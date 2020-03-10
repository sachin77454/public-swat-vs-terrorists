/*
	SWAT vs Terrorists is a team death-match SA-MP game-mode script. 
	Compatible with SA-MP 0.3.7 and later releases.

	Author: H2O
	Licensed under GNU GPLv3

	(c) 2018-2020 H2O Multiplayer. All rights reserved.
	Website: h2omultiplayer.com

	Admin related discord commands
*/

//Support for y_text, load language files...
#include <YSI_Players\y_text> //Y_Less
loadtext mode_text[all], mode_text[client], mode_text[newcs], mode_text[dialogs], mode_text[gametexts];

//Admin discord chat

flags:ad(CMD_ADMIN);
CMD:ad(playerid, params[]) {
	if (isnull(params)) return Text_Send(playerid, $NEWCLIENT_184x);

	new String[128];
	format(String, sizeof(String), "[To Discord] %s[%d]: %s", PlayerInfo[playerid][PlayerName], playerid, params);
	foreach (new i: Player) {
		if (PlayerInfo[i][pAdminLevel] >= 1) SendClientMessage(i, 0x008080FF, String);
	}

	new DCC_Channel:StaffChannel;
	StaffChannel = DCC_FindChannelByName(CHANNEL_STAFF_NAME);
	DCC_SendChannelMessage(StaffChannel, String);
	print(String);
	return 1;
}

//Discord server commands

DC_CMD:mgetid(author, params, channel) {
	if (!IsStaffChannel(channel)) return SendDCByName(channel, "you must be an admin to use this command");
	if (isnull(params)) return SendDCByName(channel, "!mgetid [part name of an in game player]");

	new rows;

	foreach (new i: Player) {
		new bool: searched = false;
		for (new pos = 0; pos <= strlen(PlayerInfo[i][PlayerName]); pos ++) {
			if (searched != true) {
				if (strfind(PlayerInfo[i][PlayerName], params, true) == pos) {
					SendDCByName(channel, "found %s [id: %d]", PlayerInfo[i][PlayerName], i);
					searched = true;
					rows ++;
				}
			}
		}
	}

	if (rows == 0) SendDCByName(channel, "couldn't find anything");
	return 1;
}

DC_CMD:machat(author, params, channel) {
	if (!IsStaffChannel(channel)) return SendDCByName(channel, "you must be an admin to use this command");
	if (!IsValidText(author)) return SendDCByName(channel, "your username contains invalid characters, can't send command in-game");

	new message[128];
	if (sscanf(params, "s[127]", message)) return SendDCByName(channel, "use the command again, but the next time write a proper message");

	new game_message[303];
	format(game_message, sizeof(game_message), "[From Discord] %s: %s", author, message);
	foreach (new i: Player) {
		if (PlayerInfo[i][pAdminLevel] >= 1) SendClientMessage(i, 0x008080FF, game_message);
	}

	SendDCByName(channel, "%s (sent in game): %s", author, message);
	return 1;
}

DC_CMD:manswer(author, params, channel) {
	if (!IsStaffChannel(channel)) return SendDCByName(channel, "you must be an admin to use this command");
	if (!IsValidText(author)) return SendDCByName(channel, "your username contains invalid characters, can't send command in-game");

	new id, message[128];
	if (sscanf(params, "ds[127]", id, message)) return SendDCByName(channel, "use the command again, but the next time write a player id and a proper message");

	if (!IsPlayerConnected(id)) return SendDCByName(channel, "invalid player");
	if (!PlayerInfo[id][pQuestionAsked]) return SendDCByName(channel, "this player never asked for help");
	PlayerInfo[id][pQuestionAsked] = 0;

	Text_Send(id, $NEWCLIENT_180x, author, message);

	SendDCByName(channel, "%s (answered %s[%d]): %s", author, PlayerInfo[id][PlayerName], id, message);
	return 1;
}

DC_CMD:mmsg(author, params, channel) {
	if (!IsStaffChannel(channel)) return SendDCByName(channel, "you must be an admin to use this command");
	if (!IsValidText(author)) return SendDCByName(channel, "your username contains invalid characters, can't send command in-game");

	new id, message[128];
	if (sscanf(params, "ds[127]", id, message)) return SendDCByName(channel, "use the command again, but the next time write a player id and a proper message");

	if (!IsPlayerConnected(id)) return SendDCByName(channel, "invalid player");

	Text_Send(id, $NEWCLIENT_181x, author, message);
	SendDCByName(channel, "%s (sent in game to %s[%d]): %s", author, PlayerInfo[id][PlayerName], id, message);
	return 1;
}

DC_CMD:mkick(author, params, channel) {
	if (!IsStaffChannel(channel)) return SendDCByName(channel, "you must be an admin to use this command");
	if (!IsValidText(author)) return SendDCByName(channel, "your username contains invalid characters, can't send command in-game");

	new id, reason[128];
	if (sscanf(params, "ds[127]", id, reason)) return SendDCByName(channel, "use the command again, but the next time write a player id and a proper reason");

	if (!IsPlayerConnected(id)) return SendDCByName(channel, "invalid player");
	if (PlayerInfo[id][pAdminLevel] || PlayerInfo[id][pIsModerator]) return SendDCByName(channel, "you can't kick a staff member");

	Text_Send(id, $NEWCLIENT_182x, author, reason);

	SendDCByName(channel, "%s (kicked %s[%d] in game) for: %s", author, PlayerInfo[id][PlayerName], id, reason);
	SetTimerEx("ApplyBan", 500, false, "i", id);
	return 1;
}

DC_CMD:mwarn(author, params, channel) {
	if (!IsStaffChannel(channel)) return SendDCByName(channel, "you must be an admin to use this command");
	if (!IsValidText(author)) return SendDCByName(channel, "your username contains invalid characters, can't send command in-game");

	new id, reason[128];
	if (sscanf(params, "ds[127]", id, reason)) return SendDCByName(channel, "use the command again, but the next time write a player id and a proper reason");

	if (!IsPlayerConnected(id)) return SendDCByName(channel, "invalid player");
	if (PlayerInfo[id][pAdminLevel] || PlayerInfo[id][pIsModerator]) return SendDCByName(channel, "you can't warn a staff member");

	Text_Send(id, $NEWCLIENT_183x, author, reason, PlayerInfo[id][pTempWarnings], svtconf[max_warns]);

	SendDCByName(channel, "%s (kicked %s[%d] in game) for: %s", author, PlayerInfo[id][PlayerName], id, reason);

	if (PlayerInfo[id][pTempWarnings] > 3) {
		SetTimerEx("ApplyBan", 500, false, "i", id);
	}
	return 1;
}

DC_CMD:mchat(author, params, channel) { 
	if (!IsStaffChannel(channel)) return SendDCByName(channel, "you must be an admin to use this command");
	if (!IsValidText(author)) return SendDCByName(channel, "your username contains invalid characters, can't send command in-game");

	new msg[128]; 
	if(sscanf(params, "s[127]", msg)) return SendDCByName(channel, "use the command again, but the next time with something to say"); 
	SendDCByName(channel, "%s (sent in main chat): %s", author, msg);

	Text_Send(@pVerified, $NEWSERVER_59x, author, msg);
	return 1; 
}

DC_CMD:mann(author, params, channel) { 
	if (!IsStaffChannel(channel)) return SendDCByName(channel, "you must be an admin to use this command");

	new msg[128]; 
	if(sscanf(params, "s[127]", msg)) return SendDCByName(channel, "use the command again, but the next time with something to say"); 
	SendDCByName(channel, "%s (announced in game): %s", author, msg);

	GameTextForAll(msg, 3000, 3);
	return 1; 
}

//End of File
/* (c) H2O Multiplayer 2018-2020. All rights reserved. */