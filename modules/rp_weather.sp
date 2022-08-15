/*
*   Roleplay CS:GO de Benito est mis à disposition selon les termes de la licence Creative Commons Attribution .
* - Pas d’Utilisation Commerciale 
* - Partage dans les Mêmes Conditions 4.0 International.
*
*   Merci de respecter le travail fourni par le ou les auteurs 
*   https://enemy-down.eu - benitalpa1020@gmail.com
*/

/***************************************************************************************

							P L U G I N  -  D E F I N E S

***************************************************************************************/
#pragma semicolon 1
#pragma newdecls required

#warning TO BE FINISHED
#warning TO BE FINISHED
#warning TO BE FINISHED

#define PLUGIN_NAME 	"Weather"
#define PARTICLE_FOG	"storm_cloud_parent"
#define	MAX_FOG			16
#define MAX_RADIATION 	16
#define MAX_TESLA		8

/***************************************************************************************

										H E A D E R

***************************************************************************************/
#include <roleplay_csgo.inc>

char sSteamID[MAXPLAYERS + 1][32];
KeyValues gKv;

enum STATE{
	STATE_OFF,
	STATE_ON
}

enum struct WeatherData {
	int iStorm;
	STATE iStormState;
	
	int iClouds;
	STATE iCloudsState;
	
	int iFog;
	STATE iFogState;
	
	int iRadiation[MAX_RADIATION + 1];
	STATE iRadiationState[MAX_RADIATION + 1];
	
	int iTesla[MAX_TESLA + 1];
	
	// File Data
	int iCountRadiations;
	int iCountTesla;
}

WeatherData weather;

/***************************************************************************************

							P L U G I N  -  I N F O

***************************************************************************************/
public Plugin myinfo = 
{
	name = "Roleplay - Weather",  // TODO
	author = "MBK", 
	description = "Control the weather, sun, snow, rain, etc...", // TODO
	version = "1.0", 
	url = "https://github.com/Mbk10201"
};

/***************************************************************************************

									 F U N C T I O N S

***************************************************************************************/

public void OnPluginStart()
{
	LoadTranslation();
	LoadTranslations("rp_weather.phrases");
	PrintToServer("[MODULE] %s ✓", PLUGIN_NAME);	
	
	/*----------------------------------Commands-------------------------------*/
	RegConsoleCmd("rp_weather", Command_Weather, "Opens the storm menu.");
	/*-------------------------------------------------------------------------------*/
	
	char sMap[64];
	rp_GetCurrentMap(STRING(sMap));
	
	// Load files
	gKv = new KeyValues("Weather");
	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, STRING(sPath), "data/roleplay/%s/weather.cfg", sMap);
	Kv_CheckIfFileExist(gKv, sPath);
}

public void OnMapStart()
{
	// Create weather actors
	CreateClouds();
	//CreateFog();
	
	// Load file data
	if (!gKv.GotoFirstSubKey())
	{
		PrintToServer("ERROR FIRST KEY");
		delete gKv;
		return;
	}
	
	if(gKv.JumpToKey("tesla", true))
	{
		if(gKv.JumpToKey("1"))
		{
			gKv.GoBack();
			do
			{
				char sVector[16];
				gKv.GetString("vector", STRING(sVector));
				
				if(!StrEqual(sVector, ""))
				{
					weather.iCountTesla++;
					float fVector[3]; 
					fVector	= StringToVector(sVector);
					weather.iTesla[weather.iCountTesla] = UTIL_CreateTesla(_, fVector, _, _, "100.0");
					
					AcceptEntityInput(weather.iTesla[weather.iCountTesla], "Disable");
				}
			} 
			while (gKv.GotoNextKey());
			
			char sTmp[256];
			Format(STRING(sTmp), "[rp_weather] Found %i tesla positions", weather.iCountTesla);
			PrintToServer(sTmp);
			rp_LogToDiscord(sTmp);
		}	
	}
	
	if(gKv.JumpToKey("triggers", true))
	{
		if(gKv.JumpToKey("radiation"))
		{
			if(gKv.JumpToKey("1"))
			{
				gKv.GoBack();
				do
				{
					weather.iCountTesla++;
					char sMin[16], sMax[16];
					gKv.GetString("min", STRING(sMin));
					gKv.GetString("max", STRING(sMax));
					
					if(!StrEqual(sMin, "") && !StrEqual(sMax, ""))
					{
						float fMin[3];  
						fMin = StringToVector(sMin);
						float fMax[3];  
						fMax = StringToVector(sMax);
						
						weather.iRadiation[weather.iCountRadiations++] = CreateTriggerEntity(fMin, fMax);
					}
				} 
				while (gKv.GotoNextKey());
				
				char sTmp[256];
				Format(STRING(sTmp), "[rp_weather] Found %i radiation triggers", weather.iCountRadiations);
				PrintToServer(sTmp);
				rp_LogToDiscord(sTmp);
			}
		}	
	}
}

/***************************************************************************************

									N A T I V E S

***************************************************************************************/

public APLRes AskPluginLoad2(Handle plugin, bool late, char[] error, int err_max)
{
	//RegPluginLibrary("");
	
	return APLRes_Success;
}

/***************************************************************************************

									C A L L B A C K

***************************************************************************************/

public Action Command_Weather(int client, int args)
{
	#if DEBUG
		Translation_DebugCommand(client);
	#endif
	
	if(client == 0)
	{
		Translation_PrintNoAvailable();
		return Plugin_Handled;
	}
	
	if(rp_GetAdmin(client) == ADMIN_FLAG_NONE)
	{
		Translation_PrintNoAccess(client);
		return Plugin_Handled;
	}

	MenuWeather(client);
	return Plugin_Handled;
}

Menu MenuWeather(int client)
{
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_MenuWeather);
	
	char sTmp[64];
	menu.SetTitle("%T", "MenuWeather_Title", LANG_SERVER);
	
	Format(STRING(sTmp), "%T", "MenuWeather_Storm", LANG_SERVER, (weather.iStormState == STATE_OFF) ? "OFF" : "ON");
	menu.AddItem("storm", sTmp);
	
	Format(STRING(sTmp), "%T", "MenuWeather_Clouds", LANG_SERVER, (weather.iCloudsState == STATE_OFF) ? "OFF" : "ON");
	menu.AddItem("clouds", sTmp);
	
	Format(STRING(sTmp), "%T", "MenuWeather_Triggers", LANG_SERVER);
	menu.AddItem("triggers", sTmp);
	
	Format(STRING(sTmp), "%T", "MenuWeather_Reset", LANG_SERVER);
	menu.AddItem("reset", sTmp);
	
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Handle_MenuWeather(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[64];
		menu.GetItem(param, STRING(info));
		
		if(StrEqual(info, "storm"))
		{
			/*if( weather.iStormState == STATE_OFF )
				StartStorm(client);
			else
				StopStorm(client);*/
		}
		else if(StrEqual(info, "clouds"))
		{
			if( weather.iCloudsState == STATE_OFF )
			{
				weather.iCloudsState = STATE_ON;
				ShowClouds();
			}	
			else
			{
				weather.iCloudsState = STATE_OFF;
				HideClouds();
			}	
			MenuWeather(client);
		}
		else if(StrEqual(info, "triggers"))
		{
			MenuTriggers(client);
		}
		else if(StrEqual(info, "reset"))
		{
			MenuWeather(client);
			rp_LogToDiscord("[WEATHER] World reset");
		}
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit || param == MenuCancel_ExitBack)
			rp_SetClientBool(client, b_DisplayHud, true);
	}
	else if(action == MenuAction_End)
		delete menu;
}

Menu MenuTriggers(int client)
{
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_MenuTriggers);
	
	char sTmp[64];
	menu.SetTitle("%T", "MenuTrigger_Title", LANG_SERVER);
	
	Format(STRING(sTmp), "%T", "MenuWeather_Radiation", LANG_SERVER);
	menu.AddItem("radiation", sTmp);
	
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Handle_MenuTriggers(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[64];
		menu.GetItem(param, STRING(info));
		
		if(StrEqual(info, "radiation"))
		{
			/*if( weather.iStormState == STATE_OFF )
				StartStorm(client);
			else
				StopStorm(client);*/
		}
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if(param == MenuCancel_ExitBack)
			MenuWeather(client);
	}
	else if(action == MenuAction_End)
		delete menu;
}

/***************************************************************************************

									C L I E N T - S I D E

***************************************************************************************/

public void OnClientPutInServer(int client)
{
}

public void OnClientAuthorized(int client, const char[] auth) 
{	
	strcopy(sSteamID[client], sizeof(sSteamID[]), auth);
}

/***************************************************************************************

									F O G -- C L O U D S

***************************************************************************************/
void CreateClouds()
{
	int entity = FindEntityByClassname(-1, "sky_camera");

	if( entity != -1 )
	{
		float vPos[3];
		GetEntPropVector(entity, Prop_Data, "m_vecOrigin", vPos);

		weather.iClouds = CreateEntityByName("info_particle_system");
		DispatchKeyValue(weather.iClouds, "effect_name", PARTICLE_FOG);
		DispatchKeyValue(weather.iClouds, "targetname", "silver_fx_skybox_general_lightning");
		DispatchSpawn(weather.iClouds);
		ActivateEntity(weather.iClouds);
		AcceptEntityInput(weather.iClouds, "Stop");
		weather.iClouds = EntIndexToEntRef(weather.iClouds);
		TeleportEntity(weather.iClouds, vPos, NULL_VECTOR, NULL_VECTOR);
	}
}

void ShowClouds()
{
	if(IsValidEntity(weather.iClouds))
	{
		AcceptEntityInput(weather.iClouds, "Start");
		rp_LogToDiscord("[WEATHER] Clouds enabled");
	}
}

void HideClouds()
{
	if(IsValidEntity(weather.iClouds))
	{
		AcceptEntityInput(weather.iClouds, "Stop");
		rp_LogToDiscord("[WEATHER] Clouds disabled");
	}
}

/***************************************************************************************

										F O G

***************************************************************************************/

void CreateFog()
{
	weather.iFogState = STATE_ON;

	char sTemp[8];
	int entity = -1;
	int count;

	entity = -1;
	while( (entity = FindEntityByClassname(entity, "env_fog_controller")) != INVALID_ENT_REFERENCE )
	{
		if( count < MAX_FOG )
		{
			GetEntPropString(entity, Prop_Data, "m_iName", g_sFogStolen[count], sizeof(g_sFogStolen[]));
			g_iFogStolen[count][0] = EntIndexToEntRef(entity);
			g_iFogStolen[count][1] = GetEntProp(entity, Prop_Send, "m_fog.colorPrimary");
			g_iFogStolen[count][2] = GetEntProp(entity, Prop_Send, "m_fog.colorSecondary");
			g_iFogStolen[count][3] = GetEntProp(entity, Prop_Send, "m_fog.colorPrimaryLerpTo");
			g_iFogStolen[count][4] = GetEntProp(entity, Prop_Send, "m_fog.colorSecondaryLerpTo");
			g_fFogStolen[count][0] = GetEntPropFloat(entity, Prop_Send, "m_fog.start");
			g_fFogStolen[count][1] = GetEntPropFloat(entity, Prop_Send, "m_fog.end");
			g_fFogStolen[count][2] = GetEntPropFloat(entity, Prop_Send, "m_fog.maxdensity");
			g_fFogStolen[count][3] = GetEntPropFloat(entity, Prop_Send, "m_fog.farz");
			g_fFogStolen[count][4] = GetEntPropFloat(entity, Prop_Send, "m_fog.skyboxFogFactor");
			g_fFogStolen[count][5] = GetEntPropFloat(entity, Prop_Send, "m_fog.startLerpTo");
			g_fFogStolen[count][6] = GetEntPropFloat(entity, Prop_Send, "m_fog.endLerpTo");
			g_fFogStolen[count][7] = GetEntPropFloat(entity, Prop_Send, "m_fog.maxdensityLerpTo");
			g_fFogStolen[count][8] = GetEntPropFloat(entity, Prop_Send, "m_fog.duration");
			count++;
		}

		DispatchKeyValue(entity, "targetname", "stolen_fog_storm");
		DispatchKeyValue(entity, "use_angles", "1");
		DispatchKeyValue(entity, "fogstart", "1");
		DispatchKeyValue(entity, "fogmaxdensity", "1");
		DispatchKeyValue(entity, "heightFogStart", "0.0");
		DispatchKeyValue(entity, "heightFogMaxDensity", "1.0");
		DispatchKeyValue(entity, "heightFogDensity", "0.0");
		DispatchKeyValue(entity, "fogdir", "1 0 0");
		DispatchKeyValue(entity, "angles", "0 180 0");

		if( g_iCfgFogBlend != -1 )
		{
			IntToString(g_iCfgFogBlend, sTemp, sizeof(sTemp));
			DispatchKeyValue(entity, "foglerptime", sTemp);
		}

		if( g_sCfgFogColor[0] )
		{
			DispatchKeyValue(entity, "fogcolor", g_sCfgFogColor);
			DispatchKeyValue(entity, "fogcolor2", g_sCfgFogColor);
			SetVariantString(g_sCfgFogColor);
			AcceptEntityInput(entity, "SetColorLerpTo");
		}
	}

	if( count == 0 )
	{
		g_iFog = CreateEntityByName("env_fog_controller");
		if( g_iFog != -1 )
		{
			DispatchKeyValue(g_iFog, "targetname", "silver_fog_storm");
			DispatchKeyValue(g_iFog, "use_angles", "1");
			DispatchKeyValue(g_iFog, "fogstart", "1");
			DispatchKeyValue(g_iFog, "fogmaxdensity", "1");
			DispatchKeyValue(g_iFog, "heightFogStart", "0.0");
			DispatchKeyValue(g_iFog, "heightFogMaxDensity", "1.0");
			DispatchKeyValue(g_iFog, "heightFogDensity", "0.0");
			DispatchKeyValue(g_iFog, "fogenable", "1");
			DispatchKeyValue(g_iFog, "fogdir", "1 0 0");
			DispatchKeyValue(g_iFog, "angles", "0 180 0");

			if( g_iCfgFogBlend != -1 )
			{
				IntToString(g_iCfgFogBlend, sTemp, sizeof(sTemp));
				DispatchKeyValue(g_iFog, "foglerptime", sTemp);
			}

			if( g_iCfgFogZIdle && g_iCfgFogZStorm )
			{
				IntToString(g_iCfgFogZIdle, sTemp, sizeof(sTemp));
				DispatchKeyValue(g_iFog, "farz", sTemp);
			}

			if( g_sCfgFogColor[0] )
			{
				DispatchKeyValue(g_iFog, "fogcolor", g_sCfgFogColor);
				DispatchKeyValue(g_iFog, "fogcolor2", g_sCfgFogColor);
			}

			DispatchSpawn(g_iFog);
			ActivateEntity(g_iFog);

			TeleportEntity(g_iFog, view_as<float>({ 10.0, 15.0, 20.0 }), NULL_VECTOR, NULL_VECTOR);
			g_iFog = EntIndexToEntRef(g_iFog);
		}
	}
}

public int CreateTriggerEntity(float fMins[3], float fMaxs[3]) 
{
	float fMiddle[3];
	int iEnt = CreateEntityByName("trigger_multiple");
	
	char sZoneName[64];
	Format(STRING(sZoneName), "radiation_%i", GetRandomInt(1, MAX_RADIATION));
	
	DispatchKeyValue(iEnt, "spawnflags", "64");
	DispatchKeyValue(iEnt, "targetname", sZoneName);
	DispatchKeyValue(iEnt, "wait", "0");
	
	DispatchSpawn(iEnt);
	ActivateEntity(iEnt);
	
	GetMiddleOfABox(fMins, fMaxs, fMiddle);
	
	TeleportEntity(iEnt, fMiddle, NULL_VECTOR, NULL_VECTOR);
	
	// Have the mins always be negative
	fMins[0] = fMins[0] - fMiddle[0]; 
	if (fMins[0] > 0.0)
		fMins[0] *= -1.0;
	fMins[1] = fMins[1] - fMiddle[1];
	if (fMins[1] > 0.0)
		fMins[1] *= -1.0;
	fMins[2] = fMins[2] - fMiddle[2];
	if (fMins[2] > 0.0)
		fMins[2] *= -1.0;
	
	// And the maxs always be positive
	fMaxs[0] = fMaxs[0] - fMiddle[0];
	if (fMaxs[0] < 0.0)
		fMaxs[0] *= -1.0;
	fMaxs[1] = fMaxs[1] - fMiddle[1];
	if (fMaxs[1] < 0.0)
		fMaxs[1] *= -1.0;
	fMaxs[2] = fMaxs[2] - fMiddle[2];
	if (fMaxs[2] < 0.0)
		fMaxs[2] *= -1.0;
	
	SetEntPropVector(iEnt, Prop_Send, "m_vecMins", fMins);
	SetEntPropVector(iEnt, Prop_Send, "m_vecMaxs", fMaxs);
	SetEntProp(iEnt, Prop_Send, "m_nSolidType", 2);
	
	int iEffects = GetEntProp(iEnt, Prop_Send, "m_fEffects");
	iEffects |= 32;
	SetEntProp(iEnt, Prop_Send, "m_fEffects", iEffects);

	SDKHookEx(iEnt, SDKHook_Touch, Hook_OnTouch);
	SDKHookEx(iEnt, SDKHook_EndTouch, Hook_OnEndTouch);
	
	return iEnt;
}

public Action Hook_OnTouch(int ent, int other)
{
	if(IsValidEntity(ent) && IsClientValid(other))
	{
		char sTargetName[256], name[3][64];
		GetEntPropString(ent, Prop_Data, "m_iName", STRING(sTargetName)); 
		ExplodeString(sTargetName, "|", name, 3, 64);
		
		int zoneID = StringToInt(name[1]);
		
		if(StrContains(sTargetName, "none", false) == -1)
		{
			if(StrContains(sTargetName, "appart", false) != -1)
			{
				rp_SetClientInt(other, i_ZoneAppart, StringToInt(name[2]));
			}
			else if(StrContains(sTargetName, "villa", false) != -1)
			{
				rp_SetClientInt(other, i_ZoneVilla, StringToInt(name[2]));
			}	
			
			char translation[64];
			Format(STRING(translation), "%T", name[0], LANG_SERVER);
			
			rp_SetClientString(other, sz_ZoneName, STRING(translation));	
		}	
		rp_SetClientInt(other, i_Zone, zoneID);
	}
} 

public void Hook_OnEndTouch(int ent, int other)
{
	if(IsValidEntity(ent) && IsClientValid(other))
	{
		rp_SetClientInt(other, i_Zone, 0);
		
		char translation[64];
		Format(STRING(translation), "%T", "zone_none", LANG_SERVER);
		rp_SetClientString(other, sz_ZoneName, STRING(translation));
		
		rp_SetClientInt(other, i_ZoneAppart, 0);
	}	
}