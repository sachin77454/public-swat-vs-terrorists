/*
	SWAT vs Terrorists is a team death-match SA-MP game-mode script. 
	Compatible with SA-MP 0.3.7 and later releases.

	Author: H2O
	Licensed under GNU GPLv3

	(c) 2018-2020 H2O Multiplayer. All rights reserved.
	Website: h2omultiplayer.com

	Deathmatch system
*/

#include <YSI_Coding\y_hooks>

//Support for y_text, load language files...
#include <YSI_Players\y_text> //Y_Less
loadtext mode_text[all], mode_text[client], mode_text[newcs], mode_text[dialogs], mode_text[gametexts];

//Deathmatch

forward HideDMText(playerid);
public HideDMText(playerid) {
	DMTimer[playerid] = -1;
	TextDrawHideForPlayer(playerid, DMBox);
	TextDrawHideForPlayer(playerid, DMText);
	TextDrawHideForPlayer(playerid, DMText2[0]);
	TextDrawHideForPlayer(playerid, DMText2[1]);
	TextDrawHideForPlayer(playerid, DMText2[2]);
	TextDrawHideForPlayer(playerid, DMText2[3]);
	return 1;
}

ShowDMText(playerid) {
	TextDrawShowForPlayer(playerid, DMBox);
	TextDrawShowForPlayer(playerid, DMText);

	new dmstring[180], top[MAX_PLAYERS][2], topcount = 1;

	foreach(new p: Player) {
		top[p][0] = pDMKills[p][PlayerInfo[playerid][pDeathmatchId]];
		top[p][1] = p;

		topcount ++;  
	}

	QuickSort_Pair(top, true, 0, topcount);

	for (new i = 0; i < topcount; i++) {
		if (i < 5) {
			if (top[i][0]) {
				format(dmstring, sizeof(dmstring), "%s%d. %s - K: %d~n~", dmstring, i + 1, PlayerInfo[top[i][1]][PlayerName], top[i][0]);
			}
		} else {
			break;
		}
	}

	if (isnull(dmstring)) {
		format(dmstring, sizeof(dmstring), "There is no top DMer.");
	}

	TextDrawSetString(DMText2[3], dmstring);
	TextDrawShowForPlayer(playerid, DMText2[0]);
	TextDrawShowForPlayer(playerid, DMText2[1]);
	TextDrawShowForPlayer(playerid, DMText2[2]);
	TextDrawShowForPlayer(playerid, DMText2[3]);
	
	DMTimer[playerid] = SetTimerEx("HideDMText", 3000, false, "i", playerid);
	return 1;
}

SetupDeathmatch(playerid) {
	ShowDMText(playerid);
	SetPlayerColor(playerid, 0xECECECFF);

	if (PlayerInfo[playerid][pDeathmatchId] != 7) {
		Text_Send(playerid, $CLIENT_173x);
		SetPlayerChatBubble(playerid, "*Immune*", X11_RED2, 150.0, 4000);
		SetPlayerAttachedObject(playerid, 8, 18729, 1, 0.87, -0.04, 1.62, -174.00, 0.00, 0.00, 1.00, 1.00, 1.00);
		AntiSKStart[playerid] = gettime() + 3;
		AntiSK[playerid] = 1;
	}

	SetPlayerSkin(playerid, DMInfo[PlayerInfo[playerid][pDeathmatchId]][DM_SKIN]);

	SetPlayerHealth(playerid, DMInfo[PlayerInfo[playerid][pDeathmatchId]][DM_HP]);
	SetPlayerArmour(playerid, DMInfo[PlayerInfo[playerid][pDeathmatchId]][DM_AR]);

	SetPlayerInterior(playerid, DMInfo[PlayerInfo[playerid][pDeathmatchId]][DM_INT]);
	SetPlayerVirtualWorld(playerid, DM_WORLD);

	GivePlayerWeapon(playerid, DMInfo[PlayerInfo[playerid][pDeathmatchId]][DM_WEAP_1][0], DMInfo[PlayerInfo[playerid][pDeathmatchId]][DM_WEAP_1][1]);
	GivePlayerWeapon(playerid, DMInfo[PlayerInfo[playerid][pDeathmatchId]][DM_WEAP_2][0], DMInfo[PlayerInfo[playerid][pDeathmatchId]][DM_WEAP_2][1]);
	GivePlayerWeapon(playerid, DMInfo[PlayerInfo[playerid][pDeathmatchId]][DM_WEAP_3][0], DMInfo[PlayerInfo[playerid][pDeathmatchId]][DM_WEAP_3][1]);
	GivePlayerWeapon(playerid, DMInfo[PlayerInfo[playerid][pDeathmatchId]][DM_WEAP_4][0], DMInfo[PlayerInfo[playerid][pDeathmatchId]][DM_WEAP_4][1]);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_SAWNOFF_SHOTGUN, 1000);
	SetPlayerSkin(playerid, DMInfo[PlayerInfo[playerid][pDeathmatchId]][DM_SKIN]);

	new i = random(3);

	switch (i) {
		case 0:
		{
			SetPlayerPos(playerid, DMInfo[PlayerInfo[playerid][pDeathmatchId]][DM_SPAWN_1][0], DMInfo[PlayerInfo[playerid][pDeathmatchId]][DM_SPAWN_1][1], DMInfo[PlayerInfo[playerid][pDeathmatchId]][DM_SPAWN_1][2]);
			SetPlayerFacingAngle(playerid, DMInfo[PlayerInfo[playerid][pDeathmatchId]][DM_SPAWN_1][3]);
		}
		case 1:
		{
			SetPlayerPos(playerid, DMInfo[PlayerInfo[playerid][pDeathmatchId]][DM_SPAWN_2][0], DMInfo[PlayerInfo[playerid][pDeathmatchId]][DM_SPAWN_2][1], DMInfo[PlayerInfo[playerid][pDeathmatchId]][DM_SPAWN_2][2]);
			SetPlayerFacingAngle(playerid, DMInfo[PlayerInfo[playerid][pDeathmatchId]][DM_SPAWN_2][3]);
		}
		case 2:
		{
			SetPlayerPos(playerid, DMInfo[PlayerInfo[playerid][pDeathmatchId]][DM_SPAWN_3][0], DMInfo[PlayerInfo[playerid][pDeathmatchId]][DM_SPAWN_3][1], DMInfo[PlayerInfo[playerid][pDeathmatchId]][DM_SPAWN_3][2]);
			SetPlayerFacingAngle(playerid, DMInfo[PlayerInfo[playerid][pDeathmatchId]][DM_SPAWN_3][3]);	
		}
	}

	UpdateLabelText(playerid);
	KillTimer(DelayerTimer[playerid]);
	DelayerTimer[playerid] = SetTimerEx("InitPlayer", GetPlayerPing(playerid) + 100, false, "i", playerid);
	TogglePlayerControllable(playerid, false);	
	return 1;
}

//Deathmatch Commands

CMD:ww(playerid) {
	return PC_EmulateCommand(playerid, "/dm ww");
}

CMD:rw(playerid) {
	return PC_EmulateCommand(playerid, "/dm rw");
}

CMD:sdm(playerid) {
	return PC_EmulateCommand(playerid, "/dm sdm");
}

CMD:mg(playerid) {
	return PC_EmulateCommand(playerid, "/dm mg");
}

CMD:rc(playerid) {
	return PC_EmulateCommand(playerid, "/dm rc");
}

CMD:ft(playerid) {
	return PC_EmulateCommand(playerid, "/dm ft");
}

CMD:rl(playerid) {
	return PC_EmulateCommand(playerid, "/dm rl");
}

CMD:tw(playerid) {
	return PC_EmulateCommand(playerid, "/dm tw");
}

CMD:bdm(playerid) {
	return PC_EmulateCommand(playerid, "/dm bdm");
}

CMD:dm(playerid, params[]) {
	if (GetPlayerState(playerid) != PLAYER_STATE_ONFOOT || pDuelInfo[playerid][pDInMatch] == 1) return Text_Send(playerid, $CLIENT_495x);
	if (PlayerInfo[playerid][pAdminDuty] == 1) return Text_Send(playerid, $CLIENT_436x);
	if (PlayerInfo[playerid][pDeathmatchId] >= 0) return Text_Send(playerid, $CLIENT_436x);
	if (Iter_Contains(ePlayers, playerid) || Iter_Contains(PUBGPlayers, playerid)) return Text_Send(playerid, $CLIENT_436x);
	if (PlayerInfo[playerid][pLastHitTick] > gettime()) return Text_Send(playerid, $JUSTHIT, PlayerInfo[playerid][pLastHitTick] - gettime());

	if (isnull(params)) {
		new
				string[110],
				dialogstr[470]
		;

		format(string, sizeof(string), "Shortcut\tArea\tPlayers\n");
		strcat(dialogstr, string);

		for (new i = 0; i < sizeof(DMInfo); i++) {
			new count = 0;

			foreach (new x: Player) {
				if (PlayerInfo[x][pDeathmatchId] == i) {
					count++;
				}
			}

			format(string, sizeof(string), "{0000FF}[%s]\t{FF0000}%s\t%d\n", DMInfo[i][DM_SHORTCUT], DMInfo[i][DM_NAME], count);
			strcat(dialogstr, string);
		}

		inline DMList(pid, dialogid, response, listitem, string:inputtext[]) {
			#pragma unused dialogid, inputtext
			if (!response) return 1;
			
			PlayerInfo[pid][pDeathmatchId] = listitem;

			new dm_count = 0;

			foreach (new i: Player) {
				if (i != pid) {
					if (PlayerInfo[pid][pDeathmatchId] == PlayerInfo[i][pDeathmatchId]) {
						dm_count ++;
					}
				}
			}

			Text_Send(@pVerified, $SERVER_70x, PlayerInfo[pid][PlayerName], DMInfo[PlayerInfo[pid][pDeathmatchId]][DM_NAME], DMInfo[PlayerInfo[pid][pDeathmatchId]][DM_SHORTCUT], dm_count + 1);
			SpawnPlayer(pid);
		}

		Dialog_ShowCallback(playerid, using inline DMList, DIALOG_STYLE_TABLIST_HEADERS, ""RED2"SvT - Deathmatch", dialogstr, ">>", "<<");
	} else {
		for (new i = 0; i < sizeof(DMInfo); i++) {
			new alt_sct[9];
			format(alt_sct, sizeof(alt_sct), "[%s]", DMInfo[i][DM_SHORTCUT]);
			
			if (!strcmp(params, DMInfo[i][DM_SHORTCUT], true) || !strcmp(params, alt_sct, true)) {
				PlayerInfo[playerid][pDeathmatchId] = i;

				new dm_count = 0;

				foreach (new x: Player) {
					if (x != playerid) {
						if (PlayerInfo[playerid][pDeathmatchId] == PlayerInfo[x][pDeathmatchId]) {
							dm_count ++;
						}
					}
				}

				Text_Send(@pVerified, $SERVER_70x, PlayerInfo[playerid][PlayerName], DMInfo[PlayerInfo[playerid][pDeathmatchId]][DM_NAME], DMInfo[PlayerInfo[playerid][pDeathmatchId]][DM_SHORTCUT], dm_count + 1);
				SpawnPlayer(playerid);
			}
		}
	}

	Text_Send(playerid, $CLIENT_496x);    
	return 1;
}

CMD:qdm(playerid) {
	if (PlayerInfo[playerid][pDeathmatchId] >= 0 && pDuelInfo[playerid][pDInMatch] == 0) {
		pDMKills[playerid][PlayerInfo[playerid][pDeathmatchId]] = 0;
		PlayerInfo[playerid][pDeathmatchId] = -1;

		SetPlayerHealth(playerid, 0.0);
	}  else Text_Send(playerid, $CLIENT_497x);    
	return 1;
}

CMD:dmers(playerid) {
	new sub_holder[27], string[256], count = 0;

	foreach (new i: Player) {
		if (PlayerInfo[i][pDeathmatchId] >= 0) {
			format(sub_holder, sizeof(sub_holder), "%s\t%s\n", PlayerInfo[i][PlayerName], DMInfo[PlayerInfo[i][pDeathmatchId]][DM_NAME]);
			strcat(string, sub_holder);

			count = 1;
		}
	}

	if (count) {
		Dialog_Show(playerid, DIALOG_STYLE_TABLIST, "DM Players", string, "X", "");
	}  else Text_Send(playerid, $CLIENT_423x);
	return 1;
}

//End of File
/* (c) H2O Multiplayer 2018-2020. All rights reserved. */