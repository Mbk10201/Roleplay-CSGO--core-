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

#define price_bonus 500
#define JOBID	6

/***************************************************************************************

							G L O B A L  -  V A R S

***************************************************************************************/

char 
	steamID[MAXPLAYERS + 1][32];
int
	iBoxAppart[MAXAPPART + 1] = {-1, ...},
	iBoxVilla[MAXVILLA + 1] = {-1, ...},
	iBoxHotel[MAXHOTEL + 1] = {-1, ...},
	iVillaRentTime[MAXPLAYERS + 1];
bool 
	asKey_appart[MAXPLAYERS + 1][MAXAPPART + 1],
	asKey_villa[MAXPLAYERS + 1][MAXVILLA + 1],
	asKey_hotel[MAXPLAYERS + 1][MAXHOTEL + 1],
	box_appart[MAXAPPART + 1],
	box_villa[MAXVILLA + 1],
	box_hotel[MAXHOTEL + 1];
Database 
	g_DB;
ArrayList
	g_aAvailableAppart,
	g_aAvailableVilla,
	g_aAvailableHotel;
KeyValues 
	g_kLocations;

/*enum LOCTYPE {
	APPART = 0,
	VILLA,
	HOTEL
}*/

enum struct BoxType {
	int wepIndex[33];
	int ammoPrimary[33];
	int ammoReserve[33];
	int total;
	int type;
}

BoxType BoxData[MAXPLAYERS + 1];

/***************************************************************************************

							P L U G I N  -  I N F O

***************************************************************************************/
public Plugin myinfo = 
{
	name = "Roleplay - [JOB] Immobilier", 
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
	LoadTranslations("rp_job_immo.txt");
	
	RegConsoleCmd("sm_vendreapp", Command_Vendre);
	
	#if DEBUG
		RegConsoleCmd("rp_testvapp", Command_TestApp);
	#endif	
	
	g_aAvailableAppart = new ArrayList(MAXAPPART, 1);
	g_aAvailableVilla = new ArrayList(MAXVILLA, 1);
	g_aAvailableHotel = new ArrayList(MAXHOTEL, 1);
}

public void RP_OnSQLInit(Database db, Transaction transaction)
{
	g_DB = db;
	
	char sBuffer[MAX_BUFFER_LENGTH + 1];
	
	Format(STRING(sBuffer), "CREATE TABLE IF NOT EXISTS `rp_villa` ( \
	  `id` int(20) NOT NULL, \
	  `ownerid` int(20) NOT NULL, \
	  `time` varchar(64) NOT NULL, \
	  PRIMARY KEY (`id`), \
	  UNIQUE KEY `id` (`id`), \
	  FOREIGN KEY (`ownerid`) REFERENCES `rp_players` (`id`) ON DELETE CASCADE ON UPDATE CASCADE\
	  )ENGINE = InnoDB DEFAULT CHARSET = utf8 COLLATE = utf8_bin;");
	#if DEBUG
		PrintToServer(sBuffer);
	#endif
	transaction.AddQuery(sBuffer);
}

public Action Command_TestApp(int client, int args)
{
	/*if(rp_GetAdmin(client) != ADMIN_FLAG_OWNER)
		return Plugin_Handled;*/
		
	RegisterLocations();
	
	char arg[2];
	GetCmdArg(1, STRING(arg));
	
	if(StringToInt(arg) == 1)	
		SellAppartments(client, client);
	else if(StringToInt(arg) == 2)	
		SellVilla(client, client);	
	else if(StringToInt(arg) == 3)	
		SellHotel(client, client);
	else if(StringToInt(arg) == 4)	
		SellBonus(client, client);
	
	return Plugin_Handled;
}

public void OnMapStart()
{
	for (int i = 1; i <= MAXAPPART; i++)
	{
		rp_SetAppartementInt(i, appart_owner, -1);
		rp_SetAppartementInt(i, appart_price, GetAppartPrice(i));
	}	
	for (int i = 1; i <= MAXVILLA; i++)
	{
		rp_SetVillaInt(i, villa_owner, -1);
		rp_SetVillaInt(i, villa_price, GetVillaPrice(i));
	}
	for (int i = 1; i <= MAXHOTEL; i++)
	{
		rp_SetHotelInt(i, hotel_owner, -1);
		rp_SetHotelInt(i, hotel_price, GetHotelPrice(i));
	}
	
	RegisterLocations();
}

void RegisterLocations()
{
	g_kLocations = new KeyValues("Locations");
	char sPath[PLATFORM_MAX_PATH], map[64];
	rp_GetCurrentMap(STRING(map));
	BuildPath(Path_SM, STRING(sPath), "data/roleplay/%s/locations.cfg", map);
	Kv_CheckIfFileExist(g_kLocations, sPath);	
	
	// Jump into the first subsection
	if (!g_kLocations.GotoFirstSubKey())
	{
		PrintToServer("ERROR FIRST KEY");
		delete g_kLocations;
		return;
	}
	
	
	char buffer[8];
	if(g_kLocations.JumpToKey("appartment"))
	{
		do
		{
			if(g_kLocations.GetSectionName(STRING(buffer)))
			{
				if(vbool(g_kLocations.GetNum("active")) == true)
					g_aAvailableAppart.PushString(buffer);
			}
		} 
		while (g_kLocations.GotoNextKey());
		
		g_kLocations.GoBack();
	}
	
	if(g_kLocations.JumpToKey("villa"))
	{
		do
		{
			if(g_kLocations.GetSectionName(STRING(buffer)))
			{
				if(vbool(g_kLocations.GetNum("active")) == true)
					g_aAvailableVilla.PushString(buffer);
			}
		} 
		while (g_kLocations.GotoNextKey());
		
		g_kLocations.GoBack();
	}
	
	if(g_kLocations.JumpToKey("hotel"))
	{
		do
		{
			if(g_kLocations.GetSectionName(STRING(buffer)))
			{
				if(vbool(g_kLocations.GetNum("active")) == true)
					g_aAvailableHotel.PushString(buffer);
			}
		} 
		while (g_kLocations.GotoNextKey());
		
		g_kLocations.GoBack();
	}
 
	g_kLocations.Rewind();
}

public void OnMapEnd()
{
	for (int i = 1; i <= MAXAPPART; i++)
		rp_SetAppartementInt(i, appart_owner, -1);
	for (int i = 1; i <= MAXHOTEL; i++)
		rp_SetHotelInt(i, hotel_owner, -1);
}

/***************************************************************************************

									N A T I V E S

***************************************************************************************/
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) 
{
	CreateNative("rp_GetClientKeyAppartement", Native_GetClientKeyAppartement);
	CreateNative("rp_SetClientKeyAppartement", Native_SetClientKeyAppartement);
	
	CreateNative("rp_GetClientKeyVilla", Native_GetClientKeyVilla);
	CreateNative("rp_SetClientKeyVilla", Native_SetClientKeyVilla);
	
	CreateNative("rp_GetClientKeyHotel", Native_GetClientKeyHotel);
	CreateNative("rp_SetClientKeyHotel", Native_SetClientKeyHotel);
	
	return APLRes_Success;
}

public int Native_GetClientKeyAppartement(Handle plugin, int numParams) 
{
	int client = GetNativeCell(1);
	int appid = GetNativeCell(2);
	
	if(!IsClientValid(client))
		return false;
		
	if(asKey_appart[client][appid])
		return true;
		
	return false;
}

public int Native_SetClientKeyAppartement(Handle plugin, int numParams) 
{
	int client = GetNativeCell(1);
	int appid = GetNativeCell(2);
	bool value = GetNativeCell(3);
	
	if(!IsClientValid(client))
		return false;
	
	return asKey_appart[client][appid] = value;
}

public int Native_GetClientKeyVilla(Handle plugin, int numParams) 
{
	int client = GetNativeCell(1);
	int appid = GetNativeCell(2);
	
	if(!IsClientValid(client))
		return false;
		
	if(asKey_villa[client][appid])
		return true;
		
	return false;
}

public int Native_SetClientKeyVilla(Handle plugin, int numParams) 
{
	int client = GetNativeCell(1);
	int appid = GetNativeCell(2);
	bool value = GetNativeCell(3);
	
	if(!IsClientValid(client))
		return false;
	
	return asKey_villa[client][appid] = value;
}

public int Native_GetClientKeyHotel(Handle plugin, int numParams) 
{
	int client = GetNativeCell(1);
	int appid = GetNativeCell(2);
	
	if(!IsClientValid(client))
		return false;
		
	if(asKey_hotel[client][appid])
		return true;
		
	return false;
}

public int Native_SetClientKeyHotel(Handle plugin, int numParams) 
{
	int client = GetNativeCell(1);
	int appid = GetNativeCell(2);
	bool value = GetNativeCell(3);
	
	if(!IsClientValid(client))
		return false;
	
	return asKey_hotel[client][appid] = value;
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
	if(rp_GetClientInt(client, i_Appart) != -1)
	{
		int appID = rp_GetClientInt(client, i_Appart);
		
		rp_SetClientKeyAppartement(client, appID, false);
		rp_SetAppartementInt(appID, appart_owner, -1);		
		rp_SetClientInt(client, i_Appart, -1);
		box_appart[appID] = false;
	}
	else if(rp_GetClientInt(client, i_Villa) != -1)
	{
		int id = rp_GetClientInt(client, i_Villa);
		box_villa[id] = false;
	}
	else if(rp_GetClientInt(client, i_Hotel) != -1)
	{
		int id = rp_GetClientInt(client, i_Hotel);
		box_hotel[id] = false;
	}

	rp_SetClientBool(client, b_HasBonusHealth, false);
	rp_SetClientBool(client, b_HasBonusKevlar, false);	
	rp_SetClientBool(client, b_HasBonusPay, false);
	rp_SetClientBool(client, b_HasBonusBox, false);	
	rp_SetClientBool(client, b_HasBonusTomb, false);
}		

public void OnClientPutInServer(int client)
{
	rp_SetClientBool(client, b_HasBonusHealth, false);
	rp_SetClientBool(client, b_HasBonusKevlar, false);	
	rp_SetClientBool(client, b_HasBonusPay, false);
	rp_SetClientBool(client, b_HasBonusBox, false);
	rp_SetClientBool(client, b_HasBonusTomb, false);
	rp_SetClientInt(client, i_Appart, -1);
	rp_SetClientInt(client, i_Villa, -1);
	rp_SetClientInt(client, i_Hotel, -1);
	
	iVillaRentTime[client] = 0;
	
	for (int i = 0; i <= 3; i++)
		BoxData[client].wepIndex[i] = -1;
	BoxData[client].total = 0;
}	

public void SQL_LOAD(int client) 
{
	char sQuery[MAX_BUFFER_LENGTH + 1];
	Format(STRING(sQuery), "SELECT * FROM `rp_villa` WHERE `ownerid` = '%i'", rp_GetSQLID(client));
	#if DEBUG
		PrintToServer("[RP_SQL] %s", sQuery);
	#endif
	g_DB.Query(SQL_QueryCallBack, sQuery, GetClientUserId(client));
}

public void SQL_QueryCallBack(Database db, DBResultSet Results, const char[] error, any data) 
{	
	int client = GetClientOfUserId(data);
	if(Results.FetchRow()) 
	{
		int id, time;
		Results.FetchIntByName("id", id);
		Results.FetchIntByName("time", time);
		
		if(GetTime() < (time + GetTime()))
		{
			rp_SetClientInt(client, i_Villa, id);
			rp_SetVillaInt(id, villa_owner, client);
			iVillaRentTime[client] = time;
		}
		else
		{
			rp_PrintToChatAll("La villa Nº{green}%i{default} est disponible à la vente.", id);
			SQL_Request(g_DB, "UPDATE `rp_villa` SET `ownerid` = '0', `time` = '0' WHERE `id` = '%i';", id);
		}	
	}
}

public void RP_OnClientFirstSpawnMessage(int client)
{
	if(iVillaRentTime[client] > 0)
	{
		char sTmp[64];
		StringTime((GetTime() + iVillaRentTime[client]), STRING(sTmp));
		
		CPrintToChat(client, "%T", "Core_WelcomeVilla", LANG_SERVER, sTmp);
	}
}

/***************************************************************************************

									C A L L B A C K

***************************************************************************************/

public Action Command_Vendre(int client, int arg)
{
	if (client == 0)
	{
		PrintToServer("%T", "Command_NotAvailable", LANG_SERVER);
		return Plugin_Handled;
	}
	int target = GetClientAimTarget(client, true);
	if(!IsClientValid(target))
	{
		Translation_PrintInvalidTarget(client);
		return Plugin_Handled;
	}
	else if(rp_GetClientInt(client, i_JailTime) != 0)
	{
		Translation_PrintNoAccessInJail(client);
		return Plugin_Handled;
	}
	else if(rp_GetClientInt(client, i_Job) != JOBID)
	{
		Translation_PrintNoAccess(client);
		return Plugin_Handled;
	}
	
	MenuSell(client, target);
	
	return Plugin_Handled;
}

void MenuSell(int client, int target)
{
	char strIndex[64], translation[64];	
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_MenuSellType);
	menu.SetTitle("%T", "Product_Type", LANG_SERVER);
	
	Format(STRING(translation), "%T", "Product_Type_Appart", LANG_SERVER);
	Format(STRING(strIndex), "appart|%i", target);
	if(rp_GetClientInt(target, i_Appart) != -1)
		menu.AddItem("", "Ce joueur à déjà un appartement.", ITEMDRAW_DISABLED);
	else
		menu.AddItem(strIndex, translation);

	Format(STRING(translation), "%T", "Product_Type_Villa", LANG_SERVER);
	Format(STRING(strIndex), "villa|%i", target);
	if(rp_GetClientInt(target, i_Villa) != -1)
		menu.AddItem("", "Ce joueur à déjà une villa.", ITEMDRAW_DISABLED);
	else
		menu.AddItem(strIndex, translation);
		
	Format(STRING(translation), "%T", "Product_Type_Hotel", LANG_SERVER);
	Format(STRING(strIndex), "hotel|%i", target);
	if(rp_GetClientInt(target, i_Hotel) != -1)
		menu.AddItem("", "Ce joueur à déjà une chambre d'hôtel.", ITEMDRAW_DISABLED);
	else
		menu.AddItem(strIndex, translation);
	
	Format(STRING(translation), "%T", "Product_Type_Bonus", LANG_SERVER);
	Format(STRING(strIndex), "bonus|%i", target);
	menu.AddItem(strIndex, translation);
	
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}	

public int Handle_MenuSellType(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[64], buffer[2][64];
		menu.GetItem(param, STRING(info));
		ExplodeString(info, "|", buffer, 2, 64);
		
		int target = StringToInt(buffer[1]);		
		
		if(StrEqual(buffer[0], "appart"))
			SellAppartments(client, target);
		else if(StrEqual(buffer[0], "villa"))
			SellVilla(client, target);
		else if(StrEqual(buffer[0], "hotel"))
			SellHotel(client, target);
		else if(StrEqual(buffer[0], "bonus"))
			SellBonus(client, target);
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

void SellBonus(int client, int target)
{
	char translation[64], strIndex[64];
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_MenuVendre);
	menu.SetTitle("%T", "Bonus_Type", LANG_SERVER);
	
	Format(STRING(translation), "%T", "Bonus_Type_Health", LANG_SERVER);
	Format(STRING(strIndex), "%i|Bonus_Type_Health", target);	
	if(rp_GetClientBool(target, b_HasBonusHealth))
		menu.AddItem(strIndex, translation, ITEMDRAW_DISABLED);	
	else
		menu.AddItem(strIndex, translation);
	
	Format(STRING(translation), "%T", "Bonus_Type_Kevlar", LANG_SERVER);
	Format(STRING(strIndex), "%i|Bonus_Type_Kevlar", target);
	if(rp_GetClientBool(target, b_HasBonusKevlar))
		menu.AddItem(strIndex, translation, ITEMDRAW_DISABLED);	
	else
		menu.AddItem(strIndex, translation);	
	
	Format(STRING(translation), "%T", "Bonus_Type_Pay", LANG_SERVER);
	Format(STRING(strIndex), "%i|Bonus_Type_Pay", target);
	if(rp_GetClientBool(target, b_HasBonusPay))
		menu.AddItem(strIndex, translation, ITEMDRAW_DISABLED);	
	else
		menu.AddItem(strIndex, translation);	
	
	Format(STRING(translation), "%T", "Bonus_Type_Box", LANG_SERVER);
	Format(STRING(strIndex), "%i|Bonus_Type_Box", target);
	if(rp_GetClientBool(target, b_HasBonusBox))
		menu.AddItem(strIndex, translation, ITEMDRAW_DISABLED);	
	else
		menu.AddItem(strIndex, translation);	
	
	Format(STRING(translation), "%T", "Bonus_Type_Tomb", LANG_SERVER);
	Format(STRING(strIndex), "%i|Bonus_Type_Tomb", target);
	if(rp_GetClientBool(target, b_HasBonusTomb))
		menu.AddItem(strIndex, translation, ITEMDRAW_DISABLED);	
	else
		menu.AddItem(strIndex, translation);	
	
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}	

void SellVilla(int client, int target)
{
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_MenuVendre);
	menu.SetTitle("%T", "Villa_Type", LANG_SERVER);
	
	char sTmp[64], strIndex[32];
	for (int i = 1; i < g_aAvailableVilla.Length; i++) 
	{
		g_aAvailableVilla.GetString(i, STRING(sTmp));
		if(!StrEqual(sTmp, ""))
		{
			int owner = rp_GetAppartementInt(i, appart_owner);
			Format(STRING(sTmp), "Villa Nº%i", i);
			
			if(owner == -1)
			{
				Format(STRING(strIndex), "%i|villa_%i", target, i);
				menu.AddItem(strIndex, sTmp);
			}
			else
				menu.AddItem("", sTmp, ITEMDRAW_DISABLED);
		}
	}
	
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

void SellHotel(int client, int target)
{
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_MenuVendre);
	menu.SetTitle("%T", "Hotel_Type", LANG_SERVER);
	
	char sTmp[64], strIndex[32];
	for (int i = 1; i < g_aAvailableHotel.Length; i++) 
	{
		g_aAvailableHotel.GetString(i, STRING(sTmp));
		if(!StrEqual(sTmp, ""))
		{
			int owner = rp_GetHotelInt(i, hotel_owner);
			Format(STRING(sTmp), "Chambre Nº%i", i);
			
			if(owner == -1)
			{
				Format(STRING(strIndex), "%i|hotel_%i", target, i);
				menu.AddItem(strIndex, sTmp);
			}
			else
				menu.AddItem("", sTmp, ITEMDRAW_DISABLED);
		}
	}
	
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

void SellAppartments(int client, int target)
{
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_MenuVendre);
	menu.SetTitle("%T", "Appartment_Type", LANG_SERVER);
	
	char sTmp[64], strIndex[32];
	for (int i = 1; i < g_aAvailableAppart.Length; i++) 
	{
		g_aAvailableAppart.GetString(i, STRING(sTmp));
		if(!StrEqual(sTmp, ""))
		{
			int owner = rp_GetAppartementInt(i, appart_owner);
			Format(STRING(sTmp), "Appartement Nº%i", i);
			
			if(owner == -1)
			{
				Format(STRING(strIndex), "%i|appart_%i", target, i);
				menu.AddItem(strIndex, sTmp);
			}
			else
				menu.AddItem("", sTmp, ITEMDRAW_DISABLED);
		}
	}
	
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}	

public int Handle_MenuVendre(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[64], buffer[2][128], subBuffer[3][64], translation[128], strIndex[64];
		menu.GetItem(param, STRING(info));
		ExplodeString(info, "|", buffer, 2, 128);
		ExplodeString(buffer[1], "_", subBuffer, 3, 64);		
		
		int target = StringToInt(buffer[0]);	
		int id, price;
		
		char clientname[64];
		GetClientName(client, STRING(clientname));
		
		rp_SetClientBool(target, b_DisplayHud, false);
		Menu menu1 = new Menu(Handle_MenuSellConfirm);
		
		if(StrEqual(subBuffer[0], "appart", false))
		{
			id = StringToInt(subBuffer[1]);
			price = rp_GetAppartementInt(id, appart_price);
			menu1.SetTitle("%T", "Appart_Sell_Title", LANG_SERVER, clientname, id, price);
		}
		else if(StrEqual(subBuffer[0], "villa", false))
		{
			id = StringToInt(subBuffer[1]);
			price = rp_GetVillaInt(id, villa_price);
			menu1.SetTitle("%T", "Villa_Sell_Title", LANG_SERVER, clientname, id, price);
		}		
		else
		{
			price = price_bonus;
			Format(STRING(translation), "%T", buffer[1], LANG_SERVER);
			menu1.SetTitle("%T", "Bonus_Sell_Title", LANG_SERVER, clientname, translation, price_bonus);		
		}	
		
		Format(STRING(translation), "%T", "Sell_PayBy_Cash", LANG_SERVER);
		Format(STRING(strIndex), "%i|%s|%i|0", client, buffer[1], price);					
		menu1.AddItem(strIndex, translation);
		
		if(rp_GetClientBool(target, b_HasBankCard))
		{
			Format(STRING(translation), "%T", "Sell_PayBy_BankCard", LANG_SERVER);
			Format(STRING(strIndex), "%i|%s|%i|1", client, buffer[1], price);			
			menu1.AddItem(strIndex, translation);
		}	
	
		Format(STRING(translation), "%T", "Sell_Cancel", LANG_SERVER);
		menu1.AddItem("no", translation);
		
		menu1.ExitButton = true;
		menu1.Display(target, MENU_TIME_FOREVER);
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

public int Handle_MenuSellConfirm(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[64], buffer[5][256];
		menu.GetItem(param, STRING(info));
		ExplodeString(info, "|", buffer, 5, 256);
		
		int seller = StringToInt(buffer[0]);
		int price = StringToInt(buffer[2]);
		bool bankCard = view_as<bool>(StringToInt(buffer[3]));
		
		Request_Sell(client, seller, buffer[1], price, bankCard);
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

void Request_Sell(int buyer, int seller, char[] type, int price, bool payCB)
{
	char buffer[3][128];
	ExplodeString(type, "_", buffer, 3, 128);	
	if (payCB && rp_GetClientInt(buyer, i_Bank) >= price || !payCB && rp_GetClientInt(buyer, i_Money) >= price)
	{
		if (payCB)
			rp_SetClientInt(buyer, i_Bank, rp_GetClientInt(buyer, i_Bank) - price);
		else
			rp_SetClientInt(buyer, i_Money, rp_GetClientInt(buyer, i_Money) - price);
		EmitCashSound(buyer, -price);
		
		rp_SetClientInt(seller, i_Money, rp_GetClientInt(seller, i_Money) + price / 2);
		EmitCashSound(seller, price / 2);
		
		rp_SetJobCapital(8, rp_GetJobCapital(8) + price / 2);			
		
		char name[64];
		GetClientName(buyer, STRING(name));
		
		if(StrEqual(buffer[0], "appart"))
		{
			int appid = StringToInt(buffer[1]);
			rp_PrintToChat(buyer, "%T", "Appart_SellFinal_Buyer", LANG_SERVER, appid);
			rp_PrintToChat(seller, "%T", "Appart_SellFinal_Seller", LANG_SERVER, appid, name);
	
			rp_SetClientInt(buyer, i_Appart, appid);
			rp_SetClientInt(buyer, i_AppartCount, rp_GetClientInt(buyer, i_AppartCount) + 1);
			rp_SetClientKeyAppartement(buyer, appid, true);
			rp_SetAppartementInt(appid, appart_owner, buyer);
		}	
		else if(StrEqual(buffer[0], "villa"))
		{
			int villaID = StringToInt(buffer[1]);
			
			rp_PrintToChat(buyer, "%T", "Villa_SellFinal_Buyer", LANG_SERVER, villaID);
			rp_PrintToChat(seller, "%T", "Villa_SellFinal_Seller", LANG_SERVER, villaID, name);
	
			rp_SetClientInt(buyer, i_Villa, villaID);
			rp_SetClientKeyVilla(buyer, villaID, true);
			rp_SetVillaInt(villaID, villa_owner, buyer);
			
			SQL_Request(g_DB, "UPDATE `rp_villa` SET `ownerid` = '%i', `time` = '%s' WHERE `id` = '%i';", rp_GetSQLID(buyer), TIME_WEEK, villaID);
		}
		else if(StrEqual(buffer[0], "hotel"))
		{
			int hotelID = StringToInt(buffer[1]);
			
			rp_PrintToChat(buyer, "%T", "Hotel_SellFinal_Buyer", LANG_SERVER, hotelID);
			rp_PrintToChat(seller, "%T", "Hotel_SellFinal_Seller", LANG_SERVER, hotelID, name);
	
			rp_SetClientInt(buyer, i_Hotel, hotelID);
			rp_SetClientKeyHotel(buyer, hotelID, true);
			rp_SetHotelInt(hotelID, hotel_owner, buyer);
		}
		else
		{
			char product[64];
			Format(STRING(product), "%T", type, LANG_SERVER);
			
			if(StrEqual(type, "Bonus_Type_Health"))	
				rp_SetClientBool(buyer, b_HasBonusHealth, true);
			else if(StrEqual(type, "Bonus_Type_Kevlar"))				
				rp_SetClientBool(buyer, b_HasBonusKevlar, true);	
			else if(StrEqual(type, "Bonus_Type_Pay"))	
				rp_SetClientBool(buyer, b_HasBonusPay, true);
			else if(StrEqual(type, "Bonus_Type_Box"))	
				rp_SetClientBool(buyer, b_HasBonusBox, true);	
			else if(StrEqual(type, "Bonus_Type_Tomb"))	
				rp_SetClientBool(buyer, b_HasBonusTomb, true);
			
			
			rp_PrintToChat(buyer, "%T", "Bonus_SellFinal_Buyer", LANG_SERVER, product);
			rp_PrintToChat(seller, "%T", "Bonus_SellFinal_Seller", LANG_SERVER, product, name);
		}	
		
		rp_SetClientBool(buyer, b_DisplayHud, true);
		rp_SetClientBool(seller, b_DisplayHud, true);
	}
	else if (rp_GetClientInt(buyer, i_Money) <= price)
	{
		char strName[64];
		GetClientName(buyer, STRING(strName));
		
		rp_PrintToChat(seller, "%T", "Target_NotEnoughtMoney", LANG_SERVER, strName);
		rp_PrintToChat(buyer, "%T", "Client_NotEnoughtCash", LANG_SERVER);
	}
	else if (rp_GetClientInt(buyer, i_Bank) <= price)
	{
		char strName[64];
		GetClientName(buyer, STRING(strName));
		
		rp_PrintToChat(seller, "%T", "Target_NotEnoughtBank", LANG_SERVER, strName);
		rp_PrintToChat(buyer, "%T", "Client_NotEnoughtBank", LANG_SERVER);
	}
}

public void RP_ClientTimerEverySecond(int client)
{
	int appid = rp_GetClientInt(client, i_Appart);
	if(appid != -1)
	{
		if(IsClientInAppart(client))
		{
			if(rp_GetClientBool(client, b_HasBonusBox))
			{
				if(!box_appart[appid])
				{
					box_appart[appid] = true;
					SpawnBox(client, 1);
				}	
			}	
			
			if(rp_GetClientBool(client, b_HasBonusHealth))
			{
				int hp = GetClientHealth(client);
				if(hp != rp_GetClientInt(client, i_MaxHealth))
					rp_SetClientHealth(client, hp + 1);
			}	
			
			if(rp_GetClientBool(client, b_HasBonusKevlar))
			{
				int armor = GetClientArmor(client);
				if(armor != 100)
					SetEntProp(client, Prop_Data, "m_ArmorValue", armor + 1, 4);	
			}	
		}	
		else
		{
			if(box_appart[appid])
			{
				box_appart[appid] = false;
				RemoveBox(client, 1);
			}	
		}		
	}	
	
	int villaid = rp_GetClientInt(client, i_Villa);
	if(villaid != -1)
	{
		if(IsClientInVilla(client))
		{
			if(rp_GetClientBool(client, b_HasBonusBox))
			{
				if(!box_villa[villaid])
				{
					box_villa[villaid] = true;
					SpawnBox(client, 2);
				}	
			}	
			
			if(rp_GetClientBool(client, b_HasBonusHealth))
			{
				int hp = GetClientHealth(client);
				if(hp != rp_GetClientInt(client, i_MaxHealth))
					rp_SetClientHealth(client, hp + 1);
			}	
			
			if(rp_GetClientBool(client, b_HasBonusKevlar))
			{
				int armor = GetClientArmor(client);
				if(armor != 100)
					SetEntProp(client, Prop_Data, "m_ArmorValue", armor + 1, 4);	
			}	
		}	
		else
		{
			if(box_villa[villaid])
			{
				box_villa[villaid] = false;
				RemoveBox(client, 2);
			}	
		}		
	}
	
	int hotelid = rp_GetClientInt(client, i_Hotel);
	if(hotelid != -1)
	{
		if(IsClientInHotel(client))
		{
			if(rp_GetClientBool(client, b_HasBonusBox))
			{
				if(!box_hotel[hotelid])
				{
					box_hotel[hotelid] = true;
					SpawnBox(client, 3);
				}	
			}	
			
			if(rp_GetClientBool(client, b_HasBonusHealth))
			{
				int hp = GetClientHealth(client);
				if(hp != rp_GetClientInt(client, i_MaxHealth))
					rp_SetClientHealth(client, hp + 1);
			}	
			
			if(rp_GetClientBool(client, b_HasBonusKevlar))
			{
				int armor = GetClientArmor(client);
				if(armor != 100)
					SetEntProp(client, Prop_Data, "m_ArmorValue", armor + 1, 4);	
			}	
		}	
		else
		{
			if(box_hotel[villaid])
			{
				box_hotel[villaid] = false;
				RemoveBox(client, 3);
			}	
		}		
	}
		
	int aim = GetClientAimTarget(client, false);
	
	char entName[64], HudMSG[256];
	
	if(IsValidEntity(aim))
	{
		Entity_GetName(aim, STRING(entName));	
		if(StrContains(entName, "door_appart_") != -1 && Distance(client, aim) < 80)
		{
			char strAppart[3][64];		
			ExplodeString(entName, "_", strAppart, 3, 64);
			
			int owner = rp_GetAppartementInt(StringToInt(strAppart[2]), appart_owner);
			int price = rp_GetAppartementInt(StringToInt(strAppart[2]), appart_price);
			
			if(!IsClientValid(owner))
				Format(STRING(HudMSG), "Appartement: Nº <font color='%s'>%i</font> à louer\nPrix: <font color='%s'>%i$</font>", HTML_TURQUOISE, StringToInt(strAppart[2]), HTML_CHARTREUSE, price);	
			else
				Format(STRING(HudMSG), "Appartement: Nº <font color='%s'>%i</font>\nPropriétaire: <font color='%s'>%N</font>", HTML_TURQUOISE, StringToInt(strAppart[2]), HTML_PINK, owner);	
			
			if(owner == client || rp_GetClientKeyAppartement(client, StringToInt(strAppart[2])))
				Format(STRING(HudMSG), "%s\n<font color='%s'>Vous avez les clées</font>", HudMSG, HTML_CHARTREUSE);
			else
				Format(STRING(HudMSG), "%s\n<font color='%s'>Vous n'avez pas les clées</font>", HudMSG, HTML_CRIMSON);	

			PrintHintText(client, HudMSG);	
		}	
		else if(StrContains(entName, "door_villa_") != -1 && Distance(client, aim) < 80)
		{
			char strVilla[3][64];		
			ExplodeString(entName, "_", strVilla, 3, 64);
			
			int owner = rp_GetVillaInt(StringToInt(strVilla[2]), villa_owner);
			int price = rp_GetVillaInt(StringToInt(strVilla[2]), villa_price);
			
			if(!IsClientValid(owner))
				Format(STRING(HudMSG), "Villa: Nº <font color='%s'>%i</font> à louer\nPrix: <font color='%s'>%i$</font>", HTML_TURQUOISE, StringToInt(strVilla[2]), HTML_CHARTREUSE, price);	
			else
				Format(STRING(HudMSG), "Villa: Nº <font color='%s'>%i</font>\nPropriétaire: <font color='%s'>%N</font>", HTML_TURQUOISE, StringToInt(strVilla[2]), HTML_PINK, owner);	
			
			if(owner == client || rp_GetClientKeyVilla(client, StringToInt(strVilla[2])))
				Format(STRING(HudMSG), "%s\n<font color='%s'>Vous avez les clées</font>", HudMSG, HTML_CHARTREUSE);
			else
				Format(STRING(HudMSG), "%s\n<font color='%s'>Vous n'avez pas les clées</font>", HudMSG, HTML_CRIMSON);

			PrintHintText(client, HudMSG);	
		}
		else if(StrContains(entName, "door_hotel_") != -1 && Distance(client, aim) < 80)
		{
			char strHotel[3][64];		
			ExplodeString(entName, "_", strHotel, 3, 64);
			
			int owner = rp_GetHotelInt(StringToInt(strHotel[2]), hotel_owner);
			int price = rp_GetHotelInt(StringToInt(strHotel[2]), hotel_price);
			
			if(!IsClientValid(owner))
				Format(STRING(HudMSG), "Chambre: Nº <font color='%s'>%i</font> à louer\nPrix: <font color='%s'>%i$</font>", HTML_TURQUOISE, StringToInt(strHotel[2]), HTML_CHARTREUSE, price);	
			else
				Format(STRING(HudMSG), "Chambre: Nº <font color='%s'>%i</font>\nPropriétaire: <font color='%s'>%N</font>", HTML_TURQUOISE, StringToInt(strHotel[2]), HTML_PINK, owner);	
			
			if(owner == client || rp_GetClientKeyHotel(client, StringToInt(strHotel[2])))
				Format(STRING(HudMSG), "%s\n<font color='%s'>Vous avez les clées</font>", HudMSG, HTML_CHARTREUSE);
			else
				Format(STRING(HudMSG), "%s\n<font color='%s'>Vous n'avez pas les clées</font>", HudMSG, HTML_CRIMSON);

			PrintHintText(client, HudMSG);	
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

	if(IsBoxOwner(client, target))
		MenuBox(client);
}	

void SpawnBox(int client, int type)
{
	KeyValues kv = new KeyValues("SpawnBox");

	char sPath[PLATFORM_MAX_PATH], map[64], kID[16];
	rp_GetCurrentMap(STRING(map));
	
	if(type == 1)
	{
		IntToString(rp_GetClientInt(client, i_Appart), STRING(kID));
		BuildPath(Path_SM, STRING(sPath), "data/roleplay/%s/spawnboxappart.cfg", map);
	}
	else if(type == 2)
	{
		IntToString(rp_GetClientInt(client, i_Villa), STRING(kID));
		BuildPath(Path_SM, STRING(sPath), "data/roleplay/%s/spawnboxvilla.cfg", map);
	}
	else if(type == 3)
	{
		IntToString(rp_GetClientInt(client, i_Villa), STRING(kID));
		BuildPath(Path_SM, STRING(sPath), "data/roleplay/%s/spawnboxhotel.cfg", map);
	}
	
	Kv_CheckIfFileExist(kv, sPath);
	
	if(kv.JumpToKey(kID))
	{	
		float position[3], angle[3];
		kv.GetVector("position", position);
		kv.GetVector("angle", angle);
		
		char sModel[256];
		rp_GetGlobalData("model_box", STRING(sModel));
		
		PrecacheModel(sModel);
		int box_ent = CreateEntityByName("prop_dynamic_override");
		DispatchKeyValue(box_ent, "solid", "6");
		DispatchKeyValue(box_ent, "model", sModel);
		DispatchSpawn(box_ent);
		TeleportEntity(box_ent, position, angle, NULL_VECTOR);
		BoxData[client].type = type;
		
		switch(type)
		{
			case 1:iBoxAppart[rp_GetClientInt(client, i_Appart)] = box_ent;
			case 2:iBoxVilla[rp_GetClientInt(client, i_Villa)] = box_ent;
			case 3:iBoxHotel[rp_GetClientInt(client, i_Hotel)] = box_ent;
		}
	}	
	
	kv.Rewind();
	delete kv;
}

void RemoveBox(int client, int type)
{
	switch(type)
	{
		case 1:
		{
			int id = rp_GetClientInt(client, i_Appart);
			if(IsValidEntity(iBoxAppart[id]))
				UTIL_RemoveEntity(iBoxAppart[id], 0.0);
		}
		case 2:
		{
			int id = rp_GetClientInt(client, i_Appart);
			if(IsValidEntity(iBoxVilla[id]))
				UTIL_RemoveEntity(iBoxVilla[id], 0.0);
		}
		case 3:
		{
			int id = rp_GetClientInt(client, i_Hotel);
			if(IsValidEntity(iBoxHotel[id]))
				UTIL_RemoveEntity(iBoxHotel[id], 0.0);
		}
	}
}

bool IsBoxOwner(int client, int target)
{
	if(rp_IsValidBox(target))
	{
		char entname[64], buffer[2][64];
		Entity_GetName(target, STRING(entname));
		ExplodeString(entname, "_", buffer, 2, 64);
		int ID = StringToInt(buffer[1]);
			
		if(BoxData[client].type == 1 && rp_GetClientInt(client, i_Appart) == ID)
			return true;
		else if(BoxData[client].type == 2 && rp_GetClientInt(client, i_Villa) == ID)
			return true;
		else if(BoxData[client].type == 3 && rp_GetClientInt(client, i_Hotel) == ID)
			return true;
	}	
	
	return false;
}	

void MenuBox(int client)
{
	char translation[64];
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_MenuBox);
	menu.SetTitle("%T", "MenuBox_Title", LANG_SERVER);
	
	Format(STRING(translation), "%T", "MenuBox_Store", LANG_SERVER);
	if(BoxData[client].total != 3)
		menu.AddItem("store", translation);
	else
		menu.AddItem("", translation, ITEMDRAW_DISABLED);	
	
	Format(STRING(translation), "%T", "MenuBox_Recover", LANG_SERVER);
	menu.AddItem("recover", translation);
	
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}	

public int Handle_MenuBox(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[64];
		menu.GetItem(param, STRING(info));
		
		if(StrEqual(info, "store"))
		{
			char entClass[32];
			int weapon = Client_GetActiveWeapon(client);
			Entity_GetClassName(weapon, STRING(entClass));
			
			int numero = -1;
			if(StrEqual(entClass, "weapon_hkp2000"))
				numero = 0;
			else if(StrEqual(entClass, "weapon_usp_silencer"))
				numero = 1;
			else if(StrEqual(entClass, "weapon_tec9"))
				numero = 2;
			else if(StrEqual(entClass, "weapon_glock"))
				numero = 3;
			else if(StrEqual(entClass, "weapon_p250"))
				numero = 4;
			else if(StrEqual(entClass, "weapon_deagle"))
				numero = 5;
			else if(StrEqual(entClass, "weapon_fiveseven"))
				numero = 6;
			else if(StrEqual(entClass, "weapon_elite"))
				numero = 7;
			else if(StrEqual(entClass, "weapon_cz75a"))
				numero = 8;
			else if(StrEqual(entClass, "weapon_mac10"))
				numero = 9;
			else if(StrEqual(entClass, "weapon_mp9"))
				numero = 10;
			else if(StrEqual(entClass, "weapon_bizon"))
				numero = 11;
			else if(StrEqual(entClass, "weapon_ump45"))
				numero = 12;
			else if(StrEqual(entClass, "weapon_mp7"))
				numero = 13;
			else if(StrEqual(entClass, "weapon_p90"))
				numero = 14;
			else if(StrEqual(entClass, "weapon_sawedoff"))
				numero = 15;
			else if(StrEqual(entClass, "weapon_nova"))
				numero = 16;
			else if(StrEqual(entClass, "weapon_mag7"))
				numero = 17;
			else if(StrEqual(entClass, "weapon_xm1014"))
				numero = 18;
			else if(StrEqual(entClass, "weapon_galilar"))
				numero = 19;
			else if(StrEqual(entClass, "weapon_famas"))
				numero = 20;
			else if(StrEqual(entClass, "weapon_ak47"))
				numero = 21;
			else if(StrEqual(entClass, "weapon_m4a1_silencer"))
				numero = 22;
			else if(StrEqual(entClass, "weapon_m4a1"))
				numero = 23;
			else if(StrEqual(entClass, "weapon_aug"))
				numero = 24;
			else if(StrEqual(entClass, "weapon_sg556"))
				numero = 25;
			else if(StrEqual(entClass, "weapon_m249"))
				numero = 26;
			else if(StrEqual(entClass, "weapon_negev"))
				numero = 27;
			else if(StrEqual(entClass, "weapon_ssg08"))
				numero = 28;
			else if(StrEqual(entClass, "weapon_awp"))
				numero = 29;
			else if(StrEqual(entClass, "weapon_scar20"))
				numero = 30;
			else if(StrEqual(entClass, "weapon_g3sg1"))
				numero = 31;
			else if(StrEqual(entClass, "weapon_mp5sd"))
				numero = 32;	
			else
				numero = -1;
				
			BoxData[client].wepIndex[numero]++;	
			BoxData[client].ammoPrimary[numero] = GetEntProp(weapon, Prop_Send, "m_iClip1");	
			BoxData[client].ammoReserve[numero] = GetEntProp(weapon, Prop_Send, "m_iPrimaryReserveAmmoCount");	
			BoxData[client].total++;
			RemovePlayerItem(client, weapon);
		}
		else if(StrEqual(info, "recover"))
		{
			char strFormat[32];
			rp_SetClientBool(client, b_DisplayHud, false);
			Menu menu1 = new Menu(Handle_MenuBoxRecover);
			menu1.SetTitle("%T", "MenuBox_Recover", LANG_SERVER);
					
			if(BoxData[client].total == 0)
				menu1.AddItem("", "Le coffre est vide !", ITEMDRAW_DISABLED);
			else
			{
				if(BoxData[client].wepIndex[0] > 0)
				{
					Format(STRING(strFormat), "P2000: %i", BoxData[client].wepIndex[0]);
					menu1.AddItem("0|weapon_hkp2000", strFormat);		
				}
				if(BoxData[client].wepIndex[1] > 0)
				{
					Format(STRING(strFormat), "USP: %i", BoxData[client].wepIndex[1]);
					menu1.AddItem("1|weapon_usp_silencer", strFormat);		
				}
				if(BoxData[client].wepIndex[2] > 0)
				{
					Format(STRING(strFormat), "TEC-9: %i", BoxData[client].wepIndex[2]);
					menu1.AddItem("2|weapon_tec9", strFormat);		
				}
				if(BoxData[client].wepIndex[3] > 0)
				{
					Format(STRING(strFormat), "Glock-18: %i", BoxData[client].wepIndex[3]);
					menu1.AddItem("3|weapon_glock", strFormat);		
				}
				if(BoxData[client].wepIndex[4] > 0)
				{
					Format(STRING(strFormat), "P250: %i", BoxData[client].wepIndex[4]);
					menu1.AddItem("4|weapon_p250", strFormat);		
				}	
				if(BoxData[client].wepIndex[5] > 0)
				{
					Format(STRING(strFormat), "Deagle: %i", BoxData[client].wepIndex[5]);
					menu1.AddItem("5|weapon_deagle", strFormat);		
				}
				if(BoxData[client].wepIndex[6] > 0)
				{
					Format(STRING(strFormat), "Five-seven: %i", BoxData[client].wepIndex[6]);
					menu1.AddItem("6|weapon_fiveseven", strFormat);		
				}
				if(BoxData[client].wepIndex[7] > 0)
				{
					Format(STRING(strFormat), "Dual Elites: %i", BoxData[client].wepIndex[7]);
					menu1.AddItem("7|weapon_elite", strFormat);		
				}
				if(BoxData[client].wepIndex[8] > 0)
				{
					Format(STRING(strFormat), "CZ-75: %i", BoxData[client].wepIndex[8]);
					menu1.AddItem("8|weapon_cz75a", strFormat);		
				}
				if(BoxData[client].wepIndex[9] > 0)
				{
					Format(STRING(strFormat), "MAC10: %i", BoxData[client].wepIndex[9]);
					menu1.AddItem("9|weapon_mac10", strFormat);		
				}	
				if(BoxData[client].wepIndex[10] > 0)
				{
					Format(STRING(strFormat), "MP9: %i", BoxData[client].wepIndex[10]);
					menu1.AddItem("10|weapon_mp9", strFormat);		
				}
				if(BoxData[client].wepIndex[11] > 0)
				{
					Format(STRING(strFormat), "PP-BIZON: %i", BoxData[client].wepIndex[11]);
					menu1.AddItem("11|weapon_ppbizon", strFormat);		
				}
				if(BoxData[client].wepIndex[12] > 0)
				{
					Format(STRING(strFormat), "UMP45: %i", BoxData[client].wepIndex[12]);
					menu1.AddItem("12|weapon_ump45", strFormat);		
				}
				if(BoxData[client].wepIndex[13] > 0)
				{
					Format(STRING(strFormat), "MP7: %i", BoxData[client].wepIndex[13]);
					menu1.AddItem("13|weapon_mp7", strFormat);		
				}
				if(BoxData[client].wepIndex[14] > 0)
				{
					Format(STRING(strFormat), "P90: %i", BoxData[client].wepIndex[14]);
					menu1.AddItem("14|weapon_p90", strFormat);		
				}		
				if(BoxData[client].wepIndex[15] > 0)
				{
					Format(STRING(strFormat), "Sawedoff: %i", BoxData[client].wepIndex[15]);
					menu1.AddItem("15|weapon_sawedoff", strFormat);		
				}	
				if(BoxData[client].wepIndex[16] > 0)
				{
					Format(STRING(strFormat), "Nova: %i", BoxData[client].wepIndex[16]);
					menu1.AddItem("16|weapon_nova", strFormat);		
				}
				if(BoxData[client].wepIndex[17] > 0)
				{
					Format(STRING(strFormat), "Mag-7: %i", BoxData[client].wepIndex[17]);
					menu1.AddItem("17|weapon_mag7", strFormat);		
				}
				if(BoxData[client].wepIndex[18] > 0)
				{
					Format(STRING(strFormat), "XM1014: %i", BoxData[client].wepIndex[18]);
					menu1.AddItem("18|weapon_xm1014", strFormat);		
				}
				if(BoxData[client].wepIndex[19] > 0)
				{
					Format(STRING(strFormat), "Galilar: %i", BoxData[client].wepIndex[19]);
					menu1.AddItem("19|weapon_galilar", strFormat);		
				}
				if(BoxData[client].wepIndex[20] > 0)
				{
					Format(STRING(strFormat), "Famas: %i", BoxData[client].wepIndex[20]);
					menu1.AddItem("20|weapon_famas", strFormat);		
				}	
				if(BoxData[client].wepIndex[21] > 0)
				{
					Format(STRING(strFormat), "AK47: %i", BoxData[client].wepIndex[21]);
					menu1.AddItem("21|weapon_ak47", strFormat);		
				}	
				if(BoxData[client].wepIndex[22] > 0)
				{
					Format(STRING(strFormat), "M4a1-s: %i", BoxData[client].wepIndex[22]);
					menu1.AddItem("22|weapon_m4a1_silencer", strFormat);		
				}
				if(BoxData[client].wepIndex[23] > 0)
				{
					Format(STRING(strFormat), "M4a4: %i", BoxData[client].wepIndex[23]);
					menu1.AddItem("23|weapon_m4a1", strFormat);		
				}
				if(BoxData[client].wepIndex[24] > 0)
				{
					Format(STRING(strFormat), "Aug: %i", BoxData[client].wepIndex[24]);
					menu1.AddItem("24|weapon_aug", strFormat);		
				}
				if(BoxData[client].wepIndex[25] > 0)
				{
					Format(STRING(strFormat), "SG556: %i", BoxData[client].wepIndex[25]);
					menu1.AddItem("25|weapon_sg556", strFormat);		
				}
				if(BoxData[client].wepIndex[26] > 0)
				{
					Format(STRING(strFormat), "M249: %i", BoxData[client].wepIndex[26]);
					menu1.AddItem("26|weapon_m249", strFormat);		
				}
				if(BoxData[client].wepIndex[27] > 0)
				{
					Format(STRING(strFormat), "Negev: %i", BoxData[client].wepIndex[27]);
					menu1.AddItem("27|weapon_negev", strFormat);		
				}
				if(BoxData[client].wepIndex[28] > 0)
				{
					Format(STRING(strFormat), "SSG08: %i", BoxData[client].wepIndex[28]);
					menu1.AddItem("28|weapon_ssg08", strFormat);		
				}
				if(BoxData[client].wepIndex[29] > 0)
				{
					Format(STRING(strFormat), "AWP: %i", BoxData[client].wepIndex[29]);
					menu1.AddItem("29|weapon_awp", strFormat);		
				}
				if(BoxData[client].wepIndex[30] > 0)
				{
					Format(STRING(strFormat), "SCAR-20: %i", BoxData[client].wepIndex[30]);
					menu1.AddItem("30|weapon_scar20", strFormat);		
				}
				if(BoxData[client].wepIndex[31] > 0)
				{
					Format(STRING(strFormat), "G3SG1: %i", BoxData[client].wepIndex[31]);
					menu1.AddItem("31|weapon_g3sg1", strFormat);		
				}
				if(BoxData[client].wepIndex[32] > 0)
				{
					Format(STRING(strFormat), "MP5-SD: %i", BoxData[client].wepIndex[32]);
					menu1.AddItem("32|weapon_mp5sd", strFormat);		
				}
			}	
			
			menu1.ExitButton = true;
			menu1.Display(client, MENU_TIME_FOREVER);
		}
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

public int Handle_MenuBoxRecover(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[64], buffer[2][64];
		menu.GetItem(param, STRING(info));
		ExplodeString(info, "|", buffer, 2, 64);
		
		int id = StringToInt(buffer[0]);		
		BoxData[client].wepIndex[id]--;	
		BoxData[client].total--;	
		int weapon = GivePlayerItem(client, buffer[1]);
		EquipPlayerWeapon(client, weapon);
		rp_SetClientAmmo(weapon, BoxData[client].ammoPrimary[id], BoxData[client].ammoReserve[id], false);
		BoxData[client].ammoPrimary[id] = 0;
		BoxData[client].ammoReserve[id] = 0;
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