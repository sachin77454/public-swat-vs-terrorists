/*
	SWAT vs Terrorists is a team death-match SA-MP game-mode script.
	Compatible with SA-MP 0.3.7 and later releases.

	Author: H2O
	Licensed under GNU GPLv3

	(c) 2018-2020 H2O Multiplayer. All rights reserved.
	Website: h2omultiplayer.com

	Votekicking
*/

#include <YSI\y_text>
loadtext mode_text[alt];

task voteKicks[10000]() {
	new admins = 0;
	foreach (new i: Player) {
		if (PlayerInfo[i][pAdminLevel]) {
			admins ++;
		}
	}
	if (admins) return true;

	foreach (new i: Player) {
		if ((pVotesKick[i] / Iter_Count(Player) * 100) > 20.0
				&& pVotesKick[i] > 3) {
			Text_Send(@pVerified, $VOTE_KICK, PlayerInfo[i][PlayerName]);
			BlockIpAddress(PlayerInfo[i][pIP], 1500 * 1000);
			Kick(i);
		}
	}
	return 1;
}

hook OnPlayerConnect(playerid) {
	pVotesKick[playerid] = 0;
	foreach (new i: Player) {
		pVotedKick[playerid][i] = false;
	}
	pVoteKickCD[playerid] = gettime();
	return 1;
}

hook OnPlayerDisconnect(playerid, reason) {
	foreach (new i: Player) {
		pVotedKick[i][playerid] = false;
	}
	return 1;
}

CMD:votekick(playerid, params[]) {
	if (!PlayerInfo[playerid][pLoggedIn]) return 0;

	new targetid;
	if (sscanf(params, "u", targetid)) return ShowSyntax(playerid, "/votekick [playerid/name]");
	if (!IsPlayerConnected(targetid) || targetid == INVALID_PLAYER_ID ||
			targetid == playerid) return 0;

	if (pVotesKick[playerid] > 3) return 0;
	if (pVotedKick[playerid][targetid] == true || PlayerInfo[targetid][pAdminLevel]) return 0;
	if (pVoteKickCD[playerid] > gettime()) return Text_Send(playerid, $VOTE_CD);

	pVotedKick[playerid][targetid] = true;
	pVotesKick[targetid] ++;

	Text_Send(playerid, $VOTED_KICK, PlayerInfo[targetid][PlayerName]);

	pVoteKickCD[playerid] = gettime() + 60;
	return 1;
}

/*CMD:testvk(playerid) {
	pVotesKick[playerid] ++;
	return 1;
}*/

//End of File
/* (c) H2O Multiplayer 2018-2020. All rights reserved. */