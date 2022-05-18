/*
*   Roleplay CS:GO de Benito est mis à disposition selon les termes de la licence Creative Commons Attribution .
* - Pas d’Utilisation Commerciale 
* - Partage dans les Mêmes Conditions 4.0 International.
*
*   Fondé(e) sur une œuvre à https://github.com/Mbk10201/Roleplay-CS-GO
*   Les autorisations au-delà du champ de cette licence peuvent être obtenues à https://steamcommunity.com/id/xsuprax/.
*
*   Merci de respecter le travail fourni par le ou les auteurs 
*   https://enemy-down.fr - benitalpa1020@gmail.com
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
#define RACK_MAX_MINER 		8
#define RACK_MAX_MINER_VIP 	16
#define JOBID				10

/***************************************************************************************

							G L O B A L  -  V A R S

***************************************************************************************/

Database g_DB;
	
enum struct ClientData {
	char steamID[32];
	int EntityPrinter[2];
	int EntityRack;
	bool HasDoublePrinter;
	bool HasRack;
}
ClientData iData[MAXPLAYERS + 1];

enum struct printer_data {
	int owner;
	int entity_index;
	int EntityMoney;
	int EntityMoneyValue;
	int UpgradeNumber;
	int Number;
	bool NeedPaper;
	bool Blindage;
	Handle TimerPaper;
	void SetON()
	{
		PlayAnimation(this.entity_index, "Running");
	}
	void SetOFF()
	{
		PlayAnimation(this.entity_index, "Off");
	}
	void SetPaper(bool value)
	{
		SetBodyGroup(this.entity_index, GetEntityStudioHdr(this.entity_index).FindBodyPart("InkCartridge"), value);
	}
	int GetMoneyValue()
	{
		return this.EntityMoneyValue;
	}
	void SetMoneyValue(int value)
	{
		this.EntityMoneyValue += value;
	}
}
printer_data printer[MAXENTITIES + 1];

enum struct Rack_Data {
	bool HasBattery;
	bool HasRGBKit;
	bool HasVentUpdateV1;
	bool HasVentUpdateV2;
	bool HasVentUpdateV3;
	bool Power;
	bool RGB_ON;
	int miners;
	int owner;
	float hashrate;
	float bitcoin;
	float battery_life;
	
	float GetBitcoinPrice() {
		return (36000.0 / this.bitcoin);
	}
	float GetHashRate() {
		return this.hashrate * this.miners;
	}
}
Rack_Data rack[MAXENTITIES + 1];

/***************************************************************************************

							P L U G I N  -  I N F O

***************************************************************************************/
public Plugin myinfo = 
{
	name = "Roleplay - [JOB] Technicien", 
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
}

// Init SQL
public void RP_OnSQLInit(Database db)
{
	g_DB = db;
	
	char buffer[4096];
	Format(STRING(buffer), 
	"CREATE TABLE IF NOT EXISTS `rp_bitcoin` ( \
	  `id` int(11) NOT NULL AUTO_INCREMENT, \
	  `steamid` varchar(32) COLLATE utf8_bin NOT NULL, \
	  `playername` varchar(64) COLLATE utf8_bin NOT NULL, \
	  `bitcoin` int(11) NOT NULL, \
	  PRIMARY KEY (`id`), \
	  UNIQUE KEY `steamid` (`steamid`) \
	  )ENGINE = InnoDB DEFAULT CHARSET = utf8 COLLATE = utf8_bin;");
	g_DB.Query(SQL_CheckForErrors, buffer);
	
	Format(STRING(buffer), 
	"CREATE TABLE IF NOT EXISTS `rp_bitcoin_history` ( \
	  `id` int(11) NOT NULL AUTO_INCREMENT, \
	  `steamid` varchar(32) COLLATE utf8_bin NOT NULL, \
	  `playername` varchar(64) COLLATE utf8_bin NOT NULL, \
	  `bitcoin` int(11) NOT NULL DEFAULT '0', \
	  `date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP, \
	  PRIMARY KEY (`id`) \
	  )ENGINE = InnoDB DEFAULT CHARSET = utf8 COLLATE = utf8_bin;");
	g_DB.Query(SQL_CheckForErrors, buffer);
	
	Format(STRING(buffer), 
	"CREATE TABLE IF NOT EXISTS `rp_bitcoin_exchange` ( \
	  `id` int(11) NOT NULL AUTO_INCREMENT, \
	  `steamid` varchar(32) COLLATE utf8_bin NOT NULL, \
	  `playername` varchar(64) COLLATE utf8_bin NOT NULL, \
	  `bitcoin` int(11) NOT NULL, \
	  `money` int(11) NOT NULL, \
	  `date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP, \
	  PRIMARY KEY (`id`) \
	  )ENGINE = InnoDB DEFAULT CHARSET = utf8 COLLATE = utf8_bin;");
	g_DB.Query(SQL_CheckForErrors, buffer);
}

public void OnMapStart()
{
	PrecacheModel("models/props_survival/upgrades/exojump.mdl");
	PrecacheModel("models/props_survival/jammer/jammer.mdl");
}	

public void OnMapEnd()
{
	SaveClientStuff();
}
/***************************************************************************************

									C A L L B A C K

***************************************************************************************/  

public void OnClientDisconnect(int client)
{
	if(!IsClientInGame(client))
		return;
	
	for(int i = 0; i <= 1; i++)
	{
		if(IsValidEntity(iData[client].EntityPrinter[i]))
		{
			RemoveEdict(iData[client].EntityPrinter[i]);
			iData[client].EntityPrinter[i] = -1;
		}
	}

	iData[client].HasRack = false;
	iData[client].HasDoublePrinter = false;
	rp_SetClientBool(client, b_HasKevlarRegen, false);
}

public void OnClientPutInServer(int client)
{	
	for(int i = 0; i <= 1; i++)
	{
		iData[client].EntityPrinter[i] = -1;
	}
	
	iData[client].HasRack = false;
	iData[client].HasDoublePrinter = false;
	rp_SetClientBool(client, b_HasKevlarRegen, false);
}

public void OnClientAuthorized(int client, const char[] auth) 
{	
	strcopy(iData[client].steamID, sizeof(iData[].steamID), auth);
}

public void RP_OnPlayerDeath(int attacker, int victim, int respawnTime)
{
	rp_SetClientBool(victim, b_HasKevlarRegen, false);
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
	else if(rp_IsValidPrinter(target) && Distance(client, target) <= 80.0)
	{
		if (printer[target].owner && client)
			MenuPrinter(client, target);
	}
	else if(IsEntityModelInArray(target, "model_money") && Distance(client, target) <= 80.0)
	{
		char sEntName[64];
		Entity_GetName(target, STRING(sEntName));
		int owner = Client_FindBySteamId(sEntName);
		int origin = FindMoneyPrinterOrigin(target);
		
		rp_SetClientInt(client, i_Money, rp_GetClientInt(client, i_Money) + printer[origin].GetMoneyValue());
		rp_SetJobCapital(5, rp_GetJobCapital(5) - printer[origin].GetMoneyValue());
		EmitCashSound(client, printer[origin].GetMoneyValue());
		RemoveEdict(target);
		
		printer[origin].EntityMoney = -1;
		if(client != owner)
			rp_PrintToChat(owner, "Les billets de votre imprimante à faux billet ont été volés !");
		
		if(rp_GetClientInt(client, i_Job) == 1)
		{
			rp_SetClientInt(client, i_Money, rp_GetClientInt(client, i_Money) + 100);
			rp_SetJobCapital(5, rp_GetJobCapital(5) - 100);
			EmitCashSound(client, 100);
			rp_PrintToChat(client, "Vous avez récupéré {green}100${default}.");	
		}
		else if(rp_GetClientInt(client, i_Job) == 2)
		{
			rp_SetClientInt(client, i_Money, rp_GetClientInt(client, i_Money) + printer[origin].GetMoneyValue() / 2);
			rp_SetJobCapital(3, rp_GetJobCapital(3) + printer[origin].GetMoneyValue() / 2);
			rp_SetJobCapital(5, rp_GetJobCapital(5) - printer[origin].GetMoneyValue());
			EmitCashSound(client, printer[origin].GetMoneyValue() / 2);
			rp_PrintToChat(client, "Vous avez récupéré {green}%i${default}.", printer[origin].GetMoneyValue() / 2);
		}
		else
			rp_PrintToChat(client, "Vous avez récupéré {green}%i${default}.", printer[origin].GetMoneyValue());	
		
		printer[origin].EntityMoneyValue = 0;
	}
	else if(IsEntityModelInArray(target, "model_rack") && rp_GetClientInt(client, i_Job) == JOBID)
	{
		if(Distance(client, target) <= 80.0)
			MenuRack(client, target);
		else
			Translation_PrintTooFar(client);
	}
}

public void RP_OnPlayerTase(int client, int target, int reward, const char[] class, const char[] model, const char[] name)
{
	if(IsEntityModelInArray(target, "model_printer") && Distance(client, target) <= 180)
	{
		rp_PrintToChat(client, "Vous avez saisi un appareil de contrebande.");
					
		reward = FindConVar("rp_tase_printer").IntValue;
		rp_PrintToChat(client, "Le Commandant vous reverse une prime de {green}%i$ {default}pour cette saisie.", reward);
		
		if(IsClientValid(printer[target].owner))
			rp_PrintToChat(printer[target].owner, "Votre imprimante à faux billet à été saisie par le {lightred}service de Police{default}.");
			
		RemovePrinter(target);
		RemoveEntity(target);
	}
}	

public void RP_OnClientBuild(Menu menu, int client)
{
	if(rp_GetClientInt(client, i_Job) == JOBID)
	{
		menu.AddItem("printer", "Installer une imprimante");
		//menu.AddItem("bitcoin", "Bitcoin");
	}	
}	

public void RP_OnClientBuildHandle(int client, const char[] info)
{
	if(StrEqual(info, "printer"))
	{
		if(rp_GetClientInt(client, i_Zone) != 777)
		{
			if (iData[client].EntityPrinter[0] != -1 && !iData[client].HasDoublePrinter)
				rp_PrintToChat(client, "Vous n'avez pas les compétences d'installer plusieurs imprimantes.");
			else if (iData[client].HasDoublePrinter && iData[client].EntityPrinter[0] != -1 && iData[client].EntityPrinter[1] != -1)
				rp_PrintToChat(client, "Vous avez déjà posé 2 imprimantes.");
			else
			{
				rp_SetClientInt(client, i_Machine, rp_GetClientInt(client, i_Machine) + 1);
				
				char sTmp[128];
				rp_GetGlobalData("model_printer", STRING(sTmp));
				
				float origin[3];
				GetClientAbsOrigin(client, origin);
				
				int ent = rp_CreatePhysics("", origin, NULL_VECTOR, sTmp, 0, true);
				
				if (iData[client].EntityPrinter[0] == -1)
				{
					iData[client].EntityPrinter[0] = ent;
					printer[ent].Number = 0;
				}
				else
				{
					iData[client].EntityPrinter[1] = ent;
					printer[ent].Number = 1;
				}
				
				printer[ent].entity_index = ent;
				printer[ent].owner = client;
				printer[ent].Blindage = false;
				printer[ent].NeedPaper = true;
				printer[ent].SetPaper(false);
				printer[ent].SetOFF();
				printer[ent].TimerPaper = CreateTimer(FindConVar("rp_printerpaper_timer").FloatValue, Timer_PrinterPaper, ent);
							
				origin[2] += 20;
				TeleportEntity(client, origin, NULL_VECTOR, NULL_VECTOR);
				
				CreateTimer(FindConVar("rp_printer_timer").FloatValue, Timer_GenerateMoney, ent);
			}
		}
		else
			rp_PrintToChat(client, "Interdit de poser une imprimante en zone P.V.P");
	}
	else if(StrEqual(info, "bitcoin"))
		MenuBuildBitcoin(client);
}	

void MenuBuildBitcoin(int client)
{
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_MenuBuildBitcoin);
	menu.SetTitle("Minage Bitcoin");
	
	char strFormat[32];
	Format(STRING(strFormat), "Rack de minage");
	if(iData[client].HasRack)
		menu.AddItem("", strFormat, ITEMDRAW_DISABLED);
	else
		menu.AddItem("rack", strFormat);		
	menu.AddItem("rgbkit", "Kit RGB");
	menu.AddItem("miner", "CrabMiner");
	menu.AddItem("upgrade01", "Kit Amélioration V1");
	menu.AddItem("upgrade02", "Kit Amélioration V2");
	menu.AddItem("upgrade03", "Kit Amélioration V3");
	menu.AddItem("battery", "Batterie lithium");
	
	menu.ExitButton = true;
	menu.ExitBackButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Handle_MenuBuildBitcoin(Menu menu, MenuAction action, int client, int param)
{
	if (action == MenuAction_Select)
	{
		char info[64];
		menu.GetItem(param, STRING(info));
		
		if(rp_GetClientInt(client, i_Zone) != 777)
		{
			if(IsOnGround(client))
			{
				int ent;
				float TeleportOrigin[3], JoueurOrigin[3];
				GetClientAbsOrigin(client, JoueurOrigin);
				TeleportOrigin[0] = JoueurOrigin[0];
				TeleportOrigin[1] = JoueurOrigin[1];
				TeleportOrigin[2] = (JoueurOrigin[2]);
				
				char sModel[128];
				if (StrEqual(info, "rgbkit"))
				{
					rp_GetGlobalData("model_rgbkit", STRING(sModel));
					ent = rp_CreatePhysics("", TeleportOrigin, NULL_VECTOR, sModel, 0, true);
					rp_PrintToChat(client, "Vous avez installé un Kit {lightred}R{green}G{lightblue}B{default}.");
				}
				else if (StrEqual(info, "miner"))
				{
					rp_GetGlobalData("model_miner", STRING(sModel));
					ent = rp_CreatePhysics("", TeleportOrigin, NULL_VECTOR, sModel, 0, true);
					rp_PrintToChat(client, "Vous avez installé une machine à miner.");
				}
				else if (StrEqual(info, "upgrade01"))
				{
					rp_GetGlobalData("model_upgrade01", STRING(sModel));
					ent = rp_CreatePhysics("", TeleportOrigin, NULL_VECTOR, sModel, 0, true);
					rp_PrintToChat(client, "Vous avez installé un Kit Amélioration V1.");
				}
				else if (StrEqual(info, "upgrade02"))
				{
					rp_GetGlobalData("model_upgrade02", STRING(sModel));
					ent = rp_CreatePhysics("", TeleportOrigin, NULL_VECTOR, sModel, 0, true);
					rp_PrintToChat(client, "Vous avez installé un Kit Amélioration V2.");
				}
				else if (StrEqual(info, "upgrade03"))
				{
					rp_GetGlobalData("model_upgrade03", STRING(sModel));
					ent = rp_CreatePhysics("", TeleportOrigin, NULL_VECTOR, sModel, 0, true);
					rp_PrintToChat(client, "Vous avez installé un Kit Amélioration V3.");
				}
				else if (StrEqual(info, "battery"))
				{
					rp_GetGlobalData("model_battery", STRING(sModel));
					ent = rp_CreatePhysics("", TeleportOrigin, NULL_VECTOR, sModel, 0, true);
					rp_PrintToChat(client, "Vous avez installé une Batterie Lithium.");
				}
				else if (StrEqual(info, "rack"))
				{
					rp_GetGlobalData("model_rack", STRING(sModel));
					ent = rp_CreatePhysics("", TeleportOrigin, NULL_VECTOR, sModel, 0, true);
					iData[client].HasRack = true;
					rack[ent].HasBattery = false;
					rack[ent].owner = client;
					SetEntProp(ent, Prop_Send, "m_nSkin", 1);
					//SetEntityMoveType(ent, MOVETYPE_NONE);
					
					rp_PrintToChat(client, "Vous avez installé un Rack de minage");		
				}	
				
				Entity_SetName(ent, iData[client].steamID);
				
				JoueurOrigin[2] += 35;
				TeleportEntity(client, JoueurOrigin, NULL_VECTOR, NULL_VECTOR);
			}	
		}	
		else 
			rp_PrintToChat(client, "Interdit d'installer un mélangeur en zone P.V.P");
	}
	else if (action == MenuAction_Cancel)
	{
		if (param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if(param == MenuCancel_ExitBack)	
			FakeClientCommand(client, "say !b");
	}
	else if (action == MenuAction_End)
		delete menu;
		
	return 0;
}

public void RP_OnClientStartTouch(int caller, int activator)
{
	if (IsValidEntity(caller))
	{
		if (IsEntityModelInArray(caller, "model_rgbkit") || IsEntityModelInArray(caller, "model_miner")
		|| IsEntityModelInArray(caller, "model_upgrade01") || IsEntityModelInArray(caller, "model_upgrade02")
		|| IsEntityModelInArray(caller, "model_upgrade03") || IsEntityModelInArray(caller, "model_battery") 
		|| IsEntityModelInArray(caller, "model_rack") || IsEntityModelInArray(caller, "model_printer")
		|| IsEntityModelInArray(caller, "model_printerpaper"))
		{
			if (IsEntityModelInArray(activator, "model_rack"))
			{
				int client = rack[activator].owner;
				if(IsClientValid(client) && rp_GetClientInt(client, i_Job) == JOBID)
				{
					if(IsEntityModelInArray(caller, "model_battery") )
					{
						if(!rack[activator].HasBattery)
						{
							SetBodyGroup(activator, 17, 4);
							rack[activator].HasBattery = true;
							rack[activator].battery_life = 100.0;
							RemoveEdict(caller);
							rp_Sound(client, "sound_filldrug", 0.2);
							
							float position[3];
							GetEntPropVector(activator, Prop_Send, "m_vecOrigin", position);
							rp_CreateParticle(position, "ambient_sparks", 1.0);
							
							rp_PrintToChat(client, "Le rack est désormais équipé d'une batterie lithium");
						}	
						else
							rp_PrintToChat(client, "Le rack est déjà équipé d'une batterie lithium.");
					}	
					else if(IsEntityModelInArray(caller, "model_miner"))
					{
						if(rack[activator].miners != RACK_MAX_MINER || rp_GetClientBool(client, b_IsVip) && rack[activator].miners != RACK_MAX_MINER_VIP)
						{
							rack[activator].miners++;
							SetBodyGroup(activator, rack[activator].miners, 1);
							RemoveEdict(caller);
							rp_Sound(client, "sound_filldrug", 0.2);
							
							float position[3];
							GetEntPropVector(activator, Prop_Send, "m_vecOrigin", position);
							rp_CreateParticle(position, "ambient_sparks", 1.0);
							
							rp_PrintToChat(client, "Le rack est désormais équipé de %i/%i miners.", rack[activator].miners, (rp_GetClientBool(client, b_IsVip)) ? RACK_MAX_MINER_VIP : RACK_MAX_MINER);
						}	
						else
						{
							rp_PrintToChat(client, "Le rack est déjà équipé de %i miners.", (rp_GetClientBool(client, b_IsVip)) ? RACK_MAX_MINER_VIP : RACK_MAX_MINER);
							return;
						}	
					}					
					else if(IsEntityModelInArray(caller, "model_rgbkit"))
					{
						if(!rack[activator].HasRGBKit)
						{
							rack[activator].HasRGBKit = true;
							rack[activator].RGB_ON = true;
							RemoveEdict(caller);
							rp_Sound(client, "sound_filldrug", 0.2);
							
							SetEntProp(activator, Prop_Send, "m_nSkin", 4);
							
							float position[3];
							GetEntPropVector(activator, Prop_Send, "m_vecOrigin", position);
							rp_CreateParticle(position, "ambient_sparks", 1.0);
							
							rp_PrintToChat(client, "Le rack est désormais équipé d'un kit {lightred}R{green}G{lightblue}B{default}.");
						}	
						else
							rp_PrintToChat(client, "Le rack est déjà équipé d'un kit {lightred}R{green}G{lightblue}B{default}.");
					}
					else if(IsEntityModelInArray(caller, "model_upgrade01"))
					{
						if(!rack[activator].HasVentUpdateV1)
						{
							SetBodyGroup(activator, 18, 1);
							rack[activator].HasVentUpdateV1 = true;
							RemoveEdict(caller);
							rp_Sound(client, "sound_filldrug", 0.2);
							
							float position[3];
							GetEntPropVector(activator, Prop_Send, "m_vecOrigin", position);
							rp_CreateParticle(position, "ambient_sparks", 1.0);
							
							rp_PrintToChat(client, "Le rack est désormais équipé d'une mise à jour v1.");
						}	
						else
							rp_PrintToChat(client, "Le rack est déjà équipé d'une mise à jour v1.");
					}
					else if(IsEntityModelInArray(caller, "model_upgrade02"))
					{
						if(!rack[activator].HasVentUpdateV2)
						{
							SetBodyGroup(activator, 18, 2);
							rack[activator].HasVentUpdateV2 = true;
							RemoveEdict(caller);
							rp_Sound(client, "sound_filldrug", 0.2);
							
							float position[3];
							GetEntPropVector(activator, Prop_Send, "m_vecOrigin", position);
							rp_CreateParticle(position, "ambient_sparks", 1.0);
							
							rp_PrintToChat(client, "Le rack est désormais équipé d'une mise à jour v2.");
						}	
						else
							rp_PrintToChat(client, "Le rack est déjà équipé d'une mise à jour v2.");
					}
					else if(IsEntityModelInArray(caller, "model_upgrade03"))
					{
						if(!rack[activator].HasVentUpdateV3)
						{
							SetBodyGroup(activator, 18, 3);
							rack[activator].HasVentUpdateV3 = true;
							RemoveEdict(caller);
							rp_Sound(client, "sound_filldrug", 0.2);
							
							float position[3];
							GetEntPropVector(activator, Prop_Send, "m_vecOrigin", position);
							rp_CreateParticle(position, "ambient_sparks", 1.0);
							
							rp_PrintToChat(client, "Le rack est désormais équipé d'une mise à jour v3.");
						}
						else
							rp_PrintToChat(client, "Le rack est déjà équipé d'une mise à jour v2.");
					}
				}
			}
			else if (IsEntityModelInArray(activator, "model_printer"))
			{
				if(IsEntityModelInArray(caller, "model_printerpaper"))
				{
					printer[activator].NeedPaper = false;
					printer[activator].SetPaper(true);
					printer[activator].SetON();
					printer[activator].TimerPaper = CreateTimer(FindConVar("rp_printerpaper_timer").FloatValue, Timer_PrinterPaper, activator);
					rp_PrintToChat(printer[activator].owner, "Votre imprimante a été ravitaillé en papier.");
					RemoveEdict(caller);
					rp_SoundAll(activator, "sound_full", 0.5);
				}
			}	
		}	
	}
}

public void RP_OnInventoryHandle(int client, int itemID)
{
	int target = GetClientAimTarget(client, false);
	
	if(itemID == 106)
	{
		if(rp_GetClientInt(client, i_Zone) != 777)
		{
			if (iData[client].EntityPrinter[0] != -1 && !iData[client].HasDoublePrinter)
				rp_PrintToChat(client, "Vous n'avez pas les compétences d'installer plusieurs imprimantes.");
			else if (iData[client].HasDoublePrinter && iData[client].EntityPrinter[0] != -1 && iData[client].EntityPrinter[1] != -1)
				rp_PrintToChat(client, "Vous avez déjà posé 2 imprimantes.");
			else
			{
				rp_SetClientInt(client, i_Machine, rp_GetClientInt(client, i_Machine) + 1);
				rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);		
				
				char sModel[128];
				rp_GetGlobalData("model_printer", STRING(sModel));
				
				float origin[3];
				GetClientAbsOrigin(client, origin);
				
				int ent = rp_CreatePhysics("", origin, NULL_VECTOR, sModel, 0, true);
				
				if (iData[client].EntityPrinter[0] == -1)
				{
					iData[client].EntityPrinter[0] = ent;
					printer[ent].Number = 0;
				}
				else
				{
					iData[client].EntityPrinter[1] = ent;
					printer[ent].Number = 1;
				}
				
				printer[ent].entity_index = ent;
				printer[ent].owner = client;
				printer[ent].UpgradeNumber = 0;
				printer[ent].Blindage = false;
				printer[ent].NeedPaper = true;
				printer[ent].SetPaper(false);
				printer[ent].SetOFF();
				printer[ent].TimerPaper = CreateTimer(FindConVar("rp_printerpaper_timer").FloatValue, Timer_PrinterPaper, ent);
				
				origin[2] += 20;
				TeleportEntity(client, origin, NULL_VECTOR, NULL_VECTOR);
							
				CreateTimer(FindConVar("rp_printer_timer").FloatValue, Timer_GenerateMoney, ent);
				
				char name[32];
				rp_GetItemData(itemID, item_name, STRING(name));
				rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
			}	
		}
		else 
			rp_PrintToChat(client, "Interdit de poser une imprimante en zone P.V.P");	
	}
	else if(itemID == 107)
	{
		if(GetPlayerWeaponSlot(client, CS_SLOT_C4) == -1)
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);	
				
			GivePlayerItem(client, "weapon_bumpmine");
			
			char name[32];
			rp_GetItemData(itemID, item_name, STRING(name));
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}
		else
			rp_PrintToChat(client, "Vous avez déjà des mines.");
	}
	else if(itemID == 108)
	{
		rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
			
		GivePlayerItem(client, "prop_weapon_upgrade_exojump");
		
		char name[32];
		rp_GetItemData(itemID, item_name, STRING(name));
		rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
	}	
	else if(itemID == 109)
	{
		if(rp_IsValidPrinter(target) && Distance(client, target) <= 80.0)
		{
			if(printer[target].owner == client)
			{
				rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
				
				printer[target].UpgradeNumber = 1;
				rp_PrintToChat(client, "L'Imprimante a été mis à jour (1.0).");
		
				char name[32];
				rp_GetItemData(itemID, item_name, STRING(name));
				rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
			}
			else
				rp_PrintToChat(client, "Ce n'est pas votre imprimante !");
		}
	}
	else if(itemID == 110)
	{
		if(rp_IsValidPrinter(target) && Distance(client, target) <= 80.0)
		{
			if(printer[target].owner == client)
			{
				rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
				
				printer[target].UpgradeNumber = 1;
				rp_PrintToChat(client, "L'Imprimante a été mis à jour (2.0).");
		
				char name[32];
				rp_GetItemData(itemID, item_name, STRING(name));
				rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
			}
			else
				rp_PrintToChat(client, "Ce n'est pas votre imprimante !");
		}
	}
	else if(itemID == 111)
	{
		if(rp_IsValidPrinter(target) && Distance(client, target) <= 80.0)
		{
			if(printer[target].owner == client)
			{
				rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
				
				printer[target].Blindage = true;
				rp_PrintToChat(client, "L'Imprimante a été blindé.");
		
				char name[32];
				rp_GetItemData(itemID, item_name, STRING(name));
				rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
			}
			else
				rp_PrintToChat(client, "Ce n'est pas votre imprimante !");
		}
	}
	else if(itemID == 112)
	{
		if(iData[client].EntityPrinter[0] == -1 || iData[client].EntityPrinter[1] == -1)
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
			
			float TeleportOrigin[3], JoueurOrigin[3];
			GetClientAbsOrigin(client, JoueurOrigin);
			TeleportOrigin[0] = JoueurOrigin[0];
			TeleportOrigin[1] = JoueurOrigin[1];
			TeleportOrigin[2] = (JoueurOrigin[2]);
			
			char sModel[128];
			rp_GetGlobalData("model_printerpaper", STRING(sModel));
			
			int ent = rp_CreatePhysics("", TeleportOrigin, NULL_VECTOR, sModel, 0, true);
			rp_PrintToChat(client, "Vous avez installé une cartouche de papier.");
			
			Entity_SetName(ent, iData[client].steamID);
			JoueurOrigin[2] += 35;
			TeleportEntity(client, JoueurOrigin, NULL_VECTOR, NULL_VECTOR);
	
			char name[32];
			rp_GetItemData(itemID, item_name, STRING(name));
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}
		else
			rp_PrintToChat(client, "Vous n'avez pas d'imprimante.");
	}
	else if(itemID == 113)
	{
		rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
		
		float position[3], velocity[3], angle[3];
		GetClientAbsOrigin(client, position);
		position[2] += 32.0;
		GetEntPropVector(client, Prop_Data, "m_vecVelocity", velocity);
		GetClientEyeAngles(client, angle);
		if (velocity[2] < -1000.0)
			velocity[2] = -1000.0;
		velocity[2] += 500.0;
		TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);
		
		rp_AttachCreateParticle(client, "trail1", 3.0);
		
		char name[32];
		rp_GetItemData(itemID, item_name, STRING(name));
		rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
	}
	else if(itemID == 143)
	{
		rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
		
		float velocity[3];
		GetEntPropVector(client, Prop_Data, "m_vecVelocity", velocity);
		velocity[0] *= 5.0;
		velocity[1] *= 5.0;
		velocity[2] = (FloatAbs(velocity[2]) * 2.0) + Math_GetRandomFloat(50.0, 75.0);
		
		TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);
		
		rp_AttachCreateParticle(client, "trail4", 3.0);
		
		char name[32];
		rp_GetItemData(itemID, item_name, STRING(name));
		rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
	}
	else if(itemID == 144)
	{
		if(!rp_GetClientBool(client, b_HasKevlarRegen)) 
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
			
			rp_SetClientBool(client, b_HasKevlarRegen, true);
			
			char name[32];
			rp_GetItemData(itemID, item_name, STRING(name));
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}
		else
			rp_PrintToChat(client, "Vous êtes déjà équipé d'une regénération kevlar.");
	}
	else if(itemID == 173)
	{
		if(iData[client].HasRack)
		{
			int entity = iData[client].EntityRack;

			if(!rack[entity].HasRGBKit)
			{
				rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
				
				float TeleportOrigin[3], JoueurOrigin[3];
				GetClientAbsOrigin(client, JoueurOrigin);
				TeleportOrigin[0] = JoueurOrigin[0];
				TeleportOrigin[1] = JoueurOrigin[1];
				TeleportOrigin[2] = (JoueurOrigin[2]);
				
				char sModel[128];
				rp_GetGlobalData("model_rgbkit", STRING(sModel));
				
				int ent = rp_CreatePhysics("", TeleportOrigin, NULL_VECTOR, sModel, 0, true);
				rp_PrintToChat(client, "Vous avez installé un Kit {lightred}R{green}G{lightblue}B{default}.");
				
				Entity_SetName(ent, iData[client].steamID);
				JoueurOrigin[2] += 35;
				TeleportEntity(client, JoueurOrigin, NULL_VECTOR, NULL_VECTOR);
				
				char name[32];
				rp_GetItemData(itemID, item_name, STRING(name));
				rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
			}	
			else
				rp_PrintToChat(client, "Votre rack possède déjà un kit {lightred}R{lightgreen}G{lightblue}B.");
		}	
		else
			rp_PrintToChat(client, "Vous n'avez pas de rack.");
	}
	else if(itemID == 174)
	{
		if(iData[client].HasRack)
		{
			int entity = iData[client].EntityRack;

			if(rack[entity].miners != RACK_MAX_MINER || rp_GetClientBool(client, b_IsVip) && rack[entity].miners != RACK_MAX_MINER_VIP)
			{
				rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
				
				float TeleportOrigin[3], JoueurOrigin[3];
				GetClientAbsOrigin(client, JoueurOrigin);
				TeleportOrigin[0] = JoueurOrigin[0];
				TeleportOrigin[1] = JoueurOrigin[1];
				TeleportOrigin[2] = (JoueurOrigin[2]);
				
				char sModel[128];
				rp_GetGlobalData("model_miner", STRING(sModel));
				
				int ent = rp_CreatePhysics("", TeleportOrigin, NULL_VECTOR, sModel, 0, true);
				rp_PrintToChat(client, "Vous avez installé un {green}Mineur{default}.");
				
				Entity_SetName(ent, iData[client].steamID);
				JoueurOrigin[2] += 35;
				TeleportEntity(client, JoueurOrigin, NULL_VECTOR, NULL_VECTOR);
				
				char name[32];
				rp_GetItemData(itemID, item_name, STRING(name));
				rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
			}	
			else
				rp_PrintToChat(client, "%s Le rack est déjà équipé de %i miners.", (rp_GetClientBool(client, b_IsVip)) ? RACK_MAX_MINER_VIP : RACK_MAX_MINER);
		}	
		else
			rp_PrintToChat(client, "%s Vous n'avez pas de rack.");
	}
	else if(itemID == 175)
	{
		if(!iData[client].HasRack) 
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
			
			float TeleportOrigin[3], JoueurOrigin[3];
			GetClientAbsOrigin(client, JoueurOrigin);
			TeleportOrigin[0] = JoueurOrigin[0];
			TeleportOrigin[1] = JoueurOrigin[1];
			TeleportOrigin[2] = (JoueurOrigin[2]);
			
			char sModel[128];
			rp_GetGlobalData("model_rack", STRING(sModel));
			
			int ent = rp_CreatePhysics("", TeleportOrigin, NULL_VECTOR, sModel, 0, true);
			CPrintToChat(client, "Vous avez installé un {green}Rack de minage{default}.");
			
			JoueurOrigin[2] += 35;
			TeleportEntity(client, JoueurOrigin, NULL_VECTOR, NULL_VECTOR);
			iData[client].EntityRack = ent;
			iData[client].HasRack = true;
			rack[ent].owner = client;
			
			char name[32];
			rp_GetItemData(itemID, item_name, STRING(name));
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}	
		else
			rp_PrintToChat(client, "Vous avez déjà un rack.");
	}
	else if(itemID == 178)
	{
		if(iData[client].HasRack) 
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
			
			float TeleportOrigin[3], JoueurOrigin[3];
			GetClientAbsOrigin(client, JoueurOrigin);
			TeleportOrigin[0] = JoueurOrigin[0];
			TeleportOrigin[1] = JoueurOrigin[1];
			TeleportOrigin[2] = (JoueurOrigin[2]);
			
			char sModel[128];
			rp_GetGlobalData("model_upgrade01", STRING(sModel));
			
			int ent = rp_CreatePhysics("", TeleportOrigin, NULL_VECTOR, sModel, 0, true);
			rp_PrintToChat(client, "Vous avez installé un Kit d'amélioration ventilateurs {green}v1{default}.");
			
			Entity_SetName(ent, iData[client].steamID);
			JoueurOrigin[2] += 35;
			TeleportEntity(client, JoueurOrigin, NULL_VECTOR, NULL_VECTOR);
			
			char name[32];
			rp_GetItemData(itemID, item_name, STRING(name));
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}	
		else
			rp_PrintToChat(client, "Vous n'avez pas de rack.");
	}
	else if(itemID == 179)
	{
		if(iData[client].HasRack) 
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
			iData[client].HasRack = true;
			
			float TeleportOrigin[3], JoueurOrigin[3];
			GetClientAbsOrigin(client, JoueurOrigin);
			TeleportOrigin[0] = JoueurOrigin[0];
			TeleportOrigin[1] = JoueurOrigin[1];
			TeleportOrigin[2] = (JoueurOrigin[2]);
			
			char sModel[128];
			rp_GetGlobalData("model_upgrade02", STRING(sModel));
			
			int ent = rp_CreatePhysics("", TeleportOrigin, NULL_VECTOR, sModel, 0, true);
			rp_PrintToChat(client, "Vous avez installé un Kit d'amélioration ventilateurs {green}v2{default}.");
			
			Entity_SetName(ent, iData[client].steamID);
			JoueurOrigin[2] += 35;
			TeleportEntity(client, JoueurOrigin, NULL_VECTOR, NULL_VECTOR);
			
			char name[32];
			rp_GetItemData(itemID, item_name, STRING(name));
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}	
		else
			rp_PrintToChat(client, "Vous n'avez pas de rack.");
	}
	else if(itemID == 180)
	{
		if(iData[client].HasRack) 
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
			iData[client].HasRack = true;
			
			float TeleportOrigin[3], JoueurOrigin[3];
			GetClientAbsOrigin(client, JoueurOrigin);
			TeleportOrigin[0] = JoueurOrigin[0];
			TeleportOrigin[1] = JoueurOrigin[1];
			TeleportOrigin[2] = (JoueurOrigin[2]);
			
			char sModel[128];
			rp_GetGlobalData("model_upgrade03", STRING(sModel));
			
			int ent = rp_CreatePhysics("", TeleportOrigin, NULL_VECTOR, sModel, 0, true);
			rp_PrintToChat(client, "Vous avez installé un Kit d'amélioration ventilateurs {green}v3{default}.");
			
			Entity_SetName(ent, iData[client].steamID);
			JoueurOrigin[2] += 35;
			TeleportEntity(client, JoueurOrigin, NULL_VECTOR, NULL_VECTOR);

			char name[32];
			rp_GetItemData(itemID, item_name, STRING(name));
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);
		}	
		else
			rp_PrintToChat(client, "Vous n'avez pas de rack.");
	}
}

public void RP_OnEntityEndLife(int entity)
{
	if(IsEntityModelInArray(entity, "model_printer"))
	{
		rp_PrintToChat(printer[entity].owner, "Votre imprimante a été détruite.");
		
		float position[3];
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", position);
		TE_SetupExplosion(position, -1, 1.0, 1, 0, 200, 200);
		TE_SendToAll();
		
		char sTmp[128];
		switch (GetRandomInt(1, 3))
		{
			case 1:strcopy(STRING(sTmp), "weapons/hegrenade/explode3.wav");
			case 2:strcopy(STRING(sTmp), "weapons/hegrenade/explode4.wav");
			case 3:strcopy(STRING(sTmp), "weapons/hegrenade/explode5.wav");
		}
		
		PrecacheSound(sTmp);
		EmitSoundToAll(sTmp, entity, _, _, _, 1.0, _, _, position);
		
		LoopClients(i)
		{
			if(!IsClientValid(i))
				continue;
			
			if(Distance(entity, i) <= 20)
			{
				ForcePlayerSuicide(i);
				rp_PrintToChat(i, "Vous avez été tuée par une explosion !");
			}
		}	
		
		RemovePrinter(entity);
		RemoveEntity(entity);
	}
}

public Action Timer_GenerateMoney(Handle timer, int entity)
{
	CreateTimer(FindConVar("rp_printer_timer").FloatValue, Timer_GenerateMoney, entity);
	int owner = printer[entity].owner;
	
	float position[3];
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", position);
	
	if (printer[entity].NeedPaper)
	{
		PrecacheSound("ui/beep22.wav");
		EmitSoundToAll("ui/beep22.wav", entity, _, _, _, 1.0, _, _, position);
		if (GetRandomInt(1, 10) == 5)
		{
			PrintHintText(owner, "Imprimante à court d'encre et de papier.");

			PrecacheSound("ui/weapon_cant_buy.wav");
			EmitSoundToClient(owner, "ui/weapon_cant_buy.wav", owner, _, _, _, 0.8);
		}
		return Plugin_Handled;
	}
		
	int sound = true;
	if(!rp_GetClientBool(owner, b_IsAfk))
	{
		if (rp_GetClientBool(owner, b_HasSwissAccount) && rp_GetClientInt(owner, i_JailTime) == 0)
		{
			if (printer[entity].UpgradeNumber == 0)
				rp_SetClientInt(owner, i_Bank, rp_GetClientInt(owner, i_Bank) + FindConVar("rp_printer_cash").IntValue);
			else if (printer[entity].UpgradeNumber == 1)
				rp_SetClientInt(owner, i_Bank, rp_GetClientInt(owner, i_Bank) + FindConVar("rp_printer_cash_v2").IntValue);
			else if (printer[entity].UpgradeNumber == 2)
				rp_SetClientInt(owner, i_Bank, rp_GetClientInt(owner, i_Bank) + FindConVar("rp_printer_cash_v3").IntValue);
		}
		else if (!IsValidEntity(printer[entity].EntityMoney))
		{
			char sModel[128];
			rp_GetGlobalData("model_money", STRING(sModel));
			
			PrecacheModel(sModel);
			int money = CreateEntityByName("prop_dynamic_override");
			DispatchKeyValue(money, "solid", "6");
			DispatchKeyValue(money, "model", sModel);
			DispatchSpawn(money);
			
			if (printer[entity].UpgradeNumber == 0)
				printer[entity].SetMoneyValue(FindConVar("rp_printer_cash").IntValue);
			else if (printer[entity].UpgradeNumber == 1)
				printer[entity].SetMoneyValue(FindConVar("rp_printer_cash_v2").IntValue);
			else if (printer[entity].UpgradeNumber == 2)
				printer[entity].SetMoneyValue(FindConVar("rp_printer_cash_v3").IntValue);
				
			Entity_SetName(money, iData[owner].steamID);
			
			position[1] -= 10;
			position[2] += 16;
			TeleportEntity(money, position, NULL_VECTOR, NULL_VECTOR);
			
			printer[entity].EntityMoney = money;
		}
		else if (IsValidEntity(printer[entity].EntityMoney))
		{
			int valeur;
			if (printer[entity].UpgradeNumber == 0)
				valeur = FindConVar("rp_printer_cash").IntValue;
			else if (printer[entity].UpgradeNumber == 1)
				valeur = FindConVar("rp_printer_cash_v2").IntValue;
			else if (printer[entity].UpgradeNumber == 2)
				valeur = FindConVar("rp_printer_cash_v3").IntValue;
				
			if (printer[entity].GetMoneyValue() >= FindConVar("rp_printer_cash_max").IntValue)
			{
				if (rp_GetClientInt(owner, i_JailTime) == 0 && !rp_GetClientBool(owner, b_IsAfk))
					printer[entity].SetMoneyValue(valeur);
			}
			else
			{
				sound = false;
				switch (GetRandomInt(1, 10))
				{
					case 5:CPrintToChat(owner, "Votre imprimante à faux billets déborde !");
					case 10:PrintHintText(owner, "Votre imprimante à faux billets déborde !");
				}
			}
		}
		
		if (sound)
		{
			char sTmp[128];
			rp_GetGlobalData("sound_cash", STRING(sTmp));
			EmitSoundToAll(sTmp, entity, _, _, _, 0.2, _, _, position);
		}
	}	
	
	return Plugin_Continue;
}

public Action Timer_PrinterPaper(Handle timer, int entity)
{
	if(!printer[entity].NeedPaper)
		printer[entity].NeedPaper = true;
		
	printer[entity].SetPaper(false);
	printer[entity].SetOFF();
		
	rp_PrintToChat(printer[entity].owner, "Votre imprimante à faux billets a besoin d'encre et de papier pour continuer à imprimer !");
	PrintCenterText(printer[entity].owner, "Votre imprimante à faux billets a besoin d'encre et de papier !");
	
	return Plugin_Handled;
}

void MenuPrinter(int client, int target)
{
	if (IsValidEntity(target))
	{
		char strFormat[64], entName[64], buffer[2][64];
		Entity_GetName(target, STRING(entName));
		ExplodeString(entName, "|", buffer, 2, 64);

		rp_SetClientBool(client, b_DisplayHud, false);
		
		Menu menu = new Menu(DoMenuPrinter);
		menu.SetTitle("Imprimante [%0.1f]\n", rp_GetEntityHealth(target));
		
		Format(STRING(strFormat), "destroy|%i", target);
		menu.AddItem(strFormat, "Détruire l'imprimante.");
		
		if (rp_GetEntityHealth(target) > 0)
		{			
			if (rp_GetClientInt(client, i_Job) == JOBID && rp_GetClientInt(client, i_Grade) > 4)
			{
				Format(STRING(strFormat), "store|%i", target);
				menu.AddItem(strFormat, "Ranger");
			}
			else
				menu.AddItem("", "Vous n'avez pas le droit de ranger cette machine.", ITEMDRAW_DISABLED);
		}
		else if (rp_GetEntityHealth(target) < 100 && rp_GetClientInt(client, i_Job) == JOBID)
		{
			Format(STRING(strFormat), "reparer|%i", target);
			menu.AddItem(strFormat, "Réparer l'imprimante.");
		}
			
		menu.ExitButton = true;
		menu.Display(client, MENU_TIME_FOREVER);
	}
	else
		rp_PrintToChat(client, "Un menu plus important est ouvert.");
}

public int DoMenuPrinter(Menu menu, MenuAction action, int client, int param)
{
	if (action == MenuAction_Select)
	{
		char info[64], buffer[2][64];
		menu.GetItem(param, STRING(info));		
		ExplodeString(info, "|", buffer, 2, 64);
		
		int entity = StringToInt(buffer[1]);
		int owner = printer[entity].owner;
		
		if (StrEqual(buffer[0], "store"))
		{
			PrecacheSound("weapons/movement3.wav");
			EmitSoundToAll("weapons/movement3.wav", client, _, _, _, 1.0);
			
			rp_SetClientItem(client, 106, rp_GetClientItem(client, 106, false) + 1, false);			
			rp_PrintToChat(client, "Vous avez rangé votre imprimante à faux billets dans votre inventaire.");
		}
		else if (StrEqual(buffer[0], "destroy"))
		{
			RemovePrinter(entity);
			RemoveEntity(entity);
		}	
		else if (StrEqual(buffer[0], "reparer"))
		{
			rp_SetEntityHealth(entity, 100.0);
			
			if(owner != client)
			{
				rp_PrintToChat(client, "Vous avez réparé l'imprimante de {green}%N{default}.", owner);
				rp_PrintToChat(owner, "{green}%N{default} a réparé votre imprimante.", client);
			}
			else
				rp_PrintToChat(client, "Vous avez réparé votre imprimante.");			
		}
		rp_SetClientBool(client, b_DisplayHud, true);
	}
	else if (action == MenuAction_Cancel)
	{
		if (param == MenuCancel_Exit || param == MenuCancel_ExitBack)
			rp_SetClientBool(client, b_DisplayHud, true);
	}
	else if (action == MenuAction_End)
		delete menu;

	return 0;
}

public void RP_ClientTimerEverySecond(int client)
{
	if(rp_GetClientBool(client, b_HasKevlarRegen) && IsPlayerAlive(client))
	{
		int kevlar = GetClientArmor(client);
		if(kevlar != 100)
			rp_SetClientArmor(client, GetClientArmor(client) + 1);
		else
			rp_SetClientBool(client, b_HasKevlarRegen, false);			
	}
}

public void RP_EntityTimerEverySecond(int entity)
{
	if(IsEntityModelInArray(entity, "model_rack"))
	{
		if(rack[entity].Power)
		{
			rp_SoundAll(entity, "sound_power", 0.1);
			float calcul = 0.7 * rack[entity].miners;
			rack[entity].hashrate = calcul;
			rack[entity].bitcoin += (calcul / 10000000);
			
			if(rack[entity].battery_life > 0.0)
				rack[entity].battery_life -= (rack[entity].miners * 0.02);
			else
			{
				rack[entity].battery_life = 0.0;
				rack[entity].HasBattery = false;
				rack[entity].Power = false;
				rp_PrintToChat(rack[entity].owner, "La batterie de votre rack est arrivé à court de vie, changez la.");
			}	
			
			/*if(IsClientValid(rack[entity].owner))
			{
				if(rack[entity].bitcoin = 1.0)
					rp_PrintToChat(rack[entity].owner, "Votre rack de minage a atteint le seuil de {lightgreen}1 {yellow}Bitcoin{default}.");
			}*/
		}
	}
}

void MenuRack(int client, int target)
{
	char strFormat[128], strIndex[64];
	
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_MenuRack);
	menu.SetTitle("Rack de minage\n Statut : %s\n    ", (rack[target].Power == true) ? "ON" : "OFF");
	
	Format(STRING(strFormat), "Mineurs : %i", rack[target].miners);	
	menu.AddItem("", strFormat, ITEMDRAW_DISABLED);
	
	Format(STRING(strFormat), "Fréquence : %0.1f Hz", rack[target].hashrate);	
	menu.AddItem("", strFormat, ITEMDRAW_DISABLED);
	
	Format(STRING(strFormat), "Bitcoin : %f BTC", rack[target].bitcoin);	
	menu.AddItem("", strFormat, ITEMDRAW_DISABLED);
	
	Format(STRING(strFormat), "Prix : %0.3f€", (rack[target].bitcoin * 36000));	
	menu.AddItem("", strFormat, ITEMDRAW_DISABLED);
	
	if(rack[target].HasBattery)
		Format(STRING(strFormat), "Batterie: 1/1 [%0.1f]", rack[target].battery_life);
	else
		Format(STRING(strFormat), "Batterie: 0/1");	
	menu.AddItem("", strFormat, ITEMDRAW_DISABLED);
	
	if(rack[target].Power)
	{
		Format(STRING(strIndex), "%i|stop", target);
		menu.AddItem(strIndex, "Arrêter");
	}	
	else
	{
		Format(STRING(strIndex), "%i|start", target);
		menu.AddItem(strIndex, "Démarrer");
	}	
	
	if(rack[target].HasRGBKit)
	{
		if(rack[target].RGB_ON)
		{
			Format(STRING(strIndex), "%i|offrgb", target);
			menu.AddItem(strIndex, "Eteindre RGB");
		}
		else 
		{
			Format(STRING(strIndex), "%i|onrgb", target);
			menu.AddItem(strIndex, "Allumer RGB");
		}
	}	
	
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Handle_MenuRack(Menu menu, MenuAction action, int client, int param)
{
	if (action == MenuAction_Select)
	{
		char info[64], buffer[2][64];
		menu.GetItem(param, STRING(info));		
		ExplodeString(info, "|", buffer, 2, 64);
		
		int target = StringToInt(buffer[0]);
		
		if(StrEqual(buffer[1], "start"))
		{
			if(!rack[target].HasBattery)
				rp_PrintToChat(client, "Le rack ne possède pas de batterie lithium !");
			else
			{
				if(rack[target].miners > 0)
				{
					if(rack[target].HasRGBKit)
						SetEntProp(target, Prop_Send, "m_nSkin", 4);	
					else
						if(rp_GetClientBool(client, b_IsVip))
							SetEntProp(target, Prop_Send, "m_nSkin", 3);		
						else
							SetEntProp(target, Prop_Send, "m_nSkin", 1);					
					
					rp_PrintToChat(client, "Vous avez démarrer le processus de minage au bitcoin.");
					rack[target].Power = true;
				}	
				else
					rp_PrintToChat(client, "Le rack ne possède pas de mineurs !");
			}	
		}
		else if(StrEqual(buffer[1], "stop"))
		{
			SetEntProp(target, Prop_Send, "m_nSkin", 1);				
			rp_StopSound(target, "sound_power");
			rack[target].Power = false;
			rp_PrintToChat(client, "Vous avez arréter le processus de minage.");
		}	
		else if(StrEqual(buffer[1], "onrgb"))
		{
			rack[target].RGB_ON = true;
			SetEntProp(target, Prop_Send, "m_nSkin", 4);
			rp_PrintToChat(client, "Vous avez allumer l'{lightred}R{green}G{lightblue}B{default}.");
		}
		else if(StrEqual(buffer[1], "offrgb"))
		{
			rack[target].RGB_ON = false;
			SetEntProp(target, Prop_Send, "m_nSkin", 1);
			rp_PrintToChat(client, "Vous avez étteint l'{lightred}R{green}G{lightblue}B{default}.");
		}
		
		MenuRack(client, target);
	}
	else if (action == MenuAction_Cancel)
	{
		if (param == MenuCancel_Exit || param == MenuCancel_ExitBack)
			rp_SetClientBool(client, b_DisplayHud, true);
	}
	else if (action == MenuAction_End)
		delete menu;
		
	return 0;
}

public void RP_OnReboot()
{
	SaveClientStuff();
}

void SaveClientStuff()
{
	LoopEntities(i)
	{
		if(!IsValidEntity(i))
			continue;
			
		if(IsEntityModelInArray(i, "model_rack"))
		{
			int client = rack[i].owner;
			
			if(IsClientValid(client))
			{
				if(rack[i].HasRGBKit)
					rp_SetClientItem(client, 173, rp_GetClientItem(client, 173, true) + 1, true);
				if(rack[i].miners != 0)
					rp_SetClientItem(client, 174, rp_GetClientItem(client, 174, true) + rack[i].miners, true);	
				if(rack[i].battery_life >= 50.0)
					rp_SetClientItem(client, 171, rp_GetClientItem(client, 171, true) + 1, true);	
				
				rp_SetClientItem(client, 175, rp_GetClientItem(client, 175, true) + 1, true);

				rp_PrintToChat(client, "Votre rack vous a été stocké en {orange}Inventaire banquaire{default}.");
			}	
		}
		else if(IsEntityModelInArray(i, "model_printer"))
		{
			char entName[64];
			Entity_GetName(i, STRING(entName));
			
			char buffer[2][64];
			ExplodeString(entName, "|", buffer, 2, 64);
			
			int client = StringToInt(buffer[0]);
			
			if(IsClientValid(client))
			{
				rp_SetClientItem(client, 106, rp_GetClientItem(client, 106, true) + 1, true);
				SQL_Request(g_DB, "UPDATE `rp_items` SET `106` = '%i' WHERE `playerid` = '%i';", rp_GetClientItem(client, 106, true), rp_GetSQLID(client));
				
				rp_PrintToChat(client, "Votre imprimante vous a été stocké en {orange}Inventaire banquaire{default}.");
			}	
		}
	}
}

void RemovePrinter(int entity)
{
	int owner = printer[entity].owner;
	int type = printer[entity].Number;
	iData[owner].EntityPrinter[type] = -1;
	
	if(printer[entity].TimerPaper != null)
		TrashTimer(printer[entity].TimerPaper);
	
	if(printer[entity].EntityMoney != -1)
	{
		printer[entity].EntityMoney = -1;
		RemoveEntity(printer[entity].EntityMoney);
	}
}

public void RP_OnLookAtTarget(int client, int target, char[] model)
{
	if(!IsValidEntity(target))
		return;
	
	if(IsEntityModelInArray(target, "model_printer"))
	{
		if(printer[target].owner == client)
			PrintHintText(client, "<font color='%s'>Imprimante</font>\nVie: <font color='%s'>%0.1f</font>", HTML_FLUOYELLOW, HTML_CHARTREUSE, rp_GetEntityHealth(target));
		else
			PrintHintText(client, "<font color='%s'>Imprimante</font>\nProps de: <font color='%s'>%N</font>\nVie: <font color='%s'>%0.1f</font>", HTML_FLUOYELLOW, HTML_TURQUOISE, printer[target].owner, HTML_CHARTREUSE, rp_GetEntityHealth(target));
	}	
	else if(IsEntityModelInArray(target, "model_printerpaper"))
	{
		char sEntName[64];
		Entity_GetName(target, STRING(sEntName));
		int owner = Client_FindBySteamId(sEntName);
		if(owner == client)
			PrintHintText(client, "<font color='%s'>Papier</font>\nVie: <font color='%s'>%0.1f</font>", HTML_FLUOYELLOW, HTML_CHARTREUSE, rp_GetEntityHealth(target));
		else
			PrintHintText(client, "<font color='%s'>Papier</font>\nProps de: <font color='%s'>%N</font>\nVie: <font color='%s'>%0.1f</font>", HTML_FLUOYELLOW, HTML_TURQUOISE, owner, HTML_CHARTREUSE, rp_GetEntityHealth(target));
	}
}

int FindMoneyPrinterOrigin(int target)
{
	LoopEntities(i)
	{
		if(!IsValidEntity(i))
			continue;
			
		if(printer[i].EntityMoney == target)
			return printer[i].entity_index;
	}
	
	return -1;
}