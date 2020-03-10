/*
	SWAT vs Terrorists is a team death-match SA-MP game-mode script. 
	Compatible with SA-MP 0.3.7 and later releases.

	Author: H2O
	Licensed under GNU GPLv3

	(c) 2018-2020 H2O Multiplayer. All rights reserved.
	Website: h2omultiplayer.com

	Miscellaneous stuff, things that we didn't feel like
	putting in modules at all
*/

//------------

//Checkpoints

public OnPlayerEnterRaceCheckpoint(playerid) {
	if (!Iter_Contains(ePlayers, playerid)) {
		DisablePlayerRaceCheckpoint(playerid);
	}   
	return 1;
}

//------------

//Dynamic Areas

public OnPlayerEnterDynamicArea(playerid, areaid) {
	PlayerInfo[playerid][pAreasEntered] ++;
	PlayerInfo[playerid][pLastAreaId] = areaid;
	return 1;
}

/* To avoid errors */
public OnPlayerRequestClass(playerid, classid) {
	return 1;
}

public OnPlayerLeaveDynamicCP(playerid, checkpointid) {
	return 1;
}

public OnPlayerClickTextDraw(playerid, Text:clickedid) {
	return 0;
}

//End of File
/* (c) H2O Multiplayer 2018-2020. All rights reserved. */