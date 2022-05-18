/*
*   Roleplay CS:GO de Benito est mis à disposition selon les termes de la licence Creative Commons Attribution .
* - Pas d’Utilisation Commerciale 
* - Partage dans les Mêmes Conditions 4.0 International.
*
*   Fondé(e) sur une œuvre à https://github.com/Benito1020/Roleplay-CS-GO
*   Les autorisations au-delà du champ de cette licence peuvent être obtenues à https://steamcommunity.com/id/xsuprax/.
*
*   Merci de respecter le travail fourni par le ou les auteurs 
*   https://vr-hosting.fr - benitalpa1020@gmail.com
*/

/***************************************************************************************

							C O M P I L E  -  O P T I O N S

***************************************************************************************/
#pragma semicolon 1
#pragma newdecls required

/***************************************************************************************

							P L U G I N  -  I N C L U D E S

***************************************************************************************/
#include <sourcemod>
#include <sdktools>
#include <roleplay_csgo>
#include <multicolors>

/***************************************************************************************

							G L O B A L  -  V A R S

***************************************************************************************/
ConVar EventStart = null;
char EventEnCours[64];
int timing;

enum struct event_data {
	char name[64];
	int players;
}

event_data GetEvent[enum_event_type];

/***************************************************************************************

							P L U G I N  -  I N F O

***************************************************************************************/
public Plugin myinfo = 
{
	name = "Roleplay - [MODULE]Event Management", 
	author = "Benito",
	description = "Event Management",
	version = "1.0",
	url = "https://steamcommunity.com/id/xsuprax/"
};

/***************************************************************************************

							P L U G I N  -  E V E N T S

***************************************************************************************/
public void OnPluginStart()
{
	LoadTranslation();
		
	EventStart = CreateConVar("rp_event_start", "30.0", "Temps d'attente avant le demarrage d'un event");
	AutoExecConfig(true, "rp_event_manager");
	timing = GetConVarInt(EventStart);
	
	SetEventsStuff();
}

public void OnMapEnd()
{
	SetEventsStuff();
}	

public void SetEventsStuff()
{		
	rp_SetEventType(event_type_none);
	
	GetEvent[event_type_none].name = "Aucun";
	GetEvent[event_type_murder].name = "Murder";	
	GetEvent[event_type_buildwars].name = "Buildwars";
}		

public void RP_OnPlayerSpawn(int client)
{
	rp_SetClientBool(client, b_isEventParticipant, false);
}	

public void RP_OnRoleplay(Menu menu, int client)
{
	if(rp_GetAdmin(client) != ADMIN_FLAG_NONE) 
	{
		if(rp_GetEventType() == event_type_none)
			menu.AddItem("event", "Créer un event");
		else
			menu.AddItem("stop", "Stoper l'event en cours");	
	}		
}		

public int RP_OnRoleplayHandle(int client, const char[] info)
{
	if(StrEqual(info, "event"))
		BuildMenuEvents(client);
	else if(StrEqual(info, "stop"))	
		StopEvent();
}	

int StopEvent()
{
	LoopClients(i)
	{
		if(rp_GetClientBool(i, b_isEventParticipant))
		{
			if(rp_GetEventType() == event_type_buildwars)
				CPrintToChat(i, "%s L'event {darkred}Buildwars{default} a été arreté par un admin.", TEAM);
			else if(rp_GetEventType() == event_type_murder)
			{
				CPrintToChat(i, "%s L'event {darkred}Murder{default} a été arreté par un admin.", TEAM);
				rp_ShutDownMurder();
			}	
		}		
	}	
	
	rp_SetEventType(event_type_none);
}	

Menu BuildMenuEvents(int client) 
{
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(DoBuildEvents);
	menu.SetTitle("Roleplay - Events");
	menu.AddItem("murder", "Murder");
	menu.AddItem("buildwars", "BuildWars");
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}	

public int DoBuildEvents(Menu menu, MenuAction action, int client, int param)
{
	if (action == MenuAction_Select)
	{
		char info[32];
		menu.GetItem(param, STRING(info));
		
		if(StrEqual(info, "murder"))
			LaunchEventRequest("Murder");
		else if(StrEqual(info, "buildwars"))
			LaunchEventRequest("Buildwars");
	}	
	else if (action == MenuAction_Cancel)
	{
		if (param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
	}
	else if (action == MenuAction_End)
		delete menu;
}

Menu LaunchEventRequest(char[] event)
{
	LoopClients(i)
	{
		char strFormat[64];
		rp_SetClientBool(i, b_menuOpen, true);
		
		Menu menu = new Menu(DoLaunchEventRequest);
		menu.SetTitle("Event %s", event);
		menu.AddItem("", "Voulez-vous participer ?", ITEMDRAW_DISABLED);		
		
		Format(STRING(strFormat), "oui|%s", event);
		menu.AddItem(strFormat, "Oui");		
		menu.AddItem("non", "Non");
		menu.ExitButton = true;
		menu.Display(i, 30);
		
		Format(STRING(EventEnCours), "%s", event);
		CPrintToChat(i, "%s L'event {darkred}%s{default} va commencer dans {green}%i{default} secondes.", TEAM, EventEnCours, GetConVarInt(EventStart));		
		CreateTimer(GetConVarFloat(EventStart), ExecEvent, i, TIMER_FLAG_NO_MAPCHANGE);
	}	
}

public int DoLaunchEventRequest(Menu menu, MenuAction action, int client, int param)
{
	if (action == MenuAction_Select)
	{
		char info[32], buffer[2][64];
		menu.GetItem(param, STRING(info));
		ExplodeString(info, "|", buffer, 2, 64);
		
		if(StrEqual(buffer[0], "oui"))
		{
			rp_SetClientBool(client, b_isEventParticipant, true);
			CPrintToChat(client, "%s Vous avez été rajouté à la liste des participants.", TEAM);
			rp_SetClientBool(client, b_DisplayHud, true);
			CreateTimer(1.0, ShowEventStarting, client, TIMER_REPEAT);
			GetEvent[rp_GetEventType()].players++;
		}	
		else if(StrEqual(buffer[0], "non"))
			return;
	}	
	else if (action == MenuAction_Cancel)
	{
		if (param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
	}
	else if (action == MenuAction_End)
		delete menu;
}

public Action ExecEvent(Handle timer, any client)
{
	if(IsClientValid(client))
	{	
		if(StrEqual(EventEnCours, "Murder"))
		{
			rp_SetEventType(event_type_murder);
			rp_InitMurder();
		}	
		else if(StrEqual(EventEnCours, "Buildwars"))
			rp_SetEventType(event_type_buildwars);	
	}	
}	

public Action ShowEventStarting(Handle timer, any client)
{
	if (0 < timing)
	{
		timing--;
		PrintHintText(client, "L'event <font color='#5eff00'>%s</font> commence dans : <font color='#eaff00'>%i</font> secondes restantes...", EventEnCours, timing);
	}
	else
		TrashTimer(timer, true);
}	