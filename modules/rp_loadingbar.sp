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

char loadingbar[MAXPLAYERS + 1][64];
float cooldown[MAXPLAYERS + 1];
Handle Timer_LoadingBar[MAXPLAYERS + 1] = { null, ... };
LOADING_TYPE type_loading[MAXPLAYERS + 1] = { LOADING_HUDMSG, ... };
/***************************************************************************************

							P L U G I N  -  I N F O

***************************************************************************************/
public Plugin myinfo = 
{
	name = "Roleplay - [MODULE]LoadingBar", 
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

public APLRes AskPluginLoad2(Handle plugin, bool late, char[] error, int err_max)
{
	RegPluginLibrary("rp_loadingbar");
	CreateNative("rp_PerformLoadingBar", Native_PerformLoadingBar);
	
	return APLRes_Success;
}

public int Native_PerformLoadingBar(Handle plugin, int numParams) 
{
	int client = GetNativeCell(1);
	type_loading[client] = GetNativeCell(2);
	char message[64];
	GetNativeString(3, STRING(message));
	int maxcubes = GetNativeCell(4);
	
	if(!IsClientValid(client))
		return -1;
	
	/*if(Timer_LoadingBar[client] != null)
		return;*/
	
	LoadingBar(client, message, maxcubes);
	
	return 0;
}

/***************************************************************************************

									C L I E N T - S I D E

***************************************************************************************/

/***************************************************************************************

									C A L L B A C K

***************************************************************************************/

stock void LoadingBar(int client, const char[] message, int maxcubes)
{
	char tmp[8];
	Format(STRING(tmp), "%i", maxcubes);	
	cooldown[client] = StringToFloat(tmp);

	DataPack pack;
	switch(type_loading[client])
	{
		case LOADING_HUDMSG:
		{
			Timer_LoadingBar[client] = CreateDataTimer(1.0, Timer_RefreshLoading, pack, TIMER_REPEAT);
			for(int i = 0; i < maxcubes; i++) 
				Format(loadingbar[client], sizeof(loadingbar[]), "%s□", loadingbar[client]);
		}	
		case LOADING_SURVIVALPANEL:
		{
			Timer_LoadingBar[client] = CreateDataTimer(0.1, Timer_RefreshLoading, pack, TIMER_REPEAT);
		}	
	}
	pack.WriteCell(client);
	pack.WriteString(message);
}	

stock Action Timer_RefreshLoading(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	char message[128];
	pack.ReadString(STRING(message));	
	
	if(!IsClientValid(client))
		return Plugin_Stop;
	
	switch(type_loading[client])
	{
		case LOADING_HUDMSG:
		{
			ReplaceStringEx(loadingbar[client], sizeof(loadingbar[]), "□", "■", -1, -1, false);
			SetHudTextParams(-1.0, -1.0, 1.0, 0, 255, 0, 255);
			ShowHudText(client, -1, "%s\n%s", message, loadingbar[client]);
			
			if(StrContains(loadingbar[client], "■") != -1 && StrContains(loadingbar[client], "□") == -1)
			{
				loadingbar[client] = "";
				TrashTimer(Timer_LoadingBar[client], true);
			}
		}	
		case LOADING_SURVIVALPANEL:
		{
			if (cooldown[client] > 0.1)
			{
				cooldown[client] -= 0.1;
				ShowPanel2(client, 2, "%s <font color='#00FF51'>%0.1f</font>", message, cooldown[client]);
				
				if(cooldown[client] <= 0.0)
				{
					cooldown[client] = 0.0;
					TrashTimer(Timer_LoadingBar[client], true);
				}
			}	
		}	
	}
	
	return Plugin_Handled;
}