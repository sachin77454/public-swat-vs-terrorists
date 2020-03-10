/*
	SWAT vs Terrorists is a team death-match SA-MP game-mode script.
	Compatible with SA-MP 0.3.7 and later releases.

	Author: H2O
	Licensed under GNU GPLv3

	(c) 2018-2020 H2O Multiplayer. All rights reserved.
	Website: h2omultiplayer.com

	Exit Module
*/

#include <YSI\y_hooks>
#include <YSI_Players\y_text> //Y_Less
loadtext mode_text[all], mode_text[client], mode_text[newcs], mode_text[dialogs], mode_text[gametexts];

hook OnPlayerDisconnect(playerid, reason) {
	pSpawn[playerid] = -1;
	ForceSync[playerid] = 0;

	////////Timers/////////////

	KillTimer(FirstSpawn_Timer[playerid]);
	KillTimer(KillerTimer[playerid]);
	KillTimer(RespawnTimer[playerid]);
	KillTimer(LoadingTimer[playerid]);
	KillTimer(InviteTimer[playerid]);
	KillTimer(ac_InformTimer[playerid]);

	///////////////////////////

	TargetOf[playerid] = INVALID_PLAYER_ID;
	pKillerCam[playerid] = INVALID_PLAYER_ID;
	playerUsingMenu[playerid] = false;

	RemovePlayerUI(playerid);

	//------------
	PlayerInfo[playerid][pTimePlayed] += gettime() - PlayerInfo[playerid][pPlayTick];

	RecountPlayedTime(playerid);

	KillTimer(TutoTimer[playerid]);
	KillTimer(NotifierTimer[playerid]);
	KillTimer(CarInfoTimer[playerid]);

	TextDrawHideForPlayer(playerid, Site_TD);
	TextDrawHideForPlayer(playerid, SvT_TD);

	KillTimer(SpawnTimer[playerid]);

	foreach (new i: Player) {
		if (pClickedID[i] == playerid) {
			pClickedID[i] = INVALID_PLAYER_ID;
		}

		if (pLastMessager[i] == playerid) {
			pLastMessager[i] = INVALID_PLAYER_ID;
		}		

		for (new x = 0; x < MAX_SLOTS; x++) {
			if (gLandminePlacer[x] == playerid) {
				gLandminePlacer[x] = INVALID_PLAYER_ID;
			}

			if (gDynamitePlacer[x] == playerid) {
				gDynamitePlacer[x] = INVALID_PLAYER_ID;
			}
		}	
	}

	pLastMessager[playerid] = INVALID_PLAYER_ID;

	DeletePVar(playerid, "DialogListitem");

	Delete3DTextLabel(VipLabel[playerid]);

	KillTimer(DamageTimer[playerid]);

	if (nukePlayerId == playerid) {
		UpdateDynamic3DTextLabelText(nukeRemoteLabel, 0xFFFFFFFF, "Nuke\n{00CC00}Online");
		Text_Send(@pVerified, $SERVER_52x);
		KillTimer(NukeTimer[playerid]);
	}

	KillTimer(RecoverTimer[playerid]);
	KillTimer(AKTimer[playerid]);
	KillTimer(ExplodeTimer[playerid]);
	KillTimer(RepairTimer[playerid]);
	KillTimer(JailTimer[playerid]);
	KillTimer(DelayerTimer[playerid]);
	KillTimer(FreezeTimer[playerid]);
	KillTimer(DMTimer[playerid]);

	pClickedID[playerid] = INVALID_PLAYER_ID;
	
	RemovePlayerMapIcon(playerid, 33);
	RemovePlayerMapIcon(playerid, 34);
	RemovePlayerMapIcon(playerid, 35);

	DestroyDynamicMapIcon(gModMapIcon[playerid]);

	ClearReportsData(playerid);

	if (PlayerInfo[playerid][pLoggedIn] && pVerified[playerid] && reason != 0) {
		SavePlayerStats(playerid);
	}

	PlayerInfo[playerid][pLoggedIn] = 0;
	KillTimer(pConnectDelay[playerid]);

	foreach (new i: Player) {
		if (PlayerInfo[i][pBackup] == playerid && i != playerid) {
			pBackupResponded[i] = 0;
			PlayerInfo[i][pBackup] = INVALID_PLAYER_ID;
		}
	}

	/* Reset objects */

	if (IsValidDynamicObject(PlayerInfo[playerid][pBombId])) {
		DestroyDynamicObject(PlayerInfo[playerid][pBombId]);
	}
	PlayerInfo[playerid][pBombId] = INVALID_OBJECT_ID;
	for (new i = 0; i < 5; i++) {
		if (IsValidDynamicObject(PlayerInfo[playerid][pBombIds][i])) {
			DestroyDynamicObject(PlayerInfo[playerid][pBombIds][i]);
		}
		PlayerInfo[playerid][pBombIds][i] = INVALID_OBJECT_ID;
	}

	////////////////////////////

	SendDeathMessage(INVALID_PLAYER_ID, playerid, 201);

	if (PlayerInfo[playerid][pAdminLevel] || PlayerInfo[playerid][pIsModerator]) { 
		new String[128];
		format(String, sizeof(String), "%s has left the game.", PlayerInfo[playerid][PlayerName]);
		
		new DCC_Channel:StaffChannel;
		StaffChannel = DCC_FindChannelByName(CHANNEL_STAFF_NAME);
		DCC_SendChannelMessage(StaffChannel, String);
	}

	pStreak[playerid] = 0;
	rconAttempts[playerid] = 0;

	pLastMessager[playerid] = INVALID_PLAYER_ID;

	Delete3DTextLabel(VipLabel[playerid]);

	for (new i = 0; i < 10; i++) {
		if (IsPlayerAttachedObjectSlotUsed(playerid, i)) {
			RemovePlayerAttachedObject(playerid, i);
		}
	}

	//Check if player goodbye'd their opponent
	PlayerLeaveDuelCheck(playerid);

	if (cache_is_valid(PlayerInfo[playerid][pCacheId])) {
		cache_delete(PlayerInfo[playerid][pCacheId]);
		PlayerInfo[playerid][pCacheId] = MYSQL_INVALID_CACHE;
	}

	//Unverify this account slot
	new clear_data2[PlayerData];
	PlayerInfo[playerid] = clear_data2;

	pVerified[playerid] = false;
	return 1;
}

//End of File
/* (c) H2O Multiplayer 2018-2020. All rights reserved. */