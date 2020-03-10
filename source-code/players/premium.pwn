/*
	SWAT vs Terrorists is a team death-match SA-MP game-mode script. 
	Compatible with SA-MP 0.3.7 and later releases.

	Author: H2O
	Licensed under GNU GPLv3

	(c) 2018-2020 H2O Multiplayer. All rights reserved.
	Website: h2omultiplayer.com
*/

#include <YSI\y_text>
loadtext mode_text[all], mode_text[client], mode_text[newcs], mode_text[dialogs], mode_text[gametexts];

SetPlayerDonorSpawn(playerid) {
	switch (PlayerInfo[playerid][pDonorLevel]) {
		case 1: {
			AddPlayerItem(playerid, MK, 1);
			AddPlayerItem(playerid, SK, 1);
			Update3DTextLabelText(VipLabel[playerid], 0x9C693DCC, " ");
			Update3DTextLabelText(VipLabel[playerid], 0x9C693DCC, "Bronze");
		}
		case 2: {
			AddPlayerItem(playerid, MK, 2);
			AddPlayerItem(playerid, SK, 2);
			Update3DTextLabelText(VipLabel[playerid], 0x9C693DCC, " ");
			Update3DTextLabelText(VipLabel[playerid], 0xDBD5D5CC, "Silver");
			SetPlayerChatBubble(playerid, "100 ARMOUR (VIP)", X11_LIMEGREEN, 100.0, 3000);
			SetPlayerArmour(playerid, 100.0);
		}
		case 3: {
			AddPlayerItem(playerid, MK, 3);
			AddPlayerItem(playerid, SK, 3);
			AddPlayerItem(playerid, PL, 1);
			Update3DTextLabelText(VipLabel[playerid], 0x9C693DCC, " ");
			Update3DTextLabelText(VipLabel[playerid], 0xFF9E17CC, "Gold");
			SetPlayerChatBubble(playerid, "100 ARMOUR (VIP)", X11_LIMEGREEN, 100.0, 3000);
			SetPlayerArmour(playerid, 100.0);
		}
		case 4: {
			AddPlayerItem(playerid, MK, 4);
			AddPlayerItem(playerid, AK, 4);
			AddPlayerItem(playerid, SK, 1);
			AddPlayerItem(playerid, PL, 1);
			AddPlayerItem(playerid, DYNAMITE, 2);
			AddPlayerItem(playerid, LANDMINES, 2);
			Update3DTextLabelText(VipLabel[playerid], 0x9C693DCC, " ");
			Update3DTextLabelText(VipLabel[playerid], 0xFF00E1CC, "Platinum");
			SetPlayerSkillLevel(playerid, WEAPONSKILL_SAWNOFF_SHOTGUN, 1000);
			SetPlayerChatBubble(playerid, "100 ARMOUR (VIP)", X11_LIMEGREEN, 100.0, 3000);
			SetPlayerArmour(playerid, 100.0);
		}
		case 5: {
			AddPlayerItem(playerid, HELMET, 3);
			AddPlayerItem(playerid, MASK, 3);
			AddPlayerItem(playerid, MK, 5);
			AddPlayerItem(playerid, AK, 5);
			AddPlayerItem(playerid, SK, 2);
			AddPlayerItem(playerid, PL, 1);
			AddPlayerItem(playerid, DYNAMITE, 2);
			AddPlayerItem(playerid, LANDMINES, 2);
			Update3DTextLabelText(VipLabel[playerid], 0x9C693DCC, " ");
			Update3DTextLabelText(VipLabel[playerid], X11_LIGHTBLUE, "Ultimate");
			SetPlayerSkillLevel(playerid, WEAPONSKILL_SAWNOFF_SHOTGUN, 1000);
			SetPlayerChatBubble(playerid, "100 ARMOUR (VIP)", X11_LIMEGREEN, 100.0, 3000);
			SetPlayerMaxHealth(playerid, 125.0);
			SetPlayerHealth(playerid, 125.0);
			SetPlayerArmour(playerid, 100.0);
		}
		default: {
			Update3DTextLabelText(VipLabel[playerid], 0x00000000, " ");
			if (pClass[playerid] != SCOUT || !pAdvancedClass[playerid]) {
				SetPlayerSkillLevel(playerid, WEAPONSKILL_SAWNOFF_SHOTGUN, 0);
			} else {
				SetPlayerSkillLevel(playerid, WEAPONSKILL_SAWNOFF_SHOTGUN, 1000);
			}
		}
	}
	return 1;
}

//Donor Commands

CMD:vips(playerid) {
	new count = 0, VipStr[128];
	
	Text_Send(playerid, $NEWCLIENT_109x);

	foreach (new i: Player) {
		if (PlayerInfo[i][pDonorLevel] >= 1) {
			new rank[10];
			switch (PlayerInfo[i][pDonorLevel]) {
				case 1: rank = "Bronze";
				case 2: rank = "Silver";
				case 3: rank = "Golden";
				case 4: rank = "Platinum";
				case 5: rank = "Ultimate";
			}
			
			format(VipStr, sizeof(VipStr), "%s[%d] - %s VIP", PlayerInfo[i][PlayerName], i, rank);
			SendClientMessage(playerid, X11_DEEPSKYBLUE, VipStr);
			count++;
		}
	}

	if (count == 0) return Text_Send(playerid, $CLIENT_423x);    
	return 1;
}

alias:vcmds("vip");
CMD:vcmds(playerid) {
   if (PlayerInfo[playerid][pLoggedIn] == 1) {
		inline VIPCommandsResponse(pid, dialogid, response, listitem, string:inputtext[]) {
			#pragma unused dialogid, response, listitem, inputtext
			PC_EmulateCommand(pid, "/vcmds");
		}   	
   		inline VCmds(pid, dialogid, response, listitem, string:inputtext[]) {
   			#pragma unused dialogid, inputtext
			if (response) {
				switch (listitem) {
					case 0: Text_DialogBox(pid, DIALOG_STYLE_MSGBOX, using inline VIPCommandsResponse, $VIP_CMDS_CAP, $VIP_CMDS_BRONZE, $DIALOG_RETURN, "");
					case 1: Text_DialogBox(pid, DIALOG_STYLE_MSGBOX, using inline VIPCommandsResponse, $VIP_CMDS_CAP, $VIP_CMDS_SILVER, $DIALOG_RETURN, "");
					case 2: Text_DialogBox(pid, DIALOG_STYLE_MSGBOX, using inline VIPCommandsResponse, $VIP_CMDS_CAP, $VIP_CMDS_GOLD, $DIALOG_RETURN, "");
					case 3: Text_DialogBox(pid, DIALOG_STYLE_MSGBOX, using inline VIPCommandsResponse, $VIP_CMDS_CAP, $VIP_CMDS_PLAT, $DIALOG_RETURN, "");
					case 4: Text_DialogBox(pid, DIALOG_STYLE_MSGBOX, using inline VIPCommandsResponse, $VIP_CMDS_CAP, $VIP_CMDS_ULT, $DIALOG_RETURN, "");
				}
			}
   		}
		Dialog_ShowCallback(playerid, using inline VCmds, DIALOG_STYLE_LIST, ""RED2"SvT - VIP Features",
		"{A6804B}Bronze Features\n\
		"IVORY"Silver Features\n\
		{E6AB2E}Golden Features\n\
		{E62ED6}Platinum Features\n\
		"LIGHTBLUE"Ultimate Features", "Browse", "X");
   }
   
   return 1;
}

CMD:vtune(playerid, params[]) {
	if (PlayerInfo[playerid][pDonorLevel] >= 4) {
		if (IsPlayerInAnyVehicle(playerid)) {
			new LVehicleID = GetPlayerVehicleID(playerid), LModel = GetVehicleModel(LVehicleID);
			switch (LModel) {
				case 448, 461, 462, 463, 468, 471, 509, 510, 521, 522, 523, 581, 586, 449: return Text_Send(playerid, $CLIENT_426x);
			}
			Tuneacar(LVehicleID);
			PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
			SetPlayerChatBubble(playerid, "VIP vehicle tuned", 0xFF00FFCC, 100.0, 3000);
		}  else Text_Send(playerid, $CLIENT_445x);
	}  else Text_Send(playerid, $CLIENT_362x);
	return 1;
}

CMD:vtc(playerid, params[]) {
	if (PlayerInfo[playerid][pDonorLevel] >= 3) {
		if (!IsPlayerInAnyVehicle(playerid)) {
			if (PlayerInfo[playerid][pCar] != -1) DestroyVehicle(PlayerInfo[playerid][pCar]);
			PlayerInfo[playerid][pCar] = -1;

			new Float:X, Float:Y, Float:Z, Float:Angle, Tunedcar;
			GetPlayerPos(playerid, X, Y, Z);

			GetPlayerFacingAngle(playerid, Angle);
			Tunedcar = CreateVehicle(560, X, Y, Z, Angle, 1, -1, -1);
			PutPlayerInVehicle(playerid, Tunedcar, 0);

			AddVehicleComponent(Tunedcar, 1028);
			AddVehicleComponent(Tunedcar, 1030);
			AddVehicleComponent(Tunedcar, 1031);
			AddVehicleComponent(Tunedcar, 1138);
			AddVehicleComponent(Tunedcar, 1140);
			AddVehicleComponent(Tunedcar, 1170);
			AddVehicleComponent(Tunedcar, 1028);
			AddVehicleComponent(Tunedcar, 1030);
			AddVehicleComponent(Tunedcar, 1031);
			AddVehicleComponent(Tunedcar, 1138);
			AddVehicleComponent(Tunedcar, 1140);
			AddVehicleComponent(Tunedcar, 1170);
			AddVehicleComponent(Tunedcar, 1080);
			AddVehicleComponent(Tunedcar, 1086);
			AddVehicleComponent(Tunedcar, 1087);
			AddVehicleComponent(Tunedcar, 1010);

			PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
			ChangeVehiclePaintjob(Tunedcar, 0);

			SetVehicleVirtualWorld(Tunedcar, GetPlayerVirtualWorld(playerid));
			LinkVehicleToInterior(Tunedcar, GetPlayerInterior(playerid));

			pVehId[playerid] = PlayerInfo[playerid][pCar] = Tunedcar;
		}  else Text_Send(playerid, $CLIENT_433x);
	}
	return 1;
}

CMD:vbike(playerid, params[]) {
	if (pDuelInfo[playerid][pDInMatch] == 1) return Text_Send(playerid, $COMMAND_INDUEL);
	if (PlayerInfo[playerid][pDeathmatchId] > -1) return Text_Send(playerid, $COMMAND_INDM);
	if (Iter_Contains(ePlayers, playerid)) return Text_Send(playerid, $COMMAND_INEVENT);
	if (Iter_Contains(CWCLAN1, playerid) || Iter_Contains(CWCLAN2, playerid)) return Text_Send(playerid, $COMMAND_INCW);
	if (Iter_Contains(PUBGPlayers, playerid)) return Text_Send(playerid, $COMMAND_INPUBG);
	if (PlayerInfo[playerid][pLastHitTick] > gettime()) return Text_Send(playerid, $JUSTHIT, PlayerInfo[playerid][pLastHitTick] - gettime());

	if (PlayerInfo[playerid][pDonorLevel] >= 2) {
		if (pCooldown[playerid][31] < gettime()) {
			CarSpawner(playerid, 522);
			pCooldown[playerid][31] = gettime() + 35;
			SetPlayerChatBubble(playerid, "Spawned VIP bike", X11_PINK, 120.0, 10000);
		} else {
			Text_Send(playerid, $COOLDOWN_TIMELEFT, pCooldown[playerid][31] - gettime());
		}
	}  else Text_Send(playerid, $VIP_LOW_RANK);
	return 1;
}

CMD:vtime(playerid, params[]) {
	if (PlayerInfo[playerid][pDonorLevel] >= 2) {
		if (isnull(params)) return ShowSyntax(playerid, "/vtime [hour]");

		new time = strval(params);
		SetPlayerTime(playerid, time, 0);
	}  else Text_Send(playerid, $VIP_LOW_RANK);
	return 1;
}

CMD:vweather(playerid, params[]) {
	if (PlayerInfo[playerid][pDonorLevel] >= 2) {
		new weather;
		if (sscanf(params, "i", weather)) return ShowSyntax(playerid, "/vweather [weather]");
		if (weather > 45 || weather < 0) return ShowSyntax(playerid, "/vweather [weather id 0-45]");
		SetPlayerWeather(playerid, weather);
	}  else Text_Send(playerid, $VIP_LOW_RANK);
	return 1;
}

CMD:vboat(playerid,params[]) {
	if (pDuelInfo[playerid][pDInMatch] == 1) return Text_Send(playerid, $COMMAND_INDUEL);
	if (PlayerInfo[playerid][pDeathmatchId] > -1) return Text_Send(playerid, $COMMAND_INDM);
	if (Iter_Contains(ePlayers, playerid)) return Text_Send(playerid, $COMMAND_INEVENT);
	if (Iter_Contains(CWCLAN1, playerid) || Iter_Contains(CWCLAN2, playerid)) return Text_Send(playerid, $COMMAND_INCW);
	if (Iter_Contains(PUBGPlayers, playerid)) return Text_Send(playerid, $COMMAND_INPUBG);
	if (PlayerInfo[playerid][pLastHitTick] > gettime()) return Text_Send(playerid, $JUSTHIT, PlayerInfo[playerid][pLastHitTick] - gettime());

	if (PlayerInfo[playerid][pDonorLevel] >= 3) {
		if (pCooldown[playerid][5] < gettime()) {
			CarSpawner(playerid, 452);
			pCooldown[playerid][5] = gettime() + 35;
		} else {
			Text_Send(playerid, $COOLDOWN_TIMELEFT, pCooldown[playerid][5] - gettime());
		}
	}  else Text_Send(playerid, $VIP_LOW_RANK);
	return 1;
}

CMD:vcar(playerid) {
	if (pDuelInfo[playerid][pDInMatch] == 1) return Text_Send(playerid, $COMMAND_INDUEL);
	if (PlayerInfo[playerid][pDeathmatchId] > -1) return Text_Send(playerid, $COMMAND_INDM);
	if (Iter_Contains(ePlayers, playerid)) return Text_Send(playerid, $COMMAND_INEVENT);
	if (Iter_Contains(CWCLAN1, playerid) || Iter_Contains(CWCLAN2, playerid)) return Text_Send(playerid, $COMMAND_INCW);
	if (Iter_Contains(PUBGPlayers, playerid)) return Text_Send(playerid, $COMMAND_INPUBG);
	if (PlayerInfo[playerid][pLastHitTick] > gettime()) return Text_Send(playerid, $JUSTHIT, PlayerInfo[playerid][pLastHitTick] - gettime());

	if (PlayerInfo[playerid][pDonorLevel] >= 1) {
		if (pCooldown[playerid][5] < gettime()) {
			CarSpawner(playerid, 411);
			pCooldown[playerid][5] = gettime() + 35;
			SetPlayerChatBubble(playerid, "Spawned VIP car", X11_PINK, 120.0, 10000);
		} else {
			Text_Send(playerid, $COOLDOWN_TIMELEFT, pCooldown[playerid][5] - gettime());
		}
	}  else Text_Send(playerid, $VIP_LOW_RANK);
	return 1;
}

CMD:vcar2(playerid, params[]) {
	if (PlayerInfo[playerid][pDonorLevel] >= 5) {
		if (pDuelInfo[playerid][pDInMatch] == 1) return Text_Send(playerid, $COMMAND_INDUEL);
		if (PlayerInfo[playerid][pDeathmatchId] > -1) return Text_Send(playerid, $COMMAND_INDM);
		if (Iter_Contains(ePlayers, playerid)) return Text_Send(playerid, $COMMAND_INEVENT);
		if (Iter_Contains(CWCLAN1, playerid) || Iter_Contains(CWCLAN2, playerid)) return Text_Send(playerid, $COMMAND_INCW);
		if (Iter_Contains(PUBGPlayers, playerid)) return Text_Send(playerid, $COMMAND_INPUBG);

		new car, Carstr[90];
		if (sscanf(params, "s[90]", Carstr)) return ShowSyntax(playerid, "/car [modelid/name]");
		if (IsPlayerInAnyVehicle(playerid)) return Text_Send(playerid, $CLIENT_433x);
		if (!IsNumeric(Carstr))
		{
		   car = GetVehicleModelIDFromName(Carstr);

		} else car = strval(Carstr);

		if (car < 400 || car > 611) return ShowSyntax(playerid, "/vcar2 [model id 400-610]");
		if (PlayerInfo[playerid][pCar] != -1) DestroyVehicle(PlayerInfo[playerid][pCar]);
		PlayerInfo[playerid][pCar] = -1;

		new LVehicleID, Float:X, Float:Y, Float:Z, Float:Angle, int1;

		GetPlayerPos(playerid, X, Y, Z);
		GetPlayerFacingAngle(playerid, Angle);

		int1 = GetPlayerInterior(playerid);

		LVehicleID = CreateVehicle(car, X + 3, Y, Z + 2, Angle, 0, 7, -1);
		pVehId[playerid] = PlayerInfo[playerid][pCar] = LVehicleID;

		LinkVehicleToInterior(LVehicleID, int1);

		new world;
		world = GetPlayerVirtualWorld(playerid);
		SetVehicleVirtualWorld(LVehicleID, world);

		PutPlayerInVehicle(playerid, PlayerInfo[playerid][pCar], 0);
	}  else Text_Send(playerid, $CLIENT_362x);
	return 1;
}

CMD:vmon(playerid) {
	if (pDuelInfo[playerid][pDInMatch] == 1) return Text_Send(playerid, $COMMAND_INDUEL);
	if (PlayerInfo[playerid][pDeathmatchId] > -1) return Text_Send(playerid, $COMMAND_INDM);
	if (Iter_Contains(ePlayers, playerid)) return Text_Send(playerid, $COMMAND_INEVENT);
	if (Iter_Contains(CWCLAN1, playerid) || Iter_Contains(CWCLAN2, playerid)) return Text_Send(playerid, $COMMAND_INCW);
	if (Iter_Contains(PUBGPlayers, playerid)) return Text_Send(playerid, $COMMAND_INPUBG);
	if (PlayerInfo[playerid][pLastHitTick] > gettime()) return Text_Send(playerid, $JUSTHIT, PlayerInfo[playerid][pLastHitTick] - gettime());

	if (PlayerInfo[playerid][pDonorLevel] >= 4) {
		if (pCooldown[playerid][5] < gettime()) {
			CarSpawner(playerid, 444);
			pCooldown[playerid][5] = gettime() + 35;
			SetPlayerChatBubble(playerid, "Spawned VIP monster", X11_PINK, 120.0, 10000);
		} else {
			Text_Send(playerid, $COOLDOWN_TIMELEFT, pCooldown[playerid][5] - gettime());
		}
	}  else Text_Send(playerid, $VIP_LOW_RANK);
	return 1;
}

CMD:vheli(playerid, params[]) {
	if (pDuelInfo[playerid][pDInMatch] == 1) return Text_Send(playerid, $COMMAND_INDUEL);
	if (PlayerInfo[playerid][pDeathmatchId] > -1) return Text_Send(playerid, $COMMAND_INDM);
	if (Iter_Contains(ePlayers, playerid)) return Text_Send(playerid, $COMMAND_INEVENT);
	if (Iter_Contains(CWCLAN1, playerid) || Iter_Contains(CWCLAN2, playerid)) return Text_Send(playerid, $COMMAND_INCW);
	if (Iter_Contains(PUBGPlayers, playerid)) return Text_Send(playerid, $COMMAND_INPUBG);
	if (PlayerInfo[playerid][pLastHitTick] > gettime()) return Text_Send(playerid, $JUSTHIT, PlayerInfo[playerid][pLastHitTick] - gettime());

	if (PlayerInfo[playerid][pDonorLevel] >= 2) {
		if (pCooldown[playerid][15] < gettime()) {
			CarSpawner(playerid, 487);
			pCooldown[playerid][15] = gettime() + 35;
			SetPlayerChatBubble(playerid, "Spawned VIP helicopter", X11_PINK, 120.0, 10000);
		} else {
			Text_Send(playerid, $COOLDOWN_TIMELEFT, pCooldown[playerid][15] - gettime());
		}
	}  else Text_Send(playerid, $VIP_LOW_RANK);
	return 1;
}

CMD:vskin(playerid, params[]) {
   if (pDuelInfo[playerid][pDInMatch] == 1) return Text_Send(playerid, $COMMAND_INDUEL);
   if (PlayerInfo[playerid][pLoggedIn] == 1)
   {
		if (PlayerInfo[playerid][pDonorLevel] >= 2) {
			if (!IsValidSkin(strval(params))) return ShowSyntax(playerid, "/vskin [valid skin id]");
			if (isnull(params)) {
				pSkin[playerid] = 165;
				SetPlayerSkin(playerid, 165);
				NotifyPlayer(playerid, "Use /vskin [ID] to choose another skin.");
			} else {
				pSkin[playerid] = strval(params);
				SetPlayerSkin(playerid, strval(params));
			}
			SetPlayerChatBubble(playerid, "Changed VIP skin", X11_PINK, 120.0, 10000);
		}  else Text_Send(playerid, $VIP_LOW_RANK);
   }

   return 1;
}

CMD:vfr(playerid) {
	if (pDuelInfo[playerid][pDInMatch] == 1) return Text_Send(playerid, $COMMAND_INDUEL);

	if (PlayerInfo[playerid][pDonorLevel] >= 2) {
		if (pCooldown[playerid][12] < gettime())
		{
			new Float:x, Float:y, Float:z;
			pCooldown[playerid][12] = gettime() + 125;
			GetPlayerPos(playerid, x, y, z);

			foreach (new i: Player) {
				if (i != playerid && IsPlayerInAnyVehicle(i)) {
					if (pTeam[playerid] != pTeam[i]
						&& !GetPlayerInterior(i) && !GetPlayerVirtualWorld(i) && IsPlayerSpawned(i)) {
						if (IsPlayerInRangeOfPoint(i, 15.0, x + 6, y + 6, z + 6)) {
							SetVehicleHealth(GetPlayerVehicleID(i), 0.0);
							GameTextForPlayer(playerid, "~r~BURNT", 2500, 1);
						}
					}
				}
			}

			SetPlayerChatBubble(playerid, "Used VIP range fire", X11_PINK, 120.0, 10000);
		} else {
			Text_Send(playerid, $COOLDOWN_TIMELEFT, pCooldown[playerid][12] - gettime());
		}
	}  else Text_Send(playerid, $CLIENT_362x);    
	return 1;
}

CMD:vheal(playerid, params[]) {
	if (pDuelInfo[playerid][pDInMatch] == 1) return Text_Send(playerid, $COMMAND_INDUEL);
	if (PlayerInfo[playerid][pDeathmatchId] > -1) return Text_Send(playerid, $COMMAND_INDM);
	if (Iter_Contains(ePlayers, playerid)) return Text_Send(playerid, $COMMAND_INEVENT);
	if (Iter_Contains(CWCLAN1, playerid) || Iter_Contains(CWCLAN2, playerid)) return Text_Send(playerid, $COMMAND_INCW);
	if (Iter_Contains(PUBGPlayers, playerid)) return Text_Send(playerid, $COMMAND_INPUBG);

	if (PlayerInfo[playerid][pLoggedIn] == 1) {
		if (PlayerInfo[playerid][pDonorLevel] >= 1) {
			if (pCooldown[playerid][1] < gettime()) {
				SetPlayerHealth(playerid, 100.0);
				pCooldown[playerid][1] = gettime() + 100;
			}
			else {
				Text_Send(playerid, $COOLDOWN_TIMELEFT, pCooldown[playerid][1] - gettime());
			}

			SetPlayerChatBubble(playerid, "Used VIP health refill", X11_PINK, 120.0, 10000);
		}  else Text_Send(playerid, $VIP_LOW_RANK);
	}
	return 1;
}

CMD:vammo(playerid, params[]) {
	if (pDuelInfo[playerid][pDInMatch] == 1) return Text_Send(playerid, $COMMAND_INDUEL);
	if (PlayerInfo[playerid][pDeathmatchId] > -1) return Text_Send(playerid, $COMMAND_INDM);
	if (Iter_Contains(ePlayers, playerid)) return Text_Send(playerid, $COMMAND_INEVENT);
	if (Iter_Contains(CWCLAN1, playerid) || Iter_Contains(CWCLAN2, playerid)) return Text_Send(playerid, $COMMAND_INCW);
	if (Iter_Contains(PUBGPlayers, playerid)) return Text_Send(playerid, $COMMAND_INPUBG);

	if (PlayerInfo[playerid][pLoggedIn] == 1) {
		if (PlayerInfo[playerid][pDonorLevel] >= 1) {
			if (pCooldown[playerid][7] < gettime()) {
				AddAmmo(playerid);
				GameTextForPlayer(playerid, "~g~ADDED AMMO", 2500, 1);
				pCooldown[playerid][7] = gettime() + 100;
			}
			else {
				Text_Send(playerid, $COOLDOWN_TIMELEFT, pCooldown[playerid][7] - gettime());
			}

			SetPlayerChatBubble(playerid, "Added VIP ammo", X11_PINK, 120.0, 10000);
		}
		 else Text_Send(playerid, $VIP_LOW_RANK);
	}    
	return 1;
}

CMD:vweaps(playerid) {
	if (pDuelInfo[playerid][pDInMatch] == 1) return Text_Send(playerid, $COMMAND_INDUEL);
	if (PlayerInfo[playerid][pDeathmatchId] > -1) return Text_Send(playerid, $COMMAND_INDM);
	if (Iter_Contains(ePlayers, playerid)) return Text_Send(playerid, $COMMAND_INEVENT);
	if (Iter_Contains(CWCLAN1, playerid) || Iter_Contains(CWCLAN2, playerid)) return Text_Send(playerid, $COMMAND_INCW);
	if (Iter_Contains(PUBGPlayers, playerid)) return Text_Send(playerid, $COMMAND_INPUBG);

	if (PlayerInfo[playerid][pLoggedIn] == 1) {
		if (PlayerInfo[playerid][pDonorLevel] >= 2) {
			if (pCooldown[playerid][11] < gettime()) {
				GivePlayerWeapon(playerid, 26, 500);
				GivePlayerWeapon(playerid, 24, 500);
				GivePlayerWeapon(playerid, 32, 500);
				GivePlayerWeapon(playerid, 35, 1);
				GivePlayerWeapon(playerid, 16, 2);

				pCooldown[playerid][11] = gettime() + 60;
			} else {
				Text_Send(playerid, $COOLDOWN_TIMELEFT, pCooldown[playerid][11] - gettime());
			}

			SetPlayerChatBubble(playerid, "Added VIP weapons", X11_PINK, 120.0, 10000);
		}
		 else Text_Send(playerid, $VIP_LOW_RANK);
	}    
	return 1;
}

CMD:vcc(playerid, params[]) {
	if (pDuelInfo[playerid][pDInMatch] == 1) return Text_Send(playerid, $CLIENT_436x);
	if (!IsPlayerInAnyVehicle(playerid)) return Text_Send(playerid, $CLIENT_436x);

	if (PlayerInfo[playerid][pDonorLevel] >= 1) {
		new col[2];
		if (sscanf(params, "ii", col[0], col[1])) return ShowSyntax(playerid, "/vcc [1st color] [2nd color]");
		ChangeVehicleColor(GetPlayerVehicleID(playerid), col[0], col[1]);
		SetPlayerChatBubble(playerid, "Changed vehicle color", X11_PINK, 120.0, 10000);
	}  else Text_Send(playerid, $VIP_LOW_RANK);    
	return 1;
}

CMD:vnos(playerid) {
   if (pDuelInfo[playerid][pDInMatch] == 1) return Text_Send(playerid, $CLIENT_436x);
   if (PlayerInfo[playerid][pLoggedIn] == 1) {
		if (PlayerInfo[playerid][pDonorLevel] >= 1) {
			if (!IsPlayerInAnyVehicle(playerid)) return Text_Send(playerid, $CLIENT_436x);
			AddVehicleComponent(GetPlayerVehicleID(playerid), 1010);
			SetPlayerChatBubble(playerid, "Added nitro", X11_PINK, 120.0, 10000);
		}  else Text_Send(playerid, $VIP_LOW_RANK);
   }

   return 1;
}

//VIP Shop

alias:vshop("vhelp", "vinfo", "shop");
CMD:vshop(playerid) { 
	inline CashVShop(pid, dialogid, response, listitem, string:inputtext[]) {
		#pragma unused dialogid, inputtext, listitem
		if (!response) return PC_EmulateCommand(pid, "/vshop");
		if (!IsNumeric(inputtext)) return Text_Send(pid, $NEWCLIENT_116x);
		new cash = strval(inputtext);
		if (cash <= 0) return Text_Send(pid, $NEWCLIENT_117x);
		if (cash > 1000000) return Text_Send(pid, $NEWCLIENT_118x);
		new Float: multiplier;
		multiplier = 0.00001 * cash;
		if (multiplier > PlayerInfo[pid][pCoins]) {
			Text_Send(pid, $NEWCLIENT_119x, multiplier - PlayerInfo[pid][pCoins]);
			return 1;
		}
		PlayerInfo[pid][pCoins] -= multiplier;
		PlayerInfo[pid][pCoinsSpent] += multiplier;
		PlayerInfo[pid][pPaymentsAccepted] ++;

		Text_Send(pid, $NEWCLIENT_120x, cash, multiplier);

		PlayerPlaySound(pid, 1057, 0.0, 0.0, 0.0);
		SetPlayerChatBubble(pid, "Bought Money", X11_ORANGE, 300.0, 10000);
		Text_Send(pid, $NEWCLIENT_121x);
		GivePlayerCash(pid, cash);

		SendDCByName(CHANNEL_PAYMENTS_NAME, "%s bought $%d for %0.2f coin(s)", PlayerInfo[pid][PlayerName], cash, multiplier);
	}

	inline ScoreVShop(pid, dialogid, response, listitem, string:inputtext[]) {
		#pragma unused dialogid, inputtext, listitem
		if (!response) return PC_EmulateCommand(pid, "/vshop");
		if (!IsNumeric(inputtext)) return Text_Send(pid, $NEWCLIENT_122x);
		new Score = strval(inputtext);
		if (Score <= 0) return Text_Send(pid, $NEWCLIENT_123x);
		if (Score > 10000) return Text_Send(pid, $NEWCLIENT_124x);
		new Float: multiplier;
		multiplier = 0.03 * Score;
		if (multiplier > PlayerInfo[pid][pCoins]) {
			Text_Send(pid, $NEWCLIENT_119x, multiplier - PlayerInfo[pid][pCoins]);
			return 1;
		}
		PlayerInfo[pid][pCoins] -= multiplier;
		PlayerInfo[pid][pCoinsSpent] += multiplier;
		PlayerInfo[pid][pPaymentsAccepted] ++;

		Text_Send(pid, $NEWCLIENT_125x, Score, multiplier);

		PlayerPlaySound(pid, 1057, 0.0, 0.0, 0.0);
		SetPlayerChatBubble(pid, "Bought Score", X11_ORANGE, 300.0, 10000);
		Text_Send(pid, $NEWCLIENT_121x);
		GivePlayerScore(pid, Score);

		SendDCByName(CHANNEL_PAYMENTS_NAME, "%s bought %d score for %0.2f coin(s)", PlayerInfo[pid][PlayerName], Score, multiplier);
	}

	inline KDRVShop(pid, dialogid, response, listitem, string:inputtext[]) {
		#pragma unused dialogid, inputtext, listitem, inputtext
		if (!response) return PC_EmulateCommand(pid, "/vshop");
		new Float: multiplier;
		multiplier = 10;
		if (multiplier > PlayerInfo[pid][pCoins]) {
			Text_Send(pid, $NEWCLIENT_119x, multiplier - PlayerInfo[pid][pCoins]);
			return 1;
		}
		if (!PlayerInfo[pid][pDeaths]) return Text_Send(pid, $NEWCLIENT_126x);
		PlayerInfo[pid][pCoins] -= multiplier;
		PlayerInfo[pid][pCoinsSpent] += multiplier;
		PlayerInfo[pid][pPaymentsAccepted] ++;

		Text_Send(pid, $NEWCLIENT_127x, multiplier);

		PlayerPlaySound(pid, 1057, 0.0, 0.0, 0.0);
		SetPlayerChatBubble(pid, "Reset K/D", X11_ORANGE, 300.0, 10000);
		Text_Send(pid, $NEWCLIENT_121x);
		PlayerInfo[pid][pKills] = 0;
		PlayerInfo[pid][pDeaths] = 0;

		SendDCByName(CHANNEL_PAYMENTS_NAME, "%s reset their deaths for 10 coins", PlayerInfo[pid][PlayerName]);
	}

	inline PackVShop(pid, dialogid, response, listitem, string:inputtext[]) {
		#pragma unused dialogid, inputtext, listitem
		if (!response) return PC_EmulateCommand(pid, "/vshop");
		if (!IsNumeric(inputtext)) return Text_Send(pid, $NEWCLIENT_128x);
		new days = strval(inputtext);
		if (days <= 0) return Text_Send(pid, $NEWCLIENT_129x);
		if (days > 30) return Text_Send(pid, $NEWCLIENT_130x);
		if (PlayerInfo[pid][pDonorLevel] > 4) return Text_Send(pid, $NEWCLIENT_131x);
		new Float: multiplier;
		multiplier = 0.333 * days;
		if (multiplier > PlayerInfo[pid][pCoins]) {
			Text_Send(pid, $NEWCLIENT_119x, multiplier - PlayerInfo[pid][pCoins]);
			return 1;
		}
		PlayerInfo[pid][pCoins] -= multiplier;
		PlayerInfo[pid][pCoinsSpent] += multiplier;
		PlayerInfo[pid][pPaymentsAccepted] ++;
		Text_Send(pid, $NEWCLIENT_132x, days, multiplier, PlayerInfo[pid][pDonorLevel] + 1);
		PlayerPlaySound(pid, 1057, 0.0, 0.0, 0.0);
		SetPlayerChatBubble(pid, "Upgraded VIP", X11_ORANGE, 300.0, 10000);
		PlayerInfo[pid][pDonorLevel] ++;
		new query[450];
		mysql_format(Database, query, sizeof query, "CREATE EVENT `%d_VSHOP_VPACK%d` ON SCHEDULE AT CURRENT_TIMESTAMP() + INTERVAL %d DAY DO UPDATE `Players` SET `DonorLevel` = `DonorLevel`-1 WHERE `ID` = '%d'", PlayerInfo[pid][pAccountId], random(402) + 5000, days, PlayerInfo[pid][pAccountId]);
		mysql_tquery(Database, query);
		mysql_format(Database, query, sizeof query, "UPDATE `Players` SET `DonorLevel` = '%d' WHERE `ID` = '%d' LIMIT 1", PlayerInfo[pid][pDonorLevel], PlayerInfo[pid][pAccountId]);
		mysql_tquery(Database, query);
		Text_Send(pid, $NEWCLIENT_121x);

		SendDCByName(CHANNEL_PAYMENTS_NAME, "%s upgraded their VIP to Tier %d for %d days for %0.2f coin(s)", PlayerInfo[pid][PlayerName], PlayerInfo[pid][pDonorLevel], days, multiplier);
	}

	inline ClanBaseVShop(pid, dialogid, response, listitem, string:inputtext[]) {
		#pragma unused dialogid, inputtext, listitem
		if (!response) return PC_EmulateCommand(pid, "/vshop");
		if (!IsNumeric(inputtext)) return Text_Send(pid, $NEWCLIENT_128x);
		new days = strval(inputtext);
		if (days <= 0) return Text_Send(pid, $NEWCLIENT_129x);
		if (days > 30) return Text_Send(pid, $NEWCLIENT_130x);
		if (!IsPlayerInAnyClan(pid)) return Text_Send(pid, $CLIENT_358x);
		if (GetPlayerClanRank(pid) < 10) return Text_Send(pid, $CLIENT_362x);

		new clanbase_owner = 0;
		for (new i = 0; i < MAX_CLANS; i++) {
			if (ClanInfo[i][Clan_Id] != -1 && ClanInfo[i][Clan_Baseperk]) {
				clanbase_owner ++;
				break;
			}
		}

		if (clanbase_owner) return Text_Send(pid, $NEWCLIENT_133x);

		new Float: multiplier;
		multiplier = 0.8 * days;

		if (multiplier > PlayerInfo[pid][pCoins]) {
			Text_Send(pid, $NEWCLIENT_119x, multiplier - PlayerInfo[pid][pCoins]);
			return 1;
		}

		PlayerInfo[pid][pCoins] -= multiplier;
		PlayerInfo[pid][pCoinsSpent] += multiplier;
		PlayerInfo[pid][pPaymentsAccepted] ++;

		Text_Send(pid, $NEWCLIENT_134x, days, multiplier);

		PlayerPlaySound(pid, 1057, 0.0, 0.0, 0.0);
		SetPlayerChatBubble(pid, "Bought VIP Fortress", X11_ORANGE, 300.0, 10000);

		Text_Send(pid, $NEWCLIENT_121x);

		for (new i = 0; i < MAX_CLANS; i++) {
			if (ClanInfo[i][Clan_Id] == pClan[pid]) {
				ClanInfo[i][Clan_Baseperk] = gettime() + (86400 * 7);
				break;
			}
		}

		foreach(new i: Player) if (pClan[i] == pClan[pid]) {
			Text_Send(i, $NEWCLIENT_135x, PlayerInfo[pid][PlayerName], days);
		}

		Text_Send(@pVerified, $NEWSERVER_57x, GetPlayerClan(pid), days);
		SetClanTeam(GetPlayerClan(pid), VIP);

		SendDCByName(CHANNEL_PAYMENTS_NAME, "%s bought VIP Fortress for clan %s for %d days for %0.2f coin(s)", PlayerInfo[pid][PlayerName], GetPlayerClan(pid), days, multiplier);
	}

	inline ClanPtsVShop(pid, dialogid, response, listitem, string:inputtext[]) {
		#pragma unused dialogid, inputtext, listitem
		if (!response) return PC_EmulateCommand(pid, "/vshop");
		if (!IsNumeric(inputtext)) return Text_Send(pid, $NEWCLIENT_136);
		new pts = strval(inputtext);
		if (pts <= 0) return Text_Send(pid, $NEWCLIENT_137);
		if (pts > 1000000) return Text_Send(pid, $NEWCLIENT_138);
		if (!IsPlayerInAnyClan(pid)) return Text_Send(pid, $CLIENT_358x);
		if (GetPlayerClanRank(pid) < 10) return Text_Send(pid, $CLIENT_362x);
		new Float: multiplier;
		multiplier = 0.001 * pts;
		if (multiplier > PlayerInfo[pid][pCoins]) {
			Text_Send(pid, $NEWCLIENT_119x, multiplier - PlayerInfo[pid][pCoins]);
			return 1;
		}
		PlayerInfo[pid][pCoins] -= multiplier;
		PlayerInfo[pid][pCoinsSpent] += multiplier;
		PlayerInfo[pid][pPaymentsAccepted] ++;

		Text_Send(pid, $NEWCLIENT_139x, pts, multiplier);

		PlayerPlaySound(pid, 1057, 0.0, 0.0, 0.0);
		SetPlayerChatBubble(pid, "Bought Clan Points", X11_ORANGE, 300.0, 10000);
		Text_Send(pid, $NEWCLIENT_121x);

		new query[450];
		mysql_format(Database, query, sizeof query, 
			"INSERT INTO `payments` (`player`, `item`, `price`) VALUES ('%e', '%d Clan points', '%f')",
			PlayerInfo[pid][PlayerName], pts, multiplier);
		mysql_tquery(Database, query);	

		foreach(new i: Player) if (pClan[i] == pClan[pid]) {
			Text_Send(pid, $NEWCLIENT_140x, PlayerInfo[pid][PlayerName], pts);
		}

		AddClanXP(GetPlayerClan(pid), pts);

		SendDCByName(CHANNEL_PAYMENTS_NAME, "%s bought %d clan points for clan %s for %0.2f coin(s)", PlayerInfo[pid][PlayerName], pts, GetPlayerClan(pid), multiplier);
	}

	inline ClanItemsVShop(pid, dialogid, response, listitem, string:inputtext[]) {
		#pragma unused dialogid, inputtext
		if (!response) return PC_EmulateCommand(pid, "/vshop");
		switch (listitem) {
			case 0: Text_DialogBox(pid, DIALOG_STYLE_INPUT, using inline ClanBaseVShop, $VIPFORT_CAP, $VIPFORT_DESC, $DIALOG_PURCHASE, $DIALOG_CANCEL, PlayerInfo[pid][pCoins]);
			case 1: Text_DialogBox(pid, DIALOG_STYLE_INPUT, using inline ClanPtsVShop, $CLANPOINTS_CAP, $CLANPOINTS_DESC, $DIALOG_PURCHASE, $DIALOG_CANCEL, PlayerInfo[pid][pCoins]);
		}
	}

	inline VPacksVShop(pid, dialogid, response, listitem, string:inputtext[]) {
		#pragma unused dialogid, inputtext
		if (!response) return PC_EmulateCommand(pid, "/vshop");
		if (PlayerInfo[pid][pDonorLevel] > 4) return Text_Send(pid, $NEWCLIENT_131x);
		switch (listitem) {
			case 0: Text_DialogBox(pid, DIALOG_STYLE_INPUT, using inline PackVShop, $VPACK_VSHOP_CAP, $VPACK_VSHOP_DESC, $DIALOG_PURCHASE, $DIALOG_CANCEL, PlayerInfo[pid][pCoins]);
		}
	}

	inline VShop(pid, dialogid, response, listitem, string:inputtext[]) {
		#pragma unused dialogid, inputtext

		if (!response) return Text_Send(pid, $NEWCLIENT_141x);
		switch (listitem) {
			case 0: Dialog_ShowCallback(pid, using inline VPacksVShop, DIALOG_STYLE_LIST, ""RED2"SvT - VIP Upgrade", "Upgrade!", ">>", "X");
			case 1: Text_DialogBox(pid, DIALOG_STYLE_INPUT, using inline CashVShop, $CASH_VSHOP_CAP, $CASH_VSHOP_DESC, $DIALOG_PURCHASE, $DIALOG_CANCEL, PlayerInfo[pid][pCoins]);
			case 2: Text_DialogBox(pid, DIALOG_STYLE_INPUT, using inline ScoreVShop, $SCORE_VSHOP_CAP, $SCORE_VSHOP_DESC, $DIALOG_PURCHASE, $DIALOG_CANCEL, PlayerInfo[pid][pCoins]);
			case 3: Text_DialogBox(pid, DIALOG_STYLE_MSGBOX, using inline KDRVShop, $KDR_VSHOP_CAP, $KDR_VSHOP_DESC, $DIALOG_PURCHASE, $DIALOG_CANCEL, PlayerInfo[pid][pCoins]);
			case 4: {
				Dialog_ShowCallback(pid, using inline ClanItemsVShop, DIALOG_STYLE_LIST, ""RED2"SvT - Clan Shop",
					"Buy VIP Fortress\nClan Points", ">>", "X");
			}			
		}    
	}

	Dialog_ShowCallback(playerid, using inline VShop, DIALOG_STYLE_LIST, 
		""RED2"SvT - Shop",
		"VIP\n\
		Cash\n\
		Score\n\
		K/D Reset\n\
		Clan Related", ">>", "X");    
	return 1;
}

//End of File
/* (c) H2O Multiplayer 2018-2020. All rights reserved. */