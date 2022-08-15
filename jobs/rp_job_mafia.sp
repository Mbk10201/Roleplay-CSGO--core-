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

#warning PLEASE NOTE, This plugin need to be finished

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
#include <smlib>
#include <cstrike>
#include <multicolors>
#include <roleplay_csgo.inc>

/***************************************************************************************

							G L O B A L  -  D E F I N E S

***************************************************************************************/
#define MAX_KIT 5

/***************************************************************************************

							P L U G I N  -  I N F O

***************************************************************************************/
public Plugin myinfo = 
{
	name = "Roleplay - [JOB] Mafia", 
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
}

/*public Action RP_OnClientInteract(int client, int target, const char[] class, const char[] model, const char[] name)
{
	if(rp_GetNPCType(target) == JOBID)
	{
		if(Distance(client, target) <= 80.0)
			rp_PerformNPCSell(client, JOBID);
		else
			Translation_PrintTooFar(client);
	}	
}	*/

Menu Coffre(int client)
{	
	if(rp_GetClientInt(client, i_Job) == 2)
	{
		char strMenu[64];
		
		rp_SetClientBool(client, b_DisplayHud, false);
		Menu menu = new Menu(DoMenuCoffre);
		menu.SetTitle("Coffre Mafia братва :");	
		
		if(rp_GetClientBool(client, b_HasCrowbar))
			menu.AddItem("piedbiche", "Ranger le pied-de-biche");
		else
			menu.AddItem("piedbiche", "Prendre un pied-de-biche");		
			
		if(rp_GetClientInt(client, i_KitCrochetage) != MAX_KIT)
			menu.AddItem("kit", "Prendre un kit de crochetage");
		else
		{
			Format(STRING(strMenu), "Prendre un kit de crochetage(%i MAX)", MAX_KIT);		
			menu.AddItem("", strMenu, ITEMDRAW_DISABLED);		
		}	
		
		menu.ExitButton = true;
		menu.Display(client, MENU_TIME_FOREVER);
	}
	else
		rp_PrintToChat(client, "Vous n'avez pas accès au coffre de la mafia japonaise.");	
}

public int DoMenuCoffre(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[64];
		menu.GetItem(param, STRING(info));
		
		if(StrEqual(info, "piedbiche"))
		{
			if(rp_GetClientBool(client, b_HasCrowbar))
			{
				rp_PrintToChat(client, "Vous avez ranger votre pied-de-biche.");
				rp_SetClientBool(client, b_HasCrowbar, false);
			}
			else
			{
				rp_PrintToChat(client, "Vous avez recupéré un pied-de-biche.");
				rp_SetClientBool(client, b_HasCrowbar, true);
			}	
		}
		else if(StrEqual(info, "kit"))
		{
			rp_SetClientInt(client, i_KitCrochetage, rp_GetClientInt(client, i_KitCrochetage) + 1);
			rp_PrintToChat(client, "Vous avez recupéré un kit de crochetage %i/%i.", rp_GetClientInt(client, i_KitCrochetage), MAX_KIT);
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