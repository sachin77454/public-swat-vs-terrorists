/*
	SWAT vs Terrorists is a team death-match SA-MP game-mode script. 
	Compatible with SA-MP 0.3.7 and later releases.

	Author: H2O
	Licensed under GNU GPLv3

	(c) 2018-2020 H2O Multiplayer. All rights reserved.
	Website: h2omultiplayer.com

	Player duel system
*/

#include <YSI\y_text>
loadtext mode_text[all], mode_text[client], mode_text[newcs], mode_text[dialogs], mode_text[gametexts];

PlayerLeaveDuelCheck(playerid) {
	if (pDuelInfo[playerid][pDInMatch] == 1 && TargetOf[playerid] != INVALID_PLAYER_ID) {
		pDuelInfo[playerid][pDInMatch] = 0;
		pDuelInfo[TargetOf[playerid]][pDInMatch] = 0;

		if (!pDuelInfo[playerid][pDRCDuel]) {
			Text_Send(@pVerified, $SERVER_21x, PlayerInfo[TargetOf[playerid]][PlayerName], PlayerInfo[playerid][PlayerName], ReturnWeaponName(pDuelInfo[playerid][pDWeapon]), pDuelInfo[playerid][pDBetAmount]);
		} else {
			Text_Send(@pVerified, $SERVER_22x, PlayerInfo[TargetOf[playerid]][PlayerName], PlayerInfo[playerid][PlayerName], pDuelInfo[playerid][pDBetAmount]);
		}

		GivePlayerCash(playerid, -pDuelInfo[playerid][pDBetAmount]);
		GivePlayerCash(TargetOf[playerid], pDuelInfo[playerid][pDBetAmount]);

		PlayerInfo[playerid][pDuelsLost]++;
		PlayerInfo[TargetOf[playerid]][pDuelsWon]++;

		SpawnPlayer(TargetOf[playerid]);

		pDuelInfo[TargetOf[playerid]][pDLocked] =
		pDuelInfo[TargetOf[playerid]][pDInMatch] =
		pDuelInfo[TargetOf[playerid]][pDWeapon] =
		pDuelInfo[TargetOf[playerid]][pDAmmo] =
		pDuelInfo[TargetOf[playerid]][pDMatchesPlayed] =
		pDuelInfo[TargetOf[playerid]][pDRematchOpt] =
		pDuelInfo[TargetOf[playerid]][pDBetAmount] = 0;
		
		TargetOf[TargetOf[playerid]] = INVALID_PLAYER_ID;
		TargetOf[playerid] = INVALID_PLAYER_ID;
	}
	
	TargetOf[playerid] = INVALID_PLAYER_ID;
	pDuelInfo[playerid][pDLocked] =
	pDuelInfo[playerid][pDInMatch] =
	pDuelInfo[playerid][pDWeapon] =
	pDuelInfo[playerid][pDAmmo] =
	pDuelInfo[playerid][pDBetAmount] =
	pDuelInfo[playerid][pDInMatch] = 0;
	return 1;
}

PlayerDuelSpawn(playerid) {
	//Player spawned and is recognized by being in a duel?!
	if (pDuelInfo[playerid][pDInMatch]) {
		if (TargetOf[playerid] == INVALID_PLAYER_ID || !IsPlayerConnected(TargetOf[playerid])) {
			pDuelInfo[playerid][pDLocked] =
			pDuelInfo[playerid][pDInMatch] =
			pDuelInfo[playerid][pDWeapon] =
			pDuelInfo[playerid][pDAmmo] =
			pDuelInfo[playerid][pDMatchesPlayed] =
			pDuelInfo[playerid][pDRematchOpt] =
			pDuelInfo[playerid][pDBetAmount] = 0;
		}
		else if (pDuelInfo[playerid][pDRematchOpt] && !pDuelInfo[playerid][pDMatchesPlayed]) {
			ResetPlayerWeapons(playerid);
			ResetPlayerWeapons(TargetOf[playerid]);

			pDuelInfo[TargetOf[playerid]][pDMatchesPlayed] =
				pDuelInfo[playerid][pDMatchesPlayed] = 1;

			Text_Send(playerid, $REMATCH);
			Text_Send(TargetOf[playerid], $REMATCH);
			
			pDuelInfo[playerid][pDLocked] = 1;
			pDuelInfo[TargetOf[playerid]][pDLocked] = 1;
			pDuelInfo[playerid][pDCountDown] = pDuelInfo[TargetOf[playerid]][pDCountDown] = gettime() + 99;

			KillTimer(DelayerTimer[playerid]);
			DelayerTimer[playerid] = SetTimerEx("InitPlayer", 3000, false, "i", playerid);
			TogglePlayerControllable(playerid, false);

			KillTimer(DelayerTimer[TargetOf[playerid]]);
			DelayerTimer[TargetOf[playerid]] = SetTimerEx("InitPlayer", 3000, false, "i", TargetOf[playerid]);
			TogglePlayerControllable(TargetOf[playerid], false);

			switch (pDuelInfo[playerid][pDMapId]) {
				case 0: {
					SetPlayerPosition(playerid, "", playerid + DUEL_WORLD, 0, 1358.6832,2185.3911,11.0156,147.3334);
					SetPlayerPosition(TargetOf[playerid], "", playerid + DUEL_WORLD, 0, 1317.3516,2120.9395,11.0156,327.8713);
				}
				case 1: {
					SetPlayerPosition(playerid, "", playerid + DUEL_WORLD, 10, -1018.2189,1056.7441,1342.9358,53.6926);
					SetPlayerPosition(TargetOf[playerid], "", playerid + DUEL_WORLD, 10, -1053.4242,1087.2908,1343.0204,230.7042);
				}
				case 2: {
					SetPlayerPosition(playerid, "", playerid + DUEL_WORLD, 3, 298.0534,176.0552,1007.1719,91.2696);
					SetPlayerPosition(TargetOf[playerid], "", playerid + DUEL_WORLD, 3, 238.5584,178.5376,1003.0300,267.9679);
				}
				case 3: {
					SetPlayerPosition(playerid, "", playerid + DUEL_WORLD, 3, 4888.9790,149.8565,15.1086);
					SetPlayerPosition(TargetOf[playerid], "", playerid + DUEL_WORLD, 3, 4858.3604,132.1908,15.0253);
				}
			}

			return 1;
		} else {
			pDuelInfo[playerid][pDInMatch] = 0;
			pDuelInfo[TargetOf[playerid]][pDInMatch] = 0;

			if (!pDuelInfo[playerid][pDRCDuel]) {
				Text_Send(@pVerified, $SERVER_21x, PlayerInfo[TargetOf[playerid]][PlayerName], PlayerInfo[playerid][PlayerName], ReturnWeaponName(pDuelInfo[playerid][pDWeapon]), pDuelInfo[playerid][pDBetAmount]);
			} else {
				Text_Send(@pVerified, $SERVER_22x, PlayerInfo[TargetOf[playerid]][PlayerName], PlayerInfo[playerid][PlayerName], pDuelInfo[playerid][pDBetAmount]);
			}

			GivePlayerCash(playerid, -pDuelInfo[playerid][pDBetAmount]);
			GivePlayerCash(TargetOf[playerid], pDuelInfo[playerid][pDBetAmount]);

			PlayerInfo[playerid][pDuelsLost]++;
			PlayerInfo[TargetOf[playerid]][pDuelsWon]++;

			SpawnPlayer(TargetOf[playerid]);

			pDuelInfo[TargetOf[playerid]][pDLocked] =
			pDuelInfo[TargetOf[playerid]][pDInMatch] =
			pDuelInfo[TargetOf[playerid]][pDWeapon] =
			pDuelInfo[TargetOf[playerid]][pDAmmo] =
			pDuelInfo[TargetOf[playerid]][pDMatchesPlayed] =
			pDuelInfo[TargetOf[playerid]][pDRematchOpt] =
			pDuelInfo[TargetOf[playerid]][pDBetAmount] = 0;

			TargetOf[TargetOf[playerid]] = INVALID_PLAYER_ID;
			TargetOf[playerid] = INVALID_PLAYER_ID;
		}
	}

	//Important duel stuff
	TargetOf[playerid] = INVALID_PLAYER_ID;
	pDuelInfo[playerid][pDLocked] =
	pDuelInfo[playerid][pDInMatch] =
	pDuelInfo[playerid][pDWeapon] =
	pDuelInfo[playerid][pDAmmo] =
	pDuelInfo[playerid][pDBetAmount] =
	pDuelInfo[playerid][pDInMatch] = 0;
	return 1;
}

//Duel Commands

CMD:duelers(playerid) {
	new sub_holder[27], string[256], count = 0;

	foreach (new i: Player) {
		if (pDuelInfo[i][pDInMatch]) {
			format(sub_holder, sizeof(sub_holder), "%s\t%s\t%s\t$%d\n", PlayerInfo[i][PlayerName], 
				PlayerInfo[TargetOf[i]][PlayerName], ReturnWeaponName(GetPlayerWeapon(i)), pDuelInfo[i][pDBetAmount]);
			strcat(string, sub_holder);

			count = 1;
		}
	}

	if (count) {
		Dialog_Show(playerid, DIALOG_STYLE_TABLIST, "Duelers", string, "X", "");
	}  else Text_Send(playerid, $CLIENT_423x);
	return 1;
}

CMD:duel(playerid, params[]) {
	if (pDuelInfo[playerid][pDInMatch] == 1) return Text_Send(playerid, $COMMAND_INDUEL);
	if (PlayerInfo[playerid][pDeathmatchId] > -1) return Text_Send(playerid, $COMMAND_INDM);
	if (Iter_Contains(ePlayers, playerid)) return Text_Send(playerid, $COMMAND_INEVENT);
	if (Iter_Contains(CWCLAN1, playerid) || Iter_Contains(CWCLAN2, playerid)) return Text_Send(playerid, $COMMAND_INCW);
	if (!IsPlayerSpawned(playerid)) return Text_Send(playerid, $COMMAND_NOTSPAWNED);
	if (PlayerInfo[playerid][pAdminDuty]) return Text_Send(playerid, $COMMAND_ADMINDUTY);
	if (Iter_Contains(PUBGPlayers, playerid)) return Text_Send(playerid, $COMMAND_INPUBG);
	if (PlayerInfo[playerid][pLastHitTick] > gettime()) return Text_Send(playerid, $JUSTHIT, PlayerInfo[playerid][pLastHitTick] - gettime());

	if (pDuelInfo[playerid][pDLocked] == 0 && pDuelInfo[playerid][pDInMatch] == 0) {
		new
			ID, bet, rematch, rcduel;
		if (sscanf(params, "uiii", ID, bet, rematch, rcduel)) return ShowSyntax(playerid, "/duel [playerid/name] [bet cash] [rematch (0-1)] [rcduel (0-1)]");
		if (!IsPlayerConnected(ID) || ID == playerid || !IsPlayerSpawned(ID) || GetPlayerConfigValue(ID, "NODUEL") == 1 || pDuelInfo[ID][pDInMatch] == 1 ||
			PlayerInfo[ID][pDeathmatchId] > -1 || Iter_Contains(ePlayers, ID) ||
			Iter_Contains(CWCLAN1, ID) || Iter_Contains(CWCLAN2, ID) ||
			PlayerInfo[ID][pAdminDuty] || Iter_Contains(PUBGPlayers, ID)) return Text_Send(playerid, $CLIENT_482x);

		if (!pDuelInfo[ID][pDLocked]) {
			if (AntiSK[playerid] == 1 || AntiSK[ID] == 1 || PlayerInfo[ID][pAdminDuty] == 1) return Text_Send(playerid, $CLIENT_482x);
			if (GetPlayerCash(playerid) < bet || GetPlayerCash(ID) < bet) return Text_Send(playerid, $CLIENT_483x);
			if (bet > svtconf[max_duel_bets] || bet < 150) {
				new string[95];
				format(string, sizeof(string), "Bet: $150-%d", svtconf[max_duel_bets]);
				SendClientMessage(playerid, X11_RED2, string);
				return 1;
			}

			if (rematch > 1 || rematch < 0) return ShowSyntax(playerid, "Rematch opt: 0-1");
			if (rcduel > 1 || rcduel < 0) return ShowSyntax(playerid, "RC duel opt: 0-1");

			new sub_str[30], weaponstr[1024];

			for (new i = 0; i < sizeof(WeaponInfo); i++) {
				format(sub_str, sizeof(sub_str), "{00CC00}%s\n", ReturnWeaponName(WeaponInfo[i][Weapon_Id]));
				strcat(weaponstr, sub_str);
			}

			inline DuelMap(pid, dialogid, response, listitem, string:inputtext[]) {
				#pragma unused dialogid, inputtext
				if (!response) return TargetOf[pid] = INVALID_PLAYER_ID;
				if (TargetOf[pid] != INVALID_PLAYER_ID && IsPlayerConnected(TargetOf[pid])) {
					if (pDuelInfo[TargetOf[pid]][pDInMatch] == 0 && pDuelInfo[TargetOf[pid]][pDLocked] == 0) {
						if (AntiSK[TargetOf[pid]] == 1) return Text_Send(pid, $CLIENT_482x);

						Text_Send(pid, $CLIENT_484x, ReturnWeaponName(pDuelInfo[pid][pDWeapon]), PlayerInfo[TargetOf[pid]][PlayerName], pDuelInfo[pid][pDBetAmount]);

						TargetOf[TargetOf[pid]] = pid;     
						pDuelInfo[pid][pDMapId] = listitem;

						Text_Send(TargetOf[pid], $CLIENT_485x, PlayerInfo[pid][PlayerName], ReturnWeaponName(pDuelInfo[pid][pDWeapon]), pDuelInfo[pid][pDBetAmount], (pDuelInfo[pid][pDRematchOpt] == 1) ? ("Yes") : ("No"));
						Text_Send(TargetOf[pid], $CLIENT_486x);

						pDuelInfo[pid][pDInvitePeriod] = gettime() + 50;
						pDuelInfo[TargetOf[pid]][pDInvitePeriod] = gettime() + 50;
						pDuelInfo[pid][pDLocked] = 1;
						pDuelInfo[TargetOf[pid]][pDLocked] = 1;
						PlayerInfo[pid][pDuelRequests] ++;
					}
				}  else Text_Send(pid, $CLIENT_487x);
			}

			if (!rcduel) {
				inline DuelWeapon2(pid, dialogid, response, listitem, string:inputtext[]) {
					#pragma unused dialogid, inputtext
					if (!response) return TargetOf[pid] = INVALID_PLAYER_ID;

					Dialog_ShowCallback(pid, using inline DuelMap, DIALOG_STYLE_LIST, "Select Map:", "Stadium\nBattlefield\nLVPD\nDocks Arena", ">>", "Exit");

					pDuelInfo[pid][pDWeapon2] = WeaponInfo[listitem][Weapon_Id];
					pDuelInfo[pid][pDAmmo2] = 9999;
				}

				inline DuelWeapon1(pid, dialogid, response, listitem, string:inputtext[]) {
					#pragma unused dialogid, inputtext
					if (!response) return TargetOf[pid] = INVALID_PLAYER_ID;

					for (new i = 0; i < sizeof(WeaponInfo); i++) {
						format(sub_str, sizeof(sub_str), "{00CC00}%s\n", ReturnWeaponName(WeaponInfo[i][Weapon_Id]));
						strcat(weaponstr, sub_str);
					}

					Dialog_ShowCallback(pid, using inline DuelWeapon2, DIALOG_STYLE_LIST, "Select Weapon (2):", weaponstr, ">>", "Exit");

					pDuelInfo[pid][pDWeapon] = WeaponInfo[listitem][Weapon_Id];
					pDuelInfo[pid][pDAmmo] = 9999;
				}
				Dialog_ShowCallback(playerid, using inline DuelWeapon1, DIALOG_STYLE_LIST, "Select Weapon (1):", weaponstr, ">>", "Exit");
			} else {
				Dialog_ShowCallback(playerid, using inline DuelMap, DIALOG_STYLE_LIST, "Select RC Duel Map:", "Stadium\nBattlefield\nLVPD\nDocks Arena", ">>", "Exit");
			}
			
			TargetOf[playerid] = ID;
			pDuelInfo[playerid][pDBetAmount] = bet;
			pDuelInfo[playerid][pDRematchOpt] = rematch;
			pDuelInfo[playerid][pDRCDuel] = rcduel;
			pDuelInfo[playerid][pDInvitePeriod] = gettime() + 30;

			printf("%s[%d] sent duel to %s[%d] for %d - rematch: %d, rcduel: %d", PlayerInfo[playerid][PlayerName], playerid, PlayerInfo[ID][PlayerName], ID, bet, rematch, rcduel);
		}  else Text_Send(playerid, $CLIENT_487x);
	} else {
		Text_Send(playerid, $CLIENT_487x);
	}
	return 1;
}

CMD:noduel(playerid) {
	if (pDuelInfo[playerid][pDInMatch]) return Text_Send(playerid, $COMMAND_INDUEL);
	if (GetPlayerConfigValue(playerid, "NODUEL") == 1) {
		Text_Send(playerid, $CLIENT_488x);
		SetPlayerConfigValue(playerid, "NODUEL", 0);
		printf("Player %s[%d] decided to receive duels.", PlayerInfo[playerid][PlayerName], playerid);
	}
	else
	{
		Text_Send(playerid, $CLIENT_489x);
		SetPlayerConfigValue(playerid, "NODUEL", 1);
		printf("Player %s[%d] decided not to receive duels.", PlayerInfo[playerid][PlayerName], playerid);
	}
	return 1;
}

CMD:acceptduel(playerid) {
	if (gettime() > pDuelInfo[playerid][pDInvitePeriod] || !pDuelInfo[playerid][pDLocked]) {
		return Text_Send(playerid, $CLIENT_490x);
	}

	if (TargetOf[playerid] == INVALID_PLAYER_ID || !IsPlayerConnected(TargetOf[playerid])) {
		pDuelInfo[playerid][pDInMatch] = 0;
		pDuelInfo[playerid][pDLocked] = 0;
		TargetOf[playerid] = INVALID_PLAYER_ID;

		Text_Send(playerid, $CLIENT_491x);
		return 1;
	}

	if (!IsPlayerSpawned(TargetOf[playerid])) {
		pDuelInfo[playerid][pDLocked] = 0;
		pDuelInfo[TargetOf[playerid]][pDLocked] = 0;
		TargetOf[playerid] = INVALID_PLAYER_ID;

		Text_Send(playerid, $CLIENT_492x);
		return 1;
	}

	Text_Send(@pVerified, $SERVER_69x, PlayerInfo[TargetOf[playerid]][PlayerName], PlayerInfo[playerid][PlayerName], pDuelInfo[TargetOf[playerid]][pDBetAmount]);

	ResetPlayerWeapons(playerid);
	ResetPlayerWeapons(TargetOf[playerid]);

	pDuelInfo[playerid][pDCountDown] = pDuelInfo[TargetOf[playerid]][pDCountDown] = gettime() + 99;
	pDuelInfo[playerid][pDBetAmount] = pDuelInfo[TargetOf[playerid]][pDBetAmount];
	pDuelInfo[playerid][pDMapId] = pDuelInfo[TargetOf[playerid]][pDMapId];
	pDuelInfo[playerid][pDWeapon] = pDuelInfo[TargetOf[playerid]][pDWeapon];
	pDuelInfo[playerid][pDAmmo] = pDuelInfo[TargetOf[playerid]][pDAmmo];
	pDuelInfo[playerid][pDWeapon2] = pDuelInfo[TargetOf[playerid]][pDWeapon2];
	pDuelInfo[playerid][pDAmmo2] = pDuelInfo[TargetOf[playerid]][pDAmmo2];
	pDuelInfo[playerid][pDInMatch] = pDuelInfo[TargetOf[playerid]][pDInMatch] = 1;
	pDuelInfo[playerid][pDRematchOpt] = pDuelInfo[TargetOf[playerid]][pDRematchOpt];
	pDuelInfo[playerid][pDMatchesPlayed] = pDuelInfo[TargetOf[playerid]][pDMatchesPlayed] = 0;
	pDuelInfo[playerid][pDRCDuel] = pDuelInfo[TargetOf[playerid]][pDRCDuel];

	if (pDuelInfo[playerid][pDBetAmount] > PlayerInfo[playerid][pHighestBet]) {
		PlayerInfo[playerid][pHighestBet] = pDuelInfo[playerid][pDBetAmount];
	}

	if (pDuelInfo[TargetOf[playerid]][pDBetAmount] > PlayerInfo[TargetOf[playerid]][pHighestBet]) {
		PlayerInfo[TargetOf[playerid]][pHighestBet] = pDuelInfo[TargetOf[playerid]][pDBetAmount];
	}

	PlayerInfo[playerid][pDuelsAccepted] ++;

	PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
	PlayerPlaySound(TargetOf[playerid], 1057, 0.0, 0.0, 0.0);

	Text_Send(playerid, $READY, 1000, 3);
	Text_Send(TargetOf[playerid], $READY, 1000, 3);

	KillTimer(DelayerTimer[playerid]);
	DelayerTimer[playerid] = SetTimerEx("InitPlayer", 3000, false, "i", playerid);
	TogglePlayerControllable(playerid, false);

	KillTimer(DelayerTimer[TargetOf[playerid]]);
	DelayerTimer[TargetOf[playerid]] = SetTimerEx("InitPlayer", 3000, false, "i", TargetOf[playerid]);
	TogglePlayerControllable(TargetOf[playerid], false);

	switch (pDuelInfo[playerid][pDMapId]) {
		case 0: {
			SetPlayerPosition(playerid, "", playerid + DUEL_WORLD, 0, 1358.6832,2185.3911,11.0156,147.3334);
			SetPlayerPosition(TargetOf[playerid], "", playerid + DUEL_WORLD, 0, 1317.3516,2120.9395,11.0156,327.8713);
		}
		case 1: {
			SetPlayerPosition(playerid, "", playerid + DUEL_WORLD, 10, -1018.2189,1056.7441,1342.9358,53.6926);
			SetPlayerPosition(TargetOf[playerid], "", playerid + DUEL_WORLD, 10, -1053.4242,1087.2908,1343.0204,230.7042);
		}
		case 2: {
			SetPlayerPosition(playerid, "", playerid + DUEL_WORLD, 3, 298.0534,176.0552,1007.1719,91.2696);
			SetPlayerPosition(TargetOf[playerid], "", playerid + DUEL_WORLD, 3, 238.5584,178.5376,1003.0300,267.9679);
		}
		case 3: {
			SetPlayerPosition(playerid, "", playerid + DUEL_WORLD, 3, 4888.9790,149.8565,15.1086);
			SetPlayerPosition(TargetOf[playerid], "", playerid + DUEL_WORLD, 3, 4858.3604,132.1908,15.0253);	
		}				
	}
	return 1;
}

CMD:refuseduel(playerid) {
	if (gettime() > pDuelInfo[playerid][pDInvitePeriod]) {
		return Text_Send(playerid, $CLIENT_490x);
	}

	if (TargetOf[playerid] != INVALID_PLAYER_ID) {
		Text_Send(TargetOf[playerid], $CLIENT_494x);
		Text_Send(playerid, $CLIENT_493x);
		pDuelInfo[TargetOf[playerid]][pDInMatch] = 0;
		pDuelInfo[TargetOf[playerid]][pDLocked] = 0;
		TargetOf[TargetOf[playerid]] = INVALID_PLAYER_ID;
		pDuelInfo[playerid][pDInMatch] = 0;
		pDuelInfo[playerid][pDLocked] = 0;
		PlayerInfo[TargetOf[playerid]][pDuelsRefusedByOthers] ++;
		TargetOf[playerid] = INVALID_PLAYER_ID;
		PlayerInfo[playerid][pDuelsRefusedByPlayer] ++;
	}
	return 1;
}

//End of File
/* (c) H2O Multiplayer 2018-2020. All rights reserved. */