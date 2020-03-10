/*
	SWAT vs Terrorists is a team death-match SA-MP game-mode script. 
	Compatible with SA-MP 0.3.7 and later releases.

	Author: H2O
	Licensed under GNU GPLv3

	(c) 2018-2020 H2O Multiplayer. All rights reserved.
	Website: h2omultiplayer.com

	Create a module for the crates system
*/

#include <YSI\y_hooks>
#include <YSI\y_text>
loadtext mode_text[all], mode_text[client], mode_text[newcs], mode_text[dialogs], mode_text[gametexts];

forward DestroyCrate(crateid);
public DestroyCrate(crateid) {
	DestroyDynamicObject(crateid);
	return 1;
}

forward OpenCrate(playerid);
public OpenCrate(playerid) {
	new random_obj = random(4);
	PlayerInfo[playerid][pCrates] --;
	switch (random_obj) {
		case 0: {
			new random_cash = random(10000) + 500;
			GivePlayerCash(playerid, random_cash);

			new string[9];
			format(string, sizeof(string), "$%d", random_cash);
			Text_Send(playerid, $CRATE_OPEN, string);
		}
		case 1: {
			new random_score = random(10) + 1;
			GivePlayerScore(playerid, random_score);

			new string[9];
			format(string, sizeof(string), "%d score", random_score);
			Text_Send(playerid, $CRATE_OPEN, string);
		}
		case 2: {
			new random_weap = random(3);
			switch (random_weap) {
				case 0: {
					GivePlayerWeapon(playerid, 24, 50);
					Text_Send(playerid, $CRATE_OPEN, "a desert eagle");
				}
				case 1: {
					GivePlayerWeapon(playerid, WEAPON_TEC9, 100);
					Text_Send(playerid, $CRATE_OPEN, "a Tec-9");
				}
				case 2: {
					GivePlayerWeapon(playerid, WEAPON_SAWEDOFF, 100);
					Text_Send(playerid, $CRATE_OPEN, "a sawn-off shotgun");
				}								
			}
		}
		case 3: {
			new random_item = random(MAX_ITEMS);
			pItems[playerid][random_item] ++;
			Text_Send(playerid, $CRATE_OPEN, ItemsInfo[random_item][Item_Name]);	
		}			
	}    
	return 1;
}

//Hook this thing

hook OnPlayerDisconnect(playerid, reason) {
	KillTimer(CrateTimer[playerid]);
	return 1;
}

//Commands

CMD:opencrate(playerid) {
	if (pDuelInfo[playerid][pDInMatch] == 1) return Text_Send(playerid, $COMMAND_INDUEL);
	if (PlayerInfo[playerid][pDeathmatchId] > -1) return Text_Send(playerid, $COMMAND_INDM);
	if (Iter_Contains(ePlayers, playerid)) return Text_Send(playerid, $COMMAND_INEVENT);
	if (Iter_Contains(CWCLAN1, playerid) || Iter_Contains(CWCLAN2, playerid)) return Text_Send(playerid, $COMMAND_INCW);
	if (!IsPlayerSpawned(playerid)) return Text_Send(playerid, $COMMAND_NOTSPAWNED);
	if (PlayerInfo[playerid][pAdminDuty]) return Text_Send(playerid, $COMMAND_ADMINDUTY);
	if (Iter_Contains(PUBGPlayers, playerid)) return Text_Send(playerid, $COMMAND_INPUBG);
	if (!PlayerInfo[playerid][pCrates]) return Text_Send(playerid, $CLIENT_335x);
	if (PlayerInfo[playerid][pDonorLevel]) {
		KillTimer(CrateTimer[playerid]);
		OpenCrate(playerid);
		Text_Send(playerid, $OPENING_CRATE);
		PlayerPlaySound(playerid, 1068, 0.0, 0.0, 0.0);
		AnimPlayer(playerid, "ROB_BANK", "CAT_Safe_Open", 8.0, 0, 0, 0, 0, 0);

		new Float: X, Float: Y, Float: Z;
		GetXYZInfrontOfPlayer(playerid, X, Y, 0.7);
		CA_FindZ_For2DCoord(X, Y, Z);

		new crate = CreateDynamicObject(3014, X, Y, Z, 0.0, 0.0, 0.0);
		SetTimerEx("DestroyCrate", 5000, false, "i", crate);
	} else {
		KillTimer(CrateTimer[playerid]);
		CrateTimer[playerid] = SetTimerEx("OpenCrate", 5000, false, "i", playerid);
		Text_Send(playerid, $OPENING_CRATE);
		PlayerPlaySound(playerid, 1068, 0.0, 0.0, 0.0);
		AnimPlayer(playerid, "ROB_BANK", "CAT_Safe_Open", 8.0, 0, 0, 0, 0, 0);

		new Float: X, Float: Y, Float: Z;
		GetXYZInfrontOfPlayer(playerid, X, Y, 0.7);
		CA_FindZ_For2DCoord(X, Y, Z);

		new crate = CreateDynamicObject(3014, X, Y, Z, 0.0, 0.0, 0.0);
		SetTimerEx("DestroyCrate", 5000, false, "i", crate);
	}    
	return 1;
}

//End of File
/* (c) H2O Multiplayer 2018-2020. All rights reserved. */