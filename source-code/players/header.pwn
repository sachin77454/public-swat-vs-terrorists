/*
	SWAT vs Terrorists is a team death-match SA-MP game-mode script. 
	Compatible with SA-MP 0.3.7 and later releases.

	Author: H2O
	Licensed under GNU GPLv3

	(c) 2018-2020 H2O Multiplayer. All rights reserved.
	Website: h2omultiplayer.com
*/

#if defined PLAYERS_HEADER_INCLUDED
	#endinput
#endif
#define PLAYERS_HEADER_INCLUDED

/*
 *
 *
//Player definitions
 *
 *
 */


//An enumerator that contains all player's account data
enum PlayerData {
	PlayerName[MAX_PLAYER_NAME],
	pAccountId,
	pIP[16],
	pPassword[65],
	pEmailAddress[65],
	pSaltKey[11],
	Cache: pCacheId,
	pLoggedIn,
	pPasswordVerified,
	pAdminLevel,
	pIsModerator,
	pDonorLevel,
	pMuted,
	pCapsDisabled,
	pJailed,
	pJailTime,
	pFrozen,
	pFreezeTime,
	pKills,
	pDeaths,
	Float: pCoins,
	ppSessionDeathsays,
	pSessionHours,
	pSessionMins,
	pTimePlayed,
	pPlayTick,
	pTempWarnings,
	pDoorsLocked,
	pSpamCount,
	pSpamTick,
	pCar,
	pSpecId,
	pSpecMode,
	pAdminDuty,
	pFailedLogins,
	pRegDate,
	pLastVisit,
	pGunFires,
	pHeadshots,
	pNutshots,
	pSessionKills,
	pSessionDeaths,
	pSessionGunFires,
	pLastKiller,
	pDeathmatchId,
	pLastHitTick,
	pIsAFK,
	pAFKTick,
	pLastSync,
	pBackup,
	pLimit,
	pLimit2,
	pZonesCaptured,
	pCaptureStreak,
	pPickedWeap,
	pHitIndicator,
	pAcceptedWeap,
	pDuelsWon,
	pDuelsLost,
	pTimesLoggedIn,
	pMedkitsUsed,
	pArmourkitsUsed,
	pSupportAttempts,
	pFavWeap,
	pFavWeap2,
	pFavWeap3,
	pIsInvitedToClan,
	pClan_Name[35],
	pClanWarSpec,
	pClanWarSpecId,
	pIsSpying,
	pUsedReport,
	pKnifeKills,
	pBombId,
	pBombIds[5],
	pAnthrax,
	pAnthraxEffects[17],
	pAnthraxTimer,
	pAnthraxTimes,
	pDoNotDisturb,
	pNoDuel,
	pHitIndicatorEnabled,
	pGUIEnabled,
	pSpawnKillTime,
	pQuestionAsked,
	pHeadshotStreak,
	pSpyTeam,
	pRevengeTakes,
	pClanTag,
	pEXPEarned,
	pKillAssists,
	pCapturAssists,
	pHighestKillStreak,
	pSawnKills,
	sKnives,
	sRevenges,
	sDisguisedKills,
	sSpiesKilled,
	sAssistkills,
	sGasKills,
	pAdjustedHelmet,
	pAdjustedMask,
	pAdjustedDynamite,
	pAirRocketsFired,
	pAntiAirRocketsFired,
	Carepacks,
	sEvents,
	sRaces,
	sDMKills,
	pLeavetime,
	pIsSafe,
	pDisableCapslock,
	pKnifer,
	pPrevName[MAX_PLAYER_NAME],
	pKnifeTarget,
	AntiAirAlerts,
	pChatLog[128],
	cbugLastAmmo,
	pCheckCBug,
	cbugAmmo,
	pCarInfoDisplayed,
	pSelecting,
	pSpamWarnings,
	pCrates,
	pDeathmatchKills,
	pRustlerRocketsFired,
	pRustlerRocketsHit,
	acWarnings,
	acTotalWarnings,
	acCooldown,
	Float: pHealthLost,
	Float: pDamageRate,
	pSMGKills,
	pShotgunKills,
	pPistolKills,
	pMeleeKills,
	pHeavyKills,
	pFistKills,
	pCloseKills,
	pDriversStabbed,
	pSpiesEliminated,
	pKillsAsSpy,
	pLongDistanceKills,
	pWeaponsDropped,
	pWeaponsPicked,
	pEventsWon,
	pRacesWon,
	pItemsUsed,
	pFavSkin,
	pFavTeam,
	pSuicideAttempts,
	pPlayersHealed,
	pCommandsUsed,
	pCommandsFailed,
	pUnauthorizedActions,
	pRCONLogins,
	pRCONFailedAttempts,
	pClassAbilitiesUsed,
	pDronesExploded,
	Float: pHealthGained,
	pInteriorsEntered,
	pInteriorsExitted,
	pPickupsPicked,
	pQuestionsAsked,
	pQuestionsAnswered,
	pCrashTimes,
	pSAMPClient[10],
	pBackupAttempts,
	pBackupsResponded,
	pBaseRapeAttempts,
	pCBugAttempts,
	pChatMessagesSent,
	pMoneySent,
	pMoneyReceived,
	pHighestBet,
	pDuelRequests,
	pDuelsAccepted,
	pDuelsRefusedByPlayer,
	pDuelsRefusedByOthers,
	pBountyAmount,
	pBountyCashSpent,
	pCoinsSpent,
	pPaymentsAccepted,
	pClanKills,
	pClanDeaths,
	pHighestCaptures,
	pKicksByAdmin,
	Float: pLongestKillDistance,
	Float: pNearestKillDistance,
	pHighestCaptureAssists,
	pHighestKillAssists,
	pBountyPlayersKilled,
	pPrototypesStolen,
	pAntennasDestroyed,
	pCratesOpened,
	pLastPing,
	Float: pLastPacketLoss,
	pHighestPing,
	pLowestPing,
	pNukesLaunched,
	pAirstrikesCalled,
	pAnthraxIntoxications,
	pPUBGEventsWon,
	pRopeRappels,
	pAreasEntered,
	pLastAreaId,
	Float: pLastPosX,
	Float: pLastPosY,
	Float: pLastPosZ,
	Float: pLastHealth,
	Float: pLastArmour,
	pTimeSpentOnFoot,
	pTimeSpentInCar,
	pTimeSpentAsPassenger,
	pTimeSpentInSelection,
	pTimeSpentAFK,
	pDriveByKills,
	pCashAdded,
	pCashReduced,
	pLastInterior,
	pLastVirtualWorld,
	pAccountWarnings,
	pAntiCheatWarnings,
	pPlayerReports,
	pSpamAttempts,
	pAdvAttempts,
	pAntiSwearBlocks,
	pTagPermitted,
	pReportAttempts,
	pBannedTimes,
	pWrapWarnings,
	pFlashBangedPlayers,
	pACWarnings,
	pACCooldown,
	pAFKOnSpawn,
	pLastMove,
	bool: pTFA,
	pSupportKey[10],
	pVerifyCode[10],
	bool: pEmailVerified,
	pEmailAttempts
};

//Email verification steps
new pEVerifySteps[MAX_PLAYERS];

//Checks...
new bool: pVerified[MAX_PLAYERS];
new bool: pIsAdmin[MAX_PLAYERS];

//The player's data array
new PlayerInfo[MAX_PLAYERS][PlayerData];

//Store player's money
new pMoney[MAX_PLAYERS];

//Stores the player's last vehicle ID
new LastVehicleID[MAX_PLAYERS];

/*
 *
 *
//Per-player timers
 *
 *
 */

new ExplodeTimer[MAX_PLAYERS];
new RepairTimer[MAX_PLAYERS];
new DelayerTimer[MAX_PLAYERS];
new RecoverTimer[MAX_PLAYERS];
new AKTimer[MAX_PLAYERS];
new CrateTimer[MAX_PLAYERS];
new KillerTimer[MAX_PLAYERS];
new JailTimer[MAX_PLAYERS];
new FreezeTimer[MAX_PLAYERS];
new DMTimer[MAX_PLAYERS];
new RespawnTimer[MAX_PLAYERS];
new InviteTimer[MAX_PLAYERS];
new ac_InformTimer[MAX_PLAYERS];
new SpawnTimer[MAX_PLAYERS];
new LoadingTimer[MAX_PLAYERS];
new TutoTimer[MAX_PLAYERS];
new NotifierTimer[MAX_PLAYERS];
new CarInfoTimer[MAX_PLAYERS];
new pTeamSTimer[MAX_PLAYERS];
new gBackupTimer[MAX_PLAYERS];
new DamageTimer[MAX_PLAYERS];
//new ParadropTimer[MAX_PLAYERS];
new FirstSpawn_Timer[MAX_PLAYERS];
new pAACTargetTimer[MAX_PLAYERS];
new NukeTimer[MAX_PLAYERS];

/*
 *
 *
//Sync
 *
 *
 */

new gOldWeaps[MAX_PLAYERS][13], gOldAmmo[MAX_PLAYERS][13], gOldSkin[MAX_PLAYERS], 
	gOldCol[MAX_PLAYERS], gOldInt[MAX_PLAYERS], gOldWorld[MAX_PLAYERS], Float: gOldPos[MAX_PLAYERS][4],
	gOldSpree[MAX_PLAYERS], gOldVID[MAX_PLAYERS], ForceSync[MAX_PLAYERS]
;

//Weapon/ammo data
new pWeaponData[MAX_PLAYERS][13];
new pAmmoData[MAX_PLAYERS][13];

/*
 *
 *
//Per-player textdraw definitions
 *
 *
 */

//Flashbang
new PlayerText: FlashTD[MAX_PLAYERS];

//PUBG textdraws
new PlayerText: PUBGBonusTD[MAX_PLAYERS];

//Used to show a player the details of a certain vehicle
new PlayerText: CarInfoPTD[MAX_PLAYERS][3];

//Player textdraws
new PlayerBar: Player_ProgressBar[MAX_PLAYERS];
new PlayerText: killedby[MAX_PLAYERS];
new PlayerText: deathbox[MAX_PLAYERS];
new PlayerText: killedtext[MAX_PLAYERS];
new PlayerText: killedbox[MAX_PLAYERS];
new PlayerText:	Notifier_PTD[MAX_PLAYERS];
new PlayerText: aSpecPTD[MAX_PLAYERS][3];
new PlayerText: Stats_PTD[MAX_PLAYERS][3];
new PlayerText: ProgressTD[MAX_PLAYERS];
new PlayerText: Stats_UIPTD[MAX_PLAYERS];

/*
 *
 *
//Player's rank system
 *
 *
 */

new PlayerRank[MAX_PLAYERS];
new Text3D: RankLabel[MAX_PLAYERS];

//VIP label text
new Text3D: VipLabel[MAX_PLAYERS];

/*
 *
 *
//Rope-rappelling system
 *
 *
 */

enum RopeData {
	RopeID[MAX_ROPES],
	Float: RRX,
	Float: RRY,
	Float: RRZ
};

new pRope[MAX_PLAYERS][RopeData], gRappelling[MAX_PLAYERS];

/*
 *
 *
//Player duel system
 *
 *
 */

enum playerDuelData {
	pDWeapon,
	pDAmmo,

	pDWeapon2,
	pDAmmo2,

	pDBetAmount,
	pDInMatch,
	pDLocked,

	pDMapId,
	pDRematchOpt,
	pDMatchesPlayed,
	pDCountDown,
	pDRCDuel,

	pDInvitePeriod
};

new pDuelInfo[MAX_PLAYERS][playerDuelData], TargetOf[MAX_PLAYERS];

/*
 *
 *
//Player bullet statistcs
 *
 *
 */

enum BulletData {
	Bullets_Hit,
	Bullets_Miss,
	Miss_Ratio,
	Last_Shot_MS,
	MS_Between_Shots,
	Group_Misses,
	Group_Hits,
	Last_Hit_MS,
	Float: Last_Hit_Distance,
	Float: Longest_Hit_Distance,
	Float: Shortest_Hit_Distance,
	Hits_Per_Miss,
	Misses_Per_Hit,
	Longest_Distance_Weapon,
	Aim_SameHMRate,
	Hits_Without_Aiming,
	Float: Bullet_Vectors[3],
	Highest_Hits,
	Highest_Misses
};

new BulletStats[MAX_PLAYERS][BulletData];

/*
 *
 *
//Player inventory system and items
 *
 *
 */

//Player items array
new pItems[MAX_PLAYERS][MAX_ITEMS];

//Inventory configuration and UI setup
new pItemList[MAX_ITEMS + 10][MAX_PLAYERS];
new pSlotList[MAX_ITEMS + 10][MAX_PLAYERS];

new bool: playerUsingMenu[MAX_PLAYERS];

enum {
	BACKGROUND = 0x18181890,
	LEFT_BACKGROUND = 0x29292990,
	RIGHT_BACKGROUND = 0x29292990,
	SELECTED = 0x4C4C4C90,
	FONT = 1
};

enum E_MENU_TEXTDRAW {
	E_MENU_TEXTDRAW_SCROLL_UP,
	E_MENU_TEXTDRAW_SCROLL_DOWN,
	E_MENU_TEXTDRAW_SCROLL,
	E_MENU_TEXTDRAW_LEFT_BOX[MAX_RIGHT_MENU_COLUMNS * MAX_RIGHT_MENU_ROWS],
	E_MENU_TEXTDRAW_LEFT_MODEL[MAX_RIGHT_MENU_COLUMNS * MAX_RIGHT_MENU_ROWS],
	E_MENU_TEXTDRAW_LEFT_TEXT[MAX_RIGHT_MENU_COLUMNS * MAX_RIGHT_MENU_ROWS],
	E_MENU_TEXTDRAW_RIGHT_MODEL[MAX_RIGHT_MENU_COLUMNS * MAX_RIGHT_MENU_ROWS],
	E_MENU_TEXTDRAW_RIGHT_NUMBER[MAX_RIGHT_MENU_COLUMNS * MAX_RIGHT_MENU_ROWS],
	E_MENU_TEXTDRAW_RIGHT_TEXT[MAX_RIGHT_MENU_COLUMNS * MAX_RIGHT_MENU_ROWS],
	E_MENU_TEXTDRAW_LEFT_COUNT,
	E_MENU_TEXTDRAW_RIGHT_COUNT,
	E_MENU_TEXTDRAW_LEFTBTN,
	E_MENU_TEXTDRAW_RIGHTBTN,
	E_MENU_TEXTDRAW_MIDDLEBTN,
	E_MENU_TEXTDRAW_CLOSE,
	E_MENU_TEXTDRAW_EMPTY_LEFT[2],
	E_MENU_TEXTDRAW_EMPTY_RIGHT[2]
};

new Text: menuTextDraw[MAX_MENU_TEXTDRAWS];
new menuTextDrawID[E_MENU_TEXTDRAW];
new menuTextDrawCount;

new PlayerText: menuPlayerTextDraw[MAX_PLAYERS][MAX_MENU_PLAYER_TEXTDRAWS];
new menuPlayerTextDrawID[MAX_PLAYERS][E_MENU_TEXTDRAW];
new menuPlayerTextDrawCount[MAX_PLAYERS];

new playerLeftMenuClickTickCount[MAX_PLAYERS][MAX_LEFT_MENU_ROWS];
new playerRightMenuClickTickCount[MAX_PLAYERS][MAX_ITEMS];

new nearbyItemsIdx[MAX_PLAYERS][MAX_SLOTS];
new nearbyItems[MAX_PLAYERS][MAX_SLOTS];
new nearbyItemsCount[MAX_PLAYERS];

new ownedItems[MAX_PLAYERS][MAX_ITEMS];
new ownedItemsCount[MAX_PLAYERS];

new playerLeftMenuPage[MAX_PLAYERS];
new playerLeftMenuListitem[MAX_PLAYERS];
new playerRightMenuListitem[MAX_PLAYERS];

/*
 *
 *
//Per-player event sync
 *
 *
 */

enum E_PLAYER_ENUM {
	P_TEAM,
	P_CP,
	P_RACETIME,
	P_CARTIMER
};

new pEventInfo[MAX_PLAYERS][E_PLAYER_ENUM];

/*
 *
 *
//Player selection systems system
 *
 *
 */

//Stores the player's team
new pTeam[MAX_PLAYERS];

//Player's skin
new pSkin[MAX_PLAYERS];

//Class selection
new pClass[MAX_PLAYERS];
new bool: pAdvancedClass[MAX_PLAYERS];

/*
 *
 *
//Player body toys sync and attached objects
 *
 *
 */

///////////////////////////////////////////
//Attached Objects

enum attached_object_data {
	Float:ao_x,
	Float:ao_y,
	Float:ao_z,
	Float:ao_rx,
	Float:ao_ry,
	Float:ao_rz,
	Float:ao_sx,
	Float:ao_sy,
	Float:ao_sz
};

new ao[MAX_PLAYERS][MAX_PLAYER_ATTACHED_OBJECTS][attached_object_data];

///////////////////////////////////////////

new gEditSlot[MAX_PLAYERS];
new gEditModel[MAX_PLAYERS];
new gModelsObj[MAX_PLAYERS][4];
new gModelsSlot[MAX_PLAYERS][4];
new gModelsPart[MAX_PLAYERS][4];
new gEditList[MAX_PLAYERS];

/*
 *
 *
//Miscellaneous
 *
 *
 */

//Interiors
new gIntCD[MAX_PLAYERS];

//Anti Rapid Fire
new stock
	pRapidFireTick			[MAX_PLAYERS],
	pRapidFireBullets		[MAX_PLAYERS char];

//Flashbang
new pFlashLvl[MAX_PLAYERS];

//Miscellaneous
new pSpawn[MAX_PLAYERS];
new pConnectDelay[MAX_PLAYERS];
new pClickedID[MAX_PLAYERS];
new gLastWeap[MAX_PLAYERS];
new pPickupCD[MAX_PLAYERS];
new gMedicTick[MAX_PLAYERS];
new pKillerCam[MAX_PLAYERS];
new pBackupRequested[MAX_PLAYERS];
new pBackupResponded[MAX_PLAYERS];
new gBackupHighlight[MAX_PLAYERS];
new pVehId[MAX_PLAYERS];
new Anti_Warn[MAX_PLAYERS];
new pHelmetAttached[MAX_PLAYERS];
new pMaskAttached[MAX_PLAYERS];
new pRaceCheck[MAX_PLAYERS];
new pStreak[MAX_PLAYERS];
new pIsDamaged[MAX_PLAYERS];
new AntiSK[MAX_PLAYERS];
new AntiSKStart[MAX_PLAYERS];
new rconAttempts[MAX_PLAYERS];
new pLastMessager[MAX_PLAYERS];
new IsPlayerUsingAnims[MAX_PLAYERS];
new IsPlayerAnimsPreloaded[MAX_PLAYERS];
new pCooldown[MAX_PLAYERS][43];
new pMinigunFires[MAX_PLAYERS];
new pFirstSpawn[MAX_PLAYERS];
new pStats[MAX_PLAYERS];
new pStatsID[MAX_PLAYERS];
new pShopDelay[MAX_PLAYERS];
new LastDamager[MAX_PLAYERS];
new LastTarget[MAX_PLAYERS];
new LastKilled[MAX_PLAYERS];

//Drone
new bool: InDrone[MAX_PLAYERS];
new Float: gDroneLastPos[MAX_PLAYERS][3];

//Pickup cooldown
new Last_Pickup[MAX_PLAYERS];
new Last_Pickup_Tick[MAX_PLAYERS];

//Check if a player isn't moving
new StaticPlayer[MAX_PLAYERS];

//Camouflage
new pCamo[MAX_PLAYERS];
new gCamoActivated[MAX_PLAYERS];
new gCamoTime[MAX_PLAYERS];

//Medkit
new Float: gMedicKitHP[MAX_PLAYERS];
new bool: gMedicKitStarted[MAX_PLAYERS];

//Clan
new pClan[MAX_PLAYERS] = -1;
new pClanRank[MAX_PLAYERS] = 0;

//Minigun Overheat
new gMGOverheat[MAX_PLAYERS] = 0;

//Incent fire
new gIncentFire[MAX_PLAYERS];

//Katana Insta-kill
new pKatanaEnhancement[MAX_PLAYERS];

//Clear object check
new bool: pIsWorldObjectsRemoved[MAX_PLAYERS] = false;

//Clan logger page
new cLoggerList[MAX_PLAYERS];

//Jetpack
new pJetpack[MAX_PLAYERS];

//Invisibility handling
new bool: gInvisible[MAX_PLAYERS] = false;
new gInvisibleTime[MAX_PLAYERS];

//Map Icons
new gModMapIcon[MAX_PLAYERS];

//Player session DM kills counter
new pDMKills[MAX_PLAYERS][sizeof(DMInfo)];

//Check whether player is using the watchroom feature
new bool: pWatching[MAX_PLAYERS];

//Check whether a player's report was checked or not
new bool: PlayerReportChecked[MAX_PLAYERS][MAX_REPORTS];

//Return the player's selected race from the list of races
new pRaceListItem[MAX_PLAYERS][20];

/*
 *
 *
//Iterators
 *
 *
 */

//PUBG event global iterator
new Iterator: PUBGPlayers<MAX_PLAYERS>;

//Clan war global iterators
new Iterator:CWCLAN1<MAX_PLAYERS>, Iterator:CWCLAN2<MAX_PLAYERS>;

//Events global iterator
new Iterator:ePlayers<MAX_PLAYERS>;

//Votekick requests
new pVotesKick[MAX_PLAYERS];
new bool: pVotedKick[MAX_PLAYERS][MAX_PLAYERS];
new pVoteKickCD[MAX_PLAYERS];

//End of File
/* (c) H2O Multiplayer 2018-2020. All rights reserved. */