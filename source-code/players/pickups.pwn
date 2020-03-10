/*
	SWAT vs Terrorists is a team death-match SA-MP game-mode script.
	Compatible with SA-MP 0.3.7 and later releases.

	Author: H2O
	Licensed under GNU GPLv3

	(c) 2018-2020 H2O Multiplayer. All rights reserved.
	Website: h2omultiplayer.com

	Pickups Module
*/

#include <YSI\y_hooks>
#include <YSI_Players\y_text> //Y_Less
loadtext mode_text[all], mode_text[client], mode_text[newcs], mode_text[dialogs], mode_text[gametexts];

hook OnPlayerPickUpDynPickup(playerid, pickupid) {
	PlayerInfo[playerid][pPickupsPicked] ++;

	//Interiors
	for (new i = 0; i < sizeof(Interiors); i++) {
		if (pickupid == Interiors[i][IntEnterPickup]) {
			if (gIntCD[playerid] < GetTickCount()) {
				new Float: x, Float: y;
				x = Interiors[i][IntExitPos][0], 
				y = Interiors[i][IntExitPos][1];
				gIntCD[playerid] = GetTickCount() + 3000;
				SetPlayerPos(playerid, x, y, Interiors[i][IntExitPos][2]);
				SetPlayerInterior(playerid, Interiors[i][IntId]);
				PlayerInfo[playerid][pInteriorsEntered] ++;
			}
			break;
		} else if (pickupid == Interiors[i][IntExitPickup]) {
			if (gIntCD[playerid] < GetTickCount()) {
				new Float: x, Float: y;
				x = Interiors[i][IntEnterPos][0], 
				y = Interiors[i][IntEnterPos][1];
				gIntCD[playerid] = GetTickCount() + 3000;
				SetPlayerPos(playerid, x, y, Interiors[i][IntEnterPos][2]);
				SetPlayerInterior(playerid, 0);
				PlayerInfo[playerid][pInteriorsExitted] ++;
			}			
			break;
		}
	}

	//WatchRoom
	if (pickupid == gWatchRoom) {
		if (!pWatching[playerid]) {
			SetPlayerPos(playerid, -253.8266, 1534.5271, 29.3609);
			Text_Send(playerid, $CLIENT_307x);
			pWatching[playerid] = true;
			AttachCameraToDynamicObject(playerid, gCameraId);
		}
	}
	return 1;
}

hook OnPlayerPickUpPickup(playerid, pickupid) {
	PlayerInfo[playerid][pPickupsPicked] ++;

	if (Last_Pickup[playerid] != -1 && Last_Pickup[playerid] != pickupid) {
		if ((GetTickCount() - Last_Pickup_Tick[playerid]) < 200 && GetTickCount() > gIntCD[playerid]) {
			AntiCheatAlert(playerid, "Auto Pickup");
			return Kick(playerid);
		}
	}
	Last_Pickup[playerid] = pickupid;
	Last_Pickup_Tick[playerid] = GetTickCount();

	if (g_pickups[0] == pickupid) {
		SetPlayerPos(playerid, -378.4082,2186.8958,51.2200);
	}
	
	if (g_pickups[1] == pickupid) {
		SetPlayerPos(playerid, -247.4149,2306.7480,111.9679);
		PC_EmulateCommand(playerid, "/ep");
	}
	
	if (g_pickups[3] == pickupid) {
		if (ZoneInfo[SNIPERHUT][Zone_Owner] == pTeam[playerid])
		{
			if (pCooldown[playerid][27] < gettime()) {
				pCooldown[playerid][27] = gettime() + 200;
				GivePlayerWeapon(playerid, 34, 5);
				Text_Send(playerid, $CLIENT_308x);
			} else {
				 Text_Send(playerid, $CLIENT_416x, pCooldown[playerid][27] - gettime());
				 return 1;
			}
		} else Text_Send(playerid, $CLIENT_309x);
	}
	
	if (g_pickups[5] == pickupid) {
		SetPlayerPos(playerid, -101.0826,2342.9851,20.0358);
	}
	
	if (g_pickups[6] == pickupid) {
		SetPlayerPos(playerid, -103.5930,2269.3291,121.4385);
		PC_EmulateCommand(playerid, "/ep");
	}
	return 1;
}

//End of File
/* (c) H2O Multiplayer 2018-2020. All rights reserved. */