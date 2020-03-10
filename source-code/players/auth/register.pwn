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

//Successful registration callback to retrieve account ID and continue
forward OnPlayerRegister(playerid);
public OnPlayerRegister(playerid) {
	PlayerInfo[playerid][pAccountId] = cache_insert_id();
	pVerified[playerid] = true;
	Text_Send(playerid, $CLIENT_151x);
	PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
	OnPlayerRequestClass(playerid, 0);
	return 1;
}

//Complete players' registration
void:CompleteRegistration(playerid) {
	for (new i = 0; i < 10; i++) {
		PlayerInfo[playerid][pSaltKey][i] = random(79) + 47;
	}

	PlayerInfo[playerid][pSaltKey][10] = 0;
	SHA256_PassHash(PlayerInfo[playerid][pPassword], PlayerInfo[playerid][pSaltKey], PlayerInfo[playerid][pPassword], 65);

	new query[256];

	mysql_format(Database, query, sizeof(query), "INSERT INTO `Players` (`Username`,`Password`,`Salt`,`IP`,`RegDate`,`LastVisit`) \
	VALUES('%e','%e','%e','%e','%d','%d')", PlayerInfo[playerid][PlayerName], PlayerInfo[playerid][pPassword], PlayerInfo[playerid][pSaltKey], PlayerInfo[playerid][pIP], gettime(), gettime());
	mysql_tquery(Database, query, "OnPlayerRegister", "d", playerid);

	if (!isnull(PlayerInfo[playerid][pEmailAddress])) {
		mysql_format(Database, query, sizeof(query), "UPDATE `Players` SET `EmailAddress` = '%e' WHERE `Username` = '%e' LIMIT 1", 
			PlayerInfo[playerid][pEmailAddress], PlayerInfo[playerid][PlayerName]);
		mysql_tquery(Database, query);
		PlayerInfo[playerid][pEmailVerified] = false;
	}

	mysql_format(Database, query, sizeof(query), "INSERT INTO `PlayersData` (`pID`) SELECT `ID` FROM `Players` WHERE `Username` = '%e' LIMIT 1", PlayerInfo[playerid][PlayerName]);
	mysql_tquery(Database, query);

	SetPlayerScore(playerid, 0);
	PlayerRank[playerid] = GetPlayerRank(playerid);

	ResetPlayerCash(playerid);

	Text_Send(playerid, $CLIENT_152x);

	GivePlayerCash(playerid, 500000);
	GivePlayerScore(playerid, 35);

	mysql_format(Database, query, sizeof(query), "INSERT INTO `PlayersConf` (`pID`) SELECT `ID` FROM `Players` WHERE `Username` = '%e' LIMIT 1", PlayerInfo[playerid][PlayerName]);
	mysql_tquery(Database, query);
	
	PlayerInfo[playerid][pDoNotDisturb] =
	PlayerInfo[playerid][pNoDuel] = 0;
	
	PlayerInfo[playerid][pHitIndicatorEnabled] =
	PlayerInfo[playerid][pGUIEnabled] = 1;
	
	PlayerInfo[playerid][pSpawnKillTime] = 15;

	PlayerInfo[playerid][pRegDate] = gettime();
	PlayerInfo[playerid][pLastVisit] = gettime();

	PlayerInfo[playerid][pLoggedIn] = 1;

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
}

//End of File
/* (c) H2O Multiplayer 2018-2020. All rights reserved. */