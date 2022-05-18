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
#define JOBID				14

/***************************************************************************************

							G L O B A L  -  V A R S

***************************************************************************************/

char steamID[MAXPLAYERS + 1][32];
Database g_DB;

int cagnotte;
int countGrattage[MAXPLAYERS + 1][3];

/***************************************************************************************

							P L U G I N  -  I N F O

***************************************************************************************/
public Plugin myinfo = 
{
	name = "Roleplay - [JOB] Casino", 
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
	LoadTranslations("rp_job_casino.phrases.txt");
}

// Init SQL
public void RP_OnSQLInit(Database db)
{
	g_DB = db;
}

/***************************************************************************************

									C L I E N T - S I D E

***************************************************************************************/
public void OnClientAuthorized(int client, const char[] auth) 
{	
	strcopy(steamID[client], sizeof(steamID[]), auth);
}	

public void RP_OnInventoryHandle(int client, int itemID)
{
	if(itemID == 126)
	{
		if (rp_GetJobCapital(5) >= 1000)
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
			
			countGrattage[client][0]++;
			
			int nombre;
			if (countGrattage[client][0] > 142)
				nombre = GetRandomInt(40, 60);
			else
				nombre = GetRandomInt(0, 70);	
			/*else if (vitality < 5.0)
				nombre = GetRandomInt(0, 95);
			else if (vitality < 25.0)
				nombre = GetRandomInt(0, 90);
			else if (vitality < 50.0)
				nombre = GetRandomInt(0, 85);
			else if (vitality < 70.0)
				nombre = GetRandomInt(0, 80);
			else if (vitality < 99.0)
				nombre = GetRandomInt(0, 75);*/
			
			if (nombre == 42 || nombre == 69)
			{
				if (GetRandomInt(1, 2) == 2)
				{
					countGrattage[client][0] = 0;				
					rp_SetClientInt(client, i_Money, rp_GetClientInt(client, i_Money) + 1000);
					rp_SetJobCapital(5, rp_GetJobCapital(5) - 500);
					EmitCashSound(client, 1000);
					rp_PrintToChat(client, "Vous avez gratté un ticket, vous avez gagné {green}1000$ {default}!");
					
					PrecacheSound("ui/item_drop4_mythical.wav");
					EmitSoundToClient(client, "ui/item_drop4_mythical.wav", client, _, _, _, 1.0);
				}
				else 
					rp_PrintToChat(client, "Vous avez gratté un ticket, vous avez {lightred}perdu{default}.");
			}
			else if (nombre >= 37 && nombre <= 42)
			{
				int montant = GetRandomInt(6, 50);
				rp_SetClientInt(client, i_Money, rp_GetClientInt(client, i_Money) + montant);
				rp_SetJobCapital(5, rp_GetJobCapital(5) - montant);
				EmitCashSound(client, montant);
				rp_PrintToChat(client, "Vous avez gratté un ticket, vous avez gagné {green}%i$ {default}!", montant);
			}
			else
				rp_PrintToChat(client, "Vous avez gratté un ticket, vous avez {lightred}perdu.");
		}
		else
			rp_PrintToChat(client, "La loterie n'est pas assez élévée, conservez votre ticket a gratter.");
	}
	else if(itemID == 127)
	{
		if (cagnotte >= 10000)
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);		
			
			countGrattage[client][1]++;
			
			int nombre;
			if(countGrattage[client][1] > 160)
				nombre = GetRandomInt(40, 60);
			else 
				nombre = GetRandomInt(0, 100);	
			/*else if(karma[client] < 5)
				nombre = GetRandomInt(0, 125);
			else if(karma[client] < 25)
				nombre = GetRandomInt(0, 120);
			else if(karma[client] < 50)
				nombre = GetRandomInt(0, 115);
			else if(karma[client] < 70)
				nombre = GetRandomInt(0, 110);
			else if(karma[client] < 99)
				nombre = GetRandomInt(0, 105);*/
			
			if(nombre == 42 || nombre == 69)
			{
				if(GetRandomInt(1, 3) == 2)
				{
					countGrattage[client][1] = 0;
					
					rp_SetClientInt(client, i_Money, rp_GetClientInt(client, i_Money) + 100000);
					cagnotte -= 50000;
					EmitCashSound(client, 100000);
					rp_PrintToChat(client, "Vous avez joué au Loto, vous avez gagné \x0610000$ !");
				}
				else rp_PrintToChat(client, "Vous avez joué au Loto, vous avez perdu.");
			}
			else if(nombre >= 37 && nombre <= 42)
			{
				int montant = GetRandomInt(800, 1750);
				rp_SetClientInt(client, i_Money, rp_GetClientInt(client, i_Money) + montant);
				cagnotte -= montant;
				EmitCashSound(client, montant);
				rp_PrintToChat(client, "Vous avez joué au Loto, vous avez gagné \x06%i$ !", montant);
			}
			else
				rp_PrintToChat(client, "Vous avez joué au Loto, vous avez perdu.");
		}
		else
			rp_PrintToChat(client, "La loterie n'est pas assez élévée, conservez votre ticket a gratter.");
	
		char name[32];
		rp_GetItemData(itemID, item_name, STRING(name));
		rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);	
	}
	else if(itemID == 128)
	{
		if (cagnotte >= 10000)
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);	
			
			countGrattage[client][1]++;
			
			int nombre;
			if(countGrattage[client][1] > 160)
				nombre = GetRandomInt(40, 60);
			else 
				nombre = GetRandomInt(0, 100);	
			/*else if(karma[client] < 5)
				nombre = GetRandomInt(0, 125);
			else if(karma[client] < 25)
				nombre = GetRandomInt(0, 120);
			else if(karma[client] < 50)
				nombre = GetRandomInt(0, 115);
			else if(karma[client] < 70)
				nombre = GetRandomInt(0, 110);
			else if(karma[client] < 99)
				nombre = GetRandomInt(0, 105);*/
			
			if(nombre == 42 || nombre == 69)
			{
				if(GetRandomInt(1, 3) == 2)
				{
					countGrattage[client][1] = 0;
					
					rp_SetClientInt(client, i_Money, rp_GetClientInt(client, i_Money) + 10000);
					cagnotte -= 5000;
					EmitCashSound(client, 10000);
					rp_PrintToChat(client, "Vous avez joué au rapido, vous avez gagné \x0610000$ !");
				}
				else rp_PrintToChat(client, "Vous avez joué au Rapido, vous avez perdu.");
			}
			else if(nombre >= 37 && nombre <= 42)
			{
				int montant = GetRandomInt(80, 160);
				rp_SetClientInt(client, i_Money, rp_GetClientInt(client, i_Money) + montant);
				cagnotte -= montant;
				EmitCashSound(client, montant);
				rp_PrintToChat(client, "Vous avez joué au rapido, vous avez gagné \x06%i$ !", montant);
			}
			else
				rp_PrintToChat(client, "Vous avez joué au Rapido, vous avez perdu.");
		}
		else
			rp_PrintToChat(client, "La loterie n'est pas assez élévée, conservez votre ticket a gratter.");
	
		char name[32];
		rp_GetItemData(itemID, item_name, STRING(name));
		rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);	
	}
	else if(itemID == 129)
	{	
		if(rp_GetClientBool(client, b_HasFlashLight))
			rp_PrintToChat(client, "Vous êtes déjà équipé d'une lampe torche.");
		else
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
			
			rp_SetClientBool(client, b_HasFlashLight, true);
			rp_PrintToChat(client, "Vous êtes équipé d'une lampe torche, appuyez sur votre touche \x06'Examiner l'arme'\x01 pour l'activer.");
			
			char name[32];
			rp_GetItemData(itemID, item_name, STRING(name));
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}			
	}
	else if(itemID == 130)
	{	
		rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);	
			
		rp_SetClientInt(client, i_Graffiti, rp_GetClientInt(client, i_Graffiti) + 3);
		
		char name[32];
		rp_GetItemData(itemID, item_name, STRING(name));
		rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);	
	}
	else if(itemID == 131)
	{	
		rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
			
		char sModel[64];
		rp_GetGlobalData("graffiti_1", STRING(sModel));
		
		int index = PrecacheDecal(sModel);
		rp_SetClientInt(client, i_GraffitiIndex, index);
		
		char name[32];
		rp_GetItemData(itemID, item_name, STRING(name));
		rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);	
	}
	else if(itemID == 132)
	{	
		rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);	
			
		char sModel[64];
		rp_GetGlobalData("graffiti_2", STRING(sModel));
		
		int index = PrecacheDecal(sModel);
		rp_SetClientInt(client, i_GraffitiIndex, index);
		
		char name[32];
		rp_GetItemData(itemID, item_name, STRING(name));
		rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);	
	}
	else if(itemID == 133)
	{	
		rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);	
			
		char sModel[64];
		rp_GetGlobalData("graffiti_3", STRING(sModel));
		
		int index = PrecacheDecal(sModel);
		rp_SetClientInt(client, i_GraffitiIndex, index);
		
		char name[32];
		rp_GetItemData(itemID, item_name, STRING(name));
		rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);	
	}
	else if(itemID == 134)
	{	
		rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
			
		char sModel[64];
		rp_GetGlobalData("graffiti_4", STRING(sModel));
		
		int index = PrecacheDecal(sModel);
		rp_SetClientInt(client, i_GraffitiIndex, index);
		
		char name[32];
		rp_GetItemData(itemID, item_name, STRING(name));
		rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);	
	}
	else if(itemID == 135)
	{	
		rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
			
		char sModel[64];
		rp_GetGlobalData("graffiti_5", STRING(sModel));
		
		int index = PrecacheDecal(sModel);
		rp_SetClientInt(client, i_GraffitiIndex, index);
		
		char name[32];
		rp_GetItemData(itemID, item_name, STRING(name));
		rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);	
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

	if(Distance(client, target) <= 80.0)
	{
		if(StrEqual(name, "casino_lotery_1"))
			Casino_Lotery1(client);
		else if(StrEqual(name, "casino_lotery_2"))
			Casino_Lotery2(client);
		else if(StrEqual(name, "casino_lotery_3"))
			Casino_Lotery3(client);
		else if(StrEqual(name, "casino_lotery_4"))
			rp_PrintToChat(client, "Cette fonctionnalité est en développement.");
	}		
}	

void Casino_Lotery1(int client)
{
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_MenuCasino1);
	menu.SetTitle("%T", "Casino_Title", LANG_SERVER, 1);
	
	char translation[64];
	
	Format(STRING(translation), "%T", "Casino_Bet", LANG_SERVER, 10);
	menu.AddItem("10", translation);
	
	Format(STRING(translation), "%T", "Casino_Bet", LANG_SERVER, 50);
	menu.AddItem("50", translation);
	
	Format(STRING(translation), "%T", "Casino_Bet", LANG_SERVER, 100);
	menu.AddItem("100", translation);
	
	Format(STRING(translation), "%T", "Casino_BetInfo", LANG_SERVER);
	menu.AddItem("info", translation);
	
	menu.AddItem("", "", ITEMDRAW_RAWLINE);
	
	Format(STRING(translation), "%T", "Casino_Chance", LANG_SERVER);
	menu.AddItem("", translation, ITEMDRAW_DISABLED);
	
	Format(STRING(translation), "%T", "Casino_InfoHospital", LANG_SERVER);
	menu.AddItem("", translation, ITEMDRAW_DISABLED);
	
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Handle_MenuCasino1(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[32];
		menu.GetItem(param, STRING(info));
		
		if (StrEqual(info, "10"))
	    {
			if(rp_GetClientInt(client, i_Money) >= 10)
			{
				rp_SetClientInt(client, i_Money, rp_GetClientInt(client, i_Money) - 10);
				rp_SetJobCapital(16, rp_GetJobCapital(16) + 5);
				rp_SetJobCapital(4, rp_GetJobCapital(4) + 5);
				EmitCashSound(client, -10);
				rp_SetClientStat(client, i_LotoSpent, rp_GetClientStat(client, i_LotoSpent) + 10);
				rp_SetClientBool(client, b_DisplayHud, true);
		       
				int nombre = GetRandomInt(1, 3);
				if(nombre == 1) // GAGNE
		        {
					nombre = 0;
					int randomWin = GetRandomInt(1, 4);
					switch(randomWin)
		            {
		                case 1:
						{
							rp_PrintToChat(client, "Erreur de la banque en votre faveur, recevez \x0317$\x01.");
							EmitCashSound(client, 17);
							rp_SetJobCapital(16, rp_GetJobCapital(16) - 17);
							rp_SetClientInt(client, i_Money, rp_GetClientInt(client, i_Money) + 17);
							rp_SetClientStat(client, i_LotoWon, rp_GetClientStat(client, i_LotoWon) + 17);
							nombre = 0;
		                }
		                case 2:
		                {
							rp_PrintToChat(client, "Vous avez \x02perdu\x01... Mais vous ramassez discrètement par terre un billet de \x0318$\x01...");
							EmitCashSound(client, 18);
							rp_SetJobCapital(16, rp_GetJobCapital(16) - 18);
							rp_SetClientInt(client, i_Money, rp_GetClientInt(client, i_Money) + 18);
							rp_SetClientStat(client, i_LotoWon, rp_GetClientStat(client, i_LotoWon) + 18);
							nombre = 0;
		                }
		                case 3:
		                {
							rp_PrintToChat(client, "Vous avez \x03gagné\x01 ! (Le droit de recommencer..... \x0320$\x01).");
							EmitCashSound(client, 20);
							rp_SetJobCapital(16, rp_GetJobCapital(16) - 20);
							rp_SetClientInt(client, i_Money, rp_GetClientInt(client, i_Money) + 20);
							rp_SetClientStat(client, i_LotoWon, rp_GetClientStat(client, i_LotoWon) + 20);
							nombre = 0;
		                }
		                case 4:
		                {
							rp_PrintToChat(client, "Vous avez \x03gagné\x01 la somme de \x0315$\x01.");
							EmitCashSound(client, 15);
							rp_SetJobCapital(16, rp_GetJobCapital(16) - 15);
							rp_SetClientInt(client, i_Money, rp_GetClientInt(client, i_Money) + 15);
							rp_SetClientStat(client, i_LotoWon, rp_GetClientStat(client, i_LotoWon) + 15);
							nombre = 0;
		                }
		                default:
		                {
		                    rp_PrintToChat(client, "Erreur, veuillez la signaler à un admin. [WIN]");
		                }
		            }
		        }
				else if(nombre == 2) //PERDU
		        {
		            nombre = 0;
		            int randomLoose = GetRandomInt(1, 4);
		            switch(randomLoose)
		            {
		                case 1:
		                {
		                    rp_PrintToChat(client, "Malheureusement un bus a écrasé notre croupier avec vos gains, vous avez \x02perdu\x01...");
		                }
		                case 2:
		                {
		                    rp_PrintToChat(client, "Vous avez \x03gagné\x01 ! Mais, dans votre élant de joie vous donnez tout l'argent au casino. \x03Merci\x01 !");
		                }
		                case 3:
		                {
		                    rp_PrintToChat(client, "Vous avez utilisez des faux billets, vous avez \x02perdu\x01...");
		                }
		                case 4:
		                {
		                    rp_PrintToChat(client, "Vous avez \x02perdu\x01...");
		                }
		                default:
		                {
		                    rp_PrintToChat(client, "Erreur, veuillez la signaler à un admin. [LOOSE]");
		                }
		            }
		        }
				else if(nombre == 3) //PERDU
		        {
					nombre = 0;
					rp_PrintToChat(client, "Vous avez \x02perdu\x01... Dommage..");
		        }
			}
			else
			{
				rp_PrintToChat(client, "%t", "Client_NotEnoughtCash", LANG_SERVER);
			}	
	    }
		else if (StrEqual(info, "50"))
	    {
			if(rp_GetClientInt(client, i_Money) >= 50)
			{
				rp_SetClientInt(client, i_Money, rp_GetClientInt(client, i_Money) - 50);
				rp_SetJobCapital(16, rp_GetJobCapital(16) + 25);
				rp_SetJobCapital(4, rp_GetJobCapital(4) + 25);
				EmitCashSound(client, -50);
				rp_SetClientStat(client, i_LotoSpent, rp_GetClientStat(client, i_LotoSpent) + 50);
				rp_SetClientBool(client, b_DisplayHud, true);
		       
				int nombre = GetRandomInt(1, 3);
				if(nombre == 1) // GAGNE
		        {
					nombre = 0;
					int randomWin = GetRandomInt(1, 4);
					switch(randomWin)
		            {
		                case 1:
						{
							rp_PrintToChat(client, "Erreur de la banque en votre faveur, recevez \x0390$\x01.");
							EmitCashSound(client, 90);
							rp_SetJobCapital(16, rp_GetJobCapital(16) - 90);
							rp_SetClientInt(client, i_Money, rp_GetClientInt(client, i_Money) + 90);
							rp_SetClientStat(client, i_LotoWon, rp_GetClientStat(client, i_LotoWon) + 90);						
							nombre = 0;
		                }
		                case 2:
		                {
							rp_PrintToChat(client, "Vous avez \x02perdu\x01... Mais vous ramassez discrètement par terre un billet de \x0350$\x01...");
							EmitCashSound(client, 50);
							rp_SetJobCapital(16, rp_GetJobCapital(16) - 50);
							rp_SetClientInt(client, i_Money, rp_GetClientInt(client, i_Money) + 50);
							rp_SetClientStat(client, i_LotoWon, rp_GetClientStat(client, i_LotoWon) + 50);		
							nombre = 0;
		                }
		                case 3:
		                {
							rp_PrintToChat(client, "Vous avez \x03gagné\x01 ! (Le droit de recommencer..... \x03100$\x01).");
							EmitCashSound(client, 100);
							rp_SetJobCapital(16, rp_GetJobCapital(16) - 100);
							rp_SetClientInt(client, i_Money, rp_GetClientInt(client, i_Money) + 100);
							rp_SetClientStat(client, i_LotoWon, rp_GetClientStat(client, i_LotoWon) + 100);
							nombre = 0;
		                }
		                case 4:
		                {
							rp_PrintToChat(client, "Vous avez \x03gagné\x01 la somme de \x0375$\x01.");
							EmitCashSound(client, 75);
							rp_SetJobCapital(16, rp_GetJobCapital(16) - 75);
							rp_SetClientInt(client, i_Money, rp_GetClientInt(client, i_Money) + 75);
							rp_SetClientStat(client, i_LotoWon, rp_GetClientStat(client, i_LotoWon) + 75);
							nombre = 0;
		                }
		                default:
		                {
		                    rp_PrintToChat(client, "Erreur, veuillez la signaler à un admin. [WIN]");
		                }
		            }
		        }
				else if(nombre == 2) //PERDU
		        {
		            nombre = 0;
		            int randomLoose = GetRandomInt(1, 4);
		            switch(randomLoose)
		            {
		                case 1:
		                {
		                    rp_PrintToChat(client, "Malheureusement un bus a écrasé notre croupier avec vos gains, vous avez \x02perdu\x01...");
		                }
		                case 2:
		                {
		                    rp_PrintToChat(client, "Vous avez \x03gagné\x01 ! Mais, dans votre élant de joie vous donnez tout l'argent au casino. \x03Merci\x01 !");
		                }
		                case 3:
		                {
		                    rp_PrintToChat(client, "Vous avez utilisez des faux billets, vous avez \x02perdu\x01...");
		                }
		                case 4:
		                {
		                    rp_PrintToChat(client, "Vous avez \x02perdu\x01...");
		                }
		                default:
		                {
		                    rp_PrintToChat(client, "Erreur, veuillez la signaler à un admin. [LOOSE]");
		                }
		            }
		        }
				else if(nombre == 3) //PERDU
		        {
					nombre = 0;
					rp_PrintToChat(client, "Vous avez \x02perdu\x01... Dommage..");
		        }
			}
			else
			{
				rp_PrintToChat(client, "%t", "Client_NotEnoughtCash", LANG_SERVER);
			}
	    }
		else if (StrEqual(info, "100"))
	    {
			if(rp_GetClientInt(client, i_Money) >= 100)
			{	
				rp_SetClientInt(client, i_Money, rp_GetClientInt(client, i_Money) - 100);
				rp_SetJobCapital(16, rp_GetJobCapital(16) + 50);
				rp_SetJobCapital(4, rp_GetJobCapital(4) + 50);
				EmitCashSound(client, -100);
				rp_SetClientStat(client, i_LotoSpent, rp_GetClientStat(client, i_LotoSpent) + 100);
				rp_SetClientBool(client, b_DisplayHud, true);
		       
				int nombre = GetRandomInt(1, 3);
				if(nombre == 1) // GAGNE
		        {
					nombre = 0;
					int randomWin = GetRandomInt(1, 4);
					switch(randomWin)
		            {
		                case 1:
						{
							rp_PrintToChat(client, "Erreur de la banque en votre faveur, recevez \x03170$\x01.");
							EmitCashSound(client, 170);
							rp_SetJobCapital(16, rp_GetJobCapital(16) - 170);
							rp_SetClientInt(client, i_Money, rp_GetClientInt(client, i_Money) + 170);
							rp_SetClientStat(client, i_LotoWon, rp_GetClientStat(client, i_LotoWon) + 170);
							nombre = 0;
		                }
		                case 2:
		                {
							rp_PrintToChat(client, "Vous avez \x02perdu\x01... Mais vous ramassez discrètement par terre un billet de \x03100$\x01...");
							EmitCashSound(client, 100);
							rp_SetJobCapital(16, rp_GetJobCapital(16) - 100);
							rp_SetClientInt(client, i_Money, rp_GetClientInt(client, i_Money) + 100);
							rp_SetClientStat(client, i_LotoWon, rp_GetClientStat(client, i_LotoWon) + 100);
							nombre = 0;
		                }
		                case 3:
		                {
							rp_PrintToChat(client, "Vous avez \x03gagné\x01 ! (Le droit de recommencer..... \x03200$\x01).");
							EmitCashSound(client, 200);
							rp_SetJobCapital(16, rp_GetJobCapital(16) - 200);
							rp_SetClientInt(client, i_Money, rp_GetClientInt(client, i_Money) + 200);
							rp_SetClientStat(client, i_LotoWon, rp_GetClientStat(client, i_LotoWon) + 200);
							nombre = 0;
		                }
		                case 4:
		                {
							rp_PrintToChat(client, "Vous avez \x03gagné\x01 la somme de \x03150$\x01.");
							EmitCashSound(client, 150);
							rp_SetJobCapital(16, rp_GetJobCapital(16) - 150);
							rp_SetClientInt(client, i_Money, rp_GetClientInt(client, i_Money) + 150);
							rp_SetClientStat(client, i_LotoWon, rp_GetClientStat(client, i_LotoWon) + 150);
							nombre = 0;
		                }
		                default:
		                {
		                    rp_PrintToChat(client, "Erreur, veuillez la signaler à un admin. [WIN]");
		                }
		            }
		        }
				else if(nombre == 2) //PERDU
		        {
		            nombre = 0;
		            int randomLoose = GetRandomInt(1, 4);
		            switch(randomLoose)
		            {
		                case 1:
		                {
		                    rp_PrintToChat(client, "Malheureusement un bus a écrasé notre croupier avec vos gains, vous avez \x02perdu\x01...");
		                }
		                case 2:
		                {
		                    rp_PrintToChat(client, "Vous avez \x03gagné\x01 ! Mais, dans votre élant de joie vous donnez tout l'argent au casino. \x03Merci\x01 !");
		                }
		                case 3:
		                {
		                    rp_PrintToChat(client, "Vous avez utilisez des faux billets, vous avez \x02perdu\x01...");
		                }
		                case 4:
		                {
		                    rp_PrintToChat(client, "Vous avez \x02perdu\x01...");
		                }
		                default:
		                {
		                    rp_PrintToChat(client, "Erreur, veuillez la signaler à un admin. [LOOSE]");
		                }
		            }
		        }
				else if(nombre == 3) //PERDU
		        {
					nombre = 0;
					rp_PrintToChat(client, "Vous avez \x02perdu\x01... Dommage..");
		        }
			}
			else
			{
				rp_PrintToChat(client, "%t", "Client_NotEnoughtCash", LANG_SERVER);
			}
	    }
		else if (StrEqual(info, "info"))
		{
			Panel infocasino1 = new Panel();
			infocasino1.SetTitle("~~~~~~~~~ - MACHINE 1 - ~~~~~~~~~");
			infocasino1.DrawText("-|Les lots de la machine 1 sont ci-dessous|-");
			infocasino1.DrawText("- 10$ --> Gain Max[20$]");
			infocasino1.DrawText("- 50$ --> Gain Max[100$]");
			infocasino1.DrawText("- 100$ --> Gain Max[200$]");
			infocasino1.DrawItem("Retour");
			infocasino1.Send(client, Casino1Exit, -1);
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

public int Casino1Exit(Menu menu, MenuAction action, int client, int param2)
{
	if (action == MenuAction_Select)
	{
		Casino_Lotery1(client);
	}
	else if (action == MenuAction_Cancel)
	{
		rp_SetClientBool(client, b_DisplayHud, true);
	}
	
	return 0;
}

void Casino_Lotery2(int client)
{
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_MenuCasino2);
	menu.SetTitle("%T", "Casino_Title", LANG_SERVER, 2);
	
	char translation[64];
	Format(STRING(translation), "%T", "Casino_Bet", LANG_SERVER, 200);
	menu.AddItem("200", translation);
	
	Format(STRING(translation), "%T", "Casino_Bet", LANG_SERVER, 500);
	menu.AddItem("500", translation);
	
	Format(STRING(translation), "%T", "Casino_Bet", LANG_SERVER, 1000);
	menu.AddItem("1000", translation);

	Format(STRING(translation), "%T", "Casino_BetInfo", LANG_SERVER);
	menu.AddItem("info", translation);
	
	menu.AddItem("", "", ITEMDRAW_RAWLINE);
	
	Format(STRING(translation), "%T", "Casino_Chance", LANG_SERVER);
	menu.AddItem("", translation, ITEMDRAW_DISABLED);
	
	Format(STRING(translation), "%T", "Casino_InfoHospital", LANG_SERVER);
	menu.AddItem("", translation, ITEMDRAW_DISABLED);
	
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Handle_MenuCasino2(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[32];
		menu.GetItem(param, STRING(info));
		
		if (StrEqual(info, "200"))
	    {
			if(rp_GetClientInt(client, i_Money) >= 200)
			{
				rp_SetClientInt(client, i_Money, rp_GetClientInt(client, i_Money) - 200);
				rp_SetJobCapital(16, rp_GetJobCapital(16) + 100);
				rp_SetJobCapital(4, rp_GetJobCapital(4) + 100);
				EmitCashSound(client, -200);
				rp_SetClientStat(client, i_LotoSpent, rp_GetClientStat(client, i_LotoSpent) + 200);
				rp_SetClientBool(client, b_DisplayHud, true);
		       
				int nombre = GetRandomInt(1, 3);
				if(nombre == 1) // GAGNE
		        {
					nombre = 0;
					int randomWin = GetRandomInt(1, 4);
					switch(randomWin)
		            {
		                case 1:
						{
							rp_PrintToChat(client, "Erreur de la banque en votre faveur, recevez \x03400$\x01.");
							EmitCashSound(client, 400);
							rp_SetJobCapital(16, rp_GetJobCapital(16) - 400);
							rp_SetClientInt(client, i_Money, rp_GetClientInt(client, i_Money) + 400);
							nombre = 0;
		                }
		                case 2:
		                {
							rp_PrintToChat(client, "Vous avez \x02perdu\x01... Mais vous ramassez discrètement par terre un billet de \x03300$\x01...");
							EmitCashSound(client, 300);
							rp_SetJobCapital(16, rp_GetJobCapital(16) - 300);
							rp_SetClientInt(client, i_Money, rp_GetClientInt(client, i_Money) + 300);
							rp_SetClientStat(client, i_LotoWon, rp_GetClientStat(client, i_LotoWon) + 300);
							nombre = 0;
		                }
		                case 3:
		                {
							rp_PrintToChat(client, "Vous avez \x03gagné\x01 ! (Le droit de recommencer..... \x03500$\x01).");
							EmitCashSound(client, 500);
							rp_SetJobCapital(16, rp_GetJobCapital(16) - 500);
							rp_SetClientInt(client, i_Money, rp_GetClientInt(client, i_Money) + 500);
							rp_SetClientStat(client, i_LotoWon, rp_GetClientStat(client, i_LotoWon) + 500);
							nombre = 0;
		                }
		                case 4:
		                {
							rp_PrintToChat(client, "Vous avez \x03gagné\x01 la somme de \x03450$\x01.");
							EmitCashSound(client, 450);
							rp_SetJobCapital(16, rp_GetJobCapital(16) - 450);
							rp_SetClientInt(client, i_Money, rp_GetClientInt(client, i_Money) + 450);
							rp_SetClientStat(client, i_LotoWon, rp_GetClientStat(client, i_LotoWon) + 450);
							nombre = 0;
		                }
		                default:
		                {
		                    rp_PrintToChat(client, "Erreur, veuillez la signaler à un admin. [WIN]");
		                }
		            }
		        }
				else if(nombre == 2) //PERDU
		        {
		            nombre = 0;
		            int randomLoose = GetRandomInt(1, 4);
		            switch(randomLoose)
		            {
		                case 1:
		                {
		                    rp_PrintToChat(client, "Malheureusement un bus a écrasé notre croupier avec vos gains, vous avez \x02perdu\x01...");
		                }
		                case 2:
		                {
		                    rp_PrintToChat(client, "Vous avez \x03gagné\x01 ! Mais, dans votre élant de joie vous donnez tout l'argent au casino. \x03Merci\x01 !");
		                }
		                case 3:
		                {
		                    rp_PrintToChat(client, "Vous avez utilisez des faux billets, vous avez \x02perdu\x01...");
		                }
		                case 4:
		                {
		                    rp_PrintToChat(client, "Vous avez \x02perdu\x01...");
		                }
		                default:
		                {
		                    rp_PrintToChat(client, "Erreur, veuillez la signaler à un admin. [LOOSE]");
		                }
		            }
		        }
				else if(nombre == 3) //PERDU
		        {
					nombre = 0;
					rp_PrintToChat(client, "Vous avez \x02perdu\x01... Dommage..");
		        }
			}
			else
			{
				rp_PrintToChat(client, "%t", "Client_NotEnoughtCash", LANG_SERVER);
			}	
	    }
		else if (StrEqual(info, "500"))
	    {
			if(rp_GetClientInt(client, i_Money) >= 500)
			{
				rp_SetClientInt(client, i_Money, rp_GetClientInt(client, i_Money) - 500);
				rp_SetJobCapital(16, rp_GetJobCapital(16) + 250);
				rp_SetJobCapital(4, rp_GetJobCapital(4) + 250);
				EmitCashSound(client, -500);
				rp_SetClientStat(client, i_LotoSpent, rp_GetClientStat(client, i_LotoSpent) + 500);			
				rp_SetClientBool(client, b_DisplayHud, true);
		       
				int nombre = GetRandomInt(1, 3);
				if(nombre == 1) // GAGNE
		        {
					nombre = 0;
					int randomWin = GetRandomInt(1, 4);
					switch(randomWin)
		            {
		                case 1:
						{
							rp_PrintToChat(client, "Erreur de la banque en votre faveur, recevez \x03800$\x01.");
							EmitCashSound(client, 800);
							rp_SetJobCapital(16, rp_GetJobCapital(16) - 800);
							rp_SetClientInt(client, i_Money, rp_GetClientInt(client, i_Money) + 800);						
							rp_SetClientStat(client, i_LotoWon, rp_GetClientStat(client, i_LotoWon) + 800);
							nombre = 0;
		                }
		                case 2:
		                {
							rp_PrintToChat(client, "Vous avez \x02perdu\x01... Mais vous ramassez discrètement par terre un billet de \x03500$\x01...");
							EmitCashSound(client, 500);
							rp_SetJobCapital(16, rp_GetJobCapital(16) - 500);
							rp_SetClientInt(client, i_Money, rp_GetClientInt(client, i_Money) + 500);
							rp_SetClientStat(client, i_LotoWon, rp_GetClientStat(client, i_LotoWon) + 500);
							nombre = 0;
		                }
		                case 3:
		                {
							rp_PrintToChat(client, "Vous avez \x03gagné\x01 ! (Le droit de recommencer..... \x031000$\x01).");
							EmitCashSound(client, 1000);
							rp_SetJobCapital(16, rp_GetJobCapital(16) - 1000);
							rp_SetClientInt(client, i_Money, rp_GetClientInt(client, i_Money) + 1000);
							rp_SetClientStat(client, i_LotoWon, rp_GetClientStat(client, i_LotoWon) + 1000);
							nombre = 0;
		                }
		                case 4:
		                {
							rp_PrintToChat(client, "Vous avez \x03gagné\x01 la somme de \x03750$\x01.");
							EmitCashSound(client, 750);
							rp_SetJobCapital(16, rp_GetJobCapital(16) - 750);
							rp_SetClientInt(client, i_Money, rp_GetClientInt(client, i_Money) + 750);
							rp_SetClientStat(client, i_LotoWon, rp_GetClientStat(client, i_LotoWon) + 750);
							nombre = 0;
		                }
		                default:
		                {
		                    rp_PrintToChat(client, "Erreur, veuillez la signaler à un admin. [WIN]");
		                }
		            }
		        }
				else if(nombre == 2) //PERDU
		        {
		            nombre = 0;
		            int randomLoose = GetRandomInt(1, 4);
		            switch(randomLoose)
		            {
		                case 1:
		                {
		                    rp_PrintToChat(client, "Malheureusement un bus a écrasé notre croupier avec vos gains, vous avez \x02perdu\x01...");
		                }
		                case 2:
		                {
		                    rp_PrintToChat(client, "Vous avez \x03gagné\x01 ! Mais, dans votre élant de joie vous donnez tout l'argent au casino. \x03Merci\x01 !");
		                }
		                case 3:
		                {
		                    rp_PrintToChat(client, "Vous avez utilisez des faux billets, vous avez \x02perdu\x01...");
		                }
		                case 4:
		                {
		                    rp_PrintToChat(client, "Vous avez \x02perdu\x01...");
		                }
		                default:
		                {
		                    rp_PrintToChat(client, "Erreur, veuillez la signaler à un admin. [LOOSE]");
		                }
		            }
		        }
				else if(nombre == 3) //PERDU
		        {
					nombre = 0;
					rp_PrintToChat(client, "Vous avez \x02perdu\x01... Dommage..");
		        }
			}
			else
			{
				rp_PrintToChat(client, "%t", "Client_NotEnoughtCash", LANG_SERVER);
			}
	    }
		else if (StrEqual(info, "1000"))
	    {
			if(rp_GetClientInt(client, i_Money) >= 1000)
			{	
				rp_SetClientInt(client, i_Money, rp_GetClientInt(client, i_Money) - 1000);
				rp_SetJobCapital(16, rp_GetJobCapital(16) + 500);
				rp_SetJobCapital(4, rp_GetJobCapital(4) + 500);
				EmitCashSound(client, -1000);
				rp_SetClientStat(client, i_LotoSpent, rp_GetClientStat(client, i_LotoSpent) + 1000);
				rp_SetClientBool(client, b_DisplayHud, true);
		       
				int nombre = GetRandomInt(1, 3);
				if(nombre == 1) // GAGNE
		        {
					nombre = 0;
					int randomWin = GetRandomInt(1, 4);
					switch(randomWin)
		            {
		                case 1:
						{
							rp_PrintToChat(client, "Erreur de la banque en votre faveur, recevez \x031700$\x01.");
							EmitCashSound(client, 1700);
							rp_SetJobCapital(16, rp_GetJobCapital(16) - 1700);
							rp_SetClientInt(client, i_Money, rp_GetClientInt(client, i_Money) + 1700);
							rp_SetClientStat(client, i_LotoWon, rp_GetClientStat(client, i_LotoWon) + 1700);
							nombre = 0;
		                }
		                case 2:
		                {
							rp_PrintToChat(client, "Vous avez \x02perdu\x01... Mais vous ramassez discrètement par terre un billet de \x031500$\x01...");
							EmitCashSound(client, 1500);
							rp_SetJobCapital(16, rp_GetJobCapital(16) - 1500);
							rp_SetClientInt(client, i_Money, rp_GetClientInt(client, i_Money) + 1500);
							rp_SetClientStat(client, i_LotoWon, rp_GetClientStat(client, i_LotoWon) + 1500);
							nombre = 0;
		                }
		                case 3:
		                {
							rp_PrintToChat(client, "Vous avez \x03gagné\x01 ! (Le droit de recommencer..... \x032000$\x01).");
							EmitCashSound(client, 2000);
							rp_SetJobCapital(16, rp_GetJobCapital(16) - 2000);
							rp_SetClientInt(client, i_Money, rp_GetClientInt(client, i_Money) + 2000);
							rp_SetClientStat(client, i_LotoWon, rp_GetClientStat(client, i_LotoWon) + 2000);
							nombre = 0;
		                }
		                case 4:
		                {
							rp_PrintToChat(client, "Vous avez \x03gagné\x01 la somme de \x031900$\x01.");
							EmitCashSound(client, 1900);
							rp_SetJobCapital(16, rp_GetJobCapital(16) - 1900);
							rp_SetClientInt(client, i_Money, rp_GetClientInt(client, i_Money) + 1900);
							rp_SetClientStat(client, i_LotoWon, rp_GetClientStat(client, i_LotoWon) + 1900);
							nombre = 0;
		                }
		                default:
		                {
		                    rp_PrintToChat(client, "Erreur, veuillez la signaler à un admin. [WIN]");
		                }
		            }
		        }
				else if(nombre == 2) //PERDU
		        {
		            nombre = 0;
		            int randomLoose = GetRandomInt(1, 4);
		            switch(randomLoose)
		            {
		                case 1:
		                {
		                    rp_PrintToChat(client, "Malheureusement un bus a écrasé notre croupier avec vos gains, vous avez \x02perdu\x01...");
		                }
		                case 2:
		                {
		                    rp_PrintToChat(client, "Vous avez \x03gagné\x01 ! Mais, dans votre élant de joie vous donnez tout l'argent au casino. \x03Merci\x01 !");
		                }
		                case 3:
		                {
		                    rp_PrintToChat(client, "Vous avez utilisez des faux billets, vous avez \x02perdu\x01...");
		                }
		                case 4:
		                {
		                    rp_PrintToChat(client, "Vous avez \x02perdu\x01...");
		                }
		                default:
		                {
		                    rp_PrintToChat(client, "Erreur, veuillez la signaler à un admin. [LOOSE]");
		                }
		            }
		        }
				else if(nombre == 3) //PERDU
		        {
					nombre = 0;
					rp_PrintToChat(client, "Vous avez \x02perdu\x01... Dommage..");
		        }
			}
			else
			{
				rp_PrintToChat(client, "%t", "Client_NotEnoughtCash", LANG_SERVER);
			}
	    }
		else if (StrEqual(info, "info"))
		{
			Panel infocasino1 = new Panel();
			infocasino1.SetTitle("~~~~~~~~~ - MACHINE 2 - ~~~~~~~~~");
			infocasino1.DrawText("-|Les lots de la machine 2 sont ci-dessous|-");
			infocasino1.DrawText("- 200$ --> Gain Max[500$]");
			infocasino1.DrawText("- 500$ --> Gain Max[1000$]");
			infocasino1.DrawText("- 1000$ --> Gain Max[2000$]");
			infocasino1.DrawItem("Retour");
			infocasino1.Send(client, Casino2Exit, -1);
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

public int Casino2Exit(Menu menu, MenuAction action, int client, int param2)
{
	if (action == MenuAction_Select)
	{
		Casino_Lotery2(client);
	}
	else if (action == MenuAction_Cancel)
	{
		rp_SetClientBool(client, b_DisplayHud, true);
	}
	
	return 0;
}

void Casino_Lotery3(int client)
{
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_MenuCasino3);
	
	menu.SetTitle("%T", "Casino_Title", LANG_SERVER, 3);
	
	char translation[64];
	Format(STRING(translation), "%T", "Casino_Bet", LANG_SERVER, 2000);
	menu.AddItem("2000", translation);
	
	Format(STRING(translation), "%T", "Casino_Bet", LANG_SERVER, 5000);
	menu.AddItem("5000", translation);
	
	Format(STRING(translation), "%T", "Casino_Bet", LANG_SERVER, 10000);
	menu.AddItem("10000", translation);
	
	Format(STRING(translation), "%T", "Casino_BetInfo", LANG_SERVER);
	menu.AddItem("info", translation);
	
	menu.AddItem("", "", ITEMDRAW_RAWLINE);
	
	Format(STRING(translation), "%T", "Casino_Chance", LANG_SERVER);
	menu.AddItem("", translation, ITEMDRAW_DISABLED);
	
	Format(STRING(translation), "%T", "Casino_InfoHospital", LANG_SERVER);
	menu.AddItem("", translation, ITEMDRAW_DISABLED);
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Handle_MenuCasino3(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[32];
		menu.GetItem(param, STRING(info));
		
		if (StrEqual(info, "2000"))
	    {
			if(rp_GetClientInt(client, i_Money) >= 2000)
			{
				rp_SetClientInt(client, i_Money, rp_GetClientInt(client, i_Money) - 2000);
				rp_SetJobCapital(16, rp_GetJobCapital(16) + 1000);
				rp_SetJobCapital(4, rp_GetJobCapital(4) + 1000);
				EmitCashSound(client, -2000);
				rp_SetClientStat(client, i_LotoSpent, rp_GetClientStat(client, i_LotoSpent) + 2000);
				rp_SetClientBool(client, b_DisplayHud, true);
		       
				int nombre = GetRandomInt(1, 3);
				if(nombre == 1) // GAGNE
		        {
					nombre = 0;
					int randomWin = GetRandomInt(1, 4);
					switch(randomWin)
		            {
		                case 1:
						{
							rp_PrintToChat(client, "Erreur de la banque en votre faveur, recevez \x034000$\x01.");
							EmitCashSound(client, 4000);
							rp_SetJobCapital(16, rp_GetJobCapital(16) - 4000);
							rp_SetClientInt(client, i_Money, rp_GetClientInt(client, i_Money) + 4000);
							rp_SetClientStat(client, i_LotoWon, rp_GetClientStat(client, i_LotoWon) + 4000);
							nombre = 0;
		                }
		                case 2:
		                {
							rp_PrintToChat(client, "Vous avez \x02perdu\x01... Mais vous ramassez discrètement par terre un billet de \x033000$\x01...");
							EmitCashSound(client, 3000);
							rp_SetJobCapital(16, rp_GetJobCapital(16) - 3000);
							rp_SetClientInt(client, i_Money, rp_GetClientInt(client, i_Money) + 3000);
							rp_SetClientStat(client, i_LotoWon, rp_GetClientStat(client, i_LotoWon) + 3000);
							nombre = 0;
		                }
		                case 3:
		                {
							rp_PrintToChat(client, "Vous avez \x03gagné\x01 ! (Le droit de recommencer..... \x035000$\x01).");
							EmitCashSound(client, 5000);
							rp_SetJobCapital(16, rp_GetJobCapital(16) - 5000);
							rp_SetClientInt(client, i_Money, rp_GetClientInt(client, i_Money) + 5000);
							rp_SetClientStat(client, i_LotoWon, rp_GetClientStat(client, i_LotoWon) + 5000);
							nombre = 0;
		                }
		                case 4:
		                {
							rp_PrintToChat(client, "Vous avez \x03gagné\x01 la somme de \x034500$\x01.");
							EmitCashSound(client, 4500);
							rp_SetJobCapital(16, rp_GetJobCapital(16) - 4500);
							rp_SetClientInt(client, i_Money, rp_GetClientInt(client, i_Money) + 4500);
							rp_SetClientStat(client, i_LotoWon, rp_GetClientStat(client, i_LotoWon) + 4500);
							nombre = 0;
		                }
		                default:
		                {
		                    rp_PrintToChat(client, "Erreur, veuillez la signaler à un admin. [WIN]");
		                }
		            }
		        }
				else if(nombre == 2) //PERDU
		        {
		            nombre = 0;
		            int randomLoose = GetRandomInt(1, 4);
		            switch(randomLoose)
		            {
		                case 1:
		                {
		                    rp_PrintToChat(client, "Malheureusement un bus a écrasé notre croupier avec vos gains, vous avez \x02perdu\x01...");
		                }
		                case 2:
		                {
		                    rp_PrintToChat(client, "Vous avez \x03gagné\x01 ! Mais, dans votre élant de joie vous donnez tout l'argent au casino. \x03Merci\x01 !");
		                }
		                case 3:
		                {
		                    rp_PrintToChat(client, "Vous avez utilisez des faux billets, vous avez \x02perdu\x01...");
		                }
		                case 4:
		                {
		                    rp_PrintToChat(client, "Vous avez \x02perdu\x01...");
		                }
		                default:
		                {
		                    rp_PrintToChat(client, "Erreur, veuillez la signaler à un admin. [LOOSE]");
		                }
		            }
		        }
				else if(nombre == 3) //PERDU
		        {
					nombre = 0;
					rp_PrintToChat(client, "Vous avez \x02perdu\x01... Dommage..");
		        }
			}
			else
			{
				rp_PrintToChat(client, "%t", "Client_NotEnoughtCash", LANG_SERVER);
			}	
	    }
		else if (StrEqual(info, "5000"))
	    {
			if(rp_GetClientInt(client, i_Money) >= 5000)
			{
				rp_SetClientInt(client, i_Money, rp_GetClientInt(client, i_Money) - 5000);
				rp_SetJobCapital(16, rp_GetJobCapital(16) + 2500);
				rp_SetJobCapital(4, rp_GetJobCapital(4) + 2500);
				EmitCashSound(client, -5000);
				rp_SetClientStat(client, i_LotoSpent, rp_GetClientStat(client, i_LotoSpent) + 5000);
				rp_SetClientBool(client, b_DisplayHud, true);
		       
				int nombre = GetRandomInt(1, 3);
				if(nombre == 1) // GAGNE
		        {
					nombre = 0;
					int randomWin = GetRandomInt(1, 4);
					switch(randomWin)
		            {
		                case 1:
						{
							rp_PrintToChat(client, "Erreur de la banque en votre faveur, recevez \x038000$\x01.");
							EmitCashSound(client, 8000);
							rp_SetJobCapital(16, rp_GetJobCapital(16) - 8000);
							rp_SetClientInt(client, i_Money, rp_GetClientInt(client, i_Money) + 8000);
							rp_SetClientStat(client, i_LotoWon, rp_GetClientStat(client, i_LotoWon) + 800);									
							nombre = 0;
		                }
		                case 2:
		                {
							rp_PrintToChat(client, "Vous avez \x02perdu\x01... Mais vous ramassez discrètement par terre un billet de \x035000$\x01...");
							EmitCashSound(client, 5000);
							rp_SetJobCapital(16, rp_GetJobCapital(16) - 5000);
							rp_SetClientInt(client, i_Money, rp_GetClientInt(client, i_Money) + 5000);
							rp_SetClientStat(client, i_LotoWon, rp_GetClientStat(client, i_LotoWon) + 500);						
							nombre = 0;
		                }
		                case 3:
		                {
							rp_PrintToChat(client, "Vous avez \x03gagné\x01 ! (Le droit de recommencer..... \x0310000$\x01).");
							EmitCashSound(client, 10000);
							rp_SetJobCapital(16, rp_GetJobCapital(16) - 10000);
							rp_SetClientInt(client, i_Money, rp_GetClientInt(client, i_Money) + 10000);
							rp_SetClientStat(client, i_LotoWon, rp_GetClientStat(client, i_LotoWon) + 10000);
							nombre = 0;
		                }
		                case 4:
		                {
							rp_PrintToChat(client, "Vous avez \x03gagné\x01 la somme de \x037500$\x01.");
							EmitCashSound(client, 7500);
							rp_SetJobCapital(16, rp_GetJobCapital(16) - 7500);
							rp_SetClientInt(client, i_Money, rp_GetClientInt(client, i_Money) + 7500);
							rp_SetClientStat(client, i_LotoWon, rp_GetClientStat(client, i_LotoWon) + 7500);
							nombre = 0;
		                }
		                default:
		                {
		                    rp_PrintToChat(client, "Erreur, veuillez la signaler à un admin. [WIN]");
		                }
		            }
		        }
				else if(nombre == 2) //PERDU
		        {
		            nombre = 0;
		            int randomLoose = GetRandomInt(1, 4);
		            switch(randomLoose)
		            {
		                case 1:
		                {
		                    rp_PrintToChat(client, "Malheureusement un bus a écrasé notre croupier avec vos gains, vous avez \x02perdu\x01...");
		                }
		                case 2:
		                {
		                    rp_PrintToChat(client, "Vous avez \x03gagné\x01 ! Mais, dans votre élant de joie vous donnez tout l'argent au casino. \x03Merci\x01 !");
		                }
		                case 3:
		                {
		                    rp_PrintToChat(client, "Vous avez utilisez des faux billets, vous avez \x02perdu\x01...");
		                }
		                case 4:
		                {
		                    rp_PrintToChat(client, "Vous avez \x02perdu\x01...");
		                }
		                default:
		                {
		                    rp_PrintToChat(client, "Erreur, veuillez la signaler à un admin. [LOOSE]");
		                }
		            }
		        }
				else if(nombre == 3) //PERDU
		        {
					nombre = 0;
					rp_PrintToChat(client, "Vous avez \x02perdu\x01... Dommage..");
		        }
			}
			else
			{
				rp_PrintToChat(client, "%t", "Client_NotEnoughtCash", LANG_SERVER);
			}
	    }
		else if (StrEqual(info, "10000"))
	    {
			if(rp_GetClientInt(client, i_Money) >= 10000)
			{	
				rp_SetClientInt(client, i_Money, rp_GetClientInt(client, i_Money) - 10000);
				rp_SetJobCapital(16, rp_GetJobCapital(16) + 5000);
				rp_SetJobCapital(4, rp_GetJobCapital(4) + 5000);
				EmitCashSound(client, -10000);
				rp_SetClientStat(client, i_LotoSpent, rp_GetClientStat(client, i_LotoSpent) + 10000);
				rp_SetClientBool(client, b_DisplayHud, true);
		       
				int nombre = GetRandomInt(1, 3);
				if(nombre == 1) // GAGNE
		        {
					nombre = 0;
					int randomWin = GetRandomInt(1, 4);
					switch(randomWin)
		            {
		                case 1:
						{
							rp_PrintToChat(client, "Erreur de la banque en votre faveur, recevez \x0317000$\x01.");
							EmitCashSound(client, 17000);
							rp_SetJobCapital(16, rp_GetJobCapital(16) - 17000);
							rp_SetClientInt(client, i_Money, rp_GetClientInt(client, i_Money) + 17000);
							rp_SetClientStat(client, i_LotoWon, rp_GetClientStat(client, i_LotoWon) + 17000);
							nombre = 0;
		                }
		                case 2:
		                {
							rp_PrintToChat(client, "Vous avez \x02perdu\x01... Mais vous ramassez discrètement par terre un billet de \x0315000$\x01...");
							EmitCashSound(client, 15000);
							rp_SetJobCapital(16, rp_GetJobCapital(16) - 15000);
							rp_SetClientInt(client, i_Money, rp_GetClientInt(client, i_Money) + 15000);
							rp_SetClientStat(client, i_LotoWon, rp_GetClientStat(client, i_LotoWon) + 15000);
							nombre = 0;
		                }
		                case 3:
		                {
							rp_PrintToChat(client, "Vous avez \x03gagné\x01 ! (Le droit de recommencer..... \x0320000$\x01).");
							EmitCashSound(client, 20000);
							rp_SetJobCapital(16, rp_GetJobCapital(16) - 20000);
							rp_SetClientInt(client, i_Money, rp_GetClientInt(client, i_Money) + 20000);
							rp_SetClientStat(client, i_LotoWon, rp_GetClientStat(client, i_LotoWon) + 20000);
							nombre = 0;
		                }
		                case 4:
		                {
							rp_PrintToChat(client, "Vous avez \x03gagné\x01 la somme de \x0319000$\x01.");
							EmitCashSound(client, 19000);
							rp_SetJobCapital(16, rp_GetJobCapital(16) - 19000);
							rp_SetClientInt(client, i_Money, rp_GetClientInt(client, i_Money) + 19000);
							rp_SetClientStat(client, i_LotoWon, rp_GetClientStat(client, i_LotoWon) + 19000);
							nombre = 0;
		                }
		                default:
		                {
		                    rp_PrintToChat(client, "Erreur, veuillez la signaler à un admin. [WIN]");
		                }
		            }
		        }
				else if(nombre == 2) //PERDU
		        {
		            nombre = 0;
		            int randomLoose = GetRandomInt(1, 4);
		            switch(randomLoose)
		            {
		                case 1:
		                {
		                    rp_PrintToChat(client, "Malheureusement un bus a écrasé notre croupier avec vos gains, vous avez \x02perdu\x01...");
		                }
		                case 2:
		                {
		                    rp_PrintToChat(client, "Vous avez \x03gagné\x01 ! Mais, dans votre élant de joie vous donnez tout l'argent au casino. \x03Merci\x01 !");
		                }
		                case 3:
		                {
		                    rp_PrintToChat(client, "Vous avez utilisez des faux billets, vous avez \x02perdu\x01...");
		                }
		                case 4:
		                {
		                    rp_PrintToChat(client, "Vous avez \x02perdu\x01...");
		                }
		                default:
		                {
		                    rp_PrintToChat(client, "Erreur, veuillez la signaler à un admin. [LOOSE]");
		                }
		            }
		        }
				else if(nombre == 3) //PERDU
		        {
					nombre = 0;
					rp_PrintToChat(client, "Vous avez \x02perdu\x01... Dommage..");
		        }
			}
			else
			{
				rp_PrintToChat(client, "%t", "Client_NotEnoughtCash", LANG_SERVER);
			}
	    }
		else if (StrEqual(info, "info"))
		{
			Panel infocasino1 = new Panel();
			infocasino1.SetTitle("~~~~~~~~~ - MACHINE 3 - ~~~~~~~~~");
			infocasino1.DrawText("-|Les lots de la machine 3 sont ci-dessous|-");
			infocasino1.DrawText("- 2000$ --> Gain Max[5000$]");
			infocasino1.DrawText("- 5000$ --> Gain Max[10000$]");
			infocasino1.DrawText("- 10000$ --> Gain Max[20000$]");
			infocasino1.DrawItem("Retour");
			infocasino1.Send(client, Casino3Exit, -1);
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

public int Casino3Exit(Menu menu, MenuAction action, int client, int param2)
{
	if (action == MenuAction_Select)
	{
		Casino_Lotery3(client);
	}
	else if (action == MenuAction_Cancel)
	{
		rp_SetClientBool(client, b_DisplayHud, true);
	}
	
	return 0;
}