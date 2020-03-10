/*
	SWAT vs Terrorists is a team death-match SA-MP game-mode script.
	Compatible with SA-MP 0.3.7 and later releases.

	Author: H2O
	Licensed under GNU GPLv3

	(c) 2018-2020 H2O Multiplayer. All rights reserved.
	Website: h2omultiplayer.com

	Player States
*/

#include <YSI\y_hooks>
#include <YSI_Players\y_text> //Y_Less
loadtext mode_text[all], mode_text[client], mode_text[newcs], mode_text[dialogs], mode_text[gametexts];

hook OnPlayerStateChange(playerid, newstate, oldstate) {
	if (newstate == PLAYER_STATE_PASSENGER && (GetVehicleModel(GetPlayerVehicleID(playerid)) == 497 || GetVehicleModel(GetPlayerVehicleID(playerid)) == 497)) {
		if (pTeam[playerid] == SWAT) {
			Text_Send(playerid, $CLIENT_280x);
		}
	}

	if (!PlayerInfo[playerid][pSelecting]) {
		switch (newstate) {
			case PLAYER_STATE_ONFOOT,PLAYER_STATE_DRIVER,PLAYER_STATE_PASSENGER,PLAYER_STATE_WASTED: SetHealthBarVisible(playerid, true);
			default: SetHealthBarVisible(playerid, false);
		}
	} else {
		SetHealthBarVisible(playerid, false);
	}
	return 1;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
	//------
	//WatchRoom
	if (pWatching[playerid]) {
		pWatching[playerid] = false;
		SetCameraBehindPlayer(playerid);
	}
	
	if (GetPlayerWeapon(playerid) == 24 && PlayerInfo[playerid][pDeathmatchId] == -1 
		&& !pDuelInfo[playerid][pDInMatch] && !Iter_Contains(ePlayers, playerid) && !Iter_Contains(PUBGPlayers, playerid)) {
		new ammo = GetPlayerAmmo(playerid);
		if ((newkeys & KEY_FIRE) && (oldkeys & KEY_CROUCH) && !((oldkeys & KEY_FIRE) || (newkeys & KEY_HANDBRAKE)) || (oldkeys & KEY_FIRE) && (newkeys & KEY_CROUCH) && !((newkeys & KEY_FIRE) || (newkeys & KEY_HANDBRAKE))) {
			PlayerInfo[playerid][pCheckCBug] = 0;
			Text_Send(playerid, $NO_CBUG);
			TogglePlayerControllable(playerid, false);
			FreezeTimer[playerid] = SetTimerEx("Unfreeze", 1000, false, "i", playerid);
			PlayerInfo[playerid][pCBugAttempts] ++;
		}
		
		if (PlayerInfo[playerid][pCheckCBug] == 1) {
			if ((newkeys & KEY_CROUCH) && !((newkeys & KEY_FIRE) || (newkeys & KEY_HANDBRAKE)) && GetPlayerSpecialAction(playerid) != SPECIAL_ACTION_DUCK) {
				if (PlayerInfo[playerid][cbugLastAmmo] > GetPlayerAmmo(playerid)) {
					PlayerInfo[playerid][pCheckCBug] = 0;
					Text_Send(playerid, $NO_CBUG);
					TogglePlayerControllable(playerid, false);
					FreezeTimer[playerid] = SetTimerEx("Unfreeze", 1000, false, "i", playerid);
					PlayerInfo[playerid][pCBugAttempts] ++;
				}
			}
		} else if (((newkeys & KEY_FIRE) && (newkeys & KEY_HANDBRAKE) && !((newkeys & KEY_SPRINT) || (newkeys & KEY_JUMP))) ||
		(newkeys & KEY_FIRE) && !((newkeys & KEY_SPRINT) || (newkeys & KEY_JUMP)) || (StaticPlayer[playerid] && (newkeys & KEY_FIRE)
		&& (newkeys & KEY_HANDBRAKE)) || (StaticPlayer[playerid] && (newkeys & KEY_FIRE)) ||
		(newkeys & KEY_FIRE) && (oldkeys & KEY_CROUCH) && !((oldkeys & KEY_FIRE) || (newkeys & KEY_HANDBRAKE)) ||
		(oldkeys & KEY_FIRE) && (newkeys & KEY_CROUCH) && !((newkeys & KEY_FIRE) || (newkeys & KEY_HANDBRAKE)) ) {
			SetTimerEx("StoppCheckCBug", 3000, 0, "i", playerid);
			PlayerInfo[playerid][pCheckCBug] = 1;
			PlayerInfo[playerid][cbugAmmo] = ammo;
			return 1;
		}
	} else {
		PlayerInfo[playerid][pCheckCBug] = 0;
	}

	if (IsPlayerUsingAnims[playerid]) {
		StopAnimLoopPlayer(playerid);
	}

	if (PRESSED(KEY_CTRL_BACK)) {
		if (IsPlayerInAnyVehicle(playerid) && GetVehicleModel(GetPlayerVehicleID(playerid)) == 476
			&& pClass[playerid] == KAMIKAZE) {
			new Float: X, Float: Y, Float: Z;
			GetPlayerPos(playerid, X, Y, Z);

			new Float: range;
			if (pAdvancedClass[playerid]) {
				range = 15.0;
			} else {
				range = 10.0;
			}

			foreach (new x: Player) {
				if (pTeam[x] != pTeam[playerid] && IsPlayerInRangeOfPoint(x, range, X, Y, Z) && x != playerid) {
					Text_Send(playerid, $CLIENT_404x, PlayerInfo[x][PlayerName]);
					GivePlayerScore(playerid, 1);
					DamagePlayer(x, 0.0, playerid, WEAPON_EXPLOSION, BODY_PART_UNKNOWN, false);
					Text_Send(x, $KAMIKAZED);
				}
			}

			CreateExplosion(X, Y, Z, 7, 7.5);
			SetPlayerHealth(playerid, 0.0);
		}
	}

	if (PRESSED(KEY_YES)) {
		if (PlayerInfo[playerid][pAdminLevel] && IsPlayerInAnyVehicle(playerid) && GetVehicleModel(GetPlayerVehicleID(playerid)) == 592) {
			if (PUBGStarted && !PUBGOpened) {
				foreach (new i: PUBGPlayers) {
					if (GetPlayerState(i) == PLAYER_STATE_SPECTATING) {
						PlayerPlaySound(i, 15805, 0, 0, 0);
						TogglePlayerSpectating(i, false);
					}    
				}    
			}
		}

		new Float: VHP;
		GetVehicleHealth(GetPlayerVehicleID(playerid), VHP);
		if ((IsPlayerInAnyVehicle(playerid) && VHP <= 350.0) || GetVehicleModel(GetPlayerVehicleID(playerid)) == 464) {
			new Float: X, Float: Y, Float: Z;
			GetPlayerPos(playerid, X, Y, Z);
			SetPlayerPos(playerid, X, Y, Z + 200);
			PC_EmulateCommand(playerid, "/ep"); 
		}	
	}

	if (PRESSED(KEY_NO)) {
		if (AntiSK[playerid]) {
			EndProtection(playerid);
		}

		if (InDrone[playerid]) {
			InDrone[playerid] = false;

			new Float: X, Float: Y, Float: Z;
			GetPlayerPos(playerid, X, Y, Z);
			new vid = GetPlayerVehicleID(playerid);
			SetPlayerPos(playerid, gDroneLastPos[playerid][0], gDroneLastPos[playerid][1], gDroneLastPos[playerid][2]);
			CarDeleter(vid);
			foreach (new i: Player) {
				if (IsPlayerInRangeOfPoint(i, 7.5, X, Y, Z)) {
					if (i != playerid) {
						DamagePlayer(i, 0.0, playerid, WEAPON_EXPLOSION, BODY_PART_UNKNOWN, false);
						Text_Send(playerid, $CLIENT_408x, PlayerInfo[i][PlayerName]);
						Text_Send(i, $DRONE_KILLED, PlayerInfo[playerid][PlayerName]);
						GivePlayerScore(playerid, 2);
						if (IsPlayerInAnyClan(playerid)) {
							GivePlayerScore(playerid, 1);
							AddClanXP(GetPlayerClan(playerid), 2);
							foreach (new x: Player) {
								if (pClan[x] == pClan[playerid]) {
									Text_Send(x, $CLIENT_409x, PlayerInfo[playerid][PlayerName]);
								}
							}
						}
					}
				}
			}
			CreateExplosion(X, Y, Z, 6, 7.5);
		}
	}

	if (PRESSED(KEY_FIRE)) {
		if (PlayerInfo[playerid][pSpecId] != INVALID_PLAYER_ID) {
			TogglePlayerSpectating(playerid, false);
		}	
	}
	return 1;
}

//End of File
/* (c) H2O Multiplayer 2018-2020. All rights reserved. */