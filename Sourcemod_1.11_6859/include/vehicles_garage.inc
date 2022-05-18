#if defined _vehicles_garage_included
 #endinput
#endif
#define _vehicles_garage_included

/**
 * Displays the vehicles garage main menu to a certain client.
 * The function requires the vehicle entity index, 
 * however it displays the menu to the driver.
 *
 * @param entity		Vehicle entity index.
 * @param start_item	Item to start the menu in, usually 'menu.Selection'.
 * @error				Invalid client index or client not in game.
 */
native void Vehicles_DisplayGarageMenu(int entity, int start_item = 0);

/**
 * Retrieves all the garages npcs entity indexes.
 *
 * @return	ArrayList filled with all the garages npcs entity indexes.
 */
native ArrayList Vehicles_GetGaragesNPCs();

/**
 * Called when a client is accessing the vehicles garage service menu.
 *
 * @param client	Client index.
 * @param entity	Vehicle entity index.
 * @param menu		Service menu handle.
 */
forward void Vehicles_OnGarageService(int client, int entity, Menu menu);

/**
 * Called when a client had selected a vehicles garage service.
 *
 * @param client	Client index.
 * @param entity	Vehicle entity index.
 * @param item_pos	Selected menu item position index.
 * @param menu		Service menu handle.
 */
forward void Vehicles_OnGarageServiceSelect(int client, int entity, int item_pos, Menu menu);

/**
 * Generally called when a client requests to sell a vehicle.
 * Format goes like that:
 * modifications.SetString("Skin", "5;500");
 * modifications.SetString("Color", "Blue;3000");
 *
 * @param entity		Vehicle entity index.
 * @param vehicle_type	'VehicleType' data of 'entity'.
 * @param modifications	StringMap handle that will store modifications.
 */
forward void Vehicles_OnGarageModificationRequest(int entity, VehicleType vehicle_type, StringMap modifications);

#if !defined REQUIRE_PLUGIN
public __pl_vehicles_SetNTVOptional()
{
	MarkNativeAsOptional("Vehicles_DisplayGarageMenu");
	MarkNativeAsOptional("Vehicles_GetGaragesNPCs");
}
#endif

public SharedPlugin __pl_vehicles_garage = 
{
	name = "vehicles_garage", 
	file = "garage.smx", 
#if defined REQUIRE_PLUGIN
    required = 1, 
#else
    required = 0, 
#endif
}; 