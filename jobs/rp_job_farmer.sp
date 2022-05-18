/*
*   Roleplay CS:GO de Benito est mis à disposition selon les termes de la licence Creative Commons Attribution .
* - Pas d’Utilisation Commerciale 
* - Partage dans les Mêmes Conditions 4.0 International.
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

							P L U G I N  -  D E F I N E S

***************************************************************************************/

#define JOBID				21
#define MAX_WATERATTEMPT	3
#define GROW_MAXSTEP		6

/***************************************************************************************

							G L O B A L  -  V A R S

***************************************************************************************/

enum struct ClientData {
	char SteamID[32];
}
ClientData iData[MAXPLAYERS + 1];

Database g_DB;

enum struct cvar 
{
	ConVar growup;
	ConVar min_produce;
	ConVar max_produce;
}
cvar cvars;

enum PlantType{
	NONE = 0,
	CORN,
	LETTUCE,
	PEPPER,
	TOMATO,
	WHEAT
}

enum struct HoleData
{
	//CONSTRUCTOR
	int entity_index;
	
	int level;
	int owner;
	int water;
	int WaterTooMuchAttempt;
	PlantType plant;
	Handle Timer_Grow;
	
	void SetWeedsLevel()
	{
		SetBodyGroup(this.entity_index, GetEntityStudioHdr(this.entity_index).FindBodyPart("weeds"), this.level);
	}
	void SetPlant()
	{
		SetBodyGroup(this.entity_index, GetEntityStudioHdr(this.entity_index).FindBodyPart("plant"), vint(this.plant));
	}
}
HoleData g_iHole[MAXENTITIES + 1];

enum struct LampData
{
	bool HasBattery;
	bool Light;
	int entity_index;
	int batterylevel;
	
	void SetBattery(bool value = false)
	{
		this.HasBattery = value;
		SetBodyGroup(this.entity_index, GetEntityStudioHdr(this.entity_index).FindBodyPart("battery"), vint(value));
	}
	void SetBatteryLevel(int value)
	{
		this.batterylevel = value;
		SetBodyGroup(this.entity_index, GetEntityStudioHdr(this.entity_index).FindBodyPart("battery_meter_segments"), value);
	}
	void SetLight(bool value = false)
	{
		if(!value)
			PlayAnimation(this.entity_index, "switch_onoff");
		else
			PlayAnimation(this.entity_index, "switch_offon");
		
		this.Light = value;
		SetBodyGroup(this.entity_index, GetEntityStudioHdr(this.entity_index).FindBodyPart("volumetric"), vint(value));
		SetEntProp(this.entity_index, Prop_Send, "m_nSkin", vint(value));
	}
}
LampData g_iLamp[MAXENTITIES + 1];

enum struct SeedData
{
	int entity_index;
	
	void GetTypeName(char[] buffer, int maxlength)
	{
		int type = GetEntProp(this.entity_index, Prop_Send, "m_nSkin");
		char sTmp[16];
		switch(type)
		{
			case 0:Format(buffer, sizeof(maxlength), "Lettuce");
			case 1:Format(buffer, sizeof(maxlength), "Bell Pepper");
			case 2:Format(buffer, sizeof(maxlength), "Tomato");
			case 3:Format(buffer, sizeof(maxlength), "Wheat");
			case 4:Format(buffer, sizeof(maxlength), "Corn");
		}
	}
}
SeedData g_iSeed[MAXENTITIES + 1];

/***************************************************************************************

							P L U G I N  -  I N F O

***************************************************************************************/
public Plugin myinfo = 
{
	name = "Roleplay - [JOB] Farmer", 
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
	
	/*----------------------------------Local ConVars-------------------------------*/
	cvars.growup = CreateConVar("rp_grow_timer", "10.0", "Timer d'interval en secondes pour que le terreau pousse.");
	
	cvars.min_produce = CreateConVar("rp_min_produce", "5", "Minimum number between the maximum for production.");
	cvars.max_produce = CreateConVar("rp_max_produce", "10", "Maximum number between the minimum for production.");
	
	AutoExecConfig(true, "rp_job_farmer", "roleplay");
	/*------------------------------------------------------------------------*/
}

public void OnPluginEnd()
{
}

// Init SQL
public void RP_OnSQLInit(Database db)
{
	g_DB = db;
}


/***************************************************************************************

									C A L L B A C K

***************************************************************************************/

public void RP_OnClientBuild(Menu menu, int client)
{
	if(rp_GetClientInt(client, i_Job) == JOBID)
	{
		menu.AddItem("farm", "Produire");
	}
}

public void RP_OnClientBuildHandle(int client, const char[] info)
{
	if(StrEqual(info, "farm"))
		MenuBuildFarm(client);
}

void MenuBuildFarm(int client)
{
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_MenuBuildDrugs);
	menu.SetTitle("Productions d'ingrédients");
	
	menu.AddItem("corn", "Corn");
	menu.AddItem("lettuce", "Lettuce");
	menu.AddItem("pepper", "Pepper");
	menu.AddItem("tomato", "Tomato");
	menu.AddItem("wheat", "Wheat");
	menu.AddItem("hole", "Hole");
	menu.AddItem("lamp", "Lamp");
	menu.AddItem("seeds", "Seeds");
	
	menu.ExitButton = true;
	menu.ExitBackButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Handle_MenuBuildDrugs(Menu menu, MenuAction action, int client, int param)
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
				
				char sTmp[128];
				
				if (StrEqual(info, "corn"))
				{
					rp_GetGlobalData("model_corn", STRING(sTmp));
					ent = rp_CreatePhysics("", TeleportOrigin, NULL_VECTOR, sTmp, 0, true);
					rp_PrintToChat(client, "Vous avez placé un maïs.");
				}
				else if (StrEqual(info, "lettuce"))
				{
					rp_GetGlobalData("model_lettuce", STRING(sTmp));
					ent = rp_CreatePhysics("", TeleportOrigin, NULL_VECTOR, sTmp, 0, true);
					rp_PrintToChat(client, "Vous avez placé un emplacement de plantation.");
				}
				else if (StrEqual(info, "pepper"))
				{
					rp_GetGlobalData("model_pepper", STRING(sTmp));
					ent = rp_CreatePhysics("", TeleportOrigin, NULL_VECTOR, sTmp, 0, true);
					rp_PrintToChat(client, "Vous avez placé un emplacement de plantation.");
				}
				else if (StrEqual(info, "tomato"))
				{
					rp_GetGlobalData("model_tomato", STRING(sTmp));
					ent = rp_CreatePhysics("", TeleportOrigin, NULL_VECTOR, sTmp, 0, true);
					rp_PrintToChat(client, "Vous avez placé un emplacement de plantation.");
				}
				else if (StrEqual(info, "wheat"))
				{
					rp_GetGlobalData("model_wheat", STRING(sTmp));
					ent = rp_CreatePhysics("", TeleportOrigin, NULL_VECTOR, sTmp, 0, true);
					rp_PrintToChat(client, "Vous avez placé un emplacement de plantation.");
				}
				else if (StrEqual(info, "hole"))
				{
					rp_GetGlobalData("model_hole", STRING(sTmp));
					ent = rp_CreatePhysics("", TeleportOrigin, NULL_VECTOR, sTmp, 0, true);
					g_iHole[ent].entity_index = ent;
					g_iHole[ent].owner = client;
					rp_PrintToChat(client, "Vous avez placé un emplacement de plantation.");
				}
				else if (StrEqual(info, "lamp"))
				{
					rp_GetGlobalData("model_lamp", STRING(sTmp));
					ent = rp_CreatePhysics("", TeleportOrigin, NULL_VECTOR, sTmp, 0, true);
					rp_PrintToChat(client, "Vous avez placé un emplacement de plantation.");
				}
				else if (StrEqual(info, "seeds"))
				{
					rp_GetGlobalData("model_seeds", STRING(sTmp));
					ent = rp_CreatePhysics("", TeleportOrigin, NULL_VECTOR, sTmp, 0, true);
					rp_PrintToChat(client, "Vous avez placé un emplacement de plantation.");
				}
				
				Entity_SetName(ent, iData[client].SteamID);
				JoueurOrigin[2] += 50;
				TeleportEntity(client, JoueurOrigin, NULL_VECTOR, NULL_VECTOR);
			}	
		}	
		else 
			rp_PrintToChat(client, "Interdit en zone P.V.P");
			
		rp_SetClientBool(client, b_DisplayHud, true);	
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
		if (IsEntityModelInArray(caller, "model_hole") || IsEntityModelInArray(caller, "model_seeds")
		|| IsEntityModelInArray(caller, "model_water"))
		{
			char strName[64];
			Entity_GetName(caller, STRING(strName));
			
			//int client = Client_FindBySteamId(strName);
			int client;
			
			if (IsEntityModelInArray(activator, "model_hole"))
			{
				client = g_iHole[activator].owner;
				if(IsClientValid(client))
				{
					if (rp_GetClientInt(client, i_Job) == JOBID)
					{
						if(IsEntityModelInArray(caller, "model_water"))
						{
							RemoveEdict(caller);
							if(g_iHole[activator].WaterTooMuchAttempt != MAX_WATERATTEMPT)
							{
								if(g_iHole[activator].water < 100)
								{
									g_iHole[activator].water += 25;
									if(g_iHole[activator].water >= 100)
										g_iHole[activator].water = 100;
									rp_PrintToChat(client, "Vous avez arrosée : {lightblue}%i{default}/{green}100", g_iHole[activator].water);
									
									if(g_iHole[activator].Timer_Grow == null)
										g_iHole[activator].Timer_Grow = CreateTimer(cvars.growup.FloatValue, Timer_GrowUP, activator);
									
									float position[3];
									GetEntPropVector(activator, Prop_Send, "m_vecOrigin", position);
									rp_CreateParticle(position, "bubble", 1.0);
								}	
								else
								{
									g_iHole[activator].WaterTooMuchAttempt++;
									rp_PrintToChat(client, "{orange}Vous aller noyer votre terreau{default}.");	
								}	
							}
							else
							{
								if(g_iHole[activator].Timer_Grow != null)
									g_iHole[activator].Timer_Grow = null;
								RemoveEdict(activator);
								rp_PrintToChat(client, "{lightred}Vous avez noyer votre terreau{default}.");
							}
						}
						else if(IsEntityModelInArray(caller, "model_seeds"))
						{
							if(g_iHole[activator].plant == NONE)
							{
								if(g_iHole[activator].Timer_Grow == null && g_iHole[activator].water > 8)
									g_iHole[activator].Timer_Grow = CreateTimer(cvars.growup.FloatValue, Timer_GrowUP, activator);
								if(g_iHole[activator].water < 8)
									rp_PrintToChat(client, "Votre terreau n'as pas assez d'eau, arroser le.");
								
								int iID = GetEntProp(caller, Prop_Send, "m_nSkin");
								g_iHole[activator].plant = (view_as<PlantType>(iID));
								
								rp_Sound(client, "sound_upgrade", 0.2);
								char sType[64];
								switch(g_iHole[activator].plant)
								{
									case CORN:sType = "Maïs";
									case LETTUCE:sType = "Salade";
									case PEPPER:sType = "Poivron";
									case TOMATO:sType = "Tomate";
									case WHEAT:sType = "Blé";
								}
								
								rp_PrintToChat(client, "Vous avez planter: %s{default}.", sType);
								
								RemoveEdict(caller);
							}
						}
					}
				}
			}
		}
	}
}

public Action Timer_GrowUP(Handle timer, any ent)
{
	if(IsValidEntity(ent))
	{
		if(g_iHole[ent].water > 0.0)
		{
			if((g_iHole[ent].level + 1) <= GROW_MAXSTEP)
			{
				if((g_iHole[ent].level + 1) == GROW_MAXSTEP)
				{
					g_iHole[ent].SetPlant();
				}
				else
				{
					g_iHole[ent].level++;
					rp_PrintToChat(g_iHole[ent].owner, "[TERREAU] Niveau amélioration: %i/%i", g_iHole[ent].level, GROW_MAXSTEP);
					g_iHole[ent].water -= 8;
					if(g_iHole[ent].water <= 0)
						g_iHole[ent].water = 0;
					
					float position[3];
					Entity_GetAbsOrigin(ent, position);				
					
					rp_CreateParticle(position, "smoke8", 1.0);
					
					g_iHole[ent].SetWeedsLevel();
					g_iHole[ent].Timer_Grow = CreateTimer(cvars.growup.FloatValue, Timer_GrowUP, ent);
				}
			}	
			else
			{
				rp_PrintToChat(g_iHole[ent].owner, "Votre terreau est prêt a être cultivé.");
				if(g_iHole[ent].Timer_Grow != null)
					g_iHole[ent].Timer_Grow = null;
			}
		}	
		else
		{
			rp_PrintToChat(g_iHole[ent].owner, "Votre terreau n'as plus d'eau, n'oubliez pas de l'arroser.");
			if(g_iHole[ent].Timer_Grow != null)
				g_iHole[ent].Timer_Grow = null;
		}
	}
	
	return Plugin_Handled;
}

public void RP_OnLookAtTarget(int client, int target, char[] model)
{
	if(!IsValidEntity(target))
		return;
	
	if(IsEntityModelInArray(target, "model_hole"))
	{
		if(g_iHole[target].owner == client)
			PrintHintText(client, "<font color='%s'>★</font><font color='%s'>𝙏𝙚𝙧𝙧𝙚𝙖𝙪</font><font color='%s'>★</font>\nEau: <font color='%s'>%iL</font>\nVie: <font color='%s'>%0.1f</font>", HTML_CRIMSON, HTML_FLUOYELLOW, HTML_CRIMSON, HTML_BLUE, g_iHole[target].water, HTML_CHARTREUSE, rp_GetEntityHealth(target));
		else
			PrintHintText(client, "<font color='%s'>★</font><font color='%s'>𝙏𝙚𝙧𝙧𝙚𝙖𝙪</font><font color='%s'>★</font>\nProps de: <font color='%s'>%N</font>\nVie: <font color='%s'>%0.1f</font>", HTML_CRIMSON, HTML_FLUOYELLOW, HTML_CRIMSON, HTML_TURQUOISE, g_iHole[target].owner, HTML_CHARTREUSE, rp_GetEntityHealth(target));		
	}	
	else if(IsEntityModelInArray(target, "model_seeds"))
		PrintHintText(client, "<font color='%s'>★</font><font color='%s'>𝙂𝙧𝙖𝙞𝙣𝙚𝙨</font><font color='%s'>★</font>\nVie: <font color='%s'>%0.1f</font>", HTML_CRIMSON, HTML_FLUOYELLOW, HTML_CRIMSON, HTML_CHARTREUSE, rp_GetEntityHealth(target));
}

/***************************************************************************************

									C L I E N T - S I D E

***************************************************************************************/

public void OnClientPutInServer(int client)
{
}	

public void OnClientAuthorized(int client, const char[] auth) 
{	
	strcopy(iData[client].SteamID, sizeof(iData[].SteamID), auth);
}