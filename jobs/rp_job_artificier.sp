/*
*   Roleplay CS:GO de Benito est mis à disposition selon les termes de la licence Creative Commons Attribution .
* - Pas d’Utilisation Commerciale 
* - Partage dans les Mêmes Conditions 4.0 International.
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

/***************************************************************************************

							P L U G I N  -  D E F I N E S

***************************************************************************************/
#define JOBID 13

/***************************************************************************************

							G L O B A L  -  V A R S

***************************************************************************************/
Database 
	g_DB;
bool
	g_bHasAlreadyDynamite[MAXENTITIES + 1];
Handle 
	g_hDynamiteTimer[MAXENTITIES + 1];
	
enum struct ClientData {
	int DanceGrenadeEntity;
	bool CanPlantDynamite;
	bool HasDanceGrenade;
	bool HasDynamite;
	bool HasCeinture;
	char steamID[32];
}
ClientData g_iData[MAXPLAYERS + 1];

/***************************************************************************************

							P L U G I N  -  I N F O

***************************************************************************************/
public Plugin myinfo = 
{
	name = "Roleplay - [JOB] SexShop", 
	author = "MBK", 
	description = "Job Sexshop", 
	version = "1.0", 
	url = "https://github.com/Mbk10201"
};

/***************************************************************************************

									 F U N C T I O N S

***************************************************************************************/

public void OnPluginStart()
{
	LoadTranslation();
	HookEvent("decoy_started", Event_OnDecoy, EventHookMode_Post);
}

// Init SQL
public void RP_OnSQLInit(Database db)
{
	g_DB = db;
}

public void OnMapStart()
{
	LoopEntities(i)
	{
		if(IsClientValid(i))
			continue;
			
		if(!IsValidEntity(i))
			continue;
			
		if(!rp_IsValidDoor(i))
			continue;
			
		g_bHasAlreadyDynamite[i] = false;
	}
}

/***************************************************************************************

									C L I E N T - S I D E

***************************************************************************************/

public void OnClientAuthorized(int client, const char[] auth) 
{	
	strcopy(g_iData[client].steamID, sizeof(g_iData[].steamID), auth);
}	

public void OnClientPutInServer(int client)
{
	g_iData[client].HasDanceGrenade = false;
	g_iData[client].HasDynamite = false;
	g_iData[client].CanPlantDynamite = true;
	g_iData[client].HasCeinture = false;
	g_iData[client].DanceGrenadeEntity = -1;
}

public void RP_OnInventoryHandle(int client, int itemID)
{
	if(itemID == 49)
	{
		rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);	
	
		GivePlayerItem(client, "weapon_hegrenade");
		
		char name[32];
		rp_GetItemData(itemID, item_name, STRING(name));				
		rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
	}
	else if(itemID == 50)
	{
		rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
		
		GivePlayerItem(client, "weapon_flashbang");
		
		char name[32];
		rp_GetItemData(itemID, item_name, STRING(name));				
		rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
	}
	else if(itemID == 51)
	{
		rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
		
		GivePlayerItem(client, "weapon_smokegrenade");
		
		char name[32];
		rp_GetItemData(itemID, item_name, STRING(name));				
		rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
	}
	else if(itemID == 52)
	{
		rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
		
		GivePlayerItem(client, "weapon_decoy");
		
		char name[32];
		rp_GetItemData(itemID, item_name, STRING(name));				
		rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
	}
	else if(itemID == 53)
	{
		rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
		
		GivePlayerItem(client, "weapon_molotov");
		
		char name[32];
		rp_GetItemData(itemID, item_name, STRING(name));				
		rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
	}
	else if(itemID == 54)
	{
		rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
		
		GivePlayerItem(client, "weapon_incgrenade");
		
		char name[32];
		rp_GetItemData(itemID, item_name, STRING(name));				
		rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
	}
	else if(itemID == 55)
	{
		rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
		
		GivePlayerItem(client, "weapon_tagrenade");
		
		char name[32];
		rp_GetItemData(itemID, item_name, STRING(name));				
		rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
	}
	else if(itemID == 56)
	{
		rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
		
		GivePlayerItem(client, "weapon_breachcharge");
		
		char name[32];
		rp_GetItemData(itemID, item_name, STRING(name));				
		rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
	}
	else if(itemID == 57)
	{
		int wepID = Client_GetActiveWeapon(client);
		if(rp_canSetAmmo(client, wepID))
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
			
			rp_SetClientAmmo(wepID, 0, 32, true);
			
			char name[32];
			rp_GetItemData(itemID, item_name, STRING(name));				
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}	
	}
	else if(itemID == 58)
	{
		int wepID = Client_GetActiveWeapon(client);
		if(rp_canSetAmmo(client, wepID))
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
			
			rp_SetWeaponAmmoType(wepID, ammo_type_incendiary);	
			rp_SetWeaponAmmoAmount(wepID, rp_GetWeaponAmmoAmount(wepID) + 30);
			
			char name[32];
			rp_GetItemData(itemID, item_name, STRING(name));				
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}	
	}
	else if(itemID == 59)
	{
		int wepID = Client_GetActiveWeapon(client);
		if(rp_canSetAmmo(client, wepID))
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
			
			rp_SetWeaponAmmoType(wepID, ammo_type_rubber);	
			rp_SetWeaponAmmoAmount(wepID, rp_GetWeaponAmmoAmount(wepID) + 30);
			
			char name[32];
			rp_GetItemData(itemID, item_name, STRING(name));				
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}
		else	
			rp_PrintToChat(client, "%T", "AmmoNeedWeapon", LANG_SERVER);
	}
	else if(itemID == 60)
	{
		int wepID = Client_GetActiveWeapon(client);
		if(rp_canSetAmmo(client, wepID))
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
			
			rp_SetWeaponAmmoType(wepID, ammo_type_perforating);	
			rp_SetWeaponAmmoAmount(wepID, rp_GetWeaponAmmoAmount(wepID) + 30);
			
			char name[32];
			rp_GetItemData(itemID, item_name, STRING(name));				
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}	
		else		
			rp_PrintToChat(client, "%T", "AmmoNeedWeapon", LANG_SERVER);
	}
	else if(itemID == 61)
	{
		int wepID = Client_GetActiveWeapon(client);
		if(rp_canSetAmmo(client, wepID))
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);	
			
			rp_SetWeaponAmmoType(wepID, ammo_type_explosive);	
			rp_SetWeaponAmmoAmount(wepID, rp_GetWeaponAmmoAmount(wepID) + 30);
			
			char name[32];
			rp_GetItemData(itemID, item_name, STRING(name));				
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}	
		else
			rp_PrintToChat(client, "%T", "AmmoNeedWeapon", LANG_SERVER);
	}
	else if(itemID == 62)
	{
		int wepID = Client_GetActiveWeapon(client);
		if(rp_canSetAmmo(client, wepID))
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
			
			rp_SetWeaponAmmoType(wepID, ammo_type_health);	
			rp_SetWeaponAmmoAmount(wepID, rp_GetWeaponAmmoAmount(wepID) + 30);
			
			char name[32];
			rp_GetItemData(itemID, item_name, STRING(name));				
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}	
		else
			rp_PrintToChat(client, "%T", "AmmoNeedWeapon", LANG_SERVER);
	}
	else if(itemID == 63)
	{
		int wepID = Client_GetActiveWeapon(client);
		if(rp_canSetAmmo(client, wepID))
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
			
			rp_SetWeaponAmmoType(wepID, ammo_type_paintball);	
			rp_SetWeaponAmmoAmount(wepID, rp_GetWeaponAmmoAmount(wepID) + 30);
			
			char name[32];
			rp_GetItemData(itemID, item_name, STRING(name));				
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}	
		else
			rp_PrintToChat(client, "%T", "AmmoNeedWeapon", LANG_SERVER);
	}
	else if(itemID == 64)
	{
		int wepID = Client_GetActiveWeapon(client);
		if(rp_canSetAmmo(client, wepID))
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
			
			rp_SetClientAmmo(wepID, 1000, 0, true);
			
			char name[32];
			rp_GetItemData(itemID, item_name, STRING(name));				
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}
		else
			rp_PrintToChat(client, "%T", "AmmoNeedWeapon", LANG_SERVER);	
	}	
	else if(itemID == 153)
	{
		if(!g_iData[client].HasDanceGrenade)
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
			
			g_iData[client].HasDanceGrenade = true;
			g_iData[client].DanceGrenadeEntity = GivePlayerItem(client, "weapon_decoy");
			
			char name[32];
			rp_GetItemData(itemID, item_name, STRING(name));				
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}
		else			
			rp_PrintToChat(client, "Vous avez déjà une dance grenade sur vous.", LANG_SERVER);	
	}	
	else if(itemID == 154)
	{
		rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
		
		char sModel[128];
		rp_GetGlobalData("model_claymore", STRING(sModel));
		
		int ent = CreateEntityByName("prop_dynamic_override");
		DispatchKeyValue(ent, "solid", "6");
		DispatchKeyValue(ent, "model", sModel);
		DispatchSpawn(ent);
		SDKHook(ent, SDKHook_Touch, OnClientStartTouch);
		Entity_SetName(ent, "claymore_%N|%i", client, ent);
             
		float position[3];
		PointVision(client, position);
		TeleportEntity(ent, position, NULL_VECTOR, NULL_VECTOR);
		
		rp_Sound(client, "sound_plant", 1.0);
		
		LoopClients(i)
		{
			if(!IsClientValid(i))
				continue;
			
			float distance = Distance(client, i);
			if(distance <= 300.0)
			{
				rp_Sound(i, "sound_plant", 1.0);
			}	
		}
		
		char name[32];
		rp_GetItemData(itemID, item_name, STRING(name));				
		rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
	}
	else if(itemID == 155)
	{
		int target = GetClientAimTarget(client, false);
		if(rp_IsValidDoor(target) || Vehicle_IsValid(target))
		{
			if(!g_bHasAlreadyDynamite[target])
			{
				if(Entity_IsLocked(target))
				{
					if(g_iData[client].CanPlantDynamite)
					{
						rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
						
						float position[3];
						PointVision(client, position);
						
						DataPack pack = new DataPack();
						CreateDataTimer(5.0, Timer_PlantDynamite, pack);
						pack.WriteCell(client);
						pack.WriteCell(target);
						pack.WriteFloat(position[0]);
						pack.WriteFloat(position[1]);
						pack.WriteFloat(position[2]);

						g_iData[client].CanPlantDynamite = false;
						CreateTimer(25.0, Timer_ResetPlantDynamite, client);
						
						char name[32];
						rp_GetItemData(itemID, item_name, STRING(name));				
						rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
					}
					else
						rp_PrintToChat(client, "Vous devez patienter avant de pouvoir planter de la dynamite.");
				}	
				else
					rp_PrintToChat(client, "Cette porte est déjà dévérouillée.");
			}		
			else
				rp_PrintToChat(client, "Cette porte est déjà équipé de dynamite, {lightred}attention !");	
		}	
		else
			rp_PrintToChat(client, "{lightred}Vous devez viser une entité{orange}({green}Porte{orange}/{green}Voiture{orange}).");	
	}
	else if(itemID == 156)
	{
		rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
			
		int random = GetRandomInt(1, 6);
		switch(random)
		{
			case 1:GivePlayerItem(client, "weapon_hegrenade");
			case 2:GivePlayerItem(client, "weapon_flashbang");
			case 3:GivePlayerItem(client, "weapon_smokegrenade");
			case 4:GivePlayerItem(client, "weapon_decoy");
			case 5:GivePlayerItem(client, "weapon_molotov");
			case 6:GivePlayerItem(client, "weapon_incgrenade");
		}
			
		char name[32];
		rp_GetItemData(itemID, item_name, STRING(name));				
		rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
	}
	else if(itemID == 157)
	{
		rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
			
		g_iData[client].HasCeinture = true;
			
		char name[32];
		rp_GetItemData(itemID, item_name, STRING(name));				
		rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
	}
}

public void RP_OnClientDeath(int attacker, int victim, const char[] weapon, bool headshot)
{
	if(g_iData[victim].HasCeinture)
	{
		g_iData[victim].HasCeinture = false;
		int number = GetRandomInt(1, 9);
			
		char sound[128];
		Format(STRING(sound), "roleplay/claymore/ex%i.mp3", number);
		
		rp_Sound(victim, sound, 1.0);
		
		float position[3];
		GetClientAbsOrigin(victim, position);
		rp_CreateParticle(position, "explosion_hegrenade_dirt", 10.0);
		
		LoopClients(i)
		{
			if(!IsClientValid(i))
				continue;
				
			if(Distance(victim, i) < 200)
			{
				ForcePlayerSuicide(i);
				rp_PrintToChat(i, "Vous avez été tuée par un kamikaze !");
				rp_Sound(i, sound, 0.7);
			}	
			else if(Distance(victim, i) > 200 && Distance(victim, i) < 300)
			{
				int minusHealth = GetRandomInt(20, 50);
				
				if(GetClientHealth(i) <= minusHealth)
					ForcePlayerSuicide(i);
					
				rp_Sound(i, sound, 0.5);	
				
				SetEntityHealth(i, GetClientHealth(i) - minusHealth);
				rp_PrintToChat(i, "Vous avez été bléssé par un kamikaze !");
			}
		}
	}
}

public void RP_OnClientInteract(int client, int target, const char[] class, const char[] model, const char[] name)
{
	if(rp_GetNPCType(target) == JOBID)
	{
		if(Distance(client, target) <= 80.0)
			rp_PerformNPCSell(client, JOBID);
		else
			Translation_PrintTooFar(client);
	}
}	

public Action Event_OnDecoy(Event event, const char[] name, bool dontBroadcast)
{
	#if DEBUG
		PrintToServer("Event: %s", name);
	#endif
    
	int client = GetClientOfUserId(event.GetInt("userid"));
	int entity = event.GetInt("entityid");
	
	float position[3];
	position[0] = event.GetFloat("x");
	position[1] = event.GetFloat("y");
	position[2] = event.GetFloat("z");
	
	int id = GetRandomInt(1, 86);
	LoopClients(i)
	{
		if(!IsClientValid(i))
			continue;
			
		char playerName[64];
		
		float distance = Distance(entity, i);
		if(distance <= 300.0)
		{
			GetClientName(i, STRING(playerName));	
			ServerCommand("sm_setemotes %s %i", playerName, id);
			#if DEBUG
				PrintToServer("sm_setemotes %s %i", playerName, id);
			#endif	
			rp_AttachCreateParticle(i, "d2d_ring18", 5.0);
			rp_SetClientBool(i, b_TouchedByDanceGrenade, true);
			CreateTimer(5.0, Timer_ResetDanceGrenade, i);
		}	
	}
	
	rp_CreateParticle(position, "ring5", 5.0);
	UTIL_RemoveEntity(entity, 5.0);
	g_iData[client].DanceGrenadeEntity = -1;
	g_iData[client].HasDanceGrenade = false;
	
	return Plugin_Handled;
}

public Action Timer_ResetDanceGrenade(Handle timer, any client)
{
	rp_SetClientBool(client, b_TouchedByDanceGrenade, false);
	rp_StopEmote(client);
	
	return Plugin_Handled;
}

public Action Timer_ResetPlantDynamite(Handle timer, any client)
{
	if(IsClientValid(client))
	{
		g_iData[client].CanPlantDynamite = true;
		rp_PrintToChat(client, "Vous pouvez à nouveau reutiliser de la dynamite.");
	}
	
	return Plugin_Handled;
}

public Action OnClientStartTouch(int caller, int activator)
{
	if (IsValidEntity(caller))
	{
		char entModel[128];
		Entity_GetModel(caller, STRING(entModel));
		
		char sModel[128];
		rp_GetGlobalData("model_claymore", STRING(sModel));
		if (StrEqual(entModel, sModel))
		{
			RemoveEdict(caller);

			int number = GetRandomInt(1, 9);
			
			char sound[128];
			Format(STRING(sound), "roleplay/claymore/ex%i.mp3", number);
			
			rp_Sound(activator, sound, 0.4);
			
			float position[3];
			GetClientAbsOrigin(activator, position);
			rp_CreateParticle(position, "explosion_hegrenade_dirt", 10.0);
			
			ForcePlayerSuicide(activator);
			rp_PrintToChat(activator, "Vous avez marché sur une claymore !");
			
			LoopClients(i)
			{
				if(!IsClientValid(i))
					continue;
					
				if(Distance(caller, i) < 200)
				{
					ForcePlayerSuicide(i);
					rp_PrintToChat(i, "Vous avez été tuée par une claymore !");
				}	
				else if(Distance(caller, i) > 200 && Distance(caller, i) < 300)
				{
					int minusHealth = GetRandomInt(20, 50);
					
					if(GetClientHealth(i) <= minusHealth)
						ForcePlayerSuicide(i);
					
					SetEntityHealth(i, GetClientHealth(i) - minusHealth);
					rp_PrintToChat(i, "Vous avez été bléssé par une claymore !");
				}
			}
		}	
	}
	
	return Plugin_Handled;
}

public Action Timer_PlantDynamite(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int door = pack.ReadCell();
	float position[3];
	position[0] = pack.ReadFloat();
	position[1] = pack.ReadFloat();
	position[2] = pack.ReadFloat();
	
	if(!IsValidEntity(door))
		return Plugin_Stop;
	
	g_bHasAlreadyDynamite[door] = true;
	char sModel[128];
	rp_GetGlobalData("model_c4planted", STRING(sModel));
	
	int ent = CreateEntityByName("prop_dynamic_override");
	DispatchKeyValue(ent, "solid", "6");
	DispatchKeyValue(ent, "model", sModel);
	DispatchSpawn(ent);
	//SDKHook(ent, SDKHook_OnTakeDamage, OnTakeDamage);
	Entity_SetName(ent, "dynamite|%i|%i", client, door);
         
	float angles[3], clientangles[3];
	GetEntPropVector(door, Prop_Data, "m_angRotation", angles); 
	GetClientAbsAngles(client, clientangles);
	angles[0] = -90.0;
	angles[1] = float(RoundToCeil(clientangles[1]));
	TeleportEntity(ent, position, angles, NULL_VECTOR);
	
	LoopClients(i)
	{
		if(!IsClientValid(i))
			continue;
		
		float distance = Distance(client, i);
		if(distance <= 300.0)
			rp_Sound(i, "sound_plant", 1.0);
	}
	
	rp_CreateParticle(position, "vixr_niz", 10.0);
	
	DataPack pack1 = new DataPack();
	g_hDynamiteTimer[ent] = CreateDataTimer(10.0, Timer_ExplodeDynamite, pack1);
	pack1.WriteCell(client);
	pack1.WriteCell(door);
	pack1.WriteCell(ent);
	pack1.WriteFloat(position[0]);
	pack1.WriteFloat(position[1]);
	pack1.WriteFloat(position[2]);
	
	return Plugin_Stop;
}

public Action Timer_ExplodeDynamite(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int door = pack.ReadCell();
	int c4 = pack.ReadCell();
	float position[3];
	position[0] = pack.ReadFloat();
	position[1] = pack.ReadFloat();
	position[2] = pack.ReadFloat();
	
	if(!IsValidEntity(door) || !IsValidEntity(c4))
		return Plugin_Stop;
			
	rp_CreateParticle(position, "explosion_hegrenade_dirt", 1.0);
	Entity_UnLock(door);
	AcceptEntityInput(door, "Open");
	g_bHasAlreadyDynamite[door] = false;
	rp_PrintToChat(client, "La porte est dévérrouillée.");
	
	LoopClients(i)
	{
		if(!IsClientValid(i))
			continue;
			
		int number = GetRandomInt(1, 9);
		char sound[128];
		Format(STRING(sound), "roleplay/claymore/ex%i.mp3", number);	
		
		float distance = Distance(c4, i);
		if(distance <= 500.0)
			rp_Sound(i, sound, 0.7);
			
		if(distance <= 200)
		{
			ForcePlayerSuicide(i);
			rp_PrintToChat(i, "Vous été tuée par une dynamite !");
		}	
		else if(distance > 200 && distance < 300)
		{
			int minusHealth = GetRandomInt(20, 50);
			
			if(GetClientHealth(i) <= minusHealth)
				ForcePlayerSuicide(i);
			
			SetEntityHealth(i, GetClientHealth(i) - minusHealth);
			rp_PrintToChat(i, "Vous avez été bléssé par une dynamite !");
		}	
	}
	
	RemoveEdict(c4);
	
	return Plugin_Stop;
}		

public void RP_OnClientFire(int client, int target, const char[] weapon)
{
	if(IsValidEntity(target))
	{
		if (!StrEqual(weapon, "weapon_fists"))
		{
			char entModel[128];
			Entity_GetModel(target, STRING(entModel));
			
			char sModel[128];
			rp_GetGlobalData("model_claymore", STRING(sModel));
			
			if (StrEqual(entModel, sModel))
			{
				RemoveEdict(target);
		
				int number = GetRandomInt(1, 9);
				
				char sound[128];
				Format(STRING(sound), "roleplay/claymore/ex%i.mp3", number);
				
				float position[3];
				GetEntPropVector(target, Prop_Send, "m_vecOrigin", position);
				rp_CreateParticle(position, "explosion_hegrenade_dirt", 3.0);
				rp_CreateParticle(position, "explosion_child_dust07a", 2.0);
				
				rp_PrintToChat(client, "Vous avez détruit une claymore !");
				
				LoopClients(i)
				{
					if(!IsClientValid(i))
						continue;
					
					if(Distance(target, i) < 200)
					{
						ForcePlayerSuicide(i);
						rp_PrintToChat(i, "Vous été tuée par une claymore !");
						rp_Sound(i, sound, 1.0);
					}	
					else if(Distance(target, i) > 200 && Distance(target, i) < 300)
					{
						int minusHealth = GetRandomInt(20, 50);
						
						if(GetClientHealth(i) <= minusHealth)
							ForcePlayerSuicide(i);
						
						SetEntityHealth(i, GetClientHealth(i) - minusHealth);
						rp_PrintToChat(i, "Vous été bléssé par une claymore !");
						rp_Sound(i, sound, 0.5);
					}
				}
			}
			
			rp_GetGlobalData("model_c4planted", STRING(sModel));
			if (StrEqual(entModel, sModel))
			{
				if(g_hDynamiteTimer[target] != null)
					CloseHandle(g_hDynamiteTimer[target]);
				RemoveEdict(target);
				
				char entName[64];
				Entity_GetName(target, STRING(entName));
		
				char buffer[3][64];
				ExplodeString(entName, "|", buffer, 3, 64);
				
				int owner = StringToInt(buffer[1]);
				int door = StringToInt(buffer[2]);
				
				g_bHasAlreadyDynamite[door] = false;
		
				if(IsClientValid(owner))
					rp_PrintToChat(owner, "Votre dynamite a été détruite.");
		
				int number = GetRandomInt(1, 9);
				char sound[128];
				Format(STRING(sound), "roleplay/claymore/ex%i.mp3", number);
				
				float position[3];
				GetEntPropVector(target, Prop_Send, "m_vecOrigin", position);
				rp_CreateParticle(position, "explosion_child_core04b", 1.0);
				rp_CreateParticle(position, "explosion_hegrenade_dirt", 1.0);
				
				rp_PrintToChat(client, "Vous avez détruit une dynamite !");
				
				LoopClients(i)
				{
					if(!IsClientValid(i))
						continue;
					
					if(Distance(target, i) < 200)
					{
						ForcePlayerSuicide(i);
						rp_PrintToChat(i, "Vous été tuée par une dynamite !");
						rp_Sound(i, sound, 1.0);
					}	
					else if(Distance(target, i) > 200 && Distance(target, i) < 300)
					{
						int minusHealth = GetRandomInt(20, 50);
						
						if(GetClientHealth(i) <= minusHealth)
							ForcePlayerSuicide(i);
						
						SetEntityHealth(i, GetClientHealth(i) - minusHealth);
						rp_PrintToChat(i, "Vous avez été bléssé par une dynamite !");
						rp_Sound(i, sound, 0.5);
					}
				}	
			}
		}	
	}	
}