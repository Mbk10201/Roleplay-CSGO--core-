/*
*   Roleplay CS:GO de Benito est mis à disposition selon les termes de la licence Creative Commons Attribution .
* - Pas d’Utilisation Commerciale 
* - Partage dans les Mêmes Conditions 4.0 International.
*
*   Merci de respecter le travail fourni par le ou les auteurs 
*   https://enemy-down.eu/ - benitalpa1020@gmail.com
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

enum struct Data_Forward {
	GlobalForward OnHud;
	GlobalForward OnJailTimeFinish;
}	
Data_Forward Forward;

Handle Timer_HUD[MAXPLAYERS + 1] = { null, ... };
Handle synchud;
Handle Cookie_Hud;
float pourcentEntities;
int MaxEntities, nbEntities;
int countCar, countCarPolice;
// Methodmap Constructor
Roleplay m_iClient[MAXPLAYERS + 1];

/***************************************************************************************

							P L U G I N  -  I N F O

***************************************************************************************/
public Plugin myinfo = 
{
	name = "Roleplay - Hud", 
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
	PrintToServer("[REQUIREMENT] HUD ✓");
	
	/*------------------------------------FORWADS------------------------------------*/
	Forward.OnHud = new GlobalForward("RP_AddTextToHud", ET_Event, Param_String, Param_Cell, Param_Cell);
	Forward.OnJailTimeFinish = new GlobalForward("RP_OnJailTimeFinish", ET_Event,  Param_Cell);
	/*-------------------------------------------------------------------------------*/
	
	/*----------------------------------Commands-------------------------------*/
	RegConsoleCmd("hud", Command_Hud);
	RegConsoleCmd("disablehud", Command_DisableHud);
	/*-------------------------------------------------------------------------------*/
	
	synchud = CreateHudSynchronizer();
	Cookie_Hud = RegClientCookie("hud_type", "Hud type display", CookieAccess_Protected);
	
	MaxEntities = GetMaxEntities();
}

public void OnMapStart()
{
	CreateTimer(1.0, CountEntities, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

/***************************************************************************************

									C A L L B A C K

***************************************************************************************/
public Action Command_DisableHud(int client, int args)
{
	if (client == 0)
	{
		PrintToServer("%T", "Command_NotAvailable", LANG_SERVER);
		return Plugin_Handled;
	}
	
	if(rp_GetClientBool(client, b_DisplayHud))
		rp_SetClientBool(client, b_DisplayHud, false);
	else
		rp_SetClientBool(client, b_DisplayHud, true);
		
	return Plugin_Handled;	
}		

public Action Command_Hud(int client, int args)
{
	if (client == 0)
	{
		PrintToServer("%T", "Command_NotAvailable", LANG_SERVER);
		return Plugin_Handled;
	}
	
	if(IsClientValid(client))
	{
		char sTmp[2];
		rp_SetClientBool(client, b_DisplayHud, false);
		Menu menu = new Menu(Handle_Command_Hud);
		menu.SetTitle("Hud - Type");
		
		if(rp_GetHudType(client) == HUD_PANEL)
			menu.AddItem("", "Panel(*)", ITEMDRAW_DISABLED);
		else
		{
			Format(STRING(sTmp), "%d", HUD_PANEL);
			menu.AddItem(sTmp, "Panel");
		}
		
		if(rp_GetHudType(client) == HUD_HINT)
			menu.AddItem("", "Hint(*)", ITEMDRAW_DISABLED);
		else
		{
			Format(STRING(sTmp), "%d", HUD_HINT);
			menu.AddItem(sTmp, "Hint");
		}

		if(rp_GetHudType(client) == HUD_MSG)
			menu.AddItem("", "HudMsg(*)", ITEMDRAW_DISABLED);
		else
		{
			Format(STRING(sTmp), "%d", HUD_MSG);
			menu.AddItem(sTmp, "HudMsg");
		}
			
		if(rp_GetGame() == Engine_CSS)
		{
			if(rp_GetHudType(client) == HUD_KEYHINT)
				menu.AddItem("", "KeyHint(*)", ITEMDRAW_DISABLED);
			else
			{
				Format(STRING(sTmp), "%d", HUD_KEYHINT);
				menu.AddItem(sTmp, "KeyHint");
			}
		}		
			
		if(rp_GetHudType(client) == HUD_NONE)
			menu.AddItem("", "None(*)", ITEMDRAW_DISABLED);
		else
		{
			Format(STRING(sTmp), "%d", HUD_NONE);
			menu.AddItem(sTmp, "None");
		}

		menu.ExitButton = true;
		menu.Display(client, MENU_TIME_FOREVER);
	}	
	
	return Plugin_Handled;
}	

public int Handle_Command_Hud(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[64];
		menu.GetItem(param, STRING(info));
		
		SetClientCookie(client, Cookie_Hud, info);
		rp_SetHudType(client, view_as<HUD_TYPE>(StringToInt(info)));
		TrashTimer(Timer_HUD[client], true);
		Timer_HUD[client] = CreateTimer(1.0, Hud_Display, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);	
		rp_SetClientBool(client, b_DisplayHud, true);
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

/***************************************************************************************

									C L I E N T - S I D E

***************************************************************************************/

public void OnClientPutInServer(int client)
{
	// MethodMap Constructor
	m_iClient[client] = Roleplay(client);
	
	#if DEBUG
		PrintToServer("%N Init HUD", client);
	#endif
	
	char buffer[64];
	GetClientCookie(client, Cookie_Hud, STRING(buffer));	
	rp_SetHudType(client, view_as<HUD_TYPE>(StringToInt(buffer)));
	
	rp_SetClientBool(client, b_DisplayHud, true);
	Timer_HUD[client] = CreateTimer(1.0, Hud_Display, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}	

public void OnClientDisconnect(int client) 
{
	rp_SetClientBool(client, b_DisplayHud, false);
	TrashTimer(Timer_HUD[client], true);
}

public Action Hud_Display(Handle timer, int client)
{
	if(IsClientValid(client, true))
	{
		if(rp_GetClientInt(client, i_JailTime) != 0)
		{
			int calcul = rp_GetClientInt(client, i_JailTime) - 1;
			rp_SetClientInt(client, i_JailTime, rp_GetClientInt(client, i_JailTime) - 1);
			if(calcul == 0)
			{
				m_iClient[client].SetSkin();
				Call_StartForward(Forward.OnJailTimeFinish);
				Call_PushCell(client);
				Call_Finish();
				rp_PrintToChat(client, "Votre peine de prison est arrivé à écheance, on espère que vous suiverez le droit chemin.");
				if(rp_GetClientBool(client, b_SpawnJob) && !rp_GetClientBool(client, b_HasBonusTomb) && rp_GetJobSearch() != rp_GetClientInt(client, i_Job))
					SpawnJob(client);
				else if(rp_GetClientBool(client, b_HasBonusTomb))	
				{
					if(rp_GetClientInt(client, i_Appart) != -1 && rp_GetClientInt(client, i_Villa) == -1)
						SpawnLocation(client, "appartment");
					else if(rp_GetClientInt(client, i_Villa) != -1)
						SpawnLocation(client, "villa");
				}
			}	
		}
		if(rp_GetClientInt(client, i_JailTime) == 60)
			rp_PrintToChat(client, "{lightgreen}Vous aller bientôt être libéré.");
		
		char clantag[32];
		rp_GetGradeClantag(rp_GetClientInt(client, i_Job), rp_GetClientInt(client, i_Grade), STRING(clantag));
		
		if(!rp_GetClientBool(client, b_IsAfk))
		{
			if(rp_GetClientInt(client, i_Job) == 1 && GetClientTeam(client) == CS_TEAM_T 
			|| rp_GetClientInt(client, i_Job) == 7 && GetClientTeam(client) == CS_TEAM_T)
				CS_SetClientClanTag(client, "Chômeur");
			else if(rp_GetClientInt(client, i_Job) == 1 && GetClientTeam(client) == CS_TEAM_CT 
			||  rp_GetClientInt(client, i_Job) == 7 && GetClientTeam(client) == CS_TEAM_CT)		
				CS_SetClientClanTag(client, clantag);
			else if(rp_GetClientInt(client, i_Job) != 1 || rp_GetClientInt(client, i_Job) != 7 && GetClientTeam(client) == CS_TEAM_T)
				CS_SetClientClanTag(client, clantag);		
		}	
		else
		{
			CS_SetClientClanTag(client, "<< AFK >>");
		}	

		char cookie_value[64];
		GetClientCookie(client, FindClientCookie("rpv_hud_time"), STRING(cookie_value));
		int value = StringToInt(cookie_value);
		if(value != 0)
		{
			char hud_time[64], monthname[32];
			GetMonthName(rp_GetTime(i_month), STRING(monthname));
			Format(STRING(hud_time), "%i%i:%i%i %i %s %i", rp_GetTime(i_hour1), rp_GetTime(i_hour2), rp_GetTime(i_minute1), rp_GetTime(i_minute2), rp_GetTime(i_day), monthname, rp_GetTime(i_year));
			
			if(value == 1)
				ShowHudMsg(client, hud_time, 255, 255, 255, 0.01, 0.01, 1.05);
			else if(value == 2)	
				ShowHudMsg(client, hud_time, 255, 255, 255, -1.0, 1.0, 1.05);
		}
		
		if(rp_GetClientBool(client, b_DisplayHud))
		{
			if(GetClientVehicle(client) == -1)
			{
				char symbol[6];
				int number = GetRandomInt(0, 7);
				switch(number)
				{
					case 0:Format(STRING(symbol), "✩");
					case 1:Format(STRING(symbol), "✧");
					case 2:Format(STRING(symbol), "●");
					case 3:Format(STRING(symbol), "♫");
					case 4:Format(STRING(symbol), "☭");
					case 5:Format(STRING(symbol), "✶");
					case 6:Format(STRING(symbol), "❖");
					case 7:Format(STRING(symbol), "◬");
				}
				
				switch(rp_GetHudType(client))
				{			
					case HUD_PANEL:
					{
						Panel panel = new Panel();
						char strText[128];
						
						Format(STRING(strText), "   %s Roleplay (1.0 ALPHA) %s", symbol, symbol);			
						panel.SetTitle(strText);			
						panel.DrawText("▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬");
						
						if(rp_GetClientInt(client, i_JailTime) == 0)
						{
							Format(STRING(strText), "%T", "Hud_Money", LANG_SERVER, rp_GetClientInt(client, i_Money));
							panel.DrawText(strText);
							
							Format(STRING(strText), "%T", "Hud_Bank", LANG_SERVER, rp_GetClientInt(client, i_Bank));
							panel.DrawText(strText);
							
							if(rp_GetClientInt(client, i_SalaryBonus) == 0)
								Format(STRING(strText), "%T", "Hud_Salary", LANG_SERVER, rp_GetClientInt(client, i_Salary));
							else					
								Format(STRING(strText), "%T", "Hud_SalaryBonus", LANG_SERVER, rp_GetClientInt(client, i_Salary), rp_GetClientInt(client, i_SalaryBonus));	
							panel.DrawText(strText);
							
							// SPACER
							panel.DrawText("\n             ");
							
							char jobname[64], gradename[64];
							rp_GetJobName(rp_GetClientInt(client, i_Job), STRING(jobname));
							rp_GetGradeName(rp_GetClientInt(client, i_Job), rp_GetClientInt(client, i_Grade), STRING(gradename));
							
							Format(STRING(strText), "%T", "Hud_Job", LANG_SERVER, gradename, jobname);				
							panel.DrawText(strText);
							
							char rankname[32];
							rp_GetRank(rp_GetClientInt(client, i_Rank), rank_name, STRING(rankname));
							
							Format(STRING(strText), "Rang: %i %s", rp_GetClientInt(client, i_Rank), rankname);				
							panel.DrawText(strText);
							
							// SPACER
							panel.DrawText("\n             ");
							
							char zone[64];
							rp_GetClientString(client, sz_ZoneName, STRING(zone));			
							Format(STRING(strText), "%T", "Hud_Zone", LANG_SERVER, zone);
							panel.DrawText(strText);		
							
							if(rp_GetAdmin(client) == ADMIN_FLAG_OWNER)
							{
								char strSpecial[32] = "";
								if(pourcentEntities > 95.0)
									Format(STRING(strSpecial), "[CRITIQUE]");
								else if(pourcentEntities > 92.0)
									Format(STRING(strSpecial), "[DANGER]");
								
								Format(STRING(strText), "Entités : %.2f%% [%i/%i] %s", pourcentEntities, nbEntities, MaxEntities, strSpecial);
								panel.DrawText(strText);		
							}
							
							/*char pushedString[64];
							Call_StartForward(Forward.OnHud);
							Call_PushString(pushedString);
							Call_PushCell(sizeof(pushedString));
							if(!StrEqual(pushedString, ""))
							{
								Format(STRING(strText), "%s", pushedString);
								panel.DrawText(strText);
							}	
							Call_Finish();*/
							
							
						}
						else
						{
							panel.DrawText("Portland Police Département");
							
							char raison[64];
							rp_GetRaisonName(rp_GetClientInt(client, i_JailRaisonID), STRING(raison));
							Format(STRING(strText), "Raison: %s", raison);
							panel.DrawText(strText);
							
							char strTime[64];
							StringTime(rp_GetClientInt(client, i_JailTime), STRING(strTime));
							
							Format(STRING(strText), "Temps: %s", strTime);
							panel.DrawText(strText);
						}			

						panel.DrawText("▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬");
						panel.Send(client, HandleNothing, 1);
					}
					case HUD_HINT:
					{
						if(rp_GetClientInt(client, i_JailTime) == 0)
						{
							char tempTxt[512], money[64], bank[64], rank[128], zone[64], jobFinal[64], salary[64];
							Format(STRING(money), "%T", "Hud_Money", LANG_SERVER, rp_GetClientInt(client, i_Money));
							Format(STRING(bank), "%T", "Hud_Bank", LANG_SERVER, rp_GetClientInt(client, i_Bank));
							
							char jobname[32], gradename[32];
							rp_GetJobName(rp_GetClientInt(client, i_Job), STRING(jobname));
							rp_GetGradeName(rp_GetClientInt(client, i_Job), rp_GetClientInt(client, i_Grade), STRING(gradename));		
			
							if(rp_GetClientInt(client, i_Job) == 0)
								Format(STRING(jobFinal), "%T", "Hud_Job", LANG_SERVER, "", jobname);
							else
								Format(STRING(jobFinal), "%T", "Hud_Job", LANG_SERVER, gradename, jobname);
	
							char rankname[32];
							rp_GetRank(rp_GetClientInt(client, i_Rank), rank_name, STRING(rankname));
							Format(STRING(rank), "Rang: %i %s", rp_GetClientInt(client, i_Rank), rankname);	
							
							rp_GetClientString(client, sz_ZoneName, STRING(zone));			
							Format(STRING(zone), "%T", "Hud_Zone", LANG_SERVER, zone);
							
							if(rp_GetClientInt(client, i_SalaryBonus) == 0)
								Format(STRING(salary), "Salaire : %i$", rp_GetClientInt(client, i_Salary));
							else
								Format(STRING(salary), "Salaire : %i$ + %i$", rp_GetClientInt(client, i_Salary), rp_GetClientInt(client, i_SalaryBonus));
								
							HintColorToCss(STRING(tempTxt));
							Format(STRING(tempTxt), "<font color='#E22000'>%s</font> Roleplay <font color='#E22000'>%s</font>\n--------------\n%s\n%s\n%s\n%s\n%s\n%s\n--------------", symbol, symbol, money, bank, salary, jobFinal, rank, zone); 
							
							/*#if DEBUG
								PrintHintText(client, "Test");
							#else
								PrintHintText(client, "%s", tempTxt);				
							#endif*/
							
							PrintHintText(client, "%s", tempTxt);		
						}	
					}
					case HUD_MSG:
					{
						if(rp_GetClientInt(client, i_JailTime) == 0)
						{
							char tempTxt[512], money[64], bank[64], rank[128], jobFinal[64], salary[64];
							Format(STRING(money), "%T", "Hud_Money", LANG_SERVER, rp_GetClientInt(client, i_Money));
							Format(STRING(bank), "%T", "Hud_Bank", LANG_SERVER, rp_GetClientInt(client, i_Bank));
							
							char jobname[32], gradename[32];
							rp_GetJobName(rp_GetClientInt(client, i_Job), STRING(jobname));
							rp_GetGradeName(rp_GetClientInt(client, i_Job), rp_GetClientInt(client, i_Grade), STRING(gradename));			
							
							if(rp_GetClientInt(client, i_Job) == 0)
								Format(STRING(jobFinal), "%T", "Hud_Job", LANG_SERVER, "", jobname);
							else
								Format(STRING(jobFinal), "%T", "Hud_Job", LANG_SERVER, gradename, jobname);	
							
							char rankname[32];
							rp_GetRank(rp_GetClientInt(client, i_Rank), rank_name, STRING(rankname));
							Format(STRING(rank), "Rang: %i %s", rp_GetClientInt(client, i_Rank), rankname);	
							
							char zone[64];
							rp_GetClientString(client, sz_ZoneName, STRING(zone));			
							Format(STRING(zone), "%T", "Hud_Zone", LANG_SERVER, zone);
							
							if(rp_GetClientInt(client, i_SalaryBonus) == 0)
								Format(STRING(salary), "Salaire : %i$", rp_GetClientInt(client, i_Salary));
							else
								Format(STRING(salary), "Salaire : %i$ + %i$", rp_GetClientInt(client, i_Salary), rp_GetClientInt(client, i_SalaryBonus));	
							
							Format(STRING(tempTxt), "-|%sRoleplay%s|-\n-|%s|\n-|%s|\n-|%s|\n-|%s|\n-|%s|\n-|%s|", symbol, symbol, money, bank, salary, jobFinal, rank, zone);
							SetHudTextParams(0.0, 0.4, 1.0, 255, 255, 255, 255, 0, 0.00, 0.3, 0.4);
							ShowSyncHudText(client, synchud, tempTxt);
						}	
					}	
					case HUD_KEYHINT:
					{
						if(rp_GetClientInt(client, i_JailTime) == 0)
						{
							char tempTxt[512], money[64], bank[64], rank[128], zone[64], jobFinal[64], salary[64];
							Format(STRING(money), "%T", "Hud_Money", LANG_SERVER, rp_GetClientInt(client, i_Money));
							Format(STRING(bank), "%T", "Hud_Bank", LANG_SERVER, rp_GetClientInt(client, i_Bank));
							
							char jobname[32], gradename[32];
							rp_GetJobName(rp_GetClientInt(client, i_Job), STRING(jobname));
							rp_GetGradeName(rp_GetClientInt(client, i_Job), rp_GetClientInt(client, i_Grade), STRING(gradename));		
			
							if(rp_GetClientInt(client, i_Job) == 0)
								Format(STRING(jobFinal), "%T", "Hud_Job", LANG_SERVER, "", jobname);
							else
								Format(STRING(jobFinal), "%T", "Hud_Job", LANG_SERVER, gradename, jobname);
	
							char rankname[32];
							rp_GetRank(rp_GetClientInt(client, i_Rank), rank_name, STRING(rankname));
							Format(STRING(rank), "Rang: %i %s", rp_GetClientInt(client, i_Rank), rankname);	
							
							rp_GetClientString(client, sz_ZoneName, STRING(zone));			
							Format(STRING(zone), "%T", "Hud_Zone", LANG_SERVER, zone);
							
							if(rp_GetClientInt(client, i_SalaryBonus) == 0)
								Format(STRING(salary), "Salaire : %i$", rp_GetClientInt(client, i_Salary));
							else
								Format(STRING(salary), "Salaire : %i$ + %i$", rp_GetClientInt(client, i_Salary), rp_GetClientInt(client, i_SalaryBonus));	
							
							Format(STRING(tempTxt), "%s - Roleplay - %s\n--------------\n%s\n%s\n%s\n%s\n%s\n%s\n--------------", symbol, symbol, money, bank, salary, jobFinal, rank, zone); 
							
							Handle panelBuffer = StartMessageOne("KeyHintText", client);
							BfWriteByte(panelBuffer, 1);
							BfWriteString(panelBuffer, tempTxt);
							EndMessage();	
						}	
					}
				}
			}
			else
			{
				char translation[64];
				int car = GetClientVehicle(client);
				
				VehicleType vehicle_type;
				Vehicles_GetVehicleTypeOfVehicle(car, vehicle_type);
				
				switch(rp_GetHudType(client))
				{
					case HUD_PANEL:
					{
						Panel panel = new Panel();
						char strText[128];
									
						panel.SetTitle(vehicle_type.name);
						
						Format(STRING(strText), "─────────────────────────");
						panel.DrawText(strText);
						
						Format(STRING(translation), "%T", "HudCar_Speed", LANG_SERVER, Vehicles_GetVehicleSpeed(car));
						Format(STRING(strText), "- %s", translation);						
						panel.DrawText(strText);
						
						Format(STRING(translation), "%T", "HudCar_Fuel", LANG_SERVER, Vehicles_GetVehicleFuel(car));
						Format(STRING(strText), "- %s", translation);								
						panel.DrawText(strText);
						
						Format(STRING(translation), "%T", "HudCar_Health", LANG_SERVER, Vehicles_GetVehicleHealth(car));
						Format(STRING(strText), "- %s", translation);								
						panel.DrawText(strText);
						
						Format(STRING(translation), "%T", "HudCar_Distance", LANG_SERVER, rp_GetVehicleFloat(car, car_km));
						Format(STRING(strText), "- %s", translation);						
						panel.DrawText(strText);
						
						panel.DrawText("─────────────────────────");
						
						panel.Send(client, HandleNothing, 1);
					}
					case HUD_HINT:
					{
						char speed[32];
						Format(STRING(translation), "%T", "HudCar_Speed", LANG_SERVER, Vehicles_GetVehicleSpeed(car));
						Format(STRING(speed), "- %s", translation);						
						
						char fuel[32];
						Format(STRING(translation), "%T", "HudCar_Fuel", LANG_SERVER, Vehicles_GetVehicleFuel(car));
						Format(STRING(fuel), "- %s", translation);								
						
						char health[32];
						Format(STRING(translation), "%T", "HudCar_Health", LANG_SERVER, Vehicles_GetVehicleHealth(car));
						Format(STRING(health), "- %s", translation);								
						
						char distance[32];
						Format(STRING(translation), "%T", "HudCar_Distance", LANG_SERVER, rp_GetVehicleFloat(car, car_km));
						Format(STRING(distance), "- %s", translation);
						
						PrintHintText(client, "%s\n%s\n%s\n%s\n%s", vehicle_type.name, speed, fuel, health, distance);
					}
					case HUD_MSG:
					{
						char speed[32];
						Format(STRING(translation), "%T", "HudCar_Speed", LANG_SERVER, Vehicles_GetVehicleSpeed(car));
						Format(STRING(speed), "- %s", translation);						
						
						char fuel[32];
						Format(STRING(translation), "%T", "HudCar_Fuel", LANG_SERVER, Vehicles_GetVehicleFuel(car));
						Format(STRING(fuel), "- %s", translation);								
						
						char health[32];
						Format(STRING(translation), "%T", "HudCar_Health", LANG_SERVER, Vehicles_GetVehicleHealth(car));
						Format(STRING(health), "- %s", translation);								
						
						char distance[32];
						Format(STRING(translation), "%T", "HudCar_Distance", LANG_SERVER, rp_GetVehicleFloat(car, car_km));
						Format(STRING(distance), "- %s", translation);
						
						char tempTxt[256];
						Format(STRING(tempTxt), "-|%s|-\n%s\n%s\n%s\n%s", vehicle_type.name, speed, fuel, health, distance);
						SetHudTextParams(0.0, 0.4, 1.0, 255, 255, 255, 255, 0, 0.00, 0.3, 0.4);
						ShowSyncHudText(client, synchud, tempTxt);
					}
					case HUD_KEYHINT:
					{
						char strText[128];
						
						char speed[32];
						Format(STRING(translation), "%T", "HudCar_Speed", LANG_SERVER, Vehicles_GetVehicleSpeed(car));
						Format(STRING(speed), "- %s", translation);						
						
						char fuel[32];
						Format(STRING(translation), "%T", "HudCar_Fuel", LANG_SERVER, Vehicles_GetVehicleFuel(car));
						Format(STRING(fuel), "- %s", translation);								
						
						char health[32];
						Format(STRING(translation), "%T", "HudCar_Health", LANG_SERVER, Vehicles_GetVehicleHealth(car));
						Format(STRING(health), "- %s", translation);								
						
						char distance[32];
						Format(STRING(translation), "%T", "HudCar_Distance", LANG_SERVER, rp_GetVehicleFloat(car, car_km));
						Format(STRING(distance), "- %s", translation);
						
						Format(STRING(strText), "-|%s|-\n%s\n%s\n%s\n%s", vehicle_type.name, speed, fuel, health, distance);
						
						Handle panelBuffer = StartMessageOne("KeyHintText", client);
						BfWriteByte(panelBuffer, 1);
						BfWriteString(panelBuffer, strText);
						EndMessage();
					}	
				}	
			}
		}	
	}
	
	return Plugin_Handled;
}	

public Action CountEntities(Handle timer)
{
	nbEntities = MaxClients;
	countCar = 0;
	countCarPolice = 0;
	
	char entClass[64], entName[64];
	LoopEntities(i)
	{
		if(IsValidEntity(i))
		{
			nbEntities++;
			
			Entity_GetClassName(i, entClass, sizeof(entClass));
			if(StrEqual(entClass, "prop_vehicle_driveable"))
			{
				countCar++;
				
				Entity_GetName(i, entName, sizeof(entName));
				if(StrContains(entName, "police") != -1)
					countCarPolice++;
			}
		}
	}
	
	pourcentEntities = float(nbEntities) * 100.0 / float(MaxEntities);
	
	if(nbEntities > 2045)
	{
		char mapName[128];
		GetCurrentMap(mapName, sizeof(mapName));
		ForceChangeLevel(mapName, "+2045 entites");
		PrintToServer("ENTITES CRITIQUE, REDEMARAGE DE LA MAP ! (+2045 entites)");
	}
	
	return Plugin_Handled;
}