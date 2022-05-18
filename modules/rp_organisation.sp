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

										H E A D E R

***************************************************************************************/
#include <roleplay_csgo.inc>

enum struct iOrganisation_s {
	char name[64];
	char slogan[256];
	char imageurl[512];
	char skin[256];
	int members;
	StringMap memberslist;
	StringMap hierarchy;
}

iOrganisation_s iOrganisation[MAXORGANISATION + 1];

/***************************************************************************************

							P L U G I N  -  I N F O

***************************************************************************************/
public Plugin myinfo = 
{
	name = "Roleplay - [MODULE]Emoji", 
	author = "MBK", 
	description = "", 
	version = "1.0", 
	url = "https://github.com/Mbk10201"
};

/***************************************************************************************

									C A L L B A C K

***************************************************************************************/

public void OnPluginStart()
{
	RegServerCmd("test_organisation", Callback_Organisation);
}

public Action Callback_Organisation(int args)
{
	iOrganisation[0].name = "Cosa nostra";
	iOrganisation[0].slogan = "La costa nostra detruira tout sur son passsage";
	iOrganisation[0].imageurl = "https://upload.wikimedia.org/wikipedia/commons/thumb/f/f1/Pornhub-logo.svg/1024px-Pornhub-logo.svg.png";
	iOrganisation[0].skin = "models/error.mdl";
	iOrganisation[0].members = 10;
	iOrganisation[0].memberslist = new StringMap();
	iOrganisation[0].hierarchy = new StringMap();
	
	for (int i = 0; i <= 10; i++)
	{
		char sTmp[8], sName[32];
		Format(STRING(sTmp), "%i", i);
		GetRandomString(STRING(sName));
		
		iOrganisation[0].memberslist.SetString(sTmp, sName);
	}
	
	iOrganisation[0].hierarchy.SetString("Chef", "Benito");
	iOrganisation[0].hierarchy.SetString("Co-Chef", "Wiktoria");
	iOrganisation[0].hierarchy.SetString("Manageur", "Fils de pute");
	
	return Plugin_Handled;
}

void GetRandomString(char[] buffer, int maxlength)
{
	int random = GetRandomInt(0, 10);
	switch(random)
	{
		case 0:Format(buffer, maxlength, "Jackson");
	}
}