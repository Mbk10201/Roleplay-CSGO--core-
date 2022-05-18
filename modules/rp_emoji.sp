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
	name = "Roleplay - [MODULE]Emoji", 
	author = "MBK", 
	description = "", 
	version = "1.0", 
	url = "https://github.com/Mbk10201"
};

/***************************************************************************************

									C A L L B A C K

***************************************************************************************/

public void OnPluginStart()
{
	
}

public Action RP_OnClientSay(int client, const char[] arg)
{
	if(StrEqual(arg, "love") || StrEqual(arg, "Love"))
		CreateEmoji(client, "emoji_heart");
	else if(StrEqual(arg, "?") || StrEqual(arg, "quoi"))
		CreateEmoji(client, "emoji_thinking");	
	else if(StrEqual(arg, "oui") || StrEqual(arg, "yes"))
		CreateEmoji(client, "emoji_grinning");	
	else if(StrEqual(arg, "haha") || StrEqual(arg, "hahaha"))
		CreateEmoji(client, "emoji_hahaha");		
}	

void CreateEmoji(int client, char[] path)
{
	//UTIL_CreateSprite(client, _, _, "!activator", path, "1", "7", 2.0);
	
	char sModel[128];
	rp_GetGlobalData(path, STRING(sModel));
	
	int ent = CreateEntityByName("env_sprite");	
	if (IsValidEntity(ent) && !StrEqual(sModel, ""))
	{
		DispatchKeyValue(ent, "model", sModel);
		DispatchSpawn(ent);

		float pos[3];
		GetClientEyePosition(client, pos);
		pos[2] += 20.0;

		TeleportEntity(ent, pos, NULL_VECTOR, NULL_VECTOR);
		SetVariantString("!activator");
		AcceptEntityInput(ent, "SetParent", client, ent, 0);		
		SetEntPropEnt(ent, Prop_Data, "m_hOwnerEntity", client);		
		SetEdictFlags(ent, 0);
		SetEdictFlags(ent, FL_EDICT_FULLCHECK);

		UTIL_RemoveEntity(ent, 2.0);
	}
}