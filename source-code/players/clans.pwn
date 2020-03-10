/*
	SWAT vs Terrorists is a team death-match SA-MP game-mode script. 
	Compatible with SA-MP 0.3.7 and later releases.

	Author: H2O
	Licensed under GNU GPLv3

	(c) 2018-2020 H2O Multiplayer. All rights reserved.
	Website: h2omultiplayer.com

	This file aims to create the clan system and all it's
	commands
*/

#include <YSI\y_hooks>
#include <YSI\y_text>
loadtext mode_text[all], mode_text[client], mode_text[newcs], mode_text[dialogs], mode_text[gametexts];

forward KickClanMember(playerid, Reason[]);
forward ParseClanUsers(playerid, clan_name[]);
forward OnClanLogView(playerid);
forward CancelInvite(playerid);
forward LoadClans();
forward InitializeClan(playerid, clan_name[], clan_tag[]);

public KickClanMember(playerid, Reason[]) {
	if (cache_num_rows() > 0) {
		new username[MAX_PLAYER_NAME];
		cache_get_value(0, "Username", username, sizeof(username));
		
		foreach (new i: Player) {
			if (IsPlayerInAnyClan(i)) {
				if (pClan[playerid] == pClan[i]) {
					Text_Send(i, $PLAYER_KICKED_FROM_CLAN, username, Reason);
				}
			}
			
			if (!strcmp(PlayerInfo[i][PlayerName], username, true) && !isnull(username)) {
				pClan[i] = -1;
				pClanRank[i] = 0;
				PlayerInfo[i][pClanTag] = 0;
			}
		}
		
		new query[140];

		mysql_format(Database, query, sizeof(query), "UPDATE `Players` SET `ClanId` = '-1', `ClanRank` = '0' WHERE `Username` = '%e' LIMIT 1",  username);
		mysql_tquery(Database, query);

		format(query, sizeof(query), "Offline kicked %s from the clan", username);
		AddClanLog(playerid, query);
		
	}  else Text_Send(playerid, $NOT_IN_PLAYER_CLAN);    
	return 1;
}

//Clan memberlist
public ParseClanUsers(playerid, clan_name[]) {
	if (cache_num_rows() > 0) {
		for (new i, j = cache_num_rows(); i != j; i++) {
			new username[MAX_PLAYER_NAME], clan_rank, clan_id, last_visit;
			cache_get_value(i, "Username", username, sizeof(username));
			cache_get_value_int(i, "ClanRank", clan_rank);
			cache_get_value_int(i, "ClanId", clan_id);
			cache_get_value_int(i, "LastVisit", last_visit);

			Text_Send(playerid, $NEWCLIENT_21x, i + 1, username, GetClanRankName(clan_name, clan_rank), clan_rank, GetWhen(last_visit, gettime()));
		}
	}  else Text_Send(playerid, $EMPTY_CLAN);
	return 1;
}

//Clan logger
public OnClanLogView(playerid) {
	if (cache_num_rows()) {
		Text_Send(playerid, $NEWCLIENT_22x);
		for (new i, j = cache_num_rows(); i != j; i++) {
			new member[MAX_PLAYER_NAME], rank, action[256], date;
			cache_get_value(i, "Member", member, sizeof(member));
			cache_get_value_int(i, "Rank", rank);
			cache_get_value_int(i, "Date", date);
			cache_get_value(i, "Action", action, sizeof(action));

			Text_Send(playerid, $NEWCLIENT_23x, member, rank, action, GetWhen(date, gettime()));
		}
	}  else Text_Send(playerid, $ADMIN_NO_RECORDS);
	return 1;
}

//Cancel a clan invitation
public CancelInvite(playerid) {
	PlayerInfo[playerid][pIsInvitedToClan] = 0;
	Text_Send(playerid, $CANCEL_CLAN_INVITE, PlayerInfo[playerid][pClan_Name]);
	format(PlayerInfo[playerid][pClan_Name], 35, "");	
	return 1;
}

//Load in game clans
public LoadClans() {
	for (new i = 0; i < MAX_CLANS; i++) {
		new clear_clan[ClanData] = -1;
		ClanInfo[i] = clear_clan;
	}

	if (cache_num_rows() > 0) {
		for (new i, j = cache_num_rows(); i != j; i++) {		
			cache_get_value_int(i, "ClanId", ClanInfo[clans][Clan_Id]);
			cache_get_value(i, "ClanName", ClanInfo[clans][Clan_Name], 35);	
			cache_get_value(i, "ClanTag", ClanInfo[clans][Clan_Tag], 7);	
			cache_get_value(i, "ClanMotd", ClanInfo[clans][Clan_Motd], 60);	
			cache_get_value_int(i, "ClanWeap", ClanInfo[clans][Clan_Weapon]);
			cache_get_value_int(i, "ClanWallet", ClanInfo[clans][Clan_Wallet]);
			cache_get_value_int(i, "ClanKills", ClanInfo[clans][Clan_Kills]);
			cache_get_value_int(i, "ClanDeaths", ClanInfo[clans][Clan_Deaths]);
			cache_get_value_int(i, "ClanPoints", ClanInfo[clans][Clan_XP]);
			cache_get_value_int(i, "ClanLevel", ClanInfo[clans][Clan_Level]);
			cache_get_value_int(i, "ClanSkin", ClanInfo[clans][Clan_Skin]);
			cache_get_value(i, "Rank1", ClanInfo[clans][Clan_Rank1], 20);
			cache_get_value(i, "Rank2", ClanInfo[clans][Clan_Rank2], 20);
			cache_get_value(i, "Rank3", ClanInfo[clans][Clan_Rank3], 20);
			cache_get_value(i, "Rank4", ClanInfo[clans][Clan_Rank4], 20);
			cache_get_value(i, "Rank5", ClanInfo[clans][Clan_Rank5], 20);
			cache_get_value(i, "Rank6", ClanInfo[clans][Clan_Rank6], 20);
			cache_get_value(i, "Rank7", ClanInfo[clans][Clan_Rank7], 20);
			cache_get_value(i, "Rank8", ClanInfo[clans][Clan_Rank8], 20);
			cache_get_value(i, "Rank9", ClanInfo[clans][Clan_Rank9], 20);
			cache_get_value(i, "Rank10", ClanInfo[clans][Clan_Rank10], 20);
			cache_get_value_int(i, "InviteClanLevel", ClanInfo[clans][Clan_Addlevel]);
			cache_get_value_int(i, "ClanWarLevel", ClanInfo[clans][Clan_Warlevel]);
			cache_get_value_int(i, "ClanPermsLevel", ClanInfo[clans][Clan_Setlevel]);
			cache_get_value_int(i, "BasePurchaseTime", ClanInfo[clans][Clan_Baseperk]);
			cache_get_value_int(i, "PreferredTeam", ClanInfo[clans][Clan_Team]);

			clans ++;	
		}

		printf("Loaded %d clans from database.", clans);
	}
	return 1;
}

//Create clan
public InitializeClan(playerid, clan_name[], clan_tag[]) {
	clans++;
	ClanInfo[clans][Clan_Id] = cache_insert_id();

	new clantag[7];
	format(clantag, sizeof(clantag), "[%s]", clan_tag);

	format(ClanInfo[clans][Clan_Name], 35, clan_name);
	format(ClanInfo[clans][Clan_Tag], 7, clantag);
	format(ClanInfo[clans][Clan_Motd], 60, "New clan message");
	format(ClanInfo[clans][Clan_Rank1], 20, "Recruit");
	format(ClanInfo[clans][Clan_Rank2], 20, "Novice");
	format(ClanInfo[clans][Clan_Rank3], 20, "Member");
	format(ClanInfo[clans][Clan_Rank4], 20, "Elite");
	format(ClanInfo[clans][Clan_Rank5], 20, "Hero");
	format(ClanInfo[clans][Clan_Rank6], 20, "Legend");
	format(ClanInfo[clans][Clan_Rank7], 20, "Conqueror");
	format(ClanInfo[clans][Clan_Rank8], 20, "Crown");
	format(ClanInfo[clans][Clan_Rank9], 20, "Co Leader");
	format(ClanInfo[clans][Clan_Rank10], 20, "Leader");
	ClanInfo[clans][Clan_Wallet] = 10000;
	ClanInfo[clans][Clan_Level] = 1;
	ClanInfo[clans][Clan_Kills] = 0;
	ClanInfo[clans][Clan_Deaths] = 0;
	ClanInfo[clans][Clan_XP] = 0;

	ClanInfo[clans][Clan_Addlevel] = 10;
	ClanInfo[clans][Clan_Warlevel] = 10;
	ClanInfo[clans][Clan_Setlevel] = 10;
	ClanInfo[clans][Clan_Baseperk] = 0;
	ClanInfo[clans][Clan_Team] = 0;
	ClanInfo[clans][Clan_Skin] = 0;

	pClan[playerid] = ClanInfo[clans][Clan_Id];
	pClanRank[playerid] = 10;

	AddClanLog(playerid, "Created the clan");
	Text_Send(playerid, $CLAN_CREATED);
	return 1;
}

//Main clan core

CreateClan(playerid, const clan_name[], const clan_tag[]) {
	if (GetPlayerScore(playerid) < 10000 || GetPlayerCash(playerid) < 500000) {
		return Text_Send(playerid, $CLIENT_174x);
	}

	if (IsPlayerInAnyClan(playerid)) {
		return Text_Send(playerid, $CLIENT_175x);
	}

	if (IsValidClan(clan_name)) {
		return Text_Send(playerid, $CLIENT_176x);
	}

	if (IsValidClanTag(clan_tag)) {
		return Text_Send(playerid, $CLIENT_177x);
	}

	if (clans >= MAX_CLANS - 1) {
		return Text_Send(playerid, $CLIENT_178x);
	}

	GivePlayerCash(playerid, -500000);

	new query[600];

	mysql_format(Database, query, sizeof(query), "INSERT INTO `ClansData` (`ClanName`, `ClanTag`, `ClanMotd`, `ClanWallet`, `ClanKills`, `ClanDeaths`, `ClanPoints`, `Rank1`, `Rank2`, `Rank3`, `Rank4`, `Rank5`, `Rank6`, `Rank7`, `Rank8`, `Rank9`, `Rank10`, `ClanLevel`, `ClanSkin`) \
	VALUES ('%e', '[%e]', 'Clan message', '10000', '0', '0', '0', 'Recruit', 'Novice', 'Member', 'Elite', 'Hero', 'Legend', 'Conqueror', 'Crown', 'Co Leader', 'Leader', '0', '0')", clan_name, clan_tag);

	mysql_tquery(Database, query, "InitializeClan", "iss", playerid, clan_name, clan_tag);
	return 1;
}

IsPlayerInAnyClan(playerid) {
	if (pClan[playerid] != -1) return 1;
	return 0;
}

IsValidClan(const clan_name[]) {
	new is_valid = 0;
	for (new i = 0; i < sizeof(ClanInfo) - 1; i++) {
		if (ClanInfo[i][Clan_Id] != -1 && !strcmp(ClanInfo[i][Clan_Name], clan_name, true) &&
			!isnull(clan_name) && !isnull(ClanInfo[i][Clan_Name])) {
			is_valid = 1;
			break;
		}
	}

	return is_valid;
}

IsValidClanTag(const clan_tag[]) {
	new is_valid = 0;
	for (new i = 0; i < sizeof(ClanInfo) - 1; i++) {
		if (ClanInfo[i][Clan_Id] != -1 && !strcmp(ClanInfo[i][Clan_Tag], clan_tag, true) &&
			!isnull(clan_tag) && !isnull(ClanInfo[i][Clan_Tag])) {
			is_valid = 1;
			break;
		}
	}

	return is_valid;
}

GetPlayerClan(playerid) {
	new clan_name[35];

	if (pClan[playerid] != -1) {
		for (new i = 0; i < sizeof(ClanInfo) - 1; i++) {
			if (pClan[playerid] == ClanInfo[i][Clan_Id] && ClanInfo[i][Clan_Id] != -1) {
				format(clan_name, 35, ClanInfo[i][Clan_Name]);
				break;
			}
		}
	}

	return clan_name;
}

GetPlayerClanRank(playerid) {
	return pClanRank[playerid];
}

GetPlayerClanRankName(playerid) {
	new player_clan_rank[20];
	if (pClan[playerid] != -1) {	
		for (new i = 0; i < sizeof(ClanInfo) - 1; i++) {
			if (ClanInfo[i][Clan_Id] != -1 && pClan[playerid] == ClanInfo[i][Clan_Id]) {
				switch (pClanRank[playerid]) {
					case 1: format(player_clan_rank, 20, ClanInfo[i][Clan_Rank1]);
					case 2: format(player_clan_rank, 20, ClanInfo[i][Clan_Rank2]);
					case 3: format(player_clan_rank, 20, ClanInfo[i][Clan_Rank3]);
					case 4: format(player_clan_rank, 20, ClanInfo[i][Clan_Rank4]);
					case 5: format(player_clan_rank, 20, ClanInfo[i][Clan_Rank5]);
					case 6: format(player_clan_rank, 20, ClanInfo[i][Clan_Rank6]);
					case 7: format(player_clan_rank, 20, ClanInfo[i][Clan_Rank7]);
					case 8: format(player_clan_rank, 20, ClanInfo[i][Clan_Rank8]);
					case 9: format(player_clan_rank, 20, ClanInfo[i][Clan_Rank9]);
					case 10: format(player_clan_rank, 20, ClanInfo[i][Clan_Rank10]);
				}

				break;
			}
		}
	}

	return player_clan_rank;
}

GetClanRankName(const clan_name[], rankid) {
	new clan_rank[20];

	for (new i = 0; i < sizeof(ClanInfo) - 1; i++) {
		if (ClanInfo[i][Clan_Id] != -1 && !strcmp(ClanInfo[i][Clan_Name], clan_name, true) && !isnull(ClanInfo[i][Clan_Name])) {
			switch (rankid) {
				case 1: format(clan_rank, 20, ClanInfo[i][Clan_Rank1]);
				case 2: format(clan_rank, 20, ClanInfo[i][Clan_Rank2]);
				case 3: format(clan_rank, 20, ClanInfo[i][Clan_Rank3]);
				case 4: format(clan_rank, 20, ClanInfo[i][Clan_Rank4]);
				case 5: format(clan_rank, 20, ClanInfo[i][Clan_Rank5]);
				case 6: format(clan_rank, 20, ClanInfo[i][Clan_Rank6]);
				case 7: format(clan_rank, 20, ClanInfo[i][Clan_Rank7]);
				case 8: format(clan_rank, 20, ClanInfo[i][Clan_Rank8]);
				case 9: format(clan_rank, 20, ClanInfo[i][Clan_Rank9]);
				case 10: format(clan_rank, 20, ClanInfo[i][Clan_Rank10]);
			}

			break;
		}
	}

	return clan_rank;
}

SetClanName(const clan_name[], const newName[]) {
	for (new i = 0; i < sizeof(ClanInfo) - 1; i++) {
		if (ClanInfo[i][Clan_Id] != -1 && !strcmp(ClanInfo[i][Clan_Name], clan_name, true) && !isnull(ClanInfo[i][Clan_Name])) {
			format(ClanInfo[i][Clan_Name], 35, newName);
			break;
		}
	}

	return 0;
}

SetClanTag(const clan_name[], const new_tag[]) {
	for (new i = 0; i < sizeof(ClanInfo) - 1; i++) {
		if (ClanInfo[i][Clan_Id] != -1 && !strcmp(ClanInfo[i][Clan_Name], clan_name, true) && !isnull(ClanInfo[i][Clan_Name])) {
			new tag[7];
			format(tag, 7, "[%s]", new_tag);
			format(ClanInfo[i][Clan_Tag], 7, tag);
			break;
		}
	}

	return 0;
}

SetClanRankName(const clan_name[], rankid, const new_rank[]) {
	for (new i = 0; i < sizeof(ClanInfo) - 1; i++) {
		if (ClanInfo[i][Clan_Id] != -1 && !strcmp(ClanInfo[i][Clan_Name], clan_name, true) && !isnull(ClanInfo[i][Clan_Name])) {
			switch (rankid) {
				case 1: format(ClanInfo[i][Clan_Rank1], 20, new_rank);
				case 2: format(ClanInfo[i][Clan_Rank2], 20, new_rank);
				case 3: format(ClanInfo[i][Clan_Rank3], 20, new_rank);
				case 4: format(ClanInfo[i][Clan_Rank4], 20, new_rank);
				case 5: format(ClanInfo[i][Clan_Rank5], 20, new_rank);
				case 6: format(ClanInfo[i][Clan_Rank6], 20, new_rank);
				case 7: format(ClanInfo[i][Clan_Rank7], 20, new_rank);
				case 8: format(ClanInfo[i][Clan_Rank8], 20, new_rank);
				case 9: format(ClanInfo[i][Clan_Rank9], 20, new_rank);
				case 10: format(ClanInfo[i][Clan_Rank10], 20, new_rank);
			}

			break;
		}
	}

	return 0;
}

GetClanMotd(const clan_name[]) {
	new clan_motd[60];

	for (new i = 0; i < sizeof(ClanInfo) - 1; i++) {
		if (ClanInfo[i][Clan_Id] != -1 && !strcmp(ClanInfo[i][Clan_Name], clan_name, true) && !isnull(ClanInfo[i][Clan_Name])) {
			format(clan_motd, 60, ClanInfo[i][Clan_Motd]);
			break;
		}
	}

	return clan_motd;
}

SetClanMotd(const clan_name[], const title[]) {
	for (new i = 0; i < sizeof(ClanInfo) - 1; i++) {
		if (ClanInfo[i][Clan_Id] != -1 && !strcmp(ClanInfo[i][Clan_Name], clan_name, true) && !isnull(ClanInfo[i][Clan_Name])) {
			format(ClanInfo[i][Clan_Motd], 60, title);
			break;
		}
	}
	return 1;
}

GetClanWeapon(const clan_name[]) {
	for (new i = 0; i < sizeof(ClanInfo) - 1; i++) {
		if (ClanInfo[i][Clan_Id] != -1 && !strcmp(ClanInfo[i][Clan_Name], clan_name, true) && !isnull(ClanInfo[i][Clan_Name])) {
			return ClanInfo[i][Clan_Weapon];
		}
	}
	return 0;
}

GetClanAddPerms(const clan_name[]) {
	for (new i = 0; i < sizeof(ClanInfo) - 1; i++) {
		if (ClanInfo[i][Clan_Id] != -1 && !strcmp(ClanInfo[i][Clan_Name], clan_name, true) && !isnull(ClanInfo[i][Clan_Name])) {
			return ClanInfo[i][Clan_Addlevel];
		}
	}
	return 0;
}

GetClanWarPerms(const clan_name[]) {
	for (new i = 0; i < sizeof(ClanInfo) - 1; i++) {
		if (ClanInfo[i][Clan_Id] != -1 && !strcmp(ClanInfo[i][Clan_Name], clan_name, true) && !isnull(ClanInfo[i][Clan_Name])) {
			return ClanInfo[i][Clan_Warlevel];
		}
	}
	return 0;
}

GetClanSetPerms(const clan_name[]) {
	for (new i = 0; i < sizeof(ClanInfo) - 1; i++) {
		if (ClanInfo[i][Clan_Id] != -1 && !strcmp(ClanInfo[i][Clan_Name], clan_name, true) && !isnull(ClanInfo[i][Clan_Name])) {
			return ClanInfo[i][Clan_Setlevel];
		}
	}
	return 0;
}

GetClanTeam(const clan_name[]) {
	for (new i = 0; i < sizeof(ClanInfo) - 1; i++) {
		if (ClanInfo[i][Clan_Id] != -1 && !strcmp(ClanInfo[i][Clan_Name], clan_name, true) && !isnull(ClanInfo[i][Clan_Name])) {
			return ClanInfo[i][Clan_Team];
		}
	}
	return 0;
}

GetClanSkin(const clan_name[]) {
	for (new i = 0; i < sizeof(ClanInfo) - 1; i++) {
		if (ClanInfo[i][Clan_Id] != -1 && !strcmp(ClanInfo[i][Clan_Name], clan_name, true) && !isnull(ClanInfo[i][Clan_Name])) {
			return ClanInfo[i][Clan_Skin];
		}
	}
	return 0;
}

SetClanSkin(const clan_name[], amount) {
	for (new i = 0; i < sizeof(ClanInfo) - 1; i++) {
		if (ClanInfo[i][Clan_Id] != -1 && !strcmp(ClanInfo[i][Clan_Name], clan_name, true) && !isnull(ClanInfo[i][Clan_Name])) {
			ClanInfo[i][Clan_Skin] = amount;
			break;
		}
	}
	return 1;
}

SetClanTeam(const clan_name[], amount) {
	for (new i = 0; i < sizeof(ClanInfo) - 1; i++) {
		if (ClanInfo[i][Clan_Id] != -1 && !strcmp(ClanInfo[i][Clan_Name], clan_name, true) && !isnull(ClanInfo[i][Clan_Name])) {
			ClanInfo[i][Clan_Team] = amount;
			break;
		}
	}
	return 1;
}

SetClanWeapon(const clan_name[], amount) {
	for (new i = 0; i < sizeof(ClanInfo) - 1; i++) {
		if (ClanInfo[i][Clan_Id] != -1 && !strcmp(ClanInfo[i][Clan_Name], clan_name, true) && !isnull(ClanInfo[i][Clan_Name])) {
			ClanInfo[i][Clan_Weapon] = amount;
			break;
		}
	}
	return 1;
}

SetClanAddPerms(const clan_name[], amount) {
	for (new i = 0; i < sizeof(ClanInfo) - 1; i++) {
		if (ClanInfo[i][Clan_Id] != -1 && !strcmp(ClanInfo[i][Clan_Name], clan_name, true) && !isnull(ClanInfo[i][Clan_Name])) {
			ClanInfo[i][Clan_Addlevel] = amount;
			break;
		}
	}
	return 1;
}

SetClanWarPerms(const clan_name[], amount) {
	for (new i = 0; i < sizeof(ClanInfo) - 1; i++) {
		if (ClanInfo[i][Clan_Id] != -1 && !strcmp(ClanInfo[i][Clan_Name], clan_name, true) && !isnull(ClanInfo[i][Clan_Name])) {
			ClanInfo[i][Clan_Warlevel] = amount;
			break;
		}
	}
	return 1;
}

SetClanSetPerms(const clan_name[], amount) {
	for (new i = 0; i < sizeof(ClanInfo) - 1; i++) {
		if (ClanInfo[i][Clan_Id] != -1 && !strcmp(ClanInfo[i][Clan_Name], clan_name, true) && !isnull(ClanInfo[i][Clan_Name])) {
			ClanInfo[i][Clan_Setlevel] = amount;
			break;
		}
	}
	return 1;
}

GetClanName(const clan_tag[]) {
	new clan_name[35];

	for (new i = 0; i < sizeof(ClanInfo) - 1; i++) {
		if (ClanInfo[i][Clan_Id] != -1 && !strcmp(ClanInfo[i][Clan_Tag], clan_tag, true) && !isnull(ClanInfo[i][Clan_Tag])) {
			format(clan_name, 35, ClanInfo[i][Clan_Name]);
			break;
		}
	}
	return clan_name;
}

GetClanTag(const clan_name[]) {
	new clan_tag[7];

	for (new i = 0; i < sizeof(ClanInfo) - 1; i++) {
		if (ClanInfo[i][Clan_Id] != -1 && !strcmp(ClanInfo[i][Clan_Name], clan_name, true) && !isnull(ClanInfo[i][Clan_Name])) {
			format(clan_tag, 7, ClanInfo[i][Clan_Tag]);
			break;
		}
	}
	return clan_tag;
}

GetClanXP(const clan_name[]) {
	for (new i = 0; i < sizeof(ClanInfo) - 1; i++) {
		if (ClanInfo[i][Clan_Id] != -1 && !strcmp(ClanInfo[i][Clan_Name], clan_name, true) && !isnull(ClanInfo[i][Clan_Name])) {
			return ClanInfo[i][Clan_XP];
		}
	}
	return 0;
}

AddClanXP(const clan_name[], amount) {
	for (new i = 0; i < sizeof(ClanInfo) - 1; i++) {
		if (ClanInfo[i][Clan_Id] != -1 && !strcmp(ClanInfo[i][Clan_Name], clan_name, true) && !isnull(ClanInfo[i][Clan_Name])) {
			ClanInfo[i][Clan_XP] += amount;
			if (ClanInfo[i][Clan_XP] < 0) ClanInfo[i][Clan_XP] = 0;
			for (new x = sizeof(ClanRanks) - 1; x > -1; x--) {
				if (ClanInfo[i][Clan_XP] >= ClanRanks[x][C_LevelXP])
				{
					ClanInfo[i][Clan_Level] = x;
					break;
				}
			}			
			break;
		}
	}    
	return 1;
}

GetClanLevel(const clan_name[]) {
	for (new i = 0; i < sizeof(ClanInfo) - 1; i++) {
		if (ClanInfo[i][Clan_Id] != -1 && !strcmp(ClanInfo[i][Clan_Name], clan_name, true) && !isnull(ClanInfo[i][Clan_Name])) {
			if (ClanInfo[i][Clan_XP] < 0) ClanInfo[i][Clan_XP] = 0;
			for (new x = sizeof(ClanRanks) - 1; x > -1; x--) {
				if (ClanInfo[i][Clan_XP] >= ClanRanks[x][C_LevelXP])
				{
					ClanInfo[i][Clan_Level] = x;
					return ClanInfo[i][Clan_Level];
				}
			}
		}
	}
	
	return 0;
}

GetClanWallet(const clan_name[]) {
	for (new i = 0; i < sizeof(ClanInfo) - 1; i++) {
		if (ClanInfo[i][Clan_Id] != -1 && !strcmp(ClanInfo[i][Clan_Name], clan_name, true) && !isnull(ClanInfo[i][Clan_Name])) {
			return ClanInfo[i][Clan_Wallet];
		}
	}
	return 0;
}

AddClanWallet(const clan_name[], amount) {
	for (new i = 0; i < sizeof(ClanInfo) - 1; i++) {
		if (ClanInfo[i][Clan_Id] != -1 && !strcmp(ClanInfo[i][Clan_Name], clan_name, true) && !isnull(ClanInfo[i][Clan_Name])) {
			return ClanInfo[i][Clan_Wallet] += amount;
		}
	}
	return 0;
}

GetClanKills(const clan_name[]) {
	for (new i = 0; i < sizeof(ClanInfo) - 1; i++) {
		if (ClanInfo[i][Clan_Id] != -1 && !strcmp(ClanInfo[i][Clan_Name], clan_name, true) && !isnull(ClanInfo[i][Clan_Name])) {
			return ClanInfo[i][Clan_Kills];
		}
	}
	return 0;
}

AddClanKills(const clan_name[], amount) {
	for (new i = 0; i < sizeof(ClanInfo) - 1; i++) {
		if (ClanInfo[i][Clan_Id] != -1 && !strcmp(ClanInfo[i][Clan_Name], clan_name, true) && !isnull(ClanInfo[i][Clan_Name])) {
			ClanInfo[i][Clan_Kills] += amount;
		}
	}
	return 0;
}

GetClanDeaths(const clan_name[]) {
	for (new i = 0; i < sizeof(ClanInfo) - 1; i++) {
		if (ClanInfo[i][Clan_Id] != -1 && !strcmp(ClanInfo[i][Clan_Name], clan_name, true) && !isnull(ClanInfo[i][Clan_Name])) {
			return ClanInfo[i][Clan_Deaths];
		}
	}
	return 0;
}

AddClanDeaths(const clan_name[], amount) {
	for (new i = 0; i < sizeof(ClanInfo) - 1; i++) {
		if (ClanInfo[i][Clan_Id] != -1 && !strcmp(ClanInfo[i][Clan_Name], clan_name, true) && !isnull(ClanInfo[i][Clan_Name])) {
			ClanInfo[i][Clan_Deaths] += amount;
		}
	}
	return 0;
}

AddClanLog(playerid, const action[]) {
	if (IsPlayerInAnyClan(playerid)) {
		new query[600];
		mysql_format(Database, query, sizeof(query), 
			"INSERT INTO `ClanLog` (`cID`, `Member`, `Rank`, `Action`, `Date`) \
			VALUES('%d', '%e', '%d', '%e', '%d')", pClan[playerid], PlayerInfo[playerid][PlayerName],
				GetPlayerClanRank(playerid), action, gettime());
		mysql_tquery(Database, query);
	}
	return 1;
}

//Clan war

SetupClanwar(playerid) {
	if (PlayerInfo[playerid][pClanWarSpec] == 0) {
		if (cwInfo[cw_started] == 1) {
			KillTimer(DelayerTimer[playerid]);
			DelayerTimer[playerid] = SetTimerEx("InitPlayer", GetPlayerPing(playerid) + 200, false, "i", playerid);
			TogglePlayerControllable(playerid, false);
		}
		else
		{
			TogglePlayerControllable(playerid, false);
		}

		Text_Send(playerid, $CLANWAR_INIT);

		GivePlayerWeapon(playerid, cwInfo[cw_weap1], 9999);
		GivePlayerWeapon(playerid, cwInfo[cw_weap2], 9999);
		GivePlayerWeapon(playerid, cwInfo[cw_weap3], 9999);
		GivePlayerWeapon(playerid, cwInfo[cw_weap4], 9999);

		if (Iter_Contains(CWCLAN1, playerid)) {
			if (cwInfo[cw_skin1] != 0)
				SetPlayerSkin(playerid, cwInfo[cw_skin1]);
			switch (cwInfo[cw_map]) {
				case 0:
				{
					SetPlayerPosition(playerid, "", CW_WORLD, 0, 1358.6832,2185.3911,11.0156,147.3334);
				}
				case 1:
				{
					SetPlayerPosition(playerid, "", CW_WORLD, 10, -1018.2189,1056.7441,1342.9358,53.6926);
				}
				case 2:
				{
					SetPlayerPosition(playerid, "", CW_WORLD, 3, 298.0534,176.0552,1007.1719,91.2696);
				}
				case 3:
				{
					SetPlayerPosition(playerid, "", CW_WORLD, 1, 2467.0950, -2819.3567, 57.2000, 183.0627);
				}
				case 4:
				{
					SetPlayerPosition(playerid, "", CW_WORLD, 15, 2191.9275,-1180.8783,1033.7896,90.9186);
				}
			}

			SetPlayerColor(playerid, 0xECECECFF);
			return 1;
		} else {
			if (cwInfo[cw_skin2] != 0)
				SetPlayerSkin(playerid, cwInfo[cw_skin2]);
			switch (cwInfo[cw_map]) {
				case 0: {
					SetPlayerPosition(playerid, "", CW_WORLD, 0, 1317.3516,2120.9395,11.0156,327.8713);
				}
				case 1: {
					SetPlayerPosition(playerid, "", CW_WORLD, 10, -1053.4242,1087.2908,1343.0204,230.7042);
				}
				case 2: {
					SetPlayerPosition(playerid, "", CW_WORLD, 3, 238.5584,178.5376,1003.0300,267.9679);
				}
				case 3: {
					SetPlayerPosition(playerid, "", CW_WORLD, 1, 2469.7866, -2981.1807, 57.1900, 3.2077);
				}
				case 4: {
					SetPlayerPosition(playerid, "", CW_WORLD, 15, 2222.2390,-1151.7870,1025.7969,1.3280);
				}
			}
			SetPlayerColor(playerid, 0xECECECFF);
		}
	}
	else
	{
		foreach (new x: Player) {
			if (Iter_Contains(CWCLAN1, x) || Iter_Contains(CWCLAN2, x))
			{
				if (PlayerInfo[x][pClanWarSpec] == 0 && x != playerid)
				{
					TogglePlayerSpectating(playerid, true);
					PlayerSpectatePlayer(playerid, x);
					PlayerInfo[playerid][pClanWarSpecId] = x;
				}
			}
		}
	}
	return 1;
}

//Hook some stuff..?

hook OnGameModeInit() {
	clanskinlist = LoadModelSelectionMenu("skins.txt"); //Load the clan skin menu...
	//Why not create a separate file for clan skins?

	//Load them from database..
	mysql_tquery(Database, "SELECT * FROM `ClansData`", "LoadClans");
	return 1;
}

hook OnGameModeExit() {
	//Make sure to update clans data if the server shuts down
	for (new i = 0; i < sizeof(ClanInfo) - 1; i++) {
		if (ClanInfo[i][Clan_Id] != -1) {	
			new query[800];

			mysql_format(Database, query, sizeof(query), "UPDATE `ClansData` SET ClanName = '%e', ClanTag = '%e', ClanMotd = '%e', Rank1 = '%e', Rank2 = '%e', Rank3 = '%e', Rank4 = '%e', Rank5 = '%e', Rank6 = '%e', Rank7 = '%e', Rank8 = '%e', Rank9 = '%e', Rank10 = '%e', ClanWallet = '%d', ClanKills = '%d', ClanDeaths = '%d', ClanPoints = '%d', ClanLevel = '%d', ClanWeap = '%d', ClanSkin = '%d',\
			InviteClanLevel = '%d', ClanWarLevel = '%d', ClanPermsLevel = '%d', BasePurchaseTime = '%d', PreferredTeam = '%d' WHERE ClanId = '%d'",
			ClanInfo[i][Clan_Name], ClanInfo[i][Clan_Tag], ClanInfo[i][Clan_Motd], ClanInfo[i][Clan_Rank1], ClanInfo[i][Clan_Rank2], ClanInfo[i][Clan_Rank3], ClanInfo[i][Clan_Rank4], ClanInfo[i][Clan_Rank5], ClanInfo[i][Clan_Rank6],
			ClanInfo[i][Clan_Rank7], ClanInfo[i][Clan_Rank8], ClanInfo[i][Clan_Rank9], ClanInfo[i][Clan_Rank10],
			ClanInfo[i][Clan_Wallet], ClanInfo[i][Clan_Kills], ClanInfo[i][Clan_Deaths], ClanInfo[i][Clan_XP], ClanInfo[i][Clan_Level], ClanInfo[i][Clan_Weapon], ClanInfo[i][Clan_Skin],
			ClanInfo[i][Clan_Addlevel], ClanInfo[i][Clan_Warlevel], ClanInfo[i][Clan_Setlevel], ClanInfo[i][Clan_Baseperk], ClanInfo[i][Clan_Team], ClanInfo[i][Clan_Id]);
			mysql_tquery(Database, query);
		}
	}
	return 1;
}

//....
hook OnPlayerConnect(playerid) {
	//Reset variables
	PlayerInfo[playerid][pIsInvitedToClan] = 0;
	pClan[playerid] = -1;
	pClanRank[playerid] = 0;
	return 1;
}

hook OnPlayerDisconnect(playerid, reason) {
	foreach (new x: Player) {
		if (PlayerInfo[x][pClanWarSpec] == 1 && x != playerid) {
			if (PlayerInfo[x][pClanWarSpecId] == playerid) {
				Text_Send(x, $SPEC_PLEFT);

				PlayerInfo[x][pClanWarSpecId] = -1;
				PlayerInfo[x][pClanWarSpec] = 1;
						
				TogglePlayerSpectating(x, false);
				SpawnPlayer(x);
			}
		}
	}
	if (Iter_Contains(CWCLAN1, playerid)) {
		Iter_Remove(CWCLAN1, playerid);
		if (Iter_Count(CWCLAN1) == 1 || !Iter_Count(CWCLAN1)) {
			if (cwInfo[cw_started]) {
				cwInfo[cw_ready] = 0;
				cwInfo[cw_started] = 0;
				foreach (new x: CWCLAN1) Iter_SafeRemove(CWCLAN1, x, x), SpawnPlayer(x);
				foreach (new x: CWCLAN2) Iter_Remove(CWCLAN2, x), SpawnPlayer(x);
			}
		}
	}
	
	if (Iter_Contains(CWCLAN2, playerid)) {
		Iter_Remove(CWCLAN2, playerid);
		if (Iter_Count(CWCLAN2) == 1 || !Iter_Count(CWCLAN2)) {
			if (cwInfo[cw_started]) {
				cwInfo[cw_ready] = 0;
				cwInfo[cw_started] = 0;
				foreach (new x: CWCLAN1) Iter_SafeRemove(CWCLAN1, x, x), SpawnPlayer(x);
				foreach (new x: CWCLAN2) Iter_Remove(CWCLAN2, x), SpawnPlayer(x);
			}
		}
	}
	format(PlayerInfo[playerid][pClan_Name], 35, "");
	return 1;
}

hook OnPlayerDeath(playerid, killerid, reason) {
	if (killerid == playerid || killerid == INVALID_PLAYER_ID) return false;
	//Code for handling clan kills..
	////

	if (IsPlayerInAnyClan(playerid) && GetPlayerVirtualWorld(playerid) == 0) {
		AddClanDeaths(GetPlayerClan(playerid), 1);
		PlayerInfo[playerid][pClanDeaths] ++;
	}

	if (IsPlayerInAnyClan(killerid) && GetPlayerVirtualWorld(killerid) == 0) {
		if (pClan[killerid] != pClan[playerid]) {
			AddClanXP(GetPlayerClan(killerid), 1);
			AddClanKills(GetPlayerClan(killerid), 1);
			PlayerInfo[killerid][pClanKills] ++;
		}	
	}


	if (!cwInfo[cw_started]) return false; //Next code for clan wars only

	if (!Iter_Contains(CWCLAN1, playerid) || !Iter_Contains(CWCLAN2, playerid)) {
		PlayerInfo[playerid][pClanWarSpec] = 1;

		if (Iter_Count(CWCLAN1) <= 0 && Iter_Count(CWCLAN2) <= 0) {
			foreach (new x: CWCLAN1) {
				PlayerInfo[x][pClanWarSpec] = 0;

				if (!IsPlayerSpawned(x))
				{
					TogglePlayerSpectating(x, false);
				}
				SpawnPlayer(x);
				Text_Send(x, $CLIENT_396x);
			}
			
			foreach (new x: CWCLAN2) {
				PlayerInfo[x][pClanWarSpec] = 0;

				if (!IsPlayerSpawned(x))
				{
					TogglePlayerSpectating(x, false);
				}
				SpawnPlayer(x);
				Text_Send(x, $CLIENT_396x);
			}

			return 1;
		}
		else if (Iter_Count(CWCLAN1) <= 0 || Iter_Count(CWCLAN2) <= 0) {
			if (cwInfo[cw_rounds] == cwInfo[cw_maxrounds]) {
				if (Iter_Count(CWCLAN2) > Iter_Count(CWCLAN1)) {
					AddClanXP(cwInfo[cw_clan2], 5000);
					AddClanXP(cwInfo[cw_clan1], -5000);

					Text_Send(@pVerified, $NEWSERVER_38x, cwInfo[cw_clan2]);

					cwInfo[cw_ready] = 0;
					cwInfo[cw_started] = 0;
					
					foreach (new x: CWCLAN1)
					{
						Iter_SafeRemove(CWCLAN1, x, x);
						PlayerInfo[x][pClanWarSpec] = 0;

						if (GetPlayerState(x) == PLAYER_STATE_SPECTATING) {
							TogglePlayerSpectating(x, false);
						}
						SpawnPlayer(x);
					}
					
					foreach (new x: CWCLAN2)
					{
						Iter_Remove(CWCLAN2, x);
						PlayerInfo[x][pClanWarSpec] = 0;

						if (GetPlayerState(x) == PLAYER_STATE_SPECTATING) {
							TogglePlayerSpectating(x, false);
						}
						SpawnPlayer(x);
					}
					
					Iter_Clear(CWCLAN1);
					Iter_Clear(CWCLAN2);
				}
				else
				{
					AddClanXP(cwInfo[cw_clan1], 5000);
					AddClanXP(cwInfo[cw_clan2], -5000);

					Text_Send(@pVerified, $NEWSERVER_38x, cwInfo[cw_clan1]);
					
					cwInfo[cw_ready] = 0;
					cwInfo[cw_started] = 0;

					foreach (new x: CWCLAN1)
					{
						Iter_SafeRemove(CWCLAN1, x, x);
						PlayerInfo[x][pClanWarSpec] = 0;

						if (GetPlayerState(x) == PLAYER_STATE_SPECTATING) {
							TogglePlayerSpectating(x, false);
						}
							
						SpawnPlayer(x);
					}
					
					foreach (new x: CWCLAN2)
					{
						Iter_Remove(CWCLAN2, x);
						PlayerInfo[x][pClanWarSpec] = 0;

						if (GetPlayerState(x) == PLAYER_STATE_SPECTATING) {
							TogglePlayerSpectating(x, false);
						}

						SpawnPlayer(x);
					}
					
					Iter_Clear(CWCLAN1);
					Iter_Clear(CWCLAN2);
				}						
			}	
			else
			{
				if (Iter_Count(CWCLAN2) > Iter_Count(CWCLAN1)) {
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

						if (GetPlayerState(x) == PLAYER_STATE_SPECTATING) {
							TogglePlayerSpectating(x, false);
						}

						SpawnPlayer(x);
					}
					
					foreach (new x: CWCLAN2)
					{
						PlayerInfo[x][pClanWarSpec] = 0;

						if (GetPlayerState(x) == PLAYER_STATE_SPECTATING) {
							TogglePlayerSpectating(x, false);
						}

						SpawnPlayer(x);
					}
				}	
				if (Iter_Count(CWCLAN1) > Iter_Count(CWCLAN2)) {
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

						if (GetPlayerState(x) == PLAYER_STATE_SPECTATING) {
							TogglePlayerSpectating(x, false);
						}
					}
					
					foreach (new x: CWCLAN2)
					{
						PlayerInfo[x][pClanWarSpec] = 0;

						if (GetPlayerState(x) == PLAYER_STATE_SPECTATING) {
							TogglePlayerSpectating(x, false);
						}
					}
				}						
			}
		}	
	}
	return 1;
}

//Clan skin selection menu..
hook OnPlayerModelSelection(playerid, response, listid, modelid) {
	if (listid == clanskinlist) {
		if (!response) return 1;
		SetClanSkin(GetPlayerClan(playerid), modelid);
		AddClanXP(GetPlayerClan(playerid), -5000);

		foreach(new i: Player) if (pClan[i] == pClan[playerid]) Text_Send(i, $CLIENT_412x, PlayerInfo[playerid][PlayerName], modelid);
		Text_Send(playerid, $CLIENT_300x);
	}
	return 1;
}

//Don't forget to show the clan's motd :)
hook EndFirstSpawn(playerid) {
	if (IsPlayerInAnyClan(playerid)) {
		Text_Send(playerid, $CLAN_MOTD, GetClanMotd(GetPlayerClan(playerid)));
	}
}

//Make sure to update clans
hook SaveAllStats() {
	for (new i = 0; i < sizeof(ClanInfo) - 1; i++) {
		if (ClanInfo[i][Clan_Id] != -1) {
			if (ClanInfo[i][Clan_Baseperk]) {
				if (gettime() >= ClanInfo[i][Clan_Baseperk]) {
					ClanInfo[i][Clan_Baseperk] = 0;
					SetClanTeam(ClanInfo[i][Clan_Name], TERRORIST);
					Text_Send(@pVerified, $SERVER_18x);
				}
			}

			new query[800];

			mysql_format(Database, query, sizeof(query), "UPDATE `ClansData` SET ClanName = '%e', ClanTag = '%e', ClanMotd = '%e', Rank1 = '%e', Rank2 = '%e', Rank3 = '%e', Rank4 = '%e', Rank5 = '%e', Rank6 = '%e', Rank7 = '%e', Rank8 = '%e', Rank9 = '%e', Rank10 = '%e', ClanWallet = '%d', ClanKills = '%d', ClanDeaths = '%d', ClanPoints = '%d', ClanLevel = '%d', ClanWeap = '%d', ClanSkin = '%d',\
			InviteClanLevel = '%d', ClanWarLevel = '%d', ClanPermsLevel = '%d', BasePurchaseTime = '%d', PreferredTeam = '%d' WHERE ClanId = '%d'",
			ClanInfo[i][Clan_Name], ClanInfo[i][Clan_Tag], ClanInfo[i][Clan_Motd], ClanInfo[i][Clan_Rank1], ClanInfo[i][Clan_Rank2], ClanInfo[i][Clan_Rank3], ClanInfo[i][Clan_Rank4], ClanInfo[i][Clan_Rank5], ClanInfo[i][Clan_Rank6],
			ClanInfo[i][Clan_Rank7], ClanInfo[i][Clan_Rank8], ClanInfo[i][Clan_Rank9], ClanInfo[i][Clan_Rank10],
			ClanInfo[i][Clan_Wallet], ClanInfo[i][Clan_Kills], ClanInfo[i][Clan_Deaths], ClanInfo[i][Clan_XP], ClanInfo[i][Clan_Level], ClanInfo[i][Clan_Weapon], ClanInfo[i][Clan_Skin],
			ClanInfo[i][Clan_Addlevel], ClanInfo[i][Clan_Warlevel], ClanInfo[i][Clan_Setlevel], ClanInfo[i][Clan_Baseperk], ClanInfo[i][Clan_Team], ClanInfo[i][Clan_Id]);
			mysql_tquery(Database, query);
		}    
	}
}

//Commands for handling the clans

alias:ccreate("createclan");
CMD:ccreate(playerid, params[]) {
	new clan_name[35], clan_tag[7];

	if (!pVerified[playerid]) return 1;
	if (sscanf(params, "s[7]s[31]", clan_tag, clan_name)) return ShowSyntax(playerid, "/ccreate [clan tag without brackets] [clan name]");
	if (strlen(clan_name) > 30 || strlen(clan_name) < 5) return Text_Send(playerid, $CLIENT_498x);
	if (strlen(clan_tag) > 4 || strlen(clan_tag) < 1) return Text_Send(playerid, $CLIENT_499x);
	if (!IsValidText(clan_name) || !IsValidText(clan_tag)) return Text_Send(playerid, $CLIENT_500x);
	
	CreateClan(playerid, clan_name, clan_tag);
	printf("%s[%d] attempted to add a clan: %s[%s]", PlayerInfo[playerid][PlayerName], playerid, clan_name, clan_tag);
	return 1;
}

//-------------------------------------------------------------------------------------------------------

CMD:clan(playerid) {
	if (!IsPlayerInAnyClan(playerid)) return Text_Send(playerid, $CLIENT_358x);
	if (GetPlayerClanRank(playerid) < 10) return Text_Send(playerid, $CLIENT_362x);
	if (!IsValidClan(GetPlayerClan(playerid))) return Text_Send(playerid, $CLIENT_420x);

	new clan_message[900];
	format(clan_message, sizeof(clan_message),
	""DEEPSKYBLUE"Clan Moto\t"CYAN"%s\n\
	"DEEPSKYBLUE"Clan Rank 1\t"CYAN"%s\n\
	"DEEPSKYBLUE"Clan Rank 2\t"CYAN"%s\n\
	"DEEPSKYBLUE"Clan Rank 3\t"CYAN"%s\n\
	"DEEPSKYBLUE"Clan Rank 4\t"CYAN"%s\n\
	"DEEPSKYBLUE"Clan Rank 5\t"CYAN"%s\n\
	"DEEPSKYBLUE"Clan Rank 6\t"CYAN"%s\n\
	"DEEPSKYBLUE"Clan Rank 7\t"CYAN"%s\n\
	"DEEPSKYBLUE"Clan Rank 8\t"CYAN"%s\n\
	"DEEPSKYBLUE"Clan Rank 9\t"CYAN"%s\n\
	"DEEPSKYBLUE"Clan Rank 10\t"CYAN"%s\n\
	"DEEPSKYBLUE"Change Perms\n\
	"DEEPSKYBLUE"Change Name\t"CYAN"%s\n\
	"DEEPSKYBLUE"Change Tag\t"CYAN"%s\n\
	"DEEPSKYBLUE"Clan Perks",
	GetClanMotd(GetPlayerClan(playerid)),
	GetClanRankName(GetPlayerClan(playerid), 1),
	GetClanRankName(GetPlayerClan(playerid), 2),
	GetClanRankName(GetPlayerClan(playerid), 3),
	GetClanRankName(GetPlayerClan(playerid), 4),
	GetClanRankName(GetPlayerClan(playerid), 5),
	GetClanRankName(GetPlayerClan(playerid), 6),
	GetClanRankName(GetPlayerClan(playerid), 7),
	GetClanRankName(GetPlayerClan(playerid), 8),
	GetClanRankName(GetPlayerClan(playerid), 9),
	GetClanRankName(GetPlayerClan(playerid), 10),
	GetPlayerClan(playerid),
	GetClanTag(GetPlayerClan(playerid)));

	AddClanLog(playerid, "Used the /clan command");

	inline ClanManagerClanName(pid, dialogid, response, listitem, string:inputtext[]) {
		#pragma unused dialogid, inputtext, listitem
		if (!response) return PC_EmulateCommand(pid, "/clan");
		if (!IsPlayerInAnyClan(pid)) return Text_Send(pid, $CLIENT_420x);
		if (strlen(inputtext) >= 31 || strlen(inputtext) <= 4) return Text_Send(pid, $CLIENT_498x);
		if (!IsValidText(inputtext)) return Text_Send(pid, $CLIENT_503x);
		if (GetClanXP(GetPlayerClan(pid)) < 500) return Text_Send(pid, $CLIENT_501x);
		PC_EmulateCommand(pid, "/clan");
		foreach(new i: Player) if (pClan[i] == pClan[pid]) Text_Send(i, $CLIENT_502x, PlayerInfo[pid][PlayerName], GetClanName(GetPlayerClan(pid)), inputtext);
		SetClanName(GetPlayerClan(pid), inputtext);
		AddClanXP(GetPlayerClan(pid), -500);    
		new logmessage[500];
		format(logmessage, sizeof(logmessage), "Updated clan name to: %s (lost 500 XP)", inputtext);
		AddClanLog(pid, logmessage);
	}

	inline ClanManagerClanTag(pid, dialogid, response, listitem, string:inputtext[]) {
		#pragma unused dialogid, inputtext, listitem
		if (!response) return PC_EmulateCommand(pid, "/clan");
		if (!IsPlayerInAnyClan(pid)) return Text_Send(pid, $CLIENT_420x);
		if (strlen(inputtext) >= 5 || strlen(inputtext) <= 0) return Text_Send(pid, $CLIENT_599x);
		if (!IsValidText(inputtext)) return Text_Send(pid, $CLIENT_503x);
		if (GetClanXP(GetPlayerClan(pid)) < 500) return Text_Send(pid, $CLIENT_501x);
		PC_EmulateCommand(pid, "/clan");
		foreach(new i: Player) if (pClan[i] == pClan[pid]) Text_Send(i, $CLIENT_504x, PlayerInfo[pid][PlayerName], GetClanTag(GetPlayerClan(pid)), inputtext);
		SetClanTag(GetPlayerClan(pid), inputtext);
		AddClanXP(GetPlayerClan(pid), -500);  
		new logmessage[500];
		format(logmessage, sizeof(logmessage), "Updated clan tag to: %s (lost 500 XP)", inputtext);
		AddClanLog(pid, logmessage);
	}

	inline ClanManagerMotd(pid, dialogid, response, listitem, string:inputtext[]) {
		#pragma unused dialogid, inputtext, listitem
		if (!response) return PC_EmulateCommand(pid, "/clan");
		if (!IsPlayerInAnyClan(pid)) return Text_Send(pid, $CLIENT_420x);
		if (strlen(inputtext) >= 59 || strlen(inputtext) <= 3) return Text_Send(pid, $CLIENT_505x);
		SetClanMotd(GetPlayerClan(pid), inputtext);
		PC_EmulateCommand(pid, "/clan");
		foreach(new i: Player) if (pClan[i] == pClan[pid]) Text_Send(i, $CLIENT_506x, PlayerInfo[pid][PlayerName], inputtext);    
		new logmessage[500];
		format(logmessage, sizeof(logmessage), "Updated clan motd to: %s", inputtext);
		AddClanLog(pid, logmessage);
	}

	inline ClanManagerRank1(pid, dialogid, response, listitem, string:inputtext[]) {
		#pragma unused dialogid, inputtext, listitem
		if (!response) return PC_EmulateCommand(pid, "/clan");
		if (!IsPlayerInAnyClan(pid)) return Text_Send(pid, $CLIENT_420x);
		if (strlen(inputtext) >= 19 || strlen(inputtext) <= 3) return Text_Send(pid, $CLIENT_507x);
		if (!IsValidText(inputtext)) return Text_Send(pid, $CLIENT_503x);
		PC_EmulateCommand(pid, "/clan");
		foreach(new i: Player) if (pClan[i] == pClan[pid]) Text_Send(i, $CLIENT_508x, PlayerInfo[pid][PlayerName], GetClanRankName(GetPlayerClan(pid), 1), inputtext);
		new logmessage[128];
		format(logmessage, sizeof(logmessage), "Updated clan rank %s to %s", GetClanRankName(GetPlayerClan(pid), 1), inputtext);
		AddClanLog(pid, logmessage);
		SetClanRankName(GetPlayerClan(pid), 1, inputtext);
	}

	inline ClanManagerRank2(pid, dialogid, response, listitem, string:inputtext[]) {
		#pragma unused dialogid, inputtext, listitem
		if (!response) return PC_EmulateCommand(pid, "/clan");
		if (!IsPlayerInAnyClan(pid)) return Text_Send(pid, $CLIENT_420x);
		if (strlen(inputtext) >= 19 || strlen(inputtext) <= 3) return Text_Send(pid, $CLIENT_507x);
		if (!IsValidText(inputtext)) return Text_Send(pid, $CLIENT_503x);
		PC_EmulateCommand(pid, "/clan");
		foreach(new i: Player) if (pClan[i] == pClan[pid]) Text_Send(i, $CLIENT_508x, PlayerInfo[pid][PlayerName], GetClanRankName(GetPlayerClan(pid), 2), inputtext);
		new logmessage[128];
		format(logmessage, sizeof(logmessage), "Updated clan rank %s to %s", GetClanRankName(GetPlayerClan(pid), 2), inputtext);
		AddClanLog(pid, logmessage);
		SetClanRankName(GetPlayerClan(pid), 2, inputtext);
	}

	inline ClanManagerRank3(pid, dialogid, response, listitem, string:inputtext[]) {
		#pragma unused dialogid, inputtext, listitem
		if (!response) return PC_EmulateCommand(pid, "/clan");
		if (!IsPlayerInAnyClan(pid)) return Text_Send(pid, $CLIENT_420x);
		if (strlen(inputtext) >= 19 || strlen(inputtext) <= 3) return Text_Send(pid, $CLIENT_507x);
		if (!IsValidText(inputtext)) return Text_Send(pid, $CLIENT_503x);
		PC_EmulateCommand(pid, "/clan");
		foreach(new i: Player) if (pClan[i] == pClan[pid]) Text_Send(i, $CLIENT_508x, PlayerInfo[pid][PlayerName], GetClanRankName(GetPlayerClan(pid), 3), inputtext);
		new logmessage[128];
		format(logmessage, sizeof(logmessage), "Updated clan rank %s to %s", GetClanRankName(GetPlayerClan(pid), 3), inputtext);
		AddClanLog(pid, logmessage);
		SetClanRankName(GetPlayerClan(pid), 3, inputtext);
	}

	inline ClanManagerRank4(pid, dialogid, response, listitem, string:inputtext[]) {
		#pragma unused dialogid, inputtext, listitem
		if (!response) return PC_EmulateCommand(pid, "/clan");
		if (!IsPlayerInAnyClan(pid)) return Text_Send(pid, $CLIENT_420x);
		if (strlen(inputtext) >= 19 || strlen(inputtext) <= 3) return Text_Send(pid, $CLIENT_507x);
		if (!IsValidText(inputtext)) return Text_Send(pid, $CLIENT_503x);
		PC_EmulateCommand(pid, "/clan");
		foreach(new i: Player) if (pClan[i] == pClan[pid]) Text_Send(i, $CLIENT_508x, PlayerInfo[pid][PlayerName], GetClanRankName(GetPlayerClan(pid), 4), inputtext);
		new logmessage[128];
		format(logmessage, sizeof(logmessage), "Updated clan rank %s to %s", GetClanRankName(GetPlayerClan(pid), 4), inputtext);
		AddClanLog(pid, logmessage);
		SetClanRankName(GetPlayerClan(pid), 4, inputtext);
	}

	inline ClanManagerRank5(pid, dialogid, response, listitem, string:inputtext[]) {
		#pragma unused dialogid, inputtext, listitem
		if (!response) return PC_EmulateCommand(pid, "/clan");
		if (!IsPlayerInAnyClan(pid)) return Text_Send(pid, $CLIENT_420x);
		if (strlen(inputtext) >= 19 || strlen(inputtext) <= 3) return Text_Send(pid, $CLIENT_507x);
		if (!IsValidText(inputtext)) return Text_Send(pid, $CLIENT_503x);
		PC_EmulateCommand(pid, "/clan");
		foreach(new i: Player) if (pClan[i] == pClan[pid]) Text_Send(i, $CLIENT_508x, PlayerInfo[pid][PlayerName], GetClanRankName(GetPlayerClan(pid), 5), inputtext);
		new logmessage[128];
		format(logmessage, sizeof(logmessage), "Updated clan rank %s to %s", GetClanRankName(GetPlayerClan(pid), 5), inputtext);
		AddClanLog(pid, logmessage);
		SetClanRankName(GetPlayerClan(pid), 5, inputtext);
	}

	inline ClanManagerRank6(pid, dialogid, response, listitem, string:inputtext[]) {
		#pragma unused dialogid, inputtext, listitem
		if (!response) return PC_EmulateCommand(pid, "/clan");
		if (!IsPlayerInAnyClan(pid)) return Text_Send(pid, $CLIENT_420x);
		if (strlen(inputtext) >= 19 || strlen(inputtext) <= 3) return Text_Send(pid, $CLIENT_507x);
		if (!IsValidText(inputtext)) return Text_Send(pid, $CLIENT_503x);
		PC_EmulateCommand(pid, "/clan");
		foreach(new i: Player) if (pClan[i] == pClan[pid]) Text_Send(i, $CLIENT_508x, PlayerInfo[pid][PlayerName], GetClanRankName(GetPlayerClan(pid), 6), inputtext);
		new logmessage[128];
		format(logmessage, sizeof(logmessage), "Updated clan rank %s to %s", GetClanRankName(GetPlayerClan(pid), 6), inputtext);
		AddClanLog(pid, logmessage);
		SetClanRankName(GetPlayerClan(pid), 6, inputtext);
	}

	inline ClanManagerRank7(pid, dialogid, response, listitem, string:inputtext[]) {
		#pragma unused dialogid, inputtext, listitem
		if (!response) return PC_EmulateCommand(pid, "/clan");
		if (!IsPlayerInAnyClan(pid)) return Text_Send(pid, $CLIENT_420x);
		if (strlen(inputtext) >= 19 || strlen(inputtext) <= 3) return Text_Send(pid, $CLIENT_507x);
		if (!IsValidText(inputtext)) return Text_Send(pid, $CLIENT_503x);
		PC_EmulateCommand(pid, "/clan");
		foreach(new i: Player) if (pClan[i] == pClan[pid]) Text_Send(i, $CLIENT_508x, PlayerInfo[pid][PlayerName], GetClanRankName(GetPlayerClan(pid), 7), inputtext);
		new logmessage[128];
		format(logmessage, sizeof(logmessage), "Updated clan rank %s to %s", GetClanRankName(GetPlayerClan(pid), 7), inputtext);
		AddClanLog(pid, logmessage);
		SetClanRankName(GetPlayerClan(pid), 7, inputtext);
	}

	inline ClanManagerRank8(pid, dialogid, response, listitem, string:inputtext[]) {
		#pragma unused dialogid, inputtext, listitem
		if (!response) return PC_EmulateCommand(pid, "/clan");
		if (!IsPlayerInAnyClan(pid)) return Text_Send(pid, $CLIENT_420x);
		if (strlen(inputtext) >= 19 || strlen(inputtext) <= 3) return Text_Send(pid, $CLIENT_507x);
		if (!IsValidText(inputtext)) return Text_Send(pid, $CLIENT_503x);
		PC_EmulateCommand(pid, "/clan");
		foreach(new i: Player) if (pClan[i] == pClan[pid]) Text_Send(i, $CLIENT_508x, PlayerInfo[pid][PlayerName], GetClanRankName(GetPlayerClan(pid), 8), inputtext);
		new logmessage[128];
		format(logmessage, sizeof(logmessage), "Updated clan rank %s to %s", GetClanRankName(GetPlayerClan(pid), 8), inputtext);
		AddClanLog(pid, logmessage);
		SetClanRankName(GetPlayerClan(pid), 8, inputtext);
	}

	inline ClanManagerRank9(pid, dialogid, response, listitem, string:inputtext[]) {
		#pragma unused dialogid, inputtext, listitem
		if (!response) return PC_EmulateCommand(pid, "/clan");
		if (!IsPlayerInAnyClan(pid)) return Text_Send(pid, $CLIENT_420x);
		if (strlen(inputtext) >= 19 || strlen(inputtext) <= 3) return Text_Send(pid, $CLIENT_507x);
		if (!IsValidText(inputtext)) return Text_Send(pid, $CLIENT_503x);
		PC_EmulateCommand(pid, "/clan");
		foreach(new i: Player) if (pClan[i] == pClan[pid]) Text_Send(i, $CLIENT_508x, PlayerInfo[pid][PlayerName], GetClanRankName(GetPlayerClan(pid), 9), inputtext);
		new logmessage[128];
		format(logmessage, sizeof(logmessage), "Updated clan rank %s to %s", GetClanRankName(GetPlayerClan(pid), 9), inputtext);
		AddClanLog(pid, logmessage);
		SetClanRankName(GetPlayerClan(pid), 9, inputtext);
	}

	inline ClanManagerRank10(pid, dialogid, response, listitem, string:inputtext[]) {
		#pragma unused dialogid, inputtext, listitem
		if (!response) return PC_EmulateCommand(pid, "/clan");
		if (!IsPlayerInAnyClan(pid)) return Text_Send(pid, $CLIENT_420x);
		if (strlen(inputtext) >= 19 || strlen(inputtext) <= 3) return Text_Send(pid, $CLIENT_507x);
		if (!IsValidText(inputtext)) return Text_Send(pid, $CLIENT_503x);
		PC_EmulateCommand(pid, "/clan");
		foreach(new i: Player) if (pClan[i] == pClan[pid]) Text_Send(i, $CLIENT_508x, PlayerInfo[pid][PlayerName], GetClanRankName(GetPlayerClan(pid), 10), inputtext);
		new logmessage[128];
		format(logmessage, sizeof(logmessage), "Updated clan rank %s to %s", GetClanRankName(GetPlayerClan(pid), 10), inputtext);
		AddClanLog(pid, logmessage);
		SetClanRankName(GetPlayerClan(pid), 10, inputtext);
	}

	inline ClanManagerPermsInvite(pid, dialogid, response, listitem, string:inputtext[]) {
		#pragma unused dialogid, inputtext, listitem
		if (!response) return PC_EmulateCommand(pid, "/clan");
		if (!IsPlayerInAnyClan(pid)) return Text_Send(pid, $CLIENT_420x);
		if (strval(inputtext) > 10 || strval(inputtext) < 1) return Text_Send(pid, $CLIENT_509x);
		SetClanAddPerms(GetPlayerClan(pid), strval(inputtext));
		Text_Send(pid, $CLIENT_510x);
		PC_EmulateCommand(pid, "/clan");    
		AddClanLog(pid, "Changed clan permissions");
	}

	inline ClanManagerPermsWar(pid, dialogid, response, listitem, string:inputtext[]) {
		#pragma unused dialogid, inputtext, listitem
		if (!response) return PC_EmulateCommand(pid, "/clan");
		if (!IsPlayerInAnyClan(pid)) return Text_Send(pid, $CLIENT_420x);
		if (strval(inputtext) > 10 || strval(inputtext) < 1) return Text_Send(pid, $CLIENT_509x);
		SetClanWarPerms(GetPlayerClan(pid), strval(inputtext));
		Text_Send(pid, $CLIENT_510x);
		PC_EmulateCommand(pid, "/clan");    
		AddClanLog(pid, "Changed clan permissions");
	}

	inline ClanManagerPermsRanks(pid, dialogid, response, listitem, string:inputtext[]) {
		#pragma unused dialogid, inputtext, listitem
		if (!response) return PC_EmulateCommand(pid, "/clan");
		if (strval(inputtext) > 10 || strval(inputtext) < 1) return Text_Send(pid, $CLIENT_509x);
		SetClanSetPerms(GetPlayerClan(pid), strval(inputtext));
		Text_Send(pid, $CLIENT_510x);
		PC_EmulateCommand(pid, "/clan");    
		AddClanLog(pid, "Changed clan permissions");
	}

	inline ClanManagerClanPerms(pid, dialogid, response, listitem, string:inputtext[]) {
		#pragma unused dialogid, inputtext
		if (response) {
			if (!IsPlayerInAnyClan(pid)) return Text_Send(pid, $CLIENT_420x);
			switch (listitem) {
				case 0: Text_DialogBox(pid, DIALOG_STYLE_INPUT, using inline ClanManagerPermsInvite, $CLAN_PERMS_CAP, $CLAN_FIRST_PERM_DESC, $DIALOG_CONFIRM, $DIALOG_CANCEL);
				case 1: Text_DialogBox(pid, DIALOG_STYLE_INPUT, using inline ClanManagerPermsWar, $CLAN_PERMS_CAP, $CLAN_SECOND_PERM_DESC, $DIALOG_CONFIRM, $DIALOG_CANCEL);
				case 2: Text_DialogBox(pid, DIALOG_STYLE_INPUT, using inline ClanManagerPermsRanks, $CLAN_PERMS_CAP, $CLAN_THIRD_PERM_DESC, $DIALOG_CONFIRM, $DIALOG_CANCEL);
			}
		} else {
			PC_EmulateCommand(pid, "/clan");
		}
	}

	inline ClanManager(pid, dialogid, response, listitem, string:inputtext[]) {
		#pragma unused dialogid, inputtext
		if (response) {
			if (!IsPlayerInAnyClan(pid)) return Text_Send(pid, $CLIENT_420x);
			switch (listitem) {
				case 0: Text_DialogBox(pid, DIALOG_STYLE_INPUT, using inline ClanManagerClanTag, $DIALOG_MESSAGE_CAP, $CLAN_MOTD_CHANGE, $DIALOG_CONFIRM, $DIALOG_CANCEL);
				case 1: Text_DialogBox(pid, DIALOG_STYLE_INPUT, using inline ClanManagerRank1, $DIALOG_MESSAGE_CAP, $NEW_CLAN_RANK_DESC, $DIALOG_CONFIRM, $DIALOG_CANCEL);
				case 2: Text_DialogBox(pid, DIALOG_STYLE_INPUT, using inline ClanManagerRank2, $DIALOG_MESSAGE_CAP, $NEW_CLAN_RANK_DESC, $DIALOG_CONFIRM, $DIALOG_CANCEL);
				case 3: Text_DialogBox(pid, DIALOG_STYLE_INPUT, using inline ClanManagerRank3, $DIALOG_MESSAGE_CAP, $NEW_CLAN_RANK_DESC, $DIALOG_CONFIRM, $DIALOG_CANCEL);
				case 4: Text_DialogBox(pid, DIALOG_STYLE_INPUT, using inline ClanManagerRank4, $DIALOG_MESSAGE_CAP, $NEW_CLAN_RANK_DESC, $DIALOG_CONFIRM, $DIALOG_CANCEL);
				case 5: Text_DialogBox(pid, DIALOG_STYLE_INPUT, using inline ClanManagerRank5, $DIALOG_MESSAGE_CAP, $NEW_CLAN_RANK_DESC, $DIALOG_CONFIRM, $DIALOG_CANCEL);
				case 6: Text_DialogBox(pid, DIALOG_STYLE_INPUT, using inline ClanManagerRank6, $DIALOG_MESSAGE_CAP, $NEW_CLAN_RANK_DESC, $DIALOG_CONFIRM, $DIALOG_CANCEL);
				case 7: Text_DialogBox(pid, DIALOG_STYLE_INPUT, using inline ClanManagerRank7, $DIALOG_MESSAGE_CAP, $NEW_CLAN_RANK_DESC, $DIALOG_CONFIRM, $DIALOG_CANCEL);
				case 8: Text_DialogBox(pid, DIALOG_STYLE_INPUT, using inline ClanManagerRank8, $DIALOG_MESSAGE_CAP, $NEW_CLAN_RANK_DESC, $DIALOG_CONFIRM, $DIALOG_CANCEL);
				case 9: Text_DialogBox(pid, DIALOG_STYLE_INPUT, using inline ClanManagerRank9, $DIALOG_MESSAGE_CAP, $NEW_CLAN_RANK_DESC, $DIALOG_CONFIRM, $DIALOG_CANCEL);
				case 10: Text_DialogBox(pid, DIALOG_STYLE_INPUT, using inline ClanManagerRank10, $DIALOG_MESSAGE_CAP, $NEW_CLAN_RANK_DESC, $DIALOG_CONFIRM, $DIALOG_CANCEL);
				case 11: Text_DialogBox(pid, DIALOG_STYLE_TABLIST, using inline ClanManagerClanPerms, $DIALOG_SELECT_CAP, $CLAN_RANK_PERMS_DESC, $DIALOG_SELECT, $DIALOG_CANCEL, GetClanRankName(GetPlayerClan(pid), GetClanAddPerms(GetPlayerClan(pid))), GetClanRankName(GetPlayerClan(pid), GetClanWarPerms(GetPlayerClan(pid))), GetClanRankName(GetPlayerClan(pid), GetClanSetPerms(GetPlayerClan(pid))));
				case 12: Text_DialogBox(pid, DIALOG_STYLE_INPUT, using inline ClanManagerClanName, $DIALOG_MESSAGE_CAP, $CLAN_NAME_CHANGE, $DIALOG_CONFIRM, $DIALOG_CANCEL);
				case 13: Text_DialogBox(pid, DIALOG_STYLE_INPUT, using inline ClanManagerClanTag, $DIALOG_MESSAGE_CAP, $CLAN_TAG_CHANGE, $DIALOG_CONFIRM, $DIALOG_CANCEL);
				case 14: PC_EmulateCommand(pid, "/clanperks");
			}
		}
	}
	Dialog_ShowCallback(playerid, using inline ClanManager, DIALOG_STYLE_TABLIST, GetPlayerClan(playerid), clan_message, ">>", "X");
	return 1;
}

CMD:clanperks(playerid) {
	if (!IsPlayerInAnyClan(playerid)) return Text_Send(playerid, $CLIENT_311x);
	if (GetPlayerClanRank(playerid) < 10) return Text_Send(playerid, $CLIENT_362x);
	if (!IsValidClan(GetPlayerClan(playerid))) return Text_Send(playerid, $CLIENT_420x);

	inline ClanPerks(pid, dialogid, response, listitem, string:inputtext[]) {
		#pragma unused dialogid, inputtext
		if (response) {
			switch (listitem) {
				case 0: {
					PC_EmulateCommand(pid, "/vshop");
				}
				case 1: {
					PC_EmulateCommand(pid, "/cskin");
				}
				case 2: {
					PC_EmulateCommand(pid, "/cweapon");
				}
			}
		}
	}

	Text_DialogBox(playerid, DIALOG_STYLE_TABLIST, using inline ClanPerks, $CLAN_PERKS_CAP, $CLAN_PERKS_DESC, $DIALOG_PURCHASE, $DIALOG_CANCEL);
	AddClanLog(playerid, "Used the /clanperks command");
	return 1;
}

CMD:cmembers(playerid, params[]) {
	if (isnull(params)) { 
		if (!IsPlayerInAnyClan(playerid) || !IsValidClan(GetPlayerClan(playerid))) return Text_Send(playerid, $CLIENT_358x);
	} else if (!IsValidClan(params)) return Text_Send(playerid, $CLIENT_517x);
	for (new i = 0; i < sizeof(ClanInfo) - 1; i++) {
		if (ClanInfo[i][Clan_Id] != -1 && !strcmp(ClanInfo[i][Clan_Name], params, true) &&
			!isnull(ClanInfo[i][Clan_Name])) {
			new query[160];
			if (!isnull(params)) {
				mysql_format(Database, query, sizeof(query), "SELECT * FROM `Players` WHERE `ClanId` = %d", ClanInfo[i][Clan_Id]);
				mysql_tquery(Database, query, "ParseClanUsers", "is", playerid, params);
			} else {
				mysql_format(Database, query, sizeof(query), "SELECT * FROM `Players` WHERE `ClanId` = %d", pClan[playerid]);
				mysql_tquery(Database, query, "ParseClanUsers", "is", playerid, GetPlayerClan(playerid));
			}
			break;
		}
	}
	return 1;
}

CMD:cmon(playerid) {
	if (IsPlayerInAnyClan(playerid)) {
		new string[95];
		foreach(new i: Player) {
			if (IsPlayerInAnyClan(i) && pClan[playerid] == pClan[i])
			{
				format(string, sizeof(string), "%s - %s (%d)", PlayerInfo[i][PlayerName], GetPlayerClanRankName(i), GetPlayerClanRank(i));
				SendClientMessage(playerid, 0x0099CCFF, string);
			}
		}
		if (isnull(string)) return Text_Send(playerid, $CLIENT_423x);
	}
	else
		return Text_Send(playerid, $CLIENT_358x);    
	return 1;
}

CMD:clogger(playerid, params[]) {
	new limit;
	if (isnull(params) || !IsNumeric(params)) {
		limit = 0;
	} else {
		limit = strval(params);
	}
	if (!IsPlayerInAnyClan(playerid)) return Text_Send(playerid, $CLIENT_358x);
	if (GetPlayerClanRank(playerid) < 10) return Text_Send(playerid, $CLIENT_362x);

	new query[128];
	mysql_format(Database, query, sizeof(query), "SELECT * FROM `ClanLog` WHERE `cID` = '%d' LIMIT %d, %d", pClan[playerid], limit, limit + 10);
	mysql_tquery(Database, query, "OnClanLogView", "i", playerid);
	return 1;
}

alias:clans("topclans");
CMD:clans(playerid) {
	new Cache: topClans;
	topClans = mysql_query(Database, "SELECT `ClanName`, `ClanPoints` FROM `ClansData` ORDER BY `ClanPoints` DESC LIMIT 10");
	if (cache_num_rows()) {
		for (new i = 0; i < cache_num_rows(); i++) {
			new clanName[35], clanPoints;
			cache_get_value(i, "ClanName", clanName);
			cache_get_value_int(i, "ClanPoints", clanPoints);

			Text_Send(playerid, $NEWCLIENT_185x, clanName, i + 1, clanPoints);
		}
	} else Text_Send(playerid, $CLIENT_423x);
	cache_delete(topClans);
	return 1;
}

CMD:usetag(playerid) {
	if (!IsPlayerInAnyClan(playerid)) return Text_Send(playerid, $CLIENT_358x);
	if (!PlayerInfo[playerid][pClanTag]) {
		printf("Player %s[%d] attached clan tag to their name.", PlayerInfo[playerid][PlayerName], playerid);
		PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
		PlayerInfo[playerid][pClanTag] = 1;
	}
	else
	{
		printf("Player %s[%d] removed clan tag from their name.", PlayerInfo[playerid][PlayerName], playerid);
		PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
		PlayerInfo[playerid][pClanTag] = 0;
	}
	return 1;
}

CMD:cann(playerid, params[]) {
	if (IsPlayerInAnyClan(playerid) && GetPlayerClanRank(playerid) == 10) {
		if (strlen(params) >= 15) {
			if (GetClanLevel(GetPlayerClan(playerid)) >= 7) {
				new message[128];
				format(message, sizeof(message), "[!] CLAN ADV (%s): %s", GetPlayerClan(playerid), params);
				SendClientMessageToAll(0x30A69EFF, message);
				printf("[CLAN ANN by %s] %s", PlayerInfo[playerid][PlayerName], message);
				format(message, sizeof(message), "Advertised clan mssage: %s", params);
				AddClanLog(playerid, message);
			}  else Text_Send(playerid, $CLIENT_518x);
		}  else Text_Send(playerid, $CLIENT_519x);
	}  else Text_Send(playerid, $CLIENT_362x);
	return 1;
}

CMD:c(playerid, params[]) {
	if (isnull(params)) return 1;
	new message[150 + MAX_PLAYER_NAME];

	if (IsPlayerInAnyClan(playerid)) {
		foreach (new i: Player) {
			if (IsPlayerInAnyClan(i)) {
				if (pClan[playerid] == pClan[i])
				{
					format(message, sizeof(message), "[C-%s]{%06x} %s %s[%d]:"IVORY" %s", GetPlayerClan(playerid), GetPlayerColor(playerid) >>> 8, GetPlayerClanRankName(playerid), PlayerInfo[playerid][PlayerName], playerid, params);
					SendClientMessage(i, 0xFFFF00FF, message);
				}
			}
		}

		format(message, sizeof(message), "[C-%s] %s %s[%d]: %s", GetPlayerClan(playerid), GetPlayerClanRankName(playerid), PlayerInfo[playerid][PlayerName], playerid, params);
		foreach(new i: Player) {
			if (IsPlayerConnected(i) && PlayerInfo[i][pAdminLevel] && i != playerid
				&& PlayerInfo[i][pAdminLevel] >= PlayerInfo[playerid][pAdminLevel]) {
				SendClientMessage(i, X11_IVORY, message);
			}
		}
		printf(message);

	}  else Text_Send(playerid, $CLIENT_358x);
	return 1;
}

CMD:csetleader(playerid, params[]) {
	if (IsPlayerInAnyClan(playerid)) {
		if (GetPlayerClanRank(playerid) < 10) return Text_Send(playerid, $CLIENT_362x);
		new targetid;
		if (sscanf(params, "ud", targetid)) return ShowSyntax(playerid, "/csetleader [playerid/name]");
		if (!IsPlayerConnected(targetid) || targetid == playerid) return Text_Send(playerid, $CLIENT_319x);

		if (IsPlayerInAnyClan(targetid) && pClan[playerid] == pClan[targetid]) {
			if (pClanRank[targetid] != 10) {
				pClanRank[targetid] = 10;
			} else {
				pClanRank[targetid] = 9;
			}

			foreach (new i: Player) {
				if (IsPlayerInAnyClan(i)) {
					if (pClan[playerid] == pClan[i]) {
						Text_Send(i, $CLIENT_520x, PlayerInfo[targetid][PlayerName], GetClanRankName(GetPlayerClan(playerid), pClanRank[targetid]));
					}
				}
			}

			new message[90];
			format(message, sizeof(message), "Made %s level %d in clan", PlayerInfo[targetid][PlayerName], pClanRank[targetid]);
			AddClanLog(playerid, message);
		}  else Text_Send(playerid, $CLIENT_434x);
	}  else Text_Send(playerid, $CLIENT_358x);
	return 1;
}

CMD:resetskin(playerid, params[]) {
	if (!IsPlayerInAnyClan(playerid)) return Text_Send(playerid, $CLIENT_358x);
	if (GetClanSkin(GetPlayerClan(playerid)) == 0) return Text_Send(playerid, $CLIENT_521x);

	SetClanSkin(GetPlayerClan(playerid), 0);
	AddClanXP(GetPlayerClan(playerid), 5000);
	AddClanLog(playerid, "Reset the clan skin");
	foreach(new i: Player) if (pClan[i] == pClan[playerid]) Text_Send(i, $CLIENT_522x, PlayerInfo[playerid][PlayerName]);
	return 1;
}

CMD:csetrank(playerid, params[]) {
	if (IsPlayerInAnyClan(playerid)) {
		if (GetPlayerClanRank(playerid) < GetClanSetPerms(GetPlayerClan(playerid))) return Text_Send(playerid, $CLIENT_362x);
		new rankid, targetid;
		if (sscanf(params, "ud", targetid, rankid)) return ShowSyntax(playerid, "/csetrank [playerid/name] [level 1-9]");
		if (rankid > 9 || rankid < 1) return ShowSyntax(playerid, "/csetrank [player name/id] [level 1-9]");
		if (!IsPlayerConnected(targetid) || targetid == playerid) return Text_Send(playerid, $CLIENT_319x);

		if (IsPlayerInAnyClan(targetid) && pClan[playerid] == pClan[targetid]) {
			if (pClanRank[targetid] >= pClanRank[playerid]) return Text_Send(playerid, $CLIENT_362x);
			if (pClanRank[targetid] == rankid) return Text_Send(playerid, $CLIENT_420x);

			pClanRank[targetid] = rankid;

			foreach (new i: Player) {
				if (IsPlayerInAnyClan(i)) {
					if (pClan[playerid] == pClan[i]) {
						Text_Send(i, $CLIENT_520x, PlayerInfo[playerid][PlayerName], GetClanRankName(GetPlayerClan(playerid), pClanRank[targetid]));
					}
				}
			}

			new message[90];
			format(message, sizeof(message), "Made %s level %d in clan", PlayerInfo[targetid][PlayerName], pClanRank[targetid]);
			AddClanLog(playerid, message);
		}  else Text_Send(playerid, $CLIENT_523x);
	}  else Text_Send(playerid, $CLIENT_358x);
	return 1;
}

CMD:claninfo(playerid, params[]) {
	if (!IsPlayerInAnyClan(playerid) && PlayerInfo[playerid][pAdminLevel] < svtconf[max_admin_level]) return Text_Send(playerid, $CLIENT_358x);

	new clan[60];

	if (isnull(params)) { 
		if (IsPlayerInAnyClan(playerid)) {
			strcat(clan, GetPlayerClan(playerid));
		} else {
			return Text_Send(playerid, $CLIENT_524x);
		}	
	} else {
		if (!IsValidClanTag(params) && !IsValidClan(params)) return Text_Send(playerid, $CLIENT_525x);
		
		if (IsValidClan(params)) {
			strcat(clan, params);
		} else {
			strcat(clan, GetClanName(params));			
		}
	}

	for (new i = 0; i < sizeof(ClanInfo) - 1; i++) {
		if (ClanInfo[i][Clan_Id] != -1 && !strcmp(ClanInfo[i][Clan_Name], clan, true)
			&& !isnull(ClanInfo[i][Clan_Name])) {	
			new clan_stats[170], full_stats[170 * 5];
			format(clan_stats, sizeof(clan_stats), ""IVORY"Clan name:"DEEPSKYBLUE" %s\n"IVORY"Clan tag:"DEEPSKYBLUE" %s\n"IVORY"Clan weapon:"DEEPSKYBLUE" %s\n",
			ClanInfo[i][Clan_Name], ClanInfo[i][Clan_Tag], ClanInfo[i][Clan_Weapon] != 0 ? ReturnWeaponName(ClanInfo[i][Clan_Weapon]) : "None");
			strcat(full_stats, clan_stats);

			format(clan_stats, sizeof(clan_stats), ""IVORY"Clan wallet:"DEEPSKYBLUE" $%d\n"IVORY"clan points:"DEEPSKYBLUE" %d\n"IVORY"Clan rank:"DEEPSKYBLUE" %s\n"IVORY"Clan level:"DEEPSKYBLUE" %d\n",
			ClanInfo[i][Clan_Wallet], GetClanXP(ClanInfo[i][Clan_Name]), ClanRanks[ClanInfo[i][Clan_Level]][C_LevelName], GetClanLevel(ClanInfo[i][Clan_Name]));
			strcat(full_stats, clan_stats);

			format(clan_stats, sizeof(clan_stats), ""IVORY"Clan motd:"DEEPSKYBLUE" %s\n"IVORY"Clan kills:"DEEPSKYBLUE" %d\n"IVORY"Clan deaths:"DEEPSKYBLUE" %d\n"IVORY"Clan KDR:"DEEPSKYBLUE" %0.1f", 
			GetClanMotd(ClanInfo[i][Clan_Name]), GetClanKills(ClanInfo[i][Clan_Name]), GetClanDeaths(ClanInfo[i][Clan_Name]), 
			floatdiv(GetClanKills(ClanInfo[i][Clan_Name]), GetClanDeaths(ClanInfo[i][Clan_Name])));
			strcat(full_stats, clan_stats);

			Dialog_Show(playerid, DIALOG_STYLE_MSGBOX, ClanInfo[i][Clan_Name], full_stats, "X", "");

			break;
		}
	}
	return 1;
}

CMD:cdonate(playerid, params[]) {
	if (!IsPlayerInAnyClan(playerid)) return Text_Send(playerid, $CLIENT_524x);

	new amount;
	if (sscanf(params, "i", amount)) return ShowSyntax(playerid, "/cdonate [amount]");
	if (amount < 5000) return Text_Send(playerid, $CLIENT_526x);
	if (amount > 700000) return Text_Send(playerid, $CLIENT_527x);
	if (amount > GetPlayerMoney(playerid)) return Text_Send(playerid, $CLIENT_528x);
	
	AddClanWallet(GetPlayerClan(playerid), amount);
	GivePlayerCash(playerid, -amount);

	foreach (new i: Player) {
		if (IsPlayerInAnyClan(i)) {
			if (pClan[playerid] == pClan[i]) {
				Text_Send(i, $CLIENT_529x, PlayerInfo[playerid][PlayerName], amount);
			}
		}
	}

	new message[90];
	format(message, sizeof(message), "Donated $%d to the clan", amount);
	AddClanLog(playerid, message);
	return 1;
}

CMD:cwithdraw(playerid, params[]) {
	if (!IsPlayerInAnyClan(playerid)) return Text_Send(playerid, $CLIENT_358x);
	if (GetPlayerClanRank(playerid) < 10) return Text_Send(playerid, $CLIENT_362x);

	new amount;
	if (sscanf(params, "i", amount)) return ShowSyntax(playerid, "/cwithdraw [amount]");
	if (amount < 5000 || !amount) return Text_Send(playerid, $CLIENT_530x);
	if (amount > 100000) return Text_Send(playerid, $CLIENT_531x);
	if (GetClanWallet(GetPlayerClan(playerid)) < amount ||
		!GetClanWallet(GetPlayerClan(playerid))) Text_Send(playerid, $CLIENT_532x);

	AddClanWallet(GetPlayerClan(playerid), -amount);
	GivePlayerCash(playerid, amount);

	foreach (new i: Player) {
		if (pClan[playerid] == pClan[i]) {
			Text_Send(i, $CLIENT_533x, PlayerInfo[playerid][PlayerName], amount);
		}
	}

	new message[90];
	format(message, sizeof(message), "Withdrew $%d from the clan", amount);
	AddClanLog(playerid, message);
	return 1;
}

CMD:ockick(playerid, params[]) {
	if (IsPlayerInAnyClan(playerid)) {
		if (GetPlayerClanRank(playerid) == 10) {
			new Name[MAX_PLAYER_NAME], Reason[25];

			if (sscanf(params, "s[25]s[25]", Name, Reason)) return ShowSyntax(playerid, "/ockick [name] [reason]");
			if (!strcmp(Name, PlayerInfo[playerid][PlayerName], true)) return Text_Send(playerid, $CLIENT_390x);

			new query[140];

			mysql_format(Database, query, sizeof(query), "SELECT * FROM `Players` WHERE `Username` = '%e' AND `ClanId` = '%d' LIMIT 1",  Name, pClan[playerid]);
			mysql_tquery(Database, query, "KickClanMember", "is", playerid, Reason);
		}  else Text_Send(playerid, $CLIENT_362x);
	}
	return 1;
}

CMD:ckick(playerid, params[]) {
	if (IsPlayerInAnyClan(playerid)) {
		if (GetPlayerClanRank(playerid) >= GetClanAddPerms(GetPlayerClan(playerid))) {
			new targetid, Reason[25];

			if (sscanf(params, "us[25]", targetid, Reason)) return ShowSyntax(playerid, "/ckick [playerid/name] [reason]");
			if (!IsPlayerConnected(targetid) || targetid == playerid) return Text_Send(playerid, $CLIENT_319x);

			if (pClan[playerid] == pClan[targetid]) {
				if (pClanRank[targetid] >= pClanRank[playerid]) return Text_Send(playerid, $CLIENT_362x);
				foreach (new i: Player) {
					if (IsPlayerInAnyClan(i)) {
						if (pClan[playerid] == pClan[i]) {
							Text_Send(i, $CLIENT_534x, PlayerInfo[targetid][PlayerName], Reason);
						}
					}
				}

				new query[140];

				mysql_format(Database, query, sizeof(query), "UPDATE `Players` SET `ClanId` = '-1', `ClanRank` = '0' WHERE `ID` = '%d' LIMIT 1",  PlayerInfo[targetid][pAccountId]);
				mysql_tquery(Database, query);

				pClan[targetid] = -1;
				pClanRank[targetid] = 0;
				PlayerInfo[targetid][pClanTag] = 0;
				format(query, sizeof(query), "Kicked %s from the clan", PlayerInfo[targetid][PlayerName]);
				AddClanLog(playerid, query);
			}  else Text_Send(playerid, $CLIENT_389x);
		}  else Text_Send(playerid, $CLIENT_362x);
	}
	return 1;
}

CMD:cleave(playerid) {
	if (IsPlayerInAnyClan(playerid)) {
		if (GetPlayerClanRank(playerid) < 10) {
			foreach (new i: Player) {
				if (IsPlayerInAnyClan(i)) {
					if (pClan[playerid] == pClan[i]) {
						Text_Send(playerid, $CLIENT_535x, PlayerInfo[playerid][PlayerName]);
					}
				}
			}

			AddClanLog(playerid, "Left the clan");

			pClan[playerid] = -1;
			pClanRank[playerid] = 0;
			PlayerInfo[playerid][pClanTag] = 0;
			Text_Send(playerid, $CLIENT_388x);
		}  else Text_Send(playerid, $CLIENT_387x);
	}
	return 1;
}

CMD:cinvite(playerid, params[]) {
	new targetid;

	if (!IsPlayerInAnyClan(playerid)) return Text_Send(playerid, $CLIENT_358x);
	if (GetPlayerClanRank(playerid) < GetClanAddPerms(GetPlayerClan(playerid))) return Text_Send(playerid, $CLIENT_362x);
	if (sscanf(params, "u", targetid)) return ShowSyntax(playerid, "/cinvite [playerid/name]");
	if (!IsPlayerConnected(targetid) || targetid == INVALID_PLAYER_ID) return Text_Send(playerid, $CLIENT_386x);
	if (IsPlayerInAnyClan(targetid)) return Text_Send(playerid, $CLIENT_385x);
	
	if (pCooldown[playerid][35] > gettime()) {
		Text_Send(playerid, $CLIENT_384x, pCooldown[playerid][35] - gettime());
		return 1;
	}

	pCooldown[playerid][35] = gettime() + 70;

	PlayerInfo[targetid][pIsInvitedToClan] = 1;
	format(PlayerInfo[targetid][pClan_Name], 35, "%s", GetPlayerClan(playerid));

	Text_Send(targetid, $CLIENT_383x, PlayerInfo[playerid][PlayerName], GetPlayerClan(playerid));
	Text_Send(playerid, $CLIENT_382x);
	
	new message[70];
	format(message, sizeof(message), "Invited %s to the clan", PlayerInfo[targetid][PlayerName]);
	AddClanLog(playerid, message);

	KillTimer(InviteTimer[targetid]);
	InviteTimer[targetid] = SetTimerEx("CancelInvite", 9000, false, "i", targetid);
	return 1;
}

CMD:accept(playerid, params[]) {
	if (IsPlayerInAnyClan(playerid)) return Text_Send(playerid, $CLIENT_381x);
	if (!PlayerInfo[playerid][pIsInvitedToClan]) return Text_Send(playerid, $CLIENT_380x);

	KillTimer(InviteTimer[playerid]);
	PlayerInfo[playerid][pIsInvitedToClan] = 0;

	for (new i = 0; i < sizeof(ClanInfo) - 1; i++) {
		if (ClanInfo[i][Clan_Id] != -1 && !strcmp(ClanInfo[i][Clan_Name], PlayerInfo[playerid][pClan_Name], true) &&
			!isnull(ClanInfo[i][Clan_Name])) {
			pClan[playerid] = ClanInfo[i][Clan_Id];
		}
	}		

	foreach (new i: Player) {
		if (IsPlayerInAnyClan(i)) {
			if (pClan[playerid] == pClan[i]) {
				Text_Send(i, $CLIENT_536x, PlayerInfo[playerid][PlayerName]);
			}
		}
	}

	pClanRank[playerid] = 1;
	AddClanLog(playerid, "Joined the clan");
	return 1;
}

CMD:clanpoints(playerid) {
	Text_DialogBox(playerid, DIALOG_STYLE_TABLIST_HEADERS, using none, $CLAN_POINTS_CAP, $CLAN_POINTS_DESC, $DIALOG_GOTIT, "");
	return 1;
}

CMD:clanranks(playerid) {
	new c_info[800];
	strcat(c_info, ""IVORY"");
	for (new i = 0; i < sizeof(ClanRanks); i++) {
		format(c_info, sizeof(c_info), "%s%s[%d] - EXP needed: %d\n", c_info, ClanRanks[i][C_LevelName], i, ClanRanks[i][C_LevelXP]);
	}

	Text_Send(playerid, $CLAN_RANKS_HINT);
	Text_Send(playerid, $CLAN_RANKS_2HINT);
	Text_Send(playerid, $CLAN_RANKS_3HINT);
	Text_Send(playerid, $CLAN_RANKS_4HINT);
	Text_Send(playerid, $CLAN_RANKS_5HINT);
	Dialog_Show(playerid, DIALOG_STYLE_MSGBOX, "Clan Ranks", c_info, "X", "");
	return 1;
}

CMD:cskin(playerid) {
	if (!IsPlayerInAnyClan(playerid)) return Text_Send(playerid, $CLIENT_358x);
	if (GetPlayerClanRank(playerid) < 10) return Text_Send(playerid, $CLIENT_362x);
	if (GetClanXP(GetPlayerClan(playerid)) < 5000) return PlayerPlaySound(playerid, 1055, 0.0, 0.0, 0.0), Text_Send(playerid, $CLIENT_377x);
	ShowModelSelectionMenu(playerid, clanskinlist, "Clan Skins", 0x000000CC, X11_DEEPPINK, X11_IVORY);    
	AddClanLog(playerid, "Accessed the clan skin command");
	return 1;
}

CMD:cweapon(playerid) {
	if (!IsPlayerInAnyClan(playerid)) return Text_Send(playerid, $CLIENT_358x);
	if (GetPlayerClanRank(playerid) < 10) return Text_Send(playerid, $CLIENT_362x);
	if (GetClanXP(GetPlayerClan(playerid)) < 5000) return PlayerPlaySound(playerid, 1055, 0.0, 0.0, 0.0), Text_Send(playerid, $CLIENT_377x);

	new weapons_str[65], overall[970];
	strcat(overall, "Weapon\tAmmo\tPrice\n");
		
	for (new i = 0; i < sizeof(WeaponInfo); i++)	{
		format(weapons_str, sizeof(weapons_str), ""LIGHTBLUE"%s\t"IVORY"%d\t"YELLOW"$%d\n", ReturnWeaponName(WeaponInfo[i][Weapon_Id]), WeaponInfo[i][Weapon_Ammo], WeaponInfo[i][Weapon_Price] * 60);
		strcat(overall, weapons_str);
	}

	inline ClanWeapon(pid, dialogid, response, listitem, string:inputtext[]) {
		#pragma unused dialogid, inputtext
		if (!response) return 1;
		if (GetClanWallet(GetPlayerClan(pid)) < WeaponInfo[listitem][Weapon_Price] * 60) return Text_Send(pid, $CLIENT_379x);
		if (GetClanXP(GetPlayerClan(pid)) < 5000) return PlayerPlaySound(pid, 1055, 0.0, 0.0, 0.0), Text_Send(pid, $CLIENT_377x);
		AddClanXP(GetPlayerClan(pid), -5000);
		AddClanWallet(GetPlayerClan(pid), -WeaponInfo[listitem][Weapon_Price] * 60);

		SetClanWeapon(GetPlayerClan(pid), WeaponInfo[listitem][Weapon_Id]);
		PlayerPlaySound(pid, 1054, 0.0, 0.0, 0.0);

		foreach(new i: Player) if (pClan[i] == pClan[pid]) Text_Send(i, $CLIENT_537x, ReturnWeaponName(WeaponInfo[listitem][Weapon_Id]), WeaponInfo[listitem][Weapon_Price] * 60);
		AddClanLog(pid, "Changed clan weapon (lost cash and 5000 XP)");
	}

	Dialog_ShowCallback(playerid, using inline ClanWeapon, DIALOG_STYLE_TABLIST_HEADERS, "Clan Weapon:", overall, ">>", "X");
	AddClanLog(playerid, "Accessed the clan weapon command");
	return 1;
}

CMD:cw(playerid, params[]) {
	if (cwInfo[cw_ready] == 1 || cwInfo[cw_started] == 1) return Text_Send(playerid, $CLIENT_378x);
	if (!IsPlayerInAnyClan(playerid)) return Text_Send(playerid, $CLIENT_358x);
	if (GetPlayerClanRank(playerid) < GetClanWarPerms(GetPlayerClan(playerid))) return Text_Send(playerid, $CLIENT_362x);
	if (GetClanXP(GetPlayerClan(playerid)) < 5000) return Text_Send(playerid, $CLIENT_377x);
	new clan_tag[10], weap1, weap2, weap3, weap4, maxrounds;
	if (sscanf(params, "s[10]ddddd", clan_tag, weap1, weap2, weap3, weap4, maxrounds)) return ShowSyntax(playerid, "/cw [clan tag] [weap 1] [weap 2] [weap 3] [weap 4] [rounds]");
	if (!IsValidWeapon(weap1) || !IsValidWeapon(weap2)) return Text_Send(playerid, $CLIENT_376x);
	if (maxrounds > 5 || maxrounds <= 0) return Text_Send(playerid, $CLIENT_375x);

	if (IsValidClanTag(clan_tag)) {
		foreach (new i: Player) {
			if (IsPlayerConnected(i) && i != playerid) {
				if (!strcmp(GetClanTag(GetPlayerClan(i)), clan_tag)) {
					if (GetPlayerClanRank(i) >= GetClanWarPerms(GetPlayerClan(playerid))) {
						if (GetClanXP(GetPlayerClan(i)) < 5000) return Text_Send(playerid, $CLIENT_374x);
						cwInfo[cw_ready] = 1;
						cwInfo[cw_plantime] = gettime() + 120;

						cwInfo[cw_clan1score] = 0;
						cwInfo[cw_clan2score] = 0;

						cwInfo[cw_rounds] = 1;
						cwInfo[cw_started] = 0;

						cwInfo[cw_maxrounds] = maxrounds;
						cwInfo[cw_weap1] = weap1;
						cwInfo[cw_weap2] = weap2;
						cwInfo[cw_weap3] = weap3;
						cwInfo[cw_weap4] = weap4;
						cwInfo[cw_skin1] = 0;
						cwInfo[cw_skin2] = 0;
						cwInfo[cw_admin] = 0;

						format(cwInfo[cw_clan1], 35, "%s", GetPlayerClan(playerid));
						format(cwInfo[cw_clan2], 35, "%s", GetPlayerClan(i));

						Iter_Clear(CWCLAN1);
						Iter_Clear(CWCLAN2);

						inline CWDialog(pid, dialogid, response, listitem, string:inputtext[]) {
							#pragma unused dialogid, listitem, inputtext
							if (cwInfo[cw_ready] != 1) return Text_Send(playerid, $CLIENT_373x);
							if (IsPlayerInAnyClan(pid) && !strcmp(GetPlayerClan(pid), cwInfo[cw_clan2])) {
								if (!response) {
									foreach (new x: Player) {
										 if (IsPlayerInAnyClan(x)) {
											  if (!strcmp(GetPlayerClan(x), cwInfo[cw_clan1], true)) {
												  if (GetPlayerClanRank(x) >= GetClanWarPerms(GetPlayerClan(pid))) {
													  Text_Send(x, $CLIENT_371x);
													  cwInfo[cw_ready] = 0;
													  cwInfo[cw_started] = 0;

													  return 1;
												  }
											  }
										 }
									}
								}

								Text_Send(@pVerified, $SERVER_71x, cwInfo[cw_clan1], cwInfo[cw_clan2]);

								foreach (new x: Player) {
									if (IsPlayerInAnyClan(x)) {
										if (!strcmp(GetPlayerClan(x), cwInfo[cw_clan1])) {
											Iter_SafeRemove(CWCLAN1, x, x);
										} else {
											Iter_SafeRemove(CWCLAN2, x, x);
										}
										if (!strcmp(GetPlayerClan(x), cwInfo[cw_clan1])) {
											Text_Send(x, $CLIENT_538x, cwInfo[cw_clan2]);
											Text_Send(x, $CLANWAR_ALERT);
										}
										if (!strcmp(GetPlayerClan(x), cwInfo[cw_clan2])) {
											Text_Send(x, $CLIENT_538x, cwInfo[cw_clan1]);
											Text_Send(x, $CLANWAR_ALERT);
										}
									}	
								}
							} else {
								Text_Send(pid, $CLIENT_372x);
							}    
							return 1;
						}

						inline CWMap(pid, dialogid, response, listitem, string:inputtext[]) {
							#pragma unused dialogid, inputtext
							if (!response) return cwInfo[cw_ready] = cwInfo[cw_started] = 0, Text_Send(pid, $CLIENT_371x);

							cwInfo[cw_map] = listitem;

							foreach (new x: Player) {
								if (x != pid) {
									if (IsPlayerInAnyClan(x)) {
										if (!strcmp(GetPlayerClan(x), cwInfo[cw_clan2])) {
											if (GetPlayerClanRank(x) == 10) {    
												new dialog_cw[290];
												format(dialog_cw, sizeof(dialog_cw),
												""IVORY"You received clan invitation from clan %s.\n\
												"IVORY"Clan Leader:{0099FF} %s[%d]\n\n\
												"IVORY"Weapons are random per round with a maximum of 3 rounds.",
												GetPlayerClan(pid), PlayerInfo[pid][PlayerName], pid);

												Dialog_ShowCallback(x, using inline CWDialog, DIALOG_STYLE_MSGBOX, "Clan War", dialog_cw, "Accept", "Decline");

												Text_Send(pid, $CLIENT_370x);      							
											}
										}
									}	
								}
							}
						}

						Dialog_ShowCallback(playerid, using inline CWMap, DIALOG_STYLE_LIST, "Select Map:", "Stadium\nBattlefield\nLVPD\nNew Island\nJefferson Motel", ">>", "Exit");
						
						new message[95];
						format(message, sizeof(message), "Invited %s for clan war", clan_tag);
						AddClanLog(playerid, message);
						return 1;
					}
				}
			}
		}
	}  else Text_Send(playerid, $CLIENT_369x);
	Text_Send(playerid, $CLIENT_368x);
	return 1;
}

CMD:cwstart(playerid) {
	if (cwInfo[cw_ready] == 0) return Text_Send(playerid, $CLIENT_363x);
	if (!IsPlayerInAnyClan(playerid)) return Text_Send(playerid, $CLIENT_358x);
	if (GetPlayerClanRank(playerid) < GetClanWarPerms(GetPlayerClan(playerid))) return Text_Send(playerid, $CLIENT_362x);
	if (cwInfo[cw_admin]) return Text_Send(playerid, $CLIENT_367x);

	if (!strcmp(GetPlayerClan(playerid), cwInfo[cw_clan1]) || !strcmp(GetPlayerClan(playerid), cwInfo[cw_clan2])) {
		if (Iter_Count(CWCLAN1) < 3 || Iter_Count(CWCLAN2) < 3) return Text_Send(playerid, $CLIENT_366x);
		cwInfo[cw_started] = 1;

		foreach (new i: CWCLAN1) {
			if (IsPlayerSpawned(i)) {
				Text_Send(i, $GO);
				SpawnPlayer(i);
			} else {
				Iter_SafeRemove(CWCLAN1, i, i);
				Text_Send(playerid, $CLIENT_365x);
			}
		}
		
		foreach (new i: CWCLAN2) {
			if (IsPlayerSpawned(i)) {
				Text_Send(i, $GO);
				SpawnPlayer(i);
			} else {
				Iter_SafeRemove(CWCLAN1, i, i);
				Text_Send(playerid, $CLIENT_365x);
			}
		}

		Text_Send(@pVerified, $SERVER_72x);

		AddClanLog(playerid, "Started clan war");
	}  else Text_Send(playerid, $CLIENT_364x);
	return 1;
}

CMD:cwend(playerid) {
	if (cwInfo[cw_ready] == 0) return Text_Send(playerid, $CLIENT_363x);
	if (!IsPlayerInAnyClan(playerid)) return Text_Send(playerid, $CLIENT_358x);
	if (GetPlayerClanRank(playerid) < GetClanWarPerms(GetPlayerClan(playerid))) return Text_Send(playerid, $CLIENT_362x);
	if (cwInfo[cw_admin]) return Text_Send(playerid, $CLIENT_361x);

	if (!strcmp(GetPlayerClan(playerid), cwInfo[cw_clan1]) || !strcmp(GetPlayerClan(playerid), cwInfo[cw_clan2])) {
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

		Text_Send(@pVerified, $SERVER_73x);
		AddClanLog(playerid, "Ended clan war");
	}  else Text_Send(playerid, $CLIENT_360x);    
	return 1;
}

CMD:joincw(playerid) {
	if (cwInfo[cw_ready] == 0 || cwInfo[cw_started] == 1) return Text_Send(playerid, $CLIENT_359x);
	if (!IsPlayerInAnyClan(playerid)) return Text_Send(playerid, $CLIENT_358x);
	if (!IsPlayerSpawned(playerid)) return Text_Send(playerid, $CLIENT_357x);
	if (Iter_Contains(CWCLAN1, playerid) || Iter_Contains(CWCLAN2, playerid)) return Text_Send(playerid, $CLIENT_356x);
	if (cwInfo[cw_admin]) return Text_Send(playerid, $CLIENT_355x);
	if (PlayerInfo[playerid][pLastHitTick] > gettime()) return Text_Send(playerid, $JUSTHIT, PlayerInfo[playerid][pLastHitTick] - gettime());

	if (!strcmp(GetPlayerClan(playerid), cwInfo[cw_clan1]) || !strcmp(GetPlayerClan(playerid), cwInfo[cw_clan2])) {
		if (AntiSK[playerid]) {
			EndProtection(playerid);
		}

		PlayerInfo[playerid][pClanWarSpec] = 0;
		PlayerInfo[playerid][pClanWarSpecId] = -1;

		if (!strcmp(GetPlayerClan(playerid), cwInfo[cw_clan1])) {
			Iter_Add(CWCLAN1, playerid);
		}
		else if (!strcmp(GetPlayerClan(playerid), cwInfo[cw_clan2])) {
			Iter_Add(CWCLAN2, playerid);
		}

		SetupClanwar(playerid);

		foreach(new i: Player) {
			if (IsPlayerConnected(i)) {
				if (!strcmp(GetPlayerClan(i), cwInfo[cw_clan1]) || !strcmp(GetPlayerClan(i), cwInfo[cw_clan2])) {
					Text_Send(i, $CLIENT_539x, PlayerInfo[playerid][PlayerName], Iter_Count(CWCLAN1) + Iter_Count(CWCLAN2));
				}
			}
		}
		
		AddClanLog(playerid, "Joined clan war");
	}  else Text_Send(playerid, $CLIENT_354x);
	return 1;
}

CMD:cbase(playerid) {
	new clanbase_owner = -1;
	for (new i = 0; i < MAX_CLANS; i++) {
		if (ClanInfo[i][Clan_Id] != -1 && ClanInfo[i][Clan_Baseperk]) {
			clanbase_owner = i;
			break;
		}
	}
	if (clanbase_owner != -1) {
		new d, h, m, s, seconds = ClanInfo[clanbase_owner][Clan_Baseperk] - gettime();
		d = (seconds / 86400);
		h = (seconds / 60 / 60 % 60);
		m = (seconds / 60 % 60);
		s = (seconds % 60);
		Text_Send(playerid, $NEWCLIENT_186x, ClanInfo[clanbase_owner][Clan_Name], d, h, m, s);
	} else {
		Text_Send(playerid, $CLIENT_353x);
	}    
	return 1;
}

//End of File
/* (c) H2O Multiplayer 2018-2020. All rights reserved. */