/*
	SWAT vs Terrorists is a team death-match SA-MP game-mode script. 
	Compatible with SA-MP 0.3.7 and later releases.

	Author: H2O
	Licensed under GNU GPLv3

	(c) 2018-2020 H2O Multiplayer. All rights reserved.
	Website: h2omultiplayer.com

	This is actually the core of the admin-script,
	It includes all the admin stuff of the script
*/

#include <YSI_Coding\y_hooks>

//Support for y_text, load language files...
#include <YSI_Players\y_text> //Y_Less
loadtext mode_text[all], mode_text[client], mode_text[newcs], mode_text[dialogs], mode_text[gametexts];

#include "players/admin/logs.pwn"
#include "players/admin/clan.pwn"
#include "players/admin/event.pwn"
#include "players/admin/discord.pwn"

//
/*
		C A L L B A C K S!
*/
//

forward OnlineChangeName(playerid, ID, newName[MAX_PLAYER_NAME]);
forward OfflineChangeName(playerid, oldName[MAX_PLAYER_NAME], newName[MAX_PLAYER_NAME]);
forward OfflineChangeName2(playerid, oldName[MAX_PLAYER_NAME], newName[MAX_PLAYER_NAME]);
forward ChangePlayerPassword(playerid, Username[], newPassword[]);
forward RemovePlayerAccount(playerid);
forward UpdatePlayerScore(playerid, score);
forward OfflineBan(playerid, nickname[], days, reason[]);
forward UnbanPlayer(playerid, nickname[]);
forward UnbanAddress(playerid, nickname[]);
forward UpdatePlayerKills(playerid, kills);
forward UpdatePlayerCash(playerid, cash);
forward UpdatePlayerDeaths(playerid, deaths);
forward UpdateAdminRank(playerid, al);
forward UpdateModeratorRank(playerid, al);
forward UpdateDonorRank(playerid, dl);
forward GetLastSeen(playerid);
forward GetAKALogger(playerid);
forward CheckBansData(playerid);
forward IPBanCheck(playerid);
forward OnWordForbid(playerid, word[]);
forward OnNameUnforbid(playerid, name[]);
forward Unfreeze(targetid);
forward OnNameForbid(playerid, word[]);
forward OnWordUnforbid(playerid, word[]);
forward IsForbiddenName(playerid, nick[]);
forward LoadForbiddenWords();
forward LoadForbiddenNames();

public OnlineChangeName(playerid, ID, newName[MAX_PLAYER_NAME]) {
	if (cache_num_rows() <= 0) {
		new query[256];

		mysql_format(Database, query, sizeof(query), "UPDATE `Players` SET `Username` = '%e' WHERE `Username` = '%e' LIMIT 1", newName, PlayerInfo[ID][PlayerName]);
		mysql_tquery(Database, query);

		SetPlayerName(ID, newName);
		
		Text_Send(playerid, $ADMIN_RENAME_PLAYER, PlayerInfo[ID][PlayerName], ID, newName);

		if (playerid != ID) {
			Text_Send(ID, $ADMIN_RENAMED_PLAYER, newName, PlayerInfo[playerid][PlayerName]);
		}

		mysql_format(Database, query, sizeof(query), "INSERT INTO `NameChangesLog` (`OldName`, `NewName`, `Admin`, `ActionDate`) VALUES ('%e', '%e', '%e', '%d')", PlayerInfo[ID][PlayerName], newName, PlayerInfo[playerid][PlayerName], gettime());
		mysql_tquery(Database, query);


		new String[128];
		format(String, sizeof(String), "Administrator %s changed %s's name to %s.", PlayerInfo[playerid][PlayerName], PlayerInfo[ID][PlayerName], newName);
		MessageToAdmins(0x2281C8FF, String);

		GetPlayerName(ID, PlayerInfo[ID][PlayerName], MAX_PLAYER_NAME);

	}  else Text_Send(playerid, $ADMIN_FAILED_ACTION);
	return 1;
}

public OfflineChangeName(playerid, oldName[MAX_PLAYER_NAME], newName[MAX_PLAYER_NAME]) {
	if (cache_num_rows() <= 0) {
		new query[105];

		mysql_format(Database, query, sizeof(query), "SELECT * FROM `Players` WHERE `Username` = '%e' LIMIT 1", oldName);
		mysql_tquery(Database, query, "OfflineChangeName2", "dss", playerid, oldName, newName);

	}  else Text_Send(playerid, $ADMIN_FAILED_ACTION);
	return 1;
}

public OfflineChangeName2(playerid, oldName[MAX_PLAYER_NAME], newName[MAX_PLAYER_NAME]) {
	if (cache_num_rows() > 0) {
		new query[256];

		new rank;
		cache_get_value_int(0, "AdminLevel", rank);
		if (rank == svtconf[max_admin_level] || rank >= PlayerInfo[playerid][pAdminLevel]) return Text_Send(playerid, $ADMIN_FAILED_ACTION);

		mysql_format(Database, query, sizeof(query), "UPDATE `Players` SET `Username` = '%e' WHERE `Username` = '%e' LIMIT 1", newName, oldName);
		mysql_tquery(Database, query);

		mysql_format(Database, query, sizeof(query), "INSERT INTO `NameChangesLog` (`OldName`, `NewName`, `Admin`, `ActionDate`) VALUES ('%e', '%e', '%e', '%d')", oldName, newName, PlayerInfo[playerid][PlayerName], gettime());
		mysql_tquery(Database, query);

		Text_Send(playerid, $ADMIN_OFFLINE_RENAME, oldName, newName);

		new String[128];
		format(String, sizeof(String), "Administrator %s changed %s's name to %s.", PlayerInfo[playerid][PlayerName], oldName, newName);
		MessageToAdmins(0x2281C8FF, String);

		format(query, sizeof(query), "Renamed player %s to %s.", oldName, newName);
		LogAdminAction(playerid, query);
	}  else Text_Send(playerid, $ADMIN_FAILED_ACTION);
	return 1;
}

public ChangePlayerPassword(playerid, Username[], newPassword[]) {
	if (cache_num_rows() > 0) {
		new query[500], Salt_key[11], Pass[65];
		
		new rank;
		cache_get_value_int(0, "AdminLevel", rank);
		if (rank == svtconf[max_admin_level]
				|| rank >= PlayerInfo[playerid][pAdminLevel]) return Text_Send(playerid, $ADMIN_FAILED_ACTION);

		for (new i = 0; i < 10; i++) {
			Salt_key[i] = random(79) + 47;
		}

		Salt_key[10] = 0;
		SHA256_PassHash(newPassword, Salt_key, Pass, 65);

		mysql_format(Database, query, sizeof(query), "UPDATE `Players` SET `Password` = '%e', `Salt` = '%e' WHERE `Username` = '%e' LIMIT 1", Pass, Salt_key, Username);
		mysql_tquery(Database, query);

		Text_Send(playerid, $ADMIN_OFFLINE_CHANGEPASS, Username, newPassword);

		new String[128];
		format(String, sizeof(String), "Administrator %s changed %s's account password.", PlayerInfo[playerid][PlayerName], Username);
		MessageToAdmins(0x2281C8FF, String);

		format(query, sizeof(query), "Changed %s's password to %s.", Username, newPassword);
		LogAdminAction(playerid, query);
	}  else Text_Send(playerid, $ADMIN_FAILED_ACTION);    
	return 1;
}

public RemovePlayerAccount(playerid) {
	if (cache_num_rows() > 0) {
		new pName[MAX_PLAYER_NAME], pid, rank;
		cache_get_value_int(0, "AdminLevel", rank);
		if (rank == svtconf[max_admin_level]
				|| rank >= PlayerInfo[playerid][pAdminLevel]) return Text_Send(playerid, $ADMIN_FAILED_ACTION);
		cache_get_value_int(0, "ID", pid);
		cache_get_value(0, "Username", pName, MAX_PLAYER_NAME);

		new query[450];

		mysql_format(Database, query, sizeof(query), "DELETE FROM `Players` WHERE `ID` = '%d' LIMIT 1", pid);
		mysql_tquery(Database, query);

		mysql_format(Database, query, sizeof(query), "DELETE FROM `PlayersData` WHERE `pID` = '%d' LIMIT 1", pid);
		mysql_tquery(Database, query);

		mysql_format(Database, query, sizeof(query), "DELETE FROM `PlayersConf` WHERE `pID` = '%d' LIMIT 1", pid);
		mysql_tquery(Database, query);

		mysql_format(Database, query, sizeof(query), "DELETE FROM FROM `IgnoreList` WHERE `BlockerId` = '%d' OR `BlockedId` = '%d'", pid, pid);
		mysql_tquery(Database, query);

		mysql_format(Database, query, sizeof(query), "DELETE FROM `BansData` WHERE `BannedName` = '%e' LIMIT 1", pName);
		mysql_tquery(Database, query);

		Text_Send(playerid, $ADMIN_OFFLINE_REMOVEACC, pName);

		new String[128];
		format(String, sizeof(String), "Administrator %s removed %s's account.", PlayerInfo[playerid][PlayerName], pName);
		MessageToAdmins(0x2281C8FF, String);

		format(query, sizeof(query), "Removed account for %s.", pName);
		LogAdminAction(playerid, query);
	}  else Text_Send(playerid, $ADMIN_FAILED_ACTION);    
	return 1;
}

public UpdatePlayerScore(playerid, score) {
	new pID, pName[MAX_PLAYER_NAME];

	if (cache_num_rows() > 0) {
		new rank;
		cache_get_value(0, "Username", pName, MAX_PLAYER_NAME);
		cache_get_value_int(0, "AdminLevel", rank);
		if (rank == svtconf[max_admin_level]
				|| rank >= PlayerInfo[playerid][pAdminLevel]) return Text_Send(playerid, $ADMIN_FAILED_ACTION); 
		cache_get_value_int(0, "ID", pID);

		new query[105];

		mysql_format(Database, query, sizeof(query), "UPDATE `PlayersData` SET `Score` = '%d' WHERE `pID` = '%d' LIMIT 1", score, pID);
		mysql_tquery(Database, query);

		Text_Send(playerid, $ADMIN_OFFLINE_SETSCORE, pName, score);

		new String[128];
		format(String, sizeof(String), "Administrator %s changed %s's score to %d.", PlayerInfo[playerid][PlayerName], pName, score);
		MessageToAdmins(0x2281C8FF, String);

		format(query, sizeof(query), "Changed score for %s to %d.", pName, score);
		LogAdminAction(playerid, query);
	}  else Text_Send(playerid, $ADMIN_FAILED_ACTION);    
	return 1;
}

public OfflineBan(playerid, nickname[], days, reason[]) {
	new query[450], String[140], IP[20];

	if (cache_num_rows() > 0) {
		new rank, bannedTimes;
		cache_get_value_int(0, "AdminLevel", rank);
		cache_get_value_int(0, "BannedTimes", bannedTimes);
		if (rank == svtconf[max_admin_level]
				|| rank >= PlayerInfo[playerid][pAdminLevel]) return Text_Send(playerid, $ADMIN_FAILED_ACTION);
		if ((days > 30) || (days <= 0 && days != -1)) return Text_Send(playerid, $ADMIN_BAN_DAYS);
	
		new converttime;
		
		if (days != -1)
			converttime = gettime() + (86400 * days);
		else
			converttime = -1;
	
		new pID, pName[MAX_PLAYER_NAME];

		cache_get_value_int(0, "ID", pID);
		cache_get_value(0, "Username", pName, MAX_PLAYER_NAME);
		cache_get_value(0, "IP", IP, 25);

		mysql_format(Database, query, sizeof (query), "UPDATE `Players` SET `IsBanned` = '1', `BannedTimes` = '%d' WHERE `Username` = '%e' LIMIT 1", bannedTimes + 1, nickname);
		mysql_tquery(Database, query);

		Text_Send(playerid, $ADMIN_OFFLINE_BAN, nickname, days, reason);

		format(String, sizeof(String), "Administrator %s offline banned %s for %d days for %s.", PlayerInfo[playerid][PlayerName], nickname, days, reason);
		MessageToAdmins(0x2281C8FF, String);

		mysql_format(Database, query, sizeof(query), "INSERT INTO `BansData` (`BannedName`, `AdminName`, `BanReason`, `ExpiryDate`, `BanDate`) VALUES ('%e', '%e', '%e', '%d', NOW())", pName, PlayerInfo[playerid][PlayerName], reason, converttime);
		mysql_tquery(Database, query);

		mysql_format(Database, query, sizeof(query), "INSERT INTO `BansHistoryData` (`BannedName`, `AdminName`, `BanReason`, `ExpiryDate`, `BanDate`) VALUES ('%e', '%e', '%e', '%d', NOW())", pName, PlayerInfo[playerid][PlayerName], reason, converttime);
		mysql_tquery(Database, query);

		format(query, sizeof(query), "Banned %s for %d days for %s.", nickname, days, reason);
		LogAdminAction(playerid, query);
	}
	return 1;
}

public UnbanPlayer(playerid, nickname[]) {
	new query[256], String[120];

	if (cache_num_rows() > 0) {
		new pID;
		cache_get_value_int(0, "ID", pID);
		mysql_format(Database, query, sizeof(query), "DELETE FROM `BansData` WHERE `BannedName` = '%e' LIMIT 1", nickname);
		mysql_tquery(Database, query);

		mysql_format(Database, query, sizeof(query), "SELECT * FROM `Players` WHERE `Username` = '%e' LIMIT 1", nickname);
		mysql_tquery(Database, query, "UnbanAddress", "is", playerid, nickname);

		Text_Send(playerid, $ADMIN_UNBAN, nickname);

		format(String, sizeof(String), "Administrator %s unbanned %s.", PlayerInfo[playerid][PlayerName], nickname);
		MessageToAdmins(0x2281C8FF, String);

		mysql_format(Database, query, sizeof(query), "INSERT INTO `Punishments` (PunishedPlayer, Punisher, Action, ActionReason, PunishmentTime, ActionDate) \
			VALUES ('%e', '%e', 'Unban', '', '', '%d')", nickname, PlayerInfo[playerid][PlayerName], gettime());
		mysql_tquery(Database, query);

		format(query, sizeof(query), "Revoked ban for player %s.", nickname);
		LogAdminAction(playerid, query);
	}  else Text_Send(playerid, $ADMIN_FAILED_ACTION);    
	return 1;
}

public UnbanAddress(playerid, nickname[]) {
	if (cache_num_rows() > 0) {
		new IP[16], String[140];
		cache_get_value(0, "IP", IP, 16);
		
		format(String, sizeof(String), "unbanip %s", IP);
		SendRconCommand(String);

		SendRconCommand("reloadbans");
		
		mysql_format(Database, String, sizeof (String), "UPDATE `Players` SET `IsBanned` = '0' WHERE `Username` = '%e' LIMIT 1", nickname);
		mysql_tquery(Database, String);

		format(String, sizeof(String), "Administrator %s unbanned account (%s) IP (%s).",
			PlayerInfo[playerid][PlayerName], nickname, IP);
		MessageToAdmins(0x2281C8FF, String);
		RangeUnban(IP);
		new query[160];
		format(query, sizeof(query), "Unbanned IP for player %s.", nickname);
		LogAdminAction(playerid, query);
	}
	return 1;
}

public UpdatePlayerKills(playerid, kills) {
	new pID, nickname[MAX_PLAYER_NAME];

	if (cache_num_rows() > 0) {
		cache_get_value_int(0, "ID", pID);
		cache_get_value(0, "Username", nickname, MAX_PLAYER_NAME);

		new query[450];

		mysql_format(Database, query, sizeof(query), "UPDATE `PlayersData` SET `Kills` = '%d' WHERE `pID` = '%d' LIMIT 1", kills, pID);
		mysql_tquery(Database, query);

		Text_Send(playerid, $ADMIN_OFFLINE_SETKILLS, nickname, kills);

		new String[128];
		format(String, sizeof(String), "Administrator %s changed %s's kills to %d.", PlayerInfo[playerid][PlayerName], nickname, kills);
		MessageToAdmins(0x2281C8FF, String);

		format(query, sizeof(query), "Updated kills for %s to %d.", nickname, kills);
		LogAdminAction(playerid, query);
	}  else Text_Send(playerid, $ADMIN_FAILED_ACTION);    
	return 1;
}

public UpdatePlayerCash(playerid, cash) {
	new pID, pName[MAX_PLAYER_NAME];

	if (cache_num_rows() > 0) {
		cache_get_value_int(0, "pID", pID);
		cache_get_value(0, "Username", pName, MAX_PLAYER_NAME);

		new query[450];

		mysql_format(Database, query, sizeof(query), "UPDATE `PlayersData` SET `Cash` = '%d' WHERE `pID` = '%d' LIMIT 1", cash, pID);
		mysql_tquery(Database, query);

		Text_Send(playerid, $ADMIN_OFFLINE_SETCASH, pName, cash);

		new String[128];
		format(String, sizeof(String), "Administrator %s changed %s's cash to $%d.", PlayerInfo[playerid][PlayerName], pName, cash);
		MessageToAdmins(0x2281C8FF, String);

		format(query, sizeof(query), "Updated cash for %s to %d.", pName, cash);
		LogAdminAction(playerid, query);
	}  else Text_Send(playerid, $ADMIN_FAILED_ACTION);    
	return 1;
}

public GetAKALogger(playerid) {
	if (cache_num_rows() > 0) {
		new IP[20], user[MAX_PLAYER_NAME];
		cache_get_value(0, "Username", user, MAX_PLAYER_NAME);
		cache_get_value(0, "IP", IP, 20);

		new query[160];
		mysql_format(Database, query, sizeof(query), "SELECT `IP`, `Username` FROM `Players` WHERE `IP` = '%e'", IP);
		mysql_tquery(Database, query, "AKASearch", "is", playerid, user);
	}  else Text_Send(playerid, $ADMIN_AKA_NOTFOUND);    
	return 1;
}

forward AKASearch(playerid, user[]);
public AKASearch(playerid, user[]) {
	new pName[MAX_PLAYER_NAME], IP[20];

	if (cache_num_rows() > 0) {
		new Result[128], count = 0;
		cache_get_value(0, "IP", IP, 20);

		for (new i = 0; i < cache_num_rows(); i++) {
			cache_get_value(i, "Username", pName, MAX_PLAYER_NAME);
			cache_get_value(i, "IP", IP, 20);

			if (strcmp(pName, user, true) && strfind(pName, Result, true) == -1) {
				if (count < 9) {
					strcat(Result, pName);
					strcat(Result, ", ");
					count ++;
				}
				else {
					Text_Send(playerid, $AKA_SEARCH, Result);
					format(Result, sizeof(Result), "");
					count = 0;
				}
			}
		}
		
		if (!count) {
			Text_Send(playerid, $CLIENT_143x, Result);
		}
		else {
			strdel(Result, strlen(Result) - 2, strlen(Result) - 1);
			Text_Send(playerid, $AKA_SEARCH, Result);
		}

	}  else Text_Send(playerid, $ADMIN_NOT_AKA);
	return 1;
}

public UpdatePlayerDeaths(playerid, deaths) {
	new pID, pName[MAX_PLAYER_NAME];

	if (cache_num_rows() > 0) {
		cache_get_value_int(0, "ID", pID);
		cache_get_value(0, "Username", pName, MAX_PLAYER_NAME);

		new query[450];

		mysql_format(Database, query, sizeof(query), "UPDATE `PlayersData` SET `Deaths` = '%d' WHERE `pID` = '%d' LIMIT 1", deaths, pID);
		mysql_tquery(Database, query);

		Text_Send(playerid, $ADMIN_OFFLINE_SETDEATHS, pName, deaths);

		new String[128];
		format(String, sizeof(String), "Administrator %s changed %s's deaths to %d.", PlayerInfo[playerid][PlayerName], pName, deaths);
		MessageToAdmins(0x2281C8FF, String);

		format(query, sizeof(query), "Updated deaths for %s to %d.", pName, deaths);
		LogAdminAction(playerid, query);
	}  else Text_Send(playerid, $ADMIN_FAILED_ACTION);
	return 1;
}

public UpdateAdminRank(playerid, al) {
	new pName[MAX_PLAYER_NAME];

	if (cache_num_rows() > 0) {
		new rank;
		cache_get_value_int(0, "AdminLevel", rank);
		if (rank == svtconf[max_admin_level]
				|| rank >= PlayerInfo[playerid][pAdminLevel]) return Text_Send(playerid, $ADMIN_FAILED_ACTION);
		cache_get_value(0, "Username", pName, MAX_PLAYER_NAME);

		new query[450];

		mysql_format(Database, query, sizeof(query), "UPDATE `Players` SET `AdminLevel` = '%d' WHERE `Username` = '%e' LIMIT 1", al, pName);
		mysql_tquery(Database, query);

		Text_Send(playerid, $ADMIN_OFFLINE_SETLEVEL, pName, al);

		new String[128];
		format(String, sizeof(String), "Administrator %s offline changed %s's account level to %d.", PlayerInfo[playerid][PlayerName], pName, al);
		MessageToAdmins(0x2281C8FF, String);

		format(query, sizeof(query), "Updated admin level for %s to %d.", pName, al);
		LogAdminAction(playerid, query);
	}  else Text_Send(playerid, $ADMIN_FAILED_ACTION);
	return 1;
}

public UpdateModeratorRank(playerid, al) {
	new pName[MAX_PLAYER_NAME];

	if (cache_num_rows() > 0) {
		new rank;
		cache_get_value_int(0, "AdminLevel", rank);
		if (rank == svtconf[max_admin_level]
				|| rank >= PlayerInfo[playerid][pAdminLevel]) return Text_Send(playerid, $ADMIN_FAILED_ACTION);
		cache_get_value(0, "Username", pName, MAX_PLAYER_NAME);

		new query[450];

		mysql_format(Database, query, sizeof(query), "UPDATE `Players` SET `IsModerator` = '%d' WHERE `Username` = '%e' LIMIT 1", al, pName);
		mysql_tquery(Database, query);

		Text_Send(playerid, $ADMIN_OFFLINE_SETHELPER, pName, al);

		new String[128];
		format(String, sizeof(String), "Administrator %s offline changed %s's moderator level to %d.", PlayerInfo[playerid][PlayerName], pName, al);
		MessageToAdmins(0x2281C8FF, String);

		format(query, sizeof(query), "Updated moderator status for %s to %d.", pName, al);
		LogAdminAction(playerid, query);
	}  else Text_Send(playerid, $ADMIN_FAILED_ACTION);
	return 1;
}

public UpdateDonorRank(playerid, dl) {
	new pName[MAX_PLAYER_NAME];

	if (cache_num_rows() > 0) {
		new rank;
		cache_get_value_int(0, "AdminLevel", rank);
		if (rank == svtconf[max_admin_level]
				|| rank >= PlayerInfo[playerid][pAdminLevel]) return Text_Send(playerid, $ADMIN_FAILED_ACTION);
		cache_get_value(0, "Username", pName, MAX_PLAYER_NAME);

		new query[450];

		mysql_format(Database, query, sizeof(query), "UPDATE `Players` SET `DonorLevel` = '%d' WHERE `Username` = '%e' LIMIT 1", dl, pName);
		mysql_tquery(Database, query);

		Text_Send(playerid, $ADMIN_OFFLINE_SETDONOR, pName, dl);

		new String[128];
		format(String, sizeof(String), "Administrator %s changed %s's donor level to %d.", PlayerInfo[playerid][PlayerName], pName, dl);
		MessageToAdmins(0x2281C8FF, String);

		format(query, sizeof(query), "Updated donor level for %s to %d.", pName, dl);
		LogAdminAction(playerid, query);
	}  else Text_Send(playerid, $ADMIN_FAILED_ACTION);
	return 1;
}

public CheckBansData(playerid) {
	if (cache_num_rows() > 0) {
		new query[400], days;
		cache_get_value_int(0, "ExpiryDate", days);

		if (days != -1) {
			if (gettime() > days) {
				if (pVerified[playerid]) {
					mysql_format(Database, query, sizeof(query), "UPDATE `Players` SET `IsBanned` = '0' WHERE `Username` = '%e' LIMIT 1", PlayerInfo[playerid][PlayerName]);
					mysql_tquery(Database, query);
				}

				mysql_format(Database, query, sizeof(query), "DELETE FROM `BansData` WHERE `BannedName` = '%e' LIMIT 1", PlayerInfo[playerid][PlayerName]);
				mysql_tquery(Database, query);

				new banString[125];

				format(banString, sizeof(banString), "[ADMIN] %s[%d] ban expired. (Address: %s)", PlayerInfo[playerid][PlayerName], playerid, PlayerInfo[playerid][pIP]);
				MessageToManagers(X11_RED2, banString);

				format(banString, sizeof(banString), "[ADMIN] %s[%d] ban expired.", PlayerInfo[playerid][PlayerName], playerid);
				MessageToAdmins(X11_RED2, banString);   

				Text_Send(playerid, $BAN_EXPIRED);
			} else {
				mysql_format(Database, query, sizeof(query), "UPDATE `Players` SET `IsBanned` = '1' WHERE `IP` = '%e' OR `Username` = '%e' LIMIT 1", PlayerInfo[playerid][pIP], PlayerInfo[playerid][PlayerName]);
				mysql_tquery(Database, query);

				Text_Send(playerid, $BANNED_PLAYER);
				SetTimerEx("ApplyBan", 500, false, "i", playerid);

				new AdminName[MAX_PLAYER_NAME], Reason[35], Days, Date[24];

				cache_get_value(0, "AdminName", AdminName, sizeof(AdminName));
				cache_get_value(0, "BanReason", Reason, sizeof(Reason));
				cache_get_value_int(0, "ExpiryDate", Days);
				cache_get_value(0, "BanDate", Date, sizeof(Date));

				new dialog[290], sub[60];

				format(sub, sizeof(sub), ""RED2"Nickname: "IVORY"%s\n", PlayerInfo[playerid][PlayerName]);
				strcat(dialog, sub);

				format(sub, sizeof(sub), ""RED2"Banning Administrator: "IVORY"%s\n", AdminName);
				strcat(dialog, sub);

				format(sub, sizeof(sub), ""RED2"Banned for "IVORY"%s\n", Reason);
				strcat(dialog, sub);

				new seconds = Days - gettime(), d, h, m, s;

				d = (seconds / 86400);
				h = (seconds / 60 / 60 % 60);
				m = (seconds / 60 % 60);
				s = (seconds % 60); 

				format(sub, sizeof(sub), ""RED2"Expiring In "IVORY"%d dy, %d hr, %d min, %d sec\n", d, h, m, s);
				strcat(dialog, sub);

				format(sub, sizeof(sub), ""RED2"Issued "IVORY"%s", Date);
				strcat(dialog, sub);

				Dialog_Show(playerid, DIALOG_STYLE_MSGBOX, ""RED2"You are banned", dialog, "X", "");

				new banString[125];

				format(banString, sizeof(banString), "[ADMIN] %s[%d] tried joining with an unexpired ban account. (Address: %s)", PlayerInfo[playerid][PlayerName], playerid, PlayerInfo[playerid][pIP]);
				MessageToManagers(X11_RED2, banString);        

				format(banString, sizeof(banString), "[ADMIN] %s[%d] tried joining with an unexpired ban account.", PlayerInfo[playerid][PlayerName], playerid);
				MessageToAdmins(X11_RED2, banString);              
			}
		} else {
			Text_Send(playerid, $PERMANENT_BAN);
			SetTimerEx("ApplyBan", 500, false, "i", playerid);

			new banString[125];
			format(banString, sizeof(banString), "[ADMIN] %s[%d] tried joining with a permanently banned account. (Address: %s)", PlayerInfo[playerid][PlayerName], playerid, PlayerInfo[playerid][pIP]);
			MessageToAdmins(X11_RED2, banString);
		}
	}
	else {
		new query[256];
		mysql_format(Database, query, sizeof(query), "SELECT * FROM `Players` WHERE `IsBanned` = '1' AND `IP` LIKE '%e'", GetPlayerIPRange(playerid));
		mysql_tquery(Database, query, "IPBanCheck", "i", playerid); 
	}
	return 1;
}

public GetLastSeen(playerid) {
	if (cache_num_rows() != 0) {
		new pName[MAX_PLAYER_NAME], lastvisit;
		cache_get_value(0, "Username", pName, MAX_PLAYER_NAME);
		cache_get_value_int(0, "LastVisit", lastvisit);

		Text_Send(playerid, $ADMIN_LASTSEEN, pName, GetWhen(lastvisit, gettime()));
	
		new query[110];
		format(query, sizeof(query), "Searched last seen time for %s.", pName);
		LogAdminAction(playerid, query);

	}  else Text_Send(playerid, $ADMIN_FAILED_ACTION); 
	return 1;
}

public IPBanCheck(playerid) {
	if (cache_num_rows() > 0) {
		new old_gpci[41], ip_addr[25];
		cache_get_value(0, "GPCI", old_gpci, sizeof(old_gpci));
		cache_get_value(0, "IP", ip_addr, sizeof(ip_addr));

		new current_gpci[41];
		gpci(playerid, current_gpci, sizeof(current_gpci));
		if (!isnull(old_gpci) && !strcmp(current_gpci, old_gpci, false)) {
			new query[250];

			mysql_format(Database, query, sizeof(query), "UPDATE `Players` SET `IsBanned` = '1',`IP` = '%e' WHERE `Username` = '%e' LIMIT 1", PlayerInfo[playerid][pIP], PlayerInfo[playerid][PlayerName]);
			mysql_tquery(Database, query);

			Text_Send(playerid, $RANGE_BANNED);
			SetTimerEx("DelayKick", 1000, false, "i", playerid);

			new banString[125];
			format(banString, sizeof(banString), "Warning:{E8E8E8} %s[%d] IP RANGE evasion detected. (Address: %s)", PlayerInfo[playerid][PlayerName], playerid, PlayerInfo[playerid][pIP]);
			MessageToAdmins(X11_RED2, banString);
		} else {
			new query[250];

			mysql_format(Database, query, sizeof(query), "UPDATE `Players` SET `IsBanned` = '1' WHERE `Username` = '%e' LIMIT 1", PlayerInfo[playerid][PlayerName]);
			mysql_tquery(Database, query);
			Text_Send(playerid, $IP_BANNED);
			SetTimerEx("DelayKick", 1000, false, "i", playerid);

			new banString[125];
			format(banString, sizeof(banString), "Warning:{E8E8E8} %s[%d] IP evasion detected. (Address: %s)", PlayerInfo[playerid][PlayerName], playerid, PlayerInfo[playerid][pIP]);
			MessageToAdmins(X11_RED2, banString); 
		}
	}
	return 1;
}

//Forbiddens

public OnWordForbid(playerid, word[]) {
	if (cache_num_rows() <= 0) {
		Text_Send(playerid, $NEWCLIENT_1x, word);

		new query[100];
		mysql_format(Database, query, sizeof(query), "INSERT INTO `ForbiddenList` (`Type`, `Text`) VALUES ('Word', '%e')", word);
		mysql_tquery(Database, query);     
	} else Text_Send(playerid, $NEWCLIENT_2x);    
	return 1;
}

public OnWordUnforbid(playerid, word[]) {
	if (cache_num_rows() > 0) {
		Text_Send(playerid, $NEWCLIENT_3x, word);

		new query[100];
		mysql_format(Database, query, sizeof(query), "DELETE FROM `ForbiddenList` WHERE `Type` = 'Word' AND `Text` = '%e'", word);
		mysql_tquery(Database, query);     
	} else Text_Send(playerid, $NEWCLIENT_4);    
	return 1;
}
public OnNameForbid(playerid, word[]) {
	if (cache_num_rows() <= 0) {
		Text_Send(playerid, $NEWCLIENT_5x, word);

		new query[100];
		mysql_format(Database, query, sizeof(query), "INSERT INTO `ForbiddenList` (`Type`, `Word`) VALUES ('Name', '%e')", word);
		mysql_tquery(Database, query);     
	} else Text_Send(playerid, $NEWCLIENT_6x);    
	return 1;
}

public OnNameUnforbid(playerid, name[]) {
	if (cache_num_rows() > 0) {
		Text_Send(playerid, $NEWCLIENT_7x, name);

		new query[100];
		mysql_format(Database, query, sizeof(query), "DELETE FROM `ForbiddenList` WHERE `Type` = 'Name' AND `Text` = '%e'", name);
		mysql_tquery(Database, query);     
	} else Text_Send(playerid, $NEWCLIENT_8x);    
	return 1;
}

public Unfreeze(targetid) {
	TogglePlayerControllable(targetid, true);

	KillTimer(FreezeTimer[targetid]);
	PlayerInfo[targetid][pFrozen] = 0;

	PlayerPlaySound(targetid, 1057, 0.0, 0.0, 0.0);    
	return 1;
}

public IsForbiddenName(playerid, nick[]) {
	if (cache_num_rows() != 0) {
		new part_name[MAX_PLAYER_NAME];

		for (new i, j = cache_num_rows(); i != j; i++) {
			cache_get_value(i, "Text", part_name, sizeof(part_name));
			if (strfind(PlayerInfo[playerid][PlayerName], part_name, true) != -1) {
				Text_Send(playerid, $CLIENT_144x, part_name);
				SetTimerEx("ApplyBan", 500, false, "i", playerid);

				Text_Send(@pVerified, $SERVER_34x, PlayerInfo[playerid][PlayerName]);
			}
		}
	}
	return 1;
}

public LoadForbiddenWords() {
	if (cache_num_rows() > 0) {
		new words;
		for (new i, j = cache_num_rows(); i != j; i++) {    
			if (words < MAX_FORBIDS) {
				new word[25];
				cache_get_value(i, "Text", word, 25);
				format(ForbiddenWords[words], 25, word);
			} 

			words ++;     
		} 
		printf("Loaded %d forbidden words from database.", words);
	}

	return 1;
}

public LoadForbiddenNames() {
	if (cache_num_rows() > 0) {
		new names;
		for (new i, j = cache_num_rows(); i != j; i++) {    
			if (names < MAX_FORBIDS) {
				new name[25];
				cache_get_value(i, "Text", name, 25);
				format(ForbiddenNames[names], 25, name);
			} 
			names ++;     
		} 
		printf("Loaded %d forbidden namees from database.", names);
	}

	return 1;
}

//
/*
		F U N C T I O N S!
*/
//

RandomSpectate(playerid) {
	new count = Iter_Count(Player);
	if (count < 2) {
		return StopSpectate(playerid);
	}

	new x = Iter_Random(Player);

	if (IsPlayerSpawned(x)) {
		StartSpectate(playerid, x);
	} else StopSpectate(playerid);
	return 1;
}

StartSpectate(playerid, specplayerid) {
	if (!PlayerInfo[playerid][pAdminLevel] && !PlayerInfo[playerid][pIsModerator]) return 0;
	SetPlayerInterior(playerid, GetPlayerInterior(specplayerid));
	SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(specplayerid));

	foreach (new x: Player) {
		if (GetPlayerState(x) == PLAYER_STATE_SPECTATING && PlayerInfo[x][pSpecId] == playerid) {
			RandomSpectate(x);
		}
	}

	TogglePlayerSpectating(playerid, true);

	if (IsPlayerInAnyVehicle(specplayerid)) {
		PlayerSpectateVehicle(playerid, GetPlayerVehicleID(specplayerid));
		PlayerInfo[playerid][pSpecId] = specplayerid;
		PlayerInfo[playerid][pSpecMode] = ADMIN_SPEC_TYPE_VEHICLE;
	}
	else
	{
		PlayerSpectatePlayer(playerid, specplayerid);
		PlayerInfo[playerid][pSpecId] = specplayerid;
		PlayerInfo[playerid][pSpecMode] = ADMIN_SPEC_TYPE_PLAYER;
	}

	new str[128];
	format(str, sizeof(str), "[ADMIN] Administrator %s began spectating %s[%d]", PlayerInfo[playerid][PlayerName], PlayerInfo[specplayerid][PlayerName], specplayerid);
	MessageToAdmins(0x2281C8FF, str);
	print(str);

	Text_Send(playerid, $CLIENT_155x);
	
	for (new i = 0; i < sizeof(aSpecTD); i++) {
		TextDrawShowForPlayer(playerid, aSpecTD[i]);
	}
	
	format(str, sizeof(str), "%s[%d]",
		PlayerInfo[specplayerid][PlayerName], specplayerid);

	PlayerTextDrawSetString(playerid, aSpecPTD[playerid][1], str);
	
	format(str, sizeof(str), "%s (%d)~n~Speed: %0.2f KM/H",
		ReturnWeaponName(GetPlayerWeapon(specplayerid)),
		 GetPlayerAmmo(specplayerid), GetPlayerSpeed(specplayerid));
		 
	PlayerTextDrawSetString(playerid, aSpecPTD[playerid][2], str);
	
	PlayerTextDrawSetPreviewModel(playerid, aSpecPTD[playerid][0], GetPlayerSkin(specplayerid));
	
	PlayerTextDrawShow(playerid, aSpecPTD[playerid][0]);
	PlayerTextDrawShow(playerid, aSpecPTD[playerid][1]);
	PlayerTextDrawShow(playerid, aSpecPTD[playerid][2]);

	SelectTextDraw(playerid, X11_DEEPPINK);
	UpdatePlayerHUD(playerid);
	return 1;
}

StopSpectate(playerid) {
	PlayerInfo[playerid][pSpecId] = INVALID_PLAYER_ID;
	PlayerInfo[playerid][pSpecMode] = ADMIN_SPEC_TYPE_NONE;
	
	CancelSelectTextDraw(playerid);
	TogglePlayerSpectating(playerid, false);
	
	for (new i = 0; i < sizeof(aSpecTD); i++) {
		TextDrawHideForPlayer(playerid, aSpecTD[i]);
	}
	
	PlayerTextDrawHide(playerid, aSpecPTD[playerid][0]);
	PlayerTextDrawHide(playerid, aSpecPTD[playerid][1]);
	PlayerTextDrawHide(playerid, aSpecPTD[playerid][2]);
	return 1;
}

//Admin panel
OnAdminClickPlayer(playerid, clickedplayerid) {
	if (PlayerInfo[playerid][pAdminLevel] >= 4) {
		pClickedID[playerid] = clickedplayerid;

		inline AdminClickPlayer(pid, dialogid, response, listitem, string:inputtext[]) {
			#pragma unused dialogid, inputtext, listitem
			if (!response) return pClickedID[pid] = INVALID_PLAYER_ID;
			if (pClickedID[pid] == INVALID_PLAYER_ID || !IsPlayerConnected(pClickedID[pid])) return Text_Send(pid, $CLIENT_156x);

			new command[10], full_cmd[50];

			if (strfind(inputtext, "!kick", true) != -1) {
				new reason[25];
				if (sscanf(inputtext, "s[10]s[25]", command, reason)) return ShowSyntax(playerid, "!kick [reason]");
				format(full_cmd, sizeof(full_cmd), "/kick %d %s", pClickedID[pid], reason); 
				return PC_EmulateCommand(pid, full_cmd);
			}  

			if (strfind(inputtext, "!warn", true) != -1) {
				new reason[25];
				if (sscanf(inputtext, "s[10]s[25]", command, reason)) return ShowSyntax(playerid, "!warn [reason]");
				format(full_cmd, sizeof(full_cmd), "/warn %d %s", pClickedID[pid], reason); 
				return PC_EmulateCommand(pid, full_cmd);
			}                   

			if (strfind(inputtext, "!ban", true) != -1) {
				new days, reason[25];
				if (sscanf(inputtext, "s[10]is[25]", command, days, reason)) return ShowSyntax(playerid, "!ban [days] [reason]");
				format(full_cmd, sizeof(full_cmd), "/ban %d %d %s", pClickedID[pid], days, reason); 
				return PC_EmulateCommand(pid, full_cmd);
			}

			if (strfind(inputtext, "!jail", true) != -1) {
				new minutes, reason[25];
				if (sscanf(inputtext, "s[10]is[25]", command, minutes, reason)) return ShowSyntax(playerid, "!jail [mins] [reason]");
				format(full_cmd, sizeof(full_cmd), "/jail %d %d %s", pClickedID[pid], minutes, reason); 
				return PC_EmulateCommand(pid, full_cmd);
			} 

			if (strfind(inputtext, "!unjail", true) != -1) {
				format(full_cmd, sizeof(full_cmd), "/unjail %d", pClickedID[pid]); 
				return PC_EmulateCommand(pid, full_cmd);
			}           

			if (strfind(inputtext, "!freeze", true) != -1) {
				new minutes, reason[25];
				if (sscanf(inputtext, "s[10]is[25]", command, minutes, reason)) return ShowSyntax(playerid, "!freeze [mins] [reason]");
				format(full_cmd, sizeof(full_cmd), "/freeze %d %d %s", pClickedID[pid], minutes, reason); 
				return PC_EmulateCommand(pid, full_cmd);
			}       

			if (strfind(inputtext, "!unfreeze", true) != -1) {
				format(full_cmd, sizeof(full_cmd), "/unfreeze %d", pClickedID[pid]); 
				return PC_EmulateCommand(pid, full_cmd);
			}           

			if (strfind(inputtext, "!mute", true) != -1) {
				new reason[25];
				if (sscanf(inputtext, "s[10]s[25]", command, reason)) return ShowSyntax(playerid, "!mute [reason]");
				format(full_cmd, sizeof(full_cmd), "/mute %d %s", pClickedID[pid], reason); 
				return PC_EmulateCommand(pid, full_cmd);
			}  

			if (strfind(inputtext, "!unmute", true) != -1) {
				format(full_cmd, sizeof(full_cmd), "/unmute %d", pClickedID[pid]); 
				return PC_EmulateCommand(pid, full_cmd);
			}                   

			if (strfind(inputtext, "!goto", true) != -1) {
				format(full_cmd, sizeof(full_cmd), "/goto %d", pClickedID[pid]); 
				return PC_EmulateCommand(pid, full_cmd);
			}      

			if (strfind(inputtext, "!get", true) != -1) {
				format(full_cmd, sizeof(full_cmd), "/get %d", pClickedID[pid]); 
				return PC_EmulateCommand(pid, full_cmd);
			}           

			if (strfind(inputtext, "!slap", true) != -1) {
				format(full_cmd, sizeof(full_cmd), "/slap %d", pClickedID[pid]); 
				return PC_EmulateCommand(pid, full_cmd);
			}    

			if (strfind(inputtext, "!burn", true) != -1) {
				format(full_cmd, sizeof(full_cmd), "/burn %d", pClickedID[pid]); 
				return PC_EmulateCommand(pid, full_cmd);
			}    

			if (strfind(inputtext, "!aka", true) != -1) {
				format(full_cmd, sizeof(full_cmd), "/aka %d", pClickedID[pid]); 
				return PC_EmulateCommand(pid, full_cmd);
			}           

			if (strfind(inputtext, "!spec", true) != -1) {
				format(full_cmd, sizeof(full_cmd), "/spec %d", pClickedID[pid]); 
				return PC_EmulateCommand(pid, full_cmd);
			}  

			if (strfind(inputtext, "!crash", true) != -1) {
				format(full_cmd, sizeof(full_cmd), "/crash %d", pClickedID[pid]); 
				return PC_EmulateCommand(pid, full_cmd);
			}   

			if (strfind(inputtext, "!setlevel", true) != -1) {
				new lvl;
				if (sscanf(inputtext, "s[10]i", command, lvl)) return ShowSyntax(playerid, "!setlevel [level]");
				format(full_cmd, sizeof(full_cmd), "/setlevel %d %d", pClickedID[pid], lvl); 
				return PC_EmulateCommand(pid, full_cmd);
			}   

			if (strfind(inputtext, "!setvip", true) != -1) {
				new lvl;
				if (sscanf(inputtext, "s[10]i", command, lvl)) return ShowSyntax(playerid, "!setvip [level]");
				format(full_cmd, sizeof(full_cmd), "/setvip %d %d", pClickedID[pid], lvl); 
				return PC_EmulateCommand(pid, full_cmd);
			}                           

			if (strfind(inputtext, "!explode", true) != -1) {
				format(full_cmd, sizeof(full_cmd), "/explode %d", pClickedID[pid]); 
				return PC_EmulateCommand(pid, full_cmd);
			}    

			if (strfind(inputtext, "!eject", true) != -1) {
				format(full_cmd, sizeof(full_cmd), "/eject %d", pClickedID[pid]); 
				return PC_EmulateCommand(pid, full_cmd);
			}   

			if (strfind(inputtext, "!apm", true) != -1) {
				new message[90];
				if (sscanf(inputtext, "s[10]s[90]", command, message)) return ShowSyntax(playerid, "!apm [message]");
				format(full_cmd, sizeof(full_cmd), "/apm %d %s", pClickedID[pid], message); 
				return PC_EmulateCommand(pid, full_cmd);
			}          

			if (strfind(inputtext, "!answer", true) != -1) {
				new message[90];
				if (sscanf(inputtext, "s[10]s[90]", command, message)) return ShowSyntax(playerid, "!answer [message]");
				format(full_cmd, sizeof(full_cmd), "/answer %d %s", pClickedID[pid], message); 
				return PC_EmulateCommand(pid, full_cmd);
			}                           

			if (strfind(inputtext, "!teleplayer", true) != -1) {
				new target;
				if (sscanf(inputtext, "s[10]i", command, target)) return ShowSyntax(playerid, "!teleplayer [target]");
				format(full_cmd, sizeof(full_cmd), "/teleplayer %d %d", pClickedID[pid], target); 
				return PC_EmulateCommand(pid, full_cmd);
			}                                                               

			Text_Send(pid, $ADMIN_PANEL_INVALID);
		}
		Text_DialogBox(playerid, DIALOG_STYLE_INPUT, using inline AdminClickPlayer, $ADMIN_CLICK_PLAYER_CAP, $ADMIN_CLICK_PLAYER_DESC, $ADMIN_CLICK_PLAYER_1ST, $ADMIN_CLICK_PLAYER_2ND, PlayerInfo[clickedplayerid][PlayerName]);
	}   
	return 1;
}

//Clear reports
ClearReportsData(playerid) {
	for (new i = 0; i < MAX_REPORTS; i++) {
		if (ReportInfo[i][R_FROM_ID] == playerid) {
			ReportInfo[i][R_FROM_ID] = INVALID_PLAYER_ID;
		} else if (ReportInfo[i][R_AGAINST_ID] == playerid) {
			ReportInfo[i][R_AGAINST_ID] = INVALID_PLAYER_ID;
		}
	}
	return 1;
}

//Jail system

JailPlayer(targetid) {
	SetPlayerVirtualWorld(targetid, JAIL_WORLD);
	TogglePlayerControllable(targetid, true);
	SetPlayerPos(targetid, 197.6661, 173.8179, 1003.0234);
	SetPlayerInterior(targetid, 3);
	SetCameraBehindPlayer(targetid);
	JailTimer[targetid] = SetTimerEx("JailRelease", PlayerInfo[targetid][pJailTime], false, "d", targetid);
	PlayerInfo[targetid][pJailed] = 1;
	printf("Player %d was jailed.", targetid);
	return 1;
}

JailRelease(targetid) {
	KillTimer(JailTimer[targetid]);
	PlayerInfo[targetid][pJailTime] = 0;
	PlayerInfo[targetid][pJailed] = 0;
	SetPlayerInterior(targetid, 0);
	SetPlayerVirtualWorld(targetid, BF_WORLD);
	SetPlayerPos(targetid, 0.0, 0.0, 0.0);
	SpawnPlayer(targetid);
	PlayerPlaySound(targetid, 1057, 0.0, 0.0, 0.0);
	Text_Send(targetid, $JAIL_RELEASED);
	printf("Player %d was released.", targetid);
	return 1;
}

//Range Handling

GetPlayerIPRange(playerid) {
	new overall_ip[25], wildcards;
	
	new IP[25];
	format(IP, 25, PlayerInfo[playerid][pIP]);
	for(new i = 0; i < strlen(IP); i++) {
		if (IP[i] == '.') wildcards++;
		if (wildcards == 2) {
			strdel(IP, i + 1, strlen(IP));
			format(overall_ip, sizeof(overall_ip), "%s", IP);
			break;
		}
	}
	return overall_ip;
}

RangeBan(playerid) {
	new overall_ip[25], string[27], wildcards;
	
	new IP[25];
	format(IP, 25, PlayerInfo[playerid][pIP]);
	for(new i = 0; i < strlen(IP); i++) {
		if (IP[i] == '.') wildcards++;
		if (wildcards == 2) {
			strdel(IP, i + 1, strlen(IP));
			format(overall_ip, sizeof(overall_ip), "%s*.*", IP);
			break;
		}
	}
	format(string, sizeof(string), "banip %s", overall_ip);
	SendRconCommand(string);
	return 1;
}

RangeUnban(IP[16]) {
	new overall_ip[16], string[27], wildcards;
	for(new i = 0; i < strlen(IP); i++) {
		if (IP[i] == '.') wildcards++;
		if (wildcards == 2) {
			strdel(IP, i + 1, strlen(IP));
			format(overall_ip, sizeof(overall_ip), "%s*.*", IP);
			break;
		}
	}
	format(string, sizeof(string), "unbanip %s", overall_ip);
	SendRconCommand(string);    
	return 1;
}

//Send a message to any level +1 administrator
MessageToAdmins(color, const String[]) {
	foreach (new i: Player) {
		if (PlayerInfo[i][pAdminLevel] >= 1) SendClientMessage(i, color, String);
	}

	print(String);

	new DCC_Channel:StaffChannel;
	StaffChannel = DCC_FindChannelByName(CHANNEL_STAFF_NAME);
	DCC_SendChannelMessage(StaffChannel, String);
	return 1;
}

//Send a message to any level +1 administrator excluding one player
MessageToAdminsEx(playerid, color, const String[]) {
	foreach (new i: Player) {
		if (PlayerInfo[i][pAdminLevel] >= 1 && i != playerid) SendClientMessage(i, color, String);
	}

	print(String);

	new DCC_Channel:StaffChannel;
	StaffChannel = DCC_FindChannelByName(CHANNEL_STAFF_NAME);
	DCC_SendChannelMessage(StaffChannel, String);
	return 1;
}

//Send a message to any level +1 administrator and not discord
MessageToAdminsEx2(color, const String[]) {
	foreach (new i: Player) {
		if (PlayerInfo[i][pAdminLevel] >= 1) SendClientMessage(i, color, String);
	}

	print(String);
	return 1;
}

//Send a message to managers only
MessageToManagers(color, const String[]) {
  foreach (new i: Player) {
	if (PlayerInfo[i][pAdminLevel] >= 5) {
	  SendClientMessage(i, color, String);
	}
  }

  print(String);  
  return 1;
}

//Send a private message to all the administrators
SendAdminPM(sender, receiver, const Message[]) {
	foreach (new i: Player) if (PlayerInfo[i][pAdminLevel] > 1) {
		if (PlayerInfo[sender][pAdminLevel] <= PlayerInfo[i][pAdminLevel] && PlayerInfo[receiver][pAdminLevel] <= PlayerInfo[i][pAdminLevel]) {
			Text_Send(i, $ADMIN_PM, PlayerInfo[sender][PlayerName], sender, PlayerInfo[receiver][PlayerName], receiver, Message);
		}
	}       
	return 1;
}

//Send admin command message to other administrators
SendAdminCommand(playerid, command[], params[]) {
	if (svtconf[read_admin_cmds] == 1 && PlayerInfo[playerid][pAdminLevel]) {
		if (PlayerInfo[playerid][pAdminLevel] < svtconf[max_admin_level] - 1) {
			foreach (new i: Player) {
				if (PlayerInfo[i][pAdminLevel] >= PlayerInfo[playerid][pAdminLevel]) {
					Text_Send(i, $ADMIN_CMD, PlayerInfo[playerid][PlayerName], playerid, command, params);
				}
			}
		}
	}   
	return 1;
}

//Count how long the administrator played in a session
CountAdminPlaytime(playerid) {
	new seconds = (gettime() - PlayerInfo[playerid][pPlayTick]);

	new d = (seconds / 86400);
	new h = (seconds / 3600);
	new m = (seconds / 60 % 60);
	new s = (seconds % 60);

	new query[100];
	format(query, sizeof(query), "Left the server after playing for %dd, %dh, %dm, %ds.", d, h, m, s);
	LogAdminAction(playerid, query);
	return 1;
}

//
/*
		H O O K S!
*/
//

hook OnRconLoginAttempt(ip[], password[], success) {
	if (!success) {
		foreach (new i: Player) {
			if (!strcmp(PlayerInfo[i][pIP], ip) && !isnull(PlayerInfo[i][pIP])) {
				PlayerInfo[i][pRCONFailedAttempts] ++;
			}
		}
		return BlockIpAddress(ip, 60 * 100000);
	}

	foreach (new i: Player) {
		if (!strcmp(PlayerInfo[i][pIP], ip) && !isnull(PlayerInfo[i][pIP])) {
			PlayerInfo[i][pRCONLogins] ++;
		}
	}
	return 1;
}

//Reset
hook OnPlayerConnect(playerid) {
	pIsAdmin[playerid] = false;
	PlayerInfo[playerid][pAdminDuty] = 0;
	PlayerInfo[playerid][pDonorLevel] = 0;
	PlayerInfo[playerid][pAdminLevel] = 0;
	return 1;
}

//Count admin play time
hook OnPlayerDisconnect(playerid, reason) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		CountAdminPlaytime(playerid);
	}

	//Ensure that the admin system is properly reset
	PlayerInfo[playerid][pJailed] = 0;
	PlayerInfo[playerid][pFrozen] = 0;

	//Update spectator mode if this player was being spectated by an admin
	foreach (new x: Player) {
		if (GetPlayerState(x) == PLAYER_STATE_SPECTATING && PlayerInfo[x][pSpecId] == playerid) {
			if (PlayerInfo[x][pAdminLevel]) {
				RandomSpectate(x);
			} else {
				StopSpectate(x);
			}
		}
	}
	return 1;
}

hook OnPlayerSpawn(playerid) {
	//Update administrators whom are spectating this player
	foreach (new x: Player) {
		if (IsPlayerConnected(x) && GetPlayerState(x) == PLAYER_STATE_SPECTATING) {
			if (PlayerInfo[x][pSpecId] == playerid && PlayerInfo[x][pAdminLevel]) {
				PlayerSpectatePlayer(x, playerid);
				NotifyPlayer(x, "Player respawned...");
			} 
			if (PlayerInfo[x][pSpecId] == playerid && !PlayerInfo[x][pAdminLevel]) {
				PlayerInfo[x][pSpecId] = INVALID_PLAYER_ID;
				TogglePlayerSpectating(x, false);
			}
		}
	}

	//Reset spectator mode if this player was spectating
	if (PlayerInfo[playerid][pSpecId] != INVALID_PLAYER_ID) {
		PlayerInfo[playerid][pSpecId] = INVALID_PLAYER_ID;
		PlayerInfo[playerid][pSpecMode] = ADMIN_SPEC_TYPE_NONE;
	}

	//Was on duty?
	if (PlayerInfo[playerid][pAdminDuty]) {
		UpdateLabelText(playerid);
		SetPlayerColor(playerid, 0xFF00FFFF);
		SetPlayerSkin(playerid, 217);

		SetPlayerHealth(playerid, 100.0);
		SetPlayerArmour(playerid, 100.0);

		GivePlayerWeapon(playerid, 38, 9999);
	}
	return 1;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
	//If the admin wants to spectate a random player, why not let him be?
	if (PRESSED(KEY_WALK)) {
		if (GetPlayerState(playerid) == PLAYER_STATE_SPECTATING) {
			if (PlayerInfo[playerid][pAdminLevel]) {
				RandomSpectate(playerid);
			}
		}
	}
	return 1;
}

hook OnVehDamageStatusUpdate(vehicleid, playerid) {
	if (PlayerInfo[playerid][pAdminDuty]) { //Admins' on duty's cars' shouldn't be damaged, right?
		new panels, doors, lights, tires;
		GetVehicleDamageStatus(vehicleid, panels, doors, lights, tires);

		tires = 0;
		doors = 0;
		lights = 0;
		panels = 0;

		UpdateVehicleDamageStatus(vehicleid, panels, doors, lights, tires);
		SetVehicleHealth(vehicleid, 10000.0);
	}
	return 1;
}

//Spectator mode
hook OnPlayerStateChange(playerid, newstate, oldstate) {
	foreach (new x: Player) {
		if (GetPlayerState(x) == PLAYER_STATE_SPECTATING && PlayerInfo[x][pSpecId] == playerid) {
			if ((!PlayerInfo[x][pAdminLevel] && !PlayerInfo[x][pIsModerator])) {
				StopSpectate(x);
			} else {
				SetPlayerInterior(x, GetPlayerInterior(playerid));
				SetPlayerVirtualWorld(x, GetPlayerVirtualWorld(playerid));
			
				if (newstate == PLAYER_STATE_ONFOOT) {
					TogglePlayerSpectating(x, 1);
					PlayerSpectatePlayer(x, playerid);
					PlayerInfo[x][pSpecMode] = ADMIN_SPEC_TYPE_PLAYER;
				}
				
				if (newstate == PLAYER_STATE_DRIVER || newstate == PLAYER_STATE_PASSENGER) {
					TogglePlayerSpectating(x, 1);
					PlayerSpectateVehicle(x, GetPlayerVehicleID(playerid));
					PlayerInfo[x][pSpecMode] = ADMIN_SPEC_TYPE_VEHICLE;
				}
			}
		}
	}
	return 1;
}

//Map teleport
hook OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ) {
	if (PlayerInfo[playerid][pAdminLevel] >= 5 && PlayerInfo[playerid][pAdminDuty]) {
		new Float: Convert_Pos_Z;
		CA_FindZ_For2DCoord(fX, fY, Convert_Pos_Z);
		SetPlayerPos(playerid, fX, fY, Convert_Pos_Z);
	} 
	return 1;
}

//Include admin panel on clicking a player
hook OnPlayerClickPlayer(playerid, clickedplayerid, source) {
	OnAdminClickPlayer(playerid, clickedplayerid);
	return 1;
}

hook OnPlayerClickTD(playerid, Text:clickedid) {
	if (clickedid == aSpecTD[1]) {
		StopSpectate(playerid);
		return 1;
	}
	
	if (clickedid == aSpecTD[4]) {
		new count = Iter_Count(Player);
		if (count < 2) {
			return StopSpectate(playerid);
		}

		new x = PlayerInfo[playerid][pSpecId] - 1;
		if (x < 0) x = Iter_Count(Player);

		if (IsPlayerConnected(x)) {
			StartSpectate(playerid, x);
		} else StopSpectate(playerid);
		return 1;
	}
	
	if (clickedid == aSpecTD[5]) {
		new count = Iter_Count(Player);
		if (count < 2) {
			return StopSpectate(playerid);
		}

		new x = PlayerInfo[playerid][pSpecId] + 1;
		if (x >= MAX_PLAYERS) x = 0;

		if (IsPlayerConnected(x)) {
			StartSpectate(playerid, x);
		} else StopSpectate(playerid);
		return 1;
	}
	
	if (clickedid == aSpecTD[7]) {
		new cmd[15];
		format(cmd, sizeof(cmd), "/weaps %d", PlayerInfo[playerid][pSpecId]);
		PC_EmulateCommand(playerid, cmd);
		return 1;
	}
	
	if (clickedid == aSpecTD[8]) {
		new cmd[15];
		format(cmd, sizeof(cmd), "/items %d", PlayerInfo[playerid][pSpecId]);
		PC_EmulateCommand(playerid, cmd);
		return 1;
	}
	
	if (clickedid == aSpecTD[9]) {
		new cmd[15];
		format(cmd, sizeof(cmd), "/bstats %d", PlayerInfo[playerid][pSpecId]);
		PC_EmulateCommand(playerid, cmd);
		return 1;
	}
	
	if (clickedid == aSpecTD[10]) {
		new cmd[15];
		format(cmd, sizeof(cmd), "/getinfo %d", PlayerInfo[playerid][pSpecId]);
		PC_EmulateCommand(playerid, cmd);
		return 1;
	}
	
	if (clickedid == aSpecTD[11]) {
		OnAdminClickPlayer(playerid, PlayerInfo[playerid][pSpecId]);
		return 1;
	}
	return 1;
}

/*
	Team management commands
*/

flags:gteam(CMD_ADMIN);
alias:gteam("getteam");
CMD:gteam(playerid, params[]) {
	new team[35], Float:x, Float:y, Float:z, interior = GetPlayerInterior(playerid), world = GetPlayerVirtualWorld(playerid);
	if (sscanf(params, "s[35]", team)) return ShowSyntax(playerid, "/getteam [team name]");
	GetPlayerPos(playerid, x, y, z);

	for (new a = 0; a < sizeof(TeamInfo); a++) {
		if (!strcmp(team, TeamInfo[a][Team_Name], true)) {
			foreach (new i: Player) {
				if (pTeam[i] == a
						&& !GetPlayerInterior(i) && !GetPlayerVirtualWorld(i) && IsPlayerSpawned(i)) {
					SetPlayerPos(i, x + 2, y, z);
					SetPlayerInterior(i, interior);
					SetPlayerVirtualWorld(i, world);
					TogglePlayerControllable(i, false);
					PlayerInfo[i][pFrozen] = 1;
				}
			}
		}
	}

	Text_Send(@pVerified, $NEWSERVER_3x, PlayerInfo[playerid][PlayerName], team);
	LogAdminAction(playerid, "Teleported a team.");
	return 1;
}

flags:steam(CMD_ADMIN);
alias:steam("spawnteam");
CMD:steam(playerid, params[]) {
	new team[35];
	if (sscanf(params, "s[35]", team)) return ShowSyntax(playerid, "/spawnteam [team name]");

	for (new x = 0; x < sizeof(TeamInfo); x++) {
		if (!strcmp(team, TeamInfo[x][Team_Name], true)) {
			foreach (new i: Player) {
				if (pTeam[i] == x && IsPlayerSpawned(i)
						&& !GetPlayerInterior(i) && !GetPlayerVirtualWorld(i)) {
					SpawnPlayer(i);
				}
			}
		}
	}

	Text_Send(@pVerified, $NEWSERVER_4x, PlayerInfo[playerid][PlayerName], team);
	LogAdminAction(playerid, "Spawned a team.");
	return 1;
}

flags:fteam(CMD_ADMIN);
alias:fteam("freezeteam");
CMD:fteam(playerid, params[]) {
	new team[20];
	if (sscanf(params, "s[20]", team)) return ShowSyntax(playerid, "/freezeteam [team name]");

	for (new x = 0; x < sizeof(TeamInfo); x++) {
		if (!strcmp(team, TeamInfo[x][Team_Name], true)) {
			foreach (new i: Player) {
				if (pTeam[i] == x
						&& !GetPlayerInterior(i) && !GetPlayerVirtualWorld(i) && IsPlayerSpawned(i)) {
					TogglePlayerControllable(i, false);
					PlayerInfo[i][pFrozen] = 1;
				}
			}
		}
	}

	Text_Send(@pVerified, $NEWSERVER_5x, PlayerInfo[playerid][PlayerName], team);
	LogAdminAction(playerid, "Froze a team.");
	return 1;
}

flags:ufteam(CMD_ADMIN);
alias:ufteam("unfreezeteam");
CMD:ufteam(playerid, params[]) {
	new team[20];
	if (sscanf(params, "s[20]", team)) return ShowSyntax(playerid, "/unfreezeteam [team name]");

	for (new x = 0; x < sizeof(TeamInfo); x++) {
		if (!strcmp(team, TeamInfo[x][Team_Name], true)) {
			foreach (new i: Player) {
				if (pTeam[i] == x
						&& !GetPlayerInterior(i) && !GetPlayerVirtualWorld(i) && IsPlayerSpawned(i)) {
					TogglePlayerControllable(i, true);
					PlayerInfo[i][pFrozen] = 0;
				}
			}
		}
	}

	Text_Send(@pVerified, $NEWSERVER_6x, PlayerInfo[playerid][PlayerName], team);
	LogAdminAction(playerid, "Unfroze a team.");
	return 1;
}

flags:dteam(CMD_ADMIN);
alias:dteam("disarmteam");
CMD:dteam(playerid, params[]) {
	new team[20];
	if (sscanf(params, "s[20]", team)) return ShowSyntax(playerid, "/disarmteam [team name]");

	for (new x = 0; x < sizeof(TeamInfo); x++) {
		if (!strcmp(team, TeamInfo[x][Team_Name], true)) {
			foreach (new i: Player) {
				 if (pTeam[i] == x
						&& !GetPlayerInterior(i) && !GetPlayerVirtualWorld(i) && IsPlayerSpawned(i)) {
					 ResetPlayerWeapons(i);
				 }
			}
		}
	}

	Text_Send(@pVerified, $NEWSERVER_7x, PlayerInfo[playerid][PlayerName], team);
	LogAdminAction(playerid, "Disarmed a team.");
	return 1;
}

flags:gsteam(CMD_ADMIN);
CMD:gsteam(playerid, params[]) {
	new team[20], amount;
	if (sscanf(params, "s[20]d", team, amount)) return ShowSyntax(playerid, "/gsteam [team name] [score amount]");

	for (new x = 0; x < sizeof(TeamInfo); x++) {
		if (!strcmp(team, TeamInfo[x][Team_Name], true)) {
			foreach (new i: Player) {
				if (pTeam[i] == x
						&& !GetPlayerInterior(i) && !GetPlayerVirtualWorld(i) && IsPlayerSpawned(i)) {
					GivePlayerScore(i, amount);
					PlayerPlaySound(i, 1057, 0.0, 0.0, 0.0);
				}
			}
		}
	}

	Text_Send(@pVerified, $NEWSERVER_8x, PlayerInfo[playerid][PlayerName], team);
	LogAdminAction(playerid, "Gave score to a team.");
	printf("Admin %s gave team %s a score %d points.", PlayerInfo[playerid][PlayerName], team, amount);
	return 1;
}

flags:gcteam(CMD_ADMIN);
CMD:gcteam(playerid, params[]) {
	new team[20], amount;
	if (sscanf(params, "s[20]d", team, amount)) return ShowSyntax(playerid, "/gcteam [team name] [cash amount]");

	for (new x = 0; x < sizeof(TeamInfo); x++) {
		if (!strcmp(team, TeamInfo[x][Team_Name], true)) {
			foreach (new i: Player) {
				if (pTeam[i] == x
						&& !GetPlayerInterior(i) && !GetPlayerVirtualWorld(i) && IsPlayerSpawned(i)) {
				   GivePlayerCash(i, amount);
				   PlayerPlaySound(i, 1057, 0.0, 0.0, 0.0);
				}
			}
		}
	}

	Text_Send(@pVerified, $NEWSERVER_9x, PlayerInfo[playerid][PlayerName], team);
	LogAdminAction(playerid, "Gave cash to a team.");
	printf("Admin %s gave team %s cash worth $%d.", PlayerInfo[playerid][PlayerName], team, amount);
	return 1;
}

flags:gwteam(CMD_ADMIN);
CMD:gwteam(playerid, params[]) {
	new team[20], weap, ammo;
	if (sscanf(params, "s[20]dd", team, weap, ammo)) return ShowSyntax(playerid, "/gwteam [team name] [weapon id] [ammo]");

	for (new x = 0; x < sizeof(TeamInfo); x++) {
		if (!strcmp(team, TeamInfo[x][Team_Name], true)) {
			foreach (new i: Player) {
				if (pTeam[i] == x
						&& !GetPlayerInterior(i) && !GetPlayerVirtualWorld(i) && IsPlayerSpawned(i)) {
				   GivePlayerWeapon(i, weap, ammo);
				   PlayerPlaySound(i, 1057, 0.0, 0.0, 0.0);
				}
			}
		}
	}

	Text_Send(@pVerified, $NEWSERVER_10x, PlayerInfo[playerid][PlayerName], team, weap, ammo);
	LogAdminAction(playerid, "Gave weapon to a team.");
	printf("Admin %s gave team %s a weapon, id %d with %d ammo.", PlayerInfo[playerid][PlayerName], team, weap, ammo);
	return 1;
}

flags:forceteam(CMD_ADMIN);
CMD:forceteam(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new targetid;
		if (sscanf(params, "u", targetid)) return ShowSyntax(playerid, "/forceteam [playerid/name]");
		if (PlayerInfo[targetid][pAdminLevel] == svtconf[max_admin_level] && PlayerInfo[playerid][pAdminLevel] < svtconf[max_admin_level] - 1) return Text_Send(playerid, $CLIENT_362x);

		if (IsPlayerSpawned(targetid) && targetid != INVALID_PLAYER_ID) {
			ForceClassSelection(targetid);
			DamagePlayer(targetid, 0.0, INVALID_PLAYER_ID, 255, BODY_PART_UNKNOWN, true);
			
			new message[120];

			format(message, sizeof(message), "Forced player %s into team selection.", PlayerInfo[targetid][PlayerName]);
			LogAdminAction(playerid, message);
			
		}  else Text_Send(playerid, $NEWCLIENT_193x);
	}
	return 1;
}

flags:force(CMD_ADMIN);
CMD:force(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new targetid;

		if (sscanf(params, "i", targetid)) return ShowSyntax(playerid, "/force [playerid]");
		if (PlayerInfo[targetid][pAdminLevel] == svtconf[max_admin_level] && PlayerInfo[playerid][pAdminLevel] < svtconf[max_admin_level] - 1) return Text_Send(playerid, $CLIENT_362x);
		if (IsPlayerSpawned(targetid) && targetid != INVALID_PLAYER_ID) {			
			ForceClassSelection(targetid);
			DamagePlayer(targetid, 0.0, INVALID_PLAYER_ID, 255, BODY_PART_UNKNOWN, true);
			PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);

			new String[128];
			format(String, sizeof(String), "Administrator %s forced %s into team selection.", PlayerInfo[playerid][PlayerName], PlayerInfo[targetid][PlayerName]);
			MessageToAdmins(0x2281C8FF, String);

			new query[120];
			format(query, sizeof(query), "Forced %s into team selection.", PlayerInfo[targetid][PlayerName]);
			LogAdminAction(playerid, query);			
		}  else Text_Send(playerid, $NEWCLIENT_193x);
	}
	return 1;
}

//Team war commands

flags:teamwar(CMD_ADMIN);
CMD:teamwar(playerid) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		if (WarInfo[War_Started] == 1) return Text_Send(playerid, $CLIENT_433x);

		new dialogstr[290];
		format(dialogstr, sizeof(dialogstr), "First team: %s\nSecond team: %s\nWar Time: %d Secs\nStart",
		TeamInfo[WarInfo[War_Team1]][Team_Name], TeamInfo[WarInfo[War_Team2]][Team_Name], WarInfo[War_Time]);

		inline TeamWarTeam1(pid, dialogid, response, listitem, string:inputtext[]) {
			#pragma unused dialogid, inputtext
			if (!response) return PC_EmulateCommand(pid, "/teamwar");
			WarInfo[War_Team1] = listitem;
			PC_EmulateCommand(pid, "/teamwar");
		}

		inline TeamWarTeam2(pid, dialogid, response, listitem, string:inputtext[]) {
			#pragma unused dialogid, inputtext
			if (!response) return PC_EmulateCommand(pid, "/teamwar");
			WarInfo[War_Team2] = listitem;
			PC_EmulateCommand(pid, "/teamwar");
		}

		inline TeamWarWarTime(pid, dialogid, response, listitem, string:inputtext[]) {
			#pragma unused dialogid, inputtext, listitem
			if (!response) return PC_EmulateCommand(pid, "/teamwar");
		 
			new time;
			if (sscanf(inputtext, "d", time)) return ShowSyntax(playerid, "Team war time: 100-2000 secs");
			if (time > 2000 || time < 100) return ShowSyntax(playerid, "Team war time: 100-2000 secs");

			WarInfo[War_Time] = time;

			PC_EmulateCommand(pid, "/teamwar");
		}

		inline TeamWar(pid, dialogid, response, listitem, string:inputtext[]) {
			#pragma unused dialogid, inputtext
			if (!response) return 1;

			switch (listitem) {
				case 0: {
					new sub_str[20], full_str[100];

					for (new i = 0; i < sizeof(TeamInfo); i++) {
						format(sub_str, sizeof(sub_str), "%s\n", TeamInfo[i][Team_Name]);
						strcat(full_str, sub_str);
					}

					Dialog_ShowCallback(pid, using inline TeamWarTeam1, DIALOG_STYLE_LIST, "Select Team 1:", full_str, ">>", "<<");
				}
				case 1: {
					new sub_str[20], full_str[100];

					for (new i = 0; i < sizeof(TeamInfo); i++) {
						format(sub_str, sizeof(sub_str), "%s\n", TeamInfo[i][Team_Name]);
						strcat(full_str, sub_str);
					}

					Dialog_ShowCallback(pid, using inline TeamWarTeam2, DIALOG_STYLE_LIST, "Select Team 2:", full_str, ">>", "<<");
				}
				case 2: {
					Dialog_ShowCallback(pid, using inline TeamWarWarTime, DIALOG_STYLE_INPUT, "Input Time", "Please input the team war time.\n\n\
					{E8E8E8}Minimum: {0099FF}100Sec\n\
					{E8E8E8}Maximum: {0099FF}2000Sec", ">>", "<<");
				}
				case 3: {
					if (WarInfo[War_Started] == 1) return Text_Send(pid, $CLIENT_420x);
					if (WarInfo[War_Time] == 0) return Text_Send(pid, $CLIENT_420x);
					if (WarInfo[War_Team1] == WarInfo[War_Team2]) return ShowSyntax(playerid, "Team war teams matching.");

					WarInfo[Team1_Score] = 0;
					WarInfo[Team2_Score] = 0;

					war_time = WarInfo[War_Time] + gettime();
					WarInfo[War_Started] = 1;

					new war_str[130];
					format(war_str, sizeof(war_str), "%s%s (%d)~w~ VS %s[%d] %s~n~~w~Winner: %s%s", TeamInfo[WarInfo[War_Team1]][Chat_Bub], TeamInfo[WarInfo[War_Team1]][Team_Name],
					WarInfo[Team1_Score], TeamInfo[WarInfo[War_Team2]][Chat_Bub], WarInfo[Team2_Score], TeamInfo[WarInfo[War_Team2]][Team_Name]);

					TextDrawSetString(War_TD, war_str);
					foreach (new i: Player) {
						if (IsPlayerSpawned(i)) {
							UpdatePlayerHUD(i);
						}
					}
					new String[128];
					format(String, sizeof(String), "Administrator %s started a team war.", PlayerInfo[playerid][PlayerName]);
					MessageToAdmins(0x2281C8FF, String);

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
		}

		Dialog_ShowCallback(playerid, using inline TeamWar, DIALOG_STYLE_LIST, ""RED2"SvT - Team War", dialogstr, ">>", "X");
	}   
	return 1;
}

flags:endwar(CMD_ADMIN);
CMD:endwar(playerid) {
	if (PlayerInfo[playerid][pAdminLevel]) {  
		if (WarInfo[War_Started] == 0) return Text_Send(playerid, $CLIENT_420x);

		WarInfo[War_Started] = 0;
		TextDrawHideForAll(War_TD);
		TextDrawHideForAll(War_TDBox);

		new String[128];
		format(String, sizeof(String), "Administrator %s ended a team war.", PlayerInfo[playerid][PlayerName]);
		MessageToAdmins(0x2281C8FF, String);
	}   
	return 1;
}

//General commands

flags:miniguns(CMD_ADMIN);
CMD:miniguns(playerid) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new bool:First2 = false, carty, String[140], slot, weap, ammo;

		foreach (new i: Player) {
			for (slot = 0; slot < 13; slot++) {
				GetPlayerWeaponData(i, slot, weap, ammo);

				if (ammo != 0 && weap == 38) {
					carty++;

					if (!First2) {
						format(String, sizeof(String), "Minigun: [%d]%s Ammo - %d", i, PlayerInfo[i][PlayerName], ammo);
						First2 = true;
					} else {
						format(String, sizeof(String), "%s, [%d]%s Ammo - %d", String, i, PlayerInfo[i][PlayerName], ammo);
					}
				}
			}
		}

		if (carty == 0) return Text_Send(playerid, $CLIENT_418x);
		SendClientMessage(playerid, 0xFFFFFFFF, String);
		print(String);
	}
	return 1;
}

flags:hseeks(CMD_ADMIN);
CMD:hseeks(playerid) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new bool:First2 = false, carty, String[140], slot, weap, ammo;

		foreach (new i: Player) {
			for (slot = 0; slot < 13; slot++) {
				GetPlayerWeaponData(i, slot, weap, ammo);
				if (ammo != 0 && weap == 36) {
					carty++;
					if (!First2) {
						format(String, sizeof(String), "Heat Seeker: [%d]%s Ammo - %d", i, PlayerInfo[i][PlayerName], ammo);
						First2 = true;
					}
					else
					{
						format(String, sizeof(String), "%s, [%d]%s Ammo - %d", String, i, PlayerInfo[i][PlayerName], ammo);
					}
				}
			}
		}

		if (carty == 0) return Text_Send(playerid, $CLIENT_419x);
		SendClientMessage(playerid, 0xFFFFFFFF, String);
		print(String);
	}
	return 1;
}

flags:rheal(CMD_ADMIN);
CMD:rheal(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new Float:x, Float:y, Float:z;
		GetPlayerPos(playerid, x, y, z);

		foreach (new i: Player) {
			if (IsPlayerInRangeOfPoint(i, 10.0, x, y, z)) {
				SetPlayerHealth(playerid, 100.0);
				SetPlayerArmour(playerid, 100.0);
			}
		}
	}    
	return 1;
}

flags:spec(CMD_ADMIN | CMD_MOD);
CMD:spec(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel] || PlayerInfo[playerid][pIsModerator]) {
		new specplayerid;
		if (sscanf(params, "u", specplayerid)) return ShowSyntax(playerid, "/spec [playerid/name]");
		if (!IsPlayerConnected(specplayerid) || specplayerid == INVALID_PLAYER_ID)  return Text_Send(playerid, $CLIENT_320x);

		if (PlayerInfo[specplayerid][pAdminLevel] == svtconf[max_admin_level] && PlayerInfo[playerid][pAdminLevel] < svtconf[max_admin_level] - 1) return Text_Send(playerid, $CLIENT_362x);
		if (specplayerid == playerid || (GetPlayerState(specplayerid) == PLAYER_STATE_SPECTATING && PlayerInfo[specplayerid][pSpecId] != INVALID_PLAYER_ID) ||
			(GetPlayerState(specplayerid) != 1 && GetPlayerState(specplayerid) != 2 && GetPlayerState(specplayerid) != 3)) return Text_Send(playerid, $CLIENT_420x);
	
		if (!ForceSync[playerid]) {
			StoreData(playerid);
		}   
		StartSpectate(playerid, specplayerid);

		new query[64];
		format(query, sizeof(query), "Started spectating %s.", PlayerInfo[specplayerid][PlayerName]);
		LogAdminAction(playerid, query);
	}
	return 1;
}

flags:specoff(CMD_ADMIN | CMD_MOD);
CMD:specoff(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel] || PlayerInfo[playerid][pIsModerator]) {
		if (PlayerInfo[playerid][pSpecMode] != ADMIN_SPEC_TYPE_NONE) {
			StopSpectate(playerid);
		}  else Text_Send(playerid, $CLIENT_420x);
	}
	return 1;
}

flags:cc(CMD_ADMIN);
CMD:cc(playerid) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		for (new i = 0; i < 21; i++) {
			SendClientMessageToAll(X11_LIMEGREEN, " ");
		}
		LogAdminAction(playerid, "Cleared chat.");
	}    
	return 1;
}

flags:saveallstats(CMD_ADMIN);
CMD:saveallstats(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		SaveAllStats();
		Text_Send(@pVerified, $NEWSERVER_11x);
	}
	return 1;
}

flags:specs(CMD_ADMIN);
CMD:specs(playerid) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new sub_holder[120], string[800], count = 0;

		strcat(string, "Spectator\n");

		foreach (new i: Player) {
			if (GetPlayerState(i) == PLAYER_STATE_SPECTATING) {
				if (PlayerInfo[i][pAdminLevel] >= 1 && IsPlayerConnected(PlayerInfo[i][pSpecId])) {
					format(sub_holder, sizeof(sub_holder), "%s is watching %s (/spec)\n", PlayerInfo[i][PlayerName], PlayerInfo[PlayerInfo[i][pSpecId]][PlayerName]);
				} else {
					if ((Iter_Contains(CWCLAN1, i) || Iter_Contains(CWCLAN2, i)) && PlayerInfo[i][pClanWarSpec]) {
						format(sub_holder, sizeof(sub_holder), "%s is watching %s (for clan war)\n", PlayerInfo[i][PlayerName], PlayerInfo[PlayerInfo[i][pClanWarSpecId]][PlayerName]);
					} else {
						format(sub_holder, sizeof(sub_holder), "%s is watching unknown (possibly cheating)\n", PlayerInfo[i][PlayerName]);
					}   
				}
				strcat(string, sub_holder);
				count = 1;
			}
		}

		if (count) {
			Dialog_Show(playerid, DIALOG_STYLE_MSGBOX, "Spectators", string, "X", "");
		}  else Text_Send(playerid, $CLIENT_421x);
	}
	return 1;
}

flags:forcerules(CMD_ADMIN);
CMD:forcerules(playerid, params[]) {
	new targetid;
	if (sscanf(params, "u", targetid)) return ShowSyntax(playerid, "/forcerules [player]");
	if (!IsPlayerConnected(targetid) || targetid == INVALID_PLAYER_ID || targetid == playerid) return Text_Send(playerid, $CLIENT_319x);
	return PC_EmulateCommand(targetid, "/rules");
}

flags:mcmds(CMD_MOD | CMD_ADMIN);
CMD:mcmds(playerid) {
	if (PlayerInfo[playerid][pAdminLevel] || PlayerInfo[playerid][pIsModerator]) {
		SendClientMessage(playerid, X11_IVORY, "");
		SendClientMessage(playerid, 0x2281C8FF, "Moderator Commands");
		SendClientMessage(playerid, 0x2281C8FF, "/spec /specoff /warn /kick /weaps");
		SendClientMessage(playerid, 0x2281C8FF, "/ip /m [moderator chat] /slap /reports /answer");
		SendClientMessage(playerid, X11_IVORY, "");
	}    
	return 1;
}

flags:m(CMD_MOD | CMD_ADMIN);
CMD:m(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel] || PlayerInfo[playerid][pIsModerator]) {
		new String[150];
		format(String, sizeof(String), "[Moderator Chat] %s[%d]: %s", PlayerInfo[playerid][PlayerName], playerid, params);
		foreach (new i: Player) {
			if (PlayerInfo[i][pAdminLevel] >= 1 || PlayerInfo[i][pIsModerator]) SendClientMessage(i, 0x881FDEFF, String);
		}
		print(String);
	}
	return 1;   
}

flags:acmds(CMD_ADMIN);
CMD:acmds(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new level;
		if (sscanf(params, "i", level)) return ShowSyntax(playerid, "/acmds [admin level]");
		if (level < 1 || level > svtconf[max_admin_level]) return Text_Send(playerid, $CLIENT_420x);
		if (level > PlayerInfo[playerid][pAdminLevel]) return Text_Send(playerid, $CLIENT_362x);

		new string[400], aRank[40];
		switch (level) {
			case 1: aRank = "Trial Admin"; 
			case 2: aRank = "Senior Admin"; 
			case 3: aRank = "Lead Admin"; 
			case 4: aRank = "Head Admin"; 
			case 5: aRank = "Assistant Manager"; 
			case 6: aRank = "Manager"; 
			case 7: aRank = "Lead Manager"; 
			case 8: aRank = "CEO";
		}
		format(string, sizeof(string), "%s [%d] ", aRank, level);
			
		new count;
		for (new x = 0; x < sizeof(ACmds); x++) {
			if (ACmds[x][Adm_Level] == level) {
				if (count < 8) {
					strcat(string, ACmds[x][Adm_Command]);
					strcat(string, ", ");
					count ++;
				} else {
					SendClientMessage(playerid, X11_GRAY, string);
					format(string, sizeof(string), "");
					count = 0;
				}
			}
		}

		if (!isnull(string)) {
			strdel(string, strlen(string) - 2, strlen(string) - 1);
			SendClientMessage(playerid, X11_GRAY, string);
		}
	}
	return 1;
}

flags:reports(CMD_ADMIN | CMD_MOD);
CMD:reports(playerid) {
	if (PlayerInfo[playerid][pAdminLevel] || PlayerInfo[playerid][pIsModerator]) {
		new dialog[1000], count = 0;
		dialog[0] = EOS;

		format(dialog, sizeof(dialog), "Status\tReported\tReporter\n");

		for (new i = 0; i < MAX_REPORTS; i++) {
			if (ReportInfo[i][R_VALID]) {
				if (ReportInfo[i][R_READ] == 1) {
					format(dialog, sizeof (dialog), "%s{0099FF}Checked\t{AC3069}%s\t%s\t%s\n", dialog, ReportInfo[i][R_AGAINST_NAME], ReportInfo[i][R_FROM_NAME]);
				}
				else {
					format(dialog, sizeof (dialog), "%s{FF0000}Unchecked\t{AC3069}%s\t%s\t%s\n", dialog, ReportInfo[i][R_AGAINST_NAME], ReportInfo[i][R_FROM_NAME]);
				}

				count ++;
			}
		}

		if (count == 0) return Text_Send(playerid, $CLIENT_423x);

		inline ReportStatus(pid, dialogid, response, listitem, string:inputtext[]) {
			#pragma unused dialogid, inputtext, listitem
			if (response) {
				if (!strcmp(inputtext, "erase", true)) {
					if (ReportInfo[GetPVarInt(pid, "DialogListitem")][R_VALID] == false) return DeletePVar(pid, "DialogListitem");
					ReportInfo[GetPVarInt(pid, "DialogListitem")][R_VALID] = false;
					DeletePVar(pid, "DialogListitem");
					return 1;
				}

				if (!strcmp(inputtext, "panel", true)) {
					if (IsPlayerConnected(ReportInfo[GetPVarInt(pid, "DialogListitem")][R_AGAINST_ID]) && ReportInfo[GetPVarInt(pid, "DialogListitem")][R_AGAINST_ID] != INVALID_PLAYER_ID) {
						if (PlayerInfo[pid][pAdminLevel]) {
							pClickedID[pid] = ReportInfo[GetPVarInt(pid, "DialogListitem")][R_AGAINST_ID];
							OnAdminClickPlayer(pid, ReportInfo[GetPVarInt(pid, "DialogListitem")][R_AGAINST_ID]);
							return 1;              
						}       
					}
				}

				if (!strcmp(inputtext, "kick", true)) {
					if (IsPlayerConnected(ReportInfo[GetPVarInt(pid, "DialogListitem")][R_AGAINST_ID]) && ReportInfo[GetPVarInt(pid, "DialogListitem")][R_AGAINST_ID] != INVALID_PLAYER_ID) {
							
						Text_Send(@pVerified, $NEWSERVER_41x, PlayerInfo[ReportInfo[GetPVarInt(pid, "DialogListitem")][R_AGAINST_ID]][PlayerName], ReportInfo[GetPVarInt(pid, "DialogListitem")][R_REASON]);
						SetTimerEx("ApplyBan", 500, false, "i", ReportInfo[GetPVarInt(pid, "DialogListitem")][R_AGAINST_ID]);

						new query[256];

						mysql_format(Database, query, sizeof(query), "INSERT INTO `Punishments` (PunishedPlayer, Punisher, Action, ActionReason, PunishmentTime, ActionDate) \
							VALUES ('%e', '%e', 'Kick', '%e', '', '%d')", PlayerInfo[ReportInfo[GetPVarInt(pid, "DialogListitem")][R_AGAINST_ID]][PlayerName], 
							PlayerInfo[pid][PlayerName], ReportInfo[GetPVarInt(pid, "DialogListitem")][R_REASON], gettime());
						mysql_tquery(Database, query);

						DeletePVar(pid, "DialogListitem");
						return 1;
					}
				}
				
				if (!strcmp(inputtext, "aka", true)) {
					if (IsPlayerConnected(ReportInfo[GetPVarInt(pid, "DialogListitem")][R_AGAINST_ID]) && ReportInfo[GetPVarInt(pid, "DialogListitem")][R_AGAINST_ID] != INVALID_PLAYER_ID) {
						new params[75];
						format(params, sizeof(params), "/aka %d", ReportInfo[GetPVarInt(pid, "DialogListitem")][R_AGAINST_ID]);
						DeletePVar(pid, "DialogListitem");
						PC_EmulateCommand(pid, params);
						return 1;
					}
				}
				
				if (!strcmp(inputtext, "ban", true)) {
					if (IsPlayerConnected(ReportInfo[GetPVarInt(pid, "DialogListitem")][R_AGAINST_ID]) && ReportInfo[GetPVarInt(pid, "DialogListitem")][R_AGAINST_ID] != INVALID_PLAYER_ID) {
						new params[100];
						format(params, sizeof(params), "/ban %d %s", ReportInfo[GetPVarInt(pid, "DialogListitem")][R_AGAINST_ID], ReportInfo[GetPVarInt(pid, "DialogListitem")][R_REASON]);
						DeletePVar(pid, "DialogListitem");
						PC_EmulateCommand(pid, params);
						return 1;
					}
				}
				
				if (!strcmp(inputtext, "spec", true)) {                       
					if (IsPlayerConnected(ReportInfo[GetPVarInt(pid, "DialogListitem")][R_AGAINST_ID]) && ReportInfo[GetPVarInt(pid, "DialogListitem")][R_AGAINST_ID] != INVALID_PLAYER_ID) {
						if (ReportInfo[GetPVarInt(pid, "DialogListitem")][R_CHECKED] == true) {
							ReportInfo[GetPVarInt(pid, "DialogListitem")][R_CHECKED] = false;

							PlayerReportChecked[pid][GetPVarInt(pid, "DialogListitem")] = true;
							ReportInfo[GetPVarInt(pid, "DialogListitem")][R_READ] = 1;
						}

						new specpid = ReportInfo[GetPVarInt(pid, "DialogListitem")][R_AGAINST_ID];

						if (PlayerInfo[specpid][pAdminLevel] == svtconf[max_admin_level] && PlayerInfo[pid][pAdminLevel] < svtconf[max_admin_level]) return Text_Send(pid, $CLIENT_362x);
						if (!IsPlayerConnected(specpid) || specpid == INVALID_PLAYER_ID)  return Text_Send(pid, $CLIENT_320x);

						if (specpid == pid) return Text_Send(pid, $NEWCLIENT_193x);

						if (GetPlayerState(specpid) == PLAYER_STATE_SPECTATING && PlayerInfo[specpid][pSpecId] != INVALID_PLAYER_ID) return Text_Send(pid, $NEWCLIENT_193x);
						if (GetPlayerState(specpid) != 1 && GetPlayerState(specpid) != 2 && GetPlayerState(specpid) != 3) return Text_Send(pid, $NEWCLIENT_194x);

						StartSpectate(pid, specpid);
						DeletePVar(pid, "DialogListitem");
						return 1;
					}
				}

				Text_Send(pid, $CLIENT_420x);
				DeletePVar(pid, "DialogListitem");
				PC_EmulateCommand(pid, "/reports");
			}
		}

		inline ReportsList(pid, dialogid, response, listitem, string:inputtext[]) {
			#pragma unused dialogid, inputtext
			if (response) {
				new string[500];

				format(string, sizeof (string), ""DEEPSKYBLUE"Issued{E8E8E8} %s\n\n"DEEPSKYBLUE"Complainer:{E8E8E8} %s[%d]\n"DEEPSKYBLUE"Target:{E8E8E8} %s[%d]\n\n"DEEPSKYBLUE"Reason:{E8E8E8} %s\n\n{AACC99}Actions: erase, spec, kick, aka, ban, panel",
					GetWhen(ReportInfo[listitem][R_TIMESTAMP], gettime()), ReportInfo[listitem][R_FROM_NAME], ReportInfo[listitem][R_FROM_ID], ReportInfo[listitem][R_AGAINST_NAME], ReportInfo[listitem][R_AGAINST_ID], ReportInfo[listitem][R_REASON], ReportInfo[listitem][R_AGAINST_NAME], ReportInfo[listitem][R_AGAINST_NAME], ReportInfo[listitem][R_AGAINST_NAME], ReportInfo[listitem][R_AGAINST_NAME]);

				Dialog_ShowCallback(pid, using inline ReportStatus, DIALOG_STYLE_INPUT, "Report Status", string, "Proceed", "<<");
				SetPVarInt(pid, "DialogListitem", listitem);
			}
		}

		Dialog_ShowCallback(playerid, using inline ReportsList, DIALOG_STYLE_TABLIST_HEADERS, "Reports", dialog, ">>", "X");

	}
	return 1;
}

flags:offlineban(CMD_ADMIN);
CMD:offlineban(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new
			nickname[MAX_PLAYER_NAME], days, reason[25];
		if (sscanf(params, "s[24]ds[25]", nickname, days, reason)) return ShowSyntax(playerid, "/offlineban [name] [days] [reason]");

		new
			query[450];

		mysql_format(Database, query, sizeof(query), "SELECT * FROM `Players` WHERE `Username` = '%e' LIMIT 1", nickname);
		mysql_tquery(Database, query, "OfflineBan", "dsds", playerid, nickname, days, reason);
	}
	return 1;
}

flags:unban(CMD_ADMIN);
CMD:unban(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new
			nickname[MAX_PLAYER_NAME];
		if (sscanf(params, "s[24]", nickname)) return ShowSyntax(playerid, "/unban [nickname]");

		new
			query[450];

		mysql_format(Database, query, sizeof(query), "SELECT * FROM `BansData` WHERE `BannedName` = '%e' LIMIT 1", nickname);
		mysql_tquery(Database, query, "UnbanPlayer", "ds", playerid, nickname);
	}    
	return 1;
}

flags:customweapons(CMD_ADMIN);
CMD:customweapons(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new id;
		if (sscanf(params, "d", id)) return ShowSyntax(playerid, "/cweapweapons [playerid]");
		if (!IsPlayerConnected(id) || id == INVALID_PLAYER_ID) return Text_Send(playerid, $NEWCLIENT_193x);

		if (PlayerRank[id] >= 6) {
			Text_Send(playerid, $LIST_CUSTOM_WEAPS, PlayerInfo[id][PlayerName], ReturnWeaponName(WeaponInfo[PlayerInfo[id][pFavWeap]][Weapon_Id]), ReturnWeaponName(WeaponInfo[PlayerInfo[id][pFavWeap2]][Weapon_Id]), ReturnWeaponName(WeaponInfo[PlayerInfo[id][pFavWeap3]][Weapon_Id]));

			new query[160];
			format(query, sizeof(query), "Viewed custom weapons for %s.", PlayerInfo[id][PlayerName]);
			LogAdminAction(playerid, query);
		}  else Text_Send(playerid, $CLIENT_423x);
	}
	return 1;
}

flags:pufa(CMD_ADMIN);
CMD:pufa(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		if (isnull(params)) return ShowSyntax(playerid, "/pufa [URL]");

		foreach(new i:Player) {
			PlayAudioStreamForPlayer(i, params, 0.0, 0.0, 0.0, 0.0, 0);
		}   

		Text_Send(@pVerified, $NEWSERVER_42x, PlayerInfo[playerid][PlayerName]);

		new query[160];
		format(query, sizeof(query), "Played music for all, URL: %s", params);
		LogAdminAction(playerid, query);
	}
	return 1;
}

flags:sufa(CMD_ADMIN);
CMD:sufa(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		foreach(new i:Player) {
			StopAudioStreamForPlayer(i);
		}   

		Text_Send(@pVerified, $NEWSERVER_12x, PlayerInfo[playerid][PlayerName]);
		LogAdminAction(playerid, "Stopped playing music from URL.");
	}
	return 1;
}

flags:forbidword(CMD_ADMIN);
CMD:forbidword(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel] == svtconf[max_admin_level]) {
		if (isnull(params)) return ShowSyntax(playerid, "/forbidword [word ]");
		if (strlen(params) > 24 || strlen(params) < 3) return Text_Send(playerid, $CLIENT_422x);

		new query[130];
		mysql_format(Database, query, sizeof(query), "SELECT * FROM `ForbiddenList` WHERE `Type` = 'Word' AND `Text` = '%e'", params);
		mysql_tquery(Database, query, "OnWordForbid", "is", playerid, params);
	}
	return 1;
}

flags:unforbidword(CMD_ADMIN);
CMD:unforbidword(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel] == svtconf[max_admin_level]) {
		if (isnull(params)) return ShowSyntax(playerid, "/unforbidword [word]");
		if (strlen(params) > 24 || strlen(params) < 3) return Text_Send(playerid, $CLIENT_422x);

		new query[130];
		mysql_format(Database, query, sizeof(query), "SELECT * FROM `ForbiddenList` WHERE `Type` = 'Word' AND `Text` = '%e'", params);
		mysql_tquery(Database, query, "OnWordUnforbid", "is", playerid, params);
	}
	return 1;
}

flags:forbidname(CMD_ADMIN);
CMD:forbidname(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel] == svtconf[max_admin_level]) {
		if (isnull(params)) return ShowSyntax(playerid, "/forbinname [name]");
		if (strlen(params) > 24 || strlen(params) < 3) return Text_Send(playerid, $CLIENT_422x);

		new query[130];
		mysql_format(Database, query, sizeof(query), "SELECT * FROM `ForbiddenList` WHERE Type = 'Name' AND `Text` = '%e'", params);
		mysql_tquery(Database, query, "OnNameForbid", "is", playerid, params);
	}
	return 1;
}

flags:unforbidname(CMD_ADMIN);
CMD:unforbidname(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel] == svtconf[max_admin_level]) {
		if (isnull(params)) return ShowSyntax(playerid, "/unforbidname [name]");
		if (strlen(params) > 24 || strlen(params) < 3) return Text_Send(playerid, $CLIENT_422x);

		new query[130];
		mysql_format(Database, query, sizeof(query), "SELECT * FROM `ForbiddenList` WHERE `Type` = 'Name' AND `Text` = '%e'", params);
		mysql_tquery(Database, query, "OnNameUnforbid", "is", playerid, params);
	}
	return 1;
}

flags:banip(CMD_ADMIN);
CMD:banip(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		if (!AdCheck(params)) return ShowSyntax(playerid, "/banip [valid ip address]");
		new String[100];

		format(String, sizeof(String), "banip %s", params);
		SendRconCommand(String);

		format(String, sizeof(String), "Administrator %s[%d] banned IP %s.", PlayerInfo[playerid][PlayerName], playerid, params);
		MessageToAdmins(0x2281C8FF, String);

		mysql_format(Database, String, sizeof (String), "UPDATE `Players` SET `IsBanned` = '1' WHERE `IP` = '%e' LIMIT 1", params);
		mysql_tquery(Database, String);

		new query[160];
		format(query, sizeof(query), "Banned IP %s.", params);
		LogAdminAction(playerid, query);
	}
	return 1;
}

flags:unbanip(CMD_ADMIN);
CMD:unbanip(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		if (!AdCheck(params)) return ShowSyntax(playerid, "/unbanip [valid ip address]");
		new String[100];
		format(String, sizeof(String), "unbanip %s", params);
		SendRconCommand(String);

		format(String, sizeof(String), "Administrator %s[%d] unbanned IP %s.", PlayerInfo[playerid][PlayerName], playerid, params);
		MessageToAdmins(0x2281C8FF, String);

		mysql_format(Database, String, sizeof (String), "UPDATE `Players` SET `IsBanned` = '0' WHERE `IP` = '%e' LIMIT 1", params);
		mysql_tquery(Database, String);

		new query[160];
		format(query, sizeof(query), "Unbanned IP %s.", params);
		LogAdminAction(playerid, query);
	}
	return 1;
}

flags:ban(CMD_ADMIN);
CMD:ban(playerid, params[]) {
	if (PlayerInfo[playerid][pLoggedIn]) {
		if (PlayerInfo[playerid][pAdminLevel]) {
			new targetid, reasonid, reason[25], playername[MAX_PLAYER_NAME], String[140],
			query[300], days, converttime;

			if (sscanf(params, "ui", targetid, reasonid)) {

				ShowSyntax(playerid, "/ban [playerid/name] [reason id]");
				SendClientMessage(playerid, X11_RED2, "1: Cheating - 2: Breaking rules - 3: Ban evasion - 4: Rude behavior");
				SendClientMessage(playerid, X11_RED2, "5: Bug abusing - 6: Repeated disobeying - 7: Harming players");
				SendClientMessage(playerid, X11_RED2, "8: Disrespectful attitude - 9: Repeated cheating");
				return 1;
			}

			if (reasonid > 9 || reasonid < 1) return ShowSyntax(playerid, "/ban [playerid/name] [reason id]");
			switch (reasonid) {
				case 1: format(reason, sizeof(reason), "Cheating"), days = 7;
				case 2: format(reason, sizeof(reason), "Breaking rules"), days = 14;
				case 3: format(reason, sizeof(reason), "Ban evasion"), days = -1;
				case 4: format(reason, sizeof(reason), "Rude behavior"), days = 3;
				case 5: format(reason, sizeof(reason), "Bug abusing"), days = 14;
				case 6: format(reason, sizeof(reason), "Repeated disobeying"), days = 14;
				case 7: format(reason, sizeof(reason), "Harming players"), days = 30;
				case 8: format(reason, sizeof(reason), "Disrespectful attitude"), days = 7;
				case 9: format(reason, sizeof(reason), "Repeated cheating"), days = 365;
			}

			if (IsPlayerConnected(targetid) && targetid != INVALID_PLAYER_ID && targetid != playerid) {
				if (PlayerInfo[targetid][pAdminLevel] == svtconf[max_admin_level] && PlayerInfo[playerid][pAdminLevel] < PlayerInfo[targetid][pAdminLevel])
					return Text_Send(playerid, $CLIENT_362x);

				if (PlayerInfo[targetid][pAdminLevel] > PlayerInfo[playerid][pAdminLevel]) return Text_Send(playerid, $CLIENT_321x);

				GetPlayerName(targetid, playername, sizeof(playername));

				new year, month, day, hour, minute, second;

				getdate(year, month, day);
				gettime(hour, minute, second);

				if (days != -1)
					converttime = gettime() + (86400 * days);
				else
					converttime = -1;

				mysql_format(Database, query, sizeof(query), "INSERT INTO `BansData` (`BannedName`, `AdminName`, `BanReason`, `ExpiryDate`, `BanDate`) VALUES ('%e', '%e', '%e', '%d', NOW())", PlayerInfo[targetid][PlayerName], PlayerInfo[playerid][PlayerName], reason, converttime);
				mysql_tquery(Database, query);

				mysql_format(Database, query, sizeof(query), "INSERT INTO `BansHistoryData` (`BannedName`, `AdminName`, `BanReason`, `ExpiryDate`, `BanDate`) VALUES ('%e', '%e', '%e', '%d', NOW())", PlayerInfo[targetid][PlayerName], PlayerInfo[playerid][PlayerName], reason, converttime);
				mysql_tquery(Database, query);

				new fullString[500];

				Text_Send(@pVerified, $NEWSERVER_43x, PlayerInfo[playerid][PlayerName], playername, reason);

				new DCC_Channel:StaffChannel;
				format(String, sizeof (String), "Staff %s has banned %s for %s.", PlayerInfo[playerid][PlayerName], PlayerInfo[targetid][PlayerName], reason);
				StaffChannel = DCC_FindChannelByName(CHANNEL_STAFF_NAME);
				DCC_SendChannelMessage(StaffChannel, String);

				new pgpci[41];
				gpci(targetid, pgpci, sizeof(pgpci));
				if (pVerified[targetid]) {
					mysql_format(Database, query, sizeof query, "UPDATE `Players` SET IsBanned = '1', GPCI = '%e', IP = '%e' WHERE `Username` = '%e' LIMIT 1", pgpci, PlayerInfo[targetid][pIP], playername);
					mysql_tquery(Database, query);
				}

				format(String, sizeof(String), ""RED2"Your name: "IVORY"%s\n", PlayerInfo[targetid][PlayerName]);
				strcat(fullString, String);

				format(String, sizeof(String), ""RED2"Banning Administrator: "IVORY"%s\n", PlayerInfo[playerid][PlayerName]);
				strcat(fullString, String);

				if (days != -1) {
					format(String, sizeof(String), ""RED2"Duration: "IVORY"%d days\n", days);
					strcat(fullString, String);
				} else {
					strcat(fullString, ""RED2"Duration: "IVORY"Not Expiring\n");
				}

				format(String, sizeof(String), ""RED2"Ban Reason: "IVORY"%s\n", reason);
				strcat(fullString, String);

				format(String, sizeof(String), ""RED2"Date and Time: "IVORY"%d/%d/%d %d:%d:%d\n\n", day, month, year, hour, minute, second);
				strcat(fullString, String);

				strcat(fullString, ""LIGHTBLUE"If you believe this action was biased, invalid or shouldn't be done, please post a ban appeal.\n\
					Forum link: "IVORY"https://forum.h2omultiplayer.com/");
				Dialog_Show(targetid, DIALOG_STYLE_MSGBOX, ""RED2"You are banned!", fullString, "X", "");

				foreach(new i: Player) {
					if (IsPlayerConnected(i)) {
						for (new x = 0; x < sizeof(ReportInfo); x++) {
							if (i != targetid && i == ReportInfo[x][R_FROM_ID] && targetid == ReportInfo[x][R_AGAINST_ID]) {
								Text_Send(i, $CLIENT_424x);
								GivePlayerScore(i, 2);
								break;
							}
						}
					}
				}

				format(query, sizeof(query), "Banned player %s for %d days for %s.", PlayerInfo[targetid][PlayerName], days, reason);
				LogAdminAction(playerid, query);
				
				if (days == -1) {
					RangeBan(targetid);
				}
				PlayerInfo[targetid][pBannedTimes] ++;
				SetTimerEx("ApplyBan", 500, false, "i", targetid);
			}  else Text_Send(playerid, $CLIENT_319x);
		}
	}
	return 1;
}

flags:warn(CMD_ADMIN | CMD_MOD);
CMD:warn(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel] || PlayerInfo[playerid][pIsModerator]) {
		new warned, reason[25], str[140];

		if (sscanf(params, "us[25]", warned, reason)) return ShowSyntax(playerid, "/warn [playerid/name] [Reason]");
		if (IsPlayerConnected(warned) && warned != INVALID_PLAYER_ID) {
			if (PlayerInfo[warned][pAdminLevel] == svtconf[max_admin_level] && PlayerInfo[playerid][pAdminLevel] < PlayerInfo[warned][pAdminLevel])
				return Text_Send(playerid, $CLIENT_362x);

			if (PlayerInfo[warned][pAdminLevel] > PlayerInfo[playerid][pAdminLevel]) return Text_Send(playerid, $CLIENT_321x);

			if (warned != playerid) {
				if (Anti_Warn[warned] > gettime()) return Text_Send(playerid, $NEWCLIENT_195x);
				PlayerInfo[warned][pTempWarnings]++;

				new query[256];
				mysql_format(Database, query, sizeof(query), "INSERT INTO `Punishments` (PunishedPlayer, Punisher, Action, ActionReason, PunishmentTime, ActionDate) \
					VALUES ('%e', '%e', 'Warn', '%s', '', '%d')", PlayerInfo[warned][PlayerName], PlayerInfo[playerid][PlayerName], reason, gettime());
				mysql_tquery(Database, query);
			
				if (PlayerInfo[playerid][pAdminLevel]) {
					if ( PlayerInfo[warned][pTempWarnings] == svtconf[max_warns]) {
						Text_Send(@pVerified, $NEWSERVER_44x, PlayerInfo[playerid][PlayerName], PlayerInfo[warned][PlayerName],  PlayerInfo[warned][pTempWarnings], svtconf[max_warns], reason);
						Kick(warned);
						PlayerInfo[warned][pTempWarnings] = 0;
					} else {
						Text_Send(@pVerified, $NEWSERVER_45x, PlayerInfo[playerid][PlayerName], PlayerInfo[warned][PlayerName], PlayerInfo[warned][pTempWarnings], svtconf[max_warns],reason);
						Anti_Warn[warned] = 1;
					}
				} else {
					if ( PlayerInfo[warned][pTempWarnings] == svtconf[max_warns]) {
						Text_Send(@pVerified, $NEWSERVER_46x, PlayerInfo[playerid][PlayerName], PlayerInfo[warned][PlayerName],  PlayerInfo[warned][pTempWarnings], svtconf[max_warns], reason);
						Kick(warned);
						PlayerInfo[warned][pTempWarnings] = 0;
					} else {
						Text_Send(@pVerified, $NEWSERVER_47x, PlayerInfo[playerid][PlayerName], PlayerInfo[warned][PlayerName], PlayerInfo[warned][pTempWarnings], svtconf[max_warns],reason);
						Anti_Warn[warned] = 1;
					}                   
				}

				new DCC_Channel:StaffChannel;
				format(str, sizeof (str), "Staff %s has warned %s (%d/%d) for %s.", PlayerInfo[playerid][PlayerName], PlayerInfo[warned][PlayerName], PlayerInfo[warned][pTempWarnings], svtconf[max_warns], reason);
				StaffChannel = DCC_FindChannelByName(CHANNEL_STAFF_NAME);
				DCC_SendChannelMessage(StaffChannel, str);

				new warn_info[300];
				format(warn_info, sizeof(warn_info), "{0099FF}Reason:{E8E8E8} %s\n\
					{0099FF}Admin:{E8E8E8} %s\n\
					{0099FF}Warning:{E8E8E8} %d/%d\n\nPlease be nice next time.", reason, PlayerInfo[playerid][PlayerName], PlayerInfo[warned][pTempWarnings], svtconf[max_warns]);
				Dialog_Show(warned, DIALOG_STYLE_MSGBOX, "You are warned", warn_info, "X", "");

				Anti_Warn[warned] = gettime() + 5;

				format(query, sizeof(query), "Warned player %s for %s (Warnings %d/%d).", PlayerInfo[warned][PlayerName], reason, PlayerInfo[warned][pTempWarnings], svtconf[max_warns]);
				LogAdminAction(playerid, query);

				PlayerInfo[warned][pAccountWarnings] ++;
			}  else Text_Send(playerid, $NEWCLIENT_193x);
		}  else Text_Send(playerid, $CLIENT_320x);
	}
	return 1;
}

flags:removewarnings(CMD_ADMIN);
CMD:removewarnings(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new warned;

		if (sscanf(params, "u", warned)) return ShowSyntax(playerid, "/removewarnings [playerid/name]");

		if (IsPlayerConnected(warned) && warned != INVALID_PLAYER_ID) {
			if (PlayerInfo[warned][pAdminLevel] == svtconf[max_admin_level] && PlayerInfo[playerid][pAdminLevel] < svtconf[max_admin_level] - 1) return Text_Send(playerid, $CLIENT_362x);
			if (warned != playerid) {
				if (PlayerInfo[warned][pTempWarnings] > 0) {
					PlayerInfo[warned][pTempWarnings] = 0;
					
					Text_Send(@pVerified, $NEWSERVER_48x, PlayerInfo[playerid][PlayerName], PlayerInfo[warned][PlayerName]);

					new query[160];
					format(query, sizeof(query), "Removed warnings for player %s.", PlayerInfo[warned][PlayerName]);
					LogAdminAction(playerid, query);
				}  else Text_Send(playerid, $NEWCLIENT_196x);
			}
		}
	}
	return 1;
}

flags:kick(CMD_ADMIN | CMD_MOD);
CMD:kick(playerid, params[]) {
	if (PlayerInfo[playerid][pLoggedIn] == 1) {
		if (PlayerInfo[playerid][pAdminLevel] || PlayerInfo[playerid][pIsModerator]) {
			new targetid, reason[25];

			if (sscanf(params, "us[25]", targetid, reason)) return ShowSyntax(playerid, "/kick [playerid/name] [reason]");

			if (IsPlayerConnected(targetid) && targetid != INVALID_PLAYER_ID && targetid != playerid) {
				if (PlayerInfo[targetid][pAdminLevel] == svtconf[max_admin_level] && PlayerInfo[playerid][pAdminLevel] < PlayerInfo[targetid][pAdminLevel])
					return Text_Send(playerid, $CLIENT_362x);

				if (PlayerInfo[targetid][pAdminLevel] > PlayerInfo[playerid][pAdminLevel]) return Text_Send(playerid, $CLIENT_321x);

				if (PlayerInfo[playerid][pAdminLevel]) {
					Text_Send(@pVerified, $NEWSERVER_49x, PlayerInfo[playerid][PlayerName], PlayerInfo[targetid][PlayerName], reason);
				} else {
					Text_Send(@pVerified, $NEWSERVER_50x, PlayerInfo[playerid][PlayerName], PlayerInfo[targetid][PlayerName], reason);
				}

				new query[256];

				mysql_format(Database, query, sizeof(query), "INSERT INTO `Punishments` (PunishedPlayer, Punisher, Action, ActionReason, PunishmentTime, ActionDate) \
					VALUES ('%e', '%e', 'Kick', '%s', '', '%d')", PlayerInfo[targetid][PlayerName], PlayerInfo[playerid][PlayerName], reason, gettime());
				mysql_tquery(Database, query);

				PlayerInfo[targetid][pKicksByAdmin] ++;

				foreach(new i: Player) {
					if (IsPlayerConnected(i)) {
						for (new x = 0; x < sizeof(ReportInfo); x++) {
							if (i != targetid && i == ReportInfo[x][R_FROM_ID] && targetid == ReportInfo[x][R_AGAINST_ID]) {
								Text_Send(i, $CLIENT_424x);
								GivePlayerScore(i, 2);
								break;
							}
						}
					}
				}
				SetTimerEx("ApplyBan", 500, false, "i", targetid);                  
				format(query, sizeof(query), "Kicked player %s for %s.", PlayerInfo[targetid][PlayerName], reason);
				LogAdminAction(playerid, query);

				new DCC_Channel:StaffChannel, String[128];
				format(String, sizeof (String), "Staff %s has kicked %s for %s.", PlayerInfo[playerid][PlayerName], PlayerInfo[targetid][PlayerName], reason);
				StaffChannel = DCC_FindChannelByName(CHANNEL_STAFF_NAME);
				DCC_SendChannelMessage(StaffChannel, String);
			}  else Text_Send(playerid, $CLIENT_319x);
		}
	}
	return 1;
}

flags:slap(CMD_ADMIN | CMD_MOD);
CMD:slap(playerid, params[]) {
	if (PlayerInfo[playerid][pLoggedIn]) {
		if (PlayerInfo[playerid][pAdminLevel] || PlayerInfo[playerid][pIsModerator]) {
			new targetid;
			if (sscanf(params, "u", targetid)) return ShowSyntax(playerid, "/slap [playerid/name]");

			if (IsPlayerConnected(targetid) && targetid != INVALID_PLAYER_ID) {
				if (PlayerInfo[targetid][pAdminLevel] == svtconf[max_admin_level] && PlayerInfo[playerid][pAdminLevel] < PlayerInfo[targetid][pAdminLevel])
					return Text_Send(playerid, $CLIENT_362x);

				if (!IsPlayerInAnyVehicle(targetid)) {
					new Float:x, Float:y, Float:z;

					GetPlayerPos(targetid, x, y, z);
					SetPlayerPos(targetid, x, y, z + 16);
				}
				else
				{
					new Float:x, Float:y, Float:z;

					GetVehiclePos(GetPlayerVehicleID(targetid), x, y, z);
					SetVehiclePos(GetPlayerVehicleID(targetid), x, y, z + 16);
				}
				PlayerPlaySound(playerid, 1190, 0.0, 0.0, 0.0);
				PlayerPlaySound(targetid, 1190, 0.0, 0.0, 0.0);

				new query[160];
				format(query, sizeof(query), "Slapped player %s.", PlayerInfo[targetid][PlayerName]);
				LogAdminAction(playerid, query);
			}  else Text_Send(playerid, $CLIENT_320x);
		}
	}
	return 1;
}

flags:explode(CMD_ADMIN);
CMD:explode(playerid, params[]) {
	if (PlayerInfo[playerid][pLoggedIn] == 1) {
		if (PlayerInfo[playerid][pAdminLevel]) {
			new targetid;
			if (sscanf(params, "u", targetid)) return ShowSyntax(playerid, "/explode [playerid/name]");

			if (IsPlayerConnected(targetid) && targetid != INVALID_PLAYER_ID) {
				if (PlayerInfo[targetid][pAdminLevel] == svtconf[max_admin_level] && PlayerInfo[playerid][pAdminLevel] < PlayerInfo[targetid][pAdminLevel])
					return Text_Send(playerid, $CLIENT_362x);

				new Float:burnx, Float:burny, Float:burnz;
				GetPlayerPos(targetid,burnx, burny, burnz);
				CreateExplosion(burnx, burny, burnz, 7, 10.0);

				new query[160];
				format(query, sizeof(query), "Exploded player %s.", PlayerInfo[targetid][PlayerName]);
				LogAdminAction(playerid, query);

				new String[128];
				format(String, sizeof(String), "Administrator %s exploded %s.", PlayerInfo[playerid][PlayerName], PlayerInfo[targetid][PlayerName]);
				MessageToAdmins(0x2281C8FF, String);
			}  else Text_Send(playerid, $CLIENT_320x);
		}
	}
	return 1;
}

flags:jail(CMD_ADMIN);
CMD:jail(playerid, params[]) {
	if (PlayerInfo[playerid][pLoggedIn] == 1) {
		if (PlayerInfo[playerid][pAdminLevel]) {
			new targetid, playername[MAX_PLAYER_NAME], adminname[MAX_PLAYER_NAME], reason[25], jtime;
			if (sscanf(params, "uis[25]", targetid, jtime, reason)) return ShowSyntax(playerid, "/jail [playerid/name] [minutes] [reason]");

			if (IsPlayerConnected(targetid) && targetid != INVALID_PLAYER_ID) {
				if (PlayerInfo[targetid][pAdminLevel] == svtconf[max_admin_level] && PlayerInfo[playerid][pAdminLevel] < PlayerInfo[targetid][pAdminLevel])
					return Text_Send(playerid, $CLIENT_362x);
				
				if (PlayerInfo[targetid][pAdminLevel] > PlayerInfo[playerid][pAdminLevel]) return Text_Send(playerid, $CLIENT_321x);

				if (PlayerInfo[targetid][pJailed] == 0) {

					GetPlayerName(targetid, playername, sizeof(playername));
					GetPlayerName(playerid, adminname, sizeof(adminname));

					if (jtime == 0) jtime = 5;

					PlayerInfo[targetid][pJailTime] = (jtime * 60) + gettime();

					ResetPlayerWeapons(targetid);

					JailPlayer(targetid);
					PlayerInfo[targetid][pJailed] = 1;

					new String[128];
					format(String, sizeof(String), "Administrator %s jailed %s for %d minutes. [Reason: %s]", PlayerInfo[playerid][PlayerName], PlayerInfo[targetid][PlayerName], jtime, reason);
					MessageToAdmins(0x2281C8FF, String);

					new query[256];
					mysql_format(Database, query, sizeof(query), "INSERT INTO `Punishments` (PunishedPlayer, Punisher, Action, ActionReason, PunishmentTime, ActionDate) \
						VALUES ('%e', '%e', 'Jail', '%s', '%d Minutes', '%d')", PlayerInfo[targetid][PlayerName], PlayerInfo[playerid][PlayerName], reason, jtime, gettime());
					mysql_tquery(Database, query);

					Text_Send(@pVerified, $NEWSERVER_51x, adminname, playername, jtime, reason);

					format(query, sizeof(query), "Jailed player %s for %d seconds for %s.", PlayerInfo[targetid][PlayerName], jtime, reason);
					LogAdminAction(playerid, query);
				}  else Text_Send(playerid, $NEWCLIENT_197x);
			}  else Text_Send(playerid, $CLIENT_320x);
		}
	}
	return 1;
}

flags:unjail(CMD_ADMIN);
CMD:unjail(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new targetid;
		if (sscanf(params, "u", targetid)) return ShowSyntax(playerid, "/unjail [playerid/name]");

		if (IsPlayerConnected(targetid) && targetid != INVALID_PLAYER_ID)
		 {
			if (PlayerInfo[targetid][pAdminLevel] == svtconf[max_admin_level] && PlayerInfo[playerid][pAdminLevel] < PlayerInfo[targetid][pAdminLevel])
				return Text_Send(playerid, $CLIENT_362x);
			
			if (PlayerInfo[targetid][pAdminLevel] > PlayerInfo[playerid][pAdminLevel]) return Text_Send(playerid, $CLIENT_321x);

			if (PlayerInfo[targetid][pJailed] == 1) {
				Text_Send(@pVerified, $NEWSERVER_52x, PlayerInfo[playerid][PlayerName], PlayerInfo[targetid][PlayerName]);

				JailRelease(targetid);

				new String[128];
				format(String, sizeof(String), "Administrator %s unjailed %s.", PlayerInfo[playerid][PlayerName], PlayerInfo[targetid][PlayerName]);
				MessageToAdmins(0x2281C8FF, String);

				new query[160];
				format(query, sizeof(query), "Unjailed player %s.", PlayerInfo[targetid][PlayerName]);
				LogAdminAction(playerid, query);
			}  else Text_Send(playerid, $NEWCLIENT_196x);
		}  else Text_Send(playerid, $CLIENT_320x);
	}
	return 1;
}

flags:jailed(CMD_ADMIN);
CMD:jailed(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new bool:First2 = false, cout, adminname[MAX_PLAYER_NAME], String[140];

		foreach (new i: Player)
			if (IsPlayerConnected(i) && PlayerInfo[i][pJailed])
				 cout++;

		if (cout == 0) return Text_Send(playerid, $CLIENT_423x);

		foreach (new i: Player) {
			if (IsPlayerConnected(i) && PlayerInfo[i][pJailed]) {
				GetPlayerName(i, adminname, sizeof(adminname));

				if (!First2) {
					format(String, sizeof(String), "Jailed Players: (%d)%s", i, adminname);
					First2 = true;
				} else format(String, sizeof(String), "%s, (%d)%s ", String, i, adminname);

			}
		}
		
		SendClientMessage(playerid, 0xFFFFFFFF, String);
	}
	return 1;
}

flags:freeze(CMD_ADMIN);
CMD:freeze(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new targetid, reason[25], ftime;
		if (sscanf(params, "uis[25]", targetid, ftime, reason)) return ShowSyntax(playerid, "/freeze [playerid/name] [minutes] [reason]");

		if (IsPlayerConnected(targetid) && targetid != INVALID_PLAYER_ID) {
			if (PlayerInfo[targetid][pAdminLevel] == svtconf[max_admin_level] && PlayerInfo[playerid][pAdminLevel] < PlayerInfo[targetid][pAdminLevel])
				return Text_Send(playerid, $CLIENT_420x);
			
			if (PlayerInfo[targetid][pAdminLevel] > PlayerInfo[playerid][pAdminLevel]) return Text_Send(playerid, $CLIENT_321x);
			
			if (PlayerInfo[targetid][pFrozen] == 0) {
				if (ftime == 0) ftime = 5;

				TogglePlayerControllable(targetid, false);

				PlayerInfo[targetid][pFrozen] = 1;
				PlayerPlaySound(targetid, 1057, 0.0, 0.0, 0.0);

				PlayerInfo[targetid][pFreezeTime] = ftime * 1000 * 60;
				FreezeTimer[targetid] = SetTimerEx("Unfreeze", PlayerInfo[targetid][pFreezeTime], 0, "d", targetid);

				Text_Send(@pVerified, $NEWSERVER_53x, PlayerInfo[playerid][PlayerName], PlayerInfo[targetid][PlayerName], ftime, reason);

				new String[128];
				format(String, sizeof(String), "Administrator %s froze %s for %d minutes. [Reason: %s]", PlayerInfo[playerid][PlayerName], PlayerInfo[targetid][PlayerName], ftime, reason);
				MessageToAdmins(0x2281C8FF, String);

				new query[256];

				mysql_format(Database, query, sizeof(query), "INSERT INTO `Punishments` (PunishedPlayer, Punisher, Action, ActionReason, PunishmentTime, ActionDate) \
					VALUES ('%e', '%e', 'Freeze', '%s', '%d Minutes', '%d')", PlayerInfo[targetid][PlayerName], PlayerInfo[playerid][PlayerName], reason, ftime, gettime());
				mysql_tquery(Database, query);
				
				format(query, sizeof(query), "Froze player %s for %d seconds for %s.", PlayerInfo[targetid][PlayerName], ftime, reason);
				LogAdminAction(playerid, query);
			}  else Text_Send(playerid, $NEWCLIENT_197x);
		}  else Text_Send(playerid, $CLIENT_320x);
	}
	return 1;
}

flags:unfreeze(CMD_ADMIN);
CMD:unfreeze(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new targetid;
		if (sscanf(params, "u", targetid)) return ShowSyntax(playerid, "/unfreeze [playerid/name]");

		if (IsPlayerConnected(targetid) && targetid != INVALID_PLAYER_ID) {
			if (PlayerInfo[targetid][pAdminLevel] == svtconf[max_admin_level] && PlayerInfo[playerid][pAdminLevel] < PlayerInfo[targetid][pAdminLevel])
				return Text_Send(playerid, $CLIENT_362x);
			
			if (PlayerInfo[targetid][pAdminLevel] > PlayerInfo[playerid][pAdminLevel]) return Text_Send(playerid, $CLIENT_321x);

			if (PlayerInfo[targetid][pFrozen] == 1) {
				Unfreeze(targetid);

				Text_Send(@pVerified, $NEWSERVER_54x, PlayerInfo[playerid][PlayerName], PlayerInfo[targetid][PlayerName]);

				new String[128];
				format(String, sizeof(String), "Administrator %s unfroze %s.", PlayerInfo[playerid][PlayerName], PlayerInfo[targetid][PlayerName]);
				MessageToAdmins(0x2281C8FF, String);

				new query[160];
				format(query, sizeof(query), "Unfrozen player %s.", PlayerInfo[targetid][PlayerName]);
				LogAdminAction(playerid, query);
			}  else Text_Send(playerid, $NEWCLIENT_196x);
		}  else Text_Send(playerid, $CLIENT_320x);
	}
	return 1;
}

flags:frozen(CMD_ADMIN);
CMD:frozen(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new bool:First2 = false, cot, adminname[MAX_PLAYER_NAME], String[140];

		foreach (new i: Player) if (PlayerInfo[i][pFrozen]) cot++;
		if (cot == 0) return Text_Send(playerid, $CLIENT_423x);

		foreach (new i: Player) if (PlayerInfo[i][pFrozen]) {
			GetPlayerName(i, adminname, sizeof(adminname));

			if (!First2) {
				format(String, sizeof(String), "Frozen Players: (%d)%s", i, adminname);
				First2 = true;
			}
			else format(String, sizeof(String), "%s, (%d)%s ", String,i,adminname);
		}
		return SendClientMessage(playerid, 0xFFFFFFFF, String);
	}
	return 1;
}

flags:mute(CMD_ADMIN);
CMD:mute(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new targetid, reason[25];
		if (sscanf(params, "us[25]", targetid, reason)) return ShowSyntax(playerid, "/mute [playerid/name] [reason]");

		if (IsPlayerConnected(targetid) && targetid != INVALID_PLAYER_ID) {
			if (PlayerInfo[targetid][pAdminLevel] == svtconf[max_admin_level] && PlayerInfo[playerid][pAdminLevel] < PlayerInfo[targetid][pAdminLevel])
				return Text_Send(playerid, $CLIENT_362x);
			
			if (PlayerInfo[targetid][pAdminLevel] > PlayerInfo[playerid][pAdminLevel]) return Text_Send(playerid, $CLIENT_321x);

			if (!PlayerInfo[targetid][pMuted]) {
				PlayerPlaySound(targetid, 1057, 0.0, 0.0, 0.0);

				PlayerInfo[targetid][pMuted] = 1;

				new String[128];
				format(String, sizeof(String), "Administrator %s muted %s. [Reason: %s]", PlayerInfo[playerid][PlayerName], PlayerInfo[targetid][PlayerName], reason);
				MessageToAdmins(0x2281C8FF, String);

				new query[256];

				mysql_format(Database, query, sizeof(query), "INSERT INTO `Punishments` (PunishedPlayer, Punisher, Action, ActionReason, PunishmentTime, ActionDate) \
					VALUES ('%e', '%e', 'Mute', '%s', '', '%d')", PlayerInfo[targetid][PlayerName], PlayerInfo[playerid][PlayerName], reason, gettime());
				mysql_tquery(Database, query);

				Text_Send(@pVerified, $NEWSERVER_55x, PlayerInfo[playerid][PlayerName], PlayerInfo[targetid][PlayerName]);

				format(query, sizeof(query), "Muted player %s for %s.", PlayerInfo[targetid][PlayerName], reason);
				LogAdminAction(playerid, query);
			} else return Text_Send(playerid, $NEWCLIENT_197x);
		}  else Text_Send(playerid, $CLIENT_320x);
	}
	return 1;
}

flags:unmute(CMD_ADMIN);
CMD:unmute(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new targetid;
		if (sscanf(params, "u", targetid)) return ShowSyntax(playerid, "/unmute [playerid/name]");

		if (IsPlayerConnected(targetid) && targetid != INVALID_PLAYER_ID) {
			if (PlayerInfo[targetid][pAdminLevel] == svtconf[max_admin_level] && PlayerInfo[playerid][pAdminLevel] < PlayerInfo[targetid][pAdminLevel])
				return Text_Send(playerid, $CLIENT_362x);
			
			if (PlayerInfo[targetid][pAdminLevel] > PlayerInfo[playerid][pAdminLevel]) return Text_Send(playerid, $CLIENT_321x);

			if (PlayerInfo[targetid][pMuted] == 1) {
				PlayerPlaySound(targetid, 1057, 0.0, 0.0, 0.0);
				PlayerInfo[targetid][pMuted] = 0;

				Text_Send(@pVerified, $NEWSERVER_56x, PlayerInfo[playerid][PlayerName], PlayerInfo[targetid][PlayerName]);

				new String[128];
				format(String, sizeof(String), "Administrator %s unmuted %s.", PlayerInfo[playerid][PlayerName], PlayerInfo[targetid][PlayerName]);
				MessageToAdmins(0x2281C8FF, String);

				new query[160];
				format(query, sizeof(query), "Unmuted player %s.", PlayerInfo[targetid][PlayerName]);
				LogAdminAction(playerid, query);
			}  else Text_Send(playerid, $NEWCLIENT_196x);
		}  else Text_Send(playerid, $CLIENT_320x);
	}
	return 1;
}

flags:muted(CMD_ADMIN);
CMD:muted(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new bool:First2 = false, cart, adminname[MAX_PLAYER_NAME], String[140];
		foreach (new i: Player) if (PlayerInfo[i][pMuted]) cart++;
		if (cart == 0) return Text_Send(playerid, $CLIENT_423x);

		foreach (new i: Player) if (PlayerInfo[i][pMuted]) {
			GetPlayerName(i, adminname, sizeof(adminname));

			if (!First2) {
				format(String, sizeof(String), "Muted Players: (%d)%s", i, adminname);
				First2 = true;
			}
			else format(String, sizeof(String), "%s, (%d)%s ", String, i, adminname);
		}
		
		SendClientMessage(playerid, 0xFFFFFFFF, String);
	}
	return 1;
}

CMD:items(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new targetid, String[128];
		if (sscanf(params, "u", targetid)) return ShowSyntax(playerid, "/items [playerid/name]");

		new items;
		format(String, sizeof(String), "%s[%d]'s Items:", PlayerInfo[targetid][PlayerName], targetid);
		SendClientMessage(playerid, 0x2281C8FF, String);
		if (IsPlayerConnected(targetid) && targetid != INVALID_PLAYER_ID) {
			for (new i = 0; i < MAX_ITEMS; i++) {
				if (pItems[targetid][i]) {
					items ++;
					format(String, sizeof(String), "-%s <%d>", ItemsInfo[i][Item_Name], pItems[targetid][i]);
					SendClientMessage(playerid, 0x2281C8FF, String);
				}
			}

			if (PlayerInfo[targetid][pIsSpying]) {
				format(String, sizeof(String), "-Player is spying %s.", TeamInfo[PlayerInfo[targetid][pSpyTeam]][Team_Name]);
				SendClientMessage(playerid, 0x2281C8FF, String);
			}

			format(String, sizeof(String), "Administrator %s checked %s's items.", PlayerInfo[playerid][PlayerName], PlayerInfo[targetid][PlayerName]);
			MessageToAdmins(0x2281C8FF, String);

			format(String, sizeof(String), "Viewed %s's items.", PlayerInfo[targetid][PlayerName]);
			LogAdminAction(playerid, String);
		}  else Text_Send(playerid, $CLIENT_320x);
	}    
	return 1;
}

CMD:breset(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new targetid;
		if (sscanf(params, "u", targetid)) return ShowSyntax(playerid, "/bstats [playerid/name]");

		if (IsPlayerConnected(targetid) && targetid != INVALID_PLAYER_ID) {
			new reset_bullet_stats[BulletData];
			BulletStats[targetid] = reset_bullet_stats;

			new query[160];
			format(query, sizeof(query), "Reset bullet statistics for %s.", PlayerInfo[targetid][PlayerName]);
			LogAdminAction(playerid, query);
		}
	}
	return 1;   
}

CMD:bstats(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new targetid, String[910];
		if (sscanf(params, "u", targetid)) return ShowSyntax(playerid, "/bstats [playerid/name]");

		if (IsPlayerConnected(targetid) && targetid != INVALID_PLAYER_ID) {
			if (BulletStats[targetid][Bullet_Vectors][0] == 0.0 && BulletStats[targetid][Bullet_Vectors][1] == 0.0 && BulletStats[targetid][Bullet_Vectors][2] == 0.0) {
				Text_Send(playerid, $CLIENT_420x);
				return 1;
			}

			new Float: HMR = floatdiv(BulletStats[targetid][Bullets_Hit], BulletStats[targetid][Bullets_Miss]);
			new Float: Avg = floatdiv(BulletStats[targetid][Bullets_Hit] + BulletStats[targetid][Bullets_Miss], 2);
			new Float: Dist = floatdiv(BulletStats[targetid][Longest_Hit_Distance] + BulletStats[targetid][Shortest_Hit_Distance], 2);
			new WeaponName[32];
			GetWeaponName(BulletStats[targetid][Longest_Distance_Weapon], WeaponName, sizeof(WeaponName));

			new WeaponName2[32];
			GetWeaponName(GetPlayerWeapon(targetid), WeaponName2, sizeof(WeaponName2));
			format(String, sizeof(String), ""DARKBLUE"Viewing %s[%d]'s bullet statistics:\n\n\
			{E8E8E8}Bullets hit by player: %d\n\
			Bullets missed by player: %d\n\
			Bullets hit/miss acuracy: %0.2f\n\
			Avg bullet hit/miss: %0.1f\n\
			Seconds since last shot: %0.1f\n\
			Interval between shots: %0.1f\n\
			Bullets hit in a row: %d\n\
			Bullets missed in a row: %d\n\
			Seconds since last hit: %0.1f\n\
			Longest hit distance: %0.2f\n\
			Shortest hit distance: %0.2f\n\
			Last hit distance: %0.2f\n\
			Avg hit distance: %0.2f\n",
			PlayerInfo[targetid][PlayerName], targetid, BulletStats[targetid][Bullets_Hit], BulletStats[targetid][Bullets_Miss], HMR, Avg, floatdiv(GetTickCount() - BulletStats[targetid][Last_Shot_MS], 1000), floatdiv(BulletStats[targetid][MS_Between_Shots], 1000),
			BulletStats[targetid][Group_Hits], BulletStats[targetid][Group_Misses], BulletStats[targetid][Last_Hit_MS], BulletStats[targetid][Longest_Hit_Distance], BulletStats[targetid][Shortest_Hit_Distance],
			BulletStats[targetid][Last_Hit_Distance], Dist);
			format(String, sizeof(String), "%sHits per one miss: %d\n\
			Misses per one hit: %d\n\
			Longest distance weapon: %s[%d]\n\
			Current weapon: %s[%d]\n\
			Shots hit without aiming: %d\n\
			Last shot vectors: %0.2f, %0.2f, %0.2f\n\
			Highest hit record without a miss: %d\n\
			Highest miss record without a hit: %d\n\n", String, BulletStats[targetid][Hits_Per_Miss], BulletStats[targetid][Misses_Per_Hit], WeaponName,
			BulletStats[targetid][Longest_Distance_Weapon], WeaponName2, GetPlayerWeapon(targetid),
			BulletStats[targetid][Hits_Without_Aiming],
			BulletStats[targetid][Bullet_Vectors][0], BulletStats[targetid][Bullet_Vectors][1], BulletStats[targetid][Bullet_Vectors][2],
			BulletStats[targetid][Highest_Hits], BulletStats[targetid][Highest_Misses]);
			format(String, sizeof(String), "%s"DARKBLUE"Network statistics:\n\n\
			{E8E8E8}Packet loss percent: %0.2f\n\
			Player is lagging? %s\n\
			Player ping: %d", String, NetStats_PacketLossPercent(targetid), (NetStats_PacketLossPercent(targetid) > 1.0) ? ("Yes") : ("No"),
			GetPlayerPing(targetid));
			Dialog_Show(playerid, DIALOG_STYLE_MSGBOX, "Bullet/Network Stats", String, "X", "");
		}  else Text_Send(playerid, $CLIENT_320x);
	}
	return 1;
}

flags:weaps(CMD_ADMIN | CMD_MOD);
CMD:weaps(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel] || PlayerInfo[playerid][pIsModerator]) {
		new targetid, String[140], WeapName[24], slot, weap, ammo, wh, x;
		if (sscanf(params, "u", targetid)) return ShowSyntax(playerid, "/weaps [playerid/name]");

		if (IsPlayerConnected(targetid) && targetid != INVALID_PLAYER_ID) {
			format(String, sizeof(String), "%s[%d]'s weapons:", PlayerInfo[targetid][PlayerName], targetid);
			SendClientMessage(playerid, 0x2281C8FF, String);

			format(String, sizeof(String), " ");

			for (slot = 0; slot < 13; slot++) {
				GetPlayerWeaponData(targetid, slot, weap, ammo);

				if (ammo != 0 && weap != 0) {
					wh++;
				}
			}

			if (wh < 1) {
				return Text_Send(playerid, $CLIENT_423x);
			}

			if (wh >= 1) {
				for (slot = 0; slot < 13; slot++) {
					GetPlayerWeaponData(targetid, slot, weap, ammo);

					if ( ammo != 0 && weap != 0) {
						GetWeaponName(weap, WeapName, sizeof(WeapName));
						if (ammo == 65535 || ammo == 1)
						{
							format(String, sizeof(String), "%s%s (1)", String, WeapName);
						} else format(String, sizeof(String), "%s%s (%d)", String, WeapName, ammo );

						x++;

						if (x >= 5)
						{
							SendClientMessage(playerid, 0x2281C8FF, String);
							x = 0;
							format(String, sizeof(String), "");
						} else format(String, sizeof(String), "%s,  ", String);
					}
				}

				if (x <= 4 && x > 0) {
					String[strlen(String)-3] = '.';
					SendClientMessage(playerid, 0x2281C8FF, String);
				}
			}
		}  else Text_Send(playerid, $CLIENT_320x);
	}    
	return 1;
}

flags:aka(CMD_ADMIN);
CMD:aka(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new args[25];
		if (sscanf(params, "s[25]", args)) return ShowSyntax(playerid, "/aka [name/IP]");

		new query[140];

		mysql_format(Database, query, sizeof(query),
			"SELECT * FROM `Players` WHERE `Username` LIKE '%e' OR `IP` LIKE '%e'", args, args);

		mysql_tquery(Database, query, "GetAKALogger", "i", playerid);
		printf("[ADMIN] %s[%d] used /aka (parameter: %s)", PlayerInfo[playerid][PlayerName], playerid, args);

	}
	return 1;
}

flags:screen(CMD_ADMIN);
CMD:screen(playerid, params[]) {
	new targetid, gameText[50];
	
	if (PlayerInfo[playerid][pAdminLevel]) {
		if (sscanf(params, "us[50]", targetid, gameText)) return ShowSyntax(playerid, "/screen [playerid/name] [text]");
		if (IsPlayerConnected(targetid) && targetid != INVALID_PLAYER_ID && targetid != playerid) {

			GameTextForPlayer(targetid, gameText, 4000, 3);

			new query[160];
			format(query, sizeof(query), "Showed text \"%s\" on %s's screen.", gameText, PlayerInfo[targetid][PlayerName]);
			LogAdminAction(playerid, query);
		} else Text_Send(playerid, $NEWCLIENT_193x);
	}
	return 1;
}

flags:countdown(CMD_ADMIN);
CMD:countdown(playerid, params[]) {
	if (!PlayerInfo[playerid][pAdminLevel]) return 1;

	new cdValue = 0;
	if (sscanf(params, "i", cdValue)) return ShowSyntax(playerid, "/countdown [seconds]");

	counterValue = cdValue;
	counterOn = 1;

	KillTimer(counterTimer);
	counterTimer = SetTimer("StartCount", 1500, true);

	new query[160];
	format(query, sizeof(query), "Started a global count down for %d seconds.", cdValue);
	LogAdminAction(playerid, query);

	return 1;
}

flags:aduty(CMD_ADMIN);
CMD:aduty(playerid) {
   if (PlayerInfo[playerid][pAdminLevel]) {
		 if (!PlayerInfo[playerid][pAdminDuty]) {
			if (!ForceSync[playerid]) {
				StoreData(playerid);
			}   

			PlayerInfo[playerid][pAdminDuty] = 1;

			SetPlayerSkin(playerid, 217);
			 
			SetPlayerHealth(playerid, 100.0);
			SetPlayerArmour(playerid, 100.0);
			 
			ResetPlayerWeapons(playerid);
			GivePlayerWeapon(playerid, 38, 9999);
			 
			SetPlayerColor(playerid, X11_DEEPSKYBLUE);

			if (PlayerInfo[playerid][pDeathmatchId] > -1) {
				ForceSync[playerid] = 0;
				PlayerInfo[playerid][pDeathmatchId] = -1;
				SpawnPlayer(playerid);
			}

			if (pDuelInfo[playerid][pDInMatch]) {
				ForceSync[playerid] = 0;
				pDuelInfo[playerid][pDInMatch] = 0;
				SpawnPlayer(playerid);
			}

			if (Iter_Contains(CWCLAN1, playerid)) {
				ForceSync[playerid] = 0;
				Iter_Remove(CWCLAN1, playerid);
				SpawnPlayer(playerid);
			}
			if (Iter_Contains(CWCLAN2, playerid)) {
				ForceSync[playerid] = 0;
				Iter_Remove(CWCLAN2, playerid);
				SpawnPlayer(playerid);
			}   
		 } else if (PlayerInfo[playerid][pAdminDuty]) {		 
			PlayerInfo[playerid][pAdminDuty] = 0;
			SetPlayerSkin(playerid, pSkin[playerid]);
			SpawnPlayer(playerid);            
		 }
		 
		 UpdatePlayerHUD(playerid);
   }
   return 1;
}

//-all commands

flags:spawnall(CMD_ADMIN);
CMD:spawnall(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		foreach (new i: Player) {
			if (i != playerid && !PlayerInfo[i][pAdminLevel] && IsPlayerSpawned(i)) {
				PlayerPlaySound(i, 1057, 0.0, 0.0, 0.0);
				SetPlayerPos(i, 0.0, 0.0, 0.0);
				SpawnPlayer(i);
			}
		}

		new String[140];
		format(String, sizeof(String), "Administrator %s respawned all the players", PlayerInfo[playerid][PlayerName]);
		GameTextForPlayer(playerid, String, 5000, 3);
		strcat(String, ".");
		MessageToAdmins(0x2281C8FF, String);

		LogAdminAction(playerid, "Respawned all the players.");
	}
	return 1;
}

flags:muteall(CMD_ADMIN);
CMD:muteall(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		foreach (new i: Player) {
			if (i != playerid && !PlayerInfo[i][pAdminLevel]) {
				PlayerPlaySound(i, 1057, 0.0, 0.0, 0.0);
				PlayerInfo[i][pMuted] = 1;
			}
		}

		Text_Send(@pVerified, $NEWSERVER_13x, PlayerInfo[playerid][PlayerName]);
		LogAdminAction(playerid, "Muted all the players.");
	}
	return 1;
}

flags:unmuteall(CMD_ADMIN);
CMD:unmuteall(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		foreach (new i: Player) {
			if (i != playerid && !PlayerInfo[i][pAdminLevel]) {
				PlayerPlaySound(i, 1057, 0.0, 0.0, 0.0);
				PlayerInfo[i][pMuted] = 0;
			}
		}

		Text_Send(@pVerified, $NEWSERVER_14x, PlayerInfo[playerid][PlayerName]);		
		LogAdminAction(playerid, "Unmuted all the players.");
	}
	return 1;
}

flags:getall(CMD_ADMIN);
CMD:getall(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new
			Float: x,
			Float: y,
			Float: z,
			interior = GetPlayerInterior(playerid)
		;

		GetPlayerPos(playerid, x, y, z);

		foreach (new i: Player) {
			if (i != playerid && !PlayerInfo[i][pAdminLevel]) {
				PlayerPlaySound(i, 1057, 0.0, 0.0, 0.0);
				SetPlayerPos(i, x + (playerid / 4) + 1, y + (playerid / 4), z);
				SetPlayerInterior(i, interior);
			}
		}

		Text_Send(@pVerified, $NEWSERVER_15x, PlayerInfo[playerid][PlayerName]);	
		LogAdminAction(playerid, "Teleported all the players to their location.");
	}
	return 1;
}

flags:healall(CMD_ADMIN);
CMD:healall(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		foreach (new i: Player) {
			PlayerPlaySound(i, 1057, 0.0, 0.0, 0.0);
			SetPlayerHealth(i, 100.0);
		}

		Text_Send(@pVerified, $NEWSERVER_16x, PlayerInfo[playerid][PlayerName]);		
		LogAdminAction(playerid, "Healed all the players.");
	}
	return 1;
}

flags:armourall(CMD_ADMIN);
CMD:armourall(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		foreach (new i: Player) {
			PlayerPlaySound(i,1057,0.0,0.0,0.0);
			SetPlayerArmour(i, 100.0);
		}

		Text_Send(@pVerified, $NEWSERVER_17x, PlayerInfo[playerid][PlayerName]);	
		LogAdminAction(playerid, "Filled armour all the players.");
	}
	return 1;
}

flags:killall(CMD_ADMIN);
CMD:killall(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		foreach (new i: Player)
		{
			if (i != playerid && !PlayerInfo[i][pAdminLevel]) {
				PlayerPlaySound(i, 1057, 0.0, 0.0, 0.0);
				SetPlayerHealth(i, 0.0);
			}
		}

		Text_Send(@pVerified, $NEWSERVER_18x, PlayerInfo[playerid][PlayerName]);		
		LogAdminAction(playerid, "Eliminated all the players.");
	}
	return 1;
}

flags:freezeall(CMD_ADMIN);
CMD:freezeall(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		foreach (new i: Player) {
			if (i != playerid && !PlayerInfo[i][pAdminLevel]) {
				PlayerPlaySound(i, 1057, 0.0, 0.0, 0.0);
				TogglePlayerControllable(i, false);
				PlayerInfo[i][pFrozen] = 1;
			}
		}

		Text_Send(@pVerified, $NEWSERVER_19x, PlayerInfo[playerid][PlayerName]);	
		LogAdminAction(playerid, "Froze all the players.");
	}
	return 1;
}

flags:unfreezeall(CMD_ADMIN);
CMD:unfreezeall(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		foreach (new i: Player) {
			PlayerPlaySound(i, 1057, 0.0, 0.0, 0.0);
			TogglePlayerControllable(i, true);

			PlayerInfo[i][pFrozen] = 0;
			Text_Send(i, $UNFROZEN);
		}

		Text_Send(@pVerified, $NEWSERVER_20x, PlayerInfo[playerid][PlayerName]);		
		LogAdminAction(playerid, "Unfroze all the players.");
	}
	return 1;
}

flags:kickall(CMD_ADMIN);
CMD:kickall(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel] == svtconf[max_admin_level]) {
		foreach (new i: Player) {
			if (i != playerid && !PlayerInfo[i][pAdminLevel]) {
				PlayerPlaySound(i, 1057, 0.0, 0.0, 0.0);
				Kick(i);
			}
		}
		Text_Send(@pVerified, $NEWSERVER_21x, PlayerInfo[playerid][PlayerName]);	
		LogAdminAction(playerid, "Kicked all the players.");
	}
	return 1;
}

flags:slapall(CMD_ADMIN);
CMD:slapall(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new Float:x, Float:y, Float:z;

		foreach (new i: Player)
		   {
			if (i != playerid && !PlayerInfo[i][pAdminLevel]) {
				PlayerPlaySound(i, 1190, 0.0, 0.0, 0.0);
				GetPlayerPos(i, x, y, z);
				SetPlayerPos(i, x, y, z + 4);
			}
		}

		Text_Send(@pVerified, $NEWSERVER_22x, PlayerInfo[playerid][PlayerName]);
		LogAdminAction(playerid, "Slapped all the players.");
	}
	return 1;
}

flags:explodeall(CMD_ADMIN);
CMD:explodeall(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new Float:x, Float:y, Float:z;

		foreach (new i: Player) {
			if (i != playerid && !PlayerInfo[i][pAdminLevel]) {
				PlayerPlaySound(i, 1190, 0.0, 0.0, 0.0);
				GetPlayerPos(i, x, y, z);
				CreateExplosion(x, y , z, 7, 10.0);
			}
		}

		Text_Send(@pVerified, $NEWSERVER_23x, PlayerInfo[playerid][PlayerName]);
		LogAdminAction(playerid, "Exploded all the players.");
	}
	return 1;
}

flags:disarmall(CMD_ADMIN);
CMD:disarmall(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		foreach (new i: Player) {
			if (i != playerid && !PlayerInfo[i][pAdminLevel]) {
				PlayerPlaySound(i, 1057, 0.0, 0.0, 0.0);
				ResetPlayerWeapons(i);
			}
		}
		Text_Send(@pVerified, $NEWSERVER_24x, PlayerInfo[playerid][PlayerName]);
		LogAdminAction(playerid, "Disarmed all the players.");
	}
	return 1;
}

flags:ejectall(CMD_ADMIN);
CMD:ejectall(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new Float:x, Float:y, Float:z;

		foreach (new i: Player)
		{
			if (i != playerid && !PlayerInfo[i][pAdminLevel]) {
				if (IsPlayerInAnyVehicle(i)) {
					PlayerPlaySound(i, 1057, 0.0, 0.0, 0.0);
					GetPlayerPos(i, x, y, z);
					SetPlayerPos(i, x, y, z + 3);
				}
			}
		}

		Text_Send(@pVerified, $NEWSERVER_25x, PlayerInfo[playerid][PlayerName]);
		LogAdminAction(playerid, "Ejected all the players.");
	}
	return 1;
}

flags:setallweather(CMD_ADMIN);
CMD:setallweather(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		if (isnull(params)) return ShowSyntax(playerid, "/setallweather [weather ID]");

		new var = strval(params);

		foreach (new i: Player) {
			PlayerPlaySound(i, 1057, 0.0, 0.0, 0.0);
			SetWeather(var);
		}

		Text_Send(@pVerified, $NEWSERVER_26x, PlayerInfo[playerid][PlayerName], var);

		new query[95];
		format(query, sizeof(query), "Changed everyone's weather to %d.", var);
		LogAdminAction(playerid, query);
	}
	return 1;
}

flags:setalltime(CMD_ADMIN);
CMD:setalltime(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		if (isnull(params)) return ShowSyntax(playerid, "/setalltime [hour]");

		new var = strval(params);
		if (var > 24) return ShowSyntax(playerid, "/setalltime [hour 0-24]");

		foreach (new i: Player) {
			PlayerPlaySound(i, 1057, 0.0, 0.0, 0.0);
			SetPlayerTime(i, strval(params), 0);
		}

		Text_Send(@pVerified, $NEWSERVER_27x, PlayerInfo[playerid][PlayerName], var);

		new query[95];
		format(query, sizeof(query), "Changed global time to %d.", var);
		LogAdminAction(playerid, query);
	}
	return 1;
}

flags:setallworld(CMD_ADMIN);
CMD:setallworld(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		if (isnull(params)) return ShowSyntax(playerid, "/setallworld [virtual world]");

		new var = strval(params);

		foreach (new i: Player) {
			PlayerPlaySound(i, 1057, 0.0, 0.0, 0.0);
			SetPlayerVirtualWorld(i, var);
		}
		Text_Send(@pVerified, $NEWSERVER_28x PlayerInfo[playerid][PlayerName], var);

		new query[95];
		format(query, sizeof(query), "Changed everyone's world to %d.", var);
		LogAdminAction(playerid, query);
	}
	return 1;
}

flags:setallinterior(CMD_ADMIN);
CMD:setallinterior(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		if (isnull(params)) return ShowSyntax(playerid, "/setallinterior [interior]");

		new var = strval(params);

		foreach (new i: Player) {
			PlayerPlaySound(i, 1057, 0.0, 0.0, 0.0);
			SetPlayerInterior(i, var);
		}
		Text_Send(@pVerified, $NEWSERVER_29x, PlayerInfo[playerid][PlayerName], var);

		new query[95];
		format(query, sizeof(query), "Changed everyone's interior to %d.", var);
		LogAdminAction(playerid, query);
	}
	return 1;
}

flags:giveallcash(CMD_ADMIN);
CMD:giveallcash(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		if (isnull(params)) return ShowSyntax(playerid, "/giveallcash [amount]");

		new var = strval(params);

		if (var > 50000 || var <= 0) return ShowSyntax(playerid, "/giveallcash [amount $1-$50000]");

		foreach (new i: Player) {
			PlayerPlaySound(i, 1057, 0.0, 0.0, 0.0);
			GivePlayerCash(i,var);
		}
		Text_Send(@pVerified, $NEWSERVER_30x, PlayerInfo[playerid][PlayerName], var);
		
		new query[95];
		format(query, sizeof(query), "Gave everyone $%d.", var);
		LogAdminAction(playerid, query);
	}
	return 1;
}

flags:giveallscore(CMD_ADMIN);
CMD:giveallscore(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		if (isnull(params)) return ShowSyntax(playerid, "/giveallscore [amount]");

		new var = strval(params);
		
		if (var > 100 || var <= 0) return ShowSyntax(playerid, "/giveallscore [amount 1-100]");

		foreach (new i: Player) {
			PlayerPlaySound(i, 1057, 0.0, 0.0, 0.0);
			GivePlayerScore(i, var);
		}
		Text_Send(@pVerified, $NEWSERVER_31x, PlayerInfo[playerid][PlayerName], var);

		new query[95];
		format(query, sizeof(query), "Gave everyone %d score.", var);
		LogAdminAction(playerid, query);
	}
	return 1;
}

flags:giveallweapon(CMD_ADMIN);
CMD:giveallweapon(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new Weap, ammo;

		if (sscanf(params, "ii", Weap, ammo)) return ShowSyntax(playerid, "/giveallweapon [weapon id] [ammo]");

		foreach (new i: Player) {
			GivePlayerWeapon(i, Weap, ammo) && PlayerPlaySound(i, 1057, 0.0, 0.0, 0.0);
		}

		Text_Send(@pVerified, $NEWSERVER_32x, PlayerInfo[playerid][PlayerName], ReturnWeaponName(Weap), ammo);

		new query[115];
		format(query, sizeof(query), "Gave everyone weapon %s with %d ammo.", ReturnWeaponName(Weap), ammo);
		LogAdminAction(playerid, query);
	} 
	return 1;
}

//Vehicle spawn

flags:sv(CMD_ADMIN);
CMD:sv(playerid, params[]) {
  if (PlayerInfo[playerid][pAdminLevel])
  {
	  new vehID;
	  if (sscanf(params, "i",  vehID)) return ShowSyntax(playerid, "/sv [ID]" );
	  if (vehID == INVALID_VEHICLE_ID) return 0;

	  SetVehicleToRespawn( vehID );
  }
  return 1;
}

flags:dv(CMD_ADMIN);
CMD:dv(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel] == svtconf[max_admin_level]) {
		new vehID;
		if (sscanf( params, "i",  vehID)) return ShowSyntax(playerid, "/dv [vehicle id]");
		if (vehID == INVALID_VEHICLE_ID) return ShowSyntax(playerid, "/dv (delete vehicle) [vehicle id]");
		DestroyVehicle(vehID);
	}    
	return 1;
}

flags:rac(CMD_ADMIN);
CMD:rac(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		for (new i = 0; i < GetVehiclePoolSize(); i++) {
			if (!IsVehicleUsed(i)) {
				SetVehicleToRespawn(i);
			}
		}
		
		LogAdminAction(playerid, "Respawned all the vehicles.");
	}
	return 1;
}
alias:rac("respawncars");

//Get last seen for a player
flags:lastseen(CMD_ADMIN);
CMD:lastseen(playerid, params[]) {
	new nick[MAX_PLAYER_NAME], query[115];

	if (PlayerInfo[playerid][pAdminLevel]) {
		if (sscanf(params, "s[24]", nick)) return ShowSyntax(playerid, "/lastseen [name]");


		mysql_format(Database, query, sizeof(query), "SELECT * FROM `Players` WHERE `Username` = '%e'", nick);
		mysql_tquery(Database, query, "GetLastSeen", "i", playerid);
	}
	return 1;
}

//Teleport to a specific destination
flags:xyz(CMD_ADMIN);
CMD:xyz(playerid, params[]) {
	new Float: X, Float: Y, Float: Z, Interior, Float: R, World;
	if (sscanf(params, "ffffii", X, Y, Z, R, Interior, World)) return ShowSyntax(playerid, "/xyz [x] [y] [z] [rotation] [interior] [virtual world]");
	SetPlayerPosition(playerid, "", World, Interior, X, Y, Z, R);   
	return 1;
}

//Teleport to a specific zone
flags:gotozone(CMD_ADMIN);
CMD:gotozone(playerid) {
	new str[35 * sizeof(ZoneInfo)];
	
	for (new i = 0; i < sizeof(ZoneInfo); i++) {
		strcat(str, ZoneInfo[i][Zone_Name]);
		strcat(str, "\n");
	}

	inline ZonesTeleport(pid, dialogid, response, listitem, string:inputtext[]) {
		#pragma unused dialogid, inputtext
		if (response) {
			SetPlayerPos(pid, ZoneInfo[listitem][Zone_CapturePoint][0], ZoneInfo[listitem][Zone_CapturePoint][1], ZoneInfo[listitem][Zone_CapturePoint][2]);
		}
	}

	Dialog_ShowCallback(playerid, using inline ZonesTeleport, DIALOG_STYLE_LIST, "Zones Teleport", str, ">>", "X");   
	return 1;
}

//Commands

flags:apm(CMD_ADMIN);
CMD:apm(playerid, params[]) {
   if (!PlayerInfo[playerid][pAdminLevel]) return 1;

   new str[140], message[100], ID;
   if (sscanf(params, "us[100]", ID, message)) return ShowSyntax(playerid, "/apm [playerid/name] [message]");

   if (IsPlayerConnected(ID) && ID != playerid && ID != INVALID_PLAYER_ID)
   {
		format(str, sizeof(str), "PM to [%d] %s: "IVORY"%s", ID, PlayerInfo[ID][PlayerName], message);
		SendClientMessage(playerid, 0xFFFF00FF, str);

		format(str, sizeof(str), "Admin PM: "IVORY"%s", message);
		SendClientMessage(ID, 0xFFFF00FF, str);

		PlayerPlaySound(ID, 1057, 0.0, 0.0, 0.0);

		new query[256];
		format(query, sizeof(query), "Force messaged %s, message: %s.", PlayerInfo[ID][PlayerName], message);
		LogAdminAction(playerid, query);
   }  else Text_Send(playerid, $CLIENT_319x);
   return 1;
}

flags:answer(CMD_ADMIN | CMD_MOD);
CMD:answer(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel] || PlayerInfo[playerid][pIsModerator]) {
		new id, input[141];
		if (sscanf(params, "us[140]", id, input)) return ShowSyntax(playerid, "/answer [name/ID] [text]");
		if (!IsPlayerConnected(id) || id == playerid) return Text_Send(playerid, $NEWCLIENT_193x);
		if (!PlayerInfo[id][pQuestionAsked]) return Text_Send(playerid, $CLIENT_434x);

		Text_Send(id, $NEWCLIENT_31x, PlayerInfo[playerid][PlayerName], playerid, input);

		foreach(new i: Player) {
			if (PlayerInfo[i][pAdminLevel] || PlayerInfo[i][pIsModerator]) {
				Text_Send(i, $NEWCLIENT_32x, PlayerInfo[playerid][PlayerName], playerid, PlayerInfo[id][PlayerName], id, input);
			}
		}

		PlayerInfo[id][pQuestionAsked] = 0;
		PlayerInfo[id][pQuestionsAnswered] ++;
		
		new query[256];
		format(query, sizeof(query), "Answered %s's question, answer: %s.", PlayerInfo[id][PlayerName], input);
		LogAdminAction(playerid, query);
	}
	return 1;
}

flags:giveweapon(CMD_ADMIN);
alias:giveweapon("gw");
CMD:giveweapon(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new targetid, weap, weaponname[32], ammoval, ammo, WeapName[32];

		if (sscanf(params, "us[32]i", targetid, weaponname, ammoval)) return ShowSyntax(playerid, "/giveweapon [playerid/name] [weapon ID/weapon name] [ammo]");

		if (ammoval <= 0 || ammoval > 99999) {
			ammo = 500;
		} else ammo = ammoval;

		if (!IsNumeric(weaponname)) weap = GetWeaponIDFromName(weaponname); else weap = strval(weaponname);

		if (IsPlayerConnected(targetid) && targetid != INVALID_PLAYER_ID) {
			if (!IsValidWeapon(weap)) return Text_Send(playerid, $CLIENT_422x);

			GetWeaponName(weap, WeapName, 32);

			GivePlayerWeapon(targetid, weap, ammo);
			printf("Administrator %s[%d] gave %s[%d] weapon %d ammo %d.",
			   PlayerInfo[playerid][PlayerName], playerid, PlayerInfo[targetid][PlayerName],
			   targetid, weap, ammo);

			new query[160];
			format(query, sizeof(query), "Gave %s weapon id %d, ammo %d.", PlayerInfo[targetid][PlayerName], weap, ammo);
			LogAdminAction(playerid, query);
		}  else Text_Send(playerid, $CLIENT_320x);
	}
	return 1;
}

flags:sethealth(CMD_ADMIN);
alias:sethealth("sh");
CMD:sethealth(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new targetid, health;

		if (sscanf(params, "uf", targetid, health)) return ShowSyntax(playerid, "/sethealth [playerid/name] [amount]");
		if (health > 100) return ShowSyntax(playerid, "/sethealth [player name/id] [health 0-100]");

		if (PlayerInfo[targetid][pAdminLevel] == svtconf[max_admin_level] && PlayerInfo[playerid][pAdminLevel] < svtconf[max_admin_level] - 1) return Text_Send(playerid, $CLIENT_362x);
		if (IsPlayerConnected(targetid) && targetid != INVALID_PLAYER_ID) {
			new query[120];
			format(query, sizeof(query), "Updated health for %s to %0.2f.", PlayerInfo[targetid][PlayerName], health);
			LogAdminAction(playerid, query);
			SetPlayerHealth(targetid, health);
		
			new String[128];
			format(String, sizeof(String), "Administrator %s changed %s's health to %0.2f", PlayerInfo[playerid][PlayerName], PlayerInfo[targetid][PlayerName], health);
			MessageToAdmins(0x2281C8FF, String);
		}  else Text_Send(playerid, $CLIENT_320x);
	}
	return 1;
}

flags:setarmour(CMD_ADMIN);
CMD:setarmour(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new targetid, armour;

		if (sscanf(params, "uf", targetid, armour)) return ShowSyntax(playerid, "/setarmour [playerid/name] [amount]");
		if (armour < 0 || armour > 100) return ShowSyntax(playerid, "/setarmour [player name/id] [armour 0-100]");

		if (PlayerInfo[targetid][pAdminLevel] == svtconf[max_admin_level] && PlayerInfo[playerid][pAdminLevel] < svtconf[max_admin_level] - 1) return Text_Send(playerid, $CLIENT_362x);
		if (IsPlayerConnected(targetid) && targetid != INVALID_PLAYER_ID) {

			new query[120];
			format(query, sizeof(query), "Updated armour for %s to %0.2f.", PlayerInfo[targetid][PlayerName], armour);
			LogAdminAction(playerid, query);
			SetPlayerArmour(targetid, armour);
		
			new String[128];
			format(String, sizeof(String), "Administrator %s changed %s's armour to %0.2f.", PlayerInfo[playerid][PlayerName], PlayerInfo[targetid][PlayerName], armour);
			MessageToAdmins(0x2281C8FF, String);
		}  else Text_Send(playerid, $CLIENT_320x);
	}
	return 1;
}

flags:setcash(CMD_ADMIN);
CMD:setcash(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new targetid, cash;

		if (sscanf(params, "ui", targetid, cash)) return ShowSyntax(playerid, "/setcash [playerid/name] [amount]");
		if (PlayerInfo[targetid][pAdminLevel] == svtconf[max_admin_level] && PlayerInfo[playerid][pAdminLevel] < svtconf[max_admin_level] - 1) return Text_Send(playerid, $CLIENT_362x);

		if (IsPlayerConnected(targetid) && targetid != INVALID_PLAYER_ID) {
			
			new query[120];
			format(query, sizeof(query), "Updated cash for %s to %d.", PlayerInfo[targetid][PlayerName], cash);
			LogAdminAction(playerid, query);
			
			GivePlayerCash(targetid, cash);
			ResetPlayerCash(targetid);

			PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
			PlayerPlaySound(targetid, 1057, 0.0, 0.0, 0.0);

			new String[128];
			format(String, sizeof(String), "Administrator %s changed %s's cash to %d.", PlayerInfo[playerid][PlayerName], PlayerInfo[targetid][PlayerName], cash);
			MessageToAdmins(0x2281C8FF, String);
		}  else Text_Send(playerid, $CLIENT_320x);
	}
	return 1;
}

flags:setscore(CMD_ADMIN);
CMD:setscore(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new targetid, score;
		if (sscanf(params, "ui", targetid, score)) return ShowSyntax(playerid, "/setscore [playerid/name] [score]");

		if (PlayerInfo[targetid][pAdminLevel] == svtconf[max_admin_level] && PlayerInfo[playerid][pAdminLevel] < svtconf[max_admin_level] - 1) return Text_Send(playerid, $CLIENT_362x);
		if (IsPlayerConnected(targetid) && targetid != INVALID_PLAYER_ID) {

			new query[120];
			format(query, sizeof(query), "Updated score for %s to %d.", PlayerInfo[targetid][PlayerName], score);
			LogAdminAction(playerid, query);
			SetPlayerScore(targetid, score);

			PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
			PlayerPlaySound(targetid, 1057, 0.0, 0.0, 0.0);

			new String[128];
			format(String, sizeof(String), "Administrator %s changed %s's score to %d.", PlayerInfo[playerid][PlayerName], PlayerInfo[targetid][PlayerName], score);
			MessageToAdmins(0x2281C8FF, String);
		}  else Text_Send(playerid, $CLIENT_320x);
	}
	return 1;
}

flags:setskin(CMD_ADMIN);
CMD:setskin(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new targetid, skin;
		if (sscanf(params, "ui", targetid, skin)) return ShowSyntax(playerid, "/setskin [playerid/name] [skin id]");

		if (!IsValidSkin(skin)) return ShowSyntax(playerid, "/setskin [player name/id] [valid skin id]");
		if (PlayerInfo[targetid][pAdminLevel] == svtconf[max_admin_level] && PlayerInfo[playerid][pAdminLevel] < svtconf[max_admin_level] - 1) return Text_Send(playerid, $CLIENT_362x);

		if (IsPlayerConnected(targetid) && targetid != INVALID_PLAYER_ID) {
			if (PlayerInfo[targetid][pAdminLevel] > PlayerInfo[playerid][pAdminLevel]) return Text_Send(playerid, $CLIENT_321x);
			PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
			PlayerPlaySound(targetid, 1057, 0.0, 0.0, 0.0);

			new query[120];
			format(query, sizeof(query), "Updated skin for %s to %d.", PlayerInfo[targetid][PlayerName], skin);
			LogAdminAction(playerid, query);
			SetPlayerSkin(targetid, skin);

			new String[128];
			format(String, sizeof(String), "Administrator %s changed %s's skin to %d.", PlayerInfo[playerid][PlayerName], PlayerInfo[targetid][PlayerName], skin);
			MessageToAdmins(0x2281C8FF, String);
		}  else Text_Send(playerid, $CLIENT_320x);
	}
	return 1;
}

flags:setcolor(CMD_ADMIN);
CMD:setcolor(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new Colourstr[8], targetid;

		if (sscanf(params, "is[8]", targetid, Colourstr)) return ShowSyntax(playerid, "/setcolor [playerid] [color]"),
			SendClientMessage(playerid, X11_RED2, "Colors: 0 = Black, 1 = White, 2 = Red, 3 = Orange, 4 = Yellow, 5 = Green, 6 = Blue, 7 = Purple, 8 = Brown, 9 = Light Blue.");

		new Colour = strval(Colourstr), colour[24];

		if (Colour > 9 || Colour < 0) return SendClientMessage(playerid, X11_RED2, "Colors: 0 = Black, 1 = White, 2 = Red, 3 = Orange, 4 = Yellow, 5 = Green, 6 = Blue, 7 = Purple, 8 = Brown, 9 = Light Blue.");

		if (PlayerInfo[targetid][pAdminLevel] == svtconf[max_admin_level] && PlayerInfo[playerid][pAdminLevel] < svtconf[max_admin_level] - 1) return Text_Send(playerid, $CLIENT_362x);
		if (IsPlayerConnected(targetid) && targetid != INVALID_PLAYER_ID) {
			switch (Colour) {
				case 0: {
					SetPlayerColor(targetid, 0x000000FF);
					colour = "Black";
				}
				case 1: {
					SetPlayerColor(targetid, 0xFFFFFFFF);
					colour = "White";
				}
				case 2: {
					SetPlayerColor(targetid, X11_RED2);
					colour = "Red";
				}
				case 3: {
					SetPlayerColor(targetid, X11_ORANGE);
					colour = "Orange";
				}
				case 4: {
					SetPlayerColor(targetid, X11_YELLOW);
					colour = "Yellow";
				}
				case 5: {
					SetPlayerColor(targetid, X11_LIMEGREEN);
					colour = "Green";
				}
				case 6: {
					SetPlayerColor(targetid, X11_BLUE);
					colour = "Blue";
				}
				case 7: {
					SetPlayerColor(targetid, X11_PURPLE);
					colour = "Purple";
				}
				case 8: {
					SetPlayerColor(targetid, X11_BROWN);
					colour = "Brown";
				}
				case 9: {
					SetPlayerColor(targetid, X11_LIGHTBLUE);
					colour = "Light Blue";
				}
			}

			PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
			PlayerPlaySound(targetid, 1057, 0.0, 0.0, 0.0);

			new String[128];
			format(String, sizeof(String), "Administrator %s changed %s's colour to %s.", PlayerInfo[playerid][PlayerName], PlayerInfo[targetid][PlayerName], colour);
			MessageToAdmins(0x2281C8FF, String);

			new query[120];
			format(query, sizeof(query), "Updated colour for %s to %s.", PlayerInfo[targetid][PlayerName], colour);
			LogAdminAction(playerid, query);
		}  else Text_Send(playerid, $CLIENT_320x);
	}
	return 1;
}

flags:setweather(CMD_ADMIN);
CMD:setweather(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new targetid, weather;

		if (sscanf(params, "ui", targetid, weather)) return ShowSyntax(playerid, "/setweather [playerid/name] [weather]");
		if (PlayerInfo[targetid][pAdminLevel] == svtconf[max_admin_level] && PlayerInfo[playerid][pAdminLevel] < svtconf[max_admin_level] - 1) return Text_Send(playerid, $CLIENT_362x);

		if (IsPlayerConnected(targetid) && targetid != INVALID_PLAYER_ID) {
			SetPlayerWeather(targetid, weather);

			PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
			PlayerPlaySound(targetid, 1057, 0.0, 0.0, 0.0);
			
			new String[128];
			format(String, sizeof(String), "Administrator %s changed %s's weather to %d.", PlayerInfo[playerid][PlayerName], PlayerInfo[targetid][PlayerName], weather);
			MessageToAdmins(0x2281C8FF, String);

			new query[120];
			format(query, sizeof(query), "Updated weather for %s to %d.", PlayerInfo[targetid][PlayerName], weather);
			LogAdminAction(playerid, query);
		}  else Text_Send(playerid, $CLIENT_320x);
	}
	return 1;
}

flags:setcoins(CMD_ADMIN);
CMD:setcoins(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new targetid, Float: coins;

		if (sscanf(params, "uf", targetid, coins)) return ShowSyntax(playerid, "/setcoins [playerid/name] [amount]");
		if (PlayerInfo[targetid][pAdminLevel] == svtconf[max_admin_level] && PlayerInfo[playerid][pAdminLevel] < svtconf[max_admin_level] - 1) return Text_Send(playerid, $CLIENT_362x);

		if (IsPlayerConnected(targetid) && targetid != INVALID_PLAYER_ID) {
			PlayerInfo[targetid][pCoins] = coins;

			PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
			PlayerPlaySound(targetid, 1057, 0.0, 0.0, 0.0);

			new String[128];
			format(String, sizeof(String), "Administrator %s changed %s's coins to %d.", PlayerInfo[playerid][PlayerName], PlayerInfo[targetid][PlayerName], coins);
			MessageToAdmins(0x2281C8FF, String);

			new query[120];
			format(query, sizeof(query), "Updated coins for %s to %d.", PlayerInfo[targetid][PlayerName], coins);
			LogAdminAction(playerid, query);
		}  else Text_Send(playerid, $CLIENT_320x);
	}
	return 1;
}

flags:givecoins(CMD_ADMIN);
CMD:givecoins(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new targetid, Float: coins;

		if (sscanf(params, "uf", targetid, coins)) return ShowSyntax(playerid, "/givecoins [playerid/name] [amount]");
		if (PlayerInfo[targetid][pAdminLevel] == svtconf[max_admin_level] && PlayerInfo[playerid][pAdminLevel] < svtconf[max_admin_level] - 1) return Text_Send(playerid, $CLIENT_362x);

		if (IsPlayerConnected(targetid) && targetid != INVALID_PLAYER_ID) {
			PlayerInfo[targetid][pCoins] += coins;
			PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
			PlayerPlaySound(targetid, 1057, 0.0, 0.0, 0.0);

			new String[128];
			format(String, sizeof(String), "Administrator %s gave %s %d VIP coins.", PlayerInfo[playerid][PlayerName], PlayerInfo[targetid][PlayerName], coins);
			MessageToAdmins(0x2281C8FF, String);

			new query[120];
			format(query, sizeof(query), "Gave %d VIP coins to %s.", coins, PlayerInfo[targetid][PlayerName]);
			LogAdminAction(playerid, query);
		}  else Text_Send(playerid, $CLIENT_320x);
	}
	return 1;
}

flags:disablecaps(CMD_ADMIN);
CMD:disablecaps(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new targetid, String[140];

		if (sscanf(params, "u", targetid)) return ShowSyntax(playerid, "/disablecaps [playerid/name]");
		
		if (IsPlayerConnected(targetid) && targetid != INVALID_PLAYER_ID) {
			if (PlayerInfo[targetid][pAdminLevel] == svtconf[max_admin_level] && PlayerInfo[playerid][pAdminLevel] < svtconf[max_admin_level] - 1) return Text_Send(playerid, $CLIENT_362x);
			if (!PlayerInfo[targetid][pCapsDisabled]) {
				PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
				PlayerPlaySound(targetid, 1057, 0.0, 0.0, 0.0);

				format(String, sizeof(String), "Administrator %s disabled %s's capslock!", PlayerInfo[playerid][PlayerName], PlayerInfo[targetid][PlayerName]);
				MessageToAdmins(0x2281C8FF, String);
				
				PlayerInfo[targetid][pCapsDisabled] = 1;
			} else {
				PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
				PlayerPlaySound(targetid, 1057, 0.0, 0.0, 0.0);

				format(String, sizeof(String), "Administrator %s enabled %s's capslock!", PlayerInfo[playerid][PlayerName], PlayerInfo[targetid][PlayerName]);
				MessageToAdmins(0x2281C8FF, String);
				
				PlayerInfo[targetid][pCapsDisabled] = 0;
			}
			
			new query[120];
			format(query, sizeof(query), "Revoked capslock permission for %s.", PlayerInfo[targetid][PlayerName]);
			LogAdminAction(playerid, query);
		}  else Text_Send(playerid, $CLIENT_320x);
	}
	return 1;
}

flags:setkills(CMD_ADMIN);
CMD:setkills(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new targetid, kills, String[140];

		if (sscanf(params, "ui", targetid, kills)) return ShowSyntax(playerid, "/setkills [playerid/name] [amount]");
		if (PlayerInfo[targetid][pAdminLevel] == svtconf[max_admin_level] && PlayerInfo[playerid][pAdminLevel] < svtconf[max_admin_level] - 1) return Text_Send(playerid, $CLIENT_362x);

		if (IsPlayerConnected(targetid) && targetid != INVALID_PLAYER_ID) {
			PlayerInfo[targetid][pKills] = kills;
			PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
			PlayerPlaySound(targetid, 1057, 0.0, 0.0, 0.0);

			format(String, sizeof(String), "Administrator %s changed %s's kills to %d!", PlayerInfo[playerid][PlayerName],
				PlayerInfo[targetid][PlayerName], kills);
			MessageToAdmins(0x2281C8FF, String);

			new query[120];
			format(query, sizeof(query), "Updated kills for %s to %d.", PlayerInfo[targetid][PlayerName], kills);
			LogAdminAction(playerid, query);
		}  else Text_Send(playerid, $CLIENT_320x);
	}
	return 1;
}

flags:setakills(CMD_ADMIN);
CMD:setakills(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new targetid, kills, String[140];

		if (sscanf(params, "ui", targetid, kills)) return ShowSyntax(playerid, "/setakills [playerid/name] [amount]");
		if (PlayerInfo[targetid][pAdminLevel] == svtconf[max_admin_level] && PlayerInfo[playerid][pAdminLevel] < svtconf[max_admin_level] - 1) return Text_Send(playerid, $CLIENT_362x);

		if (IsPlayerConnected(targetid) && targetid != INVALID_PLAYER_ID) {
			PlayerInfo[targetid][pKillAssists] = kills;
			PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
			PlayerPlaySound(targetid, 1057, 0.0, 0.0, 0.0);

			format(String, sizeof(String), "Administrator %s changed %s's kill assists to %d!", PlayerInfo[playerid][PlayerName],
				PlayerInfo[targetid][PlayerName], kills);
			MessageToAdmins(0x2281C8FF, String);

			new query[120];
			format(query, sizeof(query), "Updated kill assists for %s to %d.", PlayerInfo[targetid][PlayerName], kills);
			LogAdminAction(playerid, query);
		}  else Text_Send(playerid, $CLIENT_320x);
	}
	return 1;
}

flags:setacaptures(CMD_ADMIN);
CMD:setacaptures(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new targetid, zones, String[140];

		if (sscanf(params, "ui", targetid, zones)) return ShowSyntax(playerid, "/setacaptures [playerid/name] [amount]");
		if (PlayerInfo[targetid][pAdminLevel] == svtconf[max_admin_level] && PlayerInfo[playerid][pAdminLevel] < svtconf[max_admin_level] - 1) return Text_Send(playerid, $CLIENT_362x);

		if (IsPlayerConnected(targetid) && targetid != INVALID_PLAYER_ID) {
			PlayerInfo[targetid][pCapturAssists] = zones;
			PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
			PlayerPlaySound(targetid, 1057, 0.0, 0.0, 0.0);

			format(String, sizeof(String), "Administrator %s changed %s's capture assists to %d!", PlayerInfo[playerid][PlayerName],
				PlayerInfo[targetid][PlayerName], zones);
			MessageToAdmins(0x2281C8FF, String);

			new query[120];
			format(query, sizeof(query), "Updated capture assists for %s to %d.", PlayerInfo[targetid][PlayerName], zones);
			LogAdminAction(playerid, query);
		}  else Text_Send(playerid, $CLIENT_320x);
	}
	return 1;
}

flags:setrevenges(CMD_ADMIN);
CMD:setrevenges(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new targetid, revenges, String[140];

		if (sscanf(params, "ui", targetid, revenges)) return ShowSyntax(playerid, "/setrevenges [playerid/name] [amount]");
		if (PlayerInfo[targetid][pAdminLevel] == svtconf[max_admin_level] && PlayerInfo[playerid][pAdminLevel] < svtconf[max_admin_level] - 1) return Text_Send(playerid, $CLIENT_362x);

		if (IsPlayerConnected(targetid) && targetid != INVALID_PLAYER_ID) {
			PlayerInfo[targetid][pRevengeTakes] = revenges;
			PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
			PlayerPlaySound(targetid, 1057, 0.0, 0.0, 0.0);

			format(String, sizeof(String), "Administrator %s changed %s's revenges to %d!", PlayerInfo[playerid][PlayerName],
				PlayerInfo[targetid][PlayerName], revenges);
			MessageToAdmins(0x2281C8FF, String);

			new query[120];
			format(query, sizeof(query), "Updated revenge takes for %s to %d.", PlayerInfo[targetid][PlayerName], revenges);
			LogAdminAction(playerid, query);
		}  else Text_Send(playerid, $CLIENT_320x);
	}
	return 1;
}

flags:setxp(CMD_ADMIN);
CMD:setxp(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new targetid, xp, String[140];

		if (sscanf(params, "ui", targetid, xp)) return ShowSyntax(playerid, "/setxp [playerid/name] [amount]");
		if (PlayerInfo[targetid][pAdminLevel] == svtconf[max_admin_level] && PlayerInfo[playerid][pAdminLevel] < svtconf[max_admin_level] - 1) return Text_Send(playerid, $CLIENT_362x);

		if (IsPlayerConnected(targetid) && targetid != INVALID_PLAYER_ID) {
			PlayerInfo[targetid][pEXPEarned] = xp;
			PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
			PlayerPlaySound(targetid, 1057, 0.0, 0.0, 0.0);

			format(String, sizeof(String), "Administrator %s changed %s's EXP to %d!", PlayerInfo[playerid][PlayerName],
				PlayerInfo[targetid][PlayerName], xp);
			MessageToAdmins(0x2281C8FF, String);
			
			new query[120];
			format(query, sizeof(query), "Updated EXP for %s to %d.", PlayerInfo[targetid][PlayerName], xp);
			LogAdminAction(playerid, query);
		}  else Text_Send(playerid, $CLIENT_320x);
	}
	return 1;
}

flags:setdeaths(CMD_ADMIN);
CMD:setdeaths(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new targetid, deaths, String[140];

		if (sscanf(params, "ui", targetid, deaths)) return ShowSyntax(playerid, "/setdeaths [playerid/name] [amount]");
		if (PlayerInfo[targetid][pAdminLevel] == svtconf[max_admin_level] && PlayerInfo[playerid][pAdminLevel] < svtconf[max_admin_level] - 1) return Text_Send(playerid, $CLIENT_362x);

		if (IsPlayerConnected(targetid) && targetid != INVALID_PLAYER_ID) {
			PlayerInfo[targetid][pDeaths] = deaths;
			PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
			PlayerPlaySound(targetid, 1057, 0.0, 0.0, 0.0);
			
			format(String, sizeof(String), "Administrator %s changed %s's deaths to %d!", PlayerInfo[playerid][PlayerName],
				PlayerInfo[targetid][PlayerName], deaths);
			MessageToAdmins(0x2281C8FF, String);
			
			new query[120];
			format(query, sizeof(query), "Updated deaths for %s to %d.", PlayerInfo[targetid][PlayerName], deaths);
			LogAdminAction(playerid, query);
		}  else Text_Send(playerid, $CLIENT_320x);
	}
	return 1;
}

flags:seths(CMD_ADMIN);
CMD:seths(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new targetid, hs, String[140];

		if (sscanf(params, "ui", targetid, hs)) return ShowSyntax(playerid, "/seths [playerid/name] [amount]");
		if (PlayerInfo[targetid][pAdminLevel] == svtconf[max_admin_level] && PlayerInfo[playerid][pAdminLevel] < svtconf[max_admin_level] - 1) return Text_Send(playerid, $CLIENT_362x);

		if (IsPlayerConnected(targetid) && targetid != INVALID_PLAYER_ID) {
			PlayerInfo[targetid][pHeadshots] = hs;
			PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
			PlayerPlaySound(targetid, 1057, 0.0, 0.0, 0.0);

			format(String, sizeof(String), "Administrator %s changed %s's headshts to %d!", PlayerInfo[playerid][PlayerName],
				PlayerInfo[targetid][PlayerName], hs);
			MessageToAdmins(0x2281C8FF, String);
			
			new query[120];
			format(query, sizeof(query), "Updated headshots for %s to %d.", PlayerInfo[targetid][PlayerName], hs);
			LogAdminAction(playerid, query);
		}  else Text_Send(playerid, $CLIENT_320x);
	}
	return 1;
}

flags:setns(CMD_ADMIN);
CMD:setns(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new targetid, ns, String[140];

		if (sscanf(params, "ui", targetid, ns)) return ShowSyntax(playerid, "/setns [playerid/name] [amount]");
		if (PlayerInfo[targetid][pAdminLevel] == svtconf[max_admin_level] && PlayerInfo[playerid][pAdminLevel] < svtconf[max_admin_level] - 1) return Text_Send(playerid, $CLIENT_362x);

		if (IsPlayerConnected(targetid) && targetid != INVALID_PLAYER_ID) {
			PlayerInfo[targetid][pNutshots] = ns;
			PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
			PlayerPlaySound(targetid, 1057, 0.0, 0.0, 0.0);
			
			format(String, sizeof(String), "Administrator %s changed %s's nutshots to %d!", PlayerInfo[playerid][PlayerName],
				PlayerInfo[targetid][PlayerName], ns);
			MessageToAdmins(0x2281C8FF, String);
			
			new query[120];
			format(query, sizeof(query), "Updated nutshots for %s to %d.", PlayerInfo[targetid][PlayerName], ns);
			LogAdminAction(playerid, query);			
		}  else Text_Send(playerid, $CLIENT_320x);
	}
	return 1;
}

flags:setzones(CMD_ADMIN);
CMD:setzones(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new targetid, zones;

		if (sscanf(params, "ui", targetid, zones)) return ShowSyntax(playerid, "/setzones [playerid/name] [amount]");
		if (PlayerInfo[targetid][pAdminLevel] == svtconf[max_admin_level] && PlayerInfo[playerid][pAdminLevel] < svtconf[max_admin_level] - 1) return Text_Send(playerid, $CLIENT_362x);

		if (IsPlayerConnected(targetid) && targetid != INVALID_PLAYER_ID) {
			PlayerInfo[targetid][pZonesCaptured] = zones;
			PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
			PlayerPlaySound(targetid, 1057, 0.0, 0.0, 0.0);
			
			new String[128];
			format(String, sizeof(String), "Administrator %s changed %s's captured zones to %d.", PlayerInfo[playerid][PlayerName], PlayerInfo[targetid][PlayerName], zones);
			MessageToAdmins(0x2281C8FF, String);

			new query[120];
			format(query, sizeof(query), "Updated capture zones for %s to %d.", PlayerInfo[targetid][PlayerName], zones);
			LogAdminAction(playerid, query);
		}  else Text_Send(playerid, $CLIENT_320x);
	}
	return 1;
}

flags:afk(CMD_ADMIN);
CMD:afk(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new targetid;
		if (sscanf(params, "u", targetid)) return ShowSyntax(playerid, "/afk [playerid/name]");

		if (IsPlayerConnected(targetid) && targetid != INVALID_PLAYER_ID) {
			if (targetid == playerid) return Text_Send(playerid, $NEWCLIENT_193x);
			if (PlayerInfo[targetid][pAdminLevel] == svtconf[max_admin_level] && PlayerInfo[playerid][pAdminLevel] < svtconf[max_admin_level] - 1) return Text_Send(playerid, $CLIENT_362x);
			if (PlayerInfo[targetid][pAdminLevel] > PlayerInfo[playerid][pAdminLevel]) return Text_Send(playerid, $CLIENT_321x);

			foreach (new i: Player) {
				if (PlayerInfo[i][pAdminLevel]) {
					Text_Send(i, $SERVER_32x, PlayerInfo[targetid][PlayerName]);
				}
			}

			new query[256];

			mysql_format(Database, query, sizeof(query), "INSERT INTO `Punishments` (PunishedPlayer, Punisher, Action, ActionReason, PunishmentTime, ActionDate) \
					VALUES ('%e', '%e', 'Kick', '', '', '%d')", PlayerInfo[targetid][PlayerName], PlayerInfo[playerid][PlayerName], gettime());
			mysql_tquery(Database, query);

			Kick(targetid);

			new String[128];
			format(String, sizeof(String), "Administrator %s disconnected %s for being AFK.", PlayerInfo[playerid][PlayerName], PlayerInfo[targetid][PlayerName]);
			MessageToAdmins(0x2281C8FF, String);

			format(query, sizeof(query), "Disconnected player %s.", PlayerInfo[targetid][PlayerName]);
			LogAdminAction(playerid, query);			
		}  else Text_Send(playerid, $CLIENT_320x);
	}
	return 1;
}

flags:settime(CMD_ADMIN);
CMD:settime(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new targetid, time;

		if (sscanf(params, "ui", targetid, time)) return ShowSyntax(playerid, "/settime [playerid] [time]");
		if (PlayerInfo[targetid][pAdminLevel] == svtconf[max_admin_level] && PlayerInfo[playerid][pAdminLevel] < svtconf[max_admin_level] - 1) return Text_Send(playerid, $CLIENT_362x);

		if (IsPlayerConnected(targetid) && targetid != INVALID_PLAYER_ID) {
			if (PlayerInfo[targetid][pAdminLevel] > PlayerInfo[playerid][pAdminLevel]) return Text_Send(playerid, $CLIENT_321x);
			PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
			PlayerPlaySound(targetid, 1057, 0.0, 0.0, 0.0);
			SetPlayerTime(targetid, time, 0);

			new String[128];
			format(String, sizeof(String), "Administrator %s changed %s's time to %d:00.", PlayerInfo[playerid][PlayerName], PlayerInfo[targetid][PlayerName], time);
			MessageToAdmins(0x2281C8FF, String);

			new query[120];
			format(query, sizeof(query), "Updated local time for %s to %d.", PlayerInfo[targetid][PlayerName], time);
			LogAdminAction(playerid, query);			
		}  else Text_Send(playerid, $CLIENT_320x);
	}
	return 1;
}

flags:setworld(CMD_ADMIN);
CMD:setworld(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new targetid, world;

		if (sscanf(params, "ui", targetid, world)) return ShowSyntax(playerid, "/setworld [playerid] [world]");
		if (PlayerInfo[targetid][pAdminLevel] == svtconf[max_admin_level] && PlayerInfo[playerid][pAdminLevel] < svtconf[max_admin_level] - 1) return Text_Send(playerid, $CLIENT_362x);

		if (IsPlayerConnected(targetid) && targetid != INVALID_PLAYER_ID) {
			if (PlayerInfo[targetid][pAdminLevel] > PlayerInfo[playerid][pAdminLevel]) return Text_Send(playerid, $CLIENT_321x);
			PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
			PlayerPlaySound(targetid, 1057, 0.0, 0.0, 0.0);
			SetPlayerVirtualWorld(targetid, world);

			new String[128];
			format(String, sizeof(String), "Administrator %s changed %s's virtual world to %d.", PlayerInfo[playerid][PlayerName], PlayerInfo[targetid][PlayerName], world);
			MessageToAdmins(0x2281C8FF, String);

			new query[120];
			format(query, sizeof(query), "Updated local world for %s to %d.", PlayerInfo[targetid][PlayerName], world);
			LogAdminAction(playerid, query);			
		}  else Text_Send(playerid, $CLIENT_320x);
	}
	return 1;
}

flags:setinterior(CMD_ADMIN);
CMD:setinterior(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new targetid, int;

		if (sscanf(params, "ui", targetid, int)) return ShowSyntax(playerid, "/setinterior [playerid/name] [interior]");
		if (int >= 255 || int < 0) return ShowSyntax(playerid, "/setinterior [player name/id] [int id 0-254]");
		if (PlayerInfo[targetid][pAdminLevel] == svtconf[max_admin_level] && PlayerInfo[playerid][pAdminLevel] < svtconf[max_admin_level] - 1) return Text_Send(playerid, $CLIENT_362x);

		if (IsPlayerConnected(targetid) && targetid != INVALID_PLAYER_ID) {
			if (PlayerInfo[targetid][pAdminLevel] > PlayerInfo[playerid][pAdminLevel]) return Text_Send(playerid, $CLIENT_321x);
			PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
			PlayerPlaySound(targetid, 1057, 0.0, 0.0, 0.0);
			SetPlayerInterior(targetid, int);

			new String[128];
			format(String, sizeof(String), "Administrator %s changed %s's interior to %d.", PlayerInfo[playerid][PlayerName], PlayerInfo[targetid][PlayerName], int);
			MessageToAdmins(0x2281C8FF, String);
			new query[120];
			format(query, sizeof(query), "Updated local interior for %s to %d.", PlayerInfo[targetid][PlayerName], int);
			LogAdminAction(playerid, query);
		}  else Text_Send(playerid, $CLIENT_320x);
	}
	return 1;
}

flags:givecar(CMD_ADMIN);
CMD:givecar(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new carid, targetid;
		if (sscanf(params, "ui", targetid, carid)) return ShowSyntax(playerid, "/givecar [playerid/name] [car]");

		if (PlayerInfo[targetid][pAdminLevel] == svtconf[max_admin_level] && PlayerInfo[playerid][pAdminLevel] < svtconf[max_admin_level] - 1) return Text_Send(playerid, $CLIENT_362x);

		if (IsPlayerConnected(targetid) && targetid != INVALID_PLAYER_ID && targetid != playerid) {
			if (IsPlayerInAnyVehicle(targetid)) return Text_Send(playerid, $NEWCLIENT_194x);
			if (carid < 400 || carid > 611) return ShowSyntax(playerid, "/givecar [player name/id] [vehicle id 400-610]");
			
			new Float:x, Float:y, Float:z;
			GetPlayerPos(targetid, x, y, z);

			CarSpawner(targetid, carid);
			PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
			PlayerPlaySound(targetid, 1068, 0.0, 0.0, 0.0);
			
			new String[128];
			format(String, sizeof(String), "Administrator %s spawned a vehicle for %s (model: %d).", PlayerInfo[playerid][PlayerName], PlayerInfo[targetid][PlayerName], carid);
			MessageToAdmins(0x2281C8FF, String);

			new query[120];
			format(query, sizeof(query), "Gave %d a car with model %d.", PlayerInfo[targetid][PlayerName], carid);
			LogAdminAction(playerid, query);			
		}  else Text_Send(playerid, $CLIENT_319x);
	}
	return 1;
}

flags:eject(CMD_ADMIN);
CMD:eject(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new targetid, Float:x, Float:y, Float:z;
		if (sscanf(params, "u", targetid)) return ShowSyntax(playerid, "/eject [playerid/name]");

		if (PlayerInfo[targetid][pAdminLevel] == svtconf[max_admin_level] && PlayerInfo[playerid][pAdminLevel] < svtconf[max_admin_level] - 1) return Text_Send(playerid, $CLIENT_362x);
		if (IsPlayerConnected(targetid) && targetid != INVALID_PLAYER_ID) {
			if (IsPlayerInAnyVehicle(targetid)) {
				GetPlayerPos(targetid, x, y, z);
				SetPlayerPos(targetid, x, y, z + 3);

				new String[128];
				format(String, sizeof(String), "Administrator %s ejected %s from their vehicle.", PlayerInfo[playerid][PlayerName], PlayerInfo[targetid][PlayerName]);
				MessageToAdmins(0x2281C8FF, String);

				new query[120];
				format(query, sizeof(query), "Ejected %s from their vehicle.", PlayerInfo[targetid][PlayerName]);
				LogAdminAction(playerid, query);			
			}  else Text_Send(playerid, $NEWCLIENT_194x);
		}  else Text_Send(playerid, $CLIENT_320x);
	}
	return 1;
}

flags:givecash(CMD_ADMIN);
CMD:givecash(playerid, params[]) {
	new ID, money;

	if (PlayerInfo[playerid][pAdminLevel]) {
		if (sscanf(params, "ui", ID, money)) return ShowSyntax(playerid, "/givecash [playerid/name] [amount]");
		if (!IsPlayerConnected(ID)) return Text_Send(playerid, $CLIENT_320x);

		GivePlayerCash(ID, money);
		PlayerPlaySound(ID, 1057, 0.0, 0.0, 0.0);
		PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
	
		new String[128];
		format(String, sizeof(String), "Administrator %s forced %s into team selection.", PlayerInfo[playerid][PlayerName], PlayerInfo[ID][PlayerName]);
		MessageToAdmins(0x2281C8FF, String);

		new query[120];
		format(query, sizeof(query), "Gave $%d to %s.", money, PlayerInfo[ID][PlayerName]);
		LogAdminAction(playerid, query);			
	}
	return 1;
}

flags:lockcar(CMD_ADMIN);
CMD:lockcar(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		if (IsPlayerInAnyVehicle(playerid)) {
			foreach (new i: Player) {
				SetVehicleParamsForPlayer(GetPlayerVehicleID(playerid), i, false, true);
			}
			PlayerInfo[playerid][pDoorsLocked] = 1;
			new String[128];
			format(String, sizeof(String), "Administrator %s locked their own vehicle.", PlayerInfo[playerid][PlayerName]);
			MessageToAdmins(0x2281C8FF, String);
		}  else Text_Send(playerid, $CLIENT_420x);
	}
	return 1;
}

flags:unlockcar(CMD_ADMIN);
CMD:unlockcar(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		if (IsPlayerInAnyVehicle(playerid)) {
			foreach (new i: Player) {
				SetVehicleParamsForPlayer(GetPlayerVehicleID(playerid), i, false, false);
			}
			PlayerInfo[playerid][pDoorsLocked] = 0;
			new String[128];
			format(String, sizeof(String), "Administrator %s unlocked their own vehicle.", PlayerInfo[playerid][PlayerName]);
			MessageToAdmins(0x2281C8FF, String);
		}  else Text_Send(playerid, $CLIENT_420x);
	}
	return 1;
}

flags:burn(CMD_ADMIN);
CMD:burn(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new targetid, Float:x, Float:y, Float:z;
		if (sscanf(params, "u", targetid)) return ShowSyntax(playerid, "/burn [playerid/name]");

		if (IsPlayerConnected(targetid) && targetid != INVALID_PLAYER_ID) {
			if (PlayerInfo[targetid][pAdminLevel] == svtconf[max_admin_level] && PlayerInfo[playerid][pAdminLevel] < PlayerInfo[targetid][pAdminLevel])
				return Text_Send(playerid, $CLIENT_362x);
			GetPlayerPos(targetid, x, y, z);
			CreateExplosion(x, y , z + 3, 1, 10);

			new String[128];
			format(String, sizeof(String), "Administrator %s burnt %s.", PlayerInfo[playerid][PlayerName], PlayerInfo[targetid][PlayerName]);
			MessageToAdmins(0x2281C8FF, String);

			new query[120];
			format(query, sizeof(query), "Burnt out %s.", PlayerInfo[targetid][PlayerName]);
			LogAdminAction(playerid, query);			
		}  else Text_Send(playerid, $CLIENT_320x);
	}
	return 1;
}

flags:spawn(CMD_ADMIN);
CMD:spawn(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new targetid;
		if (sscanf(params, "u", targetid)) return ShowSyntax(playerid, "/spawn [playerid/name]");

		if (IsPlayerConnected(targetid) && targetid != INVALID_PLAYER_ID && IsPlayerSpawned(targetid)) {
			if (PlayerInfo[targetid][pAdminLevel] == svtconf[max_admin_level] && PlayerInfo[playerid][pAdminLevel] < PlayerInfo[targetid][pAdminLevel])
				return Text_Send(playerid, $CLIENT_362x);

			SpawnPlayer(targetid);
			PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);

			new String[128];
			format(String, sizeof(String), "Administrator %s spawned %s.", PlayerInfo[playerid][PlayerName], PlayerInfo[targetid][PlayerName]);
			MessageToAdmins(0x2281C8FF, String);

			new query[120];
			format(query, sizeof(query), "Spawned player %s.", PlayerInfo[targetid][PlayerName]);
			LogAdminAction(playerid, query);			
		}  else Text_Send(playerid, $NEWCLIENT_193x);
	}
	return 1;
}

flags:disarm(CMD_ADMIN);
CMD:disarm(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new targetid;
		if (sscanf(params, "u", targetid)) return ShowSyntax(playerid, "/disarm [playerid/name]");

		if (IsPlayerConnected(targetid) && targetid != INVALID_PLAYER_ID) {
			if (PlayerInfo[targetid][pAdminLevel] == svtconf[max_admin_level] && PlayerInfo[playerid][pAdminLevel] < PlayerInfo[targetid][pAdminLevel])
				return Text_Send(playerid, $CLIENT_362x);

			PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
			ResetPlayerWeapons(targetid);

			new String[128];
			format(String, sizeof(String), "Administrator %s disarmed %s.", PlayerInfo[playerid][PlayerName], PlayerInfo[targetid][PlayerName]);
			MessageToAdmins(0x2281C8FF, String);

			new query[120];
			format(query, sizeof(query), "Disarmed player %s.", PlayerInfo[targetid][PlayerName]);
			LogAdminAction(playerid, query);
		}  else Text_Send(playerid, $CLIENT_320x);
	}
	return 1;
}

CMD:crash(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel] == svtconf[max_admin_level]) {
		new targetid;
		if (sscanf(params, "u", targetid)) return ShowSyntax(playerid, "/crash [playerid/name]");

		if (IsPlayerConnected(targetid) && targetid != INVALID_PLAYER_ID) {
			if (PlayerInfo[targetid][pAdminLevel] == svtconf[max_admin_level] && PlayerInfo[playerid][pAdminLevel] < PlayerInfo[targetid][pAdminLevel])
				return Text_Send(playerid, $CLIENT_362x);

			for (new i = 0; i < 2000; i++) {
				RemoveBuildingForPlayer(targetid, -1, 0.0, 0.0, 0.0, 1000.25);
			}

			new query[120];
			format(query, sizeof(query), "Crashed player %s.", PlayerInfo[targetid][PlayerName]);
			LogAdminAction(playerid, query);			
		}  else Text_Send(playerid, $CLIENT_320x);
	}
	return 1;
}

flags:ip(CMD_ADMIN | CMD_MOD);
CMD:ip(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel] || PlayerInfo[playerid][pIsModerator]) {
		new targetid, String[140];
		if (sscanf(params, "u", targetid)) return ShowSyntax(playerid, "/ip [playerid/name]");

		if (IsPlayerConnected(targetid) && targetid != INVALID_PLAYER_ID) {
			if (PlayerInfo[targetid][pAdminLevel] == svtconf[max_admin_level] && PlayerInfo[playerid][pAdminLevel] < PlayerInfo[targetid][pAdminLevel])
				return Text_Send(playerid, $CLIENT_362x);

			PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);

			format(String, sizeof(String), "%s's IP: %s", PlayerInfo[targetid][PlayerName], PlayerInfo[targetid][pIP]);
			SendClientMessage(playerid, 0x2281C8FF, String);

			new query[120];
			format(query, sizeof(query), "Fetched player %s's IP address.", PlayerInfo[targetid][PlayerName]);
			LogAdminAction(playerid, query);			
		}  else Text_Send(playerid, $CLIENT_320x);
	}
	return 1;
}

flags:rangecheck(CMD_ADMIN);
CMD:rangecheck(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new found = 1, String[128];

		new ip[25];
		if (sscanf(params, "s[25]", ip)) return ShowSyntax(playerid, "/rangecheck [pIP]");

		format(String, sizeof(String), "Range check for: \"%s\" ", ip);
		SendClientMessage(playerid, 0x2281C8FF, String);

		foreach(new i: Player) {
			if (IsPlayerConnected(i)) {
				if (!strfind(PlayerInfo[playerid][pIP], ip, true)) {
					found++;
					format(String, sizeof(String), "No. %d IP: %s {E8E8E8}%s[%d]", found, PlayerInfo[i][pIP], PlayerInfo[i][PlayerName], i);
					SendClientMessage(playerid, X11_DEEPSKYBLUE, String);
				}
			}
		}
		if (found == 0) Text_Send(playerid, $CLIENT_423x);
	}
	return 1;
}

alias:rangecheck("ipcheck");

//Why was that so important..
flags:freehunter(CMD_ADMIN);
CMD:freehunter(playerid) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		if (FreeHunter) {
			FreeHunter = false;
		} else {
			FreeHunter = true;
		}
	}
	return 1;
}

flags:getinfo(CMD_ADMIN);
CMD:getinfo(playerid, params[]) {
	new targetid, information_string[250],

	Float: Health, Float: Armour,
	Float: X, Float: Y, Float: Z, Int, World,
	Vehicle_ID, Vehicle_Model, Float: Vehicle_Health, Float: Velocity,
	sKills, sDeaths, sShoots,
	Surfing_Vehicle = INVALID_VEHICLE_ID, Surfing_Object = INVALID_OBJECT_ID;

	if (sscanf(params, "u", targetid)) return ShowSyntax(playerid, "/getinfo [playerid/name]");
	if (!IsPlayerConnected(targetid)) return Text_Send(playerid, $CLIENT_320x);

	format(information_string, sizeof(information_string), "Player %s[%d]:", PlayerInfo[targetid][PlayerName], targetid);
	SendClientMessage(playerid, 0xE8E8E8FF, information_string);

	format(information_string, sizeof(information_string), "/weaps %d", targetid);
	PC_EmulateCommand(playerid, information_string);

	GetPlayerPos(targetid, X, Y, Z);

	Int = GetPlayerInterior(targetid);
	World = GetPlayerVirtualWorld(targetid);

	Velocity = GetPlayerSpeed(targetid);
	Surfing_Vehicle = GetPlayerSurfingVehicleID(targetid);
	Surfing_Object = GetPlayerSurfingObjectID(targetid);

	sKills = PlayerInfo[targetid][pSessionKills];
	sDeaths = PlayerInfo[targetid][pSessionDeaths];
	sShoots = PlayerInfo[targetid][pSessionGunFires];

	GetPlayerHealth(targetid, Health);
	GetPlayerArmour(targetid, Armour);

	format(information_string, sizeof(information_string), "X: %0.2f, Y: %0.2f, Z: %0.2f, Interior: %d, World: %d", X, Y, Z, Int, World);
	SendClientMessage(playerid, X11_DEEPSKYBLUE, information_string);

	format(information_string, sizeof(information_string), "Speed: %0.2f KM/H, Health: %0.2f, Armour: %0.2f, Weapon: %d, Ammo: %d", Velocity, Health, Armour, GetPlayerWeapon(targetid), GetPlayerAmmo(targetid));
	SendClientMessage(playerid, X11_DEEPSKYBLUE, information_string);

	if (Surfing_Object != INVALID_OBJECT_ID) {
		format(information_string, sizeof(information_string), "Surfing Object: %d, X: %0.2f, Y: %0.2f, Z: %0.2f", Surfing_Object, X, Y, Z);
		SendClientMessage(playerid, X11_DEEPSKYBLUE, information_string);
	}

	if (Surfing_Vehicle != INVALID_VEHICLE_ID) {
		format(information_string, sizeof(information_string), "Surfing Vehicle: %d, X: %0.2f, Y: %0.2f, Z: %0.2f", Surfing_Vehicle, X, Y, Z);
		SendClientMessage(playerid, X11_DEEPSKYBLUE, information_string);
	}

	if (IsPlayerInAnyVehicle(playerid)) {
		Vehicle_ID = GetPlayerVehicleID(targetid);
		Vehicle_Model = GetVehicleModel(Vehicle_ID);
		Velocity = GetVehicleSpeed(Vehicle_ID);

		GetVehicleHealth(Vehicle_ID, Vehicle_Health);

		format(information_string, sizeof(information_string), "Vehicle: %s, Model: %d, ID: %d, Velocity: %0.2f KM/H, V/HP: %0.2f", VehicleNames[Vehicle_Model - 400], Vehicle_Model, Vehicle_ID, Velocity, Vehicle_Health);
		SendClientMessage(playerid, X11_DEEPSKYBLUE, information_string);
	}

	format(information_string, sizeof(information_string), "Session Kills: %d, Session Deaths: %d, Session Shoots: %d", sKills, sDeaths, sShoots);
	SendClientMessage(playerid, X11_DEEPSKYBLUE, information_string);

	format(information_string, sizeof(information_string), "Deathmatch: %d, Duel: %d, Event: %d", PlayerInfo[targetid][pDeathmatchId], pDuelInfo[targetid][pDInMatch], Iter_Contains(ePlayers, targetid));
	SendClientMessage(playerid, X11_DEEPSKYBLUE, information_string);
	
	format(information_string, sizeof(information_string), "Team: %s, Class: %s (%d), Skin: %d, Coins: %f", TeamInfo[pTeam[targetid]][Team_Name], ClassInfo[pClass[targetid]][Class_Name], pAdvancedClass[targetid], GetPlayerSkin(playerid), PlayerInfo[targetid][pCoins]);
	SendClientMessage(playerid, X11_DEEPSKYBLUE, information_string);    
	return 1;
}

flags:aweaps(CMD_ADMIN);
CMD:aweaps(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		GivePlayerWeapon(playerid, 28, 1000);
		GivePlayerWeapon(playerid, 31, 1000);
		GivePlayerWeapon(playerid, 34, 1000);
		GivePlayerWeapon(playerid, 38, 1000);
		GivePlayerWeapon(playerid, 16, 1000);
		GivePlayerWeapon(playerid, 42, 1000);
		GivePlayerWeapon(playerid, 14, 1000);
		GivePlayerWeapon(playerid, 46, 1000);
		GivePlayerWeapon(playerid, 24, 1000);
		GivePlayerWeapon(playerid, 26, 1000);

	}
	return 1;
}

flags:aammo(CMD_ADMIN);
CMD:aammo(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		MaxAmmo(playerid);
	}
	return 1;
}

flags:afix(CMD_ADMIN);
CMD:afix(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		if (IsPlayerInAnyVehicle(playerid)) {
			RepairVehicle(GetPlayerVehicleID(playerid));
			SetVehicleHealth(GetPlayerVehicleID(playerid), 1000);
		}  else Text_Send(playerid, $CLIENT_420x);
	}
	return 1;
}

flags:atune(CMD_ADMIN);
CMD:atune(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		if (IsPlayerInAnyVehicle(playerid)) {
			new LVehicleID = GetPlayerVehicleID(playerid), LModel = GetVehicleModel(LVehicleID);

			switch (LModel) {
				case 448, 461, 462, 463, 468, 471, 509, 510, 521, 522, 523, 581, 586, 449: return Text_Send(playerid, $CLIENT_426x);
			}

			SetVehicleHealth(LVehicleID, 2000.0);

			Tuneacar(LVehicleID);
			RepairVehicle(LVehicleID);

			PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);

		}  else Text_Send(playerid, $CLIENT_420x);
	}
	return 1;
}

flags:givescore(CMD_ADMIN);
CMD:givescore(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new targetid, amount;

		if (sscanf(params, "ud", targetid, amount)) return ShowSyntax(playerid, "/givescore [playerid/partname] [amount]");
		if (!IsPlayerConnected(targetid)) return Text_Send(playerid, $NEWCLIENT_193x);
		if (amount > 100000 || amount <= 0) return ShowSyntax(playerid, "/givescore [player name/id] [score 0-100000]");
		GivePlayerScore(targetid, amount);
		PlayerPlaySound(targetid, 1057, 0.0, 0.0, 0.0);

		new String[128];
		format(String, sizeof(String), "Administrator %s gave %s %d score.", PlayerInfo[playerid][PlayerName], PlayerInfo[targetid][PlayerName], amount);
		MessageToAdmins(0x2281C8FF, String);

		new query[120];
		format(query, sizeof(query), "Gave %d score for player %s.", amount, PlayerInfo[targetid][PlayerName]);
		LogAdminAction(playerid, query);
	}    
	return 1;
}

flags:giveall(CMD_ADMIN);
CMD:giveall(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		if (isnull(params)) return ShowSyntax(playerid, "/giveall [item name]");

		new valid_item = 0;

		for(new i = 0; i < sizeof(ItemsInfo); i++) {
			if (!strcmp(params, ItemsInfo[i][Item_Name], true)) {
				Text_Send(@pVerified, $NEWSERVER_36x, PlayerInfo[playerid][PlayerName], ItemsInfo[i][Item_Name]);

				foreach(new x: Player) {
					AddPlayerItem(x, i, 1);
					PlayerPlaySound(x, 1057, 0.0, 0.0, 0.0);
				}

				new string[25];
				format(string, sizeof(string), "~g~%s", ItemsInfo[i][Item_Name]);
				GameTextForAll(string, 5000, 3);

				valid_item = 1;

				new query[120];
				format(query, sizeof(query), "Gave everyone an item: %s.", ItemsInfo[i][Item_Name]);
				LogAdminAction(playerid, query);
				break;
			}
		}

		if (!valid_item) {
			Text_Send(playerid, $CLIENT_423x);
		}
	}    
	return 1;
}

//Fun commands

flags:morning(CMD_ADMIN);
CMD:morning(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		SetPlayerTime(playerid, 7, 0);
	}    
	return 1;
}

flags:adminarea(CMD_ADMIN);
CMD:adminarea(playerid) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		SetPlayerPos(playerid, 384.808624, 173.804992, 1008.382812);
		SetPlayerFacingAngle(playerid, 90.0);

		SetPlayerInterior(playerid, 3);
		SetPlayerVirtualWorld(playerid, SPECIAL_WORLD);

		new Float: HP, Float: AR;
		GetPlayerHealth(playerid, HP);
		GetPlayerArmour(playerid, AR);
		printf("[ADMIN] %s[%d] went to admin area with %d HP and %d AR. Duty: %d",
			PlayerInfo[playerid][PlayerName], playerid, HP, AR, PlayerInfo[playerid][pAdminDuty]);
	}
	return 1;
}

flags:hy(CMD_ADMIN);
CMD:hy(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		if (IsPlayerInAnyVehicle(playerid)) {
			new LVehicleID = GetPlayerVehicleID(playerid), LModel = GetVehicleModel(LVehicleID);

			switch (LModel)
			{
				case 448,461,462,463,468,471,509,510,521,522,523,581,586,449: return Text_Send(playerid, $CLIENT_426x);
			}

			AddVehicleComponent(LVehicleID, 1087);

			PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
		}  else Text_Send(playerid, $CLIENT_420x);
	}
	return 1;
}

flags:acar(CMD_ADMIN);
CMD:acar(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		if (!IsPlayerInAnyVehicle(playerid)) {
			CarSpawner(playerid, 415);
		}  else Text_Send(playerid, $CLIENT_420x);
	}
	return 1;
}

flags:abike(CMD_ADMIN);
CMD:abike(playerid) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		if (!IsPlayerInAnyVehicle(playerid)) {
			CarSpawner(playerid, 522);
		}  else Text_Send(playerid, $CLIENT_420x);
	}    
	return 1;
}

flags:aheli(CMD_ADMIN);
CMD:aheli(playerid) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		if (!IsPlayerInAnyVehicle(playerid)) {
			CarSpawner(playerid, 487);
		}  else Text_Send(playerid, $CLIENT_420x);
	}    
	return 1;
}

flags:aboat(CMD_ADMIN);
CMD:aboat(playerid) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		if (!IsPlayerInAnyVehicle(playerid)) {
			CarSpawner(playerid, 493);
		}  else Text_Send(playerid, $CLIENT_420x);
	}    
	return 1;
}

flags:aplane(CMD_ADMIN);
CMD:aplane(playerid) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		if (!IsPlayerInAnyVehicle(playerid)) {
			CarSpawner(playerid, 513);
		}  else Text_Send(playerid, $CLIENT_420x);
	}    
	return 1;
}

flags:anos(CMD_ADMIN);
CMD:anos(playerid) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		if (IsPlayerInAnyVehicle(playerid)) {
			switch (GetVehicleModel( GetPlayerVehicleID(playerid) )) {
				case 448, 461, 462, 463, 468, 471, 509, 510, 521, 522, 523, 581,586, 449: return Text_Send(playerid, $CLIENT_426x);
			}
			AddVehicleComponent(GetPlayerVehicleID(playerid), 1010);
		}  else Text_Send(playerid, $CLIENT_420x);
	}    
	return 1;
}

flags:car(CMD_ADMIN);
CMD:car(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new car, Carstr[90];
		if (sscanf(params, "s[90]", Carstr)) return ShowSyntax(playerid, "/car [modelid/name]");
		if (IsPlayerInAnyVehicle(playerid)) return Text_Send(playerid, $CLIENT_420x);
		if (!IsNumeric(Carstr))
		{
		   car = GetVehicleModelIDFromName(Carstr);

		} else car = strval(Carstr);

		if (car < 400 || car > 611) return ShowSyntax(playerid, "/car [vehicle id 400-610/name]");
		if (PlayerInfo[playerid][pCar] != -1) DestroyVehicle(PlayerInfo[playerid][pCar]);
		PlayerInfo[playerid][pCar] = -1;

		new LVehicleID, Float:X, Float:Y, Float:Z, Float:Angle, int1;

		GetPlayerPos(playerid, X, Y, Z);
		GetPlayerFacingAngle(playerid, Angle);

		int1 = GetPlayerInterior(playerid);

		LVehicleID = CreateVehicle(car, X + 3, Y, Z + 2, Angle, 0, 7, -1);
		pVehId[playerid] = PlayerInfo[playerid][pCar] = LVehicleID;

		LinkVehicleToInterior(LVehicleID, int1);

		new world;
		world = GetPlayerVirtualWorld(playerid);
		SetVehicleVirtualWorld(LVehicleID, world);

		PutPlayerInVehicle(playerid, PlayerInfo[playerid][pCar], 0);
	}
	return 1;
}

flags:carhealth(CMD_ADMIN);
CMD:carhealth(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new targetid, health;

		if (sscanf(params, "ui", targetid, health)) return ShowSyntax(playerid, "/carhealth [playerid/name] [amount]");
		if (PlayerInfo[targetid][pAdminLevel] == svtconf[max_admin_level] && PlayerInfo[playerid][pAdminLevel] < svtconf[max_admin_level] - 1) return Text_Send(playerid, $CLIENT_362x);
		if (IsPlayerConnected(targetid) && targetid != INVALID_PLAYER_ID) {
			if (IsPlayerInAnyVehicle(targetid)) {
				SetVehicleHealth(GetPlayerVehicleID(targetid), health);
			}  else Text_Send(playerid, $NEWCLIENT_194x);
		}  else Text_Send(playerid, $CLIENT_320x);
	}    
	return 1;
}

flags:carcolor(CMD_ADMIN);
CMD:carcolor(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new targetid, colour1, colour2;

		if (sscanf(params, "uii", targetid, colour1, colour2)) return ShowSyntax(playerid, "/carcolor [playerid/name] [colour1] [colour2]");

		if (PlayerInfo[targetid][pAdminLevel] == svtconf[max_admin_level] && PlayerInfo[playerid][pAdminLevel] < svtconf[max_admin_level] - 1) return Text_Send(playerid, $CLIENT_362x);

		if (IsPlayerConnected(targetid) && targetid != INVALID_PLAYER_ID) {
			if (IsPlayerInAnyVehicle(targetid)) {
				ChangeVehicleColor(GetPlayerVehicleID(targetid), colour1, colour2);
			}  else Text_Send(playerid, $NEWCLIENT_194x);
		}  else Text_Send(playerid, $CLIENT_320x);
	}    
	return 1;
}

flags:jetpack(CMD_ADMIN);
CMD:jetpack(playerid, params[]) {
	if (isnull(params)) {
		if (PlayerInfo[playerid][pAdminLevel]) {
			SetPlayerSpecialAction(playerid, 2);
		}
	} else {
		new targetid;
		targetid = strval(params);
		if (PlayerInfo[playerid][pAdminLevel]) {
			if (IsPlayerConnected(targetid) && targetid != INVALID_PLAYER_ID && targetid != playerid)
			 {
				SetPlayerSpecialAction(targetid, 2);
				pJetpack[targetid] = 1;
			}  else Text_Send(playerid, $CLIENT_319x);
		}
	}    
	return 1;
}

flags:aflip(CMD_ADMIN);
CMD:aflip(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		if (isnull(params)) {
			if (IsPlayerInAnyVehicle(playerid)) {
				new VehicleID, Float:X, Float:Y, Float:Z, Float:Angle;
				GetPlayerPos(playerid, X, Y, Z);
				VehicleID = GetPlayerVehicleID(playerid);

				GetVehicleZAngle(VehicleID, Angle);
				SetVehiclePos(VehicleID, X, Y, Z);

				SetVehicleZAngle(VehicleID, Angle);

				SetVehicleHealth(VehicleID, 1000.0);
				return 1;

			}  else Text_Send(playerid, $CLIENT_420x);
		}

		new targetid;
		targetid = strval(params);

		if (IsPlayerConnected(targetid) && targetid != INVALID_PLAYER_ID && targetid != playerid) {
			if (IsPlayerInAnyVehicle(targetid)) {
				new VehicleID, Float:X, Float:Y, Float:Z, Float:Angle;

				GetPlayerPos(targetid, X, Y, Z);
				VehicleID = GetPlayerVehicleID(targetid);

				GetVehicleZAngle(VehicleID, Angle);
				SetVehiclePos(VehicleID, X, Y, Z);

				SetVehicleZAngle(VehicleID, Angle);
				SetVehicleHealth(VehicleID, 1000.0);
			}  else Text_Send(playerid, $NEWCLIENT_194x);
		}  else Text_Send(playerid, $CLIENT_319x);
	}
	return 1;
}

flags:destroycar(CMD_ADMIN);
CMD:destroycar(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		if (PlayerInfo[playerid][pCar] != -1) DestroyVehicle(PlayerInfo[playerid][pCar]);
		PlayerInfo[playerid][pCar] = -1;
	}
	return 1;
}

flags:atc(CMD_ADMIN);
CMD:atc(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		if (!IsPlayerInAnyVehicle(playerid)) {
			if (PlayerInfo[playerid][pCar] != -1) DestroyVehicle(PlayerInfo[playerid][pCar]);
			PlayerInfo[playerid][pCar] = -1;

			new Float:X, Float:Y, Float:Z, Float:Angle, Tunedcar;
			GetPlayerPos(playerid, X, Y, Z);

			GetPlayerFacingAngle(playerid, Angle);
			Tunedcar = CreateVehicle(560, X, Y, Z, Angle, 1, -1, -1);
			PutPlayerInVehicle(playerid, Tunedcar, 0);

			AddVehicleComponent(Tunedcar, 1028);
			AddVehicleComponent(Tunedcar, 1030);
			AddVehicleComponent(Tunedcar, 1031);
			AddVehicleComponent(Tunedcar, 1138);
			AddVehicleComponent(Tunedcar, 1140);
			AddVehicleComponent(Tunedcar, 1170);
			AddVehicleComponent(Tunedcar, 1028);
			AddVehicleComponent(Tunedcar, 1030);
			AddVehicleComponent(Tunedcar, 1031);
			AddVehicleComponent(Tunedcar, 1138);
			AddVehicleComponent(Tunedcar, 1140);
			AddVehicleComponent(Tunedcar, 1170);
			AddVehicleComponent(Tunedcar, 1080);
			AddVehicleComponent(Tunedcar, 1086);
			AddVehicleComponent(Tunedcar, 1087);
			AddVehicleComponent(Tunedcar, 1010);

			PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
			ChangeVehiclePaintjob(Tunedcar, 0);

			SetVehicleVirtualWorld(Tunedcar, GetPlayerVirtualWorld(playerid));
			LinkVehicleToInterior(Tunedcar, GetPlayerInterior(playerid));

			pVehId[playerid] = PlayerInfo[playerid][pCar] = Tunedcar;
		}  else Text_Send(playerid, $CLIENT_420x);
	}
	return 1;
}

//Alerts

flags:asay(CMD_ADMIN);
CMD:asay(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		if (isnull(params)) return ShowSyntax(playerid, "/asay [text]");

		new String[140], aRank[40];
		
		switch (PlayerInfo[playerid][pAdminLevel]) {
			case 0: aRank = "Moderator"; 
			case 1: aRank = "Trial Admin"; 
			case 2: aRank = "Senior Admin"; 
			case 3: aRank = "Lead Admin"; 
			case 4: aRank = "Head Admin"; 
			case 5: aRank = "Assistant Manager"; 
			case 6: aRank = "Manager"; 
			case 7: aRank = "Lead Manager"; 
			case 8: aRank = "CEO";
		}

		format(String, sizeof(String), "***%s: %s", aRank, params);
		SendClientMessageToAll(0x6700A6FF, String);
	}
	return 1;
}

flags:ann(CMD_ADMIN);
CMD:ann(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		if (isnull(params)) return ShowSyntax(playerid, "/announce <text>");
		GameTextForAll(params, 4000, 3);
	}    
	return 1;
}

flags:ann2(CMD_ADMIN);
CMD:ann2(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new style, time, text[80];
		if (sscanf(params, "iis[80]", style, time, text)) return ShowSyntax(playerid, "/announce2 <style> <time> <text>");
		if (style > 6 || style < 0 || style == 2) return Text_Send(playerid, $CLIENT_422x);

		GameTextForAll(text, time, style);
	}    
	return 1;
}

alias:ann("announce");
alias:ann2("announce2");

//Teleport

flags:teleplayer(CMD_ADMIN);
CMD:teleplayer(playerid, params[]) {
	new targetid, player2, Float:plocx, Float:plocy, Float:plocz;

	if (PlayerInfo[playerid][pAdminLevel]) {
		if (sscanf(params, "uu", targetid, player2)) return ShowSyntax(playerid, "/teleplayer [playerid/name] [targetid/name]");

		if (PlayerInfo[targetid][pAdminLevel] == svtconf[max_admin_level] && PlayerInfo[playerid][pAdminLevel] < svtconf[max_admin_level] - 1) return Text_Send(playerid, $CLIENT_362x);

		if (IsPlayerConnected(targetid) && targetid != INVALID_PLAYER_ID) {
			if (IsPlayerConnected(player2) && player2 != INVALID_PLAYER_ID) {
				GetPlayerPos(player2, plocx, plocy, plocz);

				new intid = GetPlayerInterior(player2);

				SetPlayerInterior(targetid,intid);
				SetPlayerVirtualWorld(targetid, GetPlayerVirtualWorld(player2));

				if (GetPlayerState(targetid) == PLAYER_STATE_DRIVER) {
					new VehicleID = GetPlayerVehicleID(targetid);
					SetVehiclePos(VehicleID, plocx, plocy + 4, plocz);

					LinkVehicleToInterior(VehicleID, intid);
					SetVehicleVirtualWorld(VehicleID, GetPlayerVirtualWorld(player2));
				} else SetPlayerPos(targetid, plocx, plocy + 2, plocz);
			}  else Text_Send(playerid, $NEWCLIENT_193x);
		}  else Text_Send(playerid, $NEWCLIENT_193x);
	}
	return 1;
}

flags:teles(CMD_ADMIN);
CMD:teles(playerid) {
	if (!PlayerInfo[playerid][pAdminLevel]) return 1;

	inline AdminTeleports(pid, dialogid, response, listitem, string:inputtext[]) {
		#pragma unused dialogid, inputtext
		if (!response) return 1;
		switch (listitem) {
			case 0: {
				SetPlayerPosition(pid, "Sherman dam", 0, 17,   -959.564392,1848.576782,9.000000);
			}
			case 1: {
				SetPlayerPosition(pid, "Warehouse", 0, 18,     1302.519897,-1.787510,1001.028259);
			}
			case 2: {
				SetPlayerPosition(pid, "SF Police HQ", 0, 10, 246.375991,109.245994,1003.218750);
			}
			case 3: {
				SetPlayerPosition(pid, "LS Police HQ", 0,  6, 246.783996,63.900199,1003.640625);
			}
			case 4: {
				SetPlayerPosition(pid, "Shamal", 0, 1,     1.808619,32.384357,1199.593750);
			}
			case 5: {
				SetPlayerPosition(pid, "Jefferson motel", 0, 15,   2215.454833,-1147.475585,1025.796875);
			}
			case 6: {
				SetPlayerPosition(pid, "Betting shop", 0, 3,   833.269775,10.588416,1004.179687);
			}
			case 7: {
				SetPlayerPosition(pid, "Sex shop", 0, 3,   -103.559165,-24.225606,1000.718750);
			}
			case 8: {
				SetPlayerPosition(pid, "Meat factory", 0, 1,   963.418762,2108.292480,1011.030273);
			}
			case 9: {
				SetPlayerPosition(pid, "RC shop", 0, 6,    -2240.468505,137.060440,1035.414062);
			}
			case 10:  {
				SetPlayerPosition(pid, "Catigula's basement", 0, 1,    2169.461181,1618.798339,999.976562);
			}
			case 11:  {
				SetPlayerPosition(pid, "Woozie's office", 0, 1,    -2159.122802,641.517517,1052.381713);
			}
			case 12:  {
				SetPlayerPosition(pid, "Binco", 0, 15, 207.737991,-109.019996,1005.132812);
			}
			case 13:  {
				SetPlayerPosition(pid, "Jay's diner", 0, 4,    457.304748,-88.428497,999.554687);
			}
			case 14:  {
				SetPlayerPosition(pid, "Burger shot", 0, 10,   375.962463,-65.816848,1001.507812);
			}
			case 15:  {
				SetPlayerPosition(pid, "LS Gym", 0,    5,  772.111999,-3.898649,1000.728820);
			}
			case 16:  {
				SetPlayerPosition(pid, "Sweet's house", 0, 1,  2527.654052,-1679.388305,1015.498596);
			}
			case 17:  {
				SetPlayerPosition(pid, "Crack factory", 0, 2,  2543.462646,-1308.379882,1026.728393);
			}
			case 18:  {
				SetPlayerPosition(pid, "Strip club", 0, 2,     1204.809936,-11.586799,1000.921875);
			}
			case 19: {
				SetPlayerPosition(pid, "Pleasure domes", 0, 3, -2640.762939,1406.682006,906.460937);
			}
			case 20: {
				SetPlayerPosition(pid, "8-Track", 0, 7, -1398.065307,-217.028900,1051.115844);
			}
			case 21: {
				SetPlayerPosition(pid, "Bloodbowl", 0, 15, -1398.103515,937.631164,1036.479125);
			}
			case 22: {
				SetPlayerPosition(pid, "Vice stadium", 0, 1, -1401.829956,107.051300,1032.273437);
			}
			case 23: {
				SetPlayerPosition(pid, "Kickstart", 0, 14, -1465.268676,1557.868286,1052.531250);
			}
			case 24: {
				SetPlayerPosition(pid, "RC Battlefield", 0, 10, -975.975708,1060.983032,1345.671875);
			}
			case 25: {
				SetPlayerPosition(pid, "LS Atruim", 0, 18, 1710.433715,-1669.379272,20.225049);
			}
			case 26: {
				SetPlayerPosition(pid, "LV police HQ", 0, 3, 288.745971,169.350997,1007.171875);
			}
			case 27: {
				SetPlayerPosition(pid, "Planning dept.", 0, 3, 384.808624,173.804992,1008.382812);
			}
			case 28: {
				SetPlayerPosition(pid, "Zombie Island", 0, 3, 1435.9980,-3881.3413,17.0);
			}
			case 29: {
				SetPlayerPosition(pid, "Clanwar Island", 150, 3, 2495.3467,-2839.5181,57.2000,89.0618);
			}
			case 30: {
				SetPlayerPosition(pid, "Madd Doggs", 0, 5, 1267.663208,-781.323242,1091.906250);
			}
			case 31: {
				SetPlayerPosition(pid, "Big Spread Ranch", 0, 3, 1212.019897,-28.663099,1000.953125);
			}                 
		}    
	}

	Dialog_ShowCallback(playerid, using inline AdminTeleports, DIALOG_STYLE_LIST, "Teleports",
	"Sherman dam\nWarehouse\n\
	SF Police HQ\nLS Police HQ\nShamal\n\
	Jefferson motel\n\
	Betting shop\nSex shop\nMeat factory\nRC shop\n\
	Catigula's\nWoozie's office\nBinco\nJay's diner\n\
	Burger shot\nLS Gym\nSweet's House\nCrack factory\nStrip club\nPleasure domes\n8-Track\n\
	Bloodbowl\nVice stadium\nKickstart\nRC Battlefield\nLS Atrium\nLV police HQ\nPlanning dept.\n\
	Zombie Island\nClanwar Island\nMadd Doggs\nBig Spread Ranch", "Go", "X");
	return 1;
}

flags:goto(CMD_ADMIN);
CMD:goto(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new targetid;

		if (sscanf(params, "u", targetid)) return ShowSyntax(playerid, "/goto [playerid/name]");

		if (IsPlayerConnected(targetid) && targetid != INVALID_PLAYER_ID && targetid != playerid) {
			new Float: x, Float: y, Float: z;
			GetPlayerPos(targetid, x, y, z);

			SetPlayerInterior(playerid, GetPlayerInterior(targetid));
			SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(targetid));

			if (GetPlayerState(playerid) == 2) {
				SetVehiclePos(GetPlayerVehicleID(playerid), x + 3, y, z);

				LinkVehicleToInterior(GetPlayerVehicleID(playerid), GetPlayerInterior(targetid));
				SetVehicleVirtualWorld(GetPlayerVehicleID(playerid), GetPlayerVirtualWorld(targetid));

			}
			else
				SetPlayerPos(playerid, x + 2, y, z);
		}  else Text_Send(playerid, $CLIENT_319x);
	}
	return 1;
}

flags:vgoto(CMD_ADMIN);
CMD:vgoto(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new targetid;
		if (sscanf(params, "i", targetid)) return ShowSyntax(playerid, "/vgoto [vehicle]");


		new Float:x, Float:y, Float:z;
		GetVehiclePos(targetid, x, y, z);

		SetPlayerVirtualWorld(playerid,GetVehicleVirtualWorld(targetid));
		if (GetPlayerState(playerid) == 2) {
			SetVehiclePos(GetPlayerVehicleID(playerid), x + 3, y, z);
			SetVehicleVirtualWorld(GetPlayerVehicleID(playerid), GetVehicleVirtualWorld(targetid));

		} else SetPlayerPos(playerid, x + 2, y, z);
	}
	return 1;
}

flags:vget(CMD_ADMIN);
CMD:vget(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new targetid;
		if (sscanf(params, "i", targetid)) return ShowSyntax(playerid, "/vget [vehicle]");

		new Float:x, Float:y, Float:z;

		GetPlayerPos(playerid, x, y, z);
		SetVehiclePos(targetid, x + 3, y, z);

		SetVehicleVirtualWorld(targetid, GetPlayerVirtualWorld(playerid));
	}
	return 1;
}

flags:vslap(CMD_ADMIN);
CMD:vslap(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new targetid;
		if (sscanf(params, "i", targetid)) return ShowSyntax(playerid, "/vslap [vehicle]");

		new Float:x, Float:y, Float:z;

		GetVehiclePos(targetid, x, y, z);
		SetVehiclePos(targetid, x, y, z + 5);

		SetVehicleVirtualWorld(targetid, GetPlayerVirtualWorld(playerid));
	}
	return 1;
}

flags:get(CMD_ADMIN);
CMD:get(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new targetid;
		if (sscanf(params, "u", targetid)) return ShowSyntax(playerid, "/get [playerid/name]");

		if (IsPlayerConnected(targetid) && targetid != INVALID_PLAYER_ID && targetid != playerid) {
			if (PlayerInfo[targetid][pAdminLevel] == svtconf[max_admin_level] && PlayerInfo[playerid][pAdminLevel] < svtconf[max_admin_level] - 1) return Text_Send(playerid, $CLIENT_362x);

			new Float:x, Float:y, Float:z;
			GetPlayerPos(playerid, x, y, z);
			SetPlayerInterior(targetid, GetPlayerInterior(playerid));

			SetPlayerVirtualWorld(targetid, GetPlayerVirtualWorld(playerid));

			if (GetPlayerState(targetid) == 2) {
				new VehicleID = GetPlayerVehicleID(targetid);

				SetVehiclePos(VehicleID,x + 3, y, z);
				LinkVehicleToInterior(VehicleID, GetPlayerInterior(playerid));

				SetVehicleVirtualWorld(GetPlayerVehicleID(targetid), GetPlayerVirtualWorld(playerid));

			} else SetPlayerPos(targetid, x + 2, y, z);

			new query[120];
			format(query, sizeof(query), "Teleported player %s to their location.", PlayerInfo[targetid][PlayerName]);
			LogAdminAction(playerid, query);
		}  else Text_Send(playerid, $CLIENT_319x);
	}
	return 1;
}

//HR commands

flags:setvip(CMD_ADMIN);
CMD:setvip(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new targetid, rank;

		if (sscanf(params, "ui", targetid, rank)) return ShowSyntax(playerid, "/setvip [playerid/name] [level]");
		if (IsPlayerConnected(targetid) && targetid != INVALID_PLAYER_ID) {
			if (rank > 5 || rank < 0) return ShowSyntax(playerid, "/setvip [playe name/id] [level 0-5]");
			PlayerInfo[targetid][pDonorLevel] = rank;

			PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
			PlayerPlaySound(targetid, 1057, 0.0, 0.0, 0.0);

			new String[128];
			format(String, sizeof(String), "Administrator %s changed %s's donor level to %d!", PlayerInfo[playerid][PlayerName],
				PlayerInfo[targetid][PlayerName], rank);
			MessageToAdmins(0x2281C8FF, String);

			new query[120];
			format(query, sizeof(query), "Changed donor level for %s to %d.", PlayerInfo[targetid][PlayerName], rank);
			LogAdminAction(playerid, query);
		} 
		else Text_Send(playerid, $CLIENT_320x);
	}
	return 1;
}

flags:setname(CMD_ADMIN);
CMD:setname(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new ID, query[120], nickname[MAX_PLAYER_NAME];
		if (sscanf(params, "us[24]", ID, nickname)) return ShowSyntax(playerid, "/setname [playerid/name] [name]");
		if (!IsPlayerConnected(ID) || !PlayerInfo[ID][pLoggedIn] || !pVerified[ID]) return Text_Send(playerid, $NEWCLIENT_193x);
		if (strlen(nickname) > 20 || strlen(nickname) < 3) return ShowSyntax(playerid, "/setname [player name/id] [new name 3-20]");
		mysql_format(Database, query, sizeof(query), "SELECT * FROM `Players` WHERE `Username` = '%e' LIMIT 1", nickname);
		mysql_tquery(Database, query, "OnlineChangeName", "dds", playerid, ID, nickname);

		printf("[ADMIN] %s[%d] attempted to rename %s[%d] to: %s", PlayerInfo[playerid][PlayerName], playerid,
			PlayerInfo[ID][PlayerName], ID, nickname);
	}      
	return 1;
}

flags:osetname(CMD_ADMIN);
CMD:osetname(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new query[105], oldname[MAX_PLAYER_NAME], nickname[MAX_PLAYER_NAME];
		if (sscanf(params, "s[24]s[24]", oldname, nickname)) return ShowSyntax(playerid, "/osetname [name] [new name]");
		if (strlen(nickname) > 20 || strlen(nickname) < 3) return ShowSyntax(playerid, "/osetname [old name] [new name 3-20]");

		mysql_format(Database, query, sizeof(query), "SELECT * FROM `Players` WHERE `Username` = '%e' LIMIT 1", nickname);
		mysql_tquery(Database, query, "OfflineChangeName", "dss", playerid, oldname, nickname);

		printf("[ADMIN] %s[%d] attempted to rename %s to: %s", PlayerInfo[playerid][PlayerName], playerid,
			oldname, nickname);
	}      
	return 1;
}

flags:setpass(CMD_ADMIN | CMD_SECRET);
CMD:setpass(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new query[450], Username[MAX_PLAYER_NAME], newPassword[50];
		if (sscanf(params, "s[24]s[50]", Username, newPassword)) return ShowSyntax(playerid, "/setpass [name] [new pass]");

		mysql_format(Database, query, sizeof(query), "SELECT * FROM `Players` WHERE `Username` = '%e' LIMIT 1", Username);
		mysql_tquery(Database, query, "ChangePlayerPassword", "dss", playerid, Username, newPassword);
	}
	return 1;
}

flags:removeaccount(CMD_ADMIN | CMD_SECRET);
CMD:removeaccount(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel] == svtconf[max_admin_level]) {
		new query[450], Username[MAX_PLAYER_NAME];
		if (sscanf(params, "s[24]", Username)) return ShowSyntax(playerid, "/removeaccount [name]");

		mysql_format(Database, query, sizeof(query), "SELECT * FROM `Players` WHERE `Username` = '%e' LIMIT 1", Username);
		mysql_tquery(Database, query, "RemovePlayerAccount", "d", playerid);
	}
	return 1;
}

flags:osetscore(CMD_ADMIN);
CMD:osetscore(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new query[105], Username[MAX_PLAYER_NAME], score;
		if (sscanf(params, "s[24]d", Username, score)) return ShowSyntax(playerid, "/osetscore [name] [score]");

		mysql_format(Database, query, sizeof(query), "SELECT * FROM `Players` WHERE `Username` = '%e' LIMIT 1", Username);
		mysql_tquery(Database, query, "UpdatePlayerScore", "dd", playerid, score);
	}
	return 1;
}

flags:osetcash(CMD_ADMIN);
CMD:osetcash(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new query[450], Username[MAX_PLAYER_NAME], cash;
		if (sscanf(params, "s[24]d", Username, cash)) return ShowSyntax(playerid, "/osetcash [name] [cash]");

		mysql_format(Database, query, sizeof(query), "SELECT * FROM `Players` WHERE `Username` = '%e' LIMIT 1", Username);
		mysql_tquery(Database, query, "UpdatePlayerCash", "dd", playerid, cash);
	}
	return 1;
}

flags:osetkills(CMD_ADMIN);
CMD:osetkills(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new query[450], Username[MAX_PLAYER_NAME], kills;
		if (sscanf(params, "s[24]d", Username, kills)) return ShowSyntax(playerid, "/osetkills [name] [kikks]");

		mysql_format(Database, query, sizeof(query), "SELECT * FROM `Players` WHERE `Username` = '%e' LIMIT 1", Username);
		mysql_tquery(Database, query, "UpdatePlayerKills", "dd", playerid, kills);
	}
	return 1;
}

flags:osetdeaths(CMD_ADMIN);
CMD:osetdeaths(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new query[450], Username[MAX_PLAYER_NAME], deaths;
		if (sscanf(params, "s[24]d", Username, deaths)) return ShowSyntax(playerid, "/osetdeaths [name] [deaths]");

		mysql_format(Database, query, sizeof(query), "SELECT * FROM `Players` WHERE `Username` = '%e' LIMIT 1", Username);
		mysql_tquery(Database, query, "UpdatePlayerDeaths", "dd", playerid, deaths);
	}
	return 1;
}

flags:osetlevel(CMD_ADMIN);
CMD:osetlevel(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new query[450], Username[MAX_PLAYER_NAME], level;
		if (sscanf(params, "s[24]d", Username, level)) return ShowSyntax(playerid, "/osetlevel [name] [admin level]");
		if (level > 7) return Text_Send(playerid, $CLIENT_422x);
		mysql_format(Database, query, sizeof(query), "SELECT * FROM `Players` WHERE `Username` = '%e' LIMIT 1", Username);
		mysql_tquery(Database, query, "UpdateAdminRank", "dd", playerid, level);
	}
	return 1;
}

flags:osetmoderator(CMD_ADMIN);
CMD:osetmoderator(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new query[450], Username[MAX_PLAYER_NAME], status;
		if (sscanf(params, "s[24]d", Username, status)) return ShowSyntax(playerid, "/osetmoderator [name] [0 = regular / 1 = moderator]");

		mysql_format(Database, query, sizeof(query), "SELECT * FROM `Players` WHERE `Username` = '%e' LIMIT 1", Username);
		mysql_tquery(Database, query, "UpdateModeratorRank", "dd", playerid, status);
	}
	return 1;
}

flags:osetvip(CMD_ADMIN);
CMD:osetvip(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new query[450], Username[MAX_PLAYER_NAME], donorlevel;
		if (sscanf(params, "s[24]d", Username, donorlevel)) return ShowSyntax(playerid, "/osetvip [name] [donor level]");
		if (donorlevel > 5 || donorlevel < 0) return ShowSyntax(playerid, "/osetvip [player name] [donor level 0-5]");

		mysql_format(Database, query, sizeof(query), "SELECT * FROM `Players` WHERE `Username` = '%e' LIMIT 1", Username);
		mysql_tquery(Database, query, "UpdateDonorRank", "dd", playerid, donorlevel);
	}
	return 1;
}

flags:query(CMD_ADMIN);
CMD:query(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel] == svtconf[max_admin_level]) {
		new query[656];
		if (sscanf(params, "s[656]", query)) return ShowSyntax(playerid, "/query [sql query]");
		mysql_tquery(Database, query);
	}
	return 1;
}

//Staff management

flags:setmoderator(CMD_ADMIN);
CMD:setmoderator(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new targetid;
		if (sscanf(params, "ui", targetid)) return ShowSyntax(playerid, "/setmoderator [player id/name]");

		if (IsPlayerConnected(targetid) && targetid != INVALID_PLAYER_ID) {
			if (PlayerInfo[targetid][pLoggedIn] == 1) {
				if (PlayerInfo[targetid][pIsModerator]) return Text_Send(playerid, $CLIENT_420x);

				PlayerInfo[targetid][pTagPermitted] = 1;

				GameTextForPlayer(targetid, "~g~PROMOTED~n~HELPER STATUS", 2000, 3);

				PlayerInfo[targetid][pIsModerator] = 1;
				PlayerPlaySound(targetid, 1057, 0.0, 0.0, 0.0);

				new String[128];
				format(String, sizeof(String), "Administrator %s made %s a server moderator.", PlayerInfo[playerid][PlayerName], PlayerInfo[targetid][PlayerName]);
				MessageToAdmins(0x2281C8FF, String);

				new query[120];
				format(query, sizeof(query), "Changed moderator status for %s to %d.", PlayerInfo[targetid][PlayerName], 1);
				LogAdminAction(playerid, query);
			}
		}  else Text_Send(playerid, $CLIENT_320x);
	}
	return 1;
}

flags:unsetmoderator(CMD_ADMIN);
CMD:unsetmoderator(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new targetid;
		if (sscanf(params, "ui", targetid)) return ShowSyntax(playerid, "/unsetmoderator [player id/name]");

		if (IsPlayerConnected(targetid) && targetid != INVALID_PLAYER_ID) {
			if (PlayerInfo[targetid][pLoggedIn] == 1) {
				if (!PlayerInfo[targetid][pIsModerator]) return Text_Send(playerid, $CLIENT_420x);
				
				if (!PlayerInfo[targetid][pAdminLevel]) {
					PlayerInfo[targetid][pTagPermitted] = 0;
				}

				GameTextForPlayer(targetid, "~r~DEMOTED~n~HELPER STATUS", 2000, 3);

				PlayerInfo[targetid][pIsModerator] = 0;
				PlayerPlaySound(targetid, 1057, 0.0, 0.0, 0.0);

				new String[128];
				format(String, sizeof(String), "Administrator %s removed %s from server moderator status.", PlayerInfo[playerid][PlayerName], PlayerInfo[targetid][PlayerName]);
				MessageToAdmins(0x2281C8FF, String);

				new query[120];
				format(query, sizeof(query), "Changed moderator status for %s to %d.", PlayerInfo[targetid][PlayerName], 1);
				LogAdminAction(playerid, query);
			}
		}  else Text_Send(playerid, $CLIENT_320x);
	}
	return 1;
}

flags:setlevel(CMD_ADMIN);
CMD:setlevel(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new targetid, level;
		if (sscanf(params, "ui", targetid, level)) return ShowSyntax(playerid, "/setlevel [playerid/name] [level]");

		if (IsPlayerConnected(targetid) && targetid != INVALID_PLAYER_ID) {
			if (PlayerInfo[targetid][pAdminLevel] >= PlayerInfo[playerid][pAdminLevel]) return Text_Send(playerid, $CLIENT_321x);

			if (PlayerInfo[targetid][pLoggedIn] == 1) {
				if (level >= PlayerInfo[playerid][pAdminLevel] || level < 0) return Text_Send(playerid, $CLIENT_422x);
				if (level == PlayerInfo[targetid][pAdminLevel]) return Text_Send(playerid, $CLIENT_420x);

				if (level > 0) {
					PlayerInfo[targetid][pTagPermitted] = 1;
					pIsAdmin[targetid] = true;
				} else {
					PlayerInfo[targetid][pTagPermitted] = 0;
					pIsAdmin[targetid] = false;
				}

				new String[128];
				format(String, sizeof(String), "Administrator %s changed %s's account level to %d!", PlayerInfo[playerid][PlayerName],
					PlayerInfo[targetid][PlayerName], level);
				MessageToAdmins(0x2281C8FF, String);

				if (level > PlayerInfo[targetid][pAdminLevel]) GameTextForPlayer(targetid, "~g~PROMOTED~n~ADMIN STATUS", 2000, 3);
				else GameTextForPlayer(targetid, "~r~DEMOTED~n~ADMIN STATUS", 2000, 3);

				PlayerInfo[targetid][pAdminLevel] = level;
				PlayerPlaySound(targetid, 1057, 0.0, 0.0, 0.0);

				new query[120];
				format(query, sizeof(query), "Changed admin level for %s to %d.", PlayerInfo[targetid][PlayerName], level);
				LogAdminAction(playerid, query);
			}
		}  else Text_Send(playerid, $CLIENT_320x);
	}
	return 1;
}

//Restart server
flags:gmx(CMD_ADMIN);
CMD:gmx(playerid) {
	if (!PlayerInfo[playerid][pAdminLevel]) return 0;
	mysql_tquery(Database, "UPDATE `ServerConfig` SET `ConfValue` = '1' WHERE `ConfName` = 'SafeRestart'");
	Text_Send(@pVerified, $GOODBYE);
	PC_EmulateCommand(playerid, "/saveallstats");
	SendRconCommand("gmx");
	return 1;
}

//PLAYER SECTION

//Admins

CMD:admins(playerid) {
	new count = 0, AdmStr[128];
	
	Text_Send(playerid, $NEWCLIENT_189x);

	foreach (new i: Player) {
		if (PlayerInfo[i][pAdminLevel] >= 1) {
			if (PlayerInfo[i][pAdminDuty] || PlayerInfo[playerid][pAdminLevel] || PlayerInfo[playerid][pIsModerator]) {
				new aRank[30];
				switch (PlayerInfo[i][pAdminLevel]) {
					case 0: aRank = "Moderator"; 
					case 1: aRank = "Trial Admin"; 
					case 2: aRank = "Senior Admin"; 
					case 3: aRank = "Lead Admin"; 
					case 4: aRank = "Head Admin"; 
					case 5: aRank = "Assistant Manager"; 
					case 6: aRank = "Manager"; 
					case 7: aRank = "Lead Manager"; 
					case 8: aRank = "CEO";
				}
				format(AdmStr, sizeof(AdmStr), "%s[%d] - %s [%d]", PlayerInfo[i][PlayerName], i, aRank, PlayerInfo[i][pAdminLevel]);
				SendClientMessage(playerid, X11_DEEPSKYBLUE, AdmStr);
				count++;
			}
		}
	}

	if (count == 0) return Text_Send(playerid, $CLIENT_336x);    
	return 1;
}


//Report

CMD:report(playerid, params[]) {
	new targetid, reason[45];

	if (sscanf(params, "us[45]", targetid, reason)) return ShowSyntax(playerid, "/report [playerid/name] [reason]");
	if (strlen(reason) < 1) return Text_Send(playerid, $CLIENT_330x);
	if (targetid == playerid) return Text_Send(playerid, $CLIENT_329x);
	if (!IsPlayerConnected(targetid) || targetid == INVALID_PLAYER_ID) return Text_Send(playerid, $CLIENT_320x);

	new hour, minute, second;
	gettime(hour, minute, second);

	foreach (new i: Player) {
		if (PlayerInfo[i][pIsModerator]) {
			Text_Send(i, $NEWCLIENT_191x, PlayerInfo[playerid][PlayerName], playerid, PlayerInfo[targetid][PlayerName], targetid, reason);
		}
	}

	new String[128];
	format(String, sizeof(String), "[REPORT] %s[%d] reported %s[%d] for \"%s\".", PlayerInfo[playerid][PlayerName], playerid, PlayerInfo[targetid][PlayerName], targetid, reason);
	MessageToAdmins(X11_MAROON, String);

	for (new i = (MAX_REPORTS - 1); i >= 1; i--) {
		ReportInfo[i][R_VALID] = ReportInfo[i - 1][R_VALID];
		ReportInfo[i][R_AGAINST_ID] = ReportInfo[i - 1][R_AGAINST_ID];

		format(ReportInfo[i][R_AGAINST_NAME], MAX_PLAYER_NAME, ReportInfo[i - 1][R_AGAINST_NAME]);
		ReportInfo[i][R_FROM_ID] = ReportInfo[i - 1][R_FROM_ID];

		format(ReportInfo[i][R_FROM_NAME], MAX_PLAYER_NAME, ReportInfo[i - 1][R_FROM_NAME]);
		ReportInfo[i][R_TIMESTAMP] = ReportInfo[i - 1][R_TIMESTAMP];

		format(ReportInfo[i][R_REASON], 65, ReportInfo[i - 1][R_REASON]);

		ReportInfo[i][R_CHECKED] = ReportInfo[i - 1][R_CHECKED];
		ReportInfo[i][R_READ] = ReportInfo[i - 1][R_READ];
	}

	ReportInfo[0][R_VALID] = true;
	ReportInfo[0][R_AGAINST_ID] = targetid;

	GetPlayerName(targetid, ReportInfo[0][R_AGAINST_NAME], MAX_PLAYER_NAME);
	ReportInfo[0][R_FROM_ID] = playerid;

	GetPlayerName(playerid, ReportInfo[0][R_FROM_NAME], MAX_PLAYER_NAME);
	ReportInfo[0][R_TIMESTAMP] = gettime();

	format(ReportInfo[0][R_REASON], 65, reason);

	ReportInfo[0][R_CHECKED] = true;
	ReportInfo[0][R_READ] = 0;

	foreach( new x: Player) {
		PlayerReportChecked[x][0] = PlayerReportChecked[x][0];
	}

	new query[240];

	mysql_format(Database, query, sizeof(query), "INSERT INTO `PlayersReports` (`Reporter`, `ReportedPlayer`, `Reason`, `DateIssued`) VALUES ('%e', '%e', '%e', CURDATE())", PlayerInfo[playerid][PlayerName], reason, PlayerInfo[targetid][PlayerName]);
	mysql_tquery(Database, query);

	PlayerInfo[playerid][pUsedReport] = 1;

	PlayerInfo[playerid][pPlayerReports] ++;
	PlayerInfo[targetid][pReportAttempts] ++;

	PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);

	Text_Send(playerid, $CLIENT_328x);
	return 1;
}

//End of File
/* (c) H2O Multiplayer 2018-2020. All rights reserved. */