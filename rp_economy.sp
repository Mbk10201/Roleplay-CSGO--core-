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

enum struct ClientData {
	char SteamID[32];
	bool CanSetItemPrice;
	int SetItemSellQuantity;
	int SetItemSellId;
}
ClientData iData[MAXPLAYERS + 1];
 
int 
	g_iStartMoney = 300;
Database 
	g_DB;

/***************************************************************************************

							P L U G I N  -  I N F O

***************************************************************************************/
public Plugin myinfo = 
{
	name = "Roleplay - Economy", 
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
	// Load global translations
	LoadTranslation();
	// Print to server console the plugin status
	PrintToServer("[REQUIREMENT] ECONOMY ✓");
	
	/*----------------------------------Commands-------------------------------*/
	// Register all local plugin commands available in game
	RegConsoleCmd("rp_money", Cmd_GiveMoney);
	RegConsoleCmd("rp_bank", Cmd_GiveBank);
	RegConsoleCmd("rp_donner", Cmd_GivePlayer);
	RegConsoleCmd("rp_give", Cmd_GivePlayer);
	/*-------------------------------------------------------------------------------*/
}	

public void RP_OnSQLInit(Database db, Transaction transaction)
{
	g_DB = db;
	
	char sBuffer[MAX_BUFFER_LENGTH + 1];
	
	Format(STRING(sBuffer), "CREATE TABLE IF NOT EXISTS `rp_economy` ( \
	  `playerid` int(20) NOT NULL, \
	  `money` int(100) NOT NULL, \
	  `bank` int(100) NOT NULL, \
	  PRIMARY KEY (`playerid`), \
	  UNIQUE KEY `playerid` (`playerid`), \
	  FOREIGN KEY (`playerid`) REFERENCES `rp_players` (`id`) ON DELETE CASCADE ON UPDATE CASCADE \
	  )ENGINE = InnoDB DEFAULT CHARSET = utf8 COLLATE = utf8_bin;");
	#if DEBUG
		PrintToServer(sBuffer);
	#endif
	transaction.AddQuery(sBuffer);
	
	Format(STRING(sBuffer), "CREATE TABLE IF NOT EXISTS `rp_hotelvente` ( \
	  `id` int(20) NOT NULL AUTO_INCREMENT, \
	  `sellerid` int(20) NOT NULL, \
	  `itemid` int(10) NOT NULL, \
	  `quantity` int(100) NOT NULL, \
	  `price` int(100) NOT NULL, \
	  PRIMARY KEY (`id`), \
	  FOREIGN KEY (`sellerid`) REFERENCES `rp_players` (`id`) ON DELETE CASCADE ON UPDATE CASCADE \
	  )ENGINE = InnoDB DEFAULT CHARSET = utf8 COLLATE = utf8_bin;");
	#if DEBUG
		PrintToServer(sBuffer);
	#endif
	transaction.AddQuery(sBuffer);
}

public void OnPluginEnd()
{
	LoopClients(i)
	{
		if(!IsClientValid(i))
			continue;			
		SaveClient(i);
	}
}

public void OnClientDisconnect(int client)
{
	SaveClient(client);
}

public void SaveClient(int client) 
{	
	if(rp_GetClientInt(client, i_Money) > 0 || rp_GetClientInt(client, i_Bank) > 0)
		SQL_Request(g_DB, "UPDATE `rp_economy` SET `money` = '%i', `bank` = '%i' WHERE `playerid` = '%i';", rp_GetClientInt(client, i_Money), rp_GetClientInt(client, i_Bank), rp_GetSQLID(client));
}

public void OnMapStart()
{
	CreateTimer(120.0, ClearDatabaseSells, _, TIMER_REPEAT);
}	

public void OnClientAuthorized(int client, const char[] auth) 
{	
	strcopy(iData[client].SteamID, sizeof(iData[].SteamID), auth);
}

public void OnClientPostAdminCheck(int client) 
{	
	if(!IsClientValid(client))
		return;
	
	SQL_Request(g_DB, "INSERT IGNORE INTO `rp_economy` (`playerid`, `money`, `bank`) VALUES ('%i', '0', '%i');", rp_GetSQLID(client), g_iStartMoney);
	SQL_LoadClient(client);
}

public void SQL_LoadClient(int client) 
{
	if(!IsClientValid(client))
		return;
			
	char buffer[512];
	Format(STRING(buffer), "SELECT * FROM `rp_economy` WHERE `playerid` = '%i'", rp_GetSQLID(client));
	#if DEBUG
		PrintToServer("[RP_SQL] %s", buffer);
	#endif	
	g_DB.Query(QueryCallback, buffer, GetClientUserId(client));
}

public void QueryCallback(Database db, DBResultSet Results, const char[] error, any data) 
{	
	int client = GetClientOfUserId(data);
	while (Results.FetchRow()) 
	{
		int money, bank;
		Results.FetchIntByName("money", money);
		Results.FetchIntByName("bank", bank);
		
		if(money >= 0)
			rp_SetClientInt(client, i_Money, money);		
		else
			rp_SetClientInt(client, i_Money, 0);				
		
		if(bank >= 0)
			rp_SetClientInt(client, i_Bank, bank);
		else
			rp_SetClientInt(client, i_Bank, 0);		
	}
} 

public Action Cmd_GiveMoney(int client, int args) 
{	
	#if DEBUG
		Translation_DebugCommand(client);
	#endif
	
	if(rp_GetAdmin(client) != ADMIN_FLAG_OWNER)
	{
		Translation_PrintNoAccess(client);
		return Plugin_Handled;
	}
	
	if (args < 2) 
	{
		ReplyToCommand(client, "%T", "GiveMoneyInvalid", LANG_SERVER);
		return Plugin_Handled;
	}
	
	char arg[64];
	GetCmdArg(1, STRING(arg));
	
	int target = -1; 
	
	if(StrEqual(arg, "@me", false) || StrEqual(arg, "@moi", false))
		target = client;
	else
		target = FindTarget(client, arg, true);
	if (target <= COMMAND_TARGET_NONE)
	{
		ReplyToTargetError(client, target);
		return Plugin_Handled;
	}
	
	char amountStr[64];
	GetCmdArg(2, STRING(amountStr));
	
	if(!String_IsNumeric(amountStr))
	{
		rp_PrintToChat(client, "La somme doit être précisée en chiffre !");
		return Plugin_Handled;
	}
	
	int amount = StringToInt(amountStr);
	
	if(IsClientValid(target))
	{
		rp_PrintToChat(client, "Vous avez give %i$ à %N!", amount, target);
		rp_PrintToChat(target, "Vous avez été give %i$ par %N", amount, client);
		rp_SetClientInt(target, i_Money, rp_GetClientInt(target, i_Money) + amount);
		
		#if !DEBUG
			rp_SetJobCapital(3, rp_GetJobCapital(3) - amount);
		#endif	
	}
		
	return Plugin_Handled;
}

public Action Cmd_GiveBank(int client, int args) 
{
	#if DEBUG
		Translation_DebugCommand(client);
	#endif	
	
	if(rp_GetAdmin(client) != ADMIN_FLAG_OWNER)
	{
		Translation_PrintNoAccess(client);
		return Plugin_Handled;
	}
	
	if (args < 2) 
	{
		ReplyToCommand(client, "%T", "GiveMoneyInvalid", LANG_SERVER);
		return Plugin_Handled;
	}
	
	char arg[64];
	GetCmdArg(1, STRING(arg));
	
	int target = -1; 
	
	if(StrEqual(arg, "@me", false) || StrEqual(arg, "@moi", false))
		target = client;
	else
		target = FindTarget(client, arg, true);
	if (target <= COMMAND_TARGET_NONE)
	{
		ReplyToTargetError(client, target);
		return Plugin_Handled;
	}
	
	char amountStr[64];
	GetCmdArg(2, STRING(amountStr));
	
	if(!String_IsNumeric(amountStr))
	{
		rp_PrintToChat(client, "La somme doit être précisée en chiffre !");
		return Plugin_Handled;
	}
	
	int amount = StringToInt(amountStr);
	
	if(IsClientValid(target))
	{
		rp_PrintToChat(client, "Vous avez give {lightgreen}%i$ {default}à {yellow}%N{default}!", amount, target);
		rp_PrintToChat(target, "Vous avez été give {lightgreen}%i$ par {yellow}%N{default}.", amount, client);
		rp_SetClientInt(target, i_Bank, rp_GetClientInt(target, i_Bank) + amount);
		rp_SetJobCapital(3, rp_GetJobCapital(3) - amount);
	}
	
	return Plugin_Handled;
}

public void RP_OnClientInteract(int client, int target, const char[] class, const char[] model, const char[] name)
{
	if (StrContains(model, "atm.mdl") != -1 || StrContains(model, "atm01.mdl") != -1)
	{
		if (Distance(client, target) <= 50.0)
			MenuBanque(client);
	}
}

void MenuBanque(int client)
{	
	char buffer[128];
	
	rp_SetClientBool(client, b_DisplayHud, false);
	
	Menu menu = new Menu(DoMenuBanque);	
	
	Format(STRING(buffer), "%T", "ATM_Title", LANG_SERVER);
	menu.SetTitle(buffer);
	
	Format(STRING(buffer), "%T", "ATM_Deposit", LANG_SERVER);
	menu.AddItem("deposer", buffer, (rp_GetClientInt(client, i_Money) > 0) ? ITEMDRAW_DEFAULT:ITEMDRAW_DISABLED);
	
	Format(STRING(buffer), "%T", "ATM_Withdraw", LANG_SERVER);
	menu.AddItem("retirer", buffer, (rp_GetClientInt(client, i_Bank) > 0) ? ITEMDRAW_DEFAULT:ITEMDRAW_DISABLED);
	
	Format(STRING(buffer), "%T", "ATM_Management", LANG_SERVER);
	menu.AddItem("bankitem", buffer, (rp_GetClientBool(client, b_IsNew) == false) ? ITEMDRAW_DEFAULT:ITEMDRAW_DISABLED);		
	
	Format(STRING(buffer), "%T", "ATM_Informations", LANG_SERVER);
	menu.AddItem("info", buffer, (rp_GetClientBool(client, b_IsNew) == false) ? ITEMDRAW_DEFAULT:ITEMDRAW_DISABLED);

	menu.ExitButton = true;
	menu.Display(client, 20);
}

public int DoMenuBanque(Menu menu, MenuAction action, int client, int param) {
	
	if(action == MenuAction_Select) {
		char info[32];
		menu.GetItem(param, STRING(info));
		
		if(StrEqual(info, "deposer")) 
		{
			if(rp_GetClientInt(client, i_Money) <= 0)
			{	
				rp_PrintToChat(client, "%T", "ATM_InsufficientMoney", LANG_SERVER);
				rp_SetClientBool(client, b_DisplayHud, true);
			}	
			
			MenuDepose(client);
		}
		else if(StrEqual(info, "retirer")) 
		{
			if(rp_GetClientInt(client, i_Bank) <= 0)
			{
				rp_PrintToChat(client, "%T", "ATM_InsufficientMoney", LANG_SERVER);
				rp_SetClientBool(client, b_DisplayHud, true);
			}	
			else
				MenuRetire(client);
		}
		else if(StrEqual(info, "bankitem")) 
		{
			MenuItems(client);
		}
		else if(StrEqual(info, "info")) 
		{
			MenuInformations(client);
		}
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit || param == MenuCancel_ExitBack)
		{
			if(rp_GetClientBool(client, b_IsNew))
				rp_OpenTutorial(client);
			else	
				rp_SetClientBool(client, b_DisplayHud, true);
		}		
	}
	else if(action == MenuAction_End)
		delete menu;
		
	return 0;
}

void MenuInformations(int client)
{	
	rp_SetClientBool(client, b_DisplayHud, false);
	
	Menu menu = new Menu(Handle_MenuATMInformations);
	menu.SetTitle("%T", "ATM_Informations", LANG_SERVER);
	
	menu.AddItem("", "Chaque somme vérsée, vous déduira 2% de frais", ITEMDRAW_DISABLED);
	
	menu.ExitButton = true;
	menu.ExitBackButton = true;
	menu.Display(client, 30);	
}

public int Handle_MenuATMInformations(Menu menu, MenuAction action, int client, int param)
{	
	if(action == MenuAction_Select)
	{
		char info[32];
		menu.GetItem(param, STRING(info));
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if(param == MenuCancel_ExitBack)
			MenuBanque(client);
	}
	else if(action == MenuAction_End)
		delete menu;
		
	return 0;
}

void MenuDepose(int client)
{
	char buffer[128];
	
	rp_SetClientBool(client, b_DisplayHud, false);
	
	Menu menu = new Menu(DoMenuDepose);
	menu.SetTitle("%T", "ATM_DepositAmount", LANG_SERVER);
	
	Format(STRING(buffer), "%T", "ATM_AllMoneyDeposit", LANG_SERVER);
	menu.AddItem("all", buffer, (rp_GetClientInt(client, i_Money) > 0) ? ITEMDRAW_DEFAULT:ITEMDRAW_DISABLED);
	
	if(rp_GetClientInt(client, i_Money) >= 1)
		menu.AddItem("1", "1$");
	if(rp_GetClientInt(client, i_Money) >= 5)
		menu.AddItem("5", "5$");
	if(rp_GetClientInt(client, i_Money) >= 10)
		menu.AddItem("10", "10$");
	if(rp_GetClientInt(client, i_Money) >= 50)
		menu.AddItem("50", "50$");
	if(rp_GetClientInt(client, i_Money) >= 100)
		menu.AddItem("100", "100$");
	if(rp_GetClientInt(client, i_Money) >= 250)
		menu.AddItem("250", "250$");
	if(rp_GetClientInt(client, i_Money) >= 500)
		menu.AddItem("500", "500$");
	if(rp_GetClientInt(client, i_Money) >= 1000)
		menu.AddItem("1000", "1000$");
	if(rp_GetClientInt(client, i_Money) >= 2500)
		menu.AddItem("2500", "2500$");
	if(rp_GetClientInt(client, i_Money) >= 5000)
		menu.AddItem("5000", "5000$");
	if(rp_GetClientInt(client, i_Money) >= 10000)
		menu.AddItem("10000", "10000$");
	if(rp_GetClientInt(client, i_Money) >= 25000)
		menu.AddItem("25000", "25000$");
	if(rp_GetClientInt(client, i_Money) >= 50000)
		menu.AddItem("50000", "50000$");
	
	menu.ExitButton = true;
	menu.Display(client, 30);	
}

void MenuRetire(int client)
{	
	char buffer[128];
	
	rp_SetClientBool(client, b_DisplayHud, false);
	
	Menu menu = new Menu(DoMenuRetirer);	
	menu.SetTitle("%T", "ATM_WithdrawAmount", LANG_SERVER);
	if(rp_GetClientInt(client, i_Bank) >= 1)
		menu.AddItem("1", "1$");
	if(rp_GetClientInt(client, i_Bank) >= 5)
		menu.AddItem("5", "5$");
	if(rp_GetClientInt(client, i_Bank) >= 10)
		menu.AddItem("10", "10$");
	if(rp_GetClientInt(client, i_Bank) >= 50)
		menu.AddItem("50", "50$");
	if(rp_GetClientInt(client, i_Bank) >= 100)
		menu.AddItem("100", "100$");
	if(rp_GetClientInt(client, i_Bank) >= 250)
		menu.AddItem("250", "250$");
	if(rp_GetClientInt(client, i_Bank) >= 500)
		menu.AddItem("500", "500$");
	if(rp_GetClientInt(client, i_Bank) >= 1000)
		menu.AddItem("1000", "1000$");
	if(rp_GetClientInt(client, i_Bank) >= 2500)
		menu.AddItem("2500", "2500$");
	if(rp_GetClientInt(client, i_Bank) >= 5000)
		menu.AddItem("5000", "5000$");
	if(rp_GetClientInt(client, i_Bank) >= 10000)
		menu.AddItem("10000", "10000$");
	if(rp_GetClientInt(client, i_Bank) >= 25000)
		menu.AddItem("25000", "25000$");
	if(rp_GetClientInt(client, i_Bank) >= 50000)
		menu.AddItem("50000", "50000$");
	
	Format(STRING(buffer), "%T", "ATM_AllMoneyRetract", LANG_SERVER);
	menu.AddItem("all", buffer, (rp_GetClientInt(client, i_Bank) > 0) ? ITEMDRAW_DEFAULT:ITEMDRAW_DISABLED);
	
	menu.ExitButton = true;
	menu.Display(client, 30);	
}

public int DoMenuDepose(Menu menu, MenuAction action, int client, int param)
{	
	if(action == MenuAction_Select)
	{
		char info[32];
		menu.GetItem(param, STRING(info));
		
		int sommeDepose = StringToInt(info, 10);
		
		if(sommeDepose < 0)
			rp_PrintToChat(client, "%T", "ATM_Overdraft", LANG_SERVER);
		if(StrEqual(info, "all"))
		{
			rp_PrintToChat(client, "%T", "ATM_Crediting", LANG_SERVER, rp_GetClientInt(client, i_Money));		
			
			rp_SetClientInt(client, i_Bank, rp_GetClientInt(client, i_Bank) + rp_GetClientInt(client, i_Money));		
			rp_SetClientInt(client, i_Money, rp_GetClientInt(client, i_Money) - rp_GetClientInt(client, i_Money));
		}
		else if(rp_GetClientInt(client, i_Money) >= sommeDepose)
		{
			rp_SetClientInt(client, i_Bank, rp_GetClientInt(client, i_Bank) + sommeDepose);		
			rp_SetClientInt(client, i_Money, rp_GetClientInt(client, i_Money) - sommeDepose);
			
			rp_PrintToChat(client, "%T", "ATM_Crediting", LANG_SERVER, sommeDepose);			
			
			EmitCashSound(client, sommeDepose);
			MenuDepose(client);
		}
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit || param == MenuCancel_ExitBack)
		{
			if(rp_GetClientBool(client, b_IsNew))
				rp_OpenTutorial(client);
			else	
				rp_SetClientBool(client, b_DisplayHud, true);
		}
	}
	else if(action == MenuAction_End)
		delete menu;
		
	return 0;
}

public int DoMenuRetirer(Menu menu, MenuAction action, int client, int param)
{	
	if(action == MenuAction_Select)
	{
		char info[32];
		menu.GetItem(param, STRING(info));

		int sommeRetire = StringToInt(info, 10);
		if(sommeRetire > rp_GetClientInt(client, i_Bank))
			rp_PrintToChat(client, "%T", "ATM_InsufficientRequestedMoney", LANG_SERVER);
		if(StrEqual(info, "all"))
		{
			rp_SetClientInt(client, i_Money, rp_GetClientInt(client, i_Money) + rp_GetClientInt(client, i_Bank));
			rp_SetClientInt(client, i_Bank, rp_GetClientInt(client, i_Bank) - rp_GetClientInt(client, i_Bank));
		}
		else
		{
			rp_SetClientInt(client, i_Money, rp_GetClientInt(client, i_Money) + sommeRetire);
			rp_SetClientInt(client, i_Bank, rp_GetClientInt(client, i_Bank) - sommeRetire);
			
			MenuRetire(client);
		}
		
		rp_PrintToChat(client, "%T", "ATM_Debited", LANG_SERVER, sommeRetire);			
		
		EmitCashSound(client, sommeRetire);
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit || param == MenuCancel_ExitBack)
		{
			if(rp_GetClientBool(client, b_IsNew))
				rp_OpenTutorial(client);
			else	
				rp_SetClientBool(client, b_DisplayHud, true);
		}
	}
	else if(action == MenuAction_End)
		delete menu;
		
	return 0;
}

void MenuItems(int client)
{
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_MenuItem);
	menu.SetTitle("Gestion de l'inventaire");
	menu.AddItem("deposit", "Déposer des objets");
	menu.AddItem("withdraw", "Retirer des objets");
	menu.AddItem("force", "Forcer la sauvegarde");
	menu.AddItem("vente", "Hôtel des ventes");
	menu.AddItem("depot", "Dépot dans le capital");
	menu.ExitButton = true;
	menu.ExitBackButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}	

public int Handle_MenuItem(Menu menu, MenuAction action, int client, int param)
{	
	if(action == MenuAction_Select)
	{
		char info[32];
		menu.GetItem(param, STRING(info));

		if(StrEqual(info, "deposit"))	
			MenuDepositItem(client);		
		else if(StrEqual(info, "withdraw"))
			MenuWithdrawItem(client);
		else if(StrEqual(info, "force"))
		{
			SQL_SaveClient(client);
			rp_PrintToChat(client, "Sauvegarde forcée éffectué.");
		}	
		else if(StrEqual(info, "vente"))	
			MenuHotelVente(client);
		else if(StrEqual(info, "depot"))
			MenuCapital(client);
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if(param == MenuCancel_ExitBack)
			MenuItems(client);
	}
	else if(action == MenuAction_End)
		delete menu;

	return 0;
}

void MenuDepositItem(int client)
{
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_ItemDeposit_Quantity);
	menu.SetTitle("Que souhaitez-vous déposer?\nVotre coffre est rempli à %0.2f%.");
	
	int count;
	LoopItems(i)
	{		
		if(!rp_IsItemValidIndex(i))
			continue;
		
		if(rp_GetClientItem(client, i, false) >= 1)
		{
			count++;
			char itemname[32], strIndex[10], strName[64];
			rp_GetItemData(i, item_name, STRING(itemname));
			Format(STRING(strIndex), "%i", i);
			Format(STRING(strName), "%s [%i]", itemname, rp_GetClientItem(client, i, false));
			menu.AddItem(strIndex, strName);
		}
				
	}
	if(count == 0)
		menu.AddItem("", "Vous n'avez pas d'objet à déposer.", ITEMDRAW_DISABLED);		
		
	menu.ExitButton = true;
	menu.ExitBackButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Handle_ItemDeposit_Quantity(Menu menu, MenuAction action, int client, int param)
{	
	if(action == MenuAction_Select)
	{
		char info[10], strFormat[32];
		menu.GetItem(param, STRING(info));

		Menu quantity = new Menu(Handle_ItemDeposit_Final);	
		quantity.SetTitle("Choisissez la quantité a déposer.");
		
		int itemID = StringToInt(info);
		
		if(rp_GetClientItem(client, itemID, false) >= 1)
		{
			Format(STRING(strFormat), "%i|%i", rp_GetClientItem(client, itemID, false), itemID);
			quantity.AddItem(strFormat, "Tout");
			
			Format(STRING(strFormat), "1|%i", itemID);
			quantity.AddItem(strFormat, "1");
		}
		
		if(rp_GetClientItem(client, itemID, false) >= 2)
		{
			Format(STRING(strFormat), "2|%i", itemID);
			quantity.AddItem(strFormat, "2");
		}
		
		if(rp_GetClientItem(client, itemID, false) >= 3)
		{
			Format(STRING(strFormat), "3|%i", itemID);
			quantity.AddItem(strFormat, "3");
		}
		
		if(rp_GetClientItem(client, itemID, false) >= 4)
		{
			Format(STRING(strFormat), "4|%i", itemID);
			quantity.AddItem(strFormat, "4");
		}
		
		if(rp_GetClientItem(client, itemID, false) >= 5)
		{
			Format(STRING(strFormat), "5|%i", itemID);
			quantity.AddItem(strFormat, "5");
		}
		
		if(rp_GetClientItem(client, itemID, false) >= 10)
		{
			Format(STRING(strFormat), "10|%i", itemID);
			quantity.AddItem(strFormat, "10");
		}
		
		if(rp_GetClientItem(client, itemID, false) >= 50)
		{
			Format(STRING(strFormat), "50|%i", itemID);
			quantity.AddItem(strFormat, "50");
		}
		
		if(rp_GetClientItem(client, itemID, false) >= 100)
		{
			Format(STRING(strFormat), "100|%i", itemID);
			quantity.AddItem(strFormat, "100");
		}
		
		quantity.ExitBackButton = true;
		quantity.ExitButton = true;
		quantity.Display(client, MENU_TIME_FOREVER);
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if(param == MenuCancel_ExitBack)
			MenuItems(client);
	}
	else if(action == MenuAction_End)
		delete menu;
		
	return 0;
}

public int Handle_ItemDeposit_Final(Menu menu, MenuAction action, int client, int param)
{	
	if(action == MenuAction_Select)
	{
		char info[32], buffer[2][32];
		menu.GetItem(param, STRING(info));
		ExplodeString(info, "|", buffer, 2, 32);
		
		int item = StringToInt(buffer[1]);
		int itemQuantity = StringToInt(buffer[0]);
		
		rp_SetClientItem(client, item, rp_GetClientItem(client, item, false) - itemQuantity, false);
		rp_SetClientItem(client, item, rp_GetClientItem(client, item, true) + itemQuantity, true);
		
		char name[32];
		rp_GetItemData(item, item_name, STRING(name));
		
		rp_PrintToChat(client, "Vous avez déposé {lightgreen}%i {orange}%s", itemQuantity, name);
		
		SQL_Request(g_DB, "UPDATE `rp_items` SET `%i` = '%i' WHERE `steamid` = '%s';", item, rp_GetClientItem(client, item, true), iData[client].SteamID);
		
		rp_SetClientBool(client, b_DisplayHud, false);
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);	
		else if(param == MenuCancel_ExitBack)	
			MenuDepositItem(client);
	}
	else if(action == MenuAction_End)
		delete menu;
		
	return 0;
}

void MenuWithdrawItem(int client)
{
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_ItemWithdraw_Quantity);
	menu.SetTitle("Que souhaitez-vous retirer?.");
	
	int count;
	LoopItems(i)
	{
		if(!rp_IsItemValidIndex(i))
			continue;
		
		if(rp_GetClientItem(client, i, true) >= 1)
		{
			count++;
			char itemname[32], strIndex[32], strName[32];
			rp_GetItemData(i, item_name, STRING(itemname));
			Format(STRING(strIndex), "%i|%i", rp_GetClientItem(client, i, true), i);
			Format(STRING(strName), "%s [%i]", itemname, rp_GetClientItem(client, i, true));
			menu.AddItem(strIndex, strName);
		}	
	}			
	
	if(count == 0)
		menu.AddItem("", "Aucun objet n'est stocké.", ITEMDRAW_DISABLED);	
		
	menu.ExitButton = true;
	menu.ExitBackButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Handle_ItemWithdraw_Quantity(Menu menu, MenuAction action, int client, int param)
{	
	if(action == MenuAction_Select)
	{
		char info[10], strFormat[32], buffer[2][64];
		menu.GetItem(param, STRING(info));
		ExplodeString(info, "|", buffer, 2, 64);

		Menu quantity = new Menu(Handle_ItemWithdraw_Final);	
		quantity.SetTitle("Choisissez la quantité a retirer.");
		
		int itemID = StringToInt(buffer[1]);
		int itemQuantity = StringToInt(buffer[0]);
		
		if(itemQuantity >= 1)
		{
			Format(STRING(strFormat), "1|%i", itemID);
			quantity.AddItem(strFormat, "1");
		}
		
		if(itemQuantity >= 2)
		{
			Format(STRING(strFormat), "2|%i", itemID);
			quantity.AddItem(strFormat, "2");
		}
		
		if(itemQuantity >= 3)
		{
			Format(STRING(strFormat), "3|%i", itemID);
			quantity.AddItem(strFormat, "3");
		}
		
		if(itemQuantity >= 4)
		{
			Format(STRING(strFormat), "4|%i", itemID);
			quantity.AddItem(strFormat, "4");
		}
		
		if(itemQuantity >= 5)
		{
			Format(STRING(strFormat), "5|%i", itemID);
			quantity.AddItem(strFormat, "5");
		}
		
		if(itemQuantity >= 10)
		{
			Format(STRING(strFormat), "10|%i", itemID);
			quantity.AddItem(strFormat, "10");
		}
		
		if(itemQuantity >= 50)
		{
			Format(STRING(strFormat), "50|%i", itemID);
			quantity.AddItem(strFormat, "50");
		}
		
		if(itemQuantity >= 100)
		{
			Format(STRING(strFormat), "100|%i", itemID);
			quantity.AddItem(strFormat, "100");
		}
		
		if(itemQuantity >= 1)	
		{
			Format(STRING(strFormat), "%i|%i", itemQuantity, itemID);
			quantity.AddItem(strFormat, "Tout");
		}	
		
		quantity.ExitBackButton = true;
		quantity.ExitButton = true;
		quantity.Display(client, MENU_TIME_FOREVER);
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit) 
			rp_SetClientBool(client, b_DisplayHud, true);		
		else if(param == MenuCancel_ExitBack)
			MenuItems(client);
	}
	else if(action == MenuAction_End)
		delete menu;

	return 0;
}

public int Handle_ItemWithdraw_Final(Menu menu, MenuAction action, int client, int param)
{	
	if(action == MenuAction_Select)
	{
		char info[32], buffer[2][32];
		menu.GetItem(param, STRING(info));
		ExplodeString(info, "|", buffer, 2, 32);
		
		int item = StringToInt(buffer[1]);
		int itemQuantity = StringToInt(buffer[0]);
		
		rp_SetClientItem(client, item, rp_GetClientItem(client, item, false) + itemQuantity, false);
		rp_SetClientItem(client, item, rp_GetClientItem(client, item, true) - itemQuantity, true);
		
		char name[32];
		rp_GetItemData(item, item_name, STRING(name));
		
		rp_PrintToChat(client, "Vous avez retiré {lightgreen}%i {orange}%s", itemQuantity, name);
		rp_PrintToChat(client, "{lightgreen}Oubliez pas de sauvegarder vos items avant la déconnection {darkred}!");
		
		SQL_Request(g_DB, "UPDATE `rp_items` SET `%i` = '%i' WHERE `steamid` = '%s';", item, rp_GetClientItem(client, item, true), iData[client].SteamID);
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);	
		else if(param == MenuCancel_ExitBack)	
			MenuWithdrawItem(client);
	}
	else if(action == MenuAction_End)
		delete menu;

	return 0;
}

void MenuCapital(int client)
{
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_CapitalDepot);
	menu.SetTitle("Moyen d'envoi");
	menu.AddItem("money", "Cash", (rp_GetClientInt(client, i_Money) >= 1)? ITEMDRAW_DEFAULT:ITEMDRAW_DISABLED);
	menu.AddItem("bank", "Carte Bancaire", (rp_GetClientBool(client, b_HasBankCard) == true && rp_GetClientInt(client, i_Bank) >= 1)? ITEMDRAW_DEFAULT:ITEMDRAW_DISABLED);
	menu.ExitButton = true;
	menu.ExitBackButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Handle_CapitalDepot(Menu menu, MenuAction action, int client, int param)
{	
	if(action == MenuAction_Select)
	{
		char info[32];
		menu.GetItem(param, STRING(info));

		rp_SetClientBool(client, b_DisplayHud, false);
		Menu menu1 = new Menu(Handle_FinalCapital);
		menu1.SetTitle("Choisissez le montant");
		
		int money = rp_GetClientInt(client, i_Money);
		int bank = rp_GetClientInt(client, i_Bank);
		if(StrEqual(info, "money"))	
		{
			if(money >= 1)
				menu1.AddItem("1|money", "1$");
			if(money >= 5)
				menu1.AddItem("5", "5$");
			if(money >= 10)
				menu1.AddItem("10|money", "10$");
			if(money >= 50)
				menu1.AddItem("50|money", "50$");
			if(money >= 100)
				menu1.AddItem("100|money", "100$");
			if(money >= 250)
				menu1.AddItem("250|money", "250$");
			if(money >= 500)
				menu1.AddItem("500|money", "500$");
			if(money >= 1000)
				menu1.AddItem("1000|money", "1000$");
			if(money >= 2500)
				menu1.AddItem("2500|money", "2500$");
			if(money >= 5000)
				menu1.AddItem("5000|money", "5000$");
			if(money >= 10000)
				menu1.AddItem("10000|money", "10000$");
			if(money >= 25000)
				menu1.AddItem("25000|money", "25000$");
			if(money >= 50000)
				menu1.AddItem("50000|money", "50000$");
			if(money >= 2)
				menu1.AddItem("all|money", "Tout mon argent");	
		}		
		else if(StrEqual(info, "bank"))
		{
			if(bank >= 1)
				menu1.AddItem("1|bank", "1$");
			if(bank >= 5)
				menu1.AddItem("5|bank", "5$");
			if(bank >= 10)
				menu1.AddItem("10|bank", "10$");
			if(bank >= 50)
				menu1.AddItem("50|bank", "50$");
			if(bank >= 100)
				menu1.AddItem("100|bank", "100$");
			if(bank >= 250)
				menu1.AddItem("250|bank", "250$");
			if(bank >= 500)
				menu1.AddItem("500|bank", "500$");
			if(bank >= 1000)
				menu1.AddItem("1000|bank", "1000$");
			if(bank >= 2500)
				menu1.AddItem("2500|bank", "2500$");
			if(bank >= 5000)
				menu1.AddItem("5000|bank", "5000$");
			if(bank >= 10000)
				menu1.AddItem("10000|bank", "10000$");
			if(bank >= 25000)
				menu1.AddItem("25000|bank", "25000$");
			if(bank >= 50000)
				menu1.AddItem("50000|bank", "50000$");
			if(bank >= 2)
				menu1.AddItem("all|bank", "Tout mon argent");
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
			MenuCapital(client);
	}
	else if(action == MenuAction_End)
		delete menu;

	return 0;
}

public int Handle_FinalCapital(Menu menu, MenuAction action, int client, int param)
{	
	if(action == MenuAction_Select)
	{
		char info[32], buffer[2][32];
		menu.GetItem(param, STRING(info));
		ExplodeString(info, "|", buffer, 2, 32);		
		
		if(StrEqual(buffer[0], "all"))
		{
			if(StrEqual(buffer[1], "bank"))
			{
				rp_PrintToChat(client, "Le transfert de %i$ de votre compte bancaire vers le capital a été effectué avec succès.", rp_GetClientInt(client, i_Bank));
				rp_SetClientInt(client, i_Bank, 0);
				rp_SetJobCapital(rp_GetClientInt(client, i_Job), rp_GetJobCapital(rp_GetClientInt(client, i_Job)) + rp_GetClientInt(client, i_Bank));
			}	
			else
			{
				rp_PrintToChat(client, "Le transfert de %i$ vers le capital a été effectué avec succès.", rp_GetClientInt(client, i_Money));
				rp_SetClientInt(client, i_Money, 0);
				rp_SetJobCapital(rp_GetClientInt(client, i_Job), rp_GetJobCapital(rp_GetClientInt(client, i_Job)) + rp_GetClientInt(client, i_Money));
			}
		}
		else
		{
			int amount = StringToInt(buffer[0]);
			
			if(StrEqual(buffer[1], "bank"))
			{
				if(rp_GetClientInt(client, i_Bank) >= amount)
				{			
					rp_SetClientInt(client, i_Bank, rp_GetClientInt(client, i_Bank) - amount);
					rp_SetJobCapital(rp_GetClientInt(client, i_Job), rp_GetJobCapital(rp_GetClientInt(client, i_Job)) + amount);
					rp_PrintToChat(client, "Le transfert de %i$ de votre compte bancaire vers le capital a été effectué avec succès.", amount);
				}	
				else
					rp_PrintToChat(client, "Vous n'avez pas l'argent nécessaire pour le transfert.");
			}	
			else 
			{
				if(rp_GetClientInt(client, i_Money) >= amount)
				{				
					rp_SetClientInt(client, i_Money, rp_GetClientInt(client, i_Money) - amount);
					rp_SetJobCapital(rp_GetClientInt(client, i_Job), rp_GetJobCapital(rp_GetClientInt(client, i_Job)) + amount);
					rp_PrintToChat(client, "Le transfert de %i$ vers le capital a été effectué avec succès.", amount);
				}	
				else
					rp_PrintToChat(client, "Vous n'avez pas l'argent nécessaire pour le transfert.");
			}
		}
		
		MenuCapital(client);
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit || param == MenuCancel_ExitBack)
			rp_SetClientBool(client, b_DisplayHud, true);		
	}
	else if(action == MenuAction_End)
		delete menu;
		
	return 0;
}

void MenuHotelVente(int client)
{
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_HotelVente);
	menu.SetTitle("Hôtel des ventes");
	menu.AddItem("buy", "Acheter un objet");
	menu.AddItem("sell", "Vendre un objet");
	
	char query[100];
	Format(STRING(query), "SELECT * FROM `rp_hotelvente` WHERE `vendeur` = '%s'", iData[client].SteamID);	 
	DBResultSet Results = SQL_Query(g_DB, query);
	if(Results.FetchRow())
	{
		menu.AddItem("edit", "Modifier une vente");
	}			
	delete Results;
	
	menu.ExitButton = true;
	menu.ExitBackButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}	

public int Handle_HotelVente(Menu menu, MenuAction action, int client, int param)
{	
	if(action == MenuAction_Select)
	{
		char info[32];
		menu.GetItem(param, STRING(info));

		if(StrEqual(info, "buy"))
			MenuHotelVente_Buy(client);
		else if(StrEqual(info, "sell"))
			MenuHotelVente_Sell(client);
		else if(StrEqual(info, "edit"))
			MenuHotelVente_Edit(client);	
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if(param == MenuCancel_ExitBack)
			MenuItems(client);
	}
	else if(action == MenuAction_End)
		delete menu;
		
	return 0;
}

void MenuHotelVente_Buy(int client)
{
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_HotelVente_Buy);
	menu.SetTitle("Choisissez un objet à acheter.");
	
	char query[100];
	Format(STRING(query), "SELECT * FROM `rp_hotelvente`");	 
	DBResultSet Results = SQL_Query(g_DB, query);
	
	char strIndex[32], strName[64];
	
	int count;
	while(Results.FetchRow())
	{
		count++;
		char seller_id[32];
		Results.FetchStringByName("vendeur", STRING(seller_id));
		int item, quantity, price;
		Results.FetchIntByName("itemid", item);
		Results.FetchIntByName("quantity", quantity);
		Results.FetchIntByName("price", price);
		
		if(quantity >= 1)
		{
			char itemname[64];
			rp_GetItemData(item, item_name, STRING(itemname));
			Format(STRING(strIndex), "%i|%i|%i|%s", item, quantity, price, seller_id);
			Format(STRING(strName), "%s [%i$]", itemname, price);
			menu.AddItem(strIndex, strName);
		}	
	}			
	delete Results;
	
	if(count == 0)
		menu.AddItem("", "Aucun objet n'est disponible.", ITEMDRAW_DISABLED);	
	
	menu.ExitButton = true;
	menu.ExitBackButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}	

public int Handle_HotelVente_Buy(Menu menu, MenuAction action, int client, int param)
{	
	if(action == MenuAction_Select)
	{
		char info[128], buffer[4][128];
		menu.GetItem(param, STRING(info));
		ExplodeString(info, "|", buffer, 4, 128);
		
		/*
			buffer[0] = item choisie
			buffer[1] = quantity de l'item disponible
			buffer[2] = prix de l'item
			buffer[3] = steamid du vendeur		
		*/
		
		int item = StringToInt(buffer[0]);
		int quantity = StringToInt(buffer[1]);
		int price = StringToInt(buffer[2]);
		
		rp_SetClientBool(client, b_DisplayHud, false);
		Menu menuQuantity = new Menu(Handle_HotelVente_Buy_Method);	
		menuQuantity.SetTitle("Choisissez la quantité à acheter.");
				
		char strFormat[128];
		if(quantity >= 1)
		{
			Format(STRING(strFormat), "1|%i|%i|%s", item, price, buffer[3]);
			menuQuantity.AddItem(strFormat, "1");
		}
		
		if(quantity >= 2)
		{
			Format(STRING(strFormat), "2|%i|%i|%s", item, price, buffer[3]);
			menuQuantity.AddItem(strFormat, "2");
		}
		
		if(quantity >= 3)
		{
			Format(STRING(strFormat), "3|%i|%i|%s", item, price, buffer[3]);
			menuQuantity.AddItem(strFormat, "3");
		}
		
		if(quantity >= 4)
		{
			Format(STRING(strFormat), "4|%i|%i|%s", item, price, buffer[3]);
			menuQuantity.AddItem(strFormat, "4");
		}
		
		if(quantity >= 5)
		{
			Format(STRING(strFormat), "5|%i|%i|%s", item, price, buffer[3]);
			menuQuantity.AddItem(strFormat, "5");
		}
		
		if(quantity >= 10)
		{
			Format(STRING(strFormat), "10|%i|%i|%s", item, price, buffer[3]);
			menuQuantity.AddItem(strFormat, "10");
		}
		
		if(quantity >= 50)
		{
			Format(STRING(strFormat), "50|%i|%i|%s", item, price, buffer[3]);
			menuQuantity.AddItem(strFormat, "50");
		}
		
		if(quantity >= 100)
		{
			Format(STRING(strFormat), "100|%i|%i|%s", item, price, buffer[3]);
			menuQuantity.AddItem(strFormat, "100");
		}
		
		if(quantity >= 1)	
		{
			Format(STRING(strFormat), "%i|%i|%i|%s", quantity, item, price, buffer[3]);
			menuQuantity.AddItem(strFormat, "Tout");
		}	
		
		menuQuantity.ExitBackButton = true;
		menuQuantity.ExitButton = true;
		menuQuantity.Display(client, MENU_TIME_FOREVER);
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if(param == MenuCancel_ExitBack)
			MenuHotelVente(client);
	}
	else if(action == MenuAction_End)
		delete menu;

	return 0;
}

public int Handle_HotelVente_Buy_Method(Menu menu, MenuAction action, int client, int param)
{	
	if(action == MenuAction_Select)
	{
		char info[128], buffer[4][128];
		menu.GetItem(param, STRING(info));
		ExplodeString(info, "|", buffer, 4, 128);
		
		/*
			buffer[0] = quantity d'item à acheter
			buffer[1] = item à acheter
			buffer[2] = prix de l'item
			buffer[3] = steamid du vendeur		
		*/
		
		int item = StringToInt(buffer[1]);
		int quantity = StringToInt(buffer[0]);
		int price = StringToInt(buffer[2]);
		
		char strFormat[128];
		
		rp_SetClientBool(client, b_DisplayHud, false);
		Menu methodBuy = new Menu(Handle_HotelVente_Buy_Final);	
		methodBuy.SetTitle("Choisissez le moyen de paiement.");
		
		Format(STRING(strFormat), "cash|%i|%i|%i|%s", quantity, item, price, buffer[3]);
		methodBuy.AddItem(strFormat, "Cash");	
		
		if(rp_GetClientBool(client, b_HasBankCard))
		{
			Format(STRING(strFormat), "cb|%i|%i|%i|%s", quantity, item, price, buffer[3]);
			methodBuy.AddItem(strFormat, "Carte Bancaire");		
		}	
		
		methodBuy.ExitBackButton = true;
		methodBuy.ExitButton = true;
		methodBuy.Display(client, MENU_TIME_FOREVER);
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if(param == MenuCancel_ExitBack)
			MenuHotelVente_Buy(client);
	}
	else if(action == MenuAction_End)
		delete menu;

	return 0;
}

public int Handle_HotelVente_Buy_Final(Menu menu, MenuAction action, int client, int param)
{	
	if(action == MenuAction_Select)
	{
		char info[128], buffer[5][128];
		menu.GetItem(param, STRING(info));
		ExplodeString(info, "|", buffer, 5, 128);
		
		/*
			buffer[0] = moyen de paiement
			buffer[1] = quantity d'item à acheter
			buffer[2] = item à acheter
			buffer[3] = prix de l'item
			buffer[4] = steamid du vendeur		
		*/
		
		int quantity = StringToInt(buffer[1]);
		int item = StringToInt(buffer[2]);		
		int price = StringToInt(buffer[3]);
		price = price * quantity;
		
		char itemname[64];
		rp_GetItemData(item, item_name, STRING(itemname));
		
		char query[1024];
		Format(STRING(query), "SELECT `quantity` FROM `rp_hotelvente` WHERE `vendeur` = '%s' AND `itemid` = '%i'", buffer[4], item);	 
		DBResultSet Results = SQL_Query(g_DB, query);
		
		if(Results.FetchRow())
		{
			int query_quantity = Results.FetchInt(0);
			query_quantity -= quantity;	
			SQL_Request(g_DB, "UPDATE `rp_hotelvente` SET `quantity` = '%i' WHERE `vendeur` = '%s' AND `itemid` = '%i';", query_quantity, buffer[4], item);	
		}	
			
		delete Results;

		if(StrEqual(buffer[0], "cb"))
		{
			if(rp_GetClientInt(client, i_Bank) >= price)
			{
				rp_SetClientInt(client, i_Bank, rp_GetClientInt(client, i_Bank) - price);
				rp_SetClientItem(client, item, rp_GetClientItem(client, item, true) + quantity, true);
				rp_PrintToChat(client, "Vous avez acheté %i %s pour %i$", quantity, itemname, price);
				
				int vendeur = Client_FindBySteamId(buffer[4]);
				if(vendeur != -1 && vendeur != client)
				{
					rp_PrintToChat(client, "Vous avez acheté %i %s à %N pour %i$", quantity, itemname, vendeur, price);
					
					rp_SetClientInt(vendeur, i_Bank, rp_GetClientInt(vendeur, i_Bank) + price);
					CPrintToChat(vendeur, "%s %N vous à acheté %i %s pour %i$", client, quantity, itemname, price);
				}
				else
				{
					Format(STRING(query), "SELECT `id` FROM `rp_players` WHERE `steamid_32` = '%s'", buffer[4]);	 
					DBResultSet Results1 = SQL_Query(g_DB, query);
					
					if(Results1.FetchRow())
					{
						int id = Results1.FetchInt(0);
						SQL_Request(g_DB, "UPDATE `rp_economy` SET `bank` = bank + '%i' WHERE `playerid` = '%i';", price, id);
					}	
					else
						rp_PrintToChat(client, "Vendeur inconnu !");
					delete Results1;	
						
					rp_PrintToChat(client, "Vous avez acheté %i %s pour %i$", quantity, itemname, price);	
				}
			}
			else
				rp_PrintToChat(client, "Vous n'avez pas assez d'argent en banque.");
		}	
		else if(StrEqual(buffer[0], "cash"))
		{
			if(rp_GetClientInt(client, i_Money) >= price)
			{
				rp_SetClientInt(client, i_Money, rp_GetClientInt(client, i_Money) - price);
				rp_SetClientItem(client, item, rp_GetClientItem(client, item, true) + quantity, true);
				
				int vendeur = Client_FindBySteamId(buffer[4]);
				if(vendeur != -1 && vendeur != client)
				{
					rp_PrintToChat(client, "Vous avez acheté %i %s à %N pour %i$", quantity, itemname, vendeur, price);
					
					rp_SetClientInt(vendeur, i_Money, rp_GetClientInt(vendeur, i_Money) + price);
					CPrintToChat(vendeur, "%s %N vous à acheté %i %s pour %i$", client, quantity, itemname, price);
				}
				else
				{
					Format(STRING(query), "SELECT `id` FROM `rp_players` WHERE `steamid_32` = '%s'", buffer[4]);	 
					DBResultSet Results1 = SQL_Query(g_DB, query);
					
					if(Results1.FetchRow())
					{
						int id = Results1.FetchInt(0);
						SQL_Request(g_DB, "UPDATE `rp_economy` SET `money` = money + '%i' WHERE `playerid` = '%i';", price, id);
					}	
					else
						rp_PrintToChat(client, "Vendeur inconnu !");
					delete Results1;	
						
					rp_PrintToChat(client, "Vous avez acheté %i %s pour %i$", quantity, itemname, price);	
				}	
			}
			else
				rp_PrintToChat(client, "Vous n'avez pas assez d'argent.");
		}		
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if(param == MenuCancel_ExitBack)
			MenuHotelVente_Buy(client);
	}
	else if(action == MenuAction_End)
		delete menu;

	return 0;
}

void MenuHotelVente_Sell(int client)
{
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_HotelVente_Sell);
	menu.SetTitle("Choisissez un objet à vendre.");
	
	char strIndex[10];
	int count;
	
	LoopItems(i)
	{
		if(!rp_IsItemValidIndex(i))
			continue;
		
		if(rp_GetClientItem(client, i, false) >= 1)
		{
			count++;
			
			char query[1024];
			Format(STRING(query), "SELECT * FROM `rp_hotelvente` WHERE `vendeur` = '%s' AND `itemid` = '%i'", iData[client].SteamID, i);
			DBResultSet Results = SQL_Query(g_DB, query);
			
			if(!Results.FetchRow())
			{
				char itemname[32];
				rp_GetItemData(i, item_name, STRING(itemname));
				Format(STRING(strIndex), "%i", i);
				menu.AddItem(strIndex, itemname);
			}	
			delete Results;
		}	
	}	
	
	if(count == 0)
		menu.AddItem("", "Vous n'avez aucun objet à vendre.", ITEMDRAW_DISABLED);
	
	menu.ExitButton = true;
	menu.ExitBackButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}	

public int Handle_HotelVente_Sell(Menu menu, MenuAction action, int client, int param)
{	
	if(action == MenuAction_Select)
	{
		char info[10];
		menu.GetItem(param, STRING(info));
		int itemid = StringToInt(info);
		
		rp_SetClientBool(client, b_DisplayHud, false);
		Menu menuQuantity = new Menu(Handle_HotelVente_Sell_Price);	
		menuQuantity.SetTitle("Choisissez la quantité à vendre.");
				
		char strFormat[128];
		if(rp_GetClientItem(client, itemid, false) >= 1)
		{
			Format(STRING(strFormat), "%i|%i", rp_GetClientItem(client, itemid, false), itemid);
			menuQuantity.AddItem(strFormat, "Tout");
			
			Format(STRING(strFormat), "1|%i", itemid);
			menuQuantity.AddItem(strFormat, "1");
		}
		
		if(rp_GetClientItem(client, itemid, false) >= 2)
		{
			Format(STRING(strFormat), "2|%i", itemid);
			menuQuantity.AddItem(strFormat, "2");
		}
		
		if(rp_GetClientItem(client, itemid, false) >= 3)
		{
			Format(STRING(strFormat), "3|%i", itemid);
			menuQuantity.AddItem(strFormat, "3");
		}
		
		if(rp_GetClientItem(client, itemid, false) >= 4)
		{
			Format(STRING(strFormat), "4|%i", itemid);
			menuQuantity.AddItem(strFormat, "4");
		}
		
		if(rp_GetClientItem(client, itemid, false) >= 5)
		{
			Format(STRING(strFormat), "5|%i", itemid);
			menuQuantity.AddItem(strFormat, "5");
		}
		
		if(rp_GetClientItem(client, itemid, false) >= 10)
		{
			Format(STRING(strFormat), "10|%i", itemid);
			menuQuantity.AddItem(strFormat, "10");
		}
		
		if(rp_GetClientItem(client, itemid, false) >= 50)
		{
			Format(STRING(strFormat), "50|%i", itemid);
			menuQuantity.AddItem(strFormat, "50");
		}
		
		if(rp_GetClientItem(client, itemid, false) >= 100)
		{
			Format(STRING(strFormat), "100|%i", itemid);
			menuQuantity.AddItem(strFormat, "100");
		}
		
		menuQuantity.ExitBackButton = true;
		menuQuantity.ExitButton = true;
		menuQuantity.Display(client, MENU_TIME_FOREVER);
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if(param == MenuCancel_ExitBack)
			MenuHotelVente_Sell(client);
	}
	else if(action == MenuAction_End)
		delete menu;
		
	return 0;
}

public int Handle_HotelVente_Sell_Price(Menu menu, MenuAction action, int client, int param)
{	
	if(action == MenuAction_Select)
	{
		char info[10], buffer[2][32];
		menu.GetItem(param, STRING(info));
		ExplodeString(info, "|", buffer, 2, 32);
		
		int quantity = StringToInt(buffer[0]);
		int itemid = StringToInt(buffer[1]);
		
		rp_SetClientBool(client, b_DisplayHud, false);
		Panel panel = new Panel();
		panel.SetTitle("Prix");	
		panel.DrawText("Ecrivez dans le tchat le prix a attribuer à l'item\npour la vente.");
		panel.DrawText("                                  ");
		panel.DrawText("Lors d'un achat de votre item, le prix est multiplié par le nombre\nde quantité mit en vente.");
		panel.Send(client, HandleNothing, 25);
		
		iData[client].SetItemSellQuantity = quantity;
		iData[client].SetItemSellId = itemid;
		iData[client].CanSetItemPrice = true;
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if(param == MenuCancel_ExitBack)
			MenuHotelVente_Sell(client);
	}
	else if(action == MenuAction_End)
		delete menu;
		
	return 0;
}

public void RP_OnClientSay(int client, const char[] arg)
{
	if(iData[client].CanSetItemPrice)
	{
		iData[client].CanSetItemPrice = false;
		if(String_IsNumeric(arg))
		{
			int price = StringToInt(arg);
			MenuHotelVente_Sell_Final(client, price);
			rp_SetClientBool(client, b_DisplayHud, true);
		}
		else 
			rp_PrintToChat(client, "Le prix doit être précisée en chiffre !");
	}	
}

void MenuHotelVente_Sell_Final(int client, int price)
{	
	char query[1024];
	Format(STRING(query), "SELECT * FROM `rp_hotelvente` WHERE `vendeur` = '%s' AND `itemid` = '%i'", iData[client].SteamID, iData[client].SetItemSellId);
	DBResultSet Results = SQL_Query(g_DB, query);
			
	char itemname[32];
	rp_GetItemData(iData[client].SetItemSellId, item_name, STRING(itemname));
	
	if(!Results.FetchRow())
	{
		rp_PrintToChat(client, "Vous avez mit à vendre %i %s (Prix Unité %i).", iData[client].SetItemSellQuantity, itemname, price);
		SQL_Request(g_DB, "INSERT INTO `rp_hotelvente` (`Id`, `vendeur`, `itemid`, `quantity`, `price`) VALUES (NULL, '%s', '%i', '%i', '%i');", iData[client].SteamID, iData[client].SetItemSellId, iData[client].SetItemSellQuantity, price);		
	}	
	else
	{
		rp_PrintToChat(client, "Vous avez changé le prix de %s en %i Prix Unité.", itemname, price);
		SQL_Request(g_DB, "UPDATE `rp_hotelvente` SET `price` = '%i' WHERE `vendeur` = '%s' AND `itemid` = '%i';", price, iData[client].SteamID, iData[client].SetItemSellId);	
	}	
	
	delete Results;
	
	rp_SetClientItem(client, iData[client].SetItemSellId, rp_GetClientItem(client, iData[client].SetItemSellId, false) - iData[client].SetItemSellQuantity, false);
	
	iData[client].SetItemSellQuantity = 0;
	iData[client].SetItemSellId = 0;
}	

public Action ClearDatabaseSells(Handle Timer)
{
	char query[1024];
	Format(STRING(query), "SELECT * FROM `rp_hotelvente`");
	DBResultSet Results = SQL_Query(g_DB, query);
	
	while(Results.FetchRow())
	{
		int itemid, quantity;
		Results.FetchIntByName("itemid", itemid);
		Results.FetchIntByName("quantity", quantity);
		
		if(quantity == 0)
		{
			SQL_Request(g_DB, "DELETE FROM `rp_hotelvente` WHERE `itemid` = '%i'", itemid);
		}	
	}	
	delete Results;
	
	return Plugin_Handled;
}		

void MenuHotelVente_Edit(int client)
{
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_HotelVente_EditType);
	menu.SetTitle("Choisissez un objet à modifier.");
	
	char strIndex[10];
	
	char query[1024];
	Format(STRING(query), "SELECT * FROM `rp_hotelvente` WHERE `vendeur` = '%s'", iData[client].SteamID);
	DBResultSet Results = SQL_Query(g_DB, query);
	
	int count;
	while(Results.FetchRow())
	{
		count++;
		
		int itemid, quantity;
		Results.FetchIntByName("itemid", itemid);
		Results.FetchIntByName("quantity", quantity);
		
		if(quantity >= 1)
		{		
			char itemname[32];
			rp_GetItemData(itemid, item_name, STRING(itemname));
			Format(STRING(strIndex), "%i", itemid);
			menu.AddItem(strIndex, itemname);
		}	
	}
	
	if(count == 0)
		menu.AddItem("", "Vous n'avez aucun objet en vente.", ITEMDRAW_DISABLED);	
	
	delete Results;
	
	menu.ExitButton = true;
	menu.ExitBackButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}	

public int Handle_HotelVente_EditType(Menu menu, MenuAction action, int client, int param)
{	
	if(action == MenuAction_Select)
	{
		char info[10], strIndex[32];
		menu.GetItem(param, STRING(info));
		
		rp_SetClientBool(client, b_DisplayHud, false);
		Menu menu1 = new Menu(Handle_HotelVente_EditType1);
		menu1.SetTitle("Choisissez le type à modifier.");
		
		Format(STRING(strIndex), "%i|prix", StringToInt(info));
		menu1.AddItem(strIndex, "Changer le Prix");
		
		Format(STRING(strIndex), "%i|quantity", StringToInt(info));
		menu1.AddItem(strIndex, "Changer la Quantité");
		
		Format(STRING(strIndex), "%i|retirer", StringToInt(info));
		menu1.AddItem(strIndex, "Retirer la Vente");
		
		menu1.ExitButton = true;
		menu1.ExitBackButton = true;
		menu1.Display(client, MENU_TIME_FOREVER);
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if(param == MenuCancel_ExitBack)
			MenuHotelVente_Sell(client);
	}
	else if(action == MenuAction_End)
		delete menu;
	
	return 0;
}

public int Handle_HotelVente_EditType1(Menu menu, MenuAction action, int client, int param)
{	
	if(action == MenuAction_Select)
	{
		char info[10], buffer[2][64];
		menu.GetItem(param, STRING(info));
		ExplodeString(info, "|", buffer, 2, 64);
		
		if(StrEqual(buffer[1], "prix"))
			MenuHotelVente_Edit_Price(client, StringToInt(buffer[0]));
		else if(StrEqual(buffer[1], "quantity"))
			MenuHotelVente_Edit_Quantity(client, StringToInt(buffer[0]));
		else if(StrEqual(buffer[1], "retirer"))
			MenuHotelVente_Edit_Delete(client, StringToInt(buffer[0]));
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if(param == MenuCancel_ExitBack)
			MenuHotelVente_Sell(client);
	}
	else if(action == MenuAction_End)
		delete menu;
	
	return 0;
}

void MenuHotelVente_Edit_Price(int client, int itemID)
{
	rp_SetClientBool(client, b_DisplayHud, false);
	
	Panel panel = new Panel();
	panel.SetTitle("--------Prix--------");	
	panel.DrawText("Ecrivez dans le tchat le prix a reattribuer à l'item\npour la vente.");
	panel.DrawText("                                  ");
	panel.DrawText("Lors d'un achat de votre item, le prix est multiplié par le nombre\nde quantité mit en vente.");
	panel.Send(client, HandleNothing, 25);
	
	iData[client].CanSetItemPrice = true;
	iData[client].SetItemSellId = itemID;
}

void MenuHotelVente_Edit_Quantity(int client, int itemID)
{
	CPrintToChat(client, "%i", itemID);
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Menu_Edit_Quantity_Type);	
	menu.SetTitle("Choisissez le type de quantité à modifier.");	
	
	char strFormat[32];
	
	Format(STRING(strFormat), "%i|+", itemID);
	menu.AddItem(strFormat, "Ajouter");
	
	Format(STRING(strFormat), "%i|-", itemID);
	menu.AddItem(strFormat, "Retirer");
	
	menu.ExitBackButton = true;
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Menu_Edit_Quantity_Type(Menu menu, MenuAction action, int client, int param)
{	
	if(action == MenuAction_Select)
	{
		char info[10], buffer[2][64];
		menu.GetItem(param, STRING(info));
		ExplodeString(info, "|", buffer, 2, 64);
		
		if(StrEqual(buffer[1], "+"))
			Menu_Edit_Quantity_Type_Plus(client, StringToInt(buffer[0]));
		else if(StrEqual(buffer[1], "-"))
			Menu_Edit_Quantity_Type_Minus(client, StringToInt(buffer[0]));
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if(param == MenuCancel_ExitBack)
			MenuHotelVente_Edit(client);
	}
	else if(action == MenuAction_End)
		delete menu;
	
	return 0;
}

void Menu_Edit_Quantity_Type_Plus(int client, int itemID)
{
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Quantity_Type_Plus_Final);	
	menu.SetTitle("Choisissez la quantité à ajouter.");	
	
	char strFormat[32];
	if(rp_GetClientItem(client, itemID, false) >= 1)
	{
		Format(STRING(strFormat), "%i|%i", rp_GetClientItem(client, itemID, false), itemID);
		menu.AddItem(strFormat, "Tout");
		
		Format(STRING(strFormat), "1|%i", itemID);
		menu.AddItem(strFormat, "1");
	}
	
	if(rp_GetClientItem(client, itemID, false) >= 2)
	{
		Format(STRING(strFormat), "2|%i", itemID);
		menu.AddItem(strFormat, "2");
	}
	
	if(rp_GetClientItem(client, itemID, false) >= 3)
	{
		Format(STRING(strFormat), "3|%i", itemID);
		menu.AddItem(strFormat, "3");
	}
	
	if(rp_GetClientItem(client, itemID, false) >= 4)
	{
		Format(STRING(strFormat), "4|%i", itemID);
		menu.AddItem(strFormat, "4");
	}
	
	if(rp_GetClientItem(client, itemID, false) >= 5)
	{
		Format(STRING(strFormat), "5|%i", itemID);
		menu.AddItem(strFormat, "5");
	}
	
	if(rp_GetClientItem(client, itemID, false) >= 10)
	{
		Format(STRING(strFormat), "10|%i", itemID);
		menu.AddItem(strFormat, "10");
	}
	
	if(rp_GetClientItem(client, itemID, false) >= 50)
	{
		Format(STRING(strFormat), "50|%i", itemID);
		menu.AddItem(strFormat, "50");
	}
	
	if(rp_GetClientItem(client, itemID, false) >= 100)
	{
		Format(STRING(strFormat), "100|%i", itemID);
		menu.AddItem(strFormat, "100");
	}
	
	menu.ExitBackButton = true;
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Quantity_Type_Plus_Final(Menu menu, MenuAction action, int client, int param)
{	
	if(action == MenuAction_Select)
	{
		char info[10], buffer[2][64];
		menu.GetItem(param, STRING(info));
		ExplodeString(info, "|", buffer, 2, 64);
		
		int quantity = StringToInt(buffer[0]);
		int itemID = StringToInt(buffer[1]);
		iData[client].SetItemSellId = itemID;
		
		rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - quantity, false);
		
		char query[1024];
		Format(STRING(query), "SELECT `quantity` FROM `rp_hotelvente` WHERE `vendeur` = '%s' AND `itemid` = '%i'", iData[client].SteamID, itemID);
		DBResultSet Results = SQL_Query(g_DB, query);
		
		if(Results.FetchRow())
		{
			int query_quantity = Results.FetchInt(0);
			query_quantity += quantity;
			
			SQL_Request(g_DB, "UPDATE `rp_hotelvente` SET `quantity` = '%i' WHERE `vendeur` = '%s' AND `itemid` = '%i';", query_quantity, iData[client].SteamID, itemID);
		}	
		delete Results;
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if(param == MenuCancel_ExitBack)
			MenuHotelVente_Edit(client);
	}
	else if(action == MenuAction_End)
		delete menu;
	
	return 0;
}

void Menu_Edit_Quantity_Type_Minus(int client, int itemID)
{
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Quantity_Type_Minus_Final);	
	menu.SetTitle("Choisissez la quantité à retirer.");

	char query[1024];
	Format(STRING(query), "SELECT `quantity` FROM `rp_hotelvente` WHERE `vendeur` = '%s' AND `itemid` = '%i'", iData[client].SteamID, itemID);
	DBResultSet Results = SQL_Query(g_DB, query);
	
	if(Results.FetchRow())
	{
		int query_quantity = Results.FetchInt(0);
	
		char strFormat[32];
		if(query_quantity >= 1)
		{
			Format(STRING(strFormat), "1|%i", itemID);
			menu.AddItem(strFormat, "1");
		}
		
		if(query_quantity >= 2)
		{
			Format(STRING(strFormat), "2|%i", itemID);
			menu.AddItem(strFormat, "2");
		}
		
		if(query_quantity >= 3)
		{
			Format(STRING(strFormat), "3|%i", itemID);
			menu.AddItem(strFormat, "3");
		}
		
		if(query_quantity >= 4)
		{
			Format(STRING(strFormat), "4|%i", itemID);
			menu.AddItem(strFormat, "4");
		}
		
		if(query_quantity >= 5)
		{
			Format(STRING(strFormat), "5|%i", itemID);
			menu.AddItem(strFormat, "5");
		}
		
		if(query_quantity >= 10)
		{
			Format(STRING(strFormat), "10|%i", itemID);
			menu.AddItem(strFormat, "10");
		}
		
		if(query_quantity >= 50)
		{
			Format(STRING(strFormat), "50|%i", itemID);
			menu.AddItem(strFormat, "50");
		}
		
		if(query_quantity >= 100)
		{
			Format(STRING(strFormat), "100|%i", itemID);
			menu.AddItem(strFormat, "100");
		}
		
		if(query_quantity >= 1)	
		{
			Format(STRING(strFormat), "%i|%i", query_quantity, itemID);
			menu.AddItem(strFormat, "Tout");
		}
	}	
	delete Results;	
	
	menu.ExitBackButton = true;
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Quantity_Type_Minus_Final(Menu menu, MenuAction action, int client, int param)
{	
	if(action == MenuAction_Select)
	{
		char info[10], buffer[2][64];
		menu.GetItem(param, STRING(info));
		ExplodeString(info, "|", buffer, 2, 64);
		
		int quantity = StringToInt(buffer[0]);
		int itemID = StringToInt(buffer[1]);
		iData[client].SetItemSellId = itemID;
		
		rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) + quantity, false);
		
		char query[1024];
		Format(STRING(query), "SELECT `quantity` FROM `rp_hotelvente` WHERE `vendeur` = '%s' AND `itemid` = '%i'", iData[client].SteamID, itemID);
		DBResultSet Results = SQL_Query(g_DB, query);
		
		if(Results.FetchRow())
		{
			int query_quantity = Results.FetchInt(0);
			query_quantity -= quantity;
			
			SQL_Request(g_DB, "UPDATE `rp_hotelvente` SET `quantity` = '%i' WHERE `vendeur` = '%s' AND `itemid` = '%i';", query_quantity, iData[client].SteamID, itemID);
		}	
		delete Results;
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if(param == MenuCancel_ExitBack)
			MenuHotelVente_Edit(client);
	}
	else if(action == MenuAction_End)
		delete menu;
	
	return 0;
}

void MenuHotelVente_Edit_Delete(int client, int itemID)
{
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(MenuHotelVente_Edit_Delete_Final);	
	menu.SetTitle("Confirmez votre choix.");	
	
	char strFormat[32];
	
	Format(STRING(strFormat), "%i|oui", itemID);
	menu.AddItem(strFormat, "Oui, Retirer");
	
	menu.AddItem("", "Non, Annuler");
	
	menu.ExitBackButton = true;
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHotelVente_Edit_Delete_Final(Menu menu, MenuAction action, int client, int param)
{	
	if(action == MenuAction_Select)
	{
		char info[10], buffer[2][64];
		menu.GetItem(param, STRING(info));
		ExplodeString(info, "|", buffer, 2, 64);
		int itemID = StringToInt(buffer[0]);
		
		if(StrEqual(buffer[1], "oui"))
		{		
			char query[1024];
			Format(STRING(query), "SELECT `quantity` FROM `rp_hotelvente` WHERE `vendeur` = '%s' AND `itemid` = '%i'", iData[client].SteamID, itemID);
			DBResultSet Results = SQL_Query(g_DB, query);
			
			if(Results.FetchRow())
			{
				int query_quantity = Results.FetchInt(0);
				rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) + query_quantity, false);
				
				SQL_Request(g_DB, "DELETE FROM `rp_hotelvente` WHERE `vendeur` = '%s' AND `itemid` = '%i'", iData[client].SteamID, itemID);
				
				char itemname[64];
				rp_GetItemData(itemID, item_name, STRING(itemname));
				
				rp_PrintToChat(client, "Vous avez retiré %s de l'hôtel des ventes.", itemname);
			}	
			delete Results;
		}
		else
			rp_SetClientBool(client, b_DisplayHud, true);		
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if(param == MenuCancel_ExitBack)
			MenuHotelVente_Edit(client);
	}
	else if(action == MenuAction_End)
		delete menu;
	
	return 0;
}

public Action Cmd_GivePlayer(int client, int arg)
{
	#if DEBUG
		Translation_DebugCommand(client);
	#endif
	
	int target = GetClientAimTarget(client, true);
	if(!IsClientValid(target))
	{
		Translation_PrintInvalidTarget(client);
		return Plugin_Handled;
	}
	else if(arg < 1)
	{
		char args_cmd[32];
		GetCmdArg(0, STRING(args_cmd));
		rp_PrintToChat(client, "Utilisation: /%s <somme>.", args_cmd);
		return Plugin_Handled;
	}
	
	char args[32];
	GetCmdArg(1, STRING(args));
	if(!String_IsNumeric(args))
	{
		rp_PrintToChat(client, "La somme doit être précisée en chiffre !");
		return Plugin_Handled;
	}
	int amount = StringToInt(args);
		
	if(rp_GetClientInt(client, i_Money) >= amount)
	{
		rp_SetClientInt(client, i_Money, rp_GetClientInt(client, i_Money) - amount);
		rp_SetClientInt(target, i_Money, rp_GetClientInt(target, i_Money) + amount);
		rp_PrintToChat(client, "Vous avez donnée %i$ à %N.", amount, target);
		CPrintToChat(target, "%s %N vous a donner %i$.", client, amount);
	}
	else
		rp_PrintToChat(client, "Vous n'avez pas assez d'argent.");
		
	return Plugin_Handled;
}		

void SQL_SaveClient(int client)
{
	for(int job = 1; job <= MAXJOBS; job++)
	{
		if(!rp_CanJobSell(job))
			continue;
		
		LoopItems(i)
		{
			if(!rp_IsItemValidIndex(i))
				continue;
			
			if(rp_GetClientItem(client, i, true) > 0)
			{
				rp_SetClientItem(client, i, rp_GetClientItem(client, i, true) + rp_GetClientItem(client, i, false), true);
				rp_SetClientItem(client, i, 0, false);
				SQL_Request(g_DB, "UPDATE `rp_items` SET `%i` = '%i' WHERE `steamid` = '%s';", i, rp_GetClientItem(client, i, true), iData[client].SteamID);	
			}	
		}
	}	
}	