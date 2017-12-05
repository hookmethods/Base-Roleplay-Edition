/*
	- Phone battery
	
	
	To do:
		Phone menu
		Car jacker: if player disconnect or death in the mission, reset their var
		Car jacker if player destroys the vehicle in mission, fine them the car price * 0.1
*/


#include <a_samp>
#include <a_mysql>
#include <Pawn.CMD>
#include <streamer>
#include <foreach>
#include <sscanf2>
#include <evi>
#include <3DTryg>
#include <easyDialog>


#define this::%0(%1) forward %0(%1); public %0(%1)

#define SPLITTER                (".")
#define SPECIAL_ACTION_PISSING  (69)
#define DOTS_ADD                (3)
#define BYTES_PER_CELL          (cellbits / 8)
#define NULL                    ("\1")

#undef MAX_PLAYERS
	#define MAX_PLAYERS  (50)
	
native gpci(playerid, serial[], len);

new this; //dbHandler

#define SQL_HOSTNAME "localhost"
#define SQL_USERNAME "root"
#define SQL_DATABASE "ls-rp"
#define SQL_PASSWORD "root"

//Database establisher end of.
main ()  
	{ }
	
/*	

	To do:
	
	1. Revamp housing.
	2. Add more features into business such as ..
	                                            /dj - for nightclubs, bar typed business. (clerk & owner)
	                                            /mic - microphone for business. (clerk & owner)
	                                            /hire - hire a clerk (limit up to 5 depends on owner's donate level)
	                                            /fire - fire a clerk
	                                            
	3. Add /bareswitch and /housetime for house system, after this then do furniture system.
	4. Script some jobs, as the same as LS-RP.
	5. Phone sys.
	
	6. When these are done, upgrade veh system, something needs tweak.
	7. Hud doesnt show properly

*/


#define SCRIPT_REV "Rev 1.5.10.4"
	
#define INVALID_ID         		  -1
	
//Max defines:
#define MAX_PROPERTY (200)

#define MAX_BUSINESS (200)
#define MAX_BUSINESS_PRODUCTS (500)

#define MAX_FACTIONS (30)
#define MAX_FACTION_RANKS (21)

#define MAX_PLAYER_VEHICLES (6)

#define MAX_XMR_CATEGORY (40)
#define MAX_XMR_CATEGORY_STATIONS (60)

#define MAX_RECORD_SHOW (6)
#define MAX_ZONE_NAME (28)


//THREADS
#define THREAD_GRAFFITI (1)
#define THREAD_KILL 	(0)


//phone types
#define PHONE_TYPE_BLACK (0)
#define PHONE_TYPE_RED   (1)
#define PHONE_TYPE_BLUE  (2)

#define    Page_None        -1
#define    Page_Home   		0
#define    Page_Menu   		1
#define    Page_Notebook   	2
#define    Page_Contact   	3
#define    Page_Setting   	4

enum cache_data
{
	current_page
}

new cache_phone[MAX_PLAYERS][cache_data];

#define SLOT_HANDCUFF 6
#define SLOT_PHONE 7
#define SLOT_MEAL 8
#define SLOT_MISC 9

//Colors:
#define COLOR_LIGHTRED (0xFF6347AA)
#define COLOR_RED (0xFF6347FF)
#define COLOR_REDEX (0xF81414FF)

#define COLOR_STREAM (0x88AA62FF)
#define COLOR_GREEN (0x33CC33FF)
#define COLOR_DARKGREEN (0x33AA33FF)

#define COLOR_YELLOW (0xFFE104FF)
#define COLOR_YELLOWEX (0xFFFF00FF)

#define COLOR_GRAD1	(0xCCE6E6FF)
#define COLOR_GRAD2	(0xE2FFFFFF)

#define COLOR_WHITE (0xFFFFFFFF)
#define COLOR_GREY 	(0xAFAFAFFF)

#define COLOR_EMOTE	(0xC2A2DAFF)
#define COLOR_REPORT (0xFFFF91FF)

#define COLOR_FADE1 (0xE6E6E6E6)
#define COLOR_FADE2 (0xC8C8C8C8)
#define COLOR_FADE3 (0xAAAAAAAA)
#define COLOR_FADE4 (0x8C8C8C8C)
#define COLOR_FADE5 (0x6E6E6E6E)

#define COLOR_COP (0x8D8DFFFF)
#define COLOR_DEPT (0xF07A7AFF)

#define COLOR_ACTION (0xF8E687FF)
#define COLOR_SAMP	(0xADC3E7FF)

#define COLOR_RADIO	(0xFFEC8BFF)
#define COLOR_RADIOEX (0xB5AF8FFF)

#define COLOR_PMRECEIVED (0xFFDC18FF)
#define COLOR_PMSENT (0xEEE854FF)

#define COLOR_CYAN (0x00FFFFFF)
#define COLOR_PINK	(0xFF8282FF)

//Client messages:
#define SendUsageMessage(%0,%1) \
	sendMessage(%0, COLOR_RED, "USAGE: "%1)
	
#define SendErrorMessage(%0,%1) \
	sendMessage(%0, COLOR_RED, "ERROR: "%1)

#define SendServerMessage(%0,%1) \
	sendMessage(%0, COLOR_RED, "SERVER: "%1)
	
#define HOLDING(%0) \
    ((newkeys & (%0)) == (%0))

#define RELEASED(%0) \
	(((newkeys & (%0)) != (%0)) && ((oldkeys & (%0)) == (%0)))

#define PRESSED(%0) \
	(((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))
	
//Faction types:	
#define FACTION_TYPE_ILLEGAL (1)
#define FACTION_TYPE_POLICE (2)
#define FACTION_TYPE_MEDICAL (3)
#define FACTION_TYPE_DOC (4)

//Property types:
#define PROPERTY_TYPE_HOUSE (1)
#define PROPERTY_TYPE_APTCOMPLEX (2)
#define PROPERTY_TYPE_APTROOM (3)

//Business types:
#define BUSINESS_TYPE_RESTAURANT (1)
#define BUSINESS_TYPE_AMMUNATION (2)
#define BUSINESS_TYPE_CLUB (3)
#define BUSINESS_TYPE_BANK (4)
#define BUSINESS_TYPE_GENERAL (5)
#define BUSINESS_TYPE_DEALERSHIP (6)
#define BUSINESS_TYPE_DMV (7) 

//Player states:
#define PLAYER_STATE_ALIVE (1)
#define PLAYER_STATE_WOUNDED (2)
#define PLAYER_STATE_DEAD (3)

//Body parts:
#define BODY_PART_CHEST	(3)
#define BODY_PART_GROIN (4)
#define BODY_PART_LEFT_ARM (5)
#define BODY_PART_RIGHT_ARM (6)
#define BODY_PART_LEFT_LEG (7)
#define BODY_PART_RIGHT_LEG (8)
#define BODY_PART_HEAD (9)

//Spawn points:
#define SPAWN_POINT_AIRPORT (0)
#define SPAWN_POINT_PROPERTY (1)
#define SPAWN_POINT_FACTION (2)

//Global variables:
new call_count = 0, warrant_count = 0;
new bool:oocEnabled = false, globalWeather = 2; 
new dmv_vehicles[4]; 
new Job_Fails[MAX_PLAYERS];
//Phone Textdraw

new PlayerText:MDC_UI[MAX_PLAYERS][70];
new PlayerText:SetUp[MAX_PLAYERS][16];

new PlayerText:Player_Hud[MAX_PLAYERS][9];

new PlayerText:MDC_Layout[MAX_PLAYERS][19];
new PlayerText:PlayerOffer[MAX_PLAYERS];

new PlayerText:TDTuning_Component[MAX_PLAYERS],
	PlayerText:TDTuning_Dots[MAX_PLAYERS],
	PlayerText:TDTuning_Price[MAX_PLAYERS],
	PlayerText:TDTuning_ComponentName[MAX_PLAYERS],
	PlayerText:TDTuning_YN[MAX_PLAYERS];
	
new PlayerText:Player_Static_Arrow[MAX_PLAYERS];
new PlayerText:Player_Vehicles_Arrow[MAX_PLAYERS][3];

new PlayerText:Player_Vehicles[MAX_PLAYERS][6];
new PlayerText:Player_Vehicles_Name[MAX_PLAYERS][6];

new PlayerText: Store_Business[MAX_PLAYERS];
new PlayerText: Store_Mask[MAX_PLAYERS]; 
new PlayerText: Store_Cart[MAX_PLAYERS];
new Text: Store_UI[10];
new Text: Store_Frame[30];

enum SIREN_DATA
{
	siren_model,
	siren_name[64],
	Float: siren_offsetX,
	Float: siren_offsetY,
	Float: siren_offsetZ,
	Float: siren_rotX,
	Float: siren_rotY,
	Float: siren_rotZ,
	bool:IsDynamic,
	flash_time
}

new const siren_array[][SIREN_DATA] = {

    {19298, "Silent Siren", 0.0000, 0.0000, 1.2000, 0.0000, 0.0000, 0.0000, true, 150}, //与19296 进行闪烁, 0.5s一次
    {19294, "Roof Siren", 0.5000, -0.2500, 1.0000, 0.0000, 0.0000, 0.0000, true, 1000}, //从0.5增长到-0.9 然后从-0.9 增长到0.5
	{19280, "Alley Light", -0.8999, 1.0000, 0.3000, 0.0000, 0.0000, 0.0000, false, -1},
	{345, "Flasher", 0.0000, -0.4000, 0.8999, 0.0000, 0.0000, 90.0000, false, -1}
};

new g_MaleSkins[185] = {
	1, 2, 3, 4, 5, 6, 7, 8, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29,
	30, 32, 33, 34, 35, 36, 37, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 57, 58, 59, 60,
	61, 62, 66, 68, 72, 73, 78, 79, 80, 81, 82, 83, 84, 94, 95, 96, 97, 98, 99, 100, 101, 102,
	103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120,
	121, 122, 123, 124, 125, 126, 127, 128, 132, 133, 134, 135, 136, 137, 142, 143, 144, 146,
	147, 153, 154, 155, 156, 158, 159, 160, 161, 162, 167, 168, 170, 171, 173, 174, 175, 176,
	177, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 200, 202, 203, 204, 206,
	208, 209, 210, 212, 213, 217, 220, 221, 222, 223, 228, 229, 230, 234, 235, 236, 239, 240,
	241, 242, 247, 248, 249, 250, 253, 254, 255, 258, 259, 260, 261, 262, 268, 272, 273, 289,
	290, 291, 292, 293, 294, 295, 296, 297, 299
};

new g_FemaleSkins[77] = {
    9, 10, 11, 12, 13, 31, 38, 39, 40, 41, 53, 54, 55, 56, 63, 64, 65, 69, 75, 76, 77, 85, 88,
	89, 90, 91, 92, 93, 129, 130, 131, 138, 140, 141, 145, 148, 150, 151, 152, 157, 169, 178,
	190, 191, 192, 193, 194, 195, 196, 197, 198, 199, 201, 205, 207, 211, 214, 215, 216, 219,
	224, 225, 226, 231, 232, 233, 237, 238, 243, 244, 245, 246, 251, 256, 257, 263, 298
};

new Text:PP_Framework[15];
new PlayerText:NumberLetters[MAX_PLAYERS][4];
new PlayerText:PP_Btn[MAX_PLAYERS][11];

new
	PlayerText: ColorPanel[MAX_PLAYERS][10],
	PlayerText: PhoneFrame[MAX_PLAYERS][3],
	PlayerText: PhoneLogo[MAX_PLAYERS],
	PlayerText: PhoneSwitch[MAX_PLAYERS],
	PlayerText: PhoneInfo[MAX_PLAYERS],
	PlayerText: PhoneDisplay[MAX_PLAYERS],
	PlayerText: PhoneBtnL[MAX_PLAYERS],
	PlayerText: PhoneBtnR[MAX_PLAYERS],
	PlayerText: PhoneArrowUp[MAX_PLAYERS],
	PlayerText: PhoneArrowDown[MAX_PLAYERS],
	PlayerText: PhoneArrowLeft[MAX_PLAYERS],
	PlayerText: PhoneArrowRight[MAX_PLAYERS],
	PlayerText: PhoneBtnMenu[MAX_PLAYERS],
	PlayerText: PhoneBtnBack[MAX_PLAYERS],
	PlayerText: PhoneDate[MAX_PLAYERS],
	PlayerText: PhoneTime[MAX_PLAYERS],
	PlayerText: PhoneSignal[MAX_PLAYERS],
	PlayerText: PhonePower[MAX_PLAYERS],
	PlayerText: PhoneNotify[MAX_PLAYERS],
	PlayerText: PhoneList[MAX_PLAYERS][3],
	PlayerText: PhoneListName[MAX_PLAYERS]
;

enum
{
	DIALOG_DEFAULT,
	DIALOG_CONFIRM_SYS,
	DIALOG_REGISTER,
	DIALOG_LOGIN,
	DIALOG_REPORT,
	DIALOG_FACTION_CONFIG,
	DIALOG_FACTION_NAME,
	DIALOG_FACTION_ABBREV,
	DIALOG_FACTION_ALTER_R,
	DIALOG_FACTION_ALTER_J,
	DIALOG_FACTION_ALTER_C,
	DIALOG_FACTION_CHATCOLOR,
	DIALOG_FACTION_RANKS,
	DIALOG_FACTION_RANKEDIT,
	DIALOG_FACTION_ALTER_T,
	DIALOG_VEHICLE_WEAPONS,
	DIALOG_HOUSE_WEAPONS,
	DIALOG_XMR_CATEGORIES,
	DIALOG_XMR_STATIONS,
	DIALOG_POLICE_SKINS,
	DIALOG_BUY_LIST,
	DIALOG_DEALERSHIP,
	DIALOG_DEALERSHIP_SELECT,
	DIALOG_DEALERSHIP_APPEND,
	DIALOG_DEALERSHIP_APPEND_ALARM,
	DIALOG_DEALERSHIP_APPEND_LOCK,
	DIALOG_DEALERSHIP_APPEND_INS,
	DIALOG_DEALERSHIP_APPEND_IMMOB,
	DIALOG_DEALERSHIP_APPEND_CMenu,
	DIALOG_DEALERSHIP_PURCHASE,
	DIALOG_SELECT_HOUSE,
	DIALOG_MDC,
	DIALOG_MDC_NAME,
	DIALOG_MDC_NAME_QUEUE,
	DIALOG_MDC_PLATE,
	DIALOG_MDC_PLATE_QUEUE,
	DIALOG_MDC_PLATE_LIST,
	DIALOG_MDC_FINISH_QUEUE,
	DIALOG_SECRETWORD_CREATE,
	DIALOG_SECRETWORD_INPUT,
	DIALOG_EDIT_BONE,
	DIALOG_FOOD_CONFIG,
	DIALOG_FOOD_TYPE,
	DIALOG_FOOD_PRICE_1,
	DIALOG_FOOD_PRICE_2,
	DIALOG_FOOD_PRICE_3,
	DIALOG_SPRAY_MAIN,
	DIALOG_SPRAY_IMAGE,
	DIALOG_SPRAY_INPUT,
	DIALOG_SPRAY_FONT,
	DIALOG_SPRAY_CREATE,
	DIALOG_CHOPSHOP,
	DIALOG_REMOVE_COMP
};

#define MAX_ADVERT_SLOT (6)

enum e_advert_data
{
    advert_id,
    advert_text[256],
    publish_time,
	advert_placeby[MAX_PLAYER_NAME],
    advert_contact,
    in_area,
    advert_type,
    bool:advert_exists
}
new advert_data[MAX_ADVERT_SLOT][e_advert_data];


enum weaponSettings
{
    Float:Position[6],
    Bone,
    Hidden
}
new
	WeaponSettings[MAX_PLAYERS][17][weaponSettings],
	WeaponTick[MAX_PLAYERS],
	EditingWeapon[MAX_PLAYERS]
;

//Enumerators:
enum P_MASTER_ACCOUNTS
{
	mDBID,
	mAccName[60],
	
	mForumName[60],
	bool:mLoggedin
}

new e_pAccountData[MAX_PLAYERS][P_MASTER_ACCOUNTS]; 

enum P_ACCOUNT_DATA
{
	pDBID,
	bool:pLoggedin,

	pAdmin, 
	bool:pAdminDuty,
	
	pLastSkin,
	
	pLevel,
	pEXP,
	
	Float: pLastPos[3],
	pLastInterior,
	pLastWorld,
	
	pAge,
	
	pMoney,
	pBank,
	pPaycheck,
	
	pPhone,
	bool:pPhoneOff,
	bool:pPhonespeaker,
	
	pPhoneline,
	pCalling, 
	
	pActiveIP[60], 
	pLastOnline[90],
	pLastOnlineTime,
	
	bool:pAdminjailed, 
	pAdminjailTime,
	
	bool:pOfflinejailed,
	pOfflinejailedReason[128],
	
	bool:pMuted,	
	pSpectating,
	
	pFaction,
	pFactionRank,
	bool:pFactionChat,
	pFactionInvite,
	pFactionInvitedBy,
	
	pOwnedVehicles[MAX_PLAYER_VEHICLES],
	bool:pVehicleSpawned,
	pVehicleSpawnedID,
	pDuplicateKey,
	
	bool:pWeaponsSpawned,
	pWeaponsImmune,
	pWeapons[4], 
	pWeaponsAmmo[4],
	
	bool:pUnscrambling,
	pUnscramblerTime,
	pUnscrambleTimer,
	pUnscrambleID,
	pScrambleSuccess,
	pScrambleFailed,
	
	bool:pPoliceDuty,
	bool:pMedicDuty,
	
	pTimeplayed,
	
	pInsideProperty,
	pInsideBusiness,
	pAtDealership,
	
	pMaskID[2],
	bool:pMasked,
	
	pLastDamagetime,
	
	bool:pRelogging,
	pRelogCount,
	Text3D:pRelogTD,
	pRelogTimer,
	
	pPauseCheck,
	pPauseTime,
	
	pAddObject,
	pEditingObject,
	
	pHandcuffed,
	
	pGascan,
	bool:pHasMask,
	
	bool:pHasRadio,
	pRadio[3],
	pMainSlot,
	
	pRespawnTime,
	pDeathFix,
	
	pSpawnPoint,
	pSpawnPointHouse,
	
	bool:pTaser,
	
	pWeaponsLicense,
	pDriversLicense,
	
	pActiveListings,
	pPrisonTimes,
	pJailTimes,
	TempTweak,
	pHud,
	bool:pUseHud,
	pDonator,
	pJob,
	pCareer,
	pSideJob,
	pWalkstyle,
	pChatstyle,
    pAnimation,
    pChatting,
    pSelection,
    pMeal,
    bool:pUseGUI,
    pPhoneType,
    bool:pCooldown,
    pSprayPoint,
    pSprayLength,
    pSprayText[128],
    pSprayFont,
    pSprayTarget,
    pSprayAllow,
    pSprayTimer[2],
    pNumberStr[64],
    pPayphone,
    bool:pBoombox,
    ItemCache[10],
    pPhonePower,
    pDealershipIndex,
    pDealershipPage,
    bool:pViewingDealership,
    
	pInTuning,
	pTuningCategoryID,
	pTuningCount,
	pTuningComponent,
	
	InMission,
	MissionTime,
	MissionTarget[2],
	MissionReward,
	//pCharges
	pAddCharges,
	pJailType,
	pSetupInfo,
	pOutfit,
	pGender,
	
	pRentAt
	
}

new PlayerInfo[MAX_PLAYERS][P_ACCOUNT_DATA];

enum {
	GENDER_MALE = 1,
	GENDER_FEMALE
};

// job list
enum
{
	JOB_NONE,
	JOB_MECHANIC,
	JOB_FARMER,
	JOB_TRUCKER,
	JOB_CARJACKER
}

enum
{
	MISSION_NONE,
	CARJACKER_DELIVER,
	CARJACKER_DROPOFF,
	MECHANIC_BODYWORK,
	MECHANIC_CARFIX,
	MECHANIC_ENGINE,
	MECHANIC_BATTERY
}

enum // Textdraw activities
{
    EVENT_OFF,
	EVENT_FOODMENU,
    EVENT_CLOSE,
    EVENT_PHONE,
    EVENT_PURCHASE
}

enum
{
	REGULAR_PLAYER,
	DONATOR_BRONZE,
	DONATOR_SILVER,
	DONATOR_GOLD
};

new registerTime[MAX_PLAYERS], loginTime[MAX_PLAYERS];
new playerLastpay[MAX_PLAYERS], playerTaserAmmo[MAX_PLAYERS]; 

new 
	PlayerCheckpoint[MAX_PLAYERS], 
	playerWeaponsSave[MAX_PLAYERS][4], 
	playerWeaponsAmmoSave[MAX_PLAYERS][4]; 
	
new 
	bool:playerTextdraw[MAX_PLAYERS],
	PlayerText:FoodOrder[MAX_PLAYERS][13],
	Text3D:playerVehicleTextdraw[MAX_PLAYERS];

enum G_REPORT_INFO
{
	bool:rReportExists,
	rReportDetails[90], 
	rReportTime,
	rReportBy[32]
}

new ReportInfo[100][G_REPORT_INFO]; 
new playerReport[MAX_PLAYERS][128]; 

enum E_FACTION_INFO
{
	eFactionDBID,
	
	eFactionName[90],
	eFactionAbbrev[30], 
	
	Float: eFactionSpawn[3],
	eFactionSpawnInt,
	eFactionSpawnWorld,
	
	eFactionJoinRank,
	eFactionAlterRank,
	eFactionChatRank,
	eFactionTowRank,
	
	bool:eFactionChatStatus,
	eFactionChatColor,
	
	eFactionType,
	eFactionCSID
}

new FactionInfo[MAX_FACTIONS][E_FACTION_INFO]; 
new FactionRanks[MAX_FACTIONS][MAX_FACTION_RANKS][60]; 
new playerEditingRank[MAX_PLAYERS];

#define MAX_VEH_PART (4)

enum E_VEHICLE_SYSTEM
{
	eVehicleDBID, 
	bool:eVehicleExists,
	
	eVehicleOwnerDBID,
	eVehicleFaction,
	
	eVehicleModel, 
	eVehicleColor1,
	eVehicleColor2,
	eVehiclePaintjob,
	
	Float:eVehicleParkPos[4],
	eVehicleParkInterior,
	eVehicleParkWorld,
	
	eVehiclePlates[32], 
	bool:eVehicleLocked,
	
	bool:eVehicleImpounded,
	Float:eVehicleImpoundPos[4], 
	
	Float: eVehicleFuel,
	eVehicleSirens,
	
	eVehicleLastDrivers[5], //4;
	eVehicleLastPassengers[5], //4;
	
	bool:eVehicleLights,
	bool:eVehicleEngineStatus,
	
	bool:eVehicleAdminSpawn,
	
	Text3D:eVehicleTowDisplay,
	eVehicleTowCount,
	
	bool:eVehicleHasXMR, 
	bool:eVehicleXMROn,
	eVehicleXMRURL[128],
	
	Float:eVehicleBattery,
	Float:eVehicleEngine, 
	Float:eVehicleHealth,
	eVehicleTimesDestroyed,
	
	eVehicleLockLevel,
	eVehicleAlarmLevel, 
	eVehicleImmobLevel,
	eVehicleInsurance,
	eVehicleInsBill,
	eVehicleInsTime,
	
	Text3D:eVehicleLabel,
	eVehicleEnterTimer,
	
	bool:eVehicleTweak,
	eVehicleDamage[MAX_VEH_PART],
	
	bool:eVehicleHasCarsign,
	Text3D:eVehicleCarsign,
	
	eVehicleRefillCount,
	Text3D:eVehicleRefillDisplay,
	Float: eMileage,
	eVehicleSiren[4],
	eVehicleSirenTimer[4],
	eVehicleFlash[4],
	eVehicleFlashRaise[4],
	eVehicleSirenUsed[4],
	
	eVehicleMods[14],
	bool:ePhysicalAttack,
	eDoorHealth,
	eDoorEffect,
	eVehicleRev,
	bool:vCooldown,
	
	vWindows,
	vWindowFL,
	vWindowFR,
	vWindowBL,
	vWindowBR,
	
	Float: eVehicleStolenPos[4],
	bool:eVehicleStolen
}

new VehicleInfo[MAX_VEHICLES][E_VEHICLE_SYSTEM]; 
					
#define BLOCK_NONE 0
#define LESS_DAMAGE_FIST 1
#define BLOCK_FIST 2
#define LESS_DAMAGE_MELEE 3
#define BLOCK_PHYSICAL 4

#define MAX_WEP_SLOT (6)

enum E_TRUNK_DATA
{
	data_id,
	veh_id,
	Float: wep_offset[6],
	veh_wep,
	veh_ammo,
	temp_object,
	bool:is_exist
}
new vehicle_trunk_data[MAX_VEHICLES][MAX_WEP_SLOT][E_TRUNK_DATA];

new
	lastVehicleSpawn[MAX_PLAYERS], 
	bool:playerTowingVehicle[MAX_PLAYERS], 
	playerTowTimer[MAX_PLAYERS]
;

new playerInsertID[MAX_PLAYERS];

new playerRefillingVehicle[MAX_PLAYERS], playerRefillTimer[MAX_PLAYERS]; 

enum E_UNSCRAMBLER_DATA
{
	eUnscrambleLevel,
	eScrambledWord[60],
	eUnscrambledWord[60]
}

new UnscrambleInfo[][E_UNSCRAMBLER_DATA] = 
{
	{1, "Nwe", "New"},
	{2, "Relseea", "Release"},
	{3, "Scritp", "Script"}
  //The values are the immobiliser level the word will show for. 
  //I recommend having them equally the same amount. Up to you. 
  // /unscramble usage. 
};

enum E_DROPPEDGUN_DATA
{
	bool:eWeaponDropped,
	eWeaponObject,
	eWeaponTimer,
	
	eWeaponWepID,
	eWeaponWepAmmo,
	
	Float:eWeaponPos[3],
	eWeaponInterior,
	eWeaponWorld,
	
	eWeaponDroppedBy
}

new WeaponDropInfo[200][E_DROPPEDGUN_DATA];

enum E_PROPERTY_DATA
{
	ePropertyDBID,
	ePropertyOwnerDBID,
	
	ePropertyType,
	ePropertyFaction,
	
	Float:ePropertyEntrance[3],
	ePropertyEntranceInterior,
	ePropertyEntranceWorld,
	
	Float:ePropertyInterior[3],
	ePropertyInteriorIntID,
	ePropertyInteriorWorld,
	
	ePropertyMarketPrice,
	ePropertyLevel,
	ePropertyAlarm,
	
	bool:ePropertyLocked,
	
	ePropertyCashbox,
	ePropertyWeapons[21],
	ePropertyWeaponsAmmo[21],
	
	Float:ePropertyPlacePos[3],
	
	bool:ePropertyHasBoombox,
	
	bool:ePropertyBoomboxOn,
	ePropertyBoomboxURL,
	
	ePropertyRentFee,
	bool:ePropertyRentAble,
	ePropertyBareSwitch
}

new PropertyInfo[MAX_PROPERTY][E_PROPERTY_DATA]; 

enum E_XMR_CATEGORY_DATA
{
	eXMRID,
	eXMRCategoryName[90]
}

enum E_XMR_CATEGORY_STATIONS_DATA
{
	eXMRStationID,
	eXMRCategory,
	
	eXMRStationName[90],
	eXMRStationURL[128]
}

new XMRCategoryInfo[MAX_XMR_CATEGORY][E_XMR_CATEGORY_DATA];
new XMRStationInfo[MAX_XMR_CATEGORY_STATIONS][E_XMR_CATEGORY_STATIONS_DATA]; 

new CatXMRHolder[MAX_PLAYERS], SubXMRHolder[MAX_PLAYERS]; 
new SubXMRHolderArr[MAX_PLAYERS][MAX_XMR_CATEGORY]; 

enum E_BUSINESS_DATA
{
	eBusinessDBID,
	eBusinessOwnerDBID,
	
	Float:eBusinessInterior[3], 
	eBusinessInteriorWorld,
	eBusinessInteriorIntID, 
	
	Float:eBusinessEntrance[3],
	
	eBusinessName[90], 
	
	eBusinessType, 
	eBusinessPickup, 
	
	bool:eBusinessLocked,
	eBusinessEntranceFee,
	
	eBusinessLevel,
	eBusinessMarketPrice,
	
	eBusinessCashbox,
	eBusinessProducts,
	
	eBusinessBankPickup,
	Float:eBusinessBankPickupLoc[3], 
	eBusinessBankPickupWorld,
	
	eBusinessRestaurantType,
	eBusinessFood[3],
	eBusinessFoodPrice[3]
	
}
new BusinessInfo[MAX_BUSINESS][E_BUSINESS_DATA]; 

enum E_FOOD_DATA
{
	FoodType,
	Model,
    FoodName[128],
    Float: HealthPoint,
	FoodPrice
};

#define TYPE_PIZZA    (0)
#define TYPE_BURGER   (1)
#define TYPE_CHICKEN  (2)
#define TYPE_DONUT    (3)

new const Food_Data[][E_FOOD_DATA] = {

	{TYPE_PIZZA, 2218, "Buster", 50.0, 150},
	{TYPE_PIZZA, 2219, "Double_D-Luxe", 100.0, 350},
	{TYPE_PIZZA, 2220, "Full_Rack", 150.0, 500},
	
	{TYPE_BURGER, 2213, "Moo_Kids_Meal", 50.0, 150},
	{TYPE_BURGER, 2214, "Beef_Tower", 100.0, 350},
	{TYPE_BURGER, 2212, "Meat_Stack", 150.0, 500},

	{TYPE_CHICKEN, 2215, "Cluckin'_Little_Meal", 50.0, 150},
	{TYPE_CHICKEN, 2216, "Cluckin'_Big_Meal", 100.0, 350},
	{TYPE_CHICKEN, 2217, "Cluckin'_Huge_Meal", 150.0, 500},
	
	{TYPE_DONUT, 2221, "Donut_Small_Pack", 50.0, 150},
	{TYPE_DONUT, 2223, "Donut_Medium_Pack", 100.0, 350},
	{TYPE_DONUT, 2222, "Donut_Large_Pack", 150.0, 500}
	
};

enum e_InteriorList {
	e_Interior,
	Float: e_InteriorX,
	Float: e_InteriorY,
	Float: e_InteriorZ,
	Float: e_InteriorA
};

new const Float:g_HouseInteriors[][e_InteriorList] =
{
	{0,  0000.0000, 0000.0000, 0000.0000, 000.0000},
    {3,  1363.7614, -2145.6965, 1050.5886, 356.4167},
    {6,  1749.6356, -1822.4457, 1000.3405, 355.5393},
    {4,  1282.0646, -1140.2067, 980.0524, 1.5357},
    {8,  2008.8319, -1698.8461, 1165.7001, 88.6156},
    {9,  1178.3398, -419.0833, 1234.7045, 177.8144},
    {11, 2184.1011, -1130.3905, 1128.7655, 265.1024},
    {2,  1434.0806, -1832.7854, 1313.5573, 267.1467},
    {7,  925.0102, -496.8101, 843.8953, 88.8976},
    {3,  828.6323, -1014.0038, 799.9664, 266.5594},
    {5,  1320.1091, -167.6174, 1088.0741, 89.3401},
    {1,  1834.2408, -1278.7684, 832.1602, 177.6579},
    {5,  2654.4524, -1023.7827, 929.9266, 180.4350},
    {1,  244.0626,  304.9826,   999.1484, 270.4359},
    {1, 1417.2693,-18.4743,1000.9266,89.4260},
    {10, 2259.7542,-1136.0293,1050.6328,271.4703},
    {3, 2495.9561,-1692.3522,1014.7422,179.3060},
    {3, 235.2513,1187.0618,1080.2578,1.5732},
    {2, 225.3744,1239.9326,1082.1406,91.4331},
    {5, 226.9044,1114.2283,1080.9961,270.5323},
    {4, 310.8174,313.8372,1003.3047,90.7227},
    {5, 1298.8762,-796.5984,1084.0078,359.3316}
};

new const g_BusinessInteriors[][e_InteriorList] =
{
	{0,  0000.0000, 0000.0000, 0000.0000, 000.0000},
	{17, -25.884498, -185.868988, 1003.546875, 0.0},
	{10, 6.091179,-29.271898,1003.549438, 0.0},
	{1, 286.148986,-40.644397,1001.515625, 0.0},
	{7, 314.820983,-141.431991,999.601562, 0.0},
	{3, 1038.531372,0.111030,1001.284484, 0.0},
	{15, 2215.454833,-1147.475585,1025.796875, 0.0},
	{3, 833.269775,10.588416,1004.179687, 0.0},
	{3, -103.559165,-24.225606,1000.718750, 0.0},
	{6, -2240.468505,137.060440,1035.414062, 0.0},
	{0, 663.836242,-575.605407,16.343263, 0.0},
	{1, 2169.461181,1618.798339,999.976562, 0.0},
	{1, -2159.122802,641.517517,1052.381713, 0.0},
	{15, 207.737991,-109.019996,1005.132812, 0.0},
	{14, 204.332992,-166.694992,1000.523437, 0.0},
	{17, 207.054992,-138.804992,1003.507812, 0.0},
	{11, 501.980987,-69.150199,998.757812, 0.0},
	{18, -227.027999,1401.229980,27.765625, 0.0},
	{4, 457.304748,-88.428497,999.554687, 0.0},
	{10, 375.962463,-65.816848,1001.507812, 0.0},
	{9, 369.579528,-4.487294,1001.858886, 0.0},
	{5, 373.825653,-117.270904,1001.499511, 0.0},
	{5, 772.111999,-3.898649,1000.728820, 0.0},
	{6, 774.213989,-48.924297,1000.585937, 0.0},
	{7, 773.579956,-77.096694,1000.655029, 0.0},
	{3, 1212.019897,-28.663099,1000.953125, 0.0},
	{2, 1204.809936,-11.586799,1000.921875, 0.0},
	{3, 964.106994,-53.205497,1001.124572, 0.0},
	{3, -2640.762939,1406.682006,906.460937, 0.0},
	{1, -794.806396,497.738037,1376.195312, 0.0},
	{0, 2315.952880,-1.618174,26.742187, 0.0}
};

enum E_ANTENNAS
{
	Float:arX,
	Float:arY,
	Float:arZ,
	Float:arRX,
	Float:arRY,
	Float:arRZ,
	arObject
};

static const Float:AntennasRadio[][E_ANTENNAS] =
{
	{1873.5248000, -2329.6567000, 56.7900300, 0.0000000, 0.0000000,	0.0000000},
	{983.4611800, -2159.8096000, 45.2825400, 0.0000000, 0.0000000, 356.9350000},
	{1593.2427000, -1987.8363000, 65.9038400, 0.0000000, 0.0000000,	0.0000000},
	{2807.0779000, -2562.0874000, 45.8178300, 0.0000000, 0.0000000,	0.0000000},
	{287.6870100, -1609.0853000, 146.6050400, 0.0000000, 0.0000000,	351.0390000},
	{742.7111200, -1372.8469000, 57.8810000, 0.0000000, 0.0000000, 0.0000000},
	{914.1608300, -1021.4240000, 143.2434700, 0.0000000, 0.0000000,	0.0000000},
	{1075.1816000,-1537.5150000, 62.0872300, 0.0000000, 0.0000000, 0.0000000},
	{1330.7587000, -1795.5013000, 67.9658700, 0.0000000, 0.0000000,	0.1400000},
	{1721.6172000, -1656.2406000, 74.6659500, 0.0000000, 0.0000000,	0.0000000},
	{1488.5817000, -1266.3929000, 145.9683200, 0.0000000, 0.0000000, 0.0000000},
	{1745.0426000, -1227.5677000, 123.9753300, 0.0000000, 0.0000000, 0.0000000},
	{1830.8950000, -1303.4642000, 163.9231600, 0.0000000, 0.0000000, 358.4670000},
	{2236.6411000, -1117.8912000, 80.8877200, 0.0000000, 0.0000000,	333.8120000},
	{2681.8406000, -1297.0231000, 105.1341000, 0.0000000, 0.0000000, 0.0000000},
	{2845.0032000, -1440.2858000, 54.4231600, 0.0000000, 0.0000000,	0.0000000},
	{2493.2390000, -1903.9171000, 57.8753200, 0.0000000, 0.0000000,	0.0000000},
	{2017.0137000, -1372.7006000, 80.5247300, 0.0000000, 0.0000000,	0.0000000},
	{1458.8198000, -782.0927700, 124.5058400, 0.0000000, 0.0000000,	0.0000000},
	{2575.5464000, -649.3110400, 168.2467500, 0.0000000, 0.0000000,	1.5330000},
	{2625.7988000, 221.4483200, 85.3451400, 0.0000000, 0.0000000, 0.0000000},
	{2804.7646000, 127.8274500, 53.5860900, 0.0000000, 0.0000000, 346.2060000},
	{2751.7217000, 606.7897900, 43.0872300, 0.0000000, 0.0000000, 0.0000000},
	{2385.9048000, 1133.7803000, 66.4466000, 0.0000000, 0.0000000, 0.0000000},
	{2576.4504000, 1432.4124000, 52.6334500, 0.0000000, 0.0000000, 0.0000000},
	{2465.1763000, 2267.1748000, 123.8188300, 0.0000000, 0.0000000,	0.0000000},
	{2816.7488000, 2925.7786000, 72.5324400, 0.0000000, 0.0000000, 0.0000000},
	{2011.4418000, 2916.0891000, 83.9133300, 0.0000000, 0.0000000, 0.0000000},
	{1053.5707000, 2915.9419000, 83.8509500, 0.0000000, 0.0000000, 0.0000000},
	{1765.2372000, 2589.2529000, 43.0013700, 0.0000000, 0.0000000, 0.0000000},
	{1858.9889000, 1976.8081000, 45.9735600, 0.0000000, 0.0000000, 0.0000000},
	{1547.8467000, 1849.8915000, 43.0091000, 0.0000000, 0.0000000, 0.0000000},
	{1147.5680000, 693.0312500, 42.9607800,	 0.0000000, 0.0000000, 0.0000000},
	{933.9601400 , 1476.8508000, 39.0186500, 0.0000000, 0.0000000, 0.0000000},
	{1802.0830000, -422.1296400, 117.8551300, 0.0000000, 0.0000000,	0.0000000},
	{1652.7856000, 404.7159400, 52.4052200, 0.0000000, 0.0000000, 6.1310000},
	{1022.2531000, 270.6766400, 61.8626100, 359.5510000,359.3000000,359.9950000},
	{-51.8132200, -251.7265500, 64.9115500, 0.0000000, 0.0000000, 0.0000000},
	{535.0059800, -469.3061200, 72.6485100, 0.0000000, 0.0000000, 0.4130000},
	{-328.7667500, 1558.0273000, 107.7489200, 0.0000000, 0.0000000,	0.0000000},
	{144.7441400, 1571.5165000, 66.6131100, 0.0000000, 0.0000000, 0.2800000},
	{543.0272800, 1986.1819000, 91.8344600, 0.0000000, 0.0000000, 359.3000000},
	{634.3645000, 2610.6875000, 62.2163500, 0.0000000, 0.0000000, 2.6600000},
	{-679.7687400, 1534.0026000, 114.9654500, 0.0000000, 0.0000000,	0.0000000},
	{-670.5002400, -1772.6312000, 127.1410400, 0.0000000, 0.0000000, 0.0000000},
	{-228.9733400, -2212.3320000, 61.3732000, 0.0000000, 0.0000000,	0.0000000},
	{-420.8356600, -2353.1040000, 121.1058200, 0.0000000, 0.0000000, 0.0000000},
	{-460.6909200, -2644.1189000, 188.0450300, 0.0000000, 0.0000000, 0.0000000},
	{-1536.6974000, -2696.2898000, 91.8902100, 0.0000000, 0.0000000, 0.0000000},
	{-2234.8179000, -2571.8608000, 56.6504800, 0.0000000, 0.0000000, 332.2050000},
	{-2459.0754000, -2651.2615000, 104.0372300, 0.0000000, 0.0000000, 0.0000000},
	{-2520.3657000, -652.9471400, 180.0950900, 0.0000000, 0.0000000, 0.0000000},
	{-1407.2498000, -943.8815300, 231.1748700, 0.0000000, 0.0000000, 0.0000000},
	{-2195.4087000, -42.1375800, 80.0315200, 0.0000000, 0.0000000, 0.0000000},
	{-2706.7393000, 531.0545700, 80.1653500, 0.0000000, 0.0000000, 0.0000000},
	{-1754.4127000, 788.0283800, 199.8450300, 0.0000000, 0.0000000, 0.0000000},
	{-2631.2017000, 1417.5940000, 42.1748200, 0.0000000, 0.0000000, 0.0000000},
	{-2458.2644000, 2534.0676000, 41.6977300, 0.0000000, 0.0000000, 0.0000000},
	{-1512.0822000, 2513.6567000, 61.0867100, 0.0000000, 0.0000000, 0.0000000},
	{-553.2486000, 2610.1523000, 64.8367800, 0.0000000, 0.0000000, 1.5330000}
};

#define MAX_MEALS (30)

enum E_MEALS
{
	mExists,
	mModel,
	mObject,
	Float:mPosX,
	Float:mPosY,
	Float:mPosZ,
	mInterior,
	mWorld,
	mPlayer,
	mEditing
};
new MealInfo[MAX_MEALS][E_MEALS];

new Iterator:Meals<MAX_MEALS>;

#define MAX_CHOPSHOP 15

enum CHOPSHOP_DATA
{
	chopshop_id,
	chopshop_wanted[10],
    Float: chopshop_pos[6],
    chopshop_faction, // can run by a faction, they can
    chopshop_object[2],
    chopshop_money,
    bool:chopshop_exist
}
new chopshop_data[MAX_CHOPSHOP][CHOPSHOP_DATA];

enum E_DEALERSHIP_DATA
{
	eDealershipType,
	eDealershipCategory,
	
	eDealershipModel[128],
	eDealershipModelID,
	
	eDealershipPrice
}

new CatDealershipHolder[MAX_PLAYERS], SubDealershipHolder[MAX_PLAYERS];
new SubDealershipHolderArr[MAX_PLAYERS][200], DealershipInsLevel[MAX_PLAYERS];
new DealershipPlayerCar[MAX_PLAYERS], DealershipTotalCost[MAX_PLAYERS];
new DealershipAlarmLevel[MAX_PLAYERS], DealershipImmobLevel[MAX_PLAYERS];
new DealershipLockLevel[MAX_PLAYERS], DealershipXMR[MAX_PLAYERS];
new DealershipCarColors[MAX_PLAYERS][2], bool:PlayerPurchasingVehicle[MAX_PLAYERS]; 

enum
{	
	DEALERSHIP_CATEGORY_AIRCRAFTS,
	DEALERSHIP_CATEGORY_BOATS,
	DEALERSHIP_CATEGORY_BIKES,
	DEALERSHIP_CATEGORY_TWODOOR,
	DEALERSHIP_CATEGORY_FOURDOOR,
	DEALERSHIP_CATEGORY_CIVIL,
	DEALERSHIP_CATEGORY_HEAVY,
	DEALERSHIP_CATEGORY_VANS,
	DEALERSHIP_CATEGORY_SUV,
	DEALERSHIP_CATEGORY_MUSCLE,
	DEALERSHIP_CATEGORY_RACERS,
	DEALERSHIP_CATEGORY_SPECIAL
}

new g_aDealershipData[][E_DEALERSHIP_DATA] = {
	{0, DEALERSHIP_CATEGORY_AIRCRAFTS, "Maverick", 487, 1500000},
	{1, DEALERSHIP_CATEGORY_BOATS, "Squallo", 446, 200000},
	{2, DEALERSHIP_CATEGORY_BIKES, "Bike", 509, 500},
	{2, DEALERSHIP_CATEGORY_BIKES, "BMX", 481, 500},
	{2, DEALERSHIP_CATEGORY_BIKES, "Mountain_Bike", 510, 1000},
	{2, DEALERSHIP_CATEGORY_BIKES, "Faggio", 462, 8000},
	{2, DEALERSHIP_CATEGORY_BIKES, "FCR-900", 521, 130000},
	{2, DEALERSHIP_CATEGORY_BIKES, "Freeway", 463, 50000},
	{2, DEALERSHIP_CATEGORY_BIKES, "Sanchez", 468, 100000},
	{2, DEALERSHIP_CATEGORY_BIKES, "Wayfarer", 586, 50000},
	{3, DEALERSHIP_CATEGORY_TWODOOR, "Alpha", 602, 250000},
	{3, DEALERSHIP_CATEGORY_TWODOOR, "Blista_Compact", 496, 60000},
	{3, DEALERSHIP_CATEGORY_TWODOOR, "Bravura", 401, 9000},
	{3, DEALERSHIP_CATEGORY_TWODOOR, "Buccaneer", 518, 25000},
	{3, DEALERSHIP_CATEGORY_TWODOOR, "Cadrona", 527, 15000},
	{3, DEALERSHIP_CATEGORY_TWODOOR, "Club", 589, 30000},
	{3, DEALERSHIP_CATEGORY_TWODOOR, "Esperanto", 419, 25000},
	{3, DEALERSHIP_CATEGORY_TWODOOR, "Euros", 587, 250000},
	{3, DEALERSHIP_CATEGORY_TWODOOR, "Feltzer", 533, 90000},
	{3, DEALERSHIP_CATEGORY_TWODOOR, "Fortune", 526, 40000},
	{3, DEALERSHIP_CATEGORY_TWODOOR, "Hermes", 474, 100000},
	{3, DEALERSHIP_CATEGORY_TWODOOR, "Hustler", 545, 70000},
	{3, DEALERSHIP_CATEGORY_TWODOOR, "Majestic", 517, 45000},
	{3, DEALERSHIP_CATEGORY_TWODOOR, "Manana", 410, 10000},
	{3, DEALERSHIP_CATEGORY_TWODOOR, "Picador", 600, 35000},
	{3, DEALERSHIP_CATEGORY_TWODOOR, "Previon", 436, 10000},
	{3, DEALERSHIP_CATEGORY_TWODOOR, "Stallion", 439, 110000},
	{3, DEALERSHIP_CATEGORY_TWODOOR, "Tampa", 549, 20000},
	{3, DEALERSHIP_CATEGORY_TWODOOR, "Virgo", 491, 55000},
	{3, DEALERSHIP_CATEGORY_TWODOOR, "Blade", 536, 50000},
	{3, DEALERSHIP_CATEGORY_TWODOOR, "Broadway", 575, 59000},
	{3, DEALERSHIP_CATEGORY_TWODOOR, "Remington", 534, 45000},
	{3, DEALERSHIP_CATEGORY_TWODOOR, "Slamvan", 535, 75000},
	{3, DEALERSHIP_CATEGORY_TWODOOR, "Tornado", 576, 65000},
	{3, DEALERSHIP_CATEGORY_TWODOOR, "Voodoo", 412, 40000},
	{4, DEALERSHIP_CATEGORY_FOURDOOR, "Admiral", 445, 40000},
	{4, DEALERSHIP_CATEGORY_FOURDOOR, "Glendale", 604, 35000},
	{4, DEALERSHIP_CATEGORY_FOURDOOR, "Elegant", 507, 60000},
	{4, DEALERSHIP_CATEGORY_FOURDOOR, "Greenwood", 492, 15000},
	{4, DEALERSHIP_CATEGORY_FOURDOOR, "Intruder", 546, 19000},
	{4, DEALERSHIP_CATEGORY_FOURDOOR, "Merit", 551, 50000},
	{4, DEALERSHIP_CATEGORY_FOURDOOR, "Nebula", 516, 20000},
	{4, DEALERSHIP_CATEGORY_FOURDOOR, "Oceanic", 467, 35000},
	{4, DEALERSHIP_CATEGORY_FOURDOOR, "Premier", 426, 100000},
	{4, DEALERSHIP_CATEGORY_FOURDOOR, "Primo", 547, 35000},
	{4, DEALERSHIP_CATEGORY_FOURDOOR, "Sentinel", 405, 90000},
	{4, DEALERSHIP_CATEGORY_FOURDOOR, "Stafford", 580, 120000},
	{4, DEALERSHIP_CATEGORY_FOURDOOR, "Stretch", 409, 250000},
	{4, DEALERSHIP_CATEGORY_FOURDOOR, "Sunrise", 550, 110000},
	{4, DEALERSHIP_CATEGORY_FOURDOOR, "Tahoma", 566, 55000},
	{4, DEALERSHIP_CATEGORY_FOURDOOR, "Vincent", 540, 40000},
	{4, DEALERSHIP_CATEGORY_FOURDOOR, "Washington", 421, 60000},
	{4, DEALERSHIP_CATEGORY_FOURDOOR, "Willard", 529, 15000},
	{4, DEALERSHIP_CATEGORY_FOURDOOR, "Savanna", 567, 80000},
	{5, DEALERSHIP_CATEGORY_CIVIL, "Bus", 431, 120000},
	{5, DEALERSHIP_CATEGORY_CIVIL, "Cabbie", 438, 45000},
	{5, DEALERSHIP_CATEGORY_CIVIL, "Taxi", 420, 35000},
	{5, DEALERSHIP_CATEGORY_CIVIL, "Towtruck", 525, 15000},
	{5, DEALERSHIP_CATEGORY_CIVIL, "Trashmaster", 408, 70000},
	{6, DEALERSHIP_CATEGORY_HEAVY, "Benson", 499, 50000},
	{6, DEALERSHIP_CATEGORY_HEAVY, "Boxville", 609, 30000},
	{6, DEALERSHIP_CATEGORY_HEAVY, "Harvester", 532, 100000},
	{6, DEALERSHIP_CATEGORY_HEAVY, "DFT-30", 578, 60000},
	{6, DEALERSHIP_CATEGORY_HEAVY, "Hotdog_Truck", 588, 25000},
	{6, DEALERSHIP_CATEGORY_HEAVY, "Linerunner", 403, 150000},
	{6, DEALERSHIP_CATEGORY_HEAVY, "Mr.Whoopee", 423, 35000},
	{6, DEALERSHIP_CATEGORY_HEAVY, "Mule", 414, 40000}, 
	{6, DEALERSHIP_CATEGORY_HEAVY, "Packer", 443, 75000},
	{6, DEALERSHIP_CATEGORY_HEAVY, "Roadtrain", 515, 150000},
	{6, DEALERSHIP_CATEGORY_HEAVY, "Tanker", 514, 155000},
	{6, DEALERSHIP_CATEGORY_HEAVY, "Yankee", 456, 80000},
	{7, DEALERSHIP_CATEGORY_VANS, "Berkley's_RC_Van", 459, 50000},
	{7, DEALERSHIP_CATEGORY_VANS, "Bobcat", 422, 15000},
	{7, DEALERSHIP_CATEGORY_VANS, "Burrito", 482, 70000},
	{7, DEALERSHIP_CATEGORY_VANS, "Sadler", 605, 16000},
	{7, DEALERSHIP_CATEGORY_VANS, "Moonbeam", 418, 20000},
	{7, DEALERSHIP_CATEGORY_VANS, "Pony", 413, 15000},
	{7, DEALERSHIP_CATEGORY_VANS, "Rumpo", 440, 30000},
	{7, DEALERSHIP_CATEGORY_VANS, "Sadler", 543, 10000},
	{7, DEALERSHIP_CATEGORY_VANS, "Walton", 478, 40000},
	{7, DEALERSHIP_CATEGORY_VANS, "Yosemite", 554, 90000},
	{8, DEALERSHIP_CATEGORY_SUV, "Huntley", 579, 200000},
	{8, DEALERSHIP_CATEGORY_SUV, "Landstalker", 400, 120000},
	{8, DEALERSHIP_CATEGORY_SUV, "Perennial", 404, 60000},
	{8, DEALERSHIP_CATEGORY_SUV, "Rancher", 489, 35000},
	{8, DEALERSHIP_CATEGORY_SUV, "Regina", 479, 40000},
	{8, DEALERSHIP_CATEGORY_SUV, "Romero", 442, 50000},
	{8, DEALERSHIP_CATEGORY_SUV, "Solair", 458, 45000},
	{9, DEALERSHIP_CATEGORY_MUSCLE, "Buffalo", 402, 130000},
	{9, DEALERSHIP_CATEGORY_MUSCLE, "Clover", 542, 25000},
	{9, DEALERSHIP_CATEGORY_MUSCLE, "Phoenix", 603, 90000},
	{9, DEALERSHIP_CATEGORY_MUSCLE, "Sabre", 475, 50000},
	{10, DEALERSHIP_CATEGORY_RACERS, "Banshee", 429, 60000},
	{10, DEALERSHIP_CATEGORY_RACERS, "Bullet", 541, 350000},
	{10, DEALERSHIP_CATEGORY_RACERS, "Cheetah", 415, 450000},
	{10, DEALERSHIP_CATEGORY_RACERS, "Comet", 480, 120000},
	{10, DEALERSHIP_CATEGORY_RACERS, "Elegy", 562, 85000},
	{10, DEALERSHIP_CATEGORY_RACERS, "Flash", 565, 70000},
	{10, DEALERSHIP_CATEGORY_RACERS, "Jester", 559, 40000},
	{10, DEALERSHIP_CATEGORY_RACERS, "Stratum", 561, 50000},
	{10, DEALERSHIP_CATEGORY_RACERS, "Sultan", 560, 250000},
	{10, DEALERSHIP_CATEGORY_RACERS, "Super_GT", 506, 130000},
	{10, DEALERSHIP_CATEGORY_RACERS, "Uranus", 558, 69000},
	{10, DEALERSHIP_CATEGORY_RACERS, "Windsor", 555, 100000},
	{10, DEALERSHIP_CATEGORY_RACERS, "ZR-350", 477, 100000}
};

enum E_DAMAGE_INFO
{
	eDamageTaken,
	eDamageTime,
	
	eDamageWeapon,
	
	eDamageBodypart,
	eDamageArmor,
	
	eDamageBy
}

new DamageInfo[MAX_PLAYERS][100][E_DAMAGE_INFO]; 
new TotalPlayerDamages[MAX_PLAYERS];

enum E_LICENSETEST_INFO
{
	Float: eCheckpointX,
	Float: eCheckpointY,
	Float: eCheckpointZ,
	bool: eFinishLine
}

new LicensetestInfo[][E_LICENSETEST_INFO] = 
{
	{1237.5154, -1572.2375, 13.3828, false},
	{1186.1718, -1572.1316, 13.3828, false},
	{1122.9329, -1572.2052, 13.4022, false},
	{1046.1570, -1569.9575, 13.3828, false},
	{1050.3602, -1506.8011, 13.3906, false},
	{1065.1661, -1416.7653, 13.4577, false},
	{1183.5283, -1405.4906, 13.2156, false},
	{1261.6847, -1405.8959, 13.0086, false},
	{1332.1536, -1405.6932, 13.3703, false},
	{1324.8597, -1486.7848, 13.3828, false},
	{1295.2579, -1561.2516, 13.3906, true}
};

#define MAX_STREET 500

enum E_SA_STREET
{
	street_id,
	street_name[MAX_ZONE_NAME],
	Float: street_area[2],
	area_tag,
	Float: street_size
}

new street_data[MAX_STREET][E_SA_STREET];

enum E_SAZONE_MAIN 
{
    SAZONE_NAME[28],
    Float:SAZONE_AREA[6]
}

enum E_SACITY_MAIN
{
    SACITY_NAME[28],
    Float:SACITY_AREA[6]
}

static const gSACities[][E_SACITY_MAIN] = {

        {"Los Santos",                  {44.60,-2892.90,-242.90,2997.00,-768.00,900.00}},
        {"Las Venturas",                {869.40,596.30,-242.90,2997.00,2993.80,900.00}},
        {"Bone County",                 {-480.50,596.30,-242.90,869.40,2993.80,900.00}},
        {"Tierra Robada",               {-2997.40,1659.60,-242.90,-480.50,2993.80,900.00}},
        {"Tierra Robada",               {-1213.90,596.30,-242.90,-480.50,1659.60,900.00}},
        {"San Fierro",                  {-2997.40,-1115.50,-242.90,-1213.90,1659.60,900.00}},
        {"Red County",                  {-1213.90,-768.00,-242.90,2997.00,596.30,900.00}},
        {"Flint County",                {-1213.90,-2892.90,-242.90,44.60,-768.00,900.00}},
        {"Whetstone",                   {-2997.40,-2892.90,-242.90,-1213.90,-1115.50,900.00}}
        
};

#define MAX_PAYPHONE 	(50)
#define PAYPHONE_STATE_NONE 	(0)
#define PAYPHONE_STATE_INCALL 	(1)
#define PAYPHONE_STATE_RINGING  (2)

enum E_PAYPHONE
{
	bool: payphone_exist,
	payphone_id,
	Float: payphone_pos[6],
	payphone_code,
	payphone_number,
	payphone_numstr[24], // < cache data
	payphone_coin, // coin in payphone, robbery :P
	payphone_state, // 0 = Normal, 1 = in call, 2 = ringing
	Text3D: payphone_text, // only use when a payphone is ringing or state changes
	payphone_model,
	payphone_caller
}
new payphone_data[MAX_PAYPHONE][E_PAYPHONE];

#define MAX_SPRAYS   (50)

enum e_spray_data
{
	spray_id,
	bool:is_exists,
	Float: spray_location[6],
	spray_modelid,
	spray_by[MAX_PLAYER_NAME],
	spray_object
};

new spray_data[MAX_SPRAYS][e_spray_data];

enum spraytag_data
{
	tag_name[64],
	tag_modelid
}

static const g_spraytag[][spraytag_data] =
{
	{"Grove Street Families", 18659},
	{"Seville BLVD Families", 18660},
	{"Varrio Los Aztecas", 	  18661},
	{"Kilo Tray Ballas", 	  18662},
	{"San Fiero Rifa", 		  18663},
	{"Temple Drive Ballas ",  18664},
	{"Los Santos Vagos", 	  18665},
	{"Front Yard Ballaz", 	  18666},
	{"Rollin Heights Ballas", 18667}
};

enum e_font_config
{
	font_name[64]
}

static const font_data[][e_font_config] =
{
	{"Comic Sans MS"},
	{"Levi Brush"},
	{"Dripping"},
	{"Diploma"}
};

//
static const VehicleColoursTableRGBA[256] =
{
	0x000000FF, 0xF5F5F5FF, 0x2A77A1FF, 0x840410FF, 0x263739FF, 0x86446EFF, 0xD78E10FF, 0x4C75B7FF, 0xBDBEC6FF, 0x5E7072FF,
	0x46597AFF, 0x656A79FF, 0x5D7E8DFF, 0x58595AFF, 0xD6DAD6FF, 0x9CA1A3FF, 0x335F3FFF, 0x730E1AFF, 0x7B0A2AFF, 0x9F9D94FF,
	0x3B4E78FF, 0x732E3EFF, 0x691E3BFF, 0x96918CFF, 0x515459FF, 0x3F3E45FF, 0xA5A9A7FF, 0x635C5AFF, 0x3D4A68FF, 0x979592FF,
	0x421F21FF, 0x5F272BFF, 0x8494ABFF, 0x767B7CFF, 0x646464FF, 0x5A5752FF, 0x252527FF, 0x2D3A35FF, 0x93A396FF, 0x6D7A88FF,
	0x221918FF, 0x6F675FFF, 0x7C1C2AFF, 0x5F0A15FF, 0x193826FF, 0x5D1B20FF, 0x9D9872FF, 0x7A7560FF, 0x989586FF, 0xADB0B0FF,
	0x848988FF, 0x304F45FF, 0x4D6268FF, 0x162248FF, 0x272F4BFF, 0x7D6256FF, 0x9EA4ABFF, 0x9C8D71FF, 0x6D1822FF, 0x4E6881FF,
	0x9C9C98FF, 0x917347FF, 0x661C26FF, 0x949D9FFF, 0xA4A7A5FF, 0x8E8C46FF, 0x341A1EFF, 0x6A7A8CFF, 0xAAAD8EFF, 0xAB988FFF,
	0x851F2EFF, 0x6F8297FF, 0x585853FF, 0x9AA790FF, 0x601A23FF, 0x20202CFF, 0xA4A096FF, 0xAA9D84FF, 0x78222BFF, 0x0E316DFF,
	0x722A3FFF, 0x7B715EFF, 0x741D28FF, 0x1E2E32FF, 0x4D322FFF, 0x7C1B44FF, 0x2E5B20FF, 0x395A83FF, 0x6D2837FF, 0xA7A28FFF,
	0xAFB1B1FF, 0x364155FF, 0x6D6C6EFF, 0x0F6A89FF, 0x204B6BFF, 0x2B3E57FF, 0x9B9F9DFF, 0x6C8495FF, 0x4D8495FF, 0xAE9B7FFF,
	0x406C8FFF, 0x1F253BFF, 0xAB9276FF, 0x134573FF, 0x96816CFF, 0x64686AFF, 0x105082FF, 0xA19983FF, 0x385694FF, 0x525661FF,
	0x7F6956FF, 0x8C929AFF, 0x596E87FF, 0x473532FF, 0x44624FFF, 0x730A27FF, 0x223457FF, 0x640D1BFF, 0xA3ADC6FF, 0x695853FF,
	0x9B8B80FF, 0x620B1CFF, 0x5B5D5EFF, 0x624428FF, 0x731827FF, 0x1B376DFF, 0xEC6AAEFF, 0x000000FF,
	0x177517FF, 0x210606FF, 0x125478FF, 0x452A0DFF, 0x571E1EFF, 0x010701FF, 0x25225AFF, 0x2C89AAFF, 0x8A4DBDFF, 0x35963AFF,
	0xB7B7B7FF, 0x464C8DFF, 0x84888CFF, 0x817867FF, 0x817A26FF, 0x6A506FFF, 0x583E6FFF, 0x8CB972FF, 0x824F78FF, 0x6D276AFF,
	0x1E1D13FF, 0x1E1306FF, 0x1F2518FF, 0x2C4531FF, 0x1E4C99FF, 0x2E5F43FF, 0x1E9948FF, 0x1E9999FF, 0x999976FF, 0x7C8499FF,
	0x992E1EFF, 0x2C1E08FF, 0x142407FF, 0x993E4DFF, 0x1E4C99FF, 0x198181FF, 0x1A292AFF, 0x16616FFF, 0x1B6687FF, 0x6C3F99FF,
	0x481A0EFF, 0x7A7399FF, 0x746D99FF, 0x53387EFF, 0x222407FF, 0x3E190CFF, 0x46210EFF, 0x991E1EFF, 0x8D4C8DFF, 0x805B80FF,
	0x7B3E7EFF, 0x3C1737FF, 0x733517FF, 0x781818FF, 0x83341AFF, 0x8E2F1CFF, 0x7E3E53FF, 0x7C6D7CFF, 0x020C02FF, 0x072407FF,
	0x163012FF, 0x16301BFF, 0x642B4FFF, 0x368452FF, 0x999590FF, 0x818D96FF, 0x99991EFF, 0x7F994CFF, 0x839292FF, 0x788222FF,
	0x2B3C99FF, 0x3A3A0BFF, 0x8A794EFF, 0x0E1F49FF, 0x15371CFF, 0x15273AFF, 0x375775FF, 0x060820FF, 0x071326FF, 0x20394BFF,
	0x2C5089FF, 0x15426CFF, 0x103250FF, 0x241663FF, 0x692015FF, 0x8C8D94FF, 0x516013FF, 0x090F02FF, 0x8C573AFF, 0x52888EFF,
	0x995C52FF, 0x99581EFF, 0x993A63FF, 0x998F4EFF, 0x99311EFF, 0x0D1842FF, 0x521E1EFF, 0x42420DFF, 0x4C991EFF, 0x082A1DFF,
	0x96821DFF, 0x197F19FF, 0x3B141FFF, 0x745217FF, 0x893F8DFF, 0x7E1A6CFF, 0x0B370BFF, 0x27450DFF, 0x071F24FF, 0x784573FF,
	0x8A653AFF, 0x732617FF, 0x319490FF, 0x56941DFF, 0x59163DFF, 0x1B8A2FFF, 0x38160BFF, 0x041804FF, 0x355D8EFF, 0x2E3F5BFF,
	0x561A28FF, 0x4E0E27FF, 0x706C67FF, 0x3B3E42FF, 0x2E2D33FF, 0x7B7E7DFF, 0x4A4442FF, 0x28344EFF
};

enum G_DEALERSHIP_DATA
{
    dealerType,
	dealerName[24],
	dealerModel
}

static const g_aDealershipCategory[][G_DEALERSHIP_DATA] = {
	{DEALERSHIP_CATEGORY_AIRCRAFTS, "Airplanes", 520},
	{DEALERSHIP_CATEGORY_BOATS, "Boats", 521},
	{DEALERSHIP_CATEGORY_BIKES, "Bikes", 596},
	{DEALERSHIP_CATEGORY_TWODOOR, "Compact_cars", 597},
	{DEALERSHIP_CATEGORY_FOURDOOR, "Luxury_cars", 598},
	{DEALERSHIP_CATEGORY_CIVIL, "Civil_Service", 520},
	{DEALERSHIP_CATEGORY_HEAVY, "Heavy_&_Utility Trucks", 451},
	{DEALERSHIP_CATEGORY_VANS, "Light_trucks & Vans", 560},
	{DEALERSHIP_CATEGORY_SUV, "SUVs_&_Wagons", 562},
	{DEALERSHIP_CATEGORY_MUSCLE, "Muscle_Cars", 579},
	{DEALERSHIP_CATEGORY_RACERS, "Street_Racers", 555},
	{DEALERSHIP_CATEGORY_SPECIAL, "Special_Traffic", 456}
};

static const s_TopSpeed[212] = {
    157, 147, 186, 110, 133, 164, 110, 148, 100, 158, 129, 221, 168, 110, 105, 192, 154, 270,
    115, 149, 145, 154, 140, 99, 135, 270, 173, 165, 157, 201, 190, 130, 94, 110, 167, 0, 149,
    158, 142, 168, 136, 145, 139, 126, 110, 164, 270, 270, 111, 0, 0, 193, 270, 60, 135, 157,
    106, 95, 157, 136, 270, 160, 111, 142, 145, 145, 147, 140, 144, 270, 157, 110, 190, 190,
    149, 173, 270, 186, 117, 140, 184, 73, 156, 122, 190, 99, 64, 270, 270, 139, 157, 149, 140,
    270, 214, 176, 162, 270, 108, 123, 140, 145, 216, 216, 173, 140, 179, 166, 108, 79, 101, 270,
    270, 270, 120, 142, 157, 157, 164, 270, 270, 160, 176, 151, 130, 160, 158, 149, 176, 149, 60,
    70, 110, 167, 168, 158, 173, 0, 0, 270, 149, 203, 164, 151, 150, 147, 149, 142, 270, 153, 145,
    157, 121, 270, 144, 158, 113, 113, 156, 178, 169, 154, 178, 270, 145, 165, 160, 173, 146, 0, 0,
    93, 60, 110, 60, 158, 158, 270, 130, 158, 153, 151, 136, 85, 0, 153, 142, 165, 108, 162, 0, 0,
    270, 270, 130, 190, 175, 175, 175, 158, 151, 110, 169, 171, 148, 152, 0, 0, 0, 108, 0, 0
}; //Credits to Emmet (Extended Vehicle function)

//tuning
#define MAX_TUNING_COMPONENTS           (14)
#define EXTERIOR_TUNING_X 				(418.0252)
#define EXTERIOR_TUNING_Y 				(-1324.3462)
#define EXTERIOR_TUNING_Z 				(14.9415)

#define INTERIOR_TUNING_X 				(434.0549)
#define INTERIOR_TUNING_Y 				(-1299.4264)
#define INTERIOR_TUNING_Z 				(15.3104)

static const Float:RandomTuningSpawn[][] =
{
    {345.8079, -1358.1921, 14.1357, 118.4599},
	{344.5041, -1355.7866, 14.1322, 118.4599},
	{343.1835, -1353.3506, 14.1286, 118.4599},
	{341.8597, -1350.9081, 14.1250, 118.4599},
	{340.5688, -1348.5264, 14.1215, 118.4599},
	{339.2497, -1346.0927, 14.1179, 118.4599},
	{338.0098, -1343.8055, 14.1145, 118.4599},
	{336.7597, -1341.4994, 14.1111, 118.4599}
};

static const TuningCategories[11][32] =
{
	"Spoiler",
	"Air-vents",
	"Exhaust",
	"Bumper A",
	"Bumper P",
	"Roof",
	"Wheels",
	"Hydraulic",
	"Nitro",
	"Side Skirts",
	"Paintjob"
};

//
new possibleVehiclePlates[][] = 
	{"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"};
	
static const g_aPreloadLibs[][] =
{
	"AIRPORT",      "ATTRACTORS",   "BAR",          "BASEBALL",     "BD_FIRE",
	"BEACH",        "BENCHPRESS",   "BF_INJECTION", "BIKE_DBZ",     "BIKED",
	"BIKEH",        "BIKELEAP",     "BIKES",        "BIKEV",        "BLOWJOBZ",
	"BMX",          "BOMBER",       "BOX",          "BSKTBALL",     "BUDDY",
	"BUS",          "CAMERA",       "CAR",          "CAR_CHAT",     "CARRY",
	"CASINO",       "CHAINSAW",     "CHOPPA",       "CLOTHES",      "COACH",
	"COLT45",       "COP_AMBIENT",  "COP_DVBYZ",    "CRACK",        "CRIB",
	"DAM_JUMP",     "DANCING",      "DEALER",       "DILDO",        "DODGE",
	"DOZER",        "DRIVEBYS",     "FAT",          "FIGHT_B",      "FIGHT_C",
	"FIGHT_D",      "FIGHT_E",      "FINALE",       "FINALE2",      "FLAME",
	"FLOWERS",      "FOOD",         "FREEWEIGHTS",  "GANGS",        "GFUNK",
	"GHANDS",       "GHETTO_DB",    "GOGGLES",      "GRAFFITI",     "GRAVEYARD",
	"GRENADE",      "GYMNASIUM",    "HAIRCUTS",     "HEIST9",       "INT_HOUSE",
	"INT_OFFICE",   "INT_SHOP",     "JST_BUISNESS", "KART",         "KISSING",
	"KNIFE",        "LAPDAN1",      "LAPDAN2",      "LAPDAN3",      "LOWRIDER",
	"MD_CHASE",     "MD_END",       "MEDIC",        "MISC",         "MTB",
	"MUSCULAR",     "NEVADA",       "ON_LOOKERS",   "OTB",          "PARACHUTE",
	"PARK",         "PAULNMAC",     "PED",          "PLAYER_DVBYS", "PLAYIDLES",
	"POLICE",       "POOL",         "POOR",         "PYTHON",       "QUAD",
	"QUAD_DBZ",     "RAPPING",      "RIFLE",        "RIOT",         "ROB_BANK",
	"ROCKET",       "RUNNINGMAN",   "RUSTLER",      "RYDER",        "SCRATCHING",
	"SEX",          "SHAMAL",       "SHOP",         "SHOTGUN",      "SILENCED",
	"SKATE",        "SMOKING",      "SNIPER",       "SNM",          "SPRAYCAN",
	"STRIP",        "SUNBATHE",     "SWAT",         "SWEET",        "SWIM",
	"SWORD",        "TANK",         "TATTOOS",      "TEC",          "TRAIN",
	"TRUCK",        "UZI",          "VAN",          "VENDING",      "VORTEX",
	"WAYFARER",     "WEAPONS",      "WOP",          "WUZI"
};

static const gSAZones[][E_SAZONE_MAIN] = {  // Majority of names and area coordinates adopted from Mabako's 'Zones Script' v0.2
        //      NAME                            AREA (Xmin,Ymin,Zmin,Xmax,Ymax,Zmax)
        {"The Big Ear",                 {-410.00,1403.30,-3.00,-137.90,1681.20,200.00}},
        {"Aldea Malvada",               {-1372.10,2498.50,0.00,-1277.50,2615.30,200.00}},
        {"Angel Pine",                  {-2324.90,-2584.20,-6.10,-1964.20,-2212.10,200.00}},
        {"Arco del Oeste",              {-901.10,2221.80,0.00,-592.00,2571.90,200.00}},
        {"Avispa Country Club",         {-2646.40,-355.40,0.00,-2270.00,-222.50,200.00}},
        {"Avispa Country Club",         {-2831.80,-430.20,-6.10,-2646.40,-222.50,200.00}},
        {"Avispa Country Club",         {-2361.50,-417.10,0.00,-2270.00,-355.40,200.00}},
        {"Avispa Country Club",         {-2667.80,-302.10,-28.80,-2646.40,-262.30,71.10}},
        {"Avispa Country Club",         {-2470.00,-355.40,0.00,-2270.00,-318.40,46.10}},
        {"Avispa Country Club",         {-2550.00,-355.40,0.00,-2470.00,-318.40,39.70}},
        {"Back o Beyond",               {-1166.90,-2641.10,0.00,-321.70,-1856.00,200.00}},
        {"Battery Point",               {-2741.00,1268.40,-4.50,-2533.00,1490.40,200.00}},
        {"Bayside",                     {-2741.00,2175.10,0.00,-2353.10,2722.70,200.00}},
        {"Bayside Marina",              {-2353.10,2275.70,0.00,-2153.10,2475.70,200.00}},
        {"Beacon Hill",                 {-399.60,-1075.50,-1.40,-319.00,-977.50,198.50}},
        {"Blackfield",                  {964.30,1203.20,-89.00,1197.30,1403.20,110.90}},
        {"Blackfield",                  {964.30,1403.20,-89.00,1197.30,1726.20,110.90}},
        {"Blackfield Chapel",           {1375.60,596.30,-89.00,1558.00,823.20,110.90}},
        {"Blackfield Chapel",           {1325.60,596.30,-89.00,1375.60,795.00,110.90}},
        {"Blackfield Intersection",     {1197.30,1044.60,-89.00,1277.00,1163.30,110.90}},
        {"Blackfield Intersection",     {1166.50,795.00,-89.00,1375.60,1044.60,110.90}},
        {"Blackfield Intersection",     {1277.00,1044.60,-89.00,1315.30,1087.60,110.90}},
        {"Blackfield Intersection",     {1375.60,823.20,-89.00,1457.30,919.40,110.90}},
        {"Blueberry",                   {104.50,-220.10,2.30,349.60,152.20,200.00}},
        {"Blueberry",                   {19.60,-404.10,3.80,349.60,-220.10,200.00}},
        {"Blueberry Acres",             {-319.60,-220.10,0.00,104.50,293.30,200.00}},
        {"Caligula's Palace",           {2087.30,1543.20,-89.00,2437.30,1703.20,110.90}},
        {"Caligula's Palace",           {2137.40,1703.20,-89.00,2437.30,1783.20,110.90}},
        {"Calton Heights",              {-2274.10,744.10,-6.10,-1982.30,1358.90,200.00}},
        {"Chinatown",                   {-2274.10,578.30,-7.60,-2078.60,744.10,200.00}},
        {"City Hall",                   {-2867.80,277.40,-9.10,-2593.40,458.40,200.00}},
        {"Come-A-Lot",                  {2087.30,943.20,-89.00,2623.10,1203.20,110.90}},
        {"Commerce",                    {1323.90,-1842.20,-89.00,1701.90,-1722.20,110.90}},
        {"Commerce",                    {1323.90,-1722.20,-89.00,1440.90,-1577.50,110.90}},
        {"Commerce",                    {1370.80,-1577.50,-89.00,1463.90,-1384.90,110.90}},
        {"Commerce",                    {1463.90,-1577.50,-89.00,1667.90,-1430.80,110.90}},
        {"Commerce",                    {1583.50,-1722.20,-89.00,1758.90,-1577.50,110.90}},
        {"Commerce",                    {1667.90,-1577.50,-89.00,1812.60,-1430.80,110.90}},
        {"Conference Center",           {1046.10,-1804.20,-89.00,1323.90,-1722.20,110.90}},
        {"Conference Center",           {1073.20,-1842.20,-89.00,1323.90,-1804.20,110.90}},
        {"Cranberry Station",           {-2007.80,56.30,0.00,-1922.00,224.70,100.00}},
        {"Creek",                       {2749.90,1937.20,-89.00,2921.60,2669.70,110.90}},
        {"Dillimore",                   {580.70,-674.80,-9.50,861.00,-404.70,200.00}},
        {"Doherty",                     {-2270.00,-324.10,-0.00,-1794.90,-222.50,200.00}},
        {"Doherty",                     {-2173.00,-222.50,-0.00,-1794.90,265.20,200.00}},
        {"Downtown",                    {-1982.30,744.10,-6.10,-1871.70,1274.20,200.00}},
        {"Downtown",                    {-1871.70,1176.40,-4.50,-1620.30,1274.20,200.00}},
        {"Downtown",                    {-1700.00,744.20,-6.10,-1580.00,1176.50,200.00}},
        {"Downtown",                    {-1580.00,744.20,-6.10,-1499.80,1025.90,200.00}},
        {"Downtown",                    {-2078.60,578.30,-7.60,-1499.80,744.20,200.00}},
        {"Downtown",                    {-1993.20,265.20,-9.10,-1794.90,578.30,200.00}},
        {"Downtown Los Santos",         {1463.90,-1430.80,-89.00,1724.70,-1290.80,110.90}},
        {"Downtown Los Santos",         {1724.70,-1430.80,-89.00,1812.60,-1250.90,110.90}},
        {"Downtown Los Santos",         {1463.90,-1290.80,-89.00,1724.70,-1150.80,110.90}},
        {"Downtown Los Santos",         {1370.80,-1384.90,-89.00,1463.90,-1170.80,110.90}},
        {"Downtown Los Santos",         {1724.70,-1250.90,-89.00,1812.60,-1150.80,110.90}},
        {"Downtown Los Santos",         {1370.80,-1170.80,-89.00,1463.90,-1130.80,110.90}},
        {"Downtown Los Santos",         {1378.30,-1130.80,-89.00,1463.90,-1026.30,110.90}},
        {"Downtown Los Santos",         {1391.00,-1026.30,-89.00,1463.90,-926.90,110.90}},
        {"Downtown Los Santos",         {1507.50,-1385.20,110.90,1582.50,-1325.30,335.90}},
        {"East Beach",                  {2632.80,-1852.80,-89.00,2959.30,-1668.10,110.90}},
        {"East Beach",                  {2632.80,-1668.10,-89.00,2747.70,-1393.40,110.90}},
        {"East Beach",                  {2747.70,-1668.10,-89.00,2959.30,-1498.60,110.90}},
        {"East Beach",                  {2747.70,-1498.60,-89.00,2959.30,-1120.00,110.90}},
        {"East Los Santos",             {2421.00,-1628.50,-89.00,2632.80,-1454.30,110.90}},
        {"East Los Santos",             {2222.50,-1628.50,-89.00,2421.00,-1494.00,110.90}},
        {"East Los Santos",             {2266.20,-1494.00,-89.00,2381.60,-1372.00,110.90}},
        {"East Los Santos",             {2381.60,-1494.00,-89.00,2421.00,-1454.30,110.90}},
        {"East Los Santos",             {2281.40,-1372.00,-89.00,2381.60,-1135.00,110.90}},
        {"East Los Santos",             {2381.60,-1454.30,-89.00,2462.10,-1135.00,110.90}},
        {"East Los Santos",             {2462.10,-1454.30,-89.00,2581.70,-1135.00,110.90}},
        {"Easter Basin",                {-1794.90,249.90,-9.10,-1242.90,578.30,200.00}},
        {"Easter Basin",                {-1794.90,-50.00,-0.00,-1499.80,249.90,200.00}},
        {"Easter Bay Airport",          {-1499.80,-50.00,-0.00,-1242.90,249.90,200.00}},
        {"Easter Bay Airport",          {-1794.90,-730.10,-3.00,-1213.90,-50.00,200.00}},
        {"Easter Bay Airport",          {-1213.90,-730.10,0.00,-1132.80,-50.00,200.00}},
        {"Easter Bay Airport",          {-1242.90,-50.00,0.00,-1213.90,578.30,200.00}},
        {"Easter Bay Airport",          {-1213.90,-50.00,-4.50,-947.90,578.30,200.00}},
        {"Easter Bay Airport",          {-1315.40,-405.30,15.40,-1264.40,-209.50,25.40}},
        {"Easter Bay Airport",          {-1354.30,-287.30,15.40,-1315.40,-209.50,25.40}},
        {"Easter Bay Airport",          {-1490.30,-209.50,15.40,-1264.40,-148.30,25.40}},
        {"Easter Bay Chemicals",        {-1132.80,-768.00,0.00,-956.40,-578.10,200.00}},
        {"Easter Bay Chemicals",        {-1132.80,-787.30,0.00,-956.40,-768.00,200.00}},
        {"El Castillo del Diablo",      {-464.50,2217.60,0.00,-208.50,2580.30,200.00}},
        {"El Castillo del Diablo",      {-208.50,2123.00,-7.60,114.00,2337.10,200.00}},
        {"El Castillo del Diablo",      {-208.50,2337.10,0.00,8.40,2487.10,200.00}},
        {"El Corona",                   {1812.60,-2179.20,-89.00,1970.60,-1852.80,110.90}},
        {"El Corona",                   {1692.60,-2179.20,-89.00,1812.60,-1842.20,110.90}},
        {"El Quebrados",                {-1645.20,2498.50,0.00,-1372.10,2777.80,200.00}},
        {"Esplanade East",              {-1620.30,1176.50,-4.50,-1580.00,1274.20,200.00}},
        {"Esplanade East",              {-1580.00,1025.90,-6.10,-1499.80,1274.20,200.00}},
        {"Esplanade East",              {-1499.80,578.30,-79.60,-1339.80,1274.20,20.30}},
        {"Esplanade North",             {-2533.00,1358.90,-4.50,-1996.60,1501.20,200.00}},
        {"Esplanade North",             {-1996.60,1358.90,-4.50,-1524.20,1592.50,200.00}},
        {"Esplanade North",             {-1982.30,1274.20,-4.50,-1524.20,1358.90,200.00}},
        {"Fallen Tree",                 {-792.20,-698.50,-5.30,-452.40,-380.00,200.00}},
        {"Fallow Bridge",               {434.30,366.50,0.00,603.00,555.60,200.00}},
        {"Fern Ridge",                  {508.10,-139.20,0.00,1306.60,119.50,200.00}},
        {"Financial",                   {-1871.70,744.10,-6.10,-1701.30,1176.40,300.00}},
        {"Fisher's Lagoon",             {1916.90,-233.30,-100.00,2131.70,13.80,200.00}},
        {"Flint Intersection",          {-187.70,-1596.70,-89.00,17.00,-1276.60,110.90}},
        {"Flint Range",                 {-594.10,-1648.50,0.00,-187.70,-1276.60,200.00}},
        {"Fort Carson",                 {-376.20,826.30,-3.00,123.70,1220.40,200.00}},
        {"Foster Valley",               {-2270.00,-430.20,-0.00,-2178.60,-324.10,200.00}},
        {"Foster Valley",               {-2178.60,-599.80,-0.00,-1794.90,-324.10,200.00}},
        {"Foster Valley",               {-2178.60,-1115.50,0.00,-1794.90,-599.80,200.00}},
        {"Foster Valley",               {-2178.60,-1250.90,0.00,-1794.90,-1115.50,200.00}},
        {"Frederick Bridge",            {2759.20,296.50,0.00,2774.20,594.70,200.00}},
        {"Gant Bridge",                 {-2741.40,1659.60,-6.10,-2616.40,2175.10,200.00}},
        {"Gant Bridge",                 {-2741.00,1490.40,-6.10,-2616.40,1659.60,200.00}},
        {"Ganton",                      {2222.50,-1852.80,-89.00,2632.80,-1722.30,110.90}},
        {"Ganton",                      {2222.50,-1722.30,-89.00,2632.80,-1628.50,110.90}},
        {"Garcia",                      {-2411.20,-222.50,-0.00,-2173.00,265.20,200.00}},
        {"Garcia",                      {-2395.10,-222.50,-5.30,-2354.00,-204.70,200.00}},
        {"Garver Bridge",               {-1339.80,828.10,-89.00,-1213.90,1057.00,110.90}},
        {"Garver Bridge",               {-1213.90,950.00,-89.00,-1087.90,1178.90,110.90}},
        {"Garver Bridge",               {-1499.80,696.40,-179.60,-1339.80,925.30,20.30}},
        {"Glen Park",                   {1812.60,-1449.60,-89.00,1996.90,-1350.70,110.90}},
        {"Glen Park",                   {1812.60,-1100.80,-89.00,1994.30,-973.30,110.90}},
        {"Glen Park",                   {1812.60,-1350.70,-89.00,2056.80,-1100.80,110.90}},
        {"Green Palms",                 {176.50,1305.40,-3.00,338.60,1520.70,200.00}},
        {"Greenglass College",          {964.30,1044.60,-89.00,1197.30,1203.20,110.90}},
        {"Greenglass College",          {964.30,930.80,-89.00,1166.50,1044.60,110.90}},
        {"Hampton Barns",               {603.00,264.30,0.00,761.90,366.50,200.00}},
        {"Hankypanky Point",            {2576.90,62.10,0.00,2759.20,385.50,200.00}},
        {"Harry Gold Parkway",          {1777.30,863.20,-89.00,1817.30,2342.80,110.90}},
        {"Hashbury",                    {-2593.40,-222.50,-0.00,-2411.20,54.70,200.00}},
        {"Hilltop Farm",                {967.30,-450.30,-3.00,1176.70,-217.90,200.00}},
        {"Hunter Quarry",               {337.20,710.80,-115.20,860.50,1031.70,203.70}},
        {"Idlewood",                    {1812.60,-1852.80,-89.00,1971.60,-1742.30,110.90}},
        {"Idlewood",                    {1812.60,-1742.30,-89.00,1951.60,-1602.30,110.90}},
        {"Idlewood",                    {1951.60,-1742.30,-89.00,2124.60,-1602.30,110.90}},
        {"Idlewood",                    {1812.60,-1602.30,-89.00,2124.60,-1449.60,110.90}},
        {"Idlewood",                    {2124.60,-1742.30,-89.00,2222.50,-1494.00,110.90}},
        {"Idlewood",                    {1971.60,-1852.80,-89.00,2222.50,-1742.30,110.90}},
        {"Jefferson",                   {1996.90,-1449.60,-89.00,2056.80,-1350.70,110.90}},
        {"Jefferson",                   {2124.60,-1494.00,-89.00,2266.20,-1449.60,110.90}},
        {"Jefferson",                   {2056.80,-1372.00,-89.00,2281.40,-1210.70,110.90}},
        {"Jefferson",                   {2056.80,-1210.70,-89.00,2185.30,-1126.30,110.90}},
        {"Jefferson",                   {2185.30,-1210.70,-89.00,2281.40,-1154.50,110.90}},
        {"Jefferson",                   {2056.80,-1449.60,-89.00,2266.20,-1372.00,110.90}},
        {"Julius Thruway East",         {2623.10,943.20,-89.00,2749.90,1055.90,110.90}},
        {"Julius Thruway East",         {2685.10,1055.90,-89.00,2749.90,2626.50,110.90}},
        {"Julius Thruway East",         {2536.40,2442.50,-89.00,2685.10,2542.50,110.90}},
        {"Julius Thruway East",         {2625.10,2202.70,-89.00,2685.10,2442.50,110.90}},
        {"Julius Thruway North",        {2498.20,2542.50,-89.00,2685.10,2626.50,110.90}},
        {"Julius Thruway North",        {2237.40,2542.50,-89.00,2498.20,2663.10,110.90}},
        {"Julius Thruway North",        {2121.40,2508.20,-89.00,2237.40,2663.10,110.90}},
        {"Julius Thruway North",        {1938.80,2508.20,-89.00,2121.40,2624.20,110.90}},
        {"Julius Thruway North",        {1534.50,2433.20,-89.00,1848.40,2583.20,110.90}},
        {"Julius Thruway North",        {1848.40,2478.40,-89.00,1938.80,2553.40,110.90}},
        {"Julius Thruway North",        {1704.50,2342.80,-89.00,1848.40,2433.20,110.90}},
        {"Julius Thruway North",        {1377.30,2433.20,-89.00,1534.50,2507.20,110.90}},
        {"Julius Thruway South",        {1457.30,823.20,-89.00,2377.30,863.20,110.90}},
        {"Julius Thruway South",        {2377.30,788.80,-89.00,2537.30,897.90,110.90}},
        {"Julius Thruway West",         {1197.30,1163.30,-89.00,1236.60,2243.20,110.90}},
        {"Julius Thruway West",         {1236.60,2142.80,-89.00,1297.40,2243.20,110.90}},
        {"Juniper Hill",                {-2533.00,578.30,-7.60,-2274.10,968.30,200.00}},
        {"Juniper Hollow",              {-2533.00,968.30,-6.10,-2274.10,1358.90,200.00}},
        {"K.A.C.C. Military Fuels",     {2498.20,2626.50,-89.00,2749.90,2861.50,110.90}},
        {"Kincaid Bridge",              {-1339.80,599.20,-89.00,-1213.90,828.10,110.90}},
        {"Kincaid Bridge",              {-1213.90,721.10,-89.00,-1087.90,950.00,110.90}},
        {"Kincaid Bridge",              {-1087.90,855.30,-89.00,-961.90,986.20,110.90}},
        {"King's",                      {-2329.30,458.40,-7.60,-1993.20,578.30,200.00}},
        {"King's",                      {-2411.20,265.20,-9.10,-1993.20,373.50,200.00}},
        {"King's",                      {-2253.50,373.50,-9.10,-1993.20,458.40,200.00}},
        {"LVA Freight Depot",           {1457.30,863.20,-89.00,1777.40,1143.20,110.90}},
        {"LVA Freight Depot",           {1375.60,919.40,-89.00,1457.30,1203.20,110.90}},
        {"LVA Freight Depot",           {1277.00,1087.60,-89.00,1375.60,1203.20,110.90}},
        {"LVA Freight Depot",           {1315.30,1044.60,-89.00,1375.60,1087.60,110.90}},
        {"LVA Freight Depot",           {1236.60,1163.40,-89.00,1277.00,1203.20,110.90}},
        {"Las Barrancas",               {-926.10,1398.70,-3.00,-719.20,1634.60,200.00}},
        {"Las Brujas",                  {-365.10,2123.00,-3.00,-208.50,2217.60,200.00}},
        {"Las Colinas",                 {1994.30,-1100.80,-89.00,2056.80,-920.80,110.90}},
        {"Las Colinas",                 {2056.80,-1126.30,-89.00,2126.80,-920.80,110.90}},
        {"Las Colinas",                 {2185.30,-1154.50,-89.00,2281.40,-934.40,110.90}},
        {"Las Colinas",                 {2126.80,-1126.30,-89.00,2185.30,-934.40,110.90}},
        {"Las Colinas",                 {2747.70,-1120.00,-89.00,2959.30,-945.00,110.90}},
        {"Las Colinas",                 {2632.70,-1135.00,-89.00,2747.70,-945.00,110.90}},
        {"Las Colinas",                 {2281.40,-1135.00,-89.00,2632.70,-945.00,110.90}},
        {"Las Payasadas",               {-354.30,2580.30,2.00,-133.60,2816.80,200.00}},
        {"Las Venturas Airport",        {1236.60,1203.20,-89.00,1457.30,1883.10,110.90}},
        {"Las Venturas Airport",        {1457.30,1203.20,-89.00,1777.30,1883.10,110.90}},
        {"Las Venturas Airport",        {1457.30,1143.20,-89.00,1777.40,1203.20,110.90}},
        {"Las Venturas Airport",        {1515.80,1586.40,-12.50,1729.90,1714.50,87.50}},
        {"Last Dime Motel",             {1823.00,596.30,-89.00,1997.20,823.20,110.90}},
        {"Leafy Hollow",                {-1166.90,-1856.00,0.00,-815.60,-1602.00,200.00}},
        {"Liberty City",                {-1000.00,400.00,1300.00,-700.00,600.00,1400.00}},
        {"Lil' Probe Inn",              {-90.20,1286.80,-3.00,153.80,1554.10,200.00}},
        {"Linden Side",                 {2749.90,943.20,-89.00,2923.30,1198.90,110.90}},
        {"Linden Station",              {2749.90,1198.90,-89.00,2923.30,1548.90,110.90}},
        {"Linden Station",              {2811.20,1229.50,-39.50,2861.20,1407.50,60.40}},
        {"Harmony Oaks",                {1701.90,-1842.20,-89.00,1812.60,-1722.20,110.90}},
        {"Harmony Oaks",                {1758.90,-1722.20,-89.00,1812.60,-1577.50,110.90}},
        {"Los Flores",                  {2581.70,-1454.30,-89.00,2632.80,-1393.40,110.90}},
        {"Los Flores",                  {2581.70,-1393.40,-89.00,2747.70,-1135.00,110.90}},
        {"Los Santos International",    {1249.60,-2394.30,-89.00,1852.00,-2179.20,110.90}},
        {"Los Santos International",    {1852.00,-2394.30,-89.00,2089.00,-2179.20,110.90}},
        {"Los Santos International",    {1382.70,-2730.80,-89.00,2201.80,-2394.30,110.90}},
        {"Los Santos International",    {1974.60,-2394.30,-39.00,2089.00,-2256.50,60.90}},
        {"Los Santos International",    {1400.90,-2669.20,-39.00,2189.80,-2597.20,60.90}},
        {"Los Santos International",    {2051.60,-2597.20,-39.00,2152.40,-2394.30,60.90}},
        {"Marina",                      {647.70,-1804.20,-89.00,851.40,-1577.50,110.90}},
        {"Marina",                      {647.70,-1577.50,-89.00,807.90,-1416.20,110.90}},
        {"Marina",                      {807.90,-1577.50,-89.00,926.90,-1416.20,110.90}},
        {"Market",                      {787.40,-1416.20,-89.00,1072.60,-1310.20,110.90}},
        {"Market",                      {952.60,-1310.20,-89.00,1072.60,-1130.80,110.90}},
        {"Market",                      {1072.60,-1416.20,-89.00,1370.80,-1130.80,110.90}},
        {"Market",                      {926.90,-1577.50,-89.00,1370.80,-1416.20,110.90}},
        {"Market Station",              {787.40,-1410.90,-34.10,866.00,-1310.20,65.80}},
        {"Martin Bridge",               {-222.10,293.30,0.00,-122.10,476.40,200.00}},
        {"Missionary Hill",             {-2994.40,-811.20,0.00,-2178.60,-430.20,200.00}},
        {"Montgomery",                  {1119.50,119.50,-3.00,1451.40,493.30,200.00}},
        {"Montgomery",                  {1451.40,347.40,-6.10,1582.40,420.80,200.00}},
        {"Montgomery Intersection",     {1546.60,208.10,0.00,1745.80,347.40,200.00}},
        {"Montgomery Intersection",     {1582.40,347.40,0.00,1664.60,401.70,200.00}},
        {"Mulholland",                  {1414.00,-768.00,-89.00,1667.60,-452.40,110.90}},
        {"Mulholland",                  {1281.10,-452.40,-89.00,1641.10,-290.90,110.90}},
        {"Mulholland",                  {1269.10,-768.00,-89.00,1414.00,-452.40,110.90}},
        {"Mulholland",                  {1357.00,-926.90,-89.00,1463.90,-768.00,110.90}},
        {"Mulholland",                  {1318.10,-910.10,-89.00,1357.00,-768.00,110.90}},
        {"Mulholland",                  {1169.10,-910.10,-89.00,1318.10,-768.00,110.90}},
        {"Mulholland",                  {768.60,-954.60,-89.00,952.60,-860.60,110.90}},
        {"Mulholland",                  {687.80,-860.60,-89.00,911.80,-768.00,110.90}},
        {"Mulholland",                  {737.50,-768.00,-89.00,1142.20,-674.80,110.90}},
        {"Mulholland",                  {1096.40,-910.10,-89.00,1169.10,-768.00,110.90}},
        {"Mulholland",                  {952.60,-937.10,-89.00,1096.40,-860.60,110.90}},
        {"Mulholland",                  {911.80,-860.60,-89.00,1096.40,-768.00,110.90}},
        {"Mulholland",                  {861.00,-674.80,-89.00,1156.50,-600.80,110.90}},
        {"Mulholland Intersection",     {1463.90,-1150.80,-89.00,1812.60,-768.00,110.90}},
        {"North Rock",                  {2285.30,-768.00,0.00,2770.50,-269.70,200.00}},
        {"Ocean Docks",                 {2373.70,-2697.00,-89.00,2809.20,-2330.40,110.90}},
        {"Ocean Docks",                 {2201.80,-2418.30,-89.00,2324.00,-2095.00,110.90}},
        {"Ocean Docks",                 {2324.00,-2302.30,-89.00,2703.50,-2145.10,110.90}},
        {"Ocean Docks",                 {2089.00,-2394.30,-89.00,2201.80,-2235.80,110.90}},
        {"Ocean Docks",                 {2201.80,-2730.80,-89.00,2324.00,-2418.30,110.90}},
        {"Ocean Docks",                 {2703.50,-2302.30,-89.00,2959.30,-2126.90,110.90}},
        {"Ocean Docks",                 {2324.00,-2145.10,-89.00,2703.50,-2059.20,110.90}},
        {"Ocean Flats",                 {-2994.40,277.40,-9.10,-2867.80,458.40,200.00}},
        {"Ocean Flats",                 {-2994.40,-222.50,-0.00,-2593.40,277.40,200.00}},
        {"Ocean Flats",                 {-2994.40,-430.20,-0.00,-2831.80,-222.50,200.00}},
        {"Octane Springs",              {338.60,1228.50,0.00,664.30,1655.00,200.00}},
        {"Old Venturas Strip",          {2162.30,2012.10,-89.00,2685.10,2202.70,110.90}},
        {"Palisades",                   {-2994.40,458.40,-6.10,-2741.00,1339.60,200.00}},
        {"Palomino Creek",              {2160.20,-149.00,0.00,2576.90,228.30,200.00}},
        {"Paradiso",                    {-2741.00,793.40,-6.10,-2533.00,1268.40,200.00}},
        {"Pershing Square",             {1440.90,-1722.20,-89.00,1583.50,-1577.50,110.90}},
        {"Pilgrim",                     {2437.30,1383.20,-89.00,2624.40,1783.20,110.90}},
        {"Pilgrim",                     {2624.40,1383.20,-89.00,2685.10,1783.20,110.90}},
        {"Pilson Intersection",         {1098.30,2243.20,-89.00,1377.30,2507.20,110.90}},
        {"Pirates in Men's Pants",      {1817.30,1469.20,-89.00,2027.40,1703.20,110.90}},
        {"Playa del Seville",           {2703.50,-2126.90,-89.00,2959.30,-1852.80,110.90}},
        {"Prickle Pine",                {1534.50,2583.20,-89.00,1848.40,2863.20,110.90}},
        {"Prickle Pine",                {1117.40,2507.20,-89.00,1534.50,2723.20,110.90}},
        {"Prickle Pine",                {1848.40,2553.40,-89.00,1938.80,2863.20,110.90}},
        {"Prickle Pine",                {1938.80,2624.20,-89.00,2121.40,2861.50,110.90}},
        {"Queens",                      {-2533.00,458.40,0.00,-2329.30,578.30,200.00}},
        {"Queens",                      {-2593.40,54.70,0.00,-2411.20,458.40,200.00}},
        {"Queens",                      {-2411.20,373.50,0.00,-2253.50,458.40,200.00}},
        {"Randolph Industrial Estate",  {1558.00,596.30,-89.00,1823.00,823.20,110.90}},
        {"Redsands East",               {1817.30,2011.80,-89.00,2106.70,2202.70,110.90}},
        {"Redsands East",               {1817.30,2202.70,-89.00,2011.90,2342.80,110.90}},
        {"Redsands East",               {1848.40,2342.80,-89.00,2011.90,2478.40,110.90}},
        {"Redsands West",               {1236.60,1883.10,-89.00,1777.30,2142.80,110.90}},
        {"Redsands West",               {1297.40,2142.80,-89.00,1777.30,2243.20,110.90}},
        {"Redsands West",               {1377.30,2243.20,-89.00,1704.50,2433.20,110.90}},
        {"Redsands West",               {1704.50,2243.20,-89.00,1777.30,2342.80,110.90}},
        {"Regular Tom",                 {-405.70,1712.80,-3.00,-276.70,1892.70,200.00}},
        {"Richman",                     {647.50,-1118.20,-89.00,787.40,-954.60,110.90}},
        {"Richman",                     {647.50,-954.60,-89.00,768.60,-860.60,110.90}},
        {"Richman",                     {225.10,-1369.60,-89.00,334.50,-1292.00,110.90}},
        {"Richman",                     {225.10,-1292.00,-89.00,466.20,-1235.00,110.90}},
        {"Richman",                     {72.60,-1404.90,-89.00,225.10,-1235.00,110.90}},
        {"Richman",                     {72.60,-1235.00,-89.00,321.30,-1008.10,110.90}},
        {"Richman",                     {321.30,-1235.00,-89.00,647.50,-1044.00,110.90}},
        {"Richman",                     {321.30,-1044.00,-89.00,647.50,-860.60,110.90}},
        {"Richman",                     {321.30,-860.60,-89.00,687.80,-768.00,110.90}},
        {"Richman",                     {321.30,-768.00,-89.00,700.70,-674.80,110.90}},
        {"Robada Intersection",         {-1119.00,1178.90,-89.00,-862.00,1351.40,110.90}},
        {"Roca Escalante",              {2237.40,2202.70,-89.00,2536.40,2542.50,110.90}},
        {"Roca Escalante",              {2536.40,2202.70,-89.00,2625.10,2442.50,110.90}},
        {"Rockshore East",              {2537.30,676.50,-89.00,2902.30,943.20,110.90}},
        {"Rockshore West",              {1997.20,596.30,-89.00,2377.30,823.20,110.90}},
        {"Rockshore West",              {2377.30,596.30,-89.00,2537.30,788.80,110.90}},
        {"Rodeo",                       {72.60,-1684.60,-89.00,225.10,-1544.10,110.90}},
        {"Rodeo",                       {72.60,-1544.10,-89.00,225.10,-1404.90,110.90}},
        {"Rodeo",                       {225.10,-1684.60,-89.00,312.80,-1501.90,110.90}},
        {"Rodeo",                       {225.10,-1501.90,-89.00,334.50,-1369.60,110.90}},
        {"Rodeo",                       {334.50,-1501.90,-89.00,422.60,-1406.00,110.90}},
        {"Rodeo",                       {312.80,-1684.60,-89.00,422.60,-1501.90,110.90}},
        {"Rodeo",                       {422.60,-1684.60,-89.00,558.00,-1570.20,110.90}},
        {"Rodeo",                       {558.00,-1684.60,-89.00,647.50,-1384.90,110.90}},
        {"Rodeo",                       {466.20,-1570.20,-89.00,558.00,-1385.00,110.90}},
        {"Rodeo",                       {422.60,-1570.20,-89.00,466.20,-1406.00,110.90}},
        {"Rodeo",                       {466.20,-1385.00,-89.00,647.50,-1235.00,110.90}},
        {"Rodeo",                       {334.50,-1406.00,-89.00,466.20,-1292.00,110.90}},
        {"Royal Casino",                {2087.30,1383.20,-89.00,2437.30,1543.20,110.90}},
        {"San Andreas Sound",           {2450.30,385.50,-100.00,2759.20,562.30,200.00}},
        {"Santa Flora",                 {-2741.00,458.40,-7.60,-2533.00,793.40,200.00}},
        {"Santa Maria Beach",           {342.60,-2173.20,-89.00,647.70,-1684.60,110.90}},
        {"Santa Maria Beach",           {72.60,-2173.20,-89.00,342.60,-1684.60,110.90}},
        {"Shady Cabin",                 {-1632.80,-2263.40,-3.00,-1601.30,-2231.70,200.00}},
        {"Shady Creeks",                {-1820.60,-2643.60,-8.00,-1226.70,-1771.60,200.00}},
        {"Shady Creeks",                {-2030.10,-2174.80,-6.10,-1820.60,-1771.60,200.00}},
        {"Sobell Rail Yards",           {2749.90,1548.90,-89.00,2923.30,1937.20,110.90}},
        {"Spinybed",                    {2121.40,2663.10,-89.00,2498.20,2861.50,110.90}},
        {"Starfish Casino",             {2437.30,1783.20,-89.00,2685.10,2012.10,110.90}},
        {"Starfish Casino",             {2437.30,1858.10,-39.00,2495.00,1970.80,60.90}},
        {"Starfish Casino",             {2162.30,1883.20,-89.00,2437.30,2012.10,110.90}},
        {"Temple",                      {1252.30,-1130.80,-89.00,1378.30,-1026.30,110.90}},
        {"Temple",                      {1252.30,-1026.30,-89.00,1391.00,-926.90,110.90}},
        {"Temple",                      {1252.30,-926.90,-89.00,1357.00,-910.10,110.90}},
        {"Temple",                      {952.60,-1130.80,-89.00,1096.40,-937.10,110.90}},
        {"Temple",                      {1096.40,-1130.80,-89.00,1252.30,-1026.30,110.90}},
        {"Temple",                      {1096.40,-1026.30,-89.00,1252.30,-910.10,110.90}},
        {"The Camel's Toe",             {2087.30,1203.20,-89.00,2640.40,1383.20,110.90}},
        {"The Clown's Pocket",          {2162.30,1783.20,-89.00,2437.30,1883.20,110.90}},
        {"The Emerald Isle",            {2011.90,2202.70,-89.00,2237.40,2508.20,110.90}},
        {"The Farm",                    {-1209.60,-1317.10,114.90,-908.10,-787.30,251.90}},
        {"The Four Dragons Casino",     {1817.30,863.20,-89.00,2027.30,1083.20,110.90}},
        {"The High Roller",             {1817.30,1283.20,-89.00,2027.30,1469.20,110.90}},
        {"The Mako Span",               {1664.60,401.70,0.00,1785.10,567.20,200.00}},
        {"The Panopticon",              {-947.90,-304.30,-1.10,-319.60,327.00,200.00}},
        {"The Pink Swan",               {1817.30,1083.20,-89.00,2027.30,1283.20,110.90}},
        {"The Sherman Dam",             {-968.70,1929.40,-3.00,-481.10,2155.20,200.00}},
        {"The Strip",                   {2027.40,863.20,-89.00,2087.30,1703.20,110.90}},
        {"The Strip",                   {2106.70,1863.20,-89.00,2162.30,2202.70,110.90}},
        {"The Strip",                   {2027.40,1783.20,-89.00,2162.30,1863.20,110.90}},
        {"The Strip",                   {2027.40,1703.20,-89.00,2137.40,1783.20,110.90}},
        {"The Visage",                  {1817.30,1863.20,-89.00,2106.70,2011.80,110.90}},
        {"The Visage",                  {1817.30,1703.20,-89.00,2027.40,1863.20,110.90}},
        {"Unity Station",               {1692.60,-1971.80,-20.40,1812.60,-1932.80,79.50}},
        {"Valle Ocultado",              {-936.60,2611.40,2.00,-715.90,2847.90,200.00}},
        {"Verdant Bluffs",              {930.20,-2488.40,-89.00,1249.60,-2006.70,110.90}},
        {"Verdant Bluffs",              {1073.20,-2006.70,-89.00,1249.60,-1842.20,110.90}},
        {"Verdant Bluffs",              {1249.60,-2179.20,-89.00,1692.60,-1842.20,110.90}},
        {"Verdant Meadows",             {37.00,2337.10,-3.00,435.90,2677.90,200.00}},
        {"Verona Beach",                {647.70,-2173.20,-89.00,930.20,-1804.20,110.90}},
        {"Verona Beach",                {930.20,-2006.70,-89.00,1073.20,-1804.20,110.90}},
        {"Verona Beach",                {851.40,-1804.20,-89.00,1046.10,-1577.50,110.90}},
        {"Verona Beach",                {1161.50,-1722.20,-89.00,1323.90,-1577.50,110.90}},
        {"Verona Beach",                {1046.10,-1722.20,-89.00,1161.50,-1577.50,110.90}},
        {"Vinewood",                    {787.40,-1310.20,-89.00,952.60,-1130.80,110.90}},
        {"Vinewood",                    {787.40,-1130.80,-89.00,952.60,-954.60,110.90}},
        {"Vinewood",                    {647.50,-1227.20,-89.00,787.40,-1118.20,110.90}},
        {"Vinewood",                    {647.70,-1416.20,-89.00,787.40,-1227.20,110.90}},
        {"Whitewood Estates",           {883.30,1726.20,-89.00,1098.30,2507.20,110.90}},
        {"Whitewood Estates",           {1098.30,1726.20,-89.00,1197.30,2243.20,110.90}},
        {"Willowfield",                 {1970.60,-2179.20,-89.00,2089.00,-1852.80,110.90}},
        {"Willowfield",                 {2089.00,-2235.80,-89.00,2201.80,-1989.90,110.90}},
        {"Willowfield",                 {2089.00,-1989.90,-89.00,2324.00,-1852.80,110.90}},
        {"Willowfield",                 {2201.80,-2095.00,-89.00,2324.00,-1989.90,110.90}},
        {"Willowfield",                 {2541.70,-1941.40,-89.00,2703.50,-1852.80,110.90}},
        {"Willowfield",                 {2324.00,-2059.20,-89.00,2541.70,-1852.80,110.90}},
        {"Willowfield",                 {2541.70,-2059.20,-89.00,2703.50,-1941.40,110.90}},
        {"Yellow Bell Station",         {1377.40,2600.40,-21.90,1492.40,2687.30,78.00}}
};

//Player variables:
new playerLogin[MAX_PLAYERS] = 0, playerHouseSelect[MAX_PLAYERS][3]; 
new playerPhone[MAX_PLAYERS], playerText[MAX_PLAYERS];

new bool:PlayerTakingLicense[MAX_PLAYERS], PlayerLicenseTime[MAX_PLAYERS]; 
new PlayerLicensePoint[MAX_PLAYERS]; 
new PlayersLicenseVehicle[MAX_PLAYERS]; 

new Player911Type[MAX_PLAYERS];
new Player911Text[MAX_PLAYERS][3][128]; 

new PlayerMDCTimer[MAX_PLAYERS], PlayerMDCCount[MAX_PLAYERS];
new PlayerMDCName[MAX_PLAYERS][32], PlayerPlateSaver[MAX_PLAYERS][5][20]; 

new PlayerText:Unscrambler_PTD[MAX_PLAYERS][7]; 
new PlayerText:ui_msgbox[MAX_PLAYERS][2];
new PlayerText:JobInfo[MAX_PLAYERS][2];
new Text:Masktd;

//Dynamic areas:
new ImpoundLotArea; 

//Start of functions:
public OnGameModeInit()
{
	SetGameModeText(SCRIPT_REV); 
	this = mysql_connect(SQL_HOSTNAME, SQL_USERNAME, SQL_DATABASE, SQL_PASSWORD);
	
	if(mysql_errno() != 0)	
		printf ("[DATABASE]: Connection failed to '%s'...", SQL_DATABASE);
		
	else printf ("[DATABASE]: Connection established to '%s'...", SQL_DATABASE);
	
	mysql_log(LOG_ERROR | LOG_WARNING);
	
	//Disabling single player entities:
	ShowPlayerMarkers(PLAYER_MARKERS_MODE_OFF);
	SetNameTagDrawDistance(20.0);

	EnableStuntBonusForAll(0);
	
	ManualVehicleEngineAndLights();
	DisableInteriorEnterExits();
	
	AddHousesInteriors();
	//Configure world:
	SetWeather(globalWeather); 
	
	new 
		hour, seconds, minute;
		
	gettime(hour, seconds, minute); 
	SetWorldTime(hour); 
  
	//Global timers:
	SetTimer("PublishAds", 1000, true);
	SetTimer("FunctionPlayers", 1000, true); 
	SetTimer("OnWeaponsUpdate", 1000, true);
	SetTimer("FunctionPaychecks", 1000, true);
	SetTimer("OnPlayerNearProperty", 3000, true);
	SetTimer("OnPlayerNearBusiness", 3000, true); 
	SetTimer("OnVehicleUpdate", 250, true);
	
	SetTimer("UpdateTextDraw", 60000, true);
	
	//Loading systems:
	mysql_tquery(this, "SELECT * FROM factions ORDER BY dbid ASC", "Query_LoadFactions");
	mysql_tquery(this, "SELECT * FROM vehicles WHERE VehicleFaction > 0", "Query_LoadVehicles");
	mysql_tquery(this, "SELECT * FROM properties ORDER BY PropertyDBID", "Query_LoadProperties");
	mysql_tquery(this, "SELECT * FROM xmr_categories ORDER BY XMRDBID ASC", "Query_LoadXMRCategories");
	mysql_tquery(this, "SELECT * FROM xmr_stations ORDER BY XMRStationDBID ASC", "Query_LoadXMRStations");
	mysql_tquery(this, "SELECT * FROM businesses ORDER BY BusinessDBID ASC", "Query_LoadBusinesses");
	mysql_tquery(this, "SELECT * FROM street_data ORDER BY id", "Query_LoadStreets");
	mysql_tquery(this, "SELECT * FROM spray_tag ORDER BY id", "Query_LoadTags");
	mysql_tquery(this, "SELECT * FROM payphone ORDER BY id", "Query_LoadPayphone");
	mysql_tquery(this, "SELECT * FROM chopshop ORDER BY id", "Query_LoadChopshop");
	
	for(new a, as = sizeof(AntennasRadio); a < as; a++)
 		AntennasRadio[a][arObject] = CreateDynamicObject(3763, AntennasRadio[a][arX], AntennasRadio[a][arY], AntennasRadio[a][arZ], AntennasRadio[a][arRX], AntennasRadio[a][arRY], AntennasRadio[a][arRZ]);
	
	//DMV vehicles:
	dmv_vehicles[0] = AddStaticVehicle(405, 1273.0470, -1557.0576, 13.5405, -91.0000, 1, 1); SetVehicleNumberPlate(dmv_vehicles[0], "DMV");
	dmv_vehicles[1] = AddStaticVehicle(405, 1273.0470, -1549.9562, 13.5405, -91.0000, 1, 1); SetVehicleNumberPlate(dmv_vehicles[1], "DMV");
	dmv_vehicles[2] = AddStaticVehicle(405, 1273.0470, -1542.8961, 13.5405, -91.0000, 1, 1); SetVehicleNumberPlate(dmv_vehicles[2], "DMV");
	dmv_vehicles[3] = AddStaticVehicle(405, 1273.0470, -1536.0962, 13.5405, -91.0000, 1, 1); SetVehicleNumberPlate(dmv_vehicles[3], "DMV");
	
	CreateDynamicPickup(1239, 23, EXTERIOR_TUNING_X, EXTERIOR_TUNING_Y, EXTERIOR_TUNING_Z, 0);
	
	init_global_textdraw();
	
	//Areas:
	ImpoundLotArea = CreateDynamicCircle(-1098.6909, -973.7175, 140.0, 0, 0);
	
	for(new ad_id = 0; ad_id < MAX_ADVERT_SLOT; ad_id ++)
	{
		advert_data[ ad_id ][advert_id] = -1;
		advert_data[ ad_id ][publish_time] = -1;
		advert_data[ ad_id ][advert_contact] = 0;
		format(advert_data[ ad_id ][advert_text], 256, "None");
		format(advert_data[ ad_id ][advert_placeby], 32, "None");
		advert_data[ ad_id ][advert_exists] = false;
		advert_data[ ad_id ][in_area] = -1;
		advert_data[ ad_id ][advert_type] = 0;
	}
	CreateFireDepartment();
	CreateIdlewood();
	CreatePoliceStations();
	return 1;
}

public OnGameModeExit()
{
	foreach (new i : Player)
	{
		SetPlayerName(i, e_pAccountData[i][mAccName]);
		SaveCharacter(i); SaveCharacterPos(i);
	}
	
	//Saving systems:
	SaveFactions();
	SaveProperties();
	SaveBusinesses();
	
	//Closing database:
	mysql_close(this);
	return 1;
}

public OnPlayerConnect(playerid)
{
	ResetPlayer(playerid);
	PreloadAnimations(playerid); 
	SetPlayerColor(playerid, 0xAFAFAFFF); 
	SetPlayerTeam(playerid, PLAYER_STATE_ALIVE); 
	//Dualies;
	SetPlayerSkillLevel(playerid, WEAPONSKILL_PISTOL, 899);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_MICRO_UZI, 0);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_SPAS12_SHOTGUN, 0);
	
	SetPlayerSkillLevel(playerid, WEAPONSKILL_AK47, 999);
    SetPlayerSkillLevel(playerid, WEAPONSKILL_DESERT_EAGLE, 999);
    SetPlayerSkillLevel(playerid, WEAPONSKILL_SHOTGUN, 999);
    SetPlayerSkillLevel(playerid, WEAPONSKILL_M4, 999);
    SetPlayerSkillLevel(playerid, WEAPONSKILL_MP5, 999);


	new 
		existCheck[60]
	; 
	
	mysql_format(this, existCheck, sizeof(existCheck), "SELECT * FROM bannedlist WHERE IpAddress = '%e'", ReturnIP(playerid));
	mysql_tquery(this, existCheck, "CheckBanList", "i", playerid);
	// We'll check if their IP is linked to any players on the bannedlist.
	// A master account DBID ban will be checked once they login. 
	
	SetPlayerCamera(playerid);
	
	Init_SpeedText(playerid);
	Init_PlayerTextdraws(playerid);
	
	CreatePhoneGUI(playerid);
    CreateVehicleMenu(playerid);
//Player TextDraws:
	Tuning_CreateTD(playerid);
	
    InitMDC(playerid);
	SetUp[playerid][0] = CreatePlayerTextDraw(playerid, 160.000000, 173.000000, "_");
	PlayerTextDrawBackgroundColor(playerid, SetUp[playerid][0], 255);
	PlayerTextDrawFont(playerid, SetUp[playerid][0], 1);
	PlayerTextDrawLetterSize(playerid, SetUp[playerid][0], 0.500000, 14.599998);
	PlayerTextDrawColor(playerid, SetUp[playerid][0], -1);
	PlayerTextDrawSetOutline(playerid, SetUp[playerid][0], 0);
	PlayerTextDrawSetProportional(playerid, SetUp[playerid][0], 1);
	PlayerTextDrawSetShadow(playerid, SetUp[playerid][0], 1);
	PlayerTextDrawUseBox(playerid, SetUp[playerid][0], 1);
	PlayerTextDrawBoxColor(playerid, SetUp[playerid][0], 119);
	PlayerTextDrawTextSize(playerid, SetUp[playerid][0], 10.000000, 20.000000);

	SetUp[playerid][1] = CreatePlayerTextDraw(playerid, 9.000000, 162.000000, "Character Setup");
	PlayerTextDrawBackgroundColor(playerid, SetUp[playerid][1], 255);
	PlayerTextDrawFont(playerid, SetUp[playerid][1], 0);
	PlayerTextDrawLetterSize(playerid, SetUp[playerid][1], 0.569999, 1.799998);
	PlayerTextDrawColor(playerid, SetUp[playerid][1], -1);
	PlayerTextDrawSetOutline(playerid, SetUp[playerid][1], 1);
	PlayerTextDrawSetProportional(playerid, SetUp[playerid][1], 1);

	SetUp[playerid][2] = CreatePlayerTextDraw(playerid, 18.000000, 184.000000, "~g~~h~Gender:");
	PlayerTextDrawBackgroundColor(playerid, SetUp[playerid][2], 255);
	PlayerTextDrawFont(playerid, SetUp[playerid][2], 2);
	PlayerTextDrawLetterSize(playerid, SetUp[playerid][2], 0.239999, 1.200000);
	PlayerTextDrawColor(playerid, SetUp[playerid][2], -1);
	PlayerTextDrawSetOutline(playerid, SetUp[playerid][2], 1);
	PlayerTextDrawSetProportional(playerid, SetUp[playerid][2], 1);

	SetUp[playerid][3] = CreatePlayerTextDraw(playerid, 19.000000, 195.000000, "Male");
	PlayerTextDrawTextSize(playerid, SetUp[playerid][3], 100.000000, 10.000000);
	PlayerTextDrawBackgroundColor(playerid, SetUp[playerid][3], 255);
	PlayerTextDrawFont(playerid, SetUp[playerid][3], 2);
	PlayerTextDrawLetterSize(playerid, SetUp[playerid][3], 0.239999, 1.100000);
	PlayerTextDrawColor(playerid, SetUp[playerid][3], -1);
	PlayerTextDrawSetOutline(playerid, SetUp[playerid][3], 1);
	PlayerTextDrawSetProportional(playerid, SetUp[playerid][3], 1);
	PlayerTextDrawSetSelectable(playerid, SetUp[playerid][3], true);

	SetUp[playerid][4] = CreatePlayerTextDraw(playerid, 19.000000, 205.000000, "Female");
	PlayerTextDrawTextSize(playerid, SetUp[playerid][4], 100.000000, 10.000000);
	PlayerTextDrawBackgroundColor(playerid, SetUp[playerid][4], 255);
	PlayerTextDrawFont(playerid, SetUp[playerid][4], 2);
	PlayerTextDrawLetterSize(playerid, SetUp[playerid][4], 0.240000, 1.100000);
	PlayerTextDrawColor(playerid, SetUp[playerid][4], -1);
	PlayerTextDrawSetOutline(playerid, SetUp[playerid][4], 1);
	PlayerTextDrawSetProportional(playerid, SetUp[playerid][4], 1);
	PlayerTextDrawSetSelectable(playerid, SetUp[playerid][4], true);

	SetUp[playerid][5] = CreatePlayerTextDraw(playerid, 18.000000, 225.000000, "~g~~h~Age:");
	PlayerTextDrawBackgroundColor(playerid, SetUp[playerid][5], 255);
	PlayerTextDrawFont(playerid, SetUp[playerid][5], 2);
	PlayerTextDrawLetterSize(playerid, SetUp[playerid][5], 0.239999, 1.100000);
	PlayerTextDrawColor(playerid, SetUp[playerid][5], -1);
	PlayerTextDrawSetOutline(playerid, SetUp[playerid][5], 1);
	PlayerTextDrawSetProportional(playerid, SetUp[playerid][5], 1);

	SetUp[playerid][6] = CreatePlayerTextDraw(playerid, 19.000000, 235.000000, "13 years old");
	PlayerTextDrawBackgroundColor(playerid, SetUp[playerid][6], 255);
	PlayerTextDrawFont(playerid, SetUp[playerid][6], 2);
	PlayerTextDrawLetterSize(playerid, SetUp[playerid][6], 0.230000, 1.100000);
	PlayerTextDrawColor(playerid, SetUp[playerid][6], -1);
	PlayerTextDrawSetOutline(playerid, SetUp[playerid][6], 1);
	PlayerTextDrawSetProportional(playerid, SetUp[playerid][6], 1);

	SetUp[playerid][7] = CreatePlayerTextDraw(playerid, 123.000000, 235.000000, "-");
	PlayerTextDrawAlignment(playerid, SetUp[playerid][7], 2);
	PlayerTextDrawBackgroundColor(playerid, SetUp[playerid][7], 255);
	PlayerTextDrawFont(playerid, SetUp[playerid][7], 0);
	PlayerTextDrawLetterSize(playerid, SetUp[playerid][7], 0.589999, 1.200000);
	PlayerTextDrawColor(playerid, SetUp[playerid][7], -1);
	PlayerTextDrawSetOutline(playerid, SetUp[playerid][7], 1);
	PlayerTextDrawSetProportional(playerid, SetUp[playerid][7], 1);
	PlayerTextDrawUseBox(playerid, SetUp[playerid][7], 1);
	PlayerTextDrawBoxColor(playerid, SetUp[playerid][7], 68);
	PlayerTextDrawTextSize(playerid, SetUp[playerid][7], 20.000000, 15.000000);
	PlayerTextDrawSetSelectable(playerid, SetUp[playerid][7], true);

	SetUp[playerid][8] = CreatePlayerTextDraw(playerid, 143.000000, 235.000000, "+");
	PlayerTextDrawAlignment(playerid, SetUp[playerid][8], 2);
	PlayerTextDrawBackgroundColor(playerid, SetUp[playerid][8], 255);
	PlayerTextDrawFont(playerid, SetUp[playerid][8], 0);
	PlayerTextDrawLetterSize(playerid, SetUp[playerid][8], 0.389999, 1.200000);
	PlayerTextDrawColor(playerid, SetUp[playerid][8], -1);
	PlayerTextDrawSetOutline(playerid, SetUp[playerid][8], 1);
	PlayerTextDrawSetProportional(playerid, SetUp[playerid][8], 1);
	PlayerTextDrawUseBox(playerid, SetUp[playerid][8], 1);
	PlayerTextDrawBoxColor(playerid, SetUp[playerid][8], 68);
	PlayerTextDrawTextSize(playerid, SetUp[playerid][8], 20.000000, 15.000000);
	PlayerTextDrawSetSelectable(playerid, SetUp[playerid][8], true);

	SetUp[playerid][9] = CreatePlayerTextDraw(playerid, 18.000000, 256.000000, "~g~~h~Outfit:");
	PlayerTextDrawBackgroundColor(playerid, SetUp[playerid][9], 255);
	PlayerTextDrawFont(playerid, SetUp[playerid][9], 2);
	PlayerTextDrawLetterSize(playerid, SetUp[playerid][9], 0.239999, 1.100000);
	PlayerTextDrawColor(playerid, SetUp[playerid][9], -1);
	PlayerTextDrawSetOutline(playerid, SetUp[playerid][9], 1);
	PlayerTextDrawSetProportional(playerid, SetUp[playerid][9], 1);

	SetUp[playerid][10] = CreatePlayerTextDraw(playerid, 19.000000, 266.000000, "Skin: 299");
	PlayerTextDrawBackgroundColor(playerid, SetUp[playerid][10], 255);
	PlayerTextDrawFont(playerid, SetUp[playerid][10], 2);
	PlayerTextDrawLetterSize(playerid, SetUp[playerid][10], 0.230000, 1.100000);
	PlayerTextDrawColor(playerid, SetUp[playerid][10], -1);
	PlayerTextDrawSetOutline(playerid, SetUp[playerid][10], 1);
	PlayerTextDrawSetProportional(playerid, SetUp[playerid][10], 1);

	SetUp[playerid][11] = CreatePlayerTextDraw(playerid, 123.000000, 267.000000, "<<");
	PlayerTextDrawAlignment(playerid, SetUp[playerid][11], 2);
	PlayerTextDrawBackgroundColor(playerid, SetUp[playerid][11], 255);
	PlayerTextDrawFont(playerid, SetUp[playerid][11], 0);
	PlayerTextDrawLetterSize(playerid, SetUp[playerid][11], 0.219999, 1.200000);
	PlayerTextDrawColor(playerid, SetUp[playerid][11], -1);
	PlayerTextDrawSetOutline(playerid, SetUp[playerid][11], 1);
	PlayerTextDrawSetProportional(playerid, SetUp[playerid][11], 1);
	PlayerTextDrawUseBox(playerid, SetUp[playerid][11], 1);
	PlayerTextDrawBoxColor(playerid, SetUp[playerid][11], 68);
	PlayerTextDrawTextSize(playerid, SetUp[playerid][11], 20.000000, 15.000000);
	PlayerTextDrawSetSelectable(playerid, SetUp[playerid][11], true);

	SetUp[playerid][12] = CreatePlayerTextDraw(playerid, 143.000000, 267.000000, ">>");
	PlayerTextDrawAlignment(playerid, SetUp[playerid][12], 2);
	PlayerTextDrawBackgroundColor(playerid, SetUp[playerid][12], 255);
	PlayerTextDrawFont(playerid, SetUp[playerid][12], 0);
	PlayerTextDrawLetterSize(playerid, SetUp[playerid][12], 0.219999, 1.200000);
	PlayerTextDrawColor(playerid, SetUp[playerid][12], -1);
	PlayerTextDrawSetOutline(playerid, SetUp[playerid][12], 1);
	PlayerTextDrawSetProportional(playerid, SetUp[playerid][12], 1);
	PlayerTextDrawUseBox(playerid, SetUp[playerid][12], 1);
	PlayerTextDrawBoxColor(playerid, SetUp[playerid][12], 68);
	PlayerTextDrawTextSize(playerid, SetUp[playerid][12], 20.000000, 15.000000);
	PlayerTextDrawSetSelectable(playerid, SetUp[playerid][12], true);

	SetUp[playerid][13] = CreatePlayerTextDraw(playerid, 37.000000, 290.000000, "Reset");
	PlayerTextDrawAlignment(playerid, SetUp[playerid][13], 2);
	PlayerTextDrawBackgroundColor(playerid, SetUp[playerid][13], 255);
	PlayerTextDrawFont(playerid, SetUp[playerid][13], 2);
	PlayerTextDrawLetterSize(playerid, SetUp[playerid][13], 0.230000, 1.200000);
	PlayerTextDrawColor(playerid, SetUp[playerid][13], -1);
	PlayerTextDrawSetOutline(playerid, SetUp[playerid][13], 1);
	PlayerTextDrawSetProportional(playerid, SetUp[playerid][13], 1);
	PlayerTextDrawUseBox(playerid, SetUp[playerid][13], 1);
	PlayerTextDrawBoxColor(playerid, SetUp[playerid][13], 68);
	PlayerTextDrawTextSize(playerid, SetUp[playerid][13], 20.000000, 37.000000);
	PlayerTextDrawSetSelectable(playerid, SetUp[playerid][13], true);

	SetUp[playerid][14] = CreatePlayerTextDraw(playerid, 85.000000, 290.000000, "Confirm");
	PlayerTextDrawAlignment(playerid, SetUp[playerid][14], 2);
	PlayerTextDrawBackgroundColor(playerid, SetUp[playerid][14], 255);
	PlayerTextDrawFont(playerid, SetUp[playerid][14], 2);
	PlayerTextDrawLetterSize(playerid, SetUp[playerid][14], 0.230000, 1.200000);
	PlayerTextDrawColor(playerid, SetUp[playerid][14], -1);
	PlayerTextDrawSetOutline(playerid, SetUp[playerid][14], 1);
	PlayerTextDrawSetProportional(playerid, SetUp[playerid][14], 1);
	PlayerTextDrawUseBox(playerid, SetUp[playerid][14], 1);
	PlayerTextDrawBoxColor(playerid, SetUp[playerid][14], 68);
	PlayerTextDrawTextSize(playerid, SetUp[playerid][14], 20.000000, 46.000000);
	PlayerTextDrawSetSelectable(playerid, SetUp[playerid][14], true);

	SetUp[playerid][15] = CreatePlayerTextDraw(playerid, 133.000000, 290.000000, "Help");
	PlayerTextDrawAlignment(playerid, SetUp[playerid][15], 2);
	PlayerTextDrawBackgroundColor(playerid, SetUp[playerid][15], 255);
	PlayerTextDrawFont(playerid, SetUp[playerid][15], 2);
	PlayerTextDrawLetterSize(playerid, SetUp[playerid][15], 0.230000, 1.200000);
	PlayerTextDrawColor(playerid, SetUp[playerid][15], -1);
	PlayerTextDrawSetOutline(playerid, SetUp[playerid][15], 1);
	PlayerTextDrawSetProportional(playerid, SetUp[playerid][15], 1);
	PlayerTextDrawUseBox(playerid, SetUp[playerid][15], 1);
	PlayerTextDrawBoxColor(playerid, SetUp[playerid][15], 68);
	PlayerTextDrawTextSize(playerid, SetUp[playerid][15], 20.000000, 37.000000);
	PlayerTextDrawSetSelectable(playerid, SetUp[playerid][15], true);
	
	//remove building
	RemoveFireDepartment(playerid);
	RemoveIdlewoodBuilding(playerid);
	Police_Buidings(playerid);
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	if(DealershipPlayerCar[playerid] != INVALID_VEHICLE_ID)
	{
		if(IsValidVehicle(DealershipPlayerCar[playerid]) && !VehicleInfo[DealershipPlayerCar[playerid]][eVehicleDBID])
		{
			DestroyVehicle(DealershipPlayerCar[playerid]);
		}
		if(!PlayerPurchasingVehicle[playerid])
			ResetDealershipVars(playerid);
	}

	if(IsValidVehicle(GetPVarInt(playerid, "Breakin_ID")))
	{
		new Float:cX, Float:cY, Float:cZ;
		GetVehiclePos(GetPVarInt(playerid, "Breakin_ID"), cX, cY, cZ);

	    VehicleInfo[GetPVarInt(playerid, "Breakin_ID")][ePhysicalAttack] = false;
	    DestroyDynamic3DTextLabel(VehicleInfo[GetPVarInt(playerid, "Breakin_ID")][eVehicleLabel]);
	    VehicleInfo[GetPVarInt(playerid, "Breakin_ID")][vCooldown] = false;
	    SetPVarInt(playerid, "Breakin_ID", 0);
	}
	if(PlayerInfo[playerid][pEditingObject] == 3)
	{
	    new vehicleid = GetPVarInt(playerid, "getVehicleID");
	    new slot = GetPVarInt(playerid, "getSlot");
	    new insert[128];
	    
	    AttachDynamicObjectToVehicle( vehicle_trunk_data[vehicleid][slot][temp_object], vehicleid, 0, 0, 0, 0, 0, 0);
	    for(new i = 0; i < 6; i ++) vehicle_trunk_data[vehicleid][slot][wep_offset][i] = 0.0;
	    
		mysql_format(this, insert, sizeof(insert), "UPDATE vehicle_trunk SET offsetX = 0.0, offsetY = 0.0, offsetZ = 0.0, rotX = 0.0, rotY = 0.0, rotZ = 0.0 WHERE id = %i",
			vehicle_trunk_data[vehicleid][slot][data_id]);
		mysql_tquery(this, insert);
		
		DeletePVar(playerid, "getVehicleID");
		DeletePVar(playerid, "getSlot");
	}

	for (new i = 0; i < sizeof(ReportInfo); i ++)
	{
		if(ReportInfo[i][rReportBy] == playerid)
		{
			ReportInfo[i][rReportExists] = false; 
			ReportInfo[i][rReportBy] = INVALID_PLAYER_ID;
		}
	}
	
	foreach(new i : Player)
	{
		if(PlayerInfo[i][pFactionInvitedBy] == playerid)
		{
			PlayerInfo[i][pFactionInvite] = 0;
			PlayerInfo[i][pFactionInvitedBy] = INVALID_PLAYER_ID;
			SendClientMessage(i, COLOR_YELLOW, "Your faction invitation was disregarded. Your inviter disconnected.");
		}
	}

	new playerTime = NetStats_GetConnectedTime(playerid);
	new secondsConnection = (playerTime % (1000*60*60)) / (1000*60);
	// Converting their connection time into minutes;
	
	PlayerInfo[playerid][pLastOnlineTime] = secondsConnection;
	SaveCharacter(playerid); SaveCharacterPos(playerid);
	return 1; 
}

Float: getVehicleCondition(vehid, type) // type 0 血 1 引擎 2 电池
{
	new Float: value;
	switch(type)
	{
	    case 0:
		{
		    switch(GetVehicleModel(vehid))
		    {
				case 462, 463, 521, 522, 581, 586, 461: value = 800.0; // 其他摩托
				case 468, 471: value = 700.0; // sanchez 沙地摩托
				case 481, 509, 510: value = 1000.0; // 自行车
				case 439, 480, 533, 555: value = 850.0;// 敞篷车 非lowrider
				case 549, 604, 605: value = 550.0;
				default: value = 900.0;
		    }
		}
	    case 1:
	    {
		    switch(GetVehicleModel(vehid))
		    {
				case 462, 463, 521, 522, 581, 586, 461: value = 65.0; // 其他摩托
				case 468, 471: value = 50.0; // sanchez 沙地摩托
				case 481, 509, 510: value = 100.0; // 自行车
				case 439, 480, 533, 555: value = 75.0;// 敞篷车 非lowrider
				case 549, 604, 605: value = 50.0; // 烂车
				default: value = 100.0;
		    }
	    }
	    case 2:
	    {
		    switch(GetVehicleModel(vehid))
		    {
				case 462, 463, 521, 522, 581, 586, 461: value = 80.0; // 其他摩托
				case 468, 471: value = 90.0; // sanchez 沙地摩托
				case 481, 509, 510: value = 100.0; // 自行车
				case 439, 480, 533, 555: value = 100.0;// 敞篷车 非lowrider
				case 549, 604, 605: value = 50.0; // 烂车
				default: value = 100.0;
			}
	    }
	}
	return value;
}

this::SetPlayerCamera(playerid)
{
	new rand = random(3);

	switch(rand)
	{
		case 0:
		{
   			SetPlayerCameraPos(playerid, 1249.3018, -1697.8046, 99.9554);
			SetPlayerCameraLookAt(playerid, 1249.6576, -1696.8656, 99.4902);
		}
		case 1:
		{
   			SetPlayerCameraPos(playerid, 2151.2539, -1894.5447, 85.3924);
			SetPlayerCameraLookAt(playerid, 2150.5833, -1893.8066, 84.6774);
		}
		case 2:
		{
   			SetPlayerCameraPos(playerid, 2169.0635, -1740.4182, 112.0308);
			SetPlayerCameraLookAt(playerid, 2170.0603, -1740.3655, 111.3108);
		}
	}
	return 1;
}

this::CheckBanList(playerid)
{	
	if(!cache_num_rows())
	{
		new existCheck[129];
	
		mysql_format(this, existCheck, sizeof(existCheck), "SELECT char_dbid FROM characters WHERE char_name = '%e'", ReturnName(playerid));
		mysql_tquery(this, existCheck, "LogPlayerIn", "i", playerid);
	}
	else
	{
		SendServerMessage(playerid, "Your IP \"%s\" is banned from our servers.", ReturnIP(playerid));
		SendServerMessage(playerid, "You may appeal your ban on our forums."); 
		return KickEx(playerid);
	}
	return 1;
}

this::LogPlayerIn(playerid)
{		
	if(!cache_num_rows())
	{	
		for(new i = 0; i < 3; i ++) { SendClientMessage(playerid, -1, " "); }
		
		sendMessage(playerid, COLOR_YELLOWEX, "The user (%s) you're connected with is not a registered master account.", ReturnName(playerid));
		SendClientMessage(playerid, -1, "You need to register this user to continue.");
		
		registerTime[playerid] = 1;
		
		ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "Welcome to Beta Server", "SERVER: You have 60 seconds to register!\nTIP: Please report all bugs that you\nmay have found to development.\n\n           Enter Your Password:", "Select", "Cancel");
		return 1;
	}
	
	loginTime[playerid] = 1; 

	sendMessage(playerid, COLOR_YELLOW, "Welcome to Beta Server, %s {FFFFFF}["SCRIPT_REV"]", ReturnName(playerid));
	return ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Welcome to Beta Server", "SERVER: You have 60 seconds to login!\nTIP: Please report all bugs that you\nmay have found to development.\n\n           Enter Your Password:", "Select", "Cancel");
}

this::OnSecretWordInput(playerid)
{
	if(!cache_num_rows())
	{
		SendClientMessage(playerid, COLOR_RED, "ACCESS DENIED:{FFFFFF} You entered a bad security word. This was logged for security reasons.");
		KickEx(playerid);
		return 1;
	}
	
	new logquery[128];
	
	mysql_format(this, logquery, sizeof(logquery), "SELECT * FROM bannedlist WHERE MasterDBID = %i", e_pAccountData[playerid][mDBID]);
	mysql_tquery(this, logquery, "Query_CheckBannedAccount", "i", playerid);

	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
	if(!PlayerCheckpoint[playerid])
	{	
		PlayerPlaySound(playerid, 1138, 0.0, 0.0, 0.0);
		DisablePlayerCheckpoint(playerid);
	}
	
	if(PlayerCheckpoint[playerid] == 1)
	{
	    if(VehicleInfo[ PlayerInfo[playerid][pVehicleSpawnedID] ][eVehicleStolen]) VehicleInfo[ PlayerInfo[playerid][pVehicleSpawnedID] ][eVehicleStolen] = false;
		GameTextForPlayer(playerid, "~p~You have found it!", 3000, 3);
		PlayerCheckpoint[playerid] = 0; DisablePlayerCheckpoint(playerid);
	}
	
	if(PlayerTakingLicense[playerid])
	{
		if(PlayerCheckpoint[playerid] == 2)
		{
			StopDriverstest(playerid);
			sendMessage(playerid, COLOR_RED, "Congratulations %s, you've passed your test.", ReturnName(playerid, 0));
			
			PlayerInfo[playerid][pDriversLicense] = 1;
			SaveCharacter(playerid);
			
			PlayerCheckpoint[playerid] = 0; 
			return 1; 
		}
	
		if(PlayerLicensePoint[playerid] < sizeof LicensetestInfo)
		{
			SendClientMessage(playerid, COLOR_GREY, "License instructor says: Head to the next checkpoint."); 
			PlayerLicensePoint[playerid]++; 
			
			new 
				idx = PlayerLicensePoint[playerid]
			;
			
			SetPlayerCheckpoint(playerid, LicensetestInfo[idx][eCheckpointX], LicensetestInfo[idx][eCheckpointY], LicensetestInfo[idx][eCheckpointZ], 3.0);
			
			if(LicensetestInfo[idx][eFinishLine])
			{
				//StopDriverstest(playerid);
				PlayerCheckpoint[playerid] = 2;
			}
		}
	}
	
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch (dialogid)
	{
		case DIALOG_CONFIRM_SYS:
		{
			ConfirmDialog_Response(playerid, response);
			return 1;
		}
		case DIALOG_REGISTER:
		{
			if(!response)
			{
				SendClientMessage(playerid, COLOR_REDEX, "You were kicked for not registering.");
				return KickEx(playerid); 
			}
			
			new insert[256]; 
			
			if(strlen(inputtext) > 128 || strlen(inputtext) < 3)
				return ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "Welcome to Beta Server", "SERVER: You have 60 seconds to register!\n\nYour password needs to be greater than 3 and less than 128 characters.\nTIP: Please report all bugs that you\nmay have found to development.\n\n           Enter Your Password:", "Select", "Cancel");
				
			mysql_format(this, insert, sizeof(insert), "INSERT INTO characters (char_name, char_pass, create_date, create_ip, pPhone) VALUES('%e', sha1('%e'), '%e', '%e', %i)", ReturnName(playerid), inputtext, ReturnDate(), ReturnIP(playerid), 94000+random(6999));
			mysql_tquery(this, insert, "OnPlayerRegister", "i", playerid);
		}
		case DIALOG_LOGIN:
		{
			if (!response)
			{
				SendClientMessage(playerid, COLOR_REDEX, "You were kicked for not logging in."); 
				return KickEx(playerid);
			}
			
			new continueCheck[211]; 
			
			mysql_format(this, continueCheck, sizeof(continueCheck), "SELECT char_dbid, forum_name, secret_word, active_ip FROM characters WHERE char_name = '%e' AND char_pass = sha1('%e') LIMIT 1",
				ReturnName(playerid), inputtext);
				
			mysql_tquery(this, continueCheck, "LoggingIn", "i", playerid);
			return 1;
		}
		case DIALOG_REPORT:
		{
			if (!response)
			{
				return SendServerMessage(playerid, "You cancelled your report.");
			}
			
			new idx;
	
			for (new i = 1; i < sizeof(ReportInfo); i ++)
			{
				if (ReportInfo[i][rReportExists] == false)
				{
					idx = i;
					break; 
				}
			}
			
			OnPlayerReport(playerid, idx, playerReport[playerid]); 
		}
		case DIALOG_FACTION_CONFIG:
		{
			if(response)
			{
				switch(listitem)
				{
					case 0: return ShowPlayerDialog(playerid, DIALOG_FACTION_NAME, DIALOG_STYLE_INPUT, "Faction Configuration", "Enter your factions new name:", "Select", "<<"); 
					case 1: return ShowPlayerDialog(playerid, DIALOG_FACTION_ABBREV, DIALOG_STYLE_INPUT, "Faction Configuration", "Enter your factions new abbreviation:", "Select", "<<"); 
					case 2: 
					{
						if(PlayerInfo[playerid][pFactionRank] != 1)
						{
							SendClientMessage(playerid, COLOR_RED, "ACCESS DENIED:{FFFFFF} This configuration is restricted to rank 1 only.");
							return ShowFactionConfig(playerid);
						}
						
						return ShowPlayerDialog(playerid, DIALOG_FACTION_ALTER_R, DIALOG_STYLE_INPUT, "Faction Configuration", "Enter your factions new alter rank:", "Select", "<<"); 
					}
					case 3: return ShowPlayerDialog(playerid, DIALOG_FACTION_ALTER_J, DIALOG_STYLE_INPUT, "Faction Configuration", "Enter your factions new join rank:", "Select", "<<");
					case 4: return ShowPlayerDialog(playerid, DIALOG_FACTION_ALTER_C, DIALOG_STYLE_INPUT, "Faction Configuration", "Enter your factions new chat rank:", "Select", "<<"); 
					case 5: return ShowPlayerDialog(playerid, DIALOG_FACTION_CHATCOLOR, DIALOG_STYLE_INPUT, "Faction Configuration", "Enter your factions new chat color: (Example: 0x8D8DFFFF)", "Select", "<<");
					case 6: return ShowPlayerDialog(playerid, DIALOG_FACTION_RANKS, DIALOG_STYLE_INPUT, "Faction Configuration", "Enter the factions rank ID you want to alter. (1-20)", "Select", "<<");
					case 7:
					{
						if(PlayerInfo[playerid][pFactionRank] != 1)
							return SendErrorMessage(playerid, "The factions spawn may only be changed by rank 1.");
					
						new factionid = PlayerInfo[playerid][pFaction]; 
					
						GetPlayerPos(playerid, FactionInfo[factionid][eFactionSpawn][0], FactionInfo[factionid][eFactionSpawn][1], FactionInfo[factionid][eFactionSpawn][2]);
		
						FactionInfo[factionid][eFactionSpawnInt] = GetPlayerInterior(playerid);
					
						if(GetPlayerInterior(playerid) != 0)
							FactionInfo[factionid][eFactionSpawnWorld] = random(50000)+playerid+5; 
							
						else FactionInfo[factionid][eFactionSpawnWorld] = GetPlayerVirtualWorld(playerid);
						
						SendServerMessage(playerid, "Your factions spawn has been altered."); 
						return ShowFactionConfig(playerid);
					}
					case 8: return ShowPlayerDialog(playerid, DIALOG_FACTION_ALTER_T, DIALOG_STYLE_INPUT, "Faction Configuration", "Enter the factions new tow rank:", "Select", "<<"); 
				}
			}
		}
		case DIALOG_FACTION_NAME:
		{
			if(!response)
				return ShowFactionConfig(playerid);
			
			if(strlen(inputtext) > 90 || strlen(inputtext) < 3)
				return ShowPlayerDialog(playerid, DIALOG_FACTION_NAME, DIALOG_STYLE_INPUT, "Faction Configuration", "Your factions name must be less than 90 characters.\n\nEnter your factions new name:", "Select", "<<"); 
			
			format(FactionInfo[PlayerInfo[playerid][pFaction]][eFactionName], 90, "%s", inputtext);
			SendServerMessage(playerid, "Your factions name is now: \"%s\".", inputtext);
			
			return ShowFactionConfig(playerid);
		}
		case DIALOG_FACTION_ABBREV:
		{
			if(!response)
				return ShowFactionConfig(playerid);
			
			if(strlen(inputtext) > 30 || strlen(inputtext) < 1)
				return ShowPlayerDialog(playerid, DIALOG_FACTION_NAME, DIALOG_STYLE_INPUT, "Faction Configuration", "Your factions name must be less than 30 characters and more than 1.\n\nEnter your factions new name:", "Select", "<<"); 
				
			format(FactionInfo[PlayerInfo[playerid][pFaction]][eFactionAbbrev], 30, "%s", inputtext);
			SendServerMessage(playerid, "Your factions abbreviation is now: \"%s\".", inputtext);
			
			return ShowFactionConfig(playerid);
		}
		case DIALOG_FACTION_ALTER_R:
		{
			if(!response)
				return ShowFactionConfig(playerid);
			
			if(strlen(inputtext) < 1 || strlen(inputtext) > 2)
				return ShowPlayerDialog(playerid, DIALOG_FACTION_ALTER_R, DIALOG_STYLE_INPUT, "Faction Configuration", "Enter your factions new alter rank:", "Select", "<<"); 

			new rankid = strval(inputtext); 
			
			if(rankid > 20 || rankid < 1)
				return ShowPlayerDialog(playerid, DIALOG_FACTION_ALTER_R, DIALOG_STYLE_INPUT, "Faction Configuration", "Your factions alter rank must be between 1-20.\n\nEnter your factions new alter rank:", "Select", "<<"); 
			
			FactionInfo[PlayerInfo[playerid][pFaction]][eFactionAlterRank] = rankid;
			SendServerMessage(playerid, "Your factions alter rank is now: %i.", rankid);
			
			return ShowFactionConfig(playerid);
		}
		case DIALOG_FACTION_ALTER_J:
		{
			if(!response)
				return ShowFactionConfig(playerid);
			
			if(strlen(inputtext) < 1 || strlen(inputtext) > 2)
				return ShowPlayerDialog(playerid, DIALOG_FACTION_ALTER_J, DIALOG_STYLE_INPUT, "Faction Configuration", "Enter your factions new join rank:", "Select", "<<"); 

			new rankid = strval(inputtext); 
			
			if(rankid > 20 || rankid < 1)
				return ShowPlayerDialog(playerid, DIALOG_FACTION_ALTER_J, DIALOG_STYLE_INPUT, "Faction Configuration", "Your factions join rank must be between 1-20.\n\nEnter your factions new join rank:", "Select", "<<"); 
			
			FactionInfo[PlayerInfo[playerid][pFaction]][eFactionJoinRank] = rankid;
			SendServerMessage(playerid, "Your factions join rank is now: %i.", rankid);
			
			return ShowFactionConfig(playerid);
		}
		case DIALOG_FACTION_ALTER_C:
		{
			if(!response)
				return ShowFactionConfig(playerid);
			
			if(strlen(inputtext) < 1 || strlen(inputtext) > 2)
				return ShowPlayerDialog(playerid, DIALOG_FACTION_ALTER_C, DIALOG_STYLE_INPUT, "Faction Configuration", "Enter your factions new chat rank:", "Select", "<<"); 

			new rankid = strval(inputtext); 
			
			if(rankid > 20 || rankid < 1)
				return ShowPlayerDialog(playerid, DIALOG_FACTION_ALTER_C, DIALOG_STYLE_INPUT, "Faction Configuration", "Your factions chat rank must be between 1-20.\n\nEnter your factions new chat rank:", "Select", "<<"); 
			
			FactionInfo[PlayerInfo[playerid][pFaction]][eFactionChatRank] = rankid;
			SendServerMessage(playerid, "Your factions chat rank is now: %i.", rankid);
			
			return ShowFactionConfig(playerid);
		}
		case DIALOG_FACTION_ALTER_T:
		{
			if(!response)
				return ShowFactionConfig(playerid);
			
			if(strlen(inputtext) < 1 || strlen(inputtext) > 2)
				return ShowPlayerDialog(playerid, DIALOG_FACTION_ALTER_T, DIALOG_STYLE_INPUT, "Faction Configuration", "Enter your factions new tow rank:", "Select", "<<"); 
				
			new rankid = strval(inputtext); 
			
			if(rankid > 20 || rankid < 1)
				return ShowPlayerDialog(playerid, DIALOG_FACTION_ALTER_T, DIALOG_STYLE_INPUT, "Faction Configuration", "Your factions chat rank must be between 1-20.\n\nEnter your factions new tow rank:", "Select", "<<");

			FactionInfo[PlayerInfo[playerid][pFaction]][eFactionTowRank] = rankid;
			SendServerMessage(playerid, "Your factions tow rank is now: %i.", rankid);
			
			return ShowFactionConfig(playerid);
		}
		case DIALOG_FACTION_CHATCOLOR:
		{
			if(!response)
				return ShowFactionConfig(playerid);
			
			FactionInfo[PlayerInfo[playerid][pFaction]][eFactionChatColor] = HexToInt(inputtext);
			SendServerMessage(playerid, "Your factions chat color was altered.");
			
			return ShowFactionConfig(playerid);
		}
		case DIALOG_FACTION_RANKS:
		{
			if(!response)
				return ShowFactionConfig(playerid);
				
			new rankid = strval(inputtext), str[128];
			
			if(rankid > 20 || rankid < 1)
				return ShowPlayerDialog(playerid, DIALOG_FACTION_RANKS, DIALOG_STYLE_INPUT, "Faction Configuration", "Enter the factions rank ID you want to alter. (1-20)", "Select", "<<");
				
			playerEditingRank[playerid] = rankid;
			
			format(str, sizeof(str), "You're editing your factions rank ID %i ('%s').\n\n{F81414}To remove this rank, set the name to \"NotSet\". Case sensitive.", rankid, FactionRanks[PlayerInfo[playerid][pFaction]][rankid]);
			return ShowPlayerDialog(playerid, DIALOG_FACTION_RANKEDIT, DIALOG_STYLE_INPUT, "Faction Configuration", str, "Select", "<<"); 
		}
		case DIALOG_FACTION_RANKEDIT:
		{
			if(!response)
				return ShowFactionConfig(playerid);
				
			new str[128];
				
			if(strlen(inputtext) > 60 || strlen(inputtext) < 1)
			{
				format(str, sizeof(str), "Your rank should be less than 60 characters.\n\nYou're editing your factions rank ID %i ('%s').\n{F81414}To remove this rank, set the name to \"NotSet\". Case sensitive.", FactionRanks[PlayerInfo[playerid][pFaction]][playerEditingRank[playerid]], playerEditingRank[playerid]);
				return ShowPlayerDialog(playerid, DIALOG_FACTION_RANKEDIT, DIALOG_STYLE_INPUT, "Faction Configuration", str, "Select", "<<"); 
			}
			
			SendServerMessage(playerid, "You edited faction rank %i (%s) to: \"%s\". ", playerEditingRank[playerid], FactionRanks[PlayerInfo[playerid][pFaction]][playerEditingRank[playerid]], inputtext);
			format(FactionRanks[PlayerInfo[playerid][pFaction]][playerEditingRank[playerid]], 60, "%s", inputtext);
			
			return ShowFactionConfig(playerid);
		}
		case DIALOG_VEHICLE_WEAPONS:
		{
			if(response)
			{
				new vehicleid = INVALID_VEHICLE_ID;

				if(!IsPlayerInAnyVehicle(playerid))
					vehicleid = GetNearestVehicle(playerid);

				else
					vehicleid = GetPlayerVehicleID(playerid);

				if(vehicleid == INVALID_VEHICLE_ID)
					return SendErrorMessage(playerid, "You're no longer in or near a vehicle.");

				if(!vehicle_trunk_data[vehicleid][listitem+1][is_exist])
					return SendErrorMessage(playerid, "The weapon slot you selected is invalid. (if it's not empty please contact an admin)");

                RemoveWeaponFromTrunk(playerid, vehicleid, listitem+1);
				SaveCharacter(playerid);
				return 1;
			}
		}
		case DIALOG_HOUSE_WEAPONS:
		{
			if(response)
			{
				new
					id = IsPlayerInProperty(playerid),
					str[128]
				;
				
				if(!PropertyInfo[id][ePropertyWeapons][listitem+1])
					return SendErrorMessage(playerid, "The weapon slot you selected is empty."); 
					
				GivePlayerGun(playerid, PropertyInfo[id][ePropertyWeapons][listitem+1], PropertyInfo[id][ePropertyWeaponsAmmo][listitem+1]);
				
				format(str, sizeof(str), "* %s takes a %s from the house.", ReturnName(playerid, 0), ReturnWeaponName(PropertyInfo[id][ePropertyWeapons][listitem+1])); 
				SetPlayerChatBubble(playerid, str, COLOR_EMOTE, 20.0, 4500); 
				SendClientMessage(playerid, COLOR_EMOTE, str); 
				
				PropertyInfo[id][ePropertyWeapons][listitem+1] = 0; 
				PropertyInfo[id][ePropertyWeaponsAmmo][listitem+1] = 0; 
			
				SaveCharacter(playerid); SaveProperty(id);
				return 1;
			}
		}
		case DIALOG_XMR_CATEGORIES:
		{
			if(response)
			{
				new 
					liststr[500], 
					counter = 0
				;
					
				CatXMRHolder[playerid] = listitem+1;
				
				for(new i = 1; i < MAX_XMR_CATEGORY_STATIONS; i++)
				{
					if(CatXMRHolder[playerid] == XMRStationInfo[i][eXMRCategory])
					{
						format(liststr, sizeof(liststr), "%sID:%d - %s\n", liststr, XMRStationInfo[i][eXMRStationID], XMRStationInfo[i][eXMRStationName]);
					
						SubXMRHolderArr[playerid][counter] = i; 
						counter ++; 	
					}
				}
				
				strcat(liststr, "{FFE104}OFF - Click to turn off.\n"); 
				ShowPlayerDialog(playerid, DIALOG_XMR_STATIONS, DIALOG_STYLE_LIST, "Stations:", liststr, "Select", "<<"); 		
				return 1;
			}
		}
		case DIALOG_XMR_STATIONS:
		{
			if(response)
			{
				new 
					vehicleid = INVALID_VEHICLE_ID;
					
				if(IsPlayerInAnyVehicle(playerid))
					vehicleid = GetPlayerVehicleID(playerid);
			
				if(!strcmp(inputtext, "OFF - Click to turn off."))
				{
					PlayXMRStation(playerid, vehicleid, IsPlayerInProperty(playerid), true); 
					return 1;
				}
			
				SubXMRHolder[playerid] = SubXMRHolderArr[playerid][listitem]; 
					
				PlayXMRStation(playerid, vehicleid, IsPlayerInProperty(playerid)); 
			}
			return 1;
		}
		case DIALOG_POLICE_SKINS:
		{
			if(response)
			{
				switch(listitem)
				{
					case 0: SetPlayerSkin(playerid, 280);
					case 1: SetPlayerSkin(playerid, 300);
					case 2: SetPlayerSkin(playerid, 281);
					case 3: SetPlayerSkin(playerid, 301);
					case 4: SetPlayerSkin(playerid, 306);
					case 5: SetPlayerSkin(playerid, 307);
					case 6: SetPlayerSkin(playerid, 265);
					case 7: SetPlayerSkin(playerid, 267);
					case 8: SetPlayerSkin(playerid, 266);
					case 9: SetPlayerSkin(playerid, 284);
					case 10: SetPlayerSkin(playerid, 61);
					case 11: SetPlayerSkin(playerid, 93);
				}
			}
			return 1;
		}
		case DIALOG_DEALERSHIP:
		{
			if(response)
			{
				new larstr[600],
					counter = 0
				; 
				
				CatDealershipHolder[playerid] = listitem; 
				
				for(new i = 0; i < sizeof(g_aDealershipData); i++)
				{
					if(listitem == g_aDealershipData[i][eDealershipCategory])
					{
						format(larstr, sizeof(larstr), "%s%s\t\t\t$%s\n", larstr, g_aDealershipData[i][eDealershipModel], MoneyFormat(g_aDealershipData[i][eDealershipPrice]));
						
						SubDealershipHolderArr[playerid][counter] = i; 
						counter++; 
					}
				}
				
				ShowPlayerDialog(playerid, DIALOG_DEALERSHIP_SELECT, DIALOG_STYLE_LIST, "Available Models:", larstr, "Select", "<<"); 
			}
			return 1;
		}
		case DIALOG_DEALERSHIP_SELECT:
		{
			if(!response)
			{
				new catstr[190];
				
				for(new i = 0; i < sizeof(g_aDealershipCategory); i++)
				{
					format(catstr, sizeof(catstr), "%s%s\n", catstr, g_aDealershipCategory[i][dealerName]);
				}
				
				return ShowPlayerDialog(playerid, DIALOG_DEALERSHIP, DIALOG_STYLE_LIST, "Categories:", catstr, "Select", "Cancel");			
			}
	
			SubDealershipHolder[playerid] = SubDealershipHolderArr[playerid][listitem]; 
			
			new
				i,
				d,
				str[128],
				caption[60]
			; 
				
			i = SubDealershipHolder[playerid];
			d = PlayerInfo[playerid][pAtDealership]; 
			
			if(g_aDealershipData[i][eDealershipPrice] > PlayerInfo[playerid][pMoney])
				return SendServerMessage(playerid, "You need $%s to buy this. (Total: $%s)", MoneyFormat(g_aDealershipData[i][eDealershipPrice]), MoneyFormat(PlayerInfo[playerid][pMoney])); 
				
			DealershipTotalCost[playerid] = g_aDealershipData[i][eDealershipPrice] + GetPVarInt(playerid, "InsPrice") + GetPVarInt(playerid, "LockPrice") + GetPVarInt(playerid, "ImmobPrice") + GetPVarInt(playerid, "AlarmPrice");
			
			format(caption, 60, "%s - {33AA33}%s", g_aDealershipData[i][eDealershipModel], MoneyFormat(DealershipTotalCost[playerid]));
			
			strcat(str, "Alarm\n");
			strcat(str, "Lock\n");
			strcat(str, "Immobiliser\n");
			strcat(str, "Insurance\n");
			strcat(str, "Colors\n");
			strcat(str, "No XM Installed\n");
			strcat(str, "{FFFF00}Purchase Vehicle\n"); 
			
			TogglePlayerControllable(playerid, 0); 
			
			DealershipPlayerCar[playerid] = 
				CreateVehicle(g_aDealershipData[i][eDealershipModelID], BusinessInfo[d][eBusinessInterior][0], BusinessInfo[d][eBusinessInterior][1], BusinessInfo[d][eBusinessInterior][2], 90.0, 0, 0, -1);
				
			PutPlayerInVehicle(playerid, DealershipPlayerCar[playerid], 0); 
			
			printf("[DEBUG]: Player %s (ID : %i) was spawned in a Dealership vehicle. (Vehicle ID: %d)", ReturnName(playerid), playerid, DealershipPlayerCar[playerid]); 
			ShowPlayerDialog(playerid, DIALOG_DEALERSHIP_APPEND, DIALOG_STYLE_LIST, caption, str, "Append", "<<");
			return 1;
		}
		case DIALOG_DEALERSHIP_APPEND:
		{
			new
				caption[60],
				str[400],
				price[128]
			; 
			
			

			format(caption, 60, "%s - {33AA33}%s", g_aDealershipData[SubDealershipHolder[playerid]][eDealershipModel], MoneyFormat(DealershipTotalCost[playerid] + GetPVarInt(playerid, "InsPrice") + GetPVarInt(playerid, "LockPrice") + GetPVarInt(playerid, "ImmobPrice") + GetPVarInt(playerid, "AlarmPrice")));
			
			if(response)
			{
				switch(listitem)
				{
					case 0: //Alarms;
					{
					    new car_price = g_aDealershipData[ SubDealershipHolder[playerid] ][eDealershipPrice];
                        strcat(str, "No Alarm\n");
						if(DealershipAlarmLevel[playerid] == 1)
						{
							format(price, sizeof(price), "{FFFF00}>>{FFFFFF}Alarm Level 1 - $%s\n", MoneyFormat(floatround(car_price * 0.20 * 1)));
							strcat(str, price);
						}
						else { format(price, sizeof(price), "Alarm Level 1 - $%s\n", MoneyFormat(floatround(car_price * 0.20 * 1))), strcat(str, price); }

						if(DealershipAlarmLevel[playerid] == 2)
						{
							format(price, sizeof(price), "{FFFF00}>>{FFFFFF}Alarm Level 2 - $%s\n", MoneyFormat(floatround(car_price * 0.20 * 2)));
							strcat(str, price);
						}
						else
						{
						    format(price, sizeof(price), "Alarm Level 2 - $%s\n", MoneyFormat(floatround(car_price * 0.20 * 2)));
							strcat(str, price);
						}
						if(DealershipAlarmLevel[playerid] == 3)
						{
							format(price, sizeof(price), "{FFFF00}>>{FFFFFF}Alarm Level 3 - $%s\n", MoneyFormat(floatround(car_price * 0.20 * 3)));
							strcat(str, price);
						}
						else
						{
						    format(price, sizeof(price), "Alarm Level 3 - $%s\n", MoneyFormat(floatround(car_price * 0.20 * 3)));
							strcat(str, price);
						}
						if(DealershipAlarmLevel[playerid] == 4)
						{
							format(price, sizeof(price), "{FFFF00}>>{FFFFFF}Alarm Level 4 - $%s\n", MoneyFormat(floatround(car_price * 0.20 * 4)));
							strcat(str, price);
						}
						else
						{
						    format(price, sizeof(price), "Alarm Level 4 - $%s\n", MoneyFormat(floatround(car_price * 0.20 * 4)));
							strcat(str, price);
						}
						
						ShowPlayerDialog(playerid, DIALOG_DEALERSHIP_APPEND_ALARM, DIALOG_STYLE_LIST, caption, str, "Select", "<<"); 
					}
					case 1: //Locks;
					{
					    new car_price = g_aDealershipData[ SubDealershipHolder[playerid] ][eDealershipPrice];
						if(DealershipLockLevel[playerid] == 0)
						{
							strcat(str, "{FFFF00}>>{FFFFFF}Lock Level 1 - $0\n");
						}
						else { strcat(str, "Lock Level 1 - $0\n"); }
						
						if(DealershipLockLevel[playerid] == 1)
						{
							format(price, sizeof(price), "{FFFF00}>>{FFFFFF}Lock Level 2 - $%s\n", MoneyFormat(floatround(car_price * 0.15 * 1)));
							strcat(str, price);
						}
						else { format(price, sizeof(price), "Lock Level 2 - $%s\n", MoneyFormat(floatround(car_price * 0.15 * 1))), strcat(str, price); }

						if(DealershipLockLevel[playerid] == 2)
						{
							format(price, sizeof(price), "{FFFF00}>>{FFFFFF}Lock Level 3 - $%s\n", MoneyFormat(floatround(car_price * 0.15 * 2)));
							strcat(str, price);
						}
						else
						{
						    format(price, sizeof(price), "Lock Level 3 - $%s\n", MoneyFormat(floatround(car_price * 0.15 * 2)));
							strcat(str, price);
						}
						if(DealershipLockLevel[playerid] == 3)
						{
							format(price, sizeof(price), "{FFFF00}>>{FFFFFF}Lock Level 4 - $%s\n", MoneyFormat(floatround(car_price * 0.15 * 3)));
							strcat(str, price);
						}
						else
						{
						    format(price, sizeof(price), "Lock Level 4 - $%s\n", MoneyFormat(floatround(car_price * 0.15 * 3)));
							strcat(str, price);
						}
						if(DealershipLockLevel[playerid] == 4)
						{
							format(price, sizeof(price), "{FFFF00}>>{FFFFFF}Lock Level 5 - $%s\n", MoneyFormat(floatround(car_price * 0.15 * 4)));
							strcat(str, price);
						}
						else
						{
						    format(price, sizeof(price), "Lock Level 5 - $%s\n", MoneyFormat(floatround(car_price * 0.15 * 4)));
							strcat(str, price);
						}
						
						ShowPlayerDialog(playerid, DIALOG_DEALERSHIP_APPEND_LOCK, DIALOG_STYLE_LIST, caption, str, "Select", "<<"); 
					}
					case 2: //Immob;
					{
					
					    new car_price = g_aDealershipData[ SubDealershipHolder[playerid] ][eDealershipPrice];
                        strcat(str, "None\n");
						if(DealershipImmobLevel[playerid] == 1)
						{
							format(price, sizeof(price), "{FFFF00}>>{FFFFFF}Immob Level 1 - $%s\n", MoneyFormat(floatround(car_price * 0.23 * 1)));
							strcat(str, price);
						}
						else { format(price, sizeof(price), "Immob Level 1 - $%s\n", MoneyFormat(floatround(car_price * 0.23 * 1))), strcat(str, price); }

						if(DealershipImmobLevel[playerid] == 2)
						{
							format(price, sizeof(price), "{FFFF00}>>{FFFFFF}Immob Level 2 - $%s\n", MoneyFormat(floatround(car_price * 0.23 * 2)));
							strcat(str, price);
						}
						else
						{
						    format(price, sizeof(price), "Immob Level 2 - $%s\n", MoneyFormat(floatround(car_price * 0.23 * 2)));
							strcat(str, price);
						}
						if(DealershipImmobLevel[playerid] == 3)
						{
							format(price, sizeof(price), "{FFFF00}>>{FFFFFF}Immob Level 3 - $%s\n", MoneyFormat(floatround(car_price * 0.23 * 3)));
							strcat(str, price);
						}
						else
						{
						    format(price, sizeof(price), "Immob Level 3 - $%s\n", MoneyFormat(floatround(car_price * 0.23 * 3)));
							strcat(str, price);
						}
						if(DealershipImmobLevel[playerid] == 4)
						{
							format(price, sizeof(price), "{FFFF00}>>{FFFFFF}Immob Level 4 - $%s\n", MoneyFormat(floatround(car_price * 0.23 * 4)));
							strcat(str, price);
						}
						else
						{
						    format(price, sizeof(price), "Immob Level 4 - $%s\n", MoneyFormat(floatround(car_price * 0.23 * 4)));
							strcat(str, price);
						}
						ShowPlayerDialog(playerid, DIALOG_DEALERSHIP_APPEND_IMMOB, DIALOG_STYLE_LIST, caption, str, "Select", "<<"); 
					}
					case 3: //Ins
					{
					    new car_price = g_aDealershipData[ SubDealershipHolder[playerid] ][eDealershipPrice];
                        strcat(str, "None\n");
						if(DealershipInsLevel[playerid] == 1)
						{
							format(price, sizeof(price), "{FFFF00}>>{FFFFFF}Insurance Level 1 - $%s\n", MoneyFormat(floatround(car_price * 0.25 * 1)));
							strcat(str, price);
						}
						else { format(price, sizeof(price), "Insurance Level 1 - $%s\n", MoneyFormat(floatround(car_price * 0.25 * 1))), strcat(str, price); }

						if(DealershipInsLevel[playerid] == 2)
						{
							format(price, sizeof(price), "{FFFF00}>>{FFFFFF}Insurance Level 2 - $%s\n", MoneyFormat(floatround(car_price * 0.25 * 2)));
							strcat(str, price);
						}
						else
						{
						    format(price, sizeof(price), "Insurance Level 2 - $%s\n", MoneyFormat(floatround(car_price * 0.25 * 2)));
							strcat(str, price);
						}
						if(DealershipInsLevel[playerid] == 2)
						{
							format(price, sizeof(price), "{FFFF00}>>{FFFFFF}Insurance Level 3 - $%s\n", MoneyFormat(floatround(car_price * 0.25 * 3)));
							strcat(str, price);
						}
						else
						{
						    format(price, sizeof(price), "Insurance Level 3 - $%s\n", MoneyFormat(floatround(car_price * 0.25 * 3)));
							strcat(str, price);
						}
						ShowPlayerDialog(playerid, DIALOG_DEALERSHIP_APPEND_INS, DIALOG_STYLE_LIST, caption, str, "Select", "<<");
					}
					case 4: //Colors
					{
                        DisplayColors(playerid, true);
                        SelectTextDraw(playerid, COLOR_GREY);
					}
					case 5: //XM-Radio
					{
						if(!DealershipXMR[playerid])
						{
							DealershipXMR[playerid] = 1;
							DealershipTotalCost[playerid] += 10000;
						}	
						else
						{
							DealershipXMR[playerid] = 0;
							DealershipTotalCost[playerid] -= 10000;
						}
						return ShowDealerAppend(playerid);
					}
					case 6: //Purchase
					{
						new
							dstr[128],
							Float:vehMass,
							Float:vehVelo,
							vehDrive[60],
							vehFuel[60]
						;
						
						vehMass = GetVehicleModelInfoAsFloat(GetVehicleModel(DealershipPlayerCar[playerid]), "fMass"); 
						vehVelo = GetVehicleModelInfoAsFloat(GetVehicleModel(DealershipPlayerCar[playerid]), "TransmissionData_fMaxVelocity"); 
						
						
						if(GetVehicleModelInfoAsInt(GetVehicleModel(DealershipPlayerCar[playerid]), "TransmissionData_nDriveType") == 'F')
							vehDrive = "Front-Wheel Drive";
							
						else if(GetVehicleModelInfoAsInt(GetVehicleModel(DealershipPlayerCar[playerid]), "TransmissionData_nDriveType") == 'R')
							vehDrive = "Rear-Wheel Drive";
						
						else if(GetVehicleModelInfoAsInt(GetVehicleModel(DealershipPlayerCar[playerid]), "TransmissionData_nDriveType") == '4')
							vehDrive = "4-Wheel Drive";
						
						
						if(GetVehicleModelInfoAsInt(GetVehicleModel(DealershipPlayerCar[playerid]), "TransmissionData_nEngineType") == 'P')
							vehFuel = "Petrol";
							
						else if(GetVehicleModelInfoAsInt(GetVehicleModel(DealershipPlayerCar[playerid]), "TransmissionData_nEngineType") == 'D')
							vehFuel = "Diesel";
							
						else if(GetVehicleModelInfoAsInt(GetVehicleModel(DealershipPlayerCar[playerid]), "TransmissionData_nEngineType") == 'E')
							vehFuel = "Electric";
						
						format(dstr, sizeof(dstr), "{FFFF00}Value:\t\t{FFFFFF}$%s \n", MoneyFormat(g_aDealershipData[SubDealershipHolder[playerid]][eDealershipPrice]));
						strcat(str, dstr);
						
						format(dstr, sizeof(dstr), "{FFFF00}Max Speed:\t\t{FFFFFF}%.1f \n", GetVehicleTopSpeed(DealershipPlayerCar[playerid])); 
						strcat(str, dstr); 
						
						format(dstr, sizeof(dstr), "{FFFF00}Max Velocity:\t\t{FFFFFF}%.2f \n", vehVelo);
						strcat(str, dstr); 
						
						format(dstr, sizeof(dstr), "{FFFF00}Max Health:\t\t{FFFFFF}%.2f \n", getVehicleCondition(DealershipPlayerCar[playerid], 0));
						strcat(str, dstr);
						
						format(dstr, sizeof(dstr), "{FFFF00}Mass:\t\t{FFFFFF}%.2f \n\n", vehMass);
						strcat(str, dstr);

						format(dstr, sizeof(dstr), "{FFFF00}Engine Drive:\t\t{FFFFFF}%s \n", vehDrive);
						strcat(str, dstr); 
						
						format(dstr, sizeof(dstr), "{FFFF00}Engine Fuel:\t\t{FFFFFF}%s \n\n", vehFuel); 
						strcat(str, dstr);
						
						if(DealershipXMR[playerid])
							strcat(str, "{FFFF00}XM-Radio:\t\t{FFFFFF}$10,000\n");
						
						ShowPlayerDialog(playerid, DIALOG_DEALERSHIP_PURCHASE, DIALOG_STYLE_MSGBOX, caption, str, "Edit", "Checkout"); 
						return 1;
					}
				}
			}
			else ConfirmDialog(playerid, "Confirmation", "Are you sure you want to exit?", "OnPlayerExitDealership"); 
			return 1;
		}
		case DIALOG_DEALERSHIP_PURCHASE:
		{		
			if(response)
			{
				return ShowDealerAppend(playerid);
			}
			else
			{
			    new price = DealershipTotalCost[playerid] + GetPVarInt(playerid, "InsPrice") + GetPVarInt(playerid, "LockPrice") + GetPVarInt(playerid, "ImmobPrice") + GetPVarInt(playerid, "AlarmPrice");
				if(price > PlayerInfo[playerid][pMoney])
				{
					SendServerMessage(playerid, "You can't afford the total price. (Price: $%s, Total:$%s)", MoneyFormat(price), MoneyFormat(PlayerInfo[playerid][pMoney]));
					
					DestroyVehicle(DealershipPlayerCar[playerid]);
					TogglePlayerControllable(playerid, 1);
					
					return ResetDealershipVars(playerid);
				}
				
				new
					idx, 
					plates[32],
					randset[3],
					insert[256],
					Float:x,
					Float:y,
					Float:z,
					Float:a
				;
				
				for(new i = 1; i < MAX_PLAYER_VEHICLES; i++)
				{
					if(!PlayerInfo[playerid][pOwnedVehicles][i])
					{
						idx = i;
						break;
					}
				}
				
				GetVehiclePos(DealershipPlayerCar[playerid], x, y, z); 
				GetVehicleZAngle(DealershipPlayerCar[playerid], a); 
				
				randset[0] = random(sizeof(possibleVehiclePlates)); 
				randset[1] = random(sizeof(possibleVehiclePlates)); 
				randset[2] = random(sizeof(possibleVehiclePlates)); 
				
				format(plates, 32, "%d%s%s%s%d%d%d", random(9), possibleVehiclePlates[randset[0]], possibleVehiclePlates[randset[1]], possibleVehiclePlates[randset[2]], random(9), random(9)); 
				GiveMoney(playerid, -price);
				
				SendClientMessage(playerid, 0xB9E35EFF, "PROCESSING: Your vehicles being setup.");
				sendTextInfo(playerid, "YOUR_NEW_PLATE_HAS_BEEN_SET", plates);
				
				mysql_format(this, insert, sizeof(insert), "INSERT INTO vehicles (VehicleOwnerDBID, VehicleModel, VehicleParkPosX, VehicleParkPosY, VehicleParkPosZ, VehicleParkPosA) VALUES(%i, %i, %f, %f, %f, %f)",
					PlayerInfo[playerid][pDBID], g_aDealershipData[SubDealershipHolder[playerid]][eDealershipModelID], x, y, z, a); 
					
				mysql_tquery(this, insert, "OnPlayerVehiclePurchase", "iisffff", playerid, idx, plates, x, y, z, a);
				
				PlayerPurchasingVehicle[playerid] = true; 
				TogglePlayerControllable(playerid, 1);
			}
			return 1;
		}
		case DIALOG_DEALERSHIP_APPEND_ALARM:
		{
			if(response)
			{
				if(listitem == 0)
				{
					SetPVarInt(playerid, "AlarmPrice", 0);
					DealershipAlarmLevel[playerid] = 0;
				}
				else
				{
					DealershipAlarmLevel[playerid] = listitem;
					SetPVarInt(playerid, "AlarmPrice", floatround(g_aDealershipData[ SubDealershipHolder[playerid] ][eDealershipPrice] * 0.20 * listitem));
				}
				ShowDealerAppend(playerid);
			}
			else return ShowDealerAppend(playerid);
			return 1;
		}
		case DIALOG_DEALERSHIP_APPEND_LOCK:
		{
			if(response)
			{
				if(listitem == 0)
				{
					SetPVarInt(playerid, "LockPrice", 0);
					DealershipLockLevel[playerid] = 0;
				}
				else
				{
					DealershipLockLevel[playerid] = listitem;
					SetPVarInt(playerid, "LockPrice", floatround(g_aDealershipData[ SubDealershipHolder[playerid] ][eDealershipPrice] * 0.15 * listitem));
				}
				ShowDealerAppend(playerid);
			}
			else return ShowDealerAppend(playerid);
			return 1;
		}
		case DIALOG_DEALERSHIP_APPEND_IMMOB:
		{
			if(response)
			{
				if(listitem == 0)
				{
					SetPVarInt(playerid, "ImmobPrice", 0);
					DealershipImmobLevel[playerid] = 0;
				}
				else
				{
					DealershipImmobLevel[playerid] = listitem;
					SetPVarInt(playerid, "LockPrice", floatround(g_aDealershipData[ SubDealershipHolder[playerid] ][eDealershipPrice] * 0.23 * listitem));
				}
				ShowDealerAppend(playerid);
			}
			else return ShowDealerAppend(playerid);
			return 1;
		}
		case DIALOG_DEALERSHIP_APPEND_INS:
		{
			if(response)
			{
				if(listitem == 0)
				{
					SetPVarInt(playerid, "InsPrice", 0);
					DealershipInsLevel[playerid] = 0;
				}
				else
				{
					DealershipInsLevel[playerid] = listitem;
					SetPVarInt(playerid, "LockPrice", floatround(g_aDealershipData[ SubDealershipHolder[playerid] ][eDealershipPrice] * 0.25 * listitem));
				}
				ShowDealerAppend(playerid);
			}
			else return ShowDealerAppend(playerid);
			return 1;
		}
		case DIALOG_SELECT_HOUSE:
		{
			if(response)
			{
				new
					id
				;
				
				id = playerHouseSelect[playerid][listitem];
			
				PlayerInfo[playerid][pSpawnPoint] = SPAWN_POINT_PROPERTY;
				PlayerInfo[playerid][pSpawnPointHouse] = id;
				
				SendServerMessage(playerid, "You selected Property %i and will now spawn there.", listitem); 
			}
			return 1;
		}
		case DIALOG_MDC:
		{
			if(response)
			{
				switch(listitem)
				{
					case 0: return ShowPlayerDialog(playerid, DIALOG_MDC_NAME, DIALOG_STYLE_INPUT, "Name Search - MDC", "Enter the persons full name to search below:", "Search", "<<"); 
					case 1: return ShowPlayerDialog(playerid, DIALOG_MDC_PLATE, DIALOG_STYLE_INPUT, "Plate Search - MDC", "Enter the vehicles full or partial plate to search below:", "Search", "<<"); 
				}
				return 1;
			}
		}
		case DIALOG_MDC_NAME:
		{
			if(response)
			{
				if(strlen(inputtext) < 3 || strlen(inputtext) > 32)
					return ShowPlayerDialog(playerid, DIALOG_MDC_NAME, DIALOG_STYLE_INPUT, "Name Search - MDC", "Enter the persons full name to search below:", "Search", "<<"); 
					
				for(new i = 0; i < strlen(inputtext); i++)
				{
					if(inputtext[i] == '_')
					{
						return ShowPlayerDialog(playerid, DIALOG_MDC_NAME, DIALOG_STYLE_INPUT, "Name Search - MDC", "Enter the persons full name to search below:", "Search", "<<"); 
					}
					else
					{
						if(inputtext[i] == ' ')
						{
							inputtext[i] = '_';
						}
					}
				}
				
				PlayerMDCCount[playerid] = 0;
				PlayerMDCTimer[playerid] = SetTimerEx("OnMDCSearch", 1000, true, "ii", playerid, 1);
				format(PlayerMDCName[playerid], 32, "%s", inputtext); 
    			PlayerTextDrawSetString(playerid, MDC_UI[playerid][64], "Searching.");
				return 1;
			}
			else return 1;
		}
		case DIALOG_MDC_PLATE:
		{
			if(response)
			{
				if(strlen(inputtext) > 6 || strlen(inputtext) < 3)
					return ShowPlayerDialog(playerid, DIALOG_MDC_PLATE, DIALOG_STYLE_INPUT, "Plate Search - MDC", "Enter the vehicles full or partial plate to search below:\n\nYou need at least 3 characters for a plate search.", "Search", "<<"); 
					
				PlayerMDCCount[playerid] = 0;
				PlayerMDCTimer[playerid] = SetTimerEx("OnMDCSearch", 1000, true, "ii", playerid, 2);
				format(PlayerMDCName[playerid], 32, "%s", inputtext);
				PlayerTextDrawSetString(playerid, MDC_UI[playerid][64], "Searching.");
			}
			else return 1;
		}
		case DIALOG_MDC_NAME_QUEUE:
		{
			if(response)
			{
				new
					str[120];
					
				format(str, sizeof(str), "{FFFFFF}Name search cancelled for: \"%s\"", PlayerMDCName[playerid]);
				ShowPlayerDialog(playerid, DIALOG_DEFAULT, DIALOG_STYLE_MSGBOX, "Name Search - MDC", str, "Okay", ""); 
				
				KillTimer(PlayerMDCTimer[playerid]);
				PlayerMDCCount[playerid] = 0; 
				return 1;
			}
		}
		case DIALOG_MDC_PLATE_QUEUE:
		{
			if(response)
			{
				new
					str[120];
					
				format(str, sizeof(str), "{FFFFFF}Plate search cancelled for: \"%s\"", PlayerMDCName[playerid]);
				ShowPlayerDialog(playerid, DIALOG_DEFAULT, DIALOG_STYLE_MSGBOX, "Plate Search - MDC", str, "Okay", ""); 
				
				KillTimer(PlayerMDCTimer[playerid]);
				
				for(new i = 0; i < 5; i++) PlayerPlateSaver[playerid][i] = "";
				PlayerMDCName[playerid] = "";
				PlayerMDCCount[playerid] = 0; 
			}
		}
		case DIALOG_MDC_PLATE_LIST:
		{
			if(response)
			{
				new query[220];
			
				mysql_format(this, query, sizeof(query), "SELECT VehicleStolen, VehicleOwnerDBID, VehicleModel, VehicleImpounded FROM vehicles WHERE VehiclePlates = '%e'", PlayerPlateSaver[playerid][listitem]);
				mysql_tquery(this, query, "OnPlateSelect", "ii", playerid, listitem);
				return 1; 
			}
		}
		case DIALOG_MDC_FINISH_QUEUE:
		{
			if(response)
			{
				ShowPlayerMDC(playerid);
				return 1;
			}
		}
		case DIALOG_SECRETWORD_CREATE:
		{
			if(response)
			{
				new 
					insert[128];
					
				mysql_format(this, insert, sizeof(insert), "UPDATE characters SET secret_word = sha1('%e') WHERE char_dbid = %i", inputtext, e_pAccountData[playerid][mDBID]);
				mysql_tquery(this, insert);
				
				mysql_format(this, insert, sizeof(insert), "SELECT char_dbid FROM characters WHERE char_name = '%e'", ReturnName(playerid));
				mysql_tquery(this, insert, "LogPlayerIn", "i", playerid);
				return 1;
			}
			else
			{
				return KickEx(playerid);
			}
		}
		case DIALOG_SECRETWORD_INPUT:
		{
			if(response)
			{
				new 
					query[128];
				
				mysql_format(this, query, sizeof(query), "SELECT secret_word FROM characters WHERE char_name = '%e' AND secret_word = sha1('%e')", ReturnName(playerid), inputtext);
				mysql_tquery(this, query, "OnSecretWordInput", "i", playerid);
				return 1;
			}
			else
			{
				return KickEx(playerid);
			}
		}
		case DIALOG_EDIT_BONE:
		{
	        if (response)
	        {
	            new weaponid = EditingWeapon[playerid], insert[150];
	            WeaponSettings[playerid][weaponid - 22][Bone] = listitem + 1;

	            sendMessage(playerid, -1, "You have successfully changed the bone of your %s.", ReturnWeaponName(weaponid));
	            
	            mysql_format(this, insert, sizeof(insert), "INSERT INTO weaponsettings (Name, WeaponID, Bone) VALUES ('%s', %d, %d) ON DUPLICATE KEY UPDATE Bone = VALUES(Bone)", ReturnName(playerid), weaponid, listitem + 1);
	            mysql_tquery(this, insert);
			}
			EditingWeapon[playerid] = 0;
   			return 1;
		}
	    case DIALOG_FOOD_CONFIG:
	    {
			if(!response) return 1;
			switch(listitem)
			{
			    case 0: ShowPlayerDialog(playerid, DIALOG_FOOD_TYPE, DIALOG_STYLE_LIST, "Select a meal type to offer", "Pizza Restaurant\nBurger Fast-Food\nChicken Fast-Food\nDonut Fast-Food", "Continue", "Back");
			    case 1: ShowPlayerDialog(playerid, DIALOG_FOOD_PRICE_1, DIALOG_STYLE_LIST, "Change Price", "Please enter a new price for this meal (min $25, max $1000)", "Continue", "Back");
			    case 2: ShowPlayerDialog(playerid, DIALOG_FOOD_PRICE_2, DIALOG_STYLE_LIST, "Change Price", "Please enter a new price for this meal (min $25, max $1000)", "Continue", "Back");
			    case 3: ShowPlayerDialog(playerid, DIALOG_FOOD_PRICE_3, DIALOG_STYLE_LIST, "Change Price", "Please enter a new price for this meal (min $25, max $1000)", "Continue", "Back");
			}
			return 1;
	    }

	    case DIALOG_FOOD_TYPE:
	    {
			if(!response) return ShowBusinessConfig(playerid);
			switch(listitem)
			{
			    case 0:
				{
					BusinessInfo[IsPlayerInBusiness(playerid)][eBusinessFood][0] = 0;
					BusinessInfo[IsPlayerInBusiness(playerid)][eBusinessFood][1] = 1;
					BusinessInfo[IsPlayerInBusiness(playerid)][eBusinessFood][2] = 2;
					BusinessInfo[IsPlayerInBusiness(playerid)][eBusinessRestaurantType] = listitem;
				}
			    case 1:
			    {
					BusinessInfo[IsPlayerInBusiness(playerid)][eBusinessFood][0] = 3;
					BusinessInfo[IsPlayerInBusiness(playerid)][eBusinessFood][1] = 4;
					BusinessInfo[IsPlayerInBusiness(playerid)][eBusinessFood][2] = 5;
					BusinessInfo[IsPlayerInBusiness(playerid)][eBusinessRestaurantType] = listitem;
			    }
			    case 2:
			    {
					BusinessInfo[IsPlayerInBusiness(playerid)][eBusinessFood][0] = 6;
					BusinessInfo[IsPlayerInBusiness(playerid)][eBusinessFood][1] = 7;
					BusinessInfo[IsPlayerInBusiness(playerid)][eBusinessFood][2] = 8;
					BusinessInfo[IsPlayerInBusiness(playerid)][eBusinessRestaurantType] = listitem;
			    }
			    case 3:
			    {
					BusinessInfo[IsPlayerInBusiness(playerid)][eBusinessFood][0] = 9;
					BusinessInfo[IsPlayerInBusiness(playerid)][eBusinessFood][1] = 10;
					BusinessInfo[IsPlayerInBusiness(playerid)][eBusinessFood][2] = 11;
					BusinessInfo[IsPlayerInBusiness(playerid)][eBusinessRestaurantType] = listitem;
			    }
			}
			sendMessage(playerid, COLOR_LIGHTRED, "[ ! ] Restaurant type changed to [FFFFFF]%s", ReturnRestaurantName(listitem));
			return 1;

	    }
	    case DIALOG_FOOD_PRICE_1:
	    {
			if(!response) return ShowBusinessConfig(playerid);
			if(strlen(inputtext) < 1 || strlen(inputtext) > 2)
				return ShowPlayerDialog(playerid, DIALOG_FOOD_PRICE_1, DIALOG_STYLE_LIST, "Change Price", "Please enter a new price for this meal (min $25, max $1000)", "Continue", "Back");

			if(strval(inputtext) < 25 || strval(inputtext) > 1000)
			    return ShowPlayerDialog(playerid, DIALOG_FOOD_PRICE_1, DIALOG_STYLE_LIST, "Change Price", "Please enter a new price for this meal (min $25, max $1000)", "Continue", "Back");

		    BusinessInfo[IsPlayerInBusiness(playerid)][eBusinessFoodPrice][0] = strval(inputtext);
		    sendMessage(playerid, COLOR_LIGHTRED, "[ ! ] Restaurant food #1 price changed to [FFFFFF]%d", strval(inputtext));
		    return 1;
	    }
	    case DIALOG_FOOD_PRICE_2:
	    {
			if(!response) return ShowBusinessConfig(playerid);
			if(strlen(inputtext) < 1 || strlen(inputtext) > 2)
				return ShowPlayerDialog(playerid, DIALOG_FOOD_PRICE_2, DIALOG_STYLE_LIST, "Change Price", "Please enter a new price for this meal (min $25, max $1000)", "Continue", "Back");

			if(strval(inputtext) < 25 || strval(inputtext) > 1000)
			    return ShowPlayerDialog(playerid, DIALOG_FOOD_PRICE_2, DIALOG_STYLE_LIST, "Change Price", "Please enter a new price for this meal (min $25, max $1000)", "Continue", "Back");

		    BusinessInfo[IsPlayerInBusiness(playerid)][eBusinessFoodPrice][1] = strval(inputtext);
		    sendMessage(playerid, COLOR_LIGHTRED, "[ ! ] Restaurant food #2 price changed to [FFFFFF]%d", strval(inputtext));
		    return 1;
	    }
	    case DIALOG_FOOD_PRICE_3:
	    {
			if(!response) return ShowBusinessConfig(playerid);
			if(strlen(inputtext) < 1 || strlen(inputtext) > 2)
				return ShowPlayerDialog(playerid, DIALOG_FOOD_PRICE_3, DIALOG_STYLE_LIST, "Change Price", "Please enter a new price for this meal (min $25, max $1000)", "Continue", "Back");

			if(strval(inputtext) < 25 || strval(inputtext) > 1000)
			    return ShowPlayerDialog(playerid, DIALOG_FOOD_PRICE_3, DIALOG_STYLE_LIST, "Change Price", "Please enter a new price for this meal (min $25, max $1000)", "Continue", "Back");

		    BusinessInfo[IsPlayerInBusiness(playerid)][eBusinessFoodPrice][2] = strval(inputtext);
		    sendMessage(playerid, COLOR_LIGHTRED, "[ ! ] Restaurant food #3 price changed to [FFFFFF]%d", strval(inputtext));
		    return 1;
	    }
	    case DIALOG_SPRAY_CREATE:
	    {
			if(!response) return 1;
			new Float: x, Float: y, Float: z;
			GetPlayerPos(playerid, x, y, z);
			PlayerInfo[playerid][pEditingObject] = 5;
			SetPVarInt(playerid, "spray_model", g_spraytag[listitem][tag_modelid]);
			PlayerInfo[playerid][pAddObject] = CreateDynamicObject(g_spraytag[listitem][tag_modelid], x, y, z, 0.0, 0.0, 0.0);
			EditDynamicObject(playerid, PlayerInfo[playerid][pAddObject]);
			return 1;
	    }
	    case DIALOG_SPRAY_MAIN:
	    {
	        if(!response) return 1;
	        switch(listitem)
	        {
	            case 0: ShowSprayDialog(playerid, DIALOG_SPRAY_IMAGE);
	            case 1: ShowSprayDialog(playerid, DIALOG_SPRAY_INPUT);
	            case 2: ShowSprayDialog(playerid, DIALOG_SPRAY_FONT);
	        }
	        return 1;
	    }
	    case DIALOG_SPRAY_IMAGE:
	    {
	        if(!response) return ShowSprayDialog(playerid, DIALOG_SPRAY_MAIN);
	        PlayerInfo[playerid][pSprayFont] = g_spraytag[listitem][tag_modelid];
	        PlayerInfo[playerid][pSprayAllow] = 2;
	        PlayerInfo[playerid][pSprayLength] = 10;
	        PlayerInfo[playerid][pSprayPoint] = 1;
			new string[64];
			sendMessage(playerid, COLOR_YELLOWEX, "You have picked graffiti image: {FFFFFF}%s", g_spraytag[listitem][tag_name]);
			SendClientMessage(playerid, COLOR_YELLOWEX, string);
			
	        return 1;
	    }
	    case DIALOG_SPRAY_INPUT:
	    {
	        if(!response) return ShowSprayDialog(playerid, DIALOG_SPRAY_MAIN);
			if(!strlen(inputtext)) return ShowSprayDialog(playerid, DIALOG_SPRAY_INPUT);
			PlayerInfo[playerid][pSprayAllow] = 1;
	        PlayerInfo[playerid][pSprayLength] = strlen(inputtext);
	        PlayerInfo[playerid][pSprayPoint] = 0;
	        PlayerInfo[playerid][pSprayTarget] = GetPlayerNearestTag(playerid);
	        new string[128];
			SendClientMessage(playerid, COLOR_YELLOWEX, "You have set your text.");
	        format(string, sizeof(string),"%s", inputtext);
	        SendClientMessage(playerid, COLOR_YELLOWEX, string);
	        PlayerInfo[playerid][pSprayText] = string;
	        return 1;
	    }
	    case DIALOG_SPRAY_FONT:
	    {
	        if(!response) return ShowSprayDialog(playerid, DIALOG_SPRAY_MAIN);
	        
	        new string[64];
			sendMessage(playerid, COLOR_YELLOWEX, "You have chosen font: {FFFFFF}%s", font_data[listitem][font_name]);
			SendClientMessage(playerid, COLOR_YELLOWEX, string);
			
            PlayerInfo[playerid][pSprayFont] = listitem;
            return 1;
	    }
		case DIALOG_CHOPSHOP:
		{
		    if(!response) return callcmd::chopshop(playerid, "");
			switch(listitem)
			{
				case 0:
				{
					GiveMoney(playerid, -100000);
					new Float: x, Float: y, Float: z;
					GetPlayerPos(playerid, x, y, z);
					PlayerInfo[playerid][pEditingObject] = 7;
					PlayerInfo[playerid][pAddObject] = CreateDynamicObject(3077, x, y, z, 0.0, 0.0, 0.0);
					EditDynamicObject(playerid, PlayerInfo[playerid][pAddObject]);
				}
				case 1: GetRandomModel( GetChopshopID(playerid) );
				case 2: return 1;//ShowChopShop(playerid);
				case 3: EditChopShop(playerid, GetChopshopID(playerid));
			}
			return 1;
		}
		case DIALOG_REMOVE_COMP:
		{
			if(!response)return 0;

			new vid = GetPlayerVehicleID(playerid);
			new component;
			new count;

			if(vid == -1) return 1;

			if(VehicleInfo[vid][eVehicleOwnerDBID] != PlayerInfo[playerid][pDBID])
				return SendErrorMessage(playerid, "You don't own this vehicle.");

			if(!listitem)
			{
				for(new j; j < 14; j++)
				{
				    component = GetVehicleComponentInSlot(vid, j);
				    if(!component)continue;
				    RemoveVehicleComponent(vid, component);
				    VehicleInfo[vid][eVehicleMods][GetVehicleComponentType(component)] = 0;
		            SaveComponent(vid, j);
					count++;
				}

				if(!count) return
				    SendErrorMessage(playerid, "You don't have any components.");

				SendServerMessage(playerid, "Components have been resetted.");
				return 1;
			}

			if(listitem == 1)
			{
			    if(VehicleInfo[vid][eVehiclePaintjob] == 3)return
			        SendErrorMessage(playerid, "This vehicle does not have paintjob.");

			    VehicleInfo[vid][eVehiclePaintjob] = 3;
			    ChangeVehiclePaintjob(vid, 3);
			    ChangeVehicleColor(vid, VehicleInfo[vid][eVehicleColor1], VehicleInfo[vid][eVehicleColor2]);
			    SendServerMessage(playerid, "Paint job removed.");
			    return SaveVehicle(vid);
			}

			listitem -= 2; component = GetVehicleComponentInSlot(vid, listitem);

			if(!component)return
			    SendServerMessage(playerid, "You don't have any components.");

			RemoveVehicleComponent(vid, component);
		 	VehicleInfo[vid][eVehicleMods][GetVehicleComponentType(component)] = 0;
			SaveVehicle(vid);

			sendMessage(playerid, COLOR_YELLOWEX, "Component %s (#%d) removed.", GetComponentName(component), component);
		}
	}
	return 0;
}

this::OnMDCSearch(playerid, type)
{
	new
		str[60]
	;

	PlayerMDCCount[playerid]++; 
	switch(PlayerMDCCount[playerid])
	{
		case 1: str = "Searching.."; 
		case 2: str = "Searching.";
		case 3: str = "Searching..";
		case 4: str = "Searching...";
		case 5:
		{
			KillTimer(PlayerMDCTimer[playerid]);
			PlayerMDCCount[playerid] = 0;
			
			OnMDCRecordSearch(playerid, type); 
			return 1; 
		}
	}
	PlayerTextDrawSetString(playerid, MDC_UI[playerid][64], str);
	return 1;
}

this::OnPlayerRegister(playerid)
{
	e_pAccountData[playerid][mDBID] = cache_insert_id(); 
	format(e_pAccountData[playerid][mAccName], 32, "%s", ReturnName(playerid)); 
	
	registerTime[playerid] = 0;
	loginTime[playerid] = 1; 
	
	sendMessage(playerid, COLOR_YELLOW, "You successfully registered as %s. You need to login to continue:", ReturnName(playerid));
	return ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Welcome to Beta Server", "SERVER: You have 60 seconds to login!\nTIP: Please report all bugs that you\nmay have found to development.\n\n           Enter Your Password:", "Select", "Cancel");
}

this::LoggingIn(playerid)
{
	if(!cache_num_rows())
	{
		playerLogin[playerid]++;
		if(playerLogin[playerid] == 3)
		{
			SendClientMessage(playerid, COLOR_REDEX, "[SERVER]: You were kicked for bad password attempts.");
			return KickEx(playerid);
		}
		
		return ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Welcome to Beta Server", "You entered the wrong password!\n\nSERVER: You have 60 seconds to login!\nTIP: Please report all bugs that you\nmay have found to development.\n\n           Enter Your Password:", "Select", "Cancel");
	}
	
	new rows, fields, fetchChars[128];
	cache_get_data(rows, fields, this);
	
	new secret_word[128], ActiveIP[60];
	
	e_pAccountData[playerid][mDBID] = cache_get_field_content_int(0, "char_dbid", this);
	cache_get_field_content(0, "forum_name", e_pAccountData[playerid][mForumName], this, 60);
	cache_get_field_content(0, "secret_word", secret_word); 
	cache_get_field_content(0, "active_ip", ActiveIP);
	format(e_pAccountData[playerid][mAccName], 32, "%s", ReturnName(playerid));

	if(isnull(secret_word))
	{
		ShowPlayerDialog(playerid, DIALOG_SECRETWORD_CREATE, DIALOG_STYLE_PASSWORD, "Welcome to Beta Server",
		"SECURITY PRECAUTION:\n\nWe have introduced a SECRET CONFIRMATION CODE system to help protect user accounts. This is basically a word that will be presented if any connection conditions change.\n\nYou will have to remember this.\n\n{F81414}IT IS ADVISED THIS ISN'T YOUR PASSWORD.", "Enter", "Cancel");
		return 1; 
	}
	
	if(strcmp(ReturnIP(playerid), ActiveIP))
	{
		ShowPlayerDialog(playerid, DIALOG_SECRETWORD_INPUT, DIALOG_STYLE_PASSWORD, "Welcome to Beta Server",
		"{F81414}SECURITY PRECAUTION:{FFFFFF}\n\nOur system has flagged changes to your accounts connection conditions. To ensure there is no breach of security,\n\nPlease enter your {F81414}SECURITY CONFIRMATION CODE{FFFFFF} you selected during registration to login.", "Enter", "Cancel");
		return 1;
	}	
	
	mysql_format(this, fetchChars, sizeof(fetchChars), "SELECT * FROM bannedlist WHERE MasterDBID = %i", e_pAccountData[playerid][mDBID]);
	mysql_tquery(this, fetchChars, "Query_CheckBannedAccount", "i", playerid);
	return 1;
}

this::Query_CheckBannedAccount(playerid)
{
	if(!cache_num_rows())
	{
		new fetchChars[128];
		
		loginTime[playerid] = 0; 
		
		mysql_format(this, fetchChars, sizeof(fetchChars), "SELECT * FROM characters WHERE char_name = '%e'", ReturnName(playerid));
		mysql_tquery(this, fetchChars, "Query_LoadCharacter", "i", playerid);
	}
	else
	{
		new rows, fields;
		cache_get_data(rows, fields, this);
		
		new banDate[90], banner[32];
		
		cache_get_field_content(0, "Date", banDate, this, 90);
		cache_get_field_content(0, "BannedBy", banner, this, 32);
	
		SendServerMessage(playerid, "Your account \"%s\" is banned from our server.", ReturnName(playerid));
		SendServerMessage(playerid, "You were banned on %s by %s.", banDate, banner); 
		return KickEx(playerid);
	}
	return 1;
}

this::Query_LoadCharacter(playerid)
{
	PlayerInfo[playerid][pDBID] = cache_get_field_content_int(0, "char_dbid", this);

	PlayerInfo[playerid][pAdmin] = cache_get_field_content_int(0, "pAdmin", this);
	PlayerInfo[playerid][pLastSkin] = cache_get_field_content_int(0, "pLastSkin", this);
	
	PlayerInfo[playerid][pLastPos][0] = cache_get_field_content_float(0, "pLastPosX", this);
	PlayerInfo[playerid][pLastPos][1] = cache_get_field_content_float(0, "pLastPosY", this);
	PlayerInfo[playerid][pLastPos][2] = cache_get_field_content_float(0, "pLastPosZ", this);
	
	PlayerInfo[playerid][pLastInterior] = cache_get_field_content_int(0, "pLastInterior", this);
	PlayerInfo[playerid][pLastWorld] = cache_get_field_content_int(0, "pLastWorld", this);
	
	PlayerInfo[playerid][pLevel] = cache_get_field_content_int(0, "pLevel", this);
	PlayerInfo[playerid][pEXP] = cache_get_field_content_int(0, "pEXP", this);
	PlayerInfo[playerid][pAge] = cache_get_field_content_int(0, "pAge", this);
	
	PlayerInfo[playerid][pMoney] = cache_get_field_content_int(0, "pMoney", this);
	PlayerInfo[playerid][pBank] = cache_get_field_content_int(0, "pBank", this);
	PlayerInfo[playerid][pPaycheck] = cache_get_field_content_int(0, "pPaycheck", this);
	
	PlayerInfo[playerid][pPhone] = cache_get_field_content_int(0, "pPhone", this);
	
	cache_get_field_content(0, "pLastOnline", PlayerInfo[playerid][pLastOnline], this, 90);
	PlayerInfo[playerid][pLastOnlineTime] = cache_get_field_content_int(0, "pLastOnlineTime", this);
	
	PlayerInfo[playerid][pAdminjailed] = bool:cache_get_field_content_int(0, "pAdminjailed", this);
	PlayerInfo[playerid][pAdminjailTime] = cache_get_field_content_int(0, "pAdminjailTime", this);
	
	PlayerInfo[playerid][pOfflinejailed] = bool:cache_get_field_content_int(0, "pOfflinejailed", this);
	cache_get_field_content(0, "pOfflinejailedReason", PlayerInfo[playerid][pOfflinejailedReason], this, 128);
	
	PlayerInfo[playerid][pFaction] = cache_get_field_content_int(0, "pFaction", this);
	PlayerInfo[playerid][pFactionRank] = cache_get_field_content_int(0, "pFactionRank", this);
	
	PlayerInfo[playerid][pVehicleSpawned] = bool:cache_get_field_content_int(0, "pVehicleSpawned", this);
	PlayerInfo[playerid][pVehicleSpawnedID] = cache_get_field_content_int(0, "pVehicleSpawnedID", this);
	
	PlayerInfo[playerid][pTimeplayed] = cache_get_field_content_int(0, "pTimeplayed", this);
	
	PlayerInfo[playerid][pMaskID][0] = cache_get_field_content_int(0, "pMaskID", this);
	PlayerInfo[playerid][pMaskID][1] = cache_get_field_content_int(0, "pMaskIDEx", this);
	
	PlayerInfo[playerid][pInsideProperty] = cache_get_field_content_int(0, "pInProperty", this);
	PlayerInfo[playerid][pInsideBusiness] = cache_get_field_content_int(0, "pInBusiness", this);
	
	PlayerInfo[playerid][pHasRadio] = bool:cache_get_field_content_int(0, "pHasRadio", this);
	PlayerInfo[playerid][pMainSlot] = cache_get_field_content_int(0, "pMainSlot", this);
	
	PlayerInfo[playerid][pGascan] = cache_get_field_content_int(0, "pGascan", this);
	
	PlayerInfo[playerid][pSpawnPoint] = cache_get_field_content_int(0, "pSpawnPoint", this);
	PlayerInfo[playerid][pSpawnPointHouse] = cache_get_field_content_int(0, "pSpawnPointHouse", this);
	
	PlayerInfo[playerid][pWeaponsLicense] = cache_get_field_content_int(0, "pWeaponsLicense", this);
	PlayerInfo[playerid][pDriversLicense] = cache_get_field_content_int(0, "pDriversLicense", this);
	
	PlayerInfo[playerid][pActiveListings] = cache_get_field_content_int(0, "pActiveListings", this);
	PlayerInfo[playerid][pJailTimes] = cache_get_field_content_int(0, "pJailTimes", this);
	PlayerInfo[playerid][pPrisonTimes] = cache_get_field_content_int(0, "pPrisonTimes", this);
	
	PlayerInfo[playerid][pDonator] = cache_get_field_content_int(0, "Donator", this);
	PlayerInfo[playerid][pWalkstyle] = cache_get_field_content_int(0, "Walk_style", this);
	PlayerInfo[playerid][pChatstyle] = cache_get_field_content_int(0, "Chat_style", this);
	PlayerInfo[playerid][pHud] = cache_get_field_content_int(0, "Hud_style", this);
	PlayerInfo[playerid][pPhonePower] = cache_get_field_content_int(0, "PhonePower", this);
	PlayerInfo[playerid][pJob] = cache_get_field_content_int(0, "Job", this);
	PlayerInfo[playerid][pCareer] = cache_get_field_content_int(0, "Career", this);
	PlayerInfo[playerid][pSideJob] = cache_get_field_content_int(0, "SideJob", this);
	
	PlayerInfo[playerid][pUseHud] = bool:cache_get_field_content_int(0, "Hud_style", this);
	
	PlayerInfo[playerid][pSetupInfo] = bool:cache_get_field_content_int(0, "SetupInfo", this);
	
	PlayerInfo[playerid][pGender] = cache_get_field_content_int(0, "Gender", this);
	PlayerInfo[playerid][pRentAt] = cache_get_field_content_int(0, "RentAt", this);
	new str[128];
	
	for(new i = 1; i < 3; i++)
	{
		format(str, sizeof(str), "pRadio%i", i);
		PlayerInfo[playerid][pRadio][i] = cache_get_field_content_int(0, str, this);
	}
	
	for(new i = 0; i < 4; i++)
	{
		format(str, sizeof(str), "pWeapons%d", i);
		PlayerInfo[playerid][pWeapons][i] = cache_get_field_content_int(0, str, this);
		
		format(str, sizeof(str), "pWeaponsAmmo%d", i);
		PlayerInfo[playerid][pWeaponsAmmo][i] = cache_get_field_content_int(0, str, this);
	}
	
	for(new i = 1; i < MAX_PLAYER_VEHICLES; i++)
	{	
		format(str, sizeof(str), "pOwnedVehicles%d", i);
		PlayerInfo[playerid][pOwnedVehicles][i] = cache_get_field_content_int(0, str, this);
	}
	
	if(!PlayerInfo[playerid][pMaskID])
	{
		PlayerInfo[playerid][pMaskID][0] = 200000+random(199991);
		PlayerInfo[playerid][pMaskID][1] = 40+random(59);
	}

	TogglePlayerSpectating(playerid, false);
	return LoadCharacter(playerid);
}

this::LoadCharacter(playerid)
{
	new
		string[128]
	;
	
	PlayerInfo[playerid][pLoggedin] = true;
	e_pAccountData[playerid][mLoggedin] = true;
	
	SetPlayerScore(playerid, PlayerInfo[playerid][pLevel]);
	SetPlayerColor(playerid, 0xFFFFFFFF);
	
	ResetPlayerMoney(playerid); 
	GivePlayerMoney(playerid, PlayerInfo[playerid][pMoney]);

	SetSpawnInfo(playerid, 0, PlayerInfo[playerid][pLastSkin], PlayerInfo[playerid][pLastPos][0], PlayerInfo[playerid][pLastPos][1], PlayerInfo[playerid][pLastPos][2], 0, 0, 0, 0, 0, 0, 0);
	SpawnPlayer(playerid);

	format(string, sizeof(string), "~w~Welcome~n~~y~ %s", ReturnName(playerid));
	GameTextForPlayer(playerid, string, 1000, 1);

	if (PlayerInfo[playerid][pAdmin])
	{
		sendMessage(playerid, COLOR_WHITE, "SERVER: You logged in as a level %i admin.", PlayerInfo[playerid][pAdmin]);
		
		if(!strcmp(e_pAccountData[playerid][mForumName], "Null"))
		{
			ShowPlayerDialog(playerid, 99, DIALOG_STYLE_MSGBOX, "Notification", "This message notifies all admins on login if their forum name hasn't been set.\nYour forum name is NULL and requires a change.\n\n{F81414}Please ensure it's changed ASAP using /forumname.", "Understood", ""); 
		}
	}
	
	if(PlayerInfo[playerid][pVehicleSpawned] == true)
	{
		if(!IsValidVehicle(PlayerInfo[playerid][pVehicleSpawnedID]))
			PlayerInfo[playerid][pVehicleSpawned] = false; 
			
		else
			SendServerMessage(playerid, "Your vehicle is still spawned.");
	}
	
	SetPlayerSkin(playerid, PlayerInfo[playerid][pLastSkin]);
	SetPlayerPos(playerid, PlayerInfo[playerid][pLastPos][0], PlayerInfo[playerid][pLastPos][1], PlayerInfo[playerid][pLastPos][2]);
	
	if(PlayerInfo[playerid][pOfflinejailed])
	{
		if(strlen(PlayerInfo[playerid][pOfflinejailedReason]) > 56)
		{
			SendClientMessageToAllEx(COLOR_RED, "AdmCmd: %s was admin jailed by SYSTEM for %d minutes, Reason: %.56s", ReturnName(playerid), PlayerInfo[playerid][pAdminjailTime] / 60, PlayerInfo[playerid][pOfflinejailedReason]);
			SendClientMessageToAllEx(COLOR_RED, "AdmCmd: ...%s", PlayerInfo[playerid][pOfflinejailedReason][56]); 
		}
		else SendClientMessageToAllEx(COLOR_RED, "AdmCmd: %s was admin jailed by SYSTEM for %d minutes, Reason: %s", ReturnName(playerid), PlayerInfo[playerid][pAdminjailTime] / 60, PlayerInfo[playerid][pOfflinejailedReason]);
		
		ClearAnimations(playerid); 
		
		SetPlayerPos(playerid, 2687.3630, 2705.2537, 22.9472);
		SetPlayerInterior(playerid, 0); SetPlayerVirtualWorld(playerid, 1338);
		
		PlayerInfo[playerid][pOfflinejailed] = false; 
		PlayerInfo[playerid][pAdminjailed] = true; 
	}
	
	format(PlayerInfo[playerid][pActiveIP], 60, "%s", ReturnIP(playerid)); 
	
    for (new i; i < 17; i++)
    {
        WeaponSettings[playerid][i][Position][0] = -0.116;
        WeaponSettings[playerid][i][Position][1] = 0.189;
        WeaponSettings[playerid][i][Position][2] = 0.088;
        WeaponSettings[playerid][i][Position][3] = 0.0;
        WeaponSettings[playerid][i][Position][4] = 44.5;
        WeaponSettings[playerid][i][Position][5] = 0.0;
        WeaponSettings[playerid][i][Bone] = 1;
        WeaponSettings[playerid][i][Hidden] = false;
    }
    WeaponTick[playerid] = 0;
	EditingWeapon[playerid] = 0;

	new insert[128];
    mysql_format(this, insert, sizeof(insert), "SELECT * FROM weaponsettings WHERE Name = '%s'", ReturnName(playerid));
    mysql_tquery(this, insert, "OnWeaponsLoaded", "d", playerid);
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	if (e_pAccountData[playerid][mLoggedin] == false)
	{
		TogglePlayerSpectating(playerid, true);
		return 0;
	}
	else if(e_pAccountData[playerid][mLoggedin] == true)
	{
		SetSpawnInfo(playerid, 0, PlayerInfo[playerid][pLastSkin], PlayerInfo[playerid][pLastPos][0], PlayerInfo[playerid][pLastPos][1], PlayerInfo[playerid][pLastPos][2], 0, 0, 0, 0, 0, 0, 0);
		SpawnPlayer(playerid);
		return 0;
	}
	else return 0;
}

this::KickTimer(playerid) { return Kick(playerid); }

this::ResetPlayer(playerid)
{
    ResetSprayVars(playerid);
	//Master accounts:
	
    if(PlayerInfo[playerid][pInTuning])
        Tuning_ExitDisplay(playerid);
	
	e_pAccountData[playerid][mDBID] = 0; 
	e_pAccountData[playerid][mLoggedin] = false; 

	PlayerInfo[playerid][pChatting] = 0;

	PlayerInfo[playerid][TempTweak] = 0;
	PlayerInfo[playerid][pMeal] = -1;
	
	playerLogin[playerid] = 0; 
	
	//Prevents;
	loginTime[playerid] = 0;
	registerTime[playerid] = 0;
	
	ResetDealershipVars(playerid);
	ClearDamages(playerid);
	
	playerPhone[playerid] = 0;
	
	for(new i = 0; i < 5; i++) PlayerPlateSaver[playerid][i] = "";
	PlayerMDCName[playerid] = "";
	
	//Player characters:
	PlayerInfo[playerid][pDBID] = 0; 
	PlayerInfo[playerid][pLoggedin] = false; 
	
	PlayerInfo[playerid][pAdmin] = 0;
	PlayerInfo[playerid][pAdminDuty] = false; 
	PlayerInfo[playerid][pLastSkin] = 264;
	
	PlayerInfo[playerid][pLastPos][0] = 1642.02;
	PlayerInfo[playerid][pLastPos][1] = -2334.05;
	PlayerInfo[playerid][pLastPos][2] = 13.5469;
	
	PlayerInfo[playerid][pLastInterior] = 0;
	PlayerInfo[playerid][pLastWorld] = 0;
	
	PlayerInfo[playerid][pLevel] = 1; 
	PlayerInfo[playerid][pAge] = 13;
	
	PlayerInfo[playerid][pMoney] = 5000;
	PlayerInfo[playerid][pBank] = 15000;
	PlayerInfo[playerid][pPaycheck] = 5000; 
	
	PlayerInfo[playerid][pPhone] = 94000+random(6999);
	PlayerInfo[playerid][pPhoneOff] = false; 
	PlayerInfo[playerid][pPhonespeaker] = false; 
	
	PlayerInfo[playerid][pCalling] = 0;
	PlayerInfo[playerid][pPayphone] = INVALID_ID;
	PlayerInfo[playerid][pPhoneline] = INVALID_PLAYER_ID;
	
	PlayerInfo[playerid][pMuted] = false;
	
	PlayerInfo[playerid][pSpectating] = INVALID_PLAYER_ID;
	
	PlayerInfo[playerid][pFaction] = 0;
	PlayerInfo[playerid][pFactionRank] = 0;
	PlayerInfo[playerid][pFactionInvite] = 0;
	PlayerInfo[playerid][pFactionInvitedBy] = INVALID_PLAYER_ID;
	
	for(new i = 1; i < MAX_PLAYER_VEHICLES; i++) { 
		PlayerInfo[playerid][pOwnedVehicles][i] = 0; 
	}
	
	PlayerInfo[playerid][pVehicleSpawned] = false;
	PlayerInfo[playerid][pVehicleSpawnedID] = INVALID_VEHICLE_ID;
	PlayerInfo[playerid][pDuplicateKey] = INVALID_VEHICLE_ID;
	
	PlayerInfo[playerid][pWeaponsSpawned] = false;
	
	for(new i = 0; i < 4; i++){
		PlayerInfo[playerid][pWeapons][i] = 0;
		PlayerInfo[playerid][pWeaponsAmmo][i] = 0;
	}
	
	PlayerInfo[playerid][pUnscrambling] = false;
	PlayerInfo[playerid][pUnscramblerTime] = 0;
	PlayerInfo[playerid][pScrambleFailed] = 0;
	PlayerInfo[playerid][pScrambleSuccess] = 0; 
	PlayerInfo[playerid][pUnscrambleID] = 0;
	
	PlayerInfo[playerid][pPoliceDuty] = false;
	PlayerInfo[playerid][pMedicDuty] = false;
	
	PlayerInfo[playerid][pTimeplayed] = 0;
	
	PlayerInfo[playerid][pInsideProperty] = 0; 
	PlayerInfo[playerid][pInsideBusiness] = 0;
	PlayerInfo[playerid][pAtDealership] = 0;
	
	PlayerInfo[playerid][pMaskID][0] = 200000+random(199991);
	PlayerInfo[playerid][pMaskID][1] = 40+random(59);
	PlayerInfo[playerid][pMasked] = false;
	PlayerInfo[playerid][pHasMask] = false;
	
	PlayerInfo[playerid][pOfflinejailed] = false;
	
	PlayerInfo[playerid][pLastDamagetime] = 0;
	
	PlayerInfo[playerid][pRelogCount] = 0;
	PlayerInfo[playerid][pRelogging] = false;
	
	PlayerInfo[playerid][pAddObject] = INVALID_OBJECT_ID;
	PlayerInfo[playerid][pEditingObject] = 0;
	
	PlayerInfo[playerid][pHasRadio] = false;
	PlayerInfo[playerid][pMainSlot] = 1; 
	
	for(new i = 1; i < 3; i++){
		PlayerInfo[playerid][pRadio][i] = 0;
	}
	
	PlayerInfo[playerid][pRespawnTime] = 0;
	
	PlayerInfo[playerid][pDonator] = 0;
	
	PlayerInfo[playerid][pJob] = 0;
	PlayerInfo[playerid][pCareer] = 0;
	PlayerInfo[playerid][pSideJob] = 0;
	PlayerInfo[playerid][pWalkstyle] = 0;
	PlayerInfo[playerid][pChatstyle] = 0;
	PlayerInfo[playerid][pHud] = 1;
	PlayerInfo[playerid][pUseHud] = true;
	
	PlayerInfo[playerid][pRentAt] = 0;
	
	PlayerInfo[playerid][pSetupInfo] = false;
	
	PlayerInfo[playerid][pGender] = 1;
	
	PlayerInfo[playerid][pSpawnPoint] = 0; 
	PlayerInfo[playerid][pSpawnPointHouse] = 0;
	
	PlayerInfo[playerid][pTaser] = false; 
	
	PlayerInfo[playerid][pWeaponsLicense] = 0;
	PlayerInfo[playerid][pDriversLicense] = 0;
	
	PlayerInfo[playerid][pActiveListings] = 0;
	PlayerInfo[playerid][pJailTimes] = 0;
	PlayerInfo[playerid][pPrisonTimes] = 0;
	return 1;
}

this::FunctionPlayers()
{
	foreach (new i : Player)
	{
		if(GetTickCount() > (PlayerInfo[i][pPauseCheck]+2000))
			PlayerInfo[i][pPauseTime] ++; 
			
		else PlayerInfo[i][pPauseTime] = 0;
	
		if(e_pAccountData[i][mLoggedin] == false)
		{
			if(loginTime[i] > 0)
			{
				loginTime[i]++;
				
				if(loginTime[i] >= 60)
				{
					SendServerMessage(i, "You were kicked for not logging in."); 
					KickEx(i); 
				}
			}
			
			if(registerTime[i] > 0)
			{
				registerTime[i]++;
				
				if(registerTime[i] >= 60)
				{
					SendServerMessage(i, "You were kicked for not registering.");
					KickEx(i); 
				}
			}
		}
		
		if (PlayerInfo[i][pAdminjailed] == true)
		{
			PlayerInfo[i][pAdminjailTime]--; 
			
			if(PlayerInfo[i][pAdminjailTime] < 1)
			{
				PlayerInfo[i][pAdminjailed] = false; 
				PlayerInfo[i][pAdminjailTime] = 0; 
				
				SendServerMessage(i, "You served your admin jail time.");
				
				new str[128];
				format(str, sizeof(str), "%s was released from admin jail.", ReturnName(i));
				SendAdminMessage(1, str);
				
				SetPlayerVirtualWorld(i, 0); SetPlayerInterior(i, 0);
				SetPlayerPos(i, 1553.0421, -1675.4706, 16.1953);
			}
		}
		if(PlayerInfo[i][MissionTarget][0] != INVALID_VEHICLE_ID && PlayerInfo[i][InMission] == CARJACKER_DELIVER)
		{
		    PlayerInfo[i][MissionTime] --;
		    new time[32];
			format(time, 32, "~w~%d_~r~SECONDS_LEFT.", PlayerInfo[i][MissionTime]);
			ShowInfoEx(i, "~r~DISMANTLING_THE_CAR", time);
			new lights, doors, panels, tires;
			GetVehicleDamageStatus(PlayerInfo[i][MissionTarget][0], panels, doors, lights, tires);
			if(PlayerInfo[i][MissionTime] <= 0)
			{
			    PlayerInfo[i][MissionReward] = CJ_MissionReward(PlayerInfo[i][MissionTarget][0]); // temp reward
			    UpdateVehicleDamageStatus(PlayerInfo[i][MissionTarget][0], 53674035, 33686020, 5, 15);
			    PlayerInfo[i][InMission] = CARJACKER_DROPOFF;
			    ShowInfoEx(i, "~r~THE_CAR_HAS_BEEN_CHOPPED", "DRIVE_WHAT'S_LEFT_OF_THE_VEHICLE_FAR_FROM_THE_SHOP.~n~~y~HIDE_IT_AND_YOU_WILL_BE_PAID.~w~/DROPOFF_WHEN_HIDDEN.~n~/LEAVEMISSION_TO_END_IT_ALL.~r~YOU_WON'T_BE_PAID~n~~r~[[YOU_WILL_BE_FINED_IF_YOU_DESTROY_THE_CAR]]");
			}
		}
	    if(VehicleInfo[GetPVarInt(i, "Breakin_ID")][ePhysicalAttack] && GetPlayerState(i) == PLAYER_STATE_ONFOOT)
	    {
			if(IsValidVehicle(GetPVarInt(i, "Breakin_ID")))
			{
				new Float:cX, Float:cY, Float:cZ;
				GetVehiclePos(GetPVarInt(i, "Breakin_ID"), cX, cY, cZ);
				
				if(GetVehicleDriver(GetPVarInt(i, "Breakin_ID")) != -1 || !IsPlayerInRangeOfPoint(i, 5.0, cX, cY, cZ))
				{
				    VehicleInfo[GetPVarInt(i, "Breakin_ID")][ePhysicalAttack] = false;
				    DestroyDynamic3DTextLabel(VehicleInfo[GetPVarInt(i, "Breakin_ID")][eVehicleLabel]);
				    VehicleInfo[GetPVarInt(i, "Breakin_ID")][vCooldown] = false;
				    SetPVarInt(i, "Breakin_ID", 0);
				}
			}
		}
		if(GetPVarInt(i, "Picklock") != INVALID_VEHICLE_ID)
		{
			new Float:cX, Float:cY, Float:cZ;
			new Float:dX, Float:dY, Float:dZ;
			
			GetVehicleModelInfo(VehicleInfo[GetPVarInt(i, "Picklock")][eVehicleModel], VEHICLE_MODEL_INFO_FRONTSEAT, cX, cY, cZ);
			GetVehicleRelativePos(GetPVarInt(i, "Picklock"), dX, dY, dZ, -cX - 0.5, cY, cZ);
			if(IsPlayerInRangeOfPoint(i, 1.2, dX, dY, dZ))
			{
			    if(GetPlayerSpecialAction(i) != SPECIAL_ACTION_DUCK)
			    {
					Job_Fails[i] = gettime();
			        ShowInfoEx(i, "PRYING_THE_DOOR_OPEN", "~r~YOU_MUST_BE_CROUCH_WHILE_PRYING.");
			        if(gettime() - Job_Fails[i] < 60)
			        {
						ShowInfoEx(i, "~r~MISSION_FAILED", "YOU_LEFT_THE_MISSION.", true);
					    SetPVarInt(i, "Picklock", INVALID_VEHICLE_ID);
					    SetPVarInt(i, "PryTime", 0);
					    Job_Fails[i] = 0;
			        }
			    }
			    else
			    {
				    SetPVarInt(i, "PryTime", GetPVarInt(i, "PryTime")-1);
					new time[32];
					format(time, 32, "~g~%d~w~SECONDS_REMAIN.", GetPVarInt(i, "PryTime"));
					ShowInfoEx(i, "~w~PRYING_THE_DOOR_OPEN", time);
					if(GetPVarInt(i, "PryTime") <= 0)
					{
						new statusString[90];
						new engine, lights, alarm, doors, bonnet, boot, objective;
						GetVehicleParamsEx(GetPVarInt(i, "Picklock"), engine, lights, alarm, doors, bonnet, boot, objective);

						format(statusString, sizeof(statusString), "~g~%s UNLOCKED", ReturnVehicleName(GetPVarInt(i, "Picklock")));
						SetVehicleParamsEx(GetPVarInt(i, "Picklock"), engine, lights, alarm, false, bonnet, boot, objective);
						VehicleInfo[GetPVarInt(i, "Picklock")][eVehicleLocked] = false;
						GameTextForPlayer(i, statusString, 3000, 3);
						ShowInfoEx(i, "_", "_", true);
					    SetPVarInt(i, "Picklock", INVALID_VEHICLE_ID);
					    SetPVarInt(i, "PryTime", 0);
					}
				}
			}
			else
			{
				Job_Fails[i] = gettime();
		        ShowInfoEx(i, "~w~PRYING_THE_DOOR_OPEN", "~r~YOU_ARE_TOO_FAR_AWAY_FROM_THE_VEHICLE.");
		        if(gettime() - Job_Fails[i] < 60)
		        {
					ShowInfoEx(i, "~r~MISSION_FAILED", "YOU_LEFT_THE_MISSION.", true);
				    SetPVarInt(i, "Picklock", INVALID_VEHICLE_ID);
				    SetPVarInt(i, "PryTime", 0);
				    Job_Fails[i] = 0;
		        }
			}
		}
		
		if(PlayerInfo[i][pDeathFix])
		{
			PlayerInfo[i][pDeathFix]++;
			if(PlayerInfo[i][pDeathFix] == 5)
			{
				PlayerInfo[i][pDeathFix] = 0;
			}
		}
		if(PlayerInfo[i][pUseGUI])
		{
			new str[24], phone_power[24];
			/*switch(GetNearestAntenna(i))
			{
			    case 1: str = "I";
			    case 2: str = "II";
			    case 3: str = "III";
		     	case 4: str = "IIII";
			    case 5: str = "IIIII";
			    default: str = "NO_SERVICE";
			}*/
			format(str, 24, "%d", GetNearestAntennaEx(i));
			PlayerTextDrawSetString(i, PhoneSignal[i], str);
		    format(phone_power, 24, "%d%%", PlayerInfo[i][pPhonePower]/100);
			PlayerTextDrawSetString(i, PhonePower[i], phone_power);
			if(PlayerInfo[i][pCalling] > 0 && PlayerInfo[i][pPhoneline] > 999 && !GetPVarInt(i, "UsePayphone"))
			{
			    if(GetNearestAntenna(i) == -1) HangupCall(i);
			    if(PlayerInfo[i][pPhonePower] == 0) HangupCall(i);
			    PlayerInfo[i][pPhonePower] -= randomEx(1, 3);
			}
			else
			{
			    PlayerInfo[i][pPhonePower] --;
			}
		}
		UpdatePlayerHud(i, GetPlayerVehicleID(i));
		if(PlayerTakingLicense[i] && PlayerLicenseTime[i] <= 60)
		{
			PlayerLicenseTime[i]--; 
			
			new
				str[128]
			;
			
			format(str, sizeof(str), "~w~%d", PlayerLicenseTime[i]);
			GameTextForPlayer(i, str, 2000, 3); 
			
			if(PlayerLicenseTime[i] < 1)
			{
				StopDriverstest(i);
				SendClientMessage(i, COLOR_DARKGREEN, "You took too long and failed."); 
			}
		}
	}
	return 1;
}

this::OnWeaponsUpdate()
{
	foreach(new i : Player)
	{
		if(e_pAccountData[i][mLoggedin] == false)
			continue;
		
		if(!PlayerHasWeapons(i))
			continue;
			
		for (new w = 0; w < 4; w++)
		{
			new idx = WeaponDataSlot(PlayerInfo[i][pWeapons][w]); 
			
			if(PlayerInfo[i][pWeapons][w] != 0 && PlayerInfo[i][pWeaponsAmmo][w] > 0)
			{
				GetPlayerWeaponData(i, idx, PlayerInfo[i][pWeapons][w], PlayerInfo[i][pWeaponsAmmo][w]); 
			}
			
			if(PlayerInfo[i][pWeapons][w] != 0 && PlayerInfo[i][pWeaponsAmmo][w] == 0)
			{
				PlayerInfo[i][pWeapons][w] = 0;
				//Removing 0 ammo weapons;
			}
		}
			
		return 1;
	}
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	new
		Float: vehicle_health
	;
	
    if(IsValidDynamic3DTextLabel(VehicleInfo[vehicleid][eVehicleLabel])) DestroyDynamic3DTextLabel(VehicleInfo[vehicleid][eVehicleLabel]);
    
	GetVehicleHealth(vehicleid, vehicle_health); 
	printf("[DEBUG] Vehicle ID: %i (%s) (Health: %.2f) destroyed by %s", ReturnVehicleName(vehicleid), vehicle_health, ReturnName(killerid)); 
	if(VehicleInfo[vehicleid][eVehicleFaction])
	{
	    SirenEvent(vehicleid, 0, false, true);
		SetVehicleToRespawn(vehicleid);
	}
	else
	{
		foreach(new i : Player) if(PlayerInfo[i][pDBID] == VehicleInfo[i][eVehicleOwnerDBID])
		{
			sendMessage(i, COLOR_RED, "Your %s was destroyed.", ReturnVehicleName(vehicleid));
			
			PlayerInfo[i][pVehicleSpawned] = false;
			PlayerInfo[i][pVehicleSpawnedID] = INVALID_VEHICLE_ID; 
		}
		else
		{
			new
				chanquery[128]
			;
			
			mysql_format(this, chanquery, sizeof(chanquery), "UPDATE characters SET pVehicleSpawned = 0, pVehicleSpawnedID = %i WHERE char_dbid = %i", INVALID_VEHICLE_ID, VehicleInfo[vehicleid][eVehicleOwnerDBID]);
			mysql_pquery(this, chanquery);
		}
	}	
		
	return 1; 
}

this::OnVehicleUpdate()
{
	new Float: vehicle_health;
		
	for (new i = 1, j = GetVehiclePoolSize(); i <= j; i++)
	{
		if(VehicleInfo[i][eVehicleAdminSpawn])
			continue;
			
		CallLocalFunction("OnVehicleFuelChange", "i", i);
		GetVehicleHealth(i, vehicle_health); 
		if(vehicle_health != VehicleInfo[i][eVehicleHealth])
		{
			if(CallLocalFunction("OnVehicleHealthChange","iff", i, vehicle_health, VehicleInfo[i][eVehicleHealth])) {
				VehicleInfo[i][eVehicleHealth] = vehicle_health;
			}
			else {
				SetVehicleHealth(i, VehicleInfo[i][eVehicleHealth]);
			}
		}
	}
	return 1;
}

this::OnVehicleFuelChange(vehicleid)
{
	new iEngine, iLights, iAlarm,
		iDoors, iBonnet, iBoot,
		iObjective
	;
	if(VehicleInfo[vehicleid][eVehicleEngineStatus])
	{
		GetVehicleParamsEx(vehicleid, iEngine, iLights, iAlarm, iDoors, iBonnet, iBoot, iObjective);
		if(VehicleInfo[vehicleid][eVehicleFuel] >= 1.0)
		{
		    VehicleInfo[vehicleid][eVehicleFuel] -= 0.01;
		    VehicleInfo[vehicleid][eVehicleEngine] -= 0.001;
		    if(VehicleInfo[vehicleid][eVehicleXMROn]) VehicleInfo[vehicleid][eVehicleBattery] -= 0.005;
			if(iLights == 1) VehicleInfo[vehicleid][eVehicleBattery] -= 0.003;
		}
		else if(VehicleInfo[vehicleid][eVehicleFuel] >= 1.0 && VehicleInfo[vehicleid][eVehicleEngine] <= 50.0)
		{
		    VehicleInfo[vehicleid][eVehicleEngine] -= 0.001 * randomEx(1,10);
		    VehicleInfo[vehicleid][eVehicleFuel] -= randomEx(1,3) * 0.2;
		    VehicleInfo[vehicleid][eVehicleBattery] -= 0.002;
		    if(VehicleInfo[vehicleid][eVehicleXMROn]) VehicleInfo[vehicleid][eVehicleBattery] -= 0.01;
			if(iLights == 1) VehicleInfo[vehicleid][eVehicleBattery] -= 0.005;
		}
		else if(VehicleInfo[vehicleid][eVehicleFuel] <= 0.0)
		{
		    VehicleInfo[vehicleid][eVehicleFuel] = 0.0;
			ToggleVehicleEngine(vehicleid, false);
			VehicleInfo[vehicleid][eVehicleEngineStatus] = false;
			for(new i = 0, j = GetMaxPlayers(); i < j; i ++)
			{
			    if(!IsPlayerConnected(i)) continue;
				if(GetPlayerState(i) == PLAYER_STATE_DRIVER && GetPlayerVehicleID(i) == vehicleid)
				{
			    	GameTextForPlayer(i, "~r~Vehicle has ran out of fuel!", 3500, 4);
			    	break;
			    }
			}
		}
	}
	return 1;
}

this::OnVehicleHealthChange(vehicleid, Float:newhealth, Float:oldhealth)
{
	new
        Float: vehicle_health_loss = oldhealth - newhealth,
		owner_id = INVALID_PLAYER_ID,
		str[128]
	;
	
	if(!VehicleInfo[vehicleid][eVehicleFaction])
	{
		if(VehicleInfo[vehicleid][eVehicleEngineStatus])
		{
	     	if(newhealth >= 550 && newhealth <= 649)
	        {
				VehicleInfo[vehicleid][eVehicleEngine] -= (vehicle_health_loss / 125.0);
	            VehicleInfo[vehicleid][eVehicleBattery] -= (vehicle_health_loss / 150.0);
			}
			else if(newhealth >= 390 && newhealth <= 549)
			{
				VehicleInfo[vehicleid][eVehicleEngine] -= (vehicle_health_loss / 100.0);
	            VehicleInfo[vehicleid][eVehicleBattery] -= (vehicle_health_loss / 125.0);
			}
			else if(newhealth >= 250 && newhealth <= 389)
			{
				VehicleInfo[vehicleid][eVehicleEngine] -= (vehicle_health_loss / 75.0);
	            VehicleInfo[vehicleid][eVehicleBattery] -= (vehicle_health_loss / 100.0);

				if(newhealth < 350.0)
				{
					ToggleVehicleEngine(vehicleid, false);
					VehicleInfo[vehicleid][eVehicleEngineStatus] = false;
					VehicleInfo[vehicleid][eVehicleTweak] = true;
					SetVehicleHealth(vehicleid, 360.0);
					foreach(new pid : Player) if(IsPlayerInVehicle(pid, vehicleid))
					{
					    if(GetPlayerVehicleID(pid) == vehicleid)
					    {
					        if(GetPlayerState(pid) == PLAYER_STATE_DRIVER)
					        {
								SendClientMessage(pid, COLOR_LIGHTRED, "{FF6347}Your vehicle is stalled! Press {FFFFFF}W{FF6347} and {FFFFFF}S{FF6347} to get it back.");
								GameTextForPlayer(pid, "~r~ENGINE HAS WENT DOWN~n~YOU HAVE TO TWEAK THE ENGINE!", 10000, 4);
								return 1;
					        }
					    }
					}
				}
	        }
		}
		if(newhealth <= 248) //this is the point where the vehicle starts to catch fire;
		{
			foreach(new p : Player) if(PlayerInfo[p][pDBID] == VehicleInfo[vehicleid][eVehicleOwnerDBID])
			{
				owner_id = p;
			}

			if (owner_id != INVALID_PLAYER_ID)
			{
				new
					Float:life_deplete
				;

				//life_deplete = VehicleInfo[vehicleid][eVehicleEngine] / 1.30;
				life_deplete = VehicleInfo[vehicleid][eVehicleEngine] - float(10+random(5));

				printf("life_deplete is: %f", life_deplete);

				VehicleInfo[vehicleid][eVehicleTimesDestroyed] ++;

				if(VehicleInfo[vehicleid][eVehicleEngine] - life_deplete < 1.00)
					VehicleInfo[vehicleid][eVehicleEngine] = 0.0;

				else VehicleInfo[vehicleid][eVehicleEngine] = life_deplete;
				VehicleInfo[vehicleid][eVehicleBattery] -= 10.0;

				PlayerInfo[owner_id][pVehicleSpawned] = false;
				PlayerInfo[owner_id][pVehicleSpawnedID] = INVALID_VEHICLE_ID;

				sendMessage(owner_id, COLOR_RED, "Your %s has been destroyed.", ReturnVehicleName(vehicleid));
				sendMessage(owner_id, COLOR_RED, "HEALTH: Engine health depleted to {FFFFFF}%.2f. {FF6346}Battery health depleted to {FFFFFF}%.2f{FF6346}.", VehicleInfo[vehicleid][eVehicleEngine], VehicleInfo[vehicleid][eVehicleBattery]);
			}
			else
			{
				mysql_format(this, str, sizeof(str), "UPDATE characters SET pVehicleSpawned = 0, pVehicleSpawnedID = %i WHERE char_dbid = %i", INVALID_VEHICLE_ID, VehicleInfo[vehicleid][eVehicleOwnerDBID]);
				mysql_pquery(this, str);
			}

			new
				car_driver = INVALID_PLAYER_ID
			;

			foreach(new c : Player) if(IsPlayerInVehicle(c, vehicleid))
			{
				if(GetPlayerState(c) == PLAYER_STATE_DRIVER)
					car_driver = c;
			}

			if(car_driver == INVALID_PLAYER_ID)
				format(str, sizeof(str), "Vehicle %s (ID: %i) was destroyed.", ReturnVehicleName(vehicleid), vehicleid);

			else format(str, sizeof(str), "Vehicle %s (ID %i) was destroyed. Driver was: %s", ReturnVehicleName(vehicleid), vehicleid, ReturnName(car_driver));

			SendAdminMessage(1, str);
			SaveVehicle(vehicleid);

			ResetVehicleVars(vehicleid);
			DestroyVehicle(vehicleid);
		}
	}
	return 1;
}
this::FunctionPaychecks()
{
	new 
		hour, 
		minute, 
		seconds
	;

	gettime(hour, minute, seconds); 
	
	if(minute == 00 && seconds == 59)
	{
		CallPaycheck(); 
		SetWorldTime(hour + 1); 
	}
	
	return 1;
}

this::CallPaycheck()
{
	foreach(new i : Player)
	{
		if(!PlayerInfo[i][pLoggedin])
			continue;
			
		new
			str[128],
			total_paycheck = 0
		; 
		
		new
			Float: interest,
			interest_convert,
			total_tax
		; 
		
		PlayerInfo[i][pTimeplayed]++; 
		PlayerInfo[i][pEXP]++; 
		
		if(PlayerInfo[i][pLevel] == 1)
			total_paycheck+= 2000; 
			
		else if(PlayerInfo[i][pLevel] == 2)
			total_paycheck+= 1500; 
			
		//Add an auto-level up on paycheck for level 1 and 2 to prevent paycheck farming.
			
		interest = (PlayerInfo[i][pBank] / 100) * 0.1; 
		interest_convert = floatround(interest, floatround_round); 
		
		total_tax = total_paycheck / 10; 
		
		sendMessage(i, COLOR_WHITE, "SERVER TIME:[ %s ]", ReturnHour());
		
		if(PlayerInfo[i][pBank] <= 0)
		{
		    new debt = randomEx(10, 20);
			sendMessage(i, COLOR_LIGHTRED, "$%i {FFFFFF}debt paid off through your paycheck", debt);
			PlayerInfo[i][pBank] -= debt;
		}
		SendClientMessage(i, COLOR_WHITE, "|___ BANK STATEMENT ___|"); 
		sendMessage(i, COLOR_FADE1, "   Balance: $%s", PlayerInfo[i][pBank]);
		SendClientMessage(i, COLOR_FADE1, "   Interest rate: 0.1");
		sendMessage(i, COLOR_FADE1, "   Interest Gained: $%s", interest_convert);
		sendMessage(i, COLOR_FADE1, "   Tax paid: $%s", total_tax);
		sendMessage(i, COLOR_FADE1, " ");
		sendMessage(i, COLOR_FADE1, " ");
		//sendMessage(i, COLOR_FADE1, "   Savings income: $%s, at rate: 0.5", MoneyFormat(savings));
		//sendMessage(i, COLOR_FADE1, "   Savings new balance: $%s", MoneyFormat(PlayerInfo[playerid][pSavings]));
		SendClientMessage(i, COLOR_WHITE, "|________________________|");
		
		PlayerInfo[i][pPaycheck]+= total_paycheck; 
		PlayerInfo[i][pBank]+= interest_convert; 
		PlayerInfo[i][pBank]-= total_tax; 
		
		sendMessage(i, COLOR_WHITE, "   New Balance: $%s", PlayerInfo[i][pBank]);
		if(PlayerInfo[i][pRentAt] > 0 && PlayerInfo[i][pBank] >= PropertyInfo[ PlayerInfo[i][pRentAt] ][ePropertyRentFee]) sendMessage(i, COLOR_WHITE, "   Rent: -$%d", PropertyInfo[ PlayerInfo[i][pRentAt] ][ePropertyRentFee]);
		else if(PlayerInfo[i][pRentAt] > 0 && PlayerInfo[i][pBank] < PropertyInfo[ PlayerInfo[i][pRentAt] ][ePropertyRentFee]) PlayerInfo[i][pRentAt] = 0, sendMessage(i, COLOR_RED, "You have been evicted from your rented house due to lack of payment.");

		if(PlayerInfo[i][pJob] == JOB_MECHANIC)
		{
			SendClientMessage(i, COLOR_WHITE, "You have received $1,250 for your mechanic duties.");
		}
		
		if(PlayerInfo[i][pLevel] == 1)
			SendClientMessage(i, COLOR_WHITE, "(( You have received $2,000 for being level 1. ))");
			
		else if(PlayerInfo[i][pLevel] == 2)
			SendClientMessage(i, COLOR_WHITE, "(( You have received $1,500 for being level 2. ))");
		
		new exp_count = ((PlayerInfo[i][pLevel]) * 4 + 2);
		if(PlayerInfo[i][pLevel] == 1 && PlayerInfo[i][pEXP] >= exp_count || PlayerInfo[i][pLevel] == 2 && PlayerInfo[i][pEXP] >= exp_count || PlayerInfo[i][pDonator] > 2 && PlayerInfo[i][pEXP] >= exp_count)
		{
			PlayerInfo[i][pLevel]++;
			PlayerInfo[i][pEXP] = 0;

			PlayerPlaySound(i, 1052, 0.0, 0.0, 0.0);
			SetPlayerScore(i, PlayerInfo[i][pLevel]);

			format(str, sizeof(str), "~g~Leveled Up~n~~w~You leveled up to level %i", PlayerInfo[i][pLevel]);
			GameTextForPlayer(i, str, 5000, 1);
		}
		
		format(str, sizeof(str), "~y~Payday~n~~w~Paycheck~n~~g~$%d", total_paycheck);
		GameTextForPlayer(i, str, 3000, 1); 
	
		SaveCharacter(i); 
	}
	return 1;
}

this::OnPlayerNearProperty()
{
	foreach(new i : Player)
	{
		if(PlayerInfo[i][pLoggedin] == false)
			continue;
			
		for(new p = 1; p < MAX_PROPERTY; p++)
		{
			if(!PropertyInfo[p][ePropertyDBID])
				continue;
				
			if(IsPlayerInRangeOfPoint(i, 3.0, PropertyInfo[p][ePropertyEntrance][0], PropertyInfo[p][ePropertyEntrance][1], PropertyInfo[p][ePropertyEntrance][2]))
			{
				if(GetPlayerInterior(i) != PropertyInfo[p][ePropertyEntranceInterior])
					continue;
					
				if(GetPlayerVirtualWorld(i) != PropertyInfo[p][ePropertyEntranceWorld])
					continue; 
		
				if(!PropertyInfo[p][ePropertyOwnerDBID])
				{
					SendClientMessage(i, COLOR_GREEN, "This property is for sale. Use /buyproperty."); 
					sendMessage(i, COLOR_GREEN, "Price: $%i", PropertyInfo[p][ePropertyMarketPrice]);
				}
				else
				{
					sendMessage(i, COLOR_GREEN, "You're standing on %s's porch. Use /enter to go in.",  ReturnDBIDName(PropertyInfo[p][ePropertyOwnerDBID]));
				}	
			}
		}
	}
	return 1;
}

this::OnPlayerNearBusiness()
{
	foreach(new i : Player)
	{
		if(PlayerInfo[i][pLoggedin] == false)
			continue;
			
		new
			id,
			str[128]
		;
		
		if((id = IsPlayerNearBusiness(i)) != 0)
		{
			if(!BusinessInfo[id][eBusinessOwnerDBID])
			{
				if(BusinessInfo[id][eBusinessType] > 5)
					format(str, sizeof(str), "%s~n~~w~Entrance Fee : ~g~$%d~n~~p~To use /enter", BusinessInfo[id][eBusinessName], BusinessInfo[id][eBusinessEntranceFee]); 
					
				else format(str, sizeof(str), "%s~n~~w~This business is for sale~n~Price : ~g~$%d~w~ Level : %d~n~~p~To buy use /buybiz", BusinessInfo[id][eBusinessName], BusinessInfo[id][eBusinessMarketPrice], BusinessInfo[id][eBusinessLevel]); 
			}
			else format(str, sizeof(str), "%s~n~~w~Owned By : %s~n~Entrance Fee : ~g~$%d~n~~p~To use /enter", BusinessInfo[id][eBusinessName], ReturnDBIDName(BusinessInfo[id][eBusinessOwnerDBID]), BusinessInfo[id][eBusinessEntranceFee]); 
			
			GameTextForPlayer(i, str, 3500, 3); 	
		}
	}
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	if(killerid != INVALID_PLAYER_ID)
		SendAdminMessageEx(COLOR_RED, 4, "[DEBUG DEBUG] %s was killed by %s. (%s)", ReturnName(playerid), ReturnName(killerid), ReturnWeaponName(reason));

	if(IsValidVehicle(GetPVarInt(playerid, "Breakin_ID")))
	{
		new Float:cX, Float:cY, Float:cZ;
		GetVehiclePos(GetPVarInt(playerid, "Breakin_ID"), cX, cY, cZ);

	    VehicleInfo[GetPVarInt(playerid, "Breakin_ID")][ePhysicalAttack] = false;
	    DestroyDynamic3DTextLabel(VehicleInfo[GetPVarInt(playerid, "Breakin_ID")][eVehicleLabel]);
	    VehicleInfo[GetPVarInt(playerid, "Breakin_ID")][vCooldown] = false;
	    SetPVarInt(playerid, "Breakin_ID", 0);
	}
	printf("Callback OnPlayerDeath called for player %s (ID: %i)", ReturnName(playerid), playerid); 
	//SetTimerEx("SetPlayersSpawn", 2100, false, "i", playerid);
	return 1; 
}

this::OnPlayerWounded(playerid, killerid, reason)
{
	new
		str[128]
	;
	
	PlayerInfo[playerid][pDeathFix] = 1; 
	
	format(str, sizeof(str), "%s has been brutally wounded by %s. (%s)", ReturnName(playerid), ReturnName(killerid), ReturnWeaponName(reason)); 
	SendAdminMessageEx(COLOR_RED, 1, str); 

	GameTextForPlayer(playerid, "~b~BRUTALLY WOUNDED", 5000, 3);
	ApplyAnimation(playerid, "WUZI", "CS_Dead_Guy", 4.1, 0, 1, 1, 1, 0, 1);		
	
	SetPlayerHealth(playerid, 26); 
	SetPlayerWeather(playerid, 250); 
	
	GiveMoney(playerid, -200); 
	SetPlayerTeam(playerid, PLAYER_STATE_WOUNDED); 
	
	SendClientMessage(playerid, COLOR_LIGHTRED, "You were brutally wounded, now if a medic or anyone else doesn't save you, you will die.");
	SendClientMessage(playerid, COLOR_LIGHTRED, "To accept death type /acceptdeath.");
	sendMessage(playerid, COLOR_LIGHTRED, "(( Has been shot %i times, /damages %i for more information. ))", TotalPlayerDamages[playerid], playerid);
	return 1;
}

this::OnPlayerDead(playerid, killerid, reason, executed)
{
	new
		str[128]
	;
	
	if(executed == 1)
	{
		format(str, sizeof(str), "%s has been executed by %s. (%s)", ReturnName(playerid), ReturnName(killerid), ReturnWeaponName(reason)); 
		SendAdminMessageEx(COLOR_RED, 1, str); 
	}
	
	SetPlayerTeam(playerid, PLAYER_STATE_DEAD); 
	PlayerInfo[playerid][pRespawnTime] = gettime(); 
	
	SendClientMessage(playerid, COLOR_YELLOWEX, "-> You're now dead. You need to wait 60 seconds until you can /respawnme."); 
	
	ClearAnimations(playerid, 1);
	for(new i =0; i <4; i++)
		ApplyAnimation(playerid, "WUZI", "CS_Dead_Guy", 4.1, 0, 1, 1, 1, 0, 1);	
	
	TogglePlayerControllable(playerid, 0);
	SetPlayerWeather(playerid, globalWeather); 
	return 1;
}

public OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid, bodypart)
{
	if(issuerid != INVALID_PLAYER_ID)
	{
		new
			Float:health
		;
		
		PlayerInfo[playerid][pLastDamagetime] = gettime();
		GetPlayerHealth(playerid, health); 
		
		if(GetPlayerTeam(playerid) != PLAYER_STATE_ALIVE && PlayerInfo[playerid][pDeathFix])
			SetPlayerHealth(playerid, health); 
		
		if(GetPlayerTeam(playerid) == PLAYER_STATE_ALIVE)
		{
		    if(health - amount <= 30.0)
		    {
		        SendClientMessage(playerid, COLOR_LIGHTRED, "-> Low health, shooting skills at medium.");
			    SetPlayerSkillLevel(playerid, WEAPONSKILL_PISTOL, 200);
				SetPlayerSkillLevel(playerid, WEAPONSKILL_AK47, 200);
			    SetPlayerSkillLevel(playerid, WEAPONSKILL_DESERT_EAGLE, 200);
			    SetPlayerSkillLevel(playerid, WEAPONSKILL_SHOTGUN, 200);
			    SetPlayerSkillLevel(playerid, WEAPONSKILL_M4, 200);
			    SetPlayerSkillLevel(playerid, WEAPONSKILL_MP5, 200);
		    }

		    if(bodypart == 7 || bodypart == 8 || amount > 6.0)//bodypart == 8
			{
			    SetPVarInt(playerid, "BrokenLeg", 1);
				SendClientMessage(playerid, COLOR_YELLOWEX, "-> You've been shot in the legs, you are not able to jump and sprite.");
			}
			SetPlayerHealth(playerid, health - amount); 
			CallbackDamages(playerid, issuerid, bodypart, weaponid, amount); 
		}
		
		if(health - amount <= 4)
		{
			if(GetPlayerTeam(playerid) == PLAYER_STATE_ALIVE)
			{
				if(IsPlayerInAnyVehicle(playerid))
					ClearAnimations(playerid); 
				
				CallLocalFunction("OnPlayerWounded", "iii", playerid, issuerid, weaponid); 
				return 0;
			}
			
			return 0;
		}
		
		if(GetPlayerTeam(playerid) == PLAYER_STATE_WOUNDED)
		{
			if(!PlayerInfo[playerid][pDeathFix])
			{				
				CallLocalFunction("OnPlayerDead", "iiii", playerid, issuerid, weaponid, 1);
				return 0;
			}
			
			return 0;
		}
		
		if(GetPlayerTeam(playerid) != PLAYER_STATE_ALIVE)
		{
			SetPlayerHealth(playerid, health);
			return 0;
		}
	}
	return 1;
}

public OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ)
{
	if(hittype == BULLET_HIT_TYPE_PLAYER) //Death system; 
	{	
		if(GetPlayerTeam(hitid) == PLAYER_STATE_WOUNDED && !PlayerInfo[hitid][pDeathFix])
		{	
			CallLocalFunction("OnPlayerDead", "iii", hitid, playerid, weaponid);
			return 0;
		} 
		else if(GetPlayerTeam(hitid) != PLAYER_STATE_ALIVE)
			return 0; 
			
	}
	
	if(PlayerInfo[playerid][pTaser] && weaponid == 23)
	{
		SetPlayerArmedWeapon(playerid, 0); 
		
		ApplyAnimation(playerid, "SILENCED", "Silence_reload", 4.1, 0, 1, 1, 1, 1, 1);
		ApplyAnimation(playerid, "SILENCED", "Silence_reload", 4.1, 0, 1, 1, 1, 1, 1);
		
		SetTimerEx("OnTaserShoot", 1100, false, "i", playerid); 
	}
	
	if(hittype == BULLET_HIT_TYPE_PLAYER) //Taser system; 
	{
		if(PlayerInfo[playerid][pTaser] && weaponid == 23)
		{
			if(!IsPlayerNearPlayer(playerid, hitid, 15.0))
			{
				sendMessage(playerid, COLOR_YELLOWEX, "-> You aren't close enough to hit %s with your taser.", ReturnName(hitid, 0));
				return 0;
			}
			
			SetPlayerDrunkLevel(hitid, 4000); 
			TogglePlayerControllable(playerid, 1); 
			
			SendNearbyMessage(hitid, 20.0, COLOR_EMOTE, "* %s falls on the ground after being hit by %s's taser.", ReturnName(hitid, 0), ReturnName(playerid, 0)); 
			GameTextForPlayer(hitid, "~b~You Are Tasered", 2500, 3);
			
			SendClientMessage(hitid, COLOR_YELLOWEX, "-> You were just hit by a taser. 10,000 volts go through your body.");
			sendMessage(playerid, COLOR_YELLOWEX, "-> You hit %s with your taser!", ReturnName(hitid, 0));
			
			ClearAnimations(playerid, 1);
			SetTimerEx("OnPlayerTasered", 1200, false, "i", hitid); 
			return 0;
		}
	}
	return 1;
}

public OnPlayerSpawn(playerid)
{	
	Streamer_Update(playerid);
	
	SetPlayerTeam(playerid, PLAYER_STATE_ALIVE);
	SetPlayerWeather(playerid, globalWeather); 
	
	if (!PlayerInfo[playerid][pSetupInfo])
	{
	    SetPlayerInterior(playerid, 14);
	    SetPlayerPos(playerid, 208.3268, -154.9872, 1000.5234);
	    SetPlayerFacingAngle(playerid, 180.0000);
     	SetPlayerCameraPos(playerid, 208.276733, -158.160308, 1001.734130);
		SetPlayerCameraLookAt(playerid, 208.316360, -155.487106, 1001.023437);
	    SetPlayerVirtualWorld(playerid, playerid);
		TogglePlayerControllable(playerid, 0);
		ResetCharacterSetup(playerid);
		SelectTextDraw(playerid, -1);

		for (new i = 0; i < 16; i ++) {
		    PlayerTextDrawShow(playerid, SetUp[playerid][i]);
		}
	}
	else
	{
		if(PlayerInfo[playerid][pAdminjailed] == true)
		{
			ClearAnimations(playerid);

			SetPlayerPos(playerid, 2687.3630, 2705.2537, 22.9472);
			SetPlayerInterior(playerid, 0); SetPlayerVirtualWorld(playerid, 1338);

			SendServerMessage(playerid, "You're currently admin jailed. You have %i minutes left.", PlayerInfo[playerid][pAdminjailTime] / 60);
		}
		else
		{
			if(PlayerInfo[playerid][pWeaponsSpawned] == false)
			{
				for(new i = 0; i < 4; i ++)
				{
					if(PlayerInfo[playerid][pWeapons][i] != 0)
					{
						GivePlayerGun(playerid, PlayerInfo[playerid][pWeapons][i], PlayerInfo[playerid][pWeaponsAmmo][i]);
					}
				}

				SetPlayerArmedWeapon(playerid, 0);
				PlayerInfo[playerid][pWeaponsSpawned] = true;
			}

			if(PlayerInfo[playerid][pSpectating] != INVALID_PLAYER_ID)
			{
				SetPlayerPos(playerid, PlayerInfo[playerid][pLastPos][0], PlayerInfo[playerid][pLastPos][1], PlayerInfo[playerid][pLastPos][2]);
				PlayerInfo[playerid][pSpectating] = INVALID_PLAYER_ID;
			}
			else SetPlayersSpawn(playerid);
		}
	}
	return 1;
}

public OnPlayerText(playerid, text[])
{
	if(PlayerInfo[playerid][pSpectating] != INVALID_PLAYER_ID)
	{
		SendServerMessage(playerid, "You can't type while you're spectating.");
		return 0;
	}
	
	if(PlayerInfo[playerid][pLoggedin] && GetPlayerTeam(playerid) != PLAYER_STATE_ALIVE)
	{
		SendServerMessage(playerid, "You can't talk when you aren't alive.");
		return 0;
	}
	
	if(PlayerInfo[playerid][pRelogging])
	{
		SendServerMessage(playerid, "You can't talk when relogging.");
		return 0;
	}

	if(!e_pAccountData[playerid][mLoggedin] && !PlayerInfo[playerid][pLoggedin])
	{
		SendServerMessage(playerid, "You can't type during login.");
		return 0;
	}
	
	new 
		string[128]; 
		
	if(PlayerInfo[playerid][pPhoneline] != INVALID_PLAYER_ID && PlayerInfo[playerid][pCalling] == 2)
	{
		if(PlayerInfo[playerid][pPhoneline] == 911)
		{
			format(string, sizeof(string), "%s says (phone): %s", ReturnName(playerid, 0), text); 
			LocalChat(playerid, 20.0, string, COLOR_FADE1, COLOR_FADE2, COLOR_FADE3, COLOR_FADE4); 
			
			switch(Player911Type[playerid])
			{
				case 0: // 0 service, 1 - emergency, 2 - location
				{
					if(strfind(text, "Police", true) != -1 || strfind(text, "Cops", true) != -1 || strfind(text, "Law enforcement", true) != -1)
					{
						format(Player911Text[playerid][0], 128, "%s", text);
						
						SendClientMessage(playerid, COLOR_YELLOWEX, "911 Operator says: You're being transferred to the police. What's your emergency?"); 
						Player911Type[playerid] = 1; 
					}
					else if(strfind(text, "Medics", true) != -1 || strfind(text, "Paramedics", true) != -1 || strfind(text, "Ambulance", true) != -1 || strfind(text, "Fire", true) != -1)
					{
						format(Player911Text[playerid][0], 128, "%s", text);
						
						SendClientMessage(playerid, COLOR_YELLOWEX, "911 Operator says: You're being transferred to the fire department. What's your emergency?"); 
						Player911Type[playerid] = 2;
					}
					else SendClientMessage(playerid, COLOR_YELLOWEX, "911 Operator says: Repeat that, please."); 
				}
				case 1: //Police input;
				{
					if(strlen(text) < 3)
						return SendErrorMessage(playerid, "Please input actual text."); 
						
					format(Player911Text[playerid][1], 128, "%s", text);
					
					SendClientMessage(playerid, COLOR_YELLOWEX, "911 Operator says: What's your location?"); 
					Player911Type[playerid] = 911; 
				}
				case 911: //Police;
				{
					if(strlen(text) < 3)
						return SendErrorMessage(playerid, "Please input actual text."); 
						
					format(Player911Text[playerid][2], 128, "%s", text);
					SendClientMessage(playerid, COLOR_YELLOWEX, "911 Operator says: Police units were dispatched."); 
					
					Send911Message(playerid, 911); 
				}
				case 2: //Medic input;
				{
					if(strlen(text) < 3)
						return SendErrorMessage(playerid, "Please input actual text."); 
						
					format(Player911Text[playerid][1], 128, "%s", text);
					
					SendClientMessage(playerid, COLOR_YELLOWEX, "911 Operator says: What's your location?"); 
					Player911Type[playerid] = 811; 
				}
				case 811: // Medic;
				{
					if(strlen(text) < 3)
						return SendErrorMessage(playerid, "Please input actual text."); 
						
					format(Player911Text[playerid][2], 128, "%s", text);
					SendClientMessage(playerid, COLOR_YELLOWEX, "911 Operator says: Medical units were dispatched."); 
					
					Send911Message(playerid, 811); 
				}
			}
		}
		else if(PlayerInfo[playerid][pPhoneline] == 444)
		{
			if(1000 > PlayerInfo[playerid][pMoney])
			{
			    SendClientMessage(playerid, COLOR_YELLOWEX, "Agency says (phone): You must have at least $1000 to complete the transaction.");
			}
			else if(PlayerInQueue(playerid) > GetAdLimit(playerid))
			{
			    sendMessage(playerid, COLOR_YELLOWEX, "Agency says (phone): You already have %d advertisements in queue which is the max.", PlayerInQueue(playerid));
			}
			else if(GetNextAdSlot() == -1)
			{
			    SendClientMessage(playerid, COLOR_YELLOWEX, "Agency says (phone): We don't have the slot right now, try it later.");
			}
			else
			{
                publishAdvertisement(playerid, text, true);
				GiveMoney(playerid, -1000);
			    SendClientMessage(playerid, COLOR_YELLOWEX, "Agency says (phone): Your advertisement will be posted shortly.");
			    SendAdminMessageEx(COLOR_YELLOWEX, 1, "AdmWarn: %s released an advertisement: %s", ReturnName(playerid, 0), text);
			}
			callcmd::hangup(playerid, "");
  		}
		else if(PlayerInfo[playerid][pPhoneline] == 445)
		{
			if(2500 > PlayerInfo[playerid][pMoney])
			{
			    SendClientMessage(playerid, COLOR_YELLOWEX, "Agency says (phone): You must have at least $2500 to complete the transaction.");
			}
			else if(PlayerInQueue(playerid) > GetAdLimit(playerid))
			{
			    sendMessage(playerid, COLOR_YELLOWEX, "Agency says (phone): You already have %d advertisements in queue which is the max limit.", PlayerInQueue(playerid));
			}
			else if(GetNextAdSlot() == -1)
			{
			    SendClientMessage(playerid, COLOR_YELLOWEX, "Agency says (phone): We don't have the slot right now, try it later.");
			}
			else
			{
				publishAdvertisement(playerid, text, false);
			    SendClientMessage(playerid, COLOR_YELLOWEX, "Agency says (phone): Your advertisement will be posted shortly.");
			    SendAdminMessageEx(COLOR_YELLOWEX, 1, "AdmWarn: %s released a cad: %s", ReturnName(playerid, 0), text);
			}
			callcmd::hangup(playerid, "");
  		}
		else
		{
		    if(PlayerInfo[playerid][pCalling] == 2)
		    {
		        new message[128+1]; // +1 for looping
			    format(message, sizeof(message), text);
	        	new playerAntenna, receiverAntenna;
				new antennasLimit = sizeof(AntennasRadio);
	            new length = strlen(message);
				new position;

				receiverAntenna = GetNearestAntenna( PlayerInfo[playerid][pPhoneline] );
				playerAntenna = GetNearestAntenna(playerid);

				if(receiverAntenna == -1 || playerAntenna == -1)
				{
				    HangupCall(playerid); return 0;
				}
				if(receiverAntenna > antennasLimit || playerAntenna > antennasLimit) for(new j; j < random(6); j++)
				{
					if(j >= length) break;
					position = random(length);

					if(position + DOTS_ADD > length)position--;
					if(!position)position++;

					strdel(message, position, position + DOTS_ADD);
					strins(message, "...", position);
				}
				if(strlen(text) > 87)
				{
				    
					format(string, sizeof(string), "%s says (phone): %.87s...", ReturnName(playerid, 0), message);
					LocalChat(playerid, 20.0, string, COLOR_FADE1, COLOR_FADE2, COLOR_FADE3, COLOR_FADE4);

					if(!PlayerInfo[ PlayerInfo[playerid][pPhoneline] ][pPhonespeaker])
						SendClientMessage(PlayerInfo[playerid][pPhoneline], COLOR_YELLOWEX, string);

					else LocalChat(PlayerInfo[playerid][pPhoneline], 6.0, string, COLOR_FADE1, COLOR_FADE2, COLOR_FADE3, COLOR_FADE4);

					format(string, sizeof(string), "%s says (phone): ... %s", ReturnName(playerid, 0), message[87]);
					LocalChat(playerid, 20.0, string, COLOR_FADE1, COLOR_FADE2, COLOR_FADE3, COLOR_FADE4);

					if(!PlayerInfo[ PlayerInfo[playerid][pPhoneline] ][pPhonespeaker])
						SendClientMessage(PlayerInfo[playerid][pPhoneline], COLOR_YELLOWEX, string);

					else LocalChat(PlayerInfo[playerid][pPhoneline], 6.0, string, COLOR_FADE1, COLOR_FADE2, COLOR_FADE3, COLOR_FADE4);
				}
				else
				{
					format(string, sizeof(string), "%s says (phone): %s", ReturnName(playerid, 0), message);
					LocalChat(playerid, 20.0, string, COLOR_FADE1, COLOR_FADE2, COLOR_FADE3, COLOR_FADE4);

					if(!PlayerInfo[ PlayerInfo[playerid][pPhoneline] ][pPhonespeaker])
						SendClientMessage(PlayerInfo[playerid][pPhoneline], COLOR_YELLOWEX, string);

					else LocalChat(PlayerInfo[playerid][pPhoneline], 6.0, string, COLOR_FADE1, COLOR_FADE2, COLOR_FADE3, COLOR_FADE4);
				}
			}
			else
			{
				SendErrorMessage(playerid, "An error occured, please contact an administrator.");
			    return callcmd::hangup(playerid, "");
			}
		}
		return 0; 
	}

    if (PlayerInfo[playerid][pPhoneline] == INVALID_PLAYER_ID && !PlayerInfo[playerid][pAnimation] && GetPlayerTeam(playerid) == PLAYER_STATE_ALIVE)
	{
		PlayChatStyle(playerid, text);
    }
	
	if (strlen(text) > 99)
	{
		format (string, sizeof(string), "%s says: %.99s...", ReturnName(playerid, 0), text);
		LocalChat(playerid, 20.0, string, COLOR_FADE1, COLOR_FADE2, COLOR_FADE3, COLOR_FADE4);
				
		format (string, sizeof(string), "%s says: ... %s", ReturnName(playerid, 0), text[99]); 
		LocalChat(playerid, 20.0, string, COLOR_FADE1, COLOR_FADE2, COLOR_FADE3, COLOR_FADE4);
				
	}
	else 
	{	
		format (string, sizeof(string), "%s says: %s", ReturnName(playerid, 0), text);
		LocalChat(playerid, 20.0, string, COLOR_FADE1, COLOR_FADE2, COLOR_FADE3, COLOR_FADE4);
	}
	
	return 0;
}

public OnPlayerUpdate(playerid)
{
    if (NetStats_GetConnectedTime(playerid) - WeaponTick[playerid] >= 250)
    {
        new weaponid, ammo, objectslot, count, index;

        for (new i = 2; i <= 7; i++) //Loop only through the slots that may contain the wearable weapons
        {
            GetPlayerWeaponData(playerid, i, weaponid, ammo);
            index = weaponid - 22;

            if (weaponid && ammo && !WeaponSettings[playerid][index][Hidden] && IsWeaponWearable(weaponid) && EditingWeapon[playerid] != weaponid)
            {
                objectslot = GetWeaponObjectSlot(weaponid);

                if (GetPlayerWeapon(playerid) != weaponid)
                    SetPlayerAttachedObject(playerid, objectslot, ReturnWeaponsModel(weaponid), WeaponSettings[playerid][index][Bone], WeaponSettings[playerid][index][Position][0], WeaponSettings[playerid][index][Position][1], WeaponSettings[playerid][index][Position][2], WeaponSettings[playerid][index][Position][3], WeaponSettings[playerid][index][Position][4], WeaponSettings[playerid][index][Position][5], 1.0, 1.0, 1.0);

                else if (IsPlayerAttachedObjectSlotUsed(playerid, objectslot)) RemovePlayerAttachedObject(playerid, objectslot);
            }
        }
        for (new i; i <= 5; i++) if (IsPlayerAttachedObjectSlotUsed(playerid, i))
        {
            count = 0;

            for (new j = 22; j <= 38; j++) if (PlayerHasWeapon(playerid, j) && GetWeaponObjectSlot(j) == i)
                count++;

            if (!count) RemovePlayerAttachedObject(playerid, i);
        }
        WeaponTick[playerid] = NetStats_GetConnectedTime(playerid);
    }

	if(PlayerInfo[playerid][pAdminDuty])
		SetPlayerHealth(playerid, 250);
		
	PlayerInfo[playerid][pPauseCheck] = GetTickCount(); 

	new
		string[128];
		
	if(GetPlayerTeam(playerid) == PLAYER_STATE_WOUNDED)
	{
		format(string, sizeof(string), "(( Has been injured %d times, /damages %d for more information. ))", TotalPlayerDamages[playerid], playerid);
		SetPlayerChatBubble(playerid, string, COLOR_RED, 30.0, 2500); 
		
		ApplyAnimation(playerid, "WUZI", "CS_Dead_Guy", 4.1, 0, 1, 1, 1, 0, 1);	
	}
	else if(GetPlayerTeam(playerid) == PLAYER_STATE_DEAD)
	{
		SetPlayerChatBubble(playerid, "(( THIS PLAYER IS DEAD ))", COLOR_RED, 30.0, 2500); 
	}
	
	return 1;
}

public OnPlayerCommandReceived(playerid, cmd[], params[], flags)
{
	if(PlayerInfo[playerid][pLoggedin] == true)
	{
		printf("Player [%s] sent command: %s", ReturnName(playerid), cmd);
		return 1;
	}
	else
	{
		SendClientMessage(playerid, COLOR_RED, "ACCESS DENIED:{FFFFFF} You need to be logged in to use commands.");
		printf("Player [%s] tried to send command: %s (During login, denied access)", ReturnName(playerid), cmd);
		return 0;
	}
}

public OnPlayerCommandPerformed(playerid, cmd[], params[], result, flags)
{
	if(result == -1)
	{
		if(strlen(cmd) > 28) // Preventing long bad commands from returning default message;
			SendServerMessage(playerid, "Sorry, that command doesn't exist. Use /help if you need assistance."); 
			
		else
			SendServerMessage(playerid, "Sorry, the command \"%s\" doesn't exist. Use /help if you need assistance.", cmd);
	}
	else return 1;
	return 1;
}

/*public OnUnoccupiedVehicleUpdate(vehicleid, playerid, passenger_seat, Float:new_x, Float:new_y, Float:new_z, Float:vel_x, Float:vel_y, Float:vel_z)
{
    // Check if it moved far	
    if(GetVehicleDistanceFromPoint(vehicleid, new_x, new_y, new_z) > 50)
    {
        // Reject the update
		SendClientMessageToAllEx(COLOR_RED, "OnUnoccupiedVehicleUpdate called for Vehicle ID %i.", vehicleid);
        return 0;
    }
 
    return 1;
}*/

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	if(newstate == PLAYER_STATE_DRIVER)
	{
		if(!VehicleInfo[GetPlayerVehicleID(playerid)][eVehicleEngineStatus])
			SendClientMessage(playerid, COLOR_DARKGREEN, "The engine is off. (/engine)");
	
		if(VehicleInfo[GetPlayerVehicleID(playerid)][eVehicleOwnerDBID] == PlayerInfo[playerid][pDBID])
			sendMessage(playerid, COLOR_WHITE, "Welcome to your %s.", ReturnVehicleName(GetPlayerVehicleID(playerid)));
			
		OnPlayerChangeHud(playerid);
			
		for(new i = 0; i < sizeof dmv_vehicles; i++) if(GetPlayerVehicleID(playerid) == dmv_vehicles[i])
			SendServerMessage(playerid, "You're inside a DMV vehicle. Use /licenseexam to start taking your test."); 
	}
	
	if(newstate == PLAYER_STATE_DRIVER || newstate == PLAYER_STATE_PASSENGER)
	{
		if(VehicleInfo[GetPlayerVehicleID(playerid)][eVehicleXMROn])
		{
			PlayAudioStreamForPlayer(playerid, VehicleInfo[GetPlayerVehicleID(playerid)][eVehicleXMRURL]);
		}
	}
	
	if(oldstate == PLAYER_STATE_DRIVER || oldstate == PLAYER_STATE_PASSENGER && newstate == PLAYER_STATE_ONFOOT)
	{
		StopAudioStreamForPlayer(playerid); 
		showMDCLayout(playerid, false);
	}
	
	if(oldstate == PLAYER_STATE_DRIVER)
	{
		OnPlayerChangeHud(playerid);
		if(DealershipPlayerCar[playerid] != INVALID_VEHICLE_ID)
		{
			if(IsValidVehicle(DealershipPlayerCar[playerid]) && !VehicleInfo[DealershipPlayerCar[playerid]][eVehicleDBID])
			{
				DestroyVehicle(DealershipPlayerCar[playerid]); 
			}
			
			if(!PlayerPurchasingVehicle[playerid])
				ResetDealershipVars(playerid); 
		}
		
		if(PlayerTakingLicense[playerid])
			StopDriverstest(playerid);
	}
	
	return 1; 
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	if(!ispassenger && VehicleInfo[vehicleid][eVehicleFaction] && PlayerInfo[playerid][pFaction] != VehicleInfo[vehicleid][eVehicleFaction])
	{
		if(!playerTextdraw[playerid])
		{
			playerVehicleTextdraw[playerid] = CreateDynamic3DTextLabel("You can't enter this. (Faction-vehicle)", COLOR_WHITE, 0.0, 0.0, 0.0, 10.0,  vehicleid, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), playerid); 
			SetTimerEx("OnVehicleTextdraw", 4000, false, "i", playerid); 
			
			playerTextdraw[playerid] = true;
		}
		
		return ClearAnimations(playerid);
	}
	
	if(!ispassenger)
	{
		for(new i = 0; i < sizeof dmv_vehicles; i++) if(vehicleid == dmv_vehicles[i])
		{
			if(PlayerInfo[playerid][pDriversLicense])
			{
				SendErrorMessage(playerid, "You already have a driver's license.");
				return ClearAnimations(playerid);
			}
		}
	}
	
	return 1;
}

Float:XB_GetDistanceBetweenTPoints(Float:x,Float:y,Float:z,Float:tx,Float:ty,Float:tz)
{
	new Float:temp1, Float:temp2 , Float:temp3;
	temp1 = x-tx;temp2 = y-ty;
	temp3 = z-tz;
	return floatsqroot(temp1*temp1+temp2*temp2+temp3*temp3);
}

public OnPlayerEditDynamicObject(playerid, objectid, response, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz)
{
	if(PlayerInfo[playerid][pEditingObject])
	{
		switch(PlayerInfo[playerid][pEditingObject])
		{
			case 1:
			{
				if(response == EDIT_RESPONSE_CANCEL)
				{
					DestroyDynamicObject(PlayerInfo[playerid][pAddObject]); 
					PlayerInfo[playerid][pEditingObject] = 0;
						
					SendServerMessage(playerid, "You're no longer buying a boombox."); 
					return 1;
				}
					
				if(response == EDIT_RESPONSE_FINAL)
				{
					ConfirmDialog(playerid, "Confirmation", "Are you sure you want to buy this?\nPrice: $1,000", "OnPropertyBoombox", IsPlayerInProperty(playerid), x, y, z, rx, ry, rz); 
					return 1;
				}
			}
			
			case 2:
			{
					//furniture
					return 1;
			}
			case 3:
			{
			    new 
		            vehicleid = GetPVarInt(playerid, "getVehicleID" ),
		            slot = GetPVarInt(playerid, "getSlot" ),
					Float:ofx, Float:ofy,
					Float:ofz, Float:ofaz,
					Float: getPoint[3],
					Float:getDistance,
					insert[128],
		            Float:finalx, Float:finaly,
			    	Float:px, Float:py, Float:pz, Float:roz
				;
				
				GetVehiclePartPos(vehicleid, VEHICLE_PART_CHASSIS, getPoint[0], getPoint[1], getPoint[2]);
		        getDistance = XB_GetDistanceBetweenTPoints(x, y, z, getPoint[0], getPoint[1], getPoint[2]);
				if(response == EDIT_RESPONSE_CANCEL)
				{
				    AttachDynamicObjectToVehicle( vehicle_trunk_data[vehicleid][slot][temp_object] , vehicleid, 0, 0, 0, 0, 0, 0);
				    SendClientMessage(playerid, COLOR_LIGHTRED, "INFO: Your weapon was out of bound and set to a default position.");
				    
				    for(new i = 0; i < 6; i ++) vehicle_trunk_data[vehicleid][slot][wep_offset][i] = 0.0;

					mysql_format(this, insert, sizeof(insert), "UPDATE vehicle_trunk SET offsetX = 0.0, offsetY = 0.0, offsetZ = 0.0, rotX = 0.0, rotY = 0.0, rotZ = 0.0 WHERE id = %i",
						vehicle_trunk_data[vehicleid][slot][data_id]);
						
					mysql_tquery(this, insert);
					DeletePVar(playerid, "getVehicleID");
					DeletePVar(playerid, "getSlot");
					PlayerInfo[playerid][pEditingObject] = 0;
					return true;
				}
				if(response == EDIT_RESPONSE_FINAL)
				{
				    if(getDistance > 1.8)
				    {
					    AttachDynamicObjectToVehicle( vehicle_trunk_data[vehicleid][slot][temp_object] , vehicleid, 0, 0, 0, 0, 0, 0);
					    SendClientMessage(playerid, COLOR_YELLOWEX, "INFO: Your weapon was out of bound and set to a default position.");

					    for(new i = 0; i < 6; i ++) vehicle_trunk_data[vehicleid][slot][wep_offset][i] = 0.0;

						mysql_format(this, insert, sizeof(insert), "UPDATE vehicle_trunk SET offsetX = 0.0, offsetY = 0.0, offsetZ = 0.0, rotX = 0.0, rotY = 0.0, rotZ = 0.0 WHERE id = %i",
							vehicle_trunk_data[vehicleid][slot][data_id]);

						mysql_tquery(this, insert);
				    }
				    else
				    {
					    GetVehiclePos(vehicleid, px, py, pz);
					    GetVehicleZAngle(vehicleid, roz);
					    ofx = x-px;
					    ofy = y-py;
					    ofz = z-pz;
					    ofaz = rz-roz;
					    finalx = ofx*floatcos(roz, degrees)+ofy*floatsin(roz, degrees);
					    finaly = -ofx*floatsin(roz, degrees)+ofy*floatcos(roz, degrees);
					    
					    AttachDynamicObjectToVehicle( vehicle_trunk_data[vehicleid][slot][temp_object] , vehicleid, finalx, finaly, ofz, rx, ry, ofaz);
						mysql_format(this, insert, sizeof(insert), "UPDATE vehicle_trunk SET offsetX = %f, offsetY = %f, offsetZ = %f, rotX = %f, rotY = %f, rotZ = %f WHERE id = %i",
							finalx, finaly, ofz, rx, ry, ofaz, vehicle_trunk_data[vehicleid][slot][data_id]);
						mysql_tquery(this, insert);
						
						vehicle_trunk_data[vehicleid][slot][wep_offset][0] = finalx;
						vehicle_trunk_data[vehicleid][slot][wep_offset][1] = finaly;
						vehicle_trunk_data[vehicleid][slot][wep_offset][2] = ofz;
						vehicle_trunk_data[vehicleid][slot][wep_offset][3] = rx;
						vehicle_trunk_data[vehicleid][slot][wep_offset][4] = ry;
						vehicle_trunk_data[vehicleid][slot][wep_offset][5] = ofaz;
				    }
					DeletePVar(playerid, "getVehicleID");
					DeletePVar(playerid, "getSlot");
					PlayerInfo[playerid][pEditingObject] = 0;
					SendClientMessage(playerid, COLOR_LIGHTRED, "You can use /takegun to take your weapon from house/trunk.");
					SendClientMessage(playerid, COLOR_LIGHTRED, "NOTE: You must be close to it's physical model.");
					return true;
				}
				if(response == EDIT_RESPONSE_UPDATE)
				{
				    if(getDistance > 1.8)
				    {
				        SendClientMessage(playerid, COLOR_LIGHTRED, "Object is out of bound.");
				    }
				}
			}
			case 4:
			{
			    new listitem = GetPVarInt(playerid, "Meal_ID");
			    
	            MealInfo[listitem][mEditing] = false;

	            if(response == EDIT_RESPONSE_CANCEL)
	            {
	                SetDynamicObjectPos(objectid, MealInfo[listitem][mPosX], MealInfo[listitem][mPosY], MealInfo[listitem][mPosZ]);
	                PlayerInfo[playerid][pEditingObject] = 0;
	                DeletePVar(playerid, "Meal_ID");
	            }
	            else if(response == EDIT_RESPONSE_FINAL)
	            {
	                DestroyDynamicObject(MealInfo[listitem][mObject]);
	                MealInfo[listitem][mObject] = CreateDynamicObject(MealInfo[listitem][mModel], x, y, z, rx, ry, rz);
	                MealInfo[listitem][mPosX] = x;
	                MealInfo[listitem][mPosY] = y;
	                MealInfo[listitem][mPosZ] = z;
	                PlayerInfo[playerid][pEditingObject] = 0;
	                DeletePVar(playerid, "Meal_ID");
	            }
	            else return 1;
			}
			case 5:
			{
				if (PlayerInfo[playerid][pAdmin])
				{
		            if(response == EDIT_RESPONSE_CANCEL)
		            {
						DestroyDynamicObject(PlayerInfo[playerid][pAddObject]);
						PlayerInfo[playerid][pEditingObject] = 0;
						SendClientMessage(playerid, COLOR_LIGHTRED, "Creation Cancelled.");
					}
					else if(response == EDIT_RESPONSE_FINAL)
					{
						DestroyDynamicObject(PlayerInfo[playerid][pAddObject]);
					    new insert[256];
						mysql_format(this, insert, sizeof(insert), "INSERT INTO spray_tag (modelid, offsetX, offsetY, offsetZ, rotX, rotY, rotZ) VALUES(%i, %f, %f, %f, %f, %f, %f)", GetPVarInt(playerid, "spray_model"), x, y, z, rx, ry, rz);
						mysql_tquery(this, insert, "OnSprayTagCreated", "iiffffff", playerid, GetPVarInt(playerid, "spray_model"), x, y, z, rx, ry, rz);
						PlayerInfo[playerid][pEditingObject] = 0;
					}
				}
				else
				{
					DestroyDynamicObject(PlayerInfo[playerid][pAddObject]);
					PlayerInfo[playerid][pEditingObject] = 0;
				}
			}
			case 6:
			{
				if (PlayerInfo[playerid][pAdmin])
				{
		            if(response == EDIT_RESPONSE_CANCEL)
		            {
						DestroyDynamicObject(PlayerInfo[playerid][pAddObject]);
						PlayerInfo[playerid][pEditingObject] = 0;
						SendClientMessage(playerid, COLOR_LIGHTRED, "Creation Cancelled.");
					}
					else if(response == EDIT_RESPONSE_FINAL)
					{
						DestroyDynamicObject(PlayerInfo[playerid][pAddObject]);
					    new insert[256];
						mysql_format(this, insert, sizeof(insert), "INSERT INTO payphone (offsetX, offsetY, offsetZ, rotX, rotY, rotZ) VALUES(%f, %f, %f, %f, %f, %f)", x, y, z, rx, ry, rz);
						mysql_tquery(this, insert, "OnPayPhoneCreated", "iffffff", playerid, x, y, z, rx, ry, rz);
						PlayerInfo[playerid][pEditingObject] = 0;
					}
				}
				else
				{
					DestroyDynamicObject(PlayerInfo[playerid][pAddObject]);
					PlayerInfo[playerid][pEditingObject] = 0;
				}
			}
			case 7:
			{
 				if(response == EDIT_RESPONSE_FINAL || response == EDIT_RESPONSE_CANCEL)
				{
				    print("called1");
					DestroyDynamicObject(PlayerInfo[playerid][pAddObject]);
				    new insert[256];
					mysql_format(this, insert, sizeof(insert), "INSERT INTO chopshop (offsetX, offsetY, offsetZ, rotX, rotY, rotZ) VALUES(%f, %f, %f, %f, %f, %f)", x, y, z, rx, ry, rz);
					mysql_tquery(this, insert, "OnCSCreated", "iffffff", playerid, x, y, z, rx, ry, rz);
					PlayerInfo[playerid][pEditingObject] = 0;
				}
			}
		}
	}
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	if(HasNoEngine(vehicleid))
		ToggleVehicleEngine(vehicleid, true);
		
	Tuning_SetComponents(vehicleid);
	printf("[DEBUG] Vehicle ID %i was respawned.", vehicleid);
	return 1;
}

this::SaveCharacterPos(playerid)
{
	new thread[256]; 
	
	GetPlayerPos(playerid, PlayerInfo[playerid][pLastPos][0], PlayerInfo[playerid][pLastPos][1], PlayerInfo[playerid][pLastPos][2]);
	
	mysql_format(this, thread, sizeof(thread), "UPDATE characters SET pLastPosX = %f, pLastPosY = %f, pLastPosZ = %f, pLastInterior = %i, pLastWorld = %i, pInProperty = %i, pInBusiness = %i WHERE char_dbid = %i",
	
		PlayerInfo[playerid][pLastPos][0],
		PlayerInfo[playerid][pLastPos][1],
		PlayerInfo[playerid][pLastPos][2],
		GetPlayerInterior(playerid),
		GetPlayerVirtualWorld(playerid),
		PlayerInfo[playerid][pInsideProperty],
		PlayerInfo[playerid][pInsideBusiness],
		PlayerInfo[playerid][pDBID]);
		
	return mysql_tquery(this, thread);
}

this::SaveCharacter(playerid)
{
	new query[320];
	
	mysql_format(this, query, sizeof(query), "UPDATE characters SET forum_name = '%e', active_ip = '%e' WHERE char_dbid = %i",
		e_pAccountData[playerid][mForumName],
		PlayerInfo[playerid][pActiveIP],
		e_pAccountData[playerid][mDBID]);
	mysql_tquery(this, query);
	
	mysql_format(this, query, sizeof(query), "UPDATE characters SET pAdmin = %i, pLastSkin = %i, pLevel = %i, pEXP = %i, pMoney = %i, pBank = %i, pPaycheck = %i, pPhone = %i, pLastOnline = '%e', pLastOnlineTime = %i, pAdminjailed = %i, pAdminjailTime = %i WHERE char_dbid = %i",
		PlayerInfo[playerid][pAdmin],
		PlayerInfo[playerid][pLastSkin],
		PlayerInfo[playerid][pLevel],
		PlayerInfo[playerid][pEXP],
		PlayerInfo[playerid][pMoney],
		PlayerInfo[playerid][pBank],
		PlayerInfo[playerid][pPaycheck],
		PlayerInfo[playerid][pPhone],
		ReturnDate(),
		PlayerInfo[playerid][pLastOnlineTime],
		PlayerInfo[playerid][pAdminjailed],
		PlayerInfo[playerid][pAdminjailTime],
		PlayerInfo[playerid][pDBID]);
	mysql_tquery(this, query);
	
	mysql_format(this, query, sizeof(query), "UPDATE characters SET pFaction = %i, pFactionRank = %i, pVehicleSpawned = %i, pVehicleSpawnedID = %i, pTimeplayed = %i, pMaskID = %i, pMaskIDEx = %i, pOfflinejailed = 0 WHERE char_dbid = %i",
		PlayerInfo[playerid][pFaction], 
		PlayerInfo[playerid][pFactionRank], 
		PlayerInfo[playerid][pVehicleSpawned],
		PlayerInfo[playerid][pVehicleSpawnedID],
		PlayerInfo[playerid][pTimeplayed],
		PlayerInfo[playerid][pMaskID][0],
		PlayerInfo[playerid][pMaskID][1],
		PlayerInfo[playerid][pDBID]);
	mysql_tquery(this, query);
	
	mysql_format(this, query, sizeof(query), "UPDATE characters SET pHasRadio = %i, pMainSlot = %i, pGascan = %i, pSpawnPoint = %i, pSpawnPointHouse = %i, pWeaponsLicense = %i, pDriversLicense = %i WHERE char_dbid = %i",
		PlayerInfo[playerid][pHasRadio],
		PlayerInfo[playerid][pMainSlot],
		PlayerInfo[playerid][pGascan],
		PlayerInfo[playerid][pSpawnPoint],
		PlayerInfo[playerid][pSpawnPointHouse],
		PlayerInfo[playerid][pWeaponsLicense],
		PlayerInfo[playerid][pDriversLicense],
		PlayerInfo[playerid][pDBID]);
	mysql_tquery(this, query);
	
	mysql_format(this, query, sizeof(query), "UPDATE characters SET Donator = %i, Walk_style = %i, Chat_style = %i, Hud_style = %i, PhonePower = %i, Job = %i, Career = %i, SideJob = %i, UseHud = %i, SetupInfo = %i, Gender = %i, pAge = %i, RentAt = %i WHERE char_dbid = %i",
		PlayerInfo[playerid][pDonator],
		PlayerInfo[playerid][pWalkstyle],
		PlayerInfo[playerid][pChatstyle],
		PlayerInfo[playerid][pHud],
		PlayerInfo[playerid][pPhonePower],
		PlayerInfo[playerid][pJob],
		PlayerInfo[playerid][pCareer],
		PlayerInfo[playerid][pSideJob],
		PlayerInfo[playerid][pUseHud],
		PlayerInfo[playerid][pSetupInfo],
		PlayerInfo[playerid][pGender],
		PlayerInfo[playerid][pAge],
		PlayerInfo[playerid][pRentAt],
		PlayerInfo[playerid][pDBID]);
	mysql_tquery(this, query);
	
	for(new i = 1; i < 3; i++)
	{
		mysql_format(this, query, sizeof(query), "UPDATE characters SET pRadio%i = %i WHERE char_dbid = %i",
			i, 
			PlayerInfo[playerid][pRadio][i],
			PlayerInfo[playerid][pDBID]);
		mysql_tquery(this, query);
	}
	
	for(new i = 0; i < 4; i++)
	{
		mysql_format(this, query, sizeof(query), "UPDATE characters SET pWeapons%d = %i, pWeaponsAmmo%d = %i WHERE char_dbid = %i",
			i,
			PlayerInfo[playerid][pWeapons][i],
			i,
			PlayerInfo[playerid][pWeaponsAmmo][i],
			PlayerInfo[playerid][pDBID]);
		mysql_tquery(this, query);
	}
	
	for(new i = 1; i < MAX_PLAYER_VEHICLES; i++)
	{
		mysql_format(this, query, sizeof(query), "UPDATE characters SET pOwnedVehicles%d = %i WHERE char_dbid = %i", i, PlayerInfo[playerid][pOwnedVehicles][i], PlayerInfo[playerid][pDBID]);
		mysql_tquery(this, query);
	}
	
	return 1;
}

//General commands:
CMD:help(playerid, params[])
{
	SendClientMessage(playerid, COLOR_DARKGREEN, "______________________________________________");
	
	SendClientMessage(playerid, COLOR_GRAD1, "[ACCOUNT] /stats, /admins, /report, /o(oc) /relog, /pay, /isafk");
	SendClientMessage(playerid, COLOR_GRAD2, "[GENERAL] /time, /rcp, /weapons, /leavegun, /grabgun, /enter, /exit, /mask");
	SendClientMessage(playerid, COLOR_GRAD1, "[GENERAL] /buy, /setchannel, /setslot, /radio, /radiolow, /damages, /acceptdeath,");
	SendClientMessage(playerid, COLOR_GRAD2, "[GENERAL] /respawnme, /setspawn, /levelup, /bank, /withdraw, /balance, /ammuhelp,"); 
	SendClientMessage(playerid, COLOR_GRAD1, "[GENERAL] /license, /licenseexam, /unimpound, /fixr");
	SendClientMessage(playerid, COLOR_GRAD1, "[VEHICLES] /v(ehicle), /engine, /unscramble, /check, /place, /setstation, /refill"); 
	SendClientMessage(playerid, COLOR_GRAD2, "[EMOTES] /me, /do, /ame, /my, /amy, /shout, /low, /b, /pm"); 
	SendClientMessage(playerid, COLOR_GRAD1, "[PHONE] /call, /hangup, /pickup, /sms, /loudspeaker"); 
	SendClientMessage(playerid, COLOR_GRAD2, "[PROPERTY] /buyproperty, /lock, /check, /place, /placepos, /setstation, /property, /setrent, /rentfee");
	SendClientMessage(playerid, COLOR_GRAD1, "[BUSINESS] /buybiz, /bizinfo, /bizfee, /bizcash, /sellbiz"); 
	SendClientMessage(playerid, COLOR_GRAD2, "[FACTION] /factionhelp, /factions, /f, /togfam, /factionon, /accept");
	
	SendClientMessage(playerid, COLOR_DARKGREEN, "______________________________________________");
	return 1; 
}

CMD:stats(playerid, params[])
{
	new playerb;
	
	if(PlayerInfo[playerid][pAdmin])
	{
		if (sscanf(params, "I(-1)", playerb))
			return 1; 
			
		if(playerb == -1)
		{
			return ShowCharacterStats(playerid, playerid);
		}
		else
		{
			if(!IsPlayerConnected(playerb))
				return SendErrorMessage(playerid, "The player you specified isn't connected.");
				
			if(e_pAccountData[playerid][mLoggedin] == false)
				return SendErrorMessage(playerid, "The player you specified isn't logged in."); 
				
			ShowCharacterStats(playerb, playerid); 
		}
	}
	else return ShowCharacterStats(playerid, playerid);
	return 1;
}

CMD:admins(playerid, params[])
{
	new bool:adminOn = false;
	
	foreach (new i : Player)
	{
		if (PlayerInfo[playerid][pAdmin]) adminOn = true;
	}
	
	if(adminOn == true)
	{
		SendClientMessage(playerid, COLOR_GREY, "Admins Online:");
		
		foreach(new i : Player)
		{
			if(PlayerInfo[i][pAdmin])
			{
				if(PlayerInfo[i][pAdminDuty])
				{
					sendMessage(playerid, COLOR_DARKGREEN, "(Level: %d) %s (%s) - On Duty: Yes", PlayerInfo[i][pAdmin], ReturnName(i), e_pAccountData[i][mForumName]);
				}
				else sendMessage(playerid, COLOR_GREY, "(Level: %d) %s (%s) - On Duty: No", PlayerInfo[i][pAdmin], ReturnName(i), e_pAccountData[i][mForumName]);
			}
		}
	}
	else
	{
		return SendClientMessage(playerid, COLOR_GREY, "There are no administrators' online.");
	}

	return 1;
}

CMD:report(playerid, params[])
{
	if(isnull(params) || strlen(params) < 3)
		return SendUsageMessage(playerid, "/re(port) [text]"); 
	
	new 
		showString[350]
	;
	
	format(showString, sizeof(showString), "{FFFFFF}Are you sure you want to send this report?\n\n{F81414}Remember that, reporting actions which do not happen at the moment is extremely difficult for online admins to handle on the spot, since no proof is presented to them.\n{FFFFFF}Report: %s", params);
	ShowPlayerDialog(playerid, DIALOG_REPORT, DIALOG_STYLE_MSGBOX, "Confirmation", showString, "Yes", "No"); 
	
	format(playerReport[playerid], 128, "%s", params);
	return 1;
}
alias:report("re");

CMD:ooc(playerid, params[])
{
	if(isnull(params))
		return SendUsageMessage(playerid, "/ooc [text]"); 
		
	if(!oocEnabled && !PlayerInfo[playerid][pAdmin])
		return SendErrorMessage(playerid, "OOC chat was disabled by an admin."); 
		
	if(PlayerInfo[playerid][pAdmin] && strcmp(e_pAccountData[playerid][mForumName], "Null"))
		SendClientMessageToAllEx(COLOR_SAMP, "[OOC] %s (%s): %s", ReturnName(playerid), e_pAccountData[playerid][mForumName], params); 
		
	else SendClientMessageToAllEx(COLOR_SAMP, "[OOC] %s: %s", ReturnName(playerid), params);
	return 1;
}
alias:ooc("o");


CMD:relog(playerid, params[])
{
	if(gettime() - PlayerInfo[playerid][pLastDamagetime] < 120)
		return SendServerMessage(playerid, "You took damage recently and can't relog yet."); 
		
	if(PlayerInfo[playerid][pRelogging])
		return SendErrorMessage(playerid, "You're in the middle of relogging."); 
		
	new
		str[128],
		Float:x,
		Float:y,
		Float:z
	;
	
	GetPlayerPos(playerid, x, y, z);

	format(str, sizeof(str), "%s initiated a relog.", ReturnName(playerid));
	SendAdminMessage(1, str);
	
	PlayerInfo[playerid][pRelogging] = true; 
	PlayerInfo[playerid][pRelogCount] = 1; 
	
	PlayerInfo[playerid][pRelogTD] = Create3DTextLabel("(( |------ ))\nRELOGGING", COLOR_DARKGREEN, x, y, z, 20.0, GetPlayerVirtualWorld(playerid), 1);
	Attach3DTextLabelToPlayer(PlayerInfo[playerid][pRelogTD], playerid, 0.0, 0.0, 0.1); 
	
	PlayerInfo[playerid][pRelogTimer] = SetTimerEx("OnPlayerRelog", 3000, true, "i", playerid); 
	
	TogglePlayerControllable(playerid, 0); 
	SendServerMessage(playerid, "To circumvent abuse, you will be relogged shortly."); 
	return 1;
}

CMD:pay(playerid, params[])
{
	new playerb, amount, emote[90], str[128]; 

	if(sscanf(params, "uiS('None')[90]", playerb, amount, emote))
		return SendUsageMessage(playerid, "/pay [playerid OR name] [amount] [emote (Optional)]");

	if(!IsPlayerConnected(playerb))
		return SendErrorMessage(playerid, "The player you specified isn't connected.");
		
	if(!PlayerInfo[playerb][pLoggedin])
		return SendErrorMessage(playerid, "The player you specified isn't logged in.");
		
	if(!IsPlayerNearPlayer(playerid, playerb, 5.0))
		return SendErrorMessage(playerid, "You aren't near that player."); 
		
	if(amount > PlayerInfo[playerid][pMoney])
		return SendErrorMessage(playerid, "You don't have that amount of money.");
		
	if(gettime() - playerLastpay[playerid] < 3)
		return SendServerMessage(playerid, "Please wait before paying again.");
		
	PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0); PlayerPlaySound(playerb, 1052, 0.0, 0.0, 0.0);
	playerLastpay[playerid] = gettime(); 
	
	sendMessage(playerid, COLOR_GREY, " You have sent %s, $%s.", ReturnName(playerb, 0), MoneyFormat(amount));
	sendMessage(playerb, COLOR_GREY, " You have received $%s from %s.", MoneyFormat(amount), ReturnName(playerid, 0));
	
	if(!strcmp(emote, "None"))
		SendNearbyMessage(playerid, 20.0, COLOR_EMOTE, "* %s takes out some cash, and hands it to %s.", ReturnName(playerid, 0), ReturnName(playerb, 0)); 

	else SendNearbyMessage(playerid, 20.0, COLOR_EMOTE, "* %s %s %s (( Cash exchange ))", ReturnName(playerid, 0), emote, ReturnName(playerb, 0));
	
	if(PlayerInfo[playerid][pLevel] <= 3 && PlayerInfo[playerb][pLevel] <= 3 || amount >= 50000)
	{
		format(str, sizeof(str), "%s has paid $%s to %s.", ReturnName(playerid), MoneyFormat(amount), ReturnName(playerb)); 
		SendAdminMessage(1, str);
	}
	
	GiveMoney(playerid, -amount); GiveMoney(playerb, amount);
	return 1;
}

CMD:ads(playerid, params[])
{
	return ListAds(playerid);
}

CMD:isafk(playerid, params[])
{
	new 
		playerb;
		
	if(sscanf(params, "u", playerb))
		return SendUsageMessage(playerid, "/isafk [playerid OR name]");
		
	if(!IsPlayerConnected(playerb))
		return SendErrorMessage(playerid, "The player you specified isn't logged in.");
	
	if(GetTickCount() > (PlayerInfo[playerb][pPauseCheck]+2000))
		sendMessage(playerid, COLOR_GREY, "Player %s has been paused for %i seconds!", ReturnName(playerb), PlayerInfo[playerb][pPauseTime]);
		
	else sendMessage(playerid, COLOR_GREY, "Player %s is not paused.", ReturnName(playerb));

	return 1;
}

CMD:id(playerid, params[]) // This command was a hefty test. Can be commented out if need be. 
{
	if(isnull(params))
		return SendUsageMessage(playerid, "/id [playerid OR name]"); 
		
	new
		bool:inputID = false,
		playerb
	;
		
	for(new ix = 0, j = strlen(params); ix < j; ix++)
	{
		if (params[ix] > '9' || params[ix] < '0')
		{
			inputID = false; 
		}
		else inputID = true;
	}
	
	if(inputID)
	{
		playerb = strval(params);
		
		if(!IsPlayerConnected(playerb))
			return SendClientMessage(playerid, COLOR_RED, "Player not found."); 
			
		sendMessage(playerid, COLOR_GREY, "(ID: %i) %s | Level: %i", playerb, ReturnName(playerb), PlayerInfo[playerb][pLevel]);
	}
	else
	{
		new
			bool:matchFound = false,
			bool:fullName = false,
			countMatches = 0,
			matchesFound[6],
			string[128]
		;
		
		for(new cc = 0; cc < 5; cc++) { matchesFound[cc] = INVALID_PLAYER_ID; }
		
		for(new i = 0, j = strlen(params); i < j; i++)
		{
			if (params[i] != '_')
			{
				fullName = false; 
			}
			else
			{
				fullName = true; 
			}
		}
		
		if(fullName)
		{
			foreach(new b : Player)
			{
				if(strfind(ReturnName(b), params, true) != -1)
				{
					sendMessage(playerid, COLOR_GREY, "(ID: %i) %s | Level: %i", b, ReturnName(b), PlayerInfo[b][pLevel]);
				}
				else return SendClientMessage(playerid, COLOR_RED, "Player not found."); 
			}
		}
		else
		{
			for(new a = 0; a < MAX_PLAYERS; a++)
			{
				if(IsPlayerConnected(a))
				{
					if(strfind(ReturnName(a, 0), params, true) != -1)
					{
						matchFound = true;
						countMatches ++; 
					}
				}
			}
		
			if(matchFound)
			{
				for(new f = 0, g = GetPlayerPoolSize(), t = 0; f <= g; f++)
				{		
					if(IsPlayerConnected(f) && strfind(ReturnName(f, 0), params, true) != -1)
					{
						matchesFound[t] = f;
						t++; 
						
						if(t >= 5) break; 
					}
				}
			
				if(countMatches != 0 && countMatches > 1)
				{
					for(new l = 0; l < sizeof(matchesFound); l++)
					{
						if(matchesFound[l] == INVALID_PLAYER_ID)
							continue; 
							
						format(string, sizeof(string), "%s(ID: %i) %s, ", string, matchesFound[l], ReturnName(matchesFound[l])); 
											
						if(l % 3 == 0 && l != 0 || l == 5-1)
						{
							SendClientMessage(playerid, COLOR_GREY, string);
							string[0] = 0;
						}
					}
				}
				else if(countMatches == 1)
				{
					sendMessage(playerid, COLOR_GREY, "(ID: %i) %s | Level: %i", matchesFound[0], ReturnName(matchesFound[0]), PlayerInfo[matchesFound[0]][pLevel]);
				}
			}
			else return SendClientMessage(playerid, COLOR_RED, "Player not found."); 
		}
	}
	return 1; 
}

CMD:mask(playerid, params[])
{
	if(PlayerInfo[playerid][pLevel] < 3 && !PlayerInfo[playerid][pAdmin])
		return SendErrorMessage(playerid, "You aren't level 3 or higher."); 
		
	if(!PlayerInfo[playerid][pHasMask] && !PlayerInfo[playerid][pAdmin])
		return SendErrorMessage(playerid, "You don't have a mask."); 
	
	if(!PlayerInfo[playerid][pMasked])
	{
		foreach(new i : Player)
		{
			if(!PlayerInfo[i][pAdminDuty])
				ShowPlayerNameTagForPlayer(i, playerid, 0);
		}
		TextDrawShowForPlayer(playerid, Masktd);
		PlayerInfo[playerid][pMasked] = true;
		GameTextForPlayer(playerid, "~p~YOUR MASK IS NOW ON", 3000, 5); 
	}
	else
	{
		foreach(new i : Player)
		{
			ShowPlayerNameTagForPlayer(i, playerid, 1);
		}
		TextDrawHideForPlayer(playerid, Masktd);
		PlayerInfo[playerid][pMasked] = false;
		GameTextForPlayer(playerid, "~p~YOUR MASK IS NOW OFF", 3000, 5); 
	}
		
	return 1;
}

CMD:buy(playerid, params[])
{
	new
		id = IsPlayerInBusiness(playerid)
	;
	
	if(!IsPlayerInBusiness(playerid))
		return SendErrorMessage(playerid, "You aren't in a business.");
		
	if(BusinessInfo[id][eBusinessType] != BUSINESS_TYPE_GENERAL)
		return SendErrorMessage(playerid, "You aren't in a store."); 
	
	ShowShopList(playerid, true);
	return 1;
}

CMD:pc(playerid, params[])
{
	if(PlayerInfo[playerid][pUseGUI])
	{
    	SelectTextDraw(playerid, COLOR_GREY);
	}
	else
	{
	    callcmd::phone(playerid, "");
	}
    return 1;
}

CMD:phone(playerid, params[])
{
	if(!PlayerInfo[playerid][pPhonePower]) return SendErrorMessage(playerid, "The phone is powered off.");
	if(!PlayerInfo[playerid][pUseGUI])
	{
    	Phone_ShowUI(playerid);
	}
	else
	{
	    Phone_HideUI(playerid);
	}
	return 1;
}

CMD:eat(playerid, params[])
{
	new 
	    id = IsPlayerInBusiness(playerid)
	;

	if(!IsPlayerInBusiness(playerid))
		return SendErrorMessage(playerid, "You aren't in a business.");

	if(BusinessInfo[id][eBusinessType] != BUSINESS_TYPE_RESTAURANT)
		return SendErrorMessage(playerid, "You aren't in a restaurant.");

    PlayerInfo[playerid][pSelection] = EVENT_FOODMENU;
    ShowFoodMenu(playerid, true);
	return 1;
}

CMD:meal(playerid, params[])
{
	if(PlayerInfo[playerid][pEditingObject]) return
 		SendErrorMessage(playerid, "You are in the editing mode.");

	if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) return
 		SendErrorMessage(playerid, "You must be on foot.");

	if(isnull(params) || strlen(params) > 20)
	{
	    SendUsageMessage(playerid, "/meal [action]");
	    SendClientMessage(playerid, COLOR_LIGHTRED, "throw {FFFFFF}- throw the meal away.");
	    SendClientMessage(playerid, COLOR_LIGHTRED, "pickup {FFFFFF}- pick up a meal.");
	    SendClientMessage(playerid, COLOR_LIGHTRED, "place {FFFFFF}- place a meal onto a surface.");
	    SendClientMessage(playerid, COLOR_LIGHTRED, "order {FFFFFF}- order a meal.");
	    SendClientMessage(playerid, COLOR_LIGHTRED, "config {FFFFFF}- set up your restaurant business.");
	    return true;
	}

	new id = PlayerInfo[playerid][pMeal];

	if(!strcmp(params, "throw", true))
	{
	    if(PlayerInfo[playerid][pMeal] == -1)return
	        SendErrorMessage(playerid, "You don't have any meal in hand.");

		RemovePlayerAttachedObject(playerid, 9);
		callcmd::ame(playerid, "throws his meal away.");
		SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
		Meal_Drop(id);
		PlayerInfo[playerid][pMeal] = -1;
	}
	else if(!strcmp(params, "order", true))
	{
        callcmd::eat(playerid, "");
	}
	else if(!strcmp(params, "config", true))
	{
        ShowBusinessConfig(playerid);
	}
	else if(!strcmp(params, "pickup", true))
	{
	    if(PlayerInfo[playerid][pMeal] != -1) return
	        SendErrorMessage(playerid, "You already have a meal in hand.");

		if(GetNearestMeal(playerid) == -1) return
		    SendErrorMessage(playerid, "There's no meal around you...");

		id = GetNearestMeal(playerid);

		if(MealInfo[id][mEditing] || MealInfo[id][mPlayer] != -1) return
   			SendErrorMessage(playerid, "This meal can not be taken right now.");

  		ApplyAnimation(playerid, "CARRY", "liftup", 4.1, 0, 0, 0, 0, 0, 1);

		PlayerInfo[playerid][pMeal] = id;
        SetPlayerAttachedObject(playerid, SLOT_MEAL, MealInfo[id][mModel], 1, 0.004999, 0.529999, 0.126999, -83.200004, 115.999961, -31.799890, 0.500000, 0.816000, 0.500000);

		callcmd::ame(playerid, "picks up a meal.");

		DestroyDynamicObject(MealInfo[id][mObject]);
		SetPlayerSpecialAction(playerid, SPECIAL_ACTION_CARRY);

		MealInfo[id][mPosX] = 0.0;
		MealInfo[id][mPosY] = 0.0;
		MealInfo[id][mPosZ] = 0.0;
		MealInfo[id][mPlayer] = playerid;
	}
	else if(!strcmp(params, "place", true))
	{
	    if(PlayerInfo[playerid][pMeal] == -1) return
	        SendErrorMessage(playerid, "You don't have a meal in hand.");

	    new Float:playerPosX, Float:playerPosY, Float:playerPosZ;

		GetPlayerPos(playerid, playerPosX, playerPosY, playerPosZ);

	    RemovePlayerAttachedObject(playerid, 9);
	    SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
	    callcmd::ame(playerid, "places his meal.");

	    MealInfo[id][mPlayer] = -1;
	    MealInfo[id][mPosX] = playerPosX;
	    MealInfo[id][mPosY] = playerPosY;
	    MealInfo[id][mPosZ] = playerPosZ;
        MealInfo[id][mWorld] = GetPlayerVirtualWorld(playerid);
        MealInfo[id][mInterior] = GetPlayerInterior(playerid);
		MealInfo[id][mEditing] = true;

	    MealInfo[id][mObject] = CreateDynamicObject(MealInfo[id][mModel], playerPosX, playerPosY, playerPosZ, 0.0, 0.0, 0.0, MealInfo[id][mWorld], MealInfo[id][mInterior]);
	    EditDynamicObject(playerid, MealInfo[id][mObject]);

		PlayerInfo[playerid][pEditingObject] = 4;
		SetPVarInt(playerid, "Meal_ID", PlayerInfo[playerid][pMeal]);
		PlayerInfo[playerid][pMeal] = -1;
	}
	else return callcmd::meal(playerid, "");
	return 1;
}

CMD:setstyle(playerid, params[])
{
	new oneString[30], secString[90];

	if(sscanf(params, "s[30]S()[90]", oneString, secString))
	{
		SendUsageMessage(playerid, "/setstyle [category] [style]");
        SendClientMessage(playerid, COLOR_LIGHTRED, "chatstyle | walkstyle | hud");
		return 1;
	}
	if(!strcmp(oneString, "chatstyle"))
	{
		new
			slotid
		;

		if(sscanf(secString, "d", slotid))
			return SendUsageMessage(playerid, "/setstyle [chatstyle] [1-8]");

		if(!(1 <= slotid <= 8))
			return SendUsageMessage(playerid, "/setstyle [chatstyle] [1-8]");

	    if (PlayerInfo[playerid][pDonator] == REGULAR_PLAYER)
	    	return SendErrorMessage(playerid, "You don't have permission.");

		PlayerInfo[playerid][pChatstyle] = slotid;
  		SendClientMessage(playerid, COLOR_LIGHTRED, "You have changed your chat style.");
	}
	else if(!strcmp(oneString, "walkstyle"))
	{
		new
			slotid
		;

		if(sscanf(secString, "d", slotid))
		{
		    SendUsageMessage(playerid, "/setstyle [walkstyle] [1-16]");
    		SendClientMessage(playerid, -1, "Random: 7, 8.");
    		SendClientMessage(playerid, -1, "Normal: 1, 2, 6, 9, 11.");
    		SendClientMessage(playerid, -1, "Old/Fat: 3, 4, 5, 10.");
    		SendClientMessage(playerid, -1, "Woman: 12, 13, 14, 15, 16.");
			return 1;
		}

		if(!(1 <= slotid <= 16))
		{
		    SendUsageMessage(playerid, "/setstyle [walkstyle] [1-16]");
    		SendClientMessage(playerid, -1, "Random: 7, 8.");
    		SendClientMessage(playerid, -1, "Normal: 1, 2, 6, 9, 11.");
    		SendClientMessage(playerid, -1, "Old/Fat: 3, 4, 5, 10.");
    		SendClientMessage(playerid, -1, "Woman: 12, 13, 14, 15, 16.");
			return 1;
		}

	    if (PlayerInfo[playerid][pDonator] == REGULAR_PLAYER)
	    	return SendErrorMessage(playerid, "You don't have permission.");

		PlayerInfo[playerid][pWalkstyle] = slotid;
  		SendClientMessage(playerid, COLOR_LIGHTRED, "You have changed your walk style.");
	}
	if(!strcmp(oneString, "hud"))
	{
		new
			slotid
		;

		if(sscanf(secString, "d", slotid))
			return SendUsageMessage(playerid, "/setstyle [chatstyle] [1-3]");

		if(!(1 <= slotid <= 3))
			return SendUsageMessage(playerid, "/setstyle [chatstyle] [1-3]");

	    if (PlayerInfo[playerid][pDonator] == REGULAR_PLAYER)
	    	return SendErrorMessage(playerid, "You don't have permission.");

    	PlayerInfo[playerid][pHud] = slotid;
  		SendClientMessage(playerid, COLOR_LIGHTRED, "You have changed your hud style.");
  		SendClientMessage(playerid, COLOR_YELLOWEX, "Use /toghud to toggle it back on.");
	}
	return 1;
}

CMD:toghud(playerid, params[])
{
	if(PlayerInfo[playerid][pUseHud])
	{
	    for(new i = 0; i < 9; i ++) PlayerTextDrawHide(playerid, Player_Hud[playerid][i]);
	    SendClientMessage(playerid, COLOR_YELLOWEX, "You have turned off the hud.");
	    PlayerInfo[playerid][pUseHud] = false;
	}
	else
	{
	    PlayerInfo[playerid][pUseHud] = true;
	    CallLocalFunction("OnPlayerChangeHud", "i", playerid);
	    SendClientMessage(playerid, COLOR_YELLOWEX, "You have turned on the hud.");
	}
	return 1;
}

CMD:walk(playerid, params[])
{
	if (!IsAnimationPermitted(playerid))
	{
	    return SendClientMessage(playerid, COLOR_LIGHTRED, "You cannot use this command right now.");
	}
	switch (PlayerInfo[playerid][pWalkstyle])
	{
	    case 1: PlayAnimation(playerid, "PED", "WALK_civi", 4.1, 1, 1, 1, 1, 1, 1);
	    case 2: PlayAnimation(playerid, "PED", "WALK_armed", 4.1, 1, 1, 1, 1, 1, 1);
	    case 3: PlayAnimation(playerid, "PED", "WALK_fat", 4.1, 1, 1, 1, 1, 1, 1);
	    case 4: PlayAnimation(playerid, "PED", "WALK_fatold", 4.1, 1, 1, 1, 1, 1, 1);
	    case 5: PlayAnimation(playerid, "FAT", "FatWalk", 4.1, 1, 1, 1, 1, 1, 1);
	    case 6: PlayAnimation(playerid, "MUSCULAR", "MuscleWalk", 4.1, 1, 1, 1, 1, 1, 1);
	    case 7: PlayAnimation(playerid, "PED", "WALK_gang1", 4.1, 1, 1, 1, 1, 1, 1);
	    case 8: PlayAnimation(playerid, "PED", "WALK_gang2", 4.1, 1, 1, 1, 1, 1, 1);
	    case 9: PlayAnimation(playerid, "PED", "WALK_player", 4.1, 1, 1, 1, 1, 1, 1);
	    case 10: PlayAnimation(playerid, "PED", "WALK_old", 4.1, 1, 1, 1, 1, 1, 1);
	    case 11: PlayAnimation(playerid, "PED", "WALK_wuzi", 4.1, 1, 1, 1, 1, 1, 1);
	    case 12: PlayAnimation(playerid, "PED", "WOMAN_walkbusy", 4.1, 1, 1, 1, 1, 1, 1);
	    case 13: PlayAnimation(playerid, "PED", "WOMAN_walkfatold", 4.1, 1, 1, 1, 1, 1, 1);
	    case 14: PlayAnimation(playerid, "PED", "WOMAN_walknorm", 4.1, 1, 1, 1, 1, 1, 1);
	    case 15: PlayAnimation(playerid, "PED", "WOMAN_walksexy", 4.1, 1, 1, 1, 1, 1, 1);
	    case 16: PlayAnimation(playerid, "PED", "WOMAN_walkshop", 4.1, 1, 1, 1, 1, 1, 1);
	    default: PlayAnimation(playerid, "PED", "WALK_civi", 4.1, 1, 1, 1, 1, 1, 1);
	}
	return 1;
}

CMD:setchannel(playerid, params[])
{
	new 
		slot, 
		channel
	;
	
	if(sscanf(params, "ii", channel, slot))
		return SendUsageMessage(playerid, "/setchannel [channel] [slot]"); 
		
	if(!PlayerInfo[playerid][pHasRadio])
		return SendErrorMessage(playerid, "You don't have a radio."); 
		
	if(slot > 2 || slot < 1)
		return SendErrorMessage(playerid, "You specified an invalid slot. (1-2)");
		
	if(channel < 1 || channel > 1000000)
		return SendErrorMessage(playerid, "You specified an invalid channel. (1-1000000)"); 
		
	for(new i = 1; i < 3; i++)
	{
		if(PlayerInfo[i][pRadio][i] == channel)
		{
			SendErrorMessage(playerid, "Your radio slot %i already supports channel %i.", i, channel);
			return 1;
		}
	}
	
	if(channel == 911)
	{
		if(FactionInfo[PlayerInfo[playerid][pFaction]][eFactionType] != FACTION_TYPE_POLICE)
			return SendClientMessage(playerid, COLOR_RED, "ACCESS DENIED:{FFFFFF} You're not authorized to use this channel."); 
	}
	
	PlayerInfo[playerid][pRadio][slot] = channel;
	
	sendMessage(playerid, COLOR_YELLOWEX, "You're now listening to channel %i under slot %i.", channel, slot);
	SaveCharacter(playerid); 
	return 1;
}

CMD:setslot(playerid, params[])
{
	new
		slot
	;
	
	if(sscanf(params, "i", slot))
		return SendUsageMessage(playerid, "/setslot [slot id]");
		
	if(!PlayerInfo[playerid][pHasRadio])
		return SendUsageMessage(playerid, "You don't own a radio.");
		
	if(slot > 2 || slot < 1)
		return SendErrorMessage(playerid, "You specified an invalid slot. (1-2)");
		
	PlayerInfo[playerid][pMainSlot] = slot;
		
	sendMessage(playerid, COLOR_YELLOWEX, "Local channel on the radio set to %i.", slot);
	SaveCharacter(playerid);
	return 1;
}

CMD:radio(playerid, params[])
{
	if(!PlayerInfo[playerid][pHasRadio])
		return SendUsageMessage(playerid, "You don't own a radio.");

	new
		local,
		channel
	;
		
	local = PlayerInfo[playerid][pMainSlot]; 
	channel = PlayerInfo[playerid][pRadio][local]; 
	
	if(!PlayerInfo[playerid][pRadio][local])
		return SendErrorMessage(playerid, "Your local radio slot isn't set to a channel."); 
		
	if(isnull(params))
		return SendUsageMessage(playerid, "/r [text], /rlow [text]");
		
	foreach(new i : Player)
	{
		for(new r = 1; r < 3; r ++)
		{
			if(PlayerInfo[i][pRadio][r] == channel)
			{
				if(r != PlayerInfo[i][pMainSlot])
					sendMessage(i, COLOR_RADIOEX, "**[CH: %d, S: %d] %s says: %s", PlayerInfo[i][pRadio][r], GetChannelSlot(i, channel), ReturnName(playerid, 0), params);
					
				else sendMessage(i, COLOR_RADIO, "**[CH: %d, S: %d] %s says: %s", PlayerInfo[i][pRadio][r], GetChannelSlot(i, channel), ReturnName(playerid, 0), params);
			}
		}
	}
	
	new Float:posx, Float:posy, Float:posz;
	GetPlayerPos(playerid, posx,posy,posz);

	foreach(new i : Player)
	{
	   	if(i == playerid)
	       continue;

		else if(IsPlayerInRangeOfPoint(i, 20.0, posx,posy,posz))
		{
			sendMessage(playerid, COLOR_GRAD1, "(Radio) %s says: %s", ReturnName(playerid, 0), params);
		}
	}
	return 1;
}
alias:radio("r");

CMD:rlow(playerid, params[])
{
	if(!PlayerInfo[playerid][pHasRadio])
		return SendUsageMessage(playerid, "You don't own a radio.");

	new
		local,
		channel
	;
		
	local = PlayerInfo[playerid][pMainSlot]; 
	channel = PlayerInfo[playerid][pRadio][local]; 
	
	if(!PlayerInfo[playerid][pRadio][local])
		return SendErrorMessage(playerid, "Your local radio slot isn't set to a channel."); 
		
	if(isnull(params))
		return SendUsageMessage(playerid, "/rlow [text]");
		
	foreach(new i : Player)
	{
		for(new r = 1; r < 3; r ++)
		{
			if(PlayerInfo[i][pRadio][r] == channel)
			{
				if(r != PlayerInfo[i][pMainSlot])
					sendMessage(i, COLOR_RADIOEX, "**[CH: %d, S: %d] %s says: %s", PlayerInfo[i][pRadio][r], GetChannelSlot(i, channel), ReturnName(playerid, 0), params);
					
				else sendMessage(i, COLOR_RADIO, "**[CH: %d, S: %d] %s says: %s", PlayerInfo[i][pRadio][r], GetChannelSlot(i, channel), ReturnName(playerid, 0), params);
			}
		}
	}
	
	new Float:posx, Float:posy, Float:posz;
	GetPlayerPos(playerid, posx,posy,posz);

	foreach(new i : Player)
	{
	   	if(i == playerid)
	       continue;

		else if(IsPlayerInRangeOfPoint(i, 5.0, posx,posy,posz))
		{
			sendMessage(playerid, COLOR_GRAD1, "(Radio) %s says[low]: %s", ReturnName(playerid, 0), params);
		}
	}
	return 1;
}

/*CMD:r2(playerid, params[])
{
	if(!PlayerInfo[playerid][pHasRadio])
		return SendUsageMessage(playerid, "You don't own a radio.");

	new
		channel
	;
		
	channel = PlayerInfo[playerid][pRadio][2]; 
	
	if(!PlayerInfo[playerid][pRadio][2])
		return SendErrorMessage(playerid, "Your local radio slot isn't set to a channel."); 
		
	if(isnull(params))
		return SendUsageMessage(playerid, "/r2 [text]");
		
	foreach(new i : Player)
	{
		for(new r = 1; r < 3; r ++)
		{
			if(PlayerInfo[i][pRadio][r] == channel)
			{
				if(r != PlayerInfo[i][pMainSlot])
					sendMessage(i, COLOR_RADIOEX, "**[CH: %d, S: %d] %s says: %s", PlayerInfo[i][pRadio][r], GetChannelSlot(i, channel), ReturnName(playerid, 0), params);
					
				else sendMessage(i, COLOR_RADIO, "**[CH: %d, S: %d] %s says: %s", PlayerInfo[i][pRadio][r], GetChannelSlot(i, channel), ReturnName(playerid, 0), params);
			}
		}
	}
	
	new Float:posx, Float:posy, Float:posz;
	GetPlayerPos(playerid, posx,posy,posz);

	foreach(new i : Player)
	{
	   	if(i == playerid)
	       continue;

		else if(IsPlayerInRangeOfPoint(i, 20.0, posx,posy,posz))
		{
			sendMessage(playerid, COLOR_GRAD1, "(Radio) %s says: %s", ReturnName(playerid, 0), params);
		}
	}
	return 1;
}

CMD:r2low(playerid, params[])
{
	if(!PlayerInfo[playerid][pHasRadio])
		return SendUsageMessage(playerid, "You don't own a radio.");

	new
		channel
	;
		
	channel = PlayerInfo[playerid][pRadio][2]; 
	
	if(!PlayerInfo[playerid][pRadio][2])
		return SendErrorMessage(playerid, "Your local radio slot isn't set to a channel."); 
		
	if(isnull(params))
		return SendUsageMessage(playerid, "/r2low [text]");
		
	foreach(new i : Player)
	{
		for(new r = 1; r < 3; r ++)
		{
			if(PlayerInfo[i][pRadio][r] == channel)
			{
				if(r != PlayerInfo[i][pMainSlot])
					sendMessage(i, COLOR_RADIOEX, "**[CH: %d, S: %d] %s says: %s", PlayerInfo[i][pRadio][r], GetChannelSlot(i, channel), ReturnName(playerid, 0), params);
					
				else sendMessage(i, COLOR_RADIO, "**[CH: %d, S: %d] %s says: %s", PlayerInfo[i][pRadio][r], GetChannelSlot(i, channel), ReturnName(playerid, 0), params);
			}
		}
	}
	
	new Float:posx, Float:posy, Float:posz;
	GetPlayerPos(playerid, posx,posy,posz);

	foreach(new i : Player)
	{
	   	if(i == playerid)
	       continue;

		else if(IsPlayerInRangeOfPoint(i, 6.0, posx,posy,posz))
		{
			sendMessage(playerid, COLOR_GRAD1, "(Radio) %s says[low]: %s", ReturnName(playerid, 0), params);
		}
	}
	return 1;
}*/

CMD:refill(playerid, params[])
{
	if(!PlayerInfo[playerid][pGascan])
		return SendErrorMessage(playerid, "You don't have any gascans."); 
		
	if(IsPlayerInAnyVehicle(playerid))
		return SendErrorMessage(playerid, "You can't be in a vehicle.");
		
	if(GetNearestVehicle(playerid) == INVALID_VEHICLE_ID)
		return SendErrorMessage(playerid, "You aren't near a vehicle."); 
		
	if(playerRefillingVehicle[playerid])
		return SendErrorMessage(playerid, "You're already refilling a vehicle."); 
		
	new 
		vehicleid = GetNearestVehicle(playerid),
		Float:x,
		Float:y,
		Float:z,
		Float:vx,
		Float:vy,
		Float:vz
	;
	
	GetVehicleModelInfo(GetVehicleModel(vehicleid), VEHICLE_MODEL_INFO_PETROLCAP, x, y, z); 
	GetVehiclePos(vehicleid, vx, vy, vz); 
	
	GetPlayerPos(playerid, PlayerInfo[playerid][pLastPos][0], PlayerInfo[playerid][pLastPos][1], PlayerInfo[playerid][pLastPos][2]); 
			
	if(!IsPlayerInRangeOfPoint(playerid, 5.0, x, y, z))
		return SendErrorMessage(playerid, "You aren't near the vehicles gas cap.");
		
	if(VehicleInfo[vehicleid][eVehicleFuel] > 50.0)
		return SendErrorMessage(playerid, "This vehicle doesn't need fuel."); 
		
	SendClientMessage(playerid, COLOR_ACTION, "You're starting to refill the vehicle.");
	SendClientMessage(playerid, COLOR_ACTION, "If you, or the vehicle moves then this process will be interrupted."); 
	
	VehicleInfo[vehicleid][eVehicleRefillDisplay] = Create3DTextLabel("(( |------ ))\nREFILLING VEHICLE", COLOR_DARKGREEN, x, y, z, 25.0, 0, 1);
	Attach3DTextLabelToVehicle(VehicleInfo[vehicleid][eVehicleRefillDisplay], vehicleid, -0.0, -0.0, -0.0); 

	PlayerInfo[playerid][pGascan]--; 
	VehicleInfo[vehicleid][eVehicleRefillCount] = 1;
	
	playerRefillingVehicle[playerid] = true; 
	playerRefillTimer[playerid] = SetTimerEx("OnGascanRefill", 4500, true, "iifff", playerid, vehicleid, vx, vy, vz);
	return 1;
}

CMD:damages(playerid, params[])
{
	new playerb;
	
	if(sscanf(params, "u", playerb))
		return SendUsageMessage(playerid, "/damages [playerid OR name]");
		
	if(!IsPlayerConnected(playerb))	
		return SendErrorMessage(playerid, "The player you specified isn't connected.");
		
	if(!PlayerInfo[playerb][pLoggedin])
		return SendErrorMessage(playerid, "The player you specified isn't logged in.");
		
	if(PlayerInfo[playerid][pAdminDuty])
	{
		ShowPlayerDamages(playerb, playerid, 1); 
	}
	else
	{
		if(!IsPlayerNearPlayer(playerid, playerb, 5.0))
			return SendErrorMessage(playerid, "You aren't near that player.");
		
		if(GetPlayerTeam(playerb) == PLAYER_STATE_ALIVE)
			return SendErrorMessage(playerid, "That player isn't brutally wounded.");
			
		ShowPlayerDamages(playerb, playerid, 0); 
	}
	return 1;
}
 
CMD:acceptdeath(playerid, params[])
{
	if(GetPlayerTeam(playerid) != PLAYER_STATE_WOUNDED)
		return SendErrorMessage(playerid, "You aren't brutally wounded.");
		
	CallLocalFunction("OnPlayerDead", "iii", playerid, INVALID_PLAYER_ID, -1, 0);
	return 1;
}

CMD:respawnme(playerid, params[])
{
	if(GetPlayerTeam(playerid) != PLAYER_STATE_DEAD)
		return SendErrorMessage(playerid, "You aren't dead right now.");
		
	if(gettime() - PlayerInfo[playerid][pRespawnTime] < 60)
		return sendMessage(playerid, COLOR_YELLOWEX, "-> You've only been dead for %i seconds. You need to wait at least 60 sec to respawn.", gettime() - PlayerInfo[playerid][pRespawnTime]);

	PlayerInfo[playerid][pRespawnTime] = 0;
	SetPlayerChatBubble(playerid, "Respawned", COLOR_WHITE, 20.0, 1500);
	
	TogglePlayerControllable(playerid, 1); 
	SetPlayerHealth(playerid, 0); 
	
	SetPVarInt(playerid, "BrokenLeg", 0);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_PISTOL, 899);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_MICRO_UZI, 0);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_SPAS12_SHOTGUN, 0);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_AK47, 999);
    SetPlayerSkillLevel(playerid, WEAPONSKILL_DESERT_EAGLE, 999);
    SetPlayerSkillLevel(playerid, WEAPONSKILL_SHOTGUN, 999);
    SetPlayerSkillLevel(playerid, WEAPONSKILL_M4, 999);
    SetPlayerSkillLevel(playerid, WEAPONSKILL_MP5, 999);
	return 1;
}

CMD:setspawn(playerid, params[])
{
	new 
		id;

	if(sscanf(params, "i", id))
	{
		SendUsageMessage(playerid, "/setspawn [spawn id]");
		SendClientMessage(playerid, COLOR_WHITE, "1. Airport, 2. Property, 3. Faction");
		return 1;
	}
	
	if(id > 3 || id < 1)
		return SendErrorMessage(playerid, "You specified an invalid ID."); 
		
	switch(id)
	{
		case 1:
		{
			if(PlayerInfo[playerid][pSpawnPoint] == 0)
				return SendErrorMessage(playerid, "This is already your spawn point."); 
				
			PlayerInfo[playerid][pSpawnPoint] = 0; 
			SendServerMessage(playerid, "You will now spawn at the airport."); 
		}
		case 2:
		{		
			if(!CountPlayerProperties(playerid))
				return SendErrorMessage(playerid, "You don't own any properties."); 
				
			new
				str[128]
			; 
			
			for(new i = 1, j = 0; i < MAX_PROPERTY; i++)
			{
				if(PropertyInfo[i][ePropertyOwnerDBID] != PlayerInfo[playerid][pDBID])
					continue;
					
				playerHouseSelect[playerid][j] = i; 
				j++;
				
				if(j >= 3)
					break; 
			}
			 
			for(new c = 0; c < 3; c++)
			{
				if(playerHouseSelect[playerid][c])
				{
					format(str, sizeof(str), "%sHouse %i\n", str, c); 
				}
			}
			
			ShowPlayerDialog(playerid, DIALOG_SELECT_HOUSE, DIALOG_STYLE_LIST, "Select A Property:", str, "Select", "<<"); 
		}
		case 3:
		{
			if(PlayerInfo[playerid][pSpawnPoint] == 2)
				return SendErrorMessage(playerid, "This is already your spawn point.");
		
			if(!PlayerInfo[playerid][pFaction])
				return SendErrorMessage(playerid, "You aren't in any faction.");
				
			PlayerInfo[playerid][pSpawnPoint] = 2;
			SendServerMessage(playerid, "You will now spawn at your faction."); 
		}
	}

	return 1;
}

CMD:levelup(playerid, params[])
{
	new
		exp_count,
		str[128]
	;
	
	exp_count = ((PlayerInfo[playerid][pLevel]) * 4 + 2);
	
	if(PlayerInfo[playerid][pEXP] < exp_count)
	{
		SendServerMessage(playerid, "You don't have enough EXP (%i) to level up.", exp_count); 
		return 1; 
	}
	
	PlayerInfo[playerid][pLevel]++; 
	PlayerInfo[playerid][pEXP] = 0; 
	
	PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
	SetPlayerScore(playerid, PlayerInfo[playerid][pLevel]); 
	
	format(str, sizeof(str), "~g~Leveled Up~n~~w~You leveled up to level %i", PlayerInfo[playerid][pLevel]);
	GameTextForPlayer(playerid, str, 5000, 1);

	SaveCharacter(playerid); 
	return 1;
}

CMD:bank(playerid, params[])
{
	new
		id = IsPlayerInBusiness(playerid),
		amount
	;
		
	if(!id)
		return SendErrorMessage(playerid, "You aren't in a business.");
		
	if(BusinessInfo[id][eBusinessType] != BUSINESS_TYPE_BANK)
		return SendErrorMessage(playerid, "You aren't inside a bank."); 
		
	if(sscanf(params, "d", amount))
		return SendUsageMessage(playerid, "/bank [deposit amount]");
		
	if(amount < 1 || amount > PlayerInfo[playerid][pMoney])
		return SendErrorMessage(playerid, "You can't deposit that amount."); 
		
	PlayerInfo[playerid][pBank]+= amount;
	GiveMoney(playerid, -amount); 
	
	sendMessage(playerid, COLOR_ACTION, "You have deposited $%s into your account, Total:$%s", MoneyFormat(amount), MoneyFormat(PlayerInfo[playerid][pBank]));
	SaveCharacter(playerid);
	return 1; 
}

CMD:withdraw(playerid, params[])
{
	new
		id = IsPlayerInBusiness(playerid),
		amount
	;
		
	if(!id)
		return SendErrorMessage(playerid, "You aren't in a business.");
		
	if(BusinessInfo[id][eBusinessType] != BUSINESS_TYPE_BANK && BusinessInfo[id][eBusinessType] != BUSINESS_TYPE_GENERAL)
		return SendErrorMessage(playerid, "You can't do this inside this business."); 
		
	if(sscanf(params, "i", amount))
		return SendUsageMessage(playerid, "/withdraw [amount]");
		
	if(amount < 1 || amount > PlayerInfo[playerid][pBank])
		return SendErrorMessage(playerid, "You can't withdraw that amount."); 
		
	PlayerInfo[playerid][pBank]-= amount;
	GiveMoney(playerid, amount);
	
	sendMessage(playerid, COLOR_ACTION, "You have withdrawn $%s from your account, Total:$%s", MoneyFormat(amount), MoneyFormat(PlayerInfo[playerid][pBank]));
	SaveCharacter(playerid);
	return 1;
}

CMD:balance(playerid, params[])
{
	new
		id = IsPlayerInBusiness(playerid)
	;
		
	if(!id)
		return SendErrorMessage(playerid, "You aren't in a business.");
		
	if(BusinessInfo[id][eBusinessType] != BUSINESS_TYPE_BANK && BusinessInfo[id][eBusinessType] != BUSINESS_TYPE_GENERAL)
		return SendErrorMessage(playerid, "You can't do this inside this business."); 
	
	sendMessage(playerid, COLOR_ACTION, "You have $%s in your bank and $%s in your paycheck. (%s)", MoneyFormat(PlayerInfo[playerid][pBank]), MoneyFormat(PlayerInfo[playerid][pPaycheck]), ReturnDate());
	return 1;
}

alias:hangup("h");
CMD:hangup(playerid, params[])
{
    if(!PlayerInfo[playerid][pPhonePower]) return SendErrorMessage(playerid, "The phone is powered off.");
    if (!PlayerInfo[playerid][pCalling])
	{
	    return 1;
	}
	else if(PlayerInfo[playerid][pPhoneline] == 999 || PlayerInfo[playerid][pPhoneline] == 991 || PlayerInfo[playerid][pPhoneline] == 911 || PlayerInfo[playerid][pPhoneline] == 444 || PlayerInfo[playerid][pPhoneline] == 445)
	{
		SendClientMessage(playerid, COLOR_GREY, "[ ! ] You hung up.");
		Phone_HideUI(playerid);
        Phone_ShowUI(playerid);
        
		PlayerInfo[playerid][pPhoneline] = INVALID_PLAYER_ID;
		PlayerInfo[playerid][pCalling] = 0;
		CancelSelectTextDraw(playerid);
        ResetPayphone(playerid);
		if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_USECELLPHONE)
		{
			SetPlayerSpecialAction(playerid, SPECIAL_ACTION_STOPUSECELLPHONE);
		}
		return 1;
	}
	else
	{
	    HangupCall(playerid);
	    SendClientMessage(playerid, COLOR_GREY, "[ ! ] You hung up.");
	}
	return 1;
}

alias:pickup("p");
CMD:pickup(playerid, params[])
{
	if (!IsCallIncoming(playerid) && !IsPlayerNearRingingPayphone(playerid))
 	{
	    return SendErrorMessage(playerid, "There are no incoming calls to answer.");
	}
	else
	{
	    new payphone = GetClosestPayphone(playerid);

	    if (IsValidPayphoneID(payphone) && payphone_data[payphone][payphone_caller] != INVALID_PLAYER_ID)
		{
	    	PlayerInfo[playerid][pCalling] = 2;
	    	PlayerInfo[playerid][pPhoneline] = payphone_data[payphone][payphone_caller];

	    	PlayerInfo[ payphone_data[payphone][payphone_caller] ][pCalling] = 2;
	    	PlayerInfo[ payphone_data[payphone][payphone_caller] ][pPhoneline] = playerid;

            PlayerPlaySound(payphone_data[payphone][payphone_caller], 20601, 0.0, 0.0, 0.0);
			AssignPayphone(playerid, payphone);

			SendClientMessage(PlayerInfo[playerid][pPhoneline], COLOR_GREY, "[ ! ] They picked up. You can talk now by using the chat box.");
			SendClientMessage(playerid, COLOR_WHITE, "HINT: You can talk now by using the chatbox.");
		}
		else
		{
		    PlayerInfo[playerid][pCalling] = 2;
	    	PlayerInfo[PlayerInfo[playerid][pPhoneline]][pCalling] = 2;
	    	
			SendClientMessage(PlayerInfo[playerid][pPhoneline], COLOR_GREY, "[ ! ] They picked up. You can talk now by using the chat box.");
			SendClientMessage(playerid, COLOR_WHITE, "HINT: You can talk now by using the chatbox.");
	    }
		SetPlayerCellphoneAction(playerid, true);
		PlayerPlaySound(playerid, 20601, 0.0, 0.0, 0.0);
	}
	return 1;
}

CMD:call(playerid, params[])
{
	new number[32];

	if(!PlayerInfo[playerid][pPhonePower]) return SendErrorMessage(playerid, "The phone is powered off.");
	else if (PlayerInfo[playerid][pPhoneOff])
    {
        return SendErrorMessage(playerid, "Your phone is turned off. Use /phone to turn it on.");
	}
	else if (sscanf(params, "s[32]", number))
	{
		SendUsageMessage(playerid, "/call [number]");
	}
	else if (strval(number) < 1)
	{
	    return SendErrorMessage(playerid, "You have entered an invalid phone number.");
	}
	else
	{
		CallNumber(playerid, strval(number), 0);
	}
	return 1;
}

CMD:sms(playerid, params[])
{
	new
		text[128],
		str[128],
		phone_number,
		playerb = INVALID_PLAYER_ID
	;
	
	if(PlayerInfo[playerid][pPhoneOff])
		return SendErrorMessage(playerid, "Your cellphone is turned off.");
		
	if(!PlayerInfo[playerid][pPhonePower]) return SendErrorMessage(playerid, "The phone is powered off.");
	
	if(PlayerInfo[playerid][pHandcuffed])
		return SendErrorMessage(playerid, "You can't use your phone right now."); 
		
	if(playerText[playerid])
		return SendClientMessage(playerid, COLOR_WHITE, "Please Wait."); 
		
	if(sscanf(params, "is[128]", phone_number, text))
		return SendUsageMessage(playerid, "/sms [phone number] [text]"); 
		
	foreach(new i : Player) if(PlayerInfo[i][pPhone] == phone_number)
	{
		playerb = i;
	}

	if(GetNearestAntenna(playerid) == -1)
	{
	    SendClientMessage(playerid, COLOR_LIGHTRED, "No signal.");
	    return 1;
	}
	
	format(str, sizeof(str), "* %s takes out their cellphone.", ReturnName(playerid, 0));
	SetPlayerChatBubble(playerid, str, COLOR_EMOTE, 20.0, 3000); 
	
 	Phone_HideUI(playerid);
 	Phone_ShowUI(playerid);
 	
	PlayerTextDrawSetString(playerid, PhoneTime[playerid], "Sending");
	format(str, sizeof(str), "(%d)", phone_number);
	PlayerTextDrawSetString(playerid, PhoneDate[playerid], str);
	PlayerTextDrawHide(playerid, PhoneBtnMenu[playerid]);
	
	if(playerb == INVALID_PLAYER_ID)
	{
		playerText[playerid] = SetTimerEx("OnPhoneSMS", 3000, false, "ii", playerid, 1); 
		return 1;
	}
	
	if(PlayerInfo[playerb][pPhoneOff])
	{
		playerText[playerid] = SetTimerEx("OnPhoneSMS", 3000, false, "ii", playerid, 2);
		return 1;
	}
		
	playerText[playerid] = SetTimerEx("OnPhoneSMS", 1500, false, "iiis", playerid, 3, playerb, text); 
	return 1;
}

CMD:loudspeaker(playerid, params[])
{
	if(PlayerInfo[playerid][pPhoneOff])
		return SendErrorMessage(playerid, "Your cellphone is turned off.");
		
	if(PlayerInfo[playerid][pHandcuffed])
		return SendErrorMessage(playerid, "You can't use your phone right now."); 
		
	if(PlayerInfo[playerid][pPhonespeaker])
	{
		SendNearbyMessage(playerid, 20.0, COLOR_EMOTE, "* %s turns their phones loudspeaker off.", ReturnName(playerid, 0));
		PlayerInfo[playerid][pPhonespeaker] = false;
	}
	else
	{
		SendNearbyMessage(playerid, 20.0, COLOR_EMOTE, "* %s turns their phones loudspeaker on.", ReturnName(playerid, 0));
		PlayerInfo[playerid][pPhonespeaker] = true;
	}
	
	return 1; 
}

CMD:ammuhelp(playerid, params[])
{
	SendClientMessage(playerid, COLOR_DARKGREEN, "______________** AMMUNATION HELP **______________");
	SendClientMessage(playerid, COLOR_WHITE, "/buygun, /buyammo"); 
	return 1;
}

CMD:buygun(playerid, params[])
{
	new id = IsPlayerInBusiness(playerid), a_str[60], b_str[60];
	new totalPrice, ammo, str[128];
	
	if(!IsPlayerInBusiness(playerid))	
		return SendErrorMessage(playerid, "You aren't in a business."); 
		
	if(BusinessInfo[id][eBusinessType] != BUSINESS_TYPE_AMMUNATION)
		return SendErrorMessage(playerid, "You aren't in an ammunation."); 
		
	if(!PlayerInfo[playerid][pWeaponsLicense])
		return SendUnauthMessage(playerid); 
		
	if(sscanf(params, "s[60]S()[60]", a_str, b_str))
	{
		SendUsageMessage(playerid, "/buygun [weapon] [ammo]"); 
		SendClientMessage(playerid, COLOR_GRAD2, "[ colt: $12,500; ammo: $25 ] [ deagle: $17,500; ammo: $38 ] [ shotgun: $17,500; ammo: $38 ]");
		SendClientMessage(playerid, COLOR_GRAD2, "[ rifle: $25,000; ammo: $100 ] [ parachute: $1,250; ammo: $1,250 ] [ armor: $2,000; ammo: $2,000 ]");
		return 1;
	}
	
	if(!strcmp(a_str, "colt"))
	{
		if(sscanf(b_str, "i", ammo))
			return SendUsageMessage(playerid, "/buygun colt [ammo]"); 
			
		if(ammo < 1 || ammo > 32767)
			return SendErrorMessage(playerid, "Invalid Ammo.");  
			
		totalPrice = ammo * 25 + 12500; 
		
		format(str, sizeof(str), "Are you sure you want to purchase a Colt 45 for $%s?", MoneyFormat(totalPrice));
		ConfirmDialog(playerid, "Confirmation", str, "OnPlayerPurchaseWeapon", WEAPON_COLT45, ammo, totalPrice); 
	}
	else if(!strcmp(a_str, "deagle"))
	{
		if(sscanf(b_str, "i", ammo))
			return SendUsageMessage(playerid, "/buygun deagle [ammo]"); 
			
		if(ammo < 1 || ammo > 32767)
			return SendErrorMessage(playerid, "Invalid Ammo.");  
			
		totalPrice = ammo * 38 + 17500; 
		
		format(str, sizeof(str), "Are you sure you want to purchase a Desert Eagle for $%s?", MoneyFormat(totalPrice));
		ConfirmDialog(playerid, "Confirmation", str, "OnPlayerPurchaseWeapon", WEAPON_DEAGLE, ammo, totalPrice); 
	}
	else if(!strcmp(a_str, "shotgun"))
	{
		if(sscanf(b_str, "i", ammo))
			return SendUsageMessage(playerid, "/buygun shotgun [ammo]"); 
			
		if(ammo < 1 || ammo > 32767)
			return SendErrorMessage(playerid, "Invalid Ammo.");  
			
		totalPrice = ammo * 38 + 17500; 
		
		format(str, sizeof(str), "Are you sure you want to purchase a Shotgun for $%s?", MoneyFormat(totalPrice));
		ConfirmDialog(playerid, "Confirmation", str, "OnPlayerPurchaseWeapon", WEAPON_SHOTGUN, ammo, totalPrice); 
	}
	else if(!strcmp(a_str, "rifle"))
	{
		if(sscanf(b_str, "i", ammo))
			return SendUsageMessage(playerid, "/buygun rifle [ammo]"); 
			
		if(ammo < 1 || ammo > 32767)
			return SendErrorMessage(playerid, "Invalid Ammo.");  
			
		totalPrice = ammo * 100 + 25000; 
		
		format(str, sizeof(str), "Are you sure you want to purchase a Rifle for $%s?", MoneyFormat(totalPrice));
		ConfirmDialog(playerid, "Confirmation", str, "OnPlayerPurchaseWeapon", WEAPON_RIFLE, ammo, totalPrice); 
	}
	else if(!strcmp(a_str, "parachute"))
	{
		totalPrice = 1250; 
		ammo = 1; 
		
		format(str, sizeof(str), "Are you sure you want to purchase a Parachute for $%s?", MoneyFormat(totalPrice));
		ConfirmDialog(playerid, "Confirmation", str, "OnPlayerPurchaseWeapon", WEAPON_PARACHUTE, ammo, totalPrice); 
	}
	else if(!strcmp(a_str, "armor"))
	{
		totalPrice = 2000; 
		
		format(str, sizeof(str), "Are you sure you want to purchase Armor for $%s?", MoneyFormat(totalPrice));
		ConfirmDialog(playerid, "Confirmation", str, "OnPlayerPurchaseArmor"); 
	}
		
	return 1;
}

CMD:buyammo(playerid, params[])
{
	new id = IsPlayerInBusiness(playerid);
	new weapon[30], ammo, totalPrice, str[128];
	
	if(!IsPlayerInBusiness(playerid))	
		return SendErrorMessage(playerid, "You aren't in a business."); 
		
	if(BusinessInfo[id][eBusinessType] != BUSINESS_TYPE_AMMUNATION)
		return SendErrorMessage(playerid, "You aren't in an ammunation."); 
		
	if(!PlayerInfo[playerid][pWeaponsLicense])
		return SendUnauthMessage(playerid); 
		
	if(sscanf(params, "s[30]i", weapon, ammo))
	{
		SendUsageMessage(playerid, "/buyammo [weapon] [ammo]"); 
		SendClientMessage(playerid, COLOR_GRAD2, "[ colt: $25 ] [ deagle: $38 ] [ shotgun: $38 ] [ rifle: $100 ]");
		return 1; 
	}
	
	if(ammo < 1 || ammo > 32767)
			return SendErrorMessage(playerid, "Invalid Ammo.");  
	
	if(!strcmp(weapon, "colt"))
	{
		if(!PlayerHasWeapon(playerid, 22))
			return SendErrorMessage(playerid, "You don't have this weapon.");
			
		totalPrice = 25 * ammo; 
		
		format(str, sizeof(str), "Are you sure you want to buy ammo for $%s?", MoneyFormat(totalPrice)); 
		ConfirmDialog(playerid, "Confirmation", str, "OnPlayerPurchaseAmmo", WEAPON_COLT45, ammo, totalPrice); 
	}
	else if(!strcmp(weapon, "deagle"))
	{
		if(!PlayerHasWeapon(playerid, 24))
			return SendErrorMessage(playerid, "You don't have this weapon.");
			
		totalPrice = 38 * ammo; 
		
		format(str, sizeof(str), "Are you sure you want to buy ammo for $%s?", MoneyFormat(totalPrice)); 
		ConfirmDialog(playerid, "Confirmation", str, "OnPlayerPurchaseAmmo", WEAPON_DEAGLE, ammo, totalPrice); 
	}
	else if(!strcmp(weapon, "shotgun"))
	{
		if(!PlayerHasWeapon(playerid, 25))
			return SendErrorMessage(playerid, "You don't have this weapon.");
			
		totalPrice = 38 * ammo; 
		
		format(str, sizeof(str), "Are you sure you want to buy ammo for $%s?", MoneyFormat(totalPrice)); 
		ConfirmDialog(playerid, "Confirmation", str, "OnPlayerPurchaseAmmo", WEAPON_SHOTGUN, ammo, totalPrice); 
	}
	else if(!strcmp(weapon, "rifle"))
	{
		if(!PlayerHasWeapon(playerid, 33))
			return SendErrorMessage(playerid, "You don't have this weapon.");
			
		totalPrice = 100 * ammo; 
		
		format(str, sizeof(str), "Are you sure you want to buy ammo for $%s?", MoneyFormat(totalPrice)); 
		ConfirmDialog(playerid, "Confirmation", str, "OnPlayerPurchaseAmmo", WEAPON_RIFLE, ammo, totalPrice); 
	}
		
	return 1;
}

CMD:license(playerid, params[])
{
	new
		playerb;
		
	if(sscanf(params, "u", playerb))
		return SendUsageMessage(playerid, "/license [playerid OR name]"); 
	
	if(!IsPlayerConnected(playerb))
		return SendErrorMessage(playerid, "You specified an invalid player.");
		
	if(!PlayerInfo[playerb][pLoggedin])
		return SendErrorMessage(playerid, "You specified a player that isn't logged in.");
		
	if(!IsPlayerNearPlayer(playerid, playerb, 5.0))
		return SendErrorMessage(playerid, "You aren't near that player."); 
		
	if(playerb != playerid)
		SendNearbyMessage(playerid, 20.0, COLOR_EMOTE, "* %s shows %s their identification card.", ReturnName(playerid, 0), ReturnName(playerb, 0));
		
	else SendNearbyMessage(playerid, 20.0, COLOR_EMOTE, "* %s looks at their identification card.", ReturnName(playerid, 0));
	
	ReturnLicenses(playerid, playerb); 	
	return 1;
}

CMD:licenseexam(playerid, params[])
{
	if(!IsPlayerInDMVVehicle(playerid))
		return SendErrorMessage(playerid, "You aren't in a license exam vehicle."); 
		
	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
		return SendErrorMessage(playerid, "You aren't in the driver's seat."); 
		
	if(PlayerTakingLicense[playerid])
		return SendErrorMessage(playerid, "You're already in middle of a test.");
		
	new
		vehicleid = GetPlayerVehicleID(playerid);

	PlayerTakingLicense[playerid] = true; 
	PlayerLicenseTime[playerid] = 60;
	
	PlayersLicenseVehicle[playerid] = vehicleid;
	PlayerLicensePoint[playerid] = 0; 
	
	ToggleVehicleEngine(vehicleid, true); 
	VehicleInfo[vehicleid][eVehicleEngineStatus] = true;
	
	SendClientMessage(playerid, COLOR_GREY, "License instructor says: Follow the checkpoints and the rules of the road.");
	SetPlayerCheckpoint(playerid, LicensetestInfo[0][eCheckpointX], LicensetestInfo[1][eCheckpointY], LicensetestInfo[2][eCheckpointZ], 3.0); 
	return 1;
}

CMD:unimpound(playerid, params[])
{
	if(!PlayerInfo[playerid][pVehicleSpawned] && !PlayerInfo[playerid][pAdminDuty])
		return SendErrorMessage(playerid, "You don't have a vehicle spawned.");
	
	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
		return SendErrorMessage(playerid, "You aren't in the driver's seat of a vehicle."); 
		
	new vehicleid = GetPlayerVehicleID(playerid);

	if(VehicleInfo[vehicleid][eVehicleOwnerDBID] != PlayerInfo[playerid][pDBID])
		return SendErrorMessage(playerid, "You don't own this vehicle.");
		
	if(!VehicleInfo[vehicleid][eVehicleImpounded])
		return SendErrorMessage(playerid, "Your vehicle isn't impounded.");
		
	if(1500 > PlayerInfo[playerid][pMoney])
		return SendErrorMessage(playerid, "You don't have $1,500 to pay the fee.");
		
	VehicleInfo[vehicleid][eVehicleImpounded] = false;	
	GiveMoney(playerid, -1500);
	
	SendServerMessage(playerid, "You have unimpounded your %s.", ReturnVehicleName(vehicleid));
	SaveVehicle(vehicleid);
	SaveVehicle(vehicleid);
	return 1;
}

CMD:fixr(playerid, params[])
{
	StopAudioStreamForPlayer(playerid);
	return 1;
}

CMD:setstation(playerid, params[])
{
	if(!IsPlayerInAnyVehicle(playerid) && !IsPlayerInProperty(playerid))
		return SendErrorMessage(playerid, "You are not near a radio.");
		
	new
		vehicleid = INVALID_VEHICLE_ID,
		id
	; 
	
	if(IsPlayerInAnyVehicle(playerid))
	{
		vehicleid = GetPlayerVehicleID(playerid);
	
		if(GetPlayerVehicleSeat(playerid) > 1)
			return SendErrorMessage(playerid, "You aren't in the driver or front passenger seat."); 
			
		if(!VehicleInfo[vehicleid][eVehicleHasXMR])
			return SendClientMessage(playerid, COLOR_YELLOW, "This vehicle does not have an XM-Radio."); 
	}
	
	if(!strcmp(params, "off"))
	{
		if(IsPlayerInAnyVehicle(playerid))
		{
			if(!VehicleInfo[vehicleid][eVehicleXMROn])
				return SendErrorMessage(playerid, "The XM-Radio is not on."); 
				
			PlayXMRStation(playerid, vehicleid, 0, true);
			return 1; 
		}
		
		if(IsPlayerInProperty(playerid) != 0)
		{
			PlayXMRStation(playerid, INVALID_VEHICLE_ID, IsPlayerInProperty(playerid), true); 
			return 1;
		}
		
		return 1;
	}
	
	if(sscanf(params, "i", id))
	{
		return ReturnXMRCategories(playerid); 
	}
	
	if(!XMRStationInfo[id][eXMRStationID])
		return SendErrorMessage(playerid, "You specified an invalid Station ID."); 
		
	SubXMRHolder[playerid] = id;
	PlayXMRStation(playerid, vehicleid, IsPlayerInProperty(playerid)); 
	return 1;
}

CMD:time(playerid, params[])
{
	callcmd::ame(playerid, "checks the time.");

	new string[128], hour, minute, seconds;
	
	gettime(hour, minute, seconds);
	
	if(PlayerInfo[playerid][pAdminjailed] == true)
		format(string, sizeof(string), "~g~|~w~%02d:%02d~g~|~n~~w~Jail Time left: %d SEC", hour, minute, PlayerInfo[playerid][pAdminjailTime]);

	else
		format(string, sizeof(string), "~g~|~w~%02d:%02d~g~|", hour, minute);
		
	GameTextForPlayer(playerid, string, 2000, 1);
	
	return 1;
}

CMD:rcp(playerid, params[])
{
	DisablePlayerCheckpoint(playerid);
	
	//Disabling checkpoint referring variables:
	PlayerCheckpoint[playerid] = 0;
	return 1;
}

CMD:weapon(playerid, params[])
{
	new oneString[24], secString[64];

	if(sscanf(params, "s[24]S()[64]", oneString, secString))
	{
		SendUsageMessage(playerid, "/weapon [adjust/bone/hide]");
		return 1;
	}
    new weaponid = GetPlayerWeapon(playerid);

    if (!weaponid)
        return SendClientMessage(playerid, -1, "You are not holding a weapon.");

    if (!IsWeaponWearable(weaponid))
        return SendClientMessage(playerid, -1, "This weapon cannot be edited.");

    if (!strcmp(secString, "adjust", true))
    {
        if (EditingWeapon[playerid])
            return SendClientMessage(playerid, -1, "You are already editing a weapon.");

        if (WeaponSettings[playerid][weaponid - 22][Hidden])
            return SendClientMessage(playerid, -1, "You cannot adjust a hidden weapon.");

        new index = weaponid - 22;

        SetPlayerArmedWeapon(playerid, 0);

        SetPlayerAttachedObject(playerid, GetWeaponObjectSlot(weaponid), ReturnWeaponsModel(weaponid), WeaponSettings[playerid][index][Bone], WeaponSettings[playerid][index][Position][0], WeaponSettings[playerid][index][Position][1], WeaponSettings[playerid][index][Position][2], WeaponSettings[playerid][index][Position][3], WeaponSettings[playerid][index][Position][4], WeaponSettings[playerid][index][Position][5], 1.0, 1.0, 1.0);
        EditAttachedObject(playerid, GetWeaponObjectSlot(weaponid));

        EditingWeapon[playerid] = weaponid;
    }
    else if (!strcmp(secString, "bone", true))
    {
        if (EditingWeapon[playerid])
            return SendClientMessage(playerid, -1, "You are already editing a weapon.");

        ShowPlayerDialog(playerid, DIALOG_EDIT_BONE, DIALOG_STYLE_LIST, "Bone", "Spine\nHead\nLeft upper arm\nRight upper arm\nLeft hand\nRight hand\nLeft thigh\nRight thigh\nLeft foot\nRight foot\nRight calf\nLeft calf\nLeft forearm\nRight forearm\nLeft shoulder\nRight shoulder\nNeck\nJaw", "Choose", "Cancel");
        EditingWeapon[playerid] = weaponid;
    }
    else if (!strcmp(secString, "hide", true))
    {
        if (EditingWeapon[playerid])
            return SendClientMessage(playerid, -1, "You cannot hide a weapon while you are editing it.");

        if (!IsWeaponHideable(weaponid))
            return SendClientMessage(playerid, -1, "This weapon cannot be hidden.");

        new index = weaponid - 22, string[150];

        if (WeaponSettings[playerid][index][Hidden])
        {
            format(string, sizeof(string), "You have set your %s to show.", ReturnWeaponName(weaponid));
            WeaponSettings[playerid][index][Hidden] = false;
        }
        else
        {
            if (IsPlayerAttachedObjectSlotUsed(playerid, GetWeaponObjectSlot(weaponid)))
                RemovePlayerAttachedObject(playerid, GetWeaponObjectSlot(weaponid));

            format(string, sizeof(string), "You have set your %s not to show.", ReturnWeaponName(weaponid));
            WeaponSettings[playerid][index][Hidden] = true;
        }
        SendClientMessage(playerid, -1, string);

        mysql_format(this, string, sizeof(string), "INSERT INTO weaponsettings (Name, WeaponID, Hidden) VALUES ('%s', %d, %d) ON DUPLICATE KEY UPDATE Hidden = VALUES(Hidden)", ReturnName(playerid), weaponid, WeaponSettings[playerid][index][Hidden]);
        mysql_tquery(this, string);
    }
    else SendClientMessage(playerid, -1, "You have specified an invalid option.");
	return 1;
}

CMD:weapons(playerid, params[])
{
	SendClientMessage(playerid, COLOR_RED, "To throw away a weapon, type /leavegun [weapon ID]"); 
	
	for(new i = 0; i < 4; i++)
	{
		if(PlayerInfo[playerid][pWeaponsAmmo][i] > 0)
			sendMessage(playerid, COLOR_GREY, "[ID: %d] Weapon: [%s] - Ammo: [%d]", PlayerInfo[playerid][pWeapons][i], ReturnWeaponName(PlayerInfo[playerid][pWeapons][i]), PlayerInfo[playerid][pWeaponsAmmo][i]);
	}
		
	return 1;
}

alias:leavegun("lg");
CMD:leavegun(playerid, params[])
{
	new 
		weaponid, 
		idx,
		id, 
		Float:x,
		Float:y,
		Float:z
	;
	
	if(sscanf(params, "i", weaponid))
	{
		SendUsageMessage(playerid, "/leavegun [weapon id]");
		SendClientMessage(playerid, COLOR_RED, "[ ! ]{FFFFFF} To pick up the weapon, use /grabgun."); 
		return 1;
	}
	
	if(weaponid < 1 || weaponid > 46 || weaponid == 35 || weaponid == 36 || weaponid == 37 || weaponid == 38 || weaponid == 39)
	    return SendErrorMessage(playerid, "You have specified an invalid weaponid.");
		
	if(!PlayerHasWeapon(playerid, weaponid))
		return SendErrorMessage(playerid, "You don't have that weapon."); 
		
	for(new i = 0; i < sizeof(WeaponDropInfo); i++)
	{
		if(!WeaponDropInfo[i][eWeaponDropped])
		{
			idx = i;
			break;
		}
	}
	
	id = ReturnWeaponIDSlot(weaponid); 
	GetPlayerPos(playerid, x, y, z); 
	
	WeaponDropInfo[idx][eWeaponDropped] = true;
	WeaponDropInfo[idx][eWeaponDroppedBy] = PlayerInfo[playerid][pDBID]; 
	
	WeaponDropInfo[idx][eWeaponWepID] = weaponid;
	WeaponDropInfo[idx][eWeaponWepAmmo] = PlayerInfo[playerid][pWeaponsAmmo][id];
	
	WeaponDropInfo[idx][eWeaponPos][0] = x;
	WeaponDropInfo[idx][eWeaponPos][1] = y;
	WeaponDropInfo[idx][eWeaponPos][2] = z;
	
	WeaponDropInfo[idx][eWeaponInterior] = GetPlayerInterior(playerid);
	WeaponDropInfo[idx][eWeaponWorld] = GetPlayerVirtualWorld(playerid); 
	
	RemovePlayerWeapon(playerid, weaponid);
	PlayerInfo[playerid][pWeapons][id] = 0;
	PlayerInfo[playerid][pWeaponsAmmo][id] = 0; 
	
	WeaponDropInfo[idx][eWeaponObject] = CreateDynamicObject(
		ReturnWeaponsModel(weaponid),
		x,
		y,
		z - 1,
		80.0,
		0.0,
		0.0,
		GetPlayerVirtualWorld(playerid),
		GetPlayerInterior(playerid)); 
		
	WeaponDropInfo[idx][eWeaponTimer] = SetTimerEx("OnPlayerLeaveWeapon", 600000, false, "i", idx); 
	SendClientMessage(playerid, COLOR_RED, "[ ! ]{FFFFFF} Your weapon will disappear in 10 minutes if it isn't picked up.");
	return 1;
}

alias:grabgun("gg");
CMD:grabgun(playerid, params[])
{	
	new
		bool:foundWeapon = false,
		id,
		str[128]
	;

	for(new i = 0; i < sizeof(WeaponDropInfo); i++)
	{
		if(!WeaponDropInfo[i][eWeaponDropped])
			continue; 
	
		if(IsPlayerInRangeOfPoint(playerid, 3.0, WeaponDropInfo[i][eWeaponPos][0], WeaponDropInfo[i][eWeaponPos][1], WeaponDropInfo[i][eWeaponPos][2]))
		{
			if(GetPlayerVirtualWorld(playerid) == WeaponDropInfo[i][eWeaponWorld])
			{
				foundWeapon = true;
				id = i;
			}							
		}
	}
	
	if(foundWeapon)
	{
		GivePlayerGun(playerid, WeaponDropInfo[id][eWeaponWepID], WeaponDropInfo[id][eWeaponWepAmmo]);
		
		format(str, sizeof(str), "* %s picks up a %s.", ReturnName(playerid, 0), ReturnWeaponName(WeaponDropInfo[id][eWeaponWepID]));
		SetPlayerChatBubble(playerid, str, COLOR_EMOTE, 20.0, 3000);
		SendClientMessage(playerid, COLOR_EMOTE, str);
		
		WeaponDropInfo[id][eWeaponDropped] = false; 
		WeaponDropInfo[id][eWeaponDroppedBy] = 0;
		
		WeaponDropInfo[id][eWeaponWepID] = 0; WeaponDropInfo[id][eWeaponWepAmmo] = 0; 
		
		KillTimer(WeaponDropInfo[id][eWeaponTimer]); 
		DestroyDynamicObject(WeaponDropInfo[id][eWeaponObject]); 
	}
	else return SendServerMessage(playerid, "You aren't near a dropped weapon.");
	return 1;
}

CMD:enter(playerid, params[])
{
	new
		id,
		str[128]
	; 

	for(new p = 1; p < MAX_PROPERTY; p++)
	{
		if(!PropertyInfo[p][ePropertyDBID])
			continue;
				
		if(IsPlayerInRangeOfPoint(playerid, 3.0, PropertyInfo[p][ePropertyEntrance][0], PropertyInfo[p][ePropertyEntrance][1], PropertyInfo[p][ePropertyEntrance][2]))
		{
			if(GetPlayerInterior(playerid) != PropertyInfo[p][ePropertyEntranceInterior])
				continue;
					
			if(GetPlayerVirtualWorld(playerid) != PropertyInfo[p][ePropertyEntranceWorld])
				continue;
				
			if(PropertyInfo[p][ePropertyLocked])
				return GameTextForPlayer(playerid, "~r~Locked", 3000, 1);
				
			PlayerInfo[playerid][pInsideProperty] = p;
			
			if(PropertyInfo[p][ePropertyBoomboxOn])
			{
				PlayAudioStreamForPlayer(playerid, PropertyInfo[p][ePropertyBoomboxURL]);
			}

			SetPlayerPos(playerid, PropertyInfo[p][ePropertyInterior][0], PropertyInfo[p][ePropertyInterior][1], PropertyInfo[p][ePropertyInterior][2] - 3);
			
			SetPlayerVirtualWorld(playerid, PropertyInfo[p][ePropertyInteriorWorld]);
			SetPlayerInterior(playerid, PropertyInfo[p][ePropertyInteriorIntID]);
			
			TogglePlayerControllable(playerid, 0);
			SetTimerEx("OnPlayerEnterProperty", 2000, false, "ii", playerid, p); 
		
		}
	}
	
	if((id = IsPlayerNearBusiness(playerid)) != 0)
	{
		if(BusinessInfo[id][eBusinessLocked])
			return GameTextForPlayer(playerid, "~r~Locked", 3000, 1); 
			
		if(BusinessInfo[id][eBusinessType] == BUSINESS_TYPE_DEALERSHIP || BusinessInfo[id][eBusinessType] == BUSINESS_TYPE_DMV)
			return GameTextForPlayer(playerid, "~r~Closed", 3000, 1); 
			
		if(BusinessInfo[id][eBusinessEntranceFee] > PlayerInfo[playerid][pMoney])
			return GameTextForPlayer(playerid, "~r~You can't afford this.", 3000, 1); 
			
		if(PlayerInfo[playerid][pDBID] != BusinessInfo[id][eBusinessOwnerDBID] && BusinessInfo[id][eBusinessType] != BUSINESS_TYPE_BANK)
		{
			GiveMoney(playerid, -BusinessInfo[id][eBusinessEntranceFee]); 
			BusinessInfo[id][eBusinessCashbox]+= BusinessInfo[id][eBusinessEntranceFee]; 
		}
			
		format(str, sizeof(str), "%s", BusinessInfo[id][eBusinessName]); 
		GameTextForPlayer(playerid, str, 3000, 1); 
		
		SetPlayerPos(playerid, BusinessInfo[id][eBusinessInterior][0], BusinessInfo[id][eBusinessInterior][1], BusinessInfo[id][eBusinessInterior][2]); 
		
		SetPlayerInterior(playerid, BusinessInfo[id][eBusinessInteriorIntID]); 
		SetPlayerVirtualWorld(playerid, BusinessInfo[id][eBusinessInteriorWorld]); 
		
		PlayerInfo[playerid][pInsideBusiness] = id; 
		
		SendBusinessType(playerid, id);
		return 1;
	}
	
	SendServerMessage(playerid, "You aren't near an entrance."); 
	return 1;
}

CMD:exit(playerid, params[])
{
	new 
		id,
		b_id
	;
	
	if(PlayerInfo[playerid][pEditingObject])
		return SendErrorMessage(playerid, "You can't leave while editing an object.");
	
	if((id = IsPlayerInProperty(playerid)) != 0)
	{
		if(!IsPlayerInRangeOfPoint(playerid, 3.0, PropertyInfo[id][ePropertyInterior][0], PropertyInfo[id][ePropertyInterior][1], PropertyInfo[id][ePropertyInterior][2]))
			return SendErrorMessage(playerid, "You aren't near the door.");
	
		SetPlayerPos(playerid, PropertyInfo[id][ePropertyEntrance][0], PropertyInfo[id][ePropertyEntrance][1], PropertyInfo[id][ePropertyEntrance][2]);
		
		SetPlayerVirtualWorld(playerid, PropertyInfo[id][ePropertyEntranceWorld]);
		SetPlayerInterior(playerid, PropertyInfo[id][ePropertyEntranceInterior]); 
		
		if(PropertyInfo[id][ePropertyBoomboxOn])
			StopAudioStreamForPlayer(playerid);
		
		PlayerInfo[playerid][pInsideProperty] = 0;
		return 1;
	}
	
	if((b_id = IsPlayerInBusiness(playerid)) != 0)
	{
		if(!IsPlayerInRangeOfPoint(playerid, 3.0, BusinessInfo[b_id][eBusinessInterior][0], BusinessInfo[b_id][eBusinessInterior][1], BusinessInfo[b_id][eBusinessInterior][2]))
			return SendErrorMessage(playerid, "You aren't near the door.");
	
		SetPlayerPos(playerid, BusinessInfo[b_id][eBusinessEntrance][0], BusinessInfo[b_id][eBusinessEntrance][1], BusinessInfo[b_id][eBusinessEntrance][2]);
		
		SetPlayerVirtualWorld(playerid, 0);
		SetPlayerInterior(playerid, 0);
		
		PlayerInfo[playerid][pInsideBusiness] = 0;
		return 1;
	}
	
	SendServerMessage(playerid, "You aren't in an interior.");
	return 1;
}
alias:rollwindow("rw", "wi", "window");
CMD:rollwindow(playerid,params[])
{
	new
		vehicle = GetPlayerVehicleID(playerid),
		type[24];

	if (vehicle == INVALID_VEHICLE_ID)
		return SendErrorMessage(playerid, "You are not inside any vehicle.");

	if (!IsWindowedVehicle(vehicle))
		return SendErrorMessage(playerid, "This vehicle doesn't have windows.");

	if (PlayerInfo[playerid][pHandcuffed])
		return SendErrorMessage(playerid, "You can't use this command while cuffed.");

	if (sscanf(params,"s[24]",type))
		return SendUsageMessage(playerid, "/(r)oll(w)indow {FFFFFF}[fl/fr/bl/br/all]");

	if (!strcmp(type, "fl", true))
	{
		VehicleInfo[vehicle][vWindowFL] = !VehicleInfo[vehicle][vWindowFL];
	}
	if (!strcmp(type, "fr", true))
	{
		VehicleInfo[vehicle][vWindowFR] = !VehicleInfo[vehicle][vWindowFR];
	}
	if (!strcmp(type, "bl", true))
	{
		VehicleInfo[vehicle][vWindowBL] = !VehicleInfo[vehicle][vWindowBL];
	}
	if (!strcmp(type, "br", true))
	{
		VehicleInfo[vehicle][vWindowBR] = !VehicleInfo[vehicle][vWindowBR];
	}
	if (!strcmp(type, "all", true))
	{
		VehicleInfo[vehicle][vWindows] = !VehicleInfo[vehicle][vWindows];
		VehicleInfo[vehicle][vWindowFL] = VehicleInfo[vehicle][vWindows];
		VehicleInfo[vehicle][vWindowFR] = VehicleInfo[vehicle][vWindows];
		VehicleInfo[vehicle][vWindowBL] = VehicleInfo[vehicle][vWindows];
		VehicleInfo[vehicle][vWindowBR] = VehicleInfo[vehicle][vWindows];
	}
	SetVehicleParamsCarWindows(vehicle, VehicleInfo[vehicle][vWindowFL], VehicleInfo[vehicle][vWindowFR], VehicleInfo[vehicle][vWindowBL], VehicleInfo[vehicle][vWindowBR]);
	return 1;
}

CMD:modmenu(playerid, params[])
{
	if(PlayerInfo[playerid][pInTuning])return SendErrorMessage(playerid, "You already in tuning.");

	if(IsPlayerInRangeOfPoint(playerid, 5, EXTERIOR_TUNING_X, EXTERIOR_TUNING_Y, EXTERIOR_TUNING_Z) == 0) return
		SendErrorMessage(playerid, "You are not in Wang's Car.");

	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)return
		SendErrorMessage(playerid, "You must be driver.");

	new vehID = GetPlayerVehicleID(playerid);

	if(IsABike(vehID) > 0 || IsAMotorBike(vehID) > 0)return
		SendErrorMessage(playerid, "This vehicle can not be modded..");

	if(VehicleInfo[vehID][eVehicleOwnerDBID] != PlayerInfo[playerid][pDBID])
		return SendErrorMessage(playerid, "You don't own this vehicle.");

	foreach(new i : Player) if(IsPlayerConnected(i) && GetPlayerVehicleID(i) == vehID && i != playerid)return
		SendErrorMessage(playerid, "There's someone in your car.");

	SetPlayerCameraPos(playerid, 441.1662, -1302.0037, 18.0385);
	SetPlayerCameraLookAt(playerid, 440.2185, -1301.6881, 17.6184);

	SetVehiclePos(vehID, INTERIOR_TUNING_X, INTERIOR_TUNING_Y, INTERIOR_TUNING_Z);
	SetVehicleZAngle(vehID, -180);
	SetPlayerVirtualWorld(playerid, playerid + 1);
	SetVehicleVirtualWorld(vehID, playerid + 1);
	
	SendNearbyMessage(playerid, 20.0, COLOR_EMOTE, "* %s stopped the engine of the %s.", ReturnName(playerid, 0), ReturnVehicleName(vehID));
	ToggleVehicleEngine(vehID, false); VehicleInfo[vehID][eVehicleEngineStatus] = false;

	TogglePlayerControllable(playerid, false);

	PlayerInfo[playerid][pInTuning] = 1;
	PlayerInfo[playerid][pTuningCategoryID] = 0;

	new string[64];
	new categoryTuning = PlayerInfo[playerid][pTuningCategoryID];

	format(string, sizeof(string), "%s (~>~)~y~ %s", TuningCategories[categoryTuning], TuningCategories[categoryTuning + 1]);
	PlayerTextDrawSetString(playerid, TDTuning_Component[playerid], string);
	PlayerTextDrawShow(playerid, TDTuning_Component[playerid]);

	Tuning_SetDisplay(playerid);

	PlayerTextDrawShow(playerid, TDTuning_Dots[playerid]);
	PlayerTextDrawShow(playerid, TDTuning_Price[playerid]);
	PlayerTextDrawShow(playerid, TDTuning_ComponentName[playerid]);
	PlayerTextDrawShow(playerid, TDTuning_YN[playerid]);
 	return 1;
}

//Vehicle commands:
alias:vehicle("v", "vhelp", "veh");
CMD:vehicle(playerid, params[])
{
	new oneString[30], secString[90];
	
	if(sscanf(params, "s[30]S()[90]", oneString, secString))
	{
	    SendClientMessage(playerid, 0xFFFF00FF, "_____________________________________________");
		SendClientMessage(playerid, 0xFCF87FFF, "USAGE: (/v)ehicle [options]");
		SendClientMessage(playerid, 0xBFC0C2FF, "[Actions] get, park, buypark, duplicatekey, buy");
		SendClientMessage(playerid, 0xBFC0C2FF, "[Actions] tow, lock, lights, find, stats, mod, comps");
		SendClientMessage(playerid, 0xBFC0C2FF, "[Actions] list, faction, unfaction, trunk, hood");
		SendClientMessage(playerid, 0xBFC0C2FF, "[Delete] scrap (warning: this option will delete the vehicle PERMANENTLY)");
		SendClientMessage(playerid, 0xFFFF00FF, "_____________________________________________");
		return 1;
	}
	
	if(!strcmp(oneString, "get"))
	{
		if(CountPlayerVehicles(playerid) == 0)
			return SendServerMessage(playerid, "You don't own any vehicles.");

		return ShowVehicleList(playerid);
	}
	else if(!strcmp(oneString, "park"))
	{
		if(!IsPlayerInAnyVehicle(playerid))
			return SendErrorMessage(playerid, "You aren't in any vehicle.");
			
		if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)return SendErrorMessage(playerid, "You need to be driving your vehicle.");

		new 
			vehicleid = GetPlayerVehicleID(playerid);
			
		if(VehicleInfo[vehicleid][eVehicleOwnerDBID] != PlayerInfo[playerid][pDBID])
			return SendErrorMessage(playerid, "You don't own this vehicle."); 
			
		if(!IsPlayerInRangeOfPoint(playerid, 5.0, VehicleInfo[vehicleid][eVehicleParkPos][0], VehicleInfo[vehicleid][eVehicleParkPos][1], VehicleInfo[vehicleid][eVehicleParkPos][2]))
		{
			SendErrorMessage(playerid, "You have to be at your vehicle's parking place.");
			SendClientMessage(playerid, 0xFF00FFFF, "Follow the marker to your parking.");
		
			SetPlayerCheckpoint(playerid, VehicleInfo[vehicleid][eVehicleParkPos][0], VehicleInfo[vehicleid][eVehicleParkPos][1], VehicleInfo[vehicleid][eVehicleParkPos][2], 5.0);
			return 1;
		}
		
		PlayerInfo[playerid][pVehicleSpawned] = false; 
		PlayerInfo[playerid][pVehicleSpawnedID] = INVALID_VEHICLE_ID;
		
		sendMessage(playerid, COLOR_DARKGREEN, "You parked your %s.", ReturnVehicleName(vehicleid));
		
		SaveVehicle(vehicleid);
		
		ResetVehicleVars(vehicleid);
		DestroyVehicle(vehicleid); 
	}
	else if(!strcmp(oneString, "buypark"))
	{
		if(!IsPlayerInAnyVehicle(playerid))
			return SendErrorMessage(playerid, "You aren't in any vehicle.");
			
		if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)return SendErrorMessage(playerid, "You need to be driving your vehicle.");
			
		if(PlayerInfo[playerid][pVehicleSpawned] == false) return SendErrorMessage(playerid, "You don't have a vehicle spawned.");
			
		new 
			vehicleid = GetPlayerVehicleID(playerid);
			
		if(VehicleInfo[vehicleid][eVehicleOwnerDBID] != PlayerInfo[playerid][pDBID])
			return SendErrorMessage(playerid, "You don't own this vehicle."); 
			
		GetVehiclePos(vehicleid, VehicleInfo[vehicleid][eVehicleParkPos][0], VehicleInfo[vehicleid][eVehicleParkPos][1], VehicleInfo[vehicleid][eVehicleParkPos][2]);
		GetVehicleZAngle(vehicleid, VehicleInfo[vehicleid][eVehicleParkPos][3]); 
		
		VehicleInfo[vehicleid][eVehicleParkInterior] = GetPlayerInterior(playerid);
		VehicleInfo[vehicleid][eVehicleParkWorld] = GetPlayerVirtualWorld(playerid); 
		
		SendServerMessage(playerid, "You purchased the parking place for $1,000.");
		GiveMoney(playerid, -1000);
	}
	else if(!strcmp(oneString, "duplicatekey"))
	{
		if(!IsPlayerInAnyVehicle(playerid))
			return SendErrorMessage(playerid, "You aren't in any vehicle.");
			
		if(PlayerInfo[playerid][pVehicleSpawned] == false) return SendErrorMessage(playerid, "You don't have a vehicle spawned.");
			
		new 
			playerb, vehicleid = GetPlayerVehicleID(playerid);
			
		if(VehicleInfo[vehicleid][eVehicleOwnerDBID] != PlayerInfo[playerid][pDBID])
			return SendErrorMessage(playerid, "You don't own this vehicle."); 
			
		if(sscanf(params, "u", playerb))
			return SendUsageMessage(playerid, "/vehicle duplicatekey [playerid OR name]"); 
			
		if(playerb == playerid)return SendErrorMessage(playerid, "You can't give yourself a duplicate key.");
			
		if(!IsPlayerConnected(playerb))
			return SendErrorMessage(playerid, "The player you specified isn't connected.");
			
		if(e_pAccountData[playerb][mLoggedin] == false)
			return SendErrorMessage(playerid, "The player you specified isn't logged in.");
			
		if(!IsPlayerNearPlayer(playerid, playerb, 5.0))
			return SendErrorMessage(playerid, "You aren't near that player."); 
			
		SendNearbyMessage(playerid, 20.0, COLOR_EMOTE, "* %s gives %s a key to their vehicle.", ReturnName(playerid, 0), ReturnName(playerb, 0));
		SendServerMessage(playerb, "%s gave you a key to their vehicle.", ReturnName(playerid, 0));
		
		GiveMoney(playerid, -500);
		SendServerMessage(playerid, "You gave %s a duplicatekey for $500.", ReturnName(playerb, 0));
		
		PlayerInfo[playerb][pDuplicateKey] = vehicleid;
	}
	else if(!strcmp(oneString, "mod", true))
	{
		callcmd::modmenu(playerid, "");
	}
	//
	else if(!strcmp(oneString, "comps", true))
	{
	    new vid = GetPlayerVehicleID(playerid);
		if(VehicleInfo[GetPlayerVehicleID(playerid)][eVehicleOwnerDBID] != PlayerInfo[playerid][pDBID])
			return SendErrorMessage(playerid, "You don't own this vehicle.");

		new string[512] = "{FF6347}>> Reset{FFFFFF}\n{FF6347}Delete Paintjob{FFFFFF}\n";
		new component;
		new strName[32];
		new count;

		for(new j; j < MAX_TUNING_COMPONENTS; j++)
		{
		    strName = "Empty"; component = VehicleInfo[vid][eVehicleMods][j];
		    if(component)strmid(strName, GetComponentName(component), 0, 32);
		    format(string, sizeof(string), "%sSlot %d: %s (#%d)\n", string, j, strName, component);
		    count++;
		}

		if(!count && VehicleInfo[vid][eVehiclePaintjob] == 3) return
			SendServerMessage(playerid, "This vehicle does not have any mods.");

		ShowPlayerDialog(playerid, DIALOG_REMOVE_COMP, DIALOG_STYLE_LIST, "Vehicle Modifications", string, "Remove", "<<");
	}
	else if(!strcmp(oneString, "buy"))
	{
		if(PlayerInfo[playerid][pVehicleSpawned])
			return SendErrorMessage(playerid, "You have a vehicle spawned."); 
			
		new
			id,
			idx
		;
			
		for(new i = 1; i < MAX_PLAYER_VEHICLES; i++)
		{
			if(!PlayerInfo[playerid][pOwnedVehicles][i])
			{
				idx = i;
				break;
			}
		}
				
		if(!idx)
		{
			SendServerMessage(playerid, "You own the maximum amount of vehicles."); 
			return 1;
		}
		
		if(!(id = IsPlayerNearBusiness(playerid)))
			return SendErrorMessage(playerid, "You aren't near a business.");
			
		if((id = IsPlayerNearBusiness(playerid)))
		{
			if(BusinessInfo[id][eBusinessType] != BUSINESS_TYPE_DEALERSHIP)
				return SendErrorMessage(playerid, "You aren't at a dealership."); 
				
			if(GetPVarInt(playerid, "Viewing_OwnedCarList")) return SendErrorMessage(playerid, "You are viewing your car list, you have to close it before view Dealership.");
			PlayerInfo[playerid][pAtDealership] = id;
			ShowDealershipPreviewMenu(playerid);
		}
	}
	else if(!strcmp(oneString, "scrap"))
	{
		if(!IsPlayerInAnyVehicle(playerid))
			return SendErrorMessage(playerid, "You aren't in any vehicle.");
			
		if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)return SendErrorMessage(playerid, "You need to be driving your vehicle.");
			
		if(PlayerInfo[playerid][pVehicleSpawned] == false) return SendErrorMessage(playerid, "You don't have a vehicle spawned.");
			
		new 
			str[160], 
			vehicleid = GetPlayerVehicleID(playerid),
			cash_back
		;
			
		if(VehicleInfo[vehicleid][eVehicleOwnerDBID] != PlayerInfo[playerid][pDBID])
			return SendErrorMessage(playerid, "You don't own this vehicle."); 
			
		for(new i = 0; i < sizeof(g_aDealershipData); i++)
		{
			if(g_aDealershipData[i][eDealershipModelID] == VehicleInfo[vehicleid][eVehicleModel])
			{
				cash_back = g_aDealershipData[i][eDealershipPrice] / 2; 
			}
		}
			
		format(str, sizeof(str), "Are you sure you want to scrap your %s?\nYou'll receive a cashback of: $%s\n\n{FF6347}This action is permanent and cannot be undone.", ReturnVehicleName(vehicleid), MoneyFormat(cash_back)); 
		ConfirmDialog(playerid, "Confirmation", str, "OnVehicleScrap", VehicleInfo[vehicleid][eVehicleDBID], cash_back);
	}
	else if(!strcmp(oneString, "tow"))
	{
		if(PlayerInfo[playerid][pVehicleSpawned] == false) 
			return SendErrorMessage(playerid, "You don't have a vehicle spawned.");
			
		if(IsVehicleOccupied(PlayerInfo[playerid][pVehicleSpawnedID]))
			return SendErrorMessage(playerid, "Your vehicle is in use."); 
			
		VehicleInfo[PlayerInfo[playerid][pVehicleSpawnedID]][eVehicleTowDisplay] = 
			Create3DTextLabel("(( | ))\nTOWING VEHICLE", COLOR_DARKGREEN, 0.0, 0.0, 0.0, 25.0, 0, 1);
			
		Attach3DTextLabelToVehicle(VehicleInfo[PlayerInfo[playerid][pVehicleSpawnedID]][eVehicleTowDisplay], PlayerInfo[playerid][pVehicleSpawnedID], -0.0, -0.0, -0.0);
			
		playerTowingVehicle[playerid] = true;
		playerTowTimer[playerid] = SetTimerEx("OnVehicleTow", 5000, true, "i", playerid);
		
		SendServerMessage(playerid, "Your %s's tow request was sent.", ReturnVehicleName(PlayerInfo[playerid][pVehicleSpawnedID]));
	}
	else if(!strcmp(oneString, "lock"))
	{
		new bool:foundCar = false, vehicleid, Float:fetchPos[3];
		
		for (new i = 0; i < MAX_VEHICLES; i++)
		{
			GetVehiclePos(i, fetchPos[0], fetchPos[1], fetchPos[2]);
			if(IsPlayerInRangeOfPoint(playerid, 4.0, fetchPos[0], fetchPos[1], fetchPos[2]))
			{
				foundCar = true;
				vehicleid = i; 
				break; 
			}
		}
		if(foundCar == true)
		{
			if(VehicleInfo[vehicleid][eVehicleOwnerDBID] != PlayerInfo[playerid][pDBID] && PlayerInfo[playerid][pDuplicateKey] != vehicleid && !IsWindowOpened(vehicleid))
			{
                SendClientMessage(playerid, COLOR_LIGHTRED, "You don't have access to the vehicle.");
                SendClientMessage(playerid, COLOR_LIGHTRED, "If you are trying to break-in: {FFFFFF}\"/lock breakin\"");
                SendClientMessage(playerid, COLOR_LIGHTRED, "If you prefer the peaceful break-in method: {FFFFFF}\"/lock pry\"");
				return 1;
			}
			new statusString[90]; 
			new engine, lights, alarm, doors, bonnet, boot, objective; 
	
			GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);

			if(VehicleInfo[vehicleid][eVehicleLocked])
			{
				format(statusString, sizeof(statusString), "~g~%s UNLOCKED", ReturnVehicleName(vehicleid));
			
				SetVehicleParamsEx(vehicleid, engine, lights, alarm, false, bonnet, boot, objective);
				VehicleInfo[vehicleid][eVehicleLocked] = false;
			}
			else 
			{
				format(statusString, sizeof(statusString), "~r~%s LOCKED", ReturnVehicleName(vehicleid));
				
				SetVehicleParamsEx(vehicleid, engine, lights, alarm, true, bonnet, boot, objective);
				VehicleInfo[vehicleid][eVehicleLocked] = true;
			}
			GameTextForPlayer(playerid, statusString, 3000, 3);
		}
		else SendServerMessage(playerid, "You aren't near a vehicle OR the vehicle isn't synced.");
	}
	else if(!strcmp(oneString, "lights"))
	{
		new vehicleid = GetPlayerVehicleID(playerid);
		
		if(!IsPlayerInAnyVehicle(playerid))
			return SendErrorMessage(playerid, "You aren't in any vehicle.");
			
		if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return SendErrorMessage(playerid, "You aren't driving a vehicle.");
		
		if(VehicleInfo[vehicleid][eVehicleLights] == false)
			ToggleVehicleLights(vehicleid, true);
			
		else ToggleVehicleLights(vehicleid, false);
	}
	else if(!strcmp(oneString, "find"))
	{
		if(PlayerInfo[playerid][pVehicleSpawned] == false) 
			return SendErrorMessage(playerid, "You don't have a vehicle spawned.");
			
		if(IsVehicleOccupied(PlayerInfo[playerid][pVehicleSpawnedID]))
			return SendErrorMessage(playerid, "Your vehicle is in use / stolen.");
			
		new 
			Float:fetchPos[3];
		
		GetVehiclePos(PlayerInfo[playerid][pVehicleSpawnedID], fetchPos[0], fetchPos[1], fetchPos[2]);
		SetPlayerCheckpoint(playerid, fetchPos[0], fetchPos[1], fetchPos[2], 3.0);
	}
	else if(!strcmp(oneString, "stats"))
	{			
		new vehicleid = GetPlayerVehicleID(playerid);
		
		if(VehicleInfo[vehicleid][eVehicleOwnerDBID] != PlayerInfo[playerid][pDBID])
			return SendErrorMessage(playerid, "You don't own this vehicle.");
			
			
		sendMessage(playerid, COLOR_WHITE, "Life Span: Engine Life[%.2f], Battery Life[%.2f], Mileage[%.1f]", VehicleInfo[vehicleid][eVehicleEngine], VehicleInfo[vehicleid][eVehicleBattery], VehicleInfo[vehicleid][eMileage]);
		sendMessage(playerid, COLOR_WHITE, "Security: Lock Level[%i], Alarm Level[%i], Immobilizer[%i], Insurance[%i]", VehicleInfo[vehicleid][eVehicleLockLevel]+1, VehicleInfo[vehicleid][eVehicleAlarmLevel], VehicleInfo[vehicleid][eVehicleImmobLevel], VehicleInfo[vehicleid][eVehicleInsurance]);
		sendMessage(playerid, COLOR_WHITE, "Misc: Primary Color[{%06x}#%03i{FFFFFF}], Secondary Color[{%06x}#%03i{FFFFFF}], License Plate[%s], Times Destroyed[%i]", VehicleColoursTableRGBA[VehicleInfo[vehicleid][eVehicleColor1]] >>> 8, VehicleInfo[vehicleid][eVehicleColor1], VehicleColoursTableRGBA[VehicleInfo[vehicleid][eVehicleColor2]] >>> 8, VehicleInfo[vehicleid][eVehicleColor2], VehicleInfo[vehicleid][eVehiclePlates], VehicleInfo[vehicleid][eVehicleTimesDestroyed]);
	}
	else if(!strcmp(oneString, "faction"))
	{
		if(PlayerInfo[playerid][pVehicleSpawned] == false) 
			return SendErrorMessage(playerid, "You don't have a vehicle spawned.");
			
		if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
			return SendErrorMessage(playerid, "You aren't in a vehicle.");
			
		if(!PlayerInfo[playerid][pFaction]) return SendErrorMessage(playerid, "You aren't in any faction.");
		
		if(PlayerInfo[playerid][pFactionRank] > FactionInfo[PlayerInfo[playerid][pFaction]][eFactionAlterRank])
			return SendClientMessage(playerid, COLOR_RED, "ACCESS DENIED:{FFFFFF} You don't have permission in your faction to add faction vehicles.");
			
		new vehicleid = GetPlayerVehicleID(playerid);
		
		if(VehicleInfo[vehicleid][eVehicleOwnerDBID] != PlayerInfo[playerid][pDBID])
			return SendErrorMessage(playerid, "You don't own this vehicle."); 
			
		if(VehicleInfo[vehicleid][eVehicleFaction] != 0)
			return SendErrorMessage(playerid, "This vehicle is already factionized to the %s.", ReturnFactionNameEx(VehicleInfo[vehicleid][eVehicleFaction]));
		
		VehicleInfo[vehicleid][eVehicleFaction] = PlayerInfo[playerid][pFaction]; 
		SendServerMessage(playerid, "Your vehicle now belongs to the %s.", ReturnFactionName(playerid));
		
		SaveVehicle(vehicleid);
	}
	else if(!strcmp(oneString, "unfaction"))
	{
		if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
			return SendErrorMessage(playerid, "You aren't driving a vehicle.");
			
		new vehicleid = GetPlayerVehicleID(playerid);
		
		if(VehicleInfo[vehicleid][eVehicleOwnerDBID] != PlayerInfo[playerid][pDBID])
			return SendErrorMessage(playerid, "You don't own this vehicle."); 
			
		SendServerMessage(playerid, "You unfactionized your %s from the %s.", ReturnVehicleName(vehicleid), ReturnFactionNameEx(VehicleInfo[vehicleid][eVehicleFaction]));
		VehicleInfo[vehicleid][eVehicleFaction] = 0;
		
		SaveVehicle(vehicleid);
	}
	else if(!strcmp(oneString, "trunk"))
	{
		new
			Float:x,
			Float:y,
			Float:z
		;
		
		new engine, lights, alarm, doors, bonnet, boot, objective;
	
		if(!IsPlayerInAnyVehicle(playerid) && GetNearestVehicle(playerid) != INVALID_VEHICLE_ID)
		{
			GetVehicleBoot(GetNearestVehicle(playerid), x, y, z); 
			
			new 
				vehicleid = GetNearestVehicle(playerid)
			;
				
			if(VehicleInfo[vehicleid][eVehicleLocked])
				return SendServerMessage(playerid, "This vehicle is locked."); 
			
			if(!IsPlayerInRangeOfPoint(playerid, 2.5, x, y, z))
				return SendErrorMessage(playerid, "You aren't near the vehicles trunk.");
			
			GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
			
			if(!boot)
			{
				SetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, 1, objective);
				
				SendClientMessage(playerid, COLOR_YELLOWEX, "You have opened the trunk.");
				SendClientMessage(playerid, COLOR_WHITE, "You can use /check to take a gun or /place to put one in."); 
			}
			else
			{
				SetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, 0, objective);
				
				SendClientMessage(playerid, COLOR_YELLOWEX, "You have closed the trunk.");
			}
		}
		else if(IsPlayerInAnyVehicle(playerid))
		{
			new
				vehicleid = GetPlayerVehicleID(playerid)
			;
			
			if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
				return SendErrorMessage(playerid, "You aren't in the driver's seat.");
			
			if(PlayerInfo[playerid][pDBID] != VehicleInfo[vehicleid][eVehicleOwnerDBID] && PlayerInfo[playerid][pDuplicateKey] != vehicleid)
				return SendErrorMessage(playerid, "You don't have the keys to this vehicle."); 
				
			GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
			
			if(!boot)
			{
				SetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, 1, objective);
				
				SendClientMessage(playerid, COLOR_YELLOWEX, "You have opened the trunk.");
				SendClientMessage(playerid, COLOR_WHITE, "You can use /check to take a gun or /place to put one in."); 
			}
			else
			{
				SetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, 0, objective);
				SendClientMessage(playerid, COLOR_YELLOWEX, "You have closed the trunk.");
			}
		}
		else return SendServerMessage(playerid, "You aren't in or near a vehicle.");
	}
	else if(!strcmp(oneString, "hood"))
	{
		new
			Float:x,
			Float:y,
			Float:z
		;
		
		new engine, lights, alarm, doors, bonnet, boot, objective;
	
		if(!IsPlayerInAnyVehicle(playerid) && GetNearestVehicle(playerid) != INVALID_VEHICLE_ID)
		{
			GetVehicleHood(GetNearestVehicle(playerid), x, y, z); 
			
			new 
				vehicleid = GetNearestVehicle(playerid)
			;
				
			if(VehicleInfo[vehicleid][eVehicleLocked])
				return SendServerMessage(playerid, "This vehicle is locked."); 
			
			if(!IsPlayerInRangeOfPoint(playerid, 2.5, x, y, z))
				return SendErrorMessage(playerid, "You aren't near the vehicles hood.");
			
			GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
			
			if(!bonnet)
			{
				SetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, 1, boot, objective);
				SendClientMessage(playerid, COLOR_YELLOWEX, "You have opened the hood.");
			}
			else
			{
				SetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, 0, boot, objective);
				SendClientMessage(playerid, COLOR_YELLOWEX, "You have closed the hood.");
			}
		}
		else if(IsPlayerInAnyVehicle(playerid))
		{
			new
				vehicleid = GetPlayerVehicleID(playerid)
			;
			
			if(PlayerInfo[playerid][pDBID] != VehicleInfo[vehicleid][eVehicleOwnerDBID] && PlayerInfo[playerid][pDuplicateKey] != vehicleid)
				return SendErrorMessage(playerid, "You don't have the keys to this vehicle."); 
				
			if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
				return SendErrorMessage(playerid, "You aren't in the driver's seat.");
				
			GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
			
			if(!bonnet)
			{
				SetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, 1, boot, objective);
				SendClientMessage(playerid, COLOR_YELLOWEX, "You have opened the hood.");
			}
			else
			{
				SetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, 0, boot, objective);
				SendClientMessage(playerid, COLOR_YELLOWEX, "You have closed the hood.");
			}
		}
		else return SendServerMessage(playerid, "You aren't in or near a vehicle.");
	}
	else if(!strcmp(oneString, "list"))
	{
		if(CountPlayerVehicles(playerid) == 0)
			return SendServerMessage(playerid, "You don't own any vehicles.");
			
		return ShowVehicleList(playerid); 
	}
	else return SendErrorMessage(playerid, "Invalid Parameter.");
	return 1;
}

CMD:engine(playerid, params[])
{
	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
		return SendErrorMessage(playerid, "You aren't in the driver's seat of a vehicle."); 
		
	new vehicleid = GetPlayerVehicleID(playerid);
	
	if(HasNoEngine(vehicleid))
		return SendErrorMessage(playerid, "This vehicle doesn't have a engine."); 

	if(!VehicleInfo[vehicleid][eVehicleDBID] && !VehicleInfo[vehicleid][eVehicleAdminSpawn])
		return SendServerMessage(playerid, "This command can only be used for private vehicles. You are in a public static vehicle.");
		
	if(VehicleInfo[vehicleid][eVehicleFuel] < 1.0 && !VehicleInfo[vehicleid][eVehicleAdminSpawn])
		return SendClientMessage(playerid, COLOR_RED, "Vehicle is out of fuel!"); 
	
	if(VehicleInfo[vehicleid][eVehicleFaction] > 0)
	{
		if(PlayerInfo[playerid][pFaction] != VehicleInfo[vehicleid][eVehicleFaction] && !PlayerInfo[playerid][pAdminDuty])
		{
			return SendErrorMessage(playerid, "You don't have the keys to this vehicle."); 
		}
	}

	if(!VehicleInfo[vehicleid][eVehicleFaction] && VehicleInfo[vehicleid][eVehicleOwnerDBID] != PlayerInfo[playerid][pDBID] && PlayerInfo[playerid][pDuplicateKey] != vehicleid && !PlayerInfo[playerid][pAdminDuty] && !VehicleInfo[vehicleid][eVehicleAdminSpawn])
	{
		new idx, str[128];
		
		if(VehicleInfo[vehicleid][eVehicleEngineStatus] && !PlayerInfo[playerid][pAdminDuty])
			return GameTextForPlayer(playerid, "~g~ENGINE IS ALREADY ON", 3000, 3);
		
		if(VehicleInfo[vehicleid][eVehicleTweak])
		{
		    SendServerMessage(playerid, "The engine is badly damaged.");
		    VehicleInfo[vehicleid][eVehicleRev] = gettime();
			SendClientMessage(playerid, -1, "{FFFF00}HINT: HOLD your W key to rev the egine.");
			SendClientMessage(playerid, -1, "{FFFF00}HINT: You have 10 seconds to rev the engine.");
			return 1;
		}
		PlayerInfo[playerid][pUnscrambling] = true;
	
		for(new i = 0; i < sizeof(UnscrambleInfo); i++)
		{
			idx = random(sizeof(UnscrambleInfo));
		}
		
		PlayerInfo[playerid][pUnscrambleID] = idx;
		
		switch(VehicleInfo[vehicleid][eVehicleImmobLevel])
		{
			case 0: PlayerInfo[playerid][pUnscramblerTime] = 125;
			case 1: PlayerInfo[playerid][pUnscramblerTime] = 100;
			case 2: PlayerInfo[playerid][pUnscramblerTime] = 75;
			case 3: PlayerInfo[playerid][pUnscramblerTime] = 50;
			case 4: PlayerInfo[playerid][pUnscramblerTime] = 25;
		}
		
		PlayerInfo[playerid][pUnscrambleTimer] = SetTimerEx("OnPlayerUnscramble", 1000, true, "i", playerid);
		
		format(str, sizeof(str), "%s", UnscrambleInfo[idx][eScrambledWord]); 
		PlayerTextDrawSetString(playerid, Unscrambler_PTD[playerid][3], str);
		
		format(str, sizeof(str), "%d", PlayerInfo[playerid][pUnscramblerTime]);
		PlayerTextDrawSetString(playerid, Unscrambler_PTD[playerid][5], str);
		
		ShowUnscrambleTextdraw(playerid);
		return 1; 
	}
	
	if(!VehicleInfo[vehicleid][eVehicleEngineStatus])
	{
		SendNearbyMessage(playerid, 20.0, COLOR_EMOTE, "* %s started the engine of the %s.", ReturnName(playerid, 0), ReturnVehicleName(vehicleid)); 
		ToggleVehicleEngine(vehicleid, true); VehicleInfo[vehicleid][eVehicleEngineStatus] = true;
	}
	else
	{
		SendNearbyMessage(playerid, 20.0, COLOR_EMOTE, "* %s stopped the engine of the %s.", ReturnName(playerid, 0), ReturnVehicleName(vehicleid)); 
		ToggleVehicleEngine(vehicleid, false); VehicleInfo[vehicleid][eVehicleEngineStatus] = false;
	}
	return 1;
}

alias:unscramble("uns", "decode", "code");
CMD:unscramble(playerid, params[])
{
	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
		return SendErrorMessage(playerid, "You aren't driving a vehicle.");
		
	if(!PlayerInfo[playerid][pUnscrambling])
		return SendErrorMessage(playerid, "You aren't hotwiring a vehicle.");
	
	if(isnull(params)) return SendUsageMessage(playerid, "/(uns)cramble [unscrambled word]");
	
	if(!strcmp(UnscrambleInfo[PlayerInfo[playerid][pUnscrambleID]][eUnscrambledWord], params))
	{ // This occurrs if they wrote the correct word:
	
		PlayerInfo[playerid][pUnscrambleID] = random(sizeof(UnscrambleInfo)); 
		
		new displayString[60];
		
		format(displayString, 60, "%s", UnscrambleInfo[PlayerInfo[playerid][pUnscrambleID]][eScrambledWord]);
		PlayerTextDrawSetString(playerid, Unscrambler_PTD[playerid][3], displayString); 
		
		//Timer increases depending on alarm level:
		PlayerInfo[playerid][pUnscramblerTime] += 9;
		PlayerInfo[playerid][pScrambleSuccess]++; 
		
		PlayerPlaySound(playerid, 1052, 0, 0, 0);
		//Depending on alarm levels, success time would change:
		if(PlayerInfo[playerid][pScrambleSuccess] >= 7)
		{
			KillTimer(PlayerInfo[playerid][pUnscrambleTimer]);
			PlayerInfo[playerid][pScrambleSuccess] = 0; 
			PlayerInfo[playerid][pUnscrambling] = false;
			
			PlayerInfo[playerid][pUnscrambleID] = 0;
			PlayerInfo[playerid][pUnscramblerTime] = 0;
			
			PlayerInfo[playerid][pScrambleFailed] = 0;
			
			GameTextForPlayer(playerid, "~g~ENGINE TURNED ON", 2000, 3); 
			ShowUnscrambleTextdraw(playerid, false);
			
			new vehicleid = GetPlayerVehicleID(playerid);
			
			SendNearbyMessage(playerid, 20.0, COLOR_EMOTE, "* %s started the engine of the %s.", ReturnName(playerid, 0), ReturnVehicleName(vehicleid)); 
			ToggleVehicleEngine(vehicleid, true); VehicleInfo[vehicleid][eVehicleEngineStatus] = true;
		}	
	}
	else
	{
		PlayerPlaySound(playerid, 1055, 0, 0, 0); 
		
		PlayerInfo[playerid][pUnscrambleID] = random(sizeof(UnscrambleInfo)); 
		
		new displayString[60];
		
		format(displayString, 60, "%s", UnscrambleInfo[PlayerInfo[playerid][pUnscrambleID]][eScrambledWord]);
		PlayerTextDrawSetString(playerid, Unscrambler_PTD[playerid][3], displayString); 
		
		PlayerInfo[playerid][pScrambleFailed]++; 
		PlayerInfo[playerid][pUnscramblerTime] -= random(6)+1;
		
		if(PlayerInfo[playerid][pScrambleFailed] >= 5)
		{
			KillTimer(PlayerInfo[playerid][pUnscrambleTimer]);
			PlayerInfo[playerid][pScrambleSuccess] = 0; 
			PlayerInfo[playerid][pUnscrambling] = false;
			
			PlayerInfo[playerid][pUnscrambleID] = 0;
			PlayerInfo[playerid][pUnscramblerTime] = 0;
			
			PlayerInfo[playerid][pScrambleFailed] = 0;
			
			new 
				vehicleid = GetPlayerVehicleID(playerid)
			;
			
			ToggleVehicleAlarms(vehicleid, true);
			NotifyVehicleOwner(vehicleid);
			
			ClearAnimations(playerid);
			ShowUnscrambleTextdraw(playerid, false);
		}
	}
	
	return 1;
}

CMD:check(playerid, params[])
{
	if(!IsPlayerInAnyVehicle(playerid) && GetNearestVehicle(playerid) == INVALID_VEHICLE_ID && !IsPlayerInProperty(playerid))
		return SendErrorMessage(playerid, "You can't do this right now.");
	
	new
		Float: x,
		Float: y,
		Float: z
	;
	
	if(!IsPlayerInAnyVehicle(playerid) && GetNearestVehicle(playerid) != INVALID_VEHICLE_ID)
	{
		GetVehicleBoot(GetNearestVehicle(playerid), x, y, z); 
		
		new 
			vehicleid = GetNearestVehicle(playerid)
		;
		
		if(!VehicleInfo[vehicleid][eVehicleDBID] && !VehicleInfo[vehicleid][eVehicleAdminSpawn])
			return SendServerMessage(playerid, "This command can only be used for private vehicles. You are in a public static vehicle.");
		
		if(VehicleInfo[vehicleid][eVehicleFaction] && FactionInfo[VehicleInfo[vehicleid][eVehicleFaction]][eFactionType] != FACTION_TYPE_ILLEGAL && PlayerInfo[playerid][pFaction] != VehicleInfo[vehicleid][eVehicleFaction])
			return SendClientMessage(playerid, COLOR_YELLOW, "You don't have access to this vehicle.");
		
		if(!IsPlayerInRangeOfPoint(playerid, 2.5, x, y, z))
			return SendErrorMessage(playerid, "You aren't near the vehicles trunk.");
 
		new engine, lights, alarm, doors, bonnet, boot, objective;
		GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
		
		if(!bonnet)
			return SendServerMessage(playerid, "Trunk is locked..");
			
		ListTrunkWeapons(playerid, vehicleid, false);
	}
	else if(IsPlayerInAnyVehicle(playerid))
	{
		new
			vehicleid = GetPlayerVehicleID(playerid)
		;

		if(!VehicleInfo[vehicleid][eVehicleDBID] && !VehicleInfo[vehicleid][eVehicleAdminSpawn])
			return SendServerMessage(playerid, "This command can only be used for private vehicles. You are in a public static vehicle.");	

		if(VehicleInfo[vehicleid][eVehicleFaction] && FactionInfo[VehicleInfo[vehicleid][eVehicleFaction]][eFactionType] != FACTION_TYPE_ILLEGAL && PlayerInfo[playerid][pFaction] != VehicleInfo[vehicleid][eVehicleFaction])
			return SendClientMessage(playerid, COLOR_YELLOW, "You don't have access to this vehicle.");
		
		if(!VehicleInfo[vehicleid][eVehicleEngineStatus])
			return SendServerMessage(playerid, "Turn on the engine..");
		
		ListTrunkWeapons(playerid, vehicleid, false);
	}
	else if(IsPlayerInProperty(playerid))
	{
		new
			id = IsPlayerInProperty(playerid),
			longstr[600]
		;
		
		if(!IsPlayerInRangeOfPoint(playerid, 3.0, PropertyInfo[id][ePropertyPlacePos][0], PropertyInfo[id][ePropertyPlacePos][1], PropertyInfo[id][ePropertyPlacePos][2]))
			return SendErrorMessage(playerid, "You aren't near this properties place position.");
			
		for(new i = 1; i < 21; i++)
		{
			if(!PropertyInfo[id][ePropertyWeapons][i])
				format(longstr, sizeof(longstr), "%s%d. [Empty]\n", longstr, i);
				
			else format(longstr, sizeof(longstr), "%s%d. %s[Ammo: %d]\n", longstr, i, ReturnWeaponName(PropertyInfo[id][ePropertyWeapons][i]), PropertyInfo[id][ePropertyWeaponsAmmo][i]); 
		}
		
		ShowPlayerDialog(playerid, DIALOG_HOUSE_WEAPONS, DIALOG_STYLE_LIST, "Weapons:", longstr, "Select", "Cancel");		
	}
	return 1;
}

CMD:place(playerid, params[])
{
	if(!IsPlayerInAnyVehicle(playerid) && GetNearestVehicle(playerid) == INVALID_VEHICLE_ID && !IsPlayerInProperty(playerid))
		return SendErrorMessage(playerid, "You can't do this right now.");
	
	new
		Float: x,
		Float: y,
		Float: z,
		str[128],
		weaponid
	;
	
	if(sscanf(params, "i", weaponid))
		return SendUsageMessage(playerid, "/place [weapon id]");
		
	if(!PlayerHasWeapon(playerid, weaponid))
		return SendErrorMessage(playerid, "You don't have that weapon.");
	
	if(!IsPlayerInAnyVehicle(playerid) && GetNearestVehicle(playerid) != INVALID_VEHICLE_ID)
	{
		GetVehicleBoot(GetNearestVehicle(playerid), x, y, z); 
		
		new 
			vehicleid = GetNearestVehicle(playerid)
		;
		
		if(VehicleInfo[vehicleid][eVehicleFaction] && FactionInfo[VehicleInfo[vehicleid][eVehicleFaction]][eFactionType] != FACTION_TYPE_ILLEGAL)
			return SendClientMessage(playerid, COLOR_YELLOW, "You don't have access to this vehicle.");
		
		if(!IsPlayerInRangeOfPoint(playerid, 2.5, x, y, z))
			return SendErrorMessage(playerid, "You aren't near the vehicles trunk.");
 
		new engine, lights, alarm, doors, bonnet, boot, objective;
		GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
		
		if(!bonnet)
			return SendClientMessage(playerid, COLOR_YELLOWEX, "You need to open the trunk first."); 
			
		if(GetVehicleTrunkWeps(vehicleid) == MAX_WEP_SLOT-1) return SendClientMessage(playerid, COLOR_LIGHTRED, "No more space.");

		new
			slot = GetNextVehicleTrunkSlot(vehicleid),
            insert[300]
			;

		mysql_format(this, insert, sizeof(insert), "INSERT INTO vehicle_trunk (weapon, ammo, vehicle) VALUES(%i, %i, %i)",
		PlayerInfo[playerid][pWeaponsAmmo][ ReturnWeaponIDSlot(weaponid) ], PlayerInfo[playerid][pWeapons][ ReturnWeaponIDSlot(weaponid) ], vehicleid);
		mysql_tquery(this, insert, "AddWeaponToTrunk", "iiiii", playerid, vehicleid, slot, PlayerInfo[playerid][pWeapons][ ReturnWeaponIDSlot(weaponid) ], PlayerInfo[playerid][pWeaponsAmmo][ ReturnWeaponIDSlot(weaponid) ]);
	}
	else if(IsPlayerInAnyVehicle(playerid))
	{
		new 
			vehicleid = GetPlayerVehicleID(playerid)
		;
		
		if(VehicleInfo[vehicleid][eVehicleFaction] && FactionInfo[VehicleInfo[vehicleid][eVehicleFaction]][eFactionType] != FACTION_TYPE_ILLEGAL)
			return SendClientMessage(playerid, COLOR_YELLOW, "You don't have access to this vehicle.");
			
		if(GetVehicleTrunkWeps(vehicleid) == MAX_WEP_SLOT-1) return SendClientMessage(playerid, COLOR_LIGHTRED, "This vehicle is full.");

		new
			slot = GetNextVehicleTrunkSlot(vehicleid),
            insert[128]
			;

		mysql_format(this, insert, sizeof(insert), "INSERT INTO vehicle_trunk (weapon, ammo, vehicle) VALUES(%i, %i, %i)",
		PlayerInfo[playerid][pWeaponsAmmo][ ReturnWeaponIDSlot(weaponid) ], PlayerInfo[playerid][pWeapons][ ReturnWeaponIDSlot(weaponid) ], vehicleid);
		mysql_tquery(this, insert, "AddWeaponToTrunk", "iiiii", playerid, vehicleid, slot, PlayerInfo[playerid][pWeapons][ ReturnWeaponIDSlot(weaponid) ], PlayerInfo[playerid][pWeaponsAmmo][ ReturnWeaponIDSlot(weaponid) ]);
	}
	else if(IsPlayerInProperty(playerid))
	{
		new
			id = IsPlayerInProperty(playerid),
			pid
		;
		
		if(!IsPlayerInRangeOfPoint(playerid, 3.0, PropertyInfo[id][ePropertyPlacePos][0], PropertyInfo[id][ePropertyPlacePos][1], PropertyInfo[id][ePropertyPlacePos][2]))
			return SendErrorMessage(playerid, "You aren't near this properties place position.");
			
		for(new i = 1; i < 21; i++)
		{
			if(!PropertyInfo[id][ePropertyWeapons][i])
			{
				pid = i;
				break;
			}
		}
		
		PropertyInfo[id][ePropertyWeapons][pid] = weaponid;
		PropertyInfo[id][ePropertyWeaponsAmmo][pid] = PlayerInfo[playerid][pWeaponsAmmo][ReturnWeaponIDSlot(weaponid)];
		
		PlayerInfo[playerid][pWeaponsAmmo][ReturnWeaponIDSlot(weaponid)] = 0;
		PlayerInfo[playerid][pWeapons][ReturnWeaponIDSlot(weaponid)] = 0;
		
		RemovePlayerWeapon(playerid, weaponid);
		
		format(str, sizeof(str), "* %s placed a %s in the house.", ReturnName(playerid, 0), ReturnWeaponName(weaponid));
		SetPlayerChatBubble(playerid, str, COLOR_EMOTE, 20.0, 4000); 
		SendClientMessage(playerid, COLOR_EMOTE, str);
	}
	return 1;
}

//Property commands:
CMD:buyproperty(playerid, params[])
{
	new
		bool:nearProperty = false,
		id,
		str[128]
	;
	for(new i = 1; i < MAX_PROPERTY; i++)
	{
		if(!PropertyInfo[i][ePropertyDBID])
			continue;

		if(IsPlayerInRangeOfPoint(playerid, 3.0, PropertyInfo[i][ePropertyEntrance][0], PropertyInfo[i][ePropertyEntrance][1], PropertyInfo[i][ePropertyEntrance][2]))
		{
			nearProperty = true;
			id = i;
			break;
		}
	}

	if(nearProperty)
	{
		if(PropertyInfo[id][ePropertyOwnerDBID])
			return SendErrorMessage(playerid, "This property isn't for sale.");

		if(PropertyInfo[id][ePropertyMarketPrice] > PlayerInfo[playerid][pMoney])
			return SendErrorMessage(playerid, "You can't afford to buy this property.");

		if(CountPlayerProperties(playerid) > 3)
			return SendErrorMessage(playerid, "You already own 3 properties.");

		GiveMoney(playerid, -PropertyInfo[id][ePropertyMarketPrice]);
		PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);

		format(str, sizeof(str), "Congratulations!~n~You're now the owner of this property! $%d", PropertyInfo[id][ePropertyMarketPrice]);
		GameTextForPlayer(playerid, str, 4000, 5);

		PropertyInfo[id][ePropertyOwnerDBID] = PlayerInfo[playerid][pDBID];
		SaveCharacter(playerid); SaveProperty(id);
	}
	else
	{
	    SendErrorMessage(playerid, "You aren't near a property.");
	    return 1;
	}
	return 1; 
}

CMD:lock(playerid, params[])
{
	new
		id,
		sub_cmd[64],
		b_id
	;
	if(sscanf(params, "s[64]", sub_cmd))
	{
		if((id = IsPlayerNearProperty(playerid)) != 0)
		{
			if(PlayerInfo[playerid][pDBID] != PropertyInfo[id][ePropertyOwnerDBID] || PlayerInfo[playerid][pRentAt] != PropertyInfo[id][ePropertyDBID])
				return SendErrorMessage(playerid, "You don't have the keys to this property.");

			if(!PropertyInfo[id][ePropertyLocked])
			{
				GameTextForPlayer(playerid, "~w~DOOR ~r~LOCKED", 1000, 6);
				PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);

				PropertyInfo[id][ePropertyLocked] = true;
			}
			else
			{
				GameTextForPlayer(playerid, "~w~DOOR ~g~UNLOCKED", 1000, 6);
				PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);

				PropertyInfo[id][ePropertyLocked] = false;
			}
		}
		else if((id = IsPlayerInProperty(playerid)) != 0)
		{
			if(PlayerInfo[playerid][pDBID] != PropertyInfo[id][ePropertyOwnerDBID] || PlayerInfo[playerid][pRentAt] != PropertyInfo[id][ePropertyDBID])
				return SendErrorMessage(playerid, "You don't have the keys to this property.");

			if(!IsPlayerInRangeOfPoint(playerid, 3.0, PropertyInfo[id][ePropertyInterior][0], PropertyInfo[id][ePropertyInterior][1], PropertyInfo[id][ePropertyInterior][2]))
				return SendErrorMessage(playerid, "You aren't near your properties door.");

			if(!PropertyInfo[id][ePropertyLocked])
			{
				GameTextForPlayer(playerid, "~w~DOOR ~r~LOCKED", 1000, 4);
				PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);

				PropertyInfo[id][ePropertyLocked] = true;
			}
			else
			{
				GameTextForPlayer(playerid, "~w~DOOR ~g~UNLOCKED", 1000, 4);
				PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);

				PropertyInfo[id][ePropertyLocked] = false;
			}
		}

		if((b_id = IsPlayerNearBusiness(playerid)) != 0)
		{
			if(BusinessInfo[b_id][eBusinessOwnerDBID] != PlayerInfo[playerid][pDBID])
				return SendErrorMessage(playerid, "You don't have the keys to this business.");

			if(!BusinessInfo[b_id][eBusinessLocked])
			{
				GameTextForPlayer(playerid, "~w~DOOR ~r~LOCKED", 1000, 4);
				PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);

				BusinessInfo[b_id][eBusinessLocked] = true;
			}
			else
			{
				GameTextForPlayer(playerid, "~w~DOOR ~g~UNLOCKED", 1000, 4);
				PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);

				BusinessInfo[b_id][eBusinessLocked] = false;
			}
		}
		else if((b_id = IsPlayerInBusiness(playerid)) != 0)
		{
			if(!IsPlayerInRangeOfPoint(playerid, 3.0, BusinessInfo[b_id][eBusinessInterior][0], BusinessInfo[b_id][eBusinessInterior][1], BusinessInfo[b_id][eBusinessInterior][2]))
				return SendErrorMessage(playerid, "You aren't near the door.");

			if(BusinessInfo[b_id][eBusinessOwnerDBID] != PlayerInfo[playerid][pDBID])
				return SendErrorMessage(playerid, "You don't have the keys to this business.");

			if(!BusinessInfo[b_id][eBusinessLocked])
			{
				GameTextForPlayer(playerid, "~w~DOOR ~r~LOCKED", 1000, 4);
				PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);

				BusinessInfo[b_id][eBusinessLocked] = true;
			}
			else
			{
				GameTextForPlayer(playerid, "~w~DOOR ~g~UNLOCKED", 1000, 4);
				PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);

				BusinessInfo[b_id][eBusinessLocked] = false;
			}
		}
		return 1;
	}

	if(!strcmp(sub_cmd, "breakin", true, 7))
	{
		new bool:foundCar = false, vehicleid, Float:fetchPos[3];

		for (new i = 0; i < MAX_VEHICLES; i++)
		{
			GetVehiclePos(i, fetchPos[0], fetchPos[1], fetchPos[2]);
			if(IsPlayerInRangeOfPoint(playerid, 4.0, fetchPos[0], fetchPos[1], fetchPos[2]))
			{
				foundCar = true;
				vehicleid = i;
				break;
			}
		}
		if(foundCar == true)
		{
			if(VehicleInfo[vehicleid][eVehicleOwnerDBID] == PlayerInfo[playerid][pDBID] && PlayerInfo[playerid][pDuplicateKey] == vehicleid)
				return SendErrorMessage(playerid, "It's your car, dummie...");

			new Float:cX, Float:cY, Float:cZ;
			new Float:dX, Float:dY, Float:dZ;

			GetVehicleModelInfo(VehicleInfo[vehicleid][eVehicleModel], VEHICLE_MODEL_INFO_FRONTSEAT, cX, cY, cZ);
			GetVehicleRelativePos(vehicleid, dX, dY, dZ, -cX - 0.5, cY, cZ);
			if(!IsPlayerInRangeOfPoint(playerid, 1.2, dX, dY, dZ)) return SendErrorMessage(playerid, "You are not near the front door! (driver door)");
			if(!VehicleInfo[vehicleid][eVehicleLocked]) return SendErrorMessage(playerid, "Doors are opened!");
			if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) return SendErrorMessage(playerid, "You must be on foot.");
			if(GetPVarInt(playerid, "Picklock") != INVALID_VEHICLE_ID) return SendErrorMessage(playerid, "You are in prying.");
			if(VehicleInfo[vehicleid][ePhysicalAttack] && VehicleInfo[vehicleid][eDoorHealth] > 0)
			{
	            new doorhealth[12];
	            format(doorhealth, 12, "%d", VehicleInfo[vehicleid][eDoorHealth]);
                VehicleInfo[vehicleid][ePhysicalAttack] = true;
	            sendMessage(playerid, -1, "-%s", ReturnWeaponName(GetPlayerWeapon(playerid)));
	            sendMessage(playerid, -1, "-%s", ReturnWeaponType(GetPlayerWeapon(playerid)));
	            SetPVarInt(playerid, "Breakin_ID", vehicleid);
	            if(!IsValidDynamic3DTextLabel(VehicleInfo[vehicleid][eVehicleLabel]))
				{
				    VehicleInfo[vehicleid][eVehicleLabel] = CreateDynamic3DTextLabel(doorhealth, COLOR_WHITE, 0.0, 0.0, 0.0, 15.0, vehicleid, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), playerid);
				}
			    return 1;
			}
			if(VehicleInfo[vehicleid][eVehicleFaction] > 0 || VehicleInfo[vehicleid][eVehicleAdminSpawn]) return SendClientMessage(playerid, -1, "This is not a private vehicle.");
			switch(VehicleInfo[vehicleid][eVehicleLockLevel])
			{
				case 0: VehicleInfo[vehicleid][eDoorHealth] = 25, VehicleInfo[vehicleid][eDoorEffect] = BLOCK_NONE;
				case 1: VehicleInfo[vehicleid][eDoorHealth] = 50, VehicleInfo[vehicleid][eDoorEffect] = LESS_DAMAGE_FIST;
				case 2: VehicleInfo[vehicleid][eDoorHealth] = 75, VehicleInfo[vehicleid][eDoorEffect] = BLOCK_FIST;
				case 3: VehicleInfo[vehicleid][eDoorHealth] = 150, VehicleInfo[vehicleid][eDoorEffect] = LESS_DAMAGE_MELEE;
				case 4: VehicleInfo[vehicleid][eDoorHealth] = 200, VehicleInfo[vehicleid][eDoorEffect] = BLOCK_PHYSICAL;
			}
			new playerLocation[MAX_ZONE_NAME];
			GetPlayer2DZone(playerid, playerLocation, MAX_ZONE_NAME);
			
            VehicleInfo[vehicleid][ePhysicalAttack] = true;
            TriggerAlarm(vehicleid, playerLocation, VehicleInfo[vehicleid][eVehicleAlarmLevel]);
            SendClientMessage(playerid, -1, "You can start beating down the driver door now! Break-in Methods:");
            sendMessage(playerid, -1, "-%s", ReturnWeaponName(GetPlayerWeapon(playerid)));
            sendMessage(playerid, -1, "-%s", ReturnWeaponType(GetPlayerWeapon(playerid)));
            SetPVarInt(playerid, "Breakin_ID", vehicleid);
            new doorhealth[12];
            format(doorhealth, 12, "%d", VehicleInfo[vehicleid][eDoorHealth]);
            VehicleInfo[vehicleid][eVehicleLabel] = CreateDynamic3DTextLabel(doorhealth, COLOR_WHITE, 0.0, 0.0, 0.0, 15.0, vehicleid, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), playerid);
		}
		else SendServerMessage(playerid, "You aren't near a vehicle OR the vehicle isn't synced.");
		return true;
	}
	else if(!strcmp(sub_cmd, "pry", true, 3))
	{
		new bool:foundCar = false, vehicleid, Float:fetchPos[3];

		for (new i = 0; i < MAX_VEHICLES; i++)
		{
			GetVehiclePos(i, fetchPos[0], fetchPos[1], fetchPos[2]);
			if(IsPlayerInRangeOfPoint(playerid, 4.0, fetchPos[0], fetchPos[1], fetchPos[2]))
			{
				foundCar = true;
				vehicleid = i;
				break;
			}
		}
		if(foundCar == true)
		{
			if(VehicleInfo[vehicleid][eVehicleOwnerDBID] == PlayerInfo[playerid][pDBID] && PlayerInfo[playerid][pDuplicateKey] == vehicleid) return SendErrorMessage(playerid, "It's your car, dummie...");
			new Float:cX, Float:cY, Float:cZ;
			new Float:dX, Float:dY, Float:dZ;
			GetVehicleModelInfo(VehicleInfo[vehicleid][eVehicleModel], VEHICLE_MODEL_INFO_FRONTSEAT, cX, cY, cZ);
			GetVehicleRelativePos(vehicleid, dX, dY, dZ, -cX - 0.5, cY, cZ);
			if(!IsPlayerInRangeOfPoint(playerid, 1.2, dX, dY, dZ)) return SendErrorMessage(playerid, "You are not near the front door! (driver door)");
			if(!VehicleInfo[vehicleid][eVehicleLocked]) return SendErrorMessage(playerid, "Doors are opened!");
			if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) return SendErrorMessage(playerid, "You must be on foot.");
			if(VehicleInfo[vehicleid][ePhysicalAttack]) return SendErrorMessage(playerid, "This vehicle is on physical attack breaching.");
			if(GetPVarInt(playerid, "Picklock") != INVALID_VEHICLE_ID) return SendErrorMessage(playerid, "You are in prying.");
			if(GetPlayerSpecialAction(playerid) != SPECIAL_ACTION_DUCK) return SendErrorMessage(playerid, "You must be crouch.");
			// you don't have a screwdriver, wrench bar etc.... do it here~
			SetPVarInt(playerid, "PryTime", (1+VehicleInfo[vehicleid][eVehicleLockLevel]) * 250);
			SetPVarInt(playerid, "Picklock", vehicleid);
			new time[32];
			format(time, 32, "~g~%d~w~SECONDS_REMAIN.", GetPVarInt(playerid, "PryTime"));
			ShowInfoEx(playerid, "~w~PRYING_THE_DOOR_OPEN", time);
			
		}
		else return SendServerMessage(playerid, "You aren't near a vehicle OR the vehicle isn't synced.");
	}
	return 1;
}

stock TriggerAlarm(vehicleid, street[], level)
{
	static notify[128];
	switch(level)
	{
	    case 1:
		{
		    ToggleVehicleAlarms(vehicleid, true, 60000);
		}
		case 2:
		{
		    NotifyVehicleOwner(vehicleid);
		    ToggleVehicleAlarms(vehicleid, true, 120000);
		}
		case 3:
		{
		    NotifyVehicleOwner(vehicleid);
		    ToggleVehicleAlarms(vehicleid, true, 180000);

			foreach(new i : Player) if(PlayerInfo[i][pPoliceDuty])
			{
				format(notify, 128, "* [Vehicle alarm] %s located in %s", ReturnVehicleName(vehicleid), street);
				SendClientMessage(i, COLOR_LIGHTRED, notify);
			}
		}
		case 4:
		{
		    NotifyVehicleOwner(vehicleid);
		    ToggleVehicleAlarms(vehicleid, true, 240000);
			new Float: address[3];
			GetVehiclePos(vehicleid, address[0], address[1], address[2]);
			foreach(new i : Player) if(PlayerInfo[i][pPoliceDuty])
			{
				format(notify, 128, "* [Vehicle alarm] %s located in %s", ReturnVehicleName(vehicleid), street);
				SendClientMessage(i, COLOR_LIGHTRED, notify);
			}
		}
	}
	return 1;
}


CMD:placepos(playerid, params[])
{
	new
		id
	;
	
	if((id = IsPlayerInProperty(playerid)) != 0)
	{
		if(PlayerInfo[playerid][pDBID] != PropertyInfo[id][ePropertyOwnerDBID])
			return SendErrorMessage(playerid, "You don't own this house.");

		if(!GetPVarInt(playerid, "AllowPlace")) return SendErrorMessage(playerid, "You need a permission from administrators.");
		GetPlayerPos(playerid, PropertyInfo[id][ePropertyPlacePos][0], PropertyInfo[id][ePropertyPlacePos][1], PropertyInfo[id][ePropertyPlacePos][2]); 
		SendServerMessage(playerid, "You changed your properties place position."); 
		DeletePVar(playerid, "AllowPlace");
	}
	else return SendErrorMessage(playerid, "You aren't in a property.");
	
	return 1;
}

CMD:allowplace(playerid, params[])
{
	if(!PlayerInfo[playerid][pAdmin]) return SendErrorMessage(playerid, "No permission.");
	new id;
	if(sscanf(params, "d", id))
	{
		SendClientMessage(playerid, COLOR_RED, "USAGE: /allowplace [player id OR player name]");
		return 1;
	}
	if(!IsPlayerConnected(id)) return SendErrorMessage(playerid, "This player is not connected.");
	SetPVarInt(id, "AllowPlace", 1);
	SendAdminMessageEx(1, COLOR_YELLOWEX, "AdmWarn[%i]: %s has just given %s the permission to set their property entrance.", playerid, ReturnName(playerid), id, ReturnName(id));
	return 1;
}

CMD:setrent(playerid, params[])
{
	new id;
	if(!CountPlayerProperties(playerid))
		return SendErrorMessage(playerid, "You don't own a property.");

	if((id = IsPlayerInProperty(playerid)) == 0)
		return SendErrorMessage(playerid, "You aren't inside your property.");

	if(PropertyInfo[id][ePropertyOwnerDBID] != PlayerInfo[playerid][pDBID])
		return SendErrorMessage(playerid, "You don't own this property.");

	PropertyInfo[id][ePropertyRentAble] = !PropertyInfo[id][ePropertyRentAble];
	sendMessage(playerid, COLOR_YELLOWEX, "Property Rent: %s", (PropertyInfo[id][ePropertyRentAble] == true) ? ("Yes") : ("No"));
	
	return 1;
}

CMD:bareswitch(playerid, params[])
{
	new id = IsPlayerInProperty(playerid);
	if(!PropertyInfo[id][ePropertyBareSwitch])
	{
	    SetPlayerPos(playerid, -42.4361,1405.8180,1084.4297);
		SetPlayerInterior(playerid, 8);

		GetPlayerPos(playerid, PropertyInfo[id][ePropertyInterior][0], PropertyInfo[id][ePropertyInterior][1], PropertyInfo[id][ePropertyInterior][2]);

		PropertyInfo[id][ePropertyInteriorIntID] = GetPlayerInterior(playerid);

        PropertyInfo[id][ePropertyBareSwitch] = true;
	
	}
	else
	{
	    PropertyInfo[id][ePropertyBareSwitch] = false;
	    SetPlayerPos(playerid, -48.4335, 1458.4772, 1085.6138);
		SetPlayerInterior(playerid, 0);

		GetPlayerPos(playerid, PropertyInfo[id][ePropertyInterior][0], PropertyInfo[id][ePropertyInterior][1], PropertyInfo[id][ePropertyInterior][2]);
		PropertyInfo[id][ePropertyInteriorIntID] = GetPlayerInterior(playerid);
	}
	return 1;
}

CMD:rentfee(playerid, params[])
{
    new id, amount;
	if(sscanf(params, "d", amount))
	{
		SendUsageMessage(playerid, "/rentfee [amount]");
		return 1;
	}
	if(!CountPlayerProperties(playerid))
		return SendErrorMessage(playerid, "You don't own a property.");

	if((id = IsPlayerInProperty(playerid)) == 0)
		return SendErrorMessage(playerid, "You aren't inside your property.");

	if(PropertyInfo[id][ePropertyOwnerDBID] != PlayerInfo[playerid][pDBID])
		return SendErrorMessage(playerid, "You don't own this property.");

	if(amount > 10000 || amount < 0) return SendErrorMessage(playerid, "Rent price should be 0-10000.");

	PropertyInfo[id][ePropertyRentAble] = !PropertyInfo[id][ePropertyRentAble];
	sendMessage(playerid, COLOR_YELLOWEX, "Rent fee has been set to %s", amount);
	return 1;
}

CMD:rentroom(playerid, params[])
{
    new id;

	if((id = IsPlayerNearProperty(playerid)) == 0)
		return SendErrorMessage(playerid, "You aren't near any properties.");

	if(PropertyInfo[id][ePropertyOwnerDBID] == PlayerInfo[playerid][pDBID])
		return SendErrorMessage(playerid, "This is your property..");
		
	if(!PropertyInfo[id][ePropertyRentAble])
		return SendErrorMessage(playerid, "This property is not rentable..");
		
	PlayerInfo[playerid][pRentAt] = id;
	sendMessage(playerid, -1, "You have rent this house.");
	return 1;
}

CMD:unrent(playerid, params[])
{
	PlayerInfo[playerid][pRentAt] = 0;
	sendMessage(playerid, -1, "You are now homeless.");
	return 1;
}

CMD:property(playerid, params[])
{
	if(!CountPlayerProperties(playerid))
		return SendErrorMessage(playerid, "You don't own a property."); 
		
	new id, str[90], bstr[90], cstr[60];
	
	if((id = IsPlayerInProperty(playerid)) == 0)
		return SendErrorMessage(playerid, "You aren't inside your property.");
		
	if(PropertyInfo[id][ePropertyOwnerDBID] != PlayerInfo[playerid][pDBID])
		return SendErrorMessage(playerid, "You don't own this property."); 
		
	if(sscanf(params, "s[90]S()[90]S()[60]", str, bstr, cstr))
	{
		SendClientMessage(playerid, COLOR_RED, "____________________________________________________");
		SendUsageMessage(playerid, "/property [action]");
		SendClientMessage(playerid, COLOR_RED, "[Actions] info, cashbox");
		SendClientMessage(playerid, COLOR_RED, "____________________________________________________");
		return 1;
	}
	
	if(!strcmp(str, "info"))
	{
		new type[30];
		
		if(PropertyInfo[id][ePropertyType] == PROPERTY_TYPE_HOUSE)
			type = "House";
		
		else if(PropertyInfo[id][ePropertyType] == PROPERTY_TYPE_APTROOM)
			type = "Apartment Room";
			
		else if(PropertyInfo[id][ePropertyType] == PROPERTY_TYPE_APTCOMPLEX)
			type = "Apartment Complex"; 
	
		sendMessage(playerid, COLOR_WHITE, "ID:[%i], Price:[$%s], Level:[%i], Type:[%s]", PropertyInfo[id][ePropertyDBID], MoneyFormat(PropertyInfo[id][ePropertyMarketPrice]), PropertyInfo[id][ePropertyLevel], type);
	}
	else if(!strcmp(str, "cashbox"))
	{
		new pick[30], amount;
		
		if(sscanf(bstr, "s[30]", pick))
			return SendUsageMessage(playerid, "/property cashbox [Info, Place, Take]"); 
			
		if(!strcmp(pick, "info"))
		{
			sendMessage(playerid, COLOR_ACTION, "You have $%s inside your houses' cashbox.", MoneyFormat(PropertyInfo[id][ePropertyCashbox]));
		}
		else if(!strcmp(pick, "place"))
		{	
			if(sscanf(cstr, "i", amount))
				return SendUsageMessage(playerid, "/property cashbox place [amount]"); 
				
			if(amount > PlayerInfo[playerid][pMoney])
				return SendErrorMessage(playerid, "You don't have that amount on you.");
				
			GiveMoney(playerid, -amount);
			PropertyInfo[id][ePropertyCashbox]+= amount; 
			
			SendServerMessage(playerid, "You added $%s to your cashbox.", amount); 
			SaveProperty(id);
		}
		else if(!strcmp(pick, "take"))
		{
			if(sscanf(cstr, "i", amount))
				return SendUsageMessage(playerid, "/property cashbox take [amount]");
				
			if(amount > PropertyInfo[id][ePropertyCashbox])
				return SendErrorMessage(playerid, "Your cashbox doesn't have that much.");
				
			GiveMoney(playerid, amount);
			PropertyInfo[id][ePropertyCashbox]-= amount;
			
			SendServerMessage(playerid, "You took $%s from your cashbox.", amount); 
			SaveProperty(id); 
		}
		else return SendErrorMessage(playerid, "Invalid Paramater."); 
	}
	else return SendErrorMessage(playerid, "Invalid Paramater.");
	return 1;
}

//Emote commands:
CMD:me(playerid, params[])
{
	if (isnull(params)) 
		return SendUsageMessage(playerid, "/me [emote]");

	if(strlen(params) > 86)
	{
		SendNearbyMessage(playerid, 20.0, COLOR_EMOTE, "* %s %.86s", ReturnName(playerid, 0), params); 
		SendNearbyMessage(playerid, 20.0, COLOR_EMOTE, "* %s ...%s", ReturnName(playerid, 0), params[86]);
	}
	else SendNearbyMessage(playerid, 20.0, COLOR_EMOTE, "* %s %s", ReturnName(playerid, 0), params);
		
	return 1; 
}

CMD:do(playerid, params[])
{
	if (isnull(params)) 
		return SendUsageMessage(playerid, "/do [emote]");

	if(strlen(params) > 86)
	{
		SendNearbyMessage(playerid, 20.0, COLOR_EMOTE, "* %.86s", params); 
		SendNearbyMessage(playerid, 20.0, COLOR_EMOTE, "* %s (( %s ))", params[86], ReturnName(playerid, 0));
	}
	else SendNearbyMessage(playerid, 20.0, COLOR_EMOTE, "* %s (( %s ))", params, ReturnName(playerid, 0));
		
	return 1; 
}

CMD:ame(playerid, params[])
{
	if (isnull(params))
		return SendUsageMessage(playerid, "/ame [emote]");

	new str[128]; 
	
	format (str, sizeof(str), "> %s %s", ReturnName(playerid, 0), params);
	SetPlayerChatBubble(playerid, str, COLOR_EMOTE, 20.0, 4000);
	
	sendMessage(playerid, COLOR_EMOTE, "* %s %s", ReturnName(playerid, 0), params);
	return 1;
}

CMD:my(playerid, params[])
{
	if (isnull(params)) 
		return SendUsageMessage(playerid, "/my [emote]");
		
	new playerName[MAX_PLAYER_NAME], bool:hasEnding = false, idx; 
	
	format(playerName, sizeof(playerName), "%s", ReturnName(playerid, 0)); 
	idx = strlen(playerName);
	
	if(playerName[idx-1] == 's' || playerName[idx-1] == 's')
	{
		hasEnding = true; 
	}
	
	if(hasEnding == true)
	{
		if(strlen(params) > 86)
		{
			SendNearbyMessage(playerid, 20.0, COLOR_EMOTE, "* %s' %.86s", ReturnName(playerid, 0), params); 
			SendNearbyMessage(playerid, 20.0, COLOR_EMOTE, "* %s' ...%s", ReturnName(playerid, 0), params[86]);
		}
		else SendNearbyMessage(playerid, 20.0, COLOR_EMOTE, "* %s' %s", ReturnName(playerid, 0), params);
	}
	else
	{
		if(strlen(params) > 86)
		{
			SendNearbyMessage(playerid, 20.0, COLOR_EMOTE, "* %s's %.86s", ReturnName(playerid, 0), params); 
			SendNearbyMessage(playerid, 20.0, COLOR_EMOTE, "* %s's ...%s", ReturnName(playerid, 0), params[86]);
		}
		else SendNearbyMessage(playerid, 20.0, COLOR_EMOTE, "* %s's %s", ReturnName(playerid, 0), params);
	}
		
	return 1; 
}

CMD:amy(playerid, params[])
{
	if (isnull(params))
		return SendUsageMessage(playerid, "/amy [emote]");

	new str[128], playerName[MAX_PLAYER_NAME], bool:hasEnding = false, idx; 
	
	format(playerName, sizeof(playerName), "%s", ReturnName(playerid, 0)); 
	idx = strlen(playerName);
	
	if(playerName[idx-1] == 's' || playerName[idx-1] == 's')
	{
		hasEnding = true; 
	}
	
	if(hasEnding == true)
	{
		format (str, sizeof(str), "> %s' %s", ReturnName(playerid, 0), params);
		SetPlayerChatBubble(playerid, str, COLOR_EMOTE, 20.0, 4000);
		
		sendMessage(playerid, COLOR_EMOTE, "* %s' %s", ReturnName(playerid, 0), params);
	}
	else
	{
		format (str, sizeof(str), "> %s's %s", ReturnName(playerid, 0), params);
		SetPlayerChatBubble(playerid, str, COLOR_EMOTE, 20.0, 4000);
		
		sendMessage(playerid, COLOR_EMOTE, "* %s's %s", ReturnName(playerid, 0), params);
	}
	return 1;
}

alias:shout("s", "yell", "scream");
CMD:shout(playerid, params[])
{
	if (isnull(params))
		return SendUsageMessage(playerid, "/shout [text]"); 
		
	if(GetPlayerTeam(playerid) != PLAYER_STATE_ALIVE)
		return SendErrorMessage(playerid, "You can't shout right now.");
		
	new bool:isCaps = false;
	
	for( new i, j = strlen( params )-1; i < j; i ++ )
    {
        if( ( 'A' <= params[ i ] <= 'Z' ) && ( 'A' <= params[ i+1 ] <= 'Z' ) )
            isCaps = true; 
    }
	
	if(isCaps == true)
	{
		if(strlen(params) > 84)
		{
			SendNearbyMessage(playerid, 30.0, COLOR_WHITE, "%s screams: %.84s", ReturnName(playerid, 0), params);
			SendNearbyMessage(playerid, 30.0, COLOR_WHITE, "%s screams: ...%s", params[84]);
		}
		else SendNearbyMessage(playerid, 30.0, COLOR_WHITE, "%s screams: %s", ReturnName(playerid, 0), params);
	}
	else
	{
		if(strlen(params) > 84)
		{
			SendNearbyMessage(playerid, 20.0, COLOR_WHITE, "%s shouts: %.84s", ReturnName(playerid, 0), params);
			SendNearbyMessage(playerid, 20.0, COLOR_WHITE, "%s shouts: ...%s", params[84]);
		}
		else SendNearbyMessage(playerid, 20.0, COLOR_WHITE, "%s shouts: %s", ReturnName(playerid, 0), params);
	}
	return 1;
}

CMD:low(playerid, params[])
{
	if(GetPlayerTeam(playerid) == PLAYER_STATE_DEAD)
		return SendErrorMessage(playerid, "You can't when you aren't alive.");
	
	if(isnull(params))
		return SendUsageMessage(playerid, "/low [text]");
		
	new
		str[128]
	; 
		
	if(strlen(params) > 84)
	{
		format(str, sizeof(str), "%s says[low]: %.84s", ReturnName(playerid, 0), params);
		LocalChat(playerid, 6.0, str, COLOR_FADE5, COLOR_FADE4, COLOR_FADE3, COLOR_FADE3); 
		
		format(str, sizeof(str), "%s says[low]: ... %s", ReturnName(playerid, 0), params[84]); 
		LocalChat(playerid, 6.0, str, COLOR_FADE5, COLOR_FADE4, COLOR_FADE3, COLOR_FADE3); 
	}
	else
	{
		format(str, sizeof(str), "%s says[low]: %s", ReturnName(playerid, 0), params); 
		LocalChat(playerid, 6.0, str, COLOR_FADE5, COLOR_FADE4, COLOR_FADE3, COLOR_FADE3); 
	}
		
	return 1;
}

CMD:b(playerid, params[])
{
	if (isnull(params))
		return SendUsageMessage(playerid, "/b [text]"); 
	
	if(PlayerInfo[playerid][pAdminDuty] == true)
	{
		if(strlen(params) > 84)
		{
			SendNearbyMessage(playerid, 20.0, COLOR_GREY, "(( [%d] {FF9900}%s{AFAFAF}: %.84s ))", playerid, ReturnName(playerid), params);
			SendNearbyMessage(playerid, 20.0, COLOR_GREY, "(( [%d] {FF9900}%s{AFAFAF}: ...%s ))", playerid, ReturnName(playerid), params[84]);
		}
		else SendNearbyMessage(playerid, 20.0, COLOR_GREY, "(( [%d] {FF9900}%s{AFAFAF}: %s ))", playerid, ReturnName(playerid), params);
	}
	else
	{
		if(strlen(params) > 84)
		{
			SendNearbyMessage(playerid, 20.0, COLOR_GREY, "(( [%d] %s: %.84s ))", playerid, ReturnName(playerid), params);
			SendNearbyMessage(playerid, 20.0, COLOR_GREY, "(( [%d] %s: ...%s ))", playerid, ReturnName(playerid), params[84]); 
		}
		else SendNearbyMessage(playerid, 20.0, COLOR_GREY, "(( [%d] %s: %s ))", playerid, ReturnName(playerid), params);
	}	
	return 1;
}

CMD:pm(playerid, params[])
{
	new
		playerb,
		text[144]
	;
		
	if(sscanf(params, "us[144]", playerb, text))
		return SendUsageMessage(playerid, "/pm [playerid OR name] [text]");
		
	if(!IsPlayerConnected(playerb))
		return SendErrorMessage(playerid, "The player you specified isn't connected.");
		
	if(PlayerInfo[playerid][pAdminDuty])
	{
		sendMessage(playerb, COLOR_PMRECEIVED, "(( PM from {FF9900}%s{FFDC18} (ID: %d): %s ))", ReturnName(playerid), playerid, text);
		
		if(!PlayerInfo[playerb][pAdminDuty])
			sendMessage(playerid, COLOR_PMSENT, "(( PM sent to %s (ID: %d): %s ))", ReturnName(playerb), playerb, text);
			
		else sendMessage(playerid, COLOR_PMSENT, "(( PM sent to {FF9900}%s{EEE854} (ID: %d): %s ))", ReturnName(playerb), playerb, text);
	}
	else
	{
		if(PlayerInfo[playerb][pAdminDuty])
		{
			sendMessage(playerb, COLOR_PMRECEIVED, "(( PM from %s (ID: %d): %s ))", ReturnName(playerid), playerid, text);
			sendMessage(playerid, COLOR_PMSENT, "(( PM sent to {FF9900}%s{EEE854} (ID: %d): %s ))", ReturnName(playerb), playerb, text);
		}
		else
		{
			sendMessage(playerb, COLOR_PMRECEIVED, "(( PM from %s (ID: %d): %s ))", ReturnName(playerid), playerid, text);
			sendMessage(playerid, COLOR_PMSENT, "(( PM sent to %s (ID: %d): %s ))", ReturnName(playerb), playerb, text);
		}
	}
	return 1;
}

//Business commands:
CMD:buybiz(playerid, params[])
{
	new
		id
	; 
	
	if((id = IsPlayerNearBusiness(playerid)) != 0)
	{
		if(CountPlayerBusiness(playerid) == 1)
			return SendErrorMessage(playerid, "You can't own more than 1 business."); 
			
		if(BusinessInfo[id][eBusinessOwnerDBID])
			return SendErrorMessage(playerid, "This business isn't for sale."); 
			
		if(PlayerInfo[playerid][pLevel] < BusinessInfo[id][eBusinessLevel])
			return SendErrorMessage(playerid, "You need to be level %i to buy this.", BusinessInfo[id][eBusinessLevel]);
			
		if(PlayerInfo[playerid][pMoney] < BusinessInfo[id][eBusinessMarketPrice])
			return SendErrorMessage(playerid, "You can't afford this business."); 
			
		PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
		GameTextForPlayer(playerid, "Congratulations!~n~You're now the owner of this business!", 4000, 5);
		
		sendMessage(playerid, COLOR_ACTION, "You purchased the %s for $%s!", BusinessInfo[id][eBusinessName], MoneyFormat(BusinessInfo[id][eBusinessMarketPrice]));
		
		BusinessInfo[id][eBusinessOwnerDBID] = PlayerInfo[playerid][pDBID]; 
		GiveMoney(playerid, -BusinessInfo[id][eBusinessMarketPrice]); 
		
		if(BusinessInfo[id][eBusinessType] == BUSINESS_TYPE_RESTAURANT)
		{
			DestroyDynamicPickup(BusinessInfo[id][eBusinessPickup]); 
			BusinessInfo[id][eBusinessPickup] = CreateDynamicPickup(1239, 14, BusinessInfo[id][eBusinessEntrance][0], BusinessInfo[id][eBusinessEntrance][1], BusinessInfo[id][eBusinessEntrance][2], 0); 
		}
		
		SaveBusiness(id); SaveCharacter(playerid); 
	}
	else return SendErrorMessage(playerid, "You aren't near a business.");

	return 1;
}

CMD:bizinfo(playerid, params[])
{
	if(!CountPlayerBusiness(playerid))
		return SendErrorMessage(playerid, "You don't own a business.");
		
	new
		id
	;
	
	if((id = IsPlayerInBusiness(playerid)) != 0)
	{
		if(BusinessInfo[id][eBusinessOwnerDBID] != PlayerInfo[playerid][pDBID])
			return SendErrorMessage(playerid, "You don't own this business."); 
			
		SendClientMessage(playerid, COLOR_DARKGREEN, "____________________________________________");
		
		sendMessage(playerid, COLOR_DARKGREEN, "*** %s ***", BusinessInfo[id][eBusinessName]);
		
		sendMessage(playerid, COLOR_WHITE, "Owner:[%s] Level:[%d] Value:[$%s] Type:[%d] Locked:[%s] ID:[%d]", ReturnName(playerid), BusinessInfo[id][eBusinessLevel], MoneyFormat(BusinessInfo[id][eBusinessMarketPrice]),
			BusinessInfo[id][eBusinessType], (BusinessInfo[id][eBusinessLocked] != true) ? ("No") : ("Yes"), BusinessInfo[id][eBusinessDBID]); 
			
		sendMessage(playerid, COLOR_WHITE, "Cashbox:[$%s] Entrance fee:[$%s] Products:[%d / %d]", MoneyFormat(BusinessInfo[id][eBusinessCashbox]), MoneyFormat(BusinessInfo[id][eBusinessEntranceFee]), BusinessInfo[id][eBusinessProducts], MAX_BUSINESS_PRODUCTS);
		
		SendClientMessage(playerid, COLOR_DARKGREEN, "____________________________________________");
	}
	else return SendErrorMessage(playerid, "You aren't in a business.");

	return 1;
}

CMD:bizfee(playerid, params[])
{
	if(!CountPlayerBusiness(playerid))
		return SendErrorMessage(playerid, "You don't own a business.");
		
	new
		id,
		amount
	;
	
	if((id = IsPlayerInBusiness(playerid)) != 0)
	{
		if(BusinessInfo[id][eBusinessOwnerDBID] != PlayerInfo[playerid][pDBID])
			return SendErrorMessage(playerid, "You don't own this business."); 
			
		if(sscanf(params, "i", amount))
			return SendUsageMessage(playerid, "/bizfee [amount]"); 
			
		if(amount > 1500)
			return SendErrorMessage(playerid, "The amount can't be above $1,500.");
			
		SendServerMessage(playerid, "You set your businesses entrance fee to $%s.", MoneyFormat(amount));
		
		BusinessInfo[id][eBusinessEntranceFee] = amount;
		SaveBusiness(id);
	}
	else return SendErrorMessage(playerid, "You aren't in a business."); 
	return 1;
}

CMD:bizcash(playerid, params[])
{
	if(!CountPlayerBusiness(playerid))
		return SendErrorMessage(playerid, "You don't own a business.");
		
	new
		id,
		amount,
		astr[30],
		bstr[30]
	;
	
	if((id = IsPlayerInBusiness(playerid)) != 0)
	{
		if(BusinessInfo[id][eBusinessOwnerDBID] != PlayerInfo[playerid][pDBID])
			return SendErrorMessage(playerid, "You don't own this business."); 
			
		if(sscanf(params, "s[30]S()[30]", astr, bstr))
			return SendUsageMessage(playerid, "/bizcash [balance, deposit, withdraw]"); 
			
		if(!strcmp(astr, "balance"))
		{
			sendMessage(playerid, COLOR_ACTION, "You have $%s in your businesses cashbox.", MoneyFormat(BusinessInfo[id][eBusinessCashbox]));
		}
		else if(!strcmp(astr, "deposit"))
		{	
			if(sscanf(bstr, "i", amount))
				return SendUsageMessage(playerid, "/bizcash deposit [amount]"); 
				
			if(amount > PlayerInfo[playerid][pMoney])
				return SendErrorMessage(playerid, "You don't have that much money.");
				
			BusinessInfo[id][eBusinessCashbox]+= amount;
			GiveMoney(playerid, -amount);
			
			sendMessage(playerid, COLOR_ACTION, "You deposited $%s into your business. (Total: $%s)", MoneyFormat(amount), MoneyFormat(BusinessInfo[id][eBusinessCashbox]));
			SaveBusiness(id); SaveCharacter(playerid);
		}
		else if(!strcmp(astr, "withdraw"))
		{	
			if(sscanf(bstr, "i", amount))
				return SendUsageMessage(playerid, "/bizcash deposit [amount]"); 
			
			if(amount > BusinessInfo[id][eBusinessCashbox])
				return SendErrorMessage(playerid, "Your business doesn't have that much money.");
				
			BusinessInfo[id][eBusinessCashbox] -= amount; 
			GiveMoney(playerid, amount); 
			
			sendMessage(playerid, COLOR_ACTION, "You withdrew $%s from your business. (Total: $%s)", MoneyFormat(amount), MoneyFormat(BusinessInfo[id][eBusinessCashbox]));
			SaveBusiness(id); SaveCharacter(playerid);
		}
		else return SendErrorMessage(playerid, "Invalid Parameter.");
	}
	else return SendErrorMessage(playerid, "You aren't in a business."); 
	return 1;
}

CMD:sellbiz(playerid, params[])
{
	new
		id,
		str[128]
	;
	
	if(!CountPlayerBusiness(playerid))
		return SendErrorMessage(playerid, "You don't own a business.");
		
	if((id = IsPlayerInBusiness(playerid)) != 0)
	{
		if(BusinessInfo[id][eBusinessOwnerDBID] != PlayerInfo[playerid][pDBID])
			return SendErrorMessage(playerid, "You don't own this business."); 
			
		format(str, sizeof(str), "Are you sure you want to sell your business?\nYou'll earn $%s from selling and $%s from the cashbox.", MoneyFormat(BusinessInfo[id][eBusinessMarketPrice] / 2), MoneyFormat(BusinessInfo[id][eBusinessCashbox]));
		ConfirmDialog(playerid, "Confirmation", str, "OnSellBusiness", id); 
	}
	else return SendErrorMessage(playerid, "You aren't in a business.");
	return 1;
}

//Faction commands:
CMD:factionhelp(playerid, params[])
{
	SendClientMessage(playerid, COLOR_RED, "[FACTION]:{FFFFFF} /factions, /f, /togfam, /nofam, /factionhelp"); 
	
	if(!PlayerInfo[playerid][pFaction])
		return 1;
	
	sendMessage(playerid, COLOR_RED, "%s Commands:", ReturnFactionName(playerid));
		
	if(ReturnFactionType(playerid) == FACTION_TYPE_POLICE)
	{
		SendClientMessage(playerid, COLOR_RED, "[ ! ]{FFFFFF} /duty, /offduty, /handcuff, /unhandcuff, /badge, /uniform, /m(egaphone), /(dep)artment,");
		SendClientMessage(playerid, COLOR_RED, "[ ! ]{FFFFFF} /carsign, /remove_carsign, /taser, /take, /givelicense, /impound, /mdc, /wanted");
		
		if(PlayerInfo[playerid][pFactionRank] <= FactionInfo[PlayerInfo[playerid][pFaction]][eFactionTowRank])
			SendClientMessage(playerid, COLOR_RED, "[ ! ]{FFFFFF} /towcars"); 
	}
	
	if(PlayerInfo[playerid][pFactionRank] <= FactionInfo[PlayerInfo[playerid][pFaction]][eFactionAlterRank])
	{
		SendClientMessage(playerid, COLOR_RED, "Leadership:{FFFFFF} /invite, /uninvite, /ouninvite, /rank, /towcars, /factionconfig");
	}
	
	return 1;
}

CMD:factions(playerid, params[])
{
	new str[182], longstr[556]; 

	for (new i = 1; i < MAX_FACTIONS; i ++)
	{
		if(!FactionInfo[i][eFactionDBID])
			continue;
			
		format(str, sizeof(str), "{ADC3E7}%d \t\t\t %s \t\t\t [%d out of %d]\n", i, FactionInfo[i][eFactionName], ReturnOnlineMembers(i), ReturnTotalMembers(i));
		strcat(longstr, str);
	}
	
	ShowPlayerDialog(playerid, DIALOG_DEFAULT, DIALOG_STYLE_LIST, "Factions:", longstr, "<<", ""); 
	return 1;
}

CMD:f(playerid, params[])
{
	if(!PlayerInfo[playerid][pFaction])
		return SendErrorMessage(playerid, "You aren't in any faction."); 
	
	if(PlayerInfo[playerid][pFactionRank] > FactionInfo[PlayerInfo[playerid][pFaction]][eFactionChatRank])
		return SendErrorMessage(playerid, "Your rank doesn't have faction chat permissions.");
		
	if(PlayerInfo[playerid][pFactionChat] == true)
		return SendErrorMessage(playerid, "You have your faction chat toggled. Use \"/togfam\" to enable."); 

	if(isnull(params)) return SendUsageMessage(playerid, "/f [text]");
	
	if(FactionInfo[PlayerInfo[playerid][pFaction]][eFactionChatStatus] == true)
	{
		if(PlayerInfo[playerid][pFactionRank] > FactionInfo[PlayerInfo[playerid][pFaction]][eFactionAlterRank])
			return SendErrorMessage(playerid, "Your factions chat is disabled. Your rank doesn't have permissions to avoid this.");  
			
		if(strlen(params) > 79)
		{
			SendFactionMessage(playerid, "**(( %s %s: %.79s ))**", ReturnFactionRank(playerid), ReturnName(playerid), params); 
			SendFactionMessage(playerid, "**(( %s %s: ...%s ))**", ReturnFactionRank(playerid), ReturnName(playerid), params[79]); 
		}
		else SendFactionMessage(playerid, "**(( %s %s: %s ))**", ReturnFactionRank(playerid), ReturnName(playerid), params); 
		return 1;
	}
	
	if(strlen(params) > 79)
	{
		SendFactionMessage(playerid, "**(( %s %s: %.79s ))**", ReturnFactionRank(playerid), ReturnName(playerid), params); 
		SendFactionMessage(playerid, "**(( %s %s: ...%s ))**", ReturnFactionRank(playerid), ReturnName(playerid), params[79]); 
	}
	else SendFactionMessage(playerid, "**(( %s %s: %s ))**", ReturnFactionRank(playerid), ReturnName(playerid), params); 		
	return 1;
}

CMD:nofam(playerid, params[])
{
	if(!PlayerInfo[playerid][pFaction])
		return SendErrorMessage(playerid, "You aren't in any faction.");
		
	if(PlayerInfo[playerid][pFactionRank] > FactionInfo[PlayerInfo[playerid][pFaction]][eFactionAlterRank])
		return SendErrorMessage(playerid, "Your rank doesn't have permission to alter the faction chat.");
		
	if(FactionInfo[PlayerInfo[playerid][pFaction]][eFactionChatStatus] == true)
	{
		SendFactionMessageEx(playerid, COLOR_RED, "%s turned the /f chat on.", ReturnName(playerid));
		FactionInfo[PlayerInfo[playerid][pFaction]][eFactionChatStatus] = false;
	}
	else
	{
		SendFactionMessageEx(playerid, COLOR_RED, "%s turned the /f chat off.", ReturnName(playerid));
		FactionInfo[PlayerInfo[playerid][pFaction]][eFactionChatStatus] = true;
	}	
	return 1;
}

CMD:togfam(playerid, params[])
{
	if(!PlayerInfo[playerid][pFaction])
		return SendErrorMessage(playerid, "You aren't in any faction.");
	
	if(PlayerInfo[playerid][pFactionChat] == true)
	{
		SendServerMessage(playerid, "You enabled your faction chat.");
		PlayerInfo[playerid][pFactionChat] = false;
	}
	else
	{
		SendServerMessage(playerid, "You disabled your faction chat.");
		PlayerInfo[playerid][pFactionChat] = true;
	}
	return 1;
}

CMD:invite(playerid, params[])
{
	new playerb;
	
	if(!PlayerInfo[playerid][pFaction])
		return SendErrorMessage(playerid, "You aren't in any faction.");
		
	if(PlayerInfo[playerid][pFactionRank] > FactionInfo[PlayerInfo[playerid][pFaction]][eFactionAlterRank])
		return SendErrorMessage(playerid, "You don't have permission to use this command."); 
	
	if(sscanf(params, "u", playerb))
		return SendUsageMessage(playerid, "/invite [playerid OR name]");
		
	if(!IsPlayerConnected(playerb))
		return SendErrorMessage(playerid, "The player you specified isn't connected."); 
		
	if(e_pAccountData[playerb][mLoggedin] == false)
		return SendErrorMessage(playerid, "The player you specified hasn't logged in yet.");
		
	if(PlayerInfo[playerb][pFaction])
		return SendErrorMessage(playerid, "The player you specified IS already in a faction."); 
		
	PlayerInfo[playerb][pFactionInvite] = PlayerInfo[playerid][pFaction];	
	PlayerInfo[playerb][pFactionInvitedBy] = playerid;
	
	sendMessage(playerb, COLOR_YELLOW, "%s has invited you to join the %s, type /accept to join.", ReturnName(playerid), ReturnFactionName(playerid));
	sendMessage(playerid, COLOR_YELLOW, "You invited %s to join the %s.", ReturnName(playerb), ReturnFactionName(playerid));
	return 1;
}

CMD:accept(playerid, params[])
{
	if(PlayerInfo[playerid][pFaction])
		return SendErrorMessage(playerid, "You're already in a faction.");

	if(!PlayerInfo[playerid][pFactionInvite])
		return SendErrorMessage(playerid, "You weren't invited to join any faction.");
			
	sendMessage(PlayerInfo[playerid][pFactionInvitedBy], COLOR_YELLOW, "%s accepted your faction invitation.", ReturnName(playerid));
	sendMessage(playerid, COLOR_YELLOW, "You joined the %s!", ReturnFactionNameEx(PlayerInfo[playerid][pFactionInvite]));
	
	PlayerInfo[playerid][pFaction] = PlayerInfo[playerid][pFactionInvite]; 
	PlayerInfo[playerid][pFactionRank] = FactionInfo[PlayerInfo[playerid][pFactionInvite]][eFactionJoinRank]; 
	
	PlayerInfo[playerid][pFactionInvite] = 0;
	PlayerInfo[playerid][pFactionInvitedBy] = INVALID_PLAYER_ID;
	
	SaveCharacter(playerid);
	return 1;
}

CMD:uninvite(playerid, params[])
{
	new playerb;
	
	if(!PlayerInfo[playerid][pFaction])
		return SendErrorMessage(playerid, "You aren't in any faction.");
		
	if(PlayerInfo[playerid][pFactionRank] > FactionInfo[PlayerInfo[playerid][pFaction]][eFactionAlterRank])
		return SendErrorMessage(playerid, "You don't have permission to use this command."); 
	
	if(sscanf(params, "u", playerb))
		return SendUsageMessage(playerid, "/uninvite [playerid OR name]");
		
	if(!IsPlayerConnected(playerb))
		return SendErrorMessage(playerid, "The player you specified isn't connected."); 
		
	if(e_pAccountData[playerb][mLoggedin] == false)
		return SendErrorMessage(playerid, "The player you specified hasn't logged in yet.");
		
	if(PlayerInfo[playerb][pFaction] != PlayerInfo[playerid][pFaction])
		return SendErrorMessage(playerid, "The player you specified IS not in your faction.");
	
	sendMessage(playerb, COLOR_YELLOW, "You were uninvited from the %s by %s!", ReturnFactionNameEx(PlayerInfo[playerid][pFaction]), ReturnName(playerid));
	sendMessage(playerid, COLOR_YELLOW, "You uninvited %s!", ReturnName(playerb));
	
	PlayerInfo[playerb][pFaction] = 0;
	PlayerInfo[playerb][pFactionRank] = 0;
	
	SetPlayerSkin(playerb, 264); PlayerInfo[playerb][pLastSkin] = 264;
	SaveCharacter(playerb);
	return 1;
}

CMD:ouninvite(playerid, params[])
{
	if(!PlayerInfo[playerid][pFaction])
		return SendErrorMessage(playerid, "You aren't in any faction.");
		
	if(PlayerInfo[playerid][pFactionRank] > FactionInfo[PlayerInfo[playerid][pFaction]][eFactionAlterRank])
		return SendErrorMessage(playerid, "You don't have permission to use this command."); 
		
	new thread[128];
		
	if(isnull(params))
		return SendUsageMessage(playerid, "/ouninvite [Firstname_Lastname]"); 
		
	foreach(new i : Player)
	{
		if(!strcmp(ReturnName(i), params))
		{
			SendServerMessage(playerid, "%s is connected to the server. (ID: %i)", ReturnName(i), i);
			return 1;
		}
	}
	
	mysql_format(this, thread, sizeof(thread), "SELECT char_dbid, pFaction, pFactionRank FROM characters WHERE char_name = '%e'", params);
	new Cache:cache = mysql_query(this, thread);
	
	if(!cache_num_rows())
	{
		SendServerMessage(playerid, "%s does not exist in the database.", params);
		cache_delete(cache);
		return 1;
	}
	
	new playerDBID = cache_get_field_content_int(0, "char_dbid"); 
	new playerFaction = cache_get_field_content_int(0, "pFaction");
	new playerRank = cache_get_field_content_int(0, "pFactionRank");
	
	if(playerFaction != PlayerInfo[playerid][pFaction])
		return SendErrorMessage(playerid, "%s is not in your faction.", params); 
		
	if(playerRank > PlayerInfo[playerid][pFactionRank])
		return SendErrorMessage(playerid, "%s exceeds your faction rank.", params);
		
	
	mysql_format(this, thread, sizeof(thread), "UPDATE characters SET pFaction = 0, pFactionRank = 0, pLastSkin = 264 WHERE char_dbid = %i", playerDBID);
	mysql_tquery(this, thread); cache_delete(cache);
	
	SendServerMessage(playerid, "%s was removed from the faction.", params);
	return 1;
}

CMD:rank(playerid, params[])
{
	new playerb, rank;
	
	if(!PlayerInfo[playerid][pFaction])
		return SendErrorMessage(playerid, "You aren't in any faction.");
		
	if(PlayerInfo[playerid][pFactionRank] > FactionInfo[PlayerInfo[playerid][pFaction]][eFactionAlterRank])
		return SendErrorMessage(playerid, "You don't have permission to use this command."); 
	
	if(sscanf(params, "ui", playerb, rank))
	{
		for(new i = 1; i < MAX_FACTION_RANKS; i++)
		{
			if(!strcmp(FactionRanks[PlayerInfo[playerid][pFaction]][i], "NotSet"))
				continue;
				
			sendMessage(playerid, COLOR_YELLOWEX, "-> Rank %i: %s", i, FactionRanks[PlayerInfo[playerid][pFaction]][i]);
		}
	
		SendUsageMessage(playerid, "/rank [playerid OR name] [rank id]");
		return 1;
	}
	
	if(rank < 1 || rank > 20)
		return SendErrorMessage(playerid, "You specified an invalid rank."); 
		
	if(!IsPlayerConnected(playerb))
		return SendErrorMessage(playerid, "The player you specified isn't connected."); 
		
	if(e_pAccountData[playerb][mLoggedin] == false)
		return SendErrorMessage(playerid, "The player you specified hasn't logged in yet.");
		
	if(PlayerInfo[playerb][pFaction] != PlayerInfo[playerid][pFaction])
		return SendErrorMessage(playerid, "The player you specified IS not in your faction.");
		
	if(PlayerInfo[playerb][pFactionRank] > PlayerInfo[playerid][pFaction])
		return SendErrorMessage(playerid, "You can't alter %s's rank.", ReturnName(playerb)); 
		
	sendMessage(playerb, COLOR_YELLOW, "Your rank has been upgraded from %s to %s by %s!", FactionRanks[PlayerInfo[playerb][pFaction]][PlayerInfo[playerb][pFactionRank]], FactionRanks[PlayerInfo[playerb][pFaction]][rank], ReturnName(playerid, 0));
	sendMessage(playerid, COLOR_YELLOW, "You upgraded %s's rank from %s to %s!", ReturnName(playerb, 0), FactionRanks[PlayerInfo[playerb][pFaction]][PlayerInfo[playerb][pFactionRank]], FactionRanks[PlayerInfo[playerb][pFaction]][rank]);
		
	PlayerInfo[playerb][pFactionRank] = rank; 
	SaveCharacter(playerb);
	return 1;
}

CMD:factionconfig(playerid, params[])
{
	if(!PlayerInfo[playerid][pFaction])
		return SendErrorMessage(playerid, "You aren't in any faction.");
		
	if(PlayerInfo[playerid][pFactionRank] > FactionInfo[PlayerInfo[playerid][pFaction]][eFactionAlterRank])
		return SendErrorMessage(playerid, "You don't have permission to use this command."); 
	
	ShowFactionConfig(playerid);
	return 1;
}

CMD:factionon(playerid, params[])
{
	new factionid;
	
	if(sscanf(params, "I(-1)", factionid))
		return SendUsageMessage(playerid, "/factionon [factionid]");
		
	if(factionid == -1)
	{
		if(!PlayerInfo[playerid][pFaction])
			return SendErrorMessage(playerid, "You aren't in any faction.");
			
		sendMessage(playerid, COLOR_GREY, "Members of %s online:", ReturnFactionName(playerid));
		
		foreach(new i : Player)
		{
			if(PlayerInfo[i][pFaction] != PlayerInfo[playerid][pFaction])
				continue;
				
			if(PlayerInfo[i][pAdminDuty])
				sendMessage(playerid, COLOR_GREY, "(ID: %i) {FF9900}%s %s", i, ReturnFactionRank(i), ReturnName(i));
				
			else
				sendMessage(playerid, COLOR_GREY, "(ID: %i) %s %s", i, ReturnFactionRank(i), ReturnName(i));
		}
		
		return 1;
	}

	if(!FactionInfo[factionid][eFactionDBID])
		return SendErrorMessage(playerid, "The faction you specified doesn't exist.");
		
	sendMessage(playerid, COLOR_RED, "[ ! ]{FFFFFF} %s has %i out of %i members online.",  ReturnFactionNameEx(factionid), ReturnOnlineMembers(factionid), ReturnTotalMembers(factionid));
	return 1;
}

//Police commands:
CMD:duty(playerid, params[])
{
	if(!PlayerInfo[playerid][pFaction])
		return SendErrorMessage(playerid, "You aren't in any faction.");
		
	if(FactionInfo[PlayerInfo[playerid][pFaction]][eFactionType] != FACTION_TYPE_POLICE)
		return SendClientMessage(playerid, COLOR_RED, "ACCESS DENIED:{FFFFFF} You can't use this command."); 
		
	if(PlayerInfo[playerid][pPoliceDuty])
		return SendErrorMessage(playerid, "You're already on duty."); 
		
	if(!IsPlayerInRangeOfPoint(playerid, 5.0, FactionInfo[PlayerInfo[playerid][pFaction]][eFactionSpawn][0], FactionInfo[PlayerInfo[playerid][pFaction]][eFactionSpawn][1], FactionInfo[PlayerInfo[playerid][pFaction]][eFactionSpawn][2]))
		return SendErrorMessage(playerid, "You aren't near your faction spawn.");
		
	PlayerInfo[playerid][pPoliceDuty] = true; 
	
	for(new i = 0; i < 4; i++)
	{
		playerWeaponsSave[playerid][i] = PlayerInfo[playerid][pWeapons][i];
		playerWeaponsAmmoSave[playerid][i] = PlayerInfo[playerid][pWeaponsAmmo][i]; 
	}
	
	SendPoliceMessage(COLOR_COP, "** HQ: %s %s is now On Duty! **", ReturnFactionRank(playerid), ReturnName(playerid, 0));
	SendClientMessage(playerid, COLOR_WHITE, "You were given: Spraycan, Nitestick, Desert Eagle (60), Health(100)");
	
	callcmd::me(playerid, "takes equipment from their locker.");
	
	SetPlayerHealth(playerid, 100);
	SetPlayerArmour(playerid, 100);
	
	TakePlayerGuns(playerid);
	
	GivePlayerGun(playerid, 24, 100);
	GivePlayerGun(playerid, 3, 1);
	GivePlayerGun(playerid, 41, 350);
	
	if(!PlayerInfo[playerid][pAdminDuty])
		SetPlayerColor(playerid, COLOR_COP);

	return 1;
}

CMD:offduty(playerid, params[])
{
	if(!PlayerInfo[playerid][pFaction])
		return SendErrorMessage(playerid, "You aren't in any faction.");
		
	if(FactionInfo[PlayerInfo[playerid][pFaction]][eFactionType] != FACTION_TYPE_POLICE)
		return SendClientMessage(playerid, COLOR_RED, "ACCESS DENIED:{FFFFFF} You can't use this command."); 
		
	if(!PlayerInfo[playerid][pPoliceDuty])
		return SendErrorMessage(playerid, "You aren't on duty."); 
		
	if(!IsPlayerInRangeOfPoint(playerid, 5.0, FactionInfo[PlayerInfo[playerid][pFaction]][eFactionSpawn][0], FactionInfo[PlayerInfo[playerid][pFaction]][eFactionSpawn][1], FactionInfo[PlayerInfo[playerid][pFaction]][eFactionSpawn][2]))
		return SendErrorMessage(playerid, "You aren't near your faction spawn.");
		
	PlayerInfo[playerid][pPoliceDuty] = false;
	
	ResetPlayerWeapons(playerid); 
	
	for(new i = 0; i < 4; i++)
	{
		PlayerInfo[playerid][pWeapons][i] = 0; PlayerInfo[playerid][pWeaponsAmmo][i] = 0;
		
		if(playerWeaponsSave[playerid][i])
			GivePlayerGun(playerid, playerWeaponsSave[playerid][i], playerWeaponsAmmoSave[playerid][i]);
	}
	
	SendPoliceMessage(COLOR_COP, "** HQ: %s %s is now Off Duty! **", ReturnFactionRank(playerid), ReturnName(playerid, 0)); 
	callcmd::me(playerid, "puts their equipment away.");
	
	SetPlayerArmour(playerid, 0);
	SetPlayerHealth(playerid, 100); 
	
	if(!PlayerInfo[playerid][pAdminDuty])
		SetPlayerColor(playerid, COLOR_WHITE);
	
	if(GetPlayerSkin(playerid) != PlayerInfo[playerid][pLastSkin])
		SetPlayerSkin(playerid, PlayerInfo[playerid][pLastSkin]); 
		
	return 1;
}

CMD:handcuff(playerid, params[])
{
	if(!PlayerInfo[playerid][pFaction])
		return SendErrorMessage(playerid, "You aren't in any faction.");
		
	if(FactionInfo[PlayerInfo[playerid][pFaction]][eFactionType] != FACTION_TYPE_POLICE)
		return SendClientMessage(playerid, COLOR_RED, "ACCESS DENIED:{FFFFFF} You can't use this command."); 
		
	new playerb;
	
	if(sscanf(params, "u", playerb))
		return SendUsageMessage(playerid, "/handcuff [playerid OR name]"); 
		
	if(!IsPlayerConnected(playerb))
		return SendErrorMessage(playerid, "The player you specified isn't connected.");
		
	if(!PlayerInfo[playerb][pLoggedin])
		return SendErrorMessage(playerid, "The player you specified isn't logged in."); 
		
	if(!IsPlayerNearPlayer(playerid, playerb, 5.0))
		return SendErrorMessage(playerid, "You aren't near that player.");
		
	if(PlayerInfo[playerb][pHandcuffed])
		return SendErrorMessage(playerid, "That player's already handcuffed."); 
		
	if(GetPlayerSpecialAction(playerb) != SPECIAL_ACTION_HANDSUP && GetPlayerSpecialAction(playerb) != SPECIAL_ACTION_DUCK)
		return SendErrorMessage(playerid, "That player isn't crouched or with their hands up."); 
	
	SetPlayerAttachedObject(playerb, SLOT_HANDCUFF, 19418,6, -0.031999, 0.024000, -0.024000, -7.900000, -32.000011, -72.299987, 1.115998, 1.322000, 1.406000);
	SetPlayerSpecialAction(playerb, SPECIAL_ACTION_CUFFED);
	
	PlayerInfo[playerb][pHandcuffed] = true;
	
	SendServerMessage(playerb, "You were handcuffed by %s.", ReturnName(playerid, 0)); 
	SendServerMessage(playerid, "You handcuffed %s.", ReturnName(playerb, 0));
	return 1;
}

CMD:unhandcuff(playerid, params[])
{
	if(!PlayerInfo[playerid][pFaction])
		return SendErrorMessage(playerid, "You aren't in any faction.");
		
	if(FactionInfo[PlayerInfo[playerid][pFaction]][eFactionType] != FACTION_TYPE_POLICE)
		return SendClientMessage(playerid, COLOR_RED, "ACCESS DENIED:{FFFFFF} You can't use this command."); 
		
	new playerb;
	
	if(sscanf(params, "u", playerb))
		return SendUsageMessage(playerid, "/unhandcuff [playerid OR name]"); 
		
	if(!IsPlayerConnected(playerb))
		return SendErrorMessage(playerid, "The player you specified isn't connected.");
		
	if(!PlayerInfo[playerb][pLoggedin])
		return SendErrorMessage(playerid, "The player you specified isn't logged in."); 
		
	if(!IsPlayerNearPlayer(playerid, playerb, 5.0))
		return SendErrorMessage(playerid, "You aren't near that player.");
		
	if(!PlayerInfo[playerb][pHandcuffed])
		return SendErrorMessage(playerid, "That player isn't handcuffed.");

	RemovePlayerAttachedObject(playerb, 0); 
	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE); 
	
	PlayerInfo[playerb][pHandcuffed] = false;
	SendServerMessage(playerid, "You unhandcuffed %s.", ReturnName(playerb, 0));
	return 1;
}

CMD:badge(playerid, params[])
{
	if(!PlayerInfo[playerid][pFaction])
		return SendErrorMessage(playerid, "You aren't in any faction.");
		
	if(FactionInfo[PlayerInfo[playerid][pFaction]][eFactionType] != FACTION_TYPE_POLICE)
		return SendClientMessage(playerid, COLOR_RED, "ACCESS DENIED:{FFFFFF} You can't use this command."); 
		
	new playerb;
	
	if(sscanf(params, "u", playerb))
		return SendUsageMessage(playerid, "/unhandcuff [playerid OR name]"); 
		
	if(!IsPlayerConnected(playerb))
		return SendErrorMessage(playerid, "The player you specified isn't connected.");
		
	if(!PlayerInfo[playerb][pLoggedin])
		return SendErrorMessage(playerid, "The player you specified isn't logged in."); 
		
	if(!IsPlayerNearPlayer(playerid, playerb, 5.0))
		return SendErrorMessage(playerid, "You aren't near that player.");
		
	if(playerb == playerid)
		SendNearbyMessage(playerid, 20.0, COLOR_EMOTE, "* %s looks at their badge.", ReturnName(playerid, 0));
	
	else SendNearbyMessage(playerid, 20.0, COLOR_EMOTE, "* %s shows %s their badge.", ReturnName(playerid, 0), ReturnName(playerb, 0));
	
	SendClientMessage(playerb, COLOR_COP, "______________________________________");
	
	sendMessage(playerb, COLOR_GRAD2, "  Name: %s", ReturnNameLetter(playerid));
	sendMessage(playerb, COLOR_GRAD2, "  Rank: %s", ReturnFactionRank(playerid));
	sendMessage(playerb, COLOR_GRAD2, "  Agency: %s", ReturnFactionName(playerid));
	
	SendClientMessage(playerb, COLOR_COP, "______________________________________");
	return 1;
}

CMD:uniform(playerid, params[])
{
	if(!PlayerInfo[playerid][pFaction])
		return SendErrorMessage(playerid, "You aren't in any faction.");
		
	if(FactionInfo[PlayerInfo[playerid][pFaction]][eFactionType] != FACTION_TYPE_POLICE && FactionInfo[PlayerInfo[playerid][pFaction]][eFactionType] != FACTION_TYPE_MEDICAL)
		return SendClientMessage(playerid, COLOR_RED, "ACCESS DENIED:{FFFFFF} You can't use this command."); 
		
	if(!IsPlayerInRangeOfPoint(playerid, 5.0, FactionInfo[PlayerInfo[playerid][pFaction]][eFactionSpawn][0], FactionInfo[PlayerInfo[playerid][pFaction]][eFactionSpawn][1], FactionInfo[PlayerInfo[playerid][pFaction]][eFactionSpawn][2]))
		return SendErrorMessage(playerid, "You aren't near your faction spawn.");
		
	if(FactionInfo[PlayerInfo[playerid][pFaction]][eFactionType] == FACTION_TYPE_POLICE)
	{
		ShowPlayerDialog(playerid, DIALOG_POLICE_SKINS, DIALOG_STYLE_TABLIST_HEADERS, "Select a skin",
		"Model\tRace\tSex\n\
		11: LSPD\tCaucasian\tMale\n\
		12: LSPD (No Belt)\tCaucasian\tMale\n\
		13: SFPD\tCaucasian\tMale\n\
		14: SFPD (No Belt)\tCaucasian\tMale\n\
		15: LSPD\tCaucasian\tFemale\n\
		16: LSPD\tAfrican American\tFemale\n\
		17: TENPENNY\tAfrican American\tMale\n\
		18: HERNANDEZ\tHispanic\tMale\n\
		19: PULASKI\tCaucasian\tMale\n\
		20: Biker\tAfrican American\tMale\n\
		21: Pilot\tCaucasian\tMale\n\
		22: Lady\tCaucasian\tFemale",
			"Select", "Cancel");
	}
		
	return 1;
}

alias:megaphone("m");
CMD:megaphone(playerid, params[])
{
	if(!PlayerInfo[playerid][pFaction])
		return SendErrorMessage(playerid, "You aren't in any faction.");
		
	if(FactionInfo[PlayerInfo[playerid][pFaction]][eFactionType] != FACTION_TYPE_POLICE && FactionInfo[PlayerInfo[playerid][pFaction]][eFactionType] != FACTION_TYPE_MEDICAL)
		return SendClientMessage(playerid, COLOR_RED, "ACCESS DENIED:{FFFFFF} You can't use this command."); 
		
	if(!IsPlayerInAnyVehicle(playerid))
		return SendErrorMessage(playerid, "You aren't in any vehicle.");
		
	if(isnull(params))
		return SendUsageMessage(playerid, "/megaphone [text]"); 
		
	SendNearbyMessage(playerid, 40.0, COLOR_YELLOWEX, "[ %s %s:o< %s ]", ReturnFactionRank(playerid), ReturnName(playerid, 0), params);
	return 1;
}

alias:department("dep", "d");
CMD:department(playerid, params[])
{
	if(!PlayerInfo[playerid][pFaction])
		return SendErrorMessage(playerid, "You aren't in any faction.");
		
	if(FactionInfo[PlayerInfo[playerid][pFaction]][eFactionType] != FACTION_TYPE_POLICE && FactionInfo[PlayerInfo[playerid][pFaction]][eFactionType] != FACTION_TYPE_MEDICAL && FactionInfo[PlayerInfo[playerid][pFaction]][eFactionType] != FACTION_TYPE_DOC)
		return SendClientMessage(playerid, COLOR_RED, "ACCESS DENIED:{FFFFFF} You can't use this command."); 
		
	if(isnull(params))
		return SendUsageMessage(playerid, "/department [text]");

	foreach(new i : Player)
	{
		new
			factionid;
			
		factionid = PlayerInfo[i][pFaction];
			
		if(FactionInfo[factionid][eFactionType] == FACTION_TYPE_POLICE || FactionInfo[factionid][eFactionType] == FACTION_TYPE_MEDICAL || FactionInfo[factionid][eFactionType] == FACTION_TYPE_DOC)
		{
			sendMessage(playerid, COLOR_DEPT, "** [%s] %s %s: %s", FactionInfo[factionid][eFactionAbbrev], ReturnFactionRank(i), ReturnName(playerid, 0), params);
		}
	}
	
	new Float:posx, Float:posy, Float:posz;
	GetPlayerPos(playerid, posx,posy,posz);

	foreach(new i : Player)
	{
 		if(i == playerid)
   			continue;

		else if(IsPlayerInRangeOfPoint(i, 20.0, posx,posy,posz))
		{
  			sendMessage(i, COLOR_GRAD1, "%s says (radio): %s", ReturnName(playerid, 0), params);
 		}
	}
		
	return 1;
}

CMD:carsign(playerid, params[])
{
	if(!IsPlayerInAnyVehicle(playerid))
		return SendErrorMessage(playerid, "You aren't in any vehicle.");
		
	new
		vehicleid = GetPlayerVehicleID(playerid);
		
	if(FactionInfo[PlayerInfo[playerid][pFaction]][eFactionType] != FACTION_TYPE_POLICE && FactionInfo[PlayerInfo[playerid][pFaction]][eFactionType] != FACTION_TYPE_MEDICAL && FactionInfo[PlayerInfo[playerid][pFaction]][eFactionType] != FACTION_TYPE_DOC)
		return SendClientMessage(playerid, COLOR_RED, "ACCESS DENIED:{FFFFFF} You can't use this command."); 
		
	if(isnull(params))
		return SendUsageMessage(playerid, "/carsign [text]"); 
		
	if(strlen(params) < 2 || strlen(params) >= 50)
		return SendErrorMessage(playerid, "Your text has to be greater than 1 char and less than 50.");
		
	if(!VehicleInfo[vehicleid][eVehicleFaction])
		return SendErrorMessage(playerid, "You aren't in a faction vehicle.");
		
	if(VehicleInfo[vehicleid][eVehicleHasCarsign])
		Update3DTextLabelText(VehicleInfo[vehicleid][eVehicleCarsign], COLOR_WHITE, params); 
	
	else
	{
		SendServerMessage(playerid, "Use \"/remove_carsign\" to destroy it next."); 
		
		VehicleInfo[vehicleid][eVehicleCarsign] = Create3DTextLabel(params, COLOR_WHITE, 0.0, 0.0, 0.0, 25.0, GetPlayerVirtualWorld(playerid), 0); 
		Attach3DTextLabelToVehicle(VehicleInfo[vehicleid][eVehicleCarsign], vehicleid, -0.7, -1.9, -0.3); 
		
		VehicleInfo[vehicleid][eVehicleHasCarsign] = true;
	}

	return 1;
}

CMD:remove_carsign(playerid, params[])
{
	if(!IsPlayerInAnyVehicle(playerid))
		return SendErrorMessage(playerid, "You aren't in any vehicle.");
		
	new
		vehicleid = GetPlayerVehicleID(playerid);
		
	if(FactionInfo[PlayerInfo[playerid][pFaction]][eFactionType] != FACTION_TYPE_POLICE && FactionInfo[PlayerInfo[playerid][pFaction]][eFactionType] != FACTION_TYPE_MEDICAL && FactionInfo[PlayerInfo[playerid][pFaction]][eFactionType] != FACTION_TYPE_DOC)
		return SendClientMessage(playerid, COLOR_RED, "ACCESS DENIED:{FFFFFF} You can't use this command."); 
		
	if(!VehicleInfo[vehicleid][eVehicleFaction])
		return SendErrorMessage(playerid, "You aren't in a faction vehicle.");
		
	if(!VehicleInfo[vehicleid][eVehicleHasCarsign])
		return SendErrorMessage(playerid, "Your vehicle doesn't have a carsign."); 
	
	Delete3DTextLabel(VehicleInfo[vehicleid][eVehicleCarsign]); 
	VehicleInfo[vehicleid][eVehicleHasCarsign] = true;

	SendServerMessage(playerid, "You deleted your vehicles carsign."); 
	return 1;
}

CMD:taser(playerid, params[])
{
	if(FactionInfo[PlayerInfo[playerid][pFaction]][eFactionType] != FACTION_TYPE_POLICE)
		return SendClientMessage(playerid, COLOR_RED, "ACCESS DENIED:{FFFFFF} You can't use this command."); 
		
	if(!PlayerInfo[playerid][pPoliceDuty])
		return SendClientMessage(playerid, COLOR_RED, "ACCESS DENIED:{FFFFFF} You can't use this command."); 
	
	if(!PlayerHasWeapon(playerid, 24) && !PlayerInfo[playerid][pTaser])
		return SendErrorMessage(playerid, "You don't have a taser on you."); 
		
	if(!PlayerInfo[playerid][pTaser])
	{
		GetPlayerWeaponData(playerid, WeaponDataSlot(24), PlayerInfo[playerid][pWeapons][ReturnWeaponIDSlot(24)], playerTaserAmmo[playerid]); 
		
		PlayerInfo[playerid][pTaser] = true;
		GivePlayerGun(playerid, 23, 5); 
		
		SendNearbyMessage(playerid, 20.0, COLOR_EMOTE, "* %s takes out their taser.", ReturnName(playerid, 0)); 
	}
	else
	{
		GivePlayerGun(playerid, 24, playerTaserAmmo[playerid]); 
		PlayerInfo[playerid][pTaser] = false;
		
		SendNearbyMessage(playerid, 20.0, COLOR_EMOTE, "* %s puts their taser away.", ReturnName(playerid, 0)); 
	}
	return 1; 
}

CMD:towcars(playerid, params[])
{
	new
		bool:vehicle_found = false,
		factionid
	; 
	
	if(PlayerInfo[playerid][pFactionRank] > FactionInfo[PlayerInfo[playerid][pFaction]][eFactionTowRank] && !PlayerInfo[playerid][pAdminDuty])
		return SendUnauthMessage(playerid);
		
	if(PlayerInfo[playerid][pAdminDuty])
	{
		if(sscanf(params, "i", factionid))
			return SendUsageMessage(playerid, "/towcars [faction ID]"); 
			
		if(!FactionInfo[factionid][eFactionDBID] || factionid > MAX_FACTIONS)
			return SendErrorMessage(playerid, "You specified an invalid faction ID.");
			
		for(new f = 1, j = GetVehiclePoolSize(); f <= j; f++)
		{
			if(VehicleInfo[f][eVehicleFaction] == factionid)
			{
				if(!IsVehicleOccupied(f))
				{
					vehicle_found = true; 
					SetVehicleToRespawn(f);
				}
			}
		}
		
		if(vehicle_found)
		{
			foreach(new g : Player) if(PlayerInfo[g][pFaction] == factionid)
				SendFactionMessageEx(playerid, COLOR_RED, "<< Administrator %s returned all faction vehicles to their parking place >>", ReturnName(playerid));
		}
		else SendErrorMessage(playerid, "No vehicles were available for tow.");
		return 1;
	}
		
	for(new i = 1, j = GetVehiclePoolSize(); i <= j; i++)
	{
		if(VehicleInfo[i][eVehicleFaction] == PlayerInfo[playerid][pFaction])
		{
			if(!IsVehicleOccupied(i))
			{
				vehicle_found = true; 
				SetVehicleToRespawn(i);
			}
		}
	}
	
	if(vehicle_found)
		SendFactionMessageEx(playerid, COLOR_RED, "<< %s returned all faction vehicles to their parking place >>", ReturnName(playerid));
		
	else SendErrorMessage(playerid, "No vehicles were available for tow.");
	
	return 1;
}

CMD:take(playerid, params[])
{
	if(ReturnFactionType(playerid) != FACTION_TYPE_POLICE)
		return SendUnauthMessage(playerid);
	
	new 
		playerb,
		a_str[60]
	; 
		
	if(sscanf(params, "us[60]", playerb, a_str))
	{
		SendUsageMessage(playerid, "/take [playerid OR name] [item]");
		SendClientMessage(playerid, COLOR_RED, "[ ! ]{FFFFFF} driverlicense, weaponlicense, weapons"); 
		return 1;
	}
	
	if(!IsPlayerConnected(playerb))
		return SendErrorMessage(playerid, "You specified an invalid player.");
		
	if(!PlayerInfo[playerb][pLoggedin])
		return SendErrorMessage(playerid, "You specified a player that isn't logged in.");
		
	if(!IsPlayerNearPlayer(playerid, playerb, 4.0))
		return SendErrorMessage(playerid, "You aren't near that player.");
	
	if(!strcmp(a_str, "driverlicense"))
	{
		if(!PlayerInfo[playerb][pDriversLicense])
			return SendErrorMessage(playerid, "%s doesn't have a driver's license.", ReturnName(playerb, 0)); 
			
		PlayerInfo[playerb][pDriversLicense] = 0;
		SendNearbyMessage(playerid, 20.0, COLOR_EMOTE, "* %s %s took %s's driver's license.", ReturnFactionRank(playerid), ReturnName(playerid, 0), ReturnName(playerb, 0));
	}
	else if(!strcmp(a_str, "weaponlicense"))
	{
		if(!PlayerInfo[playerb][pWeaponsLicense])
			return SendErrorMessage(playerid, "%s doesn't have a weapons license.", ReturnName(playerb, 0)); 
			
		PlayerInfo[playerb][pWeaponsLicense] = 0;
		SendNearbyMessage(playerid, 20.0, COLOR_EMOTE, "* %s %s took %s's weapons license.", ReturnFactionRank(playerid), ReturnName(playerid, 0), ReturnName(playerb, 0));
	}
	else if(!strcmp(a_str, "weapons"))
	{
		TakePlayerGuns(playerb);
		SendNearbyMessage(playerid, 20.0, COLOR_EMOTE, "* %s %s took %s's weapons.", ReturnFactionRank(playerid), ReturnName(playerid, 0), ReturnName(playerb, 0));
		return 1;
	}
	else return SendServerMessage(playerid, "Invalid Parameter.");
	return 1;
}

CMD:givelicense(playerid, params[])
{
	if(ReturnFactionType(playerid) != FACTION_TYPE_POLICE)
		return SendUnauthMessage(playerid);
		
	if(PlayerInfo[playerid][pFactionRank] >= FactionInfo[PlayerInfo[playerid][pFaction]][eFactionAlterRank])
		return SendServerMessage(playerid, "Your rank doesn't have permission for this."); 
	
	new 
		playerb; 
		
	if (sscanf(params, "u", playerb))
	{
		SendUsageMessage(playerid, "/givelicense [playerid OR name]");
		SendServerMessage(playerid, "This issues a weapon's license to players. "); 
		return 1;
	}
		
	if(!IsPlayerConnected(playerb))
		return SendErrorMessage(playerid, "You specified an invalid player.");
		
	if(!PlayerInfo[playerb][pLoggedin])
		return SendErrorMessage(playerid, "You specified a player that isn't logged in.");
		
	if(!PlayerInfo[playerid][pWeaponsLicense]) {
		PlayerInfo[playerid][pWeaponsLicense] = 1;
		
		SendPoliceMessage(COLOR_COP, "** HQ: %s %s issued %s a weapon's license! **", ReturnFactionRank(playerid), ReturnName(playerid, 0), ReturnName(playerb)); 
	}
	else {
		PlayerInfo[playerid][pWeaponsLicense] = 0; 
		
		SendPoliceMessage(COLOR_COP, "** HQ: %s %s removed %s's weapon's license! **", ReturnFactionRank(playerid), ReturnName(playerid, 0), ReturnName(playerb)); 
	}
		
	return 1;
}

CMD:impound(playerid, params[])
{
	if(ReturnFactionType(playerid) != FACTION_TYPE_POLICE)
		return SendUnauthMessage(playerid);
		
	if(!PlayerInfo[playerid][pPoliceDuty])
		return SendUnauthMessage(playerid);
		
	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
		return SendErrorMessage(playerid, "You aren't driving a vehicle.");
		
	new	
		vehicleid = GetPlayerVehicleID(playerid);
		
	if(!VehicleInfo[vehicleid][eVehicleDBID] && !VehicleInfo[vehicleid][eVehicleAdminSpawn])
		return SendServerMessage(playerid, "This command can only be used for private vehicles. You are in a public static vehicle."); 
		
	if(VehicleInfo[vehicleid][eVehicleFaction])
		return SendErrorMessage(playerid, "You can't impound faction vehicles."); 
		
	if(!IsPlayerInDynamicArea(playerid, ImpoundLotArea))
		return SendErrorMessage(playerid, "You aren't in the impound lot area."); 
		
	GetPlayerPos(playerid, VehicleInfo[vehicleid][eVehicleImpoundPos][0], VehicleInfo[vehicleid][eVehicleImpoundPos][1], VehicleInfo[vehicleid][eVehicleImpoundPos][2]); 
	VehicleInfo[vehicleid][eVehicleImpounded] = true; 
	
	sendMessage(playerid, COLOR_DARKGREEN, "You impounded %s's %s", ReturnDBIDName(VehicleInfo[vehicleid][eVehicleOwnerDBID]), ReturnVehicleName(vehicleid));
	
	foreach(new i : Player) if(PlayerInfo[i][pDBID] == VehicleInfo[vehicleid][eVehicleOwnerDBID])
		sendMessage(i, COLOR_DARKGREEN, "Your %s was impounded by %s", ReturnVehicleName(vehicleid), ReturnName(playerid));

	return 1;
}

CMD:mdc(playerid, params[])
{
	if(ReturnFactionType(playerid) != FACTION_TYPE_POLICE)
		return SendUnauthMessage(playerid);
		
	if(!IsPlayerInAnyVehicle(playerid))
		return SendErrorMessage(playerid, "You aren't in a vehicle.");
		
	if(GetPlayerVehicleSeat(playerid) > 1)
		return SendErrorMessage(playerid, "You can't use the MDC from back there.");
		
	new
		vehicleid = GetPlayerVehicleID(playerid)
	; 
	
	//if(!VehicleInfo[vehicleid][eVehicleFaction] || VehicleInfo[vehicleid][eVehicleFaction] && FactionInfo[VehicleInfo[vehicleid][eVehicleFaction]][eFactionType] != FACTION_TYPE_POLICE)
	//	return SendErrorMessage(playerid, "This vehicle doesn't have an MDC.");
	
	SetPVarInt(playerid, "UsingMDC", 1);
    SetPVarInt(playerid, "LastPage_ID", 10);
    ToggleMDC(playerid, true);
    UpdateMDC(playerid, 0);
	SelectTextDraw(playerid, COLOR_GREY);
	//ShowPlayerMDC(playerid);
	return 1;
}

CMD:wanted(playerid, params[])
{
	new
		add_query[256],
		charge[90],
		playerb
	;
	
	if(ReturnFactionType(playerid) != FACTION_TYPE_POLICE)
		return SendUnauthMessage(playerid);
	
	if(sscanf(params, "us[90]", playerb, charge))
		return SendUsageMessage(playerid, "/wanted [playerid OR name] [reason]"); 
	
	if(!IsPlayerConnected(playerb))
		return SendErrorMessage(playerid, "The player you specified isn't connected."); 
		
	if(PlayerInfo[playerb][pLoggedin] == false)
		return SendErrorMessage(playerid, "The player you specified hasn't logged in yet.");
	
	mysql_format(this, add_query, sizeof(add_query), "INSERT INTO criminal_record (player_name, charge_reason, add_date) VALUES('%e', '%e', '%e')", ReturnName(playerb), charge, ReturnDate());
	mysql_tquery(this, add_query, "OnPlayerAddCharge", "iis", playerid, playerb, charge);
	return 1;
}

//Admin commands:
CMD:ahelp(playerid, params[])
{
	if(!PlayerInfo[playerid][pAdmin])
		return 0;
		
	if(PlayerInfo[playerid][pAdmin] >= 1)
	{
		SendClientMessage(playerid, COLOR_DARKGREEN, "LEVEL 1:{FFFFFF} /aduty, /forumname, /goto, /gethere, /a (achat), /showmain, /kick, /(o)ban, /(o)ajail,"); 
		SendClientMessage(playerid, COLOR_DARKGREEN, "LEVEL 1:{FFFFFF} /unjail, /setint, /setworld, /skin, /health, /reports, /ar (accept), /dr (disregard),"); 
		SendClientMessage(playerid, COLOR_DARKGREEN, "LEVEL 1:{FFFFFF} /slap, /mute, /freeze, /unfreeze, /awp, /watchoff, /stats (id), /gotols, /respawncar,");
		SendClientMessage(playerid, COLOR_DARKGREEN, "LEVEL 1:{FFFFFF} /gotocar, /getcar, /listmasks, /dropinfo, /aooc, /revive, /arecord, /towcars (aduty), /listweapons");
	}
	if(PlayerInfo[playerid][pAdmin] >= 2)
	{
		SendClientMessage(playerid, COLOR_DARKGREEN, "LEVEL 2:{FFFFFF} /armor, /clearreports, /p2p, /givegun, /clearpguns, /gotoproperty, /gotofaction, /gotopoint,");
		SendClientMessage(playerid, COLOR_DARKGREEN, "LEVEL 2:{FFFFFF} /gotobusiness, /noooc, /backup, /repair.");
	}
	if(PlayerInfo[playerid][pAdmin] >= 3)
	{
		SendClientMessage(playerid, COLOR_DARKGREEN, "LEVEL 3:{FFFFFF} /spawncar, /houseint, /bizint, /despawncar, /pcar, /setstats, /givemoney, /setcar, /setcarparams.");
	}
	if(PlayerInfo[playerid][pAdmin] >= 4)
	{
		SendClientMessage(playerid, COLOR_DARKGREEN, "LEVEL 4:{FFFFFF} /makefaction, /editfaction, /setpfaction, /makeproperty, /editproperty, /makexmrcat, /makexmrstation.");
		SendClientMessage(playerid, COLOR_DARKGREEN, "LEVEL 4:{FFFFFF} /makebusiness, /editbusiness, /callpaycheck, /graffiti, /makepayphone");
	}
	 
	return 1; 
}

CMD:aduty(playerid, params[])
{
	if(!PlayerInfo[playerid][pAdmin])
		return 0;
		
	new str[128];
		
	if(PlayerInfo[playerid][pAdminDuty])
	{
		PlayerInfo[playerid][pAdminDuty] = false;
		
		format(str, sizeof(str), "%s is now off admin duty.", ReturnName(playerid)); 
		SendAdminMessage(1, str);
		
		if(!PlayerInfo[playerid][pPoliceDuty])
			SetPlayerColor(playerid, COLOR_WHITE); 
			
		else
			SetPlayerColor(playerid, COLOR_COP);
			
		SetPlayerHealth(playerid, 100); 
	}
	else
	{
		PlayerInfo[playerid][pAdminDuty] = true;
		
		format(str, sizeof(str), "%s is now on admin duty.", ReturnName(playerid)); 
		SendAdminMessage(1, str);
		
		SetPlayerColor(playerid, 0x587B95FF);
		SetPlayerHealth(playerid, 250);
	}
	
	return 1; 
}

CMD:a(playerid, params[])
{
	if(!PlayerInfo[playerid][pAdmin])
		return 0;
		
	if(isnull(params)) return SendUsageMessage(playerid, "/a (admin chat) [text]"); 
	
	if(strlen(params) > 89)
	{
		SendAdminMessageEx(COLOR_YELLOWEX, 1, "** %s (%s): %.89s", ReturnName(playerid), e_pAccountData[playerid][mForumName], params);
		SendAdminMessageEx(COLOR_YELLOWEX, 1, "** %s (%s): ... %s", ReturnName(playerid), e_pAccountData[playerid][mForumName], params[89]);
	}
	else SendAdminMessageEx(COLOR_YELLOWEX, 1, "** %s (%s): %s", ReturnName(playerid), e_pAccountData[playerid][mForumName], params);
	return 1;
}

CMD:forumname(playerid, params[])
{
	if(!PlayerInfo[playerid][pAdmin])
		return SendUnauthMessage(playerid);
		
	if(isnull(params))
		return SendUsageMessage(playerid, "/forumname [forum name]");
		
	if(strlen(params) > 60)
		return SendErrorMessage(playerid, "Your forum name needs to be shorter.");
	
	format(e_pAccountData[playerid][mForumName], 60, "%s", params);
	SendServerMessage(playerid, "Your forum name was changed to: %s.", params);  
	
	SaveCharacter(playerid);
	return 1;
}

CMD:gotoxyz(playerid, params[])
{
	new Float:gotoPos[3];
	if(PlayerInfo[playerid][pAdmin] < 5)
		return SendUnauthMessage(playerid);
		
    if(sscanf(params, "fffd", gotoPos[0], gotoPos[1], gotoPos[2], params[4])) return SendClientMessage(playerid, -1, "USAGE: /gotoxyz (X) (Y) (Z) (Int)");
    SetPlayerPos(playerid, gotoPos[0], gotoPos[1], gotoPos[2]);
    SetPlayerInterior(playerid, params[4]);
    return 1;
}

//Level 1 Admin commands:
CMD:goto(playerid, params[])
{
	if(!PlayerInfo[playerid][pAdmin])
		return SendUnauthMessage(playerid); 
		
	new playerb;
	
	if (sscanf(params, "u", playerb)) 
		return SendUsageMessage(playerid, "/goto [playerid OR name]"); 
	
	if(!IsPlayerConnected(playerb))
		return SendErrorMessage(playerid, "The player you specified isn't connected."); 
		
	if(PlayerInfo[playerb][pLoggedin] == false)
		return SendErrorMessage(playerid, "The player you specified hasn't logged in yet.");
		
	GetPlayerPos(playerb, PlayerInfo[playerb][pLastPos][0], PlayerInfo[playerb][pLastPos][1], PlayerInfo[playerb][pLastPos][2]);
	//Using the player variable to avoid making other variables; 
	
	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		SetVehiclePos(GetPlayerVehicleID(playerid), PlayerInfo[playerb][pLastPos][0], PlayerInfo[playerb][pLastPos][1] - 1, PlayerInfo[playerb][pLastPos][2]);
	
	else
		SetPlayerPos(playerid, PlayerInfo[playerb][pLastPos][0], PlayerInfo[playerb][pLastPos][1] - 1, PlayerInfo[playerb][pLastPos][2]);
		
	SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(playerb));
	
	if(GetPlayerInterior(playerb) != 0)
		SetPlayerInterior(playerid, GetPlayerInterior(playerb)); 
		
	SendTeleportMessage(playerid);	
	
	if(PlayerInfo[playerid][pInsideProperty] || PlayerInfo[playerid][pInsideBusiness])
	{
		PlayerInfo[playerid][pInsideProperty] = 0; PlayerInfo[playerid][pInsideBusiness] = 0;
	}
	return 1;
}

CMD:gethere(playerid, params[])
{
	if(!PlayerInfo[playerid][pAdmin])
		return SendUnauthMessage(playerid); 
		
	new playerb;
	
	if (sscanf(params, "u", playerb)) 
		return SendUsageMessage(playerid, "/goto [playerid OR name]"); 
	
	if(!IsPlayerConnected(playerb))
		return SendErrorMessage(playerid, "The player you specified isn't connected."); 
		
	if(PlayerInfo[playerb][pLoggedin] == false)
		return SendErrorMessage(playerid, "The player you specified hasn't logged in yet.");
		
	GetPlayerPos(playerid, PlayerInfo[playerid][pLastPos][0], PlayerInfo[playerid][pLastPos][1], PlayerInfo[playerid][pLastPos][2]);
	//Using the player variable to avoid making other variables; 
	
	if(GetPlayerState(playerb) == PLAYER_STATE_DRIVER)
		SetVehiclePos(GetPlayerVehicleID(playerb), PlayerInfo[playerid][pLastPos][0], PlayerInfo[playerid][pLastPos][1] - 1, PlayerInfo[playerid][pLastPos][2]);
		
	else
		SetPlayerPos(playerb, PlayerInfo[playerid][pLastPos][0], PlayerInfo[playerid][pLastPos][1] - 1, PlayerInfo[playerid][pLastPos][2]);
		
	SetPlayerVirtualWorld(playerb, GetPlayerVirtualWorld(playerid));
	
	if(GetPlayerInterior(playerid) != 0)
		SetPlayerInterior(playerb, GetPlayerInterior(playerid)); 
		
	SendTeleportMessage(playerb);
	SendServerMessage(playerid, "%s was teleported to you.", ReturnName(playerb));
	
	return 1;
}

CMD:showmain(playerid, params[])
{
	if(!PlayerInfo[playerid][pAdmin])
		return SendUnauthMessage(playerid); 
		
	new playerb;
	
	if (sscanf(params, "u", playerb)) 
		return SendUsageMessage(playerid, "/showmain [playerid OR name]"); 
	
	if(!IsPlayerConnected(playerb))
		return SendErrorMessage(playerid, "The player you specified isn't connected."); 
		
	if(e_pAccountData[playerb][mLoggedin] == false)
		return SendErrorMessage(playerid, "The player you specified hasn't logged in yet.");
	
	SendServerMessage(playerid, "%s's Master account is \"%s\" (DBID: %i).", ReturnName(playerid), e_pAccountData[playerid][mAccName], e_pAccountData[playerid][mDBID]);	
	return 1;
}

CMD:kick(playerid, params[])
{
	if(!PlayerInfo[playerid][pAdmin])
		return SendUnauthMessage(playerid); 
		
	new playerb, reason[120];
	
	if (sscanf(params, "us[120]", playerb, reason)) 
		return SendUsageMessage(playerid, "/kick [playerid OR name] [reason]"); 
	
	if(!IsPlayerConnected(playerb))
		return SendErrorMessage(playerid, "The player you specified isn't connected."); 
		
	if(PlayerInfo[playerb][pAdmin] > PlayerInfo[playerid][pAdmin])
		return SendErrorMessage(playerid, "You can't kick %s.", ReturnName(playerb)); 
		
	if(strlen(reason) > 56)
	{
		SendClientMessageToAllEx(COLOR_RED, "AdmCmd: %s was kicked by %s, Reason: %.56s", ReturnName(playerb), ReturnName(playerid), reason);
		SendClientMessageToAllEx(COLOR_RED, "AdmCmd: ...%s", reason[56]); 
	}
	else SendClientMessageToAllEx(COLOR_RED, "AdmCmd: %s was kicked by %s, Reason: %s", ReturnName(playerb), ReturnName(playerid), reason);
	
	new insertLog[256];
	
	if(e_pAccountData[playerb][mLoggedin] == false)
	{
		SendServerMessage(playerid, "The player (%s) you kicked was not logged in.", ReturnName(playerb));
	}
	
	mysql_format(this, insertLog, sizeof(insertLog), "INSERT INTO kick_logs (`KickedDBID`, `KickedName`, `Reason`, `KickedBy`, `Date`) VALUES(%i, '%e', '%e', '%e', '%e')",
		PlayerInfo[playerid][pDBID], ReturnName(playerb), reason, ReturnName(playerid), ReturnDate()); 
		
	mysql_tquery(this, insertLog);

	KickEx(playerb);
	return 1;
}

CMD:oban(playerid, params[])
{
	if(!PlayerInfo[playerid][pAdmin])
		return SendUnauthMessage(playerid); 
		
	new 
		insertQuery[256], 
		infoQuery[128], 
		playerb[32], 
		reason[120],
		masterDBID
	;
	
	if(sscanf(params, "s[32]s[120]", playerb, reason))
		return SendUsageMessage(playerid, "/offlineban [players name] [reason]");
		
	foreach(new i : Player)
	{
		if(!strcmp(ReturnName(i), playerb))
		{
			SendServerMessage(playerid, "%s is connected to the server. (ID: %i)", playerb, i);
			return 1;
		}
	}
	
	if(!DoesPlayerExist(playerb))
		return SendErrorMessage(playerid, "%s doesn't exist in the database.", playerb); 
		
	mysql_format(this, infoQuery, sizeof(infoQuery), "SELECT master_dbid FROM characters WHERE char_name = '%e'", playerb);
	new Cache:cache = mysql_query(this, infoQuery);
	
	masterDBID = cache_get_field_content_int(0, "master_dbid", this);
	cache_delete(cache);
	
	mysql_format(this, insertQuery, sizeof(insertQuery), "INSERT INTO bannedlist (CharacterDBID, MasterDBID, CharacterName, Reason, Date, BannedBy, IPAddress) VALUES(%i, %i, '%e', '%e', '%e', '%e', 'Offline')",
		ReturnDBIDFromName(playerb), masterDBID, playerb, reason, ReturnDate(), ReturnName(playerid));
		
	mysql_tquery(this, insertQuery, "OnOfflineBan", "isiiss", playerid, playerb, ReturnDBIDFromName(playerb), masterDBID, reason, ReturnDate());
	return 1;
}

CMD:ban(playerid, params[])
{
	if(!PlayerInfo[playerid][pAdmin])
		return SendUnauthMessage(playerid); 
		
	new playerb, reason[120];
	
	if (sscanf(params, "us[120]", playerb, reason)) 
		return SendUsageMessage(playerid, "/ban [playerid OR name] [reason]"); 
	
	if(!IsPlayerConnected(playerb))
		return SendErrorMessage(playerid, "The player you specified isn't connected."); 
		
	if(PlayerInfo[playerb][pAdmin] > PlayerInfo[playerid][pAdmin])
		return SendErrorMessage(playerid, "You can't ban %s.", ReturnName(playerb)); 
		
	if(strlen(reason) > 56)
	{
		SendClientMessageToAllEx(COLOR_RED, "AdmCmd: %s was banned by %s, Reason: %.56s", ReturnName(playerb), ReturnName(playerid), reason);
		SendClientMessageToAllEx(COLOR_RED, "AdmCmd: ...%s", reason[56]); 
	}
	else SendClientMessageToAllEx(COLOR_RED, "AdmCmd: %s was banned by %s, Reason: %s", ReturnName(playerb), ReturnName(playerid), reason);
	
	new insertLog[256];
	
	if(e_pAccountData[playerb][mLoggedin] == false)
	{
		SendServerMessage(playerid, "The player (%s) you selected isn't logged in.", ReturnName(playerb));
		SendServerMessage(playerid, "Kick them OR use adminsys for further details.");
		return 1;
	}
	
	mysql_format(this, insertLog, sizeof(insertLog), "INSERT INTO bannedlist (`CharacterDBID`, `MasterDBID`, `CharacterName`, `Reason`, `Date`, `BannedBy`, `IpAddress`) VALUES(%i, %i, '%e', '%e', '%e', '%e', '%e')",
		PlayerInfo[playerb][pDBID], e_pAccountData[playerid][mDBID], ReturnName(playerb), reason, ReturnDate(), ReturnName(playerid), ReturnIP(playerb));
	
	mysql_tquery(this, insertLog);
	
	mysql_format(this, insertLog, sizeof(insertLog), "INSERT INTO ban_logs (`CharacterDBID`, `MasterDBID`, `CharacterName`, `Reason`, `BannedBy`, `Date`) VALUES(%i, %i, '%e', '%e', '%e', '%e')",
		PlayerInfo[playerb][pDBID], e_pAccountData[playerid][mDBID], ReturnName(playerb), reason, ReturnName(playerid), ReturnDate());
		
	mysql_tquery(this, insertLog);
	
	KickEx(playerb);
	return 1;
}

CMD:oajail(playerid, params[])
{
	if(!PlayerInfo[playerid][pAdmin])
		return SendUnauthMessage(playerid); 
		
	new insertQuery[256], playerb[32], length, reason[128]; 
	
	if(sscanf(params, "s[32]ds[128]", playerb, length, reason))
		return SendUsageMessage(playerid, "/offlineajail [player name] [time in minutes] [reason]"); 
		
	foreach(new i : Player)
	{
		if(!strcmp(ReturnName(i), playerb))
		{
			SendServerMessage(playerid, "%s is connected to the server. (ID: %i)", playerb, i);
			return 1;
		}
	}
	
	if(!DoesPlayerExist(playerb))
		return SendErrorMessage(playerid, "%s doesn't exist in the database.", playerb); 
		
	mysql_format(this, insertQuery, sizeof(insertQuery), "UPDATE characters SET pOfflinejailed = 1, pOfflinejailedReason = '%e', pAdminjailTime = %i WHERE char_name = '%e'", reason, length * 60, playerb);
	mysql_tquery(this, insertQuery, "OnOfflineAjail", "issi", playerid, playerb, reason, length);

	return 1;
}

CMD:ajail(playerid, params[])
{
	if(!PlayerInfo[playerid][pAdmin])
		return SendUnauthMessage(playerid); 
		
	new playerb, length, reason[120];
	
	if (sscanf(params, "uds[120]", playerb, length, reason)) 
		return SendUsageMessage(playerid, "/ajail [playerid OR name] [time in minutes] [reason]"); 
	
	if(!IsPlayerConnected(playerb))
		return SendErrorMessage(playerid, "The player you specified isn't connected."); 
		
	if(e_pAccountData[playerb][mLoggedin] == false)
		return SendErrorMessage(playerid, "The player you specified isn't logged in."); 
		
	if(length < 1)
		return SendErrorMessage(playerid, "You can't admin jail players for under a minute."); 
		
	if(strlen(reason) > 45)
	{
		SendClientMessageToAllEx(COLOR_RED, "AdmCmd: %s was admin jailed by %s for %d mintues, Reason: %.56s", ReturnName(playerb), ReturnName(playerid), length, reason);
		SendClientMessageToAllEx(COLOR_RED, "AdmCmd: ...%s", reason[56]); 
	}
	else SendClientMessageToAllEx(COLOR_RED, "AdmCmd: %s was admin jailed by %s for %d mintues, Reason: %s", ReturnName(playerb), ReturnName(playerid), length, reason);
	
	ClearAnimations(playerb); 
	
	SetPlayerPos(playerb, 2687.3630, 2705.2537, 22.9472);
	SetPlayerInterior(playerb, 0); SetPlayerVirtualWorld(playerb, 1338);
	
	PlayerInfo[playerb][pAdminjailed] = true;
	PlayerInfo[playerb][pAdminjailTime] = length * 60; 
		
	SaveCharacter(playerb);
	
	new insertLog[250];
	
	mysql_format(this, insertLog, sizeof(insertLog), "INSERT INTO ajail_logs (`JailedDBID`, `JailedName`, `Reason`, `Date`, `JailedBy`, `Time`) VALUES(%i, '%e', '%e', '%e', '%e', %i)",
		PlayerInfo[playerb][pDBID], ReturnName(playerb), reason, ReturnDate(), ReturnName(playerid), length);
		
	mysql_tquery(this, insertLog);
	return 1;
}

CMD:unjail(playerid, params[])
{
	if(!PlayerInfo[playerid][pAdmin])
		return SendUnauthMessage(playerid); 
		
	new playerb;
	
	if (sscanf(params, "u", playerb)) 
		return SendUsageMessage(playerid, "/unjail [playerid OR name]"); 
	
	if(!IsPlayerConnected(playerb))
		return SendErrorMessage(playerid, "The player you specified isn't connected."); 
		
	if(e_pAccountData[playerb][mLoggedin] == false)
		return SendErrorMessage(playerid, "The player you specified isn't logged in."); 
	
	if(PlayerInfo[playerb][pAdminjailed] == false)
		return SendErrorMessage(playerid, "The player you specified isn't admin jailed."); 
		
	SetPlayerVirtualWorld(playerb, 0); SetPlayerInterior(playerb, 0);
	SetPlayerPos(playerb, 1553.0421, -1675.4706, 16.1953);
	
	PlayerInfo[playerb][pAdminjailed] = false;
	PlayerInfo[playerb][pAdminjailTime] = 0;
	
	SaveCharacter(playerb);
	SendClientMessageToAllEx(COLOR_RED, "AdmCmd: %s has been released from admin jail by %s.", ReturnName(playerb), ReturnName(playerid));
	return 1;
}

CMD:setint(playerid, params[])
{
	if(!PlayerInfo[playerid][pAdmin])
		return SendUnauthMessage(playerid); 
		
	new playerb, int, str[128];
	
	if (sscanf(params, "ud", playerb, int)) 
		return SendUsageMessage(playerid, "/setint [playerid OR name] [interior]"); 
	
	if(!IsPlayerConnected(playerb))
		return SendErrorMessage(playerid, "The player you specified isn't connected."); 
		
	if(e_pAccountData[playerb][mLoggedin] == false)
		return SendErrorMessage(playerid, "The player you specified isn't logged in."); 
	
	SetPlayerInterior(playerb, int);
	
	format(str, sizeof(str), "%s set %s's interior to %d.", ReturnName(playerid), ReturnName(playerb), int);
	SendAdminMessage(1, str);
	return 1;
}

CMD:setworld(playerid, params[])
{
	if(!PlayerInfo[playerid][pAdmin])
		return SendUnauthMessage(playerid); 
		
	new playerb, world, str[128];
	
	if (sscanf(params, "ud", playerb, world)) 
		return SendUsageMessage(playerid, "/setworld [playerid OR name] [world]"); 
	
	if(!IsPlayerConnected(playerb))
		return SendErrorMessage(playerid, "The player you specified isn't connected."); 
		
	if(e_pAccountData[playerb][mLoggedin] == false)
		return SendErrorMessage(playerid, "The player you specified isn't logged in."); 
	
	SetPlayerVirtualWorld(playerb, world);
	
	format(str, sizeof(str), "%s set %s's local world to %d.", ReturnName(playerid), ReturnName(playerb), world);
	SendAdminMessage(1, str);
	return 1;
}

CMD:skin(playerid, params[])
{
	if(!PlayerInfo[playerid][pAdmin])
		return SendUnauthMessage(playerid); 
		
	new playerb, skinid, str[128];
	
	if (sscanf(params, "ud", playerb, skinid)) 
		return SendUsageMessage(playerid, "/skin [playerid OR name] [skinid]"); 
	
	if(!IsPlayerConnected(playerb))
		return SendErrorMessage(playerid, "The player you specified isn't connected."); 
		
	if(e_pAccountData[playerb][mLoggedin] == false)
		return SendErrorMessage(playerid, "The player you specified isn't logged in."); 
		
	PlayerInfo[playerb][pLastSkin] = skinid; SetPlayerSkin(playerb, skinid);
	
	format(str, sizeof(str), "%s set %s's skin to %d.", ReturnName(playerid), ReturnName(playerb), skinid);
	SendAdminMessage(1, str);
	return 1;
}

CMD:health(playerid, params[])
{
	if(!PlayerInfo[playerid][pAdmin])
		return SendUnauthMessage(playerid); 
		
	new playerb, health, str[128];
	
	if (sscanf(params, "ud", playerb, health)) 
		return SendUsageMessage(playerid, "/health [playerid OR name] [health]"); 
	
	if(!IsPlayerConnected(playerb))
		return SendErrorMessage(playerid, "The player you specified isn't connected."); 
		
	if(e_pAccountData[playerb][mLoggedin] == false)
		return SendErrorMessage(playerid, "The player you specified isn't logged in."); 
		
	if(health > 150)
		return SendErrorMessage(playerid, "You can't set health over 150."); 
		
	SetPlayerHealth(playerb, health);
	
	format(str, sizeof(str), "%s set %s's health to %d.", ReturnName(playerid), ReturnName(playerb), health);
	SendAdminMessage(1, str);
	return 1;
}

CMD:reports(playerid, params[])
{
	if(!PlayerInfo[playerid][pAdmin])
		return 0;
		
	SendClientMessage(playerid, COLOR_DARKGREEN, "____________________REPORTS____________________");
		
	for (new i = 0; i < sizeof(ReportInfo); i ++)
	{
		if(ReportInfo[i][rReportExists] == true)
		{
			if(strlen(ReportInfo[i][rReportDetails]) > 65)
			{
				sendMessage(playerid, COLOR_REPORT, "%s (ID: %d) | RID: %d | Report: %.65s", ReturnName(ReportInfo[i][rReportBy]), ReportInfo[i][rReportBy], i, ReportInfo[i][rReportDetails]);
				sendMessage(playerid, COLOR_REPORT, "...%s | Pending: %d Sec ago", ReportInfo[i][rReportDetails][65], gettime() - ReportInfo[i][rReportTime]);
			}
			else sendMessage(playerid, COLOR_REPORT, "%s (ID: %d) | RID: %d | Report: %s | Pending: %d Sec ago", ReturnName(ReportInfo[i][rReportBy]), ReportInfo[i][rReportBy], i, ReportInfo[i][rReportDetails], gettime() - ReportInfo[i][rReportTime]);
		}
	}
	return 1;
}

CMD:ar(playerid, params[])
{
	if(!PlayerInfo[playerid][pAdmin])
		return 0;
		
	new reportid;
	
	if (sscanf(params, "d", reportid))
		return SendUsageMessage(playerid, "/acceptreport [report id]"); 
	
	if(ReportInfo[reportid][rReportExists] == false)
		return SendErrorMessage(playerid, "The report ID you specified doesn't exist."); 
		
	SendAdminMessageEx(COLOR_RED, 1, "[Report] Admin %s has accepted report %d", ReturnName(playerid), reportid);
	sendMessage(playerid, COLOR_YELLOW, "You accepted %s's report. [Report: %s]", ReturnName(ReportInfo[reportid][rReportBy]), ReportInfo[reportid][rReportDetails]);
	
	ReportInfo[reportid][rReportExists] = false;
	ReportInfo[reportid][rReportBy] = INVALID_PLAYER_ID; 
	
	//You can include a message to the reporter if you would like;
	return 1; 
}

CMD:dr(playerid, params[])
{
	if(!PlayerInfo[playerid][pAdmin])
		return 0;
		
	new reportid;
	
	if (sscanf(params, "d", reportid))
		return SendUsageMessage(playerid, "/disregardreport [report id]"); 
	
	if(ReportInfo[reportid][rReportExists] == false)
		return SendErrorMessage(playerid, "The report ID you specified doesn't exist."); 
		
	SendAdminMessageEx(COLOR_RED, 1, "[Report] Admin %s has disregarded report %d", ReturnName(playerid), reportid);
	
	ReportInfo[reportid][rReportExists] = false;
	ReportInfo[reportid][rReportBy] = INVALID_PLAYER_ID; 
	
	//You can include a message to the reporter if you would like;
	return 1; 
}

CMD:slap(playerid, params[])
{
	if(!PlayerInfo[playerid][pAdmin])
		return SendUnauthMessage(playerid);
		
	new playerb;
	
	if (sscanf(params, "u", playerb))
		return SendUsageMessage(playerid, "/slap [playerid OR name]");
		
	if(!IsPlayerConnected(playerb))
		return SendErrorMessage(playerid, "The player you specified isn't connected."); 
		
	if(e_pAccountData[playerb][mLoggedin] == false)
		return SendErrorMessage(playerid, "The player you specified isn't logged in."); 
		
	GetPlayerPos(playerb, PlayerInfo[playerb][pLastPos][0], PlayerInfo[playerb][pLastPos][1], PlayerInfo[playerb][pLastPos][2]);
	//Using the player variable to avoid making other variables; 
	
	SetPlayerPos(playerb, PlayerInfo[playerb][pLastPos][0], PlayerInfo[playerb][pLastPos][1], PlayerInfo[playerb][pLastPos][2] + 5); 
	PlayNearbySound(playerb, 1130); //Slap sound;
	
	SendServerMessage(playerid, "%s slapped %s", ReturnName(playerid), ReturnName(playerb));
	if(playerb != playerid) SendServerMessage(playerb, "%s slapped %s", ReturnName(playerid), ReturnName(playerb));
	return 1;
}

CMD:mute(playerid, params[])
{
	if(!PlayerInfo[playerid][pAdmin])
		return SendUnauthMessage(playerid);
		
	new playerb;
	
	if (sscanf(params, "u", playerb))
		return SendUsageMessage(playerid, "/mute [playerid OR name]");
		
	if(!IsPlayerConnected(playerb))
		return SendErrorMessage(playerid, "The player you specified isn't connected."); 
		
	if(e_pAccountData[playerb][mLoggedin] == false)
		return SendErrorMessage(playerid, "The player you specified isn't logged in."); 
		
	if(PlayerInfo[playerb][pMuted] == false)
	{
		PlayerInfo[playerb][pMuted] = true; 
		SendClientMessageToAllEx(COLOR_RED, "%s muted %s.", ReturnName(playerid), ReturnName(playerb)); 
	}
	else
	{
		PlayerInfo[playerb][pMuted] = false;
		SendClientMessageToAllEx(COLOR_RED, "%s unmuted %s.", ReturnName(playerid), ReturnName(playerb));
	}
	return 1;
}

CMD:freeze(playerid, params[])
{
	if(!PlayerInfo[playerid][pAdmin])
		return SendUnauthMessage(playerid);
		
	new playerb, str[128];
	
	if (sscanf(params, "u", playerb))
		return SendUsageMessage(playerid, "/freeze [playerid OR name]");
		
	if(!IsPlayerConnected(playerb))
		return SendErrorMessage(playerid, "The player you specified isn't connected."); 
		
	if(e_pAccountData[playerb][mLoggedin] == false)
		return SendErrorMessage(playerid, "The player you specified isn't logged in."); 
		
	TogglePlayerControllable(playerb, 0);
	
	format(str, sizeof(str), "%s froze player %s.", ReturnName(playerid), ReturnName(playerb));
	SendAdminMessage(1, str);
	return 1;
}

CMD:unfreeze(playerid, params[])
{
	if(!PlayerInfo[playerid][pAdmin])
		return SendUnauthMessage(playerid);
		
	new playerb, str[128];
	
	if (sscanf(params, "u", playerb))
		return SendUsageMessage(playerid, "/unfreeze [playerid OR name]");
		
	if(!IsPlayerConnected(playerb))
		return SendErrorMessage(playerid, "The player you specified isn't connected."); 
		
	if(e_pAccountData[playerb][mLoggedin] == false)
		return SendErrorMessage(playerid, "The player you specified isn't logged in."); 
		
	TogglePlayerControllable(playerb, 1);
	
	format(str, sizeof(str), "%s unfroze player %s.", ReturnName(playerid), ReturnName(playerb));
	SendAdminMessage(1, str);
	return 1;
}

CMD:awp(playerid, params[])
{
	if(!PlayerInfo[playerid][pAdmin])
		return SendUnauthMessage(playerid);
		
	new playerb;
	
	if (sscanf(params, "u", playerb))
		return SendUsageMessage(playerid, "/awp [playerid OR name]");
		
	if(!IsPlayerConnected(playerb))
		return SendErrorMessage(playerid, "The player you specified isn't connected."); 
		
	if(e_pAccountData[playerb][mLoggedin] == false)
		return SendErrorMessage(playerid, "The player you specified isn't logged in."); 
		
	if(PlayerInfo[playerb][pSpectating] != INVALID_PLAYER_ID)
		return SendErrorMessage(playerid, "That player is spectating another player."); 
		
	//if(playerb == playerid) return SendErrorMessage(playerid, "You can't spectate yourself.");
		
	if(GetPlayerState(playerid) != PLAYER_STATE_SPECTATING)
	{
		GetPlayerPos(playerid, PlayerInfo[playerid][pLastPos][0], PlayerInfo[playerid][pLastPos][1], PlayerInfo[playerid][pLastPos][2]);
		
		PlayerInfo[playerid][pLastInterior] = GetPlayerInterior(playerid);
		PlayerInfo[playerid][pLastWorld] = GetPlayerVirtualWorld(playerid);
	}
	
	SetPlayerInterior(playerid, GetPlayerInterior(playerb));
	SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(playerb));
	
	TogglePlayerSpectating(playerid, true); 
	PlayerSpectatePlayer(playerid, playerb);
		
	PlayerInfo[playerid][pSpectating] = playerb; 
	SendServerMessage(playerid, "You're now spectating %s. To stop, use \"/watchoff\".", ReturnName(playerb));
	return 1;
}

CMD:watchoff(playerid, params[])
{
	if(!PlayerInfo[playerid][pAdmin])
		return SendUnauthMessage(playerid);
		
	if (GetPlayerState(playerid) != PLAYER_STATE_SPECTATING)
		return SendErrorMessage(playerid, "You aren't spectating anyone."); 
		
	SendServerMessage(playerid, "You stopped spectating %s.", ReturnName(PlayerInfo[playerid][pSpectating]));
	
	TogglePlayerSpectating(playerid, false); 
	ReturnPlayerGuns(playerid);
	return 1;
}

CMD:gotols(playerid, params[])
{
	if(!PlayerInfo[playerid][pAdmin])
		return SendUnauthMessage(playerid);
		
	SetPlayerPos(playerid, 1514.1836, -1677.8027, 14.0469);
	SetPlayerInterior(playerid, 0); SetPlayerVirtualWorld(playerid, 0);
	
	if(PlayerInfo[playerid][pInsideProperty] || PlayerInfo[playerid][pInsideBusiness])
	{
		PlayerInfo[playerid][pInsideProperty] = 0; PlayerInfo[playerid][pInsideBusiness] = 0;
	}
	
	SendTeleportMessage(playerid);
	return 1;
}

CMD:respawncar(playerid, params[])
{
	if(!PlayerInfo[playerid][pAdmin])
		return SendUnauthMessage(playerid);
		
	new vehicleid, str[128];
	
	if(sscanf(params, "d", vehicleid))
		return SendUsageMessage(playerid, "/respawncar [vehicleid]");
		
	if(!IsValidVehicle(vehicleid))
		return SendErrorMessage(playerid, "You specified an invalid vehicle.");
		
	SetVehicleToRespawn(vehicleid);
	
	foreach(new i : Player)
	{
		if(GetPlayerVehicleID(i) == vehicleid)
		{
			SendServerMessage(i, "The vehicle you're in was respawned by %s.", ReturnName(playerid));
		}
	}
	
	format(str, sizeof(str), "%s respawned vehicle ID %d.", ReturnName(playerid), vehicleid);
	SendAdminMessage(1, str);
	return 1;
}

CMD:gotocar(playerid, params[])
{
	if(!PlayerInfo[playerid][pAdmin])
		return SendUnauthMessage(playerid);
		
	new vehicleid;
	
	if(sscanf(params, "d", vehicleid))
		return SendUsageMessage(playerid, "/gotocar [vehicleid]");
		
	if(!IsValidVehicle(vehicleid))
		return SendErrorMessage(playerid, "You specified an invalid vehicle.");
		
	new Float: fetchPos[3];
	GetVehiclePos(vehicleid, fetchPos[0], fetchPos[1], fetchPos[2]);
	
	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		SetVehiclePos(GetPlayerVehicleID(playerid), fetchPos[0], fetchPos[1], fetchPos[2]);
	
	else
		SetPlayerPos(playerid, fetchPos[0], fetchPos[1], fetchPos[2]);
		
	SendTeleportMessage(playerid);
	
	if(PlayerInfo[playerid][pInsideProperty] || PlayerInfo[playerid][pInsideBusiness])
	{
		PlayerInfo[playerid][pInsideProperty] = 0; PlayerInfo[playerid][pInsideBusiness] = 0;
	}
	return 1;
}

CMD:getcar(playerid, params[])
{
	if(!PlayerInfo[playerid][pAdmin])
		return SendUnauthMessage(playerid);
		
	new 
		vehicleid,
		Float:x,
		Float:y,
		Float:z,
		str[128]
	;
	
	if(sscanf(params, "d", vehicleid))
		return SendUsageMessage(playerid, "/gotocar [vehicleid]");
		
	if(!IsValidVehicle(vehicleid))
		return SendErrorMessage(playerid, "You specified an invalid vehicle.");
	
	GetPlayerPos(playerid, x, y, z);
	
	SetVehiclePos(vehicleid, x, y, z);
	LinkVehicleToInterior(vehicleid, GetPlayerInterior(playerid)); 
	
	format(str, sizeof(str), "%s teleported vehicle ID %i", ReturnName(playerid), vehicleid);
	SendAdminMessage(1, str); 
	
	foreach(new i : Player)
	{
		if(!IsPlayerInAnyVehicle(i))
			continue;
			
		if(GetPlayerVehicleID(i) == vehicleid)
		{
			SendServerMessage(i, "The vehicle you were in (%i) was teleported.", vehicleid); 
		}
	}
	return 1;
}

CMD:listmasks(playerid, params[])
{
	if(!PlayerInfo[playerid][pAdmin])
		return SendUnauthMessage(playerid);
	
	foreach(new i : Player)
	{
		if(!PlayerInfo[i][pMasked])
			continue;
			
		sendMessage(playerid, COLOR_RED, "%s ID: %i %s", ReturnName(i), i, ReturnName(i, 0));
		return 1;
	}
	
	SendServerMessage(playerid, "There aren't any Masked players.");
	return 1;
}

CMD:dropinfo(playerid, params[])
{
	if(!PlayerInfo[playerid][pAdmin])
		return SendUnauthMessage(playerid);
		
	for(new i = 0; i < sizeof(WeaponDropInfo); i++)
	{
		if(!WeaponDropInfo[i][eWeaponDropped])
			continue;
	
		if(IsPlayerInRangeOfPoint(playerid, 5.0, WeaponDropInfo[i][eWeaponPos][0], WeaponDropInfo[i][eWeaponPos][1], WeaponDropInfo[i][eWeaponPos][2]))
		{
			if(GetPlayerVirtualWorld(playerid) == WeaponDropInfo[i][eWeaponWorld])
			{
				SendServerMessage(playerid, "This is a %s with %d ammo dropped by %s.", ReturnWeaponName(WeaponDropInfo[i][eWeaponWepID]), WeaponDropInfo[i][eWeaponWepAmmo], ReturnDBIDName(WeaponDropInfo[i][eWeaponDroppedBy]));
			}
		}
		return 1;
	}
	
	SendServerMessage(playerid, "You aren't near a dropped gun.");
	return 1;
}

CMD:aooc(playerid, params[])
{
	if(!PlayerInfo[playerid][pAdmin])
		return SendUnauthMessage(playerid);
		
	if(isnull(params)) return SendUsageMessage(playerid, "/aooc [text]"); 
	
	if(strcmp(e_pAccountData[playerid][mForumName], "Null"))
		SendClientMessageToAllEx(COLOR_RED, "[AOOC] Admin %s (%s): %s", ReturnName(playerid), e_pAccountData[playerid][mForumName], params);
		
	else SendClientMessageToAllEx(COLOR_RED, "[AOOC] Admin %s: %s", ReturnName(playerid), params);
	return 1;
}

CMD:revive(playerid, params[])
{
	new 
		playerb,
		str[128]
	;
		
	if(sscanf(params, "u", playerb))
		return SendUsageMessage(playerid, "/revive [playerid OR name]"); 
		
	if(!IsPlayerConnected(playerb))
		return SendErrorMessage(playerid, "The player you specified isn't connected."); 
		
	if(!PlayerInfo[playerb][pLoggedin])
		return SendErrorMessage(playerid, "The player you specified isn't logged in."); 
		
	if(GetPlayerTeam(playerb) == PLAYER_STATE_ALIVE)
		return SendErrorMessage(playerid, "That player isn't dead or brutally wounded.");
	
	format(str, sizeof(str), "%s revived player %s.", ReturnName(playerid), ReturnName(playerb));
	SendAdminMessage(1, str); 
	
	SetPlayerTeam(playerb, PLAYER_STATE_ALIVE); 
	SetPlayerHealth(playerb, 100); 
	
	TogglePlayerControllable(playerb, 1); 
	SetPlayerWeather(playerb, globalWeather);  
	
	SetPlayerChatBubble(playerb, "(( Respawned ))", COLOR_WHITE, 21.0, 3000); 
	GameTextForPlayer(playerb, "~b~You were revived", 3000, 4);
	
	SetPVarInt(playerb, "BrokenLeg", 0);
	
	SetPlayerSkillLevel(playerb, WEAPONSKILL_PISTOL, 899);
	SetPlayerSkillLevel(playerb, WEAPONSKILL_MICRO_UZI, 0);
	SetPlayerSkillLevel(playerb, WEAPONSKILL_SPAS12_SHOTGUN, 0);
	SetPlayerSkillLevel(playerb, WEAPONSKILL_AK47, 999);
    SetPlayerSkillLevel(playerb, WEAPONSKILL_DESERT_EAGLE, 999);
    SetPlayerSkillLevel(playerb, WEAPONSKILL_SHOTGUN, 999);
    SetPlayerSkillLevel(playerb, WEAPONSKILL_M4, 999);
    SetPlayerSkillLevel(playerb, WEAPONSKILL_MP5, 999);
	
	ClearDamages(playerb);
	return 1;
}

CMD:arecord(playerid, params[])
{
	new
		playerb[60],
		type[30],
		query[128]
	;
	
	if(sscanf(params, "s[60]s[30]", playerb, type))
		return SendUsageMessage(playerid, "/arecord [character name] [ajail, kicks, bans]");
		
	if(!ReturnDBIDFromName(playerb))
		return SendErrorMessage(playerid, "That character doesn't exist.");
		
	if(!strcmp(type, "ajail"))
	{
		mysql_format(this, query, sizeof(query), "SELECT * FROM ajail_logs WHERE JailedDBID = %i", ReturnDBIDFromName(playerb));
		mysql_tquery(this, query, "OnAjailRecord", "i", playerid);
	}	
	else return SendServerMessage(playerid, "Invalid Parameter.");
	return 1;
}

CMD:listweapons(playerid, params[])
{
	new
		playerb,
		weapon_id[2][13]
	;
	
	if(sscanf(params, "u", playerb))
		return SendUsageMessage(playerid, "/listweapons [playerid OR name]");
	
	if(!IsPlayerConnected(playerb))
		return SendErrorMessage(playerid, "The player you specified isn't connected."); 
		
	if(e_pAccountData[playerb][mLoggedin] == false)
		return SendErrorMessage(playerid, "The player you specified isn't logged in."); 
	
	
	sendMessage(playerid, COLOR_RED, "________** %s's Weapons **________", ReturnName(playerb));
	
	for(new i = 0; i < 13; i++)
	{
		GetPlayerWeaponData(playerid, i, weapon_id[0][i], weapon_id[1][i]); 
		
		if(!weapon_id[0][i])
			continue;
			
		sendMessage(playerid, COLOR_GRAD1, "%s [Ammo: %d]", ReturnWeaponName(weapon_id[0][i]), weapon_id[1][i]);
	}
		
	return 1;
}

//Level 2 Admin commands:
CMD:armor(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 2)
		return SendUnauthMessage(playerid); 
		
	new playerb, armor, str[128];
	
	if (sscanf(params, "ud", playerb, armor)) 
		return SendUsageMessage(playerid, "/armor [playerid OR name] [armor]"); 
	
	if(!IsPlayerConnected(playerb))
		return SendErrorMessage(playerid, "The player you specified isn't connected."); 
		
	if(e_pAccountData[playerb][mLoggedin] == false)
		return SendErrorMessage(playerid, "The player you specified isn't logged in."); 
		
	if(armor > 200)
		return SendErrorMessage(playerid, "You can't set armor above 200."); 
		
	SetPlayerArmour(playerid, armor);
	
	format(str, sizeof(str), "%s set %s's Armor to %d.", ReturnName(playerid), ReturnName(playerb), armor);
	SendAdminMessage(1, str);
	return 1;
}

CMD:clearreports(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 2)
		return 0;
		
	new reportCount = 0;
	
	for (new i = 0; i < sizeof(ReportInfo); i ++)
	{
		if(ReportInfo[i][rReportExists] == true)
		{
			reportCount++;
		}
	}
	if(reportCount)
	{
		new string[128]; 
		
		format(string, sizeof(string), "{FFFFFF}Are you sure you want to clear ALL active reports?\n\nThere are {FF6347}%d{FFFFFF} report(s).", reportCount);
		ConfirmDialog(playerid, "Confirmation", string, "ClearReports", reportCount); 
	}
	else return SendServerMessage(playerid, "There are no active reports to clear.");
	return 1;
}

CMD:p2p(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 2)
		return SendUnauthMessage(playerid);
		
	new playerb, targetid, str[128]; 
	
	if(sscanf(params, "uu", playerb, targetid))
		return SendUsageMessage(playerid, "/p2p [playerid] [targetid]");
	
	if (!IsPlayerConnected(playerb) || !IsPlayerConnected(targetid))
		return SendErrorMessage(playerid, "A player you specified isn't connected to the server."); 
		
	if (e_pAccountData[playerb][mLoggedin] == false || e_pAccountData[targetid][mLoggedin] == false)
		return SendErrorMessage(playerid, "A player you specified isn't logged in."); 
		
	format(str, sizeof(str), "%s teleported player %s to %s.", ReturnName(playerid), ReturnName(playerb), ReturnName(targetid));
	SendAdminMessage(1, str);
	
	GetPlayerPos(targetid, PlayerInfo[targetid][pLastPos][0], PlayerInfo[targetid][pLastPos][1], PlayerInfo[targetid][pLastPos][2]);
	//Using the player variable to avoid making other variables; 
	
	SetPlayerPos(playerb, PlayerInfo[targetid][pLastPos][0], PlayerInfo[targetid][pLastPos][1], PlayerInfo[targetid][pLastPos][2]);
	SetPlayerInterior(playerb, GetPlayerInterior(targetid)); SetPlayerVirtualWorld(playerb, GetPlayerVirtualWorld(targetid)); 
	
	SendTeleportMessage(playerb);
	return 1;
}

CMD:givegun(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 2)
		return SendUnauthMessage(playerid);
		
	new playerb, weaponid, ammo, idx, str[128];
	
	if(sscanf(params, "uii", playerb, weaponid, ammo))
	{
		SendUsageMessage(playerid, "/givegun [playerid OR name] [weaponid] [ammo]");
		SendServerMessage(playerid, "These weapons save to the players account."); 
		return 1;
	}
	
	if (!IsPlayerConnected(playerb))
		return SendErrorMessage(playerid, "A player you specified isn't connected to the server."); 
		
	if (e_pAccountData[playerb][mLoggedin] == false)
		return SendErrorMessage(playerid, "A player you specified isn't logged in."); 
		
	if(weaponid < 1 || weaponid > 46 || weaponid == 35 || weaponid == 36 || weaponid == 37 || weaponid == 38 || weaponid == 39)
	    return SendErrorMessage(playerid, "You have specified an invalid weaponid.");
		
	if(ammo < 1)return SendErrorMessage(playerid, "You specified invalid ammo amount.");
	
	idx = ReturnWeaponIDSlot(weaponid); 
	
	if(PlayerInfo[playerb][pWeapons][idx])
		SendServerMessage(playerid, "%s's %s and %d ammo was removed.", ReturnName(playerb), ReturnWeaponName(PlayerInfo[playerb][pWeapons][idx]), PlayerInfo[playerb][pWeaponsAmmo][idx]);
	
	GivePlayerWeapon(playerb, weaponid, ammo); 
	
	PlayerInfo[playerb][pWeapons][idx] = weaponid;
	PlayerInfo[playerb][pWeaponsAmmo][idx] = ammo; 
	
	format(str, sizeof(str), "%s gave %s a %s and %d ammo.", ReturnName(playerid), ReturnName(playerb), ReturnWeaponName(weaponid), ammo);
	SendAdminMessage(2, str);
	
	SendServerMessage(playerb, "You were given %s and %d ammo.", ReturnWeaponName(weaponid), ammo);
	return 1;
}

CMD:clearpguns(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 2)
		return SendUnauthMessage(playerid);
		
	new playerb, displayString[128], str[128]; 
	
	if(sscanf(params, "u", playerb))
		return SendUsageMessage(playerid, "/clearpguns [playerid OR name]");
	
	if(!IsPlayerConnected(playerb))
		return SendErrorMessage(playerid, "The player you specified isn't connected."); 
		
	if(e_pAccountData[playerb][mLoggedin] == false)
		return SendErrorMessage(playerid, "The player you specified isn't logged in."); 
		
		
	for(new i = 0; i < 4; i ++)
	{
		if(PlayerInfo[playerb][pWeaponsAmmo][i] > 0)
		{
			format(displayString, sizeof(displayString), "%s%s - %d Ammo\n", displayString, ReturnWeaponName(PlayerInfo[playerb][pWeapons][i]), PlayerInfo[playerb][pWeaponsAmmo][i]);
			
			PlayerInfo[playerb][pWeapons][i] = 0;
			PlayerInfo[playerb][pWeaponsAmmo][i] = 0;
		}
	}
	
	ShowPlayerDialog(playerid, DIALOG_DEFAULT, DIALOG_STYLE_LIST, "Weapons Cleared:", displayString, "<<", ""); 
	TakePlayerGuns(playerb); 
	
	format(str, sizeof(str), "%s cleared %s's weapons.", ReturnName(playerid), ReturnName(playerb));
	SendAdminMessage(1, str);
	return 1;
}

CMD:gotoproperty(playerid, params[])
{
	new id;
	
	if(PlayerInfo[playerid][pAdmin] < 2)
		return SendUnauthMessage(playerid);
	
	if(sscanf(params, "i", id))
		return SendUsageMessage(playerid, "/gotoproperty [property ID]");
		
	if(!PropertyInfo[id][ePropertyDBID] || id > MAX_PROPERTY)
		return SendErrorMessage(playerid, "The property you specified doesn't exist.");
		
	SetPlayerPos(playerid, PropertyInfo[id][ePropertyEntrance][0], PropertyInfo[id][ePropertyEntrance][1], PropertyInfo[id][ePropertyEntrance][2]);
	
	SetPlayerVirtualWorld(playerid, PropertyInfo[id][ePropertyEntranceWorld]);
	SetPlayerInterior(playerid, PropertyInfo[id][ePropertyEntranceInterior]);
	
	SendServerMessage(playerid, "You teleported to Property %i.", id);
	
	if(PlayerInfo[playerid][pInsideProperty] || PlayerInfo[playerid][pInsideBusiness])
	{
		PlayerInfo[playerid][pInsideProperty] = 0; PlayerInfo[playerid][pInsideBusiness] = 0;
	}
	return 1;
}

CMD:gotobusiness(playerid, params[])
{
	new id;
	
	if(PlayerInfo[playerid][pAdmin] < 2)
		return SendUnauthMessage(playerid);
	
	if(sscanf(params, "i", id))
		return SendUsageMessage(playerid, "/gotobusiness [business ID]");
		
	if(!BusinessInfo[id][eBusinessDBID] || id > MAX_BUSINESS)
		return SendErrorMessage(playerid, "The business you specified doesn't exist.");
		
	SetPlayerPos(playerid, BusinessInfo[id][eBusinessEntrance][0], BusinessInfo[id][eBusinessEntrance][1], BusinessInfo[id][eBusinessEntrance][2]); 
	SendServerMessage(playerid, "You teleported to business %i.", id); 
	
	if(PlayerInfo[playerid][pInsideProperty] || PlayerInfo[playerid][pInsideBusiness])
	{
		PlayerInfo[playerid][pInsideProperty] = 0; PlayerInfo[playerid][pInsideBusiness] = 0;
	}
	return 1;
}

CMD:gotofaction(playerid, params[])
{
	new id;
	
	if(PlayerInfo[playerid][pAdmin] < 2)
		return SendUnauthMessage(playerid);
	
	if(sscanf(params, "i", id))
		return SendUsageMessage(playerid, "/gotofaction [faction ID]");
		
	if(!FactionInfo[id][eFactionDBID] || id > MAX_FACTIONS)
		return SendErrorMessage(playerid, "The faction you specified doesn't exist.");
		
	SetPlayerPos(playerid, FactionInfo[id][eFactionSpawn][0], FactionInfo[id][eFactionSpawn][1], FactionInfo[id][eFactionSpawn][2]);
	
	SetPlayerVirtualWorld(playerid, FactionInfo[id][eFactionSpawnWorld]);
	SetPlayerInterior(playerid, FactionInfo[id][eFactionSpawnInt]); 
	
	SendServerMessage(playerid, "You teleported to %s's spawn point.", ReturnFactionNameEx(id)); 

	if(PlayerInfo[playerid][pInsideProperty] || PlayerInfo[playerid][pInsideBusiness])
	{
		PlayerInfo[playerid][pInsideProperty] = 0; PlayerInfo[playerid][pInsideBusiness] = 0;
	}
	return 1;
}

CMD:gotopoint(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 2)
		return SendUnauthMessage(playerid);

	new
		Float:x,
		Float:y,
		Float:z,
		interior
	; 
	
	if(sscanf(params, "fffi", x, y, z, interior))
		return SendUsageMessage(playerid, "/gotopoint [x] [y] [z] [interior id]"); 
		
	SetPlayerPos(playerid, x, y, z);
	SetPlayerInterior(playerid, interior);
	
	SendTeleportMessage(playerid);
	
	if(PlayerInfo[playerid][pInsideProperty] || PlayerInfo[playerid][pInsideBusiness])
	{
		PlayerInfo[playerid][pInsideProperty] = 0; PlayerInfo[playerid][pInsideBusiness] = 0;
	}
	return 1;
}

CMD:noooc(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 2)
		return SendUnauthMessage(playerid);
		
	new
		str[128]
	;
		
	if(!oocEnabled)
	{
		format(str, sizeof(str), "%s enabled OOC chat.", ReturnName(playerid));
		SendAdminMessage(1, str); 
		
		SendClientMessageToAll(COLOR_GREY, "OOC chat has been enabled by an admin."); 
		oocEnabled = true;
	}
	else
	{
		format(str, sizeof(str), "%s disabled OOC chat.", ReturnName(playerid));
		SendAdminMessage(1, str); 
		
		SendClientMessageToAll(COLOR_GREY, "OOC chat has been disabled by an admin."); 
		oocEnabled = false;
	}
	return 1;
}

CMD:backup(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 2)
		return SendUnauthMessage(playerid);
	
	if(isnull(params))
		return SendUsageMessage(playerid, "/backup [players, all]"); 
		
	new 
		str[128];
		
	if(!strcmp(params, "players"))
	{
		foreach(new i : Player)
		{
			if(!PlayerInfo[playerid][pDBID])
				continue;
				
			SaveCharacter(i); 
		}
		
		format(str, sizeof(str), "%s backed up player data. (%i)", ReturnName(playerid), GetPlayerPoolSize());
		SendAdminMessage(1, str); 
	}
	else if(!strcmp(params, "all"))
	{
		SaveFactions();
		SaveProperties();
		SaveBusinesses();
		
		SendClientMessageToAllEx(COLOR_RED, "Admin %s backed up server data.", ReturnName(playerid));
	}
	else return SendErrorMessage(playerid, "Invalid Paramater.");	
	return 1;
}

CMD:repair(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 2)
		return SendUnauthMessage(playerid);
		
	new 
		str[128],
		vehicleid,
		Float:angle
	;
	
	if(sscanf(params, "i", vehicleid))
		return SendUsageMessage(playerid, "/repair [vehicle id]"); 
		
	if(!IsValidVehicle(vehicleid))
		return SendErrorMessage(playerid, "You specified an invalid vehicle."); 
		
	format(str, sizeof(str), "%s repaired vehicle ID %i.", ReturnName(playerid), vehicleid);
	SendAdminMessage(1, str);
	
	RepairVehicle(vehicleid);
	SetVehicleHealth(vehicleid, 900); 
	
	GetVehicleZAngle(vehicleid, angle);
	SetVehicleZAngle(vehicleid, angle);
	return 1; 
}

//Level 3 Admin commands:
CMD:spawncar(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 3)
		return 0;
		
	new vehicleid = INVALID_VEHICLE_ID, modelid, color1, color2, siren, str[128]; 
	
	if(sscanf(params, "iiiI(0)", modelid, color1, color2, siren))
	{
		SendUsageMessage(playerid, "/spawncar [model id] [color1] [color2] [siren default 0]");
		SendServerMessage(playerid, "These vehicles are temporary. Siren allows you to turn sirens on using horn."); 
		return 1;
	}
	
	if(gettime() - lastVehicleSpawn[playerid] < 5)
		return SendServerMessage(playerid, "You need to wait before spawning another vehicle.");
	
	if(modelid < 400 || modelid > 611)
		return SendErrorMessage(playerid, "You specified an invalid model.");
		
	if(color1 < 0 || color2 < 0 || color1 > 255 || color2 > 255)
		return SendErrorMessage(playerid, "A color you specified was invalid."); 
		
	GetPlayerPos(playerid, PlayerInfo[playerid][pLastPos][0], PlayerInfo[playerid][pLastPos][1], PlayerInfo[playerid][pLastPos][2]);
	//Using the player variable to avoid making other variables; 
	
	vehicleid = CreateVehicle(modelid, PlayerInfo[playerid][pLastPos][0], PlayerInfo[playerid][pLastPos][1], PlayerInfo[playerid][pLastPos][2], 0, color1, color2, -1, siren);
	
	if(vehicleid != INVALID_VEHICLE_ID)
	{
		VehicleInfo[vehicleid][eVehicleAdminSpawn] = true;
		VehicleInfo[vehicleid][eVehicleModel] = modelid;
		
		VehicleInfo[vehicleid][eVehicleColor1] = color1;
		VehicleInfo[vehicleid][eVehicleColor2] = color2;
	}
	
	lastVehicleSpawn[playerid] = gettime();
	PutPlayerInVehicle(playerid, vehicleid, 0);
	
	format(str, sizeof(str), "%s spawned a temporary %s.", ReturnName(playerid), ReturnVehicleName(vehicleid));
	SendAdminMessage(3, str);
	return 1;
}

CMD:despawncar(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 3)
		return 0;
		
	new vehicleid, str[128];
	
	if(sscanf(params, "d", vehicleid))
		return SendUsageMessage(playerid, "/despawncar [vehicleid]");
	
	if(!IsValidVehicle(vehicleid))
		return SendErrorMessage(playerid, "You specified an invalid vehicle.");
		
	if(VehicleInfo[vehicleid][eVehicleAdminSpawn] == false)
		return SendErrorMessage(playerid, "You can't despawn a private / faction vehicle."); 
	
	format(str, sizeof(str), "%s despawned %s (%d).", ReturnName(playerid), ReturnVehicleName(vehicleid), vehicleid);
	SendAdminMessage(3, str);
		
	ResetVehicleVars(vehicleid); DestroyVehicle(vehicleid);
	return 1;
}

CMD:pcar(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 3)
		return SendUnauthMessage(playerid);
		
	new playerb, modelid, color1, color2;
	
	if(sscanf(params, "uiii", playerb, modelid, color1, color2))
	{
		SendUsageMessage(playerid, "/pcar [playerid OR name] [model id] [color1] [color2]");
		SendServerMessage(playerid, "This issues a permanent vehicle to a player.");
		return 1;
	}
	
	if (!IsPlayerConnected(playerb))
		return SendErrorMessage(playerid, "A player you specified isn't connected to the server."); 
		
	if (e_pAccountData[playerb][mLoggedin] == false)
		return SendErrorMessage(playerid, "A player you specified isn't logged in."); 
	
	if(modelid < 400 || modelid > 611)
		return SendErrorMessage(playerid, "You specified an invalid model.");
		
	if(color1 < 0 || color2 < 0 || color1 > 255 || color2 > 255)
		return SendErrorMessage(playerid, "A color you specified was invalid."); 
		
	for(new i = 1; i < MAX_PLAYER_VEHICLES; i++)
	{
		if(!PlayerInfo[playerb][pOwnedVehicles][i])
		{
			playerInsertID[playerb] = i;
			break;
		}
	}
	if(!playerInsertID[playerb])
	{
		SendErrorMessage(playerid, "%s doesn't have any free vehicle slots.", ReturnName(playerb));
	}
	else
	{
		new insertQuery[256];
		
		mysql_format(this, insertQuery, sizeof(insertQuery), "INSERT INTO vehicles (`VehicleOwnerDBID`, `VehicleModel`, `VehicleColor1`, `VehicleColor2`, `VehicleParkPosX`, `VehicleParkPosY`, `VehicleParkPosZ`, `VehicleParkPosA`) VALUES(%i, %i, %i, %i, 1705.4175, -1485.9148, 13.3828, 87.5097)",
			PlayerInfo[playerb][pDBID], modelid, color1, color2);
		mysql_tquery(this, insertQuery, "Query_AddPlayerVehicle", "ii", playerid, playerb);
	}
	
	return 1;
}

CMD:setstats(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 3)
		return SendUnauthMessage(playerid);
		
	new 
		playerb, 
		statid, 
		value,
		str[128]
	;
	
	if(sscanf(params, "uiI(-1)", playerb, statid, value))
	{
		SendUsageMessage(playerid, "/setstats [playerid OR name] [stat code] [value]"); 
		SendClientMessage(playerid, COLOR_WHITE, "1. Faction Rank, 2. Mask, 3. Radio, 4. Bank Money, 5. Level,");
		SendClientMessage(playerid, COLOR_WHITE, "6. EXP, 7. Paycheck, 8. Donator");
		return 1;
	}
	
	if(!IsPlayerConnected(playerb))
		return SendErrorMessage(playerid, "The player you specified isn't connected.");
		
	if(!PlayerInfo[playerid][pLoggedin])
		return SendErrorMessage(playerid, "The player you specified isn't logged in."); 
	
	switch(statid)
	{
		case 1: 
		{
			if(value == -1)
				return SendUsageMessage(playerid, "/setstats [playerid OR name] 1 [value required]"); 
		
			if(value < 1 && value != -1 || value > 20)
				return SendErrorMessage(playerid, "You specified an invalid rank. (1-20)");
				
			PlayerInfo[playerb][pFactionRank] = value;
			SaveCharacter(playerb); 
			
			format(str, sizeof(str), "%s set %s's faction rank to %i.", ReturnName(playerid), ReturnName(playerb), value); 
			SendAdminMessage(3, str); 
		}
		case 2:
		{
			if(!PlayerInfo[playerb][pHasMask])
				PlayerInfo[playerb][pHasMask] = true;
				
			else PlayerInfo[playerb][pHasMask] = false;
			
			format(str, sizeof(str), "%s %s %s's Mask.", ReturnName(playerid), (PlayerInfo[playerb][pHasMask] != true) ? ("took") : ("set"), ReturnName(playerb));
			SendAdminMessage(3, str); 
		}
		case 3:
		{
			if(!PlayerInfo[playerb][pHasRadio])
				PlayerInfo[playerb][pHasRadio] = true;
				
			else PlayerInfo[playerb][pHasRadio] = false;
			
			format(str, sizeof(str), "%s %s %s's Radio.", ReturnName(playerid), (PlayerInfo[playerb][pHasRadio] != true) ? ("took") : ("set"), ReturnName(playerb));
			SendAdminMessage(3, str);
		}
		case 4:
		{
			if(value == -1)
				return SendUsageMessage(playerid, "/setstats [playerid OR name] 4 [value required]"); 
		
			format(str, sizeof(str), "%s set %s's bank money: $%s (Previously $%s)", ReturnName(playerid), ReturnName(playerb), MoneyFormat(value), MoneyFormat(PlayerInfo[playerb][pBank])); 
			SendAdminMessage(3, str);
			
			PlayerInfo[playerb][pBank] = value;
			SaveCharacter(playerb);
		}
		case 5:
		{
			if(value == -1)
				return SendUsageMessage(playerid, "/setstats [playerid OR name] 5 [value required]"); 
		
			if(value < 1 && value != -1)
				return SendErrorMessage(playerid, "Player levels can't go below one.");

			format(str, sizeof(str), "%s set %s's level: %i (Previously %i)", ReturnName(playerid), ReturnName(playerb), value, PlayerInfo[playerb][pLevel]);
			SendAdminMessage(3, str); 
			
			PlayerInfo[playerb][pLevel] = value; SetPlayerScore(playerb, value);
			SaveCharacter(playerb);
		}
		case 6:
		{
			if(value == -1)
				return SendUsageMessage(playerid, "/setstats [playerid OR name] 6 [value required]"); 
		
			format(str, sizeof(str), "%s set %s's EXP: %i (Previously %i)", ReturnName(playerid), ReturnName(playerb), value, PlayerInfo[playerb][pEXP]);
			SendAdminMessage(3, str);
			
			PlayerInfo[playerb][pEXP] = value;
			SaveCharacter(playerb);
		}
		case 7:
		{
			if(value == -1)
				return SendUsageMessage(playerid, "/setstats [playerid OR name] 7 [value required]");
				
			format(str, sizeof(str), "%s set %s's EXP: %i (Previously %i)", ReturnName(playerid), ReturnName(playerb), value, PlayerInfo[playerb][pPaycheck]);
			SendAdminMessage(3, str);
			
			PlayerInfo[playerb][pPaycheck] = value; 
			SaveCharacter(playerb);
		}
		case 8:
		{
			if(value == -1)
				return SendUsageMessage(playerid, "/setstats [playerid OR name] 8 [value required]");
				
			format(str, sizeof(str), "%s set %s's donator: %i", ReturnName(playerid), ReturnName(playerb), value);
			SendAdminMessage(3, str);

			PlayerInfo[playerb][pDonator] = value;
			SaveCharacter(playerb);
		}
	}
	return 1;
}

CMD:givemoney(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 3)
		return SendUnauthMessage(playerid);
		
	new playerb, value, str[128];
	
	if(sscanf(params, "ui", playerb, value))
		return SendUsageMessage(playerid, "/givemoney [playerid OR name] [amount]");
		
	if(!IsPlayerConnected(playerb))
		return SendErrorMessage(playerid, "The player you specified isn't connected.");
		
	if(!PlayerInfo[playerid][pLoggedin])
		return SendErrorMessage(playerid, "The player you specified isn't logged in."); 
		
	GiveMoney(playerb, value);
	SendServerMessage(playerb, "You received $%s from Admin %s.", MoneyFormat(value), ReturnName(playerid));

	format(str, sizeof(str), "%s gave $%s to %s", ReturnName(playerid), MoneyFormat(value), ReturnName(playerb));
	SendAdminMessage(3, str);
	return 1;
}

CMD:setcar(playerid, params[])
{
	new	vehicleid, a_str[60], b_str[60];
	new str[128], value, Float:life; 
	
	if(PlayerInfo[playerid][pAdmin] < 3)
		return SendUnauthMessage(playerid);
		
	if(sscanf(params, "is[60]S()[60]", vehicleid, a_str, b_str))
	{
		SendUsageMessage(playerid, "/setcar [vehicleid] [params]");
		SendClientMessage(playerid, COLOR_RED, "[ ! ]{FFFFFF} locklvl, alarmlvl, immoblvl, timesdestroyed, fuel");
		SendClientMessage(playerid, COLOR_RED, "[ ! ]{FFFFFF} enginelife, batterylife, color1, color2, paintjob, plates."); 
		return 1;
	}
	
	if(!IsValidVehicle(vehicleid))
		return SendErrorMessage(playerid, "You specified an invalid vehicle ID."); 
		
	if(VehicleInfo[vehicleid][eVehicleAdminSpawn])
		return SendErrorMessage(playerid, "The vehicle you specified is admin spawned.");
		
	if(!strcmp(a_str, "locklvl"))
	{
		if(sscanf(b_str, "i", value))
			return SendUsageMessage(playerid, "/setcar vehicleid locklvl [1-4]"); 
			
		if(value > 4 || value < 1)
			return SendErrorMessage(playerid, "Invalid Value.");
		
		format(str, sizeof(str), "%s set vehicle ID %i's lock level to %i.", ReturnName(playerid), vehicleid, value); 
		SendAdminMessage(3, str); 
		
		VehicleInfo[vehicleid][eVehicleLockLevel] = value; 
		SaveVehicle(vehicleid);
	}
	else if(!strcmp(a_str, "fuel"))
	{
	    new Float: fuel;
		if(sscanf(b_str, "f", fuel))
			return SendUsageMessage(playerid, "/setcar vehicleid fuel [amount]");

		if(fuel > 100 || fuel < 1)
			return SendErrorMessage(playerid, "Invalid Value.");

		format(str, sizeof(str), "%s set vehicle ID %i's fuel to %i.", ReturnName(playerid), vehicleid, fuel);
		SendAdminMessage(3, str);

		VehicleInfo[vehicleid][eVehicleFuel] = fuel;
		SaveVehicle(vehicleid);
	}
	else if(!strcmp(a_str, "alarmlvl"))
	{
		if(sscanf(b_str, "i", value))
			return SendUsageMessage(playerid, "/setcar vehicleid alarmlvl [1-4]"); 
			
		if(value > 4 || value < 1)
			return SendErrorMessage(playerid, "Invalid Value.");
		
		format(str, sizeof(str), "%s set vehicle ID %i's alarm level to %i.", ReturnName(playerid), vehicleid, value); 
		SendAdminMessage(3, str); 
		
		VehicleInfo[vehicleid][eVehicleAlarmLevel] = value; 
		SaveVehicle(vehicleid);
	}
	else if(!strcmp(a_str, "immoblvl"))
	{
		if(sscanf(b_str, "i", value))
			return SendUsageMessage(playerid, "/setcar vehicleid immoblvl [1-5]"); 
			
		if(value > 5 || value < 1)
			return SendErrorMessage(playerid, "Invalid Value.");
		
		format(str, sizeof(str), "%s set vehicle ID %i's immobiliser level to %i.", ReturnName(playerid), vehicleid, value); 
		SendAdminMessage(3, str); 
		
		VehicleInfo[vehicleid][eVehicleImmobLevel] = value; 
		SaveVehicle(vehicleid);
	}
	else if(!strcmp(a_str, "timesdestroyed"))
	{
		if(sscanf(b_str, "i", value))
			return SendUsageMessage(playerid, "/setcar vehicleid timesdestroyed [value]");
			
		format(str, sizeof(str), "%s set vehicle ID %i's time destroyed to %i. (Previously %i)", ReturnName(playerid), vehicleid, value, VehicleInfo[vehicleid][eVehicleTimesDestroyed]); 
		SendAdminMessage(3, str); 
		
		VehicleInfo[vehicleid][eVehicleTimesDestroyed] = value; 
		SaveVehicle(vehicleid);
	}
	else if(!strcmp(a_str, "enginelife"))
	{
		if(sscanf(b_str, "f", life))
			return SendUsageMessage(playerid, "/setcar vehicleid enginelife [float]");
			
		if(life > 100.00 || life < 0.00)
			return SendErrorMessage(playerid, "You can't set that value. (0.00 - 100.00)");
			
		format(str, sizeof(str), "%s set vehicle ID %i's engine life to %.2f. (Previously %.2f)", ReturnName(playerid), vehicleid, life, VehicleInfo[vehicleid][eVehicleEngine]);
		SendAdminMessage(3, str); 
		
		VehicleInfo[vehicleid][eVehicleEngine] = life;
		SaveVehicle(vehicleid);
	}
	else if(!strcmp(a_str, "batterylife"))
	{
		if(sscanf(b_str, "f", life))
			return SendUsageMessage(playerid, "/setcar vehicleid batterylife [float]");
			
		if(life > 100.00 || life < 0.00)
			return SendErrorMessage(playerid, "You can't set that value. (0.00 - 100.00)");
			
		format(str, sizeof(str), "%s set vehicle ID %i's battery life to %.2f. (Previously %.2f)", ReturnName(playerid), vehicleid, life, VehicleInfo[vehicleid][eVehicleBattery]);
		SendAdminMessage(3, str); 
		
		VehicleInfo[vehicleid][eVehicleBattery] = life;
		SaveVehicle(vehicleid);
	}
	else if(!strcmp(a_str, "color1"))
	{
		if(sscanf(b_str, "i", value))
			return SendUsageMessage(playerid, "/setcar vehicleid color1 [value]");
			
		if(value > 255 || value < 0)
			return SendErrorMessage(playerid, "You specified an invalid color. (0-255)");
			
		format(str, sizeof(str), "%s set vehicle ID %i's color1 to %i. (Previously %i)", ReturnName(playerid), vehicleid, value, VehicleInfo[vehicleid][eVehicleColor1]);
		SendAdminMessage(3, str);
		
		SendClientMessage(playerid, COLOR_WHITE, "The vehicle needs to be respawned to take affect.");
		
		VehicleInfo[vehicleid][eVehicleColor1] = value;
		SaveVehicle(vehicleid);
	}
	else if(!strcmp(a_str, "color2"))
	{
		if(sscanf(b_str, "i", value))
			return SendUsageMessage(playerid, "/setcar vehicleid color2 [value]");
			
		if(value > 255 || value < 0)
			return SendErrorMessage(playerid, "You specified an invalid color. (0-255)");
			
		format(str, sizeof(str), "%s set vehicle ID %i's color2 to %i. (Previously %i)", ReturnName(playerid), vehicleid, value, VehicleInfo[vehicleid][eVehicleColor2]);
		SendAdminMessage(3, str);
		
		SendClientMessage(playerid, COLOR_WHITE, "The vehicle needs to be respawned to take affect.");
		
		VehicleInfo[vehicleid][eVehicleColor2] = value;
		SaveVehicle(vehicleid);
	}
	else if(!strcmp(a_str, "paintjob"))
	{
		if(sscanf(b_str, "i", value))
			return SendUsageMessage(playerid, "/setcar vehicleid paintjob [0-2, 3 to remove]");
			
		if(value > 255 || value < 0)
			return SendErrorMessage(playerid, "You specified an invalid color. (0-255)");
			
		format(str, sizeof(str), "%s set vehicle ID %i's paintjob to %i. (Previously %i)", ReturnName(playerid), vehicleid, value, VehicleInfo[vehicleid][eVehiclePaintjob]);
		SendAdminMessage(3, str);
		
		SendClientMessage(playerid, COLOR_WHITE, "The vehicle needs to be respawned to take affect.");
		
		VehicleInfo[vehicleid][eVehiclePaintjob] = value;
		SaveVehicle(vehicleid);
	}
	else if(!strcmp(a_str, "plates"))
	{
		new
			plates[32]; 
			
		if(sscanf(b_str, "s[32]", plates))
			return SendUsageMessage(playerid, "/setcar vehicleid plates [plates]"); 
			
		if(strlen(plates) > 6 || strlen(plates) < 6)
			return SendErrorMessage(playerid, "You need to provide a 6 digit plate. (California license plate: Q123Q1)");
			
		format(str, sizeof(str), "%s set vehicle ID %i's plates to \"%s\". (Previously %s)", ReturnName(playerid), vehicleid, plates, VehicleInfo[vehicleid][eVehiclePlates]);
		SendAdminMessage(3, str);
		
		format(VehicleInfo[vehicleid][eVehiclePlates], 32, "%s", plates); 
		SaveVehicle(vehicleid);
	}
	return 1;
}

CMD:setcarparams(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 3)
		return SendUnauthMessage(playerid);
	
	new vehicleid, a_str[60], b_str[60]; 
	new str[128];
	
	if(sscanf(params, "is[60]S()[60]", vehicleid, a_str, b_str))
	{
		SendUsageMessage(playerid, "/setcarparams [vehicleid] [params]");
		SendClientMessage(playerid, COLOR_RED, "[ ! ]{FFFFFF} engine, lights, lock, health"); 
		return 1;
	}
		
	if(!IsValidVehicle(vehicleid))
		return SendErrorMessage(playerid, "You specified an invalid vehicleid."); 
		
	if(!strcmp(a_str, "engine"))
	{
		if(!VehicleInfo[vehicleid][eVehicleEngineStatus])
		{
			ToggleVehicleEngine(vehicleid, true); VehicleInfo[vehicleid][eVehicleEngineStatus] = true;
			format(str, sizeof(str), "%s turned vehicle ID %i's engine on.", ReturnName(playerid), vehicleid);
		}
		else
		{
			ToggleVehicleEngine(vehicleid, false); VehicleInfo[vehicleid][eVehicleEngineStatus] = false;
			format(str, sizeof(str), "%s turned vehicle ID %i's engine off.", ReturnName(playerid), vehicleid);
		}
		
		SendAdminMessage(3, str); 
	}
	else if(!strcmp(a_str, "lights"))
	{
		if(VehicleInfo[vehicleid][eVehicleLights] == false)
			ToggleVehicleLights(vehicleid, true);
			
		else ToggleVehicleLights(vehicleid, false);
		
		format(str, sizeof(str), "%s turned vehicle ID %i's lights %s.", ReturnName(playerid), vehicleid, (VehicleInfo[vehicleid][eVehicleLights] != true) ? ("off") : ("on"));
		SendAdminMessage(3, str);
	}
	else if(!strcmp(a_str, "lock"))
	{
		new engine, lights, alarm, doors, bonnet, boot, objective; 
	
		GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
			
		if(VehicleInfo[vehicleid][eVehicleLocked])
		{
			SetVehicleParamsEx(vehicleid, engine, lights, alarm, false, bonnet, boot, objective);
			VehicleInfo[vehicleid][eVehicleLocked] = false;
		}
		else 
		{
			SetVehicleParamsEx(vehicleid, engine, lights, alarm, true, bonnet, boot, objective);
			VehicleInfo[vehicleid][eVehicleLocked] = true;
		}
		
		format(str, sizeof(str), "%s %s vehicle ID %i.", ReturnName(playerid), (VehicleInfo[vehicleid][eVehicleLocked] != false) ? ("locked") : ("unlocked")); 
		SendAdminMessage(3, str);
	}
	else if(!strcmp(a_str, "health"))
	{
		new Float:health;
		
		if(sscanf(b_str, "f", health))
			return SendUsageMessage(playerid, "/setcar vehicleid health [value]");
			
		SetVehicleHealth(vehicleid, health); 
		
		format(str, sizeof(str), "%s set vehicle ID %i's health to %.2f.", ReturnName(playerid), vehicleid, health);
		SendAdminMessage(3, str);
	}

	return 1;
}

//Level 4 Admin commands:
CMD:makefaction(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 4)
		return 0;
		
	new varAbbrev[30], varName[90]; 
	
	if(sscanf(params, "s[30]s[90]", varAbbrev, varName))
	{
		SendUsageMessage(playerid, "/makefaction [faction abbreviation] [faction name]");
		SendClientMessage(playerid, COLOR_RED, "[ ! ]{FFFFFF} Do not use spaces for the abbreviation.");
		return 1; 
	}
	
	if(strlen(varName) > 90)
		return SendErrorMessage(playerid, "Your factions name needs to be shorter."); 
		
	new idx = 0;
	
	for (new i = 1; i < MAX_FACTIONS; i ++)
	{
		if(!FactionInfo[i][eFactionDBID])
		{
			idx = i; 
			break;
		}
	}
	if(idx == 0)
	{
		return SendServerMessage(playerid, "The server has met the maximum amount of factions."); 
	}

	SendServerMessage(playerid, "Creating the faction..."); 	
	
	new thread[128]; 
	
	mysql_format(this, thread, sizeof(thread), "INSERT INTO factions (`FactionName`, `FactionAbbrev`) VALUES('%e', '%e')", varName, varAbbrev);
	mysql_tquery(this, thread, "Query_InsertFaction", "issi", playerid, varAbbrev, varName, idx);
	
	return 1;
}

CMD:editfaction(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 4)
		return 0;
		
	//This is a lead admin version for faction configuration;
	new factionid, oneString[60], secString[90]; 
		
	if (sscanf(params, "ds[60]S()[90]", factionid, oneString, secString))
	{
		SendUsageMessage(playerid, "/editfaction [faction id] [configuration]");
		SendServerMessage(playerid, "type, alterrank, joinrank, chatrank, towrank, chatcolor, spawn"); 
		return 1;
	}
	
	if(!FactionInfo[factionid][eFactionDBID])
		return SendErrorMessage(playerid, "The faction you specified doesn't exist.");
	
	if(!strcmp(oneString, "type"))
	{
		new type;
		
		if(sscanf(secString, "d", type))
		{
			SendUsageMessage(playerid, "/editfaction factionid type [type id]");
			SendServerMessage(playerid, "1. Illegal, 2. Police, 3. Medical, 4. DOC"); 
			return 1;
		}
		
		if(type > 4 || type < 1)
			return SendErrorMessage(playerid, "You specified an invalid faction type."); 
			
		FactionInfo[factionid][eFactionType] = type; 
		
		new 
			typeName[32];
		
		if(type == 1) typeName = "Illegal";
		if(type == 2) typeName = "Police";
		if(type == 3) typeName = "Medical";
		if(type == 4) typeName = "DOC"; 
		
		SendServerMessage(playerid, "You set faction %d's type to %s.", factionid, typeName);
		SaveFaction(factionid);
	}
	else if(!strcmp(oneString, "alterrank"))
	{
		new rankid;
		
		if(sscanf(secString, "d", rankid))
		{
			SendUsageMessage(playerid, "/editfaction factionid alterrank [rank]");
			SendServerMessage(playerid, "This is the rank that may edit the factions name and other permissions."); 
			return 1;
		}
		
		if(rankid < 1 || rankid > 20)
			return SendErrorMessage(playerid, "Faction ranks are between 1-20.");  
			
		FactionInfo[factionid][eFactionAlterRank] = rankid;
		SendServerMessage(playerid, "You set faction %d's alter rank to %d.", factionid, rankid);
		
		SaveFaction(factionid);
	}
	else if(!strcmp(oneString, "joinrank"))
	{
		new rankid;
		
		if(sscanf(secString, "d", rankid))
		{
			SendUsageMessage(playerid, "/editfaction factionid joinrank [rank]");
			SendServerMessage(playerid, "This is the rank a player receives when they join this faction."); 
			return 1;
		}
		
		if(rankid < 1 || rankid > 20)
			return SendErrorMessage(playerid, "Faction ranks are between 1-20.");  
			
		FactionInfo[factionid][eFactionJoinRank] = rankid;
		SendServerMessage(playerid, "You set faction %d's join rank to %d.", factionid, rankid);
		
		SaveFaction(factionid);
	}
	else if(!strcmp(oneString, "chatrank"))
	{
		new rankid;
		
		if(sscanf(secString, "d", rankid))
		{
			SendUsageMessage(playerid, "/editfaction factionid chatrank [rank]");
			SendServerMessage(playerid, "This is the rank a player needs to access faction chat.");
			return 1;
		}
		
		if(rankid < 1 || rankid > 20)
			return SendErrorMessage(playerid, "Faction ranks are between 1-20.");  
			
		FactionInfo[factionid][eFactionChatRank] = rankid;
		SendServerMessage(playerid, "You set faction %d's chat rank to %d.", factionid, rankid);
		
		SaveFaction(factionid);
	}
	else if(!strcmp(oneString, "towrank"))
	{
		new rankid;
		
		if(sscanf(secString, "d", rankid))
		{
			SendUsageMessage(playerid, "/editfaction factionid towrank [rank]");
			SendServerMessage(playerid, "This is the rank a player needs to tow faction vehicles.");
			return 1;
		}
		
		if(rankid < 1 || rankid > 20)
			return SendErrorMessage(playerid, "Faction ranks are between 1-20.");  
			
		FactionInfo[factionid][eFactionTowRank] = rankid;
		SendServerMessage(playerid, "You set faction %d's tow rank to %d.", factionid, rankid); 
		
		SaveFaction(factionid);
	}
	else if(!strcmp(oneString, "chatcolor"))
	{
		new hexcolor; 
		
		if(sscanf(secString, "x", hexcolor))
		{
			SendUsageMessage(playerid, "/editfaction factionid chatcolor [hexcode]");
			SendServerMessage(playerid, "This is the color faction chat is shown in. Example: 0x8D8DFFFF"); 
			return 1;
		}
		
		FactionInfo[factionid][eFactionChatColor] = hexcolor;
		SendServerMessage(playerid, "You set faction %d's chat color to \"%x\". ", factionid, hexcolor);
		
		SaveFaction(factionid);
	}
	else if(!strcmp(oneString, "spawn"))
	{
		GetPlayerPos(playerid, FactionInfo[factionid][eFactionSpawn][0], FactionInfo[factionid][eFactionSpawn][1], FactionInfo[factionid][eFactionSpawn][2]);
		
		FactionInfo[factionid][eFactionSpawnInt] = GetPlayerInterior(playerid);
		
		if(GetPlayerInterior(playerid) != 0)
			FactionInfo[factionid][eFactionSpawnWorld] = random(50000)+playerid+5; 
		
		else FactionInfo[factionid][eFactionSpawnWorld] = GetPlayerVirtualWorld(playerid);
		
		SendServerMessage(playerid, "You changed faction %d's spawn point."); 
	}
	else return SendErrorMessage(playerid, "Invalid Parameter.");
	return 1;
}

CMD:setpfaction(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 4)
		return SendUnauthMessage(playerid);
		
	new playerb, factionid, str[128];
	
	if(sscanf(params, "ud", playerb, factionid))
		return SendUsageMessage(playerid, "/setpfaction [playerid OR name] [faction id]");
		
	if(!IsPlayerConnected(playerb))
		return SendErrorMessage(playerid, "The player you specified isn't connected.");
		
	if(e_pAccountData[playerid][mLoggedin] == false)
		return SendErrorMessage(playerid, "The player you specified isn't logged in."); 
		
	if(!FactionInfo[factionid][eFactionDBID]) return SendErrorMessage(playerid, "The faction you specified doesn't exist.");
	
	if(PlayerInfo[playerb][pFaction] != 0)
	{
		new detailStr[128];
		
		format(detailStr, sizeof(detailStr), "{FFFFFF}%s is already in a faction. Would you like to continue?", ReturnName(playerb));
		ConfirmDialog(playerid, "Confirmation", detailStr, "OnSetFaction", playerb, factionid);
		return 1;
	}
	
	PlayerInfo[playerb][pFaction] = factionid;
	PlayerInfo[playerb][pFactionRank] = FactionInfo[factionid][eFactionJoinRank]; 
	
	SaveCharacter(playerb);
		
	format(str, sizeof(str), "%s set %s's faction to %d.", ReturnName(playerid), ReturnName(playerb), factionid);
	SendAdminMessage(4, str);
	
	SendServerMessage(playerb, "You were set to faction %d by Admin %s.", factionid, ReturnName(playerid));
	
	return 1;
}

CMD:bizint(playerid, params[])
{
	new type;

    if (PlayerInfo[playerid][pAdmin] < 3)
	{
		return SendErrorMessage(playerid, "You don't have permission to use this command.");
	}
	else if (sscanf(params, "i", type))
	{
	    return SendUsageMessage(playerid, "/bizint (interior 1-%i)", sizeof(g_BusinessInteriors) - 1);
	}
	else if (type < 1 || type > sizeof(g_BusinessInteriors) - 1)
	{
	    return SendErrorMessage(playerid, "You must input a type between 1 and %i.", sizeof(g_BusinessInteriors) - 1);
	}
	else
	{
	    SetPlayerPos(playerid, g_BusinessInteriors[type][e_InteriorX], g_BusinessInteriors[type][e_InteriorY], g_BusinessInteriors[type][e_InteriorZ]);
        SetPlayerInterior(playerid, g_BusinessInteriors[type][e_Interior]);
		sendMessage(playerid, -1, "You are now viewing business interior: %i.", type);
	}
	return 1;
}

CMD:makeproperty(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 4)
		return 0;
		
	new 
		vartype, 
		query[128]
	; 
	
	if(sscanf(params, "i", vartype))
	{
		SendUsageMessage(playerid, "/makeproperty [type]");
		SendClientMessage(playerid, COLOR_WHITE, "Types: 1. House, 2. Apartment Complex, 3. Apartment Room.");
		return 1;
	}
	
	if(vartype > 3 || vartype < 1) 
		return SendErrorMessage(playerid, "You specified an invalid type.");
		
	mysql_format(this, query, sizeof(query), "INSERT INTO properties (`PropertyType`) VALUES(%i)", vartype);
	mysql_tquery(this, query, "OnPropertyCreate", "ii", playerid, vartype);
	return 1;
}

CMD:editproperty(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 4)
		return 0;
		
	new id, indx[60], specifier[60];
	
	if(sscanf(params, "is[60]S()[60]", id, indx, specifier))
	{
		SendUsageMessage(playerid, "/editproperty [property id] [params]");
		SendClientMessage(playerid, COLOR_WHITE, "Params: 1. Entrance, 2. Interior, 3. Faction,");
		SendClientMessage(playerid, COLOR_WHITE, "Params: 4. Type, 5. MarketPrice, 6. Level.");
		return 1; 
	}
	
	if(!PropertyInfo[id][ePropertyDBID] || id > MAX_PROPERTY)
		return SendErrorMessage(playerid, "That Property doesn't exist.");
	
	if(!strcmp(indx, "entrance"))
	{
		ConfirmDialog(playerid, "Confirmation", "Are you sure you want to set this properties entrance?", "OnEntranceChange", id); 
	}
	else if(!strcmp(indx, "interior"))
	{
		ConfirmDialog(playerid, "Confirmation", "Are you sure you want to set this properties interior?", "OnInteriorChange", id); 
	}
	else if(!strcmp(indx, "faction"))
	{		
		new factionid;
		
		if(sscanf(specifier, "i", factionid))
			return SendUsageMessage(playerid, "/editproperty %i Faction [faction ID]", id);
			
		if(!FactionInfo[factionid][eFactionDBID] || factionid > MAX_FACTIONS)
			return SendErrorMessage(playerid, "You specifier an invalid faction ID.");
			
		PropertyInfo[id][ePropertyFaction] = factionid;
		SaveProperty(factionid);
		
		SendServerMessage(playerid, "You set Property %i's faction to %i.", id, factionid);
	}
	else if(!strcmp(indx, "type"))
	{
		new vartype, typeName[30];
		
		if(sscanf(specifier, "i", vartype))
		{
			SendUsageMessage(playerid, "/editproperty %i Type [type id]", id);
			SendClientMessage(playerid, COLOR_WHITE, "Types: 1. House, 2. Apartment Complex, 3. Apartment Room.");
			return 1;
		}
		
		if(vartype > 3 || vartype < 1) 
			return SendErrorMessage(playerid, "You specified an invalid type.");
			
		if(vartype == PROPERTY_TYPE_HOUSE) typeName = "House";
		if(vartype == PROPERTY_TYPE_APTCOMPLEX) typeName = "Apartment Complex";
		if(vartype == PROPERTY_TYPE_APTROOM) typeName = "Apartment Room";
		
		PropertyInfo[id][ePropertyType] = vartype;
		SaveProperty(id);
		
		SendServerMessage(playerid, "You set Property %i's type to %s.", id, typeName);	
	}
	else if(!strcmp(indx, "marketprice"))
	{
		new price;
		
		if(sscanf(specifier, "i", price))
			return SendUsageMessage(playerid, "/editproperty %i MarketPrice [price]", id);
			
		if(price < 1)
			return SendErrorMessage(playerid, "The price has to be greater than or equal to 1."); 
			 
		PropertyInfo[id][ePropertyMarketPrice] = price;
		SaveProperty(id);
		
		SendServerMessage(playerid, "You set Property %i's market price to %i.", id, price);
	}
	else if(!strcmp(indx, "level"))
	{
		new level;
		
		if(sscanf(specifier, "i", level))
			return SendUsageMessage(playerid, "/editproperty %i Level [level]", id);
			
		if(level < 1)
			return SendErrorMessage(playerid, "The level can't be less than 1.");
			
		PropertyInfo[id][ePropertyLevel] = level;
		SaveProperty(id);
		
		SendServerMessage(playerid, "You set Property %i's level to %i.", id, level);
	}
	else return SendServerMessage(playerid, "Invalid Paramater.");	
	return 1;
}

CMD:makexmrcat(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 4)
		return 0;
		
	if(isnull(params))
	{
		SendUsageMessage(playerid, "/makexmrcat [Category name] (e.g: Rap)"); 
		SendServerMessage(playerid, "These are the station categories listed in the station list."); 
		return 1;
	}
	
	if(strlen(params) > 90 || strlen(params) < 3)
		return SendErrorMessage(playerid, "Your categories either too long or too short.");
		
	new
		idx,
		insertQuery[128]
	; 
		
	for(new i = 1; i < MAX_XMR_CATEGORY; i++)
	{
		if(!XMRCategoryInfo[i][eXMRID])
		{
			idx = i;
			break;
		}
	}
	
	if(idx == 0)
		return SendErrorMessage(playerid, "The server has met its XMR category capacity."); 
		
	mysql_format(this, insertQuery, sizeof(insertQuery), "INSERT INTO xmr_categories (XMRCategoryName) VALUES ('%e')", params);
	mysql_tquery(this, insertQuery, "OnXMRCategory", "iis", playerid, idx, params);

	return 1;
}

CMD:makexmrstation(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 4)
		return 0;
		
	new 
		category,
		staURL[128],
		staName[90],
		idx,
		insertQuery[256]
	;
	
	if(sscanf(params, "is[128]s[90]", category, staURL, staName))
	{
		SendUsageMessage(playerid, "/makexmrstation [Category] [Audio URL] [Station Name]"); 
		SendClientMessage(playerid, -1, "Example: /makexmrstation 1 http://powerhitz.com Powerhitz"); 
		return 1;
	}
	
	if(!XMRCategoryInfo[category][eXMRID] || category > MAX_XMR_CATEGORY)
		return SendErrorMessage(playerid, "The category you specified doesn't exist."); 
	
	for(new i = 1; i < MAX_XMR_CATEGORY_STATIONS; i++)
	{
		if(!XMRStationInfo[i][eXMRStationID])
		{
			idx = i; 
			break;
		}
	}
	
	if(idx == 0)
		return SendErrorMessage(playerid, "The server has met its XMR stations capacity."); 
	
	mysql_format(this, insertQuery, sizeof(insertQuery), "INSERT INTO xmr_stations (XMRCategory, XMRStationName, XMRStationURL) VALUES(%i, '%e', '%e')", category, staName, staURL);
	mysql_tquery(this, insertQuery, "OnXMRStation", "iiiss", playerid, category, idx, staURL, staName);
	
	return 1;
}

CMD:makebusiness(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 4)
		return 0;		

	new 
		type_id,
		idx,
		query[128]
	; 
	
	if(sscanf(params, "i", type_id))
	{
		SendUsageMessage(playerid, "/makebusiness [business type]"); 
		SendClientMessage(playerid, COLOR_WHITE, "Types: 1. Restaurant, 2. Ammunation, 3. Club,");
		SendClientMessage(playerid, COLOR_WHITE, "Types: 4. Bank, 5. General, 6. Dealership, 7. DMV."); 
		return 1;
	}
	
	if(type_id > 7 || type_id < 1)
		return SendErrorMessage(playerid, "You specified an invalid type.");
	
	for(new i = 1; i < MAX_BUSINESS; i++)
	{
		if(!BusinessInfo[i][eBusinessDBID])
		{
			idx = i;
			break;
		}
	}
	
	if(idx == 0)
		return SendErrorMessage(playerid, "You can't make anymore businesses."); 
		
	mysql_format(this, query, sizeof(query), "INSERT INTO businesses (BusinessType, BusinessName) VALUES(%i, '%s')", type_id, ReturnBusinessName(type_id));
	mysql_tquery(this, query, "Query_InsertBusiness", "iii", playerid, idx, type_id, ReturnBusinessName(type_id));
	return 1;
}

CMD:editbusiness(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 4)
		return 0;

	new 
		id,
		astr[90],
		bstr[90]
	;
		
	if(sscanf(params, "is[90]S()[90]", id, astr, bstr))
	{
		SendUsageMessage(playerid, "/editbusiness [business ID] [configuration]");
		SendServerMessage(playerid, "interior, entrance, type, level, product");
		SendServerMessage(playerid, "entrancefee, name, bankpickup, marketprice"); 
		return 1;
	}
	
	if(!BusinessInfo[id][eBusinessDBID] || id > MAX_BUSINESS)
		return SendErrorMessage(playerid, "You specified an invalid business ID.");
		
	if(!strcmp(astr, "interior"))
	{
		ConfirmDialog(playerid, "Confirmation", "Are you sure you want to change this businesses interior?", "OnBusinessInteriorChange", id); 
	}
	else if(!strcmp(astr, "entrance"))
	{
		ConfirmDialog(playerid, "Confirmation", "Are you sure you want to change this businesses entrance?", "OnBusinessEntranceChange", id); 
	}
	else if(!strcmp(astr, "type"))
	{
		new type;
		
		if(sscanf(bstr, "i", type))
		{
			SendUsageMessage(playerid, "/editbusiness %i type [type id]", id); 
			SendClientMessage(playerid, COLOR_WHITE, "Types: 1. Restaurant, 2. Ammunation, 3. Club,");
			SendClientMessage(playerid, COLOR_WHITE, "Types: 4. Bank, 5. General, 6. Dealership, 7. DMV."); 
			return 1;
		}

		if(type > 7 || type < 1)
			return SendErrorMessage(playerid, "You specified an invalid type.");
			
		if(type == BusinessInfo[id][eBusinessType])
			return SendErrorMessage(playerid, "You can't set the businesses type to what it already is."); 
			
		DestroyDynamicPickup(BusinessInfo[id][eBusinessPickup]);
			
		if(type == BUSINESS_TYPE_RESTAURANT)
		{
			if(!BusinessInfo[id][eBusinessOwnerDBID])
				BusinessInfo[id][eBusinessPickup] = CreateDynamicPickup(1272, 14, BusinessInfo[id][eBusinessEntrance][0], BusinessInfo[id][eBusinessEntrance][1], BusinessInfo[id][eBusinessEntrance][2], 0);
				
			else BusinessInfo[id][eBusinessPickup] = CreateDynamicPickup(1239, 14, BusinessInfo[id][eBusinessEntrance][0], BusinessInfo[id][eBusinessEntrance][1], BusinessInfo[id][eBusinessEntrance][2], 0);
		}
		else BusinessInfo[id][eBusinessPickup] = CreateDynamicPickup(1239, 14, BusinessInfo[id][eBusinessEntrance][0], BusinessInfo[id][eBusinessEntrance][1], BusinessInfo[id][eBusinessEntrance][2], 0);
		
		if(BusinessInfo[id][eBusinessType] == BUSINESS_TYPE_BANK)
		{
			DestroyDynamicPickup(BusinessInfo[id][eBusinessBankPickup]);
			
			for(new i = 0; i < 3; i++) {
				BusinessInfo[id][eBusinessBankPickupLoc][i] = 0.0; 
			}
			
			SendServerMessage(playerid, "This business is no longer a bank and the pickup was destroyed."); 
		}
		
		SendServerMessage(playerid, "You changed business %i's type to %i.", id, type);
		SaveBusiness(id);	
	}
	else if(!strcmp(astr, "level"))
	{
		new level;
		
		if(sscanf(bstr, "i", level))
			return SendUsageMessage(playerid, "/editbusiness %i level [level]", id);
			
		if(level < 1)
			return SendErrorMessage(playerid, "You can't make the level below 1."); 
			
		BusinessInfo[id][eBusinessLevel] = level;
		
		SendServerMessage(playerid, "You set business %i's level to %i.", id, level);
		SaveBusiness(id);
	}
	else if(!strcmp(astr, "product"))
	{
		new product;

		if(sscanf(bstr, "i", product))
			return SendUsageMessage(playerid, "/editbusiness %i product [level]", id);

		if(product < 1 || product > 500)
			return SendErrorMessage(playerid, "product can only be 1 - 500");

		BusinessInfo[id][eBusinessProducts] = product;

		SendServerMessage(playerid, "You set business %i's product to %i.", id, product);
		SaveBusiness(id);
	}
	else if(!strcmp(astr, "entrancefee"))
	{
		new fee;
		
		if(sscanf(bstr, "i", fee))
			return SendUsageMessage(playerid, "/editbusiness %i entrancefee [amount]", id);
			
		if(fee > 1500)
			return SendErrorMessage(playerid, "The entrance fee can't be above 1500.");
			
		BusinessInfo[id][eBusinessEntranceFee] = fee;
		
		SendServerMessage(playerid, "You set business %i's entrance fee to %i.", id, fee);
		SaveBusiness(id);
	}
	else if(!strcmp(astr, "name"))
	{
		new bizname[90]; 
		
		if(sscanf(bstr, "s[90]", bizname))
		{
			SendUsageMessage(playerid, "/editbusiness %i name [business name]", id);
			SendServerMessage(playerid, "You can use text colors (i.e ~r~Red ~b~Blue) in the name."); 
			return 1;
		}
		
		if(strlen(bizname) > 90)
			return SendErrorMessage(playerid, "Stay below 90 characters.");
			
		SendServerMessage(playerid, "You set business %i's name from \"%s\" to \"%s\". ", id, BusinessInfo[id][eBusinessName], bizname); 
		
		format(BusinessInfo[id][eBusinessName], 90, "%s", bizname);
		SaveBusiness(id); 
	}
	else if(!strcmp(astr, "bankpickup"))
	{
		if(BusinessInfo[id][eBusinessType] != BUSINESS_TYPE_BANK)
			return SendErrorMessage(playerid, "This business isn't a bank."); 
			
		ConfirmDialog(playerid, "Confirmation", "Are you sure you want to set / change this banks pickup?", "OnBusinessBankpickupChange", id);
	}
	else if(!strcmp(astr, "marketprice"))
	{
		new price;
		
		if(sscanf(bstr, "i", price))
			return SendUsageMessage(playerid, "/editbusiness %i marketprice [amount]", id);
			
		BusinessInfo[id][eBusinessMarketPrice] = price;
		
		SendServerMessage(playerid, "You set business %i's market price to $%s.", id, MoneyFormat(price));
		SaveBusiness(id);
	}
	else return SendErrorMessage(playerid, "Invalid Parameter.");
	return 1;
}

CMD:callpaycheck(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 4)
		return 0;
		
	ConfirmDialog(playerid, "Confirmation", "Are you sure you want to call a paycheck?\n\nThis action cannot be undone.", "OnCallPaycheck"); 
	return 1;
}


CMD:streetname(playerid, params[])
{
	sendMessage(playerid, COLOR_DARKGREEN, "%s, San Andreas", ReturnLocationEx(playerid));
	return 1;
}

CMD:makestreet(playerid, params[])
{
	new Float: temp_pos[3], insert[129], Float: size;
    if(sscanf(params,"s[32]f", params[0], size))
	{
		return SendClientMessage(playerid, COLOR_LIGHTRED, "USAGE: /makestreet [input] [size]");
	}
	GetPlayerPos(playerid, temp_pos[0], temp_pos[1], temp_pos[2]);
	if(size < 25.0 || size > 100.0) return SendErrorMessage(playerid, "Size can not be less than 25 or more than 100");
	
	mysql_format(this, insert, sizeof(insert), "INSERT INTO street_data (name, circleX, circleY, size) VALUES('%s', %f, %f, %f)",
		params[0], temp_pos[0], temp_pos[1]);
	mysql_tquery(this, insert, "OnPlayerInsertStreet", "isfff", playerid, params[0], temp_pos[0], temp_pos[1], size);
	return 1;
}

//Local functions:
this::LocalChat(playerid, Float:radi, string[], color1, color2, color3, color4)
{
	if (e_pAccountData[playerid][mLoggedin] == false)
		return 0;
		
	new
		Float:currentPos[3], 
		Float:oldPos[3],
		Float:checkPos[3]
	;
		
	GetPlayerPos(playerid, oldPos[0], oldPos[1], oldPos[2]); 
	foreach (new i : Player)
	{
		if (PlayerInfo[playerid][pLoggedin] == false) continue; 
		
		GetPlayerPos(i, currentPos[0], currentPos[1], currentPos[2]); 
		for (new p = 0; p < 3; p++)
		{
			checkPos[p] = (oldPos[p] - currentPos[p]);  
		}
		
		if (GetPlayerVirtualWorld(i) != GetPlayerVirtualWorld(playerid))
			continue;
			
		if (((checkPos[0] < radi/16) && (checkPos[0] > -radi/16)) && ((checkPos[1] < radi/16) && (checkPos[1] > -radi/16)) && ((checkPos[2] < radi/16) && (checkPos[2] > -radi/16)))
		{
			SendClientMessage(i, color1, string);
		}
		else if (((checkPos[0] < radi/8) && (checkPos[0] > -radi/8)) && ((checkPos[1] < radi/8) && (checkPos[1] > -radi/8)) && ((checkPos[2] < radi/8) && (checkPos[2] > -radi/8)))
		{
			SendClientMessage(i, color2, string);
		}
		else if (((checkPos[0] < radi/4) && (checkPos[0] > -radi/4)) && ((checkPos[1] < radi/4) && (checkPos[1] > -radi/4)) && ((checkPos[2] < radi/4) && (checkPos[2] > -radi/4)))
		{
			SendClientMessage(i, color3, string);
		}
		else if (((checkPos[0] < radi/2) && (checkPos[0] > -radi/2)) && ((checkPos[1] < radi/2) && (checkPos[1] > -radi/2)) && ((checkPos[2] < radi/2) && (checkPos[2] > -radi/2)))
		{
			SendClientMessage(i, color4, string);
		}	
	}
	return 1;
}

this::OnPlayerReport(playerid, reportid, const text[])
{
	if(ReportInfo[reportid][rReportExists] == true)
	{
		for (new i = 1; i < sizeof(ReportInfo); i ++)
		{
			if(ReportInfo[i][rReportExists] == false)
			{
				reportid = i;
				break;
			}
		}
	}
		
	ReportInfo[reportid][rReportExists] = true;
	ReportInfo[reportid][rReportTime] = gettime();
		
	format(ReportInfo[reportid][rReportDetails], 90, "%s", text);
	ReportInfo[reportid][rReportBy] = playerid;
		
	SendServerMessage(playerid, "Your report was sent to all online admins.");
		
	if(strlen(text) > 67)
	{
		SendAdminMessageEx(COLOR_REPORT, 1, "[Report: %d] %s (%d): %.75s", reportid, ReturnName(playerid), playerid, text);
		SendAdminMessageEx(COLOR_REPORT, 1, "[Report: %d] ...%s", reportid, text[75]);
	}
	else SendAdminMessageEx(COLOR_REPORT, 1, "[Report: %d] %s (%d): %s", reportid, ReturnName(playerid), playerid, text);
		
	if(strfind(text, "hack", true) != -1 || strfind(text, "cheat", true) != -1)
	{
		foreach(new i : Player)
		{
			if(PlayerInfo[i][pAdmin]) GameTextForPlayer(i, "~y~~h~Priority Report", 4000, 1);
		}
	}
	return 1;
}

this::ClearReports(playerid, response, reports)
{
	if(response)
	{
		for (new i = 0; i < sizeof(ReportInfo); i ++)
		{
			ReportInfo[i][rReportExists] = false;
			ReportInfo[i][rReportDetails] = ' '; 
			ReportInfo[i][rReportBy] = INVALID_PLAYER_ID;
			ReportInfo[i][rReportTime] = 0; 
		}
		
		new str[128];
		
		format(str, sizeof(str), "%s cleared %d active reports.", ReturnName(playerid), reports);
		SendAdminMessage(1, str); 
	}
	else return SendServerMessage(playerid, "You cancelled the confirmation.");
	return 1;
}

this::OnSetFaction(playerid, response, playerb, factionid)
{
	if(response)
	{
		PlayerInfo[playerb][pFaction] = factionid;
		PlayerInfo[playerb][pFactionRank] = FactionInfo[factionid][eFactionJoinRank]; 
		
		new str[128];
		
		format(str, sizeof(str), "%s set %s's faction to %d.", ReturnName(playerid), ReturnName(playerb), factionid);
		SendAdminMessage(4, str);
		
		SendServerMessage(playerb, "You were set to faction %d by Admin %s.", factionid, ReturnName(playerid));
		
		SaveCharacter(playerb);
	}
	else return SendServerMessage(playerid, "You disregarded the faction set.");
	return 1;
}

this::OnVehicleScrap(playerid, response, dbid, cash_back)
{
	if(response)
	{
		if(!IsPlayerInAnyVehicle(playerid))
			return SendErrorMessage(playerid, "You're no longer in a vehicle. This was aborted.");
			
		new delQuery[128];
		
		mysql_format(this, delQuery, sizeof(delQuery), "DELETE FROM vehicles WHERE VehicleDBID = %i", dbid);
		mysql_tquery(this, delQuery);
		
		SendServerMessage(playerid, "Your %s has been permanently deleted.", ReturnVehicleName(GetPlayerVehicleID(playerid))); 
		SendServerMessage(playerid, "You earned $%s from scrapping it.", MoneyFormat(cash_back));
		
		GiveMoney(playerid, cash_back); 
		
		ResetVehicleVars(GetPlayerVehicleID(playerid)); 
		DestroyVehicle(GetPlayerVehicleID(playerid)); 
		
		PlayerInfo[playerid][pVehicleSpawned] = false;
		PlayerInfo[playerid][pVehicleSpawnedID] = 0;
		
		for(new i = 1; i < MAX_PLAYER_VEHICLES; i++)
		{
			if(PlayerInfo[playerid][pOwnedVehicles][i] == dbid)
			{
				PlayerInfo[playerid][pOwnedVehicles][i] = 0;
			}
		}
	}
	else return SendServerMessage(playerid, "This action was aborted.");
	return 1;
}

this::OnVehicleTow(playerid)
{
	new vehicleid = PlayerInfo[playerid][pVehicleSpawnedID], newDisplay[128]; 
	
	if(IsVehicleOccupied(vehicleid))
	{
		KillTimer(playerTowTimer[playerid]);
		SendServerMessage(playerid, "Your vehicle tow was interrupted."); 
		
		playerTowingVehicle[playerid] = false;	
		Delete3DTextLabel(VehicleInfo[vehicleid][eVehicleTowDisplay]);
		
		VehicleInfo[vehicleid][eVehicleTowCount] = 0;
		return 1;
	}
	
	VehicleInfo[vehicleid][eVehicleTowCount]++;
	
	if(VehicleInfo[vehicleid][eVehicleTowCount] == 1) newDisplay = "(( || ))\nTOWING VEHICLE"; 
	if(VehicleInfo[vehicleid][eVehicleTowCount] == 2) newDisplay = "(( ||| ))\nTOWING VEHICLE"; 
	if(VehicleInfo[vehicleid][eVehicleTowCount] == 3) newDisplay = "(( |||| ))\nTOWING VEHICLE"; 
	if(VehicleInfo[vehicleid][eVehicleTowCount] == 4) newDisplay = "(( ||||| ))\nTOWING VEHICLE"; 
	if(VehicleInfo[vehicleid][eVehicleTowCount] == 5) newDisplay = "(( |||||| ))\nTOWING VEHICLE"; 
	if(VehicleInfo[vehicleid][eVehicleTowCount] == 6) newDisplay = "(( ||||||| ))\nTOWING VEHICLE"; 
	if(VehicleInfo[vehicleid][eVehicleTowCount] == 7) newDisplay = "(( |||||||| ))\nTOWING VEHICLE"; 
	if(VehicleInfo[vehicleid][eVehicleTowCount] == 8) newDisplay = "(( |||||||| ))\nTOWING VEHICLE"; 
	
	Update3DTextLabelText(VehicleInfo[vehicleid][eVehicleTowDisplay], COLOR_DARKGREEN, newDisplay);
	
	if(VehicleInfo[vehicleid][eVehicleTowCount] == 9)
	{
		SendServerMessage(playerid, "Your vehicle has been towed.");
		GiveMoney(playerid, -2000);
		
		playerTowingVehicle[playerid] = false;	
		SetVehicleToRespawn(vehicleid); 
		
		Delete3DTextLabel(VehicleInfo[vehicleid][eVehicleTowDisplay]);
		KillTimer(playerTowTimer[playerid]);
		
		VehicleInfo[vehicleid][eVehicleTowCount] = 0; 
		return 1;
	}
	
	return 1;
}

this::OnGascanRefill(playerid, vehicleid, x, y, z)
{
	new 
		text[128]
	; 
	if(GetVehicleDistanceFromPoint(vehicleid, x, y, z) > 3)
	{
		SendClientMessage(playerid, COLOR_ACTION, "The vehicle you were refilling moved and canceled."); 
		
		KillTimer(playerRefillTimer[playerid]);
		playerRefillingVehicle[playerid] = false; 
		
		Delete3DTextLabel(VehicleInfo[vehicleid][eVehicleRefillDisplay]); 
		VehicleInfo[vehicleid][eVehicleRefillCount] = 0; 
		return 1;
	}
	
	if(!IsPlayerInRangeOfPoint(playerid, 1.0, PlayerInfo[playerid][pLastPos][0], PlayerInfo[playerid][pLastPos][1], PlayerInfo[playerid][pLastPos][2]))
	{
		SendClientMessage(playerid, COLOR_ACTION, "You moved and stopped refilling the vehicle."); 
		
		KillTimer(playerRefillTimer[playerid]);
		playerRefillingVehicle[playerid] = false; 
		
		Delete3DTextLabel(VehicleInfo[vehicleid][eVehicleRefillDisplay]); 
		VehicleInfo[vehicleid][eVehicleRefillCount] = 0; 
		return 1;
	}
	
	VehicleInfo[vehicleid][eVehicleRefillCount] ++;
	
	switch(VehicleInfo[vehicleid][eVehicleRefillCount])
	{
		case 2: text = "(( ||----- ))\nREFILLING VEHICLE";
		case 3: text = "(( |||---- ))\nREFILLING VEHICLE";
		case 4: text = "(( ||||--- ))\nREFILLING VEHICLE";
		case 5: text = "(( |||||-- ))\nREFILLING VEHICLE";
		case 6: text = "(( ||||||- ))\nREFILLING VEHICLE";
		case 7: text = "(( ||||||| ))\nREFILLING VEHICLE";
		case 8:
		{
			KillTimer(playerRefillTimer[playerid]);
			playerRefillingVehicle[playerid] = false; 
			
			Delete3DTextLabel(VehicleInfo[vehicleid][eVehicleRefillDisplay]); 
			VehicleInfo[vehicleid][eVehicleRefillCount] = 0; 
			
			VehicleInfo[vehicleid][eVehicleFuel] = 50.0;
			
			sendMessage(playerid, COLOR_ACTION, "You refilled the %s to 50 percent fuel.", ReturnVehicleName(vehicleid));
			SendNearbyMessage(playerid, 20.0, COLOR_EMOTE, "* %s refilled the %s with their gas can.", ReturnName(playerid, 0), ReturnVehicleName(vehicleid)); 
			return 1;
		}
	}
	
	Update3DTextLabelText(VehicleInfo[vehicleid][eVehicleRefillDisplay], COLOR_DARKGREEN, text); 
	return 1;
}

this::OnPlayerRelog(playerid)
{
	new 
		updateLabel[90],
		relogCheck[60]
	;
	
	PlayerInfo[playerid][pRelogCount] ++; 
	
	if(PlayerInfo[playerid][pRelogCount] == 2)
		updateLabel = "(( ||----- ))\nRELOGGING"; 
		
	if(PlayerInfo[playerid][pRelogCount] == 3)
		updateLabel = "(( |||---- ))\nRELOGGING"; 
		
	if(PlayerInfo[playerid][pRelogCount] == 4)
		updateLabel = "(( ||||--- ))\nRELOGGING"; 
		
	if(PlayerInfo[playerid][pRelogCount] == 5)
		updateLabel = "(( |||||-- ))\nRELOGGING"; 
		
	if(PlayerInfo[playerid][pRelogCount] == 6)
		updateLabel = "(( ||||||- ))\nRELOGGING"; 
		
	if(PlayerInfo[playerid][pRelogCount] == 7)
		updateLabel = "(( ||||||| ))\nRELOGGING";  
		
	Update3DTextLabelText(PlayerInfo[playerid][pRelogTD], COLOR_DARKGREEN, updateLabel);
	
	if(PlayerInfo[playerid][pRelogCount] == 8)
	{
		Delete3DTextLabel(PlayerInfo[playerid][pRelogTD]);
		KillTimer(PlayerInfo[playerid][pRelogTimer]); 
		
		PlayerInfo[playerid][pRelogging] = false;
		PlayerInfo[playerid][pRelogCount] = 0; 
		
		SaveCharacter(playerid);
		SaveCharacterPos(playerid);
		
		SetPlayerInterior(playerid, 0);
		SetPlayerVirtualWorld(playerid, 0); 
		
		PlayerInfo[playerid][pLoggedin] = false;
		e_pAccountData[playerid][mLoggedin] = false;
		
		SetPlayerName(playerid, e_pAccountData[playerid][mAccName]); 
		TogglePlayerSpectating(playerid, true); SetPlayerCamera(playerid);

		mysql_format(this, relogCheck, sizeof(relogCheck), "SELECT char_dbid FROM characters WHERE char_name = '%e'", ReturnName(playerid));
		mysql_tquery(this, relogCheck, "LogPlayerIn", "i", playerid);
		
		return 1;
	}
	return 1;
}

this::OnVehicleTextdraw(playerid)
{
	if(IsValidDynamic3DTextLabel(playerVehicleTextdraw[playerid]))
		DestroyDynamic3DTextLabel(playerVehicleTextdraw[playerid]);
		
	playerTextdraw[playerid] = false; 
	return 1;
}

this::OnBusinessInteriorChange(playerid, response, businessid)
{
	if(response)
	{
		GetPlayerPos(playerid, BusinessInfo[businessid][eBusinessInterior][0], BusinessInfo[businessid][eBusinessInterior][1], BusinessInfo[businessid][eBusinessInterior][2]);
		
		new 
			world = random(20000)+playerid+2; 
		
		BusinessInfo[businessid][eBusinessInteriorIntID] = GetPlayerInterior(playerid);
		BusinessInfo[businessid][eBusinessInteriorWorld] = world;
		
		SendServerMessage(playerid, "You changed Business %i's interior ID.", businessid);
		
		foreach(new i : Player) if(IsPlayerInBusiness(i) == businessid)
		{
			SetPlayerPos(i, BusinessInfo[businessid][eBusinessInterior][0], BusinessInfo[businessid][eBusinessInterior][1], BusinessInfo[businessid][eBusinessInterior][2]);
			SetPlayerInterior(i, GetPlayerInterior(playerid)); SetPlayerVirtualWorld(playerid, world); 
			
			SendServerMessage(i, "The business you were in was amended."); 
		}
		
		if(BusinessInfo[businessid][eBusinessType] == BUSINESS_TYPE_BANK)
		{
			if(IsValidDynamicPickup(BusinessInfo[businessid][eBusinessBankPickup]))
			{
				DestroyDynamicObject(BusinessInfo[businessid][eBusinessBankPickup]); 
				SendServerMessage(playerid, "This businesses' bank pickup was destroyed and needs to be remade."); 
			}
			
			for(new i = 0; i < 3; i++)
			{
				BusinessInfo[businessid][eBusinessBankPickupLoc][i] = 0.0; 
			}
		}
	
		SaveBusiness(businessid); 
	}
	else return SendServerMessage(playerid, "You cancelled."); 
	return 1; 
}

this::OnBusinessEntranceChange(playerid, response, businessid)
{
	if(response)
	{
		GetPlayerPos(playerid, BusinessInfo[businessid][eBusinessEntrance][0], BusinessInfo[businessid][eBusinessEntrance][1], BusinessInfo[businessid][eBusinessEntrance][2]); 
		
		if(IsValidDynamicObject(BusinessInfo[businessid][eBusinessPickup]))
			DestroyDynamicPickup(BusinessInfo[businessid][eBusinessPickup]); 
			
		if(BusinessInfo[businessid][eBusinessType] == BUSINESS_TYPE_RESTAURANT)
		{
			if(!BusinessInfo[businessid][eBusinessOwnerDBID])
				BusinessInfo[businessid][eBusinessPickup] = CreateDynamicPickup(1272, 14, BusinessInfo[businessid][eBusinessEntrance][0], BusinessInfo[businessid][eBusinessEntrance][1], BusinessInfo[businessid][eBusinessEntrance][2], 0);
				
			else BusinessInfo[businessid][eBusinessPickup] = CreateDynamicPickup(1239, 14, BusinessInfo[businessid][eBusinessEntrance][0], BusinessInfo[businessid][eBusinessEntrance][1], BusinessInfo[businessid][eBusinessEntrance][2], 0);
		}
		else BusinessInfo[businessid][eBusinessPickup] = CreateDynamicPickup(1239, 14, BusinessInfo[businessid][eBusinessEntrance][0], BusinessInfo[businessid][eBusinessEntrance][1], BusinessInfo[businessid][eBusinessEntrance][2], 0); 
		
		SendServerMessage(playerid, "You changed Business %i's entrance.", businessid);
		SaveBusiness(businessid); 
	}
	else return SendServerMessage(playerid, "You cancelled.");
	return 1;
}

this::OnBusinessBankpickupChange(playerid, response, businessid)
{
	if(response)
	{
		GetPlayerPos(playerid, BusinessInfo[businessid][eBusinessBankPickupLoc][0], BusinessInfo[businessid][eBusinessBankPickupLoc][1], BusinessInfo[businessid][eBusinessBankPickupLoc][2]);
		BusinessInfo[businessid][eBusinessBankPickupWorld] = GetPlayerVirtualWorld(playerid);
		
		if(IsValidDynamicPickup(BusinessInfo[businessid][eBusinessBankPickup]))
			DestroyDynamicPickup(BusinessInfo[businessid][eBusinessBankPickup]); 
			
		BusinessInfo[businessid][eBusinessBankPickup] = CreateDynamicPickup(1274, 2, BusinessInfo[businessid][eBusinessBankPickupLoc][0], BusinessInfo[businessid][eBusinessBankPickupLoc][1], BusinessInfo[businessid][eBusinessBankPickupLoc][2], BusinessInfo[businessid][eBusinessBankPickupWorld]);
		
		SendServerMessage(playerid, "You changed business %i's bank point.", businessid); 
		SaveBusiness(businessid);
	}
	else return SendServerMessage(playerid, "You cancelled.");
	return 1;
}

this::OnSellBusiness(playerid, response, businessid)
{
	if(response)
	{
		new
			totalPay
		;
		
		totalPay = BusinessInfo[businessid][eBusinessMarketPrice] / 2 + BusinessInfo[businessid][eBusinessCashbox]; 
		GiveMoney(playerid, totalPay); 
		
		BusinessInfo[businessid][eBusinessOwnerDBID] = 0; 
		
		if(BusinessInfo[businessid][eBusinessType] == BUSINESS_TYPE_RESTAURANT)
		{
			DestroyDynamicPickup(BusinessInfo[businessid][eBusinessPickup]);
			BusinessInfo[businessid][eBusinessPickup] = CreateDynamicPickup(1272, 14, BusinessInfo[businessid][eBusinessEntrance][0], BusinessInfo[businessid][eBusinessEntrance][1], BusinessInfo[businessid][eBusinessEntrance][2], 0);
		}
		
		PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
		sendMessage(playerid, COLOR_ACTION, "You sold your business and earned $%s.", MoneyFormat(totalPay));
		
		SaveBusiness(businessid); SaveCharacter(playerid); 
	}
	else return SendServerMessage(playerid, "You cancelled.");
	return 1;
}

this::onTextSend(playerid, type)
{
	switch(type)
	{
	    case 0:
	    {
			for(new i = 0; i < 2; i++)
			{
				PlayerTextDrawHide(playerid, ui_msgbox[playerid][i]);
			}
	    }
		case 1:
		{
			for(new i = 0; i < 2; i++)
			{
				PlayerTextDrawHide(playerid, JobInfo[playerid][i]);
			}
		}
	}
	return 1;
}

this::OnPlayerExitDealership(playerid, response)
{
	if(response)
	{
		SendServerMessage(playerid, "You exited out the dealership.");
		
		ResetVehicleVars(DealershipPlayerCar[playerid]); 
		DestroyVehicle(DealershipPlayerCar[playerid]); 
		
		ResetDealershipVars(playerid);
		TogglePlayerControllable(playerid, 1); 
	}
	else return ShowDealerAppend(playerid);
	return 1;
}

this::OnPlayerVehiclePurchase(playerid, id, plates[], Float:x, Float:y, Float:z, Float:a)
{
	new
		vehicleid = INVALID_VEHICLE_ID
	;
	
	DestroyVehicle(DealershipPlayerCar[playerid]);
	
	vehicleid = 
		CreateVehicle(g_aDealershipData[SubDealershipHolder[playerid]][eDealershipModelID], x, y, z, a, DealershipCarColors[playerid][0], DealershipCarColors[playerid][1], -1);  
		
	SetVehicleNumberPlate(vehicleid, plates); 
	SetVehicleToRespawn(vehicleid); 
	
	PutPlayerInVehicle(playerid, vehicleid, 0); 
	PlayerInfo[playerid][pOwnedVehicles][id] = cache_insert_id(); 
	
	if(vehicleid != INVALID_VEHICLE_ID)
	{
		VehicleInfo[vehicleid][eVehicleDBID] = cache_insert_id();
		VehicleInfo[vehicleid][eVehicleOwnerDBID] = PlayerInfo[playerid][pDBID]; 
		
		VehicleInfo[vehicleid][eVehicleModel] = g_aDealershipData[SubDealershipHolder[playerid]][eDealershipModelID];
		
		VehicleInfo[vehicleid][eVehicleColor1] = DealershipCarColors[playerid][0];
		VehicleInfo[vehicleid][eVehicleColor2] = DealershipCarColors[playerid][1];
		
		VehicleInfo[vehicleid][eVehiclePaintjob] = -1;
		
		VehicleInfo[vehicleid][eVehicleParkPos][0] = x;
		VehicleInfo[vehicleid][eVehicleParkPos][1] = y;
		VehicleInfo[vehicleid][eVehicleParkPos][2] = z;
		VehicleInfo[vehicleid][eVehicleParkPos][3] = a;
		
		format(VehicleInfo[vehicleid][eVehiclePlates], 32, "%s", plates); 
		
		VehicleInfo[vehicleid][eVehicleLocked] = false;
		VehicleInfo[vehicleid][eVehicleEngineStatus] = false;
		
		VehicleInfo[vehicleid][eVehicleFuel] = 100.0;
		
		VehicleInfo[vehicleid][eVehicleHealth] = getVehicleCondition(vehicleid, 0);
		VehicleInfo[vehicleid][eVehicleEngine] = getVehicleCondition(vehicleid, 1);
		VehicleInfo[vehicleid][eVehicleBattery] = getVehicleCondition(vehicleid, 2);
		
		VehicleInfo[vehicleid][eVehicleHasXMR] = bool:DealershipXMR[playerid];
		VehicleInfo[vehicleid][eVehicleTimesDestroyed] = 0;
		
		VehicleInfo[vehicleid][eVehicleAlarmLevel] = DealershipAlarmLevel[playerid];
		VehicleInfo[vehicleid][eVehicleLockLevel] = DealershipLockLevel[playerid];
		VehicleInfo[vehicleid][eVehicleImmobLevel] = DealershipImmobLevel[playerid]; 
		VehicleInfo[vehicleid][eVehicleInsurance] = DealershipInsLevel[playerid];

		SetVehicleHealth(vehicleid, VehicleInfo[vehicleid][eVehicleHealth]);
		SaveVehicle(vehicleid);
		
		PlayerInfo[playerid][pVehicleSpawned] = true;
		PlayerInfo[playerid][pVehicleSpawnedID] = vehicleid;
	}
	
	sendMessage(playerid, 0xB9E35EFF, "PROCESSED: You successfully bought a %s for $%s.", ReturnVehicleName(vehicleid), MoneyFormat(DealershipTotalCost[playerid]));
	callcmd::vehicle(playerid, "stats");
	
	PlayerPurchasingVehicle[playerid] = false;
	ResetDealershipVars(playerid); 
	return 1;
}

this::OnCallPaycheck(playerid, response)
{
	new
		str[128]
	;
	
	if(response)
	{
		format(str, sizeof(str), "%s called a paycheck.", ReturnName(playerid));
		SendAdminMessage(3, str);
		
		CallPaycheck(); 
	}
	return 1;
}

this::OnPlayerPurchaseWeapon(playerid, response, weapon, ammo, price)
{
	if(response)
	{
		if(price > PlayerInfo[playerid][pMoney])
			return SendErrorMessage(playerid, "You can't afford this. (Cost: $%s, Total: $%s)", MoneyFormat(price), MoneyFormat(PlayerInfo[playerid][pMoney]));
	
		new
			str[128]
		;
		
		GiveMoney(playerid, -price);
		GivePlayerGun(playerid, weapon, ammo);
		
		format(str, sizeof(str), "%s bought %s and %d Ammo", ReturnName(playerid), ReturnWeaponName(weapon), ammo);
		SendAdminMessage(1, str); 
	}
	return 1;
}

this::OnPlayerPurchaseArmor(playerid, response)
{
	if(response)
	{
		if(2000 > PlayerInfo[playerid][pMoney])
			return SendErrorMessage(playerid, "You can't afford this. (Cost: $2,000, Total: $%s)", MoneyFormat(PlayerInfo[playerid][pMoney]));
			
		new
			str[128]
		;
	
		SetPlayerArmour(playerid, 50); 
		
		format(str, sizeof(str), "%s bought Armor.", ReturnName(playerid));
		SendAdminMessage(1, str); 
	}
	return 1;
}

this::OnPlayerAddCharge(playerid, playerb, charge[])
{
	SendPoliceMessage(COLOR_COP, "[WANTED] Suspect: %s Charger: %s Reason: %s", ReturnName(playerb), ReturnName(playerid), charge);
	PlayerInfo[playerb][pActiveListings]++; 
	warrant_count ++;
	
	new 
		query[128];
	 
	mysql_format(this, query, sizeof(query), "UPDATE characters SET pActiveListings = %i WHERE char_dbid = %i", PlayerInfo[playerb][pActiveListings], PlayerInfo[playerb][pDBID]);
	mysql_pquery(this, query);
	return 1; 
}

this::OnPlayerPurchaseAmmo(playerid, response, weaponid, ammo, price)
{
	if(response)
	{
		new
			slot,
			currammo,
			str[128]
		;
		
		slot = ReturnWeaponIDSlot(weaponid); 
		currammo = PlayerInfo[playerid][pWeaponsAmmo][slot];
		
		GiveMoney(playerid, -price);
		SetPlayerAmmo(playerid, weaponid, currammo + ammo); 
		
		format(str, sizeof(str), "%s bought %d Ammo for %s", ReturnName(playerid), ammo, ReturnWeaponName(weaponid));
		SendAdminMessage(1, str); 
	}
	return 1;
}

this::Query_InsertFaction(playerid, varName, varAbbrev, idx)
{
	new insertRanks[90], str[128];
		
	mysql_format(this, insertRanks, sizeof(insertRanks), "INSERT INTO faction_ranks (`factionid`) VALUES(%i)", cache_insert_id());
	mysql_tquery(this, insertRanks);
	
	FactionInfo[idx][eFactionDBID] = cache_insert_id();
		
	format(FactionInfo[idx][eFactionName], 90, "%s", varName);
	format(FactionInfo[idx][eFactionAbbrev], 30, "%s", varAbbrev); 
		
	format(str, sizeof(str), "%s has created Faction ID %d.", ReturnName(playerid), cache_insert_id());
	SendAdminMessage(4, str);
	
	SendServerMessage(COLOR_RED, "To configure the faction, use \"/editfaction\". "); 
	return 1;
}

this::Query_InsertBusiness(playerid, newid, type, name[])
{
	BusinessInfo[newid][eBusinessDBID] = cache_insert_id(); 
	BusinessInfo[newid][eBusinessType] = type; 
	
	BusinessInfo[newid][eBusinessFood][0] = 0;
	BusinessInfo[newid][eBusinessFood][1] = 1;
	BusinessInfo[newid][eBusinessFood][2] = 2;
	BusinessInfo[newid][eBusinessRestaurantType] = 0;
	format(BusinessInfo[newid][eBusinessName], 90, "%s", name);
	SendServerMessage(playerid, "You created business ID %i. To configure, use \"/editbusiness\". ", newid); 
	return 1;
}

this::Query_LoadFactions()
{
	if(!cache_num_rows())
		return printf("[SERVER]: No factions were loaded from \"%s\" database...", SQL_DATABASE);
		
	new newThread[128], rows, fields; cache_get_data(rows, fields, this);
	
	for (new i = 0; i < rows && i < MAX_FACTIONS; i ++)
	{
		FactionInfo[i+1][eFactionDBID] = cache_get_field_content_int(i, "DBID", this);
		
		cache_get_field_content(i, "FactionName", FactionInfo[i+1][eFactionName], this, 90);
		cache_get_field_content(i, "FactionAbbrev", FactionInfo[i+1][eFactionAbbrev], this, 30);
		
		FactionInfo[i+1][eFactionSpawn][0] = cache_get_field_content_float(i, "FactionSpawnX", this);
		FactionInfo[i+1][eFactionSpawn][1] = cache_get_field_content_float(i, "FactionSpawnY", this);
		FactionInfo[i+1][eFactionSpawn][2] = cache_get_field_content_float(i, "FactionSpawnZ", this);
		
		FactionInfo[i+1][eFactionSpawnInt] = cache_get_field_content_int(i, "FactionInterior", this);
		FactionInfo[i+1][eFactionSpawnWorld] = cache_get_field_content_int(i, "FactionWorld", this);
		
		FactionInfo[i+1][eFactionJoinRank] = cache_get_field_content_int(i, "FactionJoinRank", this);
		FactionInfo[i+1][eFactionAlterRank] = cache_get_field_content_int(i, "FactionAlterRank", this);
		FactionInfo[i+1][eFactionChatRank] = cache_get_field_content_int(i, "FactionChatRank", this);
		FactionInfo[i+1][eFactionTowRank] = cache_get_field_content_int(i, "FactionTowRank", this);
		
		FactionInfo[i+1][eFactionChatColor] = cache_get_field_content_int(i, "FactionChatColor", this);
		
		FactionInfo[i+1][eFactionType] = cache_get_field_content_int(i, "FactionType", this);
		
		mysql_format(this, newThread, sizeof(newThread), "SELECT * FROM faction_ranks WHERE factionid = %i", i+1);
		mysql_tquery(this, newThread, "Query_LoadFactionRanks", "i", i+1);
	}
	printf("[SERVER]: %i factions were loaded from \"%s\" database...", rows, SQL_DATABASE);
	return 1;
}

this::Query_LoadFactionRanks(factionid)
{
	new str[128];
	
	new rows, fields; cache_get_data(rows, fields, this);
	
	for (new i = 0; i < rows; i++)
	{
		for (new j = 1; j < MAX_FACTION_RANKS; j++)
		{
			format(str, sizeof(str), "FactionRank%i", j); 
			cache_get_field_content(i, str, FactionRanks[factionid][j], this, 60);
		}
	}
	return 1;
}

this::Query_LoadPrivateVehicle(playerid)
{
	if(!cache_num_rows())
		return SendErrorMessage(playerid, "An error occurred while loading your vehicle."); 
		
	new rows, fields; cache_get_data(rows, fields, this);
	new str[128], vehicleid = INVALID_VEHICLE_ID; 
	new newThread[128];
	
	for (new i = 0; i < rows && i < MAX_VEHICLES; i++)
	{
		vehicleid = CreateVehicle(cache_get_field_content_int(i, "VehicleModel", this),
			cache_get_field_content_float(i, "VehicleParkPosX", this),
			cache_get_field_content_float(i, "VehicleParkPosY", this),
			cache_get_field_content_float(i, "VehicleParkPosZ", this),
			cache_get_field_content_float(i, "VehicleParkPosA", this),
			cache_get_field_content_int(i, "VehicleColor1", this),
			cache_get_field_content_int(i, "VehicleColor2", this),
			-1,
			0);
			
		if(vehicleid != INVALID_VEHICLE_ID)
		{
			VehicleInfo[vehicleid][eVehicleExists] = true; 
			VehicleInfo[vehicleid][eVehicleDBID] = cache_get_field_content_int(i, "VehicleDBID", this);
			
			VehicleInfo[vehicleid][eVehicleOwnerDBID] = cache_get_field_content_int(i, "VehicleOwnerDBID", this);
			VehicleInfo[vehicleid][eVehicleFaction] = cache_get_field_content_int(i, "VehicleFaction", this);
			
			VehicleInfo[vehicleid][eVehicleModel] = cache_get_field_content_int(i, "VehicleModel", this);
			
			VehicleInfo[vehicleid][eVehicleColor1] = cache_get_field_content_int(i, "VehicleColor1", this);
			VehicleInfo[vehicleid][eVehicleColor2] = cache_get_field_content_int(i, "VehicleColor2", this);
			
			VehicleInfo[vehicleid][eVehicleParkPos][0] = cache_get_field_content_float(i, "VehicleParkPosX", this);
			VehicleInfo[vehicleid][eVehicleParkPos][1] = cache_get_field_content_float(i, "VehicleParkPosY", this);
			VehicleInfo[vehicleid][eVehicleParkPos][2] = cache_get_field_content_float(i, "VehicleParkPosZ", this);
			VehicleInfo[vehicleid][eVehicleParkPos][3] = cache_get_field_content_float(i, "VehicleParkPosA", this);
			
			VehicleInfo[vehicleid][eVehicleParkInterior] = cache_get_field_content_int(i, "VehicleParkInterior", this);
			VehicleInfo[vehicleid][eVehicleParkWorld] = cache_get_field_content_int(i, "VehicleParkWorld", this);
			
			cache_get_field_content(i, "VehiclePlates", VehicleInfo[vehicleid][eVehiclePlates], this, 32);
			VehicleInfo[vehicleid][eVehicleLocked] = bool:cache_get_field_content_int(i, "VehicleLocked", this);
			
			VehicleInfo[vehicleid][eVehicleImpounded] = bool:cache_get_field_content_int(i, "VehicleImpounded", this);
			
			VehicleInfo[vehicleid][eVehicleImpoundPos][0] = cache_get_field_content_float(i, "VehicleImpoundPosX", this);
			VehicleInfo[vehicleid][eVehicleImpoundPos][1] = cache_get_field_content_float(i, "VehicleImpoundPosY", this);
			VehicleInfo[vehicleid][eVehicleImpoundPos][2] = cache_get_field_content_float(i, "VehicleImpoundPosZ", this);
			VehicleInfo[vehicleid][eVehicleImpoundPos][3] = cache_get_field_content_float(i, "VehicleImpoundPosA", this);
			
			VehicleInfo[vehicleid][eVehicleFuel] = cache_get_field_content_float(i, "VehicleFuel", this);
			
			VehicleInfo[vehicleid][eVehicleHasXMR] = bool:cache_get_field_content_int(i, "VehicleXMR", this);
			VehicleInfo[vehicleid][eVehicleTimesDestroyed] = cache_get_field_content_int(i, "VehicleTimesDestroyed", this);
			VehicleInfo[vehicleid][eVehicleEngine] = cache_get_field_content_float(i, "VehicleEngine", this);
			VehicleInfo[vehicleid][eVehicleBattery] = cache_get_field_content_float(i, "VehicleBattery", this);
			
			VehicleInfo[vehicleid][eVehicleHealth] = cache_get_field_content_float(i, "VehicleHealth", this);

			VehicleInfo[vehicleid][eVehicleAlarmLevel] = cache_get_field_content_int(i, "VehicleAlarmLevel", this);
			VehicleInfo[vehicleid][eVehicleLockLevel] = cache_get_field_content_int(i, "VehicleLockLevel", this);
			VehicleInfo[vehicleid][eVehicleImmobLevel] = cache_get_field_content_int(i, "VehicleImmobLevel", this);
			
			VehicleInfo[vehicleid][eVehicleInsurance] = cache_get_field_content_int(i, "Insurance", this);
			VehicleInfo[vehicleid][eVehicleInsBill] = cache_get_field_content_int(i, "InsBill", this);
		    VehicleInfo[vehicleid][eVehicleInsTime] = cache_get_field_content_int(i, "InsTime", this);
			
			VehicleInfo[vehicleid][eVehicleStolen] = bool:cache_get_field_content_int(i, "VehicleStolen", this);

			VehicleInfo[vehicleid][eVehicleStolenPos][0] = cache_get_field_content_float(i, "VehicleStolenPosX", this);
			VehicleInfo[vehicleid][eVehicleStolenPos][1] = cache_get_field_content_float(i, "VehicleStolenPosY", this);
			VehicleInfo[vehicleid][eVehicleStolenPos][2] = cache_get_field_content_float(i, "VehicleStolenPosZ", this);
			VehicleInfo[vehicleid][eVehicleStolenPos][3] = cache_get_field_content_float(i, "VehicleStolenPosA", this);
			
			VehicleInfo[vehicleid][eMileage] = cache_get_field_content_float(i, "Mileage", this);

			
			mysql_format(this, newThread, sizeof(newThread), "SELECT * FROM vehicle_trunk WHERE vehicle = %i", VehicleInfo[vehicleid][eVehicleDBID]);
			mysql_tquery(this, newThread, "Query_LoadTrunk", "i", VehicleInfo[vehicleid][eVehicleDBID]);


			for(new d = 1; d < 5; d++)
			{
				format(str, sizeof(str), "VehicleLastDrivers%d", d);
				VehicleInfo[vehicleid][eVehicleLastDrivers][d] = cache_get_field_content_int(i, str, this);
				
				format(str, sizeof(str), "VehicleLastPassengers%d", d);
				VehicleInfo[vehicleid][eVehicleLastPassengers][d] = cache_get_field_content_int(i, str, this);
			}
			
			for(new getDS = 0; getDS < MAX_VEH_PART; getDS++)
			{
				format(str, sizeof(str), "DamageStatus%d", getDS);
				VehicleInfo[vehicleid][eVehicleDamage][getDS] = cache_get_field_content_int(i, str, this);
			}
			
			if(VehicleInfo[vehicleid][eVehicleParkInterior] != 0)
			{
				LinkVehicleToInterior(vehicleid, VehicleInfo[vehicleid][eVehicleParkInterior]); 
				SetVehicleVirtualWorld(vehicleid, VehicleInfo[vehicleid][eVehicleParkWorld]);
			}
			
			if(!isnull(VehicleInfo[vehicleid][eVehiclePlates]))
			{
				SetVehicleNumberPlate(vehicleid, VehicleInfo[vehicleid][eVehiclePlates]);
				SetVehicleToRespawn(vehicleid); 
			}
			
			if(VehicleInfo[vehicleid][eVehicleImpounded] == true)
			{
				SetVehiclePos(vehicleid, VehicleInfo[vehicleid][eVehicleImpoundPos][0], VehicleInfo[vehicleid][eVehicleImpoundPos][1], VehicleInfo[vehicleid][eVehicleImpoundPos][2]);
				SetVehicleZAngle(vehicleid, VehicleInfo[vehicleid][eVehicleImpoundPos][3]); 
			}
			
			if(VehicleInfo[vehicleid][eVehicleStolen] == true)
			{
				SetVehiclePos(vehicleid, VehicleInfo[vehicleid][eVehicleStolenPos][0], VehicleInfo[vehicleid][eVehicleStolenPos][1], VehicleInfo[vehicleid][eVehicleStolenPos][2]);
				SetVehicleZAngle(vehicleid, VehicleInfo[vehicleid][eVehicleStolenPos][3]);
			}
			
			if(VehicleInfo[vehicleid][eVehicleLocked] == false)
				SetVehicleParamsEx(vehicleid, 0, 0, 0, 0, 0, 0, 0);
				
			else SetVehicleParamsEx(vehicleid, 0, 0, 0, 1, 0, 0, 0);
			
			VehicleInfo[vehicleid][eVehicleAdminSpawn] = false;
			
			if(HasNoEngine(playerid))
				ToggleVehicleEngine(vehicleid, true); 
				
				
			static gExecute[129];
			for (new x = 0; x < rows; x ++)
			{
			    if (VehicleInfo[x][eVehicleExists])
			    {
			        format(gExecute, sizeof(gExecute), "SELECT * FROM vehiclemods WHERE ID = %i AND Component > 0", VehicleInfo[x][eVehicleDBID]);
			        mysql_tquery(this, gExecute, "OnLoadVehicleMods", "i", x);
				}
			}
		}
	}
	
    for(new i = 0; i < 6; i ++)
    {
		PlayerTextDrawHide(playerid, Player_Vehicles_Name[playerid][i]);
		PlayerTextDrawHide(playerid, Player_Vehicles[playerid][i]);
    }
    for(new x = 0; x < 3; x++) PlayerTextDrawHide(playerid, Player_Vehicles_Arrow[playerid][x]);
	PlayerTextDrawHide(playerid, Player_Static_Arrow[playerid]);
	SetPVarInt(playerid, "Viewing_OwnedCarList", 0);
	
	PlayerInfo[playerid][pVehicleSpawned] = true;
	PlayerInfo[playerid][pVehicleSpawnedID] = vehicleid; 
	SetVehicleHealth(playerid, VehicleInfo[vehicleid][eVehicleHealth]);
	
	sendMessage(playerid, COLOR_DARKGREEN, "%s has been spawned at its parking place.", ReturnVehicleName(vehicleid));
	sendMessage(playerid, COLOR_WHITE, "Lifespan: Engine Life[%.2f], Battery Life[%.2f], Times Destroyed[%d]", VehicleInfo[vehicleid][eVehicleEngine], VehicleInfo[vehicleid][eVehicleBattery], VehicleInfo[vehicleid][eVehicleTimesDestroyed]);
	if(VehicleInfo[vehicleid][eVehicleImpounded]) SendClientMessage(playerid, COLOR_RED, "Your vehicle is impounded.");
	if(VehicleInfo[vehicleid][eVehicleStolen]) SendClientMessage(playerid, COLOR_YELLOWEX, "Your vehicle is stolen.");
	
	SendClientMessage(playerid, 0xFF00FFFF, "Hint: Follow the red marker to your parking place.");
	SetPlayerCheckpoint(playerid, VehicleInfo[vehicleid][eVehicleParkPos][0], VehicleInfo[vehicleid][eVehicleParkPos][1], VehicleInfo[vehicleid][eVehicleParkPos][2], 3.0);

	PlayerCheckpoint[playerid] = 1; 
	
	
	return 1;
}

this::Query_LoadProperties()
{
	if(!cache_num_rows())
		return printf("[SERVER]: No properties were loaded from \"%s\" database...", SQL_DATABASE);
	
	new rows, fields; cache_get_data(rows, fields, this);
	new countProperties = 0, str[128];

	for(new i = 0; i < rows && i < MAX_PROPERTY; i++)
	{
		PropertyInfo[i+1][ePropertyDBID] = cache_get_field_content_int(i, "PropertyDBID", this);
		PropertyInfo[i+1][ePropertyOwnerDBID] = cache_get_field_content_int(i, "PropertyOwnerDBID", this);
		
		PropertyInfo[i+1][ePropertyType] = cache_get_field_content_int(i, "PropertyType", this);
		PropertyInfo[i+1][ePropertyFaction] = cache_get_field_content_int(i, "PropertyFaction", this);
		
		PropertyInfo[i+1][ePropertyEntrance][0] = cache_get_field_content_float(i, "PropertyEntranceX", this);
		PropertyInfo[i+1][ePropertyEntrance][1] = cache_get_field_content_float(i, "PropertyEntranceY", this);
		PropertyInfo[i+1][ePropertyEntrance][2] = cache_get_field_content_float(i, "PropertyEntranceZ", this);
		
		PropertyInfo[i+1][ePropertyEntranceInterior] = cache_get_field_content_int(i, "PropertyEntranceInterior", this);
		PropertyInfo[i+1][ePropertyEntranceWorld] = cache_get_field_content_int(i, "PropertyEntranceWorld", this);
		
		PropertyInfo[i+1][ePropertyInterior][0] = cache_get_field_content_float(i, "PropertyInteriorX", this);
		PropertyInfo[i+1][ePropertyInterior][1] = cache_get_field_content_float(i, "PropertyInteriorY", this);
		PropertyInfo[i+1][ePropertyInterior][2] = cache_get_field_content_float(i, "PropertyInteriorZ", this);
		
		PropertyInfo[i+1][ePropertyInteriorIntID] = cache_get_field_content_int(i, "PropertyInteriorIntID", this);
		PropertyInfo[i+1][ePropertyInteriorWorld] = cache_get_field_content_int(i, "PropertyInteriorWorld", this);
		
		PropertyInfo[i+1][ePropertyMarketPrice] = cache_get_field_content_int(i, "PropertyMarketPrice", this);
		PropertyInfo[i+1][ePropertyLevel] = cache_get_field_content_int(i, "PropertyLocked", this);
		PropertyInfo[i+1][ePropertyAlarm] = cache_get_field_content_int(i, "PropertyAlarm", this);
		
		PropertyInfo[i+1][ePropertyRentFee] = cache_get_field_content_int(i, "PropertyRentFee", this);
		PropertyInfo[i+1][ePropertyRentAble] = bool:cache_get_field_content_int(i, "PropertyRentAble", this);

		
		PropertyInfo[i+1][ePropertyLocked] = bool:cache_get_field_content_int(i, "PropertyLocked", this);
		
		PropertyInfo[i+1][ePropertyCashbox] = cache_get_field_content_int(i, "PropertyCashbox", this);
		
		PropertyInfo[i+1][ePropertyPlacePos][0] = cache_get_field_content_float(i, "PropertyPlacePosX", this);
		PropertyInfo[i+1][ePropertyPlacePos][1] = cache_get_field_content_float(i, "PropertyPlacePosY", this);
		PropertyInfo[i+1][ePropertyPlacePos][2] = cache_get_field_content_float(i, "PropertyPlacePosZ", this);
		
		for(new w = 1; w < 21; w++)
		{
			format(str, sizeof(str), "PropertyWeapon%i", w);
			PropertyInfo[i+1][ePropertyWeapons][w] = cache_get_field_content_int(i, str, this);
			
			format(str, sizeof(str), "PropertyWeaponAmmo%i", w);
			PropertyInfo[i+1][ePropertyWeaponsAmmo][w] = cache_get_field_content_int(i, str, this);
		}
		
		countProperties++; 
	}
	
	printf("[SERVER]: %i properties were loaded from \"%s\" database...", countProperties, SQL_DATABASE);
	return 1;
}

this::Query_LoadVehicles()
{
	if(!cache_num_rows())
		return printf("[SERVER]: No vehicles were loaded from \"%s\" database...", SQL_DATABASE);
	
	new rows, fields; cache_get_data(rows, fields, this);
	new endCount = 0, str[128], vehicleid = INVALID_VEHICLE_ID; 
	
	for (new i = 0; i < rows && i < MAX_VEHICLES; i ++)
	{
		vehicleid = CreateVehicle(cache_get_field_content_int(i, "VehicleModel", this),
			cache_get_field_content_float(i, "VehicleParkPosX", this),
			cache_get_field_content_float(i, "VehicleParkPosY", this),
			cache_get_field_content_float(i, "VehicleParkPosZ", this),
			cache_get_field_content_float(i, "VehicleParkPosA", this),
			cache_get_field_content_int(i, "VehicleColor1", this),
			cache_get_field_content_int(i, "VehicleColor2", this),
			-1,
			cache_get_field_content_int(i, "VehicleSirens", this));
			
		if(vehicleid != INVALID_VEHICLE_ID)
		{
			VehicleInfo[vehicleid][eVehicleExists] = true; 
			VehicleInfo[vehicleid][eVehicleDBID] = cache_get_field_content_int(i, "VehicleDBID", this);
			
			VehicleInfo[vehicleid][eVehicleOwnerDBID] = cache_get_field_content_int(i, "VehicleOwnerDBID", this);
			VehicleInfo[vehicleid][eVehicleFaction] = cache_get_field_content_int(i, "VehicleFaction", this);
			
			VehicleInfo[vehicleid][eVehicleModel] = cache_get_field_content_int(i, "VehicleModel", this);
			
			VehicleInfo[vehicleid][eVehicleColor1] = cache_get_field_content_int(i, "VehicleColor1", this);
			VehicleInfo[vehicleid][eVehicleColor2] = cache_get_field_content_int(i, "VehicleColor2", this);
			
			VehicleInfo[vehicleid][eVehicleParkPos][0] = cache_get_field_content_float(i, "VehicleParkPosX", this);
			VehicleInfo[vehicleid][eVehicleParkPos][1] = cache_get_field_content_float(i, "VehicleParkPosY", this);
			VehicleInfo[vehicleid][eVehicleParkPos][2] = cache_get_field_content_float(i, "VehicleParkPosZ", this);
			VehicleInfo[vehicleid][eVehicleParkPos][3] = cache_get_field_content_float(i, "VehicleParkPosA", this);
			
			VehicleInfo[vehicleid][eVehicleParkInterior] = cache_get_field_content_int(i, "VehicleParkInterior", this);
			VehicleInfo[vehicleid][eVehicleParkWorld] = cache_get_field_content_int(i, "VehicleParkWorld", this);
			
			cache_get_field_content(i, "VehiclePlates", VehicleInfo[vehicleid][eVehiclePlates], this, 32);
			VehicleInfo[vehicleid][eVehicleLocked] = bool:cache_get_field_content_int(i, "VehicleLocked", this);
			
			VehicleInfo[vehicleid][eVehicleImpounded] = bool:cache_get_field_content_int(i, "VehicleImpounded", this);
			
			VehicleInfo[vehicleid][eVehicleImpoundPos][0] = cache_get_field_content_float(i, "VehicleImpoundPosX", this);
			VehicleInfo[vehicleid][eVehicleImpoundPos][1] = cache_get_field_content_float(i, "VehicleImpoundPosY", this);
			VehicleInfo[vehicleid][eVehicleImpoundPos][2] = cache_get_field_content_float(i, "VehicleImpoundPosZ", this);
			VehicleInfo[vehicleid][eVehicleImpoundPos][3] = cache_get_field_content_float(i, "VehicleImpoundPosA", this);
			
			VehicleInfo[vehicleid][eVehicleFuel] = cache_get_field_content_float(i, "VehicleFuel", this);
			VehicleInfo[vehicleid][eVehicleSirens] = cache_get_field_content_int(i, "VehicleSirens", this);
			
			VehicleInfo[vehicleid][eVehicleHasXMR] = bool:cache_get_field_content_int(i, "VehicleXMR", this);
			VehicleInfo[vehicleid][eVehicleTimesDestroyed] = cache_get_field_content_int(i, "VehicleTimesDestroyed", this);
						
			VehicleInfo[vehicleid][eVehicleEngine] = cache_get_field_content_float(i, "VehicleEngine", this);
			VehicleInfo[vehicleid][eVehicleBattery] = cache_get_field_content_float(i, "VehicleBattery", this);
			VehicleInfo[vehicleid][eVehicleHealth] = cache_get_field_content_float(i, "VehicleHealth", this);
			
			
			VehicleInfo[vehicleid][eVehicleAlarmLevel] = cache_get_field_content_int(i, "VehicleAlarmLevel", this);
			VehicleInfo[vehicleid][eVehicleLockLevel] = cache_get_field_content_int(i, "VehicleLockLevel", this);
			VehicleInfo[vehicleid][eVehicleImmobLevel] = cache_get_field_content_int(i, "VehicleImmobLevel", this);
			VehicleInfo[vehicleid][eVehicleInsurance] = cache_get_field_content_int(i, "Insurance", this);
			
			for(new d = 1; d < 5; d++)
			{
				format(str, sizeof(str), "VehicleLastDrivers%d", d);
				VehicleInfo[vehicleid][eVehicleLastDrivers][d] = cache_get_field_content_int(i, str, this);
				
				format(str, sizeof(str), "VehicleLastPassengers%d", d);
				VehicleInfo[vehicleid][eVehicleLastPassengers][d] = cache_get_field_content_int(i, str, this);
			}
			
			if(VehicleInfo[vehicleid][eVehicleParkInterior] != 0)
			{
				LinkVehicleToInterior(vehicleid, VehicleInfo[vehicleid][eVehicleParkInterior]); 
				SetVehicleVirtualWorld(vehicleid, VehicleInfo[vehicleid][eVehicleParkWorld]);
			}
			
			if(!isnull(VehicleInfo[vehicleid][eVehiclePlates]))
			{
				SetVehicleNumberPlate(vehicleid, VehicleInfo[vehicleid][eVehiclePlates]);
				SetVehicleToRespawn(vehicleid); 
			}
			
			if(VehicleInfo[vehicleid][eVehicleImpounded] == true)
			{
				SetVehiclePos(vehicleid, VehicleInfo[vehicleid][eVehicleImpoundPos][0], VehicleInfo[vehicleid][eVehicleImpoundPos][1], VehicleInfo[vehicleid][eVehicleImpoundPos][2]);
				SetVehicleZAngle(vehicleid, VehicleInfo[vehicleid][eVehicleImpoundPos][3]); 
			}
			
			VehicleInfo[vehicleid][eVehicleAdminSpawn] = false;
			endCount++;
		}
	}
	printf("[SERVER]: %d vehicles were loaded from \"%s\" database...", endCount, SQL_DATABASE);
	return 1;
}

this::Query_LoadXMRCategories()
{
	if(!cache_num_rows())
		return  printf("[SERVER]: No XMR categories were loaded from \"%s\" database...", SQL_DATABASE); 
	
	new rows, fields; cache_get_data(rows, fields, this);
	
	for(new i = 0; i < rows && i < MAX_XMR_CATEGORY; i++)
	{
		XMRCategoryInfo[i+1][eXMRID] = cache_get_field_content_int(i, "XMRDBID", this);
		cache_get_field_content(i, "XMRCategoryName", XMRCategoryInfo[i+1][eXMRCategoryName], this, 90);
	}
	
	printf("[SERVER]: %i XMR categories were loaded from \"%s\" database...", rows, SQL_DATABASE); 
	return 1;
}

this::Query_LoadXMRStations()
{
	if(!cache_num_rows())
		return  printf("[SERVER]: No XMR stations were loaded from \"%s\" database...", SQL_DATABASE); 
	
	new rows, fields; cache_get_data(rows, fields, this);
	
	for(new i = 0; i < rows && i < MAX_XMR_CATEGORY_STATIONS; i++)
	{
		XMRStationInfo[i+1][eXMRStationID] = cache_get_field_content_int(i, "XMRStationDBID", this);
		XMRStationInfo[i+1][eXMRCategory] = cache_get_field_content_int(i, "XMRCategory", this);
		
		cache_get_field_content(i, "XMRStationName", XMRStationInfo[i+1][eXMRStationName], this, 90);
		cache_get_field_content(i, "XMRStationURL", XMRStationInfo[i+1][eXMRStationURL], this, 128);
	}
	
	printf("[SERVER]: %i XMR stations were loaded from \"%s\" database...", rows, SQL_DATABASE); 
	return 1;
}

this::Query_LoadBusinesses()
{
	if(!cache_num_rows())
		return printf("[SERVER]: No businesses were loaded from \"%s\" database...", SQL_DATABASE); 
		
	new rows, fields; cache_get_data(rows, fields, this);
	
	for(new i = 0; i < rows && i < MAX_BUSINESS; i++)
	{
		BusinessInfo[i+1][eBusinessDBID] = cache_get_field_content_int(i, "BusinessDBID", this);
		BusinessInfo[i+1][eBusinessOwnerDBID] = cache_get_field_content_int(i, "BusinessOwnerDBID", this);
		
		BusinessInfo[i+1][eBusinessInterior][0] = cache_get_field_content_float(i, "BusinessInteriorX", this);
		BusinessInfo[i+1][eBusinessInterior][1] = cache_get_field_content_float(i, "BusinessInteriorY", this);
		BusinessInfo[i+1][eBusinessInterior][2] = cache_get_field_content_float(i, "BusinessInteriorZ", this);
		
		BusinessInfo[i+1][eBusinessInteriorWorld] = cache_get_field_content_int(i, "BusinessInteriorWorld", this);
		BusinessInfo[i+1][eBusinessInteriorIntID] = cache_get_field_content_int(i, "BusinessInteriorIntID", this);
		
		BusinessInfo[i+1][eBusinessEntrance][0] = cache_get_field_content_float(i, "BusinessEntranceX", this);
		BusinessInfo[i+1][eBusinessEntrance][1] = cache_get_field_content_float(i, "BusinessEntranceY", this);
		BusinessInfo[i+1][eBusinessEntrance][2] = cache_get_field_content_float(i, "BusinessEntranceZ", this);
		
		cache_get_field_content(i, "BusinessName", BusinessInfo[i+1][eBusinessName], this, 90);
		BusinessInfo[i+1][eBusinessType] = cache_get_field_content_int(i, "BusinessType", this);
		
		BusinessInfo[i+1][eBusinessRestaurantType] = cache_get_field_content_int(i, "RType", this);

		BusinessInfo[i+1][eBusinessFood][0] = cache_get_field_content_int(i, "Food1", this);
		BusinessInfo[i+1][eBusinessFood][1] = cache_get_field_content_int(i, "Food2", this);
		BusinessInfo[i+1][eBusinessFood][2] = cache_get_field_content_int(i, "Food3", this);
		
		BusinessInfo[i+1][eBusinessFoodPrice][0] = cache_get_field_content_int(i, "Price1", this);
		BusinessInfo[i+1][eBusinessFoodPrice][1] = cache_get_field_content_int(i, "Price2", this);
		BusinessInfo[i+1][eBusinessFoodPrice][2] = cache_get_field_content_int(i, "Price3", this);
		
		BusinessInfo[i+1][eBusinessType] = cache_get_field_content_int(i, "BusinessType", this);
		
		BusinessInfo[i+1][eBusinessLocked] = bool:cache_get_field_content_int(i, "BusinessLocked", this);
		BusinessInfo[i+1][eBusinessEntranceFee] = cache_get_field_content_int(i, "BusinessEntranceFee", this);
		
		BusinessInfo[i+1][eBusinessLevel] = cache_get_field_content_int(i, "BusinessLevel", this);
		BusinessInfo[i+1][eBusinessMarketPrice] = cache_get_field_content_int(i, "BusinessMarketPrice", this);
		
		BusinessInfo[i+1][eBusinessCashbox] = cache_get_field_content_int(i, "BusinessCashbox", this);
		BusinessInfo[i+1][eBusinessProducts] = cache_get_field_content_int(i, "BusinessProducts", this);
		
		BusinessInfo[i+1][eBusinessBankPickupLoc][0] = cache_get_field_content_float(i, "BusinessBankPickupLocX", this);
		BusinessInfo[i+1][eBusinessBankPickupLoc][1] = cache_get_field_content_float(i, "BusinessBankPickupLocY", this);
		BusinessInfo[i+1][eBusinessBankPickupLoc][2] = cache_get_field_content_float(i, "BusinessBankPickupLocZ", this);
		
		BusinessInfo[i+1][eBusinessBankPickupWorld] = cache_get_field_content_int(i, "BusinessBankPickupWorld", this);
		
		if(BusinessInfo[i+1][eBusinessType] == BUSINESS_TYPE_RESTAURANT)
		{
			if(!BusinessInfo[i+1][eBusinessOwnerDBID])
				BusinessInfo[i+1][eBusinessPickup] = CreateDynamicPickup(1272, 14, BusinessInfo[i+1][eBusinessEntrance][0], BusinessInfo[i+1][eBusinessEntrance][1], BusinessInfo[i+1][eBusinessEntrance][2], 0);
					
			else BusinessInfo[i+1][eBusinessPickup] = CreateDynamicPickup(1239, 14, BusinessInfo[i+1][eBusinessEntrance][0], BusinessInfo[i+1][eBusinessEntrance][1], BusinessInfo[i+1][eBusinessEntrance][2], 0);
		}
		else BusinessInfo[i+1][eBusinessPickup] = CreateDynamicPickup(1239, 14, BusinessInfo[i+1][eBusinessEntrance][0], BusinessInfo[i+1][eBusinessEntrance][1], BusinessInfo[i+1][eBusinessEntrance][2], 0);
		
		if(BusinessInfo[i+1][eBusinessType] == BUSINESS_TYPE_BANK)
		{
			BusinessInfo[i+1][eBusinessBankPickup] = CreateDynamicPickup(1274, 2, BusinessInfo[i+1][eBusinessBankPickupLoc][0], BusinessInfo[i+1][eBusinessBankPickupLoc][1], BusinessInfo[i+1][eBusinessBankPickupLoc][2], BusinessInfo[i+1][eBusinessBankPickupWorld]);
		}
	}
	
	printf("[SERVER]: %i businesses were loaded from \"%s\" database...", rows, SQL_DATABASE);
	return 1;
}

this::Query_AddPlayerVehicle(playerid, playerb)
{
	PlayerInfo[playerb][pOwnedVehicles][playerInsertID[playerb]] = cache_insert_id(); 
	
	SendServerMessage(playerb, "You received a vehicle from %s in slot %i.", ReturnName(playerid), playerInsertID[playerb]);
	SendServerMessage(playerid, "You issued %s a new vehicle.", ReturnName(playerb));
	
	playerInsertID[playerb] = 0;
	SaveCharacter(playerb);
	return 1;
}

this::GivePlayerGun(playerid, weaponid, ammo)
{
	new idx = ReturnWeaponIDSlot(weaponid); 
	
	if(PlayerInfo[playerid][pWeapons][idx])
	{
		RemovePlayerWeapon(playerid, PlayerInfo[playerid][pWeapons][idx]);
		printf("A weapon was removed. Slot: %i, Weapon: %i", idx, PlayerInfo[playerid][pWeapons][idx]);
	}
	
	GivePlayerWeapon(playerid, weaponid, ammo); 
	
	PlayerInfo[playerid][pWeapons][idx] = weaponid;
	PlayerInfo[playerid][pWeaponsAmmo][idx] = ammo;
	
	PlayerInfo[playerid][pWeaponsImmune] = gettime();
	
	printf("Weapon given: IDX: %i, Weapon ID: %i", idx, PlayerInfo[playerid][pWeapons][idx]); 
	return 1;
}

this::ReturnPlayerGuns(playerid)
{
	for(new i = 0; i < 4; i++) if(PlayerInfo[playerid][pWeaponsAmmo][i])
		GivePlayerWeapon(playerid, PlayerInfo[playerid][pWeapons][i], PlayerInfo[playerid][pWeaponsAmmo][i]); 
	
	return 1; 
}

this::TakePlayerGuns(playerid)
{
	for(new i = 0; i < 4; i++) if(PlayerInfo[playerid][pWeaponsAmmo][i])
		PlayerInfo[playerid][pWeapons][i] = 0;  
		
	ResetPlayerWeapons(playerid); 
	return 1;
}

this::OnPlayerUnscramble(playerid)
{	
	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
	{
		PlayerInfo[playerid][pUnscrambling] = false;
		PlayerInfo[playerid][pUnscramblerTime] = 0;
		PlayerInfo[playerid][pUnscrambleID] = 0;
		
		PlayerInfo[playerid][pScrambleSuccess] = 0; 
		PlayerInfo[playerid][pScrambleFailed] = 0; 
		KillTimer(PlayerInfo[playerid][pUnscrambleTimer]); 
		
		ShowUnscrambleTextdraw(playerid, false);
		return 1;
	}
	
	PlayerInfo[playerid][pUnscramblerTime]--;
	
	new timerString[20];
	
	format(timerString, 20, "%d", PlayerInfo[playerid][pUnscramblerTime]);
	PlayerTextDrawSetString(playerid, Unscrambler_PTD[playerid][5], timerString);
	
	if(PlayerInfo[playerid][pUnscramblerTime] < 1)
	{
		PlayerInfo[playerid][pUnscrambling] = false;
		PlayerInfo[playerid][pUnscramblerTime] = 0;
		PlayerInfo[playerid][pUnscrambleID] = 0;
		
		PlayerInfo[playerid][pScrambleSuccess] = 0; 
		PlayerInfo[playerid][pScrambleFailed] = 0; 
		KillTimer(PlayerInfo[playerid][pUnscrambleTimer]); 
		
		ShowUnscrambleTextdraw(playerid, false);
		
		new 
			vehicleid = GetPlayerVehicleID(playerid)
		;
			
		ToggleVehicleAlarms(vehicleid, true);
		NotifyVehicleOwner(vehicleid);
		
		ClearAnimations(playerid);
	}
	return 1;
}

this::OnVehicleAlarm(vehicleid)
{
	return ToggleVehicleAlarms(vehicleid, false);
}

this::OnPlayerLeaveWeapon(index)
{
	WeaponDropInfo[index][eWeaponDropped] = false;
	WeaponDropInfo[index][eWeaponDroppedBy] = 0;
	
	WeaponDropInfo[index][eWeaponWepAmmo] = 0;
	WeaponDropInfo[index][eWeaponWepID] = 0;
	
	for(new i = 0; i < 3; i++)
	{
		WeaponDropInfo[index][eWeaponPos][i] = 0.0;
	}
	
	if(IsValidDynamicObject(WeaponDropInfo[index][eWeaponObject]))
	{
		DestroyDynamicObject(WeaponDropInfo[index][eWeaponObject]);
	}
	
	return 1;
}

this::OnPropertyCreate(playerid, type)
{
	new
		idx,
		str[128]
	;
	
	for(new i = 1; i < MAX_PROPERTY; i++)
	{
		if(PropertyInfo[i][ePropertyDBID])
			continue;
			
		idx = i; 
		break;
	}
	
	PropertyInfo[idx][ePropertyDBID] = cache_insert_id(); 
	PropertyInfo[idx][ePropertyType] = type; 
	
	format(str, sizeof(str), "%s created Property ID %i.", ReturnName(playerid), cache_insert_id());
	SendAdminMessage(4, str);
	
	SendClientMessage(playerid, COLOR_RED, "[ ! ]{FFFFFF} Use \"/editproperty\" to continue the next part.");
	return 1;
}

this::OnEntranceChange(playerid, response, property)
{
	if(response)
	{
		GetPlayerPos(playerid, PropertyInfo[property][ePropertyEntrance][0], PropertyInfo[property][ePropertyEntrance][1], PropertyInfo[property][ePropertyEntrance][2]);
		
		PropertyInfo[property][ePropertyEntranceInterior] = GetPlayerInterior(playerid);
		PropertyInfo[property][ePropertyEntranceWorld] = GetPlayerVirtualWorld(playerid);
		
		SaveProperty(property);
		SendServerMessage(playerid, "You set Property %i's entrance.", property);
	}
	return 1;
}

this::OnInteriorChange(playerid, response, property)
{
	if(response)
	{
		GetPlayerPos(playerid, PropertyInfo[property][ePropertyInterior][0], PropertyInfo[property][ePropertyInterior][1], PropertyInfo[property][ePropertyInterior][2]);
		
		new
			world = random(40000)+playerid+2;
		
		PropertyInfo[property][ePropertyInteriorIntID] = GetPlayerInterior(playerid);
		PropertyInfo[property][ePropertyInteriorWorld] = world;
		
		foreach(new i : Player) if(IsPlayerInProperty(i) == property)
		{
		    TogglePlayerControllable(i, 0);
		    SetCameraBehindPlayer(i);
			SetPlayerPos(i, PropertyInfo[property][ePropertyInterior][0], PropertyInfo[property][ePropertyInterior][1], PropertyInfo[property][ePropertyInterior][2]);
			SetPlayerInterior(i, GetPlayerInterior(playerid)); SetPlayerVirtualWorld(i, world); 
			SendServerMessage(i, "The property you were in was amended."); 
			SetTimerEx("UnfreezePlayer", 3000, false, "i", i);
		}

		SaveProperty(property);
		SendServerMessage(playerid, "You set Property %i's interior.", property);
	}
	return 1;
}

this::UnfreezePlayer(playerid)
{
    TogglePlayerControllable(playerid, 1);
}

this::OnPlayerEnterProperty(playerid, id)
{
	SetPlayerPos(playerid, PropertyInfo[id][ePropertyInterior][0], PropertyInfo[id][ePropertyInterior][1], PropertyInfo[id][ePropertyInterior][2]);
	return TogglePlayerControllable(playerid, 1);
}

this::Query_ShowVehicleList(playerid, idx)
{
	new rows, fields; cache_get_data(rows, fields, this);
	
	new 
		vehicleModel,
		vehicleColor1,
		vehicleColor2
	;
	
	for(new i = 0; i < rows; i++)
	{
		vehicleModel = cache_get_field_content_int(0, "VehicleModel", this);
		vehicleColor1 = cache_get_field_content_int(0, "VehicleColor1", this);
		vehicleColor2 = cache_get_field_content_int(0, "VehicleColor2", this);
	}
    PlayerTextDrawShow(playerid, Player_Static_Arrow[playerid]);
    if(idx == 1)
    {
		PlayerTextDrawShow(playerid, Player_Vehicles_Arrow[playerid][0]);
	}
    if(idx == 2)
    {
        PlayerTextDrawHide(playerid, Player_Vehicles_Arrow[playerid][0]);
		PlayerTextDrawShow(playerid, Player_Vehicles_Arrow[playerid][1]);
	}
    if(idx == 3)
    {
        PlayerTextDrawHide(playerid, Player_Vehicles_Arrow[playerid][0]);
        PlayerTextDrawHide(playerid, Player_Vehicles_Arrow[playerid][1]);
		PlayerTextDrawShow(playerid, Player_Vehicles_Arrow[playerid][2]);
	}
	
	new str[64];
    format(str, sizeof(str), "%s", ReturnVehicleModelName(vehicleModel));
    PlayerTextDrawSetString(playerid, Player_Vehicles_Name[playerid][idx-1], str);
    
    PlayerTextDrawSetPreviewModel(playerid, Player_Vehicles[playerid][idx-1], vehicleModel);
    PlayerTextDrawSetPreviewVehCol(playerid, Player_Vehicles[playerid][idx-1], vehicleColor1, vehicleColor2);
    
    PlayerTextDrawShow(playerid, Player_Vehicles[playerid][idx-1]);
    PlayerTextDrawShow(playerid, Player_Vehicles_Name[playerid][idx-1]);

	SelectTextDraw(playerid, COLOR_DARKGREEN);
	SetPVarInt(playerid, "Viewing_OwnedCarList", 1);
	return 1;
}

this::OnOfflineAjail(playerid, jailing[], reason[], length)
{
	SendServerMessage(playerid, "%s was successfully admin jailed.", jailing); 
	
	new
		logQuery[256]
	;
	
	mysql_format(this, logQuery, sizeof(logQuery), "INSERT INTO ajail_logs (JailedDBID, JailedName, Reason, Date, JailedBy) VALUES(%i, '%e', '%e', '%e', '%e')", ReturnDBIDFromName(jailing), jailing, reason, ReturnDate(), ReturnName(playerid));
	mysql_tquery(this, logQuery);
	return 1;
}

this::OnOfflineBan(playerid, banning[], dbid, masterdbid, reason[], date[])
{
	SendServerMessage(playerid, "%s was successfully banned.", banning);
	
	new
		logQuery[256]
	;
	
	mysql_format(this, logQuery, sizeof(logQuery), "INSERT INTO ban_logs (CharacterDBID, MasterDBID, CharacterName, Reason, BannedBy, Date) VALUES(%i, %i, '%e', '%e', '%e', '%e')",
		dbid, masterdbid, banning, reason, date);
		
	mysql_tquery(this, logQuery);
	return 1;
}

this::OnXMRCategory(playerid, newid, cat[])
{
	XMRCategoryInfo[newid][eXMRID] = cache_insert_id(); 
	format(XMRCategoryInfo[newid][eXMRCategoryName], 90, "%s", cat);
	
	SendServerMessage(playerid, "You made a new XMR category. \"%s\" (ID: %i)", cat, newid); 
	return 1;
}

this::OnXMRStation(playerid, category, newid, url[], name[])
{
	XMRStationInfo[newid][eXMRStationID] = cache_insert_id(); 
	
	format(XMRStationInfo[newid][eXMRStationName], 90, "%s", name);
	format(XMRStationInfo[newid][eXMRStationURL], 128, "%s", url); 
	
	SendServerMessage(playerid, "You made a new XMR station. \"%s\" (ID: %i)", name, newid);
	sendMessage(playerid, COLOR_WHITE, "Category: %s (%i). URL: %s", XMRCategoryInfo[category][eXMRCategoryName], category, url);
	return 1;
}

this::Float:GetVehicleTopSpeed(vehicleid)
{
    new model = GetVehicleModel(vehicleid);
 
    if (model)
    {
        return float(s_TopSpeed[(model - 400)]);
    }
    return 0.0;
}

this::SetPlayersSpawn(playerid)
{
	switch(PlayerInfo[playerid][pSpawnPoint])
	{
		case SPAWN_POINT_AIRPORT:
		{
			SetPlayerPos(playerid, 1642.02, -2334.05, 13.5469); 
			SetPlayerInterior(playerid, 0);
			SetPlayerVirtualWorld(playerid, 0);
		}
		case SPAWN_POINT_PROPERTY:
		{
			new
				id;
				
			id = PlayerInfo[playerid][pSpawnPointHouse]; 
			
			if(!PropertyInfo[id][ePropertyDBID] || PropertyInfo[id][ePropertyOwnerDBID] != PlayerInfo[playerid][pDBID] || PlayerInfo[playerid][pRentAt] != PropertyInfo[id][ePropertyDBID])
			{
				PlayerInfo[playerid][pSpawnPoint] = SPAWN_POINT_AIRPORT; 
				PlayerInfo[playerid][pSpawnPointHouse] = 0;
				
				return SetPlayersSpawn(playerid);
			}
			
			SetPlayerPos(playerid, PropertyInfo[id][ePropertyInterior][0], PropertyInfo[id][ePropertyInterior][1], PropertyInfo[id][ePropertyInterior][2]);
			
			SetPlayerInterior(playerid, PropertyInfo[id][ePropertyInteriorIntID]);
			SetPlayerVirtualWorld(playerid, PropertyInfo[id][ePropertyInteriorWorld]); 
			
			PlayerInfo[playerid][pInsideProperty] = id;
			
			SendClientMessage(playerid, COLOR_LIGHTRED, "Rent Price:"); // 当前租房价格
			sendMessage(playerid, COLOR_WHITE, "$%i", PropertyInfo[ PlayerInfo[playerid][pRentAt] ][ePropertyRentFee]);
		}
		case SPAWN_POINT_FACTION:
		{
			if(!PlayerInfo[playerid][pFaction])
			{
				PlayerInfo[playerid][pSpawnPoint] = SPAWN_POINT_AIRPORT;
				return SetPlayersSpawn(playerid);
			}
			
			new 
				idx 
			; 
			
			idx = PlayerInfo[playerid][pFaction];
			
			if(!FactionInfo[idx][eFactionDBID])
			{
				PlayerInfo[playerid][pSpawnPoint] = SPAWN_POINT_AIRPORT;
				return SetPlayersSpawn(playerid);
			}
			
			SetPlayerPos(playerid, FactionInfo[idx][eFactionSpawn][0], FactionInfo[idx][eFactionSpawn][1], FactionInfo[idx][eFactionSpawn][2]);
			
			SetPlayerInterior(playerid, FactionInfo[idx][eFactionSpawnInt]);
			SetPlayerVirtualWorld(playerid, FactionInfo[idx][eFactionSpawnWorld]); 
		}
	}
	return 1;
}

this::OnTaserShoot(playerid)
{
	return SetPlayerArmedWeapon(playerid, WEAPON_SILENCED); 
}

this::OnPlayerTasered(playerid)
{
	SetPlayerDrunkLevel(playerid, 1000);
	TogglePlayerControllable(playerid, 1);
	
	ApplyAnimation(playerid, "PED", "KO_skid_front", 4.1, 0, 1, 1, 1, 0);
	ApplyAnimation(playerid, "PED", "KO_skid_front", 4.1, 0, 1, 1, 1, 0);
	return 1; 
}

this::OnPhoneCall(playerid, type)
{
	switch(type)
	{
		case 1:
		{
			SendClientMessage(playerid, COLOR_GREY, "[ ! ] The number you dialed is out of service."); 
			playerPhone[playerid] = 0;
			
			if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_USECELLPHONE){
				SetPlayerSpecialAction(playerid, SPECIAL_ACTION_STOPUSECELLPHONE);
			}
			
			return 1;
		}
		case 2:
		{
			SendClientMessage(playerid, COLOR_GREY, "[ ! ] The number you dialed cannot be reached at this time.");
			playerPhone[playerid] = 0;
			
			if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_USECELLPHONE){
				SetPlayerSpecialAction(playerid, SPECIAL_ACTION_STOPUSECELLPHONE);
			}
			
			return 1;
		}
		case 3:
		{
			SendClientMessage(playerid, COLOR_GREY, "[ ! ] You received a busy tone.");
			playerPhone[playerid] = 0;
			
			if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_USECELLPHONE){
				SetPlayerSpecialAction(playerid, SPECIAL_ACTION_STOPUSECELLPHONE);
			}
			
			return 1;
		}
		case 4:
		{
			SendClientMessage(playerid, COLOR_GREY, "[ ! ] You received a busy tone.");
			playerPhone[playerid] = 0;
			
			if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_USECELLPHONE){
				SetPlayerSpecialAction(playerid, SPECIAL_ACTION_STOPUSECELLPHONE);
			}
			
			return 1;
		}
	}
	return 1;
}

this::OnPhoneSMS(playerid, type, playerb, text[])
{
	if(GetNearestAntenna(playerid) == -1)
	{
	    playerText[playerid] = 0;
		PlayerTextDrawSetString(playerid, PhoneTime[playerid], "Deliver_Failed");
	    return SetTimerEx("RefreshPhone", 2500, false, "i", playerid);
	}
	switch(type)
	{
		case 1:
		{
		    playerText[playerid] = 0;
			PlayerTextDrawSetString(playerid, PhoneTime[playerid], "Deliver_Failed");
		    return SetTimerEx("RefreshPhone", 2500, false, "i", playerid);
		}
		case 2:
		{
		    playerText[playerid] = 0;
			PlayerTextDrawSetString(playerid, PhoneTime[playerid], "Deliver_Failed");
		    return SetTimerEx("RefreshPhone", 2500, false, "i", playerid);
		}
		case 3:
		{
			if(!IsPlayerConnected(playerb)) //Possible they disconnect while timer plays;
			{
			    playerText[playerid] = 0;
				PlayerTextDrawSetString(playerid, PhoneTime[playerid], "Deliver_Failed");
			    return SetTimerEx("RefreshPhone", 2500, false, "i", playerid);
			}
		    if(!PlayerInfo[playerText[playerid]][pUseGUI])
		    {
		        //PlayerTextDrawSetSelectable(playerText[playerid], PhoneNotify[ playerText[playerid] ], true);
				Phone_ShowUI(playerText[playerid]);
				PlayerTextDrawSetString(playerText[playerid], PhoneNotify[ playerText[playerid] ], "NEW_MESSAGE!");
		    }
			SetTimerEx("HideNotify", 2500, false, "i", playerText[playerid]);
			
		    playerText[playerid] = 0;
			PlayerTextDrawSetString(playerid, PhoneTime[playerid], "SMS_Sent");
		    SetTimerEx("RefreshPhone", 2500, false, "i", playerid);
		    
			if(strlen(text) > 80)
			{
				sendMessage(playerb, COLOR_YELLOWEX, "SMS: %.80s ...", text, PlayerInfo[playerid][pPhone]);
				sendMessage(playerb, COLOR_YELLOWEX, "SMS: ...%s, Sender: %i", text[80], PlayerInfo[playerid][pPhone]);
			}
			else sendMessage(playerb, COLOR_YELLOWEX, "SMS: %s, Sender: %i", text, PlayerInfo[playerid][pPhone]);
			
			playerText[playerid] = 0;
			return 1;
		}
	}
	return 1;
}

this::OnAjailRecord(playerid)
{
	if(!cache_num_rows())
		return SendClientMessage(playerid, COLOR_RED, "[ ! ] {FFFFFF}This player hasn't been admin jailed.");
	
	new rows, fields;
	cache_get_data(rows, fields, this);
	
	new
		JailedName[32], 
		Reason[128],
		Date[90],
		JailedBy[32],
		Time
	;
	
	for(new i = 0; i < rows; i++)
	{
		cache_get_field_content(i, "JailedName", JailedName, this, 32);
		cache_get_field_content(i, "Reason", Reason, this, 128);
		
		cache_get_field_content(i, "Date", Date, this, 90);
		cache_get_field_content(i, "JailedBy", JailedBy, this, 32);
		
		Time = cache_get_field_content_int(i, "Time", this);
		
		sendMessage(playerid, COLOR_ACTION, "[%s] %s was admin jailed by %s for %d minutes, Reason: %s", Date, JailedName, JailedBy, Time, Reason);
	}
		
	return 1;
}

//Stock functions:
stock PreloadAnimations(playerid)
{
	for (new i = 0; i < sizeof(g_aPreloadLibs); i ++) {
	    ApplyAnimation(playerid, g_aPreloadLibs[i], "null", 4.0, 0, 0, 0, 0, 0, 1);
	}
	return 1;
} // Credits to Emmet, South Central Roleplay

stock sendMessage(playerid, color, const str[], {Float,_}:...)
{
	static
	    args,
	    start,
	    end,
	    string[156]
	;
	#emit LOAD.S.pri 8
	#emit STOR.pri args

	if (args > 12)
	{
		#emit ADDR.pri str
		#emit STOR.pri start

	    for (end = start + (args - 12); end > start; end -= 4)
		{
	        #emit LREF.pri end
	        #emit PUSH.pri
		}
		#emit PUSH.S str
		#emit PUSH.C 156
		#emit PUSH.C string
		#emit PUSH.C args
		#emit SYSREQ.C format

		SendClientMessage(playerid, color, string);

		#emit LCTRL 5
		#emit SCTRL 4
		#emit RETN
	}
	return SendClientMessage(playerid, color, str);
} // Credits to Emmet, South Central Roleplay

stock SendClientMessageToAllEx(color, const str[], {Float,_}:...)
{
	static
	    args,
	    start,
	    end,
	    string[144]
	;
	#emit LOAD.S.pri 8
	#emit STOR.pri args

	if (args > 8)
	{
		#emit ADDR.pri str
		#emit STOR.pri start

	    for (end = start + (args - 8); end > start; end -= 4)
		{
	        #emit LREF.pri end
	        #emit PUSH.pri
		}
		#emit PUSH.S str
		#emit PUSH.C 144
		#emit PUSH.C string

		#emit LOAD.pri args
		#emit ADD.C 4
		#emit PUSH.pri
		#emit SYSREQ.C format

        #emit LCTRL 5
		#emit SCTRL 4

		foreach (new i : Player) {
			SendClientMessage(i, color, string);
		}
		return 1;
	}
	return SendClientMessageToAll(color, str);
} // Credits to Emmet, South Central Roleplay

stock SendNearbyMessage(playerid, Float:radius, color, const str[], {Float,_}:...)
{
	static
	    args,
	    start,
	    end,
	    string[144]
	;
	#emit LOAD.S.pri 8
	#emit STOR.pri args

	if (args > 16)
	{
		#emit ADDR.pri str
		#emit STOR.pri start

	    for (end = start + (args - 16); end > start; end -= 4)
		{
	        #emit LREF.pri end
	        #emit PUSH.pri
		}
		#emit PUSH.S str
		#emit PUSH.C 144
		#emit PUSH.C string

		#emit LOAD.S.pri 8
		#emit CONST.alt 4
		#emit SUB
		#emit PUSH.pri

		#emit SYSREQ.C format
		#emit LCTRL 5
		#emit SCTRL 4

        foreach (new i : Player)
		{
			if (IsPlayerNearPlayer(i, playerid, radius)) {
  				SendClientMessage(i, color, string);
			}
		}
		return 1;
	}
	foreach (new i : Player)
	{
		if (IsPlayerNearPlayer(i, playerid, radius)) {
			SendClientMessage(i, color, str);
		}
	}
	return 1;
} // Credits to Emmet, South Central Roleplay

stock SendAdminMessage(level, const str[])
{
	new 
		newString[128]
	;
	
	format(newString, sizeof(newString), "AdmWarn(%i): %s", level, str);
	
	foreach(new i : Player)
	{
		if(PlayerInfo[i][pAdmin] >= level)
		{
			SendClientMessage(i, COLOR_YELLOWEX, newString);
		}
	}
	return 1;
}

stock SendAdminMessageEx(color, level, const str[], {Float,_}:...)
{
	static
	    args,
	    start,
	    end,
	    string[144]
	;
	#emit LOAD.S.pri 8
	#emit STOR.pri args

	if (args > 8)
	{
		#emit ADDR.pri str
		#emit STOR.pri start

	    for (end = start + (args - 8); end > start; end -= 4)
		{
	        #emit LREF.pri end
	        #emit PUSH.pri
		}
		#emit PUSH.S str
		#emit PUSH.C 144
		#emit PUSH.C string

		#emit LOAD.S.pri 8
		#emit ADD.C 4
		#emit PUSH.pri

		#emit SYSREQ.C format
		#emit LCTRL 5
		#emit SCTRL 4

        foreach (new i : Player)
		{
			if (PlayerInfo[i][pAdmin] >= level) {
  				SendClientMessage(i, color, string);
			}
		}
		return 1;
	}
	foreach (new i : Player)
	{
		if (PlayerInfo[i][pAdmin] >= level) {
			SendClientMessage(i, color, str);
		}
	}
	return 1;
} // Credits to Emmet, South Central Roleplay

stock SendFactionMessage(playerid, const str[], {Float,_}:...)
{
	static
	    args,
	    start,
	    end,
	    string[144]
	;
	#emit LOAD.S.pri 8
	#emit STOR.pri args

	if (args > 8)
	{
		#emit ADDR.pri str
		#emit STOR.pri start

	    for (end = start + (args - 8); end > start; end -= 4)
		{
	        #emit LREF.pri end
	        #emit PUSH.pri
		}
		#emit PUSH.S str
		#emit PUSH.C 144
		#emit PUSH.C string

		#emit LOAD.S.pri 8
		#emit ADD.C 4
		#emit PUSH.pri

		#emit SYSREQ.C format
		#emit LCTRL 5
		#emit SCTRL 4

        foreach (new i : Player)
		{
			if (PlayerInfo[i][pFaction] == PlayerInfo[playerid][pFaction]) {
				if(PlayerInfo[i][pFactionChat] == false)
  				{ 
					SendClientMessage(i, FactionInfo[PlayerInfo[playerid][pFaction]][eFactionChatColor], string);
				}
			}
		}
		return 1;
	}
	foreach (new i : Player)
	{
		if (PlayerInfo[i][pFaction] == PlayerInfo[playerid][pFaction]) {
			if(PlayerInfo[i][pFactionChat] == false)
  			{ 
				SendClientMessage(i, FactionInfo[PlayerInfo[playerid][pFaction]][eFactionChatColor], str);
			}
		}
	}
	return 1;
} // Credits to Emmet, South Central Roleplay

stock SendFactionMessageEx(playerid, color, const str[], {Float,_}:...)
{
	static
	    args,
	    start,
	    end,
	    string[144]
	;
	#emit LOAD.S.pri 8
	#emit STOR.pri args

	if (args > 8)
	{
		#emit ADDR.pri str
		#emit STOR.pri start

	    for (end = start + (args - 8); end > start; end -= 4)
		{
	        #emit LREF.pri end
	        #emit PUSH.pri
		}
		#emit PUSH.S str
		#emit PUSH.C 144
		#emit PUSH.C string

		#emit LOAD.S.pri 8
		#emit ADD.C 4
		#emit PUSH.pri

		#emit SYSREQ.C format
		#emit LCTRL 5
		#emit SCTRL 4

        foreach (new i : Player)
		{
			if (PlayerInfo[i][pFaction] == PlayerInfo[playerid][pFaction]) {
  				SendClientMessage(i, color, string);
			}
		}
		return 1;
	}
	foreach (new i : Player)
	{
		if (PlayerInfo[i][pFaction] == PlayerInfo[playerid][pFaction]) {
			SendClientMessage(i, color, str);
		}
	}
	return 1;
} // Credits to Emmet, South Central Roleplay

stock SendPoliceMessage(color, const str[], {Float,_}:...)
{
	static
	    args,
	    start,
	    end,
	    string[144]
	;
	#emit LOAD.S.pri 8
	#emit STOR.pri args

	if (args > 8)
	{
		#emit ADDR.pri str
		#emit STOR.pri start

	    for (end = start + (args - 8); end > start; end -= 4)
		{
	        #emit LREF.pri end
	        #emit PUSH.pri
		}
		#emit PUSH.S str
		#emit PUSH.C 144
		#emit PUSH.C string

		#emit LOAD.S.pri 8
		#emit ADD.C 4
		#emit PUSH.pri

		#emit SYSREQ.C format
		#emit LCTRL 5
		#emit SCTRL 4

        foreach (new i : Player)
		{
			if (FactionInfo[PlayerInfo[i][pFaction]][eFactionType] == FACTION_TYPE_POLICE) {
  				SendClientMessage(i, color, string);
			}
		}
		return 1;
	}
	foreach (new i : Player)
	{
		if (FactionInfo[PlayerInfo[i][pFaction]][eFactionType] == FACTION_TYPE_POLICE) {
			SendClientMessage(i, color, str);
		}
	}
	return 1;
} // Credits to Emmet, South Central Roleplay
	
stock SendUnauthMessage(playerid)
{
	return SendClientMessage(playerid, COLOR_RED, "ACCESS DENIED:{FFFFFF} You aren't authorized to use this.");
}

stock SendTeleportMessage(playerid)
{
	return SendClientMessage(playerid, COLOR_GREY, "You were teleported."); 
}

stock IsPlayerNearPlayer(playerid, targetid, Float:radius)
{
	static
		Float:fX,
		Float:fY,
		Float:fZ;

	GetPlayerPos(targetid, fX, fY, fZ);

	return (GetPlayerInterior(playerid) == GetPlayerInterior(targetid) && GetPlayerVirtualWorld(playerid) == GetPlayerVirtualWorld(targetid)) && IsPlayerInRangeOfPoint(playerid, radius, fX, fY, fZ);
}

stock IsValidRoleplayName(const name[]) {
	if (!name[0] || strfind(name, "_") == -1)
	    return 0;

	else for (new i = 0, len = strlen(name); i != len; i ++) {
	    if ((i == 0) && (name[i] < 'A' || name[i] > 'Z'))
	        return 0;

		else if ((i != 0 && i < len  && name[i] == '_') && (name[i + 1] < 'A' || name[i + 1] > 'Z'))
		    return 0;

		else if ((name[i] < 'A' || name[i] > 'Z') && (name[i] < 'a' || name[i] > 'z') && name[i] != '_' && name[i] != '.')
		    return 0;
	}
	return 1;
}

stock ReturnName(playerid, underScore = 1)
{
	new playersName[MAX_PLAYER_NAME + 2];
	GetPlayerName(playerid, playersName, sizeof(playersName)); 
	
	if(!underScore)
	{
		if(PlayerInfo[playerid][pMasked])
			format(playersName, sizeof(playersName), "[Mask %i_%i]", PlayerInfo[playerid][pMaskID][0], PlayerInfo[playerid][pMaskID][1]); 
			
		else
		{
			for(new i = 0, j = strlen(playersName); i < j; i ++) 
			{ 
				if(playersName[i] == '_') 
				{ 
					playersName[i] = ' '; 
				} 
			} 
		}
	}
	return playersName;
}

stock ReturnFoodName(id)
{
	new str[128 + 2];
	format(str, sizeof(str), "%s", Food_Data[id][FoodName]);
	for(new i = 0, j = strlen(str); i < j; i ++)
	{
		if(str[i] == '_')
		{
			str[i] = ' ';
		}
	}
	return str;
}

stock KickEx(playerid)
{
	return SetTimerEx("KickTimer", 100, false, "i", playerid);
}

stock ClearLines(playerid, lines)
{
	if (lines > 20 || lines < 1)
		return 0;
		
	for (new i = 0; i < lines; i++)
	{
		SendClientMessage(playerid, -1, " ");
	}
	return 1;
}

stock strreplace(string[], find, replace)
{
    for(new i=0; string[i]; i++)
	{
        if(string[i] == find)
		{
            string[i] = replace;
        }
    }
}

stock ReturnDate()
{
	new sendString[90], MonthStr[40], month, day, year;
	new hour, minute, second;
	
	gettime(hour, minute, second);
	getdate(year, month, day);
	switch(month)
	{
	    case 1:  MonthStr = "January";
	    case 2:  MonthStr = "February";
	    case 3:  MonthStr = "March";
	    case 4:  MonthStr = "April";
	    case 5:  MonthStr = "May";
	    case 6:  MonthStr = "June";
	    case 7:  MonthStr = "July";
	    case 8:  MonthStr = "August";
	    case 9:  MonthStr = "September";
	    case 10: MonthStr = "October";
	    case 11: MonthStr = "November";
	    case 12: MonthStr = "December";
	}
	
	format(sendString, 90, "%s %d, %d %02d:%02d:%02d", MonthStr, day, year, hour, minute, second);
	return sendString;
}

stock ShowCharacterStats(playerid, playerb)
{
	// playerid = player's statistics;
	// playerb = player receiving stats;
	
	new 
		vehicle_key[20],
		duplicate_key[20],
		business_key[20] = "None"
	;
	
	if(!PlayerInfo[playerid][pVehicleSpawned])
		vehicle_key = "None";
	else format(vehicle_key, 32, "%d", PlayerInfo[playerid][pVehicleSpawnedID]);
	
	if(PlayerInfo[playerid][pDuplicateKey] == INVALID_VEHICLE_ID)
		duplicate_key = "None";
	else format(duplicate_key, 32, "%d", PlayerInfo[playerid][pDuplicateKey]); 
	
	for(new i = 1; i < MAX_BUSINESS; i++)
	{
		if(!BusinessInfo[i][eBusinessDBID])
			continue;
			
		if(BusinessInfo[i][eBusinessOwnerDBID] == PlayerInfo[playerid][pDBID])
			format(business_key, 20, "%d", BusinessInfo[i][eBusinessDBID]); 
	}
	
	sendMessage(playerb, COLOR_DARKGREEN, "|__________________%s [%s]__________________|", ReturnName(playerid), ReturnDate());

	sendMessage(playerb, COLOR_GRAD2, "CHARACTER: Faction:[%s] Rank:[%s]", ReturnFactionName(playerid), ReturnFactionRank(playerid));
	sendMessage(playerb, COLOR_GRAD1, "EXPERIENCE: Level:[%d] Experience:[%d/%d] Time played:[%d hours]", PlayerInfo[playerid][pLevel], PlayerInfo[playerid][pEXP], ((PlayerInfo[playerid][pLevel]) * 4 + 2), PlayerInfo[playerid][pTimeplayed]);
	sendMessage(playerb, COLOR_GRAD2, "WEAPONS: Primary weapon:[%s] Ammo:[%d] Secondary weapon:[%s] Ammo:[%d]", ShowPlayerWeapons(playerid, 4), PlayerInfo[playerid][pWeaponsAmmo][3], ShowPlayerWeapons(playerid, 3), PlayerInfo[playerid][pWeaponsAmmo][2]);
	sendMessage(playerb, COLOR_GRAD1, "INVENTORY: Phone:[%d] Radio:[%s] Channel:[%d] Mask:[%s] Melee:[%s]", PlayerInfo[playerid][pPhone], (PlayerInfo[playerid][pHasRadio] != true) ? ("No") : ("Yes"), PlayerInfo[playerid][pRadio][PlayerInfo[playerid][pMainSlot]], (PlayerInfo[playerid][pHasMask] != true) ? ("No") : ("Yes"), ShowPlayerWeapons(playerid, 1));
	sendMessage(playerb, COLOR_GRAD2, "MONEY: Cash:[$%s] Bank:[$%s] Paycheck:[$%s]", MoneyFormat(PlayerInfo[playerid][pMoney]), MoneyFormat(PlayerInfo[playerid][pBank]), MoneyFormat(PlayerInfo[playerid][pPaycheck]));
	sendMessage(playerb, COLOR_GRAD1, "OTHER: VehicleKey:[%s] DuplicateKey:[%s] BusinessKey:[%s]", vehicle_key, duplicate_key, business_key);
	
	if(PlayerInfo[playerb][pAdmin])
	{
		sendMessage(playerb, COLOR_GRAD1, "FOR ADMIN: DBID:[%d] Master:[%s (%d)] Interior:[%d] Local:[%d]", PlayerInfo[playerid][pDBID], e_pAccountData[playerid][mAccName], e_pAccountData[playerid][mDBID], GetPlayerInterior(playerid), GetPlayerVirtualWorld(playerid));
		
		sendMessage(playerb, COLOR_GRAD2, "CONNECTION: IP:[%s] Last Online:[%s] Duration:[%d Minutes]", ReturnIP(playerid), ReturnLastOnline(playerid), PlayerInfo[playerid][pLastOnlineTime]);
		
		sendMessage(playerb, COLOR_GRAD1, "MISC: InsideProperty:[%i] InsideBusiness:[%i]", IsPlayerInProperty(playerid), IsPlayerInBusiness(playerid));
	}
	
	sendMessage(playerb, COLOR_DARKGREEN, "|__________________%s [%s]__________________|", ReturnName(playerid), ReturnDate());
	
	return 1;
}

stock ReturnIP(playerid)
{
	new
		ipAddress[20];

	GetPlayerIp(playerid, ipAddress, sizeof(ipAddress));
	return ipAddress; 
}

stock ReturnGPCI(playerid)
{
	new szSerial[41]; // 40 + \0
 
	gpci(playerid, szSerial, sizeof(szSerial));
	return szSerial;
}

stock ReturnLastOnline(playerid)
{
	new returnString[90]; 
	
	if(isnull(PlayerInfo[playerid][pLastOnline]))
		returnString = "Never";
	
	else
		format(returnString, 90, "%s", PlayerInfo[playerid][pLastOnline]);
	
	return returnString;
}

stock ConfirmDialog(playerid, caption[], info[], callback[], {Float,_}:...)
{
	new n = numargs(), 		// number of arguments, static + optional
		szParamHash[256];	// variable where the passed arguments will be stored
	for(new arg = 4; arg < n; arg++){	// loop all additional arguments
		format(szParamHash, sizeof(szParamHash), "%s%d|", szParamHash, getarg(arg)); // store them in szParamHash
	}
	SetPVarInt(playerid, "confDialogArgs", n -4);			// store the amount of additional arguments
	SetPVarString(playerid, "confDialCallback", callback);	// store the callback that needs to be called after response
	SetPVarString(playerid, "confDialog_arg", szParamHash);	// store the additional arguments
	
	ShowPlayerDialog(playerid, DIALOG_CONFIRM_SYS, DIALOG_STYLE_MSGBOX, caption, info, "Yes", "No"); // display the dialog message itself
	
	return;
} // Credits to Mmartin (SA-MP forums)

stock ConfirmDialog_Response(playerid, response)
{
	new szCallback[33],		// variable to fetch our callback to
		szParamHash[64], 	// variable to check raw compressed argument string
		n,					// variable to fetch the amount of additional arguments
		szForm[12];			// variable to generate the CallLocalFunction() "format" argument
		
	n = GetPVarInt(playerid, "confDialogArgs");	// Fetch the amount of additional arguments
	GetPVarString(playerid, "confDialCallback", szCallback, sizeof(szCallback));	// fetch the callback
	GetPVarString(playerid, "confDialog_arg", szParamHash, sizeof(szParamHash));	// fetch the raw compressed additional arguments
	
	new hashDecoded[12];	// variable to store extracted additional arguments from the ConfirmDialog() generated string
	
	sscanf(szParamHash, "p<|>A<d>(0)[12]", hashDecoded);	// extraction of the additional arguments
	
	new args, 	// amount of cells passed to CallLocalFunction
		addr, 	// pointer address variable for later use
		i;		// i
		
	format(szForm, sizeof(szForm), "dd");	// static parameters for the callback, "playerid" and "response"
	
	#emit ADDR.pri hashDecoded	// get pointer address of the extracted additional arguments
	#emit STOR.S.pri addr		// store the pointer address in variable 'addr'
	if(n){	// if there's any additional arguments
		for(i = addr + ((n-1) * 4); i >= addr; i-=4){ // loops all additional arguments by their addresses
			format(szForm, sizeof(szForm), "%sd", szForm); // adds an aditional specifier to the "format" parameter of CallLocalFunction
			#emit load.s.pri i	// load the argument at the current address
			#emit push.pri		// push it to the CallLocalFunction argument list
			args+=4;			// increase used cell number by 4
		}
	}
	
	
	args+=16;	// preserve 4 more arguments for CallLocalFunction (16 cause 4 args by 4 cells (4*4))
	
	#emit ADDR.pri response				// fetch "response" pointer address to the primary buffer
	#emit push.pri						// push it to the argument list
	
	#emit ADDR.pri playerid				// fetch "playerid" pointer address to the primary buffer
	#emit push.pri						// push it to the argument list
	
	#emit push.adr szForm				// push the szForm ("format") to the argument list by its referenced address
	#emit push.adr szCallback			// push the szCallback (custom callback) to the argument list by its referenced address
	#emit push.s args					// push the amount of arguments
	#emit sysreq.c CallLocalFunction	// call the function
	
	// Clear used data
	#emit LCTRL 4
	#emit LOAD.S.ALT args
	#emit ADD.C 4
	#emit ADD
	#emit SCTRL 4
	
	// Clear used PVars
	DeletePVar(playerid, "confDialCallback");
	DeletePVar(playerid, "confDialog_arg");
	DeletePVar(playerid, "confDialogArgs");
	
	return;
} // Credits to Mmartin (SA-MP forums)

stock PlayNearbySound(playerid, sound)
{
	new
	    Float:x,
	    Float:y,
	    Float:z;

	GetPlayerPos(playerid, x, y, z);

	foreach (new i : Player) if (IsPlayerInRangeOfPoint(i, 15.0, x, y, z)) {
	    PlayerPlaySound(i, sound, x, y, z);
	}
	return 1;
}

stock SaveFactions()
{
	for (new i = 1; i < MAX_FACTIONS; i ++)
	{
		if(FactionInfo[i][eFactionDBID])
		{
			SaveFaction(i);
		}
	}
	return 1;
}

stock SaveProperties()
{
	for(new i = 1; i < MAX_PROPERTY; i++)
	{
		if(!PropertyInfo[i][ePropertyDBID])
			continue;
			
		SaveProperty(i); 
	}
	return 1;
}

stock SaveBusinesses()
{
	for(new i = 1; i < MAX_BUSINESS; i++)
	{
		if(!BusinessInfo[i][eBusinessDBID])
			continue;
			
		SaveBusiness(i);
	}
	return 1;
}

stock SaveFaction(id)
{
	if(!FactionInfo[id][eFactionDBID])
		return 0;
		
	new threadSave[256];
	
	mysql_format(this, threadSave, sizeof(threadSave), "UPDATE factions SET FactionName = '%e', FactionAbbrev = '%e', FactionJoinRank = %i, FactionAlterRank = %i, FactionChatRank = %i, FactionTowRank = %i, FactionType = %i, FactionChatColor = %i WHERE DBID = %i",
		FactionInfo[id][eFactionName],
		FactionInfo[id][eFactionAbbrev],
		FactionInfo[id][eFactionJoinRank],
		FactionInfo[id][eFactionAlterRank],
		FactionInfo[id][eFactionChatRank],
		FactionInfo[id][eFactionTowRank],
		FactionInfo[id][eFactionType],
		FactionInfo[id][eFactionChatColor],
		FactionInfo[id][eFactionDBID]);
	mysql_tquery(this, threadSave);
	
	mysql_format(this, threadSave, sizeof(threadSave), "UPDATE factions SET FactionSpawnX = %f, FactionSpawnY = %f, FactionSpawnZ = %f, FactionInterior = %i, FactionWorld = %i WHERE DBID = %i",
		FactionInfo[id][eFactionSpawn][0],
		FactionInfo[id][eFactionSpawn][1],
		FactionInfo[id][eFactionSpawn][2],
		FactionInfo[id][eFactionSpawnInt],
		FactionInfo[id][eFactionSpawnWorld],
		FactionInfo[id][eFactionDBID]);
	mysql_tquery(this, threadSave);
	return 1;
}

stock SaveFactionRanks(id)
{
	if(!FactionInfo[id][eFactionDBID])
		return 0;
		
	new threadSave[256];
	
	for(new i = 1; i < MAX_FACTION_RANKS; i++)
	{
		mysql_format(this, threadSave, sizeof(threadSave), "UPDATE faction_ranks SET FactionRank%i = %i WHERE factionid = %i", i, FactionRanks[id][i], FactionInfo[id][eFactionDBID]);
		mysql_tquery(this, threadSave);
	}
	
	return 1;
}

stock SaveVehicle(vehicleid)
{

	new Float: current_health, panels, doors, lights, tires;
	GetVehicleHealth(vehicleid, current_health);
    GetVehicleDamageStatus(vehicleid, panels, doors, lights, tires);
	VehicleInfo[vehicleid][eVehicleDamage][0] = panels;
	VehicleInfo[vehicleid][eVehicleDamage][1] = doors;
	VehicleInfo[vehicleid][eVehicleDamage][2] = lights;
    VehicleInfo[vehicleid][eVehicleDamage][3] = tires;

	switch(VehicleInfo[vehicleid][eVehicleInsurance])
	{
	    case 1:
	    {
			if(current_health <= 380.0)
			{
				if(VehicleInfo[vehicleid][eVehicleInsurance] != 0)
				{
				    VehicleInfo[vehicleid][eVehicleInsBill] += floatround(g_aDealershipData[GetVehicleModel(vehicleid)][eDealershipPrice] * 0.09);
				    if(VehicleInfo[vehicleid][eVehicleInsTime] <= 0) VehicleInfo[vehicleid][eVehicleInsTime] = 24;
				}
			}
	        VehicleInfo[vehicleid][eVehicleHealth] = getVehicleCondition(vehicleid, 0);
			VehicleInfo[vehicleid][eVehicleDamage][0] = panels;
			VehicleInfo[vehicleid][eVehicleDamage][1] = doors;
			VehicleInfo[vehicleid][eVehicleDamage][2] = lights;
			VehicleInfo[vehicleid][eVehicleDamage][3] = tires;
	    }
		case 2:
		{
			if(current_health <= 380.0)
			{
				if(VehicleInfo[vehicleid][eVehicleInsurance] != 0)
				{
				    VehicleInfo[vehicleid][eVehicleInsBill] += floatround(g_aDealershipData[GetVehicleModel(vehicleid)][eDealershipPrice] * 0.09);
				    if(VehicleInfo[vehicleid][eVehicleInsTime] <= 0) VehicleInfo[vehicleid][eVehicleInsTime] = 24;
				}
			}
		    VehicleInfo[vehicleid][eVehicleHealth] = getVehicleCondition(vehicleid, 0);
			VehicleInfo[vehicleid][eVehicleDamage][0] = 0;
			VehicleInfo[vehicleid][eVehicleDamage][1] = 0;
			VehicleInfo[vehicleid][eVehicleDamage][2] = 0;
			VehicleInfo[vehicleid][eVehicleDamage][3] = 0;
		}
		case 3:
		{
			if(current_health <= 380.0)
			{
				if(VehicleInfo[vehicleid][eVehicleInsurance] != 0)
				{
				    VehicleInfo[vehicleid][eVehicleInsBill] += floatround(g_aDealershipData[GetVehicleModel(vehicleid)][eDealershipPrice] * 0.09);
				    if(VehicleInfo[vehicleid][eVehicleInsTime] <= 0) VehicleInfo[vehicleid][eVehicleInsTime] = 24;
				}
			}
		    VehicleInfo[vehicleid][eVehicleHealth] = getVehicleCondition(vehicleid, 0);
			VehicleInfo[vehicleid][eVehicleDamage][0] = 0;
			VehicleInfo[vehicleid][eVehicleDamage][1] = 0;
			VehicleInfo[vehicleid][eVehicleDamage][2] = 0;
			VehicleInfo[vehicleid][eVehicleDamage][3] = 0;
		}
		default:
		{
			if(current_health <= 380.0)
			{
				VehicleInfo[vehicleid][eVehicleHealth] = 380.0;
				VehicleInfo[vehicleid][eVehicleDamage][0] = panels;
				VehicleInfo[vehicleid][eVehicleDamage][1] = doors;
				VehicleInfo[vehicleid][eVehicleDamage][2] = lights;
				VehicleInfo[vehicleid][eVehicleDamage][3] = tires;
			}
			else
			{
				VehicleInfo[vehicleid][eVehicleDamage][0] = panels;
				VehicleInfo[vehicleid][eVehicleDamage][1] = doors;
				VehicleInfo[vehicleid][eVehicleDamage][2] = lights;
				VehicleInfo[vehicleid][eVehicleDamage][3] = tires;
			}
		}
	}
	
	new query[256];
	mysql_format(this, query, sizeof(query), "UPDATE vehicles SET VehicleOwnerDBID = %i, VehicleFaction = %i, VehicleColor1 = %i, VehicleColor2 = %i, VehiclePaintjob = %i, VehiclePlates = '%e', VehicleLocked = %i, VehicleSirens = %i, VehicleFuel = %f WHERE VehicleDBID = %i",
		VehicleInfo[vehicleid][eVehicleOwnerDBID], 
		VehicleInfo[vehicleid][eVehicleFaction],
		VehicleInfo[vehicleid][eVehicleColor1],
		VehicleInfo[vehicleid][eVehicleColor2],
		VehicleInfo[vehicleid][eVehiclePaintjob],
		VehicleInfo[vehicleid][eVehiclePlates],
		VehicleInfo[vehicleid][eVehicleLocked],
		VehicleInfo[vehicleid][eVehicleSirens],
		VehicleInfo[vehicleid][eVehicleFuel],
		VehicleInfo[vehicleid][eVehicleDBID]);
	mysql_tquery(this, query);
	
	mysql_format(this, query, sizeof(query), "UPDATE vehicles SET VehicleHealth = %f, Insurance = %i, VehicleXMR = %i, VehicleBattery = %f, VehicleEngine = %f, VehicleTimesDestroyed = %i WHERE VehicleDBID = %i",
        VehicleInfo[vehicleid][eVehicleHealth],
	    VehicleInfo[vehicleid][eVehicleInsurance],
		VehicleInfo[vehicleid][eVehicleHasXMR],
		VehicleInfo[vehicleid][eVehicleBattery],
		VehicleInfo[vehicleid][eVehicleEngine],
		VehicleInfo[vehicleid][eVehicleTimesDestroyed],
		VehicleInfo[vehicleid][eVehicleDBID]);
	mysql_tquery(this, query);
	
	mysql_format(this, query, sizeof(query), "UPDATE vehicles SET VehicleParkPosX = %f, VehicleParkPosY = %f, VehicleParkPosZ = %f, VehicleParkPosA = %f, VehicleParkInterior = %i, VehicleParkWorld = %i WHERE VehicleDBID = %i",
		VehicleInfo[vehicleid][eVehicleParkPos][0],
		VehicleInfo[vehicleid][eVehicleParkPos][1], 
		VehicleInfo[vehicleid][eVehicleParkPos][2],
		VehicleInfo[vehicleid][eVehicleParkPos][3],
		VehicleInfo[vehicleid][eVehicleParkInterior],
		VehicleInfo[vehicleid][eVehicleParkWorld],
		VehicleInfo[vehicleid][eVehicleDBID]);
	mysql_tquery(this, query);
	
	mysql_format(this, query, sizeof(query), "UPDATE vehicles SET VehicleImpounded = %i, VehicleImpoundPosX = %f, VehicleImpoundPosY = %f, VehicleImpoundPosZ = %f, VehicleImpoundPosA = %f WHERE VehicleDBID = %i",
		VehicleInfo[vehicleid][eVehicleImpounded],
		VehicleInfo[vehicleid][eVehicleImpoundPos][0],
		VehicleInfo[vehicleid][eVehicleImpoundPos][1],
		VehicleInfo[vehicleid][eVehicleImpoundPos][2],
		VehicleInfo[vehicleid][eVehicleImpoundPos][3],
		VehicleInfo[vehicleid][eVehicleDBID]);
	mysql_tquery(this, query);

	mysql_format(this, query, sizeof(query), "UPDATE vehicles SET VehicleStolen = %i, VehicleStolenPosX = %f, VehicleStolenPosY = %f, VehicleStolenPosZ = %f, VehicleStolenPosA = %f WHERE VehicleDBID = %i",
		VehicleInfo[vehicleid][eVehicleStolen],
		VehicleInfo[vehicleid][eVehicleStolenPos][0],
		VehicleInfo[vehicleid][eVehicleStolenPos][1],
		VehicleInfo[vehicleid][eVehicleStolenPos][2],
		VehicleInfo[vehicleid][eVehicleStolenPos][3],
		VehicleInfo[vehicleid][eVehicleDBID]);
	mysql_tquery(this, query);

	mysql_format(this, query, sizeof(query), "UPDATE vehicles SET InsTime = %i, InsBill = %i, Mileage = %f WHERE VehicleDBID = %i",
		VehicleInfo[vehicleid][eVehicleInsBill],
        VehicleInfo[vehicleid][eVehicleInsTime],
        VehicleInfo[vehicleid][eMileage],
		VehicleInfo[vehicleid][eVehicleDBID]);
	mysql_tquery(this, query);

	for(new j = 1; j < 5; j++)
	{
		mysql_format(this, query, sizeof(query), "UPDATE vehicles SET VehicleLastDrivers%d = %i, VehicleLastPassengers%d = %i WHERE VehicleDBID = %i",
			j,
			VehicleInfo[vehicleid][eVehicleLastDrivers][j],
			j,
			VehicleInfo[vehicleid][eVehicleLastPassengers][j],
			VehicleInfo[vehicleid][eVehicleDBID]);
		mysql_tquery(this, query);
			
	}
	
	for(new list_damage = 0; list_damage < MAX_VEH_PART; list_damage++)
	{
		mysql_format(this, query, sizeof(query), "UPDATE vehicles SET DamageStatus%d = %i, WHERE VehicleDBID = %i",
			list_damage,
			VehicleInfo[vehicleid][eVehicleDamage][list_damage],
			VehicleInfo[vehicleid][eVehicleDBID]);
		mysql_tquery(this, query);
	}
	
	return 1;
}

stock SaveProperty(id)
{
	new query[256]; 
	
	mysql_format(this, query, sizeof(query), "UPDATE properties SET PropertyOwnerDBID = %i, PropertyAlarm = %i, PropertyType = %i, PropertyFaction = %i, PropertyLocked = %i, PropertyCashbox = %i, PropertyLevel = %i, PropertyMarketPrice = %i, PropertyHasBoombox = %i WHERE PropertyDBID = %i",
		PropertyInfo[id][ePropertyOwnerDBID], 
        PropertyInfo[id][ePropertyAlarm],
		PropertyInfo[id][ePropertyType],
		PropertyInfo[id][ePropertyFaction],
		PropertyInfo[id][ePropertyLocked],
		PropertyInfo[id][ePropertyCashbox],
		PropertyInfo[id][ePropertyLevel],
		PropertyInfo[id][ePropertyMarketPrice],
		PropertyInfo[id][ePropertyHasBoombox],
		PropertyInfo[id][ePropertyDBID]);
	mysql_tquery(this, query);
	
	mysql_format(this, query, sizeof(query), "UPDATE properties SET PropertyEntranceX = %f, PropertyEntranceY = %f, PropertyEntranceZ = %f, PropertyEntranceInterior = %i, PropertyEntranceWorld = %i WHERE PropertyDBID = %i",
		PropertyInfo[id][ePropertyEntrance][0],
		PropertyInfo[id][ePropertyEntrance][1],
		PropertyInfo[id][ePropertyEntrance][2],
		PropertyInfo[id][ePropertyEntranceInterior],
		PropertyInfo[id][ePropertyEntranceWorld],
		PropertyInfo[id][ePropertyDBID]);
	mysql_tquery(this, query);
	 
	mysql_format(this, query, sizeof(query), "UPDATE properties SET PropertyInteriorX = %f, PropertyInteriorY = %f, PropertyInteriorZ = %f, PropertyInteriorIntID = %i, PropertyInteriorWorld = %i WHERE PropertyDBID = %i",
		PropertyInfo[id][ePropertyInterior][0],
		PropertyInfo[id][ePropertyInterior][1],
		PropertyInfo[id][ePropertyInterior][2],
		PropertyInfo[id][ePropertyInteriorIntID],
		PropertyInfo[id][ePropertyInteriorWorld],
		PropertyInfo[id][ePropertyDBID]);
	mysql_tquery(this, query);
	
	mysql_format(this, query, sizeof(query), "UPDATE properties SET PropertyPlacePosX = %f, PropertyPlacePosY = %f, PropertyPlacePosZ = %f, PropertyRentFee = %i, PropertyRentAble = %i WHERE PropertyDBID = %i",
		PropertyInfo[id][ePropertyPlacePos][0],
		PropertyInfo[id][ePropertyPlacePos][1],
		PropertyInfo[id][ePropertyPlacePos][2],
		PropertyInfo[id][ePropertyRentFee],
		PropertyInfo[id][ePropertyRentAble],
  
		PropertyInfo[id][ePropertyDBID]);
	mysql_tquery(this, query);
	
	return 1;
}

stock SaveBusiness(id)
{
	new query[400];
	
	mysql_format(this, query, sizeof(query), "UPDATE businesses SET BusinessOwnerDBID = %i, BusinessName = '%e', BusinessType = %i, BusinessLocked = %i, BusinessEntranceFee = %i, BusinessLevel = %i, BusinessCashbox = %i, BusinessProducts = %i, BusinessMarketPrice = %i WHERE BusinessDBID = %i",
		BusinessInfo[id][eBusinessOwnerDBID],
		BusinessInfo[id][eBusinessName],
		BusinessInfo[id][eBusinessType],
		BusinessInfo[id][eBusinessLocked], 
		BusinessInfo[id][eBusinessEntranceFee],
		BusinessInfo[id][eBusinessLevel],
		BusinessInfo[id][eBusinessCashbox],
		BusinessInfo[id][eBusinessProducts],
		BusinessInfo[id][eBusinessMarketPrice],
		BusinessInfo[id][eBusinessDBID]);
	mysql_tquery(this, query);
	
	mysql_format(this, query, sizeof(query), "UPDATE businesses SET BusinessInteriorX = %f, BusinessInteriorY = %f, BusinessInteriorZ = %f, BusinessInteriorWorld = %i, BusinessInteriorIntID = %i WHERE BusinessDBID = %i",
		BusinessInfo[id][eBusinessInterior][0],
		BusinessInfo[id][eBusinessInterior][1],
		BusinessInfo[id][eBusinessInterior][2],
		BusinessInfo[id][eBusinessInteriorWorld],
		BusinessInfo[id][eBusinessInteriorIntID],
		BusinessInfo[id][eBusinessDBID]);
	mysql_tquery(this, query);
	
	mysql_format(this, query, sizeof(query), "UPDATE businesses SET BusinessEntranceX = %f, BusinessEntranceY = %f, BusinessEntranceZ = %f WHERE BusinessDBID = %i",
		BusinessInfo[id][eBusinessEntrance][0],
		BusinessInfo[id][eBusinessEntrance][1],
		BusinessInfo[id][eBusinessEntrance][2],
		BusinessInfo[id][eBusinessDBID]);
	mysql_tquery(this, query);
	
	mysql_format(this, query, sizeof(query), "UPDATE businesses SET BusinessBankPickupLocX = %f, BusinessBankPickupLocY = %f, BusinessBankPickupLocZ = %f, BusinessBankPickupWorld = %i WHERE BusinessDBID = %i",
		BusinessInfo[id][eBusinessBankPickupLoc][0],
		BusinessInfo[id][eBusinessBankPickupLoc][1],
		BusinessInfo[id][eBusinessBankPickupLoc][2],
		BusinessInfo[id][eBusinessBankPickupWorld],
		BusinessInfo[id][eBusinessDBID]);
	mysql_tquery(this, query);
	
	mysql_format(this, query, sizeof(query), "UPDATE businesses SET RType = %i, Food1 = %i, Food2 = %i, Food3 = %i, Price1 = %i, Price2 = %i, Price3 = %i WHERE BusinessDBID = %i",
        BusinessInfo[id][eBusinessRestaurantType],
        BusinessInfo[id][eBusinessFood][0],
        BusinessInfo[id][eBusinessFood][1],
        BusinessInfo[id][eBusinessFood][2],
        BusinessInfo[id][eBusinessFoodPrice][0],
        BusinessInfo[id][eBusinessFoodPrice][1],
        BusinessInfo[id][eBusinessFoodPrice][2],
		BusinessInfo[id][eBusinessDBID]);
	mysql_tquery(this, query);

	return 1;
}

stock ReturnTotalMembers(factionid)
{
	if(factionid == 0 || !FactionInfo[factionid][eFactionDBID])
		return 0; 
		
	new threadCheck[128], counter;
	
	mysql_format(this, threadCheck, sizeof(threadCheck), "SELECT COUNT(*) FROM characters WHERE pFaction = %i", factionid);
	mysql_query(this, threadCheck);
	
	counter = cache_get_row_int(0, 0);
	return counter;
}

stock ReturnOnlineMembers(factionid)
{
	new counter;
		
	foreach(new i : Player)
	{
		if(e_pAccountData[i][mLoggedin] == false)
			continue;
		
		if(PlayerInfo[i][pFaction] == factionid)
		{
			counter++;
		}
	}
	return counter;
}

stock ReturnFactionName(playerid)
{
	new factionName[90];
	
	if(!PlayerInfo[playerid][pFaction])
		factionName = "Civilian";
		
	else
		format(factionName, sizeof(factionName), "%s", FactionInfo[PlayerInfo[playerid][pFaction]][eFactionName]);
		
	return factionName;
}

stock ReturnFactionNameEx(factionid)
{
	new factionName[90];
	
	format(factionName, sizeof(factionName), "%s", FactionInfo[factionid][eFactionName]);
	return factionName;
}

stock ReturnFactionAbbrev(factionid)
{		
	 new facAbbrev[90];
	 
	 format(facAbbrev, sizeof(facAbbrev), "%s", FactionInfo[factionid][eFactionAbbrev]);
	 return facAbbrev; 
}

stock ReturnFactionRank(playerid)
{
	new rankStr[90]; 
	
	if(!PlayerInfo[playerid][pFaction])
	{
		rankStr = "No Rank";
	}
	else
	{
		new 
			factionid = PlayerInfo[playerid][pFaction],
			rank = PlayerInfo[playerid][pFactionRank];
			
		format(rankStr, sizeof(rankStr), "%s", FactionRanks[factionid][rank]);
	}
	return rankStr;
}

stock ReturnFactionType(playerid)
{
	if(!PlayerInfo[playerid][pFaction])
		return 0;
	
	return FactionInfo[PlayerInfo[playerid][pFaction]][eFactionType];
}

static stock g_arrVehicleNames[][] = {
    "Landstalker", "Bravura", "Buffalo", "Linerunner", "Perrenial", "Sentinel", "Dumper", "Firetruck", "Trashmaster",
    "Stretch", "Manana", "Infernus", "Voodoo", "Pony", "Mule", "Cheetah", "Ambulance", "Leviathan", "Moonbeam",
    "Esperanto", "Taxi", "Washington", "Bobcat", "Whoopee", "BF Injection", "Hunter", "Premier", "Enforcer",
    "Securicar", "Banshee", "Predator", "Bus", "Rhino", "Barracks", "Hotknife", "Trailer", "Previon", "Coach",
    "Cabbie", "Stallion", "Rumpo", "RC Bandit", "Romero", "Packer", "Monster", "Admiral", "Squalo", "Seasparrow",
    "Pizzaboy", "Tram", "Trailer", "Turismo", "Speeder", "Reefer", "Tropic", "Flatbed", "Yankee", "Caddy", "Solair",
    "Berkley's RC Van", "Skimmer", "PCJ-600", "Faggio", "Freeway", "RC Baron", "RC Raider", "Glendale", "Oceanic",
    "Sanchez", "Sparrow", "Patriot", "Quad", "Coastguard", "Dinghy", "Hermes", "Sabre", "Rustler", "ZR-350", "Walton",
    "Regina", "Comet", "BMX", "Burrito", "Camper", "Marquis", "Baggage", "Dozer", "Maverick", "News Chopper", "Rancher",
    "FBI Rancher", "Virgo", "Greenwood", "Jetmax", "Hotring", "Sandking", "Blista Compact", "Police Maverick",
    "Boxville", "Benson", "Mesa", "RC Goblin", "Hotring Racer A", "Hotring Racer B", "Bloodring Banger", "Rancher",
    "Super GT", "Elegant", "Journey", "Bike", "Mountain Bike", "Beagle", "Cropduster", "Stunt", "Tanker", "Roadtrain",
    "Nebula", "Majestic", "Buccaneer", "Shamal", "Hydra", "FCR-900", "NRG-500", "HPV1000", "Cement Truck", "Tow Truck",
    "Fortune", "Cadrona", "SWAT Truck", "Willard", "Forklift", "Tractor", "Combine", "Feltzer", "Remington", "Slamvan",
    "Blade", "Streak", "Freight", "Vortex", "Vincent", "Bullet", "Clover", "Sadler", "Firetruck", "Hustler", "Intruder",
    "Primo", "Cargobob", "Tampa", "Sunrise", "Merit", "Utility", "Nevada", "Yosemite", "Windsor", "Monster", "Monster",
    "Uranus", "Jester", "Sultan", "Stratum", "Elegy", "Raindance", "RC Tiger", "Flash", "Tahoma", "Savanna", "Bandito",
    "Freight Flat", "Streak Carriage", "Kart", "Mower", "Dune", "Sweeper", "Broadway", "Tornado", "AT-400", "DFT-30",
    "Huntley", "Stafford", "BF-400", "News Van", "Tug", "Trailer", "Emperor", "Wayfarer", "Euros", "Hotdog", "Club",
    "Freight Box", "Trailer", "Andromada", "Dodo", "RC Cam", "Launch", "LSPD Cruiser", "SFPD Cruiser", "LVPD Cruiser",
    "Police Rancher", "Picador", "S.W.A.T", "Alpha", "Phoenix", "Glendale", "Sadler", "Luggage", "Luggage", "Stairs",
    "Boxville", "Tiller", "Utility Trailer"
};

stock ReturnVehicleName(vehicleid)
{
	new
		model = GetVehicleModel(vehicleid),
		name[32] = "None";

    if (model < 400 || model > 611)
	    return name;

	format(name, sizeof(name), g_arrVehicleNames[model - 400]);
	return name;
}

stock ReturnVehicleModelName(model)
{
	new
	    name[32] = "None";

    if (model < 400 || model > 611)
	    return name;

	format(name, sizeof(name), g_arrVehicleNames[model - 400]);
	return name;
}

stock ResetVehicleVars(vehicleid)
{
	if(vehicleid == INVALID_VEHICLE_ID)
		return 0;
		
	VehicleInfo[vehicleid][eVehicleDBID] = 0; 
	VehicleInfo[vehicleid][eVehicleExists] = false;
	
	VehicleInfo[vehicleid][eVehicleOwnerDBID] = 0;
	VehicleInfo[vehicleid][eVehicleFaction] = 0;
	
	VehicleInfo[vehicleid][eVehicleImpounded] = false;
	VehicleInfo[vehicleid][eVehicleStolen] = false;
	
	VehicleInfo[vehicleid][eVehiclePaintjob] = -1; 
	
	VehicleInfo[vehicleid][eVehicleFuel] = 100.0;
	
	for(new i = 1; i < 5; i++)
	{
		VehicleInfo[vehicleid][eVehicleLastDrivers][i] = 0;
		VehicleInfo[vehicleid][eVehicleLastPassengers][i] = 0;
	}
	
	VehicleInfo[vehicleid][eVehicleTowCount] = 0;
	
	VehicleInfo[vehicleid][eVehicleHasXMR] = false;
	VehicleInfo[vehicleid][eVehicleBattery] = 100.0;
	VehicleInfo[vehicleid][eVehicleEngine] = 100.0;
	VehicleInfo[vehicleid][eVehicleTimesDestroyed] = 0;
	
	VehicleInfo[vehicleid][eVehicleEngineStatus] = false;
	VehicleInfo[vehicleid][eVehicleLights] = false;
	
	for(new j; j < 14; j++)
	    VehicleInfo[vehicleid][eVehicleMods][j] = 0;
	
	for(new x; x < MAX_WEP_SLOT; x++)
	{
		vehicle_trunk_data[vehicleid][x][is_exist] = false;
		if(IsValidDynamicObject(vehicle_trunk_data[vehicleid][x][temp_object])) DestroyDynamicObject(vehicle_trunk_data[vehicleid][x][temp_object]);
	}
	
	if(IsValidDynamic3DTextLabel(VehicleInfo[vehicleid][eVehicleLabel])) DestroyDynamic3DTextLabel(VehicleInfo[vehicleid][eVehicleLabel]);
	return 1;
}

stock ToggleVehicleAlarms(vehicleid, bool:alarmstate, time = 5000)
{
	new engine, lights, alarm, doors, bonnet, boot, objective;
 
	GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
	SetVehicleParamsEx(vehicleid, engine, lights, alarmstate, doors, bonnet, boot, alarmstate);
	
	if(alarmstate) SetTimerEx("OnVehicleAlarm", time, false, "i", vehicleid);
	return 1;
}

stock ToggleVehicleEngine(vehicleid, bool:enginestate)
{
	new engine, lights, alarm, doors, bonnet, boot, objective;

	GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
	SetVehicleParamsEx(vehicleid, enginestate, lights, alarm, doors, bonnet, boot, objective);
	return 1;
}

stock ToggleVehicleLights(vehicleid, bool:lightstate)
{
	new engine, lights, alarm, doors, bonnet, boot, objective;

	GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
	SetVehicleParamsEx(vehicleid, engine, lightstate, alarm, doors, bonnet, boot, objective);
	
	VehicleInfo[vehicleid][eVehicleLights] = lightstate;
	return 1;
}

stock GiveMoney(playerid, amount)
{
	PlayerInfo[playerid][pMoney] += amount;
	GivePlayerMoney(playerid, amount);
	
	new string[128]; 
	
	if(amount < 0) {
		format(string, sizeof(string), "~r~$%d", amount);
		GameTextForPlayer(playerid, string, 2000, 1);
	}
	else{
		format(string, sizeof(string), "~g~$%d", amount);
		GameTextForPlayer(playerid, string, 2000, 1);
	}
	return 1;
}

stock IsVehicleOccupied(vehicleid)
{
	foreach(new i : Player){
		if(IsPlayerInVehicle(i, vehicleid))return true; 
	}
	return false;
}

stock PlayerHasWeapons(playerid)
{
	new countWeapons = 0;
	
	for(new i = 0; i < 4; i ++)
	{
		if(PlayerInfo[playerid][pWeapons][i] != 0)
			countWeapons++;
	}
	if(countWeapons == 0)
		return 0;
		
	if(countWeapons > 0)
		return 1;
		
	return 1;
}

stock PlayerHasWeapon(playerid, weaponid)
{
	if(PlayerInfo[playerid][pWeapons][ReturnWeaponIDSlot(weaponid)] != weaponid)
		return 0;

	return 1;
}

stock ReturnWeaponIDSlot(weaponid)
{
	new returnID; 
	
	switch(weaponid)
	{
		case 1 .. 10: returnID = 0;
		case 11 .. 18, 41, 43: returnID = 1;
		case 22 .. 24: returnID = 2;
		case 25, 27 .. 34: returnID = 3;
	}
	return returnID;
}

stock WeaponDataSlot(weaponid)
{
	new slot;
	
	switch (weaponid)
	{
		case 1: slot = 0;
		case 2 .. 9: slot = 1; 
		case 10 .. 15: slot = 10; 
		case 16 .. 18: slot = 8;
		case 41, 43: slot = 9; 
		case 24: slot = 2;
		case 25: slot = 3;
		case 28, 29, 32: slot = 4;
		case 30, 31: slot = 5;
		case 33, 34: slot = 6; 
	}
	return slot;
}

stock RemovePlayerWeapon(playerid, weaponid)
{
	if(!IsPlayerConnected(playerid) || weaponid < 0 || weaponid > 50)
	    return;
	new saveweapon[13], saveammo[13];
	for(new slot = 0; slot < 13; slot++)
	    GetPlayerWeaponData(playerid, slot, saveweapon[slot], saveammo[slot]);
	ResetPlayerWeapons(playerid);
	for(new slot; slot < 13; slot++)
	{
		if(saveweapon[slot] == weaponid || saveammo[slot] == 0)
			continue;
		GivePlayerWeapon(playerid, saveweapon[slot], saveammo[slot]);
	}

	GivePlayerWeapon(playerid, 0, 1);
}

stock ReturnWeaponName(weaponid)
{
	new weapon[22];
    switch(weaponid)
    {
        case 0: weapon = "Fists";
        case 18: weapon = "Molotov Cocktail";
        case 44: weapon = "Night Vision Goggles";
        case 45: weapon = "Thermal Goggles";
		case 54: weapon = "Fall";
        default: GetWeaponName(weaponid, weapon, sizeof(weapon));
    }
    return weapon;
}

stock ReturnWeaponType(id)
{
	new weapon[22];
    switch(id)
    {
        case 0 .. 24: weapon = "Melee Weapon";
        default: weapon = "Heavy Weapon";
    }
    return weapon;
}

stock ShowFactionConfig(playerid)
{
	new rankCount, infoString[128], showString[256]; 
	
	format(infoString, sizeof(infoString), "Name: %s\n", ReturnFactionName(playerid));
	strcat(showString, infoString); 
	
	format(infoString, sizeof(infoString), "Abbreviation: %s\n", ReturnFactionAbbrev(PlayerInfo[playerid][pFaction]));
	strcat(showString, infoString);
	
	format(infoString, sizeof(infoString), "Alter Rank: %d\n", FactionInfo[PlayerInfo[playerid][pFaction]][eFactionAlterRank]);
	strcat(showString, infoString);
	
	format(infoString, sizeof(infoString), "Join Rank: %d\n", FactionInfo[PlayerInfo[playerid][pFaction]][eFactionJoinRank]);
	strcat(showString, infoString);
	
	format(infoString, sizeof(infoString), "Chat Rank: %d\n", FactionInfo[PlayerInfo[playerid][pFaction]][eFactionChatRank]);
	strcat(showString, infoString);
	
	format(infoString, sizeof(infoString), "Chat Color\n", FactionInfo[PlayerInfo[playerid][pFaction]][eFactionChatColor]);
	strcat(showString, infoString);
	
	for(new i = 1; i < MAX_FACTION_RANKS; i++)
	{
		if(!strcmp(FactionRanks[PlayerInfo[playerid][pFaction]][i], "NotSet"))
			continue;
			
		rankCount++;
	}
	
	format(infoString, sizeof(infoString), "Faction Ranks (%i)\n", rankCount);
	strcat(showString, infoString);
	
	strcat(showString, "Faction Spawn\n"); 
	
	format(infoString, sizeof(infoString), "Tow Rank: %d\n", FactionInfo[PlayerInfo[playerid][pFaction]][eFactionTowRank]);
	strcat(showString, infoString);
	
	ShowPlayerDialog(playerid, DIALOG_FACTION_CONFIG, DIALOG_STYLE_LIST, "{ADC3E7}Faction Configuration", showString, "Select", "<<");
	return 1;
}

stock HexToInt(string[])
{
    if(!string[0]) return 0;
    new cur = 1, res = 0;
    for(new i = strlen(string); i > 0; i--)
    {
        res += cur * (string[i - 1] - ((string[i - 1] < 58) ? (48) : (55)));
        cur = cur * 16;
    }
    return res;
}

stock ShowUnscrambleTextdraw(playerid, bool:showTextdraw = true)
{
	if(showTextdraw)
	{
		for(new i = 0; i < 7; i++)
		{
			PlayerTextDrawShow(playerid, Unscrambler_PTD[playerid][i]);
		}
	}
	else
	{
		for(new i = 0; i < 7; i++)
		{
			PlayerTextDrawHide(playerid, Unscrambler_PTD[playerid][i]);
		}
	}
	return 1;
}

stock ShowPlayerWeapons(playerid, slotid)
{
	new returnStr[60];
	
	switch(slotid)
	{
		case 1:
		{
			new str_1slot[60];
			
			if(!PlayerInfo[playerid][pWeapons][0])
				str_1slot = "None"; 
				
			else
				format(str_1slot, 60, "%s", ReturnWeaponName(PlayerInfo[playerid][pWeapons][0]));
				
			returnStr = str_1slot;
		}
		case 2:
		{
			new str_2slot[60];
			
			if(!PlayerInfo[playerid][pWeapons][1])
				str_2slot = "None"; 
				
			else
				format(str_2slot, 60, "%s", ReturnWeaponName(PlayerInfo[playerid][pWeapons][1]));
				
			returnStr = str_2slot;
		}
		case 3:
		{
			new str_3slot[60];
			
			if(!PlayerInfo[playerid][pWeapons][2])
				str_3slot = "None"; 
				
			else
				format(str_3slot, 60, "%s", ReturnWeaponName(PlayerInfo[playerid][pWeapons][2]));
				
			returnStr = str_3slot;
		}
		case 4:
		{
			new str_4slot[60];
			
			if(!PlayerInfo[playerid][pWeapons][3])
				str_4slot = "None"; 
				
			else
				format(str_4slot, 60, "%s", ReturnWeaponName(PlayerInfo[playerid][pWeapons][3]));
				
			returnStr = str_4slot;
		}
	}
	return returnStr;
}

stock ReturnDBIDName(dbid)
{
	new query[120], returnString[60];
	
	mysql_format(this, query, sizeof(query), "SELECT char_name FROM characters WHERE char_dbid = %i", dbid);
	new Cache:cache = mysql_query(this, query);
	
	if(!cache_num_rows())
		returnString = "None";
		
	else
		cache_get_field_content(0, "char_name", returnString);
	
	cache_delete(cache);
	return returnString;
}

stock NotifyVehicleOwner(vehicleid)
{
	new playerid = INVALID_PLAYER_ID;

	foreach(new i : Player)
	{
		if(!strcmp(ReturnName(i), ReturnDBIDName(VehicleInfo[vehicleid][eVehicleOwnerDBID])))
		{
			playerid = i;
		}
	}
	if(playerid != INVALID_PLAYER_ID)
	{
		SendClientMessage(playerid, COLOR_YELLOWEX, "SMS: Your vehicle alarm has been set off, Sender: Vehicle Alarm (Unknown)");
	}
	else return 1;
	return 1;
}

stock GetNearestVehicle(playerid)
{
 	new
	 	Float:fX,
	 	Float:fY,
	 	Float:fZ,
	 	Float:fSX,
	    Float:fSY,
		Float:fSZ,
		Float:fRadius;

	for (new i = 1, j = GetVehiclePoolSize(); i <= j; i ++)
	{
	    if (!IsVehicleStreamedIn(i, playerid))
		{
			continue;
	    }
	    else
	    {
			GetVehiclePos(i, fX, fY, fZ);

			GetVehicleModelInfo(GetVehicleModel(i), VEHICLE_MODEL_INFO_SIZE, fSX, fSY, fSZ);

			fRadius = floatsqroot((fSX + fSX) + (fSY + fSY));

			if (IsPlayerInRangeOfPoint(playerid, fRadius, fX, fY, fZ) && GetPlayerVirtualWorld(playerid) == GetVehicleVirtualWorld(i))
			{
				return i;
			}
		}
	}
	return INVALID_VEHICLE_ID;
}

stock GetVehicleBoot(vehicleid, &Float:x, &Float:y, &Float:z) 
{ 
    if (!GetVehicleModel(vehicleid) || vehicleid == INVALID_VEHICLE_ID) 
        return (x = 0.0, y = 0.0, z = 0.0), 0; 

    static 
        Float:pos[7] 
    ; 
    GetVehicleModelInfo(GetVehicleModel(vehicleid), VEHICLE_MODEL_INFO_SIZE, pos[0], pos[1], pos[2]); 
    GetVehiclePos(vehicleid, pos[3], pos[4], pos[5]); 
    GetVehicleZAngle(vehicleid, pos[6]); 

    x = pos[3] - (floatsqroot(pos[1] + pos[1]) * floatsin(-pos[6], degrees)); 
    y = pos[4] - (floatsqroot(pos[1] + pos[1]) * floatcos(-pos[6], degrees)); 
    z = pos[5]; 

    return 1; 
} 

stock GetVehicleHood(vehicleid, &Float:x, &Float:y, &Float:z) 
{ 
    if (!GetVehicleModel(vehicleid) || vehicleid == INVALID_VEHICLE_ID) 
        return (x = 0.0, y = 0.0, z = 0.0), 0; 

    static 
        Float:pos[7] 
    ; 
    GetVehicleModelInfo(GetVehicleModel(vehicleid), VEHICLE_MODEL_INFO_SIZE, pos[0], pos[1], pos[2]); 
    GetVehiclePos(vehicleid, pos[3], pos[4], pos[5]); 
    GetVehicleZAngle(vehicleid, pos[6]); 

    x = pos[3] + (floatsqroot(pos[1] + pos[1]) * floatsin(-pos[6], degrees)); 
    y = pos[4] + (floatsqroot(pos[1] + pos[1]) * floatcos(-pos[6], degrees)); 
    z = pos[5]; 

    return 1; 
}  

stock ReturnWeaponsModel(weaponid)
{
    new WeaponModels[] =
    {
        0, 331, 333, 334, 335, 336, 337, 338, 339, 341, 321, 322, 323, 324,
        325, 326, 342, 343, 344, 0, 0, 0, 346, 347, 348, 349, 350, 351, 352,
        353, 355, 356, 372, 357, 358, 359, 360, 361, 362, 363, 364, 365, 366,
        367, 368, 368, 371
    };
    return WeaponModels[weaponid];
}

stock IsPlayerInProperty(playerid)
{
	if(PlayerInfo[playerid][pInsideProperty])
	{
		for(new i = 1; i < MAX_PROPERTY; i++)
		{
			if(i == PlayerInfo[playerid][pInsideProperty] && GetPlayerVirtualWorld(playerid) == PropertyInfo[i][ePropertyInteriorWorld])
				return i;
		}
	}
	return 0;
}

stock IsPlayerNearProperty(playerid)
{
	for(new i = 1; i < MAX_PROPERTY; i++)
	{
		if(!PropertyInfo[i][ePropertyDBID])
			continue; 
			
		if(IsPlayerInRangeOfPoint(playerid, 3.0, PropertyInfo[i][ePropertyEntrance][0], PropertyInfo[i][ePropertyEntrance][1], PropertyInfo[i][ePropertyEntrance][2]) && GetPlayerVirtualWorld(playerid) == PropertyInfo[i][ePropertyEntranceWorld])
			return i;
	} 
	return 0; 
}

stock IsPlayerNearBusiness(playerid)
{
	for(new i = 1; i < MAX_BUSINESS; i++)
	{
		if(!BusinessInfo[i][eBusinessDBID])
			continue;
			
		if(IsPlayerInRangeOfPoint(playerid, 3.0, BusinessInfo[i][eBusinessEntrance][0], BusinessInfo[i][eBusinessEntrance][1], BusinessInfo[i][eBusinessEntrance][2]))
			return i;
	}
	return 0;
}

stock IsPlayerInBusiness(playerid)
{
	if(PlayerInfo[playerid][pInsideBusiness])
	{
		for(new i = 1; i < MAX_BUSINESS; i++)
		{
			if(!BusinessInfo[i][eBusinessDBID])
				continue;
				
			if(i == PlayerInfo[playerid][pInsideBusiness] && GetPlayerVirtualWorld(playerid) == BusinessInfo[i][eBusinessInteriorWorld])
				return i;
		}
	}
	return 0;
}

stock CountPlayerProperties(playerid)
{
	new
		count = 0
	;

	for(new i = 1; i < MAX_PROPERTY; i++)
	{
		if(!PropertyInfo[i][ePropertyDBID])
			continue;
			
		if(PropertyInfo[i][ePropertyOwnerDBID] == PlayerInfo[playerid][pDBID])
			count++; 
	}
	return count; 
}

stock CountPlayerBusiness(playerid)
{
	new
		count = 0
	;
	
	for(new i = 1; i < MAX_BUSINESS; i++)
	{
		if(!BusinessInfo[i][eBusinessDBID])
			continue;
			
		if(BusinessInfo[i][eBusinessOwnerDBID] == PlayerInfo[playerid][pDBID])
			count++;
	}
	return count;
}

stock CountPlayerVehicles(playerid)
{
	new
		count = 0
	;
	
	for(new i = 1; i < 6; i++)
	{
		if(PlayerInfo[playerid][pOwnedVehicles][i])
		{
			count++;
		}
	}
	return count;
}

stock ShowVehicleList(playerid)
{
    if(PlayerInfo[playerid][pViewingDealership]) return SendErrorMessage(playerid, "You are viewing dealership, you have to close it before view car list.");
	new thread[128]; 
	for(new i = 1; i < 6; i++)
	{
		if(PlayerInfo[playerid][pOwnedVehicles][i])
		{
			mysql_format(this, thread, sizeof(thread), "SELECT * FROM vehicles WHERE VehicleDBID = %i", PlayerInfo[playerid][pOwnedVehicles][i]);
			mysql_tquery(this, thread, "Query_ShowVehicleList", "ii", playerid, i);
		}
	}

	return 1;
}

stock DoesPlayerExist(name[])
{
	new checkQuery[128];
	
	mysql_format(this, checkQuery, sizeof(checkQuery), "SELECT char_name FROM characters WHERE char_name = '%e'", name);
	new Cache:cache = mysql_query(this, checkQuery);
	
	if(cache_num_rows())
	{
		cache_delete(cache); 
		return 1; 
	}
	
	cache_delete(cache);
	return 0;	
}

stock ReturnDBIDFromName(name[])
{
	new checkQuery[128], dbid;
	
	mysql_format(this, checkQuery, sizeof(checkQuery), "SELECT char_dbid FROM characters WHERE char_name = '%e'", name);
	new Cache:cache = mysql_query(this, checkQuery);
	
	
	if(!cache_num_rows())
	{
		cache_delete(cache);
		return 0;
	}
	
	dbid = cache_get_field_content_int(0, "char_dbid", this);
	cache_delete(cache);
	return dbid; 
}

stock MoneyFormat(integer)
{
	new value[20], string[20];

	valstr(value, integer);

	new charcount;

	for(new i = strlen(value); i >= 0; i --)
	{
		format(string, sizeof(string), "%c%s", value[i], string);
		if(charcount == 3)
		{
			if(i != 0)
				format(string, sizeof(string), ",%s", string);
			charcount = 0;
		}
		charcount ++;
	}

	return string;
}

stock ReturnXMRCategories(playerid)
{
	new 
		liststr[500];
		
	for (new i = 1; i < MAX_XMR_CATEGORY; i++)
	{
		if(XMRCategoryInfo[i][eXMRID])
		{			
			format (liststr, sizeof(liststr), "%s%s\n", liststr, XMRCategoryInfo[i][eXMRCategoryName]);
			ShowPlayerDialog(playerid, DIALOG_XMR_CATEGORIES, DIALOG_STYLE_LIST, "Genres:", liststr, "Select", "Cancel");
		}
	}
		
	return 1;
}

stock PlayXMRStation(playerid, vehicleid = INVALID_VEHICLE_ID, propertyid = 0, bool:disableXMR = false)
{
	new
		string[128]; 
		
	if(disableXMR == true)
	{
		if(vehicleid != INVALID_VEHICLE_ID)
		{
			foreach(new i : Player)
			{
				if(IsPlayerInVehicle(i, vehicleid))
				{
					StopAudioStreamForPlayer(i);
					SendClientMessage(i, COLOR_RED, "Radio has been stopped."); 
				}
			}
			
			VehicleInfo[vehicleid][eVehicleXMROn] = false; 
			format(VehicleInfo[vehicleid][eVehicleXMRURL], 128, " ");
			
			return 1;
		}
		
		if(propertyid != 0)
		{
			foreach(new i : Player)
			{
				if(IsPlayerInProperty(playerid) == propertyid)
				{
					StopAudioStreamForPlayer(i);
					SendClientMessage(i, COLOR_RED, "Radio has been stopped."); 
				}
			}
			
			PropertyInfo[propertyid][ePropertyBoomboxOn] = false;
			format(PropertyInfo[propertyid][ePropertyBoomboxURL], 128, " ");
			
			return 1;
		}
	
		return 1;
	}

	if(vehicleid != INVALID_VEHICLE_ID)
	{
		format(string, sizeof(string), "> %s has turned the radio to %s.", ReturnName(playerid, 0), XMRStationInfo[SubXMRHolder[playerid]][eXMRStationName]);
		SetPlayerChatBubble(playerid, string, COLOR_ACTION, 20.0, 3000);
		SendClientMessage(playerid, 0x88AA62FF, string);
		
		foreach(new i : Player)
		{
			if(IsPlayerInVehicle(i, vehicleid))
			{
				PlayAudioStreamForPlayer(i, XMRStationInfo[SubXMRHolder[playerid]][eXMRStationURL]); 
				sendMessage(i, COLOR_RED, "Radio changed to station %s.", XMRStationInfo[SubXMRHolder[playerid]][eXMRStationName]);
			}
		}
		
		if(!VehicleInfo[vehicleid][eVehicleXMROn])
			VehicleInfo[vehicleid][eVehicleXMROn] = true;
			
		format(VehicleInfo[vehicleid][eVehicleXMRURL], 128, "%s", XMRStationInfo[SubXMRHolder[playerid]][eXMRStationURL]); 
		SubXMRHolder[playerid] = 0;
		
		return 1;
	}
	
	if(propertyid != 0)
	{
		format(string, sizeof(string), "> %s has turned the radio to %s.", ReturnName(playerid, 0), XMRStationInfo[SubXMRHolder[playerid]][eXMRStationName]);
		SetPlayerChatBubble(playerid, string, COLOR_ACTION, 20.0, 3000);
		SendClientMessage(playerid, 0x88AA62FF, string);
		
		foreach(new i : Player)
		{
			if(IsPlayerInProperty(i) == propertyid)
			{
				PlayAudioStreamForPlayer(i, XMRStationInfo[SubXMRHolder[playerid]][eXMRStationURL]); 
				sendMessage(i, COLOR_RED, "Radio changed to station %s.", XMRStationInfo[SubXMRHolder[playerid]][eXMRStationName]);
			}
		}
		
		if(!PropertyInfo[propertyid][ePropertyBoomboxOn])
			PropertyInfo[propertyid][ePropertyBoomboxOn] = true;
			
		format(PropertyInfo[propertyid][ePropertyBoomboxURL], 128, "%s", XMRStationInfo[SubXMRHolder[playerid]][eXMRStationURL]);
		SubXMRHolder[playerid] = 0; 
		
		return 1;
	}

	return 1; 
}

stock ReturnNameLetter(playerid)
{
	new 
		playersName[MAX_PLAYER_NAME]
	; 
	
	GetPlayerName(playerid, playersName, sizeof(playersName));
	
	format(playersName, sizeof(playersName), "%c. %s", playersName[0], playersName[strfind(playersName, "_") + 1]);
	return playersName;
}

stock SendBusinessType(playerid, id)
{
	switch(BusinessInfo[id][eBusinessType])
	{
		case BUSINESS_TYPE_AMMUNATION:
		{
			sendMessage(playerid, COLOR_DARKGREEN, "Welcome to %s.", BusinessInfo[id][eBusinessName]);
			SendClientMessage(playerid, COLOR_WHITE, "Available commands: /buygun, /buyammo."); 
		}
		case BUSINESS_TYPE_BANK:
		{
			SendClientMessage(playerid, COLOR_DARKGREEN, "Bank: /bank, /withdraw, /balance."); 
		}
		case BUSINESS_TYPE_GENERAL:
		{
			sendMessage(playerid, COLOR_DARKGREEN, "Welcome to %s.", BusinessInfo[id][eBusinessName]);
			SendClientMessage(playerid, COLOR_WHITE, "Available commands: /buy, /withdraw, /balance."); 
		}
		case BUSINESS_TYPE_CLUB:
		{
			sendMessage(playerid, COLOR_DARKGREEN, "Welcome to %s.", BusinessInfo[id][eBusinessName]);
			SendClientMessage(playerid, COLOR_WHITE, "Available commands: /buydrink."); 
		}
		case BUSINESS_TYPE_RESTAURANT:
		{
			//sendMessage(playerid, COLOR_DARKGREEN, "This business offers %s. This is a fast food restaurant.", BusinessInfo[id][eBusinessName]);
			SendClientMessage(playerid, -1, "Use /eat or /meal order");
		}
	}
	return 1;
}

stock GetChannelSlot(playerid, chan)
{
	for(new i = 1; i < 3; i++)
	{
		if(PlayerInfo[playerid][pRadio][i] == chan)
			return i;
	}
	return 0; 
}

stock ResetDealershipVars(playerid)
{
	DeletePVar(playerid, "LockPrice");
	DeletePVar(playerid, "AlarmPrice");
	DeletePVar(playerid, "InsPrice");
	DeletePVar(playerid, "ImmobPrice");

	DealershipPlayerCar[playerid] = INVALID_VEHICLE_ID; 
	DealershipTotalCost[playerid] = 0;

	DealershipAlarmLevel[playerid] = 0;
	DealershipImmobLevel[playerid] = 1;
	
	DealershipLockLevel[playerid] = 0;
	DealershipXMR[playerid] = 0; 
	
	for(new i = 0; i <2 ;i++) { DealershipCarColors[playerid][i] = 0; }
	return 1;
}

stock ShowDealerAppend(playerid)
{
	new
		caption[60],
		str[255]
	;

	format(caption, 60, "%s - {33AA33}%s", g_aDealershipData[SubDealershipHolder[playerid]][eDealershipModel], MoneyFormat(DealershipTotalCost[playerid] + GetPVarInt(playerid, "InsPrice") + GetPVarInt(playerid, "LockPrice") + GetPVarInt(playerid, "ImmobPrice") + GetPVarInt(playerid, "AlarmPrice")));
				
	strcat(str, "Alarm\n");
	strcat(str, "Lock\n");
	strcat(str, "Immobiliser\n");
	strcat(str, "Insurance\n");
	strcat(str, "Colors\n");
	
	if(DealershipXMR[playerid])
		strcat(str, "{FFFF00}XM-Radio Installed\n");

	else strcat(str, "No XM Installed\n");
	
	strcat(str, "{FFFF00}Purchase Vehicle\n");
	ShowPlayerDialog(playerid, DIALOG_DEALERSHIP_APPEND, DIALOG_STYLE_LIST, caption, str, "Append", "<<"); 
	return 1; 
}

stock IsNumeric(const str[])
{
	for (new i = 0, l = strlen(str); i != l; i ++)
	{
	    if (i == 0 && str[0] == '-')
			continue;

	    else if (str[i] < '0' || str[i] > '9')
			return 0;
	}
	return 1;
}

stock sendTextInfo(playerid, str[], extra[], time = 4000)
{
	for(new i = 0; i < 2; i++)
	{
		PlayerTextDrawShow(playerid, ui_msgbox[playerid][i]);
	}
	PlayerTextDrawSetString(playerid, ui_msgbox[playerid][0], str);
	PlayerTextDrawSetString(playerid, ui_msgbox[playerid][1], extra);
	SetTimerEx("onTextSend", time, false, "ii", playerid, 0);
	return 1;
}

stock ReturnBodypartName(bodypart)
{
	new bodyname[20];
	
	switch(bodypart)
	{
		case BODY_PART_CHEST:bodyname = "CHEST";
		case BODY_PART_GROIN:bodyname = "GROIN";
		case BODY_PART_LEFT_ARM:bodyname = "LEFT ARM";
		case BODY_PART_RIGHT_ARM:bodyname = "RIGHT ARM";
		case BODY_PART_LEFT_LEG:bodyname = "LEFT LEG";
		case BODY_PART_RIGHT_LEG:bodyname = "RIGHT LEG";
		case BODY_PART_HEAD:bodyname = "HEAD";
	}
	
	return bodyname;
}

stock CallbackDamages(playerid, issuerid, bodypart, weaponid, Float:amount)
{
	new
		id,
		Float:armor
	;
	
	TotalPlayerDamages[playerid] ++; 
	
	for(new i = 0; i < 100; i++)
	{
		if(!DamageInfo[playerid][i][eDamageTaken])
		{
			id = i;
			break;
		}
	}
	
	GetPlayerArmour(playerid, armor);
	
	if(armor > 1 && bodypart == BODY_PART_CHEST)
		DamageInfo[playerid][id][eDamageArmor] = 1;
		
	else DamageInfo[playerid][id][eDamageArmor] = 0;
	
	DamageInfo[playerid][id][eDamageTaken] = floatround(amount, floatround_round); 
	DamageInfo[playerid][id][eDamageWeapon] = weaponid;
	
	DamageInfo[playerid][id][eDamageBodypart] = bodypart; 
	DamageInfo[playerid][id][eDamageTime] = gettime();
	
	DamageInfo[playerid][id][eDamageBy] = PlayerInfo[issuerid][pDBID]; 
	return 1; 
}

stock ShowPlayerDamages(damageid, playerid, adminView)
{
	new
		caption[33],
		str[355], 
		longstr[1200]
	; 
	
	format(caption, sizeof(caption), "%s", ReturnName(damageid));
	
	if (TotalPlayerDamages[damageid] < 1)
		return ShowPlayerDialog(playerid, DIALOG_DEFAULT, DIALOG_STYLE_LIST, caption, "There aren't any damages to show.", "<<", ""); 

	switch(adminView)
	{
		case 0:
		{
			for(new i = 0; i < 100; i ++)
			{
				if(!DamageInfo[damageid][i][eDamageTaken])
					continue;
					
				format(str, sizeof(str), "%d dmg from %s to %s (Kevlarhit: %d) %d s ago\n", DamageInfo[damageid][i][eDamageTaken], ReturnWeaponName(DamageInfo[damageid][i][eDamageWeapon]), ReturnBodypartName(DamageInfo[damageid][i][eDamageBodypart]), DamageInfo[damageid][i][eDamageArmor], gettime() - DamageInfo[damageid][i][eDamageTime]); 
				strcat(longstr, str); 
			}
			
			ShowPlayerDialog(playerid, DIALOG_DEFAULT, DIALOG_STYLE_LIST, caption, longstr, "<<", ""); 
		}
		case 1:
		{
			for(new i = 0; i < 100; i ++)
			{
				if(!DamageInfo[damageid][i][eDamageTaken])
					continue;
					
				format(str, sizeof(str), "{FF6346}(%s){FFFFFF} %d dmg from %s to %s (Kevlarhit: %d) %d s ago\n", ReturnDBIDName(DamageInfo[damageid][i][eDamageBy]), DamageInfo[damageid][i][eDamageTaken], ReturnWeaponName(DamageInfo[damageid][i][eDamageWeapon]), ReturnBodypartName(DamageInfo[damageid][i][eDamageBodypart]), DamageInfo[damageid][i][eDamageArmor], gettime() - DamageInfo[damageid][i][eDamageTime]); 
				strcat(longstr, str); 
			}
			
			ShowPlayerDialog(playerid, DIALOG_DEFAULT, DIALOG_STYLE_LIST, caption, longstr, "<<", ""); 
		}
	}
	return 1;
}

stock ClearDamages(playerid)
{
	for(new i = 0; i < 100; i++)
	{
		DamageInfo[playerid][i][eDamageTaken] = 0;
		DamageInfo[playerid][i][eDamageBy] = 0; 
		
		DamageInfo[playerid][i][eDamageArmor] = 0;
		DamageInfo[playerid][i][eDamageBodypart] = 0;
		
		DamageInfo[playerid][i][eDamageTime] = 0;
		DamageInfo[playerid][i][eDamageWeapon] = 0; 
	}
	
	return 1;
}

stock ReturnHour()
{
	new time[36]; 
	
	gettime(time[0], time[1], time[2]);
	
	format(time, sizeof(time), "%02d:%02d", time[0], time[1]);
	return time;
}

stock ReturnLicenses(playerid, playerb)
{
	new
		driver_str[60],
		wep_str[60]
	;
	
	if(!PlayerInfo[playerid][pDriversLicense])
		driver_str = "{FF6346}Driving License : No";
		
	else driver_str = "{E2FFFF}Driving License : Yes";
	
	if(!PlayerInfo[playerid][pWeaponsLicense])
		wep_str = "{FF6346}Weapons License : No";
	
	else wep_str = "{E2FFFF}Weapons License : Yes";
	
	SendClientMessage(playerb, COLOR_DARKGREEN, "______Identification_______");
	sendMessage(playerb, COLOR_GRAD2, "Name : %s", ReturnName(playerid));
	sendMessage(playerb, COLOR_GRAD2, "%s", driver_str);
	sendMessage(playerb, COLOR_GRAD2, "%s", wep_str);
	SendClientMessage(playerb, COLOR_DARKGREEN, "___________________________"); 
	return 1;
}

stock IsPlayerInDMVVehicle(playerid)
{
	new
		vehicleid = GetPlayerVehicleID(playerid);
	
	if(!vehicleid)
		return 0; 
		
	for(new i = 0; i < sizeof dmv_vehicles; i++)
	{
		if(vehicleid == dmv_vehicles[i])
			return 1;
	}
		
	return 0;
}

stock StopDriverstest(playerid)
{
	SetVehicleToRespawn(PlayersLicenseVehicle[playerid]);
	ToggleVehicleEngine(PlayersLicenseVehicle[playerid], false); 
	VehicleInfo[PlayersLicenseVehicle[playerid]][eVehicleEngineStatus] = false;
	
	PlayersLicenseVehicle[playerid] = INVALID_VEHICLE_ID; 
	
	PlayerLicensePoint[playerid] = 0;
	PlayerTakingLicense[playerid] = false;
	
	DisablePlayerCheckpoint(playerid);
	return 1;
}

stock GetPlayerStreet(playerid, zone[], len)
{
    for(new g = 0; g < MAX_STREET; g++ )
 	{
 	    if(IsPlayerInDynamicArea(playerid, street_data[g][area_tag]))
		{
		    return format(zone, len, street_data[g][street_name], 0);
		}
	}
	return format(zone, len, "Unknown", 0);
}

stock GetStreet(Float: x, Float: y, Float: z, zone[], len)
{
    for(new g = 0; g < MAX_STREET; g++ )
 	{
 	    if(IsPointInDynamicArea(street_data[g][area_tag], x, y, z))
		{
		    return format(zone, len, street_data[g][street_name], 0);
		}
	}
	return format(zone, len, "Unknown", 0);
}

stock GetPlayer2DZone(playerid, zone[], len)
{
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
	for(new i = 0; i != sizeof(gSAZones); i++ )
	{
        if(x >= gSAZones[i][SAZONE_AREA][0] && x <= gSAZones[i][SAZONE_AREA][3] && y >= gSAZones[i][SAZONE_AREA][1] && y <= gSAZones[i][SAZONE_AREA][4])
        {
            return format(zone, len, gSAZones[i][SAZONE_NAME], 0);
        }
	}
	return 0;
}

stock GetPlayerZoneID(playerid)
{
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
	for(new i = 0; i != sizeof(gSAZones); i++ )
	{
        if(x >= gSAZones[i][SAZONE_AREA][0] && x <= gSAZones[i][SAZONE_AREA][3] && y >= gSAZones[i][SAZONE_AREA][1] && y <= gSAZones[i][SAZONE_AREA][4])
        {
            return i;
        }
	}
	return 0;
}

stock GetPlayerCityID(playerid)
{
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
	for(new i = 0; i != sizeof(gSACities); i++ )
	{
        if(x >= gSACities[i][SACITY_AREA][0] && x <= gSACities[i][SACITY_AREA][3] && y >= gSACities[i][SACITY_AREA][1] && y <= gSACities[i][SACITY_AREA][4])
        {
            return i;
        }
	}
	return 0;
}

stock GetPlayerCity(playerid, zone[], len) //Credits to Cueball, Betamaster, Mabako, and Simon (for finetuning).
{
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
	for(new i = 0; i != sizeof(gSACities); i++ )
	{
        if(x >= gSACities[i][SACITY_AREA][0] && x <= gSACities[i][SACITY_AREA][3] && y >= gSACities[i][SACITY_AREA][1] && y <= gSACities[i][SACITY_AREA][4])
        {
            return format(zone, len, gSACities[i][SACITY_NAME], 0);
        }
	}
	return 0;
}

stock ReturnLocationEx(playerid)
{
	new 
		playerLocation[MAX_ZONE_NAME],
		playerCity[MAX_ZONE_NAME],
		playerStreet[MAX_ZONE_NAME],
		longStr[128]
	;
	GetPlayerStreet(playerid, playerStreet, MAX_ZONE_NAME);
	GetPlayer2DZone(playerid, playerLocation, MAX_ZONE_NAME);
	GetPlayerCity(playerid, playerCity, MAX_ZONE_NAME);
	format(longStr, sizeof(longStr), "%s, %s, %s %d", playerStreet, playerLocation, playerCity, ReturnAreaCode( GetPlayerZoneID(playerid) ));
	return longStr;
}

stock ReturnLocation(playerid)
{
	new
		playerStreet[MAX_ZONE_NAME],
		playerLocation[MAX_ZONE_NAME],
		longStr[128]
	;
	GetPlayerStreet(playerid, playerStreet, MAX_ZONE_NAME);
	GetPlayer2DZone(playerid, playerLocation, MAX_ZONE_NAME);
	format(longStr, sizeof(longStr), "%s, %s", playerStreet, playerLocation);
	return longStr;
}

stock Send911Message(playerid, type, payphone = 0)
{
    call_count++;
	switch(type)
	{
		case 991:
		{
			foreach(new i : Player) if(PlayerInfo[i][pPoliceDuty])
			{
				SendClientMessage(i, COLOR_CYAN, "|____________Non-Emergency Call____________|");
			    if(payphone > 0)
			    {
                    sendMessage(i, COLOR_CYAN, "Caller: Payphone, Number: %s, Trace: %s", PlayerInfo[playerid][pPhone], payphone_data[payphone][payphone_numstr], GetPayphoneArea(payphone_data[payphone][payphone_number]));
			    }
			    else
			    {
					sendMessage(i, COLOR_PINK, "Caller: %s, Phone: %d, Trace: %s", ReturnName(playerid, 0), PlayerInfo[playerid][pPhone], ReturnLocation(playerid));
			    }
				sendMessage(i, COLOR_CYAN, "Service required: %s", Player911Text[playerid][0]);
				sendMessage(i, COLOR_CYAN, "Situation: %s", Player911Text[playerid][1]);
				sendMessage(i, COLOR_CYAN, "Location: %s", Player911Text[playerid][2]);
			}
		}
		case 911:
		{
			foreach(new i : Player) if(PlayerInfo[i][pPoliceDuty])
			{
				SendClientMessage(i, COLOR_CYAN, "|____________Emergency Call____________|");
			    if(payphone > 0)
			    {
                    sendMessage(i, COLOR_CYAN, "Caller: Payphone, Number: %s, Trace: %s", PlayerInfo[playerid][pPhone], payphone_data[payphone][payphone_numstr], GetPayphoneArea(payphone_data[payphone][payphone_number]));
			    }
			    else
			    {
					sendMessage(i, COLOR_PINK, "Caller: %s, Phone: %d, Trace: %s", ReturnName(playerid, 0), PlayerInfo[playerid][pPhone], ReturnLocation(playerid));
			    }
				sendMessage(i, COLOR_CYAN, "Service required: %s", Player911Text[playerid][0]);
				sendMessage(i, COLOR_CYAN, "Situation: %s", Player911Text[playerid][1]);
				sendMessage(i, COLOR_CYAN, "Location: %s", Player911Text[playerid][2]);
			}
		}
		case 800:
		{
			foreach(new i : Player) if(PlayerInfo[i][pMedicDuty])
			{
				SendClientMessage(i, COLOR_PINK, "|____________Emergency Call____________|");
			    if(payphone > 0)
			    {
                    sendMessage(i, COLOR_CYAN, "Caller: Payphone, Number: %s, Trace: %s", PlayerInfo[playerid][pPhone], payphone_data[payphone][payphone_numstr], GetPayphoneArea(payphone_data[payphone][payphone_number]));
			    }
			    else
			    {
					sendMessage(i, COLOR_PINK, "Caller: %s, Phone: %d, Trace: %s", ReturnName(playerid, 0), PlayerInfo[playerid][pPhone], ReturnLocation(playerid));
			    }
				sendMessage(i, COLOR_PINK, "Service required: %s", Player911Text[playerid][0]);
				sendMessage(i, COLOR_PINK, "Situation: %s", Player911Text[playerid][1]);
				sendMessage(i, COLOR_PINK, "Location: %s", Player911Text[playerid][2]);
			}
		}
	}
	Player911Type[playerid] = 0;	
	callcmd::hangup(playerid, "");
	return 1;
}

stock ShowPlayerMDC(playerid)
{
	new
		list_str[128]
	;

	strcat(list_str, "Name Search\n");
	strcat(list_str, "Plate Search\n"); 
		
	ShowPlayerDialog(playerid, DIALOG_MDC, DIALOG_STYLE_LIST, "Mobile Database Computer", list_str, "Select", "Exit");
	return 1;
}

stock HasNoEngine(vehicleid)
{
	switch(GetVehicleModel(vehicleid))
	{
		case 481, 509, 510: return 1;
	}
	return 0;
}

//GetVehiclePartPos(vehicleid, VEHICLE_PART_CHASSIS, &Float:tx, &Float:ty, &Float:tz);

stock ListTrunkWeapons(playerid, vehicleid, bool:readonly)
{
	new principal_str[256];
	for(new i = 1; i < MAX_WEP_SLOT; i++)
	{
		if(vehicle_trunk_data[vehicleid][i][veh_wep])
			format(principal_str, sizeof(principal_str), "%s%i. %s[Ammo: %i]\n", principal_str, i, ReturnWeaponName(vehicle_trunk_data[vehicleid][i][veh_wep]), vehicle_trunk_data[vehicleid][i][veh_ammo]);
		else
			format(principal_str, sizeof(principal_str), "%s%i. [Empty]\n", principal_str, i);
	}
	if(readonly) ShowPlayerDialog(playerid, DIALOG_DEFAULT, DIALOG_STYLE_LIST, "Trunk:", principal_str, "<<", "");
	else ShowPlayerDialog(playerid, DIALOG_VEHICLE_WEAPONS, DIALOG_STYLE_LIST, "Trunk:", principal_str, "Take", "<<");
	return true;
}

stock GetVehicleTrunkWeps(vehicleid)
{
	new count = 0;
	for(new i = 1; i < MAX_WEP_SLOT; i++)
	{
		if(vehicle_trunk_data[vehicleid][i][veh_wep])
		{
			count++;
		}
	}
	return count;
}

stock GetNextVehicleTrunkSlot(vehicleid)
{
	new i = 1;
	while(i != MAX_WEP_SLOT)
	{
		if(vehicle_trunk_data[vehicleid][i][veh_wep] == 0)
		{
			return i;
		}
		i++;
	}
	return -1;
}

this::AddWeaponToTrunk(playerid, vehicleid, slot, weapon, ammo)
{
    vehicle_trunk_data[vehicleid][slot][data_id] = cache_insert_id();
    vehicle_trunk_data[vehicleid][slot][veh_wep] = weapon;
    vehicle_trunk_data[vehicleid][slot][veh_ammo] = ammo;
    vehicle_trunk_data[vehicleid][slot][is_exist] = true;
    vehicle_trunk_data[vehicleid][slot][veh_id] = VehicleInfo[vehicleid][eVehicleDBID];
    
	for(new i = 0; i < 6; i++) vehicle_trunk_data[vehicleid][slot][wep_offset][i] = 0.0;

	new Float: player_pos[3];
	GetPlayerPos(playerid, player_pos[0], player_pos[1], player_pos[2]);
    PlayerInfo[playerid][pEditingObject] = 3;
    SetPVarInt(playerid, "getVehicleID", vehicleid);
    SetPVarInt(playerid, "getSlot", slot);
    
    vehicle_trunk_data[vehicleid][slot][temp_object] = CreateDynamicObject(ReturnWeaponsModel(weapon), player_pos[0], player_pos[1], player_pos[2], 0, 0, 0);
	EditDynamicObject(playerid, vehicle_trunk_data[vehicleid][slot][temp_object]);
    SendClientMessage(playerid, COLOR_LIGHTRED, "[ ! ]{FFFFFF} You can hold {FFFF00}W{FFFFFF} in order to move the camera while editing.");

	PlayerInfo[playerid][pWeaponsAmmo][ ReturnWeaponIDSlot(weapon) ] = 0;
	PlayerInfo[playerid][pWeapons][ ReturnWeaponIDSlot(weapon) ] = 0;
	RemovePlayerWeapon(playerid, weapon);
	
    sendMessage(playerid, -1, "{FFFF00} You have stored a %s into %s.", ReturnWeaponName(weapon), ReturnVehicleName(vehicleid));
	return 1;
}

stock RemoveWeaponFromTrunk(playerid, vehicleid, slot)
{
	new str[128];
	GivePlayerGun(playerid, vehicle_trunk_data[vehicleid][slot][veh_wep], vehicle_trunk_data[vehicleid][slot][veh_ammo]);
	
	format(str, sizeof(str), "* %s takes a %s from the %s.", ReturnName(playerid, 0), ReturnWeaponName( vehicle_trunk_data[vehicleid][slot][veh_wep] ),
		ReturnVehicleName(vehicleid));

	SetPlayerChatBubble(playerid, str, COLOR_EMOTE, 20.0, 4500);
	SendClientMessage(playerid, COLOR_EMOTE, str);
	
	if(IsValidDynamicObject(vehicle_trunk_data[vehicleid][slot][temp_object])) DestroyDynamicObject(vehicle_trunk_data[vehicleid][slot][temp_object]);
    vehicle_trunk_data[vehicleid][slot][data_id] = EOS;
	vehicle_trunk_data[vehicleid][slot][veh_wep] = 0;
    vehicle_trunk_data[vehicleid][slot][veh_ammo] = 0;
    vehicle_trunk_data[vehicleid][slot][is_exist] = false;
    for(new i = 0; i < 6; i++) vehicle_trunk_data[vehicleid][slot][wep_offset][i] = 0.0;
	new delQuery[128];
	mysql_format(this, delQuery, sizeof(delQuery), "DELETE FROM vehicle_trunk WHERE id = %i", vehicle_trunk_data[vehicleid][slot][data_id]);
	mysql_tquery(this, delQuery);
	return 1;
}

this::Query_LoadTrunk(vehicleid)
{
	new rows, fields; cache_get_data(rows, fields, this);

	for (new i = 0; i < rows; i++)
	{
		for (new j = 1; j < MAX_WEP_SLOT; j++)
		{
		
		    vehicle_trunk_data[vehicleid][j][data_id] = cache_get_field_content_int(i, "id", this);
		    vehicle_trunk_data[vehicleid][j][veh_wep] = cache_get_field_content_int(i, "weapon", this);
			vehicle_trunk_data[vehicleid][j][veh_ammo] = cache_get_field_content_int(i, "ammo", this);
			vehicle_trunk_data[vehicleid][j][veh_id] = cache_get_field_content_int(i, "vehicle", this);
			vehicle_trunk_data[vehicleid][j][wep_offset][0] = cache_get_field_content_float(i, "offsetX", this);
			vehicle_trunk_data[vehicleid][j][wep_offset][1] = cache_get_field_content_float(i, "offsetY", this);
			vehicle_trunk_data[vehicleid][j][wep_offset][2] = cache_get_field_content_float(i, "offsetZ", this);
			vehicle_trunk_data[vehicleid][j][wep_offset][3] = cache_get_field_content_float(i, "rotX", this);
			vehicle_trunk_data[vehicleid][j][wep_offset][4] = cache_get_field_content_float(i, "rotY", this);
			vehicle_trunk_data[vehicleid][j][wep_offset][5] = cache_get_field_content_float(i, "rotZ", this);
			
			if(vehicle_trunk_data[vehicleid][j][veh_wep])
			{
			    if(IsValidDynamicObject( vehicle_trunk_data[vehicleid][j][temp_object] )) DestroyDynamicObject( vehicle_trunk_data[vehicleid][j][temp_object] );
			    vehicle_trunk_data[vehicleid][j][is_exist] = true;
			    vehicle_trunk_data[vehicleid][j][temp_object] = CreateDynamicObject(ReturnWeaponsModel( vehicle_trunk_data[vehicleid][j][veh_wep] ), 0, 0, -1000, 0, 0, 0);
			    AttachDynamicObjectToVehicle( vehicle_trunk_data[vehicleid][j][temp_object] , vehicleid,
					vehicle_trunk_data[vehicleid][j][wep_offset][0],
					vehicle_trunk_data[vehicleid][j][wep_offset][1],
					vehicle_trunk_data[vehicleid][j][wep_offset][2],
					vehicle_trunk_data[vehicleid][j][wep_offset][3],
					vehicle_trunk_data[vehicleid][j][wep_offset][4],
					vehicle_trunk_data[vehicleid][j][wep_offset][5]
				);
				printf("Loaded %i valid items from vehicle_data_id %i", VehicleInfo[vehicleid][eVehicleDBID]);
			}
		}
	}
	return 1;
}

this::OnPlayerInsertStreet(playerid, name[], Float: circleX, Float: circleY, Float: size)
{
	new idx = -1;
	for(new i = 1; i < MAX_STREET; i++)
	{
		if(street_data[i][street_id])
			continue;

		idx = i;
		break;
	}
	
    street_data[idx][street_id] = cache_insert_id();
    format(street_data[idx][street_name], 28, "%s", name);
    street_data[idx][street_area][0] = circleX;
    street_data[idx][street_area][1] = circleY;
    street_data[idx][street_size] = size;

    street_data[idx][area_tag] = CreateDynamicCircle(street_data[idx][street_area][0], street_data[idx][street_area][1], street_data[idx][street_size]);

    SendAdminMessageEx(COLOR_YELLOWEX, 1, "AdmWarn: %s created a new street [%s].", ReturnName(playerid), name);
	return 1;
}

this::Query_LoadStreets()
{
	if(!cache_num_rows())
		return printf("[SERVER]: No streets were loaded from \"%s\" database...", SQL_DATABASE);

	new rows, fields; cache_get_data(rows, fields, this);
	new countStreet = 0;

	for(new i = 0; i < rows && i < MAX_STREET; i++)
	{
		street_data[i+1][street_id] = cache_get_field_content_int(i, "id", this);
		cache_get_field_content(i, "name", street_data[i+1][street_name], this, 28);
		street_data[i+1][street_area][0] = cache_get_field_content_float(i, "circleX", this);
		street_data[i+1][street_area][1] = cache_get_field_content_float(i, "circleY", this);
        street_data[i+1][street_size] = cache_get_field_content_float(i, "size", this);
        street_data[i+1][area_tag] = CreateDynamicCircle(street_data[i+1][street_area][0], street_data[i+1][street_area][1], street_data[i+1][street_size]);
	    countStreet ++;
	}
	printf("[SERVER]: %d streets were loaded from \"%s\" database...", countStreet, SQL_DATABASE);
	return 1;
}

stock ReturnAreaCode(areaid)
{
	if(strcmp("Los Santos International", gSAZones[areaid][SAZONE_NAME], false) == 0) return 218;
	if(strcmp("Ocean Docks", gSAZones[areaid][SAZONE_NAME], false) == 0) return 218;
	if(strcmp("Santa Maria Beach", gSAZones[areaid][SAZONE_NAME], false) == 0) return 218;
	if(strcmp("Verona Beach", gSAZones[areaid][SAZONE_NAME], false) == 0) return 313;
	if(strcmp("Marina", gSAZones[areaid][SAZONE_NAME], false) == 0) return 313;
	if(strcmp("Rodeo", gSAZones[areaid][SAZONE_NAME], false) == 0) return 802;
	if(strcmp("Temple", gSAZones[areaid][SAZONE_NAME], false) == 0) return 343;
	if(strcmp("Market", gSAZones[areaid][SAZONE_NAME], false) == 0) return 343;
	if(strcmp("Downtown", gSAZones[areaid][SAZONE_NAME], false) == 0) return 206;
	if(strcmp("Pershing Square", gSAZones[areaid][SAZONE_NAME], false) == 0) return 206;
	if(strcmp("Glen Park", gSAZones[areaid][SAZONE_NAME], false) == 0) return 826;
	if(strcmp("Verdant Bluffs", gSAZones[areaid][SAZONE_NAME], false) == 0) return 216;
	if(strcmp("Idlewood", gSAZones[areaid][SAZONE_NAME], false) == 0) return 415;
	if(strcmp("Ganton", gSAZones[areaid][SAZONE_NAME], false) == 0) return 516;
	if(strcmp("El Corona", gSAZones[areaid][SAZONE_NAME], false) == 0) return 516;
	if(strcmp("Willowfield", gSAZones[areaid][SAZONE_NAME], false) == 0) return 516;
	if(strcmp("Playa Del Seville", gSAZones[areaid][SAZONE_NAME], false) == 0) return 516;
	if(strcmp("East Beach", gSAZones[areaid][SAZONE_NAME], false) == 0) return 616;
	if(strcmp("Jefferson", gSAZones[areaid][SAZONE_NAME], false) == 0) return 424;
	if(strcmp("East Los Santos", gSAZones[areaid][SAZONE_NAME], false) == 0) return 424;
	if(strcmp("Jefferson", gSAZones[areaid][SAZONE_NAME], false) == 0) return 424;
	if(strcmp("East Los Santos", gSAZones[areaid][SAZONE_NAME], false) == 0) return 424;
	if(strcmp("Vinewood", gSAZones[areaid][SAZONE_NAME], false) == 0) return 806;
	if(strcmp("Richman", gSAZones[areaid][SAZONE_NAME], false) == 0) return 806;
	if(strcmp("Mulholland", gSAZones[areaid][SAZONE_NAME], false) == 0) return 806;
	if(strcmp("North Rock", gSAZones[areaid][SAZONE_NAME], false) == 0) return 828;
	if(strcmp("Palomino Creek", gSAZones[areaid][SAZONE_NAME], false) == 0) return 835;
	if(strcmp("Montgomery", gSAZones[areaid][SAZONE_NAME], false) == 0) return 824;
	if(strcmp("Dillimore", gSAZones[areaid][SAZONE_NAME], false) == 0) return 808;
	if(strcmp("Blueberry", gSAZones[areaid][SAZONE_NAME], false) == 0) return 890;
	if(strcmp("Blueberry Acres", gSAZones[areaid][SAZONE_NAME], false) == 0) return 890;
	if(strcmp("The Panopticon", gSAZones[areaid][SAZONE_NAME], false) == 0) return 890;
	if(strcmp("Fallen Tree", gSAZones[areaid][SAZONE_NAME], false) == 0) return 890;
	if(strcmp("Easter Bay Chemicals", gSAZones[areaid][SAZONE_NAME], false) == 0) return 843;
	if(strcmp("The Farm", gSAZones[areaid][SAZONE_NAME], false) == 0) return 843;
	if(strcmp("Flint Country", gSAZones[areaid][SAZONE_NAME], false) == 0) return 856;
	if(strcmp("Angel Pine", gSAZones[areaid][SAZONE_NAME], false) == 0) return 856;
	if(strcmp("Fort Carson", gSAZones[areaid][SAZONE_NAME], false) == 0) return 855;
	if(strcmp("Harmony Oaks", gSAZones[areaid][SAZONE_NAME], false) == 0) return 310;
	return 999;
}

stock ReturnCityCode(cityid)
{
	if(strcmp("Los Santos", gSACities[cityid][SACITY_NAME], false) == 0) return 213;
	if(strcmp("San Fierro", gSACities[cityid][SACITY_NAME], false) == 0) return 415;
    if(strcmp("Las Venturas", gSACities[cityid][SACITY_NAME], false) == 0) return 702;
    if(strcmp("Flint County", gSACities[cityid][SACITY_NAME], false) == 0) return 707;
    if(strcmp("Red County", gSACities[cityid][SACITY_NAME], false) == 0) return 714;
    if(strcmp("Bone County", gSACities[cityid][SACITY_NAME], false) == 0) return 760;
    if(strcmp("Tierra Robada", gSACities[cityid][SACITY_NAME], false) == 0) return 619;
    if(strcmp("Whetstone", gSACities[cityid][SACITY_NAME], false) == 0) return 408;
	return 555;
}

stock init_global_textdraw()
{
 	Masktd = TextDrawCreate(544.890441, 354.666625, "_");
    TextDrawFont(Masktd, TEXT_DRAW_FONT_MODEL_PREVIEW);
    TextDrawTextSize(Masktd, 80.0, 80.0);
    TextDrawSetPreviewModel(Masktd, 19036);
    TextDrawBackgroundColor(Masktd, 0);
    TextDrawSetPreviewRot(Masktd, 0.0, 0.0, 90.0, 1.0);
    
	PP_Framework[0] = TextDrawCreate(484.436248, 207.500045, "box");
	TextDrawLetterSize(PP_Framework[0], 0.000000, 22.228401);
	TextDrawTextSize(PP_Framework[0], 612.000000, 0.000000);
	TextDrawAlignment(PP_Framework[0], 1);
	TextDrawColor(PP_Framework[0], -1);
	TextDrawUseBox(PP_Framework[0], 1);
	TextDrawBoxColor(PP_Framework[0], -2139062017);
	TextDrawSetShadow(PP_Framework[0], 0);
	TextDrawSetOutline(PP_Framework[0], 0);
	TextDrawBackgroundColor(PP_Framework[0], -2004317953);
	TextDrawFont(PP_Framework[0], 1);
	TextDrawSetProportional(PP_Framework[0], 1);
	TextDrawSetShadow(PP_Framework[0], 0);

	PP_Framework[1] = TextDrawCreate(492.401275, 218.000061, "box");
	TextDrawLetterSize(PP_Framework[1], 0.000000, 2.456809);
	TextDrawTextSize(PP_Framework[1], 587.000000, 0.000000);
	TextDrawAlignment(PP_Framework[1], 1);
	TextDrawColor(PP_Framework[1], -1);
	TextDrawUseBox(PP_Framework[1], 1);
	TextDrawBoxColor(PP_Framework[1], -858993409);
	TextDrawSetShadow(PP_Framework[1], 0);
	TextDrawSetOutline(PP_Framework[1], 0);
	TextDrawBackgroundColor(PP_Framework[1], 255);
	TextDrawFont(PP_Framework[1], 1);
	TextDrawSetProportional(PP_Framework[1], 1);
	TextDrawSetShadow(PP_Framework[1], 0);

	PP_Framework[2] = TextDrawCreate(588.748046, 215.666687, "");
	TextDrawLetterSize(PP_Framework[2], 0.000000, 0.000000);
	TextDrawTextSize(PP_Framework[2], 16.000000, 27.000000);
	TextDrawAlignment(PP_Framework[2], 1);
	TextDrawColor(PP_Framework[2], -1);
	TextDrawSetShadow(PP_Framework[2], 0);
	TextDrawSetOutline(PP_Framework[2], 0);
	TextDrawBackgroundColor(PP_Framework[2], 1431655935);
	TextDrawFont(PP_Framework[2], 5);
	TextDrawSetProportional(PP_Framework[2], 0);
	TextDrawSetShadow(PP_Framework[2], 0);
	TextDrawSetSelectable(PP_Framework[2], true);
	TextDrawSetPreviewModel(PP_Framework[2], 298);
	TextDrawSetPreviewRot(PP_Framework[2], 0.000000, 0.000000, 0.000000, -1.000000);

	PP_Framework[3] = TextDrawCreate(591.259521, 216.833312, "<");
	TextDrawLetterSize(PP_Framework[3], 0.301610, 2.515832);
	TextDrawAlignment(PP_Framework[3], 1);
	TextDrawColor(PP_Framework[3], -1);
	TextDrawSetShadow(PP_Framework[3], 0);
	TextDrawSetOutline(PP_Framework[3], 0);
	TextDrawBackgroundColor(PP_Framework[3], 255);
	TextDrawFont(PP_Framework[3], 2);
	TextDrawSetProportional(PP_Framework[3], 1);
	TextDrawSetShadow(PP_Framework[3], 0);

	PP_Framework[4] = TextDrawCreate(482.093994, 248.333358, "box");
	TextDrawLetterSize(PP_Framework[4], 0.000000, 2.175696);
	TextDrawTextSize(PP_Framework[4], 616.000000, 0.000000);
	TextDrawAlignment(PP_Framework[4], 1);
	TextDrawColor(PP_Framework[4], -1);
	TextDrawUseBox(PP_Framework[4], 1);
	TextDrawBoxColor(PP_Framework[4], 479182822);
	TextDrawSetShadow(PP_Framework[4], 0);
	TextDrawSetOutline(PP_Framework[4], 0);
	TextDrawBackgroundColor(PP_Framework[4], 255);
	TextDrawFont(PP_Framework[4], 1);
	TextDrawSetProportional(PP_Framework[4], 1);
	TextDrawSetShadow(PP_Framework[4], 0);

	PP_Framework[5] = TextDrawCreate(485.841827, 247.750030, "Want_to_advertise_here?_Call~n~1-800-Advertise_with_a_phone.");
	TextDrawLetterSize(PP_Framework[5], 0.235080, 1.063332);
	TextDrawAlignment(PP_Framework[5], 1);
	TextDrawColor(PP_Framework[5], -1);
	TextDrawSetShadow(PP_Framework[5], 0);
	TextDrawSetOutline(PP_Framework[5], 0);
	TextDrawBackgroundColor(PP_Framework[5], 255);
	TextDrawFont(PP_Framework[5], 1);
	TextDrawSetProportional(PP_Framework[5], 1);
	TextDrawSetShadow(PP_Framework[5], 0);

	PP_Framework[6] = TextDrawCreate(495.212249, 276.916717, "box");
	TextDrawLetterSize(PP_Framework[6], 0.000000, 12.811126);
	TextDrawTextSize(PP_Framework[6], 598.000000, 0.000000);
	TextDrawAlignment(PP_Framework[6], 1);
	TextDrawColor(PP_Framework[6], -1);
	TextDrawUseBox(PP_Framework[6], 1);
	TextDrawBoxColor(PP_Framework[6], -858993409);
	TextDrawSetShadow(PP_Framework[6], 0);
	TextDrawSetOutline(PP_Framework[6], 0);
	TextDrawBackgroundColor(PP_Framework[6], 255);
	TextDrawFont(PP_Framework[6], 1);
	TextDrawSetProportional(PP_Framework[6], 1);
	TextDrawSetShadow(PP_Framework[6], 0);

	PP_Framework[7] = TextDrawCreate(524.092285, 365.000000, "");
	TextDrawLetterSize(PP_Framework[7], 0.000000, 0.000000);
	TextDrawTextSize(PP_Framework[7], 72.000000, 22.000000);
	TextDrawAlignment(PP_Framework[7], 1);
	TextDrawColor(PP_Framework[7], -1);
	TextDrawSetShadow(PP_Framework[7], 0);
	TextDrawSetOutline(PP_Framework[7], 0);
	TextDrawBackgroundColor(PP_Framework[7], 762659839);
	TextDrawFont(PP_Framework[7], 5);
	TextDrawSetProportional(PP_Framework[7], 0);
	TextDrawSetShadow(PP_Framework[7], 0);
	TextDrawSetSelectable(PP_Framework[7], true);
	TextDrawSetPreviewModel(PP_Framework[7], 0);
	TextDrawSetPreviewRot(PP_Framework[7], 0.000000, 0.000000, 0.000000, -1.000000);

	PP_Framework[8] = TextDrawCreate(575.161193, 282.749908, "");
	TextDrawLetterSize(PP_Framework[8], 0.000000, 0.000000);
	TextDrawTextSize(PP_Framework[8], 21.000000, 77.000000);
	TextDrawAlignment(PP_Framework[8], 1);
	TextDrawColor(PP_Framework[8], -1);
	TextDrawSetShadow(PP_Framework[8], 0);
	TextDrawSetOutline(PP_Framework[8], 0);
	TextDrawBackgroundColor(PP_Framework[8], 255);
	TextDrawFont(PP_Framework[8], 5);
	TextDrawSetProportional(PP_Framework[8], 0);
	TextDrawSetShadow(PP_Framework[8], 0);
	TextDrawSetSelectable(PP_Framework[8], true);
	TextDrawSetPreviewModel(PP_Framework[8], 299);
	TextDrawSetPreviewRot(PP_Framework[8], 0.000000, 0.000000, 0.000000, -1.000000);

	PP_Framework[9] = TextDrawCreate(535.036743, 286.250152, "1___2___3");
	TextDrawLetterSize(PP_Framework[9], 0.413118, 1.774999);
	TextDrawAlignment(PP_Framework[9], 2);
	TextDrawColor(PP_Framework[9], -1);
	TextDrawSetShadow(PP_Framework[9], 0);
	TextDrawSetOutline(PP_Framework[9], 0);
	TextDrawBackgroundColor(PP_Framework[9], 255);
	TextDrawFont(PP_Framework[9], 1);
	TextDrawSetProportional(PP_Framework[9], 1);
	TextDrawSetShadow(PP_Framework[9], 0);

	PP_Framework[10] = TextDrawCreate(534.568237, 313.666900, "4___5___6");
	TextDrawLetterSize(PP_Framework[10], 0.413118, 1.774999);
	TextDrawAlignment(PP_Framework[10], 2);
	TextDrawColor(PP_Framework[10], -1);
	TextDrawSetShadow(PP_Framework[10], 0);
	TextDrawSetOutline(PP_Framework[10], 0);
	TextDrawBackgroundColor(PP_Framework[10], 255);
	TextDrawFont(PP_Framework[10], 1);
	TextDrawSetProportional(PP_Framework[10], 1);
	TextDrawSetShadow(PP_Framework[10], 0);

	PP_Framework[11] = TextDrawCreate(534.568237, 342.250396, "7___8___9");
	TextDrawLetterSize(PP_Framework[11], 0.413118, 1.774999);
	TextDrawAlignment(PP_Framework[11], 2);
	TextDrawColor(PP_Framework[11], -1);
	TextDrawSetShadow(PP_Framework[11], 0);
	TextDrawSetOutline(PP_Framework[11], 0);
	TextDrawBackgroundColor(PP_Framework[11], 255);
	TextDrawFont(PP_Framework[11], 1);
	TextDrawSetProportional(PP_Framework[11], 1);
	TextDrawSetShadow(PP_Framework[11], 0);

	PP_Framework[12] = TextDrawCreate(504.114288, 369.083435, "0");
	TextDrawLetterSize(PP_Framework[12], 0.400000, 1.600000);
	TextDrawAlignment(PP_Framework[12], 1);
	TextDrawColor(PP_Framework[12], -1);
	TextDrawSetShadow(PP_Framework[12], 0);
	TextDrawSetOutline(PP_Framework[12], 0);
	TextDrawBackgroundColor(PP_Framework[12], 255);
	TextDrawFont(PP_Framework[12], 1);
	TextDrawSetProportional(PP_Framework[12], 1);
	TextDrawSetShadow(PP_Framework[12], 0);

	PP_Framework[13] = TextDrawCreate(561.742492, 366.750000, "CALL");
	TextDrawLetterSize(PP_Framework[13], 0.462313, 1.792500);
	TextDrawAlignment(PP_Framework[13], 2);
	TextDrawColor(PP_Framework[13], -1);
	TextDrawSetShadow(PP_Framework[13], 0);
	TextDrawSetOutline(PP_Framework[13], 0);
	TextDrawBackgroundColor(PP_Framework[13], 255);
	TextDrawFont(PP_Framework[13], 2);
	TextDrawSetProportional(PP_Framework[13], 1);
	TextDrawSetShadow(PP_Framework[13], 0);

	PP_Framework[14] = TextDrawCreate(525.197937, 395.916442, "Provided_by_LS_Telefonica");
	TextDrawLetterSize(PP_Framework[14], 0.195724, 1.226665);
	TextDrawAlignment(PP_Framework[14], 1);
	TextDrawColor(PP_Framework[14], -1482184705);
	TextDrawSetShadow(PP_Framework[14], 0);
	TextDrawSetOutline(PP_Framework[14], 0);
	TextDrawBackgroundColor(PP_Framework[14], 255);
	TextDrawFont(PP_Framework[14], 1);
	TextDrawSetProportional(PP_Framework[14], 1);
	TextDrawSetShadow(PP_Framework[14], 0);
	
	Store_UI[0] = TextDrawCreate(139.904861, 100.166664, "");
	TextDrawLetterSize(Store_UI[0], 0.000000, 0.000000);
	TextDrawTextSize(Store_UI[0], 78.000000, 78.000000);
	TextDrawAlignment(Store_UI[0], 1);
	TextDrawColor(Store_UI[0], -1);
	TextDrawSetShadow(Store_UI[0], 0);
	TextDrawSetOutline(Store_UI[0], 0);
	TextDrawBackgroundColor(Store_UI[0], -572662273);
	TextDrawFont(Store_UI[0], 5);
	TextDrawSetProportional(Store_UI[0], 0);
	TextDrawSetShadow(Store_UI[0], 0);
	TextDrawSetSelectable(Store_UI[0], true);
	TextDrawSetPreviewModel(Store_UI[0], 1650);
	TextDrawSetPreviewRot(Store_UI[0], 0.000000, 0.000000, 35.000000, 0.899999);

	Store_UI[1] = TextDrawCreate(223.770141, 100.166671, "");
	TextDrawLetterSize(Store_UI[1], 0.000000, 0.000000);
	TextDrawTextSize(Store_UI[1], 78.000000, 78.000000);
	TextDrawAlignment(Store_UI[1], 1);
	TextDrawColor(Store_UI[1], -1);
	TextDrawSetShadow(Store_UI[1], 0);
	TextDrawSetOutline(Store_UI[1], 0);
	TextDrawBackgroundColor(Store_UI[1], -572662273);
	TextDrawFont(Store_UI[1], 5);
	TextDrawSetProportional(Store_UI[1], 0);
	TextDrawSetShadow(Store_UI[1], 0);
	TextDrawSetSelectable(Store_UI[1], true);
	TextDrawSetPreviewModel(Store_UI[1], 2226);
	TextDrawSetPreviewRot(Store_UI[1], 0.000000, 0.000000, 180.000000, 0.899999);

	Store_UI[2] = TextDrawCreate(140.373382, 184.749969, "");
	TextDrawLetterSize(Store_UI[2], 0.000000, 0.000000);
	TextDrawTextSize(Store_UI[2], 78.000000, 78.000000);
	TextDrawAlignment(Store_UI[2], 1);
	TextDrawColor(Store_UI[2], -1);
	TextDrawSetShadow(Store_UI[2], 0);
	TextDrawSetOutline(Store_UI[2], 0);
	TextDrawBackgroundColor(Store_UI[2], -572662273);
	TextDrawFont(Store_UI[2], 5);
	TextDrawSetProportional(Store_UI[2], 0);
	TextDrawSetShadow(Store_UI[2], 0);
	TextDrawSetSelectable(Store_UI[2], true);
	TextDrawSetPreviewModel(Store_UI[2], 336);
	TextDrawSetPreviewRot(Store_UI[2], 50.000000, 91.000000, 298.000000, 2.099999);

	Store_UI[3] = TextDrawCreate(224.238662, 184.166625, "");
	TextDrawLetterSize(Store_UI[3], 0.000000, 0.000000);
	TextDrawTextSize(Store_UI[3], 78.000000, 78.000000);
	TextDrawAlignment(Store_UI[3], 1);
	TextDrawColor(Store_UI[3], -1);
	TextDrawSetShadow(Store_UI[3], 0);
	TextDrawSetOutline(Store_UI[3], 0);
	TextDrawBackgroundColor(Store_UI[3], -572662273);
	TextDrawFont(Store_UI[3], 5);
	TextDrawSetProportional(Store_UI[3], 0);
	TextDrawSetShadow(Store_UI[3], 0);
	TextDrawSetSelectable(Store_UI[3], true);
	TextDrawSetPreviewModel(Store_UI[3], 325);
	TextDrawSetPreviewRot(Store_UI[3], 50.000000, 91.000000, 298.000000, 2.099999);

	Store_UI[4] = TextDrawCreate(308.104156, 184.166625, "");
	TextDrawLetterSize(Store_UI[4], 0.000000, 0.000000);
	TextDrawTextSize(Store_UI[4], 78.000000, 78.000000);
	TextDrawAlignment(Store_UI[4], 1);
	TextDrawColor(Store_UI[4], -1);
	TextDrawSetShadow(Store_UI[4], 0);
	TextDrawSetOutline(Store_UI[4], 0);
	TextDrawBackgroundColor(Store_UI[4], -572662273);
	TextDrawFont(Store_UI[4], 5);
	TextDrawSetProportional(Store_UI[4], 0);
	TextDrawSetShadow(Store_UI[4], 0);
	TextDrawSetSelectable(Store_UI[4], true);
	TextDrawSetPreviewModel(Store_UI[4], 326);
	TextDrawSetPreviewRot(Store_UI[4], 50.000000, 91.000000, 298.000000, 1.000000);

	Store_UI[5] = TextDrawCreate(392.437927, 183.583297, "");
	TextDrawLetterSize(Store_UI[5], 0.000000, 0.000000);
	TextDrawTextSize(Store_UI[5], 78.000000, 78.000000);
	TextDrawAlignment(Store_UI[5], 1);
	TextDrawColor(Store_UI[5], -1);
	TextDrawSetShadow(Store_UI[5], 0);
	TextDrawSetOutline(Store_UI[5], 0);
	TextDrawBackgroundColor(Store_UI[5], -572662273);
	TextDrawFont(Store_UI[5], 5);
	TextDrawSetProportional(Store_UI[5], 0);
	TextDrawSetShadow(Store_UI[5], 0);
	TextDrawSetSelectable(Store_UI[5], true);
	TextDrawSetPreviewModel(Store_UI[5], 367);
	TextDrawSetPreviewRot(Store_UI[5], 52.000000, 231.000000, 102.000000, 1.000000);

	Store_UI[6] = TextDrawCreate(139.904861, 269.333221, "");
	TextDrawLetterSize(Store_UI[6], 0.000000, 0.000000);
	TextDrawTextSize(Store_UI[6], 78.000000, 78.000000);
	TextDrawAlignment(Store_UI[6], 1);
	TextDrawColor(Store_UI[6], -1);
	TextDrawSetShadow(Store_UI[6], 0);
	TextDrawSetOutline(Store_UI[6], 0);
	TextDrawBackgroundColor(Store_UI[6], -572662273);
	TextDrawFont(Store_UI[6], 5);
	TextDrawSetProportional(Store_UI[6], 0);
	TextDrawSetShadow(Store_UI[6], 0);
	TextDrawSetSelectable(Store_UI[6], true);
	TextDrawSetPreviewModel(Store_UI[6], 325);
	TextDrawSetPreviewRot(Store_UI[6], 50.000000, 91.000000, 298.000000, -1.000000);

	Store_UI[7] = TextDrawCreate(224.238769, 269.333251, "");
	TextDrawLetterSize(Store_UI[7], 0.000000, 0.000000);
	TextDrawTextSize(Store_UI[7], 78.000000, 78.000000);
	TextDrawAlignment(Store_UI[7], 1);
	TextDrawColor(Store_UI[7], -1);
	TextDrawSetShadow(Store_UI[7], 0);
	TextDrawSetOutline(Store_UI[7], 0);
	TextDrawBackgroundColor(Store_UI[7], -572662273);
	TextDrawFont(Store_UI[7], 5);
	TextDrawSetProportional(Store_UI[7], 0);
	TextDrawSetShadow(Store_UI[7], 0);
	TextDrawSetSelectable(Store_UI[7], true);
	TextDrawSetPreviewModel(Store_UI[7], 19823);
	TextDrawSetPreviewRot(Store_UI[7], 0.000000, 0.000000, 0.000000, 1.000000);

	Store_UI[8] = TextDrawCreate(308.572631, 269.333282, "");
	TextDrawLetterSize(Store_UI[8], 0.000000, 0.000000);
	TextDrawTextSize(Store_UI[8], 78.000000, 78.000000);
	TextDrawAlignment(Store_UI[8], 1);
	TextDrawColor(Store_UI[8], -1);
	TextDrawSetShadow(Store_UI[8], 0);
	TextDrawSetOutline(Store_UI[8], 0);
	TextDrawBackgroundColor(Store_UI[8], -572662273);
	TextDrawFont(Store_UI[8], 5);
	TextDrawSetProportional(Store_UI[8], 0);
	TextDrawSetShadow(Store_UI[8], 0);
	TextDrawSetSelectable(Store_UI[8], true);
	TextDrawSetPreviewModel(Store_UI[8], 19896);
	TextDrawSetPreviewRot(Store_UI[8], 90.000000, 180.000000, 0.000000, 0.699999);

	Store_UI[9] = TextDrawCreate(392.906677, 269.333251, "");
	TextDrawLetterSize(Store_UI[9], 0.000000, 0.000000);
	TextDrawTextSize(Store_UI[9], 78.000000, 78.000000);
	TextDrawAlignment(Store_UI[9], 1);
	TextDrawColor(Store_UI[9], -1);
	TextDrawSetShadow(Store_UI[9], 0);
	TextDrawSetOutline(Store_UI[9], 0);
	TextDrawBackgroundColor(Store_UI[9], -572662273);
	TextDrawFont(Store_UI[9], 5);
	TextDrawSetProportional(Store_UI[9], 0);
	TextDrawSetShadow(Store_UI[9], 0);
	TextDrawSetSelectable(Store_UI[9], true);
	TextDrawSetPreviewModel(Store_UI[9], 19942);
	TextDrawSetPreviewRot(Store_UI[9], 0.000000, 0.000000, 180.000000, 0.899999);

	Store_Frame[0] = TextDrawCreate(136.325042, 83.833259, "box");
	TextDrawLetterSize(Store_Frame[0], 0.000000, 30.005851);
	TextDrawTextSize(Store_Frame[0], 477.000000, 0.000000);
	TextDrawAlignment(Store_Frame[0], 1);
	TextDrawColor(Store_Frame[0], -1);
	TextDrawUseBox(Store_Frame[0], 1);
	TextDrawBoxColor(Store_Frame[0], 120);
	TextDrawSetShadow(Store_Frame[0], 0);
	TextDrawSetOutline(Store_Frame[0], 0);
	TextDrawBackgroundColor(Store_Frame[0], 255);
	TextDrawFont(Store_Frame[0], 1);
	TextDrawSetProportional(Store_Frame[0], 1);
	TextDrawSetShadow(Store_Frame[0], 0);

	Store_Frame[1] = TextDrawCreate(143.352828, 99.583358, "Gas_can");
	TextDrawLetterSize(Store_Frame[1], 0.256163, 1.407499);
	TextDrawAlignment(Store_Frame[1], 1);
	TextDrawColor(Store_Frame[1], -1);
	TextDrawSetShadow(Store_Frame[1], 0);
	TextDrawSetOutline(Store_Frame[1], 1);
	TextDrawBackgroundColor(Store_Frame[1], 255);
	TextDrawFont(Store_Frame[1], 1);
	TextDrawSetProportional(Store_Frame[1], 1);
	TextDrawSetShadow(Store_Frame[1], 0);

	Store_Frame[2] = TextDrawCreate(198.638351, 167.249984, "$500");
	TextDrawLetterSize(Store_Frame[2], 0.192269, 1.074999);
	TextDrawAlignment(Store_Frame[2], 1);
	TextDrawColor(Store_Frame[2], 1249264383);
	TextDrawSetShadow(Store_Frame[2], 0);
	TextDrawSetOutline(Store_Frame[2], 0);
	TextDrawBackgroundColor(Store_Frame[2], 255);
	TextDrawFont(Store_Frame[2], 1);
	TextDrawSetProportional(Store_Frame[2], 1);
	TextDrawSetShadow(Store_Frame[2], 0);

	Store_Frame[3] = TextDrawCreate(229.092193, 101.333396, "Boombox");
	TextDrawLetterSize(Store_Frame[3], 0.256163, 1.407499);
	TextDrawAlignment(Store_Frame[3], 1);
	TextDrawColor(Store_Frame[3], -1);
	TextDrawSetShadow(Store_Frame[3], 0);
	TextDrawSetOutline(Store_Frame[3], 1);
	TextDrawBackgroundColor(Store_Frame[3], 255);
	TextDrawFont(Store_Frame[3], 1);
	TextDrawSetProportional(Store_Frame[3], 1);
	TextDrawSetShadow(Store_Frame[3], 0);

	Store_Frame[4] = TextDrawCreate(273.133300, 167.249984, "$10,000");
	TextDrawLetterSize(Store_Frame[4], 0.192269, 1.074999);
	TextDrawAlignment(Store_Frame[4], 1);
	TextDrawColor(Store_Frame[4], 1249264383);
	TextDrawSetShadow(Store_Frame[4], 0);
	TextDrawSetOutline(Store_Frame[4], 0);
	TextDrawBackgroundColor(Store_Frame[4], 255);
	TextDrawFont(Store_Frame[4], 1);
	TextDrawSetProportional(Store_Frame[4], 1);
	TextDrawSetShadow(Store_Frame[4], 0);


	Store_Frame[5] = TextDrawCreate(144.289871, 187.083374, "Baseball_bat");
	TextDrawLetterSize(Store_Frame[5], 0.256163, 1.407499);
	TextDrawAlignment(Store_Frame[5], 1);
	TextDrawColor(Store_Frame[5], -1);
	TextDrawSetShadow(Store_Frame[5], 0);
	TextDrawSetOutline(Store_Frame[5], 1);
	TextDrawBackgroundColor(Store_Frame[5], 255);
	TextDrawFont(Store_Frame[5], 1);
	TextDrawSetProportional(Store_Frame[5], 1);
	TextDrawSetShadow(Store_Frame[5], 0);

	Store_Frame[6] = TextDrawCreate(192.547576, 250.083267, "$1,500");
	TextDrawLetterSize(Store_Frame[6], 0.192269, 1.074999);
	TextDrawAlignment(Store_Frame[6], 1);
	TextDrawColor(Store_Frame[6], 1249264383);
	TextDrawSetShadow(Store_Frame[6], 0);
	TextDrawSetOutline(Store_Frame[6], 0);
	TextDrawBackgroundColor(Store_Frame[6], 255);
	TextDrawFont(Store_Frame[6], 1);
	TextDrawSetProportional(Store_Frame[6], 1);
	TextDrawSetShadow(Store_Frame[6], 0);

	Store_Frame[7] = TextDrawCreate(144.758392, 272.250091, "OOC_Mask");
	TextDrawLetterSize(Store_Frame[7], 0.256163, 1.407499);
	TextDrawAlignment(Store_Frame[7], 1);
	TextDrawColor(Store_Frame[7], -1);
	TextDrawSetShadow(Store_Frame[7], 0);
	TextDrawSetOutline(Store_Frame[7], 1);
	TextDrawBackgroundColor(Store_Frame[7], 255);
	TextDrawFont(Store_Frame[7], 1);
	TextDrawSetProportional(Store_Frame[7], 1);
	TextDrawSetShadow(Store_Frame[7], 0);

	Store_Frame[8] = TextDrawCreate(230.966308, 271.666687, "Drink");
	TextDrawLetterSize(Store_Frame[8], 0.256163, 1.407499);
	TextDrawAlignment(Store_Frame[8], 1);
	TextDrawColor(Store_Frame[8], -1);
	TextDrawSetShadow(Store_Frame[8], 0);
	TextDrawSetOutline(Store_Frame[8], 1);
	TextDrawBackgroundColor(Store_Frame[8], 255);
	TextDrawFont(Store_Frame[8], 1);
	TextDrawSetProportional(Store_Frame[8], 1);
	TextDrawSetShadow(Store_Frame[8], 0);

	Store_Frame[9] = TextDrawCreate(312.489044, 271.666656, "Cigarettes");
	TextDrawLetterSize(Store_Frame[9], 0.256163, 1.407499);
	TextDrawAlignment(Store_Frame[9], 1);
	TextDrawColor(Store_Frame[9], -1);
	TextDrawSetShadow(Store_Frame[9], 0);
	TextDrawSetOutline(Store_Frame[9], 1);
	TextDrawBackgroundColor(Store_Frame[9], 255);
	TextDrawFont(Store_Frame[9], 1);
	TextDrawSetProportional(Store_Frame[9], 1);
	TextDrawSetShadow(Store_Frame[9], 0);

	Store_Frame[10] = TextDrawCreate(398.697143, 272.250000, "Radio");
	TextDrawLetterSize(Store_Frame[10], 0.256163, 1.407499);
	TextDrawAlignment(Store_Frame[10], 1);
	TextDrawColor(Store_Frame[10], -1);
	TextDrawSetShadow(Store_Frame[10], 0);
	TextDrawSetOutline(Store_Frame[10], 1);
	TextDrawBackgroundColor(Store_Frame[10], 255);
	TextDrawFont(Store_Frame[10], 1);
	TextDrawSetProportional(Store_Frame[10], 1);
	TextDrawSetShadow(Store_Frame[10], 0);

	Store_Frame[11] = TextDrawCreate(281.098175, 250.083251, "$500");
	TextDrawLetterSize(Store_Frame[11], 0.192269, 1.074999);
	TextDrawAlignment(Store_Frame[11], 1);
	TextDrawColor(Store_Frame[11], 1249264383);
	TextDrawSetShadow(Store_Frame[11], 0);
	TextDrawSetOutline(Store_Frame[11], 0);
	TextDrawBackgroundColor(Store_Frame[11], 255);
	TextDrawFont(Store_Frame[11], 1);
	TextDrawSetProportional(Store_Frame[11], 1);
	TextDrawSetShadow(Store_Frame[11], 0);

	Store_Frame[12] = TextDrawCreate(449.766387, 249.499938, "$500");
	TextDrawLetterSize(Store_Frame[12], 0.192269, 1.074999);
	TextDrawAlignment(Store_Frame[12], 1);
	TextDrawColor(Store_Frame[12], 1249264383);
	TextDrawSetShadow(Store_Frame[12], 0);
	TextDrawSetOutline(Store_Frame[12], 0);
	TextDrawBackgroundColor(Store_Frame[12], 255);
	TextDrawFont(Store_Frame[12], 1);
	TextDrawSetProportional(Store_Frame[12], 1);
	TextDrawSetShadow(Store_Frame[12], 0);

	Store_Frame[13] = TextDrawCreate(365.432525, 250.083267, "$200");
	TextDrawLetterSize(Store_Frame[13], 0.192269, 1.074999);
	TextDrawAlignment(Store_Frame[13], 1);
	TextDrawColor(Store_Frame[13], 1249264383);
	TextDrawSetShadow(Store_Frame[13], 0);
	TextDrawSetOutline(Store_Frame[13], 0);
	TextDrawBackgroundColor(Store_Frame[13], 255);
	TextDrawFont(Store_Frame[13], 1);
	TextDrawSetProportional(Store_Frame[13], 1);
	TextDrawSetShadow(Store_Frame[13], 0);

	Store_Frame[14] = TextDrawCreate(190.205520, 334.666656, "$5,000");
	TextDrawLetterSize(Store_Frame[14], 0.192269, 1.074999);
	TextDrawAlignment(Store_Frame[14], 1);
	TextDrawColor(Store_Frame[14], 1249264383);
	TextDrawSetShadow(Store_Frame[14], 0);
	TextDrawSetOutline(Store_Frame[14], 0);
	TextDrawBackgroundColor(Store_Frame[14], 255);
	TextDrawFont(Store_Frame[14], 1);
	TextDrawSetProportional(Store_Frame[14], 1);
	TextDrawSetShadow(Store_Frame[14], 0);

	Store_Frame[15] = TextDrawCreate(281.098663, 335.250061, "$200");
	TextDrawLetterSize(Store_Frame[15], 0.192269, 1.074999);
	TextDrawAlignment(Store_Frame[15], 1);
	TextDrawColor(Store_Frame[15], 1249264383);
	TextDrawSetShadow(Store_Frame[15], 0);
	TextDrawSetOutline(Store_Frame[15], 0);
	TextDrawBackgroundColor(Store_Frame[15], 255);
	TextDrawFont(Store_Frame[15], 1);
	TextDrawSetProportional(Store_Frame[15], 1);
	TextDrawSetShadow(Store_Frame[15], 0);

	Store_Frame[16] = TextDrawCreate(365.901275, 334.666748, "$500");
	TextDrawLetterSize(Store_Frame[16], 0.192269, 1.074999);
	TextDrawAlignment(Store_Frame[16], 1);
	TextDrawColor(Store_Frame[16], 1249264383);
	TextDrawSetShadow(Store_Frame[16], 0);
	TextDrawSetOutline(Store_Frame[16], 0);
	TextDrawBackgroundColor(Store_Frame[16], 255);
	TextDrawFont(Store_Frame[16], 1);
	TextDrawSetProportional(Store_Frame[16], 1);
	TextDrawSetShadow(Store_Frame[16], 0);

	Store_Frame[17] = TextDrawCreate(434.305236, 335.833496, "prices_vary");
	TextDrawLetterSize(Store_Frame[17], 0.192269, 1.074999);
	TextDrawAlignment(Store_Frame[17], 1);
	TextDrawColor(Store_Frame[17], 1249264383);
	TextDrawSetShadow(Store_Frame[17], 0);
	TextDrawSetOutline(Store_Frame[17], 0);
	TextDrawBackgroundColor(Store_Frame[17], 255);
	TextDrawFont(Store_Frame[17], 1);
	TextDrawSetProportional(Store_Frame[17], 1);
	TextDrawSetShadow(Store_Frame[17], 0);

	Store_Frame[18] = TextDrawCreate(0, 0, "_");
	TextDrawLetterSize(Store_Frame[18], 0, 0);
	TextDrawAlignment(Store_Frame[18], 1);
	TextDrawColor(Store_Frame[18], -1);
	TextDrawSetShadow(Store_Frame[18], 0);
	TextDrawSetOutline(Store_Frame[18], 1);
	TextDrawBackgroundColor(Store_Frame[18], 255);
	TextDrawFont(Store_Frame[18], 0);
	TextDrawSetProportional(Store_Frame[18], 1);
	TextDrawSetShadow(Store_Frame[18], 0);

	Store_Frame[19] = TextDrawCreate(374.333770, 169.583358, "PURCHASE");
	TextDrawLetterSize(Store_Frame[19], 0.238360, 1.069166);
	TextDrawAlignment(Store_Frame[19], 1);
	TextDrawColor(Store_Frame[19], 8388863);
	TextDrawSetShadow(Store_Frame[19], 0);
	TextDrawSetOutline(Store_Frame[19], 1);
	TextDrawBackgroundColor(Store_Frame[19], 255);
	TextDrawFont(Store_Frame[19], 1);
	TextDrawSetProportional(Store_Frame[19], 1);
	TextDrawSetShadow(Store_Frame[19], 0);
	TextDrawSetSelectable(Store_Frame[19], true);

	Store_Frame[20] = TextDrawCreate(420.248870, 169.583343, "EMPTY_CART");
	TextDrawLetterSize(Store_Frame[20], 0.238360, 1.069166);
	TextDrawAlignment(Store_Frame[20], 1);
	TextDrawColor(Store_Frame[20], -16776961);
	TextDrawSetShadow(Store_Frame[20], 0);
	TextDrawSetOutline(Store_Frame[20], 1);
	TextDrawBackgroundColor(Store_Frame[20], 255);
	TextDrawFont(Store_Frame[20], 1);
	TextDrawSetProportional(Store_Frame[20], 1);
	TextDrawSetShadow(Store_Frame[20], 0);
	//TextDrawSetSelectable(Store_Frame[20], true);

	Store_Frame[21] = TextDrawCreate(307.803710, 168.416671, "Cart:");
	TextDrawLetterSize(Store_Frame[21], 0.190102, 1.197499);
	TextDrawAlignment(Store_Frame[21], 1);
	TextDrawColor(Store_Frame[21], -1);
	TextDrawSetShadow(Store_Frame[21], 0);
	TextDrawSetOutline(Store_Frame[21], 1);
	TextDrawBackgroundColor(Store_Frame[21], 255);
	TextDrawFont(Store_Frame[21], 1);
	TextDrawSetProportional(Store_Frame[21], 1);
	TextDrawSetShadow(Store_Frame[21], 0);

	Store_Frame[22] = TextDrawCreate(310.146270, 96.666633, "Welcome!");
	TextDrawLetterSize(Store_Frame[22], 0.419209, 1.769166);
	TextDrawAlignment(Store_Frame[22], 1);
	TextDrawColor(Store_Frame[22], -1);
	TextDrawSetShadow(Store_Frame[22], 0);
	TextDrawSetOutline(Store_Frame[22], 1);
	TextDrawBackgroundColor(Store_Frame[22], 255);
	TextDrawFont(Store_Frame[22], 1);
	TextDrawSetProportional(Store_Frame[22], 1);
	TextDrawSetShadow(Store_Frame[22], 0);

	Store_Frame[23] = TextDrawCreate(310.146331, 114.166656, "Click_on_any_of_the_items_to_add_them_to~n~your_cart.~n~~n~Press_ESC_to_exit.");
	TextDrawLetterSize(Store_Frame[23], 0.189634, 1.133334);
	TextDrawAlignment(Store_Frame[23], 1);
	TextDrawColor(Store_Frame[23], -1);
	TextDrawSetShadow(Store_Frame[23], 0);
	TextDrawSetOutline(Store_Frame[23], 1);
	TextDrawBackgroundColor(Store_Frame[23], 255);
	TextDrawFont(Store_Frame[23], 1);
	TextDrawSetProportional(Store_Frame[23], 1);
	TextDrawSetShadow(Store_Frame[23], 0);

	Store_Frame[24] = TextDrawCreate(455.856719, 75.666625, "EXIT");
	TextDrawLetterSize(Store_Frame[24], 0.316603, 1.495000);
	TextDrawAlignment(Store_Frame[24], 1);
	TextDrawColor(Store_Frame[24], -1);
	TextDrawSetShadow(Store_Frame[24], 0);
	TextDrawSetOutline(Store_Frame[24], 1);
	TextDrawBackgroundColor(Store_Frame[24], 255);
	TextDrawFont(Store_Frame[24], 1);
	TextDrawSetProportional(Store_Frame[24], 1);
	TextDrawSetShadow(Store_Frame[24], 0);
	TextDrawSetSelectable(Store_Frame[24], true);

	Store_Frame[25] = TextDrawCreate(0, 0, "");
	TextDrawLetterSize(Store_Frame[25], 0.000000, 0.000000);
	TextDrawTextSize(Store_Frame[25], -46.000000, 10.000000);
	TextDrawAlignment(Store_Frame[25], 1);
	TextDrawColor(Store_Frame[25], -1);
	TextDrawSetShadow(Store_Frame[25], 0);
	TextDrawSetOutline(Store_Frame[25], 0);
	TextDrawBackgroundColor(Store_Frame[25], 0);
	TextDrawFont(Store_Frame[25], 5);
	TextDrawSetProportional(Store_Frame[25], 0);
	TextDrawSetShadow(Store_Frame[25], 0);
	//TextDrawSetSelectable(Store_Frame[25], true);
	TextDrawSetPreviewModel(Store_Frame[25], 0);
	TextDrawSetPreviewRot(Store_Frame[25], 0.000000, 0.000000, 0.000000, -1.000000);

	Store_Frame[26] = TextDrawCreate(420.248870, 169.583343, "");
	TextDrawLetterSize(Store_Frame[26], 0.000000, 0.000000);
	TextDrawTextSize(Store_Frame[26], -46.000000, 10.000000);
	TextDrawAlignment(Store_Frame[26], 1);
	TextDrawColor(Store_Frame[26], -1);
	TextDrawSetShadow(Store_Frame[26], 0);
	TextDrawSetOutline(Store_Frame[26], 0);
	TextDrawBackgroundColor(Store_Frame[26], 0);
	TextDrawFont(Store_Frame[26], 5);
	TextDrawSetProportional(Store_Frame[26], 0);
	TextDrawSetShadow(Store_Frame[26], 0);
	TextDrawSetSelectable(Store_Frame[26], true);
	TextDrawSetPreviewModel(Store_Frame[26], 0);
	TextDrawSetPreviewRot(Store_Frame[26], 0.000000, 0.000000, 0.000000, -1.000000);

	Store_Frame[27] = TextDrawCreate(229.092193, 185.916687, "Flowers");
	TextDrawLetterSize(Store_Frame[27], 0.256163, 1.407499);
	TextDrawAlignment(Store_Frame[27], 1);
	TextDrawColor(Store_Frame[27], -1);
	TextDrawSetShadow(Store_Frame[27], 0);
	TextDrawSetOutline(Store_Frame[27], 1);
	TextDrawBackgroundColor(Store_Frame[27], 255);
	TextDrawFont(Store_Frame[27], 1);
	TextDrawSetProportional(Store_Frame[27], 1);
	TextDrawSetShadow(Store_Frame[27], 0);

	Store_Frame[28] = TextDrawCreate(313.426177, 185.333358, "Cane");
	TextDrawLetterSize(Store_Frame[28], 0.256163, 1.407499);
	TextDrawAlignment(Store_Frame[28], 1);
	TextDrawColor(Store_Frame[28], -1);
	TextDrawSetShadow(Store_Frame[28], 0);
	TextDrawSetOutline(Store_Frame[28], 1);
	TextDrawBackgroundColor(Store_Frame[28], 255);
	TextDrawFont(Store_Frame[28], 1);
	TextDrawSetProportional(Store_Frame[28], 1);
	TextDrawSetShadow(Store_Frame[28], 0);

	Store_Frame[29] = TextDrawCreate(396.823181, 184.750015, "Camera");
	TextDrawLetterSize(Store_Frame[29], 0.256163, 1.407499);
	TextDrawAlignment(Store_Frame[29], 1);
	TextDrawColor(Store_Frame[29], -1);
	TextDrawSetShadow(Store_Frame[29], 0);
	TextDrawSetOutline(Store_Frame[29], 1);
	TextDrawBackgroundColor(Store_Frame[29], 255);
	TextDrawFont(Store_Frame[29], 1);
	TextDrawSetProportional(Store_Frame[29], 1);
	TextDrawSetShadow(Store_Frame[29], 0);
}

stock PlayerCache_GetFree(playerid)
{
	for(new i = 0; i < 10; i ++)
	{
		if(!PlayerInfo[playerid][ItemCache][i])
			return i+1;
	}
	return -1;
}

stock ShowShopList(playerid, bool:toggle)
{
	new
		id = IsPlayerInBusiness(playerid),
		str[90]
	;
	
	if(toggle)
	{
	    SelectTextDraw(playerid, COLOR_GREY);
	    for(new x; x < 10; x ++)
	    {
	        TextDrawShowForPlayer(playerid, Store_UI[x]);
	        PlayerInfo[playerid][ItemCache][x] = -1;
	    }
	    for(new i; i < 30; i ++)
	    {
			TextDrawShowForPlayer(playerid, Store_Frame[i]);
	    }
	    new maskid[24];
	    format(maskid, 24, "Mask~n~[%d_%d]", PlayerInfo[playerid][pMaskID][0], PlayerInfo[playerid][pMaskID][1]);
	    PlayerTextDrawSetString(playerid, Store_Mask[playerid], maskid);
		format(str, sizeof(str), "%s", BusinessInfo[id][eBusinessName]);
		PlayerTextDrawSetString(playerid, Store_Business[playerid], str);
	    PlayerTextDrawShow(playerid, Store_Mask[playerid]);
	    PlayerTextDrawShow(playerid, Store_Cart[playerid]);
	    PlayerTextDrawShow(playerid, Store_Business[playerid]);
	    SetPVarInt(playerid, "PriceCount", 0);
	    SetPVarInt(playerid, "UI_Purchase", 1);
	}
	else
	{
	    for(new x; x < 10; x ++)
	    {
	        TextDrawHideForPlayer(playerid, Store_UI[x]);
	    }
	    for(new i; i < 30; i ++)
	    {
			TextDrawHideForPlayer(playerid, Store_Frame[i]);
	    }
	    PlayerTextDrawHide(playerid, Store_Mask[playerid]);
	    PlayerTextDrawHide(playerid, Store_Cart[playerid]);
	    PlayerTextDrawHide(playerid, Store_Business[playerid]);
	    SetPVarInt(playerid, "UI_Purchase", 0);
	}
	return 1;
}

stock ReturnItemPrice(itemid)
{
	switch(itemid)
	{
	    case 0:
			return 500;
	    case 1:
	        return 10000;
	    case 2:
	        return 1500;
	    case 3:
     		return 500;
	    case 4:
     		return 200;
		case 5:
     		return 500;
		case 6:
     		return 5000;
		case 7:
     		return 200;
		case 8:
     		return 500;
		case 9:
     		return 3000;
	}
	return 1;
}

stock OnPlayerPurchaseItem(playerid, type)
{
	switch(type)
	{
	    case 0: PlayerInfo[playerid][pGascan]++;
	    case 1: PlayerInfo[playerid][pBoombox] = true;
	    case 2: GivePlayerGun(playerid, 5, 1);
	    case 3: GivePlayerGun(playerid, 14, 1);
	    case 4: GivePlayerGun(playerid, 15, 1);
		case 5: GivePlayerGun(playerid, 43, 9999);
		case 6: PlayerInfo[playerid][pHasMask] = true;
		case 7: SetPlayerSpecialAction(playerid, SPECIAL_ACTION_DRINK_SPRUNK); // add this into /pitems system
		case 8: SetPlayerSpecialAction(playerid, SPECIAL_ACTION_SMOKE_CIGGY); // add this into /pitems system
		case 9: PlayerInfo[playerid][pHasRadio] = true;
	}
	return 1;
}

public OnPlayerClickTextDraw(playerid, Text:clickedid)
{
	if(GetPVarInt(playerid, "UI_Purchase"))
	{
	    new index_id = PlayerCache_GetFree(playerid);
	    for(new x = 0; x < 10; x ++)
	    {
	        if(clickedid == Store_UI[x])
	        {
	            if(PlayerCache_GetFree(playerid))
	            {
	            	PlayerInfo[playerid][ItemCache][index_id] = x;
	            	SetPVarInt(playerid, "PriceCount", GetPVarInt(playerid, "PriceCount") + ReturnItemPrice(x));
					if(PlayerInfo[playerid][ItemCache][x])
					{
					    if(GetPVarInt(playerid, "PriceCount") - ReturnItemPrice(PlayerInfo[playerid][ItemCache][index_id]) > 0)
					    {
					    	SetPVarInt(playerid, "PriceCount", GetPVarInt(playerid, "PriceCount") - ReturnItemPrice(PlayerInfo[playerid][ItemCache][index_id]));
						}
						else
						{
						    SetPVarInt(playerid, "PriceCount", 0);
						}
						PlayerInfo[playerid][ItemCache][index_id] = -1;
					}
				}
				new price[24];
				format(price, 24, "~g~$%s", MoneyFormat(GetPVarInt(playerid, "PriceCount")));
				PlayerTextDrawSetString(playerid, Store_Cart[playerid], price);
	        }
	    }
	    if(clickedid == Store_Frame[24])
	    {
	        CancelSelectTextDraw(playerid);
			ShowShopList(playerid, false);
	    }
	    if(clickedid == Store_Frame[19])
	    {
	        printf("pruchase");
	        if(!GetPVarInt(playerid, "PriceCount")) return PlayerTextDrawSetString(playerid, Store_Cart[playerid], "~r~EMPTY");
	        if(PlayerInfo[playerid][pMoney] < GetPVarInt(playerid, "PriceCount")) return SendErrorMessage(playerid, "You don't have that money! Total: $%d", GetPVarInt(playerid, "PriceCount"));
			for(new i = 0; i < 10; i ++)
			{
                OnPlayerPurchaseItem(playerid, i);
                PlayerInfo[playerid][ItemCache][i] = -1;
			}
			GiveMoney(playerid, -GetPVarInt(playerid, "PriceCount"));
			DeletePVar(playerid, "PriceCount");
	    }
	    if(clickedid == Store_Frame[26])
	    {
	        printf("empty");
			for(new i = 0; i < 10; i ++)
			{
                PlayerInfo[playerid][ItemCache][i] = -1;
			}
			PlayerTextDrawSetString(playerid, Store_Cart[playerid], "~r~EMPTY");
			DeletePVar(playerid, "PriceCount");
	    }
	}
	if(GetPVarInt(playerid, "UsePayphone") == 1)
	{
		if(clickedid == PP_Framework[2])
		{
			if(PlayerInfo[playerid][pCalling] > 0) return 1;
		    new hour, minute, second, str[64];
			gettime(hour, minute, second);
			format(str, sizeof(str), "%02d:%02d", hour, minute);
		    PlayerTextDrawSetString(playerid, PP_Btn[playerid][0], str);
	  		PlayerInfo[playerid][pNumberStr] = EOS;
	  		return 1;
		}
		if(clickedid == PP_Framework[8])
		{
			for(new i = 0; i < 15; i ++) TextDrawHideForPlayer(playerid, PP_Framework[i]);
			for(new g = 0; g < 11; g ++) PlayerTextDrawHide(playerid, PP_Btn[playerid][g]);
			for(new e = 0; e < 4; e ++) PlayerTextDrawHide(playerid, NumberLetters[playerid][e]);
			CancelSelectTextDraw(playerid);
			DeletePVar(playerid, "UsePayphone");
			return HangupCall(playerid);
		}
		if(clickedid == PP_Framework[7])
		{
		    if(PlayerInfo[playerid][pMoney] < 2) return SendClientMessage(playerid, COLOR_LIGHTRED, "ERROR: You need $2 in your hand.");
			if(PlayerInfo[playerid][pCalling] > 0) return SendClientMessage(playerid, COLOR_LIGHTRED, "ERROR: You are in a call!");
			if(strval(PlayerInfo[playerid][pNumberStr]) < 100 || strval(PlayerInfo[playerid][pNumberStr]) > 9999999) return SendClientMessage(playerid, COLOR_LIGHTRED, "Wrong number.");
		    PlayerTextDrawSetString(playerid, PP_Btn[playerid][0], "Calling..");
		    //callcmd::call(playerid, PlayerInfo[playerid][pNumberStr]);
			CallNumber(playerid, PlayerInfo[playerid][pNumberStr], GetPVarInt(playerid, "ThisPayphone"));
		    PlayerInfo[playerid][pNumberStr] = EOS;
		    DeletePVar(playerid, "ThisPayphone");
		    return 1;
		}
	}
    if(_:clickedid == INVALID_TEXT_DRAW)
    {
        if(PlayerInfo[playerid][pViewingDealership])
        {
            HideDealershipPreview(playerid);
            return 1;
        }
        if(GetPVarInt(playerid, "Viewing_OwnedCarList"))
        {
            for(new i = 0; i < 6; i ++)
            {
				PlayerTextDrawHide(playerid, Player_Vehicles_Name[playerid][i]);
				PlayerTextDrawHide(playerid, Player_Vehicles[playerid][i]);
            }
            for(new x = 0; x < 3; x++) PlayerTextDrawHide(playerid, Player_Vehicles_Arrow[playerid][x]);
			PlayerTextDrawHide(playerid, Player_Static_Arrow[playerid]);
			SetPVarInt(playerid, "Viewing_OwnedCarList", 0);
            return 1;
        }
		if(GetPVarInt(playerid, "UI_Purchase"))
		{
        	ShowShopList(playerid, false);
        	return 1;
        }
        if(GetPVarInt(playerid, "UsePayphone") == 1)
        {
			if(PlayerInfo[playerid][pCalling] > 0)
			{
			    return SelectTextDraw(playerid, COLOR_GREY);
			}
			for(new i = 0; i < 15; i ++) TextDrawHideForPlayer(playerid, PP_Framework[i]);
			for(new g = 0; g < 11; g ++) PlayerTextDrawHide(playerid, PP_Btn[playerid][g]);
			for(new e = 0; e < 4; e ++) PlayerTextDrawHide(playerid, NumberLetters[playerid][e]);
			DeletePVar(playerid, "UsePayphone");
    		return 1;
    	}
        if(PlayerInfo[playerid][pSelection] == EVENT_FOODMENU)
        {
    		ShowFoodMenu(playerid, false);
    		return 1;
    	}
	    if(GetPVarInt(playerid, "ColorSelect") != 0)
		{
		    DisplayColors(playerid, false);
			return ShowDealerAppend(playerid);
		}
    }
	return 0;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
    if(GetPVarInt(playerid, "BrokenLeg") && GetPlayerState(playerid) == PLAYER_STATE_ONFOOT)
    {
		if(newkeys & KEY_JUMP && !(oldkeys & KEY_JUMP))
		{
			ApplyAnimation(playerid, "GYMNASIUM", "gym_jog_falloff",4.1,0,1,1,0,0);
			ApplyAnimation(playerid, "GYMNASIUM", "gym_jog_falloff",4.1,0,1,1,0,0);
		}

	}
    if(GetPVarInt(playerid, "Mechanic_ID") != INVALID_PLAYER_ID && GetPVarInt(playerid, "Mechanic_Type") > 0)
    {
        new id = GetPVarInt(playerid, "Mechanic_ID");
		new TYPE = GetPVarInt(playerid, "Mechanic_Type");
		new vehicle = GetPlayerVehicleID(playerid);
		new string[128];
        if(PRESSED(KEY_YES))
        {
			PlayerInfo[id][InMission] = TYPE;
			PlayerInfo[id][MissionTarget][0] = playerid;
			PlayerInfo[id][MissionTarget][1] = vehicle;
			//PlayerInfo[id][MissionExtra] = GetPlayerVehicleID(id);
			//PlayerInfo[id][MissionTime] = CountMechanicJob(id);
	        format(string, 128, "~g~%s~p~_HAS_ACCEPTED_YOUR_OFFER.", ReturnName(playerid));
   			PlayerTextDrawSetString(id, PlayerOffer[id], string);
	        format(string, 128, "~p~YOU_HAVE_ACCEPTED_~g~%s~p~'s_OFFER!", ReturnName(id));
   			PlayerTextDrawSetString(playerid, PlayerOffer[playerid], string);
   			SetTimerEx("OnJobMessageSent", 5000, false, "i", playerid);
   			PlayerTextDrawSetString(id, PlayerOffer[id], "~h~~p~PULL OUT YOUR SPRAYCAN.");
   			
			SetPVarInt(playerid, "Mechanic_ID", INVALID_PLAYER_ID);
			SetPVarInt(playerid, "Mechanic_Type", -1);

        }
        if(PRESSED(KEY_NO))
        {
	        format(string, 128, "~g~%s~p~_HAS_REFUSED_YOUR_OFFER.", ReturnName(playerid));
   			PlayerTextDrawSetString(id, PlayerOffer[id], string);
	        format(string, 128, "~p~YOU_HAVE_REFUSED_~g~%s~p~'s_OFFER!", ReturnName(id));
   			PlayerTextDrawSetString(playerid, PlayerOffer[playerid], string);
   			
			SetPVarInt(playerid, "Mechanic_ID", INVALID_PLAYER_ID);
			SetPVarInt(playerid, "Mechanic_Type", -1);
        }
    }
	if(PlayerInfo[playerid][pInTuning])
 	{
  		new string[64];
		new vehID = GetPlayerVehicleID(playerid);
		new categoryTuning = PlayerInfo[playerid][pTuningCategoryID];

		if(newkeys & KEY_LOOK_RIGHT || newkeys & KEY_LOOK_LEFT)
		{
			PlayerInfo[playerid][pTuningCategoryID] = (newkeys & KEY_LOOK_RIGHT) ? categoryTuning + 1 : categoryTuning - 1;

			if(PlayerInfo[playerid][pTuningCategoryID] > 10)PlayerInfo[playerid][pTuningCategoryID] = 10;
			if(PlayerInfo[playerid][pTuningCategoryID] < 0)PlayerInfo[playerid][pTuningCategoryID] = 0;

			categoryTuning = PlayerInfo[playerid][pTuningCategoryID];

			if(categoryTuning != 0 && categoryTuning != 10)
			{
	  			format(string, sizeof(string), "~y~%s~w~ (~<~) %s (~>~)~y~ %s", TuningCategories[categoryTuning - 1], TuningCategories[categoryTuning], TuningCategories[categoryTuning + 1]);
	     		PlayerTextDrawSetString(playerid, TDTuning_Component[playerid], string);
				PlayerTextDrawShow(playerid, TDTuning_Component[playerid]);
			}
	        else
	        {
				format(string, sizeof(string), (!categoryTuning) ? ("%s (~>~)~y~ %s") : ("~y~%s~w~ (~>~) %s"), TuningCategories[(newkeys & KEY_LOOK_RIGHT) ? categoryTuning - 1 : categoryTuning], TuningCategories[(newkeys & KEY_LOOK_RIGHT) ? categoryTuning : categoryTuning + 1]);
				PlayerTextDrawSetString(playerid, TDTuning_Component[playerid], string);
				PlayerTextDrawShow(playerid, TDTuning_Component[playerid]);
			}

			Tuning_SetDisplay(playerid);
		}
		else if(newkeys & KEY_FIRE || newkeys & KEY_HANDBRAKE)
		{
		    new validCount = GetVehicleComponentCount(categoryTuning, VehicleInfo[vehID][eVehicleModel]);
		    new tuningCount = PlayerInfo[playerid][pTuningCount];

		    if(tuningCount && (newkeys & KEY_FIRE && tuningCount != validCount) || (newkeys & KEY_HANDBRAKE && tuningCount != 0 && tuningCount != 1) && validCount)
		    {
			    PlayerInfo[playerid][pTuningCount] = (newkeys & KEY_FIRE) ? tuningCount + 1 : tuningCount - 1;
                Tuning_SetDisplay(playerid, PlayerInfo[playerid][pTuningCount]);
			}
			else return 1;
		}
		else if(newkeys & KEY_YES)
		{
			if(!PlayerInfo[playerid][pTuningCount])return
				SendServerMessage(playerid, "You have not selected any car parts.");

		    new componentPrice = (categoryTuning == 10) ? 2500 : GetComponentPrice(PlayerInfo[playerid][pTuningComponent]);

			if(componentPrice > PlayerInfo[playerid][pMoney]) return
			 	SendServerMessage(playerid, "You don't have enough money.");

		 	GiveMoney(playerid, -componentPrice);

			if(categoryTuning == 10)
			{
   				ChangeVehiclePaintjob(vehID, PlayerInfo[playerid][pTuningComponent]);
	            VehicleInfo[vehID][eVehiclePaintjob] = PlayerInfo[playerid][pTuningComponent];
	            SaveVehicle(vehID);
			}
			else Tuning_AddComponent(vehID, PlayerInfo[playerid][pTuningComponent]);

			PlayerPlaySound(playerid, 1134, 0, 0, 0);
		}
		else if(newkeys & KEY_NO) Tuning_ExitDisplay(playerid);
	}

    if(VehicleInfo[GetPVarInt(playerid, "Breakin_ID")][ePhysicalAttack] && RELEASED(KEY_FIRE) && GetPlayerState(playerid) == PLAYER_STATE_ONFOOT && !VehicleInfo[GetPVarInt(playerid, "Breakin_ID")][vCooldown])
    {
		new weaponid = GetPlayerWeapon(playerid);
		new vehicleid = GetPVarInt(playerid, "Breakin_ID");
		if(IsValidVehicle(vehicleid))
		{
			new Float:cX, Float:cY, Float:cZ;
			new Float:dX, Float:dY, Float:dZ, Float: playerHealth;
			
			GetPlayerHealth(playerid, playerHealth);
			GetVehicleModelInfo(VehicleInfo[vehicleid][eVehicleModel], VEHICLE_MODEL_INFO_FRONTSEAT, cX, cY, cZ);
			GetVehicleRelativePos(vehicleid, dX, dY, dZ, -cX - 0.5, cY, cZ);
			
			if(GetVehicleDriver(vehicleid) != -1 || VehicleInfo[vehicleid][eDoorHealth] <= 0.0 || !IsPlayerInRangeOfPoint(playerid, 1.2, dX, dY, dZ)) return 1;
			
		    switch(VehicleInfo[vehicleid][eDoorEffect])
		    {
		        case LESS_DAMAGE_FIST:
		        {
		            if(weaponid == 0)
		            {
		                VehicleInfo[vehicleid][eDoorHealth] = (VehicleInfo[vehicleid][eDoorHealth] - 1 <= 0) ? 0 : VehicleInfo[vehicleid][eDoorHealth] - 1;
		                if(playerHealth > 10.0)
		                {
		                    SetPlayerHealth(playerid, playerHealth - 10.0);
		                }
		            }
		            if(weaponid >= 1 && weaponid <= 9)
		            {
		                VehicleInfo[vehicleid][eDoorHealth] = (VehicleInfo[vehicleid][eDoorHealth] - 10 <= 0) ? 0 : VehicleInfo[vehicleid][eDoorHealth] - 10;
		            }
		          	if(weaponid >= 22 && weaponid <= 24)
		            {
		                VehicleInfo[vehicleid][eDoorHealth] = (VehicleInfo[vehicleid][eDoorHealth] - 15 <= 0) ? 0 : VehicleInfo[vehicleid][eDoorHealth] - 15;
              		}
		          	if(weaponid >= 25 && weaponid <= 33)
		            {
		                VehicleInfo[vehicleid][eDoorHealth] = (VehicleInfo[vehicleid][eDoorHealth] - 30 <= 0) ? 0 : VehicleInfo[vehicleid][eDoorHealth] - 30;
		            }
		        }
		        case BLOCK_FIST:
		        {
		            if(weaponid >= 1 && weaponid <= 9)
		            {
		                VehicleInfo[vehicleid][eDoorHealth] = (VehicleInfo[vehicleid][eDoorHealth] - 10 <= 0) ? 0 : VehicleInfo[vehicleid][eDoorHealth] - 10;
		            }
		          	if(weaponid >= 22 && weaponid <= 24)
		            {
		                VehicleInfo[vehicleid][eDoorHealth] = (VehicleInfo[vehicleid][eDoorHealth] - 15 <= 0) ? 0 : VehicleInfo[vehicleid][eDoorHealth] - 15;
		            }
		        }
		        case LESS_DAMAGE_MELEE:
		        {
		          	if(weaponid >= 22 && weaponid <= 24)
		            {
		                VehicleInfo[vehicleid][eDoorHealth] = (VehicleInfo[vehicleid][eDoorHealth] - 5 <= 0) ? 0 : VehicleInfo[vehicleid][eDoorHealth] - 5;
		            }
		          	if(weaponid >= 25 && weaponid <= 33)
		            {
		                VehicleInfo[vehicleid][eDoorHealth] = (VehicleInfo[vehicleid][eDoorHealth] - 20 <= 0) ? 0 : VehicleInfo[vehicleid][eDoorHealth] - 20;
		            }
		        }
		        case BLOCK_PHYSICAL:
		        {
		          	if(weaponid >= 25 && weaponid <= 33)
		            {
		                VehicleInfo[vehicleid][eDoorHealth] = (VehicleInfo[vehicleid][eDoorHealth] - 30 <= 0) ? 0 : VehicleInfo[vehicleid][eDoorHealth] - 30;
		            }
		        }
		        default:
		        {
		            if(weaponid == 0)
		            {
		                VehicleInfo[vehicleid][eDoorHealth] = (VehicleInfo[vehicleid][eDoorHealth] - 2 <= 0) ? 0 : VehicleInfo[vehicleid][eDoorHealth] - 2;
		                SetPlayerHealth(playerid, playerHealth - 5.0);
		            }
		            if(weaponid >= 1 && weaponid <= 9)
		            {
		                VehicleInfo[vehicleid][eDoorHealth] = (VehicleInfo[vehicleid][eDoorHealth] - 10 <= 0) ? 0 : VehicleInfo[vehicleid][eDoorHealth] - 10;
		            }
		          	if(weaponid >= 22 && weaponid <= 24)
		            {
		                VehicleInfo[vehicleid][eDoorHealth] = (VehicleInfo[vehicleid][eDoorHealth] - 15 <= 0) ? 0 : VehicleInfo[vehicleid][eDoorHealth] - 15;
		            }
		          	if(weaponid >= 25 && weaponid <= 33)
		            {
		                VehicleInfo[vehicleid][eDoorHealth] = (VehicleInfo[vehicleid][eDoorHealth] - 30 <= 0) ? 0 : VehicleInfo[vehicleid][eDoorHealth] - 30;
		            }
				}
			}
			new engine, lights, alarm, doors, bonnet, boot, objective, panels, tires;
			new statusString[90];
			GetVehicleDamageStatus(vehicleid, panels, doors, lights, tires);
			switch(VehicleInfo[vehicleid][eDoorHealth])
			{
			
				case 0: UpdateVehicleDamageStatus(vehicleid, panels, encode_doors(0, 0, 4, 0, 0, 0), lights, tires);
				case 1 .. 20: UpdateVehicleDamageStatus(vehicleid, panels, encode_doors(0, 0, 2, 0, 0, 0), lights, tires);
			}
			new doorhealth[12];
			format(doorhealth, 12, "%d", VehicleInfo[vehicleid][eDoorHealth]);
			UpdateDynamic3DTextLabelText(VehicleInfo[vehicleid][eVehicleLabel], COLOR_WHITE, doorhealth);
			VehicleInfo[vehicleid][vCooldown] = true;
			SetTimerEx("OnCoolDown", 1000, false, "i", vehicleid);
			//ToggleVehicleAlarms(vehicleid, true);
			sendMessage(playerid, -1, "%d", VehicleInfo[vehicleid][eDoorHealth]);
			if(VehicleInfo[vehicleid][eDoorHealth] <= 0)
			{
			    DestroyDynamic3DTextLabel(VehicleInfo[vehicleid][eVehicleLabel]);
			    VehicleInfo[vehicleid][vCooldown] = false;
			    VehicleInfo[GetPVarInt(playerid, "Breakin_ID")][ePhysicalAttack] = false;
			    VehicleInfo[vehicleid][eDoorHealth] = 0;
			    format(statusString, sizeof(statusString), "~g~%s UNLOCKED", ReturnVehicleName(vehicleid));
			    GameTextForPlayer(playerid, statusString, 3000, 3);
				GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
				SetVehicleParamsEx(vehicleid, engine, lights, alarm, false, bonnet, boot, objective);
				VehicleInfo[vehicleid][eVehicleLocked] = false;
				SetPVarInt(playerid, "Breakin_ID", INVALID_VEHICLE_ID);
			}
		}
    }
	if(HOLDING(KEY_HANDBRAKE) && PRESSED(KEY_WALK))
	{
	    if(GetPVarInt(playerid, "MDCLayout"))
	    {
	        SelectTextDraw(playerid, COLOR_GREY);
	    }
	}
	if(PRESSED(KEY_FIRE))
	{
        if(PlayerInfo[playerid][pSprayAllow] && GetPlayerWeapon(playerid) == 41 && PlayerInfo[playerid][pSprayTarget] == GetPlayerNearestTag(playerid))
        {
            KillTimer(PlayerInfo[playerid][pSprayTimer][1]);
            PlayerInfo[playerid][pSprayTimer][0] = SetTimerEx("SprayListener", 1000, true, "ii", playerid, THREAD_GRAFFITI);
        }
	}
	if(RELEASED(KEY_FIRE))
	{
        if(PlayerInfo[playerid][pSprayAllow] && GetPlayerWeapon(playerid) == 41 && PlayerInfo[playerid][pSprayTarget] == GetPlayerNearestTag(playerid))
        {
            KillTimer(PlayerInfo[playerid][pSprayTimer][0]);
            PlayerInfo[playerid][pSprayPoint] --;
            GameTextForPlayer(playerid, "~g~Keep spraying!", 5000, 5);
            PlayerInfo[playerid][pSprayTimer][1] = SetTimerEx("SprayListener", 20000, true, "ii", playerid, THREAD_KILL);
        }
	}
	if (newkeys & KEY_SPRINT)
	{
	    if (PlayerInfo[playerid][pAnimation])
	    {
			PlayerInfo[playerid][pAnimation] = 0;
			ApplyAnimation(playerid, "CARRY", "crry_prtial", 4.0, 0, 0, 0, 0, 0);
		}
	}
	
    if(HOLDING(KEY_JUMP) && HOLDING(KEY_SPRINT))
    {
		if(IsPlayerInAnyVehicle(playerid))
		{
		    new vehicleid = GetPlayerVehicleID(playerid);

		    if(VehicleInfo[vehicleid][eVehicleTweak])
		    {
		        if(gettime() - VehicleInfo[vehicleid][eVehicleRev] < 60)
		        {
			        PlayerInfo[playerid][TempTweak] ++;
					PlayNearbySound(playerid, 11200);
					if(PlayerInfo[playerid][TempTweak] >= 20)
					{
					    new rand = random(3);
					    if(rand != 0)
					    {
						    VehicleInfo[vehicleid][eVehicleTweak] = false;
						    PlayerInfo[playerid][TempTweak] = 0;
						    VehicleInfo[vehicleid][eVehicleRev] = 0;
							SendNearbyMessage(playerid, 20.0, COLOR_EMOTE, "* %s started the engine of the %s.", ReturnName(playerid, 0), ReturnVehicleName(vehicleid));
							ToggleVehicleEngine(vehicleid, true); VehicleInfo[vehicleid][eVehicleEngineStatus] = true;
						}
						else
						{
						    GameTextForPlayer(playerid, "~r~ENGINE COULDN'T STARTED~n~~w~Try it again!", 3000, 4);
						    PlayerInfo[playerid][TempTweak] = 0;
						    VehicleInfo[vehicleid][eVehicleRev] = 0;
						}
					}
				}
	    	}
    	}
	}
    if(RELEASED(KEY_JUMP) && RELEASED(KEY_SPRINT))
    {
        if(IsPlayerInAnyVehicle(playerid))
        {
            if(VehicleInfo[ GetPlayerVehicleID(playerid) ][eVehicleTweak])
            {
                PlayerInfo[playerid][TempTweak] = 0;
            }
        }
    }
 	return 1;
}

stock randomEx(min, max)
{
    return random(max - min) + min;
}

stock GetPlayerIDFromName(playername[])
{
	for(new i = 0; i <= MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i))
		{
			new playername2[MAX_PLAYER_NAME];
			GetPlayerName(i, playername2, sizeof(playername2));
			if(strcmp(playername2, playername, true, strlen(playername)) == 0)
			{
				return i;
			}
		}
	}
	return INVALID_PLAYER_ID;
}

stock Init_SpeedText(playerid)
{
	Player_Hud[playerid][0] = CreatePlayerTextDraw(playerid, 524.729553, 383.083496, "Landstalker");
	PlayerTextDrawLetterSize(playerid, Player_Hud[playerid][0], 0.495577, 3.367500);
	PlayerTextDrawAlignment(playerid, Player_Hud[playerid][0], 2);
	PlayerTextDrawColor(playerid, Player_Hud[playerid][0], 255);
	PlayerTextDrawSetShadow(playerid, Player_Hud[playerid][0], 0);
	PlayerTextDrawSetOutline(playerid, Player_Hud[playerid][0], 1);
	PlayerTextDrawBackgroundColor(playerid, Player_Hud[playerid][0], -2139062017);
	PlayerTextDrawFont(playerid, Player_Hud[playerid][0], 2);
	PlayerTextDrawSetProportional(playerid, Player_Hud[playerid][0], 1);
	PlayerTextDrawSetShadow(playerid, Player_Hud[playerid][0], 0);

	Player_Hud[playerid][1] = CreatePlayerTextDraw(playerid, 590.322448, 413.416870, "~w~0   ~l~0   ~w~1000   ~l~100");
	PlayerTextDrawLetterSize(playerid, Player_Hud[playerid][1], 0.406558, 2.649996);
	PlayerTextDrawAlignment(playerid, Player_Hud[playerid][1], 3);
	PlayerTextDrawColor(playerid, Player_Hud[playerid][1], 255);
	PlayerTextDrawSetShadow(playerid, Player_Hud[playerid][1], 0);
	PlayerTextDrawSetOutline(playerid, Player_Hud[playerid][1], 1);
	PlayerTextDrawBackgroundColor(playerid, Player_Hud[playerid][1], -2139062017);
	PlayerTextDrawFont(playerid, Player_Hud[playerid][1], 2);
	PlayerTextDrawSetProportional(playerid, Player_Hud[playerid][1], 1);
	PlayerTextDrawSetShadow(playerid, Player_Hud[playerid][1], 0);

	Player_Hud[playerid][2] = CreatePlayerTextDraw(playerid, 494.275604, 162.583328, "~bl~Radio_Info");
	PlayerTextDrawLetterSize(playerid, Player_Hud[playerid][2], 0.446852, 1.454165);
	PlayerTextDrawAlignment(playerid, Player_Hud[playerid][2], 1);
	PlayerTextDrawColor(playerid, Player_Hud[playerid][2], -1);
	PlayerTextDrawSetShadow(playerid, Player_Hud[playerid][2], 2);
	PlayerTextDrawSetOutline(playerid, Player_Hud[playerid][2], 0);
	PlayerTextDrawBackgroundColor(playerid, Player_Hud[playerid][2], 255);
	PlayerTextDrawFont(playerid, Player_Hud[playerid][2], 3);
	PlayerTextDrawSetProportional(playerid, Player_Hud[playerid][2], 1);
	PlayerTextDrawSetShadow(playerid, Player_Hud[playerid][2], 2);

	Player_Hud[playerid][3] = CreatePlayerTextDraw(playerid, 497.086761, 180.083251, "~bl~chan:~n~slot:");
	PlayerTextDrawLetterSize(playerid, Player_Hud[playerid][3], 0.459502, 1.302499);
	PlayerTextDrawAlignment(playerid, Player_Hud[playerid][3], 1);
	PlayerTextDrawColor(playerid, Player_Hud[playerid][3], -1);
	PlayerTextDrawSetShadow(playerid, Player_Hud[playerid][3], 2);
	PlayerTextDrawSetOutline(playerid, Player_Hud[playerid][3], 0);
	PlayerTextDrawBackgroundColor(playerid, Player_Hud[playerid][3], 255);
	PlayerTextDrawFont(playerid, Player_Hud[playerid][3], 3);
	PlayerTextDrawSetProportional(playerid, Player_Hud[playerid][3], 1);
	PlayerTextDrawSetShadow(playerid, Player_Hud[playerid][3], 2);

	Player_Hud[playerid][4] = CreatePlayerTextDraw(playerid, 551.435241, 180.666610, "~g~0~n~0");
	PlayerTextDrawLetterSize(playerid, Player_Hud[playerid][4], 0.459970, 1.273333);
	PlayerTextDrawAlignment(playerid, Player_Hud[playerid][4], 1);
	PlayerTextDrawColor(playerid, Player_Hud[playerid][4], -1);
	PlayerTextDrawSetShadow(playerid, Player_Hud[playerid][4], 2);
	PlayerTextDrawSetOutline(playerid, Player_Hud[playerid][4], 0);
	PlayerTextDrawBackgroundColor(playerid, Player_Hud[playerid][4], 255);
	PlayerTextDrawFont(playerid, Player_Hud[playerid][4], 3);
	PlayerTextDrawSetProportional(playerid, Player_Hud[playerid][4], 1);
	PlayerTextDrawSetShadow(playerid, Player_Hud[playerid][4], 2);

	Player_Hud[playerid][5] = CreatePlayerTextDraw(playerid, 497.086730, 127.583274, "~bl~km/h:~n~fuel:");
	PlayerTextDrawLetterSize(playerid, Player_Hud[playerid][5], 0.459502, 1.302499);
	PlayerTextDrawAlignment(playerid, Player_Hud[playerid][5], 1);
	PlayerTextDrawColor(playerid, Player_Hud[playerid][5], -1);
	PlayerTextDrawSetShadow(playerid, Player_Hud[playerid][5], 2);
	PlayerTextDrawSetOutline(playerid, Player_Hud[playerid][5], 0);
	PlayerTextDrawBackgroundColor(playerid, Player_Hud[playerid][5], 255);
	PlayerTextDrawFont(playerid, Player_Hud[playerid][5], 3);
	PlayerTextDrawSetProportional(playerid, Player_Hud[playerid][5], 1);
	PlayerTextDrawSetShadow(playerid, Player_Hud[playerid][5], 2);

	Player_Hud[playerid][6] = CreatePlayerTextDraw(playerid, 552.372192, 128.166625, "~g~0~n~0");
	PlayerTextDrawLetterSize(playerid, Player_Hud[playerid][6], 0.459970, 1.273333);
	PlayerTextDrawAlignment(playerid, Player_Hud[playerid][6], 1);
	PlayerTextDrawColor(playerid, Player_Hud[playerid][6], -1);
	PlayerTextDrawSetShadow(playerid, Player_Hud[playerid][6], 2);
	PlayerTextDrawSetOutline(playerid, Player_Hud[playerid][6], 0);
	PlayerTextDrawBackgroundColor(playerid, Player_Hud[playerid][6], 255);
	PlayerTextDrawFont(playerid, Player_Hud[playerid][6], 3);
	PlayerTextDrawSetProportional(playerid, Player_Hud[playerid][6], 1);
	PlayerTextDrawSetShadow(playerid, Player_Hud[playerid][6], 2);

	Player_Hud[playerid][7] = CreatePlayerTextDraw(playerid, 597.349853, 97.250038, "~g~100__~r~9__~w~15");
	PlayerTextDrawLetterSize(playerid, Player_Hud[playerid][7], 0.532122, 2.031666);
	PlayerTextDrawAlignment(playerid, Player_Hud[playerid][7], 3);
	PlayerTextDrawColor(playerid, Player_Hud[playerid][7], -1);
	PlayerTextDrawSetShadow(playerid, Player_Hud[playerid][7], 0);
	PlayerTextDrawSetOutline(playerid, Player_Hud[playerid][7], 1);
	PlayerTextDrawBackgroundColor(playerid, Player_Hud[playerid][7], 255);
	PlayerTextDrawFont(playerid, Player_Hud[playerid][7], 3);
	PlayerTextDrawSetProportional(playerid, Player_Hud[playerid][7], 1);
	PlayerTextDrawSetShadow(playerid, Player_Hud[playerid][7], 0);

	Player_Hud[playerid][8] = CreatePlayerTextDraw(playerid, 20.131790, 152.666564, "Tahoma_~r~100_90~y~KMH/~r~92~y~MPH~n~~w~Radio_Info:~y~123~n~~w~Slot:~y~11");
	PlayerTextDrawLetterSize(playerid, Player_Hud[playerid][8], 0.245387, 1.745832);
	PlayerTextDrawAlignment(playerid, Player_Hud[playerid][8], 1);
	PlayerTextDrawColor(playerid, Player_Hud[playerid][8], -1);
	PlayerTextDrawSetShadow(playerid, Player_Hud[playerid][8], 0);
	PlayerTextDrawSetOutline(playerid, Player_Hud[playerid][8], 1);
	PlayerTextDrawBackgroundColor(playerid, Player_Hud[playerid][8], 255);
	PlayerTextDrawFont(playerid, Player_Hud[playerid][8], 1);
	PlayerTextDrawSetProportional(playerid, Player_Hud[playerid][8], 1);
	PlayerTextDrawSetShadow(playerid, Player_Hud[playerid][8], 0);
}

this::UpdatePlayerHud(playerid, vehicleid)
{
	new speed[128];
	switch(PlayerInfo[playerid][pHud])
	{
	    case 1:
	    {
	        if(IsPlayerInAnyVehicle(playerid) && GetPlayerState(playerid) == PLAYER_STATE_DRIVER && GetPlayerVehicleID(playerid) != DealershipPlayerCar[playerid])
			{
			    PlayerTextDrawShow(playerid, Player_Hud[playerid][5]);
			    PlayerTextDrawShow(playerid, Player_Hud[playerid][6]);
		        format(speed, sizeof(speed), "~g~%d~n~%d", floatround(GetVehicleSpeed(vehicleid)), floatround(VehicleInfo[vehicleid][eVehicleFuel]));
		        PlayerTextDrawSetString(playerid, Player_Hud[playerid][6], speed);

	        }
	        else
	        {
			    PlayerTextDrawHide(playerid, Player_Hud[playerid][5]);
			    PlayerTextDrawHide(playerid, Player_Hud[playerid][6]);
	        }
	        format(speed, sizeof(speed), "~g~%d~n~%d", PlayerInfo[playerid][pRadio][ PlayerInfo[playerid][pMainSlot] ], PlayerInfo[playerid][pMainSlot]);
	        PlayerTextDrawSetString(playerid, Player_Hud[playerid][4], speed);
	    }
	    case 2:
	    {
	        if(IsPlayerInAnyVehicle(playerid) && GetPlayerState(playerid) == PLAYER_STATE_DRIVER && GetPlayerVehicleID(playerid) != DealershipPlayerCar[playerid])
			{
	        	format(speed, sizeof(speed), "~g~%d__~r~%d__~w~%d", floatround(GetVehicleSpeed(vehicleid)), floatround(VehicleInfo[vehicleid][eVehicleFuel]), VehicleInfo[vehicleid][eMileage]);
	        	PlayerTextDrawSetString(playerid, Player_Hud[playerid][7], speed);
	        }
	        else
	        {
	            PlayerTextDrawHide(playerid, Player_Hud[playerid][7]);
	        }
	    }
	    case 3:
	    {
	        if(IsPlayerInAnyVehicle(playerid) && GetPlayerState(playerid) == PLAYER_STATE_DRIVER && GetPlayerVehicleID(playerid) != DealershipPlayerCar[playerid])
			{
		        format(speed, sizeof(speed), "%s_~r~%d_%d~y~KMH/~r~%d~y~MPH~n~~w~Radio_Info:~y~%d~n~~w~Slot:~y~%d",
				ReturnVehicleName(vehicleid),
				floatround(VehicleInfo[vehicleid][eVehicleFuel]),
				floatround(GetVehicleSpeed(vehicleid)),
				floatround(GetVehicleSpeed(vehicleid)) * 0.6214,
				PlayerInfo[playerid][pRadio][ PlayerInfo[playerid][pMainSlot] ],
				PlayerInfo[playerid][pMainSlot]);
				
		        PlayerTextDrawSetString(playerid, Player_Hud[playerid][8], speed);

	        }
	        else
	        {
		        format(speed, sizeof(speed), "Radio_Info:~y~%d~n~~w~Slot:~y~%d",
				PlayerInfo[playerid][pRadio][ PlayerInfo[playerid][pMainSlot] ],
				PlayerInfo[playerid][pMainSlot]);
		        PlayerTextDrawSetString(playerid, Player_Hud[playerid][8], speed);
	        }
	    }
	    case 4:
	    {
	        if(IsPlayerInAnyVehicle(playerid) && GetPlayerState(playerid) == PLAYER_STATE_DRIVER && GetPlayerVehicleID(playerid) != DealershipPlayerCar[playerid])
			{
		        new Float: carhp;
		        GetVehicleHealth(vehicleid, carhp);

		        format(speed, sizeof(speed), "%s", ReturnVehicleName(vehicleid));
		        PlayerTextDrawSetString(playerid,Player_Hud[playerid][0], speed);

		        format(speed, sizeof(speed), "~w~%d   ~l~%d   ~w~%d   ~l~%d", floatround(VehicleInfo[vehicleid][eVehicleEngine]), floatround(VehicleInfo[vehicleid][eVehicleFuel]), floatround(carhp), floatround(GetVehicleSpeed(vehicleid)));
		        PlayerTextDrawSetString(playerid,Player_Hud[playerid][1], speed);
	        }
	        else
	        {
	            PlayerTextDrawHide(playerid, Player_Hud[playerid][0]);
	            PlayerTextDrawHide(playerid, Player_Hud[playerid][1]);
	        }
	    }
	}
	VehicleInfo[vehicleid][eMileage] += (floatround(GetVehicleSpeed(vehicleid)) * 0.00009722222);
}

this::OnPlayerChangeHud(playerid)
{
	if(PlayerInfo[playerid][pUseHud])
	{
		switch(PlayerInfo[playerid][pHud])
		{
		    case 1:
		    {
				for(new i = 2; i < 5; i ++)
				{
					PlayerTextDrawShow(playerid, Player_Hud[playerid][i]);
				}
		    }
		    case 2:
		    {
	            PlayerTextDrawShow(playerid, Player_Hud[playerid][7]);
		    }
		    case 3:
		    {
				PlayerTextDrawShow(playerid, Player_Hud[playerid][8]);
		    }
		    case 4:
		    {
		        PlayerTextDrawShow(playerid, Player_Hud[playerid][0]);
		        PlayerTextDrawShow(playerid, Player_Hud[playerid][1]);
		    }
		}
	}
	return 1;
}

PlayAnimation(playerid, library[], name[], Float:speed, loop, lockx, locky, freeze, time, forcesync)
{
	ApplyAnimation(playerid, library, "null", 0.0, 0, 0, 0, 0, 0, 1);
	ApplyAnimation(playerid, library, name, speed, loop, lockx, locky, freeze, time, forcesync);

	if (loop > 0 || freeze > 0)
	{
	    PlayerInfo[playerid][pAnimation] = 1;
	}
}

IsAnimationPermitted(playerid)
{
	return (GetPlayerState(playerid) == PLAYER_STATE_ONFOOT && GetPlayerTeam(playerid) == PLAYER_STATE_ALIVE && PlayerInfo[playerid][pMeal] == -1);
}

ApplyChatAnimation(playerid, name[])
{
	if (IsPlayerInAnyVehicle(playerid))
	    ApplyAnimation(playerid, "GANGS", name, 4.1, 1, 0, 0, 0, 0, 1);
	else
	    ApplyAnimation(playerid, "GANGS", name, 4.1, 1, 1, 1, 1, 1, 1);
}

PlayChatStyle(playerid, const text[])
{
	switch (PlayerInfo[playerid][pChatstyle])
	{
	    case 1: ApplyChatAnimation(playerid, "prtial_gngtlkA");
	    case 2: ApplyChatAnimation(playerid, "prtial_gngtlkB");
	    case 3: ApplyChatAnimation(playerid, "prtial_gngtlkC");
	    case 4: ApplyChatAnimation(playerid, "prtial_gngtlkD");
	    case 5: ApplyChatAnimation(playerid, "prtial_gngtlkE");
	    case 6: ApplyChatAnimation(playerid, "prtial_gngtlkF");
	    case 7: ApplyChatAnimation(playerid, "prtial_gngtlkG");
	    case 8: ApplyChatAnimation(playerid, "prtial_gngtlkH");
		default: ApplyChatAnimation(playerid, "prtial_gngtlkC");
	}

	if (!PlayerInfo[playerid][pChatting])
	{
		SetTimerEx("StopChatting", strlen(text) * 100, false, "i", playerid);
		PlayerInfo[playerid][pChatting] = 1;
	}
}

this::StopChatting(playerid)
{
	if (PlayerInfo[playerid][pLoggedin] && PlayerInfo[playerid][pChatting] && !PlayerInfo[playerid][pAnimation])
	{
	    ApplyAnimation(playerid, "CARRY", "crry_prtial", 4.0, 0, 0, 0, 0, 0, 1);
	    ApplyAnimation(playerid, "CARRY", "crry_prtial", 4.0, 0, 0, 0, 0, 0, 1);
	}
	PlayerInfo[playerid][pChatting] = 0;
}

GetFurnitureLimit(playerid)
{
	switch (PlayerInfo[playerid][pDonator])
	{
	    case REGULAR_PLAYER:
	        return 70;
		case DONATOR_BRONZE:
		    return 150;
		case DONATOR_SILVER:
		    return 250;
		case DONATOR_GOLD:
		    return 400;
	}
	return 70;
}

GetAdLimit(playerid)
{
	switch (PlayerInfo[playerid][pDonator])
	{
	    case REGULAR_PLAYER:
	        return 1;
		case DONATOR_BRONZE:
		    return 1;
		case DONATOR_SILVER:
		    return 2;
		case DONATOR_GOLD:
		    return 3;
	}
	return 1;
}

stock ListAds(playerid)
{
    static
        gListString[256],
        count = 0
	;
        
	gListString = "#\tAdvert\tAirs In\n";
	for(new i = 1; i < MAX_ADVERT_SLOT; i++)
	{
	    if(advert_data[i][advert_exists])
	    {
			format(gListString, sizeof(gListString), "%s\n%d\t%.86s ...\t~%is", gListString, i, advert_data[i][advert_text], advert_data[i][publish_time]);
            count ++;
		}
	}
	if (count == 0) ShowPlayerDialog(playerid, DIALOG_DEFAULT, DIALOG_STYLE_MSGBOX, "View Advertisements", "There's no much thing right now.. :(", "<<", "");
	else return ShowPlayerDialog(playerid, DIALOG_DEFAULT, DIALOG_STYLE_TABLIST_HEADERS, "View Advertisements", gListString, "<<", "");
	return 0;
}

stock PlayerInQueue(playerid)
{
   	new count = 0;
	new name[MAX_PLAYER_NAME];
 	GetPlayerName(playerid, name, sizeof(name));
 	for(new i = 0; i < MAX_ADVERT_SLOT; i ++)
 	{
 	    if(strcmp(advert_data[i][advert_placeby], name, false) == 0 && advert_data[i][advert_exists]) count ++;
	}
	return count;
}

stock GetNextAdSlot()
{
	for(new i = 1; i < MAX_ADVERT_SLOT; i++)
	{
		if(!advert_data[i][advert_exists])
			return i;
	}
	return -1;
}

this::publishAdvertisement(playerid, text[], bool:personal)
{
	new new_ad = GetNextAdSlot();
	advert_data[ new_ad ][advert_id] = new_ad;
	advert_data[ new_ad ][publish_time] = new_ad * 60;
	advert_data[ new_ad ][advert_contact] = PlayerInfo[playerid][pPhone];
	format(advert_data[ new_ad ][advert_text], 256, text);
	format(advert_data[ new_ad ][advert_placeby], MAX_PLAYER_NAME, ReturnName(playerid));
	advert_data[ new_ad ][advert_exists] = true;
	advert_data[ new_ad ][in_area] = GetPlayerCityID(playerid);
	advert_data[ new_ad ][advert_type] = 1;
	if(!personal)
	{
		advert_data[ new_ad ][advert_type] = 2;
	}
	return 1;
}

stock ClearAd(ad_id)
{
	advert_data[ ad_id ][advert_id] = -1;
	advert_data[ ad_id ][publish_time] = -1;
	advert_data[ ad_id ][advert_contact] = 0;
	format(advert_data[ ad_id ][advert_text], 256, "None");
	format(advert_data[ ad_id ][advert_placeby], 32, "None");
	advert_data[ ad_id ][advert_exists] = false;
	advert_data[ ad_id ][in_area] = -1;
	advert_data[ ad_id ][advert_type] = 0;
	return 1;
}

this::PublishAds()
{
	for(new ad_id = 0; ad_id < MAX_ADVERT_SLOT; ad_id ++)
	{
	    if(advert_data[ ad_id ][advert_exists] && advert_data[ ad_id ][publish_time] != -1)
	    {
	        advert_data[ ad_id ][publish_time] --;
	        if(advert_data[ ad_id ][publish_time] == 0)
	        {
	            if( advert_data[ ad_id ][advert_type] == 1)
	            {
				    foreach(new playerid : Player)
				    {
						if(IsPlayerConnected(playerid) && ReturnCityCode(advert_data[ ad_id ][in_area]) == ReturnCityCode(GetPlayerCityID(playerid))) // if they in a same city code
						{
	                        sendMessage(playerid, COLOR_GREEN, "[Local Advertisement] %s, Ph. %i", advert_data[ ad_id ][advert_text], advert_data[ ad_id ][advert_contact]);
						}
				    }
				}
				else if( advert_data[ ad_id ][advert_type] == 2)
				{
				    SendClientMessageToAllEx(COLOR_GREEN, "[Company Advertisement] %s", advert_data[ ad_id ][advert_text]);
				}
	            ClearAd(ad_id);
	        }
	    }
	}
}

public OnPlayerEnterDynamicArea(playerid, areaid)
{
	for(new s_id = 0; s_id < MAX_STREET; s_id++)
	{
		if(areaid == street_data[s_id][area_tag])
		{
		    sendMessage(playerid, -1, "You are entering %s", street_data[s_id][street_name]);
		}
	}
	return 1;
}

public OnPlayerLeaveDynamicArea(playerid, areaid)
{
	for(new s_id = 0; s_id < MAX_STREET; s_id++)
	{
		if(areaid == street_data[s_id][area_tag])
		{
		    sendMessage(playerid, -1, "You are leaving %s", street_data[s_id][street_name]);
		}
	}
	return 1;
}

GetWeaponObjectSlot(weaponid)
{
    new objectslot;

    switch (weaponid)
    {
        case 22..24: objectslot = 0;
        case 25..27: objectslot = 1;
        case 28, 29, 32: objectslot = 2;
        case 30, 31: objectslot = 3;
        case 33, 34: objectslot = 4;
        case 35..38: objectslot = 5;
    }
    return objectslot;
}

IsWeaponWearable(weaponid)
    return (weaponid >= 22 && weaponid <= 38);

IsWeaponHideable(weaponid)
    return (weaponid >= 22 && weaponid <= 24 || weaponid == 28 || weaponid == 32);


this::OnWeaponsLoaded(playerid)
{
	new rows, fields; cache_get_data(rows, fields, this);
	new weaponid, index;
	for(new i = 0; i < rows; i++)
	{
		weaponid = cache_get_field_content_int(i, "WeaponID", this);
		index = weaponid - 22;
		
		WeaponSettings[playerid][index][Position][0] = cache_get_field_content_float(i, "PosX", this);
		WeaponSettings[playerid][index][Position][1] = cache_get_field_content_float(i, "PosY", this);
		WeaponSettings[playerid][index][Position][2] = cache_get_field_content_float(i, "PosZ", this);
		WeaponSettings[playerid][index][Position][3] = cache_get_field_content_float(i, "RotX", this);
		WeaponSettings[playerid][index][Position][4] = cache_get_field_content_float(i, "RotY", this);
		WeaponSettings[playerid][index][Position][5] = cache_get_field_content_float(i, "RotZ", this);
		
		WeaponSettings[playerid][index][Bone] = cache_get_field_content_int(i, "Bone", this);
		WeaponSettings[playerid][index][Hidden] = cache_get_field_content_int(i, "Hidden", this);
	}
}

public OnPlayerEditAttachedObject(playerid, response, index, modelid, boneid, Float:fOffsetX, Float:fOffsetY, Float:fOffsetZ, Float:fRotX, Float:fRotY, Float:fRotZ, Float:fScaleX, Float:fScaleY, Float:fScaleZ)
{
    new weaponid = EditingWeapon[playerid];

    if (weaponid)
    {
        if (response)
        {
            new enum_index = weaponid - 22, string[340];

            WeaponSettings[playerid][enum_index][Position][0] = fOffsetX;
            WeaponSettings[playerid][enum_index][Position][1] = fOffsetY;
            WeaponSettings[playerid][enum_index][Position][2] = fOffsetZ;
            WeaponSettings[playerid][enum_index][Position][3] = fRotX;
            WeaponSettings[playerid][enum_index][Position][4] = fRotY;
            WeaponSettings[playerid][enum_index][Position][5] = fRotZ;

            RemovePlayerAttachedObject(playerid, GetWeaponObjectSlot(weaponid));
            SetPlayerAttachedObject(playerid, GetWeaponObjectSlot(weaponid), ReturnWeaponsModel(weaponid), WeaponSettings[playerid][enum_index][Bone], fOffsetX, fOffsetY, fOffsetZ, fRotX, fRotY, fRotZ, 1.0, 1.0, 1.0);

            sendMessage(playerid, -1, "You have successfully adjusted the position of your %s.", ReturnWeaponName(weaponid));

            mysql_format(this, string, sizeof(string), "INSERT INTO weaponsettings (Name, WeaponID, PosX, PosY, PosZ, RotX, RotY, RotZ) VALUES ('%s', %d, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f) ON DUPLICATE KEY UPDATE PosX = VALUES(PosX), PosY = VALUES(PosY), PosZ = VALUES(PosZ), RotX = VALUES(RotX), RotY = VALUES(RotY), RotZ = VALUES(RotZ)", ReturnName(playerid), weaponid, fOffsetX, fOffsetY, fOffsetZ, fRotX, fRotY, fRotZ);
            mysql_tquery(this, string);
        }
        EditingWeapon[playerid] = 0;
    }
    return 1;
}

stock Init_PlayerTextdraws(playerid)
{

	PlayerOffer[playerid] = CreatePlayerTextDraw(playerid, 308.741638, 339.916656, "ANDREW_WANG_OFFERS_YOU_$25000_FOR_BUYING_HIS_VEHICLE_~n~_PRESS_Y_TO_CONFIRM");
	PlayerTextDrawLetterSize(playerid, PlayerOffer[playerid], 0.338623, 2.912499);
	PlayerTextDrawAlignment(playerid, PlayerOffer[playerid], 2);
	PlayerTextDrawColor(playerid, PlayerOffer[playerid], -1);
	PlayerTextDrawSetShadow(playerid, PlayerOffer[playerid], 0);
	PlayerTextDrawSetOutline(playerid, PlayerOffer[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, PlayerOffer[playerid], 255);
	PlayerTextDrawFont(playerid, PlayerOffer[playerid], 2);
	PlayerTextDrawSetProportional(playerid, PlayerOffer[playerid], 1);
	PlayerTextDrawSetShadow(playerid, PlayerOffer[playerid], 0);

	JobInfo[playerid][0] = CreatePlayerTextDraw(playerid, 97.333351, 291.629669, "TITLE");
	PlayerTextDrawLetterSize(playerid, JobInfo[playerid][0], 0.216666, 1.139555);
	PlayerTextDrawAlignment(playerid, JobInfo[playerid][0], 1);
	PlayerTextDrawColor(playerid, JobInfo[playerid][0], -1523963137);
	PlayerTextDrawSetShadow(playerid, JobInfo[playerid][0], 0);
	PlayerTextDrawSetOutline(playerid, JobInfo[playerid][0], 1);
	PlayerTextDrawBackgroundColor(playerid, JobInfo[playerid][0], 255);
	PlayerTextDrawFont(playerid, JobInfo[playerid][0], 2);
	PlayerTextDrawSetProportional(playerid, JobInfo[playerid][0], 1);
	PlayerTextDrawSetShadow(playerid, JobInfo[playerid][0], 0);

	JobInfo[playerid][1] = CreatePlayerTextDraw(playerid, 96.799972, 301.485900, "STRING");
	PlayerTextDrawLetterSize(playerid, JobInfo[playerid][1], 0.210332, 1.122962);
	PlayerTextDrawAlignment(playerid, JobInfo[playerid][1], 1);
	PlayerTextDrawColor(playerid, JobInfo[playerid][1], -1);
	PlayerTextDrawSetShadow(playerid, JobInfo[playerid][1], 0);
	PlayerTextDrawSetOutline(playerid, JobInfo[playerid][1], 1);
	PlayerTextDrawBackgroundColor(playerid, JobInfo[playerid][1], 255);
	PlayerTextDrawFont(playerid, JobInfo[playerid][1], 2);
	PlayerTextDrawSetProportional(playerid, JobInfo[playerid][1], 1);
	PlayerTextDrawSetShadow(playerid, JobInfo[playerid][1], 0);

	MDC_Layout[playerid][0] = CreatePlayerTextDraw(playerid, 519.575378, 177.166748, "box");
	PlayerTextDrawLetterSize(playerid, MDC_Layout[playerid][0], 0.000000, 1.566619);
	PlayerTextDrawTextSize(playerid, MDC_Layout[playerid][0], 615.000000, 0.000000);
	PlayerTextDrawAlignment(playerid, MDC_Layout[playerid][0], 1);
	PlayerTextDrawColor(playerid, MDC_Layout[playerid][0], -1);
	PlayerTextDrawUseBox(playerid, MDC_Layout[playerid][0], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Layout[playerid][0], -1717986982);
	PlayerTextDrawSetShadow(playerid, MDC_Layout[playerid][0], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Layout[playerid][0], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Layout[playerid][0], 1962829311);
	PlayerTextDrawFont(playerid, MDC_Layout[playerid][0], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Layout[playerid][0], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Layout[playerid][0], 0);

	MDC_Layout[playerid][1] = CreatePlayerTextDraw(playerid, 565.959411, 177.750000, "EMERGENCY_LIGHT");
	PlayerTextDrawLetterSize(playerid, MDC_Layout[playerid][1], 0.247730, 1.174165);
	PlayerTextDrawAlignment(playerid, MDC_Layout[playerid][1], 2);
	PlayerTextDrawColor(playerid, MDC_Layout[playerid][1], -1);
	PlayerTextDrawSetShadow(playerid, MDC_Layout[playerid][1], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Layout[playerid][1], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Layout[playerid][1], 255);
	PlayerTextDrawFont(playerid, MDC_Layout[playerid][1], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Layout[playerid][1], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Layout[playerid][1], 0);

	MDC_Layout[playerid][2] = CreatePlayerTextDraw(playerid, 519.106933, 202.250076, "box");
	PlayerTextDrawLetterSize(playerid, MDC_Layout[playerid][2], 0.000000, 12.623718);
	PlayerTextDrawTextSize(playerid, MDC_Layout[playerid][2], 616.000000, 0.000000);
	PlayerTextDrawAlignment(playerid, MDC_Layout[playerid][2], 1);
	PlayerTextDrawColor(playerid, MDC_Layout[playerid][2], -1);
	PlayerTextDrawUseBox(playerid, MDC_Layout[playerid][2], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Layout[playerid][2], -1717986982);
	PlayerTextDrawSetShadow(playerid, MDC_Layout[playerid][2], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Layout[playerid][2], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Layout[playerid][2], 1962829311);
	PlayerTextDrawFont(playerid, MDC_Layout[playerid][2], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Layout[playerid][2], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Layout[playerid][2], 0);

	MDC_Layout[playerid][3] = CreatePlayerTextDraw(playerid, 526.603271, 206.916717, "PRIMARY");
	PlayerTextDrawLetterSize(playerid, MDC_Layout[playerid][3], 0.153557, 1.086665);
	PlayerTextDrawAlignment(playerid, MDC_Layout[playerid][3], 1);
	PlayerTextDrawColor(playerid, MDC_Layout[playerid][3], 255);
	PlayerTextDrawSetShadow(playerid, MDC_Layout[playerid][3], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Layout[playerid][3], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Layout[playerid][3], 255);
	PlayerTextDrawFont(playerid, MDC_Layout[playerid][3], 2);
	PlayerTextDrawSetProportional(playerid, MDC_Layout[playerid][3], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Layout[playerid][3], 0);

	MDC_Layout[playerid][4] = CreatePlayerTextDraw(playerid, 576.735107, 205.166641, "~g~Off");
	PlayerTextDrawLetterSize(playerid, MDC_Layout[playerid][4], 0.217276, 1.337499);
	PlayerTextDrawAlignment(playerid, MDC_Layout[playerid][4], 1);
	PlayerTextDrawColor(playerid, MDC_Layout[playerid][4], -1523963137);
	PlayerTextDrawSetShadow(playerid, MDC_Layout[playerid][4], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Layout[playerid][4], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Layout[playerid][4], 255);
	PlayerTextDrawFont(playerid, MDC_Layout[playerid][4], 2);
	PlayerTextDrawSetProportional(playerid, MDC_Layout[playerid][4], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Layout[playerid][4], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_Layout[playerid][4], true);

	MDC_Layout[playerid][5] = CreatePlayerTextDraw(playerid, 526.603271, 225.583312, "STROBE");
	PlayerTextDrawLetterSize(playerid, MDC_Layout[playerid][5], 0.153557, 1.086665);
	PlayerTextDrawAlignment(playerid, MDC_Layout[playerid][5], 1);
	PlayerTextDrawColor(playerid, MDC_Layout[playerid][5], 255);
	PlayerTextDrawSetShadow(playerid, MDC_Layout[playerid][5], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Layout[playerid][5], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Layout[playerid][5], 255);
	PlayerTextDrawFont(playerid, MDC_Layout[playerid][5], 2);
	PlayerTextDrawSetProportional(playerid, MDC_Layout[playerid][5], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Layout[playerid][5], 0);

	MDC_Layout[playerid][6] = CreatePlayerTextDraw(playerid, 576.735107, 223.833312, "~g~Off");
	PlayerTextDrawLetterSize(playerid, MDC_Layout[playerid][6], 0.217276, 1.337499);
	PlayerTextDrawAlignment(playerid, MDC_Layout[playerid][6], 1);
	PlayerTextDrawColor(playerid, MDC_Layout[playerid][6], -1523963137);
	PlayerTextDrawSetShadow(playerid, MDC_Layout[playerid][6], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Layout[playerid][6], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Layout[playerid][6], 255);
	PlayerTextDrawFont(playerid, MDC_Layout[playerid][6], 2);
	PlayerTextDrawSetProportional(playerid, MDC_Layout[playerid][6], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Layout[playerid][6], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_Layout[playerid][6], true);

	MDC_Layout[playerid][7] = CreatePlayerTextDraw(playerid, 526.134765, 244.833312, "SEARCH");
	PlayerTextDrawLetterSize(playerid, MDC_Layout[playerid][7], 0.153557, 1.086665);
	PlayerTextDrawAlignment(playerid, MDC_Layout[playerid][7], 1);
	PlayerTextDrawColor(playerid, MDC_Layout[playerid][7], 255);
	PlayerTextDrawSetShadow(playerid, MDC_Layout[playerid][7], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Layout[playerid][7], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Layout[playerid][7], 255);
	PlayerTextDrawFont(playerid, MDC_Layout[playerid][7], 2);
	PlayerTextDrawSetProportional(playerid, MDC_Layout[playerid][7], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Layout[playerid][7], 0);

	MDC_Layout[playerid][8] = CreatePlayerTextDraw(playerid, 576.735046, 243.083282, "~g~Off");
	PlayerTextDrawLetterSize(playerid, MDC_Layout[playerid][8], 0.217276, 1.337499);
	PlayerTextDrawAlignment(playerid, MDC_Layout[playerid][8], 1);
	PlayerTextDrawColor(playerid, MDC_Layout[playerid][8], -1523963137);
	PlayerTextDrawSetShadow(playerid, MDC_Layout[playerid][8], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Layout[playerid][8], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Layout[playerid][8], 255);
	PlayerTextDrawFont(playerid, MDC_Layout[playerid][8], 2);
	PlayerTextDrawSetProportional(playerid, MDC_Layout[playerid][8], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Layout[playerid][8], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_Layout[playerid][8], true);

	MDC_Layout[playerid][9] = CreatePlayerTextDraw(playerid, 595.476196, 205.750015, "~y~Static");
	PlayerTextDrawLetterSize(playerid, MDC_Layout[playerid][9], 0.117012, 1.179999);
	PlayerTextDrawAlignment(playerid, MDC_Layout[playerid][9], 1);
	PlayerTextDrawColor(playerid, MDC_Layout[playerid][9], -1);
	PlayerTextDrawSetShadow(playerid, MDC_Layout[playerid][9], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Layout[playerid][9], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Layout[playerid][9], 255);
	PlayerTextDrawFont(playerid, MDC_Layout[playerid][9], 2);
	PlayerTextDrawSetProportional(playerid, MDC_Layout[playerid][9], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Layout[playerid][9], 0);

	MDC_Layout[playerid][10] = CreatePlayerTextDraw(playerid, 595.944580, 221.500030, "~y~Static");
	PlayerTextDrawLetterSize(playerid, MDC_Layout[playerid][10], 0.116075, 1.284999);
	PlayerTextDrawAlignment(playerid, MDC_Layout[playerid][10], 1);
	PlayerTextDrawColor(playerid, MDC_Layout[playerid][10], -1);
	PlayerTextDrawSetShadow(playerid, MDC_Layout[playerid][10], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Layout[playerid][10], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Layout[playerid][10], 255);
	PlayerTextDrawFont(playerid, MDC_Layout[playerid][10], 2);
	PlayerTextDrawSetProportional(playerid, MDC_Layout[playerid][10], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Layout[playerid][10], 0);

	MDC_Layout[playerid][11] = CreatePlayerTextDraw(playerid, 535.973937, 264.083251, "Dispatch");
	PlayerTextDrawLetterSize(playerid, MDC_Layout[playerid][11], 0.168549, 1.162497);
	PlayerTextDrawAlignment(playerid, MDC_Layout[playerid][11], 1);
	PlayerTextDrawColor(playerid, MDC_Layout[playerid][11], -1);
	PlayerTextDrawSetShadow(playerid, MDC_Layout[playerid][11], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Layout[playerid][11], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Layout[playerid][11], 255);
	PlayerTextDrawFont(playerid, MDC_Layout[playerid][11], 2);
	PlayerTextDrawSetProportional(playerid, MDC_Layout[playerid][11], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Layout[playerid][11], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_Layout[playerid][11], true);

	MDC_Layout[playerid][12] = CreatePlayerTextDraw(playerid, 532.225463, 282.166748, "box");
	PlayerTextDrawLetterSize(playerid, MDC_Layout[playerid][12], 0.000000, 2.691070);
	PlayerTextDrawTextSize(playerid, MDC_Layout[playerid][12], 609.000000, 0.000000);
	PlayerTextDrawAlignment(playerid, MDC_Layout[playerid][12], 1);
	PlayerTextDrawColor(playerid, MDC_Layout[playerid][12], -2139062017);
	PlayerTextDrawUseBox(playerid, MDC_Layout[playerid][12], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Layout[playerid][12], -1523963137);
	PlayerTextDrawSetShadow(playerid, MDC_Layout[playerid][12], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Layout[playerid][12], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Layout[playerid][12], 255);
	PlayerTextDrawFont(playerid, MDC_Layout[playerid][12], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Layout[playerid][12], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Layout[playerid][12], 0);

	MDC_Layout[playerid][13] = CreatePlayerTextDraw(playerid, 613.279968, 264.083435, "[~bl~IIIIIIII~w~]");
	PlayerTextDrawLetterSize(playerid, MDC_Layout[playerid][13], 0.214465, 1.174165);
	PlayerTextDrawAlignment(playerid, MDC_Layout[playerid][13], 3);
	PlayerTextDrawColor(playerid, MDC_Layout[playerid][13], -1);
	PlayerTextDrawSetShadow(playerid, MDC_Layout[playerid][13], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Layout[playerid][13], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Layout[playerid][13], 255);
	PlayerTextDrawFont(playerid, MDC_Layout[playerid][13], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Layout[playerid][13], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Layout[playerid][13], 0);

	MDC_Layout[playerid][14] = CreatePlayerTextDraw(playerid, 537.379211, 282.166748, "Something_here");
	PlayerTextDrawLetterSize(playerid, MDC_Layout[playerid][14], 0.180261, 0.882498);
	PlayerTextDrawAlignment(playerid, MDC_Layout[playerid][14], 1);
	PlayerTextDrawColor(playerid, MDC_Layout[playerid][14], -1);
	PlayerTextDrawSetShadow(playerid, MDC_Layout[playerid][14], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Layout[playerid][14], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Layout[playerid][14], 255);
	PlayerTextDrawFont(playerid, MDC_Layout[playerid][14], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Layout[playerid][14], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Layout[playerid][14], 0);

	MDC_Layout[playerid][15] = CreatePlayerTextDraw(playerid, 537.379272, 292.083435, "Something_here");
	PlayerTextDrawLetterSize(playerid, MDC_Layout[playerid][15], 0.180261, 0.882498);
	PlayerTextDrawAlignment(playerid, MDC_Layout[playerid][15], 1);
	PlayerTextDrawColor(playerid, MDC_Layout[playerid][15], -1);
	PlayerTextDrawSetShadow(playerid, MDC_Layout[playerid][15], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Layout[playerid][15], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Layout[playerid][15], 255);
	PlayerTextDrawFont(playerid, MDC_Layout[playerid][15], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Layout[playerid][15], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Layout[playerid][15], 0);

	MDC_Layout[playerid][16] = CreatePlayerTextDraw(playerid, 586.573974, 276.916625, "l");
	PlayerTextDrawLetterSize(playerid, MDC_Layout[playerid][16], 0.255225, 3.279999);
	PlayerTextDrawAlignment(playerid, MDC_Layout[playerid][16], 1);
	PlayerTextDrawColor(playerid, MDC_Layout[playerid][16], 255);
	PlayerTextDrawSetShadow(playerid, MDC_Layout[playerid][16], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Layout[playerid][16], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Layout[playerid][16], 255);
	PlayerTextDrawFont(playerid, MDC_Layout[playerid][16], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Layout[playerid][16], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Layout[playerid][16], 0);

	MDC_Layout[playerid][17] = CreatePlayerTextDraw(playerid, 600.160644, 282.166564, "BACK-UP~n~DEPART");
	PlayerTextDrawLetterSize(playerid, MDC_Layout[playerid][17], 0.134816, 1.086665);
	PlayerTextDrawAlignment(playerid, MDC_Layout[playerid][17], 2);
	PlayerTextDrawColor(playerid, MDC_Layout[playerid][17], 255);
	PlayerTextDrawSetShadow(playerid, MDC_Layout[playerid][17], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Layout[playerid][17], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Layout[playerid][17], 255);
	PlayerTextDrawFont(playerid, MDC_Layout[playerid][17], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Layout[playerid][17], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Layout[playerid][17], 0);

	MDC_Layout[playerid][18] = CreatePlayerTextDraw(playerid, 595.944580, 241.916687, "~y~Static");
	PlayerTextDrawLetterSize(playerid, MDC_Layout[playerid][18], 0.116075, 1.284999);
	PlayerTextDrawAlignment(playerid, MDC_Layout[playerid][18], 1);
	PlayerTextDrawColor(playerid, MDC_Layout[playerid][18], -1);
	PlayerTextDrawSetShadow(playerid, MDC_Layout[playerid][18], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Layout[playerid][18], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Layout[playerid][18], 255);
	PlayerTextDrawFont(playerid, MDC_Layout[playerid][18], 2);
	PlayerTextDrawSetProportional(playerid, MDC_Layout[playerid][18], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Layout[playerid][18], 0);

	Store_Business[playerid] = CreatePlayerTextDraw(playerid, 123.675003, 67.499977, "Business_Name");
	PlayerTextDrawLetterSize(playerid, Store_Business[playerid], 0.699853, 2.620834);
	PlayerTextDrawAlignment(playerid, Store_Business[playerid], 1);
	PlayerTextDrawColor(playerid, Store_Business[playerid], -1);
	PlayerTextDrawSetShadow(playerid, Store_Business[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Store_Business[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, Store_Business[playerid], 255);
	PlayerTextDrawFont(playerid, Store_Business[playerid], 0);
	PlayerTextDrawSetProportional(playerid, Store_Business[playerid], 1);
	PlayerTextDrawSetShadow(playerid, Store_Business[playerid], 0);

	Store_Mask[playerid] = CreatePlayerTextDraw(playerid, 179.897491, 294.999969, "Mask~n~[246212_42]");
	PlayerTextDrawLetterSize(playerid, Store_Mask[playerid], 0.254289, 1.045832);
	PlayerTextDrawAlignment(playerid, Store_Mask[playerid], 2);
	PlayerTextDrawColor(playerid, Store_Mask[playerid], 255);
	PlayerTextDrawSetShadow(playerid, Store_Mask[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Store_Mask[playerid], 0);
	PlayerTextDrawBackgroundColor(playerid, Store_Mask[playerid], 255);
	PlayerTextDrawFont(playerid, Store_Mask[playerid], 1);
	PlayerTextDrawSetProportional(playerid, Store_Mask[playerid], 1);
	PlayerTextDrawSetShadow(playerid, Store_Mask[playerid], 0);

	Store_Cart[playerid] = CreatePlayerTextDraw(playerid, 326.544403, 168.416671, "~g~EMPTY");
	PlayerTextDrawLetterSize(playerid, Store_Cart[playerid], 0.190102, 1.197499);
	PlayerTextDrawAlignment(playerid, Store_Cart[playerid], 1);
	PlayerTextDrawColor(playerid, Store_Cart[playerid], -1);
	PlayerTextDrawSetShadow(playerid, Store_Cart[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Store_Cart[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, Store_Cart[playerid], 255);
	PlayerTextDrawFont(playerid, Store_Cart[playerid], 1);
	PlayerTextDrawSetProportional(playerid, Store_Cart[playerid], 1);
	PlayerTextDrawSetShadow(playerid, Store_Cart[playerid], 0);

	ColorPanel[playerid][0] = CreatePlayerTextDraw(playerid, 139.436340, 323.000030, "");
	PlayerTextDrawLetterSize(playerid, ColorPanel[playerid][0], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, ColorPanel[playerid][0], 12.000000, 14.000000);
	PlayerTextDrawAlignment(playerid, ColorPanel[playerid][0], 1);
	PlayerTextDrawColor(playerid, ColorPanel[playerid][0], -1);
	PlayerTextDrawSetShadow(playerid, ColorPanel[playerid][0], 0);
	PlayerTextDrawSetOutline(playerid, ColorPanel[playerid][0], 0);
	PlayerTextDrawBackgroundColor(playerid, ColorPanel[playerid][0], -16776961);
	PlayerTextDrawFont(playerid, ColorPanel[playerid][0], 5);
	PlayerTextDrawSetProportional(playerid, ColorPanel[playerid][0], 0);
	PlayerTextDrawSetShadow(playerid, ColorPanel[playerid][0], 0);
	PlayerTextDrawSetSelectable(playerid, ColorPanel[playerid][0], true);
	PlayerTextDrawSetPreviewModel(playerid, ColorPanel[playerid][0], 0);
	PlayerTextDrawSetPreviewRot(playerid, ColorPanel[playerid][0], 0.000000, 0.000000, 0.000000, -1.000000);

	ColorPanel[playerid][1] = CreatePlayerTextDraw(playerid, 151.149368, 323.000030, "");
	PlayerTextDrawLetterSize(playerid, ColorPanel[playerid][1], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, ColorPanel[playerid][1], 12.000000, 14.000000);
	PlayerTextDrawAlignment(playerid, ColorPanel[playerid][1], 1);
	PlayerTextDrawColor(playerid, ColorPanel[playerid][1], -1);
	PlayerTextDrawSetShadow(playerid, ColorPanel[playerid][1], 0);
	PlayerTextDrawSetOutline(playerid, ColorPanel[playerid][1], 0);
	PlayerTextDrawBackgroundColor(playerid, ColorPanel[playerid][1], -1);
	PlayerTextDrawFont(playerid, ColorPanel[playerid][1], 5);
	PlayerTextDrawSetProportional(playerid, ColorPanel[playerid][1], 0);
	PlayerTextDrawSetShadow(playerid, ColorPanel[playerid][1], 0);
	PlayerTextDrawSetSelectable(playerid, ColorPanel[playerid][1], true);
	PlayerTextDrawSetPreviewModel(playerid, ColorPanel[playerid][1], 0);
	PlayerTextDrawSetPreviewRot(playerid, ColorPanel[playerid][1], 0.000000, 0.000000, 0.000000, -1.000000);

	ColorPanel[playerid][2] = CreatePlayerTextDraw(playerid, 163.330917, 323.000030, "");
	PlayerTextDrawLetterSize(playerid, ColorPanel[playerid][2], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, ColorPanel[playerid][2], 12.000000, 14.000000);
	PlayerTextDrawAlignment(playerid, ColorPanel[playerid][2], 1);
	PlayerTextDrawColor(playerid, ColorPanel[playerid][2], -1);
	PlayerTextDrawSetShadow(playerid, ColorPanel[playerid][2], 0);
	PlayerTextDrawSetOutline(playerid, ColorPanel[playerid][2], 0);
	PlayerTextDrawBackgroundColor(playerid, ColorPanel[playerid][2], 65535);
	PlayerTextDrawFont(playerid, ColorPanel[playerid][2], 5);
	PlayerTextDrawSetProportional(playerid, ColorPanel[playerid][2], 0);
	PlayerTextDrawSetShadow(playerid, ColorPanel[playerid][2], 0);
	PlayerTextDrawSetSelectable(playerid, ColorPanel[playerid][2], true);
	PlayerTextDrawSetPreviewModel(playerid, ColorPanel[playerid][2], 0);
	PlayerTextDrawSetPreviewRot(playerid, ColorPanel[playerid][2], 0.000000, 0.000000, 0.000000, -1.000000);

	ColorPanel[playerid][3] = CreatePlayerTextDraw(playerid, 175.043945, 323.000000, "");
	PlayerTextDrawLetterSize(playerid, ColorPanel[playerid][3], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, ColorPanel[playerid][3], 12.000000, 14.000000);
	PlayerTextDrawAlignment(playerid, ColorPanel[playerid][3], 1);
	PlayerTextDrawColor(playerid, ColorPanel[playerid][3], -1);
	PlayerTextDrawSetShadow(playerid, ColorPanel[playerid][3], 0);
	PlayerTextDrawSetOutline(playerid, ColorPanel[playerid][3], 0);
	PlayerTextDrawBackgroundColor(playerid, ColorPanel[playerid][3], -65281);
	PlayerTextDrawFont(playerid, ColorPanel[playerid][3], 5);
	PlayerTextDrawSetProportional(playerid, ColorPanel[playerid][3], 0);
	PlayerTextDrawSetShadow(playerid, ColorPanel[playerid][3], 0);
	PlayerTextDrawSetSelectable(playerid, ColorPanel[playerid][3], true);
	PlayerTextDrawSetPreviewModel(playerid, ColorPanel[playerid][3], 0);
	PlayerTextDrawSetPreviewRot(playerid, ColorPanel[playerid][3], 0.000000, 0.000000, 0.000000, -1.000000);

	ColorPanel[playerid][4] = CreatePlayerTextDraw(playerid, 139.436340, 337.000030, "");
	PlayerTextDrawLetterSize(playerid, ColorPanel[playerid][4], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, ColorPanel[playerid][4], 12.000000, 14.000000);
	PlayerTextDrawAlignment(playerid, ColorPanel[playerid][4], 1);
	PlayerTextDrawColor(playerid, ColorPanel[playerid][4], -1);
	PlayerTextDrawSetShadow(playerid, ColorPanel[playerid][4], 0);
	PlayerTextDrawSetOutline(playerid, ColorPanel[playerid][4], 0);
	PlayerTextDrawBackgroundColor(playerid, ColorPanel[playerid][4], -2147450625);
	PlayerTextDrawFont(playerid, ColorPanel[playerid][4], 5);
	PlayerTextDrawSetProportional(playerid, ColorPanel[playerid][4], 0);
	PlayerTextDrawSetShadow(playerid, ColorPanel[playerid][4], 0);
	PlayerTextDrawSetSelectable(playerid, ColorPanel[playerid][4], true);
	PlayerTextDrawSetPreviewModel(playerid, ColorPanel[playerid][4], 0);
	PlayerTextDrawSetPreviewRot(playerid, ColorPanel[playerid][4], 0.000000, 0.000000, 0.000000, -1.000000);

	ColorPanel[playerid][5] = CreatePlayerTextDraw(playerid, 151.617889, 337.000061, "");
	PlayerTextDrawLetterSize(playerid, ColorPanel[playerid][5], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, ColorPanel[playerid][5], 12.000000, 14.000000);
	PlayerTextDrawAlignment(playerid, ColorPanel[playerid][5], 1);
	PlayerTextDrawColor(playerid, ColorPanel[playerid][5], -1);
	PlayerTextDrawSetShadow(playerid, ColorPanel[playerid][5], 0);
	PlayerTextDrawSetOutline(playerid, ColorPanel[playerid][5], 0);
	PlayerTextDrawBackgroundColor(playerid, ColorPanel[playerid][5], 16711935);
	PlayerTextDrawFont(playerid, ColorPanel[playerid][5], 5);
	PlayerTextDrawSetProportional(playerid, ColorPanel[playerid][5], 0);
	PlayerTextDrawSetShadow(playerid, ColorPanel[playerid][5], 0);
	PlayerTextDrawSetSelectable(playerid, ColorPanel[playerid][5], true);
	PlayerTextDrawSetPreviewModel(playerid, ColorPanel[playerid][5], 0);
	PlayerTextDrawSetPreviewRot(playerid, ColorPanel[playerid][5], 0.000000, 0.000000, 0.000000, -1.000000);

	ColorPanel[playerid][6] = CreatePlayerTextDraw(playerid, 163.799438, 337.000061, "");
	PlayerTextDrawLetterSize(playerid, ColorPanel[playerid][6], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, ColorPanel[playerid][6], 12.000000, 14.000000);
	PlayerTextDrawAlignment(playerid, ColorPanel[playerid][6], 1);
	PlayerTextDrawColor(playerid, ColorPanel[playerid][6], -1);
	PlayerTextDrawSetShadow(playerid, ColorPanel[playerid][6], 0);
	PlayerTextDrawSetOutline(playerid, ColorPanel[playerid][6], 0);
	PlayerTextDrawBackgroundColor(playerid, ColorPanel[playerid][6], -16711681);
	PlayerTextDrawFont(playerid, ColorPanel[playerid][6], 5);
	PlayerTextDrawSetProportional(playerid, ColorPanel[playerid][6], 0);
	PlayerTextDrawSetShadow(playerid, ColorPanel[playerid][6], 0);
	PlayerTextDrawSetSelectable(playerid, ColorPanel[playerid][6], true);
	PlayerTextDrawSetPreviewModel(playerid, ColorPanel[playerid][6], 0);
	PlayerTextDrawSetPreviewRot(playerid, ColorPanel[playerid][6], 0.000000, 0.000000, 0.000000, -1.000000);

	ColorPanel[playerid][7] = CreatePlayerTextDraw(playerid, 175.043945, 337.000061, "");
	PlayerTextDrawLetterSize(playerid, ColorPanel[playerid][7], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, ColorPanel[playerid][7], 12.000000, 14.000000);
	PlayerTextDrawAlignment(playerid, ColorPanel[playerid][7], 1);
	PlayerTextDrawColor(playerid, ColorPanel[playerid][7], -1);
	PlayerTextDrawSetShadow(playerid, ColorPanel[playerid][7], 0);
	PlayerTextDrawSetOutline(playerid, ColorPanel[playerid][7], 0);
	PlayerTextDrawBackgroundColor(playerid, ColorPanel[playerid][7], -2147483393);
	PlayerTextDrawFont(playerid, ColorPanel[playerid][7], 5);
	PlayerTextDrawSetProportional(playerid, ColorPanel[playerid][7], 0);
	PlayerTextDrawSetShadow(playerid, ColorPanel[playerid][7], 0);
	PlayerTextDrawSetSelectable(playerid, ColorPanel[playerid][7], true);
	PlayerTextDrawSetPreviewModel(playerid, ColorPanel[playerid][7], 0);
	PlayerTextDrawSetPreviewRot(playerid, ColorPanel[playerid][7], 0.000000, 0.000000, 0.000000, -1.000000);

	ColorPanel[playerid][8] = CreatePlayerTextDraw(playerid, 126.486099, 354.500030, "Primary_Colors");
	PlayerTextDrawLetterSize(playerid, ColorPanel[playerid][8], 0.341434, 1.430832);
	PlayerTextDrawAlignment(playerid, ColorPanel[playerid][8], 1);
	PlayerTextDrawColor(playerid, ColorPanel[playerid][8], -1);
	PlayerTextDrawSetShadow(playerid, ColorPanel[playerid][8], 0);
	PlayerTextDrawSetOutline(playerid, ColorPanel[playerid][8], 1);
	PlayerTextDrawBackgroundColor(playerid, ColorPanel[playerid][8], 255);
	PlayerTextDrawFont(playerid, ColorPanel[playerid][8], 1);
	PlayerTextDrawSetProportional(playerid, ColorPanel[playerid][8], 1);
	PlayerTextDrawSetShadow(playerid, ColorPanel[playerid][8], 0);
	PlayerTextDrawSetSelectable(playerid, ColorPanel[playerid][8], true);

	ColorPanel[playerid][9] = CreatePlayerTextDraw(playerid, 186.756942, 329.416625, "LD_BEAT:RIGHT");
	PlayerTextDrawLetterSize(playerid, ColorPanel[playerid][9], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, ColorPanel[playerid][9], 16.000000, 17.000000);
	PlayerTextDrawAlignment(playerid, ColorPanel[playerid][9], 1);
	PlayerTextDrawColor(playerid, ColorPanel[playerid][9], -1);
	PlayerTextDrawSetShadow(playerid, ColorPanel[playerid][9], 0);
	PlayerTextDrawSetOutline(playerid, ColorPanel[playerid][9], 0);
	PlayerTextDrawBackgroundColor(playerid, ColorPanel[playerid][9], 255);
	PlayerTextDrawFont(playerid, ColorPanel[playerid][9], 4);
	PlayerTextDrawSetProportional(playerid, ColorPanel[playerid][9], 0);
	PlayerTextDrawSetShadow(playerid, ColorPanel[playerid][9], 0);
	PlayerTextDrawSetSelectable(playerid, ColorPanel[playerid][9], true);

	//Unscrambler Textdraws:
	Unscrambler_PTD[playerid][0] = CreatePlayerTextDraw(playerid, 199.873275, 273.593383, "<UNSCRAMBLED_WORD>");
	PlayerTextDrawLetterSize(playerid, Unscrambler_PTD[playerid][0], 0.206330, 1.118813);
	PlayerTextDrawAlignment(playerid, Unscrambler_PTD[playerid][0], 1);
	PlayerTextDrawColor(playerid, Unscrambler_PTD[playerid][0], -1);
	PlayerTextDrawSetShadow(playerid, Unscrambler_PTD[playerid][0], 0);
	PlayerTextDrawSetOutline(playerid, Unscrambler_PTD[playerid][0], 1);
	PlayerTextDrawBackgroundColor(playerid, Unscrambler_PTD[playerid][0], 255);
	PlayerTextDrawFont(playerid, Unscrambler_PTD[playerid][0], 2);
	PlayerTextDrawSetProportional(playerid, Unscrambler_PTD[playerid][0], 1);
	PlayerTextDrawSetShadow(playerid, Unscrambler_PTD[playerid][0], 0);

	Unscrambler_PTD[playerid][1] = CreatePlayerTextDraw(playerid, 137.369461, 273.593383, "/unscramble");
	PlayerTextDrawLetterSize(playerid, Unscrambler_PTD[playerid][1], 0.206330, 1.118813);
	PlayerTextDrawAlignment(playerid, Unscrambler_PTD[playerid][1], 1);
	PlayerTextDrawColor(playerid, Unscrambler_PTD[playerid][1], -490707969);
	PlayerTextDrawSetShadow(playerid, Unscrambler_PTD[playerid][1], 0);
	PlayerTextDrawSetOutline(playerid, Unscrambler_PTD[playerid][1], 1);
	PlayerTextDrawBackgroundColor(playerid, Unscrambler_PTD[playerid][1], 255);
	PlayerTextDrawFont(playerid, Unscrambler_PTD[playerid][1], 2);
	PlayerTextDrawSetProportional(playerid, Unscrambler_PTD[playerid][1], 1);
	PlayerTextDrawSetShadow(playerid, Unscrambler_PTD[playerid][1], 0);

	Unscrambler_PTD[playerid][2] = CreatePlayerTextDraw(playerid, 305.179687, 273.593383, "TO_UNSCRAMBLE_THE_WORD");
	PlayerTextDrawLetterSize(playerid, Unscrambler_PTD[playerid][2], 0.206330, 1.118813);
	PlayerTextDrawAlignment(playerid, Unscrambler_PTD[playerid][2], 1);
	PlayerTextDrawColor(playerid, Unscrambler_PTD[playerid][2], -2147483393);
	PlayerTextDrawSetShadow(playerid, Unscrambler_PTD[playerid][2], 0);
	PlayerTextDrawSetOutline(playerid, Unscrambler_PTD[playerid][2], 1);
	PlayerTextDrawBackgroundColor(playerid, Unscrambler_PTD[playerid][2], 255);
	PlayerTextDrawFont(playerid, Unscrambler_PTD[playerid][2], 2);
	PlayerTextDrawSetProportional(playerid, Unscrambler_PTD[playerid][2], 1);
	PlayerTextDrawSetShadow(playerid, Unscrambler_PTD[playerid][2], 0);

	Unscrambler_PTD[playerid][3] = CreatePlayerTextDraw(playerid, 141.369705, 285.194091, "scrambledword");
	PlayerTextDrawLetterSize(playerid, Unscrambler_PTD[playerid][3], 0.206330, 1.118813);
	PlayerTextDrawAlignment(playerid, Unscrambler_PTD[playerid][3], 1);
	PlayerTextDrawColor(playerid, Unscrambler_PTD[playerid][3], -1);
	PlayerTextDrawSetShadow(playerid, Unscrambler_PTD[playerid][3], 0);
	PlayerTextDrawSetOutline(playerid, Unscrambler_PTD[playerid][3], 1);
	PlayerTextDrawBackgroundColor(playerid, Unscrambler_PTD[playerid][3], 255);
	PlayerTextDrawFont(playerid, Unscrambler_PTD[playerid][3], 2);
	PlayerTextDrawSetProportional(playerid, Unscrambler_PTD[playerid][3], 1);
	PlayerTextDrawSetShadow(playerid, Unscrambler_PTD[playerid][3], 0);

	Unscrambler_PTD[playerid][4] = CreatePlayerTextDraw(playerid, 137.902801, 296.924377, "YOU_HAVE");
	PlayerTextDrawLetterSize(playerid, Unscrambler_PTD[playerid][4], 0.206330, 1.118813);
	PlayerTextDrawAlignment(playerid, Unscrambler_PTD[playerid][4], 1);
	PlayerTextDrawColor(playerid, Unscrambler_PTD[playerid][4], -2147483393);
	PlayerTextDrawSetShadow(playerid, Unscrambler_PTD[playerid][4], 0);
	PlayerTextDrawSetOutline(playerid, Unscrambler_PTD[playerid][4], 1);
	PlayerTextDrawBackgroundColor(playerid, Unscrambler_PTD[playerid][4], 255);
	PlayerTextDrawFont(playerid, Unscrambler_PTD[playerid][4], 2);
	PlayerTextDrawSetProportional(playerid, Unscrambler_PTD[playerid][4], 1);
	PlayerTextDrawSetShadow(playerid, Unscrambler_PTD[playerid][4], 0);

	Unscrambler_PTD[playerid][5] = CreatePlayerTextDraw(playerid, 184.539016, 297.024383, "001");
	PlayerTextDrawLetterSize(playerid, Unscrambler_PTD[playerid][5], 0.206330, 1.118813);
	PlayerTextDrawAlignment(playerid, Unscrambler_PTD[playerid][5], 1);
	PlayerTextDrawColor(playerid, Unscrambler_PTD[playerid][5], -1);
	PlayerTextDrawSetShadow(playerid, Unscrambler_PTD[playerid][5], 0);
	PlayerTextDrawSetOutline(playerid, Unscrambler_PTD[playerid][5], 1);
	PlayerTextDrawBackgroundColor(playerid, Unscrambler_PTD[playerid][5], 255);
	PlayerTextDrawFont(playerid, Unscrambler_PTD[playerid][5], 2);
	PlayerTextDrawSetProportional(playerid, Unscrambler_PTD[playerid][5], 1);
	PlayerTextDrawSetShadow(playerid, Unscrambler_PTD[playerid][5], 0);

	Unscrambler_PTD[playerid][6] = CreatePlayerTextDraw(playerid, 202.540191, 297.124389, "SECONDS_LEFT_TO_FINISh.");
	PlayerTextDrawLetterSize(playerid, Unscrambler_PTD[playerid][6], 0.206330, 1.118813);
	PlayerTextDrawAlignment(playerid, Unscrambler_PTD[playerid][6], 1);
	PlayerTextDrawColor(playerid, Unscrambler_PTD[playerid][6], -2147483393);
	PlayerTextDrawSetShadow(playerid, Unscrambler_PTD[playerid][6], 0);
	PlayerTextDrawSetOutline(playerid, Unscrambler_PTD[playerid][6], 1);
	PlayerTextDrawBackgroundColor(playerid, Unscrambler_PTD[playerid][6], 255);
	PlayerTextDrawFont(playerid, Unscrambler_PTD[playerid][6], 2);
	PlayerTextDrawSetProportional(playerid, Unscrambler_PTD[playerid][6], 1);
	PlayerTextDrawSetShadow(playerid, Unscrambler_PTD[playerid][6], 0);

	//Plate Textdraw:
	ui_msgbox[playerid][0] = CreatePlayerTextDraw(playerid, 97.333351, 291.629669, "_");
	PlayerTextDrawLetterSize(playerid, ui_msgbox[playerid][0], 0.248666, 1.259851);
	PlayerTextDrawAlignment(playerid, ui_msgbox[playerid][0], 1);
	PlayerTextDrawColor(playerid, ui_msgbox[playerid][0], -1);
	PlayerTextDrawSetShadow(playerid, ui_msgbox[playerid][0], 0);
	PlayerTextDrawSetOutline(playerid, ui_msgbox[playerid][0], 1);
	PlayerTextDrawBackgroundColor(playerid, ui_msgbox[playerid][0], 255);
	PlayerTextDrawFont(playerid, ui_msgbox[playerid][0], 2);
	PlayerTextDrawSetProportional(playerid, ui_msgbox[playerid][0], 1);
	PlayerTextDrawSetShadow(playerid, ui_msgbox[playerid][0], 0);

	ui_msgbox[playerid][1] = CreatePlayerTextDraw(playerid, 97.533348, 302.630340, "_");
	PlayerTextDrawLetterSize(playerid, ui_msgbox[playerid][1], 0.248666, 1.259851);
	PlayerTextDrawAlignment(playerid, ui_msgbox[playerid][1], 1);
	PlayerTextDrawColor(playerid, ui_msgbox[playerid][1], -490707969);
	PlayerTextDrawSetShadow(playerid, ui_msgbox[playerid][1], 0);
	PlayerTextDrawSetOutline(playerid, ui_msgbox[playerid][1], 1);
	PlayerTextDrawBackgroundColor(playerid, ui_msgbox[playerid][1], 255);
	PlayerTextDrawFont(playerid, ui_msgbox[playerid][1], 2);
	PlayerTextDrawSetProportional(playerid, ui_msgbox[playerid][1], 1);
	PlayerTextDrawSetShadow(playerid, ui_msgbox[playerid][1], 0);

	FoodOrder[playerid][0] = CreatePlayerTextDraw(playerid, 127.423080, 80.916671, "box");
	PlayerTextDrawLetterSize(playerid, FoodOrder[playerid][0], 0.000000, 31.317710);
	PlayerTextDrawTextSize(playerid, FoodOrder[playerid][0], 536.000000, 0.000000);
	PlayerTextDrawAlignment(playerid, FoodOrder[playerid][0], 1);
	PlayerTextDrawColor(playerid, FoodOrder[playerid][0], -1);
	PlayerTextDrawUseBox(playerid, FoodOrder[playerid][0], 1);
	PlayerTextDrawBoxColor(playerid, FoodOrder[playerid][0], 255);
	PlayerTextDrawSetShadow(playerid, FoodOrder[playerid][0], 0);
	PlayerTextDrawSetOutline(playerid, FoodOrder[playerid][0], 0);
	PlayerTextDrawBackgroundColor(playerid, FoodOrder[playerid][0], 255);
	PlayerTextDrawFont(playerid, FoodOrder[playerid][0], 1);
	PlayerTextDrawSetProportional(playerid, FoodOrder[playerid][0], 1);
	PlayerTextDrawSetShadow(playerid, FoodOrder[playerid][0], 0);

	FoodOrder[playerid][1] = CreatePlayerTextDraw(playerid, 143.352844, 94.333312, "Business_Type");
	PlayerTextDrawLetterSize(playerid, FoodOrder[playerid][1], 0.724685, 2.819167);
	PlayerTextDrawAlignment(playerid, FoodOrder[playerid][1], 1);
	PlayerTextDrawColor(playerid, FoodOrder[playerid][1], -1);
	PlayerTextDrawSetShadow(playerid, FoodOrder[playerid][1], 0);
	PlayerTextDrawSetOutline(playerid, FoodOrder[playerid][1], 0);
	PlayerTextDrawBackgroundColor(playerid, FoodOrder[playerid][1], 255);
	PlayerTextDrawFont(playerid, FoodOrder[playerid][1], 0);
	PlayerTextDrawSetProportional(playerid, FoodOrder[playerid][1], 1);
	PlayerTextDrawSetShadow(playerid, FoodOrder[playerid][1], 0);

	FoodOrder[playerid][2] = CreatePlayerTextDraw(playerid, 158.813995, 133.416641, "This_restaurant_offers_multiple_meals.~n~Choose_one_by_clicking_on_its_picture.");
	PlayerTextDrawLetterSize(playerid, FoodOrder[playerid][2], 0.266002, 1.390000);
	PlayerTextDrawAlignment(playerid, FoodOrder[playerid][2], 1);
	PlayerTextDrawColor(playerid, FoodOrder[playerid][2], -1);
	PlayerTextDrawSetShadow(playerid, FoodOrder[playerid][2], 0);
	PlayerTextDrawSetOutline(playerid, FoodOrder[playerid][2], 0);
	PlayerTextDrawBackgroundColor(playerid, FoodOrder[playerid][2], 255);
	PlayerTextDrawFont(playerid, FoodOrder[playerid][2], 1);
	PlayerTextDrawSetProportional(playerid, FoodOrder[playerid][2], 1);
	PlayerTextDrawSetShadow(playerid, FoodOrder[playerid][2], 0);

	FoodOrder[playerid][3] = CreatePlayerTextDraw(playerid, 519.575683, 88.500007, "X");
	PlayerTextDrawLetterSize(playerid, FoodOrder[playerid][3], 0.333469, 1.144999);
	PlayerTextDrawAlignment(playerid, FoodOrder[playerid][3], 2);
	PlayerTextDrawColor(playerid, FoodOrder[playerid][3], -1);
	PlayerTextDrawSetShadow(playerid, FoodOrder[playerid][3], 0);
	PlayerTextDrawSetOutline(playerid, FoodOrder[playerid][3], 0);
	PlayerTextDrawBackgroundColor(playerid, FoodOrder[playerid][3], 255);
	PlayerTextDrawFont(playerid, FoodOrder[playerid][3], 1);
	PlayerTextDrawSetProportional(playerid, FoodOrder[playerid][3], 1);
	PlayerTextDrawSetShadow(playerid, FoodOrder[playerid][3], 0);
	PlayerTextDrawSetSelectable(playerid, FoodOrder[playerid][3], true);

	FoodOrder[playerid][4] = CreatePlayerTextDraw(playerid, 126.317764, 143.333328, "");
	PlayerTextDrawLetterSize(playerid, FoodOrder[playerid][4], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, FoodOrder[playerid][4], 103.000000, 136.000000);
	PlayerTextDrawAlignment(playerid, FoodOrder[playerid][4], 1);
	PlayerTextDrawColor(playerid, FoodOrder[playerid][4], -1);
	PlayerTextDrawSetShadow(playerid, FoodOrder[playerid][4], 0);
	PlayerTextDrawSetOutline(playerid, FoodOrder[playerid][4], 0);
	PlayerTextDrawBackgroundColor(playerid, FoodOrder[playerid][4], 255);
	PlayerTextDrawFont(playerid, FoodOrder[playerid][4], 5);
	PlayerTextDrawSetProportional(playerid, FoodOrder[playerid][4], 0);
	PlayerTextDrawSetShadow(playerid, FoodOrder[playerid][4], 0);
	PlayerTextDrawSetSelectable(playerid, FoodOrder[playerid][4], true);
	PlayerTextDrawSetPreviewModel(playerid, FoodOrder[playerid][4], 2213);
	PlayerTextDrawSetPreviewRot(playerid, FoodOrder[playerid][4], 300.000000, 26.000000, 52.000000, 0.899999);

	FoodOrder[playerid][5] = CreatePlayerTextDraw(playerid, 258.909301, 140.999969, "");
	PlayerTextDrawLetterSize(playerid, FoodOrder[playerid][5], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, FoodOrder[playerid][5], 103.000000, 136.000000);
	PlayerTextDrawAlignment(playerid, FoodOrder[playerid][5], 1);
	PlayerTextDrawColor(playerid, FoodOrder[playerid][5], -1);
	PlayerTextDrawSetShadow(playerid, FoodOrder[playerid][5], 0);
	PlayerTextDrawSetOutline(playerid, FoodOrder[playerid][5], 0);
	PlayerTextDrawBackgroundColor(playerid, FoodOrder[playerid][5], 255);
	PlayerTextDrawFont(playerid, FoodOrder[playerid][5], 5);
	PlayerTextDrawSetProportional(playerid, FoodOrder[playerid][5], 0);
	PlayerTextDrawSetShadow(playerid, FoodOrder[playerid][5], 0);
	PlayerTextDrawSetSelectable(playerid, FoodOrder[playerid][5], true);
	PlayerTextDrawSetPreviewModel(playerid, FoodOrder[playerid][5], 2214);
	PlayerTextDrawSetPreviewRot(playerid, FoodOrder[playerid][5], 300.000000, 26.000000, 52.000000, 0.899999);

	FoodOrder[playerid][6] = CreatePlayerTextDraw(playerid, 401.808380, 138.083374, "");
	PlayerTextDrawLetterSize(playerid, FoodOrder[playerid][6], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, FoodOrder[playerid][6], 103.000000, 136.000000);
	PlayerTextDrawAlignment(playerid, FoodOrder[playerid][6], 1);
	PlayerTextDrawColor(playerid, FoodOrder[playerid][6], -1);
	PlayerTextDrawSetShadow(playerid, FoodOrder[playerid][6], 0);
	PlayerTextDrawSetOutline(playerid, FoodOrder[playerid][6], 0);
	PlayerTextDrawBackgroundColor(playerid, FoodOrder[playerid][6], 255);
	PlayerTextDrawFont(playerid, FoodOrder[playerid][6], 5);
	PlayerTextDrawSetProportional(playerid, FoodOrder[playerid][6], 0);
	PlayerTextDrawSetShadow(playerid, FoodOrder[playerid][6], 0);
	PlayerTextDrawSetSelectable(playerid, FoodOrder[playerid][6], true);
	PlayerTextDrawSetPreviewModel(playerid, FoodOrder[playerid][6], 2212);
	PlayerTextDrawSetPreviewRot(playerid, FoodOrder[playerid][6], 300.000000, 26.000000, 52.000000, 0.899999);

	FoodOrder[playerid][7] = CreatePlayerTextDraw(playerid, 189.736465, 283.333404, "FOOD_NAME_1");
	PlayerTextDrawLetterSize(playerid, FoodOrder[playerid][7], 0.298330, 1.407499);
	PlayerTextDrawAlignment(playerid, FoodOrder[playerid][7], 2);
	PlayerTextDrawColor(playerid, FoodOrder[playerid][7], -1);
	PlayerTextDrawSetShadow(playerid, FoodOrder[playerid][7], 0);
	PlayerTextDrawSetOutline(playerid, FoodOrder[playerid][7], 0);
	PlayerTextDrawBackgroundColor(playerid, FoodOrder[playerid][7], 255);
	PlayerTextDrawFont(playerid, FoodOrder[playerid][7], 1);
	PlayerTextDrawSetProportional(playerid, FoodOrder[playerid][7], 1);
	PlayerTextDrawSetShadow(playerid, FoodOrder[playerid][7], 0);

	FoodOrder[playerid][8] = CreatePlayerTextDraw(playerid, 319.517211, 282.750091, "FOOD_NAME_2");
	PlayerTextDrawLetterSize(playerid, FoodOrder[playerid][8], 0.298330, 1.407499);
	PlayerTextDrawAlignment(playerid, FoodOrder[playerid][8], 2);
	PlayerTextDrawColor(playerid, FoodOrder[playerid][8], -1);
	PlayerTextDrawSetShadow(playerid, FoodOrder[playerid][8], 0);
	PlayerTextDrawSetOutline(playerid, FoodOrder[playerid][8], 0);
	PlayerTextDrawBackgroundColor(playerid, FoodOrder[playerid][8], 255);
	PlayerTextDrawFont(playerid, FoodOrder[playerid][8], 1);
	PlayerTextDrawSetProportional(playerid, FoodOrder[playerid][8], 1);
	PlayerTextDrawSetShadow(playerid, FoodOrder[playerid][8], 0);

	FoodOrder[playerid][9] = CreatePlayerTextDraw(playerid, 464.758911, 282.750030, "FOOD_NAME_3");
	PlayerTextDrawLetterSize(playerid, FoodOrder[playerid][9], 0.298330, 1.407499);
	PlayerTextDrawAlignment(playerid, FoodOrder[playerid][9], 2);
	PlayerTextDrawColor(playerid, FoodOrder[playerid][9], -1);
	PlayerTextDrawSetShadow(playerid, FoodOrder[playerid][9], 0);
	PlayerTextDrawSetOutline(playerid, FoodOrder[playerid][9], 0);
	PlayerTextDrawBackgroundColor(playerid, FoodOrder[playerid][9], 255);
	PlayerTextDrawFont(playerid, FoodOrder[playerid][9], 1);
	PlayerTextDrawSetProportional(playerid, FoodOrder[playerid][9], 1);
	PlayerTextDrawSetShadow(playerid, FoodOrder[playerid][9], 0);

	FoodOrder[playerid][10] = CreatePlayerTextDraw(playerid, 160.219589, 297.916625, "~r~Health:_+99_1~n~Removes_Hunger~n~~b~Price:_$99_1");
	PlayerTextDrawLetterSize(playerid, FoodOrder[playerid][10], 0.247730, 1.063332);
	PlayerTextDrawAlignment(playerid, FoodOrder[playerid][10], 1);
	PlayerTextDrawColor(playerid, FoodOrder[playerid][10], -1);
	PlayerTextDrawSetShadow(playerid, FoodOrder[playerid][10], 0);
	PlayerTextDrawSetOutline(playerid, FoodOrder[playerid][10], 0);
	PlayerTextDrawBackgroundColor(playerid, FoodOrder[playerid][10], 255);
	PlayerTextDrawFont(playerid, FoodOrder[playerid][10], 1);
	PlayerTextDrawSetProportional(playerid, FoodOrder[playerid][10], 1);
	PlayerTextDrawSetShadow(playerid, FoodOrder[playerid][10], 0);

	FoodOrder[playerid][11] = CreatePlayerTextDraw(playerid, 290.468750, 296.749969, "~r~Health:_+99_2~n~Removes_Hunger~n~~b~Price:_$99_2");
	PlayerTextDrawLetterSize(playerid, FoodOrder[playerid][11], 0.247730, 1.063332);
	PlayerTextDrawAlignment(playerid, FoodOrder[playerid][11], 1);
	PlayerTextDrawColor(playerid, FoodOrder[playerid][11], -1);
	PlayerTextDrawSetShadow(playerid, FoodOrder[playerid][11], 0);
	PlayerTextDrawSetOutline(playerid, FoodOrder[playerid][11], 0);
	PlayerTextDrawBackgroundColor(playerid, FoodOrder[playerid][11], 255);
	PlayerTextDrawFont(playerid, FoodOrder[playerid][11], 1);
	PlayerTextDrawSetProportional(playerid, FoodOrder[playerid][11], 1);
	PlayerTextDrawSetShadow(playerid, FoodOrder[playerid][11], 0);

	FoodOrder[playerid][12] = CreatePlayerTextDraw(playerid, 434.774810, 297.333312, "~r~Health:_+99_3~n~Removes_Hunger~n~~b~Price:_$99_3");
	PlayerTextDrawLetterSize(playerid, FoodOrder[playerid][12], 0.247730, 1.063332);
	PlayerTextDrawAlignment(playerid, FoodOrder[playerid][12], 1);
	PlayerTextDrawColor(playerid, FoodOrder[playerid][12], -1);
	PlayerTextDrawSetShadow(playerid, FoodOrder[playerid][12], 0);
	PlayerTextDrawSetOutline(playerid, FoodOrder[playerid][12], 0);
	PlayerTextDrawBackgroundColor(playerid, FoodOrder[playerid][12], 255);
	PlayerTextDrawFont(playerid, FoodOrder[playerid][12], 1);
	PlayerTextDrawSetProportional(playerid, FoodOrder[playerid][12], 1);
	PlayerTextDrawSetShadow(playerid, FoodOrder[playerid][12], 0);
}

stock ShowFoodMenu(playerid, bool:showTextdraw = true)
{
	if(showTextdraw)
	{
		new
		    id = IsPlayerInBusiness(playerid)
		;

		new str[512];
	    format(str, sizeof(str), "%s", ReturnFoodType( Food_Data[ BusinessInfo[id][eBusinessFood][0] ][ FoodType ] ));
	    PlayerTextDrawSetString(playerid, FoodOrder[playerid][1], str);
		format(str, sizeof(str), "~r~Health:_+%d~n~Removes_Hunger~n~~b~Price:_$%d", floatround(Food_Data[ BusinessInfo[id][eBusinessFood][0] ][ HealthPoint ]), Food_Data[ BusinessInfo[id][eBusinessFood][0] ][ FoodPrice ]);
		PlayerTextDrawSetString(playerid, FoodOrder[playerid][10], str);
		format(str, sizeof(str), "~r~Health:_+%d~n~Removes_Hunger~n~~b~Price:_$%d", floatround(Food_Data[ BusinessInfo[id][eBusinessFood][1] ][ HealthPoint ]), Food_Data[ BusinessInfo[id][eBusinessFood][1] ][ FoodPrice ]);
		PlayerTextDrawSetString(playerid, FoodOrder[playerid][11], str);
		format(str, sizeof(str), "~r~Health:_+%d~n~Removes_Hunger~n~~b~Price:_$%d", floatround(Food_Data[ BusinessInfo[id][eBusinessFood][2] ][ HealthPoint ]), Food_Data[ BusinessInfo[id][eBusinessFood][2] ][ FoodPrice ]);
		PlayerTextDrawSetString(playerid, FoodOrder[playerid][12], str);
		format(str, sizeof(str), "%s", Food_Data[ BusinessInfo[id][eBusinessFood][0] ][ FoodName ]);
		PlayerTextDrawSetString(playerid, FoodOrder[playerid][7], str);
		format(str, sizeof(str), "%s", Food_Data[ BusinessInfo[id][eBusinessFood][1] ][ FoodName ]);
		PlayerTextDrawSetString(playerid, FoodOrder[playerid][8], str);
		format(str, sizeof(str), "%s", Food_Data[ BusinessInfo[id][eBusinessFood][2] ][ FoodName ]);
		PlayerTextDrawSetString(playerid, FoodOrder[playerid][9], str);
		PlayerTextDrawSetPreviewModel(playerid, FoodOrder[playerid][4], Food_Data[ BusinessInfo[id][eBusinessFood][0] ][ Model ]);
		PlayerTextDrawSetPreviewModel(playerid, FoodOrder[playerid][5], Food_Data[ BusinessInfo[id][eBusinessFood][1] ][ Model ]);
		PlayerTextDrawSetPreviewModel(playerid, FoodOrder[playerid][6], Food_Data[ BusinessInfo[id][eBusinessFood][2] ][ Model ]);
        SelectTextDraw(playerid, COLOR_GREY);
		for(new i = 0; i < sizeof(FoodOrder); i++)
		{
			PlayerTextDrawShow(playerid, FoodOrder[playerid][i]);
		}
	}
	else
	{
		for(new i = 0; i < sizeof(FoodOrder); i++)
		{
			PlayerTextDrawHide(playerid, FoodOrder[playerid][i]);
		}
	}
	return 1;
}

ReturnFoodType(index)
{
	new str[40];
	switch(index)
	{
	    case TYPE_PIZZA: str = "The_Well_Pizza_Stack";
	    case TYPE_BURGER: str = "Cluckin_Bell";
	    case TYPE_CHICKEN: str = "Burger_King";
	    case TYPE_DONUT: str = "Donut";
	    default: str = "Unknown";
	}
	return str;
}

ReturnRestaurantName(index)
{
	new str[40];
	switch(index)
	{
	    case TYPE_PIZZA: str = "Pizza Restaurant";
	    case TYPE_BURGER: str = "Burger Fast-Food";
	    case TYPE_CHICKEN: str = "Chicken Fast-Food";
	    case TYPE_DONUT: str = "Donut Fast-Food";
	    default: str = "Unknown";
	}
	return str;
}

public OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
    if (!PlayerInfo[playerid][pSetupInfo])
	{
		if (playertextid == SetUp[playerid][3]) {
	    	PlayerInfo[playerid][pGender] = GENDER_MALE;
	    	UpdateSkinSelection(playerid, 0);
	    	PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
	    } else if (playertextid == SetUp[playerid][4]) {
	        PlayerInfo[playerid][pGender] = GENDER_FEMALE;
	        UpdateSkinSelection(playerid, 0);
	        PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
	    } else if (playertextid == SetUp[playerid][7] && PlayerInfo[playerid][pAge] > 13) {
	        PlayerInfo[playerid][pAge]--;
	        PlayerPlaySound(playerid, 1053, 0.0, 0.0, 0.0);
		} else if (playertextid == SetUp[playerid][8] && PlayerInfo[playerid][pAge] < 99) {
	        PlayerInfo[playerid][pAge]++;
	        PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
		} else if (playertextid == SetUp[playerid][11]) {
	        UpdateSkinSelection(playerid, PlayerInfo[playerid][pOutfit] - 1);
	        PlayerPlaySound(playerid, 1053, 0.0, 0.0, 0.0);
		} else if (playertextid == SetUp[playerid][12]) {
	        UpdateSkinSelection(playerid, PlayerInfo[playerid][pOutfit] + 1);
	        PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
		} else if (playertextid == SetUp[playerid][13]) {
		    ResetCharacterSetup(playerid);
		} else if (playertextid == SetUp[playerid][14]) {
		    Dialog_Show(playerid, SetupConfirm, DIALOG_STYLE_MSGBOX, "Confirmation", "Are you sure you would like to save your character?", "Yes", "No");
		} else if (playertextid == SetUp[playerid][15]) {
		    Dialog_Show(playerid, SetupHelp, DIALOG_STYLE_MSGBOX, "More Help", "You can easily setup your character using this simple interface.\n\n- To change your gender, click on {88AA62}Male{A9C4E4} or {88AA62}Female{A9C4E4}.\n- To change your age, click on the minus (-) and plus (+) buttons.\n- To change your outfit, click on the arrows to browse between outfits.\n\nOnce you are ready, just click {88AA62}Confirm{A9C4E4} to save your character!", "Close", "");
		}
		UpdateCharacterSetup(playerid);
	}
	if(GetPVarInt(playerid, "UsingMDC") == 1)
	{
		if(playertextid == MDC_UI[playerid][35])
		{
		    PlayerTextDrawBackgroundColor(playerid, MDC_UI[playerid][36], -1431655681);
		    PlayerTextDrawHide(playerid, MDC_UI[playerid][36]);
		    PlayerTextDrawShow(playerid, MDC_UI[playerid][36]);

		    PlayerTextDrawHide(playerid, MDC_UI[playerid][35]);
		    PlayerTextDrawBackgroundColor(playerid, MDC_UI[playerid][35], 858993663);
		    PlayerTextDrawShow(playerid, MDC_UI[playerid][35]);

		    PlayerTextDrawHide(playerid, MDC_UI[playerid][39]);
		    PlayerTextDrawColor(playerid, MDC_UI[playerid][39], -1);
		    PlayerTextDrawShow(playerid, MDC_UI[playerid][39]);

		    PlayerTextDrawHide(playerid, MDC_UI[playerid][40]);
		    PlayerTextDrawColor(playerid, MDC_UI[playerid][40], 858993663);
		    PlayerTextDrawShow(playerid, MDC_UI[playerid][40]);

		    SetPVarInt(playerid, "Query_Mode", 0);
		}
		if(playertextid == MDC_UI[playerid][36])
		{
		    PlayerTextDrawHide(playerid, MDC_UI[playerid][39]);
		    PlayerTextDrawColor(playerid, MDC_UI[playerid][39], 858993663);
		    PlayerTextDrawShow(playerid, MDC_UI[playerid][39]);

		    PlayerTextDrawHide(playerid, MDC_UI[playerid][40]);
		    PlayerTextDrawColor(playerid, MDC_UI[playerid][40], -1);
		    PlayerTextDrawShow(playerid, MDC_UI[playerid][40]);

		    PlayerTextDrawHide(playerid, MDC_UI[playerid][35]);
		    PlayerTextDrawBackgroundColor(playerid, MDC_UI[playerid][35], -1431655681);
		    PlayerTextDrawShow(playerid, MDC_UI[playerid][35]);

		    PlayerTextDrawHide(playerid, MDC_UI[playerid][36]);
		    PlayerTextDrawBackgroundColor(playerid, MDC_UI[playerid][36], 858993663);
		    PlayerTextDrawShow(playerid, MDC_UI[playerid][36]);

		    SetPVarInt(playerid, "Query_Mode", 1);
		}
		if(playertextid == MDC_UI[playerid][37])
		{
		    if(!GetPVarInt(playerid, "Query_Mode"))
		    {
		    	ShowPlayerDialog(playerid, DIALOG_MDC_NAME, DIALOG_STYLE_INPUT, "Name Search - MDC", "Enter the persons full name to search below:", "Search", "<<");
		    }
		    else
		    {
		        ShowPlayerDialog(playerid, DIALOG_MDC_PLATE, DIALOG_STYLE_INPUT, "Plate Search - MDC", "Enter the vehicles full or partial plate to search below:", "Search", "<<");
		    }
		}
		for(new i = 10; i < 16; i ++)
		{
		    if(playertextid == MDC_UI[playerid][i])
		    {
				if(GetPVarInt(playerid, "LastPage_ID") != -1)
				{
				    PlayerTextDrawBackgroundColor(playerid, MDC_UI[playerid][GetPVarInt(playerid, "LastPage_ID")], -1431655681);
				    PlayerTextDrawHide(playerid, MDC_UI[playerid][GetPVarInt(playerid, "LastPage_ID")]);
				    PlayerTextDrawShow(playerid, MDC_UI[playerid][GetPVarInt(playerid, "LastPage_ID")]);
				    PlayerTextDrawColor(playerid, MDC_UI[playerid][GetPVarInt(playerid, "LastPage_ID")+6], 858993663);
				    PlayerTextDrawHide(playerid, MDC_UI[playerid][GetPVarInt(playerid, "LastPage_ID")+6]);
				    PlayerTextDrawShow(playerid, MDC_UI[playerid][GetPVarInt(playerid, "LastPage_ID")+6]);
			    }
			    PlayerTextDrawColor(playerid, MDC_UI[playerid][i+6], -1);
			    PlayerTextDrawHide(playerid, MDC_UI[playerid][i+6]);
			    PlayerTextDrawShow(playerid, MDC_UI[playerid][i+6]);

			    PlayerTextDrawHide(playerid, MDC_UI[playerid][i]);
			    PlayerTextDrawBackgroundColor(playerid, MDC_UI[playerid][i], 858993663);
			    PlayerTextDrawShow(playerid, MDC_UI[playerid][i]);
			    SetPVarInt(playerid, "LastPage_ID", i);
		        sendMessage(playerid, -1, "%d", i-10);
		        UpdateMDC(playerid, i-10);
		    }
		}
		if(playertextid == MDC_UI[playerid][3])
		{
		    CancelSelectTextDraw(playerid);
		    ToggleMDC(playerid, false);
		}
	}
	if (PlayerInfo[playerid][pViewingDealership])
	{
	    if(playertextid == Player_Static_Arrow[playerid])
	    {
		    PlayerInfo[playerid][pDealershipIndex] = GetPreviousDealershipCar(PlayerInfo[playerid][pDealershipIndex]);

			PlayerPlaySound(playerid, 1053, 0.0, 0.0, 0.0);
			UpdateDealershipPreview(playerid);
	    }
	    else if(playertextid == Player_Vehicles_Arrow[playerid][2])
	    {
		    PlayerInfo[playerid][pDealershipIndex] = GetNextDealershipCar(PlayerInfo[playerid][pDealershipIndex]);

			PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
			UpdateDealershipPreview(playerid);
	    }
		else
		{
		    new listitem = (PlayerInfo[playerid][pDealershipIndex] * 6);
			for(new i = 0; i < 6; i ++)
			{
                if(playertextid == Player_Vehicles[playerid][i])
                {
                    CancelSelectTextDraw(playerid);
                    HideDealershipPreview(playerid);
                    
					SubDealershipHolder[playerid] = SubDealershipHolderArr[playerid][i+listitem];
					new
					    index,
						d,
						str[128],
						caption[60]
					;

					index = SubDealershipHolder[playerid];
					d = PlayerInfo[playerid][pAtDealership];

					if(g_aDealershipData[index][eDealershipPrice] > PlayerInfo[playerid][pMoney])
						return SendServerMessage(playerid, "You need $%s to buy this. (Total: $%s)", MoneyFormat(g_aDealershipData[index][eDealershipPrice]), MoneyFormat(PlayerInfo[playerid][pMoney]));

					DealershipTotalCost[playerid] = g_aDealershipData[index][eDealershipPrice] + GetPVarInt(playerid, "InsPrice") + GetPVarInt(playerid, "LockPrice") + GetPVarInt(playerid, "ImmobPrice") + GetPVarInt(playerid, "AlarmPrice");

					format(caption, 60, "%s - {33AA33}%s", g_aDealershipData[index][eDealershipModel], MoneyFormat(DealershipTotalCost[playerid]));

					strcat(str, "Alarm\n");
					strcat(str, "Lock\n");
					strcat(str, "Immobiliser\n");
					strcat(str, "Insurance\n");
					strcat(str, "Colors\n");
					strcat(str, "No XM Installed\n");
					strcat(str, "{FFFF00}Purchase Vehicle\n");

					TogglePlayerControllable(playerid, 0);

					DealershipPlayerCar[playerid] =
						CreateVehicle(g_aDealershipData[index][eDealershipModelID], BusinessInfo[d][eBusinessInterior][0], BusinessInfo[d][eBusinessInterior][1], BusinessInfo[d][eBusinessInterior][2], 90.0, 0, 0, -1);

					PutPlayerInVehicle(playerid, DealershipPlayerCar[playerid], 0);

					printf("[DEBUG]: Player %s (ID : %i) was spawned in a Dealership vehicle. (Vehicle ID: %d)", ReturnName(playerid), playerid, DealershipPlayerCar[playerid]);
					ShowPlayerDialog(playerid, DIALOG_DEALERSHIP_APPEND, DIALOG_STYLE_LIST, caption, str, "Append", "<<");
                }
			}
		}
	}
	if(GetPVarInt(playerid, "Viewing_OwnedCarList"))
	{
	    for(new i = 0; i < 6; i ++)
	    {
	        if(playertextid == Player_Vehicles[playerid][i])
	        {
				if(!PlayerInfo[playerid][pOwnedVehicles][i+1])
					return SendErrorMessage(playerid, "You don't have a vehicle in that slot.");

				if(PlayerInfo[playerid][pVehicleSpawned] == true)
					return SendErrorMessage(playerid, "You already have a vehicle spawned.");

				static
					threadLoad[128]
				;

				for(new x = 0; x < MAX_VEHICLES; x++)
				{
					if(VehicleInfo[x][eVehicleDBID] == PlayerInfo[playerid][pOwnedVehicles][i+1])
						return SendErrorMessage(playerid, "That vehicle's already spawned.");
				}
				mysql_format(this, threadLoad, sizeof(threadLoad), "SELECT * FROM vehicles WHERE VehicleDBID = %i", PlayerInfo[playerid][pOwnedVehicles][i+1]);
				mysql_tquery(this, threadLoad, "Query_LoadPrivateVehicle", "i", playerid);
	        }
	    }
	}
	if(GetPVarInt(playerid, "MDCLayout") == 1)
	{
		new vehicleid = GetPlayerVehicleID(playerid);
		if(playertextid == MDC_Layout[playerid][4])
		{
		    if(!VehicleInfo[vehicleid][eVehicleSirenUsed][0])
		    {
		    	PlayerTextDrawSetString(playerid, MDC_Layout[playerid][4], "~g~On");
		    	SirenEvent(vehicleid, 0, true);
		    }
		    else
		    {
		        PlayerTextDrawSetString(playerid, MDC_Layout[playerid][4], "~g~Off");
		        SirenEvent(vehicleid, 0, false);
		    }
		}
		if(playertextid == MDC_Layout[playerid][6])
		{
		    if(!VehicleInfo[vehicleid][eVehicleSirenUsed][1])
		    {
		    	PlayerTextDrawSetString(playerid, MDC_Layout[playerid][6], "~g~On");
		    	SirenEvent(vehicleid, 1, true);
		    }
		    else
		    {
		        PlayerTextDrawSetString(playerid, MDC_Layout[playerid][6], "~g~Off");
		        SirenEvent(vehicleid, 1, false);
		    }
		}
		if(playertextid == MDC_Layout[playerid][8])
		{
		    if(!VehicleInfo[vehicleid][eVehicleSirenUsed][2])
		    {
		    	PlayerTextDrawSetString(playerid, MDC_Layout[playerid][8], "~g~On");
		    	SirenEvent(vehicleid, 2, true);
		    }
		    else
		    {
		        PlayerTextDrawSetString(playerid, MDC_Layout[playerid][8], "~g~Off");
		        SirenEvent(vehicleid, 2, false);
		    }
		}
		if(playertextid == MDC_Layout[playerid][11])
		{
		    if(!VehicleInfo[vehicleid][eVehicleSirenUsed][3])
		    {
		    	SirenEvent(vehicleid, 3, true);
		    }
		    else
		    {
		        SirenEvent(vehicleid, 3, false);
		    }
		}
	}
	if(GetPVarInt(playerid, "UsePayphone"))
	{
	    new qustr[128];
	    for(new i = 1; i < 10; i ++)
	    {
	    	if(playertextid == PP_Btn[playerid][i])
	    	{
				if(PlayerInfo[playerid][pCalling] > 0) return 1;
				if(strlen(PlayerInfo[playerid][pNumberStr]) >= 8) return 1;
	    	    format(PlayerInfo[playerid][pNumberStr], 64, "%s%d", PlayerInfo[playerid][pNumberStr], i);
				format(qustr, sizeof(qustr), "%s", PlayerInfo[playerid][pNumberStr]);
			    PlayerTextDrawSetString(playerid, PP_Btn[playerid][0], qustr);
	    	}
	    }
    	if(playertextid == PP_Btn[playerid][10])
    	{
			if(PlayerInfo[playerid][pCalling] > 0) return 1;
			if(strlen(PlayerInfo[playerid][pNumberStr]) >= 8) return 1;
    	    format(PlayerInfo[playerid][pNumberStr], 64, "%s0", PlayerInfo[playerid][pNumberStr]);
			format(qustr, sizeof(qustr), "%s", PlayerInfo[playerid][pNumberStr]);
		    PlayerTextDrawSetString(playerid, PP_Btn[playerid][0], qustr);
    	}
	}
	if(GetPVarInt(playerid, "ColorSelect") != 0)
	{
	    new offset = GetPVarInt(playerid, "index_color") * 8;
	    
	    for(new i; i < 8; i ++)
	    {
		    if(playertextid == ColorPanel[playerid][i])
		    {
		        if(GetPVarInt(playerid, "ColorSelect") == 1)
		        {
                    DealershipCarColors[playerid][0] = i+offset;
					ChangeVehicleColor(DealershipPlayerCar[playerid], i+offset, DealershipCarColors[playerid][1]);
		        }
		        else if(GetPVarInt(playerid, "ColorSelect") == 2)
		        {
		            DealershipCarColors[playerid][1] = i+offset;
					ChangeVehicleColor(DealershipPlayerCar[playerid], DealershipCarColors[playerid][0], i+offset);
		        }
		    }
	    }
	    if(playertextid == ColorPanel[playerid][9])
	    {
	        showNextColor(playerid);
	    }
	    if(playertextid == ColorPanel[playerid][8])
	    {
	        if(GetPVarInt(playerid, "ColorSelect") == 1)
	        {
	            SetPVarInt(playerid, "index_color", 0);
				for(new i; i < 8; i ++)
				{
				    PlayerTextDrawHide(playerid, ColorPanel[playerid][i]);
				    PlayerTextDrawBackgroundColor(playerid, ColorPanel[playerid][i], VehicleColoursTableRGBA[i]);
				    PlayerTextDrawShow(playerid, ColorPanel[playerid][i]);
				}
	            SetPVarInt(playerid, "ColorSelect", 2);
				PlayerTextDrawSetString(playerid, ColorPanel[playerid][8],"Secondary_Colors");
	        }
	        else if(GetPVarInt(playerid, "ColorSelect") == 2)
	        {
	        
	            SetPVarInt(playerid, "index_color", 0);
				for(new i; i < 8; i ++)
				{
				    PlayerTextDrawHide(playerid, ColorPanel[playerid][i]);
				    PlayerTextDrawBackgroundColor(playerid, ColorPanel[playerid][i], VehicleColoursTableRGBA[i]);
				    PlayerTextDrawShow(playerid, ColorPanel[playerid][i]);
				}
	            SetPVarInt(playerid, "ColorSelect", 1);
				PlayerTextDrawSetString(playerid, ColorPanel[playerid][8],"Primary_Colors");
	        }
	    }
	}
	if(PlayerInfo[playerid][pUseGUI])
	{
		if(playertextid == PhoneSwitch[playerid])
		{
		    if(!PlayerInfo[playerid][pCooldown])
		    {
		        PlayerInfo[playerid][pCooldown] = true;
            	Phone_Switch(playerid);
			}
		}
		if(playertextid == PhoneBtnL[playerid])
		{
		    if(cache_phone[playerid][current_page] == Page_Home) return 1;
		    cache_phone[playerid][current_page] = Page_Menu;
  			showPhoneMenu(playerid, true, cache_phone[playerid][current_page]);
		}
		if(playertextid == PhoneBtnR[playerid])
		{
		    if(PlayerInfo[playerid][pCalling]) return callcmd::hangup(playerid, "");

		    switch(cache_phone[playerid][current_page])
		    {
		        case Page_Menu: showPhoneMenu(playerid, false, cache_phone[playerid][current_page]);
		        case Page_Notebook: cache_phone[playerid][current_page] = Page_Menu, showPhoneMenu(playerid, false, cache_phone[playerid][current_page]), showPhoneMenu(playerid, true, cache_phone[playerid][current_page]);
		        case Page_Contact: cache_phone[playerid][current_page] = Page_Menu, showPhoneMenu(playerid, true, cache_phone[playerid][current_page]);
		        case Page_Setting: cache_phone[playerid][current_page] = Page_Menu, showPhoneMenu(playerid, true, cache_phone[playerid][current_page]);
		    }
		}
		if(playertextid == PhoneList[playerid][0])
		{
		    if(cache_phone[playerid][current_page] == Page_Menu)
		    {
		    	cache_phone[playerid][current_page] = Page_Notebook;
		    	showPhoneMenu(playerid, true, cache_phone[playerid][current_page]);
		    	return 1;
			}
			switch(cache_phone[playerid][current_page])
			{
			    case Page_Notebook: sendMessage(playerid, -1, "call called"); // dialog stuff
			    case Page_Contact: sendMessage(playerid, -1, "add contact called"); // dialog stuff
			    case Page_Setting: sendMessage(playerid, -1, "ringtone called"); // dialog stuff
			}
			
		}
		if(playertextid == PhoneList[playerid][1])
		{
		    if(cache_phone[playerid][current_page] == Page_Menu)
		    {
		    	cache_phone[playerid][current_page] = Page_Contact;
		    	showPhoneMenu(playerid, true, cache_phone[playerid][current_page]);
		    	return 1;
			}
			switch(cache_phone[playerid][current_page])
			{
			    case Page_Notebook: sendMessage(playerid, -1, "sms called");// dialog stuff
			    case Page_Contact: sendMessage(playerid, -1, "edit contact called");// dialog stuff
			    case Page_Setting: sendMessage(playerid, -1, "theme called");// dialog stuff
			}
		}
		if(playertextid == PhoneList[playerid][2])
		{
		    if(cache_phone[playerid][current_page] == Page_Menu)
		    {
		    	cache_phone[playerid][current_page] = Page_Setting;
		    	showPhoneMenu(playerid, true, cache_phone[playerid][current_page]);
		    	return 1;
			}
			switch(cache_phone[playerid][current_page])
			{
			    case Page_Notebook: sendMessage(playerid, -1, "Contact List called");// dialog stuff
			    case Page_Contact: sendMessage(playerid, -1, "Delete contact called");// dialog stuff
			    case Page_Setting: sendMessage(playerid, -1, "silent mode called");// dialog stuff
			}
		}
	}
	switch(PlayerInfo[playerid][pSelection])
	{
	    case EVENT_FOODMENU:
	    {
	        CancelSelectTextDraw(playerid);
	        new id = IsPlayerInBusiness(playerid);
		    if(playertextid == FoodOrder[playerid][4])
		    {
		         PlayerInfo[playerid][pSelection] = EVENT_OFF;
		         GiveMoney(playerid, -BusinessInfo[id][eBusinessFoodPrice][0]);
		         BusinessInfo[id][eBusinessProducts] --;
		         BusinessInfo[id][eBusinessCashbox] += BusinessInfo[id][eBusinessFoodPrice][0];
		         
		         OnPlayerFoodPurchase(playerid, BusinessInfo[id][eBusinessFood][0]);
		         ShowFoodMenu(playerid, false);
		         
		         return 1;
		    }
		    if(playertextid == FoodOrder[playerid][5])
		    {
		         PlayerInfo[playerid][pSelection] = EVENT_OFF;
		         GiveMoney(playerid, -BusinessInfo[id][eBusinessFoodPrice][1]);
                 BusinessInfo[id][eBusinessProducts] -= 2;
		    	 BusinessInfo[id][eBusinessCashbox] += BusinessInfo[id][eBusinessFoodPrice][1];
		    
		         OnPlayerFoodPurchase(playerid, BusinessInfo[id][eBusinessFood][1]);
		         ShowFoodMenu(playerid, false);
		         return 1;
		    }
		    if(playertextid == FoodOrder[playerid][6])
		    {
		         PlayerInfo[playerid][pSelection] = EVENT_OFF;
		         GiveMoney(playerid, -BusinessInfo[id][eBusinessFoodPrice][2]);
                 BusinessInfo[id][eBusinessProducts] -= 3;
		         BusinessInfo[id][eBusinessCashbox] += BusinessInfo[id][eBusinessFoodPrice][2];
		    
		         OnPlayerFoodPurchase(playerid, BusinessInfo[id][eBusinessFood][2]);
		         ShowFoodMenu(playerid, false);
		         return 1;
		    }
		    if(playertextid == FoodOrder[playerid][3])
		    {
		         ShowFoodMenu(playerid, false);
		         PlayerInfo[playerid][pSelection] = EVENT_OFF;
		         return 1;
		    }
	    }
    }
    return 0;
}

stock OnPlayerFoodPurchase(playerid, food_id)
{
	if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_CARRY) return
		SendErrorMessage(playerid, "You are holding something.");

	new Float: playerHealth;
	new mealID = Meal_FreeID();

	GetPlayerHealth(playerid, playerHealth);
	playerHealth += Food_Data[food_id][HealthPoint];
	SetPlayerHealth(playerid, (playerHealth > 100) ? 100.0 : playerHealth);

	//SetPlayerAttachedObject(playerid, 9, Food_Data[food_id][Model], 1, 0.004999, 0.529999, 0.126999, -83.200004, 115.999961, -31.799890, 0.500000, 0.816000, 0.500000);
	SetPlayerAttachedObject(playerid, SLOT_MEAL, Food_Data[food_id][Model], 1, 0.004999, 0.529999, 0.126999, -83.200004, 115.999961, -31.799890);
	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_CARRY);

	MealInfo[mealID][mPlayer] = playerid;
	MealInfo[mealID][mExists] = 1;
	MealInfo[mealID][mModel] = Food_Data[food_id][Model];

	PlayerInfo[playerid][pMeal] = mealID;
	SendClientMessage(playerid, -1, "Hint: You can drop meal /meal throw.");

	Iter_Add(Meals, mealID);
	return 1;
}

Meal_FreeID()
{
	if(Iter_Count(Meals) >= MAX_MEALS) foreach(new x : Meals) if(MealInfo[x][mPlayer] == -1)
 	{
 		Meal_Drop(x); return x;
	}

	return Iter_Free(Meals);
}

Meal_Drop(id)
{
	MealInfo[id][mPlayer] = -1;
	MealInfo[id][mExists] = 0;
	MealInfo[id][mModel] = 0;
	MealInfo[id][mPosX] = 0.0;
	MealInfo[id][mPosY] = 0.0;
	MealInfo[id][mPosZ] = 0.0;
	MealInfo[id][mInterior] = 0;
	MealInfo[id][mWorld] = 0;
	DestroyDynamicObject(MealInfo[id][mObject]);
	MealInfo[id][mEditing] = false;

	Iter_Remove(Meals, id);

	return 1;
}

GetNearestMeal(playerid)
{
    new mealid = PlayerInfo[playerid][pMeal];

	if(mealid != -1 && MealInfo[mealid][mExists])return
		PlayerInfo[playerid][pMeal];

    foreach(new i : Meals) if(MealInfo[i][mExists] && IsPlayerInRangeOfPoint(playerid, 2.5, MealInfo[i][mPosX], MealInfo[i][mPosY], MealInfo[i][mPosZ]) && GetPlayerInterior(playerid) == MealInfo[i][mInterior] && GetPlayerVirtualWorld(playerid) == MealInfo[i][mWorld])
	{
	    if(MealInfo[i][mPosX] == 0.0 && MealInfo[i][mPosY] == 0.0 && MealInfo[i][mPosZ] == 0.0)continue;

		if(MealInfo[i][mPlayer] == -1)
			return i;
	}

	return -1;
}

ShowBusinessConfig(playerid)
{
	new
	    id = IsPlayerInBusiness(playerid),
		list[256]
	;
	
	if(id != 0)
	{
		if(BusinessInfo[id][eBusinessOwnerDBID] != PlayerInfo[playerid][pDBID])
			return SendErrorMessage(playerid, "You don't own this business.");
			
        if(BusinessInfo[id][eBusinessType] != BUSINESS_TYPE_RESTAURANT)
            return SendErrorMessage(playerid, "This business is not a restaurant type.");
            
		format(list, sizeof(list), "Change restaurant type {C3C3C3}[%s]{FFFFFF}\nChange #1 price {C3C3C3}[%s, $%d]{FFFFFF}\nChange #2 price {C3C3C3}[%s, $%d]{FFFFFF}\nChange #3 price {C3C3C3}[%s, $%d]{FFFFFF}",
		ReturnRestaurantName(BusinessInfo[id][eBusinessRestaurantType]),
        ReturnFoodName(BusinessInfo[id][eBusinessFood][0]),
		BusinessInfo[id][eBusinessFoodPrice][0],
		ReturnFoodName(BusinessInfo[id][eBusinessFood][1]),
		BusinessInfo[id][eBusinessFoodPrice][1],
		ReturnFoodName(BusinessInfo[id][eBusinessFood][2]),
		BusinessInfo[id][eBusinessFoodPrice][2]);
		
		ShowPlayerDialog(playerid, DIALOG_FOOD_CONFIG, DIALOG_STYLE_LIST, "Restaurant Configuration", list, "Select", "Exit");
	}
	else return SendErrorMessage(playerid, "You aren't in a business.");
	return 1;
}

stock CreatePhoneGUI(playerid)
{
	PhoneFrame[playerid][0] = CreatePlayerTextDraw(playerid, 476.003417, 346.916748, "box");
	PlayerTextDrawLetterSize(playerid, PhoneFrame[playerid][0], 0.000000, 13.935577);
	PlayerTextDrawTextSize(playerid, PhoneFrame[playerid][0], 558.000000, 0.000000);
	PlayerTextDrawAlignment(playerid, PhoneFrame[playerid][0], 1);
	PlayerTextDrawColor(playerid, PhoneFrame[playerid][0], 255);
	PlayerTextDrawUseBox(playerid, PhoneFrame[playerid][0], 1);
	PlayerTextDrawBoxColor(playerid, PhoneFrame[playerid][0], 255);
	PlayerTextDrawSetShadow(playerid, PhoneFrame[playerid][0], 0);
	PlayerTextDrawSetOutline(playerid, PhoneFrame[playerid][0], 0);
	PlayerTextDrawBackgroundColor(playerid, PhoneFrame[playerid][0], 255);
	PlayerTextDrawFont(playerid, PhoneFrame[playerid][0], 1);
	PlayerTextDrawSetProportional(playerid, PhoneFrame[playerid][0], 1);
	PlayerTextDrawSetShadow(playerid, PhoneFrame[playerid][0], 0);

	PhoneFrame[playerid][1] = CreatePlayerTextDraw(playerid, 471.149597, 337.583282, "LD_DRV:TVCORN");
	PlayerTextDrawLetterSize(playerid, PhoneFrame[playerid][1], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, PhoneFrame[playerid][1], 45.000000, 111.000000);
	PlayerTextDrawAlignment(playerid, PhoneFrame[playerid][1], 1);
	PlayerTextDrawColor(playerid, PhoneFrame[playerid][1], -1);
	PlayerTextDrawSetShadow(playerid, PhoneFrame[playerid][1], 0);
	PlayerTextDrawSetOutline(playerid, PhoneFrame[playerid][1], 0);
	PlayerTextDrawBackgroundColor(playerid, PhoneFrame[playerid][1], 255);
	PlayerTextDrawFont(playerid, PhoneFrame[playerid][1], 4);
	PlayerTextDrawSetProportional(playerid, PhoneFrame[playerid][1], 0);
	PlayerTextDrawSetShadow(playerid, PhoneFrame[playerid][1], 0);

	PhoneFrame[playerid][2] = CreatePlayerTextDraw(playerid, 562.979858, 337.583221, "LD_DRV:TVCORN");
	PlayerTextDrawLetterSize(playerid, PhoneFrame[playerid][2], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, PhoneFrame[playerid][2], -47.000000, 112.000000);
	PlayerTextDrawAlignment(playerid, PhoneFrame[playerid][2], 1);
	PlayerTextDrawColor(playerid, PhoneFrame[playerid][2], -1);
	PlayerTextDrawSetShadow(playerid, PhoneFrame[playerid][2], 0);
	PlayerTextDrawSetOutline(playerid, PhoneFrame[playerid][2], 0);
	PlayerTextDrawBackgroundColor(playerid, PhoneFrame[playerid][2], 255);
	PlayerTextDrawFont(playerid, PhoneFrame[playerid][2], 4);
	PlayerTextDrawSetProportional(playerid, PhoneFrame[playerid][2], 0);
	PlayerTextDrawSetShadow(playerid, PhoneFrame[playerid][2], 0);

	PhoneLogo[playerid] = CreatePlayerTextDraw(playerid, 495.212463, 352.166748, "LS_Telefonica");
	PlayerTextDrawLetterSize(playerid, PhoneLogo[playerid], 0.206500, 0.940833);
	PlayerTextDrawAlignment(playerid, PhoneLogo[playerid], 1);
	PlayerTextDrawColor(playerid, PhoneLogo[playerid], -1);
	PlayerTextDrawSetShadow(playerid, PhoneLogo[playerid], 0);
	PlayerTextDrawSetOutline(playerid, PhoneLogo[playerid], 0);
	PlayerTextDrawBackgroundColor(playerid, PhoneLogo[playerid], 255);
	PlayerTextDrawFont(playerid, PhoneLogo[playerid], 1);
	PlayerTextDrawSetProportional(playerid, PhoneLogo[playerid], 1);
	PlayerTextDrawSetShadow(playerid, PhoneLogo[playerid], 0);

	PhoneSwitch[playerid] = CreatePlayerTextDraw(playerid, 546.581420, 347.499877, "LD_BEAT:circle");
	PlayerTextDrawLetterSize(playerid, PhoneSwitch[playerid], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, PhoneSwitch[playerid], 12.000000, 13.000000);
	PlayerTextDrawAlignment(playerid, PhoneSwitch[playerid], 1);
	PlayerTextDrawColor(playerid, PhoneSwitch[playerid], -1);
	PlayerTextDrawSetShadow(playerid, PhoneSwitch[playerid], 0);
	PlayerTextDrawSetOutline(playerid, PhoneSwitch[playerid], 0);
	PlayerTextDrawBackgroundColor(playerid, PhoneSwitch[playerid], 255);
	PlayerTextDrawFont(playerid, PhoneSwitch[playerid], 4);
	PlayerTextDrawSetProportional(playerid, PhoneSwitch[playerid], 0);
	PlayerTextDrawSetShadow(playerid, PhoneSwitch[playerid], 0);
	PlayerTextDrawSetSelectable(playerid, PhoneSwitch[playerid], true);

	PhoneInfo[playerid] = CreatePlayerTextDraw(playerid, 547.518432, 349.249816, "LD_BEAT:chit");
	PlayerTextDrawLetterSize(playerid, PhoneInfo[playerid], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, PhoneInfo[playerid], -6.000000, 6.000000);
	PlayerTextDrawAlignment(playerid, PhoneInfo[playerid], 1);
	PlayerTextDrawColor(playerid, PhoneInfo[playerid], -1);
	PlayerTextDrawSetShadow(playerid, PhoneInfo[playerid], 0);
	PlayerTextDrawSetOutline(playerid, PhoneInfo[playerid], 0);
	PlayerTextDrawBackgroundColor(playerid, PhoneInfo[playerid], 255);
	PlayerTextDrawFont(playerid, PhoneInfo[playerid], 4);
	PlayerTextDrawSetProportional(playerid, PhoneInfo[playerid], 0);
	PlayerTextDrawSetShadow(playerid, PhoneInfo[playerid], 0);

	PhoneDisplay[playerid] = CreatePlayerTextDraw(playerid, 483.031005, 367.916717, "box");
	PlayerTextDrawLetterSize(playerid, PhoneDisplay[playerid], 0.000000, 4.565154);
	PlayerTextDrawTextSize(playerid, PhoneDisplay[playerid], 551.000000, 0.000000);
	PlayerTextDrawAlignment(playerid, PhoneDisplay[playerid], 1);
	PlayerTextDrawColor(playerid, PhoneDisplay[playerid], -1);
	PlayerTextDrawUseBox(playerid, PhoneDisplay[playerid], 1);
	PlayerTextDrawBoxColor(playerid, PhoneDisplay[playerid], -572662273);
	PlayerTextDrawSetShadow(playerid, PhoneDisplay[playerid], 0);
	PlayerTextDrawSetOutline(playerid, PhoneDisplay[playerid], 0);
	PlayerTextDrawBackgroundColor(playerid, PhoneDisplay[playerid], 255);
	PlayerTextDrawFont(playerid, PhoneDisplay[playerid], 1);
	PlayerTextDrawSetProportional(playerid, PhoneDisplay[playerid], 1);
	PlayerTextDrawSetShadow(playerid, PhoneDisplay[playerid], 0);

/*	PhoneBtnL[playerid] = CreatePlayerTextDraw(playerid, 483.030639, 415.166503, "box");
	PlayerTextDrawLetterSize(playerid, PhoneBtnL[playerid], 0.000000, 0.535869);
	PlayerTextDrawTextSize(playerid, PhoneBtnL[playerid], 499.000000, 0.000000);
	PlayerTextDrawAlignment(playerid, PhoneBtnL[playerid], 1);
	PlayerTextDrawColor(playerid, PhoneBtnL[playerid], -1);
	PlayerTextDrawUseBox(playerid, PhoneBtnL[playerid], 1);
	PlayerTextDrawBoxColor(playerid, PhoneBtnL[playerid], -1717986817);
	PlayerTextDrawSetShadow(playerid, PhoneBtnL[playerid], 0);
	PlayerTextDrawSetOutline(playerid, PhoneBtnL[playerid], 0);
	PlayerTextDrawBackgroundColor(playerid, PhoneBtnL[playerid], 255);
	PlayerTextDrawFont(playerid, PhoneBtnL[playerid], 1);
	PlayerTextDrawSetProportional(playerid, PhoneBtnL[playerid], 1);
	PlayerTextDrawSetShadow(playerid, PhoneBtnL[playerid], 0);
	PlayerTextDrawSetSelectable(playerid, PhoneBtnL[playerid], true);

	PhoneBtnR[playerid] = CreatePlayerTextDraw(playerid, 555.182739, 415.166503, "box");
	PlayerTextDrawLetterSize(playerid, PhoneBtnR[playerid], 0.000000, 0.442165);
	PlayerTextDrawTextSize(playerid, PhoneBtnR[playerid], 531.000000, 0.000000);
	PlayerTextDrawAlignment(playerid, PhoneBtnR[playerid], 1);
	PlayerTextDrawColor(playerid, PhoneBtnR[playerid], -1);
	PlayerTextDrawUseBox(playerid, PhoneBtnR[playerid], 1);
	PlayerTextDrawBoxColor(playerid, PhoneBtnR[playerid], -1717986817);
	PlayerTextDrawSetShadow(playerid, PhoneBtnR[playerid], 0);
	PlayerTextDrawSetOutline(playerid, PhoneBtnR[playerid], 0);
	PlayerTextDrawBackgroundColor(playerid, PhoneBtnR[playerid], 255);
	PlayerTextDrawFont(playerid, PhoneBtnR[playerid], 1);
	PlayerTextDrawSetProportional(playerid, PhoneBtnR[playerid], 1);
	PlayerTextDrawSetShadow(playerid, PhoneBtnR[playerid], 0);
	PlayerTextDrawSetSelectable(playerid, PhoneBtnR[playerid], true);
	*/
	
	PhoneBtnL[playerid] = CreatePlayerTextDraw(playerid, 480.988555, 412.833404, "");
	PlayerTextDrawLetterSize(playerid, PhoneBtnL[playerid], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, PhoneBtnL[playerid], 19.000000, 10.000000);
	PlayerTextDrawAlignment(playerid, PhoneBtnL[playerid], 1);
	PlayerTextDrawColor(playerid, PhoneBtnL[playerid], -1717986817);
	PlayerTextDrawSetShadow(playerid, PhoneBtnL[playerid], 0);
	PlayerTextDrawSetOutline(playerid, PhoneBtnL[playerid], 0);
	PlayerTextDrawBackgroundColor(playerid, PhoneBtnL[playerid], -1717986817);
	PlayerTextDrawFont(playerid, PhoneBtnL[playerid], 5);
	PlayerTextDrawSetProportional(playerid, PhoneBtnL[playerid], 0);
	PlayerTextDrawSetShadow(playerid, PhoneBtnL[playerid], 0);
	PlayerTextDrawSetSelectable(playerid, PhoneBtnL[playerid], true);
	PlayerTextDrawSetPreviewModel(playerid, PhoneBtnL[playerid], 0);
	PlayerTextDrawSetPreviewRot(playerid, PhoneBtnL[playerid], 0.000000, 0.000000, 0.000000, -1.000000);

	PhoneBtnR[playerid] = CreatePlayerTextDraw(playerid, 533.932189, 412.833404, "");
	PlayerTextDrawLetterSize(playerid, PhoneBtnR[playerid], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, PhoneBtnR[playerid], 19.000000, 10.000000);
	PlayerTextDrawAlignment(playerid, PhoneBtnR[playerid], 1);
	PlayerTextDrawColor(playerid, PhoneBtnR[playerid], -1717986817);
	PlayerTextDrawSetShadow(playerid, PhoneBtnR[playerid], 0);
	PlayerTextDrawSetOutline(playerid, PhoneBtnR[playerid], 0);
	PlayerTextDrawBackgroundColor(playerid, PhoneBtnR[playerid], -1717986817);
	PlayerTextDrawFont(playerid, PhoneBtnR[playerid], 5);
	PlayerTextDrawSetProportional(playerid, PhoneBtnR[playerid], 0);
	PlayerTextDrawSetShadow(playerid, PhoneBtnR[playerid], 0);
	PlayerTextDrawSetSelectable(playerid, PhoneBtnR[playerid], true);
	PlayerTextDrawSetPreviewModel(playerid, PhoneBtnR[playerid], 0);
	PlayerTextDrawSetPreviewRot(playerid, PhoneBtnR[playerid], 0.000000, 0.000000, 0.000000, -1.000000);
	
	PhoneArrowUp[playerid] = CreatePlayerTextDraw(playerid, 511.442016, 444.916625, "LD_BEAT:UP");
	PlayerTextDrawLetterSize(playerid, PhoneArrowUp[playerid], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, PhoneArrowUp[playerid], 12.000000, -13.000000);
	PlayerTextDrawAlignment(playerid, PhoneArrowUp[playerid], 1);
	PlayerTextDrawColor(playerid, PhoneArrowUp[playerid], -1);
	PlayerTextDrawSetShadow(playerid, PhoneArrowUp[playerid], 0);
	PlayerTextDrawSetOutline(playerid, PhoneArrowUp[playerid], 0);
	PlayerTextDrawBackgroundColor(playerid, PhoneArrowUp[playerid], 255);
	PlayerTextDrawFont(playerid, PhoneArrowUp[playerid], 4);
	PlayerTextDrawSetProportional(playerid, PhoneArrowUp[playerid], 0);
	PlayerTextDrawSetShadow(playerid, PhoneArrowUp[playerid], 0);
	PlayerTextDrawSetSelectable(playerid, PhoneArrowUp[playerid], true);

	PhoneArrowDown[playerid] = CreatePlayerTextDraw(playerid, 511.442016, 426.833068, "LD_BEAT:DOWN");
	PlayerTextDrawLetterSize(playerid, PhoneArrowDown[playerid], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, PhoneArrowDown[playerid], 12.000000, -13.000000);
	PlayerTextDrawAlignment(playerid, PhoneArrowDown[playerid], 1);
	PlayerTextDrawColor(playerid, PhoneArrowDown[playerid], -1);
	PlayerTextDrawSetShadow(playerid, PhoneArrowDown[playerid], 0);
	PlayerTextDrawSetOutline(playerid, PhoneArrowDown[playerid], 0);
	PlayerTextDrawBackgroundColor(playerid, PhoneArrowDown[playerid], 255);
	PlayerTextDrawFont(playerid, PhoneArrowDown[playerid], 4);
	PlayerTextDrawSetProportional(playerid, PhoneArrowDown[playerid], 0);
	PlayerTextDrawSetShadow(playerid, PhoneArrowDown[playerid], 0);
	PlayerTextDrawSetSelectable(playerid, PhoneArrowDown[playerid], true);

	PhoneArrowLeft[playerid] = CreatePlayerTextDraw(playerid, 501.603393, 434.999847, "LD_BEAT:LEFT");
	PlayerTextDrawLetterSize(playerid, PhoneArrowLeft[playerid], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, PhoneArrowLeft[playerid], 12.000000, -13.000000);
	PlayerTextDrawAlignment(playerid, PhoneArrowLeft[playerid], 1);
	PlayerTextDrawColor(playerid, PhoneArrowLeft[playerid], -1);
	PlayerTextDrawSetShadow(playerid, PhoneArrowLeft[playerid], 0);
	PlayerTextDrawSetOutline(playerid, PhoneArrowLeft[playerid], 0);
	PlayerTextDrawBackgroundColor(playerid, PhoneArrowLeft[playerid], 255);
	PlayerTextDrawFont(playerid, PhoneArrowLeft[playerid], 4);
	PlayerTextDrawSetProportional(playerid, PhoneArrowLeft[playerid], 0);
	PlayerTextDrawSetShadow(playerid, PhoneArrowLeft[playerid], 0);
	PlayerTextDrawSetSelectable(playerid, PhoneArrowLeft[playerid], true);

	PhoneArrowRight[playerid] = CreatePlayerTextDraw(playerid, 520.812255, 435.583221, "LD_BEAT:RIGHT");
	PlayerTextDrawLetterSize(playerid, PhoneArrowRight[playerid], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, PhoneArrowRight[playerid], 12.000000, -13.000000);
	PlayerTextDrawAlignment(playerid, PhoneArrowRight[playerid], 1);
	PlayerTextDrawColor(playerid, PhoneArrowRight[playerid], -1);
	PlayerTextDrawSetShadow(playerid, PhoneArrowRight[playerid], 0);
	PlayerTextDrawSetOutline(playerid, PhoneArrowRight[playerid], 0);
	PlayerTextDrawBackgroundColor(playerid, PhoneArrowRight[playerid], 255);
	PlayerTextDrawFont(playerid, PhoneArrowRight[playerid], 4);
	PlayerTextDrawSetProportional(playerid, PhoneArrowRight[playerid], 0);
	PlayerTextDrawSetShadow(playerid, PhoneArrowRight[playerid], 0);
	PlayerTextDrawSetSelectable(playerid, PhoneArrowRight[playerid], true);

	PhoneBtnMenu[playerid] = CreatePlayerTextDraw(playerid, 490.995941, 399.416625, "Menu");
	PlayerTextDrawLetterSize(playerid, PhoneBtnMenu[playerid], 0.156368, 0.929166);
	//PlayerTextDrawTextSize(playerid, PhoneBtnMenu[playerid], 15.000000, 21.000000);
	PlayerTextDrawAlignment(playerid, PhoneBtnMenu[playerid], 2);
	PlayerTextDrawColor(playerid, PhoneBtnMenu[playerid], 255);
	//PlayerTextDrawUseBox(playerid, PhoneBtnMenu[playerid], 1);
	PlayerTextDrawBoxColor(playerid, PhoneBtnMenu[playerid], 0);
	PlayerTextDrawSetShadow(playerid, PhoneBtnMenu[playerid], 0);
	PlayerTextDrawSetOutline(playerid, PhoneBtnMenu[playerid], 0);
	PlayerTextDrawBackgroundColor(playerid, PhoneBtnMenu[playerid], 255);
	PlayerTextDrawFont(playerid, PhoneBtnMenu[playerid], 1);
	PlayerTextDrawSetProportional(playerid, PhoneBtnMenu[playerid], 1);
	PlayerTextDrawSetShadow(playerid, PhoneBtnMenu[playerid], 0);
	//PlayerTextDrawSetSelectable(playerid, PhoneBtnMenu[playerid], true);

	PhoneBtnBack[playerid] = CreatePlayerTextDraw(playerid, 543.470092, 399.416625, "Back");
	PlayerTextDrawLetterSize(playerid, PhoneBtnBack[playerid], 0.156368, 0.929166);
	//PlayerTextDrawTextSize(playerid, PhoneBtnBack[playerid], 0.000000, -21.000000);
	PlayerTextDrawAlignment(playerid, PhoneBtnBack[playerid], 2);
	PlayerTextDrawColor(playerid, PhoneBtnBack[playerid], 255);
	//PlayerTextDrawUseBox(playerid, PhoneBtnBack[playerid], 1);
	PlayerTextDrawBoxColor(playerid, PhoneBtnBack[playerid], 0);
	PlayerTextDrawSetShadow(playerid, PhoneBtnBack[playerid], 0);
	PlayerTextDrawSetOutline(playerid, PhoneBtnBack[playerid], 0);
	PlayerTextDrawBackgroundColor(playerid, PhoneBtnBack[playerid], 255);
	PlayerTextDrawFont(playerid, PhoneBtnBack[playerid], 1);
	PlayerTextDrawSetProportional(playerid, PhoneBtnBack[playerid], 1);
	PlayerTextDrawSetShadow(playerid, PhoneBtnBack[playerid], 0);
	//PlayerTextDrawSetSelectable(playerid, PhoneBtnBack[playerid], true);

	PhoneTime[playerid] = CreatePlayerTextDraw(playerid, 503.177520, 374.333282, "17:00");
	PlayerTextDrawLetterSize(playerid, PhoneTime[playerid], 0.295519, 1.127499);
	PlayerTextDrawAlignment(playerid, PhoneTime[playerid], 1);
	PlayerTextDrawColor(playerid, PhoneTime[playerid], 255);
	PlayerTextDrawSetShadow(playerid, PhoneTime[playerid], 0);
	PlayerTextDrawSetOutline(playerid, PhoneTime[playerid], 0);
	PlayerTextDrawBackgroundColor(playerid, PhoneTime[playerid], 255);
	PlayerTextDrawFont(playerid, PhoneTime[playerid], 1);
	PlayerTextDrawSetProportional(playerid, PhoneTime[playerid], 1);
	PlayerTextDrawSetShadow(playerid, PhoneTime[playerid], 0);

	PhoneDate[playerid] = CreatePlayerTextDraw(playerid, 517.701782, 384.249908, "November_1");
	PlayerTextDrawLetterSize(playerid, PhoneDate[playerid], 0.182137, 0.934999);
	PlayerTextDrawAlignment(playerid, PhoneDate[playerid], 2);
	PlayerTextDrawColor(playerid, PhoneDate[playerid], 255);
	PlayerTextDrawSetShadow(playerid, PhoneDate[playerid], 0);
	PlayerTextDrawSetOutline(playerid, PhoneDate[playerid], 0);
	PlayerTextDrawBackgroundColor(playerid, PhoneDate[playerid], 255);
	PlayerTextDrawFont(playerid, PhoneDate[playerid], 1);
	PlayerTextDrawSetProportional(playerid, PhoneDate[playerid], 1);
	PlayerTextDrawSetShadow(playerid, PhoneDate[playerid], 0);

	PhoneSignal[playerid] = CreatePlayerTextDraw(playerid, 483.030761, 366.166687, "IIIIII");
	PlayerTextDrawLetterSize(playerid, PhoneSignal[playerid], 0.162927, 0.789166);
	PlayerTextDrawAlignment(playerid, PhoneSignal[playerid], 1);
	PlayerTextDrawColor(playerid, PhoneSignal[playerid], 255);
	PlayerTextDrawSetShadow(playerid, PhoneSignal[playerid], 0);
	PlayerTextDrawSetOutline(playerid, PhoneSignal[playerid], 0);
	PlayerTextDrawBackgroundColor(playerid, PhoneSignal[playerid], 255);
	PlayerTextDrawFont(playerid, PhoneSignal[playerid], 1);
	PlayerTextDrawSetProportional(playerid, PhoneSignal[playerid], 1);
	PlayerTextDrawSetShadow(playerid, PhoneSignal[playerid], 0);

	PhonePower[playerid] = CreatePlayerTextDraw(playerid, 544.407287, 366.166625, "100%");
	PlayerTextDrawLetterSize(playerid, PhonePower[playerid], 0.162927, 0.789166);
	PlayerTextDrawAlignment(playerid, PhonePower[playerid], 2);
	PlayerTextDrawColor(playerid, PhonePower[playerid], 255);
	PlayerTextDrawSetShadow(playerid, PhonePower[playerid], 0);
	PlayerTextDrawSetOutline(playerid, PhonePower[playerid], 0);
	PlayerTextDrawBackgroundColor(playerid, PhonePower[playerid], 255);
	PlayerTextDrawFont(playerid, PhonePower[playerid], 1);
	PlayerTextDrawSetProportional(playerid, PhonePower[playerid], 1);
	PlayerTextDrawSetShadow(playerid, PhonePower[playerid], 0);

	PhoneNotify[playerid] = CreatePlayerTextDraw(playerid, 516.764465, 366.749969, "_");
	PlayerTextDrawLetterSize(playerid, PhoneNotify[playerid], 0.136690, 0.742499);
	PlayerTextDrawAlignment(playerid, PhoneNotify[playerid], 2);
	PlayerTextDrawColor(playerid, PhoneNotify[playerid], -16776961);
	PlayerTextDrawSetShadow(playerid, PhoneNotify[playerid], 0);
	PlayerTextDrawSetOutline(playerid, PhoneNotify[playerid], 0);
	PlayerTextDrawBackgroundColor(playerid, PhoneNotify[playerid], 255);
	PlayerTextDrawFont(playerid, PhoneNotify[playerid], 1);
	PlayerTextDrawSetProportional(playerid, PhoneNotify[playerid], 1);
	PlayerTextDrawSetShadow(playerid, PhoneNotify[playerid], 0);
	//PlayerTextDrawSetSelectable(playerid, PhoneNotify[playerid], true);
	
	PhoneListName[playerid] = CreatePlayerTextDraw(playerid, 518.170104, 368.500061, "Notebook~n~Contact~n~Setting");
	PlayerTextDrawLetterSize(playerid, PhoneListName[playerid], 0.176983, 1.465832);
	PlayerTextDrawAlignment(playerid, PhoneListName[playerid], 2);
	PlayerTextDrawColor(playerid, PhoneListName[playerid], 255);
	PlayerTextDrawSetShadow(playerid, PhoneListName[playerid], 0);
	PlayerTextDrawSetOutline(playerid, PhoneListName[playerid], 0);
	PlayerTextDrawBackgroundColor(playerid, PhoneListName[playerid], 255);
	PlayerTextDrawFont(playerid, PhoneListName[playerid], 2);
	PlayerTextDrawSetProportional(playerid, PhoneListName[playerid], 1);
	PlayerTextDrawSetShadow(playerid, PhoneListName[playerid], 0);

	PhoneList[playerid][0] = CreatePlayerTextDraw(playerid, 483.799438, 369.666717, "");
	PlayerTextDrawLetterSize(playerid, PhoneList[playerid][0], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, PhoneList[playerid][0], 66.000000, 12.000000);
	PlayerTextDrawAlignment(playerid, PhoneList[playerid][0], 1);
	PlayerTextDrawColor(playerid, PhoneList[playerid][0], -2139062017);
	PlayerTextDrawSetShadow(playerid, PhoneList[playerid][0], 0);
	PlayerTextDrawSetOutline(playerid, PhoneList[playerid][0], 0);
	PlayerTextDrawBackgroundColor(playerid, PhoneList[playerid][0], -1717986817);
	PlayerTextDrawFont(playerid, PhoneList[playerid][0], 5);
	PlayerTextDrawSetProportional(playerid, PhoneList[playerid][0], 0);
	PlayerTextDrawSetShadow(playerid, PhoneList[playerid][0], 0);
	PlayerTextDrawSetSelectable(playerid, PhoneList[playerid][0], true);
	PlayerTextDrawSetPreviewModel(playerid, PhoneList[playerid][0], 0);
	PlayerTextDrawSetPreviewRot(playerid, PhoneList[playerid][0], 0.000000, 0.000000, 0.000000, -2.000000);

	PhoneList[playerid][1] = CreatePlayerTextDraw(playerid, 483.799407, 383.083465, "");
	PlayerTextDrawLetterSize(playerid, PhoneList[playerid][1], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, PhoneList[playerid][1], 66.000000, 12.000000);
	PlayerTextDrawAlignment(playerid, PhoneList[playerid][1], 1);
	PlayerTextDrawColor(playerid, PhoneList[playerid][1], -2139062017);
	PlayerTextDrawSetShadow(playerid, PhoneList[playerid][1], 0);
	PlayerTextDrawSetOutline(playerid, PhoneList[playerid][1], 0);
	PlayerTextDrawBackgroundColor(playerid, PhoneList[playerid][1], -1717986817);
	PlayerTextDrawFont(playerid, PhoneList[playerid][1], 5);
	PlayerTextDrawSetProportional(playerid, PhoneList[playerid][1], 0);
	PlayerTextDrawSetShadow(playerid, PhoneList[playerid][1], 0);
	PlayerTextDrawSetSelectable(playerid, PhoneList[playerid][1], true);
	PlayerTextDrawSetPreviewModel(playerid, PhoneList[playerid][1], 0);
	PlayerTextDrawSetPreviewRot(playerid, PhoneList[playerid][1], 0.000000, 0.000000, 0.000000, -2.000000);

	PhoneList[playerid][2] = CreatePlayerTextDraw(playerid, 484.267944, 396.500244, "");
	PlayerTextDrawLetterSize(playerid, PhoneList[playerid][2], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, PhoneList[playerid][2], 66.000000, 12.000000);
	PlayerTextDrawAlignment(playerid, PhoneList[playerid][2], 1);
	PlayerTextDrawColor(playerid, PhoneList[playerid][2], -2139062017);
	PlayerTextDrawSetShadow(playerid, PhoneList[playerid][2], 0);
	PlayerTextDrawSetOutline(playerid, PhoneList[playerid][2], 0);
	PlayerTextDrawBackgroundColor(playerid, PhoneList[playerid][2], -1717986817);
	PlayerTextDrawFont(playerid, PhoneList[playerid][2], 5);
	PlayerTextDrawSetProportional(playerid, PhoneList[playerid][2], 0);
	PlayerTextDrawSetShadow(playerid, PhoneList[playerid][2], 0);
	PlayerTextDrawSetSelectable(playerid, PhoneList[playerid][2], true);
	PlayerTextDrawSetPreviewModel(playerid, PhoneList[playerid][2], 0);
	PlayerTextDrawSetPreviewRot(playerid, PhoneList[playerid][2], 0.000000, 0.000000, 0.000000, -2.000000);
	
	PP_Btn[playerid][0] = CreatePlayerTextDraw(playerid, 497.554870, 219.749984, "998");
	PlayerTextDrawLetterSize(playerid, PP_Btn[playerid][0], 0.494641, 1.932500);
	PlayerTextDrawAlignment(playerid, PP_Btn[playerid][0], 1);
	PlayerTextDrawColor(playerid, PP_Btn[playerid][0], 255);
	PlayerTextDrawSetShadow(playerid, PP_Btn[playerid][0], 0);
	PlayerTextDrawSetOutline(playerid, PP_Btn[playerid][0], 0);
	PlayerTextDrawBackgroundColor(playerid, PP_Btn[playerid][0], 255);
	PlayerTextDrawFont(playerid, PP_Btn[playerid][0], 1);
	PlayerTextDrawSetProportional(playerid, PP_Btn[playerid][0], 1);
	PlayerTextDrawSetShadow(playerid, PP_Btn[playerid][0], 0);

	PP_Btn[playerid][1] = CreatePlayerTextDraw(playerid, 498.323608, 283.333190, "");
	PlayerTextDrawLetterSize(playerid, PP_Btn[playerid][1], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, PP_Btn[playerid][1], 20.000000, 22.000000);
	PlayerTextDrawAlignment(playerid, PP_Btn[playerid][1], 1);
	PlayerTextDrawColor(playerid, PP_Btn[playerid][1], -1);
	PlayerTextDrawSetShadow(playerid, PP_Btn[playerid][1], 0);
	PlayerTextDrawSetOutline(playerid, PP_Btn[playerid][1], 0);
	PlayerTextDrawBackgroundColor(playerid, PP_Btn[playerid][1], 1431655935);
	PlayerTextDrawFont(playerid, PP_Btn[playerid][1], 5);
	PlayerTextDrawSetProportional(playerid, PP_Btn[playerid][1], 0);
	PlayerTextDrawSetShadow(playerid, PP_Btn[playerid][1], 0);
	PlayerTextDrawSetSelectable(playerid, PP_Btn[playerid][1], true);
	PlayerTextDrawSetPreviewModel(playerid, PP_Btn[playerid][1], 0);
	PlayerTextDrawSetPreviewRot(playerid, PP_Btn[playerid][1], 0.000000, 0.000000, 0.000000, -1.000000);

	PP_Btn[playerid][2] = CreatePlayerTextDraw(playerid, 524.092468, 283.333221, "");
	PlayerTextDrawLetterSize(playerid, PP_Btn[playerid][2], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, PP_Btn[playerid][2], 20.000000, 22.000000);
	PlayerTextDrawAlignment(playerid, PP_Btn[playerid][2], 1);
	PlayerTextDrawColor(playerid, PP_Btn[playerid][2], -1);
	PlayerTextDrawSetShadow(playerid, PP_Btn[playerid][2], 0);
	PlayerTextDrawSetOutline(playerid, PP_Btn[playerid][2], 0);
	PlayerTextDrawBackgroundColor(playerid, PP_Btn[playerid][2], 1431655935);
	PlayerTextDrawFont(playerid, PP_Btn[playerid][2], 5);
	PlayerTextDrawSetProportional(playerid, PP_Btn[playerid][2], 0);
	PlayerTextDrawSetShadow(playerid, PP_Btn[playerid][2], 0);
	PlayerTextDrawSetSelectable(playerid, PP_Btn[playerid][2], true);
	PlayerTextDrawSetPreviewModel(playerid, PP_Btn[playerid][2], 0);
	PlayerTextDrawSetPreviewRot(playerid, PP_Btn[playerid][2], 0.000000, 0.000000, 0.000000, -1.000000);

	PP_Btn[playerid][3] = CreatePlayerTextDraw(playerid, 550.329467, 283.333190, "");
	PlayerTextDrawLetterSize(playerid, PP_Btn[playerid][3], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, PP_Btn[playerid][3], 20.000000, 22.000000);
	PlayerTextDrawAlignment(playerid, PP_Btn[playerid][3], 1);
	PlayerTextDrawColor(playerid, PP_Btn[playerid][3], -1);
	PlayerTextDrawSetShadow(playerid, PP_Btn[playerid][3], 0);
	PlayerTextDrawSetOutline(playerid, PP_Btn[playerid][3], 0);
	PlayerTextDrawBackgroundColor(playerid, PP_Btn[playerid][3], 1431655935);
	PlayerTextDrawFont(playerid, PP_Btn[playerid][3], 5);
	PlayerTextDrawSetProportional(playerid, PP_Btn[playerid][3], 0);
	PlayerTextDrawSetShadow(playerid, PP_Btn[playerid][3], 0);
	PlayerTextDrawSetSelectable(playerid, PP_Btn[playerid][3], true);
	PlayerTextDrawSetPreviewModel(playerid, PP_Btn[playerid][3], 0);
	PlayerTextDrawSetPreviewRot(playerid, PP_Btn[playerid][3], 0.000000, 0.000000, 0.000000, -1.000000);

	PP_Btn[playerid][4] = CreatePlayerTextDraw(playerid, 498.791992, 311.916625, "");
	PlayerTextDrawLetterSize(playerid, PP_Btn[playerid][4], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, PP_Btn[playerid][4], 20.000000, 22.000000);
	PlayerTextDrawAlignment(playerid, PP_Btn[playerid][4], 1);
	PlayerTextDrawColor(playerid, PP_Btn[playerid][4], -1);
	PlayerTextDrawSetShadow(playerid, PP_Btn[playerid][4], 0);
	PlayerTextDrawSetOutline(playerid, PP_Btn[playerid][4], 0);
	PlayerTextDrawBackgroundColor(playerid, PP_Btn[playerid][4], 1431655935);
	PlayerTextDrawFont(playerid, PP_Btn[playerid][4], 5);
	PlayerTextDrawSetProportional(playerid, PP_Btn[playerid][4], 0);
	PlayerTextDrawSetShadow(playerid, PP_Btn[playerid][4], 0);
	PlayerTextDrawSetSelectable(playerid, PP_Btn[playerid][4], true);
	PlayerTextDrawSetPreviewModel(playerid, PP_Btn[playerid][4], 0);
	PlayerTextDrawSetPreviewRot(playerid, PP_Btn[playerid][4], 0.000000, 0.000000, 0.000000, -1.000000);

	PP_Btn[playerid][5] = CreatePlayerTextDraw(playerid, 524.560607, 311.333282, "");
	PlayerTextDrawLetterSize(playerid, PP_Btn[playerid][5], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, PP_Btn[playerid][5], 20.000000, 22.000000);
	PlayerTextDrawAlignment(playerid, PP_Btn[playerid][5], 1);
	PlayerTextDrawColor(playerid, PP_Btn[playerid][5], -1);
	PlayerTextDrawSetShadow(playerid, PP_Btn[playerid][5], 0);
	PlayerTextDrawSetOutline(playerid, PP_Btn[playerid][5], 0);
	PlayerTextDrawBackgroundColor(playerid, PP_Btn[playerid][5], 1431655935);
	PlayerTextDrawFont(playerid, PP_Btn[playerid][5], 5);
	PlayerTextDrawSetProportional(playerid, PP_Btn[playerid][5], 0);
	PlayerTextDrawSetShadow(playerid, PP_Btn[playerid][5], 0);
	PlayerTextDrawSetSelectable(playerid, PP_Btn[playerid][5], true);
	PlayerTextDrawSetPreviewModel(playerid, PP_Btn[playerid][5], 0);
	PlayerTextDrawSetPreviewRot(playerid, PP_Btn[playerid][5], 0.000000, 0.000000, 0.000000, -1.000000);

	PP_Btn[playerid][6] = CreatePlayerTextDraw(playerid, 550.328979, 310.749938, "");
	PlayerTextDrawLetterSize(playerid, PP_Btn[playerid][6], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, PP_Btn[playerid][6], 20.000000, 22.000000);
	PlayerTextDrawAlignment(playerid, PP_Btn[playerid][6], 1);
	PlayerTextDrawColor(playerid, PP_Btn[playerid][6], -1);
	PlayerTextDrawSetShadow(playerid, PP_Btn[playerid][6], 0);
	PlayerTextDrawSetOutline(playerid, PP_Btn[playerid][6], 0);
	PlayerTextDrawBackgroundColor(playerid, PP_Btn[playerid][6], 1431655935);
	PlayerTextDrawFont(playerid, PP_Btn[playerid][6], 5);
	PlayerTextDrawSetProportional(playerid, PP_Btn[playerid][6], 0);
	PlayerTextDrawSetShadow(playerid, PP_Btn[playerid][6], 0);
	PlayerTextDrawSetSelectable(playerid, PP_Btn[playerid][6], true);
	PlayerTextDrawSetPreviewModel(playerid, PP_Btn[playerid][6], 0);
	PlayerTextDrawSetPreviewRot(playerid, PP_Btn[playerid][6], 0.000000, 0.000000, 0.000000, -1.000000);

	PP_Btn[playerid][7] = CreatePlayerTextDraw(playerid, 498.791534, 338.749969, "");
	PlayerTextDrawLetterSize(playerid, PP_Btn[playerid][7], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, PP_Btn[playerid][7], 20.000000, 22.000000);
	PlayerTextDrawAlignment(playerid, PP_Btn[playerid][7], 1);
	PlayerTextDrawColor(playerid, PP_Btn[playerid][7], -1);
	PlayerTextDrawSetShadow(playerid, PP_Btn[playerid][7], 0);
	PlayerTextDrawSetOutline(playerid, PP_Btn[playerid][7], 0);
	PlayerTextDrawBackgroundColor(playerid, PP_Btn[playerid][7], 1431655935);
	PlayerTextDrawFont(playerid, PP_Btn[playerid][7], 5);
	PlayerTextDrawSetProportional(playerid, PP_Btn[playerid][7], 0);
	PlayerTextDrawSetShadow(playerid, PP_Btn[playerid][7], 0);
	PlayerTextDrawSetSelectable(playerid, PP_Btn[playerid][7], true);
	PlayerTextDrawSetPreviewModel(playerid, PP_Btn[playerid][7], 0);
	PlayerTextDrawSetPreviewRot(playerid, PP_Btn[playerid][7], 0.000000, 0.000000, 0.000000, -1.000000);

	PP_Btn[playerid][8] = CreatePlayerTextDraw(playerid, 525.028747, 338.749969, "");
	PlayerTextDrawLetterSize(playerid, PP_Btn[playerid][8], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, PP_Btn[playerid][8], 20.000000, 22.000000);
	PlayerTextDrawAlignment(playerid, PP_Btn[playerid][8], 1);
	PlayerTextDrawColor(playerid, PP_Btn[playerid][8], -1);
	PlayerTextDrawSetShadow(playerid, PP_Btn[playerid][8], 0);
	PlayerTextDrawSetOutline(playerid, PP_Btn[playerid][8], 0);
	PlayerTextDrawBackgroundColor(playerid, PP_Btn[playerid][8], 1431655935);
	PlayerTextDrawFont(playerid, PP_Btn[playerid][8], 5);
	PlayerTextDrawSetProportional(playerid, PP_Btn[playerid][8], 0);
	PlayerTextDrawSetShadow(playerid, PP_Btn[playerid][8], 0);
	PlayerTextDrawSetSelectable(playerid, PP_Btn[playerid][8], true);
	PlayerTextDrawSetPreviewModel(playerid, PP_Btn[playerid][8], 0);
	PlayerTextDrawSetPreviewRot(playerid, PP_Btn[playerid][8], 0.000000, 0.000000, 0.000000, -1.000000);

	PP_Btn[playerid][9] = CreatePlayerTextDraw(playerid, 550.329162, 338.749938, "");
	PlayerTextDrawLetterSize(playerid, PP_Btn[playerid][9], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, PP_Btn[playerid][9], 20.000000, 22.000000);
	PlayerTextDrawAlignment(playerid, PP_Btn[playerid][9], 1);
	PlayerTextDrawColor(playerid, PP_Btn[playerid][9], -1);
	PlayerTextDrawSetShadow(playerid, PP_Btn[playerid][9], 0);
	PlayerTextDrawSetOutline(playerid, PP_Btn[playerid][9], 0);
	PlayerTextDrawBackgroundColor(playerid, PP_Btn[playerid][9], 1431655935);
	PlayerTextDrawFont(playerid, PP_Btn[playerid][9], 5);
	PlayerTextDrawSetProportional(playerid, PP_Btn[playerid][9], 0);
	PlayerTextDrawSetShadow(playerid, PP_Btn[playerid][9], 0);
	PlayerTextDrawSetSelectable(playerid, PP_Btn[playerid][9], true);
	PlayerTextDrawSetPreviewModel(playerid, PP_Btn[playerid][9], 0);
	PlayerTextDrawSetPreviewRot(playerid, PP_Btn[playerid][9], 0.000000, 0.000000, 0.000000, -1.000000);

	PP_Btn[playerid][10] = CreatePlayerTextDraw(playerid, 498.791595, 365.583282, "");
	PlayerTextDrawLetterSize(playerid, PP_Btn[playerid][10], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, PP_Btn[playerid][10], 20.000000, 22.000000);
	PlayerTextDrawAlignment(playerid, PP_Btn[playerid][10], 1);
	PlayerTextDrawColor(playerid, PP_Btn[playerid][10], -1);
	PlayerTextDrawSetShadow(playerid, PP_Btn[playerid][10], 0);
	PlayerTextDrawSetOutline(playerid, PP_Btn[playerid][10], 0);
	PlayerTextDrawBackgroundColor(playerid, PP_Btn[playerid][10], 1431655935);
	PlayerTextDrawFont(playerid, PP_Btn[playerid][10], 5);
	PlayerTextDrawSetProportional(playerid, PP_Btn[playerid][10], 0);
	PlayerTextDrawSetShadow(playerid, PP_Btn[playerid][10], 0);
	PlayerTextDrawSetSelectable(playerid, PP_Btn[playerid][10], true);
	PlayerTextDrawSetPreviewModel(playerid, PP_Btn[playerid][10], 0);
	PlayerTextDrawSetPreviewRot(playerid, PP_Btn[playerid][10], 0.000000, 0.000000, 0.000000, -1.000000);
	
	NumberLetters[playerid][0] = CreatePlayerTextDraw(playerid, 504.114227, 285.083312, "1___2___3");
	PlayerTextDrawLetterSize(playerid, NumberLetters[playerid][0], 0.410776, 1.862500);
	PlayerTextDrawAlignment(playerid, NumberLetters[playerid][0], 1);
	PlayerTextDrawColor(playerid, NumberLetters[playerid][0], -1);
	PlayerTextDrawSetShadow(playerid, NumberLetters[playerid][0], 0);
	PlayerTextDrawSetOutline(playerid, NumberLetters[playerid][0], 0);
	PlayerTextDrawBackgroundColor(playerid, NumberLetters[playerid][0], 255);
	PlayerTextDrawFont(playerid, NumberLetters[playerid][0], 1);
	PlayerTextDrawSetProportional(playerid, NumberLetters[playerid][0], 1);
	PlayerTextDrawSetShadow(playerid, NumberLetters[playerid][0], 0);

	NumberLetters[playerid][1] = CreatePlayerTextDraw(playerid, 503.177154, 313.666625, "4___5___6");
	PlayerTextDrawLetterSize(playerid, NumberLetters[playerid][1], 0.410776, 1.862500);
	PlayerTextDrawAlignment(playerid, NumberLetters[playerid][1], 1);
	PlayerTextDrawColor(playerid, NumberLetters[playerid][1], -1);
	PlayerTextDrawSetShadow(playerid, NumberLetters[playerid][1], 0);
	PlayerTextDrawSetOutline(playerid, NumberLetters[playerid][1], 0);
	PlayerTextDrawBackgroundColor(playerid, NumberLetters[playerid][1], 255);
	PlayerTextDrawFont(playerid, NumberLetters[playerid][1], 1);
	PlayerTextDrawSetProportional(playerid, NumberLetters[playerid][1], 1);
	PlayerTextDrawSetShadow(playerid, NumberLetters[playerid][1], 0);

	NumberLetters[playerid][2] = CreatePlayerTextDraw(playerid, 503.177124, 341.083312, "7___8___9");
	PlayerTextDrawLetterSize(playerid, NumberLetters[playerid][2], 0.410776, 1.862500);
	PlayerTextDrawAlignment(playerid, NumberLetters[playerid][2], 1);
	PlayerTextDrawColor(playerid, NumberLetters[playerid][2], -1);
	PlayerTextDrawSetShadow(playerid, NumberLetters[playerid][2], 0);
	PlayerTextDrawSetOutline(playerid, NumberLetters[playerid][2], 0);
	PlayerTextDrawBackgroundColor(playerid, NumberLetters[playerid][2], 255);
	PlayerTextDrawFont(playerid, NumberLetters[playerid][2], 1);
	PlayerTextDrawSetProportional(playerid, NumberLetters[playerid][2], 1);
	PlayerTextDrawSetShadow(playerid, NumberLetters[playerid][2], 0);

	NumberLetters[playerid][3] = CreatePlayerTextDraw(playerid, 504.114288, 369.083435, "0");
	PlayerTextDrawLetterSize(playerid, NumberLetters[playerid][3], 0.400000, 1.600000);
	PlayerTextDrawAlignment(playerid, NumberLetters[playerid][3], 1);
	PlayerTextDrawColor(playerid, NumberLetters[playerid][3], -1);
	PlayerTextDrawSetShadow(playerid, NumberLetters[playerid][3], 0);
	PlayerTextDrawSetOutline(playerid, NumberLetters[playerid][3], 0);
	PlayerTextDrawBackgroundColor(playerid, NumberLetters[playerid][3], 255);
	PlayerTextDrawFont(playerid, NumberLetters[playerid][3], 1);
	PlayerTextDrawSetProportional(playerid, NumberLetters[playerid][3], 1);
	PlayerTextDrawSetShadow(playerid, NumberLetters[playerid][3], 0);
	
}

stock AttachPlayerPhone(playerid)
{
	switch(PlayerInfo[playerid][pPhoneType])
	{
	    case PHONE_TYPE_BLACK:
		{
			SetPlayerAttachedObject(playerid, SLOT_PHONE, 18868, 6, 0.064999, 0.043999, 0.004999, -112.0, 0.0, -178.9);
		}
	    case PHONE_TYPE_RED:
		{
			PlayerTextDrawBoxColor(playerid, PhoneFrame[playerid][0], 1225921279);
			PlayerTextDrawColor(playerid, PhoneFrame[playerid][1], 1225921279);
			PlayerTextDrawColor(playerid, PhoneFrame[playerid][2], 1225921279);
			SetPlayerAttachedObject(playerid, SLOT_PHONE, 18870, 6, 0.064999, 0.043999, 0.004999, -112.0, 0.0, -178.9);
		}
		case PHONE_TYPE_BLUE:
		{
		    PlayerTextDrawBoxColor(playerid, PhoneFrame[playerid][0], 456290303);
		    PlayerTextDrawColor(playerid, PhoneFrame[playerid][1], 456290303);
		    PlayerTextDrawColor(playerid, PhoneFrame[playerid][2], 456290303);
			SetPlayerAttachedObject(playerid, SLOT_PHONE, 18874, 6, 0.064999, 0.043999, 0.004999, -112.0, 0.0, -178.9);
		}
	}
	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USECELLPHONE);
	return 1;
}

stock showPhoneMenu(playerid, bool:show, page)
{
	if(show)
	{
	    showPhonePage(playerid, page);
	    
	    PlayerTextDrawShow(playerid, PhoneListName[playerid]);
	    for(new i = 0; i < 3; i ++) PlayerTextDrawShow(playerid, PhoneList[playerid][i]);
	    
	    PlayerTextDrawHide(playerid, PhoneDate[playerid]);
	    PlayerTextDrawHide(playerid, PhoneTime[playerid]);
	    PlayerTextDrawHide(playerid, PhoneSignal[playerid]);
	    PlayerTextDrawHide(playerid, PhonePower[playerid]);
		PlayerTextDrawHide(playerid, PhoneNotify[playerid]);
		PlayerTextDrawHide(playerid, PhoneBtnMenu[playerid]);
		PlayerTextDrawHide(playerid, PhoneBtnBack[playerid]);
		
	}
	else
	{
	    cache_phone[playerid][current_page] = 0;
	    PlayerTextDrawHide(playerid, PhoneListName[playerid]);
	    for(new i = 0; i < 3; i ++) PlayerTextDrawHide(playerid, PhoneList[playerid][i]);
	    Phone_HideUI(playerid);
	    Phone_ShowUI(playerid);
	}
	return 1;
}

stock showPhonePage(playerid, page)
{
	switch(page)
	{
	    case Page_Home:
	    {
	        PlayerTextDrawSetString(playerid, PhoneListName[playerid], "Notebook~n~Contact~n~Setting");
			showPhoneMenu(playerid, false, -1);
	    }
	    case Page_Menu:
	    {
			PlayerTextDrawSetString(playerid, PhoneListName[playerid], "Notebook~n~Contact~n~Setting");
	    }
	    case Page_Notebook:
	    {
			PlayerTextDrawSetString(playerid, PhoneListName[playerid], "Call~n~SMS~n~Contact_List");
	    }
	    case Page_Contact:
	    {
			PlayerTextDrawSetString(playerid, PhoneListName[playerid], "Add_Contact~n~Edit_Contact~n~Delete_Contact");
	    }
	    case Page_Setting:
	    {
			PlayerTextDrawSetString(playerid, PhoneListName[playerid], "Ringtone~n~Theme~n~Phone_Mode"); // phone mode > silent, flight
	    }
	}
}

stock Phone_Switch(playerid)
{
	if(PlayerInfo[playerid][pPhoneOff]) // turn on
	{
	    if(PlayerInfo[playerid][pPhonePower] > 0)
	    {
		    PlayerTextDrawHide(playerid, PhoneDisplay[playerid]);
		    PlayerTextDrawBoxColor(playerid, PhoneDisplay[playerid], 255);
		    PlayerTextDrawShow(playerid, PhoneDisplay[playerid]);
	    	PlayerTextDrawSetString(playerid, PhoneNotify[playerid], "Loading..");
    	}
	}
	else // Turn Off
	{
	    PlayerTextDrawHide(playerid, PhoneDisplay[playerid]);
	    PlayerTextDrawBoxColor(playerid, PhoneDisplay[playerid], 255);
	    PlayerTextDrawShow(playerid, PhoneDisplay[playerid]);
	    PlayerTextDrawSetString(playerid, PhoneNotify[playerid], "Bye_Bye!");
	}
	SetTimerEx("OnPhoneToggle", 2500, false, "i", playerid);
}

this::OnPhoneToggle(playerid, type)
{
    PlayerInfo[playerid][pCooldown] = false;
	if(PlayerInfo[playerid][pUseGUI])
	{
		if(PlayerInfo[playerid][pPhoneOff]) // turn on
		{
		    PlayerInfo[playerid][pPhoneOff] = false;
		    PlayerTextDrawHide(playerid, PhoneDisplay[playerid]);
		    PlayerTextDrawBoxColor(playerid, PhoneDisplay[playerid], -572662273);
		    PlayerTextDrawShow(playerid, PhoneDisplay[playerid]);
		    PlayerTextDrawSetString(playerid, PhoneNotify[playerid], "_");
		}
		else
		{
		    PlayerInfo[playerid][pPhoneOff] = true;
		    PlayerTextDrawHide(playerid, PhoneDisplay[playerid]);
		    PlayerTextDrawBoxColor(playerid, PhoneDisplay[playerid], 255);
		    PlayerTextDrawShow(playerid, PhoneDisplay[playerid]);
		    PlayerTextDrawSetString(playerid, PhoneNotify[playerid], "_");
		}
	}
	return 1;
}

stock Phone_ShowUI(playerid)
{
	SendClientMessage(playerid, COLOR_WHITE, "[ ! ] Note: To toggle the phone, use /phone. To bring up the mouse, use /pc.");
    Phone_HideUI(playerid);
	PlayerInfo[playerid][pUseGUI] = true;
    cache_phone[playerid][current_page] = Page_Home;
    
	AttachPlayerPhone(playerid);
	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_STOPUSECELLPHONE);
	ApplyAnimation(playerid, "CARRY", "crry_prtial", 4.1, 0, 0, 0, 0, 0);

	new
		hour,
		minute,
		second,
		year,
		month,
		day,
		MonthStr[40],
		str[128]
	;
	
	gettime(hour, minute, second);
	format(str, sizeof(str), "%02d:%02d", hour, minute);
    PlayerTextDrawSetString(playerid, PhoneTime[playerid], str);
    
	getdate(year, month, day);
	switch(month)
	{
	    case 1:  MonthStr = "January";
	    case 2:  MonthStr = "February";
	    case 3:  MonthStr = "March";
	    case 4:  MonthStr = "April";
	    case 5:  MonthStr = "May";
	    case 6:  MonthStr = "June";
	    case 7:  MonthStr = "July";
	    case 8:  MonthStr = "August";
	    case 9:  MonthStr = "September";
	    case 10: MonthStr = "October";
	    case 11: MonthStr = "November";
	    case 12: MonthStr = "December";
	}
	format(str, sizeof(str), "%s_%d", MonthStr, day);
    PlayerTextDrawSetString(playerid, PhoneDate[playerid], str);
    
    if(PlayerInfo[playerid][pPhoneOff])
    {
        PlayerTextDrawBoxColor(playerid, PhoneDisplay[playerid], 255);
    }

	for(new i = 0; i < 3; i++) PlayerTextDrawShow(playerid, PhoneFrame[playerid][i]);
	PlayerTextDrawShow(playerid, PhoneLogo[playerid]);
	PlayerTextDrawShow(playerid, PhoneSwitch[playerid]);
	PlayerTextDrawShow(playerid, PhoneInfo[playerid]);
	PlayerTextDrawShow(playerid, PhoneDisplay[playerid]);
	PlayerTextDrawShow(playerid, PhoneBtnL[playerid]);
	PlayerTextDrawShow(playerid, PhoneBtnR[playerid]);
	PlayerTextDrawShow(playerid, PhoneArrowUp[playerid]);
	PlayerTextDrawShow(playerid, PhoneArrowDown[playerid]);
	PlayerTextDrawShow(playerid, PhoneArrowLeft[playerid]);
	PlayerTextDrawShow(playerid, PhoneArrowRight[playerid]);
	PlayerTextDrawShow(playerid, PhoneBtnMenu[playerid]);
	PlayerTextDrawShow(playerid, PhoneBtnBack[playerid]);
	PlayerTextDrawShow(playerid, PhoneDate[playerid]);
	PlayerTextDrawShow(playerid, PhoneTime[playerid]);
	PlayerTextDrawShow(playerid, PhoneSignal[playerid]);
	PlayerTextDrawShow(playerid, PhonePower[playerid]);
    PlayerTextDrawShow(playerid, PhoneDate[playerid]);
    PlayerTextDrawShow(playerid, PhoneTime[playerid]);
    PlayerTextDrawShow(playerid, PhoneNotify[playerid]);
    
    SelectTextDraw(playerid, COLOR_GREY);
	return 1;
}

stock Phone_HideUI(playerid)
{
	for(new i = 0; i < 3; i++) PlayerTextDrawHide(playerid, PhoneFrame[playerid][i]);
	PlayerTextDrawHide(playerid, PhoneLogo[playerid]);
	PlayerTextDrawHide(playerid, PhoneSwitch[playerid]);
	PlayerTextDrawHide(playerid, PhoneInfo[playerid]);
	PlayerTextDrawHide(playerid, PhoneDisplay[playerid]);
	PlayerTextDrawHide(playerid, PhoneBtnL[playerid]);
	PlayerTextDrawHide(playerid, PhoneBtnR[playerid]);
	PlayerTextDrawHide(playerid, PhoneArrowUp[playerid]);
	PlayerTextDrawHide(playerid, PhoneArrowDown[playerid]);
	PlayerTextDrawHide(playerid, PhoneArrowLeft[playerid]);
	PlayerTextDrawHide(playerid, PhoneArrowRight[playerid]);
	PlayerTextDrawHide(playerid, PhoneBtnMenu[playerid]);
	PlayerTextDrawHide(playerid, PhoneBtnBack[playerid]);
	PlayerTextDrawHide(playerid, PhoneDate[playerid]);
	PlayerTextDrawHide(playerid, PhoneTime[playerid]);
	PlayerTextDrawHide(playerid, PhoneSignal[playerid]);
	PlayerTextDrawHide(playerid, PhonePower[playerid]);
    PlayerTextDrawHide(playerid, PhoneDate[playerid]);
    PlayerTextDrawHide(playerid, PhoneTime[playerid]);
    PlayerTextDrawHide(playerid, PhoneNotify[playerid]);
    cache_phone[playerid][current_page] = Page_None;
	RemovePlayerAttachedObject(playerid, SLOT_PHONE);
	PlayerInfo[playerid][pUseGUI] = false;
	CancelSelectTextDraw(playerid);
	return 1;
}

DisplayColors(playerid, bool:toggle)
{
	if(toggle)
	{
	    SetPVarInt(playerid, "ColorSelect", 1);
		SetPVarInt(playerid, "index_color", 0);
		for(new i; i < 8; i ++)
		{
		    PlayerTextDrawBackgroundColor(playerid, ColorPanel[playerid][i], VehicleColoursTableRGBA[i]);
		}
		for(new idx; idx < 10; idx ++)
		{
		    PlayerTextDrawShow(playerid, ColorPanel[playerid][idx]);
		}
	}
	else
	{
		for(new i; i < 10; i ++)
		{
		    PlayerTextDrawHide(playerid, ColorPanel[playerid][i]);
		}
	    DeletePVar(playerid, "ColorSelect");
		DeletePVar(playerid, "index_color");
	}
	return 1;
}
showNextColor(playerid)
{
    SetPVarInt(playerid, "index_color", GetPVarInt(playerid, "index_color")+1);
    new offset = GetPVarInt(playerid, "index_color") * 8;
	for(new idx; idx < 8; idx ++)
	{
	    PlayerTextDrawHide(playerid, ColorPanel[playerid][idx]);
	}
	if(GetPVarInt(playerid, "index_color") >= 32)
	{
	    SetPVarInt(playerid, "index_color", 1);
		for(new i; i < 8; i ++)
		{
		    PlayerTextDrawBackgroundColor(playerid, ColorPanel[playerid][i], VehicleColoursTableRGBA[i]);
		}
		for(new g; g < 8; g ++)
		{
		    PlayerTextDrawShow(playerid, ColorPanel[playerid][g]);
		}
	}
	else
	{
		for(new i; i < 8; i ++)
		{
		    PlayerTextDrawBackgroundColor(playerid, ColorPanel[playerid][i], VehicleColoursTableRGBA[i+offset]);
		}
		for(new g; g < 8; g ++)
		{
		    PlayerTextDrawShow(playerid, ColorPanel[playerid][g]);
		}
	}
	return 1;
}

this::Query_LoadTags()
{
	if(!cache_num_rows())
		return printf("[SERVER]: No tags were loaded from \"%s\" database...", SQL_DATABASE);

	new rows, fields; cache_get_data(rows, fields, this);
	new countTags = 0;

	for(new i = 1; i < rows && i < MAX_SPRAYS; i++)
	{
		spray_data[i][spray_id] = cache_get_field_content_int(i, "id", this);
		spray_data[i][spray_modelid] = cache_get_field_content_int(i, "modelid", this);
		spray_data[i][spray_location][0] = cache_get_field_content_float(i, "offsetX", this);
        spray_data[i][spray_location][1] = cache_get_field_content_float(i, "offsetY", this);
        spray_data[i][spray_location][2] = cache_get_field_content_float(i, "offsetZ", this);
        spray_data[i][spray_location][3] = cache_get_field_content_float(i, "rotX", this);
        spray_data[i][spray_location][4] = cache_get_field_content_float(i, "rotY", this);
        spray_data[i][spray_location][5] = cache_get_field_content_float(i, "rotZ", this);
        
        spray_data[i][spray_object] = CreateDynamicObject(spray_data[i][spray_modelid], spray_data[i][spray_location][0], spray_data[i][spray_location][1], spray_data[i][spray_location][2], spray_data[i][spray_location][3], spray_data[i][spray_location][4], spray_data[i][spray_location][5]);
	    countTags ++;
	}
	printf("[SERVER]: %d tags were loaded from \"%s\" database...", countTags, SQL_DATABASE);
	return 1;
}

this::OnSprayTagCreated(playerid, modelid, Float: x, Float: y, Float: z, Float: rx, Float: ry, Float: rz)
{
	new idx;
	for(new i = 1; i < MAX_SPRAYS; i++)
	{
		if(spray_data[i][spray_id])
			continue;

		idx = i;
		break;
	}
    spray_data[idx][spray_id] = cache_insert_id();
    spray_data[idx][is_exists] = true;
    spray_data[idx][spray_modelid] = modelid;
    spray_data[idx][spray_location][0] = x;
    spray_data[idx][spray_location][1] = y;
    spray_data[idx][spray_location][2] = z;
    spray_data[idx][spray_location][3] = rx;
    spray_data[idx][spray_location][4] = ry;
    spray_data[idx][spray_location][5] = rz;
    
    spray_data[idx][spray_object] = CreateDynamicObject(modelid, x, y, z, rx, ry, rz);
    
	SendAdminMessageEx(COLOR_YELLOWEX, 1, "AdmWarn: %s has just created a new spray location, ID: %d", ReturnName(playerid, 1), idx);
    return 1;
}
CMD:makepayphone(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] > 4)
	{
		new Float: x, Float: y, Float: z;
		GetPlayerPos(playerid, x, y, z);
		PlayerInfo[playerid][pEditingObject] = 6;
		PlayerInfo[playerid][pAddObject] = CreateDynamicObject(1216, x, y+2.0, z, 0.0, 0.0, 0.0);
		EditDynamicObject(playerid, PlayerInfo[playerid][pAddObject]);
	}
	else return SendErrorMessage(playerid, "No permission.");
	return 1;
}

CMD:chopshop(playerid, params[])
{
	if(!PlayerInfo[playerid][pAdmin] && PlayerInfo[playerid][pFactionRank] > FactionInfo[PlayerInfo[playerid][pFaction]][eFactionAlterRank])
		return SendErrorMessage(playerid, "You don't have permission to use this command.");

	if(!PlayerInfo[playerid][pAdmin] && FactionInfo[PlayerInfo[playerid][pFaction]][eFactionCSID] != GetChopshopID(playerid))
	{
		ShowPlayerDialog(playerid, DIALOG_CHOPSHOP, DIALOG_STYLE_LIST, "ChopShop Main Page:", "Order A ChopShop", "Select", "<<");
	}
	else
	{
	    ShowPlayerDialog(playerid, DIALOG_CHOPSHOP, DIALOG_STYLE_LIST, "ChopShop Main Page:", "Order A ChopShop\nChange Wanted List\nChopShop Info\nMove ChalkBoard", "Select", "<<");
	}
	return 1;
}

CMD:graffiti(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] > 4)
	{
		new oneString[30], value;
		if(sscanf(params, "s[30]I(-1)", oneString, value))
		{
			SendUsageMessage(playerid, "/graffiti [category] (Admins ONLY)");
			SendClientMessage(playerid, COLOR_LIGHTRED, "show - {FFFFFF} displays the GUI.");
	        SendClientMessage(playerid, COLOR_LIGHTRED, "create - {FFFFFF} Create a new spray location.");
	        SendClientMessage(playerid, COLOR_LIGHTRED, "edit - {FFFFFF} Edit the spraytag that created.");
	        SendClientMessage(playerid, COLOR_LIGHTRED, "delete - {FFFFFF} Delete the spraytag that already exists.");
			return 1;
		}
		if(!strcmp(oneString, "create"))
		{
		    new diaLog[256], list[128];
		    for(new i = 0; i < sizeof(g_spraytag); i ++)
		    {
		        format(list, sizeof(list), "%s\n", g_spraytag[i][tag_name]);
		        strcat(diaLog, list);
		    }
		    ShowPlayerDialog(playerid, DIALOG_SPRAY_CREATE, DIALOG_STYLE_LIST, "Pick A Graffiti Image:", diaLog, "Select", "<<");
		}
		else if(!strcmp(oneString, "getid"))
		{
		    if(value == -1)
		        return SendUsageMessage(playerid, "/graffiti edit [id]");
		        
		    if(!GetPlayerNearestTag(playerid)) return SendErrorMessage(playerid, "There's nothing around you.");
            sendMessage(playerid, COLOR_YELLOWEX, "_> the nearest tag is ID %d", GetPlayerNearestTag(playerid));
		}
		else if(!strcmp(oneString, "show"))
		{
			ShowSprayDialog(playerid, DIALOG_SPRAY_MAIN);
		}
		else if(!strcmp(oneString, "delete"))
		{
		    if(value == -1)
		        return SendUsageMessage(playerid, "/graffiti delete [id]");
		        
			new delQuery[128];

			mysql_format(this, delQuery, sizeof(delQuery), "DELETE FROM spray_tag WHERE id = %i", spray_data[value][spray_id]);
			mysql_tquery(this, delQuery, "OnSprayTagDeleted", "ii", playerid, value);
		}
	}
	else
	{
	    ShowSprayDialog(playerid, DIALOG_SPRAY_MAIN);
	}
	return 1;
}

this::OnSprayTagDeleted(playerid, id)
{
	if(!cache_num_rows())
	{
	    sendMessage(playerid, COLOR_LIGHTRED, "ERROR: Could not find spray tag id %d.", id);
		return 1;
	}
	if(IsValidDynamicObject(spray_data[id][spray_object])) DestroyDynamicObject(spray_data[id][spray_object]);
	spray_data[id][is_exists] = false;
	spray_data[id][spray_id] = 0;
	SendAdminMessageEx(COLOR_YELLOWEX, 1, "AdmWarn: %s has just deleted spray location, spray ID: %d", ReturnName(playerid, 1), id);
    return 1;
}

stock ShowSprayDialog(playerid, part)
{
	switch(part)
	{
		case DIALOG_SPRAY_MAIN:
		{
		    ShowPlayerDialog(playerid, part, DIALOG_STYLE_LIST, "Main Menu:", "Pick A Graffiti Image\nWant Custom Text Instead?\nPick A Font(For Custom Text)", "Select", "<<");
		}
		case DIALOG_SPRAY_IMAGE:
		{
		    new diaLog[256], list[128];
		    for(new i = 0; i < sizeof(g_spraytag); i ++)
		    {
		        format(list, sizeof(list), "%s\n", g_spraytag[i][tag_name]);
		        strcat(diaLog, list);
		    }
		    ShowPlayerDialog(playerid, part, DIALOG_STYLE_LIST, "Pick A Graffiti Image:", diaLog, "Select", "<<");
		}
		case DIALOG_SPRAY_INPUT:
		{
		    ShowPlayerDialog(playerid, part, DIALOG_STYLE_INPUT, "Write in what you want:", "HINT:\n-\t\t\tWe use a special bbcode template to format messages using a (c) system. (n) for new line\n\t\t\t\t\t\t(bl):Blue,(w):White,(y):Yellow,(g):Green\n\t\t\t\t\t\t(b):Black /bbcode for the rest.\n\t\t\t\t\t\tUsage:This will make (y)word(b) yellow and the rest black.\n-\t\t\tTry not to make your message too long.\nThe max is 60 characters.", "Select", "<<");
		}
		case DIALOG_SPRAY_FONT:
		{
		    
		    new diaLog[256], list[128];
		    for(new i = 0; i < sizeof(font_data); i ++)
		    {
		        format(list, sizeof(list), "%s\n", font_data[i][font_name]);
		        strcat(diaLog, list);
		    }
			ShowPlayerDialog(playerid, part, DIALOG_STYLE_LIST, "Pick A Font(For Custom Text):", diaLog, "Select", "<<");
		}
 	}
 	return 1;
}

stock ResetSprayVars(playerid)
{
    KillTimer(PlayerInfo[playerid][pSprayTimer][0]);
    KillTimer(PlayerInfo[playerid][pSprayTimer][1]);
	PlayerInfo[playerid][pSprayPoint] = 0;
	PlayerInfo[playerid][pSprayLength] = 0;
	PlayerInfo[playerid][pSprayTarget] = -1;
	return 1;
}

stock GetPlayerNearestTag(playerid)
{
	for(new i = 1; i < MAX_SPRAYS; i++)
	{
		if(!spray_data[i][spray_id])
			continue;
			
		if(!spray_data[i][is_exists])
			continue;

		if(IsPlayerInRangeOfPoint(playerid, 3.0, spray_data[i][spray_location][0], spray_data[i][spray_location][1], spray_data[i][spray_location][2]))
			return i;
	}
	return 0;
}

this::SprayListener(playerid, type)
{
	switch(type)
	{
	    case THREAD_GRAFFITI:
	    {
	        new id = PlayerInfo[playerid][pSprayTarget], string[64];
			if((id == GetPlayerNearestTag(playerid)))
			{
			    PlayerInfo[playerid][pSprayPoint] ++;
				format(string, sizeof(string),"~g~SPRAYING~n~~w~%d]", PlayerInfo[playerid][pSprayPoint]); // <----
				GameTextForPlayer(playerid, string, 1000, 5);
			    if(PlayerInfo[playerid][pSprayPoint] >= PlayerInfo[playerid][pSprayLength])
			    {
			        ReplaceText(PlayerInfo[playerid][pSprayText], "(n)", "\n");
			        ReplaceText(PlayerInfo[playerid][pSprayText], "(r)", "{FF6347}"); // red
			        ReplaceText(PlayerInfo[playerid][pSprayText], "(b)", "{0E0101}"); // black
			        ReplaceText(PlayerInfo[playerid][pSprayText], "(y)", "{F3FF02}"); // yellow
			        ReplaceText(PlayerInfo[playerid][pSprayText], "(bl)", "{0049FF}"); // blue
			        ReplaceText(PlayerInfo[playerid][pSprayText], "(g)", "{6EF83C}"); // green
			        ReplaceText(PlayerInfo[playerid][pSprayText], "(o)", "{FFA500}"); // orange
			        ReplaceText(PlayerInfo[playerid][pSprayText], "(w)", "{FFFFFF}"); // white
					switch(PlayerInfo[playerid][pSprayAllow])
					{
						case 1: SetDynamicObjectMaterialText(spray_data[id][spray_object], 0, PlayerInfo[playerid][pSprayText], OBJECT_MATERIAL_SIZE_512x256, font_data[PlayerInfo[playerid][pSprayFont]][font_name], 40, 1, -1, 0, 1);
						case 2:
						{
							DestroyDynamicObject(spray_data[id][spray_object]);
							spray_data[id][spray_object] = CreateDynamicObject
							(
								PlayerInfo[playerid][pSprayFont],
								spray_data[id][spray_location][0],
								spray_data[id][spray_location][1],
								spray_data[id][spray_location][2],
								spray_data[id][spray_location][3],
								spray_data[id][spray_location][4],
								spray_data[id][spray_location][5]
							);
						}
					}
					GameTextForPlayer(playerid, "~g~SPRAYED~w~]", 5000, 5);
					PlayerPlaySound(playerid, 1057, 0, 0, 0);
					ResetSprayVars(playerid);
					return 1;
			    }
			}
			else
			{
			    ResetSprayVars(playerid);
			    return 1;
			}
	    }
	    case THREAD_KILL:
	    {
	        ResetSprayVars(playerid);
	    }
	}
	return 1;
}

ReplaceText(string[], const search[], const replacement[], bool:ignorecase = false, pos = 0, limit = -1, maxlength = 256)
{
    if(!limit)return 0;

    new sublen = strlen(search),
        replen = strlen(replacement),
        bool:packed = ispacked(string),
        maxlen = maxlength,
        len = strlen(string),
        count = 0;

    if(packed)maxlen *= 4;
    if(!sublen)return 0;

    while(-1 != (pos = strfind(string, search, ignorecase, pos)))
    {
        strdel(string, pos, pos + sublen);

        len -= sublen;

        if(replen && len + replen < maxlen)
        {
            strins(string, replacement, pos, maxlength);

            pos += replen;
            len += replen;
       }

        if(limit != -1 && ++count >= limit)break;
   }

    return count;
}

this::OnPayPhoneCreated(playerid, Float: x, Float: y, Float: z, Float: rx, Float: ry, Float: rz)
{
	new idx;
	for(new i = 1; i < MAX_PAYPHONE; i++)
	{
		if(payphone_data[i][payphone_id])
			continue;
			
		if(payphone_data[i][payphone_exist])
			continue;

		idx = i;
		break;
	}
	
    payphone_data[idx][payphone_id] = cache_insert_id();
    payphone_data[idx][payphone_exist] = true;
    payphone_data[idx][payphone_pos][0] = x;
    payphone_data[idx][payphone_pos][1] = y;
    payphone_data[idx][payphone_pos][2] = z;
    payphone_data[idx][payphone_pos][3] = rx;
    payphone_data[idx][payphone_pos][4] = ry;
    payphone_data[idx][payphone_pos][5] = rz;
    payphone_data[idx][payphone_coin] = 0;
    payphone_data[idx][payphone_state] = PAYPHONE_STATE_NONE;
    payphone_data[idx][payphone_code] = ReturnAreaCode(GetPlayerZoneID(playerid));
	format(payphone_data[idx][payphone_numstr], 24, "%d-%0d", payphone_data[idx][payphone_code], payphone_data[idx][payphone_id]+10);
	ReplaceText(payphone_data[idx][payphone_numstr], "-", "");
	payphone_data[idx][payphone_number] = strval(payphone_data[idx][payphone_numstr]);
		
    payphone_data[idx][payphone_model] = CreateDynamicObject(1216, x, y, z, rx, ry, rz);
	SendAdminMessageEx(COLOR_YELLOWEX, 1, "AdmWarn: %s has just created a new payphone, ID: %d", ReturnName(playerid, 1), idx);

	SavePayphone(idx);
    return 1;
}

stock SavePayphone(id)
{
	new query[400];

	mysql_format(this, query, sizeof(query), "UPDATE payphone SET offsetX = %f, offsetY = %f, offsetZ = %f, rotX = %f, rotY = %f, rotZ = %f, coin = %i, code = %i WHERE id = %i",
		payphone_data[id][payphone_pos][0],
		payphone_data[id][payphone_pos][1],
		payphone_data[id][payphone_pos][2],
		payphone_data[id][payphone_pos][3],
		payphone_data[id][payphone_pos][4],
		payphone_data[id][payphone_pos][5],
		payphone_data[id][payphone_coin],
		payphone_data[id][payphone_code],
		payphone_data[id][payphone_id]);
	mysql_tquery(this, query);

	return 1;
}

this::Query_LoadPayphone()
{
	if(!cache_num_rows())
		return printf("[SERVER]: No payphones were loaded from \"%s\" database...", SQL_DATABASE);

	new rows, fields; cache_get_data(rows, fields, this);
	new countphones = 0;

	for(new i = 1; i < rows && i < MAX_PAYPHONE; i++)
	{
		payphone_data[i][payphone_id] = cache_get_field_content_int(i, "id", this);
		payphone_data[i][payphone_pos][0] = cache_get_field_content_float(i, "offsetX", this);
		payphone_data[i][payphone_pos][1] = cache_get_field_content_float(i, "offsetY", this);
		payphone_data[i][payphone_pos][2] = cache_get_field_content_float(i, "offsetZ", this);
		payphone_data[i][payphone_pos][3] = cache_get_field_content_float(i, "rotX", this);
		payphone_data[i][payphone_pos][4] = cache_get_field_content_float(i, "rotY", this);
		payphone_data[i][payphone_pos][5] = cache_get_field_content_float(i, "rotZ", this);
		payphone_data[i][payphone_coin] = cache_get_field_content_int(i, "coin", this);
		payphone_data[i][payphone_code] = cache_get_field_content_int(i, "code", this);
		format(payphone_data[i][payphone_numstr], 24, "%d-%0d", payphone_data[i][payphone_code], payphone_data[i][payphone_id]+10);
		ReplaceText(payphone_data[i][payphone_numstr], "-", "");
		payphone_data[i][payphone_number] = strval(payphone_data[i][payphone_numstr]);
        payphone_data[i][payphone_model] = CreateDynamicObject(1216, payphone_data[i][payphone_pos][0], payphone_data[i][payphone_pos][1], payphone_data[i][payphone_pos][2], payphone_data[i][payphone_pos][3], payphone_data[i][payphone_pos][4], payphone_data[i][payphone_pos][5]);

		payphone_data[i][payphone_exist] = true;

		countphones ++;
	}
	printf("[SERVER]: %d payphones were loaded from \"%s\" database...", countphones, SQL_DATABASE);
	return 1;
}


CMD:payphone(playerid, params[])
{
	new id = GetClosestPayphone(playerid);
	if(PlayerInfo[playerid][pUseGUI]) return SendClientMessage(playerid, COLOR_LIGHTRED, "ERROR: pocket your phone first... (/phone)");
	if(GetPVarInt(playerid, "UsePayphone") == 1) return SendClientMessage(playerid, COLOR_LIGHTRED, "ERROR: You are using payphone.");
	if(id == INVALID_ID) return SendClientMessage(playerid, COLOR_LIGHTRED, "There is no payphone around you..");
 	if(PlayerInfo[playerid][pPayphone] == id) return SendClientMessage(playerid, COLOR_LIGHTRED, "You are using this payphone..");
	foreach(new i: Player) if(IsPlayerConnected(i))
	{
	    if(i == playerid) continue;
	    
	    if(PlayerInfo[i][pPayphone] == id)
	    {
	        SendClientMessage(playerid, COLOR_LIGHTRED, "ERROR: This payphone is occupied.");
			break;
	    }
	}
	SetPVarInt(playerid, "UsePayphone", 1);
	SetPVarInt(playerid, "ThisPayphone", id);
    new hour, minute, second, str[64];
	gettime(hour, minute, second);
	format(str, sizeof(str), "%02d:%02d", hour, minute);
    PlayerTextDrawSetString(playerid, PP_Btn[playerid][0], str);
	for(new i = 0; i < 15; i ++) TextDrawShowForPlayer(playerid, PP_Framework[i]);
	for(new g = 0; g < 11; g ++) PlayerTextDrawShow(playerid, PP_Btn[playerid][g]);
	for(new e = 0; e < 4; e ++) PlayerTextDrawShow(playerid, NumberLetters[playerid][e]);
	SetCameraBehindPlayer(playerid);
	SelectTextDraw(playerid, COLOR_GREY);
	return 1;
}

IsCallIncoming(playerid)
{
	return (PlayerInfo[playerid][pCalling] == 1 && PlayerInfo[playerid][pPhoneline] != INVALID_PLAYER_ID);
}

IsPlayerNearRingingPayphone(playerid)
{
	new payphone = GetClosestPayphone(playerid);

	return (IsValidPayphoneID(payphone) && payphone_data[payphone][payphone_caller] != INVALID_PLAYER_ID);
}

GetClosestPayphone(playerid)
{
    for (new i = 1; i < MAX_PAYPHONE; i ++)
	{
	    if (payphone_data[i][payphone_exist] && IsPlayerInRangeOfPoint(playerid, 2.0, payphone_data[i][payphone_pos][0], payphone_data[i][payphone_pos][1], payphone_data[i][payphone_pos][2]))
  		{
    		return i;
		}
	}
	return INVALID_ID;
}

IsPhoneBusy(number)
{
	new targetid = GetPhonePlayerID(number);

	return (targetid != INVALID_PLAYER_ID && PlayerInfo[targetid][pCalling] > 0);
}

IsValidPayphoneID(id)
{
	return (id > 0 && id < MAX_PAYPHONE) && payphone_data[id][payphone_exist];
}

GetPhonePlayerID(number)
{
	foreach (new i : Player)
	{
	    if (PlayerInfo[i][pPhone] == number)
	    {
	        return i;
		}
	}
	return INVALID_PLAYER_ID;
}

GetPhonePayphoneID(number)
{
	for (new i = 1; i < MAX_PAYPHONE; i ++)
	{
		if (IsValidPayphoneID(i) && payphone_data[i][payphone_number] == number)
		{
		    return i;
		}
	}
	return 0;
}

GetPayphoneArea(number)
{
	new str[64];
	format(str, sizeof(str), "Unknown");
	for (new i = 1; i < MAX_PAYPHONE; i ++)
	{
		if (IsValidPayphoneID(i) && payphone_data[i][payphone_number] == number)
		{
		    GetStreet(payphone_data[i][payphone_pos][0], payphone_data[i][payphone_pos][1], payphone_data[i][payphone_pos][2], str, 64);
		    return str;
		}
	}
	return str;
}

AssignPayphone(playerid, payphone)
{
	if (IsValidPayphoneID(payphone))
	{
	    PlayerTextDrawSetString(playerid, PP_Btn[playerid][0], "Dialing..");
		    
		PlayerInfo[playerid][pPayphone] = payphone;
		payphone_data[payphone][payphone_state] = PAYPHONE_STATE_INCALL;
		payphone_data[payphone][payphone_caller] = INVALID_PLAYER_ID;
	    UpdatePayphone(payphone);
	}
}

CallPayphone(playerid, payphone)
{
    payphone_data[payphone][payphone_state] = PAYPHONE_STATE_INCALL;
	payphone_data[payphone][payphone_caller] = playerid;
	UpdatePayphone(payphone);
}

UpdatePayphone(id)
{
	if (!payphone_data[id][payphone_exist]) return 0;
    if (IsPlayerConnected(payphone_data[id][payphone_caller]))
	{
	    if(IsValidDynamic3DTextLabel(payphone_data[id][payphone_text])) DestroyDynamic3DTextLabel(payphone_data[id][payphone_text]);
        payphone_data[id][payphone_text] = CreateDynamic3DTextLabel("** Payphone is ringing ** \n (( /payphone to pick it up ))", COLOR_EMOTE, payphone_data[id][payphone_pos][0], payphone_data[id][payphone_pos][1], payphone_data[id][payphone_pos][2]+2.0, 10.0);
	}
	else
	{
		if(IsValidDynamic3DTextLabel(payphone_data[id][payphone_text])) DestroyDynamic3DTextLabel(payphone_data[id][payphone_text]);
	}
	return 1;
}

CallNumber(playerid, number, payphone = 0) // 0 = INVALID_PAYPHONE
{
    if (PlayerInfo[playerid][pCalling])
	{
	    return SendErrorMessage(playerid, "You are already on a call.");
	}
	else if (PlayerInfo[playerid][pPhone] == number)
	{
		return SendErrorMessage(playerid, "You can't dial your own number.");
	}
	else
	{
	    new targetid = GetPhonePlayerID(number);
		if (IsValidPayphoneID(payphone))
  		{
	        callcmd::me(playerid, "inserts a coin and picks up the payphone.");
	        AssignPayphone(playerid, payphone);
        }
        else
        {
            callcmd::ame(playerid, "dials a number on their phone.");
        }

        if (IsPlayerConnected(targetid))
        {
			if (PlayerInfo[targetid][pPhoneOff])
  			{
			    PlayerTextDrawSetString(playerid, PhoneTime[playerid], "Call_Failed");
			    return SetTimerEx("HangupDelay", 2500, false, "i", playerid);
        	}
        	else if (PlayerInfo[targetid][pCalling] > 0)
  			{
			    PlayerTextDrawSetString(playerid, PhoneTime[playerid], "Call_Failed");
			    return SetTimerEx("HangupDelay", 2500, false, "i", playerid);
        	}
	        else
       		{
       		    new str[64];
       		    Phone_HideUI(playerid);
       		    Phone_ShowUI(playerid);
				PlayerTextDrawSetString(playerid, PhoneTime[playerid], "Dialing..");
				format(str, sizeof(str), "(%d)", number);
				PlayerTextDrawSetString(playerid, PhoneDate[playerid], str);
				PlayerTextDrawHide(playerid, PhoneBtnMenu[playerid]);
				
       		    PlayerInfo[playerid][pCalling] = 1;
      			PlayerInfo[playerid][pPhoneline] = targetid;
      			PlayerInfo[ PlayerInfo[playerid][pPhoneline] ][pCalling] = 1;
      			PlayerInfo[ PlayerInfo[playerid][pPhoneline] ][pPhoneline] = playerid;
				if (IsValidPayphoneID(payphone))
				{
	    			Phone_HideUI(targetid);
	    			Phone_ShowUI(targetid);
					PlayerTextDrawSetString(playerid, PhoneTime[targetid], "Incoming_call");
					format(str, sizeof(str), "(%d)", payphone_data[payphone][payphone_numstr]);
					PlayerTextDrawSetString(playerid, PhoneDate[targetid], str);
					PlayerTextDrawHide(playerid, PhoneBtnMenu[targetid]);
				}
				else
				{
				    Phone_HideUI(targetid);
				    Phone_ShowUI(targetid);
					PlayerTextDrawSetString(playerid, PhoneTime[targetid], "Incoming_call");
					format(str, sizeof(str), "(%d)", PlayerInfo[playerid][pPhone]);
					PlayerTextDrawSetString(playerid, PhoneDate[targetid], str);
					PlayerTextDrawHide(playerid, PhoneBtnMenu[targetid]);
					
				}
				callcmd::my(targetid, "phone starts to ring.");
				HandlePhoneRing(targetid);
			}
	    }
	    else
		{
		    new id = GetPhonePayphoneID(number);

		    if (IsValidPayphoneID(id) && payphone_data[id][payphone_state] == PAYPHONE_STATE_NONE)
		    {
       		    new str[64];
       		    Phone_HideUI(playerid);
       		    Phone_ShowUI(playerid);
				PlayerTextDrawSetString(playerid, PhoneTime[playerid], "Dialing..");
				format(str, sizeof(str), "(%s)", payphone_data[id][payphone_numstr]);
				PlayerTextDrawSetString(playerid, PhoneDate[playerid], str);
				PlayerTextDrawHide(playerid, PhoneBtnMenu[playerid]);
				CallPayphone(playerid, id);
			}
			else
			{
       		    new str[64];
       		    Phone_HideUI(playerid);
       		    Phone_ShowUI(playerid);
				PlayerTextDrawSetString(playerid, PhoneTime[playerid], "Dialing..");
				format(str, sizeof(str), "(%d)", number);
				PlayerTextDrawSetString(playerid, PhoneDate[playerid], str);
				PlayerTextDrawHide(playerid, PhoneBtnMenu[playerid]);
				
				SetTimerEx("OnPhoneResponse", 3000, false, "ii", playerid, number);
			}
			PlayerInfo[playerid][pCalling] = 1;
		}

		SetPlayerCellphoneAction(playerid, true);
		HandlePhoneDial(playerid);
        PlayerPlaySound(playerid, 16001, 0.0, 0.0, 0.0);
	}
	return 1;
}

this::HandlePhoneRing(playerid)
{
	if (PlayerInfo[playerid][pCalling] != 1)
	{
	    return 0;
	}
	PlayNearbySound(playerid, 20600);
	SetTimerEx("HandlePhoneRing", 4000, false, "i", playerid);
	return 1;
}

this::HandlePhoneDial(playerid)
{
	if (PlayerInfo[playerid][pCalling] != 1)
	{
	    return 0;
	}
	if(GetNearestAntenna(playerid) == -1)
	{
	    PlayerTextDrawSetString(playerid, PhoneTime[playerid], "Call_Failed");
	    return SetTimerEx("HangupDelay", 2500, false, "i", playerid);
	}
	if(GetNearestAntenna(PlayerInfo[playerid][pPhoneline]) == -1)
	{
	    return HangupCall(playerid);
	}
	PlayerPlaySound(playerid, 16001, 0.0, 0.0, 0.0);
	SetTimerEx("HandlePhoneDial", 4000, false, "i", playerid);
	return 1;
}

this::HangupDelay(playerid)
{
    HangupCall(playerid);
}
this::RefreshPhone(playerid)
{
 	Phone_HideUI(playerid);
 	Phone_ShowUI(playerid);
}
this::HideNotify(playerid)
{
    PlayerTextDrawSetString(playerid, PhoneNotify[playerid], "Call_Failed");
}
VehicleHasDoors(vehicleid)
{
	switch (GetVehicleModel(vehicleid))
	{
		case 400..424, 426..429, 431..440, 442..445, 451, 455, 456, 458, 459, 466, 467, 470, 474, 475, 477..480, 482, 483, 486, 489, 490..492, 494..496, 498..500, 502..508, 514..518, 524..529, 533..536, 540..547, 549..552, 554..562, 565..568, 573, 575, 576, 578..580, 582, 585, 587..589, 596..605, 609:
			return 1;
	}
	return 0;
}

SetPlayerCellphoneAction(playerid, enable)
{
	if (GetPlayerTeam(playerid) == PLAYER_STATE_ALIVE || PlayerInfo[playerid][pHandcuffed])
	{
	    return 0;
	}
	else
	{
		if (VehicleHasDoors(GetPlayerVehicleID(playerid)) && PlayerInfo[playerid][pChatting])
		{
		    PlayerInfo[playerid][pChatting] = 0;
		}
	    if (enable)
	    {
	        if (VehicleHasDoors(GetPlayerVehicleID(playerid)))
	        {
				ApplyAnimation(playerid, "CAR_CHAT", "carfone_in", 4.1, 0, 0, 0, 1, 0, 1);
			}
			else
			{
				SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USECELLPHONE);
			}
		}
		else
		{
		    if (VehicleHasDoors(GetPlayerVehicleID(playerid)))
	        {
				ApplyAnimation(playerid, "CAR_CHAT", "carfone_out", 4.1, 0, 0, 0, 0, 0, 1);
			}
			else
			{
		    	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_STOPUSECELLPHONE);
			}
		}
	}
	return 1;
}

this::OnPhoneResponse(playerid, number)
{
	if ((PlayerInfo[playerid][pPayphone] > 0 && GetClosestPayphone(playerid) != PlayerInfo[playerid][pPayphone]) || PlayerInfo[playerid][pPhoneOff] || !PlayerInfo[playerid][pCalling])
	{
	    return 0;
	}

    switch (number)
    {
        case 444: // add random name array here for more realistic
		{
	    	SendClientMessage(playerid, COLOR_YELLOWEX, "Agency says (phone): Hello, San Andreas Network!");
	    	PlayerInfo[playerid][pCalling] = 2;
	    	PlayerInfo[playerid][pPhoneline] = number;
	    	PlayerTextDrawSetString(playerid, PP_Btn[playerid][0], "Dialing..");
		}
        case 445: // add random name array here for more realistic
		{
	    	SendClientMessage(playerid, COLOR_YELLOWEX, "Agency says (phone): Hello, San Andreas Network!");
	    	PlayerInfo[playerid][pCalling] = 2;
	    	PlayerInfo[playerid][pPhoneline] = number;
	    	PlayerTextDrawSetString(playerid, PP_Btn[playerid][0], "Dialing..");
		}
	    case 911:
	    {
			SendClientMessage(playerid, COLOR_YELLOW, "911 Operator says (phone): Which service do you require?");
	    	PlayerInfo[playerid][pCalling] = 2;
	    	PlayerInfo[playerid][pPhoneline] = number;
	    	PlayerTextDrawSetString(playerid, PP_Btn[playerid][0], "Dialing..");
		}
		case 991:
		{
			SendClientMessage(playerid, COLOR_YELLOW, "911 Operator says (phone): This is the police non-emergency line, what can we help you with?");
	    	PlayerInfo[playerid][pCalling] = 2;
	    	PlayerInfo[playerid][pPhoneline] = number;
	    	PlayerTextDrawSetString(playerid, PP_Btn[playerid][0], "Dialing..");
		}
		default:
		{
		    new targetid = GetPhonePlayerID(number);

		    if (targetid == INVALID_PLAYER_ID)
		    {
			    PlayerTextDrawSetString(playerid, PhoneTime[playerid], "Call_Failed");
			    SetTimerEx("HangupDelay", 2500, false, "i", playerid);
			}
		    else if (IsPhoneBusy(number))
		    {
			    PlayerTextDrawSetString(playerid, PhoneTime[playerid], "Call_Failed");
			    SetTimerEx("HangupDelay", 2500, false, "i", playerid);
		    }
		}
	}
	return 1;
}

HangupCall(playerid)
{
	if (PlayerInfo[playerid][pCalling] > 0)
	{
	    for (new i = 1; i < MAX_PAYPHONE; i ++)
	    {
	        if (IsValidPayphoneID(i) && payphone_data[i][payphone_caller] == playerid)
	        {
	            payphone_data[i][payphone_caller] = INVALID_PLAYER_ID;
				payphone_data[i][payphone_state] = 0;
	            UpdatePayphone(i);
	        }
	    }
	    if (PlayerInfo[playerid][pPhoneline] != INVALID_PLAYER_ID)
 		{
 		    SetPlayerCellphoneAction(PlayerInfo[playerid][pPhoneline], false);
	  		SendClientMessage(PlayerInfo[playerid][pPhoneline], COLOR_GREY, "[ ! ] They hung up.");
			PlayerPlaySound(PlayerInfo[playerid][pPhoneline], 20601, 0.0, 0.0, 0.0);
			if (PlayerInfo[ PlayerInfo[playerid][pPhoneline] ][pPayphone] != INVALID_ID)
			{
				ResetPayphone(PlayerInfo[playerid][pPhoneline]);
				callcmd::me(PlayerInfo[playerid][pPhoneline], "hangs up the payphone.");
			}
			else
			{
			    callcmd::me(PlayerInfo[playerid][pPhoneline], "pockets the phone.");
			}
			Phone_HideUI( PlayerInfo[playerid][pPhoneline] );
	        Phone_ShowUI( PlayerInfo[playerid][pPhoneline] );
			PlayerInfo[ PlayerInfo[playerid][pPhoneline] ][pCalling] = 0;
	    	PlayerInfo[ PlayerInfo[playerid][pPhoneline] ][pPhoneline] = INVALID_PLAYER_ID;
		}
		Phone_HideUI(playerid);
        Phone_ShowUI(playerid);
        CancelSelectTextDraw(playerid);
		PlayerPlaySound(playerid, 20601, 0.0, 0.0, 0.0);
		SetPlayerCellphoneAction(playerid, false);
	    PlayerInfo[playerid][pCalling] = 0;
	    PlayerInfo[playerid][pPhoneline] = INVALID_PLAYER_ID;
		if (PlayerInfo[playerid][pPayphone] != INVALID_ID)
		{
			ResetPayphone(playerid);
			callcmd::me(playerid, "hangs up the payphone.");
		}
		else
		{
		    callcmd::me(playerid, "puts their phone away.");
		}
	}
	return 1;
}
ResetPayphone(playerid)
{
    if (PlayerInfo[playerid][pPayphone] != INVALID_ID)
	{
	    GiveMoney(playerid, -5);
	    payphone_data[ PlayerInfo[playerid][pPayphone] ][payphone_coin] += 5;
		payphone_data[PlayerInfo[playerid][pPayphone]][payphone_state] = 0;
		UpdatePayphone(PlayerInfo[playerid][pPayphone]);
	}
    new hour, minute, second, str[64];
	gettime(hour, minute, second);
	format(str, sizeof(str), "%02d:%02d", hour, minute);
    PlayerTextDrawSetString(playerid, PP_Btn[playerid][0], str);
	PlayerInfo[playerid][pPayphone] = INVALID_ID;
}
this::UpdateTextDraw()
{
	foreach(new playerid : Player)
	{
	    if(!IsPlayerConnected(playerid))
	        continue;
	        
	    new hour, minute, second, str[64], MonthStr[40], year, month, day;
		gettime(hour, minute, second);
		getdate(year, month, day);
		switch(month)
		{
		    case 1:  MonthStr = "January";
		    case 2:  MonthStr = "February";
		    case 3:  MonthStr = "March";
		    case 4:  MonthStr = "April";
		    case 5:  MonthStr = "May";
		    case 6:  MonthStr = "June";
		    case 7:  MonthStr = "July";
		    case 8:  MonthStr = "August";
		    case 9:  MonthStr = "September";
		    case 10: MonthStr = "October";
		    case 11: MonthStr = "November";
		    case 12: MonthStr = "December";
		}

		if(PlayerInfo[playerid][pPhoneline] == INVALID_PLAYER_ID && PlayerInfo[playerid][pCalling] == 0)
		{
			if(GetPVarInt(playerid, "UsePayphone"))
			{
				format(str, sizeof(str), "%02d:%02d", hour, minute);
			    PlayerTextDrawSetString(playerid, PP_Btn[playerid][0], str);
		    }
			if(PlayerInfo[playerid][pUseGUI])
			{
				format(str, sizeof(str), "%02d:%02d", hour, minute);
			    PlayerTextDrawSetString(playerid, PhoneTime[playerid], str);
			    format(str, sizeof(str), "%s_%d", MonthStr, day);
			    PlayerTextDrawSetString(playerid, PhoneDate[playerid], str);
			}
		}
	}
}

GetDynamicPlayerPos(playerid, &Float:x, &Float:y, &Float:z)
{
	new world = GetPlayerVirtualWorld(playerid);
	if(world == 0)
	{
	    GetPlayerPos(playerid, x, y, z);
	}
	else
	{
	    new propertyID = IsPlayerInProperty(playerid);
	    new businessID = IsPlayerInBusiness(playerid);
	    if(propertyID)
	    {
			x = PropertyInfo[propertyID][ePropertyEntrance][0];
			y = PropertyInfo[propertyID][ePropertyEntrance][1];
			z = PropertyInfo[propertyID][ePropertyEntrance][2];
	    }
	    else if(businessID)
	    {
			x = BusinessInfo[propertyID][eBusinessEntrance][0];
			y = BusinessInfo[propertyID][eBusinessEntrance][1];
			z = BusinessInfo[propertyID][eBusinessEntrance][2];
	    }
	    else
	    {
	        GetPlayerPos(playerid, x, y, z);
	    }

	}
	return 1;
}

GetNearestAntenna(playerid, Float:radius = 600.0)
{
    new Float:x, Float:y, Float:z, Float:distance, result = -1;
	GetDynamicPlayerPos(playerid, x, y, z);

	for(new j, js = sizeof(AntennasRadio); j < js; j++)
	{
        Streamer_GetDistanceToItem(x, y, z, STREAMER_TYPE_OBJECT, AntennasRadio[j][arObject], distance);
        if(distance < radius)
		{
		    radius = distance;
			result = j;
		}
		continue;
	}
	return (result == -1) ? (-1) : (radius <= 600.0 - 75.0) ? (result) : (sizeof(AntennasRadio) + result);
}

GetNearestAntennaEx(playerid, Float:radius = 600.0)
{
    new Float:x, Float:y, Float:z, Float:distance, result = -1;
	GetDynamicPlayerPos(playerid, x, y, z);

	for(new j, js = sizeof(AntennasRadio); j < js; j++)
	{
        Streamer_GetDistanceToItem(x, y, z, STREAMER_TYPE_OBJECT, AntennasRadio[j][arObject], distance);
        if(distance < radius)
		{
		    radius = distance;
			result = j;
		}
		continue;
	}
	return result;
}

CMD:elm(playerid, params[])
{
	if(!IsPlayerInAnyVehicle(playerid))
		return SendErrorMessage(playerid, "You aren't in any vehicle.");

	new vehicleid = GetPlayerVehicleID(playerid);
	if(FactionInfo[PlayerInfo[playerid][pFaction]][eFactionType] != FACTION_TYPE_POLICE && FactionInfo[PlayerInfo[playerid][pFaction]][eFactionType] != FACTION_TYPE_MEDICAL && FactionInfo[PlayerInfo[playerid][pFaction]][eFactionType] != FACTION_TYPE_DOC)
		return SendClientMessage(playerid, COLOR_RED, "ACCESS DENIED:{FFFFFF} You can't use this command.");
		
	if(!VehicleInfo[vehicleid][eVehicleFaction])
		return SendErrorMessage(playerid, "You aren't in a faction vehicle.");
		
	if(GetVehicleModel(vehicleid) >= 596 && GetVehicleModel(vehicleid) <= 598)
	{
	    if(!GetPVarInt(playerid, "MDCLayout")) showMDCLayout(playerid, true);
	    else showMDCLayout(playerid, false);
	}
	else return SendErrorMessage(playerid, "You are not in a PD cruiser.");
	return 1;
}

stock showMDCLayout(playerid, bool:show)
{
	if(show)
	{
		new str[64];
	    format(str, sizeof(str), "~g~%s", (VehicleInfo[GetPlayerVehicleID(playerid)][eVehicleSirenUsed]) ? ("On") : ("Off"));
		PlayerTextDrawSetString(playerid, MDC_Layout[playerid][4], str);
		
	    format(str, sizeof(str), "~g~%s", (VehicleInfo[GetPlayerVehicleID(playerid)][eVehicleSirenUsed]) ? ("On") : ("Off"));
		PlayerTextDrawSetString(playerid, MDC_Layout[playerid][6], str);
		
	    format(str, sizeof(str), "~g~%s", (VehicleInfo[GetPlayerVehicleID(playerid)][eVehicleSirenUsed]) ? ("On") : ("Off"));
		PlayerTextDrawSetString(playerid, MDC_Layout[playerid][8], str);
		
		for(new i; i < 19; i ++) PlayerTextDrawShow(playerid, MDC_Layout[playerid][i]);
		
	    SetPVarInt(playerid, "MDCLayout", 1);
	    SelectTextDraw(playerid, COLOR_GREY);
	    SendClientMessage(playerid, COLOR_DARKGREEN, "ACCESSED:{FFFFFF} You can hold RMB and press Left Alt to re-active the cursor.");
	}
	else
	{
	    CancelSelectTextDraw(playerid);
	    for(new i; i < 19; i ++) PlayerTextDrawHide(playerid, MDC_Layout[playerid][i]);
	    SetPVarInt(playerid, "MDCLayout", 0);
	}
	return 1;
}

stock SirenEvent(vehicleid, slot, bool:show, bool:force = false)
{
	if(show)
	{
	    VehicleInfo[vehicleid][eVehicleSirenUsed][slot] = true;
		VehicleInfo[vehicleid][eVehicleSiren][slot] = CreateObject(siren_array[slot][siren_model], 0, 0, -1000.0, 0, 0, 0);
		AttachObjectToVehicle(VehicleInfo[vehicleid][eVehicleSiren][slot], vehicleid, siren_array[slot][siren_offsetX], siren_array[slot][siren_offsetY], siren_array[slot][siren_offsetZ], siren_array[slot][siren_rotX], siren_array[slot][siren_rotY], siren_array[slot][siren_rotZ]);
		if(siren_array[slot][IsDynamic]) VehicleInfo[vehicleid][eVehicleSirenTimer][slot] = SetTimerEx("OnSirenChange", siren_array[slot][flash_time], true, "ii", vehicleid, slot);
	}
	else
	{
	    if(!force)
	    {
	        if(slot == 1) for(new i = 0; i < 3; i ++) DestroyObject(VehicleInfo[vehicleid][eVehicleFlashRaise][i]);

		    DestroyObject(VehicleInfo[vehicleid][eVehicleSiren][slot]);
		    KillTimer(VehicleInfo[vehicleid][eVehicleSirenTimer][slot]);
		    VehicleInfo[vehicleid][eVehicleSirenUsed][slot] = false;
		    VehicleInfo[vehicleid][eVehicleFlash][slot] = false;
		}
		else
		{
		    for(new i = 0; i < 3; i ++) if(IsValidObject(VehicleInfo[vehicleid][eVehicleFlashRaise][i])) DestroyObject(VehicleInfo[vehicleid][eVehicleFlashRaise][i]);
		    for(new x = 0; x < 4; x ++)
		    {
			    if(IsValidObject(VehicleInfo[vehicleid][eVehicleSiren][x])) DestroyObject(VehicleInfo[vehicleid][eVehicleSiren][x]);
			    KillTimer(VehicleInfo[vehicleid][eVehicleSirenTimer][x]);
			    VehicleInfo[vehicleid][eVehicleSirenUsed][x] = false;
			    VehicleInfo[vehicleid][eVehicleFlash][x] = false;
		    }
		}
	}
	return 1;
}

this::OnSirenChange(vehicleid, slot) // 4 as a extra slot for silent siren, 5 as a extra slot for roof
{
	switch(slot)
	{
		case 0:
		{
			if(!VehicleInfo[vehicleid][eVehicleFlash][slot])
			{
		        DestroyObject(VehicleInfo[vehicleid][eVehicleSiren][0]);
		        VehicleInfo[vehicleid][eVehicleSiren][0] = CreateObject(19296, 0, 0, -1000.0, 0, 0, 0);
		        AttachObjectToVehicle(VehicleInfo[vehicleid][eVehicleSiren][0], vehicleid, 0.0000, 0.0000, 1.2000, 0.0000, 0.0000, 0.0000);
		        VehicleInfo[vehicleid][eVehicleFlash][slot] = true;

			}
			else
			{
			    DestroyObject(VehicleInfo[vehicleid][eVehicleSiren][0]);
			    VehicleInfo[vehicleid][eVehicleSiren][0] = CreateObject(19298, 0, 0, -1000.0, 0, 0, 0);
			    AttachObjectToVehicle(VehicleInfo[vehicleid][eVehicleSiren][0], vehicleid, 0.0000, 0.0000, 1.2000, 0.0000, 0.0000, 0.0000);
			    VehicleInfo[vehicleid][eVehicleFlash][slot] = false;
			}
		}
		case 1:
		{
            VehicleInfo[vehicleid][eVehicleFlash][slot] ++;
			if(VehicleInfo[vehicleid][eVehicleFlash][slot] >= 3) VehicleInfo[vehicleid][eVehicleFlash][slot] = 0;
            switch(VehicleInfo[vehicleid][eVehicleFlash][slot])
            {
                case 0:
                {
		            if(!IsValidObject(VehicleInfo[vehicleid][eVehicleFlashRaise][0]))
		            {
		            	VehicleInfo[vehicleid][eVehicleFlashRaise][0] = CreateObject(19294, 0, 0, -1000.0, 0, 0, 0);
		            	AttachObjectToVehicle(VehicleInfo[vehicleid][eVehicleFlashRaise][0], vehicleid, 0.3000, -0.2500, 1.0000, 0.0000, 0.0000, 0.0000);
		            }
		            else
		            {
						DestroyObject(VehicleInfo[vehicleid][eVehicleFlashRaise][0]);
		            }
                }
                case 1:
                {
		            if(!IsValidObject(VehicleInfo[vehicleid][eVehicleFlashRaise][1]))
		            {
		            	VehicleInfo[vehicleid][eVehicleFlashRaise][1] = CreateObject(19294, 0, 0, -1000.0, 0, 0, 0);
		            	AttachObjectToVehicle(VehicleInfo[vehicleid][eVehicleFlashRaise][1], vehicleid, 0.1000, -0.2500, 1.0000, 0.0000, 0.0000, 0.0000);
		            }
		            else
		            {
						DestroyObject(VehicleInfo[vehicleid][eVehicleFlashRaise][1]);
		            }
                }
                case 2:
                {
		            if(!IsValidObject(VehicleInfo[vehicleid][eVehicleFlashRaise][2]))
		            {
		            	VehicleInfo[vehicleid][eVehicleFlashRaise][2] = CreateObject(19294, 0, 0, -1000.0, 0, 0, 0);
		            	AttachObjectToVehicle(VehicleInfo[vehicleid][eVehicleFlashRaise][2], vehicleid, -0.9000, -0.2500, 1.0000, 0.0000, 0.0000, 0.0000);
		            }
		            else
		            {
						DestroyObject(VehicleInfo[vehicleid][eVehicleFlashRaise][2]);
		            }
                }
            }
		}
	}
	return 1;
}

stock ReturnBusinessName(type)
{
	new str[24];
	switch(type)
	{
	    case 1: str = "Restaurant";
	    case 2: str = "Ammunation";
	    case 3: str = "Club";
	    case 4: str = "Bank";
	    case 5: str = "General Store";
	    case 6: str = "Dealership";
	    case 7: str = "DMV";
	    default: str = "Business";
	}
	return str;
}

this::OnCSCreated(playerid, Float: offX, Float: offY, Float: offZ, Float: rotX, Float: rotY, Float: rotZ)
{
	new idx = -1;
	for(new i = 0; i < MAX_CHOPSHOP; i++)
	{
		if(chopshop_data[i][chopshop_exist])
			continue;

		idx = i;
		break;
	}
	
	chopshop_data[idx][chopshop_id] = cache_insert_id();
	chopshop_data[idx][chopshop_pos][0] = offX;
	chopshop_data[idx][chopshop_pos][1] = offY;
	chopshop_data[idx][chopshop_pos][2] = offZ;
	chopshop_data[idx][chopshop_pos][3] = rotX;
	chopshop_data[idx][chopshop_pos][4] = rotY;
	chopshop_data[idx][chopshop_pos][5] = rotZ;
//	chopshop_data[idx][chopshop_faction] = faction;
	chopshop_data[idx][chopshop_money] = 0;
	chopshop_data[idx][chopshop_exist] = true;
	GetRandomModel(idx);
    chopshop_data[idx][chopshop_object][0] = CreateDynamicObject(3077, offX, offY, offZ, rotX, rotY, rotZ);
	
	
	if(rotZ > 0)
	{
		chopshop_data[idx][chopshop_object][1] = CreateDynamicObject(19482, offX, offY+0.1, offZ+1.9, rotX, rotY, rotZ-90);
	}
	else
	{
        chopshop_data[idx][chopshop_object][1] = CreateDynamicObject(19482, offX, offY+0.1, offZ+1.9, rotX, rotY, rotZ+90);
	}
	
	new string[512];
	format(string, sizeof(string), "Wanted\n((/delivercar))\n%s     %s\n%s     %s\n%s     %s\n%s     %s\n%s     %s",
	ReturnVehicleModelName(chopshop_data[idx][chopshop_wanted][0]),
	ReturnVehicleModelName(chopshop_data[idx][chopshop_wanted][1]),
	ReturnVehicleModelName(chopshop_data[idx][chopshop_wanted][2]),
	ReturnVehicleModelName(chopshop_data[idx][chopshop_wanted][3]),
	ReturnVehicleModelName(chopshop_data[idx][chopshop_wanted][4]),
	ReturnVehicleModelName(chopshop_data[idx][chopshop_wanted][5]),
	ReturnVehicleModelName(chopshop_data[idx][chopshop_wanted][6]),
	ReturnVehicleModelName(chopshop_data[idx][chopshop_wanted][7]),
	ReturnVehicleModelName(chopshop_data[idx][chopshop_wanted][8]),
	ReturnVehicleModelName(chopshop_data[idx][chopshop_wanted][9]));
	
    SetDynamicObjectMaterialText(chopshop_data[idx][chopshop_object][1], 0, string, OBJECT_MATERIAL_SIZE_512x256, "Comic Sans MS", 26, 1, -1, 0, 1);
	return 1;
}

stock EditChopShop(playerid, id)
{
	if(!chopshop_data[id][chopshop_exist]) return SendClientMessage(playerid, COLOR_RED, "This chopshop does not exist.");
	new Float: x, Float: y, Float: z;
	GetPlayerPos(playerid, x, y, z);
	PlayerInfo[playerid][pEditingObject] = 8;
	return EditDynamicObject(playerid, chopshop_data[id][chopshop_object][0]);
}

this::Query_LoadChopshop()
{
	if(!cache_num_rows())
		return printf("[SERVER]: No chopshops were loaded from \"%s\" database...", SQL_DATABASE);

	new rows, fields; cache_get_data(rows, fields, this);
	new count = 0;

	for(new i = 0; i < rows && i < MAX_CHOPSHOP; i++)
	{
		chopshop_data[i][chopshop_id] = cache_get_field_content_int(i, "id", this);
		chopshop_data[i][chopshop_pos][0] = cache_get_field_content_float(i, "offsetX", this);
		chopshop_data[i][chopshop_pos][1] = cache_get_field_content_float(i, "offsetY", this);
		chopshop_data[i][chopshop_pos][2] = cache_get_field_content_float(i, "offsetZ", this);
		chopshop_data[i][chopshop_pos][3] = cache_get_field_content_float(i, "rotX", this);
		chopshop_data[i][chopshop_pos][4] = cache_get_field_content_float(i, "rotY", this);
		chopshop_data[i][chopshop_pos][5] = cache_get_field_content_float(i, "rotZ", this);
		chopshop_data[i][chopshop_faction] = cache_get_field_content_int(i, "faction", this);
		chopshop_data[i][chopshop_money] = cache_get_field_content_int(i, "money", this);
		chopshop_data[i][chopshop_exist] = true;
		GetRandomModel(i);
    	chopshop_data[i][chopshop_object][0] = CreateDynamicObject(3077, chopshop_data[i][chopshop_pos][0], chopshop_data[i][chopshop_pos][1], chopshop_data[i][chopshop_pos][2], chopshop_data[i][chopshop_pos][3], chopshop_data[i][chopshop_pos][4], chopshop_data[i][chopshop_pos][5]);
		if(chopshop_data[i][chopshop_pos][5] > 0)
		{
			chopshop_data[i][chopshop_object][1] = CreateDynamicObject(19482, chopshop_data[i][chopshop_pos][0], chopshop_data[i][chopshop_pos][1]+0.1, chopshop_data[i][chopshop_pos][2]+1.9, chopshop_data[i][chopshop_pos][3], chopshop_data[i][chopshop_pos][4], chopshop_data[i][chopshop_pos][5]-90);
		}
		else
		{
            chopshop_data[i][chopshop_object][1] = CreateDynamicObject(19482, chopshop_data[i][chopshop_pos][0], chopshop_data[i][chopshop_pos][1]+0.1, chopshop_data[i][chopshop_pos][2]+1.9, chopshop_data[i][chopshop_pos][3], chopshop_data[i][chopshop_pos][4], chopshop_data[i][chopshop_pos][5]+90);
		}
		new string[512];
		format(string, sizeof(string), "Wanted\n((/delivercar))\n%s     %s\n%s     %s\n%s     %s\n%s     %s\n%s     %s",
		ReturnVehicleModelName(chopshop_data[i][chopshop_wanted][0]),
		ReturnVehicleModelName(chopshop_data[i][chopshop_wanted][1]),
		ReturnVehicleModelName(chopshop_data[i][chopshop_wanted][2]),
		ReturnVehicleModelName(chopshop_data[i][chopshop_wanted][3]),
		ReturnVehicleModelName(chopshop_data[i][chopshop_wanted][4]),
		ReturnVehicleModelName(chopshop_data[i][chopshop_wanted][5]),
		ReturnVehicleModelName(chopshop_data[i][chopshop_wanted][6]),
		ReturnVehicleModelName(chopshop_data[i][chopshop_wanted][7]),
		ReturnVehicleModelName(chopshop_data[i][chopshop_wanted][8]),
		ReturnVehicleModelName(chopshop_data[i][chopshop_wanted][9]));

	    SetDynamicObjectMaterialText(chopshop_data[i][chopshop_object][1], 0, string, OBJECT_MATERIAL_SIZE_512x256, "Comic Sans MS", 26, 1, -1, 0, 1);

		count ++;
	}
	printf("[SERVER]: %d chopshops were loaded from \"%s\" database...", count, SQL_DATABASE);
	return 1;
}

stock SaveChopshop(id)
{
	new query[300];
	
	mysql_format(this, query, sizeof(query), "UPDATE chopshop SET offsetX = %f, offsetY = %f, offsetZ = %f, rotX = %f, rotY = %f, rotZ = %f, faction = %i, money = %i WHERE id = %i",
		chopshop_data[id][chopshop_pos][0],
		chopshop_data[id][chopshop_pos][1],
		chopshop_data[id][chopshop_pos][2],
		chopshop_data[id][chopshop_pos][3],
		chopshop_data[id][chopshop_pos][4],
		chopshop_data[id][chopshop_pos][5],
		chopshop_data[id][chopshop_faction],
		chopshop_data[id][chopshop_money],
		chopshop_data[id][chopshop_id]);
	mysql_tquery(this, query);
	return 1;
}

stock GetChopshopID(playerid)
{
	for(new i; i < MAX_CHOPSHOP; i ++)
	{
	    if(!chopshop_data[i][chopshop_exist])
			continue;
	    
	    if(IsPlayerInRangeOfPoint(playerid, 3.0, chopshop_data[i][chopshop_pos][0], chopshop_data[i][chopshop_pos][1], chopshop_data[i][chopshop_pos][2]))
	    {
	        return i;
	    }
	}
	return -1;
}

stock CheckWantedModel(cs_id, modelid)
{
	for(new i = 0; i < 10; i ++)
	{
		if(chopshop_data[cs_id][chopshop_wanted][i] == modelid)
		{
		    return 1;
		}
	}
	return 0;
}

stock GetRandomModel(id)
{
	for(new i = 0; i < 10; i ++)
	{
		if(chopshop_data[id][chopshop_exist])
		{
		    chopshop_data[id][chopshop_wanted][i] = g_aDealershipData[random(sizeof(g_aDealershipData))][eDealershipModelID];
		}
	}
    return 0;
}



stock CJ_MissionReward(vehicleid)
{
	new
		car_price = g_aDealershipData[vehicleid][eDealershipPrice],
		count,
		final_money = 50,
		Float: vehHP
	;
	
	final_money += (car_price * 0.01);
	GetVehicleHealth(vehicleid, vehHP);
	if(vehHP > 850.0) final_money += 50;

	//if(distance < 100.0) final_money += floatround(distance * 2);
	//else final_money += 200;
	new component;
	for(new j; j < 14; j++)
	{
	    component = GetVehicleComponentInSlot(vehicleid, j);
	    if(!component) continue;
	    RemoveVehicleComponent(vehicleid, component);
	    VehicleInfo[vehicleid][eVehicleMods][GetVehicleComponentType(component)] = 0;
        SaveComponent(vehicleid, j);
		count++;
	}
	final_money += (count * 25);
	return final_money;
}

stock ShowInfo(playerid, title[], string[], delay = 4000)
{
	for(new i; i < 2; i ++) PlayerTextDrawShow(playerid, JobInfo[playerid][i]);
	PlayerTextDrawSetString(playerid, JobInfo[playerid][0], title);
	PlayerTextDrawSetString(playerid, JobInfo[playerid][1], string);
	return SetTimerEx("onTextSend", delay, false, "ii", playerid, 1);
}

stock ShowInfoEx(playerid, title[], string[], bool:disable = false)
{
	for(new i; i < 2; i ++) PlayerTextDrawShow(playerid, JobInfo[playerid][i]);
	PlayerTextDrawSetString(playerid, JobInfo[playerid][0], title);
	PlayerTextDrawSetString(playerid, JobInfo[playerid][1], string);
	if(disable)
	{
		PlayerTextDrawHide(playerid, JobInfo[playerid][0]);
		PlayerTextDrawHide(playerid, JobInfo[playerid][1]);
	}
	return 1;
}

this::OnLoadVehicleMods(vehicle)
{
    new
	    rows = cache_get_row_count(this),
		slot;

	for (new i = 0; i < rows; i ++)
	{
		slot = cache_get_field_content_int(i, "Slot");

		VehicleInfo[vehicle][eVehicleMods][slot] = cache_get_field_content_int(i, "Component");
	}
	ApplyModifications(vehicle);
}

SaveComponent(id, slot)
{
	static
	    queryString[200];

    if (!VehicleInfo[id][eVehicleExists]) return 0;

	format(queryString, sizeof(queryString), "INSERT INTO vehiclemods VALUES(%i, %i, %i) ON DUPLICATE KEY UPDATE Component = %i", VehicleInfo[id][eVehicleDBID], slot, VehicleInfo[id][eVehicleMods][slot], VehicleInfo[id][eVehicleMods][slot]);
	return mysql_tquery(this, queryString);
}

ApplyModifications(id)
{
	if (IsValidVehicle(id))
	{
	    ChangeVehicleColor(id, VehicleInfo[id][eVehicleColor1], VehicleInfo[id][eVehicleColor2]);

	    if (VehicleInfo[id][eVehiclePaintjob] != INVALID_ID)
	    {
	        ChangeVehiclePaintjob(id, VehicleInfo[id][eVehiclePaintjob]);
	    }

	    for (new i = 0; i < 14; i ++)
	    {
	        if (VehicleInfo[id][eVehicleMods][i] > 0)
	        {
	            AddVehicleComponent(id, VehicleInfo[id][eVehicleMods][i]);
	        }
	    }
	}
}

GetVehicleRelativePos(vehicleid, &Float:x, &Float:y, &Float:z, Float:xoff= 0.0, Float:yoff= 0.0, Float:zoff= 0.0)
{
    new Float:rot;
    GetVehicleZAngle(vehicleid, rot);
    rot = 360 - rot;
    GetVehiclePos(vehicleid, x, y, z);
    x = floatsin(rot, degrees) * yoff + floatcos(rot, degrees) * xoff + x;
    y = floatcos(rot, degrees) * yoff - floatsin(rot, degrees) * xoff + y;
    z = zoff + z;

    return 1;
}

GetVehicleDriver(vehicleid)
{
    foreach(new i : Player)
    {
        if(!IsPlayerConnected(i) || GetPlayerState(i) != PLAYER_STATE_DRIVER) continue;

        if(GetPlayerVehicleID(i) == vehicleid)
            return i;
   }
    return -1;
}

encode_doors(bonnet, boot, driver_door, passenger_door, behind_driver_door, behind_passenger_door)
{
    #pragma unused behind_driver_door
    #pragma unused behind_passenger_door

    return bonnet | (boot << 8) | (driver_door << 16) | (passenger_door << 24);
}

this::OnCoolDown(vehicleid)
{
    VehicleInfo[vehicleid][vCooldown] = false;
}

stock CreateVehicleMenu(playerid)
{
	Player_Vehicles[playerid][0] = CreatePlayerTextDraw(playerid, 79.934127, 96.666671, "");
	PlayerTextDrawLetterSize(playerid, Player_Vehicles[playerid][0], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, Player_Vehicles[playerid][0], 121.000000, 120.000000);
	PlayerTextDrawAlignment(playerid, Player_Vehicles[playerid][0], 1);
	PlayerTextDrawColor(playerid, Player_Vehicles[playerid][0], -1);
	PlayerTextDrawSetShadow(playerid, Player_Vehicles[playerid][0], 0);
	PlayerTextDrawSetOutline(playerid, Player_Vehicles[playerid][0], 0);
	PlayerTextDrawBackgroundColor(playerid, Player_Vehicles[playerid][0], 8873060);
	PlayerTextDrawFont(playerid, Player_Vehicles[playerid][0], 5);
	PlayerTextDrawSetProportional(playerid, Player_Vehicles[playerid][0], 0);
	PlayerTextDrawSetShadow(playerid, Player_Vehicles[playerid][0], 0);
	PlayerTextDrawSetSelectable(playerid, Player_Vehicles[playerid][0], true);
	PlayerTextDrawSetPreviewModel(playerid, Player_Vehicles[playerid][0], 562);
	PlayerTextDrawSetPreviewRot(playerid, Player_Vehicles[playerid][0], -15.000000, 0.000000, -45.000000, 0.899999);
	PlayerTextDrawSetPreviewVehCol(playerid, Player_Vehicles[playerid][0], 1, 1);

	Player_Vehicles[playerid][1] = CreatePlayerTextDraw(playerid, 200.812606, 96.666694, "");
	PlayerTextDrawLetterSize(playerid, Player_Vehicles[playerid][1], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, Player_Vehicles[playerid][1], 121.000000, 120.000000);
	PlayerTextDrawAlignment(playerid, Player_Vehicles[playerid][1], 1);
	PlayerTextDrawColor(playerid, Player_Vehicles[playerid][1], -1);
	PlayerTextDrawSetShadow(playerid, Player_Vehicles[playerid][1], 0);
	PlayerTextDrawSetOutline(playerid, Player_Vehicles[playerid][1], 0);
	PlayerTextDrawBackgroundColor(playerid, Player_Vehicles[playerid][1], 8873060);
	PlayerTextDrawFont(playerid, Player_Vehicles[playerid][1], 5);
	PlayerTextDrawSetProportional(playerid, Player_Vehicles[playerid][1], 0);
	PlayerTextDrawSetShadow(playerid, Player_Vehicles[playerid][1], 0);
	PlayerTextDrawSetSelectable(playerid, Player_Vehicles[playerid][1], true);
	PlayerTextDrawSetPreviewModel(playerid, Player_Vehicles[playerid][1], 562);
	PlayerTextDrawSetPreviewRot(playerid, Player_Vehicles[playerid][1], -15.000000, 0.000000, -45.000000, 0.899999);
	PlayerTextDrawSetPreviewVehCol(playerid, Player_Vehicles[playerid][1], 1, 1);

	Player_Vehicles[playerid][2] = CreatePlayerTextDraw(playerid, 321.691406, 96.666664, "");
	PlayerTextDrawLetterSize(playerid, Player_Vehicles[playerid][2], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, Player_Vehicles[playerid][2], 121.000000, 120.000000);
	PlayerTextDrawAlignment(playerid, Player_Vehicles[playerid][2], 1);
	PlayerTextDrawColor(playerid, Player_Vehicles[playerid][2], -1);
	PlayerTextDrawSetShadow(playerid, Player_Vehicles[playerid][2], 0);
	PlayerTextDrawSetOutline(playerid, Player_Vehicles[playerid][2], 0);
	PlayerTextDrawBackgroundColor(playerid, Player_Vehicles[playerid][2], 8873060);
	PlayerTextDrawFont(playerid, Player_Vehicles[playerid][2], 5);
	PlayerTextDrawSetProportional(playerid, Player_Vehicles[playerid][2], 0);
	PlayerTextDrawSetShadow(playerid, Player_Vehicles[playerid][2], 0);
	PlayerTextDrawSetSelectable(playerid, Player_Vehicles[playerid][2], true);
	PlayerTextDrawSetPreviewModel(playerid, Player_Vehicles[playerid][2], 562);
	PlayerTextDrawSetPreviewRot(playerid, Player_Vehicles[playerid][2], -15.000000, 0.000000, -45.000000, 0.899999);
	PlayerTextDrawSetPreviewVehCol(playerid, Player_Vehicles[playerid][2], 1, 1);


	Player_Vehicles[playerid][3] = CreatePlayerTextDraw(playerid, 79.934127, 216.833267, "");
	PlayerTextDrawLetterSize(playerid, Player_Vehicles[playerid][3], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, Player_Vehicles[playerid][3], 121.000000, 120.000000);
	PlayerTextDrawAlignment(playerid, Player_Vehicles[playerid][3], 1);
	PlayerTextDrawColor(playerid, Player_Vehicles[playerid][3], -1);
	PlayerTextDrawSetShadow(playerid, Player_Vehicles[playerid][3], 0);
	PlayerTextDrawSetOutline(playerid, Player_Vehicles[playerid][3], 0);
	PlayerTextDrawBackgroundColor(playerid, Player_Vehicles[playerid][3], 8873060);
	PlayerTextDrawFont(playerid, Player_Vehicles[playerid][3], 5);
	PlayerTextDrawSetProportional(playerid, Player_Vehicles[playerid][3], 0);
	PlayerTextDrawSetShadow(playerid, Player_Vehicles[playerid][3], 0);
	PlayerTextDrawSetSelectable(playerid, Player_Vehicles[playerid][3], true);
	PlayerTextDrawSetPreviewModel(playerid, Player_Vehicles[playerid][3], 562);
	PlayerTextDrawSetPreviewRot(playerid, Player_Vehicles[playerid][3], -15.000000, 0.000000, -45.000000, 0.899999);
	PlayerTextDrawSetPreviewVehCol(playerid, Player_Vehicles[playerid][3], 1, 1);

	Player_Vehicles[playerid][4] = CreatePlayerTextDraw(playerid, 200.812576, 216.833282, "");
	PlayerTextDrawLetterSize(playerid, Player_Vehicles[playerid][4], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, Player_Vehicles[playerid][4], 121.000000, 120.000000);
	PlayerTextDrawAlignment(playerid, Player_Vehicles[playerid][4], 1);
	PlayerTextDrawColor(playerid, Player_Vehicles[playerid][4], -1);
	PlayerTextDrawSetShadow(playerid, Player_Vehicles[playerid][4], 0);
	PlayerTextDrawSetOutline(playerid, Player_Vehicles[playerid][4], 0);
	PlayerTextDrawBackgroundColor(playerid, Player_Vehicles[playerid][4], 8873060);
	PlayerTextDrawFont(playerid, Player_Vehicles[playerid][4], 5);
	PlayerTextDrawSetProportional(playerid, Player_Vehicles[playerid][4], 0);
	PlayerTextDrawSetShadow(playerid, Player_Vehicles[playerid][4], 0);
	PlayerTextDrawSetSelectable(playerid, Player_Vehicles[playerid][4], true);
	PlayerTextDrawSetPreviewModel(playerid, Player_Vehicles[playerid][4], 562);
	PlayerTextDrawSetPreviewRot(playerid, Player_Vehicles[playerid][4], -15.000000, 0.000000, -45.000000, 0.899999);
	PlayerTextDrawSetPreviewVehCol(playerid, Player_Vehicles[playerid][4], 1, 1);

	Player_Vehicles[playerid][5] = CreatePlayerTextDraw(playerid, 321.690917, 216.833297, "");
	PlayerTextDrawLetterSize(playerid, Player_Vehicles[playerid][5], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, Player_Vehicles[playerid][5], 121.000000, 120.000000);
	PlayerTextDrawAlignment(playerid, Player_Vehicles[playerid][5], 1);
	PlayerTextDrawColor(playerid, Player_Vehicles[playerid][5], -1);
	PlayerTextDrawSetShadow(playerid, Player_Vehicles[playerid][5], 0);
	PlayerTextDrawSetOutline(playerid, Player_Vehicles[playerid][5], 0);
	PlayerTextDrawBackgroundColor(playerid, Player_Vehicles[playerid][5], 8873060);
	PlayerTextDrawFont(playerid, Player_Vehicles[playerid][5], 5);
	PlayerTextDrawSetProportional(playerid, Player_Vehicles[playerid][5], 0);
	PlayerTextDrawSetShadow(playerid, Player_Vehicles[playerid][5], 0);
	PlayerTextDrawSetSelectable(playerid, Player_Vehicles[playerid][5], true);
	PlayerTextDrawSetPreviewModel(playerid, Player_Vehicles[playerid][5], 562);
	PlayerTextDrawSetPreviewRot(playerid, Player_Vehicles[playerid][5], -15.000000, 0.000000, -45.000000, 0.899999);
	PlayerTextDrawSetPreviewVehCol(playerid, Player_Vehicles[playerid][5], 1, 1);

	Player_Vehicles_Name[playerid][0] = CreatePlayerTextDraw(playerid, 140.541748, 195.833267, "TDEditor");
	PlayerTextDrawLetterSize(playerid, Player_Vehicles_Name[playerid][0], 0.459502, 2.078332);
	PlayerTextDrawTextSize(playerid, Player_Vehicles_Name[playerid][0], 0.000000, 117.000000);
	PlayerTextDrawAlignment(playerid, Player_Vehicles_Name[playerid][0], 2);
	PlayerTextDrawColor(playerid, Player_Vehicles_Name[playerid][0], -1);
	PlayerTextDrawUseBox(playerid, Player_Vehicles_Name[playerid][0], 1);
	PlayerTextDrawBoxColor(playerid, Player_Vehicles_Name[playerid][0], 255);
	PlayerTextDrawSetShadow(playerid, Player_Vehicles_Name[playerid][0], 0);
	PlayerTextDrawSetOutline(playerid, Player_Vehicles_Name[playerid][0], 0);
	PlayerTextDrawBackgroundColor(playerid, Player_Vehicles_Name[playerid][0], 255);
	PlayerTextDrawFont(playerid, Player_Vehicles_Name[playerid][0], 3);
	PlayerTextDrawSetProportional(playerid, Player_Vehicles_Name[playerid][0], 1);
	PlayerTextDrawSetShadow(playerid, Player_Vehicles_Name[playerid][0], 0);

	Player_Vehicles_Name[playerid][1] = CreatePlayerTextDraw(playerid, 260.951782, 195.833251, "TDEditor");
	PlayerTextDrawLetterSize(playerid, Player_Vehicles_Name[playerid][1], 0.459502, 2.078332);
	PlayerTextDrawTextSize(playerid, Player_Vehicles_Name[playerid][1], 0.000000, 117.000000);
	PlayerTextDrawAlignment(playerid, Player_Vehicles_Name[playerid][1], 2);
	PlayerTextDrawColor(playerid, Player_Vehicles_Name[playerid][1], -1);
	PlayerTextDrawUseBox(playerid, Player_Vehicles_Name[playerid][1], 1);
	PlayerTextDrawBoxColor(playerid, Player_Vehicles_Name[playerid][1], 255);
	PlayerTextDrawSetShadow(playerid, Player_Vehicles_Name[playerid][1], 0);
	PlayerTextDrawSetOutline(playerid, Player_Vehicles_Name[playerid][1], 0);
	PlayerTextDrawBackgroundColor(playerid, Player_Vehicles_Name[playerid][1], 255);
	PlayerTextDrawFont(playerid, Player_Vehicles_Name[playerid][1], 3);
	PlayerTextDrawSetProportional(playerid, Player_Vehicles_Name[playerid][1], 1);
	PlayerTextDrawSetShadow(playerid, Player_Vehicles_Name[playerid][1], 0);

	Player_Vehicles_Name[playerid][2] = CreatePlayerTextDraw(playerid, 381.830444, 195.833282, "TDEditor");
	PlayerTextDrawLetterSize(playerid, Player_Vehicles_Name[playerid][2], 0.459502, 2.078332);
	PlayerTextDrawTextSize(playerid, Player_Vehicles_Name[playerid][2], 0.000000, 118.000000);
	PlayerTextDrawAlignment(playerid, Player_Vehicles_Name[playerid][2], 2);
	PlayerTextDrawColor(playerid, Player_Vehicles_Name[playerid][2], -1);
	PlayerTextDrawUseBox(playerid, Player_Vehicles_Name[playerid][2], 1);
	PlayerTextDrawBoxColor(playerid, Player_Vehicles_Name[playerid][2], 255);
	PlayerTextDrawSetShadow(playerid, Player_Vehicles_Name[playerid][2], 0);
	PlayerTextDrawSetOutline(playerid, Player_Vehicles_Name[playerid][2], 0);
	PlayerTextDrawBackgroundColor(playerid, Player_Vehicles_Name[playerid][2], 255);
	PlayerTextDrawFont(playerid, Player_Vehicles_Name[playerid][2], 3);
	PlayerTextDrawSetProportional(playerid, Player_Vehicles_Name[playerid][2], 1);
	PlayerTextDrawSetShadow(playerid, Player_Vehicles_Name[playerid][2], 0);

	Player_Vehicles_Name[playerid][3] = CreatePlayerTextDraw(playerid, 140.073226, 316.583343, "TDEditor");
	PlayerTextDrawLetterSize(playerid, Player_Vehicles_Name[playerid][3], 0.459502, 2.078332);
	PlayerTextDrawTextSize(playerid, Player_Vehicles_Name[playerid][3], 0.000000, 118.000000);
	PlayerTextDrawAlignment(playerid, Player_Vehicles_Name[playerid][3], 2);
	PlayerTextDrawColor(playerid, Player_Vehicles_Name[playerid][3], -1);
	PlayerTextDrawUseBox(playerid, Player_Vehicles_Name[playerid][3], 1);
	PlayerTextDrawBoxColor(playerid, Player_Vehicles_Name[playerid][3], 255);
	PlayerTextDrawSetShadow(playerid, Player_Vehicles_Name[playerid][3], 0);
	PlayerTextDrawSetOutline(playerid, Player_Vehicles_Name[playerid][3], 0);
	PlayerTextDrawBackgroundColor(playerid, Player_Vehicles_Name[playerid][3], 255);
	PlayerTextDrawFont(playerid, Player_Vehicles_Name[playerid][3], 3);
	PlayerTextDrawSetProportional(playerid, Player_Vehicles_Name[playerid][3], 1);
	PlayerTextDrawSetShadow(playerid, Player_Vehicles_Name[playerid][3], 0);

	Player_Vehicles_Name[playerid][4] = CreatePlayerTextDraw(playerid, 260.951507, 316.583251, "TDEditor");
	PlayerTextDrawLetterSize(playerid, Player_Vehicles_Name[playerid][4], 0.459502, 2.078332);
	PlayerTextDrawTextSize(playerid, Player_Vehicles_Name[playerid][4], 0.000000, 118.000000);
	PlayerTextDrawAlignment(playerid, Player_Vehicles_Name[playerid][4], 2);
	PlayerTextDrawColor(playerid, Player_Vehicles_Name[playerid][4], -1);
	PlayerTextDrawUseBox(playerid, Player_Vehicles_Name[playerid][4], 1);
	PlayerTextDrawBoxColor(playerid, Player_Vehicles_Name[playerid][4], 255);
	PlayerTextDrawSetShadow(playerid, Player_Vehicles_Name[playerid][4], 0);
	PlayerTextDrawSetOutline(playerid, Player_Vehicles_Name[playerid][4], 0);
	PlayerTextDrawBackgroundColor(playerid, Player_Vehicles_Name[playerid][4], 255);
	PlayerTextDrawFont(playerid, Player_Vehicles_Name[playerid][4], 3);
	PlayerTextDrawSetProportional(playerid, Player_Vehicles_Name[playerid][4], 1);
	PlayerTextDrawSetShadow(playerid, Player_Vehicles_Name[playerid][4], 0);

	Player_Vehicles_Name[playerid][5] = CreatePlayerTextDraw(playerid, 382.298797, 316.583282, "TDEditor");
	PlayerTextDrawLetterSize(playerid, Player_Vehicles_Name[playerid][5], 0.459502, 2.078332);
	PlayerTextDrawTextSize(playerid, Player_Vehicles_Name[playerid][5], 0.000000, 118.000000);
	PlayerTextDrawAlignment(playerid, Player_Vehicles_Name[playerid][5], 2);
	PlayerTextDrawColor(playerid, Player_Vehicles_Name[playerid][5], -1);
	PlayerTextDrawUseBox(playerid, Player_Vehicles_Name[playerid][5], 1);
	PlayerTextDrawBoxColor(playerid, Player_Vehicles_Name[playerid][5], 255);
	PlayerTextDrawSetShadow(playerid, Player_Vehicles_Name[playerid][5], 0);
	PlayerTextDrawSetOutline(playerid, Player_Vehicles_Name[playerid][5], 0);
	PlayerTextDrawBackgroundColor(playerid, Player_Vehicles_Name[playerid][5], 255);
	PlayerTextDrawFont(playerid, Player_Vehicles_Name[playerid][5], 3);
	PlayerTextDrawSetProportional(playerid, Player_Vehicles_Name[playerid][5], 1);
	PlayerTextDrawSetShadow(playerid, Player_Vehicles_Name[playerid][5], 0);
	
	Player_Vehicles_Arrow[playerid][0] = CreatePlayerTextDraw(playerid, 192.401168, 188.833297/*188.249984*/, "LD_BEAT:RIGHT");
	PlayerTextDrawLetterSize(playerid, Player_Vehicles_Arrow[playerid][0], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, Player_Vehicles_Arrow[playerid][0], 44.000000, 45.000000);
	PlayerTextDrawAlignment(playerid, Player_Vehicles_Arrow[playerid][0], 1);
	PlayerTextDrawColor(playerid, Player_Vehicles_Arrow[playerid][0], -1);
	PlayerTextDrawSetShadow(playerid, Player_Vehicles_Arrow[playerid][0], 0);
	PlayerTextDrawSetOutline(playerid, Player_Vehicles_Arrow[playerid][0], 0);
	PlayerTextDrawBackgroundColor(playerid, Player_Vehicles_Arrow[playerid][0], 255);
	PlayerTextDrawFont(playerid, Player_Vehicles_Arrow[playerid][0], 4);
	PlayerTextDrawSetProportional(playerid, Player_Vehicles_Arrow[playerid][0], 0);
	PlayerTextDrawSetShadow(playerid, Player_Vehicles_Arrow[playerid][0], 0);

	Player_Vehicles_Arrow[playerid][1] = CreatePlayerTextDraw(playerid, 310.000244, 188.833297/*188.249984*/, "LD_BEAT:RIGHT");
	PlayerTextDrawLetterSize(playerid, Player_Vehicles_Arrow[playerid][1], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, Player_Vehicles_Arrow[playerid][1], 44.000000, 45.000000);
	PlayerTextDrawAlignment(playerid, Player_Vehicles_Arrow[playerid][1], 1);
	PlayerTextDrawColor(playerid, Player_Vehicles_Arrow[playerid][1], -1);
	PlayerTextDrawSetShadow(playerid, Player_Vehicles_Arrow[playerid][1], 0);
	PlayerTextDrawSetOutline(playerid, Player_Vehicles_Arrow[playerid][1], 0);
	PlayerTextDrawBackgroundColor(playerid, Player_Vehicles_Arrow[playerid][1], 255);
	PlayerTextDrawFont(playerid, Player_Vehicles_Arrow[playerid][1], 4);
	PlayerTextDrawSetProportional(playerid, Player_Vehicles_Arrow[playerid][1], 0);
	PlayerTextDrawSetShadow(playerid, Player_Vehicles_Arrow[playerid][1], 0);

	Player_Vehicles_Arrow[playerid][2] = CreatePlayerTextDraw(playerid, 432.752929, 188.833297/*188.249984*/, "LD_BEAT:RIGHT");
	PlayerTextDrawLetterSize(playerid, Player_Vehicles_Arrow[playerid][2], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, Player_Vehicles_Arrow[playerid][2], 44.000000, 45.000000);
	PlayerTextDrawAlignment(playerid, Player_Vehicles_Arrow[playerid][2], 1);
	PlayerTextDrawColor(playerid, Player_Vehicles_Arrow[playerid][2], -1);
	PlayerTextDrawSetShadow(playerid, Player_Vehicles_Arrow[playerid][2], 0);
	PlayerTextDrawSetOutline(playerid, Player_Vehicles_Arrow[playerid][2], 0);
	PlayerTextDrawBackgroundColor(playerid, Player_Vehicles_Arrow[playerid][2], 255);
	PlayerTextDrawFont(playerid, Player_Vehicles_Arrow[playerid][2], 4);
	PlayerTextDrawSetProportional(playerid, Player_Vehicles_Arrow[playerid][2], 0);
	PlayerTextDrawSetShadow(playerid, Player_Vehicles_Arrow[playerid][2], 0);

	Player_Static_Arrow[playerid] = CreatePlayerTextDraw(playerid, 47.606147, 188.833297, "LD_BEAT:LEFT");
	PlayerTextDrawLetterSize(playerid, Player_Static_Arrow[playerid], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, Player_Static_Arrow[playerid], 44.000000, 45.000000);
	PlayerTextDrawAlignment(playerid, Player_Static_Arrow[playerid], 1);
	PlayerTextDrawColor(playerid, Player_Static_Arrow[playerid], -1);
	PlayerTextDrawSetShadow(playerid, Player_Static_Arrow[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Player_Static_Arrow[playerid], 0);
	PlayerTextDrawBackgroundColor(playerid, Player_Static_Arrow[playerid], 255);
	PlayerTextDrawFont(playerid, Player_Static_Arrow[playerid], 4);
	PlayerTextDrawSetProportional(playerid, Player_Static_Arrow[playerid], 0);
	PlayerTextDrawSetShadow(playerid, Player_Static_Arrow[playerid], 0);

	/*
		PlayerTextDrawSetSelectable(playerid, Player_Static_Arrow[playerid], true);
		PlayerTextDrawSetSelectable(playerid, Player_Vehicles_Arrow[playerid][0], true);
		PlayerTextDrawSetSelectable(playerid, Player_Vehicles_Arrow[playerid][1], true);
		PlayerTextDrawSetSelectable(playerid, Player_Vehicles_Arrow[playerid][2], true);
	*/
}

/*ShowDealership(playerid, bool:show, extra_id = 0, bool:category = false)
{
	if(show)
	{
	    if(!category)
	    {
			new itemat = GetPVarInt(playerid, "carmenu_page") * 6;
			ShowDealership(playerid, false);
	        new x = 0, str[64];

	        SelectTextDraw(playerid, COLOR_DARKGREEN);
			PlayerTextDrawSetSelectable(playerid, Player_Static_Arrow[playerid], true);
			PlayerTextDrawSetSelectable(playerid, Player_Vehicles_Arrow[playerid][2], true);
		    PlayerTextDrawShow(playerid, Player_Static_Arrow[playerid]);
		    PlayerTextDrawShow(playerid, Player_Vehicles_Arrow[playerid][2]);
			while( x != 6 && itemat < sizeof(g_aDealershipCategory))
			{
			    format(str, 64, "%s", g_aDealershipCategory[x+itemat][dealerName]);
				PlayerTextDrawSetString(playerid, Player_Vehicles_Name[playerid][x], str);
				PlayerTextDrawSetPreviewModel(playerid, Player_Vehicles[playerid][x], g_aDealershipCategory[x+itemat][dealerModel]);
				PlayerTextDrawShow(playerid, Player_Vehicles[playerid][x]);
				PlayerTextDrawShow(playerid, Player_Vehicles_Name[playerid][x]);
				x++;
			}
		}
		else
		{
		    ShowDealership(playerid, false, extra_id);
	        SelectTextDraw(playerid, COLOR_DARKGREEN);
			PlayerTextDrawSetSelectable(playerid, Player_Static_Arrow[playerid], true);
			PlayerTextDrawSetSelectable(playerid, Player_Vehicles_Arrow[playerid][2], true);
		    PlayerTextDrawShow(playerid, Player_Static_Arrow[playerid]);
		    PlayerTextDrawShow(playerid, Player_Vehicles_Arrow[playerid][2]);
		    new itemat = GetPVarInt(playerid, "carmenu_page") * 6;
		    new x = 0, str[64+1];
			while(x != 6 && itemat < sizeof(g_aDealershipData))
			{
			    format(str, 64, "%s~n~", g_aDealershipData[x+itemat][eDealershipModel], g_aDealershipData[x+itemat][eDealershipPrice]);
				PlayerTextDrawSetString(playerid, Player_Vehicles_Name[playerid][x], str);
				PlayerTextDrawSetPreviewModel(playerid, Player_Vehicles[playerid][x], g_aDealershipData[x+itemat][eDealershipModelID]);
				PlayerTextDrawShow(playerid, Player_Vehicles[playerid][x]);
				PlayerTextDrawShow(playerid, Player_Vehicles_Name[playerid][x]);
				x++;
			}
		}
	}
	else
	{
	    for(new i = 0; i < 6; i++)
	    {
	        PlayerTextDrawHide(playerid, Player_Vehicles[playerid][i]);
	        PlayerTextDrawHide(playerid, Player_Vehicles_Name[playerid][i]);
	    }
	    PlayerTextDrawHide(playerid, Player_Static_Arrow[playerid]);
	    PlayerTextDrawHide(playerid, Player_Vehicles_Arrow[playerid][2]);
	}
}*/


GetNextDealershipCar(index)
{
	index++;

	if (index >= sizeof(g_aDealershipData)) {
	    index = 0;
	}

	for (new i = index; i < sizeof(g_aDealershipData); i ++)
	{
		return i;
	}
	return GetFirstDealershipCar();
}

GetPreviousDealershipCar(index)
{
	if (index - 1 < 0) {
	    index = sizeof(g_aDealershipData);
	}

	for (new i = index; --i >= 0; )
	{
		return i;
	}
	return GetLastDealershipCar();
}

GetFirstDealershipCar()
{
    for (new i = 0; i < sizeof(g_aDealershipData); i ++)
	{
		return i;
	}
	return INVALID_ID;
}

GetLastDealershipCar()
{
    for (new i = sizeof(g_aDealershipData); --i >= 0; )
	{
		return i;
	}
	return INVALID_ID;
}

ShowDealershipPreviewMenu(playerid)
{
    new index = GetFirstDealershipCar();
    if (index == INVALID_ID)
	{
		return 0;
    }
    else
    {
        PlayerInfo[playerid][pDealershipPage] = 0;
        PlayerInfo[playerid][pDealershipIndex] = index;

		ShowDealershipPreview(playerid);
		UpdateDealershipPreview(playerid);

		SelectTextDraw(playerid, COLOR_DARKGREEN);
    }
	return 1;
}

ShowDealershipPreview(playerid)
{
    for(new x = 0; x < 6; x++)
    {
 		PlayerTextDrawShow(playerid, Player_Vehicles[playerid][x]);
		PlayerTextDrawShow(playerid, Player_Vehicles_Name[playerid][x]);
	}
	PlayerTextDrawSetSelectable(playerid, Player_Static_Arrow[playerid], true);
	PlayerTextDrawSetSelectable(playerid, Player_Vehicles_Arrow[playerid][2], true);
	PlayerTextDrawShow(playerid, Player_Static_Arrow[playerid]);
	PlayerTextDrawShow(playerid, Player_Vehicles_Arrow[playerid][2]);
	PlayerInfo[playerid][pViewingDealership] = true;
}

HideDealershipPreview(playerid)
{
    for(new x = 0; x < 6; x++)
    {
 		PlayerTextDrawHide(playerid, Player_Vehicles[playerid][x]);
		PlayerTextDrawHide(playerid, Player_Vehicles_Name[playerid][x]);
	}
	PlayerTextDrawSetSelectable(playerid, Player_Static_Arrow[playerid], false);
	PlayerTextDrawSetSelectable(playerid, Player_Vehicles_Arrow[playerid][2], false);
	PlayerTextDrawHide(playerid, Player_Static_Arrow[playerid]);
	PlayerTextDrawHide(playerid, Player_Vehicles_Arrow[playerid][2]);


	PlayerInfo[playerid][pDealershipIndex] = INVALID_ID;
	PlayerInfo[playerid][pDealershipPage] = INVALID_ID;
	PlayerInfo[playerid][pViewingDealership] = false;
}

UpdateDealershipPreview(playerid)
{
	new index = PlayerInfo[playerid][pDealershipIndex] * 6, string[128];
    for(new x = 0; x < 6; x++)
    {
    	PlayerTextDrawSetPreviewModel(playerid, Player_Vehicles[playerid][x], g_aDealershipData[x+index][eDealershipModelID]);
		PlayerTextDrawSetPreviewVehCol(playerid, Player_Vehicles[playerid][x], random(sizeof(VehicleColoursTableRGBA)), random(sizeof(VehicleColoursTableRGBA)));
		format(string, sizeof(string), "%s~n~$%s", g_aDealershipData[x+index][eDealershipModel], MoneyFormat(g_aDealershipData[x+index][eDealershipPrice]));
		PlayerTextDrawSetString(playerid, Player_Vehicles_Name[playerid][x], string);
		PlayerTextDrawHide(playerid, Player_Vehicles[playerid][x]);
		PlayerTextDrawHide(playerid, Player_Vehicles[playerid][x]);
		PlayerTextDrawShow(playerid, Player_Vehicles_Name[playerid][x]);
		PlayerTextDrawShow(playerid, Player_Vehicles[playerid][x]);
	}
}

IsWindowedVehicle(vehicleid)
{
	new
		model = GetVehicleModel(vehicleid);

    if (400 <= model <= 611)
    {
        static const g_WindowInfo[] = {
		    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
		    1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 0, 1, 1, 1, 1,
		    1, 0, 1, 1, 1, 1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 1, 0, 1, 1,
		    1, 0, 0, 0, 0, 0, 1, 1, 0, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1,
		    1, 0, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1,
		    1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1,
		    1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 1, 0, 1, 1, 0, 0, 0, 0,
		    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
		    1, 1, 1, 1, 0, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1, 1, 1, 1,
			1, 0, 1, 1, 0, 1, 0, 1, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 1, 1,
			1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 0, 0
		};

		return g_WindowInfo[model - 400];
	}
	return 0;
}

IsWindowOpened(vehicleid)
{
    if( VehicleInfo[vehicleid][vWindows] ||
		VehicleInfo[vehicleid][vWindowFL] ||
		VehicleInfo[vehicleid][vWindowFR] ||
		VehicleInfo[vehicleid][vWindowBL] ||
		VehicleInfo[vehicleid][vWindowBR])
	{
	    return true;
	}
	return 0;
}

stock AddHousesInteriors()
{
	//2 Room house
	CreateDynamicObject(14755, -79.76019, 1375.42126, 1079.20508,   0.00000, 0.00000, 0.00000); //Interior
	CreateDynamicObject(1498, -80.68050, 1382.76636, 1077.94690,   0.00000, 0.00000, 0.00000); //Door
	//2 Room house

	//2 Room house
	CreateDynamicObject(14756, -48.48457, 1458.49207, 1086.61377,   0.00000, 0.00000, 0.00000); //Interior
	CreateDynamicObject(1498, -47.69450, 1457.73669, 1084.60840,   0.00000, 0.00000, 90.00000); //Door
	//2 Room house

	//3 Room house
	CreateDynamicObject(14748, 41.38534, 1440.95935, 1083.41199,   0.00000, 0.00000, 0.00000); //Interior
	CreateDynamicObject(1506, 46.51220, 1438.62793, 1081.40894,   0.00000, 0.00000, 90.00000); //Door
	//3 Room house

	//3 Room house & two story
	CreateDynamicObject(14750, 11.03331, 1314.19482, 1088.33093,   0.00000, 0.00000, 0.00000); //Interior
	CreateDynamicObject(1506, 6.96000, 1304.85022, 1081.82263,   0.00000, 0.00000, 0.00000); //Door
	//3 Room house & two story

	//4 Room house & two story
	CreateDynamicObject(14754, 85.66241, 1280.42249, 1082.82739,   0.00000, 0.00000, 0.00000); //Interior
	CreateDynamicObject(1506, 82.19940, 1271.31091, 1078.86523,   0.00000, 0.00000, 0.00000); //Door
	//4 Room house & two story

	//4 Room house & two story (More expensive)
	CreateDynamicObject(14758, 155.35648, 1409.17212, 1087.30750,   0.00000, 0.00000, 0.00000); //Interior
	CreateDynamicObject(1506, 154.62061, 1409.09656, 1085.43335,   0.00000, 0.00000, 0.00000); //Door
	CreateDynamicObject(1506, 156.12061, 1409.09656, 1085.43335,   0.00000, 0.00000, 0.00000); //Door
	//4 Room house & two story (More expensive)

	//3 Room house
	CreateDynamicObject(14714, 289.94763, 1509.23218, 1079.22510,   0.00000, 0.00000, 0.00000); //Interior
	CreateDynamicObject(1498, 289.17270, 1501.17688, 1077.42126,   0.00000, 0.00000, 0.00000); //Door
	//3 Room house

	//3 Room house
	CreateDynamicObject(14700, 329.35416, 1516.43005, 1086.31531,   0.00000, 0.00000, 0.00000); //Interior
	CreateDynamicObject(1498, 328.56949, 1512.34375, 1084.81165,   0.00000, 0.00000, 0.00000); //Door
	//3 Room house

	//2 Room house
	CreateDynamicObject(14711, 382.01254, 1498.42480, 1080.69409,   0.00000, 0.00000, 0.00000); //Interior
	CreateDynamicObject(1498, 391.08289, 1505.09924, 1079.09644,   0.00000, 0.00000, 90.00000); //Door
	//2 Room house

	//3 Room house
	CreateDynamicObject(14710, 366.74869, 1381.78625, 1080.31787,   0.00000, 0.00000, 0.00000); //Interior
	CreateDynamicObject(1498, 376.35840, 1377.81616, 1078.80579,   0.00000, 0.00000, 90.00000); //Door
	//3 Room house

	//3 Room house
	CreateDynamicObject(14701, 448.67178, 1363.61853, 1083.28748,   0.00000, 0.00000, 0.00000); //Interior
	CreateDynamicObject(1498, 447.54770, 1353.26965, 1081.21570,   0.00000, 0.00000, 0.00000); //Door
	//3 Room house

	//4 Room house & 2 story
	CreateDynamicObject(14703, 506.95187, 1366.91003, 1080.07947,   0.00000, 0.00000, 0.00000); //Interior
	CreateDynamicObject(1504, 508.85950, 1353.45654, 1075.78345,   0.00000, 0.00000, 0.00000); //Door
	CreateDynamicObject(14722, 510.94690, 1363.57544, 1078.67737,   0.00000, 0.00000, 0.00000); //Stairs
	CreateDynamicObject(14724, 510.99319, 1363.60266, 1078.67590,   0.00000, 0.00000, 0.00000); //Stairs
	CreateDynamicObject(14715, 510.92340, 1363.51001, 1078.70215,   0.00000, 0.00000, 0.00000); //Stairs
	CreateDynamicObject(14723, 510.91971, 1363.70605, 1078.84021,   0.00000, 0.00000, 0.00000); //Stairs
	//4 Room house & 2 story

	//3 Room house & strip
	CreateDynamicObject(14736, 755.25836, 1419.45801, 1102.58032,   0.00000, 0.00000, 0.00000); //Interior
	CreateDynamicObject(14738, 753.20190, 1415.76831, 1104.04199,   0.00000, 0.00000, 0.00000); //Interior
	CreateDynamicObject(1504, 744.47321, 1411.75403, 1101.42236,   0.00000, 0.00000, 0.00000); //Door
	//3 Room house & strip

	//2 Room house
	CreateDynamicObject(14713, 289.97849, 1289.53406, 1079.25183,   0.00000, 0.00000, 0.00000); //Interior
	CreateDynamicObject(1498, 294.37189, 1284.51709, 1077.43616,   0.00000, 0.00000, 0.00000); //Door
	//2 Room house

	//2 Room house
	CreateDynamicObject(14718, 188.29053, 1293.25732, 1081.13208,   0.00000, 0.00000, 0.00000); //Interior
	CreateDynamicObject(1498, 190.53439, 1288.35291, 1081.13416,   0.00000, 0.00000, 0.00000); //Door
	//2 Room house

	//2 Room house
	CreateDynamicObject(14712, 287.90448, 1249.52588, 1083.25146,   0.00000, 0.00000, 0.00000); //Interior
	CreateDynamicObject(1498, 290.09601, 1241.95874, 1081.70117,   0.00000, 0.00000, 0.00000); //Door
	//2 Room house

	//2 Room house
	CreateDynamicObject(14709, 245.01108, 1155.45520, 1081.63599,   0.00000, 0.00000, 0.00000); //Interior
	//2 Room house

	//3 Room house
	CreateDynamicObject(14735, 342.67169, 1081.66528, 1082.87891,   0.00000, 0.00000, 0.00000); //Interior
	CreateDynamicObject(1506, 325.45471, 1074.26355, 1081.25549,   0.00000, 0.00000, 0.00000); //Door
	//3 Room house

	//Richman house 5 rooms & 2 bathrooms
	CreateDynamicObject(14708, 200.11450, 1119.56934, 1083.97693,   0.00000, 0.00000, 0.00000); //Interior
	//Richman house 5 rooms & 2 bathrooms

	//Richman house 5 rooms & 2 bathrooms
	CreateDynamicObject(14706, 277.86502, 1069.62952, 1085.65552,   0.00000, 0.00000, 0.00000); //Interior
	//Richman house 5 rooms & 2 bathrooms

	//Richman house 5 rooms & 2 bathrooms
	CreateDynamicObject(14707, 275.53461, 992.44232, 1087.27319,   0.00000, 0.00000, 0.00000); //Interior
	//Richman house 5 rooms & 2 bathrooms

	//2 Room house (Small)
	CreateDynamicObject(15029, 2265.87500, -1122.75220, 1049.62781,   0.00000, 0.00000, 0.00000); //Interior
	CreateDynamicObject(1535, 2260.34570, -1121.88794, 1047.87683,   0.00000, 0.00000, 90.00000); //Door
	//2 Room house (Small)

	//1 Room house (Small)
	CreateDynamicObject(15031, 2281.78003, -1121.99768, 1049.92285,   0.00000, 0.00000, 0.00000); //Interior
	CreateDynamicObject(1535, 2284.04028, -1126.90771, 1049.91650,   0.00000, 0.00000, 0.00000); //Door
	//1 Room house (Small)

	//3 Room house
	CreateDynamicObject(15055, 2374.03271, -1102.76465, 1049.87073,   0.00000, 0.00000, 0.00000); //Interior
	CreateDynamicObject(1504, 2369.77124, -1094.13245, 1048.61951,   0.00000, 0.00000, 0.00000); //Door
	//3 Room house

	//1 Room house (Very Small)
	CreateDynamicObject(15042, 2318.45508, -1230.66187, 1048.40820,   0.00000, 0.00000, 0.00000); //Interior
	CreateDynamicObject(1501, 2312.65112, -1231.38013, 1046.40540,   0.00000, 0.00000, 0.00000); //Door
	//1 Room house (Very Small)

	//2 Room house (Small)
	CreateDynamicObject(15053, 2243.98071, -1024.30042, 1048.01758,   0.00000, 0.00000, 0.00000); //Interior
	CreateDynamicObject(1535, 2243.21191, -1027.78198, 1046.76501,   0.00000, 0.00000, 0.00000); //Door
	//2 Room house (Small)

	//3 Room house
	CreateDynamicObject(15054, 2260.93286, -1251.45007, 1051.05786,   0.00000, 0.00000, 0.00000); //Interior
	CreateDynamicObject(1506, 2273.48657, -1243.43054, 1047.59131,   0.00000, 0.00000, 90.00000); //Door
	//3 Room house

	//4 Room house
	CreateDynamicObject(15041, 2158.54736, -1220.96997, 1050.11694,   0.00000, 0.00000, 0.00000); //Interior
	CreateDynamicObject(1506, 2149.11328, -1216.07935, 1048.11365,   0.00000, 0.00000, 0.00000); //Door
	//4 Room house

	//2 Room house
	CreateDynamicObject(15046, 2364.22144, -1082.74231, 1048.01733,   0.00000, 0.00000, 0.00000); //Interior
	CreateDynamicObject(1498, 2363.47827, -1075.46021, 1046.76379,   0.00000, 0.00000, 0.00000); //Door
	//2 Room house

	//4 Room house (Rich man big)
	CreateDynamicObject(15048, 2364.55444, -1179.42346, 1055.79187,   0.00000, 0.00000, 0.00000); //Interior
	CreateDynamicObject(15059, 2364.56909, -1179.41418, 1055.79187,   0.00000, 0.00000, 0.00000); //Interior
	CreateDynamicObject(1506, 2372.00317, -1184.51221, 1052.20117,   0.00000, 0.00000, 0.00000); //Door
	CreateDynamicObject(1506, 2373.50317, -1184.51221, 1052.20117,   0.00000, 0.00000, 0.00000); //Door
	//4 Room house (Rich man big)

	//Only one room (TINY for las colinas)
	CreateDynamicObject(14859, 245.20708, 321.97745, 1000.59143,   0.00000, 0.00000, 0.00000); //Interior
	//Only one room (TINY for las colinas)

	//Only one room (TINY for las colinas)
	CreateDynamicObject(14865, 269.22012, 322.22049, 998.14349,   0.00000, 0.00000, 0.00000); //Interior
	//Only one room (TINY for las colinas)

	//Only one room (TINY for las colinas)
	CreateDynamicObject(14889, 363.51450, 304.98868, 998.14722,   0.00000, 0.00000, 0.00000); //Interior
	//Only one room (TINY for las colinas)

	//Only one room (TINY for las colinas)
	CreateDynamicObject(15033, 2177.35718, -1069.85181, 1049.47449,   0.00000, 0.00000, 0.00000); //Interior
	CreateDynamicObject(1535, 2190.13110, -1074.29504, 1049.47742,   0.00000, 0.00000, 90.00000); //Door
	//Only one room (TINY for las colinas)

	//Only two rooms (TINY for las colinas)
	CreateDynamicObject(15034, 2254.38940, -1108.71704, 1049.87268,   0.00000, 0.00000, 0.00000); //Interior
	CreateDynamicObject(1535, 2254.09644, -1113.33044, 1048.11633,   0.00000, 0.00000, 0.00000); //Door
	//Only two rooms (TINY for las colinas)

	//Only two rooms (TINY for las colinas)
	CreateDynamicObject(15030, 2293.09204, -1092.09229, 1049.62341,   0.00000, 0.00000, 0.00000); //Interior
	CreateDynamicObject(2904, 2298.69800, -1093.70605, 1048.97290,   0.00000, 0.00000, 90.00000); //Door
	CreateDynamicObject(1535, 2298.64600, -1094.47375, 1047.87195,   0.00000, 0.00000, 90.00000); //Door
	//Only two rooms (TINY for las colinas)
}

Tuning_AddComponent(vehicleid, component)
{
    if(IsValidVehicle(vehicleid) <= 0) return 0;

    new cslot = GetVehicleComponentType(component);

	VehicleInfo[vehicleid][eVehicleMods][cslot] = component;

    AddVehicleComponent(vehicleid, component);
    
    SaveComponent(vehicleid, cslot);

    return 1;
}

Tuning_SetComponents(vehicleid)
{
	for(new i; i < 14; i++)
	{
	    if(GetVehicleComponentInSlot(vehicleid, i) > 0) RemoveVehicleComponent(vehicleid, VehicleInfo[vehicleid][eVehicleMods][i]);
		if(!VehicleInfo[vehicleid][eVehicleMods][i]) continue;

 		AddVehicleComponent(vehicleid, VehicleInfo[vehicleid][eVehicleMods][i]);
	}

	return 1;
}


Tuning_ExitDisplay(playerid)
{
	new n = sizeof(RandomTuningSpawn);
 	new random_spawn = random(n);
	new categoryTuning = PlayerInfo[playerid][pTuningCategoryID];
	new vehID = GetPlayerVehicleID(playerid);

	RemoveVehicleComponent(vehID, PlayerInfo[playerid][pTuningComponent]);

 	TogglePlayerControllable(playerid, true);
 	SetPlayerVirtualWorld(playerid, 0);
 	SetVehicleVirtualWorld(vehID, 0);

	switch(VehicleInfo[vehID][eVehicleModel])
	{
 		case 455, 403, 514, 515: SetVehiclePos(vehID, 340.3456, -1348.7977, 15.5257);
		default: SetVehiclePos(vehID, RandomTuningSpawn[random_spawn][0], RandomTuningSpawn[random_spawn][1], RandomTuningSpawn[random_spawn][2]);
	}

	SetVehicleZAngle(vehID, RandomTuningSpawn[random_spawn][3]);
	SaveVehicle(vehID);

	PlayerInfo[playerid][pInTuning] = 0;

	if(categoryTuning == 10)
	{
 		ChangeVehiclePaintjob(vehID, VehicleInfo[vehID][eVehiclePaintjob]);
		if(VehicleInfo[vehID][eVehiclePaintjob] == 3) ChangeVehicleColor(vehID, VehicleInfo[vehID][eVehicleColor1], VehicleInfo[vehID][eVehicleColor2]);
	}

	PlayerTextDrawHide(playerid, TDTuning_Component[playerid]);
	PlayerTextDrawHide(playerid, TDTuning_Dots[playerid]);
	PlayerTextDrawHide(playerid, TDTuning_Price[playerid]);
	PlayerTextDrawHide(playerid, TDTuning_ComponentName[playerid]);
	PlayerTextDrawHide(playerid, TDTuning_YN[playerid]);

	SetCameraBehindPlayer(playerid);
	
	Tuning_SetComponents(vehID);

	return 1;
}

Tuning_SetDisplay(playerid, validCount = -1)
{
    new categoryTuning = PlayerInfo[playerid][pTuningCategoryID];
    new vehID = GetPlayerVehicleID(playerid);
    new string[64];

	PlayerInfo[playerid][pTuningCount] = (validCount == -1) ? GetVehicleComponentCount(categoryTuning, VehicleInfo[vehID][eVehicleModel]) : validCount;
	if(validCount == -1) SetPlayerTuningCameraPos(playerid, categoryTuning);

	if(!PlayerInfo[playerid][pTuningCount])
	{
   		PlayerTextDrawSetString(playerid, TDTuning_Price[playerid], "~y~Not compatible with your car.");
		PlayerTextDrawSetString(playerid, TDTuning_ComponentName[playerid], "PRESS [~y~~k~~CONVERSATION_YES~~w~] to ~y~confirm~w~. PRESS [~y~ ~k~~CONVERSATION_NO~ ~w~] to ~y~exit~w~.");

		PlayerTextDrawShow(playerid, TDTuning_Dots[playerid]);
		PlayerTextDrawShow(playerid, TDTuning_Price[playerid]);
		PlayerTextDrawShow(playerid, TDTuning_ComponentName[playerid]);

		PlayerTextDrawHide(playerid, TDTuning_YN[playerid]);

		RemoveVehicleComponent(vehID, PlayerInfo[playerid][pTuningComponent]);
		ChangeVehiclePaintjob(vehID, VehicleInfo[vehID][eVehiclePaintjob]);
	}
	else
	{
	    new compName[32] = "Paintjob";
	    new compPrice = 2500;

     	RemoveVehicleComponent(vehID, PlayerInfo[playerid][pTuningComponent]);
		ChangeVehiclePaintjob(vehID, VehicleInfo[vehID][eVehiclePaintjob]);

   		PlayerInfo[playerid][pTuningCount] = (validCount == -1) ? 1 : validCount;
		PlayerInfo[playerid][pTuningComponent] = GetVehicleCompatibleComponent(categoryTuning, VehicleInfo[vehID][eVehicleModel], PlayerInfo[playerid][pTuningCount]);

        new compatibleComponent = PlayerInfo[playerid][pTuningComponent];

		if(categoryTuning != 10)
		{
			AddVehicleComponent(vehID, compatibleComponent);
			strmid(compName, GetComponentName(compatibleComponent), 0, 32);
			compPrice = GetComponentPrice(compatibleComponent);
		}
		else ChangeVehiclePaintjob(vehID, PlayerInfo[playerid][pTuningComponent]);

		format(string, sizeof(string), "~y~Price: ~w~$%d", compPrice);
		PlayerTextDrawSetString(playerid, TDTuning_Price[playerid], string);
		PlayerTextDrawShow(playerid, TDTuning_Price[playerid]);

		format(string, sizeof(string), "~y~Name: ~w~%s (#%d)", compName, compatibleComponent);
		PlayerTextDrawSetString(playerid, TDTuning_ComponentName[playerid], string);
		PlayerTextDrawShow(playerid, TDTuning_ComponentName[playerid]);

		PlayerTextDrawShow(playerid, TDTuning_YN[playerid]);
	}
    Tuning_SetComponents(vehID);
	return 1;
}

Tuning_CreateTD(playerid)
{
    TDTuning_Component[playerid] = CreatePlayerTextDraw(playerid, 220.000000, 320.000000, "Spoiler (~>~)~y~ Hood");
	PlayerTextDrawBackgroundColor(playerid, TDTuning_Component[playerid], 255);
	PlayerTextDrawFont(playerid, TDTuning_Component[playerid], 3);
	PlayerTextDrawLetterSize(playerid, TDTuning_Component[playerid], 0.450000, 1.799999);
	PlayerTextDrawColor(playerid, TDTuning_Component[playerid], -1);
	PlayerTextDrawSetOutline(playerid, TDTuning_Component[playerid], 1);
	PlayerTextDrawSetProportional(playerid, TDTuning_Component[playerid], 1);
	PlayerTextDrawSetSelectable(playerid, TDTuning_Component[playerid], 0);

	TDTuning_Dots[playerid] = CreatePlayerTextDraw(playerid, 220.000000, 333.000000, ".................");
	PlayerTextDrawBackgroundColor(playerid, TDTuning_Dots[playerid], 255);
	PlayerTextDrawFont(playerid, TDTuning_Dots[playerid], 3);
	PlayerTextDrawLetterSize(playerid, TDTuning_Dots[playerid], 0.670000, 1.699999);
	PlayerTextDrawColor(playerid, TDTuning_Dots[playerid], -1);
	PlayerTextDrawSetOutline(playerid, TDTuning_Dots[playerid], 1);
	PlayerTextDrawSetProportional(playerid, TDTuning_Dots[playerid], 1);
	PlayerTextDrawSetSelectable(playerid, TDTuning_Dots[playerid], 0);

	TDTuning_Price[playerid] = CreatePlayerTextDraw(playerid, 221.000000, 351.000000, "~y~Price: ~w~$0");
	PlayerTextDrawBackgroundColor(playerid, TDTuning_Price[playerid], 255);
	PlayerTextDrawFont(playerid, TDTuning_Price[playerid], 3);
	PlayerTextDrawLetterSize(playerid, TDTuning_Price[playerid], 0.390000, 1.900000);
	PlayerTextDrawColor(playerid, TDTuning_Price[playerid], -1);
	PlayerTextDrawSetOutline(playerid, TDTuning_Price[playerid], 1);
	PlayerTextDrawSetProportional(playerid, TDTuning_Price[playerid], 1);
	PlayerTextDrawSetSelectable(playerid, TDTuning_Price[playerid], 0);

	TDTuning_ComponentName[playerid] = CreatePlayerTextDraw(playerid, 221.000000, 369.000000, "~y~Name: ~w~Unknown (#0).");
	PlayerTextDrawBackgroundColor(playerid, TDTuning_ComponentName[playerid], 255);
	PlayerTextDrawFont(playerid, TDTuning_ComponentName[playerid], 3);
	PlayerTextDrawLetterSize(playerid, TDTuning_ComponentName[playerid], 0.390000, 1.900000);
	PlayerTextDrawColor(playerid, TDTuning_ComponentName[playerid], -1);
	PlayerTextDrawSetOutline(playerid, TDTuning_ComponentName[playerid], 1);
	PlayerTextDrawSetProportional(playerid, TDTuning_ComponentName[playerid], 1);
	PlayerTextDrawSetSelectable(playerid, TDTuning_ComponentName[playerid], 0);

	TDTuning_YN[playerid] = CreatePlayerTextDraw(playerid, 221.000000, 388.000000, "PRESS [~y~Y~w~] to ~y~confirm~w~. PRESS [~y~N~w~] to ~y~exit~w~.");
	PlayerTextDrawBackgroundColor(playerid, TDTuning_YN[playerid], 255);
	PlayerTextDrawFont(playerid, TDTuning_YN[playerid], 3);
	PlayerTextDrawLetterSize(playerid, TDTuning_YN[playerid], 0.390000, 1.900000);
	PlayerTextDrawColor(playerid, TDTuning_YN[playerid], -1);
	PlayerTextDrawSetOutline(playerid, TDTuning_YN[playerid], 1);
	PlayerTextDrawSetProportional(playerid, TDTuning_YN[playerid], 1);
	PlayerTextDrawSetSelectable(playerid, TDTuning_YN[playerid], 0);
}

#include "carparts.pwn"

CMD:delivercar(playerid, params[])
{
	new
		id,
		vehID = GetPlayerVehicleID(playerid)
	;
	
	if(PlayerInfo[playerid][pJob] != JOB_CARJACKER) return SendErrorMessage(playerid, "You are not a thief.");
	
	if((id = GetChopshopID(playerid)) && IsPlayerInAnyVehicle(playerid))
	{
		if(VehicleInfo[ vehID ][eVehicleOwnerDBID] == PlayerInfo[ playerid ][pDBID] && PlayerInfo[playerid][pDuplicateKey] == vehID)
			return SendErrorMessage(playerid, "This is your vehicle.");

		if(!VehicleInfo[ vehID ][eVehicleDBID])
			return SendServerMessage(playerid, "This is not a regular vehicle. (Private Vehicle)");

		if(VehicleInfo[ vehID ][eVehicleAdminSpawn])
  			return SendServerMessage(playerid, "This command can only be used for private vehicles. You are in a public static vehicle.");

		if(PlayerInfo[playerid][InMission]) return SendServerMessage(playerid, "You are in a mission.");

		if(VehicleInfo[ vehID ][eVehicleFaction] > 0)
			return SendServerMessage(playerid, "This car is too hot. Find a regular vehicle!");

		if(CheckWantedModel(id, GetVehicleModel(vehID)))
		{
			new count, time[16];
			for(new i; i < 14; i++)
			{
			    if(VehicleInfo[vehID][eVehicleMods][i] > 0)
			    {
					count++;
			    }
			}
			PlayerInfo[playerid][InMission] = CARJACKER_DELIVER;
			PlayerInfo[playerid][MissionTime] = 15 + count;
			PlayerInfo[playerid][MissionTarget][0] = vehID;
			PlayerInfo[playerid][MissionTarget][1] = id;
			
			format(time, 32, "~w~%d_~r~SECONDS_LEFT.", PlayerInfo[playerid][MissionTime]);
			ShowInfoEx(playerid, "~r~DISMANTLING_THE_CAR", time);
		}
		else return SendServerMessage(playerid, "We don't need this car.");
	}
	else return SendServerMessage(playerid, "There is no chopshop around you or you are not in a vehicle!");
	
	return true;
}

CMD:leavemission(playerid, params[])
{
	if(!PlayerInfo[playerid][InMission]) return SendErrorMessage(playerid, "You are not in any mission.");
	ShowInfo(playerid, "MISSION_FAILED", "~y~You_left_the_mission.", 4000);
	PlayerInfo[playerid][InMission] = MISSION_NONE;
	PlayerInfo[playerid][MissionTime] = 0;
	PlayerInfo[playerid][MissionTarget][0] = 0;
	PlayerInfo[playerid][MissionTarget][1] = 0;
	return true;
}

CMD:dropoff(playerid, params[])
{
	new vehID = PlayerInfo[playerid][MissionTarget][0];
	new id = PlayerInfo[playerid][MissionTarget][1];
	new Float: playerPos[3];
	GetPlayerPos(playerid, playerPos[0], playerPos[1], playerPos[2]);
	if(PlayerInfo[playerid][pJob] != JOB_CARJACKER) return SendErrorMessage(playerid, "You are not a thief.");
	if(!PlayerInfo[playerid][InMission]) return SendErrorMessage(playerid, "You are not in any mission.");
	if(PlayerInfo[playerid][InMission] != CARJACKER_DROPOFF) return SendErrorMessage(playerid, "You are not in drop off mission.");
	if(GetPlayerVehicleID(playerid) != PlayerInfo[playerid][MissionTarget][1]) return SendErrorMessage(playerid, "This is not the car we needed!");
	if(!IsPlayerInRangeOfPoint(playerid, 50.0, chopshop_data[id][chopshop_pos][0], chopshop_data[id][chopshop_pos][1], chopshop_data[id][chopshop_pos][2]))
	{
	    new Float: distance_reward = XB_GetDistanceBetweenTPoints(playerPos[0], playerPos[1], playerPos[2], chopshop_data[id][chopshop_pos][0], chopshop_data[id][chopshop_pos][1], chopshop_data[id][chopshop_pos][2]);
	    
	    if(distance_reward > 200.0) PlayerInfo[playerid][MissionReward] += 400;
	    else PlayerInfo[playerid][MissionReward] += floatround(distance_reward) * 2;
	    
	    GiveMoney(playerid, PlayerInfo[playerid][MissionReward]);
	    
	    new money[32];
	    format(money, 32, "~y~You_EARNED_$%s_FROM_THIS_MISSION.", MoneyFormat(PlayerInfo[playerid][MissionReward]));
		ShowInfo(playerid, "MISSION_FINISHED", money, 4000);
			
		GetPlayerPos(playerid, VehicleInfo[vehID][eVehicleStolenPos][0], VehicleInfo[vehID][eVehicleStolenPos][1], VehicleInfo[vehID][eVehicleStolenPos][2]);
		VehicleInfo[vehID][eVehicleStolen] = true;
		foreach(new i : Player) if(PlayerInfo[i][pDBID] == VehicleInfo[vehID][eVehicleOwnerDBID])
		{
			sendMessage(i, COLOR_RED, "Your %s has been stolen.", ReturnVehicleName(vehID));

			PlayerInfo[i][pVehicleSpawned] = false;
			PlayerInfo[i][pVehicleSpawnedID] = INVALID_VEHICLE_ID;
		}
		else
		{
			new
				chanquery[128]
			;

			mysql_format(this, chanquery, sizeof(chanquery), "UPDATE characters SET pVehicleSpawned = 0, pVehicleSpawnedID = %i WHERE char_dbid = %i", INVALID_VEHICLE_ID, VehicleInfo[vehID][eVehicleOwnerDBID]);
			mysql_pquery(this, chanquery);
		}
		SaveVehicle(vehID);
		ResetVehicleVars(vehID);
		DestroyVehicle(vehID);
		PlayerInfo[playerid][InMission] = MISSION_NONE;
		PlayerInfo[playerid][MissionTime] = 0;
		PlayerInfo[playerid][MissionTarget][0] = 0;
		PlayerInfo[playerid][MissionTarget][1] = 0;
	}
	else return SendErrorMessage(playerid, "You are not far away from chopshop enough!");
	return true;
}

CMD:repaircar(playerid, params[])
{
    new id, type, secoption;
	new vehid = GetPlayerVehicleID(playerid);
    if(PlayerInfo[playerid][pJob] != JOB_MECHANIC || PlayerInfo[playerid][pSideJob] != JOB_MECHANIC) return SendClientMessage(playerid, COLOR_WHITE, "You are not a mechanic.");
	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return SendClientMessage(playerid, COLOR_GREY, "You must be inside a Tow Truck as a driver.");
	if(GetVehicleModel(vehid) != 525) return SendClientMessage(playerid, COLOR_LIGHTRED, "You must be inside a Tow Truck.");
	if(sscanf(params,"udD(-1)",id,type,secoption))
	{
		SendUsageMessage(playerid, "/repaircar [playerid/PartOfName] [type]");
		SendClientMessage(playerid, -1, "{C0C0C0}Type 1: {FFFFFF}Bodywork");
		SendClientMessage(playerid, -1, "{C0C0C0}Type 2: {FFFFFF}Repair the car");
		SendClientMessage(playerid, -1, "{C0C0C0}Type 3: {FFFFFF}Engine Tune-up");
		SendClientMessage(playerid, -1, "{C0C0C0}Type 4: {FFFFFF}Battery Replace");
		return 1;
	}
	if(id == playerid) return SendErrorMessage(playerid, "You may not offer it to yourself.");
	if(!IsPlayerConnected(id)) return SendErrorMessage(playerid, "Invalid player.");
	if(!IsPlayerNearPlayer(playerid, id, 6.0)) return SendErrorMessage(playerid, "You are too far away from the player.");
	if(GetPlayerState(id) != PLAYER_STATE_DRIVER) return SendErrorMessage(playerid, "This player isn't in a vehicle as a driver.");
	new vehicle = GetPlayerVehicleID(id);
	if(!VehicleInfo[vehicle][eVehicleOwnerDBID]) return SendErrorMessage(playerid, "This vehicle is a government vehicle.");
	SendOffer(playerid, id, type);
	return 1;
}



SendOffer(playerid, toplayer, type)
{
	new
		string[128]
	;
	
	switch(type) // 0 bodywork, 1 car fix, 2 battery 3 engine tune up
	{
	    case 1:
	    {
	        format(string, 128, "~p~%s_HAS_SENT_YOU_THE_OFFER_FOR_FIXING_YOUR_VEHICLE~n~~y~_PRESS_~g~Y_TO_ACCEPT, PRESS_~g~N_TO_CANCEL.", ReturnName(playerid));
   			PlayerTextDrawSetString(toplayer, PlayerOffer[toplayer], string);
	        
	        format(string, 128, "~p~YOU_HAVE_SENT_%s_THE_OFFER,_PLEASE_WAITING_FOR_HIS_RESPONSE..", ReturnName(toplayer));
   			PlayerTextDrawSetString(playerid, PlayerOffer[playerid], string);
   			
	    }
	    case 2:
	    {
	    
	    }
	    case 3:
	    {
	    
	    }
	}
	SetPVarInt(toplayer, "Mechanic_ID", playerid);
	SetPVarInt(toplayer, "Mechanic_Type", type);
	return 1;
}

this::OnJobMessageSent(playerid)
{
    PlayerTextDrawHide(playerid, PlayerOffer[playerid]);
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	if(PlayerInfo[playerid][InMission])
	{
		PlayerTextDrawSetString(playerid, PlayerOffer[playerid], "~h~~p~START SPRAYING THE VEHICLE.");
		GivePlayerWeapon(playerid, 41, 99999);
	}
	return 1;
}

stock InitMDC(playerid)
{
	MDC_UI[playerid][0] = CreatePlayerTextDraw(playerid, 164.904830, 117.666671, "box");
	PlayerTextDrawLetterSize(playerid, MDC_UI[playerid][0], 0.000000, 25.789161);
	PlayerTextDrawTextSize(playerid, MDC_UI[playerid][0], 501.000000, 0.000000);
	PlayerTextDrawAlignment(playerid, MDC_UI[playerid][0], 1);
	PlayerTextDrawColor(playerid, MDC_UI[playerid][0], -1061109505);
	PlayerTextDrawUseBox(playerid, MDC_UI[playerid][0], 1);
	PlayerTextDrawBoxColor(playerid, MDC_UI[playerid][0], -1061109505);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][0], 0);
	PlayerTextDrawSetOutline(playerid, MDC_UI[playerid][0], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_UI[playerid][0], 255);
	PlayerTextDrawFont(playerid, MDC_UI[playerid][0], 1);
	PlayerTextDrawSetProportional(playerid, MDC_UI[playerid][0], 1);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][0], 0);

	MDC_UI[playerid][1] = CreatePlayerTextDraw(playerid, 166.310394, 119.416687, "box");
	PlayerTextDrawLetterSize(playerid, MDC_UI[playerid][1], 0.000000, 25.461196);
	PlayerTextDrawTextSize(playerid, MDC_UI[playerid][1], 500.000000, 0.000000);
	PlayerTextDrawAlignment(playerid, MDC_UI[playerid][1], 1);
	PlayerTextDrawColor(playerid, MDC_UI[playerid][1], -1061109505);
	PlayerTextDrawUseBox(playerid, MDC_UI[playerid][1], 1);
	PlayerTextDrawBoxColor(playerid, MDC_UI[playerid][1], -572662273);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][1], 0);
	PlayerTextDrawSetOutline(playerid, MDC_UI[playerid][1], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_UI[playerid][1], 255);
	PlayerTextDrawFont(playerid, MDC_UI[playerid][1], 1);
	PlayerTextDrawSetProportional(playerid, MDC_UI[playerid][1], 1);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][1], 0);

	MDC_UI[playerid][2] = CreatePlayerTextDraw(playerid, 167.247436, 119.999977, "box");
	PlayerTextDrawLetterSize(playerid, MDC_UI[playerid][2], 0.000000, 1.144950);
	PlayerTextDrawTextSize(playerid, MDC_UI[playerid][2], 499.000000, 0.000000);
	PlayerTextDrawAlignment(playerid, MDC_UI[playerid][2], 1);
	PlayerTextDrawColor(playerid, MDC_UI[playerid][2], -1);
	PlayerTextDrawUseBox(playerid, MDC_UI[playerid][2], 1);
	PlayerTextDrawBoxColor(playerid, MDC_UI[playerid][2], 203444479);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][2], 0);
	PlayerTextDrawSetOutline(playerid, MDC_UI[playerid][2], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_UI[playerid][2], 255);
	PlayerTextDrawFont(playerid, MDC_UI[playerid][2], 1);
	PlayerTextDrawSetProportional(playerid, MDC_UI[playerid][2], 1);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][2], 0);

	MDC_UI[playerid][3] = CreatePlayerTextDraw(playerid, 482.393859, 118.249992, "");
	PlayerTextDrawLetterSize(playerid, MDC_UI[playerid][3], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, MDC_UI[playerid][3], 18.000000, 14.000000);
	PlayerTextDrawAlignment(playerid, MDC_UI[playerid][3], 1);
	PlayerTextDrawColor(playerid, MDC_UI[playerid][3], -1);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][3], 0);
	PlayerTextDrawSetOutline(playerid, MDC_UI[playerid][3], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_UI[playerid][3], -1440603393);
	PlayerTextDrawFont(playerid, MDC_UI[playerid][3], 5);
	PlayerTextDrawSetProportional(playerid, MDC_UI[playerid][3], 0);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][3], 0);
	PlayerTextDrawSetPreviewModel(playerid, MDC_UI[playerid][3], 0);
	PlayerTextDrawSetPreviewRot(playerid, MDC_UI[playerid][3], 0.000000, 0.000000, 0.000000, -11.000000);
	PlayerTextDrawSetSelectable(playerid, MDC_UI[playerid][3], true);

	MDC_UI[playerid][4] = CreatePlayerTextDraw(playerid, 483.499908, 120.583320, "box");
	PlayerTextDrawLetterSize(playerid, MDC_UI[playerid][4], 0.000000, 1.004394);
	PlayerTextDrawTextSize(playerid, MDC_UI[playerid][4], 461.000000, 0.000000);
	PlayerTextDrawAlignment(playerid, MDC_UI[playerid][4], 1);
	PlayerTextDrawColor(playerid, MDC_UI[playerid][4], -1);
	PlayerTextDrawUseBox(playerid, MDC_UI[playerid][4], 1);
	PlayerTextDrawBoxColor(playerid, MDC_UI[playerid][4], 577162495);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][4], 0);
	PlayerTextDrawSetOutline(playerid, MDC_UI[playerid][4], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_UI[playerid][4], 255);
	PlayerTextDrawFont(playerid, MDC_UI[playerid][4], 1);
	PlayerTextDrawSetProportional(playerid, MDC_UI[playerid][4], 1);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][4], 0);

	MDC_UI[playerid][5] = CreatePlayerTextDraw(playerid, 469.912292, 117.083343, "-");
	PlayerTextDrawLetterSize(playerid, MDC_UI[playerid][5], 0.400000, 1.600000);
	PlayerTextDrawAlignment(playerid, MDC_UI[playerid][5], 1);
	PlayerTextDrawColor(playerid, MDC_UI[playerid][5], -1);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][5], 0);
	PlayerTextDrawSetOutline(playerid, MDC_UI[playerid][5], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_UI[playerid][5], 255);
	PlayerTextDrawFont(playerid, MDC_UI[playerid][5], 2);
	PlayerTextDrawSetProportional(playerid, MDC_UI[playerid][5], 1);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][5], 0);

	MDC_UI[playerid][6] = CreatePlayerTextDraw(playerid, 488.184692, 117.666679, "x");
	PlayerTextDrawLetterSize(playerid, MDC_UI[playerid][6], 0.321287, 1.331665);
	PlayerTextDrawAlignment(playerid, MDC_UI[playerid][6], 1);
	PlayerTextDrawColor(playerid, MDC_UI[playerid][6], -1);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][6], 0);
	PlayerTextDrawSetOutline(playerid, MDC_UI[playerid][6], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_UI[playerid][6], 255);
	PlayerTextDrawFont(playerid, MDC_UI[playerid][6], 1);
	PlayerTextDrawSetProportional(playerid, MDC_UI[playerid][6], 1);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][6], 0);

	MDC_UI[playerid][7] = CreatePlayerTextDraw(playerid, 168.016098, 120.000022, "hud:radar_emmetGun");
	PlayerTextDrawLetterSize(playerid, MDC_UI[playerid][7], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, MDC_UI[playerid][7], 10.000000, 10.000000);
	PlayerTextDrawAlignment(playerid, MDC_UI[playerid][7], 1);
	PlayerTextDrawColor(playerid, MDC_UI[playerid][7], -1);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][7], 0);
	PlayerTextDrawSetOutline(playerid, MDC_UI[playerid][7], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_UI[playerid][7], 255);
	PlayerTextDrawFont(playerid, MDC_UI[playerid][7], 4);
	PlayerTextDrawSetProportional(playerid, MDC_UI[playerid][7], 0);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][7], 0);

	MDC_UI[playerid][8] = CreatePlayerTextDraw(playerid, 182.240127, 119.416679, "Los_Santos_Police_Department_-_www.lspd.gov.us");
	PlayerTextDrawLetterSize(playerid, MDC_UI[playerid][8], 0.199472, 1.104166);
	PlayerTextDrawAlignment(playerid, MDC_UI[playerid][8], 1);
	PlayerTextDrawColor(playerid, MDC_UI[playerid][8], -1);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][8], 0);
	PlayerTextDrawSetOutline(playerid, MDC_UI[playerid][8], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_UI[playerid][8], 255);
	PlayerTextDrawFont(playerid, MDC_UI[playerid][8], 1);
	PlayerTextDrawSetProportional(playerid, MDC_UI[playerid][8], 1);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][8], 0);

	MDC_UI[playerid][9] = CreatePlayerTextDraw(playerid, 416.969818, 118.833358, "Offset_Test");
	PlayerTextDrawLetterSize(playerid, MDC_UI[playerid][9], 0.233206, 1.220832);
	PlayerTextDrawAlignment(playerid, MDC_UI[playerid][9], 1);
	PlayerTextDrawColor(playerid, MDC_UI[playerid][9], -1785159937);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][9], 0);
	PlayerTextDrawSetOutline(playerid, MDC_UI[playerid][9], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_UI[playerid][9], 255);
	PlayerTextDrawFont(playerid, MDC_UI[playerid][9], 1);
	PlayerTextDrawSetProportional(playerid, MDC_UI[playerid][9], 1);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][9], 0);

	MDC_UI[playerid][10] = CreatePlayerTextDraw(playerid, 166.610565, 134.000015, "Main Screen");
	PlayerTextDrawLetterSize(playerid, MDC_UI[playerid][10], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, MDC_UI[playerid][10], 59.000000, 13.000000);
	PlayerTextDrawAlignment(playerid, MDC_UI[playerid][10], 1);
	PlayerTextDrawColor(playerid, MDC_UI[playerid][10], -1);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][10], 0);
	PlayerTextDrawSetOutline(playerid, MDC_UI[playerid][10], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_UI[playerid][10], -1431655681);
	PlayerTextDrawFont(playerid, MDC_UI[playerid][10], 5);
	PlayerTextDrawSetProportional(playerid, MDC_UI[playerid][10], 0);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][10], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_UI[playerid][10], true);
	PlayerTextDrawSetPreviewModel(playerid, MDC_UI[playerid][10], 0);
	PlayerTextDrawSetPreviewRot(playerid, MDC_UI[playerid][10], 0.000000, 0.000000, 0.000000, -1.000000);

	MDC_UI[playerid][11] = CreatePlayerTextDraw(playerid, 166.610565, 149.166732, "Look-up");
	PlayerTextDrawLetterSize(playerid, MDC_UI[playerid][11], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, MDC_UI[playerid][11], 59.000000, 13.000000);
	PlayerTextDrawAlignment(playerid, MDC_UI[playerid][11], 1);
	PlayerTextDrawColor(playerid, MDC_UI[playerid][11], -1);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][11], 0);
	PlayerTextDrawSetOutline(playerid, MDC_UI[playerid][11], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_UI[playerid][11], -1431655681);
	PlayerTextDrawFont(playerid, MDC_UI[playerid][11], 5);
	PlayerTextDrawSetProportional(playerid, MDC_UI[playerid][11], 0);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][11], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_UI[playerid][11], true);
	PlayerTextDrawSetPreviewModel(playerid, MDC_UI[playerid][11], 0);
	PlayerTextDrawSetPreviewRot(playerid, MDC_UI[playerid][11], 0.000000, 0.000000, 0.000000, -1.000000);

	MDC_UI[playerid][12] = CreatePlayerTextDraw(playerid, 166.610565, 164.333404, "Emergency");
	PlayerTextDrawLetterSize(playerid, MDC_UI[playerid][12], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, MDC_UI[playerid][12], 59.000000, 13.000000);
	PlayerTextDrawAlignment(playerid, MDC_UI[playerid][12], 1);
	PlayerTextDrawColor(playerid, MDC_UI[playerid][12], -1);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][12], 0);
	PlayerTextDrawSetOutline(playerid, MDC_UI[playerid][12], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_UI[playerid][12], -1431655681);
	PlayerTextDrawFont(playerid, MDC_UI[playerid][12], 5);
	PlayerTextDrawSetProportional(playerid, MDC_UI[playerid][12], 0);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][12], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_UI[playerid][12], true);
	PlayerTextDrawSetPreviewModel(playerid, MDC_UI[playerid][12], 0);
	PlayerTextDrawSetPreviewRot(playerid, MDC_UI[playerid][12], 0.000000, 0.000000, 0.000000, -1.000000);

	MDC_UI[playerid][13] = CreatePlayerTextDraw(playerid, 166.610565, 204.583404, "Roster");
	PlayerTextDrawLetterSize(playerid, MDC_UI[playerid][13], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, MDC_UI[playerid][13], 59.000000, 13.000000);
	PlayerTextDrawAlignment(playerid, MDC_UI[playerid][13], 1);
	PlayerTextDrawColor(playerid, MDC_UI[playerid][13], -1);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][13], 0);
	PlayerTextDrawSetOutline(playerid, MDC_UI[playerid][13], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_UI[playerid][13], -1431655681);
	PlayerTextDrawFont(playerid, MDC_UI[playerid][13], 5);
	PlayerTextDrawSetProportional(playerid, MDC_UI[playerid][13], 0);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][13], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_UI[playerid][13], true);
	PlayerTextDrawSetPreviewModel(playerid, MDC_UI[playerid][13], 0);
	PlayerTextDrawSetPreviewRot(playerid, MDC_UI[playerid][13], 0.000000, 0.000000, 0.000000, -1.000000);

	MDC_UI[playerid][14] = CreatePlayerTextDraw(playerid, 166.610565, 219.750091, "Records");
	PlayerTextDrawLetterSize(playerid, MDC_UI[playerid][14], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, MDC_UI[playerid][14], 59.000000, 13.000000);
	PlayerTextDrawAlignment(playerid, MDC_UI[playerid][14], 1);
	PlayerTextDrawColor(playerid, MDC_UI[playerid][14], -1);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][14], 0);
	PlayerTextDrawSetOutline(playerid, MDC_UI[playerid][14], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_UI[playerid][14], -1431655681);
	PlayerTextDrawFont(playerid, MDC_UI[playerid][14], 5);
	PlayerTextDrawSetProportional(playerid, MDC_UI[playerid][14], 0);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][14], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_UI[playerid][14], true);
	PlayerTextDrawSetPreviewModel(playerid, MDC_UI[playerid][14], 0);
	PlayerTextDrawSetPreviewRot(playerid, MDC_UI[playerid][14], 0.000000, 0.000000, 0.000000, -1.000000);

	MDC_UI[playerid][15] = CreatePlayerTextDraw(playerid, 166.610565, 234.916732, "CCTV");
	PlayerTextDrawLetterSize(playerid, MDC_UI[playerid][15], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, MDC_UI[playerid][15], 59.000000, 13.000000);
	PlayerTextDrawAlignment(playerid, MDC_UI[playerid][15], 1);
	PlayerTextDrawColor(playerid, MDC_UI[playerid][15], -1);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][15], 0);
	PlayerTextDrawSetOutline(playerid, MDC_UI[playerid][15], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_UI[playerid][15], -1431655681);
	PlayerTextDrawFont(playerid, MDC_UI[playerid][15], 5);
	PlayerTextDrawSetProportional(playerid, MDC_UI[playerid][15], 0);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][15], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_UI[playerid][15], true);
	PlayerTextDrawSetPreviewModel(playerid, MDC_UI[playerid][15], 0);
	PlayerTextDrawSetPreviewRot(playerid, MDC_UI[playerid][15], 0.000000, 0.000000, 0.000000, -1.000000);

	MDC_UI[playerid][16] = CreatePlayerTextDraw(playerid, 196.295730, 133.416641, "Main_Screen");
	PlayerTextDrawLetterSize(playerid, MDC_UI[playerid][16], 0.178389, 1.232499);
	PlayerTextDrawAlignment(playerid, MDC_UI[playerid][16], 2);
	PlayerTextDrawColor(playerid, MDC_UI[playerid][16], 858993663);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][16], 0);
	PlayerTextDrawSetOutline(playerid, MDC_UI[playerid][16], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_UI[playerid][16], 255);
	PlayerTextDrawFont(playerid, MDC_UI[playerid][16], 2);
	PlayerTextDrawSetProportional(playerid, MDC_UI[playerid][16], 1);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][16], 0);

	MDC_UI[playerid][17] = CreatePlayerTextDraw(playerid, 196.295730, 148.583328, "Look_Up");
	PlayerTextDrawLetterSize(playerid, MDC_UI[playerid][17], 0.178389, 1.232499);
	PlayerTextDrawAlignment(playerid, MDC_UI[playerid][17], 2);
	PlayerTextDrawColor(playerid, MDC_UI[playerid][17], 858993663);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][17], 0);
	PlayerTextDrawSetOutline(playerid, MDC_UI[playerid][17], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_UI[playerid][17], 255);
	PlayerTextDrawFont(playerid, MDC_UI[playerid][17], 2);
	PlayerTextDrawSetProportional(playerid, MDC_UI[playerid][17], 1);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][17], 0);

	MDC_UI[playerid][18] = CreatePlayerTextDraw(playerid, 197.701293, 163.749984, "Emergency");
	PlayerTextDrawLetterSize(playerid, MDC_UI[playerid][18], 0.178389, 1.232499);
	PlayerTextDrawAlignment(playerid, MDC_UI[playerid][18], 2);
	PlayerTextDrawColor(playerid, MDC_UI[playerid][18], 858993663);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][18], 0);
	PlayerTextDrawSetOutline(playerid, MDC_UI[playerid][18], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_UI[playerid][18], 255);
	PlayerTextDrawFont(playerid, MDC_UI[playerid][18], 2);
	PlayerTextDrawSetProportional(playerid, MDC_UI[playerid][18], 1);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][18], 0);

	MDC_UI[playerid][19] = CreatePlayerTextDraw(playerid, 196.764251, 203.999969, "Roster");
	PlayerTextDrawLetterSize(playerid, MDC_UI[playerid][19], 0.178389, 1.232499);
	PlayerTextDrawAlignment(playerid, MDC_UI[playerid][19], 2);
	PlayerTextDrawColor(playerid, MDC_UI[playerid][19], 858993663);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][19], 0);
	PlayerTextDrawSetOutline(playerid, MDC_UI[playerid][19], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_UI[playerid][19], 255);
	PlayerTextDrawFont(playerid, MDC_UI[playerid][19], 2);
	PlayerTextDrawSetProportional(playerid, MDC_UI[playerid][19], 1);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][19], 0);

	MDC_UI[playerid][20] = CreatePlayerTextDraw(playerid, 196.295730, 219.749969, "Records_DB");
	PlayerTextDrawLetterSize(playerid, MDC_UI[playerid][20], 0.178389, 1.232499);
	PlayerTextDrawAlignment(playerid, MDC_UI[playerid][20], 2);
	PlayerTextDrawColor(playerid, MDC_UI[playerid][20], 858993663);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][20], 0);
	PlayerTextDrawSetOutline(playerid, MDC_UI[playerid][20], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_UI[playerid][20], 255);
	PlayerTextDrawFont(playerid, MDC_UI[playerid][20], 2);
	PlayerTextDrawSetProportional(playerid, MDC_UI[playerid][20], 1);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][20], 0);

	MDC_UI[playerid][21] = CreatePlayerTextDraw(playerid, 195.827209, 234.333297, "Dispatch");
	PlayerTextDrawLetterSize(playerid, MDC_UI[playerid][21], 0.178389, 1.232499);
	PlayerTextDrawAlignment(playerid, MDC_UI[playerid][21], 2);
	PlayerTextDrawColor(playerid, MDC_UI[playerid][21], 858993663);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][21], 0);
	PlayerTextDrawSetOutline(playerid, MDC_UI[playerid][21], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_UI[playerid][21], 255);
	PlayerTextDrawFont(playerid, MDC_UI[playerid][21], 2);
	PlayerTextDrawSetProportional(playerid, MDC_UI[playerid][21], 1);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][21], 0);

	MDC_UI[playerid][22] = CreatePlayerTextDraw(playerid, 229.560760, 136.333328, "box");
	PlayerTextDrawLetterSize(playerid, MDC_UI[playerid][22], 0.000000, 23.212295);
	PlayerTextDrawTextSize(playerid, MDC_UI[playerid][22], 227.000000, 0.000000);
	PlayerTextDrawAlignment(playerid, MDC_UI[playerid][22], 1);
	PlayerTextDrawColor(playerid, MDC_UI[playerid][22], -1);
	PlayerTextDrawUseBox(playerid, MDC_UI[playerid][22], 1);
	PlayerTextDrawBoxColor(playerid, MDC_UI[playerid][22], -1431655681);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][22], 0);
	PlayerTextDrawSetOutline(playerid, MDC_UI[playerid][22], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_UI[playerid][22], 255);
	PlayerTextDrawFont(playerid, MDC_UI[playerid][22], 1);
	PlayerTextDrawSetProportional(playerid, MDC_UI[playerid][22], 1);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][22], 0);

	MDC_UI[playerid][23] = CreatePlayerTextDraw(playerid, 262.656921, 141.583236, "");
	PlayerTextDrawLetterSize(playerid, MDC_UI[playerid][23], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, MDC_UI[playerid][23], 210.000000, 147.000000);
	PlayerTextDrawAlignment(playerid, MDC_UI[playerid][23], 1);
	PlayerTextDrawColor(playerid, MDC_UI[playerid][23], -1);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][23], 0);
	PlayerTextDrawSetOutline(playerid, MDC_UI[playerid][23], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_UI[playerid][23], 0);
	PlayerTextDrawFont(playerid, MDC_UI[playerid][23], 5);
	PlayerTextDrawSetProportional(playerid, MDC_UI[playerid][23], 0);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][23], 0);
	PlayerTextDrawSetPreviewModel(playerid, MDC_UI[playerid][23], 267);
	PlayerTextDrawSetPreviewRot(playerid, MDC_UI[playerid][23], 0.000000, 0.000000, 0.000000, 0.899999);

	MDC_UI[playerid][24] = CreatePlayerTextDraw(playerid, 231.903335, 203.416717, "box");
	PlayerTextDrawLetterSize(playerid, MDC_UI[playerid][24], 0.000000, 16.043922);
	PlayerTextDrawTextSize(playerid, MDC_UI[playerid][24], 499.000000, 0.000000);
	PlayerTextDrawAlignment(playerid, MDC_UI[playerid][24], 1);
	PlayerTextDrawColor(playerid, MDC_UI[playerid][24], -1);
	PlayerTextDrawUseBox(playerid, MDC_UI[playerid][24], 1);
	PlayerTextDrawBoxColor(playerid, MDC_UI[playerid][24], -572662273);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][24], 0);
	PlayerTextDrawSetOutline(playerid, MDC_UI[playerid][24], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_UI[playerid][24], 255);
	PlayerTextDrawFont(playerid, MDC_UI[playerid][24], 1);
	PlayerTextDrawSetProportional(playerid, MDC_UI[playerid][24], 1);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][24], 0);

	MDC_UI[playerid][25] = CreatePlayerTextDraw(playerid, 234.714080, 202.833404, "box");
	PlayerTextDrawLetterSize(playerid, MDC_UI[playerid][25], 0.000000, 1.426062);
	PlayerTextDrawTextSize(playerid, MDC_UI[playerid][25], 497.000000, 0.000000);
	PlayerTextDrawAlignment(playerid, MDC_UI[playerid][25], 1);
	PlayerTextDrawColor(playerid, MDC_UI[playerid][25], -2004318108);
	PlayerTextDrawUseBox(playerid, MDC_UI[playerid][25], 1);
	PlayerTextDrawBoxColor(playerid, MDC_UI[playerid][25], -2004318128);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][25], 0);
	PlayerTextDrawSetOutline(playerid, MDC_UI[playerid][25], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_UI[playerid][25], 255);
	PlayerTextDrawFont(playerid, MDC_UI[playerid][25], 1);
	PlayerTextDrawSetProportional(playerid, MDC_UI[playerid][25], 1);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][25], 0);

	MDC_UI[playerid][26] = CreatePlayerTextDraw(playerid, 363.557678, 202.833404, "Chief_Of_Police_Offset_Test");
	PlayerTextDrawLetterSize(playerid, MDC_UI[playerid][26], 0.274904, 1.314165);
	PlayerTextDrawAlignment(playerid, MDC_UI[playerid][26], 2);
	PlayerTextDrawColor(playerid, MDC_UI[playerid][26], 255);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][26], 0);
	PlayerTextDrawSetOutline(playerid, MDC_UI[playerid][26], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_UI[playerid][26], 255);
	PlayerTextDrawFont(playerid, MDC_UI[playerid][26], 1);
	PlayerTextDrawSetProportional(playerid, MDC_UI[playerid][26], 1);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][26], 0);

	MDC_UI[playerid][27] = CreatePlayerTextDraw(playerid, 242.679290, 229.083297, "Members_On_Duty~n~Active_Warrants~n~Active_Bolo's");
	PlayerTextDrawLetterSize(playerid, MDC_UI[playerid][27], 0.149340, 1.372501);
	PlayerTextDrawAlignment(playerid, MDC_UI[playerid][27], 1);
	PlayerTextDrawColor(playerid, MDC_UI[playerid][27], 255);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][27], 0);
	PlayerTextDrawSetOutline(playerid, MDC_UI[playerid][27], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_UI[playerid][27], 255);
	PlayerTextDrawFont(playerid, MDC_UI[playerid][27], 2);
	PlayerTextDrawSetProportional(playerid, MDC_UI[playerid][27], 1);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][27], 0);

	MDC_UI[playerid][28] = CreatePlayerTextDraw(playerid, 341.537658, 226.749984, "0~n~0~n~0");
	PlayerTextDrawLetterSize(playerid, MDC_UI[playerid][28], 0.180263, 1.425000);
	PlayerTextDrawAlignment(playerid, MDC_UI[playerid][28], 1);
	PlayerTextDrawColor(playerid, MDC_UI[playerid][28], -2139062017);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][28], 0);
	PlayerTextDrawSetOutline(playerid, MDC_UI[playerid][28], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_UI[playerid][28], 255);
	PlayerTextDrawFont(playerid, MDC_UI[playerid][28], 2);
	PlayerTextDrawSetProportional(playerid, MDC_UI[playerid][28], 1);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][28], 0);

	MDC_UI[playerid][29] = CreatePlayerTextDraw(playerid, 367.774688, 227.333297, "CALLS_LAST_HOUR~n~ARRESTS_LAST_HOUR~n~Fines_Last_Hour");
	PlayerTextDrawLetterSize(playerid, MDC_UI[playerid][29], 0.149340, 1.372501);
	PlayerTextDrawAlignment(playerid, MDC_UI[playerid][29], 1);
	PlayerTextDrawColor(playerid, MDC_UI[playerid][29], 255);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][29], 0);
	PlayerTextDrawSetOutline(playerid, MDC_UI[playerid][29], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_UI[playerid][29], 255);
	PlayerTextDrawFont(playerid, MDC_UI[playerid][29], 2);
	PlayerTextDrawSetProportional(playerid, MDC_UI[playerid][29], 1);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][29], 0);

	MDC_UI[playerid][30] = CreatePlayerTextDraw(playerid, 486.779418, 225.000000, "0~n~0~n~0");
	PlayerTextDrawLetterSize(playerid, MDC_UI[playerid][30], 0.180263, 1.425000);
	PlayerTextDrawAlignment(playerid, MDC_UI[playerid][30], 1);
	PlayerTextDrawColor(playerid, MDC_UI[playerid][30], -2139062017);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][30], 0);
	PlayerTextDrawSetOutline(playerid, MDC_UI[playerid][30], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_UI[playerid][30], 255);
	PlayerTextDrawFont(playerid, MDC_UI[playerid][30], 2);
	PlayerTextDrawSetProportional(playerid, MDC_UI[playerid][30], 1);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][30], 0);

	MDC_UI[playerid][31] = CreatePlayerTextDraw(playerid, 235.182983, 279.833343, "box");
	PlayerTextDrawLetterSize(playerid, MDC_UI[playerid][31], 0.000000, 1.285506);
	PlayerTextDrawTextSize(playerid, MDC_UI[playerid][31], 498.000000, 0.000000);
	PlayerTextDrawAlignment(playerid, MDC_UI[playerid][31], 1);
	PlayerTextDrawColor(playerid, MDC_UI[playerid][31], -1);
	PlayerTextDrawUseBox(playerid, MDC_UI[playerid][31], 1);
	PlayerTextDrawBoxColor(playerid, MDC_UI[playerid][31], -1440603393);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][31], 0);
	PlayerTextDrawSetOutline(playerid, MDC_UI[playerid][31], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_UI[playerid][31], 255);
	PlayerTextDrawFont(playerid, MDC_UI[playerid][31], 1);
	PlayerTextDrawSetProportional(playerid, MDC_UI[playerid][31], 1);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][31], 0);

	MDC_UI[playerid][32] = CreatePlayerTextDraw(playerid, 236.120056, 279.833343, "]_NEW_NOTIFY");
	PlayerTextDrawLetterSize(playerid, MDC_UI[playerid][32], 0.207437, 1.075000);
	PlayerTextDrawAlignment(playerid, MDC_UI[playerid][32], 1);
	PlayerTextDrawColor(playerid, MDC_UI[playerid][32], -1);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][32], 0);
	PlayerTextDrawSetOutline(playerid, MDC_UI[playerid][32], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_UI[playerid][32], 255);
	PlayerTextDrawFont(playerid, MDC_UI[playerid][32], 2);
	PlayerTextDrawSetProportional(playerid, MDC_UI[playerid][32], 1);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][32], 0);

	MDC_UI[playerid][33] = CreatePlayerTextDraw(playerid, 235.182983, 299.666687, "]_NEW_WARN");
	PlayerTextDrawLetterSize(playerid, MDC_UI[playerid][33], 0.000000, 1.285506);
	PlayerTextDrawTextSize(playerid, MDC_UI[playerid][33], 498.000000, 0.000000);
	PlayerTextDrawAlignment(playerid, MDC_UI[playerid][33], 1);
	PlayerTextDrawColor(playerid, MDC_UI[playerid][33], -1);
	PlayerTextDrawUseBox(playerid, MDC_UI[playerid][33], 1);
	PlayerTextDrawBoxColor(playerid, MDC_UI[playerid][33], 41215);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][33], 0);
	PlayerTextDrawSetOutline(playerid, MDC_UI[playerid][33], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_UI[playerid][33], 255);
	PlayerTextDrawFont(playerid, MDC_UI[playerid][33], 1);
	PlayerTextDrawSetProportional(playerid, MDC_UI[playerid][33], 1);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][33], 0);

	MDC_UI[playerid][34] = CreatePlayerTextDraw(playerid, 236.120056, 300.250122, "]_NEW_WARN");
	PlayerTextDrawLetterSize(playerid, MDC_UI[playerid][34], 0.207437, 1.075000);
	PlayerTextDrawAlignment(playerid, MDC_UI[playerid][34], 1);
	PlayerTextDrawColor(playerid, MDC_UI[playerid][34], -1);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][34], 0);
	PlayerTextDrawSetOutline(playerid, MDC_UI[playerid][34], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_UI[playerid][34], 255);
	PlayerTextDrawFont(playerid, MDC_UI[playerid][34], 2);
	PlayerTextDrawSetProportional(playerid, MDC_UI[playerid][34], 1);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][34], 0);
	
	
	
	MDC_UI[playerid][35] = CreatePlayerTextDraw(playerid, 234.546127, 142.166671, "NAME");
	PlayerTextDrawLetterSize(playerid, MDC_UI[playerid][35], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, MDC_UI[playerid][35], 34.000000, 14.000000);
	PlayerTextDrawAlignment(playerid, MDC_UI[playerid][35], 1);
	PlayerTextDrawColor(playerid, MDC_UI[playerid][35], -1);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][35], 0);
	PlayerTextDrawSetOutline(playerid, MDC_UI[playerid][35], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_UI[playerid][35], -1431655681);
	PlayerTextDrawFont(playerid, MDC_UI[playerid][35], 5);
	PlayerTextDrawSetProportional(playerid, MDC_UI[playerid][35], 0);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][35], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_UI[playerid][35], true);
	PlayerTextDrawSetPreviewModel(playerid, MDC_UI[playerid][35], 0);
	PlayerTextDrawSetPreviewRot(playerid, MDC_UI[playerid][35], 0.000000, 0.000000, 0.000000, -1.000000);

	MDC_UI[playerid][36] = CreatePlayerTextDraw(playerid, 271.559417, 142.166687, "PLATE");
	PlayerTextDrawLetterSize(playerid, MDC_UI[playerid][36], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, MDC_UI[playerid][36], 33.000000, 14.000000);
	PlayerTextDrawAlignment(playerid, MDC_UI[playerid][36], 1);
	PlayerTextDrawColor(playerid, MDC_UI[playerid][36], -1);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][36], 0);
	PlayerTextDrawSetOutline(playerid, MDC_UI[playerid][36], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_UI[playerid][36], -1431655681);
	PlayerTextDrawFont(playerid, MDC_UI[playerid][36], 5);
	PlayerTextDrawSetProportional(playerid, MDC_UI[playerid][36], 0);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][36], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_UI[playerid][36], true);
	PlayerTextDrawSetPreviewModel(playerid, MDC_UI[playerid][36], 0);
	PlayerTextDrawSetPreviewRot(playerid, MDC_UI[playerid][36], 0.000000, 0.000000, 0.000000, -1.000000);

	MDC_UI[playerid][37] = CreatePlayerTextDraw(playerid, 310.446899, 142.166687, "INPUT");
	PlayerTextDrawLetterSize(playerid, MDC_UI[playerid][37], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, MDC_UI[playerid][37], 104.000000, 14.000000);
	PlayerTextDrawAlignment(playerid, MDC_UI[playerid][37], 1);
	PlayerTextDrawColor(playerid, MDC_UI[playerid][37], -1);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][37], 0);
	PlayerTextDrawSetOutline(playerid, MDC_UI[playerid][37], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_UI[playerid][37], -1);
	PlayerTextDrawFont(playerid, MDC_UI[playerid][37], 5);
	PlayerTextDrawSetProportional(playerid, MDC_UI[playerid][37], 0);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][37], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_UI[playerid][37], true);
	PlayerTextDrawSetPreviewModel(playerid, MDC_UI[playerid][37], 0);
	PlayerTextDrawSetPreviewRot(playerid, MDC_UI[playerid][37], 0.000000, 0.000000, 0.000000, -1.000000);

	MDC_UI[playerid][38] = CreatePlayerTextDraw(playerid, 414.458312, 142.166702, "REFRESH");
	PlayerTextDrawLetterSize(playerid, MDC_UI[playerid][38], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, MDC_UI[playerid][38], 34.000000, 13.000000);
	PlayerTextDrawAlignment(playerid, MDC_UI[playerid][38], 1);
	PlayerTextDrawColor(playerid, MDC_UI[playerid][38], -1);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][38], 0);
	PlayerTextDrawSetOutline(playerid, MDC_UI[playerid][38], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_UI[playerid][38], -1431655681);
	PlayerTextDrawFont(playerid, MDC_UI[playerid][38], 5);
	PlayerTextDrawSetProportional(playerid, MDC_UI[playerid][38], 0);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][38], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_UI[playerid][38], true);
	PlayerTextDrawSetPreviewModel(playerid, MDC_UI[playerid][38], 0);
	PlayerTextDrawSetPreviewRot(playerid, MDC_UI[playerid][38], 0.000000, 0.000000, 0.000000, -1.000000);

	MDC_UI[playerid][39] = CreatePlayerTextDraw(playerid, 240.336746, 143.333297, "NAME");
	PlayerTextDrawLetterSize(playerid, MDC_UI[playerid][39], 0.203689, 1.150832);
	PlayerTextDrawAlignment(playerid, MDC_UI[playerid][39], 1);
	PlayerTextDrawColor(playerid, MDC_UI[playerid][39], 858993663);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][39], 0);
	PlayerTextDrawSetOutline(playerid, MDC_UI[playerid][39], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_UI[playerid][39], 255);
	PlayerTextDrawFont(playerid, MDC_UI[playerid][39], 2);
	PlayerTextDrawSetProportional(playerid, MDC_UI[playerid][39], 1);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][39], 0);

	MDC_UI[playerid][40] = CreatePlayerTextDraw(playerid, 275.944305, 143.333328, "PLATE");
	PlayerTextDrawLetterSize(playerid, MDC_UI[playerid][40], 0.203689, 1.150832);
	PlayerTextDrawAlignment(playerid, MDC_UI[playerid][40], 1);
	PlayerTextDrawColor(playerid, MDC_UI[playerid][40], 858993663);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][40], 0);
	PlayerTextDrawSetOutline(playerid, MDC_UI[playerid][40], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_UI[playerid][40], 255);
	PlayerTextDrawFont(playerid, MDC_UI[playerid][40], 2);
	PlayerTextDrawSetProportional(playerid, MDC_UI[playerid][40], 1);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][40], 0);

	MDC_UI[playerid][41] = CreatePlayerTextDraw(playerid, 417.437957, 142.166656, "Refresh");
	PlayerTextDrawLetterSize(playerid, MDC_UI[playerid][41], 0.159648, 1.261663);
	PlayerTextDrawAlignment(playerid, MDC_UI[playerid][41], 1);
	PlayerTextDrawColor(playerid, MDC_UI[playerid][41], 858993663);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][41], 0);
	PlayerTextDrawSetOutline(playerid, MDC_UI[playerid][41], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_UI[playerid][41], 255);
	PlayerTextDrawFont(playerid, MDC_UI[playerid][41], 2);
	PlayerTextDrawSetProportional(playerid, MDC_UI[playerid][41], 1);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][41], 0);

	MDC_UI[playerid][42] = CreatePlayerTextDraw(playerid, 153.960479, 152.666656, "");
	PlayerTextDrawLetterSize(playerid, MDC_UI[playerid][42], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, MDC_UI[playerid][42], 234.000000, 172.000000);
	PlayerTextDrawAlignment(playerid, MDC_UI[playerid][42], 1);
	PlayerTextDrawColor(playerid, MDC_UI[playerid][42], -1);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][42], 0);
	PlayerTextDrawSetOutline(playerid, MDC_UI[playerid][42], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_UI[playerid][42], 0);
	PlayerTextDrawFont(playerid, MDC_UI[playerid][42], 5);
	PlayerTextDrawSetProportional(playerid, MDC_UI[playerid][42], 0);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][42], 0);
	PlayerTextDrawSetPreviewModel(playerid, MDC_UI[playerid][42], 286);
	PlayerTextDrawSetPreviewRot(playerid, MDC_UI[playerid][42], 0.000000, 0.000000, 20.000000, 0.899999);

	MDC_UI[playerid][43] = CreatePlayerTextDraw(playerid, 234.714492, 215.083435, "box");
	PlayerTextDrawLetterSize(playerid, MDC_UI[playerid][43], 0.000000, 13.654464);
	PlayerTextDrawTextSize(playerid, MDC_UI[playerid][43], 499.000000, 0.000000);
	PlayerTextDrawAlignment(playerid, MDC_UI[playerid][43], 1);
	PlayerTextDrawColor(playerid, MDC_UI[playerid][43], -1);
	PlayerTextDrawUseBox(playerid, MDC_UI[playerid][43], 1);
	PlayerTextDrawBoxColor(playerid, MDC_UI[playerid][43], -572662273);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][43], 0);
	PlayerTextDrawSetOutline(playerid, MDC_UI[playerid][43], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_UI[playerid][43], 255);
	PlayerTextDrawFont(playerid, MDC_UI[playerid][43], 1);
	PlayerTextDrawSetProportional(playerid, MDC_UI[playerid][43], 1);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][43], 0);

	MDC_UI[playerid][44] = CreatePlayerTextDraw(playerid, 309.677734, 156.750045, "Name:~n~Address:~n~Number:~n~Priors:~n~Licenses:");
	PlayerTextDrawLetterSize(playerid, MDC_UI[playerid][44], 0.207437, 1.226666);
	PlayerTextDrawAlignment(playerid, MDC_UI[playerid][44], 1);
	PlayerTextDrawColor(playerid, MDC_UI[playerid][44], 858993663);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][44], 0);
	PlayerTextDrawSetOutline(playerid, MDC_UI[playerid][44], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_UI[playerid][44], 255);
	PlayerTextDrawFont(playerid, MDC_UI[playerid][44], 2);
	PlayerTextDrawSetProportional(playerid, MDC_UI[playerid][44], 1);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][44], 0);

	MDC_UI[playerid][45] = CreatePlayerTextDraw(playerid, 353.970947, 156.750030, "_");
	PlayerTextDrawLetterSize(playerid, MDC_UI[playerid][45], 0.156837, 1.244166);
	PlayerTextDrawAlignment(playerid, MDC_UI[playerid][45], 1);
	PlayerTextDrawColor(playerid, MDC_UI[playerid][45], -1667457793);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][45], 0);
	PlayerTextDrawSetOutline(playerid, MDC_UI[playerid][45], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_UI[playerid][45], 255);
	PlayerTextDrawFont(playerid, MDC_UI[playerid][45], 2);
	PlayerTextDrawSetProportional(playerid, MDC_UI[playerid][45], 1);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][45], 0);

	MDC_UI[playerid][46] = CreatePlayerTextDraw(playerid, 234.714462, 217.999984, "box");
	PlayerTextDrawLetterSize(playerid, MDC_UI[playerid][46], 0.000000, 1.004393);
	PlayerTextDrawTextSize(playerid, MDC_UI[playerid][46], 498.000000, 0.000000);
	PlayerTextDrawAlignment(playerid, MDC_UI[playerid][46], 1);
	PlayerTextDrawColor(playerid, MDC_UI[playerid][46], -1);
	PlayerTextDrawUseBox(playerid, MDC_UI[playerid][46], 1);
	PlayerTextDrawBoxColor(playerid, MDC_UI[playerid][46], -56833);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][46], 0);
	PlayerTextDrawSetOutline(playerid, MDC_UI[playerid][46], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_UI[playerid][46], 255);
	PlayerTextDrawFont(playerid, MDC_UI[playerid][46], 1);
	PlayerTextDrawSetProportional(playerid, MDC_UI[playerid][46], 1);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][46], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_UI[playerid][46], true);

	MDC_UI[playerid][47] = CreatePlayerTextDraw(playerid, 236.588531, 217.416656, "]_This_Person_has_multi_addresses,_click_here_for_a_list!");
	PlayerTextDrawLetterSize(playerid, MDC_UI[playerid][47], 0.177452, 1.051667);
	PlayerTextDrawAlignment(playerid, MDC_UI[playerid][47], 1);
	PlayerTextDrawColor(playerid, MDC_UI[playerid][47], 255);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][47], 0);
	PlayerTextDrawSetOutline(playerid, MDC_UI[playerid][47], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_UI[playerid][47], 255);
	PlayerTextDrawFont(playerid, MDC_UI[playerid][47], 2);
	PlayerTextDrawSetProportional(playerid, MDC_UI[playerid][47], 1);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][47], 0);

	MDC_UI[playerid][48] = CreatePlayerTextDraw(playerid, 234.714462, 234.916656, "box");
	PlayerTextDrawLetterSize(playerid, MDC_UI[playerid][48], 0.000000, 1.004393);
	PlayerTextDrawTextSize(playerid, MDC_UI[playerid][48], 498.000000, 0.000000);
	PlayerTextDrawAlignment(playerid, MDC_UI[playerid][48], 1);
	PlayerTextDrawColor(playerid, MDC_UI[playerid][48], -1);
	PlayerTextDrawUseBox(playerid, MDC_UI[playerid][48], 1);
	PlayerTextDrawBoxColor(playerid, MDC_UI[playerid][48], -1457315073);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][48], 0);
	PlayerTextDrawSetOutline(playerid, MDC_UI[playerid][48], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_UI[playerid][48], 255);
	PlayerTextDrawFont(playerid, MDC_UI[playerid][48], 1);
	PlayerTextDrawSetProportional(playerid, MDC_UI[playerid][48], 1);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][48], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_UI[playerid][48], true);

	MDC_UI[playerid][49] = CreatePlayerTextDraw(playerid, 236.588531, 234.333312, "]_This_Person_has_multi_addresses,_click_here_for_a_list!");
	PlayerTextDrawLetterSize(playerid, MDC_UI[playerid][49], 0.177452, 1.051667);
	PlayerTextDrawAlignment(playerid, MDC_UI[playerid][49], 1);
	PlayerTextDrawColor(playerid, MDC_UI[playerid][49], -1);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][49], 0);
	PlayerTextDrawSetOutline(playerid, MDC_UI[playerid][49], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_UI[playerid][49], 255);
	PlayerTextDrawFont(playerid, MDC_UI[playerid][49], 2);
	PlayerTextDrawSetProportional(playerid, MDC_UI[playerid][49], 1);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][49], 0);

	MDC_UI[playerid][50] = CreatePlayerTextDraw(playerid, 234.714462, 251.249984, "box");
	PlayerTextDrawLetterSize(playerid, MDC_UI[playerid][50], 0.000000, 0.957541);
	PlayerTextDrawTextSize(playerid, MDC_UI[playerid][50], 498.000000, 0.000000);
	PlayerTextDrawAlignment(playerid, MDC_UI[playerid][50], 1);
	PlayerTextDrawColor(playerid, MDC_UI[playerid][50], -1);
	PlayerTextDrawUseBox(playerid, MDC_UI[playerid][50], 1);
	PlayerTextDrawBoxColor(playerid, MDC_UI[playerid][50], -1457315073);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][50], 0);
	PlayerTextDrawSetOutline(playerid, MDC_UI[playerid][50], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_UI[playerid][50], 255);
	PlayerTextDrawFont(playerid, MDC_UI[playerid][50], 1);
	PlayerTextDrawSetProportional(playerid, MDC_UI[playerid][50], 1);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][50], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_UI[playerid][50], true);

	MDC_UI[playerid][51] = CreatePlayerTextDraw(playerid, 237.057052, 251.249938, "]_Fines:_6_Pending,_2_Expired!!");
	PlayerTextDrawLetterSize(playerid, MDC_UI[playerid][51], 0.177452, 1.051667);
	PlayerTextDrawAlignment(playerid, MDC_UI[playerid][51], 1);
	PlayerTextDrawColor(playerid, MDC_UI[playerid][51], -1);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][51], 0);
	PlayerTextDrawSetOutline(playerid, MDC_UI[playerid][51], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_UI[playerid][51], 255);
	PlayerTextDrawFont(playerid, MDC_UI[playerid][51], 2);
	PlayerTextDrawSetProportional(playerid, MDC_UI[playerid][51], 1);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][51], 0);

	MDC_UI[playerid][52] = CreatePlayerTextDraw(playerid, 233.608917, 267.583343, "");
	PlayerTextDrawLetterSize(playerid, MDC_UI[playerid][52], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, MDC_UI[playerid][52], 115.000000, 13.000000);
	PlayerTextDrawAlignment(playerid, MDC_UI[playerid][52], 1);
	PlayerTextDrawColor(playerid, MDC_UI[playerid][52], -1);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][52], 0);
	PlayerTextDrawSetOutline(playerid, MDC_UI[playerid][52], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_UI[playerid][52], -1431655681);
	PlayerTextDrawFont(playerid, MDC_UI[playerid][52], 5);
	PlayerTextDrawSetProportional(playerid, MDC_UI[playerid][52], 0);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][52], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_UI[playerid][52], true);
	PlayerTextDrawSetPreviewModel(playerid, MDC_UI[playerid][52], 0);
	PlayerTextDrawSetPreviewRot(playerid, MDC_UI[playerid][52], 0.000000, 0.000000, 0.000000, -11.000000);

	MDC_UI[playerid][53] = CreatePlayerTextDraw(playerid, 233.608917, 282.166748, "");
	PlayerTextDrawLetterSize(playerid, MDC_UI[playerid][53], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, MDC_UI[playerid][53], 115.000000, 13.000000);
	PlayerTextDrawAlignment(playerid, MDC_UI[playerid][53], 1);
	PlayerTextDrawColor(playerid, MDC_UI[playerid][53], -1);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][53], 0);
	PlayerTextDrawSetOutline(playerid, MDC_UI[playerid][53], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_UI[playerid][53], -1431655681);
	PlayerTextDrawFont(playerid, MDC_UI[playerid][53], 5);
	PlayerTextDrawSetProportional(playerid, MDC_UI[playerid][53], 0);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][53], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_UI[playerid][53], true);
	PlayerTextDrawSetPreviewModel(playerid, MDC_UI[playerid][53], 0);
	PlayerTextDrawSetPreviewRot(playerid, MDC_UI[playerid][53], 0.000000, 0.000000, 0.000000, -11.000000);

	MDC_UI[playerid][54] = CreatePlayerTextDraw(playerid, 233.608917, 296.750122, "");
	PlayerTextDrawLetterSize(playerid, MDC_UI[playerid][54], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, MDC_UI[playerid][54], 115.000000, 13.000000);
	PlayerTextDrawAlignment(playerid, MDC_UI[playerid][54], 1);
	PlayerTextDrawColor(playerid, MDC_UI[playerid][54], -1);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][54], 0);
	PlayerTextDrawSetOutline(playerid, MDC_UI[playerid][54], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_UI[playerid][54], -1431655681);
	PlayerTextDrawFont(playerid, MDC_UI[playerid][54], 5);
	PlayerTextDrawSetProportional(playerid, MDC_UI[playerid][54], 0);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][54], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_UI[playerid][54], true);
	PlayerTextDrawSetPreviewModel(playerid, MDC_UI[playerid][54], 0);
	PlayerTextDrawSetPreviewRot(playerid, MDC_UI[playerid][54], 0.000000, 0.000000, 0.000000, -11.000000);

	MDC_UI[playerid][55] = CreatePlayerTextDraw(playerid, 237.525588, 268.166656, "~>~_Manage_Licenses");
	PlayerTextDrawLetterSize(playerid, MDC_UI[playerid][55], 0.205094, 1.069166);
	PlayerTextDrawAlignment(playerid, MDC_UI[playerid][55], 1);
	PlayerTextDrawColor(playerid, MDC_UI[playerid][55], 858993663);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][55], 0);
	PlayerTextDrawSetOutline(playerid, MDC_UI[playerid][55], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_UI[playerid][55], 255);
	PlayerTextDrawFont(playerid, MDC_UI[playerid][55], 2);
	PlayerTextDrawSetProportional(playerid, MDC_UI[playerid][55], 1);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][55], 0);

	MDC_UI[playerid][56] = CreatePlayerTextDraw(playerid, 237.525588, 282.750030, "~>~_Apply_Charges");
	PlayerTextDrawLetterSize(playerid, MDC_UI[playerid][56], 0.205094, 1.069166);
	PlayerTextDrawAlignment(playerid, MDC_UI[playerid][56], 1);
	PlayerTextDrawColor(playerid, MDC_UI[playerid][56], 858993663);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][56], 0);
	PlayerTextDrawSetOutline(playerid, MDC_UI[playerid][56], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_UI[playerid][56], 255);
	PlayerTextDrawFont(playerid, MDC_UI[playerid][56], 2);
	PlayerTextDrawSetProportional(playerid, MDC_UI[playerid][56], 1);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][56], 0);

	MDC_UI[playerid][57] = CreatePlayerTextDraw(playerid, 237.057067, 297.333404, "~>~_Arrest_Record");
	PlayerTextDrawLetterSize(playerid, MDC_UI[playerid][57], 0.205094, 1.069166);
	PlayerTextDrawAlignment(playerid, MDC_UI[playerid][57], 1);
	PlayerTextDrawColor(playerid, MDC_UI[playerid][57], 858993663);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][57], 0);
	PlayerTextDrawSetOutline(playerid, MDC_UI[playerid][57], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_UI[playerid][57], 255);
	PlayerTextDrawFont(playerid, MDC_UI[playerid][57], 2);
	PlayerTextDrawSetProportional(playerid, MDC_UI[playerid][57], 1);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][57], 0);

	MDC_UI[playerid][58] = CreatePlayerTextDraw(playerid, 357.935638, 269.333282, "box");
	PlayerTextDrawLetterSize(playerid, MDC_UI[playerid][58], 0.000000, 0.816985);
	PlayerTextDrawTextSize(playerid, MDC_UI[playerid][58], 498.000000, 0.000000);
	PlayerTextDrawAlignment(playerid, MDC_UI[playerid][58], 1);
	PlayerTextDrawColor(playerid, MDC_UI[playerid][58], 926035967);
	PlayerTextDrawUseBox(playerid, MDC_UI[playerid][58], 1);
	PlayerTextDrawBoxColor(playerid, MDC_UI[playerid][58], 255);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][58], 0);
	PlayerTextDrawSetOutline(playerid, MDC_UI[playerid][58], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_UI[playerid][58], 255);
	PlayerTextDrawFont(playerid, MDC_UI[playerid][58], 1);
	PlayerTextDrawSetProportional(playerid, MDC_UI[playerid][58], 1);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][58], 0);

	MDC_UI[playerid][59] = CreatePlayerTextDraw(playerid, 480.688507, 267.583190, "~y~]~w~_OUTSTANDING_CHARGES_~y~]~w~");
	PlayerTextDrawLetterSize(playerid, MDC_UI[playerid][59], 0.184011, 1.115832);
	PlayerTextDrawAlignment(playerid, MDC_UI[playerid][59], 3);
	PlayerTextDrawColor(playerid, MDC_UI[playerid][59], -1);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][59], 0);
	PlayerTextDrawSetOutline(playerid, MDC_UI[playerid][59], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_UI[playerid][59], 255);
	PlayerTextDrawFont(playerid, MDC_UI[playerid][59], 2);
	PlayerTextDrawSetProportional(playerid, MDC_UI[playerid][59], 1);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][59], 0);

	MDC_UI[playerid][60] = CreatePlayerTextDraw(playerid, 356.061431, 279.833221, "-_Rape_x2~n~-_House_Robbery");
	PlayerTextDrawLetterSize(playerid, MDC_UI[playerid][60], 0.185885, 0.958333);
	PlayerTextDrawAlignment(playerid, MDC_UI[playerid][60], 1);
	PlayerTextDrawColor(playerid, MDC_UI[playerid][60], 255);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][60], 0);
	PlayerTextDrawSetOutline(playerid, MDC_UI[playerid][60], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_UI[playerid][60], 255);
	PlayerTextDrawFont(playerid, MDC_UI[playerid][60], 1);
	PlayerTextDrawSetProportional(playerid, MDC_UI[playerid][60], 1);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][60], 0);

	MDC_UI[playerid][61] = CreatePlayerTextDraw(playerid, 231.581253, 119.999938, "");
	PlayerTextDrawLetterSize(playerid, MDC_UI[playerid][61], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, MDC_UI[playerid][61], 106.000000, 123.000000);
	PlayerTextDrawAlignment(playerid, MDC_UI[playerid][61], 1);
	PlayerTextDrawColor(playerid, MDC_UI[playerid][61], -1);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][61], 0);
	PlayerTextDrawSetOutline(playerid, MDC_UI[playerid][61], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_UI[playerid][61], 0);
	PlayerTextDrawFont(playerid, MDC_UI[playerid][61], 5);
	PlayerTextDrawSetProportional(playerid, MDC_UI[playerid][61], 0);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][61], 0);
	PlayerTextDrawSetPreviewModel(playerid, MDC_UI[playerid][61], 560);
	PlayerTextDrawSetPreviewRot(playerid, MDC_UI[playerid][61], 0.000000, 0.000000, 90.000000, 0.899999);
	PlayerTextDrawSetPreviewVehCol(playerid, MDC_UI[playerid][61], 1, 1);

	MDC_UI[playerid][62] = CreatePlayerTextDraw(playerid, 342.474792, 156.166687, "Model:~n~Plate:~n~Owner~n~Impounded");
	PlayerTextDrawLetterSize(playerid, MDC_UI[playerid][62], 0.207437, 1.226666);
	PlayerTextDrawAlignment(playerid, MDC_UI[playerid][62], 1);
	PlayerTextDrawColor(playerid, MDC_UI[playerid][62], 858993663);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][62], 0);
	PlayerTextDrawSetOutline(playerid, MDC_UI[playerid][62], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_UI[playerid][62], 255);
	PlayerTextDrawFont(playerid, MDC_UI[playerid][62], 2);
	PlayerTextDrawSetProportional(playerid, MDC_UI[playerid][62], 1);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][62], 0);

	MDC_UI[playerid][63] = CreatePlayerTextDraw(playerid, 420.719268, 156.166748, "Sultan~n~56JHA~n~Offset_Test~n~~g~No");
	PlayerTextDrawLetterSize(playerid, MDC_UI[playerid][63], 0.207437, 1.226666);
	PlayerTextDrawAlignment(playerid, MDC_UI[playerid][63], 1);
	PlayerTextDrawColor(playerid, MDC_UI[playerid][63], -2004317953);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][63], 0);
	PlayerTextDrawSetOutline(playerid, MDC_UI[playerid][63], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_UI[playerid][63], 255);
	PlayerTextDrawFont(playerid, MDC_UI[playerid][63], 2);
	PlayerTextDrawSetProportional(playerid, MDC_UI[playerid][63], 1);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][63], 0);
	
	MDC_UI[playerid][64] = CreatePlayerTextDraw(playerid, 314.363433, 142.750015, "_"); // input_button
	PlayerTextDrawLetterSize(playerid, MDC_UI[playerid][64], 0.214933, 1.045833);
	PlayerTextDrawAlignment(playerid, MDC_UI[playerid][64], 1);
	PlayerTextDrawColor(playerid, MDC_UI[playerid][64], 255);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][64], 0);
	PlayerTextDrawSetOutline(playerid, MDC_UI[playerid][64], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_UI[playerid][64], 255);
	PlayerTextDrawFont(playerid, MDC_UI[playerid][64], 1);
	PlayerTextDrawSetProportional(playerid, MDC_UI[playerid][64], 1);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][64], 0);
	
	MDC_UI[playerid][65] = CreatePlayerTextDraw(playerid, 236.588592, 159.666702, "box");
	PlayerTextDrawLetterSize(playerid, MDC_UI[playerid][65], 0.000000, 5.689605);
	PlayerTextDrawTextSize(playerid, MDC_UI[playerid][65], 300.000000, 0.000000);
	PlayerTextDrawAlignment(playerid, MDC_UI[playerid][65], 1);
	PlayerTextDrawColor(playerid, MDC_UI[playerid][65], -1);
	PlayerTextDrawUseBox(playerid, MDC_UI[playerid][65], 1);
	PlayerTextDrawBoxColor(playerid, MDC_UI[playerid][65], 255);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][65], 0);
	PlayerTextDrawSetOutline(playerid, MDC_UI[playerid][65], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_UI[playerid][65], 255);
	PlayerTextDrawFont(playerid, MDC_UI[playerid][65], 1);
	PlayerTextDrawSetProportional(playerid, MDC_UI[playerid][65], 1);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][65], 0);

	MDC_UI[playerid][66] = CreatePlayerTextDraw(playerid, 268.448120, 164.916641, "PICTURE~n~NOT~n~AVAILABLE");
	PlayerTextDrawLetterSize(playerid, MDC_UI[playerid][66], 0.340966, 1.425000);
	PlayerTextDrawAlignment(playerid, MDC_UI[playerid][66], 2);
	PlayerTextDrawColor(playerid, MDC_UI[playerid][66], -1);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][66], 0);
	PlayerTextDrawSetOutline(playerid, MDC_UI[playerid][66], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_UI[playerid][66], 255);
	PlayerTextDrawFont(playerid, MDC_UI[playerid][66], 1);
	PlayerTextDrawSetProportional(playerid, MDC_UI[playerid][66], 1);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][66], 0);
	
	MDC_UI[playerid][67] = CreatePlayerTextDraw(playerid, 236.588485, 208.083328, "box");
	PlayerTextDrawLetterSize(playerid, MDC_UI[playerid][67], 0.000000, 1.144950);
	PlayerTextDrawTextSize(playerid, MDC_UI[playerid][67], 498.000000, 0.000000);
	PlayerTextDrawAlignment(playerid, MDC_UI[playerid][67], 1);
	PlayerTextDrawColor(playerid, MDC_UI[playerid][67], -1);
	PlayerTextDrawUseBox(playerid, MDC_UI[playerid][67], 1);
	PlayerTextDrawBoxColor(playerid, MDC_UI[playerid][67], -1440602881);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][67], 0);
	PlayerTextDrawSetOutline(playerid, MDC_UI[playerid][67], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_UI[playerid][67], 255);
	PlayerTextDrawFont(playerid, MDC_UI[playerid][67], 1);
	PlayerTextDrawSetProportional(playerid, MDC_UI[playerid][67], 1);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][67], 0);

	MDC_UI[playerid][68] = CreatePlayerTextDraw(playerid, 237.994079, 207.499984, "]_this_vehicle_is_reported_stolen_-_7/FEB/2017");
	PlayerTextDrawLetterSize(playerid, MDC_UI[playerid][68], 0.213528, 1.104168);
	PlayerTextDrawAlignment(playerid, MDC_UI[playerid][68], 1);
	PlayerTextDrawColor(playerid, MDC_UI[playerid][68], -1);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][68], 0);
	PlayerTextDrawSetOutline(playerid, MDC_UI[playerid][68], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_UI[playerid][68], 255);
	PlayerTextDrawFont(playerid, MDC_UI[playerid][68], 2);
	PlayerTextDrawSetProportional(playerid, MDC_UI[playerid][68], 1);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][68], 0);
	
	MDC_UI[playerid][69] = CreatePlayerTextDraw(playerid, 233.777709, 135.750030, "[CARSIGN]_~n~NAME");
	PlayerTextDrawLetterSize(playerid, MDC_UI[playerid][69], 0.208843, 0.993332);
	PlayerTextDrawAlignment(playerid, MDC_UI[playerid][69], 1);
	PlayerTextDrawColor(playerid, MDC_UI[playerid][69], 858993663);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][69], 0);
	PlayerTextDrawSetOutline(playerid, MDC_UI[playerid][69], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_UI[playerid][69], 255);
	PlayerTextDrawFont(playerid, MDC_UI[playerid][69], 1);
	PlayerTextDrawSetProportional(playerid, MDC_UI[playerid][69], 1);
	PlayerTextDrawSetShadow(playerid, MDC_UI[playerid][69], 0);
	
}


ToggleMDC(playerid, bool:SHOW)
{
	if(SHOW)
	{
	    PlayerTextDrawBackgroundColor(playerid, MDC_UI[playerid][35], 858993663);
	    PlayerTextDrawColor(playerid, MDC_UI[playerid][39], -1);
		PlayerTextDrawBackgroundColor(playerid, MDC_UI[playerid][10], 858993663);
		PlayerTextDrawColor(playerid, MDC_UI[playerid][16], -1);
		
		for(new i; i < 35; i ++) PlayerTextDrawShow(playerid, MDC_UI[playerid][i]);

		new sub_str[128], count = 0;
		for(new i = 0; i < GetPlayerPoolSize(); i+=3)
		{
		    if(PlayerInfo[i][pPoliceDuty])
		    {
				count ++;
			}
		}
		format(sub_str, 128, "%d~n~%d~n~0", count, warrant_count);
		PlayerTextDrawSetString(playerid, MDC_UI[playerid][28], sub_str);
		format(sub_str, 128, "%d~n~0~n~0", call_count);
		PlayerTextDrawSetString(playerid, MDC_UI[playerid][30], sub_str);
		
	}
	else
	{
	    for(new i; i < 70; i ++) PlayerTextDrawHide(playerid, MDC_UI[playerid][i]);
	    
	    PlayerTextDrawBackgroundColor(playerid, MDC_UI[playerid][36], -1431655681);
	    PlayerTextDrawColor(playerid, MDC_UI[playerid][40], 858993663);
	    
	    
		for(new x = 10; x < 16; x ++)
		{
		    PlayerTextDrawBackgroundColor(playerid, MDC_UI[playerid][x], -1431655681);
		    PlayerTextDrawColor(playerid, MDC_UI[playerid][x+6], 858993663);
		}
	    SetPVarInt(playerid, "Query_Mode", 0);
	    SetPVarInt(playerid, "UsingMDC", 0);
	}
	return 1;
}

this::OnMDCRecordSearch(playerid, type)
{
	new
		query[255];

	switch(type)
	{
		case 1: //Name search;
		{
			if(!ReturnDBIDFromName(PlayerMDCName[playerid]))
			{
				return PlayerTextDrawSetString(playerid, MDC_UI[playerid][64], "NO_SUCH_DATA..");
			}
			mysql_format(this, query, sizeof(query), "SELECT LastSeen, char_dbid, PrisonSkin, pPhone, pActiveListings, pPrisonTimes, pJailTimes, pDriversLicense, pWeaponsLicense FROM characters WHERE char_dbid = %i", ReturnDBIDFromName(PlayerMDCName[playerid]));
			mysql_tquery(this, query, "OnMDCNameFound", "i", playerid);
		}
		case 2: //Plate search;
		{
			mysql_format(this, query, sizeof(query), "SELECT VehiclePlates FROM vehicles WHERE VehiclePlates LIKE '%%%e%%' LIMIT 5", PlayerMDCName[playerid]);
			mysql_tquery(this, query, "OnMDCPlate", "i", playerid);

			return 1;
		}
	}

	return 1;
}

this::OnMDCPlate(playerid)
{
	if(!cache_num_rows())
	{
		for(new i = 0; i < 5; i++) PlayerPlateSaver[playerid][i] = "";
		PlayerMDCName[playerid] = "";

		return PlayerTextDrawSetString(playerid, MDC_UI[playerid][64], "~r~NO_SUCH_DATA..");
	}

	new rows, fields, str[128];
	cache_get_data(rows, fields, this);

	for(new i = 0; i < rows; i++)
	{
		cache_get_field_content(i, "VehiclePlates", PlayerPlateSaver[playerid][i], this, 20);
	}

	for(new i = 0; i < 5; i++)
	{
		if(!isnull(PlayerPlateSaver[playerid][i]))
		{
			format(str, sizeof(str), "%s%s\n", str, PlayerPlateSaver[playerid][i]);
		}
	}

	ShowPlayerDialog(playerid, DIALOG_MDC_PLATE_LIST, DIALOG_STYLE_LIST, "Plate Search - MDC", str, "Select", "<<");
	return 1;
}

this::OnPlateSelect(playerid, listitem)
{
	new rows, fields;
	cache_get_data(rows, fields, this);

	new
		model,
		owner,
		impounded,
		sub_str[64],
		stolen,
		primary_str[200]
	;

	model = cache_get_field_content_int(0, "VehicleModel", model);
	owner = cache_get_field_content_int(0, "VehicleOwnerDBID", owner);
	impounded = bool:cache_get_field_content_int(0, "VehicleImpounded", impounded);
    stolen = bool:cache_get_field_content_int(0, "VehicleStolen", stolen);

	PlayerTextDrawHide(playerid, MDC_UI[playerid][65]);
	PlayerTextDrawHide(playerid, MDC_UI[playerid][66]);

	if(stolen)
	{
	    PlayerTextDrawShow(playerid, MDC_UI[playerid][67]);
	    PlayerTextDrawShow(playerid, MDC_UI[playerid][68]);
		new year, month, day, MonthStr[16], str[64];
		getdate(year, month, day);
		switch(month)
		{
		    case 1:  MonthStr = "Jan";
		    case 2:  MonthStr = "Feb";
		    case 3:  MonthStr = "Mar";
		    case 4:  MonthStr = "Apr";
		    case 5:  MonthStr = "May";
		    case 6:  MonthStr = "Jun";
		    case 7:  MonthStr = "Jul";
		    case 8:  MonthStr = "Aug";
		    case 9:  MonthStr = "Sep";
		    case 10: MonthStr = "Oct";
		    case 11: MonthStr = "Nov";
		    case 12: MonthStr = "Dec";
		}
		format(str, sizeof str, "_NOTE(s):_Vehicle_reported_stolen_-_%d/%s/%d", day, MonthStr, year);
	    PlayerTextDrawSetString(playerid, MDC_UI[playerid][68], "_NOTE(s):_Vehicle_reported_stolen");
	}
	
    for(new x = 16; x < 22; x ++)
    {
        PlayerTextDrawShow(playerid, MDC_UI[playerid][x]);
    }
    
    for(new x = 42; x < 61; x ++)
    {
        PlayerTextDrawHide(playerid, MDC_UI[playerid][x]);
    }

    PlayerTextDrawSetPreviewModel(playerid, MDC_UI[playerid][61], model);
    format(primary_str, sizeof primary_str, "%s~n~%s~n~%s~n~~g~%s", ReturnVehicleModelName(model), PlayerPlateSaver[playerid][listitem], ReturnDBIDName(owner), (impounded) ? ("Yes") : ("No"));
    PlayerTextDrawSetString(playerid, MDC_UI[playerid][63], primary_str);
    
    format(sub_str, sizeof sub_str, "%s", PlayerPlateSaver[playerid][listitem]);
    PlayerTextDrawSetString(playerid, MDC_UI[playerid][64], sub_str);
    
    for(new x = 61; x < 64; x ++)
    {
        PlayerTextDrawHide(playerid, MDC_UI[playerid][x]);
    	PlayerTextDrawShow(playerid, MDC_UI[playerid][x]);
    }
	return 1;
}

this::OnMDCNameFound(playerid)
{
	new rows, fields;
	cache_get_data(rows, fields, this);

	new
		primary_str[300],
		sub_str[128],
		str[128],
		active_listing,
		jail_times,
		skin,
		dlic,
		wlic,
		charid,
		phone_number,
		prison_times,
		list[256],
		last_seen[28],
		query[128]
	;

	phone_number = cache_get_field_content_int(0, "pPhone", phone_number);
	active_listing = cache_get_field_content_int(0, "pActiveListings", active_listing);
	jail_times = cache_get_field_content_int(0, "pJailTimes", jail_times);
	prison_times = cache_get_field_content_int(0, "pPrisonTimes", prison_times);
	dlic = cache_get_field_content_int(0, "pDriversLicense", dlic);
	wlic = cache_get_field_content_int(0, "pWeaponsLicense", wlic);
	skin = cache_get_field_content_int(0, "PrisonSkin", skin);
	charid = cache_get_field_content_int(0, "char_dbid", charid);

	cache_get_field_content(0, "LastSeen", last_seen, this, 28);
	
	if(!skin)
	{
	    PlayerTextDrawShow(playerid, MDC_UI[playerid][65]);
	    PlayerTextDrawShow(playerid, MDC_UI[playerid][66]);
	}
	
    format(str, sizeof str, "%s", PlayerMDCName[playerid]);
    PlayerTextDrawSetString(playerid, MDC_UI[playerid][64], str);
    PlayerTextDrawSetPreviewModel(playerid, MDC_UI[playerid][42], skin);
    

    
    for(new x = 35; x < 61; x ++)
    {
        PlayerTextDrawHide(playerid, MDC_UI[playerid][x]);
    	PlayerTextDrawShow(playerid, MDC_UI[playerid][x]);
    }
    
    if(jail_times > 0)
    {
	    format(list, sizeof(list), "%s~n~%s~n~%d~n~%d_jail_sentences.~n~%s_%s", PlayerMDCName[playerid], last_seen, phone_number, jail_times, (wlic) ? ("Weapons_License") : ("None_(PF/CCW)"), (dlic) ? ("Driver's_License") : ("None_(DL)"));
		PlayerTextDrawSetString(playerid, MDC_UI[playerid][45], list);
	}
	else if(prison_times > 0)
	{
	    format(list, sizeof(list), "%s~n~%s~n~%d~n~%d_prison_sentences.~n~%s_%s", PlayerMDCName[playerid], last_seen, phone_number, prison_times, (wlic) ? ("Weapons_License") : ("None_(PF/CCW)"), (dlic) ? ("Driver's_License") : ("None_(DL)"));
		PlayerTextDrawSetString(playerid, MDC_UI[playerid][45], list);
	}
	else if(prison_times > 0 && jail_times > 0)
	{
	    format(list, sizeof(list), "%s~n~%s~n~%d~n~%d_jail_sentences,_%d_prison_sentences.~n~%s_%s", PlayerMDCName[playerid], last_seen, phone_number, jail_times, prison_times, (wlic) ? ("Weapons_License") : ("None_(PF/CCW)"), (dlic) ? ("Driver's_License") : ("None_(DL)"));
		PlayerTextDrawSetString(playerid, MDC_UI[playerid][45], list);
	}
	else
	{
	    format(list, sizeof(list), "%s~n~%s~n~%d~n~None~n~%s_%s", PlayerMDCName[playerid], last_seen, phone_number, (wlic) ? ("Weapons_License") : ("None_(PF/CCW)"), (dlic) ? ("Driver's_License") : ("None_(DL)"));
		PlayerTextDrawSetString(playerid, MDC_UI[playerid][45], list);
	}
	
    PlayerTextDrawHide(playerid, MDC_UI[playerid][44]);
    PlayerTextDrawShow(playerid, MDC_UI[playerid][44]);
    
	if(active_listing > 0)
	{
		PlayerTextDrawSetString(playerid, MDC_UI[playerid][49], "]_This_Person_is_linked_to_a_warrant!_click_here_for_info");
	}
	else
	{
		PlayerTextDrawSetString(playerid, MDC_UI[playerid][49], "]_This_Person_has_no_warrants.");
	}
	
	mysql_format(this, query, sizeof(query), "SELECT * FROM properties WHERE PropertyOwnerDBID = %d", charid);
	new Cache:house_cache = mysql_query(this, query);
	
	if(!cache_num_rows())
	{
		PlayerTextDrawSetString(playerid, MDC_UI[playerid][47], "]_This_Person_has_no_registered_properties.");
	}
	else
	{
	    static
			getHouse[32]
		;
		
	    format(getHouse, 32, "]_This_Person_has_%d_addresse(s),_click_here_for_a_list!", cache_num_rows());
		PlayerTextDrawSetString(playerid, MDC_UI[playerid][47], getHouse);
	}
    cache_delete(house_cache);
    
	mysql_format(this, query, sizeof(query), "SELECT charge_reason FROM criminal_record WHERE player_name = '%e' ORDER BY idx DESC", PlayerMDCName[playerid]);
	
	new Cache:cache = mysql_query(this, query);
	new record[128];

	if(!cache_num_rows())
		primary_str = "~g~NO_CHARGES_FOUND.";

	else
	{
		for(new i = 0; i < cache_num_rows(); i++)
		{
			cache_get_field_content(i, "charge_reason", record);
			format(sub_str, sizeof(sub_str), "-_%s~n~", record);
			strcat(primary_str, sub_str);
		}
	}
	
    PlayerTextDrawSetString(playerid, MDC_UI[playerid][60], primary_str);

	cache_delete(cache);
	return 1;
}

UpdateMDC(playerid, page)
{
	new str[128];
	switch(page)
	{
		case 0:
		{
		    for(new x = 35; x < 42; x ++)
		    {
		        PlayerTextDrawHide(playerid, MDC_UI[playerid][x]);
		    }
		    for(new i = 23; i < 35; i ++)
		    {
		        PlayerTextDrawShow(playerid, MDC_UI[playerid][i]);
		    }
		    PlayerTextDrawSetPreviewModel(playerid, MDC_UI[playerid][23], GetPlayerSkin(playerid));
		 	format(str, sizeof(str), "%s_%s", ReturnFactionRank(playerid), ReturnName(playerid));
		  	PlayerTextDrawSetString(playerid, MDC_UI[playerid][26], str);
		  	PlayerTextDrawHide(playerid, MDC_UI[playerid][23]);
            PlayerTextDrawShow(playerid, MDC_UI[playerid][23]);
            
            PlayerTextDrawHide(playerid, MDC_UI[playerid][64]);
			PlayerTextDrawHide(playerid, MDC_UI[playerid][65]);
			PlayerTextDrawHide(playerid, MDC_UI[playerid][66]);
            
		}
		case 1:
		{
			PlayerTextDrawHide(playerid, MDC_UI[playerid][65]);
			PlayerTextDrawHide(playerid, MDC_UI[playerid][66]);
		
		    for(new i = 23; i < 35; i ++)
		    {
		        PlayerTextDrawHide(playerid, MDC_UI[playerid][i]);
		    }
		    for(new x = 35; x < 42; x ++)
		    {
		    	PlayerTextDrawShow(playerid, MDC_UI[playerid][x]);
		    }
		    PlayerTextDrawShow(playerid, MDC_UI[playerid][64]);
		}
		case 2:
		{
		
		}
		case 3:
		{
			new primary_str[256], sub_str[128], count = 0;
			for(new i = 0; i < GetPlayerPoolSize(); i+=3)
			{
			    if(PlayerInfo[i][pPoliceDuty])
			    {
					format(sub_str, sizeof(sub_str), "(Unit_%i):_%s_%s_%s_%s~n~", i-2, ReturnName(i), ReturnName(i+1), ReturnName(i+2), ReturnName(i+3));
					strcat(primary_str, sub_str);
					count ++;
				}
			}
			
			if(!count) return PlayerTextDrawSetString(playerid, MDC_UI[playerid][69], "~r~There's no-one that registered to any callsigns..");
		    PlayerTextDrawSetString(playerid, MDC_UI[playerid][69], primary_str);
		    PlayerTextDrawShow(playerid, MDC_UI[playerid][69]);
		    // list onduty cops
		}
		case 4:
		{
		
		}
		case 5:
		{
		
		}
	}
 	format(str, sizeof(str), "%s", ReturnPage(page));
  	PlayerTextDrawSetString(playerid, MDC_UI[playerid][8], str);
  	
 	format(str, sizeof(str), "%s", ReturnName(playerid));
  	PlayerTextDrawSetString(playerid, MDC_UI[playerid][9], str);
  	return 1;
}

ReturnPage(page)
{
	new str[64];
	switch(page)
	{
		case 0: str = "Los_Santos_Police_Department_-_www.lspd.gov.us";
		case 1: str = "POLICE_~>~_Look-Up";
		case 2: str = "POLICE_~>~_Emergency";
		case 3: str = "POLICE_~>~_Roster";
		case 4: str = "POLICE_~>~_Records_DB";
		case 5: str = "POLICE_~>~_CCTV";
	}
	return str;
}

ResetCharacterSetup(playerid)
{
	if (!PlayerInfo[playerid][pSetupInfo])
	{
	    PlayerInfo[playerid][pLastSkin] = g_MaleSkins[0];
    	PlayerInfo[playerid][pAge] = 13;
    	PlayerInfo[playerid][pGender] = GENDER_MALE;
    	PlayerInfo[playerid][pOutfit] = 0;

		SetPlayerSkin(playerid, PlayerInfo[playerid][pLastSkin]);
		UpdateCharacterSetup(playerid);
	}
}

UpdateCharacterSetup(playerid)
{
	new string[64];

	if (PlayerInfo[playerid][pGender] == GENDER_MALE) {
	    PlayerTextDrawSetString(playerid, SetUp[playerid][3], "Male");
	    PlayerTextDrawSetString(playerid, SetUp[playerid][4], "Female");
	} else if (PlayerInfo[playerid][pGender] == GENDER_FEMALE) {
	    PlayerTextDrawSetString(playerid, SetUp[playerid][3], "Male");
	    PlayerTextDrawSetString(playerid, SetUp[playerid][4], "Female");
	}

	format(string, sizeof(string), "%i years old", PlayerInfo[playerid][pAge]);
	PlayerTextDrawSetString(playerid, SetUp[playerid][6], string);

	format(string, sizeof(string), "Skin: %i/%i", PlayerInfo[playerid][pOutfit] + 1, (PlayerInfo[playerid][pGender] == GENDER_MALE ? sizeof(g_MaleSkins) : sizeof(g_FemaleSkins)));
	PlayerTextDrawSetString(playerid, SetUp[playerid][10], string);
}

UpdateSkinSelection(playerid, index)
{
	new size;

	if (PlayerInfo[playerid][pGender] == GENDER_MALE) {
	    size = sizeof(g_MaleSkins);
	} else if (PlayerInfo[playerid][pGender] == GENDER_FEMALE) {
	    size = sizeof(g_FemaleSkins);
	}

	if (index < 0) {
	    index = --size;
	} else if (index >= size) {
	    index = 0;
	}

    PlayerInfo[playerid][pOutfit] = index;

	if (PlayerInfo[playerid][pGender] == GENDER_MALE) {
	    PlayerInfo[playerid][pLastSkin] = g_MaleSkins[index];
	} else if (PlayerInfo[playerid][pGender] == GENDER_FEMALE) {
	    PlayerInfo[playerid][pLastSkin] = g_FemaleSkins[index];
	}
	SetPlayerSkin(playerid, PlayerInfo[playerid][pLastSkin]);
}

Dialog:SetupConfirm(playerid, response, listitem, inputtext[])
{
	if (response)
	{
	    PlayerInfo[playerid][pSetupInfo] = 1;
	    
		PlayerInfo[playerid][pMaskID][0] = 200000+random(199991);
		PlayerInfo[playerid][pMaskID][1] = 40+random(59);
	
		ApplyAnimation(playerid, "FREEWEIGHTS", "gym_free_celebrate", 4.0, 0, 0, 0, 0, 0, 1);
		PlayerPlaySound(playerid, 1058, 0.0, 0.0, 0.0);

		SendServerMessage(playerid, "You have completed character setup! Your character will spawn in a moment.");
		SetTimerEx("SetupConfirmed", 3000, false, "i", playerid);
	}
	return 1;
}

this::SetupConfirmed(playerid)
{
	if (PlayerInfo[playerid][pSetupInfo])
	{
		for (new i = 0; i < 16; i ++) {
		    PlayerTextDrawHide(playerid, SetUp[playerid][i]);
		}
		SetPlayersSpawn(playerid);
		//SpawnPlayer(playerid);
		
		TogglePlayerControllable(playerid, 1);
		CancelSelectTextDraw(playerid);
		
		for (new i = 0; i < 30; i ++)
		{
		    SendClientMessage(playerid, COLOR_GREY, " ");
		}
		SendServerMessage(playerid, "You have spawned at the Los Santos International Airport.");
		SendServerMessage(playerid, "There are some rental vehicles located nearby for transportation or you can call an cab to transport you.");
	}
}

GetGenderForPlayer(playerid)
{
	new str[8];

	if (PlayerInfo[playerid][pGender] == 1)
	    str = "Male";
	else if (PlayerInfo[playerid][pGender] == 2)
     	str = "Female";

	return str;
}
#include "police_map.pwn"
#include "Idlewood_Projects.pwn"
#include "fire_department.pwn"

//-79.9302, 1383.4977, 1078.9551
//
enum INTERIOR_MAIN
{
	INT_NAME[28],
	Float:INT_POS[3],
	INT_ID
};

new Interior[37][INTERIOR_MAIN] =
{
	// Interior Name // Positions ( X, Y, Z) // Interior ID
	{"Ryder's House", {2468.8411,-1698.2228,1013.5078}, 2},
	{"CJ's House", {2495.8916,-1692.5658,1014.7422}, 3},
	{"Madd Dog Mansion", {1299.14, -794.77, 1084.00}, 5},
	{"Safe House 1", {2233.6919,-1112.8107,1050.8828}, 5},
	{"Safe House 2", {2196.8374,-1204.5576,1049.0234}, 6},
	{"Safe House 3", {2317.5347,-1026.7506,1050.2178}, 9},
	{"Safe House 4", {2259.4021,-1136.0243,1050.6403}, 10},
	{"Burglary X1", {234.6087,1187.8195,1080.2578}, 3},
	{"Burglary X2", {225.5707,1240.0643,1082.1406}, 2},
	{"Burglary X3", {224.288,1289.1907,1082.1406}, 1},
	{"Burglary X4", {226.2955,1114.3379,1080.9929}, 5},
	{"Burglary Houses", {295.1391,1473.3719,1080.2578}, 15},
	{"Motel Room", {446.3247,509.9662,1001.4195}, 12},
	{"Pair Burglary", {446.626,1397.738,1084.3047}, 2},
	{"Burglary X11", {226.8998,0.2832,1080.9960}, 5},
	{"Burglary X12", {261.1165,1287.2197,1080.2578}, 4},
	{"Michelle's Love Nest", {309.4319,311.6189,1003.3047}, 4},
	{"Burglary X14", {24.3769,1341.1829,1084.375}, 10},
	{"Burglary X13", {221.6766,1142.4962,1082.6094}, 4},
	{"Unused House", {2323.7063,-1147.6509,1050.7101}, 12},
	{"Millie's Room", {344.9984,307.1824,999.1557}, 6},
	{"Burglary X15", {-262.1759,1456.6158,1084.3672}, 4},
	{"Burglary X16", {22.861,1404.9165,1084.4297}, 5},
	{"Burglary X17", {140.3679,1367.8837,1083.8621}, 5},
	{"House X18", {234.2826,1065.229,1084.2101}, 6},
	{"House X19", {-68.6652,1351.2054,1080.2109}, 6},
	{"House X20", {-283.4464,1470.8777,1084.3750}, 15},
	{"Colonel Furhberger", {2807.4458,-1174.2394,1025.5703}, 8},
	{"The Camel's Safehouse", {2218.0737,-1076.0438,1050.4844}, 1},
	{"Verdant Bluffs House", {2365.1042,-1135.5898,1050.8826}, 8},
	{"Burglary X21", {-42.6339,1405.4767,1084.4297}, 8},
	{"Willowfield House", {2282.8049,-1140.2722,1050.8984}, 11},
	{"House X20", {82.9119,1322.4266,1083.8662}, 9},
	{"Burglary X22", {260.7421,1238.2261,1084.2578}, 9},
	{"Burglary X23", {266.5074,305.1129,999.1484}, 2},
	{"Katie's Lovenest", {322.5014,303.6906,999.1484}, 5},
	{"Barbara's Love nest", {244.0007,305.1925,999.1484}, 1}
};

CMD:houseint(playerid, params[])
{
	new type;

    if (PlayerInfo[playerid][pAdmin] < 3)
	{
		return SendErrorMessage(playerid, "You don't have permission to use this command.");
	}
	else if (sscanf(params, "i", type))
	{
	    return SendUsageMessage(playerid, "/houseint (interior 0-%i)", sizeof(Interior));
	}
	else if (type < 0 || type > sizeof(Interior))
	{
	    return SendErrorMessage(playerid, "You must input a type between 0 and %i.", sizeof(g_HouseInteriors) - 1);
	}
	else
	{
	    SetPlayerPos(playerid, Interior[type][INT_POS][0], Interior[type][INT_POS][1], Interior[type][INT_POS][2]);
		SetPlayerInterior(playerid, Interior[type][INT_ID]);
	    sendMessage(playerid, -1, "You are now viewing house interior: %i.", type);
	}
	return 1;
}
