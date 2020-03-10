/*
	SWAT vs Terrorists is a team death-match SA-MP game-mode script. 
	Compatible with SA-MP 0.3.7 and later releases.

	Author: H2O
	Licensed under GNU GPLv3

	(c) 2018-2020 H2O Multiplayer. All rights reserved.
	Website: h2omultiplayer.com

	Stuff related to the team system to adapt it to the game mode
*/

#include <YSI_Coding\y_hooks>

//Support for y_text, load language files...
#include <YSI_Players\y_text> //Y_Less
loadtext mode_text[all], mode_text[client], mode_text[newcs], mode_text[dialogs], mode_text[gametexts];

forward SwitchTeam(playerid);
forward RebuildAntenna(playerid);
forward OnNukeLaunch(playerid, base);
forward OnNukeFinish(base);
forward EndFirstSpawn(playerid);
forward StopAlarm(playerid);
forward RegenerateToxic(cropid);
forward AnthraxToxication(playerid, X, Y, Z);
forward Balloon();

//Terrorists' balloon

public Balloon() {
	if (bRouteCoords == 0) {
		ballonDestination = 0;
		bRouteCoords ++;
		MoveDynamicObject(ballonObjectId, ballonRouteArray[bRouteCoords][0], ballonRouteArray[bRouteCoords][1], ballonRouteArray[bRouteCoords][2], 15.0);
	} else {
		ballonDestination = 1;
		bRouteCoords -= 2;
		MoveDynamicObject(ballonObjectId, ballonRouteArray[bRouteCoords][0], ballonRouteArray[bRouteCoords][1], ballonRouteArray[bRouteCoords][2], 15.0);
	}		
	return 1;
}

//Anthrax gas

public RegenerateToxic(cropid) {
	new rockets[30];
	CropAnthrax[cropid][Anthrax_Rockets] ++;
	format(rockets, 30, "Anthrax Cropduster\n[%d/4]", CropAnthrax[cropid][Anthrax_Rockets]);
	UpdateDynamic3DTextLabelText(CropAnthrax[cropid][Anthrax_Label], X11_CADETBLUE, rockets);    
	return 1;
}

//Anthrax Intoxication

public AnthraxToxication(playerid, X, Y, Z) {
	if (-- PlayerInfo[playerid][pAnthraxTimes] > 0) {
		foreach (new i: Player) {
			new Float: r = 35.0;
			if (PlayerInfo[playerid][pDonorLevel] >= 3) { r = 45.0; }
			if (IsPlayerInRangeOfPoint(i, r, X, Y, Z) && GetPlayerState(i) == PLAYER_STATE_ONFOOT && i != playerid
					&& !PlayerInfo[i][pAdminDuty]) {
				new Float: HP;
				GetPlayerHealth(i, HP);
				
				if (HP <= 5.2) {
					Text_Send(i, $ANTHRAX_DEAD);
					DamagePlayer(i, 0.0, playerid, WEAPON_TEARGAS, BODY_PART_UNKNOWN, true);
					Text_Send(playerid, $INTOXICATE_BONUS, PlayerInfo[i][PlayerName], i);
					GivePlayerScore(playerid, 3);
					if (IsPlayerInAnyClan(playerid)) {
						if (pClan[playerid] != pClan[i]) {
							AddClanXP(GetPlayerClan(playerid), 3);
							foreach (new x: Player) {
								if (pClan[x] == pClan[playerid]) {
									Text_Send(x, $INTOXICATION_CLAN_BONUS, GetPlayerClan(playerid), PlayerInfo[playerid][PlayerName]);
								}
							}	            		
						}
					}
				} else {
					new Float: dmg = 0.0;
					if (!IsPlayerAttachedObjectSlotUsed(i, 3)
						&& !pItems[i][MASK]) {
						dmg = 12.5;
						Text_Send(i, $ANTHRAX_12HP);
					} else {
						dmg -= 5.2;
						Text_Send(i, $ANTHRAX_5HP);
					}	
					DamagePlayer(i, dmg, playerid, WEAPON_TEARGAS, BODY_PART_UNKNOWN, true);
				}
			}
		}
		
		PlayerInfo[playerid][pAnthraxTimer] = SetTimerEx("AnthraxToxication", 500, false, "ifff", playerid, X, Y, Z);
	} else {
		for (new i = 0; i < 17; i++) {
			if (IsValidDynamicObject(PlayerInfo[playerid][pAnthraxEffects][i])) {
				DestroyDynamicObject(PlayerInfo[playerid][pAnthraxEffects][i]);
			}
			PlayerInfo[playerid][pAnthraxEffects][i] = INVALID_OBJECT_ID;
		}
		
		foreach(new i: Player) {
			if (IsPlayerInRangeOfPoint(i, 35.0, X, Y, Z)) {
				Text_Send(i, $TOXICATION_EXPIRED);
			}
		}
		
		KillTimer(PlayerInfo[playerid][pAnthraxTimer]);
	}    
	return 1;
}


//Stop nuke alarm
public StopAlarm(playerid) {
	PlayerPlaySound(playerid, 0, 0.0, 0.0, 0.0);
	return 1;
}


//Finish a player's first spawn
public EndFirstSpawn(playerid) {
	pFirstSpawn[playerid] = 0;
	
	if (GetPlayerDistanceFromPoint(playerid, TeamInfo[pTeam[playerid]][Spawn_1][0] - 1.0, TeamInfo[pTeam[playerid]][Spawn_1][1] + 1.0, TeamInfo[pTeam[playerid]][Spawn_1][2]) > 8.0) {
		new string[128];
		format(string, sizeof(string), "%s[%d] may be using s0beit or lagging.", PlayerInfo[playerid][PlayerName], playerid);
		MessageToAdmins(X11_RED2, string);
	}
	
	if (GetPlayerCameraMode(playerid) == 7) {
		new string[128];
		format(string, sizeof(string), "%s[%d] may be using s0beit or lagging.", PlayerInfo[playerid][PlayerName], playerid);
		MessageToAdmins(X11_RED2, string);
	}

	StopAudioStreamForPlayer(playerid);
	SpawnPlayer(playerid);  
	return 1;
}

//Player switching team (used for the timer)
public SwitchTeam(playerid) {
	Text_Send(playerid, $SWITCH_TEAM);
	ForceClassSelection(playerid);
	SetPlayerHealth(playerid, 0.0);
	UpdatePlayerHUD(playerid);
	return 1;
}

//A player fixed their team's radio antenna.. Nice?
public RebuildAntenna(playerid) {
	for (new i = 0; i < sizeof(AntennaInfo); i++) {
		if (i == pTeam[playerid]) {
			if (IsPlayerInRangeOfPoint(playerid, 20.0, AntennaInfo[i][Antenna_Pos][0], AntennaInfo[i][Antenna_Pos][1], AntennaInfo[i][Antenna_Pos][2])) {
				if (AntennaInfo[i][Antenna_Exists] == 0 && AntennaInfo[i][Antenna_Kill_Time] > gettime()) {
					AntennaInfo[i][Antenna_Exists] = 1;
					AntennaInfo[i][Antenna_Hits] = 0;

					SetDynamicObjectPos(AntennaInfo[i][Antenna_Id], AntennaInfo[i][Antenna_Pos][0], AntennaInfo[i][Antenna_Pos][1], AntennaInfo[i][Antenna_Pos][2]);
					Text_Send(@pVerified, $SERVER_37x, PlayerInfo[playerid][PlayerName], TeamInfo[i][Team_Name]);

					Text_Send(playerid, $ANTENNA_REPAIRED);
					GivePlayerScore(playerid, 5);

					new title[140];

					format(title, sizeof(title), "%s\n"IVORY"Radio Antenna", TeamInfo[i][Team_Name]);
					UpdateDynamic3DTextLabelText(AntennaInfo[i][Antenna_Label], TeamInfo[i][Team_Color], title);	

					if (pClass[playerid] != MECHANIC) {
						AddPlayerItem(playerid, TOOLKIT, -1);
					}
				}  else Text_Send(playerid, $ANTENNA_NOT_DESTROYED);
			}  else Text_Send(playerid, $ANTENNA_TOO_FAR);
		}
	}
	return 1;
}

//Nuke is directly related to the team system so putting it in this module is logical, no teams, no nuke, right?
public OnNukeLaunch(playerid, base) {
	nukePlayerId = INVALID_PLAYER_ID;

	new count = 0;
	
	if (ZoneInfo[LV_AIR][Zone_Owner] != base) {
		SetWeather(19);
		GameTextForAll("~r~NUKE LAUNCHED!", 5000, 3);
		GangZoneFlashForAll(TeamInfo[base][Team_Gangzone], ALPHA(X11_IVORY, 100));

		UpdateDynamic3DTextLabelText(nukeRemoteLabel, 0xFFFFFFFF, "Nuke\n{FF0000}Offline");

		SetTimerEx("OnNukeFinish", 9000, false, "i", base);
		
		if (WarInfo[War_Started] == 1) {
			if ((pTeam[playerid] == WarInfo[War_Team1] && base == WarInfo[War_Team2]) ||
			(pTeam[playerid] == WarInfo[War_Team2] && base == WarInfo[War_Team1])) {
				AddTeamWarScore(playerid, 1);
			}
		}

		for (new i = 0; i < MAX_SLOTS; i++) {
			if (!gAirstrikeExists[i]) {	
				gAirstrikeExists[i] = 1;

				new Float: X, Float: Y, Float: Z;

				new random_pos = random(3);
				switch (random_pos)
				{
					case 0:
					{
						X = TeamInfo[base][Spawn_1][0];
						Y = TeamInfo[base][Spawn_1][1];
						Z = TeamInfo[base][Spawn_1][2];
					}
					case 1:
					{
						X = TeamInfo[base][Spawn_2][0];
						Y = TeamInfo[base][Spawn_2][1];
						Z = TeamInfo[base][Spawn_2][2];
					}
					case 2:
					{
						X = TeamInfo[base][Spawn_3][0];
						Y = TeamInfo[base][Spawn_3][1];
						Z = TeamInfo[base][Spawn_3][2];
					}
				}

				CA_FindZ_For2DCoord(X, Y, Z);

				gAirstrikePos[i][0] = X;
				gAirstrikePos[i][1] = Y;
				gAirstrikePos[i][2] = Z;

				new Smoke_Flare_Object = CreateDynamicObject(18728, gAirstrikePos[i][0], gAirstrikePos[i][1], gAirstrikePos[i][2], 0.0, 0.0, 90.0);
				gAirstrikeTimer[i] = SetTimerEx("OnAirstrikeForwarded", 5000, false, "ii", i, Smoke_Flare_Object);

				break;
			}
		}		

		foreach (new i: Player) {
			if (pTeam[i] == base) {
				if (IsPlayerInBase(i) == 1) {
					new Float: burnx, Float: burny, Float: burnz;
					GetPlayerPos(i, burnx, burny, burnz);

					CreateExplosion(burnx, burny, burnz, 7, 10.0);
					CreateExplosion(burnx, burny + 5, burnz, 7, 10.0);
					CreateExplosion(burnx - 5, burny, burnz, 7, 10.0);

					PlayerPlaySound(i, 1057, 0.0, 0.0, 0.0);
					SetPlayerPos(i, burnx + 5, burny + 5, burnz + 10);

					SetPlayerHealth(i, 0.0);

					Text_Send(i, $NUKED);

					PlayAudioStreamForPlayer(i, "http://51.254.181.90/server/nuke.mp3", 0.0, 0.0, 0.0, 0.0, 0);

					PlayerInfo[playerid][pKills] ++;
					PlayerInfo[i][pDeaths] ++;

					Text_Send(playerid, $NUKE_KILLED, PlayerInfo[i][PlayerName], i);

					GivePlayerScore(playerid, 1);
					GivePlayerCash(playerid, 5000);

					count++;
				}
			}    
		}

		if (count) {
			Text_Send(@pVerified, $SERVER_7x, PlayerInfo[playerid][PlayerName], count);
		}	
	}
	else GameTextForAll("~r~NUKE FAIL!", 3000, 3), GangZoneStopFlashForAll(TeamInfo[base][Team_Gangzone]),
		UpdateDynamic3DTextLabelText(nukeRemoteLabel, 0xFFFFFFFF, "Nuke\n{00CC00}Online");
	return 1;
}

//If the nuke finished, return stuff to their normal state.. Enough fucking up :D
public OnNukeFinish(base) {
	SetWeather(10);
	GangZoneStopFlashForAll(TeamInfo[base][Team_Gangzone]);
	return 1;
}


//Rope Rappelling
CreateRope(playerid, numropes) {
	new Float:Angle;
	GetPlayerFacingAngle(playerid, Angle);

	new Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);

	PlayerInfo[playerid][pRopeRappels] ++;

	for (new i = 0; i < numropes; i++) {
		pRope[playerid][RopeID][i] = CreateDynamicObject(19089, pRope[playerid][RRX], pRope[playerid][RRY], pRope[playerid][RRZ]- 2.6 - (i * 5.1), 0, 0, Angle);
	}
}

//Is the player in his base's area?
IsPlayerInBase(playerid) {
	new InBase = 0;

	for (new i = 0; i < sizeof(TeamInfo); i++) {
		if (pTeam[playerid] == i) {
			if (IsPlayerInDynamicArea(playerid, TeamInfo[pTeam[playerid]][Team_Area]))
			{
				InBase = 1;
			}
		}
	}

	return InBase;
}

//Team War System

//Tell the player they won the war?
NotifyTW(playerid) {
	return NotifyPlayer(playerid, "~g~Your team won the team war!");
}

//Check if a team won the war
TeamWarWinCheck() {
	if (WarInfo[War_Started] == 1 && gettime() >= war_time) {
		if (WarInfo[Team1_Score] >= WarInfo[Team2_Score])
		{
			WarInfo[War_Started] = 0;
			TextDrawHideForAll(War_TD);
			TextDrawHideForAll(War_TDBox);

			Text_Send(@pVerified, $SERVER_44x, TeamInfo[WarInfo[War_Team1]][Team_Name], TeamInfo[WarInfo[War_Team2]][Team_Name]);

			foreach (new i: Player) {
				if (pTeam[i] == WarInfo[War_Team1] && IsPlayerSpawned(i) && !GetPlayerInterior(i) && !GetPlayerVirtualWorld(i)) {
					Text_Send(i, $TEAMWAR_WON);

					GivePlayerCash(i, 20000);
					GivePlayerScore(i, 5);
					
					NotifyTW(i);
				}
			}
		}
		else
		{
			WarInfo[War_Started] = 0;
			TextDrawHideForAll(War_TD);
			TextDrawHideForAll(War_TDBox);

			Text_Send(@pVerified, $SERVER_44x, TeamInfo[WarInfo[War_Team2]][Team_Name], TeamInfo[WarInfo[War_Team1]][Team_Name]);

			foreach (new i: Player) {
				if (pTeam[i] == WarInfo[War_Team2] && IsPlayerSpawned(i) && !GetPlayerInterior(i) && !GetPlayerVirtualWorld(i)) {
					Text_Send(i, $TEAMWAR_WON);

					GivePlayerCash(i, 20000);
					GivePlayerScore(i, 5);
					
					NotifyTW(i);
				}
			}
		}		
	}
	return 1;
}

//Update team war information for player(s)
UpdateTeamWarForPlayer(playerid) {
	if (WarInfo[War_Started]) {
		new war_str[130];
		format(war_str, sizeof(war_str), "%s%s (%d)~w~ VS %s[%d] %s~n~~w~Winner: %s%s", TeamInfo[WarInfo[War_Team1]][Chat_Bub], TeamInfo[WarInfo[War_Team1]][Team_Name],
		WarInfo[Team1_Score], TeamInfo[WarInfo[War_Team2]][Chat_Bub], WarInfo[Team2_Score], TeamInfo[WarInfo[War_Team2]][Team_Name]);

		TextDrawSetString(War_TD, war_str);
		UpdatePlayerHUD(playerid);		
	}
	return 1;
}

//Reward player for team war
AddTeamWarScore(playerid, Score) {
	if (WarInfo[War_Started] == 1) {
		if (pTeam[playerid] == WarInfo[War_Team1]) {
			WarInfo[Team1_Score] += Score;
			Text_Send(playerid, $TEAMWAR_PROGRESS, Score);
		}
		else if (pTeam[playerid] == WarInfo[War_Team2]) {
			WarInfo[Team2_Score] += Score;
			Text_Send(playerid, $TEAMWAR_PROGRESS, Score);
		}

		new war_str[130];
		format(war_str, sizeof(war_str), "%s%s (%d)~w~ VS %s[%d] %s~n~~w~Winner: %s%s", TeamInfo[WarInfo[War_Team1]][Chat_Bub], TeamInfo[WarInfo[War_Team1]][Team_Name],
		WarInfo[Team1_Score], TeamInfo[WarInfo[War_Team2]][Chat_Bub], WarInfo[Team2_Score], TeamInfo[WarInfo[War_Team2]][Team_Name]);

		TextDrawSetString(War_TD, war_str);
		foreach (new i: Player) {
			if (IsPlayerSpawned(i) && !IsPlayerDying(i)) {
				UpdatePlayerHUD(i);
			}
		}
	}    
	return 1;
}

//Briefcase, isn't this a team feature too?

ShowItemsDialog(playerid) {
	inline BriefcaseItems(pid, dialogid, response, listitem, string:inputtext[]) {
		#pragma unused dialogid, inputtext
		if (!response) return ShowBriefcase(pid);
		ShowItemsDialog(pid);
		switch (listitem) {
			case 0: {
				ApplyActorAnimation(ShopActors[pTeam[pid]], "DEALER", "DEALER_DEAL", 3.0, 0, 0, 0, 0, 0);
				if (GetPlayerCash(pid) < 9000) return PlayerPlaySound(pid, 1055, 0.0, 0.0, 0.0), Text_Send(pid, $CLIENT_184x);
				if (pItems[pid][LANDMINES] >= MaxPlayerItem(LANDMINES)) return Text_Send(pid, $CLIENT_185x);
				AddPlayerItem(pid, LANDMINES, 1);
				Text_Send(pid, $CLIENT_211x);
				GivePlayerCash(pid, -9000);
				PlayerPlaySound(pid, 1054, 0.0, 0.0, 0.0);
			}
			case 1: {
				ApplyActorAnimation(ShopActors[pTeam[pid]], "DEALER", "DEALER_DEAL", 3.0, 0, 0, 0, 0, 0);
				if (GetPlayerCash(pid) < 10000) return PlayerPlaySound(pid, 1055, 0.0, 0.0, 0.0), Text_Send(pid, $CLIENT_186x);
				if (pItems[pid][MK] >= MaxPlayerItem(MK)) return Text_Send(pid, $CLIENT_187x);
				AddPlayerItem(pid, MK, 1);
				Text_Send(pid, $CLIENT_212x);
				GivePlayerCash(pid, -7500);
				PlayerPlaySound(pid, 1054, 0.0, 0.0, 0.0);
			}
			case 2: {
				ApplyActorAnimation(ShopActors[pTeam[pid]], "DEALER", "DEALER_DEAL", 3.0, 0, 0, 0, 0, 0);
				if (GetPlayerCash(pid) < 15000) return PlayerPlaySound(pid, 1055, 0.0, 0.0, 0.0), Text_Send(pid, $CLIENT_188x);
				if (pItems[pid][AK] >= MaxPlayerItem(AK)) return Text_Send(pid, $CLIENT_189x);
				AddPlayerItem(pid, AK, 1);
				Text_Send(pid, $CLIENT_213x);
				GivePlayerCash(pid, -15000);
				PlayerPlaySound(pid, 1054, 0.0, 0.0, 0.0);
			}
			case 3: {
				ApplyActorAnimation(ShopActors[pTeam[pid]], "DEALER", "DEALER_DEAL", 3.0, 0, 0, 0, 0, 0);
				if (GetPlayerCash(pid) < 5000) return PlayerPlaySound(pid, 1055, 0.0, 0.0, 0.0), Text_Send(pid, $CLIENT_190x);
				if (pItems[pid][HELMET] >= 2) return Text_Send(pid, $CLIENT_191x);

				AddPlayerItem(pid, HELMET, 1);
				Text_Send(pid, $CLIENT_214x);
				GivePlayerCash(pid, -5000);
				PlayerPlaySound(pid, 1054, 0.0, 0.0, 0.0);
			}
			case 4: {
				ApplyActorAnimation(ShopActors[pTeam[pid]], "DEALER", "DEALER_DEAL", 3.0, 0, 0, 0, 0, 0);
				if (GetPlayerCash(pid) < 5000) return PlayerPlaySound(pid, 1055, 0.0, 0.0, 0.0), Text_Send(pid, $CLIENT_192x);
				if (pItems[pid][MASK] >= 2) return Text_Send(pid, $CLIENT_193x);

				AddPlayerItem(pid, MASK, 1);
				Text_Send(pid, $CLIENT_215x);
				GivePlayerCash(pid, -5000);
				PlayerPlaySound(pid, 1054, 0.0, 0.0, 0.0);
			}
			case 5: {
				ApplyActorAnimation(ShopActors[pTeam[pid]], "DEALER", "DEALER_DEAL", 3.0, 0, 0, 0, 0, 0);
				if (GetPlayerCash(pid) < 12500) return PlayerPlaySound(pid, 1055, 0.0, 0.0, 0.0), Text_Send(pid, $CLIENT_194x);
				if (pItems[pid][SK] >= MaxPlayerItem(SK)) return Text_Send(pid, $CLIENT_195x);
				AddPlayerItem(pid, SK, 1);
				Text_Send(pid, $CLIENT_216x);
				GivePlayerCash(pid, -12500);
				PlayerPlaySound(pid, 1054, 0.0, 0.0, 0.0);
			}
			case 6: {
				ApplyActorAnimation(ShopActors[pTeam[pid]], "DEALER", "DEALER_DEAL", 3.0, 0, 0, 0, 0, 0);
				if (GetPlayerCash(pid) < 45000) return PlayerPlaySound(pid, 1055, 0.0, 0.0, 0.0), Text_Send(pid, $CLIENT_196x);
				if (pItems[pid][PL] >= MaxPlayerItem(PL)) return Text_Send(pid, $CLIENT_197x);
				AddPlayerItem(pid, PL, 1);
				Text_Send(pid, $CLIENT_217x);
				GivePlayerCash(pid, -45000);
				PlayerPlaySound(pid, 1054, 0.0, 0.0, 0.0);
			}
			case 7: {
				ApplyActorAnimation(ShopActors[pTeam[pid]], "DEALER", "DEALER_DEAL", 3.0, 0, 0, 0, 0, 0);
				if (GetPlayerCash(pid) < 15000) return PlayerPlaySound(pid, 1055, 0.0, 0.0, 0.0), Text_Send(pid, $CLIENT_198x);
				if (pItems[pid][DYNAMITE] >= MaxPlayerItem(DYNAMITE)) return Text_Send(pid, $CLIENT_199x);
				AddPlayerItem(pid, DYNAMITE, 1);
				Text_Send(pid, $CLIENT_218x);
				GivePlayerCash(pid, -15000);
				PlayerPlaySound(pid, 1054, 0.0, 0.0, 0.0);
			}   
			case 8: {
				ApplyActorAnimation(ShopActors[pTeam[pid]], "DEALER", "DEALER_DEAL", 3.0, 0, 0, 0, 0, 0);
				if (GetPlayerCash(pid) < 20000) return PlayerPlaySound(pid, 1055, 0.0, 0.0, 0.0), Text_Send(pid, $CLIENT_200x);
				if (pItems[pid][TOOLKIT] >= MaxPlayerItem(TOOLKIT)) return Text_Send(pid, $CLIENT_201x);
				AddPlayerItem(pid, TOOLKIT, 1);
				Text_Send(pid, $CLIENT_219x);
				GivePlayerCash(pid, -20000);
				PlayerPlaySound(pid, 1054, 0.0, 0.0, 0.0);
			} 	      
			case 9: {
				ApplyActorAnimation(ShopActors[pTeam[pid]], "DEALER", "DEALER_DEAL", 3.0, 0, 0, 0, 0, 0);
				if (GetPlayerCash(pid) < 50000) return PlayerPlaySound(pid, 1055, 0.0, 0.0, 0.0), Text_Send(pid, $CLIENT_202x);
				if (PlayerInfo[pid][pEXPEarned] < 450) return PlayerPlaySound(pid, 1055, 0.0, 0.0, 0.0),Text_Send(pid, $CLIENT_203x);
				if (pItems[pid][JETPACK] >= MaxPlayerItem(JETPACK)) return Text_Send(pid, $CLIENT_204x);
				AddPlayerItem(pid, JETPACK, 1);
				Text_Send(pid, $CLIENT_220x);
				GivePlayerCash(pid, -50000);
				PlayerPlaySound(pid, 1054, 0.0, 0.0, 0.0);
			} 	   
			case 10: {
				ApplyActorAnimation(ShopActors[pTeam[pid]], "DEALER", "DEALER_DEAL", 3.0, 0, 0, 0, 0, 0);
				if (GetPlayerCash(pid) < 20155) return PlayerPlaySound(pid, 1055, 0.0, 0.0, 0.0), Text_Send(pid, $CLIENT_205x);
				if (PlayerInfo[pid][pEXPEarned] < 850) return PlayerPlaySound(pid, 1055, 0.0, 0.0, 0.0), Text_Send(pid, $CLIENT_206x);
				if (pItems[pid][PYROKIT] >= MaxPlayerItem(PYROKIT)) return Text_Send(pid, $CLIENT_207x);
				AddPlayerItem(pid, PYROKIT, 1);
				Text_Send(pid, $CLIENT_221x);
				GivePlayerCash(pid, -20155);
				PlayerPlaySound(pid, 1054, 0.0, 0.0, 0.0);
			}
			case 11: {
				ApplyActorAnimation(ShopActors[pTeam[pid]], "DEALER", "DEALER_DEAL", 3.0, 0, 0, 0, 0, 0);
				if (GetPlayerCash(pid) < 25000) return PlayerPlaySound(pid, 1055, 0.0, 0.0, 0.0), Text_Send(pid, $CLIENT_208x);
				SetPlayerSkillLevel(pid, WEAPONSKILL_SAWNOFF_SHOTGUN, 1000);
				GivePlayerWeapon(pid, WEAPON_SAWEDOFF, 15);
				Text_Send(pid, $CLIENT_222x);
				GivePlayerCash(pid, -25000);
				PlayerPlaySound(pid, 1054, 0.0, 0.0, 0.0);
			}
			case 12: {
				ApplyActorAnimation(ShopActors[pTeam[pid]], "DEALER", "DEALER_DEAL", 3.0, 0, 0, 0, 0, 0);
				if (GetPlayerCash(pid) < 25000) return PlayerPlaySound(pid, 1055, 0.0, 0.0, 0.0), Text_Send(pid, $CLIENT_209x);
				if (pCamo[pid]) return Text_Send(pid, $CLIENT_210x);
				pCamo[pid] = 1;
				gCamoActivated[pid] = 0;
				Text_Send(pid, $CLIENT_223x);
				GivePlayerCash(pid, -50000);
				PlayerPlaySound(pid, 1054, 0.0, 0.0, 0.0);
			}
		}
	}
	Dialog_ShowCallback(playerid, using inline BriefcaseItems, DIALOG_STYLE_TABLIST, "Items Store", 
		""IVORY"Landmine\t"GREEN"$9000\n\
		"IVORY"Medkit\t"GREEN"$7500\n\
		"IVORY"Armour Kit\t"GREEN"$10000\n\
		"IVORY"Helmet\t"GREEN"$5000\n\
		"IVORY"Gasmask\t"GREEN"$5000\n\
		"IVORY"Spy Kit\t"GREEN"$12500\n\
		"IVORY"Pilot License\t"GREEN"$45000\n\
		"IVORY"Dynamite\t"GREEN"$15000\n\
		"IVORY"Toolkit\t"GREEN"$20000\n\
		"IVORY"Jetpack\t"GREEN"$50000\n\
		"IVORY"Pyrokit\t"GREEN"$20155\n\
		"IVORY"Double sawn-off\t"GREEN"$25000\n\
		"IVORY"Camouflage\t"GREEN"$50000",
		">>", "<<");
	return 1;
}

ShowCustomWeaponDialog(playerid) {
	if (!pVerified[playerid]) return Text_Send(playerid, $CLIENT_224x);
	if (PlayerRank[playerid] < 5) return Text_Send(playerid, $CLIENT_225x);
	
	new string[456];
	format(string, sizeof(string), 
		"Option\tCurrent\n\
		Primary Weapon\t%s\n\
		Secondary Weapon\t%s\n\
		Premium Weapon\t%s\n\
		Reset Weapons",
		ReturnWeaponName(PlayerInfo[playerid][pFavWeap]),
		ReturnWeaponName(PlayerInfo[playerid][pFavWeap2]),
		ReturnWeaponName(PlayerInfo[playerid][pFavWeap3]));

	inline CustomWeapon1(pid, dialogid, response, listitem, string:inputtext[]) {
		#pragma unused dialogid, inputtext
		ShowCustomWeaponDialog(pid);
		if (!response)
			return Text_Send(pid, $CLIENT_226x), PC_EmulateCommand(pid, "/cweap");

		if (WeaponInfo[listitem][Weapon_Price] * 6 > GetPlayerCash(pid)) return Text_Send(pid, $CLIENT_227x);

		PlayerInfo[pid][pFavWeap] = WeaponInfo[listitem][Weapon_Id];
		Text_Send(pid, $CLIENT_228x, ReturnWeaponName(WeaponInfo[listitem][Weapon_Id]));

		GivePlayerCash(pid, -WeaponInfo[listitem][Weapon_Price] * 6);
		return 1;
	}

	inline CustomWeapon2(pid, dialogid, response, listitem, string:inputtext[]) {
		#pragma unused dialogid, inputtext
		ShowCustomWeaponDialog(pid);
		if (!response)
			return Text_Send(pid, $CLIENT_226x), PC_EmulateCommand(pid, "/cweap");

		if (WeaponInfo[listitem][Weapon_Price] * 6 > GetPlayerCash(pid)) return Text_Send(pid, $CLIENT_227x);

		PlayerInfo[pid][pFavWeap2] = WeaponInfo[listitem][Weapon_Id];
		Text_Send(pid, $CLIENT_228x, ReturnWeaponName(WeaponInfo[listitem][Weapon_Id]));

		GivePlayerCash(pid, -WeaponInfo[listitem][Weapon_Price] * 6);
		return 1;
	}

	inline CustomWeapon3(pid, dialogid, response, listitem, string:inputtext[]) {
		#pragma unused dialogid, inputtext
		ShowCustomWeaponDialog(pid);
		if (!response)
			return Text_Send(pid, $CLIENT_226x), PC_EmulateCommand(pid, "/cweap");

		if (WeaponInfo[listitem][Weapon_Price] * 6 > GetPlayerCash(pid)) return Text_Send(pid, $CLIENT_227x);

		PlayerInfo[pid][pFavWeap3] = WeaponInfo[listitem][Weapon_Id];
		Text_Send(pid, $CLIENT_228x, ReturnWeaponName(WeaponInfo[listitem][Weapon_Id]));

		GivePlayerCash(pid, -WeaponInfo[listitem][Weapon_Price] * 6);
		return 1;
	}

	inline CustomWeapons(pid, dialogid, response, listitem, string:inputtext[]) {
		#pragma unused dialogid, inputtext
		if (response) {
			new sub_str[60], weaponstr[970];

			strcat(weaponstr, "Weapon\tPrice\tAmmo\n");

			for (new i = 0; i < sizeof(WeaponInfo); i++) {
				format(sub_str, sizeof(sub_str), ""IVORY"%s\t$%d\t%d\n", ReturnWeaponName(WeaponInfo[i][Weapon_Id]), WeaponInfo[i][Weapon_Price] * 6, WeaponInfo[i][Weapon_Ammo]);
				strcat(weaponstr, sub_str);
			}
			switch (listitem) {
				case 0: {
					Dialog_ShowCallback(pid, using inline CustomWeapon1, DIALOG_STYLE_TABLIST_HEADERS, ""RED2"SvT - Custom Weapon",
					weaponstr, ">>", "<<");
				}
				case 1: {
					Dialog_ShowCallback(pid, using inline CustomWeapon2, DIALOG_STYLE_TABLIST_HEADERS, ""RED2"SvT - Custom Weapon",
					weaponstr, ">>", "<<");
				}
				case 2: {
					if (!PlayerInfo[pid][pDonorLevel]) return Text_Send(pid, $CLIENT_229x);
					Dialog_ShowCallback(pid, using inline CustomWeapon3, DIALOG_STYLE_TABLIST_HEADERS, ""RED2"SvT - Custom Weapon",
					weaponstr, ">>", "<<");
				}
				case 3: {
					Text_Send(pid, $CLIENT_230x);
					PlayerInfo[pid][pFavWeap] = 0;
					PlayerInfo[pid][pFavWeap2] = 0;
					PlayerInfo[pid][pFavWeap3] = 0;
					ShowCustomWeaponDialog(pid);
				}            
			}
		} else {
			ShowBriefcase(pid);
		}
	}
	Dialog_ShowCallback(playerid, using inline CustomWeapons, DIALOG_STYLE_TABLIST_HEADERS, "Custom Weapons", string,
	">>", "<<");
	return 1;
}

ShowWeaponDialog(playerid) {
	new weapons_str[100], overall[1700];
		
	for (new i = 0; i < sizeof(WeaponInfo); i++)	{
		format(weapons_str, sizeof(weapons_str), ""IVORY"%s\t"GREEN"%d Ammo\t"GREEN"$%d\n", ReturnWeaponName(WeaponInfo[i][Weapon_Id]), WeaponInfo[i][Weapon_Ammo], WeaponInfo[i][Weapon_Price]);
		strcat(overall, weapons_str);
	}

	inline BriefcaseWeapons(pid, dialogid, response, listitem, string:inputtext[]) {
		#pragma unused dialogid, inputtext
		ApplyActorAnimation(ShopActors[pTeam[pid]], "DEALER", "DEALER_DEAL", 3.0, 0, 0, 0, 0, 0);
		if (!response) return ShowBriefcase(pid);

		if (WeaponInfo[listitem][Weapon_Price] > GetPlayerCash(pid)) return PlayerPlaySound(pid, 1053, 0.0, 0.0, 0.0), Text_Send(pid, $CLIENT_231x);
		if (WeaponInfo[listitem][Weapon_Id] == 38 && pStreak[pid] < 25) return Text_Send(pid, $CLIENT_232x);
		if (WeaponInfo[listitem][Weapon_Id] == 36 && pStreak[pid] < 20) return Text_Send(pid, $CLIENT_233x);

		Text_Send(pid, $CLIENT_235x, ReturnWeaponName(WeaponInfo[listitem][Weapon_Id]), WeaponInfo[listitem][Weapon_Price]);
		GivePlayerCash(pid, -WeaponInfo[listitem][Weapon_Price]);
		GivePlayerWeapon(pid, WeaponInfo[listitem][Weapon_Id], WeaponInfo[listitem][Weapon_Ammo]);
		ShowWeaponDialog(pid);
		PlayerPlaySound(pid, 1052, 0.0, 0.0, 0.0);
	}

	Dialog_ShowCallback(playerid, using inline BriefcaseWeapons, DIALOG_STYLE_TABLIST, ""RED2"SvT - Weapons Store", overall, ">>", "<<");    
	return 1;
}

ShowBriefcase(playerid) {
	inline IncentiveFire(pid, dialogid, response, listitem, string:inputtext[]) {
		#pragma unused dialogid, inputtext
		ApplyActorAnimation(ShopActors[pTeam[pid]], "DEALER", "DEALER_DEAL", 3.0, 0, 0, 0, 0, 0);
		if (!response) return ShowBriefcase(pid);
		switch (listitem) {
			case 0: {
				ShowBriefcase(pid);

				if (GetPlayerCash(pid) < 100000) return PlayerPlaySound(pid, 1053, 0.0, 0.0, 0.0), Text_Send(pid, $CLIENT_236x);
				if (gIncentFire[pid] >= 5) return PlayerPlaySound(pid, 1053, 0.0, 0.0, 0.0), Text_Send(pid, $CLIENT_237x);
				
				PlayerPlaySound(pid, 1052, 0.0, 0.0, 0.0);
				gIncentFire[pid] += 5;
				Text_Send(pid, $CLIENT_240x);
				GivePlayerCash(pid, -100000);
			}
			case 1: {
				ShowBriefcase(pid);

				if (GetPlayerCash(pid) < 600000) return PlayerPlaySound(pid, 1053, 0.0, 0.0, 0.0), Text_Send(pid, $CLIENT_238x);
				if (gIncentFire[pid] >= 7) return PlayerPlaySound(pid, 1053, 0.0, 0.0, 0.0), Text_Send(pid, $CLIENT_237x);
				
				PlayerPlaySound(pid, 1052, 0.0, 0.0, 0.0);
				gIncentFire[pid] += 10;
				Text_Send(pid, $CLIENT_241x);
				GivePlayerCash(pid, -600000);
			}
			case 2: {
				ShowBriefcase(pid);

				if (GetPlayerCash(pid) < 1000000) return PlayerPlaySound(pid, 1053, 0.0, 0.0, 0.0), Text_Send(pid, $CLIENT_239x);
				if (gIncentFire[pid] >= 15) return PlayerPlaySound(pid, 1053, 0.0, 0.0, 0.0), Text_Send(pid, $CLIENT_237x);
				
				PlayerPlaySound(pid, 1052, 0.0, 0.0, 0.0);
				gIncentFire[pid] += 15;
				Text_Send(pid, $CLIENT_242x);
				GivePlayerCash(pid, -1000000);
			}
		}
		return 1;
	}
	inline BriefcaseEnhancements(pid, dialogid, response, listitem, string:inputtext[]) {
		#pragma unused dialogid, inputtext
		if (!response) return ShowBriefcase(pid);
		switch (listitem) {
			case 0: {
				Dialog_ShowCallback(pid, using inline IncentiveFire, DIALOG_STYLE_TABLIST, 
					"Explosive Bullets", "Incentive Bullets\t5 bullets\t$100000\n\
					Flamethrower-like\t10 bullets\t$600000\n\
					Supreme\t15 bullets\t$1000000", ">>", "<<");
			}
			case 1: {
				ApplyActorAnimation(ShopActors[pTeam[pid]], "DEALER", "DEALER_DEAL", 3.0, 0, 0, 0, 0, 0);
				if (GetPlayerCash(pid) < 700000) return PlayerPlaySound(pid, 1055, 0.0, 0.0, 0.0), Text_Send(pid, $CLIENT_243x);
				if (pKatanaEnhancement[pid]) return Text_Send(pid, $CLIENT_244x);
				pKatanaEnhancement[pid] = 10;
				GivePlayerWeapon(pid, WEAPON_KATANA, 1);
				Text_Send(pid, $CLIENT_245x);
				GivePlayerCash(pid, -700000);
				PlayerPlaySound(pid, 1057, 0.0, 0.0, 0.0);
			}
		}
	}
	inline Briefcase(pid, dialogid, response, listitem, string:inputtext[]) {
		#pragma unused dialogid, inputtext
		if (!response) return Text_Send(pid, $CLIENT_246x);
		switch (listitem) {
			case 0: {
				ApplyActorAnimation(ShopActors[pTeam[pid]], "DEALER", "DEALER_DEAL", 3.0, 0, 0, 0, 0, 0);
				if (ReturnHealth(pid) >= 100.0) return Text_Send(pid, $CLIENT_247x);
				if (GetPlayerCash(pid) < 5000) return PlayerPlaySound(pid, 1055, 0.0, 0.0, 0.0), Text_Send(pid, $CLIENT_248x);

				SetPlayerHealth(pid, 100.0);
				Text_Send(pid, $CLIENT_542x);
				GivePlayerCash(pid, -5000);
				PlayerPlaySound(pid, 1057, 0.0, 0.0, 0.0);
				ShowBriefcase(pid);
			}
			case 1: {
				new Float: AR;
				GetPlayerArmour(pid, AR);
				ApplyActorAnimation(ShopActors[pTeam[pid]], "DEALER", "DEALER_DEAL", 3.0, 0, 0, 0, 0, 0);
				if (AR >= 100.0) return Text_Send(pid, $CLIENT_543x);
				if (GetPlayerCash(pid) < 8000) return PlayerPlaySound(pid, 1055, 0.0, 0.0, 0.0), Text_Send(pid, $CLIENT_249x);

				new ARPts = floatround(AR, floatround_ceil);
				switch (ARPts) {
					case 0..24: {
						SetPlayerArmour(pid, 25.0);
						Text_Send(pid, $CLIENT_250x);
						GivePlayerCash(pid, -8000);
						PlayerPlaySound(pid, 1057, 0.0, 0.0, 0.0);
					}
					case 25..49: {
						SetPlayerArmour(pid, 50.0);
						Text_Send(pid, $CLIENT_250x);
						GivePlayerCash(pid, -8000);
						PlayerPlaySound(pid, 1057, 0.0, 0.0, 0.0);
					}
					case 50..74: {
						SetPlayerArmour(pid, 75.0);
						Text_Send(pid, $CLIENT_250x);
						GivePlayerCash(pid, -8000);
						PlayerPlaySound(pid, 1057, 0.0, 0.0, 0.0);
					}
					case 75..99: {
						SetPlayerArmour(pid, 100.0);
						Text_Send(pid, $CLIENT_251x);
						GivePlayerCash(pid, -8000);
						PlayerPlaySound(pid, 1057, 0.0, 0.0, 0.0);
					}
				}    
				ShowBriefcase(pid);
			}		
			case 2: {
				ApplyActorAnimation(ShopActors[pTeam[pid]], "DEALER", "DEALER_DEAL", 3.0, 0, 0, 0, 0, 0);
				ShowWeaponDialog(pid);
			}
			case 3: {
				ShowItemsDialog(pid);
			}
			case 4: {
				Dialog_ShowCallback(pid, using inline BriefcaseEnhancements, DIALOG_STYLE_TABLIST_HEADERS, ""RED2"SvT - Enhancements", 
					"Enhancement\tPrice\n\
					M4 Incentive Bullets\n\
					Katana Insta-kill\t"GREEN"$700000",
					">>", "<<");
			}
			case 5: {
				ShowCustomWeaponDialog(pid);
			}
		}
	}
	Dialog_ShowCallback(playerid, using inline Briefcase, DIALOG_STYLE_TABLIST_HEADERS, ""RED2"SvT - Team Briefcase",
		"Option\tPrice\n\
		Regenerate Health\t"GREEN"$5000\n\
		Purchase Armor\t"GREEN"$8000\n\
		Weapons Store\n\
		Items Store\n\
		Enhancements\n\
		Custom Weapons", ">>", "X");
	ApplyActorAnimation(ShopActors[pTeam[playerid]], "DEALER", "DEALER_DEAL", 3.0, 0, 0, 0, 0, 0);
	return 1;
}

//Terrorists' Balloon
MoveBalloon() {
	if (!ballonDestination) {
		bRouteCoords ++;
	} else {
		bRouteCoords --;
	}
	if (bRouteCoords == sizeof(ballonRouteArray)) {
		SetTimer("Balloon", 20000, false);
	} else {
		if (bRouteCoords != -1) {
			MoveDynamicObject(ballonObjectId, ballonRouteArray[bRouteCoords][0], ballonRouteArray[bRouteCoords][1], ballonRouteArray[bRouteCoords][2], 15.0);
		} else {
			bRouteCoords = 0;
		}
	}
	return 1;
}

//Initialize everything hosted by teams...
hook OnGameModeInit() {
	AddPlayerClass(28, -391.1616,2160.8269,52.7432,90.9379, 0, 0, 0, 0, 0, 0); // Terrorists
	AddPlayerClass(285, 238.4299,2045.3168,33.5527,132.5396, 0, 0, 0, 0, 0, 0); // SWAT
	AddPlayerClass(165, -1460.6924,2565.8379,71.8750,59.1582, 0, 0, 0, 0, 0, 0); // VIP

	//Reset some things
	nukePlayerId = INVALID_PLAYER_ID;
	foreach (new i: Player) {
		for (new j = 0; j < MAX_ROPES; j++) {
			pRope[i][RopeID][j] = -1;
		}
	}

	//Create some stuff

	for (new i = 0; i < sizeof(TeamInfo); i++) {
		TeamInfo[i][Team_Gangzone] = GangZoneCreate(TeamInfo[i][Team_MapArea][0], TeamInfo[i][Team_MapArea][1], TeamInfo[i][Team_MapArea][2], TeamInfo[i][Team_MapArea][3]);
		TeamInfo[i][Team_Area] = CreateDynamicRectangle(TeamInfo[i][Team_MapArea][0], TeamInfo[i][Team_MapArea][1], TeamInfo[i][Team_MapArea][2], TeamInfo[i][Team_MapArea][3]);
	}

	for (new i = 0; i < sizeof(ShopInfo); i++) {
		new title[90];
		format(title, sizeof(title), "%s\n"IVORY"Team Shop", TeamInfo[i][Team_Name]);
		ShopInfo[i][Shop_Label] = CreateDynamic3DTextLabel(title, TeamInfo[i][Team_Color], ShopInfo[i][Shop_Pos][0], ShopInfo[i][Shop_Pos][1], ShopInfo[i][Shop_Pos][2], 50.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, 0, 0);
		ShopInfo[i][Shop_Id] = CreatePickup(1210, 1, ShopInfo[i][Shop_Pos][0], ShopInfo[i][Shop_Pos][1], ShopInfo[i][Shop_Pos][2], -1);
		CreateDynamicMapIcon(ShopInfo[i][Shop_Pos][0], ShopInfo[i][Shop_Pos][1], ShopInfo[i][Shop_Pos][2], 6, 0, 0, 0, -1, 150.0, MAPICON_LOCAL);
		ShopInfo[i][Shop_Area] = CreateDynamicCircle(ShopInfo[i][Shop_Pos][0], ShopInfo[i][Shop_Pos][1], 1.0);
	}

	for (new i = 0; i < sizeof(AntennaInfo); i++) {
		new title[140];
		format(title, sizeof(title), "%s\n"IVORY"Radio Antenna", TeamInfo[i][Team_Name]);
		AntennaInfo[i][Antenna_Label] = CreateDynamic3DTextLabel(title, TeamInfo[i][Team_Color], AntennaInfo[i][Antenna_Pos][0], AntennaInfo[i][Antenna_Pos][1], AntennaInfo[i][Antenna_Pos][2], 50.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID);

		CA_FindZ_For2DCoord(AntennaInfo[i][Antenna_Pos][0], AntennaInfo[i][Antenna_Pos][1], AntennaInfo[i][Antenna_Pos][2]);
		AntennaInfo[i][Antenna_Id] = CreateDynamicObject(13758, AntennaInfo[i][Antenna_Pos][0], AntennaInfo[i][Antenna_Pos][1], AntennaInfo[i][Antenna_Pos][2], 0.0, 0.0, AntennaInfo[i][Antenna_Pos][3]);

		AntennaInfo[i][Antenna_Exists] = 1;
		AntennaInfo[i][Antenna_Hits] = 0;
	}

	for (new z = 0; z < sizeof(PrototypeInfo); z++) {
		PrototypeInfo[z][Prototype_Id] = AddStaticVehicle(428, PrototypeInfo[z][Prototype_Pos][0], PrototypeInfo[z][Prototype_Pos][1], PrototypeInfo[z][Prototype_Pos][2],
		PrototypeInfo[z][Prototype_Pos][3], 1, 2);
		PrototypeInfo[z][Prototype_Attacker] = INVALID_PLAYER_ID;

		SetVehicleHealth(PrototypeInfo[z][Prototype_Id], 1500.0);
		
		new owner[100];
		format(owner, sizeof(owner), "%s\n"IVORY"Prototype", TeamInfo[PrototypeInfo[z][Prototype_Owner]][Team_Name]);
		PrototypeInfo[z][Prototype_Text] = CreateDynamic3DTextLabel(owner, TeamInfo[PrototypeInfo[z][Prototype_Owner]][Team_Color], PrototypeInfo[z][Prototype_Pos][0], PrototypeInfo[z][Prototype_Pos][1], PrototypeInfo[z][Prototype_Pos][2], 50.0, INVALID_PLAYER_ID, PrototypeInfo[z][Prototype_Id], 1, 0, 0);
		CreateDynamicMapIcon(PrototypeInfo[z][Prototype_Pos][0], PrototypeInfo[z][Prototype_Pos][1], PrototypeInfo[z][Prototype_Pos][2], 51, 0, 0, 0, -1, 150.0, MAPICON_LOCAL);

		PrototypeInfo[z][Prototype_Cooldown] = gettime();
	}

	//Create our balloon
	ballonObjectId = CreateDynamicObject(19332, ballonRouteArray[0][0], ballonRouteArray[0][1], ballonRouteArray[0][2], 0.0, 0.0, 0.0);
	Balloon_Label = Create3DTextLabel("Balloon D'or\nPress 'N' key to fly", 0xCC0000CC, ballonRouteArray[0][0], ballonRouteArray[0][1], ballonRouteArray[0][2] + 2.0, 50.0, 0);
	ballonDestination = 0;
	bRouteCoords = 0;
	Balloon_Timer = gettime();

	//Anthrax
	g_pickups[4] = CreatePickup(1254, 1, -658.4724,2190.4504,51.2932, -1); // Anthrax
	CreateDynamic3DTextLabel("*ANTHRAX SKULL*", X11_DEEPSKYBLUE, -658.4724,2190.4504,51.2932, 50.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, 0, 0);

	//Create an entrable area for both nuke and anthrax
	Anthrax_Area = CreateDynamicCircle(-658.4724,2190.4504,2.0);
	Nuke_Area = CreateDynamicCircle(-352.8720,1584.9048,2.0);
	return 1;
}

//Of course remove everything related to teams at once!
hook OnGameModeExit() {
	for (new b = 0; b < sizeof(TeamInfo); b++) {
		GangZoneDestroy(TeamInfo[b][Team_Gangzone]);
	}

	for (new i = 0; i < sizeof(ShopInfo); i++) {
		DestroyPickup(ShopInfo[i][Shop_Id]);
	}

	for (new i = 0; i < sizeof(AntennaInfo); i++) {
		DestroyDynamicObject(AntennaInfo[i][Antenna_Id]);

		AntennaInfo[i][Antenna_Exists] = 0;
		AntennaInfo[i][Antenna_Hits] = 0;
	}

	for (new i = 0; i < sizeof(PrototypeInfo); i++) {
		DestroyVehicle(PrototypeInfo[i][Prototype_Id]);
		PrototypeInfo[i][Prototype_Attacker] = INVALID_PLAYER_ID;
	}

	//Remove our balloon
	KillTimer(Balloontimer);
	DestroyDynamicObject(ballonObjectId);
	Delete3DTextLabel(Balloon_Label);
	return 1;
}

hook OnPlayerConnect(playerid) {
	pTeam[playerid] = TERRORIST; //We want em' terrorists by default!

	//Ready player H2O
	for (new i = 0; i < sizeof(TeamInfo); i++) {
		GangZoneShowForPlayer(playerid, TeamInfo[i][Team_Gangzone], ALPHA(TeamInfo[i][Team_Color], 100));
	}

	for (new i = 0; i < sizeof(ZoneInfo); i++) {
		GangZoneShowForPlayer(playerid, ZoneInfo[i][Zone_Id], ALPHA(ZoneInfo[i][Zone_Owner] != NO_TEAM ? TeamInfo[ZoneInfo[i][Zone_Owner]][Team_Color] : 0xFFFFFFFF, 100));
	}

	//Ain't no spies
	PlayerInfo[playerid][pSpyTeam] = -1;

	//Of course not selecting a team on connection?
	pTeamSTimer[playerid] = -1;
	return 1;
}

hook OnPlayerDisconnect(playerid, reason) {
	//Player left during selection waiting time? Abort.
	KillTimer(pTeamSTimer[playerid]);

	//Reset prototype data for this player
	for (new i = 0; i < sizeof(PrototypeInfo); i++) {
		if (PrototypeInfo[i][Prototype_Attacker] == playerid) {
			DisablePlayerRaceCheckpoint(playerid);
			SetVehicleToRespawn(PrototypeInfo[i][Prototype_Id]);

			Text_Send(@pVerified, $SERVER_50x, PlayerInfo[playerid][PlayerName], TeamInfo[PrototypeInfo[i][Prototype_Owner]][Team_Name]);
			PrototypeInfo[i][Prototype_Attacker] = INVALID_PLAYER_ID;

			break;
		}
	}

	//No need to keep gangzones displayed anymore
	for (new i = 0; i < sizeof(TeamInfo); i++) {
		GangZoneHideForPlayer(playerid, TeamInfo[i][Team_Gangzone]);
	}

	//No anthrax
	KillTimer(PlayerInfo[playerid][pAnthraxTimer]);

	if (IsValidDynamicObject(PlayerInfo[playerid][pAnthrax])) {
		DestroyDynamicObject(PlayerInfo[playerid][pAnthrax]);
	}
	PlayerInfo[playerid][pAnthrax] = INVALID_OBJECT_ID;
	for (new i = 0; i < 17; i++) {
		if (IsValidDynamicObject(PlayerInfo[playerid][pAnthraxEffects][i])) {
			DestroyDynamicObject(PlayerInfo[playerid][pAnthraxEffects][i]);
		}
		PlayerInfo[playerid][pAnthraxEffects][i] = INVALID_OBJECT_ID;
	}
	return 1;
}

//This is mostly related to the selection system, which is also related to teams? Hence we put this here
hook OnPlayerRequestClass(playerid, classid) {
	PlayerInfo[playerid][pSelecting] = 1;

	if (!PlayerInfo[playerid][pLoggedIn]) {
		return 1;
	}

    new randcampos = random(2);
    switch (randcampos) {
        case 0: {
			InterpolateCameraPos(playerid, -755.4227,2245.6294,72.2243, -753.3530,2210.8455,53.5234, 6500, CAMERA_MOVE);
			InterpolateCameraLookAt(playerid, -753.3530,2210.8455,53.5234, -745.8900,2200.1982,51.0226, 6500, CAMERA_MOVE);
		}
        case 1: {
			InterpolateCameraPos(playerid, -796.4103,2242.9009,62.9400, -753.3530,2210.8455,53.5234, 6500, CAMERA_MOVE);
			InterpolateCameraLookAt(playerid, -753.3530,2210.8455,53.5234, -745.8900,2200.1982,51.0226, 6500, CAMERA_MOVE);
		}
    }

    Streamer_UpdateEx(playerid, -745.8900, 2200.1982, 51.0226);

    SetPlayerPos(playerid, -745.8900, 2200.1982, 51.0226);
    SetPlayerFacingAngle(playerid, 35.0305);

	if (classid >= 0 && classid < sizeof(TeamInfo)) {
		pTeam[playerid] = classid;
	} else {
		pTeam[playerid] = 0;
	}

	new string[45];
	format(string, sizeof(string), "%s%s", TeamInfo[pTeam[playerid]][Chat_Bub], TeamInfo[pTeam[playerid]][Team_Name]);
	GameTextForPlayer(playerid, string, 1200, 3);
	return 1;
}

//Player wants to spawn!
hook OnPlayerRequestSpawn(playerid) {
	if (!PlayerInfo[playerid][pLoggedIn]) return 0;
	
	if (pTeam[playerid] == VIP && !PlayerInfo[playerid][pDonorLevel]) {
		if (!IsPlayerInAnyClan(playerid) || GetClanTeam(GetPlayerClan(playerid)) != VIP) {
			Text_Send(playerid, $CLIENT_272x);
			return 0;
		}
	}

	new counter[2];
	
	foreach (new i: Player) {
		if (pTeam[i] == pTeam[playerid] && i != playerid) {
			counter[0]++;
		} else {
			counter[1]++;
		}
	}

	if (counter[0] > counter[1]) {
		if (counter[0] - counter[1] > 2) {
			if (pTeam[playerid] != VIP) {
				Text_Send(playerid, $CLIENT_273x);
				return 0;
			}
		}
	}
	return 1;
}

hook OnPlayerSpawn(playerid) {
	//Player's in VIP team and they aren't supposed to?
	if (pTeam[playerid] == VIP && !PlayerInfo[playerid][pDonorLevel]) {
		if (!IsPlayerInAnyClan(playerid) || GetClanTeam(GetPlayerClan(playerid)) != VIP) {
			ForceClassSelection(playerid);
			return SpawnPlayer(playerid);
		}
	}

	//Player spawned and is in selection now
	if (PlayerInfo[playerid][pSelecting]) {
		if (PlayerInfo[playerid][pLoggedIn]) {
			switch (pTeam[playerid]) {
				case SWAT: ShowModelSelectionMenu(playerid, sskinlist, "SWAT Skins", 0x000000CC, X11_BLUE, X11_IVORY);
				case TERRORIST: ShowModelSelectionMenu(playerid, tskinlist, "Terrorist Skins", 0x000000CC, X11_RED2, X11_IVORY);
				case VIP: ShowModelSelectionMenu(playerid, skinlist, "VIP Skins", 0x000000CC, X11_GREEN, X11_IVORY);
			}
		}

		switch (pTeam[playerid]) {  
			case SWAT: {
				SetPlayerPos(playerid, 238.4299,2045.3168,33.5527);
				SetPlayerFacingAngle(playerid, 132.5396);
				SetPlayerCameraPos(playerid, 234.5460,2041.0024,36.0514);
				SetPlayerCameraLookAt(playerid, 238.4299,2045.3168,33.5527, CAMERA_MOVE);
			} 
			case TERRORIST: {
				SetPlayerPos(playerid, -391.1616,2160.8269,52.7432);
				SetPlayerFacingAngle(playerid, 90.9379);
				SetPlayerCameraPos(playerid, -396.8252,2160.7493,55.1709);
				SetPlayerCameraLookAt(playerid, -391.1616,2160.8269,52.7432, CAMERA_MOVE);
			}
			case VIP: {
				SetPlayerPos(playerid, -1460.6924,2565.8379,71.8750);
				SetPlayerFacingAngle(playerid, 59.1582);
				SetPlayerCameraPos(playerid, -1468.4069,2570.2896,75.3104);
				SetPlayerCameraLookAt(playerid, -1460.6924,2565.8379,71.8750, CAMERA_MOVE);
			}
		}

		SetPlayerVirtualWorld(playerid, playerid + 5);
		return 1;
	}

	//Apply first spawn stuff
	if (pFirstSpawn[playerid]) {
		Text_Send(playerid, $PLEASE_WAIT);
		TogglePlayerControllable(playerid, false);
		SetPlayerPos(playerid, TeamInfo[pTeam[playerid]][Spawn_1][0] - 1.0, TeamInfo[pTeam[playerid]][Spawn_1][1] + 1.0, TeamInfo[pTeam[playerid]][Spawn_1][2]);
		SetPlayerVirtualWorld(playerid, 401);

		Text_Send(playerid, $CLIENT_391x, RankInfo[PlayerRank[playerid]][Rank_Name]);

		InterpolateCameraPos(playerid, -755.4227, 2245.6294, 172.2243, TeamInfo[pTeam[playerid]][Spawn_1][0], TeamInfo[pTeam[playerid]][Spawn_1][1], TeamInfo[pTeam[playerid]][Spawn_1][2] + 100.0, 7000, CAMERA_MOVE);
		InterpolateCameraLookAt(playerid,TeamInfo[pTeam[playerid]][Spawn_1][0], TeamInfo[pTeam[playerid]][Spawn_1][1], TeamInfo[pTeam[playerid]][Spawn_1][2] + 100.0, TeamInfo[pTeam[playerid]][Spawn_1][0], TeamInfo[pTeam[playerid]][Spawn_1][1], TeamInfo[pTeam[playerid]][Spawn_1][2], 7500, CAMERA_MOVE);
		FirstSpawn_Timer[playerid] = SetTimerEx("EndFirstSpawn", 10000, false, "i", playerid);
		return 1;
	}

	//Update team war data for this player..?
	UpdateTeamWarForPlayer(playerid);

	//Prototype
	for (new i = 0; i < sizeof(PrototypeInfo); i++) {
		if (PrototypeInfo[i][Prototype_Attacker] == playerid) {
			DisablePlayerRaceCheckpoint(playerid);
			SetVehicleToRespawn(PrototypeInfo[i][Prototype_Id]);
			Text_Send(@pVerified, $SERVER_50x, PlayerInfo[playerid][PlayerName], TeamInfo[PrototypeInfo[i][Prototype_Owner]][Team_Name]);
			Text_Send(playerid, "~r~TRY AGAIN");
			PrototypeInfo[i][Prototype_Attacker] = INVALID_PLAYER_ID;
			break;
		}
	}
	return 1;
}

//Player team list selection
hook OnPlayerModelSelection(playerid, response, listid, modelid) {
	if (listid == tskinlist) {
		if (response) {
			SetPlayerSkin(playerid, modelid);
			pSkin[playerid] = modelid;
			ShowPlayerClass(playerid);
		} else {
			Text_Send(playerid, $SKIN_NOTIF);
			SetPlayerSkin(playerid, 28);
			pSkin[playerid] = 28;
			ShowPlayerClass(playerid);
		}
		return 1;
	}
	if (listid == sskinlist) {
		if (response) {
			SetPlayerSkin(playerid, modelid);
			pSkin[playerid] = modelid;

			new string[40];
			format(string, sizeof(string), "%s%s", TeamInfo[pTeam[playerid]][Chat_Bub], TeamInfo[pTeam[playerid]][Team_Name]);
			GameTextForPlayer(playerid, string, 1000, 3);
			ShowPlayerClass(playerid);
		} else {
			SetPlayerSkin(playerid, 285);
			pSkin[playerid] = 285;
			ShowPlayerClass(playerid);
		}
		return 1;
	}
	if (listid == skinlist) {
		if (response) {
			SetPlayerSkin(playerid, modelid);
			pSkin[playerid] = modelid;
			ShowPlayerClass(playerid);
		} else {
			Text_Send(playerid, $SKIN_NOTIF);
			SetPlayerSkin(playerid, 165);
			pSkin[playerid] = 165;
			ShowPlayerClass(playerid);
		}
		return 1;
	}
	return 1;
}

//Check if player left a prototype?
hook OnPlayerStateChange(playerid, newstate, oldstate) {
	if (oldstate == PLAYER_STATE_DRIVER) {
		for (new i = 0; i < sizeof(PrototypeInfo); i++) {
			if (PrototypeInfo[i][Prototype_Attacker] == playerid && !IsPlayerInVehicle(playerid, PrototypeInfo[i][Prototype_Id])) {
				PlayerInfo[playerid][pLeavetime] = gettime() + 25;
				Text_Send(playerid, $PROTOTYPE_TIMELEFT, PlayerInfo[playerid][pLeavetime] - gettime());
				PlayerPlaySound(playerid, 1095, 0.0, 0.0, 0.0);
				break;
			}
		}
	}
	if (newstate == PLAYER_STATE_DRIVER) {
		for (new i = 0; i < sizeof(PrototypeInfo); i++) {
			if (GetPlayerVehicleID(playerid) == PrototypeInfo[i][Prototype_Id]) {
				if (gettime() >= PrototypeInfo[i][Prototype_Cooldown]) {
					switch (pTeam[playerid]) {
						case TERRORIST: SetPlayerRaceCheckpoint(playerid, 1, -374.3204,2375.4495,33.2926, 0.0, 0.0, 0.0, 10.0);
						case VIP: SetPlayerRaceCheckpoint(playerid, 1, -1368.4176,2203.0393,51.5420, 0.0, 0.0, 0.0, 10.0);
						case SWAT: SetPlayerRaceCheckpoint(playerid, 1, 107.8350,1927.3177,18.2402, 0.0, 0.0, 0.0, 10.0);
					}
					PrototypeInfo[i][Prototype_Attacker] = playerid;
					Text_Send(playerid, $CLIENT_281x);
				} else {
					Text_Send(playerid, $CLIENT_282x);
					
					new Float: X, Float: Y, Float: Z;
					GetPlayerPos(playerid, X, Y, Z);
					SetPlayerPos(playerid, X, Y, Z);
				}
				break;
			}
		}
	}
	return 1;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
	if (gRappelling[playerid]) {
		gRappelling[playerid] = 0;
		ClearAnimations(playerid);

		for (new i = 0; i < MAX_ROPES; i++) {
			if (pRope[playerid][RopeID][i] == -1) {
				break;
			}

			DestroyDynamicObject(pRope[playerid][RopeID][i]);
			pRope[playerid][RopeID][i] = -1;
		}
	}

	if (PRESSED(KEY_YES) && GetPlayerState(playerid) == PLAYER_STATE_ONFOOT && !GetPlayerInterior(playerid) && !GetPlayerVirtualWorld(playerid)) {
		new Float: x, Float: y, Float: z2, Float: dist;
		GetPlayerPos(playerid, x, y, z2);

		new Float: z;
		CA_FindZ_For2DCoord(x, y, z);
		//Dynamite defusing for SWAT
		if (pTeam[playerid] == SWAT) {
			for (new i = 0; i < MAX_SLOTS; i++) {
				if (gDynamiteExists[i] &&
					IsPlayerInDynamicArea(playerid, gDynamiteArea[i])) {
					AnimPlayer(playerid, "BOMBER", "BOM_Plant", 4.0, 0, 0, 0, 0, 0);
					Text_Send(playerid, $CLIENT_405x, PlayerInfo[gDynamitePlacer[i]][PlayerName], gDynamiteCD[i] - gettime());
					GivePlayerScore(playerid, 1);
					Text_Send(gDynamitePlacer[i], $CLIENT_406x, PlayerInfo[playerid][PlayerName], playerid, gDynamiteCD[i] - gettime());
					break;
				}
			}
		}
		//Rope rappelling for SWAT (again)
		if (pTeam[playerid] == SWAT && !gRappelling[playerid] && z2 > z && z2 < 120.0 && GetPlayerState(playerid) == PLAYER_STATE_PASSENGER
			&& !gRappelling[playerid] && (GetVehicleModel(GetPlayerVehicleID(playerid)) == 497 || GetVehicleModel(GetPlayerVehicleID(playerid)) == 497)) {
			z += 10.0;

			RemovePlayerFromVehicle(playerid);

			GetPlayerPos(playerid, pRope[playerid][RRX], pRope[playerid][RRY], pRope[playerid][RRZ]);
			SetPlayerPos(playerid, x, y, z2 - 5);

			gRappelling[playerid] = 1;
			ApplyAnimation(playerid, "ped", "abseil", 4.0, 0, 0, 0, 1, 0);

			dist = GetPlayerDistanceFromPoint(playerid, x, y, z);

			new numropes = floatround(floatdiv(dist, 5.1), floatround_ceil);
			CreateRope(playerid, numropes);
		} else if (gRappelling[playerid]) {
			ClearAnimations(playerid);

			for (new i = 0; i < MAX_ROPES; i++) {
				if (pRope[playerid][RopeID][i] == -1) {
					break;
				}

				DestroyDynamicObject(pRope[playerid][RopeID][i]);
				pRope[playerid][RopeID][i] = -1;
			}
		}
	}
	//Hot air balloon :)
	if (PRESSED(KEY_NO) &&
		IsPlayerInRangeOfPoint(playerid, 3.0, ballonRouteArray[0][0], ballonRouteArray[0][1], ballonRouteArray[0][2]) && !IsPlayerInAnyVehicle(playerid)) {
		if (bRouteCoords == 0) {
			if (pTeam[playerid] == TERRORIST) {
				if (Balloon_Timer < gettime()) {
					Balloon_Timer = gettime() + 15;
					Text_Send(@pVerified, $SERVER_23x, PlayerInfo[playerid][PlayerName]);
					Text_Send(playerid, $CLIENT_252x);
					Balloontimer = SetTimer("Balloon", 11000, false);
				}  else Text_Send(playerid, $CLIENT_253x);
			}  else Text_Send(playerid, $CLIENT_254x);
		}  else Text_Send(playerid, $CLIENT_255x);
	}	
}

hook OnPlayerDeath(playerid, killerid, reason) {
	PlayerInfo[playerid][pBackup] = INVALID_PLAYER_ID;
	return 1;
}

//Prototype checkup
hook OnVehicleStreamIn(vehicleid, forplayerid) {
	for (new i = 0; i < sizeof(PrototypeInfo); i++) {
		if (vehicleid == PrototypeInfo[i][Prototype_Id]) {
			if (PrototypeInfo[i][Prototype_Attacker] != INVALID_PLAYER_ID || pTeam[forplayerid] == PrototypeInfo[i][Prototype_Owner]) {
				SetVehicleParamsForPlayer(PrototypeInfo[i][Prototype_Id], forplayerid, 1, 1);
			}
			else {
				SetVehicleParamsForPlayer(PrototypeInfo[i][Prototype_Id], forplayerid, 1, 0);
			}

			break;
		}
	}
	return 1;
}

//Prototype checkpoint checkup
hook OnPlayerEnterRaceCP(playerid) {
	if (Iter_Contains(ePlayers, playerid)) return true;
	if (IsPlayerInAnyVehicle(playerid)) {
		new vehicleid = GetPlayerVehicleID(playerid);

		for (new x = 0; x < sizeof(PrototypeInfo); x++) {
			if (vehicleid == PrototypeInfo[x][Prototype_Id] && PrototypeInfo[x][Prototype_Attacker] == playerid) {
				Text_Send(playerid, $PROTOTYPE_STOLEN, TeamInfo[PrototypeInfo[x][Prototype_Owner]][Team_Name]);
				PlayAudioStreamForPlayer(playerid, "http://51.254.181.90/server/progress.mp3", 0.0, 0.0, 0.0, 0.0, 0);

				new crate = random(100);
				switch (crate) {
					case 0..35: {
						PlayerInfo[playerid][pCrates] ++;
						Text_Send(playerid, $CRATE_RECEIVED);
					}
				}

				PlayerInfo[playerid][pEXPEarned] += 1;
				if (WarInfo[War_Started] == 1) {
					if ((pTeam[playerid] == WarInfo[War_Team1] && x == WarInfo[War_Team2]) ||
					(pTeam[playerid] == WarInfo[War_Team2] && x == WarInfo[War_Team1])) {
						AddTeamWarScore(playerid, 1);
					}
				}

				SetVehicleToRespawn(vehicleid);

				GivePlayerCash(playerid, 10000);
				GivePlayerScore(playerid, 5);

				PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);

				PrototypeInfo[x][Prototype_Attacker] = INVALID_PLAYER_ID;

				PrototypeInfo[x][Prototype_Cooldown] = gettime() + 300;

				if (WarInfo[War_Started]) {
					if ((pTeam[playerid] == WarInfo[War_Team1] && x == WarInfo[War_Team2]) ||
					(pTeam[playerid] == WarInfo[War_Team2] && x == WarInfo[War_Team1])) {
						AddTeamWarScore(playerid, 4);
					}
				}

				Text_Send(@pVerified, $SERVER_43x, PlayerInfo[playerid][PlayerName], TeamInfo[PrototypeInfo[x][Prototype_Owner]][Team_Name]);
				PlayerInfo[playerid][pPrototypesStolen] ++;
				
				foreach (new i: Player) {
					if (pTeam[i] == PrototypeInfo[x][Prototype_Owner] && !GetPlayerInterior(i) && !GetPlayerVirtualWorld(i) && IsPlayerSpawned(i)) {
						Text_Send(i, $PROTOTYPE_LOST);
						GivePlayerScore(i, -1);
						PlayerPlaySound(i, 1057, 0.0, 0.0, 0.0);
					}
				}

				break;
			}
		}
	}
	return 1;
}

hook OnPlayerEnterDynArea(playerid, areaid) {
	if (IsPlayerSpawned(playerid) && !GetPlayerInterior(playerid) && !GetPlayerVirtualWorld(playerid) && !AntiSK[playerid]) {		
		if (Nuke_Area == areaid) { //Nuke checkup
			if (ZoneInfo[NUKE_STATION][Zone_Owner] != pTeam[playerid]) return Text_Send(playerid, $NUKE_STATION_NEEDED);
			if (GetPlayerCash(playerid) < 150000 || GetPlayerScore(playerid) < 15000) return Text_Send(playerid, $CLIENT_166x);
			if (nukeCooldown > gettime() && nukeIsLaunched) {
				Text_Send(playerid, $CLIENT_167x, nukeCooldown - gettime());
			} else {
				if (PlayerInfo[playerid][pAdminDuty] == 1) return 0;

				new alt[50], string[50 * (sizeof(TeamInfo))], count[sizeof(TeamInfo)] = 0;

				format(string, sizeof(string), "Team\tPlayers in base\n");

				for (new i = 0; i < sizeof(TeamInfo); i++) {
					foreach (new x: Player) {
						if (pTeam[x] != pTeam[playerid] && IsPlayerInBase(x) == 1)
						{
							count[pTeam[x]] ++;
						}
					}

					format(alt, sizeof(alt), "{%06x}%s\t%d\n", TeamInfo[i][Team_Color] >>> 8, TeamInfo[i][Team_Name], count[i]);
					strcat(string, alt);
				}

				inline Nuke(pid, dialogid, response, listitem, string:inputtext[]) {
					#pragma unused dialogid, inputtext
					if (!response) {
						Text_Send(pid, $CLIENT_168x);
						return 1;
					}

					if (nukeIsLaunched) return Text_Send(pid, $CLIENT_169x);
					if (listitem == pTeam[pid]) return Text_Send(pid, $CLIENT_170x);
					Nuke_Priority = 2;

					Text_Send(@pVerified, $SERVER_20x, PlayerInfo[pid][PlayerName], TeamInfo[listitem][Team_Name]);
					printf("The nuke was started by %s[%d]", PlayerInfo[pid][PlayerName], pid);

					KillTimer(NukeTimer[pid]);
					NukeTimer[pid] = SetTimerEx("OnNukeLaunch", 8000 + (1000 * Nuke_Priority), false, "ii", pid, listitem);
					nukeCooldown = gettime() + 500;
					nukeIsLaunched = 1;
					nukePlayerId = pid;

					Text_Send(pid, $CLIENT_171x);
					GivePlayerCash(pid, -150000);
					PlayerInfo[pid][pNukesLaunched] ++;
				}

				Dialog_ShowCallback(playerid, using inline Nuke, DIALOG_STYLE_TABLIST_HEADERS, "Nuclear", string, ">>", "X");
			}
		}
		//Anthrax checkup, another team feature
		if (Anthrax_Area == areaid) {
			if (GetPlayerCash(playerid) < 500000 || GetPlayerScore(playerid) < 50000) return PlayerPlaySound(playerid, 1055, 0.0, 0.0, 0.0), Text_Send(playerid, $CLIENT_303x);
			if (ZoneInfo[BATTLESHIP][Zone_Owner] != pTeam[playerid]) return Text_Send(playerid, $CLIENT_304x);
			if (gAnthraxCooldown > gettime()) {
				Text_Send(playerid, $CLIENT_415x, gAnthraxCooldown - gettime());
				return 1;
			}

			inline ConfirmAnthrax(pid, dialogid, response, listitem, string:inputtext[]) {
				#pragma unused dialogid, listitem, inputtext
				if (!response) return 1;

				GivePlayerCash(pid, -500000);
				Text_Send(pid, $CLIENT_305x);

				Text_Send(@pVerified, $SERVER_30x, PlayerInfo[pid][PlayerName], TeamInfo[pTeam[pid]][Team_Name]);

				gAnthraxOwner = pTeam[pid];
				gAnthraxCooldown = gettime() + (60 * 30);
				PlayerPlaySound(pid, 1054, 0.0, 0.0, 0.0);
			}

			Text_DialogBox(playerid, DIALOG_STYLE_MSGBOX, using inline ConfirmAnthrax, $DIALOG_MESSAGE_CAP, $CONFIRM_ANTHRAX, $DIALOG_YES, $DIALOG_NO);
		}
		//Player entered a TEAM base
		for (new a = 0; a < sizeof(TeamInfo); a++) {
			if (TeamInfo[a][Team_Area] == areaid) {
				new String_Name[100];
				format(String_Name, sizeof(String_Name), "You have entered %s.", TeamInfo[a][Team_Name]);
				NotifyPlayer(playerid, String_Name);
				break;
			}
		}
		//Player accessed a TEAM shop
		if (!IsPlayerInAnyVehicle(playerid)) {
			for (new i = 0; i < sizeof(ShopInfo); i++) {
				if (ShopInfo[i][Shop_Area] == areaid) {
					if (pTeam[playerid] == i) {
						pShopDelay[playerid] = gettime() + 3;
						ShowBriefcase(playerid);
					} else {
						Text_Send(playerid, $CLIENT_306x);
					}

					break;
				}
			}
		}
	}
	return 1;
}

hook OnDynObjectMoved(objectid) {
	//Terrorists' Balloon
	if (ballonObjectId == objectid) {
		MoveBalloon();
	}

	//Anthrax related
	foreach (new i: Player) {
		if (PlayerInfo[i][pAnthrax] == objectid) {
			new Float: X, Float: Y, Float: Z;
			GetDynamicObjectPos(PlayerInfo[i][pAnthrax], X, Y, Z);
			DestroyDynamicObject(PlayerInfo[i][pAnthrax]);
			PlayerInfo[i][pAnthrax] = INVALID_OBJECT_ID;
			for (new x = 0; x < 17; x++) {
				if (IsValidDynamicObject(PlayerInfo[i][pAnthraxEffects][x])) {
					DestroyDynamicObject(PlayerInfo[i][pAnthraxEffects][x]);
				}
				PlayerInfo[i][pAnthraxEffects][x] = INVALID_OBJECT_ID;
			}
			PlayerInfo[i][pAnthraxEffects][0] = CreateDynamicObject(18732, X, Y, Z, 0.0, 0.0, 0.0);
			PlayerInfo[i][pAnthraxEffects][1] = CreateDynamicObject(18732, X + 5, Y, Z, 0.0, 0.0, 0.0);
			PlayerInfo[i][pAnthraxEffects][2] = CreateDynamicObject(18732, X - 5, Y, Z, 0.0, 0.0, 0.0);
			PlayerInfo[i][pAnthraxEffects][3] = CreateDynamicObject(18732, X + 10, Y, Z, 0.0, 0.0, 0.0);
			PlayerInfo[i][pAnthraxEffects][4] = CreateDynamicObject(18732, X - 10, Y, Z, 0.0, 0.0, 0.0);
			PlayerInfo[i][pAnthraxEffects][5] = CreateDynamicObject(18732, X + 15, Y, Z, 0.0, 0.0, 0.0);
			PlayerInfo[i][pAnthraxEffects][6] = CreateDynamicObject(18732, X - 20, Y, Z, 0.0, 0.0, 0.0);
			PlayerInfo[i][pAnthraxEffects][7] = CreateDynamicObject(18732, X + 25, Y, Z, 0.0, 0.0, 0.0);
			PlayerInfo[i][pAnthraxEffects][8] = CreateDynamicObject(18732, X - 25, Y, Z, 0.0, 0.0, 0.0);
			PlayerInfo[i][pAnthraxEffects][9] = CreateDynamicObject(18732, X, Y + 5, Z, 0.0, 0.0, 0.0);
			PlayerInfo[i][pAnthraxEffects][10] = CreateDynamicObject(18732, X, Y - 5, Z, 0.0, 0.0, 0.0);
			PlayerInfo[i][pAnthraxEffects][11] = CreateDynamicObject(18732, X, Y + 10, Z, 0.0, 0.0, 0.0);
			PlayerInfo[i][pAnthraxEffects][12] = CreateDynamicObject(18732, X, Y - 10, Z, 0.0, 0.0, 0.0);
			PlayerInfo[i][pAnthraxEffects][13] = CreateDynamicObject(18732, X, Y + 15, Z, 0.0, 0.0, 0.0);
			PlayerInfo[i][pAnthraxEffects][14] = CreateDynamicObject(18732, X, Y - 15, Z, 0.0, 0.0, 0.0);
			PlayerInfo[i][pAnthraxEffects][15] = CreateDynamicObject(18732, X, Y + 20, Z, 0.0, 0.0, 0.0);
			PlayerInfo[i][pAnthraxEffects][16] = CreateDynamicObject(18732, X, Y - 20, Z, 0.0, 0.0, 0.0);
			PlayerInfo[i][pAnthraxTimes] = 40;
			PlayerInfo[i][pAnthraxTimer] = SetTimerEx("AnthraxToxication", 500, false, "ifff", i, X, Y, Z);
			PlayerInfo[i][pAnthraxIntoxications] ++;
			new Float: range;
			if (PlayerInfo[i][pDonorLevel] < 5) {
				range = 35.0;
			} else {
				range = 45.0;
			}
			foreach(new x: Player) {
				if (IsPlayerInRangeOfPoint(x, range, X, Y, Z)) {
					PlayAudioStreamForPlayer(x, "https://www.h2omultiplayer.com/server/nuke.mp3", 0.0, 0.0, 0.0, 0.0, 0);
				}
			}
		}
	}	
}

//Player wants to switch their team?
alias:st("switchteam");
CMD:st(playerid) {
	if (pDuelInfo[playerid][pDInMatch] == 1) return Text_Send(playerid, $COMMAND_INDUEL);
	if (PlayerInfo[playerid][pDeathmatchId] > -1) return Text_Send(playerid, $COMMAND_INDM);
	if (Iter_Contains(ePlayers, playerid)) return Text_Send(playerid, $COMMAND_INEVENT);
	if (Iter_Contains(CWCLAN1, playerid) || Iter_Contains(CWCLAN2, playerid)) return Text_Send(playerid, $COMMAND_INCW);
	if (Iter_Contains(PUBGPlayers, playerid)) return Text_Send(playerid, $COMMAND_INPUBG);
	if (PlayerInfo[playerid][pLastHitTick] > gettime()) return Text_Send(playerid, $JUSTHIT, PlayerInfo[playerid][pLastHitTick] - gettime());

	if (GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) return Text_Send(playerid, $COMMAND_NOTONFOOT);
	KillTimer(pTeamSTimer[playerid]);

	Text_Send(playerid, $TEAM_SWITCH);
	PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);

	if (AntiSK[playerid]) {
		EndProtection(playerid);
	}

	pTeamSTimer[playerid] = SetTimerEx("SwitchTeam", 5000, false, "i", playerid);
	return 1;
}

//Request backup, alerts team members
CMD:backup(playerid) {
	if (pDuelInfo[playerid][pDInMatch] == 1) return Text_Send(playerid, $COMMAND_INDUEL);
	if (PlayerInfo[playerid][pDeathmatchId] > -1) return Text_Send(playerid, $COMMAND_INDM);
	if (Iter_Contains(ePlayers, playerid)) return Text_Send(playerid, $COMMAND_INEVENT);
	if (Iter_Contains(CWCLAN1, playerid) || Iter_Contains(CWCLAN2, playerid)) return Text_Send(playerid, $COMMAND_INCW);
	if (Iter_Contains(PUBGPlayers, playerid)) return Text_Send(playerid, $COMMAND_INPUBG);

	if (pBackupRequested[playerid] == 1) return Text_Send(playerid, $CLIENT_433x);
	pBackupRequested[playerid] = 1;
	PlayerInfo[playerid][pBackupAttempts] ++;

	foreach (new i: Player) {
		if (pTeam[i] == pTeam[playerid] && !GetPlayerInterior(i) && !GetPlayerVirtualWorld(i) && IsPlayerSpawned(i)) {
			Text_Send(i, $CLIENT_435x, PlayerInfo[playerid][PlayerName]);
		}
	}    
	return 1;
}

//Respond to a team backup request
alias:respond("responda");
CMD:respond(playerid, params[]) {
	if (pDuelInfo[playerid][pDInMatch] == 1) return Text_Send(playerid, $COMMAND_INDUEL);
	if (PlayerInfo[playerid][pDeathmatchId] > -1) return Text_Send(playerid, $COMMAND_INDM);
	if (Iter_Contains(ePlayers, playerid)) return Text_Send(playerid, $COMMAND_INEVENT);
	if (Iter_Contains(CWCLAN1, playerid) || Iter_Contains(CWCLAN2, playerid)) return Text_Send(playerid, $COMMAND_INCW);
	if (Iter_Contains(PUBGPlayers, playerid)) return Text_Send(playerid, $COMMAND_INPUBG);

	new in_proto = 0;
	
	for (new i = 0; i < sizeof(PrototypeInfo); i++) {
		if (PrototypeInfo[i][Prototype_Attacker] == playerid) {
			in_proto = 1;
			break;
		}
	}

	if (in_proto) return Text_Send(playerid, $CLIENT_436x);

	new targetid;

	if (sscanf(params, "i", targetid)) return ShowSyntax(playerid, "/respond [ID]");
	if (!IsPlayerConnected(targetid) || targetid == INVALID_PLAYER_ID) return Text_Send(playerid, $CLIENT_320x);
	if (pTeam[targetid] != pTeam[playerid] || pBackupRequested[targetid] == 0 || playerid == targetid ||
		pDuelInfo[targetid][pDInMatch] == 1 || PlayerInfo[targetid][pDeathmatchId] > -1 || Iter_Contains(ePlayers, targetid) ||
		Iter_Contains(CWCLAN1, targetid)) return Text_Send(playerid, $CLIENT_437x);

	pBackupRequested[targetid] = 0;
	Text_Send(playerid, $CLIENT_438x);

	pBackupResponded[playerid] = 1;
	PlayerInfo[playerid][pBackupsResponded] ++;
	PlayerInfo[playerid][pBackup] = targetid;

	PlayerPlaySound(targetid, 1057, 0.0, 0.0, 0.0);
	PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);

	gBackupTimer[playerid] = gettime() + 75;
	return 1;
}

//Team radio is of course related to teams
flags:tr(CMD_SECRET); 
CMD:tr(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel] < svtconf[max_admin_level] && svtconf[anti_adv] && AdCheck(params)) {
		Text_Send(playerid, $ADV_ALERT);

		new adcheck[150];
		format(adcheck, sizeof(adcheck), "*%s[%d] has attempted to advertise: %s", PlayerInfo[playerid][PlayerName],
		playerid, params);

		MessageToAdmins(X11_IVORY, adcheck);
		print(adcheck);
		 
		PlayerInfo[playerid][pAdvAttempts] ++;
		return 1;
	}

	if (PlayerInfo[playerid][pMuted] == 1) {
		if (PlayerInfo[playerid][pSpamWarnings] < 3) {
			PlayerInfo[playerid][pSpamWarnings] ++;
			PlayerInfo[playerid][pSpamAttempts] ++;
			Text_Send(playerid, $MUTED);
		} else printf("Player %s[%d] was kicked for trying to evade chat mute warnings.", PlayerInfo[playerid][PlayerName], playerid), Kick(playerid);
		return 1;
	}

	if (PlayerInfo[playerid][pDeathmatchId] !=-1) {
		Text_Send(playerid, $CLIENT_436x);
	}	

	if (AntennaInfo[pTeam[playerid]][Antenna_Exists] == 0) {
		Text_Send(playerid, $CLIENT_433x);
		return 1;
	}

	new String[128 + MAX_PLAYER_NAME], adminstr[140];

	format(String, sizeof(String), "[RADIO][..] %s[%d]: %s", PlayerInfo[playerid][PlayerName], playerid, params);
	print(String);

	format(adminstr, sizeof(adminstr), "*Radio [%s] %s[%d]: %s", TeamInfo[pTeam[playerid]][Team_Name], PlayerInfo[playerid][PlayerName], playerid, params);
	MessageToAdminsEx(playerid, X11_GRAY, adminstr); 

	foreach (new i: Player) {
		if (pTeam[i] == pTeam[playerid] && IsPlayerSpawned(i)
			&& !GetPlayerInterior(i) && !GetPlayerVirtualWorld(i)) SendClientMessage(i, X11_CYAN, String);
	}
	return 1;
}

//Display a list of teams?
CMD:teams(playerid) {
	static dialog[140];
	strcat(dialog, "Team\tPlayers\tZones\n");
	for (new x = 0; x < sizeof(TeamInfo); x++) {
		new teamPlayers, teamZones;
		foreach (new i: Player) {
			if (pTeam[i] == x 
				&& !GetPlayerInterior(i) && !GetPlayerVirtualWorld(i) && IsPlayerSpawned(i)) {
				teamPlayers++;
			}
		}
		for (new i = 0; i < sizeof(ZoneInfo); i++) {
			if (ZoneInfo[i][Zone_Owner] == x) {
				teamZones++;
			}
		}
		format(dialog, sizeof(dialog), "%s{%06x}%s\t%d\t%d\n", dialog, TeamInfo[x][Team_Color] >>> 8, TeamInfo[x][Team_Name], teamPlayers, teamZones);
	}
	Dialog_Show(playerid, DIALOG_STYLE_TABLIST_HEADERS, ""RED2"SvT - Teams", dialog, "X", "");    
	return 1;
}

//Nuke

CMD:nuke(playerid) {
	if (nukeCooldown > gettime() && nukeIsLaunched) {
		Text_Send(playerid, $CLIENT_472x, nukeCooldown - gettime());
	} else {
		Text_Send(playerid, $CLIENT_473x);
	}
	return 1;
}

CMD:nukehelp(playerid) {
	SendClientMessage(playerid, X11_DEEPPINK, "Nuclear Help");
	Text_Send(playerid, $NEWCLIENT_173x);
	Text_Send(playerid, $NEWCLIENT_174x);
	Text_Send(playerid, $NEWCLIENT_175x);
	Text_Send(playerid, $NEWCLIENT_176x);
	Text_Send(playerid, $NEWCLIENT_177x);
	return 1;
}

//End of File
/* (c) H2O Multiplayer 2018-2020. All rights reserved. */