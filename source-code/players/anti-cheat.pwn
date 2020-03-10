/*
	SWAT vs Terrorists is a team death-match SA-MP game-mode script. 
	Compatible with SA-MP 0.3.7 and later releases.

	Author: H2O
	Licensed under GNU GPLv3

	(c) 2018-2020 H2O Multiplayer. All rights reserved.
	Website: h2omultiplayer.com

	Anti-Cheat related content
*/

#include <YSI_Coding\y_hooks>

//Support for y_text, load language files...
#include <YSI_Players\y_text> //Y_Less
loadtext mode_text[all], mode_text[client], mode_text[newcs], mode_text[dialogs], mode_text[gametexts];

public OnAntiCheatLagTroll(playerid) {
	AntiCheatAlert(playerid, "Troll Hack");
	return Kick(playerid);
}

public OnPlayerBreakAir(playerid, breaktype) {
	AntiCheatAlert(playerid, "Airbreak");
	return Kick(playerid);
}

public OnAntiCheatPlayerSpoof(playerid) {
	AntiCheatAlert(playerid, "Player Spoof");
	return Kick(playerid);
}

public OnPlayerWeaponHack(playerid, weaponid) {
	foreach (new i: Player) {
		if (PlayerInfo[i][pAdminLevel] || PlayerInfo[i][pIsModerator]) {
			Text_Send(i, $NEWCLIENT_24x, PlayerInfo[playerid][PlayerName], playerid, ReturnWeaponName(weaponid));
		}
	}
	SetPlayerAmmo(playerid, weaponid, 0);
	return 1;
}

public OnPlayerFlyHack(playerid) {
	AntiCheatAlert(playerid, "Fly Hack");
	return Kick(playerid);
}

public OnPlayerSuspectedForAimbot(playerid, hitid, weaponid, warnings) {
	if(warnings & WARNING_OUT_OF_RANGE_SHOT) {
		foreach (new i: Player) {
			if (PlayerInfo[i][pAdminLevel] || PlayerInfo[i][pIsModerator]) {
				Text_Send(i, $NEWCLIENT_25x, PlayerInfo[playerid][PlayerName], playerid, ReturnWeaponName(weaponid), BustAim::GetNormalWeaponRange(weaponid));
			}
		}		
	}
	if(warnings & WARNING_PROAIM_TELEPORT) {
		foreach (new i: Player) {
			if (PlayerInfo[i][pAdminLevel] || PlayerInfo[i][pIsModerator]) {
				Text_Send(i, $NEWCLIENT_26x, PlayerInfo[playerid][PlayerName], playerid);
			}
		}	
	}
	if(warnings & WARNING_RANDOM_AIM) {
		foreach (new i: Player) {
			if (PlayerInfo[i][pAdminLevel] || PlayerInfo[i][pIsModerator]) {
				Text_Send(i, $NEWCLIENT_27x, PlayerInfo[playerid][PlayerName], playerid, ReturnWeaponName(weaponid));
			}
		}	
	}
	if(warnings & WARNING_CONTINOUS_SHOTS) {
		foreach (new i: Player) {
			if (PlayerInfo[i][pAdminLevel] || PlayerInfo[i][pIsModerator]) {
				Text_Send(i, $NEWCLIENT_28x, PlayerInfo[playerid][PlayerName], playerid, ReturnWeaponName(weaponid), weaponid);
			}
		}	
	}
	return 0;
}

AntiCheatAlert(playerid, const cheat[]) {
	if (IsPlayerSpawned(playerid) && PlayerInfo[playerid][pACCooldown] < gettime()) {
		foreach (new i: Player) {
			if (PlayerInfo[i][pAdminLevel] || PlayerInfo[i][pIsModerator]) {
				Text_Send(i, $NEWCLIENT_29x, PlayerInfo[playerid][PlayerName], playerid, PlayerInfo[playerid][pIP], cheat);
			}
		}
		PlayerInfo[playerid][pACCooldown] = gettime() + 5;
		PlayerInfo[playerid][pAntiCheatWarnings] ++;
	}	
	return 1;
}

hook OnPlayerStateChange(playerid, newstate, oldstate) {
    if(newstate == PLAYER_STATE_PASSENGER) {
		new vid = GetPlayerVehicleID(playerid);
		switch (GetVehicleModel(vid)) {
		    case 519, 539, 476, 425, 520, 512, 513, 577, 553: {
			    AntiCheatAlert(playerid, "Vehicle Seat Crasher");
			    Kick(playerid);
			    return 0;
		    }
		}
	}
	return 1;
}

hook OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ) {
	if (hittype == BULLET_HIT_TYPE_PLAYER) if(hitid == INVALID_PLAYER_ID) return 0;
	if (!GetPlayerWeapon(playerid)) return 0;
	if (hitid == playerid) return 0;
	if (!IsBulletWeapon(weaponid)) {
		return 0;
	}
	if (hittype == BULLET_HIT_TYPE_PLAYER && ((fX >= 10.0 || fX <= -10.0) || (fY >= 10.0 || fY <= -10.0) || (fZ >= 10.0 || fZ <= -10.0 ))) {
		return 0;
	}

	// Anti-Rapid Fire (idea taken from Lorenc_)
	if (!pRapidFireTick[playerid]) {
		pRapidFireTick[playerid] = GetTickCount( );
	}
	else {
		new
			shotsInterval = GetTickCount( ) - pRapidFireTick[playerid];
		if ((shotsInterval <= 35 && (weaponid != 38 && weaponid != 28 && weaponid != 32)) || (shotsInterval <= 370 && (weaponid == 34 || weaponid == 33))) {
			if (pRapidFireBullets{playerid} ++ >= 5) {
				AntiCheatAlert(playerid, "Rapid Fire");
		    	return 0;
			}
		} else {
			pRapidFireBullets{playerid} = 0;
		}
		pRapidFireTick[playerid] = GetTickCount();
	}

	if (hittype != BULLET_HIT_TYPE_NONE) {
		if (!(-1000.0 <= fX <= 1000.0) || !(-1000.0 <= fY <= 1000.0) || !(-1000.0 <= fZ <= 1000.0)) {
			AntiCheatAlert(playerid, "Bullet Crasher");
			Kick(playerid);
			return 0;
		}
	}
	return 1;
}

hook OnUnoccupiedVehUpdate(vehicleid, playerid, passenger_seat, Float:new_x, Float:new_y, Float:new_z, Float:vel_x, Float:vel_y, Float:vel_z) {
	if (GetVehicleDistanceFromPoint(vehicleid, new_x, new_y, new_z) > 50.0) {
		PlayerInfo[playerid][pWrapWarnings] ++;
		if (PlayerInfo[playerid][pWrapWarnings] > 3) {
			AntiCheatAlert(playerid, "Car Wrap");
			//Kick(playerid);
		}
		SetVehicleToRespawn(vehicleid);
		return 0;
	}
	return 1;
}

//End of File
/* (c) H2O Multiplayer 2018-2020. All rights reserved. */