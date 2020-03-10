/*
	SWAT vs Terrorists is a team death-match SA-MP game-mode script. 
	Compatible with SA-MP 0.3.7 and later releases.

	Author: H2O
	Licensed under GNU GPLv3

	(c) 2018-2020 H2O Multiplayer. All rights reserved.
	Website: h2omultiplayer.com

	Core for the PUBG event
*/

#include <YSI\y_hooks>
#include <YSI\y_text>
loadtext mode_text[all], mode_text[client], mode_text[newcs], mode_text[dialogs], mode_text[gametexts];

forward HideBonus(playerid);
public HideBonus(playerid) return PlayerTextDrawHide(playerid, PUBGBonusTD[playerid]);

forward HidePUBGWinner();
public HidePUBGWinner() {
	for (new i = 0; i < sizeof(PUBGWinnerTD); i++) {
		TextDrawHideForAll(PUBGWinnerTD[i]);
	}
	TextDrawHideForAll(PUBGKillTD);
	TextDrawHideForAll(PUBGKillsTD);
	TextDrawHideForAll(PUBGAliveTD);
	TextDrawHideForAll(PUBGAreaTD);
	for (new i = 0; i < 5; i++) {
		if (IsValidVehicle(PUBGVehicles[i])) {
			CarDeleter(PUBGVehicles[i]);
		}
	}    
	return 1;
}

forward AliveUpdate();
public AliveUpdate() {
	if (PUBGOpened) {
		new players[10];
		format(players, sizeof(players), "%d ALIVE", Iter_Count(PUBGPlayers));
		TextDrawSetString(PUBGAliveTD, players);
		foreach(new i: PUBGPlayers) TextDrawShowForPlayer(i, PUBGAliveTD);
		SetTimer("AliveUpdate", 1000, false);
	}    
	return 1;
}

forward StartPUBG();
public StartPUBG() {
	if (PUBGOpened) {
		PUBGOpened = false;
		PUBGStarted = true;
		SetTimer("UpdatePUBG", 1000, false);
		foreach(new i: PUBGPlayers) {
			PlayerPlaySound(i, 15805, 0, 0, 0);
			Text_Send(i, $GO);
			SetPlayerVirtualWorld(i, PUBG_WORLD);
			SetPlayerInterior(i, 0);
			SetPlayerPos(i, 3300.2144 + frandom(15.0, -10.0), 3613.9907 + frandom(10.0, -15.0), frandom(200.0, 150.0));
			GivePlayerWeapon(i, 46, 1);
		}
	}    
	return 1;
}

forward ExecuteToxication();
public ExecuteToxication() {
	if (!PUBGStarted) return 1;
	PUBGRadius -= Multiplier;
	GZ_ShapeDestroy(PUBGCircle);
	PUBGCircle = GZ_ShapeCreate(CIRCUMFERENCE, 4023.5042, 3750.9209, PUBGRadius);
	GZ_ShapeShowForAll(PUBGCircle, X11_RED2);
	PUBGMeters -= Multiplier;
	if (PUBGMeters < 1.0) return 1;
	else return SetTimerEx("IntoxicateT", 500, false, "f", PUBGMeters);
}

forward UpdatePUBG();
public UpdatePUBG() {
	if (PUBGStarted) {
		new pubg[10];
		format(pubg, sizeof(pubg), "%d ALIVE", Iter_Count(PUBGPlayers));
		TextDrawSetString(PUBGAliveTD, pubg);
		foreach(new i: PUBGPlayers) TextDrawShowForPlayer(i, PUBGAliveTD);

		if (PUBGKillTick > 0) {
			foreach(new i: PUBGPlayers) TextDrawShowForPlayer(i, PUBGKillTD);
			PUBGKillTick --;
		} else TextDrawHideForAll(PUBGKillTD);

		if (++PUBGTimer > 5) {
			foreach (new i: Player) {
				if (GetPlayerState(i) != PLAYER_STATE_SPECTATING) {
					if (Iter_Contains(PUBGPlayers, i)) {
						new Float: X, Float: Y, Float: Z;
						GetPlayerPos(i, X, Y, Z);
						if (PUBGRadius < GetPointDistanceToPoint(X, Y, 4023.5042, 3750.9209)) {
							Text_Send(i, $PUBG_DANGER);
							new Float: HP;
							GetPlayerHealth(i, HP);
							SetPlayerHealth(i, HP -1.0);
							PlayerPlaySound(i, 1134, 0, 0, 0);
						}
					}
				}
			}
		}
		switch (PUBGTimer) {
			case 60:
			{
				TextDrawSetString(PUBGAreaTD, "Restricting area in 1 minute");
				foreach(new i: PUBGPlayers) TextDrawShowForPlayer(i, PUBGAreaTD);
			}
			case 65: foreach(new i: PUBGPlayers) TextDrawHideForPlayer(i, PUBGAreaTD);
			case 110:
			{
				TextDrawSetString(PUBGAreaTD, "Restricting area in 10 seconds");
				foreach(new i: PUBGPlayers) TextDrawShowForPlayer(i, PUBGAreaTD);
			}
			case 115: foreach(new i: PUBGPlayers) TextDrawHideForPlayer(i, PUBGAreaTD);
			case 120:
			{
				Multiplier = 5.0;
				TextDrawSetString(PUBGAreaTD, "Intoxicating.");
				Intoxicate(75.00);
				foreach(new i: PUBGPlayers) TextDrawShowForPlayer(i, PUBGAreaTD);
			}
			case 125: foreach(new i: PUBGPlayers) TextDrawHideForPlayer(i, PUBGAreaTD);
			case 130:
			{
				TextDrawSetString(PUBGAreaTD, "Restricting area in 4 minutes");
				foreach(new i: PUBGPlayers) TextDrawShowForPlayer(i, PUBGAreaTD);
			}
			case 135: foreach(new i: PUBGPlayers) TextDrawHideForPlayer(i, PUBGAreaTD);
			case 190:
			{
				TextDrawSetString(PUBGAreaTD, "Restricting area in 3 minutes");
				foreach(new i: PUBGPlayers) TextDrawShowForPlayer(i, PUBGAreaTD);
			}
			case 195: foreach(new i: PUBGPlayers) TextDrawHideForPlayer(i, PUBGAreaTD);
			case 250:
			{
				TextDrawSetString(PUBGAreaTD, "Restricting area in 2 minutes");
				foreach(new i: PUBGPlayers) TextDrawShowForPlayer(i, PUBGAreaTD);
			}
			case 255: foreach(new i: PUBGPlayers) TextDrawHideForPlayer(i, PUBGAreaTD);
			case 310:
			{
				TextDrawSetString(PUBGAreaTD, "Restricting area in 1 minute");
				foreach(new i: PUBGPlayers) TextDrawShowForPlayer(i, PUBGAreaTD);
			}
			case 315: foreach(new i: PUBGPlayers) TextDrawHideForPlayer(i, PUBGAreaTD);
			case 360:
			{
				TextDrawSetString(PUBGAreaTD, "Restricting area in 10 seconds");
				foreach(new i: PUBGPlayers) TextDrawShowForPlayer(i, PUBGAreaTD);
			}
			case 365: foreach(new i: PUBGPlayers) TextDrawHideForPlayer(i, PUBGAreaTD);
			case 370:
			{
				Multiplier = 10.0;
				TextDrawSetString(PUBGAreaTD, "Intoxicating..");
				Intoxicate(100.00);
				foreach(new i: PUBGPlayers) TextDrawShowForPlayer(i, PUBGAreaTD);
			}
			case 375: foreach(new i: PUBGPlayers) TextDrawHideForPlayer(i, PUBGAreaTD);
			case 380:
			{
				TextDrawSetString(PUBGAreaTD, "Restricting area in 5 minutes");
				foreach(new i: PUBGPlayers) TextDrawShowForPlayer(i, PUBGAreaTD);
			}
			case 385: foreach(new i: PUBGPlayers) TextDrawHideForPlayer(i, PUBGAreaTD);
			case 440:
			{
				TextDrawSetString(PUBGAreaTD, "Restricting area in 4 minutes");
				foreach(new i: PUBGPlayers) TextDrawShowForPlayer(i, PUBGAreaTD);
			}
			case 445: foreach(new i: PUBGPlayers) TextDrawHideForPlayer(i, PUBGAreaTD);
			case 500:
			{
				TextDrawSetString(PUBGAreaTD, "Restricting area in 3 minutes");
				foreach(new i: PUBGPlayers) TextDrawShowForPlayer(i, PUBGAreaTD);
			}
			case 505: foreach(new i: PUBGPlayers) TextDrawHideForPlayer(i, PUBGAreaTD);
			case 560:
			{
				TextDrawSetString(PUBGAreaTD, "Restricting area in 2 minutes");
				foreach(new i: PUBGPlayers) TextDrawShowForPlayer(i, PUBGAreaTD);
			}
			case 565: foreach(new i: PUBGPlayers) TextDrawHideForPlayer(i, PUBGAreaTD);
			case 620:
			{
				TextDrawSetString(PUBGAreaTD, "Restricting area in 1 minute");
				foreach(new i: PUBGPlayers) TextDrawShowForPlayer(i, PUBGAreaTD);
			}
			case 625: foreach(new i: PUBGPlayers) TextDrawHideForPlayer(i, PUBGAreaTD);
			case 670:
			{
				TextDrawSetString(PUBGAreaTD, "Restricting area in 10 seconds");
				foreach(new i: PUBGPlayers) TextDrawShowForPlayer(i, PUBGAreaTD);
			}
			case 675: foreach(new i: PUBGPlayers) TextDrawHideForPlayer(i, PUBGAreaTD);
			case 680:
			{
				Multiplier = 15.0;
				TextDrawSetString(PUBGAreaTD, "Intoxicating...");
				Intoxicate(700.00);
				foreach(new i: PUBGPlayers) TextDrawShowForPlayer(i, PUBGAreaTD);
			}
			case 685: foreach(new i: PUBGPlayers) TextDrawHideForPlayer(i, PUBGAreaTD);
		}
		SetTimer("UpdatePUBG", 1000, false);
	}    
	return 1;
}

Intoxicate(Float:meters)  {
	PUBGMeters = meters;
	SetTimer("ExecuteToxication", 500, 0);
	return 1;
}

hook OnPlayerSpawn(playerid) {
	if (Iter_Contains(PUBGPlayers, playerid)) {
		Iter_Remove(PUBGPlayers, playerid);
	}
	TextDrawHideForPlayer(playerid, PUBGAreaTD);
	TextDrawHideForPlayer(playerid, PUBGAliveTD);
	TextDrawHideForPlayer(playerid, PUBGKillTD);
	TextDrawHideForPlayer(playerid, PUBGKillsTD);
	return 1;
}

hook OnPlayerDisconnect(playerid, reason) {
	if (PUBGStarted) {
		if (Iter_Contains(PUBGPlayers, playerid)) {
			TextDrawHideForPlayer(playerid, PUBGKillsTD);

			new msg[128];

			format(msg, sizeof(msg), "%d Kills", PUBGKills ++);
			TextDrawSetString(PUBGKillsTD, msg);

			Iter_Remove(PUBGPlayers, playerid);
			TextDrawHideForPlayer(playerid, PUBGAreaTD);
			TextDrawHideForPlayer(playerid, PUBGAliveTD);
			TextDrawHideForPlayer(playerid, PUBGKillTD);
			if (Iter_Count(PUBGPlayers) == 1) {
				new winner = Iter_Random(PUBGPlayers);
				TextDrawHideForPlayer(winner, PUBGKillsTD);
				TextDrawHideForPlayer(winner, PUBGKillTD);
				Text_Send(@pVerified, $CHICKEN_DINNER, PlayerInfo[winner][PlayerName]);
				PlayerInfo[winner][pPUBGEventsWon] ++;
				PlayerInfo[winner][pEXPEarned] += 50;
				GivePlayerScore(winner, 100);
				GivePlayerCash(winner, 500000);
				Iter_Clear(PUBGPlayers);
				PUBGStarted = false;
				SetPlayerHealth(winner, 0);
				PlayerPlaySound(winner, 1095, 0.0, 0.0, 0.0);
				TextDrawHideForPlayer(winner, PUBGAreaTD);
				TextDrawHideForPlayer(winner, PUBGAliveTD);
				GameTextForPlayer(winner, "~g~WINNER WINNER CHICKEN DINNER!", 3000, 3);
				TextDrawSetString(PUBGWinnerTD[1], PlayerInfo[winner][PlayerName]);
				new str[128];
				format(str, sizeof(str), "~w~KILLS: ~g~%d            ~w~REWARD: ~g~$500000 & 100 Score", PUBGKills);
				TextDrawSetString(PUBGWinnerTD[3], str);
				for (new i = 0; i < sizeof(PUBGWinnerTD); i++) {
					TextDrawShowForAll(PUBGWinnerTD[i]);
				}
				SetTimer("HidePUBGWinner", 3000, false);
			}
			else if (!Iter_Count(PUBGPlayers)) {
				PUBGStarted = false;
				Text_Send(@pVerified, $SERVER_28x);
				HidePUBGWinner();
			}
		}
	}
	
	if (Iter_Contains(PUBGPlayers, playerid)) {
		Iter_Remove(PUBGPlayers, playerid);
	}
	return 1;
}

hook OnPlayerDeath(playerid, killerid, reason) {
	if (PUBGStarted) {
		if (Iter_Contains(PUBGPlayers, playerid)) {
			TextDrawHideForPlayer(playerid, PUBGKillsTD);

			new msg[128];
			if (killerid != INVALID_PLAYER_ID) {
				format(msg, sizeof(msg), "~g~~h~%s ~w~killed ~r~~h~%s~w~ with ~b~~h~%s", PlayerInfo[playerid][PlayerName], PlayerInfo[killerid][PlayerName], ReturnWeaponName(GetPlayerWeapon(killerid)));
			} else format(msg, sizeof(msg), "~r~~h~%s ~w~ was eliminated", PlayerInfo[playerid][PlayerName]);
			
			TextDrawSetString(PUBGKillTD, msg);
			
			format(msg, sizeof(msg), "%d Kills", PUBGKills ++);
			TextDrawSetString(PUBGKillsTD, msg);
			foreach(new i: PUBGPlayers) TextDrawShowForPlayer(i, PUBGKillsTD);
			
			if (killerid != INVALID_PLAYER_ID) {
				PlayerTextDrawSetString(killerid, PUBGBonusTD[killerid], "~g~~h~~h~+2 Score & $10000");
				PlayerTextDrawShow(killerid, PUBGBonusTD[killerid]);
				SetTimerEx("HideBonus", 3000, false, "i", killerid);
			}

			Iter_Remove(PUBGPlayers, playerid);
			TextDrawHideForPlayer(playerid, PUBGAreaTD);
			TextDrawHideForPlayer(playerid, PUBGAliveTD);
			TextDrawHideForPlayer(playerid, PUBGKillTD);
			if (Iter_Count(PUBGPlayers) == 1) {
				new winner = Iter_Random(PUBGPlayers);
				TextDrawHideForPlayer(winner, PUBGKillsTD);
				TextDrawHideForPlayer(winner, PUBGKillTD);
				PlayerInfo[winner][pPUBGEventsWon] ++;
				PlayerPlaySound(winner, 1095, 0.0, 0.0, 0.0);
				Text_Send(@pVerified, $CHICKEN_DINNER, PlayerInfo[winner][PlayerName]);
				PlayerInfo[winner][pEXPEarned] += 50;
				GivePlayerScore(winner, 100);
				GivePlayerCash(winner, 500000);
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
				for (new i = 0; i < sizeof(PUBGWinnerTD); i++) {
					TextDrawShowForAll(PUBGWinnerTD[i]);
				}
				SetTimer("HidePUBGWinner", 3000, false);
			}
			else if (!Iter_Count(PUBGPlayers)) {
				PUBGStarted = false;
				Text_Send(@pVerified, $SERVER_28x);
				HidePUBGWinner();
			}
		}
	}
	
	if (Iter_Contains(PUBGPlayers, playerid)) {
		Iter_Remove(PUBGPlayers, playerid);
		TextDrawHideForPlayer(playerid, PUBGAreaTD);
		TextDrawHideForPlayer(playerid, PUBGAliveTD);
		TextDrawHideForPlayer(playerid, PUBGKillTD);
		TextDrawHideForPlayer(playerid, PUBGKillsTD);
	}
	return 1;
}

//Commands

CMD:pubg(playerid) {
	if (GetPlayerVirtualWorld(playerid) || GetPlayerInterior(playerid)) return Text_Send(playerid, $CLIENT_466x);
	if (IsPlayerInAnyVehicle(playerid)) return Text_Send(playerid, $CLIENT_467x);
	if (pDuelInfo[playerid][pDInMatch] == 1) return Text_Send(playerid, $COMMAND_INDUEL);
	if (PlayerInfo[playerid][pDeathmatchId] > -1) return Text_Send(playerid, $COMMAND_INDM);
	if (Iter_Contains(ePlayers, playerid)) return Text_Send(playerid, $CLIENT_468x);
	if (Iter_Contains(CWCLAN1, playerid) || Iter_Contains(CWCLAN2, playerid)) return Text_Send(playerid, $COMMAND_INCW);
	if (!PUBGOpened) return Text_Send(playerid, $CLIENT_469x);
	if (Iter_Contains(PUBGPlayers, playerid)) return Text_Send(playerid, $CLIENT_470x);
	SetPlayerInterior(playerid, 0);
	SetPlayerPos(playerid, -2304.3433,-1608.0492,483.9337);
	SetPlayerFacingAngle(playerid, 188.4081);
	SetPlayerVirtualWorld(playerid, PUBG_WORLD);
	ResetPlayerWeapons(playerid);
	ResetPlayerItems(playerid);
	
	SetPlayerArmour(playerid, 0);
	SetPlayerHealth(playerid, 100);
	SetPlayerColor(playerid, 0xFFFFFF00);
	TextDrawShowForPlayer(playerid, PUBGAliveTD);
	TextDrawShowForPlayer(playerid, PUBGKillsTD);
	Iter_Add(PUBGPlayers, playerid);    
	return 1;
}

CMD:pubgers(playerid) {
	new sub_holder[27], string[256], count = 0;
	if (!PUBGStarted) return Text_Send(playerid, $CLIENT_471x);

	foreach(new i: Player) {
		if (Iter_Contains(PUBGPlayers, i)) {
			format(sub_holder, sizeof(sub_holder), "%s\n", PlayerInfo[i][PlayerName]);
			strcat(string, sub_holder);

			count = 1;
		}
	}

	if (count) {
		Dialog_Show(playerid, DIALOG_STYLE_TABLIST, "PUBG Players", string, "X", "");
	}  else Text_Send(playerid, $CLIENT_423x);
	return 1;
}

//End of File
/* (c) H2O Multiplayer 2018-2020. All rights reserved. */