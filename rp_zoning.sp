/*
*   Roleplay CS:GO de Benito est mis à disposition selon les termes de la licence Creative Commons Attribution .
* - Pas d’Utilisation Commerciale 
* - Partage dans les Mêmes Conditions 4.0 International.
*
*   Fondé(e) sur une œuvre à https://github.com/Mbk10201/Roleplay-CS-GO
*   Les autorisations au-delà du champ de cette licence peuvent être obtenues à https://steamcommunity.com/id/xsuprax/.
*
*   Merci de respecter le travail fourni par le ou les auteurs 
*   https://enemy-down.eu - benitalpa1020@gmail.com
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

char 
	steamID[MAXPLAYERS + 1][32];

enum struct Data_Forward {
	GlobalForward OnZoneCreated;
}	
Data_Forward Forward;

int g_BeamSprite;
int g_HaloSprite;
int enabled_zones;

Handle Timer_Zones[MAXPLAYERS + 1] = { null, ... };

enum struct ZoneData {
	char name[64];
	char min_x[8];
	char min_y[8];
	char min_z[8];
	char max_x[8];
	char max_y[8];
	char max_z[8];
	char flag[8];
	char bit[8];
	char extra[8];
}
ZoneData RoleplayZone[MAXZONES+1];

/***************************************************************************************

							P L U G I N  -  I N F O

***************************************************************************************/
public Plugin myinfo = 
{
	name = "Roleplay - Zoning", 
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
	LoadTranslation();
	LoadTranslations("rp_zones.phrases.txt");
	PrintToServer("[REQUIREMENT] ZONING ✓");	
	
	/*------------------------------------HOOKS------------------------------------*/
	HookEvent("round_start", Event_Round);
	HookEvent("teamplay_round_start", Event_Round);
	/*-----------------------------------------------------------------------------*/
	
	/*----------------------------------Commands-----------------------------------*/
	#if DEBUG
		//RegConsoleCmd("rp_zones", Command_Zones);
	#endif	
	RegConsoleCmd("gettriggerpos", Message_GetTriggerPos);
	RegConsoleCmd("getzone", Message_GetZone);
	RegConsoleCmd("savezones", Message_SaveZones);
	/*-----------------------------------------------------------------------------*/	
	
	LoopClients(i)
	{
		if(!IsClientValid(i))
			continue;
		OnClientPutInServer(i);
	}
}	

public void OnMapStart()
{
	g_BeamSprite = PrecacheModel("sprites/laserbeam.vmt");
	g_HaloSprite = PrecacheModel("materials/sprites/halo.vmt");
	LoadZones();
	RefreshZones();
}

public void RP_OnClientFirstSpawn(int client)
{
	if(FindConVar("rp_zonetype").IntValue == 1 || FindConVar("rp_zonetype").IntValue == 2)
	{
		LoopClients(i)
		{
			if(!IsClientValid(i))
				continue;
				
			Timer_Zones[i] = CreateTimer(0.5, Timer_CheckZones, i, TIMER_REPEAT);
		}
	}
}

void RefreshZones()
{
	if(FindConVar("rp_zonetype").IntValue == 0 || FindConVar("rp_zonetype").IntValue == 2)
	{
		char entClass[64], entName[64];
		LoopEntities(i)
		{			
			if (IsValidEntity(i))
			{
				Entity_GetClassName(i, STRING(entClass));
				GetEntPropString(i, Prop_Data, "m_iName", STRING(entName));
				
				char buffer[3][128];
				ExplodeString(entName, "|", buffer, 3, 128);
			
				if(StrContains(entClass, "trigger_multiple") != -1 && StrContains(buffer[0], "zone_", false) != -1 && StrEqual(buffer[2], "map"))
				{
					//HookSingleEntityOutput(i, "OnStartTouch", OnStartTouch);
					SDKHookEx(i, SDKHook_Touch, Hook_OnTouch);
					SDKHookEx(i, SDKHook_EndTouch, Hook_OnEndTouch);
				}
				
				#if !DEBUG
					if(StrContains(entClass, "trigger_multiple") != -1 && StrContains(buffer[0], "zone_", false) != -1 && !StrEqual(buffer[2], "map"))
						RemoveEntity(i);
				#endif		
			}
		} 
	}
}

public APLRes AskPluginLoad2(Handle plugin, bool late, char[] error, int err_max)
{
	RegPluginLibrary("rp_zoning");
	
	/*------------------------------------FORWADS------------------------------------*/
	Forward.OnZoneCreated = new GlobalForward("RP_OnZoneCreated", ET_Event, Param_String);
	
	CreateNative("rp_GetZoneData", Native_GetZoneData);
	CreateNative("rp_SetZoneData", Native_SetZoneData);
	
	return APLRes_Success;
}

public int Native_GetZoneData(Handle plugin, int numParams) 
{
	int zoneID = GetNativeCell(1);
	int variable = GetNativeCell(2);
	int maxlen = GetNativeCell(4) + 1;
	
	switch(variable)
	{
		case zone_name:SetNativeString(3, RoleplayZone[zoneID].name, maxlen);
		case zone_min_x:SetNativeString(3, RoleplayZone[zoneID].min_x, maxlen);
		case zone_min_y:SetNativeString(3, RoleplayZone[zoneID].min_y, maxlen);
		case zone_min_z:SetNativeString(3, RoleplayZone[zoneID].min_z, maxlen);
		case zone_max_x:SetNativeString(3, RoleplayZone[zoneID].max_x, maxlen);
		case zone_max_y:SetNativeString(3, RoleplayZone[zoneID].max_y, maxlen);
		case zone_max_z:SetNativeString(3, RoleplayZone[zoneID].max_z, maxlen);
		case zone_flag:SetNativeString(3, RoleplayZone[zoneID].flag, maxlen);
		case zone_bit:SetNativeString(3, RoleplayZone[zoneID].bit, maxlen);
		case zone_extra:SetNativeString(3, RoleplayZone[zoneID].extra, maxlen);
	}
	
	//SetNativeString(3, type_zone[zoneID][variable], maxlen);
	return -1;
}

public int Native_SetZoneData(Handle plugin, int numParams) 
{
	int zoneID = GetNativeCell(1);
	int variable = GetNativeCell(2);
	int maxlen = GetNativeCell(4) + 1;
	
	switch(variable)
	{
		case zone_name:GetNativeString(3, RoleplayZone[zoneID].name, maxlen);
		case zone_min_x:GetNativeString(3, RoleplayZone[zoneID].min_x, maxlen);
		case zone_min_y:GetNativeString(3, RoleplayZone[zoneID].min_y, maxlen);
		case zone_min_z:GetNativeString(3, RoleplayZone[zoneID].min_z, maxlen);
		case zone_max_x:GetNativeString(3, RoleplayZone[zoneID].max_x, maxlen);
		case zone_max_y:GetNativeString(3, RoleplayZone[zoneID].max_y, maxlen);
		case zone_max_z:GetNativeString(3, RoleplayZone[zoneID].max_z, maxlen);
		case zone_flag:GetNativeString(3, RoleplayZone[zoneID].flag, maxlen);
		case zone_bit:GetNativeString(3, RoleplayZone[zoneID].bit, maxlen);
		case zone_extra:GetNativeString(3, RoleplayZone[zoneID].extra, maxlen);
	}
	
	//GetNativeString(3, type_zone[zoneID][variable], maxlen);
	return -1;
}
/***************************************************************************************

									C A L L B A C K

***************************************************************************************/

public void OnClientDisconnect(int client)
{
	if(Timer_Zones[client] != null)
		TrashTimer(Timer_Zones[client], true);
}

public void OnClientPutInServer(int client)
{
	char translate[64];
	Format(STRING(translate), "%T", "zone_none", LANG_SERVER);
	rp_SetClientString(client, sz_ZoneName, STRING(translate));
	rp_SetClientInt(client, i_Zone, 0);
	SDKHook(client, SDKHook_OnTakeDamage, OnClientTakeDamage);
}	

public void OnClientAuthorized(int client, const char[] auth) 
{	
	strcopy(steamID[client], sizeof(steamID[]), auth);
}

public Action Event_Round(Event event, const char[] name, bool dontBroadcast)
{
	#if DEBUG
		PrintToServer("Event: %s", name);
	#endif
	
	RefreshZones();
	
	return Plugin_Handled;
}

public Action Message_SaveZones(int client, int args)
{
	KeyValues kv = new KeyValues("Zones");
	char sPath[PLATFORM_MAX_PATH], map[64];
	rp_GetCurrentMap(STRING(map));
	BuildPath(Path_SM, STRING(sPath), "data/roleplay/%s/zones.cfg", map);	
	Kv_CheckIfFileExist(kv, sPath);
	
	int count;
	
	LoopEntities(i)
	{
		if(!IsValidEntity(i))
			continue;
			
		char entClass[128];
		Entity_GetClassName(i, STRING(entClass));
		
		if(StrEqual(entClass, "trigger_multiple"))
		{
			char entName[64], buffer[3][64];
			Entity_GetName(i, STRING(entName));
			ExplodeString(entName, "|", STRING(buffer), sizeof(buffer[]));
			
			if(StrContains(buffer[0], "zone_") != -1 && !StrEqual(buffer[2], "map"))
			{
				count++;
				
				float fOrigin[3], fMins[3], fMaxs[3], fCornerOne[3], fCornerTwo[3];
				GetEntPropVector(i, Prop_Send, "m_vecOrigin", fOrigin);
				GetEntPropVector(i, Prop_Data, "m_vecMins", fMins);
				GetEntPropVector(i, Prop_Data, "m_vecMaxs", fMaxs);
				
				fCornerOne[0] = fOrigin[0] + fMins[0];
				fCornerOne[1] = fOrigin[1] + fMins[1];
				fCornerOne[2] = fOrigin[2] + fMins[2];
					
				fCornerTwo[0] = fOrigin[0] + fMaxs[0];
				fCornerTwo[1] = fOrigin[1] + fMaxs[1];
				fCornerTwo[2] = fOrigin[2] + fMaxs[2];
			
				char id[8];
				IntToString(count, STRING(id));
				if(kv.JumpToKey(id, true))
				{
					kv.SetString("name", buffer[0]);
					kv.SetString("bit", buffer[1]);
					if(strlen(buffer[2]) != 0)
						kv.SetString("extra", buffer[2]);
					kv.SetNum("enable", 1);
					kv.SetVector("min", fCornerOne);
					kv.SetVector("max", fCornerTwo);
					
					kv.GoBack();
					kv.Rewind();
					kv.ExportToFile(sPath);
				}	
			}	
		}
	}	
	
	delete kv;
	
	return Plugin_Handled;
}

public Action Message_GetTriggerPos(int client, int args)
{
	char arg[64];
	GetCmdArg(1, STRING(arg));
	
	LoopEntities(i)
	{
		if(!IsValidEntity(i))
			continue;
			
		char entClass[128];
		Entity_GetClassName(i, STRING(entClass));
		
		if(StrEqual(entClass, "trigger_multiple"))
		{
			char entName[64], buffer[2][64];
			Entity_GetName(i, STRING(entName));
			ExplodeString(entName, "|", STRING(buffer), sizeof(buffer[]));
			
			if(StrEqual(buffer[0], arg))
			{
				float fOrigin[3], fMins[3], fMaxs[3], fCornerOne[3], fCornerTwo[3];
				GetEntPropVector(i, Prop_Send, "m_vecOrigin", fOrigin);
				GetEntPropVector(i, Prop_Data, "m_vecMins", fMins);
				GetEntPropVector(i, Prop_Data, "m_vecMaxs", fMaxs);
				
				fCornerOne[0] = fOrigin[0] + fMins[0];
				fCornerOne[1] = fOrigin[1] + fMins[1];
				fCornerOne[2] = fOrigin[2] + fMins[2];
					
				fCornerTwo[0] = fOrigin[0] + fMaxs[0];
				fCornerTwo[1] = fOrigin[1] + fMaxs[1];
				fCornerTwo[2] = fOrigin[2] + fMaxs[2];
				
				//rp_PrintToChat(client, "{lightred}%s {grey}min: {lightgreen}%f %f %f \n {grey}max: {lightgreen}%f %f %f", entName, fCornerOne[0], fCornerOne[1], fCornerOne[2], fCornerTwo[0], fCornerTwo[1], fCornerTwo[2]);
				PrintToConsole(client, "%s \n min: %f %f %f \n max: %f %f %f", buffer[0], fCornerOne[0], fCornerOne[1], fCornerOne[2], fCornerTwo[0], fCornerTwo[1], fCornerTwo[2]);
			}	
		}
	}
	
	return Plugin_Handled;
}

public Action Message_GetZone(int client, int args)
{
	char arg[8];
	GetCmdArg(1, STRING(arg));
	
	int j = StringToInt(arg);
	
	char sMinX[32];
	rp_GetZoneData(j, zone_min_x, STRING(sMinX));
	
	char sMinY[32];
	rp_GetZoneData(j, zone_min_y, STRING(sMinY));
	
	char sMinZ[32];
	rp_GetZoneData(j, zone_min_z, STRING(sMinZ));
	
	char sMaxX[32];
	rp_GetZoneData(j, zone_max_x, STRING(sMaxX));
	
	char sMaxY[32];
	rp_GetZoneData(j, zone_max_y, STRING(sMaxY));
	
	char sMaxZ[32];
	rp_GetZoneData(j, zone_max_z, STRING(sMaxZ));
	
	float fMin[3], fMax[3];
	fMin[0] = StringToFloat(sMinX);
	fMin[1] = StringToFloat(sMinY);
	fMin[2] = StringToFloat(sMinZ);
	
	fMax[0] = StringToFloat(sMaxX);
	fMax[1] = StringToFloat(sMaxY);
	fMax[2] = StringToFloat(sMaxZ);
	
	int color[4];
	color[0] = 255;
	color[1] = 255;
	color[2] = 255;
	color[3] = 255;
	
	CPrintToChat(client, "ID: %i, min: %f %f %f max: %f %f %f", j, fMin[0], fMin[1], fMin[2], fMax[0], fMax[1], fMax[2]);
	
	return Plugin_Handled;
}

public int CreateZoneEntity(float fMins[3], float fMaxs[3], char sZoneName[64]) 
{
	float fMiddle[3];
	int iEnt = CreateEntityByName("trigger_multiple");
	
	Call_StartForward(Forward.OnZoneCreated);
	Call_PushString(sZoneName);
	Call_Finish();
	
	DispatchKeyValue(iEnt, "spawnflags", "64");
	DispatchKeyValue(iEnt, "targetname", sZoneName);
	DispatchKeyValue(iEnt, "wait", "0");
	
	DispatchSpawn(iEnt);
	ActivateEntity(iEnt);
	
	GetMiddleOfABox(fMins, fMaxs, fMiddle);
	
	TeleportEntity(iEnt, fMiddle, NULL_VECTOR, NULL_VECTOR);
	
	// Have the mins always be negative
	fMins[0] = fMins[0] - fMiddle[0]; 
	if (fMins[0] > 0.0)
		fMins[0] *= -1.0;
	fMins[1] = fMins[1] - fMiddle[1];
	if (fMins[1] > 0.0)
		fMins[1] *= -1.0;
	fMins[2] = fMins[2] - fMiddle[2];
	if (fMins[2] > 0.0)
		fMins[2] *= -1.0;
	
	// And the maxs always be positive
	fMaxs[0] = fMaxs[0] - fMiddle[0];
	if (fMaxs[0] < 0.0)
		fMaxs[0] *= -1.0;
	fMaxs[1] = fMaxs[1] - fMiddle[1];
	if (fMaxs[1] < 0.0)
		fMaxs[1] *= -1.0;
	fMaxs[2] = fMaxs[2] - fMiddle[2];
	if (fMaxs[2] < 0.0)
		fMaxs[2] *= -1.0;
	
	SetEntPropVector(iEnt, Prop_Send, "m_vecMins", fMins);
	SetEntPropVector(iEnt, Prop_Send, "m_vecMaxs", fMaxs);
	SetEntProp(iEnt, Prop_Send, "m_nSolidType", 2);
	
	int iEffects = GetEntProp(iEnt, Prop_Send, "m_fEffects");
	iEffects |= 32;
	SetEntProp(iEnt, Prop_Send, "m_fEffects", iEffects);

	SDKHookEx(iEnt, SDKHook_Touch, Hook_OnTouch);
	SDKHookEx(iEnt, SDKHook_EndTouch, Hook_OnEndTouch);
	
	return iEnt;
}

public Action Hook_OnTouch(int ent, int other)
{
	if(IsValidEntity(ent) && IsClientValid(other) || Vehicle_IsValid(other))
	{
		char sTargetName[256], name[3][64];
		GetEntPropString(ent, Prop_Data, "m_iName", STRING(sTargetName)); 
		ExplodeString(sTargetName, "|", name, 3, 64);
		
		int zoneID = StringToInt(name[1]);
		
		if(Vehicles_IsEntityDriveable(other))
		{
			if(zoneID == ZONE_RADAR)
			{
				if(rp_GetVehicleInt(other, car_insideradar) == 0)
					rp_SetVehicleInt(other, car_insideradar, 1);
			}
		}
		else
		{
			if(StrContains(sTargetName, "none", false) == -1)
			{
				if(StrContains(sTargetName, "appart", false) != -1)
				{
					rp_SetClientInt(other, i_ZoneAppart, StringToInt(name[2]));
				}
				else if(StrContains(sTargetName, "villa", false) != -1)
				{
					rp_SetClientInt(other, i_ZoneVilla, StringToInt(name[2]));
				}
				else if(StrContains(sTargetName, "hotel", false) != -1)
				{
					rp_SetClientInt(other, i_ZoneHotel, StringToInt(name[2]));
				}
				
				char translation[64];
				Format(STRING(translation), "%T", name[0], LANG_SERVER);
				
				rp_SetClientString(other, sz_ZoneName, STRING(translation));	
				rp_SetClientInt(other, i_Zone, zoneID);
			}
			else{
				if(zoneID == ZONE_GAS)
					rp_SetClientInt(other, i_Zone, ZONE_GAS);
			}
		}
	}
	
	return Plugin_Handled;
}

public void Hook_OnEndTouch(int ent, int other)
{
	if(IsValidEntity(ent) && IsClientValid(other))
	{
		rp_SetClientInt(other, i_Zone, 0);
		
		char translation[64];
		Format(STRING(translation), "%T", "zone_none", LANG_SERVER);
		rp_SetClientString(other, sz_ZoneName, STRING(translation));
		
		rp_SetClientInt(other, i_ZoneAppart, 0);
		rp_SetClientInt(other, i_ZoneVilla, 0);
		rp_SetClientInt(other, i_ZoneHotel, 0);
		
		if(rp_GetVehicleInt(other, car_insideradar) == 1)
			rp_SetVehicleInt(other, car_insideradar, 0);
		
		SetEntProp(other, Prop_Send, "m_iHideHUD", GetEntProp(other, Prop_Send, "m_iHideHUD") &~HIDE_RADAR_CSGO);
	}
}

public void RP_OnClientFire(int client, int target, const char[] weapon)
{
	if(ZoneNoDamage(client) || ZoneNoDamage(target))
	{
		PrecacheSound("ui/weapon_cant_buy.wav");
		EmitSoundToClient(client, "ui/weapon_cant_buy.wav", client, _, _, _, 0.8);
		rp_PrintToChat(client, "{lightred}Vous tirez dans une zone de paix !");
		return;
	}
}

public Action OnClientTakeDamage(int client, int &attacker, int &inflictor, float &damage, int &damagetype)
{	
	if(ZoneNoDamage(client))
	{
		damage = 0.0;
		return Plugin_Changed;
	}
	
	return Plugin_Continue;
}

/*									ZONES									*/

void LoadZones()
{
	KeyValues kv = new KeyValues("Zones");
	char map[64];
	rp_GetCurrentMap(STRING(map));
	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, STRING(sPath), "data/roleplay/%s/zones.cfg", map);
	Kv_CheckIfFileExist(kv, sPath);
	
	// Jump into the first subsection
	if (!kv.GotoFirstSubKey())
	{
		PrintToServer("ERROR FIRST KEY");
		delete kv;
		return;
	}
	
	char id[16];
	do
	{
		if(kv.GetSectionName(STRING(id)))
		{
			char zonename[64], zonebit[8], extra[8];
			kv.GetString("name", STRING(zonename));
			Format(STRING(zonename), "%T", zonename, LANG_SERVER);
			kv.GetString("bit", STRING(zonebit));
			kv.GetString("extra", STRING(extra));
			
			if(vbool(kv.GetNum("enable")) == false)
				continue;	
		
			float fMin[3], fMax[3];
			kv.GetVector("min", fMin);
			kv.GetVector("max", fMax);
					
			if(fMin[0] == 0.0 && fMin[1] == 0.0 && fMin[2] == 0.0
			|| fMax[0] == 0.0 && fMax[1] == 0.0 && fMax[2] == 0.0)
				continue;
				
			int zoneid = StringToInt(id);
					
			Format(RoleplayZone[zoneid].name, sizeof(RoleplayZone[].name), zonename);
			Format(RoleplayZone[zoneid].bit, sizeof(RoleplayZone[].bit), zonebit);
			if(strlen(extra) != 0)
				Format(RoleplayZone[zoneid].extra, sizeof(RoleplayZone[].extra), extra);
			Format(RoleplayZone[zoneid].min_x, sizeof(RoleplayZone[].min_x), "%f", fMin[0]);
			Format(RoleplayZone[zoneid].min_y, sizeof(RoleplayZone[].min_y), "%f", fMin[1]);
			Format(RoleplayZone[zoneid].min_z, sizeof(RoleplayZone[].min_z), "%f", fMin[2]);
			
			Format(RoleplayZone[zoneid].max_x, sizeof(RoleplayZone[].max_x), "%f", fMax[0]);
			Format(RoleplayZone[zoneid].max_y, sizeof(RoleplayZone[].max_y), "%f", fMax[1]);
			Format(RoleplayZone[zoneid].max_z, sizeof(RoleplayZone[].max_z), "%f", fMax[2]);
			
			enabled_zones++;
			
			#if DEBUG
				PrintToServer("Zone %i[%s]\n Min = %f %f %f\n Max = %f %f %f", enabled_zones, zonename, fMin[0], fMin[1], fMin[2], fMax[0], fMax[1], fMax[2]);
			#endif
		}	
	} 
	while (kv.GotoNextKey());
 
	
	kv.Rewind();	
	delete kv;
}

stock void TE_SendBeamBoxToClient(int client, float uppercorner[3], const float bottomcorner[3], int ModelIndex, int HaloIndex, int StartFrame, int FrameRate, float Life, float Width, float EndWidth, int FadeLength, float Amplitude, const int Color[4], int Speed) {
	// Create the additional corners of the box
	float tc1[3];
	AddVectors(tc1, uppercorner, tc1);
	tc1[0] = bottomcorner[0];
	
	float tc2[3];
	AddVectors(tc2, uppercorner, tc2);
	tc2[1] = bottomcorner[1];
	
	float tc3[3];
	AddVectors(tc3, uppercorner, tc3);
	tc3[2] = bottomcorner[2];
	
	float tc4[3];
	AddVectors(tc4, bottomcorner, tc4);
	tc4[0] = uppercorner[0];
	
	float tc5[3];
	AddVectors(tc5, bottomcorner, tc5);
	tc5[1] = uppercorner[1];
	
	float tc6[3];
	AddVectors(tc6, bottomcorner, tc6);
	tc6[2] = uppercorner[2];
	
	// Draw all the edges
	TE_SetupBeamPoints(uppercorner, tc1, ModelIndex, HaloIndex, StartFrame, FrameRate, Life, Width, EndWidth, FadeLength, Amplitude, Color, Speed);
	TE_SendToClient(client);
	TE_SetupBeamPoints(uppercorner, tc2, ModelIndex, HaloIndex, StartFrame, FrameRate, Life, Width, EndWidth, FadeLength, Amplitude, Color, Speed);
	TE_SendToClient(client);
	TE_SetupBeamPoints(uppercorner, tc3, ModelIndex, HaloIndex, StartFrame, FrameRate, Life, Width, EndWidth, FadeLength, Amplitude, Color, Speed);
	TE_SendToClient(client);
	TE_SetupBeamPoints(tc6, tc1, ModelIndex, HaloIndex, StartFrame, FrameRate, Life, Width, EndWidth, FadeLength, Amplitude, Color, Speed);
	TE_SendToClient(client);
	TE_SetupBeamPoints(tc6, tc2, ModelIndex, HaloIndex, StartFrame, FrameRate, Life, Width, EndWidth, FadeLength, Amplitude, Color, Speed);
	TE_SendToClient(client);
	TE_SetupBeamPoints(tc6, bottomcorner, ModelIndex, HaloIndex, StartFrame, FrameRate, Life, Width, EndWidth, FadeLength, Amplitude, Color, Speed);
	TE_SendToClient(client);
	TE_SetupBeamPoints(tc4, bottomcorner, ModelIndex, HaloIndex, StartFrame, FrameRate, Life, Width, EndWidth, FadeLength, Amplitude, Color, Speed);
	TE_SendToClient(client);
	TE_SetupBeamPoints(tc5, bottomcorner, ModelIndex, HaloIndex, StartFrame, FrameRate, Life, Width, EndWidth, FadeLength, Amplitude, Color, Speed);
	TE_SendToClient(client);
	TE_SetupBeamPoints(tc5, tc1, ModelIndex, HaloIndex, StartFrame, FrameRate, Life, Width, EndWidth, FadeLength, Amplitude, Color, Speed);
	TE_SendToClient(client);
	TE_SetupBeamPoints(tc5, tc3, ModelIndex, HaloIndex, StartFrame, FrameRate, Life, Width, EndWidth, FadeLength, Amplitude, Color, Speed);
	TE_SendToClient(client);
	TE_SetupBeamPoints(tc4, tc3, ModelIndex, HaloIndex, StartFrame, FrameRate, Life, Width, EndWidth, FadeLength, Amplitude, Color, Speed);
	TE_SendToClient(client);
	TE_SetupBeamPoints(tc4, tc2, ModelIndex, HaloIndex, StartFrame, FrameRate, Life, Width, EndWidth, FadeLength, Amplitude, Color, Speed);
	TE_SendToClient(client);
	
}

public Action Timer_CheckZones(Handle timer, any entity)
{
	if(!IsClientValid(entity) && !Vehicle_IsValid(entity))
		TrashTimer(timer, true);
	
	bool IsIn[MAXZONES+1] = { false, ... };
	int bit;
	char zonename[64];
	for(int j = 1; j <= enabled_zones; j++)
	{	
		float fMin[3], fMax[3];
		fMin[0] = StringToFloat(RoleplayZone[j].min_x);
		fMin[1] = StringToFloat(RoleplayZone[j].min_y); 
		fMin[2] = StringToFloat(RoleplayZone[j].min_z);
		
		fMax[0] = StringToFloat(RoleplayZone[j].max_x);
		fMax[1] = StringToFloat(RoleplayZone[j].max_y);
		fMax[2] = StringToFloat(RoleplayZone[j].max_z);
		
		int color[4];
		color[0] = 255;
		color[1] = 255;
		color[2] = 255;
		color[3] = 255;
		
		bit = StringToInt(RoleplayZone[j].bit);
		
		if(bit == ZONE_RADAR)
			continue;
			
		if(IsInsideBox(entity, fMin, fMax))
		{
			IsIn[j] = true;
			
			if(!Vehicle_IsValid(entity))
			{
				rp_GetClientString(entity, sz_ZoneName, STRING(zonename));
				if(!StrEqual(RoleplayZone[j].name, zonename))
				{
					rp_SetClientInt(entity, i_Zone, bit);
					rp_SetClientString(entity, sz_ZoneName, RoleplayZone[j].name, sizeof(RoleplayZone[].name));
					#if DEBUG
						CPrintToChat(entity, "ID: %i, min: %f %f %f max: %f %f %f", j, fMin[0], fMin[1], fMin[2], fMax[0], fMax[1], fMax[2]);
					#endif
					SetEntProp(entity, Prop_Send, "m_iHideHUD", GetEntProp(entity, Prop_Send, "m_iHideHUD") | HIDE_RADAR_CSGO);
					
					if(StrContains(zonename, "appart", false) != -1)
					{
						rp_SetClientInt(entity, i_ZoneAppart, StringToInt(RoleplayZone[j].extra));
						CPrintToChat(entity, "Appart EXTRA ID: %s", rp_GetClientInt(entity, i_ZoneAppart));
					}
					else if(StrContains(zonename, "villa", false) != -1)	
					{
						rp_SetClientInt(entity, i_ZoneVilla, StringToInt(RoleplayZone[j].extra));
						CPrintToChat(entity, "Villa EXTRA ID: %s", rp_GetClientInt(entity, i_ZoneVilla));
					}
					else if(StrContains(zonename, "hotel", false) != -1)	
					{
						rp_SetClientInt(entity, i_ZoneHotel, StringToInt(RoleplayZone[j].extra));
						CPrintToChat(entity, "Villa EXTRA ID: %s", rp_GetClientInt(entity, i_ZoneHotel));
					}
				}
			}
			else
				if(rp_GetVehicleInt(entity, car_insideradar) == 0)
					rp_SetVehicleInt(entity, car_insideradar, 1);		
		}

		#if DEBUG
			if(!Vehicle_IsValid(entity))
				TE_SendBeamBoxToClient(entity, fMin, fMax, g_BeamSprite, g_HaloSprite, 0, 30, 1.0, 5.0, 5.0, 2, 1.0, color, 0);
		#endif
	}
	
	int count;
	for(int i = 1; i <= enabled_zones; i++)
	{
		if(IsIn[i])
			count++;
	}
	
	if(count == 0)
	{
		if(!Vehicle_IsValid(entity))
		{
			if(rp_GetClientInt(entity, i_Zone) != 0)
			{
				char translation[64];
				Format(STRING(translation), "%T", "zone_none", LANG_SERVER);
				rp_SetClientString(entity, sz_ZoneName, STRING(translation));
				
				rp_SetClientInt(entity, i_Zone, 0);
				rp_SetClientInt(entity, i_ZoneAppart, 0);
				rp_SetClientInt(entity, i_ZoneVilla, 0);
				rp_SetClientInt(entity, i_ZoneHotel, 0);
				SetEntProp(entity, Prop_Send, "m_iHideHUD", GetEntProp(entity, Prop_Send, "m_iHideHUD") &~HIDE_RADAR_CSGO);
			}
		}
		else
			if(rp_GetVehicleInt(entity, car_insideradar) == 1)
				rp_SetVehicleInt(entity, car_insideradar, 0);
	}
	
	return Plugin_Handled;
}