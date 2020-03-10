/*
	SWAT vs Terrorists is a team death-match SA-MP game-mode script.
	Compatible with SA-MP 0.3.7 and later releases.

	Author: H2O
	Licensed under GNU GPLv3

	(c) 2018-2020 H2O Multiplayer. All rights reserved.
	Website: h2omultiplayer.com

	Airstrike module
*/

#include <YSI\y_hooks>
#include <YSI_Players\y_text> //Y_Less
loadtext mode_text[all], mode_text[client], mode_text[newcs], mode_text[dialogs], mode_text[gametexts];

forward OnAirstrikeForwarded(callid, Smoke_Flare_ID);
public OnAirstrikeForwarded(callid, Smoke_Flare_ID) {
	DestroyDynamicObject(Smoke_Flare_ID);
	KillTimer(gAirstrikeTimer[callid]);

	new Float: X, Float: Y, Float: Z;

	X = gAirstrikePos[callid][0];
	Y = gAirstrikePos[callid][1];
	Z = gAirstrikePos[callid][2] + 7.174264;

	gAirstrikeRocket[callid] = CreateDynamicObject(3790, X, Y, (Z - 7.174264) + 150.5, 0.0, -90.0, 0.0);
	MoveDynamicObject(gAirstrikeRocket[callid], X, Y, Z - 10.5, 35.0);

	gAirstrikePlanes[callid][0] = CreateDynamicObject(10757, X + 50, Y - 90, (Z - 7.174264) + 50.0, 0.0, 0.0, 180.0);
	gAirstrikePlanes[callid][1] = CreateDynamicObject(10757, X, Y - 90, (Z - 7.174264) + 70.0, 0.0, 0.0, 180.0);
	gAirstrikePlanes[callid][2] = CreateDynamicObject(10757, X - 50, Y - 90, (Z - 7.174264) + 50.0, 0.0, 0.0, 180.0);

	MoveDynamicObject(gAirstrikePlanes[callid][0], X, Y + 600, Z + 50.0, 70.0);
	MoveDynamicObject(gAirstrikePlanes[callid][1], X, Y + 600, Z + 50.0, 70.0);
	MoveDynamicObject(gAirstrikePlanes[callid][2], X, Y + 600, Z + 50.0, 70.0);
	return 1;
}

hook OnGameModeInit() {
	for (new i = 0; i < MAX_SLOTS; i++) {
		KillTimer(gAirstrikeTimer[i]);
		gAirstrikePos[i][0] = gAirstrikePos[i][1] = gAirstrikePos[i][2] = 0.0;
		gAirstrikeExists[i] = 0;
	}
	return 1;
}

hook OnDynamicObjectMoved(objectid) {
	for (new i = 0; i < MAX_SLOTS; i++) {
		if (gAirstrikeExists[i] && gAirstrikeRocket[i] == objectid) {
			new Float:X, Float: Y, Float: Z;
			GetDynamicObjectPos(gAirstrikeRocket[i], X, Y, Z);

			CreateExplosion(X, Y, Z, 7, 50.0);

			CreateExplosion(X, Y + 20, Z, 7, 50.0);
			CreateExplosion(X, Y - 20, Z, 7, 50.0);

			CreateExplosion(X + 20, Y, Z, 7, 50.0);
			CreateExplosion(X - 20, Y, Z, 7, 50.0);
	   
			DestroyDynamicObject(gAirstrikeRocket[i]);
			gAirstrikeRocket[i] = INVALID_OBJECT_ID;

			DestroyDynamicObject(gAirstrikePlanes[i][0]);
			DestroyDynamicObject(gAirstrikePlanes[i][1]);
			DestroyDynamicObject(gAirstrikePlanes[i][2]);

			gAirstrikeExists[i] = 0;
			break;
		}			
	}
	return 1;
}

CMD:airstrike(playerid) {
	if (GetPlayerCash(playerid) < 500000 || GetPlayerScore(playerid) < 10000) {
		return PlayerPlaySound(playerid, 1055, 0.0, 0.0, 0.0), Text_Send(playerid, $CLIENT_343x);
	}	

	if (ZoneInfo[LV_AIR][Zone_Owner] != pTeam[playerid]) return Text_Send(playerid, $CLIENT_342x);
	if (GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) return Text_Send(playerid, $CLIENT_341x);
	if (GetPlayerInterior(playerid) != 0 || GetPlayerVirtualWorld(playerid) != 0) return Text_Send(playerid, $CLIENT_339x);

	if (pDuelInfo[playerid][pDInMatch] == 1) return Text_Send(playerid, $COMMAND_INDUEL);
	if (PlayerInfo[playerid][pDeathmatchId] > -1) return Text_Send(playerid, $COMMAND_INDM);
	if (Iter_Contains(ePlayers, playerid)) return Text_Send(playerid, $COMMAND_INEVENT);
	if (Iter_Contains(CWCLAN1, playerid) || Iter_Contains(CWCLAN2, playerid)) return Text_Send(playerid, $COMMAND_INCW);
	if (Iter_Contains(PUBGPlayers, playerid)) return Text_Send(playerid, $COMMAND_INPUBG);

	if (pCooldown[playerid][30] > gettime()) {
		 Text_Send(playerid, $CLIENT_340x, pCooldown[playerid][30] - gettime());
		 return 1;
	}

	new Float: Checkpos[3], Float: Check_X;
	GetPlayerPos(playerid, Checkpos[0], Checkpos[1], Checkpos[2]);

	CA_FindZ_For2DCoord(Checkpos[0], Checkpos[1], Check_X);
	if (Checkpos[2] < Check_X) return Text_Send(playerid, $CLIENT_339x);

	for (new i = 0; i < MAX_SLOTS; i++) {
		if (!gAirstrikeExists[i]) {
			Text_Send(playerid, $CLIENT_338x);
			GivePlayerCash(playerid, -500000);

			new Float: X, Float: Y, Float: Z;

			gAirstrikeExists[i] = 1;

			GetPlayerPos(playerid, X, Y, Z);
			CA_FindZ_For2DCoord(X, Y, Z);

			gAirstrikePos[i][0] = X;
			gAirstrikePos[i][1] = Y;
			gAirstrikePos[i][2] = Z;

			new Smoke_Flare_Object = CreateDynamicObject(18728, gAirstrikePos[i][0], gAirstrikePos[i][1], gAirstrikePos[i][2], 0.0, 0.0, 90.0);
			gAirstrikeTimer[i] = SetTimerEx("OnAirstrikeForwarded", 5000, false, "ii", i, Smoke_Flare_Object);

			Text_Send(@pVerified, $SERVER_74x, PlayerInfo[playerid][PlayerName]);

			pCooldown[playerid][30] = gettime() + 45;
			PlayerInfo[playerid][pAirstrikesCalled] ++;

			break;
		}
	}
	return 1;
}


//End of File
/* (c) H2O Multiplayer 2018-2020. All rights reserved. */