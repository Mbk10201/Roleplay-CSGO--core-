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

Database g_DB;
char steamID[MAXPLAYERS + 1][32];
bool SellerAvailable[MAXJOBS + 1];

enum struct Data_Forward {
	GlobalForward OnSell;
}
Data_Forward Forward;

/***************************************************************************************

							P L U G I N  -  I N F O

***************************************************************************************/
public Plugin myinfo = 
{
	name = "Roleplay - Sell", 
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
	
	RegConsoleCmd("sm_sell", Command_Sell);
	RegConsoleCmd("sm_vendre", Command_Sell);
}

public void RP_OnSQLInit(Database db, Transaction transaction)
{
	g_DB = db;
	
	char sBuffer[MAX_BUFFER_LENGTH + 1];
	
	Format(STRING(sBuffer), "CREATE TABLE IF NOT EXISTS `rp_ventes` (\
	`id` int(20) NOT NULL AUTO_INCREMENT, \
	`steamid_acheteur` varchar(32) COLLATE utf8_bin NOT NULL, \
	`steamid_vendeur` varchar(32) COLLATE utf8_bin NOT NULL, \
	`item_nom` varchar(64) COLLATE utf8_bin NOT NULL, \
	`pu` int(100) NOT NULL, \
	`quantite` int(100) NOT NULL, \
	`date_vente` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP, \
	PRIMARY KEY (`id`), \
	UNIQUE KEY `id` (`id`)) \
	ENGINE = InnoDB DEFAULT CHARSET = utf8 COLLATE = utf8_bin;");
	#if DEBUG
		PrintToServer(sBuffer);
	#endif
	transaction.AddQuery(sBuffer);
}
/***************************************************************************************

									N A T I V E S

***************************************************************************************/

public APLRes AskPluginLoad2(Handle plugin, bool late, char[] error, int err_max)
{
	RegPluginLibrary("rp_sell");
	
	/*------------------------------------FORWADS------------------------------------*/
	Forward.OnSell = new GlobalForward("RP_OnSell", ET_Event, Param_Cell, Param_Cell, Param_Cell, Param_Cell, Param_Cell, Param_Cell);	
	/*-------------------------------------------------------------------------------*/
	
	CreateNative("rp_PerformNPCSell", Native_PerformNPCSell);
	
	return APLRes_Success;
}

public int Native_PerformNPCSell(Handle plugin, int numParams) 
{
	int client = GetNativeCell(1);
	int jobID = GetNativeCell(2);
	
	PerformNpcSell(client, jobID);
	
	return 0;
}

void PerformNpcSell(int client, int jobID)
{
	bool pass = true;
	
	int nbTypeJob;
	LoopClients(i)
	{
		if(!IsClientValid(i))
			continue;
			
		if(rp_GetClientInt(i, i_Job) == jobID && !rp_GetClientBool(i, b_IsAfk))	
			nbTypeJob++;		
	}
	
	if (nbTypeJob == 0 || nbTypeJob == 1 && rp_GetClientInt(client, i_Job) == jobID || rp_GetClientInt(client, i_Job) == jobID && rp_GetClientInt(client, i_Grade) <= 2)
		pass = true;
	else
	{
		char job[64];
		rp_GetJobName(jobID, STRING(job));
		pass = false;
		SellerAvailable[jobID] = true;
		rp_PrintToChat(client, "Ce PNJ est inactif car un vendeur (%s) est disponible en ville.", job);
	}	
	
	if(pass)
	{
		rp_SetClientBool(client, b_DisplayHud, false);	
		Menu menu = new Menu(Handle_MenuSell);
		menu.SetTitle("%T", "Sell_Type", LANG_SERVER);
		char sJob[64], index[32], itemname[64], tmp[8], itemnew[1], sFarmTime[8];
		LoopItems(i)
		{
			if(!rp_IsItemValidIndex(i))
				continue;
			
			rp_GetItemData(i, item_jobid, STRING(sJob));	
			IntToString(jobID, STRING(tmp));
			
			if(StrEqual(sJob, tmp))
			{
				rp_GetItemData(i, item_name, STRING(itemname));
				rp_GetItemData(i, item_new, STRING(itemnew));
				if(StrEqual(itemnew, "1"))
					Format(STRING(itemname), "[NEW] %s", itemname);		
				
				Format(STRING(index), "%i|%i", client, i);
								
				rp_GetItemData(i, item_farmtime, STRING(sFarmTime));
				float farmtime = StringToFloat(sFarmTime);
				if(farmtime == 0.0)
				{
					Format(STRING(itemname), "%s [∞]", itemname);
					menu.AddItem(index, itemname);
				}
				else
				{
					Format(STRING(itemname), "%s [%i]", itemname, rp_GetItemStock(i));
					menu.AddItem(index, itemname, (rp_GetItemStock(i) > 0) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
				}
			}
		}
		
		menu.ExitButton = true;
		menu.Display(client, MENU_TIME_FOREVER);
	}	
}

/***************************************************************************************

									C A L L B A C K

***************************************************************************************/

public void OnClientAuthorized(int client, const char[] auth) 
{	
	strcopy(steamID[client], sizeof(steamID[]), auth);
}

public Action Command_Sell(int client, int args)
{
	#if DEBUG
		Translation_DebugCommand(client);
	#endif
	
	if (client == 0)
	{
		Translation_PrintNoAvailable();
		return Plugin_Handled;
	}
	int target = GetClientAimTarget(client, true);
	if(!IsClientValid(target))
	{
		Translation_PrintInvalidTarget(client);
		return Plugin_Handled;
	}
	else if(rp_GetClientInt(client, i_JailTime) != 0)
	{
		rp_PrintToChat(client, "%T", "NoAccessDueJail", LANG_SERVER);
		return Plugin_Handled;
	}
	else if(!rp_CanJobSell(rp_GetClientInt(client, i_Job)))
	{
		Translation_PrintNoAccess(client);
		return Plugin_Handled;
	}
	
	MenuSell(client, target);
	
	return Plugin_Handled;
}

void MenuSell(int client, int target)
{
	#if DEBUG
		PrintToServer("MenuSell");
	#endif	
	
	rp_SetClientBool(client, b_DisplayHud, false);	
	Menu menu = new Menu(Handle_MenuSell);
	menu.SetTitle("%T", "Sell_Type", LANG_SERVER);
	char index[64];
	
	LoopItems(i)
	{
		if(!rp_IsItemValidIndex(i))
			continue;
		
		char jobid[64], itemname[64], tmp[8], itemnew[1], sFarmTime[8];
		rp_GetItemData(i, item_jobid, STRING(jobid));
		rp_GetItemData(i, item_name, STRING(itemname));
		IntToString(rp_GetClientInt(client, i_Job), STRING(tmp));
		
		if(StrEqual(jobid, tmp))
		{
			rp_GetItemData(i, item_new, STRING(itemnew));
			if(StrEqual(itemnew, "1"))
				Format(STRING(itemname), "[NEW] %s", itemname);		
			
			Format(STRING(index), "%i|%i", target, i);
			
			rp_GetItemData(i, item_farmtime, STRING(sFarmTime));
			float farmtime = StringToFloat(sFarmTime);
			if(farmtime == 0.0)
			{
				Format(STRING(itemname), "%s [∞]", itemname);
				menu.AddItem(index, itemname);
			}
			else
			{
				Format(STRING(itemname), "%s [%i]", itemname, rp_GetItemStock(i));
				menu.AddItem(index, itemname, (rp_GetItemStock(i) > 0) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
			}
		}
	}	
		
	if(rp_GetClientInt(client, i_Job) == 18)
	{
		KeyValues kv = new KeyValues("Vehicles");
	
		char sPath[PLATFORM_MAX_PATH];
		BuildPath(Path_SM, STRING(sPath), "data/roleplay/vehicles.cfg");
		
		Kv_CheckIfFileExist(kv, sPath);
		
		// Jump into the first subsection
		if (!kv.GotoFirstSubKey())
		{
			PrintToServer("ERROR FIRST KEY");
			delete kv;
			return;
		}
		
		char szCarId[255];
		do
		{
			if(kv.GetSectionName(STRING(szCarId)))
			{
				char carname[64];
				kv.GetString("brand", STRING(carname));
				int carid = StringToInt(szCarId);
				
				Format(STRING(index), "%i|%i|1|car", target, carid);
				if(GetVehiclePrice(carid) != -1)
					menu.AddItem(index, carname);
			}
			//kv.GoBack();
		} 
		while (kv.GotoNextKey());
		
		kv.Rewind();
		delete kv;	
	}	
	
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

int Handle_MenuSell(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[64], buffer[2][64];
		menu.GetItem(param, STRING(info));
		ExplodeString(info, "|", buffer, 2, 64);
		
		rp_SetClientBool(client, b_DisplayHud, false);	
		Menu menu1 = new Menu(Handle_Quantity);
		menu1.SetTitle("%T", "Sell_Quantity", LANG_SERVER);
		
		char sMaxQuantity[32];
		int iMax_quantity;
		rp_GetItemData(StringToInt(buffer[1]), item_maxquantity, STRING(sMaxQuantity));
		iMax_quantity = StringToInt(sMaxQuantity);
		
		char sFarmTime[32];
		rp_GetItemData(StringToInt(buffer[1]), item_farmtime, STRING(sFarmTime));
		float fFarmtime = StringToFloat(sFarmTime);
		
		char strIndex[64];
		
		if(fFarmtime == 0.0)
		{
			if(iMax_quantity >= 1)
			{
				Format(STRING(strIndex), "%s|1", info);
				menu1.AddItem(strIndex, "1");
			}
			if(iMax_quantity >= 2)
			{
				Format(STRING(strIndex), "%s|2", info);
				menu1.AddItem(strIndex, "2");
			}
			if(iMax_quantity >= 3)
			{
				Format(STRING(strIndex), "%s|3", info);
				menu1.AddItem(strIndex, "3");
			}
			if(iMax_quantity >= 4)
			{
				Format(STRING(strIndex), "%s|4", info);
				menu1.AddItem(strIndex, "4");
			}
			if(iMax_quantity >= 5)
			{
				Format(STRING(strIndex), "%s|5", info);
				menu1.AddItem(strIndex, "5");
			}
			if(iMax_quantity >= 10)
			{
				Format(STRING(strIndex), "%s|10", info);
				menu1.AddItem(strIndex, "10");
			}
			if(iMax_quantity >= 15)
			{
				Format(STRING(strIndex), "%s|15", info);
				menu1.AddItem(strIndex, "15");
			}
			if(iMax_quantity >= 50)
			{
				Format(STRING(strIndex), "%s|50", info);
				menu1.AddItem(strIndex, "50");
			}
			if(iMax_quantity >= 75)
			{
				Format(STRING(strIndex), "%s|75", info);
				menu1.AddItem(strIndex, "75");
			}
			if(iMax_quantity >= 100)
			{
				Format(STRING(strIndex), "%s|100", info);
				menu1.AddItem(strIndex, "100");
			}
		}
		else
		{
			if(rp_GetItemStock(StringToInt(buffer[1])) >= 1 && iMax_quantity >= 1)
			{
				Format(STRING(strIndex), "%s|1", info);
				menu1.AddItem(strIndex, "1");
			}
			if(rp_GetItemStock(StringToInt(buffer[1])) >= 2 && iMax_quantity >= 2)
			{
				Format(STRING(strIndex), "%s|2", info);
				menu1.AddItem(strIndex, "2");
			}
			if(rp_GetItemStock(StringToInt(buffer[1])) >= 3 && iMax_quantity >= 3)
			{
				Format(STRING(strIndex), "%s|3", info);
				menu1.AddItem(strIndex, "3");
			}
			if(rp_GetItemStock(StringToInt(buffer[1])) >= 4 && iMax_quantity >= 4)
			{
				Format(STRING(strIndex), "%s|4", info);
				menu1.AddItem(strIndex, "4");
			}
			if(rp_GetItemStock(StringToInt(buffer[1])) >= 5 && iMax_quantity >= 5)
			{
				Format(STRING(strIndex), "%s|5", info);
				menu1.AddItem(strIndex, "5");
			}
			if(rp_GetItemStock(StringToInt(buffer[1])) >= 10 && iMax_quantity >= 10)
			{
				Format(STRING(strIndex), "%s|10", info);
				menu1.AddItem(strIndex, "10");
			}
			if(rp_GetItemStock(StringToInt(buffer[1])) >= 15 && iMax_quantity >= 15)
			{
				Format(STRING(strIndex), "%s|15", info);
				menu1.AddItem(strIndex, "15");
			}
			if(rp_GetItemStock(StringToInt(buffer[1])) >= 50 && iMax_quantity >= 50)
			{
				Format(STRING(strIndex), "%s|50", info);
				menu1.AddItem(strIndex, "50");
			}
			if(rp_GetItemStock(StringToInt(buffer[1])) >= 75 && iMax_quantity >= 75)
			{
				Format(STRING(strIndex), "%s|75", info);
				menu1.AddItem(strIndex, "75");
			}
			if(rp_GetItemStock(StringToInt(buffer[1])) >= 100 && iMax_quantity >= 100)
			{
				Format(STRING(strIndex), "%s|100", info);
				menu1.AddItem(strIndex, "100");
			}
		}

		menu1.ExitButton = true;
		menu1.Display(client, MENU_TIME_FOREVER);
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

int Handle_Quantity(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[128], buffer[4][64], strMenu[64], strIndex[64];
		menu.GetItem(param, STRING(info));
		ExplodeString(info, "|", buffer, 4, 64);
		
		/* 			CONSTRUCTOR 			*/
		int target = StringToInt(buffer[0]);
		int item = StringToInt(buffer[1]); 
		int quantity = StringToInt(buffer[2]); 
		
		char strPrice[32];
		if(StrEqual(buffer[3], "car"))
			Format(STRING(strPrice), "%i", GetVehiclePrice(item));
		else
			rp_GetItemData(item, item_price, STRING(strPrice));
		int price = StringToInt(strPrice) * quantity;
		
		char itemname[32];
		if(StrEqual(buffer[3], "car"))
			GetVehicleName(item, STRING(itemname));
		else
			rp_GetItemData(item, item_name, STRING(itemname));
		/* 			----------- 			*/
		
		rp_SetClientBool(target, b_DisplayHud, false);	
		Menu menu1 = new Menu(Handle_SellConfirm);		
		
		char strTitle[128], strName[64];
		GetClientName(client, STRING(strName));
		if(target != client)
			Format(STRING(strTitle), "%T", "Sell_TypePay_Title", LANG_SERVER, strName, quantity, itemname, price);
		else
			Format(STRING(strTitle), "%T", "Sell_TypePay_TitleNPC", LANG_SERVER, quantity, itemname, price);		
		menu1.SetTitle(strTitle);
		
		Format(STRING(strMenu), "%T", "Sell_PayBy_Cash", LANG_SERVER);
		
		if(StrEqual(buffer[3], "car"))
			Format(STRING(strIndex), "%i|%i|%i|%i|0|car", client, quantity, item, price);			
		else
			Format(STRING(strIndex), "%i|%i|%i|%i|0", client, quantity, item, price);					
		menu1.AddItem(strIndex, strMenu);
		
		if(rp_GetClientBool(target, b_HasBankCard) || client == target && rp_GetClientBool(client, b_HasBankCard))
		{
			Format(STRING(strMenu), "%T", "Sell_PayBy_BankCard", LANG_SERVER);
			if(StrEqual(buffer[3], "car"))
				Format(STRING(strIndex), "%i|%i|%i|%i|1|car", client, quantity, item, price);	
			else	
				Format(STRING(strIndex), "%i|%i|%i|%i|1", client, quantity, item, price);	
			
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

public int Handle_SellConfirm(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[128], buffer[6][128];
		menu.GetItem(param, STRING(info));		
		ExplodeString(info, "|", buffer, 6, 128);
			
		int seller = StringToInt(buffer[0]);
		int quantity = StringToInt(buffer[1]);
		int itemID = StringToInt(buffer[2]);		
		int price = StringToInt(buffer[3]);
		bool bankCard = view_as<bool>(StringToInt(buffer[4]));
		bool car = false;
		if(StrEqual(buffer[5], "car"))
			car = true;
		
		Request_Sell(client, seller, itemID, price, quantity, bankCard, car);
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

void Request_Sell(int buyer, int seller, int itemID, int price, int quantity, bool payCB)
{
	Call_StartForward(Forward.OnSell);
	Call_PushCell(buyer);
	Call_PushCell(seller);
	Call_PushCell(itemID);
	Call_PushCell(price);
	Call_PushCell(quantity);
	Call_PushCell(payCB);
	Call_Finish();

	char item[32];
	if(car)
		GetVehicleName(itemID, STRING(item));
	else
		rp_GetItemData(itemID, item_name, STRING(item));				
	
	if (payCB && rp_GetClientInt(buyer, i_Bank) >= price || !payCB && rp_GetClientInt(buyer, i_Money) >= price)
	{
		char SQL_Buffer[2048], pu[16], item_job[8];
		rp_GetItemData(itemID, item_price, STRING(pu));
		rp_GetItemData(itemID, item_jobid, STRING(item_job));

		if (buyer != seller)
		{
			if (payCB)
				rp_SetClientInt(buyer, i_Bank, rp_GetClientInt(buyer, i_Bank) - price);
			else
				rp_SetClientInt(buyer, i_Money, rp_GetClientInt(buyer, i_Money) - price);
			EmitCashSound(buyer, -price);
			
			//rp_SetClientInt(seller, i_Money, rp_GetClientInt(seller, i_Money) + price / 2);
			rp_SetClientInt(seller, i_Money, rp_GetClientInt(seller, i_Money) + (price / 2));
			EmitCashSound(seller, price / 2);
			
			rp_SetJobCapital(rp_GetClientInt(seller, i_Job), rp_GetJobCapital(rp_GetClientInt(seller, i_Job)) + price / 2);			
			
			char strName_seller[64];
			GetClientName(seller, STRING(strName_seller));
			rp_PrintToChat(buyer, "%T", "Sell_Final_Buyer", LANG_SERVER, quantity, item, strName_seller, price);
			
			char strName_buyer[64];
			GetClientName(buyer, STRING(strName_buyer));
			rp_PrintToChat(seller, "%T", "Sell_Final_Seller", LANG_SERVER, quantity, item, strName_buyer, price);
			
			Format(STRING(SQL_Buffer), "INSERT IGNORE INTO `rp_ventes` (`id`, `steamid_acheteur`, `steamid_vendeur`, `item_nom`, `pu`, `quantite`) VALUES (NULL, '%s', '%s', '%s', '%i', '%i');", steamID[buyer], steamID[seller], item, StringToInt(pu), quantity, item_job);
		}
		else
		{
			if (payCB)
				rp_SetClientInt(buyer, i_Bank, rp_GetClientInt(buyer, i_Bank) - price);
			else
				rp_SetClientInt(buyer, i_Money, rp_GetClientInt(buyer, i_Money) - price);
			EmitCashSound(buyer, -price);
			
			char entName[32], buffer[2][64];
			Entity_GetGlobalName(seller, STRING(entName));
			ExplodeString(entName, "|", buffer, 2, 64);
			
			int jobID = StringToInt(buffer[1]);		
			rp_SetJobCapital(jobID, rp_GetJobCapital(jobID) + price / 2);
			
			rp_PrintToChat(seller, "%T", "Sell_Final_NPC", LANG_SERVER, quantity, item, price);
			
			Format(STRING(SQL_Buffer), "INSERT IGNORE INTO `rp_ventes` (`id`, `steamid_acheteur`, `steamid_vendeur`, `item_nom`, `pu`, `quantite`) VALUES (NULL, '%s', '%s', '%s', '%i', '%i');", steamID[buyer], "PNJ / NPC", item, StringToInt(pu), quantity, item_job);
		}

		if(rp_GetClientBool(buyer, b_TransfertItemBank))
		{
			rp_SetClientItem(buyer, itemID, rp_GetClientItem(buyer, itemID, true) + quantity, true);
			CPrintToChat(buyer, "%s Votre item a été transféré dans votre inventaire banquaire.", NOTIF);
		}	
		else
		{
			rp_SetClientItem(buyer, itemID, rp_GetClientItem(buyer, itemID, false) + quantity, false);		
			CPrintToChat(buyer, "%s Votre item a été transféré dans votre inventaire.", NOTIF);
		}
		
		rp_SetItemStock(itemID, rp_GetItemStock(itemID) - 1);
		
		float position[3];
		GetClientAbsOrigin(buyer, position);
		rp_CreateParticle(position, "sell", 2.0);
		GetClientAbsOrigin(seller, position);
		rp_CreateParticle(position, "sell_dollar", 2.0);
		
		#if DEBUG
			PrintToServer(SQL_Buffer);
		#endif		  
		SQL_Request(g_DB, SQL_Buffer);
	}
	else if (rp_GetClientInt(buyer, i_Money) <= price)
	{
		if (seller != buyer)
		{		
			char strName[64];
			GetClientName(buyer, STRING(strName));
			rp_PrintToChat(seller, "%T", "Target_NotEnoughtMoney", LANG_SERVER, strName);
		}
		rp_PrintToChat(seller, "%T", "Client_NotEnoughtCash", LANG_SERVER);
	}
	else if (rp_GetClientInt(buyer, i_Bank) <= price)
	{
		if (seller != buyer)
		{
			char strName[64];
			GetClientName(buyer, STRING(strName));
			rp_PrintToChat(seller, "%T", "Target_NotEnoughtBank", LANG_SERVER, strName);
		}	
		
		rp_PrintToChat(buyer, "%T", "Client_NotEnoughtBank", LANG_SERVER);
	}
}