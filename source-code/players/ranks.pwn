/*
	SWAT vs Terrorists is a team death-match SA-MP game-mode script.
	Compatible with SA-MP 0.3.7 and later releases.

	Author: H2O
	Licensed under GNU GPLv3

	(c) 2018-2020 H2O Multiplayer. All rights reserved.
	Website: h2omultiplayer.com

	Ranks Module
*/

#include <YSI\y_hooks>
#include <YSI_Players\y_text> //Y_Less
loadtext mode_text[all], mode_text[client], mode_text[newcs], mode_text[dialogs], mode_text[gametexts];

GetPlayerRank(playerid) {
	new rank_id;

	for (new i = sizeof(RankInfo) - 1; i > -1; i--) {
		if (GetPlayerScore(playerid) >= RankInfo[i][Rank_Score]) {
			rank_id = i;
			break;
		}
	}

	return rank_id;
}

GetRankByScore(Score) {
	new rank_id;

	for (new i = sizeof(RankInfo) - 1; i > -1; i--) {
		if (Score >= RankInfo[i][Rank_Score]) {
			rank_id = i;
			break;
		}
	}
	return rank_id;
}

RevealPlayerAbilities(playerid) {
	inline RankMenuReturn(pid, dialogid, response, listitem, string:inputtext[]) {
		#pragma unused dialogid, inputtext, response, listitem
		RevealPlayerAbilities(pid);
	}
	inline RankMenu(pid, dialogid, response, listitem, string:inputtext[]) {
		#pragma unused dialogid, inputtext
		if (response) {
			switch (listitem) {
				case 0: Text_DialogBox(pid, DIALOG_STYLE_MSGBOX, using inline RankMenuReturn, $DIALOG_MESSAGE_CAP, $RANK_MENU_1ST, $DIALOG_RETURN, "");
				case 1: Text_DialogBox(pid, DIALOG_STYLE_MSGBOX, using inline RankMenuReturn, $DIALOG_MESSAGE_CAP, $RANK_MENU_2ND, $DIALOG_RETURN, "");
				case 2: Text_DialogBox(pid, DIALOG_STYLE_MSGBOX, using inline RankMenuReturn, $DIALOG_MESSAGE_CAP, $RANK_MENU_3RD, $DIALOG_RETURN, "");
				case 3: Text_DialogBox(pid, DIALOG_STYLE_MSGBOX, using inline RankMenuReturn, $DIALOG_MESSAGE_CAP, $RANK_MENU_4TH, $DIALOG_RETURN, "");
				case 4: Text_DialogBox(pid, DIALOG_STYLE_MSGBOX, using inline RankMenuReturn, $DIALOG_MESSAGE_CAP, $RANK_MENU_5TH, $DIALOG_RETURN, "");
			}
		}
	}

	new string[1024];
	strcat(string, "Rank Ability (click for info)\tScore Needed\tYour Progress\n");
	format(string, sizeof(string), 
		"%sCustom Weapons\t9500\t%s\n\
		Airstriker\t10000\t%s\n\
		Clan Leader\t10000\t%s\n\
		Nukemaster\t15000\t%s\n\
		Worthless Helmet\t25000\t%s",
		string,
		GetPlayerScore(playerid) >= 9500 ? "Unlocked" : "Locked",
		GetPlayerScore(playerid) >= 10000 ? "Unlocked" : "Locked",
		GetPlayerScore(playerid) >= 10000 ? "Unlocked" : "Locked",
		GetPlayerScore(playerid) >= 15000 ? "Unlocked" : "Locked",
		GetPlayerScore(playerid) >= 25000 ? "Unlocked" : "Locked");
	Dialog_ShowCallback(playerid, using inline RankMenu, DIALOG_STYLE_TABLIST_HEADERS, 
	""RED2"Reveal Your Abilities", string, "Learn", "X");
	return 1;
}

hook OnPlayerConnect(playerid) {
	RankLabel[playerid] = Create3DTextLabel(" ", 0xFFFFFFFF, 0.0, 0.0, 0.0, 20.0, 0, 1);
	return 1;
}

hook OnPlayerDisconnect(playerid, reason) {
	Delete3DTextLabel(RankLabel[playerid]);
	return 1;
}

CMD:ranks(playerid) {
	new string[50 * 15], sub_string[45];
	strcat(string, "#\tRank\tScore\tArmour\n");

	for (new i = 0; i < sizeof(RankInfo); i++) {
		if (RankInfo[PlayerRank[playerid]][Rank_Score] >= RankInfo[i][Rank_Score]) {
			format(sub_string, sizeof(sub_string), ""DARKBLUE"%d\t%s\t%d\t%0.1f\n", i, RankInfo[i][Rank_Name], RankInfo[i][Rank_Score], RankInfo[i][Rank_Armour]);
			strcat(string, sub_string);
		}
		else
		{
			format(sub_string, sizeof(sub_string), ""IVORY"%d\t%s\t%d\t%0.1f\n", i, RankInfo[i][Rank_Name], RankInfo[i][Rank_Score], RankInfo[i][Rank_Armour]);
			strcat(string, sub_string);
		}
	}


	Dialog_Show(playerid, DIALOG_STYLE_TABLIST_HEADERS, ""RED2"SvT - Ranks", string, "X", "");    
	return 1;
}

CMD:rank(playerid) {
	new text[100];

	format(text, sizeof(text), "%s (%d/%d)", RankInfo[PlayerRank[playerid]][Rank_Name], PlayerRank[playerid], sizeof(RankInfo) - 1);
	SendClientMessage(playerid, X11_YELLOW, text);

	RevealPlayerAbilities(playerid);
	return 1;
}


//End of File
/* (c) H2O Multiplayer 2018-2020. All rights reserved. */