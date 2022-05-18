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

/***************************************************************************************

							P L U G I N  -  D E F I N E S

***************************************************************************************/
#define JOBID				4

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
	name = "Roleplay - [JOB] Armurerie", 
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

									C L I E N T - S I D E

***************************************************************************************/

public void OnClientAuthorized(int client, const char[] auth) 
{	
	strcopy(steamID[client], sizeof(steamID[]), auth);
}

public void RP_OnInventoryHandle(int client, int itemID)
{
	if(itemID == 1)
	{
		if(GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY) == -1)
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
			
			int wepID;
			if(rp_GetGame() == Engine_CSGO)
				wepID = GivePlayerItem(client, "weapon_hkp2000");
			else if(rp_GetGame() == Engine_CSS)
				wepID = GivePlayerItem(client, "weapon_usp");
			rp_SetClientAmmo(wepID, 0, 0);
			
			char name[32];
			rp_GetItemData(itemID, item_name, STRING(name));
			
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}	
		else
			rp_PrintToChat(client, "%T", "AlreadyHavePistol", LANG_SERVER);
	}
	else if(itemID == 2)
	{
		if(GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY) == -1)
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
			
			int wepID;  
			if(rp_GetGame() == Engine_CSGO)
				wepID = GivePlayerItem(client, "weapon_usp_silencer");
			else if(rp_GetGame() == Engine_CSS)
				wepID = GivePlayerItem(client, "weapon_usp");	
			rp_SetClientAmmo(wepID, 0, 0);
			
			char name[32];
			rp_GetItemData(itemID, item_name, STRING(name));
				
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}	
		else
		 rp_PrintToChat(client, "%T", "AlreadyHavePistol", LANG_SERVER);	
	}	
	else if(itemID == 3)
	{
		if(GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY) == -1)
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
				
			int wepID;
			if(rp_GetGame() == Engine_CSGO)
				wepID = GivePlayerItem(client, "weapon_glock");
			else if(rp_GetGame() == Engine_CSS)
				wepID = GivePlayerItem(client, "weapon_glock");
			rp_SetClientAmmo(wepID, 0, 0);
			
			char name[32];
			rp_GetItemData(itemID, item_name, STRING(name));
				
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}	
		else
		 rp_PrintToChat(client, "%T", "AlreadyHavePistol", LANG_SERVER);	
	}
	else if(itemID == 4)
	{
		if(GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY) == -1)
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
				
			
			int wepID = GivePlayerItem(client, "weapon_p250");
			rp_SetClientAmmo(wepID, 0, 0);
			
			char name[32];
			rp_GetItemData(itemID, item_name, STRING(name));
				
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}	
		else
		 rp_PrintToChat(client, "%T", "AlreadyHavePistol", LANG_SERVER);	
	}
	else if(itemID == 5)
	{
		if(GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY) == -1)
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
				
			
			int wepID = GivePlayerItem(client, "weapon_fiveseven");
			rp_SetClientAmmo(wepID, 0, 0);
			
			char name[32];
			rp_GetItemData(itemID, item_name, STRING(name));
				
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}	
		else
			rp_PrintToChat(client, "%T", "AlreadyHavePistol", LANG_SERVER);
	}
	else if(itemID == 6)
	{
		if(GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY) == -1)
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
				
			
			int wepID = GivePlayerItem(client, "weapon_tec9");
			rp_SetClientAmmo(wepID, 0, 0);
			
			char name[32];
			rp_GetItemData(itemID, item_name, STRING(name));
				
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}	
		else
		 rp_PrintToChat(client, "%T", "AlreadyHavePistol", LANG_SERVER);	
	}
	else if(itemID == 7)
	{
		if(GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY) == -1)
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
			
			int wepID = GivePlayerItem(client, "weapon_cz75a");
			rp_SetClientAmmo(wepID, 0, 0);
			
			char name[32];
			rp_GetItemData(itemID, item_name, STRING(name));
				
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}	
		else
		 rp_PrintToChat(client, "%T", "AlreadyHavePistol", LANG_SERVER);	
	}
	else if(itemID == 8)
	{
		if(GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY) == -1)
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
				
			
			int wepID = GivePlayerItem(client, "weapon_elite");
			rp_SetClientAmmo(wepID, 0, 0);
			
			char name[32];
			rp_GetItemData(itemID, item_name, STRING(name));
				
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}	
		else
		 rp_PrintToChat(client, "%T", "AlreadyHavePistol", LANG_SERVER);	
	}
	else if(itemID == 9)
	{
		if(GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY) == -1)
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
				
			
			int wepID = GivePlayerItem(client, "weapon_deagle");
			rp_SetClientAmmo(wepID, 0, 0);
			
			char name[32];
			rp_GetItemData(itemID, item_name, STRING(name));
				
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}	
		else
		 rp_PrintToChat(client, "%T", "AlreadyHavePistol", LANG_SERVER);	
	}
	else if(itemID == 10)
	{
		if(GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY) == -1)
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
				
			
			int wepID = GivePlayerItem(client, "weapon_revolver");
			rp_SetClientAmmo(wepID, 0, 0);
			
			char name[32];
			rp_GetItemData(itemID, item_name, STRING(name));
				
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}	
		else
		 rp_PrintToChat(client, "%T", "AlreadyHavePistol", LANG_SERVER);	
	}
	else if(itemID == 11)
	{
		if(GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY) == -1)
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
				
			
			int wepID = GivePlayerItem(client, "weapon_mp9");
			rp_SetClientAmmo(wepID, 0, 0);
			
			char name[32];
			rp_GetItemData(itemID, item_name, STRING(name));
				
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}	
		else
		 rp_PrintToChat(client, "%T", "AlreadyHavePistol", LANG_SERVER);	
	}
	else if(itemID == 12)
	{
		if(GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY) == -1)
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
				
			
			int wepID = GivePlayerItem(client, "weapon_mac10");
			rp_SetClientAmmo(wepID, 0, 0);
			
			char name[32];
			rp_GetItemData(itemID, item_name, STRING(name));
				
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}	
		else
		 rp_PrintToChat(client, "%T", "AlreadyHavePistol", LANG_SERVER);	
	}
	else if(itemID == 13)
	{
		if(GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY) == -1)
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
				
			
			int wepID = GivePlayerItem(client, "weapon_ppbizon");
			rp_SetClientAmmo(wepID, 0, 0);
			
			char name[32];
			rp_GetItemData(itemID, item_name, STRING(name));
				
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}	
		else
		 rp_PrintToChat(client, "%T", "AlreadyHavePistol", LANG_SERVER);	
	}
	else if(itemID == 14)
	{
		if(GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY) == -1)
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
				
			
			int wepID = GivePlayerItem(client, "weapon_mp7");
			rp_SetClientAmmo(wepID, 0, 0);
			
			char name[32];
			rp_GetItemData(itemID, item_name, STRING(name));
				
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}	
		else
		 rp_PrintToChat(client, "%T", "AlreadyHavePistol", LANG_SERVER);	
	}
	else if(itemID == 15)
	{
		if(GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY) == -1)
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
				
			
			int wepID = GivePlayerItem(client, "weapon_ump45");
			rp_SetClientAmmo(wepID, 0, 0);
			
			char name[32];
			rp_GetItemData(itemID, item_name, STRING(name));
				
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}	
		else
		 rp_PrintToChat(client, "%T", "AlreadyHavePistol", LANG_SERVER);	
	}
	else if(itemID == 16)
	{
		if(GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY) == -1)
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
				
			
			int wepID = GivePlayerItem(client, "weapon_p90");
			rp_SetClientAmmo(wepID, 0, 0);
			
			char name[32];
			rp_GetItemData(itemID, item_name, STRING(name));
				
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}	
		else
		 rp_PrintToChat(client, "%T", "AlreadyHavePistol", LANG_SERVER);	
	}
	else if(itemID == 17)
	{
		if(GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY) == -1)
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
				
			
			int wepID = GivePlayerItem(client, "weapon_mp5sd");
			rp_SetClientAmmo(wepID, 0, 0);
			
			char name[32];
			rp_GetItemData(itemID, item_name, STRING(name));
				
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}	
		else
		 rp_PrintToChat(client, "%T", "AlreadyHavePistol", LANG_SERVER);	
	}
	else if(itemID == 18)
	{
		if(GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY) == -1)
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
				
			
			int wepID = GivePlayerItem(client, "weapon_famas");
			rp_SetClientAmmo(wepID, 0, 0);
			
			char name[32];
			rp_GetItemData(itemID, item_name, STRING(name));
				
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}	
		else
		 rp_PrintToChat(client, "%T", "AlreadyHavePistol", LANG_SERVER);	
	}
	else if(itemID == 19)
	{
		if(GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY) == -1)
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
				
			
			int wepID = GivePlayerItem(client, "weapon_galilar");
			rp_SetClientAmmo(wepID, 0, 0);
			
			char name[32];
			rp_GetItemData(itemID, item_name, STRING(name));
				
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}	
		else
		 rp_PrintToChat(client, "%T", "AlreadyHavePistol", LANG_SERVER);	
	}
	else if(itemID == 20)
	{
		if(GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY) == -1)
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
				
			
			int wepID = GivePlayerItem(client, "weapon_m4a1");
			rp_SetClientAmmo(wepID, 0, 0);
			
			char name[32];
			rp_GetItemData(itemID, item_name, STRING(name));
				
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}	
		else
		 rp_PrintToChat(client, "%T", "AlreadyHavePistol", LANG_SERVER);	
	}
	else if(itemID == 21)
	{
		if(GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY) == -1)
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
				
			
			int wepID = GivePlayerItem(client, "weapon_m4a1_silencer");
			rp_SetClientAmmo(wepID, 0, 0);
			
			char name[32];
			rp_GetItemData(itemID, item_name, STRING(name));
				
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}	
		else
		 rp_PrintToChat(client, "%T", "AlreadyHavePistol", LANG_SERVER);	
	}
	else if(itemID == 22)
	{
		if(GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY) == -1)
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
				
			
			int wepID = GivePlayerItem(client, "weapon_ak47");
			rp_SetClientAmmo(wepID, 0, 0);
			
			char name[32];
			rp_GetItemData(itemID, item_name, STRING(name));
				
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}	
		else
		 rp_PrintToChat(client, "%T", "AlreadyHavePistol", LANG_SERVER);	
	}
	else if(itemID == 23)
	{
		if(GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY) == -1)
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
				
			
			int wepID = GivePlayerItem(client, "weapon_aug");
			rp_SetClientAmmo(wepID, 0, 0);
			
			char name[32];
			rp_GetItemData(itemID, item_name, STRING(name));
				
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}	
		else
		 rp_PrintToChat(client, "%T", "AlreadyHavePistol", LANG_SERVER);	
	}
	else if(itemID == 24)
	{
		if(GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY) == -1)
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
				
			
			int wepID = GivePlayerItem(client, "weapon_sg553");
			rp_SetClientAmmo(wepID, 0, 0);
			
			char name[32];
			rp_GetItemData(itemID, item_name, STRING(name));
				
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}	
		else
		 rp_PrintToChat(client, "%T", "AlreadyHavePistol", LANG_SERVER);	
	}
	else if(itemID == 25)
	{
		if(GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY) == -1)
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
				
			
			int wepID = GivePlayerItem(client, "weapon_ssg08");
			rp_SetClientAmmo(wepID, 0, 0);
			
			char name[32];
			rp_GetItemData(itemID, item_name, STRING(name));
				
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}	
		else
		 rp_PrintToChat(client, "%T", "AlreadyHavePistol", LANG_SERVER);	
	}
	else if(itemID == 26)
	{
		if(GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY) == -1)
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
				
			
			int wepID = GivePlayerItem(client, "weapon_awp");
			rp_SetClientAmmo(wepID, 0, 0);
			
			char name[32];
			rp_GetItemData(itemID, item_name, STRING(name));
				
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}	
		else
		 rp_PrintToChat(client, "%T", "AlreadyHavePistol", LANG_SERVER);	
	}
	else if(itemID == 27)
	{
		if(GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY) == -1)
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
				
			
			int wepID = GivePlayerItem(client, "weapon_scar20");
			rp_SetClientAmmo(wepID, 0, 0);
			
			char name[32];
			rp_GetItemData(itemID, item_name, STRING(name));
				
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}	
		else
		 rp_PrintToChat(client, "%T", "AlreadyHavePistol", LANG_SERVER);	
	}
	else if(itemID == 28)
	{
		if(GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY) == -1)
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
				
			
			int wepID = GivePlayerItem(client, "weapon_g3sg1");
			rp_SetClientAmmo(wepID, 0, 0);
			
			char name[32];
			rp_GetItemData(itemID, item_name, STRING(name));
				
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}	
		else
		 rp_PrintToChat(client, "%T", "AlreadyHavePistol", LANG_SERVER);	
	}
	else if(itemID == 29)
	{
		if(GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY) == -1)
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
				
			
			int wepID = GivePlayerItem(client, "weapon_nova");
			rp_SetClientAmmo(wepID, 0, 0);
			
			char name[32];
			rp_GetItemData(itemID, item_name, STRING(name));
				
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}	
		else
		 rp_PrintToChat(client, "%T", "AlreadyHavePistol", LANG_SERVER);	
	}
	else if(itemID == 30)
	{
		if(GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY) == -1)
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
				
			
			int wepID = GivePlayerItem(client, "weapon_xm1014");
			rp_SetClientAmmo(wepID, 0, 0);
			
			char name[32];
			rp_GetItemData(itemID, item_name, STRING(name));
				
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}	
		else
		 rp_PrintToChat(client, "%T", "AlreadyHavePistol", LANG_SERVER);	
	}
	else if(itemID == 31)
	{
		if(GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY) == -1)
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
				
			
			int wepID = GivePlayerItem(client, "weapon_mag7");
			rp_SetClientAmmo(wepID, 0, 0);
			
			char name[32];
			rp_GetItemData(itemID, item_name, STRING(name));
				
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}	
		else
		 rp_PrintToChat(client, "%T", "AlreadyHavePistol", LANG_SERVER);	
	}
	else if(itemID == 32)
	{
		if(GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY) == -1)
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
				
			
			int wepID = GivePlayerItem(client, "weapon_sawedoff");
			rp_SetClientAmmo(wepID, 0, 0);
			
			char name[32];
			rp_GetItemData(itemID, item_name, STRING(name));
				
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}	
		else
		 rp_PrintToChat(client, "%T", "AlreadyHavePistol", LANG_SERVER);	
	}
	else if(itemID == 33)
	{
		if(GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY) == -1)
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
				
			
			int wepID = GivePlayerItem(client, "weapon_m249");
			rp_SetClientAmmo(wepID, 0, 0);
			
			char name[32];
			rp_GetItemData(itemID, item_name, STRING(name));
				
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}	
		else
		 rp_PrintToChat(client, "%T", "AlreadyHavePistol", LANG_SERVER);	
	}
	else if(itemID == 34)
	{
		if(GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY) == -1)
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
				
			
			int wepID = GivePlayerItem(client, "weapon_negev");
			rp_SetClientAmmo(wepID, 0, 0);
			
			char name[32];
			rp_GetItemData(itemID, item_name, STRING(name));
				
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}	
		else
			rp_PrintToChat(client, "%T", "AlreadyHavePistol", LANG_SERVER);	
	}
	else if(itemID == 35)
	{
		rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
			
		GivePlayerItem(client, "weapon_knife");
			
		char name[32];
		rp_GetItemData(itemID, item_name, STRING(name));
			
		rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
	}
	else if(itemID == 36)
	{
		rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
			
			
		PrecacheModel("models/props_survival/upgrades/parachutepack.mdl");
		PrecacheModel("models/weapons/v_parachute.mdl");
		PrecacheModel("models/props_survival/parachute/chute.mdl");
		GivePlayerItem(client, "prop_weapon_upgrade_chute");
			
		char name[32];
		rp_GetItemData(itemID, item_name, STRING(name));
				
		rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);	
	}
	else if(itemID == 37)
	{
		rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
			
			
		int iMelee = GivePlayerItem(client, "weapon_axe");
		EquipPlayerWeapon(client, iMelee);
			
		char name[32];
		rp_GetItemData(itemID, item_name, STRING(name));
				
		rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);	
	}
	else if(itemID == 38)
	{
		rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
			
			
		int iMelee = GivePlayerItem(client, "weapon_hammer");
		EquipPlayerWeapon(client, iMelee);
			
		char name[32];
		rp_GetItemData(itemID, item_name, STRING(name));
				
		rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);	
	}
	else if(itemID == 39)
	{
		rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
			
			
		int iMelee = GivePlayerItem(client, "weapon_spanner");
		EquipPlayerWeapon(client, iMelee);
			
		char name[32];
		rp_GetItemData(itemID, item_name, STRING(name));
				
		rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);	
	}
	else if(itemID == 40)
	{
		rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);	
			
		PrecacheModel("models/props_survival/upgrades/upgrade_dz_armor.mdl");	
		GivePlayerItem(client, "prop_weapon_upgrade_armor");
			
		char name[32];
		rp_GetItemData(itemID, item_name, STRING(name));
				
		rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);	
	}
	else if(itemID == 41)
	{
		rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
			
			
		PrecacheModel("models/props_survival/upgrades/upgrade_dz_helmet.mdl");			
		GivePlayerItem(client, "prop_weapon_upgrade_helmet");
			
		char name[32];
		rp_GetItemData(itemID, item_name, STRING(name));
				
		rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);	
	}
	else if(itemID == 42)
	{
		rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
			
			
		PrecacheModel("models/props_survival/upgrades/upgrade_dz_armor_helmet.mdl");			
		GivePlayerItem(client, "prop_weapon_upgrade_armor_helmet");
			
		char name[32];
		rp_GetItemData(itemID, item_name, STRING(name));
				
		rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);	
	}
	else if(itemID == 43)
	{
		rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
			
		SetEntProp(client, Prop_Send, "m_bHasHelmet", true);
		SetEntProp(client, Prop_Send, "m_bHasHeavyArmor", true);
		SetEntProp(client, Prop_Send, "m_bWearingSuit", true);
		SetEntProp(client, Prop_Data, "m_ArmorValue", 200);
			
		char name[32];
		rp_GetItemData(itemID, item_name, STRING(name));
				
		rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);	
	}
}

public void RP_OnClientInteract(int client, int target, const char[] class, const char[] model, const char[] name)
{
	if(StrContains(model, "weapons") != -1)
	{
		int tempIndex = GetEntProp(target, Prop_Send, "m_nFallbackPaintKit");
		int iMelee = -1;
		if(StrEqual(model, "models/weapons/w_axe_dropped.mdl"))
		{
			iMelee = GivePlayerItem(client, "weapon_axe");
		}
		else if(StrEqual(model, "models/weapons/w_hammer_dropped.mdl"))		
		{
			iMelee = GivePlayerItem(client, "weapon_hammer");
		}
		else if(StrEqual(model, "models/weapons/w_spanner_dropped.mdl"))
		{
			iMelee = GivePlayerItem(client, "weapon_spanner");
		}
		else if(StrEqual(model, "models/weapons/w_knife_default_t_dropped.mdl"))
		{
			iMelee = GivePlayerItem(client, "weapon_knife_t");
		}
		else if(StrEqual(model, "models/weapons/w_knife_default_ct_dropped.mdl"))
		{
			iMelee = GivePlayerItem(client, "weapon_knife_ct");
		}
		else if(StrEqual(model, "models/weapons/w_knife_gg.mdl"))
		{
			iMelee = GivePlayerItem(client, "weapon_knifegg");
		}
		else if(StrEqual(model, "models/weapons/w_knife_ghost.mdl"))
		{
			iMelee = GivePlayerItem(client, "weapon_knife_ghost");
		}
		else if(StrEqual(model, "models/weapons/w_knife_bayonet_dropped.mdl"))
		{
			iMelee = GivePlayerItem(client, "weapon_bayonet");
		}
		else if(StrEqual(model, "models/weapons/w_knife_butterfly_dropped.mdl"))
		{
			iMelee = GivePlayerItem(client, "weapon_knife_butterfly");
		}
		else if(StrEqual(model, "models/weapons/w_knife_falchion_advanced_dropped.mdl"))
		{
			iMelee = GivePlayerItem(client, "weapon_knife_falchion");	
		}
		else if(StrEqual(model, "models/weapons/w_knife_flip_dropped.mdl"))
		{
			iMelee = GivePlayerItem(client, "weapon_knife_flip");
		}
		else if(StrEqual(model, "models/weapons/w_knife_gut_dropped.mdl"))
		{
			iMelee = GivePlayerItem(client, "weapon_knife_gut");
		}
		else if(StrEqual(model, "models/weapons/w_knife_tactical_dropped.mdl"))
		{
			iMelee = GivePlayerItem(client, "weapon_knife_tactical");
		}
		else if(StrEqual(model, "models/weapons/w_knife_karam_dropped.mdl"))
		{
			iMelee = GivePlayerItem(client, "weapon_knife_karambit");
		}
		else if(StrEqual(model, "models/weapons/w_knife_m9_bay_dropped.mdl"))
		{
			iMelee = GivePlayerItem(client, "weapon_knife_m9_bayonet");
		}
		else if(StrEqual(model, "models/weapons/w_knife_push_dropped.mdl"))
		{
			iMelee = GivePlayerItem(client, "weapon_knife_push");
		}
		else if(StrEqual(model, "models/weapons/w_knife_survival_bowie_dropped.mdl"))
		{
			iMelee = GivePlayerItem(client, "weapon_knife_survival_bowie");
		}
		else if(StrEqual(model, "models/weapons/w_knife_ursus_dropped.mdl"))
		{
			iMelee = GivePlayerItem(client, "weapon_knife_ursus");
		}
		else if(StrEqual(model, "models/weapons/w_knife_gypsy_jackknife_dropped.mdl"))
		{
			iMelee = GivePlayerItem(client, "weapon_knife_gypsy_jackknife");
		}
		else if(StrEqual(model, "models/weapons/w_knife_stiletto_dropped.mdl"))
		{
			iMelee = GivePlayerItem(client, "weapon_knife_stiletto");
		}
		else if(StrEqual(model, "models/weapons/w_knife_widowmaker_dropped.mdl"))
		{
			iMelee = GivePlayerItem(client, "weapon_knife_widowmaker");
		}
		else if(StrEqual(model, "models/weapons/w_knife_css_dropped.mdl"))
		{
			iMelee = GivePlayerItem(client, "weapon_knife_css");
		}
		else if(StrEqual(model, "models/weapons/w_knife_skeleton_dropped.mdl"))
		{
			iMelee = GivePlayerItem(client, "weapon_knife_skeleton");
		}
		else if(StrEqual(model, "models/weapons/w_knife_cord_dropped.mdl"))
		{
			iMelee = GivePlayerItem(client, "weapon_knife_cord");
		}
		else if(StrEqual(model, "models/weapons/w_knife_canis_dropped.mdl"))
		{
			iMelee = GivePlayerItem(client, "weapon_knife_canis");
		}
		
		RemoveEdict(target);
		EquipPlayerWeapon(client, iMelee);
		SetEntPropEnt(client, Prop_Data, "m_hActiveWeapon", iMelee);
		ChangeEdictState(client, FindDataMapInfo(client, "m_hActiveWeapon"));
		
		RP_SetWeaponPattern(client, tempIndex);
	}	
	
	/*if(rp_GetNPCType(target) == JOBID)
	{
		if(Distance(client, target) <= 80.0)
			rp_PerformNPCSell(client, JOBID);
		else
			Translation_PrintTooFar(client);
	}*/
}

public void RP_OnNPCInteract(int client, int entity, int jobid)
{
	if(jobid == JOBID)
	{
		if(Distance(client, entity) <= 80.0)
			rp_PerformNPCSell(client, JOBID);
		else
			Translation_PrintTooFar(client);
	}
}