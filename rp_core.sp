/*
*   Roleplay CS:GO de Benito est mis à disposition selon les termes de la licence Creative Commons Attribution.
* - Pas d’Utilisation Commerciale 
* - Partage dans les Mêmes Conditions 4.0 International.
*
*   Merci de respecter le travail fourni par le ou les auteurs 
*   https://enemy-down.fr - benitalpa1020@gmail.com
*/

/***************************************************************************************

							C O M P I L E  -  O P T I O N S

***************************************************************************************/
#pragma semicolon 1
#pragma newdecls required

/***************************************************************************************

							P L U G I N  -  D E F I N E S

***************************************************************************************/
#define PLUGIN_VERSION "2.0"

/***************************************************************************************

										H E A D E R

***************************************************************************************/
#include <roleplay_csgo.inc>

/***************************************************************************************

							G L O B A L  -  V A R S

***************************************************************************************/
enum Auth_Method {
	AUTH_LOGIN = 0,
	AUTH_REGISTER,
}

// Get server game engine
EngineVersion g_engineversion;
// Methodmap Constructor
Roleplay m_iClient[MAXPLAYERS + 1];

enum struct IntData
{
	int Appartement;
	int AppartementCount;
	int Bank;
	int GradeID;
	int GraffitiCount;
	int GraffitiIndex;
	int GroupID;
	int JobID;
	int JailTime;
	int LastAgression;
	int LastKilled_Reverse;
	int LastDangerousShot;
	int LastVol;
	int LastVolTarget;
	int LastVolTime;
	int LastVolAmount;
	int LastVolArme;
	int KillJailDuration;
	int KitCrochetage;
	int KnifeThrow;
	int KnifeLevel;
	int MarriedTo;
	int MaxHealth;
	int MaxSelfItem;
	int Money;
	int MachineCount;
	int PlantCount;
	int TicketMetro;
	int TrashCount;
	int Salary;
	int SalaryBonus;
	int RankID;
	int VipTime;
	int VillaID;
	int ZoneVilla;
	int Zone;
	int ZoneAppartement;
	int ZoneHotel;
	int XP;
	int JailRaisonID;
	int JailID;
	int Organisation;
	int Nationality;
	int Sexe;
	int HotelID;
}
IntData RoleplayInt[MAXPLAYERS + 1];

enum struct BoolData
{
	bool HasSwissAccount;
	bool HasBankCard;
	bool HasCrowbar;
	bool HasCovidFaceMask;
	bool HasFlashLight;
	bool HasLubrifiant;
	bool HasMandate;	
	bool HasBonusHealth;
	bool HasBonusKevlar;
	bool HasBonusPay;
	bool HasBonusBox;
	bool HasBonusTomb;
	bool HasJointEffect;
	bool HasShitEffect;
	bool HasAmphetamineEffect;
	bool HasHeroineEffect;
	bool HasEcstasyEffect;
	bool HasCocainaEffect;
	bool HasSellLicence;
	bool HasCarLicence;
	bool HasPrimaryWeaponLicence;
	bool HasSecondaryWeaponLicence;
	bool HasKevlarRegen;
	bool HasHealthRegen;
	bool HasRib;
	bool HasGlovesProtection;
	bool HasCasinoAccess;
	bool HasColorPallet;
	bool IsNew;
	bool IsMuteGlobal;
	bool IsMuteLocal;
	bool IsMuteVocal;
	bool IsVip;
	bool IsAfk;
	bool IsTased;
	bool IsSearchByTribunal;
	bool IsPassive;
	bool IsThirdPerson;
	bool IsOnAduty;
	bool IsSteamMember;
	bool JoinSound;
	bool MayTalk;
	bool CanUseItem;
	bool DisplayHud;
	bool SpawnJob;
	bool TransfertItemBank;
	bool TouchedByDanceGrenade;
	bool IsWebsiteMember;
}
BoolData RoleplayBool[MAXPLAYERS + 1];

enum struct FloatData {
	float Vitality;
	float Faim;
	float Soif;
}
FloatData RoleplayFloat[MAXPLAYERS + 1];

enum struct CharData {
	char SkinModel[256];
	char FirstName[64];
	char LastName[64];
	char AdminTag[64];
	char ZoneName[64];
	char ClotheHat[64];
	char ClotheMask[64];
}
CharData RoleplayChar[MAXPLAYERS + 1];

enum struct VehicleIntData {
	int owner;
	int maxPassager;
	int price;
	int police;
	int id;
	int skinid;
	int engine;
	int insideradar;
	int wheeltype;
}
VehicleIntData RoleplayIntVehicle[MAXENTITIES + 1];

enum struct VehicleFloatData {
	float fuel;
	float maxFuel;
	float km;
	float health;
}
VehicleFloatData RoleplayFloatVehicle[MAXENTITIES + 1];

enum struct VehicleCharData {
	char brand[64];
	char serial[32];
}
VehicleCharData RoleplayCharVehicle[MAXENTITIES + 1];

enum struct AppartIntData {
	int owner;
	int price;
}
AppartIntData RoleplayIntAppart[MAXAPPART + 1];

enum struct VillaIntData {
	int owner;
	int price;
}
VillaIntData RoleplayIntVilla[MAXVILLA + 1];

enum struct HotelIntData {
	int owner;
	int price;
}
HotelIntData RoleplayIntHotel[MAXHOTEL + 1];

enum struct StatData {
	int S_MoneyEarned_Pay;
	int S_MoneyEarned_Phone;
	int S_MoneyEarned_Mission;
	int S_MoneyEarned_Sales;
	int S_MoneyEarned_Pickup;
	int S_MoneyEarned_CashMachine;
	int S_MoneyEarned_Give;
	int S_MoneySpent_Fines;
	int S_MoneySpent_Shop;
	int S_MoneySpent_Give;
	int S_MoneySpent_Stolen;
	int S_LotoSpent;
	int S_LotoWon;
	int S_DrugPickedUp;
	int S_Kills;
	int S_Deaths;
	int S_ItemUsed;
	int S_ItemUsedPrice;
	int S_TotalBuild;
	int S_RunDistance;
	int S_JobSucess;
	int S_JobFails;
	
	int Money_OnConnection;
	int MoneyEarned_Pay;
	int MoneyEarned_Phone;
	int MoneyEarned_Mission;
	int MoneyEarned_Sales;
	int MoneyEarned_Pickup;
	int MoneyEarned_CashMachine;
	int MoneyEarned_Give;
	int MoneySpent_Fines;
	int MoneySpent_Shop;
	int MoneySpent_Give;
	int MoneySpent_Stolen;
	int Vitality_OnConnection;
	int LotoSpent;
	int LotoWon;
	int DrugPickedUp;
	int Kills;
	int Deaths;
	int ItemUsed;
	int ItemUsedPrice;
	int PVP_OnConnection;
	int TotalBuild;
	int RunDistance;
	int JobSucess;
	int JobFails;
	int LastDeathTimestamp;
	int LastKillTimestamp;
}
StatData RoleplayIntStat[MAXPLAYERS + 1];

enum struct ResourceData {
	int gold;
	int steel;
	int copper;
	int aluminium;
	int zinc;
	int wood;
	int plastic;
	int water;
}
ResourceData RoleplayIntResource[MAXPLAYERS + 1];

enum struct CvarData {
	ConVar respawn;
	ConVar afk;
	ConVar token;
	ConVar zoning_type;
	ConVar fuel_price;
	ConVar cooldownvol;
	ConVar voicedistance;
	ConVar contractlupin;
	ConVar contractclassic;
	ConVar contractjustice;
	ConVar kidnapping;
	ConVar police;
	ConVar taseprinterreward;
	ConVar printermoneytimer;
	ConVar printerpapertimer;
	ConVar printermoneyamount;
	ConVar printermoneyamountv2;
	ConVar printermoneyamountv3;
	ConVar printermoneyamountmax;
	ConVar surgeryoperation;
	ConVar surgery_heart_price;
	ConVar surgery_legs_price;
	ConVar surgery_liver_price;
	ConVar surgery_lung_price;
	ConVar surgery_all_price;
	ConVar speed_limit;
	ConVar fastdl;
	ConVar website;
	ConVar discord;
	ConVar cartheory_price;
	ConVar cartheory_try_price;
	ConVar fuelprice;
	ConVar steamgroup;
}
CvarData RoleplayCvar;

enum struct SickData {
	bool fever;
	bool plague;
	bool covid;
}
SickData RoleplayBoolSick[MAXPLAYERS + 1];

enum struct SurgeryData {
	bool heart;
	bool legs;
	bool lung;
	bool liver;
}
SurgeryData RoleplayBoolSurgery[MAXPLAYERS + 1];

enum struct RankData {
	char xpreq[16];
	char name[64];
	char advantage[128];
}
RankData RoleplayCharRank[MAXRANKS + 1];

enum struct Button_Pressing {
	bool E;
	bool CTRL;
	bool R;
}	
Button_Pressing button[MAXPLAYERS + 1];

enum struct Data_Forward {
	GlobalForward OnDeath;
	GlobalForward OnFire;
	GlobalForward OnSpawn;
	GlobalForward OnFirstSpawn;
	GlobalForward OnSay;
	GlobalForward OnSayTeam;
	GlobalForward OnInteract;
	GlobalForward OnReload;
	GlobalForward OnDuck;
	GlobalForward OnTakeDamage;
	GlobalForward OnHurt;
	GlobalForward OnClientTimerSecond;
	GlobalForward OnEntityTimerSecond;
	GlobalForward OnTimerSecond;
	GlobalForward OnTimer5Second;
	GlobalForward OnFootstep;
	GlobalForward OnFirstSpawnMessage;
	GlobalForward OnLookAtTarget;
	GlobalForward OnTouch;
	GlobalForward OnEndLife;
	GlobalForward OnReduceHealth;
	GlobalForward OnRoundStart;
	GlobalForward OnClockChange;
	GlobalForward OnNewDay;
}	
Data_Forward Forward;

enum struct Cookie_Forward {
	Cookie mute;
	Cookie joinsound;
	Cookie spawnjob;
	Cookie sellmethod;
	Cookie hud_time;
	Cookie thirdperson_distance;
	Cookie casinoaccess;
	Cookie itemstorage;
	Cookie Licence_Car;
	Cookie Licence_CarTry;
	Cookie color_pallet;
}	
Cookie_Forward cookie;

enum struct TimeData {
	int hour1;
	int hour2;
	int minute1;
	int minute2;
	int day;
	int month;
	int year;
}
TimeData RoleplayTime;

enum struct Job_Data {
	char name[64];
	char doors[256];
	int capital;
	int max_grades;	
	bool cansell;
}
Job_Data job[MAXJOBS+1];

enum struct Grade_Data {
	char name[64];
	char clantag[64];
	int salary;
	char model[256];
	bool IsValid;
}
Grade_Data grade[MAXJOBS+1][MAXGRADES+1];

int 
	search,
	weapon_ammo_amount[MAXENTITIES + 1],
	g_iEntityOwner[MAXENTITIES + 1],
	g_iLightingSprite,
	g_iSmokeSprite;
ammo_type 
	weapon_ammo_type[MAXENTITIES + 1];
knife_type 
	weapon_knife_type[MAXENTITIES + 1];
admin_type 
	adminLevel[MAXPLAYERS + 1];
Event 
	DestroyHandle;
HUD_TYPE
	g_hHudType[MAXPLAYERS + 1];
bool
	Licence = false,
	asKey[MAXPLAYERS + 1][MAXENTITIES + 1],
	canDrawPanel[MAXPLAYERS + 1],
	IsValidRank[MAXRANKS],
	IsFirstSpawn[MAXPLAYERS + 1] = { false, ...},
	g_bEntityValidRP[MAXENTITIES + 1],
	g_bAuthAskUsername[MAXPLAYERS + 1],
	g_bAuthAskPassword[MAXPLAYERS + 1],
	g_bAuthAskEmail[MAXPLAYERS + 1],
	CanStartClock = false;
Handle 
	TimerAFK[MAXPLAYERS + 1] = { null, ... },
	Timer_Second = null,
	Timer_5Second = null;	
StringMap
	g_hGlobalData = null;
ArrayList
	g_aDoorsData;
float 
	g_iTimerRespawn[MAXPLAYERS + 1],
	g_fHealth[MAXENTITIES + 1];
Database 
	g_DB;
char 
	g_cServerToken[128],
	g_cLicensingServer[128],
	website[128],
	key_path[PLATFORM_MAX_PATH],
	discord[128],
	steamID[MAXPLAYERS + 1][32],
	clientIP[MAXPLAYERS + 1][32],
	g_sAuthUsername[MAXPLAYERS + 1][64],
	g_sAuthPassword[MAXPLAYERS + 1][64],
	g_sAuthEmail[MAXPLAYERS + 1][64];
KeyValues 
	key_job;
Auth_Method
	g_mAuth[MAXPLAYERS + 1] = { AUTH_LOGIN, ...};

/***************************************************************************************

							P L U G I N  -  I N F O

***************************************************************************************/
public Plugin myinfo = 
{
	name = "Roleplay - Core", 
	author = "MBK", 
	description = "Support CSS & CSGO", 
	version = "1.0", 
	url = "https://github.com/Mbk10201"
};

/***************************************************************************************

									 F U N C T I O N S

***************************************************************************************/

public void OnPluginStart()
{
	LoadTranslation();
	LoadTranslations("discord.phrases");
	LoadTranslations("rp_zones.phrases.txt");
	SetRankData();
	PrintToServer("[ROLEPLAY] Main Core Status ✓\n Build: %s", SOURCEMOD_VERSION);
	
	g_engineversion = GetEngineVersion();
	if(g_engineversion != Engine_CSS && g_engineversion != Engine_CSGO)
		SetFailState("[ROLEPLAY] GAME INAVAILABLE !");
	
	/*------------------------------------EVENT Game------------------------------------*/
	HookEvent("player_death", Event_OnDeath, EventHookMode_Post);
	HookEvent("weapon_fire", Event_OnFire, EventHookMode_Post);
	HookEvent("player_spawn", Event_OnSpawn, EventHookMode_Post);
	HookEvent("player_hurt", Event_OnHurt, EventHookMode_Post);
	//HookEvent("player_connect", Event_OnConnect, EventHookMode_Pre);
	HookEvent("player_disconnect", Event_OnDisconnect, EventHookMode_Pre);
	HookEvent("player_footstep", Event_OnFootstep, EventHookMode_Pre);
	HookEvent("round_start", Event_OnRoundStart, EventHookMode_Post);
	
	HookEvent("round_end", Event_Disable, EventHookMode_Post);
	if(g_engineversion != Engine_CSS)
	{
		HookEvent("cs_match_end_restart", Event_Disable, EventHookMode_PostNoCopy);
		HookEvent("cs_intermission", Event_Disable, EventHookMode_PostNoCopy);
		HookEvent("round_announce_warmup", Event_Disable, EventHookMode_PostNoCopy);
		HookEvent("announce_phase_end", Event_Disable, EventHookMode_PostNoCopy);
		HookEvent("buytime_ended", Event_Disable, EventHookMode_PostNoCopy);
		HookEvent("weapon_outofammo", Event_Disable, EventHookMode_Pre);
		HookEvent("decoy_firing", Event_Disable, EventHookMode_Post);
		HookEvent("decoy_detonate", Event_Disable, EventHookMode_Post);
	}
	HookEvent("teamplay_round_start", Event_Disable, EventHookMode_PostNoCopy);
	HookEvent("player_team", Event_Disable, EventHookMode_Pre);	
	HookEvent("player_changename", Event_Disable, EventHookMode_Pre);
	HookEvent("weapon_fire_on_empty", Event_Disable, EventHookMode_Pre);
	/*----------------------------------------------------------------------------------*/
	
	/*----------------------------------EVENT Commands-------------------------------*/
	AddCommandListener(Listener_Radio, "player_radio");
	AddCommandListener(Listener_Say, "say");
	AddCommandListener(Listener_Say, "say_team");
	HookUserMessage(GetUserMessageId("SayText2"), BlockSayText2, true);
	HookUserMessage(GetUserMessageId("TextMsg"), BlockTextMsg, true);
	HookUserMessage(GetUserMessageId("KillCam"), BlockKillCam, true);
	/*-------------------------------------------------------------------------------*/
	
	/*----------------------------------Commands-------------------------------*/
	RegConsoleCmd("jointeam", Command_Block);
	RegConsoleCmd("explode", Command_Block);
	RegConsoleCmd("kill", Command_Block);
	RegConsoleCmd("coverme", Command_Block);
	RegConsoleCmd("takepoint", Command_Block);
	RegConsoleCmd("holdpos", Command_Block);
	RegConsoleCmd("regroup", Command_Block);
	RegConsoleCmd("followme", Command_Block);
	RegConsoleCmd("takingfire", Command_Block);
	RegConsoleCmd("go", Command_Block);
	RegConsoleCmd("fallback", Command_Block);
	RegConsoleCmd("sticktog", Command_Block);
	RegConsoleCmd("cheer", Command_Block);
	RegConsoleCmd("compliment", Command_Block);
	RegConsoleCmd("thanks", Command_Block);
	RegConsoleCmd("getinpos", Command_Block);
	RegConsoleCmd("stormfront", Command_Block);
	RegConsoleCmd("report", Command_Block);
	RegConsoleCmd("roger", Command_Block);
	RegConsoleCmd("enemyspot", Command_Block);
	RegConsoleCmd("needbackup", Command_Block);
	RegConsoleCmd("sectorclear", Command_Block);
	RegConsoleCmd("inposition", Command_Block);
	RegConsoleCmd("reportingin", Command_Block);
	RegConsoleCmd("getout", Command_Block);
	RegConsoleCmd("negative", Command_Block);
	RegConsoleCmd("enemydown", Command_Block);

	RegConsoleCmd("me", Message_Annonce);
	RegConsoleCmd("annonce", Message_Annonce);

	RegConsoleCmd("c", Message_Colocataire);
	RegConsoleCmd("coloc", Message_Colocataire);
	RegConsoleCmd("colloc", Message_Colocataire);

	RegConsoleCmd("t", Message_Team);
	RegConsoleCmd("team", Message_Team);	

	RegConsoleCmd("m", Message_Couple);
	RegConsoleCmd("marie", Message_Couple);	

	RegConsoleCmd("g", Message_Groupe);
	RegConsoleCmd("group", Message_Groupe);
	RegConsoleCmd("groupe", Message_Groupe);	

	RegConsoleCmd("a", Message_Admin);
	RegConsoleCmd("admin", Message_Admin);

	RegConsoleCmd("rp_auth", Command_Auth);
		
	/*-------------------------------------------------------------------------------*/
	
	/*----------------------------------ConVars-------------------------------*/
	RoleplayCvar.respawn = CreateConVar("rp_respawn", "10.0", "Timer to respawn.");
	RoleplayCvar.afk = CreateConVar("rp_afk", "300", "Time to be AFK");
	RoleplayCvar.token = CreateConVar("rp_token", "XXXXXXXXXXXXXXXXXXXXXXXXXXX", "Token given with the software");
	RoleplayCvar.fuel_price = CreateConVar("rp_fuel_price", "15", "Prix du carburant par litre");
	RoleplayCvar.cooldownvol = CreateConVar("rp_cooldown_vol", "10.0", "Timer to steal.");
	RoleplayCvar.voicedistance = CreateConVar("rp_voice_distance", "500", "Distance de voix maximale");
	RoleplayCvar.contractlupin = CreateConVar("rp_contractlupin_price", "1750", "Price contract lupin");
	RoleplayCvar.contractclassic = CreateConVar("rp_contractclassic_price", "750", "Price contract classic");
	RoleplayCvar.contractjustice = CreateConVar("rp_contractjustice_price", "2500", "Price contract justice");
	RoleplayCvar.kidnapping = CreateConVar("rp_contractkidnapping_price", "4000", "Price contract kidnapping");
	RoleplayCvar.police = CreateConVar("rp_contractpolice_price", "1000", "Price contract police");
	RoleplayCvar.taseprinterreward = CreateConVar("rp_tase_printer", "500", "Recompense lors d'un tase printer");	
	RoleplayCvar.printermoneytimer = CreateConVar("rp_printer_timer", "10.0", "Temps avant la recompense de l'argent");
	RoleplayCvar.printerpapertimer = CreateConVar("rp_printerpaper_timer", "3600.0", "Temps avant la recompense de l'argent");
	RoleplayCvar.printermoneyamount = CreateConVar("rp_printer_cash", "3", "Montant de la recompense sans mise à jour");
	RoleplayCvar.printermoneyamountv2 = CreateConVar("rp_printer_cash_v2", "5", "Montant de la recompense mise à jour v2.0");
	RoleplayCvar.printermoneyamountv3 = CreateConVar("rp_printer_cash_v3", "10", "Montant de la recompense mise à jour v3.0");
	RoleplayCvar.printermoneyamountmax = CreateConVar("rp_printer_cash_max", "500", "Montant max de la liasse sans compte en suisse");
	RoleplayCvar.surgeryoperation = CreateConVar("rp_surgerytime", "10.0", "Surgery cooldown before the patient got the final result");
	RoleplayCvar.surgery_heart_price = CreateConVar("surgery_heart_price", "1500", "Prix de l'opération coeur");
	RoleplayCvar.surgery_legs_price = CreateConVar("surgery_legs_price", "1500", "Prix de l'opération pieds");
	RoleplayCvar.surgery_liver_price = CreateConVar("surgery_liver_price", "1500", "Prix de l'opération foi");
	RoleplayCvar.surgery_lung_price = CreateConVar("surgery_lung_price", "1500", "de l'opération poumons");
	RoleplayCvar.surgery_all_price = CreateConVar("surgery_all_price", "6000", "Prix de toutes les opérations");
	RoleplayCvar.zoning_type = CreateConVar("rp_zonetype", "0", "0 = Default map zones | 1 = zones.cfg loaded from files | 2 = both, map zones & loaded zones");
	RoleplayCvar.speed_limit = CreateConVar("rp_speed_limit", "50", "Max speed limit, if driver increased the limit, he will receive a ticket.");
	RoleplayCvar.fastdl = CreateConVar("rp_fastdl", "https://fastdl.enemy-down.fr/", "Custom file downloading server.");
	RoleplayCvar.website = CreateConVar("rp_website", "https://enemy-down.fr/", "Main website of the server.");
	RoleplayCvar.discord = CreateConVar("rp_discord", "https://discord.gg/CPqVNu5jQj", "Discord invitation url.");
	RoleplayCvar.cartheory_price = CreateConVar("rp_cartheory_price", "2500", "Prix de la théorie voiture.");
	RoleplayCvar.cartheory_try_price = CreateConVar("rp_cartheory_try_price", "2500", "Prix de la théorie si jamais raté 2x.");
	RoleplayCvar.fuelprice = CreateConVar("rp_fuelprice", "50", "Prix du Litre de carburant en $");
	RoleplayCvar.steamgroup = CreateConVar("rp_steamgroup", "103582791469817578", "ID 64 de votre groupe steam. (/memberslistxml/?xml=1) Ajouter ceci a votre lien de groupe steam pour récuperer votre ID.");
	RoleplayCvar.discord.GetString(STRING(discord));
	RoleplayCvar.website.GetString(STRING(website));
	
	CreateConVar("rp_version", PLUGIN_VERSION, "Roleplay Version", FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	AutoExecConfig(true, "rp_core", "roleplay");
	/*------------------------------------------------------------------------*/
	
	/*----------------------------------Cookies-------------------------------*/
	cookie.mute = new Cookie("rpv_mute", "Mute [ON / OFF]", CookieAccess_Protected);
	cookie.joinsound = new Cookie("rpv_joinsound", "Join sound [ON / OFF]", CookieAccess_Public);
	cookie.spawnjob = new Cookie("rpv_spawnjob", "Spawn H.Q [ON / OFF]", CookieAccess_Public);
	cookie.sellmethod = new Cookie("rpv_sellmethod", "Transfert d'item acheté en banque [ON / OFF]", CookieAccess_Public);
	cookie.hud_time = new Cookie("rpv_hud_time", "Position de l'hud temps [1 = H/G | 2 = BAS ]", CookieAccess_Public);
	cookie.thirdperson_distance = new Cookie("rpv_thirdperson_distance", "Position de la camera 3ème personne.", CookieAccess_Public);
	cookie.casinoaccess = new Cookie("rpv_casinoextra", "Est-ce que le jouer a accèss ou pas au casino.", CookieAccess_Public);
	cookie.itemstorage = new Cookie("rpv_itemstorage", "Max d'emplacement de stockage d'item sur sois.", CookieAccess_Public);
	cookie.Licence_Car = new Cookie("rpv_licence_car", "Permis voitures [ON / OFF]", CookieAccess_Protected);
	cookie.Licence_CarTry = new Cookie("rpv_licence_carTry", "Driving licence (X times didnt passed)", CookieAccess_Protected);
	cookie.color_pallet = new Cookie("rpv_color_pallet", "Has color pallet to allow chat colors (MESSAGE & NAME)", CookieAccess_Protected);
	/*------------------------------------------------------------------------*/	

	/*----------------------------------Directory-------------------------------*/
	char map[64];
	rp_GetCurrentMap(STRING(map));
		
	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, STRING(sPath), "data/roleplay/%s", map);
	if(!DirExists(sPath))
		CreateDirectory(sPath, 0o777);
	
	BuildPath(Path_SM, STRING(sPath), "data/roleplay/json");
	if(!DirExists(sPath))
		CreateDirectory(sPath, 0o777);
	/*------------------------------------------------------------------------*/
	
	/*----------------------------------KeyValue-------------------------------*/
	// JOBS REGISTER ALL IN VAR
	key_job = new KeyValues("Jobs");
	BuildPath(Path_SM, STRING(key_path), "data/roleplay/jobs.cfg");
	Kv_CheckIfFileExist(key_job, key_path);
	
	// Jump into the first subsection
	if (!key_job.GotoFirstSubKey())
	{
		PrintToServer("ERROR FIRST KEY");
		delete key_job;
		return;
	}
	
	char buffer[32];
	int id;
	do {
		if(key_job.GetSectionName(STRING(buffer)))
		{
			id = StringToInt(buffer);
			key_job.GetString("jobname", job[id].name, sizeof(job[].name));
			job[id].capital = key_job.GetNum("capital");
			job[id].max_grades = key_job.GetNum("grades");
			job[id].cansell = vbool(key_job.GetNum("cansell"));
			
			PrintToServer("[%s] %s \n <------------->", buffer, job[id].name);
			
			for(int i = 1; i <= job[id].max_grades; i++)
			{
				char tmp[8];
				IntToString(i, STRING(tmp));
				key_job.JumpToKey(tmp);
				key_job.GetString("grade", grade[id][i].name, sizeof(grade[][].name));
				key_job.GetString("clantag", grade[id][i].clantag, sizeof(grade[][].clantag));
				grade[id][i].salary = key_job.GetNum("salary");
				grade[id][i].IsValid = true;
				key_job.GetString("model", grade[id][i].model, sizeof(grade[][].model));
				
				PrintToServer("[GRADE %i] %s", i, grade[id][i].name);
				
				key_job.GoBack();
			}
		}	
	}	
	while (key_job.GotoNextKey());
	key_job.Rewind();
	
	/*-------------------------------------------------------------------------*/
	
	SteamWorks_SetGameDescription("Roleplay");
	
	/*if(SteamWorks_IsVACEnabled())
		SetFailState("[RP] VAC IS ENABLED, In Order to run the mode completely you need to disable vac");*/
		
	/*-------------------------------------------------------------------------*/
}

public void OnPluginEnd()
{
	SQL_Request(g_DB, "UPDATE `rp_time` SET `hour1` = '%i', `hour2` = '%i', `day` = '%i', `month` = '%i', `year` = '%i' WHERE `id` = '0';", rp_GetTime(i_hour1), rp_GetTime(i_hour2), rp_GetTime(i_day), rp_GetTime(i_month), rp_GetTime(i_year));
}

public void RP_OnSQLInit(Database db, Transaction transaction)
{
	g_DB = db;
	
	char sBuffer[MAX_BUFFER_LENGTH + 1];
	
	Format(STRING(sBuffer), "CREATE TABLE IF NOT EXISTS `rp_time` ( \
		  `hour1` int(2) NOT NULL, \
		  `hour2` int(1) NOT NULL, \
		  `day` int(2) NOT NULL, \
		  `month` int(2) NOT NULL, \
		  `year` int(4) NOT NULL \
		  )ENGINE = InnoDB DEFAULT CHARSET = utf8 COLLATE = utf8_bin;");
	#if DEBUG
		PrintToServer(sBuffer);
	#endif
	transaction.AddQuery(sBuffer);
	
	LoadClock();
}	

void LoadClock()
{
	int iYear, iMonth, iDay, iHour, iMinute, iSecond;
	UnixToTime(GetTime(), iYear, iMonth, iDay, iHour, iMinute, iSecond, UT_TIMEZONE_CEST);
	
	SQL_Request(g_DB, "INSERT IGNORE INTO `rp_time` (`hour1`, `hour2`, `day`, `month`, `year`) VALUES ('0', '0', '%i', '%i', '%i');", iDay, iMonth, iYear);
	
	char buffer[512];
	Format(STRING(buffer), "SELECT * FROM `rp_time`;");
	g_DB.Query(SQL_GetTime, buffer);
}

public void SQL_GetTime(Database db, DBResultSet Results, const char[] error, any data) 
{	
	if (Results.FetchRow()) 
	{
		rp_SetTime(i_hour1, SQL_FetchIntByName(Results, "hour1"));
		rp_SetTime(i_hour2, SQL_FetchIntByName(Results, "hour2"));
		rp_SetTime(i_day, SQL_FetchIntByName(Results, "day"));
		rp_SetTime(i_month, SQL_FetchIntByName(Results, "month"));
		rp_SetTime(i_year, SQL_FetchIntByName(Results, "year"));
		
		CanStartClock = true;
	}
}

public void LoadTokenSoftware() 
{
	RoleplayCvar.token.GetString(STRING(g_cServerToken));
	
	BuildServerIp(STRING(g_cLicensingServer));	
	HTTP_GetLicence();
}

public Action HTTP_GetLicence()
{
	char sUrl[256] = "https://api.community-infinity.fr/licence";
	
	Format(STRING(sUrl), "%s/%s&%s", sUrl, g_cLicensingServer, g_cServerToken);
	
	Handle Request = SteamWorks_CreateHTTPRequest(k_EHTTPMethodGET, sUrl);

	//Set timeout to 10 seconds
	bool setnetwork = SteamWorks_SetHTTPRequestNetworkActivityTimeout(Request, 10);
	
	//SteamWorks thing, set context value so we know what call we sent for the callback.
	bool setcontext = SteamWorks_SetHTTPRequestContextValue(Request, 5);
	
	//Set callback function to get response data
	bool setcallback = SteamWorks_SetHTTPCallbacks(Request, getCallback);

	if(!setnetwork /*|| !setparam || !setparam2*/ || !setcontext || !setcallback) {
        PrintToServer("Error in setting request properties, cannot send request");
        CloseHandle(Request);
        return Plugin_Handled;
    }

    //Initialize the request.
	bool sentrequest = SteamWorks_SendHTTPRequest(Request);
	if(!sentrequest) {
		PrintToServer("Error in sending request, cannot send request");
		CloseHandle(Request);
		return Plugin_Handled;
	}

	//Send the request to the front of the queue
	SteamWorks_PrioritizeHTTPRequest(Request);
	return Plugin_Handled;
}

void getCallback(Handle hRequest, bool bFailure, bool bRequestSuccessful, EHTTPStatusCode eStatusCode, any data1) 
{
	if(!bRequestSuccessful) {
	    PrintToServer("There was an error in the request");
	    delete hRequest;
	}
	
	if(eStatusCode == k_EHTTPStatusCode202Accepted) {
	    PrintToServer("The request returned new data, http code 202");
	    delete hRequest;
	} 
	else if(eStatusCode == k_EHTTPStatusCode304NotModified) 
	{
		PrintToServer("The request did not return new data, but did not error, http code 304");
		delete hRequest;
		return;
	} 
	else if(eStatusCode == k_EHTTPStatusCode404NotFound) 
	{
		Licence = false;
		
		PrintToServer("The requested URL could not be found, http code 404");
		delete hRequest;
		return;
	} 
	else if(eStatusCode == k_EHTTPStatusCode500InternalServerError) 
	{
	    PrintToServer("The requested URL had an internal error, http code 500");
	    delete hRequest;
	    return;
	    
	} 
	else if(eStatusCode == k_EHTTPStatusCode200OK)
	{
		Licence = true;
		char token[128];
		RoleplayCvar.token.GetString(STRING(token));
		PrintToServer("-------------------------------------------");
		PrintToServer("----- Licensing Server: %s -----", g_cLicensingServer);
		PrintToServer("----- Found License: %s -----", token);
		PrintToServer("-------------------------------------------");
		PrintToServer("-------- Received License Response --------");
		PrintToServer("> Succes <");
		PrintToServer("-------------------------------------------");
		delete hRequest;
		return;
	}
	else 
	{
		char errmessage[128];
		Format(errmessage, 128, "The requested returned with an unexpected HTTP Code %d", eStatusCode);
		PrintToServer(errmessage);
		delete hRequest;
		return;
	}

	delete hRequest;
}

public void OnMapStart()
{
	LoadTokenSoftware();
	
	FindConVar("sv_allowdownload").SetInt(1);	
	FindConVar("sv_allowupload").SetInt(1);
	FindConVar("sv_hibernate_when_empty").SetInt(1);
	
	if(g_engineversion != Engine_CSS)
	{
		FindConVar("sv_show_team_equipment_prohibit").SetInt(1);	
		FindConVar("sv_teamid_overhead_always_prohibit").SetInt(1);	
		FindConVar("sv_teamid_overhead_maxdist").SetInt(1);	
		FindConVar("sv_ignoregrenaderadio").SetInt(1);	
		FindConVar("mp_teamname_1").SetString("Gouvernement");
		FindConVar("mp_teamname_2").SetString("Citoyens");
		FindConVar("mp_teammates_are_enemies").SetInt(1);
		FindConVar("spec_replay_enable").SetInt(0);
		FindConVar("mp_forcecamera").SetInt(2);	
		
		FindConVar("sv_allow_thirdperson").BoolValue = true;
		SteamWorks_SetGameDescription("CSGO ROLEPLAY");
		
		char sMap[64];
		rp_GetCurrentMap(STRING(sMap));
		SteamWorks_SetMapName(sMap);
		
		ShowPanel2(0, 1, "<img src='https://panel.enemy-down.fr/themes/Obsidian/images/logo.png'>");
	}	
	else
	{
		SteamWorks_SetGameDescription("CSS ROLEPLAY");		
	}
	
	g_iLightingSprite = PrecacheModel("sprites/lgtning.vmt"); 
	g_iSmokeSprite = PrecacheModel("sprites/steam1.vmt");
	
	CreateTimer(320.0, AutoMessages, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	Timer_Second = CreateTimer(1.0, Timer_EverySecond, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	Timer_5Second = CreateTimer(5.0, Timer_Every5Second, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);

	//SetWorldTextJob();

	/*----------------------------------Files-------------------------------*/
	char map[64], tmp[256];
	rp_GetCurrentMap(STRING(map));
	
	// Map Verification
	if(StrContains(map, "rp_") == -1)
		SetFailState("[MAP] Can't load plugin on %s, use only roleplay maps.", map);
	
	KeyValues kv;
	
	BuildPath(Path_SM, STRING(tmp), "data/roleplay/%s/locations.cfg", map);
	kv = new KeyValues("Locations");
	if(!FileExists(tmp))
	{
		kv.JumpToKey("appartment", true);
		kv.GoBack();
		kv.JumpToKey("villa", true);
		kv.GoBack();
		kv.JumpToKey("hotel", true);
		
		kv.Rewind();
		
		if(kv.ExportToFile(tmp)) 
		{
			char message[128];
			Format(STRING(message), "Nouveau fichier: %s", tmp);
			rp_LogToDiscord(message);
		}
	}
	delete kv;
	
	BuildPath(Path_SM, STRING(tmp), "data/roleplay/%s/jails.cfg", map);
	kv = new KeyValues("Jails");
	if(!FileExists(tmp))
	{
		if(kv.ExportToFile(tmp)) 
		{
			char message[128];
			Format(STRING(message), "Nouveau fichier: %s", tmp);
			rp_LogToDiscord(message);
		}
	}	
	delete kv;
	
	BuildPath(Path_SM, STRING(tmp), "data/roleplay/%s/out.cfg", map);
	kv = new KeyValues("Out");
	if(!FileExists(tmp))
	{
		if(kv.ExportToFile(tmp)) 
		{
			char message[128];
			Format(STRING(message), "Nouveau fichier: %s", tmp);
			rp_LogToDiscord(message);
		}
	}	
	delete kv;
	
	BuildPath(Path_SM, STRING(tmp), "data/roleplay/%s/rules_entity.cfg", map);
	kv = new KeyValues("Rules");
	if(!FileExists(tmp))
	{
		if(kv.ExportToFile(tmp)) 
		{
			char message[128];
			Format(STRING(message), "Nouveau fichier: %s", tmp);
			rp_LogToDiscord(message);
		}
	}	
	delete kv;
	
	BuildPath(Path_SM, STRING(tmp), "data/roleplay/%s/spawn.cfg", map);
	kv = new KeyValues("Spawn");
	if(!FileExists(tmp))
	{
		kv.JumpToKey("job", true);
		
		kv.Rewind();
		
		if(kv.ExportToFile(tmp)) 
		{
			char message[128];
			Format(STRING(message), "Nouveau fichier: %s", tmp);
			rp_LogToDiscord(message);
		}
	}	
	delete kv;
	
	BuildPath(Path_SM, STRING(tmp), "data/roleplay/%s/tutorial.cfg", map);
	kv = new KeyValues("Tutorial");
	if(!FileExists(tmp))
	{
		if(kv.ExportToFile(tmp)) 
		{
			char message[128];
			Format(STRING(message), "Nouveau fichier: %s", tmp);
			rp_LogToDiscord(message);
		}
	}	
	delete kv;
	
	BuildPath(Path_SM, STRING(tmp), "data/roleplay/%s/zones.cfg", map);
	kv = new KeyValues("Zones");
	if(!FileExists(tmp))
	{
		if(kv.ExportToFile(tmp)) 
		{
			char message[128];
			Format(STRING(message), "Nouveau fichier: %s", tmp);
			rp_LogToDiscord(message);
		}
	}	
	delete kv;
	
	BuildPath(Path_SM, STRING(tmp), "data/roleplay/%s/weather.cfg", map);
	kv = new KeyValues("Weather");
	if(!FileExists(tmp))
	{
		if(kv.ExportToFile(tmp)) 
		{
			char message[128];
			Format(STRING(message), "Nouveau fichier: %s", tmp);
			rp_LogToDiscord(message);
		}
	}	
	delete kv;

	BuildPath(Path_SM, STRING(tmp), "data/roleplay/archievements.cfg");
	if(!FileExists(tmp))
		SetFailState("[FILE FAILED] Can't load %s", tmp);
		
	BuildPath(Path_SM, STRING(tmp), "data/roleplay/drivingquestions.cfg");
	if(!FileExists(tmp))
		SetFailState("[FILE FAILED] Can't load %s", tmp);
		
	BuildPath(Path_SM, STRING(tmp), "data/roleplay/items.cfg");
	if(!FileExists(tmp))
		SetFailState("[FILE FAILED] Can't load %s", tmp);
		
	BuildPath(Path_SM, STRING(tmp), "data/roleplay/jail_raisons.cfg");
	if(!FileExists(tmp))
		SetFailState("[FILE FAILED] Can't load %s", tmp);
		
	BuildPath(Path_SM, STRING(tmp), "data/roleplay/jobs.cfg");
	if(!FileExists(tmp))
		SetFailState("[FILE FAILED] Can't load %s", tmp);
		
	BuildPath(Path_SM, STRING(tmp), "data/roleplay/nationality.cfg");
	if(!FileExists(tmp))
		SetFailState("[FILE FAILED] Can't load %s", tmp);
		
	BuildPath(Path_SM, STRING(tmp), "data/roleplay/notifications.cfg");
	if(!FileExists(tmp))
		SetFailState("[FILE FAILED] Can't load %s", tmp);
		
	BuildPath(Path_SM, STRING(tmp), "data/roleplay/particles.cfg");
	if(!FileExists(tmp))
		SetFailState("[FILE FAILED] Can't load %s", tmp);
		
	/*BuildPath(Path_SM, STRING(tmp), "data/roleplay/props.cfg");
	if(!FileExists(tmp))
		SetFailState("[FILE FAILED] Can't load %s", tmp);	*/	
		
	BuildPath(Path_SM, STRING(tmp), "data/roleplay/questions.cfg");
	if(!FileExists(tmp))
		SetFailState("[FILE FAILED] Can't load %s", tmp);
		
	BuildPath(Path_SM, STRING(tmp), "data/roleplay/rank.cfg");
	if(!FileExists(tmp))
		SetFailState("[FILE FAILED] Can't load %s", tmp);
		
	BuildPath(Path_SM, STRING(tmp), "data/roleplay/skins.cfg");
	if(!FileExists(tmp))
		SetFailState("[FILE FAILED] Can't load %s", tmp);
		
	BuildPath(Path_SM, STRING(tmp), "data/roleplay/skins.cfg");
	if(!FileExists(tmp))
		SetFailState("[FILE FAILED] Can't load %s", tmp);	
		
	BuildPath(Path_SM, STRING(tmp), "data/roleplay/vehicles.cfg");
	if(!FileExists(tmp))
		SetFailState("[FILE FAILED] Can't load %s", tmp);
	
	/*------------------------------------------------------------------------*/
	
	RegisterStringMaps();
}	

public void OnConfigsExecuted()
{
	if(g_engineversion != Engine_CSS)
	{
		ServerCommand("mp_warmup_end");
		FindConVar("mp_weapons_glow_on_ground").SetInt(1);	
		FindConVar("mp_warmuptime").SetFloat(1.0);	
		FindConVar("healthshot_health").SetInt(150);
		FindConVar("sv_ladder_scale_speed").SetFloat(1.0);	
	}
	
	FindConVar("mp_autokick").SetInt(0);	
	FindConVar("mp_tkpunish").SetInt(0);	
	FindConVar("mp_ignore_round_win_conditions").SetInt(1);	
	FindConVar("mp_round_restart_delay").SetInt(0);	
	
	SetConVarBounds(FindConVar("mp_roundtime"), ConVarBound_Upper, true, 1501102101.0);	
	ServerCommand("mp_roundtime 1501102101");
	
	char buffer[128];
	RoleplayCvar.fastdl.GetString(STRING(buffer));
	FindConVar("sv_downloadurl").SetString(buffer);	
	RoleplayCvar.discord.GetString(STRING(discord));
	RoleplayCvar.website.GetString(STRING(website));
	
	//RegisterStringMaps();
}

public void OnMapEnd()
{
	TrashTimer(Timer_Second, true);
	TrashTimer(Timer_5Second, true);
}

/***************************************************************************************

									N A T I V E S

***************************************************************************************/

public APLRes AskPluginLoad2(Handle plugin, bool late, char[] error, int err_max)
{
	RegPluginLibrary("rp_core");
	
	/*------------------------------------FORWADS------------------------------------*/
	Forward.OnDeath = new GlobalForward("RP_OnClientDeath", ET_Event, Param_Cell, Param_Cell, Param_String, Param_Cell);
	Forward.OnFire = new GlobalForward("RP_OnClientFire", ET_Event, Param_Cell, Param_Cell, Param_String, Param_Cell);
	Forward.OnSpawn = new GlobalForward("RP_OnClientSpawn", ET_Event, Param_Cell);
	Forward.OnSay = new GlobalForward("RP_OnClientSay", ET_Event, Param_Cell, Param_String);
	Forward.OnSayTeam = new GlobalForward("RP_OnClientSayTeam", ET_Event, Param_Cell, Param_String);
	Forward.OnInteract = new GlobalForward("RP_OnClientInteract", ET_Event, Param_Cell, Param_Cell, Param_String, Param_String, Param_String);
	Forward.OnReload = new GlobalForward("RP_OnClientPress_R", ET_Event, Param_Cell);
	Forward.OnDuck = new GlobalForward("RP_OnClientPress_CTRL", ET_Event, Param_Cell);
	Forward.OnTakeDamage = new GlobalForward("RP_OnClientTakeDamage", ET_Event, Param_Cell, Param_Cell, Param_Cell, Param_Float, Param_Cell);
	Forward.OnHurt = new GlobalForward("RP_OnClientHurt", ET_Event, Param_Cell, Param_Cell, Param_Cell, Param_Cell, Param_String);
	Forward.OnTimerSecond = new GlobalForward("RP_TimerEverySecond", ET_Event);
	Forward.OnClientTimerSecond = new GlobalForward("RP_ClientTimerEverySecond", ET_Event, Param_Cell);
	Forward.OnEntityTimerSecond = new GlobalForward("RP_EntityTimerEverySecond", ET_Event, Param_Cell);
	Forward.OnTimer5Second = new GlobalForward("RP_TimerEvery5Second", ET_Event);
	Forward.OnFootstep = new GlobalForward("RP_OnFootstep", ET_Event, Param_Cell);
	Forward.OnFirstSpawn = new GlobalForward("RP_OnClientFirstSpawn", ET_Event, Param_Cell);
	Forward.OnFirstSpawnMessage = new GlobalForward("RP_OnClientFirstSpawnMessage", ET_Event, Param_Cell);
	Forward.OnLookAtTarget = new GlobalForward("RP_OnLookAtTarget", ET_Event, Param_Cell, Param_Cell, Param_String);
	Forward.OnTouch = new GlobalForward("RP_OnClientStartTouch", ET_Event, Param_Cell, Param_Cell);
	Forward.OnEndLife = new GlobalForward("RP_OnEntityEndLife", ET_Event, Param_Cell);
	Forward.OnReduceHealth = new GlobalForward("RP_OnEntityReduceHealth", ET_Event, Param_Cell, Param_Float, Param_Float);
	Forward.OnRoundStart = new GlobalForward("RP_OnRoundStart", ET_Event);
	Forward.OnClockChange = new GlobalForward("RP_OnClockChange", ET_Event);
	Forward.OnNewDay = new GlobalForward("RP_OnNewDay", ET_Event);
	/*-------------------------------------------------------------------------------*/
    
	CreateNative("rp_GetClientInt", Native_GetIntData);
	CreateNative("rp_SetClientInt", Native_SetIntData);
    
	CreateNative("rp_GetClientBool", Native_GetClientBool);
	CreateNative("rp_SetClientBool", Native_SetClientBool);
	
	CreateNative("rp_GetClientFloat", Native_GetClientFloat);
	CreateNative("rp_SetClientFloat", Native_SetClientFloat);
	
	CreateNative("rp_GetClientString", Native_GetClientString);
	CreateNative("rp_SetClientString", Native_SetClientString);
	
	CreateNative("rp_GetVehicleInt", Native_GetVehicleInt);
	CreateNative("rp_SetVehicleInt", Native_SetVehicleInt);
	CreateNative("rp_GetVehicleFloat", Native_GetVehicleFloat);
	CreateNative("rp_SetVehicleFloat", Native_SetVehicleFloat);
	CreateNative("rp_GetVehicleString", Native_GetVehicleString);
	CreateNative("rp_SetVehicleString", Native_SetVehicleString);
	
	CreateNative("rp_GetJobSearch", Native_GetJobSearch);
	CreateNative("rp_SetJobSearch", Native_SetJobSearch);
	
	CreateNative("rp_GetAdmin", Native_GetAdmin);
	CreateNative("rp_SetAdmin", Native_SetAdmin);
	
	CreateNative("rp_GetWeaponAmmoType", Native_GetWeaponAmmoType);
	CreateNative("rp_SetWeaponAmmoType", Native_SetWeaponAmmoType);
	CreateNative("rp_GetWeaponAmmoAmount", Native_GetWeaponAmmoAmount);
	CreateNative("rp_SetWeaponAmmoAmount", Native_SetWeaponAmmoAmount);
	
	CreateNative("rp_SetKnifeType", Native_SetKnifeType);
	CreateNative("rp_GetKnifeType", Native_GetKnifeType);
	
	CreateNative("rp_SetClientSick", Native_SetClientSick);
	CreateNative("rp_GetClientSick", Native_GetClientSick);
	
	CreateNative("rp_SetClientSurgery", Native_SetClientSurgery);
	CreateNative("rp_GetClientSurgery", Native_GetClientSurgery);
	
	CreateNative("rp_GetAppartementInt", Native_GetAppartementInt);
	CreateNative("rp_SetAppartementInt", Native_SetAppartementInt);
	
	CreateNative("rp_GetVillaInt", Native_GetVillaInt);
	CreateNative("rp_SetVillaInt", Native_SetVillaInt);
	
	CreateNative("rp_GetHotelInt", Native_GetHotelInt);
	CreateNative("rp_SetHotelInt", Native_SetHotelInt);
	
	CreateNative("rp_GetClientStat", Native_GetClientStat);
	CreateNative("rp_SetClientStat", Native_SetClientStat);
	
	CreateNative("rp_GetClientKeyVehicle", Native_GetClientKeyVehicle);
	CreateNative("rp_SetClientKeyVehicle", Native_SetClientKeyVehicle);
	
	CreateNative("rp_GetRank", Native_GetRank);
	CreateNative("rp_SetRank", Native_SetRank);
	CreateNative("rp_IsValidRank", Native_IsValidRank);
	
	CreateNative("rp_ClientCanDrawPanel", Native_CanDrawPanel);
	CreateNative("rp_GetGame", Native_GetGame);	

	CreateNative("rp_Close", Native_Close);
	
	CreateNative("rp_GetClientResource", Native_GetClientResource);
	CreateNative("rp_SetClientResource", Native_SetClientResource);
	
	CreateNative("rp_GetEntityHealth", Native_GetEntityHealth);
	CreateNative("rp_SetEntityHealth", Native_SetEntityHealth);
	
	CreateNative("rp_GetJobName", Native_GetJobName);
	CreateNative("rp_SetJobName", Native_SetJobName);
	
	CreateNative("rp_GetJobCapital", Native_GetJobCapital);
	CreateNative("rp_SetJobCapital", Native_SetJobCapital);
	
	CreateNative("rp_GetJobDoors", Native_GetJobDoors);
	CreateNative("rp_SetJobDoors", Native_SetJobDoors);
	
	CreateNative("rp_CanJobSell", Native_CanJobSell);
	CreateNative("rp_SetCanJobSell", Native_SetCanJobSell);
	
	CreateNative("rp_GetJobMaxGrades", Native_GetJobMaxGrades);
	
	CreateNative("rp_GetGradeName", Native_GetGradeName);
	CreateNative("rp_SetGradeName", Native_SetGradeName);
	
	CreateNative("rp_GetGradeClantag", Native_GetGradeClantag);
	CreateNative("rp_SetGradeClantag", Native_SetGradeClantag);
	
	CreateNative("rp_GetGradeSalary", Native_GetGradeSalary);
	CreateNative("rp_SetGradeSalary", Native_SetGradeSalary);
	
	CreateNative("rp_GetGradeModel", Native_GetGradeModel);
	CreateNative("rp_SetGradeModel", Native_SetGradeModel);
	
	CreateNative("rp_Slay", Native_Slay);
	
	CreateNative("rp_BuildProp", Native_BuildProp);
	
	CreateNative("rp_GetGlobalData", Native_GetGlobalData);
	
	CreateNative("rp_GetEntityOwner", Native_GetEntityOwner);
	CreateNative("rp_SetEntityOwner", Native_SetEntityOwner);
	
	CreateNative("rp_IsEntityValidRoleplay", Native_IsEntityValidRoleplay);
	
	CreateNative("rp_GetDoorJobID", Native_GetDoorJob);
	
	CreateNative("rp_GetHudType", Native_GetHudType);
	CreateNative("rp_SetHudType", Native_SetHudType);
	
	CreateNative("rp_GetTime", Native_GetTime);
	CreateNative("rp_SetTime", Native_SetTime);
	
	return APLRes_Success;
}

public int Native_GetIntData(Handle plugin, int numParams) 
{
	int client = GetNativeCell(1);
	int variable = GetNativeCell(2);
	
	if(!IsClientValid(client))
	{
		//ThrowNativeError(SP_ERROR_NATIVE, "Client %i is not valid !", client);
		return -1;
	}	
		
	int data = -1;
	switch(variable)
	{
		case i_Appart:data=RoleplayInt[client].Appartement;
		case i_Bank:data=RoleplayInt[client].Bank;
		case i_Grade:data=RoleplayInt[client].GradeID;
		case i_Graffiti:data=RoleplayInt[client].GraffitiCount;
		case i_GraffitiIndex:data=RoleplayInt[client].GraffitiIndex;
		case i_Group:data=RoleplayInt[client].GroupID;
		case i_Job:data=RoleplayInt[client].JobID;
		case i_JailTime:data=RoleplayInt[client].JailTime;
		case i_LastAgression:data=RoleplayInt[client].LastAgression;
		case i_LastKilled_Reverse:data=RoleplayInt[client].LastKilled_Reverse;
		case i_LastDangerousShot:data=RoleplayInt[client].LastDangerousShot;
		case i_LastVol:data=RoleplayInt[client].LastVol;
		case i_LastVolTarget:data=RoleplayInt[client].LastVolTarget;
		case i_LastVolTime:data=RoleplayInt[client].LastVolTime;
		case i_LastVolAmount:data=RoleplayInt[client].LastVolAmount;
		case i_LastVolArme:data=RoleplayInt[client].LastVolArme;
		case i_KillJailDuration:data=RoleplayInt[client].KillJailDuration;
		case i_KitCrochetage:data=RoleplayInt[client].KitCrochetage;
		case i_KnifeThrow:data=RoleplayInt[client].KnifeThrow;
		case i_KnifeLevel:data=RoleplayInt[client].KnifeLevel;
		case i_MarriedTo:data=RoleplayInt[client].MarriedTo;
		case i_MaxHealth:data=RoleplayInt[client].MaxHealth;
		case i_Money:data=RoleplayInt[client].Money;
		case i_Machine:data=RoleplayInt[client].MachineCount;
		case i_Plante:data=RoleplayInt[client].PlantCount;
		case i_TicketMetro:data=RoleplayInt[client].TicketMetro;
		case i_Trash:data=RoleplayInt[client].TrashCount;
		case i_Salary:data=RoleplayInt[client].Salary;
		case i_Zone:data=RoleplayInt[client].Zone;
		case i_ZoneAppart:data=RoleplayInt[client].ZoneAppartement;
		case i_ZoneHotel:data=RoleplayInt[client].ZoneHotel;
		case i_SalaryBonus:data=RoleplayInt[client].SalaryBonus;
		case i_VipTime:data=RoleplayInt[client].VipTime;
		case i_Rank:data=RoleplayInt[client].RankID;
		case i_Villa:data=RoleplayInt[client].VillaID;
		case i_ZoneVilla:data=RoleplayInt[client].ZoneVilla;
		case i_AppartCount:data=RoleplayInt[client].AppartementCount;
		case i_XP:data=RoleplayInt[client].XP;
		case i_MaxSelfItem:data=RoleplayInt[client].MaxSelfItem;
		case i_JailRaisonID:data=RoleplayInt[client].JailRaisonID;
		case i_JailID:data=RoleplayInt[client].JailID;
		case i_Organisation:data=RoleplayInt[client].Organisation;
		case i_Nationality:data=RoleplayInt[client].Nationality;
		case i_Sexe:data=RoleplayInt[client].Sexe;
		case i_Hotel:data=RoleplayInt[client].HotelID;
	}
	return data;
}

public int Native_SetIntData(Handle plugin, int numParams) 
{
	int client = GetNativeCell(1);
	int variable = GetNativeCell(2);
	int value = GetNativeCell(3);
	
	if(!IsClientValid(client))
	{
		//ThrowNativeError(SP_ERROR_NATIVE, "Client %i is not valid !", client);
		return -1;
	}
	
	switch(variable)
	{
		case i_Appart:return RoleplayInt[client].Appartement = value;
		case i_Bank:return RoleplayInt[client].Bank = value;
		case i_Grade:return RoleplayInt[client].GradeID = value;
		case i_Graffiti:return RoleplayInt[client].GraffitiCount = value;
		case i_GraffitiIndex:return RoleplayInt[client].GraffitiIndex = value;
		case i_Group:return RoleplayInt[client].GroupID = value;
		case i_Job:return RoleplayInt[client].JobID = value;
		case i_JailTime:return RoleplayInt[client].JailTime = value;
		case i_LastAgression:return RoleplayInt[client].LastAgression = value;
		case i_LastKilled_Reverse:return RoleplayInt[client].LastKilled_Reverse = value;
		case i_LastDangerousShot:return RoleplayInt[client].LastDangerousShot = value;
		case i_LastVol:return RoleplayInt[client].LastVol = value;
		case i_LastVolTarget:return RoleplayInt[client].LastVolTarget = value;
		case i_LastVolTime:return RoleplayInt[client].LastVolTime = value;
		case i_LastVolAmount:return RoleplayInt[client].LastVolAmount = value;
		case i_LastVolArme:return RoleplayInt[client].LastVolArme = value;
		case i_KillJailDuration:return RoleplayInt[client].KillJailDuration = value;
		case i_KitCrochetage:return RoleplayInt[client].KitCrochetage = value;
		case i_KnifeThrow:return RoleplayInt[client].KnifeThrow = value;
		case i_KnifeLevel:return RoleplayInt[client].KnifeLevel = value;
		case i_MarriedTo:return RoleplayInt[client].MarriedTo = value;
		case i_MaxHealth:return RoleplayInt[client].MaxHealth = value;
		case i_Money:return RoleplayInt[client].Money = value;
		case i_Machine:return RoleplayInt[client].MachineCount = value;
		case i_Plante:return RoleplayInt[client].PlantCount = value;
		case i_TicketMetro:return RoleplayInt[client].TicketMetro = value;
		case i_Trash:return RoleplayInt[client].TrashCount = value;
		case i_Salary:return RoleplayInt[client].Salary = value;
		case i_Zone:return RoleplayInt[client].Zone = value;
		case i_ZoneAppart:return RoleplayInt[client].ZoneAppartement = value;
		case i_ZoneHotel:return RoleplayInt[client].ZoneHotel = value;
		case i_SalaryBonus:return RoleplayInt[client].SalaryBonus = value;
		case i_VipTime:return RoleplayInt[client].VipTime = value;
		case i_Rank:return RoleplayInt[client].RankID = value;
		case i_Villa:return RoleplayInt[client].VillaID = value;
		case i_ZoneVilla:return RoleplayInt[client].ZoneVilla = value;
		case i_AppartCount:return RoleplayInt[client].AppartementCount = value;
		case i_XP:return RoleplayInt[client].XP = value;
		case i_MaxSelfItem:return RoleplayInt[client].MaxSelfItem = value;
		case i_JailRaisonID:return RoleplayInt[client].JailRaisonID = value;
		case i_JailID:return RoleplayInt[client].JailID = value;
		case i_Organisation:return RoleplayInt[client].Organisation = value;
		case i_Nationality:return RoleplayInt[client].Nationality = value;
		case i_Sexe:return RoleplayInt[client].Sexe = value;
		case i_Hotel:return RoleplayInt[client].HotelID = value;
	}
	return -1;
}

public int Native_GetClientBool(Handle plugin, int numParams) 
{
	int client = GetNativeCell(1);
	int variable = GetNativeCell(2);
	
	if(!IsClientValid(client))
	{
		//ThrowNativeError(SP_ERROR_NATIVE, "Client %i is not valid !", client);
		return -1;
	}
		
	switch(variable)
	{
		case b_HasBankCard:return RoleplayBool[client].HasBankCard;
		case b_HasCrowbar:return RoleplayBool[client].HasCrowbar;
		case b_HasCovidFaceMask:return RoleplayBool[client].HasCovidFaceMask;
		case b_HasFlashLight:return RoleplayBool[client].HasFlashLight;
		case b_HasLubrifiant:return RoleplayBool[client].HasLubrifiant;
		case b_HasMandate:return RoleplayBool[client].HasMandate;
		case b_HasSwissAccount:return RoleplayBool[client].HasSwissAccount;
		case b_CanUseItem:return RoleplayBool[client].CanUseItem;
		case b_DisplayHud:return RoleplayBool[client].DisplayHud;
		case b_HasBonusHealth:return RoleplayBool[client].HasBonusHealth;
		case b_HasBonusKevlar:return RoleplayBool[client].HasBonusKevlar;
		case b_HasBonusPay:return RoleplayBool[client].HasBonusPay;
		case b_HasBonusBox:return RoleplayBool[client].HasBonusBox;
		case b_HasBonusTomb:return RoleplayBool[client].HasBonusTomb;
		case b_HasJointEffect:return RoleplayBool[client].HasJointEffect;
		case b_HasShitEffect:return RoleplayBool[client].HasShitEffect;
		case b_HasAmphetamineEffect:return RoleplayBool[client].HasAmphetamineEffect;
		case b_HasHeroineEffect:return RoleplayBool[client].HasHeroineEffect;
		case b_HasEcstasyEffect:return RoleplayBool[client].HasEcstasyEffect;
		case b_HasCocainaEffect:return RoleplayBool[client].HasCocainaEffect;
		case b_HasSellLicence:return RoleplayBool[client].HasSellLicence;
		case b_HasCarLicence:return RoleplayBool[client].HasCarLicence;
		case b_HasPrimaryWeaponLicence:return RoleplayBool[client].HasPrimaryWeaponLicence;
		case b_HasSecondaryWeaponLicence:return RoleplayBool[client].HasSecondaryWeaponLicence;
		case b_HasKevlarRegen:return RoleplayBool[client].HasKevlarRegen;
		case b_HasHealthRegen:return RoleplayBool[client].HasHealthRegen;
		case b_HasRib:return RoleplayBool[client].HasRib;
		case b_HasGlovesProtection:return RoleplayBool[client].HasGlovesProtection;
		case b_IsNew:return RoleplayBool[client].IsNew;
		case b_IsMuteGlobal:return RoleplayBool[client].IsMuteGlobal;
		case b_IsMuteLocal:return RoleplayBool[client].IsMuteLocal;
		case b_IsMuteVocal:return RoleplayBool[client].IsMuteVocal;
		case b_IsVip:return RoleplayBool[client].IsVip;
		case b_IsAfk:return RoleplayBool[client].IsAfk;
		case b_IsTased:return RoleplayBool[client].IsTased;
		case b_IsSearchByTribunal:return RoleplayBool[client].IsSearchByTribunal;
		case b_IsPassive:return RoleplayBool[client].IsPassive;
		case b_JoinSound:return RoleplayBool[client].JoinSound;
		case b_MayTalk:return RoleplayBool[client].MayTalk;
		case b_SpawnJob:return RoleplayBool[client].SpawnJob;
		case b_TransfertItemBank:return RoleplayBool[client].TransfertItemBank;
		case b_TouchedByDanceGrenade:return RoleplayBool[client].TouchedByDanceGrenade;
		case b_IsThirdPerson:return RoleplayBool[client].IsThirdPerson;
		case b_HasCasinoAccess:return RoleplayBool[client].HasCasinoAccess;
		case b_HasColorPallet:return RoleplayBool[client].HasColorPallet;
		case b_IsOnAduty:return RoleplayBool[client].IsOnAduty;
		case b_IsSteamMember:return RoleplayBool[client].IsSteamMember;
		case b_IsWebsiteMember:return RoleplayBool[client].IsWebsiteMember;
	}	
	return -1;
}

public int Native_SetClientBool(Handle plugin, int numParams) 
{
	int client = GetNativeCell(1);
	int variable = GetNativeCell(2);
	bool value = GetNativeCell(3);
	
	if(!IsClientValid(client))
	{
		//ThrowNativeError(SP_ERROR_NATIVE, "Client %i is not valid !", client);
		return -1;
	}	
		
	switch(variable)
	{
		case b_HasBankCard:return RoleplayBool[client].HasBankCard = value;
		case b_HasCrowbar:return RoleplayBool[client].HasCrowbar = value;
		case b_HasCovidFaceMask:return RoleplayBool[client].HasCovidFaceMask = value;
		case b_HasFlashLight:return RoleplayBool[client].HasFlashLight = value;
		case b_HasLubrifiant:return RoleplayBool[client].HasLubrifiant = value;
		case b_HasMandate:return RoleplayBool[client].HasMandate = value;
		case b_HasSwissAccount:return RoleplayBool[client].HasSwissAccount = value;
		case b_CanUseItem:return RoleplayBool[client].CanUseItem = value;
		case b_DisplayHud:return RoleplayBool[client].DisplayHud = value;
		case b_HasBonusHealth:return RoleplayBool[client].HasBonusHealth = value;
		case b_HasBonusKevlar:return RoleplayBool[client].HasBonusKevlar = value;
		case b_HasBonusPay:return RoleplayBool[client].HasBonusPay = value;
		case b_HasBonusBox:return RoleplayBool[client].HasBonusBox = value;
		case b_HasBonusTomb:return RoleplayBool[client].HasBonusTomb = value;
		case b_HasJointEffect:return RoleplayBool[client].HasJointEffect = value;
		case b_HasShitEffect:return RoleplayBool[client].HasShitEffect = value;
		case b_HasAmphetamineEffect:return RoleplayBool[client].HasAmphetamineEffect = value;
		case b_HasHeroineEffect:return RoleplayBool[client].HasHeroineEffect = value;
		case b_HasEcstasyEffect:return RoleplayBool[client].HasEcstasyEffect = value;
		case b_HasCocainaEffect:return RoleplayBool[client].HasCocainaEffect = value;
		case b_HasSellLicence:return RoleplayBool[client].HasSellLicence = value;
		case b_HasCarLicence:return RoleplayBool[client].HasCarLicence = value;
		case b_HasPrimaryWeaponLicence:return RoleplayBool[client].HasPrimaryWeaponLicence = value;
		case b_HasSecondaryWeaponLicence:return RoleplayBool[client].HasSecondaryWeaponLicence = value;
		case b_HasKevlarRegen:return RoleplayBool[client].HasKevlarRegen = value;
		case b_HasHealthRegen:return RoleplayBool[client].HasHealthRegen = value;
		case b_HasRib:return RoleplayBool[client].HasRib = value;
		case b_HasGlovesProtection:return RoleplayBool[client].HasGlovesProtection = value;
		case b_HasColorPallet:return RoleplayBool[client].HasColorPallet = value;
		case b_IsNew:return RoleplayBool[client].IsNew = value;
		case b_IsMuteGlobal:return RoleplayBool[client].IsMuteGlobal = value;
		case b_IsMuteLocal:return RoleplayBool[client].IsMuteLocal = value;
		case b_IsMuteVocal:return RoleplayBool[client].IsMuteVocal = value;
		case b_IsVip:return RoleplayBool[client].IsVip = value;
		case b_IsAfk:return RoleplayBool[client].IsAfk = value;
		case b_IsTased:return RoleplayBool[client].IsTased = value;
		case b_IsSearchByTribunal:return RoleplayBool[client].IsSearchByTribunal = value;
		case b_IsPassive:return RoleplayBool[client].IsPassive = value;
		case b_JoinSound:return RoleplayBool[client].JoinSound = value;
		case b_MayTalk:return RoleplayBool[client].MayTalk = value;
		case b_SpawnJob:return RoleplayBool[client].SpawnJob = value;
		case b_TransfertItemBank:return RoleplayBool[client].TransfertItemBank = value;
		case b_TouchedByDanceGrenade:return RoleplayBool[client].TouchedByDanceGrenade = value;
		case b_IsThirdPerson:return RoleplayBool[client].IsThirdPerson = value;
		case b_HasCasinoAccess:return RoleplayBool[client].HasCasinoAccess = value;
		case b_IsWebsiteMember:return RoleplayBool[client].IsWebsiteMember = value;
	}	
	return -1;
}

public any Native_GetClientFloat(Handle plugin, int numParams) 
{
	int client = GetNativeCell(1);
	int variable = GetNativeCell(2);
	
	if(!IsClientValid(client))
	{
		//ThrowNativeError(SP_ERROR_NATIVE, "Client %i is not valid !", client);
		return -1;
	}
		
	switch(variable)
	{
		case fl_Vitality:return RoleplayFloat[client].Vitality;
		case fl_Faim:return RoleplayFloat[client].Faim;
		case fl_Soif:return RoleplayFloat[client].Soif;
	}	
	return -1;
}

public any Native_SetClientFloat(Handle plugin, int numParams) 
{
	int client = GetNativeCell(1);
	int variable = GetNativeCell(2);
	float value = GetNativeCell(3);
	
	if(!IsClientValid(client))
	{
		//ThrowNativeError(SP_ERROR_NATIVE, "Client %i is not valid !", client);
		return -1;
	}
			
	switch(variable)
	{
		case fl_Vitality:return RoleplayFloat[client].Vitality = value;
		case fl_Faim:return RoleplayFloat[client].Faim = value;
		case fl_Soif:return RoleplayFloat[client].Soif = value;
	}	
	return -1;
}

public int Native_GetClientString(Handle plugin, int numParams) 
{
	int client = GetNativeCell(1);
	int variable = GetNativeCell(2);
	int maxlen = GetNativeCell(4) + 1;
	
	if(!IsClientValid(client))
	{
		//ThrowNativeError(SP_ERROR_NATIVE, "Client %i is not valid !", client);
		return -1;
	}
		
	switch(variable)
	{
		case sz_Skin:SetNativeString(3, RoleplayChar[client].SkinModel, maxlen);
		case sz_FirstName:SetNativeString(3, RoleplayChar[client].FirstName, maxlen);
		case sz_LastName:SetNativeString(3, RoleplayChar[client].LastName, maxlen);
		case sz_AdminTag:SetNativeString(3, RoleplayChar[client].AdminTag, maxlen);
		case sz_ZoneName:SetNativeString(3, RoleplayChar[client].ZoneName, maxlen);
		case sz_ClotheHat:SetNativeString(3, RoleplayChar[client].ClotheHat, maxlen);
		case sz_ClotheMask:SetNativeString(3, RoleplayChar[client].ClotheMask, maxlen);
	}	
	return -1;
}

public int Native_SetClientString(Handle plugin, int numParams) 
{
	int client = GetNativeCell(1);
	int variable = GetNativeCell(2);
	int maxlen = GetNativeCell(4) + 1;
	
	if(!IsClientValid(client))
	{
		//ThrowNativeError(SP_ERROR_NATIVE, "Client %i is not valid !", client);
		return -1;
	}
		
	switch(variable)
	{
		case sz_Skin:GetNativeString(3, RoleplayChar[client].SkinModel, maxlen);
		case sz_FirstName:GetNativeString(3, RoleplayChar[client].FirstName, maxlen);
		case sz_LastName:GetNativeString(3, RoleplayChar[client].LastName, maxlen);
		case sz_AdminTag:GetNativeString(3, RoleplayChar[client].AdminTag, maxlen);
		case sz_ZoneName:GetNativeString(3, RoleplayChar[client].ZoneName, maxlen);
		case sz_ClotheHat:GetNativeString(3, RoleplayChar[client].ClotheHat, maxlen);
		case sz_ClotheMask:GetNativeString(3, RoleplayChar[client].ClotheMask, maxlen);
	}
	return -1;
}

public int Native_GetJobSearch(Handle plugin, int numParams) 
{
	return search;
}

public int Native_SetJobSearch(Handle plugin, int numParams) 
{
	int jobID = GetNativeCell(1);
	search = jobID;
	
	return 0;
}

public int Native_GetAdmin(Handle plugin, int numParams) 
{
	int client = GetNativeCell(1);
	
	if(!IsClientValid(client))
		return -1;
	
	return adminLevel[client];
}

public int Native_SetAdmin(Handle plugin, int numParams) 
{
	int client = GetNativeCell(1);
	admin_type type = GetNativeCell(2);
	
	/*if(!IsClientValid(client))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "Client %i is not valid !", client);
		return -1;
	}*/
	
	return adminLevel[client] = type;
}

public int Native_GetVehicleInt(Handle plugin, int numParams) {
	int car = GetNativeCell(1);
	int variable = GetNativeCell(2);
	
	if(!Vehicle_IsValid(car))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "Vehicle %i is not valid !", car);
		return -1;
	}
		
	switch(variable)
	{
		case car_owner:return RoleplayIntVehicle[car].owner;
		case car_maxPassager:return RoleplayIntVehicle[car].maxPassager;
		case car_price:return RoleplayIntVehicle[car].price;
		case car_police:return RoleplayIntVehicle[car].police;
		case car_id:return RoleplayIntVehicle[car].id;
		case car_skinid:return RoleplayIntVehicle[car].skinid;
		case car_engine:return RoleplayIntVehicle[car].engine;
		case car_insideradar:return RoleplayIntVehicle[car].insideradar;
		case car_wheeltype:return RoleplayIntVehicle[car].wheeltype;
	}

	return -1;
}

public int Native_SetVehicleInt(Handle plugin, int numParams) {
	int car = GetNativeCell(1);
	int variable = GetNativeCell(2);
	int value = GetNativeCell(3);
	
	if(!Vehicle_IsValid(car))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "Vehicle %i is not valid !", car);
		return -1;
	}
		
	switch(variable)
	{
		case car_owner:return RoleplayIntVehicle[car].owner = value;
		case car_maxPassager:return RoleplayIntVehicle[car].maxPassager = value;
		case car_price:return RoleplayIntVehicle[car].price = value;
		case car_police:return RoleplayIntVehicle[car].police = value;
		case car_id:return RoleplayIntVehicle[car].id = value;
		case car_skinid:return RoleplayIntVehicle[car].skinid = value;
		case car_engine:return RoleplayIntVehicle[car].engine = value;
		case car_insideradar:return RoleplayIntVehicle[car].insideradar = value;
		case car_wheeltype:return RoleplayIntVehicle[car].wheeltype = value;
	}	
	
	return -1;
}

public any Native_GetVehicleFloat(Handle plugin, int numParams) {
	int car = GetNativeCell(1);
	int variable = GetNativeCell(2);
	
	if(!Vehicle_IsValid(car))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "Vehicle %i is not valid !", car);
		return -1;
	}
		
	switch(variable)
	{
		case car_fuel:return RoleplayFloatVehicle[car].fuel;
		case car_maxFuel:return RoleplayFloatVehicle[car].maxFuel;
		case car_km:return RoleplayFloatVehicle[car].km;
	}
		
	return -1;
}

public any Native_SetVehicleFloat(Handle plugin, int numParams) {
	int car = GetNativeCell(1);
	int variable = GetNativeCell(2);
	float value = GetNativeCell(3);
	
	if(!Vehicle_IsValid(car))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "Vehicle %i is not valid !", car);
		return -1;
	}
		
	switch(variable)
	{
		case car_fuel:return RoleplayFloatVehicle[car].fuel = value;
		case car_maxFuel:return RoleplayFloatVehicle[car].maxFuel = value;
		case car_km:return RoleplayFloatVehicle[car].km = value;
	}	
	
	return -1;
}

public int Native_GetVehicleString(Handle plugin, int numParams) 
{
	int car = GetNativeCell(1);
	int variable = GetNativeCell(2);
	int maxlen = GetNativeCell(4) + 1;
	
	if(!Vehicle_IsValid(car))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "Vehicle %i is not valid !", car);
		return -1;
	}
		
	switch(variable)
	{
		case car_brand:SetNativeString(3, RoleplayCharVehicle[car].brand, maxlen);
		case car_serial:SetNativeString(3, RoleplayCharVehicle[car].serial, maxlen);
	}	
	
	return -1;
}

public int Native_SetVehicleString(Handle plugin, int numParams) 
{
	int car = GetNativeCell(1);
	int variable = GetNativeCell(2);
	int maxlen = GetNativeCell(4) + 1;
	
	if(!Vehicle_IsValid(car))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "Vehicle %i is not valid !", car);
		return -1;
	}
		
	switch(variable)
	{
		case car_brand:GetNativeString(3, RoleplayCharVehicle[car].brand, maxlen);
		case car_serial:GetNativeString(3, RoleplayCharVehicle[car].serial, maxlen);
	}	
			
	return -1;
}

public int Native_SetWeaponAmmoType(Handle plugin, int numParams) 
{
	int weaponID = GetNativeCell(1);
	ammo_type type = GetNativeCell(2);	
	
	if(!IsValidEntity(weaponID))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "Weapon %i is not valid !", weaponID);
		return -1;
	}
	
	weapon_ammo_type[weaponID] = type;	
	
	return 0;
}

public int Native_GetWeaponAmmoType(Handle plugin, int numParams) 
{
	int weaponID = GetNativeCell(1);	
	
	if(!IsValidEntity(weaponID))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "Weapon %i is not valid !", weaponID);
		return -1;
	}
	
	return weapon_ammo_type[weaponID];
}

public int Native_GetWeaponAmmoAmount(Handle plugin, int numParams) 
{
	int weaponID = GetNativeCell(1);	
	
	if(!IsValidEntity(weaponID))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "Weapon %i is not valid !", weaponID);
		return -1;
	}
	
	return weapon_ammo_amount[weaponID];
}

public int Native_SetWeaponAmmoAmount(Handle plugin, int numParams) 
{
	int weaponID = GetNativeCell(1);	
	int ammo_amount = GetNativeCell(2);	
	
	if(!IsValidEntity(weaponID))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "Weapon %i is not valid !", weaponID);
		return -1;
	}
	
	rp_SetClientAmmo(weaponID, 0, ammo_amount, true);
	
	return weapon_ammo_amount[weaponID] = ammo_amount;
}

public int Native_SetKnifeType(Handle plugin, int numParams) 
{
	int weaponID = GetNativeCell(1);
	knife_type type = GetNativeCell(2);	
	
	if(IsValidEntity(weaponID))
	{
		char weaponName[64];
		Entity_GetClassName(weaponID, STRING(weaponName));
		
		if(StrContains(weaponName, "knife") == -1)
			return -1;
	}	
	else
	{
		ThrowNativeError(SP_ERROR_NATIVE, "Weapon %i is not valid !", weaponID);
		return -1;
	}
	
	weapon_knife_type[weaponID] = type;	
	
	return 0;
}

public int Native_GetKnifeType(Handle plugin, int numParams) 
{
	int weaponID = GetNativeCell(1);	
	
	if(IsValidEntity(weaponID))
	{
		char weaponName[64];
		Entity_GetClassName(weaponID, STRING(weaponName));
		
		if(StrContains(weaponName, "knife") == -1)
			return -1;
	}	
	else
	{
		ThrowNativeError(SP_ERROR_NATIVE, "Weapon %i is not valid !", weaponID);
		return -1;
	}
	
	return weapon_knife_type[weaponID];
}

public int Native_GetClientSick(Handle plugin, int numParams) 
{
	int client = GetNativeCell(1);
	int variable = GetNativeCell(2);
	
	if(!IsClientValid(client))
	{
		//ThrowNativeError(SP_ERROR_NATIVE, "Client %i is not valid !", client);
		return -1;
	}
		
	switch(variable)
	{
		case sick_type_fever:return RoleplayBoolSick[client].fever;
		case sick_type_plague:return RoleplayBoolSick[client].plague;
		case sick_type_covid:return RoleplayBoolSick[client].covid;
	}	
	
	return -1;
}

public int Native_SetClientSick(Handle plugin, int numParams) 
{
	int client = GetNativeCell(1);
	int variable = GetNativeCell(2);
	bool value = GetNativeCell(3);
	
	if(!IsClientValid(client))
	{
		//ThrowNativeError(SP_ERROR_NATIVE, "Client %i is not valid !", client);
		return -1;
	}
		
	switch(variable)
	{
		case sick_type_fever:return RoleplayBoolSick[client].fever = value;
		case sick_type_plague:return RoleplayBoolSick[client].plague = value;
		case sick_type_covid:return RoleplayBoolSick[client].covid = value;
	}	
	
	return -1;	
}

public int Native_GetClientSurgery(Handle plugin, int numParams) 
{
	int client = GetNativeCell(1);
	int variable = GetNativeCell(2);
	
	if(!IsClientValid(client))
	{
		//ThrowNativeError(SP_ERROR_NATIVE, "Client %i is not valid !", client);
		return -1;
	}
	
	switch(variable)
	{
		case surgery_heart:return RoleplayBoolSurgery[client].heart;
		case surgery_legs:return RoleplayBoolSurgery[client].legs;
		case surgery_lung:return RoleplayBoolSurgery[client].lung;
		case surgery_liver:return RoleplayBoolSurgery[client].liver;
	}	
	
	return -1;
}

public int Native_SetClientSurgery(Handle plugin, int numParams) 
{
	int client = GetNativeCell(1);
	int variable = GetNativeCell(2);
	bool value = GetNativeCell(3);
	
	if(!IsClientValid(client))
	{
		//ThrowNativeError(SP_ERROR_NATIVE, "Client %i is not valid !", client);
		return -1;
	}
	
	switch(variable)
	{
		case surgery_heart:return RoleplayBoolSurgery[client].heart = value;
		case surgery_legs:return RoleplayBoolSurgery[client].legs = value;
		case surgery_lung:return RoleplayBoolSurgery[client].lung = value;
		case surgery_liver:return RoleplayBoolSurgery[client].liver = value;
	}	
	
	return -1;
}

public int Native_GetAppartementInt(Handle plugin, int numParams) 
{
	int appid = GetNativeCell(1);
	int variable = GetNativeCell(2);
	
	switch(variable)
	{
		case appart_owner:return RoleplayIntAppart[appid].owner;
		case appart_price:return RoleplayIntAppart[appid].price;
	}
		
	return -1;
}

public int Native_SetAppartementInt(Handle plugin, int numParams) 
{
	int appid = GetNativeCell(1);
	int variable = GetNativeCell(2);
	int value = GetNativeCell(3);
	
	switch(variable)
	{
		case appart_owner:return RoleplayIntAppart[appid].owner = value;
		case appart_price:return RoleplayIntAppart[appid].price = value;
	}
		
	return -1;
}

public int Native_GetVillaInt(Handle plugin, int numParams) 
{
	int villaID = GetNativeCell(1);
	int variable = GetNativeCell(2);
	
	switch(variable)
	{
		case villa_owner:return RoleplayIntVilla[villaID].owner;
		case villa_price:return RoleplayIntVilla[villaID].price;
	}
		
	return -1;
}

public int Native_SetVillaInt(Handle plugin, int numParams) 
{
	int villaID = GetNativeCell(1);
	int variable = GetNativeCell(2);
	int value = GetNativeCell(3);
	
	switch(variable)
	{
		case villa_owner:return RoleplayIntVilla[villaID].owner = value;
		case villa_price:return RoleplayIntVilla[villaID].price = value;
	}
		
	return -1;
}

public int Native_GetHotelInt(Handle plugin, int numParams) 
{
	int hotelID = GetNativeCell(1);
	int variable = GetNativeCell(2);
	
	switch(variable)
	{
		case hotel_owner:return RoleplayIntHotel[hotelID].owner;
		case hotel_price:return RoleplayIntHotel[hotelID].price;
	}
		
	return -1;
}

public int Native_SetHotelInt(Handle plugin, int numParams) 
{
	int hotelID = GetNativeCell(1);
	int variable = GetNativeCell(2);
	int value = GetNativeCell(3);
	
	switch(variable)
	{
		case hotel_owner:return RoleplayIntHotel[hotelID].owner = value;
		case hotel_price:return RoleplayIntHotel[hotelID].price = value;
	}
		
	return -1;
}

public int Native_GetClientStat(Handle plugin, int numParams) 
{
	int client = GetNativeCell(1);
	int id = GetNativeCell(2);
	
	if(!IsClientValid(client))
	{
		//ThrowNativeError(SP_ERROR_NATIVE, "Client %i is not valid !", client);
		return -1;
	}
		
	switch(id)
	{
		case i_S_MoneyEarned_Pay:return RoleplayIntStat[client].S_MoneyEarned_Pay;
		case i_S_MoneyEarned_Phone:return RoleplayIntStat[client].S_MoneyEarned_Phone;
		case i_S_MoneyEarned_Mission:return RoleplayIntStat[client].S_MoneyEarned_Mission;
		case i_S_MoneyEarned_Sales:return RoleplayIntStat[client].S_MoneyEarned_Sales;
		case i_S_MoneyEarned_Pickup:return RoleplayIntStat[client].S_MoneyEarned_Pickup;
		case i_S_MoneyEarned_CashMachine:return RoleplayIntStat[client].S_MoneyEarned_CashMachine;
		case i_S_MoneyEarned_Give:return RoleplayIntStat[client].S_MoneyEarned_Give;
		case i_S_MoneySpent_Fines:return RoleplayIntStat[client].S_MoneySpent_Fines;
		case i_S_MoneySpent_Shop:return RoleplayIntStat[client].S_MoneySpent_Shop;
		case i_S_MoneySpent_Give:return RoleplayIntStat[client].S_MoneySpent_Give;
		case i_S_MoneySpent_Stolen:return RoleplayIntStat[client].S_MoneySpent_Stolen;
		case i_S_LotoSpent:return RoleplayIntStat[client].S_LotoSpent;
		case i_S_LotoWon:return RoleplayIntStat[client].S_LotoWon;
		case i_S_DrugPickedUp:return RoleplayIntStat[client].S_DrugPickedUp;
		case i_S_Kills:return RoleplayIntStat[client].S_Kills;
		case i_S_Deaths:return RoleplayIntStat[client].S_Deaths;
		case i_S_ItemUsed:return RoleplayIntStat[client].S_ItemUsed;
		case i_S_ItemUsedPrice:return RoleplayIntStat[client].S_ItemUsedPrice;
		case i_S_TotalBuild:return RoleplayIntStat[client].S_TotalBuild;
		case i_S_RunDistance:return RoleplayIntStat[client].S_RunDistance;
		case i_S_JobSucess:return RoleplayIntStat[client].S_JobSucess;
		case i_S_JobFails:return RoleplayIntStat[client].S_JobFails;
		
		case i_Money_OnConnection:return RoleplayIntStat[client].Money_OnConnection;
		case i_MoneyEarned_Pay:return RoleplayIntStat[client].MoneyEarned_Pay;
		case i_MoneyEarned_Phone:return RoleplayIntStat[client].MoneyEarned_Phone;
		case i_MoneyEarned_Mission:return RoleplayIntStat[client].MoneyEarned_Mission;
		case i_MoneyEarned_Sales:return RoleplayIntStat[client].MoneyEarned_Sales;
		case i_MoneyEarned_Pickup:return RoleplayIntStat[client].MoneyEarned_Pickup;
		case i_MoneyEarned_CashMachine:return RoleplayIntStat[client].MoneyEarned_CashMachine;
		case i_MoneyEarned_Give:return RoleplayIntStat[client].MoneyEarned_Give;
		case i_MoneySpent_Fines:return RoleplayIntStat[client].MoneySpent_Fines;
		case i_MoneySpent_Shop:return RoleplayIntStat[client].MoneySpent_Shop;
		case i_MoneySpent_Give:return RoleplayIntStat[client].MoneySpent_Give;
		case i_MoneySpent_Stolen:return RoleplayIntStat[client].MoneySpent_Stolen;
		case i_Vitality_OnConnection:return RoleplayIntStat[client].Vitality_OnConnection;
		case i_LotoSpent:return RoleplayIntStat[client].LotoSpent;
		case i_LotoWon:return RoleplayIntStat[client].LotoWon;
		case i_DrugPickedUp:return RoleplayIntStat[client].DrugPickedUp;
		case i_Kills:return RoleplayIntStat[client].Kills;
		case i_Deaths:return RoleplayIntStat[client].Deaths;
		case i_ItemUsed:return RoleplayIntStat[client].ItemUsed;
		case i_ItemUsedPrice:return RoleplayIntStat[client].ItemUsedPrice;
		case i_PVP_OnConnection:return RoleplayIntStat[client].PVP_OnConnection;
		case i_TotalBuild:return RoleplayIntStat[client].TotalBuild;
		case i_RunDistance:return RoleplayIntStat[client].RunDistance;
		case i_JobSucess:return RoleplayIntStat[client].JobSucess;
		case i_JobFails:return RoleplayIntStat[client].JobFails;
		case i_LastDeathTimestamp:return RoleplayIntStat[client].LastDeathTimestamp;
		case i_LastKillTimestamp:return RoleplayIntStat[client].LastKillTimestamp;
	}	
	
	return -1;
}

public int Native_SetClientStat(Handle plugin, int numParams) 
{
	int client = GetNativeCell(1);
	int id = GetNativeCell(2);
	int value = GetNativeCell(3);
	
	if(!IsClientValid(client))
	{
		//ThrowNativeError(SP_ERROR_NATIVE, "Client %i is not valid !", client);
		return -1;
	}
		
	switch(id)
	{
		case i_S_MoneyEarned_Pay:return RoleplayIntStat[client].S_MoneyEarned_Pay = value;
		case i_S_MoneyEarned_Phone:return RoleplayIntStat[client].S_MoneyEarned_Phone = value;
		case i_S_MoneyEarned_Mission:return RoleplayIntStat[client].S_MoneyEarned_Mission = value;
		case i_S_MoneyEarned_Sales:return RoleplayIntStat[client].S_MoneyEarned_Sales = value;
		case i_S_MoneyEarned_Pickup:return RoleplayIntStat[client].S_MoneyEarned_Pickup = value;
		case i_S_MoneyEarned_CashMachine:return RoleplayIntStat[client].S_MoneyEarned_CashMachine = value;
		case i_S_MoneyEarned_Give:return RoleplayIntStat[client].S_MoneyEarned_Give = value;
		case i_S_MoneySpent_Fines:return RoleplayIntStat[client].S_MoneySpent_Fines = value;
		case i_S_MoneySpent_Shop:return RoleplayIntStat[client].S_MoneySpent_Shop = value;
		case i_S_MoneySpent_Give:return RoleplayIntStat[client].S_MoneySpent_Give = value;
		case i_S_MoneySpent_Stolen:return RoleplayIntStat[client].S_MoneySpent_Stolen = value;
		case i_S_LotoSpent:return RoleplayIntStat[client].S_LotoSpent = value;
		case i_S_LotoWon:return RoleplayIntStat[client].S_LotoWon = value;
		case i_S_DrugPickedUp:return RoleplayIntStat[client].S_DrugPickedUp = value;
		case i_S_Kills:return RoleplayIntStat[client].S_Kills = value;
		case i_S_Deaths:return RoleplayIntStat[client].S_Deaths = value;
		case i_S_ItemUsed:return RoleplayIntStat[client].S_ItemUsed = value;
		case i_S_ItemUsedPrice:return RoleplayIntStat[client].S_ItemUsedPrice = value;
		case i_S_TotalBuild:return RoleplayIntStat[client].S_TotalBuild = value;
		case i_S_RunDistance:return RoleplayIntStat[client].S_RunDistance = value;
		case i_S_JobSucess:return RoleplayIntStat[client].S_JobSucess = value;
		case i_S_JobFails:return RoleplayIntStat[client].S_JobFails = value;
		
		case i_Money_OnConnection:return RoleplayIntStat[client].Money_OnConnection = value;
		case i_MoneyEarned_Pay:return RoleplayIntStat[client].MoneyEarned_Pay = value;
		case i_MoneyEarned_Phone:return RoleplayIntStat[client].MoneyEarned_Phone = value;
		case i_MoneyEarned_Mission:return RoleplayIntStat[client].MoneyEarned_Mission = value;
		case i_MoneyEarned_Sales:return RoleplayIntStat[client].MoneyEarned_Sales = value;
		case i_MoneyEarned_Pickup:return RoleplayIntStat[client].MoneyEarned_Pickup = value;
		case i_MoneyEarned_CashMachine:return RoleplayIntStat[client].MoneyEarned_CashMachine = value;
		case i_MoneyEarned_Give:return RoleplayIntStat[client].MoneyEarned_Give = value;
		case i_MoneySpent_Fines:return RoleplayIntStat[client].MoneySpent_Fines = value;
		case i_MoneySpent_Shop:return RoleplayIntStat[client].MoneySpent_Shop = value;
		case i_MoneySpent_Give:return RoleplayIntStat[client].MoneySpent_Give = value;
		case i_MoneySpent_Stolen:return RoleplayIntStat[client].MoneySpent_Stolen = value;
		case i_Vitality_OnConnection:return RoleplayIntStat[client].Vitality_OnConnection = value;
		case i_LotoSpent:return RoleplayIntStat[client].LotoSpent = value;
		case i_LotoWon:return RoleplayIntStat[client].LotoWon = value;
		case i_DrugPickedUp:return RoleplayIntStat[client].DrugPickedUp = value;
		case i_Kills:return RoleplayIntStat[client].Kills = value;
		case i_Deaths:return RoleplayIntStat[client].Deaths = value;
		case i_ItemUsed:return RoleplayIntStat[client].ItemUsed = value;
		case i_ItemUsedPrice:return RoleplayIntStat[client].ItemUsedPrice = value;
		case i_PVP_OnConnection:return RoleplayIntStat[client].PVP_OnConnection = value;
		case i_TotalBuild:return RoleplayIntStat[client].TotalBuild = value;
		case i_RunDistance:return RoleplayIntStat[client].RunDistance = value;
		case i_JobSucess:return RoleplayIntStat[client].JobSucess = value;
		case i_JobFails:return RoleplayIntStat[client].JobFails = value;
		case i_LastDeathTimestamp:return RoleplayIntStat[client].LastDeathTimestamp = value;
		case i_LastKillTimestamp:return RoleplayIntStat[client].LastKillTimestamp = value;
	}	
	
	return -1;
}

public int Native_GetClientKeyVehicle(Handle plugin, int numParams) 
{
	int client = GetNativeCell(1);
	int entID = GetNativeCell(2);
	
	if(!IsClientValid(client))
	{
		//ThrowNativeError(SP_ERROR_NATIVE, "Client %i is not valid !", client);
		return -1;
	}
		
	if(asKey[client][entID])
		return true;
		
	return false;
}

public int Native_SetClientKeyVehicle(Handle plugin, int numParams) 
{
	int client = GetNativeCell(1);
	int entID = GetNativeCell(2);
	bool value = GetNativeCell(3);
	
	if(!IsClientValid(client))
	{
		//ThrowNativeError(SP_ERROR_NATIVE, "Client %i is not valid !", client);
		return -1;
	}
	
	return asKey[client][entID] = value;
}

public int Native_GetRank(Handle plugin, int numParams) 
{
	int rankid = GetNativeCell(1);
	int variable = GetNativeCell(2);
	int maxlen = GetNativeCell(4) + 1;
	
	switch(variable)
	{
		case rank_xpreq:SetNativeString(3, RoleplayCharRank[rankid].xpreq, maxlen);
		case rank_name:SetNativeString(3, RoleplayCharRank[rankid].name, maxlen);
		case rank_advantage:SetNativeString(3, RoleplayCharRank[rankid].advantage, maxlen);
	}
	
	//SetNativeString(3, rank_string[rankid][variable], maxlen);
	return -1;
}

public int Native_SetRank(Handle plugin, int numParams) 
{
	int rankid = GetNativeCell(1);
	int variable = GetNativeCell(2);
	int maxlen = GetNativeCell(4) + 1;
	
	switch(variable)
	{
		case rank_xpreq:GetNativeString(3, RoleplayCharRank[rankid].xpreq, maxlen);
		case rank_name:GetNativeString(3, RoleplayCharRank[rankid].name, maxlen);
		case rank_advantage:GetNativeString(3, RoleplayCharRank[rankid].advantage, maxlen);
	}

	return -1;
}

public int Native_IsValidRank(Handle plugin, int numParams) 
{
	int rankid = GetNativeCell(1);
			
	if(IsValidRank[rankid])
		return true;
	else
		return false;
}

public int Native_CanDrawPanel(Handle plugin, int numParams) 
{
	int client = GetNativeCell(1);
	
	if(!IsClientValid(client))
	{
		//ThrowNativeError(SP_ERROR_NATIVE, "Client %i is not valid !", client);
		return -1;
	}
	
	return canDrawPanel[client];
}

public any Native_GetGame(Handle plugin, int numParams) 
{
	return vEngine(g_engineversion);
}

public int Native_Close(Handle plugin, int numParams)
{
	Handle data = vHandle(GetNativeCell(1));
	int event = GetNativeCell(2);
	bool repeat = vbool(GetNativeCell(2));
	float duration = GetNativeCell(4);
	
	if(data == null)
		return -1;
		
	if(duration >= 0.1)
	{
		DataPack pack;
		CreateDataTimer(duration, Timer_DestroyHandle, pack);
		DestroyHandle = vEvent(data);
		pack.WriteCell(event);
		pack.WriteCell(repeat);
	}	
	else
	{		
		if(event)
			vEvent(data).Cancel();
		else
			TrashTimer(data, repeat);
	}		
	
	return 0;
}

public Action Timer_DestroyHandle(Handle timer, DataPack pack)
{
	pack.Reset();
	bool event = vbool(pack.ReadCell());
	bool repeat = vbool(pack.ReadCell());
	
	if(event)
	{
		//FireEvent(Event(DestroyHandle));
		//Event(data).Cancel();
		char strEvent[64];
		vEvent(DestroyHandle).GetName(STRING(strEvent));
		if(StrEqual(strEvent, "cs_win_panel_round"))
		{
			Event newevent_round = CreateEvent("round_start");
			LoopClients(z)
		      if(IsClientInGame(z) && !IsFakeClient(z))
		        newevent_round.FireToClient(z);
		
			newevent_round.Cancel(); 
		}
	}	
	else
		TrashTimer(DestroyHandle, repeat);
		
	return Plugin_Handled;
}

public int Native_GetClientResource(Handle plugin, int numParams) 
{
	int client = GetNativeCell(1);
	int id = GetNativeCell(2);
	
	if(!IsClientValid(client))
	{
		//ThrowNativeError(SP_ERROR_NATIVE, "Client %i is not valid !", client);
		return -1;
	}
		
	switch(id)
	{
		case resource_gold:return RoleplayIntResource[client].gold;
		case resource_steel:return RoleplayIntResource[client].steel;
		case resource_copper:return RoleplayIntResource[client].copper;
		case resource_aluminium:return RoleplayIntResource[client].aluminium;
		case resource_zinc:return RoleplayIntResource[client].zinc;
		case resource_wood:return RoleplayIntResource[client].wood;
		case resource_plastic:return RoleplayIntResource[client].plastic;
		case resource_water:return RoleplayIntResource[client].water;
	}	
	
	return -1;
}

public int Native_SetClientResource(Handle plugin, int numParams) 
{
	int client = GetNativeCell(1);
	int id = GetNativeCell(2);
	int value = GetNativeCell(3);
	
	if(!IsClientValid(client))
	{
		//ThrowNativeError(SP_ERROR_NATIVE, "Client %i is not valid !", client);
		return -1;
	}
		
	switch(id)
	{
		case resource_gold:return RoleplayIntResource[client].gold = value;
		case resource_steel:return RoleplayIntResource[client].steel = value;
		case resource_copper:return RoleplayIntResource[client].copper = value;
		case resource_aluminium:return RoleplayIntResource[client].aluminium = value;
		case resource_zinc:return RoleplayIntResource[client].zinc = value;
		case resource_wood:return RoleplayIntResource[client].wood = value;
		case resource_plastic:return RoleplayIntResource[client].plastic = value;
		case resource_water:return RoleplayIntResource[client].water = value;
	}	
	
	return -1;	
}

public any Native_GetEntityHealth(Handle plugin, int numParams) 
{
	int entity = GetNativeCell(1);
	
	if(!IsValidEntity(entity))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "Entity %i is not valid !", entity);
		return -1;
	}	
		
	return g_fHealth[entity];
}

public any Native_SetEntityHealth(Handle plugin, int numParams) 
{
	int entity = GetNativeCell(1);
	float value = GetNativeCell(2);
	
	if(!IsValidEntity(entity))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "Entity %i is not valid !", entity);
		return -1;
	}
	
	return g_fHealth[entity] = value;
}

public int Native_GetJobName(Handle plugin, int numParams) 
{
	int jobid = GetNativeCell(1);
	int maxlen = GetNativeCell(3) + 1;
			
	SetNativeString(2, job[jobid].name, maxlen);
	return -1;
}

public int Native_SetJobName(Handle plugin, int numParams) 
{
	int jobid = GetNativeCell(1);
	int maxlen = GetNativeCell(3) + 1;
	
	GetNativeString(2, job[jobid].name, maxlen);
	
	return -1;
}

public int Native_GetJobCapital(Handle plugin, int numParams) 
{
	int jobid = GetNativeCell(1);
	return job[jobid].capital;
}

public int Native_SetJobCapital(Handle plugin, int numParams) 
{
	int jobid = GetNativeCell(1);
	int value = GetNativeCell(2);
	
	job[jobid].capital = value;
	
	// FIX FIX FIX FIX FIX ADD HTTP JSON POST TO CHANGE CAPITAL FROM HOST 
	
	return -1;
}

public int Native_GetJobMaxGrades(Handle plugin, int numParams) 
{
	int jobid = GetNativeCell(1);
	return job[jobid].max_grades;
}

public int Native_GetGradeName(Handle plugin, int numParams) 
{
	int jobid = GetNativeCell(1);
	int gradeid = GetNativeCell(2);
	int maxlen = GetNativeCell(4) + 1;
			
	SetNativeString(3, grade[jobid][gradeid].name, maxlen);
	return -1;
}

public int Native_SetGradeName(Handle plugin, int numParams) 
{
	int jobid = GetNativeCell(1);
	int gradeid = GetNativeCell(2);
	int maxlen = GetNativeCell(4) + 1;
	
	GetNativeString(3, grade[jobid][gradeid].name, maxlen);
	
	return -1;
}

public int Native_GetGradeClantag(Handle plugin, int numParams) 
{
	int jobid = GetNativeCell(1);
	int gradeid = GetNativeCell(2);
	int maxlen = GetNativeCell(4) + 1;
			
	SetNativeString(3, grade[jobid][gradeid].clantag, maxlen);
	return -1;
}

public int Native_SetGradeClantag(Handle plugin, int numParams) 
{
	int jobid = GetNativeCell(1);
	int gradeid = GetNativeCell(2);
	int maxlen = GetNativeCell(4) + 1;
	
	GetNativeString(3, grade[jobid][gradeid].clantag, maxlen);
	
	return -1;
}

public int Native_GetGradeSalary(Handle plugin, int numParams) 
{
	int jobid = GetNativeCell(1);
	int gradeid = GetNativeCell(2);
	return grade[jobid][gradeid].salary;
}

public int Native_SetGradeSalary(Handle plugin, int numParams) 
{
	int jobid = GetNativeCell(1);
	int gradeid = GetNativeCell(2);
	
	grade[jobid][gradeid].salary = GetNativeCell(3);
	
	return -1;
}

public int Native_GetGradeModel(Handle plugin, int numParams) 
{
	int jobid = GetNativeCell(1);
	int gradeid = GetNativeCell(2);
	int maxlen = GetNativeCell(4) + 1;
			
	SetNativeString(3, grade[jobid][gradeid].model, maxlen);
	return -1;
}

public int Native_SetGradeModel(Handle plugin, int numParams) 
{
	int jobid = GetNativeCell(1);
	int gradeid = GetNativeCell(2);
	int maxlen = GetNativeCell(4) + 1;
	
	GetNativeString(3, grade[jobid][gradeid].model, maxlen);
	
	return -1;
}

public int Native_Slay(Handle plugin, int numParams) 
{
	int client = GetNativeCell(1);
	
	if(!IsClientValid(client))
	{
		//ThrowNativeError(SP_ERROR_NATIVE, "Client %i is not valid !", client);
		return -1;
	}
	
	PerformSmite(client);
	
	return -1;
}

public int Native_BuildProp(Handle plugin, int numParams) 
{
	int entity = GetNativeCell(1);
	
	if(!IsValidEntity(entity))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "Entity %i is not valid !", entity);
		return -1;
	}
	
	PrecacheSound("ambient/machines/hydraulic_1.wav");
	EmitSoundToAll("ambient/machines/hydraulic_1.wav", entity, _, _, _, 1.0);
	
	SetEntityRenderMode(entity, RENDER_TRANSCOLOR);
	SetEntityRenderColor(entity, 255, 255, 255, 15);
	CreateTimer(0.15, Timer_BuildProp, entity);
	
	return -1;
}

public int Native_GetGlobalData(Handle plugin, int numParams) 
{
	char sTmp[MAX_BUFFER_LENGTH + 1];
	GetNativeString(1, STRING(sTmp));
	
	if(g_hGlobalData != null)
	{
		char sValue[MAX_BUFFER_LENGTH + 1];
		g_hGlobalData.GetString(sTmp, STRING(sValue));
		int maxlen = GetNativeCell(3) + 1;
		
		SetNativeString(2, sValue, maxlen);
		
		return 0;
	}
	else
		return -1;
}

public int Native_GetEntityOwner(Handle plugin, int numParams) 
{
	int entity = GetNativeCell(1);
	
	if(!IsValidEntity(entity))
		return -1;
		
	if(!IsClientValid(g_iEntityOwner[entity]))
		return -1;
		
	return g_iEntityOwner[entity];
}

public int Native_SetEntityOwner(Handle plugin, int numParams) 
{
	int entity = GetNativeCell(1);
	int value = GetNativeCell(2);
	
	if(!IsValidEntity(entity))
		return -1;
		
	return g_iEntityOwner[entity] = value;
}

public int Native_IsEntityValidRoleplay(Handle plugin, int numParams) 
{
	int entity = GetNativeCell(1);
	
	if(!IsValidEntity(entity))
		return -1;
		
	return g_bEntityValidRP[entity];
}

public int Native_GetJobDoors(Handle plugin, int numParams) 
{
	int id = GetNativeCell(1);
	int maxlen = GetNativeCell(3) + 1;

	if(id > MAXJOBS)
		return -1;
	
	SetNativeString(2, job[id].doors, maxlen);

	return 0;
}

public int Native_SetJobDoors(Handle plugin, int numParams) 
{
	int id = GetNativeCell(1);
	int maxlen = GetNativeCell(3) + 1;

	if(id > MAXJOBS)
		return -1;
	
	GetNativeString(2, job[id].doors, maxlen);

	return 0;
}

public int Native_GetDoorJob(Handle plugin, int numParams) 
{
	int entity = GetNativeCell(1);
	int result = 0;
	
	if(!rp_IsValidDoor(entity))
		return -1;
		
	char sName[64];
	Entity_GetName(entity, STRING(sName));
	
	char sTmp[128];
	for (int i = 1; i <= g_aDoorsData.Length; i++) 
	{
		g_aDoorsData.GetString(i, STRING(sTmp));
		
		char sBuffer[2][64];
		ExplodeString(sTmp, "|", sBuffer, 2, 64);
		
		if(StrContains(sName, sBuffer[1], false) != -1)
		{
			result = i;
			break;
		}
	}

	return result;
}

public int Native_GetHudType(Handle plugin, int numParams) 
{
	return view_as<int>(g_hHudType[GetNativeCell(1)]);
}

public int Native_SetHudType(Handle plugin, int numParams) 
{
	g_hHudType[GetNativeCell(1)] = view_as<HUD_TYPE>(GetNativeCell(2));
	
	return 0;
}

public int Native_CanJobSell(Handle plugin, int numParams) 
{
	int id = GetNativeCell(1);
	
	if(id > MAXJOBS)
		return -1;

	return job[id].cansell;
}

public int Native_SetCanJobSell(Handle plugin, int numParams) 
{
	int id = GetNativeCell(1);
	bool value = view_as<bool>(GetNativeCell(2));
	
	if(id > MAXJOBS)
		return -1;
	
	job[id].cansell = value;

	return 0;
}

public int Native_GetTime(Handle plugin, int numParams) 
{
	int variable = GetNativeCell(1);
	
	switch(variable)
	{
		case i_hour1:return RoleplayTime.hour1;
		case i_hour2:return RoleplayTime.hour2;
		case i_minute1:return RoleplayTime.minute1;
		case i_minute2:return RoleplayTime.minute2;
		case i_day:return RoleplayTime.day;
		case i_month:return RoleplayTime.month;
		case i_year:return RoleplayTime.year;
	}
	
	return -1;
}

public int Native_SetTime(Handle plugin, int numParams) 
{
	int variable = GetNativeCell(1);
	int value = GetNativeCell(2);
	
	switch(variable)
	{
		case i_hour1:return RoleplayTime.hour1 = value;
		case i_hour2:return RoleplayTime.hour2 = value;
		case i_minute1:return RoleplayTime.minute1 = value;
		case i_minute2:return RoleplayTime.minute2 = value;
		case i_day:return RoleplayTime.day = value;
		case i_month:return RoleplayTime.month = value;
		case i_year:return RoleplayTime.year = value;
	}
	
	return -1;
}

/***************************************************************************************

									C A L L B A C K

***************************************************************************************/

public void OnEntityCreated(int entity, const char[] classname)
{
  	if(StrContains(classname, "prop_physic") != -1)
  	{
		rp_SetEntityHealth(entity, 100.0);
		SDKHook(entity, SDKHook_Touch, OnStartTouch);
		g_bEntityValidRP[entity] = true;
	}
	else if(StrEqual(classname, "prop_vehicle_driveable"))
	{
		SDKHook(entity, SDKHook_Touch, OnStartTouch);
	}	
}

public void OnEntityDestroyed(int entity)
{
	SDKUnhook(entity, SDKHook_Touch, OnStartTouch);
}

public Action OnStartTouch(int caller, int activator)
{
	if (IsValidEntity(caller) && IsValidEntity(activator))
	{
		Call_StartForward(Forward.OnTouch);
		Call_PushCell(caller);
		Call_PushCell(activator);		
		Call_Finish();
	}
	//PrintToChatAll("touch");
	
	return Plugin_Handled;
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon)
{	
	if(buttons != 0) 
		ResetAFK(client);
	
	if (!button[client].E && buttons & IN_USE)
	{
		button[client].E = true;
		
		char entName[128], entClassName[64], entModel[128];		
		int target = GetClientAimTarget(client, false);
		
		if (target != -1 && IsValidEntity(target))
		{
			Entity_GetName(target, STRING(entName));
			Entity_GetModel(target, STRING(entModel));
			Entity_GetClassName(target, STRING(entClassName));
		
			Call_StartForward(Forward.OnInteract);
			Call_PushCell(client);
			Call_PushCell(target);
			Call_PushString(entClassName);
			Call_PushString(entModel);	
			Call_PushString(entName);
			Call_Finish();
		}
	}	
	else if(button[client].E && !(buttons & IN_USE))
		button[client].E = false;
		
	if (!button[client].R && buttons & IN_RELOAD)
	{
		button[client].R = true;
		
		Call_StartForward(Forward.OnReload);
		Call_PushCell(client);
		Call_Finish();
	}	
	else if(button[client].R && !(buttons & IN_RELOAD))
		button[client].R = false;
		
	if (!button[client].CTRL && buttons & IN_DUCK)
	{
		button[client].CTRL = true;
		
		Call_StartForward(Forward.OnDuck);
		Call_PushCell(client);
		Call_Finish();
	}	
	else if(button[client].CTRL && !(buttons & IN_DUCK))
		button[client].CTRL = false;
		
	if (buttons & IN_ATTACK2)
	{
		char buffer[128];
		
		int item = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		
		// prevent log errors
		if(item == -1)
			return Plugin_Continue;
		
		GetEntityClassname(item, STRING(buffer));
		
		if (StrEqual(buffer, "weapon_fists", false) && rp_GetClientBool(client, b_IsPassive))
		{
			buttons &= ~IN_ATTACK2; //Don't press attack 2
			return Plugin_Changed;
		}		
	}	
	else if(buttons & IN_ATTACK)
	{
		if(rp_GetClientBool(client, b_IsPassive))
		{
			buttons &= ~IN_ATTACK; //Don't press attack 1
			return Plugin_Changed;
		}
	}
	else if(buttons & IN_JUMP)
	{
		if(!IsPlayerAlive(client))
		{
			buttons &= ~IN_JUMP; //Don't press Space
			return Plugin_Changed;
		}
	}
	
	if (!button[client].R && buttons & IN_RELOAD)
	{
		button[client].R = true;
		
		Call_StartForward(Forward.OnReload);
		Call_PushCell(client);
		Call_Finish();
	}	
	else if(button[client].R && !(buttons & IN_RELOAD))
		button[client].R = false;
	
	return Plugin_Continue;
}

public Action Event_Round(Event event, const char[] name, bool dontBroadcast)
{
	#if DEBUG
		PrintToServer("Event: %s", name);
	#endif
	
	return Plugin_Handled;
}

public Action Event_OnDeath(Event event, const char[] name, bool dontBroadcast)
{
	#if DEBUG
		PrintToServer("Event: %s", name);
	#endif
    
	char weapon[64];
	event.GetString("weapon", STRING(weapon));
	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	int victim = GetClientOfUserId(event.GetInt("userid"));
	
	char zone[64];
	rp_GetClientString(victim, sz_ZoneName, STRING(zone));
	
	if(attacker == victim)
		weapon = "Suicide";
	
	SQL_Request(g_DB, "INSERT IGNORE INTO `rp_kills` (`id`, `playerid_killer`, `playerid_victim`, `arme`, `zone`) VALUES (NULL, '%i', '%i', '%s', '%s');", rp_GetSQLID(attacker), rp_GetSQLID(victim), weapon, zone);
	
	if(attacker != victim)
	{
		rp_SetClientStat(attacker, i_Kills, rp_GetClientStat(attacker, i_Kills) + 1);
		rp_SetClientStat(victim, i_Deaths, rp_GetClientStat(victim, i_Deaths) + 1);
		
		rp_SetClientStat(attacker, i_LastKillTimestamp, GetTime());
		rp_SetClientStat(victim, i_LastDeathTimestamp, GetTime());
		SQL_Request(g_DB, "INSERT IGNORE INTO `rp_kills` (`id`, `playerid_killer`, `playerid_victim`, `arme`, `zone`) VALUES (NULL, '%i', '%i', '%s', '%s');", rp_GetSQLID(attacker), rp_GetSQLID(victim), weapon, zone);
	}
 
	/**********************************************************************
	*							RP_OnClientDeath
	***********************************************************************/
	Call_StartForward(Forward.OnDeath); 
	Call_PushCell(attacker);
	Call_PushCell(victim);
	Call_PushString(weapon);
	Call_PushCell(event.GetInt("headshot"));
	Call_Finish();
	
	/**********************************************************************
	*					Play death sound & display overlay
	***********************************************************************/
	
	char sTmp[128];
	rp_GetGlobalData("sound_wasted", STRING(sTmp));
	if(!StrEqual(sTmp, ""))
		rp_Sound(victim, sTmp, 1.0);
	
	rp_GetGlobalData("overlay_death", STRING(sTmp));
	ScreenOverlay(victim, sTmp);
	
	ScreenFade(victim, 5, {0, 0, 0, 200});

	switch(rp_GetAdmin(victim))
	{
		case ADMIN_FLAG_OWNER: g_iTimerRespawn[victim] = 2.0;
		case ADMIN_FLAG_ADMIN: g_iTimerRespawn[victim] = 5.0;
		case ADMIN_FLAG_MODERATOR: g_iTimerRespawn[victim] = 7.0;
		default: g_iTimerRespawn[victim] = RoleplayCvar.respawn.FloatValue;
	}
		
	CreateTimer(0.1, Timer_Respawn, victim, TIMER_REPEAT);
	return Plugin_Handled;
}

public Action Event_OnRoundStart(Event event, const char[] name, bool dontBroadcast)
{
	#if DEBUG
		PrintToServer("Event: %s", name);
	#endif
    
	/**********************************************************************
	*							RP_OnRoundStart
	***********************************************************************/
	Call_StartForward(Forward.OnRoundStart); 
	Call_Finish();
	
	return Plugin_Handled;
}

public Action Event_OnFire(Event event, const char[] name, bool dontBroadcast)
{
	#if DEBUG
		PrintToServer("Event: %s", name);
	#endif
	
	Action result;
	char weapon[64];
	event.GetString("weapon", STRING(weapon));
	int client = GetClientOfUserId(event.GetInt("userid"));
	int target = GetClientAimTarget(client, false);

	Call_StartForward(Forward.OnFire);
	Call_PushCell(client);
	Call_PushCell(target);
	Call_PushString(weapon);
	Call_Finish(result);
	
	if(IsValidEntity(target))
	{
		if (!StrEqual(weapon, "weapon_fists") && !IsClientValid(target) && g_bEntityValidRP[target])
		{
			float reduce = GetRandomFloat(2.0, 25.0);
			
			if(rp_GetEntityHealth(target) > 0.0 && (rp_GetEntityHealth(target) - reduce) > 0.1)
			{
				Call_StartForward(Forward.OnReduceHealth);
				Call_PushCell(target);
				Call_PushFloat(rp_GetEntityHealth(target));
				Call_PushFloat(reduce);
				Call_Finish();
				
				rp_SetEntityHealth(target, rp_GetEntityHealth(target) - reduce);
				rp_DisplayHealth(client, target, 0.0, 0, true);
			}
			else
			{
				Call_StartForward(Forward.OnEndLife);
				Call_PushCell(target);
				Call_Finish();
				
				RemoveEntity(target);
			}
		}
	}	

	return result;
}

public Action Event_OnSpawn(Event event, const char[] name, bool dontBroadcast)
{
	#if DEBUG
		PrintToServer("Event: %s", name);
	#endif
    
	int client = GetClientOfUserId(event.GetInt("userid"));
 
	Call_StartForward(Forward.OnSpawn); 
	Call_PushCell(client);
	Call_Finish();
	
	if(GetClientTeam(client) == CS_TEAM_CT && rp_GetClientInt(client, i_Job) != 1 || rp_GetClientInt(client, i_Job) != 1)
		ChangeClientTeam(client, CS_TEAM_T);
 
 	ClientCommand(client, "r_screenoverlay 0");
 	
 	int weapon;
	while((weapon = GetPlayerWeaponSlot(client, CS_SLOT_KNIFE)) != -1)
	{
		RemovePlayerItem(client, weapon);
		AcceptEntityInput(weapon, "Kill");
	}
	
	int iMelee = 0;
	
	if(g_engineversion != Engine_CSS)
		iMelee = GivePlayerItem(client, "weapon_fists");
	else
		iMelee = GivePlayerItem(client, "weapon_knife");
	
	EquipPlayerWeapon(client, iMelee);
	
	//player.SetSkin();
	
	/*if(IsBenito(client))
	{
		PrecacheAndSetModel(client, "models/player/custom_player/legacy/gxp/bioshock/baguette_boy/boy_v1.mdl");
		PrecacheAndSetArms(client, "models/player/custom_player/legacy/gxp/bioshock/baguette_boy/boy_arm_v1.mdl");
	}*/
	
	return Plugin_Handled;
}

public Action Event_OnHurt(Event event, const char[] name, bool dontBroadcast)
{
	#if DEBUG
		PrintToServer("Event: %s", name);
	#endif
    
	char weaponName[64];
	event.GetString("weapon", STRING(weaponName));
	
	int client = GetClientOfUserId(event.GetInt("userid"));
	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	int damage = event.GetInt("dmg_health");
	int armor = event.GetInt("dmg_armor");
	
	if(!IsClientValid(attacker))
		return Plugin_Handled;
		
	rp_DisplayHealth(attacker, client, float(damage), 0, false);
	
	Call_StartForward(Forward.OnHurt); 
	Call_PushCell(client);
	Call_PushCell(attacker);
	Call_PushCell(damage);
	Call_PushCell(armor);
	Call_PushString(weaponName);
	Call_Finish();
	
	return Plugin_Handled;
}

public Action Event_OnConnect(Event event, const char[] name, bool dontBroadcast) 
{
	#if DEBUG
		PrintToServer("Event: %s", name);
	#endif	
	
	if (!dontBroadcast) 
	{
		char sName[33];
		event.GetString("name", STRING(sName));
		
		int client = GetClientOfUserId(event.GetInt("userid"));
		Event hEvent = CreateEvent("player_connect", true);
		hEvent.SetString("name", sName);
		hEvent.SetInt("index", event.GetInt("index"));
		hEvent.SetInt("userid", client);		
		hEvent.Fire(true);
		
		if(client == 0)
			return Plugin_Handled;
		
		char playername[64];
		GetClientName(client, STRING(playername));
		
		char country[64];
		GetCountryPrefix(client, STRING(country));
		
		//CPrintToChatAll("%s %t", "Core_PlayerJoin", LANG_SERVER, playername);
		rp_PrintToChatAll("Le citoyen %s (%s|%s) a rejoint la ville.", playername, steamID[client], country);
		
		char message[128];
		Format(STRING(message), "%T", "player_join", LANG_SERVER, client, clientIP[client], steamID[client]);	
		rp_LogToDiscord(message);
		
		return Plugin_Handled;
	}
	
	return Plugin_Continue;
}

public Action Event_OnDisconnect(Event event, const char[] name, bool dontBroadcast) 
{
	#if DEBUG
		PrintToServer("Event: %s", name);
	#endif
	
	if (!dontBroadcast) 
	{
		char sName[33];
		event.GetString("name", STRING(sName));
		
		int client = GetClientOfUserId(event.GetInt("userid"));
		
		/*
		Event hEvent = CreateEvent("player_disconnect", true);
		hEvent.SetInt("userid", client);
		hEvent.SetString("name", sName);
		hEvent.Fire(true);*/
		
		if(client == 0)
			return Plugin_Handled;
		
		char client_name[64];
		GetClientName(client, STRING(client_name));
		
		char country[64];
		GetCountryPrefix(client, STRING(country));
		
		rp_PrintToChatAll("%t", "Core_PlayerLeft", LANG_SERVER, client_name);
		
		char message[128];
		Format(STRING(message), "%T", "player_left", LANG_SERVER, client_name, country, steamID[client]);	
		rp_LogToDiscord(message);
		
		return Plugin_Handled;
	}
	
	return Plugin_Continue;
}

public Action Event_OnFootstep(Event event, const char[] name, bool dontBroadcast) 
{
	#if DEBUG
		PrintToServer("Event: %s", name);
	#endif
	
	int client = GetClientOfUserId(event.GetInt("userid"));
	if(!IsClientValid(client))
		return Plugin_Handled;
		
	Call_StartForward(Forward.OnFootstep); 
	Call_PushCell(client);
	Call_Finish();		
	
	//return Plugin_Continue;
	return Plugin_Handled;
}

public Action Timer_DisplayLogo(Handle timer, int client)
{
	//ShowPanel2(client, 10, "<img src='https://panel.enemy-down.fr/themes/Obsidian/images/logo.png'><br> Vous souhaite la bienvenue <font color='%s'>!</font>", HTML_CHARTREUSE);
	ShowPanel2(client, 10, "<span class='fontSize-xxxl'> <strong><font color='#00FF97'>ROLEPLAY</font></strong></span> \n <em>By <font color='#FF0068'>Mbk</font></em>");
	
	return Plugin_Handled;
}

public Action Timer_EverySecond(Handle timer)
{	
	Call_StartForward(Forward.OnTimerSecond); 
	Call_Finish();	
	
	for (int entity = 0; entity <= MAXENTITIES; entity++)
	{
		if(!IsValidEntity(entity))
			continue;
			
		if(IsClientValid(entity))
		{
			Call_StartForward(Forward.OnClientTimerSecond);
			Call_PushCell(entity);
			Call_Finish();
			
			int client = entity;
			int target = GetClientAimTarget(client, false);
			if(IsValidEntity(target))
			{
				if(Distance(client, target) <= 120.0)
				{
					char model[256];
					Entity_GetModel(target, STRING(model));
					
					Call_StartForward(Forward.OnLookAtTarget);
					Call_PushCell(client);
					Call_PushCell(target);
					Call_PushString(model);
					Call_Finish();
					
					char entName[128];
					Entity_GetName(target, STRING(entName));
					int owner = Client_FindBySteamId(entName);
					
					char sModel[128];
					
					rp_GetGlobalData("model_acetone", STRING(sModel));
					if (StrEqual(model, sModel))
					{
						PrintHintText(client, "<font color='#CAC8C5'>Acetone</font>\n<font color='#750B04'>Extrêmement Inflammable</font>\nProps de: <font color='#00A9FF'>%N</font>\nVie: <font color='#D4AE0C'>%0.1f</font>", owner, rp_GetEntityHealth(target));
					}	
					
					rp_GetGlobalData("model_ammoniac", STRING(sModel));
					if (StrEqual(model, sModel))
					{
						PrintHintText(client, "<font color='#CAC8C5'>Amoniaque</font>\n<font color='#750B04'>Extrêmement Inflammable</font>\nProps de: <font color='#00A9FF'>%N</font>\nVie: <font color='#D4AE0C'>%0.1f</font>", owner, rp_GetEntityHealth(target));
					}
					
					rp_GetGlobalData("model_bismuth", STRING(sModel));
					if (StrEqual(model, sModel))
					{
						PrintHintText(client, "<font color='#CAC8C5'>Bismuth</font>\n<font color='#750B04'>Inflammable</font>\nProps de: <font color='#00A9FF'>%N</font>\nVie: <font color='#D4AE0C'>%0.1f</font>", owner, rp_GetEntityHealth(target));
					}
					
					rp_GetGlobalData("model_phosphore", STRING(sModel));
					if (StrEqual(model, sModel))
					{
						PrintHintText(client, "<font color='#CAC8C5'>Acide Phosphorique</font>\n<font color='#750B04'>Extrêmement Inflammable & Très Corrosif</font>\nProps de: <font color='#00A9FF'>%N</font>\nVie: <font color='#D4AE0C'>%0.1f</font>", owner, rp_GetEntityHealth(target));
					}
					
					rp_GetGlobalData("model_sulfuric", STRING(sModel));
					if (StrEqual(model, sModel))
					{
						PrintHintText(client, "<font color='#CAC8C5'>Acide Sulfurique</font>\n<font color='#750B04'>Extrêmement Inflammable & Très Corrosif</font>\nProps de: <font color='#00A9FF'>%N</font>\nVie: <font color='#D4AE0C'>%0.1f</font>", owner, rp_GetEntityHealth(target));
					}
					
					rp_GetGlobalData("model_sodium", STRING(sModel));
					if (StrEqual(model, sModel))
					{
						PrintHintText(client, "<font color='#CAC8C5'>Sodium</font>\n<font color='#750B04'>Très Corrosif</font>\nProps de: <font color='#00A9FF'>%N</font>\nVie: <font color='#D4AE0C'>%0.1f</font>", owner, rp_GetEntityHealth(target));
					}
					
					rp_GetGlobalData("model_toulene", STRING(sModel));
					if (StrEqual(model, sModel))
					{
						PrintHintText(client, "<font color='#CAC8C5'>Toulenne</font>\n<font color='#750B04'>Extrêmement Inflammable</font>\nProps de: <font color='#00A9FF'>%N</font>\nVie: <font color='#D4AE0C'>%0.1f</font>", owner, rp_GetEntityHealth(target));
					}
					
					rp_GetGlobalData("model_cocaine", STRING(sModel));
					if (StrEqual(model, sModel))
					{
						PrintHintText(client, "<font color='#CAC8C5'>Cocaïne Céllophané</font>\n<font color='#750B04'>Produit Illicite</font>\nProps de: <font color='#00A9FF'>%N</font>\nVie: <font color='#D4AE0C'>%0.1f</font>", owner, rp_GetEntityHealth(target));
					}
				
					rp_GetGlobalData("model_battery", STRING(sModel));
					if (StrEqual(model, sModel))
					{
						PrintHintText(client, "<font color='#CAC8C5'>Batterie Lithium</font>\n<font color='#750B04'>Contient de l'acide !</font>\nProps de: <font color='#00A9FF'>%N</font>\nVie: <font color='#D4AE0C'>%0.1f</font>", owner, rp_GetEntityHealth(target));
					}
					
					rp_GetGlobalData("model_water", STRING(sModel));
					if (StrEqual(model, sModel))
					{
						PrintHintText(client, "<font color='#CAC8C5'>Bidon d'eau</font>\nProps de: <font color='#00A9FF'>%N</font>\nVie: <font color='#D4AE0C'>%0.1f</font>", owner, rp_GetEntityHealth(target));
					}
					
					rp_GetGlobalData("model_airdrop", STRING(sModel));
					if (StrEqual(model, sModel))
					{
						PrintHintText(client, "<font color='#CAC8C5'>Drop Aerien</font>\nProps de: <font color='#00A9FF'>%N</font>\nVie: <font color='#D4AE0C'>%0.1f</font>", owner, rp_GetEntityHealth(target));
					}
					
					if(IsClientValid(target))
					{
						if(!rp_GetClientBool(target, b_IsOnAduty))
						{
							char jobname[64];
							rp_GetJobName(rp_GetClientInt(target, i_Job), STRING(jobname));
							
							char name[64];
							Format(STRING(name), "%N", target);
							
							char info[128];
							Format(STRING(info), "%T", "Hud_Target", LANG_SERVER, name, GetClientHealth(target), jobname);
							HintColorToCss(STRING(info));
							PrintHintText(client, info);
						}	
					}
					else if(Vehicle_IsValid(target))
					{
						int health = Vehicles_GetVehicleHealth(target);
						
						char info[256];
						VehicleType vehicle_type;
						Vehicles_GetVehicleTypeOfVehicle(target, vehicle_type);
						
						if(IsClientValid(Vehicles_GetVehicleOwner(target)))
							Format(STRING(info),  "%T", "Car_Target", LANG_SERVER, vehicle_type.name, Vehicles_GetVehicleOwner(target), health);	
						else
							Format(STRING(info), "%T", "Car_Target", LANG_SERVER, vehicle_type.name, "X", health);
							
						HintColorToCss(STRING(info));	
						PrintHintText(client, info);
					}
					else if(rp_IsValidDoor(target))
					{
						char buffer[2][32], nameDisplay[64], authorisation[64];
						ExplodeString(entName, "_", buffer, 2, 32);
						if(!StrEqual(buffer[1], "appart") && !StrEqual(buffer[1], "villa") && !StrEqual(buffer[1], "hotel"))
						{
							Format(STRING(nameDisplay), "<font color='#626563'>Inconnu</font>");
						
							if(rp_HasDoorAccess(client, target))
								Format(STRING(authorisation), "<font color='#00FF2E'>Vous avez les clées</font>");
							else
								Format(STRING(authorisation), "<font color='#FF0000'>Vous n'avez pas les clées</font>");
								
							HintColorToCss(STRING(authorisation));
							
							rp_GetJobName(rp_GetDoorJobID(target), STRING(nameDisplay));
							Format(STRING(nameDisplay), "<font color='#FFBB00'>%s</font>", nameDisplay);
							HintColorToCss(STRING(nameDisplay));
								
							PrintHintText(client, "Porte %s\n%s", nameDisplay, authorisation);	
						}
					}
				}	
			}
		}
		else
		{
			Call_StartForward(Forward.OnEntityTimerSecond);
			Call_PushCell(entity);
			Call_Finish();
		}
	}
	
	if(CanStartClock)
	{
		rp_SetTime(i_minute2, rp_GetTime(i_minute2) + 1);
		if(rp_GetTime(i_minute2) > 9)
		{
			rp_SetTime(i_minute2, 0);
			rp_SetTime(i_minute1, rp_GetTime(i_minute1) + 1);
			
			if(rp_GetTime(i_minute1) > 5 && rp_GetTime(i_minute2) >= 0)
			{
				rp_SetTime(i_minute1, 0);
				rp_SetTime(i_hour2, rp_GetTime(i_hour2) + 1);
				
				if(rp_GetTime(i_hour2) > 9)
				{
					rp_SetTime(i_hour2, 0);
					rp_SetTime(i_hour1, rp_GetTime(i_hour1) + 1);
				}
			}
		}
		
		if(rp_GetTime(i_hour1) >= 2 && rp_GetTime(i_hour2) >= 4)
		{
			rp_SetTime(i_hour1, 0);
			rp_SetTime(i_hour2, 0);
			rp_SetTime(i_day, rp_GetTime(i_day) + 1);
			
			Call_StartForward(Forward.OnNewDay);
			Call_Finish();
		}
		if(rp_GetTime(i_month) == 2)
		{
			if(rp_GetTime(i_day) >= 28)
			{
				rp_SetTime(i_month, rp_GetTime(i_month) + 1);
				rp_SetTime(i_day, 1);
			}
		}
		else if(rp_GetTime(i_month) == 4 || rp_GetTime(i_month) == 6 || rp_GetTime(i_month) == 9 || rp_GetTime(i_month) == 11)
		{
			if(rp_GetTime(i_day) >= 30)
			{
				rp_SetTime(i_month, rp_GetTime(i_month) + 1);
				rp_SetTime(i_day, 1);
			}
		}
		else
		{
			if(rp_GetTime(i_day) >= 31)
			{
				rp_SetTime(i_month, rp_GetTime(i_month) + 1);
				rp_SetTime(i_day, 1);
			}
		}
		if(rp_GetTime(i_month) >= 12)
		{
			rp_SetTime(i_month, 1);
			rp_SetTime(i_year, rp_GetTime(i_year) + 1);
		}
		

		Call_StartForward(Forward.OnClockChange);
		Call_Finish();
	}
	
	return Plugin_Handled;
}	

public Action Timer_Every5Second(Handle timer)
{	
	Call_StartForward(Forward.OnTimer5Second); 
	Call_Finish();
	
	return Plugin_Handled;
}	

public Action Event_Disable(Event event, const char[] name, bool dontBroadcast)
{
	#if DEBUG
		PrintToServer("Event: %s", name);
	#endif
	
	return Plugin_Handled;
}

public Action CS_OnTerminateRound(float &delay, CSRoundEndReason &reason)
{
	if (reason == CSRoundEnd_GameStart)
		return Plugin_Handled;
	
	return Plugin_Handled;
}

public Action Command_Block(int client, int args)
{
	return Plugin_Handled;
}	

public Action Listener_Radio(int client, char[] cmd, int args)
{
	#if DEBUG
		PrintToServer("Command listener: %s", cmd);
	#endif
	return Plugin_Handled;
}

public Action Listener_SayTeam(int client, char[] Cmd, int args)
{
	if(client > 0)
	{
		if(IsClientValid(client))
		{
			char arg[256];
			GetCmdArgString(STRING(arg));
			StripQuotes(arg);
			TrimString(arg);
			
			TextColorToCss(STRING(arg));
			
			char strName[32];
			GetClientName(client, STRING(strName));
			
			if (strcmp(arg, " ") == 0 || strcmp(arg, "") == 0 || strlen(arg) == 0 || StrContains(arg, "!") == 0 || StrContains(arg, "/") == 0 || StrContains(arg, "@") == 0)
			{
				return Plugin_Handled;
			}
			else if (!IsPlayerAlive(client))
			{
				rp_PrintToChat(client, "%T", "Tchat_NoAlive", LANG_SERVER);
				return Plugin_Handled;
			}
			
			char strPseudo[256];
			
			if(rp_GetClientBool(client, b_IsMuteLocal)) 
			{
				rp_PrintToChat(client, "%T", "Tchat_Muted", LANG_SERVER);
				return Plugin_Stop;
			}
			else
			{						
				if(!rp_GetClientBool(client, b_HasColorPallet)) 
				{
					char buffer[256];
					strcopy(STRING(buffer), arg);
					
					CRemoveTags(STRING(buffer));
					CRemoveTags(STRING(strName));
				}
				
				if(!rp_GetClientBool(client, b_MayTalk))
				{
					rp_PrintToChat(client, "%T", "Tchat_Cooldown", LANG_SERVER);
					return Plugin_Stop;
				}
				else
				{
					Format(STRING(strPseudo), "{lightred}[LOCAL]{grey}%s", strName);						
					CPrintToChatAll("%s {default}: %s", strPseudo, arg);	
				}	

				rp_SetClientBool(client, b_MayTalk, false);
				CreateTimer(5.0, AllowTalking, client);
			}	
			
			Call_StartForward(Forward.OnSayTeam);
			Call_PushCell(client);
			Call_PushString(arg);
			Call_Finish();	
		}
	}
	
	return Plugin_Handled;
}

public Action Listener_Say(int client, char[] Cmd, int args)
{
	if(client > 0)
	{
		if(IsClientValid(client))
		{
			char arg[256];
			GetCmdArgString(STRING(arg));
			StripQuotes(arg);
			TrimString(arg);
			
			TextColorToCss(STRING(arg));
			
			char strName[32];
			GetClientName(client, STRING(strName));
			
			if (strcmp(arg, " ") == 0 || strcmp(arg, "") == 0 || strlen(arg) == 0 || StrContains(arg, "!") == 0 || StrContains(arg, "/") == 0 || StrContains(arg, "@") == 0)
			{
				return Plugin_Handled;
			}
			else if (!IsPlayerAlive(client))
			{
				rp_PrintToChat(client, "%T", "Tchat_NoAlive", LANG_SERVER);
				return Plugin_Handled;
			}
			
			char strPseudo[256];
			
			if(rp_GetClientBool(client, b_IsMuteGlobal)) 
			{
				rp_PrintToChat(client, "%T", "Tchat_Muted", LANG_SERVER);
				return Plugin_Stop;
			}
			else
			{						
				/*if(!rp_GetClientBool(client, b_Crayon)) 
				{
					char buffer[256];
					strcopy(STRING(buffer), arg);
					
					CRemoveTags(STRING(buffer));
					CRemoveTags(STRING(strName));
				}*/
				
				if(!rp_GetClientBool(client, b_MayTalk))
				{
					rp_PrintToChat(client, "%T", "Tchat_Cooldown", LANG_SERVER);
					return Plugin_Stop;
				}
				else
				{
					if(g_bAuthAskUsername[client] && !g_bAuthAskPassword[client])
					{
						g_bAuthAskUsername[client] = false;
						
						if(StrEqual(arg, "abort", false) || StrEqual(arg, "annuler", false))
						{
							rp_PrintToChat(client, "saisie annulée.");
							AuthSystem(client);
							return Plugin_Stop;
						}
						
						Format(g_sAuthUsername[client], sizeof(g_sAuthUsername[]), arg);
						
						switch(g_mAuth[client])
						{
							case AUTH_LOGIN:AuthSystem_Login(client);
							case AUTH_REGISTER:AuthSystem_Register(client);
						}

						return Plugin_Stop;
					}
					else if(g_bAuthAskPassword[client] && !g_bAuthAskUsername[client])
					{
						g_bAuthAskPassword[client] = false;
						
						if(StrEqual(arg, "abort", false) || StrEqual(arg, "annuler", false))
						{
							rp_PrintToChat(client, "saisie annulée.");
							AuthSystem(client);
							return Plugin_Stop;
						}
						
						Format(g_sAuthPassword[client], sizeof(g_sAuthPassword[]), arg);
						
						switch(g_mAuth[client])
						{
							case AUTH_LOGIN:AuthSystem_Login(client);
							case AUTH_REGISTER:AuthSystem_Register(client);
						}
						
						return Plugin_Stop;
					}
					else if(g_bAuthAskEmail[client] && !g_bAuthAskUsername[client] && !g_bAuthAskPassword[client])
					{
						g_bAuthAskEmail[client] = false;
						
						if(StrEqual(arg, "abort", false) || StrEqual(arg, "annuler", false))
						{
							rp_PrintToChat(client, "saisie annulée.");
							AuthSystem(client);
							return Plugin_Stop;
						}
						
						Format(g_sAuthEmail[client], sizeof(g_sAuthEmail[]), arg);
						
						switch(g_mAuth[client])
						{
							case AUTH_LOGIN:AuthSystem_Login(client);
							case AUTH_REGISTER:AuthSystem_Register(client);
						}
						
						return Plugin_Stop;
					}
					
					if(rp_GetAdmin(client) != ADMIN_FLAG_NONE)
					{				
						char rank[128];
						rp_GetClientString(client, sz_AdminTag, STRING(rank));
						
						Format(STRING(strPseudo), "{default}[%s{default}]{default}%s", rank, strName);
					}
					else if(rp_GetClientBool(client, b_IsVip))
					{				
						char tag[128], tagcolor[128];
						Cookie.Find("rpv_tag_type").Get(client, STRING(tag));
						Cookie.Find("rpv_tagcolor_type").Get(client, STRING(tagcolor));

						if(strlen(tag) != 0)
						{
							if(strlen(tagcolor) == 0)
								Format(STRING(strPseudo), "{default}[%s{default}]{default}%s", tag, strName);
							else
								Format(STRING(strPseudo), "{default}[%s%s{default}]{default}%s", tagcolor, tag, strName);	
						}	
					}
					else
						Format(STRING(strPseudo), "{grey}%s", strName);
						
					CPrintToChatAll("%s {default}: %s", strPseudo, arg);	
				}	

				rp_SetClientBool(client, b_MayTalk, false);
				CreateTimer(5.0, AllowTalking, client);
			}	
			
			Call_StartForward(Forward.OnSay);
			Call_PushCell(client);
			Call_PushString(arg);
			Call_Finish();	
		}
	}
	
	return Plugin_Handled;
}

public Action BlockSayText2(UserMsg msgID, Protobuf pb, const int[] client, int clientNum, bool reliable, bool init)
{
	if(reliable) 
	{
		return Plugin_Handled;
	}
	
	return Plugin_Continue;
}

public Action BlockTextMsg(UserMsg msgID, Protobuf pb, const int[] client, int clientNum, bool reliable, bool init)
{
	if(reliable)
	{
		char message[PLATFORM_MAX_PATH];
		if(rp_GetGame() == Engine_CSGO)
			PbReadString(pb, "params", STRING(message), false);
		else
			BfReadString(pb, message, sizeof(message), false);		
		
		if(StrContains(message, "Player_Cash_Award") != -1
		|| StrContains(message, "Team_Cash_Award") != -1
		|| StrContains(message, "Player_Point_Award") != -1
		|| StrContains(message, "Player_Team_Award") != -1
		|| StrContains(message, "Cstrike_TitlesTXT_Game_teammate_attack") != -1
		|| StrContains(message, "Chat_SavePlayer_") != -1
		|| StrContains(message, "Cstrike_game_join_") != -1
		|| StrContains(message, "SFUI_Notice_DM_BonusRespawn") != -1
		|| StrContains(message, "SFUI_Notice_DM_BonusSwitchTo") != -1
		|| StrContains(message, "SFUI_Notice_DM_BonusWeaponText") != -1
		|| StrContains(message, "SFUI_Notice_Got_Bomb") != -1
		|| StrContains(message, "Player_You_Are_") != -1
		|| StrContains(message, "SFUI_Notice_Match_Will_Start_Chat") != -1
		|| StrContains(message, "SFUI_Notice_Warmup_Has_Ended") != -1
		|| StrContains(message, "CSGO_Coach_Join_") != -1
		|| StrContains(message, "CSGO_No_Longer_Coach") != -1
		|| StrContains(message, "Player_You_Are_Now_Dominating") != -1
		|| StrContains(message, "Player_You_Are_Still_Dominating") != -1
		|| StrContains(message, "Player_On_Killing_Spree") != -1
		|| StrContains(message, "hostagerescuetime") != -1
		|| StrContains(message, "csgo_instr_explain_buymenu") != -1
		|| StrContains(message, "_Radio_") != -1
		|| StrContains(message, "Unknown command") != -1
		|| StrContains(message, "Damage") != -1
		|| StrContains(message, "attack", false) != -1
		|| StrContains(message, "teammate", false) != -1
		|| StrContains(message, "Player") != -1
		|| StrContains(message, "-----") != -1
		|| StrContains(message, "Fire_in_the_hole") != -1
		|| StrContains(message, "hole") != -1
		|| StrContains(message, "grenade") != -1
		|| StrContains(message, "in_the_hole") != -1)
			return Plugin_Handled;
	}
	
	return Plugin_Continue;
}

public Action BlockKillCam(UserMsg msgID, Protobuf pb, const int[] client, int clientNum, bool reliable, bool init)
{
	return Plugin_Handled;
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{	
	Call_StartForward(Forward.OnTakeDamage);
	Call_PushCell(victim);
	Call_PushCell(attacker);
	Call_PushCell(inflictor);
	Call_PushFloat(damage);
	Call_PushCell(damagetype);
	Call_Finish();
	
	if(rp_GetClientBool(victim, b_IsPassive) || rp_GetClientBool(attacker, b_IsTased))
	{
		damage = 0.0;
		return Plugin_Changed;
	}
	
	if(IsClientValid(attacker))
	{
		int wepID = Client_GetActiveWeapon(attacker);	
		if(IsValidEntity(wepID))
		{
			char weaponName[32];
			if(rp_GetClientInt(attacker, i_Job) == 1 || rp_GetClientInt(attacker, i_Job) == 7)
			{
				GetClientWeapon(victim, STRING(weaponName));
					
				if (StrEqual(weaponName, "weapon_usp_silencer") || StrEqual(weaponName, "weapon_m4a1_silencer"))
				{
					if (GetEntProp(wepID, Prop_Send, "m_bSilencerOn") == 1)	
					{
						ScreenFade(victim, 1, { 245, 245, 245, 120 } );
						ScreenShake(victim, 10.0, 7.0, 5.0);
						damage *= 0.0;
						return Plugin_Changed;
					}	
				}		
			}	
		}
		
		ammo_type type = rp_GetWeaponAmmoType(wepID);	
		if(rp_GetWeaponAmmoAmount(wepID) != 0)
		{
			rp_SetWeaponAmmoAmount(wepID, rp_GetWeaponAmmoAmount(wepID) - 1);
			rp_PrintToChat(attacker, "%T", "SpecialAmmoRemaining", LANG_SERVER, rp_GetWeaponAmmoAmount(wepID));
			switch(type)
			{
				case ammo_type_incendiary:
				{
					if(IsClientValid(victim))
						IgniteEntity(victim, 10.0, false);
					else
					{
						float position[3];
						PointVision(victim, position);
						rp_CreateFire(position, 10.0);		
					}	
				}
				case ammo_type_perforating:
				{
					rp_PrintToChat(victim, "{lightred}EN DEVELOPPEMENT");
				}
				case ammo_type_explosive:
				{
					float position[3];
					PointVision(attacker, position);
						
					char sound[64];
					switch (GetRandomInt(1, 3))
					{
						case 1:strcopy(STRING(sound), "weapons/hegrenade/explode3.wav");
						case 2:strcopy(STRING(sound), "weapons/hegrenade/explode4.wav");
						case 3:strcopy(STRING(sound), "weapons/hegrenade/explode5.wav");
					}
					PrecacheSound(sound);
					EmitSoundToAll(sound, attacker, _, _, _, 1.0, _, _, position);	
					
					for (int i = 1; i <= MaxClients; i++)
					{
						if (IsClientValid(i))
						{
							float origin[3];
							GetClientAbsOrigin(attacker, origin);
							if (GetVectorDistance(position, origin) < 150.0)
							{
								int vie = GetClientHealth(i);
								if (vie - 23 > 0)
									SlapPlayer(attacker, 23, true);
								else
									ForcePlayerSuicide(i);
							}
						}
					}
						
					TE_SetupExplosion(position, -1, 1.0, 1, 0, 200, 200);
					TE_SendToAll();
				}	
				case ammo_type_rubber:
				{
					if(IsClientValid(victim))
					{
						damage *= 0.0;
						ScreenFade(victim, 1, { 245, 245, 245, 120 } );
						ScreenShake(victim, 10.0, 7.0, 5.0);
						return Plugin_Changed;
					}	
				}
				case ammo_type_health: 
				{
					int current = GetClientHealth(victim);
					if( current < 500 ) {
						current += RoundToCeil(damage*0.1); // On rend environ 10% des degats infligés sous forme de vie
		
						if( current > 500 )
							current = 500;
		
						SetEntityHealth(victim, current);
						
						float vecOrigin[3], vecOrigin2[3];
						GetClientEyePosition(attacker, vecOrigin);
						GetClientEyePosition(victim, vecOrigin2);
						
						vecOrigin[2] -= 20.0; vecOrigin2[2] -= 20.0;
						
						int g_BeamSprite = PrecacheModel("sprites/laserbeam.vmt", true);
						
						TE_SetupBeamPoints(vecOrigin, vecOrigin2, g_BeamSprite, 0, 0, 0, 0.1, 10.0, 10.0, 0, 10.0, {0, 255, 0, 250}, 10); // Laser vert entre les deux
						TE_SendToAll();
					}
					damage = 0.0; // L'arme ne fait pas de dégats	
					return Plugin_Changed;
				}
				case ammo_type_paintball: 
				{
					if(IsClientValid(victim))
					{
						int r = GetRandomInt(50, 255);
						int g = GetRandomInt(50, 255);
						int b = GetRandomInt(50, 255);
			
						SetEntityRenderColor(victim, r, g, b);
						CreateTimer(7.0, Timer_ResetClientColor, victim);
						damage *= 1.0;
						return Plugin_Changed;
					}	
				}
			}
		}
	}
	
	if(damagetype & DMG_FALL)
	{
		damage *= 15.0;
		return Plugin_Changed;
	}
	
	return Plugin_Continue;
}

/***************************************************************************************

									C L I E N T - S I D E

***************************************************************************************/

public bool OnClientConnect(int client, char[] rejectmsg, int maxlen)
{
	char sName[64];
	GetClientName(client, STRING(sName));
	
	if(StrContains(sName, "rp.riplay.fr", false) != -1 || StrContains(sName, "riplay", false) != -1)
	{
		Format(rejectmsg, maxlen, "Il est interdit d'utiliser rp.riplay.fr dans votre nom.");
		return false;
	}	
	return true;
}

public void OnClientAuthorized(int client, const char[] auth) 
{	
	Format(steamID[client], sizeof(steamID[]), auth);
	GetClientIP(client, clientIP[client], sizeof(clientIP[]));

	char name[64];
	GetClientName(client, STRING(name));
	
	char country[64];
	GetCountryPrefix(client, STRING(country));
	
	rp_PrintToChatAll("%T", "Core_PlayerJoin", LANG_SERVER, name);
	
	char message[128];
	Format(STRING(message), "%T", "player_join", LANG_SERVER, name, country, steamID[client]);	
	rp_LogToDiscord(message);
}

public Action OnClientCommand(int client) 
{
	ResetAFK(client);
	
	return Plugin_Continue;
}

public void OnClientSettingsChanged(int client) 
{
	ResetAFK(client);
}

public Action OnClientPreAdminCheck(int client)
{
	if(!Licence)
	{
		KickClient(client, "- Licence Invalid -\n Contact support on https://enemy-down.fr/\nDiscord: https://discord.gg/CPqVNu5jQj");
		
		int hostIP = FindConVar("hostip").IntValue, part[4];
		int portserveur = FindConVar("hostport").IntValue;
		
		char hostname[128];
		GetConVarString(FindConVar("hostname"), STRING(hostname));
			
		part[0] = (hostIP >> 24) & 0x000000FF;
		part[1] = (hostIP >> 16) & 0x000000FF;
		part[2] = (hostIP >> 8) & 0x000000FF;
		part[3] = hostIP & 0x000000FF;
			
		char message[256], netIP[64];
		Format(STRING(netIP), "%i.%i.%i.%i:%i", part[0], part[1], part[2], part[3], portserveur);
		Format(STRING(message), "@here Le serveur %s(%s) utilise une licence invalide du roleplay csgo.", hostname, netIP);	
		rp_LogToDiscord(message);
		
		return Plugin_Handled;
	}
	
	switch(rp_GetAdmin(client))
	{
		case ADMIN_FLAG_OWNER: g_iTimerRespawn[client] = 2.0;
		case ADMIN_FLAG_ADMIN: g_iTimerRespawn[client] = 5.0;
		case ADMIN_FLAG_MODERATOR: g_iTimerRespawn[client] = 7.0;
		default: g_iTimerRespawn[client] = RoleplayCvar.respawn.FloatValue;
	}

	return Plugin_Continue;
}

public Action Timer_ShowLogo(Handle timer, int client)
{
	char message[128], jobname[64], gradename[64];
	rp_GetJobName(rp_GetClientInt(client, i_Job), STRING(jobname));
	rp_GetGradeName(rp_GetClientInt(client, i_Job), rp_GetClientInt(client, i_Grade), STRING(gradename));
	Format(STRING(message), "<br>Identité<br>Argent: %i$<br>Banque: %i$<br>Métier: %s - %s", rp_GetClientInt(client, i_Money), rp_GetClientInt(client, i_Bank), gradename, jobname);
	
	Event newevent_message = CreateEvent("cs_win_panel_round", true);
	newevent_message.SetString("funfact_token", message); 
	newevent_message.FireToClient(client);   
	newevent_message.Cancel();
	
	rp_Close(newevent_message, true, _, 10.0);
	
	return Plugin_Handled;
}

public void OnClientPutInServer(int client)
{
	// MethodMap Constructor
	m_iClient[client] = Roleplay(client);
	
	FakeClientCommand(client, "cl_teamid_overhead_maxdist 0");
	
	rp_SetClientBool(client, b_IsMuteGlobal, false);	
	rp_SetClientBool(client, b_IsMuteLocal, false);	
	rp_SetClientBool(client, b_IsMuteVocal, false);
	rp_SetClientBool(client, b_MayTalk, true);
	rp_SetClientBool(client, b_HasMandate, false);
	rp_SetClientBool(client, b_HasBankCard, false);
	rp_SetClientBool(client, b_CanUseItem, true);
	rp_SetClientBool(client, b_IsTased, false);
	rp_SetClientBool(client, b_HasLubrifiant, false);
	rp_SetClientBool(client, b_HasCrowbar, false);
	rp_SetClientBool(client, b_IsThirdPerson, false);
	rp_SetClientBool(client, b_IsOnAduty, false);
	rp_SetClientInt(client, i_Job, 0);
	rp_SetClientInt(client, i_Grade, 0);
	
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}		

public Action AutoMessages(Handle Timer)
{
	KeyValues kv = new KeyValues("Notifications");

	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, STRING(sPath), "data/roleplay/notifications.cfg");
	
	Kv_CheckIfFileExist(kv, sPath);
	
	int random = GetRandomInt(1, kv.GetNum("max"));
	
	char kv_id[16];
	IntToString(random, STRING(kv_id));
	char data[256];
	if(kv.GetString(kv_id, STRING(data)))
	{	
		CPrintToChatAll("{darkred}▬▬▬▬▬▬▬▬▬▬{yellow}PUB{darkred}▬▬▬▬▬▬▬▬▬▬");
		CPrintToChatAll("%s %s", NOTIF, data);
		CPrintToChatAll("{darkred}▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬");		
	}	
	
	kv.Rewind();
	delete kv;
	
	return Plugin_Handled;
}	

public Action Timer_Respawn(Handle timer, any client)
{	
	if (IsClientInGame(client) && !IsPlayerAlive(client))
	{
		if (g_iTimerRespawn[client] > 0.1)
		{
			g_iTimerRespawn[client] -= 0.1;
			char message[64];
			Format(STRING(message), "%T", "Core_RespawnIn", LANG_SERVER, g_iTimerRespawn[client]);		
			ShowPanel2(client, 2, message);
		}
		else
		{
			SpawnEffect(client);
			CreateTimer(1.1, Timer_DisplayLogo, client);
			CS_SwitchTeam(client, 2);
			CS_RespawnPlayer(client);
			if(rp_GetClientInt(client, i_JailTime) == 0)
			{
				if(rp_GetClientBool(client, b_SpawnJob) && !rp_GetClientBool(client, b_HasBonusTomb) && rp_GetJobSearch() != rp_GetClientInt(client, i_Job))
					SpawnJob(client);
				else if(rp_GetClientBool(client, b_HasBonusTomb))	
				{
					if(rp_GetClientInt(client, i_Appart) != -1)
						SpawnLocation(client, "appartment");
					else if(rp_GetClientInt(client, i_Villa) != -1)
						SpawnLocation(client, "villa");
					else if(rp_GetClientInt(client, i_Hotel) != -1)
						SpawnLocation(client, "hotel");
				}
			}
			else
				SpawnJail(client, rp_GetClientInt(client, i_JailID));

			if(GetClientTeam(client) == CS_TEAM_T)
			{
				for(int i; i <= MAX_WEAPON_SLOTS; i++)
				{
					if(i != CS_SLOT_KNIFE)
					{
						int weapon = GetPlayerWeaponSlot(client, i);
						if(IsValidEntity(weapon))
							DeleteWeapon(client, weapon);
					}
				}
			}
			
			if(!IsFirstSpawn[client])
			{
				IsFirstSpawn[client] = true;
				Call_StartForward(Forward.OnFirstSpawn); 
				Call_PushCell(client);
				Call_Finish();
			}
		}
	}
	else
	{	
		KillTimer(timer, false);
	}
	return vAction(0);
}

public Action AllowTalking(Handle timer, any client) 
{
	rp_SetClientBool(client, b_MayTalk, true);
	
	return Plugin_Handled;
}

public Action Message_Annonce(int client, int args)
{
	if(client == 0)
	{
		Translation_PrintNoAvailable();
		return Plugin_Handled;
	}
	
	if(IsClientValid(client))
	{
		char command[16];
		GetCmdArg(0, STRING(command));
		
		char arg[128];
		GetCmdArgString(STRING(arg));
		
		if(args < 1)
		{
			rp_PrintToChat(client, "Usage : {lightred}!%s <message>", command);
			return Plugin_Handled;
		}
		
		if(BaseComm_IsClientGagged(client) || rp_GetClientBool(client, b_IsMuteGlobal)) 
		{
			rp_PrintToChat(client, "%T", "Tchat_Muted", LANG_SERVER);
			return Plugin_Handled;
		}
		
		char name[64];
		GetClientName(client, STRING(name));
		
		CPrintToChatAll("{lightblue}%s{default} ({olive}ANNONCE{default}): %s", name, arg);
		LogToGame("[RP] [ANNONCES] %L: %s", client, arg);
	}	
	
	return Plugin_Handled;
}		

public Action Message_Colocataire(int client, int args)
{
	if(IsClientValid(client))
	{
		char command[16];
		GetCmdArg(0, STRING(command));
		
		char arg[128];
		GetCmdArgString(STRING(arg));
		
		if(args < 1)
		{
			rp_PrintToChat(client, "Utilisation : {lightred}!%s <message>", command);
			return Plugin_Handled;
		}
		else if(rp_GetClientInt(client, i_AppartCount) == 0) 
		{
			rp_PrintToChat(client, "Vous n'avez pas d'appartement.");
			return Plugin_Handled;
		}
		else if(BaseComm_IsClientGagged(client) || rp_GetClientBool(client, b_IsMuteGlobal)) 
		{
			rp_PrintToChat(client, "{default}[{lightred}MUTE{default}]: Vous avez été interdit d'utiliser le chat.");
			return Plugin_Handled;
		}
		
		LoopClients(j)
		{
			if(!IsClientValid(j))
				continue;
			if(j == client)
				continue;
			
			int appid_coloc = rp_GetClientInt(j, i_Appart);
			
			if(rp_GetClientInt(client, i_Appart) == appid_coloc)
				CPrintToChatEx(j, client, "{lightblue}%N{default} ({purple}COLOC{default}): %s", client, arg);
			else
			{
				rp_PrintToChat(client, "Vous n'avez pas de colocataire.");
				continue;
			}	
		}
		
		LogToGame("[RP] [CHAT-COLLOC] %L: %s", client, arg);
	}	
	
	return Plugin_Handled;
}

public Action Message_Team(int client, int args)
{
	if(client == 0)
	{
		Translation_PrintNoAvailable();
		return Plugin_Handled;
	}
	
	if(IsClientValid(client))
	{
		char command[16];
		GetCmdArg(0, STRING(command));
		
		char arg[128];
		GetCmdArgString(STRING(arg));
		
		if(args < 1)
		{
			rp_PrintToChat(client, "Usage : {lightred}!%s <message>", command);
			return Plugin_Handled;
		}
		
		if(rp_GetClientInt(client, i_Job) == 0) 
		{
			Translation_PrintNoAccess(client);
			return Plugin_Handled;
		}
		else if(BaseComm_IsClientGagged(client) || rp_GetClientBool(client, b_IsMuteGlobal)) 
		{
			rp_PrintToChat(client, "%T", "Tchat_Muted", LANG_SERVER);
			return Plugin_Handled;
		}

		LoopClients(i) 
		{
			if(!IsClientValid(i))
				continue;
			
			if(rp_GetClientInt(client, i_Job) == rp_GetClientInt(i, i_Job)) 
			{
				CPrintToChatEx(i, client, "{lightblue}%N{default} ({orange}TEAM{default}): %s", client, arg);
			}
		}
		
		LogToGame("[RP] [CHAT-TEAM] %L: %s", client, arg);
	}	
	
	return Plugin_Handled;
}	

public Action Message_Couple(int client, int args)
{
	if(client == 0)
	{
		Translation_PrintNoAvailable();
		return Plugin_Handled;
	}
	
	if(IsClientValid(client))
	{
		char command[16];
		GetCmdArg(0, STRING(command));
		
		char arg[128];
		GetCmdArgString(STRING(arg));
		
		if(args < 1)
		{
			rp_PrintToChat(client, "Utilisation : {lightred}!%s <message>", command);
			return Plugin_Handled;
		}
		
		if(rp_GetClientInt(client, i_MarriedTo) == 0) 
		{
			rp_PrintToChat(client, "Vous n'avez pas de conjoint.");
			return Plugin_Handled;
		}
		
		CPrintToChatEx(rp_GetClientInt(client, i_MarriedTo), client, "{lightblue}%N{default} ({red}MARIÉ{default}): %s", client, arg);
		CPrintToChatEx(client, client, "{lightblue}%N{default} ({red}MARIÉ{default}): %s", client, arg);
	}	
	
	return Plugin_Handled;
}	

public Action Message_Groupe(int client, int args)
{
	if(client == 0)
	{
		Translation_PrintNoAvailable();
		return Plugin_Handled;
	}
	
	if(IsClientValid(client))
	{
		char command[16];
		GetCmdArg(0, STRING(command));
		
		char arg[128];
		GetCmdArgString(STRING(arg));
		
		if(args < 1)
		{
			rp_PrintToChat(client, "Utilisation : {lightred}!%s <message>", command);
			return Plugin_Handled;
		}
		
		if(rp_GetClientInt(client, i_Group) == 0) 
		{
			rp_PrintToChat(client, "Vous n'êtes dans aucune organisation.");
			return Plugin_Handled;
		}

		LoopClients(i)
		{
			if(!IsClientValid(i))
				continue;
			
			if(rp_GetClientInt(i, i_Group) == rp_GetClientInt(client, i_Group)) 
			{
				CPrintToChatEx(i, client, "{lightblue}%N{default} ({red}GROUP{default}): %s", client, arg);
			}
		}
	}	
	
	return Plugin_Handled;
}

public Action Message_Admin(int client, int args)
{
	if(client == 0)
	{
		Translation_PrintNoAvailable();
		return Plugin_Handled;
	}
	else if(rp_GetAdmin(client) == ADMIN_FLAG_NONE) 
	{
		Translation_PrintNoAccess(client);
		return Plugin_Handled;
	}
	else if(IsClientValid(client))
		return Plugin_Handled;
	
	
	char command[16];
	GetCmdArg(0, STRING(command));
	
	char arg[128];
	GetCmdArgString(STRING(arg));
	
	if(args < 1)
	{
		rp_PrintToChat(client, "Utilisation : {lightred}!%s <message>", command);
		return Plugin_Handled;
	}

	CPrintToChatAll("{lightblue}%N{default} ({lightgreen}ADMIN{default}): %s", client, arg);
	
	return Plugin_Handled;
}

public Action Command_Drop(int client, int args) 
{
	#if DEBUG
		PrintToServer("Command: Drop");
	#endif	
	
	if(client == 0)
	{
		Translation_PrintNoAvailable();
		return Plugin_Handled;
	}
	else if(IsClientValid(client))
		return Plugin_Handled;
	
	
	char sWeapon[64];
	GetClientWeapon(client, STRING(sWeapon));

	if(StrContains(sWeapon, "taser", false) != -1) 
	{
		rp_PrintToChat(client, "Vous ne pouvez pas lâcher cette arme (%s).", sWeapon);
		
		char sTmp[64];
		rp_GetGlobalData("sound_full", STRING(sTmp));
		rp_Sound(client, sTmp, 0.5);
		return Plugin_Handled;
	}
		
	return Plugin_Handled;
}

public void OnClientPostAdminCheck(int client)
{	
	SteamWorks_GetUserGroupStatus(client, RoleplayCvar.steamgroup.IntValue);
	CreateTimer(2.0, Timer_ClientIntroduction, client);
}

public int SteamWorks_OnClientGroupStatus(int authid, int groupAccountID, bool isMember, bool isOfficer)
{
	int client = GetUserAuthID(authid);
	if (client == -1)
		return;

	if(isMember || isOfficer)
	{
		RoleplayBool[client].IsSteamMember = true;
	}
}


public Action Timer_ClientIntroduction(Handle timer, any client)
{
	if(IsClientValid(client))
	{
		/*char phonenumber[32];  
		rp_GetPhoneData(client, phone_number, STRING(phonenumber));
		
		char query[100];
		Format(STRING(query), "SELECT * FROM rp_phone_history_messages WHERE phonenumber_receiver = '%s'", phonenumber);	 
		DBResultSet Results = SQL_Query(rp_GetDatabase(), query);
		
		int count;
		bool viewed;
		while(Results.FetchRow())
		{
			count++;
			viewed = SQL_FetchBoolByName(Results, "viewed");	
		}			
		delete Results;
		
		if(!viewed && count != 0)
			CPrintToChat(client, "{darkred}◾️ Vous avez reçu de nouveaux messages.");*/
			
		char color[16];
		int random = GetRandomInt(0, 3);
		switch(random)
		{
			case 0:Format(STRING(color), "{darkred}");
			case 1:Format(STRING(color), "{lightblue}");
			case 2:Format(STRING(color), "{purple}");
			case 3:Format(STRING(color), "{green}");
		}
		
		CPrintToChat(client, "%s▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬", color);								   
		CPrintToChat(client, "%T", "Core_WelcomeMessage", LANG_SERVER);
		CPrintToChat(client, "%T", "Core_WelcomeOwner", LANG_SERVER);
		
		Call_StartForward(Forward.OnFirstSpawnMessage); 
		Call_PushCell(client);
		Call_Finish();

		CPrintToChat(client, "%T", "Core_WelcomeVersion", LANG_SERVER);
		CPrintToChat(client, "%T", "Core_WelcomeDiscord", LANG_SERVER, discord);	
		CPrintToChat(client, "%T", "Core_WelcomeWebsite", LANG_SERVER, website);	
		
		CPrintToChat(client, "%s▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬", color);
		
		if(rp_GetClientBool(client, b_JoinSound) && !rp_GetClientBool(client, b_IsNew))
		{
			int rand = GetRandomInt(1, 2);
			
			char sTmp[128];
			Format(STRING(sTmp), "sound_intro%i", rand);
			rp_GetGlobalData(sTmp, STRING(sTmp));
			EmitSoundToClient(client, sTmp, client, _, _, _, 0.5);
		}
		
		CreateTimer(0.1, Timer_Respawn, client, TIMER_REPEAT);
	}
	
	return Plugin_Handled;
}

void ResetAFK(int client) 
{	
	if(IsClientValid(client)) 
	{
		int iYear, iMonth, iDay, iHour, iMinute, iSecond;
		UnixToTime(GetTime(), iYear, iMonth, iDay, iHour, iMinute, iSecond, UT_TIMEZONE_CEST);
		
		if(rp_GetClientBool(client, b_IsAfk)) 
			PrintHintText(client, "Re-bonjour <font color='#eaff00'>%N</font>,\n nous sommes le <font color='#0091ff'>%02d/%02d/%d</font>, il est <font color='#0091ff'>%02d:%02d:%02d</font>", client, iDay, iMonth, iYear, iHour, iMinute, iSecond);
		
		rp_SetClientBool(client, b_IsAfk, false);
		if(TimerAFK[client] != null) 
		{
			if(CloseHandle(TimerAFK[client]))
				TimerAFK[client] = null;
		}
		TimerAFK[client] = CreateTimer(RoleplayCvar.afk.FloatValue, SetAFK, client);
	}
}

public Action SetAFK(Handle timer, any client) 
{
	if(IsClientValid(client)) 
	{
		if(RoleplayCvar.afk.FloatValue != 0.0)
			rp_SetClientBool(client, b_IsAfk, true);
	}
	TimerAFK[client] = null;
	
	return Plugin_Handled;
}

void SetRankData()
{
	KeyValues kv = new KeyValues("Rank");
	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, STRING(sPath), "data/roleplay/rank.cfg");
	Kv_CheckIfFileExist(kv, sPath);
	
	// Jump into the first subsection
	if (!kv.GotoFirstSubKey())
	{
		PrintToServer("ERROR FIRST KEY");
		delete kv;
		return;
	}
	
	char id[8];
	do
	{
		if(kv.GetSectionName(STRING(id)))
		{
			int item = StringToInt(id);
			
			IsValidRank[item] = true;
			char xp_required[16], name[32], advantage[128];
			kv.GetString("xp_required", STRING(xp_required));
			kv.GetString("name", STRING(name));
			kv.GetString("advantage", STRING(advantage));
			
			rp_SetRank(item, rank_xpreq, STRING(xp_required));
			rp_SetRank(item, rank_name, STRING(name));
			rp_SetRank(item, rank_advantage, STRING(advantage));
		}
	} 
	while (kv.GotoNextKey());
 
	
	kv.Rewind();	
	delete kv;
}	

public void OnClientCookiesCached(int client)
{
	char buffer[64];
	
	/*-------------------------------------------*/
	cookie.mute.Get(client, STRING(buffer));
	rp_SetClientBool(client, b_IsMuteGlobal, vbool(StringToInt(buffer)));
	
	/*-------------------------------------------*/
	cookie.joinsound.Get(client, STRING(buffer));
	rp_SetClientBool(client, b_JoinSound, vbool(StringToInt(buffer)));	
	
	/*-------------------------------------------*/
	cookie.spawnjob.Get(client, STRING(buffer));
	rp_SetClientBool(client, b_SpawnJob, vbool(StringToInt(buffer)));	
	
	/*-------------------------------------------*/
	cookie.sellmethod.Get(client, STRING(buffer));
	rp_SetClientBool(client, b_TransfertItemBank, vbool(StringToInt(buffer)));	
	
	/*-------------------------------------------*/
	cookie.thirdperson_distance.Get(client, STRING(buffer));
	if(StrEqual(buffer, ""))
		cookie.thirdperson_distance.Set(client, "10.0");	
	cookie.thirdperson_distance.Get(client, STRING(buffer));
	ClientCommand(client, "cam_idealdist %s", buffer);
	
	/*-------------------------------------------*/
	cookie.casinoaccess.Get(client, STRING(buffer));
	rp_SetClientBool(client, b_HasCasinoAccess, vbool(StringToInt(buffer)));	
	
	/*-------------------------------------------*/
	cookie.itemstorage.Get(client, STRING(buffer));
	if(StringToInt(buffer) == 0 || StringToInt(buffer) == 1)
	{
		cookie.itemstorage.Set(client, "100");
		cookie.itemstorage.Get(client, STRING(buffer));
	}	
	rp_SetClientInt(client, i_MaxSelfItem, StringToInt(buffer));	
	
	/*-------------------------------------------*/
	cookie.Licence_Car.Get(client, STRING(buffer));
	rp_SetClientBool(client, b_HasCarLicence, view_as<bool>(StringToInt(buffer)));
	
	/*-------------------------------------------*/
	cookie.color_pallet.Get(client, STRING(buffer));
	rp_SetClientBool(client, b_HasColorPallet, vbool(StringToInt(buffer)));	
}

public void PerformSmite(int target) 
{	
	float clientpos[3];
	GetClientAbsOrigin(target, clientpos);
	//clientpos[2] -= 26;
	
	int randomx = GetRandomInt(-500, 500);
	int randomy = GetRandomInt(-500, 500);
	
	float startpos[3];
	startpos[0] = clientpos[0] + randomx;
	startpos[1] = clientpos[1] + randomy;
	startpos[2] = clientpos[2] + 800;
	
	int color[4] = {255, 255, 255, 255};
	float dir[3] = {0.0, 0.0, 0.0};
	
	TE_SetupBeamPoints(startpos, clientpos, g_iLightingSprite, 0, 0, 0, 0.2, 20.0, 10.0, 0, 1.0, color, 3);
	TE_SendToAll();
	
	TE_SetupSparks(clientpos, dir, 5000, 1000);
	TE_SendToAll();
	
	TE_SetupEnergySplash(clientpos, dir, false);
	TE_SendToAll();
	
	TE_SetupSmoke(clientpos, g_iSmokeSprite, 5.0, 10);
	TE_SendToAll();
	
	char sTmp[64];
	rp_GetGlobalData("sound_thunder", STRING(sTmp));
	EmitAmbientSound(sTmp, startpos, target, SNDLEVEL_RAIDSIREN);
	
	ForcePlayerSuicide(target);
}

void GetCountryPrefix(int client, char[] buffer, int maxlen)
{
	char ip[32];
	GetClientIP(client, STRING(ip));	
	GeoipCountry(ip, buffer, maxlen);
}

int GetUserAuthID(int authid)
{
	LoopClients(i) 
	{
		if (!IsClientValid(i))
			continue;
		
		char authstring[50];
		GetClientAuthId(i, AuthId_Steam3, STRING(authstring));	
		
		char authstring2[50];
		IntToString(authid, STRING(authstring2));
		
		if(StrContains(authstring, authstring2) != -1) 
		{
			return i;
		}
	}

	return -1;
}

public Action Timer_BuildProp(Handle timer, any ent)
{
	if(IsValidEntity(ent))
	{
		int alpha = GetEntData(ent, GetEntSendPropOffs(ent, "m_clrRender") + 3, 1);
		if(alpha < 255)
		{
			SetEntityRenderColor(ent, 255, 255, 255, alpha + 15);
			CreateTimer(0.15, Timer_BuildProp, ent);
		}
	}
	
	return Plugin_Handled;
}

void RegisterStringMaps()
{
	/**********************************************************************
					Global Array (sound, models, configurations)
	***********************************************************************/
	g_hGlobalData = CreateTrie();
	char sTmp[MAX_BUFFER_LENGTH + 1];
	
	// Register all global data in a StringMap
	KeyValues lKey = new KeyValues("Settings");
	BuildPath(Path_SM, STRING(sTmp), "data/roleplay/settings.cfg");
	Kv_CheckIfFileExist(lKey, sTmp);
	
	if(!FileExists(sTmp))
		SetFailState("[RP] Can't find: %s", sTmp);
		
	lKey.GotoFirstSubKey();
	lKey.Rewind();	
	
	lKey.JumpToKey("Main");
	
	/**********************************************************************
							Sound configuration
	***********************************************************************/
	
	lKey.GetString("sound_taser", STRING(sTmp), "/roleplay/taser.mp3");
	g_hGlobalData.SetString("sound_taser", sTmp);
	PrecacheSound(sTmp);
	
	lKey.GetString("sound_intro1", STRING(sTmp), "/roleplay/welcome_01.mp3");
	g_hGlobalData.SetString("sound_intro1", sTmp);
	PrecacheSound(sTmp);
	
	lKey.GetString("sound_intro2", STRING(sTmp), "/roleplay/welcome_02.mp3");
	g_hGlobalData.SetString("sound_intro2", sTmp);
	PrecacheSound(sTmp);
	
	lKey.GetString("sound_cash", STRING(sTmp), "/roleplay/cash.mp3");
	g_hGlobalData.SetString("sound_cash", sTmp);
	PrecacheSound(sTmp);
	
	lKey.GetString("sound_orage", STRING(sTmp), "/roleplay/orage.mp3");
	g_hGlobalData.SetString("sound_orage", sTmp);
	PrecacheSound(sTmp);
	
	lKey.GetString("sound_knock", STRING(sTmp), "/roleplay/doorknocking.mp3");
	g_hGlobalData.SetString("sound_knock", sTmp);
	PrecacheSound(sTmp);
	
	lKey.GetString("sound_full", STRING(sTmp), "/roleplay/suitchargeok1.mp3");
	g_hGlobalData.SetString("sound_full", sTmp);
	PrecacheSound(sTmp);
	
	lKey.GetString("sound_phone", STRING(sTmp), "/survival/telephone_exterior_01.wav");
	g_hGlobalData.SetString("sound_phone", sTmp);
	PrecacheSound(sTmp);
	
	lKey.GetString("sound_radar", STRING(sTmp), "/roleplay/speeding.mp3");
	g_hGlobalData.SetString("sound_radar", sTmp);
	PrecacheSound(sTmp);
	
	lKey.GetString("sound_notif", STRING(sTmp), "/roleplay/beep.mp3");
	g_hGlobalData.SetString("sound_notif", sTmp);
	PrecacheSound(sTmp);
	
	lKey.GetString("sound_wasted", STRING(sTmp), "/roleplay/wasted.mp3");
	g_hGlobalData.SetString("sound_wasted", sTmp);
	PrecacheSound(sTmp);
	
	lKey.GetString("sound_missionpassed", STRING(sTmp), "/roleplay/mission_passed.mp3");
	g_hGlobalData.SetString("sound_missionpassed", sTmp);
	PrecacheSound(sTmp);
	
	lKey.GetString("sound_teleport", STRING(sTmp), "/roleplay/teleport.mp3");
	g_hGlobalData.SetString("sound_teleport", sTmp);
	PrecacheSound(sTmp);
	
	lKey.GetString("sound_plant", STRING(sTmp), "/survival/breach_land_01.wav");
	g_hGlobalData.SetString("sound_plant", sTmp);
	PrecacheSound(sTmp);
	
	lKey.GetString("sound_eat", STRING(sTmp), "/roleplay/eat.mp3");
	g_hGlobalData.SetString("sound_eat", sTmp);
	PrecacheSound(sTmp);
	
	lKey.GetString("sound_eat2", STRING(sTmp), "/roleplay/eat2.mp3");
	g_hGlobalData.SetString("sound_eat2", sTmp);
	PrecacheSound(sTmp);
	
	lKey.GetString("sound_burp", STRING(sTmp), "/roleplay/burp.mp3");
	g_hGlobalData.SetString("sound_burp", sTmp);
	PrecacheSound(sTmp);
	
	lKey.GetString("sound_filldrug", STRING(sTmp), "/roleplay/aluminfill02.mp3");
	g_hGlobalData.SetString("sound_filldrug", sTmp);
	PrecacheSound(sTmp);
	
	lKey.GetString("sound_pickup", STRING(sTmp), "/survival/armor_pickup_01.wav");
	g_hGlobalData.SetString("sound_pickup", sTmp);
	PrecacheSound(sTmp);
	
	lKey.GetString("sound_ding", STRING(sTmp), "/roleplay/ding.mp3");
	g_hGlobalData.SetString("sound_ding", sTmp);
	PrecacheSound(sTmp);
	
	lKey.GetString("sound_purge", STRING(sTmp), "/roleplay/purge.mp3");
	g_hGlobalData.SetString("sound_purge", sTmp);
	PrecacheSound(sTmp);
	
	lKey.GetString("sound_drill", STRING(sTmp), "/roleplay/drill.mp3");
	g_hGlobalData.SetString("sound_drill", sTmp);
	PrecacheSound(sTmp);
	
	lKey.GetString("sound_levelup", STRING(sTmp), "/roleplay/levelup.mp3");
	g_hGlobalData.SetString("sound_levelup", sTmp);
	PrecacheSound(sTmp);
	
	lKey.GetString("sound_power", STRING(sTmp), "ambient/machines/power_transformer_loop_2.wav");
	g_hGlobalData.SetString("sound_power", sTmp);
	PrecacheSound(sTmp);
	
	lKey.GetString("sound_antilag", STRING(sTmp), "/roleplay/antilag.mp3");
	g_hGlobalData.SetString("sound_antilag", sTmp);
	PrecacheSound(sTmp);
	
	lKey.GetString("sound_thunder", STRING(sTmp), "/roleplay/explode.wav");
	g_hGlobalData.SetString("sound_thunder", sTmp);
	PrecacheSound(sTmp);
	
	lKey.GetString("sound_klaxon", STRING(sTmp), "/vehicles/roleplay/shared/horn_standard.wav");
	g_hGlobalData.SetString("sound_klaxon", sTmp);
	PrecacheSound(sTmp);
	
	lKey.GetString("sound_siren", STRING(sTmp), "/vehicles/police_siren_single.mp3");
	g_hGlobalData.SetString("sound_siren", sTmp);
	PrecacheSound(sTmp);
	
	lKey.GetString("sound_gaspump", STRING(sTmp), "/roleplay/gaspump.mp3");
	g_hGlobalData.SetString("sound_gaspump", sTmp);
	PrecacheSound(sTmp);
	
	lKey.GetString("sound_vehicle_door", STRING(sTmp), "/vehicles/roleplay/shared/truck_open.wav");
	g_hGlobalData.SetString("sound_vehicle_door", sTmp);
	PrecacheSound(sTmp);
	
	lKey.GetString("sound_sniff01", STRING(sTmp), "/roleplay/sniff01.wav");
	g_hGlobalData.SetString("sound_sniff01", sTmp);
	PrecacheSound(sTmp);
	
	lKey.GetString("sound_sniff02", STRING(sTmp), "/roleplay/sniff02.wav");
	g_hGlobalData.SetString("sound_sniff02", sTmp);
	PrecacheSound(sTmp);
	
	lKey.GetString("sound_tutorial_00", STRING(sTmp), "/roleplay/tutorial/introduction.mp3");
	g_hGlobalData.SetString("sound_tutorial_00", sTmp);
	PrecacheSound(sTmp);
	
	lKey.GetString("sound_tutorial_01", STRING(sTmp), "/roleplay/tutorial/begin.mp3");
	g_hGlobalData.SetString("sound_tutorial_01", sTmp);
	PrecacheSound(sTmp);
	
	lKey.GetString("sound_tutorial_arrow", STRING(sTmp), "/roleplay/tutorial/followarrow.mp3");
	g_hGlobalData.SetString("sound_tutorial_arrow", sTmp);
	PrecacheSound(sTmp);
	
	lKey.GetString("sound_craft01", STRING(sTmp), "/roleplay/craft01.wav");
	g_hGlobalData.SetString("sound_craft01", sTmp);
	PrecacheSound(sTmp);
	
	lKey.GetString("sound_craft02", STRING(sTmp), "/roleplay/craft02.wav");
	g_hGlobalData.SetString("sound_craft02", sTmp);
	PrecacheSound(sTmp);
	
	lKey.GetString("sound_craft03", STRING(sTmp), "/roleplay/craft03.wav");
	g_hGlobalData.SetString("sound_craft03", sTmp);
	PrecacheSound(sTmp);
	
	lKey.GetString("sound_craft04", STRING(sTmp), "/roleplay/craft04.wav");
	g_hGlobalData.SetString("sound_craft04", sTmp);
	PrecacheSound(sTmp);
	
	lKey.GetString("sound_craft05", STRING(sTmp), "/roleplay/craft05.wav");
	g_hGlobalData.SetString("sound_craft05", sTmp);
	PrecacheSound(sTmp);
	
	lKey.GetString("sound_craft06", STRING(sTmp), "/roleplay/craft06.wav");
	g_hGlobalData.SetString("sound_craft06", sTmp);
	PrecacheSound(sTmp);
	
	lKey.GetString("sound_craft07", STRING(sTmp), "/roleplay/craft07.wav");
	g_hGlobalData.SetString("sound_craft07", sTmp);
	PrecacheSound(sTmp);
	
	lKey.GetString("sound_upgrade", STRING(sTmp), "/roleplay/sound_upgrade.wav");
	g_hGlobalData.SetString("sound_upgrade", sTmp);
	PrecacheSound(sTmp);
	
	lKey.GetString("sound_inventory", STRING(sTmp), "/roleplay/sound_inventory.wav");
	g_hGlobalData.SetString("sound_inventory", sTmp);
	PrecacheSound(sTmp);
	
	/**********************************************************************
							Graffi configuration
	***********************************************************************/
	
	lKey.GetString("graffiti_1", STRING(sTmp), "roleplay/graffiti/2pac.vmt");
	g_hGlobalData.SetString("graffiti_1", sTmp);
	PrecacheDecal(sTmp);
	
	lKey.GetString("graffiti_2", STRING(sTmp), "roleplay/graffiti/amer.vmt");
	g_hGlobalData.SetString("graffiti_2", sTmp);
	PrecacheDecal(sTmp);
	
	lKey.GetString("graffiti_3", STRING(sTmp), "roleplay/graffiti/artdelarue.vmt");
	g_hGlobalData.SetString("graffiti_3", sTmp);
	PrecacheDecal(sTmp);
	
	lKey.GetString("graffiti_4", STRING(sTmp), "roleplay/graffiti/devilsmoke.vmt");
	g_hGlobalData.SetString("graffiti_4", sTmp);
	PrecacheDecal(sTmp);
	
	lKey.GetString("graffiti_5", STRING(sTmp), "roleplay/graffiti/dope.vmt");
	g_hGlobalData.SetString("graffiti_5", sTmp);
	PrecacheDecal(sTmp);
	
	/**********************************************************************
							Overlay configuration
	***********************************************************************/
	
	lKey.GetString("overlay_death", STRING(sTmp), "roleplay/overlays/death01.vmt");
	g_hGlobalData.SetString("overlay_death", sTmp);
	PrecacheDecal(sTmp);	
	
	lKey.GetString("overlay_respect", STRING(sTmp), "roleplay/overlays/respect.vmt");
	g_hGlobalData.SetString("overlay_respect", sTmp);
	PrecacheDecal(sTmp);
	
	lKey.GetString("overlay_jail", STRING(sTmp), "roleplay/overlays/jail_gav.vmt");
	g_hGlobalData.SetString("overlay_jail", sTmp);
	PrecacheDecal(sTmp);
	
	lKey.GetString("effect_water", STRING(sTmp), "roleplay/overlays/effect/water.vmt");
	g_hGlobalData.SetString("effect_water", sTmp);
	PrecacheDecal(sTmp);
	
	lKey.GetString("effect01", STRING(sTmp), "roleplay/overlays/effect/effect01.vmt");
	g_hGlobalData.SetString("effect01", sTmp);
	PrecacheDecal(sTmp);
	
	lKey.GetString("effect01_warp", STRING(sTmp), "roleplay/overlays/effect/effect01_warp.vmt");
	g_hGlobalData.SetString("effect01_warp", sTmp);
	PrecacheDecal(sTmp);
	
	lKey.GetString("effect02", STRING(sTmp), "roleplay/overlays/effect/effect02.vmt");
	g_hGlobalData.SetString("effect02", sTmp);
	PrecacheDecal(sTmp);
	
	lKey.GetString("effect02_warp", STRING(sTmp), "roleplay/overlays/effect/effect02_warp.vmt");
	g_hGlobalData.SetString("effect02_warp", sTmp);
	PrecacheDecal(sTmp);
	
	lKey.GetString("effect03", STRING(sTmp), "roleplay/overlays/effect/effect03.vmt");
	g_hGlobalData.SetString("effect03", sTmp);
	PrecacheDecal(sTmp);
	
	lKey.GetString("effect03_warp", STRING(sTmp), "roleplay/overlays/effect/effect03_warp.vmt");
	g_hGlobalData.SetString("effect03_warp", sTmp);
	PrecacheDecal(sTmp);
	
	lKey.GetString("effect04", STRING(sTmp), "roleplay/overlays/effect/effect04.vmt");
	g_hGlobalData.SetString("effect04", sTmp);
	PrecacheDecal(sTmp);
	
	lKey.GetString("effect04_warp", STRING(sTmp), "roleplay/overlays/effect/effect04_warp.vmt");
	g_hGlobalData.SetString("effect04_warp", sTmp);
	PrecacheDecal(sTmp);
	
	lKey.GetString("effect05", STRING(sTmp), "roleplay/overlays/effect/effect05.vmt");
	g_hGlobalData.SetString("effect05", sTmp);
	PrecacheDecal(sTmp);
	
	lKey.GetString("effect05_warp", STRING(sTmp), "roleplay/overlays/effect/effect05_warp.vmt");
	g_hGlobalData.SetString("effect05_warp", sTmp);
	PrecacheDecal(sTmp);
	
	lKey.GetString("effect06", STRING(sTmp), "roleplay/overlays/effect/effect06.vmt");
	g_hGlobalData.SetString("effect06", sTmp);
	PrecacheDecal(sTmp);
	
	lKey.GetString("effect06_warp", STRING(sTmp), "roleplay/overlays/effect/effect06_warp.vmt");
	g_hGlobalData.SetString("effect06_warp", sTmp);
	PrecacheDecal(sTmp);
	
	lKey.GetString("effect07", STRING(sTmp), "roleplay/overlays/effect/effect07.vmt");
	g_hGlobalData.SetString("effect07", sTmp);
	PrecacheDecal(sTmp);
	
	lKey.GetString("effect07_warp", STRING(sTmp), "roleplay/overlays/effect/effect07_warp.vmt");
	g_hGlobalData.SetString("effect07_warp", sTmp);
	PrecacheDecal(sTmp);
	
	/**********************************************************************
							Emoji configuration
	***********************************************************************/
	
	lKey.GetString("emoji_thinking", STRING(sTmp), "materials/roleplay/emoji/thinking.vmt");
	g_hGlobalData.SetString("emoji_thinking", sTmp);
	
	lKey.GetString("emoji_grinning", STRING(sTmp), "materials/roleplay/emoji/grinning.vmt");
	g_hGlobalData.SetString("emoji_grinning", sTmp);
	
	lKey.GetString("emoji_hahaha", STRING(sTmp), "materials/roleplay/emoji/hahaha.vmt");
	g_hGlobalData.SetString("emoji_hahaha", sTmp);
	
	lKey.GetString("emoji_heart", STRING(sTmp), "materials/roleplay/emoji/heart_eyes.vmt");
	g_hGlobalData.SetString("emoji_heart", sTmp);
	
	/**********************************************************************
							Other configuration
	***********************************************************************/
	
	lKey.GetString("main_particle", STRING(sTmp), "particles/roleplay_csgo.pcf");
	g_hGlobalData.SetString("main_particle", sTmp);
	
	/**********************************************************************
							Model configuration
	***********************************************************************/
	
	lKey.GetString("model_box", STRING(sTmp), "models/props/coop_cementplant/coop_foot_locker/coop_foot_locker_closed.mdl");
	g_hGlobalData.SetString("model_box", sTmp);
	PrecacheModel(sTmp);
	
	lKey.GetString("model_money", STRING(sTmp), "models/props_survival/cash/prop_cash_stack.mdl");
	g_hGlobalData.SetString("model_money", sTmp);
	PrecacheModel(sTmp);
	
	lKey.GetString("model_phone", STRING(sTmp), "models/props_equipment/phone_booth.mdl");
	g_hGlobalData.SetString("model_phone", sTmp);
	PrecacheModel(sTmp);
	
	lKey.GetString("model_c4planted", STRING(sTmp), "models/weapons/w_c4_planted.mdl");
	g_hGlobalData.SetString("model_c4planted", sTmp);
	PrecacheModel(sTmp);
	
	lKey.GetString("model_airdrop", STRING(sTmp), "models/props_survival/cases/case_random_drop.mdl");
	g_hGlobalData.SetString("model_airdrop", sTmp);
	PrecacheModel(sTmp);
	
	lKey.GetString("model_bumper", STRING(sTmp), "models/roleplay/bumper.mdl");
	g_hGlobalData.SetString("model_bumper", sTmp);
	PrecacheModel(sTmp);
	
	lKey.GetString("model_claymore", STRING(sTmp), "models/roleplay/claymore.mdl");
	g_hGlobalData.SetString("model_claymore", sTmp);
	PrecacheModel(sTmp);
	
	lKey.GetString("model_printer", STRING(sTmp), "models/roleplay/printer.mdl");
	g_hGlobalData.SetString("model_printer", sTmp);
	PrecacheModel(sTmp);
	
	lKey.GetString("model_printerpaper", STRING(sTmp), "models/roleplay/printer_paper.mdl");
	g_hGlobalData.SetString("model_printerpaper", sTmp);
	PrecacheModel(sTmp);
	
	lKey.GetString("model_armory", STRING(sTmp), "models/roleplay/police_armory.mdl");
	g_hGlobalData.SetString("model_armory", sTmp);
	PrecacheModel(sTmp);
	
	lKey.GetString("model_acetone", STRING(sTmp), "models/roleplay/liquids/acetone.mdl");
	g_hGlobalData.SetString("model_acetone", sTmp);
	PrecacheModel(sTmp);
	
	lKey.GetString("model_ammoniac", STRING(sTmp), "models/roleplay/liquids/ammoniac.mdl");
	g_hGlobalData.SetString("model_ammoniac", sTmp);
	PrecacheModel(sTmp);
	
	lKey.GetString("model_bismuth", STRING(sTmp), "models/roleplay/liquids/bismuth.mdl");
	g_hGlobalData.SetString("model_bismuth", sTmp);
	PrecacheModel(sTmp);
	
	lKey.GetString("model_phosphore", STRING(sTmp), "models/roleplay/liquids/acid_phosphoric.mdl");
	g_hGlobalData.SetString("model_phosphore", sTmp);
	PrecacheModel(sTmp);
	
	lKey.GetString("model_sulfuric", STRING(sTmp), "models/roleplay/liquids/acid_sulfuric.mdl");
	g_hGlobalData.SetString("model_sulfuric", sTmp);
	PrecacheModel(sTmp);
	
	lKey.GetString("model_sodium", STRING(sTmp), "models/roleplay/liquids/sodium.mdl");
	g_hGlobalData.SetString("model_sodium", sTmp);
	PrecacheModel(sTmp);
	
	lKey.GetString("model_toulene", STRING(sTmp), "models/roleplay/liquids/toulene.mdl");
	g_hGlobalData.SetString("model_toulene", sTmp);
	PrecacheModel(sTmp);
	
	lKey.GetString("model_drugrack", STRING(sTmp), "models/roleplay/drugs/drying_rack.mdl");
	g_hGlobalData.SetString("model_drugrack", sTmp);
	PrecacheModel(sTmp);
	
	lKey.GetString("model_gasstove", STRING(sTmp), "models/roleplay/drugs/gas_stove.mdl");
	g_hGlobalData.SetString("model_gasstove", sTmp);
	PrecacheModel(sTmp);
	
	lKey.GetString("model_cocainebox", STRING(sTmp), "models/roleplay/drugs/cocaine_box.mdl");
	g_hGlobalData.SetString("model_cocainebox", sTmp);
	PrecacheModel(sTmp);
	
	lKey.GetString("model_gastank", STRING(sTmp), "models/roleplay/drugs/gas_tank.mdl");
	g_hGlobalData.SetString("model_gastank", sTmp);
	PrecacheModel(sTmp);
	
	lKey.GetString("model_water", STRING(sTmp), "models/roleplay/drugs/water.mdl");
	g_hGlobalData.SetString("model_water", sTmp);
	PrecacheModel(sTmp);
	
	lKey.GetString("model_cocaine", STRING(sTmp), "models/roleplay/drugs/cocaine_pack.mdl");
	g_hGlobalData.SetString("model_cocaine", sTmp);
	PrecacheModel(sTmp);
	
	lKey.GetString("model_battery", STRING(sTmp), "models/roleplay/drugs/battery.mdl");
	g_hGlobalData.SetString("model_battery", sTmp);
	PrecacheModel(sTmp);
	
	lKey.GetString("model_plant", STRING(sTmp), "models/roleplay/drugs/plant.mdl");
	g_hGlobalData.SetString("model_plant", sTmp);
	PrecacheModel(sTmp);
	
	lKey.GetString("model_weedseed", STRING(sTmp), "models/roleplay/drugs/weed_seed.mdl");
	g_hGlobalData.SetString("model_weedseed", sTmp);
	PrecacheModel(sTmp);
	
	lKey.GetString("model_rack", STRING(sTmp), "models/roleplay/bitcoin/rack.mdl");
	g_hGlobalData.SetString("model_rack", sTmp);
	PrecacheModel(sTmp);
	
	lKey.GetString("model_rgbkit", STRING(sTmp), "models/roleplay/bitcoin/rgb_kit.mdl");
	g_hGlobalData.SetString("model_rgbkit", sTmp);
	PrecacheModel(sTmp);
	
	lKey.GetString("model_miner", STRING(sTmp), "models/roleplay/bitcoin/miner.mdl");
	g_hGlobalData.SetString("model_miner", sTmp);
	PrecacheModel(sTmp);
	
	lKey.GetString("model_upgrade01", STRING(sTmp), "models/roleplay/bitcoin/upgrade_01.mdl");
	g_hGlobalData.SetString("model_upgrade01", sTmp);
	PrecacheModel(sTmp);
	
	lKey.GetString("model_upgrade02", STRING(sTmp), "models/roleplay/bitcoin/upgrade_02.mdl");
	g_hGlobalData.SetString("model_upgrade02", sTmp);
	PrecacheModel(sTmp);
	
	lKey.GetString("model_upgrade03", STRING(sTmp), "models/roleplay/bitcoin/upgrade_03.mdl");
	g_hGlobalData.SetString("model_upgrade03", sTmp);
	PrecacheModel(sTmp);
	
	lKey.GetString("model_crystal1", STRING(sTmp), "models/roleplay/crystals/crystal_1.mdl");
	g_hGlobalData.SetString("model_crystal1", sTmp);
	PrecacheModel(sTmp);
	
	lKey.GetString("model_crystal2", STRING(sTmp), "models/roleplay/crystals/crystal_2.mdl");
	g_hGlobalData.SetString("model_crystal2", sTmp);
	PrecacheModel(sTmp);
	
	lKey.GetString("model_crystal3", STRING(sTmp), "models/roleplay/crystals/crystal_3.mdl");
	g_hGlobalData.SetString("model_crystal3", sTmp);
	PrecacheModel(sTmp);
	
	lKey.GetString("model_perceuse", STRING(sTmp), "models/roleplay/perceuse.mdl");
	g_hGlobalData.SetString("model_perceuse", sTmp);
	PrecacheModel(sTmp);
	
	lKey.GetString("model_barrier01", STRING(sTmp), "models/roleplay/barriere_01.mdl");
	g_hGlobalData.SetString("model_barrier01", sTmp);
	PrecacheModel(sTmp);
	
	lKey.GetString("model_barrier02", STRING(sTmp), "models/roleplay/barriere_02.mdl");
	g_hGlobalData.SetString("model_barrier02", sTmp);
	PrecacheModel(sTmp);
	
	lKey.GetString("model_barrier03", STRING(sTmp), "models/roleplay/barriere_03.mdl");
	g_hGlobalData.SetString("model_barrier03", sTmp);
	PrecacheModel(sTmp);
	
	lKey.GetString("model_supply", STRING(sTmp), "models/roleplay/supply.mdl");
	g_hGlobalData.SetString("model_supply", sTmp);
	PrecacheModel(sTmp);
	
	lKey.GetString("model_seat", STRING(sTmp), "models/roleplay/vehicles/seat.mdl");
	g_hGlobalData.SetString("model_seat", sTmp);
	PrecacheModel(sTmp);
	
	lKey.GetString("model_corn", STRING(sTmp), "models/roleplay/farming/corn.mdl");
	g_hGlobalData.SetString("model_corn", sTmp);
	PrecacheModel(sTmp);
	
	lKey.GetString("model_dirtbag", STRING(sTmp), "models/roleplay/farming/dirtbag.mdl");
	g_hGlobalData.SetString("model_dirtbag", sTmp);
	PrecacheModel(sTmp);
	
	lKey.GetString("model_hole", STRING(sTmp), "models/roleplay/farming/hole.mdl");
	g_hGlobalData.SetString("model_hole", sTmp);
	PrecacheModel(sTmp);
	
	lKey.GetString("model_lamp", STRING(sTmp), "models/roleplay/farming/lamp.mdl");
	g_hGlobalData.SetString("model_lamp", sTmp);
	PrecacheModel(sTmp);
	
	lKey.GetString("model_lettuce", STRING(sTmp), "models/roleplay/farming/lettuce.mdl");
	g_hGlobalData.SetString("model_lettuce", sTmp);
	PrecacheModel(sTmp);
	
	lKey.GetString("model_pepper", STRING(sTmp), "models/roleplay/farming/pepper.mdl");
	g_hGlobalData.SetString("model_pepper", sTmp);
	PrecacheModel(sTmp);
	
	lKey.GetString("model_plantcorn", STRING(sTmp), "models/roleplay/farming/plant_corn.mdl");
	g_hGlobalData.SetString("model_plantcorn", sTmp);
	PrecacheModel(sTmp);
	
	lKey.GetString("model_plantlettuce", STRING(sTmp), "models/roleplay/farming/plant_lettuce.mdl");
	g_hGlobalData.SetString("model_plantlettuce", sTmp);
	PrecacheModel(sTmp);
	
	lKey.GetString("model_plantpepper", STRING(sTmp), "models/roleplay/farming/plant_pepper.mdl");
	g_hGlobalData.SetString("model_plantpepper", sTmp);
	PrecacheModel(sTmp);
	
	lKey.GetString("model_planttomato", STRING(sTmp), "models/roleplay/farming/plant_tomato.mdl");
	g_hGlobalData.SetString("model_planttomato", sTmp);
	PrecacheModel(sTmp);
	
	lKey.GetString("model_plantwheat", STRING(sTmp), "models/roleplay/farming/plant_wheat.mdl");
	g_hGlobalData.SetString("model_plantwheat", sTmp);
	PrecacheModel(sTmp);
	
	lKey.GetString("model_pot", STRING(sTmp), "models/roleplay/farming/pot.mdl");
	g_hGlobalData.SetString("model_pot", sTmp);
	PrecacheModel(sTmp);
	
	lKey.GetString("model_sack", STRING(sTmp), "models/roleplay/farming/sack.mdl");
	g_hGlobalData.SetString("model_sack", sTmp);
	PrecacheModel(sTmp);
	
	lKey.GetString("model_seeds", STRING(sTmp), "models/roleplay/farming/seeds_package.mdl");
	g_hGlobalData.SetString("model_seeds", sTmp);
	PrecacheModel(sTmp);
	
	lKey.GetString("model_tomato", STRING(sTmp), "models/roleplay/farming/tomato.mdl");
	g_hGlobalData.SetString("model_tomato", sTmp);
	PrecacheModel(sTmp);
	
	lKey.GetString("model_wheat", STRING(sTmp), "models/roleplay/farming/wheat.mdl");
	g_hGlobalData.SetString("model_wheat", sTmp);
	PrecacheModel(sTmp);
	
	lKey.GetString("model_workbench", STRING(sTmp), "models/roleplay/workbench.mdl");
	g_hGlobalData.SetString("model_workbench", sTmp);
	PrecacheModel(sTmp);
	
	lKey.Rewind();
	delete lKey;
	
	/**********************************************************************
	 Doors Array (Get all jobs doors name access and store in global array)
	***********************************************************************/
	
	/*g_aDoorsData = new ArrayList(MAXJOBS, 1);

	// Register all global data in a StringMap
	lKey = new KeyValues("Jobs");
	BuildPath(Path_SM, STRING(sTmp), "data/roleplay/jobs.cfg");
	Kv_CheckIfFileExist(lKey, sTmp);
	
	if(!FileExists(sTmp))
		SetFailState("[RP] Can't find: %s", sTmp);
		
	for(int i = 1; i <= MAXJOBS; i++)
	{
		char sId[8];
		IntToString(i, STRING(sId));
		
		lKey.JumpToKey(sId);
		lKey.GetString("doors", STRING(sTmp));
		Format(STRING(sTmp), "%i|%s", i, sTmp);
		g_aDoorsData.PushString(sTmp);
		
		lKey.GoBack();
	}
		
	lKey.Rewind();
	delete lKey;*/
}

public Action Command_Auth(int client, int args)
{
	if(client == 0)
	{
		Translation_PrintNoAvailable();
		return Plugin_Handled;
	}
	else if(rp_GetClientBool(client, b_IsWebsiteMember))
	{
		rp_PrintToChat(client, "{green}Vous êtes déjà connecté.");
		return Plugin_Handled;
	}
	
	AuthSystem(client);
	
	return Plugin_Handled;
}

public void RP_OnSettings(Menu menu, int client)
{
	menu.AddItem("auth", "Connexion & Inscription");
}

public void RP_OnSettingsHandle(int client, const char[] info)
{
	if(StrEqual(info, "auth"))
		FakeClientCommand(client, "say /rp_auth");
}

void AuthSystem(int client) 
{
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_MenuAuth);
	menu.SetTitle("Enemy-down - Authentification");
	menu.AddItem("login", "Connexion");
	menu.AddItem("register", "Inscription");
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Handle_MenuAuth(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[64];
		menu.GetItem(param, STRING(info));
		
		if(StrEqual(info, "login"))
			AuthSystem_Login(client);
		else if(StrEqual(info, "register"))
			AuthSystem_Register(client);
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit || param == MenuCancel_ExitBack)
			rp_SetClientBool(client, b_DisplayHud, true);
	}
	else if(action == MenuAction_End)
		delete menu;
		
	return 0;
}

Menu AuthSystem_Login(int client) 
{	
	char sTmp[64], sPasswordHashed[64];
	
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_MenuAuthLogin);
	menu.SetTitle("Enemy-down - Connexion");
	
	Format(STRING(sTmp), "Utilisateur: %s", g_sAuthUsername[client]);
	menu.AddItem("username", sTmp);
	
	for(int i = 1; i <= strlen(g_sAuthPassword[client]); i++)
	{
		Format(STRING(sPasswordHashed), "%s•", sPasswordHashed);
	}
	
	Format(STRING(sTmp), "Mot de passe: %s", sPasswordHashed);
	menu.AddItem("password", sTmp);
	
	menu.AddItem("", "\n---------", ITEMDRAW_DISABLED);
	menu.AddItem("submit", "Valider", (!StrEqual(g_sAuthPassword[client], "") && !StrEqual(g_sAuthPassword[client], "")) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
	
	return menu;
}

public int Handle_MenuAuthLogin(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[64];
		menu.GetItem(param, STRING(info));
		g_mAuth[client] = AUTH_LOGIN;
		
		if(StrEqual(info, "username"))
		{
			g_bAuthAskUsername[client] = true;
			rp_PrintToChat(client, "Entrer des à present votre nom d'utilisateur ou bien tapez {darkred}annuler{default}.");
		}
		else if(StrEqual(info, "password"))
		{
			g_bAuthAskPassword[client] = true;
			rp_PrintToChat(client, "Entrer des à present votre mot de passe ou bien tapez {darkred}annuler{default}.");
		}
		else if(StrEqual(info, "submit"))
			DoLogin(client, g_sAuthUsername[client], g_sAuthPassword[client]);
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit || param == MenuCancel_ExitBack)
			rp_SetClientBool(client, b_DisplayHud, true);
	}
	else if(action == MenuAction_End)
		delete menu;
		
	return 0;
}

void DoLogin(int client, char[] username, char[] password)
{
	Auth auth = new Auth();
	auth.SetUsername(username);
	auth.SetPassword(password);
	
	char sRequest[256];
	FormatEx(STRING(sRequest), "%s/auth/login", API);
	HTTPRequest request = new HTTPRequest(sRequest);
	
	request.SetHeader("Content-Type", "application/json");
	
	request.Post(auth, OnLogin, GetClientUserId(client));
}

void OnLogin(HTTPResponse response, any data) 
{
	#if DEBUG
		PrintToServer("[HTTP]OnLogin");
	#endif
	
	int client = GetClientOfUserId(data);
	g_sAuthUsername[client] = "";
	g_sAuthPassword[client] = "";
	
	if (response.Status == HTTPStatus_OK) {
		#if DEBUG
			PrintToServer("[HTTP]OnLogin: ok");
		#endif
		ShowPanel2(client, 3, "<font color='%s'>Connexion avec succès</font>", HTML_CHARTREUSE);
		rp_SetClientBool(client, b_IsWebsiteMember, true);
	}
	else
	{
		ShowPanel2(client, 3, "<font color='%s'>Une erreur s'est produit</font>", HTML_CRIMSON);
		AuthSystem(client);
		rp_SetClientBool(client, b_IsWebsiteMember, false);
	}
}

Menu AuthSystem_Register(int client) 
{	
	char sTmp[64], sPasswordHashed[64];
	
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_MenuAuthRegister);
	menu.SetTitle("Enemy-down - Inscription");
	
	Format(STRING(sTmp), "Utilisateur: %s", g_sAuthUsername[client]);
	menu.AddItem("username", sTmp);
	
	Format(STRING(sTmp), "Email: %s", g_sAuthEmail[client]);
	menu.AddItem("email", sTmp);
	
	for(int i = 1; i <= strlen(g_sAuthPassword[client]); i++)
	{
		Format(STRING(sPasswordHashed), "%s•", sPasswordHashed);
	}
	
	Format(STRING(sTmp), "Mot de passe: %s", sPasswordHashed);
	menu.AddItem("password", sTmp);
	
	menu.AddItem("", "\n---------", ITEMDRAW_DISABLED);
	menu.AddItem("submit", "Valider", (!StrEqual(g_sAuthPassword[client], "") && !StrEqual(g_sAuthPassword[client], "")) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
	
	return menu;
}

public int Handle_MenuAuthRegister(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[64];
		menu.GetItem(param, STRING(info));
		g_mAuth[client] = AUTH_REGISTER;
		
		if(StrEqual(info, "username"))
		{
			g_bAuthAskUsername[client] = true;
			rp_PrintToChat(client, "Entrer des à present votre nom d'utilisateur ou bien tapez {darkred}annuler{default}.");
		}
		else if(StrEqual(info, "email"))
		{
			g_bAuthAskEmail[client] = true;
			rp_PrintToChat(client, "Entrer des à present votre addresse mail ou bien tapez {darkred}annuler{default}.");
		}
		else if(StrEqual(info, "password"))
		{
			g_bAuthAskPassword[client] = true;
			rp_PrintToChat(client, "Entrer des à present votre mot de passe ou bien tapez {darkred}annuler{default}.");
		}
		else if(StrEqual(info, "submit"))
			DoRegister(client, g_sAuthUsername[client], g_sAuthEmail[client], g_sAuthPassword[client]);
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit || param == MenuCancel_ExitBack)
			rp_SetClientBool(client, b_DisplayHud, true);
	}
	else if(action == MenuAction_End)
		delete menu;
		
	return 0;
}

void DoRegister(int client, char[] username, char[] email, char[] password)
{
	Auth auth = new Auth();
	auth.SetUsername(username);
	auth.SetEmail(email);
	auth.SetPassword(password);
	
	char sSteam[64];
	GetClientAuthId(client, AuthId_SteamID64, STRING(sSteam));
	auth.SetSteamID(sSteam);
	
	char sRequest[256];
	FormatEx(STRING(sRequest), "%s/auth/register", API);
	HTTPRequest request = new HTTPRequest(sRequest);
	
	request.SetHeader("Content-Type", "application/json");
	
	request.Post(auth, OnRegister, GetClientUserId(client));
}

void OnRegister(HTTPResponse response, any data) 
{
	#if DEBUG
		PrintToServer("[HTTP]OnRegister");
	#endif
	
	int client = GetClientOfUserId(data);
	g_sAuthUsername[client] = "";
	g_sAuthEmail[client] = "";
	g_sAuthPassword[client] = "";
	
	if (response.Status == HTTPStatus_OK) {
		#if DEBUG
			PrintToServer("[HTTP]OnRegister: ok");
		#endif
		ShowPanel2(client, 3, "<font color='%s'>Inscription avec succès</font>", HTML_CHARTREUSE);
		AuthSystem_Login(client);
	}
	else
	{
		ShowPanel2(client, 3, "<font color='%s'>Une erreur s'est produit</font>", HTML_CRIMSON);
		AuthSystem(client);
	}
}