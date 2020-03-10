/*
	SWAT vs Terrorists is a team death-match SA-MP game-mode script. 
	Compatible with SA-MP 0.3.7 and later releases.

	Author: H2O
	Licensed under GNU GPLv3

	(c) 2018-2020 H2O Multiplayer. All rights reserved.
	Website: h2omultiplayer.com

	//Admin-related clan functions
*/

//Support for y_text, load language files...
#include <YSI_Players\y_text> //Y_Less
loadtext mode_text[all], mode_text[client], mode_text[newcs], mode_text[dialogs], mode_text[gametexts];

//Clan administration
AdminDeleteClan(playerid, const clan[]) {
	new query[290];

	mysql_format(Database, query, sizeof(query), "DELETE FROM `ClansData` WHERE `ClanName` = '%e'", clan);
	mysql_tquery(Database, query);

	for (new i = 0; i < sizeof(ClanInfo) - 1; i++) {
		if (ClanInfo[i][Clan_Id] != -1 && !strcmp(ClanInfo[i][Clan_Name], clan, true)) {
			mysql_format(Database, query, sizeof(query), "UPDATE `Players` SET `ClanId` = '-1' WHERE `ClanId` = '%d'", ClanInfo[i][Clan_Id]);
			mysql_tquery(Database, query);

			mysql_format(Database, query, sizeof(query), "DELETE FROM `ClanLog WHERE `cID` = '%d'", ClanInfo[i][Clan_Id]);
			mysql_tquery(Database, query);

			foreach (new j: Player) {
				if (pClan[j] == ClanInfo[i][Clan_Id]) {
					pClan[j] = -1;
					pClanRank[j] = 0;
				}
			}

			new clear_clan[ClanData] = -1;
			ClanInfo[i] = clear_clan;

			clans--;
			break;
		}
	}

	Text_Send(playerid, $CLIENT_541x);
	return 1;
}

AdminRenameClan(playerid, const oldName[], const newName[]) {
	new query[450];

	for (new i = 0; i < sizeof(ClanInfo) - 1; i++) {
		if (ClanInfo[i][Clan_Id] != -1 && !strcmp(ClanInfo[i][Clan_Name], oldName, true) && !isnull(ClanInfo[i][Clan_Name])) {
			mysql_format(Database, query, sizeof(query), "UPDATE `ClansData` SET `ClanName` = '%e' WHERE `ClanName` = '%e'", newName, oldName);
			mysql_tquery(Database, query);

			new String[128];
			format(String, sizeof(String), "Administrator %s changed clan name from \"%s\" to \"%s\".", PlayerInfo[playerid][PlayerName], oldName, newName);
			MessageToAdmins(0x2281C8FF, String);

			format(ClanInfo[i][Clan_Name], 35, newName);
			break;
		}
	}
		
	Text_Send(playerid, $CLIENT_541x);
	return 1;
}

AdminRenameClanTag(playerid, const tag[], const new_tag[]) {
	new query[450];

	for (new i = 0; i < sizeof(ClanInfo) - 1; i++) {
		if (ClanInfo[i][Clan_Id] != -1 && !strcmp(ClanInfo[i][Clan_Tag], tag, true) && !isnull(ClanInfo[i][Clan_Tag])) {
			mysql_format(Database, query, sizeof(query), "UPDATE `ClansData` SET `ClanTag` = '%e' WHERE `ClanTag` = '%e'", new_tag, tag);
			mysql_tquery(Database, query);

			new String[128];
			format(String, sizeof(String), "Administrator %s changed clan tag from \"%s\" to \"%s\".", PlayerInfo[playerid][PlayerName], tag, new_tag);
			MessageToAdmins(0x2281C8FF, String);

			format(ClanInfo[i][Clan_Tag], 7, new_tag);
			break;
		}
	}
	
	Text_Send(playerid, $CLIENT_541x);
	return 1;
}

AdminChangeClanWeapon(playerid, const clan[], new_weapon) {
	new query[290];

	for (new i = 0; i < sizeof(ClanInfo) - 1; i++) {
		if (ClanInfo[i][Clan_Id] != -1 && !strcmp(ClanInfo[i][Clan_Name], clan, true) && !isnull(ClanInfo[i][Clan_Name])) {
			mysql_format(Database, query, sizeof(query), "UPDATE `ClansData` SET `ClanWeap` = '%d' WHERE `ClanName` = '%e'", new_weapon, clan);
			mysql_tquery(Database, query);

			new String[128];
			format(String, sizeof(String), "Administrator %s changed clan weapon for \"%s\" to \"%d\".", PlayerInfo[playerid][PlayerName], clan, new_weapon);
			MessageToAdmins(0x2281C8FF, String);

			ClanInfo[i][Clan_Weapon] = new_weapon;
			break;
		}
	}
	
	Text_Send(playerid, $CLIENT_541x);
	return 1;
}

AdminChangeClanSkin(playerid, const clan[], new_skin) {
	new query[290];

	for (new i = 0; i < sizeof(ClanInfo) - 1; i++) {
		if (ClanInfo[i][Clan_Id] != -1 && !strcmp(ClanInfo[i][Clan_Name], clan, true) && !isnull(ClanInfo[i][Clan_Name])) {
			mysql_format(Database, query, sizeof(query), "UPDATE `ClansData` SET `ClanSkin` = '%d' WHERE `ClanName` = '%e'", new_skin, clan);
			mysql_tquery(Database, query);

			new String[128];
			format(String, sizeof(String), "Administrator %s changed clan skin for \"%s\" to \"%d\".", PlayerInfo[playerid][PlayerName], clan, new_skin);
			MessageToAdmins(0x2281C8FF, String);

			ClanInfo[i][Clan_Skin] = new_skin;
			break;
		}
	}
	
	Text_Send(playerid, $CLIENT_541x);
	return 1;
}

AdminSetClanWallet(playerid, const clan[], wallet) {
	new query[290];

	for (new i = 0; i < sizeof(ClanInfo) - 1; i++) {
		if (ClanInfo[i][Clan_Id] != -1 && !strcmp(ClanInfo[i][Clan_Name], clan, true) && !isnull(ClanInfo[i][Clan_Name])) {
			mysql_format(Database, query, sizeof(query), "UPDATE `ClansData` SET `ClanWallet` = '%d' WHERE `ClanName` = '%e'", wallet, clan);
			mysql_tquery(Database, query);

			new String[128];
			format(String, sizeof(String), "Administrator %s changed clan wallet for \"%s\" to \"$%d\".", PlayerInfo[playerid][PlayerName], clan, wallet);
			MessageToAdmins(0x2281C8FF, String);

			ClanInfo[i][Clan_Wallet] = wallet;
			break;
		}
	}
	
	Text_Send(playerid, $CLIENT_541x);
	return 1;
}

AdminSetClanXP(playerid, const clan[], xp) {
	new query[290];

	for (new i = 0; i < sizeof(ClanInfo) - 1; i++) {
		if (ClanInfo[i][Clan_Id] != -1 && !strcmp(ClanInfo[i][Clan_Name], clan, true) && !isnull(ClanInfo[i][Clan_Name])) {
			mysql_format(Database, query, sizeof(query), "UPDATE `ClansData` SET `ClanPoints` = '%d' WHERE `ClanName` = '%e' LIMIT 1", xp, clan);
			mysql_tquery(Database, query);

			new String[128];
			format(String, sizeof(String), "Administrator %s changed clan points for \"%s\" to \"%d\".", PlayerInfo[playerid][PlayerName], clan, xp);
			MessageToAdmins(0x2281C8FF, String);

			ClanInfo[i][Clan_XP] = xp;		
			break;
		}
	}
	
	Text_Send(playerid, $CLIENT_541x);
	return 1;
}

//Clan War system and other clan management commands

flags:acw(CMD_ADMIN);
flags:acwend(CMD_ADMIN);
flags:cwskip(CMD_ADMIN);
flags:acwstart(CMD_ADMIN);
flags:cwgoto(CMD_ADMIN);
flags:cwget(CMD_ADMIN);
flags:cwkick(CMD_ADMIN);
flags:forcejoincw(CMD_ADMIN);
flags:setclanxp(CMD_ADMIN);
flags:giveclanxp(CMD_ADMIN);
flags:giveclanwallet(CMD_ADMIN);
flags:setclanwallet(CMD_ADMIN);
flags:setclanskin(CMD_ADMIN);
flags:setclanweap(CMD_ADMIN);
flags:setclantag(CMD_ADMIN);
flags:setclanname(CMD_ADMIN);
flags:clankick(CMD_ADMIN);
flags:setclan(CMD_ADMIN);
flags:rclan(CMD_ADMIN);

CMD:rclan(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel] == svtconf[max_admin_level]) {
		if (isnull(params) || !IsValidClan(params)) return Text_Send(playerid, $NEWCLIENT_142x);
		
		AdminDeleteClan(playerid, params);
	}
	return 1;
}

CMD:setclan(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new targetid, clan[60], rank;
		if (sscanf(params, "ds[60]d", targetid, clan, rank)) return ShowSyntax(playerid, "/setclan [playerid] [clan] [rank]");
		if (!IsValidClan(clan)) return Text_Send(playerid, $NEWCLIENT_142x);
		if (rank > 6 || rank < 1) return Text_Send(playerid, $NEWCLIENT_143x);
		if (!IsPlayerConnected(targetid) || targetid == INVALID_PLAYER_ID) return Text_Send(playerid, $NEWCLIENT_144x);
		if (IsPlayerInAnyClan(targetid)) return Text_Send(playerid, $NEWCLIENT_145x);

		for (new i = 0; i < sizeof(ClanInfo) - 1; i++) {
			if (ClanInfo[i][Clan_Id] != -1 && !strcmp(ClanInfo[i][Clan_Name], clan, true)
				&& !isnull(ClanInfo[i][Clan_Name])) {
				pClan[targetid] = ClanInfo[i][Clan_Id];
				pClanRank[targetid] = rank;
				
				Text_Send(playerid, $NEWCLIENT_146x, PlayerInfo[targetid][PlayerName], ClanInfo[i][Clan_Name], GetPlayerClanRank(targetid));

				if (targetid != playerid) {
					Text_Send(targetid, $NEWCLIENT_147x, PlayerInfo[playerid][PlayerName], ClanInfo[i][Clan_Name], GetPlayerClanRank(targetid));
				}

				new String[128];
				format(String, sizeof(String), "Administrator %s set %s in clan %s as level %d.", PlayerInfo[playerid][PlayerName], PlayerInfo[targetid][PlayerName], ClanInfo[i][Clan_Name], GetPlayerClanRank(targetid));
				MessageToAdmins(0x2281C8FF, String);
			}
		}
	}
	return 1;
}

CMD:clankick(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new targetid;
		if (sscanf(params, "d", targetid)) return ShowSyntax(playerid, "/clankick [playerid]");
		if (!IsPlayerConnected(targetid) || targetid == INVALID_PLAYER_ID) return Text_Send(playerid, $NEWCLIENT_144x);
		if (!IsPlayerInAnyClan(targetid)) return Text_Send(playerid, $NEWCLIENT_148x);

		pClan[targetid] = -1;
		pClanRank[targetid] = 0;
		
		Text_Send(playerid, $NEWCLIENT_149x, PlayerInfo[targetid][PlayerName]);

		if (targetid != playerid) {
			Text_Send(targetid, $NEWCLIENT_150x, PlayerInfo[playerid][PlayerName]);
		}

		new String[128];
		format(String, sizeof(String), "Administrator %s kicked %s from their clan.", PlayerInfo[playerid][PlayerName], PlayerInfo[targetid][PlayerName]);
		MessageToAdmins(0x2281C8FF, String);		
	}
	return 1;
}

CMD:setclanname(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new oldName[60], newName[60];
		if (sscanf(params, "s[60]s[60]", oldName, newName)) return ShowSyntax(playerid, "/setclanname [clan] [new name]");
		if (!IsValidClan(oldName)) return Text_Send(playerid, $NEWCLIENT_142x);
		if (IsValidClan(newName)) return Text_Send(playerid, $NEWCLIENT_151x);
		
		AdminRenameClan(playerid, oldName, newName);
	}
	return 1;
}

CMD:setclantag(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new clan_tag[60], new_tag[7];
		if (sscanf(params, "s[60]s[7]", clan_tag, new_tag)) return ShowSyntax(playerid, "/setclantag [clan tag] [new tag]");
		if (!IsValidClan(clan_tag)) return Text_Send(playerid, $NEWCLIENT_152x);
		if (IsValidClanTag(new_tag)) return Text_Send(playerid, $NEWCLIENT_153x);
		
		AdminRenameClanTag(playerid, clan_tag, new_tag);
	}
	return 1;
}

CMD:setclanweap(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new clan_name[60], new_weapon;
		if (sscanf(params, "s[60]d", clan_name, new_weapon)) return ShowSyntax(playerid, "/setclanweap [clan] [new weap]");
		if (!IsValidClan(clan_name) || !IsValidWeapon(new_weapon)) return Text_Send(playerid, $NEWCLIENT_154x);
		
		AdminChangeClanWeapon(playerid, clan_name, new_weapon);
	}
	return 1;
}

CMD:setclanskin(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new clan_name[60], new_skin;
		if (sscanf(params, "s[60]d", clan_name, new_skin)) return ShowSyntax(playerid, "/setclanskin [clan] [new skin]");
		if (!IsValidClan(clan_name) || !IsValidSkin(new_skin)) return Text_Send(playerid, $NEWCLIENT_155x);
		
		AdminChangeClanSkin(playerid, clan_name, new_skin);
	}
	return 1;
}

CMD:setclanwallet(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new clan_name[60], wallet;
		if (sscanf(params, "s[60]d", clan_name, wallet)) return ShowSyntax(playerid, "/setclanwallet [clan] [wallet]");
		if (!IsValidClan(clan_name)) return Text_Send(playerid, $NEWCLIENT_142x);
		
		AdminSetClanWallet(playerid, clan_name, wallet);
	}
	return 1;
}

CMD:giveclanwallet(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new clan_name[60], wallet;
		if (sscanf(params, "s[60]d", clan_name, wallet)) return ShowSyntax(playerid, "/giveclanwallet [clan] [amount]");
		if (!IsValidClan(clan_name)) return Text_Send(playerid, $NEWCLIENT_142x);

		AdminSetClanWallet(playerid, clan_name, GetClanWallet(clan_name) + wallet);
	}
	return 1;
}

CMD:setclanxp(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new clan_name[60], xp;
		if (sscanf(params, "s[60]d", clan_name, xp)) return ShowSyntax(playerid, "/setclanxp [clan] [pEXPEarned]");
		if (!IsValidClan(clan_name)) return Text_Send(playerid, $NEWCLIENT_142x);
		
		AdminSetClanXP(playerid, clan_name, xp);
	}
	return 1;
}

CMD:giveclanxp(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		new clan_name[60], xp;
		if (sscanf(params, "s[60]d", clan_name, xp)) return ShowSyntax(playerid, "/giveclanxp [clan] [pEXPEarned]");
		if (!IsValidClan(clan_name)) return Text_Send(playerid, $NEWCLIENT_142x);

		AdminSetClanXP(playerid, clan_name, GetClanXP(clan_name) + xp);
	}
	return 1;
}

CMD:acw(playerid, params[]) {
	if (cwInfo[cw_ready] == 1 || cwInfo[cw_started] == 1) return Text_Send(playerid, $NEWCLIENT_156x);

	new clan_tag[10], clan_tag2[10], weapset, skin1, skin2, maxrounds;
	if (sscanf(params, "s[10]s[10]dddd", clan_tag, clan_tag2, weapset, skin1, skin2, maxrounds)) return ShowSyntax(playerid, "/acw [clan tag] [clan tag] [weap set] [skin 1] [skin 2] [rounds]");
	if (weapset > 4 || weapset <= 0) return Text_Send(playerid, $NEWCLIENT_157x);
	if (maxrounds > 12 || maxrounds <= 0) return Text_Send(playerid, $NEWCLIENT_158x);

	if (IsValidClanTag(clan_tag) && IsValidClanTag(clan_tag2)) {
		new leaders1, leaders2;
		foreach (new i: Player) {
			if (!strcmp(GetClanTag(GetPlayerClan(i)), clan_tag)) {
				if (GetPlayerClanRank(i) >= GetClanWarPerms(GetPlayerClan(playerid)))
				{
					leaders1++;
				}
			}
			
			if (!strcmp(GetClanTag(GetPlayerClan(i)), clan_tag2)) {
				if (GetPlayerClanRank(i) >= GetClanWarPerms(GetPlayerClan(playerid)))
				{
					leaders2++;
				}
			}
		}
		
		if (!leaders1 && !leaders2) return Text_Send(playerid, $NEWCLIENT_159x);
		
		cwInfo[cw_ready] = 1;
		cwInfo[cw_plantime] = gettime() + 99999;

		cwInfo[cw_clan1score] = 0;
		cwInfo[cw_clan2score] = 0;

		cwInfo[cw_rounds] = 1;
		cwInfo[cw_started] = 0;
		
		cwInfo[cw_admin] = 1;

		cwInfo[cw_maxrounds] = maxrounds;
		
		switch (weapset) {
			case 1: {
				cwInfo[cw_weap1] = 24;
				cwInfo[cw_weap2] = 27;
				cwInfo[cw_weap3] = 34;
				cwInfo[cw_weap4] = 16;
			}
			case 2: {
				cwInfo[cw_weap1] = 23;
				cwInfo[cw_weap2] = 26;
				cwInfo[cw_weap3] = 32;
				cwInfo[cw_weap4] = 33;
			}
			case 3: {
				cwInfo[cw_weap1] = 24;
				cwInfo[cw_weap2] = 34;
				cwInfo[cw_weap3] = 28;
				cwInfo[cw_weap4] = 17;
			}
			case 4: {
				cwInfo[cw_weap1] = 22;
				cwInfo[cw_weap2] = 25;
				cwInfo[cw_weap3] = 34;
				cwInfo[cw_weap4] = 16;
			}
		}
		
		cwInfo[cw_skin1] = skin1;
		cwInfo[cw_skin2] = skin2;

		format(cwInfo[cw_clan1], 35, "%s", GetClanName(clan_tag));
		format(cwInfo[cw_clan2], 35, "%s", GetClanName(clan_tag2));

		Iter_Clear(CWCLAN1);
		Iter_Clear(CWCLAN2);

		inline ACWMap(pid, dialogid, response, listitem, string:inputtext[]) {
			#pragma unused dialogid, inputtext
			if (!response) return cwInfo[cw_ready] = cwInfo[cw_started] = 0;

			cwInfo[cw_map] = listitem;

			if (cwInfo[cw_ready] != 1) return Text_Send(pid, $NEWCLIENT_161x);
			Text_Send(@pVerified, $SERVER_71x, cwInfo[cw_clan1], cwInfo[cw_clan2]);

			new String[128];
			format(String, sizeof(String), "Administrator %s started a clan war.", PlayerInfo[playerid][PlayerName]);
			MessageToAdmins(0x2281C8FF, String);

			foreach (new i: Player) {
				if (IsPlayerInAnyClan(i)) {
					if (!strcmp(GetPlayerClan(i), cwInfo[cw_clan1])) {
						Iter_SafeRemove(CWCLAN1, i, i);
					} else {
						Iter_SafeRemove(CWCLAN2, i, i);
					}

					if (!strcmp(GetPlayerClan(i), cwInfo[cw_clan1])) {
						Text_Send(i, $NEWCLIENT_162x, cwInfo[cw_clan2]);
						GameTextForPlayer(i, "~g~CLAN WAR~n~~w~JOIN!~n~~n~/JOINCW", 5000, 3);
					}

					if (!strcmp(GetPlayerClan(i), cwInfo[cw_clan2])) {
						Text_Send(i, $NEWCLIENT_162x, cwInfo[cw_clan1]);
						GameTextForPlayer(i, "~g~CLAN WAR~n~~w~JOIN!~n~~n~/JOINCW", 5000, 3);
					}
				}
			}
		}

		Dialog_ShowCallback(playerid, using inline ACWMap, DIALOG_STYLE_LIST, "Select Map:", "Stadium\nBattlefield\nLVPD\nnew Island\nJefferson Motel", ">>", "Exit");
	}  else Text_Send(playerid, $NEWCLIENT_163x);

	return 1;
}

CMD:acwend(playerid) {
	if (cwInfo[cw_ready] == 0) return Text_Send(playerid, $NEWCLIENT_164x);

	cwInfo[cw_ready] = 0;
	cwInfo[cw_started] = 0;

	foreach (new i: CWCLAN1) {
		Iter_SafeRemove(CWCLAN1, i, i);
		if (!IsPlayerSpawned(i)) {
			TogglePlayerSpectating(i, false);
		}

		SpawnPlayer(i);
	}
	
	foreach (new i: CWCLAN2) {
		Iter_SafeRemove(CWCLAN2, i, i);
		if (!IsPlayerSpawned(i)) {
			TogglePlayerSpectating(i, false);
		}

		SpawnPlayer(i);
	}

	Iter_Clear(CWCLAN1);
	Iter_Clear(CWCLAN2);

	Text_Send(@pVerified, $SERVER_32x);

	new String[128];
	format(String, sizeof(String), "Administrator %s ended a clan war.", PlayerInfo[playerid][PlayerName]);
	MessageToAdmins(0x2281C8FF, String);
	return 1;
}

CMD:cwget(playerid) {
	if (cwInfo[cw_ready] == 0) return Text_Send(playerid, $NEWCLIENT_164x);
	if (!PlayerInfo[playerid][pAdminLevel]) return 1;

	new Float: X, Float: Y, Float: Z;
	GetPlayerPos(playerid, X, Y, Z);

	foreach (new i: CWCLAN1) {
		SetPlayerPos(i, X, Y, Z);
	}

	foreach (new i: CWCLAN2) {
		SetPlayerPos(i, X, Y, Z);
	}

	new String[128];
	format(String, sizeof(String), "Administrator %s teleported clan war players.", PlayerInfo[playerid][PlayerName]);
	MessageToAdmins(0x2281C8FF, String);
	return 1;
}

CMD:cwgoto(playerid) {
	if (cwInfo[cw_ready] == 0) return Text_Send(playerid, $NEWCLIENT_164x);

	new Float: X, Float: Y, Float: Z;
	GetPlayerPos(Iter_Random(CWCLAN1), X, Y, Z);
	SetPlayerPos(playerid, X, Y, Z);

	GameTextForPlayer(playerid, "~g~TELEPORTED!", 3000, 3);

	new String[128];
	format(String, sizeof(String), "Administrator %s teleported to clan war players.", PlayerInfo[playerid][PlayerName]);
	MessageToAdmins(0x2281C8FF, String);
	return 1;
}

CMD:acwstart(playerid) {
	if (cwInfo[cw_ready] == 0) return Text_Send(playerid, $NEWCLIENT_164x);
	cwInfo[cw_started] = 1;

	foreach (new i: CWCLAN1) {
		Text_Send(i, $GO);
		SpawnPlayer(i);
	}
	
	foreach (new i: CWCLAN2) {
		Text_Send(i, $GO);
		SpawnPlayer(i);
	}

	Text_Send(@pVerified, $SERVER_33x);

	new String[128];
	format(String, sizeof(String), "Administrator %s began the clan war.", PlayerInfo[playerid][PlayerName]);
	MessageToAdmins(0x2281C8FF, String);
	return 1;
}

CMD:cwskip(playerid) {
	if (cwInfo[cw_ready]) {
		if (cwInfo[cw_started]) {
			if (Iter_Count(CWCLAN1) <= 0 && Iter_Count(CWCLAN2) <= 0) {
				foreach (new x: CWCLAN1) {
					Iter_SafeRemove(CWCLAN1, x, x);
					PlayerInfo[x][pClanWarSpec] = 0;
					if (!IsPlayerSpawned(x)) {
						TogglePlayerSpectating(x, false);
					}
					SpawnPlayer(x);
					Text_Send(x, $ROUND_SKIPPED);
				}
				
				foreach (new x: CWCLAN2) {
					Iter_Remove(CWCLAN2, x);
					PlayerInfo[x][pClanWarSpec] = 0;
					if (!IsPlayerSpawned(x)) {
						TogglePlayerSpectating(x, false);
					}
					SpawnPlayer(x);
					Text_Send(x, $ROUND_SKIPPED);
				}
				return 1;
			}
			else if (Iter_Count(CWCLAN1) <= 0 || Iter_Count(CWCLAN2) <= 0) {
				if (cwInfo[cw_rounds] == cwInfo[cw_maxrounds]) {
					if (Iter_Count(CWCLAN2) > Iter_Count(CWCLAN1)) {
						AddClanXP(cwInfo[cw_clan2], 5000);
						Text_Send(@pVerified, $NEWSERVER_38x, cwInfo[cw_clan2]);
						cwInfo[cw_ready] = 0;
						cwInfo[cw_started] = 0;
						foreach (new x: CWCLAN1) {
							Iter_SafeRemove(CWCLAN1, x, x);
							PlayerInfo[x][pClanWarSpec] = 0;
							if (!IsPlayerSpawned(x)) {
								TogglePlayerSpectating(x, false);
							}
							SpawnPlayer(x);
							Text_Send(x, $ROUND_SKIPPED);
						}
						foreach (new x: CWCLAN2) {
							Iter_Remove(CWCLAN2, x);
							PlayerInfo[x][pClanWarSpec] = 0;
							if (!IsPlayerSpawned(x)) {
								TogglePlayerSpectating(x, false);
							}
							SpawnPlayer(x);
							Text_Send(x, $ROUND_SKIPPED);
						}
						Iter_Clear(CWCLAN1);
						Iter_Clear(CWCLAN2);
					} else {
						AddClanXP(cwInfo[cw_clan1], 5000);
						Text_Send(@pVerified, $NEWSERVER_38x, cwInfo[cw_clan1]);
						cwInfo[cw_ready] = 0;
						cwInfo[cw_started] = 0;
						foreach (new x: CWCLAN1) {
							Iter_SafeRemove(CWCLAN1, x, x);
							PlayerInfo[x][pClanWarSpec] = 0;
							if (!IsPlayerSpawned(x)) {
								TogglePlayerSpectating(x, false);
							}
							SpawnPlayer(x);
							Text_Send(x, $ROUND_SKIPPED);
						}
						foreach (new x: CWCLAN2) {
							Iter_Remove(CWCLAN2, x);
							PlayerInfo[x][pClanWarSpec] = 0;
							if (!IsPlayerSpawned(x)) {
								TogglePlayerSpectating(x, false);
							}
							SpawnPlayer(x);
							Text_Send(x, $ROUND_SKIPPED);
						}
						Iter_Clear(CWCLAN1);
						Iter_Clear(CWCLAN2);
					}
				} else {
					if (Iter_Count(CWCLAN2) > Iter_Count(CWCLAN1))
					{
						AddClanXP(cwInfo[cw_clan2], 500);
						Text_Send(@pVerified, $NEWSERVER_39x, cwInfo[cw_clan2], cwInfo[cw_rounds]);

						cwInfo[cw_rounds]++;
						cwInfo[cw_clan2score]++;
						if (cwInfo[cw_admin])
						{
							switch (cwInfo[cw_rounds])
							{
								case 3: cwInfo[cw_map] = 0;
								case 6: cwInfo[cw_map] = 1;
								case 9: cwInfo[cw_map] = 2;
								case 12: cwInfo[cw_map] = 4;
							}
						}

						foreach (new x: CWCLAN1)
						{
							PlayerInfo[x][pClanWarSpec] = 0;
							if (!IsPlayerSpawned(x)) {
								TogglePlayerSpectating(x, false);
							}
							SpawnPlayer(x);
						}
						
						foreach (new x: CWCLAN2)
						{
							PlayerInfo[x][pClanWarSpec] = 0;
							if (!IsPlayerSpawned(x)) {
								TogglePlayerSpectating(x, false);
							}
							SpawnPlayer(x);
						}
					}
					if (Iter_Count(CWCLAN1) > Iter_Count(CWCLAN2))
					{
						AddClanXP(cwInfo[cw_clan1], 500);
						Text_Send(@pVerified, $NEWSERVER_39x, cwInfo[cw_clan1], cwInfo[cw_rounds]);
						cwInfo[cw_rounds]++;
						cwInfo[cw_clan1score]++;
						if (cwInfo[cw_admin])
						{
							switch (cwInfo[cw_rounds])
							{
								case 3: cwInfo[cw_map] = 0;
								case 6: cwInfo[cw_map] = 1;
								case 9: cwInfo[cw_map] = 2;
								case 12: cwInfo[cw_map] = 4;
							}
						}
						foreach (new x: CWCLAN1)
						{
							PlayerInfo[x][pClanWarSpec] = 0;
							if (!IsPlayerSpawned(x)) {
								TogglePlayerSpectating(x, false);
							}
							SpawnPlayer(x);
						}
						foreach (new x: CWCLAN2)
						{
							PlayerInfo[x][pClanWarSpec] = 0;
							if (!IsPlayerSpawned(x)) {
								TogglePlayerSpectating(x, false);
							}
							SpawnPlayer(x);
						}
					}
				}
			}
			new String[128];
			format(String, sizeof(String), "Administrator %s skipped the clan war.", PlayerInfo[playerid][PlayerName]);
			MessageToAdmins(0x2281C8FF, String);
		}
	}

	return 1;
}

CMD:cwkick(playerid, params[]) {
	if (cwInfo[cw_ready] == 0) return Text_Send(playerid, $NEWCLIENT_165x);
	if (!PlayerInfo[playerid][pAdminLevel]) return 1;

	new targetid;
	if (sscanf(params, "u", targetid)) return ShowSyntax(playerid, "/cwkick [player id]");
	if (!IsPlayerInAnyClan(targetid)) return Text_Send(playerid, $NEWCLIENT_166x);
	if (!Iter_Contains(CWCLAN1, targetid) || !Iter_Contains(CWCLAN2, targetid)) return Text_Send(playerid, $NEWCLIENT_170x);

	if (IsPlayerInAnyClan(targetid)) {
		if (!strcmp(GetPlayerClan(targetid), cwInfo[cw_clan1])) {
			Iter_SafeRemove(CWCLAN1, targetid, targetid);
		} else {
			Iter_SafeRemove(CWCLAN2, targetid, targetid);
		}
	}	
	Text_Send(targetid, $NEWCLIENT_167x);
	SpawnPlayer(targetid);

	new String[128];
	format(String, sizeof(String), "Administrator %s kicked %s from the clan war.", PlayerInfo[playerid][PlayerName], PlayerInfo[targetid][PlayerName]);
	MessageToAdmins(0x2281C8FF, String);
	return 1;
}

CMD:forcejoincw(playerid, params[]) {
	if (cwInfo[cw_ready] == 0) return Text_Send(playerid, $NEWCLIENT_165x);
	if (!PlayerInfo[playerid][pAdminLevel]) return 1;

	new targetid;
	if (sscanf(params, "u", targetid)) return ShowSyntax(playerid, "/forcejoincw [player id]");
	if (!IsPlayerInAnyClan(targetid)) return Text_Send(playerid, $NEWCLIENT_166x);
	if (!IsPlayerSpawned(targetid)) return Text_Send(playerid, $NEWCLIENT_168x);
	if (Iter_Contains(CWCLAN1, targetid) || Iter_Contains(CWCLAN2, targetid)) return Text_Send(playerid, $NEWCLIENT_169x);

	if (IsPlayerInAnyClan(targetid) && (!strcmp(GetPlayerClan(targetid), cwInfo[cw_clan1]) || !strcmp(GetPlayerClan(targetid), cwInfo[cw_clan2]))) {
		PlayerInfo[targetid][pClanWarSpec] = 0;
		PlayerInfo[targetid][pClanWarSpecId] = -1;

		if (!strcmp(GetPlayerClan(targetid), cwInfo[cw_clan1])) {
			Iter_Add(CWCLAN1, targetid);
		}
		else if (!strcmp(GetPlayerClan(targetid), cwInfo[cw_clan2])) {
			Iter_Add(CWCLAN2, targetid);
		}
		
		SetupClanwar(targetid);

		new String[128];
		format(String, sizeof(String), "Administrator %s added %s to the clan war.", PlayerInfo[playerid][PlayerName], PlayerInfo[targetid][PlayerName]);
		MessageToAdmins(0x2281C8FF, String);
	}  else Text_Send(playerid, $NEWCLIENT_170x);
	return 1;
}

//End of File
/* (c) H2O Multiplayer 2018-2020. All rights reserved. */