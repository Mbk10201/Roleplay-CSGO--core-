#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <fpvm_interface>

#define WEAPON "weapon_melee"
#define VMODEL "models/roleplay/weapons/v_pickaxe_v1.mdl"
#define WMODEL "models/roleplay/weapons/w_pickaxe_v1.mdl"

int g_vModel;
int g_wModel;

public Plugin myinfo = 
{
	name = "Roleplay - Weapons[PICKAXE]", 
	author = "MBK", 
	description = "", 
	version = "1.0",
	url = "https://github.com/Mbk10201"
};

public void OnClientPostAdminCheck(int client)
{
	FPVMI_AddViewModelToClient(client, WEAPON, g_vModel);
	FPVMI_AddWorldModelToClient(client, WEAPON, g_wModel);
	FPVMI_AddDropModelToClient(client, WEAPON, "models/roleplay/weapons/wdrop_pickaxe_v1.mdl");
}

public void OnMapStart() 
{ 
	g_vModel = PrecacheModel(VMODEL);
	g_wModel = PrecacheModel(WMODEL);
}