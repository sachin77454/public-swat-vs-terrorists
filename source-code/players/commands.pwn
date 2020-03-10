/*
	SWAT vs Terrorists is a team death-match SA-MP game-mode script.
	Compatible with SA-MP 0.3.7 and later releases.

	Author: H2O
	Licensed under GNU GPLv3

	(c) 2018-2020 H2O Multiplayer. All rights reserved.
	Website: h2omultiplayer.com

	Commands Module
*/

#include <YSI\y_hooks>
#include <YSI_Players\y_text> //Y_Less
loadtext mode_text[all], mode_text[client], mode_text[newcs], mode_text[dialogs], mode_text[gametexts];

//Commands

public OnPlayerCommandReceived(playerid, cmd[], params[], flags) {
	if (!PlayerInfo[playerid][pLoggedIn]) return Kick(playerid);

	if (!IsPlayerSpawned(playerid)) {
		if (GetPlayerState(playerid) != PLAYER_STATE_SPECTATING) {
			return 0;
		}
	}

	if (IsPlayerDying(playerid)) {
		Text_Send(playerid, $CLIENT_315x);
		return 0;
	}

	if (PlayerInfo[playerid][pJailed] && !PlayerInfo[playerid][pAdminLevel]) {
		Text_Send(playerid, $CLIENT_316x);
		return 0;
	}

	if (AntiSK[playerid]) {
		EndProtection(playerid);
	}

	if (flags & CMD_ADMIN) {
		new authorized_access = 0;

		for (new i = 0; i < sizeof(ACmds); i++) {
			if (!strcmp(ACmds[i][Adm_Command], cmd, true)) {
				if (PlayerInfo[playerid][pAdminLevel] >= ACmds[i][Adm_Level]) {
					authorized_access = 1;
				}
			}
		}

		if (flags & CMD_MOD) {
			if (PlayerInfo[playerid][pIsModerator]) {
				authorized_access = 1;
			}
		}

		if (!authorized_access) {
			printf("Player %s[%d] attempted to use %s without permission (params %s)",
				PlayerInfo[playerid][PlayerName], playerid, cmd, params);
			PlayerInfo[playerid][pUnauthorizedActions] ++;
			return 0;
		}

		SendAdminCommand(playerid, cmd, params);
		printf("[ACMD] %s[%d]: %s %s", PlayerInfo[playerid][PlayerName], playerid, cmd, params);

		new query[200];
		format(query, sizeof(query), "Used command /%s, params: %s", cmd, params);
		LogAdminAction(playerid, query);
	}

	new String[40 + MAX_PLAYER_NAME];

	if (svtconf[read_player_cmds]) {
		if (PlayerInfo[playerid][pAdminLevel] < svtconf[max_admin_level]) {
			if (flags & CMD_SECRET) {
				print(String);
			} else {
				if (flags != CMD_ADMIN) {
					format(String, sizeof(String), "*%s (%d) used: %s %s", PlayerInfo[playerid][PlayerName], playerid, cmd, params);
					MessageToAdminsEx2(X11_GRAY, String);
					print(String);
				}
			}
		} else {
			format(String, sizeof(String), "*%s (%d) used: %s %s", PlayerInfo[playerid][PlayerName], playerid, cmd, params);
			print(String);
		}
	}
	return 1;
}

public OnPlayerCommandPerformed(playerid, cmd[], params[], result, flags) {
	if (result == -1) {
		PlayerInfo[playerid][pCommandsFailed] ++;
		//return NotifyPlayer(playerid, "~w~Command failed. For more information, check out /cmds and /help!");
	}
	PlayerInfo[playerid][pCommandsUsed] ++; 
	return 1;
}

//All Commands

//Top Players

CMD:top(playerid) {
	inline TopPlayersMenu(pid, dialogid, response, listitem, string:inputtext[]) {
		#pragma unused dialogid, inputtext
		if (!response) return 1;
		switch (listitem) { 
			case 0: {
				new Cache: topResult;
				topResult = mysql_query(Database, "SELECT d1.`Username`, d2.`pID`, d2.`Kills` FROM `Players` AS d1, `PlayersData` AS d2 WHERE d1.`ID` = d2.`pID` ORDER BY d2.`Kills` DESC LIMIT 10");
				if (cache_num_rows()) {
					for (new i = 0; i < cache_num_rows(); i++) {
						new playerName[MAX_PLAYER_NAME], pID, Kills;
						cache_get_value_int(i, "pID", pID);
						cache_get_value(i, "Username", playerName);
						cache_get_value_int(i, "Kills", Kills);

						Text_Send(pid, $NEWCLIENT_33x, playerName, i + 1, Kills);
					}	
				} else Text_Send(pid, $CLIENT_423x);
				cache_delete(topResult);
			}
			case 1: {
				new Cache: topResult;
				topResult = mysql_query(Database, "SELECT d1.`Username`, d2.`pID`, d2.`Deaths` FROM `Players` AS d1, `PlayersData` AS d2 WHERE d1.`ID` = d2.`pID` ORDER BY d2.`Deaths` DESC LIMIT 10");
				if (cache_num_rows()) {
					for (new i = 0; i < cache_num_rows(); i++) {
						new playerName[MAX_PLAYER_NAME], pID, Deaths;
						cache_get_value_int(i, "pID", pID);
						cache_get_value(i, "Username", playerName);
						cache_get_value_int(i, "Deaths", Deaths);

						Text_Send(pid, $NEWCLIENT_34x, playerName, i + 1, Deaths);
					}
				} else Text_Send(pid, $CLIENT_423x);
				cache_delete(topResult);
			}
			case 2: {
				new Cache: topResult;
				topResult = mysql_query(Database, "SELECT d1.`Username`, d2.`pID`, d2.`Headshots` FROM `Players` AS d1, `PlayersData` AS d2 WHERE d1.`ID` = d2.`pID` ORDER BY d2.`Headshots` DESC LIMIT 10");
				if (cache_num_rows()) {
					for (new i = 0; i < cache_num_rows(); i++) {
						new playerName[MAX_PLAYER_NAME], pID, Headshots;
						cache_get_value_int(i, "pID", pID);
						cache_get_value(i, "Username", playerName);
						cache_get_value_int(i, "Headshots", Headshots);

						Text_Send(pid, $NEWCLIENT_35x, playerName, i + 1, Headshots);
					}
				} else Text_Send(pid, $CLIENT_423x);
				cache_delete(topResult);
			}
			case 3: {
				new Cache: topResult;
				topResult = mysql_query(Database, "SELECT d1.`Username`, d2.`pID`, d2.`DeathmatchKills` FROM `Players` AS d1, `PlayersData` AS d2 WHERE d1.`ID` = d2.`pID` ORDER BY d2.`DeathmatchKills` DESC LIMIT 10");
				if (cache_num_rows()) {
					for (new i = 0; i < cache_num_rows(); i++) {
						new playerName[MAX_PLAYER_NAME], pID, DeathmatchKills;
						cache_get_value_int(i, "pID", pID);
						cache_get_value(i, "Username", playerName);
						cache_get_value_int(i, "DeathmatchKills", DeathmatchKills);

						Text_Send(pid, $NEWCLIENT_36x, playerName, i + 1, DeathmatchKills);
					}
				} else Text_Send(pid, $CLIENT_423x);
				cache_delete(topResult);
			}
			case 4: {
				new Cache: topResult;
				topResult = mysql_query(Database, "SELECT `Username`, `ID`, `PlayTime` FROM `Players` ORDER BY `PlayTime` DESC LIMIT 10");
				if (cache_num_rows()) {
					for (new i = 0; i < cache_num_rows(); i++) {
						new playerName[MAX_PLAYER_NAME], pID;
						cache_get_value_int(i, "ID", pID);
						cache_get_value(i, "Username", playerName);

						Text_Send(pid, $NEWCLIENT_37x, playerName, i + 1);
					}	
				} else Text_Send(pid, $CLIENT_423x);
				cache_delete(topResult);
			}
			case 5: {
				new Cache: topResult;
				topResult = mysql_query(Database, "SELECT d1.`Username`, d2.`pID`, d2.`ZonesCaptured` FROM `Players` AS d1, `PlayersData` AS d2 WHERE d1.`ID` = d2.`pID` ORDER BY d2.`ZonesCaptured` DESC LIMIT 10");
				if (cache_num_rows()) {
					for (new i = 0; i < cache_num_rows(); i++) {
						new playerName[MAX_PLAYER_NAME], pID, ZonesCaptured;
						cache_get_value_int(i, "pID", pID);
						cache_get_value(i, "Username", playerName);
						cache_get_value_int(i, "ZonesCaptured", ZonesCaptured);

						Text_Send(pid, $NEWCLIENT_38x, playerName, i + 1, ZonesCaptured);
					}	
				} else Text_Send(pid, $CLIENT_423x);
				cache_delete(topResult);
			}
			case 6: {
				new Cache: topResult;
				topResult = mysql_query(Database, "SELECT d1.`Username`, d2.`pID`, d2.`ClassAbilitiesUsed` FROM `Players` AS d1, `PlayersData` AS d2 WHERE d1.`ID` = d2.`pID` ORDER BY d2.`ClassAbilitiesUsed` DESC LIMIT 10");
				if (cache_num_rows()) {
					for (new i = 0; i < cache_num_rows(); i++) {
						new playerName[MAX_PLAYER_NAME], pID, ClassAbilitiesUsed;
						cache_get_value_int(i, "pID", pID);
						cache_get_value(i, "Username", playerName);
						cache_get_value_int(i, "ClassAbilitiesUsed", ClassAbilitiesUsed);

						Text_Send(pid, $NEWCLIENT_39x, playerName, i + 1, ClassAbilitiesUsed);
					}	
				} else Text_Send(pid, $CLIENT_423x);
				cache_delete(topResult);
			}
			case 7: {
				new Cache: topResult;
				topResult = mysql_query(Database, "SELECT d1.`Username`, d2.`pID`, d2.`DuelsWon` FROM `Players` AS d1, `PlayersData` AS d2 WHERE d1.`ID` = d2.`pID` ORDER BY d2.`DuelsWon` DESC LIMIT 10");
				if (cache_num_rows()) {
					for (new i = 0; i < cache_num_rows(); i++) {
						new playerName[MAX_PLAYER_NAME], pID, DuelsWon;
						cache_get_value_int(i, "pID", pID);
						cache_get_value(i, "Username", playerName);
						cache_get_value_int(i, "DuelsWon", DuelsWon);

						Text_Send(pid, $NEWCLIENT_40x, playerName, i + 1, DuelsWon);
					}	
				} else Text_Send(pid, $CLIENT_423x);
				cache_delete(topResult);
			}
			case 8: {
				new Cache: topResult;
				topResult = mysql_query(Database, "SELECT d1.`Username`, d2.`pID`, d2.`DuelsLost` FROM `Players` AS d1, `PlayersData` AS d2 WHERE d1.`ID` = d2.`pID` ORDER BY d2.`DuelsLost` DESC LIMIT 10");
				if (cache_num_rows()) {
					for (new i = 0; i < cache_num_rows(); i++) {
						new playerName[MAX_PLAYER_NAME], pID, DuelsLost;
						cache_get_value_int(i, "pID", pID);
						cache_get_value(i, "Username", playerName);
						cache_get_value_int(i, "DuelsLost", DuelsLost);

						Text_Send(pid, $NEWCLIENT_41x, playerName, i + 1, DuelsLost);
					}	
				} else Text_Send(pid, $CLIENT_423x);
				cache_delete(topResult);
			}
			case 9: {
				new Cache: topResult;
				topResult = mysql_query(Database, "SELECT d1.`Username`, d2.`pID`, d2.`Cash` FROM `Players` AS d1, `PlayersData` AS d2 WHERE d1.`ID` = d2.`pID` ORDER BY d2.`Cash` DESC LIMIT 10");
				if (cache_num_rows()) {
					for (new i = 0; i < cache_num_rows(); i++) {
						new playerName[MAX_PLAYER_NAME], pID, Cash;
						cache_get_value_int(i, "pID", pID);
						cache_get_value(i, "Username", playerName);
						cache_get_value_int(i, "Cash", Cash);

						Text_Send(pid, $NEWCLIENT_42x, playerName, i + 1, Cash);
					}	
				} else Text_Send(pid, $CLIENT_423x);
				cache_delete(topResult);
			}
			case 10: {
				new Cache: topResult;
				topResult = mysql_query(Database, "SELECT d1.`Username`, d2.`pID`, d2.`EXP` FROM `Players` AS d1, `PlayersData` AS d2 WHERE d1.`ID` = d2.`pID` ORDER BY d2.`EXP` DESC LIMIT 10");
				if (cache_num_rows()) {
					for (new i = 0; i < cache_num_rows(); i++) {
						new playerName[MAX_PLAYER_NAME], pID, EXP;
						cache_get_value_int(i, "pID", pID);
						cache_get_value(i, "Username", playerName);
						cache_get_value_int(i, "EXP", EXP);

						Text_Send(pid, $NEWCLIENT_43x, playerName, i + 1, EXP);
					}	
				} else Text_Send(pid, $CLIENT_423x);
				cache_delete(topResult);
			}
			case 11: {
				new Cache: topResult;
				topResult = mysql_query(Database, "SELECT d1.`Username`, d2.`pID`, d2.`Score` FROM `Players` AS d1, `PlayersData` AS d2 WHERE d1.`ID` = d2.`pID` ORDER BY d2.`Score` DESC LIMIT 10");
				if (cache_num_rows()) {
					for (new i = 0; i < cache_num_rows(); i++) {
						new playerName[MAX_PLAYER_NAME], pID, Score;
						cache_get_value_int(i, "pID", pID);
						cache_get_value(i, "Username", playerName);
						cache_get_value_int(i, "Score", Score);

						Text_Send(pid, $NEWCLIENT_44x, playerName, i + 1, Score);
					}	
				} else Text_Send(pid, $CLIENT_423x);
				cache_delete(topResult);
			}
			case 12: {
				new Cache: topResult;
				topResult = mysql_query(Database, "SELECT d1.`Username`, d2.`pID`, d2.`HighestKillStreak` FROM `Players` AS d1, `PlayersData` AS d2 WHERE d1.`ID` = d2.`pID` ORDER BY d2.`HighestKillStreak` DESC LIMIT 10");
				if (cache_num_rows()) {
					for (new i = 0; i < cache_num_rows(); i++) {
						new playerName[MAX_PLAYER_NAME], pID, HighestKillStreak;
						cache_get_value_int(i, "pID", pID);
						cache_get_value(i, "Username", playerName);
						cache_get_value_int(i, "HighestKillStreak", HighestKillStreak);

						Text_Send(pid, $NEWCLIENT_45x, playerName, i + 1, HighestKillStreak);
					}	
				} else Text_Send(pid, $CLIENT_423x);
				cache_delete(topResult);
			}
			case 13: {
				new Cache: topResult;
				topResult = mysql_query(Database, "SELECT d1.`Username`, d2.`pID`, d2.`HighestCaptures` FROM `Players` AS d1, `PlayersData` AS d2 WHERE d1.`ID` = d2.`pID` ORDER BY d2.`HighestCaptures` DESC LIMIT 10");
				if (cache_num_rows()) {
					for (new i = 0; i < cache_num_rows(); i++) {
						new playerName[MAX_PLAYER_NAME], pID, HighestCaptures;
						cache_get_value_int(i, "pID", pID);
						cache_get_value(i, "Username", playerName);
						cache_get_value_int(i, "HighestCaptures", HighestCaptures);

						Text_Send(pid, $NEWCLIENT_46x, playerName, i + 1, HighestCaptures);
					}	
				} else Text_Send(pid, $CLIENT_423x);
				cache_delete(topResult);
			}
			case 14: {
				new Cache: topResult;
				topResult = mysql_query(Database, "SELECT d1.`Username`, d2.`pID`, d2.`HighestKillAssists` FROM `Players` AS d1, `PlayersData` AS d2 WHERE d1.`ID` = d2.`pID` ORDER BY d2.`HighestKillAssists` DESC LIMIT 10");
				if (cache_num_rows()) {
					for (new i = 0; i < cache_num_rows(); i++) {
						new playerName[MAX_PLAYER_NAME], pID, HighestKillAssists;
						cache_get_value_int(i, "pID", pID);
						cache_get_value(i, "Username", playerName);
						cache_get_value_int(i, "HighestKillAssists", HighestKillAssists);

						Text_Send(pid, $NEWCLIENT_47x, playerName, i + 1, HighestKillAssists);
					}	
				} else Text_Send(pid, $CLIENT_423x);
				cache_delete(topResult);
			}
			case 15: {
				new Cache: topResult;
				topResult = mysql_query(Database, "SELECT d1.`Username`, d2.`pID`, d2.`HighestCaptureAssists` FROM `Players` AS d1, `PlayersData` AS d2 WHERE d1.`ID` = d2.`pID` ORDER BY d2.`HighestCaptureAssists` DESC LIMIT 10");
				if (cache_num_rows()) {
					for (new i = 0; i < cache_num_rows(); i++) {
						new playerName[MAX_PLAYER_NAME], pID, HighestCaptureAssists;
						cache_get_value_int(i, "pID", pID);
						cache_get_value(i, "Username", playerName);
						cache_get_value_int(i, "HighestCaptureAssists", HighestCaptureAssists);

						Text_Send(pid, $NEWCLIENT_48x, playerName, i + 1, HighestCaptureAssists);
					}	
				} else Text_Send(pid, $CLIENT_423x);
				cache_delete(topResult);
			}
		}
	}
	Text_DialogBox(playerid, DIALOG_STYLE_LIST, using inline TopPlayersMenu, $TOP_PLAYERS_CAP, $TOP_PLAYERS_DESC, $DIALOG_SELECT, $DIALOG_CLOSE);
	return 1;
}

//Change password

flags:changepass(CMD_SECRET);
CMD:changepass(playerid, params[]) {
	if (!pVerified[playerid]) return 1;

	if (PlayerInfo[playerid][pLoggedIn] == 1) {
		if (isnull(params)) return ShowSyntax(playerid, "/changepass [new pass]");
		if (strlen(params) < 4 || strlen(params) > 20) return ShowSyntax(playerid, "/changepass [new pass 4-20]");

		new query[450];

		PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
		Text_Send(playerid, $NEWCLIENT_49x, params);

		for (new i = 0; i < 10; i++) {
			PlayerInfo[playerid][pSaltKey][i] = random(79) + 47;
		}

		PlayerInfo[playerid][pSaltKey][10] = 0;
		SHA256_PassHash(params, PlayerInfo[playerid][pSaltKey], PlayerInfo[playerid][pPassword], 65);

		mysql_format(Database, query, sizeof query, "UPDATE `Players` SET `Password` = '%e', `Salt` = '%e' WHERE `ID` = '%d' LIMIT 1", PlayerInfo[playerid][pPassword], PlayerInfo[playerid][pSaltKey], PlayerInfo[playerid][pAccountId]);
		mysql_tquery(Database, query);
	} else return PlayerPlaySound(playerid, 1055, 0.0, 0.0, 0.0);
	return 1;
}

//Player Spawn

alias:sp("spawnplace");
CMD:sp(playerid) {
	if (pDuelInfo[playerid][pDInMatch] == 1) return Text_Send(playerid, $COMMAND_INDUEL);
	if (PlayerInfo[playerid][pDeathmatchId] > -1) return Text_Send(playerid, $COMMAND_INDM);
	if (Iter_Contains(ePlayers, playerid)) return Text_Send(playerid, $COMMAND_INEVENT);
	if (Iter_Contains(CWCLAN1, playerid) || Iter_Contains(CWCLAN2, playerid)) return Text_Send(playerid, $COMMAND_INCW);
	if (Iter_Contains(PUBGPlayers, playerid)) return Text_Send(playerid, $COMMAND_INPUBG);

	new zonespawns[950], sub[75];

	strcat(zonespawns, ""YELLOW"BASE\n");
	strcat(zonespawns, ""YELLOW"CLAN BASE\n");

	for (new i = 0; i < sizeof(ZoneInfo); i++) {
		if (ZoneInfo[i][Zone_Owner] == pTeam[playerid]) {
			format(sub, sizeof(sub), ""DARKBLUE"%s\n", ZoneInfo[i][Zone_Name]);
			strcat(zonespawns, sub);
		} else {
			format(sub, sizeof(sub), ""RED2"%s\n", ZoneInfo[i][Zone_Name]);
			strcat(zonespawns, sub);			
		}
	}

	inline SpawnPlace(pid, dialogid, response, listitem, string:inputtext[]) {
		#pragma unused dialogid, inputtext
		if (!response) return 1;
		if (listitem == 0) {
			Text_Send(pid, $CLIENT_439x);
			pSpawn[pid] = -1;
		} else if (listitem == 1) {
			if (!IsPlayerInAnyClan(pid)) return Text_Send(pid, $CLIENT_440x);
			new clanbase_owner = -1;
			for (new i = 0; i < MAX_CLANS; i++) {
				if (ClanInfo[i][Clan_Id] != -1 && ClanInfo[i][Clan_Baseperk]) {
					clanbase_owner = ClanInfo[i][Clan_Id];
					break;
				}
			}
			if (clanbase_owner == pClan[pid]) {
				Text_Send(pid, $CHANGE_TEAM);
			} else {
				Text_Send(pid, $CLIENT_440x);
			}
		} else {
			if (ZoneInfo[listitem - 2][Zone_Owner] != pTeam[pid]) return Text_Send(pid, $CLIENT_442x);
			Text_Send(pid, $CLIENT_443x, ZoneInfo[listitem - 2][Zone_Name]);
			pSpawn[pid] = listitem - 2;
		}
	}

	Dialog_ShowCallback(playerid, using inline SpawnPlace, DIALOG_STYLE_LIST, ""YELLOW"SPAWN PLACE", zonespawns, ">>", "X");
	return 1;
}

//Player Settings

CMD:settings(playerid) {    
	if (!pVerified[playerid]) return 1;

	inline DeleteAccount(pid, dialogid, response, listitem, string:inputtext[]) {
		#pragma unused dialogid, listitem
		if (!response) return PC_EmulateCommand(pid, "/settings");
		if (!strcmp(PlayerInfo[pid][PlayerName], inputtext, true) && !isnull(inputtext)) {
			if (IsPlayerInAnyClan(pid)) return Text_Send(pid, $LEAVE_YOUR_CLAN);
			if (PlayerInfo[pid][pAdminLevel] || PlayerInfo[pid][pDonorLevel]) return Text_Send(pid, $HIGH_RANK);
			new query[450], rmpid = PlayerInfo[pid][pAccountId], rmpname[MAX_PLAYER_NAME];
			format(rmpname, MAX_PLAYER_NAME, PlayerInfo[pid][PlayerName]);
			Kick(pid);

			mysql_format(Database, query, sizeof(query), "DELETE FROM `Players` WHERE `ID` = '%d' LIMIT 1", rmpid);
			mysql_tquery(Database, query);

			mysql_format(Database, query, sizeof(query), "DELETE FROM `PlayersData` WHERE `pID` = '%d' LIMIT 1", rmpid);
			mysql_tquery(Database, query);

			mysql_format(Database, query, sizeof(query), "DELETE FROM `PlayersConf` WHERE `pID` = '%d' LIMIT 1", rmpid);
			mysql_tquery(Database, query);

			mysql_format(Database, query, sizeof(query), "DELETE FROM `Punishments` WHERE `PunishedPlayer` = '%e' LIMIT 1", rmpname);
			mysql_tquery(Database, query);

			mysql_format(Database, query, sizeof(query), "DELETE FROM FROM `IgnoreList` WHERE `BlockerId` = '%d' OR `BlockedId` = '%d'", rmpid, rmpid);
			mysql_tquery(Database, query);
		}
	}

	inline AntiSKTime(pid, dialogid, response, listitem, string:inputtext[]) {
		#pragma unused dialogid, inputtext, listitem
		if (!response) return PC_EmulateCommand(pid, "/settings");

		new seconds;
		if (sscanf(inputtext, "i", seconds)) return ShowSyntax(playerid, "Anti-SK secs: 3-15");
		if (seconds > 15 || seconds <= 2) return ShowSyntax(playerid, "Anti-SK secs: 3-15");
		PlayerPlaySound(pid, 1057, 0.0, 0.0, 0.0);

		PC_EmulateCommand(pid, "/settings");
		PlayerInfo[pid][pSpawnKillTime] = seconds;	
	}

	inline PlayerSettings(pid, dialogid, response, listitem, string:inputtext[]) {
		#pragma unused dialogid, inputtext
		if (!response) return 1;

		new id[6];
		format(id, sizeof(id), "%d", pid);

		switch (listitem) {
			case 0: PC_EmulateCommand(pid, "/noduel");
			case 1: PC_EmulateCommand(pid, "/dnd");
			case 2: PC_EmulateCommand(pid, "/hi");
			case 3: PC_EmulateCommand(pid, "/toys");
			case 4: PC_EmulateCommand(pid, "/hud");
			case 5: Text_DialogBox(pid, DIALOG_STYLE_INPUT, using inline AntiSKTime, $DIALOG_MESSAGE_CAP, $ANTI_SPAWN_TIME, $DIALOG_CONFIRM, $DIALOG_CANCEL);	
			case 6: PC_EmulateCommand(pid, "/st");
			case 7: PC_EmulateCommand(pid, "/sc");
			case 8: PC_EmulateCommand(pid, "/language");
			case 9: PC_EmulateCommand(pid, "/dm");
			case 10: PC_EmulateCommand(pid, "/mstop");
			case 11: {
				Text_DialogBox(pid, DIALOG_STYLE_INPUT, using inline DeleteAccount, $DELETE_ACC_CAP, $DELETE_ACC_DESC, $DIALOG_CONFIRM, $DIALOG_CANCEL);
			}
			case 12: {
				if (!PlayerInfo[pid][pTFA]) {
					if (isnull(PlayerInfo[playerid][pSupportKey]) || !PlayerInfo[playerid][pEmailVerified]) return Text_Send(playerid, $TFA_EMAIL_UNVERIFIED);
					Text_Send(pid, $TFA);
					PlayerInfo[pid][pTFA] = true;
				} else {
					Text_Send(pid, $TFA_OFF);
					PlayerInfo[pid][pTFA] = false;
				}
			}
		}
	}

	new settings[1010];
	format(settings, sizeof(settings), "Option\tInfo\n\
	"LIGHTBLUE"Toggle Duels\t%s\n\
	"LIGHTBLUE"Toggle Private Messages\t%s\n\
	"LIGHTBLUE"Toggle Hit Indicator\t%s\n\
	"LIGHTBLUE"Body Toys\n\
	"LIGHTBLUE"Toggle User Interface\t%s\n\
	"LIGHTBLUE"Spawn Protection Seconds\t%d\n\
	"LIGHTBLUE"Change Team\n\
	"LIGHTBLUE"Change Class\n\
	"LIGHTBLUE"Change Language\n\
	"LIGHTBLUE"Deathmatch\n\
	"LIGHTBLUE"Stop Playing Sounds\n\
	"RED2"Delete Your Account\n\
	"RED2"Two-Step Login",
	(GetPlayerConfigValue(playerid, "NODUEL") > 0) ? ("[On]") : ("[Off]"),
	(GetPlayerConfigValue(playerid, "DND") > 0) ? ("[On]") : ("[Off]"),
	(GetPlayerConfigValue(playerid, "HI") > 0) ? ("[On]") : ("[Off]"),
	(GetPlayerConfigValue(playerid, "HUD") > 0) ? ("[On]") : ("[Off]"),
	PlayerInfo[playerid][pSpawnKillTime]);

	Dialog_ShowCallback(playerid, using inline PlayerSettings, DIALOG_STYLE_TABLIST_HEADERS, ""RED2"SvT - Player Settings", settings, ">>", "X");    
	return 1;
}

//Help Commands

CMD:help(playerid) {
	inline HelpDialog(pid, dialogid, response, listitem, string:inputtext[]) {
		#pragma unused dialogid, inputtext
		if (response) {
			switch (listitem) {
				case 0: PC_EmulateCommand(pid, "/about");
				case 1: PC_EmulateCommand(pid, "/cmds"); 
				case 2: PC_EmulateCommand(pid, "/stats"); 
				case 3: PC_EmulateCommand(pid, "/settings"); 
				case 4: PC_EmulateCommand(pid, "/objectives"); 
				case 5: PC_EmulateCommand(pid, "/rules"); 
				case 6: PC_EmulateCommand(pid, "/zones");
				case 7: PC_EmulateCommand(pid, "/teams");
				case 8: PC_EmulateCommand(pid, "/st");
				case 9: PC_EmulateCommand(pid, "/sc");
				case 10: PC_EmulateCommand(pid, "/dm");
				case 11: PC_EmulateCommand(pid, "/streaks");
				case 12: PC_EmulateCommand(pid, "/ranks");
				case 13: PC_EmulateCommand(pid, "/classes");
				case 14: PC_EmulateCommand(pid, "/rank");
				case 15: PC_EmulateCommand(pid, "/streak");
				case 16: PC_EmulateCommand(pid, "/nukehelp");
				case 17: PC_EmulateCommand(pid, "/vshop");
				case 18: PC_EmulateCommand(pid, "/vcmds");
				case 19: PC_EmulateCommand(pid, "/settings");
				case 20: PC_EmulateCommand(pid, "/credits");
			}
		}		
	}

	Dialog_ShowCallback(playerid, using inline HelpDialog, DIALOG_STYLE_LIST, "Help",
		"About\n\
		Game Commands\n\
		Your Stats\n\
		Your Settings\n\
		Game Objectives\n\
		Game Rules\n\
		Capture Zones\n\
		Game Teams\n\
		Switch Team\n\
		Switch Class\n\
		Deathmatch\n\
		Streaks\n\
		Ranks\n\
		Classes\n\
		Your Rank\n\
		Your Streak\n\
		Nuke Help\n\
		V.I.P Shop\n\
		V.I.P Commands\n\
		Settings/Options\n\
		Credits", "Next", "X");
	return 1;
}

CMD:about(playerid) {
	SendClientMessage(playerid, X11_DEEPPINK, "SWAT vs Terrorists SA-MP Server");
	SendClientMessage(playerid, X11_IVORY, "Official website:"LIGHTBLUE" "WEBSITE"");
	SendClientMessage(playerid, X11_IVORY, "Official discord server:"LIGHTBLUE" https://discord.gg/dHKNJH2");
	return 1;
}

flags:rules(CMD_SYSTEM);
CMD:rules(playerid) {
	inline ConfirmRules(pid, dialogid, response, listitem, string:inputtext[]) {
		#pragma unused dialogid, response, listitem, inputtext
		if (!response) {
			Kick(pid);
		}
	}
	Text_DialogBox(playerid, DIALOG_STYLE_MSGBOX, using inline ConfirmRules, $SERVER_RULES_CAP, $SERVER_RULES_DESC, $DIALOG_AGREE, $DIALOG_DISAGREE);
	return 1;
}

flags:credits(CMD_SYSTEM);
CMD:credits(playerid) {
	SendClientMessage(playerid, -1, "");
	SendClientMessage(playerid, -1, "");
	SendClientMessage(playerid, X11_MAROON, "------=Credits=------");
	SendClientMessage(playerid, X11_RED2, "==> Senior Development: H2O");
	SendClientMessage(playerid, X11_RED2, "==> Lead V10 Testing: Aevanora, Impulse, Queen");
	SendClientMessage(playerid, X11_RED2, "==> Management: Swanson, denNorske");
	SendClientMessage(playerid, X11_RED2, "==> Minor Scripting: DarkZero");
	SendClientMessage(playerid, X11_RED2, "==> Mapping Lead: Hydra, JustCurious");
	SendClientMessage(playerid, X11_RED2, "==> Past Mappers: SKAY, Revan, ScreaM, Lucifer");
	SendClientMessage(playerid, X11_RED2, "==> Additional Mapping: spitfire, RedFusion");
	SendClientMessage(playerid, X11_RED2, "==> Thanks for everyone who helped make this possible.");
	SendClientMessage(playerid, X11_RED2, "==> And you for playing!");
	SendClientMessage(playerid, -1, "");
	SendClientMessage(playerid, -1, "");
	return 1;
}

alias:forum("website", "web");
CMD:forum(playerid) {
	SendClientMessage(playerid, X11_DEEPSKYBLUE, "Website: https://"WEBSITE"/");
	return 1;
}

CMD:language(playerid) {
	/*inline ChangeLanguage(pid, dialogid, response, listitem, string:inputtext[]) {
		#pragma unused dialogid, inputtext
		if (response) {
			switch (listitem) {
				case 0: Langs_SetPlayerLanguage(pid, English);
				case 1: Langs_SetPlayerLanguage(pid, Spanish);
			}	
		}
	}
	Dialog_ShowCallback(playerid, using inline ChangeLanguage, DIALOG_STYLE_LIST, ""RED2"SvT - Languages", "English\nSpanish", "Change", "X");*/
	SendClientMessage(playerid, X11_RED, "Coming soon!");
	return 1;
}

CMD:cmds(playerid) {
	inline CommandsResponse(pid, dialogid, response, listitem, string:inputtext[]) {
		#pragma unused dialogid, response, listitem, inputtext
		PC_EmulateCommand(pid, "/cmds");
	}

	inline Commands(pid, dialogid, response, listitem, string:inputtext[]) {
		#pragma unused dialogid, inputtext
		if (response) {
			switch (listitem) {
				case 0: Text_DialogBox(pid, DIALOG_STYLE_MSGBOX, using inline CommandsResponse, $GENERAL_CMDS_CAP, $GENERAL_CMDS_DESC, $DIALOG_RETURN, "");
				case 1: Text_DialogBox(pid, DIALOG_STYLE_MSGBOX, using inline CommandsResponse, $GENERAL_CMDS_CAP, $GENERAL_CMDS2_DESC, $DIALOG_RETURN, "");
				case 2: Text_DialogBox(pid, DIALOG_STYLE_MSGBOX, using inline CommandsResponse, $GENERAL_CMDS_CAP, $GENERAL_CMDS3_DESC, $DIALOG_RETURN, "");
				case 3: Text_DialogBox(pid, DIALOG_STYLE_MSGBOX, using inline CommandsResponse, $PLAYER_CMDS_CAP, $PLAYER_CMDS_DESC, $DIALOG_RETURN, "");
				case 4: Text_DialogBox(pid, DIALOG_STYLE_MSGBOX, using inline CommandsResponse, $PLAYER_CMDS_CAP, $PLAYER_CMDS2_DESC, $DIALOG_RETURN, "");
				case 5: Text_DialogBox(pid, DIALOG_STYLE_MSGBOX, using inline CommandsResponse, $PLAYER_CMDS_CAP, $PLAYER_CMDS3_DESC, $DIALOG_RETURN, "");
				case 6: Text_DialogBox(pid, DIALOG_STYLE_MSGBOX, using inline CommandsResponse, $INVENTORY_CMDS_CAP, $INVENTORY_CMDS_DESC, $DIALOG_RETURN, "");
				case 7: Text_DialogBox(pid, DIALOG_STYLE_MSGBOX, using inline CommandsResponse, $CLAN_CMDS_CAP, $CLAN_CMDS_DESC, $DIALOG_RETURN, "");
				case 8: Text_DialogBox(pid, DIALOG_STYLE_MSGBOX, using inline CommandsResponse, $CLAN_CMDS_CAP, $CLAN_CMDS2_DESC, $DIALOG_RETURN, "");
				case 9: Text_DialogBox(pid, DIALOG_STYLE_MSGBOX, using inline CommandsResponse, $SPECIAL_CMDS_CAP, $SPECIAL_CMDS_DESC, $DIALOG_RETURN, "");
				case 10: Text_DialogBox(pid, DIALOG_STYLE_MSGBOX, using inline CommandsResponse, $ANIMS_CMDS_CAP, $ANIMS_CMDS_DESC, $DIALOG_RETURN, "");
				case 11: Text_DialogBox(pid, DIALOG_STYLE_MSGBOX, using inline CommandsResponse, $SHORTCUTS_CAP, $SHORTCUTS_DESC, $DIALOG_RETURN, "");
			}
		}
	}
	Dialog_ShowCallback(playerid, using inline Commands, DIALOG_STYLE_LIST, ""RED2"SvT - Commands",
	"{638FD6}General Commands\n{638FD6}General Commands 2\n{638FD6}General Commands 3\n{638FD6}Player Commands\n\
	{638FD6}Player Commands 2\n{638FD6}Player Commands 3\n{638FD6}Inventory Related\n\
	{638FD6}Clan Related\n{638FD6}Clan Related 2\n{638FD6}Special\n\
	{638FD6}Animations\n{638FD6}Shortcuts",
	"Pick", "X");
	return 1;
}
alias:cmds("commands", "chelp", "ccmds", "pcmds", "gcmds", "scmds", "shortcuts");

alias:ask("helpme", "admin");
CMD:ask(playerid, params[]) {
	if (PlayerInfo[playerid][pMuted] == 1) {
		Text_Send(playerid, $CLIENT_420x);
		return 0;
	}

	if (PlayerInfo[playerid][pAdminLevel] < svtconf[max_admin_level] && svtconf[anti_adv] && AdCheck(params)) {
		new adcheck[150];
		format(adcheck, sizeof(adcheck), "*%s[%d] has attempted to advertise: %s", PlayerInfo[playerid][PlayerName],
		playerid, params);

		MessageToAdmins(0x505751FF, adcheck);
	  
		PlayerInfo[playerid][pAdvAttempts] ++;
		return 0;
	}	

	if (PlayerInfo[playerid][pQuestionAsked]) return Text_Send(playerid, $CLIENT_449x);
	PlayerInfo[playerid][pQuestionsAsked] ++;

	new String[188], message[128];
	if (sscanf(params, "s[128]", message)) {
		ShowSyntax(playerid, "/ask [text]");
		return 1;
	}

	Text_Send(playerid, $NEWCLIENT_108x, PlayerInfo[playerid][PlayerName], playerid, message);
	MessageToAdmins(X11_DEEPSKYBLUE, String);
	foreach (new i: Player) {
		if (PlayerInfo[i][pAdminLevel] || PlayerInfo[i][pIsModerator]) {
			Text_Send(i, $NEWCLIENT_108x, PlayerInfo[playerid][PlayerName], playerid, message);
		}
	}

	format(String, sizeof(String), "%s[%d] asked: %s (in game)", PlayerInfo[playerid][PlayerName], playerid, message);
  
	new DCC_Channel:StaffChannel;
	StaffChannel = DCC_FindChannelByName(CHANNEL_STAFF_NAME);
	DCC_SendChannelMessage(StaffChannel, String);
	print(String);

	Text_Send(playerid, $CLIENT_450x);
	PlayerInfo[playerid][pQuestionAsked] = 1;    
	return 1;
}

//Commit Suicide

CMD:kill(playerid) {
	if (PlayerInfo[playerid][pLastHitTick] > gettime()) return Text_Send(playerid, $JUSTHIT, PlayerInfo[playerid][pLastHitTick] - gettime());
	if (GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) return Text_Send(playerid, $COMMAND_NOTONFOOT);

	if (AntiSK[playerid]) {
		EndProtection(playerid);
	}

	SetPlayerHealth(playerid, 0.0);
	SendDeathMessage(INVALID_PLAYER_ID, playerid, 255);
	PlayerInfo[playerid][pSuicideAttempts] ++;
	return 1;
}

//User Interface

CMD:hud(playerid) {
	if (GetPlayerConfigValue(playerid, "HUD")) {
		SetPlayerConfigValue(playerid, "HUD", 0);
	} else {
		SetPlayerConfigValue(playerid, "HUD", 1);
	}

	UpdatePlayerHUD(playerid);
	return 1;
}

//Animations

CMD:handsup(playerid) {
	if (Iter_Contains(ePlayers, playerid)) return Text_Send(playerid, $CLIENT_464x);
	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_HANDSUP);    
	return 1;
}

CMD:cellin(playerid) {
	if (Iter_Contains(ePlayers, playerid)) return Text_Send(playerid, $CLIENT_464x);
	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USECELLPHONE);    
	return 1;
}

CMD:cellout(playerid) {
	if (Iter_Contains(ePlayers, playerid)) return Text_Send(playerid, $CLIENT_464x);
	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_STOPUSECELLPHONE);    
	return 1;
}

CMD:drunk(playerid) {
	if (Iter_Contains(ePlayers, playerid)) return Text_Send(playerid, $CLIENT_464x);
	AnimLoopPlayer(playerid, "PED", "WALK_DRUNK", 4.0, 1, 1, 1, 1, 0);    
	return 1;
}

CMD:wine(playerid) {
	return SetPlayerSpecialAction(playerid, SPECIAL_ACTION_DRINK_WINE);
}

CMD:bomb(playerid) {
	if (Iter_Contains(ePlayers, playerid)) return Text_Send(playerid, $CLIENT_464x);
	ClearAnimations(playerid);
	AnimPlayer(playerid, "BOMBER", "BOM_Plant", 4.0, 0, 0, 0, 0, 0);    
	return 1;
}

CMD:getarrested(playerid) {
	if (Iter_Contains(ePlayers, playerid)) return Text_Send(playerid, $CLIENT_464x);
	AnimLoopPlayer(playerid, "ped", "ARRESTgun", 4.0, 0, 1, 1, 1, -1);    
	return 1;
}

CMD:laugh(playerid) {
	if (Iter_Contains(ePlayers, playerid)) return Text_Send(playerid, $CLIENT_464x);
	AnimPlayer(playerid, "RAPPING", "Laugh_01", 4.0, 0, 0, 0, 0, 0);    
	return 1;
}

CMD:lookout(playerid) {
	if (Iter_Contains(ePlayers, playerid)) return Text_Send(playerid, $CLIENT_464x);
	AnimPlayer(playerid, "SHOP", "ROB_Shifty", 4.0, 0, 0, 0, 0, 0);    
	return 1;
}

CMD:piss(playerid) {
	if (Iter_Contains(ePlayers, playerid)) return Text_Send(playerid, $CLIENT_464x);
	SetPlayerSpecialAction(playerid, 68);    
	return 1;
}

CMD:wank(playerid) {
	if (Iter_Contains(ePlayers, playerid)) return Text_Send(playerid, $CLIENT_464x);
	AnimLoopPlayer(playerid, "PAULNMAC", "wank_loop", 4.0, 1, 0, 0, 0, 0);    
	return 1;
}

CMD:robman(playerid) {
	if (Iter_Contains(ePlayers, playerid)) return Text_Send(playerid, $CLIENT_464x);
	AnimLoopPlayer(playerid, "SHOP", "ROB_Loop_Threat", 4.0, 1, 0, 0, 0, 0);    
	return 1;
}

CMD:crossarms(playerid) {
	if (Iter_Contains(ePlayers, playerid)) return Text_Send(playerid, $CLIENT_464x);
	AnimLoopPlayer(playerid, "COP_AMBIENT", "Coplook_loop", 4.0, 0, 1, 1, 1, -1);    
	return 1;
}

CMD:lay(playerid) {
	if (Iter_Contains(ePlayers, playerid)) return Text_Send(playerid, $CLIENT_464x);
	AnimLoopPlayer(playerid, "BEACH", "bather", 4.0, 1, 0, 0, 0, 0);    
	return 1;
}

CMD:hide(playerid) {
	if (Iter_Contains(ePlayers, playerid)) return Text_Send(playerid, $CLIENT_464x);
	AnimLoopPlayer(playerid, "ped", "cower", 3.0, 1, 0, 0, 0, 0);    
	return 1;
}

CMD:vomit(playerid) {
	if (Iter_Contains(ePlayers, playerid)) return Text_Send(playerid, $CLIENT_464x);
	AnimPlayer(playerid, "FOOD", "EAT_Vomit_P", 3.0, 0, 0, 0, 0, 0);    
	return 1;
}

CMD:eat(playerid) {
	if (Iter_Contains(ePlayers, playerid)) return Text_Send(playerid, $CLIENT_464x);
	AnimPlayer(playerid, "FOOD", "EAT_Burger", 3.0, 0, 0, 0, 0, 0);    
	return 1;
}

CMD:wave(playerid) {
	if (Iter_Contains(ePlayers, playerid)) return Text_Send(playerid, $CLIENT_464x);
	AnimLoopPlayer(playerid, "ON_LOOKERS", "wave_loop", 4.0, 1, 0, 0, 0, 0);

	new Float: X, Float: Y, Float: Z;
	GetPlayerPos(playerid, X, Y, Z);

	foreach (new i: Player) {
		if (IsPlayerInRangeOfPoint(i, 10.0, X, Y, Z) && i != playerid) {
			Text_Send(i, $CLIENT_546x, PlayerInfo[playerid][PlayerName]);
		}
	}    
	return 1;
}

CMD:slapass(playerid) {
	if (Iter_Contains(ePlayers, playerid)) return Text_Send(playerid, $CLIENT_464x);
	AnimPlayer(playerid, "SWEET", "sweet_Adm_slap", 4.0, 0, 0, 0, 0, 0);    
	return 1;
}

CMD:deal(playerid) {
	if (Iter_Contains(ePlayers, playerid)) return Text_Send(playerid, $CLIENT_464x);
	AnimPlayer(playerid, "DEALER", "DEALER_DEAL", 4.0, 0, 0, 0, 0, 0);    
	return 1;
}

CMD:crack(playerid) {
	if (Iter_Contains(ePlayers, playerid)) return Text_Send(playerid, $CLIENT_464x);
	AnimLoopPlayer(playerid, "CRACK", "crckdeth2", 4.0, 1, 0, 0, 0, 0);    
	return 1;
}

CMD:smokem(playerid) {
	if (Iter_Contains(ePlayers, playerid)) return Text_Send(playerid, $CLIENT_464x);
	AnimLoopPlayer(playerid, "SMOKING", "M_smklean_loop", 4.0, 1, 0, 0, 0, 0);    
	return 1;
}

CMD:smokef(playerid) {
	if (Iter_Contains(ePlayers, playerid)) return Text_Send(playerid, $CLIENT_464x);
	AnimLoopPlayer(playerid, "SMOKING", "F_smklean_loop", 4.0, 1, 0, 0, 0, 0);    
	return 1;
}

CMD:sit(playerid) {
	if (Iter_Contains(ePlayers, playerid)) return Text_Send(playerid, $CLIENT_464x);
	AnimLoopPlayer(playerid, "BEACH", "ParkSit_M_loop", 4.0, 1, 0, 0, 0, 0);    
	return 1;
}

CMD:fu(playerid) {
	if (Iter_Contains(ePlayers, playerid)) return Text_Send(playerid, $CLIENT_464x);
	AnimPlayer(playerid, "PED", "fucku", 4.0, 0, 0, 0, 0, 0);    
	return 1;
}

CMD:taichi(playerid) {
	if (Iter_Contains(ePlayers, playerid)) return Text_Send(playerid, $CLIENT_464x);
	AnimLoopPlayer(playerid, "PARK", "Tai_Chi_Loop", 4.0, 1, 0, 0, 0, 0);    
	return 1;
}

CMD:chairsit(playerid) {
	if (Iter_Contains(ePlayers, playerid)) return Text_Send(playerid, $CLIENT_464x);
	AnimLoopPlayer(playerid, "BAR", "dnk_stndF_loop", 4.0, 1, 0, 0, 0, 0);    
	return 1;
}

CMD:chat(playerid) {
	if (Iter_Contains(ePlayers, playerid)) return Text_Send(playerid, $CLIENT_464x);
	AnimPlayer(playerid, "PED", "IDLE_CHAT", 4.0, 0, 0, 0, 0, 0);    
	return 1;
}

CMD:dance(playerid, params[]) {
	if (Iter_Contains(ePlayers, playerid)) return Text_Send(playerid, $CLIENT_464x);

	new dancestyle;
	if (!sscanf(params, "d", dancestyle)) {
		switch (dancestyle) {
			case 1: {
				SetPlayerSpecialAction(playerid, SPECIAL_ACTION_DANCE1);
			}
			case 2: {
				SetPlayerSpecialAction(playerid, SPECIAL_ACTION_DANCE2);
			}
			case 3: {
				SetPlayerSpecialAction(playerid, SPECIAL_ACTION_DANCE3);
			}
			case 4: {
				SetPlayerSpecialAction(playerid, SPECIAL_ACTION_DANCE4);
			}
			default: {
				GameTextForPlayer(playerid, "~r~Invalid, Dance Id~n~~w~~y~/Dance (1-4)", 3500, 3);
			}
		}
	} else return GameTextForPlayer(playerid, "~w~~y~/Dance (1-4)", 3500, 3);    
	return 1;
}

//Kill Streak

alias:streaks("sprees");
CMD:streaks(playerid) {
	new string[50 * sizeof(SpreeInfo)], sub_string[45];
	strcat(string, "Spree\tKills\n");

	for (new i = 0; i < sizeof(SpreeInfo); i++) {
		if (pStreak[playerid] >= SpreeInfo[i][Spree_Kills]) {
			format(sub_string, sizeof(sub_string), "{0099FF}%s\t%d\n", SpreeInfo[i][Spree_Name], SpreeInfo[i][Spree_Kills]);
			strcat(string, sub_string);
		}
		else
		{
			format(sub_string, sizeof(sub_string), "{FF0000}%s\t%d\n", SpreeInfo[i][Spree_Name], SpreeInfo[i][Spree_Kills]);
			strcat(string, sub_string);
		}
	}


	Dialog_Show(playerid, DIALOG_STYLE_TABLIST_HEADERS, ""RED2"SvT - Streaks", string, "X", "");    
	return 1;
}

alias:spree("streak");
CMD:spree(playerid) {
	Text_Send(playerid, $NEWCLIENT_110x, pStreak[playerid]);
	Text_Send(playerid, $NEWCLIENT_111x, PlayerInfo[playerid][pHighestKillStreak]);
	Text_Send(playerid, $NEWCLIENT_112x, PlayerInfo[playerid][pHighestKillAssists]);
	Text_Send(playerid, $NEWCLIENT_113x, PlayerInfo[playerid][pCaptureStreak]);
	Text_Send(playerid, $NEWCLIENT_114x, PlayerInfo[playerid][pHighestCaptures]);
	Text_Send(playerid, $NEWCLIENT_115x, PlayerInfo[playerid][pHighestCaptureAssists]);
	return 1;
}

//Radio

CMD:radio(playerid, params[]) {
	inline RadioSystem(pid, dialogid, response, listitem, string:inputtext[]) {
		#pragma unused dialogid, inputtext
		if (response) {
			switch (listitem)
			{
				case 0: PlayAudioStreamForPlayer(pid, "http://ice1.somafm.com/bagel-128-mp3", 0.0, 0.0, 0.0, 0.0, 0);
				case 1: PlayAudioStreamForPlayer(pid, "http://live-mp3-128.kexp.org/kexp128.mp3", 0.0, 0.0, 0.0, 0.0, 0);
				case 2: PlayAudioStreamForPlayer(pid, "http://listen.xray.fm:8000/stream", 0.0, 0.0, 0.0, 0.0, 0);
				case 3: PlayAudioStreamForPlayer(pid, "http://emisorasmusicales.es:8030/valencia.mp3", 0.0, 0.0, 0.0, 0.0, 0);
				case 4: PlayAudioStreamForPlayer(pid, "http://radio.talksport.com/stream?awparams=platform:ts-tunein;lang:en", 0.0, 0.0, 0.0, 0.0, 0);
				case 5: PlayAudioStreamForPlayer(pid, "http://bbcmedia.ic.llnwd.net/stream/bbcmedia_radio1_mf_q?s=1519052945&e=1519067345&h=2f5027cd68ca6d1d0d088930e0952da3", 0.0, 0.0, 0.0, 0.0, 0);
				case 6: PlayAudioStreamForPlayer(pid, "http://145.239.72.186:8005/high.m3u", 0.0, 0.0, 0.0, 0.0, 0);
				case 7: PlayAudioStreamForPlayer(pid, "http://media-ice.musicradio.com/CapitalMP3.m3u", 0.0, 0.0, 0.0, 0.0, 0);
				case 8: PlayAudioStreamForPlayer(pid, "http://dir.xiph.org/listen/940324/listen.m3u", 0.0, 0.0, 0.0, 0.0, 0);
				case 9: PlayAudioStreamForPlayer(pid, "http://dir.xiph.org/listen/1036388/listen.m3u", 0.0, 0.0, 0.0, 0.0, 0);
				case 10: PlayAudioStreamForPlayer(pid, "http://dir.xiph.org/listen/646917/listen.m3u", 0.0, 0.0, 0.0, 0.0, 0);
				case 11: PlayAudioStreamForPlayer(pid, "http://dir.xiph.org/listen/1036116/listen.m3u", 0.0, 0.0, 0.0, 0.0, 0);
				case 12: PlayAudioStreamForPlayer(pid, "http://dir.xiph.org/listen/1055804/listen.m3u", 0.0, 0.0, 0.0, 0.0, 0);
			}
		} 
	}

	Dialog_ShowCallback(playerid, using inline RadioSystem, DIALOG_STYLE_LIST, "Radio",
	"Soma FM\n\
	KEXP 90.3 FM\n\
	XRAY FM\n\
	Activa FM\n\
	talkSPORT\n\
	BBC Radio\n\
	Pulse 87NY\n\
	Capital FM\n\
	Urban Radio\n\
	Jigga Radio\n\
	Radio Kamchatka\n\
	Radio Cafe\n\
	Radio Essex", "Play", "X");
	
	Text_Send(playerid, $CLIENT_465x);
	return 1;
}

CMD:mstop(playerid) {
	StopAudioStreamForPlayer(playerid);
	return 1;
}

CMD:theme(playerid) {
	return PlayAudioStreamForPlayer(playerid, "http://51.254.181.90/server/alister_theme.mp3",0.0, 0.0, 0.0, 0.0, 0);
}

//General

//Updates

alias:updates("news", "update");
CMD:updates(playerid) {
	Dialog_Show(playerid, DIALOG_STYLE_MSGBOX, "Current Release: "BUILD"", 
		"- Removed the achievements system with plans to implement a new one in the future.\n\
		- Removed the daily missions due to being disliked by majority of players.\n\
		- Removed the random bonus zone/player.\n\
		- Removed body toys and weapon laser.\n\
		- Added a globally synced time cycle instead of the previous per-player one.\n\
		- Added a globally synced automated weather changer.\n\
		- Updated class score and EXP requirements.\n\
		- Added more abilities to classes (and removed them from ranks).\n\
		- Limited heavy air vehicles to pilot class.\n\
		- Limited AAC to supporter class.\n\
		- Limited Submarines to Scout class.\n\
		- Made Submarines inflict actual damage.\n\
		- Fastened rockets thrown by an AAC.\n\
		- Global messages will now be red in color while per-player messages will be white.\n\
		- Players who use 2FA will now receive a new security code by email every login.\n\
		- Invisibility off the radar will no longer be effective out of the battlefield.\n\
		- Fixed the ...DEAD... appearing on players who lose a duel match and respawn in the rematch mode.\n\
		- I remember adding more aummnition to Sniper for the Sniper class? Check it out.\n\
		- Radio antennas will now take damage by dynamites only.\n\
		"RED2"- Introducing /votekick [player id] - use it wisely!", "X");
	return 1;
}

CMD:afks(playerid) {
	new count;

	Text_Send(playerid, $NEWCLIENT_187x);

	foreach (new i: Player) {
		if (PlayerInfo[i][pIsAFK]) {
			count ++;
			Text_Send(playerid, $NEWCLIENT_188x, count, PlayerInfo[i][PlayerName], gettime() - PlayerInfo[i][pAFKTick]);
		}
	}

	if (!count) {
		Text_Send(playerid, $CLIENT_337x);
	}
	return 1;
}

////////////////////
//Hit indicator

CMD:hi(playerid) {
	if (GetPlayerConfigValue(playerid, "HI") == 0) {
		SetPlayerConfigValue(playerid, "HI", 1);
		Text_Send(playerid, $CLIENT_333x);
	} else {
		SetPlayerConfigValue(playerid, "HI", 0);
		Text_Send(playerid, $CLIENT_334x);
	}
	return 1;
}

//Bounties

CMD:setbounty(playerid, params[]) {
	new targetid, amount;
	if (sscanf(params, "ui", targetid, amount)) return ShowSyntax(playerid, "/setbounty [playerid/name] [cash]");
	if (!IsPlayerConnected(targetid) || targetid == INVALID_PLAYER_ID) return Text_Send(playerid, $CLIENT_320x);
	if (PlayerInfo[targetid][pBountyAmount] > 100000000) return Text_Send(playerid, $CLIENT_332x);
	if (amount <= 0) return Text_Send(playerid, $CLIENT_325x);
	if (amount > GetPlayerCash(playerid)) return Text_Send(playerid, $CLIENT_326x);

	Text_Send(@pVerified, $NEWSERVER_60x, PlayerInfo[playerid][PlayerName], amount, PlayerInfo[targetid][PlayerName]);

	PlayerInfo[targetid][pBountyAmount] += amount;
	PlayerInfo[playerid][pBountyCashSpent] += amount;

	GivePlayerCash(playerid, -amount);    
	return 1;
}

CMD:bounties(playerid) {
	new sub_holder[35], bounty_holder[750], count = 0;

	strcat(bounty_holder, "Player\tValue\n");

	foreach (new i: Player) {
		if (PlayerInfo[i][pBountyAmount]) {
			format(sub_holder, sizeof(sub_holder), "%s\t$%d\n", PlayerInfo[i][PlayerName], PlayerInfo[i][pBountyAmount]);
			strcat(bounty_holder, sub_holder);

			count ++;
		}
	}

	if (count) {
		Dialog_Show(playerid, DIALOG_STYLE_TABLIST_HEADERS, "Bounty Heads", bounty_holder, "X", "");
	}  else Text_Send(playerid, $CLIENT_331x);
	return 1;
}

//Parachute

CMD:ep(playerid) {
	GivePlayerWeapon(playerid, 46, 1);    
	return 1;
}

//Get ID

CMD:getid(playerid, params[]) {
	if (isnull(params)) return ShowSyntax(playerid, "/getid [part name]");

	new rows;

	Text_Send(playerid, $NEWCLIENT_192x, params);

	foreach (new i: Player) {
		new bool: searched = false;
		for (new pos = 0; pos <= strlen(PlayerInfo[i][PlayerName]); pos ++) {
			if (searched != true) {
				if (strfind(PlayerInfo[i][PlayerName], params, true) == pos) {
					new string[75];
					format(string, sizeof(string), "%s [id: %d]", PlayerInfo[i][PlayerName], i);
					SendClientMessage(playerid, X11_LIMEGREEN, string);
					searched = true;
					rows ++;
				}
			}
		}
	}

	if (rows == 0) Text_Send(playerid, $CLIENT_327x);
	return 1;
}

//Sending Money

alias:sm("sendmoney");
CMD:sm(playerid, params[]) {
	new
		targetid,
		amount
	;

	if (sscanf(params, "ud", targetid, amount)) return ShowSyntax(playerid, "/sm [playerid/name] [amount]");
	if (targetid == INVALID_PLAYER_ID || !IsPlayerConnected(targetid) || targetid == playerid) return Text_Send(playerid, $CLIENT_319x);

	if (GetPlayerCash(playerid) <= amount) return Text_Send(playerid, $CLIENT_326x);

	if (amount < 1 || !amount) return Text_Send(playerid, $CLIENT_325x);
	if (amount > 100000) return Text_Send(playerid, $CLIENT_324x);

	GivePlayerCash(targetid, amount);
	GivePlayerCash(playerid, -amount);

	Text_Send(targetid, $CLIENT_322x, PlayerInfo[playerid][PlayerName], amount);
	PlayerInfo[targetid][pMoneyReceived] += amount;

	Text_Send(playerid, $CLIENT_323x, PlayerInfo[targetid][PlayerName], amount);
	PlayerInfo[playerid][pMoneySent] += amount;
	return 1;
}

//End of File
/* (c) H2O Multiplayer 2018-2020. All rights reserved. */