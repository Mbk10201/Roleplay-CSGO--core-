methodmap Roleplay
{
	public Roleplay(int client)
	{
		if (!IsClientValid(client))
			return view_as<Roleplay>(-1);
		
		return view_as<Roleplay>(client);
	}
	
	// int
	property int client
	{
		public get()
		{
			return view_as<int>(this);
		}
	}
	
	property int Money
	{
		public get()
		{
			return rp_GetClientInt(this.client, i_Money);
		}
		public set(int value)
		{
			rp_SetClientInt(this.client, i_Money, value);
		}
	}
	
	property int Bank
	{
		public get()
		{
			return rp_GetClientInt(this.client, i_Bank);
		}
		public set(int value)
		{
			rp_SetClientInt(this.client, i_Bank, value);
		}
	}
	
	property int JobID
	{
		public get()
		{
			return rp_GetClientInt(this.client, i_Job);
		}
		public set(int value)
		{
			rp_SetClientInt(this.client, i_Job, value);
		}
	}
	
	property int GradeID
	{
		public get()
		{
			return rp_GetClientInt(this.client, i_Grade);
		}
		public set(int value)
		{
			rp_SetClientInt(this.client, i_Grade, value);
		}
	}
	
	property int Salary
	{
		public get()
		{
			return rp_GetClientInt(this.client, i_Salary);
		}
		public set(int value)
		{
			rp_SetClientInt(this.client, i_Salary, value);
		}
	}
	
	property int GroupID
	{
		public get()
		{
			return rp_GetClientInt(this.client, i_Group);
		}
		public set(int value)
		{
			rp_SetClientInt(this.client, i_Group, value);
		}
	}
	
	property int RankID
	{
		public get()
		{
			return rp_GetClientInt(this.client, i_Rank);
		}
		public set(int value)
		{
			rp_SetClientInt(this.client, i_Rank, value);
		}
	}
	
	property int TrashCount
	{
		public get()
		{
			return rp_GetClientInt(this.client, i_Trash);
		}
		public set(int value)
		{
			rp_SetClientInt(this.client, i_Trash, value);
		}
	}
	
	property int MaxHealth
	{
		public get()
		{
			return rp_GetClientInt(this.client, i_MaxHealth);
		}
		public set(int value)
		{
			rp_SetClientInt(this.client, i_MaxHealth, value);
		}
	}
	
	property int Appartement
	{
		public get()
		{
			return rp_GetClientInt(this.client, i_Appart);
		}
		public set(int value)
		{
			rp_SetClientInt(this.client, i_Appart, value);
		}
	}
	
	property int Villa
	{
		public get()
		{
			return rp_GetClientInt(this.client, i_Villa);
		}
		public set(int value)
		{
			rp_SetClientInt(this.client, i_Villa, value);
		}
	}
	
	property int Conjoint
	{
		public get()
		{
			return rp_GetClientInt(this.client, i_MarriedTo);
		}
		public set(int value)
		{
			rp_SetClientInt(this.client, i_MarriedTo, value);
		}
	}
	
	property int JailTime
	{
		public get()
		{
			return rp_GetClientInt(this.client, i_JailTime);
		}
		public set(int value)
		{
			rp_SetClientInt(this.client, i_JailTime, value);
		}
	}
	
	property int TeamID
	{
		public get()
		{
			return GetClientTeam(this.client);
		}
		public set(int value)
		{
			ChangeClientTeam(this.client, value);
		}
	}
	
	property int Health
	{
		public get()
		{
			return GetClientHealth(this.client);
		}
		public set(int value)
		{
			SetEntityHealth(this.client, value);
		}
	}
	
	// Functions
	public void SetSkin()
	{
		char skin[256];
		rp_GetClientString(this.client, sz_Skin, STRING(skin));
		if (this.JailTime > 0)
		{
			int random = GetRandomInt(1, 7);
			switch(random)
			{
				case 1:
				{
					if(rp_GetGame() == Engine_CSGO)
					{
						PrecacheAndSetModel(this.client, "models/player/custom_player/kuristaja/jailbreak/prisoner1/prisoner1.mdl");
						PrecacheAndSetArms(this.client, "models/player/custom_player/kuristaja/jailbreak/prisoner1/prisoner1_arms.mdl");
					}	
				}
				case 2:
				{
					if(rp_GetGame() == Engine_CSGO)
					{
						PrecacheAndSetModel(this.client, "models/player/custom_player/kuristaja/jailbreak/prisoner2/prisoner2.mdl");
						PrecacheAndSetArms(this.client, "models/player/custom_player/kuristaja/jailbreak/prisoner2/prisoner2_arms.mdl");
					}	
				}
				case 3:
				{
					if(rp_GetGame() == Engine_CSGO)
					{
						PrecacheAndSetModel(this.client, "models/player/custom_player/kuristaja/jailbreak/prisoner3/prisoner3.mdl");
						PrecacheAndSetArms(this.client, "models/player/custom_player/kuristaja/jailbreak/prisoner3/prisoner3_arms.mdl");
					}	
				}	
				case 4:
				{
					if(rp_GetGame() == Engine_CSGO)
					{
						PrecacheAndSetModel(this.client, "models/player/custom_player/kuristaja/jailbreak/prisoner4/prisoner4.mdl");
						PrecacheAndSetArms(this.client, "models/player/custom_player/kuristaja/jailbreak/prisoner4/prisoner4_arms.mdl");
					}	
				}
				case 5:
				{
					if(rp_GetGame() == Engine_CSGO)
					{
						PrecacheAndSetModel(this.client, "models/player/custom_player/kuristaja/jailbreak/prisoner5/prisoner5.mdl");
						PrecacheAndSetArms(this.client, "models/player/custom_player/kuristaja/jailbreak/prisoner5/prisoner5_arms.mdl");
					}	
				}	
				case 6:
				{
					if(rp_GetGame() == Engine_CSGO)
					{
						PrecacheAndSetModel(this.client, "models/player/custom_player/kuristaja/jailbreak/prisoner6/prisoner6.mdl");
						PrecacheAndSetArms(this.client, "models/player/custom_player/kuristaja/jailbreak/prisoner6/prisoner6_arms.mdl");
					}	
				}
				case 7:
				{
					if(rp_GetGame() == Engine_CSGO)
					{
						PrecacheAndSetModel(this.client, "models/player/custom_player/kuristaja/jailbreak/prisoner7/prisoner7.mdl");
						PrecacheAndSetArms(this.client, "models/player/custom_player/kuristaja/jailbreak/prisoner7/prisoner7_arms.mdl");
					}	
				}				
			}	
		}
		else if (this.TeamID == CS_TEAM_CT && this.JobID == 1 || this.JobID == 5)
			SetJobSkin(this.client);
		else if(this.JobID == 4 || this.JobID == 2)
			SetJobSkin(this.client);
		else if (this.TeamID == CS_TEAM_T && StrContains(skin, ".mdl") != -1)
		{
			if(!StrEqual(skin, ""))
				PrecacheAndSetModel(this.client, skin);
		}
		else
		{
			int random = GetRandomInt(1, 4);
			switch(random)
			{
				case 1:
					if(rp_GetGame() == Engine_CSGO)
						PrecacheAndSetModel(this.client, "models/player/custom_player/legacy/tm_separatist.mdl");
				case 2:
					if(rp_GetGame() == Engine_CSGO)
						PrecacheAndSetModel(this.client, "models/player/custom_player/legacy/tm_professional.mdl");
				case 3:
					if(rp_GetGame() == Engine_CSGO)
						PrecacheAndSetModel(this.client, "models/player/custom_player/legacy/tm_professional_variant.mdl");
				case 4:
					if(rp_GetGame() == Engine_CSGO)
						PrecacheAndSetModel(this.client, "models/player/custom_player/legacy/tm_phoenix_variantg.mdl");
			}	
		}	
	}
	
	public void Teleport(float origin[3] = NULL_VECTOR, float angles[3] = NULL_VECTOR, float velocity[3] = NULL_VECTOR)
	{
		TeleportEntity(this.client, origin, angles, velocity);
	}
	
	public void Slap(int health = 5, bool sound = true)
	{
		SlapPlayer(this.client, health, sound);
	}
	
	public void Suicide()
	{
		ForcePlayerSuicide(this.client);
	}
	
	public void FadeScreen(int duration, int color[4])
	{
		ScreenFade(this.client, duration, color);
	}
	
	public void ShakeScreen(float amplitude, float frequency, float duration)
	{
		ScreenShake(this.client, amplitude, frequency, duration);
	}
}

methodmap Auth < JSONObject
{
    // Constructor
    public Auth() { return view_as<Auth>(new JSONObject()); }

    public void GetUsername(char[] buffer, int maxlength)
    {
        this.GetString("username", buffer, maxlength);
    }
    public void SetUsername(const char[] value)
    {
        this.SetString("username", value);
    }
    
	public void GetEmail(char[] buffer, int maxlength)
    {
        this.GetString("email", buffer, maxlength);
    }
    public void SetEmail(const char[] value)
    {
        this.SetString("email", value);
    }
    
    public void GetPassword(char[] buffer, int maxlength)
    {
        this.GetString("password", buffer, maxlength);
    }
    public void SetPassword(const char[] value)
    {
        this.SetString("password", value);
    }
    
    public void GetToken(char[] buffer, int maxlength)
    {
        this.GetString("token", buffer, maxlength);
    }
    public void SetToken(const char[] value)
    {
        this.SetString("token", value);
    }
    
    public void GetSteamID(char[] buffer, int maxlength)
    {
        this.GetString("steamid", buffer, maxlength);
    }
    public void SetSteamID(const char[] value)
    {
        this.SetString("steamid", value);
    }
}; 