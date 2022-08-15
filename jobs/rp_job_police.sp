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

/*
	TODO
	
	1. Finir le système jail
	2. Régler les peines d'enprisonnement
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
#define COLOR_TASER			{15, 15, 255, 225}
#define COLOR_BLEU			{0, 128, 255, 255}
#define JOBID				1

/***************************************************************************************

							G L O B A L  -  V A R S

***************************************************************************************/
Handle 
	timerTase[MAXPLAYERS + 1] =  { null, ... };
GlobalForward 
	g_OnTased;
Database 
	g_DB;
char 
	logFile[PLATFORM_MAX_PATH],
	steamID[MAXPLAYERS + 1][32],
	lastModel[MAXPLAYERS + 1][128];
bool 
	canTase[MAXPLAYERS + 1] = {true, ... },
	canSwitchTeam[MAXPLAYERS + 1] =  { true, ... };
float 
	g_flLastPos[MAXPLAYERS + 1][3];
int 
	laserTaser,
	HaloSprite,
	maxRaisons,
	i_EditProp[MAXPLAYERS + 1];

// Methodmap Constructor
Roleplay m_iClient[MAXPLAYERS + 1];

enum struct JailData {
	bool enabled;
	char name[64];
	int time;
	int time_nopay;
	int price;
}
JailData Struct_JailRaison[MAXRAISONS+1];

/***************************************************************************************

							P L U G I N  -  I N F O

***************************************************************************************/
public Plugin myinfo = 
{
	name = "Roleplay - [JOB] Police", 
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
	
	g_OnTased = new GlobalForward("RP_OnPlayerTase", ET_Event, Param_Cell, Param_Cell, Param_Cell, Param_String, Param_String, Param_String);
	
	/*----------------------------------Commands-------------------------------*/
	RegConsoleCmd("taser", Command_Taser);
	RegConsoleCmd("tazer", Command_Taser);
	RegConsoleCmd("tazeur", Command_Taser);	
	RegConsoleCmd("cop", Cmd_Cops);
	RegConsoleCmd("cops", Cmd_Cops);
	RegConsoleCmd("jail", Cmd_Jail);
	RegConsoleCmd("prison", Cmd_Jail);
	RegConsoleCmd("enjail", Cmd_InJail);
	RegConsoleCmd("injail", Cmd_InJail);
	RegConsoleCmd("jaillist", Cmd_InJail);
	RegConsoleCmd("listjail", Cmd_InJail);
	RegConsoleCmd("police", Command_Garage);
	
	/*-------------------------------------------------------------------------------*/
	
	/*----------------------------------KeyValue-------------------------------*/
	KeyValues kv = new KeyValues("Jail_Raisons");
	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, STRING(sPath), "data/roleplay/jail_raisons.cfg");	
	Kv_CheckIfFileExist(kv, sPath);
	
	// Jump into the first subsection
	if (!kv.GotoFirstSubKey())
	{
		PrintToServer("ERROR FIRST KEY");
		delete kv;
		return;
	}
	
	char id[8];
	do
	{
		if(kv.GetSectionName(STRING(id)))
		{
			maxRaisons++;
			Struct_JailRaison[StringToInt(id)].enabled = vbool(kv.GetNum("enabled"));
			kv.GetString("raison", Struct_JailRaison[StringToInt(id)].name, sizeof(Struct_JailRaison[].name));
			Struct_JailRaison[StringToInt(id)].time = kv.GetNum("temps");
			Struct_JailRaison[StringToInt(id)].time_nopay = kv.GetNum("temps_nopay");
			Struct_JailRaison[StringToInt(id)].price = kv.GetNum("amende");
		}
	} 
	while (kv.GotoNextKey());
	/*-------------------------------------------------------------------------*/
}

public void OnMapStart()
{
	laserTaser = PrecacheModel("sprites/lgtning.vmt"); 
	HaloSprite = PrecacheModel("sprites/muzzleflash4.vmt"); 
}

// Init SQL
public void RP_OnSQLInit(Database db)
{
	g_DB = db;
	char buffer[4096];
	Format(STRING(buffer), 
	"CREATE TABLE IF NOT EXISTS `rp_jails` ( \
	  `Id` int(20) NOT NULL AUTO_INCREMENT, \
	  `steamid` varchar(32) COLLATE utf8_bin NOT NULL, \
	  `playername` varchar(32) COLLATE utf8_bin NOT NULL, \
	  `time` int(100) NOT NULL, \
	  `jailid` int(8) NOT NULL, \
	  `jailby` varchar(32) COLLATE utf8_bin NOT NULL, \
	  `raison` varchar(32) NOT NULL, \
	  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, \
	  PRIMARY KEY (`Id`), \
	  UNIQUE KEY `steamid` (`steamid`) \
	  )ENGINE = InnoDB DEFAULT CHARSET = utf8 COLLATE = utf8_bin;");
	g_DB.Query(SQL_CheckForErrors, buffer);
}

public APLRes AskPluginLoad2(Handle plugin, bool late, char[] error, int err_max)
{
	RegPluginLibrary("rp_job_police");
	CreateNative("rp_GetRaisonName", Native_GetRaisonName);
	
	return APLRes_Success;
}
public int Native_GetRaisonName(Handle plugin, int numParams) 
{
	int id = GetNativeCell(1);
	int maxlen = GetNativeCell(3) + 1;

	SetNativeString(3, Struct_JailRaison[id].name, maxlen);		
	return -1;
}

/***************************************************************************************

									C A L L B A C K

***************************************************************************************/  

public void OnClientPutInServer(int client)
{
	// MethodMap Constructor
	m_iClient[client] = Roleplay(client);
}

public Action Cmd_InJail(int client, int args)
{
	if(client == 0)
	{
		PrintToServer("%T", "Command_NoAcces", LANG_SERVER);
		return Plugin_Handled;
	}	
	else if(rp_GetClientInt(client, i_Job) != 1 && rp_GetClientInt(client, i_Job) != JOBID)
	{
		char translate[64];
		Format(STRING(translate), "%T", "NoAccessCommand", LANG_SERVER);
		rp_PrintToChat(client, "%s", translate);
		return Plugin_Handled;
	}	
	else if(rp_GetClientInt(client, i_Zone) != 1)
	{
		rp_PrintToChat(client, "Vous dêvez être dans le commissariat.");
		rp_SetClientBool(client, b_DisplayHud, false);
		return Plugin_Handled;
	}
	
	char tmp[256];	
	rp_SetClientBool(client, b_DisplayHud, false);	
	Menu menu = new Menu(HandleNothing);
	menu.SetTitle("Liste des joueurs en prison:");
	
	int count;
	LoopClients(i) 
	{
		if(!IsClientValid(i))
			continue;
		
		char strTime[32];
		StringTime(rp_GetClientInt(i, i_JailTime), STRING(strTime));
		
		Format(STRING(tmp), "%N  - %s", i, strTime);
		menu.AddItem("", tmp, ITEMDRAW_DISABLED);
		
		count++;
	}
	
	if(count == 0)
	{
		rp_SetClientBool(client, b_DisplayHud, true);
		rp_PrintToChat(client, "Aucun citoyen en prison trouvé.");
	}	

	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
		
	return Plugin_Handled;
}

public Action Cmd_Cops(int client, int args)
{
	if(client == 0)
	{
		PrintToServer("%T", "Command_NoAcces", LANG_SERVER);
		return Plugin_Handled;
	}	
		
	int job = rp_GetClientInt(client, i_Job);
	int grade = rp_GetClientInt(client, i_Grade);
	
	if(grade >= 4 && rp_GetClientInt(client, i_Zone) != 1)
	{
		rp_PrintToChat(client, "Vous dêvez être dans votre Q.G.");			
		return Plugin_Handled;
	}		
	
	if(job == 1 || job == 7)	
	{
		if(canSwitchTeam[client])
		{
			if(GetClientTeam(client) == CS_TEAM_T)
			{
				GetClientModel(client, lastModel[client], sizeof(lastModel[]));				
				CS_SwitchTeam(client, CS_TEAM_CT);
				rp_PrintToChat(client, "Vous avez mit votre tenue de service.");
				//SetJobSkin(client, false);		
				
				rp_SetClientHealth(client, 500);
				Entity_SetMaxHealth(client, 500);
				rp_SetClientArmor(client, 250);
				rp_SetClientHelmet(client, true);
			}
			else if(GetClientTeam(client) == CS_TEAM_CT)
			{
				Entity_SetModel(client, lastModel[client]);
				CS_SwitchTeam(client, CS_TEAM_T);
				rp_PrintToChat(client, "Vous avez enlevé votre tenue de service.");
				
				rp_SetClientHelmet(client, false);
				rp_SetClientHealth(client, 100);
				Entity_SetMaxHealth(client, 200);
			}
			else if(GetClientTeam(client) == CS_TEAM_SPECTATOR)
			{
				return Plugin_Handled;
			}

			m_iClient[client].SetSkin();
		
			if (job == 1)
			{
				if (grade <= 2)
					CreateTimer(30.0, EnableSwitchTeam, client, TIMER_FLAG_NO_MAPCHANGE);
				else if (grade == 3)
					CreateTimer(40.0, EnableSwitchTeam, client, TIMER_FLAG_NO_MAPCHANGE);
				else if (grade == 4)
					CreateTimer(50.0, EnableSwitchTeam, client, TIMER_FLAG_NO_MAPCHANGE);
				else if (grade == 5)
					CreateTimer(60.0, EnableSwitchTeam, client, TIMER_FLAG_NO_MAPCHANGE);
				else if (grade == 6)
					CreateTimer(120.0, EnableSwitchTeam, client, TIMER_FLAG_NO_MAPCHANGE);
			}
			if (job == 7)
				CreateTimer(30.0, EnableSwitchTeam, client, TIMER_FLAG_NO_MAPCHANGE);
		}
		else
			rp_PrintToChat(client, "Vous devez patienter avant de changer de tenue.");
	}
	else
	{
		rp_PrintToChat(client, "L'uniforme est reservé aux forces de l'ordre.");
		rp_PrintToChat(client, "Vous n'avez pas accès à cette commande.");
	}	
		
	return Plugin_Handled;
}

public Action EnableSwitchTeam(Handle timer, any client)
{
	if(IsClientValid(client))
		canSwitchTeam[client] = true;
		
	return Plugin_Handled;
}	

public Action ResetTaser(Handle timer, any client)
{
	if(IsClientValid(client))
		canTase[client] = true;
		
	return Plugin_Handled;
}

public Action Command_Taser(int client, int args)
{
	if(rp_GetClientInt(client, i_Zone) == 777)
	{
		rp_PrintToChat(client, "Le taser est interdit en zone PVP.");
		return Plugin_Handled;
	}
	
	int aim = GetClientAimTarget(client, false);
	/*if(!IsValidEntity(aim))
	{
		rp_PrintToChat(client, "Vous devez utiliser le taser sur une entité.");
		return;
	}*/
	aim = client;
	
	float time;
	if(rp_GetClientInt(client, i_Grade) <= 3 && Distance(client, aim) <= 1000)
		time = 10.0;
	else if(rp_GetClientInt(client, i_Grade) == 4 && Distance(client, aim) <= 950)
		time = 8.0;
	else if(rp_GetClientInt(client, i_Grade) == 5 && Distance(client, aim) <= 900)
		time = 6.0;
	else 
		return Plugin_Handled;
	
	canTase[client] = false;
	CreateTimer(time, ResetTaser, client);
	
	if(IsValidEntity(aim))
	{
		if(aim <= MaxClients && GetEntityMoveType(aim) != MOVETYPE_NOCLIP)
		{
			if(rp_GetClientInt(client, i_Job) == rp_GetClientInt(aim, i_Job) && rp_GetClientInt(client, i_Grade) > rp_GetClientInt(aim, i_Grade))
			{
				rp_PrintToChat(client, "Vous n'êtes pas autorisé à taser un supérieur.");
				aim = client;
			}
			
			if(!rp_GetClientBool(aim, b_IsTased))
			{
				if(rp_GetClientBool(aim, b_HasLubrifiant))
				{
					int nombre = GetRandomInt(1, 3);
					if(nombre == 1)
					{
						rp_SetClientBool(aim, b_HasLubrifiant, false);
						CPrintToChat(aim, "%s Votre lubrifiant n'as pas fonctionné.");
						Tase(client, aim, time);
					}	
					else
					{
						rp_SetClientBool(aim, b_HasLubrifiant, false);
						CPrintToChat(client, "Vous avez raté votre cible. Réessayez.");
						CPrintToChat(aim, "%s Votre lubrifiant a été consommé");
					}												
				}
				else					
					Tase(client, aim, time);
			}	
			else
				rp_PrintToChat(client, "Cette personne est déjà taser.");				
		}
		else if(aim > MaxClients)
		{
			char entClass[64], entModel[64], entName[64], buffer[2][64];
			Entity_GetClassName(aim, STRING(entClass));
			Entity_GetModel(aim, STRING(entModel));
			Entity_GetName(aim, STRING(entName));
			ExplodeString(entName, "|", buffer, 2, 64);		
			
			if(StrContains(entClass, "weapon_", false) != -1 && Distance(client, aim) <= 180)
			{
				if(StrContains(entName, "police", false) != -1)
					rp_PrintToChat(client, "Vous ne pouvez pas saisir une arme du service de police.");
				else
				{										
					TE_Taser(client, aim);
					rp_SetClientInt(client, i_Money, rp_GetClientInt(client, i_Money) + 10);
					rp_SetJobCapital(1, -10);
					rp_SetClientInt(client, i_Money, rp_GetClientInt(client, i_Money) + 10);
					RemoveEdict(aim);
					rp_PrintToChat(client, "Vous avez saisi une arme.");
					rp_PrintToChat(client, "Le Chef Police vous reverse une prime de 10$ pour cette saisie.");
				}	
			}
			else if(StrContains(entClass, "door") != -1)
			{
				rp_PrintToChat(client, "Vous devez utiliser le taser sur une entité.");
				return Plugin_Handled;
			}
			else if(StrContains(entClass, "vehicle") != -1)
			{
				rp_PrintToChat(client, "Vous devez utiliser le taser sur une entité.");
				return Plugin_Handled;
			}
				
			int reward;
			
			Call_StartForward(g_OnTased);
			Call_PushCell(client);
			Call_PushCell(aim);
			Call_PushCell(reward);
			Call_PushString(entClass);
			Call_PushString(entModel);
			Call_PushString(entName);
			Call_Finish();
			
			rp_SetJobCapital(1, -reward);
			rp_SetClientInt(client, i_Money, rp_GetClientInt(client, i_Money) + reward);		
			TE_Taser(client, aim);			
		}
	}
	
	return Plugin_Handled;
}

void Tase(int client, int target, float time)
{
	if(!IsValidEntity(client) || !IsValidEntity(target))
		return;
	else if(GetEntityMoveType(target) == MOVETYPE_NOCLIP)
		return;
	
	SetEntityRenderColor(target, 0, 128, 255, 192);
	SetEntityMoveType(target, MOVETYPE_NONE);
	
	TE_Taser(client, target);
	//ScreenFade(target, RoundToCeil(time)/2, COLOR_TASER);
	
	if(timerTase[target] != null)
	{
		TrashTimer(timerTase[target], true);
		timerTase[target] = null;
	}
	
	timerTase[target] = CreateTimer(time, UnTase, target);
	rp_SetClientBool(target, b_IsTased, true);
	rp_SetClientBool(target, b_CanUseItem, false);
	
	rp_PrintToChat(client, "Vous avez tasé %N.", target);
	CPrintToChat(target, "%s GZzzt !! Vous avez été tasé par %N.", client);
	LogToGame("[TAZER] %L a tazé %N dans %d.", client, target, rp_GetClientInt(client, i_Zone));
}

void TE_Taser(int client, int target)
{
	if(IsValidEntity(client) && IsValidEntity(target))
	{
		rp_Sound(target, "sound_taser", 0.5);
		rp_Sound(client, "sound_taser", 0.5);
		
		/*TE_SetupBeamLaser(target, client, laserTaser, 0, 0, 0, 0.5, 2.0, 2.0, 3, 0.5, COLOR_BLEU, 0);
		TE_SendToAll(0.1); 
		TE_SetupBeamLaser(client, target, laserTaser, 0, 0, 0, 0.5, 2.0, 2.0, 3, 0.5, COLOR_BLEU, 0);
		TE_SendToAll(0.1);*/

		float fTargetPos[3], fClientPos[3];
		GetEntPropVector(target, Prop_Send, "m_vecOrigin", fTargetPos);
		GetEntPropVector(client, Prop_Send, "m_vecOrigin", fClientPos);
		
		int randomx = GetRandomInt(-500, 500);
		int randomy = GetRandomInt(-500, 500);
		
		float startpos[3];
		startpos[0] = fClientPos[0] + randomx;
		startpos[1] = fClientPos[1] + randomy;
		startpos[2] = fClientPos[2] + 800;

		fClientPos[2] -= 26;
		rp_CreateParticle(fTargetPos, "weapon_taser_sparks", 1.0);
		TE_SetupBeamRingPoint(fClientPos, 10.0, 150.0, laserTaser, HaloSprite, 0, 15, 0.6, 15.0, 0.0, {128, 128, 0, 255}, 10, 0);
		TE_SendToAll();
		
		fClientPos[2] += 45;
		fTargetPos[2] += 45;
		
		TE_SetupEnergySplash(fClientPos, fTargetPos, false);
		TE_SendToAll();
		TE_DispatchEffect("weapon_tracers_taser", fClientPos, fTargetPos);
		
		SetEntityMoveType(target, MOVETYPE_NONE);
	}
}

public Action UnTase(Handle timer, any client)
{
	if(IsClientValid(client))
	{
		timerTase[client] = null;
		SetEntityMoveType(client, MOVETYPE_WALK);
		SetEntityRenderMode(client, RENDER_TRANSCOLOR);
		rp_SetDefaultClientColor(client);
		
		CreateTimer(5.0, Timer_ResetIsTased, client);
	}
	
	return Plugin_Handled;
}

public Action Timer_ResetIsTased(Handle timer, any client)
{
	if(IsClientValid(client))
	{
		rp_SetClientBool(client, b_IsTased, false);
		rp_SetClientBool(client, b_CanUseItem, true);
	}	
	
	return Plugin_Handled;
}

public void RP_OnClientTakeDamage(int client, int attacker, int inflictor, float &damage, int damagetype)
{
	if(rp_GetClientInt(client, i_LastAgression) != 0)
	{
		rp_SetClientInt(attacker, i_LastAgression, client);
		CreateTimer(600.0, ResetData, attacker);
	}
}	

public void RP_OnPlayerDeath(int attacker, int victim, int respawnTime)
{
	if(rp_GetClientInt(victim, i_LastKilled_Reverse) != 0)
	{
		if(attacker != victim)
		{
			rp_SetClientInt(victim, i_LastKilled_Reverse, attacker);
			CreateTimer(600.0, ResetData, victim);
		}	
	}
	
	/*if(rp_GetClientBool(victim, b_AsMandate))
	{
		if(attacker != victim)
		{
			rp_SetJobPerqui(0);
			rp_SetClientBool(victim, b_AsMandate, false);
			
			CPrintToChat(victim, "%s La perquisition est {lightred}annulée{default}, vous avez perdu le mandat.");
			
			LoopClients(i)
			{
				if (i != victim && rp_GetClientInt(i, i_Job) == 1)
				{
					CPrintToChat(i, "%s Perquisition {lightred}annulée{default} ! Le responsable %N est mort.", victim);
					PrintCenterText(i, "Perquisition annulée !!");
				}
				else if (rp_GetClientInt(i, i_Job) == rp_GetJobPerqui())
					CPrintToChat(i, "%s La perquisition de votre planque est terminée.");
			}		
		}	
	}*/	
}	

public void rp_OnClientSpawn(int client)
{
	if(rp_GetClientInt(client, i_Job) == 1)
	{
		if(rp_GetClientInt(client, i_Grade) == 1)
			SetEntityHealth(client, 500);
		else if(rp_GetClientInt(client, i_Grade) == 2)
			SetEntityHealth(client, 450);	
		else if(rp_GetClientInt(client, i_Grade) == 3)
			SetEntityHealth(client, 400);	
		else if(rp_GetClientInt(client, i_Grade) == 4)
			SetEntityHealth(client, 350);
		else if(rp_GetClientInt(client, i_Grade) == 5)
			SetEntityHealth(client, 300);
		else if(rp_GetClientInt(client, i_Grade) == 6)
			SetEntityHealth(client, 250);
		
		rp_SetClientHelmet(client, false);			
		CS_SwitchTeam(client, CS_TEAM_T);
	}	
}	

public Action RP_OnPlayerTakeDamage(int client, int &attacker, int &inflictor, float &damage, int &damagetype)
{	
	if (damage > 0)
	{
		if(IsClientValid(client) && IsClientValid(attacker))
		{
			rp_SetClientInt(attacker, i_LastDangerousShot, client);
			CreateTimer(600.0, ResetData, attacker);
		}	
	}	
	
	return Plugin_Continue;
}

public Action ResetData(Handle timer, any client)
{
	if(rp_GetClientInt(client, i_LastDangerousShot) >= 1)
		rp_SetClientInt(client, i_LastDangerousShot, 0);
	
	if(rp_GetClientInt(client, i_LastKilled_Reverse) >= 1)
		rp_SetClientInt(client, i_LastKilled_Reverse, 0);
		
	if(rp_GetClientInt(client, i_LastAgression) >= 1)
		rp_SetClientInt(client, i_LastAgression, 0);	
		
	if(rp_GetClientInt(client, i_LastVolTime) >= 1)
		rp_SetClientInt(client, i_LastAgression, 0);	

	if(rp_GetClientInt(client, i_LastVolAmount) >= 1)
		rp_SetClientInt(client, i_LastVolAmount, 0);
		
	if(rp_GetClientInt(client, i_LastVolTarget) >= 1)
		rp_SetClientInt(client, i_LastVolTarget, 0);

	return Plugin_Handled;
}

public void RP_OnClientInteract(int client, int target, const char[] class, const char[] model, const char[] name)
{
	if(rp_GetNPCType(target) == JOBID)
	{
		if(Distance(client, target) <= 80.0)
			MenuArmory(client);
		else
			Translation_PrintTooFar(client);
	}
	else if(StrEqual(name, "PROP_POLICE") && rp_GetClientInt(client, i_Job) == 1)
	{
		if(Distance(client, target) <= 128.0)
		{
			i_EditProp[client] = target;
			MenuEdit(client);
		}	
	}
}

void MenuEdit(int client)
{
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_MenuEdit);
	menu.SetTitle("Portland Police Departement");
	
	menu.AddItem("position", "Position");
	menu.AddItem("angles", "Angles");
	menu.AddItem("delete", "Supprimer");
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Handle_MenuEdit(Menu menu, MenuAction action, int client, int param) 
{
	if (action == MenuAction_Select) 
	{
		char info[32], buffer[2][32];
		menu.GetItem(param, STRING(info));
		ExplodeString(info, "|", STRING(buffer), sizeof(buffer[]));
		
		if (StrEqual(info, "position")) 
			Menu_Position(client);
		else if (StrEqual(info, "angles")) 
			Menu_Angles(client);
		else if (StrEqual(info, "delete")) 
		{
			if(IsValidEntity(i_EditProp[client]))
				AcceptEntityInput(i_EditProp[client], "kill");
				
			i_EditProp[client] = -1;
			rp_SetClientBool(client, b_DisplayHud, true);
		}	
	}
	else if (action == MenuAction_Cancel)
	{
		if (param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
	}
	else if (action == MenuAction_End)
		delete menu;
		
	return 0;
}

public void Menu_Position(int client) 
{
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_Position);
	menu.SetTitle("Prop_Police - Position");
	menu.AddItem("up", "Déplacer vers le haut");
	menu.AddItem("down", "Déplacer vers le bas");
	menu.AddItem("xPlus", "Déplacer X+");
	menu.AddItem("xMinus", "Déplacer X-");
	menu.AddItem("yPlus", "Déplacer Y+");
	menu.AddItem("yMinus", "Déplacer Y-");
	//menu.AddItem("ground", "Mettre au sol");
	menu.AddItem("tpYourself", "Téléporter à vous-même");
	menu.ExitButton = true;
	menu.ExitBackButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Handle_Position(Menu menu, MenuAction action, int client, int param) 
{
	if (action == MenuAction_Select) 
	{
		char info[32];
		menu.GetItem(param, STRING(info));
		
		float pos[3];
		char npcUniqueId[128];
		GetEntPropString(i_EditProp[client], Prop_Data, "m_iName", STRING(npcUniqueId));
		
		if (StrEqual(info, "up")) 
		{
			GetEntPropVector(i_EditProp[client], Prop_Data, "m_vecOrigin", pos);
			pos[2] += 10;
			TeleportEntity(i_EditProp[client], pos, NULL_VECTOR, NULL_VECTOR);
			Menu_Position(client);
		} 
		else if (StrEqual(info, "down")) 
		{
			GetEntPropVector(i_EditProp[client], Prop_Data, "m_vecOrigin", pos);
			pos[2] -= 10;
			TeleportEntity(i_EditProp[client], pos, NULL_VECTOR, NULL_VECTOR);
			Menu_Position(client);
		} 
		else if (StrEqual(info, "ground")) 
		{
			GetEntPropVector(i_EditProp[client], Prop_Data, "m_vecOrigin", pos);
			//pos[2] -= GetClientDistanceToGround(client);
			TeleportEntity(i_EditProp[client], pos, NULL_VECTOR, NULL_VECTOR);
			Menu_Position(client);
		} 
		else if (StrEqual(info, "tpYourself")) 
		{
			float selfPos[3];
			GetClientAbsOrigin(client, selfPos);
			TeleportEntity(i_EditProp[client], selfPos, NULL_VECTOR, NULL_VECTOR);
			Menu_Position(client);
		} 
		else if (StrEqual(info, "xPlus")) 
		{
			GetEntPropVector(i_EditProp[client], Prop_Data, "m_vecOrigin", pos);
			pos[0] += 10;
			TeleportEntity(i_EditProp[client], pos, NULL_VECTOR, NULL_VECTOR);
			Menu_Position(client);
		} 
		else if (StrEqual(info, "xMinus")) 
		{
			GetEntPropVector(i_EditProp[client], Prop_Data, "m_vecOrigin", pos);
			pos[0] -= 10;
			TeleportEntity(i_EditProp[client], pos, NULL_VECTOR, NULL_VECTOR);
			Menu_Position(client);
		} 
		else if (StrEqual(info, "yPlus")) 
		{
			GetEntPropVector(i_EditProp[client], Prop_Data, "m_vecOrigin", pos);
			pos[1] += 10;
			TeleportEntity(i_EditProp[client], pos, NULL_VECTOR, NULL_VECTOR);
			Menu_Position(client);
		} 
		else if (StrEqual(info, "yMinus")) 
		{
			GetEntPropVector(i_EditProp[client], Prop_Data, "m_vecOrigin", pos);
			pos[1] -= 10;
			TeleportEntity(i_EditProp[client], pos, NULL_VECTOR, NULL_VECTOR);
			Menu_Position(client);
		}
	}
	else if (action == MenuAction_Cancel)
	{
		if (param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if(param == MenuCancel_ExitBack)
			MenuEdit(client);
	}
	else if (action == MenuAction_End)
		delete menu;
		
	return 0;
}

public void Menu_Angles(int client) 
{
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_Angles);
	menu.SetTitle("Prop_Police - Rotation");
	menu.AddItem("yourself", "Votre angle actuelle");
	menu.AddItem("yourselfInverted", "Votre angle actuelle inversée");
	menu.AddItem("minus", "Ajouter un angle");
	menu.AddItem("plus", "Retirer un angle");
	menu.ExitButton = true;
	menu.ExitBackButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Handle_Angles(Menu menu, MenuAction action, int client, int param) 
{
	if (action == MenuAction_Select) 
	{
		char info[32];
		menu.GetItem(param, STRING(info));
		
		float angles[3];
		char npcUniqueId[128];
		if (i_EditProp[client] == -1)
			return -1;
		GetEntPropString(i_EditProp[client], Prop_Data, "m_iName", STRING(npcUniqueId));
		
		if (StrEqual(info, "plus")) 
		{
			GetEntPropVector(i_EditProp[client], Prop_Data, "m_angRotation", angles);
			angles[1] += 5;
			TeleportEntity(i_EditProp[client], NULL_VECTOR, angles, NULL_VECTOR);
			Menu_Angles(client);
		} 
		else if (StrEqual(info, "minus")) 
		{
			GetEntPropVector(i_EditProp[client], Prop_Data, "m_angRotation", angles);
			angles[1] -= 5;
			TeleportEntity(i_EditProp[client], NULL_VECTOR, angles, NULL_VECTOR);
			Menu_Angles(client);
		} 
		else if (StrEqual(info, "yourself")) 
		{
			float selfAngles[3];
			GetClientAbsAngles(client, selfAngles);
			TeleportEntity(i_EditProp[client], NULL_VECTOR, selfAngles, NULL_VECTOR);
			Menu_Angles(client);
		} 
		else if (StrEqual(info, "yourselfInverted")) 
		{
			float selfAngles[3];
			GetClientAbsAngles(client, selfAngles);
			selfAngles[1] = 180 - selfAngles[1];
			TeleportEntity(i_EditProp[client], NULL_VECTOR, selfAngles, NULL_VECTOR);
			Menu_Angles(client);
		}
	}
	else if (action == MenuAction_Cancel)
	{
		if (param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if(param == MenuCancel_ExitBack)
			MenuEdit(client);
	}
	else if (action == MenuAction_End)
		delete menu;
		
	return 0;
}

public void RP_OnPlayerInteract(int client, int target, const char[] class, const char[] model, const char[] name)
{
	/*if (StrEqual(model, "models/props_interiors/paper_tray.mdl") && rp_GetClientInt(client, i_Job) == 1 || rp_GetClientInt(client, i_Job) == JOBID)
	{
		if (rp_GetClientInt(client, i_Grade) <= 5)
		{
			char buff3[3][64], jobName[32];
			ExplodeString(name, "|", buff3, 3, 64);
			// buff3[0] : mandat
			int jobPerqui = StringToInt(buff3[1]);
			// buff3[2] : steamid
			
			rp_GetJobName(jobPerqui, STRING(jobName));
			
			if (!StrEqual(steamID[client], buff3[2]))
			{
				int joueur = Client_FindBySteamId(buff3[2]);
				rp_PrintToChat(client, "Vous avez ramassé le {yellow}mandat de perquisition{default} %s, demandé par %N.", jobName, joueur);
			}
			else
				rp_PrintToChat(client, "Vous avez ramassé le {yellow}mandat de perquisition{default} %s.", jobName);
			
			PrintHintText(client, "Vous avez le mandat de perquisition pour %s.", jobName);
			
			rp_SetClientBool(client, b_AsMandate, true);
			rp_SetPerquisitionStat(jobPerqui, false);
			rp_SetJobPerqui(jobPerqui);
			
			CreateTimer(2160.0, ResetPerquisition, jobPerqui, TIMER_FLAG_NO_MAPCHANGE);
			rp_SetPerquisitionTime(180);			
			RemoveEdict(target);
			CreateTimer(0.08, DoGlowMandat, client);
		}
		else rp_PrintToChat(client, "Vous n'êtes pas autorisé à prendre un mandat de perquisition.");
	}	*/
}	

void MenuArmory(int client)
{
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_MenuArmory);
	if(rp_GetClientInt(client, i_Job) == 1)
	{
		menu.SetTitle("Armurerie de Portland :");
		
		menu.AddItem("1|weapon_usp_silencer", "USP-S");
		menu.AddItem("0|weapon_mp5sd", "MP5");
		
		if(rp_GetClientInt(client, i_Grade) <= 5)
		{
			menu.AddItem("0|weapon_mp9", "MP9");
			menu.AddItem("0|weapon_nova", "Nova");
			menu.AddItem("1|weapon_fiveseven", "Fiveseven");
		}
		if(rp_GetClientInt(client, i_Grade) <= 4)
		{
			menu.AddItem("1|weapon_deagle", "Desert Eagle");
			menu.AddItem("0|weapon_m4a1_silencer", "M4A1");
			menu.AddItem("0|weapon_m4a1", "M4A4");
		}
		if(rp_GetClientInt(client, i_Grade) <= 3)
		{
			menu.AddItem("6|weapon_shield", "Bouclier");
			menu.AddItem("0|weapon_ssg08", "SSG08");
		}
		if(rp_GetClientInt(client, i_Grade) <= 2)
		{
			menu.AddItem("0|weapon_awp", "AWP");
			menu.AddItem("0|weapon_negev", "Negev");
		}
		menu.ExitButton = true;
		menu.Display(client, MENU_TIME_FOREVER);
	}
	else
	{
		char translate[64];
		Format(STRING(translate), "%T", "NoAccessCommand", LANG_SERVER);
		rp_PrintToChat(client, "%s", translate);
	}	
}

public int Handle_MenuArmory(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[64];
		menu.GetItem(param, STRING(info));
		
		char buffer[2][64];
		ExplodeString(info, "|", buffer, 2, 64);
		int slot = StringToInt(buffer[0]);
		if(slot != 7)
		{
			if(GetPlayerWeaponSlot(client, slot) == -1)
			{
				char strFormat[64];
				Format(STRING(strFormat), "POLICE");
				int weapon = GivePlayerItem(client, buffer[1]);
				SetEntPropEnt(client, Prop_Data, "m_hActiveWeapon", weapon);
				ChangeEdictState(client, FindDataMapInfo(client, "m_hActiveWeapon"));
				Entity_SetName(weapon, strFormat);
			}
			else if(slot == 1)
				rp_PrintToChat(client, "Vous possédez déjà une arme de poing.");
			else if(slot == 6)
				rp_PrintToChat(client, "Vous possédez déjà un bouclier.");	
			else
				rp_PrintToChat(client, "Vous possédez déjà une arme lourde.");
			rp_SetClientBool(client, b_DisplayHud, true);	
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

public Action Cmd_Jail(int client, int args) 
{
	#if DEBUG
		PrintToServer("Command: jail");
	#endif
	
	int target = GetClientAimTarget(client);
	if(rp_GetClientInt(client, i_Job) != 1 && rp_GetClientInt(client, i_Job) != JOBID)
	{
		rp_PrintToChat(client, "%t", "NoAccessCommand", LANG_SERVER);
		return Plugin_Handled;
	}
	else if(!IsClientValid(target))
	{
		rp_PrintToChat(client, "%t", "InvalidTarget", LANG_SERVER);
		return Plugin_Handled;
	}
	else if(Distance(client, target) > 350)
	{
		rp_PrintToChat(client, "%t", "InvalidDistance", LANG_SERVER);
		return Plugin_Handled;	
	}
	
	char strIndex[128], strMenu[64];
				
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_ChoiseJail);
	menu.SetTitle("Jails");
	
	if(rp_GetClientInt(target, i_JailTime) > 0)
	{
		Format(STRING(strIndex), "-1|%d", target);
		menu.AddItem(strIndex, "Annuler la peine / Liberer");
	}	
	
	float abs[3];
	GetClientAbsAngles(target, abs);
	
	g_flLastPos[target] = abs;
	
	KeyValues kv = new KeyValues("Jails");
	char sPath[PLATFORM_MAX_PATH], map[64];
	rp_GetCurrentMap(STRING(map));
	BuildPath(Path_SM, STRING(sPath), "data/roleplay/%s/jails.cfg", map);	
	Kv_CheckIfFileExist(kv, sPath);
	
	if(rp_GetClientInt(client, i_Job) == 1)
	{	
		char tmp[8];
		IntToString(rp_GetClientInt(client, i_Job), STRING(tmp));
		
		if(kv.JumpToKey(tmp))
		{
			int max_jails = kv.GetNum("max");

			for(int i = 1; i <= max_jails; i++)
			{
				IntToString(i, STRING(tmp));
				
				float pos[3];
				kv.GetVector(tmp, pos);
				
				Format(STRING(strIndex), "%i|%i|%f|%f|%f", i, target, pos[0], pos[1], pos[2]);
				Format(STRING(strMenu), "Cellule №%i", i);
				
				bool empty = false;
				
				if(pos[0] == 0.0 || pos[1] == 0.0 || pos[2] == 0.0)
					empty = true;
				
				menu.AddItem(strIndex, strMenu, (empty == false) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
			}
			
			kv.GoBack();
		}			
	}
	else
	{
		char tmp[8];
		if(kv.JumpToKey("7"))
		{
			int max_jails = kv.GetNum("max");

			for(int i = 1; i <= max_jails; i++)
			{
				IntToString(i, STRING(tmp));
				
				float pos[3];
				kv.GetVector(tmp, pos);
				
				Format(STRING(strIndex), "%i|%i|%f|%f|%f", i, target, pos[0], pos[1], pos[2]);
				Format(STRING(strMenu), "Cellule №%i", i);
				
				bool empty = false;
				
				if(pos[0] == 0.0 || pos[1] == 0.0 || pos[2] == 0.0)
					empty = true;
				
				menu.AddItem(strIndex, strMenu, (empty == false) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
			}
			
			kv.GoBack();
		}
	}
	
	kv.Rewind();	
	delete kv;
	
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
	StripWeapons(target);


	return Plugin_Handled;
}

public int Handle_ChoiseJail(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[64], buffer[5][128];
		menu.GetItem(param, STRING(info));
		ExplodeString(info, "|", buffer, 5, 128);
		
		int type = StringToInt(buffer[0]);
		int target = StringToInt(buffer[1]);	
		
		if(type == -1)
		{
			rp_SetClientInt(target, i_JailTime, 0);
			m_iClient[target].SetSkin();
			SQL_Request(g_DB, "DELETE FROM `rp_jails` WHERE `steamid` = '%s'", steamID[target]);

			rp_PrintToChat(client, "Vous avez libéré %N{default}.", target);
			CPrintToChat(target, "%s %N {default}vous a libéré.", client);
			LogToFile(logFile, "%N a libéré %N.", client, target);
		}
		else
		{
			float pos[3];
			pos[0] = StringToFloat(buffer[2]);
			pos[1] = StringToFloat(buffer[3]);
			pos[2] = StringToFloat(buffer[4]);
			
			rp_ClientTeleport(target, pos);
		}

		MenuPeine(client, target, type);
		
		CPrintToChat(target, "%s Vous avez été mis en prison, en attente de jugement par: %N", client);
		rp_PrintToChat(client, "Vous avez mis: %N {default}en prison.", target);
	}
	else if(action == MenuAction_Cancel)
	{
		rp_SetClientBool(client, b_DisplayHud, true);
		delete menu;
	}
	else if(action == MenuAction_End)
	{
		rp_SetClientBool(client, b_DisplayHud, true);
		delete menu;
	}
	
	return 0;
}	

void StripWeapons(int client) {
	
	int wepIdx;	
	for (int i = 0; i < 5; i++) 
	{
		if (i == CS_SLOT_KNIFE)
			continue;
		
		while ((wepIdx = GetPlayerWeaponSlot(client, i)) != -1) 
		{		
			//if (canWeaponBeAddedInPoliceStore(wepIdx))
				//rp_WeaponMenu_Add(g_hBuyMenu, wepIdx, GetEntProp(wepIdx, Prop_Send, "m_OriginalOwnerXuidHigh"));
			
			RemovePlayerItem(client, wepIdx);
			RemoveEdict(wepIdx);
		}
	}
	
	FakeClientCommand(client, "use weapon_knife");
}

void MenuPeine(int client, int target, int jailid)
{
	rp_SetClientBool(client, b_DisplayHud, false);
	
	Menu menu = new Menu(Handle_SetJailTime);
	menu.SetTitle("Quelle peine occasionnera %N?\n ", target);
	
	char strMenu[128], strIndex[256];
	Format(STRING(strIndex), "n/a|%i", target);
	menu.AddItem(strIndex, "Annuler la peine / Liberer");
			
	for(int i = 1; i <= maxRaisons; i++)
	{
		char time[64], price[8];
		if(Struct_JailRaison[i].time > 1)
			StringTime(Struct_JailRaison[i].time, STRING(time));
		else
			Format(STRING(time), "N/A");	
	
		if(Struct_JailRaison[i].price < 1)
			Format(STRING(price), "N/A");
		else
			Format(STRING(price), "%i", Struct_JailRaison[i].price);
		
		Format(STRING(strIndex), "%s|%i|%s|%s|%i|%i", Struct_JailRaison[i].name, target, time, price, i, jailid);
		Format(STRING(strMenu), "%s (%s) (%s$)", Struct_JailRaison[i].name, time, price);
		menu.AddItem(strIndex, strMenu);
	}	
 
	menu.ExitButton = true;	
	menu.Display(client, MENU_TIME_FOREVER);
}	

public int Handle_SetJailTime(Menu menu, MenuAction action, int client, int param) 
{
	if (action == MenuAction_Select) 
	{	
		char info[128], buffer[6][64];
		menu.GetItem(param, STRING(info));
		ExplodeString(info, "|", STRING(buffer), sizeof(buffer[]));
		//buffer[0] = raison
		//buffer[1] = target
		//buffer[2] = time
		//buffer[3] = price
		//buffer[4] = raison ID
		//buffer[5] = jail ID
		int jobID = rp_GetClientInt(client, i_Job);
		int target = StringToInt(buffer[1]);
		int RaisonId;
		int amende;
		int time_to_spend;
		int JailID;
		if(strlen(buffer[2]) != 0)
			time_to_spend = StringToInt(buffer[2]);
		if(strlen(buffer[3]) != 0)
			amende = StringToInt(buffer[3]);
		if(strlen(buffer[4]) != 0)
			RaisonId = StringToInt(buffer[4]);
		if(strlen(buffer[5]) != 0)
			JailID = StringToInt(buffer[5]);	

		if (StrEqual(buffer[0], "n/a")) 
		{
			rp_SetClientInt(target, i_JailTime, 0);
			SQL_Request(g_DB, "DELETE FROM `rp_jails` WHERE `steamid` = '%s'", steamID[target]);
			rp_PrintToChat(client, "Vous avez libéré %N{default}.", target);
			CPrintToChat(target, "%s %N {default}vous a libéré.", client);	
			LogToFile(logFile, "%N a libéré %N.", client, target);
			m_iClient[target].SetSkin();
		}
		else if (RaisonId == 3)// Agression physique
		{
			if (rp_GetClientInt(target, i_LastAgression) + 30 < GetTime()) 
			{
				rp_SetClientInt(target, i_JailTime, 0);
				SQL_Request(g_DB, "DELETE FROM `rp_jails` WHERE `steamid` = '%s'", steamID[target]);
				m_iClient[target].SetSkin();
				
				rp_PrintToChat(client, "{yellow}%N{default} a été libéré car il n'a pas commis d'agression.", target);
				CPrintToChat(target, "%s Vous avez été libéré car vous n'avez pas commis d'agression.");
				
				LogToGame("[JAIL] %L a été libéré car il n'avait pas commis d'agression", target);
				
				rp_ClientTeleport(target, g_flLastPos[target]);
			}
		}
		else if (RaisonId == 10)// Tir dans la rue
		{
			if (rp_GetClientInt(target, i_LastDangerousShot) + 30 < GetTime())
			{
				rp_SetClientInt(target, i_JailTime, 0);
				SQL_Request(g_DB, "DELETE FROM `rp_jails` WHERE `steamid` = '%s'", steamID[target]);
				m_iClient[target].SetSkin();
				
				rp_PrintToChat(client, "%N{default} a été libéré car il n'a pas effectué de tir dangereux.", target);
				CPrintToChat(target, "%s Vous avez été libéré car vous n'avez pas effectué de tir dangereux.", client);
				
				LogToGame("[JAIL] %L a été libéré car il n'avait pas effectué de tir dangereux", target);
				
				rp_ClientTeleport(target, g_flLastPos[target]);
			}
		}	
		else if (RaisonId == 5)// Vol, tentative de vol
		{
			if (rp_GetClientInt(target, i_LastVolTime) + 30 < GetTime()) 
			{
				rp_SetClientInt(target, i_JailTime, 0);
				SQL_Request(g_DB, "DELETE FROM `rp_jails` WHERE `steamid` = '%s'", steamID[target]);
				m_iClient[target].SetSkin();
				
				rp_PrintToChat(client, "%N{default} a été libéré car il n'a pas commis de vol.", target);
				CPrintToChat(target, "%s Vous avez été libéré car vous n'avez pas commis de vol.", client);
				
				LogToGame("[JAIL] %L a été libéré car il n'avait pas commis de vol", target);
				
				rp_ClientTeleport(target, g_flLastPos[target]);
			}
			if (IsClientValid(rp_GetClientInt(target, i_LastVolTarget))) 
			{
				int tg = rp_GetClientInt(target, i_LastVolTarget);
				rp_SetClientInt(tg, i_Money, rp_GetClientInt(tg, i_Money) + rp_GetClientInt(target, i_LastVolAmount));
				rp_SetClientInt(target, i_Money, rp_GetClientInt(target, i_Money) - rp_GetClientInt(target, i_LastVolAmount));
				
				CPrintToChat(target, "%s Vous avez remboursé votre victime de %d$.", rp_GetClientInt(target, i_LastVolAmount));
				CPrintToChat(tg, "%s Le voleur a été mis en prison. Vous avez été remboursé de %d$.", rp_GetClientInt(target, i_LastVolAmount));
			}
			else 
			{
				amende += rp_GetClientInt(target, i_LastVolAmount); // Cas tentative de vol ou distrib...
			}
			
			CancelClientMenu(target, true);
		}		
		
	/*	if (amende == -1) 
		{
			amende = rp_GetClientInt(target, i_KillJailDuration) * 50;
			
			if (amende == 0 && rp_GetClientInt(target, i_LastAgression) + 30 > GetTime())
				amende = StringToInt(g_szJailRaison[3][jail_amende]);
		}*/

		if (rp_GetClientInt(target, i_Money) >= amende || ((rp_GetClientInt(target, i_Money) + rp_GetClientInt(target, i_Bank)) >= amende * 250 && amende <= 2500)) 
		{			
			rp_SetClientInt(target, i_Money, rp_GetClientInt(target, i_Money) -amende);
			rp_SetJobCapital(jobID, rp_GetJobCapital(jobID) + (amende / 2));
			
			GetClientAuthId(client, AuthId_Engine, STRING(info), false);
			
			if (time_to_spend == -1) 
			{
				time_to_spend = rp_GetClientInt(target, i_KillJailDuration);
				/*if (time_to_spend == 0 && rp_GetClientInt(target, i_LastAgression) + 30 > GetTime())
					time_to_spend = StringToInt(g_szJailRaison[3][jail_temps]);*/
				
				LoopClients(i)
				{
					if (!IsClientValid(i))
						continue;
					if (rp_GetClientInt(i, i_LastKilled_Reverse) != target)
						continue;
					CPrintToChat(i, "%s Votre assassin a été mis en prison.");
				}
				time_to_spend /= 2;
			}
			
			
			if (amende > 0) 
			{				
				if (IsClientValid(target)) 
				{
					rp_PrintToChat(client, "Une amende de %i$ a été prélevée à %N{default}.", amende, target);
					CPrintToChat(target, "%s Une caution de %i$ vous a été prelevée.", amende);
				}
			}
		}
		else
		{
			//time_to_spend = StringToInt(g_szJailRaison[type][jail_temps_nopay]);
			if (time_to_spend == -1) 
			{
				time_to_spend = rp_GetClientInt(target, i_KillJailDuration);
				/*if (time_to_spend == 0 && rp_GetClientInt(target, i_LastAgression) + 30 > GetTime())
					time_to_spend = StringToInt(g_szJailRaison[3][jail_temps_nopay]);*/
				
				LoopClients(i)
				{
					if (!IsClientValid(i))
						continue;
					if (rp_GetClientInt(i, i_LastKilled_Reverse) != target)
						continue;
					CPrintToChat(i, "%s Votre assassin a été mis en prison.");
				}
			}
			else if (rp_GetClientInt(target, i_Bank) >= amende && time_to_spend != -2) 
				WantPayForLeaving(target, client, RaisonId, amende);
		}
		
		if (time_to_spend < 0) 
		{
			int d = 6;
			
			if (rp_GetClientInt(target, i_Zone) == 1)
				d = 1;
			
			time_to_spend = rp_GetClientInt(target, i_JailTime) + (d * 60);
		}
		else 
			time_to_spend *= 60;
		
		if(time_to_spend != 0)
			rp_SetClientInt(target, i_JailTime, time_to_spend);
		else
		{	
			rp_SetClientInt(target, i_JailTime, 0);
			SQL_Request(g_DB, "DELETE FROM `rp_jails` WHERE `steamid` = '%s'", steamID[target]);
			m_iClient[target].SetSkin();
		}	

		char targetname[MAX_NAME_LENGTH + 8];
		GetClientName(target, STRING(targetname));
		
		char clientname[MAX_NAME_LENGTH + 8];
		GetClientName(client, STRING(clientname));
		
		SQL_Request(g_DB, "INSERT IGNORE INTO `rp_jails` (`Id`, `steamid`, `playername`, `jailid`, `time`, `jailby`, `raison`) VALUES (NULL, '%s', '%s', '%i', '%i', '%s', '%i');", steamID[target], targetname, JailID, rp_GetClientInt(client, i_JailTime), clientname, RaisonId);
		
		int iYear, iMonth, iDay, iHour, iMinute, iSecond;
		UnixToTime(GetTime() + time_to_spend, iYear, iMonth, iDay, iHour, iMinute, iSecond, UT_TIMEZONE_CEST);
		if (IsClientValid(client) && IsClientValid(target)) 
		{
			rp_PrintToChat(client, "%N {default}restera en prison {lightgreen}%02d:%02d:%02d {default}pour \"%s\"", target, iHour, iMinute, iSecond, buffer[0]);
			CPrintToChat(target, "%s %N {default}vous a mis {lightgreen}%02d:%02d:%02d {default}de prison pour \"%s\"", client, iHour, iMinute, iSecond, buffer[0]);
			
			ScreenOverlay(target, "overlay_jail", 5.0);
			char tmp[128];
			Format(STRING(tmp), "Vous êtes en prison (%s)", buffer[0]);
			m_iClient[target].SetSkin();
		}
		else 
			rp_PrintToChat(client, "Le joueur s'est déconnecté mais il fera {lightgreen}%02d:%02d:%02d {default}prison", iHour, iMinute, iSecond);
		
		StripWeapons(target);
	}
	else if (action == MenuAction_End) {
		delete menu;
	}
	
	return 0;
}

void WantPayForLeaving(int client, int police, int type, int amende) 
{	
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_PayForLeaving);
	char tmp[256];
	
	menu.SetTitle("Vous avez été mis en prison pour \n %s\nUne caution de %i$ vous est demandé\n ", Struct_JailRaison[type].name, Struct_JailRaison[type].price);
	
	Format(STRING(tmp), "%i|%i|%i", police, type, amende);
	menu.AddItem(tmp, "Oui, je souhaite payer ma caution");
	
	Format(STRING(tmp), "0|0|0");
	menu.AddItem(tmp, "Non, je veux rester plus longtemps");
	
	menu.ExitButton = true;	
	menu.Display(client, MENU_TIME_FOREVER);
}
public int Handle_PayForLeaving(Menu menu, MenuAction action, int client, int param) 
{
	if (action == MenuAction_Select) 
	{
		char info[64], buffer[3][32];
		menu.GetItem(param, STRING(info));
		ExplodeString(info, "|", buffer, 2, 32);
		
		int target = StringToInt(buffer[0]);
		int type = StringToInt(buffer[1]);
		int amende = StringToInt(buffer[2]);
		int jobID = rp_GetClientInt(target, i_Job);
		
		if (target == 0 && type == 0 && amende == 0)
			return -1;
		
		if(rp_GetClientInt(client, i_Money) >= amende)
		{		
			int time_to_spend = 0;
			rp_SetClientInt(client, i_Money, -amende);
			rp_SetClientInt(target, i_Money, (amende / 4));
			rp_SetJobCapital(jobID, rp_GetJobCapital(jobID) + (amende / 4 * 3));
				
			time_to_spend = Struct_JailRaison[type].time;
			if (time_to_spend == -1) {
				time_to_spend = rp_GetClientInt(target, i_KillJailDuration);
				
				time_to_spend /= 2;
			}
			
			rp_ClientTeleport(client, g_flLastPos[client]);
			
			if (IsClientValid(target)) {
				CPrintToChat(target, "%s Une amende de %i$ a été prélevée à %N.", amende, client);
				rp_PrintToChat(client, "Une caution de %i$ vous a été prelevée.", amende);
			}
			
			time_to_spend *= 60;
			rp_SetClientInt(client, i_JailTime, time_to_spend);
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

public void RP_OnClientJob(Menu menu, int client)
{
	if (rp_GetClientInt(client, i_Job) == 1)
	{
		menu.AddItem("infoprison", "Information des détenus");
		menu.AddItem("avisrecherche", "Avis de recherche");
		if (rp_GetClientInt(client, i_Grade) <= 5)
			menu.AddItem("perqui", "Mandat de perquisition");
		/*if (rp_GetClientBool(client, b_AsMandate))
			menu.AddItem("finperqui", "Terminer la pequisition");*/
		if (rp_GetClientInt(client, i_Grade) <= 3)
			menu.AddItem("enquete", "Ouvrir un dossier");
		if (rp_GetClientInt(client, i_Grade) <= 2)
			menu.AddItem("police", "Gérer la police");
	}
}	

public void RP_OnClientJobHandle(int client, const char[] info)
{
	if (StrEqual(info, "police"))
		MenuParamPolice(client);
	else if (StrEqual(info, "enquete"))
		MenuEnquete(client);
	else if (StrEqual(info, "avisrecherche"))
		MenuAvisRecherche(client);
	else if (StrEqual(info, "infoprison"))
		ClientCommand(client, "injail");
	/*else if (StrEqual(info, "perqui"))
		MenuPerquisition(client);
	else if (StrEqual(info, "finperqui"))
	{
		rp_SetJobPerqui(0);
		rp_SetClientBool(client, b_AsMandate, false);
		rp_PrintToChat(client, "La perquisition est \x06terminée\x01.");
		LoopClients(i)
		{
			if (i != client && rp_GetClientInt(i, i_Job) == 1)
			{
				CPrintToChat(i, "%s Perquisition \x06terminée\x01 !");
				PrintCenterText(i, "Perquisition terminée !!");
			}
			else if (rp_GetClientInt(i, i_Job) == rp_GetJobPerqui())
				CPrintToChat(i, "%s La perquisition de votre planque est terminée.");
		}
	}	*/
}	

void MenuParamPolice(int client)
{
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_MenuParamPolice);
	menu.SetTitle("Gérer les peines :");
	
	char strMenu[128], strIndex[256];
	for(int i = 1; i <= maxRaisons; i++)
	{
		char time[64], price[8];
		if(Struct_JailRaison[i].time > 1)
			StringTime(Struct_JailRaison[i].time, STRING(time));
		else
			Format(STRING(time), "N/A");	
	
		if(Struct_JailRaison[i].price < 1)
			Format(STRING(price), "N/A");
		else
			Format(STRING(price), "%i", Struct_JailRaison[i].price);
			
		Format(STRING(strIndex), "%i", i);
		Format(STRING(strMenu), "%s (%s) (%s$)", Struct_JailRaison[i].name, time, price);
		menu.AddItem(strIndex, strMenu);	
	}		
	
	menu.ExitBackButton = true;
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Handle_MenuParamPolice(Menu menu, MenuAction action, int client, int param)
{
	if (action == MenuAction_Select)
	{
		char info[8], strMenu[64];
		menu.GetItem(param, STRING(info));
		
		KeyValues kv = new KeyValues("Jail_Raisons");
		char sPath[PLATFORM_MAX_PATH];
		BuildPath(Path_SM, STRING(sPath), "data/roleplay/jail_raisons.cfg");	
		Kv_CheckIfFileExist(kv, sPath);
		
		if(!kv.JumpToKey(info))
		{
			PrintToServer("[KV] %s: ID %i not found !", sPath, info);
		}	
		
		bool enabled = vbool(kv.GetNum("enabled"));
		char raison[64];
		kv.GetString("raison", STRING(raison));
		
		char time[64];
		kv.GetString("temps", STRING(time));
		
		char price[64];
		kv.GetString("amende", STRING(price));
		
		rp_SetClientBool(client, b_DisplayHud, false);
		
		Menu menu1 = new Menu(Handle_MenuSelectParamPolice);
		menu1.SetTitle("%s [%s] :", raison, (vbool(kv.GetNum("enabled")) == true) ? "ON" : "OFF");
		
		if (!enabled)
		{
			Format(STRING(strMenu), "%s|on", info);
			menu1.AddItem(strMenu, "Activer la peine");
		}
		else
		{
			Format(STRING(strMenu), "%s|off", info);
			menu1.AddItem(strMenu, "Désactiver la peine");
		}
		
		Format(STRING(strMenu), "%s|changeramende", info);
		menu1.AddItem(strMenu, "Changer le montant de l'amende");
		
		Format(STRING(strMenu), "%s|changertemps", info);
		menu1.AddItem(strMenu, "Changer le temps de détention");
		
		menu1.ExitButton = true;
		menu1.Display(client, MENU_TIME_FOREVER);
		
		kv.Rewind();	
		delete kv;
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

public int Handle_MenuSelectParamPolice(Menu menu1, MenuAction action, int client, int param)
{
	if (action == MenuAction_Select)
	{
		char info[32], buffer[2][32];
		menu1.GetItem(param, STRING(info));
		ExplodeString(info, "|", STRING(buffer), sizeof(buffer[]));
		// buffer[0] : ID
		// buffer[1] : choix
		
		KeyValues kv = new KeyValues("Jail_Raisons");
		char sPath[PLATFORM_MAX_PATH];
		BuildPath(Path_SM, STRING(sPath), "data/roleplay/jail_raisons.cfg");	
		Kv_CheckIfFileExist(kv, sPath);
		
		if(!kv.JumpToKey(buffer[0]))
		{
			PrintToServer("[KV] %s: ID %i not found !", sPath, buffer[0]);
			MenuParamPolice(client);
		}	
		
		char raison[64];
		kv.GetString("raison", STRING(raison));
		
		if (StrEqual(buffer[1], "on"))
		{
			kv.SetNum("enabled", 1);
			
			PrintHintText(client, "Peine <font color='#4FFF00'>%s</font> activé.", raison);
			rp_PrintToChat(client, "Peine {lightgreen}%s {default}activé.", raison);
			
			char message[128];
			Format(STRING(message), "%N a activé la peine %s.", client, raison);
			rp_LogToDiscord(message);
			
			MenuParamPolice(client);
		}
		else if (StrEqual(buffer[1], "off"))
		{
			kv.SetNum("enabled", 0);
			
			PrintHintText(client, "Peine <font color='#FF0000'>%s</font> désactivé.", raison);
			rp_PrintToChat(client, "Peine {lightred}%s {default}désactivé.", raison);
			
			char message[128];
			Format(STRING(message), "%N a désactivé la peine %s.", client, raison);
			rp_LogToDiscord(message);
			
			MenuParamPolice(client);
		}
		else if (StrEqual(buffer[1], "changeramende"))
			MenuModifierParamPolice(client, true, buffer[0]);
		else if (StrEqual(buffer[1], "changertemps"))
			MenuModifierParamPolice(client, false, buffer[0]);
			
		kv.Rewind();
		kv.ExportToFile(sPath);
		delete kv;
	}
	else if (action == MenuAction_Cancel)
	{
		if (param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if (param == MenuCancel_ExitBack)
			MenuParamPolice(client);
	}
	else if (action == MenuAction_End)
		delete menu1;
		
	return 0;
}

void MenuEnquete(int client)
{
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(DoMenuEnquete);
	menu.SetTitle("Quel dossier voulez-vous ?");
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientValid(i))
		{
			char name[32], strI[8];
			IntToString(i, STRING(strI));
			GetClientName(i, STRING(name));
			
			if (rp_GetClientInt(i, i_Job) == 2 && rp_GetClientInt(i, i_Grade) == 1)
				menu.AddItem("", name, ITEMDRAW_DISABLED);
			else 
				menu.AddItem(strI, name);
		}
	}
	
	menu.ExitBackButton = true;
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int DoMenuEnquete(Menu menu, MenuAction action, int client, int param)
{
	if (action == MenuAction_Select)
	{
		char info[64], strFormat[64];
		menu.GetItem(param, STRING(info));
		int id = StringToInt(info);
		
		rp_SetClientBool(client, b_DisplayHud, false);
		Menu menu1 = new Menu(DoMenuEnqueteFinal);
		menu1.SetTitle("Dossier de %N :", id);
		
		Format(STRING(strFormat), "Karma : %f", rp_GetClientFloat(id, fl_Vitality));
		menu1.AddItem("", strFormat, ITEMDRAW_DISABLED);
		
		menu1.ExitBackButton = true;
		menu1.ExitButton = true;
		menu1.Display(client, MENU_TIME_FOREVER);
	}
	else if (action == MenuAction_Cancel)
	{
		if (param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		//else if (param == MenuCancel_ExitBack)
			//MenuGererMetier(client);
	}
	else if (action == MenuAction_End)
		delete menu;
		
	return 0;
}

public int DoMenuEnqueteFinal(Menu menu1, MenuAction action, int client, int param)
{
	if (action == MenuAction_Cancel)
	{
		if (param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if (param == MenuCancel_ExitBack)
			MenuEnquete(client);
	}
	else if (action == MenuAction_End)
		delete menu1;
		
	return 0;
}

void MenuAvisRecherche(int client)
{
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(DoMenuRecherche);
	menu.SetTitle("Avis de recherche :");
	if (rp_GetClientInt(client, i_Job) == 1 && rp_GetClientInt(client, i_Grade) <= 5 || rp_GetClientInt(client, i_Job) == JOBID)
		menu.AddItem("avis", "Lancer un avis de recherche");
	menu.AddItem("afficher", "Liste des suspects recherchés");
	menu.ExitBackButton = true;
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int DoMenuRecherche(Menu menu, MenuAction action, int client, int param)
{
	if (action == MenuAction_Select)
	{
		char info[32];
		menu.GetItem(param, STRING(info));
		
		if (StrEqual(info, "avis"))
		{
			rp_SetClientBool(client, b_DisplayHud, false);
			Menu menu1 = new Menu(DoMenuAvisRecherche);
			menu1.SetTitle("Quel suspect est recherché ?");
			
			bool count;
			char strInfo[16], strMenu[64], jobName[32];
			LoopClients(i)
			{
				if (!IsClientValid(i))
					continue;
				
				count = true;
				rp_GetJobName(rp_GetClientInt(i, i_Job), STRING(jobName));
				Format(STRING(strMenu), "%N (%s)", i, jobName);
				Format(STRING(strInfo), "%i", i);
				menu1.AddItem(strInfo, strMenu);
			}
			if (!count)
				menu1.AddItem("", "Aucun suspect.", ITEMDRAW_DISABLED);
			
			menu1.ExitBackButton = true;
			menu1.ExitButton = true;
			menu1.Display(client, MENU_TIME_FOREVER);
		}
		else if (StrEqual(info, "afficher"))
		{
			rp_SetClientBool(client, b_DisplayHud, false);
			Menu menu2 = new Menu(DoMenuAfficherRecherche);
			menu2.SetTitle("Liste des suspects recherchés :");
			
			int count;
			char strInfo[16], strMenu[64], jobName[24];
			LoopClients(i)
			{
				if (!IsClientValid(i))
					continue;
				if (rp_GetClientBool(i, b_IsSearchByTribunal))
				{
					count++;
					rp_GetJobName(rp_GetClientInt(i, i_Job), STRING(jobName));
					Format(STRING(strMenu), "%N (%s)", i, jobName);
					Format(STRING(strInfo), "%i", i);
					if (rp_GetClientInt(client, i_Grade) <= 5)
						menu2.AddItem(strInfo, strMenu);
					else
						menu2.AddItem("", strMenu, ITEMDRAW_DISABLED);
				}
			}
			if (count == 0)
				menu2.AddItem("", "Aucun avis de recherche.", ITEMDRAW_DISABLED);
			
			menu2.ExitBackButton = true;
			menu2.ExitButton = true;
			menu2.Display(client, MENU_TIME_FOREVER);
		}
	}
	else if (action == MenuAction_Cancel)
	{
		if (param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if (param == MenuCancel_ExitBack)
		{
			ClientCommand(client, "rp");
			FakeClientCommand(client, "menuselect 1");
		}
	}
	else if (action == MenuAction_End)
		delete menu;
		
	return 0;
}

public int DoMenuAvisRecherche(Menu menu1, MenuAction action, int client, int param)
{
	if (action == MenuAction_Select)
	{
		char info[32];
		menu1.GetItem(param, STRING(info));
		
		int cible = StringToInt(info);
		if (IsClientValid(cible) && IsValidEntity(cible))
		{
			char jobName[32];
			rp_GetJobName(rp_GetClientInt(cible, i_Job), STRING(jobName));
			
			rp_SetClientBool(cible, b_IsSearchByTribunal, true);
			CreateTimer(360.0, UnAvisRecherche, client);
			
			rp_PrintToChat(client, "Vous avez lancé un avis de recherche sur \x02%N\x01.", cible);
			CPrintToChat(cible, "%s Vous êtes recherché par le \x02service de Police\x01, cachez-vous !");
			for (int i = 1; i <= MaxClients; i++)
			{
				if (IsClientValid(i) && i != client)
				{
					if (rp_GetClientInt(i, i_Job) == 1)
						CPrintToChat(i, "%s A toutes les unités, le suspect \x02%N \x01(%s) est recherché par {orange}%N\x01.", cible, jobName, client);
				}
			}
		}
	}
	else if (action == MenuAction_Cancel)
	{
		if (param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if (param == MenuCancel_ExitBack)
			MenuAvisRecherche(client);
	}
	else if (action == MenuAction_End)
		delete menu1;
		
	return 0;
}

public Action UnAvisRecherche(Handle timer, any client)
{
	if(IsClientValid(client))
	{
		if(rp_GetClientBool(client, b_IsSearchByTribunal))
		{
			rp_SetClientBool(client, b_IsSearchByTribunal, false);
			LogToFile(logFile, "Le joueur {yellow}%N {default}n'est plus recherché par la police.", client);
			
			LoopClients(i)
			{
				if(!IsClientValid(i))
					continue;
					
				if(rp_GetClientInt(i, i_Job) == 1)
				{
					PrintCenterText(i, "<font color='#a35a00'>Suspect en fuite</font> <font color='#ff0000'>!</font>");
					CPrintToChat(i, "%s Le suspect {red}%N {default} s'est enfui, l'avis de recherche est {yellow}annulé{default}.", client);
				}
			}
		}
	}
	
	return Plugin_Handled;
}

public int DoMenuAfficherRecherche(Menu menu2, MenuAction action, int client, int param)
{
	if (action == MenuAction_Select)
	{
		char info[32];
		menu2.GetItem(param, STRING(info));
		
		int cible = StringToInt(info);
		if (IsClientValid(cible) && IsValidEntity(cible))
		{
			if (rp_GetClientBool(cible, b_IsSearchByTribunal))
			{
				char jobName[32], strMenu[32];
				rp_GetJobName(rp_GetClientInt(cible, i_Job), STRING(jobName));
				
				rp_SetClientBool(client, b_DisplayHud, false);
				Menu menu5 = new Menu(DoMenuModifierRecherche);
				
				menu5.SetTitle("Modifier l'avis de recherche de %N (%s) :", cible, jobName);
				Format(STRING(strMenu), "trouver|%i", cible);
				if (rp_GetClientInt(client, i_Job) == 1)
					menu5.AddItem(strMenu, "Le suspect a été arrêté.");
				else 
					menu5.AddItem(strMenu, "Le suspect a été trouvé.");
				Format(STRING(strMenu), "annuler|%i", cible);
				menu5.AddItem(strMenu, "Annuler l'avis de recherche.");
				menu5.ExitButton = true;
				menu5.Display(client, MENU_TIME_FOREVER);
			}
		}
	}
	else if (action == MenuAction_Cancel)
	{
		if (param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if (param == MenuCancel_ExitBack)
			MenuAvisRecherche(client);
	}
	else if (action == MenuAction_End)
		delete menu2;
		
	return 0;
}

public int DoMenuModifierRecherche(Menu menu, MenuAction action, int client, int param)
{
	if (action == MenuAction_Select)
	{
		char info[32], buffer[2][16];
		menu.GetItem(param, STRING(info));
		
		ExplodeString(info, "|", buffer, 2, 16);
		// buffer[0] : info
		int cible = StringToInt(buffer[1]);
		
		if (IsValidEntity(cible))
		{
			if (StrEqual(buffer[0], "trouver"))
			{
				rp_SetClientBool(cible, b_IsSearchByTribunal, false);			
				
				char message[128];
				Format(STRING(message), "Le joueur %N a trouver le suspect %N (avis de recherche).", client, cible);
				rp_LogToDiscord(message);
				
				LoopClients(i)
				{
					if (!IsClientValid(i))
						continue;
					else if(i == client)	
						continue;
					
					char zone[64];
					rp_GetClientString(client, sz_ZoneName, STRING(zone));
					
					if (rp_GetClientInt(i, i_Job) == 1)
						rp_PrintToChat(client, "Le suspect \x02%N \x01 a été trouvé par {orange}%N \x01 (%s), l'avis de recherche est suspendu.", cible, client, zone);
				}
			}
			else if (StrEqual(buffer[0], "annuler"))
			{
				rp_SetClientBool(cible, b_IsSearchByTribunal, false);
				
				char message[128];
				Format(STRING(message), "Le joueur %N a annuler la recherche du suspect %N (avis de recherche).", client, cible);
				rp_LogToDiscord(message);
				
				LoopClients(i)
				{
					if (!IsClientValid(i))
						continue;
					else if(i == client)	
						continue;
						
					rp_PrintToChat(client, "L'avis de recherche de %N est annulé.", cible);
					PrintHintText(client, "L'avis de recherche de %N est annulé.", cible);
				}
			}
		}
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

void MenuPerquisition(int client)
{
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(DoMenuPerquisition);
	menu.SetTitle("Demander un mandat de perquisition :");
	
	char strIndex[32], jobname[64];
	for (int i = 2; i <= MAXJOBS; i++)
	{
		Format(STRING(strIndex), "%i", i);
		rp_GetJobName(i, STRING(jobname));
	
		menu.AddItem("", jobname, ITEMDRAW_DISABLED);	
	}		
	menu.ExitBackButton = true;
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int DoMenuPerquisition(Menu menu, MenuAction action, int client, int param)
{
	if (action == MenuAction_Select)
	{
		char info[64], jobName[32];
		menu.GetItem(param, STRING(info));
		
		rp_SetClientBool(client, b_DisplayHud, false);
		Menu menu1 = new Menu(DoMenuAttente);
		if (StrEqual(info, "1"))
			jobName = "appartement";
		else
			rp_GetJobName(StringToInt(info), STRING(jobName));
		menu1.SetTitle("Demande d'un mandat pour %s :", jobName);
		menu1.AddItem(info, "Le procureur étudie votre demande ...", ITEMDRAW_DISABLED);
		menu1.ExitButton = false;
		menu1.Display(client, MENU_TIME_FOREVER);
		
		DataPack pack = new DataPack();
		CreateDataTimer(GetRandomFloat(4.0, 10.0), CheckCanPerqui, pack, TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteCell(client);
		pack.WriteString(info);
	}
	else if (action == MenuAction_Cancel)
	{
		if (param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
	}
	else if (action == MenuAction_End)
		delete menu;
		
	return 0;
}

public int DoMenuAttente(Menu menu, MenuAction action, int client, int param)
{
	if (action == MenuAction_Cancel && param == MenuCancel_Exit)
	{
		rp_SetClientBool(client, b_DisplayHud, true);
	}
	else if (action == MenuAction_End)
		delete menu;
		
	return 0;
}

public Action CheckCanPerqui(Handle timer, DataPack pack)
{
	char strFormat[8];
	pack.Reset();
	int client = pack.ReadCell();
	pack.ReadString(STRING(strFormat));
	int perqui = StringToInt(strFormat);
	
	if(!IsClientValid(client))
		return Plugin_Stop;
	
	rp_SetClientBool(client, b_DisplayHud, true);
	
	/*if(!rp_CanPerquisition(perqui))
	{
		rp_PrintToChat(client, "Le procureur a {red}refusé{default} votre demande de perquisition.");
		return Plugin_Stop;
	}
	else if(rp_GetJobPerqui() != 0)
	{
		rp_PrintToChat(client, "Le procureur a {red}refusé{default} votre demande de perquisition. Une perquistion à eu lieu récemment.");
		return Plugin_Stop;
	}
	else if(rp_GetTime(i_hour2) < 6 && rp_GetTime(i_hour1) > 20)
	{
		rp_PrintToChat(client, "Le procureur a {red}refusé{default} votre demande de perquisition. L'heure réglementaire minimum est de 6h00 du matin à 20h00.");
		return Plugin_Stop;
	}*/
	
	int count;
	LoopClients(i)
	{
		if(IsClientValid(i) && rp_GetClientInt(i, i_Job) == 1 && !rp_GetClientBool(i, b_IsAfk))
			count++;
	}
	if(rp_GetClientInt(client, i_Grade) == 5 && count < 2
	|| rp_GetClientInt(client, i_Grade) == 4 && count < 1)
	{
		rp_PrintToChat(client, "Le procureur a {red}refusé{default} votre demande de perquisition. Il n'y a pas assez d'agent pour encadre une perquistion.");
		return Plugin_Stop;
	}
	
	if(perqui == 7)
	{
		count = 0;
		for(int i = 1; i <= MaxClients; i++)
		{
			if(IsClientValid(i) && rp_GetClientInt(i, i_Job) == JOBID && !rp_GetClientBool(i, b_IsAfk))
				count++;
		}
		if(count > 0)
		{
			rp_PrintToChat(client, "Le procureur a {red}refusé{default} votre demande de perquisition dans le Palais de Justice.");
			return Plugin_Stop;
		}
	}
	
	////char strName[32]; TODO
	////Format(STRING(strName), "mandat|%i|%s", perqui, steamID[client]); TODO	
	////SpawnPropByName(client, "mandat", strName); TODO
	
	rp_PrintToChat(client, "Le procureur {green}autorise{default} la perquisition, allez chercher le {yellow}mandat dans son bureau au Palais de Justice{default}.");

	return Plugin_Continue;
}

void MenuModifierParamPolice(int client, bool type, char[] id)
{
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_MenuModifierParamPolice);
	
	int price = Struct_JailRaison[StringToInt(id)].price;
	int time = Struct_JailRaison[StringToInt(id)].time;
	
	if (type)
		menu.SetTitle("%s [%i$][%s] :", Struct_JailRaison[StringToInt(id)].name, price, (Struct_JailRaison[StringToInt(id)].enabled == true) ? "ON" : "OFF");
	else
	{
		char strTime[32];
		StringTime(Struct_JailRaison[StringToInt(id)].time, STRING(strTime));
		menu.SetTitle("%s [%s][%s] :", Struct_JailRaison[StringToInt(id)].name, strTime, (Struct_JailRaison[StringToInt(id)].enabled == true) ? "ON" : "OFF");
	}
	
	char strMenu[64];
	if (type)
	{
		Format(STRING(strMenu), "%i|%s|30|+", type, id);
		menu.AddItem(strMenu, "Ajouter 30$");
		
		Format(STRING(strMenu), "%i|%s|10|+", type, id);
		menu.AddItem(strMenu, "Ajouter 10$");
		
		Format(STRING(strMenu), "%i|%s|1|+", type, id);
		menu.AddItem(strMenu, "Ajouter 1$");
		
		if (price >= 1)
		{
			Format(STRING(strMenu), "%i|%s|1|-", type, id);
			menu.AddItem(strMenu, "Retirer 1$");
		}
		if (price >= 10)
		{
			Format(STRING(strMenu), "%i|%s|10|-", type, id);
			menu.AddItem(strMenu, "Retirer 10$");
		}
		if (price >= 30)
		{
			Format(STRING(strMenu), "%i|%s|30|-", type, id);
			menu.AddItem(strMenu, "Retirer 30$");
		}
	}
	else
	{
		Format(STRING(strMenu), "%i|%s|30|+", type, id);
		menu.AddItem(strMenu, "Ajouter 30 secondes");
		
		Format(STRING(strMenu), "%i|%s|10|+", type, id);
		menu.AddItem(strMenu, "Ajouter 10 secondes");
		
		Format(STRING(strMenu), "%i|%s|1|+", type, id);
		menu.AddItem(strMenu, "Ajouter 1 seconde");
		
		if (time >= 1)
		{
			Format(STRING(strMenu), "%i|%s|1|-", type, id);
			menu.AddItem(strMenu, "Retirer 1 seconde");
		}
		if (time >= 10)
		{
			Format(STRING(strMenu), "%i|%s|10|-", type, id);
			menu.AddItem(strMenu, "Retirer 10 secondes");
		}
		if (time >= 30)
		{
			Format(STRING(strMenu), "%i|%s|30|-", type, id);
			menu.AddItem(strMenu, "Retirer 30 secondes");
		}
	}
	menu.ExitBackButton = true;
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Handle_MenuModifierParamPolice(Menu menu, MenuAction action, int client, int param)
{
	if (action == MenuAction_Select)
	{
		char info[32], buffer[4][32];
		menu.GetItem(param, STRING(info));
		ExplodeString(info, "|", STRING(buffer), sizeof(buffer[]));
		
		int type = StringToInt(buffer[0]);
		// buffer[1] : ID
		int montant = StringToInt(buffer[2]);

		KeyValues kv = new KeyValues("Jail_Raisons");
		char sPath[PLATFORM_MAX_PATH];
		BuildPath(Path_SM, STRING(sPath), "data/roleplay/jail_raisons.cfg");	
		Kv_CheckIfFileExist(kv, sPath);
		
		if(!kv.JumpToKey(buffer[1]))
		{
			PrintToServer("[KV] %s: ID %i not found !", sPath, buffer[1]);
			MenuParamPolice(client);
		}	
		
		if (vbool(type))
		{
			int calcul;
			if(StrEqual(buffer[3], "-"))
				calcul = kv.GetNum("amende") - montant;
			else
				calcul = kv.GetNum("amende") + montant;			
			
			kv.SetNum("amende", calcul);
			
			rp_PrintToChat(client, "Prix de la peine %s, changé en {lightgreen}%i$", Struct_JailRaison[StringToInt(buffer[1])].name, calcul);
			
			char message[128];
			Format(STRING(message), "%N a changé le prix de %s en %i$.", client, Struct_JailRaison[StringToInt(buffer[1])].name, calcul);
			rp_LogToDiscord(message);
		
			MenuModifierParamPolice(client, true, buffer[1]);
		}
		else
		{
			int calcul;
			if(StrEqual(buffer[3], "-"))
				calcul = kv.GetNum("temps") - montant;
			else
				calcul = kv.GetNum("temps") + montant;	

			kv.SetNum("temps", calcul);
			
			char strTime[32];
			StringTime(calcul, STRING(strTime));
			
			rp_PrintToChat(client, "Temps de la peine %s, changé en {lightblue}%s", Struct_JailRaison[StringToInt(buffer[1])].name, strTime);
			
			char message[128];
			Format(STRING(message), "%N a changé le temps de %s en %s.", client, Struct_JailRaison[StringToInt(buffer[1])].name, strTime);
			rp_LogToDiscord(message);
			
			MenuModifierParamPolice(client, false, buffer[1]);
		}
		
		kv.Rewind();
		kv.ExportToFile(sPath);
		delete kv;
	}
	else if (action == MenuAction_Cancel)
	{
		if (param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if (param == MenuCancel_ExitBack)
			MenuParamPolice(client);
	}
	else if (action == MenuAction_End)
		delete menu;
		
	return 0;
}

/***************************************************************************************

									C L I E N T - S I D E

***************************************************************************************/

public void OnClientPostAdminCheck(int client) 
{	
	SQL_LoadClient(client);
}

public void SQL_LoadClient(int client) 
{
	if(!IsClientValid(client))
		return;
			
	char buffer[512];
	Format(STRING(buffer), "SELECT * FROM `rp_jails` WHERE `steamid` = '%s';", steamID[client]);
	g_DB.Query(SQL_Callback, buffer, GetClientUserId(client));
}

public void SQL_Callback(Database db, DBResultSet Results, const char[] error, any data) 
{	
	int client = GetClientOfUserId(data);
	if (Results.FetchRow()) 
	{
		int time;
		Results.FetchIntByName("time", time);
		if(time != 0)
		{
			int raison, jailid;
			Results.FetchIntByName("raison", raison);
			Results.FetchIntByName("jailid", jailid);
			
			rp_SetClientInt(client, i_JailTime, time);
			rp_SetClientInt(client, i_JailRaisonID, raison);
			rp_SetClientInt(client, i_JailID, jailid);
		}	
		else
		{
			rp_SetClientInt(client, i_JailTime, 0);
			rp_SetClientInt(client, i_JailRaisonID, 0);
			rp_SetClientInt(client, i_JailID, 0);
		}	
	}
	else
		rp_SetClientInt(client, i_JailTime, 0);
} 

public void OnClientAuthorized(int client, const char[] auth) 
{	
	strcopy(steamID[client], sizeof(steamID[]), auth);
}

public void OnClientDisconnect(int client)
{
	SQL_Request(g_DB, "UPDATE `rp_jails` SET `time` = '%i' WHERE steamid = '%s';", rp_GetClientInt(client, i_JailTime), steamID[client]);			
}

public Action Command_Garage(int client, int args)
{
	if(Zone_Garage(client) && rp_GetClientBool(client, b_DisplayHud))
	{
		if(rp_GetClientInt(client, i_Job) == 1 && rp_GetClientInt(client, i_Grade) <= 4)
		{
			rp_SetClientBool(client, b_DisplayHud, true);
			bool blockGarage = false;
			Menu menu = new Menu(Handle_Garage);
			menu.SetTitle("Garage du W.C.P.D. :");
			
			int countCarPolice;
			char vehicleName[64];
			LoopEntities(i)
			{
				if(!IsValidEntity(i))
					continue;
				
				if(Vehicle_IsValid(i))
				{
					Entity_GetName(i, STRING(vehicleName));
					if(StrContains(vehicleName, steamID[client], false) != -1
					&& rp_GetVehicleInt(i, car_police) == 1)
					{
						countCarPolice++;
						blockGarage = true;
					}	
				}
			}
			if(countCarPolice > 2)
				menu.AddItem("", "Il y a trop de voiture de police.", ITEMDRAW_DISABLED);
			else if(!blockGarage)
				menu.AddItem("oui", "Prendre une voiture de fonction.");
			else 
				menu.AddItem("", "Votre voiture n'est pas dans le garage.", ITEMDRAW_DISABLED);
			menu.Display(client, MENU_TIME_FOREVER);
		}
	}
	
	return Plugin_Handled;
}

bool Zone_Garage(int ent)
{
	float position[3];
	GetEntPropVector(ent, Prop_Send, "m_vecOrigin", position);
	if(position[0] >= 1032.049682 && position[0] <= 1582.049682 && position[1] >= 32.078071 && position[1] <= 772.078063 && position[2] >= -4.968750 && position[2] <= 185.031250)
		return true;
	else return false;
}

public int Handle_Garage(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[32];
		menu.GetItem(param, STRING(info));
		
		if(StrEqual(info, "oui"))
		{
			bool block = false;
			char entClass[64];
			for(int i = MaxClients; i <= MAXENTITIES; i++)
			{
				if(IsValidEntity(i))
				{
					Entity_GetClassName(i, STRING(entClass));
					if(StrEqual(entClass, "prop_vehicle_driveable"))
					{
						if(Zone_Garage(i))
							block = true;
					}
				}
			}
			
			if(block)
				rp_PrintToChat(client, "Il y a déjà une voiture dans le garage.");
			else 
			{
				//rp_SpawnVehicle(client, 5, 0.0, 500.0, 250.0, false); TODO
				rp_PrintToChat(client, "Le véhicule de fonction est prêt.");
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

public void RP_OnClientBuild(Menu menu, int client)
{
	if(rp_GetClientInt(client, i_Job) == 1)
	{
		menu.AddItem("bumper", "Placer un ralentisseur");
		menu.AddItem("barriere01", "Barrière 01");
		menu.AddItem("barriere02", "Barrière 02");
		menu.AddItem("barriere03", "Barrière 03");
	}	
}	

public void RP_OnClientBuildHandle(int client, const char[] info)
{
	rp_SetClientBool(client, b_DisplayHud, true);
	int prop;
	char sModel[128];
	if(StrEqual(info, "bumper"))
	{
		float position[3], angle[3];
		PointVision(client, position);
		GetClientAbsAngles(client, angle);
		
		rp_GetGlobalData("model_bumper", STRING(sModel));
		prop = rp_CreateDynamic("prop_dynamic", position, angle, sModel);
		if(IsValidEdict(prop))
		{
			rp_PrintToChat(client, "Vous avez installé un ralentisseur.");
			
			char tmp[128];
			Format(STRING(tmp), "[SPAWN-PROP]%N: %s", client, sModel);
			rp_LogToDiscord(tmp);
		}
	}
	else if(StrEqual(info, "barriere01"))
	{
		float position[3], angle[3];
		PointVision(client, position);
		GetClientAbsAngles(client, angle);
		
		rp_GetGlobalData("model_barrier01", STRING(sModel));
		prop = rp_CreateDynamic("prop_dynamic", position, angle, sModel);
		if(IsValidEdict(prop))
		{
			rp_PrintToChat(client, "Vous avez installé une barrière.");
			
			char tmp[128];
			Format(STRING(tmp), "[SPAWN-PROP]%N: %s", client, sModel);
			rp_LogToDiscord(tmp);
		}
	}
	else if(StrEqual(info, "barriere02"))
	{
		float position[3], angle[3];
		PointVision(client, position);
		GetClientAbsAngles(client, angle);
		
		rp_GetGlobalData("model_barrier02", STRING(sModel));
		prop = rp_CreateDynamic("prop_dynamic", position, angle, sModel);
		if(IsValidEdict(prop))
		{
			rp_PrintToChat(client, "Vous avez installé une barrière.");
			
			char tmp[128];
			Format(STRING(tmp), "[SPAWN-PROP]%N: %s", client, sModel);
			rp_LogToDiscord(tmp);
		}
	}
	else if(StrEqual(info, "barriere03"))
	{
		float position[3], angle[3];
		PointVision(client, position);
		GetClientAbsAngles(client, angle);
		
		rp_GetGlobalData("model_barrier03", STRING(sModel));
		prop = rp_CreateDynamic("prop_dynamic", position, angle, sModel);
		if(IsValidEdict(prop))
		{
			rp_PrintToChat(client, "Vous avez installé une barrière.");
			
			char tmp[128];
			Format(STRING(tmp), "[SPAWN-PROP]%N: %s", client, sModel);
			rp_LogToDiscord(tmp);
		}
	}
	if(prop != -1)
		Entity_SetName(prop, "PROP_POLICE");
}

public void RP_OnClientFire(int client, int target, const char[] weapon)
{
	if(rp_GetClientBool(client, b_IsTased))
		return;
}

public Action RP_OnJailTimeFinish(int client)
{
	SQL_Request(g_DB, "DELETE FROM `rp_jails` WHERE `steamid` = '%s'", steamID[client]);
	
	return Plugin_Handled;
}