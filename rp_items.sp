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

enum struct ItemData {
	char name[64];
	char reuse_delay[64];
	char jobid[64];
	char price[64];
	char description[64];
	char newitem[64];
	char farmtime[64];
	char maxquantity[64];
	char gold[64];
	char steel[64];
	char copper[64];
	char aluminium[64];
	char zinc[64];
	char wood[64];
	char plastic[64];
	char water[64];
	bool IsValid;
	int Stock;
}
ItemData iItem[MAXITEMS + 1];

enum struct ClientData {
	char steamID[32];
	bool itemOnTimerReset[MAXITEMS + 1];
	bool canUseItem[MAXITEMS + 1];
	int item[MAXITEMS + 1];
	int bank[MAXITEMS + 1];
}
ClientData iData[MAXPLAYERS + 1];

GlobalForward
	OnInventory_Handle;
Database 
	g_DB;
	
// Methodmap Constructor
Roleplay m_iClient[MAXPLAYERS + 1];	

/***************************************************************************************

							P L U G I N  -  I N F O

***************************************************************************************/
public Plugin myinfo = 
{
	name = "Roleplay - Items", 
	author = "MBK", 
	description = "Items management", 
	version = "1.0", 
	url = "https://github.com/Mbk10201"
};

/***************************************************************************************

									 F U N C T I O N S

***************************************************************************************/

public void OnPluginStart()
{
	// Load translation, global & local
	LoadTranslation();
	LoadTranslations("rp_items.phrases");
		
	// Print to server console the plugin status
	PrintToServer("[REQUIREMENT] ITEMS ✓");
	
	/*----------------------------------Commands-------------------------------*/
	// Register all local plugin commands available in game
	RegConsoleCmd("i", Command_Inventory);
	RegConsoleCmd("inv", Command_Inventory);
	RegConsoleCmd("sac", Command_Inventory);
	RegConsoleCmd("item", Command_Inventory);
	/*-------------------------------------------------------------------------------*/
	
	SetItems();
}

public void RP_OnSQLInit(Database db, Transaction transaction)
{
	g_DB = db;
	
	char sBuffer[MAX_BUFFER_LENGTH + 1];
	
	Format(STRING(sBuffer), "CREATE TABLE IF NOT EXISTS `rp_items_data` (\
	`id` int(20) NOT NULL, \
	`name` varchar(64) NOT NULL, \ 
	`delay_use` varchar(16) NOT NULL, \
	`jobid` varchar(16) NOT NULL, \
	`price` varchar(16) NOT NULL, \
	`description` varchar(256) NOT NULL, \
	`farm_time` varchar(16) NOT NULL, \
	PRIMARY KEY (`id`), \ 
	UNIQUE KEY `id` (`id`) \
	)ENGINE = InnoDB DEFAULT CHARSET = utf8 COLLATE = utf8_bin;");
	#if DEBUG
		PrintToServer(sBuffer);
	#endif
	transaction.AddQuery(sBuffer);
	
	Format(STRING(sBuffer), "CREATE TABLE IF NOT EXISTS `rp_items` (\
	`playerid` int(20) NOT NULL, \
	PRIMARY KEY (`playerid`), \
	FOREIGN KEY (`playerid`) REFERENCES `rp_players` (`id`) ON DELETE CASCADE ON UPDATE CASCADE \
	)ENGINE = InnoDB DEFAULT CHARSET = utf8 COLLATE = utf8_bin;");
	#if DEBUG
		PrintToServer(sBuffer);
	#endif
	transaction.AddQuery(sBuffer);
	
	LoopItems(i)
	{
		if(!iItem[i].IsValid)
			continue;
		
		char sName[64];
		rp_GetItemData(i, item_name, STRING(sName));
		
		char sDelayUse[16];
		rp_GetItemData(i, item_reuse_delay, STRING(sDelayUse));
		
		char sJobID[16];
		rp_GetItemData(i, item_jobid, STRING(sJobID));
		
		char sPrice[16];
		rp_GetItemData(i, item_price, STRING(sPrice));
		
		char sDescription[256];
		rp_GetItemData(i, item_description, STRING(sDescription));
		SQL_EscapeString(db, sDescription, STRING(sDescription)); // TODO
		
		//ReplaceString(STRING(sDescription), "é", "e", false);
		
		char sFarmTime[8];
		rp_GetItemData(i, item_farmtime, STRING(sFarmTime));
		
		char sMaxQuantity[8];
		rp_GetItemData(i, item_maxquantity, STRING(sMaxQuantity));
		
		char sGold[16];
		rp_GetItemData(i, item_maxgold, STRING(sGold));
		
		char sSteel[16];
		rp_GetItemData(i, item_maxsteel, STRING(sSteel));
		
		char sCopper[16];
		rp_GetItemData(i, item_maxcopper, STRING(sCopper));
		
		char sAluminium[16];
		rp_GetItemData(i, item_maxaluminium, STRING(sAluminium));
		
		char sZinc[16];
		rp_GetItemData(i, item_maxzinc, STRING(sZinc));
		
		char sWood[16];
		rp_GetItemData(i, item_maxwood, STRING(sWood));
		
		char sPlastic[16];
		rp_GetItemData(i, item_maxplastic, STRING(sPlastic));
		
		char sWater[16];
		rp_GetItemData(i, item_maxwater, STRING(sWater));
		
		Format(STRING(sBuffer), "INSERT IGNORE INTO `rp_items_data` (`id`, `name`, `delay_use`, `jobid`, `price`, `description`, `farm_time`) VALUES ('%i', '%s', '%s', '%s', '%s', '%s', '%s');", i, sName, sDelayUse, sJobID, sPrice, sDescription, sFarmTime);
		#if DEBUG
			PrintToServer(sBuffer);
		#endif
		transaction.AddQuery(sBuffer);
		
		Format(STRING(sBuffer), "ALTER IGNORE TABLE `rp_items` ADD COLUMN IF NOT EXISTS `%i` int(100) NOT NULL AFTER `playerid`;", i);
		#if DEBUG
			PrintToServer(sBuffer);
		#endif
		transaction.AddQuery(sBuffer);
	}
}

public void OnPluginEnd()
{
	LoopClients(i)
	{
		if(!IsClientValid(i))
			continue;			
		SQL_SaveClient(i);
	}
	
	LoopItems(i)
	{
		if(rp_GetItemStock(i) > 0)
			SQL_Request(g_DB, "UPDATE `rp_items_stock` SET `%i` = '%i';", i, rp_GetItemStock(i));
	}	
}

public void OnMapEnd()
{
	LoopClients(i)
	{
		if(!IsClientValid(i))
			continue;
		SQL_SaveClient(i);
	}

	LoopItems(i)
	{
		if(rp_GetItemStock(i) > 0)
			SQL_Request(g_DB, "UPDATE `rp_items_stock` SET `%i` = '%i';", i, rp_GetItemStock(i));
	}		
}

public void OnMapStart()
{
	//SetItemStock();
}	

public void OnClientDisconnect(int client)
{
	SQL_SaveClient(client);
}

public void RP_OnReboot()
{
	LoopClients(i)
	{
		if(!IsClientValid(i))
			continue;
			
		SQL_SaveClient(i);	
	}
}

void SQL_SaveClient(int client)
{
	LoopItems(items)
		if(rp_GetClientItem(client, items, true) > 0)
			SQL_Request(g_DB, "UPDATE `rp_items` SET `%i` = '%i' WHERE `playerid` = '%i';", items, rp_GetClientItem(client, items, true), rp_GetSQLID(client));	
}	

public void OnClientPostAdminCheck(int client) 
{	
	if(!IsClientValid(client))
		return;
	
	char buffer[1024];
	Format(STRING(buffer), 
	"INSERT IGNORE INTO `rp_items` ( \
	  `playerid`\
	  ) VALUES ('%i');", rp_GetSQLID(client));	
	#if DEBUG
		PrintToServer("[RP_SQL] %s", buffer);	
	#endif	
	g_DB.Query(SQL_CheckForErrors, buffer);
	
	SQL_LoadClient(client);
}

public void SQL_LoadClient(int client) 
{
	if(!IsClientValid(client))
		return;
			
	char buffer[512];
	Format(STRING(buffer), "SELECT * FROM `rp_items` WHERE `playerid` = '%i';", rp_GetSQLID(client));
	#if DEBUG
		PrintToServer("[RP_SQL] %s", buffer);	
	#endif	
	g_DB.Query(SQL_Callback, buffer, GetClientUserId(client));
}

public void SQL_Callback(Database db, DBResultSet results, const char[] error, any data) 
{	
	int client = GetClientOfUserId(data);
	int item = 1;
	while (results.FetchRow()) 
	{
		item++;
		
		if(!iItem[item].IsValid)
			continue;
		
		char itemid[10];
		IntToString(item, STRING(itemid));
		int value = 0;
		results.FetchIntByName(itemid, value);
		rp_SetClientItem(client, item, value, true);
	}
} 
/***************************************************************************************

									N A T I V E S

***************************************************************************************/
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) 
{
	/*------------------------------------FORWADS------------------------------------*/
	OnInventory_Handle = new GlobalForward("RP_OnInventoryHandle", ET_Event, Param_Cell, Param_Cell);	
	/*-------------------------------------------------------------------------------*/
	
	CreateNative("rp_GetClientItem", Native_GetClientItem);
	CreateNative("rp_SetClientItem", Native_SetClientItem);
	
	CreateNative("rp_GetItemData", Native_GetItemData);
	CreateNative("rp_SetItemData", Native_SetItemData);
	
	CreateNative("rp_GetCanUseItem", Native_GetCanUseItem);
	CreateNative("rp_SetCanUseItem", Native_SetCanUseItem);
	
	CreateNative("rp_SetClientDelayItemStat", Native_SetClientDelayItemStat);
	
	CreateNative("rp_GetItemStock", Native_GetItemStock);
	CreateNative("rp_SetItemStock", Native_SetItemStock);
	
	CreateNative("rp_IsItemValidIndex", Native_IsItemValidIndex);
	
	return APLRes_Success;
}

public int Native_GetClientItem(Handle plugin, int numParams) 
{
	int client = GetNativeCell(1);
	int itemid = GetNativeCell(2);
	bool banked = view_as<bool>(GetNativeCell(3));
	
	if(!IsClientValid(client))
		return -1;
	
	if(banked)
		return iData[client].bank[itemid];
	else
		return iData[client].item[itemid];
}

public int Native_SetClientItem(Handle plugin, int numParams) 
{
	int client = GetNativeCell(1);
	int itemid = GetNativeCell(2);
	int value = GetNativeCell(3);
	bool banked = view_as<bool>(GetNativeCell(4));
	
	if(!IsClientValid(client))
		return -1;
	
	if(banked)
		return iData[client].bank[itemid] = value;
	else
		return iData[client].item[itemid] = value;
}

public int Native_GetItemData(Handle plugin, int numParams) 
{
	int itemID = GetNativeCell(1);
	int variable = GetNativeCell(2);
	int maxlen = GetNativeCell(4) + 1;
	
	switch(variable)
	{
		case item_name:SetNativeString(3, iItem[itemID].name, maxlen);
		case item_reuse_delay:SetNativeString(3, iItem[itemID].reuse_delay, maxlen);
		case item_jobid:SetNativeString(3, iItem[itemID].jobid, maxlen);
		case item_price:SetNativeString(3, iItem[itemID].price, maxlen);
		case item_description:SetNativeString(3, iItem[itemID].description, maxlen);
		case item_new:SetNativeString(3, iItem[itemID].newitem, maxlen);
		case item_farmtime:SetNativeString(3, iItem[itemID].farmtime, maxlen);
		case item_maxquantity:SetNativeString(3, iItem[itemID].maxquantity, maxlen);
	}

	return -1;
}

public int Native_SetItemData(Handle plugin, int numParams) 
{
	int itemID = GetNativeCell(1);
	int variable = GetNativeCell(2);
	int maxlen = GetNativeCell(4) + 1;
	
	switch(variable)
	{
		case item_name:GetNativeString(3, iItem[itemID].name, maxlen);
		case item_reuse_delay:GetNativeString(3, iItem[itemID].reuse_delay, maxlen);
		case item_jobid:GetNativeString(3, iItem[itemID].jobid, maxlen);
		case item_price:GetNativeString(3, iItem[itemID].price, maxlen);
		case item_description:GetNativeString(3, iItem[itemID].description, maxlen);
		case item_new:GetNativeString(3, iItem[itemID].newitem, maxlen);
		case item_farmtime:GetNativeString(3, iItem[itemID].farmtime, maxlen);
		case item_maxquantity:GetNativeString(3, iItem[itemID].maxquantity, maxlen);
	}

	return -1;
}

public int Native_GetCanUseItem(Handle plugin, int numParams) 
{
	int client = GetNativeCell(1);
	int itemID = GetNativeCell(2);			
	
	return iData[client].canUseItem[itemID];
}

public int Native_SetCanUseItem(Handle plugin, int numParams) 
{
	int client = GetNativeCell(1);
	int itemID = GetNativeCell(2);
	bool value = view_as<bool>(GetNativeCell(3));			
	
	return iData[client].canUseItem[itemID] = value;
}

public int Native_SetClientDelayItemStat(Handle plugin, int numParams) 
{
	int client = GetNativeCell(1);
	int itemID = GetNativeCell(2);
	bool value = view_as<bool>(GetNativeCell(3));			
	
	return iData[client].itemOnTimerReset[itemID] = value;
}

public int Native_GetItemStock(Handle plugin, int numParams) 
{
	int itemID = GetNativeCell(1);	
	
	return iItem[itemID].Stock;
}

public int Native_SetItemStock(Handle plugin, int numParams) 
{
	int itemID = GetNativeCell(1);	
	int value = GetNativeCell(2);
	
	return iItem[itemID].Stock = value;
}

public int Native_IsItemValidIndex(Handle plugin, int numParams) 
{
	return iItem[GetNativeCell(1)].IsValid;
}
/***************************************************************************************

									C L I E N T - S I D E

***************************************************************************************/

public void OnClientPutInServer(int client)
{
	// MethodMap Constructor
	m_iClient[client] = Roleplay(client);
	
	LoopItems(i)
	{
		iData[client].item[i] = 0;
		iData[client].bank[i] = 0;
		iData[client].canUseItem[i] = true;
		iData[client].itemOnTimerReset[i] = false;
	}		
}

public void OnClientAuthorized(int client, const char[] auth) 
{	
	strcopy(iData[client].steamID, sizeof(iData[].steamID), auth);
}

/***************************************************************************************

									C A L L B A C K

***************************************************************************************/

public Action Command_Inventory(int client, int args)
{
	if (client == 0)
	{
		Translation_PrintNoAvailable();
		return Plugin_Handled;
	}
	else if(!IsClientValid(client, true))
	{
		Translation_PrintNoAccess(client);
		return Plugin_Handled;
	}	
	
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(MenuInventory_Handle);
	menu.SetTitle("%t", "Inventory_Title", LANG_SERVER, rp_GetClientInt(client, i_MaxSelfItem));
	
	int count;
	LoopItems(i)
	{
		if(rp_GetClientItem(client, i, false) > 0)
		{
			count++;
			char name[64], item_handle[64];
			rp_GetItemData(i, item_name, STRING(name));
			
			Format(STRING(name), "%s [%i]", name, rp_GetClientItem(client, i, false));
			Format(STRING(item_handle), "%i", i);
			menu.AddItem(item_handle, name);
		}	
	}		
	
	if(count == 0)
	{
		rp_PrintToChat(client, "%T", "Item_None", LANG_SERVER);
		rp_SetClientBool(client, b_DisplayHud, true);
		return Plugin_Handled;	
	}	
		
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);	
	
	return Plugin_Handled;
}	

public int MenuInventory_Handle(Menu menu, MenuAction action, int client, int param)
{
	if (action == MenuAction_Select)
	{
		char info[32];
		menu.GetItem(param, STRING(info));
		
		Call_StartForward(OnInventory_Handle);
		Call_PushCell(client);
		Call_PushCell(StringToInt(info));
		Call_Finish();
		
		if(!iData[client].canUseItem[StringToInt(info)])
			rp_PrintToChat(client, "%T", "Item_Cooldown", LANG_SERVER);
		else
		{		
			if(iData[client].canUseItem[StringToInt(info)] && !iData[client].itemOnTimerReset[StringToInt(info)])
			{
				rp_Sound(client, "sound_inventory", 0.5);
				
				iData[client].canUseItem[StringToInt(info)] = false;
				iData[client].itemOnTimerReset[StringToInt(info)] = true;		
				char reuse_delay[12];
				rp_GetItemData(StringToInt(info), item_reuse_delay, STRING(reuse_delay));
				float delay = StringToFloat(reuse_delay);	
				DataPack dp = new DataPack();
				CreateDataTimer(delay, Timer_ResetItemDelay, dp);
				dp.WriteCell(client);
				dp.WriteCell(StringToInt(info));	
				
				char strPrice[16];
				rp_GetItemData(StringToInt(info), item_price, STRING(strPrice));
				
				rp_SetClientStat(client, i_ItemUsed, rp_GetClientStat(client, i_ItemUsed) + 1);
				rp_SetClientStat(client, i_ItemUsedPrice, rp_GetClientStat(client, i_ItemUsedPrice) + StringToInt(strPrice));
				
				char description[256];
				rp_GetItemData(StringToInt(info), item_description, STRING(description));	
				rp_PrintToChat(client, "Description: \n{lightgreen}%s.", description);
			}
		}	
		FakeClientCommand(client, "say !i");
	}	
	else if (action == MenuAction_Cancel)
	{
		if (param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
	}
	else if (action == MenuAction_End)
		delete menu;
	
	return 0;
}

stock Action Timer_ResetItemDelay(Handle timer, DataPack dp)
{
	dp.Reset();
	int client = dp.ReadCell();
	int itemID = dp.ReadCell();	
	rp_SetCanUseItem(client, itemID, true);
	rp_SetClientDelayItemStat(client, itemID, false);
	
	return Plugin_Handled;
}

void SetItems()
{
	char sPath[PLATFORM_MAX_PATH];
	KeyValues kv = new KeyValues("Items");
	BuildPath(Path_SM, STRING(sPath), "data/roleplay/items.cfg");
	Kv_CheckIfFileExist(kv, sPath);
	
	// Jump into the first subsection
	if (!kv.GotoFirstSubKey())
	{
		PrintToServer("ERROR FIRST KEY");
		delete kv;
		return;
	}
	
	char sTmp[128];
	int id;
	do {
		if(kv.GetSectionName(STRING(sTmp)))
		{
			id = StringToInt(sTmp);
			
			char translation[64];
			Format(STRING(translation), "%T", sTmp, LANG_SERVER);
			rp_SetItemData(id, item_name, STRING(translation));
		
			kv.GetString("delay", STRING(sTmp));
			rp_SetItemData(id, item_reuse_delay, STRING(sTmp));
			
			kv.GetString("jobid", STRING(sTmp));
			rp_SetItemData(id, item_jobid, STRING(sTmp));
		
			kv.GetString("price", STRING(sTmp));
			rp_SetItemData(id, item_price, STRING(sTmp));
	
			kv.GetString("description", STRING(sTmp));
			
			if(!StrEqual(sTmp, ""))
				rp_SetItemData(id, item_description, STRING(sTmp));
			else
				rp_SetItemData(id, item_description, "Aucune", 7);
	
			kv.GetString("new", STRING(sTmp));
			rp_SetItemData(id, item_new, STRING(sTmp));
			
			kv.GetString("farmtime", STRING(sTmp));
			rp_SetItemData(id, item_farmtime, STRING(sTmp));
			
			kv.GetString("maxquantity", STRING(sTmp));
			rp_SetItemData(id, item_maxquantity, STRING(sTmp));
			
			if(kv.JumpToKey("components"))
			{
				kv.GetString("gold", STRING(sTmp));
				rp_SetItemData(id, item_maxgold, STRING(sTmp));
				
				kv.GetString("steel", STRING(sTmp));
				rp_SetItemData(id, item_maxsteel, STRING(sTmp));
				
				kv.GetString("copper", STRING(sTmp));
				rp_SetItemData(id, item_maxcopper, STRING(sTmp));
				
				kv.GetString("aluminium", STRING(sTmp));
				rp_SetItemData(id, item_maxaluminium, STRING(sTmp));
				
				kv.GetString("zinc", STRING(sTmp));
				rp_SetItemData(id, item_maxzinc, STRING(sTmp));
				
				kv.GetString("wood", STRING(sTmp));
				rp_SetItemData(id, item_maxwood, STRING(sTmp));
				
				kv.GetString("plastic", STRING(sTmp));
				rp_SetItemData(id, item_maxplastic, STRING(sTmp));
				
				kv.GetString("water", STRING(sTmp));
				rp_SetItemData(id, item_maxwater, STRING(sTmp));
				
				kv.GoBack();
			}
			
			iItem[id].IsValid = true;
		}	
	}	
	while (kv.GotoNextKey());
	kv.Rewind();
	delete kv;
}