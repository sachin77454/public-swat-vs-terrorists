/*
	SWAT vs Terrorists is a team death-match SA-MP game-mode script. 
	Compatible with SA-MP 0.3.7 and later releases.

	Author: H2O
	Licensed under GNU GPLv3

	(c) 2018-2020 H2O Multiplayer. All rights reserved.
	Website: h2omultiplayer.com
*/

#include <YSI_Players\y_text>
loadtext mode_text[all], mode_text[client], mode_text[newcs], mode_text[dialogs], mode_text[gametexts];

//The race menu displayed on using the /race command added below
//Does this need any improvements?
forward DisplayRacesList(playerid);
public DisplayRacesList(playerid) {
	if (cache_num_rows()) {
		inline RaceMenu(pid, dialogid, response, listitem, string:inputtext[]) {
			#pragma unused dialogid, inputtext
			if (response) {
				if (!EventInfo[E_STARTED]) {
					new raceId = pRaceListItem[pid][listitem];
					for (new i = 0; i < 20; i ++) {
						pRaceListItem[pid][i] = -1;
					}

					EventInfo[E_STARTED] = 1;
					EventInfo[E_TYPE] = 2;
					EventInfo[E_FREEZE] = 1;
					EventInfo[E_SPAWN_TYPE] = EVENT_SPAWN_RANDOM;
					EventInfo[E_SPAWNS] = 0;
					EventInfo[E_CHECKPOINTS] = 0;
					EventInfo[E_MAX_PLAYERS] = 32;

					new clear_data2[E_RACE_ENUM], clear_data3[E_SPAWN_ENUM];

					for (new i = 0; i < MAX_CHECKPOINTS; i++) {
						RaceInfo[i] = clear_data2;
						SpawnInfo[i] = clear_data3;
					}

					new Cache: RaceData, query[612], vehicleModel;
					mysql_format(Database, query, sizeof(query), "SELECT * FROM `RacesData` WHERE `RaceId` = '%d' LIMIT 1", raceId);
					RaceData = mysql_query(Database, query);
					cache_get_value(0, "RaceName", EventInfo[E_NAME]);
					cache_get_value_int(0, "RaceVehicle", vehicleModel);
					cache_get_value_int(0, "RaceInt", EventInfo[E_INTERIOR]);
					cache_get_value_int(0, "RaceWorld", EventInfo[E_WORLD]);
					cache_delete(RaceData);

					new Cache: RaceSpawns;
					mysql_format(Database, query, sizeof(query), "SELECT * FROM `RacesSpawnPoints` WHERE `RaceId` = '%d'", raceId);
					RaceSpawns = mysql_query(Database, query);
					for (new i = 0; i < cache_num_rows(); i++) {
						cache_get_value_name_float(i, "RX", SpawnInfo[EventInfo[E_SPAWNS]][S_COORDS][0]);
						cache_get_value_name_float(i, "RY", SpawnInfo[EventInfo[E_SPAWNS]][S_COORDS][1]);
						cache_get_value_name_float(i, "RZ", SpawnInfo[EventInfo[E_SPAWNS]][S_COORDS][2]);
						cache_get_value_name_float(i, "RRot", SpawnInfo[EventInfo[E_SPAWNS]][S_COORDS][3]);
						EventInfo[E_SPAWNS]++;
					}	
					cache_delete(RaceSpawns);

					new Cache: RaceCheckpoints;
					mysql_format(Database, query, sizeof(query), "SELECT * FROM `RacesCheckpoints` WHERE `RaceId` = '%d'", raceId);
					RaceCheckpoints = mysql_query(Database, query);
					for (new i = 0; i < cache_num_rows(); i++) {
						cache_get_value_name_float(i, "RX", RaceInfo[EventInfo[E_CHECKPOINTS]][R_COORDS][0]);
						cache_get_value_name_float(i, "RY", RaceInfo[EventInfo[E_CHECKPOINTS]][R_COORDS][1]);
						cache_get_value_name_float(i, "RZ", RaceInfo[EventInfo[E_CHECKPOINTS]][R_COORDS][2]);
						cache_get_value_name_int(i, "RType", RaceInfo[EventInfo[E_CHECKPOINTS]][R_TYPE]);
						EventInfo[E_CHECKPOINTS]++;
					}	
					cache_delete(RaceCheckpoints);

					EventInfo[E_CASH] = random(20000) + 1000;
					EventInfo[E_OPENED] = 1;
					SetTimerEx("StartRace", 25000, false, "i", vehicleModel);
					EventInfo[E_AUTO] = 1;

					counterValue = 25;
					counterOn = 1;

					KillTimer(counterTimer);
					counterTimer = SetTimer("EventCD", 1000, true);

					Text_Send(@pVerified, $SERVER_1x, PlayerInfo[pid][PlayerName], EventInfo[E_NAME]);

					pCooldown[pid][41] = gettime() + 600;
				}
			} else {
				for (new i = 0; i < 20; i ++) {
					pRaceListItem[pid][i] = -1;
				}
			}
		}

		new highestRaceId = 0;

		for (new i = 0; i < cache_num_rows(); i++) {
			new raceId, racename[24], racemaker[24], racevehicle, racedate;
			cache_get_value_int(i, "RaceId", raceId);
			cache_get_value(i, "RaceName", racename, sizeof(racename));
			cache_get_value(i, "RaceMaker", racemaker, sizeof(racemaker));
			cache_get_value_int(i, "RaceVehicle", racevehicle);
			cache_get_value_int(i, "RaceDate", racedate);

			pRaceListItem[playerid][highestRaceId] = raceId;
			highestRaceId ++;

			new string[1512];
			strcat(string, "Race Name\tRace Maker\tModel Id\tCreation Time\n");
			format(string, sizeof(string), "%s%s\t%s\t%d\t%s\n", string, racename, racemaker, racevehicle, GetWhen(racedate, gettime()));
			Dialog_ShowCallback(playerid, using inline RaceMenu, DIALOG_STYLE_TABLIST_HEADERS, ""RED2"SvT Races List", string, "Start Race", "X");
		}
	}  else Text_Send(playerid, $CLIENT_423x);
	return 1;
}

//Start a race event using the ordinary system
forward StartRace(vehicleModel);
public StartRace(vehicleModel) {
	if (EventInfo[E_STARTED]) {
		if (Iter_Count(ePlayers) < 2) {
			new clear_data[E_DATA_ENUM];
			EventInfo = clear_data;

			EventInfo[E_STARTED] = 0;
			EventInfo[E_OPENED] = 0;

			EventInfo[E_SPAWN_TYPE] = EVENT_SPAWN_INVALID;
			EventInfo[E_TYPE] = -1;
			foreach (new i: ePlayers) {
				SetPlayerHealth(i, 0.0);
				Text_Send(i, $EVENT_CANCELLED);
			}
			Iter_Clear(ePlayers);
		} else {
			foreach (new i: ePlayers) {
				if (PlayerInfo[i][pCar] != -1) DestroyVehicle(PlayerInfo[i][pCar]);
				PlayerInfo[i][pCar] = -1;

				new Float: Position[4], Int, World;

				Int = GetPlayerInterior(i);
				World = GetPlayerVirtualWorld(i);

				GetPlayerPos(i, Position[0], Position[1], Position[2]);
				GetPlayerFacingAngle(i, Position[3]);

				PlayerInfo[i][pCar] = CreateVehicle(vehicleModel, Position[0], Position[1], Position[2], Position[3], 0, 3, -1);

				LinkVehicleToInterior(PlayerInfo[i][pCar], Int);
				SetVehicleVirtualWorld(PlayerInfo[i][pCar], World);
				PutPlayerInVehicle(i, PlayerInfo[i][pCar], 0);
				Tuneacar(PlayerInfo[i][pCar]);

				TogglePlayerControllable(i, true);
				PlayerPlaySound(i, 1057, 0.0, 0.0, 0.0);
				if (EventInfo[E_FREEZE] == 1) {
					EventInfo[E_FREEZE] = 0;
				}
			}

			EventInfo[E_OPENED] = 0;
		}
	}    
	return 1;
}

//Event race checkpoint check... PLAYER ENTERED A RACE CHECKPOINT, what to do?
hook OnPlayerEnterRaceCP(playerid) {
	if (Iter_Contains(ePlayers, playerid) && EventInfo[E_TYPE] == 2) {
		if (pEventInfo[playerid][P_CP] >= EventInfo[E_CHECKPOINTS]) {           
			Text_Send(@pVerified, $NEWSERVER_40x);

			new top[MAX_PLAYERS][2], topcount;

			foreach(new p: Player) {
				top[p][0] = pEventInfo[p][P_CP];
				top[p][1] = p;

				topcount ++;   
			}

			QuickSort_Pair(top, true, 0, topcount + 1);

			new time = gettime() - pEventInfo[playerid][P_RACETIME];

			for (new i = 0; i < topcount + 1; i++) {
				if (top[i][0])
				{
					Text_Send(@pVerified, $NEWSERVER_2x, i + 1, PlayerInfo[top[i][1]][PlayerName], time, GetPlayerVehicleSpeed(top[i][1]), top[i][0] + 10, EventInfo[E_CASH], top[i][0], EventInfo[E_CHECKPOINTS]);
					GivePlayerCash(top[i][1], EventInfo[E_CASH]);
					GivePlayerScore(top[i][1], top[i][0] + 10);

					PlayerInfo[top[i][1]][sEvents] ++;
					PlayerInfo[top[i][1]][sRaces] ++;
					DisablePlayerRaceCheckpoint(top[i][1]);
					new clear_pdata[E_PLAYER_ENUM];
					pEventInfo[top[i][1]] = clear_pdata;
					SetPlayerHealth(top[i][1], 0.0);
				}
			}

			new clear_data[E_DATA_ENUM];
			EventInfo = clear_data;

			EventInfo[E_OPENED] = 0;
			EventInfo[E_STARTED] = 0;

			EventInfo[E_SPAWN_TYPE] = EVENT_SPAWN_INVALID;
			EventInfo[E_TYPE] = -1;

			foreach (new i: ePlayers) {
				if (PlayerInfo[i][pCar] != -1) {
					DestroyVehicle(PlayerInfo[i][pCar]);
					PlayerInfo[i][pCar] = -1;
				}
			}

			Iter_Clear(ePlayers);		
		}
		else if (pEventInfo[playerid][P_CP] + 1 != EventInfo[E_CHECKPOINTS])
		{
			if (RaceInfo[pEventInfo[playerid][P_CP]][R_TYPE] == 0)
			{
				SetPlayerRaceCheckpoint(playerid, 0, RaceInfo[pEventInfo[playerid][P_CP]][R_COORDS][0], RaceInfo[pEventInfo[playerid][P_CP]][R_COORDS][1], RaceInfo[pEventInfo[playerid][P_CP]][R_COORDS][2],
				RaceInfo[pEventInfo[playerid][P_CP] + 1][R_COORDS][0], RaceInfo[pEventInfo[playerid][P_CP] + 1][R_COORDS][1], RaceInfo[pEventInfo[playerid][P_CP] + 1][R_COORDS][2], 10);
			}
			else
			{
				SetPlayerRaceCheckpoint(playerid, 3, RaceInfo[pEventInfo[playerid][P_CP]][R_COORDS][0], RaceInfo[pEventInfo[playerid][P_CP]][R_COORDS][1], RaceInfo[pEventInfo[playerid][P_CP]][R_COORDS][2],
				RaceInfo[pEventInfo[playerid][P_CP] + 1][R_COORDS][0], RaceInfo[pEventInfo[playerid][P_CP] + 1][R_COORDS][1], RaceInfo[pEventInfo[playerid][P_CP] + 1][R_COORDS][2], 10);
			}

			pEventInfo[playerid][P_CP]++;

			new time = gettime() - pEventInfo[playerid][P_RACETIME];
			Text_Send(playerid, $RACE_UPDATE, GetPlayerVehicleSpeed(playerid), pEventInfo[playerid][P_CP], EventInfo[E_CHECKPOINTS], time);
		}
		else if (pEventInfo[playerid][P_CP] + 1 == EventInfo[E_CHECKPOINTS])
		{
			if (RaceInfo[pEventInfo[playerid][P_CP]][R_TYPE] == 0)
			{
				SetPlayerRaceCheckpoint(playerid, 1, RaceInfo[pEventInfo[playerid][P_CP]][R_COORDS][0], RaceInfo[pEventInfo[playerid][P_CP]][R_COORDS][1], RaceInfo[pEventInfo[playerid][P_CP]][R_COORDS][2], 0.0, 0.0, 0.0, 15);
			}
			else
			{
				SetPlayerRaceCheckpoint(playerid, 4, RaceInfo[pEventInfo[playerid][P_CP]][R_COORDS][0], RaceInfo[pEventInfo[playerid][P_CP]][R_COORDS][1], RaceInfo[pEventInfo[playerid][P_CP]][R_COORDS][2], 0.0, 0.0, 0.0, 15);
			}
			
			pEventInfo[playerid][P_CP]++;

			new time = gettime() - pEventInfo[playerid][P_RACETIME];
			Text_Send(playerid, $RACE_UPDATE, GetPlayerVehicleSpeed(playerid), pEventInfo[playerid][P_CP], EventInfo[E_CHECKPOINTS], time);
		}
	}
	return 1;
}

//Reset race dialog listitem for staying in the safe side
hook ResetPlayerVars(playerid) {
	for (new i = 0; i < 20; i ++) {
		pRaceListItem[playerid][i] = -1;
	}
	return 1;
}

//Create race checkpoints, some important admin features
//used for over 2 years
flags:cp(CMD_ADMIN);
CMD:cp(playerid, params[]) {
	if (PlayerInfo[playerid][pAdminLevel]) {
		if (EventInfo[E_TYPE] != 2) return Text_Send(playerid, $CLIENT_426x);
		if (EventInfo[E_CHECKPOINTS] >= MAX_CHECKPOINTS || EventInfo[E_OPENED] == 1) return Text_Send(playerid, $CLIENT_420x);

		new type[20];
		if (sscanf(params, "s[20]", type)) return ShowSyntax(playerid, "/cp [air/ground]");

		if (!strcmp(type, "ground", true)) {
			RaceInfo[EventInfo[E_CHECKPOINTS]][R_TYPE] = 0;
		} else if (!strcmp(type, "air", true)) {
			RaceInfo[EventInfo[E_CHECKPOINTS]][R_TYPE] = 1;
		} else return ShowSyntax(playerid, "/cp (race checkpoint) [air (ring)/ground (normal)]");

		if (Iter_Count(ePlayers)) return Text_Send(playerid, $CLIENT_433x);

		new Float: Position[3];

		GetPlayerPos(playerid, Position[0], Position[1], Position[2]);

		RaceInfo[EventInfo[E_CHECKPOINTS]][R_COORDS][0] = Position[0];
		RaceInfo[EventInfo[E_CHECKPOINTS]][R_COORDS][1] = Position[1];
		RaceInfo[EventInfo[E_CHECKPOINTS]][R_COORDS][2] = Position[2];

		EventInfo[E_CHECKPOINTS]++;
	}
	return 1;
}

//Add code for race menu
//Isn't 2500 score too low to start a RACE event?!
CMD:race(playerid, params[]) {
	if (GetPlayerScore(playerid) < 2500) return Text_Send(playerid, $CLIENT_451x);
	if (EventInfo[E_STARTED]) return Text_Send(playerid, $CLIENT_474x);
	
	if (pCooldown[playerid][41] > gettime()) {
		Text_Send(playerid, $CLIENT_475x, pCooldown[playerid][41] - gettime());
		return 1;
	}

	mysql_tquery(Database, "SELECT * FROM `RacesData` ORDER BY `RaceDate` DESC LIMIT 20", "DisplayRacesList", "i", playerid);
	return 1;
}

//End of File
/* (c) H2O Multiplayer 2018-2020. All rights reserved. */