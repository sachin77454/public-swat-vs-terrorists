/*
	SWAT vs Terrorists is a team death-match SA-MP game-mode script. 
	Compatible with SA-MP 0.3.7 and later releases.

	Author: H2O
	Licensed under GNU GPLv3

	(c) 2018-2020 H2O Multiplayer. All rights reserved.
	Website: h2omultiplayer.com
*/

#include <YSI_Coding\y_hooks>

//Support for y_text, load language files...
#include <YSI_Players\y_text> //Y_Less
loadtext mode_text[all], mode_text[client], mode_text[newcs], mode_text[dialogs], mode_text[gametexts];

//Resync the player to the stored data
ResyncData(playerid) {
	SetPlayerSkin(playerid, gOldSkin[playerid]);
	SetPlayerInterior(playerid, gOldInt[playerid]);
	SetPlayerVirtualWorld(playerid, gOldWorld[playerid]);
	SetPlayerPos(playerid, gOldPos[playerid][0], gOldPos[playerid][1], gOldPos[playerid][2]);
	SetPlayerFacingAngle(playerid, gOldPos[playerid][3]);
	SetPlayerColor(playerid, gOldCol[playerid]);
	for (new i = 0; i < 13; i++) {
		GivePlayerWeapon(playerid, gOldWeaps[playerid][i], gOldAmmo[playerid][i]);
	}
	pStreak[playerid] = gOldSpree[playerid];
	if (gOldVID[playerid] != -1) {
		PutPlayerInVehicle(playerid, gOldVID[playerid], 0);
	}
	UpdateLabelText(playerid);
	Text_Send(playerid, $SYNC_ALERT);
	ForceSync[playerid] = 0;	
	return 1;
}

//Save the player data to sync them later
StoreData(playerid) {
	gOldInt[playerid] = GetPlayerInterior(playerid);
	gOldWorld[playerid] = GetPlayerVirtualWorld(playerid);
	gOldSkin[playerid] = GetPlayerSkin(playerid);
	GetPlayerPos(playerid, gOldPos[playerid][0], gOldPos[playerid][1], gOldPos[playerid][2]);
	GetPlayerFacingAngle(playerid, gOldPos[playerid][3]);
	gOldSpree[playerid] = pStreak[playerid];
	gOldVID[playerid] = GetPlayerVehicleID(playerid);
	for (new i = 0; i < 13; i++) {
		GetPlayerWeaponData(playerid, i, gOldWeaps[playerid][i], gOldAmmo[playerid][i]);
	}		
	ForceSync[playerid] = 1;
	gOldCol[playerid] = GetPlayerColor(playerid);	
	return 1;
}

//------------

//Update player

hook OnPlayerUpdate(playerid) {
	PlayerInfo[playerid][pLastSync] = GetTickCount();

	new weap = GetPlayerWeapon(playerid);

	if (weap != gLastWeap[playerid]) {
		OnPlayerWeaponChange(playerid);
		gLastWeap[playerid] = weap;
	}

	new keys, ud, lr;
	GetPlayerKeys(playerid, keys, ud, lr);

	if (!ud && !lr) {
		StaticPlayer[playerid] = 1;
	}
	else {
		StaticPlayer[playerid] = 0;
		PlayerInfo[playerid][pLastMove] = GetTickCount();
		//------
		//AFK on spawn
		if (PlayerInfo[playerid][pAFKOnSpawn]) {
			AntiSK[playerid] = 0;
			PlayerInfo[playerid][pAFKOnSpawn] = 0;
			SetPlayerVirtualWorld(playerid, BF_WORLD);
		}		
	}
	
	if (!StaticPlayer[playerid] && gMedicKitStarted[playerid]) {
		gMedicKitStarted[playerid] = false;
		Text_Send(playerid, $UNFINISHED_USEMK);
		KillTimer(RecoverTimer[playerid]);
		PlayerPlaySound(playerid, 0, 0.0, 0.0, 0.0);
		pCooldown[playerid][25] = gettime();
	}
	return 1;
}

//------------

//------------

//Pawn.Raknet Packet Sync

const UNOCCUPIED_SYNC = 209;

IPacket:UNOCCUPIED_SYNC(playerid, BitStream:bs)
{
    new unoccupiedData[PR_UnoccupiedSync];
 
    BS_IgnoreBits(bs, 8);
    BS_ReadUnoccupiedSync(bs, unoccupiedData);
 
    if(floatcmp(floatabs(unoccupiedData[PR_roll][0]), 1.00000) == 1
        || floatcmp(floatabs(unoccupiedData[PR_roll][1]), 1.00000) == 1
        || floatcmp(floatabs(unoccupiedData[PR_roll][2]), 1.00000) == 1
        || floatcmp(floatabs(unoccupiedData[PR_direction][0]), 1.00000) == 1
        || floatcmp(floatabs(unoccupiedData[PR_direction][1]), 1.00000) == 1
        || floatcmp(floatabs(unoccupiedData[PR_direction][2]), 1.00000) == 1
        || floatcmp(floatabs(unoccupiedData[PR_position][0]), 20000.00000) == 1
        || floatcmp(floatabs(unoccupiedData[PR_position][1]), 20000.00000) == 1
        || floatcmp(floatabs(unoccupiedData[PR_position][2]), 20000.00000) == 1
        || floatcmp(floatabs(unoccupiedData[PR_angularVelocity][0]), 1.00000) == 1
        || floatcmp(floatabs(unoccupiedData[PR_angularVelocity][1]), 1.00000) == 1
        || floatcmp(floatabs(unoccupiedData[PR_angularVelocity][2]), 1.00000) == 1
        || floatcmp(floatabs(unoccupiedData[PR_velocity][0]), 100.00000) == 1
        || floatcmp(floatabs(unoccupiedData[PR_velocity][1]), 100.00000) == 1
        || floatcmp(floatabs(unoccupiedData[PR_velocity][2]), 100.00000) == 1
    ) {
        return false;
    }

    return true;
}

const AIM_SYNC = 203;

IPacket:AIM_SYNC(playerid, BitStream:bs)
{
    new aimData[PR_AimSync];
    
    BS_IgnoreBits(bs, 8);
    BS_ReadAimSync(bs, aimData);

    if (aimData[PR_aimZ] != aimData[PR_aimZ]) // is NaN
    {
        aimData[PR_aimZ] = 0.0;

        BS_SetWriteOffset(bs, 8);
        BS_WriteAimSync(bs, aimData);
    }

    return 1;
}

//------------

//End of File
/* (c) H2O Multiplayer 2018-2020. All rights reserved. */