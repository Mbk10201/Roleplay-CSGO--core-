/**
 * @brief Get a INTEGER property value on a player.
 * 
 * @param client        	The player.
 * @param prop        		The INTEGER property (see enumeration.inc).
 *
 * @return 					int value;
 **/
native int rp_GetClientInt(int client, int_list prop);

/**
 * @brief Get a BOOLEAN property value on a player.
 * 
 * @param client        	The player.
 * @param prop        		The BOOLEAN property (see enumeration.inc).
 *
 * @return 					true/false;
 **/
native bool rp_GetClientBool(int client, bool_list prop);

/**
 * @brief Get a FLOATING property value on a player.
 * 
 * @param client        	The player.
 * @param prop        		The FLOATING property (see enumeration.inc).
 *
 * @return 					float value;
 **/
native float rp_GetClientFloat(int client, float_list prop);

/**
 * @brief Get a CHAR property value on a player.
 * 
 * @param client        	The player.
 * @param prop        		The CHAR property (see enumeration.inc).
 * @param value        		The char variable where the data will be stocked.
 * @param length        	The char variable length.
 *
 * @return 					-1;
 **/
native void rp_GetClientString(int client, string_list prop, char[] value, int length);

/**
 * @brief Retrieve the weapon ammo type.
 * 
 * @param wepID        	The weapon index.
 *
 * @return 					type id;
 **/
native ammo_type rp_GetWeaponAmmoType(int wepID);

/**
 * @brief Retrieve the weapon ammo amount.
 * 
 * @param wepID        	The weapon index.
 *
 * @return 					amount;
 **/
native int rp_GetWeaponAmmoAmount(int wepID);

/**
 * @brief Retrieve the knife type.
 * 
 * @param wepID        	The weapon index.
 *
 * @return 					type;
 **/
native knife_type rp_GetKnifeType(int wepID);

/**
 * @brief Check if player has the gived Sick.
 * 
 * @param client        	The client index.
 * @param prop        		The sick type (see enumeration.inc).
 *
 * @return 					true/false;
 **/
native bool rp_GetClientSick(int client, sick_list prop);

/**
 * @brief Check if player has the gived Surgery.
 * 
 * @param client        	The client index.
 * @param prop        		The surgery type (see enumeration.inc).
 *
 * @return 					true/false;
 **/
native bool rp_GetClientSurgery(int client, surgery_list prop);

/**
 * @brief Retrieve a rankid property.
 * 
 * @param client        	The rankID.
 * @param prop        		The rank property (see enumeration.inc).
 * @param value        		The char variable where the data will be stocked.
 * @param length        	The char variable length.
 *
 * @return 					-1;
 **/
native void rp_GetRank(int rankid, rank_list prop, char[] value, int length);

/**
 * @brief Set a INT property value on a player.
 * 
 * @param client        	The player.
 * @param prop        		The INT property (see enumeration.inc).
 * @param value        		The integer value to set.
 *
 * @return 					N/A;
 **/
native void rp_SetClientInt(int client, int_list prop, int value);

/**
 * @brief Set a BOOLEAN property value on a player.
 * 
 * @param client        	The player.
 * @param prop        		The BOOLEAN property (see enumeration.inc).
 * @param value        		The boolean value to set.
 *
 * @return 					N/A;
 **/
native void rp_SetClientBool(int client, bool_list prop, bool value);


/**
 * @brief Set a FLOATING property value on a player.
 * 
 * @param client        	The player.
 * @param prop        		The FLOATING property (see enumeration.inc).
 * @param value        		The floating value to set.
 *
 * @return 					N/A;
 **/
native void rp_SetClientFloat(int client, float_list prop, float value);

/**
 * @brief Set a CHAR property value on a player.
 * 
 * @param client        	The player.
 * @param prop        		The CHAR property (see enumeration.inc).
 * @param value        		The value to set.
 * @param value        		The length of the value.
 *
 * @return 					N/A;
 **/
native char rp_SetClientString(int client, string_list prop, char[] value, int length);

/**
 * @brief Set a AMMO_TYPE property value on a player.
 * 
 * @param wepID        		The weapon Index.
 * @param typeID        	The AMMO_TYPE property (see enumeration.inc).
 *
 * @return 					N/A;
 **/
native void rp_SetWeaponAmmoType(int wepID, ammo_type typeID);

/**
 * @brief Set weapons ammo.
 * 
 * @param wepID        		The weapon Index.
 * @param amount        	The amount of ammo to set.
 *
 * @return 					N/A;
 **/
native void rp_SetWeaponAmmoAmount(int wepID, int amount);

/**
 * @brief Set a KNIFE_TYPE property value on a player.
 * 
 * @param wepID        		The weapon Index.
 * @param typeID        	The KNIFE_TYPE property (see enumeration.inc).
 *
 * @return 					N/A;
 **/
native void rp_SetKnifeType(int wepID, knife_type typeID);

/**
 * @brief Set a SICK_LIST property value on a player.
 * 
 * @param client        	The client.
 * @param prop        		The SICK_LIST property (see enumeration.inc).
 * @param value        		The true or false to set the sick.
 *
 * @return 					N/A;
 **/
native void rp_SetClientSick(int client, sick_list prop, bool value);

/**
 * @brief Set a SURGERY_LIST property value on a player.
 * 
 * @param client        	The client.
 * @param prop        		The SURGERY_LIST property (see enumeration.inc).
 * @param value        		The true or false to set the surgery.
 *
 * @return 					N/A;
 **/
native void rp_SetClientSurgery(int client, surgery_list prop, bool value);

/**
 * @brief Set a SURGERY_LIST property value on a player.
 * 
 * @param wepID        		The rankID.
 * @param prop        		The RANK_LIST property (see enumeration.inc).
 * @param value        		The value to set.
 * @param value        		The length of the value.
 *
 * @return 					N/A;
 **/
native void rp_SetRank(int rankid, rank_list prop, char[] value, int length);

/**
 * @brief Get client admin type.
 * 
 * @param client        	The client.
 *
 * @return 					admin_type;
 **/
native admin_type rp_GetAdmin(int client);

/**
 * @brief Set client admin type.
 * 
 * @param client        	The client.
 * @param type        		The admin_type to set.
 *
 * @return 					N/A;
 **/
native void rp_SetAdmin(int client, admin_type type);

/**
 * @brief Retrieve a TIME_LIST property value.
 * 
 * @param prop        		The TIME_LIST property.
 *
 * @return 					int;
 **/
native int rp_GetTime(time_list prop);

/**
 * @brief Retrieve a TIME_LIST property value.
 * 
 * @param prop        		The TIME_LIST property.
 *
 * @return 					N/A;
 **/
native void rp_SetTime(time_list prop, int value);

/**
 * @brief Get actual wanted job.
 * 
 *
 * @return 					jobid or -1;
 **/
native int rp_GetJobSearch();

/**
 * @brief Set the actual job to wanted status.
 * 
 * @param job        		The TIME_LIST property.
 *
 * @return 					N/A;
 **/
native void rp_SetJobSearch(int job);

/**
 * @brief Send a message to the linked DISCORD.
 * 
 * @param format        	The formated message.
 *
 * @return 					N/A;
 **/
native void rp_LogToDiscord(const char[] format);

native void rp_GetItemData(int itemID, item_list typeID, char[] str, int length);
native void rp_SetItemData(int itemID, item_list typeID, char[] str, int length);

native int rp_GetClientItem(int client, int itemID, bool banked = false);
native void rp_SetClientItem(int client, int itemID, int value, bool banked = false);

native bool rp_GetCanUseItem(int client, int itemID);
native bool rp_SetCanUseItem(int client, int itemID, bool value);

native bool rp_SetClientDelayItemStat(int client, int itemID, bool value);

native int rp_GetItemStock(int itemID);
native int rp_SetItemStock(int itemID, int value);

native bool rp_IsItemValidIndex(int itemID);

native int rp_GetVehicleInt(int vehicle, vehicle_list data);
native int rp_SetVehicleInt(int vehicle, vehicle_list prop, int value);
native float rp_GetVehicleFloat(int vehicle, vehicle_list data);
native float rp_SetVehicleFloat(int vehicle, vehicle_list prop, float value);
native void rp_GetVehicleString(int vehicle, vehicle_list data, char[] value, int length);
native void rp_SetVehicleString(int vehicle, vehicle_list prop, char[] value, int length);

native void rp_PerformNPCSell(int client, int jobID);

native bool rp_SetSuccess(int client, archi_list prop, bool value);
native bool rp_GetSuccess(int client, archi_list prop);

native void rp_LoadNPC();

native int rp_GetAppartementInt(int appid, appart_list prop);
native void rp_SetAppartementInt(int appid, appart_list prop, int value);

native bool rp_GetClientKeyAppartement(int client, int appid);
native bool rp_SetClientKeyAppartement(int client, int appid, bool value);

native int rp_GetVillaInt(int villaid, villa_list prop);
native void rp_SetVillaInt(int villaid, villa_list prop, int value);

native bool rp_GetClientKeyVilla(int client, int villaid);
native bool rp_SetClientKeyVilla(int client, int villaid, bool value);

native int rp_GetHotelInt(int hotelid, hotel_list prop);
native void rp_SetHotelInt(int hotelid, hotel_list prop, int value);

native bool rp_GetClientKeyHotel(int client, int villaid);
native bool rp_SetClientKeyHotel(int client, int villaid, bool value);

native void rp_PerformLoadingBar(int client, LOADING_TYPE type, const char[] message, int maxcubes);

native int rp_GetClientStat(int client, int_stat_data prop);
native void rp_SetClientStat(int client, int_stat_data prop, int value);

native int rp_SendHelicopter(int client, int type /*See Enum*/);
native int rp_GetHelicopterOwner(int entity);

native bool rp_GetClientKeyVehicle(int client, int entcar);
native bool rp_SetClientKeyVehicle(int client, int entcar, bool value);

native bool rp_ClientCanDrawPanel(int client);

native Action rp_OpenTutorial(int client);

native EngineVersion rp_GetGame();

native bool rp_IsClientEmoting(int client);

native int rp_StopEmote(int client);

native void rp_Close(Handle data, bool event = false, bool repeat = false, float duration = 1.0);

native int rp_SetClientResource(int client, resource_list prop, int value);
native int rp_GetClientResource(int client, resource_list prop);

native void rp_SetZoneData(int zoneID, zone_type typeID, char[] str, int length);
native void rp_GetZoneData(int zoneID, zone_type typeID, char[] str, int length);

native bool rp_IsValidRank(int rankid);

native void rp_SetEntityAnimation(int entity, char animation[64] = "idle", float delay = 0.0);

native float rp_GetEntityHealth(int entity);
native float rp_SetEntityHealth(int entity, float value);

native int rp_GetJobName(int jobid, char[] str, int length);
native void rp_SetJobName(int jobid, char[] str, int length);

native int rp_GetJobCapital(int jobid);
native void rp_SetJobCapital(int jobid, int value);

native int rp_GetJobMaxGrades(int jobid);

native int rp_GetGradeName(int jobid, int gradeid, char[] str, int length);
native void rp_SetGradeName(int jobid, int gradeid, char[] str, int length);

native int rp_GetGradeClantag(int jobid, int gradeid, char[] str, int length);
native void rp_SetGradeClantag(int jobid, int gradeid, char[] str, int length);

native int rp_GetGradeSalary(int jobid, int gradeid);
native void rp_SetGradeSalary(int jobid, int gradeid, int value);

native int rp_GetGradeModel(int jobid, int gradeid, char[] str, int length);
native void rp_SetGradeModel(int jobid, int gradeid, char[] str, int length);

native void rp_Slay(int client);

native void rp_GetRaisonName(int id, char[] str, int length);

native int rp_GetSQLID(int client);

native void rp_BuildProp(int entity);

native int rp_GetNPCType(int entity);

/**
 * @brief Get a value from a gived key extracted from the settings.cfg
 * 
 * @param name        		The stringmap key
 * @param buffer        	The buffer to store
 * @param length        	The buffer length
 *
 * @return 					-1;
 **/
native void rp_GetGlobalData(char[] name, char[] value, int length);

/**
 * @brief Get entity owner
 * 
 * @param entity			The entity index
 *
 * @return 					-1;
 **/
native int rp_GetEntityOwner(int entity);

/**
 * @brief Set entity owner
 * 
 * @param entity			The entity index
 * @param owner				The entity owner
 *
 * @return 					-1;
 **/
native int rp_SetEntityOwner(int entity, int owner);

/**
 * @brief Check if the entity is a valid roleplay entity
 * 
 * @param entity			The entity index
 *
 * @return 					-1;
 **/
native bool rp_IsEntityValidRoleplay(int entity);

native void rp_GetNationalityName(int id, char[] str, int length);
native void rp_GetSexeName(int id, char[] str, int length);
native void rp_GetJobDoors(int id, char[] str, int length);
native void rp_SetJobDoors(int id, char[] str, int length);
native int rp_GetDoorJobID(int entity);
native bool rp_CanJobSell(int id);
native bool rp_SetCanJobSell(int id, bool value);

native HUD_TYPE rp_GetHudType(int client);
native HUD_TYPE rp_SetHudType(int client, HUD_TYPE value);