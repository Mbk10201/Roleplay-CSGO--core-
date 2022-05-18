/*
*   Roleplay CS:GO de Benito est mis à disposition selon les termes de la licence Creative Commons Attribution .
* - Pas d’Utilisation Commerciale 
* - Partage dans les Mêmes Conditions 4.0 International.
*
*   Fondé(e) sur une œuvre à https://github.com/Benito1020/Roleplay-CS-GO
*   Les autorisations au-delà du champ de cette licence peuvent être obtenues à https://steamcommunity.com/id/xsuprax/.
*
*   Merci de respecter le travail fourni par le ou les auteurs 
*   https://vr-hosting.fr - benitalpa1020@gmail.com
*/

/***************************************************************************************

							C O M P I L E  -  O P T I O N S

***************************************************************************************/
#pragma semicolon 1
#pragma newdecls required

/***************************************************************************************

							P L U G I N  -  I N C L U D E S

***************************************************************************************/
#include <sourcemod>
#include <sdktools>
//#include <smlib>
#include <roleplay_csgo>
#include <multicolors>

/***************************************************************************************

							G L O B A L  -  V A R S

***************************************************************************************/

bool canDeagle[MAXPLAYERS+1];
bool nameUse[MAXPLAYERS+1];

Handle timerHud[MAXPLAYERS+1] = {null, ...};

char tempName[MAXPLAYERS+1][64];

int countItem[MAXPLAYERS+1];
int murderer;
int cop;

ConVar MurderMinParticipant;

//float event_spawn[3] = {4759.233398, 11494.939453, -2047.968750};

/***************************************************************************************

							P L U G I N  -  I N F O

***************************************************************************************/
public Plugin myinfo =
{
	name = "Roleplay - [MODULE]Event - Murder", 
	author = "Benito",
	description = "Event Murder",
	version = "1.0",
	url = "https://steamcommunity.com/id/xsuprax/"
};

/***************************************************************************************

							P L U G I N  -  E V E N T S

***************************************************************************************/
public void OnPluginStart()
{
	LoadTranslation();
	
	MurderMinParticipant = CreateConVar("rp_murder_min_players", "3", "Participant minimum pour lancer l'event murder");
	AutoExecConfig(true, "rp_event_murder");
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) {
	CreateNative("rp_InitMurder", InitEvent);
	CreateNative("rp_ShutDownMurder", ShutDownEvent);
}

public int InitEvent(Handle plugin, int numParams) 
{
	StartMurder();
}

public int ShutDownEvent(Handle plugin, int numParams) 
{
	ShutDown();
}

Action StartMurder()
{
	if(rp_GetEventNombreParticipant() >= GetConVarInt(MurderMinParticipant))
	{
		timerHud[rp_GetEventParticipants()] = CreateTimer(1.0, SurvivantHud, rp_GetEventParticipants(), TIMER_REPEAT);
		GetName(rp_GetEventParticipants());
		canDeagle[rp_GetEventParticipants()] = true;
		
		rp_SetClientBool(rp_GetEventParticipants(), b_canItem, false);
	
		//if(rp_GetEventNombreParticipant() > GetConVarInt(MurderMinParticipant))
		CreateTimer(15.0, SelectMurderer, _, TIMER_FLAG_NO_MAPCHANGE);
		CPrintToChat(rp_GetEventParticipants(), "%s L'event {darkred}Murder{default} a debuté.", TEAM);
			
		rp_InitEventMinimap("Murder");
		
		TeleportEntity(rp_GetEventParticipants(), view_as<float>(EVENT_SPAWN), NULL_VECTOR, NULL_VECTOR);
		
		rp_DeleteAllWeapon(rp_GetEventParticipants());
	}
	else
	{
		CPrintToChat(rp_GetEventParticipants(), "%s Annulation de l'event {green}Murder {default}car il n'y pas assez de participants", TEAM);
		ShutDown();
	}
}

public Action RP_OnPlayerTakeDamage(int client, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if(rp_GetEventType() == event_type_murder)
	{
		if(client != murderer
		&& attacker != murderer
		&& attacker > 0)
		{
			if(attacker == cop
			|| countItem[attacker] >= 3)
			{
				SetEntityMoveType(attacker, MOVETYPE_NONE);
				SetEntityRenderColor(attacker, 0, 128, 255, 192);
				
				ClientCommand(attacker, "r_screenoverlay effects/black.vmt");
				
				PrecacheSound("physics/glass/glass_impact_bullet4.wav", true);
				EmitSoundToAll("physics/glass/glass_impact_bullet4.wav", attacker, _, _, _, 1.0);
				
				CPrintToChat(attacker, "%s Vous avez tué un innocent.", TEAM);
				
				CPrintToChat(client, "%s Vous avez été tué par un innocent.", TEAM);
				
				CreateTimer(10.0, unFreeze, attacker);
			}
		}
		
		if(attacker > 0)
		{
			ForcePlayerSuicide(client);			
			PrecacheSound("ambient/atmosphere/thunder4.wav", true);
			EmitSoundToClient(rp_GetEventParticipants(), "ambient/atmosphere/thunder4.wav", rp_GetEventParticipants(), _, _, _, 1.0);
			
			if(client == murderer)
			{
				CPrintToChat(rp_GetEventParticipants(), "%s Le policier {gold}%N{white} a tué l'assassin {red}%N{white}.", TEAM, cop, murderer);
				int prime = GetRandomInt(500, 2500);
				rp_SetClientInt(attacker, i_Money, rp_GetClientInt(attacker, i_Money) + prime);
				CPrintToChat(attacker, "%s Vous avez gagné l'event {green} Murder et reçu %i$", TEAM, prime);
				ShutDown();				
			}
			
			if(rp_GetEventNombreParticipant() <= 1)
			{
				CPrintToChat(rp_GetEventParticipants(), "%s L'assassin {red}%N{white} remporte la victoire !", TEAM, murderer);
				int prime = GetRandomInt(500, 2500);
				rp_SetClientInt(murderer, i_Money, rp_GetClientInt(murderer, i_Money) + prime);
				CPrintToChat(murderer, "%s Vous avez gagné l'event {green} Murder et reçu %i$", TEAM, prime);
				ShutDown();
			}
		}
	}	
}

public void RP_OnPlayerDeath(int attacker, int victim, int respawnTime)
{	
	if(rp_GetEventType() == event_type_murder)
	{
		rp_SetClientBool(victim, b_isEventParticipant, false);
		
		int alive;
		LoopClients(i)
		{
			if(IsClientValid(i))
			{
				if(rp_GetClientBool(i, b_isEventParticipant))
					if(IsPlayerAlive(i))
						alive++;
			}
		}
		
		if(alive <= 1)
		{
			LoopClients(i)
			{
				if(IsClientValid(i))
				{
					if(rp_GetClientBool(i, b_isEventParticipant))
					{
						timerHud[i] = null;
						CPrintToChatAll("%s L'event Murder a été gagné par %N", TEAM, i);
						
						int prime = GetRandomInt(500, 2500);
						rp_SetClientInt(rp_GetEventParticipants(), i_Money, rp_GetClientInt(rp_GetEventParticipants(), i_Money) + prime);
						CPrintToChat(rp_GetEventParticipants(), "%s Vous avez gagné l'event {green} Murder et reçu %i$", TEAM, prime);
						
						ShutDown();
					}	
				}
			}
			
			rp_SetEventType(event_type_none);
		}	
	}	
}

public void RP_OnPlayerDisconnect(int client)
{
	if(client == murderer)
	{
		if(rp_GetEventParticipants())
		{
			CPrintToChat(rp_GetEventParticipants(), "%s L'event {darkred}Murder{default} a été annulé", TEAM);
			CPrintToChat(rp_GetEventParticipants(), "%s Le Murder s'est déconnecté.", TEAM);
						
			ShutDown();
		}	
	}	
}

int ModifySpeed(int client, float speed)
{
	if(IsClientValid(client) && IsValidEntity(client))
		SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", speed);
}

public Action RP_OnPlayerInteract(int client, int target, const char[] class, const char[] model, const char[] name)
{
	if(client == murderer)
	{
		char weaponName[64];
		Client_GetActiveWeaponName(client, weaponName, sizeof(weaponName));
		
		if(StrEqual(weaponName, "weapon_knife"))
		{
			Client_RemoveWeapon(client, weaponName);
			ModifySpeed(client, 1.0);
		}
		else
		{
			GivePlayerItem(client, "weapon_knife");
			ModifySpeed(client, 1.15);
		}
	}
	else if(client == cop)
	{
		char weaponName[64];
		Client_GetActiveWeaponName(client, weaponName, sizeof(weaponName));
		
		if(StrEqual(weaponName, "weapon_deagle"))
			Client_RemoveWeapon(client, weaponName);
		else if(canDeagle[client])
		{
			CreateTimer(2.0, GetDeagle, client);
			canDeagle[client] = false;
			
			SetEntPropFloat(client, Prop_Send, "m_flProgressBarStartTime", GetGameTime());
			SetEntProp(client, Prop_Send, "m_iProgressBarDuration", 2);
		}
	}
	else if(countItem[client] >= 3)
	{
		char weaponName[64];
		Client_GetActiveWeaponName(client, weaponName, sizeof(weaponName));
		
		if(StrEqual(weaponName, "weapon_deagle"))
			Client_RemoveWeapon(client, weaponName);
		else if(canDeagle[client])
		{
			CreateTimer(2.0, GetDeagle, client);
			canDeagle[client] = false;
			
			SetEntPropFloat(client, Prop_Send, "m_flProgressBarStartTime", GetGameTime());
			SetEntProp(client, Prop_Send, "m_iProgressBarDuration", 2);
		}
	}
	
	if(IsValidEntity(target)
	&& client != murderer
	&& client != cop
	&& countItem[client] < 3)
	{
		if(StrEqual(name, "murder_item"))
		{
			RemoveEdict(target);
			countItem[client]++;
			
			PrecacheSound("weapons/deagle/de_clipout.wav");
			EmitSoundToAll("weapons/deagle/de_clipout.wav", client, _, _, _, 1.0);
			
			if(countItem[client] == 2)
			{
				CPrintToChat(client, "%s Il vous manque 1 objet pour obtenir une arme.", TEAM);
			}
			else
			{
				CPrintToChat(client, "%s Il vous manque %i objets pour obtenir une arme.", TEAM, 3 - countItem[client]);
			}
		}
	}
}			

public Action unFreeze(Handle timer, any client)
{
	if(IsClientValid(client))
	{
		if(IsPlayerAlive(client)
		&& GetEntityMoveType(client) == MOVETYPE_NONE)
		{
			SetEntityMoveType(client, MOVETYPE_WALK);
			SetEntityRenderColor(client, 255, 255, 255, 255);
			ClientCommand(client, "r_screenoverlay 0");
		}
	}
}

public Action GetDeagle(Handle timer, any client)
{
	if(IsClientValid(client))
	{
		if(IsPlayerAlive(client))
		{
			int weapon = Client_GiveWeaponAndAmmo(client, "weapon_deagle", true, 0, 0, 1, 0);
			Entity_SetOwner(weapon, client);
		}
		
		SetEntPropFloat(client, Prop_Send, "m_flProgressBarStartTime", GetGameTime());
		SetEntProp(client, Prop_Send, "m_iProgressBarDuration", 0);
		canDeagle[client] = true;
	}
}

public Action SelectMurderer(Handle timer)
{
	LoopClients(i)
	{
		if(rp_GetClientBool(i, b_isEventParticipant))
		{			
			PrintCenterText(i, "L'ASSASSIN A ÉTÉ SÉLÉCTIONNÉ");
			
			murderer = GetRandomParticipant();
			SelectCop();
			CPrintToChatAll("Murder: %N", murderer);
			//CreateTimer(0.1, SpawnItem, _);
			canDeagle[i] = true;
		}	
	}
}

int SelectCop()
{
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientValid(i))
		{
			if(rp_GetClientBool(i, b_isEventParticipant))
			{
				cop = Client_GetRandom(i);
				if(cop == murderer)
					SelectCop();
			}
		}
	}	
}

public Action SpawnItem(Handle timer)
{
	if(IsValidEntity(murderer))
	{
		int MaxEntities = GetMaxEntities();
		char entityName[64];
		for(int X = MaxClients; X <= MaxEntities; X++)
		{
			if(IsValidEntity(X))
			{
				Entity_GetName(X, entityName, sizeof(entityName));
				if(StrEqual(entityName, "murder_item"))
					RemoveEdict(X);
			}
		}
		
		char model[64];
		float teleportOrigin[3];
		int nombre = GetRandomInt(0, 1);
		if(nombre == 0)
		{
			model = "models/props/de_tides/vending_turtle.mdl";
			teleportOrigin = view_as<float>({93.462707, 232.295867, -159.968750});
		}
		else if(nombre == 1)
		{
			model = "models/weapons/w_c4_planted.mdl";
			teleportOrigin = view_as<float>({658.977844, -198.901840, -159.968750});
		}
		
		int ent = CreateEntityByName("prop_dynamic_override");
		DispatchKeyValue(ent, "solid", "1");
		DispatchKeyValue(ent, "model", model);
		DispatchSpawn(ent);
		TeleportEntity(ent, teleportOrigin, NULL_VECTOR, NULL_VECTOR);
		Entity_SetName(ent, "murder_item");
		SetEntityRenderColor(ent, 255, 255, 128, 255);
		
		if(nombre == 0)
			nombre = 1;
		else if(nombre == 14)
			nombre = 13;
		else
			nombre += 1;
		
		if(nombre == 1)
		{
			model = "models/weapons/w_c4_planted.mdl";
			teleportOrigin = view_as<float>({658.977844, -198.901840, -159.968750});
		}
		
		ent = CreateEntityByName("prop_dynamic_override");
		DispatchKeyValue(ent, "solid", "1");
		DispatchKeyValue(ent, "model", model);
		DispatchSpawn(ent);
		TeleportEntity(ent, teleportOrigin, NULL_VECTOR, NULL_VECTOR);
		Entity_SetName(ent, "murder_item");
		SetEntityRenderColor(ent, 255, 255, 128, 255);
		
		if(rp_GetEventParticipants() >= 3)
			CreateTimer(30.0, SpawnItem, _);
	}
}

public Action SurvivantHud(Handle timer, any client)
{
	if(IsClientValid(client))
	{
		if(rp_GetEventType() == event_type_murder)
		{
			if (!rp_GetClientBool(client, b_menuOpen) && !rp_GetClientBool(client, b_isAfk))
			{
				CS_SetClientClanTag(client, "★ Innocent");
				Client_SetScore(client, 0);
				
				if(client == murderer)
				{
					int weapon = GetPlayerWeaponSlot(client, 1);
					if(weapon != -1)
						Client_RemoveWeapon(client, "weapon_deagle");
				}
				
				Panel panel = new Panel();
				char strText[128];
				
				Format(strText, sizeof(strText), "Event - Murder (%s)", VERSION);			
				panel.SetTitle(strText);			
				panel.DrawText("─────────────────────────");
				
				Format(strText, sizeof(strText), "- Pseudo : %s", tempName[client]);
				panel.DrawText(strText);	
				
				Format(strText, sizeof(strText), "- Survivants : %i", rp_GetEventNombreParticipant());
				panel.DrawText(strText);
				
				char monthname[12];
				GetMonthName(rp_GetTime(i_month), STRING(monthname));
				
				Format(STRING(strText), "%T", "Hud_Time", LANG_SERVER, rp_GetTime(i_hour1), rp_GetTime(i_hour2), rp_GetTime(i_minute1), rp_GetTime(i_minute2), rp_GetTime(i_month), monthname, rp_GetTime(i_year));
				panel.DrawText(strText);	
				
				panel.DrawText("─────────────────────────");
				panel.Send(client, Handler_NullCancel, 1);
				
				murderer = -1;
				cop = -1;
				countItem[rp_GetEventParticipants()] = 0;
				
				for(int X = 0; X <= 63; X++)
				{
					nameUse[X] = false;
				}
				
				int MaxEntities = GetMaxEntities();
				char entityName[64];
				for(int X = MaxClients; X <= MaxEntities; X++)
				{
					if(IsValidEntity(X))
					{
						Entity_GetName(X, entityName, sizeof(entityName));
						if(StrEqual(entityName, "murder_item"))
							RemoveEdict(X);
					}
				}
				
				char strFr[16];
				if(IsPlayerAlive(client))
				{
					if(murderer == client)
					{
						char weaponName[64];
						Client_GetActiveWeaponName(client, weaponName, sizeof(weaponName));
						if(StrEqual(weaponName, "weapon_knife") || StrEqual(weaponName, "weapon_fists"))
							Format(strFr, sizeof(strFr), "ranger");
						else
							Format(strFr, sizeof(strFr), "sortir");
					
						PrintHintText(client, "Vous êtes l'assassin.\nAppuyer sur utiliser pour %s votre couteau.", strFr);
					}
					else if(murderer != -1)
					{
						char weaponName[64];
						Client_GetActiveWeaponName(client, weaponName, sizeof(weaponName));
						if(StrEqual(weaponName, "weapon_deagle"))
						{
							Format(strFr, sizeof(strFr), "ranger");
						}
						else
						{
							Format(strFr, sizeof(strFr), "sortir");
						}
						
						if(client == cop)
						{
							PrintHintText(client, "Vous êtes policier.\nAppuyer sur utiliser pour %s ou recharger votre arme.", strFr);
						}
						else if(countItem[client] >= 3)
						{
							PrintHintText(client, "Vous êtes innocent.\nAppuyer sur utiliser pour %s ou recharger votre arme.", strFr);
						}
						else
						{
							PrintHintText(client, "Vous êtes innocent.\nChercher les objets pour obtenir une arme.");
						}
					}
				}
				else
				{
					if(rp_GetClientBool(client, b_isEventParticipant))
					{
						FakeClientCommand(client, "redrawhudforparticipant");
						rp_SetClientBool(client, b_isEventParticipant, false);
						TrashTimer(timerHud[client]);
					}
				}	

				int aim = GetAimEnt(client, true);
				if(IsValidEntity(aim) && IsClientValid(aim))
				{
					PrintHintText(client, "%s", tempName[aim]);
				}						
			}		
		}
		else
		{
			TrashTimer(timerHud[client]);
			timerHud[client] = null;
		}	
	}
}

public Action AimHud(Handle timer, any client)
{
	if(IsClientValid(client))
	{
		int aim = GetClientAimTarget(client, true);
		if(IsValidEntity(aim))
		{
			PrintHintText(client, "%s", tempName[aim]);
		}
	}
}

int GetName(int client)
{
	int nombre = GetRandomInt(0, 63);
	if(nameUse[nombre])
		GetName(client);
	else
	{
		if(nombre == 0)
			tempName[client] = "Aatrox";
		else if(nombre == 1)
			tempName[client] = "Ahri";
		else if(nombre == 2)
			tempName[client] = "Blitzcrank";
		else if(nombre == 3)
			tempName[client] = "Braum";
		else if(nombre == 4)
			tempName[client] = "Cho'Gath";
		else if(nombre == 5)
			tempName[client] = "Darius";
		else if(nombre == 6)
			tempName[client] = "Evelynn";
		else if(nombre == 7)
			tempName[client] = "Fizz";
		else if(nombre == 8)
			tempName[client] = "Fiddlestick";
		else if(nombre == 9)
			tempName[client] = "Galio";
		else if(nombre == 10)
			tempName[client] = "Garen";
		else if(nombre == 11)
			tempName[client] = "Gragas";
		else if(nombre == 12)
			tempName[client] = "Vayne";
		else if(nombre == 13)
			tempName[client] = "Irelia";
		else if(nombre == 14)
			tempName[client] = "Jax";
		else if(nombre == 15)
			tempName[client] = "Kha'Zix";
		else if(nombre == 16)
			tempName[client] = "Lee Sin";
		else if(nombre == 17)
			tempName[client] = "Teemo";
		else if(nombre == 18)
			tempName[client] = "Lucian";
		else if(nombre == 19)
			tempName[client] = "Lux";
		else if(nombre == 20)
			tempName[client] = "Malzahar";
		else if(nombre == 21)
			tempName[client] = "Poppy";
		else if(nombre == 22)
			tempName[client] = "Nautilus";
		else if(nombre == 23)
			tempName[client] = "Nidalee";
		else if(nombre == 24)
			tempName[client] = "Nasus";
		else if(nombre == 25)
			tempName[client] = "Olaf";
		else if(nombre == 26)
			tempName[client] = "Pantheon";
		else if(nombre == 27)
			tempName[client] = "Rammus";
		else if(nombre == 28)
			tempName[client] = "Zilean";
		else if(nombre == 29)
			tempName[client] = "Xerath";
		else if(nombre == 30)
			tempName[client] = "Renekton";
		else if(nombre == 31)
			tempName[client] = "Shen";
		else if(nombre == 32)
			tempName[client] = "Riven";
		else if(nombre == 33)
			tempName[client] = "Tryndamere";
		else if(nombre == 34)
			tempName[client] = "Thresh";
		else if(nombre == 35)
			tempName[client] = "Alistar";
		else if(nombre == 36)
			tempName[client] = "Urgot";
		else if(nombre == 37)
			tempName[client] = "Lulu";
		else if(nombre == 38)
			tempName[client] = "Varus";
		else if(nombre == 39)
			tempName[client] = "Caitlyn";
		else if(nombre == 40)
			tempName[client] = "Ashe";
		else if(nombre == 41)
			tempName[client] = "Draven";
		else if(nombre == 42)
			tempName[client] = "Twisted Fate";
		else if(nombre == 43)
			tempName[client] = "Zed";
		else if(nombre == 44)
			tempName[client] = "Jinx";
		else if(nombre == 45)
			tempName[client] = "Lissandra";
		else if(nombre == 46)
			tempName[client] = "Leona";
		else if(nombre == 47)
			tempName[client] = "Katarina";
		else if(nombre == 48)
			tempName[client] = "LeBlanc";
		else if(nombre == 49)
			tempName[client] = "Shaco";
		else if(nombre == 50)
			tempName[client] = "Kassadin";
		else if(nombre == 51)
			tempName[client] = "Vegar";
		else if(nombre == 52)
			tempName[client] = "Tristana";
		else if(nombre == 53)
			tempName[client] = "Heimerdinger";
		else if(nombre == 54)
			tempName[client] = "Jarvan IV";
		else if(nombre == 55)
			tempName[client] = "Vi";
		else if(nombre == 56)
			tempName[client] = "Karma";
		else if(nombre == 57)
			tempName[client] = "Orianna";
		else if(nombre == 58)
			tempName[client] = "Zac";
		else if(nombre == 59)
			tempName[client] = "Nunu";
		else if(nombre == 60)
			tempName[client] = "Kayle";
		else if(nombre == 61)
			tempName[client] = "Soraka";
		else if(nombre == 62)
			tempName[client] = "Ryze";
		else if(nombre == 63)
			tempName[client] = "Abassi";
		
		nameUse[nombre] = true;
	}
}

void ShutDown()
{
	LoopClients(i)
	{
		if(rp_GetClientBool(i, b_isEventParticipant))
		{
			TrashTimer(timerHud[i], true);
			rp_SetClientBool(i, b_isEventParticipant, false);
			rp_SetEventType(event_type_none);
			FakeClientCommand(i, "redrawhudforparticipant");
		}			
	}
	
	rp_SetEventType(event_type_none);
}		