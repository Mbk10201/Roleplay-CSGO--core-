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

char steamID[MAXPLAYERS + 1][32];
Database g_DB;
bool g_dataloaded[MAXPLAYERS];

int g_iStat_LastSave[MAXPLAYERS][i_uStat_nosavemax];
int_stat_data g_Sassoc[] = { // Fait le lien entre une stat et sa valeur sauvegardée
	i_nostat, // Pas une stat à save
	i_nostat,
	i_S_MoneyEarned_Pay,
	i_S_MoneyEarned_Phone,
	i_S_MoneyEarned_Mission,
	i_S_MoneyEarned_Sales,
	i_S_MoneyEarned_Pickup,
	i_S_MoneyEarned_CashMachine,
	i_S_MoneyEarned_Give,
	i_S_MoneySpent_Fines,
	i_S_MoneySpent_Shop,
	i_S_MoneySpent_Give,
	i_S_MoneySpent_Stolen,
	i_nostat,
	i_S_LotoSpent,
	i_S_LotoWon,
	i_S_DrugPickedUp,
	i_S_Kills,
	i_S_Deaths,
	i_S_ItemUsed,
	i_S_ItemUsedPrice,
	i_nostat,
	i_S_TotalBuild,
	i_S_RunDistance,
	i_S_JobSucess,
	i_S_JobFails,
	i_nostat,
	i_nostat,
};

/***************************************************************************************

							P L U G I N  -  I N F O

***************************************************************************************/
public Plugin myinfo = 
{
	name = "Roleplay - [MODULE]Stats", 
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
	Database.Connect(GotDatabase, "roleplay");
	RegConsoleCmd("rp_stats", Cmd_Stats);
	CreateTimer(120.0, saveStats, _, TIMER_REPEAT);
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
		"CREATE TABLE IF NOT EXISTS `rp_statdata` ( \
		  `Id` int(20) NOT NULL AUTO_INCREMENT, \
		  `steamid` varchar(32) COLLATE utf8_bin NOT NULL, \
		  `playername` varchar(64) COLLATE utf8_bin NOT NULL, \
		  `stat_id` int(10) NOT NULL, \
		  `data` int(100) NOT NULL, \
		  PRIMARY KEY (`Id`)\
		  )ENGINE = InnoDB DEFAULT CHARSET = utf8 COLLATE = utf8_bin;");
		g_DB.Query(SQL_CheckForErrors, buffer);
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
	g_dataloaded[client] = false;
	
	char playername[MAX_NAME_LENGTH + 8];
	GetClientName(client, STRING(playername));
	char clean_playername[MAX_NAME_LENGTH * 2 + 16];
	SQL_EscapeString(g_DB, playername, STRING(clean_playername));
	
	for(int i = 0; i < view_as<int>(i_uStat_max); i++)
	{
		rp_SetClientStat(client, view_as<int_stat_data>(i), 0);
		SQL_Request(g_DB, "INSERT INTO `rp_statdata` (`Id`, `steamid`, `playername`, `stat_id`, `data`) VALUES (NULL, '%s', '%s', '%i', '0');", steamID[client], clean_playername, i);
	}	
	
	char buffer[512];
	Format(STRING(buffer), "SELECT `stat_id`, `data` FROM `rp_statdata` WHERE `steamid` = '%s';", steamID[client]);
	g_DB.Query(CallBack, buffer, GetClientUserId(client));
}

public void CallBack(Database db, DBResultSet Results, const char[] error, any data) 
{	
	int client = GetClientOfUserId(data);
	while(Results.FetchRow())
	{
		 rp_SetClientStat(client, view_as<int_stat_data>(Results.FetchInt(0)), Results.FetchInt(1));
	}
	g_dataloaded[client] = true;
} 

public void OnClientDisconnect(int client) 
{	
	SaveClient(client);
}

/***************************************************************************************

									C A L L B A C K

***************************************************************************************/
public Action Cmd_Stats(int client, int args)
{
	#if DEBUG
		PrintToServer("Command: Stats");
	#endif
	
	if(client == 0)
	{
		PrintToServer("%T", "NoAccessCommand", LANG_SERVER);
		return Plugin_Handled;
	}
	
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(MenuStats_Handle);
	menu.SetTitle("Quelles stats afficher ?\n ");
	menu.AddItem("sess", "Sur la connexion");
	menu.AddItem("full", "Le total");
	menu.AddItem("real", "En temps réel");
	menu.AddItem("coloc", "Infos appartement");
	menu.AddItem("level", "Mon niveau");
	menu.AddItem("succes", "Mes succès");
	
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
	
	return Plugin_Handled;	
}	

public int MenuStats_Handle(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[64];
		menu.GetItem(param, STRING(info));
		
		if(StrEqual(info, "full"))
			DisplayStats(client, true);
		else if(StrEqual(info, "sess"))
			DisplayStats(client, false);
		else if(StrEqual(info, "coloc"))
			DisplayAppartment(client);
		else if(StrEqual(info, "succes"))
			FakeClientCommand(client, "say /succes");
		else if(StrEqual(info, "real"))
			DisplayRTStats(client);
		//else if(StrEqual(info, "level"))
			//DisplayLevelStats(client);
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

void DisplayAppartment(int client)
{
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_MenuStats);
	menu.SetTitle("Vos stats appartement\n ");
	
	char tmp[64];
	if(rp_GetClientInt(client, i_Appart) != -1)
	{
		Format(STRING(tmp), "№ %i", rp_GetClientInt(client, i_Appart));
		menu.AddItem("", tmp, ITEMDRAW_DISABLED);	
		
		//Format(STRING(tmp), "Colocataire: %N", (rp_GetClientInt(client, i_Coloc) != -1 ? rp_GetClientInt(client, i_Coloc) : "Aucun"));
		//menu.AddItem("", tmp, ITEMDRAW_DISABLED);	
	}
	else
		menu.AddItem("", "Vous n'avez pas d'appartement.", ITEMDRAW_DISABLED);	
	
	menu.ExitBackButton = true;
	menu.ExitButton = true;
	menu.Display(client, 60);
}	

public int Handle_MenuStats(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if(param == MenuCancel_ExitBack)	
			FakeClientCommand(client, "say /rp_stats");
	}
	else if(action == MenuAction_End)
		delete menu;
		
	return 0;
}

public void DisplayStats(int client, bool full)
{
	if(!g_dataloaded[client])
		return;
	UpdateStats(client);
	char tmp[128];
	
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_MenuStats);
	if(full)
	{
		menu.SetTitle("Vos stats totales\n ");
		
		Format(STRING(tmp), "Argent gagné par la paye: %d", rp_GetClientStat(client, i_MoneyEarned_Pay));
		menu.AddItem("", tmp, ITEMDRAW_DISABLED);
		
		Format(STRING(tmp), "Argent gagné par les missions téléphones: %d", rp_GetClientStat(client, i_MoneyEarned_Phone));
		menu.AddItem("", tmp, ITEMDRAW_DISABLED);
		
		Format(STRING(tmp), "Argent gagné via metier: %d", rp_GetClientStat(client, i_MoneyEarned_Sales));
		menu.AddItem("", tmp, ITEMDRAW_DISABLED);
		
		Format(STRING(tmp), "Argent ramassé: %d", rp_GetClientStat(client, i_MoneyEarned_Pickup));
		menu.AddItem("", tmp, ITEMDRAW_DISABLED);
		
		Format(STRING(tmp), "Argent gagné par les machines: %d", rp_GetClientStat(client, i_MoneyEarned_CashMachine));
		menu.AddItem("", tmp, ITEMDRAW_DISABLED);
		
		Format(STRING(tmp), "Argent reçu: %d", rp_GetClientStat(client, i_MoneyEarned_Give));
		menu.AddItem("", tmp, ITEMDRAW_DISABLED);

		menu.AddItem("", "------------------------------------------", ITEMDRAW_DISABLED);

		Format(STRING(tmp), "Argent perdu en amendes: %d", rp_GetClientStat(client, i_MoneySpent_Fines));
		menu.AddItem("", tmp, ITEMDRAW_DISABLED);
		
		Format(STRING(tmp), "Argent perdu en achetant: %d", rp_GetClientStat(client, i_MoneySpent_Shop));
		menu.AddItem("", tmp, ITEMDRAW_DISABLED);
		
		Format(STRING(tmp), "Argent donné: %d", rp_GetClientStat(client, i_MoneySpent_Give));
		menu.AddItem("", tmp, ITEMDRAW_DISABLED);
		
		Format(STRING(tmp), "Argent perdu par Vol: %d", rp_GetClientStat(client, i_MoneySpent_Stolen));
		menu.AddItem("", tmp, ITEMDRAW_DISABLED);

		menu.AddItem("", "------------------------------------------", ITEMDRAW_DISABLED);

		Format(STRING(tmp), "Nombre d'items utilisés: %d", rp_GetClientStat(client, i_S_ItemUsed));
		menu.AddItem("", tmp, ITEMDRAW_DISABLED);
		
		Format(STRING(tmp), "Prix des items utilisés: %d", rp_GetClientStat(client, i_S_ItemUsedPrice));
		menu.AddItem("", tmp, ITEMDRAW_DISABLED);
		
		Format(STRING(tmp), "Argent perdu au loto: %d", rp_GetClientStat(client, i_S_LotoSpent));
		menu.AddItem("", tmp, ITEMDRAW_DISABLED);
		
		Format(STRING(tmp), "Argent gagné au loto: %d", rp_GetClientStat(client, i_S_LotoWon));
		menu.AddItem("", tmp, ITEMDRAW_DISABLED);
		
		Format(STRING(tmp), "Nombre de build: %d", rp_GetClientStat(client, i_S_TotalBuild));
		menu.AddItem("", tmp, ITEMDRAW_DISABLED);
		
		Format(STRING(tmp), "Distance courue: %dm", rp_GetClientStat(client, i_S_RunDistance));
		menu.AddItem("", tmp, ITEMDRAW_DISABLED);
		
		Format(STRING(tmp), "Actions de job réussies: %d", rp_GetClientStat(client, i_S_JobSucess));
		menu.AddItem("", tmp, ITEMDRAW_DISABLED);
		
		Format(STRING(tmp), "Actions de job ratées: %d", rp_GetClientStat(client, i_S_JobFails));
		menu.AddItem("", tmp, ITEMDRAW_DISABLED);
	}
	else
	{
		menu.SetTitle("Vos stats sur la connection\n ");
		
		if(( rp_GetClientInt(client, i_Money) + rp_GetClientInt(client, i_Bank) )-rp_GetClientStat(client, i_Money_OnConnection) > 0)
			Format(STRING(tmp), "Evolution de l'argent: +%d", ( rp_GetClientInt(client, i_Money) + rp_GetClientInt(client, i_Bank) )-rp_GetClientStat(client, i_Money_OnConnection));
		else
			Format(STRING(tmp), "Evolution de l'argent: %d", ( rp_GetClientInt(client, i_Money) + rp_GetClientInt(client, i_Bank) )-rp_GetClientStat(client, i_Money_OnConnection));
		menu.AddItem("", tmp, ITEMDRAW_DISABLED);
		
		Format(STRING(tmp), "Kills: %d", rp_GetClientStat(client, i_Kills));
		menu.AddItem("", tmp, ITEMDRAW_DISABLED);
		
		Format(STRING(tmp), "Morts: %d", rp_GetClientStat(client, i_Deaths));
		menu.AddItem("", tmp, ITEMDRAW_DISABLED);		
		
		Format(STRING(tmp), "Dernier Kill: %d Minutes", GetTime() - rp_GetClientStat(client, i_LastKillTimestamp) / 60.0);
		if(rp_GetClientStat(client, i_LastKillTimestamp) != 0)
			menu.AddItem("", tmp, ITEMDRAW_DISABLED);
		
		Format(STRING(tmp), "Dernière Mort: %d Minutes", GetTime() - rp_GetClientStat(client, i_LastDeathTimestamp) / 60.0);
		if(rp_GetClientStat(client, i_LastDeathTimestamp) != 0)
			menu.AddItem("", tmp, ITEMDRAW_DISABLED);
		Format(STRING(tmp), "Argent gagné par la paye: %d", rp_GetClientStat(client, i_MoneyEarned_Pay));
		menu.AddItem("", tmp, ITEMDRAW_DISABLED);
		
		Format(STRING(tmp), "Argent gagné par les missions téléphones: %d", rp_GetClientStat(client, i_MoneyEarned_Phone));
		menu.AddItem("", tmp, ITEMDRAW_DISABLED);
		
		Format(STRING(tmp), "Argent gagné via metier: %d", rp_GetClientStat(client, i_MoneyEarned_Sales));
		menu.AddItem("", tmp, ITEMDRAW_DISABLED);
		
		Format(STRING(tmp), "Argent ramassé: %d", rp_GetClientStat(client, i_MoneyEarned_Pickup));
		menu.AddItem("", tmp, ITEMDRAW_DISABLED);
		
		Format(STRING(tmp), "Argent gagné par les machines: %d", rp_GetClientStat(client, i_MoneyEarned_CashMachine));
		menu.AddItem("", tmp, ITEMDRAW_DISABLED);
		
		Format(STRING(tmp), "Argent reçu: %d", rp_GetClientStat(client, i_MoneyEarned_Give));
		menu.AddItem("", tmp, ITEMDRAW_DISABLED);

		menu.AddItem("", "------------------------------------------", ITEMDRAW_DISABLED);

		Format(STRING(tmp), "Argent perdu en amendes: %d", rp_GetClientStat(client, i_MoneySpent_Fines));
		menu.AddItem("", tmp, ITEMDRAW_DISABLED);
		
		Format(STRING(tmp), "Argent perdu en achetant: %d", rp_GetClientStat(client, i_MoneySpent_Shop));
		menu.AddItem("", tmp, ITEMDRAW_DISABLED);
		
		Format(STRING(tmp), "Argent donné: %d", rp_GetClientStat(client, i_MoneySpent_Give));
		menu.AddItem("", tmp, ITEMDRAW_DISABLED);
		
		Format(STRING(tmp), "Argent perdu par Vol: %d", rp_GetClientStat(client, i_MoneySpent_Stolen));
		menu.AddItem("", tmp, ITEMDRAW_DISABLED);

		menu.AddItem("", "------------------------------------------", ITEMDRAW_DISABLED);

		if(RoundToNearest(rp_GetClientFloat(client, fl_Vitality))-rp_GetClientStat(client, i_Vitality_OnConnection) > 0)
			Format(STRING(tmp), "Evolution de la vitalité: +%d", RoundToNearest(rp_GetClientFloat(client, fl_Vitality))-rp_GetClientStat(client, i_Vitality_OnConnection));
		else
			Format(STRING(tmp), "Evolution de la vitalité: %d", RoundToNearest(rp_GetClientFloat(client, fl_Vitality))-rp_GetClientStat(client, i_Vitality_OnConnection));
		menu.AddItem("", tmp, ITEMDRAW_DISABLED);
		
		Format(STRING(tmp), "Nombre d'items utilisés: %d", rp_GetClientStat(client, i_ItemUsed));
		menu.AddItem("", tmp, ITEMDRAW_DISABLED);
		
		Format(STRING(tmp), "Prix des items utilisés: %d", rp_GetClientStat(client, i_ItemUsedPrice));
		menu.AddItem("", tmp, ITEMDRAW_DISABLED);
		
		Format(STRING(tmp), "Argent perdu au loto: %d", rp_GetClientStat(client, i_LotoSpent));
		menu.AddItem("", tmp, ITEMDRAW_DISABLED);
		
		Format(STRING(tmp), "Argent gagné au loto: %d", rp_GetClientStat(client, i_LotoWon));
		menu.AddItem("", tmp, ITEMDRAW_DISABLED);
		
		menu.AddItem("", tmp, ITEMDRAW_DISABLED);
		
		Format(STRING(tmp), "Nombre de build: %d", rp_GetClientStat(client, i_TotalBuild));
		menu.AddItem("", tmp, ITEMDRAW_DISABLED);
		
		Format(STRING(tmp), "Distance courue: %dm", rp_GetClientStat(client, i_RunDistance));
		menu.AddItem("", tmp, ITEMDRAW_DISABLED);
		
		Format(STRING(tmp), "Actions de job réussies: %d", rp_GetClientStat(client, i_JobSucess));
		menu.AddItem("", tmp, ITEMDRAW_DISABLED);
		
		Format(STRING(tmp), "Actions de job ratées: %d", rp_GetClientStat(client, i_JobFails));
		menu.AddItem("", tmp, ITEMDRAW_DISABLED);
	}

	menu.ExitBackButton = true;
	menu.ExitButton = true;
	menu.Display(client, 60);
}

public void DisplayRTStats(int client)
{
	if(!g_dataloaded[client])
		return;
	
	char tmp[128];
	
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_MenuStats);
	menu.SetTitle("Vos stats en temps réel\n ");
	
	Format(STRING(tmp), "Nombre de machines: %i", rp_GetClientInt(client, i_Machine));
	menu.AddItem("", tmp, ITEMDRAW_DISABLED);
	
	Format(STRING(tmp), "Nombre de plants: %i", rp_GetClientInt(client, i_Plante));
	menu.AddItem("", tmp, ITEMDRAW_DISABLED);
	
	Format(STRING(tmp), "Levels cuts: %i", rp_GetClientInt(client, i_KnifeLevel));
	menu.AddItem("", tmp, ITEMDRAW_DISABLED);
	
	Format(STRING(tmp), "Lancée de couteaux: %i", rp_GetClientInt(client, i_KnifeThrow));
	menu.AddItem("", tmp, ITEMDRAW_DISABLED);
	
	//Format(STRING(tmp), "Précision de tir: %.2f", rp_GetClientFloat(client, fl_WeaponTrain)); TODO
	//menu.AddItem("", tmp, ITEMDRAW_DISABLED);
	/*if(rp_GetClientInt(client, i_Job) != 0)
	{	
		Format(STRING(tmp), "Dans le job depuis: %.2f heures ",  float(rp_GetClientPlaytimeJob(client, rp_GetClientJobID(client), true))/3600.0);
		menu.AddItem("", tmp, ITEMDRAW_DISABLED);
		Format(STRING(tmp), "Au même grade depuis: %.2f heures", float(rp_GetClientPlaytimeJob(client, rp_GetClientInt(client, i_Job), false))/3600.0);
		menu.AddItem("", tmp, ITEMDRAW_DISABLED);
	}*/
	
	int wep_id = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(rp_canSetAmmo(client, wep_id)) 
	{
		menu.AddItem("", "------ Votre Arme ------", ITEMDRAW_DISABLED);
		Format(STRING(tmp), "Nombre de balles: %d", Weapon_GetPrimaryClip(wep_id));
		menu.AddItem("", tmp, ITEMDRAW_DISABLED);
	}

	menu.ExitBackButton = true;
	menu.ExitButton = true;
	menu.Display(client, 60);
}

/*public void DisplayLevelStats(int client)
{
	char tmp[512];
	Menu menu = new Menu(HandleNothing);
	
	int level = rp_GetClientInt(client, i_PlayerLVL);

	Format(STRING(tmp), "Vous êtes niveau %d, prochain niveau: %d/3600 \nListe des bonus:\n ", rp_GetClientInt(client, i_PlayerLVL), rp_GetClientInt(client, i_PlayerXP)%3600);
	
	rp_SetClientBool(client, b_DisplayHud, false);
	SetMenuTitle(menu, tmp);
	for(int i=0; i<sizeof(g_szLevelData); i++){
		if(strlen(g_szLevelData[i][0]) == 0)
			break;
		Format(STRING(tmp), "Au niveau %s: %s - %s", g_szLevelData[i][0], g_szLevelData[i][1], g_szLevelData[i][2]);
		
		String_WordWrap(tmp, 60);
		menu.AddItem("", tmp, level >= StringToInt(g_szLevelData[i][0]) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	}
	SetMenuPagination(menu, 3);
	
	menu.ExitBackButton = true;
	menu.ExitButton = true;
	menu.Display(client, 60);
}*/

public void UpdateStats(int client)
{
	if(!g_dataloaded[client])
		return;

	for(int j=1; j < view_as<int>(i_uStat_nosavemax);j++)
	{
		if(g_Sassoc[j] == i_nostat)
			continue;
		if(g_iStat_LastSave[client][j] == rp_GetClientStat(client, view_as<int_stat_data>(j)))
			continue;
		rp_SetClientStat(client, g_Sassoc[j], (rp_GetClientStat(client, g_Sassoc[j]) + (rp_GetClientStat(client, view_as<int_stat_data>(j)) - g_iStat_LastSave[client][j]) ) );
		g_iStat_LastSave[client][j] = rp_GetClientStat(client, view_as<int_stat_data>(j));
	}
}

public Action saveStats(Handle timer)
{
	LoopClients(i)
	{
		if(!IsClientValid(i))
			continue;
		if(!g_dataloaded[i])
			continue;
		UpdateStats(i);
		SaveClient(i);
	}
	
	return Plugin_Handled;
}

public void SaveClient(int client)
{
	UpdateStats(client);
	
	char sCQuery[6048];
	for(int j = view_as<int>(i_S_MoneyEarned_Pay); j < view_as<int>(i_uStat_max); j++)
	{
		Format(sCQuery, sizeof(sCQuery), "UPDATE `rp_statdata` SET `data` = '%i' WHERE `stat_id`='%i' AND `steamid`='%s';", rp_GetClientStat(client, view_as<int_stat_data>(j)), j, steamID[client]);
	}
	
	sCQuery[strlen(sCQuery)-1] = 0;
	//SQL_Request(g_DB, sCQuery);
}