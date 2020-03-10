/*
	SWAT vs Terrorists is a team death-match SA-MP game-mode script. 
	Compatible with SA-MP 0.3.7 and later releases.

	Author: H2O
	Licensed under GNU GPLv3

	(c) 2018-2020 H2O Multiplayer. All rights reserved.
	Website: h2omultiplayer.com

	This file is only intended to add code for initializing a player
*/

//Support for y_text, load language files...
#include <YSI_Players\y_text> //Y_Less
loadtext mode_text[all], mode_text[client], mode_text[newcs], mode_text[dialogs], mode_text[gametexts];

//A SPECIAL CALLBACK

forward OnPlayerFullyConnected(playerid);
public OnPlayerFullyConnected(playerid) { //This function was hooked many times so not gonna remove it for now
	return 1;
}

hook OnIncomingConnection(playerid, ip_address[], port) {
	if (!svtconf[server_open]) {
		Kick(playerid);
		printf("[id: %d] attempted to access server while locked [%s:%d]", playerid, ip_address, port);
	}

	if (!strcmp(g_LastIp, ip_address, true) && !isnull(g_LastIp)) {
		if (g_Tick > gettime()) {	
			if (g_Connections > 3) {
				g_Connections = 0;		
				g_Tick = gettime();

				BlockIpAddress(ip_address, 60 * 1000 * 10);
				format(g_LastIp, 30, "");
				printf("Suspected bot attack: %s, id: %d", ip_address, playerid);
			}
		}

		g_Connections ++;
		g_Tick = gettime() + 3;
	}
	else {
		format(g_LastIp, 30, "%s", ip_address);
		g_Connections = 0;	
		g_Tick = gettime();
	}
	return 1;
}


hook OnPlayerConnect(playerid) {
	if (IsPlayerBot(playerid)) {
		Text_Send(playerid, $CLIENT_263x);
		GameTextForPlayer(playerid, "~r~UNAUTHORIZED ACCESS", 3000, 3);

		new suspectIp[20];
		GetPlayerIp(playerid, suspectIp, sizeof(suspectIp));
		BlockIpAddress(suspectIp, 60000 * 60);

		AntiCheatAlert(playerid, "Fake Client");
		return Kick(playerid);
	}

	//Show the player our intro
	for (new i = 0; i < sizeof(SvTTD); i++) {
		TextDrawShowForPlayer(playerid, SvTTD[i]);
	}

	//Set the player's language to English by default
	Langs_SetPlayerLanguage(playerid, English);

	//Update objects for player even if they don't move, useful for avoiding desync
	Streamer_ToggleIdleUpdate(playerid, true);

	//-----------

	/* Reset objects */

	PlayerInfo[playerid][pBombId] = INVALID_OBJECT_ID;
	PlayerInfo[playerid][pAnthrax] = INVALID_OBJECT_ID;
	for (new i = 0; i < 17; i++) {
		PlayerInfo[playerid][pAnthraxEffects][i] = INVALID_OBJECT_ID;
	}
	for (new i = 0; i < 5; i++) {
		PlayerInfo[playerid][pBombIds][i] = INVALID_OBJECT_ID;
	}

	//-----------GENERAL RESET
	new clear_data[E_PLAYER_ENUM];
	pEventInfo[playerid] = clear_data;
	new clear_data2[PlayerData];
	PlayerInfo[playerid] = clear_data2;
	pClass[playerid] = ASSAULT;
	pAdvancedClass[playerid] = false;
	SetPlayerConfigValue(playerid, "HUD", 0);
	VipLabel[playerid] = Create3DTextLabel(" ", 0x00000000, 0.0, 0.0, 8.0, 50.0, 0, 1);
	pStats[playerid] = -1;
	pStatsID[playerid] = INVALID_PLAYER_ID;
	pVehId[playerid] = INVALID_VEHICLE_ID;
	pFirstSpawn[playerid] = 1;
	pKillerCam[playerid] = INVALID_PLAYER_ID;
	LoadingTimer[playerid] = -1;
	AntiSK[playerid] = 0;
	pMinigunFires[playerid] = 0;
	InDrone[playerid] = false;
	pCamo[playerid] = 0;
	gCamoActivated[playerid] = 0;
	gMedicKitHP[playerid] = 0.0;
	gMedicKitStarted[playerid] = false;
	for (new i = 0; i < 13; i++) {
		pWeaponData[playerid][i] = pAmmoData[playerid][i] = 0;
	}
	pMoney[playerid] = 0;  
	LastKilled[playerid] = INVALID_PLAYER_ID;
	NukeTimer[playerid] =
	pTeamSTimer[playerid] =
	RecoverTimer[playerid] =
	AKTimer[playerid] =
	ExplodeTimer[playerid] =
	RepairTimer[playerid] =
	JailTimer[playerid] =
	DelayerTimer[playerid] =
	FreezeTimer[playerid] =
	DMTimer[playerid] =
	pConnectDelay[playerid] = -1;
	pClickedID[playerid] = INVALID_PLAYER_ID;
	gLastWeap[playerid] = 0;
	for (new i = 0; i < sizeof(pCooldown[]) - 1; i++) {
		pCooldown[playerid][i] = gettime();
	}
	gRappelling[playerid] = 0;
	pHelmetAttached[playerid] = 0;
	pMaskAttached[playerid] = 0;
	nearbyItemsCount[playerid] = 0;
	ownedItemsCount[playerid] = 0;
	new nearbyItemsReset[MAX_SLOTS], nearbyItemsIdxReset[MAX_SLOTS];
	nearbyItems[playerid] = nearbyItemsReset;
	nearbyItemsIdx[playerid] = nearbyItemsIdxReset;
	new ownedItemsReset[MAX_ITEMS];
	ownedItems[playerid] = ownedItemsReset;
	PlayerInfo[playerid][pPlayTick] = gettime();
	PlayerInfo[playerid][pKnifer] = INVALID_PLAYER_ID;
	LastTarget[playerid] = INVALID_PLAYER_ID;
	PlayerInfo[playerid][pBountyAmount] = 0;
	PlayerInfo[playerid][pDeathmatchId] = -1;
	PlayerInfo[playerid][pLastKiller] = INVALID_PLAYER_ID;
	PlayerInfo[playerid][pPasswordVerified] = 0;
	PlayerInfo[playerid][pACWarnings] = 0;
	PlayerInfo[playerid][pACCooldown] = gettime();
	pIsWorldObjectsRemoved[playerid] = false;
	PlayerInfo[playerid][pDeathmatchId] = -1;
	cLoggerList[playerid] = 0;
	pWatching[playerid] = false;
	new reset_bullet_stats[BulletData];
	BulletStats[playerid] = reset_bullet_stats;
	menuPlayerTextDrawCount[playerid] = 0;
	pSpawn[playerid] = -1;
	gMedicTick[playerid] = GetTickCount();
	BulletStats[playerid][Last_Shot_MS] = GetTickCount();
	BulletStats[playerid][MS_Between_Shots] = GetTickCount();
	Last_Pickup[playerid] = -1;
	Last_Pickup_Tick[playerid] = GetTickCount();
	gIntCD[playerid] = GetTickCount();
	gCamoTime[playerid] = gettime();
	PlayerInfo[playerid][pCar] = -1;
	gMGOverheat[playerid] = 0;
	gIncentFire[playerid] = 0;
	PlayerInfo[playerid][pCaptureStreak] =
	PlayerInfo[playerid][pZonesCaptured] =
	gEditSlot[playerid] = -1;
	gEditModel[playerid] = -1;
	gEditList[playerid] = 0;
	pKatanaEnhancement[playerid] = 0;
	for (new i = 0; i < 4; i++) {
		gModelsSlot[playerid][i] = -1;
		gModelsObj[playerid][i] = -1;
		gModelsPart[playerid][i] = -1;
	}

	for (new i = 0; i < MAX_SLOTS; i++) {
		gAirstrikePlanes[i][0] = gAirstrikePlanes[i][1] = gAirstrikePlanes[i][2] = INVALID_OBJECT_ID;
	}
	gInvisible[playerid] = false;
	gInvisibleTime[playerid] = gettime();
	PlayerInfo[playerid][acWarnings] = 0;
	PlayerInfo[playerid][acTotalWarnings] = 0;
	PlayerInfo[playerid][acCooldown] = gettime();
	pRapidFireBullets{playerid} = 0;
	pRapidFireTick[playerid] = GetTickCount();
	IsPlayerUsingAnims[playerid] = 0;
	IsPlayerAnimsPreloaded[playerid] = 0;
	pLastMessager[playerid] = INVALID_PLAYER_ID;
	rconAttempts[playerid] = 0;
	format(PlayerInfo[playerid][pPrevName], MAX_PLAYER_NAME, "N/A");
	PlayerInfo[playerid][pKnifeTarget] = INVALID_PLAYER_ID;
	PlayerInfo[playerid][pDeathmatchId] = -1;
	TargetOf[playerid] = INVALID_PLAYER_ID;
	pDuelInfo[playerid][pDLocked] =
	pDuelInfo[playerid][pDWeapon] =
	pDuelInfo[playerid][pDAmmo] =
	pDuelInfo[playerid][pDWeapon2] =
	pDuelInfo[playerid][pDAmmo2] =
	pDuelInfo[playerid][pDBetAmount] =
	pDuelInfo[playerid][pDInMatch] =
	pDuelInfo[playerid][pDCountDown] =
	AntiSK[playerid] = 0;
	if (svtconf[kick_bad_nicknames]) {
		for (new i = 0; i < sizeof(ForbiddenNames); i++) {
			if (strfind(PlayerInfo[playerid][PlayerName], ForbiddenNames[i], true) != -1 && !isnull(ForbiddenNames[i])) {
				PlayerInfo[playerid][pAntiSwearBlocks] ++;
				Text_Send(playerid, $CLIENT_264x);
				Kick(playerid);
			}
		}
	}
	pStreak[playerid] = 0;
	pConnectDelay[playerid] = -1;
    pVotesKick[playerid] = 0;

	//Play the server's theme song - Alister Theme, I think it's the intro song for COD:BO4?
	PlayAudioStreamForPlayer(playerid, "http://51.254.181.90/server/alister_theme.mp3", 0.0, 0.0, 0.0, 0.0, 0);

	//Set player's maximum health to 100 by default
	SetPlayerMaxHealth(playerid, 100.0);

	//Reset other stuff
	ResetToysData(playerid);
	ResetPlayerItems(playerid);

	//Load player's name
	GetPlayerName(playerid, PlayerInfo[playerid][PlayerName], MAX_PLAYER_NAME);

	//Create map icons
	SetPlayerMapIcon(playerid, 33, -337.7852, 1596.3204, 75.7351, 27, 0, MAPICON_LOCAL);
	SetPlayerMapIcon(playerid, 34, -658.4724, 2190.4504, 51.2932, 23, 0, MAPICON_LOCAL);

	//Mod place
	gModMapIcon[playerid] = CreateDynamicMapIcon(2387.1062, 1046.6208, 18.3189, 27, 0, 0, 0, playerid, 450.0, MAPICON_LOCAL);

	//-----------	

	//First server messages
	Text_Send(playerid, $AGREEMENT);
	Text_Send(playerid, $LANG_PREF);

	//If the player is advertising in their name, kick them
	if (PlayerInfo[playerid][pAdminLevel] < svtconf[max_admin_level] && svtconf[anti_adv] && AdCheck(PlayerInfo[playerid][PlayerName])) {
		return Kick(playerid);
	}

	//Continue connection stuff
	pConnectDelay[playerid] = SetTimerEx("OnPlayerFullyConnected", 200, false, "i", playerid);

	//Let others know that this player connected
	SetPlayerColor(playerid, 0xFFFFFFFF);
	SendDeathMessage(INVALID_PLAYER_ID, playerid, 200);
	
	//Create the GUI
	CreatePlayerUI(playerid);

	//Reset some dangerous stuff
	PlayerInfo[playerid][pAdminLevel] = 0;
	PlayerInfo[playerid][pIsModerator] = 0;
	PlayerInfo[playerid][pDonorLevel] = 0;
	return 1;
}

//End of File
/* (c) H2O Multiplayer 2018-2020. All rights reserved. */