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
#define JOBID				12

/***************************************************************************************

							G L O B A L  -  V A R S

***************************************************************************************/

char steamID[MAXPLAYERS + 1][32];
Database g_DB;

enum struct Clothes{
	int iMask;
	int iHat;
}
Clothes clothe[MAXPLAYERS + 1];

// Methodmap Constructor
Roleplay m_iClient[MAXPLAYERS + 1];
/***************************************************************************************

							P L U G I N  -  I N F O

***************************************************************************************/
public Plugin myinfo = 
{
	name = "Roleplay - [JOB] Skin", 
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

public Action View3rd(Handle timer, any client)
{
	if(IsClientValid(client))
	{
		if(!Client_IsInThirdPersonMode(client))
		{
			CreateTimer(5.0, View3rd, client);	
			Client_SetThirdPersonMode(client, true);
		}
		else
			Client_SetThirdPersonMode(client, false);
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

public void OnClientDisconnect(int client)
{
	rp_SetClientString(client, sz_Skin, "", 0);
	clothe[client].iHat = 0;
}	

public void OnClientPutInServer(int client)
{
	rp_SetClientString(client, sz_Skin, "", 0);
	clothe[client].iHat = 0;
	
	// MethodMap Constructor
	m_iClient[client] = Roleplay(client);
}	

public void RP_OnInventoryHandle(int client, int itemID)
{
	char translate[128], currentSkin[256];
	rp_GetClientString(client, sz_Skin, STRING(currentSkin));
	
	#if DEBUG
		PrintToServer(currentSkin);
	#endif
	
	char name[32];
	rp_GetItemData(itemID, item_name, STRING(name));
	
	if(itemID == 65)
	{
		char item_skin[256];
		GetSkinModel(itemID, item_skin);
		
		if(!StrEqual(currentSkin, item_skin))
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);			
		
			rp_SetClientString(client, sz_Skin, STRING(item_skin));
			m_iClient[client].SetSkin();
			CreateTimer(1.0, View3rd, client);

			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}
		else
		{
			Format(STRING(translate), "%T", "AlreadyHaveSkin", LANG_SERVER, name);
			rp_PrintToChat(client, "%s.", translate);
		}
	}	
	else if(itemID == 66)
	{
		char item_skin[256];
		GetSkinModel(itemID, item_skin);
		
		if(!StrEqual(currentSkin, item_skin))
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);			
		
			rp_SetClientString(client, sz_Skin, STRING(item_skin));
			m_iClient[client].SetSkin();
			CreateTimer(1.0, View3rd, client);

			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}	
		else
		{
			Format(STRING(translate), "%T", "AlreadyHaveSkin", LANG_SERVER, name);
			rp_PrintToChat(client, "%s.", translate);
		}
	}
	else if(itemID == 67)
	{
		char item_skin[256];
		GetSkinModel(itemID, item_skin);
		
		if(!StrEqual(currentSkin, item_skin))
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);			
		
			rp_SetClientString(client, sz_Skin, STRING(item_skin));
			m_iClient[client].SetSkin();
			CreateTimer(1.0, View3rd, client);
						
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}	
		else
		{
			Format(STRING(translate), "%T", "AlreadyHaveSkin", LANG_SERVER, name);
			rp_PrintToChat(client, "%s.", translate);
		}
	}
	else if(itemID == 68)
	{
		char item_skin[256];
		GetSkinModel(itemID, item_skin);
		
		if(!StrEqual(currentSkin, item_skin))
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);	
		
			rp_SetClientString(client, sz_Skin, STRING(item_skin));
			m_iClient[client].SetSkin();
			CreateTimer(1.0, View3rd, client);
							
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}	
		else
		{
			Format(STRING(translate), "%T", "AlreadyHaveSkin", LANG_SERVER, name);
			rp_PrintToChat(client, "%s.", translate);
		}
	}
	else if(itemID == 69)
	{
		char item_skin[256];
		GetSkinModel(itemID, item_skin);
		
		if(!StrEqual(currentSkin, item_skin))
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
		
			rp_SetClientString(client, sz_Skin, STRING(item_skin));
			m_iClient[client].SetSkin();
			CreateTimer(1.0, View3rd, client);
						
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}	
		else
		{
			Format(STRING(translate), "%T", "AlreadyHaveSkin", LANG_SERVER, name);
			rp_PrintToChat(client, "%s.", translate);
		}
	}
	else if(itemID == 70)
	{
		char item_skin[256];
		GetSkinModel(itemID, item_skin);
		
		if(!StrEqual(currentSkin, item_skin))
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);	
		
			rp_SetClientString(client, sz_Skin, STRING(item_skin));
			m_iClient[client].SetSkin();
			CreateTimer(1.0, View3rd, client);
					
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}	
		else
		{
			Format(STRING(translate), "%T", "AlreadyHaveSkin", LANG_SERVER, name);
			rp_PrintToChat(client, "%s.", translate);
		}
	}
	else if(itemID == 71)
	{
		char item_skin[256];
		GetSkinModel(itemID, item_skin);
		
		if(!StrEqual(currentSkin, item_skin))
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
		
			rp_SetClientString(client, sz_Skin, STRING(item_skin));
			m_iClient[client].SetSkin();
			CreateTimer(1.0, View3rd, client);
						
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}	
		else
		{
			Format(STRING(translate), "%T", "AlreadyHaveSkin", LANG_SERVER, name);
			rp_PrintToChat(client, "%s.", translate);
		}
	}
	else if(itemID == 72)
	{
		char item_skin[256];
		GetSkinModel(itemID, item_skin);
		
		if(!StrEqual(currentSkin, item_skin))
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);	
		
			rp_SetClientString(client, sz_Skin, STRING(item_skin));
			m_iClient[client].SetSkin();
			CreateTimer(1.0, View3rd, client);
					
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}	
		else
		{
			Format(STRING(translate), "%T", "AlreadyHaveSkin", LANG_SERVER, name);
			rp_PrintToChat(client, "%s.", translate);
		}
	}
	else if(itemID == 73)
	{
		char item_skin[256];
		GetSkinModel(itemID, item_skin);
		
		if(!StrEqual(currentSkin, item_skin))
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
		
			rp_SetClientString(client, sz_Skin, STRING(item_skin));
			m_iClient[client].SetSkin();
			CreateTimer(1.0, View3rd, client);
						
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}	
		else
		{
			Format(STRING(translate), "%T", "AlreadyHaveSkin", LANG_SERVER, name);
			rp_PrintToChat(client, "%s.", translate);
		}
	}
	else if(itemID == 74)
	{
		char item_skin[256];
		GetSkinModel(itemID, item_skin);
		
		if(!StrEqual(currentSkin, item_skin))
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
		
			rp_SetClientString(client, sz_Skin, STRING(item_skin));
			m_iClient[client].SetSkin();
			CreateTimer(1.0, View3rd, client);
							
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}	
		else
		{
			Format(STRING(translate), "%T", "AlreadyHaveSkin", LANG_SERVER, name);
			rp_PrintToChat(client, "%s.", translate);
		}
	}
	else if(itemID == 75)
	{
		if(rp_CanSpawnKnife(client))
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
			
			int knife = GivePlayerItem(client, "weapon_knife_ghost");
			EquipPlayerWeapon(client, knife);
								
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}
		else
		{
			Format(STRING(translate), "%T", "AlreadyHaveKnife", LANG_SERVER);
			rp_PrintToChat(client, "%s.", translate);	
		}		
	}
	else if(itemID == 76)
	{
		if(rp_CanSpawnKnife(client))
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
			
			
			int knife = GivePlayerItem(client, "weapon_bayonet");
			EquipPlayerWeapon(client, knife);
								
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}
		else
		{
			Format(STRING(translate), "%T", "AlreadyHaveKnife", LANG_SERVER);
			rp_PrintToChat(client, "%s.", translate);	
		}	
	}
	else if(itemID == 77)
	{
		if(rp_CanSpawnKnife(client))
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
			
			
			int knife = GivePlayerItem(client, "weapon_knife_butterfly");
			EquipPlayerWeapon(client, knife);
								
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}
		else
		{
			Format(STRING(translate), "%T", "AlreadyHaveKnife", LANG_SERVER);
			rp_PrintToChat(client, "%s.", translate);	
		}	
	}
	else if(itemID == 78)
	{
		if(rp_CanSpawnKnife(client))
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
			
			
			int knife = GivePlayerItem(client, "weapon_knife_falchion");
			EquipPlayerWeapon(client, knife);
								
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}
		else
		{
			Format(STRING(translate), "%T", "AlreadyHaveKnife", LANG_SERVER);
			rp_PrintToChat(client, "%s.", translate);	
		}	
	}
	else if(itemID == 79)
	{
		if(rp_CanSpawnKnife(client))
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
			
			
			int knife = GivePlayerItem(client, "weapon_knife_flip");
			EquipPlayerWeapon(client, knife);
								
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}
		else
		{
			Format(STRING(translate), "%T", "AlreadyHaveKnife", LANG_SERVER);
			rp_PrintToChat(client, "%s.", translate);	
		}	
	}
	else if(itemID == 80)
	{
		if(rp_CanSpawnKnife(client))
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);	
			
			int knife = GivePlayerItem(client, "weapon_knife_gut");
			EquipPlayerWeapon(client, knife);
								
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}
		else
		{
			Format(STRING(translate), "%T", "AlreadyHaveKnife", LANG_SERVER);
			rp_PrintToChat(client, "%s.", translate);	
		}	
	}
	else if(itemID == 81)
	{
		if(rp_CanSpawnKnife(client))
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
			
			
			int knife = GivePlayerItem(client, "weapon_knife_tactical");
			EquipPlayerWeapon(client, knife);
								
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}
		else
		{
			Format(STRING(translate), "%T", "AlreadyHaveKnife", LANG_SERVER);
			rp_PrintToChat(client, "%s.", translate);	
		}	
	}
	else if(itemID == 82)
	{
		if(rp_CanSpawnKnife(client))
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
			
			
			int knife = GivePlayerItem(client, "weapon_knife_karambit");
			EquipPlayerWeapon(client, knife);
								
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}
		else
		{
			Format(STRING(translate), "%T", "AlreadyHaveKnife", LANG_SERVER);
			rp_PrintToChat(client, "%s.", translate);	
		}	
	}
	else if(itemID == 83)
	{
		if(rp_CanSpawnKnife(client))
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
			
			
			int knife = GivePlayerItem(client, "weapon_knife_m9_bayonet");
			EquipPlayerWeapon(client, knife);
								
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}
		else
		{
			Format(STRING(translate), "%T", "AlreadyHaveKnife", LANG_SERVER);
			rp_PrintToChat(client, "%s.", translate);	
		}	
	}
	else if(itemID == 84)
	{
		if(rp_CanSpawnKnife(client))
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
			
			
			int knife = GivePlayerItem(client, "weapon_knife_push");
			EquipPlayerWeapon(client, knife);
								
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}
		else
		{
			Format(STRING(translate), "%T", "AlreadyHaveKnife", LANG_SERVER);
			rp_PrintToChat(client, "%s.", translate);	
		}	
	}
	else if(itemID == 85)
	{
		if(rp_CanSpawnKnife(client))
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
			
			
			int knife = GivePlayerItem(client, "weapon_knife_survival_bowie");
			EquipPlayerWeapon(client, knife);
								
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}
		else
		{
			Format(STRING(translate), "%T", "AlreadyHaveKnife", LANG_SERVER);
			rp_PrintToChat(client, "%s.", translate);	
		}	
	}
	else if(itemID == 86)
	{
		if(rp_CanSpawnKnife(client))
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
			
			
			int knife = GivePlayerItem(client, "weapon_knife_ursus");
			EquipPlayerWeapon(client, knife);
								
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}
		else
		{
			Format(STRING(translate), "%T", "AlreadyHaveKnife", LANG_SERVER);
			rp_PrintToChat(client, "%s.", translate);	
		}	
	}
	else if(itemID == 87)
	{
		if(rp_CanSpawnKnife(client))
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
			
			
			int knife = GivePlayerItem(client, "weapon_knife_gypsy_jackknife");
			EquipPlayerWeapon(client, knife);
								
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}
		else
		{
			Format(STRING(translate), "%T", "AlreadyHaveKnife", LANG_SERVER);
			rp_PrintToChat(client, "%s.", translate);	
		}	
	}
	else if(itemID == 88)
	{
		if(rp_CanSpawnKnife(client))
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
			
			
			int knife = GivePlayerItem(client, "weapon_knife_stiletto");
			EquipPlayerWeapon(client, knife);
								
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}
		else
		{
			Format(STRING(translate), "%T", "AlreadyHaveKnife", LANG_SERVER);
			rp_PrintToChat(client, "%s.", translate);	
		}	
	}
	else if(itemID == 89)
	{
		if(rp_CanSpawnKnife(client))
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
			
			
			int knife = GivePlayerItem(client, "weapon_knife_widowmaker");
			EquipPlayerWeapon(client, knife);
								
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}
		else
		{
			Format(STRING(translate), "%T", "AlreadyHaveKnife", LANG_SERVER);
			rp_PrintToChat(client, "%s.", translate);	
		}	
	}
	else if(itemID == 90)
	{
		if(rp_CanSpawnKnife(client))
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
			
			
			int knife = GivePlayerItem(client, "weapon_knife_css");
			EquipPlayerWeapon(client, knife);
								
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}
		else
		{
			Format(STRING(translate), "%T", "AlreadyHaveKnife", LANG_SERVER);
			rp_PrintToChat(client, "%s.", translate);	
		}	
	}
	else if(itemID == 91)
	{
		if(rp_CanSpawnKnife(client))
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
			
			
			int knife = GivePlayerItem(client, "weapon_knife_skeleton");
			EquipPlayerWeapon(client, knife);
								
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}
		else
		{
			Format(STRING(translate), "%T", "AlreadyHaveKnife", LANG_SERVER);
			rp_PrintToChat(client, "%s.", translate);	
		}	
	}
	else if(itemID == 92)
	{
		if(rp_CanSpawnKnife(client))
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
			
			
			int knife = GivePlayerItem(client, "weapon_knife_cord");
			EquipPlayerWeapon(client, knife);
								
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}
		else
		{
			Format(STRING(translate), "%T", "AlreadyHaveKnife", LANG_SERVER);
			rp_PrintToChat(client, "%s.", translate);	
		}	
	}
	else if(itemID == 93)
	{
		if(rp_CanSpawnKnife(client))
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
			
			
			int knife = GivePlayerItem(client, "weapon_knife_canis");
			EquipPlayerWeapon(client, knife);
								
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}
		else
		{
			Format(STRING(translate), "%T", "AlreadyHaveKnife", LANG_SERVER);
			rp_PrintToChat(client, "%s.", translate);	
		}	
	}
	else if(itemID == 94)
	{
		if(rp_CanSpawnKnife(client))
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
			
			
			int knife = GivePlayerItem(client, "weapon_knifegg");
			EquipPlayerWeapon(client, knife);
								
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}
		else
		{
			Format(STRING(translate), "%T", "AlreadyHaveKnife", LANG_SERVER);
			rp_PrintToChat(client, "%s.", translate);	
		}	
	}
	else if(itemID == 95)
	{
		if(rp_CanUsePattern(client, 344))
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
			
			
			RP_SetWeaponPattern(client, 344);
								
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}
		else
		{
			Format(STRING(translate), "%T", "AlreadyHavePattern", LANG_SERVER, name);
			rp_PrintToChat(client, "%s.", translate);	
		}	
	}
	else if(itemID == 96)
	{
		if(rp_CanUsePattern(client, 301))
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
			
			
			RP_SetWeaponPattern(client, 301);
								
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}
		else
		{
			Format(STRING(translate), "%T", "AlreadyHavePattern", LANG_SERVER, name);
			rp_PrintToChat(client, "%s.", translate);	
		}	
	}
	else if(itemID == 97)
	{
		if(rp_CanUsePattern(client, 279))
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
			
			
			RP_SetWeaponPattern(client, 279);
								
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}
		else
		{
			Format(STRING(translate), "%T", "AlreadyHavePattern", LANG_SERVER, name);
			rp_PrintToChat(client, "%s.", translate);	
		}	
	}
	else if(itemID == 98)
	{
		if(rp_CanUsePattern(client, 524))
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
			
			
			RP_SetWeaponPattern(client, 524);
								
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}
		else
		{
			Format(STRING(translate), "%T", "AlreadyHavePattern", LANG_SERVER, name);
			rp_PrintToChat(client, "%s.", translate);	
		}	
	}
	else if(itemID == 99)
	{
		if(rp_CanUsePattern(client, 44))
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
			
			
			RP_SetWeaponPattern(client, 44);
								
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}
		else
		{
			Format(STRING(translate), "%T", "AlreadyHavePattern", LANG_SERVER, name);
			rp_PrintToChat(client, "%s.", translate);	
		}	
	}
	else if(itemID == 100)
	{
		if(rp_CanUsePattern(client, 445))
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
			
			
			RP_SetWeaponPattern(client, 445);
								
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}
		else
		{
			Format(STRING(translate), "%T", "AlreadyHavePattern", LANG_SERVER, name);
			rp_PrintToChat(client, "%s.", translate);	
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

stock void GetSkinModel(int itemID, char model[256])
{
	KeyValues kv = new KeyValues("Skins");

	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, STRING(sPath), "data/roleplay/skins.cfg");
	
	Kv_CheckIfFileExist(kv, sPath);
	
	char kv_item[16];
	IntToString(itemID, STRING(kv_item));
	if(kv.JumpToKey(kv_item))
	{	
		kv.GetString("model", STRING(model));
		#if DEBUG
			PrintToServer(model);
		#endif
	}	
	
	kv.Rewind();
	delete kv;
}	

stock void GetSkinArms(int itemID, char[] buffer, int maxlength)
{
	KeyValues kv = new KeyValues("Skins");

	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, STRING(sPath), "data/roleplay/skins.cfg");
	
	Kv_CheckIfFileExist(kv, sPath);
	
	char kv_item[16];
	IntToString(itemID, STRING(kv_item));
	if(kv.JumpToKey(kv_item))
	{	
		kv.GetString("arms", buffer, sizeof(maxlength));
	}	
	
	kv.Rewind();
	delete kv;
}

void CreateHat(int client, char[] model)
{
	if(clothe[client].iHat != 0)
	{
		// Calculate the final position and angles for the hat
		float m_fHatOrigin[3];
		float m_fHatAngles[3];
		float m_fForward[3];
		float m_fRight[3];
		float m_fUp[3];
		GetClientAbsOrigin(client, m_fHatOrigin);
		GetClientAbsAngles(client, m_fHatAngles);
		
		m_fHatOrigin[2] -= 4.0;
		
		
		/*m_fHatAngles[0] += g_eHats[m_iData][fAngles][0];
		m_fHatAngles[1] += g_eHats[m_iData][fAngles][1];
		m_fHatAngles[2] += g_eHats[m_iData][fAngles][2];*/

		float m_fOffset[3];
		/*m_fOffset[0] = g_eHats[m_iData][fPosition][0];
		m_fOffset[1] = g_eHats[m_iData][fPosition][1];
		m_fOffset[2] = g_eHats[m_iData][fPosition][2];*/

		GetAngleVectors(m_fHatAngles, m_fForward, m_fRight, m_fUp);

		m_fHatOrigin[0] += m_fRight[0]*m_fOffset[0]+m_fForward[0]*m_fOffset[1]+m_fUp[0]*m_fOffset[2];
		m_fHatOrigin[1] += m_fRight[1]*m_fOffset[0]+m_fForward[1]*m_fOffset[1]+m_fUp[1]*m_fOffset[2];
		m_fHatOrigin[2] += m_fRight[2]*m_fOffset[0]+m_fForward[2]*m_fOffset[1]+m_fUp[2]*m_fOffset[2];
		
		// Create the hat entity
		int m_iEnt = CreateEntityByName("prop_dynamic_override");
		PrecacheModel(model);
		DispatchKeyValue(m_iEnt, "model", model);
		DispatchKeyValue(m_iEnt, "spawnflags", "256");
		DispatchKeyValue(m_iEnt, "solid", "0");
		SetEntPropEnt(m_iEnt, Prop_Send, "m_hOwnerEntity", client);
		
		DispatchSpawn(m_iEnt);	
		AcceptEntityInput(m_iEnt, "TurnOn", m_iEnt, m_iEnt, 0);
		
		// We don't want the client to see his own hat
		//SDKHook(m_iEnt, SDKHook_SetTransmit, Hook_SetTransmit);
		
		// Teleport the hat to the right position and attach it
		TeleportEntity(m_iEnt, m_fHatOrigin, m_fHatAngles, NULL_VECTOR); 
		
		SetVariantString("!activator");
		AcceptEntityInput(m_iEnt, "SetParent", client, m_iEnt, 0);
		
		SetVariantString("facemask");
		AcceptEntityInput(m_iEnt, "SetParentAttachmentMaintainOffset", m_iEnt, m_iEnt, 0);
		clothe[client].iHat = m_iEnt;
	}
}