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

#define MAX_NPCS 512

enum struct GlobalNpcProperties {
	int gRefId;
	char gUniqueId[128];
	char gName[256];
	char gIdleAnimation[256];
	char gSecondAnimation[256];
	char gThirdAnimation[256];
	bool gInAnimation;
	int iType;
}
GlobalNpcProperties g_iNpcList[MAXENTITIES + 1];

enum struct NpcEdit {
	int nNpcId;
	bool nWaitingForModelName;
	bool nWaitingForIdleAnimationName;
	bool nWaitingForName;
}
NpcEdit g_eNpcEdit[MAXPLAYERS + 1];

enum struct Data_Forward {
	GlobalForward OnInteract;
}	
Data_Forward Forward;

Database g_DB;
int g_iNpcId = 0;

/***************************************************************************************

							P L U G I N  -  I N F O

***************************************************************************************/
public Plugin myinfo = 
{
	name = "Roleplay - Permanent Entity", 
	author = "MBK", 
	description = "NPC System spawn trough the map", 
	version = "1.0", 
	url = "https://github.com/Mbk10201"
};

/***************************************************************************************

									 F U N C T I O N S

***************************************************************************************/

public void OnPluginStart()
{
	LoadTranslation();
	
	RegConsoleCmd("rp_npc", Command_SpawnNpc);
	RegConsoleCmd("rp_editnpc", Command_EditNpc);	
}

public void RP_OnSQLInit(Database db, Transaction transaction)
{
	g_DB = db;
	
	char sBuffer[MAX_BUFFER_LENGTH + 1];
	
	Format(STRING(sBuffer), "CREATE TABLE IF NOT EXISTS `rp_entity_permanent` ( \
	  `id` int(11) NOT NULL AUTO_INCREMENT, \
	  `uniqueId` varchar(128) COLLATE utf8_bin NOT NULL, \
	  `name` varchar(64) COLLATE utf8_bin NOT NULL, \
	  `type` varchar(8) COLLATE utf8_bin NOT NULL, \
	  `map` varchar(128) COLLATE utf8_bin NOT NULL, \
	  `model` varchar(256) COLLATE utf8_bin NOT NULL, \
	  `idle_animation` varchar(256) COLLATE utf8_bin NOT NULL, \
	  `second_animation` varchar(256) COLLATE utf8_bin NOT NULL, \
	  `third_animation` varchar(256) COLLATE utf8_bin NOT NULL, \
	  `pos_x` float NOT NULL, \
	  `pos_y` float NOT NULL, \
	  `pos_z` float NOT NULL, \
	  `angle_x` float NOT NULL, \
	  `angle_y` float NOT NULL, \
	  `angle_z` float NOT NULL, \
	  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP, \
	  PRIMARY KEY (`id`), \
	  UNIQUE KEY `uniqueId` (`uniqueId`) \
	  )ENGINE = InnoDB DEFAULT CHARSET = utf8 COLLATE = utf8_bin;");
	#if DEBUG
		PrintToServer(sBuffer);
	#endif
	transaction.AddQuery(sBuffer); 
}

public void resetNpcEdit(int client) 
{
	g_eNpcEdit[client].nNpcId = -1;
	g_eNpcEdit[client].nWaitingForModelName = false;
}


public void OnMapStart()
{
	g_iNpcId = 0;
	//SQL_LoadNPC();
}

public Action RP_OnRoundStart()
{
	SQL_LoadNPC();
}

/***************************************************************************************

									N A T I V E S

***************************************************************************************/

public APLRes AskPluginLoad2(Handle plugin, bool late, char[] error, int err_max)
{
	RegPluginLibrary("rp_entity_permanent");
	
	Forward.OnInteract = new GlobalForward("RP_OnNPCInteract", ET_Event, Param_Cell, Param_Cell, Param_Cell);
	
	CreateNative("rp_LoadNPC", Native_LoadPermaProps);
	CreateNative("rp_GetNPCType", Native_GetNPCType);
}

public int Native_LoadPermaProps(Handle plugin, int numParams) 
{
	g_iNpcId = 0;
	SQL_LoadNPC();
}

public int Native_GetNPCType(Handle plugin, int numParams) 
{
	int entity = GetNativeCell(1);
	
	if(!IsValidEntity(entity) && g_iNpcList[entity].gRefId != 0)
		return -1;
	
	return g_iNpcList[entity].iType;
}
/***************************************************************************************

									C A L L B A C K

***************************************************************************************/

public Action Command_EditNpc(int client, int args) 
{
	int TargetObject = GetTargetBlock(client);
	if (TargetObject == -1) 
	{
		ReplyToCommand(client, "Invalid target");
		return Plugin_Handled;
	}
	
	g_eNpcEdit[client].nNpcId = TargetObject;
	
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_MenuEdit);
	char entityName[256];
	Entity_GetGlobalName(TargetObject, STRING(entityName));
	menu.SetTitle("Entity %s", entityName);
	menu.AddItem("model", "Edit Model");
	menu.AddItem("idleAnimation", "Edit Idle Animation");
	menu.AddItem("position", "Edit Position");
	menu.AddItem("angles", "Edit Angles");
	menu.AddItem("name", "Edit Name");
	menu.AddItem("type", "Edit Type");
	menu.AddItem("base", "Edit Base Properties");
	menu.AddItem("delete", "Delete Npc");
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);	
	
	return Plugin_Handled;
}

public int Handle_MenuEdit(Menu menu, MenuAction action, int client, int param) 
{
	if (action == MenuAction_Select) 
	{
		char info[32];
		menu.GetItem(param, STRING(info));
		if (StrEqual(info, "model")) 
		{
			g_eNpcEdit[client].nWaitingForModelName = true;
			PrintToChat(client, "Enter the new Model Name OR 'abort' to cancel");
		} 
		else if (StrEqual(info, "idleAnimation")) 
		{
			g_eNpcEdit[client].nWaitingForIdleAnimationName = true;
			PrintToChat(client, "Enter the new Idle Animation Name OR 'abort' to cancel");
		} 
		else if (StrEqual(info, "position")) 
		{
			Menu_Position(client);
		} 
		else if (StrEqual(info, "angles")) 
		{
			Menu_Angles(client);
		} 
		else if (StrEqual(info, "base")) 
		{
			Menu_Property(client);
		} 
		else if (StrEqual(info, "delete")) 
		{
			char npcUniqueId[128];
			GetEntPropString(g_eNpcEdit[client].nNpcId, Prop_Data, "m_iName", STRING(npcUniqueId));
			
			SQL_Request(g_DB, "DELETE FROM `rp_entity_permanent` WHERE `uniqueId` = '%s'", npcUniqueId);
			
			if (IsValidEntity(g_eNpcEdit[client].nNpcId))
				AcceptEntityInput(g_eNpcEdit[client].nNpcId, "kill");
		} 
		else if (StrEqual(info, "name")) 
		{
			g_eNpcEdit[client].nWaitingForName = true;
			PrintToChat(client, "Enter the new Name OR 'abort' to cancel");
		} 
		else if (StrEqual(info, "type")) 
		{
			Menu_Type(client);
		} 
	}
	else if (action == MenuAction_Cancel)
	{
		if (param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
	}
	else if (action == MenuAction_End)
		delete menu;
}

public void Menu_Position(int client) 
{
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_Position);
	char entityName[256];
	Entity_GetGlobalName(g_eNpcEdit[client].nNpcId, STRING(entityName));
	menu.SetTitle("Edit Position of %s", entityName);
	menu.AddItem("up", "Move Up");
	menu.AddItem("down", "Move Down");
	menu.AddItem("xPlus", "Move X Plus");
	menu.AddItem("xMinus", "Move X Minus");
	menu.AddItem("yPlus", "Move Y Plus");
	menu.AddItem("yMinus", "Move Y Minus");
	menu.AddItem("ground", "Put on Ground");
	menu.AddItem("tpYourself", "Teleport to yourself");
	menu.ExitButton = true;
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
		GetEntPropString(g_eNpcEdit[client].nNpcId, Prop_Data, "m_iName", STRING(npcUniqueId));
		
		if (StrEqual(info, "up")) 
		{
			GetEntPropVector(g_eNpcEdit[client].nNpcId, Prop_Data, "m_vecOrigin", pos);
			pos[2] += 10;
			TeleportEntity(g_eNpcEdit[client].nNpcId, pos, NULL_VECTOR, NULL_VECTOR);
			Menu_Position(client);
			
			SQL_Request(g_DB, "UPDATE `rp_entity_permanent` SET `pos_z` = '%.2f' WHERE `uniqueId` = '%s'", pos[2], npcUniqueId);
		} 
		else if (StrEqual(info, "down")) 
		{
			GetEntPropVector(g_eNpcEdit[client].nNpcId, Prop_Data, "m_vecOrigin", pos);
			pos[2] -= 10;
			TeleportEntity(g_eNpcEdit[client].nNpcId, pos, NULL_VECTOR, NULL_VECTOR);
			Menu_Position(client);
			
			SQL_Request(g_DB, "UPDATE `rp_entity_permanent` SET `pos_z` = '%.2f' WHERE `uniqueId` = '%s'", pos[2], npcUniqueId);
		} 
		else if (StrEqual(info, "ground")) 
		{
			GetEntPropVector(g_eNpcEdit[client].nNpcId, Prop_Data, "m_vecOrigin", pos);
			pos[2] -= GetClientDistanceToGround(client);
			TeleportEntity(g_eNpcEdit[client].nNpcId, pos, NULL_VECTOR, NULL_VECTOR);
			Menu_Position(client);
			
			SQL_Request(g_DB, "UPDATE `rp_entity_permanent` SET `pos_z` = '%.2f' WHERE `uniqueId` = '%s'", pos[2], npcUniqueId);
		} 
		else if (StrEqual(info, "tpYourself")) 
		{
			float selfPos[3];
			GetClientAbsOrigin(client, selfPos);
			TeleportEntity(g_eNpcEdit[client].nNpcId, selfPos, NULL_VECTOR, NULL_VECTOR);
			Menu_Position(client);
			
			SQL_Request(g_DB, "UPDATE `rp_entity_permanent` SET `pos_x` = '%.2f' WHERE `uniqueId` = '%s'", selfPos[0], npcUniqueId);
			SQL_Request(g_DB, "UPDATE `rp_entity_permanent` SET `pos_y` = '%.2f' WHERE `uniqueId` = '%s'", selfPos[1], npcUniqueId);
			SQL_Request(g_DB, "UPDATE `rp_entity_permanent` SET `pos_z` = '%.2f' WHERE `uniqueId` = '%s'", selfPos[2], npcUniqueId);
		} 
		else if (StrEqual(info, "xPlus")) 
		{
			GetEntPropVector(g_eNpcEdit[client].nNpcId, Prop_Data, "m_vecOrigin", pos);
			pos[0] += 10;
			TeleportEntity(g_eNpcEdit[client].nNpcId, pos, NULL_VECTOR, NULL_VECTOR);
			Menu_Position(client);
			
			SQL_Request(g_DB, "UPDATE `rp_entity_permanent` SET `pos_x = '%.2f' WHERE `uniqueId` = '%s'", pos[0], npcUniqueId);
		} 
		else if (StrEqual(info, "xMinus")) 
		{
			GetEntPropVector(g_eNpcEdit[client].nNpcId, Prop_Data, "m_vecOrigin", pos);
			pos[0] -= 10;
			TeleportEntity(g_eNpcEdit[client].nNpcId, pos, NULL_VECTOR, NULL_VECTOR);
			Menu_Position(client);
			
			SQL_Request(g_DB, "UPDATE `rp_entity_permanent` SET `pos_x` = '%.2f' WHERE `uniqueId` = '%s'", pos[0], npcUniqueId);
		} 
		else if (StrEqual(info, "yPlus")) 
		{
			GetEntPropVector(g_eNpcEdit[client].nNpcId, Prop_Data, "m_vecOrigin", pos);
			pos[1] += 10;
			TeleportEntity(g_eNpcEdit[client].nNpcId, pos, NULL_VECTOR, NULL_VECTOR);
			Menu_Position(client);
			
			SQL_Request(g_DB, "UPDATE `rp_entity_permanent` SET `pos_y` = '%.2f' WHERE `uniqueId` = '%s'", pos[1], npcUniqueId);
		} 
		else if (StrEqual(info, "yMinus")) 
		{
			GetEntPropVector(g_eNpcEdit[client].nNpcId, Prop_Data, "m_vecOrigin", pos);
			pos[1] -= 10;
			TeleportEntity(g_eNpcEdit[client].nNpcId, pos, NULL_VECTOR, NULL_VECTOR);
			Menu_Position(client);
			
			SQL_Request(g_DB, "UPDATE `rp_entity_permanent` SET `pos_y` = '%.2f' WHERE `uniqueId` = '%s'", pos[1], npcUniqueId);
		}
	}
	else if (action == MenuAction_Cancel)
	{
		if (param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
	}
	else if (action == MenuAction_End)
		delete menu;
}

public void Menu_Angles(int client) 
{
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_Angles);
	char entityName[256];
	Entity_GetGlobalName(g_eNpcEdit[client].nNpcId, STRING(entityName));
	menu.SetTitle("Edit Angles of %s", entityName);
	menu.AddItem("yourself", "Set Your Angles");
	menu.AddItem("yourselfInverted", "Set Your Inverted Angles");
	menu.AddItem("minus", "Add Angles");
	menu.AddItem("plus", "Move Down");
	menu.ExitButton = true;
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
		if (g_eNpcEdit[client].nNpcId == -1)
			return;
		GetEntPropString(g_eNpcEdit[client].nNpcId, Prop_Data, "m_iName", STRING(npcUniqueId));
		
		if (StrEqual(info, "plus")) 
		{
			GetEntPropVector(g_eNpcEdit[client].nNpcId, Prop_Data, "m_angRotation", angles);
			angles[1] += 5;
			TeleportEntity(g_eNpcEdit[client].nNpcId, NULL_VECTOR, angles, NULL_VECTOR);
			Menu_Angles(client);
			
			SQL_Request(g_DB, "UPDATE `rp_entity_permanent` SET angle_y = '%.2f' WHERE `uniqueId` = '%s'", angles[1], npcUniqueId);
		} 
		else if (StrEqual(info, "minus")) 
		{
			GetEntPropVector(g_eNpcEdit[client].nNpcId, Prop_Data, "m_angRotation", angles);
			angles[1] -= 5;
			TeleportEntity(g_eNpcEdit[client].nNpcId, NULL_VECTOR, angles, NULL_VECTOR);
			Menu_Angles(client);
			
			SQL_Request(g_DB, "UPDATE `rp_entity_permanent` SET angle_y = '%.2f' WHERE `uniqueId` = '%s'", angles[1], npcUniqueId);
		} 
		else if (StrEqual(info, "yourself")) 
		{
			float selfAngles[3];
			GetClientAbsAngles(client, selfAngles);
			TeleportEntity(g_eNpcEdit[client].nNpcId, NULL_VECTOR, selfAngles, NULL_VECTOR);
			Menu_Angles(client);
			
			SQL_Request(g_DB, "UPDATE `rp_entity_permanent` SET `angle_x` = '%.2f' WHERE `uniqueId` = '%s'", selfAngles[0], npcUniqueId);
			SQL_Request(g_DB, "UPDATE `rp_entity_permanent` SET angle_y = '%.2f' WHERE `uniqueId` = '%s'", selfAngles[1], npcUniqueId);
			SQL_Request(g_DB, "UPDATE `rp_entity_permanent` SET `angle_z` = '%.2f' WHERE `uniqueId` = '%s'", selfAngles[2], npcUniqueId);
		}
		else if (StrEqual(info, "yourselfInverted")) 
		{
			float selfAngles[3];
			GetClientAbsAngles(client, selfAngles);
			selfAngles[1] = 180 - selfAngles[1];
			TeleportEntity(g_eNpcEdit[client].nNpcId, NULL_VECTOR, selfAngles, NULL_VECTOR);
			Menu_Angles(client);
			
			SQL_Request(g_DB, "UPDATE `rp_entity_permanent` SET `angle_x` = '%.2f' WHERE `uniqueId` = '%s'", selfAngles[0], npcUniqueId);
			SQL_Request(g_DB, "UPDATE `rp_entity_permanent` SET angle_y = '%.2f' WHERE `uniqueId` = '%s'", selfAngles[1], npcUniqueId);
			SQL_Request(g_DB, "UPDATE `rp_entity_permanent` SET `angle_z` = '%.2f' WHERE `uniqueId` = '%s'", selfAngles[2], npcUniqueId);
		}
	}
	else if (action == MenuAction_Cancel)
	{
		if (param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
	}
	else if (action == MenuAction_End)
		delete menu;
}

public void Menu_Property(int client) 
{
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_Property);
	char entityName[256];
	Entity_GetGlobalName(g_eNpcEdit[client].nNpcId, STRING(entityName));
	menu.SetTitle("Edit Base Properties of %s", entityName);
	menu.AddItem("solid", "Make NPC solid");
	menu.AddItem("nonsolid", "Make NPC non-solid");
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Handle_Property(Menu menu, MenuAction action, int client, int param) 
{
	if (action == MenuAction_Select) 
	{
		char info[32];
		menu.GetItem(param, STRING(info));
		if (StrEqual(info, "solid")) 
		{
			SetEntProp(g_eNpcEdit[client].nNpcId, Prop_Send, "m_nSolidType", 6);
			Menu_Property(client);
		} 
		else if (StrEqual(info, "nonsolid")) 
		{
			SetEntProp(g_eNpcEdit[client].nNpcId, Prop_Send, "m_nSolidType", 0);
			Menu_Property(client);
		}
	}
	else if (action == MenuAction_Cancel)
	{
		if (param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
	}
	else if (action == MenuAction_End)
		delete menu;
}

Menu Menu_Type(int client) 
{
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_MenuType);
	char entityName[256];
	Entity_GetGlobalName(g_eNpcEdit[client].nNpcId, STRING(entityName));
	menu.SetTitle("Edit Type %s", entityName);
	menu.AddItem("solid", "Make NPC solid");
	
	for (int i = 1; i <= MAXJOBS; i++)
	{
		char jobname[32], sTmp[8];
		rp_GetJobName(i, STRING(jobname));
		Format(STRING(jobname), "%s (%i)", jobname, i);
		Format(STRING(sTmp), "%i", i);
		
		menu.AddItem(sTmp, jobname);
	}
	
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Handle_MenuType(Menu menu, MenuAction action, int client, int param) 
{
	if (action == MenuAction_Select) 
	{
		char info[8];
		menu.GetItem(param, STRING(info));
		g_iNpcList[g_eNpcEdit[client].nNpcId].iType = StringToInt(info);
		
		char npcUniqueId[128];
		GetEntPropString(g_eNpcEdit[client].nNpcId, Prop_Data, "m_iName", STRING(npcUniqueId));

		SQL_Request(g_DB, "UPDATE `rp_entity_permanent` SET `type` = '%i' WHERE `uniqueId` = '%s'", StringToInt(info), npcUniqueId);
	}
	else if (action == MenuAction_Cancel)
	{
		if (param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
	}
	else if (action == MenuAction_End)
		delete menu;
}

public Action Command_SpawnNpc(int client, int args) 
{
	int npc = CreateEntityByName("prop_dynamic");
	if (npc == -1) 
	{
		PrintToChat(client, "[RP] Can not spawn Npc - report this?");
		return Plugin_Handled;
	}
	
	g_iNpcList[g_iNpcId].gRefId = EntIndexToEntRef(npc);
	float pos[3];
	GetClientAbsOrigin(client, pos);
	float angles[3];
	GetClientAbsAngles(client, angles);
	
	char uniqueId[128];
	int uniqueIdTime = GetTime();
	IntToString(uniqueIdTime, STRING(uniqueId));
	strcopy(g_iNpcList[g_iNpcId].gUniqueId, 128, uniqueId);
	
	char mapName[128];
	rp_GetCurrentMap(STRING(mapName));
	
	SQL_Request(g_DB, "INSERT INTO `rp_entity_permanent` (`id`, `uniqueId`, `name`, `type`, `map`, `model`, `idle_animation`, `second_animation`, `third_animation`, `pos_x`, `pos_y`, `pos_z`, `angle_x`, `angle_y`, `angle_z`, `timestamp`) VALUES (NULL, '%s', '', '-1', '%s', 'models/characters/hostage_01.mdl', 'idle_subtle', '', '', '%.2f', '%.2f', '%.2f', '%.2f', '%.2f', '%.2f', CURRENT_TIMESTAMP);", uniqueId, mapName, pos[0], pos[1], pos[2], angles[0], angles[1], angles[2]);
	CreateNpc(uniqueId, "", "-1", "models/characters/hostage_01.mdl", "idle_subtle", "Wave", "", pos, angles);
	
	//g_iNpcId++;
	return Plugin_Handled;
}

public Action RP_OnClientInteract(int client, int target, const char[] class, const char[] model, const char[] name)
{
	char sTmp[128];
	GetEntPropString(target, Prop_Data, "m_iName", STRING(sTmp));
	onNpcInteract(client, sTmp, target);
}

stock int GetTargetBlock(int client) 
{
	int entity = GetClientAimTarget(client, false);
	if (IsValidEntity(entity)) 
	{
		char classname[32];
		GetEdictClassname(entity, STRING(classname));
		
		if (StrContains(classname, "prop_dynamic") != -1)
			return entity;
	}
	return -1;
}

public Action RP_OnClientSay(int client, const char[] arg)
{
	if (g_eNpcEdit[client].nWaitingForModelName && StrContains(arg, "abort", false) == -1) 
	{
		PrecacheModel(arg, true);
		SetEntityModel(g_eNpcEdit[client].nNpcId, arg);
		char entityName[256];
		Entity_GetGlobalName(g_eNpcEdit[client].nNpcId, STRING(entityName));
		PrintToChat(client, "Set Model of %s TO %s", entityName, arg);
		g_eNpcEdit[client].nWaitingForModelName = false;
		char npcUniqueId[128];
		GetEntPropString(g_eNpcEdit[client].nNpcId, Prop_Data, "m_iName", STRING(npcUniqueId));
		SQL_Request(g_DB, "UPDATE `rp_entity_permanent` SET `model` = '%s' WHERE `uniqueId` = '%s'", arg, npcUniqueId);
		
		return Plugin_Handled;
	} 
	else if (g_eNpcEdit[client].nWaitingForIdleAnimationName && StrContains(arg, "abort", false) == -1) 
	{
		SetVariantString(arg);
		AcceptEntityInput(g_eNpcEdit[client].nNpcId, "SetAnimation");
		strcopy(g_iNpcList[g_iNpcId].gIdleAnimation, 256, arg);
		char entityName[256];
		Entity_GetGlobalName(g_eNpcEdit[client].nNpcId, STRING(entityName));
		PrintToChat(client, "Set Idle Animation of %s TO %s", entityName, arg);
		g_eNpcEdit[client].nWaitingForIdleAnimationName = false;
		char npcUniqueId[128];
		GetEntPropString(g_eNpcEdit[client].nNpcId, Prop_Data, "m_iName", STRING(npcUniqueId));
		SQL_Request(g_DB, "UPDATE `rp_entity_permanent` SET `idle_animation` = '%s' WHERE `uniqueId` = '%s'", arg, npcUniqueId);
		
		return Plugin_Handled;
	} 
	else if (g_eNpcEdit[client].nWaitingForName && StrContains(arg, "abort", false) == -1) 
	{
		SetVariantString(arg);
		char entityName[256];
		Format(STRING(entityName), "%s", arg);
		Entity_SetGlobalName(g_eNpcEdit[client].nNpcId, STRING(entityName));
		PrintToChat(client, "Set Name of %s TO %s", entityName, arg);
		g_eNpcEdit[client].nWaitingForName = false;
		char npcUniqueId[128];
		GetEntPropString(g_eNpcEdit[client].nNpcId, Prop_Data, "m_iName", STRING(npcUniqueId));
		SQL_Request(g_DB, "UPDATE `rp_entity_permanent` SET `name` = '%s' WHERE `uniqueId` = '%s'", arg, npcUniqueId);
		
		strcopy(g_iNpcList[g_iNpcId].gName, 128, arg);
		return Plugin_Handled;
	} 
	else if ((g_eNpcEdit[client].nWaitingForModelName || g_eNpcEdit[client].nWaitingForIdleAnimationName || g_eNpcEdit[client].nWaitingForName) && StrContains(arg, "abort", false) != -1) 
	{
		g_eNpcEdit[client].nWaitingForModelName = false;
		g_eNpcEdit[client].nWaitingForIdleAnimationName = false;
		g_eNpcEdit[client].nWaitingForName = false;
		PrintToChat(client, "Aborted.");
		return Plugin_Handled;
	}
	
	
	return Plugin_Continue;
}

public float GetClientDistanceToGround(int client) 
{	
	float fOrigin[3];
	float fGround[3];
	GetEntPropVector(g_eNpcEdit[client].nNpcId, Prop_Data, "m_vecOrigin", fOrigin);
	
	fOrigin[2] += 10.0;
	float anglePos[3];
	anglePos[0] = 90.0;
	anglePos[1] = 0.0;
	anglePos[2] = 0.0;
	
	TR_TraceRayFilter(fOrigin, anglePos, MASK_PLAYERSOLID, RayType_Infinite, TraceRayNoPlayers, client);
	if (TR_DidHit()) 
	{
		TR_GetEndPosition(fGround);
		fOrigin[2] -= 10.0;
		return GetVectorDistance(fOrigin, fGround);
	}
	return 0.0;
}

public bool TraceRayNoPlayers(int entity, int mask, any data)
{
	if (entity == data || (entity >= 1 && entity <= MaxClients)) 
	{
		return false;
	}
	return true;
}

public void SQL_LoadNPC() 
{
	char mapName[128];
	rp_GetCurrentMap(STRING(mapName));
	
	char buffer[1024];
	Format(STRING(buffer), "SELECT * FROM `rp_entity_permanent` WHERE `map` = '%s';", mapName);
	g_DB.Query(Query_CallBack, buffer);
}

public void Query_CallBack(Handle owner, DBResultSet Results, const char[] error, any data)
{	
	while (Results.FetchRow())
	{
		char uniqueId[128];
		char name[64];
		char type[16];
		char model[256];
		char idle_animation[256];
		char second_animation[256];
		char third_animation[256];
		float pos[3];
		float angles[3];
		SQL_FetchStringByName(Results, "uniqueId", STRING(uniqueId));
		SQL_FetchStringByName(Results, "name", STRING(name));
		SQL_FetchStringByName(Results, "type", STRING(type));
		SQL_FetchStringByName(Results, "model", STRING(model));
		SQL_FetchStringByName(Results, "idle_animation", STRING(idle_animation));
		SQL_FetchStringByName(Results, "second_animation", STRING(second_animation));
		SQL_FetchStringByName(Results, "third_animation", STRING(third_animation));
		pos[0] = SQL_FetchFloatByName(Results, "pos_x");
		pos[1] = SQL_FetchFloatByName(Results, "pos_y");
		pos[2] = SQL_FetchFloatByName(Results, "pos_z");
		angles[0] = SQL_FetchFloatByName(Results, "angle_x");
		angles[1] = SQL_FetchFloatByName(Results, "angle_y");
		angles[2] = SQL_FetchFloatByName(Results, "angle_z");
		
		CreateNpc(uniqueId, name, type, model, idle_animation, second_animation, third_animation, pos, angles);
	}
}

public void CreateNpc(char uniqueId[128], char name[64], char type[16], char model[256], char idle_animation[256], char second_animation[256], char third_animation[256], float pos[3], float angles[3]) 
{
	PrecacheModel(model, true);
	
	int npc = CreateEntityByName("prop_dynamic");
	if (npc == -1)
		return;
	
	g_iNpcList[g_iNpcId].gRefId = EntIndexToEntRef(npc);
	
	DispatchKeyValue(npc, "disablebonefollowers", "1");
	if (!DispatchKeyValue(npc, "solid", "2"))PrintToChatAll("Box Failed");
	DispatchKeyValue(npc, "model", model);
	
	SetEntProp(npc, Prop_Send, "m_nSolidType", 2);
	SetEntProp(npc, Prop_Data, "m_CollisionGroup", COLLISION_GROUP_PUSHAWAY);
	//SetEntPropFloat(npc, Prop_Send, "m_flModelScale", 3.0);
	
	DispatchSpawn(npc);
	
	SetEntPropString(npc, Prop_Data, "m_iName", uniqueId);
	
	TeleportEntity(npc, pos, angles, NULL_VECTOR);
	
	strcopy(g_iNpcList[g_iNpcId].gUniqueId, 128, uniqueId);
	strcopy(g_iNpcList[g_iNpcId].gName, 128, name);
	g_iNpcList[g_iNpcId].iType = StringToInt(type);
	strcopy(g_iNpcList[g_iNpcId].gIdleAnimation, 256, idle_animation);
	strcopy(g_iNpcList[g_iNpcId].gSecondAnimation, 256, second_animation);
	strcopy(g_iNpcList[g_iNpcId].gThirdAnimation, 256, third_animation);
	
	char entityName[128];
	if (StrEqual(name, ""))
		Format(STRING(entityName), "%i", g_iNpcId);
	else
		Format(STRING(entityName), "%s", name);
	Entity_SetGlobalName(npc, entityName);
	g_iNpcId++;
	
	SetVariantString(idle_animation);
	AcceptEntityInput(npc, "SetAnimation");
}

public void onNpcInteract(int client, char uniqueId[128], int entIndex) 
{
	int id;
	if ((id = getNpcLoadedIdFromUniqueId(uniqueId)) == -1)
		return;
		
	Call_StartForward(Forward.OnInteract); 
	Call_PushCell(client);
	Call_PushCell(entIndex);
	Call_PushCell(g_iNpcList[id].iType);
	Call_Finish();
	
	char name[64];
	Entity_GetGlobalName(entIndex, STRING(name));
	
	if (!StrEqual(g_iNpcList[id].gSecondAnimation, "") && !g_iNpcList[id].gInAnimation) 
	{
		SetVariantString(g_iNpcList[id].gSecondAnimation);
		AcceptEntityInput(entIndex, "SetAnimation");
		CreateTimer(2.0, setIdleAnimation, EntIndexToEntRef(entIndex));
		g_iNpcList[id].gInAnimation = true;
	}
}

public Action setIdleAnimation(Handle Timer, int entRef) 
{
	int ent = EntRefToEntIndex(entRef);
	int id;
	if ((id = getNpcLoadedIdFromRef(entRef)) == -1)
		return;
	SetVariantString(g_iNpcList[id].gIdleAnimation);
	AcceptEntityInput(ent, "SetAnimation");
	g_iNpcList[id].gInAnimation = false;
}

stock int getNpcLoadedIdFromUniqueId(char uniqueId[128]) 
{
	for (int i = 0; i < g_iNpcId; i++) 
	{
		if (StrEqual(g_iNpcList[i].gUniqueId, uniqueId))
			return i;
	}
	return -1;
}

stock int getNpcLoadedIdFromRef(int entRef) 
{
	for (int i = 0; i < g_iNpcId; i++) 
	{
		if (g_iNpcList[i].gRefId == entRef)
			return i;
	}
	return -1;
}