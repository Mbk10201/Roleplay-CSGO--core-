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

/***************************************************************************************

							G L O B A L  -  V A R S

***************************************************************************************/
Database g_DB;

char steamID[MAXPLAYERS + 1][32];
char active_particle[MAXPLAYERS + 1][32];
char active_tag[MAXPLAYERS + 1][32];
char active_tagcolor[MAXPLAYERS + 1][32];

int particle_entity[MAXPLAYERS + 1];
int vip_time[MAXPLAYERS + 1];
Handle Cookie_Particle;
Handle Cookie_Tag;
Handle Cookie_TagColor;

bool canSetTag[MAXPLAYERS + 1] = { false, ... };

// Methodmap Constructor
Roleplay m_iClient[MAXPLAYERS + 1];

/***************************************************************************************

							P L U G I N  -  I N F O

***************************************************************************************/
public Plugin myinfo = 
{
	name = "Roleplay - Vip", 
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
	// Load global & local translations
	LoadTranslation();
	LoadTranslations("rp_vip.phrases.txt");
	// Print to server console the plugin status
	PrintToServer("[REQUIREMENT] VIP ✓");	
	
	/*----------------------------------Cookies-------------------------------*/
	// Register all client cookies
	Cookie_Particle = RegClientCookie("rpv_particle_type", "Hud type display", CookieAccess_Protected);
	Cookie_Tag = RegClientCookie("rpv_tag_type", "Tag V.I.P", CookieAccess_Protected);
	Cookie_TagColor = RegClientCookie("rpv_tagcolor_type", "Couleur tag V.I.P", CookieAccess_Protected);
	/*------------------------------------------------------------------------*/	
}	

public void RP_OnSQLInit(Database db, Transaction transaction)
{
	g_DB = db;
	
	char sBuffer[MAX_BUFFER_LENGTH + 1];
	
	Format(STRING(sBuffer), "CREATE TABLE IF NOT EXISTS `rp_vips` ( \
	  `playerid` int(20) NOT NULL, \
	  `time` int(100) NOT NULL, \
	  PRIMARY KEY (`playerid`), \
	  UNIQUE KEY `playerid` (`playerid`), \
	  FOREIGN KEY (`playerid`) REFERENCES `rp_players` (`id`) ON DELETE CASCADE ON UPDATE CASCADE \
	  )ENGINE = InnoDB DEFAULT CHARSET = utf8 COLLATE = utf8_bin;");
	#if DEBUG
		PrintToServer(sBuffer);
	#endif
	transaction.AddQuery(sBuffer);
}

/***************************************************************************************

									C L I E N T - S I D E

***************************************************************************************/

public void OnClientPostAdminCheck(int client) 
{	
	SQL_LOAD(client);
}

public void OnClientAuthorized(int client, const char[] auth) 
{	
	strcopy(steamID[client], sizeof(steamID[]), auth);
}

public void OnClientPutInServer(int client)
{
	// MethodMap Constructor
	m_iClient[client] = Roleplay(client);
	
	rp_SetClientBool(client, b_IsVip, false);
	active_particle[client] = "";
	particle_entity[client] = -1;
}	

public void OnClientDisconnect(int client)
{
	particle_entity[client] = -1;
	active_particle[client] = "";
}

/*public Action RP_OnClientSpawn(int client)
{
	CreateTimer(10.0, CheckParticle, client);
}*/

/***************************************************************************************

									C A L L B A C K

***************************************************************************************/

public Action CheckParticle(Handle timer, any client)
{
	GetClientCookie(client, Cookie_Particle, active_particle[client], sizeof(active_particle[]));	
	if(!StrEqual(active_particle[client], ""))
	{
		int particle_ref = rp_AttachCreateParticle(client, active_particle[client], 0.0);
		particle_entity[client] = particle_ref;
	}	
	
	GetClientCookie(client, Cookie_Tag, active_tag[client], sizeof(active_tag[]));	
	GetClientCookie(client, Cookie_TagColor, active_tagcolor[client], sizeof(active_tagcolor[]));
	
	return Plugin_Handled;
}		

public void SQL_LOAD(int client) 
{
	if (!IsClientValid(client))
		return;
			
	char buffer[512];
	Format(STRING(buffer), "SELECT * FROM `rp_vips` WHERE `playerid` = '%i'", rp_GetSQLID(client));
	g_DB.Query(SQL_QueryCallBack, buffer, GetClientUserId(client));
}

public void SQL_QueryCallBack(Database db, DBResultSet Results, const char[] error, any data) 
{	
	int client = GetClientOfUserId(data);
	while (Results.FetchRow()) 
	{
		int time;
		Results.FetchIntByName("time", time);
		vip_time[client] = time;
		
		if(GetTime() < time)
			rp_SetClientBool(client, b_IsVip, true);
		else if(time == -1)
			rp_SetClientBool(client, b_IsVip, true);
		else
		{
			rp_SetClientBool(client, b_IsVip, false);
			SQL_Request(g_DB, "DELETE FROM `rp_vips` WHERE `playerid` = '%i'", rp_GetSQLID(client));
		}
	}
}

public void RP_OnClientFirstSpawnMessage(int client)
{
	char translate[128];
	if(GetTime() < vip_time[client])
	{
		char timestamp[128];
		int iYear, iMonth, iDay, iHour, iMinute, iSecond;
		UnixToTime(vip_time[client], iYear, iMonth, iDay, iHour, iMinute, iSecond, UT_TIMEZONE_CEST);	
		Format(STRING(timestamp), "%02d/%02d/%d %02d:%02d:%02d", iDay, iMonth, iYear, iHour, iMinute, iSecond);	
		
		Format(STRING(translate), "%T", "VIP_Valid", LANG_SERVER, timestamp);				
		
	}
	else if(vip_time[client] == -1)
	{
		Format(STRING(translate), "%T", "VIP_Permanent", LANG_SERVER);				
	}
	else
	{	
		Format(STRING(translate), "%T", "VIP_TimeOut", LANG_SERVER);
	}
	
	CPrintToChat(client, "{yellow}◾️ {default}%s", translate);
}

public void RP_OnRoleplay(Menu menu, int client)
{
	char translation[32];
	Format(STRING(translation), "%T", "Title_VIP", LANG_SERVER);
	if(rp_GetClientBool(client, b_IsVip))
		menu.AddItem("vip", "Menu VIP");
}

public void RP_OnRoleplayHandle(int client, const char[] info)
{
	if(StrEqual(info, "vip"))
		Menu_VIP(client);
}	

void Menu_VIP(int client)
{
	char translation[32];	
	rp_SetClientBool(client, b_DisplayHud, false);
	
	Menu menu = new Menu(Handle_MenuVip);
	menu.SetTitle("%T", "Title_VIP", LANG_SERVER);
		
	Format(STRING(translation), "%T", "param_particles", LANG_SERVER);
	menu.AddItem("particles", translation);
	
	Format(STRING(translation), "%T", "param_skins", LANG_SERVER);
	menu.AddItem("skins", translation);
	
	Format(STRING(translation), "%T", "param_finition", LANG_SERVER);
	menu.AddItem("finition", translation);
	
	Format(STRING(translation), "%T", "param_tag", LANG_SERVER);
	menu.AddItem("tag", translation);
	
	Format(STRING(translation), "%T", "param_tagcolor", LANG_SERVER);
	menu.AddItem("tagcolor", translation);
	
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}	

public int Handle_MenuVip(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[64];
		menu.GetItem(param, STRING(info));
		
		if(StrEqual(info, "particles"))
			Menu_Particles(client);
		else if(StrEqual(info, "skins"))
			Menu_Skins(client);		
		else if(StrEqual(info, "finition"))
			Menu_Finitions(client);			
		else if(StrEqual(info, "tag"))
			Menu_Tag(client);		
		else if(StrEqual(info, "tagcolor"))
			Menu_TagColor(client);		
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

public void RP_OnClientSay(int client, const char[] arg)
{
	if(canSetTag[client])
	{
		canSetTag[client] = false;
		if(StrContains(arg, "admin", false) != -1
		|| StrContains(arg, "administrateur", false) != -1
		|| StrContains(arg, "fondateur", false) != -1
		|| StrContains(arg, "fdp", false) != -1
		|| StrContains(arg, "enculer", false) != -1
		|| StrContains(arg, "moderateur", false) != -1
		|| StrContains(arg, "modérateur", false) != -1
		|| StrContains(arg, "responsable", false) != -1)
		{
			rp_PrintToChat(client, "Vous n'êtes pas autorisé.", arg);
			return;
		}
		else if(strlen(arg) > 60)
		{
			rp_PrintToChat(client, "Vous êtes limité à {green}64 {default}Charactères pour un tag.", arg);
			return;
		}		
		
		SetClientCookie(client, Cookie_Tag, arg);
		rp_PrintToChat(client, "Tag {green}%s {default}appliqué.", arg);
	}
}

void Menu_Tag(int client)
{
	rp_SetClientBool(client, b_DisplayHud, false);
	
	Menu menu = new Menu(Handle_MenuTag);
	menu.SetTitle("%T", "Title_Tag", LANG_SERVER);
		
	menu.AddItem("custom", "Personnaliser");
	menu.AddItem("Zeus", "Zeus");
	menu.AddItem("VIP", "VIP");
	menu.AddItem("☾2k21☽", "☾2k21☽");
	
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}	

public int Handle_MenuTag(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[64];
		menu.GetItem(param, STRING(info));	

		if(StrEqual(info, "custom", false))
		{
			canSetTag[client] = true;
			rp_PrintToChat(client, "Notez dans le tchat un tag.");
		}
		else
		{
			strcopy(active_tag[client], sizeof(active_tag[]), info);
			SetClientCookie(client, Cookie_Tag, active_tag[client]);
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

void Menu_TagColor(int client)
{
	rp_SetClientBool(client, b_DisplayHud, false);
	
	Menu menu = new Menu(Handle_MenuTagColor);
	menu.SetTitle("%T", "Title_TagColor", LANG_SERVER);
		
	menu.AddItem("{lightblue}", "Bleu clair");
	menu.AddItem("{blue}", "Bleu");
	menu.AddItem("{lightred}", "Rouge clair");
	menu.AddItem("{darkred}", "Rouge foncé");
	menu.AddItem("{orange}", "Orange");
	menu.AddItem("{yellow}", "Jaune");
	menu.AddItem("{purple}", "Mauve");
	menu.AddItem("{green}", "Vert");
	
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}	

public int Handle_MenuTagColor(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[64];
		menu.GetItem(param, STRING(info));	

		if(!StrEqual(active_tagcolor[client], info))
		{
			strcopy(active_tagcolor[client], sizeof(active_tagcolor[]), info);
			SetClientCookie(client, Cookie_TagColor, active_tagcolor[client]);
		}
		else
		{
			rp_PrintToChat(client, "Cette couleure est déjà activée.");
			Menu_TagColor(client);
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

void Menu_Particles(int client)
{
	char translation[32];
	rp_SetClientBool(client, b_DisplayHud, false);	
	Menu menu = new Menu(Handle_MenuParticles);
	menu.SetTitle("%T", "Title_Particles", LANG_SERVER);
	
	Format(STRING(translation), "%T", "param_noneparticles", LANG_SERVER);
	menu.AddItem("none", translation);
	
	menu.AddItem("d2d_aurathunder", "d2d_aurathunder");
	menu.AddItem("d2d_blood", "d2d_blood");
	menu.AddItem("d2d_bubble", "d2d_bubble");
	menu.AddItem("d2d_bubble2", "d2d_bubble2");
	menu.AddItem("d2d_flag2", "d2d_flag2");
	menu.AddItem("d2d_rainbow", "d2d_rainbow");
	menu.AddItem("d2d_rainbow2", "d2d_rainbow2");
	menu.AddItem("d2d_rainbow3", "d2d_rainbow3");
	menu.AddItem("d2d_rainbow4", "d2d_rainbow4");
	menu.AddItem("d2d_rainbow5", "d2d_rainbow5");
	menu.AddItem("d2d_rainbow7", "d2d_rainbow7");
	menu.AddItem("d2d_redring", "d2d_redring");
	menu.AddItem("d2d_ring", "d2d_ring");
	menu.AddItem("d2d_ring10", "d2d_ring10");
	menu.AddItem("d2d_ring11", "d2d_ring11");
	menu.AddItem("d2d_ring12", "d2d_ring12");
	menu.AddItem("d2d_ring13", "d2d_ring13");
	menu.AddItem("d2d_ring16", "d2d_ring16");
	menu.AddItem("d2d_ring17", "d2d_ring17");
	menu.AddItem("d2d_ring18", "d2d_ring18");
	menu.AddItem("d2d_ring3", "d2d_ring3");
	menu.AddItem("d2d_ring5", "d2d_ring5");
	menu.AddItem("d2d_ring6", "d2d_ring6");
	menu.AddItem("d2d_ring7", "d2d_ring7");
	menu.AddItem("d2d_ring8", "d2d_ring8");
	menu.AddItem("d2d_ring9", "d2d_ring9");
	menu.AddItem("d2d_smoke", "d2d_smoke");
	menu.AddItem("d2d_smoke2", "d2d_smoke2");
	menu.AddItem("d2d_smoke3", "d2d_smoke3");
	menu.AddItem("d2d_smoke4", "d2d_smoke4");
	menu.AddItem("d2d_smoke5", "d2d_smoke5");
	menu.AddItem("d2d_smoke6", "d2d_smoke6");
	menu.AddItem("d2d_smoke7", "d2d_smoke7");
	menu.AddItem("d2d_smoke8", "d2d_smoke8");
	menu.AddItem("d2d_smoke9", "d2d_smoke9");
	menu.AddItem("d2d_sphere", "d2d_sphere");
	menu.AddItem("d2d_trail1", "d2d_trail1");
	menu.AddItem("d2d_trail10", "d2d_trail10");
	menu.AddItem("d2d_trail11", "d2d_trail11");
	menu.AddItem("d2d_trail12", "d2d_trail12");
	menu.AddItem("d2d_trail13", "d2d_trail13");
	menu.AddItem("d2d_trail14", "d2d_trail14");
	menu.AddItem("d2d_trail16", "d2d_trail16");
	menu.AddItem("d2d_trail17", "d2d_trail17");
	menu.AddItem("d2d_trail18", "d2d_trail18");
	menu.AddItem("d2d_trail19", "d2d_trail19");
	menu.AddItem("d2d_trail2", "d2d_trail2");
	menu.AddItem("d2d_trail20", "d2d_trail20");
	menu.AddItem("d2d_trail21", "d2d_trail21");
	menu.AddItem("d2d_trail3", "d2d_trail3");
	menu.AddItem("d2d_trail4", "d2d_trail4");
	menu.AddItem("d2d_trail5", "d2d_trail5");
	menu.AddItem("d2d_trail9", "d2d_trail9");
	menu.AddItem("d2d_vortex", "d2d_vortex");
	menu.AddItem("d2d_vortex2", "d2d_vortex2");
	menu.AddItem("d2d_vortex3", "d2d_vortex3");
	menu.AddItem("d2d_vortex4", "d2d_vortex4");
	menu.AddItem("d2d_vortex5", "d2d_vortex5");
	menu.AddItem("d2d_vortex6", "d2d_vortex6");
	menu.AddItem("d2d_vixr", "d2d_vixr");
	menu.AddItem("d2d_vixr_2", "d2d_vixr_2");
	menu.AddItem("d2d_hell", "d2d_hell");
	menu.AddItem("d2d_copy", "d2d_copy");
	menu.AddItem("lightning", "lightning");
	menu.AddItem("lightning2", "lightning2");
	menu.AddItem("ring1", "ring1");
	menu.AddItem("ring10", "ring10");
	menu.AddItem("ring11", "ring11");
	menu.AddItem("ring12", "ring12");
	menu.AddItem("ring13", "ring13");
	menu.AddItem("ring14", "ring14");
	menu.AddItem("ring15", "ring15");
	menu.AddItem("ring16", "ring16");
	menu.AddItem("ring17", "ring17");
	menu.AddItem("ring18", "ring18");
	menu.AddItem("ring19", "ring19");
	menu.AddItem("ring2", "ring2");
	menu.AddItem("ring20", "ring20");
	menu.AddItem("ring21", "ring21");
	menu.AddItem("ring3", "ring3");
	menu.AddItem("ring4", "ring4");
	menu.AddItem("ring5", "ring5");
	menu.AddItem("trail_new_003", "trail_new_003");
	menu.AddItem("trail_new_003_copy", "trail_new_003_copy");
	menu.AddItem("trail_new_003_copy2", "trail_new_003_copy2");
	menu.AddItem("trail_new_003_copy_copy", "trail_new_003_copy_copy");
	menu.AddItem("vixr_body", "vixr_body");
	menu.AddItem("vixr_niz", "vixr_niz");
	
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}	

public int Handle_MenuParticles(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[64];
		menu.GetItem(param, STRING(info));
		
		if(!StrEqual(info, "none"))
		{
			if(StrEqual(active_particle[client], ""))
			{		
				Format(active_particle[client], sizeof(active_particle[]), info);		
				int particle_ref = rp_AttachCreateParticle(client, active_particle[client], 0.0);
				particle_entity[client] = particle_ref;
			}
			else
			{
				RemoveParticle(particle_entity[client]);
				Format(active_particle[client], sizeof(active_particle[]), info);		
				int particle_ref = rp_AttachCreateParticle(client, active_particle[client], 0.0);
				particle_entity[client] = particle_ref;
			}	
		}
		else
		{
			if(IsValidEntity(particle_entity[client]))
			{
				RemoveParticle(particle_entity[client]);
				particle_entity[client] = -1;
				active_particle[client] = "";
			}
		}	

		SetClientCookie(client, Cookie_Particle, active_particle[client]);
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

void Menu_Skins(int client)
{
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_MenuSkin);
	menu.SetTitle("%T", "Title_Skins", LANG_SERVER);
	
	menu.AddItem("models/player/custom_player/kirby/sasterrorist/sas.mdl", "S.A.S");
	
	menu.ExitButton = true;
	menu.ExitBackButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Handle_MenuSkin(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[64];
		menu.GetItem(param, STRING(info));
		
		rp_SetClientString(client, sz_Skin, STRING(info));
		m_iClient[client].SetSkin();
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

void Menu_Finitions(int client)
{
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_MenuFinition);
	menu.SetTitle("%T", "Title_Finition", LANG_SERVER);
	
	menu.AddItem("1017", "Bleu phosphorescent");
	menu.AddItem("1026", "Dégradé");
	menu.AddItem("990", "Bismuth doré");
	menu.AddItem("988", "Néo-noir");
	menu.AddItem("1025", "Lingot d'or");
	menu.AddItem("984", "Iconographie");
	
	menu.ExitButton = true;
	menu.ExitBackButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Handle_MenuFinition(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[64];
		menu.GetItem(param, STRING(info));
		int paintID = StringToInt(info);
		RP_SetWeaponPattern(client, paintID);
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