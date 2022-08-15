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

#warning PLEASE NOTE, This plugin need to be finished

/***************************************************************************************

							P L U G I N  -  I N C L U D E S

***************************************************************************************/
#include <roleplay_csgo>

/***************************************************************************************

							G L O B A L  -  V A R S

***************************************************************************************/
char logFile[PLATFORM_MAX_PATH];
char steamID[MAXPLAYERS + 1][32];
char definedName[MAXPLAYERS + 1][64];
bool canDefine[MAXPLAYERS + 1] = false;

Database g_DB;

/***************************************************************************************

							P L U G I N  -  I N F O

***************************************************************************************/
public Plugin myinfo = 
{
	name = "[Roleplay] Groupe",
	author = "Benito",
	description = "Système de groupes",
	version = "1.0",
	url = "https://github.com/Mbk10201"
};

/***************************************************************************************

							P L U G I N  -  E V E N T S

***************************************************************************************/
public void OnPluginStart()
{	
	LoadTranslation();
	
	BuildPath(Path_SM, STRING(logFile), "logs/roleplay/rp_groupes.log");
		
	RegConsoleCmd("creategroupe", Cmd_Groupe);
}		

public Action Cmd_Groupe(int client, int args)
{
	rp_SetClientBool(client, b_DisplayHud, false);
	Panel panel = new Panel();
	panel.SetTitle("-----------_Groupes_-----------");
	panel.DrawText("Entrer le nom du groupe dans le chat.");
	panel.Send(client, HandleNothing, 20);
	canDefine[client] = true; 
}	

public void RP_OnDatabaseLoaded(Database db)
{
	char buffer[MAX_BUFFER_LENGTH];
	Format(STRING(buffer), 
	"CREATE TABLE IF NOT EXISTS `rp_groupes` ( \
	  `Id` int(255) NOT NULL AUTO_INCREMENT, \
	  `groupename` varchar(64) COLLATE utf8_bin NOT NULL, \
	  `owner` varchar(64) COLLATE utf8_bin NOT NULL, \
	  `level` varchar(64) COLLATE utf8_bin NOT NULL, \
	  `membres` varchar(64) COLLATE utf8_bin NOT NULL, \
	  `maxmembres` varchar(64) COLLATE utf8_bin NOT NULL, \
	  `points` varchar(64) COLLATE utf8_bin NOT NULL, \
	  `argent` varchar(64) COLLATE utf8_bin NOT NULL, \
	  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, \
	  PRIMARY KEY (`Id`), \
	  UNIQUE KEY `groupename` (`groupename`) \
	  )ENGINE = InnoDB DEFAULT CHARSET = utf8 COLLATE = utf8_bin;");
	db.Query(SQLErrorCheckCallback, buffer);

	Format(STRING(buffer), 
	"CREATE TABLE IF NOT EXISTS `rp_clientgroupe` ( \
	  `Id` int(20) NOT NULL AUTO_INCREMENT, \
	  `steamid` varchar(20) COLLATE utf8_bin NOT NULL, \
	  `playername` varchar(64) COLLATE utf8_bin NOT NULL, \
	  `groupeid` int(1) NOT NULL, \
	  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, \
	  PRIMARY KEY (`Id`), \
	  UNIQUE KEY `steamid` (`steamid`) \
	  )ENGINE = InnoDB DEFAULT CHARSET = utf8 COLLATE = utf8_bin;");
	db.Query(SQLErrorCheckCallback, buffer);
	
	Format(STRING(buffer), 
	"CREATE TABLE IF NOT EXISTS `rp_groupes_history` ( \
	  `Id` int(20) NOT NULL, \
	  `note` varchar(1024) COLLATE utf8_bin NOT NULL, \
	  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, \
	 PRIMARY KEY (`Id`) \
	 )ENGINE = InnoDB DEFAULT CHARSET = utf8 COLLATE = utf8_bin;");
	db.Query(SQLErrorCheckCallback, buffer);
	
	SetGroupData();
}

void SetGroupData()
{
	char query[1024];
	Format(STRING(query), "SELECT * FROM rp_groupes");	 
	DBResultSet Results = SQL_Query(g_DB, query);
	
	while(Results.FetchRow())
	{			 
		int id = SQL_FetchIntByName(Results, "Id");
		
		char groupename[64];
		SQL_FetchStringByName(Results, "groupename", STRING(groupename));		
		rp_SetGroupString(id, group_type_name, STRING(groupename));
		
		char owner[64];
		SQL_FetchStringByName(Results, "owner", STRING(owner));		
		rp_SetGroupString(id, group_type_owner, STRING(owner));
		
		char level[64];
		SQL_FetchStringByName(Results, "level", STRING(level));		
		rp_SetGroupString(id, group_type_level, STRING(level));
		
		char membres[64];
		SQL_FetchStringByName(Results, "membres", STRING(membres));		
		rp_SetGroupString(id, group_type_membres, STRING(membres));
		
		char maxmembres[64];
		SQL_FetchStringByName(Results, "maxmembres", STRING(maxmembres));		
		rp_SetGroupString(id, group_type_maxMembres, STRING(maxmembres));
		
		char points[64];
		SQL_FetchStringByName(Results, "points", STRING(points));		
		rp_SetGroupString(id, group_type_pointClan, STRING(points));
		
		char argent[64];
		SQL_FetchStringByName(Results, "argent", STRING(argent));		
		rp_SetGroupString(id, group_type_money, STRING(argent));
	}		
		
	delete Results;
}

public void OnClientAuthorized(int client, const char[] auth) 
{	
	strcopy(steamID[client], sizeof(steamID[]), auth);
}

public void OnClientPostAdminCheck(int client) 
{					
	char playername[MAX_NAME_LENGTH + 8];
	GetClientName(client, STRING(playername));
	char clean_playername[MAX_NAME_LENGTH * 2 + 16];
	SQL_EscapeString(rp_GetDatabase(), playername, STRING(clean_playername));
	
	char buffer[2048];
	Format(STRING(buffer), "INSERT IGNORE INTO `rp_clientgroupe` (`Id`, `steamid`, `playername`, `groupeid`, `timestamp`) VALUES (NULL, '%s', '%s', '0', CURRENT_TIMESTAMP);", steamID[client], clean_playername);
	rp_GetDatabase().Query(SQLErrorCheckCallback, buffer);
	
	SQLCALLBACK_LoadGroupes(client);
}

public void SQLCALLBACK_LoadGroupes(int client) 
{
	if (!IsClientValid(client))
		return;
			
	char buffer[512];
	Format(STRING(buffer), "SELECT * FROM rp_clientgroupe WHERE steamid = '%s'", steamID[client]);
	rp_GetDatabase().Query(SQLLoadGroupesQueryCallback, buffer, GetClientUserId(client));
}

public void SQLLoadGroupesQueryCallback(Database db, DBResultSet Results, const char[] error, any data) 
{	
	int client = GetClientOfUserId(data);
	while (Results.FetchRow()) 
	{
		rp_SetClientInt(client, i_Group, SQL_FetchIntByName(Results, "groupeid"));
	}
} 

public Action RP_OnPlayerSay(int client, const char[] arg)
{
	if(canDefine[client])
	{
		if(strlen(arg) > 64)
		{
			rp_PrintToChat(client, "Le nom du groupe est trop long ! Réessayez.");
			return Plugin_Handled;
		}
		else if(strlen(arg) <= 64)
		{	
			strcopy(definedName[client], sizeof(definedName[]), arg);
			canDefine[client] = false;
			MenuGroupeStape1(client);
		}	
	}
	
	return Plugin_Continue;
}

int MenuGroupeStape1(int client)
{
	char buffer[128];
	
	rp_SetClientBool(client, b_menuOpen, true);
	
	Menu menu = new Menu(DoGroupeStape1);
	Format(STRING(buffer), "Créer %s", definedName[client]);
	menu.SetTitle(buffer);
	menu.AddItem("oui", "Oui");
	menu.AddItem("non", "Non");
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}	

public int DoGroupeStape1(Menu menu, MenuAction action, int client, int param)
{	
	if(action == MenuAction_Select) 
	{
		char info[32];
		menu.GetItem(param, STRING(info));
		
		if(StrEqual(info, "oui")) 
		{
			char buffer[2048];
			Format(STRING(buffer), "INSERT IGNORE INTO `rp_groupes` (`Id`, `groupename`, `owner`, `level`, `membres`, `maxmembres`, `points`, `argent`, `timestamp`) VALUES (NULL, '%s', '%s', '1', '1', '25', '0', '0', CURRENT_TIMESTAMP);", definedName[client], steamID[client]);
			rp_GetDatabase().Query(SQLErrorCheckCallback, buffer);
			
			int idgroup;
			
			Format(STRING(buffer), "SELECT Id FROM rp_groupes WHERE owner = '%s';", steamID[client]);
			DBResultSet query = SQL_Query(rp_GetDatabase(), buffer);			
			if(query)
			{
				while (query.FetchRow())
				{
					idgroup = query.FetchInt(0);
				}	
			}
			delete query;
			
			rp_SetClientInt(client, i_Group, idgroup);
			
			rp_PrintToChat(client, "Votre groupe %s a été créé avec succès.", TEAM, definedName[client]);
			SetGroupData();
		}
		else if(StrEqual(info, "non")) {
			delete menu;
			rp_SetClientBool(client, b_menuOpen, false);
		}
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit || param == MenuCancel_ExitBack)
			rp_SetClientBool(client, b_menuOpen, false);
	}
	else if(action == MenuAction_End)
		delete menu;
}

public Action RP_OnPlayerRoleplay(int client, Menu menu)
{
	if(rp_GetClientInt(client, i_Group) != 0)
		menu.AddItem("group", "Groupe");
}	

public int RP_OnPlayerRoleplayHandle(int client, const char[] info)
{
	if(StrEqual(info, "group"))
		BuildMenuGroupe(client);
}	

int BuildMenuGroupe(int client)
{
	char strFormat[128];
	rp_SetClientBool(client, b_menuOpen, true);
	
	Menu menu = new Menu(DoBuildMenuGroupe);
	menu.SetTitle("Groupe - Roleplay");
	
	char groupe_name[64];
	rp_GetGroupString(rp_GetClientInt(client, i_Group), group_type_name, STRING(groupe_name));
	Format(STRING(strFormat), "✦ Group: %s", groupe_name);
	menu.AddItem("", strFormat, ITEMDRAW_DISABLED);
	
	char groupe_owner[64];
	rp_GetGroupString(rp_GetClientInt(client, i_Group), group_type_owner, STRING(groupe_owner));
	int owner = Client_FindBySteamId(groupe_owner);
	char owner_name[64];
	GetClientName(owner, STRING(owner_name));
	Format(STRING(strFormat), "✦ Leader: %s", owner_name);
	menu.AddItem("", strFormat, ITEMDRAW_DISABLED);
	
	char groupe_membres[10], groupe_maxmembres[10];
	rp_GetGroupString(rp_GetClientInt(client, i_Group), group_type_membres, STRING(groupe_membres));
	rp_GetGroupString(rp_GetClientInt(client, i_Group), group_type_maxMembres, STRING(groupe_maxmembres));
	Format(STRING(strFormat), "✦ Membres: %s/%s", groupe_membres, groupe_maxmembres);
	menu.AddItem("", strFormat, ITEMDRAW_DISABLED);
	
	char groupe_money[64];
	rp_GetGroupString(rp_GetClientInt(client, i_Group), group_type_money, STRING(groupe_money));
	Format(STRING(strFormat), "✦ Argent: %s$", groupe_money);
	menu.AddItem("", strFormat, ITEMDRAW_DISABLED);
	
	menu.AddItem("give", "Donner de l'argent");
	
	menu.AddItem("show", "Voir les gangs du serveur");
	menu.AddItem("history", "Voir les historiques");
	
	if(client == owner)
	{
		menu.AddItem("remote", "Gérer");
		menu.AddItem("trade", "Transfert d'argent");
	}	
	else
		menu.AddItem("left", "Quitter");		
	
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}	

public int DoBuildMenuGroupe(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[64];
		menu.GetItem(param, STRING(info));
		
		if(StrEqual(info, "remote"))
			GererGang(client);
		else if(StrEqual(info, "left"))
		{
			if(IsClientValid(client))
			{
				int id = rp_GetClientInt(client, i_Group);
				char membres_str[64];
				rp_GetGroupString(id, group_type_membres, STRING(membres_str));
				int membres = StringToInt(membres_str);
				membres--;
				
				Format(STRING(membres_str), "%i", membres);
				rp_SetGroupString(id, group_type_membres, STRING(membres_str));
				
				UpdateSQL(rp_GetDatabase(), "UPDATE `rp_groupes` SET `membres` = '%i' WHERE Id = '%i';", membres, id);
				
				char groupe_name[64];
				rp_GetGroupString(client, group_type_name, STRING(groupe_name));
				
				rp_PrintToChat(client, "Vous avez quitté %s", TEAM, groupe_name);
				rp_SetClientInt(client, i_Group, 0);
				
				UpdateSQL(rp_GetDatabase(), "UPDATE `rp_clientgroupe` SET `groupeid` = '0' WHERE steamid = '%s';", steamID[client]);
				rp_SetClientBool(client, b_menuOpen, false);
			}
		}
		else if(StrEqual(info, "show"))
		{
			if(IsClientValid(client))
			{
				Menu menu1 = new Menu(Handler_NullCancel);
				menu1.SetTitle("Listes des gangs");
				
				for (int i = 1; i <= MAXGROUPES; i++)
				{
					char groupe_name[64];
					rp_GetGroupString(i, group_type_name, STRING(groupe_name));
					menu1.AddItem("", groupe_name);
				}	
				
				menu1.ExitButton = true;
				menu1.Display(client, MENU_TIME_FOREVER);
			}
		}
		else if(StrEqual(info, "give"))
		{
			if(IsClientValid(client))
			{
				Menu menu2 = new Menu(GroupeMoneyDeposit);
				menu2.SetTitle("Choisissez le montant");
				
				if(rp_GetClientInt(client, i_Bank) >= 1)
				{
					menu2.AddItem("all", "Tout déposer");
				}	
				if(rp_GetClientInt(client, i_Bank) >= 1)
					menu2.AddItem("1", "1$");
				if(rp_GetClientInt(client, i_Bank) >= 5)
					menu2.AddItem("5", "5$");
				if(rp_GetClientInt(client, i_Bank) >= 10)
					menu2.AddItem("10", "10$");
				if(rp_GetClientInt(client, i_Bank) >= 50)
					menu2.AddItem("50", "50$");
				if(rp_GetClientInt(client, i_Bank) >= 100)
					menu2.AddItem("100", "100$");
				if(rp_GetClientInt(client, i_Bank) >= 250)
					menu2.AddItem("250", "250$");
				if(rp_GetClientInt(client, i_Bank) >= 500)
					menu2.AddItem("500", "500$");
				if(rp_GetClientInt(client, i_Bank) >= 1000)
					menu2.AddItem("1000", "1000$");
				if(rp_GetClientInt(client, i_Bank) >= 2500)
					menu2.AddItem("2500", "2500$");
				if(rp_GetClientInt(client, i_Bank) >= 5000)
					menu2.AddItem("5000", "5000$");
				if(rp_GetClientInt(client, i_Bank) >= 10000)
					menu2.AddItem("10000", "10000$");
				if(rp_GetClientInt(client, i_Bank) >= 25000)
					menu2.AddItem("25000", "25000$");
				if(rp_GetClientInt(client, i_Bank) >= 50000)
					menu2.AddItem("50000", "50000$");
				if(rp_GetClientInt(client, i_Bank) == 0)
					menu2.AddItem("", "Vous n'avez pas d'argent", ITEMDRAW_DISABLED);	
					
				menu2.ExitButton = true;
				menu2.Display(client, MENU_TIME_FOREVER);
			}
		}
		else if(StrEqual(info, "history"))
		{	
			if(IsClientValid(client))
			{
				BuildGroupHistorique(client);
			}	
		}
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit || param == MenuCancel_ExitBack)
			rp_SetClientBool(client, b_menuOpen, false);
	}
	else if(action == MenuAction_End)
		delete menu;
}

public int ShowHistoryDonations(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{	
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit || param == MenuCancel_ExitBack)
			rp_SetClientBool(client, b_menuOpen, false);
	}
	else if(action == MenuAction_End)
		delete menu;
}

public int GroupeMoneyDeposit(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{	
		char info[32];
		menu.GetItem(param, STRING(info));
		
		int sommeDepose = StringToInt(info, 10);
		
		if(sommeDepose < 0)
			rp_PrintToChat(client, "%T", "Overdraft", LANG_SERVER, TEAM);		
		if(StrEqual(info, "all"))
		{
			int id = rp_GetClientInt(client, i_Group);
			
			char actual_money[64];
			rp_GetGroupString(id, group_type_money, STRING(actual_money));
			int money = StringToInt(actual_money);
			money += rp_GetClientInt(client, i_Bank);
			Format(STRING(actual_money), "%i", money);
			rp_SetGroupString(id, group_type_money, STRING(actual_money));
			
			char name[64];
			rp_GetGroupString(id, group_type_name, STRING(name));			
			char note[1024];
			Format(STRING(note), "%N à transferer %i$", client, rp_GetClientInt(client, i_Bank));
			UpdateSQL(rp_GetDatabase(), "INSERT IGNORE INTO `rp_groupes_history` (`Id`, `note`, `timestamp`) VALUES ('%i', '%s', CURRENT_TIMESTAMP);", id, note);
			
			rp_SetClientInt(client, i_Bank, 0);	
			UpdateSQL(rp_GetDatabase(), "UPDATE `rp_groupes` SET `argent` = '%i' WHERE Id = '%i';", money, id);
		}
		else if(rp_GetClientInt(client, i_Bank) >= sommeDepose)
		{
			int id = rp_GetClientInt(client, i_Group);
			
			rp_SetClientInt(client, i_Bank, rp_GetClientInt(client, i_Bank) - sommeDepose);	

			char actual_money[64];
			rp_GetGroupString(id, group_type_money, STRING(actual_money));
			int money = StringToInt(actual_money);
			money += sommeDepose;
			Format(STRING(actual_money), "%i", money);
			rp_SetGroupString(id, group_type_money, STRING(actual_money));
			
			EmitCashSound(client, sommeDepose);
			BuildMenuGroupe(client);
			
			char name[64];
			rp_GetGroupString(id, group_type_name, STRING(name));			
			char note[1024];
			Format(STRING(note), "%N à transferer %i$", client, rp_GetClientInt(client, i_Bank));
			UpdateSQL(rp_GetDatabase(), "INSERT IGNORE INTO `rp_groupes_history` (`Id`, `note`, `timestamp`) VALUES ('%i', '%s', CURRENT_TIMESTAMP);", id, note);
			
			rp_SetClientInt(client, i_Bank, 0);	
			UpdateSQL(rp_GetDatabase(), "UPDATE `rp_groupes` SET `argent` = '%i' WHERE Id = '%i';", money, id);
		}
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit || param == MenuCancel_ExitBack)
			rp_SetClientBool(client, b_menuOpen, false);
	}
	else if(action == MenuAction_End)
		delete menu;
}

int GererGang(int client)
{
	char groupename[64], strText[64];
	
	int id = rp_GetClientInt(client, i_Group);
	rp_GetGroupString(id, group_type_name, STRING(groupename));
	
	Menu menu = new Menu(DoGererGang);
	menu.SetTitle(groupename);
	
	char membres[64];
	rp_GetGroupString(rp_GetClientInt(client, i_Group), group_type_membres, STRING(membres));
	Format(STRING(strText), "Membres: %s", membres);
	menu.AddItem("getlistmembres", strText);
	
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}	

public int DoGererGang(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[64];
		menu.GetItem(param, STRING(info));
		if(StrEqual(info, "getlistmembres"))
		{
			LoopClients(i)
			{
				if(rp_GetClientInt(i, i_Group) == rp_GetClientInt(client, i_Group))
				{
					rp_SetClientBool(client, b_menuOpen, true);
					Menu menu1 = new Menu(DoMenuGererMembre);
					menu1.SetTitle("Gérer un membre :");
					
					char name[64], strIndex[64];
					GetClientName(i, STRING(name));
					Format(STRING(strIndex), "%i", i);
					if(i != client)
						menu1.AddItem(strIndex, name);	
					menu1.ExitButton = true;
					menu1.Display(client, MENU_TIME_FOREVER);
				}	
			}	
		}	
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit || param == MenuCancel_ExitBack)
			rp_SetClientBool(client, b_menuOpen, false);
	}
	else if(action == MenuAction_End)
		delete menu;
}

public int DoMenuGererMembre(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[64], strMenu[64];
		menu.GetItem(param, STRING(info));
		int joueur = StringToInt(info);
		
		rp_SetClientBool(client, b_menuOpen, true);
		Menu GererSub = new Menu(DoMenuActionMembre);		
		Format(STRING(strMenu), "%N :", joueur);
		GererSub.SetTitle(strMenu);
		
		Format(STRING(strMenu), "virer|%i", joueur);
		GererSub.AddItem(strMenu, "Virer");
		
		GererSub.ExitButton = true;
		GererSub.Display(client, MENU_TIME_FOREVER);	
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit || param == MenuCancel_ExitBack)
			rp_SetClientBool(client, b_menuOpen, false);
	}
	else if(action == MenuAction_End)
		delete menu;
}

public int DoMenuActionMembre(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[32], buffer[2][64];
		menu.GetItem(param, STRING(info));
		
		ExplodeString(info, "|", buffer, 2, 64);
		int joueur = StringToInt(buffer[1]);
		
		if(StrEqual(buffer[0], "virer"))
		{		
			char groupename[64];
			int id = rp_GetClientInt(client, i_Group);
			rp_GetGroupString(id, group_type_name, STRING(groupename));
			
			rp_SetClientInt(joueur, i_Group, 0);
			rp_PrintToChat(client, "Vous avez viré %N", TEAM, joueur);
			UpdateSQL(rp_GetDatabase(), "UPDATE `rp_clientgroupe` SET `rp_clientgroupe` = '0' WHERE steamid = '%s';", steamID[client]);
			
			if(IsClientValid(joueur))
				CPrintToChat(joueur, "%s %N vous a viré du gang %s", TEAM, client, groupename);
		}	
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit)
			rp_SetClientBool(client, b_menuOpen, false);
	}
	else if (action == MenuAction_End)
		delete menu;
}

public Action RP_PushToInteraction(Menu menu, int client)
{
	menu.AddItem("group", "Groupe");
}	

public int RP_PushToInteractionHandle(int client, const char[] info)
{
	int aim = GetClientAimTarget(client, false);
	if(StrEqual(info, "group"))
		InvitationGroup(client, aim);
}		

int InvitationGroup(int client, int aim)
{
	char strInfo[64];
	rp_SetClientBool(client, b_menuOpen, true);
	Menu menu = new Menu(DoInvitationGroup);
	Format(STRING(strInfo), "Intéraction avec %N", aim);
	menu.SetTitle(strInfo);
	Format(STRING(strInfo), "group|%i", aim);
	menu.AddItem(strInfo, "Groupe");
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}	

public int DoInvitationGroup(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select) 
	{
		char info[64], buffer[2][64];
		menu.GetItem(param, STRING(info));
		
		ExplodeString(info, "|", buffer, 2, 64);
		int joueur = StringToInt(buffer[1]);
		
		char membres[64], maxmembres[64];
		int id = rp_GetClientInt(client, i_Group);
		rp_GetGroupString(id, group_type_membres, STRING(membres));
		rp_GetGroupString(id, group_type_maxMembres, STRING(maxmembres));
		
		if(StrEqual(buffer[0], "group")) 
		{
			if(!StrEqual(membres, maxmembres))
			{
				char strText[64], strIndex[64];
				char groupename[64];
				rp_GetGroupString(id, group_type_name, STRING(groupename));
				
				Menu menu1 = new Menu(DoInvitationGroupSub1);
				menu1.SetTitle(groupename);
				
				Format(STRING(strText), "Inviter %N", joueur);
				Format(STRING(strIndex), "invitation|%i", joueur);
				if(rp_GetClientInt(joueur, i_Group) == 0)
					menu1.AddItem(strIndex, strText);
				else
					menu1.AddItem(strIndex, strText, ITEMDRAW_DISABLED);	
				
				Format(STRING(strText), "Virer %N", joueur);
				Format(STRING(strIndex), "virer|%i", joueur);			
				if(rp_GetClientInt(joueur, i_Group) == rp_GetClientInt(client, i_Group))
					menu1.AddItem(strIndex, strText);
				else
					menu1.AddItem(strIndex, strText, ITEMDRAW_DISABLED);	
				menu1.ExitButton = true;
				menu1.Display(client, MENU_TIME_FOREVER);
			}
			else
				rp_PrintToChat(client, "Vous avez atteint la limite des membres.");
		}
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit || param == MenuCancel_ExitBack)
			rp_SetClientBool(client, b_menuOpen, false);
	}
	else if(action == MenuAction_End)
		delete menu;
}

public int DoInvitationGroupSub1(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select) 
	{
		char info[64], buffer[2][64];
		menu.GetItem(param, STRING(info));
		
		ExplodeString(info, "|", buffer, 2, 64);
		int joueur = StringToInt(buffer[1]);
		
		if(StrEqual(buffer[0], "invitation")) 
		{
			char strText[64], strIndex[64];
			char groupename[64];
			int id = rp_GetClientInt(client, i_Group);
			rp_GetGroupString(id, group_type_name, STRING(groupename));
			
			rp_SetClientBool(joueur, b_menuOpen, true);
			Menu menu1 = new Menu(DoInvitationGroupFinal);
			Format(STRING(strText), "Invitation de %N", client);
			menu1.SetTitle(groupename);
			
			Format(STRING(strText), "Rejoindre %s", groupename);
			menu1.AddItem("", strText, ITEMDRAW_DISABLED);
			
			Format(STRING(strIndex), "accepter|%i", client);
			menu1.AddItem(strIndex, "Accepter");
			
			Format(STRING(strIndex), "refuser|%i", client);
			menu1.AddItem(strIndex, "Refuser");
				
			menu1.ExitButton = true;
			menu1.Display(joueur, MENU_TIME_FOREVER);
		}
		else if(StrEqual(buffer[0], "virer")) 
		{
			char groupename[64];
			int id = rp_GetClientInt(client, i_Group);
			rp_GetGroupString(id, group_type_name, STRING(groupename));
			
			rp_SetClientInt(joueur, i_Group, 0);
			rp_PrintToChat(client, "Vous avez viré %N", TEAM, joueur);
			SetSQL_Int(rp_GetDatabase(), "rp_clientgroupe", "groupeid", rp_GetClientInt(joueur, i_Group), steamID[joueur]);
			
			char membres_str[64];
			rp_GetGroupString(id, group_type_membres, STRING(membres_str));
			int membres = StringToInt(membres_str);
			membres--;
				
			Format(STRING(membres_str), "%i", membres);
			rp_SetGroupString(id, group_type_membres, STRING(membres_str));
				
			UpdateSQL(rp_GetDatabase(), "UPDATE `rp_groupes` SET `membres` = '%i' WHERE Id = '%i';", membres, id);
			
			if(IsClientValid(joueur))
				CPrintToChat(joueur, "%s %N vous a viré du gang %s", TEAM, client, groupename);
		}
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit || param == MenuCancel_ExitBack)
			rp_SetClientBool(client, b_menuOpen, false);
	}
	else if(action == MenuAction_End)
		delete menu;
}

public int DoInvitationGroupFinal(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select) 
	{
		char info[64], buffer[2][64];
		menu.GetItem(param, STRING(info));
		
		ExplodeString(info, "|", buffer, 2, 64);
		int joueur = StringToInt(buffer[1]);
		
		char groupename[64];
		int id = rp_GetClientInt(joueur, i_Group);
		rp_GetGroupString(id, group_type_name, STRING(groupename));
		
		if(StrEqual(buffer[0], "accepter")) 
		{
			rp_SetClientInt(client, i_Group, rp_GetClientInt(joueur, i_Group));
			UpdateSQL(rp_GetDatabase(), "UPDATE `rp_clientgroupe` SET `groupeid` = '%i' WHERE Id = '%i';", rp_GetClientInt(client, i_Group), steamID[client]);
			
			char membres_str[64];
			rp_GetGroupString(id, group_type_membres, STRING(membres_str));
			int membres = StringToInt(membres_str);
			membres++;
				
			Format(STRING(membres_str), "%i", membres);
			rp_SetGroupString(id, group_type_membres, STRING(membres_str));
				
			UpdateSQL(rp_GetDatabase(), "UPDATE `rp_groupes` SET `membres` = '%i' WHERE Id = '%i';", membres, id);
			
			rp_PrintToChat(client, "Vous avez accepter l'invitation de %N pour rejoindre %s.", TEAM, joueur, groupename);
			CPrintToChat(joueur, "%s %N a accepter votre invitation.", TEAM, client);
			rp_SetClientBool(client, b_menuOpen, false);
		}
		else if(StrEqual(buffer[0], "refuser")) 
		{
			rp_PrintToChat(client, "Vous avez refuser l'invitation de %N pour rejoindre %s.", TEAM, joueur, groupename);
			CPrintToChat(joueur, "%s %N a refuser votre invitation.", TEAM, client);
		}
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit || param == MenuCancel_ExitBack)
			rp_SetClientBool(client, b_menuOpen, false);
	}
	else if(action == MenuAction_End)
		delete menu;
}

Menu BuildGroupHistorique(int client)
{
	rp_SetClientBool(client, b_menuOpen, true);
	Menu menu = new Menu(ShowHistoryDonations);
	
	char groupe_name[64];
	rp_GetGroupString(client, group_type_name, STRING(groupe_name));
	menu.SetTitle("Historiques %s", groupe_name);
	
	char buffer[128], strIndex[16];
	Format(STRING(buffer), "SELECT * FROM rp_groupes_history WHERE Id = %i;", rp_GetClientInt(client, i_Group));
	DBResultSet query = SQL_Query(rp_GetDatabase(), buffer);			
	
	while(query.FetchRow())
	{
		char note[64];
		SQL_FetchStringByName(query, "note", STRING(note));
		menu.AddItem(strIndex, note, ITEMDRAW_DISABLED);
	}
	delete query;
	
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}	