/*
	SWAT vs Terrorists is a team death-match SA-MP game-mode script. 
	Compatible with SA-MP 0.3.7 and later releases.

	Author: H2O
	Licensed under GNU GPLv3

	(c) 2018-2020 H2O Multiplayer. All rights reserved.
	Website: h2omultiplayer.com

	Some admin commands for events
*/

#include <YSI_Coding\y_hooks>

//Support for y_text, load language files...
#include <YSI_Players\y_text> //Y_Less
loadtext mode_text[all], mode_text[client], mode_text[newcs], mode_text[dialogs], mode_text[gametexts];

//Check player state
hook OnPlayerStateChange(playerid, newstate, oldstate) {
	if (Iter_Contains(ePlayers, playerid) && EventInfo[E_ALLOWLEAVECARS] == 0 && EventInfo[E_STARTED]) {
		pEventInfo[playerid][P_CARTIMER] = 20;
		Text_Send(playerid, $CLIENT_172x);
	}
	return 1;
}

//
/*
		C O M M A N D S!
*/
//

//PUBG

//PUBG event commands

flags:spubg(CMD_ADMIN);
CMD:spubg(playerid) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		if (PUBGOpened || PUBGStarted) return Text_Send(playerid, $NEWCLIENT_171x);
		SetTimer("AliveUpdate", 1000, false);
		SetTimer("StartPUBG", 60000, false);
		Text_Send(@pVerified, $NEWSERVER_58x);
		GameTextForAll("~g~PUBG EVENT~n~/PUBG", 3000, 3);
		PUBGOpened = true;
		PUBGRadius = 800.0;
		GZ_ShapeDestroy(PUBGCircle);
		PUBGCircle = GZ_ShapeCreate(CIRCUMFERENCE, 4023.5042, 3750.9209, PUBGRadius);
		GZ_ShapeShowForAll(PUBGCircle, X11_RED2);
		PUBGKills = 0;
		TextDrawSetString(PUBGKillsTD, "0 KILLED");
		
		PUBGVehicles[0] = CreateVehicle(423,-38.5218,-41.0587,3.1429,337.0879,0,7,-1); // pubg car
		PUBGVehicles[1] = CreateVehicle(509,-20.7211,47.5877,2.6267,70.0511,0,7,-1); // pubg bike
		PUBGVehicles[2] = CreateVehicle(531,-54.2063,27.2287,3.0787,70.1768,0,7,-1); // farm tractor
		PUBGVehicles[3] = CreateVehicle(531,-51.7645,47.1532,3.0826,341.7239,0,7,-1); // farm tractor
		PUBGVehicles[4] = CreateVehicle(531,-102.9677,65.6263,3.0828,295.1403,0,7,-1); // farm tractor
		
		for (new i = 0; i < sizeof(PUBGVehicles); i++) {
			SetVehicleVirtualWorld(PUBGVehicles[i], 113);
		}

		new
			Float: FX,
			Float: FY,
			Float: FZ
		;

		for (new p = 0; p < sizeof(PUBGArray); p++) {
			FX = PUBGArray[p][0];
			FY = PUBGArray[p][1];
			CA_FindZ_For2DCoord(FX, FY, FZ);
			
			new random_type = random(100);
			switch (random_type) {
				case 0..39: {
					for (new i = 0; i < MAX_SLOTS; i++) {
						if (!gLootExists[i]) {
							gLootItem[i] = random(MAX_ITEMS);
							if (gLootItem[i] != PL) {
								new Float: RX = 0.0;

								if (gLootItem[i] != MASK && gLootItem[i] != HELMET && gLootItem[i] != LANDMINES) {
									RX = 90.0;
								}

								gLootPickable[i] = 0;
								gLootAmt[i] = random(2) + 1;
								gLootObj[i] = CreateDynamicObject(ItemsInfo[gLootItem[i]][Item_Object], FX, FY, FZ + 0.1, RX, 0.0, 12.5);
								gLootArea[i] = CreateDynamicCircle(FX, FY, 1.0);
								gLootPickable[i] = 1;

								new randposchange = random(7);
								switch (randposchange) {
									case 0: FX += 2.0, FY -= 2.0;
									case 1: FX += 2.2, FY -= 2.2;
									case 2: FX += 2.4, FY -= 2.4;
									case 3: FX += 2.6, FY -= 2.6;
									case 4: FX -= 2.0, FY += 2.0;
									case 5: FX -= 2.2, FY += 2.2;
									case 6: FX -= 2.4, FY += 2.4;
								}
							}

							KillTimer(gLootTimer[i]);
							gLootTimer[i] = SetTimerEx("AlterLootPickup", 795000, false, "i", i);
							gLootExists[i] = 1;
							break;
						}
					}
				}
				case 40..100: {
					new randomweap = random(10), weapon, ammo;
					switch (randomweap) {
						case 0: weapon = WEAPON_DEAGLE, ammo = random(100) + 50;
						case 1: weapon = WEAPON_SHOTGSPA, ammo = random(100) + 50;
						case 2: weapon = WEAPON_SHOTGUN, ammo = random(100) + 50;
						case 3: weapon = WEAPON_GRENADE, ammo = random(2) + 1;
						case 4: weapon = WEAPON_MOLTOV, ammo = random(2) + 1;
						case 5: weapon = WEAPON_COLT45, ammo = random(200) + 55;
						case 6: weapon = WEAPON_SILENCED, ammo = random(200) + 55;
						case 7: weapon = WEAPON_TEC9, ammo = random(200) + 55;
						case 8: weapon = WEAPON_MP5, ammo = random(200) + 55;
						case 9: weapon = WEAPON_SNIPER, ammo = random(25) + 55;
					}
					for (new a = 0; a < MAX_SLOTS; a++) {
						if (!gWeaponExists[a]) {
							gWeaponExists[a] = 1;
							gWeaponPickable[a] = 0;

							gWeaponObj[a] = CreateDynamicObject(GetWeaponModel(weapon), FX, FY, FZ, 90.0, 0.0, 0.0);

							new weap_label[45];
							format(weap_label, sizeof(weap_label), "%s(%d)", ReturnWeaponName(weapon), ammo);
							gWeapon3DLabel[a] = CreateDynamic3DTextLabel(weap_label, 0xFFFFFFFF, FX, FY, FZ, 50.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, 0, 0);

							gWeaponID[a] = weapon;
							gWeaponAmmo[a] = ammo;

							gWeaponPickable[a] = 1;
							gWeaponTimer[a] = SetTimerEx("AlterWeaponPickup", 450000, false, "ii", INVALID_PLAYER_ID, a);
							gWeaponArea[a] = CreateDynamicCircle(FX, FY, 2.5);

							break;
						}
					}
				}
			}
		}
		new String[128];
		format(String, sizeof(String), "Administrator %s started the PUBG event.", PlayerInfo[playerid][PlayerName]);
		MessageToAdmins(0x2281C8FF, String);
	}    
	return 1;
}

flags:epubg(CMD_ADMIN);
CMD:epubg(playerid) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		if (!PUBGStarted) return Text_Send(playerid, $NEWCLIENT_172x);
		if (!Iter_Count(PUBGPlayers)) {
			PUBGStarted = false;
			Text_Send(@pVerified, $SERVER_65x);
			HidePUBGWinner();
		}
		foreach (new i: Player) {
			if (Iter_Contains(PUBGPlayers, i)) {
				TextDrawHideForPlayer(i, PUBGKillsTD);

				new msg[128];

				format(msg, sizeof(msg), "%d Kills", PUBGKills ++);
				TextDrawSetString(PUBGKillsTD, msg);

				TextDrawHideForPlayer(i, PUBGAreaTD);
				TextDrawHideForPlayer(i, PUBGAliveTD);
				TextDrawHideForPlayer(i, PUBGKillTD);
				if (Iter_Count(PUBGPlayers) == 1) {
					new winner = Iter_Random(PUBGPlayers);
					TextDrawHideForPlayer(winner, PUBGKillsTD);
					TextDrawHideForPlayer(winner, PUBGKillTD);
					Text_Send(@pVerified, $CHICKEN_DINNER, PlayerInfo[winner][PlayerName]);
					PlayerInfo[winner][pPUBGEventsWon] ++;
					PlayerInfo[winner][pEXPEarned] += 50;
					GivePlayerScore(winner, 100);
					GivePlayerCash(winner, 500000);
					PlayerPlaySound(winner, 1095, 0.0, 0.0, 0.0);
					Iter_Clear(PUBGPlayers);
					PUBGStarted = false;
					SetPlayerHealth(winner, 0);
					TextDrawHideForPlayer(winner, PUBGAreaTD);
					TextDrawHideForPlayer(winner, PUBGAliveTD);
					GameTextForPlayer(winner, "~g~WINNER WINNER CHICKEN DINNER!", 3000, 3);
					TextDrawSetString(PUBGWinnerTD[1], PlayerInfo[winner][PlayerName]);
					new str[128];
					format(str, sizeof(str), "~w~KILLS: ~g~%d            ~w~REWARD: ~g~$500000 & 100 Score", PUBGKills);
					TextDrawSetString(PUBGWinnerTD[3], str);
					for (new x = 0; x < sizeof(PUBGWinnerTD); x++) {
						TextDrawShowForAll(PUBGWinnerTD[x]);
					}
					SetTimer("HidePUBGWinner", 3000, false);
				} 
				Iter_SafeRemove(PUBGPlayers, i, i);
			}
		}
		new String[128];
		format(String, sizeof(String), "Administrator %s ended the PUBG event.", PlayerInfo[playerid][PlayerName]);
		MessageToAdmins(0x2281C8FF, String);
	}    
	return 1;
}

//Event commands

flags:event(CMD_ADMIN);
CMD:event(playerid) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		inline EventCash(pid, dialogid, response, listitem, string:inputtext[]) {
			#pragma unused dialogid, inputtext, listitem
			PC_EmulateCommand(pid, "/event");
			if (!response) return 1;
			if (!EventInfo[E_STARTED]) return Text_Send(pid, $CLIENT_420x);

			EventInfo[E_CASH] = strval(inputtext);
		}
		inline EventScore(pid, dialogid, response, listitem, string:inputtext[]) {
			#pragma unused dialogid, inputtext, listitem
			PC_EmulateCommand(pid, "/event");
			if (!response) return 1;
			if (!EventInfo[E_STARTED]) return Text_Send(pid, $CLIENT_420x);

			EventInfo[E_SCORE] = strval(inputtext);
		}
		inline EventName(pid, dialogid, response, listitem, string:inputtext[]) {
			#pragma unused dialogid, inputtext, listitem
			PC_EmulateCommand(pid, "/event");
			if (!response) return 1;
			if (!EventInfo[E_STARTED]) return Text_Send(pid, $CLIENT_420x);
			if (!strlen(inputtext)) return Dialog_ShowCallback(pid, using inline EventName, DIALOG_STYLE_INPUT, "Custom event name:", "Write the name of this event:", "Input", "X");

			format(EventInfo[E_NAME], sizeof(EventInfo[E_NAME]), "%s", inputtext);
		}
		inline EventVehicle(pid, dialogid, response, listitem, string:inputtext[]) {
			#pragma unused dialogid, inputtext, listitem
			PC_EmulateCommand(pid, "/event");
			if (!response) return 1;
			if (!EventInfo[E_STARTED]) return Text_Send(pid, $CLIENT_420x);
			if (strval(inputtext) < 400 || strval(inputtext) > 611 || !strlen(inputtext)) return Dialog_ShowCallback(pid, using inline EventVehicle, DIALOG_STYLE_INPUT, "Custom event vehicle:", "{FF0000}Wrong vehicle ID.\nWrite the vehicle id for current event players:", "Input", "X");

			foreach (new i: ePlayers) {
				if (PlayerInfo[i][pCar] != -1) DestroyVehicle(PlayerInfo[i][pCar]);
				PlayerInfo[i][pCar] = -1;

				new Float: Position[4], Int, World;

				Int = GetPlayerInterior(i);
				World = GetPlayerVirtualWorld(i);

				GetPlayerPos(i, Position[0], Position[1], Position[2]);
				GetPlayerFacingAngle(i, Position[3]);

				PlayerInfo[i][pCar] = CreateVehicle(strval(inputtext), Position[0], Position[1], Position[2], Position[3], 0, 3, -1);

				LinkVehicleToInterior(PlayerInfo[i][pCar], Int);
				SetVehicleVirtualWorld(PlayerInfo[i][pCar], World);
				PutPlayerInVehicle(i, PlayerInfo[i][pCar], 0);
			}
		}
		inline EventWeap1(pid, dialogid, response, listitem, string:inputtext[]) {
			#pragma unused dialogid, inputtext, listitem
			PC_EmulateCommand(pid, "/event");
			if (!response) return 1;
			if (!EventInfo[E_STARTED]) return Text_Send(pid, $CLIENT_420x);

			new weapon, ammo;
			if (sscanf(inputtext, "ii", weapon, ammo)) {
				Text_Send(pid, $CLIENT_422x);
				return Dialog_ShowCallback(pid, using inline EventWeap1, DIALOG_STYLE_INPUT, "Custom event weapon 1:", "Write your weapon id and ammount of ammo below.\n {E8E8E8}-> (e.g. 24 500)", "Input", "X");
			}

			EventInfo[E_WEAP1][0] = weapon;
			EventInfo[E_WEAP1][1] = ammo;

			foreach (new i: ePlayers) {
				GivePlayerWeapon(i, EventInfo[E_WEAP1][0], EventInfo[E_WEAP1][1]);
			}
		}
		inline EventWeap2(pid, dialogid, response, listitem, string:inputtext[]) {
			#pragma unused dialogid, inputtext, listitem
			PC_EmulateCommand(pid, "/event");
			if (!response) return 1;
			if (!EventInfo[E_STARTED]) return Text_Send(pid, $CLIENT_420x);

			new weapon, ammo;
			if (sscanf(inputtext, "ii", weapon, ammo)) {
				Text_Send(pid, $CLIENT_422x);
				return Dialog_ShowCallback(pid, using inline EventWeap2, DIALOG_STYLE_INPUT, "Custom event weapon 2:", "Write your weapon id and ammount of ammo below.\n {E8E8E8}-> (e.g. 24 500)", "Input", "X");
			}

			EventInfo[E_WEAP2][0] = weapon;
			EventInfo[E_WEAP2][1] = ammo;

			foreach (new i: ePlayers) {
				GivePlayerWeapon(i, EventInfo[E_WEAP1][0], EventInfo[E_WEAP1][1]);
			}
		}
		inline EventWeap3(pid, dialogid, response, listitem, string:inputtext[]) {
			#pragma unused dialogid, inputtext, listitem
			PC_EmulateCommand(pid, "/event");
			if (!response) return 1;
			if (!EventInfo[E_STARTED]) return Text_Send(pid, $CLIENT_420x);

			new weapon, ammo;
			if (sscanf(inputtext, "ii", weapon, ammo)) {
				Text_Send(pid, $CLIENT_422x);
				return Dialog_ShowCallback(pid, using inline EventWeap3, DIALOG_STYLE_INPUT, "Custom event weapon 3:", "Write your weapon id and ammount of ammo below.\n {E8E8E8}-> (e.g. 24 500)", "Input", "X");
			}

			EventInfo[E_WEAP3][0] = weapon;
			EventInfo[E_WEAP3][1] = ammo;

			foreach (new i: ePlayers) {
				GivePlayerWeapon(i, EventInfo[E_WEAP1][0], EventInfo[E_WEAP1][1]);
			}
		}
		inline EventWeap4(pid, dialogid, response, listitem, string:inputtext[]) {
			#pragma unused dialogid, inputtext, listitem
			PC_EmulateCommand(pid, "/event");
			if (!response) return 1;
			if (!EventInfo[E_STARTED]) return Text_Send(pid, $CLIENT_420x);

			new weapon, ammo;
			if (sscanf(inputtext, "ii", weapon, ammo)) {
				Text_Send(pid, $CLIENT_422x);
				return Dialog_ShowCallback(pid, using inline EventWeap4, DIALOG_STYLE_INPUT, "Custom event weapon 4:", "Write your weapon id and ammount of ammo below.\n {E8E8E8}-> (e.g. 24 500)", "Input", "X");
			}

			EventInfo[E_WEAP4][0] = weapon;
			EventInfo[E_WEAP4][1] = ammo;

			foreach (new i: ePlayers) {
				GivePlayerWeapon(i, EventInfo[E_WEAP1][0], EventInfo[E_WEAP1][1]);
			}
		}
		inline EventSpawnType(pid, dialogid, response, listitem, string:inputtext[]) {
			#pragma unused dialogid, inputtext
			if (!response) return PC_EmulateCommand(pid, "/event");
			switch (listitem) {
				case 0: {
					if (!EventInfo[E_STARTED]) return Text_Send(pid, $CLIENT_420x);
					if (EventInfo[E_SPAWN_TYPE] != EVENT_SPAWN_INVALID) return Text_Send(pid, $CLIENT_425x);

					if (EventInfo[E_TYPE] != 1) {
						EventInfo[E_MAX_PLAYERS] = 16;
					} else {
						EventInfo[E_MAX_PLAYERS] = 32;
					}

					EventInfo[E_SPAWN_TYPE] = EVENT_SPAWN_RANDOM;
					EventInfo[E_SPAWNS] = 0;
				}
				case 1: {
					if (!EventInfo[E_STARTED]) return Text_Send(pid, $CLIENT_420x);
					if (EventInfo[E_SPAWN_TYPE] != EVENT_SPAWN_INVALID) return Text_Send(pid, $CLIENT_425x);
					if (EventInfo[E_TYPE] == 1 || EventInfo[E_TYPE] == 2) return Text_Send(pid, $CLIENT_426x);

					new Float: Position[4], Int, World;

					EventInfo[E_SPAWN_TYPE] = EVENT_SPAWN_ADMIN;
					EventInfo[E_MAX_PLAYERS] = 32;

					GetPlayerPos(pid, Position[0], Position[1], Position[2]);
					GetPlayerFacingAngle(pid, Position[3]);

					Int = GetPlayerInterior(pid);
					World = GetPlayerVirtualWorld(pid);

					SpawnInfo[0][S_COORDS][0] = Position[0];
					SpawnInfo[0][S_COORDS][1] = Position[1];
					SpawnInfo[0][S_COORDS][2] = Position[2];
					SpawnInfo[0][S_COORDS][3] = Position[3];

					EventInfo[E_INTERIOR] = Int;
					EventInfo[E_WORLD] = World;

					PC_EmulateCommand(pid, "/event");
				}
			}
		}
		inline EventMode(pid, dialogid, response, listitem, string:inputtext[]) {
			#pragma unused dialogid, inputtext
			if (!response) return 1;

			switch (listitem) {
				case 0:
				{
					if (!EventInfo[E_STARTED]) return Text_Send(pid, $CLIENT_420x);
					if (Iter_Count(ePlayers) >= 1) return Text_Send(pid, $CLIENT_427x);

					EventInfo[E_TYPE] = 1;
					PC_EmulateCommand(pid, "/event");
				}
				case 1:
				{
					if (!EventInfo[E_STARTED]) return Text_Send(pid, $CLIENT_420x);
					if (Iter_Count(ePlayers) >= 1) return Text_Send(pid, $CLIENT_427x);

					EventInfo[E_TYPE] = 2;
					PC_EmulateCommand(pid, "/event");
				}
				case 2:
				{
					if (!EventInfo[E_STARTED]) return Text_Send(pid, $CLIENT_420x);
					if (Iter_Count(ePlayers) >= 1) return Text_Send(pid, $CLIENT_427x);

					EventInfo[E_TYPE] = 0;
					PC_EmulateCommand(pid, "/event");
				}
			}
		}
		inline EventManager(pid, dialogid, response, listitem, string:inputtext[]) {
			#pragma unused dialogid, inputtext
			if (!response) return 1;

			switch (listitem) {
				case 0: {
					if (EventInfo[E_STARTED] == 1) return Text_Send(pid, $CLIENT_425x);

					new clear_data[E_DATA_ENUM];
					EventInfo = clear_data;

					new clear_data2[E_RACE_ENUM], clear_data3[E_SPAWN_ENUM];

					for (new i = 0; i < MAX_CHECKPOINTS; i++) {
						RaceInfo[i] = clear_data2;
						SpawnInfo[i] = clear_data3;
					}

					EventInfo[E_STARTED] = 1;
					EventInfo[E_OPENED] = 0;

					EventInfo[E_SPAWN_TYPE] = EVENT_SPAWN_INVALID;
					EventInfo[E_TYPE] = -1;

					EventInfo[E_FREEZE] = 1;
					EventInfo[E_AUTO] = 0;
				}
				case 1: {
					if (!EventInfo[E_STARTED]) return Text_Send(pid, $CLIENT_420x);
					if (EventInfo[E_SPAWN_TYPE] != EVENT_SPAWN_INVALID) return Text_Send(pid, $CLIENT_425x);

					Dialog_ShowCallback(pid, using inline EventSpawnType, DIALOG_STYLE_LIST, "Choose Spawn",
					"Random spawn locations\n\
					Set location here", ">>", "X");
				}
				case 2: {
					PC_EmulateCommand(pid, "/event");
					if (!EventInfo[E_STARTED]) return Text_Send(pid, $CLIENT_420x);
					Dialog_ShowCallback(pid, using inline EventWeap1, DIALOG_STYLE_INPUT, "Custom event weapon 1:", "Write your weapon id and ammount of ammo below.\n {E8E8E8}-> (e.g. 24 500)", "Input", "X");
				}
				case 3: {
					PC_EmulateCommand(pid, "/event");
					if (!EventInfo[E_STARTED]) return Text_Send(pid, $CLIENT_420x);
					Dialog_ShowCallback(pid, using inline EventWeap2, DIALOG_STYLE_INPUT, "Custom event weapon 2:", "Write your weapon id and ammount of ammo below.\n {E8E8E8}-> (e.g. 24 500)", "Input", "X");
				}
				case 4: {
					PC_EmulateCommand(pid, "/event");
					if (!EventInfo[E_STARTED]) return Text_Send(pid, $CLIENT_420x);
					Dialog_ShowCallback(pid, using inline EventWeap3, DIALOG_STYLE_INPUT, "Custom event weapon 3:", "Write your weapon id and ammount of ammo below.\n {E8E8E8}-> (e.g. 24 500)", "Input", "X");
				}
				case 5: {
					PC_EmulateCommand(pid, "/event");
					if (!EventInfo[E_STARTED]) return Text_Send(pid, $CLIENT_420x);
					Dialog_ShowCallback(pid, using inline EventWeap4, DIALOG_STYLE_INPUT, "Custom event weapon 4:", "Write your weapon id and ammount of ammo below.\n {E8E8E8}-> (e.g. 24 500)", "Input", "X");
				}
				case 6: {
					PC_EmulateCommand(pid, "/event");
					if (!EventInfo[E_STARTED]) return Text_Send(pid, $CLIENT_420x);
					Dialog_ShowCallback(pid, using inline EventVehicle, DIALOG_STYLE_INPUT, "Custom event vehicle:", "Write the vehicle id for current event players:", "Input", "X");
				}
				case 7: {
					PC_EmulateCommand(pid, "/event");
					if (!EventInfo[E_STARTED]) return Text_Send(pid, $CLIENT_420x);
					Dialog_ShowCallback(pid, using inline EventName, DIALOG_STYLE_INPUT, "Custom event name:", "Write the name of this event:", "Input", "X");
				}
				case 8: {
					PC_EmulateCommand(pid, "/event");
					if (!EventInfo[E_STARTED]) return Text_Send(pid, $CLIENT_420x);

					foreach (new i: ePlayers) {
						SetPlayerHealth(i, 100.0);
					}
				}
				case 9: {
					PC_EmulateCommand(pid, "/event");
					if (!EventInfo[E_STARTED]) return Text_Send(pid, $CLIENT_420x);

					foreach (new i: ePlayers) {
						SetPlayerArmour(i, 100.0);
					}
				}
				case 10: {
					PC_EmulateCommand(pid, "/event");
					if (!EventInfo[E_STARTED]) return Text_Send(pid, $CLIENT_420x);

					new Float: Position[3], Int, World;

					Int = GetPlayerInterior(pid);
					World = GetPlayerVirtualWorld(pid);

					GetPlayerPos(pid, Position[0], Position[1], Position[2]);

					foreach (new i: ePlayers)
					{
						SetPlayerPos(i, Position[0], Position[1], Position[2]);
						SetPlayerInterior(i, Int);
						SetPlayerVirtualWorld(i, World);
					}
				}
				case 11: {
					PC_EmulateCommand(pid, "/event");
					if (!EventInfo[E_STARTED]) return Text_Send(pid, $CLIENT_420x);

					EventInfo[E_FREEZE] = 1;

					foreach (new i: ePlayers) {
						TogglePlayerControllable(i, false);
					}
				}
				case 12: {
					PC_EmulateCommand(pid, "/event");
					if (!EventInfo[E_STARTED]) return Text_Send(pid, $CLIENT_420x);

					EventInfo[E_FREEZE] = 0;

					foreach (new i: ePlayers) {
						TogglePlayerControllable(i, true);
					}
				}
				case 13: {
					PC_EmulateCommand(pid, "/event");
					if (EventInfo[E_STARTED] == 1 && EventInfo[E_OPENED] == 1) return Text_Send(pid, $CLIENT_425x);
					if (!strlen(EventInfo[E_NAME])) return Text_Send(pid, $CLIENT_428x);
					if (EventInfo[E_SPAWN_TYPE] == EVENT_SPAWN_INVALID) return Text_Send(pid, $CLIENT_429x);
					if (EventInfo[E_SPAWN_TYPE] == EVENT_SPAWN_RANDOM && EventInfo[E_SPAWNS] == 0) return Text_Send(pid, $CLIENT_429x);
					if (EventInfo[E_TYPE] == 2 && EventInfo[E_CHECKPOINTS] < 3) return Text_Send(pid, $CLIENT_430x);

					GameTextForAll("~w~EVENT!~n~~g~/join",4000,3);

					EventInfo[E_OPENED] = 1;
					LogAdminAction(pid, "Opened an event.");
				}
				case 14: {
					PC_EmulateCommand(pid, "/event");
					if (!EventInfo[E_STARTED] || EventInfo[E_OPENED] == 0) return Text_Send(pid, $CLIENT_425x);
					if (!strlen(EventInfo[E_NAME])) return Text_Send(pid, $CLIENT_428x);
					if (EventInfo[E_SPAWN_TYPE] == EVENT_SPAWN_INVALID) return Text_Send(pid, $CLIENT_429x);
					if (EventInfo[E_SPAWN_TYPE] == EVENT_SPAWN_RANDOM && EventInfo[E_SPAWNS] == 0) return Text_Send(pid, $CLIENT_429x);

					EventInfo[E_OPENED] = 0;

					foreach (new i: ePlayers) {
						GameTextForPlayer(i, "~g~GO GO!", 2000, 3);
						TogglePlayerControllable(i, true);

						if (EventInfo[E_FREEZE] == 1) {
								EventInfo[E_FREEZE] = 0;
						}
					}
					
					LogAdminAction(pid, "Started an event.");
				}
				case 15: {
					if (!EventInfo[E_STARTED]) return Text_Send(pid, $CLIENT_420x);
					Dialog_ShowCallback(pid, using inline EventScore, DIALOG_STYLE_INPUT, "Custom event score bonus:", "Write the score bonus of event below:", "Input", "X");
				}
				case 16: {
					if (!EventInfo[E_STARTED]) return Text_Send(pid, $CLIENT_420x);
					Dialog_ShowCallback(pid, using inline EventCash, DIALOG_STYLE_INPUT, "Custom event cash bonus:", "Write the cash bonus of event below:", "Input", "X");
				}
				case 17: {
					PC_EmulateCommand(pid, "/event");
					if (!EventInfo[E_STARTED]) return Text_Send(pid, $CLIENT_420x);
					if (!strlen(EventInfo[E_NAME])) return Text_Send(pid, $CLIENT_428x);
					if (EventInfo[E_SPAWN_TYPE] == EVENT_SPAWN_INVALID) return Text_Send(pid, $CLIENT_429x);
					if (EventInfo[E_SPAWN_TYPE] == EVENT_SPAWN_RANDOM && EventInfo[E_SPAWNS] == 0) return Text_Send(pid, $CLIENT_429x);
					if (EventInfo[E_TYPE] == 2) return Text_Send(pid, $CLIENT_426x);

					new count;

					foreach (new i: ePlayers) {
						if (IsPlayerSpawned(i)) {
							count++;
						}
					}

					if (count == 0) return Text_Send(pid, $CLIENT_420x);
					Text_Send(@pVerified, $SERVER_26x, EventInfo[E_NAME]);

					Text_Send(@pVerified, $NEWSERVER_37x);

					EventInfo[E_OPENED] = 0;
					EventInfo[E_STARTED] = 0;

					new winners = 0;

					foreach (new i: ePlayers) {
						TogglePlayerControllable(i, true);
						SetPlayerHealth(i, 0.0);

						new Player_Name[MAX_PLAYER_NAME];
						GetPlayerName(i, Player_Name, sizeof(Player_Name));

						winners ++;

						Text_Send(@pVerified, $EVENT_WON_LIST, winners, Player_Name, EventInfo[E_SCORE], EventInfo[E_CASH]);

						GivePlayerCash(i, EventInfo[E_CASH]);
						GivePlayerScore(i, EventInfo[E_SCORE]);
						PlayerInfo[i][sEvents] ++;
						PlayerInfo[i][pEventsWon] ++;

						if (PlayerInfo[i][pCar] != -1) {
							DestroyVehicle(PlayerInfo[i][pCar]);
						}
					}

					Iter_Clear(ePlayers);

					new clear_data[E_DATA_ENUM];
					EventInfo = clear_data;

					EventInfo[E_SPAWN_TYPE] = EVENT_SPAWN_INVALID;
					EventInfo[E_TYPE] = -1;
				}
				case 18: {
					if (!EventInfo[E_STARTED]) return Text_Send(pid, $CLIENT_420x);

					new clear_data[E_DATA_ENUM];
					EventInfo = clear_data;

					EventInfo[E_STARTED] = 0;
					EventInfo[E_OPENED] = 0;

					EventInfo[E_SPAWN_TYPE] = EVENT_SPAWN_INVALID;
					EventInfo[E_TYPE] = -1;

					foreach (new i: ePlayers) {
						SpawnPlayer(i);
						DisablePlayerCheckpoint(i);
					}

					Iter_Clear(ePlayers);
				}
				case 19: {
					PC_EmulateCommand(pid, "/event");

					if (!EventInfo[E_STARTED]) return Text_Send(pid, $CLIENT_420x);
					if (EventInfo[E_TYPE] == 1) return Text_Send(pid, $CLIENT_426x);

					if (EventInfo[E_ALLOWLEAVECARS] == 1) {
						EventInfo[E_ALLOWLEAVECARS] = 0;
						Text_Send(pid, $CLIENT_431x);
					}
					else
					{
						EventInfo[E_ALLOWLEAVECARS] = 1;
						Text_Send(pid, $CLIENT_432x);
					}
				}
				case 20: {
					PC_EmulateCommand(pid, "/event");

					if (!EventInfo[E_STARTED]) return Text_Send(pid, $CLIENT_420x);

					foreach (new i: ePlayers) {
						if (IsPlayerInAnyVehicle(i)) {
							RepairVehicle(i);
						}
					}
				}
			}
		}
		if (EventInfo[E_STARTED] == 1) {
			if (EventInfo[E_TYPE] != -1) {
				if (EventInfo[E_SPAWN_TYPE] != -1) {
					Dialog_ShowCallback(playerid, using inline EventManager, DIALOG_STYLE_LIST, "Event",
					"{FF0000}Start Event\n{FF0000}Event Location\nEvent Weapon 1\nEvent Weapon 2\nEvent Weapon 3\nEvent Weapon 4\n\
					Give Vehicle\nEvent Name\nHeal Players\nArmour Players\nGet Players\nFreeze Players\nUnfreeze Players\n\
					Allow Joins\nClose Joins\nEvent Score\nEvent Money\nEvent Finish\nEvent Stop\nLeaving Cars", ">>", "X");
				} else {
					Dialog_ShowCallback(playerid, using inline EventManager, DIALOG_STYLE_LIST, "Event",
					"{FF0000}Start Event\nEvent Location", ">>", "X");
				}
			}
			else
			{
				Dialog_ShowCallback(playerid, using inline EventMode, DIALOG_STYLE_LIST, "Event",
				"TDM Event\nRace Event\nDeath-match Event", ">>", "X");
			}
		} else if (!EventInfo[E_STARTED]) {
			Dialog_ShowCallback(playerid, using inline EventManager, DIALOG_STYLE_LIST, "Event",
			"Start Event", ">>", "X");
		}
	}
	return 1;
}

flags:here(CMD_ADMIN);
CMD:here(playerid) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		if (EventInfo[E_TYPE] == 1 && EventInfo[E_SPAWNS] == 2) return Text_Send(playerid, $CLIENT_433x);
		if (EventInfo[E_SPAWN_TYPE] != EVENT_SPAWN_RANDOM) return Text_Send(playerid, $CLIENT_426x);
		if (EventInfo[E_SPAWNS] >= 69) return Text_Send(playerid, $CLIENT_420x);

		new Float: Position[4], Int, World;

		GetPlayerPos(playerid, Position[0], Position[1], Position[2]);
		GetPlayerFacingAngle(playerid, Position[3]);

		Int = GetPlayerInterior(playerid);
		World = GetPlayerVirtualWorld(playerid);

		SpawnInfo[EventInfo[E_SPAWNS]][S_COORDS][0] = Position[0];
		SpawnInfo[EventInfo[E_SPAWNS]][S_COORDS][1] = Position[1];
		SpawnInfo[EventInfo[E_SPAWNS]][S_COORDS][2] = Position[2];
		SpawnInfo[EventInfo[E_SPAWNS]][S_COORDS][3] = Position[3];

		EventInfo[E_MAX_PLAYERS] += 7;
		EventInfo[E_SPAWNS]++;

		EventInfo[E_INTERIOR] = Int;
		EventInfo[E_WORLD] = World;

	}
	return 1;
}

flags:eopen(CMD_ADMIN);
CMD:eopen(playerid) {
	if (!PlayerInfo[playerid][pAdminLevel]) return 1;
	if (EventInfo[E_STARTED] == 1 && EventInfo[E_OPENED] == 1) return Text_Send(playerid, $CLIENT_425x);
	if (!strlen(EventInfo[E_NAME])) return Text_Send(playerid, $CLIENT_428x);
	if (EventInfo[E_SPAWN_TYPE] == EVENT_SPAWN_INVALID) return Text_Send(playerid, $CLIENT_429x);
	if (EventInfo[E_SPAWN_TYPE] == EVENT_SPAWN_RANDOM && EventInfo[E_SPAWNS] == 0) return Text_Send(playerid, $CLIENT_429x);
	if (EventInfo[E_TYPE] == 2 && EventInfo[E_CHECKPOINTS] < 3) return Text_Send(playerid, $CLIENT_430x);

	EventInfo[E_OPENED] = 1;

	GameTextForAll("~g~EVENT!~n~~w~/join", 5000, 3);
	LogAdminAction(playerid, "Opened an event.");
	return 1;
}

flags:estart(CMD_ADMIN);
CMD:estart(playerid, params[]) {
	if (!PlayerInfo[playerid][pAdminLevel]) return 1;
	if (!EventInfo[E_STARTED] || !EventInfo[E_OPENED]) return Text_Send(playerid, $CLIENT_420x);
	if (!strlen(EventInfo[E_NAME])) return Text_Send(playerid, $CLIENT_428x);
	if (EventInfo[E_SPAWN_TYPE] == EVENT_SPAWN_INVALID) return Text_Send(playerid, $CLIENT_429x);
	if (EventInfo[E_SPAWN_TYPE] == EVENT_SPAWN_RANDOM && EventInfo[E_SPAWNS] == 0) return Text_Send(playerid, $CLIENT_429x);

	EventInfo[E_OPENED] = 0;

	foreach (new i: ePlayers) {
		GameTextForPlayer(i, "~g~GO GO!", 2000, 3);
		TogglePlayerControllable(i, true);

		if (EventInfo[E_FREEZE] == 1) {
			EventInfo[E_FREEZE] = 0;
		}
	}

	if (EventInfo[E_TYPE] == 2 && !isnull(params) && IsNumeric(params)) {
		new query[650];
		mysql_format(Database, query, sizeof(query), "INSERT INTO `RacesData` (`RaceName`, `RaceMaker`, `RaceVehicle`, `RaceInt`, `RaceWorld`, `RaceDate`) \
			VALUES ('%e', '%e', '%d', '%d', '%d', '%d')", EventInfo[E_NAME], PlayerInfo[playerid][PlayerName], strval(params), EventInfo[E_INTERIOR], EventInfo[E_WORLD], gettime());
		mysql_tquery(Database, query);

		for (new i = 0; i < EventInfo[E_SPAWNS]; i++) {
			mysql_format(Database, query, sizeof(query), "INSERT INTO `RacesSpawnPoints` (`RaceId`, `RX`, `RY`, `RZ`, `RRot`) \
				VALUES ((SELECT `RaceId` FROM `RacesData` WHERE `RaceName` = '%e'), '%f', '%f', '%f', '%f')",
				EventInfo[E_NAME], SpawnInfo[i][S_COORDS][0], SpawnInfo[i][S_COORDS][1], SpawnInfo[i][S_COORDS][2], SpawnInfo[i][S_COORDS][3]);
			mysql_tquery(Database, query);
		}

		for (new i = 0; i < EventInfo[E_CHECKPOINTS]; i++) {
			mysql_format(Database, query, sizeof(query), "INSERT INTO `RacesCheckpoints` (`RaceId`, `RX`, `RY`, `RZ`, `RType`) \
				VALUES ((SELECT `RaceId` FROM `RacesData` WHERE `RaceName` = '%e'), '%f', '%f', '%f', '%d')",
				EventInfo[E_NAME], RaceInfo[i][R_COORDS][0], RaceInfo[i][R_COORDS][1], RaceInfo[i][R_COORDS][2], RaceInfo[i][R_TYPE]);
			mysql_tquery(Database, query);
		}
	}

	LogAdminAction(playerid, "Started an event.");
	return 1;
}

flags:ehealth(CMD_ADMIN);
CMD:ehealth(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		if (!EventInfo[E_STARTED]) return Text_Send(playerid, $CLIENT_420x);

		new health;
		if (sscanf(params, "i", health)) return ShowSyntax(playerid, "/ehealth [amount]");

		if (health == 0) return 1;

		foreach (new i: ePlayers) {
			SetPlayerHealth(i, health);
		}
	}
	return 1;
}

flags:earmour(CMD_ADMIN);
CMD:earmour(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		if (!EventInfo[E_STARTED]) return Text_Send(playerid, $CLIENT_420x);

		new armour;
		if (sscanf(params, "i", armour)) return ShowSyntax(playerid, "/earmour [amount]");

		foreach (new i: ePlayers) {
			SetPlayerArmour(i, armour);
		}

	}
	return 1;
}

flags:eskin(CMD_ADMIN);
CMD:eskin(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		if (!EventInfo[E_STARTED]) return Text_Send(playerid, $CLIENT_420x);

		new skin;
		if (sscanf(params, "i", skin)) return ShowSyntax(playerid, "/eskin [skin id]");
		if (!IsValidSkin(skin)) return ShowSyntax(playerid, "/eskin (event skin) [skin id]");

		foreach (new i: ePlayers) {
			SetPlayerSkin(i, skin);
		}
	}
	return 1;
}

//End of File
/* (c) H2O Multiplayer 2018-2020. All rights reserved. */