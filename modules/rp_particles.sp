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

/***************************************************************************************

							G L O B A L  -  V A R S

***************************************************************************************/

ArrayList
	g_aParticleList;

/***************************************************************************************

							P L U G I N  -  I N F O

***************************************************************************************/
public Plugin myinfo = 
{
	name = "Roleplay - [MODULE]Particles", 
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
	// Mark to console that this plugin is running
	PrintToServer("[MODULE] Particles ✓");
}	

public void OnMapStart()
{
	// Initialise ArraySize
	g_aParticleList = new ArrayList(128);
	
	// Load particles file and add it to array
	char sPath[PLATFORM_MAX_PATH];
	int iCount;
	BuildPath(Path_SM, STRING(sPath), "data/roleplay/particles.cfg");
	
	if(!FileExists(sPath))
		SetFailState("File not found: %s", sPath);
	
	File hFile = OpenFile(sPath, "r");
	char sBuffer[MAX_BUFFER_LENGTH + 1];
	
	if (hFile != INVALID_HANDLE)
	{
		while (hFile.ReadLine(STRING(sBuffer)))
		{
			iCount++;
			g_aParticleList.PushString(sBuffer);
		}	
		
		hFile.Close();
	}
	PrintToServer("%i particles found", iCount);
	
	char sTmp[MAX_BUFFER_LENGTH + 1];
	
	// Precache main file
	rp_GetGlobalData("main_particle", STRING(sTmp));
	if(!StrEqual(sTmp, ""))
	{
		PrecacheGeneric(sTmp, true);
		// Add file to download list
		AddFileToDownloadsTable(sTmp);
	}

	// Precache each resource inside that particle file by a arrayloop
	for (int i = 0; i < g_aParticleList.Length; i++) 
	{
		g_aParticleList.GetString(i, STRING(sTmp));
		if(!StrEqual(sTmp, ""))
			PrecacheParticleSystem(sTmp);
	}
}

/***************************************************************************************

									C L I E N T - S I D E

***************************************************************************************/