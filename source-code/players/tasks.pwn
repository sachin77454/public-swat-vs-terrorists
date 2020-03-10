/*
	SWAT vs Terrorists is a team death-match SA-MP game-mode script. 
	Compatible with SA-MP 0.3.7 and later releases.

	Author: H2O
	Licensed under GNU GPLv3

	(c) 2018-2020 H2O Multiplayer. All rights reserved.
	Website: h2omultiplayer.com

	Per player tasks
*/

//Support for y_text, load language files...
#include <YSI_Players\y_text> //Y_Less
loadtext mode_text[all], mode_text[client], mode_text[newcs], mode_text[dialogs], mode_text[gametexts];

//Player Timer (sync player activity)
ptask PlayerUpdate[1000](playerid) {
	if (PlayerInfo[playerid][pSelecting]) {
		PlayerInfo[playerid][pTimeSpentInSelection] ++;
	}
	PlayerInfo[playerid][pLastPing] = GetPlayerPing(playerid);
	PlayerInfo[playerid][pLastPacketLoss] = NetStats_PacketLossPercent(playerid);
	if (IsPlayerSpawned(playerid) && !PlayerInfo[playerid][pSelecting]) {
		foreach (new x: Player) {
			if (GetPlayerState(x) == PLAYER_STATE_SPECTATING && PlayerInfo[x][pSpecId] == playerid
				&& PlayerInfo[x][pAdminLevel] && !Iter_Contains(PUBGPlayers, x))
			{
				new str[128];

				format(str, sizeof(str), "%s[%d]",
					PlayerInfo[playerid][PlayerName], playerid);

				PlayerTextDrawSetString(x, aSpecPTD[x][1], str);

				format(str, sizeof(str), "%s (%d)~n~Speed: %0.2f KM/H",
					ReturnWeaponName(GetPlayerWeapon(playerid)),
					 GetPlayerAmmo(playerid), GetPlayerSpeed(playerid));

				PlayerTextDrawSetString(x, aSpecPTD[x][2], str);

				PlayerTextDrawShow(x, aSpecPTD[x][0]);
				PlayerTextDrawShow(x, aSpecPTD[x][1]);
				PlayerTextDrawShow(x, aSpecPTD[x][2]);
			}
		}

		if (GetPlayerState(playerid) == PLAYER_STATE_ONFOOT) {
			PlayerInfo[playerid][pTimeSpentOnFoot] ++;
	        if (!pJetpack[playerid] && !PlayerInfo[playerid][pAdminLevel]) {
	        	if (GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_USEJETPACK && 
	        		!pItems[playerid][JETPACK] && pClass[playerid] != JETTROOPER) {
	        		AntiCheatAlert(playerid, "Jetpack Spawner");

	        		new Float: X, Float: Y, Float: Z;
	        		GetPlayerPos(playerid, X, Y, Z);
	        		SetPlayerPos(playerid, X, Y, Z + 5.0);
	        	}
		    }
		}

		new vid = GetPlayerVehicleID(playerid);
		if (vid) {
			new Float: X, Float: Y, Float: Z;
			GetVehicleVelocity(vid, X, Y, Z);
			if (floatround(floatsqroot(X * X + Y * Y) * 200, floatround_round) > 300) {
				AntiCheatAlert(playerid, "Vehicle Speed Hack");
				SetVehicleToRespawn(GetPlayerVehicleID(playerid));
			}
		}

		if (GetPlayerState(playerid) == PLAYER_STATE_PASSENGER) {
			PlayerInfo[playerid][pTimeSpentAsPassenger] ++;
		}

		CheckTarget(playerid);

		if (gCamoActivated[playerid] && gCamoTime[playerid] < gettime()) {
			gCamoActivated[playerid] = 0;
			pCamo[playerid] = 0;
			SetPlayerMarkerVisibility(playerid, 0xFF);
			Text_Send(playerid, $CAMO_EXPIRED);
		}

		if (gInvisible[playerid] && gInvisibleTime[playerid] < gettime()) {
			gInvisible[playerid] = false;
			SetPlayerMarkerVisibility(playerid, 0xFF);
		}

		if (GetPlayerPing(playerid) > PlayerInfo[playerid][pHighestPing]) {
			PlayerInfo[playerid][pHighestPing] = GetPlayerPing(playerid);
		}

		if (GetPlayerPing(playerid) < PlayerInfo[playerid][pLowestPing]) {
			PlayerInfo[playerid][pLowestPing] = GetPlayerPing(playerid);
		}

		if (GetPlayerPing(playerid) >= svtconf[max_ping] + 300 && svtconf[max_ping_kick] == 1 && PlayerInfo[playerid][pAdminLevel] < svtconf[max_admin_level]) {
			Text_Send(@pVerified, $SERVER_35x, PlayerInfo[playerid][PlayerName]);
			Kick(playerid);
		}

		if (GetPlayerCameraMode(playerid) == 53) {  
			new Float:kLibPos[3];  
			GetPlayerCameraPos(playerid, kLibPos[0], kLibPos[1], kLibPos[2]); 
			if (kLibPos[2] < -50000.0 || kLibPos[2] > 50000.0) {  
				AntiCheatAlert(playerid, "Player Crasher");
				Kick(playerid);
				return 0;  
			}  
		}

		if (AntiSK[playerid] && AntiSKStart[playerid] <= gettime() &&
			!PlayerInfo[playerid][pAFKOnSpawn]) {
			EndProtection(playerid);
		}

		if (IsPlayerInArea(playerid, ZoneInfo[RECHARGEPOINT][Zone_MapArea][0], ZoneInfo[RECHARGEPOINT][Zone_MapArea][1], ZoneInfo[RECHARGEPOINT][Zone_MapArea][2], ZoneInfo[RECHARGEPOINT][Zone_MapArea][3]) 
			&& pTeam[playerid] == ZoneInfo[RECHARGEPOINT][Zone_Owner]) {
			RechargeAAC(playerid);		
		}

		if ((GetTickCount() - PlayerInfo[playerid][pLastSync]) > 6500
				&& !PlayerInfo[playerid][pIsAFK])
		{
			 PlayerInfo[playerid][pAFKTick] = gettime();
			 PlayerInfo[playerid][pIsAFK] = 1;
			 UpdateLabelText(playerid);
			 return 1;
		}

		if (PlayerInfo[playerid][pIsAFK])
		{
			if ((GetTickCount() - PlayerInfo[playerid][pLastSync]) < 3000) {
				PlayerInfo[playerid][pIsAFK] = 0;
				
				if (PlayerInfo[playerid][pAdminLevel] && gettime() - PlayerInfo[playerid][pAFKTick] > 800) {
					new query[90];
					format(query, sizeof(query), "Was away from keyboard for %d seconds.", gettime() - PlayerInfo[playerid][pAFKTick]);
					LogAdminAction(playerid, query);
				}
				
				PlayerInfo[playerid][pTimeSpentAFK] += gettime() - PlayerInfo[playerid][pAFKTick];
				PlayerInfo[playerid][pAFKTick] = 0;
				UpdateLabelText(playerid);
			}	        	
		}    

		if (pDuelInfo[playerid][pDInMatch] && !pDuelInfo[playerid][pDLocked]
			&& TargetOf[playerid] != INVALID_PLAYER_ID) {
			if (pDuelInfo[playerid][pDCountDown] < gettime()) {
				pDuelInfo[playerid][pDInMatch] = 0;
				pDuelInfo[TargetOf[playerid]][pDInMatch] = 0;

				Text_Send(playerid, $DUEL_TIME_UP);
				Text_Send(TargetOf[playerid], $DUEL_TIME_UP);

				GivePlayerCash(playerid, -pDuelInfo[playerid][pDBetAmount]);
				GivePlayerCash(TargetOf[playerid], -pDuelInfo[playerid][pDBetAmount]);

				PlayerInfo[playerid][pDuelsLost]++;
				PlayerInfo[TargetOf[playerid]][pDuelsLost]++;

				SpawnPlayer(playerid);
				SpawnPlayer(TargetOf[playerid]);

				pDuelInfo[TargetOf[playerid]][pDLocked] =
				pDuelInfo[TargetOf[playerid]][pDInMatch] =
				pDuelInfo[TargetOf[playerid]][pDWeapon] =
				pDuelInfo[TargetOf[playerid]][pDAmmo] =
				pDuelInfo[TargetOf[playerid]][pDMatchesPlayed] =
				pDuelInfo[TargetOf[playerid]][pDRematchOpt] =
				pDuelInfo[TargetOf[playerid]][pDBetAmount] = 0;

				TargetOf[TargetOf[playerid]] = INVALID_PLAYER_ID;
				TargetOf[playerid] = INVALID_PLAYER_ID;
			} else if (!pDuelInfo[playerid][pDLocked]) {
				new string[25];
				format(string, sizeof(string), "~w~Time left: ~r~%d", pDuelInfo[playerid][pDCountDown] - gettime());
				NotifyPlayer(playerid, string);
				NotifyPlayer(TargetOf[playerid], string);
			}
		}
		
		if (PlayerInfo[playerid][pJailed] == 1 && gettime() > PlayerInfo[playerid][pJailTime]) {
			PlayerInfo[playerid][pJailed] = 0;
			SpawnPlayer(playerid);

			Text_Send(playerid, $UNJAILED_PLAYER);

			new message[128];

			format(message, sizeof(message), "%s[%d] has been released from the jail.", PlayerInfo[playerid][PlayerName], playerid);
			MessageToAdmins(0x2281C8FF, message);
		}

		if (PlayerInfo[playerid][pBackup] != INVALID_PLAYER_ID && pBackupResponded[playerid] == 1)
		{
			if (gBackupTimer[playerid] > gettime())
			{
				if (IsPlayerConnected(PlayerInfo[playerid][pBackup]))
				{
					switch (gBackupHighlight[playerid])
					{
						case 0: SetPlayerMarkerForPlayer(playerid, PlayerInfo[playerid][pBackup], 0xFFFF00FF), gBackupHighlight[playerid] = 1;
						case 1: SetPlayerMarkerForPlayer(playerid, PlayerInfo[playerid][pBackup], TeamInfo[pTeam[PlayerInfo[playerid][pBackup]]][Team_Color]), gBackupHighlight[playerid] = 0;
					}

					new Float: X, Float: Y, Float: Z;
					GetPlayerPos(PlayerInfo[playerid][pBackup], X, Y, Z);
					if (IsPlayerInRangeOfPoint(playerid, 15.0, X, Y, Z))
					{
						Text_Send(playerid, $DEST_REACHED);
						pBackupResponded[playerid] = 0;
						SetPlayerMarkerForPlayer(playerid, PlayerInfo[playerid][pBackup], TeamInfo[pTeam[PlayerInfo[playerid][pBackup]]][Team_Color]);
						PlayerInfo[playerid][pBackup] = INVALID_PLAYER_ID;
					}
				}
			}
			else
			{
				foreach (new x: Player)
				{
					if (PlayerInfo[x][pBackup] == playerid)
					{
						Text_Send(x, $DEST_LOST);

						pBackupResponded[x] = 0;
						SetPlayerMarkerForPlayer(playerid, PlayerInfo[playerid][pBackup], TeamInfo[pTeam[PlayerInfo[playerid][pBackup]]][Team_Color]);
						PlayerInfo[x][pBackup] = INVALID_PLAYER_ID;
					}
				}
			}
		}
		else {
			PlayerInfo[playerid][pBackup] = INVALID_PLAYER_ID;
		}

		if (TargetOf[playerid] != INVALID_PLAYER_ID || pDuelInfo[playerid][pDLocked]) {
			if (!pDuelInfo[playerid][pDInMatch] && pDuelInfo[playerid][pDInvitePeriod] < gettime()) {
				pDuelInfo[playerid][pDInMatch] = 0;
				pDuelInfo[playerid][pDLocked] = 0;
				TargetOf[playerid] = INVALID_PLAYER_ID;
			}    
		}

		if (PlayerInfo[playerid][pIsAFK] == 1)
		{
			if ((GetTickCount() - PlayerInfo[playerid][pLastSync]) > 5000)
			{
				new String[25];
				Update3DTextLabelText(RankLabel[playerid], 0xD6588CFF, " ");

				format(String, sizeof(String), "AFK (%d)", gettime() - PlayerInfo[playerid][pAFKTick]);
				Update3DTextLabelText(RankLabel[playerid], 0xFF0000CC, String);
			}
		}                
	}

	if (Iter_Contains(ePlayers, playerid) && EventInfo[E_ALLOWLEAVECARS] == 0
		&& !IsPlayerInAnyVehicle(playerid) && !EventInfo[E_OPENED]) {
		if (pEventInfo[playerid][P_CARTIMER]) {
			pEventInfo[playerid][P_CARTIMER]--;
			new string[25];
			format(string, sizeof(string), "~r~%d", pEventInfo[playerid][P_CARTIMER]);
			GameTextForPlayer(playerid, string, 1000, 3);
			if (pEventInfo[playerid][P_CARTIMER] <= 0) {
				SpawnPlayer(playerid);
			}
		}  
	}    
	return 1;
}

//End of File
/* (c) H2O Multiplayer 2018-2020. All rights reserved. */