/*
	SWAT vs Terrorists is a team death-match SA-MP game-mode script.
	Compatible with SA-MP 0.3.7 and later releases.

	Author: H2O
	Licensed under GNU GPLv3

	(c) 2018-2020 H2O Multiplayer. All rights reserved.
	Website: h2omultiplayer.com

	Death Module
*/

#include <YSI\y_hooks>
#include <YSI_Players\y_text> //Y_Less
loadtext mode_text[all], mode_text[client], mode_text[newcs], mode_text[dialogs], mode_text[gametexts];

//Hide kill box
forward KilledBox(killerid);
public KilledBox(killerid) {
	PlayerTextDrawHide(killerid, killedtext[killerid]);
	PlayerTextDrawHide(killerid, killedbox[killerid]);
	return 1;
}


//Kill Streak

stock CheckStreakBonus(killerid, playerid) {
	for (new i = 0; i < sizeof(SpreeInfo); i++) {
		if (pStreak[killerid] == SpreeInfo[i][Spree_Kills]) {
			Text_Send(@pVerified, $SERVER_19x, PlayerInfo[killerid][PlayerName], pStreak[killerid]);
			GameTextForPlayer(killerid, SpreeInfo[i][Spree_Name], 5000, 3);

			Text_Send(killerid, $STREAK_BONUS, SpreeInfo[i][Spree_Score], SpreeInfo[i][Spree_Cash], SpreeInfo[i][Spree_MK]);

			if (pStreak[killerid] > 5 && pStreak[killerid] < 10) {
				Text_Send(killerid, $CLIENT_164x);
				SetPlayerHealth(killerid, 100.0);
			}
			
			if (pStreak[killerid] > 10) {
				Text_Send(killerid, $CLIENT_165x);

				SetPlayerHealth(killerid, 100.0);
				SetPlayerArmour(killerid, 100.0);
			}

			if (pTeam[playerid] == TERRORIST) {
				SetPlayerWantedLevel(killerid, SpreeInfo[i][Spree_WantedLevel]);
				PlayCrimeReportForPlayer(playerid, playerid, 16);
				PlayCrimeReportForPlayer(killerid, playerid, 16);
				foreach (new x: Player) {
					if (pTeam[x] == SWAT) {
						PlayCrimeReportForPlayer(x, playerid, 16);
					}
				}
			}

			if (pStreak[killerid] > 25) {
				new weapon_luck = random(100);
				switch (weapon_luck) {
					case 0..70: {
						new random_weapon = random(4);
						switch(random_weapon) {
							case 0: {
								GivePlayerWeapon(playerid, WEAPON_KATANA, 1);
								GameTextForPlayer(playerid, "~g~KATANA", 3000, 3);
							}
							case 1: {
								GivePlayerWeapon(playerid, WEAPON_ROCKETLAUNCHER, 3);
								GameTextForPlayer(playerid, "~g~RPG", 3000, 3);
							}
							case 2: {
								GivePlayerWeapon(playerid, WEAPON_HEATSEEKER, 3);
								GameTextForPlayer(playerid, "~g~HEATSEEKER", 3000, 3);
							}
							case 3: {
								GivePlayerWeapon(playerid, WEAPON_MINIGUN, 10);
								GameTextForPlayer(playerid, "~g~MINIGUN", 3000, 3);
							}
						}
					}
				}
			}

			GivePlayerCash(killerid, SpreeInfo[i][Spree_Cash]);
			GivePlayerScore(killerid, SpreeInfo[i][Spree_Score]);

			AddPlayerItem(killerid, MK, SpreeInfo[i][Spree_MK]);

			break;
		}
	}
	return 1;
}

hook OnPlayerDeath(playerid, killerid, reason) {
	if (IsPlayerAttachedObjectSlotUsed(playerid, 8)) {
		RemovePlayerAttachedObject(playerid, 8);
	}

	//--------------	
	
	UpdateLabelText(playerid);

	//------------------------

	KillTimer(RecoverTimer[playerid]);
	KillTimer(AKTimer[playerid]);
	KillTimer(DamageTimer[playerid]);
	
	LastDamager[playerid] = INVALID_PLAYER_ID;
	
	if (killerid != INVALID_PLAYER_ID && killerid != playerid) {
		printf("%s[%d] killed %s[%d] with a/an %s.", PlayerInfo[killerid][PlayerName], killerid, PlayerInfo[playerid][PlayerName], playerid, ReturnWeaponName(reason));
		if (GetPlayerVirtualWorld(killerid) == 0 && GetPlayerInterior(killerid) == 0) {
			pKillerCam[playerid] = killerid;
		} else {
			pKillerCam[playerid] = INVALID_PLAYER_ID;
		}
		
		Text_Send(killerid, $CLIENT_393x, PlayerInfo[playerid][PlayerName], playerid);
		GivePlayerScore(killerid, 2);		
		GivePlayerCash(killerid, 11150);

		DropPlayerItems(playerid);

		if (GetPlayerState(killerid) == PLAYER_STATE_PASSENGER) {
			if (!GetVehicleDriver(GetPlayerVehicleID(playerid))) {
				printf("Player %s[%d] drive-by killed %s[%d] using a %s without a driver!",
					PlayerInfo[killerid][PlayerName], killerid, PlayerInfo[playerid][PlayerName], playerid,
					ReturnWeaponName(reason));
			}
			PlayerInfo[playerid][pDriveByKills] ++;
		}

		new crate = random(100);
		switch (crate) {
			case 0..5: {
				PlayerInfo[killerid][pCrates] ++;
				Text_Send(killerid, $CRATE_RECEIVED);
			}
		}

		if (PlayerRank[playerid] > 5) {
			Text_Send(killerid, $CLIENT_279x);
			PlayerInfo[killerid][pEXPEarned] += 2;
		}

		if (firstblood == INVALID_PLAYER_ID) {
			firstblood = playerid;
			Text_Send(@pVerified, $SERVER_63x, PlayerInfo[killerid][PlayerName], PlayerInfo[playerid][PlayerName]);
			Text_Send(killerid, $FIRSTBLOOD);
			GivePlayerScore(killerid, 10);
		}

		if (PlayerInfo[killerid][pDeathmatchId] >= 0) {
			PlayerInfo[killerid][sDMKills] ++;
			PlayerInfo[killerid][pDeathmatchKills] ++;
			pDMKills[killerid][PlayerInfo[killerid][pDeathmatchId]] ++;
		}

		if (IsBulletWeapon(GetPlayerWeapon(killerid))) {
			GivePlayerWeapon(killerid, GetPlayerWeapon(killerid), 10);
		}

		LastKilled[killerid] = playerid;	

		if (PlayerInfo[playerid][pDonorLevel] < 5) {
			Text_Send(playerid, $CLIENT_394x, PlayerInfo[killerid][PlayerName], killerid);
			GivePlayerCash(playerid, -250);
		} else {
			Text_Send(playerid, $CLIENT_395x, PlayerInfo[killerid][PlayerName], killerid);
		}

		if (pStreak[playerid] >= 3) {
			Text_Send(@pVerified, $SERVER_54x, PlayerInfo[killerid][PlayerName], PlayerInfo[playerid][PlayerName]);
		}
		
		pStreak[playerid] = 0;

		if (GetPlayerInterior(playerid) == 0 && GetPlayerVirtualWorld(playerid) == 0) {
			PlayerInfo[playerid][pDeaths]++;
		}
		PlayerInfo[playerid][pSessionDeaths]++;

		UpdatePlayerHUD(killerid);
		UpdatePlayerHUD(playerid);

		new Float: X, Float: Y, Float: Z;
		GetPlayerPos(killerid, X, Y, Z);

		if (WarInfo[War_Started] == 1) {
			if ((pTeam[killerid] == WarInfo[War_Team1] && pTeam[playerid] == WarInfo[War_Team2]) ||
			(pTeam[killerid] == WarInfo[War_Team2] && pTeam[playerid] == WarInfo[War_Team1])) {
				AddTeamWarScore(killerid, 1);
			}
		}

		foreach (new x: Player)
		{
			if (IsPlayerInRangeOfPoint(x, 30.0, X, Y, Z) && !PlayerInfo[playerid][pAdminDuty])
			{
				if (x != killerid && pTeam[x] != pTeam[playerid])
				{
					if (LastTarget[x] == playerid || (IsPlayerInAnyVehicle(x) && GetPlayerVehicleID(x) == GetPlayerVehicleID(killerid)
						&& GetPlayerState(x) == PLAYER_STATE_DRIVER)) {
						Text_Send(x, $CLIENT_397x, PlayerInfo[killerid][PlayerName], killerid, PlayerInfo[playerid][PlayerName], playerid);

						new string4[60];
						format(string4, sizeof(string4), "Assist Killed ~w~%s", PlayerInfo[playerid][PlayerName]);
						PlayerTextDrawSetString(x, killedtext[x], string4);
						PlayerTextDrawShow(x, killedtext[x]);
						PlayerTextDrawShow(x, killedbox[x]);

						PlayerPlaySound(x, 1095, 0.0, 0.0, 0.0);

						KillTimer(KillerTimer[x]);
						KillerTimer[x] = SetTimerEx("KilledBox", 3000, false, "i", x);

						PlayerInfo[x][pKillAssists] ++;
						if (PlayerInfo[x][pKillAssists] > PlayerInfo[x][pHighestKillAssists]) {
							PlayerInfo[x][pHighestKillAssists] = PlayerInfo[x][pKillAssists];
						}
						PlayerInfo[x][sAssistkills] ++;

						GivePlayerScore(x, 1);

						LastTarget[x] = INVALID_PLAYER_ID;
					}
				}
			}
		}

		if (PlayerInfo[playerid][pBountyAmount]) {
			GivePlayerCash(killerid, PlayerInfo[playerid][pBountyAmount]);

			Text_Send(@pVerified, $NEWSERVER_1x, PlayerInfo[killerid][PlayerName], PlayerInfo[playerid][pBountyAmount], PlayerInfo[playerid][PlayerName]);
			PlayerInfo[playerid][pBountyAmount] = 0;
			PlayerInfo[killerid][pBountyPlayersKilled] ++;
		}

		PlayerInfo[playerid][pLastKiller] = killerid;

		if (PlayerInfo[killerid][pLastKiller] == playerid && playerid != killerid)
		{
			Text_Send(killerid, $CLIENT_399x, PlayerInfo[playerid][PlayerName]);

			PlayerInfo[killerid][pRevengeTakes] ++;

			GivePlayerScore(killerid, 1);
			PlayerInfo[killerid][pLastKiller] = INVALID_PLAYER_ID;
		}

		PlayerInfo[killerid][pKills] ++;
		switch (reason) {
			case 0: PlayerInfo[playerid][pFistKills] ++;
			case 1..18, 39..42: PlayerInfo[playerid][pMeleeKills] ++;
			case 21..24: PlayerInfo[playerid][pPistolKills] ++;
			case WEAPON_TEC9, WEAPON_UZI, WEAPON_MP5: PlayerInfo[killerid][pSMGKills] ++;
			case WEAPON_SHOTGUN, WEAPON_SHOTGSPA, WEAPON_SAWEDOFF: PlayerInfo[killerid][pShotgunKills] ++;
			case WEAPON_MINIGUN, WEAPON_ROCKETLAUNCHER, WEAPON_HEATSEEKER: PlayerInfo[killerid][pHeavyKills] ++;
		}

		GetPlayerPos(playerid, X, Y, Z);
		new Float: Distance = GetPlayerDistanceFromPoint(killerid, X, Y, Z);
		if (Distance < 45.0) {
			PlayerInfo[killerid][pCloseKills] ++;
			if (Distance < PlayerInfo[killerid][pNearestKillDistance]) {
				PlayerInfo[killerid][pNearestKillDistance] = Distance;
			}
		}
		if (Distance > 100.0) {
			PlayerInfo[killerid][pLongDistanceKills] ++;
			if (Distance > PlayerInfo[killerid][pLongestKillDistance]) {
				PlayerInfo[killerid][pLongestKillDistance] = Distance;
			}
		}

		if (reason == WEAPON_SAWEDOFF) {
			PlayerInfo[killerid][pSawnKills] ++;
		}

		new KillerName[MAX_PLAYER_NAME];
		GetPlayerName(killerid, KillerName, sizeof(KillerName));

		if (reason == WEAPON_KNIFE) {
			PlayerInfo[killerid][pKnifeKills] ++;
		}

		if (reason == WEAPON_TEARGAS) {
			PlayerInfo[killerid][sGasKills] ++;
		}

		pStreak[killerid]++;
		SendDeathMessage(killerid, playerid, reason);

		if (pStreak[killerid] > PlayerInfo[killerid][pHighestKillStreak]) {
			Text_Send(killerid, $CLIENT_548y);
			PlayerInfo[killerid][pHighestKillStreak] = pStreak[killerid];
		}

		CheckStreakBonus(killerid, playerid);

		PlayerInfo[killerid][pSessionKills]++;

		if (PlayerInfo[killerid][pIsSpying] && PlayerInfo[killerid][pSpyTeam] == pTeam[playerid]) {
			Text_Send(killerid, $CLIENT_400x);
			PlayerInfo[playerid][sDisguisedKills] ++;

			GivePlayerScore(killerid, 1);
			Text_Send(playerid, $SPIED);
		}

		if (PlayerInfo[playerid][pIsSpying] && PlayerInfo[playerid][pSpyTeam] == pTeam[killerid]) {
			Text_Send(killerid, $SPY_KILLED);
			PlayerInfo[killerid][pSpiesEliminated] ++;
		}

		if (PlayerInfo[playerid][pIsSpying] && PlayerInfo[playerid][pSpyTeam] == pTeam[killerid]) {
			Text_Send(playerid, $CLIENT_401x);
			GivePlayerScore(killerid, 1);

			PlayerInfo[playerid][sSpiesKilled] ++;
		}

		new string4[60];

		format(string4,sizeof(string4),"~g~Killed By ~r~%s",PlayerInfo[killerid][PlayerName]);
		PlayerTextDrawSetString(playerid,killedby[playerid],string4);
		PlayerTextDrawShow(playerid,killedby[playerid]);
		PlayerTextDrawShow(playerid,deathbox[playerid]);

		format(string4,sizeof(string4),"Eliminated ~w~%s",PlayerInfo[playerid][PlayerName]);
		PlayerTextDrawSetString(killerid,killedtext[killerid],string4);
		PlayerTextDrawShow(killerid,killedtext[killerid]);
		PlayerTextDrawShow(killerid,killedbox[killerid]);

		KillTimer(KillerTimer[killerid]);
		KillerTimer[killerid] = SetTimerEx("KilledBox", 3000, false, "i", killerid);
	} else {
		printf("%s[%d] died without a kiler, reason: %d.", PlayerInfo[playerid][PlayerName], playerid, reason);
	}
	return 1;
}

hook OnPlayerPrepareDeath(playerid, animlib[32], animname[32], &anim_lock, &respawn_time) {
	if (!pDuelInfo[playerid][pDInMatch] && !GetPlayerInterior(playerid) && !GetPlayerVirtualWorld(playerid)) {
		PlayerPlaySound(playerid, 1095, 0.0, 0.0, 0.0);
	}
	return 1;
}

hook OnPlayerDeathFinished(playerid, bool:cancelable) {
	if (pKillerCam[playerid] != INVALID_PLAYER_ID) {
		TogglePlayerSpectating(playerid, true);
		PlayerSpectatePlayer(playerid, pKillerCam[playerid]);
		RespawnTimer[playerid] = SetTimerEx("Respawn", 2000, false, "i", playerid);
		return 0;
	}
	return 1;
}

//End of File
/* (c) H2O Multiplayer 2018-2020. All rights reserved. */