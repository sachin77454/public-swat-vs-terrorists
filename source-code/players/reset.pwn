/*
	SWAT vs Terrorists is a team death-match SA-MP game-mode script.
	Compatible with SA-MP 0.3.7 and later releases.

	Author: H2O
	Licensed under GNU GPLv3

	(c) 2018-2020 H2O Multiplayer. All rights reserved.
	Website: h2omultiplayer.com
	
	Reset function
*/

#include <YSI\y_text>
loadtext mode_text[all], mode_text[client], mode_text[newcs], mode_text[dialogs], mode_text[gametexts];

ResetPlayerVars(playerid) {
	AntiSK[playerid] =
	pStreak[playerid] =
	PlayerInfo[playerid][pCaptureStreak] =
	pBackupRequested[playerid] =
	pBackupResponded[playerid] =
	pIsDamaged[playerid] =
	PlayerInfo[playerid][pSelecting] =
	pHelmetAttached[playerid] =
	PlayerInfo[playerid][pIsSpying] = 0;
	PlayerInfo[playerid][pSpyTeam] = -1;
	pVehId[playerid] = INVALID_VEHICLE_ID;
	pCamo[playerid] = 0;
	gCamoActivated[playerid] = 0;
	pWatching[playerid] = false;
	gMGOverheat[playerid] = 0;
	gIncentFire[playerid] = 0;
	pKatanaEnhancement[playerid] = 0;
	gMedicKitHP[playerid] = 0.0;
	gMedicKitStarted[playerid] = false;
	PlayerInfo[playerid][pPickedWeap] = 0;
	PlayerInfo[playerid][pACWarnings] = 0;
	PlayerInfo[playerid][pACCooldown] = gettime();
	if (PlayerInfo[playerid][pCar] != -1) DestroyVehicle(PlayerInfo[playerid][pCar]);
	PlayerInfo[playerid][pCar] = -1;
	if (Iter_Contains(ePlayers, playerid)) {
		foreach (new i: ePlayers) Text_Send(i, $CLIENT_540x, PlayerInfo[playerid][PlayerName]);
		Iter_Remove(ePlayers, playerid);	
		if (!Iter_Count(ePlayers)) {
			new clear_data[E_DATA_ENUM];
			EventInfo = clear_data;
			EventInfo[E_STARTED] = 0;
			EventInfo[E_OPENED] = 0;
			EventInfo[E_SPAWN_TYPE] = EVENT_SPAWN_INVALID;
			EventInfo[E_TYPE] = -1;
		} else if (Iter_Count(ePlayers) > 2) {
			Text_Send(playerid, $EVENT_WATCH);
		}
		DisablePlayerRaceCheckpoint(playerid);
	}
	new clear_data[E_PLAYER_ENUM];
	pEventInfo[playerid] = clear_data;
	LastDamager[playerid] = INVALID_PLAYER_ID;   
	PlayerTextDrawHide(playerid, deathbox[playerid]);
	PlayerTextDrawHide(playerid, killedby[playerid]); 
	Attach3DTextLabelToPlayer(RankLabel[playerid], playerid, 0.0, 0.0, 0.7);
	Attach3DTextLabelToPlayer(VipLabel[playerid], playerid, 0.0, 0.0, 0.9);
	LastTarget[playerid] = INVALID_PLAYER_ID;
	DisablePlayerRaceCheckpoint(playerid);
	PlayerInfo[playerid][pBackup] = INVALID_PLAYER_ID;
	PlayerInfo[playerid][pLastHitTick] = gettime();
	PlayerPlaySound(playerid, 0, 0.0, 0.0, 0.0);
	PlayerInfo[playerid][acWarnings] = 0;
	PlayerInfo[playerid][acTotalWarnings] = 0;
	PlayerInfo[playerid][acCooldown] = gettime();
	PlayerInfo[playerid][pAFKOnSpawn] = 0;
	InDrone[playerid] = false;	
	PlayerInfo[playerid][AntiAirAlerts] = 0;
	for (new i = 0; i < sizeof(AACInfo); i++) {
		if (AACInfo[i][AAC_Target] == playerid) {
			AACInfo[i][AAC_Target] = INVALID_PLAYER_ID;
		}
	}
	ClearAnimations(playerid);
	PlayerInfo[playerid][pLimit] = gettime();
	PlayerInfo[playerid][pLimit2] = gettime();
	pKillerCam[playerid] = INVALID_PLAYER_ID;
	KillTimer(RespawnTimer[playerid]);
	for (new i = 0; i < 13; i++) {
		pWeaponData[playerid][i] = pAmmoData[playerid][i] = 0;
	}
	pMinigunFires[playerid] = 0;    
	PlayerInfo[playerid][pHeadshotStreak] = 0;
	PlayerInfo[playerid][pSpyTeam] = -1;
	LastKilled[playerid] = INVALID_PLAYER_ID;
	return 1;
}

//End of File
/* (c) H2O Multiplayer 2018-2020. All rights reserved. */