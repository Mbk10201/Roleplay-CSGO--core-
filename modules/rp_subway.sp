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

ConVar cvar_metrodelay;
bool canUseMetro[MAXPLAYERS + 1];

/***************************************************************************************

							P L U G I N  -  I N F O

***************************************************************************************/
public Plugin myinfo = 
{
	name = "Roleplay - [MODULE]Subway Transport", 
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
	
	cvar_metrodelay = CreateConVar("rp_subway_delay", "5.0", "Subway Re-use delay");
	AutoExecConfig(true, "rp_subway", "roleplay");
}

/***************************************************************************************

									C L I E N T - S I D E

***************************************************************************************/
public void OnClientPutInServer(int client)
{
	canUseMetro[client] = true;
}	

/***************************************************************************************

									C A L L B A C K

***************************************************************************************/

public void RP_OnClientInteract(int client, int target, const char[] class, const char[] model, const char[] name)		
{
	if(rp_GetClientInt(client, i_Zone) == ZONE_METROEVENT || rp_GetClientInt(client, i_Zone) == ZONE_METROCITY)
		TeleportationMetro(client);
}			

void TeleportationMetro(int client)
{
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(DoTeleportationMetro);
	menu.SetTitle("Metro Portland");
	if(rp_GetClientInt(client, i_JailTime) != 0)
		menu.AddItem("", "Vous n'avez pas accès au métro", ITEMDRAW_DISABLED);	
	else if(rp_GetClientInt(client, i_TicketMetro) == 0)	
		menu.AddItem("", "Vous n'avez pas de ticket.", ITEMDRAW_DISABLED);
	else
	{
		if(canUseMetro[client])
		{
			if(rp_GetClientInt(client, i_Zone) != ZONE_METROCITY)
				menu.AddItem("city", "Station - Ville");		
			if(rp_GetClientInt(client, i_Zone) != ZONE_METROEVENT)	
				menu.AddItem("event", "Station - Event");	
		}
		else
			menu.AddItem("", "Patienter avant de reutiliser\nle métro", ITEMDRAW_DISABLED);	
	}		
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}	

public int DoTeleportationMetro(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[32];
		menu.GetItem(param, STRING(info));
		
		canUseMetro[client] = false;
		CreateTimer(cvar_metrodelay.FloatValue, ResetData, client);
		
		rp_SetClientInt(client, i_TicketMetro, rp_GetClientInt(client, i_TicketMetro) - 1);
		
		if(StrEqual(info, "city"))
		{
			rp_SetClientBool(client, b_DisplayHud, true);		
			rp_PrintToChat(client, "Vous êtes arrivé en {lightgreen}Ville.");			
			
			int randompos = GetRandomInt(0, 3);
			switch(randompos)
			{
				case 0:TeleportEntity(client, view_as<float>( { -10116.482421, -2979.717773, -261.968750 } ), NULL_VECTOR, NULL_VECTOR);	
				case 1:TeleportEntity(client, view_as<float>( { -10114.559570, -3154.440185, -261.968750 } ), NULL_VECTOR, NULL_VECTOR);	
				case 2:TeleportEntity(client, view_as<float>( { -10098.842773, -3251.540039, -261.968750 } ), NULL_VECTOR, NULL_VECTOR);	
			}			
		}
		else if(StrEqual(info, "event"))
		{
			rp_SetClientBool(client, b_DisplayHud, true);
			rp_PrintToChat(client, "Vous êtes arrivé à la station {lightgreen}Event.");
			
			int randompos = GetRandomInt(0, 2);
			switch(randompos)
			{
				case 0:TeleportEntity(client, view_as<float>( { 5605.914062, -6475.637695, -556.968750 } ), NULL_VECTOR, NULL_VECTOR);	
				case 1:TeleportEntity(client, view_as<float>( { 5641.916015, -6593.086914, -556.968750 } ), NULL_VECTOR, NULL_VECTOR);	
				case 2:TeleportEntity(client, view_as<float>( { 5625.092773, -6351.364746, -556.968750} ), NULL_VECTOR, NULL_VECTOR);	
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

public Action ResetData(Handle timer, any client)
{
	if(IsClientValid(client))
		canUseMetro[client] = true;
		
	return Plugin_Handled;
}	