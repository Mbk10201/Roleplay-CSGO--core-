/*
*   Roleplay CS:GO de Benito est mis à disposition selon les termes de la licence Creative Commons Attribution .
* - Pas d’Utilisation Commerciale 
* - Partage dans les Mêmes Conditions 4.0 International.
*
*   Merci de respecter le travail fourni par le ou les auteurs 
*   https://enemy-down.eu - benitalpa1020@gmail.com
*/

/*
	TODO
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
#define COLOR_TASER			{15, 15, 255, 225}
#define MAXENTITIES 		2048
#define PLANT_MAXSTEP		12
#define MAX_PLANT			2
#define MAX_WATERATTEMPT	3
#define MAX_STOVEPLATE		4
#define JOBID				7

/***************************************************************************************

							G L O B A L  -  V A R S

***************************************************************************************/

// Methodmap Constructor
Roleplay m_iClient[MAXPLAYERS + 1];

enum SeedType {
	LEMONHAZE = 0,
	STRAWBERRY
}

int 
	g_iPlantsCount,
	g_iColorCocaine[4]	 			 = {220, 22, 226, 255},
	g_iColorEcstazy[4]				 = {11, 234, 22, 255},
	g_iColorHeroine[4]				 = {239, 11, 46, 255},
	g_iColorShit[4]				     = {239, 239, 23, 255},
	g_iColorWeed[4]				     = {41, 19, 239, 255},
	g_iColorAmphetamine[4]		     = {66, 248, 255, 255},
	g_iPlante[5],
	g_iBeamSpriteFollow,
	g_iGlow,
	g_iPlanteCannabis[5],
	g_iGrammeCannabis[SeedType],
	g_iDefaultColors_c[6][3] = 
	{
		{
			255, 0, 0
		}, 
		{
			0, 255, 0
		}, 
		{
			0, 0, 255
		}, 
		{
			255, 255, 0
		}, 
		{
			0, 255, 255
		}, 
		{
			255, 0, 255
		}
	};
float
	g_fDiscoRotation[3] = { 1093926912.0, ... };
Database
	g_DB;	
	
enum struct ClientData {
	int EntityPlant[MAX_PLANT];
	int StoveActivMenu;
	char SteamID[32];
	bool HasGasStove;
}
ClientData iData[MAXPLAYERS + 1];

enum struct plant_data {
	int level;
	int owner;
	int water;
	int WaterTooMuchAttempt;
	int Number;
	int entity_index;
	int GradeID;
	SeedType type;
	bool HasDirt;
	bool HasSeed;
	Handle Timer_Grow;
	
	void SetSeed(SeedType mtype)
	{
		this.type = mtype;
		SetEntProp(this.entity_index, Prop_Send, "m_nSkin", mtype);
	}
	void SetDirt(bool value)
	{
		this.HasDirt = value;
		SetBodyGroup(this.entity_index, GetEntityStudioHdr(this.entity_index).FindBodyPart("dirt"), value);
	}
}
plant_data plant[MAXENTITIES + 1];

enum struct cvar {
	ConVar max_cocaine_acetone;
	ConVar max_cocaine_amoniaque;
	ConVar max_cocaine_bismuth;
	ConVar max_cocaine_phosphore;
	ConVar max_cocaine_acidsulf;
	ConVar max_cocaine_sodium;
	ConVar max_cocaine_toulene;
	ConVar max_cocaine_water;
	
	ConVar max_amphetamine_acetone;
	ConVar max_amphetamine_amoniaque;
	ConVar max_amphetamine_bismuth;
	ConVar max_amphetamine_phosphore;
	ConVar max_amphetamine_acidsulf;
	ConVar max_amphetamine_sodium;
	ConVar max_amphetamine_toulene;
	ConVar max_amphetamine_water;
	
	ConVar max_heroine_acetone;
	ConVar max_heroine_amoniaque;
	ConVar max_heroine_bismuth;
	ConVar max_heroine_phosphore;
	ConVar max_heroine_acidsulf;
	ConVar max_heroine_sodium;
	ConVar max_heroine_toulene;
	ConVar max_heroine_water;
	
	ConVar max_ecstasy_acetone;
	ConVar max_ecstasy_amoniaque;
	ConVar max_ecstasy_bismuth;
	ConVar max_ecstasy_phosphore;
	ConVar max_ecstasy_acidsulf;
	ConVar max_ecstasy_sodium;
	ConVar max_ecstasy_toulene;
	ConVar max_ecstasy_water;
	
	ConVar weed_grow;
	ConVar min_drugproduce;
	ConVar max_drugproduce;
}
cvar cvars;

enum drug_type {
	NONE = 0,
	COCAINE,
	AMPHETAMINE,
	HEROINE,
	ECSTASY
};

enum struct stove_data {
	int entity_index;
	int owner;
	/*			VARIABLES			*/
	drug_type drug[MAX_STOVEPLATE+1];
	int cooldown[MAX_STOVEPLATE+1];
	int FireLevel[MAX_STOVEPLATE+1];
	float GazLevel;
	int acetone[MAX_STOVEPLATE+1];
	int amoniaque[MAX_STOVEPLATE+1];
	int bismuth[MAX_STOVEPLATE+1];
	int acidphosphorique[MAX_STOVEPLATE+1];
	int acidsulfurique[MAX_STOVEPLATE+1];
	int sodium[MAX_STOVEPLATE+1];
	int toulene[MAX_STOVEPLATE+1];
	int water[MAX_STOVEPLATE+1];
	bool reservedplate[MAX_STOVEPLATE+1];
	bool HasPot[MAX_STOVEPLATE+1];
	bool HasBodyWater[MAX_STOVEPLATE+1];
	bool HasBodyChimic[MAX_STOVEPLATE+1];
	bool HasGas[2];
	bool IsAvailable;
	/*			FUNCTIONS			*/
		/*		   GET		   */
	drug_type GetPlateDrugType(int plate = 1)
	{
		return this.drug[plate];
	}
	void GetPlateDrugName(int plate = 1, char[] buffer, int maxlength)
	{
		switch(this.drug[plate])
		{
			case NONE:Format(buffer, sizeof(maxlength), "N/A");
			case COCAINE:Format(buffer, sizeof(maxlength), "Cocaïne");	
			case AMPHETAMINE:Format(buffer, sizeof(maxlength), "Amphetamïne");
			case HEROINE:Format(buffer, sizeof(maxlength), "Heroïne");
			case ECSTASY:Format(buffer, sizeof(maxlength), "Ecstasy");			
		}
	}
	bool IsPlateAvailable(int plate = 1)
	{
		if(this.reservedplate[plate])
			return false;
		else
			return true;
	}
	int GetPlateCooldown(int plate = 1)
	{
		return this.cooldown[plate];
	}
	int GetPlateFireLevel(int plate = 1)
	{
		return this.FireLevel[plate];
	}
	int GetPlateWater(int plate = 1)
	{
		return this.water[plate];
	}
	bool HasPlatePot(int plate = 1)
	{
		return this.HasPot[plate];
	}
	int GetMaxAcetone(int plate = 1)
	{
		switch(this.drug[plate])
		{
			case COCAINE:return cvars.max_cocaine_acetone.IntValue;
			case AMPHETAMINE:return cvars.max_amphetamine_acetone.IntValue;
			case HEROINE:return cvars.max_heroine_acetone.IntValue;
			case ECSTASY:return cvars.max_ecstasy_acetone.IntValue;
		}
		
		return false;
	}
	int GetMaxAmoniaque(int plate = 1)
	{
		switch(this.drug[plate])
		{
			case COCAINE:return cvars.max_cocaine_amoniaque.IntValue;
			case AMPHETAMINE:return cvars.max_amphetamine_amoniaque.IntValue;
			case HEROINE:return cvars.max_heroine_amoniaque.IntValue;
			case ECSTASY:return cvars.max_ecstasy_amoniaque.IntValue;
		}
		
		return false;
	}
	int GetMaxBismuth(int plate = 1)
	{
		switch(this.drug[plate])
		{
			case COCAINE:return cvars.max_cocaine_bismuth.IntValue;
			case AMPHETAMINE:return cvars.max_amphetamine_bismuth.IntValue;
			case HEROINE:return cvars.max_heroine_bismuth.IntValue;
			case ECSTASY:return cvars.max_ecstasy_bismuth.IntValue;
		}
		
		return false;
	}
	int GetMaxPhosphore(int plate = 1)
	{
		switch(this.drug[plate])
		{
			case COCAINE:return cvars.max_cocaine_phosphore.IntValue;
			case AMPHETAMINE:return cvars.max_amphetamine_phosphore.IntValue;
			case HEROINE:return cvars.max_heroine_phosphore.IntValue;
			case ECSTASY:return cvars.max_ecstasy_phosphore.IntValue;
		}
		
		return false;
	}
	int GetMaxSulfurique(int plate = 1)
	{
		switch(this.drug[plate])
		{
			case COCAINE:return cvars.max_cocaine_acidsulf.IntValue;
			case AMPHETAMINE:return cvars.max_amphetamine_acidsulf.IntValue;
			case HEROINE:return cvars.max_heroine_acidsulf.IntValue;
			case ECSTASY:return cvars.max_ecstasy_acidsulf.IntValue;
		}
		
		return false;
	}
	int GetMaxSodium(int plate = 1)
	{
		switch(this.drug[plate])
		{
			case COCAINE:return cvars.max_cocaine_sodium.IntValue;
			case AMPHETAMINE:return cvars.max_amphetamine_sodium.IntValue;
			case HEROINE:return cvars.max_heroine_sodium.IntValue;
			case ECSTASY:return cvars.max_ecstasy_sodium.IntValue;
		}
		
		return false;
	}
	int GetMaxToulene(int plate = 1)
	{
		switch(this.drug[plate])
		{
			case COCAINE:return cvars.max_cocaine_toulene.IntValue;
			case AMPHETAMINE:return cvars.max_amphetamine_toulene.IntValue;
			case HEROINE:return cvars.max_heroine_toulene.IntValue;
			case ECSTASY:return cvars.max_ecstasy_toulene.IntValue;
		}
		
		return false;
	}
	int GetMaxWater(int plate = 1)
	{
		switch(this.drug[plate])
		{
			case COCAINE:return cvars.max_cocaine_water.IntValue;
			case AMPHETAMINE:return cvars.max_amphetamine_water.IntValue;
			case HEROINE:return cvars.max_heroine_water.IntValue;
			case ECSTASY:return cvars.max_ecstasy_water.IntValue;
		}
		
		return false;
	}
	bool HasMaxAcetone(int plate = 1)
	{
		switch(this.drug[plate])
		{
			case COCAINE:
			{
				if(this.acetone[plate] == cvars.max_cocaine_acetone.IntValue)
					return true;
			}
			case AMPHETAMINE:
			{
				if(this.acetone[plate] == cvars.max_amphetamine_acetone.IntValue)
					return true;
			}
			case HEROINE:
			{
				if(this.acetone[plate] == cvars.max_heroine_acetone.IntValue)
					return true;
			}
			case ECSTASY:
			{
				if(this.acetone[plate] == cvars.max_ecstasy_acetone.IntValue)
					return true;
			}
		}
		
		return false;
	}
	bool HasMaxAmoniaque(int plate = 1)
	{
		switch(this.drug[plate])
		{
			case COCAINE:
			{
				if(this.amoniaque[plate] == cvars.max_cocaine_amoniaque.IntValue)
					return true;
			}
			case AMPHETAMINE:
			{
				if(this.amoniaque[plate] == cvars.max_amphetamine_amoniaque.IntValue)
					return true;
			}
			case HEROINE:
			{
				if(this.amoniaque[plate] == cvars.max_heroine_amoniaque.IntValue)
					return true;
			}
			case ECSTASY:
			{
				if(this.amoniaque[plate] == cvars.max_ecstasy_amoniaque.IntValue)
					return true;
			}
		}
		
		return false;
	}
	bool HasMaxBismuth(int plate = 1)
	{
		switch(this.drug[plate])
		{
			case COCAINE:
			{
				if(this.bismuth[plate] == cvars.max_cocaine_bismuth.IntValue)
					return true;
			}
			case AMPHETAMINE:
			{
				if(this.bismuth[plate] == cvars.max_amphetamine_bismuth.IntValue)
					return true;
			}
			case HEROINE:
			{
				if(this.bismuth[plate] == cvars.max_heroine_bismuth.IntValue)
					return true;
			}
			case ECSTASY:
			{
				if(this.bismuth[plate] == cvars.max_ecstasy_bismuth.IntValue)
					return true;
			}
		}
		
		return false;
	}
	bool HasMaxPhosphore(int plate = 1)
	{
		switch(this.drug[plate])
		{
			case COCAINE:
			{
				if(this.acidphosphorique[plate] == cvars.max_cocaine_phosphore.IntValue)
					return true;
			}
			case AMPHETAMINE:
			{
				if(this.acidphosphorique[plate] == cvars.max_amphetamine_phosphore.IntValue)
					return true;
			}
			case HEROINE:
			{
				if(this.acidphosphorique[plate] == cvars.max_heroine_phosphore.IntValue)
					return true;
			}
			case ECSTASY:
			{
				if(this.acidphosphorique[plate] == cvars.max_ecstasy_phosphore.IntValue)
					return true;
			}
		}
		
		return false;
	}
	bool HasMaxSulfurique(int plate = 1)
	{
		switch(this.drug[plate])
		{
			case COCAINE:
			{
				if(this.acidsulfurique[plate] == cvars.max_cocaine_acidsulf.IntValue)
					return true;
			}
			case AMPHETAMINE:
			{
				if(this.acidsulfurique[plate] == cvars.max_amphetamine_acidsulf.IntValue)
					return true;
			}
			case HEROINE:
			{
				if(this.acidsulfurique[plate] == cvars.max_heroine_acidsulf.IntValue)
					return true;
			}
			case ECSTASY:
			{
				if(this.acidsulfurique[plate] == cvars.max_ecstasy_acidsulf.IntValue)
					return true;
			}
		}
		
		return false;
	}
	bool HasMaxSodium(int plate = 1)
	{
		switch(this.drug[plate])
		{
			case COCAINE:
			{
				if(this.sodium[plate] == cvars.max_cocaine_sodium.IntValue)
					return true;
			}
			case AMPHETAMINE:
			{
				if(this.sodium[plate] == cvars.max_amphetamine_sodium.IntValue)
					return true;
			}
			case HEROINE:
			{
				if(this.sodium[plate] == cvars.max_heroine_sodium.IntValue)
					return true;
			}
			case ECSTASY:
			{
				if(this.sodium[plate] == cvars.max_ecstasy_sodium.IntValue)
					return true;
			}
		}
		
		return false;
	}
	bool HasMaxToulene(int plate = 1)
	{
		switch(this.drug[plate])
		{
			case COCAINE:
			{
				if(this.toulene[plate] == cvars.max_cocaine_toulene.IntValue)
					return true;
			}
			case AMPHETAMINE:
			{
				if(this.toulene[plate] == cvars.max_amphetamine_toulene.IntValue)
					return true;
			}
			case HEROINE:
			{
				if(this.toulene[plate] == cvars.max_heroine_toulene.IntValue)
					return true;
			}
			case ECSTASY:
			{
				if(this.toulene[plate] == cvars.max_ecstasy_toulene.IntValue)
					return true;
			}
		}
		
		return false;
	}
	bool HasMaxWater(int plate = 1)
	{
		switch(this.drug[plate])
		{
			case COCAINE:
			{
				if(this.water[plate] == cvars.max_cocaine_water.IntValue)
					return true;
			}
			case AMPHETAMINE:
			{
				if(this.water[plate] == cvars.max_amphetamine_water.IntValue)
					return true;
			}
			case HEROINE:
			{
				if(this.water[plate] == cvars.max_heroine_water.IntValue)
					return true;
			}
			case ECSTASY:
			{
				if(this.water[plate] == cvars.max_ecstasy_water.IntValue)
					return true;
			}
		}
		
		return false;
	}
	bool HasMaxIngredients(int plate = 1)
	{
		if(this.HasMaxAcetone(plate) && this.HasMaxAmoniaque(plate) && this.HasMaxBismuth(plate) && this.HasMaxPhosphore(plate)
		&& this.HasMaxSulfurique(plate) && this.HasMaxSodium(plate) && this.HasMaxToulene(plate) && this.HasMaxWater(plate))
			return true;
		return false;
	}
		/*		   SET		   */
	void SetPlateFireLevel(int plate = 1, int value = 0)
	{
		char tmp[32];
		Format(STRING(tmp), "cooker_light_%i", plate);
		SetBodyGroup(this.entity_index, GetEntityStudioHdr(this.entity_index).FindBodyPart(tmp), value);
		this.FireLevel[plate] = value;
	}
	void SetPlateTemperatureEnt(int plate = 1, bool value)
	{
		char tmp[32];
		Format(STRING(tmp), "thermometer_%i", plate);
		SetBodyGroup(this.entity_index, GetEntityStudioHdr(this.entity_index).FindBodyPart(tmp), value);
	}
	void SetPlatePot(int plate = 1, bool value)
	{
		char tmp[32];
		Format(STRING(tmp), "pot%i", plate);
		SetBodyGroup(this.entity_index, GetEntityStudioHdr(this.entity_index).FindBodyPart(tmp), vint(value));
		this.HasPot[plate] = value;
	}
	drug_type SetPlateDrugType(int plate = 1, drug_type type)
	{
		return this.drug[plate] = type;
	}
	void AddGas()
	{
		if(!this.HasGas[0])
		{
			this.HasGas[0] = true;
			SetBodyGroup(this.entity_index, GetEntityStudioHdr(this.entity_index).FindBodyPart("gas_tanks"), 1);
		}	
		else
		{
			this.HasGas[1] = true;
			SetBodyGroup(this.entity_index, GetEntityStudioHdr(this.entity_index).FindBodyPart("gas_tanks"), 2);
		}	
	}
	void RemoveGas()
	{
		if(this.HasGas[1])
		{
			this.HasGas[1] = false;
			SetBodyGroup(this.entity_index, GetEntityStudioHdr(this.entity_index).FindBodyPart("gas_tanks"), 1);
		}	
		else
		{
			this.HasGas[0] = false;
			SetBodyGroup(this.entity_index, GetEntityStudioHdr(this.entity_index).FindBodyPart("gas_tanks"), 0);
		}
	}
	void IncreaseWater(int plate = 1)
	{
		if(!this.HasBodyWater[plate])
		{
			char tmp[32];
			Format(STRING(tmp), "pot%i_content", plate);		
			
			if(!this.HasBodyChimic[plate])
				SetBodyGroup(this.entity_index, GetEntityStudioHdr(this.entity_index).FindBodyPart(tmp), 1);
			else
				SetBodyGroup(this.entity_index, GetEntityStudioHdr(this.entity_index).FindBodyPart(tmp), 3);		

			this.HasBodyWater[plate] = true;	
		}	
		
		if(!this.HasPot[plate])
			this.SetPlatePot(plate, true);
		
		this.water[plate]++;
		rp_PrintToChat(this.owner, "Vous avez ajouter de {lightgreen}l'eau{default} a votre cuisson.");
	}
	void DisplayPotPouder(int plate = 1)
	{
		if(!this.HasBodyChimic[plate])
		{
			char tmp[32];
			Format(STRING(tmp), "pot%i_content", plate);
			
			if(!this.HasBodyWater[plate])
				SetBodyGroup(this.entity_index, GetEntityStudioHdr(this.entity_index).FindBodyPart(tmp), 2);
			else
				SetBodyGroup(this.entity_index, GetEntityStudioHdr(this.entity_index).FindBodyPart(tmp), 3);
				
			this.HasBodyChimic[plate] = true;
			
			if(!this.HasPot[plate])
				this.SetPlatePot(plate, true);
		}		
	}
	void IncreaseAcetone(int plate = 1)
	{
		this.DisplayPotPouder(plate);
		this.acetone[plate]++;
		rp_PrintToChat(this.owner, "Vous avez ajouter de {lightgreen}l'acetone{default} a votre cuisson.");
	}
	void IncreaseAmoniaque(int plate = 1)
	{
		this.DisplayPotPouder(plate);
		this.amoniaque[plate]++;
		rp_PrintToChat(this.owner, "Vous avez ajouter de {lightgreen}l'amoniaque{default} a votre cuisson.");
	}
	void IncreaseBismuth(int plate = 1)
	{
		this.DisplayPotPouder(plate);
		this.bismuth[plate]++;
		rp_PrintToChat(this.owner, "Vous avez ajouter du {lightgreen}bismuth{default} a votre cuisson.");
	}
	void IncreasePhosphore(int plate = 1)
	{
		this.DisplayPotPouder(plate);
		this.acidphosphorique[plate]++;
		rp_PrintToChat(this.owner, "Vous avez ajouter de {lightgreen}l'acide phosphorique{default} a votre cuisson.");
	}
	void IncreaseSulfurique(int plate = 1)
	{
		this.DisplayPotPouder(plate);
		this.acidsulfurique[plate]++;
		rp_PrintToChat(this.owner, "Vous avez ajouter de {lightgreen}l'acide sulfurique{default} a votre cuisson.");
	}
	void IncreaseSodium(int plate = 1)
	{
		this.DisplayPotPouder(plate);
		this.sodium[plate]++;
		rp_PrintToChat(this.owner, "Vous avez ajouter du {lightgreen}sodium{default} a votre cuisson.");
	}
	void IncreaseToulene(int plate = 1)
	{
		this.DisplayPotPouder(plate);
		this.toulene[plate]++;
		rp_PrintToChat(this.owner, "Vous avez ajouter du {lightgreen}Toulene{default} a votre cuisson.");
	}
	void Reset(int plate)
	{
		this.cooldown[plate] = 0;
		this.acetone[plate] = 0;
		this.amoniaque[plate] = 0;
		this.bismuth[plate] = 0;
		this.acidphosphorique[plate] = 0;
		this.acidsulfurique[plate] = 0;
		this.sodium[plate] = 0;
		this.toulene[plate] = 0;
		this.reservedplate[plate] = false;
		this.HasBodyChimic[plate] = false;
		
		char tmp[32];
		Format(STRING(tmp), "pot%i_content", plate);
		SetBodyGroup(this.entity_index, GetEntityStudioHdr(this.entity_index).FindBodyPart(tmp), 0);
		
		this.SetPlatePot(plate, false);
		this.SetPlateTemperatureEnt(plate, false);
		this.SetPlateDrugType(plate, NONE);
		this.SetPlateFireLevel(plate, 0);
	}
}
stove_data stove[MAXENTITIES + 1];

enum struct BoxData {
	// Constructor
	int entity_index;
	
	int content;
	bool HasCocaine;
	bool HasAmphetamine;
	bool HasHeroine;
	bool HasEcstasy;
	
	void IncreaseContent()
	{
		this.content++;
		SetBodyGroup(this.entity_index, GetEntityStudioHdr(this.entity_index).FindBodyPart("cocaine"), this.content);
	}
	
	void SetContent(drug_type type, bool value)
	{
		switch(type)
		{
			case COCAINE:this.HasCocaine = value;
			case AMPHETAMINE:this.HasAmphetamine = value;
			case HEROINE:this.HasHeroine = value;
			case ECSTASY:this.HasEcstasy = value;
		}
	}
	
	void SetTop(int value)
	{
		if(value >= 1 && value <= 3)
			SetBodyGroup(this.entity_index, GetEntityStudioHdr(this.entity_index).FindBodyPart("top"), value);
	}
}
BoxData box[MAXENTITIES + 1];

/***************************************************************************************

							P L U G I N  -  I N F O

***************************************************************************************/
public Plugin myinfo = 
{
	name = "Roleplay - [JOB] Dealer", 
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
	
	/*----------------------------------Local ConVars-------------------------------*/
	cvars.max_cocaine_acetone = CreateConVar("rp_max_cocaine_acetone", "2", "Acetone nécessaire à la fabrication de la cocaine.");
	cvars.max_cocaine_amoniaque = CreateConVar("rp_max_cocaine_amoniaque", "2", "Amoniaque nécessaire à la fabrication de la cocaine.");
	cvars.max_cocaine_bismuth = CreateConVar("rp_max_cocaine_bismuth", "2", "Bismuth nécessaire à la fabrication de la cocaine.");
	cvars.max_cocaine_phosphore = CreateConVar("rp_max_cocaine_phosphore", "2", "Acide phosphorique nécessaire à la fabrication de la cocaine.");
	cvars.max_cocaine_acidsulf = CreateConVar("rp_max_cocaine_acidsulf", "2", "Acide sulfurique nécessaire à la fabrication de la cocaine.");
	cvars.max_cocaine_sodium = CreateConVar("rp_max_cocaine_sodium", "2", "Sodium nécessaire à la fabrication de la cocaine.");
	cvars.max_cocaine_toulene = CreateConVar("rp_max_cocaine_toulene", "2", "Toulene nécessaire à la fabrication de la cocaine.");
	cvars.max_cocaine_water = CreateConVar("rp_max_cocaine_water", "2", "Eau nécessaire à la fabrication de la cocaine.");
	
	cvars.max_amphetamine_acetone = CreateConVar("rp_max_amphetamine_acetone", "2", "Acetone nécessaire à la fabrication de l'amphetamine.");
	cvars.max_amphetamine_amoniaque = CreateConVar("rp_max_amphetamine_amoniaque", "2", "Amoniaque nécessaire à la fabrication de l'amphetamine.");
	cvars.max_amphetamine_bismuth = CreateConVar("rp_max_amphetamine_bismuth", "2", "Bismuth nécessaire à la fabrication de l'amphetamine.");
	cvars.max_amphetamine_phosphore = CreateConVar("rp_max_amphetamine_phosphore", "2", "Acide phosphorique nécessaire à la fabrication de l'amphetamine.");
	cvars.max_amphetamine_acidsulf = CreateConVar("rp_max_amphetamine_acidsulf", "2", "Acide sulfurique nécessaire à la fabrication de l'amphetamine.");
	cvars.max_amphetamine_sodium = CreateConVar("rp_max_amphetamine_sodium", "2", "Sodium nécessaire à la fabrication de l'amphetamine.");
	cvars.max_amphetamine_toulene = CreateConVar("rp_max_amphetamine_toulene", "2", "Toulene nécessaire à la fabrication de l'amphetamine.");
	cvars.max_amphetamine_water = CreateConVar("rp_max_amphetamine_water", "2", "Eau nécessaire à la fabrication de l'amphetamine.");
	
	cvars.max_heroine_acetone = CreateConVar("rp_max_heroine_acetone", "2", "Acetone nécessaire à la fabrication de l'heroine.");
	cvars.max_heroine_amoniaque = CreateConVar("rp_max_heroine_amoniaque", "2", "Amoniaque nécessaire à la fabrication de l'heroine.");
	cvars.max_heroine_bismuth = CreateConVar("rp_max_heroine_bismuth", "2", "Bismuth nécessaire à la fabrication de l'heroine.");
	cvars.max_heroine_phosphore = CreateConVar("rp_max_heroine_phosphore", "2", "Acide phosphorique nécessaire à la fabrication de l'heroine.");
	cvars.max_heroine_acidsulf = CreateConVar("rp_max_heroine_acidsulf", "2", "Acide sulfurique nécessaire à la fabrication de l'heroine.");
	cvars.max_heroine_sodium = CreateConVar("rp_max_heroine_sodium", "2", "Sodium nécessaire à la fabrication de l'heroine.");
	cvars.max_heroine_toulene = CreateConVar("rp_max_heroine_toulene", "2", "Toulene nécessaire à la fabrication de l'heroine.");
	cvars.max_heroine_water = CreateConVar("rp_max_heroine_water", "2", "Eau nécessaire à la fabrication de l'heroine.");
	
	cvars.max_ecstasy_acetone = CreateConVar("rp_max_ecstasy_acetone", "2", "Acetone nécessaire à la fabrication de l'ecstasy.");
	cvars.max_ecstasy_amoniaque = CreateConVar("rp_max_ecstasy_amoniaque", "2", "Amoniaque nécessaire à la fabrication de l'ecstasy.");
	cvars.max_ecstasy_bismuth = CreateConVar("rp_max_ecstasy_bismuth", "2", "Bismuth nécessaire à la fabrication de l'ecstasy.");
	cvars.max_ecstasy_phosphore = CreateConVar("rp_max_ecstasy_phosphore", "2", "Acide phosphorique nécessaire à la fabrication de l'ecstasy.");
	cvars.max_ecstasy_acidsulf = CreateConVar("rp_max_ecstasy_acidsulf", "2", "Acide sulfurique nécessaire à la fabrication de l'ecstasy.");
	cvars.max_ecstasy_sodium = CreateConVar("rp_max_ecstasy_sodium", "2", "Sodium nécessaire à la fabrication de l'ecstasy.");
	cvars.max_ecstasy_toulene = CreateConVar("rp_max_ecstasy_toulene", "2", "Toulene nécessaire à la fabrication de l'ecstasy.");
	cvars.max_ecstasy_water = CreateConVar("rp_max_ecstasy_water", "2", "Eau nécessaire à la fabrication de l'ecstasy.");
	
	cvars.weed_grow = CreateConVar("rp_weedgrow_timer", "10.0", "Timer en secondes pour que la plante de cannabis pousse à tels moment.");
	
	cvars.min_drugproduce = CreateConVar("rp_min_drugproduce", "5", "Minimum number between the maximum for drug production stock.");
	cvars.max_drugproduce = CreateConVar("rp_max_drugproduce", "10", "Maximum number between the minimum for drug production stock.");
	
	AutoExecConfig(true, "rp_job_dealer", "roleplay");
	/*------------------------------------------------------------------------*/
	
	LoopClients(i)
	{
		if(!IsClientValid(i))
			continue;
		OnClientAuthorized(i, "");
	}
}

public void RP_OnSQLInit(Database db, Transaction transaction)
{
	g_DB = db;
}

public void OnMapStart()
{
	g_iBeamSpriteFollow = PrecacheModel("materials/sprites/laserbeam.vmt", true);
	g_iGlow = PrecacheModel("materials/sprites/glow1.vmt", true);	
		
	for(int i = 0; i <= 4; i++)
		g_iPlanteCannabis[i] = 0;
}

/***************************************************************************************

									C L I E N T - S I D E

***************************************************************************************/
public void OnClientDisconnect(int client)
{
	rp_SetClientBool(client, b_HasJointEffect, false);
	rp_SetClientBool(client, b_HasShitEffect, false);
	rp_SetClientBool(client, b_HasAmphetamineEffect, false);	
	rp_SetClientBool(client, b_HasHeroineEffect, false);
	rp_SetClientBool(client, b_HasCocainaEffect, false);	
	rp_SetClientBool(client, b_HasEcstasyEffect, false);	
	
	for(int i = 0; i <= 1; i++)
	{
		if(IsValidEntity(iData[client].EntityPlant[i]))
		{
			RemoveEdict(iData[client].EntityPlant[i]);
			iData[client].EntityPlant[i] = -1;
		}
	}
}

public void OnClientPutInServer(int client)
{
	// MethodMap Constructor
	m_iClient[client] = Roleplay(client);
	
	rp_SetClientBool(client, b_HasJointEffect, false);
	rp_SetClientBool(client, b_HasShitEffect, false);
	rp_SetClientBool(client, b_HasAmphetamineEffect, false);	
	rp_SetClientBool(client, b_HasHeroineEffect, false);
	rp_SetClientBool(client, b_HasCocainaEffect, false);	
	rp_SetClientBool(client, b_HasEcstasyEffect, false);
	
	for(int i = 0; i <= 1; i++)
	{
		iData[client].EntityPlant[i] = -1;
	}
	iData[client].HasGasStove = false;
}

public void OnClientAuthorized(int client, const char[] auth) 
{	
	strcopy(iData[client].SteamID, sizeof(iData[].SteamID), auth);
}

/***************************************************************************************

									C A L L B A C K

***************************************************************************************/  

public void RP_OnClientDeath(int attacker, int victim, const char[] weapon, bool headshot)
{
	if(rp_GetClientBool(victim, b_HasJointEffect))
		rp_SetClientBool(victim, b_HasJointEffect, false);
		
	if(rp_GetClientBool(victim, b_HasShitEffect))
		rp_SetClientBool(victim, b_HasShitEffect, false);
	
	if(rp_GetClientBool(victim, b_HasAmphetamineEffect))
		rp_SetClientBool(victim, b_HasAmphetamineEffect, false);	
	
	if(rp_GetClientBool(victim, b_HasHeroineEffect))
		rp_SetClientBool(victim, b_HasHeroineEffect, false);
		
	if(rp_GetClientBool(victim, b_HasCocainaEffect))
		rp_SetClientBool(victim, b_HasCocainaEffect, false);	
		
	if(rp_GetClientBool(victim, b_HasEcstasyEffect))
		rp_SetClientBool(victim, b_HasEcstasyEffect, false);		
}

public void RP_OnClientInteract(int client, int target, const char[] class, const char[] model, const char[] name)
{
	if(rp_GetNPCType(target) == JOBID)
	{
		if(Distance(client, target) <= 80.0)
			rp_PerformNPCSell(client, JOBID);
		else
			Translation_PrintTooFar(client);
	}
	
	char sTmp[128];
	rp_GetGlobalData("model_plant", STRING(sTmp));
	
	char buffer[2][64];
	if(StrEqual(model, sTmp))
	{
		if(Distance(client, target) <= 80.0)
		{
			if(rp_GetClientInt(client, i_Job) == JOBID || plant[target].owner == client)
			{
				if(plant[target].level != PLANT_MAXSTEP)
				{
					rp_PrintToChat(client, "Cette plante n'est pas encore prête pour la recolte.");
					PrintHintText(client, "<font color='#5100A2'>Cette plante n'est pas encore prête pour la recolte.</font>");
				}
				else
				{
					plant[target].SetDirt(false);
					if(rp_GetClientInt(client, i_Job) == JOBID)
					{
						int nombre = GetRandomInt(0, 15);
						
						ExplodeString(name, "|", buffer, 2, 64);
						
						g_iGrammeCannabis[plant[target].type] += nombre;
							
						if(StrEqual(buffer[0], "1") && rp_GetClientInt(client, i_Grade) == 1)
						{
							g_iPlanteCannabis[0]--;
						}	
						else if(StrEqual(buffer[0], "2") && rp_GetClientInt(client, i_Grade) == 2)
						{
							g_iPlanteCannabis[1]--;
						}
						else if(StrEqual(buffer[0], "3") && rp_GetClientInt(client, i_Grade) == 3)
						{
							g_iPlanteCannabis[2]--;
						}
						else if(StrEqual(buffer[0], "4") && rp_GetClientInt(client, i_Grade) == 4)
						{
							g_iPlanteCannabis[3]--;
						}
						else if(StrEqual(buffer[0], "5") && rp_GetClientInt(client, i_Grade) == 5)
						{
							g_iPlanteCannabis[4]--;
						}
						else
							rp_PrintToChat(client, "C'est mal de voler ses collègues.");
									
						rp_PrintToChat(client, "Vous avez récolté {lightgreen}%ig {default}de cannabis[%s].", nombre, (plant[target].type == LEMONHAZE) ? "Lemon Haze" : "Strawberry");
						
						RemoveEdict(target);
					}
					else if(plant[target].owner == client)
					{
						RemoveEdict(target);
						rp_SetClientInt(client, i_Plante, rp_GetClientInt(client, i_Plante) - 1);
						ExplodeString(name, "|", buffer, 2, 64);
						
						if(StrEqual(buffer[1], "plante0"))
							iData[client].EntityPlant[0] = -1;
						else
							iData[client].EntityPlant[1] = -1;		
						
						switch(GetRandomInt(0, 15))
						{
							case 0,1,2:rp_PrintToChat(client, "Cette plante est un mâle, seul les femelles produisent !");
							default:
							{
								int joints = GetRandomInt(1, 3);
								rp_SetClientItem(client, 136, rp_GetClientItem(client, 136, false) + joints, false);
								rp_PrintToChat(client, "Vous avez produits {lightgreen}%ig {default}joints de cannabis.", joints);
							}
						}
					}
				}
			}	
		}
	}	
	
	rp_GetGlobalData("model_gasstove", STRING(sTmp));
	if(StrEqual(model, sTmp) && rp_GetClientInt(client, i_Job) == JOBID)
	{
		if(Distance(client, target) <= 80.0)
		{
			iData[client].StoveActivMenu = target;
			MenuStove(client, target);
		}	
		else
			Translation_PrintTooFar(client);
	}
}	

public void RP_OnPlayerTase(int client, int target, int reward, const char[] class, const char[] model, const char[] name)
{
	if(Distance(client, target) <= 80)
	{
		char sTmp[128];
		rp_GetGlobalData("model_plant", STRING(sTmp));
		if(StrEqual(model, sTmp))
		{
			if(IsValidEdict(target))
				RemoveEdict(target);
						
			char buffer[2][64];
			ExplodeString(name, "|", buffer, 2, 64);
						
			int joueur = Client_FindBySteamId(buffer[1]);
						
			if(StrEqual(buffer[0], "1"))
				g_iPlante[0]--;
			else if(StrEqual(buffer[0], "2"))
				g_iPlante[1]--;
			else if(StrEqual(buffer[0], "3"))
				g_iPlante[2]--;	
			else if(StrEqual(buffer[0], "4"))
				g_iPlante[3]--;
			else if(StrEqual(buffer[0], "5"))
				g_iPlante[4]--;		
						
			if(IsClientValid(joueur))
				rp_PrintToChat(joueur, "Une plante de cannabis a été saisi par le service de Police.");
						
			reward = 100;
	
			rp_PrintToChat(client, "Vous avez saisi une plante de cannabis.");
			rp_PrintToChat(client, "Le Chef Police vous reverse une prime de 100$ pour cette saisie.");
		}
		
		rp_GetGlobalData("model_gasstove", STRING(sTmp));
		if(StrEqual(model, sTmp))
		{
			if(IsValidEdict(target))
				RemoveEdict(target);
						
			int joueur = Client_FindBySteamId(name);		
			iData[joueur].HasGasStove = false;
						
			if(IsClientValid(joueur))
				rp_PrintToChat(joueur, "Une cuisinière à gaz vous a été saisie par le service de Police.");
						
			reward = 100;
	
			rp_PrintToChat(client, "Vous avez saisi un étendoir de contre bande.");
			rp_PrintToChat(client, "Le Chef Police vous reverse une prime de 100$ pour cette saisie.");
		}
	}
}	

public void RP_OnClientBuild(Menu menu, int client)
{
	if(rp_GetClientInt(client, i_Job) == JOBID)
	{
		menu.AddItem("cannabis", "Planter du Cannabis");
		menu.AddItem("build", "Fabriquer de la drogue");
		menu.AddItem("dealer", "Gérer le stock");
		if(rp_GetClientBool(client, b_IsVip))
			menu.AddItem("dj", "Système DJ");
		else
			menu.AddItem("", "Système DJ(VIP)", ITEMDRAW_DISABLED);				
	}	
}	

public void RP_OnClientBuildHandle(int client, const char[] info)
{
	if(StrEqual(info, "cannabis"))
	{
		if(rp_GetClientInt(client, i_Zone) != 777)
		{
			if(IsOnGround(client))
			{
				char strBuffer[128];
				rp_SetClientInt(client, i_Plante, rp_GetClientInt(client, i_Plante) + 1);
				
				for(int i = 1; i <= rp_GetJobMaxGrades(9); i++)
				{					
					if(rp_GetClientInt(client, i_Grade) == i)
					{							
						if(IsOnGround(client))
						{
							if(g_iPlante[i--] < MAX_PLANT)
							{
								Format(STRING(strBuffer), "%i|%s", rp_GetClientInt(client, i_Grade), iData[client].SteamID);
								BuildCanabisModel(client, strBuffer);
								g_iPlante[i--]++;
								g_iPlantsCount++;
									
								rp_PrintToChat(client, "Vous avez planté du cannabis, attendez qu'il pousse pour le récolter. [%i/%i]", g_iPlante[i--], MAX_PLANT);
							}
							else
								rp_PrintToChat(client, "Vous n'avez plus de graine ! [%i/%i]", MAX_PLANT, MAX_PLANT);		
							break;
						}	
					}
				}	
			}		
		}
		else 
			rp_PrintToChat(client, "Interdit de poser une plante en zone P.V.P");
	}
	else if(StrEqual(info, "build"))
		MenuBuildDrugs(client);
	else if (StrEqual(info, "dealer"))
		MenuDealer(client);
	else if (StrEqual(info, "dj"))
		MenuDJDealer(client);	
}	

void MenuBuildDrugs(int client)
{
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_MenuBuildDrugs);
	menu.SetTitle("Fabrication de drogues");
	
	char strFormat[32];
	Format(STRING(strFormat), "Cuisinière à gaz");
	menu.AddItem("gasstove", strFormat, (iData[client].HasGasStove) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);		
	menu.AddItem("acetone", "Acetone");	
	menu.AddItem("amoniaque", "Amoniaque");	
	menu.AddItem("bismuth", "Bismuth");	
	menu.AddItem("phosphore", "Phosphore");	
	menu.AddItem("acidsulf", "Acide Sulfurique");	
	menu.AddItem("sodium", "Sodium");	
	menu.AddItem("toulene", "Toulenne");	
	
	menu.ExitButton = true;
	menu.ExitBackButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Handle_MenuBuildDrugs(Menu menu, MenuAction action, int client, int param)
{
	if (action == MenuAction_Select)
	{
		char info[64];
		menu.GetItem(param, STRING(info));
		
		if(rp_GetClientInt(client, i_Zone) != 777)
		{
			if(IsOnGround(client))
			{
				int ent;
				float TeleportOrigin[3], JoueurOrigin[3];
				GetClientAbsOrigin(client, JoueurOrigin);
				TeleportOrigin[0] = JoueurOrigin[0];
				TeleportOrigin[1] = JoueurOrigin[1];
				TeleportOrigin[2] = (JoueurOrigin[2]);
				
				char sTmp[128];
				
				if (StrEqual(info, "acetone"))
				{
					rp_GetGlobalData("model_acetone", STRING(sTmp));
					ent = rp_CreatePhysics("", TeleportOrigin, NULL_VECTOR, sTmp, 0, true);
					rp_PrintToChat(client, "Vous avez placé un bidon d'acetone, à manier avec précaution.");
				}
				else if (StrEqual(info, "amoniaque"))
				{
					rp_GetGlobalData("model_ammoniac", STRING(sTmp));
					ent = rp_CreatePhysics("", TeleportOrigin, NULL_VECTOR, sTmp, 0, true);
					rp_PrintToChat(client, "Vous avez placé un bidon d'amoniaque, à manier avec précaution.");
				}
				else if (StrEqual(info, "bismuth"))
				{
					rp_GetGlobalData("model_bismuth", STRING(sTmp));
					ent = rp_CreatePhysics("", TeleportOrigin, NULL_VECTOR, sTmp, 0, true);
					rp_PrintToChat(client, "Vous avez placé un bidon de Bismuth, à manier avec précaution.");
				}
				else if (StrEqual(info, "phosphore"))
				{
					rp_GetGlobalData("model_phosphore", STRING(sTmp));
					ent = rp_CreatePhysics("", TeleportOrigin, NULL_VECTOR, sTmp, 0, true);
					rp_PrintToChat(client, "Vous avez placé un bidon d'acide Phosphorique, à manier avec précaution.");
				}
				else if (StrEqual(info, "acidsulf"))
				{
					rp_GetGlobalData("model_sulfuric", STRING(sTmp));
					ent = rp_CreatePhysics("", TeleportOrigin, NULL_VECTOR, sTmp, 0, true);
					rp_PrintToChat(client, "Vous avez placé un bidon d'acide Sulfurique, à manier avec précaution.");
				}
				else if (StrEqual(info, "sodium"))
				{
					rp_GetGlobalData("model_sodium", STRING(sTmp));
					ent = rp_CreatePhysics("", TeleportOrigin, NULL_VECTOR, sTmp, 0, true);
					rp_PrintToChat(client, "Vous avez placé un bidon de Sodium, à manier avec précaution.");
				}
				else if (StrEqual(info, "toulene"))
				{
					rp_GetGlobalData("model_toulene", STRING(sTmp));
					ent = rp_CreatePhysics("", TeleportOrigin, NULL_VECTOR, sTmp, 0, true);
					rp_PrintToChat(client, "Vous avez placé un bidon de Toulene, à manier avec précaution.");
				}
				else if(StrEqual(info, "gasstove"))
				{
					rp_GetGlobalData("model_gasstove", STRING(sTmp));
					ent = rp_CreatePhysics("", TeleportOrigin, NULL_VECTOR, sTmp, 0, true);
					iData[client].HasGasStove = true;
					stove[ent].owner = client;
					stove[ent].entity_index = ent;
					for(int i = 1; i <= 4; i++)
						stove[ent].reservedplate[i] = false;
					
					rp_PrintToChat(client, "Vous avez installé une cuisinière à gaz.");		
				}
				
				Entity_SetName(ent, iData[client].SteamID);
				JoueurOrigin[2] += 50;
				TeleportEntity(client, JoueurOrigin, NULL_VECTOR, NULL_VECTOR);
			}	
		}	
		else 
			rp_PrintToChat(client, "Interdit en zone P.V.P");
			
		rp_SetClientBool(client, b_DisplayHud, true);	
	}
	else if (action == MenuAction_Cancel)
	{
		if (param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if(param == MenuCancel_ExitBack)	
			FakeClientCommand(client, "say !b");
	}
	else if (action == MenuAction_End)
		delete menu;
		
	return 0;
}

public void RP_OnClientStartTouch(int caller, int activator)
{
	if (IsValidEntity(caller))
	{
		if (IsEntityModelInArray(caller, "model_acetone") || IsEntityModelInArray(caller, "model_ammoniac")
		|| IsEntityModelInArray(caller, "model_bismuth") || IsEntityModelInArray(caller, "model_phosphore")
		|| IsEntityModelInArray(caller, "model_sulfuric") || IsEntityModelInArray(caller, "model_sodium")
		|| IsEntityModelInArray(caller, "model_toulene") || IsEntityModelInArray(caller, "model_battery")
		|| IsEntityModelInArray(caller, "model_gasstove") || IsEntityModelInArray(caller, "model_water")
		|| IsEntityModelInArray(caller, "model_plant") || IsEntityModelInArray(caller, "model_gastank") 
		|| IsEntityModelInArray(caller, "model_dirtbag") || IsEntityModelInArray(caller, "model_weedseed"))
		{
			char strName[64];
			Entity_GetName(caller, STRING(strName));
			
			//int client = Client_FindBySteamId(strName);
			int client;
			
			if (IsEntityModelInArray(activator, "model_gasstove"))
			{
				client = stove[activator].owner;
				if(IsClientValid(client))
				{
					if(rp_GetClientInt(client, i_Job) == JOBID)
					{
						if(IsEntityModelInArray(caller, "model_water"))
						{
							for(int i = 1; i <= 4; i++)
							{
								if(!stove[activator].HasMaxWater(i))
								{
									RemoveEdict(caller);
									MenuSelectPlateForIncrease(client, activator, "water");
								}	
							}	
						}
						else if(IsEntityModelInArray(caller, "model_acetone"))
						{
							for(int i = 1; i <= 4; i++)
							{
								if(!stove[activator].HasMaxAcetone(i))
								{
									RemoveEdict(caller);
									MenuSelectPlateForIncrease(client, activator, "acetone");
								}	
							}
						}	
						else if(IsEntityModelInArray(caller, "model_ammoniac"))
						{
							for(int i = 1; i <= 4; i++)
							{
								if(!stove[activator].HasMaxAmoniaque(i))
								{
									RemoveEdict(caller);
									MenuSelectPlateForIncrease(client, activator, "ammoniac");
								}	
							}
						}	
						else if(IsEntityModelInArray(caller, "model_bismuth"))
						{
							for(int i = 1; i <= 4; i++)
							{
								if(!stove[activator].HasMaxBismuth(i))
								{
									RemoveEdict(caller);
									MenuSelectPlateForIncrease(client, activator, "bismuth");
								}	
							}
						}	
						else if(IsEntityModelInArray(caller, "model_phosphore"))
						{
							for(int i = 1; i <= 4; i++)
							{
								if(!stove[activator].HasMaxPhosphore(i))
								{
									RemoveEdict(caller);
									MenuSelectPlateForIncrease(client, activator, "phosphore");
								}	
							}
						}
						else if(IsEntityModelInArray(caller, "model_sulfuric"))
						{
							for(int i = 1; i <= 4; i++)
							{
								if(!stove[activator].HasMaxSulfurique(i))
								{
									RemoveEdict(caller);
									MenuSelectPlateForIncrease(client, activator, "sulfuric");
								}	
							}
						}
						else if(IsEntityModelInArray(caller, "model_sodium"))
						{
							for(int i = 1; i <= 4; i++)
							{
								if(!stove[activator].HasMaxSodium(i))
								{
									RemoveEdict(caller);
									MenuSelectPlateForIncrease(client, activator, "sodium");
								}	
							}
						}
						else if(IsEntityModelInArray(caller, "model_toulene"))
						{
							for(int i = 1; i <= 4; i++)
							{
								if(!stove[activator].HasMaxToulene(i))
								{
									RemoveEdict(caller);
									MenuSelectPlateForIncrease(client, activator, "toulene");
								}	
							}
						}	
						else if(IsEntityModelInArray(caller, "model_gastank"))
						{
							if(!stove[activator].HasGas[0] || !stove[activator].HasGas[1])
							{
								RemoveEdict(caller);
								rp_Sound(client, "sound_filldrug", 0.2);
								
								float position[3];
								GetEntPropVector(activator, Prop_Send, "m_vecOrigin", position);
								rp_CreateParticle(position, "ambient_sparks", 1.0);
								stove[activator].GazLevel += 50.0;
								stove[activator].AddGas();
							}
							else
								rp_PrintToChat(client, "La cuisinière à gaz a atteint sa capacité maximum de bouteille de gaz.");									
						}
					}	
				}
			}	
			else if (IsEntityModelInArray(activator, "model_plant"))
			{
				client = plant[activator].owner;
				if(IsClientValid(client))
				{
					if (rp_GetClientInt(client, i_Job) == JOBID)
					{
						if(IsEntityModelInArray(caller, "model_water"))
						{
							RemoveEdict(caller);
							if(plant[activator].WaterTooMuchAttempt != MAX_WATERATTEMPT)
							{
								if(plant[activator].water < 100)
								{
									plant[activator].water += 25;
									if(plant[activator].water >= 100)
										plant[activator].water = 100;
									rp_PrintToChat(client, "Vous avez arrosée : {lightblue}%i{default}/{green}100", plant[activator].water);
									
									if(plant[activator].Timer_Grow == null && plant[activator].HasDirt && plant[activator].HasSeed)
										plant[activator].Timer_Grow = CreateTimer(cvars.weed_grow.FloatValue, Timer_PlantWeedGrow, activator);
									if(!plant[activator].HasDirt)
										rp_PrintToChat(client, "Votre plante n'as pas de terreau.");
									if(!plant[activator].HasSeed)
										rp_PrintToChat(client, "Votre plante n'as pas de graine.");				
									
									float position[3];
									GetEntPropVector(activator, Prop_Send, "m_vecOrigin", position);
									rp_CreateParticle(position, "bubble", 1.0);
								}	
								else
								{
									plant[activator].WaterTooMuchAttempt++;
									rp_PrintToChat(client, "{orange}Vous aller noyer votre plante{default}.");	
								}	
							}
							else
							{
								if(plant[activator].Timer_Grow != null)
									plant[activator].Timer_Grow = null;
								RemoveEdict(activator);
								rp_PrintToChat(client, "{lightred}Vous avez noyer la plante{default}.");
							}
						}
						else if(IsEntityModelInArray(caller, "model_dirtbag"))
						{
							if(!plant[activator].HasDirt)
							{
								RemoveEdict(caller);
								if(plant[activator].Timer_Grow == null && plant[activator].water > 8 && plant[activator].HasSeed)
									plant[activator].Timer_Grow = CreateTimer(cvars.weed_grow.FloatValue, Timer_PlantWeedGrow, activator);
								if(plant[activator].water < 8)
									rp_PrintToChat(client, "Votre plante n'as pas assez d'eau, arroser la.");
								if(!plant[activator].HasSeed)
									rp_PrintToChat(client, "Votre plante n'as pas de graine.");	
								
								plant[activator].SetDirt(true);
								rp_Sound(client, "sound_filldrug", 0.2);
								rp_PrintToChat(client, "Vous avez versé le sac de terre dans le pot.");
							}
						}
						else if(IsEntityModelInArray(caller, "model_weedseed"))
						{
							if(!plant[activator].HasSeed)
							{
								if(plant[activator].Timer_Grow == null && plant[activator].water > 8 && plant[activator].HasDirt)
									plant[activator].Timer_Grow = CreateTimer(cvars.weed_grow.FloatValue, Timer_PlantWeedGrow, activator);
								if(plant[activator].water < 8)
									rp_PrintToChat(client, "Votre plante n'as pas assez d'eau, arroser la.");
								if(!plant[activator].HasDirt)
										rp_PrintToChat(client, "Votre plante n'as pas de terreau.");	
								
								int iID = GetEntProp(caller, Prop_Send, "m_nSkin");
								plant[activator].SetSeed(view_as<SeedType>(iID));
								plant[activator].HasSeed = true;
								rp_Sound(client, "sound_filldrug", 0.2);
								
								rp_PrintToChat(client, "Vous avez planter: %s{default}.", (iID) == 0 ? "{yellow}Lemon Haze":"{purple}StrawBerry");
								
								RemoveEdict(caller);
							}
						}
					}
				}
			}
		}
	}
}

int BuildCanabisModel(int client, char[] name)
{
	float TeleportOrigin[3], JoueurOrigin[3];
	GetClientAbsOrigin(client, JoueurOrigin);
	TeleportOrigin[0] = JoueurOrigin[0];
	TeleportOrigin[1] = JoueurOrigin[1];
	TeleportOrigin[2] = (JoueurOrigin[2]);
	JoueurOrigin[2] += 25.0;
	TeleportEntity(client, JoueurOrigin, NULL_VECTOR, NULL_VECTOR);
	
	char sTmp[128];
	rp_GetGlobalData("model_plant", STRING(sTmp));
	
	int ent = rp_CreatePhysics("", TeleportOrigin, NULL_VECTOR, sTmp, 0, true);
	plant[ent].owner = client;
	plant[ent].entity_index = ent;
	plant[ent].level = 0;
	plant[ent].water = 0;
	plant[ent].HasDirt = false;
	plant[ent].WaterTooMuchAttempt = 0;
				
	Entity_SetName(ent, name);
	CPrintToChat(client, "Votre plante n'as pas d'eau & pas de terreau.");
	
	return ent;
}

public Action Timer_PlantWeedGrow(Handle timer, any ent)
{
	if(IsValidEntity(ent))
	{
		if(plant[ent].water > 0.0)
		{
			if((plant[ent].level + 1) <= PLANT_MAXSTEP)
			{
				plant[ent].level++;
				rp_PrintToChat(plant[ent].owner, "[CANNABIS] Niveau amélioration: %i/%i", plant[ent].level, PLANT_MAXSTEP);
				plant[ent].water -= 8;
				if(plant[ent].water <= 0)
					plant[ent].water = 0;
				
				float position[3];
				Entity_GetAbsOrigin(ent, position);	
				
				if(plant[ent].type == LEMONHAZE)
					rp_CreateParticle(position, "sell_shine", 1.0);
				else
					rp_CreateParticle(position, "heal_shine", 1.0);				
				
				rp_CreateParticle(position, "smoke8", 1.0);
				
				char sLevel[2];
				IntToString(plant[ent].level, STRING(sLevel));
				SetBodyGroup(ent, GetEntityStudioHdr(ent).FindBodyPart(sLevel), 1);
				plant[ent].Timer_Grow = CreateTimer(cvars.weed_grow.FloatValue, Timer_PlantWeedGrow, ent);
			}	
			else
			{
				rp_PrintToChat(plant[ent].owner, "Votre plante est prête a être recoltée.");
				if(plant[ent].Timer_Grow != null)
					plant[ent].Timer_Grow = null;
			}
		}	
		else
		{
			rp_PrintToChat(plant[ent].owner, "Votre plante n'as plus d'eau, n'oubliez pas de l'arroser.");
			if(plant[ent].Timer_Grow != null)
				plant[ent].Timer_Grow = null;
		}
	}
	
	return Plugin_Handled;
}
	
public void RP_OnInventoryHandle(int client, int itemID)
{
	if(itemID == 136)
	{
		rp_SetClientStat(client, i_DrugPickedUp, rp_GetClientStat(client, i_DrugPickedUp) + 1);
		rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);	
			
		//rp_SetClientInt(client, i_countDrogue, rp_GetClientInt(client, i_countDrogue) + 1);
		rp_SetClientBool(client, b_HasJointEffect, true);	
		
		ScreenOverlay(client, "overlay_weed", 30.0);
		CreateTimer(30.0, CountDrogueMinus, client, TIMER_FLAG_NO_MAPCHANGE);
		
		TE_SetupBeamFollow(client, g_iBeamSpriteFollow, 0, 30.0, 5.0, 50.0, 3, g_iColorWeed);
		TE_SendToAll();
			
		rp_PrintToChat(client, "Vous avez consommer un joint de Lemon Haze.");
		PrintHintText(client, "VOUS ÊTES DEFONCÉ");	
	}
	else if(itemID == 137)
	{
		rp_SetClientStat(client, i_DrugPickedUp, rp_GetClientStat(client, i_DrugPickedUp) + 1);
		rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
			
		//rp_SetClientInt(client, i_countDrogue, rp_GetClientInt(client, i_countDrogue) + 1);
		rp_SetClientBool(client, b_HasShitEffect, true);
		
		ScreenOverlay(client, "overlay_weed", 30.0);
		CreateTimer(30.0, CountDrogueMinus, client, TIMER_FLAG_NO_MAPCHANGE);		
		
		TE_SetupBeamFollow(client, g_iBeamSpriteFollow, 0, 30.0, 5.0, 50.0, 3, g_iColorShit);
		TE_SendToAll();
		
		rp_PrintToChat(client, "Vous avez fumé un joint de shit.");
		PrintHintText(client, "VOUS ÊTES DEFONCÉ");
	}
	else if(itemID == 138)
	{
		if(!rp_GetClientBool(client, b_HasAmphetamineEffect) && rp_GetClientFloat(client, fl_Faim) != 100.0)
		{
			rp_SetClientStat(client, i_DrugPickedUp, rp_GetClientStat(client, i_DrugPickedUp) + 1);
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
				
			//rp_SetClientInt(client, i_countDrogue, rp_GetClientInt(client, i_countDrogue) + 1);
			rp_SetClientBool(client, b_HasAmphetamineEffect, true);
			
			ScreenOverlay(client, "overlay_weed", 30.0);
			CreateTimer(30.0, CountDrogueMinus, client, TIMER_FLAG_NO_MAPCHANGE);
			
			TE_SetupBeamFollow(client, g_iBeamSpriteFollow, 0, 30.0, 5.0, 50.0, 3, g_iColorAmphetamine);
			TE_SendToAll();
			
			rp_PrintToChat(client, "Vous avez consommé une dose de amphetamine.");
			PrintHintText(client, "VOUS ÊTES DEFONCÉ");
		}
		else
		{
			if(rp_GetClientBool(client, b_HasAmphetamineEffect))
				rp_PrintToChat(client, "Vous êtes déjà sous l'effet de la amphetamine.");
			else if(rp_GetClientFloat(client, fl_Faim) == 100.0)
				rp_PrintToChat(client, "Votre barre de faim est déjà au max.");	
		}	
	}
	else if(itemID == 139)
	{
		if(!rp_GetClientBool(client, b_HasHeroineEffect))
		{
			rp_SetClientStat(client, i_DrugPickedUp, rp_GetClientStat(client, i_DrugPickedUp) + 1);
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
			
			//rp_SetClientInt(client, i_countDrogue, rp_GetClientInt(client, i_countDrogue) + 1);
			rp_SetClientBool(client, b_HasHeroineEffect, true);
			
			ScreenOverlay(client, "overlay_heroine", 30.0);
			CreateTimer(30.0, CountDrogueMinus, client, TIMER_FLAG_NO_MAPCHANGE);
			
			TE_SetupBeamFollow(client, g_iBeamSpriteFollow, 0, 30.0, 5.0, 50.0, 3, g_iColorHeroine);
			TE_SendToAll();

			int vie = GetClientHealth(client);
			if(vie + 100 < 500)
				SetEntityHealth(client, vie + 100);
			else 
				SetEntityHealth(client, 500);
			
			PrintHintText(client, "VOUS ÊTES DEFONCÉ");
			rp_PrintToChat(client, "Vous avez consommé une dose d'héroïne.");
		}
		else
			rp_PrintToChat(client, "Vous êtes déjà sous l'effet de l'héroïne.");
	}
	else if(itemID == 140)
	{
		if(!rp_GetClientBool(client, b_HasCocainaEffect))
		{
			rp_SetClientStat(client, i_DrugPickedUp, rp_GetClientStat(client, i_DrugPickedUp) + 1);
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);			
			
			//rp_SetClientInt(client, i_countDrogue, rp_GetClientInt(client, i_countDrogue) + 1);
			rp_SetClientBool(client, b_HasCocainaEffect, true);
			
			int rand = GetRandomInt(1, 2);
			
			char sTmp[128];
			Format(STRING(sTmp), "sound_sniff0%i", rand);
			rp_Sound(client, sTmp, 1.0);
			
			ScreenOverlay(client, "overlay_cocaine", 30.0);
			CreateTimer(30.0, CountDrogueMinus, client, TIMER_FLAG_NO_MAPCHANGE);
			
			TE_SetupBeamFollow(client, g_iBeamSpriteFollow, 0, 30.0, 5.0, 50.0, 3, g_iColorCocaine);
			TE_SendToAll();
			
			int vie = GetClientHealth(client);
			if(vie + 50 < 500)
				SetEntityHealth(client, vie + 50);
			else 
				SetEntityHealth(client, 500);	
			
			PrintHintText(client, "VOUS ÊTES DEFONCÉ");
			rp_PrintToChat(client, "Vous avez consommé une dose de cocaïne.");
		}
		else
			rp_PrintToChat(client, "Vous êtes déjà sous l'effet de la cocaïne.");	
	}
	else if(itemID == 141)
	{
		if(!rp_GetClientBool(client, b_HasEcstasyEffect))
		{
			rp_SetClientStat(client, i_DrugPickedUp, rp_GetClientStat(client, i_DrugPickedUp) + 1);
			rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
			
		//	rp_SetClientInt(client, i_countDrogue, rp_GetClientInt(client, i_countDrogue) + 1);
			rp_SetClientBool(client, b_HasEcstasyEffect, true);
			
			ScreenOverlay(client, "overlay_ecstasy", 30.0);
			CreateTimer(30.0, CountDrogueMinus, client, TIMER_FLAG_NO_MAPCHANGE);
			
			TE_SetupBeamFollow(client, g_iBeamSpriteFollow, 0, 30.0, 5.0, 50.0, 3, g_iColorEcstazy);
			TE_SendToAll();
			
			int vie = GetClientHealth(client);
			if(vie + 50 < 500)
				SetEntityHealth(client, vie + 50);
			else 
				SetEntityHealth(client, 500);	
			
			rp_PrintToChat(client, "Vous avez consommé une dose d'ecstasy.");
		}
		else
			rp_PrintToChat(client, "Vous êtes déjà sous l'effet de l'ecstasy.");	
	}
	else if(itemID == 142)
	{
		if(iData[client].EntityPlant[0] == -1 || iData[client].EntityPlant[1] == -1)
		{
			if(IsOnGround(client))
			{
				rp_SetClientInt(client, i_Plante, rp_GetClientInt(client, i_Plante) + 1);
				rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
					
				char strFormat[128];
				if (iData[client].EntityPlant[0] == -1)
				{
					Format(STRING(strFormat), "%s|plante0", iData[client].SteamID);
					iData[client].EntityPlant[0] = BuildCanabisModel(client, strFormat);
				}
				else
				{
					Format(STRING(strFormat), "%s|plante1", iData[client].SteamID);
					iData[client].EntityPlant[1] = BuildCanabisModel(client, strFormat);
				}
	
				rp_PrintToChat(client, "Vous avez planté du cannabis.");
			}	
		}
		else
			rp_PrintToChat(client, "Vous avez atteint la limite de plantes.");	
	}
	else if(itemID == 181)
	{
		if(iData[client].EntityPlant[0] == -1 || iData[client].EntityPlant[1] == -1)
		{
			if(IsOnGround(client))
			{
				rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
					
				float TeleportOrigin[3], JoueurOrigin[3];
				GetClientAbsOrigin(client, JoueurOrigin);
				TeleportOrigin[0] = JoueurOrigin[0];
				TeleportOrigin[1] = JoueurOrigin[1];
				TeleportOrigin[2] = (JoueurOrigin[2]);
				
				char sModel[128];
				rp_GetGlobalData("model_dirtbag", STRING(sModel));
				
				int ent = rp_CreatePhysics("", TeleportOrigin, NULL_VECTOR, sModel, 0, true);
				rp_PrintToChat(client, "Vous avez déballer un sachet de terreau{default}.");
				rp_SetEntityOwner(ent, client);
				
				SetEntProp(ent, Prop_Send, "m_nSkin", 0);
				
				JoueurOrigin[2] += 35;
				TeleportEntity(client, JoueurOrigin, NULL_VECTOR, NULL_VECTOR);
			}	
		}
		else
			rp_PrintToChat(client, "Vous n'avez pas de plante.");
	}
	else if(itemID == 182)
	{
		if(iData[client].EntityPlant[0] != -1 || iData[client].EntityPlant[1] != -1 || rp_GetClientInt(client, i_Job) == JOBID)
		{
			if(IsOnGround(client))
			{
				rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
					
				float TeleportOrigin[3], JoueurOrigin[3];
				GetClientAbsOrigin(client, JoueurOrigin);
				TeleportOrigin[0] = JoueurOrigin[0];
				TeleportOrigin[1] = JoueurOrigin[1];
				TeleportOrigin[2] = (JoueurOrigin[2]);
				
				char sModel[128];
				rp_GetGlobalData("model_weedseed", STRING(sModel));
				
				int ent = rp_CreatePhysics("", TeleportOrigin, NULL_VECTOR, sModel, 0, true);
				rp_PrintToChat(client, "Vous avez spawn des graines {yellow}Lemon Haze{default}.");
				rp_SetEntityOwner(ent, client);
				
				SetEntProp(ent, Prop_Send, "m_nSkin", 0);
				
				JoueurOrigin[2] += 35;
				TeleportEntity(client, JoueurOrigin, NULL_VECTOR, NULL_VECTOR);
			}	
		}
		else
			rp_PrintToChat(client, "Vous n'avez pas de plante de cannabis.");
	}
	else if(itemID == 183)
	{
		if(iData[client].EntityPlant[0] != -1 || iData[client].EntityPlant[1] != -1 || rp_GetClientInt(client, i_Job) == JOBID)
		{
			if(IsOnGround(client))
			{
				rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);
					
				float TeleportOrigin[3], JoueurOrigin[3];
				GetClientAbsOrigin(client, JoueurOrigin);
				TeleportOrigin[0] = JoueurOrigin[0];
				TeleportOrigin[1] = JoueurOrigin[1];
				TeleportOrigin[2] = (JoueurOrigin[2]);
				
				char sModel[128];
				rp_GetGlobalData("model_weedseed", STRING(sModel));
				
				int ent = rp_CreatePhysics("", TeleportOrigin, NULL_VECTOR, sModel, 0, true);
				rp_PrintToChat(client, "Vous avez spawn des graines {lightpurple}Strawberry{default}.");
				rp_SetEntityOwner(ent, client);
				
				SetEntProp(ent, Prop_Send, "m_nSkin", 1);
				
				JoueurOrigin[2] += 35;
				TeleportEntity(client, JoueurOrigin, NULL_VECTOR, NULL_VECTOR);
			}	
		}
		else
			rp_PrintToChat(client, "Vous n'avez pas de plante de cannabis.");
	}
	if(itemID == 184)
	{
		rp_SetClientStat(client, i_DrugPickedUp, rp_GetClientStat(client, i_DrugPickedUp) + 1);
		rp_SetClientItem(client, itemID, rp_GetClientItem(client, itemID, false) - 1, false);	
			
		//rp_SetClientInt(client, i_countDrogue, rp_GetClientInt(client, i_countDrogue) + 1);
		rp_SetClientBool(client, b_HasJointEffect, true);	
		
		ScreenOverlay(client, "overlay_weed", 30.0);
		CreateTimer(30.0, CountDrogueMinus, client, TIMER_FLAG_NO_MAPCHANGE);
		
		TE_SetupBeamFollow(client, g_iBeamSpriteFollow, 0, 30.0, 5.0, 50.0, 3, g_iColorWeed);
		TE_SendToAll();

		rp_PrintToChat(client, "Vous avez consommer un joint de strawberry.");
		PrintHintText(client, "VOUS ÊTES DEFONCÉ");	
	}
}

public Action CountDrogueMinus(Handle timer, any client)
{
	if(IsClientValid(client))
	{
		if(IsPlayerAlive(client))
		{
			//rp_SetClientInt(client, i_countDrogue, rp_GetClientInt(client, i_countDrogue) - 1);
			ClientCommand(client, "r_screenoverlay 0");
		}
	}
	
	return Plugin_Handled;
}

void MenuDealer(int client)
{
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(DoMenuDealer);
	menu.SetTitle("Aperçu de votre stock :");
	
	char strText[32];
	Format(STRING(strText), "Plantes : %i", g_iPlantsCount);
	menu.AddItem("", strText, ITEMDRAW_DISABLED);
	
	menu.AddItem("", "----------------------------------", ITEMDRAW_DISABLED);
	
	Format(STRING(strText), "Lemon Haze : %ig", g_iGrammeCannabis[LEMONHAZE]);
	menu.AddItem("", strText, ITEMDRAW_DISABLED);
	menu.AddItem("lemonhaze", "Rouler un joint (1g - LemonHaze)");
	
	menu.AddItem("", "----------------------------------", ITEMDRAW_DISABLED);
	Format(STRING(strText), "Strawberry : %ig", g_iGrammeCannabis[STRAWBERRY]);
	menu.AddItem("", strText, ITEMDRAW_DISABLED);
	menu.AddItem("strawberry", "Rouler un joint (1g - Strawberry)");
	
	menu.AddItem("", "----------------------------------", ITEMDRAW_DISABLED);
	
	menu.AddItem("shit", "Céllophaner de la résine (2g)");
	
	menu.ExitBackButton = true;
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int DoMenuDealer(Menu menu, MenuAction action, int client, int param)
{
	if (action == MenuAction_Select)
	{
		char info[64];
		menu.GetItem(param, STRING(info));
		
		if (StrEqual(info, "lemonhaze"))
		{
			if (g_iGrammeCannabis[LEMONHAZE] >= 1)
			{
				rp_SetItemStock(136, rp_GetItemStock(136) + 1);
				g_iGrammeCannabis[LEMONHAZE]--;
				
				rp_PrintToChat(client, "Vous avez roulé un joint de {yellow}Lemon {green}Haze {default}avec {lightblue}1g{default}.");
				ShowPanel2(client, 2, "<font color='%s'>-</font>1g <font color='%s'>Lemon</font> <font color='%s'>Haze</font>", HTML_CRIMSON, HTML_FLUOYELLOW, HTML_CHARTREUSE);
			}
			else
				rp_PrintToChat(client, "Vous n'avez pas assez de cannabis pour rouler un joint.");
		}
		else if (StrEqual(info, "strawberry"))
		{
			if (g_iGrammeCannabis[STRAWBERRY] >= 1)
			{
				rp_SetItemStock(136, rp_GetItemStock(136) + 1); // FIX
				g_iGrammeCannabis[STRAWBERRY]--;
				
				rp_PrintToChat(client, "Vous avez roulé un joint de {purple}StrawBerry {default}avec {lightblue}1g{default}.");
				ShowPanel2(client, 2, "<font color='%s'>-</font>1g <font color='%s'>Strawberry</font>", HTML_CRIMSON, HTML_PINK);
			}
			else
				rp_PrintToChat(client, "Vous n'avez pas assez de cannabis pour rouler un joint.");
		}
		/*else if (StrEqual(info, "shit"))
		{
			if (g_iGrammeCannabis >= 2)
			{
				rp_SetItemStock(137, rp_GetItemStock(137) + 1);
				g_iGrammeCannabis -= 2;
				
				rp_PrintToChat(client, "Vous avez fait du shit avec le pollen contenu dans 2g.");
				PrintHintText(client, "-2g de cannabis.");
			}
			else
				rp_PrintToChat(client, "Vous n'avez pas assez de cannabis pour faire du shit.");
		}*/
		MenuDealer(client);
	}
	else if (action == MenuAction_Cancel)
	{
		if (param == MenuCancel_Exit || param == MenuCancel_ExitBack)
			rp_SetClientBool(client, b_DisplayHud, true);
	}
	else if (action == MenuAction_End)
		delete menu;
		
	return 0;
}

void MenuDJDealer(int client)
{
	if (IsClientValid(client))
	{
		if (rp_GetClientInt(client, i_Job) == JOBID)
		{
			rp_SetClientBool(client, b_DisplayHud, false);
			Menu menu = new Menu(Menu_DJ);
			menu.SetTitle("Que voulez - vous faire ? ");
			menu.AddItem("placer", "Placer la boule");
			menu.AddItem("retirer", "Retirer la boule");
			menu.AddItem("jouer", "Jouer de la musique");
			menu.AddItem("stop", "Stopper la musique");
			menu.Display(client, MENU_TIME_FOREVER);
			menu.ExitButton = true;
		}
	}
}

public int Menu_DJ(Menu menu, MenuAction action, int client, int param)
{
	if (action == MenuAction_Select)
	{
		char info[64];
		menu.GetItem(param, STRING(info));
		
		if (StrEqual(info, "jouer"))
		{
			Menu menu1 = new Menu(DoMusicMenu);
			
			menu1.SetTitle("- Playliste -");
			menu1.AddItem("mmz", "MMZ - Capuché");
			menu1.AddItem("hardbass", "HardBass");
			menu1.Display(client, 0);
			menu1.ExitButton = true;
		}
		else if (StrEqual(info, "placer"))
		{
			if (0 >= RP_GetClientCountDiscoball(client))
			{
				CreateDisco(client);
			}
		}
		else if (StrEqual(info, "retirer"))
		{
			int i = 1;
			while (GetMaxEntities() >= i)
			{			
				if (IsValidEdict(i) && IsValidEntity(i))
				{
					char sName[64];
					GetEntPropString(i, view_as<PropType>(1), "m_iName", sName, 64, 0);
					char sExplode[2][64];
					ExplodeString(sName, "-", sExplode, 2, 64, false);
					
					if (StrEqual(sExplode[0], "discoball", true) && StringToInt(sExplode[1], 10) == GetClientUserId(client))
					{
						RemoveEdict(i);
					}
				}
				i++;
			}
		}
	}
	else if (action == MenuAction_Cancel)
	{
		if (param == MenuCancel_Exit || param == MenuCancel_ExitBack)
			rp_SetClientBool(client, b_DisplayHud, true);
	}
	else if (action == MenuAction_End)
		delete menu;
		
	return 0;
}

public int DoMusicMenu(Menu menu, MenuAction action, int client, int param)
{
	if (action == MenuAction_Select)
	{
		char info[32];
		menu.GetItem(param, STRING(info));
		
		if (StrEqual(info, "mmz", true))
		{
			PrecacheSound("roleplay/dj/mmz.mp3");
			EmitSoundToAll("roleplay/dj/mmz.mp3", client, _, _, _, 1.0);
		}
		else if (StrEqual(info, "hardbass", true))
		{
			PrecacheSound("roleplay/dj/hardbass.mp3");
			EmitSoundToAll("roleplay/dj/hardbass.mp3", client, _, _, _, 1.0);
		}
		//rp_PrintToChat("Le DJ %N nous joue un son !", client);
	}
	else if (action == MenuAction_Cancel)
	{
		if (param == MenuCancel_Exit || param == MenuCancel_ExitBack)
			rp_SetClientBool(client, b_DisplayHud, true);
	}
	else if (action == MenuAction_End)
		delete menu;
		
	return 0;
}

void CreateDisco(int client)
{
	float fAim[3] = {0.0, ...};
	float fClient[3] = {0.0, ...};
	GetAimOrigin(client, fAim);
	GetClientAbsOrigin(client, fClient);
	if (GetVectorDistance(fClient, fAim, false) <= 500)
	{
		int ball = CreateEntityByName("prop_dynamic_override", -1);
		char sName[64];
		Format(sName, 64, "discoball- %i", GetClientUserId(client));
		SetEntPropString(ball, view_as<PropType>(1), "m_iName", sName, 0);
		if (!IsModelPrecached("models/props/slow/spiegelkugel/slow_spiegelkugel.mdl"))
		{
			PrecacheModel("models/props/slow/spiegelkugel/slow_spiegelkugel.mdl", false);
		}
		SetEntityModel(ball, "models/props/slow/spiegelkugel/slow_spiegelkugel.mdl");
		DispatchKeyValue(ball, "solid", "0");
		DispatchSpawn(ball);
		TeleportEntity(ball, fAim, NULL_VECTOR, NULL_VECTOR);
		CreateTimer(0.1, Timer_DiscoUpdate, ball, 1);
	}
	else
	{
		rp_PrintToChat(client, "La boule est trop loin.");
	}
}

public Action Timer_DiscoUpdate(Handle timer, any ball)
{
	if (IsValidEdict(ball) && IsValidEntity(ball))
	{
		float fPropAngle[3] = {0.0, ...};
		GetEntPropVector(ball, view_as<PropType>(1), "m_angRotation", fPropAngle, 0);
		fPropAngle[0] = fPropAngle[0] + g_fDiscoRotation[0];
		fPropAngle[1] += g_fDiscoRotation[1];
		fPropAngle[2] += g_fDiscoRotation[2];
		TeleportEntity(ball, NULL_VECTOR, fPropAngle, NULL_VECTOR);
		float fPos[3] = {0.0, ...};
		float END[3] = {0.0, ...};
		GetEntPropVector(ball, view_as<PropType>(0), "m_vecOrigin", fPos, 0);
		TE_SetupGlowSprite(fPos, g_iGlow, 0.1, 2.0, 255);
		TE_SendToAll(0.0);
		int iColor[4] =  { 0, 0, 0, 255 };
		float fNewAngles[3] = {0.0, ...};
		int i;
		while (i <= 5)
		{
			fNewAngles[0] = GetRandomFloat(0.0, 90.0);
			fNewAngles[1] = GetRandomFloat(-180.0, 180.0);
			fNewAngles[2] = 0.0;
			Handle hTrace = TR_TraceRayFilterEx(fPos, fNewAngles, 1174421507, view_as<RayType>(1), TraceEntityFilterPlayer, view_as<any>(0));
			if (TR_DidHit(hTrace))
			{
				TR_GetEndPosition(END, hTrace);
				iColor[0] = g_iDefaultColors_c[i][0];
				iColor[1] = g_iDefaultColors_c[i][1];
				iColor[2] = g_iDefaultColors_c[i][2];
				LaserP(fPos, END, iColor);
			}
			CloseHandle(hTrace);
			i++;
		}
	}
	else
		KillTimer(timer, false);
	
	return Plugin_Handled;
}

public void LaserP(float start[3], float end[3], int color[4])
{
	TE_SetupBeamPoints(start, end, g_iBeamSpriteFollow, 0, 0, 0, 0.1, 3.0, 3.0, 7, 0.0, color, 0);
	TE_SendToAll(0.0);
}

public void GetAimOrigin(int client, float hOrigin[3])
{
	float vAngles[3] = {0.0, ...};
	float fOrigin[3] = {0.0, ...};
	GetClientEyePosition(client, fOrigin);
	GetClientEyeAngles(client, vAngles);
	Handle trace = TR_TraceRayFilterEx(fOrigin, vAngles, 1174421507, view_as<RayType>(1), TraceEntityFilterPlayer, view_as<any>(0));
	if (TR_DidHit(trace))
	{
		TR_GetEndPosition(hOrigin, trace);
		CloseHandle(trace);
	}
	else
	{
		CloseHandle(trace);
	}
}

public int RP_GetClientCountDiscoball(int client)
{
	int iCount;
	int i = 1;
	while (GetMaxEntities() >= i)
	{
		if (IsValidEdict(i) && IsValidEntity(i))
		{
			char sName[64];
			GetEntPropString(i, view_as<PropType>(1), "m_iName", sName, 64, 0);
			char sExplode[2][64];
			ExplodeString(sName, "-", sExplode, 2, 64, false);
			if (StrEqual(sExplode[0], "discoball", true) && GetClientUserId(client) == StringToInt(sExplode[1], 10))
			{
				iCount++;
			}
		}
		i++;
	}
	return iCount;
}

void MenuStove(int client, int target)
{
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_MenuStove);
	menu.SetTitle("Cuisinière à gaz");
	
	char tmp[32], strIndex[32];
	for(int i = 1; i <= 4; i++)
	{
		char DrugName[32];
		stove[target].GetPlateDrugName(i, STRING(DrugName));
		
		Format(STRING(strIndex), "%i|%i", target, i);
		Format(STRING(tmp), "Feu №%i", i);
		Format(STRING(tmp), "%s (%s)", tmp, DrugName);
		menu.AddItem(strIndex, tmp);
	}	
	
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Handle_MenuStove(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[64], buffer[2][64];
		menu.GetItem(param, STRING(info));
		ExplodeString(info, "|", STRING(buffer), sizeof(buffer[]));
		
		int entity = StringToInt(buffer[0]);
		int plate = StringToInt(buffer[1]);
		
		MenuPlate(client, entity, plate);
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit || param == MenuCancel_ExitBack)
			rp_SetClientBool(client, b_DisplayHud, true);
	}
	else if(action == MenuAction_End)
	{
		delete menu;
		rp_SetClientBool(client, b_DisplayHud, true);
	}
	
	return 0;
}

void MenuPlate(int client, int entity, int plate)
{
	Menu menu1 = new Menu(Handle_MenuPlate);
	menu1.SetTitle("Cuisinière - Feu №%i", plate);
	
	char tmp[32], strIndex[32], DrugName[32];
	
	stove[entity].GetPlateDrugName(plate, STRING(DrugName));
	
	Format(STRING(tmp), "Recette: %s", DrugName);
	Format(STRING(strIndex), "%i|%i|type", entity, plate);
	menu1.AddItem(strIndex, tmp, (stove[entity].IsPlateAvailable(plate)) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

	if(stove[entity].GazLevel != 0.0)
	{
		Format(STRING(strIndex), "%i|%i|fire", entity, plate);
		if(stove[entity].GetPlateFireLevel(plate) == 0)
			Format(STRING(tmp), "Niveau du feu: Etteint");
		else if(stove[entity].GetPlateFireLevel(plate) == 1)
			Format(STRING(tmp), "Niveau du feu: Petit");	
		else if(stove[entity].GetPlateFireLevel(plate) == 2)
			Format(STRING(tmp), "Niveau du feu: Grand");	
		menu1.AddItem(strIndex, tmp);	
	}	
	else
	{
		Format(STRING(tmp), "Niveau du feu: PAS DE GAZ");
		menu1.AddItem("", tmp, ITEMDRAW_DISABLED);			
	}
	
	if(!stove[entity].HasGas[0] && !stove[entity].HasGas[1])
		Format(STRING(tmp), "Gaz: 0");
	else if(stove[entity].HasGas[0] && !stove[entity].HasGas[1])
		Format(STRING(tmp), "Gaz: 1");
	else if(stove[entity].HasGas[0] && stove[entity].HasGas[1])
		Format(STRING(tmp), "Gaz: 2");
		
	if(stove[entity].GazLevel > 0.0)
		Format(STRING(tmp), "%s (%0.1f Bar)", tmp, stove[entity].GazLevel);
	
	menu1.AddItem("", tmp, ITEMDRAW_DISABLED);
	
	Format(STRING(strIndex), "%i|%i|ingredients", entity, plate);
	menu1.AddItem(strIndex, "Ingrédients");
	
	Format(STRING(strIndex), "%i|%i|start", entity, plate);
	if(stove[entity].IsPlateAvailable(plate))
		menu1.AddItem(strIndex, "Lancer la cuisson");
	else
	{
		Format(STRING(tmp), "%i/120", stove[entity].cooldown[plate]);
		menu1.AddItem("", tmp, ITEMDRAW_DISABLED);
	}	
		
	menu1.ExitButton = true;
	menu1.Display(client, MENU_TIME_FOREVER);
}

public int Handle_MenuPlate(Menu menu, MenuAction action, int client, int param)
{
	char info[64], buffer[3][64];
	menu.GetItem(param, STRING(info));
	ExplodeString(info, "|", STRING(buffer), sizeof(buffer[]));
	
	int entity = StringToInt(buffer[0]);
	int plate = StringToInt(buffer[1]);
	
	if(action == MenuAction_Select)
	{
		char strIndex[32];
		
		if(StrEqual(buffer[2], "type"))
		{
			rp_SetClientBool(client, b_DisplayHud, false);
			Menu menu1 = new Menu(Handle_MenuPlateType);
			menu1.SetTitle("Cuisinière à gaz [TYPE]");
			
			Format(STRING(strIndex), "%i|%i|1", entity, plate);
			menu1.AddItem(strIndex, "Cocaïne");
			
			Format(STRING(strIndex), "%i|%i|2", entity, plate);
			menu1.AddItem(strIndex, "Amphetamïne");
			
			Format(STRING(strIndex), "%i|%i|3", entity, plate);
			menu1.AddItem(strIndex, "Heroïne");
			
			Format(STRING(strIndex), "%i|%i|4", entity, plate);
			menu1.AddItem(strIndex, "Ecstasy");
			
			menu1.ExitBackButton = true;
			menu1.ExitButton = true;
			menu1.Display(client, MENU_TIME_FOREVER);
		}
		else if(StrEqual(buffer[2], "fire"))
		{
			if(stove[entity].GetPlateFireLevel(plate) == 0)
				stove[entity].SetPlateFireLevel(plate, 1);
			else if(stove[entity].GetPlateFireLevel(plate) == 1)
				stove[entity].SetPlateFireLevel(plate, 2);	
			else if(stove[entity].GetPlateFireLevel(plate) == 2)
				stove[entity].SetPlateFireLevel(plate, 0);
				
			MenuPlate(client, entity, plate);
		}
		else if(StrEqual(buffer[2], "ingredients"))
			MenuPlateIngredients(client, entity, plate);
		else if(StrEqual(buffer[2], "start"))
		{
			if(stove[entity].GetPlateDrugType(plate) == NONE)
				rp_PrintToChat(client, "Vous devez choisir une drogue à préparer avant de lancer la cuisson.");
			else if(stove[entity].GetPlateFireLevel(plate) == 0)
				rp_PrintToChat(client, "Vous devez allumer le feu.");
			else if(!stove[entity].HasMaxIngredients(plate))
				rp_PrintToChat(client, "La cuisson ne possède pas assez d'ingrédients.");
			else
			{
				stove[entity].SetPlateTemperatureEnt(plate, true);
				stove[entity].reservedplate[plate] = true;
				rp_PrintToChat(client, "La cuisson a commencer, n'oubliez pas de couper le feu quand c'est finit.");
			}			
			
			MenuPlate(client, entity, plate);
		}	
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if(param == MenuCancel_ExitBack)	
			MenuStove(client, entity);
	}
	else if(action == MenuAction_End)
	{
		delete menu;
		rp_SetClientBool(client, b_DisplayHud, true);
	}
	
	return 0;
}

public int Handle_MenuPlateType(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[64], buffer[3][64];
		menu.GetItem(param, STRING(info));
		ExplodeString(info, "|", STRING(buffer), sizeof(buffer[]));
		
		int entity = StringToInt(buffer[0]);
		int plate = StringToInt(buffer[1]);
		int type = StringToInt(buffer[2]);
		
		stove[entity].drug[plate] = view_as<drug_type>(type);
		stove[entity].SetPlatePot(plate, true);
		MenuPlate(client, entity, plate);
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if(param == MenuCancel_ExitBack)
			MenuStove(client, iData[client].StoveActivMenu);		
	}
	else if(action == MenuAction_End)
	{
		delete menu;
		rp_SetClientBool(client, b_DisplayHud, true);
	}

	return 0;
}

void MenuPlateIngredients(int client, int entity, int plate)
{
	Menu menu1 = new Menu(Handle_MenuPlateIngredients);
	menu1.SetTitle("Feu №%i\nIngrédients", plate);
	
	char tmp[32];
	
	Format(STRING(tmp), "Acetone: %i/%i", stove[entity].acetone[plate], stove[entity].GetMaxAcetone(plate));
	menu1.AddItem("", tmp, ITEMDRAW_DISABLED);
	
	Format(STRING(tmp), "Amoniaque: %i/%i", stove[entity].amoniaque[plate], stove[entity].GetMaxAmoniaque(plate));
	menu1.AddItem("", tmp, ITEMDRAW_DISABLED);
	
	Format(STRING(tmp), "Bismuth: %i/%i", stove[entity].bismuth[plate], stove[entity].GetMaxBismuth(plate));
	menu1.AddItem("", tmp, ITEMDRAW_DISABLED);
	
	Format(STRING(tmp), "Acide Phosphorique : %i/%i", stove[entity].acidphosphorique[plate], stove[entity].GetMaxPhosphore(plate));
	menu1.AddItem("", tmp, ITEMDRAW_DISABLED);
	
	Format(STRING(tmp), "Acide Sulfurique : %i/%i", stove[entity].acidsulfurique[plate], stove[entity].GetMaxSulfurique(plate));
	menu1.AddItem("", tmp, ITEMDRAW_DISABLED);
	
	Format(STRING(tmp), "Sodium : %i/%i", stove[entity].sodium[plate], stove[entity].GetMaxSodium(plate));
	menu1.AddItem("", tmp, ITEMDRAW_DISABLED);
	
	Format(STRING(tmp), "Toulenne : %i/%i", stove[entity].toulene[plate], stove[entity].GetMaxToulene(plate));
	menu1.AddItem("", tmp, ITEMDRAW_DISABLED);
	
	Format(STRING(tmp), "Eau : %i/%i", stove[entity].water[plate], stove[entity].GetMaxWater(plate));
	menu1.AddItem("", tmp, ITEMDRAW_DISABLED);
		
	menu1.ExitBackButton = true;
	menu1.ExitButton = true;
	menu1.Display(client, MENU_TIME_FOREVER);
}

public int Handle_MenuPlateIngredients(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit)
			rp_SetClientBool(client, b_DisplayHud, true);
		else if(param == MenuCancel_ExitBack)
			MenuStove(client, iData[client].StoveActivMenu);
	}
	else if(action == MenuAction_End)
	{
		delete menu;
		rp_SetClientBool(client, b_DisplayHud, true);
	}
	
	return 0;
}

public void RP_OnClientFire(int client, int target, const char[] weapon)
{
	if(IsValidEntity(target))
	{
		if (!StrEqual(weapon, "weapon_fists"))
		{
			float reduce = GetRandomFloat(2.0, 25.0);
			
			if(rp_GetEntityHealth(target) > 0.0 && rp_GetEntityHealth(target ) - reduce > 0.1)
			{
				rp_SetEntityHealth(target, rp_GetEntityHealth(target) - reduce);
				rp_DisplayHealth(client, target, 0.0, 0, true);
			}	
			else	
			{
				if (IsEntityModelInArray(target, "model_acetone") || IsEntityModelInArray(target, "model_ammoniac")
				|| IsEntityModelInArray(target, "model_bismuth") || IsEntityModelInArray(target, "model_phosphore")
				|| IsEntityModelInArray(target, "model_sulfuric") || IsEntityModelInArray(target, "model_sodium")
				|| IsEntityModelInArray(target, "model_toulene") || IsEntityModelInArray(target, "model_gasstove"))
				{
					RemoveEdict(target);
			
					int number = GetRandomInt(1, 9);
					
					char sound[128];
					Format(STRING(sound), "roleplay/claymore/ex%i.mp3", number);
					
					float position[3];
					GetEntPropVector(target, Prop_Send, "m_vecOrigin", position);
					rp_CreateParticle(position, "explosion_hegrenade_dirt", 10.0);
					
					rp_PrintToChat(client, "Vous avez détruit du materiel !");
					
					LoopClients(i)
					{
						if(!IsClientValid(i))
							continue;
						
						if(Distance(target, i) <= 120)
						{
							ForcePlayerSuicide(i);
							rp_PrintToChat(i, "Vous avez été tuée par une explosion !");
							rp_Sound(i, sound, 1.0);
						}
						else if(Distance(target, i) > 120 && Distance(target, i) <= 200)
						{
							int minusHealth = GetRandomInt(20, 50);
							
							if(GetClientHealth(i) <= minusHealth)
								ForcePlayerSuicide(i);
							
							SetEntityHealth(i, GetClientHealth(i) - minusHealth);
							rp_PrintToChat(i, "Vous avez été bléssé par une explosion !");
							rp_Sound(i, sound, 0.5);
						}
					}
				}
				else if(IsEntityModelInArray(target, "model_battery"))
				{
					rp_PrintToChat(client, "Vous avez détruit une batterie lithium !");
					RemoveEdict(target);
					
					LoopClients(i)
					{
						if(!IsClientValid(i))
							continue;
						
						if(Distance(target, i) <= 200)
						{
							float position[3];
							GetEntPropVector(target, Prop_Send, "m_vecOrigin", position);
							rp_CreateFire(position, 5.0);
							
							rp_PrintToChat(i, "Vous été tuée par une explosion !");
							//rp_Sound(i, sound, 1.0);
						}	
						else if(Distance(target, i) >= 200 && Distance(target, i) <= 300)
						{
							int minusHealth = GetRandomInt(20, 50);
							
							if(GetClientHealth(i) <= minusHealth)
								ForcePlayerSuicide(i);
							
							SetEntityHealth(i, GetClientHealth(i) - minusHealth);
							rp_PrintToChat(i, "Vous été bléssé par une explosion !");
							//rp_Sound(i, sound, 0.5);
						}
					}
				}
				else if(IsEntityModelInArray(target, "model_water"))
				{
					rp_PrintToChat(client, "Vous avez troué un bidon d'eau !");
					RemoveEdict(target);
					
					float position[3];
					GetEntPropVector(target, Prop_Send, "m_vecOrigin", position);
					rp_CreateParticle(position, "bubble", 2.0);
				}
			}	
		}	
	}	
}

public void RP_OnLookAtTarget(int client, int target, char[] model)
{
	if(!IsValidEntity(target))
		return;
	
	if(IsEntityModelInArray(target, "model_plant"))
	{
		if(plant[target].owner == client)
			PrintHintText(client, "<font color='%s'>★</font><font color='%s'>𝙋𝙡𝙖𝙣𝙩𝙚 𝙙𝙚 𝙘𝙖𝙣𝙣𝙖𝙗𝙞𝙨</font><font color='%s'>★</font>\nEau: <font color='%s'>%iL</font>\nVie: <font color='%s'>%0.1f</font>", HTML_CRIMSON, HTML_FLUOYELLOW, HTML_CRIMSON, HTML_BLUE, plant[target].water, HTML_CHARTREUSE, rp_GetEntityHealth(target));
		else
			PrintHintText(client, "<font color='%s'>★</font><font color='%s'>𝙋𝙡𝙖𝙣𝙩𝙚 𝙙𝙚 𝙘𝙖𝙣𝙣𝙖𝙗𝙞𝙨</font><font color='%s'>★</font>\nProps de: <font color='%s'>%N</font>\nVie: <font color='%s'>%0.1f</font>", HTML_CRIMSON, HTML_FLUOYELLOW, HTML_CRIMSON, HTML_TURQUOISE, plant[target].owner, HTML_CHARTREUSE, rp_GetEntityHealth(target));		
	}	
	else if(IsEntityModelInArray(target, "model_gasstove"))
		if(stove[target].owner == client)
			PrintHintText(client, "<font color='%s'>★</font><font color='%s'>𝘾𝙪𝙞𝙨𝙞𝙣𝙞𝙚𝙧𝙚 𝙖 𝙜𝙖𝙯</font><font color='%s'>★</font>\nVie: <font color='%s'>%0.1f</font>", HTML_CRIMSON, HTML_FLUOYELLOW, HTML_CRIMSON, HTML_CHARTREUSE, rp_GetEntityHealth(target));
		else
			PrintHintText(client, "<font color='%s'>★</font><font color='%s'>𝘾𝙪𝙞𝙨𝙞𝙣𝙞𝙚𝙧𝙚 𝙖 𝙜𝙖𝙯</font><font color='%s'>★</font>\nVie: <font color='%s'>%0.1f</font>\nProps de: <font color='%s'>%N</font>", HTML_CRIMSON, HTML_FLUOYELLOW, HTML_CRIMSON, HTML_CHARTREUSE, rp_GetEntityHealth(target), stove[target].owner);
	else if(IsEntityModelInArray(target, "model_dirtbag"))
		PrintHintText(client, "<font color='%s'>★</font><font color='%s'>𝙏𝙚𝙧𝙧𝙚𝙖𝙪</font><font color='%s'>★</font>\nVie: <font color='%s'>%0.1f</font>\nProps de: <font color='%s'>%N</font>", HTML_CRIMSON, HTML_FLUOYELLOW, HTML_CRIMSON, HTML_CHARTREUSE, rp_GetEntityHealth(target), rp_GetEntityOwner(target));
}

void MenuSelectPlateForIncrease(int client, int entity, const char[] type)
{
	rp_SetClientBool(client, b_DisplayHud, false);
	Menu menu = new Menu(Handle_MenuSelectPlateForIncrease);
	menu.SetTitle("Choisissez la plaque pour ajouter l'ingrédient");
	
	bool pass[5] = {false, ...};
	char strIndex[256], tmp[64], DrugName[32];
	for(int i = 1; i <= 4; i++)
	{
		stove[entity].GetPlateDrugName(i, STRING(DrugName));
		Format(STRING(strIndex), "%i|%i|%s", entity, i, type);
		Format(STRING(tmp), "Feu №%i", i);
		if(!stove[entity].IsPlateAvailable(i))
			Format(STRING(tmp), "%s (%s)", tmp, DrugName);
		
		if(StrEqual(type, "water"))
		{
			if(!stove[entity].HasMaxWater(i))
				pass[i] = true;
		}
		else if(StrEqual(type, "acetone"))
		{
			if(!stove[entity].HasMaxAcetone(i))
				pass[i] = true;
		}	
		else if(StrEqual(type, "ammoniac"))
		{
			if(!stove[entity].HasMaxAmoniaque(i))
				pass[i] = true;
		}	
		else if(StrEqual(type, "bismuth"))
		{
			if(!stove[entity].HasMaxBismuth(i))
				pass[i] = true;
		}	
		else if(StrEqual(type, "phosphore"))
		{
			if(!stove[entity].HasMaxPhosphore(i))
				pass[i] = true;
		}
		else if(StrEqual(type, "sulfuric"))
		{
			if(!stove[entity].HasMaxSulfurique(i))
				pass[i] = true;
		}
		else if(StrEqual(type, "sodium"))
		{
			if(!stove[entity].HasMaxSodium(i))
				pass[i] = true;
		}
		else if(StrEqual(type, "toulene"))
		{
			if(!stove[entity].HasMaxToulene(i))
				pass[i] = true;
		}	
		
		menu.AddItem(strIndex, tmp, (pass[i])? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	}
	
	menu.ExitButton = false;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Handle_MenuSelectPlateForIncrease(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		char info[256], buffer[3][256];
		menu.GetItem(param, STRING(info));
		ExplodeString(info, "|", STRING(buffer), sizeof(buffer[]));
		
		int entity = StringToInt(buffer[0]);
		int plate = StringToInt(buffer[1]);
		
		if(StrEqual(buffer[2], "water"))
		{
			rp_Sound(client, "sound_filldrug", 0.2);
			float position[3];
			GetEntPropVector(entity, Prop_Send, "m_vecOrigin", position);
			rp_CreateParticle(position, "ambient_sparks", 1.0);
			stove[entity].IncreaseWater(plate);							
		}
		else if(StrEqual(buffer[2], "acetone"))
		{
			rp_Sound(client, "sound_filldrug", 0.2);
			float position[3];
			GetEntPropVector(entity, Prop_Send, "m_vecOrigin", position);
			rp_CreateParticle(position, "ambient_sparks", 1.0);
			stove[entity].IncreaseAcetone(plate);							
		}
		else if(StrEqual(buffer[2], "ammoniac"))
		{
			rp_Sound(client, "sound_filldrug", 0.2);
			float position[3];
			GetEntPropVector(entity, Prop_Send, "m_vecOrigin", position);
			rp_CreateParticle(position, "ambient_sparks", 1.0);
			stove[entity].IncreaseAmoniaque(plate);							
		}
		else if(StrEqual(buffer[2], "bismuth"))
		{
			rp_Sound(client, "sound_filldrug", 0.2);
			float position[3];
			GetEntPropVector(entity, Prop_Send, "m_vecOrigin", position);
			rp_CreateParticle(position, "ambient_sparks", 1.0);
			stove[entity].IncreaseBismuth(plate);							
		}
		else if(StrEqual(buffer[2], "phosphore"))
		{
			rp_Sound(client, "sound_filldrug", 0.2);
			float position[3];
			GetEntPropVector(entity, Prop_Send, "m_vecOrigin", position);
			rp_CreateParticle(position, "ambient_sparks", 1.0);
			stove[entity].IncreasePhosphore(plate);							
		}
		else if(StrEqual(buffer[2], "sulfuric"))
		{
			rp_Sound(client, "sound_filldrug", 0.2);
			float position[3];
			GetEntPropVector(entity, Prop_Send, "m_vecOrigin", position);
			rp_CreateParticle(position, "ambient_sparks", 1.0);
			stove[entity].IncreaseSulfurique(plate);							
		}
		else if(StrEqual(buffer[2], "sodium"))
		{
			rp_Sound(client, "sound_filldrug", 0.2);
			float position[3];
			GetEntPropVector(entity, Prop_Send, "m_vecOrigin", position);
			rp_CreateParticle(position, "ambient_sparks", 1.0);
			stove[entity].IncreaseSodium(plate);							
		}
		else if(StrEqual(buffer[2], "toulene"))
		{
			rp_Sound(client, "sound_filldrug", 0.2);
			float position[3];
			GetEntPropVector(entity, Prop_Send, "m_vecOrigin", position);
			rp_CreateParticle(position, "ambient_sparks", 1.0);
			stove[entity].IncreaseToulene(plate);							
		}
		MenuPlate(client, entity, plate);
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit || param == MenuCancel_ExitBack)
			rp_SetClientBool(client, b_DisplayHud, true);
	}
	else if(action == MenuAction_End)
	{
		delete menu;
		rp_SetClientBool(client, b_DisplayHud, true);
	}	
	
	return 0;
}

public void RP_EntityTimerEverySecond(int entity)
{
	if(rp_IsValidGasStove(entity))
	{
		if(stove[entity].GazLevel > 0.0)
		{
			for(int i = 1; i <= 4; i++)
			{
				if(stove[entity].GetPlateFireLevel(i) == 1)
					stove[entity].GazLevel -= 0.2;
				else if(stove[entity].GetPlateFireLevel(i) == 2)
					stove[entity].GazLevel -= 0.4;
					
				if(stove[entity].GetPlateFireLevel(i) != 0)
				{
					if(stove[entity].GazLevel >= 40.0 && stove[entity].GazLevel <= 50.0)
					{
						stove[entity].HasGas[1] = false;
						stove[entity].RemoveGas();
					}	
					else if(stove[entity].GazLevel <= 0.1)
					{
						stove[entity].GazLevel = 0.0;
						stove[entity].HasGas[0] = false;
						stove[entity].RemoveGas();
						rp_PrintToChat(stove[entity].owner, "Votre cuisinère à gaz n'a plus de gaz, veuillez l'a ravitailler.");
					}
	
					if(!stove[entity].IsPlateAvailable(i) && stove[entity].GazLevel > 0.0)
					{
						if(stove[entity].GetPlateFireLevel(i) == 1)
							stove[entity].cooldown[i] += 1;
						else if(stove[entity].GetPlateFireLevel(i) == 2)
							stove[entity].cooldown[i] += 2; 
							
						/*char temp[32]; FIX prop_physics doesn't accept Pose TODO
						Format(STRING(temp), "thermometer_%i", i);
						SetPoseParameterByName(entity, temp, vfloat(stove[entity].cooldown[i]));*/
						
						if(stove[entity].cooldown[i] >= 120)
						{
							//ResetPoseParameters(entity);
							
							char attach[32];
							Format(STRING(attach), "cooker_pos_%i", i);
							UTIL_CreateSmoke(entity, NULL_VECTOR, NULL_VECTOR, attach, "2", "2", "10", "20", "5", _, _, _, "255 255 255", "200", "particle/smokesprites_0001.vmt", 5.0, 5.0);
							
							float TeleportOrigin[3];
							Entity_GetAbsOrigin(entity, TeleportOrigin);
							
							int random = GetRandomInt(cvars.min_drugproduce.IntValue, cvars.max_drugproduce.IntValue);
							
							switch(stove[entity].GetPlateDrugType(i))
							{
								case COCAINE:rp_SetItemStock(140, rp_GetItemStock(140) + random);
								case AMPHETAMINE:rp_SetItemStock(138, rp_GetItemStock(138) + random);
								case HEROINE:rp_SetItemStock(139, rp_GetItemStock(139) + random);
								case ECSTASY:rp_SetItemStock(141, rp_GetItemStock(141) + random);		
							}
							
							char DrugName[32];
							stove[entity].GetPlateDrugName(i, STRING(DrugName));
							
							rp_PrintToChat(stove[entity].owner, "Vous avez produit: {green}%i {lightred}%s{default}.", random, DrugName);
							
							stove[entity].Reset(i);
							
							//int ent = rp_CreatePhysics("", TeleportOrigin, NULL_VECTOR, MODEL_COCAINEBOX, 0, false);
							//box[ent].SetContent(stove[entity].drug[i], true);
						}	
					}
				}	
			}		
		}	
	}		
}