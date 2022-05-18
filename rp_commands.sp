/*
*   Roleplay CS:GO de Benito est mis à disposition selon les termes de la licence Creative Commons Attribution .
* - Pas d’Utilisation Commerciale 
* - Partage dans les Mêmes Conditions 4.0 International.
*
*   Merci de respecter le travail fourni par le ou les auteurs 
*   https://enemy-down.eu - benitalpa1020@gmail.com
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

/***************************************************************************************

							G L O B A L  -  V A R S

***************************************************************************************/

enum struct force_data {
	bool canForce;
	bool distance;
	int target;
	float distanceForce;
}
force_data force[MAXPLAYERS + 1];

enum struct Data_Forward {
	GlobalForward OnBuild;
	GlobalForward OnBuildHandle;
	GlobalForward OnJob;
	GlobalForward OnJobHandle;
}	
Data_Forward Forward;

bool 
	g_bCanGraffiti[MAXPLAYERS + 1],
	g_bCanVol[MAXPLAYERS + 1];
char 
	g_sSteamID[MAXPLAYERS + 1][32];
Database 
	g_DB;

/***************************************************************************************

							P L U G I N  -  I N F O

***************************************************************************************/
public Plugin myinfo = 
{
	name = "Roleplay - Commands", 
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
	LoadTranslations("rp_commands.phrases.txt");
	Database.Connect(GotDatabase, "roleplay");
	PrintToServer("[REQUIREMENT] COMMANDS ✓");	

	/*----------------------------------Commands-------------------------------*/
	RegConsoleCmd("sm_+force", Command_Grab);
	RegConsoleCmd("sm_force", Command_Grab);
	RegConsoleCmd("sm_3rd", Cmd_3rd);
	RegConsoleCmd("sm_tp", Cmd_3rd);
	RegConsoleCmd("sm_key", Cmd_Key);
	RegConsoleCmd("sm_passive", Cmd_Passive);
	RegConsoleCmd("sm_jobmenu", Cmd_JobMenu);
	//RegConsoleCmd("sm_velocity", Cmd_TestVelo); TODO ADD TODO
	RegConsoleCmd("sm_identity", Cmd_Identity);
	RegConsoleCmd("sm_graffiti", Cmd_Graffiti);
	RegConsoleCmd("sm_graff", Cmd_Graffiti);
	RegConsoleCmd("sm_spray", Cmd_Graffiti);
	RegConsoleCmd("sm_build", Cmd_Build);
	RegConsoleCmd("sm_b", Cmd_Build);
	RegConsoleCmd("sm_out", Cmd_Out);
	RegConsoleCmd("sm_dehors", Cmd_Out);
	RegConsoleCmd("sm_addnote", Cmd_AddNote);
	RegConsoleCmd("sm_vol", Cmd_Vol);
	RegConsoleCmd("sm_pick", Cmd_VolArme);
	RegConsoleCmd("sm_aide", Cmd_Help);
	RegConsoleCmd("sm_effect_gps", Command_GPS);
	RegConsoleCmd("sm_engager", Cmd_Hire);
	RegConsoleCmd("sm_hire", Cmd_Hire);
	RegConsoleCmd("sm_embaucher", Cmd_Hire);
	/*-------------------------------------------------------------------------------*/	
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
		"CREATE TABLE IF NOT EXISTS `rp_shownote` ( \
		  `Id` int(20) NOT NULL AUTO_INCREMENT, \
		  `jobid` int(20) NOT NULL, \
		  `text` varchar(128) COLLATE utf8_bin NOT NULL, \
		  PRIMARY KEY (`Id`)\
		  )ENGINE = InnoDB DEFAULT CHARSET = utf8 COLLATE = utf8_bin;");
		g_DB.Query(SQL_CheckForErrors, buffer);
	}
}

/***************************************************************************************

									N A T I V E S

***************************************************************************************/

public APLRes AskPluginLoad2(Handle plugin, bool late, char[] error, int err_max)
{
	RegPluginLibrary("rp_commands");
	
	/*------------------------------------FORWADS------------------------------------*/
	Forward.OnBuild = new GlobalForward("RP_OnClientBuild", ET_Event, Param_Cell, Param_Cell);
	Forward.OnBuildHandle = new GlobalForward("RP_OnClientBuildHandle", ET_Event, Param_Cell, Param_String);
	
	Forward.OnJob = new GlobalForward("RP_OnClientJob", ET_Event, Param_Cell, Param_Cell);
	Forward.OnJobHandle = new GlobalForward("RP_OnClientJobHandle", ET_Event, Param_Cell, Param_String);
	/*-------------------------------------------------------------------------------*/
	
	return APLRes_Success;
}

/***************************************************************************************

									C A L L B A C K

***************************************************************************************/

public Action Cmd_Identity(int client, int args)
{
	#if DEBUG
		Translation_DebugCommand(client);
	#endif
	
	if(client == 0)
	{
		Translation_PrintNoAvailable();
		return Plugin_Handled;
	}
	
	if(IsClientValid(client))
	{
		char translation[64];
		
		rp_SetClientBool(client, b_DisplayHud, false);		
		Menu menu = new Menu(HandleNothing);
		
		Format(STRING(translation), "%T", "MenuIdentity_title", LANG_SERVER);
		menu.SetTitle(translation);	
		
		Format(STRING(translation), "%T", "MenuIdentity_faim", LANG_SERVER, rp_GetClientFloat(client, fl_Faim));
		menu.AddItem("", translation, ITEMDRAW_DISABLED);
		
		Format(STRING(translation), "%T", "MenuIdentity_soif", LANG_SERVER, rp_GetClientFloat(client, fl_Soif));
		menu.AddItem("", translation, ITEMDRAW_DISABLED);
		
		Format(STRING(translation), "%T", "MenuIdentity_salary", LANG_SERVER, rp_GetClientInt(client, i_Salary));
		menu.AddItem("", translation, ITEMDRAW_DISABLED);
		
		Format(STRING(translation), "XP: %i", rp_GetClientInt(client, i_XP));
		menu.AddItem("", translation, ITEMDRAW_DISABLED);
		
		Format(STRING(translation), "%T", "MenuIdentity_steamid", LANG_SERVER, g_sSteamID[client]);
		menu.AddItem("", translation, ITEMDRAW_DISABLED);
		
		char sNationality[64];
		rp_GetNationalityName(rp_GetClientInt(client, i_Nationality), STRING(sNationality));
		Format(STRING(sNationality), "Nationalité: %s", sNationality);
		menu.AddItem("", sNationality, ITEMDRAW_DISABLED);
		
		if(rp_GetClientBool(client, b_HasBankCard))
			menu.AddItem("", "Carte bancaire: ✓", ITEMDRAW_DISABLED);
		else
			menu.AddItem("", "Carte bancaire: ✘", ITEMDRAW_DISABLED);	

		if(rp_GetClientBool(client, b_HasRib))
			menu.AddItem("", "RIB: ✓", ITEMDRAW_DISABLED);
		else
			menu.AddItem("", "RIB: ✘", ITEMDRAW_DISABLED);
		
		menu.AddItem("", "-----PERMIS-----", ITEMDRAW_DISABLED);
		
		if(rp_GetClientBool(client, b_HasSellLicence))
			menu.AddItem("", "Vente: ✓", ITEMDRAW_DISABLED);
		else
			menu.AddItem("", "Vente: ✘", ITEMDRAW_DISABLED);
		
		if(rp_GetClientBool(client, b_HasCarLicence))
			menu.AddItem("", "Voiture: ✓", ITEMDRAW_DISABLED);
		else
			menu.AddItem("", "Voiture: ✘", ITEMDRAW_DISABLED);
			
		if(rp_GetClientBool(client, b_HasPrimaryWeaponLicence))
			menu.AddItem("", "Armes primaires: ✓", ITEMDRAW_DISABLED);
		else
			menu.AddItem("", "Armes primaires: ✘", ITEMDRAW_DISABLED);	
			
		if(rp_GetClientBool(client, b_HasSecondaryWeaponLicence))
			menu.AddItem("", "Armes secondaires: ✓", ITEMDRAW_DISABLED);
		else
			menu.AddItem("", "Armes secondaires: ✘", ITEMDRAW_DISABLED);		
		
		menu.ExitButton = true;
		menu.Display(client, MENU_TIME_FOREVER);
	}
	
	return Plugin_Handled;
}		

public Action Cmd_3rd(int client, int args)
{
	#if DEBUG
		Translation_DebugCommand(client);
	#endif
	
	if(client == 0)
	{
		Translation_PrintNoAvailable();
		return Plugin_Handled;
	}
	
	if(IsClientValid(client))
	{
		if(!rp_GetClientBool(client, b_IsThirdPerson))
		{
			rp_SetClientBool(client, b_IsThirdPerson, true);
			//Client_SetThirdPersonMode(client, true); BUG
			ClientCommand(client, "thirdperson");
			
			rp_PrintToChat(client, "%T", "Command_3rd_in", LANG_SERVER);
		}	
		else
		{
			rp_SetClientBool(client, b_IsThirdPerson, false);
			//Client_SetThirdPersonMode(client, false); BUG
			ClientCommand(client, "firstperson");
			
			rp_PrintToChat(client, "%T", "Command_3rd_out", LANG_SERVER);
		}	
	}

	return Plugin_Handled;
}	

public Action Command_Grab(int client, int args)
{
	#if DEBUG
		Translation_DebugCommand(client);
	#endif
	
	if (client == 0)
	{
		Translation_PrintNoAvailable();
		return Plugin_Handled;
	}
	
	if (GetClientVehicle(client) != -1)
		return Plugin_Handled;
	
	char entClass[64];
	int aim;
	if (rp_GetAdmin(client) >= ADMIN_FLAG_OWNER && rp_GetAdmin(client) <= ADMIN_FLAG_ADMIN)
		aim = GetClientAimTarget(client, false);
	
	if (IsValidEntity(aim))
		Entity_GetClassName(aim, STRING(entClass));
	
	if (!IsPlayerAlive(client))
		return Plugin_Handled;
		
	int jobClient = rp_GetClientInt(client, i_Job);
	int gradeClient = rp_GetClientInt(client, i_Grade);
	int gradeTarget;
	int jobTarget;
	if(IsClientValid(aim))
	{
		gradeTarget = rp_GetClientInt(aim, i_Grade);
		jobTarget = rp_GetClientInt(aim, i_Job);		
	}
	
	if (IsValidEntity(aim) && aim <= MaxClients)
	{		
		if (rp_GetAdmin(client) != ADMIN_FLAG_NONE)
		{
			if (jobClient == 0 || jobClient == 1 && gradeClient == 7 || jobClient != 1 && jobClient != 7 && gradeClient >= 2)
			{
				if (!rp_GetClientBool(client, b_IsVip))
				{
					rp_PrintToChat(client, "%T", "Command_force_cantmove", LANG_SERVER);
					return Plugin_Handled;
				}
			}
			else if (jobClient == 7 && rp_GetClientInt(client, i_Zone) != 7 && gradeClient != 1 && gradeClient != 2)
			{
				rp_PrintToChat(client, "%T", "Command_force_cantjustice", LANG_SERVER);
				return Plugin_Handled;
			}
			if (jobClient == jobTarget && gradeClient > gradeTarget)
			{
				rp_PrintToChat(client, "%T", "Command_force_cantsuperior", LANG_SERVER);
				return Plugin_Handled;
			}
			if (jobClient == jobTarget && gradeClient == gradeTarget)
			{
				rp_PrintToChat(client, "%T", "Command_force_cantcolleague", LANG_SERVER);
				return Plugin_Handled;
			}
			if (jobTarget == 1)
			{
				if (jobClient == 2 && gradeClient != 1 || jobClient == 1 && gradeClient > 1 || jobClient != 2)
				{
					rp_PrintToChat(client, "%T", "Command_force_cantpolice", LANG_SERVER);
					return Plugin_Handled;
				}
			}
			if (jobClient != jobTarget && jobClient != 1 && jobClient != 7)
			{
				rp_PrintToChat(client, "%T", "Command_force_onlyemploye", LANG_SERVER);
				return Plugin_Handled;
			}
			if (jobTarget == 2 && gradeTarget == 1)
			{
				rp_PrintToChat(client, "%T", "Command_force_cantmafia", LANG_SERVER);
				return Plugin_Handled;
			}
			if (rp_GetClientBool(aim, b_IsAfk))
			{
				rp_PrintToChat(client, "%T", "Command_force_cantafk", LANG_SERVER);
				return Plugin_Handled;
			}
			if (rp_GetClientInt(client, i_Zone) == 777 && rp_GetAdmin(client) != ADMIN_FLAG_NONE)
			{
				rp_PrintToChat(client, "%T", "Command_force_cantpvp", LANG_SERVER);
				return Plugin_Handled;
			}
			if (GetEntityMoveType(aim) == MOVETYPE_NOCLIP)
				return Plugin_Handled;
		}
	}
	
	if (IsValidEntity(aim) && force[client].canForce)
	{
		char entName[64];
		Entity_GetName(aim, STRING(entName));
		
		if (StrContains(entClass, "player") == -1 && StrContains(entClass, "prop_physics") == -1 && StrContains(entClass, "prop_vehicle_driveable") == -1)
		{
			if (rp_GetAdmin(client) != ADMIN_FLAG_NONE)
			{
				if (StrContains(entName, "admin") == -1)
					return Plugin_Handled;
			}
			
			return Plugin_Handled;
		}
		else if (StrContains(entClass, "door") != -1)
			return Plugin_Handled;
		else if (StrContains(entClass, "prop_vehicle_driveable") != -1)
		{
			int owner = rp_GetVehicleInt(aim, car_owner);
			
			if (owner != client && rp_GetAdmin(client) == ADMIN_FLAG_NONE)
			{
				Translation_PrintNoAccess(client);
				return Plugin_Handled;
			}
		}
		else if (StrContains(entName, "cadavre") != -1)
		{
			if (jobClient != 12 && rp_GetAdmin(client) == ADMIN_FLAG_NONE)
			{
				Translation_PrintNoAccess(client);
				return Plugin_Handled;
			}	
		}
		else if (StrContains(entName, "mafia") != -1)
		{
			if (jobClient != 1 && jobClient != 2)
			{
				Translation_PrintNoAccess(client);
				return Plugin_Handled;
			}
		}
		
		float minDist, distance;
		distance = Distance(client, aim);
		if (force[client].distance)
		{
			if (jobClient == 1)
			{
				if (gradeClient <= 2)
					force[client].distanceForce = distance;
				else if (gradeClient == 4)
					minDist = 1000.0;
				else if (gradeClient == 5)
					minDist = 500.0;
			}
			else
			{
				minDist = 150.0;
				force[client].distanceForce = 40.0;
			}
			
			if (force[client].distanceForce < 40.0)
				force[client].distanceForce = 40.0;
		}
		else
			force[client].distanceForce = distance;
		
		if (minDist == 0.0 || distance <= minDist)
		{
			force[client].target = aim;
			force[client].canForce = false;
			
			CreateTimer(0.01, DoForce, client);
		}
	}
	else
	{
		if (IsValidEntity(force[client].target))
		{
			if (StrEqual(entClass, "player"))
				SetEntityMoveType(force[client].target, MOVETYPE_WALK);
		}
		
		force[client].canForce = true;
		force[client].target = -1;
	}
	return Plugin_Handled;
}

public Action DoForce(Handle timer, any client)
{
	if(IsValidEntity(force[client].target))
	{
		if(force[client].target <= MaxClients
		&& !IsPlayerAlive(force[client].target)
		//|| rp_GetClientBool(client, b_isTased)
		|| !IsPlayerAlive(client))
		{
			force[client].target = -1;
			force[client].canForce = true;
			return Plugin_Handled;
		}
		
		float direction[3], position[3], velocity[3], angle[3];
		
		GetClientEyeAngles(client, angle);
		GetAngleVectors(angle, direction, NULL_VECTOR, NULL_VECTOR);
		GetClientEyePosition(client, position);
		
		if(force[client].distanceForce <= 40.0)
		{
			position[0] += direction[0] * (force[client].distanceForce + 100.0);
			position[1] += direction[1] * (force[client].distanceForce + 100.0);
		}
		else
		{
			position[0] += direction[0] * force[client].distanceForce;
			position[1] += direction[1] * force[client].distanceForce;
		}
		position[2] += direction[2] * force[client].distanceForce;
		
		GetEntPropVector(force[client].target, Prop_Send, "m_vecOrigin", direction);
		
		SubtractVectors(position, direction, velocity);
		ScaleVector(velocity, 10.0);
		
		TeleportEntity(force[client].target, NULL_VECTOR, NULL_VECTOR, velocity);
		
		CreateTimer(0.01, DoForce, client);
		
		if(force[client].target <= MaxClients)
		{
			char targetname[64];
			GetClientName(force[client].target, STRING(targetname));
			
			char name[64];
			GetClientName(client, STRING(name));
			
			PrintHintText(client, "%T", "Command_force_moving", LANG_SERVER, targetname);
			PrintHintText(force[client].target, "%T", "Command_force_onmoving", LANG_SERVER, name);
		}
	}
	else
	{
		force[client].canForce = true;
		force[client].target = -1;
	}
	return Plugin_Handled;
}

public Action Cmd_Key(int client, int args)
{
	#if DEBUG
		Translation_DebugCommand(client);
	#endif
	
	if(client == 0)
	{
		Translation_PrintNoAvailable();
		return Plugin_Handled;
	}
	
	bool passed = false;
	int aim = GetClientAimTarget(client, false);
	int job = rp_GetClientInt(client, i_Job);
	char entName[64];

	if(!rp_IsValidDoor(aim))
	{
		rp_PrintToChat(client, "%T", "Door_InvalidAim", LANG_SERVER);
		return Plugin_Handled;
	}
	Entity_GetName(aim, STRING(entName));
	
	if (job == rp_GetJobSearch() && Entity_IsLocked(aim))
	{
		PrintHintText(client, "Vous ne pouvez pas fermer les portes pendant une perquisition.");
		return Plugin_Handled;
	}

	if(rp_HasDoorAccess(client, aim) || rp_GetClientInt(client, i_Zone) == job)
		passed = true;
	else
		passed = false;

	if(job == 0 && !rp_GetClientKeyAppartement(client, rp_GetClientInt(client, i_Appart)))
		passed = false;
	else if(job == 1)
	{
		if(rp_GetClientInt(client, i_Grade) <= 2)
			passed = true;
		else if(rp_GetClientInt(client, i_Grade) > 2 && passed || rp_GetClientInt(client, i_Zone) != job)
			passed = true;
	}
		
	if(StrContains(entName, g_sSteamID[client]) != -1)
		passed = true;
	else if(StrContains(entName, "door_appart") != -1)
	{
		char strAppart[4][64];		
		ExplodeString(entName, "_", strAppart, 4, 64);
			
		int appID = StringToInt(strAppart[2]);
		int owner = rp_GetAppartementInt(appID, appart_owner);
		
		if(!rp_GetClientKeyAppartement(client, appID))
			passed = false;
		else if(owner != client)	
			passed = false;
		else if(rp_GetClientInt(client, i_Job) != 6)	
			passed = false;
		else
			passed = true;
			
	}	
	else if(StrContains(entName, "door_villa_") != -1)
	{
		char strVilla[4][64];		
		ExplodeString(entName, "_", strVilla, 4, 64);
			
		int villaID = StringToInt(strVilla[2]);
		int owner = rp_GetVillaInt(villaID, villa_owner);
		
		if(!rp_GetClientKeyVilla(client, villaID))
			passed = false;
		else if(owner != client)
			passed = false;
		else if(rp_GetClientInt(client, i_Job) != 1)	
			passed = false;
		else
			passed = true;
	}

	if(passed)
	{
		if(Entity_IsLocked(aim))
		{
			ShowPanel2(client, 1, "Vous avez <font color='%s'>déverrouillée</font> la porte.", HTML_CHARTREUSE);
			AcceptEntityInput(aim, "Unlock");
		}
		else
		{
			ShowPanel2(client, 1, "Vous avez <font color='%s'>verrouillée</font> la porte.", HTML_CRIMSON);
			AcceptEntityInput(aim, "Lock");
		}
		PrecacheSound("doors/latchunlocked1.wav");
		EmitSoundToAll("doors/latchunlocked1.wav", aim, SNDCHAN_AUTO, SNDLEVEL_NORMAL);
	}
	else
		rp_PrintToChat(client, "%T", "Door_NoAccess", LANG_SERVER);	
			
	return Plugin_Handled;
}

public Action Cmd_Passive(int client, int args)
{
	#if DEBUG
		Translation_DebugCommand(client);
	#endif
	
	if(client == 0)
	{
		Translation_PrintNoAvailable();
		return Plugin_Handled;
	}
	
	if(IsClientValid(client))
	{
		if(!rp_GetClientBool(client, b_IsPassive))
		{
			rp_SetClientBool(client, b_IsPassive, true);
			rp_PrintToChat(client, "%T", "Command_passive_in", LANG_SERVER);
		}
		else
		{
			rp_SetClientBool(client, b_IsPassive, false);
			rp_PrintToChat(client, "%T", "Command_passive_out", LANG_SERVER);
		}
	}

	return Plugin_Handled;
}

public Action Cmd_JobMenu(int client, int args)
{
	#if DEBUG
		Translation_DebugCommand(client);
	#endif
	
	if(client == 0)
	{
		Translation_PrintNoAvailable();
		return Plugin_Handled;
	}
	else if(rp_GetClientInt(client, i_Job) == 0)
	{
		Translation_PrintNoAccess(client);
		return Plugin_Handled;
	}
	
	if(IsClientValid(client))
		MenuJob(client);

	return Plugin_Handled;
}

void MenuJob(int client)
{
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_MenuJob);
	
	char translation[64], jobname[32];
	rp_GetJobName(rp_GetClientInt(client, i_Job), STRING(jobname));	
	menu.SetTitle(jobname);
	
	if(rp_GetClientInt(client, i_Grade) == 1)
	{
		Format(STRING(translation), "%T", "Menu_job_capital", LANG_SERVER, rp_GetJobCapital(rp_GetClientInt(client, i_Job)));
		menu.AddItem("", translation, ITEMDRAW_DISABLED);
		Format(STRING(translation), "%T", "Menu_job_salary", LANG_SERVER);
		menu.AddItem("salary", translation);
		Format(STRING(translation), "%T", "Menu_job_employe", LANG_SERVER);
		menu.AddItem("employes", translation);
	}	
	
	Format(STRING(translation), "%T", "Menu_job_shownote", LANG_SERVER);
	menu.AddItem("shownote", translation);
			
	Format(STRING(translation), "%T", "Menu_job_left", LANG_SERVER);
	menu.AddItem("left", translation);	
		
	Call_StartForward(Forward.OnJob);
	Call_PushCell(menu);
	Call_PushCell(client);
	Call_Finish();
	
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Handle_MenuJob(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[64];
		menu.GetItem(param, STRING(info));

		if(StrEqual(info, "employes"))	
			MenuEmployes(client);
		else if(StrEqual(info, "left"))		
		{
			rp_PrintToChat(client, "%T", "JobLeft", LANG_SERVER);
			rp_SetClientInt(client, i_Job, 0);
			rp_SetClientInt(client, i_Grade, 0);
			rp_SetClientBool(client, b_DisplayHud, true);
		}	
		else if(StrEqual(info, "shownote"))	
			MenuShowNote(client);
		else if(StrEqual(info, "salary"))	
			MenuSalary(client);	
			
		Call_StartForward(Forward.OnJobHandle);
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

void MenuShowNote(int client)
{
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_MenuShowNote);
	
	menu.SetTitle("%t\n ", "Menu_job_shownote", LANG_SERVER);
	
	char query[100];
	Format(STRING(query), "SELECT * FROM `rp_shownote` WHERE `jobid` = '%i'", rp_GetClientInt(client, i_Job));	 
	DBResultSet Results = SQL_Query(g_DB, query);
	
	int count;
	while(Results.FetchRow())
	{
		count++;
		
		char text[128];
		Results.FetchStringByName("text", STRING(text));		
		menu.AddItem("", text, ITEMDRAW_DISABLED);
	}	
		
	delete Results;
	
	if(count == 0)
	{
		menu.AddItem("", "Aucune donnée", ITEMDRAW_DISABLED);
	}	
	
	menu.ExitButton = true;
	menu.ExitBackButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Handle_MenuShowNote(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if(param == MenuCancel_ExitBack)
			MenuJob(client);
	}
	else if(action == MenuAction_End)
		delete menu;
	
	return 0;
}

void MenuEmployes(int client) 
{
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_MenuEmployes);	
	
	char translation[64];	
	menu.SetTitle("%T", "Menu_employe_title", LANG_SERVER);	
	
	Format(STRING(translation), "%T", "Menu_employe_hire", LANG_SERVER);
	menu.AddItem("embaucher", translation);	
	
	Format(STRING(translation), "%T", "Menu_employe_employeedit", LANG_SERVER);
	menu.AddItem("contrat", translation);		
	
	menu.ExitBackButton = true;
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Handle_MenuEmployes(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[32];
		menu.GetItem(param, STRING(info));
		
		char translation[64];	
		if(StrEqual(info, "embaucher"))
		{
			int target = GetClientAimTarget(client, true);
			if(IsClientValid(target))
			{
				if(rp_GetClientInt(target, i_Job) == 0)
				{
					if(Distance(client, target) <= 200.0)
						MenuEmbaucher(client, target);
					else
					{
						Translation_PrintTooFar(client);
						MenuJob(client);
					}
				}
				else
				{
					rp_PrintToChat(client, "%T", "Target_AlreadyHaveJob", LANG_SERVER);
					rp_SetClientBool(client, b_DisplayHud, true);
				}
			}
			else
			{
				Translation_PrintInvalidTarget(client);
				MenuEmployes(client);
			}
		}
		else if(StrEqual(info, "contrat"))
		{
			rp_SetClientBool(client, b_DisplayHud, false);
			Menu menu1 = new Menu(Handle_MenuContrat);
			menu1.SetTitle("%T", "Menu_employe_title", LANG_SERVER);	
			
			char buffer[128];
			Format(STRING(buffer), "SELECT * FROM `rp_jobs` WHERE `jobid` = '%i' ORDER BY `gradeid`;", rp_GetClientInt(client, i_Job));
			DBResultSet query = SQL_Query(g_DB, buffer);
			
			int rowCount = SQL_GetRowCount(query);
			if(query && rowCount != 0)
			{
				for(int i = 1; i <= rowCount; i++)
				{
					char name[32], strJoueur[128], gradeName[16], strMenu[64];
					if(query.FetchRow())
					{
						int grade = 0;
						query.FetchIntByName("gradeid", grade);						
						rp_GetGradeName(grade, rp_GetClientInt(client, i_Job), STRING(gradeName));
						
						query.FetchStringByName("playername", STRING(name));
						
						Format(STRING(strJoueur), "%s : %s", name, gradeName);
						Format(STRING(strMenu), "%s|%s", g_sSteamID[client], name);
						if(grade > rp_GetClientInt(client, i_Grade))
							menu1.AddItem(strMenu, strJoueur);
						else
							menu1.AddItem("", strJoueur, ITEMDRAW_DISABLED);
					}
				}
			}
			else
			{
				Format(STRING(translation), "%T", "NullEmployees", LANG_SERVER);
				menu1.AddItem("", translation, ITEMDRAW_DISABLED);
			}	
			menu1.ExitBackButton = true;
			menu1.ExitButton = true;
			menu1.Display(client, MENU_TIME_FOREVER);
			
			delete query;
		}
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if(param == MenuCancel_ExitBack)
			MenuJob(client);
	}
	else if(action == MenuAction_End)
		delete menu;
		
	return 0;
}

void MenuEmbaucher(int client, int target)
{
	char jobName[32], strInfo[32]; 
	rp_GetJobName(rp_GetClientInt(client, i_Job), STRING(jobName));
	
	char translation[128];	
	
	char name[64];
	GetClientName(target, STRING(name));
	rp_PrintToChat(client, "%T", "Menu_employe_employeedit", LANG_SERVER, name);
	
	rp_SetClientBool(target, b_DisplayHud, false);
	Menu menu = new Menu(Handle_MenuEmbaucher);
	
	GetClientName(client, STRING(name));
	menu.SetTitle("%T", "Job_TargetReceiveRequest", LANG_SERVER, name, jobName);
	
	Format(STRING(strInfo), "oui|%i", client);	
	Format(STRING(translation), "%T", "Yes", LANG_SERVER);
	menu.AddItem(strInfo, translation);
	
	Format(STRING(strInfo), "non|%i", client);
	Format(STRING(translation), "%T", "Refuse", LANG_SERVER);
	menu.AddItem(strInfo, translation);
	
	menu.ExitBackButton = true;
	menu.ExitButton = true;
	menu.Display(target, MENU_TIME_FOREVER);
}

public int Handle_MenuEmbaucher(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[64], buffer[2][8];
		menu.GetItem(param, STRING(info));
		ExplodeString(info, "|", buffer, 2, 8);

		int patron = StringToInt(buffer[1]);
		if(IsValidEntity(patron))
		{
			if(StrEqual(buffer[0], "oui"))
			{
				if(rp_GetClientInt(client, i_Job) == 0)
				{
					rp_SetClientInt(client, i_Job, rp_GetClientInt(patron, i_Job));					
					rp_SetClientInt(client, i_Grade, rp_GetJobMaxGrades(rp_GetClientInt(patron, i_Job)));
					
					char jobName[32], gradeName[16]; 
					rp_GetJobName(rp_GetClientInt(client, i_Job), STRING(jobName));
					rp_GetGradeName(rp_GetClientInt(client, i_Grade), rp_GetClientInt(client, i_Job), STRING(gradeName));
					
					char name[64];
					GetClientName(client, STRING(name));
					rp_PrintToChat(patron, "%T", "Boss_Hire_accepted", LANG_SERVER, name);
					
					GetClientName(patron, STRING(name));
					rp_PrintToChat(patron, "%T", "Employe_Hire_accepted", LANG_SERVER, gradeName, jobName, name);
				}
				else
					rp_PrintToChat(client, "%T", "AlreadyHaveJob", LANG_SERVER);
			}
			else if(StrEqual(buffer[0], "non"))
			{
				rp_PrintToChat(client, "%T", "Target_RefuseJob", LANG_SERVER);
				
				char name[64];
				GetClientName(client, STRING(name));
				rp_PrintToChat(patron, "%T", "Boss_TargetRefusedJob", LANG_SERVER, name);
			}
		}
		rp_SetClientBool(client, b_DisplayHud, true);
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

public int Handle_MenuContrat(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[64], buffer[2][64];
		menu.GetItem(param, STRING(info));
		ExplodeString(info, "|", buffer, 2, 64);
		
		rp_SetClientBool(client, b_DisplayHud, false);
		Menu menu1 = new Menu(Handle_MenuContratFinal);
		menu1.SetTitle("Éditer le contrat de %s :", buffer[1]);
		
		char strFormat[128];
		Format(STRING(strFormat), "%s|%s|rang", buffer[0], buffer[1]);
		if(rp_GetClientInt(client, i_Job) == 1)
			menu1.AddItem(strFormat, "Gérer sa promotion", ITEMDRAW_DISABLED);
		else if(rp_GetClientInt(client, i_Job) == 2 || rp_GetClientInt(client, i_Job) == 3)
			menu1.AddItem(strFormat, "Gérér son rang", ITEMDRAW_DISABLED);
			
		for (int i = 2; i <= rp_GetJobMaxGrades(rp_GetClientInt(client, i_Job)); i++)
		{
			char gradeName[16];
			rp_GetGradeName(i, rp_GetClientInt(client, i_Job), STRING(gradeName));
			
			Format(STRING(strFormat), "%s|%s|%i", buffer[0], buffer[1], i);
			menu1.AddItem(strFormat, gradeName);
		}	
		
		Format(STRING(strFormat), "%s|%s|0", buffer[0], buffer[1]);
		menu1.AddItem(strFormat, "Renvoyer");
		
		menu1.ExitBackButton = true;
		menu1.ExitButton = true;
		menu1.Display(client, MENU_TIME_FOREVER);
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if(param == MenuCancel_ExitBack)
			MenuJob(client);
	}
	else if(action == MenuAction_End)
		delete menu;
		
	return 0;
}

public int Handle_MenuContratFinal(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[128], buffer[3][128];
		menu.GetItem(param, STRING(info));
		ExplodeString(info, "|", buffer, 3, 128);
		// buffer[0] : steamid
		// buffer[1] : name
		// buffer[2] : rang ou grade
		
		if(!StrEqual(buffer[2], "rang"))
		{
			int id;
			if(StrEqual(buffer[2], "0"))
				id = 0;
			else
				id = rp_GetClientInt(client, i_Job);
			
			int grade = StringToInt(buffer[2]);			
			int joueur = -1;
			
			LoopClients(i)
			{
				if(StrEqual(buffer[0], g_sSteamID[i]))
					joueur = Client_FindBySteamId(g_sSteamID[i]);
			}
			
			char jobName[32], gradeName[16];
			if(joueur != -1)
			{
				rp_SetClientInt(joueur, i_Job, id);
				rp_SetClientInt(joueur, i_Grade, grade);

				rp_GetJobName(rp_GetClientInt(joueur, i_Job), STRING(jobName));
				rp_GetGradeName(rp_GetClientInt(joueur, i_Grade), rp_GetClientInt(joueur, i_Job), STRING(gradeName));
				
				rp_PrintToChat(joueur, "Vous avez été promu %s (%s) par %N.", gradeName, jobName, client);
				rp_PrintToChat(client, "Vous avez promu %N au rang de %s (%s).", joueur, gradeName, jobName);
			}
			else
			{
				rp_PrintToChat(client, "Le contrat de votre employé a été correctement modifié.");
				SQL_Request(g_DB, "UPDATE `rp_jobs` SET `jobid` = '%i', `gradeid` = '%i' WHERE `steamid` = '%s';", id, grade, buffer[0]);	
			}
			rp_SetClientBool(client, b_DisplayHud, true);
		}
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if(param == MenuCancel_ExitBack)
			MenuEmployes(client);
	}
	else if(action == MenuAction_End)
		delete menu;
		
	return 0;
}

void MenuSalary(int client)
{
	char strFormat[64], strIndex[16];
	int montant[8];
	
	Menu menu = new Menu(Handle_MenuSalary);			
	rp_SetClientBool(client, b_DisplayHud, false);
	menu.SetTitle("Gérer les salaires :");
	
	for (int i = 1; i <= rp_GetJobMaxGrades(rp_GetClientInt(client, i_Job)); i++)
	{
		montant[i] = rp_GetGradeSalary(rp_GetClientInt(client, i_Job), i);
		
		char gradeName[24];
		rp_GetGradeName(rp_GetClientInt(client, i_Job), i, STRING(gradeName));
		
		Format(STRING(strFormat), "%s (%i$)", gradeName, montant[i]);
		Format(STRING(strIndex), "%i", i);
		menu.AddItem(strIndex, strFormat);
	}
	menu.ExitBackButton = true;
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}	

public int Handle_MenuSalary(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[128];
		menu.GetItem(param, STRING(info));
		int grade = StringToInt(info);		
		MenuSalaireEmployes(client, grade);	
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if(param == MenuCancel_ExitBack)
			MenuJob(client);
	}
	else if(action == MenuAction_End)
		delete menu;

	return 0;
}

void MenuSalaireEmployes(int client, int grade)
{
	char gradeName[16];
	rp_GetGradeName(grade, rp_GetClientInt(client, i_Job), STRING(gradeName));
	
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_MenuSalaireEmployes);
	
	int max_sl;
	if(rp_GetJobCapital(rp_GetClientInt(client, i_Job)) > 2000000)
		max_sl = 3800;
	else if(rp_GetJobCapital(rp_GetClientInt(client, i_Job)) > 1000000)
		max_sl = 2420;
	else if(rp_GetJobCapital(rp_GetClientInt(client, i_Job)) > 900000)
		max_sl = 1650;
	else if(rp_GetJobCapital(rp_GetClientInt(client, i_Job)) > 600000)
		max_sl = 1200;
	else if(rp_GetJobCapital(rp_GetClientInt(client, i_Job)) > 450000)
		max_sl = 800;
	else
		max_sl = 600;
	
	int salaireActuel = rp_GetGradeSalary(rp_GetClientInt(client, i_Job), grade);
	
	menu.SetTitle("Modifier le salaire du %s (%i$) :", gradeName, salaireActuel);
	char strFormat[16];
	Format(STRING(strFormat), "50|%i|%i", salaireActuel, grade);
	if(salaireActuel + 50 <= max_sl)
		menu.AddItem(strFormat, "Ajouter 50$");
	else
		menu.AddItem("", "Ajouter 50$", ITEMDRAW_DISABLED);
	Format(STRING(strFormat), "30|%i|%i", salaireActuel, grade);
	if(salaireActuel + 30 <= max_sl)
		menu.AddItem(strFormat, "Ajouter 30$");
	else
		menu.AddItem("", "Ajouter 30$", ITEMDRAW_DISABLED);
	Format(STRING(strFormat), "10|%i|%i", salaireActuel, grade);
	if(salaireActuel + 10 <= max_sl)
		menu.AddItem(strFormat, "Ajouter 10$");
	else
		menu.AddItem("", "Ajouter 10$", ITEMDRAW_DISABLED);
	Format(STRING(strFormat), "5|%i|%i", salaireActuel, grade);
	if(salaireActuel + 5 <= max_sl)
		menu.AddItem(strFormat, "Ajouter 5$");
	else
		menu.AddItem("", "Ajouter 5$", ITEMDRAW_DISABLED);
	Format(STRING(strFormat), "2|%i|%i", salaireActuel, grade);
	if(salaireActuel + 2 <= max_sl)
		menu.AddItem(strFormat, "Ajouter 2$");
	else
		menu.AddItem("", "Ajouter 2$", ITEMDRAW_DISABLED);
	Format(STRING(strFormat), "1|%i|%i", salaireActuel, grade);
	if(salaireActuel + 1 <= max_sl)
		menu.AddItem(strFormat, "Ajouter 1$");
	else
		menu.AddItem("", "Ajouter 1$", ITEMDRAW_DISABLED);
	Format(STRING(strFormat), "-1|%i|%i", salaireActuel, grade);
	if(salaireActuel - 1 >= SMIC)
		menu.AddItem(strFormat, "Retirer 1$");
	else
		menu.AddItem("", "Retirer 1$", ITEMDRAW_DISABLED);
	Format(STRING(strFormat), "-2|%i|%i", salaireActuel, grade);
	if(salaireActuel - 2 >= SMIC)
		menu.AddItem(strFormat, "Retirer 2$");
	else
		menu.AddItem("", "Retirer 2$", ITEMDRAW_DISABLED);
	Format(STRING(strFormat), "-5|%i|%i", salaireActuel, grade);
	if(salaireActuel - 5 >= SMIC)
		menu.AddItem(strFormat, "Retirer 5$");
	else
		menu.AddItem("", "Retirer 5$", ITEMDRAW_DISABLED);
	Format(STRING(strFormat), "-10|%i|%i", salaireActuel, grade);
	if(salaireActuel - 10 >= SMIC)
		menu.AddItem(strFormat, "Retirer 10$");
	else
		menu.AddItem("", "Retirer 10$", ITEMDRAW_DISABLED);
	Format(STRING(strFormat), "-30|%i|%i", salaireActuel, grade);
	if(salaireActuel - 30 >= SMIC)
		menu.AddItem(strFormat, "Retirer 30$");
	else
		menu.AddItem("", "Retirer 30$", ITEMDRAW_DISABLED);
	Format(STRING(strFormat), "-50|%i|%i", salaireActuel, grade);
	if(salaireActuel - 50 >= SMIC)
		menu.AddItem(strFormat, "Retirer 50$");
	else
		menu.AddItem("", "Retirer 50$", ITEMDRAW_DISABLED);
	menu.ExitBackButton = true;
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Handle_MenuSalaireEmployes(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[64], buffer[3][16];
		menu.GetItem(param, STRING(info));
		ExplodeString(info, "|", STRING(buffer), sizeof(buffer[]));
		
		int montant = StringToInt(buffer[0]);
		int salaireActuel = StringToInt(buffer[1]);
		int grade = StringToInt(buffer[2]);
		int salaireFinal;
		
		if(montant > 0)
			salaireFinal = salaireActuel + montant;
		else
			salaireFinal = salaireActuel - montant;		
		
		rp_SetGradeSalary(rp_GetClientInt(client, i_Job), grade, salaireFinal);
		
		PrintHintText(client, "Salaire modifié avec succès (%i$).", salaireFinal);
		
		LoopClients(i)
		{
			if(!IsClientValid(i))
				continue;
			else if(rp_GetClientInt(i, i_Job) != rp_GetClientInt(client, i_Job))
				continue;	
			if(rp_GetClientInt(i, i_Grade) == grade)
				LoadSalaire(i);
		}
		
		MenuSalaireEmployes(client, grade);
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if(param == MenuCancel_ExitBack)
			MenuEmployes(client);
	}
	else if(action == MenuAction_End)
		delete menu;
		
	return 0;
}

public Action Cmd_Graffiti(int client, int args)
{
	#if DEBUG
		Translation_DebugCommand(client);
	#endif
	
	if(client == 0)
	{
		Translation_PrintNoAvailable();
		return Plugin_Handled;
	}
	
	if(rp_GetClientInt(client, i_Graffiti) <= 0)
	{
		rp_PrintToChat(client, "Vous n'avez pas de bombe de peinture.");
		PrintHintText(client, "Rendez-vous au loto pour acheter une bombe de peinture.");
		return Plugin_Handled;
	}
	else if(rp_GetClientInt(client, i_GraffitiIndex) == 0 || rp_GetClientInt(client, i_GraffitiIndex) == 1)
	{
		rp_PrintToChat(client, "Vous n'avez pas de style de graffiti.");
		PrintHintText(client, "Rendez-vous au loto pour acheter une bombe de peinture.");
		return Plugin_Handled;
	}
	else if(!g_bCanGraffiti[client])
	{
		PrintHintText(client, "Vous avez déjà graffé.\nPatientez ...");
		return Plugin_Handled;
	}
	
	float eyePosition[3], visionOrigin[3], vectorDist[3];
	GetClientEyePosition(client, eyePosition);
	PointVision(client, visionOrigin);
	MakeVectorFromPoints(visionOrigin, eyePosition, vectorDist);
	
	if(GetVectorLength(vectorDist) > 100.0)
	{
		PrintHintText(client, "Rapprochez-vous ...");
		return Plugin_Handled;
	}
	
	SprayGraffiti(visionOrigin, rp_GetClientInt(client, i_GraffitiIndex));
	TE_SendToAll();
	
	PrecacheSound("player/sprayer.wav");
	EmitSoundToAll("player/sprayer.wav", client, _, _, _, 1.0);
	
	rp_SetClientInt(client, i_Graffiti, rp_GetClientInt(client, i_Graffiti) - 1);
	PrintHintText(client, "Graffiti restant : %i", rp_GetClientInt(client, i_Graffiti));
	
	g_bCanGraffiti[client] = false;
	CreateTimer(60.0, TimerCanGraffiti, client);
	
	return Plugin_Continue;
}

public Action TimerCanGraffiti(Handle timer, int client)
{
	if(IsClientValid(client))
		g_bCanGraffiti[client] = true;
		
	return Plugin_Handled;
}

public Action Cmd_Build(int client, int args)
{
	#if DEBUG
		Translation_DebugCommand(client);
	#endif
	
	if(client == 0)
	{
		Translation_PrintNoAvailable();
		return Plugin_Handled;
	}
	
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_MenuBuild);
	
	menu.SetTitle("%T", "MenuBuild_title", LANG_SERVER);
	
	Call_StartForward(Forward.OnBuild);
	Call_PushCell(menu);
	Call_PushCell(client);
	Call_Finish();
	
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
	
	return Plugin_Continue;
}

public int Handle_MenuBuild(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[64];
		menu.GetItem(param, STRING(info));
		
		Call_StartForward(Forward.OnBuildHandle);
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

public Action Cmd_Out(int client, int args)
{
	#if DEBUG
		Translation_DebugCommand(client);
	#endif
	
	if(client == 0)
	{
		Translation_PrintNoAvailable();
		return Plugin_Handled;
	}
	
	char zonename[64];
	rp_GetClientString(client, sz_ZoneName, STRING(zonename));
	
	int target = GetClientAimTarget(client, true);
	if(!IsClientValid(target))
	{
		Translation_PrintInvalidTarget(client);
		return Plugin_Handled;
	}
	else if(Distance(client, target) > 350)
	{
		Translation_PrintTooFar(client);
		return Plugin_Handled;	
	}	
	else if(rp_GetClientInt(client, i_Zone) != rp_GetClientInt(target, i_Zone))
	{
		Translation_PrintInvalidTarget(client);
		return Plugin_Handled;	
	}		
	
	if(isZoneProprietaire(client) && rp_GetClientInt(client, i_ZoneAppart) == 0)
		Out(client, target);
	else if(IsAppartOwner(client) && rp_GetClientInt(client, i_ZoneAppart) != 0)
		OutLocation(client, target, "appartment");
	else if(IsVillaOwner(client) && rp_GetClientInt(client, i_ZoneVilla) != 0)
		OutLocation(client, target, "villa");
	else if(IsHotelOwner(client) && rp_GetClientInt(client, i_ZoneHotel) != 0)
		OutLocation(client, target, "hotel");
	else
	{
		rp_PrintToChat(client, "Vous n'êtes pas dans votre zone appropriée / vous n'avez pas la permission.");
		return Plugin_Handled;
	}	
	
	return Plugin_Handled;
}

public Action Cmd_Help(int client, int args)
{
	#if DEBUG
		Translation_DebugCommand(client);
	#endif
	
	if(client == 0)
	{
		Translation_PrintNoAvailable();
		return Plugin_Handled;
	}
	
	Menu_Help(client);

	return Plugin_Handled;
}

void Menu_Help(int client)
{
	rp_SetClientBool(client, b_DisplayHud, false);	
	Menu menu = new Menu(Handle_MenuHelp);
	menu.SetTitle("Roleplay - AIDE");
	menu.AddItem("items", "Aide items");
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Handle_MenuHelp(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[64];
		menu.GetItem(param, STRING(info));
		
		if(StrEqual(info, "items"))
			MenuHelpItem(client);
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

void MenuHelpItem(int client)
{
	Menu submenu = new Menu(Handle_MenuHelpItem);
	submenu.SetTitle("AIDE - Items");
	submenu.AddItem("description", "Descriptions");
	submenu.AddItem("image", "Aperçu");
	submenu.ExitButton = true;
	submenu.ExitBackButton = true;
	submenu.Display(client, MENU_TIME_FOREVER);
}

public int Handle_MenuHelpItem(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[64];
		menu.GetItem(param, STRING(info));
		
		MenuHelpSelectItem(client, info);
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if(param == MenuCancel_ExitBack)	
			Menu_Help(client);
	}
	else if(action == MenuAction_End)
		delete menu;
	
	return 0;
}

void MenuHelpSelectItem(int client, char[] extra)
{
	char strIndex[128];
	
	Menu submenu = new Menu(Handle_MenuHelpSelectItem);
	submenu.SetTitle("AIDE - Items");
	
	LoopItems(i)
	{
		if(!rp_IsItemValidIndex(i))
			continue;
			
		char tmp[64];
		rp_GetItemData(i, item_name, STRING(tmp));
		
		Format(STRING(strIndex), "%s|%i", extra, i);
		submenu.AddItem(strIndex, tmp);
	}	
		
	submenu.ExitButton = true;
	submenu.ExitBackButton = true;
	submenu.Display(client, MENU_TIME_FOREVER);
}

public int Handle_MenuHelpSelectItem(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[64];
		menu.GetItem(param, STRING(info));
		
		MenuHelpItemFinal(client, info);
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if(param == MenuCancel_ExitBack)	
			MenuHelpItem(client);
	}
	else if(action == MenuAction_End)
		delete menu;

	return 0;
}

void MenuHelpItemFinal(int client, char[] extra)
{
	char buffer[2][32];
	ExplodeString(extra, "|", STRING(buffer), sizeof(buffer[]));
	
	if(StrEqual(buffer[0], "description"))
	{
		Menu submenu = new Menu(Handle_MenuHelpItemFinal);
		submenu.SetTitle("AIDE - Items");
		
		char tmp[64];
		rp_GetItemData(StringToInt(buffer[1]), item_description, STRING(tmp));
		submenu.AddItem("", tmp, ITEMDRAW_DISABLED);
			
		submenu.ExitButton = true;
		submenu.ExitBackButton = true;
		submenu.Display(client, MENU_TIME_FOREVER);
	}
	else
	{
		char url[128];
		Format(STRING(url), "https://enemy-down.eu/image/roleplay/item_%s.png", buffer[1]);
		ShowPanel2(client, 0, "<img src='%s'/>", url);
		ShowPanel2(client, 5, "<img src='%s'/>", url);
		MenuHelpItem(client);
	}	
}

public int Handle_MenuHelpItemFinal(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[64];
		menu.GetItem(param, STRING(info));
		MenuHelpItem(client);
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if(param == MenuCancel_ExitBack)	
			MenuHelpItem(client);
	}
	else if(action == MenuAction_End)
		delete menu;
	
	return 0;
}

public Action Cmd_Hire(int client, int args)
{
	#if DEBUG
		Translation_DebugCommand(client);
	#endif
	
	if(client == 0)
	{
		Translation_PrintNoAvailable();
		return Plugin_Handled;
	}
	
	char zonename[64];
	rp_GetClientString(client, sz_ZoneName, STRING(zonename));
	
	int target = GetClientAimTarget(client, true);
	if(!IsClientValid(target))
	{
		Translation_PrintInvalidTarget(client);
		return Plugin_Handled;
	}
	else if(Distance(client, target) > 350)
	{
		Translation_PrintTooFar(client);
		return Plugin_Handled;	
	}	
	else if(rp_GetClientInt(target, i_Job) != 0)
	{
		rp_PrintToChat(client, "Ce joueur a déjà un métier.");
		return Plugin_Handled;	
	}	

	char jobname[64], strIndex[64];
	rp_GetJobName(rp_GetClientInt(client, i_Job), STRING(jobname));
	
	rp_SetClientBool(target, b_DisplayHud, false);
	Menu menu = new Menu(Handle_MenuHire);
	menu.SetTitle("%N vous a proposé une offre d'emploi dans %s\nSigner le contrat ?", client, jobname);
	
	Format(STRING(strIndex), "yes|%i", client);
	menu.AddItem(strIndex, "Oui");
	
	Format(STRING(strIndex), "no|%i", client);
	menu.AddItem(strIndex, "Non");
	
	menu.ExitButton = false;
	menu.Display(target, MENU_TIME_FOREVER);
	
	return Plugin_Handled;
}

public int Handle_MenuHire(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[64], buffer[2][64];
		menu.GetItem(param, STRING(info));
		ExplodeString(info, "|", buffer, 2, 64);
		int employeur = StringToInt(buffer[1]);
		
		if(StrEqual(buffer[0], "yes"))
		{
			rp_SetClientInt(client, i_Job, rp_GetClientInt(employeur, i_Job));
			rp_SetClientInt(client, i_Grade, rp_GetJobMaxGrades(rp_GetClientInt(client, i_Job)));
			
			char jobname[64], gradename[32];
			rp_GetJobName(rp_GetClientInt(employeur, i_Job), STRING(jobname));
			rp_GetGradeName(rp_GetClientInt(client, i_Grade), rp_GetClientInt(employeur, i_Job), STRING(gradename));
			
			rp_PrintToChat(client, "Vous travaillez désormais dans le secteur: {lightgreen}%s", jobname);
			rp_PrintToChat(employeur, "Vous avez embauché %N.", client);
			
			char message[256];
			Format(STRING(message), "%N a embauché %N en tant que %s %s", employeur, client, gradename, jobname);
			rp_LogToDiscord(message);
		}
		else
			rp_PrintToChat(employeur, "%N a refusé votre offre d'emploi.", client);		
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

public Action Cmd_AddNote(int client, int args)
{
	#if DEBUG
		Translation_DebugCommand(client);
	#endif
	
	if(client == 0)
	{
		Translation_PrintNoAvailable();
		return Plugin_Handled;
	}
	else if(rp_GetClientInt(client, i_Job) == 0)
	{
		Translation_PrintNoAccess(client);
		return Plugin_Handled;
	}	
	else if (args < 1)
	{
		rp_PrintToChat(client, "Utilisation: !addnote <text>");
		return Plugin_Handled;
	}
	
	char argument[128];
	GetCmdArgString(STRING(argument));
	
	if(strlen(argument) > 128)
	{
		Translation_PrintNoAccess(client);
		return Plugin_Handled;
	}
	
	SQL_Request(g_DB, "INSERT IGNORE INTO `rp_shownote` (`Id`, `jobid`, `text`) VALUES (NULL, '%i', '%s');", rp_GetClientInt(client, i_Job), argument);
	
	return Plugin_Handled;
}

public Action Cmd_Vol(int client, int args)
{	
	#if DEBUG
		Translation_DebugCommand(client);
	#endif
	
	if(client == 0)
	{
		Translation_PrintNoAvailable();
		return Plugin_Handled;
	}	
	else if(rp_GetClientInt(client, i_Job) != 2 && rp_GetClientInt(client, i_Job) != 3)
	{
		Translation_PrintNoAccess(client);
		return Plugin_Handled;
	}
	
	int target = GetClientAimTarget(client, true);
	if(!IsClientValid(target))
	{
		Translation_PrintInvalidTarget(client);
		return Plugin_Handled;
	}
	else if(rp_GetClientInt(target, i_Job) == rp_GetClientInt(client, i_Job))
	{
		rp_PrintToChat(client, "Vous ne pouvez pas voler un collègue.");
		return Plugin_Handled;
	}	
	else if(rp_GetClientBool(target, b_IsAfk))
	{
		rp_PrintToChat(client, "Vous ne pouvez pas voler une personne inactive.");
		return Plugin_Handled;
	}
	else if(Distance(client, target) > 100.0)
	{
		Translation_PrintTooFar(client);
		return Plugin_Handled;
	}
	else if(rp_GetClientInt(client, i_JailTime) > 0)
	{
		rp_PrintToChat(client, "Vous ne pouvez pas voler en prison.");
		return Plugin_Handled;
	}	
	else if(!g_bCanVol[client])
	{
		rp_PrintToChat(client, "Vous devez patienter {lightgreen}%0.3f{default} secondes afin de voler.", FindConVar("rp_cooldown_vol").FloatValue);
		return Plugin_Handled;
	}
	
	static int RandomItem[MAXITEMS];
	int VOL_MAX, amount, money, job, prix;	
	money = rp_GetClientInt(target, i_Money);
	job = rp_GetClientInt(client, i_Job);
	VOL_MAX = (money+rp_GetClientInt(target, i_Bank)) / 200;
	amount = GetRandomInt(1, VOL_MAX);
	
	if(VOL_MAX > 0 && money >= 1)
	{		
		CreateTimer(FindConVar("rp_cooldown_vol").FloatValue, CoolDownVol, client);
		
		rp_PrintToChat(client, "Vous avez volé %d$.", amount);
		rp_PrintToChat(target, "Quelqu'un vous a volé %d$.", amount);
		
		rp_SetClientInt(client, i_Money, rp_GetClientInt(client, i_Money) + amount / 2);
		rp_SetJobCapital(rp_GetClientInt(client, i_Job), rp_GetJobCapital(rp_GetClientInt(client, i_Job)) + amount / 2);			
		
		rp_SetClientInt(target, i_Money, rp_GetClientInt(target, i_Money) - amount);
		
		g_bCanVol[client] = false;
		
		rp_SetClientInt(client, i_LastVolTarget, target);
		rp_SetClientInt(target, i_LastVolTime, GetTime());
		rp_SetClientInt(client, i_LastVolAmount, amount);
		rp_SetClientInt(target, i_LastVol, client);
	}
	else if(VOL_MAX > 0 && money <= 0 && rp_GetClientInt(client, i_Job) == 2 && !rp_GetClientBool(target, b_IsNew))
	{
		amount = 0;
		int itemRDM = GetRandomInt(0, MAXITEMS);
		CreateTimer(FindConVar("rp_cooldown_vol").FloatValue, CoolDownVol, client);
		
		LoopItems(i)
		{			
			if(!rp_IsItemValidIndex(i))
				continue;
			
			if( rp_GetClientItem(target, i, false) <= 0 )
				continue;
	
			if( job == 0|| job == 91 || job == 101 || job == 181 )
				continue;
			if( job == 51 && !(rp_GetClientItem(target, i, false) >= 1 && Math_GetRandomInt(0, 1) == 1) ) // TODO: Double vérif voiture
				continue;
			
			RandomItem[amount++] = i;
		}
		
		if(amount == 0) 
		{
			rp_PrintToChat(client, "Ce joueur n'a pas d'argent, ni d'item sur lui.");
			return Plugin_Stop;
		}
		
		int i = RandomItem[ Math_GetRandomInt(0, (amount-1)) ];			
		char itemprice[64];
		rp_GetItemData(i, item_price, STRING(itemprice));
		prix = StringToInt(itemprice) / 2;
		
		rp_SetClientItem(target, i, rp_GetClientItem(target, i, false) - 1, false);
		rp_SetClientItem(client, i, rp_GetClientItem(client, i, false) + 1, false);
			
		char itemname[64];
		rp_GetItemData(itemRDM, item_name, STRING(itemname));
		
		rp_PrintToChat(client, "Vous avez volé 1 %s à %N", itemname, target);
		rp_PrintToChat(target, "Un voleur vous a volé 1 %s", itemname);
		
		g_bCanVol[client] = false;
		rp_SetClientInt(client, i_LastVolTarget, target);
		rp_SetClientInt(target, i_LastVolTime, GetTime());
		rp_SetClientInt(target, i_LastVol, client);	
		
		rp_SetJobCapital(2, rp_GetJobCapital(2) + prix);
		rp_SetJobCapital(job, rp_GetJobCapital(job) - prix);
	}
	else 
		rp_PrintToChat(client, "%N n'a pas d'argent sur lui.", target);	
	
	return Plugin_Handled;
}

public Action CoolDownVol(Handle timer, any client)
{
	rp_SetClientInt(client, i_LastVolAmount, 0);
	rp_SetClientInt(client, i_LastVolTarget, 0);
	rp_SetClientInt(client, i_LastVolTime, 0);
	rp_SetClientInt(client, i_LastVolArme, 0);
	
	g_bCanVol[client] = true;
	rp_PrintToChat(client, "Vous pouvez désormais voler.");
	
	return Plugin_Handled;
}	

public Action Cmd_VolArme(int client, int args)
{
	#if DEBUG
		Translation_DebugCommand(client);
	#endif
	
	if(client == 0)
	{
		Translation_PrintNoAvailable();
		return Plugin_Handled;
	}	
	else if(rp_GetClientInt(client, i_Job) != 2 && rp_GetClientInt(client, i_Job) != 3)
	{
		Translation_PrintNoAccess(client);
		return Plugin_Handled;
	}
	
	int target = GetClientAimTarget(client, true);
	if(!IsClientValid(target))
	{
		Translation_PrintInvalidTarget(client);
		return Plugin_Handled;
	}	
	else if(!g_bCanVol[client])
	{
		rp_PrintToChat(client, "Vous devez patienter {lightgreen}%0.3f{default} secondes afin de voler.", FindConVar("rp_cooldown_vol").FloatValue);
		return Plugin_Handled;
	}			
	else if(rp_GetClientBool(target, b_IsAfk))
	{
		rp_PrintToChat(client, "Vous ne pouvez pas voler une personne inactive.");
		return Plugin_Handled;
	}
	else if(Distance(client, target) > 100.0)
	{
		Translation_PrintTooFar(client);
		return Plugin_Handled;
	}
	else if(rp_GetClientInt(client, i_JailTime) > 0)
	{
		rp_PrintToChat(client, "Vous ne pouvez pas voler en prison.");
		return Plugin_Handled;
	}
	
	if(rp_GetClientInt(client, i_Job) != rp_GetClientInt(target, i_Job) || rp_GetClientInt(client, i_Job) == rp_GetClientInt(target, i_Job) && rp_GetClientInt(client, i_Grade) < rp_GetClientInt(target, i_Grade))
	{
		rp_SetClientInt(client, i_LastVolTarget, target);
		rp_SetClientInt(target, i_LastVolTime, GetTime());
		
		int weapon = Client_GetActiveWeapon(target);
		char entClass[64];
		Entity_GetClassName(weapon, STRING(entClass));
		if(StrContains(entClass, "knife") != -1)
		{
			rp_PrintToChat(client, "Vous ne pouvez pas voler son couteau.");
			return Plugin_Handled;
		}
		else if(StrContains(entClass, "fists") != -1)
			return Plugin_Handled;
		
		rp_SetClientInt(client, i_LastVolArme, weapon);
		
		PrintHintText(client, "Vous tentez de voler l'arme de %N, restez près de lui.", target);			
		
		rp_SetClientInt(client, i_LastVolArme, target);
		
		SetEntityRenderColor(client, 255, 20, 20, 192);
		CreateTimer(10.0, TimerFinVolArme, client);
	}
	else
		rp_PrintToChat(client, "Vous ne pouvez pas voler un supérieur !");
	
	return Plugin_Handled;
}

public Action TimerFinVolArme(Handle timer, any client)
{
	if(IsClientValid(client) && IsValidEntity(client))
	{
		rp_SetDefaultClientColor(client);
		
		char entityClassname[128];
		Entity_GetClassName(rp_GetClientInt(client, i_LastVolArme), STRING(entityClassname));
		
		if(IsValidEntity(rp_GetClientInt(client, i_LastVolArme)))
			rp_DeleteWeapon(client, rp_GetClientInt(client, i_LastVolArme));
		
		int arme = GivePlayerItem(client, entityClassname);
		SetEntityRenderMode(arme, RENDER_TRANSCOLOR);
		SetEntityRenderColor(arme, 255, 20, 20, 255);
		
		PrintHintText(client, "Vous avez volé l'arme de %N.", rp_GetClientInt(client, i_LastVolTarget));
		
		rp_PrintToChat(rp_GetClientInt(client, i_LastVolTarget), "Votre arme vient d'être {lightred}voler {default}de force.");
		return Plugin_Stop;
	}
	else
	{
		if(Distance(client, rp_GetClientInt(client, i_LastVolTarget)) >= 100.0)
		{
			SetEntityRenderColor(client, 255, 255, 255, 255);			

			rp_PrintToChat(client, "Le vol de l'arme de %N a été interrompu.", rp_GetClientInt(client, i_LastVolTarget));
			return Plugin_Stop;
		}
		else
			return Plugin_Continue;
	}
}

public Action Command_GPS(int client, int args)
{
	if(client != 0)
	{
		Translation_PrintNoAccess(client);
		return Plugin_Handled;
	}
	else if (args < 4) 
	{
		PrintToServer("Utilisation: effect_gps <player> <pos1> <pos2> <pos3>");
		return Plugin_Handled;
	}
		
	float destination[3]; 
	
	char arg1[64];
	GetCmdArg(1, STRING(arg1));
	
	int target = FindPlayer(client, arg1, true);
	if(target == -1)
		return Plugin_Handled;
	
	char arg2[64];
	GetCmdArg(2, STRING(arg2));
	destination[0] = StringToFloat(arg2);
	
	char arg3[64];
	GetCmdArg(3, STRING(arg3));
	destination[1] = StringToFloat(arg3);
	
	char arg4[64];
	GetCmdArg(4, STRING(arg4));
	destination[2] = StringToFloat(arg4);
	
	LoopClients(i)
	{
		if(IsClientValid(target))
		{
			EmitGPSTrain(target, destination);
		}
	}
	
	return Plugin_Handled;	
}
/***************************************************************************************

									C L I E N T - S I D E

***************************************************************************************/

public void OnClientPutInServer(int client)
{
	g_bCanGraffiti[client] = true;
	force[client].distance = true;
	force[client].target = -1;
	force[client].canForce = true;
	g_bCanVol[client] = true;
}

public void OnClientAuthorized(int client, const char[] auth) 
{	
	strcopy(g_sSteamID[client], sizeof(g_sSteamID[]), auth);
}

public void RP_OnClientDeath(int attacker, int victim, const char[] weapon, bool headshot)
{
	if(rp_GetClientBool(victim, b_IsThirdPerson))
		rp_SetClientBool(victim, b_IsThirdPerson, false);
}