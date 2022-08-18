stock bool IsClientValid(int client = -1, bool bAlive = false) 
{
	return MaxClients >= client > 0 && IsClientConnected(client) && !IsFakeClient(client) && IsClientInGame(client) && (!bAlive || IsPlayerAlive(client)) ? true : false;
}

stock void TrashTimer(Handle & hTimer, bool bIsRepeat = false) 
{
	if (hTimer != null) 
	{
		if (bIsRepeat) 
			CloseHandle(hTimer);
		else 
			delete hTimer;
		hTimer = null;
	}
}

stock void LoadTranslation()
{
	LoadTranslations("common.phrases");
	LoadTranslations("roleplay.phrases");
}	

stock bool rp_IsValidPrinter(int entity)
{
	if(IsValidEntity(entity))
	{
		if(IsEntityModelInArray(entity, "model_printer"))
			return true;
	}
	
	return false;
}

stock bool rp_IsValidBox(int entity)
{
	if(IsValidEntity(entity))
	{
		if(IsEntityModelInArray(entity, "model_box"))
			return true;
	}
	
	return false;
}

stock bool rp_IsValidWorkBench(int entity)
{
	if(IsValidEntity(entity))
	{
		if(IsEntityModelInArray(entity, "model_workbench"))
			return true;
	}
	
	return false;
}

stock bool rp_IsValidDoor(int ent)
{
	char entClass[64];
	if(IsValidEntity(ent))
	{
		Entity_GetClassName(ent, STRING(entClass));
		
		if(StrContains(entClass, "door") != -1)
			return true;
	}
	
	return false;
}

stock bool rp_IsValidDrugRack(int entity)
{
	if(IsValidEntity(entity))
	{
		if(IsEntityModelInArray(entity, "model_drugrack"))
			return true;
	}
	
	return false;
}

stock bool rp_IsValidGasStove(int entity)
{
	if(IsValidEntity(entity))
	{
		if(IsEntityModelInArray(entity, "model_gasstove"))
			return true;
	}
	
	return false;
}

stock bool rp_HasDoorAccess(int client, int entity)
{
	if(rp_GetClientInt(client, i_Job) == rp_GetDoorJobID(entity))
		return true;
	else
		return false;
}

stock bool rp_IsValidDoorAppart(int ent)
{
	char entClass[64], entName[64];
	if(IsValidEntity(ent))
	{
		Entity_GetClassName(ent, STRING(entClass));
		Entity_GetName(ent, STRING(entName));
		
		if(StrContains(entClass, "door") != -1 && StrContains(entName, "door_appart_") != -1)
			return true;
	}
	
	return false;
}

stock bool rp_IsValidDoorVilla(int ent)
{
	char entClass[64], entName[64];
	if(IsValidEntity(ent))
	{
		Entity_GetClassName(ent, STRING(entClass));
		Entity_GetName(ent, STRING(entName));
		
		if(StrContains(entClass, "door") != -1 && StrContains(entName, "door_villa_") != -1)
			return true;
	}
	
	return false;
}

stock bool rp_IsValidDoorHotel(int ent)
{
	char entClass[64], entName[64];
	if(IsValidEntity(ent))
	{
		Entity_GetClassName(ent, STRING(entClass));
		Entity_GetName(ent, STRING(entName));
		
		if(StrContains(entClass, "door") != -1 && StrContains(entName, "door_hotel_") != -1)
			return true;
	}
	
	return false;
}

stock void GetVehicleName(int carID, char[] name, int maxlength)
{
	KeyValues kv = new KeyValues("Vehicles");

	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, STRING(sPath), "data/roleplay/vehicles.cfg");
	
	Kv_CheckIfFileExist(kv, sPath);
	
	char kv_carid[16];
	IntToString(carID, STRING(kv_carid));
	if(kv.JumpToKey(kv_carid))
	{	
		kv.GetString("brand", name, maxlength);
	}	
	
	kv.Rewind();
	delete kv;
}

stock int GetVehiclePrice(int carID)
{
	int price = -1;
	KeyValues kv = new KeyValues("Vehicles");

	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, STRING(sPath), "data/roleplay/vehicles.cfg");
	
	Kv_CheckIfFileExist(kv, sPath);
	
	char kv_carid[16];
	IntToString(carID, STRING(kv_carid));
	if(kv.JumpToKey(kv_carid))
	{	
		price = kv.GetNum("price");
	}	
	
	kv.Rewind();
	delete kv;
	
	return price;
}	

stock float GetVehicleMaxFuel(int carID)
{
	float fuel = 0.0;
	KeyValues kv = new KeyValues("Vehicles");

	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, STRING(sPath), "data/roleplay/vehicles.cfg");
	
	Kv_CheckIfFileExist(kv, sPath);
	
	char kv_carid[16];
	IntToString(carID, STRING(kv_carid));
	if(kv.JumpToKey(kv_carid))
	{	
		fuel = kv.GetFloat("maxfuel");
	}	
	
	kv.Rewind();
	delete kv;
	
	return fuel;
}	

stock float Distance(int client, int target)
{
	float origin1[3], origin2[3];
	GetEntPropVector(client, Prop_Send, "m_vecOrigin", origin1);
	GetEntPropVector(target, Prop_Send, "m_vecOrigin", origin2);
	return GetVectorDistance(origin1, origin2);
}

stock int HandleNothing(Menu menu, MenuAction action, int client, int param)
{
	if (action == MenuAction_Select) 
	{
		switch (param) 
		{
			default: // cancel
			{
				rp_SetClientBool(client, b_DisplayHud, true);
			}
		}
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit || param == MenuCancel_ExitBack)
			rp_SetClientBool(client, b_DisplayHud, true);
	}
	else if(action == MenuAction_End)
	{
		rp_SetClientBool(client, b_DisplayHud, true);
		delete menu;
	}
	
	return 0;
}

stock void GetMonthName(int monthID, char[] monthname, int maxlen)
{
	switch(monthID)
	{			
		case 1:
		{
			Format(monthname, maxlen, "%T", "Month_January", LANG_SERVER);
		}
		case 2:
		{
			Format(monthname, maxlen, "%T", "Month_February", LANG_SERVER);
		}
		case 3:
		{
			Format(monthname, maxlen, "%T", "Month_March", LANG_SERVER);
		}
		case 4:
		{
			Format(monthname, maxlen, "%T", "Month_April", LANG_SERVER);
		}
		case 5:
		{
			Format(monthname, maxlen, "%T", "Month_May", LANG_SERVER);
		}
		case 6:
		{
			Format(monthname, maxlen, "%T", "Month_June", LANG_SERVER);	
		}
		case 7:
		{
			Format(monthname, maxlen, "%T", "Month_July", LANG_SERVER);
		}
		case 8:
		{
			Format(monthname, maxlen, "%T", "Month_August", LANG_SERVER);	
		}
		case 9:
		{
			Format(monthname, maxlen, "%T", "Month_September", LANG_SERVER);
		}
		case 10:
		{
			Format(monthname, maxlen, "%T", "Month_October", LANG_SERVER);
		}
		case 11:
		{
			Format(monthname, maxlen, "%T", "Month_November", LANG_SERVER);
		}
		case 12:
		{
			Format(monthname, maxlen, "%T", "Month_December", LANG_SERVER);	
		}
		default:
		{
			Format(monthname, maxlen, "ERROR TIME");		
		}
	}
}	

stock void SaveOrGetCapital(bool load = true)
{
	KeyValues kv = new KeyValues("Jobs");
	
	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, STRING(sPath), "data/roleplay/jobs.cfg");
	
	Kv_CheckIfFileExist(kv, sPath);
		
	for (int i = 0; i <= MAXJOBS; i++)
	{	
		char jobNum[10];
		IntToString(i, STRING(jobNum));
		
		if(kv.JumpToKey(jobNum))
		{	
			if(load)
			{
				rp_SetJobCapital(i, kv.GetNum("capital"));
				kv.GoBack();
			}
			else
			{
				kv.SetNum("capital", rp_GetJobCapital(i));	
				kv.Rewind();
				kv.ExportToFile(sPath);			
			}	
		}
	}	

	kv.Rewind();
	delete kv;
} 

stock void ShowHudMsg(int client, char[] message, int r, int g, int b, float x, float y, float timeout) 
{
	SetHudTextParams(x, y, timeout, r, g, b, 255, 0, 0.0, 0.0, 0.0);
	ShowHudText(client, -1, message);
}

stock void rp_GetCurrentMap(char[] map, int maxlength)
{
	char tmp[128];
	GetCurrentMap(STRING(tmp));
	if (StrContains(tmp, "workshop") != -1) {
		char mapPart[3][64];
		ExplodeString(tmp, "/", mapPart, 3, 64);
		strcopy(map, maxlength, mapPart[2]);
	}
	else
		strcopy(map, maxlength, tmp);
}

stock void EmitCashSound(int client, int value)
{
	if(IsClientValid(client))
	{
		if(value < 0)
			ShowPanel2(client, 1, "<font color='%s'>-%i$</font>", HTML_CRIMSON, value);
		else
			ShowPanel2(client, 1, "<font color='%s'>+%i$</font>", HTML_CHARTREUSE, value);
		PrecacheSound("ui/store_item_purchased.wav");
		EmitSoundToClient(client, "ui/store_item_purchased.wav", client, _, _, _, 1.0);
	}
}

stock void EmitMysterySound(int client)
{
	if(IsClientValid(client))
	{
		PrecacheSound("ui/store_item_purchased.wav");
		EmitSoundToClient(client, "ui/store_item_purchased.wav", client, _, _, _, 1.0);
	}
}	

stock void rp_SetClientAmmo(int weaponEnt, int clip = -1, int ammo = -1, bool add = false)
{
	if (weaponEnt == INVALID_ENT_REFERENCE)
		return;

	if (clip != -1)
	{
		if(add)
			SetEntProp(weaponEnt, Prop_Send, "m_iClip1", GetEntProp(weaponEnt, Prop_Send, "m_iClip1") + clip);		
		else
			SetEntProp(weaponEnt, Prop_Send, "m_iClip1", clip);				
	}	

	if (ammo != -1)
	{
		if(add)
			SetEntProp(weaponEnt, Prop_Send, "m_iPrimaryReserveAmmoCount", GetEntProp(weaponEnt, Prop_Send, "m_iPrimaryReserveAmmoCount") + ammo);		
		else
			SetEntProp(weaponEnt, Prop_Send, "m_iPrimaryReserveAmmoCount", ammo);				
	}	
}

stock int FindPlayer(int client, char[] arg, bool alive = false)
{
	int target = FindTarget(client, arg, true, false);
	if (target <= COMMAND_TARGET_NONE)
	{
		ReplyToTargetError(client, target);
		return -1;
	}
    
	return target;
}

stock void Kv_CheckIfFileExist(KeyValues kv, const char[] file)
{
	if(!kv.ImportFromFile(file))
	{
		delete kv;
		PrintToServer("%s NOT FOUND", file);
	}
}	

stock bool RayDontHitClient(int entity, int contentsMask, any data)
{
	return entity != data;
}

stock bool TraceEntityFilterPlayer(int entity, int contentsMask)
{
	return entity > MaxClients;
}	

stock void PointVision(int client, float position[3])
{
	float origin[3], angles[3];
	GetClientEyePosition(client, origin);
	GetClientEyeAngles(client, angles);
	Handle trace = TR_TraceRayFilterEx(origin, angles, MASK_SOLID, RayType_Infinite, TraceEntityFilterPlayer);
	if(TR_DidHit(trace))
	{
		TR_GetEndPosition(position, trace);
		delete trace;
		return;
	}
	delete trace;
}

stock void rp_SetClientArmor(int client, int amount)
{
	if(IsClientValid(client))
	{
		if(amount < 0)
			SetEntProp(client, Prop_Data, "m_ArmorValue", -amount, 4);
		else
			SetEntProp(client, Prop_Data, "m_ArmorValue", amount, 4);		
	}
}

stock void rp_SetClientHelmet(int client, bool value)
{
	if(IsClientValid(client))
	{
		if(value)
			SetEntProp(client, Prop_Send, "m_bHasHelmet", 1);
		else
			SetEntProp(client, Prop_Send, "m_bHasHelmet", 0);
	}
}

stock void rp_SetClientHealth(int client, int hp)
{
	if(IsClientValid(client))
	{
		SetEntityHealth(client, hp);
	}
}

stock void rp_SetDefaultClientColor(int client) 
{
	if (IsClientValid(client))
	{
		SetEntityRenderColor(client, 255, 255, 255, 255);
	}
}

stock Action Timer_ResetClientColor(Handle timer, any client) 
{
	if (IsClientValid(client))
	{
		SetEntityRenderColor(client, 255, 255, 255, 255);
	}
	
	return Plugin_Handled;
}

stock void ScreenFade(int client, int duration, int color[4])
{
	if(IsClientValid(client))
	{
		int clients[2];
		clients[0] = client;
		Handle message = StartMessage("Fade", clients, 1);
		Protobuf pb = UserMessageToProtobuf(message);
		pb.SetInt("duration", duration * 1000);
		pb.SetInt("hold_time", 1);
		pb.SetInt("flags", 0);
		pb.SetColor("clr", color);
		EndMessage();
	}
}

stock void ScreenShake(int client, float amplitude, float frequency, float duration)
{
	Handle hShake = StartMessageOne("Shake", client);
	PbSetInt(hShake, "command", 0);
	PbSetFloat(hShake, "local_amplitude", amplitude);
	PbSetFloat(hShake, "frequency", frequency);
	PbSetFloat(hShake, "duration", duration);
	EndMessage();
} 

stock void rp_ClientTeleport(int client, float pos[3])
{
	TeleportEntity(client, pos, NULL_VECTOR, NULL_VECTOR);
}	

stock int GetParamPolice(bool amende, char[] motif)
{	
	KeyValues kv = new KeyValues("Amendes");

	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, STRING(sPath), "data/roleplay/amendes.cfg");
	
	if(!kv.ImportFromFile(sPath))
	{
		delete kv;
		PrintToServer("data/roleplay/amendes.cfg : NOT FOUND");
	}	
	
	kv.JumpToKey(motif);
	
	int valeur;
	
	if(amende)
		valeur = kv.GetNum("amende");
	else
		valeur = kv.GetNum("temps");	
	kv.Rewind();	
	delete kv;
	
	return valeur;
}

stock void SetParamPolice(bool amende, char[] motif, int montant)
{
	KeyValues kv = new KeyValues("Amendes");

	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, STRING(sPath), "data/roleplay/amendes.cfg");
	
	if(!kv.ImportFromFile(sPath))
	{
		delete kv;
		PrintToServer("data/roleplay/amendes.cfg : NOT FOUND");
	}
	
	kv.JumpToKey(motif);
	
	if(amende)
		kv.SetNum("amende", montant);
	else
		kv.SetNum("temps", montant);
	kv.Rewind();	
	delete kv;
}

stock void StringTime(int temps, char[] strFormat, int maxLen)
{
	int jours = temps / 86400;
	int heures = temps % 86400 / 3600;
	int minutes = temps % 86400 % 3600 / 60;
	
	if(jours == 0)
	{
		if(heures == 0)
		{
			Format(strFormat, maxLen, "%i Minutes %i Secondes", minutes, temps);	
		}	
		else
		{
			Format(strFormat, maxLen, "%i Heures %i Minutes %i Secondes", heures, minutes, temps);	
		}
	}	
	else
	{
		if(heures == 0)
		{
			Format(strFormat, maxLen, "%i Minutes %i Secondes", minutes, temps);		
		}	
		else
		{
			Format(strFormat, maxLen, "%i Jours %i Heures %i Minutes %i Secondes", jours, heures, minutes, temps);	
		}
	}	
}

stock int rp_CreateParticle(float position[3], char[] particleName, float time)
{
	int ent = CreateEntityByName("info_particle_system");
	TeleportEntity(ent, position, NULL_VECTOR, NULL_VECTOR);
	DispatchKeyValue(ent, "effect_name", particleName);
	DispatchKeyValue(ent, "targetname", "particle");
	DispatchSpawn(ent);
	ActivateEntity(ent);
	AcceptEntityInput(ent, "start");
	UTIL_RemoveEntity(ent, time);
	
	return ent;
}

stock int rp_AttachCreateParticle(int client, char[] particleName, float time = 1.0)
{
	float position[3];
	GetClientAbsOrigin(client, position);
	
	int iEntity = CreateEntityByName("info_particle_system");
	TeleportEntity(iEntity, position, NULL_VECTOR, NULL_VECTOR);
				
	DispatchKeyValue(iEntity, "effect_name", particleName);
	SetVariantString("!activator");
	AcceptEntityInput(iEntity, "SetParent", client, iEntity, 0);
	DispatchSpawn(iEntity);
	ActivateEntity(iEntity);
	AcceptEntityInput(iEntity, "Start");
	
	if(time >= 1.0)
		UTIL_RemoveEntity(iEntity, time);
	
	return iEntity;
}

stock void RemoveParticle(int ent)
{
	if(IsValidEdict(ent))
		RemoveEdict(ent);
}

stock bool rp_canSetAmmo(int client, int weapon)
{
	char weaponName[64];
	Entity_GetClassName(weapon, STRING(weaponName));
	
	if(StrContains(weaponName, "knife") == -1
	&& StrContains(weaponName, "grenade") == -1
	&& StrContains(weaponName, "he") == -1
	&& StrContains(weaponName, "flashbang") == -1
	&& StrContains(weaponName, "gss") == -1
	&& StrContains(weaponName, "smoke") == -1
	&& StrContains(weaponName, "decoy") == -1
	&& StrContains(weaponName, "molotov") == -1
	&& StrContains(weaponName, "shield") == -1
	&& StrContains(weaponName, "fists") == -1
	&& StrContains(weaponName, "axe") == -1
	&& StrContains(weaponName, "hammer") == -1
	&& StrContains(weaponName, "spanner") == -1)
		return true;
	else
		return false;
}

stock void rp_GetWeaponName(int wepid, char[] weapon, int maxlength)
{
	if(IsValidEntity(wepid))
	{
		char weaponName[64];
		Entity_GetClassName(wepid, STRING(weaponName));
	}	
}	

stock bool rp_CanSpawnKnife(int client)
{
	int wepID = Client_GetActiveWeapon(client);
	char weaponName[64];
	Entity_GetClassName(wepID, STRING(weaponName));
	
	if(StrContains(weaponName, "knife") == -1)
		return true;
	else
		return false;
}

stock bool rp_CheckIfIsUseKnife(int client)
{
	int wepID = Client_GetActiveWeapon(client);
	char weaponName[64];
	Entity_GetClassName(wepID, STRING(weaponName));
	
	if(StrContains(weaponName, "knife") != -1)
		return true;
	else
		return false;
}

stock void rp_Effect_BeamBox(int client, int target, int r = 255, int g = 255, int b = 255)
{
	int g_BeamSprite = PrecacheModel("sprites/laserbeam.vmt", true);
	int g_HaloSprite = PrecacheModel("sprites/halo.vmt", true);
	
	float clientOrigin[3], targetOrigin[3];
	GetClientAbsOrigin(client, clientOrigin);
	GetClientAbsOrigin(target, targetOrigin);
	
	int color[4];
	color[0] = r;
	color[1] = g;
	color[2] = b;
	color[3] = 255;
			
	TE_SetupBeamPoints(clientOrigin, targetOrigin, g_BeamSprite, g_HaloSprite, 0, 1, 0.1, 5.0, 5.0, 10, 0.5, color, 10);
	TE_SendToAll();
}	

stock void EmitGPSTrain(int client, float pos[3], int r = 255, int g = 255, int b = 255)
{
	int g_BeamSprite = PrecacheModel("sprites/laserbeam.vmt", true);
	int g_HaloSprite = PrecacheModel("sprites/halo.vmt", true);
	
	float clientOrigin[3];
	GetClientAbsOrigin(client, clientOrigin);
	
	int color[4];
	color[0] = r;
	color[1] = g;
	color[2] = b;
	color[3] = 255;
			
	TE_SetupBeamPoints(clientOrigin, pos, g_BeamSprite, g_HaloSprite, 0, 1, 1.0, 5.0, 5.0, 10, 0.5, color, 10);
	TE_SendToClient(client);
}

stock void EmitGPSTwiceTrain(int client, float first[3], float second[3], int r = 255, int g = 255, int b = 255)
{
	int g_BeamSprite = PrecacheModel("roleplay/tutorial/arrow.vmt", true);
	int g_HaloSprite = PrecacheModel("sprites/halo.vmt", true);
	
	int color[4];
	color[0] = r;
	color[1] = g;
	color[2] = b;
	color[3] = 255;
			
	TE_SetupBeamPoints(first, second, g_BeamSprite, g_HaloSprite, 0, 1, 0.5, 20.0, 5.0, 10, 0.1, color, 10);
	TE_SendToClient(client);
}

stock void rp_CreateFire(float position[3], float time)
{
	int ent = CreateEntityByName("env_fire");
	DispatchSpawn(ent);
	DispatchKeyValue(ent, "fireattack", "10");
	DispatchKeyValueFloat(ent, "damagescale", 2.0);
	TeleportEntity(ent, position, NULL_VECTOR, NULL_VECTOR);
	ActivateEntity(ent);
	AcceptEntityInput(ent, "StartFire");
	UTIL_RemoveEntity(ent, time);
}

stock Action rp_SetDefaultMove(Handle timer, int client)
{
	if(IsClientValid(client))
		SetEntityMoveType(client, MOVETYPE_WALK);
		
	return Plugin_Handled;
}	

stock void PrecacheAndSetModel(int client, char[] model)
{
	PrecacheModel(model);
	Entity_SetModel(client, model);
}	

stock void PrecacheAndSetArms(int client, char[] arms)
{
	PrecacheModel(arms);
	Entity_SetModel(client, arms);
}

stock void SetJobSkin(int client)
{
	KeyValues kv = new KeyValues("Jobs");

	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, STRING(sPath), "data/roleplay/jobs.cfg");
	
	Kv_CheckIfFileExist(kv, sPath);	
	
	char jobString[32];
	IntToString(rp_GetClientInt(client, i_Job), STRING(jobString));
	if(kv.JumpToKey(jobString))
	{	
		char gradeString[32];
		IntToString(rp_GetClientInt(client, i_Grade), STRING(gradeString));
		if(kv.JumpToKey(gradeString))
		{	
			char model[256], arms[256];			
			kv.GetString("model", STRING(model));
			PrintToServer("MODEL: %s", model);
			if(strlen(model) != 0)
				PrecacheAndSetModel(client, model);
			kv.GetString("arms", STRING(arms));
			PrintToServer("ARMS: %s", arms);
			if(strlen(arms) != 0)
				PrecacheAndSetArms(client, arms);
		}
	}	
	
	kv.Rewind();
	delete kv;
}

stock void RP_SetWeaponPattern(int client, int index)
{
	int weaponTemp = Client_GetActiveWeapon(client);
	int iClipTemp = GetEntProp(weaponTemp, Prop_Send, "m_iClip1");
	int iReserve = GetEntProp(weaponTemp, Prop_Send, "m_iPrimaryReserveAmmoCount");
	
	char item[64];
	GetClientWeapon(client, STRING(item));
	RemovePlayerItem(client, weaponTemp);	
	int iWeapon = GivePlayerItem(client, item);
	static int IDHigh = 16384;
	SetEntProp(iWeapon, Prop_Send, "m_iItemIDLow", -1);
	SetEntProp(iWeapon, Prop_Send, "m_iItemIDHigh", IDHigh++);
	SetEntProp(iWeapon, Prop_Send, "m_nFallbackPaintKit", index);
	SetEntProp(iWeapon, Prop_Send, "m_nFallbackSeed", 1);
	EquipPlayerWeapon(client, iWeapon);
	
	SetEntProp(iWeapon, Prop_Send, "m_iClip1", iClipTemp);  
	SetEntProp(iWeapon, Prop_Send, "m_iPrimaryReserveAmmoCount", iReserve);		
}

stock bool rp_CanUsePattern(int client, int index)
{
	int iWeapon = Client_GetActiveWeapon(client);
	int tempIndex = GetEntProp(iWeapon, Prop_Send, "m_nFallbackPaintKit");
	char weaponName[64];
	Entity_GetClassName(iWeapon, STRING(weaponName));
	
	if(StrContains(weaponName, "grenade") == -1
	&& StrContains(weaponName, "he") == -1
	&& StrContains(weaponName, "flashbang") == -1
	&& StrContains(weaponName, "gss") == -1
	&& StrContains(weaponName, "smoke") == -1
	&& StrContains(weaponName, "decoy") == -1
	&& StrContains(weaponName, "molotov") == -1
	&& StrContains(weaponName, "shield") == -1
	&& StrContains(weaponName, "fists") == -1
	&& StrContains(weaponName, "axe") == -1
	&& StrContains(weaponName, "hammer") == -1
	&& StrContains(weaponName, "spanner") == -1
	&& tempIndex != index)
		return true;
	else
		return false;
}		

stock void rp_SetSpeed(int client, float speed)
{
	if(IsClientValid(client) && IsValidEntity(client))
		SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", speed);
}	

stock float rp_GetSpeed(int client)
{
	return GetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue");
}

stock void rp_ScheduleEntityInput(int ent, float timer, const char[] input)
{
	DataPack pack;
	CreateDataTimer(timer, SendEntityInput, pack, TIMER_DATA_HNDL_CLOSE);
	pack.WriteCell(ent);
	pack.WriteString(input);
}	

stock Action SendEntityInput(Handle timer, DataPack pack) 
{
	pack.Reset();
	int entity = pack.ReadCell();
	char input[64];
	pack.ReadString(STRING(input));	
	AcceptEntityInput(entity, input);
	
	return Plugin_Continue;
}	
	
stock void rp_DisolveEntity(int ent)
{
	if(IsValidEntity(ent))
	{
		char entName[64], strType[32], entClass[32], entModel[64];
		Format(STRING(entName),"dis_%d", ent);
		Format(STRING(strType), "%d", 100);
		
		Entity_GetClassName(ent, STRING(entClass));
		Entity_GetModel(ent, STRING(entModel));
		
		if(StrEqual(entClass, "weapon_knife")
		|| StrEqual(entModel, "models/props_interiors/printer.mdl"))
		{
			int dissolver = CreateEntityByName("env_entity_dissolver");
			DispatchKeyValue(ent, "targetname", entName);
			
			DispatchKeyValue(dissolver, "dissolvetype", strType);
			DispatchKeyValue(dissolver, "target", entName);
			AcceptEntityInput(dissolver, "Dissolve");
			AcceptEntityInput(dissolver, "kill");
		}
	}
}	

stock void rp_SoundAll(int origin, char[] sound, float volume)
{
	char sTmp[128];
	rp_GetGlobalData(sound, STRING(sTmp));
	if(!StrEqual(sTmp, ""))
		EmitSoundToAll(sTmp, origin, _, _, _, volume);
	else
	{
		PrecacheSound(sound);
		EmitSoundToAll(sound, origin, _, _, _, volume);
	}
}

stock void rp_Sound(int receiver, char[] sound, float volume)
{
	char sTmp[128];
	rp_GetGlobalData(sound, STRING(sTmp));
	if(!StrEqual(sTmp, ""))
		EmitSoundToClient(receiver, sTmp, _, _, _, _, volume);
	else
	{
		PrecacheSound(sound);
		EmitSoundToClient(receiver, sound, _, _, _, _, volume);
	}	
}

stock void rp_StopSound(int target, char[] sound)
{
	char sTmp[128];
	rp_GetGlobalData(sound, STRING(sTmp));
	if(!StrEqual(sTmp, ""))
		StopSound(target, SNDCHAN_AUTO, sTmp);
	else
		StopSound(target, SNDCHAN_AUTO, sound);
}

stock int GetMaxLvlCut(int client)
{	
	int maxLvlCut;	
	if(rp_CheckIfIsUseKnife(client))
	{
		char knifename[64];
		GetClientWeapon(client, STRING(knifename));
		
		if(StrEqual(knifename, "weapon_knifegg"))
			maxLvlCut = 10;
		else if(StrEqual(knifename, "weapon_knife_ghost"))
			maxLvlCut = 15;
		else if(StrEqual(knifename, "weapon_bayonet"))
			maxLvlCut = 20;
		else if(StrEqual(knifename, "weapon_knife_butterfly"))
			maxLvlCut = 25;
		else if(StrEqual(knifename, "weapon_knife_falchion"))
			maxLvlCut = 30;
		else if(StrEqual(knifename, "weapon_knife_flip"))
			maxLvlCut = 35;
		else if(StrEqual(knifename, "weapon_knife_gut"))
			maxLvlCut = 40;
		else if(StrEqual(knifename, "weapon_knife_tactical"))
			maxLvlCut = 45;
		else if(StrEqual(knifename, "weapon_knife_karambit"))
			maxLvlCut = 50;	
		else if(StrEqual(knifename, "weapon_knife_m9_bayonet"))
			maxLvlCut = 55;
		else if(StrEqual(knifename, "weapon_knife_push"))
			maxLvlCut = 60;
		else if(StrEqual(knifename, "weapon_knife_survival_bowie"))
			maxLvlCut = 65;
		else if(StrEqual(knifename, "weapon_knife_ursus"))
			maxLvlCut = 70;
		else if(StrEqual(knifename, "weapon_knife_gypsy_jackknife"))
			maxLvlCut = 75;
		else if(StrEqual(knifename, "weapon_knife_stiletto"))
			maxLvlCut = 80;
		else if(StrEqual(knifename, "weapon_knife_widowmaker"))
			maxLvlCut = 85;
		else if(StrEqual(knifename, "weapon_knife_css"))
			maxLvlCut = 90;
		else if(StrEqual(knifename, "weapon_knife_skeleton"))
			maxLvlCut = 95;
		else if(StrEqual(knifename, "weapon_knife_cord"))
			maxLvlCut = 100;
		else if(StrEqual(knifename, "weapon_knife_canis"))
			maxLvlCut = 105;	
		else
			maxLvlCut = 2;		
	}
	else
		return -1;
	return maxLvlCut;
}

stock int IsFondateur(int client)
{
	char SteamId[64];
	GetClientAuthId(client, AuthId_Steam2, STRING(SteamId));
	
	if (StrEqual(SteamId, "STEAM_1:1:512215951")
		|| StrEqual(SteamId, "STEAM_1:0:68792182"))
		return true;
	else
		return false;
}

stock int IsCoFondateur(int client)
{
	char SteamId[64];
	GetClientAuthId(client, AuthId_Steam2, STRING(SteamId));
	
	if (StrEqual(SteamId, "STEAM_1:1:226923401"))
		return true;
	else
		return false;
}

stock int IsResponable(int client)
{
	char SteamId[64];
	GetClientAuthId(client, AuthId_Steam2, STRING(SteamId));
	
	if (StrEqual(SteamId, "STEAM_1:1:9999999"))
		return true;
	else
		return false;
}

stock void CheckSpeed(int client)
{
	float speed = rp_GetSpeed(client);
	
	if (rp_GetClientFloat(client, fl_Faim) >= 85.0 && rp_GetClientFloat(client, fl_Faim) <= 100.0)
		speed += 0.4;
	else if (rp_GetClientFloat(client, fl_Faim) >= 50.0 && rp_GetClientFloat(client, fl_Faim) < 85.0)
		speed -= 0.1;
	else if (rp_GetClientFloat(client, fl_Faim) >= 25.0 && rp_GetClientFloat(client, fl_Faim) < 50.0)
		speed -= 0.2;
	else if (rp_GetClientFloat(client, fl_Faim) < 25.0)
		speed -= 0.3;
	
	if(rp_GetClientSurgery(client, surgery_lung))
		speed += 0.4;	
		
	rp_SetSpeed(client, speed);
}	

stock void CheckGravity(int client)
{
	float gravity = 1.0;
	
	if(rp_GetClientSurgery(client, surgery_legs))
		gravity -= 0.4;	
	
	SetEntityGravity(client, gravity);
}

stock void SprayGraffiti(const float origin[3], int spray)
{
	TE_Start("World Decal");
	TE_WriteVector("m_vecOrigin", origin);
	TE_WriteNum("m_nIndex", spray);
}

stock void SpawnJail(int client, int id)
{
	KeyValues kv = new KeyValues("Jails");
	char sPath[PLATFORM_MAX_PATH], map[64];
	rp_GetCurrentMap(STRING(map));
	BuildPath(Path_SM, STRING(sPath), "data/roleplay/%s/jails.cfg", map);	
	Kv_CheckIfFileExist(kv, sPath);
	
	char tmp[16];
	IntToString(id, STRING(tmp));
	if(kv.JumpToKey("1"))
	{	
		float position[3];
		if(kv.GetVector(tmp, position))
			rp_ClientTeleport(client, position);
	}	
	
	kv.Rewind();
	delete kv;
}

stock void SpawnJob(int client)
{
	KeyValues kv = new KeyValues("Spawn");

	char sPath[PLATFORM_MAX_PATH], map[64];
	rp_GetCurrentMap(STRING(map));
	BuildPath(Path_SM, STRING(sPath), "data/roleplay/%s/spawn.cfg", map);
	
	Kv_CheckIfFileExist(kv, sPath);
	
	if(kv.JumpToKey("job"))
	{
		char kv_jobid[16];
		IntToString(rp_GetClientInt(client, i_Job), STRING(kv_jobid));
		if(kv.JumpToKey(kv_jobid))
		{
			float position[3];
			kv.GetVector("position", position);
			rp_ClientTeleport(client, position);
		}
	}
	
	kv.Rewind();
	delete kv;
}

stock void Out(int client, int target) 
{
	KeyValues kv = new KeyValues("Out");
	
	char map[64];
	rp_GetCurrentMap(STRING(map));
	
	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, STRING(sPath), "data/roleplay/%s/out.cfg", map);
	
	Kv_CheckIfFileExist(kv, sPath);	
	
	char jobString[32];
	IntToString(rp_GetClientInt(client, i_Job), STRING(jobString));
	if(kv.JumpToKey(jobString))
	{
		float position[3];
		kv.GetVector("position", position);
		
		if(position[0] != 0.0 && position[1] != 0.0 && position[2] != 0.0)
			TeleportEntity(target, position, NULL_VECTOR, NULL_VECTOR);
		else
			return;
	}
	kv.Rewind();	
	delete kv;
}

stock void SpawnLocation(int client, char[] type = "appartment")
{
	KeyValues kv = new KeyValues("Locations");

	char sPath[PLATFORM_MAX_PATH], map[64];
	rp_GetCurrentMap(STRING(map));
	BuildPath(Path_SM, STRING(sPath), "data/roleplay/%s/locations.cfg", map);
	
	Kv_CheckIfFileExist(kv, sPath);
	
	if(kv.JumpToKey("hotel"))
	{
		int loctype = -1;
		
		if(StrEqual(type, "appartment", false))
			loctype = rp_GetClientInt(client, i_Appart);
		else if(StrEqual(type, "villa", false))
			loctype = rp_GetClientInt(client, i_Villa);
		else if(StrEqual(type, "hotel", false))
			loctype = rp_GetClientInt(client, i_Hotel);
		
		char sId[8];
		IntToString(loctype, STRING(sId));
		if(kv.JumpToKey(sId))
		{
			float position[3];
			kv.GetVector("position", position);
			rp_ClientTeleport(client, position);
		}
	}

	kv.Rewind();
	delete kv;
}

stock void OutLocation(int client, int target, char[] type = "appartment") 
{
	KeyValues kv = new KeyValues("Locations");
	
	char map[64];
	rp_GetCurrentMap(STRING(map));
	
	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, STRING(sPath), "data/roleplay/%s/locations.cfg", map);
	
	Kv_CheckIfFileExist(kv, sPath);	
	
	if(kv.JumpToKey(type))
	{
		int loctype = -1;
		
		if(StrEqual(type, "appartment", false))
			loctype = rp_GetClientInt(client, i_Appart);
		else if(StrEqual(type, "villa", false))
			loctype = rp_GetClientInt(client, i_Villa);
		else if(StrEqual(type, "hotel", false))
			loctype = rp_GetClientInt(client, i_Hotel);
		
		char sId[8];
		IntToString(loctype, STRING(sId));
		if(kv.JumpToKey(sId))
		{
			float position[3];
			kv.GetVector("position", position);
			
			if(position[0] != 0.0 && position[1] != 0.0 && position[2] != 0.0)
				TeleportEntity(target, position, NULL_VECTOR, NULL_VECTOR);
			else
				return;
		}
	}
	
	kv.Rewind();	
	delete kv;
}

stock bool isZoneProprietaire(int client)
{
	int jobid = rp_GetClientInt(client, i_Job);
	int zoneid = rp_GetClientInt(client, i_Zone);
	
	if(jobid == 1 && zoneid == 1)
		return true;
	else if(jobid == 2 && zoneid == 2)
		return true;
	else if(jobid == 3 && zoneid == 3)
		return true;	
	else if(jobid == 4 && zoneid == 4)
		return true;	
	else if(jobid == 5 && zoneid == 5)
		return true;	
	else if(jobid == 6 && zoneid == 6)
		return true;
	else if(jobid == 7 && zoneid == 7)
		return true;
	else if(jobid == 8 && zoneid == 8)
		return true;
	else if(jobid == 9 && zoneid == 9)
		return true;
	else if(jobid == 10 && zoneid == 10)
		return true;	
	else if(jobid == 11 && zoneid == 11)
		return true;
	else if(jobid == 12 && zoneid == 12)
		return true;
	else if(jobid == 13 && zoneid == 13)
		return true;	
	else if(jobid == 14 && zoneid == 14)
		return true;	
	else if(jobid == 15 && zoneid == 15)
		return true;
	else if(jobid == 16 && zoneid == 16)
		return true;
	else if(jobid == 17 && zoneid == 17)
		return true;
	else if(jobid == 18 && zoneid == 18)
		return true;
	else if(jobid == 19 && zoneid == 19)
		return true;
	else if(jobid == 20 && zoneid == 20)
		return true;		
	else
		return false;
}

stock bool IsLocationOwner(int client)
{
	if(rp_GetClientInt(client, i_ZoneAppart) == rp_GetClientInt(client, i_Appart))
		return true;
	else if(rp_GetClientInt(client, i_ZoneVilla) == rp_GetClientInt(client, i_Villa))
		return true;
	else if(rp_GetClientInt(client, i_ZoneHotel) == rp_GetClientInt(client, i_Hotel))
		return true;
	else
		return false;
}

stock bool IsAppartOwner(int client)
{
	if(rp_GetClientInt(client, i_ZoneAppart) == rp_GetClientInt(client, i_Appart))
		return true;
	else
		return false;
}

stock bool IsVillaOwner(int client)
{
	if(rp_GetClientInt(client, i_ZoneVilla) == rp_GetClientInt(client, i_Villa))
		return true;
	else
		return false;
}

stock bool IsHotelOwner(int client)
{
	if(rp_GetClientInt(client, i_ZoneHotel) == rp_GetClientInt(client, i_Hotel))
		return true;
	else
		return false;
}

stock int GetAppartmentId(int target)
{
	int id = -1;
	if(rp_IsValidDoorAppart(target))
	{
		char entName[64];
		Entity_GetName(target, STRING(entName));	
		char strAppart[3][64];		
		ExplodeString(entName, "_", strAppart, 3, 64);
		
		id = StringToInt(strAppart[2]);
	}
	
	return id;
}	

stock int GetVillaId(int target)
{
	int id = -1;
	if(rp_IsValidDoorVilla(target))
	{
		char entName[64];
		Entity_GetName(target, STRING(entName));	
		char strAppart[3][64];		
		ExplodeString(entName, "_", strAppart, 3, 64);
		
		id = StringToInt(strAppart[2]);
	}
	
	return id;
}

stock bool IsClientInAppart(int client)
{
	int id = rp_GetClientInt(client, i_Appart);
	int owner = rp_GetAppartementInt(id, appart_owner);
	
	if(rp_GetClientInt(client, i_ZoneAppart) == id && owner == client)
		return true;

	return false;
}

stock bool IsClientInVilla(int client)
{
	int id = rp_GetClientInt(client, i_Villa);
	int owner = rp_GetVillaInt(id, villa_owner);
	
	if(rp_GetClientInt(client, i_ZoneVilla) == id && owner == client)
		return true;

	return false;
}

stock bool IsClientInHotel(int client)
{
	int id = rp_GetClientInt(client, i_Hotel);
	int owner = rp_GetHotelInt(id, hotel_owner);
	
	if(rp_GetClientInt(client, i_ZoneHotel) == id && owner == client)
		return true;

	return false;
}

stock bool IsOwnerInAppart(int appid)
{
	LoopClients(i)
	{
		if(!IsClientValid(i))
			continue;
			
		if(rp_GetClientInt(i, i_ZoneAppart) == appid && rp_GetAppartementInt(appid, appart_owner) == i)	
			return true;
	}

	return false;
}

stock bool IsOwnerInVilla(int villaid)
{
	LoopClients(i)
	{
		if(!IsClientValid(i))
			continue;
			
		if(rp_GetClientInt(i, i_ZoneVilla) == villaid && rp_GetClientInt(i, i_Villa) == villaid && rp_GetVillaInt(villaid, villa_owner) == i)	
			return true;
		else
			return false;
	}

	return false;
}

stock bool IsOwnerInHotel(int hotelid)
{
	LoopClients(i)
	{
		if(!IsClientValid(i))
			continue;
			
		if(rp_GetClientInt(i, i_ZoneHotel) == hotelid && rp_GetClientInt(i, i_Hotel) == hotelid && rp_GetHotelInt(hotelid, hotel_owner) == i)	
			return true;
		else
			return false;
	}

	return false;
}

stock bool Zone_Surgery(int client)
{
	float position[3];
	GetEntPropVector(client, Prop_Send, "m_vecOrigin", position);
	
	if (position[0] >= -1597.397827 && position[0] <= -1192.397827 && position[1] >= -9115.031250 && position[1] <= -8995.031250 && position[2] >= 298.701416 && position[2] <= 433.701416)
	{
		return true;
	}
	else 
		return false;
}

stock void rp_DeleteWeapon(int client, int weapon)
{
	if(IsClientValid(client))
	{
		if(IsValidEntity(weapon) && weapon > 0)
		{
			RemovePlayerItem(client, weapon);
			if(IsValidEntity(weapon))
				AcceptEntityInput(weapon, "Kill");
			
			int knife = GetPlayerWeaponSlot(client, CS_SLOT_KNIFE);
			SetEntPropEnt(client, Prop_Data, "m_hActiveWeapon", knife);
			ChangeEdictState(client, FindDataMapInfo(client, "m_hActiveWeapon"));
		}
	}
}				

stock int GetAppartPrice(int appID)
{
	int price = 0;
	
	KeyValues kv = new KeyValues("Locations");
	
	char map[64];
	rp_GetCurrentMap(STRING(map));
	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, STRING(sPath), "data/roleplay/%s/locations.cfg", map);
	Kv_CheckIfFileExist(kv, sPath);
	
	if(kv.JumpToKey("appartment"))
	{
		char kv_appid[16];
		IntToString(appID, STRING(kv_appid));
		if(kv.JumpToKey(kv_appid))
		{	
			price = kv.GetNum("price");
		}
	}
	
	kv.Rewind();
	delete kv;
	
	return price;
}

stock int GetVillaPrice(int villaID)
{
	int price = 0;
	
	KeyValues kv = new KeyValues("Locations");
	
	char map[64];
	rp_GetCurrentMap(STRING(map));
	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, STRING(sPath), "data/roleplay/%s/locations.cfg", map);
	Kv_CheckIfFileExist(kv, sPath);
	
	if(kv.JumpToKey("villa"))
	{
		char kv_appid[16];
		IntToString(villaID, STRING(kv_appid));
		if(kv.JumpToKey(kv_appid))
		{	
			price = kv.GetNum("price");
		}
	}
	
	kv.Rewind();
	delete kv;
	
	return price;
}

stock int GetHotelPrice(int villaID)
{
	int price = 0;
	
	KeyValues kv = new KeyValues("Locations");
	
	char map[64];
	rp_GetCurrentMap(STRING(map));
	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, STRING(sPath), "data/roleplay/%s/locations.cfg", map);
	Kv_CheckIfFileExist(kv, sPath);
	
	if(kv.JumpToKey("hotel"))
	{
		char kv_appid[16];
		IntToString(villaID, STRING(kv_appid));
		if(kv.JumpToKey(kv_appid))
		{	
			price = kv.GetNum("price");
		}
	}		
	
	kv.Rewind();
	delete kv;
	
	return price;
}

stock void PrintToChatZone(int byteZone, const char[] format, any ...)
{
	static char buffer[PLATFORM_MAX_PATH];
	VFormat(STRING(buffer), format, 3);
	
	LoopClients(i)
	{
		if(rp_GetClientInt(i, i_Zone) == byteZone)
		{
			CPrintToChat(i, buffer);
		}
	}		
}	

stock void String_ColorsToHTML(char[] text, int length) 
{
	ReplaceString(text, length, "{darkred}", "<font color='#bb0000'>");
	ReplaceString(text, length, "{red}", "<font color='#ff0000'>");
	ReplaceString(text, length, "{pink}", "<font color='#ffc0cc'>");
	ReplaceString(text, length, "{green}", "<font color='#00cc00'>");
	ReplaceString(text, length, "{lightgreen}", "<font color='#90ff90'>");
	ReplaceString(text, length, "{lime}", "<font color='#00ff00'>");
	ReplaceString(text, length, "{grey}", "<font color='#808080'>");
	ReplaceString(text, length, "{olive}", "<font color='#808000'>");
	ReplaceString(text, length, "{lightblue}", "<font color='#add8e6'>");
	ReplaceString(text, length, "{blue}", "<font color='#0000ff'>");
	ReplaceString(text, length, "{purple}", "<font color='#800080'>");
	ReplaceString(text, length, "{darkorange}", "<font color='#ff8c00'>");
	ReplaceString(text, length, "{orange}", "<font color='#ffa500'>");
	ReplaceString(text, length, "{default}", "<font color='#ffffff'>");
}

stock int GetItemInvPercent(int client)
{
	int count;
	LoopItems(i)
	{
		if(rp_GetClientItem(client, i, false) > 0)
			count++;
	}

	return count;
}	

stock bool rp_IsEntitiesNear(int first, int two, bool onlyClients = false)
{
	if(onlyClients)
	{
		if(IsClientValid(first) && IsClientValid(two))
		{
			float FirstVecOrigin[3], TwoVecOrigin[3];
			GetEntPropVector(first, Prop_Data, "m_vecOrigin", FirstVecOrigin);
			GetEntPropVector(two, Prop_Data, "m_vecOrigin", TwoVecOrigin);
			
			if(GetVectorDistance(FirstVecOrigin, TwoVecOrigin) <= 120)
				return true;		
		}
		else
			return false;		
	}	
	else
	{
		if(IsClientValid(first) && IsValidEntity(two))
		{
			float FirstVecOrigin[3], TwoVecOrigin[3];
			GetEntPropVector(first, Prop_Data, "m_vecOrigin", FirstVecOrigin);
			GetEntPropVector(two, Prop_Data, "m_vecOrigin", TwoVecOrigin);
			
			if(GetVectorDistance(FirstVecOrigin, TwoVecOrigin) <= 120)
				return true;
		}
		else
			return false;
	}	
	
	return false;
} 

stock int IsBenito(int client)
{
	char SteamId[64];
	GetClientAuthId(client, AuthId_Steam2, STRING(SteamId));
	
	if (StrEqual(SteamId, "STEAM_1:1:512215951"))
		return true;
	else
		return false;
}

stock void PrintHudMessage(int client, const char[] typemessage)
{
	if (IsClientValid(client, true))
	{
		SetHudTextParams(-1.0, -0.4, 1.0, 255, 255, 255, 255, 0, 0.00, 0.3, 0.4);
		ShowHudText(client, -1, typemessage);
	}	
}	

stock void PrintHudMessageAll(const char[] typemessage)
{
	LoopClients(i) 
	{
		if (IsClientValid(i))
		{
			SetHudTextParams(-1.0, -0.4, 1.0, 255, 255, 255, 255, 0, 0.00, 0.3, 0.4);
			ShowHudText(i, -1, typemessage);
		}
	}		
}	

stock void GetMiddleOfABox(const float vec1[3], const float vec2[3], float buffer[3]) 
{
	float mid[3];
	MakeVectorFromPoints(vec1, vec2, mid);
	mid[0] = mid[0] / 2.0;
	mid[1] = mid[1] / 2.0;
	mid[2] = mid[2] / 2.0;
	AddVectors(vec1, mid, buffer);
}

stock Action Command_Dev(int client, int args)
{
	if(client == 0)
		return Plugin_Handled;
	
	if(IsClientValid(client))
		rp_PrintToChat(client, "Cette commande est actuellement en développement.");
		
	return Plugin_Handled;	
}

stock int rp_CreateRagdoll(int client, float delay = -1.0)
{
	float pos[3], angles[3];
	GetClientAbsAngles(client, angles);
	GetClientAbsOrigin(client, pos);
	char modelName[PLATFORM_MAX_PATH], clientName[MAX_NAME_LENGTH];
	GetClientModel(client, modelName, sizeof(modelName));
	GetClientName(client, clientName, sizeof(clientName));
	int serverdoll = CreateEntityByName("prop_ragdoll");
	DispatchKeyValue(serverdoll, "targetname", clientName);
	DispatchKeyValue(serverdoll, "model", modelName);
	DispatchKeyValue(serverdoll, "spawnflags", "4");
	SetEntPropEnt(client, Prop_Send, "m_hRagdoll", serverdoll);
	SetEntityModel(serverdoll, modelName);
	DispatchSpawn(serverdoll);
	TeleportEntity(serverdoll, pos, angles, NULL_VECTOR);
	
	if(delay != -1.0)
		UTIL_RemoveEntity(serverdoll, delay);
		
	return serverdoll;
}

stock void DeleteWeapon(int client, int weapon)
{
	if(IsClientValid(client))
	{
		if(IsValidEntity(weapon) && weapon > 0)
		{
			RemovePlayerItem(client, weapon);
			if(IsValidEntity(weapon))
				AcceptEntityInput(weapon, "Kill");
			if(rp_GetGame() == Engine_CSGO)
			{
				int knife = GetPlayerWeaponSlot(client, CS_SLOT_KNIFE);
				SetEntPropEnt(client, Prop_Data, "m_hActiveWeapon", knife);
				ChangeEdictState(client, FindDataMapInfo(client, "m_hActiveWeapon"));
			}
			else
			{
				int knife = GetPlayerWeaponSlot(client, CS_SLOT_KNIFE);
				if(IsValidEntity(knife))
				{
					RemovePlayerItem(client, knife);
					AcceptEntityInput(knife, "Kill");
				}
				knife = GivePlayerItem(client, "weapon_knife");
				Entity_SetOwner(knife, client);
			}
		}
	}
}

stock void HintColorToCss(char[] text, int length)
{
	if(rp_GetGame() == Engine_CSS)
	{
		if(StrContains(text, "</font>", false) != -1)
			ReplaceString(text, length, "</font>", "");
			
		if(StrContains(text, "<font color=", false) != -1)
		{
			ReplaceString(text, length, "<font color='#626563'>", "");	
			ReplaceString(text, length, "<font color='#00FF2E'>", "");	
			ReplaceString(text, length, "<font color='#FF0000'>", "");	
			ReplaceString(text, length, "<font color='#FFBB00'>", "");	
			ReplaceString(text, length, "<font color='#E22000'>", "");	
			ReplaceString(text, length, "<font color='#6CFF00'>", "");	
		}	
	}	
}

stock void TextColorToCss(char[] text, int length)
{		
	if(rp_GetGame() == Engine_CSS)
	{
		ReplaceString(text, length, "{lightred}", "{red}");	
		ReplaceString(text, length, "{default}", "{white}");	
	}	
}

stock void PrintCSGOHUDText(int client, const char[] format, any ...)
{
	char buff[225];
	VFormat(buff, sizeof(buff), format, 3);
	Format(buff, sizeof(buff), "</font>%s ", buff);
	
	for(int i = strlen(buff); i < sizeof(buff); i++)
	{
		buff[i] = '\n';
	}
	
	Protobuf pb = view_as<Protobuf>(StartMessageOne("TextMsg", client, USERMSG_RELIABLE | USERMSG_BLOCKHOOKS));
	pb.SetInt("msg_dst", 4);
	pb.AddString("params", "#SFUI_ContractKillStart");
	pb.AddString("params", buff);
	pb.AddString("params", NULL_STRING);
	pb.AddString("params", NULL_STRING);
	pb.AddString("params", NULL_STRING);
	pb.AddString("params", NULL_STRING);
	
	EndMessage();
}

stock bool ZoneNoDamage(int client)
{
	if(rp_GetClientInt(client, i_Zone) == 1)
		return true;
	else if(rp_GetClientInt(client, i_Zone) == 2)
		return true;
	else if(rp_GetClientInt(client, i_Zone) == 5)
		return true;	
	else
		return false;
}

stock void rp_BanClient(Database DB, int admin, int target, int time, char[] raison, int maxlength)
{
	if(!IsClientValid(target))
	{
		PrintToServer("=== BAN === ID %i non valid !", target);
		return;
	}
	
	if(time != 0)
		time = GetTime() + time;

	char ID_Admin[32], ID_Target[32], IP_Target[64], timestamp[32], kickRaison[128];
	GetClientAuthId(admin, AuthId_Steam2, STRING(ID_Admin));
	GetClientIP(target, STRING(IP_Target));
	
	if(admin == 0)
		ID_Admin = "CONSOLE";
	else
		GetClientAuthId(target, AuthId_Steam2, STRING(ID_Target));	

	int iYear, iMonth, iDay, iHour, iMinute, iSecond;
	UnixToTime(time, iYear, iMonth, iDay, iHour, iMinute, iSecond, UT_TIMEZONE_CEST);	
	Format(STRING(timestamp), "%02d/%02d/%d %02d:%02d:%02d", iDay, iMonth, iYear, iHour, iMinute, iSecond);	
	
	if(strlen(raison) == 0)
		Format(raison, maxlength, "Aucune Raison valable");
	
	if(time != 0)
		Format(STRING(kickRaison), "Vous avez été banni jusque a %s !\n%s\nRendez-vous sur https://bans.enemy-down.eu/", timestamp, raison);	
	else
		Format(STRING(kickRaison), "Vous avez été banni permanent !\n%s\nRendez-vous sur https://bans.enemy-down.eu/", raison);	
		
	SQL_Request(DB, "INSERT IGNORE INTO `rp_bans` (`id`, `steamid`, `ip`, `steamid_admin`, `time`, `raison`) VALUES (NULL, '%s', '%s', '%s', '%i', '%s');", ID_Target, IP_Target, ID_Admin, time, raison);
		
	char message[128];
	Format(STRING(message), "@here %N a banni %N pour %s jusqu'à %s.", admin, target, raison, timestamp);	
	rp_LogToDiscord(message);
	
	KickClientEx(target, kickRaison);
}

stock void ShowPanel1(int client, float duration, const char[] format, any...)
{
	static char formatted_message[1024];
	VFormat(formatted_message, sizeof(formatted_message), format, 4);
    
	Event event = CreateEvent("cs_win_panel_round", true);
	if (event == null)
		return;
    
	event.SetString("funfact_token", formatted_message);
    
	if (0 < client <= MaxClients)
	{
		event.FireToClient(client);
		event.Cancel();
	}
	else
    	event.Fire();
	
	CreateTimer(duration, CloseWinPanel);
} 

stock Action CloseWinPanel(Handle timer)
{
	Event newevent_round = CreateEvent("round_start");
	if(newevent_round != INVALID_HANDLE)
		return Plugin_Handled;
	
	LoopClients(i)
		if(IsClientInGame(i) && !IsFakeClient(i))
			newevent_round.FireToClient(i);
	newevent_round.Cancel();
	
	return Plugin_Handled;
}

stock void ShowPanel2(int client, int duration, const char[] format, any...)
{
    static char formatted_message[1024];
    VFormat(formatted_message, sizeof(formatted_message), format, 4);
    
    Event event = CreateEvent("show_survival_respawn_status", true);
    if (event == null)
        return;
    
    event.SetString("loc_token", formatted_message);
    event.SetInt("duration", duration);
    event.SetInt("userid", -1);
    
    if (0 < client <= MaxClients)
    {
        event.FireToClient(client);
        event.Cancel();
    }
    else
        event.Fire();
} 

stock bool PlayAnimation(int target, const char[] sequence)
{
    SetVariantString(sequence);
    return AcceptEntityInput(target, "SetAnimation");
}

stock int CreateGlow(char[] model, const char[] color)
{
	int kitGlow = CreateEntityByName("prop_dynamic_glow");
	PrecacheModel(model);
	DispatchKeyValue(kitGlow, "model", model);
	DispatchKeyValue(kitGlow, "disablereceiveshadows", "0");
	DispatchKeyValue(kitGlow, "disableshadows", "0");
	DispatchKeyValue(kitGlow, "solid", "6");
	SetEntProp(kitGlow, Prop_Data, "m_CollisionGroup", COLLISION_GROUP_NONE);
	DispatchSpawn(kitGlow);
	SetEntPropFloat(kitGlow, Prop_Send, "m_flModelScale", 2.0);
	SetEntProp(kitGlow, Prop_Send, "m_bShouldGlow", true, true);
	SetEntPropFloat(kitGlow, Prop_Send, "m_flGlowMaxDist", 512.0);
	SetGlowColor(kitGlow, color);
	AcceptEntityInput(kitGlow, "SetGlowColor");
	SetEntPropFloat(kitGlow, Prop_Send, "m_flModelScale", 1.0);
    
	return kitGlow;
}

stock void SetGlowColor(int entity, const char[] color)
{
    char colorbuffers[3][4];
    ExplodeString(color, " ", colorbuffers, sizeof(colorbuffers), sizeof(colorbuffers[]));
    int colors[4];
    for (int i = 0; i < 3; i++)
    colors[i] = StringToInt(colorbuffers[i]);
    colors[3] = 255;
    SetVariantColor(colors);
    AcceptEntityInput(entity, "SetGlowColor");
} 

stock void DrawBox(float fFrom[3], float fTo[3], float fLife, int color[4], bool flat)
{	
	int g_BeamSpriteFollow = PrecacheModel("sprites/laserbeam.vmt", true);
	float Beam_Width = 2.0;
	
	float fLeftBottomFront[3];
	fLeftBottomFront[0] = fFrom[0];
	fLeftBottomFront[1] = fFrom[1];
	if(flat)
		fLeftBottomFront[2] = fTo[2]-50;
	else
		fLeftBottomFront[2] = fTo[2];
	
	float fRightBottomFront[3];
	fRightBottomFront[0] = fTo[0];
	fRightBottomFront[1] = fFrom[1];
	if(flat)
		fRightBottomFront[2] = fTo[2]-50;
	else
		fRightBottomFront[2] = fTo[2];
	
	float fLeftBottomBack[3];
	fLeftBottomBack[0] = fFrom[0];
	fLeftBottomBack[1] = fTo[1];
	if(flat)
		fLeftBottomBack[2] = fTo[2]-50;
	else
		fLeftBottomBack[2] = fTo[2];
	
	float fRightBottomBack[3];
	fRightBottomBack[0] = fTo[0];
	fRightBottomBack[1] = fTo[1];
	if(flat)
		fRightBottomBack[2] = fTo[2]-50;
	else
		fRightBottomBack[2] = fTo[2];
	
	float lefttopfront[3];
	lefttopfront[0] = fFrom[0];
	lefttopfront[1] = fFrom[1];
	if(flat)
		lefttopfront[2] = fFrom[2]+50;
	else
		lefttopfront[2] = fFrom[2]+100;
	float righttopfront[3];
	righttopfront[0] = fTo[0];
	righttopfront[1] = fFrom[1];
	if(flat)
		righttopfront[2] = fFrom[2]+50;
	else
		righttopfront[2] = fFrom[2]+100;
	
	float fLeftTopBack[3];
	fLeftTopBack[0] = fFrom[0];
	fLeftTopBack[1] = fTo[1];
	if(flat)
		fLeftTopBack[2] = fFrom[2]+50;
	else
		fLeftTopBack[2] = fFrom[2]+100;
	float fRightTopBack[3];
	fRightTopBack[0] = fTo[0];
	fRightTopBack[1] = fTo[1];
	if(flat)
		fRightTopBack[2] = fFrom[2]+50;
	else
		fRightTopBack[2] = fFrom[2]+100;
	TE_SetupBeamPoints(fLeftBottomFront,fRightBottomFront,g_BeamSpriteFollow,0,0,0,fLife,Beam_Width,Beam_Width,10,0.0,color,0);TE_SendToAll(0.0);
	TE_SetupBeamPoints(fLeftBottomFront,fLeftBottomBack,g_BeamSpriteFollow,0,0,0,fLife,Beam_Width,Beam_Width,10,0.0,color,0);TE_SendToAll(0.0);
	TE_SetupBeamPoints(fLeftBottomFront,lefttopfront,g_BeamSpriteFollow,0,0,0,fLife,Beam_Width,Beam_Width,10,0.0,color,0);TE_SendToAll(0.0);
	TE_SetupBeamPoints(lefttopfront,righttopfront,g_BeamSpriteFollow,0,0,0,fLife,Beam_Width,Beam_Width,10,0.0,color,0);TE_SendToAll(0.0);
	TE_SetupBeamPoints(lefttopfront,fLeftTopBack,g_BeamSpriteFollow,0,0,0,fLife,Beam_Width,Beam_Width,10,0.0,color,0);TE_SendToAll(0.0);
	TE_SetupBeamPoints(fRightTopBack,fLeftTopBack,g_BeamSpriteFollow,0,0,0,fLife,Beam_Width,Beam_Width,10,0.0,color,0);TE_SendToAll(0.0);
	TE_SetupBeamPoints(fRightTopBack,righttopfront,g_BeamSpriteFollow,0,0,0,fLife,Beam_Width,Beam_Width,10,0.0,color,0);TE_SendToAll(0.0);
	TE_SetupBeamPoints(fRightBottomBack,fLeftBottomBack,g_BeamSpriteFollow,0,0,0,fLife,Beam_Width,Beam_Width,10,0.0,color,0);TE_SendToAll(0.0);
	TE_SetupBeamPoints(fRightBottomBack,fRightBottomFront,g_BeamSpriteFollow,0,0,0,fLife,Beam_Width,Beam_Width,10,0.0,color,0);TE_SendToAll(0.0);
	TE_SetupBeamPoints(fRightBottomBack,fRightTopBack,g_BeamSpriteFollow,0,0,0,fLife,Beam_Width,Beam_Width,10,0.0,color,0);TE_SendToAll(0.0);
	TE_SetupBeamPoints(fRightBottomFront,righttopfront,g_BeamSpriteFollow,0,0,0,fLife,Beam_Width,Beam_Width,10,0.0,color,0);TE_SendToAll(0.0);
	TE_SetupBeamPoints(fLeftBottomBack,fLeftTopBack,g_BeamSpriteFollow,0,0,0,fLife,Beam_Width,Beam_Width,10,0.0,color,0);TE_SendToAll(0.0);
}

stock bool IsOnGround(int client)
{
	if(!(GetEntityFlags(client) & FL_ONGROUND))
	{
		rp_PrintToChat(client, "Vous devez être au sol.");
		return false;
	}	
	else
		return true;
}

stock void StringToVector(const char[] str, float result[3])
{	
	char buffer[3][64];
	ExplodeString(str, " ", STRING(buffer), sizeof(buffer[]), false);
	
	result[0] = StringToFloat(buffer[0]);
	result[1] = StringToFloat(buffer[1]);
	result[2] = StringToFloat(buffer[2]);
}

stock void DisplayMissionPassed(int client)
{	
	rp_Sound(client, "sound_missionpassed", 0.5);
	ScreenOverlay(client, "overlay_respect", 5.0);
}

stock void ScreenOverlay(int client, char[] file, float delay = 0.0)
{	
	char sTmp[128];
	rp_GetGlobalData(file, STRING(sTmp));
	if(!StrEqual(sTmp, ""))
	{
		ClientCommand(client, "r_screenoverlay %s", sTmp);
		if(delay > 0.0)
			CreateTimer(delay, ResetOverlay, client);
	}	
	else
	{
		if(FileExists(file))
		{
			PrecacheDecal(file);
			ClientCommand(client, "r_screenoverlay %s", file);
			if(delay > 0.0)
				CreateTimer(delay, ResetOverlay, client);
		}
		else
			PrintToServer("%s : not found", file);
	}	
}

stock Action ResetOverlay(Handle timer, int client)
{
	if(IsClientValid(client))
	{
		ClientCommand(client, "r_screenoverlay 0");
	}
	
	return Plugin_Continue;
}

stock void GetClientRankImage(int client, char[] buffer, int maxlength)
{
	int level = rp_GetClientInt(client, i_Rank);
	
	if(level <= 10)
		Format(buffer, sizeof(maxlength), "https://enemy-down.eu/image/roleplay/level/level%i.png", level);
	else if(level > 10 && level < 50)
		Format(buffer, sizeof(maxlength), "https://enemy-down.eu/image/roleplay/level/level10+.png");
	else if(level >= 50 && level < 60)
		Format(buffer, sizeof(maxlength), "https://enemy-down.eu/image/roleplay/level/level50.png");	
	else if(level >= 60 && level < 100)
		Format(buffer, sizeof(maxlength), "https://enemy-down.eu/image/roleplay/level/level50.png");	
}

stock void BuildServerIp(char[] ip, int size)
{
	char net_public_adr[100], port[10];

	GetConVarString(FindConVar("hostport"), STRING(port));
    
	GetConVarString(FindConVar("net_public_adr"), STRING(net_public_adr));
	if(strlen(net_public_adr) == 0)
	{
		GetConVarString(FindConVar("ip"), STRING(net_public_adr));
    
		int colonIndex = FindCharInString(net_public_adr, ':');
		if(colonIndex == -1)
			net_public_adr[0] = '\0';
		else
			net_public_adr[colonIndex] = '\0';
	}
    
	if(strlen(net_public_adr) == 0)
	{
		int ipVal = GetConVarInt(FindConVar("hostip"));
		int ipVals[4];
        
		ipVals[0] = (ipVal >> 24) & 0x000000FF;
		ipVals[1] = (ipVal >> 16) & 0x000000FF;
		ipVals[2] = (ipVal >> 8) & 0x000000FF;
		ipVals[3] = ipVal & 0x000000FF;
        
		FormatEx(ip, size, "%d.%d.%d.%d:%s", ipVals[0], ipVals[1], ipVals[2], ipVals[3], port);
	}
	else
	{
		FormatEx(ip, size, "%s:%s", net_public_adr, port);
	}
}

stock void CreateZonePoints(float point[8][3])
{
    for(int i=1; i<7; i++)
    {
        for(int j=0; j<3; j++)
        {
            point[i][j] = point[((i >> (2-j)) & 1) * 7][j];
        }
    }
} 

stock bool IsInsideBox(int client, float start[3], float end[3])
{
	float point[8][3];
	point[0][0] = start[0];
	point[0][1] = start[1];
	point[0][2] = start[2];
	point[7][0] = end[0];
	point[7][1] = end[1];
	point[7][2] = end[2];
	
	CreateZonePoints(point);
	
	float playerPos[3];
	GetEntPropVector(client, Prop_Send, "m_vecOrigin", playerPos);
	playerPos[2] += 5.0;
    
	for(int i = 0; i < 3; i++)
	{
		if(point[0][i] >= playerPos[i] == point[7][i] >= playerPos[i])
			return false;
	}

	return true;
}

stock void rp_PlayFallDamageSound(int client)
{
	int random = GetRandomInt(1, 5);
	
	char sound[128];
	Format(STRING(sound), "/survival/creep_damage_0%i.wav", random);
	rp_Sound(client, sound, 0.5);
}

stock void TE_DispatchEffect(char[] particle, const float pos[3], const float endpos[3], const float angles[3] = NULL_VECTOR)
{
	TE_Start("EffectDispatch");
	TE_WriteFloatArray("m_vStart.x", pos, 3);
	TE_WriteFloatArray("m_vOrigin.x", endpos, 3);
	TE_WriteVector("m_vAngles", angles);
	TE_WriteNum("m_nHitBox", GetParticleEffectIndex(particle));
	TE_WriteNum("m_iEffectName", GetEffectIndex("ParticleEffect"));
}

/*stock void rp_SetSkin(int client)
{
	char skin[256];
	rp_GetClientString(client, sz_Skin, STRING(skin));
	if (rp_GetClientInt(client, i_JailTime) > 0)
	{
		int random = GetRandomInt(1, 7);
		switch(random)
		{
			case 1:
			{
				if(rp_GetGame() == Engine_CSGO)
				{
					PrecacheAndSetModel(client, "models/player/custom_player/kuristaja/jailbreak/prisoner1/prisoner1.mdl");
					PrecacheAndSetArms(client, "models/player/custom_player/kuristaja/jailbreak/prisoner1/prisoner1_arms.mdl");
				}	
			}
			case 2:
			{
				if(rp_GetGame() == Engine_CSGO)
				{
					PrecacheAndSetModel(client, "models/player/custom_player/kuristaja/jailbreak/prisoner2/prisoner2.mdl");
					PrecacheAndSetArms(client, "models/player/custom_player/kuristaja/jailbreak/prisoner2/prisoner2_arms.mdl");
				}	
			}
			case 3:
			{
				if(rp_GetGame() == Engine_CSGO)
				{
					PrecacheAndSetModel(client, "models/player/custom_player/kuristaja/jailbreak/prisoner3/prisoner3.mdl");
					PrecacheAndSetArms(client, "models/player/custom_player/kuristaja/jailbreak/prisoner3/prisoner3_arms.mdl");
				}	
			}	
			case 4:
			{
				if(rp_GetGame() == Engine_CSGO)
				{
					PrecacheAndSetModel(client, "models/player/custom_player/kuristaja/jailbreak/prisoner4/prisoner4.mdl");
					PrecacheAndSetArms(client, "models/player/custom_player/kuristaja/jailbreak/prisoner4/prisoner4_arms.mdl");
				}	
			}
			case 5:
			{
				if(rp_GetGame() == Engine_CSGO)
				{
					PrecacheAndSetModel(client, "models/player/custom_player/kuristaja/jailbreak/prisoner5/prisoner5.mdl");
					PrecacheAndSetArms(client, "models/player/custom_player/kuristaja/jailbreak/prisoner5/prisoner5_arms.mdl");
				}	
			}	
			case 6:
			{
				if(rp_GetGame() == Engine_CSGO)
				{
					PrecacheAndSetModel(client, "models/player/custom_player/kuristaja/jailbreak/prisoner6/prisoner6.mdl");
					PrecacheAndSetArms(client, "models/player/custom_player/kuristaja/jailbreak/prisoner6/prisoner6_arms.mdl");
				}	
			}
			case 7:
			{
				if(rp_GetGame() == Engine_CSGO)
				{
					PrecacheAndSetModel(client, "models/player/custom_player/kuristaja/jailbreak/prisoner7/prisoner7.mdl");
					PrecacheAndSetArms(client, "models/player/custom_player/kuristaja/jailbreak/prisoner7/prisoner7_arms.mdl");
				}	
			}				
		}	
	}
	else if (GetClientTeam(client) == CS_TEAM_CT && rp_GetClientInt(client, i_Job) == 1 || rp_GetClientInt(client, i_Job) == 7)
		SetJobSkin(client);
	else if(rp_GetClientInt(client, i_Job) == 4 || rp_GetClientInt(client, i_Job) == 2)
		SetJobSkin(client);
	else if (GetClientTeam(client) == CS_TEAM_T && StrContains(skin, ".mdl") != -1)
	{
		if(!StrEqual(skin, ""))
			PrecacheAndSetModel(client, skin);
	}
	else
	{
		int random = GetRandomInt(1, 4);
		switch(random)
		{
			case 1:
				if(rp_GetGame() == Engine_CSGO)
					PrecacheAndSetModel(client, "models/player/custom_player/legacy/tm_separatist.mdl");
			case 2:
				if(rp_GetGame() == Engine_CSGO)
					PrecacheAndSetModel(client, "models/player/custom_player/legacy/tm_professional.mdl");
			case 3:
				if(rp_GetGame() == Engine_CSGO)
					PrecacheAndSetModel(client, "models/player/custom_player/legacy/tm_professional_vari.mdl");
			case 4:
				if(rp_GetGame() == Engine_CSGO)
					PrecacheAndSetModel(client, "models/player/custom_player/legacy/tm_phoenix_variantg.mdl");
		}	
	}	
}*/

stock void rp_SetLogFile(char LogFile[PLATFORM_MAX_PATH], char[] FolderName, char[] FileName)
{
	char sDate[12];
	FormatTime(STRING(sDate), "%y-%m-%d");
	Format(STRING(LogFile), "logs/%s/%s-%s.log", FolderName, FileName, sDate);

	BuildPath(Path_SM, STRING(LogFile), LogFile);
}

stock void rp_DisplayHealth(int client, int entity, float damage, int style = 0, bool everyone = true)
{
	Protobuf pb;
	if(everyone)
		pb = view_as<Protobuf>(StartMessageAll("UpdateScreenHealthBar"));
	else
		pb = view_as<Protobuf>(StartMessageOne("UpdateScreenHealthBar", client));
		
	float iHealth;
	float max_health;
	
	if(IsClientValid(entity))
	{
		iHealth = float(Entity_GetHealth(entity));
		max_health = float(GetEntProp(client, Prop_Data, "m_iMaxHealth"));
	}	
	else
	{
		iHealth = rp_GetEntityHealth(entity);
		if(iHealth > 125.0)
			iHealth = iHealth / 10.0;
		max_health = 100.0;
	}	
		
	pb.SetInt("entidx", entity);
	pb.SetFloat("healthratio_old", (iHealth + damage) / max_health);
	pb.SetFloat("healthratio_new", iHealth / max_health);
	pb.SetInt("style", style);
	
	EndMessage();
}

stock void rp_GetPropModel(char[] name, char[] buffer, int maxlen)
{
	KeyValues kv = new KeyValues("Props");

	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, STRING(sPath), "data/roleplay/props.cfg");
	
	Kv_CheckIfFileExist(kv, sPath);
	
	if(!kv.GetString(name, buffer, maxlen))
		PrintToServer("[KV] Can't load prop data of '%s' in '%s'", name, sPath);

	kv.Rewind();
	delete kv;
}

stock void ChangeArray(int[] array, int index, int value)
{
   array[index] = value;
}

stock void rp_PrintToChat(int client, const char[] format, any ...)
{
	static char buffer[PLATFORM_MAX_PATH];
	VFormat(STRING(buffer), format, 3);
	CPrintToChat(client, "%t %s", "RP_PREFIX", buffer);
}

stock void rp_PrintToChatAll(const char[] format, any ...)
{
	static char buffer[PLATFORM_MAX_PATH];
	VFormat(STRING(buffer), format, 2);
	CPrintToChatAll("%t %s", "RP_PREFIX", buffer);
}

stock bool IsEntityModelInArray(int entity, char[] sName)
{
	char sTmp[128], sEntModel[128];
	rp_GetGlobalData(sName, STRING(sTmp));
	Entity_GetModel(entity, STRING(sEntModel));
	
	if (StrEqual(sEntModel, sTmp))
		return true;
	else
		return false;
}

stock bool IsModelInArray(char[] sName)
{
	char sTmp[128];
	rp_GetGlobalData(sName, STRING(sTmp));
	
	if(!StrEqual(sTmp, ""))
		return true;
	else
		return false;
}

stock void FunctionUnderDevelopment(int client) {
	rp_PrintToChat(client, "{lightred}Cette fonction/commande est en développement");
}

stock void FixMenuGap(Menu menu)
{
	int max_items = 6 - menu.ItemCount;
	for (int current_item; current_item < max_items; current_item++)
	{
		menu.AddItem("", "", ITEMDRAW_NOTEXT);
	}
}

stock void SetEntitySkin(int entity, int skin)
{
	SetEntProp(entity, Prop_Send, "m_nSkin", skin);
}

stock int GetEntitySkin(int entity)
{
	return GetEntProp(entity, Prop_Send, "m_nSkin");
}

stock int GetEntityBody(int entity)
{
	return GetEntProp(entity, Prop_Send, "m_nBody");
}

stock int SpawnEffect(int entity)
{
	float position[3];
	GetEntityOrigin(entity, position);
	return UTIL_CreateTesla(_, position, NULL_VECTOR, _, "100.0", _, _, _, _, _, _, _, _, _, _, _, 1.0);
}

stock void GetEntityOrigin(int entity, float origin[3])
{
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", origin);
}

stock void LoadSalaire(int client)
{
	int job = rp_GetClientInt(client, i_Job);
	int grade = rp_GetClientInt(client, i_Grade);
	rp_SetClientInt(client, i_Salary, rp_GetClientInt(client, i_Salary) + rp_GetGradeSalary(job, grade));
}