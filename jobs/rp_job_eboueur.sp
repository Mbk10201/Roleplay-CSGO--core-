/*
*   Roleplay CS:GO de Benito est mis à disposition selon les termes de la licence Creative Commons Attribution .
* - Pas d’Utilisation Commerciale 
* - Partage dans les Mêmes Conditions 4.0 International.
*
*   Merci de respecter le travail fourni par le ou les auteurs 
*   https://enemy-down.eu - benitalpa1020@gmail.com
*/


/*
	TODO
	
	1. Rajouter le fait de payer le joueur quand il ramasse la poubelle, faire en sorte de payer x$ * le prix d'une poubelle.

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
#define MAX_GARBAGE 1024
#define MAX_IN_GARBAGE 5

/***************************************************************************************

							G L O B A L  -  V A R S

***************************************************************************************/
char g_cTrash[3][64];

int g_iSpeedTimeLeft[MAXPLAYERS + 1];

enum struct garbage {
	float gXPos;
	float gYPos;
	float gZPos;
	bool gIsActive;
}

garbage g_eGarbageSpawnPoints[MAX_GARBAGE];
int g_iLoadedGarbage = 0;
int g_iActiveGarbage = 0;
int g_iBlueGlow;

int g_iBaseGarbageSpawns = 10;
int g_iMaxGarbageSpawns = 20;

ArrayList randomNumbers;

/***************************************************************************************

							P L U G I N  -  I N F O

***************************************************************************************/
public Plugin myinfo = 
{
	name = "Roleplay - [JOB]Eboueur", 
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
	RegConsoleCmd("rp_poubelles", addSpawnPoints);
}

public void OnMapStart()
{
	PrecacheModel("models/props_junk/trashcluster01a_corner.mdl", true);
	PrecacheModel("models/props/de_train/hr_t/trash_c/hr_clothes_pile.mdl", true);
	PrecacheModel("models/props/de_train/hr_t/trash_b/hr_food_pile_02.mdl", true);
	
	strcopy(g_cTrash[0], 64, "models/props_junk/trashcluster01a_corner.mdl");
	strcopy(g_cTrash[1], 64, "models/props/de_train/hr_t/trash_c/hr_clothes_pile.mdl");
	strcopy(g_cTrash[2], 64, "models/props/de_train/hr_t/trash_b/hr_food_pile_02.mdl");
	
	for (int i = 0; i < MAX_GARBAGE; i++) 
	{
		g_eGarbageSpawnPoints[g_iLoadedGarbage].gXPos = -1.0;
		g_eGarbageSpawnPoints[g_iLoadedGarbage].gYPos = -1.0;
		g_eGarbageSpawnPoints[g_iLoadedGarbage].gZPos = -1.0;
		g_eGarbageSpawnPoints[g_iLoadedGarbage].gIsActive = false;
	}
	g_iLoadedGarbage = 0;
	g_iBlueGlow = PrecacheModel("sprites/blueglow1.vmt");
	loadGarbageSpawnPoints();
	InitPoubelles();
}	

public void InitPoubelles() {
	for (int i = 0; i < MAX_GARBAGE; i++) {
		g_eGarbageSpawnPoints[i].gIsActive = false;
	}
	
	randomNumbers = CreateArray(g_iBaseGarbageSpawns, g_iBaseGarbageSpawns);
	ClearArray(randomNumbers);
	for (int i = 0; i < g_iLoadedGarbage; i++) 
	{
		PushArrayCell(randomNumbers, i);
	}
	
	for (int i = 0; i < MAX_GARBAGE; i++) 
	{
		int index1 = GetRandomInt(0, (g_iLoadedGarbage - 1));
		int index2 = GetRandomInt(0, (g_iLoadedGarbage - 1));
		if (GetArraySize(randomNumbers) > 0)
			SwapArrayItems(randomNumbers, index1, index2);
	}
	
	int spawns = 0;
	if (g_iBaseGarbageSpawns > g_iLoadedGarbage)
		spawns = g_iLoadedGarbage;
	else
		spawns = g_iBaseGarbageSpawns;
	for (int i = 0; i < spawns; i++) 
	{
		int spawnId = GetArrayCell(randomNumbers, 0);
		RemoveFromArray(randomNumbers, 0);
		spawnGarbage(spawnId);
	}
}

public void OnClientPutInServer(int client)
{
	rp_SetClientInt(client, i_Trash, 0);
}

public void spawnGarbage(int id) {
	int trashEnt = CreateEntityByName("prop_dynamic_override");
	if (trashEnt == -1)
		return;
	char modelPath[128];
	Format(modelPath, sizeof(modelPath), g_cTrash[GetRandomInt(0, 2)]);
	SetEntityModel(trashEnt, modelPath);
	DispatchKeyValue(trashEnt, "Solid", "2");
	SetEntProp(trashEnt, Prop_Send, "m_nSolidType", 2);
	SetEntProp(trashEnt, Prop_Data, "m_CollisionGroup", COLLISION_GROUP_NONE);
	char cId[8];
	IntToString(id, cId, sizeof(cId));
	SetEntPropString(trashEnt, Prop_Data, "m_iName", cId);
	DispatchSpawn(trashEnt);
	float pos[3];
	pos[0] = g_eGarbageSpawnPoints[id].gXPos;
	pos[1] = g_eGarbageSpawnPoints[id].gYPos;
	pos[2] = g_eGarbageSpawnPoints[id].gZPos;
	TeleportEntity(trashEnt, pos, NULL_VECTOR, NULL_VECTOR);
	Entity_SetGlobalName(trashEnt, "Garbage");
	
	g_eGarbageSpawnPoints[id].gIsActive = true;
	g_iActiveGarbage++;
}

public void RP_ClientTimerEverySecond(int client)
{
	if (g_iSpeedTimeLeft[client] > 0)
		g_iSpeedTimeLeft[client]--;
	else if (g_iSpeedTimeLeft[client] == 0) {
		g_iSpeedTimeLeft[client] = -1;
		removeSpeed(client);
	}
}

public void RP_TimerEverySecond()
{
	if (randomNumbers == INVALID_HANDLE)
		return;

	int active = getActiveGarbage();
	if (active == g_iLoadedGarbage)
		return;
	if (active >= g_iMaxGarbageSpawns)
		return;
	if (active < g_iBaseGarbageSpawns) {
		if (GetArraySize(randomNumbers) > 0) {
			int spawnId = GetArrayCell(randomNumbers, 0);
			RemoveFromArray(randomNumbers, 0);
			spawnGarbage(spawnId);
			return;
		}
	}
	if (active >= g_iBaseGarbageSpawns && active < g_iMaxGarbageSpawns) {
		if (GetArraySize(randomNumbers) > 0) {
			if (GetRandomInt(0, 20) == 7) {
				int spawnId = GetArrayCell(randomNumbers, 0);
				RemoveFromArray(randomNumbers, 0);
				spawnGarbage(spawnId);
			}
		}
	}
}

public void RP_OnClientInteract(int client, int target, const char[] class, const char[] model, const char[] name)
{
	if(rp_GetClientInt(client, i_Job) == 19)
	{
		if (StrEqual(model, g_cTrash[0])
		|| StrEqual(model, g_cTrash[1])
		|| StrEqual(model, g_cTrash[2])) 
		{
			if(rp_GetClientInt(client, i_Trash) != MAX_IN_GARBAGE)
			{
				if(!rp_GetClientSick(client, sick_type_fever) && !rp_GetClientSick(client, sick_type_plague) && !rp_GetClientSick(client, sick_type_covid))
				{
					rp_SetClientInt(client, i_Trash, rp_GetClientInt(client, i_Trash) + 1);
					GarbageTake(client);
					rp_PerformLoadingBar(client, LOADING_SURVIVALPANEL, "Ramassage de poubelles", 2);
					RemoveEdict(target);
					rp_PrintToChat(client, "Vous avez ramassé une poubelle (%i / %i).", rp_GetClientInt(client, i_Trash), MAX_IN_GARBAGE);
				}
				else
					rp_PrintToChat(client, "Vous êtes malade, vous devez y aller vous faire dépister.");		
			}
			else
				rp_PrintToChat(client, "Vous avez atteint la limite de poubelles sur vous.");
		}
		else if (StrEqual(name, "recyclage"))
		{
			if(rp_GetClientInt(client, i_Trash) != 0)
			{
				rp_SetClientBool(client, b_DisplayHud, false);
				Menu menu = new Menu(Handle_MenuRecycle);
				menu.SetTitle("Recyclage Portland\n Poubelles: %i", rp_GetClientInt(client, i_Trash));
				menu.AddItem("in", "Déverser les poubelles");
				menu.ExitButton = true;
				menu.Display(client, MENU_TIME_FOREVER);
			}
			else
				rp_PrintToChat(client, "Vous n'avez pas de poubelles a recycler sur vous.");
		}
	}
}

public int Handle_MenuRecycle(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[64];
		menu.GetItem(param, STRING(info));
		
		if(StrEqual(info, "in"))
		{
			rp_PrintToChat(client, "Vous avez recyclé %i poubelles", rp_GetClientInt(client, i_Trash));
			rp_SetClientInt(client, i_Trash, 0);
		}
		else
			rp_SetClientBool(client, b_DisplayHud, true);
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

void GarbageTake(int client)
{	
	if(!rp_GetClientBool(client, b_HasGlovesProtection))
	{
		int random = GetRandomInt(0, 2);
		
		if(random == 1)
		{
			int type = GetRandomInt(sick_type_fever, sick_type_covid);
			rp_SetClientSick(client, view_as<sick_list>(type), true);
		}	
		
		return;
	}	
	else
	{
		int random = GetRandomInt(0, 1);
		if(random == 0)
		{
			rp_SetClientBool(client, b_HasGlovesProtection, false);
			rp_PrintToChat(client, "Vous avez usée vos gants, aller en reacheter d'autres.");
		}
	}
	
	int id = GetRandomInt(0, 7);
		
	if(id == 3)
	{
		int reward = GetRandomInt(50, 346);
		rp_PrintToChat(client, "Vous avez trouvé %i$ dans les déchets.", reward);
		rp_SetClientInt(client, i_Money, rp_GetClientInt(client, i_Money) + reward);
	}
	else if(id == 5)
	{
		GivePlayerItem(client, "weapon_glock18");
		rp_PrintToChat(client, "Vous avez trouvé une arme de crime.");	
	}	
}

public void removeSpeed(int client) 
{
	if (!IsClientValid(client))
		return;
	if (GetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue") <= 1.0)
		return;
	SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);
}

public void loadGarbageSpawnPoints()
{
	char sPath[PLATFORM_MAX_PATH], map[64];
	rp_GetCurrentMap(STRING(map));
	BuildPath(Path_SM, sPath, sizeof(sPath), "data/roleplay/%s/poubelles.cfg", map);
	
	Handle hFile = OpenFile(sPath, "r");
	
	char sBuffer[512];
	char sDatas[3][32];
	
	if (hFile != INVALID_HANDLE)
	{
		while (ReadFileLine(hFile, sBuffer, sizeof(sBuffer)))
		{
			ExplodeString(sBuffer, ";", sDatas, 3, 32);
			
			g_eGarbageSpawnPoints[g_iLoadedGarbage].gXPos = StringToFloat(sDatas[0]);
			g_eGarbageSpawnPoints[g_iLoadedGarbage].gYPos = StringToFloat(sDatas[1]);
			g_eGarbageSpawnPoints[g_iLoadedGarbage].gZPos = StringToFloat(sDatas[2]);
			
			g_iLoadedGarbage++;
		}
		
		delete hFile;
	}
	PrintToServer("Chargement de %i spawn de poubelles", g_iLoadedGarbage);
}

public void saveGarbageSpawnPoints()
{
	char map[64];
	rp_GetCurrentMap(STRING(map));
	
	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPath, sizeof(sPath), "data/roleplay/%s/poubelles.cfg", map);
	
	Handle hFile = OpenFile(sPath, "w");
	
	if (hFile != INVALID_HANDLE)
	{
		for (int i = 0; i < g_iLoadedGarbage; i++) {
			WriteFileLine(hFile, "%.2f;%.2f;%.2f;", g_eGarbageSpawnPoints[i].gXPos, g_eGarbageSpawnPoints[i].gYPos, g_eGarbageSpawnPoints[i].gZPos);
		}
		
		delete hFile;
	}
	
	if (!FileExists(sPath))
		LogError("Couldn't save item spawns to  file: \"%s\".", sPath);
}

public void AddLootSpawn(int client)
{
	float pos[3];
	GetClientAbsOrigin(client, pos);
	
	TE_SetupGlowSprite(pos, g_iBlueGlow, 10.0, 1.0, 235);
	TE_SendToAll();
	
	g_eGarbageSpawnPoints[g_iLoadedGarbage].gXPos = pos[0];
	g_eGarbageSpawnPoints[g_iLoadedGarbage].gYPos = pos[1];
	g_eGarbageSpawnPoints[g_iLoadedGarbage].gZPos = pos[2];
	g_iLoadedGarbage++;
	
	CPrintToChat(client, "Ajout d'une poubelle à la position %.2f:%.2f:%.2f", pos[0], pos[1], pos[2]);
	saveGarbageSpawnPoints();
}


public Action addSpawnPoints(int client, int args) 
{
	if(client == 0)
	{
		PrintToServer("Commande disponible uniquement en jeu");
		return Plugin_Handled;
	}
	else if(rp_GetAdmin(client) == ADMIN_FLAG_NONE)
	{
		CPrintToServer("Vous n'avez pas accès à cette commande.");
		return Plugin_Handled;
	}
	
	MenuAddSpawnPoints(client);
	return Plugin_Handled;
}

void MenuAddSpawnPoints(int client)
{
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(HandlePoubelleSpawn);
	menu.SetTitle("Spawn: Poubelles (Total: %i)", g_iLoadedGarbage);
	menu.AddItem("add", "Ajouter un spawn");
	menu.AddItem("show", "Afficher les spawn");
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int HandlePoubelleSpawn(Menu menu, MenuAction action, int client, int param) 
{
	if (action == MenuAction_Select) 
	{
		char info[64];
		menu.GetItem(param, STRING(info));
		
		if (StrEqual(info, "add")) 
		{
			AddLootSpawn(client);
			MenuAddSpawnPoints(client);
		} 
		else if (StrEqual(info, "show")) 
		{
			ShowSpawns();
			MenuAddSpawnPoints(client);
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

void ShowSpawns() 
{
	for (int i = 0; i < g_iLoadedGarbage; i++) 
	{
		float pos[3];
		pos[0] = g_eGarbageSpawnPoints[i].gXPos;
		pos[1] = g_eGarbageSpawnPoints[i].gYPos;
		pos[2] = g_eGarbageSpawnPoints[i].gZPos;
		TE_SetupGlowSprite(pos, g_iBlueGlow, 10.0, 1.0, 235);
		TE_SendToAll();
	}
}

public int getActiveGarbage() 
{
	int count = 0;
	for (int i = 0; i < g_iLoadedGarbage; i++)
	{
		if (g_eGarbageSpawnPoints[i].gIsActive)
			count++;
	}
	return count;
}

public void OnClientPostAdminCheck(int client) 
{
	resetAmountVars();
	g_iSpeedTimeLeft[client] = -1;
}

public void resetAmountVars() {
	int amount;
	if ((amount = GetRealClientCount()) != 0) {
		g_iMaxGarbageSpawns = amount;
		amount /= 3;
		g_iBaseGarbageSpawns = amount <= 3 ? 3:amount;
	} else {
		g_iBaseGarbageSpawns = 1;
		g_iMaxGarbageSpawns = 5;
	}
}

public int GetRealClientCount() {
	int total = 0;
	LoopClients(i)
		if (IsClientConnected(i) && !IsFakeClient(i))
			total++;
	return total;
} 