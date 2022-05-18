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

/**
 * @section Properties of the airdrop.
 **/
//#define AIRDROP_GLOW                  /// Uncomment to disable glow
#define AIRDROP_AMOUNT                  6
#define AIRDROP_HEIGHT                  700.0
#define AIRDROP_HEALTH                  300
#define AIRDROP_ELASTICITY              0.01
#define AIRDROP_SPEED                   175.0
#define AIRDROP_EXPLOSIONS              3
#define AIRDROP_WEAPONS                 15
#define AIRDROP_SMOKE_REMOVE            14.0
#define AIRDROP_SMOKE_TIME              17.0
#define AIRDROP_LOCK                    25.0
#define hSoundLevel						5

/**
 * @section Properties of the gibs shooter.
 **/
#define METAL_GIBS_AMOUNT               5.0
#define METAL_GIBS_DELAY                0.05
#define METAL_GIBS_SPEED                500.0
#define METAL_GIBS_VARIENCE             2.0  
#define METAL_GIBS_LIFE                 2.0  
#define METAL_GIBS_DURATION             3.0
/***************************************************************************************

										H E A D E R

***************************************************************************************/
#include <roleplay_csgo.inc>

int helicopter_owner[MAXENTITIES + 1] = { 0, ...};
int helicopter_entity[MAXPLAYERS + 1] = { 0, ...};

enum struct Data_Forward {
	GlobalForward OnHeliCreate;
	GlobalForward OnHeliIdle;
	GlobalForward OnHeliDrop;
	GlobalForward OnHeliGoAway;
	GlobalForward OnGiftDropped;
}	
Data_Forward Forward;

char steamID[MAXPLAYERS + 1][32];

/***************************************************************************************

							P L U G I N  -  I N F O

***************************************************************************************/
public Plugin myinfo = 
{
	name = "Roleplay - [MODULE]Helicopter Drop", 
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
	
	RegConsoleCmd("drop_heli", Command_DropHelicopter);
	RegConsoleCmd("tesla", Command_Tesla);
}

public APLRes AskPluginLoad2(Handle plugin, bool late, char[] error, int err_max)
{
	RegPluginLibrary("rp_helicopter_drop");
	
	/*------------------------------------FORWADS------------------------------------*/
	Forward.OnHeliCreate = new GlobalForward("RP_OnHelicopterCreate", ET_Event, Param_Cell);
	Forward.OnHeliIdle = new GlobalForward("RP_OnHelicopterIdle", ET_Event, Param_Cell);
	Forward.OnHeliDrop = new GlobalForward("RP_OnHelicopterDrop", ET_Event, Param_Cell, Param_Cell, Param_String, Param_String);
	Forward.OnHeliGoAway = new GlobalForward("RP_OnHelicopterGoAway", ET_Event, Param_Cell);
	Forward.OnGiftDropped = new GlobalForward("RP_OnGiftDropped", ET_Event, Param_Cell);
	/*-------------------------------------------------------------------------------*/
	
	CreateNative("rp_SendHelicopter", Native_SendHelicopter);
	CreateNative("rp_GetHelicopterOwner", Native_GetHelicopterOwner);
	
	return APLRes_Success;
}

public int Native_SendHelicopter(Handle plugin, int numParams) 
{
	int client = GetNativeCell(1);
	int type = GetNativeCell(2);
		
	float position[3], angles[3];
	GetClientAbsOrigin(client, position);
	GetClientAbsAngles(client, angles);
	
	UTIL_CreateSmoke(_, position, angles, _, _, _, _, _, _, _, _, _, "255 20 147", "255", "particle/particle_smokegrenade1.vmt", AIRDROP_SMOKE_REMOVE, AIRDROP_SMOKE_TIME);
	CreateHelicopter(client, position, angles, type);	
	
	return helicopter_entity[client];
}

public int Native_GetHelicopterOwner(Handle plugin, int numParams) 
{
	return helicopter_owner[GetNativeCell(1)];
}

public void OnMapStart(/*void*/)
{
	// Sounds
	PrecacheSound("survival/container_death_01.wav", true);
	PrecacheSound("survival/container_death_02.wav", true);
	PrecacheSound("survival/container_death_03.wav", true);
	PrecacheSound("survival/container_damage_01.wav", true);
	PrecacheSound("survival/container_damage_02.wav", true);
	PrecacheSound("survival/container_damage_03.wav", true);
	PrecacheSound("survival/container_damage_04.wav", true);
	PrecacheSound("survival/container_damage_05.wav", true);
	PrecacheSound("survival/missile_gas_01.wav", true);
	PrecacheSound("survival/dropzone_freefall.wav", true);
	PrecacheSound("survival/dropzone_parachute_deploy.wav", true);
	PrecacheSound("survival/dropzone_parachute_success.wav", true);
	PrecacheSound("survival/dropzone_parachute_success_02.wav", true);
	PrecacheSound("survival/dropbigguns.wav", true);
	PrecacheSound("survival/breach_activate_nobombs_01.wav", true);
	PrecacheSound("survival/breach_land_01.wav", true);
	PrecacheSound("survival/rocketincoming.wav", true);
	PrecacheSound("survival/rocketalarm.wav", true);
	PrecacheSound("survival/missile_land_01.wav", true);
	PrecacheSound("survival/missile_land_02.wav", true);
	PrecacheSound("survival/missile_land_03.wav", true);
	PrecacheSound("survival/missile_land_04.wav", true);
	PrecacheSound("survival/missile_land_05.wav", true);
	PrecacheSound("survival/missile_land_06.wav", true);

	// Models
	PrecacheModel("models/f18/f18.mdl", true);
	PrecacheModel("models/props_survival/safe/safe_door.mdl", true);
	PrecacheModel("models/props_survival/cash/dufflebag.mdl", true);
	PrecacheModel("models/props_survival/cases/case_explosive.mdl", true);
	PrecacheModel("models/props_survival/cases/case_heavy_weapon.mdl", true);
	PrecacheModel("models/props_survival/cases/case_light_weapon.mdl", true);
	PrecacheModel("models/props_survival/cases/case_pistol.mdl", true);
	PrecacheModel("models/props_survival/cases/case_pistol_heavy.mdl", true);
	PrecacheModel("models/props_survival/cases/case_tools.mdl", true);
	PrecacheModel("models/props_survival/cases/case_tools_heavy.mdl", true);
	PrecacheModel("particle/particle_smokegrenade1.vmt", true); 
	PrecacheModel("particle/particle_smokegrenade2.vmt", true); 
	PrecacheModel("particle/particle_smokegrenade3.vmt", true); 
	PrecacheModel("models/gibs/metal_gib1.mdl", true);
	PrecacheModel("models/gibs/metal_gib2.mdl", true);
	PrecacheModel("models/gibs/metal_gib3.mdl", true);
	PrecacheModel("models/gibs/metal_gib4.mdl", true);
	PrecacheModel("models/gibs/metal_gib5.mdl", true);
}


/***************************************************************************************

									C A L L B A C K

***************************************************************************************/

public Action Command_Tesla(int client, int args)
{
	float position[3], angles[3];
	GetClientAbsOrigin(client, position);
	GetClientAbsAngles(client, angles);
	
	UTIL_CreateTesla(_, position, angles, _, "100.0", _, _, _, _, _, _, _, _, _, _, _, 1.0);
	return Plugin_Handled;
}	

public Action Command_DropHelicopter(int client, int args)
{
	char arg[8];
	GetCmdArg(1, STRING(arg));
	
	int type = StringToInt(arg);
	
	float position[3], angles[3];
	GetClientAbsOrigin(client, position);
	GetClientAbsAngles(client, angles);
	
	UTIL_CreateSmoke(_, position, angles, _, _, _, _, _, _, _, _, _, "255 20 147", "255", "particle/particle_smokegrenade1.vmt", AIRDROP_SMOKE_REMOVE, AIRDROP_SMOKE_TIME);
	CreateHelicopter(client, position, angles, type);
	return Plugin_Handled;
}	

//**********************************************
//* Helicopter functions.                      *
//**********************************************

/**
 * @brief Create a helicopter entity.
 * 
 * @param vPosition         The position to the spawn.
 * @param vAngle            The angle to the spawn.                    
 **/
void CreateHelicopter(int client, float vPosition[3], float vAngle[3], int type)
{
	// Add to the position
	vPosition[2] += AIRDROP_HEIGHT;
	
	// Gets world size
	static float vMaxs[3];
	GetEntPropVector(0, Prop_Data, "m_WorldMaxs", vMaxs);
	
	// Validate world size
	float vMax = vMaxs[2] - 100.0;
	if (vPosition[2] > vMax) vPosition[2] = vMax; 
	
	// Create a model entity
	int entity = rp_CreateDynamic("helicopter", vPosition, vAngle, "models/buildables/helicopter_rescue_fix.mdl", "helicopter_coop_hostagepickup_flyin", false);
	
	// Validate entity
	if (entity != -1)
	{
		Call_StartForward(Forward.OnHeliCreate); 
		Call_PushCell(entity);
		Call_Finish();
		
		// Create thinks
		CreateTimer(20.0, HelicopterStopHook, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer(0.41, HelicopterSoundHook, EntIndexToEntRef(entity), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
		
		helicopter_owner[entity] = client;
		rp_PerformLoadingBar(helicopter_owner[entity], LOADING_SURVIVALPANEL, "Arrivage de l'hélicoptère", 20);
		helicopter_entity[client] = entity;
	
		// Sets main parameters
		SetEntProp(entity, Prop_Data, "m_iHammerID", type);
		SetEntProp(entity, Prop_Data, "m_iMaxHealth", AIRDROP_AMOUNT);
	}
}

/**
 * @brief Main timer for stop helicopter.
 *
 * @param hTimer            The timer handle.
 * @param refID             The reference index.
 **/
public Action HelicopterStopHook(Handle hTimer, int refID)
{
	// Gets entity index from reference key
	int entity = EntRefToEntIndex(refID);

	// Validate entity
	if (entity != -1)
	{
		// Sets idle
		SetVariantString("helicopter_coop_hostagepickup_idle");
		AcceptEntityInput(entity, "SetAnimation");
		
		// Sets idle
		CreateTimer(5.0, HelicopterIdleHook, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
	}
	
	// Destroy timer
	return Plugin_Stop;
}

/**
 * @brief Main timer for creating sound. (Helicopter)
 *
 * @param hTimer            The timer handle.
 * @param refID             The reference index.
 **/
public Action HelicopterSoundHook(Handle hTimer, int refID)
{
	// Gets entity index from reference key
	int entity = EntRefToEntIndex(refID);

	// Validate entity
	if (entity != -1)
	{
		// Initialize vectors
		static float vPosition[3]; static float vAngle[3];

		// Gets position/angle
		//ZP_GetAttachment(entity, "dropped", vPosition, vAngle); 

		// Play sound
		//EmitAmbientSound(gSound, vPosition, SOUND_FROM_WORLD, hSoundLevel);
	}
	else
	{
		// Destroy timer
		return Plugin_Stop;
	}
	
	// Allow timer
	return Plugin_Continue;
}

/**
 * @brief Main timer for idling helicopter.
 *
 * @param hTimer            The timer handle.
 * @param refID             The reference index.
 **/
public Action HelicopterIdleHook(Handle hTimer, int refID)
{
	// Gets entity index from reference key
	int entity = EntRefToEntIndex(refID);

	// Validate entity
	if (entity != -1)
	{
		Call_StartForward(Forward.OnHeliIdle); 
		Call_PushCell(entity);
		Call_Finish();
		
		// Sets idle
		SetVariantString("helicopter_coop_towerhover_idle");
		AcceptEntityInput(entity, "SetAnimation");
		
		// Emit sound
		PrecacheSound("survival/dropbigguns.wav");
		EmitSoundToAll("survival/dropbigguns.wav", SOUND_FROM_PLAYER, SNDCHAN_VOICE, hSoundLevel);
		
		// Drops additional random staff
		CreateTimer(1.0, HelicopterDropHook, EntIndexToEntRef(entity), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
		rp_PerformLoadingBar(helicopter_owner[entity], LOADING_SURVIVALPANEL, "Drop de l'hélicoptère", 5);
		
		// Sets flying
		CreateTimer(6.6, HelicopterRemoveHook, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
	}
	
	// Destroy timer
	return Plugin_Stop;
}

/**
 * @brief Main timer for creating drop.
 *
 * @param hTimer            The timer handle.
 * @param refID             The reference index.
 **/
public Action HelicopterDropHook(Handle hTimer, int refID)
{
	Action action_type;
	
	// Gets entity index from reference key
	int entity = EntRefToEntIndex(refID);

	// Validate entity
	if (entity != -1)
	{
				
		// Validate cases
		int iLeft = GetEntProp(entity, Prop_Data, "m_iMaxHealth");
		if (iLeft)
		{
			// Reduce amount
			iLeft--;
			
			// Sets new amount
			SetEntProp(entity, Prop_Data, "m_iMaxHealth", iLeft);
		}
		else
		{
			// Destroy timer
			return Plugin_Stop;
		}

		// Initialize vectors
		static float vPosition[3]; static float vAngle[3]; static float vVelocity[3];
		
		// Gets position/angle
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", vPosition);
		GetEntPropVector(entity, Prop_Data, "m_angRotation", vAngle); 
		
		// Gets drop type
		int iType = GetEntProp(entity, Prop_Data, "m_iHammerID"); int drop; int iCollision; int iDamage;
		
		char position[32], angle[32];
		Format(STRING(position), "%f %f %f", vPosition[0], vPosition[1], vPosition[2]);
		Format(STRING(angle), "%f %f %f", vAngle[0], vAngle[1], vAngle[2]);
		
		Call_StartForward(Forward.OnHeliDrop); 
		Call_PushCell(entity);
		Call_PushCell(iType);
		Call_PushString(position);
		Call_PushString(angle);
		Call_Finish(action_type);
		
		switch (iType)
		{
			case CAR:
			{
				//rp_SpawnVehicle(helicopter_owner[entity], 4, 0.0, 1000.0, 75.0, true);
			}	
			case GIFT:
			{
				char sModel[128];
				rp_GetGlobalData("model_airdrop", STRING(sModel));
				
				drop = rp_CreatePhysics("gift", vPosition, NULL_VECTOR, sModel, _, _, .bAnimated = false);
				
				int owner = rp_GetHelicopterOwner(entity);
				Entity_SetName(drop, steamID[owner]);
				CreateTimer(5.0, Timer_GiftChangeMDL, drop);
			}
		}

		// Randomize the drop types (except safe)
		SetEntProp(entity, Prop_Data, "m_iHammerID", GetRandomInt(EXPL, HTOOL));
		
		// Validate entity
		/*if (drop != -1)
		{
			// Returns vectors in the direction of an angle
			GetAngleVectors(vAngle, vVelocity, NULL_VECTOR, NULL_VECTOR);
			
			// Normalize the vector (equal magnitude at varying distances)
			NormalizeVector(vVelocity, vVelocity);
			
			// Apply the magnitude by scaling the vector
			ScaleVector(vVelocity, AIRDROP_SPEED);
		
			// Push the entity 
			TeleportEntity(drop, NULL_VECTOR, NULL_VECTOR, vVelocity);
			
			// Sets physics
			//SetEntProp(drop, Prop_Data, "m_CollisionGroup", iCollision);
			//SetEntProp(drop, Prop_Data, "m_nSolidType", SOLID_VPHYSICS);
			//SetEntPropFloat(drop, Prop_Data, "m_flElasticity", AIRDROP_ELASTICITY);
			
			// Sets health
			SetEntProp(drop, Prop_Data, "m_takedamage", iDamage);
			SetEntProp(drop, Prop_Data, "m_iHealth", AIRDROP_HEALTH);
			SetEntProp(drop, Prop_Data, "m_iMaxHealth", AIRDROP_HEALTH);
			
			// Sets type
			SetEntProp(drop, Prop_Data, "m_iHammerID", iType);
		}*
		
		SetEntityCollisionGroup(entity, 0);
		EntityCollisionRulesChanged(entity);*/
	}
	else
	{
		// Destroy timer
		return Plugin_Stop;
	}
	
	
	// Allow timer
	return action_type;
}

/**
 * @brief Main timer for remove helicopter.
 *
 * @param hTimer            The timer handle.
 * @param refID             The reference index.
 **/
public Action HelicopterRemoveHook(Handle hTimer, int refID)
{
	// Gets entity index from reference key
	int entity = EntRefToEntIndex(refID);

	// Validate entity
	if (entity != -1)
	{
		Call_StartForward(Forward.OnHeliGoAway); 
		Call_PushCell(entity);
		Call_Finish();
		
		// Sets idle
		SetVariantString("helicopter_coop_towerhover_flyaway");
		AcceptEntityInput(entity, "SetAnimation");
		
		rp_PerformLoadingBar(helicopter_owner[entity], LOADING_SURVIVALPANEL, "Départ de l'hélicoptère", 2);
		helicopter_owner[entity] = 0;
		int owner = helicopter_owner[entity];
		helicopter_entity[owner] = 0;
		
		SetEntityCollisionGroup(owner, 0);
		EntityCollisionRulesChanged(owner);
		
		// Kill entity after delay
		UTIL_RemoveEntity(entity, 8.3);
	}
	
	// Destroy timer
	return Plugin_Stop;
}


/**
 * @brief Transform filling amount to body index.
 * 
 * @param iLeft             The amount which left.        
 * @return                  The skin index.
 **/
stock int LeftToBody(int iLeft)
{
	// Calculate left percentage
	float flLeft = float(iLeft) / AIRDROP_WEAPONS;
	if (flLeft > 0.8)      return 0;    
	else if (flLeft > 0.6) return 1;
	else if (flLeft > 0.4) return 2;
	else if (flLeft > 0.2) return 3;
	return 4;   
}

public void OnClientAuthorized(int client, const char[] auth) 
{	
	strcopy(steamID[client], sizeof(steamID[]), auth);
}

public Action Timer_GiftChangeMDL(Handle timer, int entity)
{
	float vPosition[3], vAngle[3];
	Entity_GetAbsOrigin(entity, vPosition);
	Entity_GetAbsAngles(entity, vAngle);
	
	char owner[32];
	Entity_GetName(entity, STRING(owner));
	UTIL_RemoveEntity(entity, 0.0);
	
	char sModel[128];
	rp_GetGlobalData("model_airdrop", STRING(sModel));
	
	int drop = rp_CreateDynamic("gift", vPosition, vAngle, sModel, "idle", true, true, .bAnimated = false);
	Entity_SetName(drop, owner);
	rp_SetEntityAnimation(drop, "chute_fade", 0.0);
	
	Call_StartForward(Forward.OnGiftDropped); 
	Call_PushCell(drop);
	Call_Finish();
	
	return Plugin_Handled;
}	