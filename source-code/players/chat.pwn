/*
	SWAT vs Terrorists is a team death-match SA-MP game-mode script.
	Compatible with SA-MP 0.3.7 and later releases.

	Author: H2O
	Licensed under GNU GPLv3

	(c) 2018-2020 H2O Multiplayer. All rights reserved.
	Website: h2omultiplayer.com

	Chat module
*/

#include <YSI\y_hooks>
#include <YSI_Players\y_text> //Y_Less
loadtext mode_text[all], mode_text[client], mode_text[newcs], mode_text[dialogs], mode_text[gametexts];

//PM System

forward SendPM(playerid, ID, str2[]);
public SendPM(playerid, ID, str2[]) {
	if (cache_num_rows()) {
		if (!PlayerInfo[playerid][pAdminLevel]) {
			Text_Send(playerid, $BLOCKED_PLAYER);
		}
	}

	Text_Send(playerid, $NEWCLIENT_18x, ID, PlayerInfo[ID][PlayerName], PlayerInfo[ID][pIsAFK] == 1 ? "Away" : "Online", str2);

	if (!PlayerInfo[playerid][pAdminLevel]) {
		Text_Send(ID, $NEWCLIENT_19x, playerid, PlayerInfo[playerid][PlayerName], str2);
	} else {
		Text_Send(ID, $NEWCLIENT_20x, playerid, PlayerInfo[playerid][PlayerName], str2);
	}

	if (pLastMessager[ID] == INVALID_PLAYER_ID) {
		Text_Send(ID, $REPLY_PM);
	}

	PlayerPlaySound(ID, 1057, 0.0, 0.0, 0.0);

	SendAdminPM(playerid, ID, str2);
	PlayerPlaySound(ID, 1057, 0.0, 0.0, 0.0);

	pLastMessager[ID] = playerid;
	pLastMessager[playerid] = ID;	

	return 1;
}

forward BlockPlayer(playerid, targetid);
public BlockPlayer(playerid, targetid) {
	if (!cache_num_rows()) {
		new query[150];
		mysql_format(Database, query, sizeof(query), "INSERT INTO `IgnoreList` (`BlockerId`, `BlockedId`) VALUES('%d', '%d')", PlayerInfo[playerid][pAccountId], PlayerInfo[targetid][pAccountId]);
		mysql_tquery(Database, query);

		Text_Send(playerid, $BLOCK_PLAYER, PlayerInfo[targetid][PlayerName]);
	} else {
		Text_Send(playerid, $BLOCKED_ALREADY);
	}
	return 1;
}

forward UnblockPlayer(playerid, targetid);
public UnblockPlayer(playerid, targetid) {
	if (cache_num_rows()) {
		new query[150];
		mysql_format(Database, query, sizeof(query), "DELETE FROM `IgnoreList` WHERE `BlockerId` = '%d' AND `BlockedId` = '%d' LIMIT 1", PlayerInfo[playerid][pAccountId], PlayerInfo[targetid][pAccountId]);
		mysql_tquery(Database, query);

		Text_Send(playerid, $UNBLOCK_PLAYER, PlayerInfo[targetid][PlayerName]);
	} else {
		Text_Send(playerid, $UNBLOCKED_ALREADY);
	}
	return 1;
}

//Chat messages

hook OnPlayerText(playerid, text[]) {
	if (!PlayerInfo[playerid][pLoggedIn]) return 0;
	PlayerInfo[playerid][pChatMessagesSent] ++;

	//////////

	new newtext[300], String[300];
	GetPlayerCalledName(playerid, text, newtext);

	//Add code for admin chat
	if (text[0] == '.' && PlayerInfo[playerid][pAdminLevel]) {
		foreach(new i: Player) if (PlayerInfo[i][pAdminLevel]) Text_Send(i, $ADMIN_CHAT, PlayerInfo[playerid][PlayerName], playerid, newtext[1]);
		return 0;
	}
	
	//Add code for manager chat
	if (text[0] == '@' && PlayerInfo[playerid][pAdminLevel] >= 7) {
		GetPlayerName(playerid, String, sizeof(String));

		format(String, sizeof(String), "[Manager] %s[%d]: %s", String, playerid, newtext[1]);
		foreach(new i: Player) if (PlayerInfo[i][pAdminLevel] >= 7) SendClientMessage(i, X11_GREEN, String);
		print(String);

		return 0;
	}

	////////////////////////////////////////
	
	if (text[0] == '$' && PlayerInfo[playerid][pDonorLevel] >= 1) {
		GetPlayerName(playerid, String, sizeof(String));

		format(String, sizeof(String), "[VIP] %s[%d]: %s", String, playerid, newtext[1]);
	
		foreach (new i: Player) {
			if (PlayerInfo[i][pDonorLevel] >= 1) {
				SendClientMessage(i, X11_LIMEGREEN, String);
			}
		}

		print(String);
		return 0;
	}

	if (PlayerInfo[playerid][pAdminLevel] < svtconf[max_admin_level] && svtconf[anti_adv] && AdCheck(text)) {
		Text_Send(playerid, $ADV_ALERT);

		new adcheck[150];
		format(adcheck, sizeof(adcheck), "*%s[%d] has attempted to advertise: %s", PlayerInfo[playerid][PlayerName], playerid, newtext);

		MessageToAdmins(X11_IVORY, adcheck);
		PlayerInfo[playerid][pAdvAttempts] ++;
		return 0;
	}


	if (svtconf[disable_chat] == 1 || PlayerInfo[playerid][pMuted] == 1) {
		Text_Send(playerid, $MUTE_ALERT);
		return 0;
	}

	if (PlayerInfo[playerid][pCapsDisabled] == 1) {
		LOWERCASE(newtext);
	}
	else if (svtconf[anti_caps]) {
		LOWERCASE(newtext);
	}

	if (!isnull(PlayerInfo[playerid][pChatLog]) &&
		!strcmp(PlayerInfo[playerid][pChatLog], newtext, true)) {
		Text_Send(playerid, $SPAM_ALERT);
		return 0;
	}

	if (svtconf[anti_spam] && PlayerInfo[playerid][pAdminLevel] == 0) {
		if (PlayerInfo[playerid][pSpamCount] == 0) PlayerInfo[playerid][pSpamTick] = TimeStamp();

		PlayerInfo[playerid][pSpamCount] ++;
		PlayerInfo[playerid][pSpamAttempts] ++;

		if (TimeStamp() - PlayerInfo[playerid][pSpamTick] > SPAM_TIMELIMIT) {
			PlayerInfo[playerid][pSpamCount] = 0;
			PlayerInfo[playerid][pSpamTick] = TimeStamp();
		} else if (PlayerInfo[playerid][pSpamCount] == MAX_MESSAGES) {
			Text_Send(@pVerified, $SERVER_31x, PlayerInfo[playerid][PlayerName]);
			Kick(playerid);
			return 0;
		} else if (PlayerInfo[playerid][pSpamCount] == MAX_MESSAGES - 1) {
			Text_Send(playerid, $SPAM_ALERT);
			return 0;
		}
	}

	SetPlayerChatBubble(playerid, text, 0xFFFFFFFF, 100.0, 10000);

	new String2[300];

	new clean_message = 1;

	for (new i = 0; i < sizeof(ForbiddenWords); i++) {
		if (strfind(text, ForbiddenWords[i], true) != -1 && !isnull(ForbiddenWords[i])) {
			Text_Send(playerid, $FORBIDDEN_MESSAGE, ForbiddenWords[i]);
			printf("%s[%d] used forbidden word: %s", PlayerInfo[playerid][PlayerName], ForbiddenWords[i]);

			PlayerInfo[playerid][pAntiSwearBlocks] ++;
			return 0;
		}
	}

	if (clean_message) {
		new player_name[MAX_PLAYER_NAME + 7];
		if (PlayerInfo[playerid][pClanTag] && IsPlayerInAnyClan(playerid)) {
			format(player_name, sizeof(player_name), "%s%s", PlayerInfo[playerid][PlayerName], GetClanTag(GetPlayerClan(playerid)));
		} else {
			format(player_name, sizeof(player_name), PlayerInfo[playerid][PlayerName]);
		}
		
		if (PlayerInfo[playerid][pAdminDuty]) {
			format(String2, sizeof(String2), "**Admin %s: %s", player_name, text);
			SendClientMessageToAll(0x6700A6FF, String2);
			printf(String2);
		} else {
			format(PlayerInfo[playerid][pChatLog], 300, newtext);
			if (PlayerInfo[playerid][pDonorLevel]) {
				format(String2, sizeof(String2), "[VIP] {%06x}%s[%d]: %s", GetPlayerColor(playerid) >>> 8, player_name, playerid, newtext);
				strreplace(String2, "<r>", ""RED2"");
				strreplace(String2, "<b>", ""DARKBLUE"");
				strreplace(String2, "<w>", ""IVORY"");
				strreplace(String2, "<g>", ""GREEN"");
				strreplace(String2, "<y>", ""YELLOW"");
				SendClientMessageToAll(0x72ED72FF, String2);
				print(String2);
			} else {
				format(String2, sizeof(String2), "%s[%d]: %s", player_name, playerid, newtext);			
				SendClientMessageToAll(GetPlayerColor(playerid), String2);
				print(String2);
			}
		}
	}	
	return 0;
}

flags:pm(CMD_SECRET); 
alias:pm("sendpm", "message");
CMD:pm(playerid, params[]) {
	if (PlayerInfo[playerid][pMuted] == 1) return 1;
	if (PlayerInfo[playerid][pAdminLevel] < svtconf[max_admin_level] && svtconf[anti_adv] && AdCheck(params)) {
		new adcheck[150];
		format(adcheck, sizeof(adcheck), "*%s[%d] has attempted to advertise: %s", PlayerInfo[playerid][PlayerName],
		playerid, params);

		MessageToAdmins(0x505751FF, adcheck);
		  
		PlayerInfo[playerid][pAdvAttempts] ++;
		return 0;
	}

	new str[140], str2[140], ID;
	if (sscanf(params, "us[140]", ID, str2)) return ShowSyntax(playerid, "/pm [player id/name] [message]");

	if (GetPlayerConfigValue(playerid, "DND") == 1) return Text_Send(playerid, $CLIENT_433x);

	if (IsPlayerConnected(ID)) {
	   if (ID != playerid) {
			if (GetPlayerConfigValue(ID, "DND") == 0) {
				mysql_format(Database, str, sizeof(str), "SELECT * FROM `IgnoreList` WHERE `BlockerId` = '%d' AND `BlockedId` = '%d' LIMIT 1", PlayerInfo[ID][pAccountId], PlayerInfo[playerid][pAccountId]);
				mysql_tquery(Database, str, "SendPM", "iis", playerid, ID, str2);
			} else Text_Send(playerid, $CLIENT_420x);
		}
	} else Text_Send(playerid, $NEWCLIENT_193x);
	return 1;
}

flags:r(CMD_SECRET);
alias:r("rpm", "reply");
CMD:r(playerid, params[]) {
   if (PlayerInfo[playerid][pMuted] == 1)
   {
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

   new str[290], str2[140];
   if (sscanf(params, "s[140]", str2)) return ShowSyntax(playerid, "/r(eply) [message]");
   
   new ID = -1;
   if (pLastMessager[playerid] != INVALID_PLAYER_ID) {
	   ID = pLastMessager[playerid];
   }
   
   if (GetPlayerConfigValue(playerid, "DND") == 1) return Text_Send(playerid, $CLIENT_433x);
   
   if (ID != -1) {
	   if (GetPlayerConfigValue(ID, "DND") == 0) {
			mysql_format(Database, str, sizeof(str), "SELECT * FROM `IgnoreList` WHERE `BlockerId` = '%d' AND `BlockedId` = '%d' LIMIT 1", PlayerInfo[ID][pAccountId], PlayerInfo[playerid][pAccountId]);
			mysql_tquery(Database, str, "SendPM", "iis", playerid, ID, str2);
			pLastMessager[ID] = playerid;
	   } else Text_Send(playerid, $CLIENT_420x);
   } else Text_Send(playerid, $NEWCLIENT_193x);

   return 1;
}

CMD:dnd(playerid) {
   if (GetPlayerConfigValue(playerid, "DND") == 0) {
	   SetPlayerConfigValue(playerid, "DND", 1);
	   PlayerPlaySound(playerid, 1057, 	0.0, 	0.0, 	0.0);
   } else if (GetPlayerConfigValue(playerid, "DND") == 1) {
	   SetPlayerConfigValue(playerid, "DND", 0);
	   PlayerPlaySound(playerid, 	1085, 	0.0, 	0.0, 	0.0);
   }
   return 1;
}

CMD:block(playerid, params[]) {
	new targetid;
	if (!pVerified[playerid]) return 1;
	if (sscanf(params, "u", targetid)) return ShowSyntax(playerid, "/block [playerid/name]");
	if (!IsPlayerConnected(targetid) || targetid == INVALID_PLAYER_ID || targetid == playerid) return Text_Send(playerid, $NEWCLIENT_193x);

	new query[150];
	mysql_format(Database, query, sizeof(query), "SELECT * FROM `IgnoreList` WHERE `BlockerId` = '%d' AND `BlockedId` = '%d' LIMIT 1", PlayerInfo[playerid][pAccountId], PlayerInfo[targetid][pAccountId]);
	mysql_tquery(Database, query, "BlockPlayer", "ii", playerid, targetid);
	return 1;
}

CMD:unblock(playerid, params[]) {
	new targetid;
	if (!pVerified[playerid]) return 1;
	if (sscanf(params, "u", targetid)) return ShowSyntax(playerid, "/unblock [playerid/name]");
	if (!IsPlayerConnected(targetid) || targetid == INVALID_PLAYER_ID || targetid == playerid) return Text_Send(playerid, $NEWCLIENT_193x);

	new query[150];
	mysql_format(Database, query, sizeof(query), "SELECT * FROM `IgnoreList` WHERE `BlockerId` = '%d' AND `BlockedId` = '%d' LIMIT 1", PlayerInfo[playerid][pAccountId], PlayerInfo[targetid][pAccountId]);
	mysql_tquery(Database, query, "UnblockPlayer", "ii", playerid, targetid);
	return 1;
}

//Local chat

flags:l(CMD_SECRET); 
alias:l("local");
CMD:l(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel] < svtconf[max_admin_level] && svtconf[anti_adv] && AdCheck(params)) {
		Text_Send(playerid, $ADV_ALERT);

		new adcheck[150];
		format(adcheck, sizeof(adcheck), "*%s[%d] has attempted to advertise: %s", PlayerInfo[playerid][PlayerName],
		playerid, params);

		MessageToAdmins(X11_IVORY, adcheck);
		
		PlayerInfo[playerid][pAdvAttempts] ++;
		return 0;
	}

	if (PlayerInfo[playerid][pMuted] == 1) {
		Text_Send(playerid, $CLIENT_420x);
		return 0;
	}

	if (isnull(params)) return ShowSyntax(playerid, "/l [text]");

	new Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);
	foreach (new i: Player) {
		if (IsPlayerInRangeOfPoint(i, 7.0, x, y, z)) Text_Send(i, $NEWCLIENT_190x, PlayerInfo[playerid][PlayerName], params[0]);
	}

	new adminstr[128];
	format(adminstr, sizeof(adminstr), "*Local %s[%d]: %s", PlayerInfo[playerid][PlayerName], playerid, params);
	MessageToAdminsEx(playerid, X11_GRAY, adminstr);
	return 1;
}

//End of File
/* (c) H2O Multiplayer 2018-2020. All rights reserved. */