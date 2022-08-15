/*
*   Roleplay CS:GO de Benito est mis à disposition selon les termes de la licence Creative Commons Attribution .
* - Pas d’Utilisation Commerciale 
* - Partage dans les Mêmes Conditions 4.0 International.
*
*   Merci de respecter le travail fourni par le ou les auteurs 
*   https://enemy-down.eu - benitalpa1020@gmail.com
*/

/***************************************************************************************

							P L U G I N  -  D E F I N E S

***************************************************************************************/
#pragma semicolon 1
#pragma newdecls required

/***************************************************************************************

										H E A D E R

***************************************************************************************/
#include <roleplay_csgo.inc>
#include <discord>

enum struct CvarData {
	ConVar footericon;
	ConVar webhook;
	ConVar thumbnail;
	ConVar image;
}
CvarData RoleplayCvar;

char playerIP[MAXPLAYERS + 1][64];
char steamID[MAXPLAYERS + 1][32];
/***************************************************************************************

							P L U G I N  -  I N F O

***************************************************************************************/
public Plugin myinfo = 
{
	name = "Roleplay - [MODULE]Discord", 
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
	LoadTranslations("discord.phrases");
	LoadTranslations("roleplay.phrases");
	
	RoleplayCvar.webhook = CreateConVar("webhook_url", "https://discordapp.com/api/webhooks/", "Discord channel webhook", FCVAR_PROTECTED);
	RoleplayCvar.footericon = CreateConVar("footer_url_icon", "", "Discord footer icon", FCVAR_PROTECTED);
	RoleplayCvar.thumbnail = CreateConVar("thumb_url", "", "Discord footer icon", FCVAR_PROTECTED);
	RoleplayCvar.image = CreateConVar("image_url", "", "Discord Bottom large image", FCVAR_PROTECTED);
	AutoExecConfig(true, "rp_discord", "roleplay");
	
	CreateTimer(720.0, Timer_AnnounceDiscord, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

public Action Timer_AnnounceDiscord(Handle timer)
{
	char webhook_url[128];
	RoleplayCvar.webhook.GetString(STRING(webhook_url));
	
	if(!StrEqual(webhook_url, ""))
	{
		DiscordWebHook hook = new DiscordWebHook(webhook_url);
		hook.SlackMode = true;	
		hook.SetUsername("Roleplay CS:GO");	
		
		MessageEmbed Embed = new MessageEmbed();
	
		char color[16];
		GetRandomColor(STRING(color));
		Embed.SetColor(color);
		
		Embed.SetTitle("ENEMY-DOWN 🧠");
		Embed.SetTitleLink("https://enemy-down.eu/");
		
		char sz_Players[64], sz_Map[128], sz_Link[128], sz_Time[64], sz_Connect[64];
		Format(STRING(sz_Players), "%i/%i", GetRealClientCount(), GetMaxHumanPlayers());
		rp_GetCurrentMap(STRING(sz_Map));
		GetServerAdress(sz_Connect, sizeof(sz_Connect));
		Format(STRING(sz_Link), "steam://connect/%s", sz_Connect);
		char monthname[32];
		GetMonthName(rp_GetTime(i_month), STRING(monthname));
		Format(STRING(sz_Time), "%i%i:%i%i %i %s %i", rp_GetTime(i_hour1), rp_GetTime(i_hour2), rp_GetTime(i_minute1), rp_GetTime(i_minute2), rp_GetTime(i_day), monthname, rp_GetTime(i_year));
		
		Embed.AddField("Joueurs", sz_Players, true);
		Embed.AddField("Map", sz_Map, true);
		Embed.AddField("Heure", sz_Time, true);
		Embed.AddField("Connexion", sz_Link, true);
		
		Embed.SetFooter("Powered by Enemy-Down.eu");
		
		char icon_url[128];
		RoleplayCvar.footericon.GetString(STRING(icon_url));
		if(!StrEqual(icon_url, ""))
			Embed.SetFooterIcon(icon_url);
				
		char thumb_url[128];
		RoleplayCvar.thumbnail.GetString(STRING(thumb_url));
		if(!StrEqual(thumb_url, ""))
			Embed.SetThumb(thumb_url);
		
		char image_url[128];
		RoleplayCvar.image.GetString(STRING(image_url));
		if(!StrEqual(image_url, ""))
		{
			int random = GetRandomInt(1, 19);
			Format(STRING(image_url), "https://enemy-down.eu/roleplay/img/rp_oregon/%i.jpg", random);
		}
		Embed.SetImage(image_url);
		
		hook.Embed(Embed);	
		hook.Send();
		delete hook;
	}	
	
	return Plugin_Handled;
}

public void OnClientAuthorized(int client, const char[] auth) 
{	
	strcopy(steamID[client], sizeof(steamID[]), auth);
	GetClientIP(client, playerIP[client], sizeof(playerIP[]));
}	

/***************************************************************************************

									N A T I V E S

***************************************************************************************/
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) 
{
	RegPluginLibrary("rp_discord");
	CreateNative("rp_LogToDiscord", Native_LogToDiscord);
	return APLRes_Success;
}

public int Native_LogToDiscord(Handle plugin, int numParams) 
{
	char message[256];
	GetNativeString(1, STRING(message));	
	Discord_Quest(STRING(message));
	
	return 0;
}

/***************************************************************************************

									C A L L B A C K

***************************************************************************************/

public void RP_OnClientSay(int client, const char[] arg)
{
	if(StrContains(arg, "@everyone", false) != -1 || StrContains(arg, "@here", false) != -1 && rp_GetAdmin(client) == ADMIN_FLAG_NONE)
	{
		rp_PrintToChat(client, "Vous n'avez pas accès au @everyone");
		return;
	}
	
	char message[256];
	Format(STRING(message), "%N: %s", client, arg);	
	Discord_Quest(STRING(message));
	
	return;
}

void Discord_Quest(char[] message, int maxlength) 
{
	char webhook_url[128];
	RoleplayCvar.webhook.GetString(STRING(webhook_url));

	if(StrContains(message, "{lightblue}") != -1)
		ReplaceString(message, maxlength, "{lightblue}", "");
	if(StrContains(message, "{darkred}") != -1)
		ReplaceString(message, maxlength, "{darkred}", "");	
	if(StrContains(message, "{orange}") != -1)
		ReplaceString(message, maxlength, "{orange}", "");		
	if(StrContains(message, "{default}") != -1)
		ReplaceString(message, maxlength, "{default}", "");	
	if(StrContains(message, "{purple}") != -1)
		ReplaceString(message, maxlength, "{purple}", "");
	
	if(!StrEqual(webhook_url, ""))
	{
		DiscordWebHook hook = new DiscordWebHook(webhook_url);
		hook.SlackMode = true;	
		hook.SetUsername("Roleplay CS:GO");	
		
		MessageEmbed Embed = new MessageEmbed();

		char color[16];
		
		Embed.SetColor(color);
		
		char hostname[128];
		FindConVar("hostname").GetString(STRING(hostname));
		
		Embed.SetTitle(hostname);
		Embed.SetTitleLink("https://enemy-down.eu/roleplay/");
		Embed.AddField("Log", message, true);
		Embed.SetFooter("Powered by Enemy-Down.eu");
		
		char icon_url[128];
		RoleplayCvar.footericon.GetString(STRING(icon_url));
		if(!StrEqual(icon_url, ""))
			Embed.SetFooterIcon(icon_url);
				
		char thumb_url[128];
		RoleplayCvar.thumbnail.GetString(STRING(thumb_url));
		if(!StrEqual(thumb_url, ""))
			Embed.SetThumb(thumb_url);
		
		char image_url[128];
		RoleplayCvar.image.GetString(STRING(image_url));
		if(StrEqual(image_url, ""))
		{
			int random = GetRandomInt(1, 19);
			Format(STRING(image_url), "https://enemy-down.eu/roleplay/img/rp_oregon/%i.jpg", random);
		}
		Embed.SetImage(image_url);
		
		hook.Embed(Embed);	
		hook.Send();
		delete hook;
	}
	else
		PrintToServer("Discord Webhook missing !");
}

static stock int GetRealClientCount()
{
	int count = 0;
	LoopClients(i)
	{
		if(IsClientValid(i)) count++;
	}

	return count;
}

void GetServerAdress(char[] buffer, int maxlen)
{
	int ip[4];
	SteamWorks_GetPublicIP(ip);
	if(SteamWorks_GetPublicIP(ip)) Format(buffer, maxlen, "%d.%d.%d.%d:%d", ip[0], ip[1], ip[2], ip[3], FindConVar("hostport").IntValue);
	else {
		int iIPB = FindConVar("hostip").IntValue;
		Format(buffer, maxlen, "%d.%d.%d.%d:%d", iIPB >> 24 & 0x000000FF, iIPB >> 16 & 0x000000FF, iIPB >> 8 & 0x000000FF, iIPB & 0x000000FF, FindConVar("hostport").IntValue);
	}
}

/***************************************************************************************

									C L I E N T - S I D E

***************************************************************************************/

/*public void RP_OnSell(int buyer, int seller, int itemID, int price, int quantity, bool payCB)
{
	char translation[64], name[64];
	GetClientName(client, STRING(name));
	Format(STRING(translation), "%T", "player_left", LANG_SERVER, name);	
	Discord_Quest(translation);
}	*/

public void RP_OnClientGetJob(int giver, int target, const char[] jobname, const char[] gradename)
{
	char client_name[64], joueur_name[64];
	GetClientName(giver, STRING(client_name));
	GetClientName(target, STRING(joueur_name));		
	
	char translation[128];
	Format(STRING(translation), "%T", "player_job", LANG_SERVER, client_name, joueur_name, gradename, jobname);	
	Discord_Quest(STRING(translation));
}

public void OnMapInit(const char[] mapName)
{
	char translation[128];
	Format(STRING(translation), "%T", "map_init", LANG_SERVER, mapName);	
	Discord_Quest(STRING(translation));
}

void GetRandomColor(char[] buffer, int maxlength)
{
	int rdm = GetRandomInt(0, 5);
	switch(rdm)
	{
		case 0:Format(buffer, sizeof(maxlength), "#64ED00");
		case 1:Format(buffer, sizeof(maxlength), "#FF5733");
		case 2:Format(buffer, sizeof(maxlength), "#3498DB");
		case 3:Format(buffer, sizeof(maxlength), "#F1C40F");
		case 4:Format(buffer, sizeof(maxlength), "#C0392B");
		case 5:Format(buffer, sizeof(maxlength), "#17202A");
	}	
}