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

enum struct Data_Forward {
	GlobalForward OnSQLInit;
}	
Data_Forward Forward;

Database g_DB;
int SQL_PlayerID[MAXPLAYERS + 1];

/***************************************************************************************

							P L U G I N  -  I N F O

***************************************************************************************/
public Plugin myinfo = 
{
	name = "Roleplay - SQL Management", 
	author = "MBK", 
	description = "Foreign keys, database connexion, its here", 
	version = "1.0", 
	url = "https://github.com/Mbk10201"
};

/***************************************************************************************

									 F U N C T I O N S

***************************************************************************************/
public void OnPluginStart()
{
	// Load global translation file
	LoadTranslation();
	// Connect to the database configuration 
	if(g_DB == null)
		Database.Connect(GotDatabase, "roleplay");
	// Print to server console the plugin status
	PrintToServer("[REQUIREMENT] SQL MANAGER ✓");	
	
	/*----------------------------------Commands-------------------------------*/
	// Register all local plugin commands available in game
	RegConsoleCmd("rp_sql", Command_SQL);
	/*-------------------------------------------------------------------------------*/
}

public void OnMapStart()
{
	if(g_DB == null)
		Database.Connect(GotDatabase, "roleplay");
}

public APLRes AskPluginLoad2(Handle plugin, bool late, char[] error, int err_max)
{
	RegPluginLibrary("rp_sqlmanagement");
	
	Database.Connect(GotDatabase, "roleplay");
	
	/*------------------------------------FORWADS------------------------------------*/
	Forward.OnSQLInit = new GlobalForward("RP_OnSQLInit", ET_Event, Param_Cell, Param_Cell);
	/*-------------------------------------------------------------------------------*/
	
	CreateNative("rp_GetSQLID", Native_GetSQLID);
	
	return APLRes_Success;
}

public int Native_GetSQLID(Handle plugin, int numParams) 
{
	int client = GetNativeCell(1);

	if(!IsClientValid(client))
		return -1;

	return SQL_PlayerID[client];
}

public void OnMapEnd()
{
	LoopClients(i)
	{
		if(!IsClientValid(i))
			continue;
		
		SaveClient(i);
	}
}

/***************************************************************************************

										S Q L

***************************************************************************************/

public void GotDatabase(Database db, const char[] error, any data)
{
	if (db == null)
	{
		LogError("%T", "SQL_DatabaseErrorLogin", LANG_SERVER, error);
	} 
	else 
	{
		db.SetCharset("utf8");
		g_DB = db;
		Transaction SQLInit = new Transaction();
		
		SQLInit.AddQuery("CREATE TABLE IF NOT EXISTS `rp_players` ( \
			`id` int(20) NOT NULL AUTO_INCREMENT, \
			`steamid_32` varchar(32) NOT NULL, \
			`steamid_64` varchar(64) NOT NULL, \
			`playername` varchar(64) NOT NULL, \
			`country` varchar(32) NOT NULL, \
			`ip` varchar(32) NOT NULL, \
			`tutorial` int(1) NOT NULL, \
			`nationality` int(1) NOT NULL, \
			`sexe` int(1) NOT NULL, \
			`hungry` float NOT NULL, \
			`drink` float NOT NULL, \
			PRIMARY KEY (`id`), \
			UNIQUE KEY `steamid_32` (`steamid_32`) \
			)ENGINE = InnoDB DEFAULT CHARSET = utf8 COLLATE = utf8_bin;");

		SQLInit.AddQuery("CREATE TABLE IF NOT EXISTS `rp_kills` (\
			`id` int(20) NOT NULL AUTO_INCREMENT, \
			`playerid_killer` int(20) NOT NULL, \
			`playerid_victim` int(20) NOT NULL, \
			`arme` varchar(64) COLLATE utf8_bin NOT NULL, \
			`zone` varchar(64) COLLATE utf8_bin NOT NULL, \
			PRIMARY KEY (`id`), \
			FOREIGN KEY (`playerid_killer`) REFERENCES `rp_players` (`id`) ON DELETE CASCADE ON UPDATE CASCADE, \
			FOREIGN KEY (`playerid_victim`) REFERENCES `rp_players` (`id`) ON DELETE CASCADE ON UPDATE CASCADE \
			)ENGINE = InnoDB DEFAULT CHARSET = utf8 COLLATE = utf8_bin;");
		
		SQLInit.AddQuery("CREATE TABLE IF NOT EXISTS `rp_connections` (\
			`id` int(20) NOT NULL AUTO_INCREMENT, \
			`playerid` int(20) NOT NULL, \
			`status` enum('online', 'offline') NOT NULL, \
			`tmp_online` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP, \
			`tmp_offline` timestamp NOT NULL, \
			PRIMARY KEY (`id`), \
			FOREIGN KEY (`playerid`) REFERENCES `rp_players` (`id`) ON DELETE CASCADE ON UPDATE CASCADE \
			)ENGINE = InnoDB DEFAULT CHARSET = utf8 COLLATE = utf8_bin;");
		
		Call_StartForward(Forward.OnSQLInit);
		Call_PushCell(db);
		Call_PushCell(SQLInit);
		Call_Finish();
		
		db.Execute(SQLInit, SQL_OnSucces, SQL_OnFailed, 0, DBPrio_High);
	}
}

/***************************************************************************************

									C L I E N T - S I D E

***************************************************************************************/

public void OnClientAuthorized(int client, const char[] auth) 
{	
	char sSteamID_32[32];
	GetClientAuthId(client, AuthId_Steam2, STRING(sSteamID_32));
	
	char sSteamID_64[64];
	GetClientAuthId(client, AuthId_SteamID64, STRING(sSteamID_64));
	
	char playername[MAX_NAME_LENGTH + 8];
	GetClientName(client, STRING(playername));
	
	char sFinalName[MAX_NAME_LENGTH * 2 + 16];
	SQL_EscapeString(g_DB, playername, STRING(sFinalName));
	
	char sCountry[64];
	GetCountryPrefix(client, STRING(sCountry));
	
	char sIp[64];
	GetClientIP(client, STRING(sIp));
	
	Transaction SQLInit = new Transaction();
	
	char sQuery[MAX_BUFFER_LENGTH + 1];
	
	Format(STRING(sQuery), "INSERT IGNORE INTO `rp_players` ( \
	`id`, `steamid_32`, `steamid_64`, `playername`, `country`, `ip`, `tutorial`, `nationality`, `sexe`, `hungry`, `drink`) \
	VALUES (NULL, '%s', '%s', '%s', '%s', '%s', '0', '0', '0', '100.0', '100.0');", sSteamID_32, sSteamID_64, sFinalName, sCountry, sIp);
	#if DEBUG
		PrintToServer("[RP_SQL] %s", sQuery);
	#endif
	SQLInit.AddQuery(sQuery);

	g_DB.Execute(SQLInit, SQL_OnSucces, SQL_OnFailed);
	//SQL_PlayerID[client] = SQL_GetInsertId(g_DB);
	
	SQL_LoadClient(client);
}

public void SQL_LoadClient(int client) 
{
	char sSteamID_32[32];
	GetClientAuthId(client, AuthId_Steam2, STRING(sSteamID_32));
	
	char sSteamID_64[64];
	GetClientAuthId(client, AuthId_SteamID64, STRING(sSteamID_64));	
			
	char sQuery[MAX_BUFFER_LENGTH + 1];
	Format(STRING(sQuery), "SELECT * FROM `rp_players` WHERE `steamid_32` = '%s' OR `steamid_64` = '%s'", sSteamID_32, sSteamID_64);
	#if DEBUG
		PrintToServer(sQuery);
	#endif
	g_DB.Query(SQL_FetchResult, sQuery, GetClientUserId(client));
	
	SQL_LoadModules(client);
}

public void SQL_FetchResult(Database db, DBResultSet Results, const char[] error, any data) 
{	
	int client = GetClientOfUserId(data);
	while (Results.FetchRow()) 
	{
		float value;
		Results.FetchFloatByName("hungry", value);
		rp_SetClientFloat(client, fl_Soif, value);
		
		Results.FetchFloatByName("drink", value);
		rp_SetClientFloat(client, fl_Faim, value);
		
		Results.FetchIntByName("id", SQL_PlayerID[client]);
	}
}

public void SQL_LoadModules(int client)
{
	char sQuery[MAX_BUFFER_LENGTH + 1];
	Transaction SQLInit = new Transaction();
	
	Format(STRING(sQuery), "INSERT INTO `rp_connections` ( \
	`id`, `playerid`, `status`, `tmp_online`, `tmp_offline`) \
	VALUES (NULL, '%i', 'online', CURRENT_TIMESTAMP, tmp_offline);", SQL_PlayerID[client]);
	#if DEBUG
		PrintToServer("[RP_SQL] %s", sQuery);
	#endif
	SQLInit.AddQuery(sQuery);
	
	g_DB.Execute(SQLInit, SQL_OnSucces, SQL_OnFailed);
}

public void OnClientDisconnect(int client)
{
	SaveClient(client);
}

public void SaveClient(int client) 
{
	SQL_Request(g_DB, "UPDATE `rp_connections` SET `status` = 'offline', `tmp_offline` = CURRENT_TIMESTAMP, `tmp_online` = tmp_online WHERE `status` = 'online' AND playerid = '%i'", rp_GetSQLID(client));
	SQL_Request(g_DB, "UPDATE `rp_players` SET `hungry` = '%f', `drink` = '%f' WHERE playerid = '%i'", SQL_PlayerID[client], rp_GetClientFloat(client, fl_Faim), rp_GetClientFloat(client, fl_Soif));
}

/***************************************************************************************

									C A L L B A C K

***************************************************************************************/

public Action Command_SQL(int client, int args)
{
	if(client == 0)
	{
		PrintToServer("%T", "Command_NotAvailable", LANG_SERVER);
		return Plugin_Handled;
	}
	else if(rp_GetAdmin(client) == ADMIN_FLAG_NONE)
	{
		Translation_PrintNoAccess(client);
		return Plugin_Handled;
	}
	
	Menu_SQL(client);
	
	return Plugin_Handled;
}	

void Menu_SQL(int client)
{
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_MenuSQL);
	
	char translation[64];
	menu.SetTitle("%T", "Title", LANG_SERVER);
	
	Format(STRING(translation), "%T", "param_job", LANG_SERVER);
	menu.AddItem("jobmenu", translation, (rp_GetClientInt(client, i_Job) == 0) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Handle_MenuSQL(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[64];
		menu.GetItem(param, STRING(info));
		
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit || param == MenuCancel_ExitBack)
			if(rp_GetClientBool(client, b_IsNew))
				rp_OpenTutorial(client);
			else
				rp_SetClientBool(client, b_DisplayHud, true);
	}
	else if(action == MenuAction_End)
		delete menu;
		
	return 0;
}

void GetCountryPrefix(int client, char[] buffer, int maxlen)
{
	char ip[32];
	GetClientIP(client, STRING(ip));	
	GeoipCountry(ip, buffer, maxlen);
}	