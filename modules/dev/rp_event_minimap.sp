/*
*   Roleplay CS:GO de Benito est mis à disposition selon les termes de la licence Creative Commons Attribution .
* - Pas d’Utilisation Commerciale 
* - Partage dans les Mêmes Conditions 4.0 International.
*
*   Fondé(e) sur une œuvre à https://github.com/Benito1020/Roleplay-CS-GO
*   Les autorisations au-delà du champ de cette licence peuvent être obtenues à https://steamcommunity.com/id/xsuprax/.
*
*   Merci de respecter le travail fourni par le ou les auteurs 
*   https://vr-hosting.fr - benitalpa1020@gmail.com
*/

/***************************************************************************************

							C O M P I L E  -  O P T I O N S

***************************************************************************************/
#pragma semicolon 1
#pragma newdecls required

/***************************************************************************************

							P L U G I N  -  I N C L U D E S

***************************************************************************************/
#include <sourcemod>
#include <sdktools>
#include <roleplay>
#include <multicolors>
#include <smlib>

/***************************************************************************************

							G L O B A L  -  V A R S

***************************************************************************************/
#define MAX_PROPS 512

char eventNameDB[64];

enum struct GlobalNpcProperties {
	int gRefId;
	char gUniqueId[128];
	char gName[256];
}

int g_iNpcId = 0;
GlobalNpcProperties g_iNpcList[MAX_PROPS];

enum struct NpcEdit {
	int nNpcId;
	bool nWaitingForModelName;
	bool nWaitingForIdleAnimationName;
	bool nWaitingForName;
}

NpcEdit g_eNpcEdit[MAXPLAYERS + 1];

/***************************************************************************************

							P L U G I N  -  I N F O

***************************************************************************************/
public Plugin myinfo = 
{
	name = "[Roleplay] Minimap", 
	author = "Benito", 
	description = "Spawn une minimap préconfigurée selon l'event", 
	version = VERSION,
	url = URL
};


/***************************************************************************************

							P L U G I N  -  E V E N T S

***************************************************************************************/
public void OnPluginStart()
{
	RegConsoleCmd("rp_minimap", Cmd_SpawnProp);
	RegConsoleCmd("rp_editminimap", Cmd_EditProp);
	RegConsoleCmd("rp_loadminimap", Cmd_LoadMinimap);
	
	RegConsoleCmd("say", chatHook);
	
	HookEvent("round_start", onRoundStart);
}

public Action Cmd_LoadMinimap(int client, int args)
{
	char arg[64];
	GetCmdArg(1, STRING(arg));
	LoadProps(arg);
}	

public void RP_OnDatabaseLoaded(Database db)
{
	char createTableQuery[4096];
	Format(STRING(createTableQuery), 
	  "CREATE TABLE IF NOT EXISTS `rp_minimap` ( \
	  `id` int(11) NOT NULL AUTO_INCREMENT, \
	  `uniqueId` varchar(128) COLLATE utf8_bin NOT NULL, \
	  `name` varchar(64) COLLATE utf8_bin NOT NULL, \
	  `map` varchar(128) COLLATE utf8_bin NOT NULL, \
	  `model` varchar(256) COLLATE utf8_bin NOT NULL, \
	  `pos_x` float NOT NULL, \
	  `pos_y` float NOT NULL, \
	  `pos_z` float NOT NULL, \
	  `angle_x` float NOT NULL, \
	  `angle_y` float NOT NULL, \
	  `angle_z` float NOT NULL, \
	  `created_by` varchar(128) COLLATE utf8_bin NOT NULL, \
	  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP, \
	  PRIMARY KEY (`id`) \
	  )ENGINE = InnoDB DEFAULT CHARSET = utf8 COLLATE = utf8_bin;");
	
	rp_GetDatabase().Query(SQLErrorCheckCallback, createTableQuery);
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) {
	CreateNative("rp_InitEventMinimap", Native_InitEventMinimap);
}

public int Native_InitEventMinimap(Handle plugin, int numParams) 
{
	char eventtype[64];
	GetNativeString(1, STRING(eventtype));
	
	LoadProps(eventtype);
}

public void LoadProps(char eventName[64]) {
	char mapName[128];
	rp_GetCurrentMap(mapName);
	
	char LoadPropsQuery[1024];
	Format(STRING(LoadPropsQuery), "SELECT * FROM rp_minimap WHERE map = '%s' AND name = '%s';", mapName, eventName);
	rp_GetDatabase().Query(QueryCallback, LoadPropsQuery);
}


public void QueryCallback(Database db, DBResultSet Results, const char[] error, any data) 
{
	while (Results.FetchRow()) 
	{
		char name[64];
		SQL_FetchStringByName(Results, "name", STRING(name));
		
		char model[256];
		SQL_FetchStringByName(Results, "model", STRING(model));
		
		char uniqueId[128];
		SQL_FetchStringByName(Results, "uniqueId", STRING(uniqueId));
		
		float pos[3];
		pos[0] = SQL_FetchFloatByName(Results, "pos_x");
		pos[1] = SQL_FetchFloatByName(Results, "pos_y");
		pos[2] = SQL_FetchFloatByName(Results, "pos_z");
		
		float angles[3];
		angles[0] = SQL_FetchFloatByName(Results, "angle_x");
		angles[1] = SQL_FetchFloatByName(Results, "angle_y");
		angles[2] = SQL_FetchFloatByName(Results, "angle_z");
		
		CreateNpc(uniqueId, name, model, pos, angles);
	}
}

public void resetNpcEdit(int client) 
{
	g_eNpcEdit[client].nNpcId = -1;
}

public Action Cmd_EditProp(int client, int args) 
{
	int TargetObject = GetTargetBlock(client);
	if (TargetObject == -1) 
	{
		ReplyToCommand(client, "Invalid target");
		return Plugin_Handled;
	}
	
	g_eNpcEdit[client].nNpcId = TargetObject;
	rp_SetClientBool(client, b_menuOpen, true);
	
	Menu menu = new Menu(editMenuHandler);
	char menuTitle[255];
	char entityName[256];
	Entity_GetGlobalName(TargetObject, STRING(entityName));
	Format(menuTitle, sizeof(menuTitle), "Modification en cours (%s)", entityName);
	menu.SetTitle(menuTitle);
	menu.AddItem("position", "Modifier la position");
	menu.AddItem("angles", "Modifier les angles");
	menu.AddItem("name", "Modifier le nom");
	menu.AddItem("base", "Modifier les propriétés");
	menu.AddItem("save", "Sauvegarder le prop dans la BDD");
	menu.AddItem("delete", "Supprimer le prop");
	menu.Display(client, 60);
	
	
	return Plugin_Handled;
}

public int editMenuHandler(Menu menu, MenuAction action, int client, int item) 
{
	if (action == MenuAction_Select) 
	{
		char cValue[32];
		menu.GetItem(item, cValue, sizeof(cValue));
		if (StrEqual(cValue, "position")) 
		{
			openPositionMenu(client);
		} 
		else if (StrEqual(cValue, "angles")) 
		{
			openAnglesMenu(client);
		} 
		else if (StrEqual(cValue, "base")) 
		{
			openBasePropertyMenu(client);
		} 
		else if (StrEqual(cValue, "delete")) 
		{
			char npcUniqueId[128];
			GetEntPropString(g_eNpcEdit[client].nNpcId, Prop_Data, "m_iName", STRING(npcUniqueId));
			
			char removeNpcQuery[512];
			Format(removeNpcQuery, sizeof(removeNpcQuery), "DELETE FROM rp_minimap WHERE uniqueId = '%s'", npcUniqueId);
			rp_GetDatabase().Query(SQLErrorCheckCallback, removeNpcQuery);
			if (IsValidEntity(g_eNpcEdit[client].nNpcId))
				AcceptEntityInput(g_eNpcEdit[client].nNpcId, "kill");
		} 
		else if (StrEqual(cValue, "name")) 
		{
			g_eNpcEdit[client].nWaitingForName = true;
			PrintToChat(client, "Enter the new Name OR 'abort' to cancel");
		} 
		else if (StrEqual(cValue, "save")) 
		{
			for (int i = MaxClients; i <= MAXENTITIES; i++)
			{
				if (IsValidEntity(i))
				{
					char entName[64];
					Entity_GetName(i, entName, sizeof(entName));
					
					if(StrContains(entName, "prop;") != -1)
					{
						char modelName[256];
						GetEntPropString(i, Prop_Data, "m_ModelName", modelName, 256);
						
						int npc = CreateEntityByName("prop_dynamic_override");
			
						g_iNpcList[g_iNpcId].gRefId = EntIndexToEntRef(npc);
						
						float pos[3];
						GetEntPropVector(i, Prop_Send, "m_vecOrigin", pos);
						
						float angles[3];
						GetEntPropVector(i, Prop_Data, "m_angRotation", angles); 
						
						char uniqueId[128];
						//int uniqueIdTime = GetTime();
						IntToString(GetRandomInt(1, MAXENTITIES), STRING(uniqueId));
						
						char mapName[128], mapPart[3][64];
						GetCurrentMap(mapName, sizeof(mapName));
						ExplodeString(mapName, "/", mapPart, 3, 64);
						
						char playerid[20];
						GetClientAuthId(client, AuthId_Steam2, playerid, sizeof(playerid));
						
						char createdBy[128];
						Format(createdBy, sizeof(createdBy), "%s %N", playerid, client);
						
						char insertNpcQuery[4096];
						Format(insertNpcQuery, sizeof(insertNpcQuery), "INSERT INTO `rp_minimap` (`id`, `uniqueId`, `name`, `map`, `model`, `pos_x`, `pos_y`, `pos_z`, `angle_x`, `angle_y`, `angle_z`, `created_by`, `timestamp`) VALUES (NULL, '%s', '%s', '%s', '%s', '%.2f', '%.2f', '%.2f', '%.2f', '%.2f', '%.2f', '%s', CURRENT_TIMESTAMP);", entName, eventNameDB, mapPart[2], modelName, pos[0], pos[1], pos[2], angles[0], angles[1], angles[2], createdBy);
						PrintToServer(insertNpcQuery);
						CPrintToChat(client, insertNpcQuery);
						rp_GetDatabase().Query(SQLErrorCheckCallback, insertNpcQuery);
					}	
				}	
			}	
		}
	}
	if (action == MenuAction_End) 
	{
		delete menu;
		rp_SetClientBool(client, b_menuOpen, false);
	}
}

public void openPositionMenu(int client) 
{
	rp_SetClientBool(client, b_menuOpen, true);
	Menu menu = new Menu(editPositionMenuHandler);
	char menuTitle[255];
	char entityName[256];
	Entity_GetGlobalName(g_eNpcEdit[client].nNpcId, entityName, sizeof(entityName));
	Format(menuTitle, sizeof(menuTitle), "Edit Position of %s", entityName);
	menu.SetTitle(menuTitle);
	menu.AddItem("up", "Move Up");
	menu.AddItem("down", "Move Down");
	menu.AddItem("xPlus", "Move X Plus");
	menu.AddItem("xMinus", "Move X Minus");
	menu.AddItem("yPlus", "Move Y Plus");
	menu.AddItem("yMinus", "Move Y Minus");
	menu.AddItem("ground", "Put on Ground");
	menu.AddItem("tpYourself", "Teleport to yourself");
	menu.Display(client, 60);
}

public int editPositionMenuHandler(Menu menu, MenuAction action, int client, int item) 
{
	if (action == MenuAction_Select) 
	{
		char cValue[32];
		float pos[3];
		char npcUniqueId[128];
		GetEntPropString(g_eNpcEdit[client].nNpcId, Prop_Data, "m_iName", npcUniqueId, sizeof(npcUniqueId));
		menu.GetItem(item, cValue, sizeof(cValue));
		if (StrEqual(cValue, "up")) 
		{
			GetEntPropVector(g_eNpcEdit[client].nNpcId, Prop_Data, "m_vecOrigin", pos);
			pos[2] += 10;
			TeleportEntity(g_eNpcEdit[client].nNpcId, pos, NULL_VECTOR, NULL_VECTOR);
			openPositionMenu(client);
			char updatePositionQuery[512];
			Format(updatePositionQuery, sizeof(updatePositionQuery), "UPDATE rp_minimap SET pos_z = '%.2f' WHERE uniqueId = '%s'", pos[2], npcUniqueId);
			rp_GetDatabase().Query(SQLErrorCheckCallback, updatePositionQuery);
		} 
		else if (StrEqual(cValue, "down")) 
		{
			GetEntPropVector(g_eNpcEdit[client].nNpcId, Prop_Data, "m_vecOrigin", pos);
			pos[2] -= 10;
			TeleportEntity(g_eNpcEdit[client].nNpcId, pos, NULL_VECTOR, NULL_VECTOR);
			openPositionMenu(client);
			char updatePositionQuery[512];
			Format(updatePositionQuery, sizeof(updatePositionQuery), "UPDATE rp_minimap SET pos_z = '%.2f' WHERE uniqueId = '%s'", pos[2], npcUniqueId);
			rp_GetDatabase().Query(SQLErrorCheckCallback, updatePositionQuery);
		} 
		else if (StrEqual(cValue, "ground")) 
		{
			GetEntPropVector(g_eNpcEdit[client].nNpcId, Prop_Data, "m_vecOrigin", pos);
			pos[2] -= GetClientDistanceToGround(client);
			TeleportEntity(g_eNpcEdit[client].nNpcId, pos, NULL_VECTOR, NULL_VECTOR);
			openPositionMenu(client);
			char updatePositionQuery[512];
			Format(updatePositionQuery, sizeof(updatePositionQuery), "UPDATE rp_minimap SET pos_z = '%.2f' WHERE uniqueId = '%s'", pos[2], npcUniqueId);
			rp_GetDatabase().Query(SQLErrorCheckCallback, updatePositionQuery);
		} 
		else if (StrEqual(cValue, "tpYourself")) 
		{
			float selfPos[3];
			GetClientAbsOrigin(client, selfPos);
			TeleportEntity(g_eNpcEdit[client].nNpcId, selfPos, NULL_VECTOR, NULL_VECTOR);
			openPositionMenu(client);
			char updatePositionQuery[512];
			Format(updatePositionQuery, sizeof(updatePositionQuery), "UPDATE rp_minimap SET pos_x = '%.2f' WHERE uniqueId = '%s'", selfPos[0], npcUniqueId);
			rp_GetDatabase().Query(SQLErrorCheckCallback, updatePositionQuery);
			Format(updatePositionQuery, sizeof(updatePositionQuery), "UPDATE rp_minimap SET pos_y = '%.2f' WHERE uniqueId = '%s'", selfPos[1], npcUniqueId);
			rp_GetDatabase().Query(SQLErrorCheckCallback, updatePositionQuery);
			Format(updatePositionQuery, sizeof(updatePositionQuery), "UPDATE rp_minimap SET pos_z = '%.2f' WHERE uniqueId = '%s'", selfPos[2], npcUniqueId);
			rp_GetDatabase().Query(SQLErrorCheckCallback, updatePositionQuery);
		} 
		else if (StrEqual(cValue, "xPlus")) 
		{
			GetEntPropVector(g_eNpcEdit[client].nNpcId, Prop_Data, "m_vecOrigin", pos);
			pos[0] += 10;
			TeleportEntity(g_eNpcEdit[client].nNpcId, pos, NULL_VECTOR, NULL_VECTOR);
			openPositionMenu(client);
			char updatePositionQuery[512];
			Format(updatePositionQuery, sizeof(updatePositionQuery), "UPDATE rp_minimap SET pos_x = '%.2f' WHERE uniqueId = '%s'", pos[0], npcUniqueId);
			rp_GetDatabase().Query(SQLErrorCheckCallback, updatePositionQuery);
		} 
		else if (StrEqual(cValue, "xMinus")) 
		{
			GetEntPropVector(g_eNpcEdit[client].nNpcId, Prop_Data, "m_vecOrigin", pos);
			pos[0] -= 10;
			TeleportEntity(g_eNpcEdit[client].nNpcId, pos, NULL_VECTOR, NULL_VECTOR);
			openPositionMenu(client);
			char updatePositionQuery[512];
			Format(updatePositionQuery, sizeof(updatePositionQuery), "UPDATE rp_minimap SET pos_x = '%.2f' WHERE uniqueId = '%s'", pos[0], npcUniqueId);
			rp_GetDatabase().Query(SQLErrorCheckCallback, updatePositionQuery);
		} 
		else if (StrEqual(cValue, "yPlus")) 
		{
			GetEntPropVector(g_eNpcEdit[client].nNpcId, Prop_Data, "m_vecOrigin", pos);
			pos[1] += 10;
			TeleportEntity(g_eNpcEdit[client].nNpcId, pos, NULL_VECTOR, NULL_VECTOR);
			openPositionMenu(client);
			char updatePositionQuery[512];
			Format(updatePositionQuery, sizeof(updatePositionQuery), "UPDATE rp_minimap SET pos_y = '%.2f' WHERE uniqueId = '%s'", pos[1], npcUniqueId);
			rp_GetDatabase().Query(SQLErrorCheckCallback, updatePositionQuery);
		} 
		else if (StrEqual(cValue, "yMinus")) 
		{
			GetEntPropVector(g_eNpcEdit[client].nNpcId, Prop_Data, "m_vecOrigin", pos);
			pos[1] -= 10;
			TeleportEntity(g_eNpcEdit[client].nNpcId, pos, NULL_VECTOR, NULL_VECTOR);
			openPositionMenu(client);
			char updatePositionQuery[512];
			Format(updatePositionQuery, sizeof(updatePositionQuery), "UPDATE rp_minimap SET pos_y = '%.2f' WHERE uniqueId = '%s'", pos[1], npcUniqueId);
			rp_GetDatabase().Query(SQLErrorCheckCallback, updatePositionQuery);
		}
	}
	if (action == MenuAction_End) 
	{
		delete menu;
		rp_SetClientBool(client, b_menuOpen, false);
	}
}

public void openAnglesMenu(int client) 
{
	rp_SetClientBool(client, b_menuOpen, true);
	Menu menu = new Menu(editAnglesMenuHandler);
	char menuTitle[255];
	char entityName[256];
	Entity_GetGlobalName(g_eNpcEdit[client].nNpcId, entityName, sizeof(entityName));
	Format(menuTitle, sizeof(menuTitle), "Editer les angles de %s", entityName);
	menu.SetTitle(menuTitle);
	menu.AddItem("yourself", "Définir votre angle");
	menu.AddItem("yourselfInverted", "Définir votre angle contraire");
	menu.AddItem("minus", "Rajouter de l'angle");
	menu.AddItem("plus", "Retirer de l'angle");
	menu.Display(client, 60);
}

public int editAnglesMenuHandler(Menu menu, MenuAction action, int client, int item) 
{
	if (action == MenuAction_Select) 
	{
		char cValue[32];
		float angles[3];
		char npcUniqueId[128];
		if (g_eNpcEdit[client].nNpcId == -1)
			return;
		GetEntPropString(g_eNpcEdit[client].nNpcId, Prop_Data, "m_iName", npcUniqueId, sizeof(npcUniqueId));
		menu.GetItem(item, cValue, sizeof(cValue));
		if (StrEqual(cValue, "plus")) 
		{
			GetEntPropVector(g_eNpcEdit[client].nNpcId, Prop_Data, "m_angRotation", angles);
			angles[1] += 5;
			TeleportEntity(g_eNpcEdit[client].nNpcId, NULL_VECTOR, angles, NULL_VECTOR);
			openAnglesMenu(client);
			char updateAnglesQuery[512];
			Format(updateAnglesQuery, sizeof(updateAnglesQuery), "UPDATE rp_minimap SET angle_y = '%.2f' WHERE uniqueId = '%s'", angles[1], npcUniqueId);
			rp_GetDatabase().Query(SQLErrorCheckCallback, updateAnglesQuery);
		} 
		else if (StrEqual(cValue, "minus")) 
		{
			GetEntPropVector(g_eNpcEdit[client].nNpcId, Prop_Data, "m_angRotation", angles);
			angles[1] -= 5;
			TeleportEntity(g_eNpcEdit[client].nNpcId, NULL_VECTOR, angles, NULL_VECTOR);
			openAnglesMenu(client);
			char updateAnglesQuery[512];
			Format(updateAnglesQuery, sizeof(updateAnglesQuery), "UPDATE rp_minimap SET angle_y = '%.2f' WHERE uniqueId = '%s'", angles[1], npcUniqueId);
			rp_GetDatabase().Query(SQLErrorCheckCallback, updateAnglesQuery);
		} 
		else if (StrEqual(cValue, "yourself")) 
		{
			float selfAngles[3];
			GetClientAbsAngles(client, selfAngles);
			TeleportEntity(g_eNpcEdit[client].nNpcId, NULL_VECTOR, selfAngles, NULL_VECTOR);
			openAnglesMenu(client);
			char updateAnglesQuery[512];
			Format(updateAnglesQuery, sizeof(updateAnglesQuery), "UPDATE rp_minimap SET angle_x = '%.2f' WHERE uniqueId = '%s'", selfAngles[0], npcUniqueId);
			rp_GetDatabase().Query(SQLErrorCheckCallback, updateAnglesQuery);
			Format(updateAnglesQuery, sizeof(updateAnglesQuery), "UPDATE rp_minimap SET angle_y = '%.2f' WHERE uniqueId = '%s'", selfAngles[1], npcUniqueId);
			rp_GetDatabase().Query(SQLErrorCheckCallback, updateAnglesQuery);
			Format(updateAnglesQuery, sizeof(updateAnglesQuery), "UPDATE rp_minimap SET angle_z = '%.2f' WHERE uniqueId = '%s'", selfAngles[2], npcUniqueId);
			rp_GetDatabase().Query(SQLErrorCheckCallback, updateAnglesQuery);
		} 
		else if (StrEqual(cValue, "yourselfInverted")) 
		{
			float selfAngles[3];
			GetClientAbsAngles(client, selfAngles);
			selfAngles[1] = 180 - selfAngles[1];
			TeleportEntity(g_eNpcEdit[client].nNpcId, NULL_VECTOR, selfAngles, NULL_VECTOR);
			openAnglesMenu(client);
			char updateAnglesQuery[512];
			Format(updateAnglesQuery, sizeof(updateAnglesQuery), "UPDATE rp_minimap SET angle_x = '%.2f' WHERE uniqueId = '%s'", selfAngles[0], npcUniqueId);
			rp_GetDatabase().Query(SQLErrorCheckCallback, updateAnglesQuery);
			Format(updateAnglesQuery, sizeof(updateAnglesQuery), "UPDATE rp_minimap SET angle_y = '%.2f' WHERE uniqueId = '%s'", selfAngles[1], npcUniqueId);
			rp_GetDatabase().Query(SQLErrorCheckCallback, updateAnglesQuery);
			Format(updateAnglesQuery, sizeof(updateAnglesQuery), "UPDATE rp_minimap SET angle_z = '%.2f' WHERE uniqueId = '%s'", selfAngles[2], npcUniqueId);
			rp_GetDatabase().Query(SQLErrorCheckCallback, updateAnglesQuery);
		}
	}
	if (action == MenuAction_End) 
	{
		delete menu;
		rp_SetClientBool(client, b_menuOpen, false);
	}
}

public void openBasePropertyMenu(int client) 
{
	rp_SetClientBool(client, b_menuOpen, true);
	Menu menu = new Menu(editBasePropertyMenuHandler);
	char menuTitle[255];
	char entityName[256];
	Entity_GetGlobalName(g_eNpcEdit[client].nNpcId, entityName, sizeof(entityName));
	Format(menuTitle, sizeof(menuTitle), "Edit Base Properties of %s", entityName);
	menu.SetTitle(menuTitle);
	menu.AddItem("solid", "Make NPC solid");
	menu.AddItem("nonsolid", "Make NPC non-solid");
	menu.Display(client, 60);
}

public int editBasePropertyMenuHandler(Menu menu, MenuAction action, int client, int item) {
	if (action == MenuAction_Select) 
	{
		char cValue[32];
		menu.GetItem(item, cValue, sizeof(cValue));
		if (StrEqual(cValue, "solid")) 
		{
			SetEntProp(g_eNpcEdit[client].nNpcId, Prop_Send, "m_nSolidType", 6);
			openBasePropertyMenu(client);
		} 
		else if (StrEqual(cValue, "nonsolid")) 
		{
			SetEntProp(g_eNpcEdit[client].nNpcId, Prop_Send, "m_nSolidType", 0);
			openBasePropertyMenu(client);
		}
	}
	if (action == MenuAction_End) {
		delete menu;
		rp_SetClientBool(client, b_menuOpen, false);
	}
}

public Action Cmd_SpawnProp(int client, int args) 
{
	if(rp_GetClientInt(client, i_AdminLevel) > 2)
	{
		CPrintToChat(client, "%s Vous n'avez pas accès à cette commande.", TEAM);
		return Plugin_Handled;
	}
		
	rp_SetClientBool(client, b_menuOpen, true);
	
	Menu prop = new Menu(DoSpawnProp);	
	prop.SetTitle("Roleplay - MiniMap");	
	
	prop.AddItem("", "-- Grillages --", ITEMDRAW_DISABLED);
	prop.AddItem("models/props_c17/fence01a.mdl", "Grillage v1-A");
	prop.AddItem("models/props_c17/fence01b.mdl", "Grillage v1-B");
	prop.AddItem("models/props_c17/fence02a.mdl", "Grillage v2-A");
	prop.AddItem("models/props_c17/fence02b.mdl", "Grillage v2-B");
	prop.AddItem("models/props_c17/fence03a.mdl", "Grillage v3");
	prop.AddItem("models/props_c17/fence04a.mdl", "Grillage v4");
	prop.AddItem("", "-- Pierres --", ITEMDRAW_DISABLED);
	prop.AddItem("models/props_canal/rock_riverbed01a.mdl", "Pierres v1");
	prop.AddItem("models/props_canal/rock_riverbed01d.mdl", "Pierres v2");
	prop.AddItem("models/props_canal/rock_riverbed02a.mdl", "Pierres v3");
	prop.AddItem("models/props_canal/rock_riverbed02b.mdl", "Pierres v4");
	prop.AddItem("", "-- Batiments --", ITEMDRAW_DISABLED);
	prop.AddItem("models/props/buildings/detached_house.mdl", "Batiment v1"); // Custom Model
	prop.AddItem("models/props/building/two-storey-house.mdl", "Batiment v2"); // Custom Model
	prop.AddItem("", "-- Autres --", ITEMDRAW_DISABLED);
	prop.AddItem("models/props_docks/piling_cluster01a.mdl", "Pillier v1");
	prop.AddItem("models/props_docks/pylon_cement_368b.mdl", "Pillier v2");
	prop.AddItem("models/props_downtown/booth01.mdl", "Siège v1");
	prop.AddItem("models/props_downtown/booth02.mdl", "Siège v2");
	prop.AddItem("models/props_equipment/cargo_container01.mdl", "Contenair");
	prop.AddItem("models/props_exteriors/wood_porchsteps_02.mdl", "Escaliers en bois");
	prop.AddItem("models/props_foliage/mall_tree_large01.mdl", "Arbre v1");
	prop.AddItem("models/props_foliage/urban_tree_giant01_small.mdl", "Arbre v2");
	prop.AddItem("models/props_fortifications/concrete_wall001_96_reference.mdl", "Murret v1");
	prop.AddItem("models/props_highway/corrugated_panel_01.mdl", "Toit");
	prop.AddItem("models/props_industrial/pallet_stack_96.mdl", "Palettes");
	prop.AddItem("models/props_industrial/warehouse_shelf004.mdl", "Casier de caisses");
	prop.AddItem("models/props_industrial/wire_spool_01.mdl", "Bobine de cable");
	prop.AddItem("models/props_junk/dumpster.mdl", "Poubelle");
	prop.AddItem("models/props_unique/wooden_barricade.mdl", "Barricade en bois");
	prop.AddItem("models/props_unique/subwaycar_cheap.mdl", "Métro");
	prop.AddItem("models/props_urban/wood_fence002_256.mdl", "Barricade en bois v2");
	prop.AddItem("models/props_vehicles/car001b_hatchback.mdl", "Voiture de casse");
	prop.AddItem("models/props_bank/bank_sign_no_guns.mdl", "No Weapons");
	
	prop.ExitButton = true;
	prop.Display(client, MENU_TIME_FOREVER);
	
	return Plugin_Handled;
}

public int DoSpawnProp(Menu menu, MenuAction action, int client, int param) 
{
	if (action == MenuAction_Select)
	{
		char info[256];
		menu.GetItem(param, info, sizeof(info));
		
		//FakeClientCommand(client, "rp_editminimap");
		int npc = CreateEntityByName("prop_dynamic_override");
	
		g_iNpcList[g_iNpcId].gRefId = EntIndexToEntRef(npc);
		float pos[3];
		//GetClientAbsOrigin(client, pos);
		PointVision(client, pos);
		
		float angles[3];
		GetClientAbsAngles(client, angles);
		
		char uniqueId[128];
		int uniqueIdTime = GetTime();
		IntToString(uniqueIdTime, uniqueId, sizeof(uniqueId));
		strcopy(g_iNpcList[g_iNpcId].gUniqueId, 128, uniqueId);
		
		char mapName[128];
		rp_GetCurrentMap(mapName);
		char playerid[20];
		GetClientAuthId(client, AuthId_Steam2, playerid, sizeof(playerid));
		
		char createdBy[128];
		Format(createdBy, sizeof(createdBy), "%s %N", playerid, client);
		
		char insertNpcQuery[4096];
		Format(insertNpcQuery, sizeof(insertNpcQuery), "INSERT INTO `rp_minimap` (`id`, `uniqueId`, `name`, `map`, `model`, `pos_x`, `pos_y`, `pos_z`, `angle_x`, `angle_y`, `angle_z`, `created_by`, `timestamp`) VALUES (NULL, '%s', '', '%s', '%s', '%.2f', '%.2f', '%.2f', '%.2f', '%.2f', '%.2f', '%s', CURRENT_TIMESTAMP);", uniqueId, mapName, info, pos[0], pos[1], pos[2], angles[0], angles[1], angles[2], createdBy);
		rp_GetDatabase().Query(SQLErrorCheckCallback, insertNpcQuery);		
		
		CreateNpc(uniqueId, "", info, pos, angles);
		
		FakeClientCommand(client, "rp_minimap");
	}
	if (action == MenuAction_End) 
	{
		delete menu;
		rp_SetClientBool(client, b_menuOpen, false);
	}
}

stock int GetTargetBlock(int client) 
{
	int entity = GetClientAimTarget(client, false);
	if (IsValidEntity(entity)) 
	{
		char classname[32];
		GetEdictClassname(entity, classname, 32);
		
		if (StrContains(classname, "prop_dynamic") != -1)
			return entity;
	}
	return -1;
}

public Action chatHook(int client, int args) 
{
	char text[1024];
	GetCmdArgString(text, sizeof(text));
	StripQuotes(text);
	
	if (g_eNpcEdit[client].nWaitingForName && StrContains(text, "abort") == -1) 
	{
		SetVariantString(text);
		char entityName[256];
		Format(entityName, sizeof(entityName), "%s", text);
		Entity_SetGlobalName(g_eNpcEdit[client].nNpcId, entityName, sizeof(entityName));
		Format(eventNameDB, sizeof(eventNameDB), "%s", text);
		PrintToChat(client, "Nom de %s défini en %s", entityName, eventNameDB);
		g_eNpcEdit[client].nWaitingForName = false;
		char npcUniqueId[128];
		GetEntPropString(g_eNpcEdit[client].nNpcId, Prop_Data, "m_iName", npcUniqueId, sizeof(npcUniqueId));
		char updateNameQuery[512];
		Format(updateNameQuery, sizeof(updateNameQuery), "UPDATE rp_props SET name = '%s' WHERE uniqueId = '%s'", text, npcUniqueId);
		rp_GetDatabase().Query(SQLErrorCheckCallback, updateNameQuery);
		strcopy(g_iNpcList[g_iNpcId].gName, 128, text);
		return Plugin_Handled;
	} 
	else if ((g_eNpcEdit[client].nWaitingForName) && StrContains(text, "abort") != -1) 
	{
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

public void OnMapStart() 
{
	g_iNpcId = 0;
}	

public void onRoundStart(Event event, const char[] name, bool dontBroadcast) 
{
	g_iNpcId = 0;
}

public void CreateNpc(char uniqueId[128], char name[64], char model[256], float pos[3], float angles[3]) 
{
	PrecacheModel(model, true);
	
	int npc = CreateEntityByName("prop_dynamic_override");
	if (npc == -1)
		return;
	
	g_iNpcList[g_iNpcId].gRefId = EntIndexToEntRef(npc);
	
	DispatchKeyValue(npc, "disablebonefollowers", "1");
	if (!DispatchKeyValue(npc, "solid", "2"))PrintToChatAll("Box Failed");
	DispatchKeyValue(npc, "model", model);
	
	SetEntProp(npc, Prop_Send, "m_nSolidType", SOLID_VPHYSICS);
	
	DispatchSpawn(npc);
	
	SetEntPropString(npc, Prop_Data, "m_iName", uniqueId);
	
	TeleportEntity(npc, pos, angles, NULL_VECTOR);
	
	strcopy(g_iNpcList[g_iNpcId].gUniqueId, 128, uniqueId);
	strcopy(g_iNpcList[g_iNpcId].gName, 128, name);
	
	char entityName[128];
	if (StrEqual(name, ""))
		Format(entityName, sizeof(entityName), "%i", g_iNpcId);
	else
		Format(entityName, sizeof(entityName), "%s", name);
	Entity_SetGlobalName(npc, entityName);
	g_iNpcId++;
}

stock int getNpcLoadedIdFromUniqueId(char uniqueId[128]) 
{
	for (int i = 0; i < g_iNpcId; i++) 
	{
		if (StrEqual(g_iNpcList[i][gUniqueId], uniqueId))
			return i;
	}
	return -1;
}

stock int getNpcLoadedIdFromRef(int entRef) 
{
	for (int i = 0; i < g_iNpcId; i++) 
	{
		if (g_iNpcList[i][gRefId] == entRef)
			return i;
	}
	return -1;
}