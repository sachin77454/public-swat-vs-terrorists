/*
	SWAT vs Terrorists is a team death-match SA-MP game-mode script. 
	Compatible with SA-MP 0.3.7 and later releases.

	Author: H2O
	Licensed under GNU GPLv3

	(c) 2018-2020 H2O Multiplayer. All rights reserved.
	Website: h2omultiplayer.com

	Discord related stuff
*/

IsStaffChannel(const channel[]) {
	if(!strcmp(channel, CHANNEL_STAFF_NAME, true)) {
		return 1;
	}	
	return 0;
}

//Player commands

DC_CMD:mhelp(author, params, channel) { 
	if (IsStaffChannel(channel)) {
		SendDCByName(channel, "!machat - send a message to in game admins\n\
			!manswer - answer a question asked by a player in game"); 
		SendDCByName(channel, "!mmsg - message a player in game\n\
			!mkick - kick a player in game\n\
			!mwarn - warn a player in game\n\
			!mchat - send a message in the game's main chat\n\
			!mann - announce a message on the screen of in game players"); 
	}
	SendDCByName(channel, "!msay - say something in the discord channel you're in\n\
		!mplayers - view in game players\n\
		!madmins - view online staff in game\n\
		!mann - announce a message on the screen of in game players");
	return 1; 
}

DC_CMD:msay(author, params, channel) {
	new msg[128];
	if(sscanf(params, "s[127]", msg)) return SendDCByName(channel, "use the command again, but the next time with something to say"); 
	SendDCByName(channel, msg); 
	return 1; 
}

DC_CMD:mplayers(author, params, channel) { 
	if (!Iter_Count(Player)) return SendDCByName(channel, "there is no one in the server.");
	SendDCByName(channel, "There is currently %d online player(s).", Iter_Count(Player));
	return 1; 
}

DC_CMD:madmins(author, params, channel) { 
	if (!Iter_Count(Player)) return SendDCByName(channel, "there is no one in the server.");
	new staff = 0;
	foreach (new i: Player) {
		if (PlayerInfo[i][pAdminLevel] || PlayerInfo[i][pIsModerator]) {
			staff ++;
		}
	}
	SendDCByName(channel, "There is currently %d online staff member(s).", staff);
	return 1; 
}


//End of File
/* (c) H2O Multiplayer 2018-2020. All rights reserved. */