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

#define PLUGIN_NAME "rp_icons" // TODO

/***************************************************************************************

										H E A D E R

***************************************************************************************/
#include <voiceannounce_ex>
#include <roleplay_csgo.inc>

int iSpeakEntity[MAXPLAYERS + 1] = -1;

/***************************************************************************************

							P L U G I N  -  I N F O

***************************************************************************************/
public Plugin myinfo = 
{
	name = "Roleplay - Icons",  // TODO
	author = "MBK", 
	description = "Display icon when a player talk or write", // TODO
	version = "1.0", 
	url = "https://github.com/Mbk10201"
};

/***************************************************************************************

									 F U N C T I O N S

***************************************************************************************/

public void OnPluginStart()
{
	LoadTranslation();
	PrintToServer("[MODULE] %s ✓", PLUGIN_NAME);	
}

/***************************************************************************************

									N A T I V E S

***************************************************************************************/

/***************************************************************************************

									C A L L B A C K

***************************************************************************************/

public void OnClientSpeakingEx(int client)
{
	if(!BaseComm_IsClientMuted(client) && rp_GetClientBool(client, b_IsMuteVocal) == false)
	{
		if(iSpeakEntity[client] == -1)
			iSpeakEntity[client] = UTIL_CreateParticle(client, NULL_VECTOR, NULL_VECTOR, "head", "speech_voice", 1.0);
	}	
}

public void OnClientSpeakingEnd(int client)
{
	//UTIL_RemoveEntity(iSpeakEntity[client], 0.0);
}

public Action RP_OnClientSay(int client, const char[] arg)
{
	float pos[3];
	GetClientEyePosition(client, pos);
	pos[2] += 20.0;
	UTIL_CreateSprite(client, pos, _, "", MESSAGE_ICON, "0.1", "1", 1.0);
}