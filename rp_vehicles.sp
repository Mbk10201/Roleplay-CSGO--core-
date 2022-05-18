/*
*   Roleplay CS:GO de Benito est mis à disposition selon les termes de la licence Creative Commons Attribution .
* - Pas d’Utilisation Commerciale 
* - Partage dans les Mêmes Conditions 4.0 International.
*
*   Fondé(e) sur une œuvre à https://github.com/Mbk10201/Roleplay-CS-GO
*   Les autorisations au-delà du champ de cette licence peuvent être obtenues à https://steamcommunity.com/id/xsuprax/.
*
*   Merci de respecter le travail fourni par le ou les auteurs 
*   benitalpa1020@gmail.com
*/

/***************************************************************************************

							C O M P I L E  -  O P T I O N S

***************************************************************************************/
#pragma semicolon 1
#pragma newdecls required

#define MYSQL_TABLE "rp_vehicles"

/***************************************************************************************

										H E A D E R

***************************************************************************************/
#include <roleplay_csgo.inc>
#include <regex>
#include <vehicles>

// MySQL database handle.
Database g_Database;

enum struct SpawnSpot
{
	// Spawn position (origin) vector.
	float position[3];
	
	// Spawn angles vector.
	float angles[3];
	
	//====================================//
	
	// Retrieves whether this vehicle spawn spot is currently occupied.
	// True if taken, false otherwise.
	bool IsTaken()
	{
		static int m_vecOriginOffset;
		if (!m_vecOriginOffset)
		{
			m_vecOriginOffset = FindSendPropInfo("CBaseEntity", "m_vecOrigin");
		}
		
		ArrayList active_vehicles = Vehicles_GetActiveVehicles();
		
		float vehicle_position[3];
		for (int current_active_vehicle, vehicle_entity; current_active_vehicle < active_vehicles.Length; current_active_vehicle++)
		{
			vehicle_entity = active_vehicles.Get(current_active_vehicle);
			
			GetEntDataVector(vehicle_entity, m_vecOriginOffset, vehicle_position);
			
			if (GetVectorDistance(this.position, vehicle_position) < 250.0)
			{
				delete active_vehicles;
				return true;
			}
		}
		
		delete active_vehicles;
		return false;
	}
}


// Represents a database player vehicle.
enum struct DBVehicle
{
	// Vehicle type identifier.
	char identifier[VEHICLE_MAX_IDENTIFIER_LENGTH];
	
	// Vehicle database row id	
	int id;
	
	// Vehicle health state.
	int health;
	
	// Vehicle fuel.
	float fuel;
	
	// Vehicle distance.
	float distance;
	
	// RGBA Color.
	int color[4];
	
	// Is vehicle
	int towed;
	
	// Entity skin index.
	int skin;
	
	// Entity body group.
	int body;
	
	//====================================//
	
	void Init(VehicleType vehicle_type)
	{
		this.identifier = vehicle_type.identifier;
		this.health = vehicle_type.base_health;
		this.fuel = BASE_VEHICLES_FUEL / 4.0;
		this.color = { 255, 255, 255, 255 };
	}
	
	void RawColorToRGBA(const char[] raw_color)
	{
		// Vehicle colors format in db: "xxx xxx xxx xxx"
		
		char exploded_colors[4][4];
		ExplodeString(raw_color, " ", exploded_colors, sizeof(exploded_colors), sizeof(exploded_colors[]));
		
		for (int current_color; current_color < sizeof(exploded_colors); current_color++)
		{
			this.color[current_color] = StringToInt(exploded_colors[current_color]);
		}
	}
	
	void RGBAToRawColor(char[] buffer, int len)
	{
		Format(buffer, len, "%d %d %d %d", this.color[0], this.color[1], this.color[2], this.color[3]);
	}
}

// Stores all the data when a passengers gets interrupted by getting teleported to an admin room.
enum struct AdminRoomInterruption
{
	// Vehicle entity reference.
	int vehicle_reference;
	
	// Old passenger role.
	PassengerRole passenger_role;
	
	// Vehicle lock state before teleportation.
	bool is_vehicle_locked;
	
	//====================================//
	
	void Init()
	{
		this.vehicle_reference = INVALID_ENT_REFERENCE;
		this.passenger_role = view_as<PassengerRole>(0);
		this.is_vehicle_locked = false;
	}
}

enum struct Player
{
	// Client value of 'GetSteamAccountID()'
	int playerid;
	
	// Player userid.
	int userid;
	
	// 'DBVehicle' contents.
	ArrayList personal_vehicles;
	
	// Vehicles npc entity index.
	int vehicles_npc;
	
	// Stores all the related data to an admin room interruption.
	AdminRoomInterruption admin_room_interruption;
	
	//====================================//
	
	void Init(int client)
	{
		if (!(this.playerid = rp_GetSQLID(client)))
		{
			return;
		}
		
		this.userid = GetClientUserId(client);
		
		this.personal_vehicles = new ArrayList(sizeof(DBVehicle));
		
		this.admin_room_interruption.Init();
		
		this.FetchDBVehicles();
	}
	
	void Close()
	{
		this.playerid = 0;
		this.userid = 0;
		delete this.personal_vehicles;
		this.vehicles_npc = 0;
	}
	
	//============[ DB Help Functions ]============//
	
	void FetchDBVehicles()
	{
		char query[128];
		Format(query, sizeof(query), "SELECT * FROM `%s` WHERE `playerid` = '%d'", MYSQL_TABLE, 1);
		#if DEBUG
			PrintToServer(query);
		#endif
		g_Database.Query(SQL_FetchVehicles, query, this.userid);
	}
	
	void InsertDBVehicle(DBVehicle db_vehicle)
	{
		char query[256], raw_color[16];
		
		db_vehicle.RGBAToRawColor(raw_color, sizeof(raw_color));
		
		g_Database.Format(query, sizeof(query), "INSERT INTO `%s` (`playerid`, `identifier`, `health`, `fuel`, `color`, `distance`, `towed`, `skin`, `body`) VALUES (%d, '%s', %d, %f, '%s', %f, %d, %d, %d)", 
			MYSQL_TABLE,
			this.playerid,
			db_vehicle.identifier,
			db_vehicle.health,
			db_vehicle.fuel,
			raw_color,
			db_vehicle.distance,
			db_vehicle.towed,
			db_vehicle.skin,
			db_vehicle.body
		);
		SQL_Request(g_Database, query);
	}
	
	void UpdateDBVehicle(int index)
	{
		DBVehicle db_vehicle;
		this.personal_vehicles.GetArray(index, db_vehicle);
		
		char query[256], raw_color[16];
		
		db_vehicle.RGBAToRawColor(raw_color, sizeof(raw_color));
		
		g_Database.Format(query, sizeof(query), "UPDATE `%s` SET `health` = %d, `fuel` = %f, `color` = '%s', `distance` = %d, `towed` = %d, `skin` = %d, `body` = %d WHERE `playerid` = %d AND `id` = '%d'", 
			MYSQL_TABLE,
			db_vehicle.health, 
			db_vehicle.fuel, 
			raw_color, 
			db_vehicle.skin, 
			db_vehicle.body, 
			this.playerid, 
			db_vehicle.id
		);
		SQL_Request(g_Database, query);
	}
	
	void RemoveDBVehicle(char[] identifier)
	{
		char query[256];
		g_Database.Format(query, sizeof(query), "DELETE FROM `%s` WHERE `playerid` = %d AND `identifier` = '%s'", MYSQL_TABLE, this.playerid, identifier);
		g_Database.Query(SQL_CheckForErrors, query);
	}
	
	void Tow(int client, int client_tug)
	{
		int entity = Vehicles_GetClientVehicleEntity(client);
		if (entity != -1)
			Vehicles_DestroyVehicle(entity);
		
		rp_PrintToChat(client, "Votre vehicule a été remorquée par {lightblue}%N", client_tug);
	}
}
Player g_Players[MAXPLAYERS + 1];

enum struct Cvars {
	ConVar destroy_charge_percent;
}
Cvars cvar;

ArrayList g_Categories;

/***************************************************************************************

							P L U G I N  -  I N F O

***************************************************************************************/
public Plugin myinfo = 
{
	name = "Roleplay - Vehicles", 
	author = "MBK", 
	description = "Vehicle management for roleplay", 
	version = "1.0", 
	url = "https://github.com/Mbk10201"
};

/***************************************************************************************

									 PLUGIN START

***************************************************************************************/
public void OnPluginStart()
{
	// Load global translation file
	LoadTranslation();
	
	// Register commands
	RegConsoleCmd("sm_garage", Command_Garage);
	
	// Register Convars
	cvar.destroy_charge_percent = CreateConVar("destroy_charge_percent", "0.5", "Percentage to calculate from the destroyed vehicle price value and to charge from the attacker.", .hasMin = true, .hasMax = true, .max = 100.0);
	AutoExecConfig(true, "rp_vehicles", "roleplay");
}

// Server events.
public void Vehicles_OnConfigLoaded()
{
	// Initialize the vehicles categories ArrayList.
	g_Categories = Vehicles_GetCategories();
}

/***************************************************************************************

									DATABASE START

***************************************************************************************/
public void RP_OnSQLInit(Database db, Transaction transaction)
{
	g_Database = db;
	
	char sBuffer[MAX_BUFFER_LENGTH + 1];
	
	Format(STRING(sBuffer), "CREATE TABLE IF NOT EXISTS `rp_vehicles_list` ( \
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
		
	Format(STRING(sBuffer), "CREATE TABLE IF NOT EXISTS `%s` ( \
	  `id` int(20) NOT NULL AUTO_INCREMENT, \
	  `playerid` int(20) NOT NULL, \
	  `identifier` varchar(32) NOT NULL, \
	  `health` int(3) NOT NULL, \
	  `fuel` float NOT NULL, \
	  `color` varchar(16) NOT NULL, \
	  `distance` float NOT NULL, \
	  `towed` int(1) NOT NULL, \
	  `skin` int(2) NOT NULL, \
	  `body` int(10) NOT NULL, \
	  PRIMARY KEY (`id`), \
	  FOREIGN KEY (`playerid`) REFERENCES `rp_players` (`id`) ON DELETE CASCADE ON UPDATE CASCADE \
	  )ENGINE = InnoDB DEFAULT CHARSET = utf8 COLLATE = utf8_bin;", MYSQL_TABLE);
	#if DEBUG
		PrintToServer(sBuffer);
	#endif
	transaction.AddQuery(sBuffer);
	
	// Loop through all the online clients, for late plugin load
	/*for (int current_client = 1; current_client <= MaxClients; current_client++)
	{
		if (IsClientInGame(current_client))
		{
			OnClientPutInServer(current_client);
		}
	}*/
}

/***************************************************************************************

								    CLIENTS INIT

***************************************************************************************/

public void OnClientPutInServer(int client)
{
	g_Players[client].Init(client);
}

public void OnClientDisconnect(int client)
{
	int entity = Vehicles_GetClientVehicleEntity(client);
	if (entity != -1)
	{
		Vehicles_DestroyVehicle(entity);
	}
	
	g_Players[client].Close();
}

/***************************************************************************************

									CALLBACK'S

***************************************************************************************/
void SQL_FetchVehicles(Database db, DBResultSet results, const char[] error, int userid)
{
	// An error has occurred
	if (!db || !results || error[0])
	{
		ThrowError("Databse error, %s", error);
		return;
	}
	
	// Initialize the client index by the given userid, and perform validation.
	int client = GetClientOfUserId(userid);
	if (!client)
	{
		return;
	}
	
	// Prepare loop variables.
	DBVehicle new_db_vehicle;
	VehicleType dummy;
	char raw_color[16];
	
	while (results.FetchRow())
	{
		results.FetchIntByName("id", new_db_vehicle.id);
		
		results.FetchStringByName("identifier", new_db_vehicle.identifier, sizeof(DBVehicle::identifier));
		
		if (!Vehicles_GetVehicleTypeByIdentifier(new_db_vehicle.identifier, dummy))
		{
			continue;
		}
		
		results.FetchIntByName("health", new_db_vehicle.health);
		results.FetchFloatByName("fuel", new_db_vehicle.fuel);
		results.FetchFloatByName("distance", new_db_vehicle.distance);
		
		results.FetchStringByName("color", STRING(raw_color));
		
		new_db_vehicle.RawColorToRGBA(raw_color);
		
		results.FetchIntByName("towed", new_db_vehicle.towed);
		results.FetchIntByName("skin", new_db_vehicle.skin);
		results.FetchIntByName("body", new_db_vehicle.body);
		
		g_Players[client].personal_vehicles.PushArray(new_db_vehicle);
	}
}

public void Vehicles_OnVehicleDestroyed(int entity, const char[] identifier, int owner, int health, float fuel)
{
	// Skip if the vehicle has no owner.
	if (owner == INVALID_VEHICLE_OWNER)
	{
		return;
	}
	
	// Update 'DBVehicle' data
	int index = g_Players[owner].personal_vehicles.FindString(identifier);
	if (index == -1)
	{
		return;
	}
	
	DBVehicle db_vehicle;
	g_Players[owner].personal_vehicles.GetArray(index, db_vehicle);
	
	if (!(db_vehicle.health = health))
	{
		VehicleType vehicle_type;
		if (Vehicles_GetVehicleTypeByIdentifier(identifier, vehicle_type))
		{
			db_vehicle.health = vehicle_type.base_health;
		}
	}
	
	db_vehicle.fuel = fuel;
	
	GetEntityRenderColor(entity, db_vehicle.color[0], db_vehicle.color[1], db_vehicle.color[2], db_vehicle.color[3]);
	db_vehicle.skin = GetEntitySkin(entity);
	db_vehicle.body = GetEntityBody(entity);
	
	g_Players[owner].personal_vehicles.SetArray(index, db_vehicle);
	
	// Update in DB
	g_Players[owner].UpdateDBVehicle(index);
}

public Action Vehicles_OnVehicleTakeDamage(int entity, int attacker, int victim, float &damage)
{
	if (!(1 <= attacker <= MaxClients) || victim || attacker == Vehicles_GetVehicleOwner(entity) || damage < float(Vehicles_GetVehicleHealth(entity)))
	{
		return Plugin_Continue;
	}
	
	VehicleType vehicle_type;
	if (!Vehicles_GetVehicleTypeByEntity(entity, vehicle_type))
	{
		return Plugin_Continue;
	}
	
	int client_cash = rp_GetClientInt(attacker, i_Bank), charge = RoundToFloor(float(vehicle_type.price_value) * cvar.destroy_charge_percent.FloatValue / 100.0);
	
	// Don't overflow the client cash.
	if (charge > client_cash)
	{
		charge = client_cash;
	}
	
	rp_SetClientInt(attacker, i_Bank, client_cash - charge);
	
	rp_PrintToChat(attacker, "Vous avez été facturée de {lightred}%d{default}$ pour couvrir l'assurance.", charge);
	
	return Plugin_Continue;
}

public Action Vehicles_OnVehicleCollision(int entity, int hit_entity, float &damage, float &passengers_damage)
{
	if (!hit_entity || !Vehicles_IsEntityDriveable(hit_entity))
	{
		return Plugin_Continue;
	}
	
	int vehicle_health = Vehicles_GetVehicleHealth(entity);
	if (damage < float(vehicle_health) || !vehicle_health)
	{
		return Plugin_Continue;
	}
	
	int passengers[LAST_SHARED_VEHICLE_ROLE];
	Vehicles_GetVehiclePassengers(hit_entity, passengers);
	
	int driver = passengers[VEHICLE_ROLE_DRIVER];
	
	if (!driver || driver == Vehicles_GetVehicleOwner(entity))
	{
		return Plugin_Continue;
	}
	
	VehicleType vehicle_type;
	if (!Vehicles_GetVehicleTypeByEntity(entity, vehicle_type))
	{
		return Plugin_Continue;
	}
	
	int client_cash = rp_GetClientInt(driver, i_Money), charge = RoundToFloor(float(vehicle_type.price_value) * cvar.destroy_charge_percent.FloatValue / 100.0);
	
	// Don't overflow the client cash.
	if (charge > client_cash)
	{
		charge = client_cash;
	}
	
	rp_SetClientInt(driver, i_Money, client_cash - charge);
	
	rp_PrintToChat(driver, "Vous avez été facturée de {lightred}%d{default}$ pour couvrir l'assurance.", charge);
	
	return Plugin_Continue;
}

public Action Command_Garage(int client, int args)
{
	Menu_Vehicles(client);
	
	return Plugin_Handled;
}

void Menu_Vehicles(int client)
{
	PrintToServer("g_Players[client].personal_vehicles = %d", g_Players[client].personal_vehicles.Length);
	
	if(rp_GetHudType(client) == HUD_PANEL || rp_GetHudType(client) == HUD_MSG)
	{
		rp_SetClientBool(client, b_DisplayHud, false);
	}
	
	Menu menu = new Menu(Handler_PersonalVehicles);
	menu.SetTitle("Roleplay - Garage\n");
	
	if(g_Players[client].personal_vehicles.Length == 0)
		menu.AddItem("", "Vous n'avez aucun vehicule", ITEMDRAW_DISABLED);
	else
	{
		char sTmp[32];
		Format(STRING(sTmp), "Emplacement [%d]", g_Players[client].personal_vehicles.Length);
		menu.AddItem("", sTmp, ITEMDRAW_DISABLED);
		
		char identifier[VEHICLE_MAX_IDENTIFIER_LENGTH];
		Category category;
		
		for (int current_category; current_category < g_Categories.Length; current_category++)
		{
			g_Categories.GetArray(current_category, category);
			
			for (int current_pv; current_pv < g_Players[client].personal_vehicles.Length; current_pv++)
			{
				g_Players[client].personal_vehicles.GetString(current_pv, STRING(identifier));
				if (category.vehicle_types.FindString(identifier) != -1)
				{
					menu.AddItem(category.name, category.name);
					break;
				}
			}
		}
	}
	
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

int Handler_PersonalVehicles(Menu menu, MenuAction action, int client, int param)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			/*if (CheckDistance(client, g_Players[client].vehicles_npc) > MAX_NPC_DISTANCE)
			{
				PrintToChat(client, "%s You are too far away from this NPC.", PREFIX);
				return 0;
			}*/
			
			char category_name[CATEGORY_MAX_NAME_LENGTH];
			menu.GetItem(param, category_name, sizeof(category_name));
			
			// Find the category index by the parsed category name.
			int category_index = g_Categories.FindString(category_name);
			if (category_index == -1)
			{
				PrintToChat(client, "%s Category couldn't be found, please try again later.", VEHICLES_PREFIX);
				Menu_Vehicles(client);
				return 0;
			}
			
			Menus_SubPersonalVehicles(client, category_index);
		}
		case MenuAction_Cancel:
		{
			if(param == MenuCancel_Exit)
			{
				if(rp_GetClientBool(client, b_IsNew))
					rp_OpenTutorial(client);
				else	
					rp_SetClientBool(client, b_DisplayHud, true);
			}
		}
		case MenuAction_End:
		{
			// Don't leak memory.
			delete menu;
		}
	}
	
	return 0;
}

void Menus_SubPersonalVehicles(int client, int categoryId)
{
	char category_name[CATEGORY_MAX_NAME_LENGTH];
	g_Categories.GetString(categoryId, category_name, sizeof(category_name));
	
	Menu menu = new Menu(Handler_SubPersonalVehicles);
	menu.SetTitle("Vehicles - %s's Personal Vehicles\n ", category_name);
	
	ArrayList vehicle_types = Vehicles_GetVehicleTypes(categoryId);
	
	VehicleType vehicle_type;
	for (int current_vt; current_vt < vehicle_types.Length; current_vt++)
	{
		vehicle_types.GetArray(current_vt, vehicle_type);
		if (g_Players[client].personal_vehicles.FindString(vehicle_type.identifier) != -1)
		{
			menu.AddItem(vehicle_type.identifier, vehicle_type.name);
		}
	}
	
	delete vehicle_types;
	
	menu.ExitButton = true;
	menu.ExitBackButton = true;
	FixMenuGap(menu);
	
	menu.Display(client, MENU_TIME_FOREVER);
}

int Handler_SubPersonalVehicles(Menu menu, MenuAction action, int client, int param)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			
			/*if (CheckDistance(client, g_Players[client].vehicles_npc) > MAX_NPC_DISTANCE)
			{
				PrintToChat(client, "%s You are too far away from this NPC.", PREFIX);
				return 0;
			}*/
			
			/*if (!IsPlayerAlive(client))
			{
				PrintToChat(client, "%s In order to spawn a personal vehicle you must be \x06alive\x01!", PREFIX);
				return 0;
			}*/
			
			char identifier[VEHICLE_MAX_IDENTIFIER_LENGTH];
			menu.GetItem(param, STRING(identifier));
			
			// Find the vehicle type data by the parsed identifier.
			VehicleType vehicle_type;
			if (!Vehicles_GetVehicleTypeByIdentifier(identifier, vehicle_type))
			{
				PrintToChat(client, "%s Vehicle type couldn't be found, please try again later.", VEHICLES_PREFIX);
				Menu_Vehicles(client);
				return 0;
			}
			
			/*if (GetClientTakenVehicle(client) != -1)
			{
				ClientCommand(client, "play error.wav");
				PrintToChat(client, "%s You have to return your current vehicle back to Storage in order to take out another one.", VEHICLES_PREFIX);
				Menu_Vehicles(client);
				return 0;
			}*/
			
			// Make sure the player still owns this vehicle.
			int db_vehicle_index = g_Players[client].personal_vehicles.FindString(identifier);
			if (db_vehicle_index == -1)
			{
				PrintToChat(client, "%s Vehicle type couldn't be found, please try again later.", VEHICLES_PREFIX);
				Menu_Vehicles(client);
				return 0;
			}
			
			DBVehicle db_vehicle;
			g_Players[client].personal_vehicles.GetArray(db_vehicle_index, db_vehicle);
			
			// Get valid spawn spot.
			/*SpawnSpot spawn_spot;
			ArrayList valid_spawn_spots = g_SpawnSpots.Clone();
			
			while (valid_spawn_spots == valid_spawn_spots)
			{
				int index = GetRandomInt(0, valid_spawn_spots.Length - 1);
				valid_spawn_spots.GetArray(index, spawn_spot);
				
				if (!spawn_spot.IsTaken())
				{
					delete valid_spawn_spots;
					break;
				}
				else
				{
					valid_spawn_spots.Erase(index);
				}
				
				if (!valid_spawn_spots.Length)
				{
					PrintToChat(client, "%s Couldn't find any available vehicle spawn spots, please try again later.", VEHICLES_PREFIX);
					delete valid_spawn_spots;
					return 0;
				}
			}*/
			
			// Get spawn vectors by the client location.
			float position[3], angles[3];
			GetClientAbsOrigin(client, position);
			GetClientEyeAngles(client, angles);
			
			// Spawn the vehicle! (and check for any errors)
			int entity = Vehicles_SpawnVehicle(vehicle_type.identifier, position, angles, client);
			if (entity == -1)
			{
				PrintToChat(client, "%s An error has occured while trying to spawn the vehicle, please try again later.", VEHICLES_PREFIX);
				return 0;
			}
			
			Vehicles_SetVehicleHealth(entity, db_vehicle.health);
			Vehicles_SetVehicleFuel(entity, db_vehicle.fuel);
			SetEntityRenderColor(entity, db_vehicle.color[0], db_vehicle.color[1], db_vehicle.color[2], db_vehicle.color[3]);
			SetEntitySkin(entity, db_vehicle.skin);
			SetBodyGroups(entity, db_vehicle.body);
			
			Vehicles_GetInPassenger(entity, client, VEHICLE_ROLE_DRIVER);
			
			// Notify the client.
			PrintToChat(client, "%s Successfully \x06spawned\x01 vehicle '%s', drive safely!", VEHICLES_PREFIX, vehicle_type.name);
		}
		case MenuAction_Cancel:
		{
			if (param == MenuCancel_ExitBack)
			{
				Menu_Vehicles(client);
			}
			else if(param == MenuCancel_Exit)
			{
				if(rp_GetClientBool(client, b_IsNew))
					rp_OpenTutorial(client);
				else	
					rp_SetClientBool(client, b_DisplayHud, true);
			}
		}
		case MenuAction_End:
		{
			// Don't leak memory.
			delete menu;
		}
	}
	
	return 0;
}

//================================[ Key Values Configuration ]================================//

public void RP_OnClientPress_R(int client)
{
	if(Vehicles_GetClientPassengerRole(client) == VEHICLE_ROLE_DRIVER)
	{
		int entity = Vehicles_GetClientVehicleEntity(client);
		Vehicles_SetEngineState(entity, !Vehicles_GetEngineState(entity));
	}
}