/*
	SWAT vs Terrorists is a team death-match SA-MP game-mode script. 
	Compatible with SA-MP 0.3.7 and later releases.

	Author: H2O
	Licensed under GNU GPLv3

	(c) 2018-2020 H2O Multiplayer. All rights reserved.
	Website: h2omultiplayer.com
*/

#include <YSI_Coding\y_hooks>
#include <YSI_Players\y_text>
loadtext mode_text[all], mode_text[client], mode_text[newcs], mode_text[dialogs], mode_text[gametexts];

//Include primary system cores

#include "players/auth/register.pwn"
#include "players/auth/login.pwn"

//Post connection authentication
forward OnPlayerDataReceived(playerid, race_check);
public OnPlayerDataReceived(playerid, race_check) {
	if (race_check != pRaceCheck[playerid]) return Kick(playerid);

	for (new i = 0; i < sizeof(SvTTD); i++) {
		TextDrawHideForPlayer(playerid, SvTTD[i]);
	}

	for (new i = 0; i < 25; i++) {
		SendClientMessage(playerid, -1, "");
	}

	TextDrawShowForPlayer(playerid, Site_TD);
	TextDrawShowForPlayer(playerid, SvT_TD);
	GetPlayerIp(playerid, PlayerInfo[playerid][pIP], 16);
	GetPlayerVersion(playerid, PlayerInfo[playerid][pSAMPClient], 10);
	
	new String[368], query[220 + MAX_PLAYER_NAME];

	format(String, sizeof(String), "%s[%d] has joined (IP %s)", PlayerInfo[playerid][PlayerName], playerid, PlayerInfo[playerid][pIP]);
	MessageToManagers(X11_GREEN, String);

	mysql_format(Database, query, sizeof(query), "SELECT * FROM `BansData` WHERE `BannedName` = '%e' LIMIT 1", PlayerInfo[playerid][PlayerName]);
	mysql_tquery(Database, query, "CheckBansData", "i", playerid);

	if (cache_num_rows() > 0) {
		pVerified[playerid] = true;
		PlayerInfo[playerid][pCacheId] = cache_save();

		new ip[25], pgpci[41], dLvl, bool: everified;
		cache_get_value(0, "Password", PlayerInfo[playerid][pPassword], 65);
		cache_get_value(0, "Salt", PlayerInfo[playerid][pSaltKey], 11);
		cache_get_value(0, "IP", ip, 25);
		cache_get_value(0, "GPCI", pgpci, sizeof(pgpci));
		cache_get_value_int(0, "DonorLevel", dLvl);
		cache_get_value_int(0, "TFA", PlayerInfo[playerid][pTFA]);
		cache_get_value_name_bool(0, "EmailVerified", everified);
		cache_get_value(0, "SupportKey", PlayerInfo[playerid][pSupportKey]);

		if (dLvl >= 4) {
			Text_Send(@pVerified, $SERVER_3x, PlayerInfo[playerid][PlayerName]);
		}

		new rank[9];
		switch (dLvl) {
			case 0: rank = "Regular";
			case 1: rank = "Bronze";
			case 2: rank = "Silver";
			case 3: rank = "Gold";
			case 4: rank = "Platinum";
			case 5: rank = "Ultimate";
		}

		Text_Send(playerid, $DONOR_ALERT, rank);

	    inline TFAuthLogin(pid, dialogid, response, listitem, string:inputtext[]) {
	    	#pragma unused listitem, dialogid
			if (!response) {
				return Kick(pid);
			}
			if (!strcmp(inputtext, PlayerInfo[pid][pSupportKey]) && !isnull(inputtext)) {
				PlayerInfo[pid][pPasswordVerified] = 1;
				PlayerInfo[pid][pLoggedIn] = 1;
				LoginPlayer(pid);
			} else {
				Text_DialogBox(pid, DIALOG_STYLE_INPUT, using inline TFAuthLogin, $LOGIN_CAP, $TFA_LOGIN_DESC, $LOGIN_1ST, $LOGIN_2ND);
			}
		}

	    inline Login(pid, dialogid, response, listitem, string:inputtext[]) {
	    	#pragma unused listitem, dialogid
			if (!response) {
				return Kick(pid);
			}

			new Salted_Key[65];
			SHA256_PassHash(inputtext, PlayerInfo[pid][pSaltKey], Salted_Key, 65);

			if (strcmp(Salted_Key, PlayerInfo[pid][pPassword]) == 0 && strlen(Salted_Key) == strlen(PlayerInfo[pid][pPassword]) && !isnull(PlayerInfo[pid][pPassword])) {
				if (!PlayerInfo[pid][pTFA] || !everified || isnull(PlayerInfo[pid][pSupportKey])) {
					PlayerInfo[pid][pPasswordVerified] = 1;
					PlayerInfo[pid][pLoggedIn] = 1;
					LoginPlayer(pid);
				} else {
					Text_DialogBox(pid, DIALOG_STYLE_INPUT, using inline TFAuthLogin, $TFA_LOGIN_CAP, $TFA_LOGIN_DESC, $LOGIN_1ST, $LOGIN_2ND);
				}
			} else {
				PlayerInfo[pid][pFailedLogins]++;
				Text_DialogBox(pid, DIALOG_STYLE_PASSWORD, using inline Login, $LOGIN_CAP, $LOGIN_DESCFAIL, $LOGIN_1ST, $LOGIN_2ND, PlayerInfo[pid][PlayerName], PlayerInfo[pid][pFailedLogins]);
				if (PlayerInfo[pid][pFailedLogins] == 3) {
					Text_Send(@pVerified, $SERVER_4x, PlayerInfo[pid][PlayerName], pid);
					Kick(pid);
				}
			}
	    }
		Text_DialogBox(playerid, DIALOG_STYLE_PASSWORD, using inline Login, $LOGIN_CAP, $LOGIN_DESC, $LOGIN_1ST, $LOGIN_2ND, PlayerInfo[playerid][PlayerName]);
	} else {
		if (strfind(PlayerInfo[playerid][PlayerName], "[SvT]", true) != -1) {
			Text_Send(playerid, $CLIENT_145x);
			return SetTimerEx("ApplyBan", 500, false, "i", playerid);
		}

		pVerified[playerid] = false;

		PlayerInfo[playerid][pDoNotDisturb] =
		PlayerInfo[playerid][pNoDuel] = 0;
		
		PlayerInfo[playerid][pHitIndicatorEnabled] =
		PlayerInfo[playerid][pGUIEnabled] = 1;

		PlayerInfo[playerid][pSpawnKillTime] = 15;

		PlayerInfo[playerid][pRegDate] = gettime();
		PlayerInfo[playerid][pLastVisit] = gettime();

		new email_attempts = 0;

		inline RegisterEmail(pid, dialogid, response, listitem, string:inputtext[]) {
			#pragma unused dialogid, inputtext, listitem
			if (!response) {
				CompleteRegistration(pid);
				return false;
			}

			if (email_attempts > 3) {
				CompleteRegistration(pid);
				return false;
			}

			email_attempts ++;

			if (!IsValidEmail(inputtext)) {
				Text_DialogBox(playerid, DIALOG_STYLE_INPUT, using inline RegisterEmail, $REGISTER_CAP_EMAIL, $REGISTER_DESC_ERROR_EMAIL, $REGISTER_2ND, $REGISTER_3RD, PlayerInfo[playerid][PlayerName]);
				Text_Send(pid, $CLIENT_146x);
				return false;
			}

			new Cache: EmailQuery, bool: IsEmailRegistered = false;
			mysql_format(Database, query, sizeof(query), "SELECT * FROM `Players` WHERE `EmailAddress` = '%e'", inputtext);
			EmailQuery = mysql_query(Database, query);
			if (cache_num_rows()) {
				IsEmailRegistered = true;
			}
			cache_delete(EmailQuery);

			if (IsEmailRegistered) {
				Text_DialogBox(playerid, DIALOG_STYLE_INPUT, using inline RegisterEmail, $REGISTER_CAP_EMAIL, $REGISTER_DESC_ERROR_EMAIL_ALR, $REGISTER_2ND, $REGISTER_3RD, PlayerInfo[playerid][PlayerName]);
				Text_Send(pid, $CLIENT_147x);
				return false;
			}

			format(PlayerInfo[pid][pEmailAddress], 65, inputtext);
			Text_Send(pid, $CLIENT_148x);

			CompleteRegistration(pid);
		}

		inline RegisterPassword(pid, dialogid, response, listitem, string:inputtext[]) {
			#pragma unused dialogid, inputtext, listitem
			if (!response) {
				Kick(pid);
				return false;
			}

			if (strlen(inputtext) < 4 || strlen(inputtext) > 20) {
				Text_DialogBox(playerid, DIALOG_STYLE_PASSWORD, using inline RegisterPassword, $REGISTER_CAP_PASS, $REGISTER_DESC_ERROR_PASS, $REGISTER_1ST, "", PlayerInfo[playerid][PlayerName]);
				Text_Send(pid, $CLIENT_149x);
				return false;
			}

			format(PlayerInfo[pid][pPassword], 21, inputtext);
			Text_Send(pid, $CLIENT_150x);

			Text_DialogBox(playerid, DIALOG_STYLE_INPUT, using inline RegisterEmail, $REGISTER_CAP_EMAIL, $REGISTER_DESC_EMAIL, $REGISTER_2ND, $REGISTER_3RD, PlayerInfo[playerid][PlayerName]);
		}

		Text_DialogBox(playerid, DIALOG_STYLE_PASSWORD, using inline RegisterPassword, $REGISTER_CAP_PASS, $REGISTER_DESC, $REGISTER_1ST, "", PlayerInfo[playerid][PlayerName]);
	}

    new randcampos = random(2);
    switch (randcampos) {
        case 0: {
			InterpolateCameraPos(playerid, -755.4227,2245.6294,72.2243, -753.3530,2210.8455,53.5234, 12090, CAMERA_MOVE);
			InterpolateCameraLookAt(playerid, -753.3530,2210.8455,53.5234, -745.8900,2200.1982,51.0226, 12000, CAMERA_MOVE);
		}
        case 1: {
			InterpolateCameraPos(playerid, -796.4103,2242.9009,62.9400, -753.3530,2210.8455,53.5234, 12090, CAMERA_MOVE);
			InterpolateCameraLookAt(playerid, -753.3530,2210.8455,53.5234, -745.8900,2200.1982,51.0226, 12000, CAMERA_MOVE);
		}
    }
    Streamer_UpdateEx(playerid, -745.8900, 2200.1982, 51.0226);
    return true;
}

hook OnPlayerConnect(playerid) {
	pRaceCheck[playerid]++;

	new query[112];

	mysql_format(Database, query, sizeof query, "SELECT * FROM `Players` WHERE `Username` = '%e' LIMIT 1", PlayerInfo[playerid][PlayerName]);
	mysql_tquery(Database, query, "OnPlayerDataReceived", "dd", playerid, pRaceCheck[playerid]);

	mysql_format(Database, query, sizeof(query), "SELECT * FROM `NameChangesLog` WHERE `NewName` = '%e'", PlayerInfo[playerid][PlayerName]);
	mysql_tquery(Database, query, "GetPreviousName", "i", playerid);

	//Later...
	/*inline ConfirmRules(pid, dialogid, response, listitem, string:inputtext[]) {
		#pragma unused dialogid, response, listitem, inputtext
		if (response) {
			Text_Send(playerid, $AGREEMENT);
			Text_Send(playerid, $LANG_PREF);
			new query[112];
			mysql_format(Database, query, sizeof query, "SELECT * FROM `Players` WHERE `Username` = '%e' LIMIT 1", PlayerInfo[pid][PlayerName]);
			mysql_tquery(Database, query, "OnPlayerDataReceived", "dd", pid, pRaceCheck[pid]);
			mysql_format(Database, query, sizeof(query), "SELECT * FROM `NameChangesLog` WHERE `NewName` = '%e'", PlayerInfo[pid][PlayerName]);
			mysql_tquery(Database, query, "GetPreviousName", "i", pid);
		} else {
			Kick(pid);
		}
	}*/

	//No language selection for now
	/*inline ChangeLanguage(pid, dialogid, response, listitem, string:inputtext[]) {
		#pragma unused dialogid, inputtext
		if (response) {
			switch (listitem) {
				case 0: Langs_SetPlayerLanguage(pid, English);
				case 1: Langs_SetPlayerLanguage(pid, Spanish);
			}
		}

		Text_DialogBox(pid, DIALOG_STYLE_MSGBOX, using inline ConfirmRules, $SERVER_RULES_CAP, $SERVER_RULES_DESC, $DIALOG_AGREE, $DIALOG_DISAGREE);
	}
	Dialog_ShowCallback(playerid, using inline ChangeLanguage, DIALOG_STYLE_LIST, ""RED2"SvT - Select Your Language", "English (Default)\nSpanish (Beta)", "Change", "X");*/
	//Text_DialogBox(playerid, DIALOG_STYLE_MSGBOX, using inline ConfirmRules, $SERVER_RULES_CAP, $SERVER_RULES_DESC, $DIALOG_AGREE, $DIALOG_DISAGREE); // Later
	return true;
}

hook OnPlayerDisconnect(playerid, reason) {
	pRaceCheck[playerid]++;
	return true;
}

//End of File
/* (c) H2O Multiplayer 2018-2020. All rights reserved. */