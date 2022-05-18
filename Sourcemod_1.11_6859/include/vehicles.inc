#if defined _vehicles_included
 #endinput
#endif
#define _vehicles_included

// Strings lengths declarations.
#define CATEGORY_MAX_NAME_LENGTH 64
#define VEHICLE_MAX_IDENTIFIER_LENGTH 32
#define VEHICLE_MAX_NAME_LENGTH 64

// Vehicles entity classname to workaround with.
#define VEHICLE_ENTITY_CLASSNAME "prop_vehicle_driveable"

// Vehicles images files path inside the folder 'materials'.
#define VEHICLES_PREVIEW_FILES_PATH "entities"

// Prefixes.
#define VEHICLES_PREFIX_MENU "[Vehicles]"
#define VEHICLES_PREFIX " \x04" ... VEHICLES_PREFIX_MENU ... "\x01"

// Default horn sound.
#define VEHICLE_HORN_SOUND "vehicles/horn_standard.mp3"

// Base fuel amount on vehicle spawn.
#define BASE_VEHICLES_FUEL 100.0

#define INVALID_VEHICLE_OWNER 0

enum ViewMode
{
	Mode_FirstPerson = 0, /**< First-Person view mode, value has no effect. */
	Mode_Close = 125, 	  /**< Close view mode, value equals to camera range. */
	Mode_Far = 165, 	  /**< Far view mode, value equals to camera range. */
	Mode_VeryFar = 200	  /**< Very far view mode, value equals to camera range. */
}

// Vehicles passenger roles.
enum PassengerRole
{
	VEHICLE_ROLE_NONE = -1, 
	
	VEHICLE_ROLE_DRIVER = 0,  	  // Vehicle driver.
	VEHICLE_ROLE_PASSENGER1 = 1,  // Passenger #1
	VEHICLE_ROLE_PASSENGER2 = 2,  // Passenger #2
	VEHICLE_ROLE_PASSENGER3 = 3,  // Passenger #3
	
	LAST_SHARED_VEHICLE_ROLE
}

// Wheel indexs for the sdk wheel positions.
enum
{
	VehicleWheel_TopLeft, 
	VehicleWheel_TopRight, 
	VehicleWheel_BottomLeft, 
	VehicleWheel_BottomRight
}

enum VehicleSpawnBlockReasons
{
	VEHICLE_SPAWN_BLOCK_NONE,		/**< No block occurred */
	VEHICLE_SPAWN_BLOCK_POSITION,	/**< Block caused due to an invalid given origin vector (Outside world) */
	VEHICLE_SPAWN_BLOCK_UNSUITABLE, /**< Block caused due to unsuitable area */
	VEHICLE_SPAWN_BLOCK_FORWARD,   	/**< Block originates from a forward */
	VEHICLE_SPAWN_BLOCK_UNKNOWN   	/**< An unknown error occured */
}

enum struct VehicleType
{
	// Uniquely item identifier.
	char identifier[VEHICLE_MAX_IDENTIFIER_LENGTH];
	
	// Display name.
	char name[VEHICLE_MAX_NAME_LENGTH];
	
	// Model path.
	char model[PLATFORM_MAX_PATH];
	
	// Vehicle script path.
	char script[PLATFORM_MAX_PATH];
	
	// Base (start) health points in spawn.
	int base_health;
	
	// Vehicle type price value ($)
	int price_value;
	
	//======================================//
	
	// Retrieves the preview image file path of this vehicle.
	// True if this vehicle has an available preview image, false otherwise.
	// https://github.com/Natanel-Shitrit/vehicles/blob/5dad88b456171077b49d37bfa7c60b29a56e027a/scripting/vehicles.sp#L95-L138
	void GetPreviewImage(char[] buffer, int len)
	{
		Format(buffer, len, "%s/%s.png", VEHICLES_PREVIEW_FILES_PATH, this.identifier);
	}
	
	bool IsPreviewAvailable()
	{
		char file_path[PLATFORM_MAX_PATH];
		this.GetPreviewImage(file_path, sizeof(file_path));
		Format(file_path, sizeof(file_path), "materials/%s", file_path);
		return FileExists(file_path);
	}
}

enum struct Category
{
	// Display name (Menus, chat messages, etc...).
	char name[CATEGORY_MAX_NAME_LENGTH];
	
	// Stores the associated stock vehicles to this category.
	ArrayList vehicle_types;
	
	//======================================//
	
	// Initialize handles.
	void Init()
	{
		this.vehicle_types = new ArrayList(sizeof(VehicleType));
	}
	
	// Closes the struct handles and avoiding leaking memory. 
	// This should be called before deleting this struct.
	void Close()
	{
		delete this.vehicle_types;
	}
}

/**
 * Retrieves whether the vehicles configuration file data has successfully parsed and loaded.
 *
 * @return               True if the config file has been successfully loaded, false otherwise.
 */
native bool Vehicles_IsConfigLoaded();

/**
 * Retrieves an arraylist that contains vehicle categories data.
 * The ArrayList must be freed via delete or CloseHandle().
 *
 * @return               ArrayList handle filled with 'Category's.
 */
native ArrayList Vehicles_GetCategories();

/**
 * Retrieves an arraylist that contains vehicle types from a parent category.
 * The ArrayList must be freed via delete or CloseHandle().
 *
 * @param categoryId     Category array index.
 * @return               ArrayList handle filled with 'VehicleType's.
 * @error                Invalid category array index. (Out of bounds)
 */
native ArrayList Vehicles_GetVehicleTypes(int categoryId);

/**
 * Retrieves an arraylist that contains vehicle types from a parent category.
 * The ArrayList must be freed via delete or CloseHandle().
 *
 * @param categoryName   Category name string.
 * @return               ArrayList handle filled with 'VehicleType's, 
 *						 or null if no match has found with the give name.
 */
native ArrayList Vehicles_GetVehicleTypesByName(const char[] categoryName);

/**
 * Finds and returns a 'VehicleType' data by the given entity index.
 *
 * @param entity		Vehicle entity index.
 * @param result		Destination 'VehicleType' buffer.
 *
 * @return				True if a match has found, false otherwise.
 * @error				Invalid entity index.
 */
native bool Vehicles_GetVehicleTypeByEntity(int entity, any[] result);

/**
 * Finds and returns a 'VehicleType' data by the given identifier.
 *
 * @param identifier	 Valid vehicle type identifier.
 * @param result     	 Destination 'VehicleType' buffer.
 *
 * @return               True if a match has found, false otherwise.
 * @error                Invalid entity index.
 */
native bool Vehicles_GetVehicleTypeByIdentifier(const char[] identifier, any[] result);

/**
 * Finds and returns a 'Category' data by the given identifier.
 *
 * @param identifier	 Valid vehicle type identifier.
 * @param result     	 Destination 'Category' buffer.
 *
 * @return               True if a match has found, false otherwise.
 * @error                Invalid entity index.
 */
native bool Vehicles_GetCategoryOfVehicleType(const char[] identifier, any[] result);

/**
 * Retrieves whether an entity is a driveable vehicle.
 *
 * This check is necessary before assuming for a vehicle entity. 
 * (Certain 'prop_vehicle_driveable' entities assigned as extended seats for passengers and not actually driveable.)
 *
 * @param entity     	 Entity index to perform checks on.
 * @return               True if the entity is a driveable vehicle, false otherwise.
 * @error                Invalid entity index.
 */
native bool Vehicles_IsEntityDriveable(int entity);

/**
 * Retrieves a client vehicle passenger role. 
 *
 * @param client     	 Client index.
 * @return               Client passenger role. See the enum above.
 * @error                Invalid client index or client not in game.
 */
native PassengerRole Vehicles_GetClientPassengerRole(int client);

/**
 * Retrieves the vehicle entity index a certain client is driving on.
 *
 * @param client     	 Client index.
 * @return               Entity index on success, or -1 if the client is not driving or on faliure.
 * @error                Invalid client index or client not in game.
 */
native int Vehicles_GetClientVehicleEntity(int client);

/**
 * Retrieves a vehicle passenger client index by
 * the aim position and angles of a certain client.
 *
 * @param client     	 Client index.
 * @return               Passenger client index on success, or 0 on faliure.
 * @error                Invalid client index or client not in game.
 */
native int Vehicles_GetPassengerByClientAim(int client);

/**
 * Spawns a new driveable vehicle entity. (prop_vehicle_driveable)
 *
 * @param identifier     Vehicle type identifier to retrieve data from when spawning the vehicle.
 * @param origin		 Spawn origin.
 * @param angles		 Spawn angles.
 * @param owner			 Optional parameter to set the vehicle owner.
 * @param block_reason	 Optional by-reference parameter for spawn block error code. See the enum above for detailed block reasons.
 * 
 * @return               Entity index on success, or -1 on failure.
 * @error                Invalid vehicle type identifier or origin vector is outside world.
 */
native int Vehicles_SpawnVehicle(const char[] identifier, const float origin[3], const float angles[3], int owner = INVALID_VEHICLE_OWNER, VehicleSpawnBlockReasons &block_reason = VEHICLE_SPAWN_BLOCK_NONE);

/**
 * Destroys a driveable vehicle entity. (prop_vehicle_driveable)
 *
 * @param entity     	 		 Vehicle entity index to destroy.
 * @param kill_passengers     	 True to kill vehicle passengers on destroy, false otherwise.
 * @return						 True on success, false otherwise.
 * @error             			 Invalid entity index or the entity is not a driveable vehicle.
 */
native bool Vehicles_DestroyVehicle(int entity, bool kill_passengers = true);

/**
 * Forces a player to enter a vehicle as a passenger.
 *
 * @param entity     	 Vehicle entity index.
 * @param passenger		 Passenger client index.
 * @param role			 Passenger role, or 'VEHICLE_ROLE_NONE' to find the nearest free passenger role.
 * @param replace		 True to replace this passenger with an existing one, false otherwise.
 * 
 * @return			  	 True on success, false otherwise.
 * @error             	 Invalid entity index, entity is not a driveable vehicle, or the passenger client index is invalid.
 */
native bool Vehicles_GetInPassenger(int entity, int passenger, PassengerRole role = VEHICLE_ROLE_NONE, bool replace = false);

/**
 * Forces a passenger to leave a vehicle.
 *
 * @param passenger		 Passenger client index.
 * @return			  	 True on success, false otherwise.
 * @error                Invalid client index or client not in game.
 */
native bool Vehicles_ExitPassenger(int passenger);

/**
 * Retrieves an ArrayList with all the spawned vehicles entity indexes.
 * The ArrayList must be freed via delete or CloseHandle().
 *
 * @return			  	 ArrayList handle filled with all the spawned vehicles entity indexes.
 */
native ArrayList Vehicles_GetActiveVehicles();

/**
 * Retrieves the vehicle type data of a vehicle entity.
 *
 * @param entity     	 Vehicle entity index.
 * @param passengers	 Buffer to store the vehicle type data.            
 * @error                Invalid entity index or the entity is not a driveable vehicle.
 */
native void Vehicles_GetVehicleTypeOfVehicle(int entity, any[] buffer);

/**
 * Retrieves the passengers client indexes of a vehicle entity.
 *
 * @param entity     	 Vehicle entity index.
 * @param passengers	 Buffer to store the passengers client indexes.            
 * @error                Invalid entity index or the entity is not a driveable vehicle.
 */
native void Vehicles_GetVehiclePassengers(int entity, int passengers[LAST_SHARED_VEHICLE_ROLE]);

/**
 * Retrieves the speed of a vehicle entity.
 *
 * @param entity     	 Vehicle entity index.
 * @return 				 Vehicle speed.   
 * @error                Invalid entity index or the entity is not a driveable vehicle.
 */
native int Vehicles_GetVehicleSpeed(int entity);

/**
 * Retrieves whether or not a certain vehicle is overturned.
 *
 * @param entity     	 Vehicle entity index.
 * @return 				 True if the vehicle is overturned, false otherwise.     
 * @error                Invalid entity index or the entity is not a driveable vehicle.
 */
native bool Vehicles_IsVehicleOverturned(int entity);

/**
 * Retrieves the owner client index of a certain vehicle.
 *
 * @param entity     	 Vehicle entity index.
 * @return               Vehicle owner client index, or 'INVALID_VEHICLE_OWNER' if the vehicle has no owner at all.
 * @error                Invalid entity index or the entity is not a driveable vehicle.
 */
native int Vehicles_GetVehicleOwner(int entity);

/**
 * Sets the owner client index of a certain vehicle.
 *
 * @param entity     	 Vehicle entity index.
 * @param owner			 New owner client index, or 'INVALID_VEHICLE_OWNER' to remove the vehicle ownership.
 * @error                Invalid entity index or the entity is not a driveable vehicle.
 */
native void Vehicles_SetVehicleOwner(int entity, int owner);

/**
 * Retrieves the health points of a certain vehicle.
 *
 * @param entity     	 Vehicle entity index.
 * @return               Vehicle health points.
 * @error                Invalid entity index or the entity is not a driveable vehicle.
 */
native int Vehicles_GetVehicleHealth(int entity);

/**
 * Sets the health points of a certain vehicle.
 *
 * @param entity     	 Vehicle entity index.
 * @param amount		 New vehicle health points amount, or 0 to set the vehicle base health.
 * @error                Invalid entity index or the entity is not a driveable vehicle.
 */
native void Vehicles_SetVehicleHealth(int entity, int amount = 0);

/**
 * Retrieves the left fuel amount of a certain vehicle.
 *
 * @param entity     	 Vehicle entity index.
 * @return               Vehicle fuel.
 * @error                Invalid entity index or the entity is not a driveable vehicle.
 */
native float Vehicles_GetVehicleFuel(int entity);

/**
 * Sets the left fuel amount of a certain vehicle.
 *
 * @param entity     	 Vehicle entity index.
 * @param amount		 New vehicle left fuel amount, or 0 to empty the vehicle fuel can.
 * @error                Invalid entity index or the entity is not a driveable vehicle.
 */
native void Vehicles_SetVehicleFuel(int entity, float amount);

/**
 * Retrieves a vehicle engine state.
 *
 * @param entity     	 Vehicle entity index.
 * @return				 True if the vehicle engine is turned on, false otherwise.
 * @error                Invalid entity index or the entity is not a driveable vehicle.
 */
native bool Vehicles_GetEngineState(int entity);

/**
 * Sets a vehicle engine state.
 *
 * @param entity     	 Vehicle entity index.
 * @param state			 True to turn the vehicle engine on, false to turn it off.
 * @error                Invalid entity index or the entity is not a driveable vehicle.
 */
native void Vehicles_SetEngineState(int entity, bool state);

/**
 * Retrieves whether or not a certain vehicle is locked.
 *
 * @param entity     	 Vehicle entity index.
 * @return 				 True on success, false otherwise.     
 * @error                Invalid entity index or the entity is not a driveable vehicle.
 */
native bool Vehicles_IsVehicleLocked(int entity);

/**
 * Sets a vehicle lock state.
 *
 * @param entity     	 Vehicle entity index.
 * @param state		 	 Lock state value. True to lock the vehicle, false to unlock.
 * @error                Invalid entity index or the entity is not a driveable vehicle.
 */
native void Vehicles_SetVehicleLock(int entity, bool state);

/**
 * Called when the vehicles configuration file data has successfully parsed and loaded.
 *
 * From now and on the natives 'Vehicles_GetCategories()' and 'Vehicles_GetVehicleTypes()'
 * are available to use.
 */
forward void Vehicles_OnConfigLoaded();

/**
 * Called before a driveable vehicle entity is being created.
 *
 * Note: This called when the vehicle entity has created but hasn't spawned yet, 
 *		 therefore only KeyValues disptaching and similar actions are allowed.
 *
 * @param entity     	 Entity index.	
 * @param identifier	 Vehicle type identifier string.
 * @param owner			 Vehicle owner client index, or 'INVALID_VEHICLE_OWNER' if the vehicle has no owner.
 * @param health		 Spawn base health points.
 * @param fuel		 	 Spawn base fuel amount.
 * @param position		 Spawn origin vector. (Changeable)
 * @param angles		 Spawn angles vector. (Changeable)
 *
 * @return             	 An Action value. Returning Plugin_Handled bypasses the game function call.
 *                       Returning Plugin_Stop bypasses the post hook as well as the game function.
 */
forward Action Vehicles_OnVehicleSpawn(int entity, const char[] identifier, int &owner, int &health, float &fuel, float position[3], float angles[3]);

/**
 * Called after a driveable vehicle entity has been destroyed.
 *
 * Note: Some of the featured vehicle natives may not work properly here,
 *		 therefore implementing a use of the forward params should be preffered.
 *
 * @param entity     	 Entity index.	
 * @param identifier	 Vehicle type identifier string.
 * @param owner			 Vehicle owner client index, or 'INVALID_VEHICLE_OWNER' if the vehicle has no owner.
 * @param health		 Spawn base health points.
 * @param fuel		 	 Spawn base fuel amount.
 * @param passengers	 Contains all passengers client indexes. (By now all the passengers are already outside the vehicle, and possibility dead!)
 */
forward void Vehicles_OnVehicleDestroyed(int entity, const char[] identifier, int owner, int health, float fuel, const int passengers[LAST_SHARED_VEHICLE_ROLE]);

/**
 * Called when a vehicle is crashing against another entity.
 *
 * @param entity     	 	Entity index.	
 * @param hit_entity	 	Other hit entity index. 0 = World
 * @param damage		 	Damage given to the vehicle. 
 * @param passengers_damage	Damage given to the vehicle passengers. Generally [damage / vehicles_crash_sensitivity_scale.FloatValue]
 * @param collision_speed	Impact collision speed force - [gamevcollisionevent_t::collisionSpeed]. (This is not the same as the vehicle speed!)
 *
 * @return             	 	An Action value. Returning Plugin_Handled bypasses the game function call.
 *                       	Returning Plugin_Stop bypasses the post hook as well as the game function.
 */
forward Action Vehicles_OnVehicleCollision(int entity, int hit_entity, float &damage, float &passengers_damage, float collision_speed);

/**
 * Called when a vehicle is taking damage from a living player.
 *
 * Note: This forward doesn't called when the vehicle is taking damage by crashing.
 *		 'Vehicles_OnVehicleCollision()' forward is usefull for those cases.
 *
 * @param entity     	 	Entity index.	
 * @param attacker	 		Attacker entity index. (0 for self inflicted damage)
 * @param victim		 	Victim client index. (0 If damage applied to the vehicle)
 * @param damage			Damage given to vehicle/victim.
 *
 * @return             	 	An Action value. Returning Plugin_Handled bypasses the game function call.
 *                       	Returning Plugin_Stop bypasses the post hook as well as the game function.
 */
forward Action Vehicles_OnVehicleTakeDamage(int entity, int attacker, int victim, float &damage);

/**
 * Called when a vehicle wheel is drifted.
 *
 * Note: This forward is being called for each wheel index.
 * 		 See VehicleWheel_* for list of indexes.
 *
 *		 Returning value '>= Plugin_Handled' will block the creation of the drift material.
 *
 * @param entity     	 	Entity index.	
 * @param wheel_index	 	Wheel index.
 *
 * @return             	 	An Action value. Returning Plugin_Handled bypasses the game function call.
 *                       	Returning Plugin_Stop bypasses the post hook as well as the game function.
 */
forward Action Vehicles_OnVehicleWheelDrift(int entity, int &wheel_index);

/**
 * Called when a client is entering a vehicle as a passenger.
 *
 * @param client     	 Passenger client index.	
 * @param role			 Enter passenger role inside the vehicle. See the enum above.
 * @param entity		 Vehicle entity index.
 *
 * @return             	 An Action value. Returning Plugin_Handled bypasses the game function call.
 *                       Returning Plugin_Stop bypasses the post hook as well as the game function.
 */
forward Action Vehicles_OnPassengerEnter(int client, PassengerRole &role, int entity);

/**
 * Called when a passenger is exiting a vehicle.
 *
 * Note that this forward is also being called when a passenger died, disconnected, 
 * or has been interrupted by an external plugin who called `TeleportEntity()` on the client.
 *
 * @param client     	 Passenger client index.	
 * @param role			 Exit passenger role inside the vehicle. See the enum above.
 * @param entity		 Vehicle entity index.
 *
 * @return             	 An Action value. Returning Plugin_Handled bypasses the game function call.
 *                       Returning Plugin_Stop bypasses the post hook as well as the game function.
 */
forward Action Vehicles_OnPassengerExit(int client, PassengerRole role, int entity);

/**
 * Called when a vehicle driver is honking.
 *
 * @param client     	 Driver client index who triggered the horn.	
 * @param entity		 Vehicle entity index.
 * @param sound			 Horn sould file path relative to the "sound" folder.
 *						 'VEHICLE_HORN_SOUND' by default.
 *
 * @return             	 An Action value. Returning Plugin_Handled bypasses the game function call.
 *                       Returning Plugin_Stop bypasses the post hook as well as the game function.
 */
forward Action Vehicles_OnHornSound(int client, int entity, char sound[PLATFORM_MAX_PATH]);

// Adds health points to a certain vehicle entity.
stock void AddVehicleHealth(int entity, int amount)
{
	Vehicles_SetVehicleHealth(entity, Vehicles_GetVehicleHealth(entity) + amount);
}

// Removes health points from a certain vehicle entity.
stock void RemoveVehicleHealth(int entity, int amount)
{
	Vehicles_SetVehicleHealth(entity, Vehicles_GetVehicleHealth(entity) - amount);
}

// Adds fuel to a certain vehicle entity.
stock void AddVehicleFuel(int entity, float amount)
{
	Vehicles_SetVehicleFuel(entity, Vehicles_GetVehicleFuel(entity) + amount);
}

// Removes fuel from a certain vehicle entity.
stock void RemoveVehicleFuel(int entity, float amount)
{
	Vehicles_SetVehicleFuel(entity, Vehicles_GetVehicleFuel(entity) - amount);
}

// Emits an ambient sound from a vehicle entity.
stock void EmitVehicleAmbientSound(int vehicle, const char[] name, int level = SNDLEVEL_NORMAL, int flags = SND_NOFLAGS, float vol = SNDVOL_NORMAL, int pitch = SNDPITCH_NORMAL, float delay = 0.0)
{
	static int m_vecOriginOffset = -1;
	if (m_vecOriginOffset == -1 && (m_vecOriginOffset = FindSendPropInfo("CCSPlayer", "m_vecOrigin")) <= 0)
	{
		SetFailState("Failed to find 'm_vecOrigin' offset");
	}
	
	// Get the vehicle position.
	float pos[3];
	GetEntDataVector(vehicle, m_vecOriginOffset, pos);
	
	// Play the ambient sound.
	EmitAmbientSound(name, pos, vehicle, level, flags, vol, pitch, delay);
}

#if !defined REQUIRE_PLUGIN
public __pl_vehicles_SetNTVOptional()
{
	MarkNativeAsOptional("Vehicles_IsConfigLoaded");
	MarkNativeAsOptional("Vehicles_GetCategories");
	MarkNativeAsOptional("Vehicles_GetVehicleTypes");
	MarkNativeAsOptional("Vehicles_GetVehicleTypesByName");
	MarkNativeAsOptional("Vehicles_GetVehicleTypeByEntity");
	MarkNativeAsOptional("Vehicles_GetVehicleTypeByIdentifier");
	MarkNativeAsOptional("Vehicles_GetCategoryOfVehicleType");
	MarkNativeAsOptional("Vehicles_IsEntityDriveable");
	MarkNativeAsOptional("Vehicles_GetClientPassengerRole");
	MarkNativeAsOptional("Vehicles_GetClientVehicleEntity");
	MarkNativeAsOptional("Vehicles_GetPassengerByClientAim");
	MarkNativeAsOptional("Vehicles_SpawnVehicle");
	MarkNativeAsOptional("Vehicles_DestroyVehicle");
	MarkNativeAsOptional("Vehicles_GetInPassenger");
	MarkNativeAsOptional("Vehicles_ExitPassenger");
	MarkNativeAsOptional("Vehicles_GetActiveVehicles");
	MarkNativeAsOptional("Vehicles_GetVehicleTypeOfVehicle");
	MarkNativeAsOptional("Vehicles_GetVehiclePassengers");
	MarkNativeAsOptional("Vehicles_GetVehicleSpeed");
	MarkNativeAsOptional("Vehicles_IsVehicleOverturned");
	MarkNativeAsOptional("Vehicles_GetVehicleOwner");
	MarkNativeAsOptional("Vehicles_SetVehicleOwner");
	MarkNativeAsOptional("Vehicles_GetVehicleHealth");
	MarkNativeAsOptional("Vehicles_SetVehicleHealth");
	MarkNativeAsOptional("Vehicles_GetVehicleFuel");
	MarkNativeAsOptional("Vehicles_SetVehicleFuel");
	MarkNativeAsOptional("Vehicles_GetEngineState");
	MarkNativeAsOptional("Vehicles_SetEngineState");
	MarkNativeAsOptional("Vehicles_IsVehicleLocked");
	MarkNativeAsOptional("Vehicles_SetVehicleLock");
}
#endif

public SharedPlugin __pl_vehicles = 
{
	name = "vehicles", 
	file = "vehicles.smx", 
#if defined REQUIRE_PLUGIN
    required = 1, 
#else
    required = 0, 
#endif
}; 