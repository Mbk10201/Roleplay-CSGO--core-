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

#define MAX_ARCHIEVEMENTS 32

/***************************************************************************************

										H E A D E R

***************************************************************************************/
#include <roleplay_csgo.inc>

char steamID[MAXPLAYERS + 1][32];
bool archievement[MAXPLAYERS + 1][MAX_ARCHIEVEMENTS];
Database g_DB;

enum struct archiv_count {
	int headshots;
}

archiv_count archiv_data[MAXPLAYERS + 1];

/***************************************************************************************

							P L U G I N  -  I N F O

***************************************************************************************/
public Plugin myinfo = 
{
	name = "Roleplay - Archievements", 
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
	LoadTranslations("archievements.phrases.txt");
	Database.Connect(GotDatabase, "roleplay");
}

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
		
		char buffer[4096];
		Format(STRING(buffer), 
		"CREATE TABLE IF NOT EXISTS `rp_archievements` ( \
		  `id` int(11) NOT NULL AUTO_INCREMENT, \
		  `steamid` varchar(32) COLLATE utf8_bin NOT NULL, \
		  `playername` varchar(32) COLLATE utf8_bin NOT NULL, \
		  `0` int(1) NOT NULL, \
		  `1` int(1) NOT NULL, \
		  PRIMARY KEY (`id`), \
		  UNIQUE KEY `steamid` (`steamid`) \
		  )ENGINE = InnoDB DEFAULT CHARSET = utf8 COLLATE = utf8_bin;");	
		g_DB.Query(SQL_CheckForErrors, buffer);
		
		Format(STRING(buffer), 
		"CREATE TABLE IF NOT EXISTS `rp_archievements_stats` ( \
		  `id` int(11) NOT NULL AUTO_INCREMENT, \
		  `steamid` varchar(32) COLLATE utf8_bin NOT NULL, \
		  `playername` varchar(32) COLLATE utf8_bin NOT NULL, \
		  `headshots` int(100) NOT NULL, \
		  PRIMARY KEY (`id`), \
		  UNIQUE KEY `steamid` (`steamid`) \
		  )ENGINE = InnoDB DEFAULT CHARSET = utf8 COLLATE = utf8_bin;");	
		g_DB.Query(SQL_CheckForErrors, buffer);
	}
}

/***************************************************************************************

									N A T I V E S

***************************************************************************************/
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) 
{
	CreateNative("rp_SetSuccess", Native_SetSuccess);
	CreateNative("rp_GetSuccess", Native_GetSuccess);
}

public int Native_SetSuccess(Handle plugin, int numParams) 
{
	int client = GetNativeCell(1);
	int type = GetNativeCell(2);
	bool value = view_as<bool>(GetNativeCell(3));	
	
	if(value && !archievement[client][type])
		CheckArchievement(client, type);
	
	return archievement[client][type] = value;
	
}

public int Native_GetSuccess(Handle plugin, int numParams) 
{
	int client = GetNativeCell(1);
	int type = GetNativeCell(2);
	return archievement[client][type];
}


/***************************************************************************************

									C A L L B A C K

***************************************************************************************/
public void SQL_LoadClient(int client) 
{
	if(!IsClientValid(client))
		return;
			
	char buffer[512];
	Format(STRING(buffer), "SELECT * FROM `rp_archievements` WHERE `steamid` = '%s';", steamID[client]);
	g_DB.Query(SQL_Callback_1, buffer, GetClientUserId(client));
	
	Format(STRING(buffer), "SELECT * FROM `rp_archievements_stats` WHERE `steamid` = '%s';", steamID[client]);
	g_DB.Query(SQL_Callback_2, buffer, GetClientUserId(client));
}

public void SQL_Callback_1(Database db, DBResultSet Results, const char[] error, any data) 
{	
	int client = GetClientOfUserId(data);
	while (Results.FetchRow()) 
	{
		rp_SetSuccess(client, archi_headshotman, view_as<bool>(SQL_FetchIntByName(Results, "0")));
	}
}

public void SQL_Callback_2(Database db, DBResultSet Results, const char[] error, any data) 
{	
	int client = GetClientOfUserId(data);
	while (Results.FetchRow()) 
	{
		archiv_data[client].headshots = SQL_FetchIntByName(Results, "headshots");
	}
}

void CheckArchievement(int client, int type)
{
	if(!archievement[client][type])
	{
		char archi_name[32];
		GetArchievementName(type, STRING(archi_name));
		
		SQL_Request(g_DB, "UPDATE `rp_archievements` SET `%i` = '1' WHERE steamid = '%s';", type, steamID[client]);					
		
		char playername[64];
		GetClientName(client, STRING(playername));
		
		char translation[128];
		Format(STRING(translation), "%T", "NewArchievement_All", LANG_SERVER, playername, archi_name);
		CPrintToChatAll("%s %s", translation);
	}	
}	

void GetArchievementName(int type, char[] name, int maxlength)
{
	KeyValues kv = new KeyValues("Archievements");

	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, STRING(sPath), "data/roleplay/archievements.cfg");
	
	Kv_CheckIfFileExist(kv, sPath);
	
	char kv_typeid[16];
	IntToString(type, STRING(kv_typeid));
	if(kv.JumpToKey(kv_typeid))
	{	
		char result[64], translation[128];
		kv.GetString("name", STRING(result));		
		Format(STRING(translation), "%T", result, LANG_SERVER);
		strcopy(name, maxlength, translation);
	}	
	
	kv.Rewind();
	delete kv;
}

/***************************************************************************************

									C L I E N T - S I D E

***************************************************************************************/

public void OnClientAuthorized(int client, const char[] auth) 
{	
	strcopy(steamID[client], sizeof(steamID[]), auth);
}

public void OnClientPostAdminCheck(int client) 
{	
	char playername[MAX_NAME_LENGTH + 8];
	GetClientName(client, STRING(playername));
	char clean_playername[MAX_NAME_LENGTH * 2 + 16];
	SQL_EscapeString(g_DB, playername, STRING(clean_playername));
	
	char buffer[1024];
	Format(STRING(buffer), "INSERT IGNORE INTO `rp_archievements` (`id`, `steamid`, `playername`, `0`, `1`) VALUES (NULL, '%s', '%s', '0', '0');", steamID[client], clean_playername);	
	g_DB.Query(SQL_CheckForErrors, buffer);
	Format(STRING(buffer), "INSERT IGNORE INTO `rp_archievements_stats` (`id`, `steamid`, `playername`, `headshots`) VALUES (NULL, '%s', '%s', '0');", steamID[client], clean_playername);	
	g_DB.Query(SQL_CheckForErrors, buffer);
	
	SQL_LoadClient(client);
}

public void OnClientPutInServer(int client)
{
	archiv_data[client].headshots = 0;
	rp_SetSuccess(client, archi_newplayer, false);
	rp_SetSuccess(client, archi_headshotman, false);
	
	if(rp_GetClientBool(client, b_IsNew) && !rp_GetSuccess(client, archi_newplayer))
	{
		rp_SetSuccess(client, archi_newplayer, true);
	}	
}

public void OnClientDisconnect(int client)
{
	rp_SetSuccess(client, archi_newplayer, false);
	rp_SetSuccess(client, archi_headshotman, false);
}	

public Action rp_OnClientDeath(int attacker, int victim, const char[] weapon, bool headshot)
{
	if(headshot)
	{
		archiv_data[attacker].headshots++;
						
		if (archiv_data[attacker].headshots == 100)
		{
			rp_SetClientInt(attacker, i_Money, rp_GetClientInt(attacker, i_Money) + 1000);
			EmitCashSound(attacker, 1000);
			rp_SetSuccess(attacker, archi_headshotman, true);
			SQL_Request(g_DB, "UPDATE `rp_archievements_stats` SET `headshots` = '%i' WHERE steamid = '%s';", archiv_data[attacker].headshots, steamID[attacker]);		
		}
	}
}	