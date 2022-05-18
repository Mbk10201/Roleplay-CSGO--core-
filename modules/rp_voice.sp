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

bool isTeamTalking[MAXPLAYERS + 1];

/***************************************************************************************

							P L U G I N  -  I N F O

***************************************************************************************/
public Plugin myinfo = 
{
	name = "Roleplay - [MODULE]Voice", 
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
	LoadTranslations("rp_voice.phrases.txt");
}

public void OnMapStart()
{
	CreateTimer(1.0, CheckMicro, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

public void RP_OnSettings(Menu menu, int client)
{
	char translation[64];
	if(!isTeamTalking[client])
	{
		Format(STRING(translation), "%T", "MenuVocal_General", LANG_SERVER);		
		menu.AddItem("job", translation);
	}	
	else
	{
		Format(STRING(translation), "%T", "MenuVocal_Job", LANG_SERVER);
		menu.AddItem("global", translation);
	}	
}	

public void RP_OnSettingsHandle(int client, const char[] info)
{
	char translation[128];
	if(StrEqual(info, "job"))
	{
		isTeamTalking[client] = true;
		Format(STRING(translation), "%T", "Vocal_Job", LANG_SERVER);
		rp_PrintToChat(client, "%s", translation);
	}
	else if(StrEqual(info, "global"))
	{
		isTeamTalking[client] = false;		
		Format(STRING(translation), "%T", "Vocal_Global", LANG_SERVER);
		rp_PrintToChat(client, "%s", translation);
	}
}	

/***************************************************************************************

									C L I E N T - S I D E

***************************************************************************************/
public void OnClientPutInServer(int client)
{
	isTeamTalking[client] = false;
}	

/***************************************************************************************

									C A L L B A C K

***************************************************************************************/

public Action CheckMicro(Handle timer)
{
	float distance = FindConVar("rp_voice_distance").FloatValue;
	LoopClients(sender)
	{
		if(IsClientValid(sender))
		{
			LoopClients(receiver)
			{
				if(IsClientValid(receiver))
				{						
					if(rp_GetClientInt(sender, i_JailTime) != 0)
					{
						char translation[64];
						Format(STRING(translation), "%T", "Vocal_Muted", LANG_SERVER);					
						//CPrintToChat(sender, "%s %s", translation);
						SetListenOverride(receiver, sender, Listen_No);	
						break;
					}
					else if(rp_GetClientBool(sender, b_IsMuteVocal))
					{
						char translation[64];
						Format(STRING(translation), "%T", "Vocal_Muted", LANG_SERVER);					
						//CPrintToChat(sender, "%s %s", translation);
						SetListenOverride(receiver, sender, Listen_No);	
						break;
					}
					
					if(isTeamTalking[sender])
					{
						if(rp_GetClientInt(sender, i_Job) != rp_GetClientInt(receiver, i_Job))
							SetListenOverride(receiver, sender, Listen_No);	
						break;
					}									
					else
					{
						if(Distance(sender, receiver) <= distance)
							SetListenOverride(receiver, sender, Listen_Yes);
						else
							SetListenOverride(receiver, sender, Listen_No);	
					}		
				}
			}
		}
	}
	
	return Plugin_Handled;
}

public bool IsInZonesMute(int client)
{
	if(rp_GetClientInt(client, i_ZoneAppart) != 0)
	{
		
	}
}