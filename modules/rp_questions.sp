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

#define MAX_QUESTIONS 22
#define PREFIX "{yellow}[{orange}QUESTION{yellow}]{default}"

Handle g_hQuestions;
char reponse[128];
char question[256];
bool canRespond;
int reward;
int lastQuestion;
ConVar cv_QuestionRefreshTimer;

/***************************************************************************************

							P L U G I N  -  I N F O

***************************************************************************************/
public Plugin myinfo = 
{
	name = "Roleplay - [MODULE]Questions", 
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
	
	cv_QuestionRefreshTimer = CreateConVar("rp_question_refresh", "120.0", "The timer to send new question.");
	AutoExecConfig(true, "rp_questions", "roleplay");
}	

public void OnMapStart()
{
	g_hQuestions = CreateTimer(cv_QuestionRefreshTimer.FloatValue, SendQuestions, _, TIMER_REPEAT);
}	

public void OnMapEnd()
{
	if(g_hQuestions != null)
	{
		TrashTimer(g_hQuestions, true);
	}
}	

public Action QuestionStatus(Handle Timer)
{
	if(canRespond)
	{
		canRespond = false;
		CPrintToChatAll("%s Fin de la question, personne n'as répondu.", PREFIX);
	}
	
	return Plugin_Handled;
}		

public Action SendQuestions(Handle Timer)
{
	CreateTimer(30.0, QuestionStatus);
	int nb = GetRandomInt(1, MAX_QUESTIONS);
	
	while(nb == lastQuestion)
	{
		nb = GetRandomInt(1, MAX_QUESTIONS);
		lastQuestion = nb;
	}
	
	KeyValues kv = new KeyValues("Questions");

	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, STRING(sPath), "data/roleplay/questions.cfg");
	
	Kv_CheckIfFileExist(kv, sPath);
	
	char idString[8];
	IntToString(nb, STRING(idString));
	kv.JumpToKey(idString);
	
	kv.GetString("question", STRING(question));
	
	CPrintToChatAll("%s %s", PREFIX, question);
	
	kv.GetString("reponse", STRING(reponse));		
	
	reward = kv.GetNum("reward");
	
	kv.Rewind();	
	delete kv;
	
	canRespond = true;
	
	return Plugin_Handled;
}	

public void RP_OnClientSay(int client, const char[] arg)
{
	if(canRespond)
	{
		if(StrEqual(arg, reponse, false))
		{
			canRespond = false;
			CPrintToChatAll("%s %N a répondu correctement à la question\nLa réponse était: %s.", PREFIX, client, reponse);
			rp_PrintToChat(client, "Vous avez reçu %i$ pour votre bonne réponse.", reward);
			rp_SetClientInt(client, i_Bank, rp_GetClientInt(client, i_Bank) + reward);
		}	
	}	
}