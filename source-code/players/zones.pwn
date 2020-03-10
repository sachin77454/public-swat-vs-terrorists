/*
	SWAT vs Terrorists is a team death-match SA-MP game-mode script. 
	Compatible with SA-MP 0.3.7 and later releases.

	Author: H2O
	Licensed under GNU GPLv3

	(c) 2018-2020 H2O Multiplayer. All rights reserved.
	Website: h2omultiplayer.com

	This file includes everything related to the capture system
*/

#include <YSI_Coding\y_hooks>

//Support for y_text, load language files...
#include <YSI_Players\y_text> //Y_Less
loadtext mode_text[all], mode_text[client], mode_text[newcs], mode_text[dialogs], mode_text[gametexts];

//Update capture zones statuts
forward OnZoneUpdate(zone);
public OnZoneUpdate(zone) {
	if (ZoneInfo[zone][Zone_Attacker] != INVALID_PLAYER_ID) {
		if (ZoneInfo[zone][Zone_Attacked] == true) {
			new text[290];

			if (!IsPlayerConnected(ZoneInfo[zone][Zone_Attacker]) || ZoneInfo[zone][Zone_Attacker] == INVALID_PLAYER_ID ||
				!IsPlayerInDynamicCP(ZoneInfo[zone][Zone_Attacker], ZoneInfo[zone][Zone_Checkpoint]) || PlayerInfo[ZoneInfo[zone][Zone_Attacker]][pIsAFK]) {
				KillTimer(ZoneInfo[zone][Zone_Timer]);
				ZoneInfo[zone][Zone_Attacked] = false;
				
				GangZoneStopFlashForAll(ZoneInfo[zone][Zone_Id]);

				ZoneInfo[zone][Zone_Attacker] = INVALID_PLAYER_ID;

				new title[100];
				format(title, sizeof(title), "%s (Owned by {%06x}%s{FFFFFF})", ZoneInfo[zone][Zone_Name], TeamInfo[ZoneInfo[zone][Zone_Owner]][Team_Color] >>> 8, TeamInfo[ZoneInfo[zone][Zone_Owner]][Team_Name]);
				UpdateDynamic3DTextLabelText(ZoneInfo[zone][Zone_Label], 0xFFFFFFFF, title);
				return 1;
			}

			foreach(new i: Player) {
				if (IsPlayerInDynamicCP(i, ZoneInfo[zone][Zone_Checkpoint]) && !PlayerInfo[i][pAdminDuty] && GetPlayerState(i) != PLAYER_STATE_SPECTATING
					&& pTeam[i] == pTeam[ZoneInfo[zone][Zone_Attacker]]) {
					SetPlayerProgressBarValue(i, Player_ProgressBar[i], ZoneInfo[zone][Zone_CapTime]);

					new Float: Progress = floatdiv(ZoneInfo[zone][Zone_CapTime], 20) * 100;
					format(text, sizeof(text), "~w~\nProgress %0.1f/100...", Progress);
					PlayerTextDrawSetString(i, ProgressTD[i], text);
					PlayerTextDrawShow(i, ProgressTD[i]);

					new title[100];
					format(title, sizeof(title), "%s (Owned by %s)\n"IVORY"Attacked by %s\nTroops (%d)\nProgress %0.1f/100", ZoneInfo[zone][Zone_Name],
						TeamInfo[ZoneInfo[zone][Zone_Owner]][Team_Name], TeamInfo[pTeam[i]][Team_Name], ZoneInfo[zone][Zone_Attackers], Progress);
					UpdateDynamic3DTextLabelText(ZoneInfo[zone][Zone_Label], 0xFFFFFFFF, title);
				}
			}

			switch (PlayerInfo[ZoneInfo[zone][Zone_Attacker]][pDonorLevel]) {
				case 1: ZoneInfo[zone][Zone_CapTime] += 0.7 * ZoneInfo[zone][Zone_Attackers];
				case 2: ZoneInfo[zone][Zone_CapTime] += 1.2 * ZoneInfo[zone][Zone_Attackers];
				case 3: ZoneInfo[zone][Zone_CapTime] += 1.5 * ZoneInfo[zone][Zone_Attackers];
				case 4: ZoneInfo[zone][Zone_CapTime] += 1.9 * ZoneInfo[zone][Zone_Attackers];
				case 5: ZoneInfo[zone][Zone_CapTime] += 2.1 * ZoneInfo[zone][Zone_Attackers];
				default: {
					ZoneInfo[zone][Zone_CapTime] += 0.5 * ZoneInfo[zone][Zone_Attackers];
				}	
			}

			if (ZoneInfo[zone][Zone_CapTime] > 20.0) {
				PlayAudioStreamForPlayer(ZoneInfo[zone][Zone_Attacker], "http://51.254.181.90/server/progress.mp3", 0.0, 0.0, 0.0, 0.0, 0);
				Text_Send(ZoneInfo[zone][Zone_Attacker], $ZONE_CAPTURED, ZoneInfo[zone][Zone_Name]);

				new crate = random(100);
				switch (crate) {
					case 0..15: {
						PlayerInfo[ZoneInfo[zone][Zone_Attacker]][pCrates] ++;
						Text_Send(ZoneInfo[zone][Zone_Attacker], $CRATE_RECEIVED);
					}
				}

				PlayerInfo[ZoneInfo[zone][Zone_Attacker]][pEXPEarned] += 2;

				switch (zone) {
					case HOSPITAL: {
						foreach (new i: Player) {
							if (pTeam[i] == pTeam[ZoneInfo[zone][Zone_Attacker]]
								&& !GetPlayerInterior(i) && !GetPlayerVirtualWorld(i) && IsPlayerSpawned(i)) {
								AddPlayerItem(i, MK, 4);
								Text_Send(i, "~w~HOSPITAL CAPTURED~n~~n~~g~+4 MEDKITS", 3000, 3);
								Text_Send(i, $HOSPITAL_CAPTURED);
							}
						}
					}
					case SNIPERHUT: {
						foreach (new i: Player) {
							if (pTeam[i] == pTeam[ZoneInfo[zone][Zone_Attacker]]
								&& !GetPlayerInterior(i) && !GetPlayerVirtualWorld(i) && IsPlayerSpawned(i)) {
								GivePlayerWeapon(i, 34, 10);
								Text_Send(i, $HUT_CAPTURED);
							}
						}
					}
					case DESERTCAMP: {
						foreach (new i: Player) {
							if (pTeam[i] == pTeam[ZoneInfo[zone][Zone_Attacker]]
								&& !GetPlayerInterior(i) && !GetPlayerVirtualWorld(i) && IsPlayerSpawned(i)) {
								AddPlayerItem(i, MK, 2);
								Text_Send(i, $CAMP_CAPTURED);
							}
						}
					}
					case WEAPONDEPOT: {
						foreach (new i: Player) {
							if (pTeam[i] == pTeam[ZoneInfo[zone][Zone_Attacker]]
								&& !GetPlayerInterior(i) && !GetPlayerVirtualWorld(i) && IsPlayerSpawned(i)) {
								GivePlayerWeapon(i, WEAPON_TEC9, 50);
								Text_Send(i, $WDEPOT_CAPTURED);
							}
						}
					}
					case AMMODEPOT: {
						foreach (new i: Player) {
							if (pTeam[i] == pTeam[ZoneInfo[zone][Zone_Attacker]]
								&& !GetPlayerInterior(i) && !GetPlayerVirtualWorld(i) && IsPlayerSpawned(i)) {
								GivePlayerWeapon(i, WEAPON_SAWEDOFF, 25);
								Text_Send(i, $ADEPOT_CAPTURED);
							}
						}
					} 
					case NUKE_STATION: {
						foreach (new i: Player) {
							if (pTeam[i] == pTeam[ZoneInfo[zone][Zone_Attacker]]
								&& !GetPlayerInterior(i) && !GetPlayerVirtualWorld(i) && IsPlayerSpawned(i)) {
								GivePlayerWeapon(i, WEAPON_ROCKETLAUNCHER, 3);
								Text_Send(i, $NUKE_CAPTURED);
							}
						}
					}
				}
						
				if (IsPlayerInAnyClan(ZoneInfo[zone][Zone_Attacker])) {
					switch (zone) {	
						case LV_AIR: {
							gClanLVAWar = 1;
							gClanLVAOwner = pClan[ZoneInfo[zone][Zone_Attacker]];
							gClanLVACD = gettime() + 35;
							Text_Send(ZoneInfo[zone][Zone_Attacker], $CLAN_CAPTURED_LVA);
						}
						default: {
							AddClanXP(GetPlayerClan(ZoneInfo[zone][Zone_Attacker]), 2);
							foreach(new i: Player) {
								if (pClan[i] == pClan[ZoneInfo[zone][Zone_Attacker]]) {
									Text_Send(i, $ZONE_CLAN_BONUS, PlayerInfo[ZoneInfo[zone][Zone_Attacker]][PlayerName], ZoneInfo[zone][Zone_Name]);
									if (i != ZoneInfo[zone][Zone_Attacker]) {
										PlayerPlaySound(i, 1057, 0.0, 0.0, 0.0);
									}
								}
							}
						}
					}	
				}

				PlayerInfo[ZoneInfo[zone][Zone_Attacker]][pCaptureStreak]++;

				GivePlayerScore(ZoneInfo[zone][Zone_Attacker], 5);
				GivePlayerCash(ZoneInfo[zone][Zone_Attacker], 5000);

				PlayerTextDrawHide(ZoneInfo[zone][Zone_Attacker], ProgressTD[ZoneInfo[zone][Zone_Attacker]]);
				PlayerInfo[ZoneInfo[zone][Zone_Attacker]][pZonesCaptured]++;
				if (PlayerInfo[ZoneInfo[zone][Zone_Attacker]][pCaptureStreak] > PlayerInfo[ZoneInfo[zone][Zone_Attacker]][pHighestCaptures]) {
					PlayerInfo[ZoneInfo[zone][Zone_Attacker]][pHighestCaptures] = PlayerInfo[ZoneInfo[zone][Zone_Attacker]][pCaptureStreak];
				}				
				
				switch (PlayerInfo[ZoneInfo[zone][Zone_Attacker]][pCaptureStreak]) {
					case 5: {
						Text_Send(ZoneInfo[zone][Zone_Attacker], $CAPTURE_STREAK, 5, 2);
						GivePlayerScore(ZoneInfo[zone][Zone_Attacker], 2);
					}
					case 10: {
						Text_Send(ZoneInfo[zone][Zone_Attacker], $CAPTURE_STREAK, 10, 3);
						GivePlayerScore(ZoneInfo[zone][Zone_Attacker], 3);

					}
					case 15: {
						Text_Send(ZoneInfo[zone][Zone_Attacker], $CAPTURE_STREAK, 15, 4);
						GivePlayerScore(ZoneInfo[zone][Zone_Attacker], 4);
					}
					case 20: {
						Text_Send(ZoneInfo[zone][Zone_Attacker], $CAPTURE_STREAK, 20, 5);
						GivePlayerScore(ZoneInfo[zone][Zone_Attacker], 5);
					}
					case 25: {
						Text_Send(ZoneInfo[zone][Zone_Attacker], $CAPTURE_STREAK, 25, 6);
						GivePlayerScore(ZoneInfo[zone][Zone_Attacker], 6);
					}
					case 30: {
						Text_Send(ZoneInfo[zone][Zone_Attacker], $CAPTURE_STREAK, 30, 7);
						GivePlayerScore(ZoneInfo[zone][Zone_Attacker], 7);
					}
				}

				if (PlayerInfo[ZoneInfo[zone][Zone_Attacker]][pCaptureStreak] >= 5) {
					Text_Send(@pVerified, $SERVER_17x, PlayerInfo[ZoneInfo[zone][Zone_Attacker]][PlayerName], PlayerInfo[ZoneInfo[zone][Zone_Attacker]][pCaptureStreak]);
				}

				foreach(new e: Player) {
					if (IsPlayerSpawned(e) && (e != ZoneInfo[zone][Zone_Attacker]) && (pTeam[e] == pTeam[ZoneInfo[zone][Zone_Attacker]]) && GetPlayerVirtualWorld(e) == 0
						&& !PlayerInfo[e][pAdminDuty] && !PlayerInfo[e][pIsAFK] && GetPlayerInterior(e) == 0) {
						GivePlayerScore(e, 1);
						Text_Send(e, $TEAM_CAPTURE_BONUS, ZoneInfo[zone][Zone_Name]);
					}

					if (IsPlayerSpawned(e) && IsPlayerInDynamicCP(e, ZoneInfo[zone][Zone_Checkpoint])) {
						HidePlayerProgressBar(e, Player_ProgressBar[e]);
						PlayerTextDrawHide(e, ProgressTD[e]);

						if (e != ZoneInfo[zone][Zone_Attacker] && pTeam[e] == pTeam[ZoneInfo[zone][Zone_Attacker]] && !IsPlayerInAnyVehicle(e)) {
							GivePlayerScore(e, 2);
							Text_Send(e, $ASSIST_CAPTURE_BONUS, PlayerInfo[ZoneInfo[zone][Zone_Attacker]][PlayerName], ZoneInfo[zone][Zone_Attacker], ZoneInfo[zone][Zone_Name]);
							PlayerInfo[e][pCapturAssists] ++;
							if (PlayerInfo[e][pCaptureStreak] > PlayerInfo[e][pHighestCaptureAssists]) {
								PlayerInfo[e][pHighestCaptureAssists] = PlayerInfo[e][pCaptureStreak];
							}	
							PlayAudioStreamForPlayer(e, "http://51.254.181.90/server/progress.mp3", 0.0, 0.0, 0.0, 0.0, 0);
						}
					}

					if (IsPlayerSpawned(e) && GetPlayerInterior(e) == 0) {
						if (pTeam[e] == ZoneInfo[zone][Zone_Owner] && GetPlayerVirtualWorld(e) == 0
							&& !PlayerInfo[e][pAdminDuty] && !PlayerInfo[e][pIsAFK]) {
							if (PlayerInfo[e][pDonorLevel] < 5) {
								Text_Send(e, $ZONE_LOST, ZoneInfo[zone][Zone_Name]);
								GivePlayerScore(e, -2);
							} else {
								Text_Send(e, $VIP_LOST_ZONE, ZoneInfo[zone][Zone_Name]);
							}	
						}
					}
				}

				GangZoneStopFlashForAll(ZoneInfo[zone][Zone_Id]);
				
				GangZoneShowForAll(ZoneInfo[zone][Zone_Id], ALPHA(TeamInfo[pTeam[ZoneInfo[zone][Zone_Attacker]]][Team_Color], 100));
				ZoneInfo[zone][Zone_Attacked] = false;

				Text_Send(@pVerified, $SERVER_42x, TeamInfo[pTeam[ZoneInfo[zone][Zone_Attacker]]][Team_Name], ZoneInfo[zone][Zone_Name]);

				if (WarInfo[War_Started] == 1) {
					if ((pTeam[ZoneInfo[zone][Zone_Attacker]] == WarInfo[War_Team1] && ZoneInfo[zone][Zone_Owner] == WarInfo[War_Team2]) ||
					(pTeam[ZoneInfo[zone][Zone_Attacker]] == WarInfo[War_Team2] && ZoneInfo[zone][Zone_Owner] == WarInfo[War_Team1])) {
						AddTeamWarScore(ZoneInfo[zone][Zone_Attacker], 2);
					}
				}

				ZoneInfo[zone][Zone_Attackers] = 0;
				ZoneInfo[zone][Zone_Owner] = pTeam[ZoneInfo[zone][Zone_Attacker]];
				ZoneInfo[zone][Zone_Attacker] = INVALID_PLAYER_ID;

				new title[100];
				format(title, sizeof(title), "%s (Owned by {%06x}%s{FFFFFF})", ZoneInfo[zone][Zone_Name], TeamInfo[ZoneInfo[zone][Zone_Owner]][Team_Color] >>> 8, TeamInfo[ZoneInfo[zone][Zone_Owner]][Team_Name]);
				UpdateDynamic3DTextLabelText(ZoneInfo[zone][Zone_Label], 0xFFFFFFFF, title);
			}
		} else {
			GangZoneStopFlashForAll(ZoneInfo[zone][Zone_Id]);
			
			ZoneInfo[zone][Zone_Attacker] = INVALID_PLAYER_ID;

			KillTimer(ZoneInfo[zone][Zone_Timer]);
			ZoneInfo[zone][Zone_Attacked] = false;
		}
	} else {
		GangZoneStopFlashForAll(ZoneInfo[zone][Zone_Id]);

		ZoneInfo[zone][Zone_Attacker] = INVALID_PLAYER_ID;

		KillTimer(ZoneInfo[zone][Zone_Timer]);
		ZoneInfo[zone][Zone_Attacked] = false;
	}
	return 1;
}

//Add the capture points
LoadZones() {
	new zones = 0;
	for (new i = 0; i < sizeof(ZoneInfo); i++) {
		ZoneInfo[i][Zone_Owner] = random(MAX_TEAMS - 1);
		ZoneInfo[i][Zone_Attacked] = false;
		KillTimer(ZoneInfo[i][Zone_Timer]);
		ZoneInfo[i][Zone_Label] = CreateDynamic3DTextLabel(ZoneInfo[i][Zone_Name], 0xFFFFFFFF, ZoneInfo[i][Zone_CapturePoint][0], ZoneInfo[i][Zone_CapturePoint][1], ZoneInfo[i][Zone_CapturePoint][2], 50.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, 0, 0);
		ZoneInfo[i][Zone_Attacker] = INVALID_PLAYER_ID;
		ZoneInfo[i][Zone_PickupId] = CreatePickup(1314, 1, ZoneInfo[i][Zone_CapturePoint][0], ZoneInfo[i][Zone_CapturePoint][1], ZoneInfo[i][Zone_CapturePoint][2], 0);
		ZoneInfo[i][Zone_Id] = GangZoneCreate(ZoneInfo[i][Zone_MapArea][0], ZoneInfo[i][Zone_MapArea][1], ZoneInfo[i][Zone_MapArea][2], ZoneInfo[i][Zone_MapArea][3]);
		ZoneInfo[i][Capture_Area] = CreateDynamicRectangle(ZoneInfo[i][Zone_MapArea][0], ZoneInfo[i][Zone_MapArea][1], ZoneInfo[i][Zone_MapArea][2], ZoneInfo[i][Zone_MapArea][3]);
		ZoneInfo[i][Zone_Checkpoint] = CreateDynamicCP(ZoneInfo[i][Zone_CapturePoint][0], ZoneInfo[i][Zone_CapturePoint][1], ZoneInfo[i][Zone_CapturePoint][2], 4, 0, 0, -1, 100.0);
		CreateDynamicMapIcon(ZoneInfo[i][Zone_CapturePoint][0], ZoneInfo[i][Zone_CapturePoint][1], ZoneInfo[i][Zone_CapturePoint][2], 19, 0, 0, 0, -1, 150.0, MAPICON_GLOBAL);
		zones ++;
	}
	printf("Loaded %d zones.", zones);
	return 1;
}

//Remove capture points
UnloadZones() {
	new zones = 0;
	for (new i = 0; i < sizeof(ZoneInfo); i++) {
		ZoneInfo[i][Zone_Attacked] = false;
		KillTimer(ZoneInfo[i][Zone_Timer]);

		ZoneInfo[i][Zone_Attacker] = INVALID_PLAYER_ID;

		DestroyPickup(ZoneInfo[i][Zone_PickupId]);
		GangZoneDestroy(ZoneInfo[i][Zone_Id]);
		zones ++;
	}
	printf("Unloaded %d zones.", zones);
	return 1;
}

//Set whether a player is capturing or not
SetPlayerCaptureZone(playerid, checkpointid, bool:mode) {
	if (!mode) { // The player is attacking
		for (new i = 0; i < sizeof(ZoneInfo); i++) {
			if (ZoneInfo[i][Zone_Checkpoint] == checkpointid) {
				if (ZoneInfo[i][Zone_Attacker] != INVALID_PLAYER_ID) {
					if (pTeam[playerid] == pTeam[ZoneInfo[i][Zone_Attacker]]) {
						if (PlayerInfo[playerid][pAdminDuty] || GetPlayerState(playerid) == PLAYER_STATE_SPECTATING || IsPlayerInAnyVehicle(playerid)) return NotifyPlayer(playerid, "You can't capture in vehicles or on duty.");

						if (AntiSK[playerid]) {
							EndProtection(playerid);
						}						

						SetPlayerProgressBarValue(playerid, Player_ProgressBar[playerid], ZoneInfo[i][Zone_CapTime]);
						ShowPlayerProgressBar(playerid, Player_ProgressBar[playerid]);


						if (ZoneInfo[i][Zone_Owner] != NO_TEAM) {
							Text_Send(playerid, $CLIENT_179x, ZoneInfo[i][Zone_Name], TeamInfo[ZoneInfo[i][Zone_Owner]][Team_Name]);
						} else {
							Text_Send(playerid, $CLIENT_179x, ZoneInfo[i][Zone_Name], "no team");
						}
						ZoneInfo[i][Zone_Attackers]++;
					}
				} else {
					if (pTeam[playerid] != ZoneInfo[i][Zone_Owner]) {
						if (PlayerInfo[playerid][pAdminDuty] || GetPlayerState(playerid) == PLAYER_STATE_SPECTATING || IsPlayerInAnyVehicle(playerid)) return NotifyPlayer(playerid, "You can't capture in vehicles or on duty.");

						if (AntiSK[playerid]) {
							EndProtection(playerid);
						}

						if (ZoneInfo[i][Zone_Owner] != NO_TEAM) {
							Text_Send(playerid, $CLIENT_179x, ZoneInfo[i][Zone_Name], TeamInfo[ZoneInfo[i][Zone_Owner]][Team_Name]);
						} else {
							Text_Send(playerid, $CLIENT_179x, ZoneInfo[i][Zone_Name], "no team");
						}
						Text_Send(playerid, $CLIENT_180x);

						GangZoneFlashForAll(ZoneInfo[i][Zone_Id], ALPHA(TeamInfo[pTeam[playerid]][Team_Color], 100));

						ZoneInfo[i][Zone_Attacker] = playerid;
						ZoneInfo[i][Zone_Attackers] = 1;
						ZoneInfo[i][Zone_CapTime] = 0;

						ZoneInfo[i][Zone_Attacked] = true;

						KillTimer(ZoneInfo[i][Zone_Timer]);
						ZoneInfo[i][Zone_Timer] = SetTimerEx("OnZoneUpdate", 1000, true, "i", i);

						foreach (new x: Player) {
							if (IsPlayerSpawned(x)) {
								if (pTeam[x] == ZoneInfo[i][Zone_Owner] && GetPlayerVirtualWorld(x) == 0) {
									Text_Send(x, $CLIENT_181x, TeamInfo[pTeam[playerid]][Team_Name], ZoneInfo[i][Zone_Name]);
								}
							}
						}						

						SetPlayerProgressBarValue(playerid, Player_ProgressBar[playerid], ZoneInfo[i][Zone_CapTime]);
						PlayerTextDrawShow(playerid, ProgressTD[playerid]);
						ShowPlayerProgressBar(playerid, Player_ProgressBar[playerid]);
					} else {
						if (!AntiSK[playerid]) {
							Text_Send(playerid, $CLIENT_182x);
						}
					}			
				}

				break;
			}
		}	
	} else { //The player left the zone
		for (new i = 0; i < sizeof(ZoneInfo); i++) {
			if (ZoneInfo[i][Zone_Checkpoint] == checkpointid) {
				if (ZoneInfo[i][Zone_Attacker] != INVALID_PLAYER_ID) {
					if (pTeam[playerid] == pTeam[ZoneInfo[i][Zone_Attacker]]) {
						ZoneInfo[i][Zone_Attackers]--;

						if (ZoneInfo[i][Zone_Attackers] == 0)
						{
							KillTimer(ZoneInfo[i][Zone_Timer]);
							ZoneInfo[i][Zone_Attacked] = false;

							Text_Send(playerid, $CLIENT_183x);
					
							HidePlayerProgressBar(playerid, Player_ProgressBar[playerid]);
							PlayerTextDrawHide(playerid, ProgressTD[playerid]);
							GangZoneStopFlashForAll(ZoneInfo[i][Zone_Id]);

							ZoneInfo[i][Zone_Attacker] = INVALID_PLAYER_ID;

							new title[100];
							format(title, sizeof(title), "%s (Owned by {%06x}%s{FFFFFF})", ZoneInfo[i][Zone_Name], TeamInfo[ZoneInfo[i][Zone_Owner]][Team_Color] >>> 8, TeamInfo[ZoneInfo[i][Zone_Owner]][Team_Name]);
							UpdateDynamic3DTextLabelText(ZoneInfo[i][Zone_Label], 0xFFFFFFFF, title);
						}
						else if (ZoneInfo[i][Zone_Attacker] == playerid) {
							foreach (new x: Player)
							{
								if (pTeam[playerid] == pTeam[x])
								{
									if (IsPlayerInDynamicCP(x, checkpointid))
									{
										ZoneInfo[i][Zone_Attacker] = x;
									}
								}
							}
						}
					}

					PlayerTextDrawHide(playerid, ProgressTD[playerid]);
					HidePlayerProgressBar(playerid, Player_ProgressBar[playerid]);

					break;
				}
			}
		}
	}
	return 1;
}

hook OnPlayerConnect(playerid) {
	for (new i = 0; i < sizeof(ZoneInfo); i++) {
		GangZoneShowForPlayer(playerid, ZoneInfo[i][Zone_Id], ALPHA(TeamInfo[ZoneInfo[i][Zone_Owner]][Team_Color], 100));
	}
	return 1;
}

//Reset capture system
hook OnPlayerDisconnect(playerid, reason) {
	//Hide capture system stuff (if displayed) and reset capture system
	for (new i = 0; i < sizeof(ZoneInfo); i++) {
		GangZoneHideForPlayer(playerid, ZoneInfo[i][Zone_Id]);
	}

	//If this player was capturing a zone, no more...
	for (new Zone_ID = 0; Zone_ID < sizeof(ZoneInfo); Zone_ID++) {
		if (ZoneInfo[Zone_ID][Zone_Attacker] == playerid) {
			GangZoneStopFlashForAll(ZoneInfo[Zone_ID][Zone_Id]);
			ZoneInfo[Zone_ID][Zone_Attacker] = INVALID_PLAYER_ID;
			KillTimer(ZoneInfo[Zone_ID][Zone_Timer]);
			ZoneInfo[Zone_ID][Zone_Attacked] = false;
			new title[100];
			format(title, sizeof(title), "%s (Owned by {%06x}%s{FFFFFF})", ZoneInfo[Zone_ID][Zone_Name], TeamInfo[ZoneInfo[Zone_ID][Zone_Owner]][Team_Color] >>> 8, TeamInfo[ZoneInfo[Zone_ID][Zone_Owner]][Team_Name]);
			UpdateDynamic3DTextLabelText(ZoneInfo[Zone_ID][Zone_Label], 0xFFFFFFFF, title);
			break;
		}
	}
	return 1;
}

//Check death status
hook OnPlayerDeath(playerid, killerid, reason) {
	for (new x = 0; x < sizeof(ZoneInfo); x++) {
		if (ZoneInfo[x][Zone_Attacker] == playerid) {
			if (pTeam[killerid] == ZoneInfo[x][Zone_Owner]) {
				OnPlayerLeaveDynamicCP(playerid, ZoneInfo[x][Zone_Checkpoint]);
				foreach (new a: Player) {
					if (pTeam[a] == pTeam[killerid] && IsPlayerSpawned(a)) {
						Text_Send(a, $CLIENT_402x, PlayerInfo[killerid][PlayerName], PlayerInfo[playerid][PlayerName], ZoneInfo[x][Zone_Name]);
					}
				}
				Text_Send(playerid, $CLIENT_403x);
				GivePlayerScore(killerid, 2);
				break;
			}
		} else {
			OnPlayerLeaveDynamicCP(playerid, ZoneInfo[x][Zone_Checkpoint]);
			break;
		}
	}
	return 1;
}

//Areas
hook OnPlayerEnterDynArea(playerid, areaid) {
	for (new i = 0; i < sizeof(ZoneInfo); i++) {
		if (ZoneInfo[i][Capture_Area] == areaid) {
			new String_Name[100];
			format(String_Name, sizeof(String_Name), "You have entered %s.", ZoneInfo[i][Zone_Name]);
			NotifyPlayer(playerid, String_Name);
			break;
		}
	}
	return 1;
}

hook OnPlayerEnterDynamicCP(playerid, checkpointid) {
	if (GetPlayerVirtualWorld(playerid) == 0 && GetPlayerInterior(playerid) == 0
			&& GetPlayerState(playerid) != PLAYER_STATE_SPECTATING) {
		SetPlayerCaptureZone(playerid, checkpointid, false);
	}
	return 1;
}

hook OnPlayerLeaveDynamicCP(playerid, checkpointid) {
	SetPlayerCaptureZone(playerid, checkpointid, true);
	return 1;
}

//Zone commands
CMD:zones(playerid) {
	new str[35 * sizeof(ZoneInfo)];

	for (new i = 0; i < sizeof(ZoneInfo); i++) {
		strcat(str, ZoneInfo[i][Zone_Name]);
		strcat(str, "\n");
	}

	inline ZonesList(pid, dialogid, response, listitem, string:inputtext[]) {
		#pragma unused dialogid, inputtext
		if (response) {
			SetPlayerRaceCheckpoint(pid, 1, ZoneInfo[listitem][Zone_CapturePoint][0], ZoneInfo[listitem][Zone_CapturePoint][1], ZoneInfo[listitem][Zone_CapturePoint][2], 0.0, 0.0, 0.0, 5);
			Text_Send(pid, $CLIENT_351x, ZoneInfo[listitem][Zone_Name]);
		}
	}

	Dialog_ShowCallback(playerid, using inline ZonesList, DIALOG_STYLE_LIST, ""RED2"SvT - Zones", str, ">>", "X");    
	return 1;
}

CMD:attacks(playerid) {
	new str[70], dg[600];

	for (new i = 0; i < sizeof(ZoneInfo); i++) {
		if (ZoneInfo[i][Zone_Attackers] >= 1) {
			format(str, sizeof(str), "{D5DB65}%s is capturing %s\n", PlayerInfo[ZoneInfo[i][Zone_Attacker]][PlayerName], ZoneInfo[i][Zone_Name]);
			strcat(dg, str);
		}
	}

	if (! strlen(dg)) return Text_Send(playerid, $CLIENT_350x);
	Dialog_Show(playerid, DIALOG_STYLE_LIST, ""RED2"SvT - Attack Alerts", dg, "X", "");    
	return 1;
}

//End of File
/* (c) H2O Multiplayer 2018-2020. All rights reserved. */