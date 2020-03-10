/*
	SWAT vs Terrorists is a team death-match SA-MP game-mode script. 
	Compatible with SA-MP 0.3.7 and later releases.

	Author: H2O
	Licensed under GNU GPLv3

	(c) 2018-2020 H2O Multiplayer. All rights reserved.
	Website: h2omultiplayer.com
*/

#include <YSI_Players\y_text> //Y_Less
loadtext mode_text[all], mode_text[client], mode_text[newcs], mode_text[dialogs], mode_text[gametexts];

//Load gameplay data

forward LoadPlayerDataTable(playerid);
public LoadPlayerDataTable(playerid) {
	new query[128];

	if (cache_num_rows() > 0) {
		new Score, money;

		cache_get_value_int(0, "Score", Score);
		cache_get_value_int(0, "Cash", money);
		cache_get_value_int(0, "Kills", PlayerInfo[playerid][pKills]);
		cache_get_value_int(0, "Deaths", PlayerInfo[playerid][pDeaths]);
		cache_get_value_int(0, "GunFires", PlayerInfo[playerid][pGunFires]);
		cache_get_value_int(0, "IsJailed", PlayerInfo[playerid][pJailed]);
		cache_get_value_int(0, "JailTime", PlayerInfo[playerid][pJailTime]);
		cache_get_value_int(0, "ZonesCaptured", PlayerInfo[playerid][pZonesCaptured]);
		cache_get_value_int(0, "Headshots", PlayerInfo[playerid][pHeadshots]);
		cache_get_value_int(0, "KnifeKills", PlayerInfo[playerid][pKnifeKills]);
		cache_get_value_int(0, "Nutshots", PlayerInfo[playerid][pNutshots]);
		cache_get_value_int(0, "FavWeap", PlayerInfo[playerid][pFavWeap]);
		cache_get_value_int(0, "FavWeap2", PlayerInfo[playerid][pFavWeap2]);
		cache_get_value_int(0, "FavWeap3", PlayerInfo[playerid][pFavWeap3]);
		cache_get_value_int(0, "RevengeTakes", PlayerInfo[playerid][pRevengeTakes]);
		cache_get_value_int(0, "RustlerRockets", PlayerInfo[playerid][pRustlerRocketsFired]);
		cache_get_value_int(0, "RustlerRocketsHit", PlayerInfo[playerid][pRustlerRocketsHit]);
		cache_get_value_int(0, "DuelsWon", PlayerInfo[playerid][pDuelsWon]);
		cache_get_value_int(0, "DuelsLost", PlayerInfo[playerid][pDuelsLost]);
		cache_get_value_int(0, "MedkitsUsed", PlayerInfo[playerid][pMedkitsUsed]);
		cache_get_value_int(0, "ArmourkitsUsed", PlayerInfo[playerid][pArmourkitsUsed]);
		cache_get_value_int(0, "SupportAttempts", PlayerInfo[playerid][pSupportAttempts]);
		cache_get_value_int(0, "EXP", PlayerInfo[playerid][pEXPEarned]);
		cache_get_value_int(0, "KillAssists", PlayerInfo[playerid][pKillAssists]);
		cache_get_value_int(0, "CaptureAssists", PlayerInfo[playerid][pCapturAssists]);
		cache_get_value_int(0, "HighestKillStreak", PlayerInfo[playerid][pHighestKillStreak]);
		cache_get_value_int(0, "SawedKills", PlayerInfo[playerid][pSawnKills]);
		cache_get_value_int(0, "AirRocketsFired", PlayerInfo[playerid][pAirRocketsFired]);
		cache_get_value_int(0, "AntiAirRocketsFired", PlayerInfo[playerid][pAntiAirRocketsFired]);
		cache_get_value_int(0, "CarePackagesDropped", PlayerInfo[playerid][Carepacks]);
		cache_get_value_name_float(0, "HealthLost", PlayerInfo[playerid][pHealthLost]);
		cache_get_value_name_float(0, "DamageRate", PlayerInfo[playerid][pDamageRate]);
		cache_get_value_int(0, "SMGKills", PlayerInfo[playerid][pSMGKills]);
		cache_get_value_int(0, "PistolKills", PlayerInfo[playerid][pPistolKills]);
		cache_get_value_int(0, "MeleeKills", PlayerInfo[playerid][pMeleeKills]);
		cache_get_value_int(0, "ShotgunKills", PlayerInfo[playerid][pShotgunKills]);
		cache_get_value_int(0, "HeavyKills", PlayerInfo[playerid][pHeavyKills]);
		cache_get_value_int(0, "FistKills", PlayerInfo[playerid][pFistKills]);
		cache_get_value_int(0, "CloseKills", PlayerInfo[playerid][pCloseKills]);
		cache_get_value_int(0, "DriversStabbed", PlayerInfo[playerid][pDriversStabbed]);
		cache_get_value_int(0, "SpiesEliminated", PlayerInfo[playerid][pSpiesEliminated]);
		cache_get_value_int(0, "KillsAsSpy", PlayerInfo[playerid][pKillsAsSpy]);
		cache_get_value_int(0, "LongDistanceKills", PlayerInfo[playerid][pLongDistanceKills]);
		cache_get_value_int(0, "WeaponsDropped", PlayerInfo[playerid][pWeaponsDropped]);
		cache_get_value_int(0, "WeaponsPicked", PlayerInfo[playerid][pWeaponsPicked]);
		cache_get_value_int(0, "EventsWon", PlayerInfo[playerid][pEventsWon]);
		cache_get_value_int(0, "RacesWon", PlayerInfo[playerid][pRacesWon]);
		cache_get_value_int(0, "ItemsUsed", PlayerInfo[playerid][pItemsUsed]);
		cache_get_value_int(0, "FavSkin", PlayerInfo[playerid][pFavSkin]);
		cache_get_value_int(0, "FavTeam", PlayerInfo[playerid][pFavTeam]);
		cache_get_value_int(0, "SuicideAttempts", PlayerInfo[playerid][pSuicideAttempts]);
		cache_get_value_int(0, "PlayersHealed", PlayerInfo[playerid][pPlayersHealed]);
		cache_get_value_int(0, "CommandsUsed", PlayerInfo[playerid][pCommandsUsed]);
		cache_get_value_int(0, "CommandsFailed", PlayerInfo[playerid][pCommandsFailed]);
		cache_get_value_int(0, "UnauthorizedActions", PlayerInfo[playerid][pUnauthorizedActions]);
		cache_get_value_int(0, "RCONLogins", PlayerInfo[playerid][pRCONLogins]);
		cache_get_value_int(0, "RCONFailedAttempts", PlayerInfo[playerid][pRCONFailedAttempts]);
		cache_get_value_int(0, "ClassAbilitiesUsed", PlayerInfo[playerid][pClassAbilitiesUsed]);
		cache_get_value_int(0, "DronesExploded", PlayerInfo[playerid][pDronesExploded]);
		cache_get_value_name_float(0, "HealthGained", PlayerInfo[playerid][pHealthGained]);
		cache_get_value_int(0, "InteriorsEntered", PlayerInfo[playerid][pInteriorsEntered]);
		cache_get_value_int(0, "InteriorsExitted", PlayerInfo[playerid][pInteriorsExitted]);
		cache_get_value_int(0, "PickupsPicked", PlayerInfo[playerid][pPickupsPicked]);
		cache_get_value_int(0, "QuestionsAsked", PlayerInfo[playerid][pQuestionsAsked]);
		cache_get_value_int(0, "QuestionsAnswered", PlayerInfo[playerid][pQuestionsAnswered]);
		cache_get_value_int(0, "CrashTimes", PlayerInfo[playerid][pCrashTimes]);
		cache_get_value_int(0, "BackupAttempts", PlayerInfo[playerid][pBackupAttempts]);
		cache_get_value_int(0, "BackupsResponded", PlayerInfo[playerid][pBackupsResponded]);
		cache_get_value_int(0, "BaseRapeAttempts", PlayerInfo[playerid][pBaseRapeAttempts]);
		cache_get_value_int(0, "CBugAttempts", PlayerInfo[playerid][pCBugAttempts]);
		cache_get_value_int(0, "ChatMessagesSent", PlayerInfo[playerid][pChatMessagesSent]);
		cache_get_value_int(0, "MoneySent", PlayerInfo[playerid][pMoneySent]);
		cache_get_value_int(0, "MoneyReceived", PlayerInfo[playerid][pMoneyReceived]);
		cache_get_value_int(0, "HighestBet", PlayerInfo[playerid][pHighestBet]);
		cache_get_value_int(0, "DuelRequests", PlayerInfo[playerid][pDuelRequests]);
		cache_get_value_int(0, "DuelsAccepted", PlayerInfo[playerid][pDuelsAccepted]);
		cache_get_value_int(0, "DuelsRefusedByPlayer", PlayerInfo[playerid][pDuelsRefusedByPlayer]);
		cache_get_value_int(0, "DuelsRefusedByOthers", PlayerInfo[playerid][pDuelsRefusedByOthers]);
		cache_get_value_int(0, "BountyAmount", PlayerInfo[playerid][pBountyAmount]);
		cache_get_value_int(0, "BountyCashSpent", PlayerInfo[playerid][pBountyCashSpent]);
		cache_get_value_int(0, "CoinsSpent", PlayerInfo[playerid][pCoinsSpent]);
		cache_get_value_int(0, "PaymentsAccepted", PlayerInfo[playerid][pPaymentsAccepted]);
		cache_get_value_int(0, "ClanKills", PlayerInfo[playerid][pClanKills]);
		cache_get_value_int(0, "ClanDeaths", PlayerInfo[playerid][pClanDeaths]);
		cache_get_value_int(0, "HighestCaptures", PlayerInfo[playerid][pHighestCaptures]);
		cache_get_value_int(0, "KicksByAdmin", PlayerInfo[playerid][pKicksByAdmin]);
		cache_get_value_name_float(0, "LongestKillDistance", PlayerInfo[playerid][pLongestKillDistance]);
		cache_get_value_name_float(0, "NearestKillDistance", PlayerInfo[playerid][pNearestKillDistance]);
		cache_get_value_int(0, "HighestCaptureAssists", PlayerInfo[playerid][pHighestCaptureAssists]);
		cache_get_value_int(0, "HighestKillAssists", PlayerInfo[playerid][pHighestKillAssists]);
		cache_get_value_int(0, "BountyPlayersKilled", PlayerInfo[playerid][pBountyPlayersKilled]);
		cache_get_value_int(0, "PrototypesStolen", PlayerInfo[playerid][pPrototypesStolen]);
		cache_get_value_int(0, "AntennasDestroyed", PlayerInfo[playerid][pAntennasDestroyed]);
		cache_get_value_int(0, "CratesOpened", PlayerInfo[playerid][pCratesOpened]);
		cache_get_value_int(0, "LastPing", PlayerInfo[playerid][pLastPing]);
		cache_get_value_name_float(0, "LastPacketLoss", PlayerInfo[playerid][pLastPacketLoss]);
		cache_get_value_int(0, "HighestPing", PlayerInfo[playerid][pHighestPing]);
		cache_get_value_int(0, "LowestPing", PlayerInfo[playerid][pLowestPing]);
		cache_get_value_int(0, "NukesLaunched", PlayerInfo[playerid][pNukesLaunched]);
		cache_get_value_int(0, "AirstrikesCalled", PlayerInfo[playerid][pAirstrikesCalled]);
		cache_get_value_int(0, "AnthraxIntoxications", PlayerInfo[playerid][pAnthraxIntoxications]);
		cache_get_value_int(0, "PUBGEventsWon", PlayerInfo[playerid][pPUBGEventsWon]);
		cache_get_value_int(0, "RopeRappels", PlayerInfo[playerid][pRopeRappels]);
		cache_get_value_int(0, "AreasEntered", PlayerInfo[playerid][pAreasEntered]);
		cache_get_value_int(0, "LastAreaId", PlayerInfo[playerid][pLastAreaId]);
		cache_get_value_name_float(0, "LastPosX", PlayerInfo[playerid][pLastPosX]);
		cache_get_value_name_float(0, "LastPosY", PlayerInfo[playerid][pLastPosY]);
		cache_get_value_name_float(0, "LastPosZ", PlayerInfo[playerid][pLastPosZ]);
		cache_get_value_name_float(0, "LastHealth", PlayerInfo[playerid][pLastHealth]);
		cache_get_value_name_float(0, "LastArmour", PlayerInfo[playerid][pLastArmour]);
		cache_get_value_int(0, "TimeSpentOnFoot", PlayerInfo[playerid][pTimeSpentOnFoot]);
		cache_get_value_int(0, "TimeSpentInCar", PlayerInfo[playerid][pTimeSpentInCar]);
		cache_get_value_int(0, "TimeSpentAsPassenger", PlayerInfo[playerid][pTimeSpentAsPassenger]);
		cache_get_value_int(0, "TimeSpentInSelection", PlayerInfo[playerid][pTimeSpentInSelection]);
		cache_get_value_int(0, "TimeSpentAFK", PlayerInfo[playerid][pTimeSpentAFK]);
		cache_get_value_int(0, "DriveByKills", PlayerInfo[playerid][pDriveByKills]);
		cache_get_value_int(0, "CashAdded", PlayerInfo[playerid][pCashAdded]);
		cache_get_value_int(0, "CashReduced", PlayerInfo[playerid][pCashReduced]);
		cache_get_value_int(0, "LastInterior", PlayerInfo[playerid][pLastInterior]);
		cache_get_value_int(0, "LastVirtualWorld", PlayerInfo[playerid][pLastVirtualWorld]);
		
		SetPlayerScore(playerid, Score);
		PlayerRank[playerid] = GetPlayerRank(playerid);

		ResetPlayerCash(playerid);
		pMoney[playerid] = money;
		GivePlayerMoney(playerid, money);
	} else {
		mysql_format(Database, query, sizeof(query), "INSERT INTO `PlayersData` (`pID`) VALUES('%d')", PlayerInfo[playerid][pAccountId]);
		mysql_tquery(Database, query);
		SetPlayerScore(playerid, 0);
		PlayerRank[playerid] = GetPlayerRank(playerid);
		ResetPlayerCash(playerid);
	}	
	return 1;
}

//Load player configuration

forward LoadPlayerConfiguration(playerid);
public LoadPlayerConfiguration(playerid) {
	if (cache_num_rows() > 0) {
		cache_get_value_int(0, "DoNotDisturb", PlayerInfo[playerid][pDoNotDisturb]);
		cache_get_value_int(0, "NoDuel", PlayerInfo[playerid][pNoDuel]);
		cache_get_value_int(0, "HitIndicator", PlayerInfo[playerid][pHitIndicatorEnabled]);
		cache_get_value_int(0, "GUIEnabled", PlayerInfo[playerid][pGUIEnabled]);
		cache_get_value_int(0, "SpawnKillTime", PlayerInfo[playerid][pSpawnKillTime]);
	} else {
		new query[100];

		mysql_format(Database, query, sizeof(query), "INSERT INTO `PlayersConf` (`pID`) VALUES ('%d')", PlayerInfo[playerid][pAccountId]);
		mysql_tquery(Database, query);
		
		PlayerInfo[playerid][pDoNotDisturb] =
		PlayerInfo[playerid][pNoDuel] = 0;
		
		PlayerInfo[playerid][pHitIndicatorEnabled] =
		PlayerInfo[playerid][pGUIEnabled] = 1;
		PlayerInfo[playerid][pSpawnKillTime] = 15;
	}
	return 1;
}

//Fetch player's old name if/any
forward GetPreviousName(playerid);
public GetPreviousName(playerid) {
	if (cache_num_rows() != 0) {
		cache_get_value(cache_num_rows() - 1, "OldName", PlayerInfo[playerid][pPrevName], MAX_PLAYER_NAME);
	}    
	return 1;
}

//Load player data
LoginPlayer(playerid) {
	cache_set_active(PlayerInfo[playerid][pCacheId]);
	cache_get_value_int(0, "ID", PlayerInfo[playerid][pAccountId]);
	cache_get_value_int(0, "AdminLevel", PlayerInfo[playerid][pAdminLevel]);
	cache_get_value_int(0, "IsModerator", PlayerInfo[playerid][pIsModerator]);
	cache_get_value_int(0, "DonorLevel", PlayerInfo[playerid][pDonorLevel]);
	cache_get_value_name_float(0, "Coins", PlayerInfo[playerid][pCoins]);
	cache_get_value_int(0, "ClanId", pClan[playerid]);
	cache_get_value_int(0, "ClanRank", pClanRank[playerid]);
	cache_get_value_int(0, "PlayTime", PlayerInfo[playerid][pTimePlayed]);
	cache_get_value_int(0, "RegDate", PlayerInfo[playerid][pRegDate]);
	cache_get_value_int(0, "LastVisit", PlayerInfo[playerid][pLastVisit]);
	cache_get_value_int(0, "TimesLoggedIn", PlayerInfo[playerid][pTimesLoggedIn]);
	cache_get_value_int(0, "Warnings", PlayerInfo[playerid][pAccountWarnings]);
	cache_get_value_int(0, "AntiCheatWarnings", PlayerInfo[playerid][pAntiCheatWarnings]);
	cache_get_value_int(0, "PlayerReports", PlayerInfo[playerid][pPlayerReports]);
	cache_get_value_int(0, "SpamAttempts", PlayerInfo[playerid][pSpamAttempts]);
	cache_get_value_int(0, "AdvAttempts", PlayerInfo[playerid][pAdvAttempts]);
	cache_get_value_int(0, "AntiSwearBlocks", PlayerInfo[playerid][pAntiSwearBlocks]);
	cache_get_value_int(0, "TagPermitted", PlayerInfo[playerid][pTagPermitted]);
	cache_get_value_int(0, "ReportAttempts", PlayerInfo[playerid][pReportAttempts]);
	cache_get_value_int(0, "BannedTimes", PlayerInfo[playerid][pBannedTimes]);
	cache_get_value_int(0, "BannedTimes", PlayerInfo[playerid][pBannedTimes]);
	cache_get_value_name(0, "EmailAddress", PlayerInfo[playerid][pEmailAddress], 65);
	cache_get_value_name_bool(0, "EmailVerified", PlayerInfo[playerid][pEmailVerified]);
	cache_get_value_name_bool(0, "TFA", PlayerInfo[playerid][pTFA]);
	cache_get_value_int(0, "EmailAttempts", PlayerInfo[playerid][pEmailAttempts]);
	cache_get_value_name(0, "SupportKey", PlayerInfo[playerid][pSupportKey], 10);

	if (PlayerInfo[playerid][pAdminLevel]) {
		pIsAdmin[playerid] = true;
	} else {
		pIsAdmin[playerid] = false;
	}

	format(PlayerInfo[playerid][pPassword], 65, "");

	Update3DTextLabelText(RankLabel[playerid], 0xFFFFFFFF, " ");

	new query[240];

	mysql_format(Database, query, sizeof(query),
	"SELECT * FROM `PlayersData` WHERE `pID` = '%d'", PlayerInfo[playerid][pAccountId]);
	mysql_tquery(Database, query, "LoadPlayerDataTable", "i", playerid);


	mysql_format(Database, query, sizeof(query),
	"SELECT * FROM `PlayersConf` WHERE `pID` = '%d'", PlayerInfo[playerid][pAccountId]);
	mysql_tquery(Database, query, "LoadPlayerConfiguration", "i", playerid);  	

	cache_delete(PlayerInfo[playerid][pCacheId]);
	PlayerInfo[playerid][pCacheId] = MYSQL_INVALID_CACHE;

	Text_Send(playerid, $CLIENT_153x);

	if (PlayerInfo[playerid][pAdminLevel] || PlayerInfo[playerid][pIsModerator]) {
		new DCC_Channel:StaffChannel;
		StaffChannel = DCC_FindChannelByName(CHANNEL_STAFF_NAME);

		new String[128];
		format(String, sizeof(String), "%s has joined the game.", PlayerInfo[playerid][PlayerName]);
		DCC_SendChannelMessage(StaffChannel, String);
	}

	PlayerInfo[playerid][pLoggedIn] = 1;
	OnPlayerRequestClass(playerid, 0);

	if (!PlayerInfo[playerid][pAdminLevel] && !PlayerInfo[playerid][pIsModerator] &&
			!PlayerInfo[playerid][pTagPermitted] &&
			strfind(PlayerInfo[playerid][PlayerName], "[SvT]", true) != -1) {
		Text_Send(playerid, $CLIENT_154x);
		return SetTimerEx("ApplyBan", 500, false, "i", playerid);
	}

	Dialog_Show(playerid, DIALOG_STYLE_MSGBOX, "Current Release: "BUILD"", 
		"- Removed the achievements system with plans to implement a new one in the future.\n\
		- Removed the daily missions due to being disliked by majority of players.\n\
		- Removed the random bonus zone/player.\n\
		- Removed body toys and weapon laser.\n\
		- Added a globally synced time cycle instead of the previous per-player one.\n\
		- Added a globally synced automated weather changer.\n\
		- Updated class score and EXP requirements.\n\
		- Added more abilities to classes (and removed them from ranks).\n\
		- Limited heavy air vehicles to pilot class.\n\
		- Limited AAC to supporter class.\n\
		- Limited Submarines to Scout class.\n\
		- Made Submarines inflict actual damage.\n\
		- Fastened rockets thrown by an AAC.\n\
		- Global messages will now be red in color while per-player messages will be white.\n\
		- Players who use 2FA will now receive a new security code by email every login.\n\
		- Invisibility off the radar will no longer be effective out of the battlefield.\n\
		- Fixed the ...DEAD... appearing on players who lose a duel match and respawn in the rematch mode.\n\
		- I remember adding more aummnition to Sniper for the Sniper class? Check it out.\n\
		- Radio antennas will now take damage by dynamites only.\n\
		"RED2"- Introducing /votekick [player id] - use it wisely!", "X");
	return true;
}

//End of File
/* (c) H2O Multiplayer 2018-2020. All rights reserved. */