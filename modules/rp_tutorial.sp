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

#define MAXSTAP			32
#define MAXSPAWN		16

/***************************************************************************************

							G L O B A L  -  V A R S

***************************************************************************************/

char 
	playerIP[MAXPLAYERS + 1][64];
Database 
	g_Database;
ArrayList
	g_aNationality;
	
float spawn_positions[MAXSPAWN][3];

enum struct Data_Forward {
	GlobalForward OnStepFinished;
}	
Data_Forward Forward;
	
enum struct Stap 
{
	// Tutorial stap max checkpoints
	int max_points;
	
	// Checkpoints vectors
	StringMap points_vectors_list;
	
	// Items rewards after finishing the stap
	ArrayList items_list;
	
	void Init()
	{
		this.max_points = 0;
		this.points_vectors_list = new StringMap();
		this.items_list = new ArrayList(32);
	}
}
Stap g_Stap[MAXSTAP];

enum struct Player
{
	// Player IP
	char ip[64];
	
	// Client database id
	int playerid;
	
	// Player userid.
	int userid;
	
	// Current stap id
	int current_stap;
	
	// Current stap point
	int current_point;
	
	// ScreenFade level
	int screen_fade[4];
	
	// Tutorial start cooldown
	int tutorial_cooldown;
	
	// Track refresh timer
	Handle timer;
	
	// Voice bot stap
	bool voice_bot;
	
	// Has an active helicopter air drop
	bool helicopter_drop;
	
	// Current tutorial stap menu
	Panel panel_handle;
	
	// Current player position vector
	float origin[3];
	
	// Next point origin vector
	float point_origin[3];

	void Init(int client)
	{
		if (!(this.playerid = rp_GetSQLID(client)))
		{
			return;
		}
		
		GetClientIP(client, this.ip, 64);
		
		this.userid = GetClientUserId(client);
		this.current_stap = 0;
		this.current_point = 1;
		this.screen_fade = { 255, 255, 255, 255 };
		this.timer = null;
		this.voice_bot = true;
		this.helicopter_drop = false;
		this.panel_handle = null;
		GetClientAbsOrigin(client, this.origin);
		this.point_origin = NULL_VECTOR;
		this.tutorial_cooldown = 10;
		
		this.FetchDB();
	}
	
	void Close()
	{
		this.playerid = 0;
		this.userid = 0;
		this.current_stap = 0;
		this.current_point = 0;
		this.screen_fade = { 255, 255, 255, 255 };
		if(this.timer != null)
			TrashTimer(this.timer, true);
		if(this.panel_handle != null)
			delete this.panel_handle;
		this.origin = NULL_VECTOR;
	}
	
	//============[ DB Help Functions ]============//
	
	void FetchDB()
	{
		char query[128];
		Format(query, sizeof(query), "SELECT * FROM `rp_players` WHERE `id` = '%d'", this.playerid);
		#if DEBUG
			PrintToServer(query);
		#endif
		g_Database.Query(SQL_FetchResult, query, this.userid);
	}
}
Player g_Players[MAXPLAYERS + 1];

/***************************************************************************************

							P L U G I N  -  I N F O

***************************************************************************************/
public Plugin myinfo = 
{
	name = "Roleplay - [MODULE] Tutorial", 
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
	// Load global translations
	LoadTranslation();
	LoadTranslations("rp_tutorial.phrases");
	
	//RegConsoleCmd("rp_tutorial", Command_Tutorial);
	RegConsoleCmd("tutotest", Command_Test);
}

public void OnMapStart()
{
	LoadStaps();
	
	/**************** NATIONALITY ****************/
	
	KeyValues kv = new KeyValues("Nationality");
	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, STRING(sPath), "data/roleplay/nationality.cfg");
	Kv_CheckIfFileExist(kv, sPath);
	
	g_aNationality = new ArrayList(32);
	
	// Jump into the first subsection
	if (!kv.GotoFirstSubKey())
	{
		PrintToServer("ERROR FIRST KEY");
		delete kv;
		return;
	}
	
	char sId[16];
	do
	{
		if(kv.GetSectionName(STRING(sId)))
		{
			char sName[128];
			kv.GetString("name", STRING(sName));
			
			Format(STRING(sName), "%s|%s", sId, sName);
			g_aNationality.PushString(sName);
		}
	} 
	while (kv.GotoNextKey());
	
	kv.Rewind();
	delete kv;
}

public APLRes AskPluginLoad2(Handle plugin, bool late, char[] error, int err_max)
{
	RegPluginLibrary("rp_tutorial");
	
	/*------------------------------------FORWADS------------------------------------*/
	Forward.OnStepFinished = new GlobalForward("RP_OnStepFinished", ET_Event, Param_Cell, Param_Cell);
	/*-------------------------------------------------------------------------------*/
	
	CreateNative("rp_OpenTutorial", Native_OpenTutorialStep);
	CreateNative("rp_GetNationalityName", Native_GetNationalityName);
	CreateNative("rp_GetSexeName", Native_GetSexeName);
	
	return APLRes_Success;
}	

public int Native_GetNationalityName(Handle plugin, int numParams) 
{
	int id = GetNativeCell(1);
	int maxlen = GetNativeCell(3) + 1;
	
	char sTmp[64];
	for (int i = 0; i < g_aNationality.Length; i++) 
	{
		g_aNationality.GetString(i, STRING(sTmp));
		
		if(!StrEqual(sTmp, ""))
		{
			char sBuffer[2][64];
			ExplodeString(sTmp, "|", sBuffer, 2, 64);
			
			if(StringToInt(sBuffer[0]) == id)
			{
				Format(STRING(sTmp), "%T", sBuffer[1], LANG_SERVER);
				SetNativeString(2, sTmp, maxlen);
			}
		}
	}
	
	return -1;
}

public int Native_GetSexeName(Handle plugin, int numParams) 
{
	int id = GetNativeCell(1);
	int maxlen = GetNativeCell(3) + 1;
	
	char sTmp[64];
	Format(STRING(sTmp), "Q14_option%i", id);
	Format(STRING(sTmp), "%T", sTmp, LANG_SERVER);
	SetNativeString(2, sTmp, maxlen);
	
	return -1;
}

public int Native_OpenTutorialStep(Handle plugin, int numParams) 
{
	int client = GetNativeCell(1);
	
	if(!IsClientValid(client))
		return -1;
		
	if(g_Players[client].panel_handle == null)
	{
		PrintToServer("Aucune quete du tutoriel n'as été enregistré!");
		return -1;
	}
		
	return g_Players[client].panel_handle.Send(client, HandleNothing, -1);
}

public void RP_OnSQLInit(Database db)
{
	g_Database = db;
	Transaction SQLInit = new Transaction();
	
	SQLInit.AddQuery("CREATE TABLE IF NOT EXISTS `rp_referal` ( \
	  `playerid` int(20) NOT NULL, \
	  `parentid` int(100) NOT NULL, \
	  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, \
	  PRIMARY KEY (`playerid`), \
	  UNIQUE KEY `playerid` (`playerid`), \
	  FOREIGN KEY (`playerid`) REFERENCES `rp_players` (`id`) ON DELETE CASCADE ON UPDATE CASCADE, \
	  FOREIGN KEY (`parentid`) REFERENCES `rp_players` (`id`) ON DELETE CASCADE ON UPDATE CASCADE \
	  )ENGINE = InnoDB DEFAULT CHARSET = utf8 COLLATE = utf8_bin;");
	
	db.Execute(SQLInit, SQL_OnSucces, SQL_OnFailed);
}

/***************************************************************************************

								    CLIENTS INIT

***************************************************************************************/

public void OnClientAuthorized(int client, const char[] auth) 
{
	GetClientIP(client, playerIP[client], sizeof(playerIP[]));
}

public void OnClientDisconnect(int client)
{
	rp_SetClientBool(client, b_IsNew, false);
	if(g_Players[client].timer != null)
		TrashTimer(g_Players[client].timer, true);
		
	g_Players[client].Close();
}

public void OnClientPutInServer(int client)
{
	rp_SetClientBool(client, b_IsNew, true);
	g_Players[client].Init(client);
}

public void RP_OnClientFirstSpawn(int client)
{
	if(rp_GetClientBool(client, b_IsNew))
	{
		rp_SetClientBool(client, b_IsPassive, true);
		if(rp_GetGame() == Engine_CSGO)
		{
			int number = GetRandomInt(1, MAXSPAWN);
			while (spawn_positions[number][0] == 0.0)
			{
				number = GetRandomInt(1, MAXSPAWN);
			}
			rp_ClientTeleport(client, spawn_positions[number]);
			
			SetEntProp(client, Prop_Send, "m_iHideHUD", GetEntProp(client, Prop_Send, "m_iHideHUD") | HIDE_RADAR_CSGO);
			
			rp_Sound(client, "sound_tutorial_00", 0.5);
			
			g_Players[client].voice_bot = true;
			g_Players[client].screen_fade = {0, 0, 0, 255};
			
			ScreenFade(client, 1, g_Players[client].screen_fade);
			CreateTimer(0.1, Timer_SetTutorialScreenFade, client, TIMER_REPEAT);
			
			LoadTutorial(client);
		}	
		rp_PrintToChatAll("{green}%N {default}vien de rejoindre le serveur pour la première fois.", client);
	}
}

/***************************************************************************************

									CALLBACK'S

***************************************************************************************/

public void SQL_FetchResult(Database db, DBResultSet Results, const char[] error, any data) 
{	
	int client = GetClientOfUserId(data);
	if(Results.FetchRow()) 
	{
		if(IsClientValid(client, true))
		{
			if(SQL_FetchIntByName(Results, "tutorial") == 0)
				rp_SetClientBool(client, b_IsNew, true);
			else
			{
				rp_SetClientBool(client, b_IsNew, false);

				rp_SetClientInt(client, i_Nationality, SQL_FetchIntByName(Results, "nationality"));
				rp_SetClientInt(client, i_Sexe, SQL_FetchIntByName(Results, "sexe"));
			}
		}
	}
}

public Action Command_Test(int client, int args)
{
	LoadTutorial(client);
	
	return Plugin_Handled;
}

void LoadTutorial(int client)
{
	LoadStaps();
	g_Players[client].current_point = 1;
	g_Players[client].current_stap = 0;
	g_Players[client].tutorial_cooldown = 10;
	g_Players[client].panel_handle = Tutorial_Information00(client);
	CreateTimer(10.0, Timer_StartTutorial, client);
	//Tutorial_Job(client);
}

public Action Timer_StartTutorial(Handle timer, int client)
{
	g_Players[client].panel_handle = Tutorial_Information01(client);
	
	return Plugin_Handled;
}

public void RP_ClientTimerEverySecond(int client)
{
	if(g_Players[client].tutorial_cooldown > 0)
	{
		g_Players[client].tutorial_cooldown--;
		ShowPanel2(client, 2, "Votre tutoriel commence dans <font color='%s'>%i</font> secondes", HTML_TURQUOISE, g_Players[client].tutorial_cooldown);
	}
}

// ----------------------------------------------------------------------------
Panel Tutorial_Information00(int client)
{
	if(rp_GetHudType(client) == HUD_PANEL || rp_GetHudType(client) == HUD_MSG)
		rp_SetClientBool(client, b_DisplayHud, false);

	Panel panel = new Panel();	
	panel.SetTitle("                    ♮ Roleplay - CSGO ♮");
	panel.DrawText("▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬");
	panel.DrawText("Ce mode a été développé par MbK(Benito)");
	panel.DrawText("\n\n ");
	panel.DrawText("Crédits: \n");
	panel.DrawText("KoNLiG, LuqS, TotenFluch & Alliedmodders");

	panel.Send(client, HandleNothing, 10);
	
	return panel;
}

Panel Tutorial_Information01(int client) 
{
	if(rp_GetHudType(client) == HUD_PANEL || rp_GetHudType(client) == HUD_MSG)
		rp_SetClientBool(client, b_DisplayHud, false);
	
	Panel panel = new Panel();	
	panel.SetTitle("== Bienvenue sur le serveur RolePlay");
	panel.DrawText(" C'est votre première connexion,");
	panel.DrawText("vous devez donc faire notre tutoriel ");
	panel.DrawText("afin de vous familiariser avec ce mode");
	panel.DrawText("de jeu. A la fin de celui-ci vous");
	panel.DrawText("gagnerez 25.000$: la monnaie du jeu");
	panel.DrawText(" ");
	panel.DrawText(" Ce mode Roleplay est une sorte de simulation");
	panel.DrawText("de vie: vous pouvez avoir de l'argent,");
	panel.DrawText("un emploi etc.");
	panel.DrawText(" ");
	
	char sTmp[64];
	Format(STRING(sTmp), "Léa: %s", (g_Players[client].voice_bot) ? "Activée" : "Désactivée");
	panel.DrawItem(sTmp);

	panel.DrawItem("Continuer ->");
	panel.Send(client, Information01_CallBack, -1);
	
	return panel;
}

public int Information01_CallBack(Menu menu, MenuAction action, int client, int param2) 
{
	if(action == MenuAction_Select) 
	{
		if(param2 == 1)
		{
			if(g_Players[client].voice_bot)
				g_Players[client].voice_bot = false;
			else if(!g_Players[client].voice_bot)
				g_Players[client].voice_bot = true;
			g_Players[client].panel_handle = Tutorial_Information01(client);
		}
		else
			g_Players[client].panel_handle = Tutorial_Information02(client);
	}
	else if(action == MenuAction_End) 
	{
		if( menu != INVALID_HANDLE )
			delete menu;
	}
	
	return 0;
}

Panel Tutorial_Information02(int client) 
{
	if(rp_GetHudType(client) == HUD_PANEL || rp_GetHudType(client) == HUD_MSG)
		rp_SetClientBool(client, b_DisplayHud, false);

	Panel panel = new Panel();
	panel.SetTitle("▬▬▬▬▬▬ Objectif Suivant ▬▬▬▬▬▬\n");
	panel.DrawText(" Oregon est la ville dans laquelle");
	panel.DrawText("vous êtes, c'est la map du serveur. La ");
	panel.DrawText("justice y fait souvent défaut. De nombreux");
	panel.DrawText("meurtres y sont commis, et parfois impunis.");
	panel.DrawText(" ");
	panel.DrawText(" Bien que de nombreux citoyens s'entretuent");
	panel.DrawText("sachez, avant tout, que vous risquez de rester");
	panel.DrawText("de longues minutes en prison pour de telles actions.");
	panel.DrawText(" ");
	panel.DrawItem("Continuer ->");	
	panel.Send(client, Information02_CallBack, -1);
	
	return panel;
}

public int Information02_CallBack(Menu menu, MenuAction action, int client, int param2) 
{
	if(action == MenuAction_Select) 
	{
		g_Players[client].panel_handle = Tutorial_Stap0(client);
		GPS_Tracer(client);
	}
	else if(action == MenuAction_End) 
	{
		if( menu != INVALID_HANDLE )
			delete menu;
	}
	
	return 0;
}

/*----------------------------------------------*/

Panel Tutorial_Stap0(int client) 
{
	if(g_Players[client].voice_bot)
		rp_Sound(client, "sound_tutorial_01", 0.5);
	
	rp_SetClientBool(client, b_DisplayHud, false);		
	Panel panel = new Panel();
	panel.SetTitle("▬▬▬▬▬▬ Objectif Suivant ▬▬▬▬▬▬\n");
	panel.DrawText(" ");
	panel.DrawText("    Rendez-vous à l'entrée du métro.");
	panel.Send(client, HandleNothing, -1);
	
	g_Players[client].current_stap = 0;
	GPS_Tracer(client);
	
	return panel;
}

Panel Tutorial_Stap1(int client) 
{
	if(g_Players[client].voice_bot)
		rp_Sound(client, "sound_tutorial_arrow", 0.5);
	
	rp_SetClientBool(client, b_DisplayHud, false);		
	Panel panel = new Panel();
	panel.SetTitle("▬▬▬▬▬▬ Objectif Suivant ▬▬▬▬▬▬\n");
	panel.DrawText(" ");
	panel.DrawText("        Rendez-vous à l'épicerie.");
	panel.DrawText(" ");
	panel.DrawText(" A ce lieux vous pourrez vous approvisionner");
	panel.DrawText("en crédits de communication, crayon de couleures");
	panel.DrawText("et tout ce qui est matière première.");
	panel.Send(client, HandleNothing, -1);
	
	return panel;
}

Panel Tutorial_Stap2(int client) 
{
	if(g_Players[client].voice_bot)
		rp_Sound(client, "sound_tutorial_arrow", 0.5);
	
	rp_SetClientBool(client, b_DisplayHud, false);		
	Panel panel = new Panel();
	panel.SetTitle("▬▬▬▬▬▬ Objectif Suivant ▬▬▬▬▬▬\n");
	panel.DrawText(" ");
	panel.DrawText("        Rendez-vous à l'hôtel.");
	panel.DrawText(" ");
	panel.DrawText(" A ce lieux vous pourrez louer une chambre");
	panel.DrawText("le tarif est payé par jour (en jeu, 30 minutes réel).");
	panel.Send(client, HandleNothing, -1);
	
	return panel;
}

Panel Tutorial_Stap3(int client) 
{
	if(g_Players[client].voice_bot)
		rp_Sound(client, "sound_tutorial_arrow", 0.5);
	
	rp_SetClientBool(client, b_DisplayHud, false);		
	Panel panel = new Panel();
	panel.SetTitle("▬▬▬▬▬▬ Objectif Suivant ▬▬▬▬▬▬\n");
	panel.DrawText(" ");
	panel.DrawText("        Rendez-vous chez H & M.");
	panel.DrawText(" ");
	panel.DrawText(" A ce lieux vous pourrez changer votre tenue,");
	panel.DrawText("changer la finition de votre arme &");
	panel.DrawText("acheter un couteau personnalisé.");
	panel.Send(client, HandleNothing, -1);
	
	return panel;
}

Panel Tutorial_Stap4(int client) 
{
	if(g_Players[client].voice_bot)
		rp_Sound(client, "sound_tutorial_arrow", 0.5);
	
	rp_SetClientBool(client, b_DisplayHud, false);		
	Panel panel = new Panel();
	panel.SetTitle("▬▬▬▬▬▬ Objectif Suivant ▬▬▬▬▬▬\n");
	panel.DrawText(" ");
	panel.DrawText("        Rendez-vous aux appartements");
	panel.DrawText(" ");
	panel.DrawText(" A ce lieux vous pourrez louer un appartement,");
	panel.DrawText("faire de la colocation si cela vous chante,");
	panel.DrawText("vous pouvez ansi aussi profiter des bonus");
	panel.DrawText("proposé lors de votre achat.");
	panel.Send(client, HandleNothing, -1);
	
	return panel;
}

Panel Tutorial_Stap5(int client) 
{
	if(g_Players[client].voice_bot)
		rp_Sound(client, "sound_tutorial_arrow", 0.5);
	
	rp_SetClientBool(client, b_DisplayHud, false);		
	Panel panel = new Panel();
	panel.SetTitle("▬▬▬▬▬▬ Objectif Suivant ▬▬▬▬▬▬\n");
	panel.DrawText(" ");
	panel.DrawText("        Rendez-vous à la banque");
	panel.DrawText(" ");
	panel.DrawText(" A ce lieux vous pourrez retirer, déposer,");
	panel.DrawText("et emprunter de l'argent.");
	panel.DrawText("Tout ce-ci sera disponible via un ATM");
	panel.Send(client, HandleNothing, -1);
	
	return panel;
}

Panel Tutorial_Stap6(int client) 
{
	if(g_Players[client].voice_bot)
		rp_Sound(client, "sound_tutorial_arrow", 0.5);
	
	rp_SetClientBool(client, b_DisplayHud, false);		
	Panel panel = new Panel();
	panel.SetTitle("▬▬▬▬▬▬ Objectif Suivant ▬▬▬▬▬▬\n");
	panel.DrawText(" ");
	panel.DrawText("        Rendez-vous au kebab");
	panel.DrawText(" ");
	panel.DrawText(" A ce lieux vous pourrez vous nourrir.");
	panel.DrawText("Si votre barre de faim est basse n'oubliez pas");
	panel.DrawText("de passer au kebab :D");
	panel.Send(client, HandleNothing, -1);
	
	return panel;
}

Panel Tutorial_Stap7(int client) 
{
	if(g_Players[client].voice_bot)
		rp_Sound(client, "sound_tutorial_arrow", 0.5);
	
	rp_SetClientBool(client, b_DisplayHud, false);		
	Panel panel = new Panel();
	panel.SetTitle("▬▬▬▬▬▬ Objectif Suivant ▬▬▬▬▬▬\n");
	panel.DrawText(" ");
	panel.DrawText("        Rendez-vous chez Mercedes-Benz");
	panel.DrawText(" ");
	panel.DrawText(" A ce lieux vous pourrez louer ou bien acheter.");
	panel.DrawText("une voiture, n'oubliez pas d'avoir un permis ^^");
	panel.Send(client, HandleNothing, -1);
	
	return panel;
}

Panel Tutorial_Stap8(int client) 
{
	if(g_Players[client].voice_bot)
		rp_Sound(client, "sound_tutorial_arrow", 0.5);
	
	rp_SetClientBool(client, b_DisplayHud, false);		
	Panel panel = new Panel();
	panel.SetTitle("▬▬▬▬▬▬ Objectif Suivant ▬▬▬▬▬▬\n");
	panel.DrawText(" ");
	panel.DrawText("        Rendez-vous chez l'artificier");
	panel.DrawText(" ");
	panel.DrawText(" A ce lieux vous pourrez acheter tout ce.");
	panel.DrawText("qui fait partie de la catégorie explosives,");
	panel.DrawText("c'est à dire: HE, C4, Mines, etc...");
	panel.Send(client, HandleNothing, -1);
	
	return panel;
}

Panel Tutorial_Stap9(int client) 
{
	if(g_Players[client].voice_bot)
		rp_Sound(client, "sound_tutorial_arrow", 0.5);
	
	rp_SetClientBool(client, b_DisplayHud, false);		
	Panel panel = new Panel();
	panel.SetTitle("▬▬▬▬▬▬ Objectif Suivant ▬▬▬▬▬▬\n");
	panel.DrawText(" ");
	panel.DrawText("        Rendez-vous chez à l'armurerie");
	panel.DrawText(" ");
	panel.DrawText(" A ce lieux vous pourrez acheter tout ce.");
	panel.DrawText("qui fait office d'arme.");
	panel.DrawText("A la fin de cette étape vous obtiendrai un");
	panel.DrawText("échantillon");
	panel.Send(client, HandleNothing, -1);
	
	return panel;
}

Panel Tutorial_Stap10(int client) 
{
	if(g_Players[client].voice_bot)
		rp_Sound(client, "sound_tutorial_arrow", 0.5);
	
	rp_SetClientBool(client, b_DisplayHud, false);		
	Panel panel = new Panel();
	panel.SetTitle("▬▬▬▬▬▬ Objectif Suivant ▬▬▬▬▬▬\n");
	panel.DrawText(" ");
	panel.DrawText("        Rendez-vous chez à la mairie");
	panel.DrawText(" ");
	panel.DrawText(" A ce lieux vous pourrez consulter toutes");
	panel.DrawText("les dernières informations conçernant");
	panel.DrawText("la ville. Cele-ci peut aussi vous aider à");
	panel.DrawText("trouver un métier.");
	panel.Send(client, HandleNothing, -1);
	
	return panel;
}

Panel Tutorial_Stap11(int client) 
{
	if(g_Players[client].voice_bot)
		rp_Sound(client, "sound_tutorial_arrow", 0.5);
	
	rp_SetClientBool(client, b_DisplayHud, false);		
	Panel panel = new Panel();
	panel.SetTitle("▬▬▬▬▬▬ Objectif Suivant ▬▬▬▬▬▬\n");
	panel.DrawText(" ");
	panel.DrawText("        Rendez-vous au commissariat");
	panel.DrawText(" ");
	panel.DrawText(" Selon le règlement de la police, vous");
	panel.DrawText("pouvez être mis en prison dans ce");
	panel.DrawText("commissariat pour différentes raisons.");
	panel.DrawText(" ");
	panel.DrawText(" Les principales raisons d’incarcération");
	panel.DrawText("sont: Le meurtre ou la tentative");
	panel.DrawText("de meurtre, le tir dans la rue, le vol,");
	panel.DrawText("les nuisances sonores, le trafic illégal");
	panel.DrawText(" ");
	panel.DrawText(" Votre futur emploi définira votre");
	panel.DrawText("camp. Par exemple, un mafieux vole de l'argent,");
	panel.DrawText("un mercenaire exécute des contrats, un");
	panel.DrawText("policier tentera de les en empêcher.");
	panel.Send(client, HandleNothing, -1);
	
	return panel;
}

Panel Tutorial_Stap12(int client) 
{
	if(g_Players[client].voice_bot)
		rp_Sound(client, "sound_tutorial_arrow", 0.5);
	
	rp_SetClientBool(client, b_DisplayHud, false);		
	Panel panel = new Panel();
	panel.SetTitle("▬▬▬▬▬▬ Objectif Suivant ▬▬▬▬▬▬\n");
	panel.DrawText(" ");
	panel.DrawText("        Rendez-vous au parking de l'hôpital");
	panel.DrawText(" ");
	panel.DrawText(" Selon le règlement de la police, vous");
	panel.DrawText("pouvez être mis en prison dans ce");
	panel.DrawText("commissariat pour différentes raisons.");
	panel.DrawText(" ");
	panel.DrawText(" Les principales raisons d’incarcération");
	panel.DrawText("sont: Le meurtre ou la tentative");
	panel.DrawText("de meurtre, le tir dans la rue, le vol,");
	panel.DrawText("les nuisances sonores, le trafic illégal");
	panel.DrawText(" ");
	panel.DrawText(" Votre futur emploi définira votre");
	panel.DrawText("camp. Par exemple, un mafieux vole de l'argent,");
	panel.DrawText("un mercenaire exécute des contrats, un");
	panel.DrawText("policier tentera de les en empêcher.");
	
	//panel.DrawItem("Passer le tutoriel");
	
	panel.Send(client, HandleNothing, -1);
	
	return panel;
}

/*----------------------------------------------*/

Panel Tutorial_Nationality(int client) 
{	
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_MenuNationality);
	
	menu.SetTitle("▬▬▬▬▬▬ %t ▬▬▬▬▬▬\n Selectionnez votre nationalité.\n ", "Q13_title", LANG_SERVER);		
	
	char sTmp[128];
	int count;
	for (int i = 0; i < g_aNationality.Length; i++) 
	{
		g_aNationality.GetString(i, STRING(sTmp));
		
		if(!StrEqual(sTmp, ""))
		{
			count++;
			
			char sBuffer[2][64];
			ExplodeString(sTmp, "|", sBuffer, 2, 64);
			
			Format(STRING(sTmp), "%T", sBuffer[1], LANG_SERVER);
			menu.AddItem(sBuffer[0], sTmp);
		}
	}	
	
	if(count == 0)
		menu.AddItem("0", "None", ITEMDRAW_DISABLED);
	
	menu.ExitButton = false;
	menu.Display(client, MENU_TIME_FOREVER);
	
	return vPanel(menu);
}

public int Handle_MenuNationality(Menu menu, MenuAction action, int client, int param) 
{
	if(action == MenuAction_Select) 
	{
		char info[8];
		menu.GetItem(param, STRING(info));		
		
		rp_SetClientInt(client, i_Nationality, StringToInt(info));
		
		char sTmp[64];
		rp_GetNationalityName(StringToInt(info), STRING(sTmp));
		rp_PrintToChat(client, "%T", "Chat_SelectedOption", LANG_SERVER, sTmp);
		
		Tutorial_Gender(client);
	}
	else if(action == MenuAction_End)
	{
		delete menu;
	}
	
	return 0;
}

Panel Tutorial_Gender(int client) 
{	
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_MenuSexe);
	
	menu.SetTitle("▬▬▬▬▬▬ %t ▬▬▬▬▬▬\n Selectionnez votre sexe.\n ", "Q14_title", LANG_SERVER);		
	
	char sTmp[64];
	
	Format(STRING(sTmp), "%T", "Q14_option1", LANG_SERVER);
	menu.AddItem("1", sTmp);
	
	Format(STRING(sTmp), "%T", "Q14_option2", LANG_SERVER);
	menu.AddItem("2", sTmp);
	
	menu.ExitButton = false;
	menu.Display(client, MENU_TIME_FOREVER);
	
	return vPanel(menu);
}

public int Handle_MenuSexe(Menu menu, MenuAction action, int client, int param) 
{
	if(action == MenuAction_Select) 
	{
		char info[64];
		menu.GetItem(param, STRING(info));		
		
		rp_SetClientInt(client, i_Sexe, StringToInt(info));
		
		char sTmp[64];
		rp_GetSexeName(StringToInt(info), STRING(sTmp));
		rp_PrintToChat(client, "%T", "Chat_SelectedOption", LANG_SERVER, sTmp);
		
		Tutorial_Referal(client);
	}
	else if(action == MenuAction_End)
	{
		delete menu;
	}
	
	return 0;
}

Panel Tutorial_Referal(int client) 
{	
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_MenuReferal);
	menu.SetTitle("▬▬▬▬▬▬ Parrainage ▬▬▬▬▬▬");
				
	menu.AddItem("", "Quelqu'un de présent vous a t-il invité", ITEMDRAW_DISABLED);
	menu.AddItem("", "à jouer sur notre serveur?  Si oui, qui?\n ", ITEMDRAW_DISABLED);

	menu.AddItem("none", "Personne, j'ai connu autrement le serveur");
	menu.AddItem("youtube", "Youtube, en regardant une vidéo");
			
	char szName[128];
	LoopClients(i) 
	{
		if(!IsClientValid(i))
			continue;
		if( i == client )
			continue;
					
		char sId[8];
		Format(STRING(sId), "%i", rp_GetSQLID(i));
		
		Format(STRING(szName), "%N", i);					
		menu.AddItem(sId, szName);
	}
				
	menu.ExitButton = false;
	menu.Display(client, MENU_TIME_FOREVER);
	
	return vPanel(menu);
}

public int Handle_MenuReferal(Menu menu, MenuAction action, int client, int param) 
{
	if(action == MenuAction_Select) 
	{
		char info[64];
		menu.GetItem(param, STRING(info));		
		
		if(!StrEqual(info, "none")) 
		{
			SQL_Request(g_Database, "INSERT IGNORE INTO `rp_referal` (`playerid`, `parentid`, `timestamp`) VALUES ('%i', '%i', CURRENT_TIMESTAMP);", rp_GetSQLID(client), StringToInt(info));
			
			int parent = StringToInt(info);
			
			if(IsClientValid(parent))
				rp_PrintToChat(parent, "{green}Merci {default} d'avoir parainé {lightred}%N{default}.", client);
		}
		
		Tutorial_Job(client);
		
		rp_SetClientInt(client, i_Bank, rp_GetClientInt(client, i_Bank) + 7500);
	}
	else if(action == MenuAction_End)
	{
		delete menu;
	}
	
	return 0;
}

Panel Tutorial_Job(int client) 
{
	rp_SetClientBool(client, b_DisplayHud, false);
		
	Menu menu = new Menu(Handle_MenuJob);
	menu.SetTitle("== Votre premier job vous est offert\n ");
	menu.AddItem("", "Sachez que plus tard, vous devrez le trouver", ITEMDRAW_DISABLED);
	menu.AddItem("", "vous-même et être recruté par le chef d'un job.\n ", ITEMDRAW_DISABLED);
		
	char jobName[32], tmp2[8];
	
	for(int i = 1; i <= MAXJOBS; i++) 
	{		
		rp_GetJobName(i, STRING(jobName));
		
		if(i != 1 && i != 7 && i != 5)
		{
			Format(STRING(tmp2), "%i", i);
			menu.AddItem(tmp2, jobName);
		}	
	}
				
	menu.ExitButton = false;
	menu.Display(client, MENU_TIME_FOREVER);
	
	return vPanel(menu);
}
public int Handle_MenuJob(Menu menu, MenuAction action, int client, int param2) 
{
	if(action == MenuAction_Select) 
	{
		char options[64];
		menu.GetItem(param2, STRING(options));
		int job = StringToInt(options);
		
		char jobname[32];
		rp_GetJobName(job, STRING(jobname));
		
		Menu menu2 = new Menu(Handle_MenuSelectJobFinal);			
		menu2.SetTitle("== Votre premier job vous est offert\nVous avez choisis comme métier\n%s\n \nSachez que plus tard, vous devrez le trouver\nVOUS-MÊME et être recruté par le chef d'un job.\n---------------------", jobname);
		
		menu2.AddItem("0", "Je veux choisir un autre job");
		menu2.AddItem(options, "Je confirme mon choix");
		menu2.ExitButton = false;
		menu2.Display(client, MENU_TIME_FOREVER);
	
		rp_SetClientInt(client, i_Job, job);
		rp_SetClientInt(client, i_Grade, rp_GetJobMaxGrades(job));
		rp_SetClientInt(client, i_Salary, rp_GetGradeSalary(rp_GetClientInt(client, i_Job), rp_GetClientInt(client, i_Grade)));
		
		FakeClientCommand(client, "say /shownotes");
		
		rp_SetClientBool(client, b_IsNew, false);
		
		SQL_Request(g_Database, "UPDATE `rp_players` SET `tutorial` = '1', `nationality` = '%i', `sexe` = '%i' WHERE `id` = '%i';", rp_GetClientInt(client, i_Nationality), rp_GetClientInt(client, i_Sexe), g_Players[client].playerid);
		
		char sTmp[128];
		Format(STRING(sTmp), "%N vient de terminer son tutorial.", client);
		rp_PrintToChatAll(sTmp);
		rp_LogToDiscord(sTmp);
	}
	else if( action == MenuAction_End ) 
	{
		delete menu;
	}
	
	return 0;
}

public int Handle_MenuSelectJobFinal(Menu menu, MenuAction action, int client, int param) 
{
	if(action == MenuAction_Select) 
	{
		char options[64];
		menu.GetItem(param, STRING(options));
		
		if(StrEqual(options, "0"))
			Tutorial_Job(client);
		else
		{
			rp_SendHelicopter(client, GIFT);
			g_Players[client].helicopter_drop = true;
			
			rp_SetClientBool(client, b_DisplayHud, false);
			Panel panel = new Panel();
			panel.SetTitle("Livraison - Cadeau");
			panel.DrawText("     \n\n");
			panel.DrawText("Un hélicoptère est en route,");
			panel.DrawText("Celui-ci vous fera un drop d'un cadeau.");
			panel.DrawText("Appuyez E dessus pour récuperer votre récompense.");
			panel.DrawText("     \n\n");
			panel.DrawText("Profitez-en et bon jeu!");
			panel.Send(client, HandleNothing, 15);
			rp_PrintToChat(client, "Bon jeu !");
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

void GPS_Tracer(int client)
{
	char sValue[32], sKey[8];
	IntToString(g_Players[client].current_point, STRING(sKey));
	g_Stap[g_Players[client].current_stap].points_vectors_list.GetString(sKey, STRING(sValue));
	
	StringToVector(sValue, g_Players[client].point_origin);
	g_Players[client].point_origin[2] += 15.0;
	
	if(g_Players[client].timer == null && IsClientValid(client))
		g_Players[client].timer = CreateTimer(0.5, Timer_RefreshGps, client, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);	
}

public void RP_OnClientInteract(int client, int target, const char[] class, const char[] model, const char[] name)
{
	char sModel[256];
	rp_GetGlobalData("model_airdrop", STRING(sModel));
	if(StrEqual(model, sModel))
	{
		if(g_Players[client].helicopter_drop)
		{
			int owner = Client_FindBySteamId(name);
			if(owner == client)
			{
				RemoveEdict(target);
				
				g_Players[client].helicopter_drop = false;
				
				rp_SetClientInt(client, i_Bank, rp_GetClientInt(client, i_Bank) + 15000);
				rp_PrintToChat(client, "Vous avez reçu {lightgreen}15000{lightred}$ {default}pour votre départ.");
			}
		}
	}
}

public Action Timer_SetTutorialScreenFade(Handle timer, int client)
{
	if(IsClientValid(client))
	{
		if(g_Players[client].screen_fade[3] > 0)
		{
			g_Players[client].screen_fade[3] -= 5;
			ScreenFade(client, 1, g_Players[client].screen_fade);
		}
		else
			TrashTimer(timer, true);
	}
	
	return Plugin_Handled;
}

stock Action Timer_RefreshGps(Handle timer, int client)
{
	if(!IsClientValid(client))
		TrashTimer(g_Players[client].timer, true);

	GetClientAbsOrigin(client, g_Players[client].origin);
	g_Players[client].origin[2] += 15.0;

	if(GetVectorDistance(g_Players[client].point_origin, g_Players[client].origin) <= 64.0)
	{
		g_Players[client].current_point++;
		GPS_Tracer(client);
		
		if(g_Players[client].current_point > g_Stap[g_Players[client].current_stap].max_points)
		{
			/**********************************************************************
			*							RP_OnStepFinished
			***********************************************************************/
			Call_StartForward(Forward.OnStepFinished);
			Call_PushCell(client);
			Call_PushCell(g_Players[client].current_stap);
			Call_Finish();
			
			g_Players[client].current_point = 1;
			g_Players[client].current_stap++;
			
			TrashTimer(g_Players[client].timer, true);
			GPS_Tracer(client);
		}
	}
			
	//rp_PrintToChat(client, "Marche encore un peu t'y est près");
	EmitGPSTwiceTrain(client, g_Players[client].point_origin, g_Players[client].origin);
	
	int g_BeamSprite = PrecacheModel("sprites/laserbeam.vmt", true);
	int g_HaloSprite = PrecacheModel("sprites/halo.vmt", true);
	
	int color[4];
	color[0] = GetRandomInt(1, 255);
	color[1] = GetRandomInt(1, 255);
	color[2] = GetRandomInt(1, 255);
	color[3] = 255;
	
	TE_SetupBeamRingPoint(g_Players[client].point_origin, 5.0, 50.0, g_BeamSprite, g_HaloSprite, 0, 5, 0.5, 5.0, 1.0, color, 50, 0);
	TE_SendToClient(client);
	
	return Plugin_Handled;
}

void LoadStaps()
{
	KeyValues kv = new KeyValues("Tutorial");
	char sPath[PLATFORM_MAX_PATH], map[64];
	rp_GetCurrentMap(STRING(map));
	BuildPath(Path_SM, STRING(sPath), "data/roleplay/%s/tutorial.cfg", map);		
	Kv_CheckIfFileExist(kv, sPath);
	
	if(kv.JumpToKey("spawn_pos"))
	{
		int max_spawn = kv.GetNum("max_spawns");
		
		for(int i = 1; i <= max_spawn; i++)
		{
			float vector[3];
			
			char sTmp[8];
			IntToString(i, STRING(sTmp));
			kv.GetVector(sTmp, vector);
			
			if(vector[0] != 0.0 && vector[1] != 0.0 && vector[2] != 0.0)
				spawn_positions[i] = vector;
		}
		
		kv.GoBack();
	}
	
	if(kv.JumpToKey("staps"))
	{
		if (!kv.GotoFirstSubKey())
		{
			delete kv;
			return;
		}
		
		char sId[16];
		do
		{
			if(kv.GetSectionName(STRING(sId)))
			{
				int id = StringToInt(sId);
				
				g_Stap[id].Init();
				g_Stap[id].max_points = kv.GetNum("max_points");
				
				for(int point = 1; point <= g_Stap[id].max_points; point++)
				{
					char sKey[8], sValue[32];
					IntToString(point, STRING(sKey));
					kv.GetString(sKey, STRING(sValue));
					
					g_Stap[id].points_vectors_list.SetString(sKey, sValue);
				}
				
				char sItems[64];
				kv.GetString("items_reward", STRING(sItems));
				
				
				if(!StrEqual(sItems, ""))
				{
					char buffer[16][32];
					
					for(int i = 0; i < sizeof(buffer); i++)
						if(!StrEqual(buffer[i], ""))
							g_Stap[id].items_list.Push(StringToInt(buffer[i]));
				}
			}
		} 
		while (kv.GotoNextKey());
	}
	
	kv.Rewind();
	delete kv;
}

public void RP_OnStepFinished(int client, TUTORIAL_STEP step)
{
	ShowPanel2(client, 2, "<font color='%s'>Vous avez fini une étape</font>", HTML_CHARTREUSE);
	
	switch(step)
	{
		case STEP_METRO:{
			rp_PrintToChat(client, "Vous avez découvert {lightgreen}le métro.");
			g_Players[client].panel_handle = Tutorial_Stap1(client); // NEXT STORE
		}
		case STEP_STORE:{
			rp_PrintToChat(client, "Vous avez découvert {lightgreen}l'épicerie.");
			g_Players[client].panel_handle = Tutorial_Stap2(client); // NEXT HOTEL
		}
		case STEP_HOTEL:{
			rp_PrintToChat(client, "Vous avez découvert {lightgreen}l'hôtel.");
			g_Players[client].panel_handle = Tutorial_Stap3(client); // NEXT H&M
		}
		case STEP_SKINSELLER:{
			rp_PrintToChat(client, "Vous avez découvert {lightgreen}H&M.");
			g_Players[client].panel_handle = Tutorial_Stap4(client); // NEXT APPARTEMENTS
			// Vous avez remporter le succès de la sapologie
		}
		case STEP_APPARTEMENT:{
			rp_PrintToChat(client, "Vous avez découvert {lightgreen}les appartements.");
			g_Players[client].panel_handle = Tutorial_Stap5(client); // NEXT BANK
		}
		case STEP_BANK:{
			rp_PrintToChat(client, "Vous avez découvert {lightgreen}la banque nationale.");
			g_Players[client].panel_handle = Tutorial_Stap6(client); // NEXT KEBAB
		}
		case STEP_KEBAB:{
			rp_PrintToChat(client, "Vous avez découvert {lightgreen}le kebab.");
			g_Players[client].panel_handle = Tutorial_Stap7(client); // NEXT MERCEDES-BENZ
		}
		case STEP_MERCEDES:{
			rp_PrintToChat(client, "Vous avez découvert {lightgreen}le concessionnaire Mercedes-Benz.");
			g_Players[client].panel_handle = Tutorial_Stap8(client); // NEXT ARTIFICER
		}
		case STEP_ARTIFICER:{
			rp_PrintToChat(client, "Vous avez découvert {lightgreen}l'industrie de l'artificerie.");
			g_Players[client].panel_handle = Tutorial_Stap9(client); // NEXT ARTIFICER
		}
		case STEP_AMMUNATION:{
			rp_PrintToChat(client, "Vous avez découvert {lightgreen}l'armurerie.");
			g_Players[client].panel_handle = Tutorial_Stap10(client); // NEXT TOWNHALL
		}
		case STEP_TOWNHALL:{
			rp_PrintToChat(client, "Vous avez découvert {lightgreen}la mairie.");
			g_Players[client].panel_handle = Tutorial_Stap11(client); // NEXT POLICE
		}
		case STEP_POLICE:{
			rp_PrintToChat(client, "Vous avez découvert {lightgreen}le commissariat.");
			g_Players[client].panel_handle = Tutorial_Stap12(client); // NEXT TOWNHALL
		}
		case STEP_HOSPITAL:{
			rp_PrintToChat(client, "Vous avez découvert {lightgreen}l'hôpital.");
			rp_PrintToChat(client, "Une voiture vous a été prétée pendant 1 heure, faites-en bon usage !");
			g_Players[client].panel_handle = Tutorial_Nationality(client); // NEXT TOWNHALL
			
			rp_SetClientBool(client, b_IsPassive, false);
			
			if(g_Players[client].timer != null)
				TrashTimer(g_Players[client].timer, true);
		}
	}
	
	for(int i = 0; i <= g_Stap[step].items_list.Length; i++)
	{
		int item = g_Stap[step].items_list.Get(i);
		
		char sName[64];
		rp_GetItemData(item, item_name, STRING(sName));
		rp_SetClientItem(client, item, rp_GetClientItem(client, item) + 1);
		rp_PrintToChat(client, "Vous avez reçu 1 %s", sName);
	}
}