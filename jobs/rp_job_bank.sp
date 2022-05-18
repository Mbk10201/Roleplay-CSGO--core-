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
#define JOBID 9

/***************************************************************************************

							G L O B A L  -  V A R S

***************************************************************************************/

char steamID[MAXPLAYERS + 1][32];
Database g_DB;

enum struct Cookie_Forward {
	Cookie BankCard;
	Cookie RIB;
	Cookie Licence_Sell;
	Cookie Licence_PrimaryWeapon;
	Cookie Licence_SecondaryWeapon;
}	
Cookie_Forward cookie;

/***************************************************************************************

							P L U G I N  -  I N F O

***************************************************************************************/
public Plugin myinfo = 
{
	name = "Roleplay - [JOB] Bank", 
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
	
	/*----------------------------------Cookies-------------------------------*/
	cookie.BankCard = new Cookie("rpv_bankcard", "Carte banquaire [ON / OFF]", CookieAccess_Protected);
	cookie.RIB = new Cookie("rpv_rib", "RIB [ON / OFF]", CookieAccess_Protected);
	cookie.Licence_Sell = new Cookie("rpv_licence_sell", "Permis vente [ON / OFF]", CookieAccess_Protected);
	cookie.Licence_PrimaryWeapon = new Cookie("rpv_licence_primaryweapon", "Permis armes primaires[ON / OFF]", CookieAccess_Protected);
	cookie.Licence_SecondaryWeapon = new Cookie("rpv_licence_secondaryweapon", "Permis armes secondaires [ON / OFF]", CookieAccess_Protected);
	/*------------------------------------------------------------------------*/		
}

// Init SQL
public void RP_OnSQLInit(Database db)
{
	g_DB = db;
}

/***************************************************************************************

									C L I E N T - S I D E

***************************************************************************************/

public void OnClientPostAdminCheck(int client) 
{	
	char buffer[8];
	
	/*-------------------------------------------*/
	cookie.BankCard.Get(client, STRING(buffer));
	rp_SetClientBool(client, b_HasBankCard, view_as<bool>(StringToInt(buffer)));
	
	/*-------------------------------------------*/
	cookie.RIB.Get(client, STRING(buffer));
	rp_SetClientBool(client, b_HasRib, view_as<bool>(StringToInt(buffer)));
	
	/*-------------------------------------------*/
	cookie.Licence_Sell.Get(client, STRING(buffer));
	rp_SetClientBool(client, b_HasSellLicence, view_as<bool>(StringToInt(buffer)));
	
	/*-------------------------------------------*/
	cookie.Licence_PrimaryWeapon.Get(client, STRING(buffer));
	rp_SetClientBool(client, b_HasPrimaryWeaponLicence, view_as<bool>(StringToInt(buffer)));
	
	/*-------------------------------------------*/
	cookie.Licence_SecondaryWeapon.Get(client, STRING(buffer));
	rp_SetClientBool(client, b_HasSecondaryWeaponLicence, view_as<bool>(StringToInt(buffer)));
}

public void OnClientAuthorized(int client, const char[] auth) 
{	
	strcopy(steamID[client], sizeof(steamID[]), auth);
}

public void RP_OnClientDeath(int attacker, int victim, const char[] weapon, bool headshot)
{
	int random = GetRandomInt(100, 200);
	if(random == 140)
	{
		if(rp_GetClientBool(victim, b_HasSellLicence))
		{
			rp_SetClientBool(victim, b_HasSellLicence, false);
			cookie.Licence_Sell.Set(victim, "");
		}	
		if(rp_GetClientBool(victim, b_HasCarLicence))
		{
			rp_SetClientBool(victim, b_HasCarLicence, false);
			Cookie.Find("rpv_licence_car").Set(victim, "0");
		}
		if(rp_GetClientBool(victim, b_HasPrimaryWeaponLicence))
		{
			rp_SetClientBool(victim, b_HasPrimaryWeaponLicence, false);
			SetClientCookie(victim, cookie.Licence_PrimaryWeapon, "0");
		}
		if(rp_GetClientBool(victim, b_HasSecondaryWeaponLicence))
		{
			rp_SetClientBool(victim, b_HasSecondaryWeaponLicence, false);
			SetClientCookie(victim, cookie.Licence_SecondaryWeapon, "0");
		}
		if(rp_GetClientBool(victim, b_HasRib))
		{
			rp_SetClientBool(victim, b_HasRib, false);
			SetClientCookie(victim, cookie.RIB, "0");
		}
		if(rp_GetClientBool(victim, b_HasBankCard))
		{
			rp_SetClientBool(victim, b_HasBankCard, false);
			SetClientCookie(victim, cookie.BankCard, "0");
		}

		rp_PrintToChat(victim, "Pas de chance, vous avez perdu votre portefeuille.");
	}	
}	

public void RP_OnInventoryHandle(int client, int itemID)
{
	if(itemID == 118)
	{
		if(!rp_GetClientBool(client, b_HasBankCard))
		{
			rp_SetClientBool(client, b_HasBankCard, true);
			rp_SetClientItem(client, 118, 0, false);
			SetClientCookie(client, cookie.BankCard, "1");
			
			char name[32];
			rp_GetItemData(itemID, item_name, STRING(name));
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);	
		}	
		else
		{
			rp_PrintToChat(client, "%T", "AlreadyEnabledBankCard", LANG_SERVER);
		}
	}
	else if(itemID == 119)
	{
		if(!rp_GetClientBool(client, b_HasSwissAccount))
		{
			rp_SetClientBool(client, b_HasSwissAccount, true);
			rp_SetClientItem(client, itemID, 0, false);

			char name[32];
			rp_GetItemData(itemID, item_name, STRING(name));				
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);	
		}	
		else
		{
			rp_PrintToChat(client, "%T", "AlreadyEnabledSwiss", LANG_SERVER);
		}	
	}
	else if(itemID == 145)
	{
		if(!rp_GetClientBool(client, b_HasRib))
		{
			rp_SetClientBool(client, b_HasRib, true);
			SetClientCookie(client, cookie.RIB, "1");
			rp_SetClientItem(client, itemID, 0, false);
			
			char name[32];
			rp_GetItemData(itemID, item_name, STRING(name));
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);	
		}	
		else
		{
			rp_PrintToChat(client, "%T", "AlreadyEnabledSwiss", LANG_SERVER);	
		}
	}
	else if(itemID == 146)
	{
		rp_SetClientInt(client, i_TicketMetro, rp_GetClientInt(client, i_TicketMetro) + 1);
		rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
			
		char name[32];
		rp_GetItemData(itemID, item_name, STRING(name));
		rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);	
	}
	else if(itemID == 147)
	{
		if(!rp_GetClientBool(client, b_HasSellLicence))
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
			rp_SetClientBool(client, b_HasSellLicence, true);
			SetClientCookie(client, cookie.Licence_Sell, "1");
				
			char name[32];
			rp_GetItemData(itemID, item_name, STRING(name));
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);	
		}	
	}
	else if(itemID == 148)
	{
		if(!rp_GetClientBool(client, b_HasCarLicence))
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
			rp_SetClientBool(client, b_HasCarLicence, true);
			SetClientCookie(client, FindClientCookie("rpv_licence_car"), "1");
				
			char name[32];
			rp_GetItemData(itemID, item_name, STRING(name));
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);	
		}	
	}
	else if(itemID == 149)
	{
		if(!rp_GetClientBool(client, b_HasPrimaryWeaponLicence))
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
			rp_SetClientBool(client, b_HasPrimaryWeaponLicence, true);
			SetClientCookie(client, cookie.Licence_PrimaryWeapon, "1");
				
			char name[32];
			rp_GetItemData(itemID, item_name, STRING(name));
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);	
		}	
	}
	else if(itemID == 150)
	{
		if(!rp_GetClientBool(client, b_HasSecondaryWeaponLicence))
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
			rp_SetClientBool(client, b_HasSecondaryWeaponLicence, true);
			SetClientCookie(client, cookie.Licence_SecondaryWeapon, "1");	
				
			char name[32];
			rp_GetItemData(itemID, item_name, STRING(name));
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);	
		}	
	}
	else if(itemID == 151)
	{
		FunctionUnderDevelopment(client);
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
