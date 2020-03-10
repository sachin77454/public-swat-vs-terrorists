/*
	SWAT vs Terrorists is a team death-match SA-MP game-mode script. 
	Compatible with SA-MP 0.3.7 and later releases.

	Author: H2O
	Licensed under GNU GPLv3

	(c) 2018-2020 H2O Multiplayer. All rights reserved.
	Website: h2omultiplayer.com
*/

#include <YSI_Coding\y_hooks>
#include <YSI_Players\y_text>
loadtext mode_text[all], mode_text[client], mode_text[newcs], mode_text[dialogs], mode_text[gametexts];

task GameUpdate[1000]() {
	//Clan War

	if (gClanLVAWar && gClanLVACD < gettime()) {
		gClanLVAWar = 0;
		for (new i = 0; i < MAX_CLANS; i++) {
			if (gClanLVAOwner == ClanInfo[i][Clan_Id]) {
				AddClanXP(ClanInfo[i][Clan_Name], 30);
				gClanLVAOwner = -1;
				Text_Send(@pVerified, $SERVER_24x, ClanInfo[i][Clan_Name]);
				break;
			}
		}
	}

	//Prototype

	for (new i = 0; i < sizeof(PrototypeInfo); i++) {
		if (PrototypeInfo[i][Prototype_Attacker] != INVALID_PLAYER_ID && !IsPlayerInVehicle(PrototypeInfo[i][Prototype_Attacker], PrototypeInfo[i][Prototype_Id])
			&& gettime() >= PlayerInfo[PrototypeInfo[i][Prototype_Attacker]][pLeavetime]) {
			DisablePlayerRaceCheckpoint(PrototypeInfo[i][Prototype_Attacker]);
			SetVehicleToRespawn(PrototypeInfo[i][Prototype_Id]);

			Text_Send(@pVerified, $SERVER_50x, PlayerInfo[PrototypeInfo[i][Prototype_Attacker]][PlayerName], TeamInfo[PrototypeInfo[i][Prototype_Owner]][Team_Name]);
			Text_Send(PrototypeInfo[i][Prototype_Attacker], $PROTOTYPE_FAILED);

			PrototypeInfo[i][Prototype_Attacker] = INVALID_PLAYER_ID;

			break;
		}
	}

	if (gettime() > cwInfo[cw_plantime]) {
		if (cwInfo[cw_started] == 0 && cwInfo[cw_ready] == 1) {
			Text_Send(@pVerified, $SERVER_25x);

			cwInfo[cw_started] = 0;
			cwInfo[cw_ready] = 0;

			foreach(new x: CWCLAN1) {
				SpawnPlayer(x);
			}
			foreach(new x: CWCLAN2) {
				SpawnPlayer(x);
			}

			Iter_Clear(CWCLAN1);
			Iter_Clear(CWCLAN2);
		}
	}

	TeamWarWinCheck();

	if (EventInfo[E_STARTED] && !EventInfo[E_OPENED]) {
		if (EventInfo[E_TYPE] == 1 && EventInfo[E_SPAWN_TYPE] != EVENT_SPAWN_INVALID
			&& EventInfo[E_AUTO])
		{
			new winner_count, eteam[2];

			foreach (new i: ePlayers)
			{
				if (pEventInfo[i][P_TEAM] == 0) {
					eteam[0] ++;
				} else {
					eteam[1] ++;
				}
			}

			if ((eteam[1] <= 0 && eteam[0] >= 1) || (eteam[0] <= 0 && eteam[1] >= 1)) {
				Text_Send(@pVerified, $SERVER_26x, EventInfo[E_NAME]);

				Text_Send(@pVerified, $NEWSERVER_37x);

				EventInfo[E_OPENED] = 0;
				EventInfo[E_STARTED] = 0;
				foreach (new i: ePlayers) {
					TogglePlayerControllable(i, true);
					SetPlayerHealth(i, 0.0);

					winner_count ++;

					Text_Send(@pVerified, $EVENT_WON_LIST, winner_count, PlayerInfo[i][PlayerName], EventInfo[E_SCORE], EventInfo[E_CASH]);

					GivePlayerCash(i, EventInfo[E_CASH]);
					GivePlayerScore(i, EventInfo[E_SCORE]);
					PlayerInfo[i][sEvents] ++;
					PlayerInfo[i][pEventsWon] ++;
					
					if (PlayerInfo[i][pCar] != -1) DestroyVehicle(PlayerInfo[i][pCar]);
					PlayerInfo[i][pCar] = -1;
				}
				Iter_Clear(ePlayers);

				new clear_data[E_DATA_ENUM];
				EventInfo = clear_data;

				EventInfo[E_SPAWN_TYPE] = EVENT_SPAWN_INVALID;
				EventInfo[E_TYPE] = -1;
			} else if (eteam[1] <= 0 && eteam[0] <= 0) {
				Text_Send(@pVerified, $SERVER_27x);

				EventInfo[E_OPENED] = 0;
				EventInfo[E_STARTED] = 0;

				new clear_data[E_DATA_ENUM];
				EventInfo = clear_data;

				EventInfo[E_SPAWN_TYPE] = EVENT_SPAWN_INVALID;
				EventInfo[E_TYPE] = -1;
				Iter_Clear(ePlayers);
			}
		}
	}
	return 1;
}

task GameUpdate2[500000]() {
	if (nukeIsLaunched == 1 && gettime() > nukeCooldown) {
		UpdateDynamic3DTextLabelText(nukeRemoteLabel, 0xFFFFFFFF, "Nuke\n{00CC00}Online");

		nukeIsLaunched = 0;
		Text_Send(@pVerified, $SERVER_39x);
	}

	for (new i = 0; i < sizeof(AntennaInfo); i++) {
		if (AntennaInfo[i][Antenna_Exists] == 0 && AntennaInfo[i][Antenna_Kill_Time] <= gettime()) {
			AntennaInfo[i][Antenna_Exists] = 1;
			AntennaInfo[i][Antenna_Hits] = 0;

			CA_FindZ_For2DCoord(AntennaInfo[i][Antenna_Pos][0], AntennaInfo[i][Antenna_Pos][1], AntennaInfo[i][Antenna_Pos][2]);
			SetDynamicObjectPos(AntennaInfo[i][Antenna_Id], AntennaInfo[i][Antenna_Pos][0], AntennaInfo[i][Antenna_Pos][1], AntennaInfo[i][Antenna_Pos][2]);

			Text_Send(@pVerified, $SERVER_40x, TeamInfo[i][Team_Name]);

			new title[140];
			format(title, sizeof(title), "%s\n"IVORY"Radio Antenna", TeamInfo[i][Team_Name]);
			UpdateDynamic3DTextLabelText(AntennaInfo[i][Antenna_Label], TeamInfo[i][Team_Color], title);
		}
	}

	if (Iter_Count(Player)) {
		if (!WarInfo[War_Started]) {
			WarInfo[War_Team1] = 0;
			WarInfo[War_Team2] = 1;

			WarInfo[Team1_Score] = 0;
			WarInfo[Team2_Score] = 0;

			WarInfo[War_Time] = 60 * 30;
			war_time = WarInfo[War_Time] + gettime();
			WarInfo[War_Started] = 1;

			new war_str[130];
			format(war_str, sizeof(war_str), "%s%s (%d)~w~ VS %s[%d] %s", TeamInfo[WarInfo[War_Team1]][Chat_Bub], TeamInfo[WarInfo[War_Team1]][Team_Name],
			WarInfo[Team1_Score], TeamInfo[WarInfo[War_Team2]][Chat_Bub], WarInfo[Team2_Score], TeamInfo[WarInfo[War_Team2]][Team_Name]);

			TextDrawSetString(War_TD, war_str);
			foreach (new i: Player) {
				if (IsPlayerSpawned(i)) {
					UpdatePlayerHUD(i);
				}
			}

			/*for (new i = 0; i < sizeof(ZoneInfo); i++) {
				foreach (new x: Player) {
					if ((ZoneInfo[i][Zone_Attacker] == x) || ZoneInfo[i][Zone_Attacker] != INVALID_PLAYER_ID && pTeam[x] == pTeam[ZoneInfo[i][Zone_Attacker]] &&
						IsPlayerInDynamicCP(x, ZoneInfo[i][Zone_Checkpoint])) {
						SetPlayerCaptureZone(x, ZoneInfo[i][Zone_Checkpoint], true);
					}	
				}
				ZoneInfo[i][Zone_Owner] = NO_TEAM;
				UpdateDynamic3DTextLabelText(ZoneInfo[i][Zone_Label], 0xFFFFFFFF, ZoneInfo[i][Zone_Name]);
				GangZoneShowForAll(ZoneInfo[i][Zone_Id], ALPHA(ZoneInfo[i][Zone_Owner] != NO_TEAM ? TeamInfo[ZoneInfo[i][Zone_Owner]][Team_Color] : 0xFFFFFFFF, 100));
			}*/
		}
	}

	SaveAllStats();
	return 1;
}

task RewardZonePlayers[300000]() {
	foreach (new i: Player) {
		if (pTeam[i] == ZoneInfo[HOSPITAL][Zone_Owner]) {
			if (!GetPlayerInterior(i) && !GetPlayerVirtualWorld(i) && IsPlayerSpawned(i)) {
				new Float: HP;
				GetPlayerHealth(i, HP);
				if (HP <= 85) {
					SetPlayerHealth(i, HP + 15);
					Text_Send(i, $HOSPITAL_BONUS);
				}	
			}
		}
	}
	return 1;
}

//End of File
/* (c) H2O Multiplayer 2018-2020. All rights reserved. */