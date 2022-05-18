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

char steamID[MAXPLAYERS + 1][32];
Database g_DB;
int jobPerqui;
int timePerqui;
bool canPerquisition[MAXJOBS + 1];

/***************************************************************************************

							P L U G I N  -  I N F O

***************************************************************************************/

public Plugin myinfo = 
{
	name = "Roleplay - JobCore", 
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
	PrintToServer("[REQUIREMENT] ITEMS ✓");

	/*----------------------------------Commands-------------------------------*/
	RegConsoleCmd("job", Cmd_job);
	/*-------------------------------------------------------------------------------*/	
}	

public void RP_OnSQLInit(Database db, Transaction transaction)
{
	g_DB = db;
	
	char sBuffer[MAX_BUFFER_LENGTH + 1];
	
	Format(STRING(sBuffer), "CREATE TABLE IF NOT EXISTS `rp_jobs_list` ( \
	  `id` int(10) NOT NULL, \
	  `name` varchar(64) NOT NULL, \
	  `capital` varchar(64) NOT NULL, \
	  `shownote` varchar(256) NOT NULL, \
	  PRIMARY KEY (`id`)\
	  )ENGINE = InnoDB DEFAULT CHARSET = utf8 COLLATE = utf8_bin;");
	#if DEBUG
		PrintToServer(sBuffer);
	#endif
	transaction.AddQuery(sBuffer); 
	
	Format(STRING(sBuffer), "CREATE TABLE IF NOT EXISTS `rp_jobs_data` ( \
	  `jobid` int(10) NOT NULL, \
	  `gradeid` int(10) NOT NULL, \
	  `name` varchar(64) NOT NULL, \
	  `tag` varchar(64) NOT NULL, \
	  `salary` varchar(64) NOT NULL, \
	  `model` varchar(256) NOT NULL, \
	  PRIMARY KEY (`jobid`), \
	  FOREIGN KEY (`jobid`) REFERENCES `rp_jobs_list` (`id`) ON DELETE CASCADE ON UPDATE CASCADE \
	  )ENGINE = InnoDB DEFAULT CHARSET = utf8 COLLATE = utf8_bin;"); // FIX TODO
	#if DEBUG
		PrintToServer(sBuffer);
	#endif
	transaction.AddQuery(sBuffer); 
	
	Format(STRING(sBuffer), "CREATE TABLE IF NOT EXISTS `rp_jobs` ( \
	  `playerid` int(20) NOT NULL, \
	  `jobid` int(10) NOT NULL, \
	  `gradeid` int(10) NOT NULL, \
	  PRIMARY KEY (`playerid`), \
	  UNIQUE KEY `playerid` (`playerid`), \
	  FOREIGN KEY (`playerid`) REFERENCES `rp_players` (`id`) ON DELETE CASCADE ON UPDATE CASCADE, \
	  FOREIGN KEY (`jobid`) REFERENCES `rp_jobs_list` (`id`) ON DELETE CASCADE ON UPDATE CASCADE \
	  )ENGINE = InnoDB DEFAULT CHARSET = utf8 COLLATE = utf8_bin;");
	#if DEBUG
		PrintToServer(sBuffer);
	#endif
	transaction.AddQuery(sBuffer); 
	
	for (int i = 0; i <= MAXJOBS; i++)
	{
		char sName[64];
		rp_GetJobName(i, STRING(sName));
		
		char sCapital[64];
		IntToString(rp_GetJobCapital(i), STRING(sCapital));
		
		Format(STRING(sBuffer), "INSERT IGNORE INTO `rp_jobs_list` (`id`, `name`, `capital`, `shownote`) VALUES ('%i', '%s', '%s', '');", i, sName, sCapital);
		#if DEBUG
			PrintToServer(sBuffer);
		#endif
		transaction.AddQuery(sBuffer);
			
		for(int j = 1; j <= rp_GetJobMaxGrades(i); j++)
		{
			char sTag[64], sSalary[64], sModel[256];
			
			rp_GetGradeName(i, j, STRING(sName));
			SQL_EscapeString(db, sName, STRING(sName));
			rp_GetGradeClantag(i, j, STRING(sTag));
			rp_GetGradeModel(i, j, STRING(sModel));
			
			IntToString(rp_GetGradeSalary(i, j), STRING(sSalary));
			
			Format(STRING(sBuffer), "INSERT IGNORE INTO `rp_jobs_data` (`jobid`, `gradeid`, `name`, `tag`, `salary`, `model`) VALUES ('%i', '%i', '%s', '%s', '%s', '%s');", i, j, sName, sTag, sSalary, sModel);
			#if DEBUG
				PrintToServer(sBuffer);
			#endif
			transaction.AddQuery(sBuffer);
		}	
	}
}

public void OnMapStart()
{
	for (int i = 2; i <= MAXJOBS; i++)
		canPerquisition[i] = true;
		
}	

public void OnPluginEnd()
{
	LoopClients(i)
	{
		if(!IsClientValid(i))
			continue;			
		SQL_SaveClient(i);
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
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) 
{
	CreateNative("rp_GetJobPerqui", Native_GetJobPerqui);
	CreateNative("rp_SetJobPerqui", Native_SetJobPerqui);	
	CreateNative("rp_CanPerquisition", Native_CanPerquisition);
	CreateNative("rp_SetPerquisitionStat", Native_SetPerquisition);
	CreateNative("rp_SetPerquisitionTime", Native_SetPerquisitionTime);
	CreateNative("rp_GetPerquisitionTime", Native_GetPerquisitionTime);
	
	return APLRes_Success;
}

public int Native_GetJobPerqui(Handle plugin, int numParams) 
{
	return jobPerqui;
}

public int Native_SetJobPerqui(Handle plugin, int numParams) 
{
	int jobid = GetNativeCell(1);
	jobPerqui = jobid;
	return -1;
}

public int Native_CanPerquisition(Handle plugin, int numParams) 
{
	int jobID = GetNativeCell(1);
	return canPerquisition[jobID];
}

public int Native_SetPerquisition(Handle plugin, int numParams) 
{
	int jobID = GetNativeCell(1);
	bool value = vbool(GetNativeCell(2));
	return canPerquisition[jobID] = value;
}

public int Native_SetPerquisitionTime(Handle plugin, int numParams) 
{
	int delay = GetNativeCell(1);
	
	return timePerqui = delay;
}

public int Native_GetPerquisitionTime(Handle plugin, int numParams) 
{
	return timePerqui;
}

/***************************************************************************************

									C L I E N T - S I D E

***************************************************************************************/

void SQL_SaveClient(int client)
{
	if(rp_GetClientInt(client, i_Job) >= 0 || rp_GetClientInt(client, i_Grade) >= 0)
		SQL_Request(g_DB, "UPDATE `rp_jobs` SET `jobid` = '%i', `gradeid` = '%i' WHERE `playerid` = '%i';", rp_GetClientInt(client, i_Job), rp_GetClientInt(client, i_Grade), rp_GetSQLID(client));
}	

public void OnClientAuthorized(int client, const char[] auth) 
{	
	strcopy(steamID[client], sizeof(steamID[]), auth);
}	

public void OnClientDisconnect(int client)
{
	SQL_SaveClient(client);
}	

public void OnClientPostAdminCheck(int client) 
{	
	char playername[MAX_NAME_LENGTH + 8];
	GetClientName(client, STRING(playername));
	char clean_playername[MAX_NAME_LENGTH * 2 + 16];
	SQL_EscapeString(g_DB, playername, STRING(clean_playername));
	
	char buffer[2048];
	Format(STRING(buffer), "INSERT IGNORE INTO `rp_jobs` (`playerid`, `jobid`, `gradeid`) VALUES ('%i', '0', '1');", rp_GetSQLID(client));
	g_DB.Query(SQL_CheckForErrors, buffer);
	
	SQL_Load(client);
}

/***************************************************************************************

									C A L L B A C K

***************************************************************************************/

public void SQL_Load(int client) 
{
	char sQuery[512];
	Format(STRING(sQuery), "SELECT * FROM `rp_jobs` WHERE `playerid` = '%i'", rp_GetSQLID(client));
	g_DB.Query(SQL_CALLBACK, sQuery, GetClientUserId(client));
}

public void SQL_CALLBACK(Database db, DBResultSet Results, const char[] error, any data) 
{	
	int client = GetClientOfUserId(data);
	while (Results.FetchRow()) 
	{
		int jobid, gradeid;
		Results.FetchIntByName("jobid", jobid);
		Results.FetchIntByName("gradeid", gradeid);
		
		rp_SetClientInt(client, i_Job, jobid);
		if(rp_GetClientInt(client, i_Job) == -1)
			rp_SetClientInt(client, i_Job, 0);			
		
		rp_SetClientInt(client, i_Grade, gradeid);
		if(rp_GetClientInt(client, i_Grade) == -1)
			rp_SetClientInt(client, i_Grade, 0);

		LoadSalaire(client);
	}
}

public Action Cmd_job(int client, int args) 
{
	rp_SetClientBool(client, b_DisplayHud, false);
	
	Menu jobmenu = new Menu(Handle_MenuJobs);
	jobmenu.SetTitle("Liste des jobs disponibles\n ");
	jobmenu.AddItem("-1", "Tout afficher");
	
	char tmp[12];
	bool bJob[MAXJOBS];

	LoopClients(i)
	{
		if(!IsClientValid(i))
			continue;
		if(rp_GetClientInt(i, i_Job) == 0)
			continue;
		if(i == client)
			continue;

		int jobid = rp_GetClientInt(i, i_Job);

		if( jobid == 1 )
			continue;

		bJob[jobid] = true;
	}

	for(int i = 1; i < MAXJOBS; i++) 
	{
		if( bJob[i] == false )
			continue;
		char jobname[64];
		rp_GetJobName(i, STRING(jobname));
		
		Format(STRING(tmp), "%i", i);
		jobmenu.AddItem(tmp, jobname);
	}

	jobmenu.ExitButton = true;
	jobmenu.Display(client, 60);
	return Plugin_Handled;
}

public int Handle_MenuJobs(Menu menu, MenuAction action, int client, int param) 
{
	if (action == MenuAction_Select) 
	{
		char info[8];
		if (menu.GetItem(param, STRING(info)))
		{
			rp_SetClientBool(client, b_DisplayHud, false);
			
			Menu menu1 = new Menu(MenuJobs2);
			menu1.SetTitle("Liste des employés connectés\n ");
			int jobid = StringToInt(info);
			int amount = 0;
			char tmp[128], tmp2[128];

			LoopClients(i)
			{
				if(!IsClientValid(i))
					continue;

				/*if(jobid == -2 && rp_GetClientInt(i, i_Avocat) <= 0)
					continue;*/

				if(jobid >= 0 && (i == client || rp_GetClientInt(i, i_Job) != jobid))
					continue;

				Format(STRING(tmp2), "%i", i);
				int ijob = rp_GetClientInt(i, i_Job) == 1 && GetClientTeam(i) == 2 ? 0 : rp_GetClientInt(i, i_Job);
				rp_GetJobName(ijob, STRING(tmp));

				if(rp_GetClientBool(i, b_IsAfk))
					Format(STRING(tmp), "[AFK] %N - %s", i, tmp);
				else if(rp_GetClientInt(i, i_JailTime) > 0)
					Format(STRING(tmp), "[JAIL] %N - %s", i, tmp);
				else if(rp_GetClientInt(i, i_Zone) == 777)
					Format(STRING(tmp), "[EVENT] %N - %s", i, tmp);
				else
					Format(STRING(tmp), "%N - %s", i, tmp);

				/*if(jobid == -2)
				{
					Format(STRING(tmp), "%s (%d$)", tmp, rp_GetClientInt(i, i_Avocat));
				}*/
					
				menu1.AddItem(tmp2, tmp);
				amount++;
			}

			if( amount == 0 ) 
			{
				delete menu1;
			}
			else 
			{
				menu1.ExitButton = true;
				menu1.Display(client, 60);
			}
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

public int MenuJobs2(Menu p_hItemMenu, MenuAction action, int client, int param) 
{
	if (action == MenuAction_Select) 
	{
		char info[8];
		if (p_hItemMenu.GetItem(param, STRING(info)))
		{
			rp_SetClientBool(client, b_DisplayHud, false);
			
			Menu menu = new Menu(MenuJobs3);
			menu.SetTitle("Que voulez vous lui demander ?\n ");
			int target = StringToInt(info);
			int jobid = rp_GetClientInt(target, i_Job);
			int amount = 0;
			char tmp[128], tmp2[128];

			if(rp_GetClientInt(target, i_Job) != 0)
			{
				Format(STRING(tmp2), "%i_-1", target);
				menu.AddItem(tmp2, "Demander à être recruté");
				amount++;
			}
			if(jobid == 2)
			{
				Format(STRING(tmp2), "%i_-2", target);
				menu.AddItem(tmp2, "Demander pour un crochetage de porte");
				amount++;
			}
			else if(jobid == 6)
			{
				Format(STRING(tmp2), "%i_-6", target);
				menu.AddItem(tmp2, "Acheter / Vendre une arme");
				amount++;
			}
			else if(jobid == 7) 
			{
				Format(STRING(tmp2), "%i_-7", target);
				menu.AddItem(tmp2, "Demander pour une audience");
				amount++;
			}
			else if(jobid == 8) 
			{
				Format(STRING(tmp2), "%i_-8", target);
				menu.AddItem(tmp2, "Demander un Appartement");
				amount++;
			}
			else if(jobid == 20) 
			{
				Format(STRING(tmp2), "%i_-20", target);
				menu.AddItem(tmp2, "Demander une voiture");
				amount++;
			}
			else
			{
				LoopItems(i)
				{
					if(rp_GetClientItem(target, i, false))
					{
						rp_GetItemData(i, item_jobid, STRING(tmp));
						if(StringToInt(tmp) != jobid || StringToInt(tmp)==0)
							continue;
	
						rp_GetItemData(i, item_name, STRING(tmp));
						Format(STRING(tmp2), "%i_%i", target, i);
						menu.AddItem(tmp2, tmp);
						amount++;
					}	
				}
			}

			if( amount == 0 ) 
			{
				delete menu;
			}
			else 
			{
				menu.ExitButton = true;
				menu.Display(client, 60);
			}
		}
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit || param == MenuCancel_ExitBack)
			rp_SetClientBool(client, b_DisplayHud, true);
	}
	else if(action == MenuAction_End)
		delete p_hItemMenu;
		
	return 0;
}

public int MenuJobs3(Menu p_hItemMenu, MenuAction action, int client, int param) 
{
	if (action == MenuAction_Select) 
	{
		char info[16];
		if (p_hItemMenu.GetItem(param, STRING(info)))
		{
			rp_SetClientBool(client, b_DisplayHud, false);			
			char data[2][32], tmp[128];
			ExplodeString(info, "_", data, sizeof(data), sizeof(data[]));
			int target = StringToInt(data[0]);
			int item_id = StringToInt(data[1]);
			
			/*if( rp_ClientFloodTriggered(client, target, fd_job) ) 
			{
				CPrintToChat(client, "{lightblue}[TSX-RP]{default} Vous ne pouvez appeler %N, pour le moment.", target);
				return;
			}
			rp_ClientFloodIncrement(client, target, fd_job, 10.0);*/
			
			char zoneName[64];
			rp_GetClientString(client, sz_ZoneName, STRING(zoneName));
			switch(item_id)
			{
				case -1: rp_PrintToChat(target, "Le joueur %N aimerait être recruté, il est actuellement: %s", client, zoneName);
				case -2: rp_PrintToChat(target, "Le joueur %N a besoin d'un crochetage de porte, il est actuellement: %s", client, zoneName);
				case -6: rp_PrintToChat(target, "Le joueur %N aimerait acheter ou vendre une arme, il est actuellement: %s", client, zoneName);
				case -7: rp_PrintToChat(target, "Le joueur %N a besoin d'un juge, il est actuellement: %s", client, zoneName);
				case -8: rp_PrintToChat(target, "Le joueur %N souhaiterait acheter un appartement, merci de le contacter pour plus de renseignement. Il est actuellement: %s", client, zoneName);
				default: 
				{
					rp_GetItemData(item_id, item_name, STRING(tmp));
					rp_PrintToChat(target, "%s Le joueur %N a besoin de {lime}%s{default}, il est actuellement: %s", client, tmp, zoneName);
					LogToGame("[RP] [CALL] %L a demandé %s à %L", client, tmp, target);
				}
			}
			rp_PrintToChat(client, "La demande à été envoyée à la personne.");
			ClientCommand(target, "play buttons/blip1.wav");
			rp_Effect_BeamBox(target, client, 122, 122, 0);
			DataPack dp;
			CreateDataTimer(1.0, Timer_ClientTargetTracer, dp, TIMER_DATA_HNDL_CLOSE|TIMER_REPEAT);
			dp.WriteCell(0);
			dp.WriteCell(client);
			dp.WriteCell(target);
		}
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit || param == MenuCancel_ExitBack)
			rp_SetClientBool(client, b_DisplayHud, true);
	}
	else if(action == MenuAction_End)
		delete p_hItemMenu;
		
	return 0;
}

public Action Timer_ClientTargetTracer(Handle timer, DataPack dp) 
{
	dp.Reset();
	int count = dp.ReadCell();
	int client = dp.ReadCell();
	int target = dp.ReadCell();	
	
	if(!IsClientValid(client) || !IsClientValid(target)) 
	{
		return Plugin_Stop;
	}
	
	rp_Effect_BeamBox(target, client, 122, 122, 0);
	
	if( count >= 5 ){
		return Plugin_Stop;
	}
	
	dp.Reset();
	dp.WriteCell(count + 1);
	
	return Plugin_Continue;
}

public void RP_ClientTimerEverySecond(int client)
{
	if(jobPerqui != 0 && rp_GetClientInt(client, i_Job) == 1)
	{
		if(rp_GetClientInt(client, i_Zone) == jobPerqui)
		{
			char strTime[32];
			StringTime(timePerqui, STRING(strTime));
			PrintHintText(client, "Temps restant :\n%s", strTime);
		}
	}
}

public void RP_OnNewDay()
{
	GiveSalary();
}

void GiveSalary()
{
	int juge;
	char translation[128];
	LoopClients(i)
	{
		if(!IsClientValid(i))
			continue;
		
		if(!rp_GetClientBool(i, b_IsAfk))
		{
			if(rp_GetClientInt(i, i_Job) == 7)
				juge++;

			if(rp_GetClientBool(i, b_IsVip))
			{
				Format(STRING(translation), "%T", "Salary_Prime", LANG_SERVER);				
				CPrintToChat(i, "%s %s", NOTIF, translation);				
				rp_SetJobCapital(5, rp_GetJobCapital(5) - 100);
				rp_SetClientInt(i, i_Money, rp_GetClientInt(i, i_Money) + 100);
			}
			
			if(rp_GetClientInt(i, i_JailTime) == 0)
			{
				if(rp_GetClientInt(i, i_Job) != 0)
				{
					if(rp_GetJobCapital(rp_GetClientInt(i, i_Job)) >= rp_GetClientInt(i, i_Salary))
					{
						if(rp_GetClientInt(i, i_Salary) > 0)
						{
							Format(STRING(translation), "%T", "Salary_Receive", LANG_SERVER, rp_GetClientInt(i, i_Salary));				
							CPrintToChat(i, "%s %s", NOTIF, translation);	
							if(rp_GetClientBool(i, b_HasRib))
								rp_SetClientInt(i, i_Bank, rp_GetClientInt(i, i_Bank) + rp_GetClientInt(i, i_Salary));						
							else
								rp_SetClientInt(i, i_Money, rp_GetClientInt(i, i_Money) + rp_GetClientInt(i, i_Salary));											
							rp_SetJobCapital(rp_GetClientInt(i, i_Job), rp_GetJobCapital(rp_GetClientInt(i, i_Job)) - rp_GetClientInt(i, i_Salary));
							
							if(rp_GetClientInt(i, i_SalaryBonus) > 0)
							{
								Format(STRING(translation), "%T", "Salary_Prime", LANG_SERVER);				
								CPrintToChat(i, "%s %s (%i$)", NOTIF, translation, rp_GetClientInt(i, i_SalaryBonus));
								
								if(rp_GetClientBool(i, b_HasRib))
									rp_SetClientInt(i, i_Bank, rp_GetClientInt(i, i_Bank) + rp_GetClientInt(i, i_SalaryBonus));
								else
									rp_SetClientInt(i, i_Money, rp_GetClientInt(i, i_Money) + rp_GetClientInt(i, i_SalaryBonus));			
							}	
							
							if(rp_GetClientBool(i, b_HasBonusPay))
							{
								if(IsOwnerInAppart(rp_GetClientInt(i, i_Appart)))
								{
									int bonus = rp_GetClientInt(i, i_Salary) % 30;								
									
									if(rp_GetClientBool(i, b_HasRib))
										rp_SetClientInt(i, i_Bank, rp_GetClientInt(i, i_Bank) + bonus);
									else
										rp_SetClientInt(i, i_Money, rp_GetClientInt(i, i_Money) + bonus);									
								}	
							}	
						}
						else if(rp_GetClientInt(i, i_Grade) != 1)
						{
							Format(STRING(translation), "%T", "Salary_CantReceive", LANG_SERVER);				
							CPrintToChat(i, "%s %s", NOTIF, translation);		
						}	
						else
						{					
							Format(STRING(translation), "%T", "Salary_Denied", LANG_SERVER);				
							CPrintToChat(i, "%s %s", NOTIF, translation);		
						}	
					}
					else if(rp_GetClientInt(i, i_Grade) != 1)
					{
						Format(STRING(translation), "%T", "Salary_NotEnought", LANG_SERVER);				
						CPrintToChat(i, "%s %s", NOTIF, translation);		
					}	
				}
			}
			else
			{
				Format(STRING(translation), "%T", "Salary_DeniedJail", LANG_SERVER);				
				CPrintToChat(i, "%s %s", NOTIF, translation);		
			}	
		}
		else if(rp_GetClientBool(i, b_IsAfk))
		{
			Format(STRING(translation), "%T", "Salary_DeniedAfk", LANG_SERVER);				
			CPrintToChat(i, "%s %s", NOTIF, translation);		
		}
	}
	
	if(juge > 1)
	{
		rp_SetJobCapital(5, rp_GetJobCapital(5) - 1000);
		rp_SetJobCapital(7, rp_GetJobCapital(7) + 1000);
	}
}