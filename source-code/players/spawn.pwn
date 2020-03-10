/*
	SWAT vs Terrorists is a team death-match SA-MP game-mode script.
	Compatible with SA-MP 0.3.7 and later releases.

	Author: H2O
	Licensed under GNU GPLv3

	(c) 2018-2020 H2O Multiplayer. All rights reserved.
	Website: h2omultiplayer.com

	Spawn Module
*/

#include <YSI\y_hooks>
#include <YSI_Players\y_text> //Y_Less
loadtext mode_text[all], mode_text[client], mode_text[newcs], mode_text[dialogs], mode_text[gametexts];

forward Respawn(playerid);
public Respawn(playerid) {
	return TogglePlayerSpectating(playerid, false);
}

forward InitPlayer(playerid);
public InitPlayer(playerid) {
	TogglePlayerControllable(playerid, true);

	if (PlayerInfo[playerid][pDeathmatchId] == 5) {
		CarSpawner(playerid, 464);
	}

	if (PlayerInfo[playerid][pDeathmatchId] == 7) {
		CarSpawner(playerid, 432);
	}

	if (pDuelInfo[playerid][pDInMatch]) {
		SetPlayerHealth(playerid, 100.0);
		SetPlayerArmour(playerid, 100.0);
		Text_Send(playerid, $DUEL_FIGHT);
		PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
		PlayerPlaySound(TargetOf[playerid], 1057, 0.0, 0.0, 0.0);
		pDuelInfo[playerid][pDLocked] = 0;
		if (!pDuelInfo[playerid][pDRCDuel]) {
			GivePlayerWeapon(playerid, pDuelInfo[playerid][pDWeapon], pDuelInfo[playerid][pDAmmo]);
			GivePlayerWeapon(playerid, pDuelInfo[playerid][pDWeapon2], pDuelInfo[playerid][pDAmmo2]);
			SetPlayerSkillLevel(playerid, WEAPONSKILL_SAWNOFF_SHOTGUN, 1000);
		} else {
			CarSpawner(playerid, 464);
		}
	}
	else {
		SetPlayerHealth(playerid, 100.0);
		SetPlayerArmour(playerid, RankInfo[PlayerRank[playerid]][Rank_Armour]);
	}

	//If player is frozen, they shouldn't be able to move yet
	if (PlayerInfo[playerid][pFrozen]) {
		TogglePlayerControllable(playerid, false);
	}
	return 1;
}


SetSpawnDetails(playerid) {
	new rand = random(3);
		
	switch (rand) {
		case 0: SetSpawnInfo(playerid, 0xFE, pSkin[playerid], TeamInfo[pTeam[playerid]][Spawn_1][0], TeamInfo[pTeam[playerid]][Spawn_1][1], TeamInfo[pTeam[playerid]][Spawn_1][2], TeamInfo[pTeam[playerid]][Spawn_1][3], 0, 0, 0, 0, 0, 0);
		case 1: SetSpawnInfo(playerid, 0xFE, pSkin[playerid], TeamInfo[pTeam[playerid]][Spawn_2][0], TeamInfo[pTeam[playerid]][Spawn_2][1], TeamInfo[pTeam[playerid]][Spawn_2][2], TeamInfo[pTeam[playerid]][Spawn_2][3], 0, 0, 0, 0, 0, 0);
		case 2: SetSpawnInfo(playerid, 0xFE, pSkin[playerid], TeamInfo[pTeam[playerid]][Spawn_3][0], TeamInfo[pTeam[playerid]][Spawn_3][1], TeamInfo[pTeam[playerid]][Spawn_3][2], TeamInfo[pTeam[playerid]][Spawn_3][3], 0, 0, 0, 0, 0, 0);
	}
	return 1;
}

SetupPlayerSpawn(playerid) {
	if (!IsPlayerAnimsPreloaded[playerid]) {
		AnimPreloadForPlayer(playerid, "BOMBER");
		AnimPreloadForPlayer(playerid, "RAPPING");
		AnimPreloadForPlayer(playerid, "SHOP");
		AnimPreloadForPlayer(playerid, "BEACH");
		AnimPreloadForPlayer(playerid, "SMOKING");
		AnimPreloadForPlayer(playerid, "FOOD");
		AnimPreloadForPlayer(playerid, "ON_LOOKERS");
		AnimPreloadForPlayer(playerid, "DEALER");
		ApplyAnimation(playerid, "ROB_BANK", "null", 0.0, false, false, false, false, 0, false);

		IsPlayerAnimsPreloaded[playerid] = 1;
	}

	if (IsPlayerAnimsPreloaded[playerid] == 1) {
		AnimPreloadForPlayer(playerid, "CRACK");
		AnimPreloadForPlayer(playerid, "CARRY");
		AnimPreloadForPlayer(playerid, "COP_AMBIENT");
		AnimPreloadForPlayer(playerid, "PARK");
		AnimPreloadForPlayer(playerid, "INT_HOUSE");
		AnimPreloadForPlayer(playerid, "FOOD");
		AnimPreloadForPlayer(playerid, "GYMNASIUM");
		AnimPreloadForPlayer(playerid, "benchpress");
		AnimPreloadForPlayer(playerid, "Freeweights");

		IsPlayerAnimsPreloaded[playerid] = 2;
	}

	if (PlayerRank[playerid] < 1) {
		AddPlayerItem(playerid, HELMET, 1);
		Text_Send(playerid, $FREE_HELMET);
	}
	return 1;
}

EndProtection(playerid) {
	Text_Send(playerid, $PROTECTION_OVER);
	gInvisible[playerid] = false;

	//Update player marker status
	UpdateLabelText(playerid);

	//Remove spawn protection sprite if it exists
	if (IsPlayerAttachedObjectSlotUsed(playerid, 8)) {
		RemovePlayerAttachedObject(playerid, 8);
	}

	if (PlayerInfo[playerid][pDeathmatchId] >= 0) {
		AntiSK[playerid] = 0;
		return 1;
	}

	ShowPlayerHUD(playerid);

	AntiSK[playerid] = 0;
	AntiSKStart[playerid] = 0;

	if (!GetPlayerVirtualWorld(playerid) && !GetPlayerInterior(playerid)) {
		if (!pDuelInfo[playerid][pDInMatch] && PlayerInfo[playerid][pDeathmatchId] == -1) {
			//Invisibile players
			if (PlayerInfo[playerid][pDonorLevel]) {
				gInvisible[playerid] = true;
				gInvisibleTime[playerid] = gettime() + 60 * 5;
			} else if (pClass[playerid] == SNIPER && pAdvancedClass[playerid]) {
				gInvisible[playerid] = true;
				gInvisibleTime[playerid] = gettime() + 60 * 15;
			} else if (pClass[playerid] == RECON) {
				gInvisible[playerid] = true;
				gInvisibleTime[playerid] = gettime() + 60 * 30;
			}
		}

		//We keep class weapons here for safety measures
		GivePlayerWeapon(playerid, ClassInfo[pClass[playerid]][Class_Weapon1][0], ClassInfo[pClass[playerid]][Class_Weapon1][1]);
		GivePlayerWeapon(playerid, ClassInfo[pClass[playerid]][Class_Weapon2][0], ClassInfo[pClass[playerid]][Class_Weapon2][1]);
		GivePlayerWeapon(playerid, ClassInfo[pClass[playerid]][Class_Weapon3][0], ClassInfo[pClass[playerid]][Class_Weapon3][1]);
		GivePlayerWeapon(playerid, ClassInfo[pClass[playerid]][Class_Weapon4][0], ClassInfo[pClass[playerid]][Class_Weapon4][1]);
		GivePlayerWeapon(playerid, ClassInfo[pClass[playerid]][Class_Weapon5][0], ClassInfo[pClass[playerid]][Class_Weapon5][1]);

		if (GetPlayerDistanceFromPoint(playerid, TeamInfo[pTeam[playerid]][Spawn_1][0], TeamInfo[pTeam[playerid]][Spawn_1][1], TeamInfo[pTeam[playerid]][Spawn_1][2]) < 0.7 ||
			GetPlayerDistanceFromPoint(playerid, TeamInfo[pTeam[playerid]][Spawn_2][0], TeamInfo[pTeam[playerid]][Spawn_2][1], TeamInfo[pTeam[playerid]][Spawn_2][2]) < 0.7 ||
			GetPlayerDistanceFromPoint(playerid, TeamInfo[pTeam[playerid]][Spawn_3][0], TeamInfo[pTeam[playerid]][Spawn_3][1], TeamInfo[pTeam[playerid]][Spawn_3][2]) < 0.7) {
			if (GetTickCount() - PlayerInfo[playerid][pLastMove] > 1000) {
				PlayerInfo[playerid][pAFKOnSpawn] = 1;
				SetPlayerVirtualWorld(playerid, playerid + LONE_WORLD);
				AntiSK[playerid] = 1;
			}	
		} else {
			//We don't use that anymore but yeah we keep it for need
			if (FreeHunter) {
				inline FreeHunterDialog(pid, dialogid, response, listitem, string:inputtext[]) {
					#pragma unused dialogid, listitem, inputtext
					if (response) {
						if (IsPlayerInBase(pid) && GetPlayerVirtualWorld(pid) == 0 && GetPlayerInterior(pid) == 0) {
							new Float: X, Float: Y, Float: Z;
							GetPlayerPos(pid, X, Y, Z);
							SetPlayerPos(pid, X + frandom(30.0, -30.0, 2), Y + frandom(30.0, -30.0, 2), Z + 750 + frandom(30.0, -30.0, 2));

							SetTimerEx("SpawnFreeHunter", 150 + GetPlayerPing(pid), false, "i", pid);
						}	
					}
				}
				Text_DialogBox(playerid, DIALOG_STYLE_MSGBOX, using inline FreeHunterDialog, $DIALOG_MESSAGE_CAP, $FREE_HUNTER_DESC, $DIALOG_YES, $DIALOG_NO);
			}
		}	
	}

	//Donor ammo boost
	switch (PlayerInfo[playerid][pDonorLevel]) {
		case 1: NotifyPlayer(playerid, "~g~VIP: ~w~x2 ammo"), AddAmmo(playerid);
		case 2: NotifyPlayer(playerid, "~g~VIP: ~w~x3 ammo"), AddAmmo2(playerid);
		case 3, 4: NotifyPlayer(playerid, "~g~VIP: ~w~x4 ammo"), AddAmmo3(playerid);
		default: {
			if (ZoneInfo[AMMODEPOT][Zone_Owner] == pTeam[playerid]) {
				NotifyPlayer(playerid, "~r~Ammo Depot: ~w~x2 ammo");
				AddAmmo(playerid);
			}
		}
	}

	//Clan weapon
	if (IsPlayerInAnyClan(playerid)) {
		if (GetClanWeapon(GetPlayerClan(playerid)) != 0) {
			for (new x = 0; x < sizeof(WeaponInfo); x++) {
				if (WeaponInfo[x][Weapon_Id] == GetClanWeapon(GetPlayerClan(playerid))) {
					new message[150];
					GivePlayerWeapon(playerid, WeaponInfo[x][Weapon_Id], WeaponInfo[x][Weapon_Ammo]);

					format(message, sizeof(message), "~g~Clan:~w~ %s[ammo: %d]", ReturnWeaponName(WeaponInfo[x][Weapon_Id]), WeaponInfo[x][Weapon_Ammo]);
					NotifyPlayer(playerid, message);

					break;
				}
			}
		}
	}

	//Custom weapons
	if (PlayerRank[playerid] >= 5) {
		if (PlayerInfo[playerid][pFavWeap] > 0) {
			if (GetWeaponPriceById(PlayerInfo[playerid][pFavWeap]) <= GetPlayerCash(playerid)) {
				GivePlayerWeapon(playerid, PlayerInfo[playerid][pFavWeap], GetWeaponAmmoById(PlayerInfo[playerid][pFavWeap]));
			} else {
				Text_Send(playerid, $CLIENT_392x, GetWeaponPriceById(PlayerInfo[playerid][pFavWeap]) - GetPlayerCash(playerid),  ReturnWeaponName(PlayerInfo[playerid][pFavWeap]));
			}
		}
		if (PlayerInfo[playerid][pFavWeap2] > 0) {
			if (GetWeaponPriceById(PlayerInfo[playerid][pFavWeap2]) <= GetPlayerCash(playerid)) {
				GivePlayerWeapon(playerid, PlayerInfo[playerid][pFavWeap2], GetWeaponAmmoById(PlayerInfo[playerid][pFavWeap2]));
			} else {
				Text_Send(playerid, $CLIENT_392x, GetWeaponPriceById(PlayerInfo[playerid][pFavWeap2]) - GetPlayerCash(playerid), ReturnWeaponName(PlayerInfo[playerid][pFavWeap2]));
			}
		}
		if (PlayerInfo[playerid][pFavWeap3] > 0) {
			if (GetWeaponPriceById(PlayerInfo[playerid][pFavWeap3]) <= GetPlayerCash(playerid)) {
				GivePlayerWeapon(playerid, PlayerInfo[playerid][pFavWeap3], GetWeaponAmmoById(PlayerInfo[playerid][pFavWeap3]));
			} else {
				Text_Send(playerid, $CLIENT_392x, GetWeaponPriceById(PlayerInfo[playerid][pFavWeap3]) - GetPlayerCash(playerid), ReturnWeaponName(PlayerInfo[playerid][pFavWeap3]));
			}
		}
	}
	return 1;
}

hook OnPlayerSpawn(playerid) {
	if (!PlayerInfo[playerid][pLoggedIn]) {
		return Kick(playerid);
	}

	//Update player's HUD
	UpdatePlayerHUD(playerid);
	
	//Reset various variables and player items for a clean spawn
	ResetPlayerVars(playerid);
	ResetPlayerItems(playerid);

	//Add body toys if player set any of them
	for (new i = 0; i < 4; i++) {
		if (gModelsSlot[playerid][i] != -1) {
			SetPlayerAttachedObject(playerid, gModelsSlot[playerid][i], gModelsObj[playerid][i], gModelsPart[playerid][i], 
				ao[playerid][gModelsSlot[playerid][i]][ao_x], ao[playerid][gModelsSlot[playerid][i]][ao_y], ao[playerid][gModelsSlot[playerid][i]][ao_z], 
				ao[playerid][gModelsSlot[playerid][i]][ao_rx], ao[playerid][gModelsSlot[playerid][i]][ao_ry], ao[playerid][gModelsSlot[playerid][i]][ao_rz], 
				ao[playerid][gModelsSlot[playerid][i]][ao_sx], ao[playerid][gModelsSlot[playerid][i]][ao_sy], ao[playerid][gModelsSlot[playerid][i]][ao_sz]);	
		}
	}

	//Players can't avoid a jail man
	if (PlayerInfo[playerid][pJailed]) {
		ResetPlayerWeapons(playerid);
		JailPlayer(playerid);
		return 1;
	}

	//If the player is in team selection, let the sub-core take care of this
	if (pFirstSpawn[playerid] || PlayerInfo[playerid][pSelecting]) return true;

	//Clan wars are important too
	if (Iter_Contains(CWCLAN1, playerid) || Iter_Contains(CWCLAN2, playerid)) {
		if (IsPlayerInAnyClan(playerid) && GetClanSkin(GetPlayerClan(playerid)) != 0) {
			SetPlayerSkin(playerid, GetClanSkin(GetPlayerClan(playerid)));
			SetPlayerSkin(playerid, GetClanSkin(GetPlayerClan(playerid)));
		}
		return SetupClanwar(playerid);	    
	}

	//Then comes death-match
	if (PlayerInfo[playerid][pDeathmatchId] >= 0) {
		return SetupDeathmatch(playerid);
	}

	//PUBG integration
	if (PUBGStarted && Iter_Contains(PUBGPlayers, playerid)) {
		if (IsPlayerConnected(PlayerInfo[playerid][pSpecId])) {
			SetPlayerSkin(playerid, pSkin[playerid]);
			ResetPlayerWeapons(playerid);
			GivePlayerWeapon(playerid, 46, 1);
			new Float: X, Float: Y, Float: Z;
			GetPlayerPos(PlayerInfo[playerid][pSpecId], X, Y, Z);
			new Float:rx = frandom(15.0, -15.0, 2), Float:ry = frandom(15.0, -15.0, 2), Float:rz = frandom(15.0, -15.0, 2);
			SetPlayerPos(playerid, X + rx, Y + ry, Z + rz + 100);
			PlayerInfo[playerid][pSpecId] = INVALID_PLAYER_ID;
			ApplyAnimation(playerid, "PARACHUTE", "FALL_skyDive", 0.0, 0, 0, 0, 0, 0);
			SetPlayerVirtualWorld(playerid, PUBG_WORLD);
			SetPlayerInterior(playerid, 0);
			return 1;
		}    
	}

	//Sync player if something goes wrong
	if (ForceSync[playerid]) {
		ResyncData(playerid);
		return 1;
	}

	//Check if player is in duel
	PlayerDuelSpawn(playerid);

	//If player's in a duel YET, abort the spawn stuff and rest of code
	if (pDuelInfo[playerid][pDInMatch]) {
		return 1;
	}

	//Initiate player (disable control to not fall below ground)
	KillTimer(DelayerTimer[playerid]);
	DelayerTimer[playerid] = SetTimerEx("InitPlayer", GetPlayerPing(playerid) + 100, false, "i", playerid);
	TogglePlayerControllable(playerid, false);

	//Preload animations and add headshot-protection helmet for low level newbies (may include other stuff later)
	SetupPlayerSpawn(playerid);
	
	//If the player is stuck in the selection, show this? But I don't think it would even work so I better comment it
	//if (PlayerInfo[playerid][pSelecting]) {
		//PlayerInfo[playerid][pSelecting] = 0;
		//Text_Send(playerid, $CLIENT_274x);
		//ShowPlayerClass(playerid);
	//}

	//If player is in a clan that features clan skin, set it
	if (IsPlayerInAnyClan(playerid) && GetClanSkin(GetPlayerClan(playerid)) != 0) {
		pSkin[playerid] = GetClanSkin(GetPlayerClan(playerid));
		SetPlayerSkin(playerid, pSkin[playerid]);
	} else {
		SetPlayerSkin(playerid, pSkin[playerid]);
	}

	//Time to reset weapons
	ResetPlayerWeapons(playerid);
	
	//Now time for player spawn stuff
	new bool:BaseSpawn = true;
	if (pSpawn[playerid] != -1) {
		if (ZoneInfo[pSpawn[playerid]][Zone_Owner] != pTeam[playerid] ||
			ZoneInfo[pSpawn[playerid]][Zone_Attacked] == true) {
			BaseSpawn = true;
			Text_Send(playerid, $CLIENT_275x);
			pSpawn[playerid] = -1;
		} else {
			BaseSpawn = false;
		}
	}
	
	if (BaseSpawn) {
		new Float: fX = frandom(1.0, -1.0), Float: fY = frandom(1.0, -1.0), rand = random(3);
		switch (rand) {
			case SWAT: {
				SetPlayerPos(playerid, TeamInfo[pTeam[playerid]][Spawn_1][0] + fX, TeamInfo[pTeam[playerid]][Spawn_1][1] + fY, TeamInfo[pTeam[playerid]][Spawn_1][2]);
				SetPlayerFacingAngle(playerid, TeamInfo[pTeam[playerid]][Spawn_1][3]);
			}
			case TERRORIST: {
				SetPlayerPos(playerid, TeamInfo[pTeam[playerid]][Spawn_2][0] + fX, TeamInfo[pTeam[playerid]][Spawn_2][1] + fY, TeamInfo[pTeam[playerid]][Spawn_2][2]);
				SetPlayerFacingAngle(playerid, TeamInfo[pTeam[playerid]][Spawn_2][3]);
			}
			case VIP: {
				SetPlayerPos(playerid, TeamInfo[pTeam[playerid]][Spawn_3][0] + fX, TeamInfo[pTeam[playerid]][Spawn_3][1] + fY, TeamInfo[pTeam[playerid]][Spawn_3][2]);
				SetPlayerFacingAngle(playerid, TeamInfo[pTeam[playerid]][Spawn_3][3]);
			}
		}
	} else {
		SetPlayerPos(playerid, ZoneInfo[pSpawn[playerid]][Zone_CapturePoint][0], ZoneInfo[pSpawn[playerid]][Zone_CapturePoint][1], ZoneInfo[pSpawn[playerid]][Zone_CapturePoint][2]);
	}

	//Make sure to reset interior and virtual worlds
	SetPlayerVirtualWorld(playerid, BF_WORLD);
	SetPlayerInterior(playerid, 0);

	//Add promised donor stuff
	SetPlayerDonorSpawn(playerid);
  
	//Spawn perks for MEDKIT_ZONE, whatever was it
	if (pTeam[playerid] == ZoneInfo[MEDKIT_ZONE][Zone_Owner]) {
		AddPlayerItem(playerid, MK, 1);
	}

	//Spawn perks for whatever HELMET_ZONE was
	if (pTeam[playerid] == ZoneInfo[HELMET_ZONE][Zone_Owner] && !pItems[playerid][HELMET]) {
		AddPlayerItem(playerid, HELMET, 1);
	}


	//Add pilot license for pro jettrooper class? Was this intended?
	if (pClass[playerid] == JETTROOPER && pAdvancedClass[playerid]) {
		AddPlayerItem(playerid, PL, 1);
	}

	//Prepare spawn-kill protection
	AntiSKStart[playerid] = gettime() + PlayerInfo[playerid][pSpawnKillTime];

	Text_Send(playerid, $CLIENT_278x, PlayerInfo[playerid][pSpawnKillTime]);
	AntiSK[playerid] = 1;
	SetPlayerAttachedObject(playerid, 8, 18700, 1, 1.081000, 0.000000, -1.595999, -0.699999, -4.800000, -92.500000, 1.000000, 0.000000, 1.000000);
	SetPlayerChatBubble(playerid, "*Spawn Protected*", X11_RED2, 150.0, PlayerInfo[playerid][pSpawnKillTime] * 1000);
	SetPlayerColor(playerid, TeamInfo[pTeam[playerid]][Team_Color]);
	UpdateLabelText(playerid);
	return 1;
}

//End of File
/* (c) H2O Multiplayer 2018-2020. All rights reserved. */