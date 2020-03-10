/*
	SWAT vs Terrorists is a team death-match SA-MP game-mode script.
	Compatible with SA-MP 0.3.7 and later releases.

	Author: H2O
	Licensed under GNU GPLv3

	(c) 2018-2020 H2O Multiplayer. All rights reserved.
	Website: h2omultiplayer.com

	Handle various player configuration options
*/

GetPlayerConfigValue(playerid, const Config[]) {
	if (!strcmp(Config, "DND")) return PlayerInfo[playerid][pDoNotDisturb];
	if (!strcmp(Config, "NODUEL")) return PlayerInfo[playerid][pNoDuel];
	if (!strcmp(Config, "HI")) return PlayerInfo[playerid][pHitIndicatorEnabled];
	if (!strcmp(Config, "HUD")) return PlayerInfo[playerid][pGUIEnabled];
	if (!strcmp(Config, "ANTISKTIME")) return PlayerInfo[playerid][pSpawnKillTime];
	return 0;
}

SetPlayerConfigValue(playerid, const Config[], val) {
	if (!strcmp(Config, "DND")) PlayerInfo[playerid][pDoNotDisturb] = val;
	if (!strcmp(Config, "NODUEL")) PlayerInfo[playerid][pNoDuel] = val;
	if (!strcmp(Config, "HI")) PlayerInfo[playerid][pHitIndicatorEnabled] = val;
	if (!strcmp(Config, "HUD")) PlayerInfo[playerid][pGUIEnabled] = val;
	if (!strcmp(Config, "ANTISKTIME")) PlayerInfo[playerid][pSpawnKillTime] = val;
	return 1;
}

//End of File
/* (c) H2O Multiplayer 2018-2020. All rights reserved. */