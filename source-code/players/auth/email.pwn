/*
	SWAT vs Terrorists is a team death-match SA-MP game-mode script. 
	Compatible with SA-MP 0.3.7 and later releases.

	Author: H2O
	Licensed under GNU GPLv3

	(c) 2018-2020 H2O Multiplayer. All rights reserved.
	Website: h2omultiplayer.com
*/

#include <YSI_Coding\y_hooks> //Y_Less
#include <YSI_Players\y_text> //Y_Less
loadtext mode_text[all], mode_text[client], mode_text[newcs], mode_text[dialogs], mode_text[gametexts];

//Email handler
forward OnPlayerEmailReceived(index, response_code, data[]);
public OnPlayerEmailReceived(index, response_code, data[]) {
	printf("email request sent [index: %d, response_code: %d, data: %s]", index, response_code, data);
    return 1;
}

//Generate player account support key
stock GenerateSupportKey(playerid) {
	randomString(PlayerInfo[playerid][pSupportKey], 9);
	return 1;
}

//Email syntax validity checkup
IsValidEmail(const text[]) { 
	new Regex:r = Regex_New("[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\\.[a-zA-Z0-9-.]+"); 
	new check = Regex_Check(text, r); 
	Regex_Delete(r); 
	return check; 
}

//Reset
hook OnPlayerConnect(playerid) {
	pEVerifySteps[playerid] = 0;
}

//Check whether e-mail is verified
hook OnPlayerSpawn(playerid) {
	//Verify e-mail address
	if (!PlayerInfo[playerid][pEmailVerified] && IsValidEmail(PlayerInfo[playerid][pEmailAddress])) {
		Text_Send(playerid, $EMAIL_NOTIF);
	}
}

//Email verification player commands
flags:echange(CMD_SECRET);
CMD:echange(playerid, params[]) {
	if (isnull(params)) {
		if (!IsValidEmail(PlayerInfo[playerid][pEmailAddress])) return Text_Send(playerid, $ERR_NO_EMAIL);
		Text_Send(playerid, $EMAIL_RESET);
		PlayerInfo[playerid][pEmailVerified] = false;
		format(PlayerInfo[playerid][pEmailAddress], 65, "");
		format(PlayerInfo[playerid][pSupportKey], 10, "");

		new query[256];
		mysql_format(Database, query, sizeof(query), "UPDATE `Players` SET `EmailAddress` = NULL, `EmailVerified` = false, `SupportKey` = NULL, `TFA` = false WHERE `Username` = '%e' LIMIT 1", PlayerInfo[playerid][PlayerName]);
		mysql_tquery(Database, query);
		PlayerInfo[playerid][pTFA] = false;
		return 1;
	}
	if (!IsValidEmail(params)) return Text_Send(playerid, $ERR_INVALID_EMAIL);
	if (!strcmp(params, PlayerInfo[playerid][pEmailAddress]) && !isnull(PlayerInfo[playerid][pEmailAddress])) return Text_Send(playerid, $ERR_EMAIL_ALR);
	if (pEVerifySteps[playerid] && pEVerifySteps[playerid] != 1) return Text_Send(playerid, $ERR_EMAIL_VERIF);
	new Cache: EmailQuery, bool: IsEmailRegistered = false, query[256];
	mysql_format(Database, query, sizeof(query), "SELECT * FROM `Players` WHERE `EmailAddress` = '%e'", params);
	EmailQuery = mysql_query(Database, query);
	if (cache_num_rows()) {
		IsEmailRegistered = true;
	}
	cache_delete(EmailQuery);
	if (IsEmailRegistered) return Text_Send(playerid, X11_RED2, $ERR_EMAIL_EXISTS);
	PlayerInfo[playerid][pEmailVerified] = false;
	format(PlayerInfo[playerid][pEmailAddress], 65, params);
	format(PlayerInfo[playerid][pSupportKey], 10, "");

	Text_Send(playerid, $EMAIL_CHANGED, params);

	mysql_format(Database, query, sizeof(query), "UPDATE `Players` SET `EmailAddress` = '%e', `EmailVerified` = false, `SupportKey` = NULL, `TFA` = false WHERE `Username` = '%e' LIMIT 1", params, PlayerInfo[playerid][PlayerName]);
	mysql_tquery(Database, query);
	PlayerInfo[playerid][pTFA] = false;
	return 1;
}

flags:everify(CMD_SECRET);
CMD:everify(playerid, params[]) {
	if (PlayerInfo[playerid][pEmailVerified]) return Text_Send(playerid, $ERR_EMAIL_ALR_VERIF);
	switch (pEVerifySteps[playerid]) {
		case 0: {
			if (isnull(PlayerInfo[playerid][pEmailAddress]) || !IsValidEmail(PlayerInfo[playerid][pEmailAddress])) {
				if (isnull(params)) return Text_Send(playerid, $ERR2_NO_EMAIL);
				if (!IsValidEmail(params)) return Text_Send(playerid, $ERR_INVALID_EMAIL);
				new Cache: EmailQuery, bool: IsEmailRegistered = false, query[128];
				mysql_format(Database, query, sizeof(query), "SELECT * FROM `Players` WHERE `EmailAddress` = '%e'", params);
				EmailQuery = mysql_query(Database, query);
				if (cache_num_rows()) {
					IsEmailRegistered = true;
				}
				cache_delete(EmailQuery);
				if (IsEmailRegistered) return Text_Send(playerid, $ERR_EMAIL_EXISTS);
				PlayerInfo[playerid][pEmailVerified] = false;
				format(PlayerInfo[playerid][pEmailAddress], 65, params);
				format(PlayerInfo[playerid][pSupportKey], 10, "");
				PlayerInfo[playerid][pTFA] = false;

				Text_Send(playerid, $EMAIL_CHANGED, params);
				pEVerifySteps[playerid] ++;
			} else {
				Text_Send(playerid, $CONFIRM_EMAIL, PlayerInfo[playerid][pEmailAddress]);
				pEVerifySteps[playerid] ++;
			}
		}
		case 1: {
			if (PlayerInfo[playerid][pEmailVerified]) return Text_Send(playerid, $ERR_EMAIL_ALR_VERIF);
			if (!IsValidEmail(PlayerInfo[playerid][pEmailAddress])) return Text_Send(playerid, $ERR_INVALID_EMAIL);
			if (PlayerInfo[playerid][pEmailAttempts] > 3) {
				pEVerifySteps[playerid] = 0;
				return Text_Send(playerid, $ERR_VERIF_OVERLIMIT);
			}
			new email_post[700];
			randomString(PlayerInfo[playerid][pVerifyCode], 10);
			format(email_post, sizeof(email_post), "rec=%s&evcm=You can now use %s as your code to verify your account.",
				PlayerInfo[playerid][pEmailAddress], PlayerInfo[playerid][pVerifyCode]);
			//HTTP(playerid, HTTP_POST, "", email_post, "OnPlayerEmailReceived"); Replace this with your own/add a php script
			pEVerifySteps[playerid] ++;
			PlayerInfo[playerid][pEmailAttempts] ++;

			new query[256];
			mysql_format(Database, query, sizeof(query), "UPDATE `Players` SET `EmailAttempts`=`EmailAttempts`+1 WHERE `Username` = '%e' LIMIT 1", PlayerInfo[playerid][PlayerName]);
			mysql_tquery(Database, query);
			Text_Send(playerid, $CONFIRM_CODE);
		}
		case 2: {
			if (PlayerInfo[playerid][pEmailVerified]) return Text_Send(playerid, $ERR_EMAIL_ALR_VERIF);
			if (!IsValidEmail(PlayerInfo[playerid][pEmailAddress])) return Text_Send(playerid, $ERR_INVALID_EMAIL);
			if (isnull(params)) {
				pEVerifySteps[playerid] = 0;
				PlayerInfo[playerid][pEmailVerified] = false;
				Text_Send(playerid, $PROC_CANCELLED);

				new query[256];
				mysql_format(Database, query, sizeof(query), "UPDATE `Players` SET `EmailVerified` = false, `SupportKey` = NULL WHERE `Username` = '%e' LIMIT 1", PlayerInfo[playerid][PlayerName]);
				mysql_tquery(Database, query);
			} else {
				if (!strcmp(params, PlayerInfo[playerid][pVerifyCode]) && !isnull(params)) {
					Text_Send(playerid, $EMAIL_CONFIRMED);
					Text_Send(playerid, $EMAIL_CONFIRMED_INFO);
					pEVerifySteps[playerid] = 0;
					PlayerInfo[playerid][pEmailVerified] = true;

					GenerateSupportKey(playerid);

					new query[356];
					mysql_format(Database, query, sizeof(query), "UPDATE `Players` SET `EmailAddress` = '%e', `SupportKey` = '%e', `EmailVerified` = true WHERE `Username` = '%e' LIMIT 1",
						PlayerInfo[playerid][pEmailAddress], PlayerInfo[playerid][pSupportKey], PlayerInfo[playerid][PlayerName]);
					mysql_tquery(Database, query);

					Text_Send(playerid, $SUPPORTKEY_NOTIF);

					new email_post[700];
					format(email_post, sizeof(email_post), "rec=%s&evcm=Your security code is %s, you will be asked to provide it for account ownership verification.",
						PlayerInfo[playerid][pEmailAddress], PlayerInfo[playerid][pSupportKey]);
					//HTTP(playerid, HTTP_POST, "", email_post, "OnPlayerEmailReceived"); Replace this with your own method to send emails/add a php script
				} else return Text_Send(playerid, $CODE_MISMATCH);
			}
		}
	}	
	return 1;
}

//End of File
/* (c) H2O Multiplayer 2018-2020. All rights reserved. */