/*
	SWAT vs Terrorists is a team death-match SA-MP game-mode script. 
	Compatible with SA-MP 0.3.7 and later releases.

	Author: H2O
	Licensed under GNU GPLv3

	(c) 2018-2020 H2O Multiplayer. All rights reserved.
	Website: h2omultiplayer.com

	This file aims to work out class-related content for players
*/

#include <YSI_Coding\y_hooks>

//Support for y_text, load language files...
#include <YSI_Players\y_text> //Y_Less
loadtext mode_text[all], mode_text[client], mode_text[newcs], mode_text[dialogs], mode_text[gametexts];

//A player wants to reselect their class/skin
forward SwitchClass(playerid);
public SwitchClass(playerid) {
	Text_Send(playerid, $SWITCH_CLASS);
	SetPlayerHealth(playerid, 0.0);
	PlayerInfo[playerid][pSelecting] = 1;
	return 1;
}

//---------------
//Carepacks

forward AlterCarepack(i);
public AlterCarepack(i) {
	KillTimer(gCarepackTimer[i]);
	if (IsValidDynamicObject(gCarepackObj[i])) {
		DestroyDynamicObject(gCarepackObj[i]);
	}
	gCarepackObj[i] = INVALID_OBJECT_ID;
	DestroyDynamic3DTextLabel(gCarepack3DLabel[i]);
	DestroyDynamicArea(gCarepackArea[i]);
	gCarepackPos[i][0] = gCarepackPos[i][1] = gCarepackPos[2][0] = 0.0;
	gCarepackExists[i] = 0;
	return 1;
}

forward OnCarepackForwarded(callid);
public OnCarepackForwarded(callid) {
	new Float: X = gCarepackPos[callid][0];
	new Float: Y = gCarepackPos[callid][1];
	new Float: Z = gCarepackPos[callid][2] + 7.174264;

	gCarepackObj[callid] = CreateDynamicObject(18849, X, Y, (Z - 7.174264) + 15.0, 0.0, 0.0, 0.0);
	MoveDynamicObject(gCarepackObj[callid], X, Y, Z, 30.0);

	gCarepackPos[callid][2] -= 7.174264;
	return 1;
}

//---------------
//Flashbang!!

forward DecreaseFlash(playerid);
public DecreaseFlash(playerid) {
	if (pFlashLvl[playerid] > 0) {
		switch (pFlashLvl[playerid]) {

			case 10: {

				PlayerTextDrawBoxColor(playerid, FlashTD[playerid], 0xFFFFFFE6);
				PlayerTextDrawShow(playerid, FlashTD[playerid]);
			}
			case 9: {

				PlayerTextDrawBoxColor(playerid, FlashTD[playerid], 0xFFFFFFCD);
				PlayerTextDrawShow(playerid, FlashTD[playerid]);
			}
			case 8: {

				PlayerTextDrawBoxColor(playerid, FlashTD[playerid], 0xFFFFFFB4);
				PlayerTextDrawShow(playerid, FlashTD[playerid]);
			}
			case 7: {

				PlayerTextDrawBoxColor(playerid, FlashTD[playerid], 0xFFFFFF9B);
				PlayerTextDrawShow(playerid, FlashTD[playerid]);
			}
			case 6: {

				PlayerTextDrawBoxColor(playerid, FlashTD[playerid], 0xFFFFFF82);
				PlayerTextDrawShow(playerid, FlashTD[playerid]);
			}
			case 5: {

				PlayerTextDrawBoxColor(playerid, FlashTD[playerid], 0xFFFFFF69);
				PlayerTextDrawShow(playerid, FlashTD[playerid]);
			}
			case 4: {

				PlayerTextDrawBoxColor(playerid, FlashTD[playerid], 0xFFFFFF50);
				PlayerTextDrawShow(playerid, FlashTD[playerid]);
			}
			case 3: {

				PlayerTextDrawBoxColor(playerid, FlashTD[playerid], 0xFFFFFF37);
				PlayerTextDrawShow(playerid, FlashTD[playerid]);
			}
			case 2: {

				PlayerTextDrawBoxColor(playerid, FlashTD[playerid], 0xFFFFFF1E);
				PlayerTextDrawShow(playerid, FlashTD[playerid]);
			}
			case 1: {

				PlayerTextDrawBoxColor(playerid, FlashTD[playerid], 0xFFFFFF05);
				PlayerTextDrawShow(playerid, FlashTD[playerid]);
			}
		}
		pFlashLvl[playerid] --;
		SetTimerEx("DecreaseFlash", 500, false, "d", playerid);
	}
	else
	{

		PlayerTextDrawHide(playerid, FlashTD[playerid]);
		PlayerTextDrawBoxColor(playerid, FlashTD[playerid], 0xFFFFFFFF);
		UpdateLabelText(playerid);
	}
	return 1;
}

//There is a class that executes this callback to explode said vehicle ID
//Need to identify that class, I seem to forget things too quick
forward ExplodeCar(playerid, carid);
public ExplodeCar(playerid, carid) {
	new Float: X, Float: Y, Float: Z;
	GetVehiclePos(carid, X, Y, Z);
	CreateExplosion(X, Y, Z, 7, 10.0);
	SetVehicleHealth(carid, 0.0);
	
	foreach(new i: Player) {
		if (i != playerid && IsPlayerInRangeOfPoint(i, 15.0, X, Y, Z) && pTeam[i] != pTeam[playerid]
				&& GetPlayerState(i) != PLAYER_STATE_SPECTATING) {
			new Float: iX, Float: iY, Float: iZ;
			GetPlayerPos(i, iX, iY, iZ);

			CreateExplosion(iX, iY, iZ, 1, 0.3);
			CreateExplosion(iX, iY, iZ, 1, 0.3);

			Text_Send(i, $PLAYER_BOMBEDBY, PlayerInfo[playerid][PlayerName], playerid);
			Text_Send(playerid, $PLAYER_BOMBED, PlayerInfo[i][PlayerName], i);

			GivePlayerCash(playerid, 5000);
			DamagePlayer(i, 0.0, playerid, WEAPON_EXPLOSION, BODY_PART_UNKNOWN, false);
		}
	}
	return 1;
}

//Explode the dynamite object on said slot
forward DynamiteExplosion(dyn_slot);
public DynamiteExplosion(dyn_slot) { 
	CreateExplosion(gDynamitePos[dyn_slot][0], gDynamitePos[dyn_slot][1], gDynamitePos[dyn_slot][2], 1, 0.3);

	new playerid = INVALID_PLAYER_ID;
	foreach (new i: Player) {
		if (gDynamitePlacer[dyn_slot] == i
				&& i != playerid) {
			playerid = i;
			break;
		}
	}

	if (playerid != INVALID_PLAYER_ID) {
		new pdefender = INVALID_PLAYER_ID;

		foreach (new i: Player) {
			if (GetPlayerState(i) == PLAYER_STATE_ONFOOT && !GetPlayerInterior(i) && !GetPlayerVirtualWorld(i)
				&& pTeam[i] == SWAT) {
				new keys, ud, lr;
				GetPlayerKeys(i, keys, ud, lr);
				if ((keys & KEY_YES) && IsPlayerInDynamicArea(i, gDynamiteArea[dyn_slot])) {
					pdefender = i;
					break;
				}
			}
		}
	
		if (pdefender != INVALID_PLAYER_ID) {
			Text_Send(playerid, $SWAT_DEFUSE);
			Text_Send(pdefender, $SWAT_DEFUSEPLAYER, PlayerInfo[playerid][PlayerName], playerid);
			GivePlayerScore(pdefender, 1); 
			return 1;
		}

		foreach (new i: Player) {
			if (IsPlayerInDynamicArea(i, gDynamiteArea[dyn_slot])) {
				if (i != playerid && pTeam[i] != pTeam[playerid] && GetPlayerState(i) != PLAYER_STATE_SPECTATING) {
					new Float: X, Float: Y, Float: Z;
					GetPlayerPos(i, X, Y, Z);
					CreateExplosion(X, Y, Z, 1, 0.3);
					CreateExplosion(X, Y, Z, 1, 0.3);				
					Text_Send(i, $PLAYER_BOMBEDBY, PlayerInfo[playerid][PlayerName], playerid);
					Text_Send(playerid, $PLAYER_BOMBED, PlayerInfo[i][PlayerName], i);
					GivePlayerCash(playerid, 5000);
					DamagePlayer(i, 0.0, playerid, WEAPON_EXPLOSION, BODY_PART_UNKNOWN, false);
				}
			}
		}

		for (new i = 0; i < sizeof(AntennaInfo); i++) {
			if (GetDistance(AntennaInfo[i][Antenna_Pos][0], AntennaInfo[i][Antenna_Pos][1], AntennaInfo[i][Antenna_Pos][2],
					gDynamitePos[dyn_slot][0], gDynamitePos[dyn_slot][1], gDynamitePos[dyn_slot][2]) < 10.0
					&& AntennaInfo[i][Antenna_Exists] == 1 && pTeam[playerid] != i) {
				AntennaInfo[i][Antenna_Hits] += 5001;

				new title[100];

				new Float: hp = floatdiv(5000 - AntennaInfo[i][Antenna_Hits], 5000) * 100;
				new color[9];
				if (hp > 70.0) {
					color = ""GREEN"";
				} else if (hp <= 70.0 && hp > 50.0) {
					color = ""YELLOW"";
				} else if (hp <= 50.0 && hp > 25.0) {
					color = ""ORANGE"";
				} else if (hp <= 25.0) {
					color = ""RED2"";
				}
				format(title, sizeof(title), "%s\n"IVORY"Radio Antenna\n%s%0.2f%%", TeamInfo[i][Team_Name], color, hp);
				UpdateDynamic3DTextLabelText(AntennaInfo[i][Antenna_Label], TeamInfo[i][Team_Color], title);

				if (AntennaInfo[i][Antenna_Hits] >= 5001) {		
					Text_Send(playerid, $ANTENNA_DESTROYED);
					GivePlayerScore(playerid, 10);

					Text_Send(@pVerified, $SERVER_36x, PlayerInfo[playerid][PlayerName], TeamInfo[i][Team_Name]);

					new crate = random(100);
					switch (crate) {
						case 0..25: {
							PlayerInfo[playerid][pCrates] ++;
							Text_Send(playerid, $CRATE_RECEIVED);
						}
					}

					format(title, sizeof(title), "%s\n"IVORY"Radio Antenna\n"RED2"Offline", TeamInfo[i][Team_Name]);
					UpdateDynamic3DTextLabelText(AntennaInfo[i][Antenna_Label], TeamInfo[i][Team_Color], title);					
					
					if (WarInfo[War_Started] == 1) {
						if ((pTeam[playerid] == WarInfo[War_Team1] && i == WarInfo[War_Team2]) ||
						(pTeam[playerid] == WarInfo[War_Team2] && i == WarInfo[War_Team1])) {
							AddTeamWarScore(playerid, 1);
						}
					}

					foreach (new j: Player) {
						if (pTeam[j] == i && !GetPlayerInterior(j) && !GetPlayerVirtualWorld(j) && IsPlayerSpawned(j)) {
							GivePlayerCash(j, -2000);
							GivePlayerScore(j, -1);
								
							Text_Send(j, $LOST_ANTENNA);
							PlayerPlaySound(j, 1057, 0.0, 0.0, 0.0);
						}
					}

					PlayerInfo[playerid][pEXPEarned] += 1;
					AntennaInfo[i][Antenna_Exists] = 0;

					SetDynamicObjectPos(AntennaInfo[i][Antenna_Id], AntennaInfo[i][Antenna_Pos][0], AntennaInfo[i][Antenna_Pos][1], AntennaInfo[i][Antenna_Pos][2] - 10.0);

					CreateExplosion(AntennaInfo[i][Antenna_Pos][0], AntennaInfo[i][Antenna_Pos][1], AntennaInfo[i][Antenna_Pos][2], 4, 3.0);
					CreateExplosion(AntennaInfo[i][Antenna_Pos][0], AntennaInfo[i][Antenna_Pos][1], AntennaInfo[i][Antenna_Pos][2] + 5, 4, 3.0);
					CreateExplosion(AntennaInfo[i][Antenna_Pos][0], AntennaInfo[i][Antenna_Pos][1], AntennaInfo[i][Antenna_Pos][2] + 10, 4, 3.0);

					AntennaInfo[i][Antenna_Kill_Time] = gettime() + 250;
					return 0;			
				}

				break;
			}
		}
	}

	AlterDynamite(dyn_slot);
	return 1;
}

//Supporter class function - support nearby players with ammunition
SupportAmmo(playerid) {
	if (pDuelInfo[playerid][pDInMatch] == 1) return Text_Send(playerid, $COMMAND_INDUEL);
	if (PlayerInfo[playerid][pDeathmatchId] > -1) return Text_Send(playerid, $COMMAND_INDM);
	if (Iter_Contains(ePlayers, playerid)) return Text_Send(playerid, $COMMAND_INEVENT);
	if (Iter_Contains(CWCLAN1, playerid) || Iter_Contains(CWCLAN2, playerid)) return Text_Send(playerid, $COMMAND_INCW);
	if (Iter_Contains(PUBGPlayers, playerid)) return Text_Send(playerid, $COMMAND_INPUBG);
	if (PlayerInfo[playerid][pLoggedIn] == 1) {
		if (pClass[playerid] == SUPPORT) {
			if (pCooldown[playerid][2] < gettime()) {
				new Float:x, Float:y, Float:z;
				GetPlayerPos(playerid, x, y, z);
				
				new count = 0;

				foreach (new i: Player) {
					new Float: extrarange = 0.0;
					if (pAdvancedClass[playerid]) {
						extrarange = 5.0;
					}
					if (i != playerid && IsPlayerInRangeOfPoint(i, 10.0 + extrarange, x, y, z) && pTeam[playerid] == pTeam[i]
						&& !GetPlayerInterior(i) && !GetPlayerVirtualWorld(i) && IsPlayerSpawned(i)) {
						AddAmmo(i);

						PlayerInfo[playerid][pSupportAttempts]++;

						GivePlayerScore(playerid, 1);
						Text_Send(playerid, $PLAYER_SUPPORTED, PlayerInfo[i][PlayerName], i);						
						Text_Send(i, $SUPPORTED_AMMO, PlayerInfo[playerid][PlayerName], playerid);

						count ++;
					}
				}
				
				if (!count) {
					Text_Send(playerid, $NO_NEARBY_SUPPORTER);
				}
				else {
					pCooldown[playerid][2] = gettime() + 85;
				}
			} else {
				Text_Send(playerid, $COOLDOWN_TIMELEFT, pCooldown[playerid][2] - gettime());
			}
		}  else Text_Send(playerid, $MUSTBE_SUPPORTER);
	}
	return 1;
}

//With weapons
SupportWeaps(playerid) {
	if (pDuelInfo[playerid][pDInMatch] == 1) return Text_Send(playerid, $COMMAND_INDUEL);
	if (PlayerInfo[playerid][pDeathmatchId] > -1) return Text_Send(playerid, $COMMAND_INDM);
	if (Iter_Contains(ePlayers, playerid)) return Text_Send(playerid, $COMMAND_INEVENT);
	if (Iter_Contains(CWCLAN1, playerid) || Iter_Contains(CWCLAN2, playerid)) return Text_Send(playerid, $COMMAND_INCW);
	if (Iter_Contains(PUBGPlayers, playerid)) return Text_Send(playerid, $COMMAND_INPUBG);
	if (PlayerInfo[playerid][pLoggedIn] == 1) {
		if (pClass[playerid] == SUPPORT) {
			if (pCooldown[playerid][14] < gettime()) {
				new Float:x, Float:y, Float:z;
				GetPlayerPos(playerid, x, y, z);
				
				new count = 0;

				foreach (new i: Player) {
					new Float: extrarange = 0.0;
					if (pAdvancedClass[playerid]) {
						extrarange = 5.0;
					}
					if (i != playerid && IsPlayerInRangeOfPoint(i, 10.0 + extrarange, x, y, z) && pTeam[playerid] == pTeam[i]
						&& !GetPlayerInterior(i) && !GetPlayerVirtualWorld(i) && IsPlayerSpawned(i)) {
						GivePlayerWeapon(i, 24, 50);
						GivePlayerWeapon(i, 27, 50);
						GivePlayerWeapon(i, 32, 50);
						GivePlayerWeapon(i, 7, 2);
						PlayerInfo[playerid][pSupportAttempts]++;

						GivePlayerScore(playerid, 1);
						Text_Send(playerid, $PLAYER_SUPPORTED, PlayerInfo[i][PlayerName], i);
						Text_Send(i, $SUPPORTED_WEAP, PlayerInfo[playerid][PlayerName], playerid);

						count ++;
					}
				}
				
				if (!count) {
					Text_Send(playerid, $NO_NEARBY_SUPPORTER);
				}
				else {
					pCooldown[playerid][14] = gettime() + 85;
				}
			} else {
				Text_Send(playerid, $COOLDOWN_TIMELEFT, pCooldown[playerid][14] - gettime());
			}
		}  else Text_Send(playerid, $MUSTBE_SUPPORTER);
	}
	return 1;
}

//Heal them
SupportHealth(playerid) {
	if (pDuelInfo[playerid][pDInMatch] == 1) return Text_Send(playerid, $COMMAND_INDUEL);
	if (PlayerInfo[playerid][pDeathmatchId] > -1) return Text_Send(playerid, $COMMAND_INDM);
	if (Iter_Contains(ePlayers, playerid)) return Text_Send(playerid, $COMMAND_INEVENT);
	if (Iter_Contains(CWCLAN1, playerid) || Iter_Contains(CWCLAN2, playerid)) return Text_Send(playerid, $COMMAND_INCW);
	if (Iter_Contains(PUBGPlayers, playerid)) return Text_Send(playerid, $COMMAND_INPUBG);
	if (PlayerInfo[playerid][pLoggedIn] == 1) {
		if (pClass[playerid] == SUPPORT) {
			if (pCooldown[playerid][17] < gettime()) {
				new Float:x, Float:y, Float:z;
				GetPlayerPos(playerid, x, y, z);

				new count = 0;

				foreach (new i: Player) {
					new Float: extrarange = 0.0;
					if (pAdvancedClass[playerid]) {
						extrarange = 5.0;
					}
					if (i != playerid && IsPlayerInRangeOfPoint(i, 10.0 + extrarange, x, y, z) && pTeam[playerid] == pTeam[i]
						&& !GetPlayerInterior(i) && !GetPlayerVirtualWorld(i) && IsPlayerSpawned(i)) {
						SetPlayerHealth(i, 100.0);
						PlayerInfo[playerid][pSupportAttempts]++;

						GivePlayerScore(playerid, 1);
						Text_Send(playerid, $PLAYER_SUPPORTED, PlayerInfo[i][PlayerName], i);
						Text_Send(i, $SUPPORTED_HEALTH, PlayerInfo[playerid][PlayerName], playerid);

						count ++;
					}
				}

				if (!count) {
					Text_Send(playerid, $NO_NEARBY_SUPPORTER);
				}
				else {
					pCooldown[playerid][17] = gettime() + 85;
				}
			} else {
				Text_Send(playerid, $COOLDOWN_TIMELEFT, pCooldown[playerid][17] - gettime());
			}
		}  else Text_Send(playerid, $MUSTBE_SUPPORTER);
	}
	return 1;
}

//Fix their armour
SupportArmour(playerid) {
	if (pDuelInfo[playerid][pDInMatch] == 1) return Text_Send(playerid, $COMMAND_INDUEL);
	if (PlayerInfo[playerid][pDeathmatchId] > -1) return Text_Send(playerid, $COMMAND_INDM);
	if (Iter_Contains(ePlayers, playerid)) return Text_Send(playerid, $COMMAND_INEVENT);
	if (Iter_Contains(CWCLAN1, playerid) || Iter_Contains(CWCLAN2, playerid)) return Text_Send(playerid, $COMMAND_INCW);
	
	if (Iter_Contains(PUBGPlayers, playerid)) return Text_Send(playerid, $COMMAND_INPUBG);
	if (PlayerInfo[playerid][pLoggedIn] == 1) {
		if (pClass[playerid] == SUPPORT) {
			if (pCooldown[playerid][17] < gettime()) {
				new Float:x, Float:y, Float:z;
				GetPlayerPos(playerid, x, y, z);

				new count = 0;

				foreach (new i: Player) {
					new Float: extrarange = 0.0;
					if (pAdvancedClass[playerid]) {
						extrarange = 5.0;
					}
					if (i != playerid && IsPlayerInRangeOfPoint(i, 10.0 + extrarange, x, y, z) && pTeam[playerid] == pTeam[i]
						&& !GetPlayerInterior(i) && !GetPlayerVirtualWorld(i) && IsPlayerSpawned(i)) {
						SetPlayerArmour(i, 100.0);
						PlayerInfo[playerid][pSupportAttempts]++;

						GivePlayerScore(playerid, 1);
						Text_Send(playerid, $PLAYER_SUPPORTED, PlayerInfo[i][PlayerName], i);
						Text_Send(i, $SUPPORTED_ARMOUR, PlayerInfo[playerid][PlayerName], playerid);

						count ++;
					}
				}
				
				if (!count) {
					Text_Send(playerid, $NO_NEARBY_SUPPORTER);
				}
				else {
					pCooldown[playerid][17] = gettime() + 85;
				}
			} else {
				Text_Send(playerid, $COOLDOWN_TIMELEFT, pCooldown[playerid][17] - gettime());
			}
		}  else Text_Send(playerid, $MUSTBE_SUPPORTER);
	}
	return 1;
}

//Return a player's class name (depends on the advanced level)
GetPlayerClass(playerid) {
	new string[30];
	if (pAdvancedClass[playerid]) {
		format(string, sizeof(string), "%s", ClassInfo[pClass[playerid]][aClass_Name]);
	} else {
		format(string, sizeof(string), "%s", ClassInfo[pClass[playerid]][Class_Name]);
	}
	return string;
}

//Show the player the class selection core
ShowPlayerClass(playerid) {
	new string[900];
	format(string, sizeof(string), "Class\tRank\tScore\tStatus\n");

	for (new i = 0; i < sizeof(ClassInfo); i++) {
		if (ClassInfo[i][Class_Score] > GetPlayerScore(playerid)) {
			format(string, sizeof(string), "%s%s\t%d\t%d\t"RED"Locked\n",
				string, ClassInfo[i][Class_Name], GetRankByScore(ClassInfo[i][Class_Score]), ClassInfo[i][Class_Score]);
		}
		else
		{
			if (ClassInfo[i][Class_Score] != 0) {
				format(string, sizeof(string), "%s%s\t%d\t%d\t"LIGHTGREEN"Unlocked\n",
					string, ClassInfo[i][Class_Name], GetRankByScore(ClassInfo[i][Class_Score]), ClassInfo[i][Class_Score]);
			} else {
				format(string, sizeof(string), "%s%s\t%d\tN/A\t"LIGHTCYAN"Unlocked\n",
					string, ClassInfo[i][Class_Name], GetRankByScore(ClassInfo[i][Class_Score]));
			}
		}
	}
	
	inline AdvancedClassSystem(pid, dialogid, response, listitem, string:inputtext[]) {
		#pragma unused dialogid, inputtext
		if (!response) {
			PlayerInfo[pid][pSelecting] = 0;
			SetSpawnDetails(pid);
			pAdvancedClass[pid] = false;
			CancelSelectTextDraw(pid);
			SpawnPlayer(pid);
			return 1;
		}

		if (listitem && PlayerInfo[pid][pEXPEarned] < ClassInfo[pClass[pid]][Class_XP]) {
			ShowPlayerClass(pid);
			Text_Send(pid, $EXP_NEEDED);
			return 1;
		}

		PlayerInfo[pid][pSelecting] = 0;
		SetSpawnDetails(pid);
		if (listitem) {
			pAdvancedClass[pid] = true;
		} else {
			pAdvancedClass[pid] = false;
		}

		CancelSelectTextDraw(pid);
		SpawnPlayer(pid);
	}

	inline ClassSystem(pid, dialogid, response, listitem, string:inputtext[]) {
		#pragma unused dialogid, inputtext
		if (!response) {
			PlayerInfo[pid][pSelecting] = 0;
			SetSpawnDetails(pid);
			pClass[pid] = ASSAULT;
			pAdvancedClass[pid] = false;

			format(string, sizeof(string), "%s%s", TeamInfo[pTeam[pid]][Chat_Bub], TeamInfo[pTeam[pid]][Team_Name]);
			GameTextForPlayer(pid, string, 1000, 3);
			CancelSelectTextDraw(pid);
			SpawnPlayer(pid);
			
			Text_Send(pid, $HINT_SC);
			return 1;
		}

		if (GetPlayerScore(pid) < ClassInfo[listitem][Class_Score]) {
			ShowPlayerClass(pid);
			Text_Send(pid, $CLASS_SCORE_NEEDED, ClassInfo[listitem][Class_Score] - GetPlayerScore(pid));
			return 1;
		}

		pClass[pid] = listitem;
		pAdvancedClass[pid] = false;

		format(string, sizeof(string), "Class\tXP Needed\tStatus\n");

		format(string, sizeof(string), "%s%s\tN/A\t"LIGHTCYAN"Unlocked\n", string, ClassInfo[pClass[pid]][Class_Name]);

		if (ClassInfo[pClass[pid]][Class_XP] > PlayerInfo[pid][pEXPEarned]) {
			format(string, sizeof(string), "%s%s\t%d\t"RED"Locked\n",
				string, ClassInfo[pClass[pid]][aClass_Name], ClassInfo[pClass[pid]][Class_XP]);
		} else {
			format(string, sizeof(string), "%s%s\t%d\t"LIGHTGREEN"Unlocked\n",
				string, ClassInfo[pClass[pid]][aClass_Name], ClassInfo[pClass[pid]][Class_XP]);
		}

		Dialog_ShowCallback(pid, using inline AdvancedClassSystem, DIALOG_STYLE_TABLIST_HEADERS, ""RED2"SvT - Select Class", string, ">>", "X");
	}

	Dialog_ShowCallback(playerid, using inline ClassSystem, DIALOG_STYLE_TABLIST_HEADERS, ""RED2"SvT - Select Class", string, ">>", "");
	return 1;
}

//Medic feature, heal nearby players
HealClosePlayers(playerid) {
	if (pDuelInfo[playerid][pDInMatch] == 1) return Text_Send(playerid, $COMMAND_INDUEL);
	if (PlayerInfo[playerid][pDeathmatchId] > -1) return Text_Send(playerid, $COMMAND_INDM);
	if (Iter_Contains(ePlayers, playerid)) return Text_Send(playerid, $COMMAND_INEVENT);
	if (Iter_Contains(CWCLAN1, playerid) || Iter_Contains(CWCLAN2, playerid)) return Text_Send(playerid, $COMMAND_INCW);

	if (Iter_Contains(PUBGPlayers, playerid)) return Text_Send(playerid, $COMMAND_INPUBG);
	if (PlayerInfo[playerid][pLoggedIn] == 1) {
		if (pClass[playerid] == MEDIC) {
			if (pCooldown[playerid][17] < gettime()) {
				new Float:x, Float:y, Float:z;
				GetPlayerPos(playerid, x, y, z);

				new count = 0;
				
				new Float:r = 7.5;
				if (pAdvancedClass[playerid]) {
					r = 15.0;
				}

				foreach (new i: Player) {
					if (i != playerid && IsPlayerInRangeOfPoint(i, r, x, y, z) && pTeam[playerid] == pTeam[i]
						&& !GetPlayerInterior(i) && !GetPlayerVirtualWorld(i) && IsPlayerSpawned(i)) {
						SetPlayerHealth(i, 100.0);

						PlayerInfo[playerid][pSupportAttempts]++;
						PlayerInfo[playerid][pPlayersHealed] ++;

						GivePlayerScore(playerid, 1);
						Text_Send(playerid, $PLAYER_MEDIC_SUPPORTED, PlayerInfo[i][PlayerName], i);
						Text_Send(i, $PLAYER_MEDIC_SUPPORTED, PlayerInfo[playerid][PlayerName]);

						count ++;
					}
				}

				if (!count) {
					Text_Send(playerid, $NO_NEARBY_SUPPORTER);
				}
				else {
					pCooldown[playerid][17] = gettime() + 50;
				}
			} else {
				Text_Send(playerid, $COOLDOWN_TIMELEFT, pCooldown[playerid][17] - gettime());
			}
		}  else Text_Send(playerid, $MEDIC_NEEDED);
	}
	return 1;
}

//And here
hook OnPlayerUpdate(playerid) {
	new keys, ud, lr;
	GetPlayerKeys(playerid, keys, ud, lr);
	
	if (keys & KEY_FIRE) {
		if (GetPlayerWeapon(playerid) == WEAPON_SPRAYCAN && GetPlayerState(playerid) == PLAYER_STATE_ONFOOT &&
			pClass[playerid] == MECHANIC) {
			for (new i = 0; i < MAX_VEHICLES; i++) {
				new Float: X, Float: Y, Float: Z;
				GetVehiclePos(i, X, Y, Z);
				if (IsPlayerInRangeOfPoint(playerid, 12.5, X, Y, Z)) {
					new Float: vHP;
					GetVehicleHealth(i, vHP);
					SetPlayerLookAt(playerid, X, Y);
					if (vHP < 900.0) {
						if (pAdvancedClass[playerid]) {
							vHP += 5.00;
						}
						SetVehicleHealth(i, vHP + RandomEx(5, 10));
					} else if (vHP >= 900.0 && vHP < 1000.0) {
						SetVehicleHealth(i, 1000.0);
						RepairVehicle(i);
						Text_Send(playerid, $VEH_REPAIRED);
					}
				}
			}
		}
	}

	if (pClass[playerid] == MEDIC && pAdvancedClass[playerid]) {
		if (PlayerInfo[playerid][pLastHitTick] <= gettime() && gMedicTick[playerid] <= GetTickCount()) {
			new Float: HP;
			GetPlayerHealth(playerid, HP);
			if (HP <= 95.0) {
				HP += 5.0;
				SetPlayerHealth(playerid, HP);
				Text_Send(playerid, $DOCTOR_HPB);
				SetPlayerChatBubble(playerid, "+5 HP (Doctor Class)", X11_LIMEGREEN, 100.0, 3000);
				gMedicTick[playerid] = GetTickCount() + 30000;
				PlayerInfo[playerid][pHealthGained] += 5.0;
			}
		}
	}
	return 1;
}

//Hook some stuff here too
hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
	if (PRESSED(KEY_YES)) {
		if (GetPlayerState(playerid) == PLAYER_STATE_ONFOOT && GetPlayerInterior(playerid) == 0 && GetPlayerVirtualWorld(playerid) == 0) {
			if (pClass[playerid] == SUPPORT) {
				inline SupportClass(pid, dialogid, response, listitem, string:inputtext[]) {
					#pragma unused dialogid, inputtext
					if (response) {
						switch (listitem) {
							case 0: SupportHealth(pid);
							case 1: SupportArmour(pid);
							case 2: SupportWeaps(pid);
							case 3: SupportAmmo(pid);
						}
					}
				}
				Text_DialogBox(playerid, DIALOG_STYLE_LIST, using inline SupportClass, $SUPPORT_MENU_CAP, $SUPPORT_MENU_DESC, $DIALOG_CONFIRM, $DIALOG_CLOSE);
			}

			if (GetPlayerScore(playerid) >= 25000) {
				foreach (new i: Player) {
					new Float: X, Float: Y, Float: Z;
					GetPlayerPos(playerid, X, Y, Z);
					if (IsPlayerInRangeOfPoint(i, 3.0, X, Y, Z) && i != playerid && pItems[i][HELMET]) {
						RemovePlayerItem(i, HELMET);
					}
				}
			}
			
			if (pClass[playerid] == SCOUT) {
				if (GetPlayerSpeed(playerid) > 15) return 1;
				if (pCooldown[playerid][38] > gettime()) {
					Text_Send(playerid, $CLIENT_407x, pCooldown[playerid][38] - gettime());
					return 1;
				}
				
				new Float: pPos[3];
				GetPlayerPos(playerid, pPos[0], pPos[1], pPos[2]);
				
				new Float: range = 20.0;
				if (pAdvancedClass[playerid]) range = 30.0;
				pCooldown[playerid][38] = gettime() + 15;
				Text_Send(playerid, $FLASHBANG);
				foreach (new i: Player) {
					if (pTeam[playerid] != pTeam[i]) {
						if (IsPlayerInRangeOfPoint(i, range, pPos[0], pPos[1], pPos[2])
						&& !GetPlayerInterior(i) && !GetPlayerVirtualWorld(i) && IsPlayerSpawned(i)) {
							PlayerInfo[playerid][pFlashBangedPlayers] ++;
							PlayerTextDrawShow(i, FlashTD[i]);
							pFlashLvl[i] = 10;
							PlayAudioStreamForPlayer(i, "https://www.h2omultiplayer.com/server/vrc.mp3", 0, 0, 0, 0, 0);
							UpdateLabelText(i);
							SetPlayerDrunkLevel(i, 2500);
							SetTimerEx("DecreaseFlash", 600, false, "d", i);
							Text_Send(i, $FLASHBANGED);
						}
					}
				}
			}
		}
	}
	return 1;
}

//Hook some stuff here
hook OnPlayerStateChange(playerid, newstate, oldstate) {
	//Class-related vehicle restrictions
	if (newstate != PLAYER_STATE_DRIVER) return true;
	switch (GetVehicleModel(GetPlayerVehicleID(playerid))) {
		case 432:
		{
			if (!Iter_Contains(ePlayers, playerid) && PlayerInfo[playerid][pAdminDuty] != 1 && PlayerInfo[playerid][pDeathmatchId] != 7) {
				if (pClass[playerid] != ASSAULT || !pAdvancedClass[playerid]) {
					Text_Send(playerid, $RHINO_ERROR);
					RemovePlayerFromVehicle(playerid);
					ShowCarInfo(playerid, "Rhino", "Shoot enemies using rhino's rockets.", "Rifleman Class");
					PlayerPlaySound(playerid, 1095, 0.0, 0.0, 0.0);
				}	
			}
		}
		case 447:
		{
			if (!pItems[playerid][PL] && !Iter_Contains(ePlayers, playerid) && !PlayerInfo[playerid][pAdminDuty] && !PlayerInfo[playerid][pDonorLevel]) {
				if ((pClass[playerid] != JETTROOPER || !pAdvancedClass[playerid])) {
					if (pClass[playerid] != PILOT) {
						Text_Send(playerid, $SEASP_ERROR);
						RemovePlayerFromVehicle(playerid);
						PlayerPlaySound(playerid, 1095, 0.0, 0.0, 0.0);
					}
				}
			}
			if (pClass[playerid] == PILOT && pAdvancedClass[playerid]) {
				new Float: VHP;
				GetVehicleHealth(GetPlayerVehicleID(playerid), VHP);
				SetVehicleHealth(GetPlayerVehicleID(playerid), VHP + 500);
				SetPlayerChatBubble(playerid, "+500 health on sea sparrow", X11_BLUE, 120.0, 10000);
				PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
			}
		}
		case 520:
		{
			if (!pItems[playerid][PL] && !Iter_Contains(ePlayers, playerid) && !PlayerInfo[playerid][pAdminDuty] && !PlayerInfo[playerid][pDonorLevel]) {		    		
				if (pClass[playerid] != PILOT) {
					Text_Send(playerid, $HYDRA_ERROR);
					RemovePlayerFromVehicle(playerid);
					PlayerPlaySound(playerid, 1095, 0.0, 0.0, 0.0);
				}
			}
			if (pClass[playerid] == PILOT && pAdvancedClass[playerid]) {
				new Float: VHP;
				GetVehicleHealth(GetPlayerVehicleID(playerid), VHP);
				SetVehicleHealth(GetPlayerVehicleID(playerid), VHP + 500);
				SetPlayerChatBubble(playerid, "+500 health on hydra", X11_BLUE, 120.0, 10000);
				PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
			}
		}
		case 425:
		{
			if (!pItems[playerid][PL] && !Iter_Contains(ePlayers, playerid) && !PlayerInfo[playerid][pAdminDuty] && !PlayerInfo[playerid][pDonorLevel]) {
				if (pClass[playerid] != PILOT) {
					Text_Send(playerid, $HUNTER_ERROR);
					RemovePlayerFromVehicle(playerid);
					PlayerPlaySound(playerid, 1095, 0.0, 0.0, 0.0);
				}
			}
			if (pClass[playerid] == PILOT && pAdvancedClass[playerid]) {
				new Float: VHP;
				GetVehicleHealth(GetPlayerVehicleID(playerid), VHP);
				SetVehicleHealth(GetPlayerVehicleID(playerid), VHP + 500);
				SetPlayerChatBubble(playerid, "+500 health on hunter", X11_BLUE, 120.0, 10000);
				PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
			}
		}
		case 476:
		{
			if (!pItems[playerid][PL] && !Iter_Contains(ePlayers, playerid) && !PlayerInfo[playerid][pAdminDuty] && !PlayerInfo[playerid][pDonorLevel]) {
				if (pClass[playerid] != PILOT) {
					Text_Send(playerid, $RUSTLER_ERROR);
					RemovePlayerFromVehicle(playerid);
					PlayerPlaySound(playerid, 1095, 0.0, 0.0, 0.0);
				}
			}
			if (pClass[playerid] == PILOT && pAdvancedClass[playerid]) {
				new Float: VHP;
				GetVehicleHealth(GetPlayerVehicleID(playerid), VHP);
				SetVehicleHealth(GetPlayerVehicleID(playerid), VHP + 500);
				SetPlayerChatBubble(playerid, "+500 health on rustler", X11_BLUE, 120.0, 10000);
				PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
			}
		}
		case 512:
		{
			if (!pItems[playerid][PL] && !Iter_Contains(ePlayers, playerid) && !PlayerInfo[playerid][pAdminDuty] && !PlayerInfo[playerid][pDonorLevel]) {
				if (pClass[playerid] != PILOT) {
					Text_Send(playerid, $CROPDUST_ERROR);
					RemovePlayerFromVehicle(playerid);
					PlayerPlaySound(playerid, 1095, 0.0, 0.0, 0.0);
				}
			}
			if (pClass[playerid] == PILOT && pAdvancedClass[playerid]) {
				new Float: VHP;
				GetVehicleHealth(GetPlayerVehicleID(playerid), VHP);
				SetVehicleHealth(GetPlayerVehicleID(playerid), VHP + 500);
				SetPlayerChatBubble(playerid, "+500 health on cropduster", X11_BLUE, 120.0, 10000);
				PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
			}
		}
		case 553:
		{
			if (!pItems[playerid][PL] && !Iter_Contains(ePlayers, playerid) && !PlayerInfo[playerid][pAdminDuty] && !PlayerInfo[playerid][pDonorLevel]) {
				if (pClass[playerid] != PILOT) {
					Text_Send(playerid, $NEVADA_ERROR);
					RemovePlayerFromVehicle(playerid);
					PlayerPlaySound(playerid, 1095, 0.0, 0.0, 0.0);
				}
			}
			if (pClass[playerid] == PILOT && pAdvancedClass[playerid]) {
				new Float: VHP;
				GetVehicleHealth(GetPlayerVehicleID(playerid), VHP);
				SetVehicleHealth(GetPlayerVehicleID(playerid), VHP + 500);
				SetPlayerChatBubble(playerid, "+500 health on nevada", X11_BLUE, 120.0, 10000);
				PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
			}
		}
	}
	return 1;
}

hook OnPlayerEnterVehicle(playerid, vehicleid, ispassenger) {
	if (pClass[playerid] == ASSAULT && pAdvancedClass[playerid] && GetVehicleModel(vehicleid) == 432) {
		SetPlayerChatBubble(playerid, "+150 Rhino HP", X11_YELLOW, 100.0, 2000);

		new Float: VHP;
		GetVehicleHealth(vehicleid, VHP);
		SetVehicleHealth(vehicleid, VHP + 150);
	}
	return 1;
}

hook OnDynamicObjectMoved(objectid) {
	for (new i = 0; i < MAX_SLOTS; i++) {
		if (gCarepackExists[i] && gCarepackObj[i] == objectid) {
			gCarepackArea[i] = CreateDynamicCircle(gCarepackPos[i][0], gCarepackPos[i][1], 2.0);
			CA_FindZ_For2DCoord(gCarepackPos[i][0], gCarepackPos[i][1], gCarepackPos[i][2]);

			new Caller[90];
			format(Caller, sizeof(Caller), "Carepack\n"IVORY"Dropped by %s", gCarepackCaller[i]);
			gCarepack3DLabel[i] = CreateDynamic3DTextLabel(Caller, X11_MAROON, gCarepackPos[i][0], gCarepackPos[i][1], gCarepackPos[i][2], 50.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, 0, 0);

			format(gCarepackCaller[i], MAX_PLAYER_NAME, "");
			gCarepackUsable[i] = 1;
			gCarepackTimer[i] = SetTimerEx("AlterCarepack", 50000, false, "i", i);
			
			break;
		}
	}
	return 1;
}

//Class Commands

CMD:suicide(playerid, params[]) {
	if (pDuelInfo[playerid][pDInMatch] == 1) return Text_Send(playerid, $COMMAND_INDUEL);
	if (PlayerInfo[playerid][pDeathmatchId] > -1) return Text_Send(playerid, $COMMAND_INDM);
	if (Iter_Contains(ePlayers, playerid)) return Text_Send(playerid, $COMMAND_INEVENT);
	if (Iter_Contains(CWCLAN1, playerid) || Iter_Contains(CWCLAN2, playerid)) return Text_Send(playerid, $COMMAND_INCW);
	if (!pItems[playerid][DYNAMITE]
		&& pClass[playerid] != DEMOLISHER && pClass[playerid] != SUICIDER) return Text_Send(playerid, $CLIENT_451x);
	if (Iter_Contains(PUBGPlayers, playerid)) return Text_Send(playerid, $COMMAND_INPUBG);
	if (GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) return Text_Send(playerid, $COMMAND_NOTONFOOT);

	new Float: X, Float: Y, Float: Z;
	GetPlayerPos(playerid, X, Y, Z);
	
	new Float: r = 10.0;
	if (pClass[playerid] == SUICIDER) {
		r += 4.5;
		PlayerPlaySound(playerid, 1095, 0.0, 0.0, 0.0);
	} else {
		PlayerPlaySound(playerid, 1095, 0.0, 0.0, 0.0);
	}

	Text_Send(playerid, $SUICIDE_ABILITY);

	foreach (new i: Player) {
		if (i != playerid && IsPlayerInRangeOfPoint(i, r, X, Y, Z)) {
			DamagePlayer(i, 84.1, playerid, WEAPON_EXPLOSION, BODY_PART_UNKNOWN, false);
			Text_Send(i, $SUICIDE_KILLED);
			PlayerPlaySound(i, 1095, 0.0, 0.0, 0.0);
		}
	}

	CreateExplosion(X, Y, Z, 7, 5.0);

	SetPlayerHealth(playerid, 0.0);
	
	if (pClass[playerid] != DEMOLISHER && pClass[playerid] != SUICIDER) {
		AddPlayerItem(playerid, DYNAMITE, -1);
		PlayerInfo[playerid][pItemsUsed] ++;
	} else {
		PlayerInfo[playerid][pClassAbilitiesUsed] ++;
	}
	return 1;
}

CMD:fr(playerid) {
	if (pDuelInfo[playerid][pDInMatch] == 1) return Text_Send(playerid, $COMMAND_INDUEL);
	if (PlayerInfo[playerid][pDeathmatchId] > -1) return Text_Send(playerid, $COMMAND_INDM);
	if (Iter_Contains(ePlayers, playerid)) return Text_Send(playerid, $COMMAND_INEVENT);
	if (Iter_Contains(CWCLAN1, playerid) || Iter_Contains(CWCLAN2, playerid)) return Text_Send(playerid, $COMMAND_INCW);
	if (Iter_Contains(PUBGPlayers, playerid)) return Text_Send(playerid, $COMMAND_INPUBG);

	if (!pItems[playerid][PYROKIT])
		if (pClass[playerid] != DEMOLISHER || !pAdvancedClass[playerid])
			return Text_Send(playerid, $CLIENT_451x);

	if (!IsPlayerInAnyVehicle(playerid)) return Text_Send(playerid, $CLIENT_436x);

	if (pCooldown[playerid][26] < gettime()) {
		pCooldown[playerid][26] = gettime() + 30;
		
		new Float: vX, Float: vY, Float: vZ, count;
		GetVehiclePos(GetPlayerVehicleID(playerid), vX, vY, vZ);
		
		new bool:mega_attack = false, Float: attack_radius = 8.0;
		
		if (pClass[playerid] == DEMOLISHER
			&& pAdvancedClass[playerid]) {
			mega_attack = true;
			attack_radius = 16.0;
		}

		foreach(new i: Player) {
			if (IsPlayerInAnyVehicle(i) && IsPlayerInRangeOfPoint(i, attack_radius, vX, vY, vZ)) {
				SetVehicleHealth(GetPlayerVehicleID(i), 0.0);
				if (!mega_attack) {
					GameTextForPlayer(i, "~r~PYROATTACK!", 3000, 3);
				} else GameTextForPlayer(i, "~r~MEGA PYROATTACK!", 3000, 3);
				if (i != playerid) {
					count ++;

					Text_Send(playerid, $CLIENT_452x, PlayerInfo[i][PlayerName]);
					GivePlayerScore(playerid, 2);

					PlayerPlaySound(playerid, 1095, 0.0, 0.0, 0.0);
					PlayerPlaySound(i, 1095, 0.0, 0.0, 0.0);
				}		
			}
		}

		CreateExplosion(vX, vY, vZ, 7, 7.0);
		if (pClass[playerid] != DEMOLISHER) {
			AddPlayerItem(playerid, PYROKIT, -1), PlayerInfo[playerid][pItemsUsed] ++;
		} else {
			PlayerInfo[playerid][pClassAbilitiesUsed] ++;
		}
	} else {
		Text_Send(playerid, $COOLDOWN_TIMELEFT, pCooldown[playerid][26] - gettime());
	}
	return 1;
}

CMD:drone(playerid, params[]) {
	if (pDuelInfo[playerid][pDInMatch] == 1) return Text_Send(playerid, $COMMAND_INDUEL);
	if (PlayerInfo[playerid][pDeathmatchId] > -1) return Text_Send(playerid, $COMMAND_INDM);
	if (Iter_Contains(ePlayers, playerid)) return Text_Send(playerid, $COMMAND_INEVENT);
	if (pClass[playerid] != RECON || !pAdvancedClass[playerid]) return Text_Send(playerid, $CLIENT_451x);
	if (Iter_Contains(CWCLAN1, playerid) || Iter_Contains(CWCLAN2, playerid)) return Text_Send(playerid, $COMMAND_INCW);
	if (Iter_Contains(PUBGPlayers, playerid)) return Text_Send(playerid, $COMMAND_INPUBG);
	if (IsPlayerInAnyVehicle(playerid)) return Text_Send(playerid, $CLIENT_436x);

	if (pCooldown[playerid][39] > gettime()) {
		Text_Send(playerid, $CLIENT_453x, pCooldown[playerid][39] - gettime());
		return 1;
	}

	pCooldown[playerid][39] = gettime() + 150;
	InDrone[playerid] = true;
	GetPlayerPos(playerid, gDroneLastPos[playerid][0], gDroneLastPos[playerid][1], gDroneLastPos[playerid][2]);
	CarSpawner(playerid, 501);
	PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
	PlayerInfo[playerid][pClassAbilitiesUsed] ++;
	PlayerInfo[playerid][pDronesExploded] ++;
	return 1;
}

alias:ex("pb", "plantbomb");
CMD:ex(playerid, params[]) {
	if (pTeam[playerid] == SWAT) return Text_Send(playerid, $CLIENT_451x);
	if (pDuelInfo[playerid][pDInMatch] == 1) return Text_Send(playerid, $COMMAND_INDUEL);
	if (PlayerInfo[playerid][pDeathmatchId] > -1) return Text_Send(playerid, $COMMAND_INDM);
	if (Iter_Contains(ePlayers, playerid)) return Text_Send(playerid, $COMMAND_INEVENT);
	if (!pItems[playerid][DYNAMITE])
		if (pClass[playerid] != DEMOLISHER) return Text_Send(playerid, $CLIENT_451x);
	if (Iter_Contains(CWCLAN1, playerid) || Iter_Contains(CWCLAN2, playerid)) return Text_Send(playerid, $COMMAND_INCW);
	if (IsPlayerInBase(playerid)) return Text_Send(playerid, $CLIENT_454x);
	if (Iter_Contains(PUBGPlayers, playerid)) return Text_Send(playerid, $COMMAND_INPUBG);

	new seconds;

	if (sscanf(params, "i", seconds)) return ShowSyntax(playerid, "/pb [seconds]");
	if (seconds > 50 || seconds < 15) return Text_Send(playerid, $CLIENT_455x);

	if (pCooldown[playerid][25] < gettime()) {
		if (GetPlayerState(playerid) == PLAYER_STATE_ONFOOT) {
			pCooldown[playerid][25] = gettime() + 50;

			ApplyAnimation(playerid, "BOMBER", "BOM_Plant", 4.0, 0, 0, 0, 0, 0);
			GameTextForPlayer(playerid, "~r~PLANTING DYNAMITE", 5000, 3);

			for (new i = 0; i < MAX_SLOTS; i++) {
				if (!gDynamiteExists[i]) {
					if (pCooldown[playerid][9] < gettime()) {
						pCooldown[playerid][9] = gettime() + 35;

						new Float: X, Float: Y, Float: Z;
						GetXYZInfrontOfPlayer(playerid, X, Y, 0.7);
						CA_FindZ_For2DCoord(X, Y, Z);

						gDynamiteExists[i] = 1;

						gDynamitePlacer[i] = playerid;
						gDynamiteObj[i] = CreateDynamicObject(1654, X, Y, Z, 90.0, 0.0, 0.0);
						gDynamiteArea[i] = CreateDynamicCircle(X, Y, 15.0);

						gDynamitePos[i][0] = X;
						gDynamitePos[i][1] = Y;
						gDynamitePos[i][2] = Z;

						gDynamiteCD[i] = gettime() + seconds;

						if (pClass[playerid] != DEMOLISHER) {
							AddPlayerItem(playerid, DYNAMITE, -1);
							PlayerInfo[playerid][pItemsUsed] ++;
						} else {
							PlayerInfo[playerid][pClassAbilitiesUsed] ++;
						}

						KillTimer(gDynamiteTimer[i]);
						gDynamiteTimer[i] = SetTimerEx("DynamiteExplosion", seconds * 1000, false, "i", i);
						ApplyAnimation(playerid, "MISC", "PICKUP_box", 3.0, 0, 0, 0, 0, 0);

						break;
					} else {
						Text_Send(playerid, $COOLDOWN_TIMELEFT, pCooldown[playerid][9] - gettime());
					}
				}
			}
		} else {
			pCooldown[playerid][25] = gettime() + 50;
			KillTimer(ExplodeTimer[playerid]);
			ExplodeTimer[playerid] = SetTimerEx("ExplodeCar", seconds * 1000, false, "ii", playerid, GetPlayerVehicleID(playerid));
			GameTextForPlayer(playerid, "~g~~h~BOMBING CAR", 5000, 3);
		}
	} else {
		Text_Send(playerid, $COOLDOWN_TIMELEFT, pCooldown[playerid][25] - gettime());
	}
	return 1;
}

CMD:rebuildantenna(playerid) {
	if (pDuelInfo[playerid][pDInMatch] == 1) return Text_Send(playerid, $COMMAND_INDUEL);
	if (PlayerInfo[playerid][pDeathmatchId] > -1) return Text_Send(playerid, $COMMAND_INDM);
	if (Iter_Contains(ePlayers, playerid)) return Text_Send(playerid, $COMMAND_INEVENT);
	if (Iter_Contains(CWCLAN1, playerid) || Iter_Contains(CWCLAN2, playerid)) return Text_Send(playerid, $COMMAND_INCW);
	if (pClass[playerid] != MECHANIC || !pAdvancedClass[playerid]) return Text_Send(playerid, $CLIENT_451x);
	if (Iter_Contains(PUBGPlayers, playerid)) return Text_Send(playerid, $COMMAND_INPUBG);

	for (new i = 0; i < sizeof(AntennaInfo); i++) {
		if (i == pTeam[playerid]) {
			if (IsPlayerInRangeOfPoint(playerid, 20.0, AntennaInfo[i][Antenna_Pos][0], AntennaInfo[i][Antenna_Pos][1], AntennaInfo[i][Antenna_Pos][2])) {
				if (AntennaInfo[i][Antenna_Exists] == 0) {
					SetTimerEx("RebuildAntenna", 12000, false, "i", playerid);
					PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
					PlayerInfo[playerid][pSupportAttempts]++;
					break;
				}  else Text_Send(playerid, $CLIENT_436x);
			}  else Text_Send(playerid, $CLIENT_456x);
		}
	}
	return 1;
}

CMD:spy(playerid) {
	if (pDuelInfo[playerid][pDInMatch] == 1) return Text_Send(playerid, $COMMAND_INDUEL);
	if (PlayerInfo[playerid][pDeathmatchId] > -1) return Text_Send(playerid, $COMMAND_INDM);
	if (Iter_Contains(ePlayers, playerid)) return Text_Send(playerid, $COMMAND_INEVENT);
	if (Iter_Contains(CWCLAN1, playerid) || Iter_Contains(CWCLAN2, playerid)) return Text_Send(playerid, $COMMAND_INCW);
	if (Iter_Contains(PUBGPlayers, playerid)) return Text_Send(playerid, $COMMAND_INPUBG);

	if (pItems[playerid][SK] || (pClass[playerid] == SPY)) {
		if (PlayerInfo[playerid][pIsSpying]) return Text_Send(playerid, $CLIENT_457x);
		new string[50], alt[256];

		for (new i = 0; i < sizeof(TeamInfo); i++)
		{
			format(string, sizeof(string), "{%06x}%s\n", TeamInfo[i][Team_Color] >>> 8, TeamInfo[i][Team_Name]);
			strcat(alt, string);
		}

		inline SpySystem(pid, dialogid, response, listitem, string:inputtext[]) {
			#pragma unused dialogid, inputtext
			if (!response) {
				return 1;
			}

			if (listitem == pTeam[pid]) return Text_Send(pid, $CLIENT_458x);
			if (PlayerInfo[pid][pIsSpying]) return Text_Send(pid, $CLIENT_457x);

			PlayerInfo[pid][pIsSpying] = 1;
			PlayerInfo[pid][pSpyTeam] = listitem;

			SetPlayerColor(pid, TeamInfo[listitem][Team_Color]);
			UpdateLabelText(pid);

			switch (PlayerInfo[pid][pSpyTeam]) {
				case SWAT: SetPlayerSkin(pid, 285);
				case TERRORIST: SetPlayerSkin(pid, 28);
			}
			if (pClass[pid] != SPY) AddPlayerItem(pid, SK, -1), PlayerInfo[pid][pItemsUsed] ++;
			printf("%s[%d] is now spying %s.", PlayerInfo[pid][PlayerName], pid, TeamInfo[listitem][Team_Name]);
		}

		Dialog_ShowCallback(playerid, using inline SpySystem, DIALOG_STYLE_LIST, "Disguise", alt, ">>", "X");

		if (pClass[playerid] == SPY) {
			PlayerInfo[playerid][pClassAbilitiesUsed] ++;
		}

	}  else Text_Send(playerid, $CLIENT_451x);    
	return 1;
}

CMD:nospy(playerid) {
	if (pDuelInfo[playerid][pDInMatch] == 1) return Text_Send(playerid, $COMMAND_INDUEL);
	if (PlayerInfo[playerid][pDeathmatchId] > -1) return Text_Send(playerid, $COMMAND_INDM);
	if (Iter_Contains(CWCLAN1, playerid) || Iter_Contains(CWCLAN2, playerid)) return Text_Send(playerid, $COMMAND_INCW);
	if (Iter_Contains(ePlayers, playerid)) return Text_Send(playerid, $COMMAND_INEVENT);
	
	if (Iter_Contains(PUBGPlayers, playerid)) return Text_Send(playerid, $COMMAND_INPUBG);
	if (PlayerInfo[playerid][pIsSpying] == 1) {
		PlayerInfo[playerid][pIsSpying] = 0;
		PlayerInfo[playerid][pSpyTeam] = -1;

		SetPlayerSkin(playerid, pSkin[playerid]);
		SetPlayerColor(playerid, TeamInfo[pTeam[playerid]][Team_Color]);
		UpdateLabelText(playerid);       
	} else Text_Send(playerid, $CLIENT_459x);
	return 1;
}

CMD:stab(playerid) {
	if (pClass[playerid] != SPY)
		return PlayerPlaySound(playerid, 1055, 0.0, 0.0, 0.0), Text_Send(playerid, $CLIENT_451x);
	if (!IsPlayerInAnyVehicle(playerid)) return Text_Send(playerid, $CLIENT_445x);
	if (GetPlayerState(playerid) != PLAYER_STATE_PASSENGER) return Text_Send(playerid, $CLIENT_445x);

	new stabbed = 0;

	foreach (new i: Player) {
		if (GetPlayerVehicleID(i) == GetPlayerVehicleID(playerid) && GetPlayerState(i) == PLAYER_STATE_DRIVER) {
			if (pTeam[i] == pTeam[playerid]) return Text_Send(playerid, $CLIENT_460x);
			if (pCooldown[playerid][34] > gettime()) {
				Text_Send(playerid, $CLIENT_453x, pCooldown[playerid][34] - gettime());
				return 1;
			}

			pCooldown[playerid][34] = gettime() + 3;
			DamagePlayer(i, 40.0, playerid, WEAPON_KNIFE, BODY_PART_UNKNOWN, true);
			GameTextForPlayer(playerid, "~g~STABBED", 2000, 3);
			GameTextForPlayer(i, "~r~STABBED", 2000, 3);
			PlayerInfo[playerid][pDriversStabbed] ++;
			PlayerInfo[playerid][pClassAbilitiesUsed] ++;
			stabbed = 1;
		}
	}

	if (!stabbed)
		Text_Send(playerid, $CLIENT_461x);
	return 1;
}

CMD:heal(playerid) return HealClosePlayers(playerid);

CMD:vest(playerid) {
	if (pDuelInfo[playerid][pDInMatch] == 1) return Text_Send(playerid, $COMMAND_INDUEL);
	if (PlayerInfo[playerid][pDeathmatchId] > -1) return Text_Send(playerid, $COMMAND_INDM);
	if (Iter_Contains(ePlayers, playerid)) return Text_Send(playerid, $COMMAND_INEVENT);
	if (Iter_Contains(CWCLAN1, playerid) || Iter_Contains(CWCLAN2, playerid)) return Text_Send(playerid, $COMMAND_INCW);
	if (Iter_Contains(PUBGPlayers, playerid)) return Text_Send(playerid, $COMMAND_INPUBG);

	if (pClass[playerid] != CUSTODIAN) {
		return Text_Send(playerid, $CLIENT_451x);
	}

	if (pCooldown[playerid][42] > gettime()) {
		Text_Send(playerid, $CLIENT_453x, pCooldown[playerid][42] - gettime());
		return 1;
	}

	new Float: X, Float: Y, Float: Z, Float: rRange, Float: AR, nearby_players = 0;
	GetPlayerPos(playerid, X, Y, Z);
	if (pAdvancedClass[playerid]) {
		rRange = 15.0;
		AR = 50.0;
	} else {
		rRange = 10.0;
		AR = 25.0;
	}

	foreach (new i: Player) {
		if (IsPlayerInRangeOfPoint(i, rRange, X, Y, Z) && i != playerid && pTeam[i] == pTeam[playerid]
			&& !GetPlayerInterior(i) && !GetPlayerVirtualWorld(i) && IsPlayerSpawned(i)) {
			new Float: pAR;
			GetPlayerArmour(i, pAR);
			if (pAR + AR < 100) {
				Text_Send(playerid, $CLIENT_462x, PlayerInfo[i][PlayerName]);

				PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
				PlayerPlaySound(i, 1057, 0.0, 0.0, 0.0);

				SetPlayerArmour(i, pAR + AR);
				GivePlayerScore(playerid, 1);
				nearby_players ++;
			}	
		}
	}

	if (nearby_players) {
		pCooldown[playerid][42] = gettime() + 60;
	}

	PlayerInfo[playerid][pClassAbilitiesUsed] ++;
	return 1;
}

CMD:jp(playerid) {
	if (pDuelInfo[playerid][pDInMatch] == 1) return Text_Send(playerid, $COMMAND_INDUEL);
	if (PlayerInfo[playerid][pDeathmatchId] > -1) return Text_Send(playerid, $COMMAND_INDM);
	if (Iter_Contains(ePlayers, playerid)) return Text_Send(playerid, $COMMAND_INEVENT);
	if (Iter_Contains(CWCLAN1, playerid) || Iter_Contains(CWCLAN2, playerid)) return Text_Send(playerid, $COMMAND_INCW);

	if (PlayerInfo[playerid][pLoggedIn] == 1) {
		if (pItems[playerid][JETPACK] || (pClass[playerid] == JETTROOPER)) {
			if (pCooldown[playerid][9] < gettime()) {
				SetPlayerSpecialAction(playerid, 2);
				PlayerInfo[playerid][pClassAbilitiesUsed] ++;

				pCooldown[playerid][9] = gettime() + 15;
			} else {
				Text_Send(playerid, $COOLDOWN_TIMELEFT, pCooldown[playerid][9] - gettime());
			}
		}  else Text_Send(playerid, $CLIENT_451x);
	}
	return 1;
}

CMD:sc(playerid) {
	if (pDuelInfo[playerid][pDInMatch] == 1) return Text_Send(playerid, $COMMAND_INDUEL);
	if (PlayerInfo[playerid][pDeathmatchId] > -1) return Text_Send(playerid, $COMMAND_INDM);
	if (Iter_Contains(ePlayers, playerid)) return Text_Send(playerid, $COMMAND_INEVENT);
	if (Iter_Contains(CWCLAN1, playerid) || Iter_Contains(CWCLAN2, playerid)) return Text_Send(playerid, $COMMAND_INCW);
	if (Iter_Contains(PUBGPlayers, playerid)) return Text_Send(playerid, $COMMAND_INPUBG);
	if (PlayerInfo[playerid][pLastHitTick] > gettime()) return Text_Send(playerid, $JUSTHIT, PlayerInfo[playerid][pLastHitTick] - gettime());

	if (GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) return Text_Send(playerid, $COMMAND_NOTONFOOT);
	KillTimer(pTeamSTimer[playerid]);

	if (AntiSK[playerid]) {
		EndProtection(playerid);
	}

	Text_Send(playerid, $CLASS_SWITCHING);
	PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);

	pTeamSTimer[playerid] = SetTimerEx("SwitchClass", 5000, false, "i", playerid);
	return 1;
}

CMD:classes(playerid) {
	inline Classes(pid, dialogid, response, listitem, string:inputtext[]) {
		#pragma unused dialogid, inputtext
		if (!response) return 1;
		new string[150];
		format(string, sizeof(string), ""LIMEGREEN"%s: %s", ClassInfo[listitem][Class_Name], ClassInfo[listitem][Class_Ability]);
		SendClientMessage(pid, 0xE8E8E8FF, string);
		format(string, sizeof(string), ""LIMEGREEN"%s: %s", ClassInfo[listitem][aClass_Name], ClassInfo[listitem][aClass_Ability]);
		SendClientMessage(pid, 0xE8E8E8FF, string);
		format(string, sizeof(string), ""IVORY"%s[%d], %s[%d], %s[%d], %s[%d] and %s[%d].",
		ReturnWeaponName(ClassInfo[listitem][Class_Weapon1][0]), ClassInfo[listitem][Class_Weapon1][1],
		ReturnWeaponName(ClassInfo[listitem][Class_Weapon2][0]), ClassInfo[listitem][Class_Weapon2][1],
		ReturnWeaponName(ClassInfo[listitem][Class_Weapon3][0]), ClassInfo[listitem][Class_Weapon3][1],
		ReturnWeaponName(ClassInfo[listitem][Class_Weapon4][0]), ClassInfo[listitem][Class_Weapon4][1],
		ReturnWeaponName(ClassInfo[listitem][Class_Weapon5][0]), ClassInfo[listitem][Class_Weapon5][1]);
		SendClientMessage(pid, 0xE8E8E8FF, string);
		
		format(string, sizeof(string), ""IVORY"%d Score (advanced: %d EXP)",
		ClassInfo[listitem][Class_Score], ClassInfo[listitem][Class_XP]);
		SendClientMessage(pid, 0xE8E8E8FF, string);
	}

	new string[50 * 15], sub_string[45];
	strcat(string, "#\tClass\tScore\n");

	for (new i = 0; i < sizeof(ClassInfo); i++) {
		if (ClassInfo[i][Class_Score] <= GetPlayerScore(playerid)) {
			format(sub_string, sizeof(sub_string), ""DARKBLUE"%d\t%s\t%d\n", i, ClassInfo[i][Class_Name], ClassInfo[i][Class_Score]);
			strcat(string, sub_string);
		}
		else
		{
			format(sub_string, sizeof(sub_string), ""IVORY"%d\t%s\t%d\n", i, ClassInfo[i][Class_Name], ClassInfo[i][Class_Score]);
			strcat(string, sub_string);
		}
	}


	Dialog_ShowCallback(playerid, using inline Classes, DIALOG_STYLE_TABLIST_HEADERS, ""RED2"SvT - Classes", string, "X", "");    
	return 1;
}

//Carepack

alias:drop("dcp");
CMD:drop(playerid) {
	if (GetVehicleModel(GetPlayerVehicleID(playerid)) == 553) {
		if (pClass[playerid] == PILOT) {
			if (PlayerInfo[playerid][pLimit2] > gettime()) {
     			Text_Send(playerid, $CLIENT_347x, PlayerInfo[playerid][pLimit2] - gettime());
				return 1;
			}

			new Float: X, Float: Y, Float: Z, Float: Check_Z;
			GetPlayerPos(playerid, X, Y, Z);

			CA_FindZ_For2DCoord(X, Y, Check_Z);
			if ((Z - Check_Z) < 15.0) return Text_Send(playerid, $CLIENT_346x);

			for (new i = 0; i < MAX_SLOTS; i++) {
				if (!gCarepackExists[i]) {
					GetPlayerPos(playerid, X, Y, Z);
					CA_FindZ_For2DCoord(X, Y, Z);

					gCarepackExists[i] = 1;

					gCarepackPos[i][0] = X;
					gCarepackPos[i][1] = Y;
					gCarepackPos[i][2] = Z;

					gCarepackUsable[i] = 0;

					KillTimer(gCarepackTimer[i]);
					gCarepackTimer[i] = SetTimerEx("OnCarepackForwarded", 1000, false, "i", i);

					Text_Send(@pVerified, $SERVER_57x, PlayerInfo[playerid][PlayerName]);

					GetPlayerName(playerid, gCarepackCaller[i], MAX_PLAYER_NAME);

					PlayerInfo[playerid][pLimit2] = gettime() + 80;
					PlayerInfo[playerid][Carepacks] ++;

					PlayerPlaySound(playerid, 1095, 0.0, 0.0, 0.0);

					break;
				}
			}
		} else Text_Send(playerid, $CLIENT_345x);
	} else Text_Send(playerid, $CLIENT_344x);
	return 1;
}

//Locator ability

alias:locate("loc");
CMD:locate(playerid, params[]) {
	if (pDuelInfo[playerid][pDInMatch] == 1) return Text_Send(playerid, $COMMAND_INDUEL);
	if (PlayerInfo[playerid][pDeathmatchId] > -1) return Text_Send(playerid, $COMMAND_INDM);
	if (Iter_Contains(ePlayers, playerid)) return Text_Send(playerid, $COMMAND_INEVENT);
	if (Iter_Contains(CWCLAN1, playerid) || Iter_Contains(CWCLAN2, playerid)) return Text_Send(playerid, $COMMAND_INCW);
	if (pClass[playerid] != RECON) return PlayerPlaySound(playerid, 1055, 0.0, 0.0, 0.0), Text_Send(playerid, $CLIENT_444x);
	if (GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) return Text_Send(playerid, $CLIENT_445x);
	if (Iter_Contains(PUBGPlayers, playerid)) return Text_Send(playerid, $COMMAND_INPUBG);

	new targetid;

	if (sscanf(params, "u", targetid)) return ShowSyntax(playerid, "/locate [playerid/name] to search players.");
	if (playerid == targetid || !IsPlayerConnected(targetid)) return Text_Send(playerid, $NEWCLIENT_193x);
	if (GetPlayerInterior(targetid) != 0 || IsPlayerAttachedObjectSlotUsed(targetid, 7)) return Text_Send(playerid, $CLIENT_420x);

	new Float:Pos2[3];
	GetPlayerPos(targetid, Pos2[0], Pos2[1], Pos2[2]);
	SetPlayerRaceCheckpoint(playerid, 1, Pos2[0], Pos2[1], Pos2[2], 0.0, 0.0, 0.0, 5);

	PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
	return 1;
}

//End of File
/* (c) H2O Multiplayer 2018-2020. All rights reserved. */