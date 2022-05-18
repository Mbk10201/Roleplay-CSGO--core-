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
#define JOBID	15

/***************************************************************************************

							G L O B A L  -  V A R S

***************************************************************************************/

char steamID[MAXPLAYERS + 1][32];
Database g_DB;
bool HasOven[MAXPLAYERS + 1];
Handle Timer_Cook[MAXENTITIES + 1];

/***************************************************************************************

							P L U G I N  -  I N F O

***************************************************************************************/
public Plugin myinfo = 
{
	name = "Roleplay - [JOB] Cooker", 
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
}

public void RP_OnSQLInit(Database db, Transaction transaction)
{
	g_DB = db;
}

/***************************************************************************************

									C A L L B A C K

***************************************************************************************/

public Action canItem(Handle timer, any client)
{
	if(IsClientValid(client))
	{
		rp_PrintToChat(client, "Vous avez désormais accès aux items.");
		rp_SetClientBool(client, b_CanUseItem, true);
	}
	
	return Plugin_Handled;
}

stock Action Timer_ResetSpeed(Handle timer, int client)
{
	CheckSpeed(client);
	
	return Plugin_Handled;
}

public Action BuildingBanana_touch(int index, int client) 
{
	if(!IsClientValid(client))
		return Plugin_Continue;
	
	rp_SetClientInt(client, i_LastAgression, GetTime());
	char sound[128];
	Format(STRING(sound), "hostage/hpain/hpain%i.wav", Math_GetRandomInt(1, 6));
	EmitSoundToAll(sound, client);

	//rp_ClientDamage(client, 25, Entity_GetOwner(index));
	
	if(GetEntityFlags(client) & FL_ONGROUND) 
	{	
		int flags = GetEntityFlags(client);
		SetEntityFlags(client, (flags&~FL_ONGROUND));
		SetEntPropEnt(client, Prop_Send, "m_hGroundEntity", -1);
	}
	
	float vecVelocity[3];
	vecVelocity[0] = GetRandomFloat(400.0, 500.0);
	vecVelocity[1] = GetRandomFloat(400.0, 500.0);
	vecVelocity[2] = GetRandomFloat(600.0, 800.0);
	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vecVelocity);	
	
	AcceptEntityInput(index, "Kill");
	SDKUnhook(index, SDKHook_Touch, BuildingBanana_touch);
	
	return Plugin_Continue;
}

/***************************************************************************************

									C L I E N T - S I D E

***************************************************************************************/

public void OnClientPutInServer(int client)
{
	rp_SetClientFloat(client, fl_Faim, 5.0);
	HasOven[client] = false;
}	

public void OnClientAuthorized(int client, const char[] auth) 
{	
	strcopy(steamID[client], sizeof(steamID[]), auth);
}

public void RP_OnInventoryHandle(int client, int itemID)
{
	char translate[128];
	
	if(itemID == 101)
	{
		if(rp_GetClientFloat(client, fl_Faim) <= 100.0)
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
								
			int chance = GetRandomInt(1, 3);			
			if(chance == 2)
			{
				int random;
				LoopItems(i)
				{
					if(!rp_IsItemValidIndex(i))
						continue;
					random = GetRandomInt(1, i);
				}						
				rp_SetClientItem(client, random, rp_GetClientItem(client, random, false) + 1, false);
				
				char name_won[32];
				rp_GetItemData(random, item_name, STRING(name_won));
				Format(STRING(translate), "%T", "ItemWin", LANG_SERVER, name_won);
				rp_PrintToChat(client, "%s.", translate);

				EmitMysterySound(client);
			}	
			
			rp_SetClientFloat(client, fl_Faim, rp_GetClientFloat(client, fl_Faim) + 5.0);
			if(rp_GetClientFloat(client, fl_Faim) + 5.0 >= 100.0)
				rp_SetClientFloat(client, fl_Faim, 100.0);
			//CheckSpeed(client); TODO
			
			int random = GetRandomInt(0, 1);
			if(random == 0)
				rp_Sound(client, "sound_eat", 0.5);
			else
				rp_Sound(client, "sound_eat2", 0.5);			
			
			char name[32];
			rp_GetItemData(itemID, item_name, STRING(name));				
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);	
		}	
		else
		{
			Format(STRING(translate), "%T", "NotHunger", LANG_SERVER);
			rp_PrintToChat(client, "%s.", translate);	
		}	
	}
	else if(itemID == 102)
	{
		if(rp_GetClientFloat(client, fl_Faim) <= 100.0)
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
								
			if(Math_GetRandomInt(1, 4) == 4) 
			{
				GivePlayerItem(client, "weapon_mac10");
				EmitMysterySound(client);
			}
			else 
			{
				int ent = CreateEntityByName("chicken");
				DispatchSpawn(ent);
				float vecOrigin[3];
				GetClientAbsOrigin(client, vecOrigin);
				vecOrigin[2] += 20.0;
				TeleportEntity(ent, vecOrigin, NULL_VECTOR, NULL_VECTOR);
			}	
			
			rp_SetClientFloat(client, fl_Faim, rp_GetClientFloat(client, fl_Faim) + 10.0);
			if(rp_GetClientFloat(client, fl_Faim) + 10.0 >= 100.0)
				rp_SetClientFloat(client, fl_Faim, 100.0);
			//CheckSpeed(client); TODO
			int random = GetRandomInt(0, 1);
			if(random == 0)
				rp_Sound(client, "sound_eat",  0.5);
			else
				rp_Sound(client, "sound_eat2",  0.5);
			
			char name[32];
			rp_GetItemData(itemID, item_name, STRING(name));				
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);	
		}	
		else
		{
			Format(STRING(translate), "%T", "NotHunger", LANG_SERVER);
			rp_PrintToChat(client, "%s.", translate);	
		}	
	}
	else if(itemID == 103)
	{
		if(rp_GetClientFloat(client, fl_Faim) <= 100.0)
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);							
			
			rp_SetClientFloat(client, fl_Faim, rp_GetClientFloat(client, fl_Faim) + 15.0);
			if(rp_GetClientFloat(client, fl_Faim) + 15.0 >= 100.0)
				rp_SetClientFloat(client, fl_Faim, 100.0);
			//CheckSpeed(client); TODO
			
			if(rp_GetSpeed(client) != 1.5)
			{
				rp_SetSpeed(client, 1.5);
				CreateTimer(25.0, Timer_ResetSpeed, client);
			}	
			int random = GetRandomInt(0, 1);
			if(random == 0)
				rp_Sound(client, "sound_eat",  0.5);
			else
				rp_Sound(client, "sound_eat2",  0.5);	
			
			char name[32];
			rp_GetItemData(itemID, item_name, STRING(name));				
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);	
		}	
		else
		{
			Format(STRING(translate), "%T", "NotHunger", LANG_SERVER);
			rp_PrintToChat(client, "%s.", translate);	
		}	
	}
	else if(itemID == 104)
	{
		if(rp_GetClientFloat(client, fl_Faim) <= 100.0)
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
										
			rp_SetClientFloat(client, fl_Faim, rp_GetClientFloat(client, fl_Faim) + 5.0);
			if(rp_GetClientFloat(client, fl_Faim) + 5.0 >= 100.0)
				rp_SetClientFloat(client, fl_Faim, 100.0);
			//CheckSpeed(client); TODO
			int random = GetRandomInt(0, 1);
			if(random == 0)
				rp_Sound(client, "sound_eat",  0.5);
			else
				rp_Sound(client, "sound_eat2",  0.5);	
			
			char name[32];
			rp_GetItemData(itemID, item_name, STRING(name));				
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);	
		}	
		else
		{
			Format(STRING(translate), "%T", "NotHunger", LANG_SERVER);
			rp_PrintToChat(client, "%s.", translate);	
		}	
	}
	else if(itemID == 105)
	{
		char classname[64], classname2[64];
		Format(STRING(classname), "rp_banana_%i", client);
		int count;
		
		for (int i = MaxClients; i <= 2048; i++) 
		{
			if(!IsValidEntity(i))
				continue;			
			GetEdictClassname(i, STRING(classname2));		
			if(StrEqual(classname, classname2)) 
				count++;
		}

		if(count <= 10)
		{
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
						
			float vecOrigin[3];
			GetClientAbsOrigin(client, vecOrigin);
			
			int ent = CreateEntityByName("prop_physics_override");		
			DispatchKeyValue(ent, "classname", classname);
			DispatchKeyValue(ent, "model", "models/props/cs_italy/bananna.mdl");
			DispatchSpawn(ent);
			ActivateEntity(ent);		
			PrecacheModel("models/props/cs_italy/bananna.mdl");
			SetEntityModel(ent, "models/props/cs_italy/bananna.mdl");			
			SetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity", client);			
			//SetEntityRenderMode(ent, RENDER_NONE);			
			TeleportEntity(ent, vecOrigin, NULL_VECTOR, NULL_VECTOR);		
			Entity_SetOwner(ent, client);
			SetEntProp(ent, Prop_Data, "m_takedamage", 0);			
			ServerCommand("sm_effect_fading \"%i\" \"0.5\" \"0\"", ent);
			rp_ScheduleEntityInput(ent, 60.0, "Kill");			
			SDKHook(ent, SDKHook_StartTouch, BuildingBanana_touch);			
			
			char name[32];
			rp_GetItemData(itemID, item_name, STRING(name));				
			rp_PrintToChat(client, "%T", "Inventory_using", LANG_SERVER, name);	
		}	
		else
		{
			Format(STRING(translate), "%T", "TooManyBanana", LANG_SERVER);
			rp_PrintToChat(client, "%s.", translate);	
		}	
	}
}

public void RP_OnClientInteract(int client, int target, const char[] class, const char[] model, const char[] name)
{
	if(rp_GetNPCType(target) == JOBID)
	{
		if(Distance(client, target) <= 80.0)
			rp_PerformNPCSell(client, JOBID);
		else
		{
			char translation[64];
			Format(STRING(translation), "%T", "InvalidDistance", LANG_SERVER);
			rp_PrintToChat(client, "%s", translation);
		}
	}	
	
	if(IsEntityModelInArray(target, "model_gasstove") && rp_GetClientInt(client, i_Job) == JOBID)
	{
		if(Timer_Cook[target] == null)
		{
			MenuCook(client, target);
			PlayAnimation(target, "open");
		}
		else
			rp_PrintToChat(client, "Ce four est déjà entrain de cuire.");		
	}
}	

void MenuCook(int client, int target)
{
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_MenuCook);
	menu.SetTitle("Four de cuisson\nPréparation d'un item\n     ");
	
	char strIndex[64];
	LoopItems(i)
	{
		if(!rp_IsItemValidIndex(i))
			continue;
		
		char tmp[8];
		rp_GetItemData(i, item_jobid, STRING(tmp));	

		if(StrEqual(tmp, "15"))
		{
			char itemname[64];
			rp_GetItemData(i, item_name, STRING(itemname));		
			Format(STRING(strIndex), "%i|%i", target, i);
			menu.AddItem(strIndex, itemname);
		}
	}
	
	menu.AddItem("", "----------", ITEMDRAW_DISABLED);
	
	char entName[64];
	Entity_GetName(target, STRING(entName));
	
	Format(STRING(strIndex), "%i|delete", target);
	menu.AddItem(strIndex, "Supprimer le four", (Client_FindBySteamId(entName) == client)? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Handle_MenuCook(Menu menu, MenuAction action, int client, int param)
{
	if (action == MenuAction_Select)
	{
		char info[64], buffer[2][64];
		menu.GetItem(param, STRING(info));
		ExplodeString(info, "|", buffer, 2, 64);
		
		int target = StringToInt(buffer[0]);
		
		if(!StrEqual(buffer[1], "delete"))
		{
			int item = StringToInt(buffer[1]);
			
			PlayAnimation(target, "close");	
	
			float position[3];
			GetEntPropVector(target, Prop_Send, "m_vecOrigin", position);
			rp_CreateParticle(position, "d2d_redring", 25.0);
			
			char time[64];
			rp_GetItemData(item, item_farmtime, STRING(time));
			
			DataPack pack = new DataPack();
			Timer_Cook[target] = CreateDataTimer(StringToFloat(time), Timer_EndCook, pack);
			pack.WriteCell(client);
			pack.WriteCell(target);
			pack.WriteCell(item);
		}	
		else
		{
			RemoveEdict(target);
			HasOven[client] = false;
		}	
		
		rp_SetClientBool(client, b_DisplayHud, true);
	}
	else if (action == MenuAction_Cancel)
	{
		if (param == MenuCancel_Exit || param == MenuCancel_ExitBack)
		{
			rp_SetClientBool(client, b_DisplayHud, true);
			int target = GetClientAimTarget(client, false);
			PlayAnimation(target, "close");
		}	
	}
	else if (action == MenuAction_End)
		delete menu;

	return 0;
}

stock Action Timer_EndCook(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int target = pack.ReadCell();
	int item = pack.ReadCell();
	
	rp_SoundAll(target, "sound_ding", 1.0);
	
	char itemname[64];
	rp_GetItemData(item, item_name, STRING(itemname));
	rp_SetItemStock(item, rp_GetItemStock(item) + 1);
	rp_PrintToChat(client, "La cuisson de {lightgreen}%s {default}est fini.", itemname);
	
	Timer_Cook[target] = null;
	
	return Plugin_Handled;
}

public void RP_OnClientSpawn(int client)
{
	CheckSpeed(client);
}	

public void RP_OnClientDeath(int attacker, int victim, const char[] weapon, bool headshot)
{
	if (rp_GetClientFloat(victim, fl_Faim) == 0.0)
	{
		rp_SetClientFloat(victim, fl_Faim, 5.0);
		CPrintToChat(victim, "%s Vous devez manger pour ne pas mourir de faim !");
		PrintCenterText(victim, "Allez manger !!");
	}
}	

public void RP_ClientTimerEverySecond(int client)
{
	if(!IsClientValid(client))
	if(!rp_GetClientBool(client, b_IsAfk) && GetClientVehicle(client) == -1)
	{
		int type = GetRandomInt(1, 2); 
	
		if(rp_GetClientFloat(client, fl_Faim) == 5.0 || rp_GetClientFloat(client, fl_Faim) == 4.0 
		|| rp_GetClientFloat(client, fl_Faim) == 3.0 || rp_GetClientFloat(client, fl_Faim) == 2.0)
		{
			rp_PrintToChat(client, "Vous aller {lightred}mourir de faim{default} si vous ne mangez rien !");
		}
		
		if(rp_GetClientFloat(client, fl_Soif) == 5.0 || rp_GetClientFloat(client, fl_Soif) == 4.0
		|| rp_GetClientFloat(client, fl_Soif) == 3.0 || rp_GetClientFloat(client, fl_Soif) == 2.0)
		{
			rp_PrintToChat(client, "Vous aller {lightred}mourir de soif{default} si vous ne buvez rien !");
		}
		
		switch(type)
		{
			case 1:
			{
				if(rp_GetClientFloat(client, fl_Faim) > 0.0)
					rp_SetClientFloat(client, fl_Faim, rp_GetClientFloat(client, fl_Faim) - 0.01);
				else if(rp_GetClientFloat(client, fl_Faim) == 0.0)
				{
					ForcePlayerSuicide(client);
					rp_PrintToChat(client, "Vous êtes mort de faim\n Aller vous procurer à manger.");
					rp_SetClientFloat(client, fl_Faim, 5.0);
				}
			}
			case 2:
			{
				if(rp_GetClientFloat(client, fl_Soif) > 0.0)
					rp_SetClientFloat(client, fl_Soif, rp_GetClientFloat(client, fl_Soif) - 0.01);
				else if(rp_GetClientFloat(client, fl_Soif) == 0.0)
				{
					ForcePlayerSuicide(client);
					rp_PrintToChat(client, "Vous êtes mort de soif\n Aller vous procurer à boire.");
					rp_SetClientFloat(client, fl_Soif, 5.0);
				}
			}
		}
	}	
}		

public void RP_OnClientBuild(Menu menu, int client)
{
	if(rp_GetClientInt(client, i_Job) == JOBID)
		menu.AddItem("oven", "Four de cuisson", (HasOven[client]) ? ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
}

public void RP_OnClientBuildHandle(int client, const char[] info)
{
	if(StrEqual(info, "oven"))
	{
		char sModel[128];
		rp_GetGlobalData("model_gasstove", STRING(sModel));
		int oven = CreateEntityByName("prop_dynamic_override");
		DispatchKeyValue(oven, "solid", "6");
		DispatchKeyValue(oven, "model", sModel);
		Entity_SetName(oven, steamID[client]);
		DispatchSpawn(oven);
		
		float origin[3];
		GetClientAbsOrigin(client, origin);
		TeleportEntity(oven, origin, NULL_VECTOR, NULL_VECTOR);
		origin[2] += 70;
		TeleportEntity(client, origin, NULL_VECTOR, NULL_VECTOR);
		
		HasOven[client] = true;
	}
}

