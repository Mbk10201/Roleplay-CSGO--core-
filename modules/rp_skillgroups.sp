/*
*   Roleplay CS:GO de Benito est mis à disposition selon les termes de la licence Creative Commons Attribution .
* - Pas d’Utilisation Commerciale 
* - Partage dans les Mêmes Conditions 4.0 International.
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

int m_iRank[MAXPLAYERS + 1];
int m_iCompetitiveRanking;

/***************************************************************************************

							P L U G I N  -  I N F O

***************************************************************************************/
public Plugin myinfo = 
{
	name = "Roleplay - [PREF] Staff SkillGroups", 
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
	m_iCompetitiveRanking = FindSendPropInfo("CCSPlayerResource", "m_iCompetitiveRanking");
}

public void OnMapStart()
{
	SDKHook(GetPlayerResourceEntity(), SDKHook_ThinkPost, OnThinkPost);
}	
/***************************************************************************************

									N A T I V E S

***************************************************************************************/

/***************************************************************************************

									C L I E N T - S I D E

***************************************************************************************/
public void RP_OnClientSpawn(int client)
{
	m_iRank[client] = -1;
	LoadRankData(client);
}	

public void OnClientDisconnect(int client) 
{
	m_iRank[client] = -1;
}

public void OnThinkPost(int m_iEntity)
{
	LoopClients(i)
	{
		if(!IsClientValid(i))
			continue;
		
		SetEntData(m_iEntity, m_iCompetitiveRanking+(i*4), m_iRank[i]);
	}
}

public void OnPlayerRunCmdPost(int iClient, int iButtons)
{
	static int iOldButtons[MAXPLAYERS+1];

	if(iButtons & IN_SCORE && !(iOldButtons[iClient] & IN_SCORE))
	{
		StartMessageOne("ServerRankRevealAll", iClient, USERMSG_BLOCKHOOKS);
		EndMessage();
	}

	iOldButtons[iClient] = iButtons;
}

stock void LoadRankData(int client)
{
	if(IsFondateur(client))
		m_iRank[client] = 200001;
	else if(IsCoFondateur(client))
		m_iRank[client] = 200002;	
	else if(IsResponable(client))
		m_iRank[client] = 200003;	
	else if(rp_GetAdmin(client) == ADMIN_FLAG_ADMIN)
		m_iRank[client] = 200004;	
	else if(rp_GetAdmin(client) == ADMIN_FLAG_MODERATOR)
		m_iRank[client] = 200005;		

	char sBuffer[PLATFORM_MAX_PATH];
	Format(sBuffer, sizeof(sBuffer), "materials/panorama/images/icons/skillgroups/skillgroup%i.svg", m_iRank[client]);
	PrintToServer(sBuffer);	
	AddFileToDownloadsTable(sBuffer);
}