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

Handle g_GetBonePosition;

/***************************************************************************************

							P L U G I N  -  I N F O

***************************************************************************************/
public Plugin myinfo = 
{
	name = "Roleplay - [MODULE]Tools", 
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
	
	#if DEBUG
	RegConsoleCmd("testhtml", Cmd_Testhtml);
	RegConsoleCmd("setbodygroup", Cmd_SetEntityBodyGroup);
	RegConsoleCmd("testseq", Cmd_TestSeq);
	RegConsoleCmd("testmodel", Cmd_TestPlayerSkin);
	RegConsoleCmd("testskin", Cmd_TestSkin);
	RegConsoleCmd("testfx", Cmd_TestFx);
	RegConsoleCmd("testpermis", Cmd_TestPermis);
	RegConsoleCmd("testpose", Cmd_TestPose);
	RegConsoleCmd("testcollision", Cmd_TestCollision);
	RegConsoleCmd("testvehiclescript", Cmd_VehicleScript);
	RegConsoleCmd("getdata", Command_GetData);
	RegConsoleCmd("testsound", Command_Testsound);
	RegConsoleCmd("testoverlay", Command_Testoverlay);
	RegConsoleCmd("testjob", Command_TestJob);
	RegConsoleCmd("testtranslation", Command_TestTranslation);
	RegConsoleCmd("testanimation", Command_TestAnimation);
	RegConsoleCmd("setwheel", Command_SetWheel);
	RegConsoleCmd("testshit", Command_TestPoop);
	RegConsoleCmd("testsprite", Command_TestSprite);
	RegConsoleCmd("testparticle", Command_TestParticle);
	RegConsoleCmd("teststringmap", Command_TestStringmap);
	RegConsoleCmd("testscreenfade", Command_TestScreenFade);
	RegConsoleCmd("testscreenfade", Command_TestScreenFade);
	#endif
	
	GameData gamedata = new GameData("bones.game.csgo");
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(gamedata, SDKConf_Signature, "CBaseAnimating::GetBonePosition");
	
	// int iBone
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	// Vector &origin
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef, VDECODE_FLAG_BYREF, VENCODE_FLAG_COPYBACK);
	// QAngle &angles
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef, VDECODE_FLAG_BYREF, VENCODE_FLAG_COPYBACK);
	
	if (!(g_GetBonePosition = EndPrepSDKCall()))
	{
	    SetFailState("Missing signature 'CBaseAnimating::GetBonePosition'");
	}
}

/***************************************************************************************

									N A T I V E S

***************************************************************************************/

public APLRes AskPluginLoad2(Handle plugin, bool late, char[] error, int err_max)
{
	RegPluginLibrary("rp_tools");
	
	CreateNative("rp_SetEntityAnimation", Native_SetEntityAnimation);
	
	return APLRes_Success;
}

public int Native_SetEntityAnimation(Handle plugin, int numParams) 
{
	int entity = GetNativeCell(1);
	char animation[64];
	GetNativeString(2, STRING(animation));	
	float delay = vfloat(GetNativeCell(3));
	
	if(!IsValidEntity(entity))
		return -1;
		
	if(delay > 0.0)
	{
		DataPack pack;
		CreateDataTimer(delay, Timer_SetAnimation, pack);
		pack.WriteCell(entity);
		pack.WriteString(animation);
	}
	else
	{
		SetVariantString(animation);
		AcceptEntityInput(entity, "SetAnimation");
	}	
	
	return 0;
}

public Action Timer_SetAnimation(Handle timer, DataPack pack)
{
	pack.Reset();
	int entity = pack.ReadCell();
	char animation[64];
	pack.ReadString(STRING(animation));
	
	SetVariantString(animation);
	AcceptEntityInput(entity, "SetAnimation");
	
	return Plugin_Handled;
} 

/***************************************************************************************

									C A L L B A C K

***************************************************************************************/

public Action Command_TestAnimation(int client, int args)
{
	char arg[32];
	GetCmdArg(1, STRING(arg));
	char tmp[32];
	GetCmdArg(2, STRING(tmp));
	
	float delay = StringToFloat(tmp);
	int entity = GetClientAimTarget(client, false);
	
	if(delay > 0.0)
	{
		DataPack pack;
		CreateDataTimer(delay, Timer_SetAnimation, pack);
		pack.WriteCell(entity);
		pack.WriteString(arg);
	}
	else
	{
		SetVariantString(arg);
		AcceptEntityInput(entity, "SetAnimation");
	}
	
	return Plugin_Handled;
}

public Action Command_SetWheel(int client, int args)
{
	int vehicle = GetClientAimTarget(client, false);
	
	char arg[8];
	GetCmdArg(1, STRING(arg));
	
	char model[256];
	GetCmdArg(1, STRING(model));
	
	if(!Vehicle_IsValid(vehicle))
		return Plugin_Handled;
		
	rp_CreateDynamic("", NULL_VECTOR, NULL_VECTOR, "models/lonewolfie/wheels/wheel_com_rt_gold.mdl", _, _, _, _, _, vehicle, "wheel_fl");
	
	return Plugin_Handled;
}

public Action Command_TestPoop(int client, int args)
{
	int random = GetRandomInt(1, 5);
	
	char sSound[128];
	Format(STRING(sSound), "player/vo/anarchist/t_death0%i.wav", random);
	
	PrecacheSound(sSound);
	EmitSoundToAll(sSound, client, _, _, _, 1.0);
	
	return Plugin_Handled;
}

public Action Command_TestSprite(int client, int args)
{
	float position[3];
	PointVision(client, position);
	
	UTIL_CreateSprite(_, position, _, "Eye_R", "sprites/light_glow02.spr", "1.0", "5", 0.0, view_as<float>({255.0, 0.0, 0.0}));
	
	return Plugin_Handled;
}

public Action Command_TestParticle(int client, int args)
{
	char arg[64];
	GetCmdArg(1, STRING(arg));
	
	float position[3];
	PointVision(client, position);
	
	rp_CreateParticle(position, arg, 5.0);
	
	return Plugin_Handled;
}

public Action Command_TestStringmap(int client, int args)
{
	char sArg[64], sTmp[64];
	GetCmdArg(1, STRING(sArg));
	rp_GetGlobalData(sArg, STRING(sTmp));
	
	if(!StrEqual(sTmp, ""))
		rp_PrintToChat(client, "%s : %s", sArg, sTmp);
	else
		rp_PrintToChat(client, "%s: {lightred}not found", sArg);
		
	return Plugin_Handled;
}

public Action Command_TestScreenFade(int client, int args)
{
	char color0[64], color1[64], color2[64], color3[64];
	GetCmdArg(1, STRING(color0));
	GetCmdArg(2, STRING(color1));
	GetCmdArg(3, STRING(color2));
	GetCmdArg(4, STRING(color3));
	
	int color[4];
	
	color[0] = StringToInt(color0);
	color[1] = StringToInt(color1);
	color[2] = StringToInt(color2);
	color[3] = StringToInt(color3);
	
	ScreenFade(client, 5, color);
	
	return Plugin_Handled;
}

public Action Cmd_VehicleScript(int client, int args)
{
	char sArg[128];
	GetCmdArg(1, STRING(sArg));
	
	int iVehicle = GetClientVehicle(client);
	
	if(!Vehicle_IsValid(iVehicle))
		return Plugin_Handled;
	
	Vehicle_SetScript(iVehicle, sArg);
	
	return Plugin_Handled;
}

public Action Command_GetData(int client, int args)
{
	int target = GetClientAimTarget(client, false);
	int v;
	
	v = GetEntProp(target, Prop_Data, "m_CollisionGroup");
	PrintToChat(client, "m_CollisionGroup %i", v);
	
	v = GetEntProp(target, Prop_Data, "m_nSolidType", 1);
	PrintToChat(client, "m_nSolidType %i", v);
	
	v = GetEntProp(target, Prop_Data, "m_usSolidFlags", 2);
	PrintToChat(client, "m_usSolidFlags %i", v);
	
	StudioHdr studio = GetEntityStudioHdr(target);
	for(int i = 0; studio.AttachmentCount; i++)
	{
		char sTmp[64];
		GetEntityAttachmentName(target, i, sTmp, sizeof(sTmp));
		CPrintToChat(client, "Animation #%i Name: @%s", i, sTmp);
	}
	
	return Plugin_Handled;
}

public Action Cmd_Testhtml(int client, int args)
{
	char type[2], message[MAX_BUFFER_LENGTH + 1];
	//message = "<img src='https://enemy-down.eu/image/logo.png'>";
	GetCmdArg(1, STRING(type));
	GetCmdArg(2, STRING(message));
	
	if(StrEqual(type, "1"))
		ShowPanel1(client, 5.0, message);
	else if(StrEqual(type, "2"))	
		ShowPanel2(client, 5, message);
	
	/*Event new_event = CreateEvent("instructor_server_hint_create", true);
    new_event.SetString("hint_caption", "Ez New Hint by kRatoss");
    new_event.SetInt("hint_timeout", 5); // how many seconds to hold the hint text?
    new_event.SetString("hint_color", "255,0,0");// it does not support alpha, just "r,g,b" ( this format only);
    new_event.Fire();*/
    
	return Plugin_Handled;
}

Action Cmd_SetEntityBodyGroup(int client, int argc)
{
	if (argc != 2)
	{
		rp_PrintToChat(client, "Utilisation: !setbodygroup <body> <value>");
		return Plugin_Handled;
	}
    
	int target = GetClientAimTarget(client, false);
    
	if (target == -1)
    {
		PrintToChat(client, "Invalid aim target.");
		return Plugin_Handled;
	}
	
	char arg1[16], arg2[16];
	GetCmdArg(1, STRING(arg1));
	GetCmdArg(2, STRING(arg2));
    
	SetBodyGroup(target, StringToInt(arg1), StringToInt(arg2));
    
	return Plugin_Handled;
}

public Action Cmd_TestPose(int client, int args)
{
	int entity = GetClientAimTarget(client, false);
	
	char arg[32];
	GetCmdArg(1, STRING(arg));
	char value[32];
	GetCmdArg(2, STRING(value));
	
	SetPoseParameterByName(entity, arg, StringToFloat(value));
	
	return Plugin_Handled;
}

public Action Cmd_TestCollision(int client, int args)
{
	char arg[8];
	GetCmdArg(1, STRING(arg));
	
	int target = GetClientAimTarget(client, false);
	SetEntProp(target, Prop_Send, "m_CollisionGroup", StringToInt(arg));
	SetEntProp(target, Prop_Data, "m_nSolidType", StringToInt(arg));
	
	return Plugin_Handled;
}

public Action Cmd_TestSeq(int client, int args)
{
	char arg[64];
	GetCmdArg(1, STRING(arg));
	
	int target = GetClientAimTarget(client, false);
	AcceptEntityInput(target, "Enable");
	PlayAnimation(target, arg);
	
	return Plugin_Handled;
}

public Action Cmd_TestPlayerSkin(int client, int args)
{
	char arg[256];
	GetCmdArg(1, STRING(arg));
	PrecacheAndSetModel(client, arg);
	
	return Plugin_Handled;
}

public Action Cmd_TestFx(int client, int args)
{
	SetEntityRenderFx(client, RENDERFX_EXPLODE);
	
	return Plugin_Handled;
}

public Action Cmd_TestPermis(int client, int args)
{
	rp_SetClientBool(client, b_HasCarLicence, false);
	
	return Plugin_Handled;
}

public Action Cmd_TestSkin(int client, int args)
{
	char arg[256];
	GetCmdArg(1, STRING(arg));
	
	int target = GetClientAimTarget(client, false);
	SetEntProp(target, Prop_Send, "m_nSkin", StringToInt(arg));
	
	return Plugin_Handled;
}

public Action Command_Testsound(int client, int args)
{
	char arg[128];
	GetCmdArg(1, STRING(arg));
	rp_Sound(client, arg, 1.0);
	
	return Plugin_Handled;
}

public Action Command_Testoverlay(int client, int args)
{
	char arg[256];
	GetCmdArg(1, STRING(arg));	
	PrecacheDecal(arg, true);
	ClientCommand(client, "r_screenoverlay %s", arg);
	
	return Plugin_Handled;
}

public Action Command_TestJob(int client, int args)
{
	char arg[8];
	GetCmdArg(1, STRING(arg));
	
	KeyValues kv = new KeyValues("SpawnJob");	
	char sPath[PLATFORM_MAX_PATH], map[64];
	rp_GetCurrentMap(STRING(map));
	BuildPath(Path_SM, STRING(sPath), "data/roleplay/%s/spawnjob.cfg", map);	
	Kv_CheckIfFileExist(kv, sPath);

	if(kv.JumpToKey(arg))
	{
		float pos[3];
		kv.GetVector("position", pos);
		
		rp_ClientTeleport(client, pos);
	}
	
	
	kv.Rewind();	
	delete kv;
	
	return Plugin_Handled;
}

public Action Command_TestTranslation(int client, int args)
{
	char arg[128];
	GetCmdArg(1, STRING(arg));
	
	Handle request = CreateRequest(arg, "en", client);
	SteamWorks_SendHTTPRequest(request);
	
	return Plugin_Handled;
}

Handle CreateRequest(char[] input, char[] target, int client)
{
    Handle request = SteamWorks_CreateHTTPRequest(k_EHTTPMethodGET, "https://enemy-down.eu/php/translations/translate.php");
    SteamWorks_SetHTTPRequestGetOrPostParameter(request, "input", input);
    SteamWorks_SetHTTPRequestGetOrPostParameter(request, "target", target);
    
    SteamWorks_SetHTTPRequestContextValue(request, GetClientUserId(client));
    SteamWorks_SetHTTPCallbacks(request, Callback_OnHTTPResponse);
    return request;
}

public int Callback_OnHTTPResponse(Handle request, bool bFailure, bool bRequestSuccessful, EHTTPStatusCode eStatusCode, int userid)
{
    if (!bRequestSuccessful || eStatusCode != k_EHTTPStatusCode200OK)
	{        
		PrintToServer("Request Translation Failed");
		return -1;
	}

    int iBufferSize;
    SteamWorks_GetHTTPResponseBodySize(request, iBufferSize);
    
    char[] result = new char[iBufferSize];
    SteamWorks_GetHTTPResponseBodyData(request, result, iBufferSize);
    delete request;

    CPrintToChatAll("Response: %s", result);
    
    return 0;
}