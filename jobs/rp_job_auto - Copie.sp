/*
*   Roleplay CS:GO de Benito est mis à disposition selon les termes de la licence Creative Commons Attribution .
* - Pas d’Utilisation Commerciale 
* - Partage dans les Mêmes Conditions 4.0 International.
*
*   Merci de respecter le travail fourni par le ou les auteurs 
*   https://enemy-down.fr - benitalpa1020@gmail.com
*/

/***************************************************************************************

							C O M P I L E  -  O P T I O N S

***************************************************************************************/
#pragma semicolon 1
#pragma newdecls required

/***************************************************************************************

										H E A D E R

***************************************************************************************/
#include <roleplay_csgo.inc>
#include <collisionhook>

/***************************************************************************************

							P L U G I N  -  D E F I N E S

***************************************************************************************/

#define JOBID	18
#define VEHICLE_TYPE_AIRBOAT_RAYCAST	8
#define COLLISION_GROUP_PLAYER			5
#define SOLID_VPHYSICS 					6

/***************************************************************************************

							G L O B A L  -  V A R S

***************************************************************************************/

// Methodmap Constructor
Roleplay m_iClient[MAXPLAYERS + 1];

Database 
	g_DB;
Handle 
	g_LeaveVehicle;
KeyValues 
	gKv;
int 
	iServiceVehicle[MAXPLAYERS + 1] = -1;
char
	sSelectedBodyGroup[MAXPLAYERS + 1][32];
ArrayList
	g_aBodyData;

enum struct Cvars {
	ConVar runover_speed;
	
	// Death icon for vehicle run overs.
	// Built-in icons are located in 'materials/panorama/images/icons/equipment'
	// Default icon is 'materials/panorama/images/icons/equipment/radarjammer.svg'
	// Another good option was 'stomp_damage.svg'
	ConVar runover_icon;
}
Cvars cvar;

enum struct ClientData {
	char steamID[32];
	int SeatEntity;
	int Seat;
	int PassengerOnCar;
	int LastWeapon;
	int ClientLastSpeed;
	bool NotifByFlash;
	bool IsExitVehicleConfirm;
	
	// Vehicle informations
	int VehicleIndex;
	bool HasVehicleSpawned;
	bool CarHorn;
}
ClientData iData[MAXPLAYERS + 1];

enum struct VehicleData {
	int car_light[4];
	int police_car_light[2];
	int SmokeEntity;
	int DamageEntity;
	int passengersCount;
	int SeatEntity[7];
	int SeatClientIndex[7];
	bool CarSeatAvailable[7];
	bool CarHeadLights;
	bool CarSiren;
	bool PutFuel;
	bool BackFire;
	Handle h_siren_a;
	Handle h_siren_b;
	Handle h_siren_c;
	Handle h_horn;
	int AlphaEntity;
}
VehicleData StructVehicle[MAXENTITIES + 1];

enum struct VehicleKeyValues {
	char model[256];
	char script[256];
	char maxseat[8];
	char brand[64];
	char maxfuel[8];
	char price[16];
	char police[1];
}
VehicleKeyValues VehicleKV[MAXCARS + 1];

/***************************************************************************************

							P L U G I N  -  I N F O

***************************************************************************************/
public Plugin myinfo = 
{
	name = "Roleplay - [JOB] Concessionnaire", 
	author = "MBK", 
	description = "", 
	version = "1.0", 
	url = "https://github.com/Mbk10201"
};

/***************************************************************************************

									 F U N C T I O N S

***************************************************************************************/

public void OnPluginStart()
{
	// Load global translation
	LoadTranslation();
	LoadTranslations("rp_job_auto.phrases");
	
	/*----------------------------------Commands-------------------------------*/
	// Register all local plugin commands available in game
	RegConsoleCmd("sm_garage", Command_Garage);
	RegConsoleCmd("sm_service", Command_Service);
	RegConsoleCmd("rp_car", Command_Vehicle);
	/*-------------------------------------------------------------------------------*/
	
	/*----------------------------------Register GameData Offsets & Signatures-------------------------------*/
	GameData gamedata = new GameData("vehicles.game.csgo");
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(gamedata, SDKConf_Signature, "CBasePlayer::LeaveVehicle");
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
	PrepSDKCall_AddParameter(SDKType_QAngle, SDKPass_ByRef);

	if((g_LeaveVehicle = EndPrepSDKCall()) == INVALID_HANDLE)
	{
		SetFailState("[SM] ERROR: Missing offset 'bool CBasePlayer::GetInVehicle()'");
	}
	
	delete gamedata;
	/*-------------------------------------------------------------------------------*/
	
	g_aBodyData = new ArrayList(1024);
	
	cvar.runover_speed = CreateConVar("runover_speed", "15", "Required vehicle speed for running over and damaging players.", .hasMin = true, .hasMax = true, .max = 75.0);
	cvar.runover_icon = CreateConVar("runover_icon", "radarjammer", "Death icon for vehicle run overs.");
	AutoExecConfig(true, "rp_vehicles", "roleplay");
}

public void RP_OnSQLInit(Database db, Transaction transaction)
{
	g_DB = db;
	
	char sBuffer[MAX_BUFFER_LENGTH + 1];
	
	Format(STRING(sBuffer), "CREATE TABLE IF NOT EXISTS `rp_vehicles_data` ( \
	  `id` int(20) NOT NULL, \
	  `model` varchar(256) NOT NULL, \
	  `script` varchar(256) NOT NULL, \
	  `brand` varchar(64) NOT NULL, \
	  `maxfuel` varchar(8) NOT NULL, \
	  `price` varchar(16) NOT NULL, \
	  `police` varchar(1) NOT NULL, \
	  `wheels` varchar(8) NOT NULL, \
	  PRIMARY KEY (`id`), \
	  UNIQUE KEY `id` (`id`)\
	  )ENGINE = InnoDB DEFAULT CHARSET = utf8 COLLATE = utf8_bin;");
	#if DEBUG
		PrintToServer(sBuffer);
	#endif
	transaction.AddQuery(sBuffer);
		
	Format(STRING(sBuffer), "CREATE TABLE IF NOT EXISTS `rp_vehicles` ( \
	  `id` int(20) NOT NULL AUTO_INCREMENT, \
	  `serial` varchar(64) NOT NULL, \
	  `playerid` int(20) NOT NULL, \
	  `carid` int(3) NOT NULL, \
	  `r` int(3) NOT NULL, \
	  `g` int(3) NOT NULL, \
	  `b` int(3) NOT NULL, \
	  `fuel` float NOT NULL, \
	  `health` float NOT NULL, \
	  `km` float NOT NULL, \
	  `stat` int(1) NOT NULL, \
	  `skin` int(2) NOT NULL, \
	  `wheels` int(2) NOT NULL, \
	  PRIMARY KEY (`id`), \
	  FOREIGN KEY (`playerid`) REFERENCES `rp_players` (`id`) ON DELETE CASCADE ON UPDATE CASCADE, \
	  FOREIGN KEY (`carid`) REFERENCES `rp_vehicles_data` (`id`) ON DELETE CASCADE ON UPDATE CASCADE \
	  )ENGINE = InnoDB DEFAULT CHARSET = utf8 COLLATE = utf8_bin;");
	#if DEBUG
		PrintToServer(sBuffer);
	#endif
	transaction.AddQuery(sBuffer);
}

public void OnMapStart()
{
	Transaction transaction = new Transaction();
	
	/*----------------------------------Load Vehicles file into plugin-------------------------------*/
	char sBuffer[MAX_BUFFER_LENGTH + 1];
	gKv = new KeyValues("Vehicles");
	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, STRING(sPath), "data/roleplay/vehicles.cfg");
	Kv_CheckIfFileExist(gKv, sPath);
	/*-------------------------------------------------------------------------------*/
	
	// Jump into the first subsection
	if (!gKv.GotoFirstSubKey())
	{
		PrintToServer("ERROR FIRST KEY");
		delete gKv;
		return;
	}
	
	char sId[8];
	do
	{
		if(gKv.GetSectionName(STRING(sId)))
		{
			char sModel[256], sScript[256], sSeats[8], sBrand[64], sMaxFuel[8], sPrice[1], sPolice[8], sWheels[8];
			gKv.GetString("model", STRING(sModel));
			gKv.GetString("script", STRING(sScript));
			gKv.GetString("seats", STRING(sSeats));
			gKv.GetString("brand", STRING(sBrand));
			gKv.GetString("maxfuel", STRING(sMaxFuel));
			gKv.GetString("price", STRING(sPrice));
			gKv.GetString("policeCar", STRING(sPolice));
			
			PrecacheModel(sModel);
			
			strcopy(VehicleKV[StringToInt(sId)].model, sizeof(VehicleKV[].model), sModel);
			strcopy(VehicleKV[StringToInt(sId)].script, sizeof(VehicleKV[].script), sScript);
			strcopy(VehicleKV[StringToInt(sId)].maxseat, sizeof(VehicleKV[].maxseat), sSeats);
			strcopy(VehicleKV[StringToInt(sId)].brand, sizeof(VehicleKV[].brand), sBrand);
			strcopy(VehicleKV[StringToInt(sId)].maxfuel, sizeof(VehicleKV[].maxfuel), sMaxFuel);
			strcopy(VehicleKV[StringToInt(sId)].price, sizeof(VehicleKV[].price), sPrice);
			strcopy(VehicleKV[StringToInt(sId)].police, sizeof(VehicleKV[].police), sPrice);
			
			
			Format(STRING(sBuffer), "INSERT IGNORE INTO `rp_vehicles_data` (`id`, `model`, `script`, `brand`, `maxfuel`, `price`, `police`, `wheels`) VALUES ('%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s');", sId, sModel, sScript, sBrand, sMaxFuel, sPrice, sPolice, sWheels);
			transaction.AddQuery(sBuffer);
			
			gKv.SavePosition();
			if(gKv.JumpToKey("bodygroups"))
			{
				gKv.GotoFirstSubKey();
				
				do {
					gKv.GetSectionName(STRING(sBuffer));
					gKv.JumpToKey(sBuffer);
					
					Format(STRING(sBuffer), "%s|%i|%s", sBuffer, gKv.GetNum("max"), sId);
					g_aBodyData.PushString(sBuffer);
				}
				while (gKv.GotoNextKey());
				gKv.GoBack();
			}
			gKv.GoBack();
		}	
	} 
	while (gKv.GotoNextKey());
	
	gKv.Rewind();
	g_DB.Execute(transaction, SQL_OnSucces, SQL_OnFailed, 0, DBPrio_High);
}

public void OnMapEnd()
{
	if(gKv != null)
		delete gKv;
}

public void OnPluginEnd()
{
	if(gKv != null)
		delete gKv;
}

/***************************************************************************************

									N A T I V E S

***************************************************************************************/

public APLRes AskPluginLoad2(Handle plugin, bool late, char[] error, int err_max)
{
	CreateNative("rp_SpawnVehicle", Native_SpawnVehicle);
	CreateNative("rp_KickFromVehicle", Native_KickFromVehicle);
}

public int Native_SpawnVehicle(Handle plugin, int numParams) 
{
	int client = GetNativeCell(1);
	int carID = GetNativeCell(2);
	float km = vfloat(GetNativeCell(3));
	float fuel = vfloat(GetNativeCell(4));
	float health = vfloat(GetNativeCell(5));
	bool newcar = GetNativeCell(6);

	if(!IsClientValid(client))
		return -1;

	int color[4];
	color[0] = GetRandomInt(0, 255);
	color[1] = GetRandomInt(0, 255);
	color[2] = GetRandomInt(0, 255);

	float eyeAngles[3], origin[3], angles[3];
	GetClientEyeAngles(client, eyeAngles);
	angles[1] = eyeAngles[1] - 90.0;
	PointVision(client, origin);

	SpawnVehicle(client, carID, origin, angles, km, fuel, health, color, newcar);

	return 0;
}

public int Native_KickFromVehicle(Handle plugin, int numParams) 
{
	int client = GetNativeCell(1);
	int vehicle = GetNativeCell(2);

	if(!Vehicle_IsValid(vehicle))
		return -1;

	ExitVehicle(client, vehicle);

	return 0;
}

/***************************************************************************************

									C A L L B A C K

***************************************************************************************/

public Action Command_Vehicle(int client, int args)
{
	if(rp_GetAdmin(client) == ADMIN_FLAG_NONE)
	{
		Translation_PrintNoAccess(client);
		return Plugin_Handled;
	}
	
	char arg[64];
	GetCmdArg(1, STRING(arg));
	
	int target = FindTarget(client, arg, true);
	if (target <= COMMAND_TARGET_NONE)
	{
		ReplyToTargetError(client, target);
		return Plugin_Handled;
	}
	
	char arg2[64];
	GetCmdArg(2, STRING(arg2));
			
	int color[4];
	color[0] = 255; //GetRandomInt(0, 255);
	color[1] = 255; //GetRandomInt(0, 255);
	color[2] = 255; //GetRandomInt(0, 255);
			
	if(IsClientValid(target))
	{
		float origin[3], angles[3];
		GetClientAbsOrigin(target, origin);
		GetClientAbsAngles(target, angles);
		
		//rp_SendHelicopter(client, CAR);
		
		SpawnVehicle(target, StringToInt(arg2), origin, angles, 0.0, 75.0, 1000.0, color);
		
		origin[2] += 50.0;
		TeleportEntity(target, origin, NULL_VECTOR, NULL_VECTOR);
	}
			
	return Plugin_Handled;
}	

/***************************************************************************************

									C L I E N T - S I D E

***************************************************************************************/

public Action RP_OnClientFire(int client, int target, const char[] weapon)
{
	if(Vehicle_IsValid(target))
	{
		if (rp_GetEntityHealth(target) > 1.0)
		{
			if (!StrEqual(weapon, "weapon_fists"))
			{
				float value = GetRandomFloat(5.0, 7.0);
				rp_SetEntityHealth(target, rp_GetEntityHealth(target) - value);
				rp_DisplayHealth(client, target, 0.0, 0, true);
			}	
		}
		else 
			CreateTimer(1.0, ExploserVoiture, target);
	}
}

public void OnClientAuthorized(int client, const char[] auth) 
{	
	strcopy(iData[client].steamID, sizeof(iData[].steamID), auth);
}

public void OnClientPutInServer(client)
{
	// MethodMap Constructor
	m_iClient[client] = Roleplay(client);
	
	iData[client].CarHorn = false;
	iData[client].NotifByFlash = false;
	
	SDKHook(client, SDKHook_OnTakeDamage, OnClientTakeDamage);
	iData[client].ClientLastSpeed = 0;
}	

public void OnClientDisconnect(int client)
{
	if(!IsClientValid(client))
		return;
	
	iData[client].CarHorn = false;
	int vehicle = GetClientVehicle(client);
	if(vehicle != -1)
		ExitVehicle(client, vehicle);
		
	StoreVehicle(client);	
}	

void SpawnVehicle(int client, int carID, float origin[3], float angles[3] = NULL_VECTOR, float km, float fuel, float health, int color[4], bool newCar = true)
{
	if(!StrEqual(VehicleKV[carID].model, ""))
	{
		iData[client].HasVehicleSpawned = true;
		
		int skin = GetRandomInt(0, 5);
		char skinStr[10];
		IntToString(skin, STRING(skinStr));
		
		int entity = UTIL_CreateVehicle(_, origin, angles, _, VehicleKV[carID].model, VehicleKV[carID].script, skinStr, _, OnPreThinkPost, color);
		rp_SetVehicleFloat(entity, car_fuel, fuel);
		rp_SetVehicleFloat(entity, car_maxFuel, StringToFloat(VehicleKV[carID].maxfuel));		
		rp_SetVehicleFloat(entity, car_km, km);
		rp_SetVehicleInt(entity, car_owner, client);
		rp_SetVehicleInt(entity, car_maxPassager, StringToInt(VehicleKV[carID].maxseat));
		rp_SetVehicleInt(entity, car_price, StringToInt(VehicleKV[carID].price));
		rp_SetVehicleInt(entity, car_id, carID);
		rp_SetVehicleInt(entity, car_skinid, 0);
		rp_SetVehicleInt(entity, car_wheeltype, 0);
		rp_SetVehicleString(entity, car_brand, VehicleKV[carID].brand, sizeof(VehicleKV[].brand));
		
		char serial[32];
		GenerateVehicleSerial(STRING(serial));
		rp_SetVehicleString(entity, car_serial, STRING(serial));
		
		StructVehicle[entity].PutFuel = false;
		iData[client].VehicleIndex = entity;
		
		rp_SetClientKeyVehicle(client, entity, true);
		if(gKv.GetNum("policeCar") == 1)
			rp_SetVehicleInt(entity, car_police, 1);
		else
			rp_SetVehicleInt(entity, car_police, 0);
		
		float blue_rgb[3], red_rgb[3], brake_angles[3];
		blue_rgb[0] = 0.0;
		blue_rgb[1] = 0.0;
		blue_rgb[2] = 255.0;
		
		red_rgb[0] = 255.0;
		red_rgb[1] = 0.0;
		red_rgb[2] = 0.0;
		
		brake_angles[0] = 0.0;
		brake_angles[1] = 0.0;
		brake_angles[2] = 0.0;
	
		if(rp_GetVehicleInt(entity, car_police) == 1)
		{
			int blue = UTIL_CreateSprite(entity, NULL_VECTOR, NULL_VECTOR, "light_01", "sprites/light_glow02.spr", "0.2", "5", 0.0, blue_rgb);
			AcceptEntityInput(blue, "HideSprite");			
			StructVehicle[entity].police_car_light[0] = blue;
			
			int red = UTIL_CreateSprite(entity, NULL_VECTOR, NULL_VECTOR, "light_02", "sprites/light_glow02.spr", "0.2", "5", 0.0, red_rgb);
			AcceptEntityInput(red, "HideSprite");			
			StructVehicle[entity].police_car_light[1] = red;
			StructVehicle[entity].CarSiren = false;
		}
	
		if(newCar)
		{
			char playername[MAX_NAME_LENGTH + 8];
			GetClientName(client, STRING(playername));
			char clean_playername[MAX_NAME_LENGTH * 2 + 16];
			SQL_EscapeString(g_DB, playername, STRING(clean_playername));
			
			char buffer[2048];
			Format(STRING(buffer), "INSERT IGNORE INTO `rp_vehicles` (`serial`, `playerid`, `carID`, `r`, `g`, `b`, `fuel`, `health`, `km`, `stat`, `stat`, `wheels`) VALUES ('%s', '%i', '%i', '%i', '%i', '%i', '%.2f', '100.0', '0.0', '0', '0');", serial, rp_GetSQLID(client), carID, color[0], color[1], color[2], VehicleKV[carID].maxfuel);
			g_DB.Query(SQLErrorCheckCallback, buffer);
		}	
		/*___________________________________________*/
		
		/*____________________ACCESSORY____________________*/
		/*int damage = UTIL_CreateDamage(entity, NULL_VECTOR, Vehicle_GetDriver(entity), 50.0, 32.0);
		StructVehicle[entity].DamageEntity = damage;
		AcceptEntityInput(damage, "TurnOff");
		
		int smoke = UTIL_CreateSmoke(entity, NULL_VECTOR, NULL_VECTOR, "exhaust", "15", "10", "40", "20", "5", _, _, _, "60 62 61", "200", "particle/smokesprites_0001.vmt");
		StructVehicle[entity].SmokeEntity = smoke;
		AcceptEntityInput(smoke, "TurnOff");
		
		int front_left = UTIL_CreateLight(entity, NULL_VECTOR, "fl_light", "60", "70", "2", "-20", "0", _, "255 255 255 511", 768.0, 220.0, 0.0);
		AcceptEntityInput(front_left, "TurnOff");			
		StructVehicle[entity].car_light[0] = front_left;
		
		int front_right = UTIL_CreateLight(entity, NULL_VECTOR, "fr_light", "60", "70", "2", "-20", "0", _, "255 255 255 511", 768.0, 220.0, 0.0);
		AcceptEntityInput(front_right, "TurnOff");			
		StructVehicle[entity].car_light[1] = front_right;
		
		int rear_left = UTIL_CreateSprite(entity, NULL_VECTOR, NULL_VECTOR, "rl_light", "sprites/light_glow02.spr", "0.1", "5", 0.0, red_rgb);
		AcceptEntityInput(rear_left, "HideSprite");			
		StructVehicle[entity].car_light[2] = rear_left;
		
		int rear_right = UTIL_CreateSprite(entity, NULL_VECTOR, NULL_VECTOR, "rr_light", "sprites/light_glow02.spr", "0.1", "5", 0.0, red_rgb);
		AcceptEntityInput(rear_right, "HideSprite");			
		StructVehicle[entity].car_light[3] = rear_right;*/
		
		rp_SetEntityHealth(entity, health);
		
		Vehicle vehiclemethod = Vehicle(entity);
		
		for(int i = 0; i <= (rp_GetVehicleInt(entity, car_maxPassager) - 1); i++)
		{
			StructVehicle[entity].SeatEntity[i] = vehiclemethod.CreateExtendedSeat(i);
		}
	}
}

void StoreVehicle(int client)
{
	iData[client].HasVehicleSpawned = true;
	
	int entity = iData[client].VehicleIndex;
	if(entity != -1)
	{
		char serial[32];
		rp_GetVehicleString(entity, car_serial, STRING(serial));
		
		AcceptEntityInput(entity, "Kill");	
		SQL_Request(g_DB, "UPDATE `rp_vehicles` SET `fuel` = '%0.1f', `health` = '%0.1f', `km` = '%0.1f' WHERE `serial` = '%s' AND `playerid` = '%i';", rp_GetVehicleFloat(entity, car_fuel), rp_GetEntityHealth(entity), rp_GetVehicleFloat(entity, car_km), serial, rp_GetSQLID(client));
		rp_PrintToChat(client, "%T", "StoreCar", LANG_SERVER);
	}
	else
	{
		#if DEBUG
			PrintToServer("StoreVehicle(%N): Invalid vehicle", client);
		#endif
	}
}

public void OnPreThinkPost(int entity)
{
	int client = GetEntPropEnt(entity, Prop_Send, "m_hPlayer");
	if(IsClientValid(client))
	{
		int buttons = GetClientButtons(client);
		int mpg = GetEntProp(entity, Prop_Data, "m_nSpeed");
		int owner = rp_GetVehicleInt(entity, car_owner);
		
		if(rp_GetVehicleFloat(entity, car_fuel) == 3.0 || rp_GetVehicleFloat(entity, car_fuel) == 4.0 || rp_GetVehicleFloat(entity, car_fuel) == 5.0)
			rp_PrintToChat(client, "Votre voiture carbure sur la réserve.");
		else if(rp_GetVehicleFloat(entity, car_fuel) == 1.0 || rp_GetVehicleFloat(entity, car_fuel) == 2.0)
			rp_PrintToChat(client, "Votre voiture va tomber à court de carburant.");
		
		if(rp_GetVehicleFloat(entity, car_fuel) > 0.0)
		{	
			/*if(!vbool(rp_GetVehicleInt(entity, car_engine)) && buttons != 0)
				ShowPanel2(client, 2, "<font color='#FF3402'>La voiture n'est pas démarrée</font>");*/
				
			if(GetEntProp(entity, Prop_Send, "m_bEnterAnimOn") == 1)
			{
				float posY[3] = {0.0, 90.0, 0.0};
				TeleportEntity(client, NULL_VECTOR, posY, NULL_VECTOR);
				
				SetEntProp(entity, Prop_Send, "m_bEnterAnimOn", 0);
				SetEntProp(entity, Prop_Send, "m_nSequence", 0);
				
				SendConVarValue(client, FindConVar("sv_client_predict"), "0");
			}	
			
			if(mpg >= 50 /*&& !StructVehicle[entity].BackFire*/)
			{
				StructVehicle[entity].BackFire = true;
				UTIL_CreateParticle(entity, NULL_VECTOR, NULL_VECTOR, "exhaust", "env_fire_large", 0.5);
				UTIL_CreateParticle(entity, NULL_VECTOR, NULL_VECTOR, "exhaust2", "env_fire_large", 0.5);
			}	
			/*else
				StructVehicle[entity].BackFire = true;*/
			
			if(rp_GetVehicleInt(entity, car_engine) == 1)
			{
				int light;
				if (mpg > FindConVar("rp_speed_limit").IntValue)
				{
					if (RADAR_1(entity))
					{
						if(!iData[owner].NotifByFlash && rp_GetClientInt(owner, i_Job) != 1 && rp_GetClientInt(owner, i_Job) != 5 && rp_GetClientInt(owner, i_Job) != 7)
						{
							iData[owner].NotifByFlash = true;			
							CreateTimer(1.0, FLASH, owner);
							iData[owner].ClientLastSpeed = mpg;
						}	
					}	
				}
				
				if(mpg > 0)
				{			
					rp_SetVehicleFloat(entity, car_km, rp_GetVehicleFloat(entity, car_km) + 0.001 / mpg);	
					if (buttons & IN_FORWARD)
					{
						float substract = 0.005 / mpg;
						rp_SetVehicleFloat(entity, car_fuel, rp_GetVehicleFloat(entity, car_fuel) - substract); // accelerate
					}
					else if (buttons & IN_BACK)
					{
						float substract = 0.002 / mpg;
						rp_SetVehicleFloat(entity, car_fuel, rp_GetVehicleFloat(entity, car_fuel) - substract); // reverse
					}
				}
				else
				{
					rp_SetVehicleFloat(entity, car_fuel, rp_GetVehicleFloat(entity, car_fuel) - 0.00005); // idle
				}
				
				if (buttons & IN_ATTACK)
				{
					if(!iData[client].CarHorn)
					{
						char sTmp[128];
						rp_GetGlobalData("sound_klaxon", STRING(sTmp));
						if(!StrEqual(sTmp, ""))
							EmitSoundToAll(sTmp, entity, SNDCHAN_AUTO, SNDLEVEL_CAR, _, 0.5);
						
						iData[client].CarHorn = true;
						StructVehicle[entity].h_horn = CreateTimer(1.0, Horn_Time, client);
					}	
				}
				else if (buttons & IN_SCORE)
				{
					char sTmp[128];
					rp_GetGlobalData("sound_antilag", STRING(sTmp));
					if(!StrEqual(sTmp, ""))
						EmitSoundToAll(sTmp, entity, SNDCHAN_AUTO, SNDLEVEL_CAR, _, 0.5);
				}
				
				
				if (buttons & IN_JUMP)
				{
					light = StructVehicle[entity].car_light[2];
					if (IsValidEntity(light))
					{
						AcceptEntityInput(light, "ShowSprite");
					}
					light = StructVehicle[entity].car_light[3];
					if (IsValidEntity(light))
					{
						AcceptEntityInput(light, "ShowSprite");
					}
				}
				else
				{	
					light = StructVehicle[entity].car_light[2];
					if (IsValidEntity(light))
					{
						AcceptEntityInput(light, "HideSprite");
					}
					light = StructVehicle[entity].car_light[3];
					if (IsValidEntity(light))
					{
						AcceptEntityInput(light, "HideSprite");
					}
				}				
			}		
		}	
		else
		{
			ExitVehicle(client, entity);
			rp_PrintToChat(client, "Votre voiture est en panne de carburant.");
		}	
	}		
}

/*public Action RP_OnClientPress_CTRL(int client)
{
	if(GetClientVehicle(client) != -1)
	{
		int entity = GetClientVehicle(client);
		if(rp_GetVehicleInt(entity, car_engine) == 0)
		{
			rp_SetVehicleInt(entity, car_engine, 1);
			Vehicle_TurnOn(entity);
			ShowPanel2(client, 2, "<font color='#02FF97'>Le moteur démarre...</font>");	
			if(StructVehicle[entity].SmokeEntity != -1)
				AcceptEntityInput(StructVehicle[entity].SmokeEntity, "TurnOn");			
			ToggleLight(entity);
			EmitSoundToAll("buttons/lightswitch2.wav", client, SNDCHAN_AUTO, SNDLEVEL_NORMAL);
		}
		else
		{
			rp_SetVehicleInt(entity, car_engine, 0);
			SetEntProp(entity, Prop_Send, "m_nSpeed", 0);
			SetEntPropFloat(entity, Prop_Send, "m_flThrottle", 0.0);
			Vehicle_TurnOff(entity);
			ShowPanel2(client, 2, "<font color='#FF3402'>Le moteur se coupe...</font>");
			if(StructVehicle[entity].SmokeEntity != -1)
				AcceptEntityInput(StructVehicle[entity].SmokeEntity, "TurnOff");
			DisableLight(entity);	
		}	
	}	
}*/

public Action RP_OnClientInteract(int client, int target, const char[] class, const char[] model, const char[] name)
{
	int voiture = GetClientVehicle(client);
	
	if(IsValidEntity(voiture) && GetEntProp(voiture, Prop_Data, "m_nSpeed") == 0)
	{
		ExitVehicle(client, voiture);
		//SDKCall(g_LeaveVehicle, client, {0.0, 0.0, 0.0}, {0.0, 0.0, 0.0});
		return Plugin_Handled;
	}
	else if(IsValidEntity(voiture) && GetEntProp(voiture, Prop_Data, "m_nSpeed") != 0)
		PrintHintText(client, "Vous devez arrêter le vehicule pour sortir.");
	
	if(iData[client].PassengerOnCar != 0 && IsValidEntity(iData[client].PassengerOnCar))
	{
		ExitVehiclePassager(client);
		return Plugin_Handled;
	}
	
	if(Vehicle_IsValid(target))
	{
		if(Distance(client, target) > 150.0)
			return Plugin_Handled;
			
		Vehicle vehicle = Vehicle(target);

		char strIndex[32];
		if(rp_GetClientInt(client, i_Zone) == ZONE_GAS)
		{
			rp_SetClientBool(client, b_DisplayHud, false);
			Menu menu = new Menu(DoMenuCarUtil);
			if(rp_GetClientInt(client, i_Job) == 20)
			{
				menu.SetTitle("Vehicule de %N :", rp_GetVehicleInt(target, car_owner));
				menu.AddItem("repair", "Réparer le vehicule");
				menu.AddItem("skin", "Facturer un skin");
				menu.AddItem("piece", "Change une pièce");
			}	
			else
				menu.SetTitle("Mon Vehicle :");	
			if(rp_GetVehicleInt(target, car_owner) == client)
			{
				Format(STRING(strIndex), "%i|fuel", target);
				menu.AddItem(strIndex, "Faire le plein");
			}	
			
			menu.ExitButton = true;
			menu.Display(client, 15);
		}
			
		if(rp_GetEntityHealth(target) > 0.0)
		{
			if(rp_GetClientKeyVehicle(client, target))
			{
				AcceptEntityInput(target, "Unlock");
				AcceptEntityInput(target, "use", client);
				AcceptEntityInput(target, "Lock");
				AcceptEntityInput(target, "TurnOn");
				
				if(GetClientVehicle(client) != -1)
				{
					Client_SetObserverTarget(client, 0);
					Client_SetObserverMode(client, OBS_MODE_DEATHCAM, false);
					Client_SetDrawViewModel(client, false);	
					
					// This Only work if the car has directly player skeletton rigged to it
					//vehicle.SpawnVisualPassenger(client, target);
					
					iData[client].SeatEntity = vehicle.SpawnVisualPassenger(client, StructVehicle[target].SeatEntity[0]);
					vehicle.SpawnVisualPassenger(client, StructVehicle[target].SeatEntity[0]);
					// Dev
					vehicle.SpawnVisualPassenger(client, StructVehicle[target].SeatEntity[1]);
					StructVehicle[target].SeatClientIndex[0] = client;
					
					//UTIL_GetDistanceBetween(client, seat);
					iData[client].LastWeapon = Client_GetActiveWeapon(client);
					StructVehicle[target].passengersCount++;
				}
				
				if(rp_GetClientInt(client, i_Job) == 1 && rp_GetVehicleInt(target, car_police) == 1)
				{
					rp_SetClientBool(client, b_DisplayHud, false);
					Menu CoffreCarPolice = new Menu(DoMenuCoffreCarPolice);
					CoffreCarPolice.SetTitle("Coffre du Police Cruiser :");
					//CoffreCarPolice.AddItem("taser", "Recharger le taser");
					if(rp_GetClientInt(client, i_Grade) <= 6)
					{
						CoffreCarPolice.AddItem("1|weapon_usp_silencer", "Arme : USP");
						CoffreCarPolice.AddItem("0|weapon_nova", "Arme : Nova");
					}
					if(rp_GetClientInt(client, i_Grade) <= 5)
						CoffreCarPolice.AddItem("0|weapon_ssg08", "Arme : SSG08");
					if(rp_GetClientInt(client, i_Grade) <= 4)
					{
						if(Client_GetArmor(client) < 150)
							CoffreCarPolice.AddItem("kevlar", "Gilet pare-balles");
						else CoffreCarPolice.AddItem("", "Gilet pare-balles", ITEMDRAW_DISABLED);
					}
					CoffreCarPolice.ExitButton = true;
					CoffreCarPolice.Display(client, 15);
				}
			}
			else if(rp_GetClientInt(client, i_Job) == 1 && rp_GetClientInt(client, i_Grade) <= 5)
			{
				Menu GererVoiture = new Menu(DoMenuGererVoiture);
				GererVoiture.SetTitle("Géstion voiture :");
				
				char strMenu[32];
				if(IsClientValid(Vehicle_GetDriver(target)))
				{
					if(rp_GetClientInt(client, i_Job) < Vehicle_GetDriver(target))
					{
						Format(STRING(strMenu), "conducteur|%i", target);
						GererVoiture.AddItem(strMenu, "Sortir le conducteur");
						if(StrContains(name, "police") == -1)
						{
							Format(STRING(strMenu), "fourriere|%i", target);
							GererVoiture.AddItem(strMenu, "Mettre la voiture en fourrière");
						}
					}
				}
				
				GererVoiture.ExitButton = true;
				GererVoiture.Display(client, 15);
			}
			else if(IsClientValid(Vehicle_GetDriver(target)))
			{
				PrecacheSound("doors/default_locked.wav");
				EmitSoundToClient(client, "doors/default_locked.wav", client, _, _, _, 0.8);
				
				int count;
				LoopClients(i)
				{
					if(iData[i].PassengerOnCar == target)
						count++;
				}
				
				if(count <= rp_GetVehicleInt(target, car_maxPassager))
				{
					rp_SetClientBool(target, b_DisplayHud, false);
					Menu mVoiture = new Menu(DoMenuVoiture);
					mVoiture.SetTitle("%N souhaite entrer dans votre voiture.\nL'acceptez-vous ?", client);
					char strMenu[32];
					Format(STRING(strMenu), "oui|%i", client);
					mVoiture.AddItem(strMenu, "Accepter la demande");
					Format(STRING(strMenu), "non|%i", client);
					mVoiture.AddItem(strMenu, "Refuser la demande");
					mVoiture.AddItem(strMenu, "-----------------", ITEMDRAW_DISABLED);
					mVoiture.AddItem(strMenu, "Ignorer ce joueur");
					
					mVoiture.ExitButton = true;
					mVoiture.Display(Vehicle_GetDriver(target), 30);
				}
				else 
					rp_PrintToChat(client, "Il n'y a plus de place dans la voiture.");
			}
			else
			{
				PrintHintText(client, "Vous n'avez pas les clés de cette voiture.");
				PrecacheSound("doors/default_locked.wav");
				EmitSoundToClient(client, "doors/default_locked.wav", client, _, _, _, 0.8);
			}
		}
		else
		{
			if(rp_GetEntityHealth(target) == 0.0)
				rp_PrintToChat(client, "Votre voiture est en panne, amenez-la au concessionnaire pour la réparer.");
			else if(rp_GetVehicleFloat(target, car_fuel) == 0.0)
				rp_PrintToChat(client, "Votre voiture est sur la réserve, rendez-vous à la pompe à essence la plus prêt.");
			PrintHintText(client, "Cette voiture est en panne.");
		}
	}
	
	if(rp_GetNPCType(target) == JOBID)
	{
		if(Distance(client, target) <= 80.0)
			rp_PerformNPCSell(client, JOBID);
		else
			Translation_PrintTooFar(client);
	}
	
	return Plugin_Continue;
}	

public Action ExitVehicleConfirm(Handle timer, any client)
{
	if(IsClientValid(client)) 
		iData[client].IsExitVehicleConfirm = false;
}

public Action RP_OnClientSpawn(int client)
{
	iData[client].IsExitVehicleConfirm = false;
}

void ExitVehicle(int client, int vehicle)
{
	/*if(IsValidEntity(iData[client].SeatEntity))
		RemoveEntity(iData[client].SeatEntity);*/
	
	SDKCall(g_LeaveVehicle, client, {0.0, 0.0, 0.0}, {0.0, 0.0, 0.0});
	
	/*int speed = GetEntProp(vehicle, Prop_Data, "m_nSpeed");
	if(speed > 0)
	{
		int health = GetClientHealth(client);
		int calcul = speed / (health / 5);
		
		if(calcul < health)
			ForcePlayerSuicide(client);
		else		
			SetEntityHealth(client, RoundToCeil(vfloat(health - calcul)));
			
		rp_PlayFallDamageSound(client);
	}*/
	
	// [CLIENT RESET] :
	Client_SetThirdPersonMode(client, false);
	SendConVarValue(client, FindConVar("sv_client_predict"), "1");
	
	// [CLIENT EXIT STATEMENT] :
	char carname[64];
	Format(STRING(carname), "%i", vehicle);
	SetVariantString(carname);
	AcceptEntityInput(client, "SetParent");
	SetVariantString("exit1");
	AcceptEntityInput(client, "SetParentAttachment");
	
	float exitAng[3];
	GetEntPropVector(vehicle, Prop_Data, "m_angRotation", exitAng);
	exitAng[0] = 0.0;
	exitAng[1] += 90.0;
	exitAng[2] = 0.0;
	//TeleportEntity(client, exitPoint, exitAng, NULL_VECTOR);
	
	AcceptEntityInput(client, "ClearParent");
	SetEntPropEnt(client, Prop_Send, "m_hVehicle", -1);
	SetEntPropEnt(vehicle, Prop_Send, "m_hPlayer", -1);
	SetEntityMoveType(client, MOVETYPE_WALK);
	SetEntProp(client, Prop_Send, "m_CollisionGroup", COLLISION_GROUP_PLAYER);
	
	// [CLIENT RESET HUD] :
	int hud = GetEntProp(client, Prop_Send, "m_iHideHUD");
	hud &= ~HIDEHUD_WEAPONSELECTION;
	hud &= ~HIDEHUD_CROSSHAIR;
	hud &= ~HIDEHUD_INVEHICLE;
	SetEntProp(client, Prop_Send, "m_iHideHUD", hud);
	
	int entEffects = GetEntProp(client, Prop_Send, "m_fEffects");
	entEffects &= ~32;
	SetEntProp(client, Prop_Send, "m_fEffects", entEffects);
	
	// [VEHICLE RESET] :
	SetEntProp(vehicle, Prop_Send, "m_nSpeed", 0);
	SetEntPropFloat(vehicle, Prop_Send, "m_flThrottle", 0.0);
	//AcceptEntityInput(vehicle, "TurnOff");
	rp_SetVehicleInt(vehicle, car_engine, 1);

	SetClientViewEntity(client, client);
	
	// [WEAPON SET] :
	RemovePlayerItem(client, iData[client].LastWeapon);
	EquipPlayerWeapon(client, iData[client].LastWeapon);
	SetEntPropEnt(client, Prop_Data, "m_hActiveWeapon", iData[client].LastWeapon);
	ChangeEdictState(client, FindDataMapInfo(client, "m_hActiveWeapon"));
	CreateTimer(1.0, DebugExitVehicle, client);
	
	// [VEHICLE SEATS] :
	StructVehicle[vehicle].passengersCount--;
	// [VEHICLE LIGHTS] :
	ShutDownLights(vehicle);
}

public bool DontHitClientOrVehicle(int entity, int contentsMask, any data)
{
	return entity != data && entity != GetClientVehicle(data);
}	

public Action DebugExitVehicle(Handle timer, any client)
{
	if(IsClientValid(client))
	{
		float position[3];
		GetEntPropVector(client, Prop_Send, "m_vecOrigin", position);
		TeleportEntity(client, position, NULL_VECTOR, view_as<float>({0.0, 0.0, 0.0}));
	}
}

public Action Command_Info(int client, int args)
{
	if(rp_GetAdmin(client) == ADMIN_FLAG_NONE)
	{
		Translation_PrintNoAccess(client);
		return Plugin_Handled;
	}
	
	int target = GetClientAimTarget(client, false);
	if(Vehicle_IsValid(target))
	{		
		char arg[32];
		GetCmdArg(1, STRING(arg));		
		DispatchKeyValue(target, "setbodygroup", arg); 
		SetEntProp(target, Prop_Send, "m_nSkin", StringToInt(arg));
	}	
	
	return Plugin_Handled;
}

public Action Command_Garage(int client, int args)
{
	if(client == 0)
	{
		Translation_PrintNoAvailable();
		return Plugin_Handled;
	}
	
	char zonename[64];
	rp_GetClientString(client, sz_ZoneName, STRING(zonename));
	if(StrContains(zonename, "parking", false) == -1)
	{
		EmitGPSTrain(client, view_as<float>({-3000.34, -1786.24, 72.09 }), 255, 0, 0);
		rp_PrintToChat(client, "%T", "NotInParking", LANG_SERVER);
		return Plugin_Handled;
	}
	
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_MenuGarage);
	menu.SetTitle("%T", "MenuGarage_Title", LANG_SERVER);
	
	char query[100];
	Format(STRING(query), "SELECT * FROM `rp_vehicles` WHERE `playerid` = '%i'", rp_GetSQLID(client));	 
	DBResultSet Results = SQL_Query(g_DB, query);
	
	int cars;
	while(Results.FetchRow())
	{
		cars++;
		
		char carname[64];
		int carID = SQL_FetchIntByName(Results, "carID");
		GetVehicleName(carID, STRING(carname));
		
		char sSerial[32];
	  	SQL_FetchStringByName(Results, "serial", STRING(sSerial));
		
		char sTmp[256];
		Format(STRING(sTmp), "%s|%i|%i|%i|%i|%f|%f|%f|%i|%i|%i", \
			sSerial, \
			carID, \
			SQL_FetchIntByName(Results, "r"), \
			SQL_FetchIntByName(Results, "g"), \
			SQL_FetchIntByName(Results, "b"), \
			SQL_FetchFloatByName(Results, "fuel"), \
			SQL_FetchFloatByName(Results, "health"), \
			SQL_FetchFloatByName(Results, "km"), \
			SQL_FetchIntByName(Results, "stat"), \
			SQL_FetchIntByName(Results, "skin"), \
			SQL_FetchIntByName(Results, "wheels") \
		);
	
		menu.AddItem(sTmp, carname);
	}		
	delete Results;
	
	if(cars == 0)
	{
		rp_PrintToChat(client, "%T", "Command_GarageNoCars", LANG_SERVER);
		return Plugin_Handled;
	}
	
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);				
	
	return Plugin_Handled;
}

public int Handle_MenuGarage(Menu menu, MenuAction action, int client, int param)
{	
	if(action == MenuAction_Select)
	{
		char info[256], buffer[11][64];
		menu.GetItem(param, STRING(info));
		//buffer[0] = serial
		int carID = StringToInt(buffer[1]);
		int r, g, b;
		r = StringToInt(buffer[2]);
		g = StringToInt(buffer[3]);
		b = StringToInt(buffer[4]);
		float fuel = StringToFloat(buffer[5]);
		float health = StringToFloat(buffer[6]);
		float distance = StringToFloat(buffer[7]);
		int stat = StringToInt(buffer[8]);
		int skin = StringToInt(buffer[9]);
		int wheel = StringToInt(buffer[10]);
		
		char carname[64];
		GetVehicleName(carID, STRING(carname));
		
		rp_SetClientBool(client, b_DisplayHud, false);
		Menu menu1 = new Menu(Handle_MenuGarageFinal);
		menu1.SetTitle(carname);
		
		char strMenu[64], strIndex[64];
			
		Format(STRING(strMenu), "%T", "MenuGarage_CarFuel", LANG_SERVER, fuel);
		menu1.AddItem("", strMenu, ITEMDRAW_DISABLED);
		
		Format(STRING(strMenu), "%T", "MenuGarage_CarHealth", LANG_SERVER, health);
		menu1.AddItem("", strMenu, ITEMDRAW_DISABLED);
		
		Format(STRING(strMenu), "%T", "MenuGarage_CarKm", LANG_SERVER, distance);
		menu1.AddItem("", strMenu, ITEMDRAW_DISABLED);
		
		
		Format(STRING(strMenu), "%T", "MenuGarage_CarSpawn", LANG_SERVER);	
		Format(STRING(strIndex), "%i|%i|%i|%i|%f|%f|%f|%i|%i|spawn", buffer[0], carID, r, g, b, fuel, health, distance, skin, wheel);
		
		if(stat)
			menu1.AddItem("", strMenu, ITEMDRAW_DISABLED);
		else if(iData[client].HasVehicleSpawned)
			menu1.AddItem("", strMenu, ITEMDRAW_DISABLED);
		else
			menu1.AddItem(strIndex, strMenu);	
			
		Format(STRING(strMenu), "%T", "MenuGarage_CarStore", LANG_SERVER);
		if(iData[client].HasVehicleSpawned && Vehicle_IsValid(iData[client].VehicleIndex) 
		&& rp_GetVehicleInt(iData[client].VehicleIndex, car_id) == carID && GetClientVehicle(client) == -1)
		{
			menu1.AddItem("", strMenu);
		}
		else
			menu1.AddItem("", strMenu, ITEMDRAW_DISABLED);
		
		menu1.ExitButton = true;
		menu1.Display(client, MENU_TIME_FOREVER);
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit || param == MenuCancel_ExitBack)
			rp_SetClientBool(client, b_DisplayHud, true);
	}
	else if(action == MenuAction_End)
		delete menu;
}

public int Handle_MenuGarageFinal(Menu menu, MenuAction action, int client, int param)
{	
	if(action == MenuAction_Select)
	{
		char info[128], buffer[8][128];
		menu.GetItem(param, STRING(info));
		ExplodeString(info, "|", buffer, 8, 128);
		
		if(StrEqual(buffer[7], "spawn"))
		{
			int carID = StringToInt(buffer[0]);
			
			int color[4];
			color[0] = StringToInt(buffer[1]);
			color[1] = StringToInt(buffer[2]);
			color[2] = StringToInt(buffer[3]);
			
			float fuel = StringToFloat(buffer[4]);
			float health = StringToFloat(buffer[5]);
			float km = StringToFloat(buffer[6]);
			
			float eyeAngles[3], origin[3], angles[3];
			GetClientEyeAngles(client, eyeAngles);
			angles[1] = eyeAngles[1] - 90.0;
			PointVision(client, origin);
			
			
			SpawnVehicle(client, carID, origin, angles, km, fuel, health, color, false);
		}	
		else
			StoreVehicle(client);
			
		rp_SetClientBool(client, b_DisplayHud, true);	
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit || param == MenuCancel_ExitBack)
			rp_SetClientBool(client, b_DisplayHud, true);
	}
	else if(action == MenuAction_End)
		delete menu;
}

void ToggleSiren(int car)
{
	if (IsValidEntity(car))
	{
		StructVehicle[car].CarSiren = true;
		
		char sTmp[128];
		rp_GetGlobalData("sound_siren", STRING(sTmp));
		if(!StrEqual(sTmp, ""))
			EmitSoundToAll(sTmp, car, SNDCHAN_AUTO, SNDLEVEL_CAR);
			
		StructVehicle[car].h_siren_a = CreateTimer(0.15, A_Time, car);
		StructVehicle[car].h_siren_c = CreateTimer(4.50, C_Time, car);
	}
}

void DisableSiren(int car)
{
	if (IsValidEntity(car))
	{
		StructVehicle[car].CarSiren = false;
		if (IsValidEntity(StructVehicle[car].police_car_light[0]))
			AcceptEntityInput(StructVehicle[car].police_car_light[0], "HideSprite");
		if (IsValidEntity(StructVehicle[car].police_car_light[1]))
			AcceptEntityInput(StructVehicle[car].police_car_light[1], "HideSprite");
		
		if(StructVehicle[car].h_siren_a != null)
			TrashTimer(StructVehicle[car].h_siren_a);
		if(StructVehicle[car].h_siren_b != null)
			TrashTimer(StructVehicle[car].h_siren_b);
		if(StructVehicle[car].h_siren_c != null)
			TrashTimer(StructVehicle[car].h_siren_c);	
	}		
}

public Action A_Time(Handle timer, any entity)
{
	char model[256];
	Entity_GetModel(entity, STRING(model));
	
	if (StructVehicle[entity].CarSiren == true)
	{
		if (IsValidEntity(StructVehicle[entity].police_car_light[0]))
			AcceptEntityInput(StructVehicle[entity].police_car_light[0], "ShowSprite");
					
		if (IsValidEntity(StructVehicle[entity].police_car_light[1]))
			AcceptEntityInput(StructVehicle[entity].police_car_light[1], "HideSprite");
		
		StructVehicle[entity].h_siren_b = CreateTimer(0.15, B_Time, entity);
	}
	
	if (StructVehicle[entity].CarSiren == false)
	{
		if (IsValidEntity(StructVehicle[entity].police_car_light[0]))
			AcceptEntityInput(StructVehicle[entity].police_car_light[0], "HideSprite");
		
		if (IsValidEntity(StructVehicle[entity].police_car_light[1]))
			AcceptEntityInput(StructVehicle[entity].police_car_light[1], "HideSprite");
	}
}

public Action B_Time(Handle timer, any entity)
{
	char model[256];
	Entity_GetModel(entity, STRING(model));
	
	if (StructVehicle[entity].CarSiren == true)
	{
		if (IsValidEntity(StructVehicle[entity].police_car_light[0]))
			AcceptEntityInput(StructVehicle[entity].police_car_light[0], "HideSprite");
		
		if (IsValidEntity(StructVehicle[entity].police_car_light[1]))
			AcceptEntityInput(StructVehicle[entity].police_car_light[1], "ShowSprite");
			
		StructVehicle[entity].h_siren_a = CreateTimer(0.15, A_Time, entity);
	}
	if (StructVehicle[entity].CarSiren == false)
	{
		if (IsValidEntity(StructVehicle[entity].police_car_light[0]))
			AcceptEntityInput(StructVehicle[entity].police_car_light[0], "HideSprite");
		
		if (IsValidEntity(StructVehicle[entity].police_car_light[1]))
			AcceptEntityInput(StructVehicle[entity].police_car_light[1], "HideSprite");
	}
}
public Action C_Time(Handle timer, any entity)
{
	if (StructVehicle[entity].CarSiren == true)
	{
		if ((entity > 0) && (IsValidEntity(entity)))
		{
			if(Vehicle_IsValid(entity))	
			{		
				int Driver = GetEntPropEnt(entity, Prop_Send, "m_hPlayer");
				if (Driver > 0)
				{
					char sTmp[128];
					rp_GetGlobalData("sound_siren", STRING(sTmp));
					if(!StrEqual(sTmp, ""))
						EmitSoundToAll(sTmp, entity, SNDCHAN_AUTO, SNDLEVEL_CAR);
						
					StructVehicle[entity].h_siren_c = CreateTimer(4.50, C_Time, entity);
				}
			}
		}
	}
}

void ExitVehiclePassager(int client)
{
	AcceptEntityInput(client, "ClearParent");
	SetEntityMoveType(client, MOVETYPE_WALK);
	SetEntProp(client, Prop_Data, "m_CollisionGroup", COLLISION_GROUP_PLAYER);
	int vehicle = iData[client].PassengerOnCar;
	int seatid = iData[client].Seat;
	int speed = GetEntProp(vehicle, Prop_Data, "m_nSpeed");
	if(speed > 0)
	{
		int health = GetClientHealth(client);
		int calcul = speed / (health / 5);
		
		if(calcul < health)
			ForcePlayerSuicide(client);
		else		
			SetEntityHealth(client, health - calcul);
			
		rp_PlayFallDamageSound(client);
	}
	
	StructVehicle[vehicle].passengersCount--;
	StructVehicle[vehicle].CarSeatAvailable[seatid] = true;
	iData[client].Seat = 0;
	iData[client].PassengerOnCar = 0;
}

public Action Horn_Time(Handle timer, any client)
{
	iData[client].CarHorn = false;
}

bool RADAR_1(int vehicle)
{
	if (rp_GetVehicleInt(vehicle, car_insideradar) == 1)
		return true;
	else
		return false;
}

public Action FLASH(Handle timer, any client)
{
	char sTmp[128];
	rp_GetGlobalData("sound_radar", STRING(sTmp));
	if(!StrEqual(sTmp, ""))
		rp_Sound(client, sTmp, 1.0);
	ScreenFade(client, 1, {151, 154, 156, 100});
	
	iData[client].NotifByFlash = false;
	rp_SetClientBool(client, b_DisplayHud, false);
	rp_PrintToChatAll("{red}({purple}RADAR{red}){green} %N {red}vient de dépasser la limite de vitesse (%i/%i KM/H) !", client, FindConVar("rp_speed_limit").IntValue, iData[client].ClientLastSpeed);
	
	ShowPanel2(client, 5, "Vous venez de dépasser la limite de vitesse (%i KM/H)\nLimitation : %ikm/h\nPV: 50$", iData[client].ClientLastSpeed, FindConVar("rp_speed_limit").IntValue);
}

public int DoMenuCarUtil(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[64], buffer[2][64];
		menu.GetItem(param, STRING(info));
		ExplodeString(info, "|", buffer, 2, 64);
		int target = StringToInt(buffer[0]);
		
		if(StrEqual(buffer[1], "fuel"))
			MenuAddFuel(client, target);
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit || param == MenuCancel_ExitBack)
			rp_SetClientBool(client, b_DisplayHud, true);
	}
	else if(action == MenuAction_End)
		delete menu;
}

public int DoMenuCoffreCarPolice(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[64];
		menu.GetItem(param, STRING(info));
		
		if(StrEqual(info, "kevlar"))
		{
			Client_SetArmor(client, 150);
			rp_PrintToChat(client, "Vous avez récupéré un gilet pare-balles.");
		}
		/*else if(StrEqual(info, "taser"))
		{
			hasTaser[client] = true;
			PrintHintText(client, "Taser rechargé !");
		}*/
		else
		{
			char buffer[2][64];
			ExplodeString(info, "|", buffer, 2, 64);
			int slot = StringToInt(buffer[0]);
			if(slot != 7)
			{
				if(GetPlayerWeaponSlot(client, slot) == -1)
				{
					char strFormat[64];
					if(StrContains(info, "silencer") != -1)
						Format(strFormat, sizeof(strFormat), "silencer|police|%s", iData[client].steamID);
					else
						Format(strFormat, sizeof(strFormat), "police|%s", iData[client].steamID);
					
					int weapon = GivePlayerItem(client, buffer[1]);
					SetEntPropEnt(client, Prop_Data, "m_hActiveWeapon", weapon);
					ChangeEdictState(client, FindDataMapInfo(client, "m_hActiveWeapon"));
					Entity_SetName(weapon, strFormat);
				}
				else if(slot == 1)
					rp_PrintToChat(client, "Vous possédez déjà une arme de poing.");
				else
					rp_PrintToChat(client, "Vous possédez déjà une arme lourde.");
			}
		}
		rp_SetClientBool(client, b_DisplayHud, true);
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit || param == MenuCancel_ExitBack)
			rp_SetClientBool(client, b_DisplayHud, true);
	}
	else if(action == MenuAction_End)
		delete menu;
}

public int DoMenuGererVoiture(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[64], buffer[2][32];
		menu.GetItem(param, STRING(info));
		ExplodeString(info, "|", buffer, 2 , 32);
		// buffer[0] : choix
		int voiture = StringToInt(buffer[1]);
		
		if(IsValidEntity(voiture))
		{
			int driver = Vehicle_GetDriver(voiture);
			if(StrEqual(buffer[0], "conducteur"))
			{
				if(IsClientValid(driver))
				{
					ExitVehicle(driver, voiture);
					rp_PrintToChat(driver, "Vous avez sorti {lightblue}%N{default} de votre véhicule.");
					rp_PrintToChat(client, "Vous avez été sorti {red}%N {default}du véhicule.", driver);
				}
			}
			else if(StrEqual(buffer[0], "fourriere"))
			{
				if(IsClientValid(driver))
				{
					ExitVehicle(driver, voiture);
					
					char serial[32];
					rp_GetVehicleString(voiture, car_serial, STRING(serial));
					
					AcceptEntityInput(voiture, "Kill");				
					SQL_Request(g_DB, "UPDATE `rp_vehicles` SET `stat` = '1' WHERE `playerid` = '%i' AND `serial` = '%s';", rp_GetSQLID(client), serial);
				}
			}
		}
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit || param == MenuCancel_ExitBack)
			rp_SetClientBool(client, b_DisplayHud, true);
	}
	else if(action == MenuAction_End)
		delete menu;
}

public DoMenuVoiture(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[64], buffer[2][32];
		menu.GetItem(param, STRING(info));
		ExplodeString(info, "|", buffer, 2, 32);
		// buffer[0] : choix
		int joueur = StringToInt(buffer[1]);
		
		if(StrEqual(buffer[0], "oui"))
		{
			int vehicle = GetClientVehicle(client);
			if(IsValidEntity(vehicle))
			{
				char entName[64];
				Entity_GetName(vehicle, STRING(entName));
				
				/*float position[3];
				GetEntPropVector(voiture, Prop_Send, "m_vecOrigin", position);
				position[2] += 160.0;
				TeleportEntity(joueur, position, NULL_VECTOR, NULL_VECTOR);
				
				SetVariantString(entName);
				AcceptEntityInput(joueur, "SetParent");
				
				SetEntityMoveType(joueur, MOVETYPE_NONE);
				
				Client_SetObserverTarget(joueur, voiture);
				Client_SetObserverMode(joueur, OBS_MODE_DEATHCAM, false);
				Client_SetDrawViewModel(joueur, true);
				Client_SetFOV(joueur, 120);
				SetEntProp(joueur, Prop_Data, "m_CollisionGroup", COLLISION_GROUP_PLAYER);*/
				
				int id = 0;
				for(int i = 1; i <= rp_GetVehicleInt(vehicle, car_maxPassager); i++)
				{
					if(StructVehicle[vehicle].CarSeatAvailable[i])
					{
						id = i;
						break;
					}	
				}	
				
				if(id != 0)
				{
					iData[joueur].PassengerOnCar = vehicle;
					iData[joueur].LastWeapon = Client_GetActiveWeapon(client);
					
					StructVehicle[vehicle].CarSeatAvailable[id] = false;
					StructVehicle[vehicle].passengersCount++;
					Client_SetObserverTarget(joueur, 0);
					Client_SetObserverMode(joueur, OBS_MODE_DEATHCAM, false);
					Client_SetDrawViewModel(joueur, false);
					
					SetVariantString(entName);
					AcceptEntityInput(joueur, "SetParent");
					
					char tmp[32];
					Format(STRING(tmp), "vehicle_feet_passenger%i", id);
					SetVariantString(tmp);
					AcceptEntityInput(joueur, "SetParentAttachment", joueur, joueur, 0);
				}
				else
					rp_PrintToChat(joueur, "Il n'y a plus de place dans cette voiture.");
			}
		}
		else 
			rp_PrintToChat(joueur, "{grey}%N {default}a refusé de vous ouvrir sa voiture.", client);
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit || param == MenuCancel_ExitBack)
			rp_SetClientBool(client, b_DisplayHud, true);
	}
	else if(action == MenuAction_End)
		delete menu;
}

public Action ExploserVoiture(Handle timer, any ent)
{
	if(IsValidEntity(ent))
	{
		int client = Vehicle_GetDriver(ent);
		if(IsClientValid(client))
			ExitVehicle(client, ent);
		
		float position[3];
		GetEntPropVector(ent, Prop_Send, "m_vecOrigin", position);
		position[2] += 4;
		
		UTIL_CreateParticle(ent, NULL_VECTOR, NULL_VECTOR, "vehicle_engine", "dust_burning_engine", 25.0);
		
		StructVehicle[ent].AlphaEntity = 100;
		CreateTimer(1.0, Timer_FadeOut, ent, TIMER_REPEAT);
		CreateTimer(25.0, DoExplosionVoiture, ent);
	}
}

public Action DoExplosionVoiture(Handle timer, any ent)
{
	if(IsValidEntity(ent))
	{
		float position[3];
		GetEntPropVector(ent, Prop_Send, "m_vecOrigin", position);
		TE_SetupExplosion(position, -1, 1.0, 1, 0, 200, 200);
		TE_SendToAll();
		
		PrecacheSound("vehicles/v8/vehicle_impact_heavy1.wav");
		EmitSoundToAll("vehicles/v8/vehicle_impact_heavy1.wav", ent, _, _, _, 1.0);
		
		AcceptEntityInput(ent, "Kill");
		
		char serial[32];
		rp_GetVehicleString(ent, car_serial, STRING(serial));
		
		int client = Vehicle_GetDriver(ent);
		SQL_Request(g_DB, "UPDATE `rp_vehicles` SET `fuel` = '%0.1f', `health` = '%0.1f', `km` = '%0.1f' WHERE `serial` = '%s' AND `playerid` = '%i';", rp_GetVehicleFloat(ent, car_fuel), rp_GetEntityHealth(ent), rp_GetVehicleFloat(ent, car_km), serial, rp_GetSQLID(client));
	}
}

Menu MenuAddFuel(int client, int target)
{
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_MenuAddFuel);
	
	menu.SetTitle("Choisissez pour faire le plein (%i$/L)", FindConVar("rp_fuelprice").IntValue);
	
	char strIndex[32];
	
	Format(STRING(strIndex), "1.0|%i", target);
	menu.AddItem(strIndex, "1L");
	
	Format(STRING(strIndex), "5.0|%i", target);
	menu.AddItem(strIndex, "5L");
	
	Format(STRING(strIndex), "-1.0|%i", target);
	menu.AddItem(strIndex, "Le plein");
	
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Handle_MenuAddFuel(Menu menu, MenuAction action, int client, int param)
{	
	if(action == MenuAction_Select)
	{
		char info[32], buffer[2][32];
		menu.GetItem(param, STRING(info));
		ExplodeString(info, "|", buffer, 2, 32);
		
		float value = StringToFloat(buffer[0]);
		int target = StringToInt(buffer[1]);
		int price = FindConVar("rp_fuelprice").IntValue * RoundToCeil(value);
		
		MenuAddFuel(client, target);
		
		if(rp_GetClientInt(client, i_Bank) >= price)
		{
			if(rp_GetVehicleFloat(target, car_fuel) != rp_GetVehicleFloat(target, car_maxFuel))
			{
				if(value == -1)
				{
					rp_SetVehicleFloat(target, car_fuel, rp_GetVehicleFloat(target, car_maxFuel));
					rp_PrintToChat(client, "Vous avez mit +%0.1fL sur %0.1fL de carburant dans le réservoir.", rp_GetVehicleFloat(target, car_maxFuel), rp_GetVehicleFloat(target, car_maxFuel));
				}	
				else
				{
					rp_SetVehicleFloat(target, car_fuel, rp_GetVehicleFloat(target, car_fuel) + value);		
					rp_PrintToChat(client, "Vous avez mit +%0.1fL sur %0.1f/%0.1fL de carburant dans le réservoir.", value, rp_GetVehicleFloat(target, car_maxFuel));
				}	
				
				rp_SetClientInt(client, i_Bank, rp_GetClientInt(client, i_Bank) - price);
				rp_SetJobCapital(20, rp_GetJobCapital(20) + price);
				rp_PrintToChat(client, "Vous avez été facturé %i pour %0.1fL de carburant.", price, value);
			}
			else
				rp_PrintToChat(client, "Votre réservoir déborde ! capacité max %0.1fL.", rp_GetVehicleFloat(target, car_maxFuel));
		}	
		else
			rp_PrintToChat(client, "Vous ne possédez pas assez d'argent en banque.");	
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit || param == MenuCancel_ExitBack)
			rp_SetClientBool(client, b_DisplayHud, true);
	}
	else if(action == MenuAction_End)
		delete menu;
}

public void OnEntityDestroyed(int entity)
{
	if (IsValidEdict(entity))
	{
		if(Vehicle_IsValid(entity))
		{		
			int Driver = GetEntPropEnt(entity, Prop_Send, "m_hPlayer");
			if (Driver != -1)
			{
				ExitVehicle(Driver, entity);
			}
		}
	}
}

public Action OnClientTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (damagetype & DMG_VEHICLE)
	{
		char ClassName[30];
		GetEdictClassname(inflictor, ClassName, sizeof(ClassName));
		if (StrEqual("prop_vehicle_driveable", ClassName, false))
		{
			int Driver = GetEntPropEnt(inflictor, Prop_Send, "m_hPlayer");
			if (Driver != -1)
			{
				damage *= 2.0;
				attacker = Driver;
				return Plugin_Changed;
			}
		}
	}
	
	return Plugin_Continue;
}

public int RP_OnInventoryHandle(int client, int itemID)
{
	if(itemID == 163)
	{
		int target = GetClientAimTarget(client, false);
		if(Vehicle_IsValid(target))
		{
			if(Distance(client, target) <= 150.0)
			{
				int carID = rp_GetVehicleInt(target, car_id);
				if(rp_GetVehicleFloat(target, car_fuel) + 2.0 < GetVehicleMaxFuel(carID))
				{
					rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
					rp_SetVehicleFloat(target, car_fuel, rp_GetVehicleFloat(target, car_fuel) + 2.0);
					
					if (rp_GetVehicleFloat(target, car_fuel) + 2.0 >= GetVehicleMaxFuel(carID))
						rp_SetVehicleFloat(target, car_fuel, GetVehicleMaxFuel(carID));
					
					char name[32];
					rp_GetItemData(itemID, item_name, STRING(name));
					rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
				}
				else	
					rp_PrintToChat(client, "Cette voiture a déjà le plein.");
			}
			else
				rp_PrintToChat(client, "Rapprochez vous de la voiture pour faire le plein.");
		}	
		else
			rp_PrintToChat(client, "{lightred}Vous devez viser une voiture{default}.");
	}
}

/*public Action RP_OnClientStartTouch(int caller, int activator)
{
	if(Vehicle_IsValid(caller))
	{
		if(IsClientValid(activator))
		{
			float position[3], velocity[3], angle[3];
			GetClientAbsOrigin(activator, position);
			position[2] += 32.0;
			GetEntPropVector(activator, Prop_Data, "m_vecVelocity", velocity);
			GetClientEyeAngles(activator, angle);
			if (velocity[2] < -1000.0)
				velocity[2] = -1000.0;
			velocity[2] += 500.0;
			TeleportEntity(activator, NULL_VECTOR, NULL_VECTOR, velocity);
			
			CPrintToChat(activator, "Vous avez toucher une voiture");
			float vEnemy[3];
			GetEntPropVector(activator, Prop_Data, "m_vecAbsOrigin", vEnemy);
			float vVehicle[3];
			GetEntPropVector(caller, Prop_Data, "m_vecAbsOrigin", vVehicle);
			
			UTIL_CreatePhysForce(activator, vVehicle, vEnemy, 500.0, 40.0, 400.0);
		}	
	}	
}*/

void ShutDownLights(int entity)
{
	if (IsValidEntity(StructVehicle[entity].police_car_light[0]))
		AcceptEntityInput(StructVehicle[entity].police_car_light[0], "HideSprite");
	if (IsValidEntity(StructVehicle[entity].police_car_light[1]))
		AcceptEntityInput(StructVehicle[entity].police_car_light[1], "HideSprite");
	
	if (IsValidEntity(StructVehicle[entity].car_light[0]))
		AcceptEntityInput(StructVehicle[entity].car_light[0], "HideSprite");
	if (IsValidEntity(StructVehicle[entity].car_light[1]))
		AcceptEntityInput(StructVehicle[entity].car_light[1], "HideSprite");
	if (IsValidEntity(StructVehicle[entity].car_light[2]))
		AcceptEntityInput(StructVehicle[entity].car_light[2], "HideSprite");
	if (IsValidEntity(StructVehicle[entity].car_light[3]))
		AcceptEntityInput(StructVehicle[entity].car_light[3], "HideSprite");		
}

void ToggleLight(int entity)
{
	StructVehicle[entity].CarHeadLights = true;
	AcceptEntityInput(StructVehicle[entity].car_light[0], "Toggle");
	AcceptEntityInput(StructVehicle[entity].car_light[1], "Toggle");
}

void DisableLight(int entity)
{
	StructVehicle[entity].CarHeadLights = false;
	AcceptEntityInput(StructVehicle[entity].car_light[0], "TurnOff");
	AcceptEntityInput(StructVehicle[entity].car_light[1], "TurnOff");
}

public Action RP_OnClientPress_R(int client)
{
	if(GetClientVehicle(client) != -1 && Vehicle_GetDriver(GetClientVehicle(client)) == client)
	{
		MenuCarUtility(client, GetClientVehicle(client));
	}
}

Menu MenuCarUtility(int client, int vehicle)
{
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_MenuCarUtility);
	
	char tmp[64]; //index[64];
	rp_GetVehicleString(vehicle, car_brand, STRING(tmp));
	menu.SetTitle("%s", tmp);
	
	Format(STRING(tmp), "Passagers: %i/%i", StructVehicle[vehicle].passengersCount, rp_GetVehicleInt(vehicle, car_maxPassager));
	menu.AddItem("passengers", tmp);
	
	if(rp_GetVehicleInt(vehicle, car_police) == 1)
	{
		Format(STRING(tmp), "Sirène: %s", (StructVehicle[vehicle].CarHeadLights)?"ON":"OFF");
		menu.AddItem("siren", tmp);
		
		menu.AddItem("weaponservice", "Armes de service");
	}	
	
	if(rp_GetClientInt(client, i_Zone) == ZONE_GAS)
		menu.AddItem("fuel", "Faire le plein");
	
	Format(STRING(tmp), "Feu de route: %s", (StructVehicle[vehicle].CarHeadLights)?"ON":"OFF");
	menu.AddItem("headlights", tmp);
	
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Handle_MenuCarUtility(Menu menu, MenuAction action, int client, int param)
{	
	if(action == MenuAction_Select)
	{
		char info[32];
		menu.GetItem(param, STRING(info));
		
		int vehicle = GetClientVehicle(client);
		if(StrEqual(info, "passengers"))
		{
			rp_SetClientBool(client, b_DisplayHud, false);
			Menu menu1 = new Menu(Handle_MenuCarPassengers);
			menu1.SetTitle("Passagers");
			
			for(int i = 0; i <= rp_GetVehicleInt(vehicle, car_maxPassager); i++)
			{
				if(!IsClientValid(StructVehicle[vehicle].SeatClientIndex[i]))
					continue;
				
				char sIndex[64], sName[64];
				Format(STRING(sIndex), "%i", StructVehicle[vehicle].SeatClientIndex[i]);
				Format(STRING(sName), "%N", StructVehicle[vehicle].SeatClientIndex[i]);
				menu1.AddItem(sIndex, sName, (Vehicle_GetDriver(vehicle) == client) ? ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
			}
			
			menu1.ExitBackButton = true;
			menu1.ExitButton = true;
			menu1.Display(client, MENU_TIME_FOREVER);
		}
		else if(StrEqual(info, "headlights"))
		{
			if(StructVehicle[vehicle].CarHeadLights)
			{
				rp_PrintToChat(client, "Feu de route: {lightred} OFF");
				DisableLight(vehicle);
			}	
			else
			{
				rp_PrintToChat(client, "Feu de route: {lightgreen} ON");
				ToggleLight(vehicle);
			}	
			MenuCarUtility(client, vehicle);	
		}
		else if(StrEqual(info, "siren"))
		{
			if(StructVehicle[vehicle].CarSiren)
			{
				rp_PrintToChat(client, "Sirène: {lightred} OFF");
				DisableSiren(vehicle);
			}	
			else
			{
				rp_PrintToChat(client, "Sirène: {lightgreen} ON");
				ToggleSiren(vehicle);
			}
			MenuCarUtility(client, vehicle);			
		}
		else if(StrEqual(info, "fuel"))
		{
			/*if(rp_GetVehicleInt(vehicle, car_engine) == 1)
				rp_PrintToChat(client, "Veuillez couper le moteur avant de faire le plein.");
			else*/
			MenuFuel(client);
		}
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit || param == MenuCancel_ExitBack)
			rp_SetClientBool(client, b_DisplayHud, true);
	}
	else if(action == MenuAction_End)
		delete menu;
}

public int Handle_MenuCarPassengers(Menu menu, MenuAction action, int client, int param)
{	
	if(action == MenuAction_Select)
	{
		char info[32];
		menu.GetItem(param, STRING(info));
		
		int passenger = StringToInt(info);
		
		ExitVehiclePassager(passenger);
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit || param == MenuCancel_ExitBack)
			rp_SetClientBool(client, b_DisplayHud, true);
	}
	else if(action == MenuAction_End)
		delete menu;
}

Menu MenuFuel(int client)
{
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_MenuFuel);
	
	int vehicle = GetClientVehicle(client);
	char tmp[64]; //index[64];
	menu.SetTitle("Station Service");
	
	rp_GetVehicleString(vehicle, car_brand, STRING(tmp));
	
	Format(STRING(tmp), "Vehicule: %s", tmp);
	menu.AddItem("", tmp, ITEMDRAW_DISABLED);
	
	Format(STRING(tmp), "Carburant: %0.1f/%0.1f", rp_GetVehicleFloat(vehicle, car_fuel), rp_GetVehicleFloat(vehicle, car_maxFuel));
	menu.AddItem("", tmp, ITEMDRAW_DISABLED);
	
	//if(!StructVehicle[entVehicle].PutFuel)
	
	//Format(STRING(tmp), "Distribution automatique: %s", (StructVehicle[entVehicle].PutFuel)?"ON":"OFF");
	menu.AddItem("autopump", tmp);
	
	menu.AddItem("autopump", "Ajouter +1L");
	
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Handle_MenuFuel(Menu menu, MenuAction action, int client, int param)
{	
	if(action == MenuAction_Select)
	{
		char info[32];
		menu.GetItem(param, STRING(info));
		
		/*int vehicle = GetClientVehicle(client);
		if(StrEqual(info, "autopump"))
		{
			
		}*/
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit || param == MenuCancel_ExitBack)
			rp_SetClientBool(client, b_DisplayHud, true);
	}
	else if(action == MenuAction_End)
		delete menu;
}

public Action Timer_FadeOut(Handle timer, int entity)
{
	if(StructVehicle[entity].AlphaEntity > 0)
	{
		StructVehicle[entity].AlphaEntity -= 10;
		SetEntityRenderColor(entity, _, _, _, StructVehicle[entity].AlphaEntity);
	}
	else
		TrashTimer(timer, true);
}

public void RP_OnAdmin(Menu menu, int client)
{
	char sTmp[64];
	Format(STRING(sTmp), "%T", "ADMIN_MenuVehicle_Title", LANG_SERVER);
	
	menu.AddItem("vehicles", sTmp);
}

public int RP_OnAdminHandle(int client, const char[] info)
{
	if(StrEqual(info, "vehicles"))
	{
		MenuAdmin_Vehicles(client);
	}
}

Menu MenuAdmin_Vehicles(int client)
{
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_MenuAdmin_Vehicles);

	char sTmp[64];
	menu.SetTitle("%T", "ADMIN_MenuVehicle_Title", LANG_SERVER);
	
	Format(STRING(sTmp), "%T", "ADMIN_MenuVehicle_Give", LANG_SERVER);
	menu.AddItem("give", sTmp);
	
	Format(STRING(sTmp), "%T", "ADMIN_MenuVehicle_Spawn", LANG_SERVER);
	menu.AddItem("spawn", sTmp);
	
	menu.ExitButton = true;
	menu.ExitBackButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Handle_MenuAdmin_Vehicles(Menu menu, MenuAction action, int client, int param)
{	
	if(action == MenuAction_Select)
	{
		char info[32];
		menu.GetItem(param, STRING(info));
		
		if(StrEqual(info, "give"))
			MenuAdmin_VehiclesGive(client);
		else if(StrEqual(info, "spawn"))
			///MenuAdmin_VehiclesSpawn(client);	
			MenuAdmin_VehiclesGive(client);
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if(param == MenuCancel_ExitBack)	
			FakeClientCommand(client, "say !rp_admin");
	}
	else if(action == MenuAction_End)
		delete menu;
}

Menu MenuAdmin_VehiclesGive(int client)
{
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_MenuAdmin_VehiclesGive);

	char sTmp[64];
	menu.SetTitle("%T", "ADMIN_MenuVehicle_Give", LANG_SERVER);
	
	for(int i = 1; i <= MAXCARS; i++)
	{
		if(StrEqual(VehicleKV[i].model, ""))
			continue;
			
		Format(STRING(sTmp), "%i", i);
		menu.AddItem(sTmp, VehicleKV[i].brand);	
	}
	
	menu.ExitButton = true;
	menu.ExitBackButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Handle_MenuAdmin_VehiclesGive(Menu menu, MenuAction action, int client, int param)
{	
	if(action == MenuAction_Select)
	{
		char info[32];
		menu.GetItem(param, STRING(info));
		
		rp_SetClientBool(client, b_DisplayHud, false);
		Menu menu1 = new Menu(Handle_MenuAdmin_VehiclesGiveFinal);
	
		menu1.SetTitle("%T", "Menu_SelectPlayer", LANG_SERVER);
		
		LoopClients(i)
		{
			if(!IsClientValid(i))
				continue;
			
			char sName[64];
			GetClientName(i, STRING(sName));
			
			Format(STRING(info), "%s|%i", info, i);
			menu1.AddItem(info, sName);	
		}
		
		menu1.ExitButton = true;
		menu1.ExitBackButton = true;
		menu1.Display(client, MENU_TIME_FOREVER);
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if(param == MenuCancel_ExitBack)	
			FakeClientCommand(client, "say !rp_admin");
	}
	else if(action == MenuAction_End)
		delete menu;
}

public int Handle_MenuAdmin_VehiclesGiveFinal(Menu menu, MenuAction action, int client, int param)
{	
	if(action == MenuAction_Select)
	{
		char info[32], buffer[2][32];
		menu.GetItem(param, STRING(info));
		ExplodeString(info, "|", buffer, 2, 32);
		
		int id = StringToInt(buffer[0]);
		int target = StringToInt(buffer[1]);
		
		char sBrand[64];
		Format(STRING(sBrand), "%s", VehicleKV[id].brand);
		
		if(IsClientValid(target))
		{
			char sName[64];
			GetClientName(client, STRING(sName));
			
			char sName2[64];
			GetClientName(target, STRING(sName2));
			
			rp_PrintToChat(target, "%T", "Tchat_GiveVehicle_ToClient", LANG_SERVER, sName, sBrand);
			rp_PrintToChat(client, "%T", "Tchat_GiveVehicle_ToAdmin", LANG_SERVER, sBrand, sName2);
			
			char sTmp[256];
			Format(STRING(sTmp), "%N has gived a %s to %N", client, sBrand, target);
			rp_LogToDiscord(sTmp);
			
			char serial[32];
			GenerateVehicleSerial(STRING(serial));
			
			SQL_Request(g_DB, "INSERT IGNORE INTO `rp_vehicles` (`serial`, `playerid`, `carID`, `r`, `g`, `b`, `fuel`, `health`, `km`, `stat`, `stat`, `wheels`) VALUES ('%s', '%i', '%i', '255', '255', '255', '%.2f', '100.0', '0.0', '0', '0');", serial, rp_GetSQLID(target), id, VehicleKV[id].maxfuel);
		}
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if(param == MenuCancel_ExitBack)	
			MenuAdmin_VehiclesGive(client);
	}
	else if(action == MenuAction_End)
		delete menu;
}

public Action Command_Service(int client, int args)
{
	if(client == 0)
	{
		Translation_PrintNoAvailable();
		return Plugin_Handled;
	}
	else if(rp_GetClientInt(client, i_Job) != JOBID)
	{
		Translation_PrintNoAccess(client);
		return Plugin_Handled;
	}
	
	int target = GetClientAimTarget(client, false);
	if(!Vehicle_IsValid(target))
	{
		rp_PrintToChat(client, "Vous devez viser une voiture.");
		return Plugin_Handled;
	}
	else if(Distance(client, target) > 200)
	{
		Translation_PrintTooFar(client);
		return Plugin_Handled;
	}
	
	iServiceVehicle[client] = target;
	MenuService(client);
	
	return Plugin_Handled;
}

Menu MenuService(int client)
{
	rp_SetClientBool(client, b_DisplayHud, false);
	
	Menu menu = new Menu(Handle_MenuService);
	menu.SetTitle("Service Mécanique\n\n----------------------");
	
	char sTmp[128];
	if(Vehicle_IsValid(iServiceVehicle[client]) && IsClientValid(rp_GetVehicleInt(iServiceVehicle[client], car_owner)))
		Format(STRING(sTmp), "Voiture de: %N", rp_GetVehicleInt(iServiceVehicle[client], car_owner));
	else
		Format(STRING(sTmp), "Voiture de: X");	
	menu.AddItem("", sTmp, ITEMDRAW_DISABLED);
	
	menu.AddItem("", " ", ITEMDRAW_SPACER);
	
	menu.AddItem("paint", "Peinture");
	menu.AddItem("jantes", "Jantes");
	menu.AddItem("autres", "Autres");
	
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Handle_MenuService(Menu menu, MenuAction action, int client, int param)
{	
	if(action == MenuAction_Select)
	{
		char info[32];
		menu.GetItem(param, STRING(info));
		
		if(StrEqual(info, "paint"))
			MenuService_Paint(client);
		else if(StrEqual(info, "jantes"))
			MenuService_Jantes(client);
		else if(StrEqual(info, "autres"))
			MenuService_Autres(client);		
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit || param == MenuCancel_ExitBack)
			rp_SetClientBool(client, b_DisplayHud, true);
	}
	else if(action == MenuAction_End)
		delete menu;
}

Menu MenuService_Paint(int client)
{
	rp_SetClientBool(client, b_DisplayHud, false);
	
	Menu menu = new Menu(Handle_MenuServicePaint);
	menu.SetTitle("Service Mécanique\nPeinture\n----------------------");
	
	menu.AddItem("0", "Peinture №0(Défaut)");
	menu.AddItem("1", "Peinture №1(Rouge)");
	menu.AddItem("2", "Peinture №2(Vert)");
	menu.AddItem("3", "Peinture №3(Bleu)");
	menu.AddItem("4", "Peinture №4(Jaune)");
	menu.AddItem("5", "Peinture №5(Noir)");
	menu.AddItem("10", "Peinture №6(Brilliant)");
	menu.AddItem("11", "Peinture №7(Dégradé)");
	menu.AddItem("12", "Peinture №8(Icono)");
	menu.AddItem("6", "Camouflage №1(Militaire)");
	menu.AddItem("7", "Camouflage №2(Volcan)");
	menu.AddItem("8", "Camouflage №3(Vagues)");
	menu.AddItem("9", "Camouflage №4(Fleures)");
	
	menu.ExitButton = true;
	menu.ExitBackButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Handle_MenuServicePaint(Menu menu, MenuAction action, int client, int param)
{	
	if(action == MenuAction_Select)
	{
		char info[32];
		menu.GetItem(param, STRING(info));
		
		int id = StringToInt(info);
		
		if(id <= GetEntitySkinCount(iServiceVehicle[client]))
		{
			SetEntProp(iServiceVehicle[client], Prop_Send, "m_nSkin", id);
			rp_SetVehicleInt(iServiceVehicle[client], car_skinid, id);
		}
		else
			rp_PrintToChat(client, "Peinture/camouflage {lightred}non disponible{default}({darkred}%i{default}/{lightgreen}%i{default}).", id, GetEntitySkinCount(iServiceVehicle[client]));
	
		MenuService_Paint(client);
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if(param == MenuCancel_ExitBack)	
			MenuService(client);
	}
	else if(action == MenuAction_End)
		delete menu;
}

Menu MenuService_Jantes(int client)
{
	rp_SetClientBool(client, b_DisplayHud, false);
	
	Menu menu = new Menu(Handle_MenuServiceJantes);
	menu.SetTitle("Service Mécanique\nJantes\n----------------------");
	
	if(GetEntityStudioHdr(iServiceVehicle[client]).ExistBodyPart("wheels"))
	{
		menu.AddItem("0", "Vossen (0)");
		menu.AddItem("1", "Vossen (1)");
		menu.AddItem("2", "Vossen (2)");
		menu.AddItem("3", "Vorsteiner (0)");
		menu.AddItem("4", "Vorsteiner (1)");
		menu.AddItem("5", "Vorsteiner (2)");
		menu.AddItem("6", "Vorsteiner (3)");
		menu.AddItem("7", "Vorsteiner (4)");
	}
	else
		menu.AddItem("", "Aucune jantes disponibles", ITEMDRAW_DISABLED);

	menu.ExitButton = true;
	menu.ExitBackButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Handle_MenuServiceJantes(Menu menu, MenuAction action, int client, int param)
{	
	if(action == MenuAction_Select)
	{
		char info[32];
		menu.GetItem(param, STRING(info));
		
		int id = StringToInt(info);
		
		SetBodyGroup(iServiceVehicle[client], GetEntityStudioHdr(iServiceVehicle[client]).FindBodyPart("wheels"), id);
	
		MenuService_Jantes(client);
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if(param == MenuCancel_ExitBack)	
			MenuService(client);
	}
	else if(action == MenuAction_End)
		delete menu;
}

Menu MenuService_Autres(int client)
{
	rp_SetClientBool(client, b_DisplayHud, false);
	
	Menu menu = new Menu(Handle_MenuServiceAutres);
	menu.SetTitle("Service Mécanique\nAutres\n----------------------");
	
	char sTmp[64];
	int count;
	for (int i = 0; i < g_aBodyData.Length; i++) 
	{
		g_aBodyData.GetString(i, STRING(sTmp));
		
		char sBuffer[3][32];
		ExplodeString(sTmp, "|", sBuffer, 3, 32);
		
		if(StringToInt(sBuffer[2]) == rp_GetVehicleInt(iServiceVehicle[client], car_id))
		{
			count++;
			Format(sBuffer[0], 32, "%T", sBuffer[0], LANG_SERVER);
			menu.AddItem(sTmp, sBuffer[0]);
		}	
	}
	
	if(count == 0)
		menu.AddItem("", "Aucune pièces disponibles", ITEMDRAW_DISABLED);
	
	menu.ExitButton = true;
	menu.ExitBackButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Handle_MenuServiceAutres(Menu menu, MenuAction action, int client, int param)
{	
	if(action == MenuAction_Select)
	{
		char info[32];
		menu.GetItem(param, STRING(info));
		
		Format(sSelectedBodyGroup[client], sizeof(sSelectedBodyGroup[]), "%s", info);
		MenuService_AutresValues(client);
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if(param == MenuCancel_ExitBack)
			MenuService(client);
	}
	else if(action == MenuAction_End)
		delete menu;
}

Menu MenuService_AutresValues(int client)
{
	rp_SetClientBool(client, b_DisplayHud, false);
	
	Menu menu = new Menu(Handle_MenuServiceAutresValues);
	
	char sBuffer[3][32];
	ExplodeString(sSelectedBodyGroup[client], "|", sBuffer, 3, 32);
	
	menu.SetTitle("Service Mécanique\nAutres(%s)\n----------------------", sBuffer[0]);
	
	char sTmp[64];
	for(int j = 0; j <= StringToInt(sBuffer[1]); j++)
	{
		IntToString(j, STRING(sTmp));
		menu.AddItem(sTmp, sTmp);
	}
	
	menu.ExitButton = true;
	menu.ExitBackButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Handle_MenuServiceAutresValues(Menu menu, MenuAction action, int client, int param)
{	
	if(action == MenuAction_Select)
	{
		char info[32];
		menu.GetItem(param, STRING(info));
		
		char sBuffer[3][32];
		ExplodeString(sSelectedBodyGroup[client], "|", sBuffer, 3, 32);
		
		SetBodyGroup(iServiceVehicle[client], GetEntityStudioHdr(iServiceVehicle[client]).FindBodyPart(sBuffer[0]), StringToInt(info));
		MenuService_AutresValues(client);
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if(param == MenuCancel_ExitBack)
			MenuService_Autres(client);
	}
	else if(action == MenuAction_End)
		delete menu;
}

public void CH_PassFilter(int ent1, int ent2, CollisionHookResult &result)
{
	// Find the driveable vehicle entity index and validate the result.
	int vehicle_entity = Vehicle_IsValid(ent1) ? ent1 : Vehicle_IsValid(ent2) ? ent2 : 0;
	if (!vehicle_entity)
	{
		return;
	}
	
	// Find the client index and validate the result.
	int client = vehicle_entity == ent1 ? ent2 : ent1;
	if (!(1 <= client <= MaxClients) || GetClientVehicle(client) != -1/* Make sure the client isn't driving nor inside a vehicle. */)
	{
		return;
	}
	
	// Don't pass if the client is stuck and can't move.
	if (!IsEntityStuck(client))
	{
		return;
	}
	
	int speed = GetEntProp(vehicle_entity, Prop_Data, "m_nSpeed");
	if (speed > cvar.runover_speed.IntValue)
	{
		/*int passengers[LAST_SHARED_VEHICLE_ROLE];
		Vehicles_GetVehiclePassengers(vehicle_entity, passengers);
		
		if (GetClientHealth(client) > 0)
		{
			SDKHooks_TakeDamage(client, vehicle_entity, passengers[VEHICLE_ROLE_DRIVER], float(speed / cvar.runover_speed.IntValue));
		}*/
		
		SDKHooks_TakeDamage(client, vehicle_entity, Vehicle_GetDriver(vehicle_entity), float(speed / cvar.runover_speed.IntValue));
	}
	
	result = Result_Block;
}

Action Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	int attacker_userid = event.GetInt("attacker"), attacker = GetClientOfUserId(attacker_userid);
	
	if (1 <= attacker <= MaxClients && Vehicle_IsValid(attacker) != -1)
	{
		char weapon[32];
		cvar.runover_icon.GetString(weapon, sizeof(weapon));
		
		event.SetString("weapon", weapon);
	}
	
	return Plugin_Continue;
}

bool IsEntityStuck(int entity)
{
	// Initialize the entity's mins, maxs and position vectors
	float ent_mins[3], ent_maxs[3], pos[3];
	
	GetEntPropVector(entity, Prop_Send, "m_vecMins", ent_mins);
	GetEntPropVector(entity, Prop_Send, "m_vecMaxs", ent_maxs);
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
	
	ScaleVector(ent_mins, 0.9);
	ScaleVector(ent_maxs, 0.9);
	
	// Create a global trace hull that will ensure the entity will not stuck inside the world/another entity
	TR_TraceHullFilter(pos, pos, ent_mins, ent_maxs, MASK_PLAYERSOLID, Filter_ExcludePlayers);
	
	return TR_DidHit();
}

bool Filter_ExcludePlayers(int entity, int contentsMask)
{
	return !(1 <= entity <= MaxClients);
} 

public Action RP_OnClientPress_CTRL(int client)
{
	if(GetClientVehicle(client) != -1)
		FakeClientCommand(client, "say !3rd");
}

void GenerateVehicleSerial(char[] buffer, int maxlen)
{
	char sSerial[32];
	char sNumbers[5];
	bool exist = false;
	
	for(int i = 1; i <= 5;i++)
	{
		Format(STRING(sNumbers), "%s%i", sNumbers, GetRandomInt(0, 9));
	}
	Format(STRING(sSerial), "RP - %s", sNumbers);
	
	char sQuery[1024];
	Format(STRING(sQuery), "SELECT * FROM `rp_vehicles` WHERE `serial` = '%s'", sSerial);	 
	DBResultSet Results = SQL_Query(g_DB, sQuery);
	
	if(Results.FetchRow())
	{
		char sTmp[32];
		GenerateVehicleSerial(STRING(sTmp));
		exist = true;
	}
	delete Results;
	
	if(!exist)
		Format(buffer, maxlen, "%s", sSerial);
}