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

							P L U G I N  -  I N C L U D E S

***************************************************************************************/
#include <roleplay_csgo.inc>

/***************************************************************************************

							P L U G I N  -  D E F I N E S

***************************************************************************************/
#define MAX_QUESTIONS 10
#define JOBID		3

/***************************************************************************************

							G L O B A L  -  V A R S

***************************************************************************************/

bool question_passed[MAXPLAYERS + 1][MAX_QUESTIONS];
KeyValues keyv;
int licence_try[MAXPLAYERS + 1];
int maxquestion = 0;
int correct[MAXPLAYERS + 1] = {0, ...};
int errors[MAXPLAYERS + 1] = {0, ...};
int cooldown[MAXPLAYERS + 1] = {30, ...};
int actual_question[MAXPLAYERS + 1] = {0, ...};
char steamID[MAXPLAYERS + 1][32];
Handle Timer_Cooldown[MAXPLAYERS + 1] = {null, ...};

enum struct Question_Data {
	int correct_answer;
	char img_url[256];
	char sound_url[128];
	char title[128];
	int max_answer;
	
	void GetAnswer(int branch, int id, char[] buffer, int maxlength) 
	{
		keyv.Rewind();
		char tmp[64];
		IntToString(branch, STRING(tmp));
		if(keyv.JumpToKey(tmp))
		{
			IntToString(id, STRING(tmp));
			keyv.GetString(tmp, buffer, sizeof(maxlength));
			keyv.Rewind();
		}	
		else
		{
			keyv.Rewind();
			Format(buffer, sizeof(maxlength), "N/A");
		}	
	}
}
Question_Data question[MAX_QUESTIONS];

/***************************************************************************************

							P L U G I N  -  I N F O

***************************************************************************************/
public Plugin myinfo = 
{
	name = "Roleplay - [JOB] Mairie", 
	author = "MBK", 
	description = "", 
	version = "1.0", 
	url = "https://github.com/Mbk10201"
};

/***************************************************************************************

							P L U G I N  -  F O R W A R D S

***************************************************************************************/
public void OnPluginStart()
{
	LoadTranslation();
	
	/*----------------------------------KeyValue-------------------------------*/
	keyv = new KeyValues("DrivingQuestions");
	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, STRING(sPath), "data/roleplay/drivingquestions.cfg");	
	Kv_CheckIfFileExist(keyv, sPath);
	
	// Jump into the first subsection
	if (!keyv.GotoFirstSubKey())
	{
		PrintToServer("ERROR FIRST KEY");
		delete keyv;
		return;
	}
	
	do {
		maxquestion++;
		keyv.GetString("img_url", question[maxquestion].img_url, sizeof(question[].img_url));
		keyv.GetString("sound_url", question[maxquestion].sound_url, sizeof(question[].sound_url));
		keyv.GetString("title", question[maxquestion].title, sizeof(question[].title));
		question[maxquestion].max_answer = keyv.GetNum("max_answer");
		question[maxquestion].correct_answer = keyv.GetNum("answer");
	}	
	while (keyv.GotoNextKey());
	
	/*-------------------------------------------------------------------------*/	
}

public void OnPluginEnd()
{
	delete keyv;
}

public void OnClientAuthorized(int client, const char[] auth) 
{
	strcopy(steamID[client], sizeof(steamID[]), auth);
}

public void OnClientPostAdminCheck(int client) 
{
	char buffer[8];
	GetClientCookie(client, FindClientCookie("rpv_licence_carTry"), STRING(buffer));
	licence_try[client] = StringToInt(buffer);
}

public void RP_OnClientInteract(int client, int target, const char[] class, const char[] model, const char[] name)
{
	if(rp_GetNPCType(target) == JOBID)
	{
		if(Distance(client, target) <= 80.0)
			rp_PerformNPCSell(client, JOBID);
		else
			Translation_PrintTooFar(client);
	}
}	

/***************************************************************************************

									C A L L B A C K

***************************************************************************************/  

void MenuMairie(int client)
{	
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_MenuMairie);
	menu.SetTitle("Accueil - Mairie :");	
	
	char strMenu[64];
	
	if(rp_GetClientBool(client, b_HasCarLicence))
		menu.AddItem("", "Passer le code [✓]", ITEMDRAW_DISABLED);
	else
	{	
		if(licence_try[client] == 2)
		{
			menu.AddItem("", "Passer le code [Raté]", ITEMDRAW_DISABLED);	
			
			Format(STRING(strMenu), "Payer +2x essai [%i$]", FindConVar("rp_cartheory_try_price").IntValue);
			menu.AddItem("+try", strMenu);	
		}	
		else
		{
			Format(STRING(strMenu), "Passer le code [%i$]", FindConVar("rp_cartheory_price").IntValue);
			menu.AddItem("permis", strMenu);		
		}	
	}		
	
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Handle_MenuMairie(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[64];
		menu.GetItem(param, STRING(info));
		
		if(StrEqual(info, "permis"))
			StartPermis(client);
		else if(StrEqual(info, "+try"))
		{
			if(rp_GetClientInt(client, i_Money) >= FindConVar("rp_cartheory_try_price").IntValue)
			{
				rp_SetClientInt(client, i_Money, rp_GetClientInt(client, i_Money) - FindConVar("rp_cartheory_try_price").IntValue);
				EmitCashSound(client, FindConVar("rp_cartheory_try_price").IntValue);
				licence_try[client] = 0;
				SetClientCookie(client, FindClientCookie("rpv_licence_carTry"), "0");
			}
			else if(rp_GetClientInt(client, i_Bank) >= FindConVar("rp_cartheory_try_price").IntValue)
			{
				rp_SetClientInt(client, i_Bank, rp_GetClientInt(client, i_Bank) - FindConVar("rp_cartheory_try_price").IntValue);
				EmitCashSound(client, FindConVar("rp_cartheory_try_price").IntValue);
				licence_try[client] = 0;
				SetClientCookie(client, FindClientCookie("rpv_licence_carTry"), "0");
			}
			else
			{
				rp_SetClientBool(client, b_DisplayHud, true);
				rp_PrintToChat(client, "Vous n'avez pas assez d'argent.");
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

void StartPermis(int client)
{
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_StartPermis);
	menu.SetTitle("Centre permis - Portland [%i/2]:", licence_try[client]);	
	
	menu.AddItem("start", "Continuer");
	menu.AddItem("cancel", "Passer le code plus-tard");		
	
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Handle_StartPermis(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[64];
		menu.GetItem(param, STRING(info));
		
		if(StrEqual(info, "start"))
		{
			if(rp_GetClientInt(client, i_Money) >= FindConVar("rp_cartheory_price").IntValue)
			{
				rp_SetClientInt(client, i_Money, rp_GetClientInt(client, i_Money) - FindConVar("rp_cartheory_price").IntValue);
				EmitCashSound(client, FindConVar("rp_cartheory_price").IntValue);
				MenuPermis(client);
			}
			else if(rp_GetClientInt(client, i_Bank) >= FindConVar("rp_cartheory_price").IntValue)
			{
				rp_SetClientInt(client, i_Bank, rp_GetClientInt(client, i_Bank) - FindConVar("rp_cartheory_price").IntValue);
				EmitCashSound(client, FindConVar("rp_cartheory_price").IntValue);
				MenuPermis(client);
			}
			else
			{
				rp_SetClientBool(client, b_DisplayHud, true);
				rp_PrintToChat(client, "Vous n'avez pas assez d'argent.");
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

void MenuPermis(int client, int quest = 0)
{
	int random;
	if(quest == 0)
	{
		random = GetRandomInt(1, maxquestion);
		while (question_passed[client][random])
		{
			random = GetRandomInt(1, maxquestion);
		}
	}	
	else
		random = quest;
	
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_PermisQuestion);
	
	char kv_questid[8], strIndex[32];
	IntToString(random, STRING(kv_questid));
	if(keyv.JumpToKey(kv_questid))
	{	
		ClientCommand(client, "r_screenoverlay %s", question[random].img_url);
		rp_Sound(client, question[random].sound_url, 1.0);
		actual_question[client] = random;
		
		if(Timer_Cooldown[client] == null)
		{
			cooldown[client] = 30;
			Timer_Cooldown[client] = CreateTimer(1.0, Timer_Question, client, TIMER_REPEAT);
		}	
	
		for(int i = 1; i <= question[random].max_answer; i++)
		{
			char sValue[32];
			question[random].GetAnswer(random, i, STRING(sValue));
			
			Format(STRING(strIndex), "%i|%i", random, i);
			menu.AddItem(strIndex, sValue);
		}
		
		menu.AddItem("", "--------------------", ITEMDRAW_DISABLED);
		Format(STRING(strIndex), "%i|replay", random);
		menu.AddItem(strIndex, "Rejouer la question");
		
		keyv.GoBack();
	}
	
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Handle_PermisQuestion(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[32], buffer[2][16];
		menu.GetItem(param, STRING(info));
		ExplodeString(info, "|", buffer, 2, 8);
		
		int quest = StringToInt(buffer[0]);
		StopSound(client, SNDCHAN_AUTO, question[quest].sound_url);
		
		if(StrEqual(buffer[1], "replay"))
			MenuPermis(client, quest);
		else
		{		
			int chosed_answer = StringToInt(buffer[1]);
			if(chosed_answer == question[quest].correct_answer)
			{
				correct[client]++;
				question_passed[client][StringToInt(buffer[0])] = true;
				rp_PrintToChat(client, "{green} Bonne réponse !");
			}
			else
			{
				errors[client]++;
				question_passed[client][StringToInt(buffer[0])] = false;
				rp_PrintToChat(client, "{green} Mauvaise réponse !");
			}	
			
			if(!CheckPermis(client))
			{
				if(Timer_Cooldown[client] != null)
					TrashTimer(Timer_Cooldown[client], true);
					
				MenuPermis(client);	
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

bool CheckPermis(int client)
{
	if(errors[client] + correct[client] == maxquestion)
	{
		rp_SetClientBool(client, b_DisplayHud, false);
		Panel panel = new Panel();
		panel.SetTitle("Résultats\n\n");
		
		for(int i = 1; i <= maxquestion; i++)
		{
			char tmp[64];
			if(question_passed[client][i])
				Format(STRING(tmp), "Question %i: ✓", i);
			else
				Format(STRING(tmp), "Question %i: ✘", i);
			panel.DrawText(tmp);
		}	
		
		panel.Send(client, HandleNothing, 15);
		CPrintToChat(client, "{darkred}▬▬▬▬▬▬▬▬▬▬{yellow}MAIRIE{darkred}▬▬▬▬▬▬▬▬▬▬");
		rp_PrintToChat(client, "Réponses justes: {lightgreen}%i.", correct[client]);
		rp_PrintToChat(client, "Réponses mauvaises: {lightred}%i.", errors[client]);
		
		if(correct[client] >= (maxquestion / 2))
		{
			rp_PrintToChat(client, "Vous avez eu la théorie, {lightgreen} Félicitation{default}.");
			rp_SetClientBool(client, b_HasCarLicence, true);
			SetClientCookie(client, FindClientCookie("rpv_licence_car"), "1");
		}	
		else
		{
			rp_PrintToChat(client, "Vous avez raté la théorie.");
			licence_try[client]++;
			char tmp[8];
			IntToString(licence_try[client], STRING(tmp));
			SetClientCookie(client, FindClientCookie("rpv_licence_carTry"), tmp);
		}
		
		CPrintToChat(client, "{darkred}▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬");
		
		if(Timer_Cooldown[client] != null)
			TrashTimer(Timer_Cooldown[client], true);
			
		DisplayMissionPassed(client);
		
		return true;
	}
	else 
		return false;
}

public Action Timer_Question(Handle timer, int client)
{
	if(cooldown[client] > 0)
	{
		cooldown[client]--;
		ShowPanel2(client, 2, "%s <font color='#00FF76'>%i</font>", question[actual_question[client]].title, cooldown[client]);
	}	
	else
	{
		rp_PrintToChat(client, "Le temps s'est écoulé, vous avez rater la question.");
		question_passed[client][actual_question[client]] = false;
		errors[client]++;
		TrashTimer(Timer_Cooldown[client], true);
		if(!CheckPermis(client))
			MenuPermis(client);
	}
	
	return Plugin_Handled;
}