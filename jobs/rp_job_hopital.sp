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

/***************************************************************************************

							P L U G I N  -  D E F I N E S

***************************************************************************************/
#define JOBID	2

/***************************************************************************************

							G L O B A L  -  V A R S

***************************************************************************************/

char steamID[MAXPLAYERS + 1][32];
Database g_DB;

/***************************************************************************************

							P L U G I N  -  I N F O

***************************************************************************************/
public Plugin myinfo = 
{
	name = "Roleplay - [JOB] Hopital", 
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
	LoadTranslations("rp_job_hopital.txt");
	
	RegConsoleCmd("operer", Command_Operation);
}

// Init SQL
public void RP_OnSQLInit(Database db)
{
	g_DB = db;
}

/***************************************************************************************

									C A L L B A C K

***************************************************************************************/  

public void RP_OnClientDeath(int attacker, int victim, const char[] weapon, bool headshot)
{
	//rp_CreateRagdoll(victim);
}

public Action Command_Operation(int client, int args)
{
	if (client == 0)
	{
		PrintToServer("%T", "Command_NotAvailable", LANG_SERVER);
		return Plugin_Handled;
	}
	int target = GetClientAimTarget(client, true);
	if(rp_GetClientInt(client, i_Job) != 4)
	{
		rp_PrintToChat(client, "%t", "NoAccessCommand", LANG_SERVER);
		return Plugin_Handled;
	}
	else if(!IsClientValid(target))
	{
		rp_PrintToChat(client, "%t", "InvalidTarget", LANG_SERVER);
		return Plugin_Handled;
	}
	/*else if(!Zone_Surgery(client))
	{
		rp_PrintToChat(client, "%t", "Client_NoInSurgeryZone", LANG_SERVER);
		return Plugin_Handled;
	}
	else if(!Zone_Surgery(target) || rp_GetClientInt(client, i_Zone) != 255 || rp_GetClientInt(target, i_Zone) != 255)
	{
		rp_PrintToChat(client, "%t", "Target_NoInSurgeryZone", LANG_SERVER);
		return Plugin_Handled;
	}*/
	
	MenuSurgery(client, target);
	
	return Plugin_Handled;
}

void MenuSurgery(int client, int target)
{
	#if DEBUG
		PrintToServer("MenuSurgery");
	#endif	
	
	char translation[64], strIndex[128];
	rp_SetClientBool(client, b_DisplayHud, false);	
	
	Menu menu = new Menu(Handle_MenuSurgery);
	menu.SetTitle("%T", "Surgery_Type", LANG_SERVER);	
	
	Format(STRING(translation), "%T", "Surgery_Type_Heart", LANG_SERVER);	
	if(!rp_GetClientSurgery(target, surgery_heart))
	{
		Format(STRING(strIndex), "%i|Surgery_Type_Heart", target);
		menu.AddItem(strIndex, translation);
	}	
	else
		menu.AddItem("", translation, ITEMDRAW_DISABLED);	
	
	Format(STRING(translation), "%T", "Surgery_Type_Legs", LANG_SERVER);	
	if(!rp_GetClientSurgery(target, surgery_legs))
	{
		Format(STRING(strIndex), "%i|Surgery_Type_Legs", target);
		menu.AddItem(strIndex, translation);
	}	
	else
		menu.AddItem("", translation, ITEMDRAW_DISABLED);	
	
	Format(STRING(translation), "%T", "Surgery_Type_Lung", LANG_SERVER);	
	if(!rp_GetClientSurgery(target, surgery_lung))
	{
		Format(STRING(strIndex), "%i|Surgery_Type_Lung", target);
		menu.AddItem(strIndex, translation);
	}	
	else
		menu.AddItem("", translation, ITEMDRAW_DISABLED);
	
	Format(STRING(translation), "%T", "Surgery_Type_Liver", LANG_SERVER);	
	if(!rp_GetClientSurgery(target, surgery_liver))
	{
		Format(STRING(strIndex), "%i|Surgery_Type_Liver", target);
		menu.AddItem(strIndex, translation);
	}	
	else
		menu.AddItem("", translation, ITEMDRAW_DISABLED);	
		
	Format(STRING(translation), "%T", "Surgery_Type_All", LANG_SERVER);
	Format(STRING(strIndex), "%i|Surgery_Type_All", target);
	if(!rp_GetClientSurgery(target, surgery_liver) || !rp_GetClientSurgery(target, surgery_heart)
	|| !rp_GetClientSurgery(target, surgery_lung) || !rp_GetClientSurgery(target, surgery_legs))
	{
		menu.AddItem(strIndex, translation);	
	}	
	else
		menu.AddItem(strIndex, translation, ITEMDRAW_DISABLED);	

	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Handle_MenuSurgery(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[64], buffer[2][64], translation[128], strIndex[64], strMenu[64];
		menu.GetItem(param, STRING(info));
		ExplodeString(info, "|", buffer, 2, 128);
		
		int target = StringToInt(buffer[0]);		
		Format(STRING(translation), "%T", buffer[1], LANG_SERVER);
		
		int price_surgery = 1500;
		if(StrContains(buffer[1], "heart", false))
			price_surgery = FindConVar("surgery_heart_price").IntValue;
		else if(StrContains(buffer[1], "legs", false))
			price_surgery = FindConVar("surgery_legs_price").IntValue;
		else if(StrContains(buffer[1], "liver", false))
			price_surgery = FindConVar("surgery_liver_price").IntValue;
		else if(StrContains(buffer[1], "lung", false))
			price_surgery = FindConVar("surgery_lung_price").IntValue;
		else if(StrContains(buffer[1], "all", false))
			price_surgery = FindConVar("surgery_all_price").IntValue;
		
		char clientname[64];
		GetClientName(client, STRING(clientname));
		
		rp_SetClientBool(target, b_DisplayHud, false);
		Menu menu1 = new Menu(Handle_MenuSurgeryConfirm);
		menu1.SetTitle("%T", "Surgery_Sell_Title", LANG_SERVER, clientname, translation, price_surgery);
		
		Format(STRING(strMenu), "%T", "Sell_PayBy_Cash", LANG_SERVER);
		Format(STRING(strIndex), "%i|%s|%i|0", client, buffer[1], price_surgery);					
		menu1.AddItem(strIndex, strMenu);
		
		if(rp_GetClientBool(target, b_HasBankCard))
		{
			Format(STRING(strMenu), "%T", "Sell_PayBy_BankCard", LANG_SERVER);
			Format(STRING(strIndex), "%i|%s|%i|1", client, buffer[1], price_surgery);			
			menu1.AddItem(strIndex, strMenu);
		}	
	
		Format(STRING(strMenu), "%T", "Sell_Cancel", LANG_SERVER);
		menu1.AddItem("no", strMenu);
		
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

public int Handle_MenuSurgeryConfirm(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[64], buffer[5][128];
		menu.GetItem(param, STRING(info));
		ExplodeString(info, "|", buffer, 5, 128);
		
		int seller = StringToInt(buffer[0]);
		int price = StringToInt(buffer[2]);
		bool bankCard = view_as<bool>(StringToInt(buffer[3]));
		
		Request_Sell(client, seller, buffer[1], price, bankCard);
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

void Request_Sell(int buyer, int seller, char[] surgery, int price, bool payCB)
{
	char translation[128];	
	if (payCB && rp_GetClientInt(buyer, i_Bank) >= price || !payCB && rp_GetClientInt(buyer, i_Money) >= price)
	{
		if (payCB)
			rp_SetClientInt(buyer, i_Bank, rp_GetClientInt(buyer, i_Bank) - price);
		else
			rp_SetClientInt(buyer, i_Money, rp_GetClientInt(buyer, i_Money) - price);
		EmitCashSound(buyer, -price);
		
		rp_SetClientInt(seller, i_Money, rp_GetClientInt(seller, i_Money) + price / 2);
		EmitCashSound(seller, price / 2);
		
		rp_SetJobCapital(4, rp_GetJobCapital(4) + price / 2);			
		
		CPrintToChat(buyer, "%s %t", "Surgery_SellFinal_Buyer", LANG_SERVER);
		CPrintToChat(seller, "%s %t", "Surgery_SellFinal_Seller", LANG_SERVER);

		rp_SetClientBool(buyer, b_DisplayHud, true);
		rp_SetClientBool(seller, b_DisplayHud, true);
		
		DataPack pack;
		CreateDataTimer(FindConVar("rp_surgerytime").FloatValue, SurgeryProgress, pack);
		pack.WriteCell(buyer);
		pack.WriteCell(seller);
		pack.WriteString(surgery);
		
		SetEntityMoveType(buyer, MOVETYPE_NONE);
		SetEntityMoveType(seller, MOVETYPE_NONE);
	}
	else if (rp_GetClientInt(buyer, i_Money) <= price)
	{
		char strName[64];
		GetClientName(buyer, STRING(strName));
		
		Format(STRING(translation), "%T", "Target_NotEnoughtMoney", LANG_SERVER, strName);
		CPrintToChat(seller, "%s %s", translation);
		
		Format(STRING(translation), "%T", "Client_NotEnoughtCash", LANG_SERVER);
		CPrintToChat(buyer, "%s %s", translation);
	}
	else if (rp_GetClientInt(buyer, i_Bank) <= price)
	{
		char strName[64];
		GetClientName(buyer, STRING(strName));
		
		Format(STRING(translation), "%T", "Target_NotEnoughtBank", LANG_SERVER, strName);
		CPrintToChat(seller, "%s %s", translation);
		
		Format(STRING(translation), "%T", "Client_NotEnoughtBank", LANG_SERVER);
		CPrintToChat(buyer, "%s %s", translation);
	}
}

public Action SurgeryProgress(Handle timer, DataPack pack)
{
	pack.Reset();
	int target = pack.ReadCell();
	int client = pack.ReadCell();
	
	char surgery[64];
	pack.ReadString(STRING(surgery));
	
	rp_PrintToChat(target, "%t", "Surgery_ProgressFinish", LANG_SERVER);
	rp_PrintToChat(client, "%t", "Surgery_ProgressFinish", LANG_SERVER);
	SetEntityMoveType(target, MOVETYPE_WALK);
	SetEntityMoveType(client, MOVETYPE_WALK);
	
	if(StrContains(surgery, "Heart") != -1)
	{
		rp_SetClientSurgery(target, surgery_heart, true);
		rp_SetClientInt(target, i_MaxHealth, 500);
		rp_SetClientHealth(target, rp_GetClientInt(target, i_MaxHealth));
	}	
	else if(StrContains(surgery, "Legs") != -1)
	{
		rp_SetClientSurgery(target, surgery_legs, true);	
		CheckGravity(target);
	}	
	else if(StrContains(surgery, "Lung") != -1)
	{
		rp_SetClientSurgery(target, surgery_lung, true);	
		CheckSpeed(target);
	}	
	else if(StrContains(surgery, "Liver") != -1)
	{
		rp_SetClientSurgery(target, surgery_liver, true);
		rp_SetClientBool(target, b_HasHealthRegen, true);
	}	
	else if(StrContains(surgery, "All") != -1)
	{
		if(!rp_GetClientSurgery(target, surgery_heart))
		{
			rp_SetClientSurgery(target, surgery_heart, true);
			rp_SetClientInt(target, i_MaxHealth, 500);
			rp_SetClientHealth(target, rp_GetClientInt(target, i_MaxHealth));
		}	
		if(!rp_GetClientSurgery(target, surgery_legs))
		{
			rp_SetClientSurgery(target, surgery_legs, true);	
			CheckGravity(target);
		}	
		if(!rp_GetClientSurgery(target, surgery_lung))
		{
			rp_SetClientSurgery(target, surgery_lung, true);	
			CheckSpeed(target);
		}	
		if(!rp_GetClientSurgery(target, surgery_liver))
		{
			rp_SetClientSurgery(target, surgery_liver, true);		
			rp_SetClientBool(target, b_HasHealthRegen, true);
		}	
	}
	
	return Plugin_Handled;
}	

/***************************************************************************************

									C L I E N T - S I D E

***************************************************************************************/

public void OnClientAuthorized(int client, const char[] auth) 
{	
	strcopy(steamID[client], sizeof(steamID[]), auth);
}

public void OnClientDisconnect(int client)
{
	rp_SetClientBool(client, b_HasHealthRegen, false);
}	

public void OnClientPutInServer(int client)
{
	rp_SetClientBool(client, b_HasHealthRegen, false);
	rp_SetClientInt(client, i_MaxHealth, 100);
	rp_SetClientSurgery(client, surgery_heart, false);
	rp_SetClientSurgery(client, surgery_legs, false);
	rp_SetClientSurgery(client, surgery_lung, false);
	rp_SetClientSurgery(client, surgery_liver, false);
}

public void RP_OnInventoryHandle(int client, int itemID)
{
	if(itemID == 120)
	{
		rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
			
		GivePlayerItem(client, "weapon_healthshot");

		char name[32];
		rp_GetItemData(itemID, item_name, STRING(name));
		rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);	
	}
	else if(itemID == 121)
	{
		if(!rp_GetClientBool(client, b_HasHealthRegen))
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
				
			rp_SetClientBool(client, b_HasHealthRegen, true);
			
			char name[64];
			rp_GetItemData(itemID, item_name, STRING(name));
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);	
		}
	}
	else if(itemID == 122)
	{
		if(!rp_GetClientSick(client, sick_type_fever))
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
			
			rp_SetClientSick(client, sick_type_fever, false);
			
			char name[64];
			rp_GetItemData(itemID, item_name, STRING(name));
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}	
		else
			rp_PrintToChat(client, "Vous n'avez pas de fièvre.");
	}
	else if(itemID == 123)
	{
		if(!rp_GetClientSick(client, sick_type_plague))
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
				
			rp_SetClientSick(client, sick_type_plague, false);
			
			char name[64];
			rp_GetItemData(itemID, item_name, STRING(name));
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}
		else
			rp_PrintToChat(client, "Vous n'êtez pas atteint de la peste.");		
	}
	else if(itemID == 124)
	{
		if(!rp_GetClientSick(client, sick_type_covid))
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
				
			rp_SetClientSick(client, sick_type_covid, false);
			
			char name[64];
			rp_GetItemData(itemID, item_name, STRING(name));
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}	
		else
			rp_PrintToChat(client, "Vous n'êtez pas porteur du covid.");
	}
	else if(itemID == 152)
	{
		if(rp_GetClientInt(client, i_MaxHealth) != 500)
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
				
			rp_SetClientInt(client, i_MaxHealth, 500);
			rp_SetClientHealth(client, rp_GetClientInt(client, i_MaxHealth));
			
			char name[64];
			rp_GetItemData(itemID, item_name, STRING(name));
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);	
		}
		else
			rp_PrintToChat(client, "Vous avez déjà 500HP de limite.");		
	}
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

public void RP_ClientTimerEverySecond(int client)
{
	if(rp_GetClientBool(client, b_HasHealthRegen))
	{
		int health = GetClientHealth(client);
		if(health != rp_GetClientInt(client, i_MaxHealth))
			SetEntityHealth(client, health + 1);	
	}
}