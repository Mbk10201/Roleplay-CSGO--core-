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
#include <fpvm_interface>

/***************************************************************************************

							P L U G I N  -  I N F O

***************************************************************************************/
public Plugin myinfo = 
{
	name = "Roleplay - [MODULE]WeaponSystem", 
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
	
	RegConsoleCmd("rp_weapon_v", Command_V);
	RegConsoleCmd("rp_weapon_w", Command_W);
	RegConsoleCmd("rp_weapon_drop", Command_Drop);
}

/***************************************************************************************

									C L I E N T - S I D E

***************************************************************************************/
public void OnClientPutInServer(int client)
{
}	

/***************************************************************************************

									C A L L B A C K

***************************************************************************************/

public Action Command_V(int client, int args)
{
	char path[MAX_BUFFER_LENGTH];
	GetCmdArg(1, STRING(path));
	
	int index = GetPlayerWeaponSlot(client, CS_SLOT_KNIFE);
	FPVMI_AddViewModelToClient(client, "weapon_knife", index);
	
	return Plugin_Handled;
}

public Action Command_W(int client, int args)
{
	char path[MAX_BUFFER_LENGTH];
	GetCmdArg(1, STRING(path));
	
	int index = GetPlayerWeaponSlot(client, CS_SLOT_KNIFE);
	FPVMI_AddWorldModelToClient(client, "weapon_knife", index);
	
	return Plugin_Handled;
}

public Action Command_Drop(int client, int args)
{
	char path[MAX_BUFFER_LENGTH];
	GetCmdArg(1, STRING(path));
		
	FPVMI_AddDropModelToClient(client, "weapon_knife", path);
	
	return Plugin_Handled;
}