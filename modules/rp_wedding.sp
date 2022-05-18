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
#include <sourcemod>
#include <sdktools>
#include <smlib>
#include <multicolors>
#include <roleplay_csgo.inc>

char steamID[MAXPLAYERS + 1][32];
Database g_DB;

/***************************************************************************************

							P L U G I N  -  I N F O

***************************************************************************************/
public Plugin myinfo = 
{
	name = "[Roleplay] Quests - Marriage", 
	author = "Benito", 
	description = "Système de Marriage", 
	version = "1.0", 
	url = "https://enemy-down.eu"
};

/***************************************************************************************

							P L U G I N  -  E V E N T S

***************************************************************************************/
public void OnPluginStart() 
{
	LoadTranslation();
	Database.Connect(GotDatabase, "roleplay");
	
	RegConsoleCmd("rp_mariage", Cmd_Mariage);
	RegConsoleCmd("mariage", Cmd_Mariage);
	RegConsoleCmd("marrier", Cmd_Mariage);
}

public void GotDatabase(Database db, const char[] error, any data)
{
	if (db == null)
	{
		LogError("%T", "SQL_DatabaseErrorLogin", LANG_SERVER, error);
	} 
	else 
	{
		db.SetCharset("utf8");
		g_DB = db;
		
		char buffer[4096];
		Format(STRING(buffer), 
		"CREATE TABLE IF NOT EXISTS `rp_wedding` ( \
		  `id` int(20) NOT NULL AUTO_INCREMENT, \
		  `steamid` varchar(32) COLLATE utf8_bin NOT NULL, \
		  `steamid2` varchar(32) COLLATE utf8_bin NOT NULL, \
		  `time` int(100) NOT NULL, \
		  PRIMARY KEY (`id`) \
		  )ENGINE = InnoDB DEFAULT CHARSET = utf8 COLLATE = utf8_bin;");
		db.Query(SQL_CheckForErrors, buffer);
	}	
}

public void OnClientAuthorized(int client, const char[] auth) 
{	
	strcopy(steamID[client], sizeof(steamID[]), auth);
}

public void OnClientPostAdminCheck(int client) 
{
	rp_SetClientInt(client, i_MarriedTo, 0);
	
	char query[512];
	Format(STRING(query), "SELECT `steamid` FROM `rp_wedding` WHERE `steamid2`='%s' AND `time`>=UNIX_TIMESTAMP() UNION SELECT `steamid2` FROM `rp_wedding` WHERE `steamid`='%s' AND `time`>=UNIX_TIMESTAMP();", steamID[client], steamID[client]);
	g_DB.Query(SQL_CheckWedding, query, GetClientUserId(client));
}

public void SQL_CheckWedding(Database db, DBResultSet Results, const char[] error, any data) 
{	
	int client = GetClientOfUserId(data);
	char queryID[32];
	while (Results.FetchRow()) 
	{
		Results.FetchString(0, STRING(queryID));
		
		LoopClients(i) 
		{
			if(!IsClientValid(i) || i == client)
				continue;
				
			if(StrEqual(queryID, steamID[i]) && rp_GetClientInt(i, i_MarriedTo) == 0) 
			{
				CPrintToChat(i, "%s Votre conjoint %N a rejoint la ville.", client);
				rp_PrintToChat(client, "Votre conjoint %N a rejoint la ville.", i);
				
				rp_SetClientInt(i, i_MarriedTo, client);
				rp_SetClientInt(client, i_MarriedTo, i);
			}	
		}		
	}
}

public void OnClientDisconnect(int client) 
{
	// Un mariage est terminé si un des deux mariés déco
	int mari = rp_GetClientInt(client, i_MarriedTo);
	if( mari > 0 ) 
	{
		CPrintToChat(mari, "%s Votre conjoint a quitté la ville précipitamment.");
		rp_SetClientInt(mari, i_MarriedTo, 0);
		
		rp_SetClientInt(client, i_MarriedTo, 0);
	}
}
// ----------------------------------------------------------------------------
public Action Cmd_Mariage(int client, int args) 
{	
	#if DEBUG
		PrintToServer("Command: Mariage");
	#endif	
	
	if(client == 0)
	{
		PrintToServer("%T", "NoAccessCommand", LANG_SERVER);
		return Plugin_Handled;
	}		
	else if(rp_GetClientInt(client, i_Job) != 7)
	{
		Translation_PrintNoAccess(client);
		return Plugin_Handled;
	}
	
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = Menu_Main();
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
	
	return Plugin_Handled;
}
// ----------------------------------------------------------------------------
void Marier(int juge, int epoux, int epouse) 
{	
	int pos_1 = rp_GetClientInt(juge, i_Zone);
	int prix = 10000;

	if( (rp_GetClientInt(epoux, i_Bank)+rp_GetClientInt(epoux, i_Money)) < (prix/2) || (rp_GetClientInt(epouse, i_Bank)+rp_GetClientInt(epouse, i_Money)) < (prix/2) ) 
	{
		PrintToChatZone(pos_1, "%s L'un des mariés est en fait un SDF refoulé et n'a pas assez d'argent pour s'acquitter des frais du mariage, vous pouvez huer les pauvres !");
		return;
	}
	
	PrintToChatZone(pos_1, "%s %N répond: OUI !", epouse);
	PrintToChatZone(pos_1, "%s %N et %N sont maintenant unis par les liens du mariage, vous pouvez féliciter les mariés !", epoux, epouse);
	
	CPrintToChat(epoux, "%s Vous et %N êtes unis par les liens du mariage, vous pouvez embrasser la mariée, félicitation !", epouse);
	CPrintToChat(epouse, "%s Vous et %N êtes unis par les liens du mariage, félicitations !", epoux);
	
	// On paye le gentil juge et on preleve aux heureux élus
	rp_SetClientInt(epoux, i_Money, rp_GetClientInt(epoux, i_Money) -(prix / 2));
	rp_SetClientInt(epouse, i_Money, rp_GetClientInt(epouse, i_Money) -(prix / 2));
	rp_SetClientInt(juge, i_Money, rp_GetClientInt(juge, i_Money) + prix / 2);
	rp_SetJobCapital(7, rp_GetJobCapital(7) + prix / 2);
	
	rp_SetClientInt(epoux, i_MarriedTo, epouse);
	rp_SetClientInt(epouse, i_MarriedTo, epoux);
	
	ShareKey(epoux, epoux);
	ShareKey(epouse, epoux);
	
	char query[512];
	Format(STRING(query), "INSERT INTO `rp_wedding` (`id`, `epouxID`, `epousseID`, `timestamp`) VALUES (NULL, '%s', '%s', CURRENT_TIMESTAMP);", steamID[epoux], steamID[epouse]);
	g_DB.Query(SQL_CheckForErrors, query);
	
	return;
}
// ----------------------------------------------------------------------------
void ShareKey(int client, int target) 
{
	for (int i = 1; i <= MAXAPPART; i++) 
	{
		int proprio = rp_GetAppartementInt(i, appart_owner);
		
		if(proprio == client && !rp_GetClientKeyAppartement(target, i)) 
		{
			//rp_SetClientInt(target, i_AppartCount, rp_GetClientInt(target, i_AppartCount) + 1);
			rp_SetClientKeyAppartement(target, i, true);
		}
	}

	LoopEntities(i)
	{
		if(!Vehicle_IsValid(i))
			continue;
			
		int proprio = rp_GetVehicleInt(i, car_owner);
		
		if( proprio == client && !rp_GetClientKeyVehicle(target, i)) 
		{
			rp_SetClientKeyVehicle(target, i, true);
		}
	}
}
// ----------------------------------------------------------------------------
public void OnGameFrame() 
{
	LoopClients(client)
	{
		int target = rp_GetClientInt(client, i_MarriedTo);
		
		// Si les amoureux sont proches, regen et affiche un beamring rose autours d'eux
		bool areNear = rp_IsEntitiesNear(client, target, true);
		if( areNear ) 
		{
			if(Math_GetRandomInt(0, 10) == 2) 
			{
				ShareKey(client, target);
			}
			
			ServerCommand("sm_effect_particles %d trail_heart 3", client);		
			
			if(GetClientHealth(client) < 500) 
			{
				SetEntityHealth(client, GetClientHealth(client)+5);
			}
			
			rp_Effect_BeamBox(client, target, 255, 92, 205); // Crée un laser / laser cube rose sur le/la marié(e)*/
		}
	}		
}
// ----------------------------------------------------------------------------
Menu Menu_Main() 
{
	Menu subMenu = new Menu(eventMariage);
	subMenu.SetTitle("Tribunal de Portland - Mariage\n ");
	subMenu.AddItem("0", "Marier des joueurs");
	subMenu.AddItem("1", "Prolonger un mariage");
	subMenu.AddItem("2", "Faire divorcer des joueurs");
	subMenu.AddItem("3", "Voir la durée d'un contrat de mariage");
	
	return subMenu;
}
// ----------------------------------------------------------------------------
Menu Menu_Mariage(int& client, int a, int b, int c, int d, int e, int f) 
{
	int zone = rp_GetClientInt(client, i_Zone);
	char tmp[64], tmp2[64], query[512];
	
	Menu subMenu = null;
	if(b == 0) 
	{
		
		subMenu = new Menu(eventMariage);
		subMenu.SetTitle("Qui voulez-vous marier ?\n ");
		
		LoopClients(i) 
		{
			if(!IsClientValid(i) || rp_GetClientInt(i, i_Zone) != zone)
				continue;
			if(rp_GetClientInt(i, i_MarriedTo) > 0)
				continue;
	
			Format(STRING(tmp), "0 %d %d", client, i);
			Format(STRING(tmp2), "%N", i);
			subMenu.AddItem(tmp, tmp2);
		}
	}
	else if(c == 0) 
	{
		subMenu = new Menu(eventMariage);
		subMenu.SetTitle("À qui voulez-vous marier %N?\n ", b);
		
		LoopClients(i) 
		{
			if( !IsClientValid(i) || b == i || rp_GetClientInt(i, i_Zone) != zone )
				continue;
			if( rp_GetClientInt(i, i_MarriedTo) > 0 )
				continue;
	
			Format(STRING(tmp), "0 %d %d %d", a, b, i);
			Format(STRING(tmp2), "%N", i);
			subMenu.AddItem(tmp, tmp2);
		}
	}
	else if(d == 0) 
	{
		
		GetClientAuthId(b, AuthId_Engine, tmp, sizeof(tmp));
		GetClientAuthId(c, AuthId_Engine, tmp2, sizeof(tmp2));
		
		DataPack dp = new DataPack();
		dp.WriteCell(a);
		dp.WriteCell(b);
		dp.WriteCell(c);		
		
		Format(query, sizeof(query), "SELECT `steamid` FROM `rp_wedding` WHERE (`steamid`='%s' OR `steamid2`='%s') AND `time`>=UNIX_TIMESTAMP() UNION SELECT `steamid2` FROM `rp_wedding` WHERE (`steamid`='%s' OR `steamid2`='%s') AND `time`>=UNIX_TIMESTAMP();", tmp, tmp, tmp2, tmp2);
		g_DB.Query( SQL_CheckWedding2, query, dp);
	}
	else if(d > 0) 
	{
		if(d >= 2) 
		{
			CPrintToChat(a, "%s Vous essayez d'unir quelqu'un déjà marié, le mariage ne peut pas se dérouler.");
		}
		else 
		{
			int pos_1 = rp_GetClientInt(a, i_Zone);
			int pos_2 = rp_GetClientInt(b, i_Zone);
			int pos_3 = rp_GetClientInt(c, i_Zone);
			int err = 0;
			
			// Messages d'erreurs double check
			if(pos_1 != 7) 
			{
				CPrintToChat(a, "%s Vous n'êtes pas au tribunal, le mariage ne peut pas se dérouler.");
				err++;
			}
			if(pos_1 != pos_3 || pos_2 != pos_3) 
			{
				CPrintToChat(a, "%s Tous les prétendants ne sont pas dans la même salle du tribunal, le mariage ne peut pas se dérouler.");
				err++;
			}
			if(rp_GetClientInt(b, i_MarriedTo) > 0 || rp_GetClientInt(c, i_MarriedTo) > 0) 
			{
				CPrintToChat(a, "%s Vous essayez d'unir quelqu'un déjà marié, le mariage ne peut pas se dérouler.");
				err++;
			}
			
			if(err == 0) 
			{
				PrintToChatZone(pos_1, "%s Le juge %N s'exclame: %N, voulez-vous prendre pour époux %N et l'aimer jusqu'à ce que la mort vous sépare?", a, b, c);
				
				subMenu = new Menu(eventMariage);
				
				Format(query, sizeof(query), "Voulez-vous prendre %N pour époux\n et l'aimer jusqu'à ce que la mort vous sépare ?\nLe contrat de mariage dure 7 jours et coûte 5.000$.\n ", c); 
				subMenu.SetTitle(query);
				
				Format(tmp, sizeof(tmp), "0 %d %d %d -1 1", a, b, c); subMenu.AddItem(tmp, "Oui!");
				Format(tmp, sizeof(tmp), "0 %d %d %d -1 2", a, b, c); subMenu.AddItem(tmp, "Non...");
				subMenu.ExitButton = false;
				client = b;
			}
		}
	}
	else if( e > 0 ) 
	{
		int pos_1 = rp_GetClientInt(a, i_Zone);
		
		if( e == 2 ) 
		{
			PrintToChatZone(pos_1, "%s %N répond: NON, %N fond en larmes... Stupéfaction dans la salle .", b, c);
		}
		else 
		{			
			// Messages à toute la salle
			PrintToChatZone(pos_1, "%s %N répond: OUI, les invités et %N sourient .", b, c);
			PrintToChatZone(pos_1, "%s Le juge %N s'exclame: %N, voulez-vous prendre pour épouse %N et l'aimer jusqu'à que la mort vous sépare?", a, c, b);
			
			subMenu = new Menu(eventMariage);
			
			Format(query, sizeof(query), "Voulez-vous prendre %N pour épouse\n et l'aimer jusqu'à ce que la mort vous sépare?\nLe contrat de mariage dure 7 jours et coûte 5.000$.\n ", c);
			subMenu.SetTitle(query);
			
			Format(STRING(tmp), "0 %d %d %d -1 -1 1", a, b, c); subMenu.AddItem(tmp, "Oui!");
			Format(STRING(tmp), "0 %d %d %d -1 -1 2", a, b, c); subMenu.AddItem(tmp, "Non...");
			subMenu.ExitButton = false;
			client = c;
		}
	}
	else if( f > 0 ) 
	{		
		int pos_1 = rp_GetClientInt(a, i_Zone);
		
		if( e == 2 ) 
		{
			PrintToChatZone(pos_1, "%s %N répond: NON, %N fond en larmes... Stupéfaction dans la salle .", c, b);
		}
		else 
		{
			
			int pos_2 = rp_GetClientInt(b, i_Zone);
			int pos_3 = rp_GetClientInt(c, i_Zone);
			int err = 0;
			
			// Messages d'erreurs double check
			if( pos_1 != 7) 
			{
				CPrintToChat(a, "%s Vous n'êtes pas au tribunal, le mariage ne peut pas se dérouler.");
				err++;
			}
			if( pos_1 != pos_3 || pos_2 != pos_3 ) 
			{
				CPrintToChat(a, "%s Tous les prétendant ne sont pas dans la même salle du tribunal, le mariage ne peut pas se dérouler.");
				err++;
			}
			if( err == 0 )
				Marier(a, b, c);
		}
	}
	
	return subMenu;
}
public void SQL_CheckWedding2(Handle owner, Handle handle, const char[] error, any data) 
{
	DataPack dp = view_as<DataPack>(data);
	dp.Reset();
	int a = dp.ReadCell();
	int b = dp.ReadCell();
	int c = dp.ReadCell();
	delete dp;
	
	Menu subMenu = Menu_Mariage(a, a, b, c, SQL_GetRowCount(handle) + 1, 0, 0);
	subMenu.Display(a, MENU_TIME_FOREVER);
}
// ----------------------------------------------------------------------------
Menu Menu_Prolonge(int& client, int a, int b, int c, int d, int e) 
{
	int zone = rp_GetClientInt(client, i_Zone);
	char tmp[64], tmp2[64], query[512];
	
	Menu subMenu = null;
	
	if( zone != 7 )
		return null;
	
	if( b == 0 ) 
	{
		subMenu = new Menu(eventMariage);
		subMenu.SetTitle("Qui voulez-vous prolonger le mariage ?\n ");
		int to;
		
		LoopClients(i) 
		{
			if( !IsClientValid(i) || i == client )
				continue;
			
			to = rp_GetClientInt(i, i_MarriedTo);
			
			if( to > 0 && i < to && rp_GetClientInt(i, i_Zone) == zone && rp_GetClientInt(to, i_Zone) == zone ) {
				Format(tmp, sizeof(tmp), "1 %d %d %d", client, i, to);
				Format(query, sizeof(query), "%N et %N", i, to);
				
				subMenu.AddItem(tmp, query);
				PrintToChatAll("found %N et %N", i, to);
			}
		}
	}
	else if( d == 0 ) 
	{
		subMenu = new Menu(eventMariage);
		subMenu.SetTitle("Souhaitez vous prolonger votre\n mariage avec %N?\n ", c);
		
		Format(tmp, sizeof(tmp), "1 %d %d %d 1", a, b, c); subMenu.AddItem(tmp, "Oui! (1500$)");
		Format(tmp, sizeof(tmp), "1 %d %d %d 2", a, b, c); subMenu.AddItem(tmp, "Non...");
		subMenu.ExitButton = false;
		client = b;
	}
	else if( d > 0 ) 
	{
		if( d == 1 ) 
		{
			subMenu = new Menu(eventMariage);
			subMenu.SetTitle("Souhaitez vous prolonger votre\n mariage avec %N?\n ", b);
			
			Format(tmp, sizeof(tmp), "1 %d %d %d -1 1", a, b, c); subMenu.AddItem(tmp, "Oui! (1500$)");
			Format(tmp, sizeof(tmp), "1 %d %d %d -1 2", a, b, c); subMenu.AddItem(tmp, "Non...");
			subMenu.ExitButton = false;
			client = c;
		}
		else 
		{
			PrintToChatZone(zone, "%s %N ne souhaite pas prolonger son marriage.", b);
		}
	}
	else if( e > 0 ) 
	{
		if( e == 1 ) 
		{
			
			int prix = 3000;

			if( (rp_GetClientInt(b, i_Bank)+rp_GetClientInt(b, i_Money)) < (prix/2) || (rp_GetClientInt(c, i_Bank)+rp_GetClientInt(c, i_Money)) < (prix/2) ) 
			{
				PrintToChatZone(zone, "%s L'un des mariés n'a pas assez d'argent pour prolonger son contrat de mariage.");
				return null;
			}
			
			PrintToChatZone(zone, "%s Le contrat de mariage de %N et %N est prolongé de 7 jours!", b, c);
			
			// On paye le gentil juge et on preleve aux heureux élus
			rp_SetJobCapital(101, rp_GetJobCapital(101) + (prix/2) );
			rp_SetClientInt(b, i_Money, rp_GetClientInt(b, i_Money) -(prix / 2));
			rp_SetClientInt(c, i_Money, rp_GetClientInt(c, i_Money) -(prix / 2));
			rp_SetClientInt(a, i_Money, rp_GetClientInt(a, i_Money) + prix / 2);
			rp_SetJobCapital(7, rp_GetJobCapital(7) + prix / 2);
			
			GetClientAuthId(b, AuthId_Engine, tmp, sizeof(tmp));
			GetClientAuthId(c, AuthId_Engine, tmp2, sizeof(tmp2));			
			Format(query, sizeof(query), "UPDATE `rp_wedding` SET `time`=`time`+(7*24*60*60) WHERE (`steamid`='%s' AND `steamid2`='%s') OR (`steamid`='%s' AND `steamid2`='%s')", tmp, tmp2, tmp2, tmp);
			g_DB.Query(SQL_CheckForErrors, query);
		}
		else 
		{
			PrintToChatZone(zone, "%s %N ne souhaite pas prolonger son mariage.", c);
		}
	}
	return subMenu;
}
// ----------------------------------------------------------------------------
Menu Menu_Divorce(int& client, int a, int b, int c) 
{
	int zone = rp_GetClientInt(client, i_Zone);
	char tmp[64], szSteamIDs[512], query[1024];
	
	Menu subMenu = null;
	
	if( zone != 7 )
		return null;
	
	if( b == 0 ) 
	{
		for (int i = 1; i <= MaxClients; i++) 
		{
			if( !IsClientValid(i) )
				continue;
			if( rp_GetClientInt(i, i_Zone) == zone ) 
			{
				GetClientAuthId(i, AuthId_Engine, tmp, sizeof(tmp));
				Format(szSteamIDs, sizeof(szSteamIDs), "%s'%s',", szSteamIDs, tmp);
			}
		}
		
		szSteamIDs[strlen(szSteamIDs) - 1] = 0;
		Format(query, sizeof(query), "SELECT W.`steamid`, U1.`name`, W.`steamid2`, U2.`name` FROM `rp_wedding` W INNER JOIN `rp_users` U1 ON U1.`steamid`=W.`steamid` INNER JOIN `rp_users` U2 ON U2.`steamid`=W.`steamid2` WHERE`time` >= UNIX_TIMESTAMP() AND (W.`steamid` IN (%s) OR W.`steamid2` IN (%s))", szSteamIDs, szSteamIDs);
		g_DB.Query(SQL_CheckDivorce, query, GetClientUserId(client));
	}
	else if( c == 0 ) 
	{
		
		subMenu = new Menu(eventMariage);
		subMenu.SetTitle("Souhaitez-vous rompre votre contrat de mariage?\n ");
		
		Format(tmp, sizeof(tmp), "2 %d %d 1", a, b, c); subMenu.AddItem(tmp, "Oui! (10.000$)");
		Format(tmp, sizeof(tmp), "2 %d %d 2", a, b, c); subMenu.AddItem(tmp, "Non...");
		
		client = b;
	}
	else 
	{
		if( c == 1 ) 
		{
			int prix = 10000;

			if( (rp_GetClientInt(b, i_Bank)+rp_GetClientInt(b, i_Money)) < (prix/2) ) 
			{
				PrintToChatZone(zone, "%s %N n'a pas assez d'argent pour prolonger son contrat de mariage.", b);
				return null;
			}
			
			PrintToChatZone(zone, "%s %N a rompu son contrat de mariage!", b);
			
			
			rp_SetClientInt(b, i_Money, rp_GetClientInt(b, i_Money) - prix);
			rp_SetClientInt(a, i_Money, rp_GetClientInt(b, i_Money) + (prix / 2));
			rp_SetJobCapital(7, rp_GetJobCapital(7) + (prix/2));
			
			if(rp_GetClientInt(b, i_MarriedTo) > 0) 
			{
				CPrintToChat(rp_GetClientInt(b, i_MarriedTo), "%s Votre conjoint a rompu votre contrat de mariage.");
				
				rp_SetClientInt(rp_GetClientInt(b, i_MarriedTo), i_MarriedTo, 0);
				rp_SetClientInt(b, i_MarriedTo, 0);
			}
			
			GetClientAuthId(b, AuthId_Engine, tmp, sizeof(tmp));	
			Format(query, sizeof(query), "UPDATE `rp_wedding` SET `time`=UNIX_TIMESTAMP() WHERE (`steamid`='%s' OR `steamid2`='%s') AND `time`>=UNIX_TIMESTAMP()", tmp, tmp);
			g_DB.Query(SQL_CheckForErrors, query);
		}
		else 
		{
			PrintToChatZone(zone, "%s %N ne veut pas rompre son contrat de mariage.", b);
		}
	}
	return subMenu;
}

public void SQL_CheckDivorce(Database db, DBResultSet Results, const char[] error, any data) 
{
	int client = GetClientOfUserId(data);
	
	char steamid[32], tmp[32], name[64];
	Menu subMenu = new Menu(eventMariage);
	subMenu.SetTitle("Quel couple doit divorcer?\n ");
	
	while(Results.FetchRow()) 
	{		
		for (int i = 0; i <= 1; i++) 
		{			
			Results.FetchString(i * 2, STRING(steamid));
			Results.FetchString(i == 0 ? 3 : i, STRING(name));
			
			LoopClients(j)
			{
				if(!IsClientValid(j))
					continue;
				
				GetClientAuthId(j, AuthId_Engine, STRING(tmp));
				if(StrEqual(steamid, tmp)) 
				{
					Format(STRING(tmp), "2 %d %d", client, j);
					Format(STRING(name), "%N et %s", j, name);
					subMenu.AddItem(tmp, name);
				}
			}
		}
	}
	
	subMenu.Display(client, MENU_TIME_FOREVER);
}
// ----------------------------------------------------------------------------
Menu Menu_Duration(int client, int a, int b) 
{
	int zone = rp_GetClientInt(client, i_Zone);
	char szSteamIDs[512], query[1024];
	
	if(zone != 7)
		return null;
	
	if(a == 0) 
	{	
		LoopClients(i)
		{
			if(!IsClientValid(i) || i == client)
				continue;
			if(rp_GetClientInt(i, i_Zone) == zone) 
			{
				Format(STRING(szSteamIDs), "%s'%s',", szSteamIDs, steamID[i]);
			}
		}
			
		szSteamIDs[strlen(szSteamIDs) - 1] = 0;
		Format(query, sizeof(query), "SELECT W.`steamid`, U1.`name`, W.`steamid2`, U2.`name`, W.`time` FROM `rp_wedding` W INNER JOIN `rp_users` U1 ON U1.`steamid`=W.`steamid` INNER JOIN `rp_users` U2 ON U2.`steamid`=W.`steamid2` WHERE`time` >= UNIX_TIMESTAMP() AND (W.`steamid` IN (%s) OR W.`steamid` IN (%s))", szSteamIDs, szSteamIDs);
		g_DB.Query(SQL_CheckStatus, query, GetClientUserId(client));
	}
	else {
		float j = b / (24.0 * 60.0 * 60.0);
		PrintToChatZone(zone, "%s %N est toujours marié pour une durée de %.1f jour%s.", a, j, j >= 2.0 ? "s" : "");
	}
	
	return null;
}

public void SQL_CheckStatus(Database db, DBResultSet Results, const char[] error, any data) 
{
	int client = GetClientOfUserId(data);
	int time;
	char steamid[32], tmp[32], name[64];
	Menu subMenu = new Menu(eventMariage);
	subMenu.SetTitle("Les couples dans ce Tribunal\n ");
	
	while(Results.FetchRow()) 
	{		
		for (int i = 0; i <= 1; i++) 
		{			
			Results.FetchString(i * 2, STRING(steamid));
			Results.FetchString(i == 0 ? 3 : i, STRING(name));
			time = Results.FetchInt(4) - GetTime();
			float k = time / (24.0 * 60.0 * 60.0);
			
			LoopClients(j)
			{
				if( !IsClientValid(j) )
					continue;
				
				GetClientAuthId(j, AuthId_Engine, STRING(tmp));
				if(StrEqual(steamid, tmp)) 
				{
					Format(tmp, sizeof(tmp), "3 %d %d", j, time);
					Format(name, sizeof(name), "%N et %s - %.1f jour%s", j, name, k, k >= 2.0 ? "s" : "");
					subMenu.AddItem(tmp, name);
				}
			}
		}
	}
	
	subMenu.Display(client, MENU_TIME_FOREVER);
}
// ----------------------------------------------------------------------------
public int eventMariage(Menu menu, MenuAction action, int client, int param) 
{
	if( action == MenuAction_Select ) 
	{		
		char options[128], expl[7][12];
		menu.GetItem(param, STRING(options));
		ExplodeString(options, " ", expl, 7, 12);
		
		int t = StringToInt(expl[0]);
		int a = StringToInt(expl[1]);
		int b = StringToInt(expl[2]);
		int c = StringToInt(expl[3]);
		int d = StringToInt(expl[4]);
		int e = StringToInt(expl[5]);
		int f = StringToInt(expl[6]);
		
		Menu subMenu;
		
		switch(t) 
		{
			case 0: subMenu = Menu_Mariage(client, a, b, c, d, e, f);
			case 1: subMenu = Menu_Prolonge(client, a, b, c, d, e);
			case 2: subMenu = Menu_Divorce(client, a, b, c);
			case 3: subMenu = Menu_Duration(client, a, b);
			
			default: subMenu = Menu_Main();
		}
		
		if(subMenu)
			subMenu.Display(client, MENU_TIME_FOREVER);
		
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit || param == MenuCancel_ExitBack)
			rp_SetClientBool(client, b_DisplayHud, true);
	}
	else
	{
		if(action == MenuAction_End)
			delete menu;
	}
}