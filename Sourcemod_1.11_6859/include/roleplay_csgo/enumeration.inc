enum int_list
{
	i_Appart,
	i_AppartTime,
	i_Bank,
	i_Grade,
	i_Graffiti,
	i_GraffitiIndex,
	i_Group,
	i_Job,
	i_JailTime,
	i_LastAgression,
	i_LastKilled_Reverse,
	i_LastDangerousShot,
	i_LastVol,
	i_LastVolTarget,
	i_LastVolTime,
	i_LastVolAmount,
	i_LastVolArme,
	i_KillJailDuration,
	i_KitCrochetage,
	i_KnifeThrow,
	i_KnifeLevel,
	i_MarriedTo,
	i_MaxHealth,
	i_Money,
	i_Machine,
	i_Plante,
	i_TicketMetro,
	i_Trash,
	i_Salary,
	i_Zone,
	i_ZoneAppart,
	i_ZoneHotel,
	i_SalaryBonus,
	i_VipTime,
	i_Rank,
	i_Villa,
	i_ZoneVilla,
	i_AppartCount,
	i_XP,
	i_MaxSelfItem,
	i_JailRaisonID,
	i_JailID,
	i_Organisation,
	i_Nationality,
	i_Sexe,
	i_Hotel
};

enum bool_list
{
	b_HasBankCard,
	b_HasCrowbar,
	b_HasCovidFaceMask,
	b_HasFlashLight,
	b_HasLubrifiant,
	b_HasMandate,	
	b_HasSwissAccount,	
	b_CanUseItem,
	b_DisplayHud,	
	b_HasBonusHealth,
	b_HasBonusKevlar,
	b_HasBonusPay,
	b_HasBonusBox,
	b_HasBonusTomb,
	b_HasJointEffect,
	b_HasShitEffect,
	b_HasAmphetamineEffect,
	b_HasHeroineEffect,
	b_HasEcstasyEffect,
	b_HasCocainaEffect,
	b_HasSellLicence,
	b_HasCarLicence,
	b_HasPrimaryWeaponLicence,
	b_HasSecondaryWeaponLicence,
	b_HasKevlarRegen,
	b_HasHealthRegen,
	b_HasRib,
	b_HasGlovesProtection,
	b_IsNew,
	b_IsMuteGlobal,
	b_IsMuteLocal,
	b_IsMuteVocal,
	b_IsVip,
	b_IsAfk,
	b_IsTased,
	b_IsSearchByTribunal,
	b_IsPassive,
	b_JoinSound,
	b_MayTalk,
	b_SpawnJob,
	b_TransfertItemBank,
	b_TouchedByDanceGrenade,
	b_IsThirdPerson,
	b_HasCasinoAccess,
	b_IsOnAduty,
	b_IsSteamMember,
	b_IsWebsiteMember,
	b_IsOnParking,
	b_HasColorPallet
};

enum float_list 
{
	fl_Vitality,
	fl_Faim,
	fl_Soif
};

enum string_list 
{
	sz_Skin,
	sz_FirstName,
	sz_LastName,
	sz_AdminTag,
	sz_ZoneName,
	sz_ClotheHat,
	sz_ClotheMask,
	sz_SteamID
};

enum vehicle_list 
{
	car_fuel,
	car_maxFuel,
	car_km,
	car_owner,
	car_maxPassager,
	car_price,	
	car_police,
	car_id,
	car_skinid,
	car_brand,
	car_engine,
	car_insideradar,
	car_wheeltype,
	car_serial
};

enum time_list {
	i_hour1,
	i_hour2,
	i_minute1,
	i_minute2,
	i_day,
	i_month,
	i_year
};

enum item_list 
{
	item_name,
	item_reuse_delay,
	item_jobid,
	item_price,
	item_description,
	item_new,
	item_farmtime,
	item_maxquantity,
	item_maxgold,
	item_maxsteel,
	item_maxcopper,
	item_maxaluminium,
	item_maxzinc,
	item_maxwood,
	item_maxplastic,
	item_maxwater
};

enum admin_type {
	ADMIN_FLAG_NONE = 0,
	ADMIN_FLAG_OWNER,
	ADMIN_FLAG_ADMIN,
	ADMIN_FLAG_MODERATOR
};

enum archi_list {
	archi_headshotman = 0,
	archi_newplayer,
	archi_firstjob,
	archi_24h,
	archi_prodriver
};

enum ammo_type {
	ammo_type_default = 0,
	ammo_type_incendiary,
	ammo_type_rubber,
	ammo_type_perforating,
	ammo_type_explosive,
	ammo_type_health,
	ammo_type_paintball
};

enum knife_type {
	knife_type_default = 0,
	knife_type_freeze,
	knife_type_fire
};

enum sick_list {
	sick_type_fever,
	sick_type_plague,
	sick_type_covid
};

enum surgery_list {
	surgery_heart,
	surgery_legs,
	surgery_lung,
	surgery_liver
};

enum appart_list {
	appart_owner,
	appart_price
};

enum villa_list {
	villa_owner,
	villa_price
};

enum hotel_list {
	hotel_owner,
	hotel_price
};

enum int_stat_data {
	i_nostat = 0,
	
	i_S_MoneyEarned_Pay,
	i_S_MoneyEarned_Phone,
	i_S_MoneyEarned_Mission,
	i_S_MoneyEarned_Sales,
	i_S_MoneyEarned_Pickup,
	i_S_MoneyEarned_CashMachine,
	i_S_MoneyEarned_Give,
	i_S_MoneySpent_Fines,
	i_S_MoneySpent_Shop,
	i_S_MoneySpent_Give,
	i_S_MoneySpent_Stolen,
	i_S_LotoSpent,
	i_S_LotoWon,
	i_S_DrugPickedUp,
	i_S_Kills,
	i_S_Deaths,
	i_S_ItemUsed,
	i_S_ItemUsedPrice,
	i_S_TotalBuild,
	i_S_RunDistance,
	i_S_JobSucess,
	i_S_JobFails,
	i_uStat_nosavemax,
	
	i_Money_OnConnection,
	i_MoneyEarned_Pay, // Salaire + vita + appart
	i_MoneyEarned_Phone, // Telephone + valeur des items ramassés
	i_MoneyEarned_Mission, // Missions + valeur des items ramassés
	i_MoneyEarned_Sales, // Ventes ou Vols
	i_MoneyEarned_Pickup,
	i_MoneyEarned_CashMachine,
	i_MoneyEarned_Give,
	i_MoneySpent_Fines,
	i_MoneySpent_Shop,
	i_MoneySpent_Give,
	i_MoneySpent_Stolen,
	i_Vitality_OnConnection,
	i_LotoSpent, // FAIT
	i_LotoWon, // FAIT
	i_DrugPickedUp, // FAIT
	i_Kills, // FAIT
	i_Deaths, // FAIT
	i_ItemUsed, // FAIT
	i_ItemUsedPrice, // FAIT
	i_PVP_OnConnection, // ? TODO
	i_TotalBuild,  // TODO
	i_RunDistance,
	i_JobSucess, // Mafia 18th Tueur
	i_JobFails,
	i_LastDeathTimestamp,
	i_LastKillTimestamp,
	i_uStat_max
};

enum enum_event_type {
	event_type_none,
	event_type_murder,
	event_type_buildwars
};

enum rank_list {
	rank_xpreq,
	rank_name,
	rank_advantage
};

enum resource_list {
	resource_gold,
	resource_steel,
	resource_copper,
	resource_aluminium,
	resource_zinc,
	resource_wood,
	resource_plastic,
	resource_water
};

enum zone_type {
	zone_name = 0,

	zone_min_x,
	zone_min_y,
	zone_min_z,

	zone_max_x,
	zone_max_y,
	zone_max_z,

	zone_flag,
	zone_bit,
	zone_extra
};