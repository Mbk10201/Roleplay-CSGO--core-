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

Database g_DB;

/***************************************************************************************

							P L U G I N  -  I N F O

***************************************************************************************/
public Plugin myinfo = 
{
	name = "Roleplay - Rules Entity", 
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
	Database.Connect(GotDatabase, "roleplay");
	
	RegConsoleCmd("rp_rules", Command_Rules);
	RegConsoleCmd("rp_regles", Command_Rules);
	//RegConsoleCmd("rp_editrules", Command_EditRules);
	//RegConsoleCmd("rp_editregles", Command_EditRules);
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
		
		char buffer[2048];
		Format(STRING(buffer), 
		"CREATE TABLE IF NOT EXISTS `rp_rulesentity` ( \
		  `Id` int(20) NOT NULL AUTO_INCREMENT, \
		  `text` int(2) NOT NULL DEFAULT '1', \
		  `pos_x` float NOT NULL, \
		  `pos_y` float NOT NULL, \
		  `pos_z` float NOT NULL, \
		  `angle_x` float NOT NULL, \
		  `angle_y` float NOT NULL, \
		  `angle_z` float NOT NULL, \
		   PRIMARY KEY (`Id`), \
		   UNIQUE KEY `Id` (`Id`) \
		  )ENGINE = InnoDB DEFAULT CHARSET = utf8 COLLATE = utf8_bin;");
		db.Query(SQL_CheckForErrors, buffer);
	}
}

/***************************************************************************************

									C A L L B A C K

***************************************************************************************/

public Action Command_Rules(int client, int args)
{
	if(client == 0)
	{
		PrintToServer("%T", "Command_NotAvailable", LANG_SERVER);
		return Plugin_Handled;
	}
	
	char text[64];
	GetCmdArg(1, STRING(text));
	
	int ent = CreateEntityByName("point_worldtext");
	DispatchKeyValue(ent, "message", text);
	DispatchKeyValue(ent, "textsize", "45");
	DispatchSpawn(ent);
	ActivateEntity(ent);
	
	float eyeAngles[3], origin[3], angles[3];
	GetClientEyeAngles(client, eyeAngles);
	GetClientAbsAngles(client, angles);
	//angles[1] = eyeAngles[1] + 90.0;
	PointVision(client, origin);
	TeleportEntity(ent, origin, angles, NULL_VECTOR);	
	
	return Plugin_Handled;
}	
