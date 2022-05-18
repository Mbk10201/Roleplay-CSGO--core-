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
#define JOBID				16

/***************************************************************************************

							G L O B A L  -  V A R S

***************************************************************************************/
char steamID[MAXPLAYERS + 1][32];
Database g_DB;

/***************************************************************************************

							P L U G I N  -  I N F O

***************************************************************************************/
public Plugin myinfo = 
{
	name = "Roleplay - [JOB] SexShop", 
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
}

// Init SQL
public void RP_OnSQLInit(Database db)
{
	g_DB = db;
}

/***************************************************************************************

									C A L L B A C K

***************************************************************************************/  

public Action canItem(Handle timer, any client)
{
	if(IsClientValid(client))
	{
		rp_PrintToChat(client, "Vous avez désormais accès aux items.");
		rp_SetClientBool(client, b_CanUseItem, true);
	}
	
	return Plugin_Handled;
}

/***************************************************************************************

									C L I E N T - S I D E

***************************************************************************************/

public void OnClientAuthorized(int client, const char[] auth) 
{	
	strcopy(steamID[client], sizeof(steamID[]), auth);
}	

public void RP_OnInventoryHandle(int client, int itemID)
{
	char translate[128];
	
	if(itemID == 44)
	{
		rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
			
		
		float position[3];
		GetClientAbsOrigin(client, position);
		rp_CreateParticle(position, "explosion_c4_500", 10.0);
		PrecacheSound("weapons/c4/c4_explode1.wav");
		EmitSoundToAll("weapons/c4/c4_explode1.wav", client, _, _, _, 1.0, _, _, position);
		
		int count;
		for(int i = 1; i <= MaxClients; i++)
		{
			if(IsValidEntity(i))
			{
				int vie = GetClientHealth(i), montant;
				float playerDistance = Distance(client, i);
				if(playerDistance >= 220.0)
					montant = GetRandomInt(5, 35);
				else if(playerDistance <= 150.0)
					ForcePlayerSuicide(i);	
				else
					montant = GetRandomInt(5, 75);
				
				if(vie - montant > 0)
					SetEntityHealth(i, vie - montant);
				else
				{
					ForcePlayerSuicide(i);
					if(i != client)
						count++;
				}
			}
		}
		if(count > 0)
		{
			if(count == 1)
			{
				Format(STRING(translate), "%T", "Kill", LANG_SERVER);
				rp_PrintToChat(client, "%s", translate);
			}	
			else
			{
				Format(STRING(translate), "%T", "Kill_Count", LANG_SERVER, count);
				rp_PrintToChat(client, "%s", translate);
			}	
		}
		
		ForcePlayerSuicide(client);
		
		char name[32];
		rp_GetItemData(itemID, item_name, STRING(name));				
		rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);	
	}
	else if(itemID == 45)
	{
		if(GetClientHealth(client) != 500)
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
				
			rp_SetClientBool(client, b_HasHealthRegen, true);
			
			rp_SetClientBool(client, b_CanUseItem, false);
			CreateTimer(10.0, canItem, client);
			
			char name[32];
			rp_GetItemData(itemID, item_name, STRING(name));			
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}
		else
		{
			Format(STRING(translate), "%T", "AlreadyHaveHp", LANG_SERVER, 500);
			rp_PrintToChat(client, "%s", translate);		
		}	
	}	
	else if(itemID == 46)
	{
		if(Client_GetArmor(client) != 150)
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
				
			Client_SetArmor(client, Client_GetArmor(client) + 25);
				
			char name[32];
			rp_GetItemData(itemID, item_name, STRING(name));					
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}
		else
		{
			Format(STRING(translate), "%T", "AlreadyHaveArmor", LANG_SERVER, 150);
			rp_PrintToChat(client, "%s", translate);		
		}		
	}
	else if(itemID == 47)
	{
		int target = GetClientAimTarget(client, true);
		if(IsClientValid(target))
		{
			if(GetEntityMoveType(target) != MOVETYPE_NONE)
			{
				char model[64];
				Entity_GetModel(target, STRING(model));
				
				if(StrContains(model, "player") != -1 && Distance(client, target) < 200)
				{
					rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);

					SetEntityMoveType(target, MOVETYPE_NONE);
					CreateTimer(3.0, rp_SetDefaultMove, target);
					
					rp_Sound(target, "sound_taser", 1.0);
					rp_Sound(client, "sound_taser", 1.0);
					
					char name[32];
					rp_GetItemData(itemID, item_name, STRING(name));
					Format(STRING(translate), "%T", "Inventory_using", LANG_SERVER, name);
					rp_PrintToChat(client, "%s.", translate);
				}	
				else
				{
					if(Distance(client, target) > 200)
					{
						Format(STRING(translate), "%T", "InvalidDistance", LANG_SERVER);
						rp_PrintToChat(client, "%s.", translate);	
					}
				}
			}
			else
			{
				Format(STRING(translate), "%T", "Target_AlreadyFreeze", LANG_SERVER);
				rp_PrintToChat(client, "%s.", translate);	
			}	
		}
		else
		{
			Format(STRING(translate), "%T", "InvalidTarget", LANG_SERVER);
			rp_PrintToChat(client, "%s.", translate);	
		}		
	}
	else if(itemID == 48)
	{
		if(!rp_GetClientBool(client, b_HasLubrifiant))
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
				
			rp_SetClientBool(client, b_HasLubrifiant, true);
			
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