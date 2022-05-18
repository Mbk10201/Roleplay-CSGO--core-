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

							P L U G I N  -  I N C L U D E S

***************************************************************************************/
#include <roleplay_csgo.inc>

/***************************************************************************************

							P L U G I N  -  D E F I N E S

***************************************************************************************/
#define JOBID				4

/***************************************************************************************

							G L O B A L  -  V A R S

***************************************************************************************/

char steamID[MAXPLAYERS + 1][32];
bool EntityAlreadyHaveDrill[MAXENTITIES + 1] = {false, ...};
Handle h_DrillTimer[MAXENTITIES + 1];

/***************************************************************************************

							P L U G I N  -  I N F O

***************************************************************************************/
public Plugin myinfo = 
{
	name = "Roleplay - [JOB] Mairie", 
	author = "MBK", 
	description = "", 
	version = "1.0", 
	url = "https://github.com/Mbk10201"
};

/***************************************************************************************

							P L U G I N  -  F O R W A R D S

***************************************************************************************/
public void OnPluginStart()
{
	LoadTranslation();
}

public void OnClientAuthorized(int client, const char[] auth) 
{	
	strcopy(steamID[client], sizeof(steamID[]), auth);
}

public void RP_OnClientInteract(int client, int target, const char[] class, const char[] model, const char[] name)
{
	if(rp_GetNPCType(target) == JOBID)
	{
		if(Distance(client, target) <= 80.0)
			rp_PerformNPCSell(client, JOBID);
		else
			Translation_PrintTooFar(client);
	}
}	

/***************************************************************************************

									C A L L B A C K

***************************************************************************************/  
public void RP_OnInventoryHandle(int client, int itemID)
{
	char translate[128];

	if(itemID == 164)
	{
		if(IsOnGround(client))
		{
			if(rp_GetClientInt(client, i_Zone) != 777)
			{
				rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);		
				
				/*			ENTITY			*/
				float TeleportOrigin[3], JoueurOrigin[3];
				GetClientAbsOrigin(client, JoueurOrigin);
				TeleportOrigin[0] = JoueurOrigin[0];
				TeleportOrigin[1] = JoueurOrigin[1];
				TeleportOrigin[2] = (JoueurOrigin[2]);
				
				char sModel[128];
				rp_GetGlobalData("model_acetone", STRING(sModel));
				
				int ent = rp_CreatePhysics("", TeleportOrigin, NULL_VECTOR, sModel, 0, true);
				Entity_SetName(ent, steamID[client]);
				
				JoueurOrigin[2] += 35;
				TeleportEntity(client, JoueurOrigin, NULL_VECTOR, NULL_VECTOR);
				/****************************/
			
				char name[32];
				rp_GetItemData(itemID, item_name, STRING(name));				
				Format(STRING(translate), "%T", "Inventory_using", LANG_SERVER, name);
				rp_PrintToChat(client, "%s.", translate);
			}
			else 
				rp_PrintToChat(client, "Interdit de poser en zone P.V.P");
		}		
	}
	else if(itemID == 165)
	{
		if(IsOnGround(client))
		{
			if(rp_GetClientInt(client, i_Zone) != 777)
			{
				rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);		
				
				/*			ENTITY			*/
				float TeleportOrigin[3], JoueurOrigin[3];
				GetClientAbsOrigin(client, JoueurOrigin);
				TeleportOrigin[0] = JoueurOrigin[0];
				TeleportOrigin[1] = JoueurOrigin[1];
				TeleportOrigin[2] = (JoueurOrigin[2]);
				
				char sModel[128];
				rp_GetGlobalData("model_ammoniac", STRING(sModel));
				
				int ent = rp_CreatePhysics("", TeleportOrigin, NULL_VECTOR, sModel, 0, true);
				Entity_SetName(ent, steamID[client]);
				
				JoueurOrigin[2] += 35;
				TeleportEntity(client, JoueurOrigin, NULL_VECTOR, NULL_VECTOR);
				/****************************/
			
				char name[32];
				rp_GetItemData(itemID, item_name, STRING(name));				
				Format(STRING(translate), "%T", "Inventory_using", LANG_SERVER, name);
				rp_PrintToChat(client, "%s.", translate);
			}
			else 
				rp_PrintToChat(client, "Interdit de poser en zone P.V.P");	
		}		
	}
	else if(itemID == 166)
	{
		if(IsOnGround(client))
		{
			if(rp_GetClientInt(client, i_Zone) != 777)
			{
				rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);		
				
				/*			ENTITY			*/
				float pos[3];
				GetClientAbsOrigin(client, pos);
				
				char sModel[128];
				rp_GetGlobalData("model_bismuth", STRING(sModel));
				
				int ent = rp_CreatePhysics("", pos, NULL_VECTOR, sModel, 0, true);
				Entity_SetName(ent, steamID[client]);
				
				pos[2] += 35;
				TeleportEntity(client, pos, NULL_VECTOR, NULL_VECTOR);
				/****************************/
			
				char name[32];
				rp_GetItemData(itemID, item_name, STRING(name));				
				Format(STRING(translate), "%T", "Inventory_using", LANG_SERVER, name);
				rp_PrintToChat(client, "%s.", translate);
			}
			else 
				rp_PrintToChat(client, "Interdit de poser en zone P.V.P");	
		}		
	}
	else if(itemID == 167)
	{
		if(IsOnGround(client))
		{
			if(rp_GetClientInt(client, i_Zone) != 777)
			{
				rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);		
				
				/*			ENTITY			*/
				float pos[3];
				GetClientAbsOrigin(client, pos);
				
				char sModel[128];
				rp_GetGlobalData("model_phosphore", STRING(sModel));
				
				int ent = rp_CreatePhysics("", pos, NULL_VECTOR, sModel, 0, true);
				Entity_SetName(ent, steamID[client]);
				
				pos[2] += 35;
				TeleportEntity(client, pos, NULL_VECTOR, NULL_VECTOR);
				/****************************/
			
				char name[32];
				rp_GetItemData(itemID, item_name, STRING(name));				
				Format(STRING(translate), "%T", "Inventory_using", LANG_SERVER, name);
				rp_PrintToChat(client, "%s.", translate);
			}
			else 
				rp_PrintToChat(client, "Interdit de poser en zone P.V.P");	
		}		
	}
	else if(itemID == 168)
	{
		if(IsOnGround(client))
		{
			if(rp_GetClientInt(client, i_Zone) != 777)
			{
				rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);		
				
				/*			ENTITY			*/
				float pos[3];
				GetClientAbsOrigin(client, pos);
				
				char sModel[128];
				rp_GetGlobalData("model_sulfuric", STRING(sModel));
				
				int ent = rp_CreatePhysics("", pos, NULL_VECTOR, sModel, 0, true);
				Entity_SetName(ent, steamID[client]);
				
				pos[2] += 35;
				TeleportEntity(client, pos, NULL_VECTOR, NULL_VECTOR);
				/****************************/
			
				char name[32];
				rp_GetItemData(itemID, item_name, STRING(name));				
				Format(STRING(translate), "%T", "Inventory_using", LANG_SERVER, name);
				rp_PrintToChat(client, "%s.", translate);
			}
			else 
				rp_PrintToChat(client, "Interdit de poser en zone P.V.P");
		}		
	}
	else if(itemID == 169)
	{
		if(IsOnGround(client))
		{
			if(rp_GetClientInt(client, i_Zone) != 777)
			{
				rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);		
				
				/*			ENTITY			*/
				float pos[3];
				GetClientAbsOrigin(client, pos);
				
				char sModel[128];
				rp_GetGlobalData("model_sodium", STRING(sModel));
				
				int ent = rp_CreatePhysics("", pos, NULL_VECTOR, sModel, 0, true);
				Entity_SetName(ent, steamID[client]);
				
				pos[2] += 35;
				TeleportEntity(client, pos, NULL_VECTOR, NULL_VECTOR);
				/****************************/
			
				char name[32];
				rp_GetItemData(itemID, item_name, STRING(name));				
				Format(STRING(translate), "%T", "Inventory_using", LANG_SERVER, name);
				rp_PrintToChat(client, "%s.", translate);
			}
			else 
				rp_PrintToChat(client, "Interdit de poser en zone P.V.P");	
		}	
	}
	else if(itemID == 170)
	{
		if(IsOnGround(client))
		{
			if(rp_GetClientInt(client, i_Zone) != 777)
			{
				rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);		
				
				/*			ENTITY			*/
				float pos[3];
				GetClientAbsOrigin(client, pos);
				
				char sModel[128];
				rp_GetGlobalData("model_toulene", STRING(sModel));
				
				int ent = rp_CreatePhysics("", pos, NULL_VECTOR, sModel, 0, true);
				Entity_SetName(ent, steamID[client]);
				
				pos[2] += 35;
				TeleportEntity(client, pos, NULL_VECTOR, NULL_VECTOR);
				/****************************/
			
				char name[32];
				rp_GetItemData(itemID, item_name, STRING(name));				
				Format(STRING(translate), "%T", "Inventory_using", LANG_SERVER, name);
				rp_PrintToChat(client, "%s.", translate);
			}
			else 
				rp_PrintToChat(client, "Interdit de poser en zone P.V.P");	
		}		
	}
	else if(itemID == 171)
	{
		if(IsOnGround(client))
		{
			if(rp_GetClientInt(client, i_Zone) != 777)
			{
				rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);		
				
				/*			ENTITY			*/
				float pos[3];
				GetClientAbsOrigin(client, pos);
				
				char sModel[128];
				rp_GetGlobalData("model_battery", STRING(sModel));
				
				int ent = rp_CreatePhysics("", pos, NULL_VECTOR, sModel, 0, true);
				Entity_SetName(ent, steamID[client]);
				
				pos[2] += 35;
				TeleportEntity(client, pos, NULL_VECTOR, NULL_VECTOR);
				/****************************/
			
				char name[32];
				rp_GetItemData(itemID, item_name, STRING(name));				
				Format(STRING(translate), "%T", "Inventory_using", LANG_SERVER, name);
				rp_PrintToChat(client, "%s.", translate);
			}
			else 
				rp_PrintToChat(client, "Interdit de poser en zone P.V.P");	
		}		
	}
	else if(itemID == 172)
	{
		if(rp_GetClientInt(client, i_Zone) != 777)
		{
			int target = GetClientAimTarget(client, false);
			if(IsValidEntity(target))
			{
				char entName[64];
				Entity_GetName(target, STRING(entName));
				
				if(StrContains(entName, "coffre") != -1)
				{
					bool pass = false;
					
					if(StrContains(entName, "coffre") != -1)
					{
						if(!Entity_IsLocked(target))
						{
							pass = false;
							rp_PrintToChat(client, "La porte est déjà déverrouiller.");
						}
						else
							pass = true;
					}	
					
					if(pass)
					{
						if(!EntityAlreadyHaveDrill[target])
						{
							rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);		
							
							float position[3];
							PointVision(client, position);
							
							float eye_ang[3];
							GetClientEyeAngles(client, eye_ang);
							float ang[3];
							GetClientAbsAngles(client, ang);
							RoundToNearest(eye_ang[0]);
							RoundToNearest(eye_ang[1]);
							RoundToNearest(eye_ang[2]);
							RoundToNearest(ang[0]);
							RoundToNearest(ang[1]);
							RoundToNearest(ang[2]);
							
							float target_pos[3];
							Entity_GetAbsAngles(target, target_pos);
							if(target_pos[1] == 180.0)
								position[0] += 10.0;
							else if(target_pos[1] == 90.0)
							{
								if(ang[1] >= 80.0)
									position[1] -= 10.0;
								else if(ang[1] >= -80.0)
									position[1] += 400.0;							
							}
							
							DataPack pack = new DataPack();
							CreateDataTimer(5.0, Timer_PlantDrill, pack);
							pack.WriteCell(client);
							pack.WriteCell(target);
							pack.WriteFloat(position[0]);
							pack.WriteFloat(position[1]);
							pack.WriteFloat(position[2]);
							pack.WriteFloat(eye_ang[0]);
							pack.WriteFloat(eye_ang[1]);
							pack.WriteFloat(eye_ang[2]);
						
							char name[32];
							rp_GetItemData(itemID, item_name, STRING(name));				
							Format(STRING(translate), "%T", "Inventory_using", LANG_SERVER, name);
							rp_PrintToChat(client, "%s.", translate);
						}	
					}	
				}
				else
					rp_PrintToChat(client, "Vous devez viser l'un des objets listé ici: {lightgreen}Minerai {default}; {lightblue}Porte Blindé{default}.");				
			}
			else
				rp_PrintToChat(client, "Vous devez viser une entité.");			
		}
		else 
			rp_PrintToChat(client, "Interdit de poser en zone P.V.P");	
	}
	else if(itemID == 176)
	{
		if(IsOnGround(client))
		{
			if(rp_GetClientInt(client, i_Zone) != 777)
			{
				rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);		
				
				/*			ENTITY			*/
				float pos[3];
				GetClientAbsOrigin(client, pos);
				
				char sModel[128];
				rp_GetGlobalData("model_water", STRING(sModel));
				
				int ent = rp_CreatePhysics("", pos, NULL_VECTOR, sModel, 0, true);
				Entity_SetName(ent, steamID[client]);
				
				pos[2] += 35;
				TeleportEntity(client, pos, NULL_VECTOR, NULL_VECTOR);
				/****************************/
			
				char name[32];
				rp_GetItemData(itemID, item_name, STRING(name));				
				Format(STRING(translate), "%T", "Inventory_using", LANG_SERVER, name);
				rp_PrintToChat(client, "%s.", translate);
			}
			else 
				rp_PrintToChat(client, "Interdit de poser en zone P.V.P");	
		}		
	}
	else if(itemID == 177)
	{
		if(IsOnGround(client))
		{
			if(rp_GetClientInt(client, i_Zone) != 777)
			{
				rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);		
				
				/*			ENTITY			*/
				float pos[3];
				GetClientAbsOrigin(client, pos);
				
				char sModel[128];
				rp_GetGlobalData("model_gastank", STRING(sModel));
				
				int ent = rp_CreatePhysics("", pos, NULL_VECTOR, sModel, 0, true);
				Entity_SetName(ent, steamID[client]);
				
				pos[2] += 35;
				TeleportEntity(client, pos, NULL_VECTOR, NULL_VECTOR);
				/****************************/
			
				char name[32];
				rp_GetItemData(itemID, item_name, STRING(name));				
				Format(STRING(translate), "%T", "Inventory_using", LANG_SERVER, name);
				rp_PrintToChat(client, "%s.", translate);
			}
			else 
				rp_PrintToChat(client, "Interdit de poser en zone P.V.P");	
		}		
	}
}

public Action Timer_PlantDrill(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int target = pack.ReadCell();
	float position[3];
	position[0] = pack.ReadFloat();
	position[1] = pack.ReadFloat();
	position[2] = pack.ReadFloat();
	float clientangles[3];
	clientangles[0] = pack.ReadFloat();
	clientangles[1] = pack.ReadFloat();
	clientangles[2] = pack.ReadFloat();
	
	if(!IsValidEntity(target))
		return Plugin_Stop;
	
	EntityAlreadyHaveDrill[target] = true;
	
	char sModel[128];
	rp_GetGlobalData("model_perceuse", STRING(sModel));
	
	int ent = CreateEntityByName("prop_dynamic_override");
	DispatchKeyValue(ent, "solid", "6");
	DispatchKeyValue(ent, "model", sModel);
	DispatchSpawn(ent);
	//SDKHook(ent, SDKHook_OnTakeDamage, OnTakeDamage);
	Entity_SetName(ent, "perçeuse|%i|%i", client, target);

	TeleportEntity(ent, position, clientangles, NULL_VECTOR);
	
	rp_SoundAll(ent, "sound_drill", 0.1);
	
	rp_CreateParticle(position, "impact_physics_sparks", 10.0);
	
	DataPack pack1 = new DataPack();
	h_DrillTimer[ent] = CreateDataTimer(10.0, Timer_ExplodeEntity, pack1);
	pack1.WriteCell(client);
	pack1.WriteCell(target);
	pack1.WriteCell(ent);
	pack1.WriteFloat(position[0]);
	pack1.WriteFloat(position[1]);
	pack1.WriteFloat(position[2]);
	
	return Plugin_Stop;
}

public Action Timer_ExplodeEntity(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int target = pack.ReadCell();
	int drill = pack.ReadCell();
	float position[3];
	position[0] = pack.ReadFloat();
	position[1] = pack.ReadFloat();
	position[2] = pack.ReadFloat();
	
	if(!IsValidEntity(target) || !IsValidEntity(drill))
		return Plugin_Stop;
			
	EntityAlreadyHaveDrill[target] = false;
	
	char entModel[256], entName[64];
	Entity_GetModel(target, STRING(entModel));
	Entity_GetName(target, STRING(entName));
	
	if(StrContains(entName, "coffre") != -1)
	{
		Entity_UnLock(target);
		rp_PrintToChat(client, "Le coffre est désormais déverrouiller.");	
	}	
	
	RemoveEdict(drill);
	
	return Plugin_Stop;
}	