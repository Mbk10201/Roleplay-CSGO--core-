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

Database g_DB;
int m_iOffsetLevel = -1;
int m_iLevel[MAXPLAYERS + 1];
char steamID[MAXPLAYERS + 1][32];
bool HasHeliDrop[MAXPLAYERS + 1] = {false, ...};
KeyValues gKv;

enum struct Data_Forward {
	GlobalForward OnLevelUp;
}	
Data_Forward Forward;


/***************************************************************************************

							P L U G I N  -  I N F O

***************************************************************************************/
public Plugin myinfo = 
{
	name = "Roleplay - Ranking & Top", 
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
	
	// Register localy the Offset of the csgo level for changing level image
	m_iOffsetLevel = FindSendPropInfo("CCSPlayerResource", "m_nPersonaDataPublicLevel");
	
	/*----------------------------------Commands-------------------------------*/
	// Register all local plugin commands available in game
	RegConsoleCmd("levelup", Cmd_Levelup);
	/*-------------------------------------------------------------------------------*/
}

public void RP_OnSQLInit(Database db, Transaction transaction)
{
	g_DB = db;
	transaction.AddQuery("CREATE TABLE IF NOT EXISTS `rp_ranks_data` ( \
	  `id` int(20) NOT NULL, \
	  `xp_required` varchar(32) NOT NULL, \
	  `name` varchar(32) NOT NULL, \
	  `advantage` varchar(128) NOT NULL, \
	  PRIMARY KEY (`id`), \
	  UNIQUE KEY `playerid` (`id`) \
	  )ENGINE = InnoDB DEFAULT CHARSET = utf8 COLLATE = utf8_bin;");
	
	transaction.AddQuery("CREATE TABLE IF NOT EXISTS `rp_ranks` ( \
	  `playerid` int(20) NOT NULL, \
	  `rankid` int(20) NOT NULL, \
	  `xp` int(100) NOT NULL, \
	  PRIMARY KEY (`playerid`), \
	  UNIQUE KEY `playerid` (`playerid`), \
	  FOREIGN KEY (`playerid`) REFERENCES `rp_players` (`id`) ON DELETE CASCADE ON UPDATE CASCADE, \
	  FOREIGN KEY (`rankid`) REFERENCES `rp_ranks_data` (`id`) ON DELETE CASCADE ON UPDATE CASCADE \
	  )ENGINE = InnoDB DEFAULT CHARSET = utf8 COLLATE = utf8_bin;");
	  
	/*----------------------------------Load Ranks file into plugin-------------------------------*/
	gKv = new KeyValues("Rank");
	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, STRING(sPath), "data/roleplay/rank.cfg");
	Kv_CheckIfFileExist(gKv, sPath);
	/*-------------------------------------------------------------------------------*/
	
	// Jump into the first subsection
	if (!gKv.GotoFirstSubKey())
	{
		PrintToServer("ERROR FIRST KEY");
		delete gKv;
		return;
	}
	
	char sId[8];
	do
	{
		if(gKv.GetSectionName(STRING(sId)))
		{
			char sBuffer[MAX_BUFFER_LENGTH + 1];
			char sXpRequired[32], sName[32], sAdvantage[128];
			
			gKv.GetString("xp_required", STRING(sXpRequired));
			gKv.GetString("name", STRING(sName));
			gKv.GetString("advantage", STRING(sAdvantage));
			
			SQL_EscapeString(db, sAdvantage, STRING(sAdvantage)); // TODO
			Format(STRING(sBuffer), "INSERT IGNORE INTO `rp_ranks_data` (`id`, `xp_required`, `name`, `advantage`) VALUES ('%s', '%s', '%s', '%s');", sId, sXpRequired, sName, "");
			transaction.AddQuery(sBuffer);	
		}	
	} 
	while (gKv.GotoNextKey());
	
	gKv.Rewind(); 
}

public APLRes AskPluginLoad2(Handle plugin, bool late, char[] error, int err_max)
{
	RegPluginLibrary("rp_ranking");
	
	/*------------------------------------FORWADS------------------------------------*/
	Forward.OnLevelUp = new GlobalForward("RP_OnLevelUp", ET_Event, Param_Cell, Param_Cell);	
	/*-------------------------------------------------------------------------------*/
	
	return APLRes_Success;
}	

public void OnMapStart()
{
	if(rp_GetGame() == Engine_CSGO)
		SDKHook(GetPlayerResourceEntity(), SDKHook_ThinkPost, OnThinkPost);
}	

public void OnPluginEnd()
{
	LoopClients(i)
	{
		if(!IsClientValid(i))
			continue;			
		SQL_SaveClient(i);
	}
	
	if(gKv != null)
		delete gKv;
}

public void OnMapEnd()
{
	LoopClients(i)
	{
		if(!IsClientValid(i))
			continue;
		SQL_SaveClient(i);
	}	
	
	if(gKv != null)
		delete gKv;
}
/***************************************************************************************

									C A L L B A C K

***************************************************************************************/

void SQL_SaveClient(int client)
{
	SQL_Request(g_DB, "UPDATE `rp_ranks` SET `rankid` = '%i', `xp` = '%i' WHERE `playerid` = '%i';", rp_GetClientInt(client, i_Rank), rp_GetClientInt(client, i_XP), rp_GetSQLID(client));	
}	

public void RP_ClientTimerEverySecond(int client)
{
	if(IsClientValid(client))
	{
		char xp[8];
		rp_GetRank(rp_GetClientInt(client, i_Rank) + 1, rank_xpreq, STRING(xp));
		if(rp_GetClientInt(client, i_XP) >= StringToInt(xp))
		{
			if(rp_IsValidRank(rp_GetClientInt(client, i_Rank) + 1))
			{
				rp_SetClientInt(client, i_Rank, rp_GetClientInt(client, i_Rank) + 1);
				char advantage[128], img_url[128];
				rp_GetRank(rp_GetClientInt(client, i_Rank), rank_advantage, STRING(advantage));
				GetClientRankImage(client, STRING(img_url));
				
				if(strlen(advantage) != 0)
					ShowPanel2(client, 2, "Level <font color='#0070FF'>%i</font><font color='#00FF76'>+</font> %s", rp_GetClientInt(client, i_Rank), img_url);
				else
					ShowPanel2(client, 2, "Level <font color='#0070FF'>%i</font><font color='#00FF76'>+</font>", rp_GetClientInt(client, i_Rank));		
				rp_PrintToChat(client, "Avantages du niveau %i: %s", rp_GetClientInt(client, i_Rank), advantage);					
				
				rp_Sound(client, "sound_levelup", 0.3);
				SQL_SaveClient(client);
				
				//rp_SendHelicopter(client, GIFT);
				HasHeliDrop[client] = true;
				rp_SetClientBool(client, b_DisplayHud, false);
				Panel panel = new Panel();
				panel.SetTitle("Livraison - Cadeau");
				panel.DrawText("     \n\n");
				panel.DrawText("Un hélicoptère est en route vers vous,");
				panel.DrawText("Celui-ci vous fera un drop d'un cadeau.");
				panel.DrawText("     \n\n");
				panel.DrawText("Profitez-en a chaque passage de niveau.");
				panel.Send(client, HandleNothing, 15);
				
				Call_StartForward(Forward.OnLevelUp); 
				Call_PushCell(client);
				Call_PushCell(rp_GetClientInt(client, i_Rank));
				Call_Finish();
			}	
		}
	}
}

public Action Cmd_Levelup(int client, int args)
{
	if(client == 0)
	{
		PrintToServer("%T", "Command_NotAvailable", LANG_SERVER);
		return Plugin_Handled;
	}
	
	rp_SetClientInt(client, i_XP, rp_GetClientInt(client, i_XP) + 100);
	
	return Plugin_Handled;
}	

public void SQL_LoadClient(int client) 
{
	if(!IsClientValid(client))
		return;
			
	char buffer[512];
	Format(STRING(buffer), "SELECT * FROM `rp_ranks` WHERE `playerid` = '%s';", rp_GetSQLID(client));
	g_DB.Query(SQL_Callback, buffer, GetClientUserId(client));
}

public void SQL_Callback(Database db, DBResultSet Results, const char[] error, any data) 
{	
	int client = GetClientOfUserId(data);
	if(Results.FetchRow()) 
	{
		rp_SetClientInt(client, i_Rank, SQL_FetchIntByName(Results, "rankid"));
		rp_SetClientInt(client, i_XP, SQL_FetchIntByName(Results, "xp"));
	}
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
	if(!IsClientValid(client))
		return;
	
	char sQuery[1024];
	Format(STRING(sQuery), 
	"INSERT IGNORE INTO `rp_ranks` ( \
	  `playerid`, \
	  `rankid`,\
	  `xp`\
	  ) VALUES ('%i', '0', '0');", rp_GetSQLID(client));	
	#if DEBUG
		PrintToServer("[RP_SQL] %s", sQuery);
	#endif
	g_DB.Query(SQL_CheckForErrors, sQuery);
	SQL_LoadClient(client);
}


public void RP_OnClientSpawn(int client)
{
	//LoadTopData(client);
}	

public void OnClientPutInServer(int client) 
{	
	m_iLevel[client] = -1;
}

public void OnClientDisconnect(int client) 
{
	m_iLevel[client] = -1;
	SQL_SaveClient(client);
}

public void OnThinkPost(int m_iEntity)
{
	int m_iLevelTemp[MAXPLAYERS + 1] = {0, ...};
	GetEntDataArray(m_iEntity, m_iOffsetLevel, m_iLevelTemp, MAXPLAYERS+1);

	LoopClients(i)
	{
		if(!IsClientValid(i))
			continue;
			
		if(m_iLevel[i] != -1)
		{
			if(m_iLevel[i] != m_iLevelTemp[i])
			{
				SetEntData(m_iEntity, m_iOffsetLevel + (i * 4), m_iLevel[i]);
			}
		}
	}
}

public void RP_OnClientInteract(int client, int target, const char[] class, const char[] model, const char[] name)
{
	if(IsEntityModelInArray(target, "model_airdrop"))
	{
		if(HasHeliDrop[client])
		{
			int owner = Client_FindBySteamId(name);
			if(owner == client)
			{
				RemoveEdict(target);
				
				HasHeliDrop[client] = false;
				
				int random = GetRandomInt(0, 2);
				switch(random)
				{
					case 0:
					{
						random = GetRandomInt(150, MAXDROPAMOUNT);
						rp_SetClientInt(client, i_Money, rp_GetClientInt(client, i_Money) + random);
						rp_PrintToChat(client, "Vous avez reçu {lightgreen}%i{lightred}$ {default}.", random);
					}
					case 1:
					{
						rp_PrintToChat(client, "Malheureusement vous n'avez rien gagné cette fois.", random);
					}
					case 2:
					{
						random = GetRandomInt(1, MAXITEMS);
						do {
							random = GetRandomInt(1, MAXITEMS);
						}	
						while (!rp_IsItemValidIndex(random));
						
						char itemname[64];
						rp_GetItemData(random, item_name, STRING(itemname));
						
						rp_PrintToChat(client, "Vous avez reçu {orange}1{lightgreen}x {lightblue}%s", itemname);
					}
				}
			}
		}	
	}
}

public void RP_OnLevelUp(int client, int new_rank)
{
	if(new_rank == 5)
		rp_SetClientInt(client, i_XP, rp_GetClientInt(client, i_XP) + 125);
	else if(new_rank == 10)
	{
		SetClientCookie(client, FindClientCookie("rpv_casinoextra"), "1");
		rp_SetClientBool(client, b_HasCasinoAccess, true);	
		rp_PrintToChat(client, "Vous avez débloqué certaines fonctionnalité au casino.");
	}	
	else if(new_rank == 15)
	{
		SetClientCookie(client, FindClientCookie("rpv_itemstorage"), "150");
		rp_SetClientBool(client, b_HasCasinoAccess, true);	
		rp_PrintToChat(client, "Vous avez débloqué {lightgreen}50 emplacements {default}de plus pour stocker vos items.");
	}	
}