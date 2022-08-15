/*
*   Roleplay CS:GO de Benito est mis à disposition selon les termes de la licence Creative Commons Attribution .
* - Pas d’Utilisation Commerciale 
* - Partage dans les Mêmes Conditions 4.0 International.
*
*   Merci de respecter le travail fourni par le ou les auteurs 
*   https://enemy-down.FR - benitalpa1020@gmail.com
*/

#if defined _roleplay_csgo_included_
  #endinput
#endif
#define _roleplay_csgo_included_

#define DEBUG 1
#define STRING(%1) %1, sizeof(%1)
#define LoopClients(%1)	for (int %1 = 1; %1 <= MaxClients; %1++)
#define LoopEntities(%1) for (int %1 = MaxClients +1; %1 <= MAXENTITIES; %1++)
#define LoopItems(%1)	for (int %1 = 1; %1 <= MAXITEMS; %1++)
#define vint(%1)		view_as<int>(%1)
#define vfloat(%1)		view_as<float>(%1)
#define vbool(%1)		view_as<bool>(%1)
#define vAction(%1)		view_as<Action>(%1)
#define vHandle(%1)		view_as<Handle>(%1)
#define vEvent(%1)		view_as<Event>(%1)
#define vPanel(%1)		view_as<Panel>(%1)
#define vEngine(%1)		view_as<EngineVersion>(%1)
#define HIDE_RADAR_CSGO 1<<12
#define NOTIF 			"{orange}[{lightblue}Notification{orange}]{default}"
#define API				"https://api.enemy-down.fr"
#define MAXENTITIES 	2048
#define MAXJOBS			21
#define MAXGRADES		9
#define MAXITEMS		256
#define MAXAPPART		32
#define MAXVILLA		5
#define MAXHOTEL		16
#define MAXCARS			32
#define MAXTESLA		15
#define MAXRANKS		255
#define MAXZONES		512
#define MAXDROPAMOUNT	1500
#define MAXRAISONS		16
#define MAXORGANISATION 32
#define SMIC			90

#define ZONE_RADAR			69
#define ZONE_GAS			79
#define ZONE_EVENT			777
#define ZONE_HOLDUP			89
#define ZONE_METROEVENT		778
#define ZONE_METROCITY		779
#define ZONE_PARKING		707

#define SPEAK_ICON			"materials/roleplay/icons/microphone.vmt"
#define MESSAGE_ICON		"materials/roleplay/icons/message.vmt"

#define V_PICKAXE			"models/roleplay/weapons/pickaxe/v_axe.mdl"
#define W_PICKAXE			"models/roleplay/weapons/pickaxe/w_axe.mdl"
#define DROP_PICKAXE		"models/roleplay/weapons/pickaxe/w_axe_dropped.mdl"

#define TIME_MONTH			2628000
#define TIME_WEEK			604800
#define TIME_DAY			86400
#define TIME_HOUR			3600
#define TIME_MINUTE			60

#include <cstrike>
#include <sdktools>
#include <sdkhooks>
#include <sourcemod>
#include <multicolors>
#include <smlib>
#include <unixtime_sourcemod>
#include <clientprefs>
#include <SteamWorks>
#include <geoip>
#include <basecomm>
#include <ripext>
#include <smjansson>
//#include <vphysics>
#include <collisionhook>
#include <vehicles>
#include <autoexecconfig>

#include "roleplay_csgo/enumeration.inc"
#include "roleplay_csgo/forwards.inc"
#include "roleplay_csgo/natives.inc"
#include "roleplay_csgo/methodmap.inc"
#include "roleplay_csgo/html_color.inc"
#include "roleplay_csgo/sql_utility.inc"
#include "roleplay_csgo/stocks.inc"
#include "roleplay_csgo/utils.inc"
#include "roleplay_csgo/definition.inc"
#include "roleplay_csgo/studio_hdr.inc"
#include "roleplay_csgo/translations.inc"
#include "roleplay_csgo/json.inc"