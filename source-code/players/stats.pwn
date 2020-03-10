/*
	SWAT vs Terrorists is a team death-match SA-MP game-mode script. 
	Compatible with SA-MP 0.3.7 and later releases.

	Author: H2O
	Licensed under GNU GPLv3

	(c) 2018-2020 H2O Multiplayer. All rights reserved.
	Website: h2omultiplayer.com

	Stuff related to stats handling
*/

#include <YSI_Coding\y_hooks>

//Support for y_text, load language files...
#include <YSI_Players\y_text> //Y_Less
loadtext mode_text[all], mode_text[client], mode_text[newcs], mode_text[dialogs], mode_text[gametexts];

//Player Stats

//For /stats command
UpdatePlayerStatsList(playerid, targetid) {
	new Left_Side[256], Right_Side[256];

	switch (pStats[playerid]) {
		case 0: {
			strcat(Left_Side, "~r~GENERAL INFO~n~~n~~w~");

			format(Left_Side, sizeof(Left_Side), 
				"%sScore: %d~n~Money: $%d~n~EXP: %d~n~VIP Coins: %0.2f~n~AKA: %s", Left_Side,
				GetPlayerScore(targetid), GetPlayerCash(targetid), PlayerInfo[targetid][pEXPEarned], PlayerInfo[targetid][pCoins], 
				PlayerInfo[targetid][pPrevName]);

			new d, h, m, s;
			CountPlayedTime(targetid, d, h, m, s);	
			format(Right_Side, sizeof(Right_Side), "Played Time: %dd %dh %dm %ds~n~", d, h, m, s);
			format(Right_Side, sizeof(Right_Side), "%sRegistered %s~n~", Right_Side, GetWhen(PlayerInfo[targetid][pRegDate], gettime()));
			if (IsPlayerInAnyClan(targetid)) {
				format(Right_Side, sizeof(Right_Side), "%sClan: %s~n~Clan Rank: %s[%d]", 
					Right_Side, GetPlayerClan(targetid), GetPlayerClanRankName(targetid), GetPlayerClanRank(targetid));
			}
		}
		case 1: {
			strcat(Left_Side, "~r~GAMEPLAY STATS~n~~n~~w~");

			if (playerid != targetid && PlayerInfo[targetid][pIsSpying] && PlayerInfo[targetid][pSpyTeam] == pTeam[playerid]) {
				format(Left_Side, sizeof(Left_Side), "%sRank: %s~n~", Left_Side, RankInfo[PlayerRank[targetid]][Rank_Name]);
			} else {
				if (!pAdvancedClass[targetid]) {
					format(Left_Side, sizeof(Left_Side), "%sRank: %s~n~Team: %s~n~Class: %s~n~", Left_Side, RankInfo[PlayerRank[targetid]][Rank_Name],
						TeamInfo[pTeam[targetid]][Team_Name], ClassInfo[pClass[targetid]][Class_Name]);
				} else {
					format(Left_Side, sizeof(Left_Side), "%sRank: %s~n~Team: %s~n~Class: %s~n~", Left_Side, RankInfo[PlayerRank[targetid]][Rank_Name],
						TeamInfo[pTeam[targetid]][Team_Name], ClassInfo[pClass[targetid]][aClass_Name]);
				}	
			}
			format(Left_Side, sizeof(Left_Side), "%sPlayers Supported: %d", Left_Side, PlayerInfo[targetid][pSupportAttempts]);

			new Float:KDR = 0.0;
			if (PlayerInfo[targetid][pKills] && PlayerInfo[targetid][pDeaths]) {
				KDR = floatdiv(PlayerInfo[targetid][pKills], PlayerInfo[targetid][pDeaths]);
			}

			format(Right_Side, sizeof(Right_Side), "Kills: %d~n~DM Kills: %d~n~Deaths: %d~n~Suicides: %d~n~K/D Ratio: %0.2f",
				PlayerInfo[targetid][pKills], PlayerInfo[targetid][pDeathmatchKills], PlayerInfo[targetid][pDeaths], PlayerInfo[targetid][pSuicideAttempts], KDR);
		}
		case 2: {
			strcat(Left_Side, "~r~GAMEPLAY STATS (2)~n~~n~~w~");

			new Float: ACC = 0.0;
			if (PlayerInfo[playerid][pKills] && PlayerInfo[playerid][pGunFires]) {
				ACC = floatdiv(PlayerInfo[targetid][pKills], PlayerInfo[targetid][pGunFires]);
			}
			format(Left_Side, sizeof(Left_Side), "%sK/S Accuracy: %0.2f~n~Kill Spree: %d~n~Headshots: %d~n~Headshot Streak: %d", Left_Side, ACC,
				pStreak[targetid], PlayerInfo[targetid][pHeadshots], PlayerInfo[targetid][pHeadshotStreak]);	

			format(Right_Side, sizeof(Right_Side), "Most Kills: %d~n~Nutshots: %d~n~Kill Assists: %d~n~Most Kill Assists: %d~n~Revenges Taken: %d",
				PlayerInfo[targetid][pHighestKillStreak], PlayerInfo[targetid][pNutshots], PlayerInfo[targetid][pKillAssists], PlayerInfo[targetid][pHighestKillAssists],
				PlayerInfo[targetid][pRevengeTakes]);		
		}
		case 3: {
			strcat(Left_Side, "~r~GAMEPLAY STATS (3)~n~~n~~w~");

			format(Left_Side, sizeof(Left_Side), "%sKnife Kills: %d~n~Sawn Kills: %d~n~Zones Captured: %d~n~Capturing Streak: %d", Left_Side,
				PlayerInfo[targetid][pKnifeKills], PlayerInfo[targetid][pSawnKills], PlayerInfo[targetid][pZonesCaptured], PlayerInfo[targetid][pCaptureStreak]);
			
			format(Right_Side, sizeof(Right_Side), "Carepacks Dropped: %d",
				PlayerInfo[targetid][Carepacks]);
		}
		case 4: {
			strcat(Left_Side, "~r~GAMEPLAY STATS (4)~n~~n~~w~");

			format(Left_Side, sizeof(Left_Side), "%sFist Kills: %d~n~Melee Kills: %d~n~Pistol Kills: %d~n~SMG Kills: %d", Left_Side,
				PlayerInfo[targetid][pFistKills], PlayerInfo[targetid][pMeleeKills], PlayerInfo[targetid][pPistolKills], PlayerInfo[targetid][pSMGKills]);
			
			format(Right_Side, sizeof(Right_Side), "Shotgun Kills: %d~n~Heavy Kills: %d",
				PlayerInfo[targetid][pShotgunKills], PlayerInfo[targetid][pHeavyKills]);
		}
		case 5: {
			strcat(Left_Side, "~r~GAMEPLAY STATS (5)~n~~n~~w~");

			format(Left_Side, sizeof(Left_Side), "%sClose Kills: %d~n~Health Lost: %0.2f~n~Damage Rate: %0.2f~n~Far Kills: %d", Left_Side,
				PlayerInfo[targetid][pCloseKills], PlayerInfo[targetid][pHealthLost], PlayerInfo[targetid][pDamageRate], PlayerInfo[targetid][pLongDistanceKills]);
			
			format(Right_Side, sizeof(Right_Side), "Drivers Stabbed: %d~n~Spies Killed: %d~n~Kills As Spy: %d",
				PlayerInfo[targetid][pDriversStabbed], PlayerInfo[targetid][pSpiesEliminated], PlayerInfo[targetid][pKillsAsSpy]);
		}
		case 6: {
			strcat(Left_Side, "~r~GAMEPLAY STATS (6)~n~~n~~w~");

			format(Left_Side, sizeof(Left_Side), "%sWeapons Dropped: %d~n~Weapons Picked: %d~n~Events Won: %d~n~Races Won: %d", Left_Side,
				PlayerInfo[targetid][pWeaponsDropped], PlayerInfo[targetid][pWeaponsPicked], PlayerInfo[targetid][pEventsWon], PlayerInfo[targetid][pRacesWon]);
			
			format(Right_Side, sizeof(Right_Side), "Items Used: %d~n~Players Healed: %d~n~Commands Used: %d~n~Class Abilities Used: %d",
				PlayerInfo[targetid][pItemsUsed], PlayerInfo[targetid][pPlayersHealed], PlayerInfo[targetid][pCommandsUsed], PlayerInfo[targetid][pClassAbilitiesUsed]);
		}
		case 7: {
			strcat(Left_Side, "~r~GAMEPLAY STATS (7)~n~~n~~w~");

			format(Left_Side, sizeof(Left_Side), "%sDrones Exploded: %d~n~Health Gained: %0.2f~n~Zones Captured: %d~n~Backup Attempts: %d", Left_Side,
				PlayerInfo[targetid][pDronesExploded], PlayerInfo[targetid][pHealthGained], PlayerInfo[targetid][pZonesCaptured], PlayerInfo[targetid][pBackupAttempts]);
			
			format(Right_Side, sizeof(Right_Side), "Backups Responed: %d~n~Highest Bet: %d~n~Bounty On Head: %d~n~Bounty Spent: %d",
				PlayerInfo[targetid][pBackupsResponded], PlayerInfo[targetid][pHighestBet], PlayerInfo[targetid][pBountyAmount], PlayerInfo[targetid][pBountyCashSpent]);
		}
		case 8: {
			strcat(Left_Side, "~r~GAMEPLAY STATS (8)~n~~n~~w~");

			format(Left_Side, sizeof(Left_Side), "%sCapture Streak: %d~n~Most Cap-Assists: %d~n~Clan Kills: %d~n~Clan Deaths: %d", Left_Side,
				PlayerInfo[targetid][pCaptureStreak], PlayerInfo[targetid][pHighestCaptureAssists], PlayerInfo[targetid][pClanKills], PlayerInfo[targetid][pClanDeaths]);
			
			format(Right_Side, sizeof(Right_Side), "Bounties Hit: %d~n~Longest Kill Distance: %0.2f~n~Nearest Kill Distance: %0.2f",
				PlayerInfo[targetid][pBountyPlayersKilled], PlayerInfo[targetid][pLongestKillDistance], PlayerInfo[targetid][pNearestKillDistance]);
		}
		case 9: {
			strcat(Left_Side, "~r~GAMEPLAY STATS (9)~n~~n~~w~");

			format(Left_Side, sizeof(Left_Side), "%sPrototypes Stolen: %d~n~Antennas Destroyed: %d~n~Crates Opened: %d", Left_Side,
				PlayerInfo[targetid][pPrototypesStolen], PlayerInfo[targetid][pAntennasDestroyed], PlayerInfo[targetid][pCratesOpened]);
			
			format(Right_Side, sizeof(Right_Side), "Nukes Launched: %d~n~Airstrike Calls: %d~n~Flashbanged Players: %d~n~Anthrax Intoxications: %d",
				PlayerInfo[targetid][pNukesLaunched], PlayerInfo[targetid][pAirstrikesCalled], PlayerInfo[targetid][pFlashBangedPlayers], PlayerInfo[targetid][pAnthraxIntoxications]);
		}
		case 10: {
			strcat(Left_Side, "~r~GAMEPLAY STATS (10)~n~~n~~w~");

			format(Left_Side, sizeof(Left_Side), "%sPUBG Events Won: %d~n~Rope Rappels: %d~n~Drive-by Kills: %d", Left_Side,
				PlayerInfo[targetid][pPUBGEventsWon], PlayerInfo[targetid][pRopeRappels], PlayerInfo[targetid][pDriveByKills]);
			
			format(Right_Side, sizeof(Right_Side), "Time Spent On Foot: %ds~n~Time Spent In Car: %ds~n~Time Spent AFK: %ds",
				PlayerInfo[targetid][pTimeSpentOnFoot], PlayerInfo[targetid][pTimeSpentInCar], PlayerInfo[targetid][pTimeSpentAFK]);
		}
		case 11: {
			strcat(Left_Side, "~r~GAMEPLAY STATS (11)~n~~n~~w~");

			format(Left_Side, sizeof(Left_Side), "%sMedkits Used: %d~n~Armourkits Used: %d~n~Pilot License: %s", Left_Side,
				PlayerInfo[targetid][pMedkitsUsed], PlayerInfo[targetid][pArmourkitsUsed], (pItems[targetid][PL] == 1) ? ("Yes") : ("No"));

			new Float:WLR = 0.0;
			if (PlayerInfo[targetid][pDuelsWon] && PlayerInfo[targetid][pDuelsLost]) {
			 	WLR = floatdiv(PlayerInfo[targetid][pDuelsWon], PlayerInfo[targetid][pDuelsLost]);
			}

			format(Right_Side, sizeof(Right_Side), "Duels Played: %d~n~Duels Won: %d~n~Duels Lost: %d~n~W/L Ratio: %0.2f",
				PlayerInfo[targetid][pDuelsWon] + PlayerInfo[targetid][pDuelsLost], PlayerInfo[targetid][pDuelsWon], PlayerInfo[targetid][pDuelsLost], WLR);
		}
		case 12: {
			strcat(Left_Side, "~r~GAMEPLAY STATS (12)~n~~n~~w~");

			format(Left_Side, sizeof(Left_Side), "%sAir Rockets Dropped: %d~n~Anti Air Rockets Fired: %d~n~Rustler Rockets Dropped: %d~n~Rustler Rockets Hit: %d", Left_Side,
				PlayerInfo[targetid][pAirRocketsFired], PlayerInfo[targetid][pAntiAirRocketsFired], PlayerInfo[targetid][pRustlerRocketsFired], PlayerInfo[targetid][pRustlerRocketsHit]);
		}
		case 13: {
			strcat(Left_Side, "~r~SESSION STATS~n~~n~~w~");

			format(Left_Side, sizeof(Left_Side), "%sKills: %d~n~Deaths: %d~n~Revenges Taken: %d~n~Kill Assists: %d", Left_Side,
				PlayerInfo[targetid][pSessionKills], PlayerInfo[targetid][pSessionDeaths], PlayerInfo[targetid][sRevenges], 
				PlayerInfo[targetid][sAssistkills]);

			format(Right_Side, sizeof(Right_Side), "DM Kills: %d~n~Events Won: %d~n~Races Won: %d~n~", 
				PlayerInfo[targetid][sDMKills], PlayerInfo[targetid][sRaces], PlayerInfo[targetid][sEvents]);
		}
		default: {
			strcat(Left_Side, "~r~SESSION STATS (2)~n~~n~~w~");

			format(Left_Side, sizeof(Left_Side), "%sKills As Spy: %d~n~Spies Eliminated: %d~n~Knife Kills: %d~n~Teargas Kills: %d", Left_Side,
				PlayerInfo[targetid][sDisguisedKills], PlayerInfo[targetid][sSpiesKilled],
				PlayerInfo[targetid][sKnives], PlayerInfo[targetid][sGasKills]);
		}
	}

	PlayerTextDrawSetString(playerid, Stats_PTD[playerid][1], Left_Side);
	PlayerTextDrawSetString(playerid, Stats_PTD[playerid][2], Right_Side);
	return 1;
}

//Save one player's stats
SavePlayerStats(playerid) {
	new pgpci[41];
	gpci(playerid, pgpci, sizeof(pgpci));

	new query[2048];

	PlayerInfo[playerid][pTimesLoggedIn] ++;

	mysql_format(Database, query, sizeof(query), "UPDATE `Players` SET AdminLevel = '%d', IsModerator = '%d', LastVisit = '%d', ClanId = '%d', \
		ClanRank = '%d', Coins = '%f', PlayTime = '%d', GPCI = '%e', TFA = '%d', IP = '%e', TimesLoggedIn = '%d', Warnings = '%d', AntiCheatWarnings = '%d', \
		PlayerReports = '%d', SpamAttempts = '%d', AdvAttempts = '%d', AntiSwearBlocks = '%d', TagPermitted = '%d', ReportAttempts = '%d', BannedTimes = '%d' WHERE ID = '%d' LIMIT 1",
	PlayerInfo[playerid][pAdminLevel], PlayerInfo[playerid][pIsModerator],
	gettime(), pClan[playerid], pClanRank[playerid], PlayerInfo[playerid][pCoins], PlayerInfo[playerid][pTimePlayed], pgpci,
	PlayerInfo[playerid][pTFA], PlayerInfo[playerid][pIP], PlayerInfo[playerid][pTimesLoggedIn], PlayerInfo[playerid][pAccountWarnings],
	PlayerInfo[playerid][pAntiCheatWarnings], PlayerInfo[playerid][pPlayerReports], PlayerInfo[playerid][pSpamAttempts], PlayerInfo[playerid][pAdvAttempts],
	PlayerInfo[playerid][pAntiSwearBlocks], PlayerInfo[playerid][pTagPermitted], PlayerInfo[playerid][pReportAttempts], PlayerInfo[playerid][pBannedTimes],
	PlayerInfo[playerid][pAccountId]);
	mysql_tquery(Database, query);

	new Float: X, Float: Y, Float: Z;
	GetPlayerPos(playerid, X, Y, Z);

	new Float: Health, Float: Armour;
	GetPlayerHealth(playerid, Health);
	GetPlayerArmour(playerid, Armour);

	mysql_format(Database, query, sizeof(query), "UPDATE `PlayersData` SET Score = '%d', Cash = '%d', Kills = '%d', Deaths = '%d', GunFires = '%d', IsJailed = '%d', JailTime = '%d', \
		Headshots = '%d', Nutshots = '%d', FavWeap = '%d', FavWeap2 = '%d', FavWeap3 = '%d', KnifeKills = '%d', \
		RevengeTakes = '%d', ZonesCaptured = '%d', DeathmatchKills = '%d', RustlerRockets = '%d', RustlerRocketsHit = '%d', DuelsWon = '%d', DuelsLost = '%d', \
		MedkitsUsed = '%d', ArmourkitsUsed = '%d', SupportAttempts = '%d', EXP = '%d', KillAssists = '%d', CaptureAssists = '%d', HighestKillStreak = '%d', \
		SawedKills = '%d', AirRocketsFired = '%d', AntiAirRocketsFired = '%d', CarePackagesDropped = '%d', HealthLost = '%f', DamageRate = '%f', \
		SMGKills = '%d', ShotgunKills = '%d', HeavyKills = '%d', FistKills = '%d', CloseKills = '%d', DriversStabbed = '%d' WHERE pID = '%d' LIMIT 1",
	GetPlayerScore(playerid), GetPlayerCash(playerid), PlayerInfo[playerid][pKills], PlayerInfo[playerid][pDeaths], PlayerInfo[playerid][pGunFires], PlayerInfo[playerid][pJailed],
	PlayerInfo[playerid][pJailTime], PlayerInfo[playerid][pHeadshots], PlayerInfo[playerid][pNutshots], PlayerInfo[playerid][pFavWeap], 
	PlayerInfo[playerid][pFavWeap2], PlayerInfo[playerid][pFavWeap3], PlayerInfo[playerid][pKnifeKills], PlayerInfo[playerid][pRevengeTakes], PlayerInfo[playerid][pZonesCaptured],
	PlayerInfo[playerid][pDeathmatchKills], PlayerInfo[playerid][pRustlerRocketsFired], PlayerInfo[playerid][pRustlerRocketsHit],
	PlayerInfo[playerid][pDuelsWon], PlayerInfo[playerid][pDuelsLost], PlayerInfo[playerid][pMedkitsUsed], PlayerInfo[playerid][pArmourkitsUsed],
	PlayerInfo[playerid][pSupportAttempts], PlayerInfo[playerid][pEXPEarned], PlayerInfo[playerid][pKillAssists], PlayerInfo[playerid][pCapturAssists], PlayerInfo[playerid][pHighestKillStreak],
	PlayerInfo[playerid][pSawnKills], PlayerInfo[playerid][pAirRocketsFired], PlayerInfo[playerid][pAntiAirRocketsFired], PlayerInfo[playerid][Carepacks],
	PlayerInfo[playerid][pHealthLost], PlayerInfo[playerid][pDamageRate], PlayerInfo[playerid][pSMGKills], PlayerInfo[playerid][pShotgunKills],
	PlayerInfo[playerid][pHeavyKills], PlayerInfo[playerid][pFistKills], PlayerInfo[playerid][pCloseKills], PlayerInfo[playerid][pDriversStabbed], PlayerInfo[playerid][pAccountId]);
	mysql_tquery(Database, query);

	mysql_format(Database, query, sizeof(query), "UPDATE `PlayersData` SET SpiesEliminated = '%d', KillsAsSpy = '%d', LongDistanceKills = '%d', \
		WeaponsDropped = '%d', WeaponsPicked = '%d', EventsWon = '%d', RacesWon = '%d', \
		ItemsUsed = '%d', FavSkin = '%d', FavTeam = '%d', SuicideAttempts = '%d', PlayersHealed = '%d', CommandsUsed = '%d', CommandsFailed = '%d', \
		UnauthorizedActions = '%d', RCONLogins = '%d', RCONFailedAttempts = '%d', ClassAbilitiesUsed = '%d', DronesExploded = '%d', \
		HealthGained = '%f', InteriorsEntered = '%d', InteriorsExitted = '%d', PickupsPicked = '%d' WHERE pID = '%d' LIMIT 1",
	PlayerInfo[playerid][pSpiesEliminated], PlayerInfo[playerid][pKillsAsSpy], PlayerInfo[playerid][pLongDistanceKills], PlayerInfo[playerid][pWeaponsDropped],
	PlayerInfo[playerid][pWeaponsPicked], PlayerInfo[playerid][pEventsWon], PlayerInfo[playerid][pRacesWon],
	PlayerInfo[playerid][pItemsUsed], GetPlayerSkin(playerid), pTeam[playerid], PlayerInfo[playerid][pSuicideAttempts],
	PlayerInfo[playerid][pPlayersHealed], PlayerInfo[playerid][pCommandsUsed], PlayerInfo[playerid][pCommandsFailed],
	PlayerInfo[playerid][pUnauthorizedActions], PlayerInfo[playerid][pRCONLogins], PlayerInfo[playerid][pRCONFailedAttempts],
	PlayerInfo[playerid][pClassAbilitiesUsed], PlayerInfo[playerid][pDronesExploded], PlayerInfo[playerid][pHealthGained],
	PlayerInfo[playerid][pInteriorsEntered], PlayerInfo[playerid][pInteriorsExitted], PlayerInfo[playerid][pPickupsPicked],
	PlayerInfo[playerid][pAccountId]);
	mysql_tquery(Database, query);

	mysql_format(Database, query, sizeof(query), "UPDATE `PlayersData` SET QuestionsAsked = '%d', QuestionsAnswered = '%d', CrashTimes = '%d', SAMPClient = '%e', BackupAttempts = '%d', \
		BackupsResponded = '%d', BaseRapeAttempts = '%d', CBugAttempts = '%d', ChatMessagesSent = '%d', \
		MoneySent = '%d', MoneyReceived = '%d', HighestBet = '%d', DuelRequests = '%d', DuelsAccepted = '%d', \
		DuelsRefusedByPlayer = '%d', DuelsRefusedByOthers = '%d', BountyAmount = '%d', BountyCashSpent = '%d', CoinsSpent = '%d', \
		PaymentsAccepted = '%d', ClanKills = '%d', ClanDeaths = '%d', HighestCaptures = '%d', \
		KicksByAdmin = '%d', LongestKillDistance = '%f', NearestKillDistance = '%f', \
		HighestCaptureAssists = '%d', HighestKillAssists = '%d', BountyPlayersKilled = '%d', \
		PrototypesStolen = '%d', AntennasDestroyed = '%d', CratesOpened = '%d' WHERE pID = '%d' LIMIT 1", 
	PlayerInfo[playerid][pQuestionsAsked], PlayerInfo[playerid][pQuestionsAnswered],
	PlayerInfo[playerid][pCrashTimes], PlayerInfo[playerid][pSAMPClient], PlayerInfo[playerid][pBackupAttempts],
	PlayerInfo[playerid][pBackupsResponded], PlayerInfo[playerid][pBaseRapeAttempts], PlayerInfo[playerid][pCBugAttempts],
	PlayerInfo[playerid][pChatMessagesSent], PlayerInfo[playerid][pMoneySent], PlayerInfo[playerid][pMoneyReceived],
	PlayerInfo[playerid][pHighestBet], PlayerInfo[playerid][pDuelRequests], PlayerInfo[playerid][pDuelsAccepted],
	PlayerInfo[playerid][pDuelsRefusedByPlayer], PlayerInfo[playerid][pDuelsRefusedByOthers], PlayerInfo[playerid][pBountyAmount],
	PlayerInfo[playerid][pBountyCashSpent], PlayerInfo[playerid][pCoinsSpent], PlayerInfo[playerid][pPaymentsAccepted],
	PlayerInfo[playerid][pClanKills], PlayerInfo[playerid][pClanDeaths], PlayerInfo[playerid][pHighestCaptures],
	PlayerInfo[playerid][pKicksByAdmin], PlayerInfo[playerid][pLongestKillDistance], PlayerInfo[playerid][pNearestKillDistance],
	PlayerInfo[playerid][pHighestCaptureAssists], PlayerInfo[playerid][pHighestKillAssists],
	PlayerInfo[playerid][pBountyPlayersKilled],
	PlayerInfo[playerid][pPrototypesStolen], PlayerInfo[playerid][pAntennasDestroyed], PlayerInfo[playerid][pCratesOpened], PlayerInfo[playerid][pAccountId]);
	mysql_tquery(Database, query);

	mysql_format(Database, query, sizeof(query), "UPDATE `PlayersData` SET LastPing = '%d', LastPacketLoss = '%f', \
		HighestPing = '%d', LowestPing = '%d', NukesLaunched = '%d', AirstrikesCalled = '%d', AnthraxIntoxications = '%d', \
		PUBGEventsWon = '%d', RopeRappels = '%d', AreasEntered = '%d', LastAreaId = '%d', LastPosX = '%f', LastPosY = '%f', LastPosZ = '%f', \
		LastHealth = '%f', LastArmour = '%f', TimeSpentOnFoot = '%d', TimeSpentInCar = '%d', TimeSpentAsPassenger = '%d', \
		TimeSpentInSelection = '%d', TimeSpentAFK = '%d', DriveByKills = '%d', CashAdded = '%d', CashReduced = '%d', \
		LastInterior = '%d', LastVirtualWorld = '%d', FlashBangedPlayers = '%d', PistolKills = '%d', MeleeKills = '%d' WHERE pID = '%d' LIMIT 1",
	PlayerInfo[playerid][pLastPing], PlayerInfo[playerid][pLastPacketLoss], PlayerInfo[playerid][pHighestPing], PlayerInfo[playerid][pLowestPing],
	PlayerInfo[playerid][pNukesLaunched], PlayerInfo[playerid][pAirstrikesCalled], PlayerInfo[playerid][pAnthraxIntoxications],
	PlayerInfo[playerid][pPUBGEventsWon], PlayerInfo[playerid][pRopeRappels],
	PlayerInfo[playerid][pAreasEntered], PlayerInfo[playerid][pLastAreaId],
	X, Y, Z, Health, Armour, PlayerInfo[playerid][pTimeSpentOnFoot], PlayerInfo[playerid][pTimeSpentInCar],
	PlayerInfo[playerid][pTimeSpentAsPassenger], PlayerInfo[playerid][pTimeSpentInSelection],
	PlayerInfo[playerid][pTimeSpentAFK], PlayerInfo[playerid][pDriveByKills],
	PlayerInfo[playerid][pCashAdded], PlayerInfo[playerid][pCashReduced], GetPlayerInterior(playerid), GetPlayerVirtualWorld(playerid),
	PlayerInfo[playerid][pFlashBangedPlayers], PlayerInfo[playerid][pPistolKills], PlayerInfo[playerid][pMeleeKills], PlayerInfo[playerid][pAccountId]);
	mysql_tquery(Database, query);

	mysql_format(Database, query, sizeof(query), "UPDATE `PlayersConf` SET `DoNotDisturb` = '%d', `NoDuel` = '%d', `HitIndicator` = '%d', `GUIEnabled` = '%d', \
		`SpawnKillTime` = '%d' WHERE pID = '%d' LIMIT 1",
	PlayerInfo[playerid][pDoNotDisturb], PlayerInfo[playerid][pNoDuel], PlayerInfo[playerid][pHitIndicatorEnabled],
	PlayerInfo[playerid][pGUIEnabled], PlayerInfo[playerid][pSpawnKillTime], PlayerInfo[playerid][pAccountId]);
	mysql_tquery(Database, query);
	return 1;
}

//Save everyone's stats
SaveAllStats() {
	foreach (new i: Player) {
		if (PlayerInfo[i][pLoggedIn] && pVerified[i]) {
			SavePlayerStats(i);
		}		
	}
	return 1;
}

//Click stats textdraw
hook OnPlayerClickTD(playerid, Text:clickedid) {
	if (clickedid == Text:INVALID_TEXT_DRAW && pStats[playerid] != -1) {
		pStats[playerid] = -1;		
		CancelSelectTextDraw(playerid);
		for (new i = 0; i < sizeof(Stats_TD); i++) {
			TextDrawHideForPlayer(playerid, Stats_TD[i]);
		}
		PlayerTextDrawHide(playerid, Stats_PTD[playerid][0]);
		PlayerTextDrawHide(playerid, Stats_PTD[playerid][1]);
		PlayerTextDrawHide(playerid, Stats_PTD[playerid][2]);
		return 1;
	}

	if (clickedid == Stats_TD[2]) {
		new selec = pStats[playerid] - 1;
		if (selec < 0) {
			pStats[playerid] = 14;
		} else {
			pStats[playerid] = selec;
		}

		new targetid = pStatsID[playerid];
		if (targetid == INVALID_PLAYER_ID) {
			pStats[playerid] = -1;
			CancelSelectTextDraw(playerid);
			for (new i = 0; i < sizeof(Stats_TD); i++) {
				TextDrawHideForPlayer(playerid, Stats_TD[i]);
			}
			PlayerTextDrawHide(playerid, Stats_PTD[playerid][0]);
			PlayerTextDrawHide(playerid, Stats_PTD[playerid][1]);
			PlayerTextDrawHide(playerid, Stats_PTD[playerid][2]);
			Text_Send(playerid, $CLIENT_299x);
			return 1;
		}

		UpdatePlayerStatsList(playerid, targetid);

		PlayerTextDrawShow(playerid, Stats_PTD[playerid][1]);
		PlayerTextDrawShow(playerid, Stats_PTD[playerid][2]);
		return 1;
	}

	if (clickedid == Stats_TD[3]) {
		new selec = pStats[playerid] + 1;
		if (selec > 14) {
			pStats[playerid] = 0;
		} else {
			pStats[playerid] = selec;
		}

		new targetid = pStatsID[playerid];
		if (targetid == INVALID_PLAYER_ID) {
			pStats[playerid] = 0;		
			CancelSelectTextDraw(playerid);
			for (new i = 0; i < sizeof(Stats_TD); i++) {
				TextDrawHideForPlayer(playerid, Stats_TD[i]);
			}
			PlayerTextDrawHide(playerid, Stats_PTD[playerid][0]);
			PlayerTextDrawHide(playerid, Stats_PTD[playerid][1]);
			PlayerTextDrawHide(playerid, Stats_PTD[playerid][2]);
			Text_Send(playerid, $CLIENT_299x);
			return 1;
		}

		UpdatePlayerStatsList(playerid, targetid);

		PlayerTextDrawShow(playerid, Stats_PTD[playerid][1]);
		PlayerTextDrawShow(playerid, Stats_PTD[playerid][2]);
		return 1;
	}

	if (clickedid == Stats_TD[4]) {
		pStats[playerid] = -1;
		CancelSelectTextDraw(playerid);
		for (new i = 0; i < sizeof(Stats_TD); i++) {
			TextDrawHideForPlayer(playerid, Stats_TD[i]);
		}
		PlayerTextDrawHide(playerid, Stats_PTD[playerid][0]);
		PlayerTextDrawHide(playerid, Stats_PTD[playerid][1]);
		PlayerTextDrawHide(playerid, Stats_PTD[playerid][2]);
		return 1;	
	}
	return 1;
}

//Stats command

CMD:stats(playerid, params[]) {
	new  targetid;

	if (isnull(params)) targetid = playerid;
	else targetid = strval(params);

	if (IsPlayerConnected(targetid)) {
		pStats[playerid] = 0;
		pStatsID[playerid] = targetid;

		new player_name[MAX_PLAYER_NAME + 5];
		if (targetid == playerid) {
			format(player_name, sizeof(player_name), "%s (You)", PlayerInfo[targetid][PlayerName]);
		} else {
			format(player_name, sizeof(player_name), PlayerInfo[targetid][PlayerName]);
		}

		PlayerTextDrawSetString(playerid, Stats_PTD[playerid][0], player_name);
		PlayerTextDrawShow(playerid, Stats_PTD[playerid][0]);

		UpdatePlayerStatsList(playerid, targetid);
		PlayerTextDrawShow(playerid, Stats_PTD[playerid][1]);
		PlayerTextDrawShow(playerid, Stats_PTD[playerid][2]);

		for (new i = 0; i < sizeof(Stats_TD); i++) {
			TextDrawShowForPlayer(playerid, Stats_TD[i]);
		}

		SelectTextDraw(playerid, X11_BLUE);

	}  else Text_Send(playerid, $NEWCLIENT_193x);
	return 1;
}

//End of File
/* (c) H2O Multiplayer 2018-2020. All rights reserved. */