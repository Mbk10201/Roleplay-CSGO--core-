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

#define JOBID	15
#define KNIFE_MDL "models/down/shuriken/shuriken.mdl"
#define TRAIL_COLOR {177, 177, 177, 117}

/***************************************************************************************

							G L O B A L  -  V A R S

***************************************************************************************/

char steamID[MAXPLAYERS + 1][32];
Database g_DB;

int knifeIndex;
Handle g_hLethalArray;
float g_fVelocity;
float g_fSpin[3] = {4877.4, 0.0, 0.0};
float g_fMinS[3] = {-24.0, -24.0, -24.0};
float g_fMaxS[3] = {24.0, 24.0, 24.0};

/***************************************************************************************

							P L U G I N  -  I N F O

***************************************************************************************/
public Plugin myinfo = 
{
	name = "Roleplay - [JOB] Coach", 
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
	
	g_hLethalArray = CreateArray();
	AddNormalSoundHook(Event_SoundEmitted);
}

// Init SQL
public void RP_OnSQLInit(Database db)
{
	g_DB = db;
}

public void OnMapStart()
{
	knifeIndex = PrecacheModel("materials/sprites/laserbeam.vmt");
}	

/***************************************************************************************

									C L I E N T - S I D E

***************************************************************************************/

public void OnClientAuthorized(int client, const char[] auth) 
{	
	strcopy(steamID[client], sizeof(steamID[]), auth);
}

public void OnClientDisconnect(int client)
{
	rp_SetClientInt(client, i_KnifeThrow, 0);
	rp_SetClientInt(client, i_KnifeLevel, 0);
}	

public void OnClientPutInServer(int client)
{
	rp_SetClientInt(client, i_KnifeThrow, 0);
	rp_SetClientInt(client, i_KnifeLevel, 0);
}

public void RP_OnInventoryHandle(int client, int itemID)
{
	char translate[128];
	
	if(itemID == 114)
	{
		rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
		
		rp_SetClientInt(client, i_KnifeThrow, rp_GetClientInt(client, i_KnifeThrow) + 3);
		Format(STRING(translate), "%T", "CountThrowKnives", LANG_SERVER, rp_GetClientInt(client, i_KnifeThrow));
		rp_PrintToChat(client, "%s.", translate);	
		
		char name[32];
		rp_GetItemData(itemID, item_name, STRING(name));				
		rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);	
	}
	else if(itemID == 115)
	{
		if(rp_GetClientInt(client, i_KnifeLevel) != GetMaxLvlCut(client))
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
			
			rp_SetClientInt(client, i_KnifeLevel, rp_GetClientInt(client, i_KnifeLevel) + 3);
			Format(STRING(translate), "%T", "CountKnifeLevel", LANG_SERVER, rp_GetClientInt(client, i_KnifeLevel), GetMaxLvlCut(client));
			rp_PrintToChat(client, "%s.", translate);	
			
			char name[32];
			rp_GetItemData(itemID, item_name, STRING(name));				
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);	
		}	
		else
		{
			Format(STRING(translate), "%T", "CountThrowKnives", LANG_SERVER, rp_GetClientInt(client, i_KnifeLevel), GetMaxLvlCut(client));
			rp_PrintToChat(client, "%s.", translate);
		}	
	}
	else if(itemID == 116)
	{
		if(rp_CheckIfIsUseKnife(client))
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);	
			
			int weapon = Client_GetActiveWeapon(client);
			rp_SetKnifeType(weapon, knife_type_freeze);
			rp_SetWeaponAmmoAmount(weapon, 3);
			
			char name[32];
			rp_GetItemData(itemID, item_name, STRING(name));				
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);	
		}	
	}
	else if(itemID == 117)
	{
		if(rp_CheckIfIsUseKnife(client))
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
			
			int weapon = Client_GetActiveWeapon(client);
			rp_SetKnifeType(weapon, knife_type_fire);
			rp_SetWeaponAmmoAmount(weapon, 3);
			
			char name[32];
			rp_GetItemData(itemID, item_name, STRING(name));				
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);	
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

public Action Event_SoundEmitted(int clients[64], int &numClients, char sSample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags) 
{
	if(StrEqual(sSample, "~)weapons/smokegrenade/grenade_hit1.wav", false))
	{
		int attacker = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
		rp_Sound(attacker, "roleplay/throw.mp3", 1.0);
		int index = FindValueInArray(g_hLethalArray, entity);
		if (index != -1) 
		{
			volume = 0.2;
			RemoveFromArray(g_hLethalArray, index); // delethalize on first bounce
			float fKnifePos[3];
			GetEntPropVector(entity, Prop_Data, "m_vecOrigin", fKnifePos);
			int victim = GetTraceHullEntityIndex(fKnifePos, attacker);
			
			if (IsClientIndex(victim) && IsClientInGame(attacker)) 
			{
				ForcePlayerSuicide(victim);
				rp_Sound(victim, "roleplay/throw.mp3", 1.0);
			}
			return Plugin_Changed;
		}	
	}	

	return Plugin_Continue;
}

public void RP_OnClientHurt(int client, int attacker, int damage, int armor, const char[] weapon)
{
	int health = GetClientHealth(client);
	int maxLvlCut = GetMaxLvlCut(attacker);
	int lvlcut;
	if(rp_GetClientInt(attacker, i_KnifeLevel) > maxLvlCut)
		lvlcut = health + damage - maxLvlCut;
	else
		lvlcut = health + damage - rp_GetClientInt(attacker, i_KnifeLevel);
		
	if(StrContains(weapon, "knife") != -1)
	{
		SetEntityHealth(client, lvlcut);		
		if(rp_GetClientInt(attacker, i_KnifeLevel) == 0)
		{
			damage = 0;
			
			PrecacheSound("ui/weapon_cant_buy.wav");
			EmitSoundToClient(attacker, "ui/weapon_cant_buy.wav", attacker, _, _, _, 0.8);
			CPrintToChat(attacker, "%s Vous devez aiguiser votre couteau.\nRendez-vous au coach.");
			
			if(armor > 0)
				Client_SetArmor(client, Client_GetArmor(client) + armor);
		}
	}	
}	

public void RP_OnClientFire(int client, int target, const char[] weapon)
{
	if (StrContains(weapon, "knife") != -1)
	{
		if(rp_GetClientInt(client, i_KnifeThrow) != 0)
		{
			rp_SetClientInt(client, i_KnifeThrow, rp_GetClientInt(client, i_KnifeThrow) - 1);
			char translate[128];
			Format(STRING(translate), "%T", "CountThrowKnives", LANG_SERVER, rp_GetClientInt(client, i_KnifeThrow));
			rp_PrintToChat(client, "%s.", translate);
			
			ThrowKnife(client);
		}	
	}
}

public void RP_OnClientTakeDamage(int client, int attacker, int inflictor, float &damage, int damagetype)
{
	char translation[128];
	if(IsClientValid(attacker))
	{
		int wepID = Client_GetActiveWeapon(attacker);	
		if(IsValidEntity(wepID))
		{
			if(rp_CheckIfIsUseKnife(attacker))
			{	
				knife_type type = rp_GetKnifeType(wepID);
				if(rp_GetWeaponAmmoAmount(wepID) != 0)
				{
					rp_SetWeaponAmmoAmount(wepID, rp_GetWeaponAmmoAmount(wepID) - 1);
					
					Format(STRING(translation), "%T", "SpecialAmmoRemaining", LANG_SERVER, rp_GetWeaponAmmoAmount(wepID));
					CPrintToChat(attacker, "%s %s", translation);
					switch(type)
					{
						case knife_type_fire:
						{
							if(IsClientValid(client))
								IgniteEntity(client, 10.0, false);
						}
						case knife_type_freeze:
						{
							if(IsClientValid(client))
							{
								if(GetEntityMoveType(client) != MOVETYPE_NONE)
								{
									SetEntityMoveType(client, MOVETYPE_NONE);
									CreateTimer(5.0, rp_SetDefaultMove, client);
									
									rp_Sound(attacker, "sound_taser", 1.0);
									rp_Sound(client, "sound_taser", 1.0);
								}	
								else
								{
									Format(STRING(translation), "%T", "Target_AlreadyFreeze", LANG_SERVER);
									CPrintToChat(attacker, "%s %s.", translation);	
								}
							}	
						}
					}
				}
			}	
		}
	}	
}	

public void RP_OnClientDeath(int attacker, int victim, const char[] weapon, bool headshot)
{
	if(StrContains(weapon, "knife") != -1 && rp_GetClientInt(attacker, i_KnifeLevel) > 0)
		rp_SetClientInt(attacker, i_KnifeLevel, rp_GetClientInt(attacker, i_KnifeLevel) - 1);
}	

void ThrowKnife(int client) 
{
	float fPos[3], fAng[3], fVel[3], fPVel[3];
	GetClientEyePosition(client, fPos);

	int entity = CreateEntityByName("smokegrenade_projectile");
	if ((entity != -1) && DispatchSpawn(entity)) 
	{
		PrecacheModel("models/down/shuriken/shuriken.mdl");
		SetEntityModel(entity, "models/down/shuriken/shuriken.mdl");
		SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", client);
		/*SetVariantString(ADD_OUTPUT);
		AcceptEntityInput(entity, "AddOutput");*/
		GetClientEyeAngles(client, fAng);
		GetAngleVectors(fAng, fVel, NULL_VECTOR, NULL_VECTOR);
		ScaleVector(fVel, g_fVelocity);
		GetEntPropVector(client, Prop_Data, "m_vecVelocity", fPVel);
		AddVectors(fVel, fPVel, fVel);
		SetEntPropVector(entity, Prop_Data, "m_vecAngVelocity", g_fSpin);
		SetEntPropFloat(entity, Prop_Send, "m_flElasticity", 0.2);
		AcceptEntityInput(entity, "FireUser1");
		PushArrayCell(g_hLethalArray, entity);
		TeleportEntity(entity, fPos, fAng, fVel);
		
		TE_SetupBeamFollow(entity, knifeIndex, 0, 0.7, 7.7, 7.7, 3, TRAIL_COLOR);
		TE_SendToAll();
	}
}

int GetTraceHullEntityIndex(float pos[3], int xindex) 
{
	TR_TraceHullFilter(pos, pos, g_fMinS, g_fMaxS, MASK_SHOT, THFilter, xindex);
	return TR_GetEntityIndex();
}

public bool THFilter(int entity, int contentsMask, any data) 
{
	return IsClientIndex(entity) && (entity != data);
}

bool IsClientIndex(int index) 
{
	return (index > 0) && (index <= MaxClients);
}