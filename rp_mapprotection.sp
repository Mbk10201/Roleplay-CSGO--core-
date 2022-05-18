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

/***************************************************************************************

							P L U G I N  -  I N F O

***************************************************************************************/
public Plugin myinfo = 
{
	name = "Roleplay - Map Protection", 
	author = "MBK", 
	description = "", 
	version = "1.0", 
	url = "https://github.com/Mbk10201"
};

/***************************************************************************************

									 F U N C T I O N S

***************************************************************************************/
public void OnPluginStart(){}

public void OnMapStart()
{
	CheckEntities();
	
	HookEvent("round_start", Event_Round, EventHookMode_Post);
}

public Action Event_Round(Event event, const char[] name, bool dontBroadcast)
{
	PrintToServer("Event: %s", name);
	
	CheckEntities();
	
	return Plugin_Handled;
}

void CheckEntities()
{
	for(int i = MaxClients; i <= 2048; i++)
	{
		if(!IsValidEntity(i))
			continue;
		
		char name[64], entName[64];
		Entity_GetName(i, name, sizeof(name));
		Entity_GetClassName(i, entName, sizeof(entName));
		
		if(StrEqual(name, "9er89rs5"))
			AcceptEntityInput(i, "Kill");
		else if(StrEqual(name, "634sedsqr6s"))	
			RemoveEdict(i);
		else if(StrEqual(name, "64554es5"))	
			AcceptEntityInput(i, "TurnOff");
		else if(StrEqual(entName, "point_servercommand"))	
			AcceptEntityInput(i, "Kill");
			
		/*if(StrEqual(entName, "trigger_multiple"))	
			AcceptEntityInput(i, "Kill");	*/
	}
}

/***************************************************************************************

									C A L L B A C K

***************************************************************************************/