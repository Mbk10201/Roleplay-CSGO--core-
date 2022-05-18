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

#define URL_API ""

/***************************************************************************************

										H E A D E R

***************************************************************************************/
#include <roleplay_csgo.inc>

Database 
	g_DB,
	api_DB;

enum struct CvarData {
	ConVar Plugin_Enabled;
}
CvarData cvars;

enum struct UserSync
{
	int id;
	int admin;
	int tutorial;
	int nationality;
	int sexe;
	int jobid;
	int gradeid;
	int level;
	int xp;
	int money;
	int bank;
	int playtime;
	int viptime;
	
	char name[64];
	char steam32[32];
	char steam64[32];
	char tag[64];
	char country[64];
	char ip[64];
}
UserSync sync[128];

/***************************************************************************************

							P L U G I N  -  I N F O

***************************************************************************************/
public Plugin myinfo = 
{
	name = "Roleplay - API", 
	author = "MBK", 
	description = "API Data for the website", 
	version = "1.0", 
	url = "https://github.com/Mbk10201"
};

/***************************************************************************************

									 F U N C T I O N S

***************************************************************************************/
public void OnPluginStart()
{
	LoadTranslation();
	
	PrintToServer("[REQUIREMENT] API ✓");
	
	if(api_DB == null)
		Database.Connect(GotDatabase, "api");
		
	cvars.Plugin_Enabled = CreateConVar("plugin_enabled", "1", "Enable plugin api");
	AutoExecConfig(true, "rp_api", "roleplay");
		
	
	/*	API FROM WEBSITE */
	HTTPRequest file;
	char sBuffer[PLATFORM_MAX_PATH];
	
	BuildPath(Path_SM, STRING(sBuffer), "data/roleplay/json/jobs.json");
	file = new HTTPRequest("https://api.community-infinity.fr/roleplay/jobs");
	file.DownloadFile(sBuffer, API_OnJobsDownloaded);
}

public void OnConfigsExecuted()
{
	if(cvars.Plugin_Enabled.IntValue == 0)
		SetFailState("Plugin disabled");
}

public void OnMapStart()
{
	if(api_DB == null)
		Database.Connect(GotDatabase, "api");
	
	CreateTimer(25.0, Timer_Sync, _, TIMER_REPEAT);
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
		api_DB = db;
		Transaction SQLInit = new Transaction();
		
		char sBuffer[2048];
	
		Format(STRING(sBuffer), "CREATE TABLE IF NOT EXISTS `rp_api` ( \
		  `playerid` int(20) NOT NULL, \
		  `name` varchar(64) NOT NULL, \
		  `steamid_32` varchar(32) NOT NULL, \
		  `steamid_64` varchar(64) NOT NULL, \
		  `tag` varchar(64) NOT NULL DEFAULT 'N/A', \
		  `country` varchar(32) NOT NULL, \
		  `ip` varchar(32) NOT NULL, \
		  `admin` int(1) NOT NULL DEFAULT '0', \
		  `tutorial` int(1) NOT NULL, \
		  `nationality` int(10) NOT NULL, \
		  `sexe` int(10) NOT NULL, \
		  `jobid` int(10) NOT NULL, \
		  `gradeid` int(10) NOT NULL, \
		  `level` int(10) NOT NULL, \
		  `xp` int(10) NOT NULL, \
		  `money` int(10) NOT NULL, \
		  `bank` int(10) NOT NULL, \
		  `playtime` int(10) NOT NULL, \
		  `viptime` int(10) NOT NULL, \
		  PRIMARY KEY (`playerid`), \
		  UNIQUE KEY `playerid` (`playerid`) \
		  )ENGINE = InnoDB DEFAULT CHARSET = utf8 COLLATE = utf8_bin;");
		#if DEBUG
			PrintToServer(sBuffer);
		#endif
		SQLInit.AddQuery(sBuffer);
		
		Format(STRING(sBuffer), "CREATE TABLE IF NOT EXISTS `web_users` ( \
		  `id` int(20) NOT NULL AUTO_INCREMENT, \
		  `email` varchar(32) NOT NULL, \
		  `steamid` varchar(64) NOT NULL, \
		  `username` varchar(64) NOT NULL, \
		  `password` varchar(128) NOT NULL, \
		  `role` int(1) NOT NULL DEFAULT '0', \
		  `mail_confirmed` int(1) NOT NULL DEFAULT '0', \
		  `joindate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP, \
		  PRIMARY KEY (`id`), \
		  UNIQUE KEY `id` (`id`) \
		)ENGINE = InnoDB DEFAULT CHARSET = utf8 COLLATE = utf8_bin;");
		#if DEBUG
			PrintToServer(sBuffer);
		#endif
		SQLInit.AddQuery(sBuffer);
	  
		Format(STRING(sBuffer), "CREATE TABLE IF NOT EXISTS `web_bans` ( \
		  `id` int(20) NOT NULL AUTO_INCREMENT,\
		  `user` int(20) NOT NULL, \
		  `admin` int(10) NOT NULL, \
		  `time` int(32) NOT NULL, \
		  `raison` varchar(256) NOT NULL, \
		  PRIMARY KEY (`id`), \
		  FOREIGN KEY (`user`) REFERENCES `web_users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE \
		)ENGINE = InnoDB DEFAULT CHARSET = utf8 COLLATE = utf8_bin;");
		#if DEBUG
			PrintToServer(sBuffer);
		#endif
		SQLInit.AddQuery(sBuffer);
	  
		Format(STRING(sBuffer), "CREATE TABLE IF NOT EXISTS `web_confirmations` ( \
		  `id` int(20) NOT NULL AUTO_INCREMENT, \
		  `code` varchar(64) NOT NULL, \
		  `confirmed` int(1) NOT NULL, \
		  `user` int(10) NOT NULL, \
		  PRIMARY KEY (`id`), \
		  FOREIGN KEY (`user`) REFERENCES `web_users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE \
		)ENGINE = InnoDB DEFAULT CHARSET = utf8 COLLATE = utf8_bin;");
		#if DEBUG
			PrintToServer(sBuffer);
		#endif
		SQLInit.AddQuery(sBuffer);
	  
		Format(STRING(sBuffer), "CREATE TABLE IF NOT EXISTS `web_products` ( \
		  `id` int(20) NOT NULL AUTO_INCREMENT, \
		  `name` varchar(64) NOT NULL, \
		  `price` int(20) NOT NULL, \
		  `imagefile` varchar(256) NOT NULL, \
		  `category` varchar(64) NOT NULL, \
		  `description` varchar(512) NOT NULL, \
		  PRIMARY KEY (`id`)\
		)ENGINE = InnoDB DEFAULT CHARSET = utf8 COLLATE = utf8_bin;");
		#if DEBUG
			PrintToServer(sBuffer);
		#endif
		SQLInit.AddQuery(sBuffer);
	  
		Format(STRING(sBuffer), " CREATE TABLE IF NOT EXISTS `web_cart` ( \
		  `id` int(20) NOT NULL AUTO_INCREMENT, \
		  `user` int(10) NOT NULL, \
		  `product` int(10) NOT NULL, \
		  `quantity` int(10) NOT NULL, \
		  PRIMARY KEY (`id`), \
		  FOREIGN KEY (`user`) REFERENCES `web_users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE, \
		  FOREIGN KEY (`product`) REFERENCES `web_products` (`id`) ON DELETE CASCADE ON UPDATE CASCADE \
		)ENGINE = InnoDB DEFAULT CHARSET = utf8 COLLATE = utf8_bin;");
		#if DEBUG
			PrintToServer(sBuffer);
		#endif
		SQLInit.AddQuery(sBuffer);
	  
		Format(STRING(sBuffer), "CREATE TABLE IF NOT EXISTS `web_news` ( \
		  `id` int(20) NOT NULL AUTO_INCREMENT, \
		  `title` varchar(128) NOT NULL, \
		  `content` varchar(2048) NOT NULL, \
		  `date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP, \
		  PRIMARY KEY (`id`)\
		)ENGINE = InnoDB DEFAULT CHARSET = utf8 COLLATE = utf8_bin;");
		#if DEBUG
			PrintToServer(sBuffer);
		#endif
		SQLInit.AddQuery(sBuffer);
	  
		Format(STRING(sBuffer), "CREATE TABLE IF NOT EXISTS `web_patchnotes` ( \
		  `id` int(20) NOT NULL AUTO_INCREMENT, \
		  `title` varchar(128) NOT NULL, \
		  `content` varchar(2048) NOT NULL, \
		  `owner` varchar(64) NOT NULL, \
		  `status` varchar(64) NOT NULL, \
		  `date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP, \
	  	   PRIMARY KEY (`id`)\
		)ENGINE = InnoDB DEFAULT CHARSET = utf8 COLLATE = utf8_bin;");
		#if DEBUG
			PrintToServer(sBuffer);
		#endif
		SQLInit.AddQuery(sBuffer);
	  
		Format(STRING(sBuffer), " CREATE TABLE IF NOT EXISTS `web_servers` ( \
		  `id` int(20) NOT NULL AUTO_INCREMENT, \
		  `ip` varchar(32) NOT NULL, \
		  `port` varchar(16) NOT NULL, \
		  PRIMARY KEY (`id`)\
		)ENGINE = InnoDB DEFAULT CHARSET = utf8 COLLATE = utf8_bin;");
		#if DEBUG
			PrintToServer(sBuffer);
		#endif
		SQLInit.AddQuery(sBuffer);
	  
		Format(STRING(sBuffer), "CREATE TABLE IF NOT EXISTS `web_stats` ( \
		  `totalvisits` int(10) NOT NULL, \
		  PRIMARY KEY (`totalvisits`), \
		  UNIQUE KEY `totalvisits` (`totalvisits`) \
		)ENGINE = InnoDB DEFAULT CHARSET = utf8 COLLATE = utf8_bin;");
		#if DEBUG
			PrintToServer(sBuffer);
		#endif
		SQLInit.AddQuery(sBuffer);
		  
		Format(STRING(sBuffer), "INSERT INTO `web_stats`(`totalvisits`) VALUES('0');");
		#if DEBUG
			PrintToServer(sBuffer);
		#endif
		SQLInit.AddQuery(sBuffer);
		  
		Format(STRING(sBuffer), "CREATE TABLE IF NOT EXISTS `web_svlicences` ( \
		  `id` int(20) NOT NULL AUTO_INCREMENT, \
		  `ip` varchar(32) NOT NULL, \
		  `token` varchar(64) NOT NULL, \
		  `enabled` int(1) NOT NULL DEFAULT '0', \
		  PRIMARY KEY (`id`)\
		)ENGINE = InnoDB DEFAULT CHARSET = utf8 COLLATE = utf8_bin;");
		#if DEBUG
			PrintToServer(sBuffer);
		#endif
		SQLInit.AddQuery(sBuffer);
		
		db.Execute(SQLInit, SQL_OnSucces, SQL_OnFailed, 0, DBPrio_High);
	}
}

public void RP_OnSQLInit(Database db, Transaction transaction)
{
	g_DB = db;
}

public Action Timer_Sync(Handle timer)
{
	PrintToServer("[API - SQL] Synchronisation ...");
	
	int count = 0;
	int maxplayers = 0;
	char sQuery[2048];
	
	if(g_DB != null)
	{
		Format(STRING(sQuery), "SELECT * FROM `rp_admin`");	 
		DBResultSet Results = SQL_Query(g_DB, sQuery);
		while(Results.FetchRow())
		{
			count++;
			Results.FetchIntByName("level", sync[count].admin);
			Results.FetchStringByName("tag", sync[count].tag, sizeof(sync[].tag));
		}			
		delete Results;
		
		count = 0;
		
		Format(STRING(sQuery), "SELECT * FROM `rp_economy`");	 
		Results = SQL_Query(g_DB, sQuery);
		while(Results.FetchRow())
		{
			count++;
			Results.FetchIntByName("money", sync[count].money);
			Results.FetchIntByName("bank", sync[count].bank);
		}			
		delete Results;
		
		count = 0;
		
		Format(STRING(sQuery), "SELECT * FROM `rp_jobs`");	 
		Results = SQL_Query(g_DB, sQuery);
		while(Results.FetchRow())
		{
			count++;
			
			Results.FetchIntByName("jobid", sync[count].jobid);
			Results.FetchIntByName("gradeid", sync[count].gradeid);
		}			
		delete Results;
		
		count = 0;
		
		Format(STRING(sQuery), "SELECT * FROM `rp_players`");	 
		Results = SQL_Query(g_DB, sQuery);
		while(Results.FetchRow())
		{
			maxplayers++;
			count++;
			
			Results.FetchStringByName("steamid_32", sync[count].steam32, sizeof(sync[].steam32));
			Results.FetchStringByName("steamid_64", sync[count].steam64, sizeof(sync[].steam64));
			Results.FetchStringByName("playername", sync[count].name, sizeof(sync[].name));
			Results.FetchStringByName("country", sync[count].country, sizeof(sync[].country));
			Results.FetchStringByName("ip", sync[count].ip, sizeof(sync[].ip));
			
			Results.FetchIntByName("id", sync[count].id);
			Results.FetchIntByName("tutorial", sync[count].tutorial);
			Results.FetchIntByName("nationality", sync[count].nationality);
			Results.FetchIntByName("sexe", sync[count].sexe);
		}			
		delete Results;
		
		
		count = 0;
		
		Format(STRING(sQuery), "SELECT * FROM `rp_ranks`");	 
		Results = SQL_Query(g_DB, sQuery);
		while(Results.FetchRow())
		{
			count++;
			
			Results.FetchIntByName("rankid", sync[count].level);
			Results.FetchIntByName("xp", sync[count].xp);
		}			
		delete Results;
		
		Transaction SQLInit = new Transaction();
		
		for(int i = 1; i <= maxplayers; i++)
		{
			Format(STRING(sQuery), "SELECT name FROM `rp_api` WHERE `playerid` = '%i'", sync[i].id);	 
			Results = SQL_Query(api_DB, sQuery);
			if(!Results.FetchRow())
			{
				Format(STRING(sQuery), "INSERT INTO `rp_api` ( \
				`playerid`, `name`, `steamid_32`, `steamid_64`, `tag`, `country`, `ip`, `admin`, `tutorial`, `nationality`, `sexe`, `jobid`,\
				`gradeid`, `level`, `xp`, `money`, `bank`, `playtime`, `viptime`) \
				VALUES ('%i', '%s', '%s', '%s', '%s', '%s', '%s', '%i', '%i', '%i', '%i', '%i', '%i', '%i', '%i', '%i', '%i', '%i', '%i');", \
				sync[i].id, sync[i].name, sync[i].steam32, sync[i].steam64, sync[i].tag, sync[i].country, sync[i].ip, sync[i].admin, sync[i].tutorial, \
				sync[i].nationality, sync[i].sexe, sync[i].jobid, sync[i].gradeid, sync[i].level, sync[i].xp, sync[i].money, sync[i].bank, sync[i].playtime, sync[i].viptime);
			}
			else
			{
				Format(STRING(sQuery), "UPDATE `rp_api` SET \
					`name` = '%s', \
					`steamid_32` = '%s', \
					`steamid_64` = '%s', \
					`tag` = '%s', \
					`country` = '%s', \
					`ip` = '%s', \
					`admin` = '%i', \
					`tutorial` = '%i', \
					`nationality` = '%i', \
					`sexe` = '%i', \
					`jobid` = '%i', \
					`gradeid` = '%i', \
					`level` = '%i', \
					`xp` = '%i', \
					`money` = '%i', \
					`bank` = '%i', \
					`playtime` = '%i', \
					`viptime` = '%i' \
					WHERE `playerid` = '%i'", \
					sync[i].name, sync[i].steam32, sync[i].steam64, sync[i].tag, sync[i].country, sync[i].ip, sync[i].admin, sync[i].tutorial, \
					sync[i].nationality, sync[i].sexe, sync[i].jobid, sync[i].gradeid, sync[i].level, sync[i].xp, sync[i].money, sync[i].bank, \
					sync[i].playtime, sync[i].viptime, sync[i].id);
			}
			delete Results;
			
			SQLInit.AddQuery(sQuery);
		}
		
		api_DB.Execute(SQLInit, SQL_OnSucces, SQL_OnFailed);
		
		PrintToServer("[API - SQL] Synchronisation OK ...");
	}
	else
		PrintToServer("[API - SQL] Synchronisation FAIL ...");
		
	return Plugin_Handled;
}

void API_OnJobsDownloaded(HTTPStatus status, any value)
{
	if (status != HTTPStatus_OK) 
	{
		#if DEBUG
			PrintToServer("Telechargement erroné (data/roleplay/json/jobs.json)");
		#endif
		return;
	}
	
	#if DEBUG
		PrintToServer("Telechargement complet (data/roleplay/json/jobs.json)");
	#endif
		
	SetJobs();
}

void SetJobs()
{
	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPath, sizeof(sPath), "data/roleplay/json/jobs.json");
	
	JSONArray array = JSONArray.FromFile(sPath); 
	JSONObject row;
	char sTmp[128];

	for (int i = 0; i < array.Length; i++)
	{
		row = view_as<JSONObject>(array.Get(i));
		
		int id = row.GetInt("id");
		
		row.GetString("jobname", STRING(sTmp));
		rp_SetJobName(id, STRING(sTmp));
		
		rp_SetJobCapital(id, row.GetInt("capital"));
		
		row.GetString("doors", STRING(sTmp));
		rp_SetJobDoors(id, STRING(sTmp));
		
		rp_SetCanJobSell(id, view_as<bool>(row.GetInt("cansell")));
		
		JSONArray grades = view_as<JSONArray>(row.Get("grades"));
		JSONObject gradeRow;
		
		for (int j = 0; j < grades.Length; j++)
		{
			gradeRow = view_as<JSONObject>(grades.Get(j));
			
			gradeRow.GetString("grade", STRING(sTmp));
			rp_SetGradeName(id, j+1, STRING(sTmp));
			
			gradeRow.GetString("clantag", STRING(sTmp));
			rp_SetGradeClantag(id, j+1, STRING(sTmp));
			
			rp_SetGradeSalary(id, j+1, gradeRow.GetInt("salary"));
			
			gradeRow.GetString("model", STRING(sTmp));
			rp_SetGradeModel(id, j+1, STRING(sTmp));
			
			delete gradeRow;
		}
		
		delete row;
	}
}