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
	
	1. Rajouter les minéraux (Or, Metal, Cuivre, Aliminium, Zinc, Bois, Plastique, Eau)
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

#define MAX_MINERAL 16

/***************************************************************************************

							P L U G I N  -  I N F O

***************************************************************************************/
public Plugin myinfo = 
{
	name = "Roleplay - [MODULE]Resource", 
	author = "MBK", 
	description = "", 
	version = "1.0", 
	url = "https://github.com/Mbk10201"
};

char g_cTrash[3][64];
int g_iSpeedTimeLeft[MAXPLAYERS + 1];

enum struct garbage {
	float gXPos;
	float gYPos;
	float gZPos;
	bool gIsActive;
}

garbage MineralSpawnPoints[MAX_MINERAL];
int g_iLoadedGarbage = 0;
int g_iActiveGarbage = 0;
int g_iBlueGlow;

int g_iBaseGarbageSpawns = 10;
int g_iMaxGarbageSpawns = 20;

ArrayList randomNumbers;


/***************************************************************************************

							P L U G I N  -  E V E N T S

***************************************************************************************/
public void OnPluginStart()
{
	LoadTranslation();
	RegConsoleCmd("rp_minerals", Command_SpawnPoints);
	RegConsoleCmd("rp_giveresource", Command_GiveResource);
}

public void OnMapStart()
{
	char sModel[128];
	
	rp_GetGlobalData("model_crystal1", STRING(sModel));
	strcopy(g_cTrash[0], 64, sModel);
	
	rp_GetGlobalData("model_crystal2", STRING(sModel));
	strcopy(g_cTrash[1], 64, sModel);
	
	rp_GetGlobalData("model_crystal3", STRING(sModel));
	strcopy(g_cTrash[2], 64, sModel);
	
	for (int i = 0; i < MAX_MINERAL; i++) 
	{
		MineralSpawnPoints[g_iLoadedGarbage].gXPos = -1.0;
		MineralSpawnPoints[g_iLoadedGarbage].gYPos = -1.0;
		MineralSpawnPoints[g_iLoadedGarbage].gZPos = -1.0;
		MineralSpawnPoints[g_iLoadedGarbage].gIsActive = false;
	}
	g_iLoadedGarbage = 0;
	g_iBlueGlow = PrecacheModel("sprites/blueglow1.vmt");
	LoadMineralSpawnPoints();
	InitPoubelles();
}	

public void InitPoubelles() 
{
	for (int i = 0; i < MAX_MINERAL; i++) 
	{
		MineralSpawnPoints[i].gIsActive = false;
	}
	
	randomNumbers = CreateArray(g_iBaseGarbageSpawns, g_iBaseGarbageSpawns);
	ClearArray(randomNumbers);
	for (int i = 0; i < g_iLoadedGarbage; i++) 
	{
		PushArrayCell(randomNumbers, i);
	}
	
	for (int i = 0; i < MAX_MINERAL; i++) 
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
		SpawnMineral(spawnId);
	}
}

public void OnClientPutInServer(int client)
{
	rp_SetClientResource(client, resource_gold, 0);
	rp_SetClientResource(client, resource_steel, 0);
	rp_SetClientResource(client, resource_copper, 0);
	rp_SetClientResource(client, resource_aluminium, 0);
	rp_SetClientResource(client, resource_zinc, 0);
	rp_SetClientResource(client, resource_wood, 0);
	rp_SetClientResource(client, resource_plastic, 0);
	rp_SetClientResource(client, resource_water, 0);
}

public void SpawnMineral(int id) 
{
	char modelPath[128];
	Format(STRING(modelPath), g_cTrash[GetRandomInt(0, 2)]);
	
	int trashEnt;  
	if(rp_GetGame() == Engine_CSGO)
		trashEnt = CreateGlow(modelPath, "0 255 0");
	else
		trashEnt = CreateEntityByName("prop_dynamic_override");
	if (trashEnt == -1)
		return;
		
	SetEntProp(trashEnt, Prop_Send, "m_nSkin", GetRandomInt(0, 8));	
	
	char cId[8];
	IntToString(id, cId, sizeof(cId));
	SetEntPropString(trashEnt, Prop_Data, "m_iName", cId);
	DispatchSpawn(trashEnt);
	
	float pos[3];
	pos[0] = MineralSpawnPoints[id].gXPos;
	pos[1] = MineralSpawnPoints[id].gYPos;
	pos[2] = MineralSpawnPoints[id].gZPos;
	TeleportEntity(trashEnt, pos, vfloat({0.0, 0.0, 75.0}), NULL_VECTOR);
	Entity_SetGlobalName(trashEnt, "Mineral");
	
	MineralSpawnPoints[id].gIsActive = true;
	g_iActiveGarbage++;
}

public void RP_TimerEverySecond()
{
	LoopClients(i)
	{
		if(!IsClientValid(i))
			continue;
		
		if (g_iSpeedTimeLeft[i] > 0)
			g_iSpeedTimeLeft[i]--;
		else if (g_iSpeedTimeLeft[i] == 0) 
		{
			g_iSpeedTimeLeft[i] = -1;
		}
	}
	
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
			SpawnMineral(spawnId);
			return;
		}
	}
	if (active >= g_iBaseGarbageSpawns && active < g_iMaxGarbageSpawns) {
		if (GetArraySize(randomNumbers) > 0) {
			if (GetRandomInt(0, 20) == 7) {
				int spawnId = GetArrayCell(randomNumbers, 0);
				RemoveFromArray(randomNumbers, 0);
				SpawnMineral(spawnId);
			}
		}
	}
}

public void LoadMineralSpawnPoints()
{
	char sPath[PLATFORM_MAX_PATH], map[64];
	rp_GetCurrentMap(STRING(map));
	BuildPath(Path_SM, sPath, sizeof(sPath), "data/roleplay/%s/minerals.cfg", map);
	
	Handle hFile = OpenFile(sPath, "r");
	
	char sBuffer[512];
	char sDatas[3][32];
	
	if (hFile != INVALID_HANDLE)
	{
		while (ReadFileLine(hFile, STRING(sBuffer)))
		{
			ExplodeString(sBuffer, ";", sDatas, 3, 32);
			
			MineralSpawnPoints[g_iLoadedGarbage].gXPos = StringToFloat(sDatas[0]);
			MineralSpawnPoints[g_iLoadedGarbage].gYPos = StringToFloat(sDatas[1]);
			MineralSpawnPoints[g_iLoadedGarbage].gZPos = StringToFloat(sDatas[2]);
			
			g_iLoadedGarbage++;
		}
		
		delete hFile;
	}
	PrintToServer("Minerals loaded: %i", g_iLoadedGarbage);
}

public void SaveMineralSpawnPoints()
{
	char map[64];
	rp_GetCurrentMap(STRING(map));
	
	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPath, sizeof(sPath), "data/roleplay/%s/minerals.cfg", map);
	
	Handle hFile = OpenFile(sPath, "w");
	
	if (hFile != INVALID_HANDLE)
	{
		for (int i = 0; i < g_iLoadedGarbage; i++) {
			WriteFileLine(hFile, "%.2f;%.2f;%.2f;", MineralSpawnPoints[i].gXPos, MineralSpawnPoints[i].gYPos, MineralSpawnPoints[i].gZPos);
		}
		
		delete hFile;
	}
	
	if (!FileExists(sPath))
		LogError("Couldn't save item spawns to  file: \"%s\".", sPath);
}

public void AddLootSpawn(int client)
{
	float pos[3];
	PointVision(client, pos);
	
	TE_SetupGlowSprite(pos, g_iBlueGlow, 10.0, 1.0, 235);
	TE_SendToAll();
	
	MineralSpawnPoints[g_iLoadedGarbage].gXPos = pos[0];
	MineralSpawnPoints[g_iLoadedGarbage].gYPos = pos[1];
	MineralSpawnPoints[g_iLoadedGarbage].gZPos = pos[2];
	g_iLoadedGarbage++;
	
	CPrintToChat(client, "Ajout d'une poubelle à la position %.2f:%.2f:%.2f", pos[0], pos[1], pos[2]);
	SaveMineralSpawnPoints();
}

public Action Command_GiveResource(int client, int args) 
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
	
	char arg[32];
	GetCmdArg(1, STRING(arg));
	
	rp_SetClientResource(client, view_as<resource_list>(StringToInt(arg)), 50);
	
	return Plugin_Handled;
}

public Action Command_SpawnPoints(int client, int args) 
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
	
	SpawnPoints(client);
	
	return Plugin_Handled;
}

void SpawnPoints(int client)
{
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_MenuSpawnPoints);
	menu.SetTitle("Spawn: Minerals (Total: %i)", g_iLoadedGarbage);
	menu.AddItem("add", "Ajouter un spawn");
	menu.AddItem("show", "Afficher les spawn");
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Handle_MenuSpawnPoints(Menu menu, MenuAction action, int client, int param) 
{
	if (action == MenuAction_Select) 
	{
		char info[64];
		menu.GetItem(param, STRING(info));
		
		if (StrEqual(info, "add")) 
		{
			AddLootSpawn(client);
			SpawnPoints(client);
		} 
		else if (StrEqual(info, "show")) 
		{
			ShowSpawns();
			SpawnPoints(client);
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

public void ShowSpawns() {
	for (int i = 0; i < g_iLoadedGarbage; i++) {
		float pos[3];
		pos[0] = MineralSpawnPoints[i].gXPos;
		pos[1] = MineralSpawnPoints[i].gYPos;
		pos[2] = MineralSpawnPoints[i].gZPos;
		TE_SetupGlowSprite(pos, g_iBlueGlow, 10.0, 1.0, 235);
		TE_SendToAll();
	}
}

public int getActiveGarbage() {
	int count = 0;
	for (int i = 0; i < g_iLoadedGarbage; i++) {
		if (MineralSpawnPoints[i].gIsActive)
			count++;
	}
	return count;
}

public void OnClientPostAdminCheck(int client) {
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