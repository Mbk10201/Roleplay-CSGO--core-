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

/***************************************************************************************

										H E A D E R

***************************************************************************************/
#include <roleplay_csgo.inc>

int StuckCheck[MAXPLAYERS+1] 	= {0, ...};

bool isStuck[MAXPLAYERS + 1];

float Step;
float RadiusSize;
float Ground_Velocity[3] = {0.0, 0.0, -300.0};

enum struct ClientData{
	bool canUse;
}
ClientData iData[MAXPLAYERS + 1];

enum struct Cvars {
	ConVar cooldown;
	ConVar radius;
	ConVar step;
}
Cvars cvar;

/***************************************************************************************

							P L U G I N  -  I N F O

***************************************************************************************/
public Plugin myinfo = 
{
	name = "Roleplay - [MODULE] stuck & unstuck", 
	author = "MBK", 
	description = "Player can unstuck themselve if they are stuck on a props or a wall.", 
	version = "1.0", 
	url = "https://github.com/Mbk10201"
};

/***************************************************************************************

									 F U N C T I O N S

***************************************************************************************/

public void OnPluginStart()
{
	LoadTranslation();
	
	cvar.cooldown = CreateConVar("rp_stuck_cooldown", "60", "Time to wait before earn new !stuck.", _, true, 0.0);
	cvar.radius	= CreateConVar("stuck_radius", "200", "Radius size to fix player position.", _, true, 10.0);
	cvar.step = CreateConVar("stuck_step", "20", "Step between each position tested.", _, true, 1.0);
	
	AutoExecConfig(true, "rp_stuck", "roleplay");
	
	HookConVarChange(cvar.radius, CallBackCVarRadius);
	HookConVarChange(cvar.step, CallBackCVarStep);
		
	RadiusSize = cvar.radius.IntValue * 1.0;
	if(RadiusSize < 10.0)
		RadiusSize = 10.0;
		
	Step = cvar.step.IntValue * 1.0;
	if(Step < 1.0)
		Step = 1.0;
	
	RegConsoleCmd("stuck", Command_Stuck);
	RegConsoleCmd("unstuck", Command_Stuck);
}

public void CallBackCVarRadius(ConVar cvarr, const char[] oldVal, const char[] newVal)
{
	RadiusSize = StringToInt(newVal) * 1.0;
	if(RadiusSize < 10.0)
		RadiusSize = 10.0;
	
	LogMessage("stuck_radius = %f", RadiusSize);
}

public void CallBackCVarStep(ConVar cvarr, const char[] oldVal, const char[] newVal)
{
	Step = StringToInt(newVal) * 1.0;
	if(Step < 1.0)
		Step = 1.0;
		
	LogMessage("stuck_step = %f", Step);
}

public void OnClientPutInServer(int client)
{
	iData[client].canUse = true;
}

public Action Command_Stuck(int client, int args)
{
	if(!IsClientValid(client))
		return Plugin_Handled;
	
	if(!iData[client].canUse)
	{
		rp_PrintToChat(client, "Vous devez patienter un instant avant de reutiliser cette fonctionnalité...");
		return Plugin_Handled;
	}
	
	StuckCheck[client] = 0;
	StartStuckDetection(client);
	
	iData[client].canUse = false;
	CreateTimer(cvar.cooldown.FloatValue, Timer_Cooldown, client);
	
	return Plugin_Handled;
}

public Action Timer_Cooldown(Handle timer, int client)
{
	iData[client].canUse = true;
	return Plugin_Handled;
}

void StartStuckDetection(int client)
{
	StuckCheck[client]++;
	isStuck[client] = false;
	isStuck[client] = CheckIfPlayerIsStuck(client); // Check if player stuck in prop
	CheckIfPlayerCanMove(client, 0, 500.0, 0.0, 0.0);
}

bool CheckIfPlayerIsStuck(int client)
{
	float vecMin[3], vecMax[3], vecOrigin[3];
	
	GetClientMins(client, vecMin);
	GetClientMaxs(client, vecMax);
	GetClientAbsOrigin(client, vecOrigin);
	
	TR_TraceHullFilter(vecOrigin, vecOrigin, vecMin, vecMax, MASK_SOLID, TraceEntityFilterSolid);
	return TR_DidHit();	// head in wall ?
}


public bool TraceEntityFilterSolid(int entity, int contentsMask) 
{
	return entity > 1;
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//									More Stuck Detection
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


stock void CheckIfPlayerCanMove(int client, int testID, float X = 0.0, float Y = 0.0, float Z = 0.0)	// In few case there are issues with IsPlayerStuck() like clip
{
	float vecVelo[3];
	float vecOrigin[3];
	GetClientAbsOrigin(client, vecOrigin);
	
	vecVelo[0] = X;
	vecVelo[1] = Y;
	vecVelo[2] = Z;
	
	SetEntPropVector(client, Prop_Data, "m_vecBaseVelocity", vecVelo);
	
	DataPack pack = new DataPack();
	CreateDataTimer(0.1, TimerWait, pack); 
	pack.WriteCell(client);
	pack.WriteCell(testID);
	pack.WriteFloat(vecOrigin[0]);
	pack.WriteFloat(vecOrigin[1]);
	pack.WriteFloat(vecOrigin[2]);
}

public Action TimerWait(Handle timer, DataPack pack)
{	
	float vecOrigin[3];
	float vecOriginAfter[3];
	
	pack.Reset();
	int client 		= pack.ReadCell();
	int testID 			= pack.ReadCell();
	vecOrigin[0]		= pack.ReadFloat();
	vecOrigin[1]		= pack.ReadFloat();
	vecOrigin[2]		= pack.ReadFloat();
	
	
	GetClientAbsOrigin(client, vecOriginAfter);
	
	if(GetVectorDistance(vecOrigin, vecOriginAfter, false) < 10.0) // Can't move
	{
		if(testID == 0)
			CheckIfPlayerCanMove(client, 1, 0.0, 0.0, -500.0);	// Jump
		else if(testID == 1)
			CheckIfPlayerCanMove(client, 2, -500.0, 0.0, 0.0);
		else if(testID == 2)
			CheckIfPlayerCanMove(client, 3, 0.0, 500.0, 0.0);
		else if(testID == 3)
			CheckIfPlayerCanMove(client, 4, 0.0, -500.0, 0.0);
		else if(testID == 4)
			CheckIfPlayerCanMove(client, 5, 0.0, 0.0, 300.0);
		else
			FixPlayerPosition(client);
	}
	else
	{
		if(StuckCheck[client] < 2)
			PrintToChat(client, "[!stuck] Well Tried, but you are not stuck!");
		else
			PrintToChat(client, "[!stuck] Done!", StuckCheck[client]);
	}
	
	return Plugin_Handled;
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//									Fix Position
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


void FixPlayerPosition(int client)
{
	if(isStuck[client]) // UnStuck player stuck in prop
	{
		float pos_Z = 0.1;
		
		while(pos_Z <= RadiusSize && !TryFixPosition(client, 10.0, pos_Z))
		{	
			pos_Z = -pos_Z;
			if(pos_Z > 0.0)
				pos_Z += Step;
		}
		
		if(!CheckIfPlayerIsStuck(client) && StuckCheck[client] < 7) // If client was stuck => new check
			StartStuckDetection(client);
		else
			PrintToChat(client,"[!stuck] Sorry, I'm not able to fix your position.");
	
	}
	else // UnStuck player stuck in clip (invisible wall)
	{
		// if it is a clip on the sky, it will try to find the ground !
		Handle trace = INVALID_HANDLE;
		float vecOrigin[3];
		float vecAngle[3];
		
		GetClientAbsOrigin(client, vecOrigin);
		vecAngle[0] = 90.0;
		trace = TR_TraceRayFilterEx(vecOrigin, vecAngle, MASK_SOLID, RayType_Infinite, TraceEntityFilterSolid);		
		if(!TR_DidHit(trace)) 
		{
			CloseHandle(trace);
			return;
		}
		
		TR_GetEndPosition(vecOrigin, trace);
		CloseHandle(trace);
		vecOrigin[2] += 10.0;
		TeleportEntity(client, vecOrigin, NULL_VECTOR, Ground_Velocity);
		
		if(StuckCheck[client] < 7) // If client was stuck in invisible wall => new check
			StartStuckDetection(client);
		else
			PrintToChat(client,"[!stuck] Sorry, I'm not able to fix your position.");
	}
}

bool TryFixPosition(int client, float Radius, float pos_Z)
{
	float DegreeAngle;
	float vecPosition[3];
	float vecOrigin[3];
	float vecAngle[3];
	
	GetClientAbsOrigin(client, vecOrigin);
	GetClientEyeAngles(client, vecAngle);
	vecPosition[2] = vecOrigin[2] + pos_Z;

	DegreeAngle = -180.0;
	while(DegreeAngle < 180.0)
	{
		vecPosition[0] = vecOrigin[0] + Radius * Cosine(DegreeAngle * FLOAT_PI / 180); // convert angle in radian
		vecPosition[1] = vecOrigin[1] + Radius * Sine(DegreeAngle * FLOAT_PI / 180);
		
		TeleportEntity(client, vecPosition, vecAngle, Ground_Velocity);
		if(!CheckIfPlayerIsStuck(client))
			return true;
		
		DegreeAngle += 10.0; // + 10°
	}
	
	TeleportEntity(client, vecOrigin, vecAngle, Ground_Velocity);
	if(Radius <= RadiusSize)
		return TryFixPosition(client, Radius + Step, pos_Z);
	
	return false;
}



