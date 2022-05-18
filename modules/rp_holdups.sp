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

							P L U G I N  -  D E F I N E S

***************************************************************************************/
#define	QUEST_TEAMS			5
#define	TEAM_NONE			0
#define	TEAM_INVITATION		1
#define	TEAM_BRAQUEUR		2
#define	TEAM_BRAQUEUR_DEAD	3
#define	TEAM_POLICE			4
#define	TEAM_HOSTAGE		5
#define	TEAM_NAME1			"Braqueur"
#define	BRAQUAGE_WEAPON		"weapon_p90"

/***************************************************************************************

							P L U G I N  -  I N C L U D E S

***************************************************************************************/
#include <roleplay_csgo.inc>

/***************************************************************************************

							G L O B A L  -  V A R S

***************************************************************************************/
bool g_bHoldup = false;
bool isComplice[MAXPLAYERS + 1];
int g_iTimerHoldup;
int nbBraqueurs;
ConVar HoldupTiming;
ConVar HoldupNeededCT;
ConVar Holdup_gain_min;
ConVar Holdup_gain_max;
ConVar Holdup_Timing;
char steamID[MAXPLAYERS + 1][32];
int 
	g_iPlayerTeam[2049], 
	g_stkTeam[QUEST_TEAMS + 1][MAXPLAYERS + 1], 
	g_stkTeamCount[QUEST_TEAMS + 1], 
	g_iMaskEntity[MAXPLAYERS + 1];
Database g_DB;

/***************************************************************************************

							P L U G I N  -  I N F O

***************************************************************************************/
public Plugin myinfo = 
{
	name = "Roleplay - Holdup",
	author = "Benito",
	description = "Roleplay - Holdup",
	version = "1.0",
	url = "https://github.com/Mbk10201"
};

/***************************************************************************************

							P L U G I N  -  E V E N T S

***************************************************************************************/
public void OnPluginStart()
{
	LoadTranslation();
	Database.Connect(GotDatabase, "roleplay");
	PrintToServer("[MODULE] HOLDUP ✓");	

	RegConsoleCmd("holdup", Cmd_Holdup);
	HoldupTiming = CreateConVar("rp_holdup_refresh", "60", "Time to wait to refresh for a new holdup");
	HoldupNeededCT = CreateConVar("rp_holdup_policiers", "2", "Number of police officers required to trigger a holdup");
	Holdup_gain_min = CreateConVar("rp_holdup_gain_min", "12000", "Minimum amount that will be done randomly between the maximum amount");
	Holdup_gain_max = CreateConVar("rp_holdup_gain_max", "15000", "Maximum amount that will be done randomly between the minimum amount");
	Holdup_Timing = CreateConVar("rp_holdup_timing", "150", "Maximum waiting time before the end of the holdup");
	AutoExecConfig(true, "rp_holdup", "roleplay");
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
	}
}

public void OnClientAuthorized(int client, const char[] auth) 
{	
	strcopy(steamID[client], sizeof(steamID[]), auth);
}

public Action Cmd_Holdup(int client, int args)
{
	if (IsClientValid(client))
	{
		if (rp_GetClientInt(client, i_Job) == 2)
		{
			if (rp_GetClientInt(client, i_Zone) == 15 || rp_GetClientInt(client, i_Zone) == 144)
			{
				if (!g_bHoldup)
				{
					int CTCount;
					LoopClients(i)
					{
						if(!IsClientValid(i))
							continue;
						
						if (rp_GetClientInt(i, i_Job) == 1)
						{
							if (!rp_GetClientBool(i, b_IsAfk))
							{
								CTCount++;
							}
						}
					}
					if (CTCount >= HoldupNeededCT.IntValue)
					{
						g_iTimerHoldup = Holdup_Timing.IntValue;
						SetEntityRenderColor(client, 255, 0, 0, 255);
						g_bHoldup = true;
						isComplice[client] = true;
						//CreateTimer(1.0, Timer_Holdup, client, TIMER_REPEAT);
						attachMask(client);
						
						char zone[64];
						rp_GetClientString(client, sz_ZoneName, STRING(zone));
								
						char Translation[128];
						
						CPrintToChatAll("{lightred}─────────────────────────────────────────");
						Format(STRING(Translation), "%T", "Holdup_Start", LANG_SERVER, zone);
						CPrintToChatAll("           		%s           		", Translation);
						Format(STRING(Translation), "%T", "Holdup_Actual", LANG_SERVER);
						CPrintToChatAll("           		%s          	    ", Translation);
						CPrintToChatAll("{lightred}─────────────────────────────────────────");
						
						LoopClients(i)
						{
							if(!IsClientValid(i))
								continue;
							
							if(rp_GetClientInt(i, i_Job) == rp_GetClientInt(client, i_Job) && rp_GetClientInt(i, i_Zone) == rp_GetClientInt(client, i_Zone))
							{
								SetEntityRenderColor(i, 255, 0, 0, 255);
								isComplice[i] = true;
								nbBraqueurs++;
								GivePlayerItem(i, BRAQUAGE_WEAPON);
							}
						}
						
						Format(STRING(Translation), "%T", "Holdup_Police_Info", LANG_SERVER);
						PrintHintTextToAll(Translation);
					}
					else
					{
						char Translation[128];
						Format(STRING(Translation), "%T", "Holdup_Requires", LANG_SERVER, HoldupNeededCT.IntValue);
						rp_PrintToChat(client, "%s", Translation);
					}
				}
				else
				{
					char Translation[128];
					Format(STRING(Translation), "%T", "Holdup_NotAvailable", LANG_SERVER);
					rp_PrintToChat(client, "%s", Translation);
				}
			}
			else
			{
				char Translation[128];
				Format(STRING(Translation), "%T", "Holdup_NotInZone", LANG_SERVER);
				rp_PrintToChat(client, "%s", Translation);
			}
		}
		else
		{
			char Translation[128];
			Format(STRING(Translation), "%T", "Holdup_NoAcces", LANG_SERVER);
			rp_PrintToChat(client, "%s", Translation);
		}
	}
	else
	{
		char Translation[128];
		Format(STRING(Translation), "%T", "Holdup_NoAlive", LANG_SERVER);
		rp_PrintToChat(client, "%s", Translation);
	}
	return Plugin_Handled;
}

public void RP_TimerEverySecond()
{
	if(g_bHoldup)
	{
		if (0 < g_iTimerHoldup)
		{
			g_iTimerHoldup--;
			LoopClients(i)
			{
				char zone[64];
				rp_GetClientString(i, sz_ZoneName, STRING(zone));	
				
				if(!IsClientValid(i, true))
					continue;
	
				if(isComplice[i])
				{
					char Translation[128];
					Format(STRING(Translation), "%T", "Holdup_Active", LANG_SERVER, g_iTimerHoldup);
					PrintHintText(i, "%s", Translation);
				}
			}
		}
		else
		{
			int iGain = GetRandomInt(Holdup_gain_min.IntValue, Holdup_gain_max.IntValue);
			
			LoopClients(i)
			{
				if(!IsClientValid(i, true))
					continue;
				
				char zone[64];
				rp_GetClientString(i, sz_ZoneName, STRING(zone));	
			
				char Translation[64];
				CPrintToChat(i, "{lightred}─────────────────────────────────────────");
				Format(STRING(Translation), "%T", "Holdup_Start", LANG_SERVER, zone);
				CPrintToChat(i, "           		%s           		", Translation);
				Format(STRING(Translation), "%T", "Holdup_Succes", LANG_SERVER);
				CPrintToChat(i, "           		%s           		", Translation);
				
				if(isComplice[i])
				{
					Format(STRING(Translation), "%T", "Holdup_AmountRobbers", LANG_SERVER, nbBraqueurs);
					CPrintToChat(i, "           		%s           		", Translation);
					
					rp_SetClientInt(i, i_Money, rp_GetClientInt(i, i_Money) + iGain / nbBraqueurs);
					SetEntityRenderColor(i, 255, 255, 255, 255);
					
					Format(STRING(Translation), "%T", "Holdup_Gain", LANG_SERVER, iGain / nbBraqueurs);
					CPrintToChat(isComplice[i], "           		%s           		", Translation);
					isComplice[i] = false;
				}	
				CPrintToChatAll("{lightred}─────────────────────────────────────────");
			}	
			
	
			CreateTimer(HoldupTiming.FloatValue, Timer_Holdup_Refresh);
		}
	}	
}

/*public Action Timer_Holdup(Handle timer, any client)
{
	char zone[64];
	rp_GetClientString(client, sz_ZoneName, STRING(zone));
	
	if (IsClientInGame(client))
	{
		if (IsPlayerAlive(client))
		{
			if (rp_GetClientInt(client, i_Zone) == 15 || rp_GetClientInt(client, i_Zone) == 14)
			{
				if (0 < g_iTimerHoldup[client])
				{													
					g_iTimerHoldup[client]--;
					LoopClients(i)
					{
						if(!IsClientValid(i))
							continue;
						
						if(isComplice[i])
						{
							char Translation[128];
							Format(STRING(Translation), "%T", "Holdup_Active", LANG_SERVER, g_iTimerHoldup[client]);
							PrintHintText(i, "%s", Translation);
						}	
					}	
				}
				else
				{
					int iGain = GetRandomInt(Holdup_gain_min.IntValue, Holdup_gain_max.IntValue);
					
					char Translation[64];
					CPrintToChatAll("{lightred}─────────────────────────────────────────");
					Format(STRING(Translation), "%T", "Holdup_Start", LANG_SERVER, zone);
					CPrintToChatAll("           		%s           		", Translation);
					Format(STRING(Translation), "%T", "Holdup_Succes", LANG_SERVER);
					CPrintToChatAll("           		%s           		", Translation);
					Format(STRING(Translation), "%T", "Holdup_AmountRobbers", LANG_SERVER, nbBraqueurs);
					CPrintToChatAll("           		%s           		", Translation);
					
					LoopClients(i)
					{
						if(!IsClientValid(i))
							continue;
						
						if(isComplice[i])
						{
							rp_SetClientInt(i, i_Money, rp_GetClientInt(i, i_Money) + iGain / nbBraqueurs);
							SetEntityRenderColor(i, 255, 255, 255, 255);
							
							Format(STRING(Translation), "%T", "Holdup_Gain", LANG_SERVER, iGain / nbBraqueurs);
							CPrintToChat(isComplice[i], "           		%s           		", Translation);
							isComplice[i] = false;
						}	
					}
					CPrintToChatAll("{lightred}─────────────────────────────────────────");
					

					CreateTimer(HoldupTiming.FloatValue, Timer_Holdup_Refresh);
					TrashTimer(timer, true);
				}
			}
			else
			{
				LoopClients(i)
				{
					if(!IsClientValid(i))
						continue;
					
					if(isComplice[i])
						SetEntityRenderColor(i, 255, 255, 255, 255);
				}		
				CPrintToChatAll("{lightred}─────────────────────────────────────────");
				CPrintToChatAll("           		{green}Holdup {yellow}%s          	       ", zone);
				CPrintToChatAll("           		{lightred}Échec          	                      ");
				CPrintToChatAll("           	{green}Braqueur Principal Hors Zone          	       ");
				CPrintToChatAll("{lightred}─────────────────────────────────────────");
				TrashTimer(timer, true);
				g_bHoldup = false;
			}
		}
		else
		{
			LoopClients(i)
			{
				if(!IsClientValid(i))
					continue;
				
				if(isComplice[i])
					SetEntityRenderColor(i, 255, 255, 255, 255);
			}		
			
			char Translation[64];
			CPrintToChatAll("{lightred}─────────────────────────────────────────");
			Format(STRING(Translation), "%T", "Holdup_Start", LANG_SERVER, zone);
			CPrintToChatAll("           		%s           		", Translation);
			Format(STRING(Translation), "%T", "Holdup_Fail", LANG_SERVER, zone);
			CPrintToChatAll("           		%s           		", Translation);
			Format(STRING(Translation), "%T", "Holdup_RobberDeath", LANG_SERVER);
			CPrintToChatAll("           		%s           		", Translation);
			CPrintToChatAll("{lightred}─────────────────────────────────────────");
			TrashTimer(timer, true);
			g_bHoldup = false;
		}
	}
	else
	{
		LoopClients(i)
		{
			if(!IsClientValid(i))
				continue;
			
			if(isComplice[i])
				SetEntityRenderColor(i, 255, 255, 255, 255);
		}		
		
		char Translation[64];
		CPrintToChatAll("{lightred}─────────────────────────────────────────");
		Format(STRING(Translation), "%T", "Holdup_Start", LANG_SERVER, zone);
		CPrintToChatAll("           		%s           		", Translation);
		Format(STRING(Translation), "%T", "Holdup_Fail", LANG_SERVER, zone);
		CPrintToChatAll("           		%s           		", Translation);
		Format(STRING(Translation), "%T", "Holdup_RobberDisconnected", LANG_SERVER, zone);
		CPrintToChatAll("           		%s           		", Translation);
		CPrintToChatAll("{lightred}─────────────────────────────────────────");
		TrashTimer(timer, true);
		g_bHoldup = false;
	}
}*/

public Action Timer_Holdup_Refresh(Handle timer)
{
	g_bHoldup = false;
	
	char Translation[64];
	Format(STRING(Translation), "%T", "Holdup_Refresh", LANG_SERVER);
	CPrintToChatAll("%s %s", Translation);
}

void attachMask(int client) 
{
	int rand = GetRandomInt(1, 7);
	char model[128];
	switch (rand) {
		case 1: Format(model, sizeof(model), "models/player/holiday/facemasks/facemask_skull.mdl");
		case 2: Format(model, sizeof(model), "models/player/holiday/facemasks/facemask_wolf.mdl");
		case 3: Format(model, sizeof(model), "models/player/holiday/facemasks/facemask_tiki.mdl");
		case 4: Format(model, sizeof(model), "models/player/holiday/facemasks/facemask_samurai.mdl");
		case 5: Format(model, sizeof(model), "models/player/holiday/facemasks/facemask_hoxton.mdl");
		case 6: Format(model, sizeof(model), "models/player/holiday/facemasks/facemask_dallas.mdl");
		case 7: Format(model, sizeof(model), "models/player/holiday/facemasks/facemask_chains.mdl");
	}
	
	int ent = CreateEntityByName("prop_dynamic");
	DispatchKeyValue(ent, "classname", "rp_braquage_mask");
	DispatchKeyValue(ent, "model", model);
	DispatchSpawn(ent);
	
	Entity_SetOwner(ent, client);
	
	SetVariantString("!activator");
	AcceptEntityInput(ent, "SetParent", client, client);
	
	SetVariantString("facemask");
	AcceptEntityInput(ent, "SetParentAttachment");
	
	SDKHook(ent, SDKHook_SetTransmit, Hook_SetTransmit);
	g_iMaskEntity[client] = ent;
}

public Action Hook_SetTransmit(int entity, int client) 
{
	if (Entity_GetOwner(entity) == client && rp_GetClientBool(client, b_IsThirdPerson) == true)
		return Plugin_Handled;
	return Plugin_Continue;
}

public void OnClientDisconnect(int client) 
{
	if(g_iPlayerTeam[client] == TEAM_BRAQUEUR)
		OnBraqueurKilled(client);
	else if(g_iPlayerTeam[client] == TEAM_POLICE) {
		
		char szQuery[512];
		Format(szQuery, sizeof(szQuery), "UPDATE `rp_economy` SET `money` = 'money - 1000' WHERE steamid = '%s';", steamID[client]);
		g_DB.Query(SQL_CheckForErrors, szQuery);	
	}
		
	removeClientTeam(client);
}

void OnBraqueurKilled(int client) 
{
	//rp_SetClientBool(client, b_SpawnToGrave, false);
	
	addClientToTeam(client, TEAM_BRAQUEUR_DEAD);
	
	/*if( g_bHasHelmet ) {
		LogToGame("[BRAQUAGE] [MORT] %L est un braqueur et a été tué.", client);
		
		SetEntProp(client, Prop_Send, "m_bHasHelmet", 0);
		if( g_iMaskEntity[client] > 0 && IsValidEdict(g_iMaskEntity[client]) && IsValidEntity(g_iMaskEntity[client]) )
			AcceptEntityInput(g_iMaskEntity[client], "Kill");
		g_iMaskEntity[client] = 0;
	}*/
}

void removeClientTeam(int client) 
{
	if( g_iPlayerTeam[client] != TEAM_NONE ) 
	{
		for (int i = 0; i < g_stkTeamCount[g_iPlayerTeam[client]]; i++) 
		{
			if( g_stkTeam[ g_iPlayerTeam[client] ][ i ] == client ) 
			{
				for (; i < g_stkTeamCount[g_iPlayerTeam[client]]; i++) 
				{
					g_stkTeam[g_iPlayerTeam[client]][i] = g_stkTeam[g_iPlayerTeam[client]][i + 1];
				}
				g_stkTeamCount[g_iPlayerTeam[client]]--;
				break;
			}
		}
		
		g_iPlayerTeam[client] = TEAM_NONE;
	}
}

void addClientToTeam(int client, int team) 
{
	removeClientTeam(client);
	
	if(team != TEAM_NONE)
		g_stkTeam[team][ g_stkTeamCount[team]++ ] = client;
	
	g_iPlayerTeam[client] = team;
}