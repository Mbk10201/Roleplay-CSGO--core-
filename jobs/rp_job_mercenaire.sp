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

enum contract_type {
	CLASSIC,
	KIDNAPPING,
	JUSTICE,
	POLICE,
	LUPIN
}

enum struct Contract_Data {
	bool hasContract;
	bool targeted;
	int target;
	int mercenaire;
	int buyer;
	contract_type type;
}

Contract_Data contract[MAXPLAYERS + 1];

/***************************************************************************************

							P L U G I N  -  I N F O

***************************************************************************************/
public Plugin myinfo = 
{
	name = "Roleplay - [JOB] Mercenaire", 
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
	RegConsoleCmd("contract", Command_Contract);
	RegConsoleCmd("contrat", Command_Contract);
}

public Action Command_Contract(int client, int args)
{
	int target = GetClientAimTarget(client);
	
	if(client == 0)
	{
		PrintToServer("%T", "Command_NotAvailable", LANG_SERVER);
		return Plugin_Handled;
	}
	else if(rp_GetClientInt(client, i_Job) != 12)
	{
		char translate[64];
		Format(STRING(translate), "%T", "NoAccessCommand", LANG_SERVER);
		rp_PrintToChat(client, "%s", translate);
	}
	else if(!IsClientValid(target))
	{
		rp_PrintToChat(client, "%t", "InvalidTarget", LANG_SERVER);
		return Plugin_Handled;
	}
	
	MenuContract(client, target);
	return Plugin_Handled;
}

public void OnClientPutInServer(int client)
{
	contract[client].hasContract = false;
	contract[client].targeted = false;
	contract[client].target = -1;
	contract[client].mercenaire = -1;
}

public void RP_OnClientDeath(int attacker, int victim, const char[] weapon, bool headshot)
{
	if(contract[victim].hasContract)
	{
		
	}
	if(victim == contract[attacker].target)
	{
		CPrintToChat(attacker, "%s Vous avez {green}accomplis {default} votre contrat\n Retour à la base.");
		CPrintToChat(victim, "%s Vous avez été {lightred}assassiné.");
		
		if(IsClientValid(contract[attacker].buyer))
			CPrintToChat(contract[attacker].buyer, "%s Votre cible a bien été assassinée.");
		
		if(contract[attacker].type == LUPIN)
		{
			if(rp_GetClientBool(victim, b_HasBankCard))
			{
				rp_SetClientBool(victim, b_HasBankCard, false);
				SetClientCookie(victim, FindClientCookie("rpv_bankcard"), "0");
			}	
		}	
		
		contract[attacker].hasContract = false;
		contract[attacker].target = -1;
		contract[victim].targeted = false;
		contract[victim].mercenaire = -1;
	}
}

public void RP_OnFootstep(int client)
{
	if(contract[client].targeted)
	{
		if(IsClientValid(contract[client].mercenaire))
		{
			float origin[3];
			GetClientAbsOrigin(client, origin);	
			EmitGPSTrain(contract[client].mercenaire, origin);
		}
	}
}

void MenuContract(int client, int target)
{
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_MenuContract);	
	
	char strIndex[64];
	menu.SetTitle("=== Contrats ===");
	
	Format(STRING(strIndex), "classic|%i", target);
	menu.AddItem(strIndex, "Contrat - Classique");
	
	Format(STRING(strIndex), "kidnapping|%i", target);
	menu.AddItem(strIndex, "Contrat - Kidnapping");
	
	Format(STRING(strIndex), "justice|%i", target);
	menu.AddItem(strIndex, "Contrat - Justice");
	
	Format(STRING(strIndex), "police|%i", target);
	menu.AddItem(strIndex, "Contrat - Police");
	
	Format(STRING(strIndex), "lupin|%i", target);
	menu.AddItem(strIndex, "Contrat - Arsène Lupin");
	
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}	

public int Handle_MenuContract(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[64], buffer[2][64], strIndex[64];
		menu.GetItem(param, STRING(info));	
		ExplodeString(info, "|", buffer, 2, 64);
		
		int target = StringToInt(buffer[1]);
		rp_SetClientBool(target, b_DisplayHud, false);
		Menu menu1 = new Menu(Handle_MenuTarget);	
		
		menu1.SetTitle("=== Choisissez une cible ===");
		
		static int countPolice = 0, countJustice = 0, countTotal = 0;
		LoopClients(i)
		{
			if(!IsClientValid(i))
				continue;			
			else if(i == target)
				continue;
			else if(i == client)
				continue;
				
			if(StrEqual(buffer[0], "police") && rp_GetClientInt(i, i_Job) != 1)
				continue;
			else
				countPolice++;
				
			if(StrEqual(buffer[0], "justice") && rp_GetClientInt(i, i_Job) != 1)
				continue;
			else
				countJustice++;	
				
			countTotal++;
				
			char name[64];
			GetClientName(i, STRING(name));
			
			Format(STRING(strIndex), "%s|%i|%i", buffer[0], client, i);
			menu1.AddItem(strIndex, name);
		}
		
		if(StrEqual(buffer[0], "police") && countPolice == 0)
		{
			menu1.AddItem("", "Aucun policier disponible", ITEMDRAW_DISABLED);
		}
		else if(StrEqual(buffer[0], "justice") && countJustice == 0)
		{
			menu1.AddItem("", "Aucun juge disponible", ITEMDRAW_DISABLED);
		}
		else if(countTotal == 0)
		{
			menu1.AddItem("", "Aucune cible disponible", ITEMDRAW_DISABLED);
		}
		
		menu1.ExitButton = true;
		menu1.Display(target, MENU_TIME_FOREVER);
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

public int Handle_MenuTarget(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[64], buffer[3][64], strIndex[64];
		menu.GetItem(param, STRING(info));
		ExplodeString(info, "|", buffer, 3, 64);
		
		// buffer[0] == Contract type
		int assassin = StringToInt(buffer[1]); // Job
		int target = StringToInt(buffer[2]); // Contract target
		
		rp_SetClientBool(assassin, b_DisplayHud, false);
		Menu menu1 = new Menu(Handle_MenuConfirmAssassin);	
		
		menu1.SetTitle("=== %N a ciblé %N ===", client, target);
		
		Format(STRING(strIndex), "%s|%i|%i|confirm", buffer[0], client, target);
		menu1.AddItem(strIndex, "Confirmer le contrat");
		
		Format(STRING(strIndex), "%s|%i|%i|cancel", buffer[0], client, target);
		menu1.AddItem(strIndex, "Refuser le contrat");
		
		menu1.ExitButton = true;
		menu1.Display(assassin, MENU_TIME_FOREVER);
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

public int Handle_MenuConfirmAssassin(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[64], buffer[4][64], strIndex[64], strMenu[64], strType[32];
		menu.GetItem(param, STRING(info));
		ExplodeString(info, "|", buffer, 4, 64);
		
		if(StrEqual(buffer[0], "police"))
			strType = "Police";
		else if(StrEqual(buffer[0], "justice"))
			strType = "Justice";
		else if(StrEqual(buffer[0], "kidnapping"))
			strType = "Kidnapping";		
		else if(StrEqual(buffer[0], "lupin"))
			strType = "Arsène Lupin";
		else if(StrEqual(buffer[0], "classic"))
			strType = "Classique";
		
		// buffer[0] == Contract type
		int buyer = StringToInt(buffer[1]); // buyer
		int target = StringToInt(buffer[2]); // Contract target
		
		if(StrEqual(buffer[3], "confirm"))
		{
			rp_SetClientBool(buyer, b_DisplayHud, false);
			Menu menu1 = new Menu(Handle_MenuConfirmBuyer);	
			
			menu1.SetTitle("=== Récapitulatif du contrat ===");
			
			Format(STRING(strMenu), "Contrat: %s", strType);
			menu1.AddItem("", strMenu, ITEMDRAW_DISABLED);
			
			Format(STRING(strMenu), "Cible: %N", target);
			menu1.AddItem("", strMenu, ITEMDRAW_DISABLED);
			
			Format(STRING(strMenu), "Prix: $500");
			menu1.AddItem("", strMenu, ITEMDRAW_DISABLED);
			
			Format(STRING(strIndex), "%s|%i|%i|confirm", buffer[0], client, target);
			menu1.AddItem(strIndex, "Confirmer le contrat");
		
			Format(STRING(strIndex), "%s|%i|%i|cancel", buffer[0], client, target);
			menu1.AddItem(strIndex, "Refuser le contrat");
			
			menu1.ExitButton = true;
			menu1.Display(buyer, MENU_TIME_FOREVER);
		}
		else
		{
			CPrintToChat(buyer, "%s Le tueur à gage a {darkred}refusé {default}votre contract.");
			rp_PrintToChat(client, "Vous avez annulé le contrat de %N.", buyer);
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

public int Handle_MenuConfirmBuyer(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[64], buffer[4][64];
		menu.GetItem(param, STRING(info));
		ExplodeString(info, "|", buffer, 4, 64);
		
		// buffer[0] == Contract type
		int assassin = StringToInt(buffer[1]); // Assassin Give contract
		int target = StringToInt(buffer[2]); // Contract target
		
		if(StrEqual(buffer[3], "confirm"))
		{
			contract[assassin].hasContract = true;
			contract[target].targeted = true;
			contract[assassin].target = target;
			contract[target].mercenaire = assassin;
			contract[assassin].buyer = client;
			
			contract_type ct_type;
			if(StrEqual(buffer[0], "police"))
				ct_type = POLICE;
			else if(StrEqual(buffer[0], "justice"))
				ct_type = JUSTICE;	
			else if(StrEqual(buffer[0], "kidnapping"))
				ct_type = KIDNAPPING;		
			else if(StrEqual(buffer[0], "lupin"))
				ct_type = LUPIN;			
			else if(StrEqual(buffer[0], "classic"))
				ct_type = CLASSIC;			
			
			contract[assassin].type = ct_type;
		}	
		else
		{
			CPrintToChat(assassin, "%s Votre client {green}%N {default}a {darkred}refusé {default}votre contract.");
			rp_PrintToChat(client, "Vous avez annulé le contrat de %N.", assassin);
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