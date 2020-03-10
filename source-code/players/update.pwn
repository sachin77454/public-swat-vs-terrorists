/*
	SWAT vs Terrorists is a team death-match SA-MP game-mode script.
	Compatible with SA-MP 0.3.7 and later releases.

	Author: H2O
	Licensed under GNU GPLv3

	(c) 2018-2020 H2O Multiplayer. All rights reserved.
	Website: h2omultiplayer.com

	Player Update Module
*/

#include <YSI\y_hooks>
#include <YSI_Players\y_text> //Y_Less
loadtext mode_text[all], mode_text[client], mode_text[newcs], mode_text[dialogs], mode_text[gametexts];

hook OnPlayerUpdate(playerid) {
	new weap = GetPlayerWeapon(playerid);

	new keys, ud, lr;
	GetPlayerKeys(playerid, keys, ud, lr);

	switch (weap) {
		case 24: {
			if (PlayerInfo[playerid][pCheckCBug] == 1 && PlayerInfo[playerid][pDeathmatchId] == -1 && !pDuelInfo[playerid][pDInMatch] 
				&& !Iter_Contains(ePlayers, playerid) && !Iter_Contains(PUBGPlayers, playerid)) {
				if ((keys & KEY_CROUCH) && !((keys & KEY_FIRE) || (keys & KEY_HANDBRAKE)) && GetPlayerSpecialAction(playerid) != SPECIAL_ACTION_DUCK) {
					if (PlayerInfo[playerid][cbugLastAmmo] > GetPlayerAmmo(playerid)) {
						PlayerInfo[playerid][pCheckCBug] = 0;
						Text_Send(playerid, $NO_CBUG);
						TogglePlayerControllable(playerid, false);
						FreezeTimer[playerid] = SetTimerEx("Unfreeze", 1000, false, "i", playerid);
						PlayerInfo[playerid][pCBugAttempts] ++;
					}
				}
			} else {
				PlayerInfo[playerid][pCheckCBug] = 0;
			}
		}
	    case 44, 45:
	    {
			if ((keys & KEY_FIRE) && (!IsPlayerInAnyVehicle(playerid))) {
				return 0;
			}
		}
	}
	return 1;
}

//End of File
/* (c) H2O Multiplayer 2018-2020. All rights reserved. */