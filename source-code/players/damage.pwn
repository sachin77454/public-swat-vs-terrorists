/*
	SWAT vs Terrorists is a team death-match SA-MP game-mode script.
	Compatible with SA-MP 0.3.7 and later releases.

	Author: H2O
	Licensed under GNU GPLv3

	(c) 2018-2020 H2O Multiplayer. All rights reserved.
	Website: h2omultiplayer.com

	Damage System
*/

#include <YSI\y_hooks>
#include <YSI_Players\y_text> //Y_Less
loadtext mode_text[all], mode_text[client], mode_text[newcs], mode_text[dialogs], mode_text[gametexts];

//Hide damage sprite
forward HideDamage(playerid);
public HideDamage(playerid) {
	if (IsPlayerAttachedObjectSlotUsed(playerid, 8)) {
		RemovePlayerAttachedObject(playerid, 8);
	}
	return 1;
}

hook OnPlayerDamageDone(playerid, Float:amount, issuerid, weapon, bodypart) {
	if (issuerid != INVALID_PLAYER_ID) {
		new damage_string[20];
		format(damage_string, sizeof(damage_string), "-%.0f", amount);
		SetPlayerChatBubble(playerid, damage_string, 0xFF0000FF, 100.0, 2000);	

		if (amount > 44.5) {
			KillTimer(DamageTimer[playerid]);
			DamageTimer[playerid] = SetTimerEx("HideDamage", 1000, false, "i", playerid);
			SetPlayerAttachedObject(playerid, 8, 18668, 1, 1.081000, 0.000000, -1.595999, -0.699999, -4.800000, -92.500000, 1.000000, 0.000000, 1.000000);
		}
	}
	return 1;
}

hook OnPlayerDamage(&playerid, &Float:amount, &issuerid, &weapon, &bodypart) {
	if (gRappelling[playerid] || PlayerInfo[playerid][pIsAFK] || PlayerInfo[playerid][pSelecting] || PlayerInfo[playerid][pAdminDuty]
		|| pFirstSpawn[playerid] || AntiSK[playerid]) {
		return 0;
	}

	if (IsPlayerAttachedObjectSlotUsed(playerid, 8)) {
		RemovePlayerAttachedObject(playerid, 8);
	}

	if (issuerid != INVALID_PLAYER_ID) {
		if (issuerid != playerid) {
			LastDamager[playerid] = issuerid;
			LastTarget[issuerid] = playerid;

			if (IsPlayerInBase(playerid) && PlayerInfo[playerid][pDeathmatchId] == -1 && IsPlayerInAnyVehicle(issuerid) && pTeam[playerid] != pTeam[issuerid]
			   && (GetVehicleModel(GetPlayerVehicleID(issuerid)) == 432 || GetVehicleModel(GetPlayerVehicleID(issuerid)) == 520 ||
			   GetVehicleModel(GetPlayerVehicleID(issuerid)) == 425 || GetVehicleModel(GetPlayerVehicleID(issuerid)) == 447)) {
				Text_Send(issuerid, $BASERAPE);
				PlayerInfo[issuerid][pBaseRapeAttempts] ++;
						
				new Float: X, Float: Y, Float: Z;
				GetPlayerPos(issuerid, X, Y, Z);
				SetPlayerPos(issuerid, X + 1.0, Y + 1.0, Z + 1.0);
				PC_EmulateCommand(issuerid, "/ep");
				return 0;
			}

			if (AntiSK[playerid]) {
				Text_Send(issuerid, $SPY_KILL);
				return 0;
			}

			if (PlayerInfo[issuerid][pIsSpying] && PlayerInfo[issuerid][pSpyTeam] == pTeam[playerid]) {
				Text_Send(playerid, $TEAM_SPY);
			}

			if (weapon == WEAPON_CARPARK || weapon == WEAPON_HELIBLADES) {
				Text_Send(issuerid, $ILLEGAL_KILL);
				return 0;
			}	   		

			if (!Iter_Contains(PUBGPlayers, playerid) && !Iter_Contains(ePlayers, playerid) && PlayerInfo[playerid][pDeathmatchId] == -1 && !pDuelInfo[playerid][pDInMatch]
			   && !Iter_Contains(CWCLAN1, playerid) && !Iter_Contains(CWCLAN2, playerid) && pTeam[playerid] == pTeam[issuerid]) {
				Text_Send(issuerid, $TEAMMATE);
				return 0;
			}
			
			if (!Iter_Contains(PUBGPlayers, playerid) && !Iter_Contains(ePlayers, playerid) && PlayerInfo[playerid][pDeathmatchId] == -1 && !pDuelInfo[playerid][pDInMatch]
			   && !Iter_Contains(CWCLAN1, playerid) && !Iter_Contains(CWCLAN2, playerid) && IsPlayerInAnyClan(playerid) && pClan[playerid] == pClan[issuerid]) {
				Text_Send(issuerid, $CLANMATE);
				return 0;
			}

			if (EventInfo[E_STARTED] && EventInfo[E_TYPE] == 1 && Iter_Contains(ePlayers, playerid)) {
				if (pEventInfo[playerid][P_TEAM] == pEventInfo[issuerid][P_TEAM]) {
					Text_Send(issuerid, $EVENT_TEAMMATE);
					return 0;
				}
			}
			
			if (cwInfo[cw_started]) {
				if (Iter_Contains(CWCLAN1, playerid) || Iter_Contains(CWCLAN2, playerid)) {
					if (pClan[playerid] == pClan[issuerid]) {
						Text_Send(issuerid, $CLANMATE);
						return 0;
					}
				}
			}

			if (AntiSK[issuerid]) {
				EndProtection(issuerid);
			}

			PlayerInfo[playerid][pLastHitTick] = gettime() + 15;
			pIsDamaged[playerid] = 1;
			PlayerInfo[playerid][pHealthLost] += amount;
			PlayerInfo[issuerid][pDamageRate] += amount;

			if (GetPlayerConfigValue(issuerid, "HI") == 1) {
				PlayerPlaySound(issuerid, 17802, 0.0, 0.0, 0.0);
			}

			if (weapon == WEAPON_KATANA
					&& pKatanaEnhancement[issuerid]) {
				DamagePlayer(playerid, 0.0, issuerid, 255, BODY_PART_UNKNOWN, true);
				pKatanaEnhancement[issuerid] --;
				return 0; 
			}

			if (PlayerInfo[playerid][pDeathmatchId] > -1 &&
				bodypart == 4 && (weapon == 34 || weapon == 33)) {
				DamagePlayer(playerid, 0.0, issuerid, weapon, BODY_PART_UNKNOWN, true);
				Text_Send(issuerid, $NUTSHOT_KILL);
				Text_Send(playerid, $NUTSHOT);
				GivePlayerScore(issuerid, 1);
				PlayerInfo[issuerid][pNutshots]++;
				return 0;		    	
			}

			if (bodypart == 9 && (weapon == 34 || weapon == 33) && 
				((GetPlayerInterior(issuerid) == 0 && pTeam[playerid] != pTeam[issuerid]) || PlayerInfo[issuerid][pDeathmatchId] > -1)) {
				if (IsPlayerInAnyVehicle(playerid) && GetVehicleModel(GetPlayerVehicleID(playerid)) == 427) return 1;
				if (pItems[playerid][HELMET]) {
					switch (pItems[playerid][HELMET]) {
						case 1: {
							RemovePlayerItem(playerid, HELMET);
							Text_Send(playerid, $HELMET_LOST);
							PlayerPlaySound(playerid, 1131, 0.0, 0.0, 0.0);
						}	
						case 2: {
							AddPlayerItem(playerid, HELMET, -1);
							Text_Send(playerid, $HELMET_HIT);
							PlayerPlaySound(playerid, 1131, 0.0, 0.0, 0.0);
						}					    		    				    		    
					}
				} else {
					new probability = random(100), miss = 0;
					switch (probability) {
						case 0..85: miss = 0;
						default: miss = 1;
					}

					if (miss) {
						Text_Send(issuerid, $TARGET_MISS);
						return 0;
					}

					new Float: meters, Float: X, Float: Y, Float: Z;

					GetPlayerPos(playerid, X, Y, Z);
					meters = GetPlayerDistanceFromPoint(issuerid, X, Y, Z);

					if (meters < 40.0 && PlayerInfo[playerid][pDeathmatchId] == -1) {
						Text_Send(issuerid, $TARGET_CLOSE);
						return 1;
					}

					DamagePlayer(playerid, 0.0, issuerid, WEAPON_DROWN, BODY_PART_UNKNOWN, true);

					Text_Send(issuerid, $HEADSHOT_KILL);
					Text_Send(playerid, $HEADSHOT);

					PlayerPlaySound(issuerid, 1095, 0.0, 0.0, 0.0);
					Text_Send(issuerid, $CLIENT_267x, PlayerInfo[playerid][PlayerName], meters);

					Text_Send(@pVerified, $SERVER_53x, PlayerInfo[issuerid][PlayerName], PlayerInfo[playerid][PlayerName], meters);

					GivePlayerScore(issuerid, 5);

					PlayerInfo[issuerid][pHeadshots]++;
					PlayerInfo[issuerid][pHeadshotStreak]++;

					Text_Send(issuerid, $CLIENT_268x, PlayerInfo[issuerid][pHeadshotStreak], PlayerInfo[issuerid][pHeadshots]);

					switch (PlayerInfo[issuerid][pHeadshotStreak])
					{
						case 3: AddPlayerItem(issuerid, MK, 1), Text_Send(issuerid, $CLIENT_269x);
						case 6: AddPlayerItem(issuerid, MK, 2), Text_Send(issuerid, $CLIENT_270x);
						case 9: AddPlayerItem(issuerid, MK, 3), Text_Send(issuerid, $CLIENT_271x);
					}

					if (IsPlayerInAnyClan(issuerid))
					{
						AddClanXP(GetPlayerClan(issuerid), 5);
						foreach (new x: Player) {
							if (pClan[x] == pClan[issuerid]) {
								Text_Send(x, $CLIENT_544x, PlayerInfo[issuerid][PlayerName]);
							}
						}						            
					}

					return 0;
				}
			}
		}
	}    
	return 1;
}

hook OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ) {
	new slot = GetWeaponSlot(GetPlayerWeapon(playerid));
	pAmmoData[playerid][slot] --;

	if ((pClass[playerid] == SCOUT || pClass[playerid] == RECON) && weaponid == 34 &&
			hitid == BULLET_HIT_TYPE_PLAYER) {
		SetPlayerChatBubble(playerid, "+7 sniper damage", X11_BLUE, 120.0, 1000);
		DamagePlayer(hitid, 7.0, playerid, weaponid, BODY_PART_UNKNOWN, true);
		return 0;
	}

	if (gIncentFire[playerid] &&
			weaponid == WEAPON_M4 &&
			hittype == BULLET_HIT_TYPE_PLAYER &&
			pTeam[playerid] != pTeam[hitid]) {
		gIncentFire[playerid] --;
		DamagePlayer(hitid, 7.0, playerid, WEAPON_EXPLOSION, BODY_PART_UNKNOWN, true);
		CreateExplosion(fX, fY, fZ + 3, 1, 3);
		GameTextForPlayer(playerid, "~r~INCENTIVE BULLET", 2000, 3);
		SetPlayerChatBubble(playerid, "M4 Incentive Fire Enhanced", X11_DEEPPINK, 50.0, 3000);
	}

	PlayerInfo[playerid][pGunFires]++;
	PlayerInfo[playerid][pSessionGunFires]++;

	if (hittype == BULLET_HIT_TYPE_PLAYER) {
		if (hitid != INVALID_PLAYER_ID) {
			BulletStats[playerid][Bullets_Hit] ++;
			BulletStats[playerid][Group_Hits] ++;

			if (BulletStats[playerid][Group_Hits] > BulletStats[playerid][Highest_Hits]) {
				BulletStats[playerid][Highest_Hits] = BulletStats[playerid][Group_Hits];
			}
			
			if (BulletStats[playerid][Group_Misses] != 1) {
				BulletStats[playerid][Group_Misses] = 0;
			} else {
				BulletStats[playerid][Hits_Per_Miss] ++;
			}
			
			new ms_between_shots = GetTickCount() - BulletStats[playerid][Last_Shot_MS];
			BulletStats[playerid][Last_Shot_MS] = GetTickCount();
			BulletStats[playerid][Last_Hit_MS] = GetTickCount();
			BulletStats[playerid][MS_Between_Shots] = ms_between_shots;
			BulletStats[playerid][Bullet_Vectors][0] = fX, 
			BulletStats[playerid][Bullet_Vectors][1] = fY, 
			BulletStats[playerid][Bullet_Vectors][2] = fZ;

			new Float: X, Float: Y, Float: Z;
			GetPlayerPos(hitid, X, Y, Z);
			new Float: Distance = GetPlayerDistanceFromPoint(playerid, X, Y, Z);
			BulletStats[playerid][Last_Hit_Distance] = Distance;
			if (BulletStats[playerid][Last_Hit_Distance] > BulletStats[playerid][Longest_Hit_Distance]) {
				BulletStats[playerid][Longest_Hit_Distance] = BulletStats[playerid][Last_Hit_Distance];
				BulletStats[playerid][Longest_Distance_Weapon] = GetPlayerWeapon(playerid);
			}
			if (BulletStats[playerid][Last_Hit_Distance] >= BulletStats[playerid][Shortest_Hit_Distance]) {
				if (BulletStats[playerid][Shortest_Hit_Distance] == 0.0 && BulletStats[playerid][Longest_Hit_Distance] >= BulletStats[playerid][Shortest_Hit_Distance]) {
					BulletStats[playerid][Shortest_Hit_Distance] = BulletStats[playerid][Last_Hit_Distance];
				}
			}
			if (BulletStats[playerid][Shortest_Hit_Distance] > BulletStats[playerid][Last_Hit_Distance]) {
				BulletStats[playerid][Shortest_Hit_Distance] = BulletStats[playerid][Last_Hit_Distance];
			}
			new Float: HMR = floatdiv(BulletStats[playerid][Bullets_Hit], BulletStats[playerid][Bullets_Miss]);
			if (BulletStats[playerid][Hits_Per_Miss] - BulletStats[playerid][Misses_Per_Hit] > 10 ||
				BulletStats[playerid][Bullets_Hit] == HMR) {
				BulletStats[playerid][Aim_SameHMRate] ++;
			}

			if (!IsPlayerAimingAtPlayer(playerid, hitid) && weaponid != 38) {
				BulletStats[playerid][Hits_Without_Aiming] ++;
			}
		}	
	} else {
		BulletStats[playerid][Bullets_Miss] ++;
		BulletStats[playerid][Group_Misses] ++;

		if (BulletStats[playerid][Group_Misses] > BulletStats[playerid][Highest_Misses]) {
			BulletStats[playerid][Highest_Misses] = BulletStats[playerid][Group_Misses];
		}

		if (BulletStats[playerid][Group_Hits] != 1) {
			BulletStats[playerid][Group_Hits] = 0;
		} else {
			BulletStats[playerid][Misses_Per_Hit] ++;
		}

		new ms_between_shots = GetTickCount() - BulletStats[playerid][Last_Shot_MS];
		BulletStats[playerid][Last_Shot_MS] = GetTickCount();
		BulletStats[playerid][MS_Between_Shots] = ms_between_shots;
		BulletStats[playerid][Bullet_Vectors][0] = fX, 
		BulletStats[playerid][Bullet_Vectors][1] = fY, 
		BulletStats[playerid][Bullet_Vectors][2] = fZ;
	}

	if (weaponid == WEAPON_MINIGUN && !PlayerInfo[playerid][pAdminDuty] && PlayerInfo[playerid][pDeathmatchId] == -1) {
		if (pCooldown[playerid][33] > gettime()) {
			pMinigunFires[playerid] = 0;
			gMGOverheat[playerid] += 500;
			SetPlayerDrunkLevel(playerid, gMGOverheat[playerid]);
			if (gMGOverheat[playerid] >= 10000) {
				gMGOverheat[playerid] = 0;
				SetPlayerDrunkLevel(playerid, gMGOverheat[playerid]);
				AnimPlayer(playerid, "PED", "BIKE_fall_off", 4.1, 0, 0, 0, 0, 0);
				return 0;
			}

		}
		else if (pMinigunFires[playerid] > 15) {
			if (pClass[playerid] != GUNNER || !pAdvancedClass[playerid]) {
				pCooldown[playerid][33] = gettime() + 15;
			} else {
				pCooldown[playerid][33] = gettime() + 7;
			}
			Text_Send(playerid, $SPRAYALERT);
			SetPlayerDrunkLevel(playerid, 5000);
			gMGOverheat[playerid] = 1000;
			pMinigunFires[playerid] = 0;
		}

		pMinigunFires[playerid]++;
	}

	//Protect team players
	if (hitid == BULLET_HIT_TYPE_VEHICLE) {
		foreach (new i: Player) {
			if (IsPlayerInVehicle(i, hitid)) {
				if (pTeam[i] == pTeam[playerid]) {
					return 0;
				}
			}
		}
	}

	//Same as previous
	if (hittype == BULLET_HIT_TYPE_VEHICLE && IsValidVehicle(hitid) && IsVehicleUsed(hitid) && IsBulletWeapon(weaponid)) {
		foreach (new i: Player) {
			if (GetPlayerState(i) == PLAYER_STATE_DRIVER && GetPlayerVehicleID(i) == hitid && pTeam[i] == pTeam[playerid]) {
				Text_Send(playerid, $TEAMMATE);
				return 0;
			}
		}
	}
	return 1;
}

//End of File
/* (c) H2O Multiplayer 2018-2020. All rights reserved. */