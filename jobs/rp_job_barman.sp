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

							P L U G I N  -  I N C L U D E S

***************************************************************************************/
#include <roleplay_csgo.inc>

/***************************************************************************************

							P L U G I N  -  D E F I N E S

***************************************************************************************/

#define JOBID	20

/***************************************************************************************

							G L O B A L  -  V A R S

***************************************************************************************/

char steamID[MAXPLAYERS + 1][32];
Database g_DB;

int Alcohol[MAXPLAYERS + 1];

/***************************************************************************************

							P L U G I N  -  I N F O

***************************************************************************************/
public Plugin myinfo = 
{
	name = "Roleplay - [JOB] Barman", 
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
0..
									C L I E N T - S I D E

***************************************************************************************/

public void OnClientPutInServer(int client)
{
	rp_SetClientFloat(client, fl_Soif, 5.0);
	Alcohol[client] = 0;
}	

public void OnClientAuthorized(int client, const char[] auth) 
{	
	strcopy(steamID[client], sizeof(steamID[]), auth);
}

public void RP_OnInventoryHandle(int client, int itemID)
{
	char translate[128];
	
	if(itemID == 158)
	{
		if(rp_GetClientFloat(client, fl_Soif) <= 100.0)
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
										
			rp_SetClientFloat(client, fl_Soif, rp_GetClientFloat(client, fl_Soif) + 5.0);
			if(rp_GetClientFloat(client, fl_Soif) + 5.0 >= 100.0)
				rp_SetClientFloat(client, fl_Soif, 100.0);
			//CheckSpeed(client); TODO
			
			rp_Sound(client, "sound_burp", 0.5);
			
			Alcohol[client]++;
			
			if(Alcohol[client] == 5)
				rp_PrintToChat(client, "Buvez avec modération pour éviter les problèmes de santer {lightred}!");
			
			char name[32];
			rp_GetItemData(itemID, item_name, STRING(name));				
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);	
		}	
		else
		{
			Format(STRING(translate), "%T", "NotDrink", LANG_SERVER);
			rp_PrintToChat(client, "%s.", translate);	
		}	
	}
	else if(itemID == 159)
	{
		if(rp_GetClientFloat(client, fl_Soif) <= 100.0)
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
										
			rp_SetClientFloat(client, fl_Soif, rp_GetClientFloat(client, fl_Soif) + 2.0);
			if(rp_GetClientFloat(client, fl_Soif) + 2.0 >= 100.0)
				rp_SetClientFloat(client, fl_Soif, 100.0);
			//CheckSpeed(client); TODO
			rp_Sound(client, "sound_burp", 0.5);
			
			char name[32];
			rp_GetItemData(itemID, item_name, STRING(name));				
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);	
		}	
		else
		{
			Format(STRING(translate), "%T", "NotDrink", LANG_SERVER);
			rp_PrintToChat(client, "%s.", translate);	
		}	
	}
	else if(itemID == 160)
	{
		if(rp_GetClientFloat(client, fl_Soif) <= 100.0)
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
										
			rp_SetClientFloat(client, fl_Soif, rp_GetClientFloat(client, fl_Soif) + 7.0);
			if(rp_GetClientFloat(client, fl_Soif) + 7.0 >= 100.0)
				rp_SetClientFloat(client, fl_Soif, 100.0);
			//CheckSpeed(client); TODO
			rp_Sound(client, "sound_burp", 0.5);
			
			char name[32];
			rp_GetItemData(itemID, item_name, STRING(name));				
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);	
		}	
		else
		{
			Format(STRING(translate), "%T", "NotDrink", LANG_SERVER);
			rp_PrintToChat(client, "%s.", translate);	
		}	
	}
	else if(itemID == 161)
	{
		if(rp_GetClientFloat(client, fl_Soif) <= 100.0)
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
										
			rp_SetClientFloat(client, fl_Soif, rp_GetClientFloat(client, fl_Soif) + 1.0);
			if(rp_GetClientFloat(client, fl_Soif) + 1.0 >= 100.0)
				rp_SetClientFloat(client, fl_Soif, 100.0);
			//CheckSpeed(client); TODO
			rp_Sound(client, "sound_burp", 0.5);
			
			char name[32];
			rp_GetItemData(itemID, item_name, STRING(name));				
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);	
		}	
		else
		{
			Format(STRING(translate), "%T", "NotDrink", LANG_SERVER);
			rp_PrintToChat(client, "%s.", translate);	
		}	
	}
	else if(itemID == 162)
	{
		if(rp_GetClientFloat(client, fl_Soif) <= 100.0)
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
										
			rp_SetClientFloat(client, fl_Soif, rp_GetClientFloat(client, fl_Soif) + 10.0);
			if(rp_GetClientFloat(client, fl_Soif) + 10.0 >= 100.0)
				rp_SetClientFloat(client, fl_Soif, 100.0);
			//CheckSpeed(client); TODO
			rp_Sound(client, "sound_burp", 0.5);
			
			Alcohol[client]++;
			
			if(Alcohol[client] == 5)
				rp_PrintToChat(client, "Buvez avec modération pour éviter les problèmes de santer {lightred}!");
			
			char name[32];
			rp_GetItemData(itemID, item_name, STRING(name));				
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);	
		}	
		else
		{
			Format(STRING(translate), "%T", "NotDrink", LANG_SERVER);
			rp_PrintToChat(client, "%s.", translate);	
		}	
	}
}

public void RP_OnClientDeath(int attacker, int victim, const char[] weapon, bool headshot)
{
	if (rp_GetClientFloat(victim, fl_Soif) == 0)
	{
		rp_SetClientFloat(victim, fl_Soif, 5.0);
		CPrintToChat(victim, "%s Vous devez boire pour ne pas mourir de soif !");
		PrintCenterText(victim, "Allez boire !!");
	}
	
	Alcohol[victim] = 0;
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