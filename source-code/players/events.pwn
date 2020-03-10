/*
	SWAT vs Terrorists is a team death-match SA-MP game-mode script. 
	Compatible with SA-MP 0.3.7 and later releases.

	Author: H2O
	Licensed under GNU GPLv3

	(c) 2018-2020 H2O Multiplayer. All rights reserved.
	Website: h2omultiplayer.com

	Various server event creations are handled here
*/

#include <YSI\y_hooks>
#include <YSI\y_text>
loadtext mode_text[all], mode_text[client], mode_text[newcs], mode_text[dialogs], mode_text[gametexts];

forward StartCastle(playerid);
public StartCastle(playerid) {
	if (EventInfo[E_STARTED]) {
		if (Iter_Count(ePlayers) < 2) {
			new clear_data[E_DATA_ENUM];
			EventInfo = clear_data;

			EventInfo[E_STARTED] = 0;
			EventInfo[E_OPENED] = 0;

			EventInfo[E_SPAWN_TYPE] = EVENT_SPAWN_INVALID;
			EventInfo[E_TYPE] = -1;
			foreach (new i: ePlayers) {
				SetPlayerHealth(i, 0.0);
				Text_Send(i, $EVENT_CANCELLED);
			}
			Iter_Clear(ePlayers);
		} else {
			new model, randomcar = random(6);
			switch (randomcar) {
				case 0: model = 504;
				case 1: model = 411;
				case 2: model = 495;
				case 3: model = 444;
				case 4: model = 451;
				case 5: model = 502;
			}

			foreach (new i: ePlayers) {
				if (PlayerInfo[i][pCar] != -1) DestroyVehicle(PlayerInfo[i][pCar]);
				PlayerInfo[i][pCar] = -1;

				new Float: Position[4], Int, World;

				Int = GetPlayerInterior(i);
				World = GetPlayerVirtualWorld(i);

				GetPlayerPos(i, Position[0], Position[1], Position[2]);
				GetPlayerFacingAngle(i, Position[3]);

				PlayerInfo[i][pCar] = CreateVehicle(model, Position[0], Position[1], Position[2], Position[3], 0, 3, -1);

				LinkVehicleToInterior(PlayerInfo[i][pCar], Int);
				SetVehicleVirtualWorld(PlayerInfo[i][pCar], World);
				PutPlayerInVehicle(i, PlayerInfo[i][pCar], 0);
				Tuneacar(PlayerInfo[i][pCar]);

				TogglePlayerControllable(i, true);
				PlayerPlaySound(i, 1057, 0.0, 0.0, 0.0);
				if (EventInfo[E_FREEZE] == 1) {
					EventInfo[E_FREEZE] = 0;
				}
			}

			EventInfo[E_OPENED] = 0;
			castleTimer = SetTimer("UpdateCastle", 1000, true);
		}
	}    
	return 1;
}

forward UpdateCastle();
public UpdateCastle() {
	if (!EventInfo[E_STARTED]) {
		KillTimer(castleTimer);		
		return 1;
	}

	foreach(new x: ePlayers) {
		new Float: X, Float: Y, Float: Z;
		GetPlayerPos(x, X, Y, Z);
		if (Z <= 30.0) {
			SpawnPlayer(x);
		}
	}

	if (!Iter_Count(ePlayers)) {
		KillTimer(castleTimer);
		return 1;
	}

	if (Iter_Count(ePlayers) == 1) {
		KillTimer(castleTimer);

		new winner = Iter_Random(ePlayers);
		EventInfo[E_OPENED] = 0;
		EventInfo[E_STARTED] = 0;
		TogglePlayerControllable(winner, true);
		SetPlayerHealth(winner, 0.0);

		Text_Send(@pVerified, $SERVER_8x, PlayerInfo[winner][PlayerName]);

		GivePlayerCash(winner, EventInfo[E_CASH]);
		GivePlayerScore(winner, EventInfo[E_SCORE]);
		PlayerInfo[winner][sEvents] ++;
		
		if (PlayerInfo[winner][pCar] != -1) DestroyVehicle(PlayerInfo[winner][pCar]);
		PlayerInfo[winner][pCar] = -1;
		Iter_Clear(ePlayers);
	}
	return 1;
}

forward StartLBS(playerid);
public StartLBS(playerid) {
	if (EventInfo[E_STARTED]) {
		if (!Iter_Count(ePlayers)) {
			new clear_data[E_DATA_ENUM];
			EventInfo = clear_data;

			EventInfo[E_STARTED] = 0;
			EventInfo[E_OPENED] = 0;

			EventInfo[E_SPAWN_TYPE] = EVENT_SPAWN_INVALID;
			EventInfo[E_TYPE] = -1;
			KillTimer(bedTimer);
			if (Iter_Count(Beds)) {
				foreach (new i: Beds) {
					DestroyDynamicObject(i);
					Iter_Remove(Beds, i);
				}
			}

			Iter_Clear(Beds);		
		} else {
			EventInfo[E_OPENED] = 0;
			bedTimer = SetTimer("UpdateLBS", 800, true);
			foreach (new i: ePlayers) {
				TogglePlayerControllable(i, true);
				PlayerPlaySound(i, 1057, 0.0, 0.0, 0.0);
				if (EventInfo[E_FREEZE] == 1) {
					EventInfo[E_FREEZE] = 0;
				}
				AnimLoopPlayer(playerid, "BEACH", "bather", 4.0, 1, 0, 0, 0, 0);
			}
		}
	} else {
		KillTimer(bedTimer);
		if (Iter_Count(Beds)) {
			foreach (new i: Beds) {
				DestroyDynamicObject(i);
				Iter_Remove(Beds, i);
			}
		}

		Iter_Clear(Beds);
	}  
	return 1;
}

forward UpdateLBS();
public UpdateLBS() {
	new i = Iter_Random(Beds);
	if (!IsValidDynamicObject(i)) return 1;

	if (!EventInfo[E_STARTED]) {
		foreach (new x: Beds) {
			if (IsValidDynamicObject(x)) {
				DestroyDynamicObject(x);
			}
		}
		Iter_Clear(Beds);
		KillTimer(bedTimer);		
		return 1;
	}

	foreach(new x: ePlayers) {
		new Float: X, Float: Y, Float: Z;
		GetPlayerPos(x, X, Y, Z);
		if (Z <= 450.0) {
			SpawnPlayer(x);
		}
	}

	if (!Iter_Count(ePlayers)) {
		foreach (new x: Beds) {
			if (IsValidDynamicObject(x)) {
				DestroyDynamicObject(x);
			}
		}
		Iter_Clear(Beds);
		KillTimer(bedTimer);
		return 1;
	}	

	if (Iter_Count(ePlayers) == 1) {
		foreach (new x: Beds) {
			if (IsValidDynamicObject(x)) {
				DestroyDynamicObject(x);
			}
		}
		Iter_Clear(Beds);
		KillTimer(bedTimer);

		new winner = Iter_Random(ePlayers);
		EventInfo[E_OPENED] = 0;
		EventInfo[E_STARTED] = 0;
		TogglePlayerControllable(winner, true);
		SetPlayerHealth(winner, 0.0);

		Text_Send(@pVerified, $SERVER_9x, PlayerInfo[winner][PlayerName], EventInfo[E_SCORE], EventInfo[E_CASH]);

		GivePlayerCash(winner, EventInfo[E_CASH]);
		GivePlayerScore(winner, EventInfo[E_SCORE]);
		PlayerInfo[winner][sEvents] ++;
		Iter_Clear(ePlayers);
		return 1;
	}

	new Float: rx, Float: ry, Float: rz;
	GetDynamicObjectRot(i, rx, ry, rz);
	
	if (ry != 1.0) {
		SetDynamicObjectRot(i, rx, 1.0, rz);
	}

	if (ry == 1.0) {
		SetDynamicObjectRot(i, 1.0, ry, rz);
	}

	if (rx == 1.0) {
		new Float: X, Float: Y, Float: Z;
		GetDynamicObjectPos(i, X, Y, Z);
		MoveDynamicObject(i, X, Y, Z - 523.0, 50.0);
	}

	if (!Iter_Count(Beds)) {
		KillTimer(bedTimer);
	}
	return 1;
}

//Event countdown
forward EventCD(cdValue);
public EventCD(cdValue) {
	if (counterOn == 1) {
		if (counterValue > 0) {
			new text[10];
			format(text, sizeof(text), "~w~%d", counterValue);

			counterValue--;

			foreach (new i: ePlayers) {
				if (IsPlayerSpawned(i)) {
					GameTextForPlayer(i, text, 1000, 3);
				}
			}
		} else {
			KillTimer(counterTimer);

			counterValue = -1;
			counterOn = 0;

			foreach (new i: ePlayers) {
				if (IsPlayerSpawned(i)) {
					Text_Send(i, $GO);
					PlayerPlaySound(i, 1057, 0.0, 0.0, 0.0);
				}
			}
		}
	} else {
		KillTimer(counterTimer);
	}
	return 1;
}

hook OnGameModeInit() {
	new clear_data[E_DATA_ENUM];
	EventInfo = clear_data;
	EventInfo[E_SPAWN_TYPE] = EVENT_SPAWN_INVALID;
	EventInfo[E_TYPE] = -1;
	return 1;
}

hook OnPlayerConnect(playerid) {
	new clear_data2[E_PLAYER_ENUM] = -1;
	pEventInfo[playerid] = clear_data2;
	return 1;
}

hook OnPlayerDisconnect(playerid, reason) {
	if (Iter_Contains(ePlayers, playerid)) {  
		Iter_Remove(ePlayers, playerid);
		foreach (new i: ePlayers) {
			Text_Send(i, $CLIENT_265x, PlayerInfo[playerid][PlayerName]);
		}

		if (!Iter_Count(ePlayers)) {
			new clear_data[E_DATA_ENUM];
			EventInfo = clear_data;

			EventInfo[E_STARTED] = 0;
			EventInfo[E_OPENED] = 0;

			EventInfo[E_SPAWN_TYPE] = EVENT_SPAWN_INVALID;
			EventInfo[E_TYPE] = -1;
		}

		if (EventInfo[E_TYPE] == 1) {
			new winner_count, eteam[2];

			foreach (new i: ePlayers) {
				if (IsPlayerSpawned(i)) {
					if (pEventInfo[i][P_TEAM] == 0) {
						eteam[0] ++;
					} else {
						eteam[1] ++;
					}
				}
			}

			if ((!eteam[1] && eteam[0]) || (!eteam[0] && eteam[1])) {
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

				new clear_data[E_DATA_ENUM];
				EventInfo = clear_data;

				EventInfo[E_SPAWN_TYPE] = EVENT_SPAWN_INVALID;
				EventInfo[E_TYPE] = -1;
				Iter_Clear(ePlayers);
			} else {
				Text_Send(playerid, $CLIENT_266x);
			
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

	new clear_data[E_PLAYER_ENUM];
	pEventInfo[playerid] = clear_data;
	return 1;
}

hook OnDynamicObjectMoved(objectid) {
	//Beds
	if (Iter_Contains(Beds, objectid)) {
		DestroyDynamicObject(objectid);
		Iter_Remove(Beds, objectid);
	}
	return 1;
}

//Event Commands

CMD:castle(playerid) {
	if (GetPlayerScore(playerid) < 10000) return Text_Send(playerid, $CLIENT_451x);
	if (EventInfo[E_STARTED]) return Text_Send(playerid, $CLIENT_474x);

	if (pCooldown[playerid][41] > gettime()) {
		Text_Send(playerid, $CLIENT_475x, pCooldown[playerid][41] - gettime());
		return 1;
	}
	pCooldown[playerid][41] = gettime() + 3800;

	new clear_data2[E_RACE_ENUM], clear_data3[E_SPAWN_ENUM];
	for (new i = 0; i < MAX_CHECKPOINTS; i++) {
		RaceInfo[i] = clear_data2;
		SpawnInfo[i] = clear_data3;
	}

	EventInfo[E_SPAWN_TYPE] = EVENT_SPAWN_RANDOM;
	EventInfo[E_SPAWNS] = 0;

	new Float: CastlePoints[0][4] = {
		{2281.0234,1073.3734,93.8423,60.9852}, {2240.7446,1061.2683,93.8426,333.4335},
		{2225.4602,1094.0381,93.8414,254.4458}		
	};

	for (new i = 0; i < sizeof(CastlePoints); i++) {
		SpawnInfo[EventInfo[E_SPAWNS]][S_COORDS][0] = CastlePoints[i][0];
		SpawnInfo[EventInfo[E_SPAWNS]][S_COORDS][1] = CastlePoints[i][1];
		SpawnInfo[EventInfo[E_SPAWNS]][S_COORDS][2] = CastlePoints[i][2];
		SpawnInfo[EventInfo[E_SPAWNS]][S_COORDS][3] = CastlePoints[i][3];
		EventInfo[E_SPAWNS] ++;
	}

	EventInfo[E_STARTED] = 1;
	EventInfo[E_TYPE] = 0;
	EventInfo[E_FREEZE] = 1;

	EventInfo[E_INTERIOR] = 0;
	EventInfo[E_WORLD] = 2;

	EventInfo[E_CASH] = random(10000) + 1000;
	EventInfo[E_SCORE] = random(5) + 5;
	EventInfo[E_OPENED] = 1;
	KillTimer(castleTimer);
	SetTimer("StartCastle", 25000, false);
	EventInfo[E_AUTO] = 1;
	EventInfo[E_MAX_PLAYERS] = 30;
	format(EventInfo[E_NAME], sizeof(EventInfo[E_NAME]), "Castle Derby");

	counterValue = 25;
	counterOn = 1;

	KillTimer(counterTimer);
	counterTimer = SetTimer("EventCD", 1000, true);

	Text_Send(@pVerified, $SERVER_66x, PlayerInfo[playerid][PlayerName]);
	return 1;
}

alias:lbs("lastbedstanding");
CMD:lbs(playerid) {
	if (GetPlayerScore(playerid) < 10000) return Text_Send(playerid, $CLIENT_451x);
	if (EventInfo[E_STARTED]) return Text_Send(playerid, $CLIENT_474x);
	
	if (pCooldown[playerid][41] > gettime()) {
		Text_Send(playerid, $CLIENT_475x, pCooldown[playerid][41] - gettime());
		return 1;
	}
	pCooldown[playerid][41] = gettime() + 600;

	new Float: BedSpawns[][3] = {
	{223.05951, 1756.88721, 522.81543}, {220.07808, 1750.99243, 522.81543}, {226.33061, 1754.20056, 522.81543},
	{223.58389, 1752.45923, 522.81543}, {219.54874, 1756.38965, 522.81543}, {217.03278, 1752.43066, 522.81543},
	{215.40411, 1756.38843, 522.81543}, {226.59087, 1749.14392, 522.81543}, {228.14546, 1758.02002, 522.81543},
	{224.77321, 1760.90332, 522.81543}, {222.42131, 1747.45093, 522.81543}, {220.59564, 1762.61719, 522.81543},
	{217.50630, 1760.59473, 522.81543}, {212.86499, 1752.64172, 522.81543}, {216.32845, 1747.16443, 522.81543},
	{229.74179, 1752.46631, 522.81543}, {231.77048, 1757.40027, 522.81543}, {231.36458, 1746.77344, 522.81543},
	{224.84401, 1743.54224, 522.81543}, {219.94086, 1743.57251, 522.81543}, {217.39682, 1740.84009, 522.81543},
	{225.32259, 1765.80176, 522.81543}, {221.69331, 1767.01282, 522.81543}, {228.23470, 1762.95471, 522.81543}, 
	{212.26155, 1746.91040, 522.81543}, {234.62009, 1751.73486, 522.81543}, {234.24869, 1761.58093, 522.81543},
	{231.26349, 1763.58740, 522.81543}, {217.74226, 1765.58765, 522.81543}, {214.35780, 1762.00500, 522.81543},
	{211.57098, 1757.21436, 522.81543}, {235.25885, 1756.79346, 522.81543}, {213.83089, 1742.29248, 522.81543},
	{209.27888, 1750.78796, 522.81543}, {228.84189, 1742.85754, 522.81543}, {209.38168, 1743.89795, 522.81543},
	{208.74706, 1755.50488, 522.81543}, {210.65514, 1761.24744, 522.81543}, {214.14526, 1765.96948, 522.81543},
	{217.56512, 1769.82507, 522.81543}, {221.08783, 1771.34509, 522.81543}, {224.77724, 1771.18042, 522.81543},
	{228.65192, 1768.34229, 522.81543}, {232.97527, 1767.93091, 522.81543}, {230.22583, 1772.68372, 522.81543},
	{226.38048, 1775.03003, 522.81543}, {222.50655, 1775.48206, 522.81543}, {218.92389, 1774.71826, 522.81543},
	{215.16005, 1772.68848, 522.81543}, {212.28662, 1769.50061, 522.81543}, {209.91475, 1765.77930, 522.81543},
	{236.56987, 1765.48755, 522.81543}, {238.08913, 1760.12646, 522.81543}, {207.08452, 1760.67749, 522.81543},
	{206.73219, 1747.95764, 522.81543}, {205.43045, 1754.18250, 522.81543}, {222.96086, 1739.40112, 522.81543},
	{214.85583, 1737.31970, 522.81543}, {210.92770, 1739.02661, 522.81543}, {219.70705, 1736.06592, 522.81543},
	{216.86453, 1732.86499, 522.81543}, {212.75081, 1733.81689, 522.81543}};

	KillTimer(bedTimer);
	if (Iter_Count(Beds)) {
		foreach (new i: Beds) {
			DestroyDynamicObject(i);
			Iter_Remove(Beds, i);
		}
	}

	Iter_Clear(Beds);

	new clear_data2[E_RACE_ENUM], clear_data3[E_SPAWN_ENUM];
	for (new i = 0; i < MAX_CHECKPOINTS; i++) {
		RaceInfo[i] = clear_data2;
		SpawnInfo[i] = clear_data3;
	}

	EventInfo[E_SPAWN_TYPE] = EVENT_SPAWN_RANDOM;
	EventInfo[E_SPAWNS] = 0;

	new bed_objects[sizeof(BedSpawns)];
	for (new i = 0; i < sizeof(BedSpawns); i++) {
		bed_objects[i] = CreateDynamicObject(1800, BedSpawns[i][0], BedSpawns[i][1], BedSpawns[i][2], 0.0, 0.0, 0.0, 3, 1);
		Iter_Add(Beds, bed_objects[i]);
	}

	new Float: BedPoints[0][4] = {
		{217.2028,1754.7720,524.5815,21.6944}, {215.6206,1758.5697,524.5815,8.2210},
		{217.6569,1763.1646,524.5815,14.1744}, {217.7728,1767.7726,524.5815,358.5076},
		{217.8794,1771.8628,524.5815,358.5076}		
	};

	for (new i = 0; i < sizeof(BedPoints); i++) {
		SpawnInfo[EventInfo[E_SPAWNS]][S_COORDS][0] = BedPoints[i][0];
		SpawnInfo[EventInfo[E_SPAWNS]][S_COORDS][1] = BedPoints[i][1];
		SpawnInfo[EventInfo[E_SPAWNS]][S_COORDS][2] = BedPoints[i][2];
		SpawnInfo[EventInfo[E_SPAWNS]][S_COORDS][3] = BedPoints[i][3];
		EventInfo[E_SPAWNS] ++;
	}

	EventInfo[E_STARTED] = 1;
	EventInfo[E_TYPE] = 0;
	EventInfo[E_FREEZE] = 1;

	EventInfo[E_INTERIOR] = 1;
	EventInfo[E_WORLD] = 3;

	EventInfo[E_CASH] = random(10000) + 1000;
	EventInfo[E_SCORE] = random(5) + 5;
	EventInfo[E_OPENED] = 1;
	SetTimer("StartLBS", 25000, false);
	EventInfo[E_AUTO] = 1;
	EventInfo[E_MAX_PLAYERS] = 30;
	format(EventInfo[E_NAME], sizeof(EventInfo[E_NAME]), "LastBedStanding");

	counterValue = 25;
	counterOn = 1;

	KillTimer(counterTimer);
	counterTimer = SetTimer("EventCD", 1000, true);

	Text_Send(@pVerified, $SERVER_67x, PlayerInfo[playerid][PlayerName]);
	return 1;
}

CMD:elist(playerid) {
	new sub_holder[27], string[256];

	if (EventInfo[E_STARTED]) {
		foreach (new i: ePlayers) {
			format(sub_holder, sizeof(sub_holder), "%s\n", PlayerInfo[i][PlayerName]);
			strcat(string, sub_holder);
		}
	}

	if (Iter_Count(ePlayers)) {
		Dialog_Show(playerid, DIALOG_STYLE_LIST, EventInfo[E_NAME], string, "X", "");
	}  else Text_Send(playerid, $CLIENT_477x);
	return 1;
}

CMD:join(playerid) {
	if (GetPlayerVirtualWorld(playerid) || GetPlayerInterior(playerid)) return Text_Send(playerid, $CLIENT_478x);
	if (IsPlayerInAnyVehicle(playerid)) return Text_Send(playerid, $CLIENT_479x);
	if (EventInfo[E_STARTED] != 1 || EventInfo[E_OPENED] != 1) return Text_Send(playerid, $CLIENT_477x);
	if (EventInfo[E_SPAWN_TYPE] == EVENT_SPAWN_INVALID) return Text_Send(playerid, $CLIENT_480x);
	if (EventInfo[E_SPAWN_TYPE] == EVENT_SPAWN_RANDOM && EventInfo[E_SPAWNS] == 0) return Text_Send(playerid, $CLIENT_480x);

	if (pDuelInfo[playerid][pDInMatch] == 1) return Text_Send(playerid, $COMMAND_INDUEL);
	if (PlayerInfo[playerid][pDeathmatchId] > -1) return Text_Send(playerid, $COMMAND_INDM);
	if (Iter_Contains(ePlayers, playerid)) return 1;
	if (Iter_Contains(CWCLAN1, playerid) || Iter_Contains(CWCLAN2, playerid)) return Text_Send(playerid, $COMMAND_INCW);
	if (Iter_Contains(PUBGPlayers, playerid)) return Text_Send(playerid, $COMMAND_INPUBG);

	new in_proto = 0;

	for (new i = 0; i < sizeof(PrototypeInfo); i++) {
		if (PrototypeInfo[i][Prototype_Attacker] == playerid) {
			in_proto = 1;
			break;
		}
	}

	if (in_proto) return Text_Send(playerid, $CLIENT_479x);
	if (Iter_Count(ePlayers) >= EventInfo[E_MAX_PLAYERS]) return Text_Send(playerid, $CLIENT_481x);

	if (AntiSK[playerid]) {
		EndProtection(playerid);
	}

	SetPlayerHealth(playerid, 100);
	SetPlayerArmour(playerid, 100);

	ResetPlayerWeapons(playerid);
	SetPlayerColor(playerid, 0xFFFF00FF);
	
	Text_Send(@pVerified, $SERVER_68x, PlayerInfo[playerid][PlayerName], EventInfo[E_NAME]);

	SetPlayerInterior(playerid, EventInfo[E_INTERIOR]);
	SetPlayerVirtualWorld(playerid, EventInfo[E_WORLD]);

	GivePlayerWeapon(playerid, EventInfo[E_WEAP1][0], EventInfo[E_WEAP1][1]);
	GivePlayerWeapon(playerid, EventInfo[E_WEAP2][0], EventInfo[E_WEAP2][1]);
	GivePlayerWeapon(playerid, EventInfo[E_WEAP3][0], EventInfo[E_WEAP3][1]);
	GivePlayerWeapon(playerid, EventInfo[E_WEAP4][0], EventInfo[E_WEAP4][1]);

	if (EventInfo[E_FREEZE] == 1) {
		TogglePlayerControllable(playerid, false);
	} else {
		TogglePlayerControllable(playerid, true);
	}

	Iter_Add(ePlayers, playerid);

	if (EventInfo[E_TYPE] == 2) {
		PlayerPlaySound(playerid, 1056, 0.0, 0.0, 0.0);
		if (RaceInfo[0][R_TYPE] == 0) {
			SetPlayerRaceCheckpoint(playerid, 0, RaceInfo[0][R_COORDS][0], RaceInfo[0][R_COORDS][1], RaceInfo[0][R_COORDS][2],
			RaceInfo[1][R_COORDS][0], RaceInfo[1][R_COORDS][1], RaceInfo[1][R_COORDS][2], 10);
		} else {
			SetPlayerRaceCheckpoint(playerid, 3, RaceInfo[0][R_COORDS][0], RaceInfo[0][R_COORDS][1], RaceInfo[0][R_COORDS][2],
			RaceInfo[1][R_COORDS][0], RaceInfo[1][R_COORDS][1], RaceInfo[1][R_COORDS][2], 10);
		}

		pEventInfo[playerid][P_CP]++;

		if (EventInfo[E_SPAWN_TYPE] == EVENT_SPAWN_RANDOM) {
			new Float: rx = frandom(10.0, -10.0), Float: ry = frandom(10.0, -10.0), Float: rz = frandom(1.0, 0.5);
			new rspawn = random(EventInfo[E_SPAWNS]);
			SetPlayerPos(playerid, SpawnInfo[rspawn][S_COORDS][0] + rx, SpawnInfo[rspawn][S_COORDS][1] + ry, SpawnInfo[rspawn][S_COORDS][2] + rz);
			SetPlayerFacingAngle(playerid, SpawnInfo[rspawn][S_COORDS][3]);
		} else {
			new Float: rx = frandom(10.0, -10.0), Float: ry = frandom(10.0, -10.0), Float: rz = frandom(1.0, 0.5);
			SetPlayerPos(playerid, SpawnInfo[0][S_COORDS][0] + rx, SpawnInfo[0][S_COORDS][1] + ry, SpawnInfo[0][S_COORDS][2] + rz);
			SetPlayerFacingAngle(playerid, SpawnInfo[0][S_COORDS][3]);
		}

		SetPlayerInterior(playerid, EventInfo[E_INTERIOR]);
		SetPlayerVirtualWorld(playerid, EventInfo[E_WORLD]); 

		pEventInfo[playerid][P_RACETIME] = gettime();

		if (PlayerInfo[playerid][pCar] != -1) DestroyVehicle(PlayerInfo[playerid][pCar]);
		PlayerInfo[playerid][pCar] = -1;
	}
	else if (EventInfo[E_TYPE] == 1) {
		new counter[2];

		counter[0] = 0;
		counter[1] = 0;

		foreach(new i: ePlayers) {
			if (pEventInfo[i][P_TEAM] == 0) {
				counter[0]++;
			} else if (pEventInfo[i][P_TEAM] == 1) {
				counter[1]++;
			}
		}

		if (counter[0] > counter[1]) {
			pEventInfo[playerid][P_TEAM] = 1;
		} else if (counter[0] < counter[1]) {
			pEventInfo[playerid][P_TEAM] = 0;
		} else if (counter[0] == counter[1]) {
			pEventInfo[playerid][P_TEAM] = 1;
		}

		switch (pEventInfo[playerid][P_TEAM]) {
			case 0: {
				SetPlayerPos(playerid, SpawnInfo[0][S_COORDS][0], SpawnInfo[0][S_COORDS][1], SpawnInfo[0][S_COORDS][2]);
				SetPlayerFacingAngle(playerid, SpawnInfo[0][S_COORDS][3]);

				SetPlayerInterior(playerid, EventInfo[E_INTERIOR]);
				SetPlayerVirtualWorld(playerid, EventInfo[E_WORLD]);
				SetPlayerColor(playerid, 0x5274FFFF);
			}
			case 1: {
				SetPlayerPos(playerid, SpawnInfo[1][S_COORDS][0], SpawnInfo[1][S_COORDS][1], SpawnInfo[1][S_COORDS][2]);
				SetPlayerFacingAngle(playerid, SpawnInfo[1][S_COORDS][3]);

				SetPlayerInterior(playerid, EventInfo[E_INTERIOR]);
				SetPlayerVirtualWorld(playerid, EventInfo[E_WORLD]);
				SetPlayerColor(playerid, 0xFF1C2BFF);
			}
		}
	} else if (EventInfo[E_TYPE] == 0 && EventInfo[E_SPAWN_TYPE] == EVENT_SPAWN_ADMIN) {
		SetPlayerPos(playerid, SpawnInfo[0][S_COORDS][0], SpawnInfo[0][S_COORDS][1], SpawnInfo[0][S_COORDS][2]);
		SetPlayerFacingAngle(playerid, SpawnInfo[0][S_COORDS][3]);

		SetPlayerInterior(playerid, EventInfo[E_INTERIOR]);
		SetPlayerVirtualWorld(playerid, EventInfo[E_WORLD]);
	} else if (EventInfo[E_TYPE] == 0 && EventInfo[E_SPAWN_TYPE] == EVENT_SPAWN_RANDOM) {
		if (EventInfo[E_SPAWN_TYPE] == EVENT_SPAWN_RANDOM)
		{
			new Float: rx = frandom(10.0, -10.0), Float: ry = frandom(10.0, -10.0), Float: rz = frandom(1.0, 0.5);
			new rspawn = random(EventInfo[E_SPAWNS]);
			if (SpawnInfo[rspawn][S_COORDS][2] >= 500.0) {
				SetPlayerPos(playerid, SpawnInfo[rspawn][S_COORDS][0], SpawnInfo[rspawn][S_COORDS][1], SpawnInfo[rspawn][S_COORDS][2]);
				SetPlayerFacingAngle(playerid, SpawnInfo[rspawn][S_COORDS][3]);
			}
			else {
				SetPlayerPos(playerid, SpawnInfo[rspawn][S_COORDS][0] + rx, SpawnInfo[rspawn][S_COORDS][1] + ry, SpawnInfo[rspawn][S_COORDS][2] + rz);
				SetPlayerFacingAngle(playerid, SpawnInfo[rspawn][S_COORDS][3]);            	
			}
		} else {
			new Float: rx = frandom(2.0, -2.0), Float: ry = frandom(2.0, -2.0), Float: rz = frandom(1.0, 0.5);
			if (SpawnInfo[0][S_COORDS][2] >= 500.0) {
				SetPlayerPos(playerid, SpawnInfo[0][S_COORDS][0], SpawnInfo[0][S_COORDS][1], SpawnInfo[0][S_COORDS][2]);
				SetPlayerFacingAngle(playerid, SpawnInfo[0][S_COORDS][3]);
			}
			else {          
				SetPlayerPos(playerid, SpawnInfo[0][S_COORDS][0] + rx, SpawnInfo[0][S_COORDS][1] + ry, SpawnInfo[0][S_COORDS][2] + rz);
				SetPlayerFacingAngle(playerid, SpawnInfo[0][S_COORDS][3]);
			}	
		}

		SetPlayerInterior(playerid, EventInfo[E_INTERIOR]);
		SetPlayerVirtualWorld(playerid, EventInfo[E_WORLD]);
	}    
	return 1;
}

CMD:ewatch(playerid) {
	if (GetPlayerState(playerid) != PLAYER_STATE_ONFOOT || pDuelInfo[playerid][pDInMatch] == 1) return Text_Send(playerid, $CLIENT_436x);
	if (PlayerInfo[playerid][pAdminDuty] == 1) return Text_Send(playerid, $CLIENT_436x);
	if (PlayerInfo[playerid][pDeathmatchId] >= 0) return Text_Send(playerid, $CLIENT_436x);
	if (Iter_Contains(ePlayers, playerid) || Iter_Contains(PUBGPlayers, playerid)) return Text_Send(playerid, $CLIENT_436x);
	if (PlayerInfo[playerid][pLastHitTick] > gettime()) return Text_Send(playerid, $JUSTHIT, PlayerInfo[playerid][pLastHitTick] - gettime());
	if (!EventInfo[E_STARTED]) return Text_Send(playerid, $CLIENT_477x);
	if (Iter_Count(ePlayers) < 2) return Text_Send(playerid, $CLIENT_420x);
	new i = Iter_Random(ePlayers);
	TogglePlayerSpectating(playerid, true);
	PlayerInfo[playerid][pSpecId] = i;
	SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(i));
	SetPlayerInterior(playerid, GetPlayerInterior(i));
	if (!IsPlayerInAnyVehicle(i)) {
		PlayerSpectatePlayer(playerid, i);
	} else {
		PlayerSpectateVehicle(playerid, GetPlayerVehicleID(i));
	}
	Text_Send(playerid, $EWATCH);
	return 1;
}

//End of File
/* (c) H2O Multiplayer 2018-2020. All rights reserved. */