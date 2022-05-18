/*
*   Roleplay CS:GO de Benito est mis à disposition selon les termes de la licence Creative Commons Attribution .
* - Pas d’Utilisation Commerciale 
* - Partage dans les Mêmes Conditions 4.0 International.
*
*   Merci de respecter le travail fourni par le ou les auteurs 
*   https://enemy-down.eu - benitalpa1020@gmail.com
*/

/*
	TODO
	
	1. Régler rp_savejob FIX
*/

/***************************************************************************************

							P L U G I N  -  D E F I N E S

***************************************************************************************/
#pragma semicolon 1
#pragma newdecls required

/***************************************************************************************

										H E A D E R

***************************************************************************************/
#include <roleplay_csgo.inc>

// Methodmap Constructor
Roleplay m_iClient[MAXPLAYERS + 1];

Database 
	g_DB;
Handle 
	g_hTimerReboot = null;
float 
	g_fTimerRebootCount = 0.0;
	
enum struct ClientData {
	char SteamID[32];
	bool HasBeenDebanned;
	bool CanEditTag;
}
ClientData iData[MAXPLAYERS + 1];

enum struct Data_Forward {
	GlobalForward OnJob;
	GlobalForward OnReboot;
	GlobalForward OnAdminMenu;
	GlobalForward OnHandleAdminMenu;
}	
Data_Forward Forward;

/***************************************************************************************

							P L U G I N  -  I N F O

***************************************************************************************/
public Plugin myinfo = 
{
	name = "Roleplay - Admin", 
	author = "MBK", 
	description = "Admin management", 
	version = "1.0", 
	url = "https://github.com/Mbk10201"
};

/***************************************************************************************

									 F U N C T I O N S

***************************************************************************************/

public void OnPluginStart()
{
	// Load global & local translations file
	LoadTranslation();
	LoadTranslations("rp_admin.phrases");
	// Print to server console the plugin status
	PrintToServer("[REQUIREMENT] ADMIN ✓");	
	
	/*------------------------------------FORWADS------------------------------------*/
	
	/*-------------------------------------------------------------------------------*/
	
	/*----------------------------------Commands-------------------------------*/
	// Register all local plugin commands available in game
	RegConsoleCmd("rp_admin", Command_Admin);
	RegConsoleCmd("rp_mute", Command_Mute);	
	RegConsoleCmd("rp_noclip", Command_Noclip);
	RegConsoleCmd("rp_getpos", Command_GetPos);
	RegConsoleCmd("rp_info", Command_Info);
	RegConsoleCmd("rp_tpa", Command_TPA);
	RegConsoleCmd("rp_tp", Command_TP);
	RegConsoleCmd("rp_reboot", Command_Reboot);
	RegConsoleCmd("rp_kick", Command_Kick);
	RegConsoleCmd("rp_ban", Command_Ban);
	RegConsoleCmd("rp_slay", Command_Slay);
	RegConsoleCmd("rp_freeze", Command_Freeze);
	RegConsoleCmd("rp_skin", Command_Skin);
	RegConsoleCmd("rp_del", Command_Remove);
	RegConsoleCmd("rp_delworld", Command_RemoveFromWorld);
	RegConsoleCmd("rp_spawn", Command_SpawnProps);
	RegConsoleCmd("rp_giveitem", Command_GiveItem);
	RegConsoleCmd("rp_setname", Command_SetName);
	RegConsoleCmd("rp_aduty", Command_Aduty);
	/*-------------------------------------------------------------------------------*/
	
	RegServerCmd("rp_setadmin", Console_SetAdmin);
	
	/*----------------------------------Tools-------------------------------*/
	RegConsoleCmd("rp_saveoutlocation", Command_SaveOutLocation);
	RegConsoleCmd("rp_savespawnlocation", Command_SaveSpawnLocation);
	RegConsoleCmd("rp_setlocationprice", Command_SetLocationPrice);
	RegConsoleCmd("rp_savebox", Command_SaveBox);
	RegConsoleCmd("rp_saveout", Command_SaveOut);
	RegConsoleCmd("rp_savespawn", Command_SaveSpawn);
	RegConsoleCmd("rp_savetesla", Command_SaveTesla);
	/*-------------------------------------------------------------------------------*/
}

public void RP_OnSQLInit(Database db, Transaction transaction)
{
	g_DB = db;
	
	char sBuffer[MAX_BUFFER_LENGTH + 1];
	
	Format(STRING(sBuffer), "CREATE TABLE IF NOT EXISTS `rp_admin` ( \
	  `playerid` int(20) NOT NULL, \
	  `level` int(4) NOT NULL DEFAULT '0', \
	  `tag` varchar(64) NOT NULL, \
	  PRIMARY KEY (`playerid`), \
	  UNIQUE KEY `playerid` (`playerid`), \
	  FOREIGN KEY (`playerid`) REFERENCES `rp_players` (`id`) ON DELETE CASCADE ON UPDATE CASCADE \
	  )ENGINE = InnoDB DEFAULT CHARSET = utf8 COLLATE = utf8_bin;");
	#if DEBUG
		PrintToServer(sBuffer);
	#endif
	transaction.AddQuery(sBuffer);
	
	Format(STRING(sBuffer), "CREATE TABLE IF NOT EXISTS `rp_bans` ( \
	  `playerid` int(20) NOT NULL, \
	  `adminid` int(20) NOT NULL, \
	  `ip` varchar(64) NOT NULL, \
	  `time` int(11) NOT NULL, \
	  `raison` varchar(128) NOT NULL, \
	  PRIMARY KEY (`playerid`), \
	  FOREIGN KEY (`playerid`) REFERENCES `rp_players` (`id`) ON DELETE CASCADE ON UPDATE CASCADE, \
	  FOREIGN KEY (`adminid`) REFERENCES `rp_players` (`id`) ON DELETE CASCADE ON UPDATE CASCADE \
	  )ENGINE = InnoDB DEFAULT CHARSET = utf8 COLLATE = utf8_bin;");
	#if DEBUG
		PrintToServer(sBuffer);
	#endif
	transaction.AddQuery(sBuffer);
}

public APLRes AskPluginLoad2(Handle plugin, bool late, char[] error, int err_max)
{
	RegPluginLibrary("rp_admin");
	
	/*------------------------------------FORWADS------------------------------------*/
	Forward.OnJob = new GlobalForward("RP_OnClientGetJob", ET_Event, Param_Cell, Param_Cell, Param_String, Param_String);	
	Forward.OnReboot = new GlobalForward("RP_OnReboot", ET_Event);	
	Forward.OnAdminMenu = new GlobalForward("RP_OnAdmin", ET_Event, Param_Cell, Param_Cell);
	Forward.OnHandleAdminMenu = new GlobalForward("RP_OnAdminHandle", ET_Event, Param_Cell, Param_String);
	/*-------------------------------------------------------------------------------*/
	
	return APLRes_Success;
}	

public void OnMapEnd()
{
	if(g_hTimerReboot != null)
		TrashTimer(g_hTimerReboot, true);
}	
/***************************************************************************************

									C A L L B A C K

***************************************************************************************/

public void SQL_LOAD(int client) 
{
	/*if (!IsClientValid(client))
		return;*/
		
	bool next;
	char query[1024], IP_Target[64];
	GetClientIP(client, STRING(IP_Target));
	
	//Http_CheckIp(IP_Target, client); // FIX
	
	Format(STRING(query), "SELECT * FROM `rp_bans` WHERE `playerid` = '%i' OR `ip` = '%s'", rp_GetSQLID(client), IP_Target);	 
	DBResultSet Results = SQL_Query(g_DB, query);
	if(Results.FetchRow())
	{
		int time;
		Results.FetchIntByName("time", time);
		
		if(time != 0)
		{
			if(GetTime() > time)
			{
				SQL_Request(g_DB, "DELETE FROM `rp_bans` WHERE `playerid` = '%i'", rp_GetSQLID(client));
				iData[client].HasBeenDebanned = true;
				next = true;
			}
		}	
		
		if(!next)
		{
			char raison[128], kickRaison[256], timestamp[32];
			Results.FetchStringByName("raison", STRING(raison));
				
			int iYear, iMonth, iDay, iHour, iMinute, iSecond;
			UnixToTime(time, iYear, iMonth, iDay, iHour, iMinute, iSecond, UT_TIMEZONE_CEST);	
			Format(STRING(timestamp), "%02d/%02d/%d %02d:%02d:%02d", iDay, iMonth, iYear, iHour, iMinute, iSecond);	
			
				
			if(time != 0)
				Format(STRING(kickRaison), "%T", "UserBanned_Timestamp", LANG_SERVER, timestamp, raison);
			else
				Format(STRING(kickRaison), "%T", "UserBanned_Permanent", LANG_SERVER, timestamp, raison);
			KickClientEx(client, kickRaison);
		}	
	}			
	delete Results;
			
	char sQuery[MAX_BUFFER_LENGTH + 1];
	Format(STRING(sQuery), "SELECT * FROM `rp_admin` WHERE `playerid` = '%i'", rp_GetSQLID(client));
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
		int value = 0;
		Results.FetchIntByName("level", value);
		rp_SetAdmin(client, view_as<admin_type>(value));
		
		char tag[64];
		Results.FetchStringByName("tag", STRING(tag));
		rp_SetClientString(client, sz_AdminTag, STRING(tag));
	}
	else
		rp_SetAdmin(client, ADMIN_FLAG_NONE);
}

public Action Console_SetAdmin(int args)
{
	char arg[256];
	GetCmdArg(1, STRING(arg));
	
	char arg2[8];
	GetCmdArg(2, STRING(arg2));

	int target = FindTarget(0, arg, true);
	if (target <= COMMAND_TARGET_NONE)
	{
		ReplyToTargetError(0, target);
		return Plugin_Handled;
	}

	if(IsClientValid(target))
	{
		rp_SetAdmin(target, view_as<admin_type>(StringToInt(arg2)));
	}	
	
	return Plugin_Handled;
}

public Action Command_Admin(int client, int args)
{
	#if DEBUG
		Translation_DebugCommand(client);
	#endif
	
	if(client == 0)
	{
		Translation_PrintNoAvailable();
		return Plugin_Handled;
	}
	
	if(rp_GetAdmin(client) == ADMIN_FLAG_NONE)
	{
		Translation_PrintNoAccess(client);
		return Plugin_Handled;
	}
	
	if(IsClientValid(client))
		Menu_Admin(client);

	return Plugin_Handled;
}	

void Menu_Admin(int client)
{
	rp_SetClientBool(client, b_DisplayHud, false);
	
	Menu menu = new Menu(Handle_MenuAdmin);
	menu.SetTitle("%T", "MenuAdmin_Title", LANG_SERVER);
	
	char translation[64];
	if(rp_GetAdmin(client) >= ADMIN_FLAG_OWNER && rp_GetAdmin(client) <= ADMIN_FLAG_ADMIN)
	{
		Format(STRING(translation), "%T", "MenuAdmin_JobMenu", LANG_SERVER);
		menu.AddItem("job", translation);
	}	
	
	Format(STRING(translation), "%T", "MenuAdmin_Noclip", LANG_SERVER);
	menu.AddItem("noclip", translation);
	
	Format(STRING(translation), "%T", "MenuAdmin_Kick", LANG_SERVER);
	menu.AddItem("kick", translation);	
	
	Format(STRING(translation), "%T", "MenuAdmin_Ban", LANG_SERVER);
	menu.AddItem("ban", translation);
	
	Format(STRING(translation), "%T", "MenuAdmin_Mute", LANG_SERVER);
	menu.AddItem("mute", translation);
	
	Format(STRING(translation), "%T", "MenuAdmin_Teleport", LANG_SERVER);
	menu.AddItem("tp", translation);
	
	Format(STRING(translation), "%T", "MenuAdmin_Freeze", LANG_SERVER);
	menu.AddItem("freeze", translation);
	
	Format(STRING(translation), "%T", "MenuAdmin_Reboot", LANG_SERVER);
	menu.AddItem("reboot", translation);
	
	Format(STRING(translation), "%T", "MenuAdmin_Vip", LANG_SERVER);
	menu.AddItem("vip", translation);
	
	Format(STRING(translation), "%T", "MenuAdmin_Admin", LANG_SERVER);
	menu.AddItem("admin", translation);
	
	Format(STRING(translation), "%T", "MenuAdmin_Tag", LANG_SERVER);
	menu.AddItem("tag", translation);
	
	Format(STRING(translation), "%T", "MenuAdmin_Props", LANG_SERVER);
	menu.AddItem("props", translation);
	
	Call_StartForward(Forward.OnAdminMenu);
	Call_PushCell(menu);
	Call_PushCell(client);
	Call_Finish();	

	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Handle_MenuAdmin(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[64];
		menu.GetItem(param, STRING(info));
		
		if(StrEqual(info, "job"))
			Menu_Job(client);
		else if(StrEqual(info, "noclip"))
			Menu_Noclip(client);
		else if(StrEqual(info, "kick"))
			Menu_Kick(client);		
		else if(StrEqual(info, "ban"))
			Menu_Ban(client);		
		else if(StrEqual(info, "tp"))
			Menu_Teleport(client);			
		else if(StrEqual(info, "freeze"))
			Menu_Freeze(client);	
		else if(StrEqual(info, "reboot"))
			Menu_Reboot(client);	
		else if(StrEqual(info, "vip"))
			Menu_Vip(client);	
		else if(StrEqual(info, "admin"))
			Menu_MiscAdmin(client);		
		else if(StrEqual(info, "tag"))
			Menu_Tag(client);		
		else if(StrEqual(info, "props"))
			Menu_Props(client);
		else if(StrEqual(info, "mute"))
			Menu_Mute(client);
			
		Call_StartForward(Forward.OnHandleAdminMenu);
		Call_PushCell(client);
		Call_PushString(info);
		Call_Finish();	
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

void Menu_Noclip(int client)
{
	rp_SetClientBool(client, b_DisplayHud, false);
	
	Menu menu = new Menu(Handle_MenuNoclip);
	menu.SetTitle("=== ADMIN === -> NOCLIP");
	
	char name[32], strIndex[8], actualmov[32];
	actualmov = "";
	LoopClients(i)
	{
		if(!IsClientValid(i))
			continue;
			
		if(GetEntityMoveType(i) != MOVETYPE_NOCLIP)	
			actualmov = "[✘]";
		else
			actualmov = "[✓]";		
		
		GetClientName(i, STRING(name));
		Format(STRING(name), "%s %s", name, actualmov);
		Format(STRING(strIndex), "%i", i);
		menu.AddItem(strIndex, name);
	}
	
	menu.ExitBackButton = true;
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Handle_MenuNoclip(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[64];
		menu.GetItem(param, STRING(info));
		int joueur = StringToInt(info);		
		
		char name[64];
		Format(STRING(name), "%N", joueur);
		
		ServerCommand("rp_noclip %s", name);
		
		Menu_Noclip(client);
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if(param == MenuCancel_ExitBack)
			FakeClientCommand(client, "say !rp_admin");
	}
	else if(action == MenuAction_End)
		delete menu;
		
	return 0;
}

void Menu_Tag(int client)
{
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_MenuTag);
	menu.SetTitle("=== ADMIN === -> TAG");
	
	char actual_tag[64];
	rp_GetClientString(client, sz_AdminTag, STRING(actual_tag));
	Format(STRING(actual_tag), "Tag actuel: %s", actual_tag);
	menu.AddItem("", actual_tag, ITEMDRAW_DISABLED);
	
	menu.AddItem("edit", "Modifier");
	
	menu.ExitBackButton = true;
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Handle_MenuTag(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[32];
		menu.GetItem(param, STRING(info));
		
		if(StrEqual(info, "edit"))
		{
			iData[client].CanEditTag = true;
			rp_PrintToChat(client, "Notez dans le tchat un tag.");
		}	
		
		rp_SetClientBool(client, b_DisplayHud, false);
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if(param == MenuCancel_ExitBack)
			FakeClientCommand(client, "say !rp_admin");
	}
	else if(action == MenuAction_End)
		delete menu;
		
	return 0;
}

public void RP_OnClientSay(int client, const char[] arg)
{
	if(iData[client].CanEditTag)
	{
		iData[client].CanEditTag = false;
		
		if(strlen(arg) > 60)
		{
			rp_PrintToChat(client, "Vous êtes limité à {green}64 {default}Charactères pour un tag.");
			return;
		}
		
		rp_PrintToChat(client, "Tag {green}%s {default}appliqué.", arg);
		
		char newtag[64];
		Format(STRING(newtag), "%s", arg);
		rp_SetClientString(client, sz_AdminTag, STRING(newtag));
		
		SQL_Request(g_DB, "UPDATE `rp_admin` SET `tag` = '%s' WHERE `steamid` = '%s';", arg, iData[client].SteamID);
		Menu_Tag(client);
	}
}

void Menu_MiscAdmin(int client)
{
	rp_SetClientBool(client, b_DisplayHud, false);
	
	Menu menu = new Menu(Handle_MenuMiscAdmin);
	menu.SetTitle("=== ADMIN === -> GESTION");
	
	char name[128], strIndex[8], actual[32];
	LoopClients(i)
	{
		if(!IsClientValid(i))
			continue;
			
		switch(rp_GetAdmin(i))
		{
			case ADMIN_FLAG_OWNER:actual = "Super-Admin";
			case ADMIN_FLAG_ADMIN:actual = "Admin";
			case ADMIN_FLAG_MODERATOR:actual = "Modérateur";
			case ADMIN_FLAG_NONE:actual = "";
		}		
		
		GetClientName(i, STRING(name));
		Format(STRING(name), "%s [%s]", name, actual);
		Format(STRING(strIndex), "%i", i);
		menu.AddItem(strIndex, name);
	}
	
	menu.ExitBackButton = true;
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Handle_MenuMiscAdmin(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[64], strIndex[64];
		menu.GetItem(param, STRING(info));
		rp_SetClientBool(client, b_DisplayHud, false);
	
		Menu menu1 = new Menu(Handle_MenuMiscAdminFinal);
		menu1.SetTitle("=== GESTION === -> PROMOUVOIR");
		
		Format(STRING(strIndex), "%s|0", info);
		menu1.AddItem(strIndex, "Aucun");
		
		Format(STRING(strIndex), "%s|1", info);
		menu1.AddItem(strIndex, "Superadmin");
		
		Format(STRING(strIndex), "%s|2", info);
		menu1.AddItem(strIndex, "Admin");
		
		Format(STRING(strIndex), "%s|3", info);
		menu1.AddItem(strIndex, "Modérateur");
		
		menu1.ExitBackButton = true;
		menu1.ExitButton = true;
		menu1.Display(client, MENU_TIME_FOREVER);
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if(param == MenuCancel_ExitBack)
			FakeClientCommand(client, "say !rp_admin");
	}
	else if(action == MenuAction_End)
		delete menu;
		
	return 0;
}

public int Handle_MenuMiscAdminFinal(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[64], buffer[2][64], actual[64];
		menu.GetItem(param, STRING(info));
		ExplodeString(info, "|", buffer, 2, 64);
		int target = StringToInt(buffer[0]);
		int id = StringToInt(buffer[1]);
		
		rp_SetAdmin(target, view_as<admin_type>(id));
		
		switch(id)
		{
			case 0:actual = "Aucun";
			case 1:actual = "Super-Admin";
			case 2:actual = "Admin";
			case 3:actual = "Modérateur";
		}	
		
		rp_PrintToChat(client, "Vous avez changer le grade de {darkred}%N en {green}%s{default}.", target, actual);
		rp_PrintToChat(target, "Votre grade a été modifié en {green}%s {default}par {darkred}%N{default}.", actual, client);
		
		if(id != 0)
		{
			char query[1024];
			Format(STRING(query), "SELECT * FROM `rp_admin` WHERE `steamid` = '%s'", iData[target].SteamID);
			DBResultSet Results = SQL_Query(g_DB, query);
			if(Results.FetchRow())
				SQL_Request(g_DB, "UPDATE `rp_admin` SET `level` = '%i' WHERE `steamid` = '%s';", id, iData[target].SteamID);
			else
			{
				char playername[MAX_NAME_LENGTH + 8];
				GetClientName(client, STRING(playername));
				char clean_playername[MAX_NAME_LENGTH * 2 + 16];
				SQL_EscapeString(g_DB, playername, STRING(clean_playername));
				SQL_Request(g_DB, "INSERT INTO `rp_admin` (`id`, `steamid`, `playername`, `level`, `tag`) VALUES (NULL, '%s', '%s', '%i', '{lightred}STAFF');", iData[client].SteamID, clean_playername, id);			
			}
		}
		else
			SQL_Request(g_DB, "DELETE FROM `rp_admin` WHERE `steamid` = '%s'", iData[target].SteamID);
		
		Menu_MiscAdmin(client);
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if(param == MenuCancel_ExitBack)
			FakeClientCommand(client, "say !rp_admin");
	}
	else if(action == MenuAction_End)
		delete menu;
		
	return 0;
}

void Menu_Kick(int client)
{
	rp_SetClientBool(client, b_DisplayHud, false);
	
	Menu menu = new Menu(Handle_MenuKickRaison);
	menu.SetTitle("=== ADMIN === -> KICK");
	
	char name[32];
	LoopClients(i)
	{
		if(!IsClientValid(i))
			continue;
			
		GetClientName(i, STRING(name));
		menu.AddItem(name, name);
	}
	
	menu.ExitBackButton = true;
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Handle_MenuKickRaison(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[64], strIndex[16];
		menu.GetItem(param, STRING(info));
		
		Menu menu1 = new Menu(Handle_MenuKickFinal);
		menu1.SetTitle("=== KICK === -> RAISON");
		
		Format(STRING(strIndex), "%s|Troll", info);
		menu1.AddItem(strIndex, "Troll");
		
		Format(STRING(strIndex), "%s|Non respect du règlement", info);
		menu1.AddItem(strIndex, "Non respect du règlement");
		
		Format(STRING(strIndex), "%s|Anti Jeu", info);
		menu1.AddItem(strIndex, "Anti Jeu");
		
		Format(STRING(strIndex), "%s|Freekill", info);
		menu1.AddItem(strIndex, "Freekill");
		
		Format(STRING(strIndex), "%s|Insulte", info);
		menu1.AddItem(strIndex, "Insulte");
		
		Format(STRING(strIndex), "%s|Racisme", info);
		menu1.AddItem(strIndex, "Racisme");
		
		Format(STRING(strIndex), "%s|Atteinte à la vie privée d'autrui", info);
		menu1.AddItem(strIndex, "Atteinte à la vie privée d'autrui");
		
		Format(STRING(strIndex), "%s|Abusif", info);
		menu1.AddItem(strIndex, "Abusif");
		
		Format(STRING(strIndex), "%s|Toxique", info);
		menu1.AddItem(strIndex, "Toxique");
		
		menu1.ExitBackButton = true;
		menu1.ExitButton = true;
		menu1.Display(client, MENU_TIME_FOREVER);
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if(param == MenuCancel_ExitBack)
			FakeClientCommand(client, "say !rp_admin");
	}
	else if(action == MenuAction_End)
		delete menu;
		
	return 0;
}

int Handle_MenuKickFinal(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[128], buffer[2][128];
		menu.GetItem(param, STRING(info));
		ExplodeString(info, "|", buffer, 2, 128);	
		
		FakeClientCommand(client, "say !rp_kick %s %s", buffer[0], buffer[1]);
		rp_SetClientBool(client, b_DisplayHud, true);
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if(param == MenuCancel_ExitBack)
			FakeClientCommand(client, "say !rp_admin");
	}
	else if(action == MenuAction_End)
		delete menu;
		
	return 0;
}

void Menu_Ban(int client) {
	rp_SetClientBool(client, b_DisplayHud, false);
	
	Menu menu = new Menu(Handle_MenuBanRaison);
	menu.SetTitle("=== ADMIN === -> BAN");
	
	char name[32];
	LoopClients(i)
	{
		if(!IsClientValid(i))
			continue;
			
		GetClientName(i, STRING(name));
		menu.AddItem(name, name);
	}
	
	menu.ExitBackButton = true;
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Handle_MenuBanRaison(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[64], strIndex[16];
		menu.GetItem(param, STRING(info));
		
		Menu menu1 = new Menu(Handle_MenuBanTime);
		menu1.SetTitle("=== BAN === -> RAISON");
		
		Format(STRING(strIndex), "%s|Troll", info);
		menu1.AddItem(strIndex, "Troll");
		
		Format(STRING(strIndex), "%s|Non respect du règlement", info);
		menu1.AddItem(strIndex, "Non respect du règlement");
		
		Format(STRING(strIndex), "%s|Anti Jeu", info);
		menu1.AddItem(strIndex, "Anti Jeu");
		
		Format(STRING(strIndex), "%s|Freekill", info);
		menu1.AddItem(strIndex, "Freekill");
		
		Format(STRING(strIndex), "%s|Insulte", info);
		menu1.AddItem(strIndex, "Insulte");
		
		Format(STRING(strIndex), "%s|Racisme", info);
		menu1.AddItem(strIndex, "Racisme");
		
		Format(STRING(strIndex), "%s|Atteinte à la vie privée d'autrui", info);
		menu1.AddItem(strIndex, "Atteinte à la vie privée d'autrui");
		
		Format(STRING(strIndex), "%s|Abusif", info);
		menu1.AddItem(strIndex, "Abusif");
		
		Format(STRING(strIndex), "%s|Toxique", info);
		menu1.AddItem(strIndex, "Toxique");
		
		menu1.ExitBackButton = true;
		menu1.ExitButton = true;
		menu1.Display(client, MENU_TIME_FOREVER);
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if(param == MenuCancel_ExitBack)
			FakeClientCommand(client, "say !rp_admin");
	}
	else if(action == MenuAction_End)
		delete menu;
		
	return 0;
}

public int Handle_MenuBanTime(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[128], strIndex[128];
		menu.GetItem(param, STRING(info));
		
		Menu menu1 = new Menu(Handle_MenuBanFinal);
		menu1.SetTitle("=== BAN === -> TEMPS");
		
		Format(STRING(strIndex), "%s|0", info);
		menu1.AddItem(strIndex, "Permanent");
		
		Format(STRING(strIndex), "%s|600", info);
		menu1.AddItem(strIndex, "10 Minutes");
		
		Format(STRING(strIndex), "%s|1800", info);
		menu1.AddItem(strIndex, "30 Minutes");
		
		Format(STRING(strIndex), "%s|3600", info);
		menu1.AddItem(strIndex, "1 Heure");
		
		Format(STRING(strIndex), "%s|7200", info);
		menu1.AddItem(strIndex, "2 Heure");
		
		Format(STRING(strIndex), "%s|14400", info);
		menu1.AddItem(strIndex, "4 Heure");
		
		Format(STRING(strIndex), "%s|86 400", info);
		menu1.AddItem(strIndex, "1 Jour");
		
		Format(STRING(strIndex), "%s|604 800", info);
		menu1.AddItem(strIndex, "1 Semaine");
		
		menu1.ExitBackButton = true;
		menu1.ExitButton = true;
		menu1.Display(client, MENU_TIME_FOREVER);
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if(param == MenuCancel_ExitBack)
			FakeClientCommand(client, "say !rp_admin");
	}
	else if(action == MenuAction_End)
		delete menu;
		
	return 0;
}

public int Handle_MenuBanFinal(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[128], buffer[3][128];
		menu.GetItem(param, STRING(info));
		ExplodeString(info, "|", buffer, 3, 128);	
		
		FakeClientCommand(client, "say !rp_ban %s %i %s", buffer[0], StringToInt(buffer[2]), buffer[1]);
		rp_SetClientBool(client, b_DisplayHud, true);
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if(param == MenuCancel_ExitBack)
			FakeClientCommand(client, "say !rp_admin");
	}
	else if(action == MenuAction_End)
		delete menu;
		
	return 0;
}

void Menu_Teleport(int client)
{
	rp_SetClientBool(client, b_DisplayHud, false);
	
	Menu menu = new Menu(Handle_MenuTeleportType);
	menu.SetTitle("=== ADMIN === -> TELEPORTATION");
	
	menu.AddItem("tp", "Téléporter");
	menu.AddItem("tpa", "Se téléporter");
	
	menu.ExitBackButton = true;
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Handle_MenuTeleportType(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[128], strIndex[16];
		menu.GetItem(param, STRING(info));
			
		Menu menu1 = new Menu(Handle_MenuTeleportFinal);
		
		if(StrEqual(info, "tp"))
			menu1.SetTitle("=== TELEPORTATION === -> TELEPORTER");
		else if(StrEqual(info, "tpa"))
			menu1.SetTitle("=== TELEPORTATION === -> SE TELEPORTER");	
			
		char name[32];
		LoopClients(i)
		{
			if(!IsClientValid(i))
				continue;
				
			GetClientName(i, STRING(name));
			Format(STRING(strIndex), "%s|%s", info, name);
			menu1.AddItem(strIndex, name);
		}	
		
		menu1.ExitBackButton = true;
		menu1.ExitButton = true;
		menu1.Display(client, MENU_TIME_FOREVER);
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if(param == MenuCancel_ExitBack)
			FakeClientCommand(client, "say !rp_admin");
	}
	else if(action == MenuAction_End)
		delete menu;
		
	return 0;
}

public int Handle_MenuTeleportFinal(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[128], buffer[2][128];
		menu.GetItem(param, STRING(info));
		ExplodeString(info, "|", buffer, 2, 128);
		
		if(StrEqual(buffer[0], "tp"))
			FakeClientCommand(client, "say !rp_tp %s", buffer[1]);
		else if(StrEqual(buffer[0], "tpa"))
			FakeClientCommand(client, "say !rp_tpa %s", buffer[1]);
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if(param == MenuCancel_ExitBack)
			FakeClientCommand(client, "say !rp_admin");
	}
	else if(action == MenuAction_End)
		delete menu;
	
	return 0;
}

void Menu_Reboot(int client)
{
	rp_SetClientBool(client, b_DisplayHud, false);
	
	Menu menu = new Menu(Handle_MenuReboot);
	menu.SetTitle("=== ADMIN === -> REBOOT");
	
	menu.AddItem("0", "Instant");
	menu.AddItem("5", "5 Secondes");
	menu.AddItem("10", "10 Secondes");
	menu.AddItem("15", "15 Secondes");
	menu.AddItem("20", "20 Secondes");
	
	menu.ExitBackButton = true;
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Handle_MenuReboot(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[64];
		menu.GetItem(param, STRING(info));
		
		FakeClientCommand(client, "say !rp_reboot %s", info);
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if(param == MenuCancel_ExitBack)
			FakeClientCommand(client, "say !rp_admin");
	}
	else if(action == MenuAction_End)
		delete menu;
		
	return 0;
}

void Menu_Freeze(int client)
{
	rp_SetClientBool(client, b_DisplayHud, false);
	
	Menu menu = new Menu(Handle_MenuFreeze);
	menu.SetTitle("=== ADMIN === -> FREEZE");
	
	char name[32];
	LoopClients(i)
	{
		if(!IsClientValid(i))
			continue;
			
		GetClientName(i, STRING(name));
		menu.AddItem(name, name);
	}
	
	menu.ExitBackButton = true;
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Handle_MenuFreeze(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[64];
		menu.GetItem(param, STRING(info));
		
		FakeClientCommand(client, "say !rp_freeze %s", info);
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if(param == MenuCancel_ExitBack)
			FakeClientCommand(client, "say !rp_admin");
	}
	else if(action == MenuAction_End)
		delete menu;
		
	return 0;
}

void Menu_Job(int client)
{
	rp_SetClientBool(client, b_DisplayHud, false);
	
	Menu menu = new Menu(Handle_MenuJob);
	menu.SetTitle("%T", "MenuAdmin_SubJobMenu", LANG_SERVER);
	
	char name[32], strIndex[8];
	LoopClients(i)
	{
		if(!IsClientValid(i))
			continue;
		
		GetClientName(i, STRING(name));
		Format(STRING(strIndex), "%i", i);
		menu.AddItem(strIndex, name);
	}
	
	menu.ExitBackButton = true;
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Handle_MenuJob(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[64], strMenu[64];
		menu.GetItem(param, STRING(info));
		int joueur = StringToInt(info);		
		
		char name[64];
		Format(STRING(name), "%N", joueur);
		
		rp_SetClientBool(client, b_DisplayHud, false);
		Menu menu1 = new Menu(Handle_MenuJobSub);
		menu1.SetTitle("%T", "MenuAdmin_JobMenu_Target", LANG_SERVER, name);
		
		for (int i = 0; i <= MAXJOBS; i++)
		{
			char jobname[32];
			rp_GetJobName(i, STRING(jobname));
			
			Format(STRING(strMenu), "%i|%i", i, joueur);
			menu1.AddItem(strMenu, jobname);
		}	
		
		menu1.ExitBackButton = true;
		menu1.ExitButton = true;
		menu1.Display(client, MENU_TIME_FOREVER);
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if(param == MenuCancel_ExitBack)
			FakeClientCommand(client, "say !rp_admin");
	}
	else if(action == MenuAction_End)
		delete menu;
		
	return 0;
}

public int Handle_MenuJobSub(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[32], buffer[2][32];
		menu.GetItem(param, STRING(info));
		
		ExplodeString(info, "|", buffer, 2, 32);
		int numeroJob = StringToInt(buffer[0]);
		int joueur = StringToInt(buffer[1]);
		
		char name[64];
		Format(STRING(name), "%N", joueur);
		
		if(numeroJob != 0)
		{
			rp_SetClientBool(client, b_DisplayHud, false);
			Menu menu1 = new Menu(Handle_MenuJobFinal);

			menu1.SetTitle("%T", "MenuAdmin_JobGrade_Target", LANG_SERVER, name);
			
			char strMenu[32];	
			int MaxGrades = rp_GetJobMaxGrades(numeroJob);
			for (int i = 1; i <= MaxGrades; i++)
			{
				char gradeName[32];
				rp_GetGradeName(numeroJob, i, STRING(gradeName));
				
				Format(STRING(strMenu), "%i|%i|%i", numeroJob, i, joueur);
				menu1.AddItem(strMenu, gradeName);
			}	
	
			menu1.ExitBackButton = true;
			menu1.ExitButton = true;
			menu1.Display(client, MENU_TIME_FOREVER);
		}
		else
		{
			rp_SetClientInt(joueur, i_Job, 0);
			rp_SetClientInt(joueur, i_Grade, 0);
			rp_SetClientInt(client, i_Salary, rp_GetGradeSalary(rp_GetClientInt(client, i_Job), rp_GetClientInt(client, i_Grade)));
			
			ChangeClientTeam(joueur, 2);
			
			//LoadSalaire(joueur);			
			SQL_Request(g_DB, "UPDATE `rp_jobs` SET `jobid` = '%i', `gradeid` = '%i' WHERE `steamid` = '%s';", 0, 0, iData[joueur].SteamID);

			if(joueur != client)
				rp_PrintToChat(client, "%t", "MenuAdmin_JobClient_None", LANG_SERVER, joueur);
			else
				rp_PrintToChat(client, "%t", "MenuAdmin_Job_NoJob", LANG_SERVER);
			rp_SetClientBool(client, b_DisplayHud, true);
			
			char jobName[32], gradeName[16];
			rp_GetJobName(rp_GetClientInt(joueur, i_Job), STRING(jobName));
			rp_GetGradeName(rp_GetClientInt(joueur, i_Job), rp_GetClientInt(joueur, i_Grade), STRING(gradeName));
			
			Call_StartForward(Forward.OnJob);
			Call_PushCell(client);
			Call_PushCell(joueur);
			Call_PushString(jobName);
			Call_PushString(gradeName);
			Call_Finish();
		}
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if(param == MenuCancel_ExitBack)
			Menu_Job(client);
	}
	else if (action == MenuAction_End)
		delete menu;
		
	return 0;
}

public int Handle_MenuJobFinal(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		rp_SetClientBool(client, b_DisplayHud, false);
		char info[32], buffer[3][8];
		menu.GetItem(param, STRING(info));
		
		ExplodeString(info, "|", buffer, 3, 8);
		int numeroJob = StringToInt(buffer[0]);
		int numeroGrade = StringToInt(buffer[1]);
		int joueur = StringToInt(buffer[2]);
		
		if(numeroJob != 0)
		{
			rp_SetClientInt(joueur, i_Job, numeroJob);
			rp_SetClientInt(joueur, i_Grade, numeroGrade);				
			SQL_Request(g_DB, "UPDATE `rp_jobs` SET `jobid` = '%i', `gradeid` = '%i' WHERE `playerid` = '%i';", numeroJob, numeroGrade, rp_GetSQLID(joueur));
		}
		else
		{
			rp_SetClientInt(joueur, i_Job, 0);
			rp_SetClientInt(joueur, i_Grade, 0);				
			SQL_Request(g_DB, "UPDATE `rp_jobs` SET `jobid` = '%i', `gradeid` = '%i' WHERE `playerid` = '%i';", 0, 0, rp_GetSQLID(joueur));
		}	
		//LoadSalaire(joueur);	
		
		char jobName[32], gradeName[16];
		rp_GetJobName(numeroJob, STRING(jobName));
		rp_GetGradeName(numeroGrade, numeroJob, STRING(gradeName));

		rp_SetClientInt(client, i_Salary, rp_GetGradeSalary(rp_GetClientInt(client, i_Job), rp_GetClientInt(client, i_Grade)));
		
		if(joueur != client)
		{
			rp_PrintToChat(client, "Vous avez promu %N en tant que %s (%s).", joueur, gradeName, jobName);
			rp_PrintToChat(joueur, "Vous avez été promu %s (%s) par %N.", gradeName, jobName, client);
			
			ShowPanel2(joueur, 2, "Promotion: <font color='%s'>+</font><font color='%s'>%s - %s</font> par %s", HTML_DARKGREEN, HTML_CRIMSON, gradeName, jobName, client);
		}
		else
		{
			rp_PrintToChat(client, "Vous êtes maintenant %s (%s).", gradeName, jobName);
			ShowPanel2(client, 2, "Promotion: <font color='%s'>+</font><font color='%s'>%s - %s</font>", HTML_DARKGREEN, HTML_CRIMSON, gradeName, jobName);
		}
			
		Call_StartForward(Forward.OnJob);
		Call_PushCell(client);
		Call_PushCell(joueur);
		Call_PushString(jobName);
		Call_PushString(gradeName);
		Call_Finish();	
			
		rp_SetClientBool(client, b_DisplayHud, true);	
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if(param == MenuCancel_ExitBack)
			Menu_Job(client);
	}
	else if (action == MenuAction_End)
		delete menu;
		
	return 0;
}

void Menu_Vip(int client)
{
	rp_SetClientBool(client, b_DisplayHud, false);
	
	Menu menu = new Menu(Handle_MenuVip);
	menu.SetTitle("=== ADMIN === -> VIP");
	
	menu.AddItem("add", "Ajouter");
	menu.AddItem("edit", "Modifier");
	menu.AddItem("remove", "Supprimer");
	
	menu.ExitBackButton = true;
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Handle_MenuVip(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[64];
		menu.GetItem(param, STRING(info));
		
		if(StrEqual(info, "add"))
			Menu_VipAdd(client);
		else if(StrEqual(info, "edit"))
			Menu_VipEdit(client);
		else if(StrEqual(info, "remove"))
			Menu_VipRemove(client);		
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if(param == MenuCancel_ExitBack)
			FakeClientCommand(client, "say !rp_admin");
	}
	else if(action == MenuAction_End)
		delete menu;
		
	return 0;
}

void Menu_VipEdit(int client)
{
	rp_SetClientBool(client, b_DisplayHud, false);
	
	Menu menu = new Menu(Handle_MenuVipEdit);
	menu.SetTitle("=== VIP === -> Edit");
	
	int count;
	
	char query[1024];
	Format(STRING(query), "SELECT * FROM `rp_vips` WHERE exit");	 
	DBResultSet Results = SQL_Query(g_DB, query);
	while(Results.FetchRow())
	{
		count++;
		char query_steamid[32], query_name[64], query_time[32];
		Results.FetchStringByName("playerid", STRING(query_steamid));
		Results.FetchStringByName("time", STRING(query_time));
		int time = StringToInt(query_time);
		
		char timestamp[128], strIndex[64], strMenu[128];
		
		if(time != -1)
		{
			int iYear, iMonth, iDay, iHour, iMinute, iSecond;
			UnixToTime(time, iYear, iMonth, iDay, iHour, iMinute, iSecond, UT_TIMEZONE_CEST);	
			Format(STRING(timestamp), "%02d/%02d/%d %02d:%02d:%02d", iDay, iMonth, iYear, iHour, iMinute, iSecond);	
			
			Format(STRING(strIndex), "%s|%s", query_steamid, time);
			
		}	
		else
			timestamp = "Permanent";
		
		Format(STRING(strMenu), "%s [%s]", query_name, timestamp);
		
		if(StrEqual(timestamp, "Permanent"))
			menu.AddItem(strIndex, strMenu, ITEMDRAW_DISABLED);
		else
			menu.AddItem(strIndex, strMenu);		
	}			
	delete Results;
	
	if(count == 0)
		menu.AddItem("", "Aucun VIP !", ITEMDRAW_DISABLED);
	
	menu.ExitBackButton = true;
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Handle_MenuVipEdit(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[64], strIndex[128];
		menu.GetItem(param, STRING(info));
		
		rp_SetClientBool(client, b_DisplayHud, false);
	
		Menu menu1 = new Menu(Handle_MenuVipEditType);
		menu1.SetTitle("=== EDIT === -> Type");
		
		Format(STRING(strIndex), "%s|+", info);
		menu1.AddItem(strIndex, "Ajouter");
		
		Format(STRING(strIndex), "%s|-", info);
		menu1.AddItem(strIndex, "Retirer");
		
		menu1.ExitBackButton = true;
		menu1.ExitButton = true;
		menu1.Display(client, MENU_TIME_FOREVER);
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if(param == MenuCancel_ExitBack)
			 Menu_Vip(client);
	}
	else if(action == MenuAction_End)
		delete menu;

	return 0;
}

public int Handle_MenuVipEditType(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[64], strIndex[128];
		menu.GetItem(param, STRING(info));
		
		rp_SetClientBool(client, b_DisplayHud, false);
	
		Menu menu1 = new Menu(Handle_MenuVipEditFinal);
		
		if(StrContains(info, "+") != -1)
			menu1.SetTitle("=== EDIT === -> Ajouter");
		else if(StrContains(info, "-") != -1)
			menu1.SetTitle("=== EDIT === -> Retirer");		
		
		Format(STRING(strIndex), "%s|3600", info);
		menu1.AddItem(strIndex, "1 Heure");
		
		Format(STRING(strIndex), "%s|7200", info);
		menu1.AddItem(strIndex, "2 Heure");
		
		Format(STRING(strIndex), "%s|10800", info);
		menu1.AddItem(strIndex, "3 Heure");
		
		Format(STRING(strIndex), "%s|14400", info);
		menu1.AddItem(strIndex, "4 Heure");
		
		Format(STRING(strIndex), "%s|18000", info);
		menu1.AddItem(strIndex, "5 Heure");
		
		menu1.ExitBackButton = true;
		menu1.ExitButton = true;
		menu1.Display(client, MENU_TIME_FOREVER);
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if(param == MenuCancel_ExitBack)
			Menu_VipEdit(client);
	}
	else if(action == MenuAction_End)
		delete menu;

	return 0;
}

public int Handle_MenuVipEditFinal(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[64], buffer[4][256];
		menu.GetItem(param, STRING(info));
		ExplodeString(info, "|", buffer, 4, 256);
		
		//buffer[0] = steamid
		//buffer[1] = time
		//buffer[2] = type
		//buffer[3] = time
		
		int time_default = StringToInt(buffer[1]);
		int time_edit = StringToInt(buffer[3]);
		int time_final;
		int target = Client_FindBySteamId(buffer[0]);
		
		if(StrEqual(buffer[2], "+"))
			time_final = time_default + time_edit;
		else if(StrEqual(buffer[2], "-"))
			time_final = time_default - time_edit;	
		
		SQL_Request(g_DB, "UPDATE `rp_vips` SET `time` = '%i' WHERE `playerid` = '%i';", time_final, buffer[0]);
		
		if(IsClientValid(target))
		{
			char old_timestamp[128], new_timestamp[128];
			
			int iYear_1, iMonth_1, iDay_1, iHour_1, iMinute_1, iSecond_1;
			UnixToTime(time_default, iYear_1, iMonth_1, iDay_1, iHour_1, iMinute_1, iSecond_1, UT_TIMEZONE_CEST);	
			Format(STRING(old_timestamp), "%02d/%02d/%d %02d:%02d:%02d", iDay_1, iMonth_1, iYear_1, iHour_1, iMinute_1, iSecond_1);	
			
			int iYear_2, iMonth_2, iDay_2, iHour_2, iMinute_2, iSecond_2;
			UnixToTime(time_final, iYear_2, iMonth_2, iDay_2, iHour_2, iMinute_2, iSecond_2, UT_TIMEZONE_CEST);	
			Format(STRING(new_timestamp), "%02d/%02d/%d %02d:%02d:%02d", iDay_2, iMonth_2, iYear_2, iHour_2, iMinute_2, iSecond_2);	
			
			rp_PrintToChat(client, "Votre statut {yellow}VIP {default} a été changé, {darkred}%s {green}%s", old_timestamp, new_timestamp);
		}	
		
		//rp_PrintToChat(client, "", TEAM);
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if(param == MenuCancel_ExitBack)
			Menu_VipEdit(client);
	}
	else if(action == MenuAction_End)
		delete menu;

	return 0;
}

void Menu_VipAdd(int client)
{
	rp_SetClientBool(client, b_DisplayHud, false);
	
	Menu menu = new Menu(Handle_MenuVipAdd);
	menu.SetTitle("=== VIP === -> Ajouter");
	
	int count;

	char name[32];
	LoopClients(i)
	{
		if(!IsClientValid(i))
			continue;
		if(rp_GetClientBool(i, b_IsVip))
			continue;
			
		count++;
			
		GetClientName(i, STRING(name));
		menu.AddItem(iData[i].SteamID, name);
	}
	
	if(count == 0)
		menu.AddItem("", "Aucun joueur", ITEMDRAW_DISABLED);
	
	menu.ExitBackButton = true;
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Handle_MenuVipAdd(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[64], strIndex[64];
		menu.GetItem(param, STRING(info));
		
		rp_SetClientBool(client, b_DisplayHud, false);
	
		Menu menu1 = new Menu(Handle_MenuVipAddFinal);
		menu1.SetTitle("=== Ajouter === -> Temps");
		
		Format(STRING(strIndex), "%s|-1", info);
		menu1.AddItem(strIndex, "Permanent");
		
		Format(STRING(strIndex), "%s|3600", info);
		menu1.AddItem(strIndex, "1 Heure");
		
		Format(STRING(strIndex), "%s|7200", info);
		menu1.AddItem(strIndex, "2 Heure");
		
		Format(STRING(strIndex), "%s|10800", info);
		menu1.AddItem(strIndex, "3 Heure");
		
		Format(STRING(strIndex), "%s|14400", info);
		menu1.AddItem(strIndex, "4 Heure");
		
		Format(STRING(strIndex), "%s|18000", info);
		menu1.AddItem(strIndex, "5 Heure");
		
		menu1.ExitBackButton = true;
		menu1.ExitButton = true;
		menu1.Display(client, MENU_TIME_FOREVER);
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if(param == MenuCancel_ExitBack)
			FakeClientCommand(client, "say !rp_admin");
	}
	else if(action == MenuAction_End)
		delete menu;

	return 0;
}

public int Handle_MenuVipAddFinal(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[64], buffer[2][128];
		menu.GetItem(param, STRING(info));
		ExplodeString(info, "|", buffer, 2, 128);
		
		int target = Client_FindBySteamId(buffer[0]);
		int time = StringToInt(buffer[1]);
		
		if(IsClientValid(target))
		{
			if(time != -1)
			{
				char timestamp[128];
				int iYear, iMonth, iDay, iHour, iMinute, iSecond;
				UnixToTime(time, iYear, iMonth, iDay, iHour, iMinute, iSecond, UT_TIMEZONE_CEST);	
				Format(STRING(timestamp), "%02d/%02d/%d %02d:%02d:%02d", iDay, iMonth, iYear, iHour, iMinute, iSecond);	
				
				time = time + GetTime();
				
				if(target != client)
					rp_PrintToChat(target, "Vous avez été rajouté {yellow}VIP {default} par {darkred}%N{default} jusqu'au {green} %s.", client, timestamp);
				rp_PrintToChat(client, "Vous avez rajouté {yellow}VIP {darkred}%N{default} jusqu'au {green} %s.", target, timestamp);
			}	
			else
			{
				if(target != client)
					rp_PrintToChat(target, "Vous avez été rajouté {yellow}VIP {green}permanent {default}par {darkred}%N{default}.", client);
				rp_PrintToChat(client, "Vous avez rajouté {yellow}VIP {green}permanent {darkred}%N{default}.", target);
			}	
			
			char playername[MAX_NAME_LENGTH + 8];
			GetClientName(target, STRING(playername));
			char clean_playername[MAX_NAME_LENGTH * 2 + 16];
			SQL_EscapeString(g_DB, playername, STRING(clean_playername));
			
			SQL_Request(g_DB, "INSERT IGNORE INTO `rp_vips` (`id`, `steamid`, `playername`, `time`) VALUES (NULL, '%s', '%s', '%i');", buffer[0], clean_playername, time);	
			
			rp_SetClientBool(client, b_DisplayHud, true);
			rp_SetClientBool(target, b_IsVip, true);
		}
		else
		{
			rp_PrintToChat(client, "{default}SteamID: {lightred} not valid.");
		}		
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if(param == MenuCancel_ExitBack)
			Menu_VipAdd(client);	
	}
	else if(action == MenuAction_End)
		delete menu;
		
	return 0;
}

void Menu_VipRemove(int client)
{
	rp_SetClientBool(client, b_DisplayHud, false);
	
	Menu menu = new Menu(Handle_MenuVipRemove);
	menu.SetTitle("=== VIP === -> Supprimer");
	
	int count;
	
	char query[1024];
	Format(STRING(query), "SELECT * FROM `rp_vips`");	 
	DBResultSet Results = SQL_Query(g_DB, query);
	while(Results.FetchRow())
	{
		count++;
		char query_steamid[32], query_name[64], query_time[32];
		Results.FetchStringByName("steamid", STRING(query_steamid));
		Results.FetchStringByName("playername", STRING(query_name));
		Results.FetchStringByName("time", STRING(query_time));
		int time = StringToInt(query_time);
		
		char timestamp[128], strMenu[128];
		if(time != -1)
		{
			int iYear, iMonth, iDay, iHour, iMinute, iSecond;
			UnixToTime(time, iYear, iMonth, iDay, iHour, iMinute, iSecond, UT_TIMEZONE_CEST);	
			Format(STRING(timestamp), "%02d/%02d/%d %02d:%02d:%02d", iDay, iMonth, iYear, iHour, iMinute, iSecond);	
		}		
		else
			timestamp = "Permanent";
		
		Format(STRING(strMenu), "%s [%s]", query_name, timestamp);
		menu.AddItem(query_steamid, strMenu);
	}			
	delete Results;
	
	if(count == 0)
		menu.AddItem("", "Aucun VIP !", ITEMDRAW_DISABLED);
	
	menu.ExitBackButton = true;
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Handle_MenuVipRemove(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[64], buffer[2][128];
		menu.GetItem(param, STRING(info));
		ExplodeString(info, "|", buffer, 2, 128);
		
		int target = Client_FindBySteamId(buffer[0]);
		
		if(IsClientValid(target))
		{
			if(target != client)
				rp_PrintToChat(target, "Votre statut {yellow}VIP {default}a été supprimé par {green}%N.", target);
			rp_PrintToChat(client, "Vous avez supprimer le statut {yellow}VIP {default}de {green}%N.", target);
			
			rp_SetClientBool(target, b_IsVip, false);
			
			SQL_Request(g_DB, "DELETE FROM `rp_vips` WHERE `steamid` = '%s'", buffer[0]);
		}
		else
			rp_PrintToChat(client, "{darkred}!!! {default}SteamID non valid {darkred}!!!");
		rp_SetClientBool(client, b_DisplayHud, true);
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if(param == MenuCancel_ExitBack)
			Menu_Vip(client);	
	}
	else if(action == MenuAction_End)
		delete menu;

	return 0;
}

/***************************************************************************************

									C L I E N T - S I D E

***************************************************************************************/

public void RP_OnClientFirstSpawn(int client)
{
	if(iData[client].HasBeenDebanned)
	{
		iData[client].HasBeenDebanned = false;
		rp_PrintToChat(client, "Votre pénalité a atteint son échéance, évitez de vous attirer de nouveau des ennuies.\n Bon jeu !");
	}
}

public void OnClientPutInServer(int client)
{
	// MethodMap Constructor
	m_iClient[client] = Roleplay(client);
	
	rp_SetAdmin(client, ADMIN_FLAG_NONE);
}	

public void OnClientDisconnect(int client) 
{
	rp_SetAdmin(client, ADMIN_FLAG_NONE);
	SDKUnhook(client, SDKHook_SetTransmit, Hook_SetTransmit);
}

public void OnClientPostAdminCheck(int client) 
{	
	SQL_LOAD(client);
}

public void OnClientAuthorized(int client, const char[] auth) 
{	
	strcopy(iData[client].SteamID, sizeof(iData[].SteamID), auth);
}

/***************************************************************************************

									C O M M A N D S

***************************************************************************************/

public Action Command_Mute(int client, int args)
{
	#if DEBUG
		Translation_DebugCommand(client);
	#endif
	
	if(rp_GetAdmin(client) == ADMIN_FLAG_NONE)
	{
		Translation_PrintNoAccess(client);
		return Plugin_Handled;
	}
	
	if(args < 2)
	{
		if(client > 0)
			rp_PrintToChat(client, "Usage : rp_mute <target> <type>");
		else
			PrintToServer("[ADMIN] Usage : rp_mute <target> <type>");
		return Plugin_Handled;
	}
	
	char arg[256];
	GetCmdArg(1, STRING(arg));
	
	char arg2[256];
	GetCmdArg(2, STRING(arg2));
	
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

	if(IsClientValid(target))
	{
		if(StrEqual(arg2, "global", false))
		{
			if(rp_GetClientBool(target, b_IsMuteGlobal))
			{
				rp_SetClientBool(target, b_IsMuteGlobal, false);
				rp_PrintToChat(target, "Vous n'êtes plus muet {lightgreen}[CHAT GLOBAL]{default}.");
			}
			else
			{
				rp_SetClientBool(target, b_IsMuteGlobal, true);
				rp_PrintToChat(target, "Vous êtes muet {lightred}[CHAT GLOBAL]{default}.");
			}
			
			if(target != client)
			{
				if(client > 0)
				{
					if(rp_GetClientBool(target, b_IsMuteGlobal))
						rp_PrintToChat(target, "{yellow}%N {default}est muet {lightred}[CHAT GLOBAL]{default}.", target);
					else
						rp_PrintToChat(client, "{yellow}%N {default}n'est plus muet {lightgreen}[CHAT GLOBAL]{default}.", target);
				}
				else
				{
					if(rp_GetClientBool(target, b_IsMuteGlobal))
						PrintToServer("[ADMIN] %N est muet [CHAT GLOBAL].", target);
					else
						PrintToServer("[ADMIN] %N n'est plus muet [CHAT GLOBAL].", target);
				}
			}
		}
		else if(StrEqual(arg2, "local", false))
		{
			if(rp_GetClientBool(target, b_IsMuteLocal))
			{
				rp_SetClientBool(target, b_IsMuteLocal, false);
				PrintHintText(target, "Vous n'êtes plus muet [CHAT LOCAL].");
				rp_PrintToChat(target, "Vous n'êtes plus muet {lightgreen}[CHAT LOCAL]{default}.");
			}
			else
			{
				rp_SetClientBool(target, b_IsMuteLocal, true);
				PrintHintText(target, "Vous êtes muet [CHAT LOCAL].");
				rp_PrintToChat(target, "Vous êtes muet {lightred}[CHAT LOCAL]{default}.");
			}
			
			if(target != client)
			{
				if(client > 0)
				{
					if(rp_GetClientBool(target, b_IsMuteLocal))
						rp_PrintToChat(client, "{yellow}%N {default}est muet {lightred}[CHAT LOCAL]{default}.", target);
					else
						rp_PrintToChat(client, "{yellow}%N {default}n'est plus muet {lightgreen}[CHAT LOCAL]{default}.", target);
				}
				else
				{
					if(rp_GetClientBool(target, b_IsMuteLocal))
						PrintToServer("[ADMIN] %N est muet [CHAT LOCAL].", target);
					else
						PrintToServer("[ADMIN] %N n'est plus muet [CHAT LOCAL].", target);
				}
			}
		}	
		else if(StrEqual(arg2, "voice", false))
		{
			if(rp_GetClientBool(target, b_IsMuteVocal))
			{
				rp_SetClientBool(target, b_IsMuteVocal, false);
				PrintHintText(target, "Vous n'êtes plus muet [VOCAL].");
				rp_PrintToChat(target, "Vous n'êtes plus muet {lightgreen}[VOCAL]{default}.");
			}
			else
			{
				rp_SetClientBool(target, b_IsMuteVocal, true);
				PrintHintText(target, "Vous êtes muet [VOCAL].");
				rp_PrintToChat(target, "Vous êtes muet {lightred}[VOCAL]{default}.");
			}
			
			if(target != client)
			{
				if(client > 0)
				{
					if(rp_GetClientBool(target, b_IsMuteVocal))
						rp_PrintToChat(client, "{yellow}%N {default}est muet {lightred}[VOCAL]{default}.", target);
					else
						rp_PrintToChat(client, "{yellow}%N {default}n'est plus muet {lightgreen}[VOCAL]{default}.", target);
				}
				else
				{
					if(rp_GetClientBool(target, b_IsMuteVocal))
						PrintToServer("[ADMIN] %N est muet [VOCAL].", target);
					else
						PrintToServer("[ADMIN] %N n'est plus muet [VOCAL].", target);
				}
			}
		}
	}	
	
	return Plugin_Handled;
}

public Action Command_Noclip(int client, int args)
{
	#if DEBUG
		Translation_DebugCommand(client);
	#endif
	
	if(rp_GetAdmin(client) == ADMIN_FLAG_NONE)
	{
		Translation_PrintNoAccess(client);
		return Plugin_Handled;
	}
	
	if(args < 1)
	{
		if(client > 0)
			rp_PrintToChat(client, "Usage : rp_noclip <target>");
		else
			PrintToServer("[ADMIN] Usage : rp_noclip <target>");
		return Plugin_Handled;
	}
	
	char arg[32];
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
    
	if(IsPlayerAlive(target) && IsValidEntity(target))
	{
		if(GetEntityMoveType(target) != MOVETYPE_NOCLIP)
		{
			SetEntityMoveType(target, MOVETYPE_NOCLIP);
			ShowPanel2(target, 1, "<font color='%s'>Vous êtes en noclip</font>", HTML_CHARTREUSE);
			
			if(StrContains(arg, "@", false) == -1 && target != client)
			{
				if(client > 0)
					rp_PrintToChat(client, "{green}%N {default}est maintenant en noclip.", target);
				else
					PrintToServer("[ADMIN] %N est maintenant en noclip.", target);
			}
		}
		else
		{
			SetEntityMoveType(target, MOVETYPE_WALK);
			ShowPanel2(target, 1, "<font color='%s'>Vous n'êtes plus en noclip</font>", HTML_CRIMSON);
			
			if(StrContains(arg, "@", false) == -1 && target != client)
			{
				if(client > 0)
					rp_PrintToChat(client, "{green}%N {default}n'est plus en noclip.", target);
				else
					PrintToServer("[ADMIN] %N n'est plus en noclip.", target);
			}
		}
	}
	
	/*int target = FindPlayer(client, arg, true);
	if(target == -1)
		return Plugin_Handled;
		
	LoopClients(i)
	{
		if(IsClientValid(target))
		{
			if(IsPlayerAlive(i) && IsValidEntity(i))
			{
				if(GetEntityMoveType(i) != MOVETYPE_NOCLIP)
				{
					SetEntityMoveType(i, MOVETYPE_NOCLIP);
					PrintHintText(i, "Noclip activé.");
					
					if(StrContains(arg, "@", false) == -1 && i != client)
					{
						if(client > 0)
							rp_PrintToChat(client, "{yellow}%N {default}est maintenant en noclip.", i);
						else
							PrintToServer("[ADMIN] %N est maintenant en noclip.", i);
					}
				}
				else
				{
					SetEntityMoveType(i, MOVETYPE_WALK);
					PrintHintText(i, "Noclip désactivé.");
					
					if(StrContains(arg, "@", false) == -1 && i != client)
					{
						if(client > 0)
							rp_PrintToChat(client, "{yellow}%N {default}n'est plus en noclip.", i);
						else
							PrintToServer("[ADMIN] %N n'est plus en noclip.", i);
					}
				}
			}
		}
	}*/
	
	return Plugin_Handled;
}

public Action Command_GetPos(int client, int args)
{
	#if DEBUG
		Translation_DebugCommand(client);
	#endif
	
	if(client == 0)
	{
		Translation_PrintNoAvailable();
		return Plugin_Handled;
	}
	
	if(rp_GetAdmin(client) == ADMIN_FLAG_NONE)
	{
		Translation_PrintNoAccess(client);
		return Plugin_Handled;
	}
	
	float position[3];
	PointVision(client, position);
	rp_PrintToChat(client, "{green}%f{default}, {green}%f{default}, {green}%f", position[0], position[1], position[2]);

	return Plugin_Handled;
}

public Action Command_Info(int client, int args)
{
	#if DEBUG
		Translation_DebugCommand(client);
	#endif
	
	if(client == 0)
	{
		Translation_PrintNoAvailable();
		return Plugin_Handled;
	}
	
	int target = GetClientAimTarget(client, false);
	if(rp_GetAdmin(client) == ADMIN_FLAG_NONE)
	{
		Translation_PrintNoAccess(client);
		return Plugin_Handled;
	}
	else if(!IsValidEntity(target))
	{
		//rp_PrintToChat(client, "%t", "%T", "InvalidTarget", LANG_SERVER);
		target = client;
		//return Plugin_Handled;
	}
	
	char entModel[256], entClass[128], entName[128];
	//GetEntityClassname(target, STRING(entClass));
	Entity_GetClassName(target, STRING(entClass));
	GetEntPropString(target, Prop_Data, "m_ModelName", entModel, 256);
	Entity_GetName(target, STRING(entName));
	float position[3], angles[3];
	GetEntPropVector(target, Prop_Send, "m_vecOrigin", position);
	GetEntPropVector(target, Prop_Data, "m_angRotation", angles); 
	int hammerID = Entity_GetHammerId(target);
	
	if(StrEqual(entName, ""))
		entName = "*aucun*";
	
	for(int i; i <= 2; i++)
	{
		if(angles[i] > 360.0)
			angles[i] -= 360.0;
		else if(angles[i] < 0.0)
			angles[i] = 0.0;
	}
	
	rp_PrintToChat(client, "Classname : {yellow}%s", entClass);
	PrintToConsole(client, "Classname : %s", entClass);
	rp_PrintToChat(client, "{default}Nom : {yellow}%s", entName);
	PrintToConsole(client, "Nom : %s", entName);
	rp_PrintToChat(client, "{default}Model : {yellow}%s", entModel);
	PrintToConsole(client, "Model : %s", entModel);
	rp_PrintToChat(client, "{default}ID : {yellow}%i", target);
	PrintToConsole(client, "ID : %i", target);
	rp_PrintToChat(client, "{default}Position : {yellow}%f, %f, %f", position[0], position[1], position[2]);
	PrintToConsole(client, "Position : %f, %f, %f", position[0], position[1], position[2]);
	rp_PrintToChat(client, "{default}Angle : {yellow}%f, %f, %f", angles[0], angles[1], angles[2]);
	PrintToConsole(client, "Angle : %f, %f, %f", angles[0], angles[1], angles[2]);
	rp_PrintToChat(client, "\x01Hammer ID : \x06%i", hammerID);
	PrintToConsole(client, "Hammer ID : %i", hammerID);
	
	if(target <= MaxClients)
	{
		int id = GetClientUserId(target);
		
		rp_PrintToChat(client, "{default}Steam ID : {yellow}%s", iData[target].SteamID);
		
		rp_PrintToChat(client, "{default}User ID : {yellow}%i", id);
		
		rp_PrintToChat(client, "{default}Argent : {yellow}%i$", rp_GetClientInt(target, i_Money));
		
		rp_PrintToChat(client, "{default}Banque : {yellow}%i$", rp_GetClientInt(target, i_Bank));
		
		char skintarget[128];
		rp_GetClientString(target, sz_Skin, STRING(skintarget));
		rp_PrintToChat(client, "{default}Skin : {yellow}%s", skintarget);
		
		rp_PrintToChat(client, "{default}Admin : {yellow}%i", rp_GetAdmin(client));
		
		rp_PrintToChat(client, "{default}VIP : {yellow}%i", rp_GetClientBool(client, b_IsVip));

		rp_PrintToChat(client, "{darkred}************{orange}MALADIES{darkred}************");		
		if(rp_GetClientSick(target, sick_type_covid))
			rp_PrintToChat(client, "{darkred}* {green} Covid-19");
		if(rp_GetClientSick(target, sick_type_fever))
			rp_PrintToChat(client, "{darkred}* {green} Fièvre");
		if(rp_GetClientSick(target, sick_type_plague))
			rp_PrintToChat(client, "{darkred}* {green} Peste");	
		rp_PrintToChat(client, "{darkred}*********************************");		

		rp_PrintToChat(client, "{darkred}************{orange}CHIRURGIES{darkred}************");		
		if(rp_GetClientSurgery(target, surgery_heart))
			rp_PrintToChat(client, "{darkred}* {green} Coeur");
		if(rp_GetClientSurgery(target, surgery_legs))
			rp_PrintToChat(client, "{darkred}* {green} Jambes");
		if(rp_GetClientSurgery(target, surgery_liver))
			rp_PrintToChat(client, "{darkred}* {green} Foie");
		if(rp_GetClientSurgery(target, surgery_lung))
			rp_PrintToChat(client, "{darkred}* {green} Poumons");	
		rp_PrintToChat(client, "{darkred}*********************************");	
	}
	
	return Plugin_Handled;
}

public Action Command_Collision(int client, int args)
{
	#if DEBUG
		Translation_DebugCommand(client);
	#endif
	
	if(client == 0)
	{
		Translation_PrintNoAvailable();
		return Plugin_Handled;
	}
	
	int target = GetClientAimTarget(client, false);
	if(rp_GetAdmin(client) == ADMIN_FLAG_NONE)
	{
		Translation_PrintNoAccess(client);
		return Plugin_Handled;
	}
	else if(!IsValidEntity(target))
	{
		target = client;
	}
	
	char arg[8];
	GetCmdArg(1, STRING(arg));
	
	SetEntProp(target, Prop_Data, "m_CollisionGroup", StringToInt(arg));
	
	return Plugin_Handled;
}

public Action Command_Physics(int client, int args)
{
	if(client == 0)
	{
		Translation_PrintNoAvailable();
		return Plugin_Handled;
	}
	
	int target = GetClientAimTarget(client, false);
	if(rp_GetAdmin(client) == ADMIN_FLAG_NONE)
	{
		Translation_PrintNoAccess(client);
		return Plugin_Handled;
	}
	else if(!IsValidEntity(target))
	{
		target = client;
	}
	
	char arg[8];
	GetCmdArg(1, STRING(arg));
	
	SetEntProp(target, Prop_Data, "m_nSolidType", StringToInt(arg));
	
	return Plugin_Handled;
}

public Action Command_TPA(int client, int args)
{
	#if DEBUG
		Translation_DebugCommand(client);
	#endif
	
	if(client == 0)
	{
		Translation_PrintNoAvailable();
		return Plugin_Handled;
	}
	else if (args < 1)
	{
		rp_PrintToChat(client, "Utilisation: !rp_tpa <target>");
		return Plugin_Handled;
	}
	else if(rp_GetAdmin(client) == ADMIN_FLAG_NONE)
	{
		Translation_PrintNoAccess(client);
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

	float origin[3];
	if(IsClientValid(target, true))
	{
		GetClientAbsOrigin(target, origin);	
		rp_PrintToChat(client, "Vous vous êtes téléporté à %N", target);	
	}
	
	origin[2] += 72.0;
	TeleportEntity(client, origin, NULL_VECTOR, NULL_VECTOR);
	rp_Sound(client, "sound_teleport", 1.0);
	
	return Plugin_Handled;
}

public Action Command_TP(int client, int args)
{
	#if DEBUG
		Translation_DebugCommand(client);
	#endif
	
	if(client == 0)
	{
		Translation_PrintNoAvailable();
		return Plugin_Handled;
	}
	else if (args < 1)
	{
		rp_PrintToChat(client, "Utilisation: !rp_tp <target>");
		return Plugin_Handled;
	}
	else if(rp_GetAdmin(client) == ADMIN_FLAG_NONE)
	{
		Translation_PrintNoAccess(client);
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
	
	float origin[3];
	PointVision(client, origin);
	origin[2] += 2.0;
	
	if(IsClientValid(target, true))
	{
		TeleportEntity(target, origin, NULL_VECTOR, NULL_VECTOR);
		if(target != client)
			rp_PrintToChat(target, "Vous avez été téléporté.");
			
		rp_Sound(client, "sound_teleport", 1.0);
		rp_Sound(target, "sound_teleport", 1.0);
		
		rp_PrintToChat(client, "Vous avez téléporté {green}%N{default}.", target);
	}
	
	return Plugin_Handled;
}

public Action Command_Reboot(int client, int args)
{
	#if DEBUG
		Translation_DebugCommand(client);
	#endif
	
	if(rp_GetAdmin(client) == ADMIN_FLAG_NONE && client != 0)
	{
		Translation_PrintNoAccess(client);
		return Plugin_Handled;
	}
	
	char buffer[16];
	GetCmdArg(1, STRING(buffer));
	
	if(!StrEqual(buffer, ""))
	{
		if(!String_IsNumeric(buffer))
		{
			rp_PrintToChat(client, "Le temps doit être précisée en chiffre !");
			return Plugin_Handled;
		}
		
		float time = StringToFloat(buffer);
		g_fTimerRebootCount = time;
		g_hTimerReboot = CreateTimer(time, Timer_ChangeMap, TIMER_FLAG_NO_MAPCHANGE);
		rp_PrintToChatAll("{darkred}Redémarrage de la map dans {green}%0.1f {default}secondes.", time);
	}	
	else
	{
		Call_StartForward(Forward.OnReboot);
		Call_Finish();
		
		char map[64];
		rp_GetCurrentMap(STRING(map));
		ServerCommand("sm_map %s", map);
		rp_PrintToChatAll("{darkred}Redémarrage de la map {default}-> {green} %s", map);
		ShowPanel2(client, 2, "<font color='%s'>Redémarrage de la map</font>", HTML_CRIMSON);
		rp_LogToDiscord("REBOOT");
	}	
	return Plugin_Handled;
}

public void RP_TimerEverySecond()
{
	if(g_fTimerRebootCount > 0.0)
	{
		g_fTimerRebootCount--;
		rp_SoundAll(SOUND_FROM_PLAYER, "sound_notif", 1.0);
		ShowPanel2(0, 2, "Redémarrage dans <font color='%s'>%0.1f</font>", HTML_DARKGREEN, g_fTimerRebootCount);
	}
}

public Action Timer_ChangeMap(Handle timer)
{
	Call_StartForward(Forward.OnReboot);
	Call_Finish();
	
	char map[64];
	rp_GetCurrentMap(STRING(map));
	ServerCommand("sm_map %s", map);
	
	
	g_fTimerRebootCount = 0.0;
	rp_PrintToChatAll("{darkred}Redémarrage de la map {default}-> {green} %s", map);
	ShowPanel2(-1, 1, "<font color='%s'>Redémarrage de la map</font>", HTML_CRIMSON);
	rp_LogToDiscord("REBOOT");
	
	return Plugin_Handled;
}	

public Action Command_SaveOut(int client, int args)
{
	#if DEBUG
		Translation_DebugCommand(client);
	#endif
	
	if(client == 0)
	{
		Translation_PrintNoAvailable();
		return Plugin_Handled;
	}
	else if(rp_GetAdmin(client) == ADMIN_FLAG_NONE)
	{
		Translation_PrintNoAccess(client);
		return Plugin_Handled;
	}
	
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_MenuValidOut);
	menu.SetTitle("OUT - JOBS");
	
	for (int i = 1; i <= MAXJOBS; i++)
	{		
		char jobname[32], strMenu[128];
		rp_GetJobName(i, STRING(jobname));
		
		KeyValues kv = new KeyValues("Out");
	
		char sPath[PLATFORM_MAX_PATH], map[64];
		rp_GetCurrentMap(STRING(map));
		BuildPath(Path_SM, STRING(sPath), "data/roleplay/%s/out.cfg", map);	
		Kv_CheckIfFileExist(kv, sPath);
	
		char tmp[8];
		IntToString(i, STRING(tmp));
		bool empty = false;
		
		if(kv.JumpToKey(tmp))
			empty = false;
		else
			empty = true;
		Format(STRING(strMenu), "%i", i);
		menu.AddItem(strMenu, jobname, (empty) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
		
		kv.Rewind();	
		delete kv;
	}

	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
	
	return Plugin_Handled;
}

public int Handle_MenuValidOut(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[64];
		menu.GetItem(param, STRING(info));
		
		KeyValues kv = new KeyValues("Out");
	
		char sPath[PLATFORM_MAX_PATH], map[64];
		rp_GetCurrentMap(STRING(map));
		BuildPath(Path_SM, STRING(sPath), "data/roleplay/%s/out.cfg", map);	
		Kv_CheckIfFileExist(kv, sPath);
	
		if(kv.JumpToKey(info, true))
		{
			float position[3];
			GetClientAbsOrigin(client, position);
			
			kv.SetVector("position", position);
			
			kv.GoBack();
			kv.Rewind();
			kv.ExportToFile(sPath);
			
			char jobname[64];
			rp_GetJobName(StringToInt(info), STRING(jobname));
			
			rp_PrintToChat(client, "%s [OUT] %s (%f %f %f)", jobname, position[0], position[1], position[2]);
		}	
		
		delete kv;
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if(param == MenuCancel_ExitBack)
			 Menu_Vip(client);
	}
	else if(action == MenuAction_End)
		delete menu;

	return 0;
}

public Action Command_SaveOutLocation(int client, int args)
{
	#if DEBUG
		Translation_DebugCommand(client);
	#endif
	
	if(client == 0)
	{
		Translation_PrintNoAvailable();
		return Plugin_Handled;
	}
	else if(rp_GetAdmin(client) == ADMIN_FLAG_NONE)
	{
		Translation_PrintNoAccess(client);
		return Plugin_Handled;
	}
	else if(GetCmdArgs() < 1)
	{
		rp_PrintToChat(client, "/rp_saveout <type>");
		return Plugin_Handled;
	}
	
	char arg[32]; // TYPE
	GetCmdArg(1, STRING(arg));
	
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_MenuSaveOutLocation);
	menu.SetTitle("OUT - LOCATION");
	
	KeyValues kv = new KeyValues("Locations");
	char sPath[PLATFORM_MAX_PATH], map[64];
	rp_GetCurrentMap(STRING(map));
	BuildPath(Path_SM, STRING(sPath), "data/roleplay/%s/locations.cfg", map);
	Kv_CheckIfFileExist(kv, sPath);	
	
	if(kv.JumpToKey(arg))
	{
		// Jump into the first subsection
		if (!kv.GotoFirstSubKey())
		{
			PrintToServer("ERROR FIRST KEY");
			delete kv;
			return Plugin_Handled;
		}
		
		char buffer[255];
		do
		{
			if(kv.GetSectionName(STRING(buffer)))
			{
				int id = StringToInt(buffer);
			
				char sTmp[16];
				kv.GetString("out", STRING(sTmp));
				
				bool empty;
				if(!StrEqual(sTmp, ""))
					empty = false;
				else 
					empty = true;

				char strIndex[128], strMenu[64];
				Format(STRING(strIndex), "%s|%i", arg, id);
				Format(STRING(strMenu), "%s %i", arg, id);
				menu.AddItem(strIndex, strMenu, (empty) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
			}
		}
		while (kv.GotoNextKey());
	}
	
	kv.Rewind();	
	delete kv;

	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
	
	return Plugin_Handled;
}

public int Handle_MenuSaveOutLocation(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[64], buffer[2][64];
		menu.GetItem(param, STRING(info));
		ExplodeString(info, "|", buffer, 2, 64);
		
		char sPath[PLATFORM_MAX_PATH], map[64];
		rp_GetCurrentMap(STRING(map));
		
		KeyValues kv = new KeyValues("Locations");
		BuildPath(Path_SM, STRING(sPath), "data/roleplay/%s/locations.cfg", map);	
		
		Kv_CheckIfFileExist(kv, sPath);
	
		if(kv.JumpToKey(buffer[0]))
		{
			if(kv.JumpToKey(buffer[1]))
			{
				float position[3];
				GetClientAbsOrigin(client, position);
				
				kv.SetVector("out", position);
				
				kv.GoBack();
				kv.Rewind();
				kv.ExportToFile(sPath);
				
				rp_PrintToChat(client, "[OUT-%s] %s (%f %f %f)", buffer[0], buffer[1], position[0], position[1], position[2]);
			}
		}
		
		kv.Rewind();
		delete kv;
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if(param == MenuCancel_ExitBack)
			 Menu_Vip(client);
	}
	else if(action == MenuAction_End)
		delete menu;

	return 0;
}

public Action Command_SaveSpawn(int client, int args)
{
	#if DEBUG
		Translation_DebugCommand(client);
	#endif
	
	if(client == 0)
	{
		Translation_PrintNoAvailable();
		return Plugin_Handled;
	}
	else if(rp_GetAdmin(client) == ADMIN_FLAG_NONE)
	{
		Translation_PrintNoAccess(client);
		return Plugin_Handled;
	}
	
	KeyValues kv = new KeyValues("Spawn");
	char sPath[PLATFORM_MAX_PATH], map[64];
	rp_GetCurrentMap(STRING(map));
	BuildPath(Path_SM, STRING(sPath), "data/roleplay/%s/spawn.cfg", map);	
	Kv_CheckIfFileExist(kv, sPath);
	
	if(kv.JumpToKey("job"))
	{
		rp_SetClientBool(client, b_DisplayHud, false);
		Menu menu = new Menu(Handle_MenuSaveSpawn);
		menu.SetTitle("SpawnJob");
		
		for (int i = 1; i <= MAXJOBS; i++)
		{		
			char jobname[32], strMenu[128];
			rp_GetJobName(i, STRING(jobname));
			
			Format(STRING(strMenu), "%i", i);
			menu.AddItem(strMenu, jobname);
		}
	
		menu.ExitButton = true;
		menu.Display(client, MENU_TIME_FOREVER);
	}
	
	kv.Rewind();	
	delete kv;
		
	return Plugin_Handled;
}

public int Handle_MenuSaveSpawn(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[64];
		menu.GetItem(param, STRING(info));
		//buffer[0] = jobid;
		//buffer[1] = position;
		
		KeyValues kv = new KeyValues("Spawn");
	
		char sPath[PLATFORM_MAX_PATH], map[64];
		rp_GetCurrentMap(STRING(map));
		BuildPath(Path_SM, STRING(sPath), "data/roleplay/%s/spawn.cfg", map);	
		Kv_CheckIfFileExist(kv, sPath);
	
		if(kv.JumpToKey("job"))
		{
			if(kv.JumpToKey(info, true))
			{
				float position[3];
				GetClientAbsOrigin(client, position);
				
				kv.SetVector("position", position);
				
				kv.GoBack();
				kv.Rewind();
				kv.ExportToFile(sPath);
				
				char jobname[64];
				rp_GetJobName(StringToInt(info), STRING(jobname));
				
				rp_PrintToChat(client, "[SPAWN] %s (%f %f %f)", jobname, position[0], position[1], position[2]);
			}
		}
			
		delete kv;
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if(param == MenuCancel_ExitBack)
			 Menu_Vip(client);
	}
	else if(action == MenuAction_End)
		delete menu;

	return 0;
}

public Action Command_SaveSpawnLocation(int client, int args)
{
	#if DEBUG
		Translation_DebugCommand(client);
	#endif	
	
	if(client == 0)
	{
		Translation_PrintNoAvailable();
		return Plugin_Handled;
	}
	else if(rp_GetAdmin(client) == ADMIN_FLAG_NONE)
	{
		Translation_PrintNoAccess(client);
		return Plugin_Handled;
	}
	else if(GetCmdArgs() < 1)
	{
		rp_PrintToChat(client, "/rp_savespawnlocation <type>");
		return Plugin_Handled;
	}
	
	char arg[32]; // TYPE
	GetCmdArg(1, STRING(arg));
	
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_SaveSpawnLocation);
	menu.SetTitle("SPAWN - LOCATION");
	
	KeyValues kv = new KeyValues("Locations");
	char sPath[PLATFORM_MAX_PATH], map[64];
	rp_GetCurrentMap(STRING(map));
	BuildPath(Path_SM, STRING(sPath), "data/roleplay/%s/locations.cfg", map);
	Kv_CheckIfFileExist(kv, sPath);	
	
	if(kv.JumpToKey(arg))
	{
		if (!kv.GotoFirstSubKey())
		{
			PrintToServer("ERROR FIRST KEY");
			delete kv;
			return Plugin_Handled;
		}
		
		char sBuffer[8];
		do
		{
			if(kv.GetSectionName(STRING(sBuffer)))
			{
				int id = StringToInt(sBuffer);
				
				char strIndex[128], strMenu[64];
				Format(STRING(strIndex), "%s|%i", arg, id);
				Format(STRING(strMenu), "%s %i", arg, id);
				menu.AddItem(strIndex, strMenu);
			}
			//kv.GoBack();
		} 
		while (kv.GotoNextKey());
	}
	kv.Rewind();	
	delete kv;
	
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
	
	return Plugin_Handled;
}

public int Handle_SaveSpawnLocation(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[64], buffer[2][64];
		menu.GetItem(param, STRING(info));
		ExplodeString(info, "|", buffer, 2, 64);
		//buffer[0] = type;
		//buffer[1] = id;
		
		KeyValues kv = new KeyValues("Locations");
	
		char sPath[PLATFORM_MAX_PATH], map[64];
		rp_GetCurrentMap(STRING(map));
		BuildPath(Path_SM, STRING(sPath), "data/roleplay/%s/locations.cfg", map);
		Kv_CheckIfFileExist(kv, sPath);
	
		if(kv.JumpToKey(buffer[0]))
		{
			if(kv.JumpToKey(buffer[1]))
			{
				float position[3];
				GetClientAbsOrigin(client, position);
				
				kv.SetVector("spawn", position);
				
				kv.GoBack();
				kv.Rewind();
				kv.ExportToFile(sPath);
				
				rp_PrintToChat(client, "[SPAWN-%s] %s (%f %f %f)", buffer[0], buffer[1], position[0], position[1], position[2]);
			}
		}	
		
		kv.Rewind();
		delete kv;
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if(param == MenuCancel_ExitBack)
			 Menu_Vip(client);
	}
	else if(action == MenuAction_End)
		delete menu;

	return 0;
}

public Action Command_SetLocationPrice(int client, int args)
{
	#if DEBUG
		Translation_DebugCommand(client);
	#endif	
	
	if(client == 0)
	{
		Translation_PrintNoAvailable();
		return Plugin_Handled;
	}
	else if(rp_GetAdmin(client) == ADMIN_FLAG_NONE)
	{
		Translation_PrintNoAccess(client);
		return Plugin_Handled;
	}
	else if(GetCmdArgs() < 3)
	{
		rp_PrintToChat(client, "/rp_setlocationprice <type> <id> <price>");
		return Plugin_Handled;
	}
	
	char arg[32]; // TYPE
	GetCmdArg(1, STRING(arg));
	
	char arg2[8]; // ID
	GetCmdArg(2, STRING(arg2));
	
	char arg3[8]; // PRICE
	GetCmdArg(3, STRING(arg3));
	
	KeyValues kv = new KeyValues("Locations");
	char sPath[PLATFORM_MAX_PATH], map[64];
	rp_GetCurrentMap(STRING(map));
	BuildPath(Path_SM, STRING(sPath), "data/roleplay/%s/locations.cfg", map);
	Kv_CheckIfFileExist(kv, sPath);	
	
	if(kv.JumpToKey(arg))
	{
		if(kv.JumpToKey(arg2))
		{
			if(StrEqual(arg, "appartment"))
				rp_SetAppartementInt(StringToInt(arg2), appart_price, StringToInt(arg3));
			else if(StrEqual(arg, "villa"))
				rp_SetVillaInt(StringToInt(arg2), villa_price, StringToInt(arg3));
			else if(StrEqual(arg, "hotel"))
				rp_SetHotelInt(StringToInt(arg2), hotel_price, StringToInt(arg3));
			
			kv.SetString("price", arg3);
			kv.GoBack();
			kv.Rewind();
			kv.ExportToFile(sPath);
		}
	}

	kv.Rewind();
	delete kv;
	
	return Plugin_Handled;
}

public Action Command_SaveBox(int client, int args)
{
	#if DEBUG
		Translation_DebugCommand(client);
	#endif
	
	if(client == 0)
	{
		Translation_PrintNoAvailable();
		return Plugin_Handled;
	}
	else if (args < 2)
	{
		rp_PrintToChat(client, "Utilisation: !rp_savebox <type> <id>");
		return Plugin_Handled;
	}
	else if(rp_GetAdmin(client) == ADMIN_FLAG_NONE)
	{
		Translation_PrintNoAccess(client);
		return Plugin_Handled;
	}
	
	char arg[32]; // TYPE
	GetCmdArg(1, STRING(arg));
	
	char arg2[8]; // ID
	GetCmdArg(2, STRING(arg2));
	
	KeyValues kv = new KeyValues("Locations");
	char sPath[PLATFORM_MAX_PATH], map[64];
	rp_GetCurrentMap(STRING(map));
	BuildPath(Path_SM, STRING(sPath), "data/roleplay/%s/locations.cfg", map);	
	Kv_CheckIfFileExist(kv, sPath);

	if(kv.JumpToKey(arg))
	{
		if(kv.JumpToKey(arg2))
		{
			if(kv.JumpToKey("box"))
			{
				float position[3], angle[3];
				GetClientAbsOrigin(client, position);
				GetClientAbsAngles(client, angle);
				
				kv.SetVector("position", position);
				kv.SetVector("angle", angle);
				
				kv.GoBack();
				kv.Rewind();
				kv.ExportToFile(sPath);
				
				CPrintToChat(client, "[SaveBox] %s: %s (%f %f %f)", arg, arg2, position[0], position[1], position[2]);
			}
		}
	}	
	
	kv.Rewind();
	delete kv;	
	
	return Plugin_Handled;
}

public Action Command_SaveTesla(int client, int args)
{
	#if DEBUG
		Translation_DebugCommand(client);
	#endif
	
	if(client == 0)
	{
		Translation_PrintNoAvailable();
		return Plugin_Handled;
	}
	else if (args < 1)
	{
		rp_PrintToChat(client, "Utilisation: !rp_savetesla <id>");
		return Plugin_Handled;
	}
	else if(rp_GetAdmin(client) == ADMIN_FLAG_NONE)
	{
		Translation_PrintNoAccess(client);
		return Plugin_Handled;
	}
	
	char buffer[16];
	GetCmdArg(1, STRING(buffer));
	
	if(!String_IsNumeric(buffer))
	{
		rp_PrintToChat(client, "L'argument doit être précisée en chiffre !");
		return Plugin_Handled;
	}
	else
	{
		if(StringToInt(buffer) < 1 && StringToInt(buffer) > MAXTESLA)
		{
			rp_PrintToChat(client, "L'argument doit être précisée en chiffre entre 1 et %i !", MAXTESLA);
			return Plugin_Handled;
		}		
	}
	
	KeyValues kv = new KeyValues("Tesla");
	
	char sPath[PLATFORM_MAX_PATH], map[64];
	rp_GetCurrentMap(STRING(map));
	BuildPath(Path_SM, STRING(sPath), "data/roleplay/%s/point_tesla.cfg", map);	
	Kv_CheckIfFileExist(kv, sPath);

	if(kv.JumpToKey(buffer, true))
	{
		float position[3];
		GetClientAbsOrigin(client, position);
		
		kv.SetVector("position", position);
		
		kv.GoBack();
		kv.Rewind();
		kv.ExportToFile(sPath);
		
		rp_PrintToChat(client, "[PointTesla] Numéro: %i (%f %f %f)", StringToInt(buffer), position[0], position[1], position[2]);
	}
	
	delete kv;	
	return Plugin_Handled;
}

public Action Command_Kick(int client, int args)
{
	#if DEBUG
		Translation_DebugCommand(client);
	#endif
	
	if(client == 0)
	{
		Translation_PrintNoAvailable();
		return Plugin_Handled;
	}
	else if (args < 2)
	{
		rp_PrintToChat(client, "Utilisation: !rp_kick <target> <raison>");
		return Plugin_Handled;
	}
	else if(rp_GetAdmin(client) == ADMIN_FLAG_NONE)
	{
		Translation_PrintNoAccess(client);
		return Plugin_Handled;
	}

	char arg[64], raison[128];
	GetCmdArg(1, STRING(arg));
	GetCmdArg(2, STRING(raison));
	
	int target = FindTarget(client, arg, true);
	if (target <= COMMAND_TARGET_NONE)
	{
		ReplyToTargetError(client, target);
		return Plugin_Handled;
	}

	if(target == client)
	{
		rp_PrintToChat(client, "Impossible de se kick sois-même.");
		return Plugin_Handled;
	}	
		
	if(IsBenito(target))
	{
		KickClientEx(client, "!!! Impossible de kick Benito");
	}	
	
	if(rp_GetAdmin(client) < rp_GetAdmin(target))
	{
		rp_PrintToChat(client, "{lightred}Attention{default}, cette personne est supérieur à vous.");
		return Plugin_Handled;
	}		
	
	if(IsClientValid(target))
		KickClientEx(target, raison);
		
	char message[128];
	Format(STRING(message), "@here %N a kick %N pour %s.", client, target, raison);	
	rp_LogToDiscord(message);	
	
	return Plugin_Handled;
}

public Action Command_Ban(int client, int args)
{
	#if DEBUG
		Translation_DebugCommand(client);
	#endif
	
	if (args < 3)
	{
		rp_PrintToChat(client, "Utilisation: !rp_ban <target> <time> <raison>");
		return Plugin_Handled;
	}
	else if(rp_GetAdmin(client) == ADMIN_FLAG_NONE)
	{
		Translation_PrintNoAccess(client);
		return Plugin_Handled;
	}

	char arg[64], time[32], raison[128];
	GetCmdArg(1, STRING(arg));
	GetCmdArg(2, STRING(time));
	GetCmdArg(3, STRING(raison));
	
	if(!String_IsNumeric(time))
	{
		if(IsClientValid(client))
			rp_PrintToChat(client, "Le temps doit être précisée en chiffre !");
		else
			PrintToServer("Le temps doit être précisée en chiffre !");
		return Plugin_Handled;
	}
	
	int target = FindTarget(client, arg, true);
	if (target <= COMMAND_TARGET_NONE)
	{
		ReplyToTargetError(client, target);
		return Plugin_Handled;
	}
	
	if(IsClientValid(target))
	{
		if(target == client)
		{
			rp_PrintToChat(client, "Impossible de se ban sois-même.");
			return Plugin_Handled;
		}		
		
		if(IsBenito(target))
		{
			rp_PrintToChat(client, "Impossible de ban Benito");
			return Plugin_Handled;
		}	
			
		if(rp_GetAdmin(client) < rp_GetAdmin(target))
		{
			rp_PrintToChat(client, "{lightred}Attention{default}, cette personne est supérieur à vous.");
			return Plugin_Handled;
		}		
		
		rp_BanClient(g_DB, client, target, StringToInt(time), STRING(raison));
	}
	
	return Plugin_Handled;
}

public Action Command_Slay(int client, int args)
{
	#if DEBUG
		Translation_DebugCommand(client);
	#endif
	
	if (args < 2)
	{
		rp_PrintToChat(client, "Utilisation: !rp_slay <target> <raison>");
		return Plugin_Handled;
	}
	else if(rp_GetAdmin(client) == ADMIN_FLAG_NONE)
	{
		Translation_PrintNoAccess(client);
		return Plugin_Handled;
	}

	char arg[64], raison[128];
	GetCmdArg(1, STRING(arg));
	GetCmdArg(2, STRING(raison));
	
	int target = FindTarget(client, arg, true);
	if (target <= COMMAND_TARGET_NONE)
	{
		ReplyToTargetError(client, target);
		return Plugin_Handled;
	}

	if(IsClientValid(target, true))
	{
		if(rp_GetAdmin(client) < rp_GetAdmin(target))
		{
			rp_PrintToChat(client, "{lightred}Attention{default}, cette personne est supérieur à vous.");
			return Plugin_Handled;
		}		
		
		rp_Slay(target);
		if(strlen(raison) != 0)
			rp_PrintToChat(target, "Vous avez été slay par {lightgreen}%N {default}pour {lightred}%s{default}.", client, raison);
		else
			rp_PrintToChat(target, "Vous avez été slay par {lightgreen}%s{default}.", client);			
	}
	
	return Plugin_Handled;
}

public Action Command_Freeze(int client, int args)
{
	#if DEBUG
		Translation_DebugCommand(client);
	#endif
	
	if (args < 1)
	{
		rp_PrintToChat(client, "Utilisation: !rp_freeze <target>");
		return Plugin_Handled;
	}
	else if(rp_GetAdmin(client) == ADMIN_FLAG_NONE)
	{
		Translation_PrintNoAccess(client);
		return Plugin_Handled;
	}

	char arg[64];
	GetCmdArg(1, STRING(arg));
	
	int target = FindTarget(client, arg, true);
	if (target <= COMMAND_TARGET_NONE)
	{
		ReplyToTargetError(client, target);
		return Plugin_Handled;
	}

	if(IsClientValid(target))
	{
		if(GetEntityMoveType(target) != MOVETYPE_NONE)
		{
			SetEntityMoveType(target, MOVETYPE_NONE);
			rp_PrintToChat(client, "Vous avez freeze {green}%N{default}.", target);
			rp_PrintToChat(target, "Vous avez été freeze par {green}%N{default}.", client);
		}	
		else
		{
			SetEntityMoveType(target, MOVETYPE_WALK);
			rp_PrintToChat(client, "Vous avez défreeze {green}%N{default}.", target);
			rp_PrintToChat(target, "Vous avez été défreeze par {green}%N{default}.", client);
		}								
	}
	
	return Plugin_Handled;
}

public Action Command_Skin(int client, int args)
{
	#if DEBUG
		Translation_DebugCommand(client);
	#endif
	
	if (args < 2)
	{
		rp_PrintToChat(client, "Utilisation: !rp_skin <target> <playermodel> <armsmodel>");
		return Plugin_Handled;
	}
	else if(rp_GetAdmin(client) == ADMIN_FLAG_NONE)
	{
		Translation_PrintNoAccess(client);
		return Plugin_Handled;
	}

	char arg[64], model[256], arms[256];
	GetCmdArg(1, STRING(arg));
	GetCmdArg(2, STRING(model));
	GetCmdArg(3, STRING(arms));
	
	int target = FindTarget(client, arg, true);
	if (target <= COMMAND_TARGET_NONE)
	{
		ReplyToTargetError(client, target);
		return Plugin_Handled;
	}

	if(IsClientValid(target))
	{
		PrecacheAndSetModel(target, model);
		if(strlen(arms) != 0)
			PrecacheAndSetArms(target, arms);
	}
	
	return Plugin_Handled;
}

public Action Command_RemoveFromWorld(int client, int args)
{
	#if DEBUG
		Translation_DebugCommand(client);
	#endif
	
	if(rp_GetAdmin(client) == ADMIN_FLAG_NONE)
	{
		Translation_PrintNoAccess(client);
		return Plugin_Handled;
	}

	char arg[64];
	GetCmdArg(1, STRING(arg));
	
	LoopEntities(i)
	{
		if(!IsValidEntity(i))
			continue;
			
		char entClass[64];
		Entity_GetClassName(i, STRING(entClass));
		
		if(StrEqual(entClass, arg))
			RemoveEdict(i);
	}
	
	return Plugin_Handled;
}	

public Action Command_Remove(int client, int args)
{
	#if DEBUG
		Translation_DebugCommand(client);
	#endif	
	
	int target = GetClientAimTarget(client, false);
	if(rp_GetAdmin(client) == ADMIN_FLAG_NONE)
	{
		Translation_PrintNoAccess(client);
		return Plugin_Handled;
	}
	else if(!IsValidEntity(target))
	{
		Translation_PrintInvalidTarget(client);
		return Plugin_Handled;
	}
	else if (Distance(client, target) > 1000.0)
	{
		Translation_PrintTooFar(client);
		return Plugin_Handled;
	}
	
	char strIndex[64], entClass[128], entModel[256];
	Entity_GetClassName(target, STRING(entClass));
	Entity_GetModel(target, STRING(entModel));
	
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_MenuRemove);
	if (StrEqual(entClass, "prop_vehicle_driveable"))
	{
		menu.SetTitle("Voulez-vous supprimer cette voiture ?");
		
		Format(STRING(strIndex), "voiture|%d", target);
		menu.AddItem(strIndex, "Oui");
		
		menu.AddItem("", "Non");
	}
	else if (StrContains(entClass, "player") != -1)
		return Plugin_Handled;
	else
	{
		menu.SetTitle("Voulez-vous supprimer\n%s\n%s ?", entClass, entModel);
		
		Format(STRING(strIndex), "oui|%d", target);
		menu.AddItem(strIndex, "Oui");
		
		menu.AddItem("", "Non");
	}
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
	
	return Plugin_Handled;
}

public int Handle_MenuRemove(Menu menu, MenuAction action, int client, int param)
{
	if (action == MenuAction_Select)
	{
		char info[32];
		menu.GetItem(param, info, sizeof(info));
		
		char buffer[2][16], entClass[64], message[128];
		ExplodeString(info, "|", buffer, 2, 16);
		int target = StringToInt(buffer[1]);
		GetEntityClassname(target, entClass, sizeof(entClass));
		
		if (StrEqual(buffer[0], "oui"))
		{
			if (IsValidEntity(target))
			{
				RemoveEdict(target);
				rp_PrintToChat(client, "Prop {lightred}supprimé{default}.");
			}
		}
		else if (StrEqual(buffer[0], "voiture"))
		{
			if (IsClientValid(Vehicle_GetDriver(target)))
				Vehicles_ExitPassenger(target);
			
			AcceptEntityInput(target, "TurnOff");
			AcceptEntityInput(target, "ClearParent");
			AcceptEntityInput(target, "Kill");
		}
		
		Format(STRING(message), "[PROPS] %N a supprime %s.", client, entClass);
		rp_LogToDiscord(message);
	}
	else if (action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if(param == MenuCancel_ExitBack)
			FakeClientCommand(client, "say !rp_admin");
	}
	else if (action == MenuAction_End)
		delete menu;
		
	return 0;
}

void Menu_Props(int client)
{
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_MenuProps);
	menu.SetTitle("=== ADMIN === -> Props");
	
	menu.AddItem("", "═══✴ PLANTES ✴═══", ITEMDRAW_DISABLED);
	menu.AddItem("models/agency/electrical/tower.mdl", "Ordinateur");
	
	menu.AddItem("", "═══✴ CONSTRUCTION ✴═══", ITEMDRAW_DISABLED);
	menu.AddItem("models/props_fortifications/orange_cone001_reference.mdl", "Petit Plot");
	menu.AddItem("models/props/cs_office/rolling_gate.mdl", "Grande porte grillagée");
	menu.AddItem("models/props/de_nuke/nuclearcontainerboxclosed.mdl", "Boite en carton");
	menu.AddItem("models/props_office/file_cabinet_03.mdl", "Casier de rangement");
	menu.AddItem("models/props_office/desk_01.mdl", "Bureau");
	menu.AddItem("models/props_interiors/chair_office2.mdl", "Chaise de bureau");
	menu.AddItem("models/props/cs_assault/box_stack1.mdl", "Caisse de boites en carton");
	menu.AddItem("models/props/cs_assault/forklift_new.mdl", "Transpalette");
	menu.AddItem("models/props/cs_assault/moneypallet02.mdl", "Palette de billets");
	menu.AddItem("models/props/cs_assault/pylon.mdl", "Plot jaune");
	menu.AddItem("models/props/cs_militia/crate_extrasmallmill.mdl", "Caisse en bois (1)");
	menu.AddItem("models/props/cs_office/crate_office_indoor_64.mdl", "Caisse en bois (2)");
	menu.AddItem("models/props/cs_militia/militiarock03.mdl", "Rocher (1)");
	menu.AddItem("models/props/cs_militia/militiarock06.mdl", "Rocher (2)");
	menu.AddItem("models/props/cs_office/table_meeting.mdl", "Table de réunion");
	menu.AddItem("models/props/cs_militia/haybale_target.mdl", "Cible de tir n°1");
	menu.AddItem("models/props/cs_militia/haybale_target_02.mdl", "Cible de tir n°2");
	menu.AddItem("models/props/cs_militia/haybale_target_03.mdl", "Cible de tir n°3");
	menu.AddItem("models/props/de_boathouse/boat_inflatable01.mdl", "Bateau n°1");
	menu.AddItem("models/props/de_shacks/boat_smash.mdl", "Bateau n°2");
	menu.AddItem("models/props/de_cbble/cobble_flagpole.mdl", "Drapeau");
	
	menu.ExitBackButton = true;
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Handle_MenuProps(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[256];
		menu.GetItem(param, STRING(info));
		
		PrecacheModel(info, true);
		int ent = CreateEntityByName("prop_dynamic_override");
		DispatchKeyValue(ent, "solid", "6");
		DispatchKeyValue(ent, "model", info);
		DispatchSpawn(ent);
		PrecacheSound("weapons/stunstick/stunstick_fleshhit1.wav", true);
		EmitSoundToAll("weapons/stunstick/stunstick_fleshhit1.wav", ent, 0, 70);
		
		float teleportOrigin[3], joueurOrigin[3];
		PointVision(client, joueurOrigin);
		teleportOrigin[0] = joueurOrigin[0];
		teleportOrigin[1] = joueurOrigin[1];
		teleportOrigin[2] = joueurOrigin[2];
		TeleportEntity(ent, teleportOrigin, NULL_VECTOR, NULL_VECTOR);
		
		Menu_Props(client);
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if(param == MenuCancel_ExitBack)
			FakeClientCommand(client, "say !rp_admin");
	}
	else if(action == MenuAction_End)
		delete menu;

	return 0;
}

void Menu_Mute(int client)
{
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_MenuMute);
	menu.SetTitle("=== ADMIN === -> MUTE");
	
	LoopClients(i)
	{
		if(!IsClientValid(i))
			continue;
			
		char name[64];
		GetClientName(i, STRING(name));
		menu.AddItem(name, name);	
	}

	menu.ExitBackButton = true;
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Handle_MenuMute(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[64], strIndex[64];
		menu.GetItem(param, STRING(info));
		
		rp_SetClientBool(client, b_DisplayHud, false);
	
		Menu menu1 = new Menu(Handle_MenuMuteType);
		menu1.SetTitle("=== MUTE === -> TYPE");
		
		Format(STRING(strIndex), "%s|global", info);
		menu1.AddItem(strIndex, "Global");
		
		Format(STRING(strIndex), "%s|local", info);
		menu1.AddItem(strIndex, "Local");
		
		Format(STRING(strIndex), "%s|voice", info);
		menu1.AddItem(strIndex, "Vocal");
		
		menu1.ExitBackButton = true;
		menu1.ExitButton = true;
		menu1.Display(client, MENU_TIME_FOREVER);
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if(param == MenuCancel_ExitBack)
			FakeClientCommand(client, "say !rp_admin");
	}
	else if(action == MenuAction_End)
		delete menu;
		
	return 0;
}

public int Handle_MenuMuteType(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[64], buffer[2][64];
		menu.GetItem(param, STRING(info));
		ExplodeString(info, "|", buffer, 2, 64);
		
		FakeClientCommand(client, "say !rp_mute %s %s", buffer[0], buffer[1]);	
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if(param == MenuCancel_ExitBack)
			Menu_Mute(client);
	}
	else if(action == MenuAction_End)
		delete menu;
		
	return 0;
}

public Action Command_SpawnProps(int client, int args)
{
	#if DEBUG
		Translation_DebugCommand(client);
	#endif
	
	if(rp_GetAdmin(client) == ADMIN_FLAG_NONE)
	{
		Translation_PrintNoAccess(client);
		return Plugin_Handled;
	}

	char type[64];
	GetCmdArg(1, STRING(type));
	
	char model[128];
	GetCmdArg(2, STRING(model));
	
	if(!StrEqual(model, ""))
	{
		float teleportOrigin[3];
		PointVision(client, teleportOrigin);
		
		PrecacheModel(model);
		int ent;
		if(StrEqual(type, "prop_dynamic") || StrEqual(type, "prop_dynamic_override"))
		{
			ent = CreateEntityByName(type);
			DispatchKeyValue(ent, "solid", "6");
			DispatchKeyValue(ent, "model", model);
			DispatchSpawn(ent);
			PrecacheSound("weapons/stunstick/stunstick_fleshhit1.wav", true);
			EmitSoundToAll("weapons/stunstick/stunstick_fleshhit1.wav", ent, 0, 70);
			TeleportEntity(ent, teleportOrigin, NULL_VECTOR, NULL_VECTOR);
		}	
		else if(StrEqual(type, "prop_physics") || StrEqual(type, "prop_physics_override"))
		{
			ent = rp_CreatePhysics("", teleportOrigin, NULL_VECTOR, model, 0, true);		
			PrecacheSound("weapons/stunstick/stunstick_fleshhit1.wav", true);
			EmitSoundToAll("weapons/stunstick/stunstick_fleshhit1.wav", ent, 0, 70);
		}
		else if(StrEqual(type, "prop_dynamic_glow"))
			ent = CreateGlow(model, "0 255 0");
			
		Entity_SetName(ent, "prop_admin|%i", client);	
	}	
	
	return Plugin_Handled;
}

public Action Command_GiveItem(int client, int args)
{
	#if DEBUG
		Translation_DebugCommand(client);
	#endif
	
	if(rp_GetAdmin(client) == ADMIN_FLAG_NONE)
	{
		Translation_PrintNoAccess(client);
		return Plugin_Handled;
	}

	char tmp[64];
	GetCmdArg(1, STRING(tmp));
	int item = StringToInt(tmp);
	
	char name[64];
	rp_GetItemData(item, item_name, STRING(name));
	rp_SetClientItem(client, item, rp_GetClientItem(client, item, false) + 1, false);
	rp_PrintToChat(client, "Vous vous êtes give: {lightgreen}%s{default}.", name);
	
	return Plugin_Handled;
}

public Action Command_SetName(int client, int args)
{
	#if DEBUG
		Translation_DebugCommand(client);
	#endif
	
	if(rp_GetAdmin(client) == ADMIN_FLAG_NONE)
	{
		Translation_PrintNoAccess(client);
		return Plugin_Handled;
	}

	char tmp[64];
	GetCmdArg(1, STRING(tmp));
	
	int target = GetClientAimTarget(client, false);
	Entity_SetName(target, tmp);
	
	return Plugin_Handled;
}

public Action Command_Aduty(int client, int args)
{
	#if DEBUG
		Translation_DebugCommand(client);
	#endif	
	
	if(rp_GetAdmin(client) == ADMIN_FLAG_NONE)
	{
		Translation_PrintNoAccess(client);
		return Plugin_Handled;
	}

	if(rp_GetClientBool(client, b_IsOnAduty))
	{
		rp_SetClientBool(client, b_IsOnAduty, false);
		rp_PrintToChat(client, "Vous avez désormais visible.");
		SetEntityMoveType(client, MOVETYPE_WALK);
		InvisibleOff(client);
	}
	else
	{
		rp_SetClientBool(client, b_IsOnAduty, true);
		rp_PrintToChat(client, "Vous êtes désormais invisible.");
		SetEntityMoveType(client, MOVETYPE_NOCLIP);
		InvisibleOn(client);
	}	
	
	return Plugin_Handled;
}

public Action Hook_SetTransmit(int entity, int client) 
{ 
	if (entity != client)
	{
		return Plugin_Handled;
	}
	
	return Plugin_Continue; 
}

/*
void Http_CheckIp(char[] ip, int client) 
{
	DataPack pack = new DataPack();
	pack.WriteString(ip);
	pack.WriteCell(GetClientUserId(client));

	char url[128];
	Format(STRING(url), "http://proxy.mind-media.com/block/proxycheck.php?ip=%s", ip);

	Handle CheckIp = SteamWorks_CreateHTTPRequest(k_EHTTPMethodGET, url);
	SteamWorks_SetHTTPCallbacks(CheckIp, HttpResponseCompleted, _, HttpResponseDataReceived);
	SteamWorks_SetHTTPRequestContextValue(CheckIp, pack);
	SteamWorks_SetHTTPRequestNetworkActivityTimeout(CheckIp, 5);
	SteamWorks_SendHTTPRequest(CheckIp);
}
public void Http_RequestData(const char[] content, DataPack pack) 
{
	char ip[64];
	pack.Reset();
	pack.ReadString(STRING(ip));
	int client = GetClientOfUserId(pack.ReadCell());
	delete pack;

	if (!IsClientValid(client)) 
		return;
		
	if (StrContains(content, "y", false) != -1) 
	{
		KickClient(client, "Interdiction d'utiliser un VPN.");
		
		char message[128];
		Format(STRING(message), "[VPN - AGENT] VPN Detecté et kick du joueur %N", client);
		rp_LogToDiscord(message);
	}
}

public void HttpResponseDataReceived(Handle request, bool failure, int offset, int bytesReceived, DataPack pack) 
{
	SteamWorks_GetHTTPResponseBodyCallback(request, Http_RequestData, pack);
	delete request;
}

public int HttpResponseCompleted(Handle request, bool failure, bool requestSuccessful, EHTTPStatusCode statusCode, DataPack pack) 
{
	if(failure || !requestSuccessful) 
	{
		#if DEBUG
			PrintToServer("[RP - VPN] Check Effectue avec succes.");
		#endif
		delete pack;
		delete request;
	}
}*/

void InvisibleOn(int client)
{
	if(IsClientValid(client))
	{
		int weaponID;
		for(int i; i < 6; i++)
		{
			if(i < 6 && (weaponID = GetPlayerWeaponSlot(client, i)) != -1) 
			{
				if(IsValidEntity(weaponID))
					SetEntityRenderMode(weaponID, RENDER_NONE);
			}
		}
		
		if(IsValidEntity(client) && IsPlayerAlive(client))
		{
			SDKHook(client, SDKHook_SetTransmit, Hook_SetTransmit);
			SetEntProp(client, Prop_Send, "m_bSpotted", 0);
		}
	}
}

void InvisibleOff(int client)
{
	if(IsClientValid(client))
	{
		int weapon;
		for(int i; i < 6; i++)
		{
			if((weapon = GetPlayerWeaponSlot(client, i)) != -1)  
			{
				if(IsValidEntity(weapon))
					SetEntityRenderMode(weapon, RENDER_NORMAL);
			}
		}
		
		if(IsValidEntity(client) && IsPlayerAlive(client))
		{
			SDKUnhook(client, SDKHook_SetTransmit, Hook_SetTransmit);
			SetEntProp(client, Prop_Send, "m_bSpotted", 1);
		}
	}
}