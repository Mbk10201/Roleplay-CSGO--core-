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

							P L U G I N  -  I N C L U D E S

***************************************************************************************/
#include <roleplay_csgo.inc>

#define JOBID 5

/***************************************************************************************

							G L O B A L  -  V A R S

***************************************************************************************/
char steamID[MAXPLAYERS + 1][32];

enum tribunal_type {
	tribunal_steamid = 0,
	tribunal_duration,
	tribunal_code,
	tribunal_option,
	
	tribunal_max
}
enum struct tribunal_data 
{
	int tribunal_search_status;
	int tribunal_search_starttime;
}

tribunal_data g_TribunalSearch[MAXPLAYERS + 1];
char g_szTribunal_DATA[65][tribunal_max][64];

Database g_DB;

/***************************************************************************************

							P L U G I N  -  I N F O

***************************************************************************************/
public Plugin myinfo = 
{
	name = "Roleplay - [JOB] Justice", 
	author = "MBK", 
	description = "", 
	version = "1.0", 
	url = "https://github.com/Mbk10201"
};

/***************************************************************************************

							P L U G I N  -  E V E N T S

***************************************************************************************/
public void OnPluginStart()
{
	LoadTranslation();
	
	RegConsoleCmd("tribunal", Cmd_Tribunal);
	RegConsoleCmd("conv", Cmd_Conv);
	RegConsoleCmd("convoquer", Cmd_Conv);	
	RegConsoleCmd("jugement", Cmd_Jugement);	
	RegConsoleCmd("avocat", Cmd_Avocat);
}

// Init SQL
public void RP_OnSQLInit(Database db)
{
	g_DB = db;
}

/***************************************************************************************

									C L I E N T - S I D E

***************************************************************************************/

public void OnClientPostAdminCheck(int client) 
{
	g_TribunalSearch[client].tribunal_search_status = -1;
}

public void OnClientAuthorized(int client, const char[] auth) 
{	
	strcopy(steamID[client], sizeof(steamID[]), auth);
}

public void RP_OnClientJob(Menu menu, int client)
{
	if (rp_GetClientInt(client, i_Job) == 7)
	{
		menu.AddItem("avisrecherche", "Avis de recherche");
		menu.AddItem("enquete", "Ouvrir un dossier");
	}
}	

public void RP_OnClientJobHandle(int client, const char[] info)
{
	if (StrEqual(info, "enquete"))
		MenuEnquete(client);
}	

/***************************************************************************************

									C A L L B A C K

***************************************************************************************/

void MenuEnquete(int client)
{
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(DoMenuEnquete);
	menu.SetTitle("Quel dossier voulez-vous ?");
	
	LoopClients(i)
	{
		if(!IsClientValid(i))
			continue;
		
		char name[32], strI[8];
		IntToString(i, STRING(strI));
		GetClientName(i, STRING(name));
		
		if (rp_GetClientInt(i, i_Job) == 2 && rp_GetClientInt(i, i_Grade) == 1)
			menu.AddItem("", name, ITEMDRAW_DISABLED);
		else 
			menu.AddItem(strI, name);
	}
	
	menu.ExitBackButton = true;
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int DoMenuEnquete(Menu menu, MenuAction action, int client, int param)
{
	if (action == MenuAction_Select)
	{
		char info[64], strFormat[64];
		menu.GetItem(param, STRING(info));
		int id = StringToInt(info);
		
		rp_SetClientBool(client, b_DisplayHud, false);
		Menu menu1 = new Menu(DoMenuEnqueteFinal);
		menu1.SetTitle("Dossier de %N :", id);
		
		Format(STRING(strFormat), "Karma : %f", rp_GetClientFloat(id, fl_Vitality));
		menu1.AddItem("", strFormat, ITEMDRAW_DISABLED);
		
		menu1.ExitBackButton = true;
		menu1.ExitButton = true;
		menu1.Display(client, MENU_TIME_FOREVER);
	}
	else if (action == MenuAction_Cancel)
	{
		if (param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		//else if (param == MenuCancel_ExitBack)
			//MenuGererMetier(client);
	}
	else if (action == MenuAction_End)
		delete menu;
	
	return 0;
}

public int DoMenuEnqueteFinal(Menu menu1, MenuAction action, int client, int param)
{
	if (action == MenuAction_Cancel)
	{
		if (param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if (param == MenuCancel_ExitBack)
			MenuEnquete(client);
	}
	else if (action == MenuAction_End)
		delete menu1;

	return 0;
}

public Action Cmd_Tribunal(int client, int args) 
{
	if(client == 0)
	{
		PrintToServer("%T", "NoAccessCommand", LANG_SERVER);
		return Plugin_Handled;
	}		
	else if(rp_GetClientInt(client, i_Job) != JOBID)
	{
		Translation_PrintNoAccess(client);
		return Plugin_Handled;
	}
	
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(MenuTribunal_main);

	menu.SetTitle("  Tribunal \n--------------------");

	//menu.AddItem("forum",		"Juger les cas du forum");
	menu.AddItem("connected",	"Juger un joueur présent");
	//menu.AddItem("disconnect",	"Juger un joueur récement déconnecté");
	menu.AddItem("stats",		"Voir les stats d'un joueur");

	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);

	return Plugin_Handled;
}

public int MenuTribunal_main(Menu menu, MenuAction action, int client, int param) 
{
	if(action == MenuAction_Select) 
	{
		char options[64];
		menu.GetItem(param, STRING(options));
		
		Menu menu1 = new Menu(MenuTribunal_selectplayer);
		
		if(StrEqual(options, "forum")) 
		{		
			menu1.SetTitle("  Tribunal - Cas Forum \n--------------------");

			char szQuery[1024];
			Format(STRING(szQuery), "SELECT `site_report`.`report_steamid`,COUNT(*) AS count FROM `ts-x`.`site_report`,`ts-x`.`site_tribunal` WHERE");
			Format(STRING(szQuery), "%s `site_tribunal`.`report_steamid`=`site_report`.`report_steamid` GROUP BY", szQuery);
			Format(STRING(szQuery), "%s `site_report`.`report_steamid` HAVING COUNT(*) >= 5 ORDER BY count DESC;", szQuery);
			
			DBResultSet hQuery = SQL_Query(g_DB, szQuery);
			
			if( hQuery != INVALID_HANDLE ) 
			{
				while(hQuery.FetchRow()) 
				{			
					char tmp[255], tmp2[255], szSteam[32];
					
					hQuery.FetchString(0, STRING(szSteam));
					int count= hQuery.FetchInt(1);
					
					Format(STRING(tmp), "%s %s", options, szSteam);
					
					Format(STRING(tmp2), "[%i] %s", count, szSteam);
					menu1.AddItem(tmp, tmp2);
				}
			}
			
			if( hQuery != null )
				delete hQuery;
		}
		else if(StrEqual(options, "connected")) 
		{
			menu1.SetTitle("  Tribunal - Cas connecté \n--------------------");
			char strIndex[255], strMenu[255];
			
			LoopClients(i) 
			{		
				if(!IsClientValid(i))
					continue;
				
				if(rp_GetClientInt(client, i_Zone) != 7) 
					continue;	
				
				Format(STRING(strIndex), "%s %s", options, steamID[i]);
				
				Format(STRING(strMenu), "%N", i);
				menu1.AddItem(strIndex, strMenu);
			}
		}
		else if(StrEqual(options, "disconnect"))
		{			
			menu1.SetTitle("  Tribunal - Cas déconnecté \n--------------------");
			DBResultSet hQuery = SQL_Query(g_DB, "SELECT `steamid`, `playername` FROM `rp_logs` ORDER BY `rp_economy`.`money` DESC LIMIT 100;");
			char tmp[255], tmp2[255], szSteam[32];
			
			if(hQuery != null) 
			{
				while(hQuery.FetchRow()) 
				{				
					hQuery.FetchString(0, STRING(szSteam));
					hQuery.FetchString(1, STRING(tmp2));
					
					bool found = false;
					LoopClients(i)
					{
						if(!IsClientValid(i))
							continue;
						
						if(StrEqual(szSteam, steamID[i])) 
						{
							found = true;
							break;
						}
					}
					
					if(found)
						continue;
					
					Format(STRING(tmp), "%s %s", options, szSteam);
					Format(STRING(tmp2), "%s - %s", tmp2, szSteam);
					menu1.AddItem(tmp, tmp2);
				}
			}
			
			if(hQuery != null)
				delete hQuery;
		}
		else if(StrEqual(options, "stats")) 
		{			
			menu1.SetTitle("  Tribunal - Stats joueur \n--------------------");
			char tmp[255], tmp2[255];
			
			LoopClients(i) 
			{
				if(!IsClientValid(i))
					continue;
				
				if(rp_GetClientInt(client, i_Zone) != 7 ) 
					continue;
				
				Format(STRING(tmp), "%s %s", options, steamID[i]);
				
				Format(STRING(tmp2), "%N - %s", i, steamID[i]);
				menu1.AddItem(tmp, tmp2);
			}
		}
		
		menu1.ExitButton = true;
		menu1.Display(client, MENU_TIME_FOREVER);
	}
	else if (action == MenuAction_Cancel)
	{
		if (param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if (param == MenuCancel_ExitBack)
			MenuEnquete(client);
	}
	else if (action == MenuAction_End)
		delete menu;

	return 0;
}
public int MenuTribunal_selectplayer(Menu menu, MenuAction action, int client, int param) 
{
	if(action == MenuAction_Select) 
	{		
		char buff_options[255], options[2][64], option[64], szSteamID[64];
		menu.GetItem(param, STRING(buff_options));		
		ExplodeString(buff_options, " ", options, 2, 64);
		strcopy(STRING(option), options[0]);
		strcopy(STRING(szSteamID), options[1]);		
		
		char uniqID[64], szIP[64], szQuery[1024];
		String_GetRandom(STRING(uniqID), 32);
		GetClientIP(client, STRING(szIP));
		
		Format(STRING(szQuery), "INSERT INTO `rp_tribunal` (`uniqID`, `timestamp`, `steamid`, `IP`) VALUES ('%s', '%i', '%s', '%s');", uniqID, GetTime(), szSteamID, szIP);
		
		SQL_Query(g_DB, szQuery);
		
		char szTitle[128], szURL[512];
		Format(STRING(szTitle), "Tribunal: %s", szSteamID);
		Format(STRING(szURL), "http://www.ts-x.eu/popup.php?url=/index.php?page=tribunal&action=case&steamid=%s&tokken=%s", szSteamID, uniqID);
		
		ShowMOTDPanel(client, szTitle, szURL, MOTDPANEL_TYPE_URL);
		
		if(!StrEqual(option, "stats")) 
		{			
			Menu menu1 = new Menu(MenuTribunal_Apply);
			menu1.SetTitle("  Tribunal - Sélection de la peine \n--------------------");
			
			char tmp[255], tmp2[255];			
			for(int i=0; i<=100; i+=2) 
			{
				Format(STRING(tmp), "%s %s %i", option, szSteamID, i);
				Format(STRING(tmp2), "%i heures", i);
				menu1.AddItem(tmp, tmp2);
			}
			
			menu1.ExitButton = true;
			menu1.Display(client, MENU_TIME_FOREVER);
		}
	}
	else if (action == MenuAction_Cancel)
	{
		if (param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if (param == MenuCancel_ExitBack)
			MenuEnquete(client);
	}
	else if (action == MenuAction_End)
		delete menu;
	
	return 0;
}
public int MenuTribunal_Apply(Menu menu, MenuAction action, int client, int param) 
{
	if(action == MenuAction_Select) 
	{
		char buff_options[255], options[3][64];
		menu.GetItem(param, STRING(buff_options));		
		ExplodeString(buff_options, " ", options, 3, 64);
		
		char random[6];
		String_GetRandom(STRING(random), sizeof(random) - 1);
		
		strcopy(g_szTribunal_DATA[client][tribunal_option], 63, options[0]);
		strcopy(g_szTribunal_DATA[client][tribunal_steamid], 63, options[1]);
		strcopy(g_szTribunal_DATA[client][tribunal_duration], 63, options[2]);
		strcopy(g_szTribunal_DATA[client][tribunal_code], 63, random);
		if(StringToInt(g_szTribunal_DATA[client][tribunal_duration]) > 0)
			rp_PrintToChat(client, "Afin de confirmer votre jugement, tappez maintenant /jugement amende %s raison", random);
		else
			rp_PrintToChat(client, "Afin de confirmer votre jugement, tappez maintenant /jugement %s raison", random);
	}
	else if (action == MenuAction_Cancel)
	{
		if (param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if (param == MenuCancel_ExitBack)
			MenuEnquete(client);
	}
	else if (action == MenuAction_End)
		delete menu;

	return 0;
}

public int MenuTribunal(Menu menu, MenuAction action, int client, int param) 
{
	if (action == MenuAction_Select) 
	{		
		char szMenuItem[64];
		if(menu.GetItem(param, STRING(szMenuItem))) 
		{			
			int target = StringToInt(szMenuItem);
			if(!IsClientValid(target)) 
			{
				rp_PrintToChat(client, "Le joueur s'est déconnecté.");
				return -1;
			}
			
			char uniqID[64], szIP[64], szQuery[1024];
			
			String_GetRandom(STRING(uniqID), 32);
			GetClientIP(client, STRING(szIP));
			
			Format(STRING(szQuery), "INSERT INTO `rp_tribunal` (`uniqID`, `timestamp`, `steamid`, `IP`) VALUES ('%s', '%i', '%s', '%s');", uniqID, GetTime(), steamID[target], szIP);
			SQL_Query(g_DB, szQuery);
			
			char szTitle[128], szURL[512];
			Format(STRING(szTitle), "Tribunal: %N", target);
			Format(STRING(szURL), "http://www.ts-x.eu/popup.php?url=/index.php?page=tribunal&action=case&steamid=%s&tokken=%s", steamID[target], uniqID);
			
			ShowMOTDPanel(client, szTitle, szURL, MOTDPANEL_TYPE_URL);
		}		
	}
	else if (action == MenuAction_Cancel)
	{
		if (param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if (param == MenuCancel_ExitBack)
			MenuEnquete(client);
	}
	else if (action == MenuAction_End)
		delete menu;
		
	return 0;
}

public Action Cmd_Avocat(int client, int args) 
{
	FakeClientCommand(client, "say /job");
	return Plugin_Handled;
}

public Action Cmd_Conv(int client, int args) 
{
	if(client == 0)
	{
		PrintToServer("%T", "NoAccessCommand", LANG_SERVER);
		return Plugin_Handled;
	}		
	else if(rp_GetClientInt(client, i_Job) != 1 && rp_GetClientInt(client, i_Job) != JOBID)
	{
		Translation_PrintNoAccess(client);
		return Plugin_Handled;
	}

	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_Convocation);
	menu.SetTitle("Liste des joueurs:");
	char tmp[24], tmp2[64];

	LoopClients(i)
	{
		if(!IsClientValid(i))
			continue;
		
		Format(STRING(tmp), "%i", i);
		if(rp_GetClientBool(client, b_IsNew))
			Format(STRING(tmp2), "[NEW] %N", i);
		else
			Format(STRING(tmp2), "%N", i);

		menu.AddItem(tmp, tmp2);
	}

	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);

	return Plugin_Handled;
}

public int Handle_Convocation(Menu menu, MenuAction action, int client, int param) 
{
	if (action == MenuAction_Select) 
	{
		char options[128];
		menu.GetItem(param, STRING(options));
		int target = StringToInt(options);

		// Setup menu
		rp_SetClientBool(client, b_DisplayHud, false);
		Menu menu2 = new Menu(Handle_Convocation2);
		Format(STRING(options), "Que faire pour %N", target);
		menu2.SetTitle(options);
		if(g_TribunalSearch[target].tribunal_search_status == -1)
		{
			Format(STRING(options), "%i_1", target);
			menu2.AddItem(options, "Lancer la convocation");
			
			Format(STRING(options), "%i_-1", target);
			menu2.AddItem(options, "Annuler la convocation", ITEMDRAW_DISABLED);

			Format(STRING(options), "%i_4", target);
			menu2.AddItem(options, "Forcer la recherche");
		}
		else
		{
			Format(STRING(options), "%i_1", target);
			menu2.AddItem(options, "Lancer la convocation", ITEMDRAW_DISABLED);
			
			Format(STRING(options), "%i_-1", target);
			menu2.AddItem(options, "Annuler la convocation");

			Format(STRING(options), "%i_4", target);
			menu2.AddItem(options, "Forcer la recherche", ITEMDRAW_DISABLED);
		}
		
		menu2.ExitButton = true;
		menu2.Display(client, MENU_TIME_FOREVER);
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

public int Handle_Convocation2(Menu menu, MenuAction action, int client, int param) 
{
	if(action == MenuAction_Select) 
	{
		char options[64], optionsBuff[2][64];
		menu.GetItem(param, STRING(options));	
		ExplodeString(options, "_", optionsBuff, 2, 64);
		
		int target = StringToInt(optionsBuff[0]);
		int etat = StringToInt(optionsBuff[1]);
		
		if(etat == -1)
		{
			CPrintToChatAll("{lightblue} ================================== {default}");
			CPrintToChatAll("{lightblue}[TRIBUNAL]{default} %N {default}n'est plus recherché par le Tribunal.", target);
			CPrintToChatAll("{lightblue} ================================== {default}");
			g_TribunalSearch[target].tribunal_search_status = -1;
			rp_PrintToChat(client, "La recherche sur le joueur %N à durée %.1f minutes.", target, (GetTime()-g_TribunalSearch[target].tribunal_search_starttime)/60.0);
			LogToGame("%s [RECHERCHE] %L à mis fin à la convocation de %L.", client, target);
			rp_SetClientBool(target, b_IsSearchByTribunal, false);

		}
		else if(etat == 1)
		{
			g_TribunalSearch[target].tribunal_search_status = 1;
			g_TribunalSearch[target].tribunal_search_starttime = GetTime();
			CPrintToChatAll("{lightblue} ================================== {default}");
			CPrintToChatAll("{lightblue}[TRIBUNAL]{default} %N {default}est convoqué dans le Tribunal. [%i/3]", target, etat);
			CPrintToChatAll("{lightblue} ================================== {default}");
			LogToGame("%s [RECHERCHE] %L convoque %L au tribunal.", client, target);
			CreateTimer(30.0, Timer_ConvTribu, target, TIMER_REPEAT);
			rp_SetClientBool(target, b_IsSearchByTribunal, true);
		}
		else if(etat == 4)
		{
			g_TribunalSearch[target].tribunal_search_status = 4;
			g_TribunalSearch[target].tribunal_search_starttime = GetTime();
			CPrintToChatAll("{lightblue} ================================== {default}");
			CPrintToChatAll("{lightblue}[TRIBUNAL]{default} %N {default}est recherché par le Tribunal.", target);
			CPrintToChatAll("{lightblue} ================================== {default}");
			LogToGame("%s [RECHERCHE] %L à lancé une recherche sur %L", client, target);
			CreateTimer(60.0, Timer_ConvTribu, target, TIMER_REPEAT);
			rp_SetClientBool(target, b_IsSearchByTribunal, true);
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

public Action Timer_ConvTribu(Handle timer, any target) 
{
	if(!IsClientValid(target) || g_TribunalSearch[target].tribunal_search_status == -1)
		return Plugin_Stop;
		
	float vecOrigin[3];
	Entity_GetAbsOrigin(target, vecOrigin);
	if(GetVectorDistance(vecOrigin, view_as<float>({496.0, -1787.0, -1997.0})) < 64.0 || GetVectorDistance(vecOrigin, view_as<float>({-782.0, -476.0, -2000.0})) < 64.0)
	{
		CPrintToChatAll("{lightblue} ================================== {default}");
		CPrintToChatAll("{lightblue}[TRIBUNAL]{default} %N {default}n'est plus recherché par le Tribunal.", target);
		CPrintToChatAll("{lightblue} ================================== {default}");
		g_TribunalSearch[target].tribunal_search_status = -1;
		LogToGame("%s [RECHERCHE] %L à été détecté comme présent au tribunal.", target);
		PrintToChatZone(rp_GetClientInt(target, i_Zone), "{lightblue}[TSX-RP]{default} La recherche sur le joueur %N à durée %.1f minutes.", target, (GetTime()-g_TribunalSearch[target].tribunal_search_starttime)/60.0);
		rp_SetClientBool(target, b_IsSearchByTribunal, false);
		return Plugin_Stop;
	}
	g_TribunalSearch[target].tribunal_search_status++;
	if(g_TribunalSearch[target].tribunal_search_status > 3)
	{
		CPrintToChatAll("{lightblue} ================================== {default}");
		CPrintToChatAll("{lightblue}[TRIBUNAL]{default} %N {default}est recherché par le Tribunal.", target);
		CPrintToChatAll("{lightblue} ================================== {default}");
	}
	else if(g_TribunalSearch[target].tribunal_search_status == 4)
	{
		CPrintToChatAll("{lightblue} ================================== {default}");
		CPrintToChatAll("{lightblue}[TRIBUNAL]{default} %N {default}est convoqué dans le Tribunal. [%i/3]", target, g_TribunalSearch[target].tribunal_search_status);
		CPrintToChatAll("{lightblue} ================================== {default}");
		CreateTimer(60.0, Timer_ConvTribu, target, TIMER_REPEAT);
		return Plugin_Stop;
	}
	else
	{
		CPrintToChatAll("{lightblue} ================================== {default}");
		CPrintToChatAll("{lightblue}[TRIBUNAL]{default} %N {default}est convoqué dans le Tribunal. [%i/3]", target, g_TribunalSearch[target].tribunal_search_status);
		CPrintToChatAll("{lightblue} ================================== {default}");
	}
	return Plugin_Continue;
}

public void ClientConVar(QueryCookie cookie, int client, ConVarQueryResult result, const char[] cvarName, const char[] cvarValue) 
{
	if(StrEqual(cvarName, "cl_disablehtmlmotd"))
	{
		if(StrEqual(cvarValue, "0") == false) 
		{
			rp_PrintToChat(client, "Des problemes d'affichage ? Entrer cl_disablehtmlmotd 0 dans votre console puis relancer CS:GO.");
		}
	}
}

public Action Cmd_Jugement(int client, int args) 
{
	if(client == 0)
	{
		PrintToServer("%T", "NoAccessCommand", LANG_SERVER);
		return Plugin_Handled;
	}		
	else if(rp_GetClientInt(client, i_Job) != JOBID)
	{
		Translation_PrintNoAccess(client);
		return Plugin_Handled;
	}
	
	int amende = 0;	
	char arg1[12];
	if(StringToInt(g_szTribunal_DATA[client][tribunal_duration]) > 0)
	{
		char amendeStr[32];
		GetCmdArg(1, STRING(amendeStr));
		amende = StringToInt(amendeStr);
		GetCmdArg(2, STRING(arg1));
	}
	else
		GetCmdArg(1, STRING(arg1));
	
	char random[6];
	
	Database DB = g_DB;
	
	if(StrEqual(g_szTribunal_DATA[client][tribunal_code], arg1)) 
	{
		if(StrEqual(g_szTribunal_DATA[client][tribunal_option], "unknown")) 
		{
			rp_PrintToChat(client, "Erreur: Pas de jugement en cours.");
			return Plugin_Handled;
		}

		char UserName[64];
		GetClientName(client,UserName,63);

		char szReason[128], tmp[64];

		if(StringToInt(g_szTribunal_DATA[client][tribunal_duration]) > 0)
		{
			for(int i=3; i<=args; i++) 
			{
				GetCmdArg(i, STRING(tmp));
				Format(STRING(szReason), "%s%s ", szReason, tmp);
			}
		}
		else
		{
			for(int i=2; i<=args; i++) 
			{
				GetCmdArg(i, STRING(tmp));
				Format(STRING(szReason), "%s%s ", szReason, tmp);
			}
		}

		char buffer_name[ sizeof(UserName)*2+1 ];
		SQL_EscapeString(DB, UserName, buffer_name, sizeof(buffer_name));
		
		char buffer_reason[ sizeof(szReason)*2+1 ];
		SQL_EscapeString(DB, szReason, buffer_reason, sizeof(buffer_reason));
		
		char szQuery[2048];
		if( StringToInt(g_szTribunal_DATA[client][tribunal_duration]) > 0 ) {

			if(amende >= 1)
			{
				int maxAmount;
				switch(rp_GetClientInt(client, i_Grade)) 
				{
					case 1: maxAmount = 1000000;
					case 2: maxAmount = 300000;
					case 3: maxAmount = 100000;
					case 4: maxAmount = 75000;
					case 5: maxAmount = 50000;
					case 6: maxAmount = 25000;
					case 7: maxAmount = 12500;
				}

				if(amende > maxAmount)
				{
					rp_PrintToChat(client, "L'amende excède le montant maximum autorisé.");
					String_GetRandom(STRING(random), sizeof(random) - 1);

					Format(g_szTribunal_DATA[client][tribunal_code], 63, random);
					Format(g_szTribunal_DATA[client][tribunal_option], 63, "unknown");

					return Plugin_Handled;
				}
				int playermoney=-1;

				SQL_LockDatabase( DB );
				Format(szQuery, sizeof(szQuery), "SELECT (`money`+`bank`) FROM  `rp_economy` WHERE `steamid`='%s';", g_szTribunal_DATA[client][tribunal_steamid]);
				DBResultSet row = SQL_Query(DB, szQuery);
				if(row != null) 
				{
					if(row.FetchRow()) 
					{
						playermoney = row.FetchInt(0);
					}
				}
				SQL_UnlockDatabase( DB );

				if(playermoney == -1)
				{
					PrintToServer("Erreur SQL: Impossible de relever l'argent du joueur (Amende jugement)");
					rp_PrintToChat(client, "Erreur: Impossible de relever l'argent du joueur.", playermoney);
					String_GetRandom(random, sizeof(random), sizeof(random) - 1);

					Format(g_szTribunal_DATA[client][tribunal_code], 63, random);
					Format(g_szTribunal_DATA[client][tribunal_option], 63, "unknown");

					return Plugin_Handled;
				}
				else if(amende > playermoney)
				{
					rp_PrintToChat(client, "Le joueur n'a que %i$, le jugement a été annulé.", playermoney);
					String_GetRandom(random, sizeof(random), sizeof(random) - 1);

					Format(g_szTribunal_DATA[client][tribunal_code], 63, random);
					Format(g_szTribunal_DATA[client][tribunal_option], 63, "unknown");

					return Plugin_Handled;
				}

				rp_SetJobCapital(7, rp_GetJobCapital(7) + (amende/4 * 3));
				rp_SetClientInt(client, i_SalaryBonus, rp_GetClientInt(client, i_SalaryBonus) + (amende / 4));
			}
			else{
				amende = 0;
			}


			Format(szQuery, sizeof(szQuery), "INSERT INTO `rp_jail` (`id`, `steamid`, `jail`, `pseudo`, `steamid2`, `raison`, `money`) VALUES", szQuery);
			Format(szQuery, sizeof(szQuery), "%s (NULL, '%s', '%i', '%s', '%s', '%s', '-%i');", \
				szQuery, \
				g_szTribunal_DATA[client][tribunal_steamid], \
				StringToInt(g_szTribunal_DATA[client][tribunal_duration])*60, \
				buffer_name, \
				steamID[client], \
				buffer_reason, \
				amende \
			);

			SQL_Request(DB, szQuery);
			
			ReplaceString(g_szTribunal_DATA[client][tribunal_steamid], sizeof(g_szTribunal_DATA[][]), "STEAM_1", "STEAM_0");
			ReplaceString(steamID[client], sizeof(steamID[]), "STEAM_1", "STEAM_0");
			
			Format(szQuery, sizeof(szQuery), "INSERT INTO `ts-x`.`srv_bans` (`id`, `SteamID`, `StartTime`, `EndTime`, `Length`, `adminSteamID`, `BanReason`, `game`)");
			Format(szQuery, sizeof(szQuery), "%s VALUES (NULL, '%s', UNIX_TIMESTAMP(), (UNIX_TIMESTAMP()+'%i'), '%i', '%s', '%s', 'tribunal'); ",
			szQuery, g_szTribunal_DATA[client][tribunal_steamid], StringToInt(g_szTribunal_DATA[client][tribunal_duration])*60, StringToInt(g_szTribunal_DATA[client][tribunal_duration])*60, steamID[client], buffer_reason);
			
			SQL_Request(DB, szQuery);

			LogToGame("[TRIBUNAL] le juge %s %s a condamné %s à faire %s heures de prison et à payer %i$ pour %s",
				UserName,
				steamID[client],
				g_szTribunal_DATA[client][tribunal_steamid],
				g_szTribunal_DATA[client][tribunal_duration],
				amende,
				szReason
			);

			CPrintToChatAll("%s Le juge %s %s a condamné %s à faire %s heures de prison et à payer %i$ pour %s", UserName, steamID[client], g_szTribunal_DATA[client][tribunal_steamid], g_szTribunal_DATA[client][tribunal_duration], amende, szReason);
		}
		else
		{
			LogToGame("[TRIBUNAL] le juge %s %s a acquitté %s pour %s",
				UserName, steamID[client], g_szTribunal_DATA[client][tribunal_steamid], szReason);

			CPrintToChatAll("%s Le juge %s %s a acquitté %s pour %s", UserName, steamID[client], g_szTribunal_DATA[client][tribunal_steamid], szReason);
		}

		if( StrEqual(g_szTribunal_DATA[client][tribunal_option], "forum") ) {
			char steamid0[64];
			strcopy(steamid0,63,g_szTribunal_DATA[client][tribunal_steamid]);
			ReplaceString(steamid0, sizeof(steamid0), "STEAM_1", "STEAM_0");
			char steamid1[64];
			strcopy(steamid1,63,g_szTribunal_DATA[client][tribunal_steamid]);
			ReplaceString(steamid0, sizeof(steamid0), "STEAM_0", "STEAM_1");

			Format(szQuery, sizeof(szQuery), "DELETE FROM `ts-x`.`site_report` WHERE `report_steamid`='%s' OR `report_steamid`='%s';", steamid0, steamid1);
			SQL_Request(DB, szQuery);
			
			Format(szQuery, sizeof(szQuery), "DELETE FROM `ts-x`.`site_tribunal` WHERE `report_steamid`='%s' OR `report_steamid`='%s';", steamid0, steamid1);
			SQL_Request(DB, szQuery);
		}
		
	}
	else
	{
		rp_PrintToChat(client, "Le code est incorrect, le jugement a été annulé.");
	}
	
	String_GetRandom(random, sizeof(random), sizeof(random) - 1);
	
	Format(g_szTribunal_DATA[client][tribunal_code], 63, random);
	Format(g_szTribunal_DATA[client][tribunal_option], 63, "unknown");
	
	return Plugin_Handled;
}