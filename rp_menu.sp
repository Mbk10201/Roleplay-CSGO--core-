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

enum struct Data_Forward {
	GlobalForward OnMenu;
	GlobalForward OnHandleMenu;
	GlobalForward OnSettingsMenu;
	GlobalForward OnHandleSettingsMenu;
}	
Data_Forward Forward;

bool canKnock[MAXPLAYERS + 1];

/***************************************************************************************

							P L U G I N  -  I N F O

***************************************************************************************/
public Plugin myinfo = 
{
	name = "Roleplay - Menu", 
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
	LoadTranslations("rp_menu.phrases.txt");
	PrintToServer("[REQUIREMENT] MENU ✓");	
	
	/*----------------------------------Commands-------------------------------*/
	RegConsoleCmd("rp", Command_General);
	/*-------------------------------------------------------------------------------*/
}	

public APLRes AskPluginLoad2(Handle plugin, bool late, char[] error, int err_max)
{
	RegPluginLibrary("rp_menu");
	
	/*------------------------------------FORWADS------------------------------------*/
	Forward.OnMenu = new GlobalForward("RP_OnRoleplay", ET_Event, Param_Cell, Param_Cell);
	Forward.OnHandleMenu = new GlobalForward("RP_OnRoleplayHandle", ET_Event, Param_Cell, Param_String);
	Forward.OnSettingsMenu = new GlobalForward("RP_OnSettings", ET_Event, Param_Cell, Param_Cell);
	Forward.OnHandleSettingsMenu = new GlobalForward("RP_OnSettingsHandle", ET_Event, Param_Cell, Param_String);
	/*-------------------------------------------------------------------------------*/
	
	return APLRes_Success;
}

/***************************************************************************************

									C L I E N T - S I D E

***************************************************************************************/

public void OnClientPutInServer(int client)
{
	canKnock[client] = true;
}	

/***************************************************************************************

									C A L L B A C K

***************************************************************************************/

public Action Command_General(int client, int args)
{
	if(client == 0)
	{
		PrintToServer("%T", "Command_NotAvailable", LANG_SERVER);
		return Plugin_Handled;
	}
	
	Menu_General(client);
	return Plugin_Handled;
}	

void Menu_General(int client)
{
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_MenuGeneral);
	
	char translation[64];
	menu.SetTitle("%T", "Title", LANG_SERVER);
	
	Format(STRING(translation), "%T", "param_job", LANG_SERVER);
	menu.AddItem("jobmenu", translation, (rp_GetClientInt(client, i_Job) == 0) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	
	Format(STRING(translation), "%T", "param_identity", LANG_SERVER);
	menu.AddItem("identity", translation);
	
	menu.AddItem("", "------------------", ITEMDRAW_DISABLED);
	
	Format(STRING(translation), "%T", "param_admin", LANG_SERVER);
	menu.AddItem("rp_admin", translation, (rp_GetAdmin(client) == ADMIN_FLAG_NONE) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	
	Format(STRING(translation), "%T", "param_inventory", LANG_SERVER);
	menu.AddItem("item", translation);
	
	Format(STRING(translation), "%T", "param_garage", LANG_SERVER);
	menu.AddItem("garage", translation);
	
	if(!rp_GetClientBool(client, b_IsPassive))
		Format(STRING(translation), "%T", "param_passif", LANG_SERVER);
	else
		Format(STRING(translation), "%T", "param_normal", LANG_SERVER);	
	menu.AddItem("passive", translation);
			
	Format(STRING(translation), "%T", "param_call", LANG_SERVER);
	menu.AddItem("job", translation);
	
	Format(STRING(translation), "%T", "param_stats", LANG_SERVER);
	menu.AddItem("rp_stats", translation);
	
	Format(STRING(translation), "%T", "param_help", LANG_SERVER);
	menu.AddItem("aide", translation);
		
	menu.AddItem("", "------------------", ITEMDRAW_DISABLED);
		
	Call_StartForward(Forward.OnMenu);
	Call_PushCell(menu);
	Call_PushCell(client);
	Call_Finish();
	
	Format(STRING(translation), "%T", "param_setting", LANG_SERVER);
	menu.AddItem("settings", translation);
	
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Handle_MenuGeneral(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[64];
		menu.GetItem(param, STRING(info));
		
		Call_StartForward(Forward.OnHandleMenu);
		Call_PushCell(client);
		Call_PushString(info);
		Call_Finish();
		
		if(!StrEqual(info, "settings"))
			FakeClientCommand(client, "say /%s", info);
		else
			MenuSettings(client);
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit || param == MenuCancel_ExitBack)
			if(rp_GetClientBool(client, b_IsNew))
				rp_OpenTutorial(client);
			else	
				rp_SetClientBool(client, b_DisplayHud, true);
	}
	else if(action == MenuAction_End)
		delete menu;
	
	return 0;
}

void MenuSettings(int client)
{
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_MenuSettings);
	
	char translation[64];
	menu.SetTitle("%T", "param_setting", LANG_SERVER);
	
	Format(STRING(translation), "%T", "param_hud", LANG_SERVER);
	menu.AddItem("hud", translation);
	
	if(rp_GetClientBool(client, b_JoinSound))
		Format(STRING(translation), "%T", "param_joinsound_on", LANG_SERVER);
	else
		Format(STRING(translation), "%T", "param_joinsound_off", LANG_SERVER);	
	menu.AddItem("joinsound", translation);
	
	if(rp_GetClientInt(client, i_Job) != 0)
	{
		if(rp_GetClientBool(client, b_SpawnJob))
			Format(STRING(translation), "%T", "param_spawnjob_on", LANG_SERVER);
		else
			Format(STRING(translation), "%T", "param_spawnjob_off", LANG_SERVER);	
		menu.AddItem("spawnjob", translation);
	}	
	
	if(rp_GetClientBool(client, b_TransfertItemBank))
		Format(STRING(translation), "%T", "param_itemtransfert_on", LANG_SERVER);
	else
		Format(STRING(translation), "%T", "param_itemtransfert_off", LANG_SERVER);	
	menu.AddItem("itemtransfert", translation);
	
	char buffer[64];
	GetClientCookie(client, FindClientCookie("rpv_hud_time"), STRING(buffer));
	int value = StringToInt(buffer);
	
	if(value == 1)
		menu.AddItem("hud_pos", "HUD Date [H/G]");
	else if(value == 2)
		menu.AddItem("hud_pos", "HUD Date [BAS]");	
	else
		menu.AddItem("hud_pos", "HUD Date [OFF]");		
		
	char strIndex[64], strMenu[64];
	GetClientCookie(client, FindClientCookie("rpv_thirdperson_distance"), STRING(buffer));
	
	float distance = StringToFloat(buffer);
	Format(STRING(strMenu), "Distance 3RD [%0.2f]", distance);
	
	if(distance == 10.0)
		Format(STRING(strIndex), "3rd|25.0");
	else if(distance == 25.0)	
		Format(STRING(strIndex), "3rd|50.0");
	else if(distance == 50.0)	
		Format(STRING(strIndex), "3rd|75.0");
	else if(distance == 75.0)	
		Format(STRING(strIndex), "3rd|100.0");
	else if(distance == 100.0)	
		Format(STRING(strIndex), "3rd|125.0");
	else if(distance == 125.0)	
		Format(STRING(strIndex), "3rd|150.0");
	else if(distance == 150.0)	
		Format(STRING(strIndex), "3rd|175.0");
	else if(distance == 175.0)	
		Format(STRING(strIndex), "3rd|200.0");	
	else if(distance == 200.0)	
		Format(STRING(strIndex), "3rd|10.0");		
	
	menu.AddItem(strIndex, strMenu);
		
	Call_StartForward(Forward.OnSettingsMenu);
	Call_PushCell(menu);
	Call_PushCell(client);
	Call_Finish();	
	
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Handle_MenuSettings(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[64];
		menu.GetItem(param, STRING(info));
		char buffer[2][32];
		ExplodeString(info, "|", buffer, 2, 32);	
		
		if(StrEqual(info, "joinsound"))
		{
			if(rp_GetClientBool(client, b_JoinSound))
			{
				rp_SetClientBool(client, b_JoinSound, false);
				SetClientCookie(client, FindClientCookie("rpv_joinsound"), "0");
			}	
			else
			{
				rp_SetClientBool(client, b_JoinSound, true);
				SetClientCookie(client, FindClientCookie("rpv_joinsound"), "1");
			}	
			MenuSettings(client);
		}
		else if(StrEqual(info, "spawnjob"))
		{
			if(rp_GetClientBool(client, b_SpawnJob))
			{
				rp_SetClientBool(client, b_SpawnJob, false);
				SetClientCookie(client, FindClientCookie("rpv_spawnjob"), "0");
			}	
			else
			{
				rp_SetClientBool(client, b_SpawnJob, true);
				SetClientCookie(client, FindClientCookie("rpv_spawnjob"), "1");
			}	
			MenuSettings(client);
		}
		else if(StrEqual(info, "itemtransfert"))
		{
			if(rp_GetClientBool(client, b_TransfertItemBank))
			{
				rp_SetClientBool(client, b_TransfertItemBank, false);
				SetClientCookie(client, FindClientCookie("rpv_sellmethod"), "0");
			}	
			else
			{
				rp_SetClientBool(client, b_TransfertItemBank, true);
				SetClientCookie(client, FindClientCookie("rpv_sellmethod"), "1");
			}	
			MenuSettings(client);
		}
		else if(StrEqual(info, "hud_pos"))
		{
			char buffer1[64];
			GetClientCookie(client, FindClientCookie("rpv_hud_time"), STRING(buffer1));
			int value = StringToInt(buffer1);
			
			if(value == 0)
				SetClientCookie(client, FindClientCookie("rpv_hud_time"), "1");
			else if(value == 1)
				SetClientCookie(client, FindClientCookie("rpv_hud_time"), "2");
			else if(value == 2)
				SetClientCookie(client, FindClientCookie("rpv_hud_time"), "0");	
			MenuSettings(client);	
		}
		else if(StrEqual(buffer[0], "3rd"))
		{
			SetClientCookie(client, FindClientCookie("rpv_thirdperson_distance"), buffer[1]);
			ClientCommand(client, "cam_idealdist %s", buffer[1]);
			MenuSettings(client);
		}
		else		
			FakeClientCommand(client, "say /%s", info);
		
		Call_StartForward(Forward.OnHandleSettingsMenu);
		Call_PushCell(client);
		Call_PushString(info);
		Call_Finish();
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit || param == MenuCancel_ExitBack)
			if(rp_GetClientBool(client, b_IsNew))
				rp_OpenTutorial(client);
			else	
				rp_SetClientBool(client, b_DisplayHud, true);
	}
	else if(action == MenuAction_End)
		delete menu;
	
	return 0;
}

public void RP_OnClientInteract(int client, int target, const char[] class, const char[] model, const char[] name)
{
	if(IsClientValid(target))
	{
		if(Distance(client, target) <= 80.0)
			MenuInteraction(client, target);
	}	
	else if(rp_IsValidDoorAppart(target))
	{
		if(Distance(client, target) <= 80.0)
			MenuDoorAppart(client, target);
	}
	else if(rp_IsValidDoorVilla(target))
	{
		if(Distance(client, target) <= 80.0)
			MenuDoorVilla(client, target);
	}
	else if(rp_IsValidDoor(target) && !rp_IsValidDoorAppart(target) && rp_HasDoorAccess(client, target))
	{
		if(Distance(client, target) <= 80.0)
			MenuDoor(client, target);
	}		
}	

void MenuDoor(int client, int target)
{
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_MenuDoor);
	
	char nameDisplay[64];
	rp_GetJobName(rp_GetDoorJobID(target), STRING(nameDisplay));
	
	menu.SetTitle("▶ Roleplay Portland ◀\nPorte %s", nameDisplay);
	
	if(Entity_IsLocked(target))
		menu.AddItem("unlock", "Ouvrir");
	else
		menu.AddItem("lock", "Fermer");	
	
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}	

public int Handle_MenuDoor(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[64], buffer[2][64];
		menu.GetItem(param, STRING(info));
		ExplodeString(info, "|", buffer, 2, 64);
		
		ClientCommand(client, buffer[0]);	
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

void MenuInteraction(int client, int target)
{
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_MenuInteraction);
	menu.SetTitle("Interaction avec: %N", target);
	
	if(rp_GetClientInt(target, i_Job) == 0)
		menu.AddItem("embaucher", "Engager");
	menu.AddItem("gang", "Gang", ITEMDRAW_DISABLED);
	
	if(rp_CanJobSell(rp_GetClientInt(client, i_Job)))
		menu.AddItem("vendre", "Vendre un item");
		
	if(rp_GetClientInt(client, i_Job) == 8)
		menu.AddItem("vendreapp", "Vendre");
	
	if(rp_GetClientInt(client, i_Job) == 12)
		menu.AddItem("contract", "Signer un contrat");
	
	if (rp_GetClientInt(client, i_Job) == 4 && Zone_Surgery(target))
		menu.AddItem("operer", "Opérer");	
		
	if (rp_GetClientInt(client, i_Job) == 2 || rp_GetClientInt(client, i_Job) == 3)
		menu.AddItem("vol", "Voler");

	if(isZoneProprietaire(client) || IsLocationOwner(client))
		menu.AddItem("out", "Expulser");
	
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}	

public int Handle_MenuInteraction(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[64];
		menu.GetItem(param, STRING(info));
		
		FakeClientCommand(client, "say /%s", info);		
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

void MenuDoorAppart(int client, int target)
{
	int appID = GetAppartmentId(target);
	int owner = rp_GetAppartementInt(appID, appart_owner);
	char strMenu[64], strIndex[64];
	
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_MenuDoorAppart);
	menu.SetTitle("Appartement: Nº%i\n ", appID);
	
	if(IsClientValid(owner))
	{
		Format(STRING(strMenu), "Propriétaire: %N", owner);
		menu.AddItem("", strMenu, ITEMDRAW_DISABLED);
		
		if(client != owner)
		{
			Format(STRING(strIndex), "call|%i", target);
			if(canKnock[client])
				menu.AddItem(strIndex, "Toquer à la porte");
			else
				menu.AddItem(strIndex, "Toquer à la porte", ITEMDRAW_DISABLED);	
		}	
	}	
	else
		menu.AddItem("", "Propriétaire: Aucun", ITEMDRAW_DISABLED);	
	
	if(client == owner)
	{
		if(Entity_IsLocked(target))
			menu.AddItem("unlock", "Déverrouiller la porte");
		else
			menu.AddItem("lock", "Verrouiller la porte");		
	}
	
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}	

public int Handle_MenuDoorAppart(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[64], buffer[2][64];
		menu.GetItem(param, STRING(info));
		ExplodeString(info, "|", buffer, 2, 64);
		int target = StringToInt(buffer[1]);
		
		if(StrEqual(info, "unlock"))
			ClientCommand(client, "unlock");
		else if(StrEqual(info, "lock"))
			ClientCommand(client, "lock");	
		else if(StrEqual(buffer[0], "call"))
			EmitCallDoor(client, target);		
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

public void EmitCallDoor(int client, int target)
{
	char entName[64];
	Entity_GetName(target, STRING(entName));
	
	canKnock[client] = false;
	rp_Sound(client, "sound_knock", 0.7);	
	
	int ID = 0;
	int owner = -1;
	
	if(StrContains(entName, "door_appart_") != -1)
	{
		ID = GetAppartmentId(target);
		owner = rp_GetAppartementInt(ID, appart_owner);
		
		if(IsOwnerInAppart(ID))
		{
			rp_Sound(owner, "sound_knock", 0.7);
			CPrintToChat(owner, "%s {lime}%N {default}a toqué à la porte.", client);
			rp_PrintToChat(client, "Vous avez toqué à la porte de {lime}%N.", owner);
		}	
		else
			rp_PrintToChat(client, "Malheuresement le propriétaire de cet appartement n'est pas dans à son domicile.");
	}
	else if(StrContains(entName, "door_villa_") != -1)
	{
		ID = GetVillaId(target);
		owner = rp_GetVillaInt(ID, villa_owner);
		
		if(IsOwnerInVilla(ID))
		{
			rp_Sound(owner, "sound_knock", 0.7);
			CPrintToChat(owner, "%s {lime}%N {default}a toqué à la porte.", client);
			rp_PrintToChat(client, "Vous avez toqué à la porte de {lime}%N.", owner);
		}	
		else
			rp_PrintToChat(client, "Malheuresement le propriétaire de cette villa n'est pas dans à son domicile.");
	}
		
	CreateTimer(5.0, ResetKnock, client);
}	

public Action ResetKnock(Handle timer, int client)
{
	canKnock[client] = true;
	
	return Plugin_Handled;
}	

void MenuDoorVilla(int client, int target)
{
	int villaID = GetVillaId(target);
	int owner = rp_GetVillaInt(villaID, villa_owner);
	char strMenu[64], strIndex[64];
	
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_MenuDoorVilla);
	menu.SetTitle("Villa: Nº%i\n ", villaID);
	
	if(IsClientValid(owner))
	{
		Format(STRING(strMenu), "Propriétaire: %N", owner);
		menu.AddItem("", strMenu, ITEMDRAW_DISABLED);
		
		if(client != owner)
		{
			Format(STRING(strIndex), "call|%i", target);
			if(canKnock[client])
				menu.AddItem(strIndex, "Toquer à la porte");
			else
				menu.AddItem(strIndex, "Toquer à la porte", ITEMDRAW_DISABLED);	
		}	
	}	
	else
		menu.AddItem("", "Propriétaire: Aucun", ITEMDRAW_DISABLED);	
	
	if(client == owner)
	{
		if(Entity_IsLocked(target))
			menu.AddItem("unlock", "Déverrouiller la porte");
		else
			menu.AddItem("lock", "Verrouiller la porte");		
	}
	
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}	

public int Handle_MenuDoorVilla(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[64], buffer[2][64];
		menu.GetItem(param, STRING(info));
		ExplodeString(info, "|", buffer, 2, 64);
		int target = StringToInt(buffer[1]);
		
		if(StrEqual(info, "unlock"))
			ClientCommand(client, "unlock");
		else if(StrEqual(info, "lock"))
			ClientCommand(client, "lock");	
		else if(StrEqual(buffer[0], "call"))
			EmitCallDoor(client, target);		
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