/*
	SWAT vs Terrorists is a team death-match SA-MP game-mode script. 
	Compatible with SA-MP 0.3.7 and later releases.

	Author: H2O
	Licensed under GNU GPLv3

	(c) 2018-2020 H2O Multiplayer. All rights reserved.
	Website: h2omultiplayer.com

	Core for the logging system
*/

//Support for y_text, load language files...
#include <YSI_Players\y_text> //Y_Less
loadtext mode_text[all], mode_text[client], mode_text[newcs], mode_text[dialogs], mode_text[gametexts];

forward GetLog_Ban(playerid, nick[]);
forward GetLog_Kick(playerid, nick[]);
forward GetLog_Unban(playerid, nick[]);
forward GetLog_Jail(playerid, nick[]);
forward GetLog_Mute(playerid, nick[]);
forward GetLog_Names(playerid, nick[]);
forward GetLog_Audit(playerid, nick[]);
forward GetLog_Warn(playerid, nick[]);
forward GetLog_Freeze(playerid, nick[]);

public GetLog_Kick(playerid, nick[]) {
	if (cache_num_rows() != 0) {
		new Admin[MAX_PLAYER_NAME], Reason[35], Date;
		Text_Send(playerid, $CLIENT_549z, nick);
		for (new i = cache_num_rows() - 1; i > -1; i--) {
			cache_get_value(i, "Punisher", Admin, sizeof(Admin));
			cache_get_value(i, "ActionReason", Reason, sizeof(Reason));
			cache_get_value_int(i, "ActionDate", Date);

			Text_Send(playerid, $NEWCLIENT_9x, i, Admin, Reason, GetWhen(Date, gettime()));
		}
	}  else Text_Send(playerid, $ADMIN_NO_RECORDS);
	return 1;
}

public GetLog_Ban(playerid, nick[]) {
	if (cache_num_rows() != 0) {
		new Admin[MAX_PLAYER_NAME], Reason[35], Days, Date[24];
		Text_Send(playerid, $CLIENT_549z, nick);
		for (new i, j = cache_num_rows(); i != j; i++) {
			cache_get_value(i, "AdminName", Admin, sizeof(Admin));
			cache_get_value(i, "BanReason", Reason, sizeof(Reason));
			cache_get_value_int(i, "ExpiryDate", Days);
			cache_get_value(i, "BanDate", Date, sizeof(Date));

			Text_Send(playerid, $NEWCLIENT_10x, i, Admin, Reason, Days, Date);
		}
	}  else Text_Send(playerid, $ADMIN_NO_RECORDS);
	return 1;
}

public GetLog_Warn(playerid, nick[]) {
	if (cache_num_rows() != 0) {
		new Admin[MAX_PLAYER_NAME], Reason[35], Date;
		Text_Send(playerid, $CLIENT_549z, nick);
		for (new i, j = cache_num_rows(); i != j; i++) {
			cache_get_value(i, "Punisher", Admin, sizeof(Admin));
			cache_get_value(i, "ActionReason", Reason, sizeof(Reason));
			cache_get_value_int(i, "ActionDate", Date);

			Text_Send(playerid, $NEWCLIENT_11x, i, Admin, Reason, GetWhen(Date, gettime()));
		}
	}  else Text_Send(playerid, $ADMIN_NO_RECORDS);
	return 1;
}
public GetLog_Unban(playerid, nick[]) {
	if (cache_num_rows() != 0) {  
		new Admin[MAX_PLAYER_NAME], Date;
		Text_Send(playerid, $CLIENT_549z, nick);
		for (new i, j = cache_num_rows(); i != j; i++) {
			cache_get_value(i, "Punisher", Admin, sizeof(Admin));
			cache_get_value_int(i, "ActionDate", Date);

			Text_Send(playerid, $NEWCLIENT_12x, i, Admin, GetWhen(Date, gettime()));
		}
	}  else Text_Send(playerid, $ADMIN_NO_RECORDS);
	return 1;
}

public GetLog_Mute(playerid, nick[]) {
	if (cache_num_rows() != 0) {
		new Admin[MAX_PLAYER_NAME], Reason[35], Date;
		Text_Send(playerid, $CLIENT_549z, nick);
		for (new i, j = cache_num_rows(); i != j; i++) {
			cache_get_value(i, "Punisher", Admin, sizeof(Admin));
			cache_get_value(i, "ActionReason", Reason, sizeof(Reason));
			cache_get_value_int(i, "ActionDate", Date);

			Text_Send(playerid, $NEWCLIENT_13x, i, Admin, Reason, GetWhen(Date, gettime()));
		}
	}  else Text_Send(playerid, $ADMIN_NO_RECORDS);
	return 1;
}

public GetLog_Freeze(playerid, nick[]) {
	if (cache_num_rows() != 0) {
		new Admin[MAX_PLAYER_NAME], PunishmentTime[24], Reason[35], Date;
		Text_Send(playerid, $CLIENT_549z, nick);
		for (new i, j = cache_num_rows(); i != j; i++) {
			cache_get_value(i, "Punisher", Admin, sizeof(Admin));
			cache_get_value(i, "ActionReason", Reason, sizeof(Reason));
			cache_get_value(i, "PunishmentTime", PunishmentTime, sizeof(PunishmentTime));
			cache_get_value_int(i, "ActionDate", Date);
	
			Text_Send(playerid, $NEWCLIENT_14x, i, Admin, PunishmentTime, Reason, GetWhen(Date, gettime()));
		}
	}  else Text_Send(playerid, $ADMIN_NO_RECORDS);
	return 1;
}

public GetLog_Jail(playerid, nick[]) {
	if (cache_num_rows() != 0) {
		new Admin[MAX_PLAYER_NAME], PunishmentTime[24], Reason[35], Date;
		Text_Send(playerid, $CLIENT_549z, nick);
		for (new i, j = cache_num_rows(); i != j; i++) {
			cache_get_value(i, "Punisher", Admin, sizeof(Admin));
			cache_get_value(i, "ActionReason", Reason, sizeof(Reason));
			cache_get_value_int(i, "ActionDate", Date);
			cache_get_value(i, "PunishmentTime", PunishmentTime, sizeof(PunishmentTime));
 
			Text_Send(playerid, $NEWCLIENT_15x, i, Admin, PunishmentTime, Reason, GetWhen(Date, gettime()));
		}
	}  else Text_Send(playerid, $ADMIN_NO_RECORDS);
	return 1;
}

public GetLog_Audit(playerid, nick[]) {
	if (cache_num_rows() != 0) {    
		new Action[128], Date;
		Text_Send(playerid, $CLIENT_549z, nick);
		for (new i, j = cache_num_rows(); i != j; i++) {
			cache_get_value(i, "ActionDescription", Action, sizeof(Action));
			cache_get_value_int(i, "IssuedDate", Date);

			Text_Send(playerid, $NEWCLIENT_16x, i, Action, GetWhen(Date, gettime()));
		}
	}  else Text_Send(playerid, $ADMIN_NO_RECORDS);
	return 1;
}

public GetLog_Names(playerid, nick[]) {
	if (cache_num_rows() != 0) {
		new Admin[MAX_PLAYER_NAME], NewName[MAX_PLAYER_NAME], Date;
		Text_Send(playerid, $CLIENT_549z, nick);
		for (new i, j = cache_num_rows(); i != j; i++) {
			cache_get_value(i, "Admin", Admin, sizeof(Admin));
			cache_get_value(i, "NewName", NewName, sizeof(NewName));
			cache_get_value_int(i, "ActionDate", Date);

			Text_Send(playerid, $NEWCLIENT_17x, i, nick, NewName, Admin, GetWhen(Date, gettime()));
		}
	}  else Text_Send(playerid, $ADMIN_NO_RECORDS);
	return 1;
}

//Logging starts here
LogAdminAction(adminId, const ActionDescription[]) {
	new auditquery[253];
	mysql_format(Database, auditquery, sizeof(auditquery), 
		"INSERT INTO `AdminsAuditLog` (AdminName, ActionDescription, IssuedDate) \
			VALUES ('%e', '%e', '%d')", PlayerInfo[adminId][PlayerName], ActionDescription, gettime());
	mysql_tquery(Database, auditquery);
	return 1;
}

//Some commands for logging
flags:getbans(CMD_ADMIN);
CMD:getbans(playerid, params[]) {
	new nick[MAX_PLAYER_NAME], query[256], offset;

	if (PlayerInfo[playerid][pAdminLevel] < 3) return 1;
	if (sscanf(params, "s[24]i", nick, offset)) return ShowSyntax(playerid, "/getbans [name] [offset]");


	mysql_format(Database, query, sizeof(query), "SELECT * FROM `BansHistoryData` WHERE `BannedName` = '%e' ORDER BY `BanId` DESC LIMIT %d, %d", nick, offset, offset + 10);
	mysql_tquery(Database, query, "GetLog_Ban", "is", playerid, nick);    
	return 1;
}

flags:getfreezes(CMD_ADMIN);
CMD:getfreezes(playerid, params[]) {
	new nick[MAX_PLAYER_NAME], query[256], offset;

	if (PlayerInfo[playerid][pAdminLevel] < 3) return 1;
	if (sscanf(params, "s[24]i", nick, offset)) return ShowSyntax(playerid, "/getfreezes [name] [offset]");


	mysql_format(Database, query, sizeof(query), "SELECT * FROM `Punishments` WHERE `PunishedPlayer` = '%e' AND `Action` = 'Freeze' ORDER BY `ActionId` DESC LIMIT %d, %d", nick, offset, offset + 10);
	mysql_tquery(Database, query, "GetLog_Freeze", "is", playerid, nick);    
	return 1;
}

flags:getwarns(CMD_ADMIN);
CMD:getwarns(playerid, params[]) {
	new nick[MAX_PLAYER_NAME], query[256], offset;

	if (PlayerInfo[playerid][pAdminLevel] < 3) return 1;
	if (sscanf(params, "s[24]i", nick, offset)) return ShowSyntax(playerid, "/getwarns [name] [offset]");


	mysql_format(Database, query, sizeof(query), "SELECT * FROM `Punishments` WHERE `PunishedPlayer` = '%e' AND `Action` = 'Warn' ORDER BY `ActionId` DESC LIMIT %d, %d", nick, offset, offset + 10);
	mysql_tquery(Database, query, "GetLog_Warn", "is", playerid, nick);    
	return 1;
}

flags:getmutes(CMD_ADMIN);
CMD:getmutes(playerid, params[]) {
	new nick[MAX_PLAYER_NAME], query[256], offset;

	if (PlayerInfo[playerid][pAdminLevel] < 3) return 1;
	if (sscanf(params, "s[24]i", nick, offset)) return ShowSyntax(playerid, "/getmutes [name] [offset]");


	mysql_format(Database, query, sizeof(query), "SELECT * FROM `Punishments` WHERE `PunishedPlayer` = '%e' AND `Action` = 'Mute' ORDER BY `ActionId` DESC LIMIT %d, %d", nick, offset, offset + 10);
	mysql_tquery(Database, query, "GetLog_Mute", "is", playerid, nick);    
	return 1;
}

flags:getunbans(CMD_ADMIN);
CMD:getunbans(playerid, params[]) {
	new nick[MAX_PLAYER_NAME], query[256], offset;

	if (PlayerInfo[playerid][pAdminLevel] < 3) return 1;
	if (sscanf(params, "s[24]i", nick, offset)) return ShowSyntax(playerid, "/getunbans [name] [offset]");


	mysql_format(Database, query, sizeof(query), "SELECT * FROM `Punishments` WHERE `PunishedPlayer` = '%e' AND `Action` = 'Unban' ORDER BY `ActionId` DESC LIMIT %d, %d", nick, offset, offset + 10);
	mysql_tquery(Database, query, "GetLog_Unban", "is", playerid, nick);    
	return 1;
}

flags:audit(CMD_ADMIN);
CMD:audit(playerid, params[]) {
	new nick[MAX_PLAYER_NAME], query[110 + MAX_PLAYER_NAME], offset;

	if (PlayerInfo[playerid][pAdminLevel] < 3) return 1;
	if (sscanf(params, "s[24]i", nick, offset)) return ShowSyntax(playerid, "/audit [name] [offset]");

	mysql_format(Database, query, sizeof(query), "SELECT * FROM `AdminsAuditLog` WHERE `AdminName` = '%e' ORDER BY `AuditId` DESC LIMIT %d, %d", nick, offset, offset + 10);
	mysql_tquery(Database, query, "GetLog_Audit", "is", playerid, nick);    
	return 1;
}

flags:getnames(CMD_ADMIN);
CMD:getnames(playerid, params[]) {
	new nick[MAX_PLAYER_NAME], query[110 + MAX_PLAYER_NAME], offset;

	if (PlayerInfo[playerid][pAdminLevel] < 3) return 1;
	if (sscanf(params, "s[24]i", nick, offset)) return ShowSyntax(playerid, "/getnames [name] [offset]");

	mysql_format(Database, query, sizeof(query), "SELECT * FROM `NameChangesLog` WHERE `OldName` = '%e' OR `NewName` = '%e' ORDER BY `ActionId` DESC LIMIT %d, %d", nick, nick, offset, offset + 10);
	mysql_tquery(Database, query, "GetLog_Names", "is", playerid, nick);    
	return 1;
}

flags:getkicks(CMD_ADMIN);
CMD:getkicks(playerid, params[]) {
	new nick[MAX_PLAYER_NAME], query[110 + MAX_PLAYER_NAME], offset;

	if (PlayerInfo[playerid][pAdminLevel] < 3) return 1;
	if (sscanf(params, "s[24]i", nick, offset)) return ShowSyntax(playerid, "/getkicks [name] [offset]");

	mysql_format(Database, query, sizeof(query), "SELECT * FROM `Punishments` WHERE `PunishedPlayer` = '%e' AND `Action` = 'Kick' ORDER BY `ActionId` DESC LIMIT %d, %d", nick, offset, offset + 10);
	mysql_tquery(Database, query, "GetLog_Kick", "is", playerid, nick);    
	return 1;
}

flags:getjails(CMD_ADMIN);
CMD:getjails(playerid, params[]) {
	new nick[MAX_PLAYER_NAME], query[110 + MAX_PLAYER_NAME], offset;

	if (PlayerInfo[playerid][pAdminLevel] < 3) return 1;
	if (sscanf(params, "s[24]i", nick, offset)) return ShowSyntax(playerid, "/getjails [name] [offset]");

	mysql_format(Database, query, sizeof(query), "SELECT * FROM `Punishments` WHERE `PunishedPlayer` = '%e' AND `Action` = 'Jail' ORDER BY `ActionId` DESC LIMIT %d, %d", nick, offset, offset + 10);
	mysql_tquery(Database, query, "GetLog_Jail", "is", playerid, nick);    
	return 1;
}

//End of File
/* (c) H2O Multiplayer 2018-2020. All rights reserved. */