/*
	SWAT vs Terrorists is a team death-match SA-MP game-mode script. 
	Compatible with SA-MP 0.3.7 and later releases.

	Author: H2O
	Licensed under GNU GPLv3

	(c) 2018-2020 H2O Multiplayer. All rights reserved.
	Website: h2omultiplayer.com

	Anything related to vehicles will be moved into this module,
	handling and processing vehicles and/or special vehicles is done here
*/

#include <YSI_Coding\y_hooks>

//Support for y_text, load language files...
#include <YSI_Players\y_text> //Y_Less
loadtext mode_text[all], mode_text[client], mode_text[newcs], mode_text[dialogs], mode_text[gametexts];

//---------------
//Rustler rockets

forward RegenerateRocket(rusid);
public RegenerateRocket(rusid) {
	new rockets[30];
	gRustlerRockets[rusid] ++;
	format(rockets, 30, "Rustler Bomber\n[%d/4]", gRustlerRockets[rusid]);
	UpdateDynamic3DTextLabelText(gRustlerLabel[rusid], X11_CADETBLUE, rockets);    
	return 1;
}

//Nevada rockets

forward RegenerateNevada(nevid);
public RegenerateNevada(nevid) {
	new rockets[30];
	gNevadaRockets[nevid] ++;
	format(rockets, 30, "Nevada Bomber\n[%d/4]", gNevadaRockets[nevid]);
	UpdateDynamic3DTextLabelText(gNevadaLabel[nevid], X11_CADETBLUE, rockets);    
	return 1;
}

//---------------

//Load the Submarines
LoadSubmarines() {
	new subs = 0;
	for (new i = 0; i < sizeof(SubInfo); i++) {
		SubInfo[i][Sub_Id] = CreateDynamicObject(9958, SubInfo[i][Sub_Pos][0], SubInfo[i][Sub_Pos][1], SubInfo[i][Sub_Pos][2], 0.0, 0.0, SubInfo[i][Sub_Pos][3]);
		SubInfo[i][Sub_Label] = Create3DTextLabel("USS Numnutz", X11_CADETBLUE, SubInfo[i][Sub_Pos][0], SubInfo[i][Sub_Pos][1], SubInfo[i][Sub_Pos][2], 50, 0);
		SubInfo[i][Sub_VID] = CreateVehicle(484, SubInfo[i][Sub_Pos][0], SubInfo[i][Sub_Pos][1], SubInfo[i][Sub_Pos][2], SubInfo[i][Sub_Pos][3], -1, -1, -1);
		AttachDynamicObjectToVehicle(SubInfo[i][Sub_Id], SubInfo[i][Sub_VID], 0.0, 0.0, 4.2, 0.0, 0.0, 180.0);
		LinkVehicleToInterior(SubInfo[i][Sub_VID], 169);
		Attach3DTextLabelToVehicle(SubInfo[i][Sub_Label], SubInfo[i][Sub_VID], 0.0, 0.0, 0.0);
		subs ++;
	}
	printf("Loaded %d submarines.", subs);
	return 1;
}

//Unload the Submarines
UnloadSubmarines() {
	for (new i = 0; i < sizeof(SubInfo); i++) {
		DestroyDynamicObject(SubInfo[i][Sub_Id]);
		Delete3DTextLabel(SubInfo[i][Sub_Label]);
		CarDeleter(SubInfo[i][Sub_VID]);
	}
	return 1;
}

//Load the AAC system
LoadAntiAir() {
	new aac = 0;
	for (new i = 0; i < sizeof(AACInfo); i++) {
		AACInfo[i][AAC_Id] = CreateVehicle(AACInfo[i][AAC_Model], AACInfo[i][AAC_Pos][0], AACInfo[i][AAC_Pos][1], AACInfo[i][AAC_Pos][2], AACInfo[i][AAC_Pos][3], 0, 0, 60);
		AACInfo[i][AAC_Text] = CreateDynamic3DTextLabel("Anti Aircraft\n[4/4]", X11_CADETBLUE, 0.0, 0.0, 0.0, 50.0, INVALID_PLAYER_ID, AACInfo[i][AAC_Id], 1);
		AACInfo[i][AAC_Rockets] = 4;
		AACInfo[i][AAC_Samsite] = CreateDynamicObject(3884, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
		switch (AACInfo[i][AAC_Model]) {
			case 422: AttachDynamicObjectToVehicle(AACInfo[i][AAC_Samsite], AACInfo[i][AAC_Id], 0.009999, -1.449998, -0.534999, 0.0, 0.0, 0.0);
			case 515: AttachDynamicObjectToVehicle(AACInfo[i][AAC_Samsite], AACInfo[i][AAC_Id], 0.000000, -3.520033, -1.179999, 0.000000, 0.000000, 0.000000);
		}
		AACInfo[i][AAC_Rockets] = 4;
		UpdateDynamic3DTextLabelText(AACInfo[i][AAC_Text], X11_CADETBLUE, "Anti Aircraft\n[4/4]");
		aac ++;
	}
	printf("Loaded %d anti air vehicles.", aac);
	return 1;
}

//Unload the AAC system
UnloadAntiAir() {
	for (new i = 0; i < sizeof(AACInfo); i++) {
		DestroyVehicle(AACInfo[i][AAC_Id]);
		if (IsValidDynamicObject(AACInfo[i][AAC_Samsite])) {
			DestroyDynamicObject(AACInfo[i][AAC_Samsite]);
		}
		DestroyDynamic3DTextLabel(AACInfo[i][AAC_Text]);
	}
	return 1;
}

//Recharge an AAC in case the player is in the recharge point

RechargeAAC(playerid) {
	for (new a = 0; a < sizeof(AACInfo); a++) {
		if (GetPlayerVehicleID(playerid) == AACInfo[a][AAC_Id]) {	       		
			if (AACInfo[a][AAC_Rockets] < 4) {
				if (AACInfo[a][AAC_Regen_Timer] < gettime()) {
					AACInfo[a][AAC_Rockets] ++;
					AACInfo[a][AAC_Regen_Timer] = gettime() + 10;

					Text_Send(playerid, $CLIENT_256x);

					new text[25];
					format(text, sizeof(text), "Anti Aircraft\n[%d/4]", AACInfo[a][AAC_Rockets]);
					UpdateDynamic3DTextLabelText(AACInfo[a][AAC_Text], X11_CADETBLUE, text);

					if (AACInfo[a][AAC_Rockets] == 4) {
						Text_Send(playerid, $CLIENT_257x);
					} else {
						if (AACInfo[a][AAC_Rockets] == 1) {
							Text_Send(playerid, $CLIENT_258x);
						}
					}		                          
				}
				break;
			}
		}
	}
	return 1;
}

//Check if the player entered an AAC

CheckAAC(playerid, vehicleid) {
	for (new a = 0; a < sizeof(AACInfo) - 1; a++) {
		if (vehicleid == AACInfo[a][AAC_Id]) {
			if (pClass[playerid] == SUPPORT && pAdvancedClass[playerid]) {
				if (AACInfo[a][AAC_Rockets] != 0) {
					ShowCarInfo(playerid, "Anti-Aircraft", "LMB to fire rockets", "Veteran Supporter");
				} else {
					Text_Send(playerid, $CLIENT_547y); 			
				}
			
				if (!IsValidDynamicObject(AACInfo[a][AAC_Samsite])) {	
					AACInfo[a][AAC_Samsite] = CreateDynamicObject(3884, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
					switch (AACInfo[a][AAC_Model]) {
						case 422: AttachDynamicObjectToVehicle(AACInfo[a][AAC_Samsite], AACInfo[a][AAC_Id], 0.009999, -1.449998, -0.534999, 0.0, 0.0, 0.0);
						case 515: AttachDynamicObjectToVehicle(AACInfo[a][AAC_Samsite], AACInfo[a][AAC_Id], 0.000000, -3.520033, -1.179999, 0.000000, 0.000000, 0.000000);
					}
				}
				AACInfo[a][AAC_Driver] = playerid;
			} else {
				ClearAnimations(playerid);
				Text_Send(playerid, $CLIENT_259x);
				ShowCarInfo(playerid, "Anti-Aircraft", "LMB to fire rockets", "Veteran Supporter");
			}
			break;
		}
	}	
	return 1;
}

//Check if a player is targeted by an AAC

CheckTarget(playerid) {
	for (new i = 0; i < sizeof(AACInfo); i++) {
		if (AACInfo[i][AAC_Target] == playerid) {
			if (PlayerInfo[playerid][AntiAirAlerts] < 3) {
				new Float: X, Float: Y, Float: Z;
				GetDynamicObjectPos(AACInfo[i][AAC_RocketId], X, Y, Z);
				new Float: dist = GetPlayerDistanceFromPoint(playerid, X, Y, Z);
				if (dist > 50.0 && dist < 101.0) {
					GetPlayerPos(playerid, X, Y, Z);
					SetDynamicObjectFaceCoords3D(AACInfo[i][AAC_RocketId], X, Y, Z, 0.0, 90.0, 90.0);
					MoveDynamicObject(AACInfo[i][AAC_RocketId], X, Y, Z, 80.0);
					Text_Send(playerid, $AAC_TARGETTED);
					PlayerPlaySound(AACInfo[i][AAC_Driver], 1056, 0.0, 0.0, 0.0);
					PlayerPlaySound(playerid, 6001, 0.0, 0.0, 0.0);
					KillTimer(pAACTargetTimer[playerid]);
					pAACTargetTimer[playerid] = SetTimerEx("StopAlarm", 6000, false, "d", playerid);
				}
				if (dist < 20.0) {
					if (AACInfo[i][AAC_Driver] == INVALID_PLAYER_ID) {
						DamagePlayer(playerid, 54.2, INVALID_PLAYER_ID, WEAPON_EXPLOSION, BODY_PART_UNKNOWN, true);
						DestroyDynamicObject(AACInfo[i][AAC_RocketId]);
						CreateExplosion(X, Y, Z, 7, 25.0);
						AACInfo[i][AAC_RocketId] = INVALID_OBJECT_ID;
						AACInfo[i][AAC_Target] = INVALID_PLAYER_ID;
					} else {
						Text_Send(AACInfo[i][AAC_Driver], $CLIENT_413x, PlayerInfo[playerid][PlayerName]);
						GivePlayerScore(AACInfo[i][AAC_Driver], 2);
						DamagePlayer(playerid, 54.2, AACInfo[i][AAC_Driver], WEAPON_EXPLOSION, BODY_PART_UNKNOWN, false);
						GetDynamicObjectPos(AACInfo[i][AAC_RocketId], X, Y, Z);
						DestroyDynamicObject(AACInfo[i][AAC_RocketId]);
						CreateExplosion(X, Y, Z, 7, 25.0);
						AACInfo[i][AAC_RocketId] = INVALID_OBJECT_ID;
						AACInfo[i][AAC_Target] = INVALID_PLAYER_ID;
					}
				}
				PlayerInfo[playerid][AntiAirAlerts] ++;
			} else {
				AACInfo[i][AAC_Target] = INVALID_PLAYER_ID;
				PlayerInfo[playerid][AntiAirAlerts] = 0;
				DestroyDynamicObject(AACInfo[i][AAC_RocketId]);
				AACInfo[i][AAC_RocketId] = INVALID_OBJECT_ID;
				if (AACInfo[i][AAC_Driver] != INVALID_PLAYER_ID) {
					Text_Send(AACInfo[i][AAC_Driver], $CLIENT_301x);
				}
			}
			break;
		}
	}
	return 1;	
}

//Hook some stuff here and there

hook OnGameModeInit() {
	LoadAntiAir(); //Load anti air vehicles
	LoadSubmarines(); //Load submarines

	//Setup special vehicles
	for (new i = 0; i < MAX_VEHICLES; i++) {
		if (GetVehicleModel(i) == 432) {
			SetVehicleHealth(i, 2500);
		}
		if (GetVehicleModel(i) == 553) {
			SetVehicleHealth(i, 2000);
		}
		if (GetVehicleModel(i) == 553) {
			gNevadaLabel[i] = CreateDynamic3DTextLabel("Nevada Bomber\n[4/4]", X11_CADETBLUE, 0.0, 0.0, 0.0, 50.0, INVALID_PLAYER_ID, i, 1, 0, 0);
			gNevadaRockets[i] = 4;
		}
		if (GetVehicleModel(i) == 476) {
			gRustlerLabel[i] = CreateDynamic3DTextLabel("Rustler Bomber\n[4/4]", X11_CADETBLUE, 0.0, 0.0, 0.0, 50.0, INVALID_PLAYER_ID, i, 1, 0, 0);
			gRustlerRockets[i] = 4;
			Rustler_Rockets[i][0] = CreateDynamicObject(3790, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
			AttachDynamicObjectToVehicle(Rustler_Rockets[i][0], i, 2.925019, 0.639999, -0.719999, 0.000000, 0.000000, -90.449951);
			Rustler_Rockets[i][1] = CreateDynamicObject(3790, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
			AttachDynamicObjectToVehicle(Rustler_Rockets[i][1], i, 3.455031, 0.639999, -0.719999, 0.000000, 0.000000, -90.449951); 
			Rustler_Rockets[i][2] = CreateDynamicObject(3790, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
			AttachDynamicObjectToVehicle(Rustler_Rockets[i][2], i, -2.925019, 0.639999, -0.719999, 0.000000, 0.000000, -90.449951);
			Rustler_Rockets[i][3] = CreateDynamicObject(3790, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
			AttachDynamicObjectToVehicle(Rustler_Rockets[i][3], i, -3.455031, 0.639999, -0.719999, 0.000000, 0.000000, -90.449951);
		}
		if (GetVehicleModel(i) == 512) {
			CropAnthrax[i][Anthrax_Label] = CreateDynamic3DTextLabel("Anthrax Cropduster\n[4/4]", X11_CADETBLUE, 0.0, 0.0, 0.0, 50.0, INVALID_PLAYER_ID, i, 1, 0, 0);
			CropAnthrax[i][Anthrax_Rockets] = 4;
			CropAnthrax[i][Anthrax_Cooldown] = gettime();
		}
	}

	//-----------
	//Missing vehicles
	CreateVehicle(512,-423.4167,2369.5242,117.9840,268.7932,-1,-1,60); // cropdust
	CreateVehicle(522,294.7434,1925.3944,17.3317,0.0131,1,1,60); // cropdust
	AddStaticVehicle(468,186.8209,1924.9069,17.3991,179.1586,0,7); // sanchez
	AddStaticVehicle(468,225.4988,1925.2216,17.3099,180.1413,0,7); // sanchez
	AddStaticVehicle(468,118.2941,1867.1399,17.4984,90.8638,0,7); // sanchez
	AddStaticVehicle(468,205.2829,1814.2047,17.3086,0.4219,0,7); // sanchez
	AddStaticVehicle(468,211.8439,1828.0620,17.3082,178.9877,0,7); // sanchez
	AddStaticVehicle(468,207.1815,1827.9609,17.3097,180.0193,0,7); // sanchez
	AddStaticVehicle(468,-347.9691,2241.4644,50.8868,90.0935,0,7); // sanchez
	AddStaticVehicle(468,-343.2443,2241.4644,50.8879,90.0939,0,7); // sanchez
	AddStaticVehicle(468,-352.9611,2171.9131,50.8888,90.1111,0,7); // sanchez
	AddStaticVehicle(468,-372.2235,2162.8369,50.8887,359.2683,0,7); // sanchez
	AddStaticVehicle(468,-372.3045,2156.5798,50.8873,359.2686,0,7); // sanchez
	AddStaticVehicle(468,-405.5382,2260.2175,50.8886,183.0837,0,7); // sanchez
	AddStaticVehicle(468,-424.3455,2216.2129,50.8850,272.8933,0,7); // sanchez
	AddStaticVehicle(468,-421.0903,2187.0112,50.8841,3.2436,0,7); // sanchez
	AddStaticVehicle(468,-426.0223,2186.9597,50.8835,5.2717,0,7); // sanchez
	AddStaticVehicle(468,-430.9844,2187.2500,50.8848,1.8567,0,7); // sanchez
	AddStaticVehicle(468,-436.7222,2187.5938,50.8843,3.8621,0,7); // sanchez
	AddStaticVehicle(468,204.0832,1814.1801,17.3095,0.7160,0,7); // sanchez
	AddStaticVehicle(468,-416.0666,2260.0112,50.8849,181.4206,0,7); // sanchez
	AddStaticVehicle(468,-424.1352,2243.0642,50.8845,269.0049,0,7); // sanchez
	AddStaticVehicle(468,-429.8277,2243.1624,50.8839,269.0054,0,7); // sanchez
	AddStaticVehicle(408,989.0023,2161.0969,11.3634,179.3760,0,7); // trash
	AddStaticVehicle(408,1012.5596,2128.6406,11.2865,359.2329,0,7); // trash
	AddStaticVehicle(468,23.1080,1164.3622,19.2579,179.1718,46,46); // sanchez
	AddStaticVehicle(468,5.8219,1164.0082,19.2933,1.5656,46,46); // sanchez
	AddStaticVehicle(468,-93.0153,1221.7064,19.4043,179.7446,46,46); // sanchez
	AddStaticVehicle(468,-90.5474,1221.6484,19.4110,181.3231,46,46); // sanchez
	AddStaticVehicle(468,-54.9967,1116.3679,19.4195,89.6050,46,46); // sanchez
	AddStaticVehicle(468,-81.0383,1215.6317,19.4104,180.2057,46,46); // sanchez
	AddStaticVehicle(468,4397.3291,4037.1035,9.2544,91.2431,0,7); // sanchez
	AddStaticVehicle(468,4037.9968,4030.1965,13.2345,88.6069,0,7); // sanchez
	AddStaticVehicle(495,3709.5229,4021.2410,10.5090,91.9164,0,7); // sand
	AddStaticVehicle(470,3609.2148,4020.4548,10.1490,321.0668,0,7); // pat
	AddStaticVehicle(470,3475.0210,3939.2754,9.4449,180.2452,0,7); // pat
	AddStaticVehicle(470,3474.4353,3879.1050,9.2411,178.9529,0,7); // pat
	AddStaticVehicle(470,3614.6873,3537.5864,5.6899,224.0729,0,7); // pat
	AddStaticVehicle(470,3634.4666,3518.7708,3.6438,244.4944,0,7); // pat
	AddStaticVehicle(495,3970.1978,3444.0615,13.7079,315.0380,0,7); // pub
	AddStaticVehicle(495,3991.2241,3451.5400,13.7583,345.1254,0,7); // pub
	AddStaticVehicle(400,3603.3804,3582.3340,7.4325,90.4678,0,7); // pubg
	AddStaticVehicle(493,3369.4302,3632.4724,-0.5201,181.2233,0,7); // boat
	///////////////////////////////////////////////////////////////////////
}

hook OnGameModeExit() {
	UnloadSubmarines();
	UnloadAntiAir();

	//Unload special vehicles' stuff
	for (new i = 0; i < MAX_VEHICLES; i++) { 
		if (IsValidDynamicObject(Rustler_Rockets[i][0])) DestroyDynamicObject(Rustler_Rockets[i][0]);
		if (IsValidDynamicObject(Rustler_Rockets[i][1])) DestroyDynamicObject(Rustler_Rockets[i][1]);
		if (IsValidDynamicObject(Rustler_Rockets[i][2])) DestroyDynamicObject(Rustler_Rockets[i][2]);
		if (IsValidDynamicObject(Rustler_Rockets[i][3])) DestroyDynamicObject(Rustler_Rockets[i][3]);
		DestroyDynamic3DTextLabel(gRustlerLabel[i]);
	}

	//Carepacks - a Nevada feature
	for (new i = 0; i < MAX_SLOTS; i++) {
		KillTimer(gCarepackTimer[i]);
		gCarepackPos[i][0] = gCarepackPos[i][1] = gCarepackPos[i][2] = 0.0;
		gCarepackExists[i] = 0;
		gCarepackUsable[i] = 0;
	}
}

hook OnPlayerEnterVehicle(playerid, vehicleid, ispassenger) {
	pVehId[playerid] = vehicleid;

	new string[128];
	format(string, sizeof(string), "Entered a/an ~g~%s", VehicleNames[GetVehicleModel(vehicleid)-400]);
	NotifyPlayer(playerid, string);

	new Float:X, Float:Y, Float:Z;
	GetPlayerPos(playerid, X, Y, Z);

	if (!PlayerInfo[playerid][pAdminDuty]) {
		for (new i = 0; i < sizeof(SubInfo); i++) {
			if (SubInfo[i][Sub_VID] == vehicleid) {
				ShowCarInfo(playerid, "Submarine", "Press Left Mouse Button to fire rockets.", "Scout Class");
				if (pClass[playerid] != SCOUT) return Text_Send(playerid, $SUBMARINE_LOCKED), RemovePlayerFromVehicle(playerid);
			}
		}
	}    
	return 1;
}

hook OnPlayerExitVehicle(playerid, vehicleid) {
	if (PlayerInfo[playerid][pDoorsLocked] == 1) {
		SetVehicleParamsForPlayer(GetPlayerVehicleID(playerid), playerid, false, false);
		PlayerInfo[playerid][pDoorsLocked] = 0;
	}

	LastVehicleID[playerid] = vehicleid;
	return 1;
}

hook OnVehicleMod(playerid, vehicleid, componentid) {
	new vehicleide = GetVehicleModel(vehicleid);
	new modok = islegalcarmod(vehicleide, componentid);
	if (!modok) {
		printf("%s[%d] is using illegal mods.", PlayerInfo[playerid][PlayerName], playerid);
		AntiCheatAlert(playerid, "Vehicle Mod Crasher");
		Kick(playerid);
		return 0;
	}
	return 1;
}

hook OnVehicleSpawn(vehicleid) {
	LinkVehicleToInterior(vehicleid, 0);
	SetVehicleVirtualWorld(vehicleid, 0);

	if (GetVehicleModel(vehicleid) == 432) {
		SetVehicleHealth(vehicleid, 2500);
	}
	
	if (GetVehicleModel(vehicleid) == 553) {
		SetVehicleHealth(vehicleid, 2000);
	}

	foreach(new i: Player) {
		if (gOldVID[i] == vehicleid) {
			gOldVID[i] = -1;
		}
	}

	for (new i = 0; i < sizeof(SubInfo); i++) {
		if (SubInfo[i][Sub_VID] == vehicleid) {
			AttachDynamicObjectToVehicle(SubInfo[i][Sub_Id], SubInfo[i][Sub_VID], 0.0, 0.0, 4.2, 0.0, 0.0, 180.0);
			LinkVehicleToInterior(SubInfo[i][Sub_VID], 169);
			Attach3DTextLabelToVehicle(SubInfo[i][Sub_Label], SubInfo[i][Sub_VID], 0.0, 0.0, 0.0);
			break;
		}
	}
	
	if (GetVehicleModel(vehicleid) == 553) {
		UpdateDynamic3DTextLabelText(gNevadaLabel[vehicleid], X11_CADETBLUE, "Nevada Bomber\n[4/4]");
		gNevadaRockets[vehicleid] = 4;
	}

	if (GetVehicleModel(vehicleid) == 476) {
		AttachDynamicObjectToVehicle(Rustler_Rockets[vehicleid][0], vehicleid, 2.925019, 0.639999, -0.719999, 0.000000, 0.000000, -90.449951);
		AttachDynamicObjectToVehicle(Rustler_Rockets[vehicleid][1], vehicleid, 3.605034, 0.639999, -0.719999, 0.000000, 0.000000, -90.449951); 
		AttachDynamicObjectToVehicle(Rustler_Rockets[vehicleid][2], vehicleid, -2.925019, 0.639999, -0.719999, 0.000000, 0.000000, -90.449951);
		AttachDynamicObjectToVehicle(Rustler_Rockets[vehicleid][3], vehicleid, -3.605034, 0.639999, -0.719999, 0.000000, 0.000000, -90.449951);
		UpdateDynamic3DTextLabelText(gRustlerLabel[vehicleid], X11_CADETBLUE, "Rustler Bomber\n[4/4]");
		gRustlerRockets[vehicleid] = 4;
	}
	
	if (GetVehicleModel(vehicleid) == 512) {
		UpdateDynamic3DTextLabelText(CropAnthrax[vehicleid][Anthrax_Label], X11_CADETBLUE, "Anthrax Cropduster\n[4/4]");
		CropAnthrax[vehicleid][Anthrax_Rockets] = 4;
		CropAnthrax[vehicleid][Anthrax_Cooldown] = gettime();
	}

	for (new a = 0; a < sizeof(AACInfo); a++) {
		if (AACInfo[a][AAC_Id] == vehicleid) {
			switch (AACInfo[a][AAC_Model]) {
				case 422: AttachDynamicObjectToVehicle(AACInfo[a][AAC_Samsite], AACInfo[a][AAC_Id], 0.009999, -1.449998, -0.534999, 0.0, 0.0, 0.0);
				case 515: AttachDynamicObjectToVehicle(AACInfo[a][AAC_Samsite], AACInfo[a][AAC_Id], 0.000000, -3.520033, -1.179999, 0.000000, 0.000000, 0.000000);
			}
			AACInfo[a][AAC_Rockets] = 4;
			UpdateDynamic3DTextLabelText(AACInfo[a][AAC_Text], X11_CADETBLUE, "Anti Aircraft\n[4/4]");

			break;
		}
	}

	foreach (new i: Player) {
		for (new x = 0; x < sizeof(PrototypeInfo); x++)
		{
			if (vehicleid == PrototypeInfo[x][Prototype_Id]) {
				SetVehicleHealth(vehicleid, 1500.0);
				break;
			}
		}
	}
	return 1;
}

hook OnVehicleStreamIn(vehicleid, forplayerid) {
	return 1;
}

hook OnVehicleStreamOut(vehicleid, forplayerid) {    
	return 1;
}

hook OnVehicleDeath(vehicleid, killerid) {
	if (PlayerInfo[killerid][pDeathmatchId] > -1) {
		foreach(new i: Player) {
			if (pVehId[i] == vehicleid && killerid != i) {
				DamagePlayer(i, 0.0, killerid, WEAPON_EXPLOSION, BODY_PART_UNKNOWN, true);
			}
		}
	}    
	return 1;
}

hook OnVehDamageStatusUpdate(vehicleid, playerid) {
	new Float: VHP;
	GetVehicleHealth(vehicleid, VHP);
	if (VHP <= 300.0) {
		if (GetPlayerScore(playerid) <= 300) {
			if ((IsPlayerInAnyVehicle(playerid) && VHP <= 350.0) || GetVehicleModel(GetPlayerVehicleID(playerid)) == 464) {
				new Float: X, Float: Y, Float: Z;
				GetPlayerPos(playerid, X, Y, Z);
				SetPlayerPos(playerid, X, Y, Z + 200);
				PC_EmulateCommand(playerid, "/ep");
				NotifyPlayer(playerid, "Automatic eject will not work when you reach 300 Score.");
			}
		}
	}    
	return 1;
}

hook OnPlayerDisconnect(playerid, reason) {
	//AAC
	for (new i = 0; i < sizeof(AACInfo) - 1; i++) {
		if (LastVehicleID[playerid] == AACInfo[i][AAC_Driver]) {
			AACInfo[i][AAC_Driver] = INVALID_PLAYER_ID;
		}
		if (AACInfo[i][AAC_Target] == playerid) {
			AACInfo[i][AAC_Target] = INVALID_PLAYER_ID;
			if (IsValidDynamicObject(AACInfo[i][AAC_RocketId])) {
				DestroyDynamicObject(AACInfo[i][AAC_RocketId]);
				AACInfo[i][AAC_RocketId] = INVALID_OBJECT_ID;
			}
		}
	}
	KillTimer(pAACTargetTimer[playerid]);

	//Reset car values
	if (PlayerInfo[playerid][pCar] != -1) DestroyVehicle(PlayerInfo[playerid][pCar]);
	PlayerInfo[playerid][pCar] = -1;
	LastVehicleID[playerid] = INVALID_VEHICLE_ID;
}

hook OnPlayerDeath(playerid) {
	//AAC
	for (new i = 0; i < sizeof(AACInfo); i++) {
		if (AACInfo[i][AAC_Target] == playerid) {
			AACInfo[i][AAC_Target] = INVALID_PLAYER_ID;
		}
	}
}

hook OnPlayerStateChange(playerid, newstate, oldstate) {
	//AAC
	if (oldstate == PLAYER_STATE_DRIVER) {
		for (new a = 0; a < sizeof(AACInfo) - 1; a++) {
			if (playerid == AACInfo[a][AAC_Driver]
					&& !IsPlayerInVehicle(playerid, AACInfo[a][AAC_Id])) {
				AACInfo[a][AAC_Driver] = INVALID_PLAYER_ID;
			}
		}
	}
	if (newstate == PLAYER_STATE_DRIVER) {
		LastVehicleID[playerid] = GetPlayerVehicleID(playerid);
		CheckAAC(playerid, GetPlayerVehicleID(playerid));
		SetPlayerArmedWeapon(playerid, 0);
	}

	//General

	if (GetPlayerState(playerid) == PLAYER_STATE_PASSENGER) {
		if (!IsVehicleUsed(GetPlayerVehicleID(playerid))) {
			RemovePlayerFromVehicle(playerid);
		}
	}

	if (newstate == PLAYER_STATE_PASSENGER) {
		new vehicle_drivers = 0;
		foreach (new i: Player) {
			if (GetPlayerVehicleID(i) == GetPlayerVehicleID(playerid)
				&& GetPlayerState(i) == PLAYER_STATE_DRIVER) {
				vehicle_drivers ++;
			}
		}
		if (!vehicle_drivers) {
			Text_Send(playerid, $CLIENT_283x);
			PutPlayerInVehicle(playerid, GetPlayerVehicleID(playerid), 0);
		}
	}

	if (oldstate == PLAYER_STATE_DRIVER) {
		foreach (new i: Player) {
			if (GetPlayerVehicleID(i) == GetPlayerVehicleID(playerid)
				&& GetPlayerState(i) == PLAYER_STATE_PASSENGER) {
				PutPlayerInVehicle(i, GetPlayerVehicleID(i), 0);
				Text_Send(playerid, $CLIENT_284x);
				break;
			}
		}
	}
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
	//Submarine Integration
	if (PRESSED(KEY_SECONDARY_ATTACK)) {
		for (new i = 0; i < sizeof(SubInfo); i++) {
			new Float:X, Float:Y, Float:Z;
			GetVehiclePos(SubInfo[i][Sub_VID], X, Y, Z);
			if (IsPlayerInRangeOfPoint(playerid, 7.0, X, Y, Z) && !IsPlayerInAnyVehicle(playerid)) {
				PutPlayerInVehicle(playerid, SubInfo[i][Sub_VID], 0);
				break;
			}
		}
	}

	if (PRESSED(KEY_FIRE)) {
		if (IsPlayerInAnyVehicle(playerid)) {
			//Submarines Integration
			if (GetVehicleModel(GetPlayerVehicleID(playerid)) == 484) {
				for (new i = 0; i < sizeof(SubInfo); i++) {
					if (GetPlayerVehicleID(playerid) == SubInfo[i][Sub_VID]) {

						if (PlayerInfo[playerid][pLimit] > gettime()) {
							Text_Send(playerid, $CLIENT_411x, PlayerInfo[playerid][pLimit] - gettime());
							return 1;
						}
						
						new Float: X, Float: Y, Float: Z;
						GetVehiclePos(SubInfo[i][Sub_VID], X, Y, Z);

						new Float: FA;
						GetVehicleZAngle(SubInfo[i][Sub_VID], FA);

						for (new x = 0; x < 5; x++) {
							if (IsValidDynamicObject(PlayerInfo[playerid][pBombIds][x])) {
								DestroyDynamicObject(PlayerInfo[playerid][pBombIds][x]);
							}
							PlayerInfo[playerid][pBombIds][x] = INVALID_OBJECT_ID;
						}

						PlayerInfo[playerid][pBombIds][0] = CreateDynamicObject(1636, X, Y, Z, 0.0, 10.0, FA - 90.0);
						PlayerInfo[playerid][pBombIds][1] = CreateDynamicObject(1636, X, Y, Z, 0.0, 11.0, FA - 90.0);
						PlayerInfo[playerid][pBombIds][2] = CreateDynamicObject(1636, X, Y, Z, 0.0, 12.0, FA - 90.0);
						PlayerInfo[playerid][pBombIds][3] = CreateDynamicObject(1636, X, Y, Z, 0.0, 13.0, FA - 90.0);
						PlayerInfo[playerid][pBombIds][4] = CreateDynamicObject(1636, X, Y, Z, 0.0, 14.0, FA - 90.0);

						new Float: Front_X, Float: Front_Y;

						GetXYZInfrontOfCar(SubInfo[i][Sub_VID], Front_X, Front_Y, 50.0);
						MoveDynamicObject(PlayerInfo[playerid][pBombIds][0], Front_X, Front_Y, Z, 100.0);

						GetXYZInfrontOfCar(SubInfo[i][Sub_VID], Front_X, Front_Y, 75.0);
						MoveDynamicObject(PlayerInfo[playerid][pBombIds][1], Front_X, Front_Y, Z, 100.0);

						GetXYZInfrontOfCar(SubInfo[i][Sub_VID], Front_X, Front_Y, 100.0);
						MoveDynamicObject(PlayerInfo[playerid][pBombIds][2], Front_X, Front_Y, Z, 100.0);

						GetXYZInfrontOfCar(SubInfo[i][Sub_VID], Front_X, Front_Y, 150.0);
						MoveDynamicObject(PlayerInfo[playerid][pBombIds][3], Front_X, Front_Y, Z, 100.0);

						GetXYZInfrontOfCar(SubInfo[i][Sub_VID], Front_X, Front_Y, 200.0);
						MoveDynamicObject(PlayerInfo[playerid][pBombIds][4], Front_X, Front_Y, Z, 100.0);

						PlayerInfo[playerid][pLimit] = gettime() + 20;

						break;
					}
				}
			}

			//AAC Integration
			if (GetVehicleModel(GetPlayerVehicleID(playerid)) == 515 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 422) {
				for (new a = 0; a < sizeof(AACInfo); a++) {
					if (GetPlayerVehicleID(playerid) == AACInfo[a][AAC_Id]) {

						if (PlayerInfo[playerid][pLimit] > gettime()) {
							Text_Send(playerid, $CLIENT_411x, PlayerInfo[playerid][pLimit] - gettime());
							return 1;
						}

						if (AACInfo[a][AAC_Rockets] == 0) {
							Text_Send(playerid, $CLIENT_286x);
							return 1;
						}

						if (IsValidDynamicObject(AACInfo[a][AAC_RocketId])) {	
							return Text_Send(playerid, $CLIENT_287x);
						}

						switch (AACInfo[a][AAC_Model]) {
							case 422: AttachDynamicObjectToVehicle(AACInfo[a][AAC_Samsite], AACInfo[a][AAC_Id], 0.009999, -1.449998, -0.534999, 0.0, 0.0, 0.0);
							case 515: AttachDynamicObjectToVehicle(AACInfo[a][AAC_Samsite], AACInfo[a][AAC_Id], 0.000000, -3.520033, -1.179999, 0.000000, 0.000000, 0.000000);
						}	

						new Float: X, Float: Y, Float: Z;
						GetVehiclePos(AACInfo[a][AAC_Id], X, Y, Z);

						PlayerInfo[playerid][pLimit] = gettime() + 35;
						
						if (PlayerInfo[playerid][pDonorLevel] < 4) {
							AACInfo[a][AAC_Rockets] --;
						}				    	               	

						AACInfo[a][AAC_RocketId] = CreateDynamicObject(3790, X, Y, (Z + 4.0), 0.0, 0.0, 0.0);

						new Float: Front_X, Float: Front_Y;
						GetXYZInfrontOfAAC(a, Front_X, Front_Y, 120.0);
						
						AACInfo[a][AAC_Target] = INVALID_PLAYER_ID;
						
						foreach (new i: Player) {
							if (IsPlayerInRangeOfPoint(i, 150.0, X, Y, Z) && pTeam[i] != pTeam[playerid]
								&& IsPlayerInAnyVehicle(i) && !GetPlayerInterior(i) && !GetPlayerVirtualWorld(i)) {
								switch (GetVehicleModel(GetPlayerVehicleID(i))) {
									case 417, 425, 447, 460, 469, 476, 487, 488, 497, 511, 512, 513, 519,
									520, 548, 553, 563, 577, 592, 593: { // Airplanes and helicopters
										new Float: pX, Float: pY, Float: pZ;
										GetPlayerPos(i, pX, pY, pZ);

										AACInfo[a][AAC_Target] = i;
										SetDynamicObjectFaceCoords3D(AACInfo[a][AAC_RocketId], pX, pY, pZ, 0.0, 90.0, 90.0);
										MoveDynamicObject(AACInfo[a][AAC_RocketId], pX, pY, pZ, 100.0);
										PlayerPlaySound(i, 1159, 0.0, 0.0, 0.0);
									}
								}		
								break;
							}
						}
						
						if (AACInfo[a][AAC_Target] == INVALID_PLAYER_ID) {
							SetDynamicObjectFaceCoords3D(AACInfo[a][AAC_RocketId], Front_X, Front_Y, Z, 0.0, 90.0, 90.0);
							MoveDynamicObject(AACInfo[a][AAC_RocketId], Front_X, Front_Y, Z, 100.0);
						}
						
						PlayerPlaySound(playerid, 1159, 0.0, 0.0, 0.0);
						PlayerInfo[playerid][pAntiAirRocketsFired] ++;

						new text[25];
						format(text, sizeof(text), "Anti Aircraft\n[%d/4]", AACInfo[a][AAC_Rockets]);
						UpdateDynamic3DTextLabelText(AACInfo[a][AAC_Text], X11_CADETBLUE, text);

						break;                  	  	    	        		
					}
				}
			}

			//Nevada Integration
			if (GetVehicleModel(GetPlayerVehicleID(playerid)) == 553) {
				if (gNevadaRockets[GetPlayerVehicleID(playerid)] <= 0) return Text_Send(playerid, $CLIENT_289x);

				if (PlayerInfo[playerid][pLimit2] > gettime()) {
					Text_Send(playerid, $CLIENT_411x, PlayerInfo[playerid][pLimit2] - gettime());
					return 1;

				}

				PlayerInfo[playerid][pLimit2] = gettime() + 45;
				for (new i = 0; i < 5; i++) {
					if (IsValidDynamicObject(PlayerInfo[playerid][pBombIds][i])) {
						DestroyDynamicObject(PlayerInfo[playerid][pBombIds][i]);
					}
					PlayerInfo[playerid][pBombIds][i] = INVALID_OBJECT_ID;
				}

				gNevadaRockets[GetPlayerVehicleID(playerid)] --;

				new rockets[30];
				format(rockets, 30, "Nevada Bomber\n[%d/4]", gNevadaRockets[GetPlayerVehicleID(playerid)]);
				UpdateDynamic3DTextLabelText(gNevadaLabel[GetPlayerVehicleID(playerid)], X11_CADETBLUE, rockets);

				new Float: Coords[3];
				GetPlayerPos(playerid, Coords[0], Coords[1], Coords[2]);
				PlayerInfo[playerid][pBombIds][0] = CreateDynamicObject(3790, Coords[0], Coords[1], Coords[2] - 5.0, 0.0, -90.0, 0.0);
				PlayerInfo[playerid][pBombIds][1] = CreateDynamicObject(3790, Coords[0], Coords[1], Coords[2] - 5.0, 0.0, -90.0, 0.0);
				PlayerInfo[playerid][pBombIds][2] = CreateDynamicObject(3790, Coords[0], Coords[1], Coords[2] - 5.0, 0.0, -90.0, 0.0);
				PlayerInfo[playerid][pBombIds][3] = CreateDynamicObject(3790, Coords[0], Coords[1], Coords[2] - 5.0, 0.0, -90.0, 0.0);
				PlayerInfo[playerid][pBombIds][4] = CreateDynamicObject(3790, Coords[0], Coords[1], Coords[2] - 5.0, 0.0, -90.0, 0.0);

				CA_FindZ_For2DCoord(Coords[0], Coords[1], Coords[2]);
				MoveDynamicObject(PlayerInfo[playerid][pBombIds][0], Coords[0] + 8, Coords[1] + 8, Coords[2] - 2.0, 45.0);		                     	
				MoveDynamicObject(PlayerInfo[playerid][pBombIds][1], Coords[0] + 10, Coords[1] + 10, Coords[2] - 1.0, 45.0);		                     	
				MoveDynamicObject(PlayerInfo[playerid][pBombIds][2], Coords[0] + 12, Coords[1] + 12, Coords[2] - 2.0, 45.0);		                     	
				MoveDynamicObject(PlayerInfo[playerid][pBombIds][3], Coords[0] + 14, Coords[1] + 14, Coords[2] - 3.0, 45.0);
				MoveDynamicObject(PlayerInfo[playerid][pBombIds][4], Coords[0] + 16, Coords[1] + 16, Coords[2] - 4.0, 45.0);
				SetTimerEx("RegenerateNevada", 19000 * 5, false, "i", GetPlayerVehicleID(playerid));
			}
			
			//Rustler Integration
			if (GetVehicleModel(GetPlayerVehicleID(playerid)) == 476) {
				if (PlayerInfo[playerid][pLimit2] <= gettime()) {
					if (gRustlerRockets[GetPlayerVehicleID(playerid)] <= 0) return Text_Send(playerid, $CLIENT_290x);
					new Float: X, Float: Y, Float: Z, Float: RZ, inbase = 0;

					GetPlayerPos(playerid, X, Y, Z);
					CA_FindZ_For2DCoord(X, Y, RZ);

					for (new i = 0; i < sizeof(TeamInfo); i++) {
						if (IsPlayerInArea(playerid, TeamInfo[i][Team_MapArea][0],
						TeamInfo[i][Team_MapArea][1],
						TeamInfo[i][Team_MapArea][2],
						TeamInfo[i][Team_MapArea][3]) && 
							pTeam[playerid] != i) {
							inbase = 1;
							break;
						}
					}
					if (inbase) return Text_Send(playerid, $CLIENT_292x);
					if ((Z - RZ) >= 15.0)
					{
						gRustlerRockets[GetPlayerVehicleID(playerid)] --;
						PlayerInfo[playerid][pRustlerRocketsFired] ++;

						new rockets[30];
						format(rockets, 30, "Rustler Bomber\n[%d/4]", gRustlerRockets[GetPlayerVehicleID(playerid)]);
						UpdateDynamic3DTextLabelText(gRustlerLabel[GetPlayerVehicleID(playerid)], X11_CADETBLUE, rockets);

						if (PlayerInfo[playerid][pDonorLevel] < 5) {
							PlayerInfo[playerid][pLimit2] = gettime() + 12;
						} else {
							PlayerInfo[playerid][pLimit2] = gettime() + 6;
						}
						if (IsValidDynamicObject(PlayerInfo[playerid][pBombId])) {	
							DestroyDynamicObject(PlayerInfo[playerid][pBombId]);
						}
						PlayerInfo[playerid][pBombId] = INVALID_OBJECT_ID;

						new Float: Coords[3];
						GetPlayerPos(playerid, Coords[0], Coords[1], Coords[2]);
						PlayerInfo[playerid][pBombId] = CreateDynamicObject(3790, Coords[0], Coords[1], Coords[2] - 5.0, 0.0, -90.0, 0.0);

						CA_FindZ_For2DCoord(Coords[0], Coords[1], Coords[2]);
						MoveDynamicObject(PlayerInfo[playerid][pBombId], Coords[0], Coords[1], Coords[2] - 2.0, 45.0);
						PlayerInfo[playerid][pAirRocketsFired] ++;  
						SetTimerEx("RegenerateRocket", 7000 * 5, false, "i", GetPlayerVehicleID(playerid));
					}  else Text_Send(playerid, $CLIENT_293x);
				} else {
					Text_Send(playerid, $CLIENT_411x, PlayerInfo[playerid][pLimit2] - gettime());
				}
			}
			//Anthrax Plane Integration
			if (GetVehicleModel(GetPlayerVehicleID(playerid)) == 512) {
				if (PlayerInfo[playerid][pLimit2] <= gettime()) {
					if (CropAnthrax[GetPlayerVehicleID(playerid)][Anthrax_Rockets] <= 0) return Text_Send(playerid, $CLIENT_294x);
					if (pTeam[playerid] != gAnthraxOwner) return Text_Send(playerid, $CLIENT_295x);
					new Float: X, Float: Y, Float: Z, Float: RZ, inbase = 0;

					GetPlayerPos(playerid, X, Y, Z);
					CA_FindZ_For2DCoord(X, Y, RZ);

					for (new i = 0; i < sizeof(TeamInfo); i++) {
						if (IsPlayerInArea(playerid, TeamInfo[i][Team_MapArea][0],
						TeamInfo[i][Team_MapArea][1],
						TeamInfo[i][Team_MapArea][2],
						TeamInfo[i][Team_MapArea][3]) &&
							pTeam[playerid] != i) {
							inbase = 1;
							break;
						}
					}
					if (inbase) return Text_Send(playerid, $CLIENT_297x);
					if ((Z - RZ) >= 15.0)
					{
						CropAnthrax[GetPlayerVehicleID(playerid)][Anthrax_Rockets] --;

						new rockets[30];
						format(rockets, 30, "Anthrax Cropduster\n[%d/4]", CropAnthrax[GetPlayerVehicleID(playerid)][Anthrax_Rockets]);
						UpdateDynamic3DTextLabelText(CropAnthrax[GetPlayerVehicleID(playerid)][Anthrax_Label], X11_CADETBLUE, rockets);

						PlayerInfo[playerid][pLimit2] = gettime() + 20;
						if (IsValidDynamicObject(PlayerInfo[playerid][pAnthrax])) {
							DestroyDynamicObject(PlayerInfo[playerid][pAnthrax]);
						}
						PlayerInfo[playerid][pAnthrax] = INVALID_OBJECT_ID;

						new Float: Coords[3];
						GetPlayerPos(playerid, Coords[0], Coords[1], Coords[2]);
						PlayerInfo[playerid][pAnthrax] = CreateDynamicObject(1636, Coords[0], Coords[1], Coords[2] - 5.0, 0.0, 0.0, 0.0);

						CA_FindZ_For2DCoord(Coords[0], Coords[1], Coords[2]);
						MoveDynamicObject(PlayerInfo[playerid][pAnthrax], Coords[0], Coords[1], Coords[2] - 2.0, 45.0);
						PlayerInfo[playerid][pAirRocketsFired] ++;
						SetTimerEx("RegenerateToxic", 20000 * 5, false, "i", GetPlayerVehicleID(playerid));
					}  else Text_Send(playerid, $CLIENT_298x);
				} else {
					Text_Send(playerid, $CLIENT_411x, PlayerInfo[playerid][pLimit2] - gettime());
				}
			}
		}
	}
	return 1;
}

hook OnDynObjectMoved(objectid) {
	//Related to AAC
	for (new i = 0; i < sizeof(AACInfo); i++) {
		if (AACInfo[i][AAC_RocketId] == objectid) {
			if (AACInfo[i][AAC_Target] == INVALID_PLAYER_ID) {
				new Float: X, Float: Y, Float: Z;
				GetDynamicObjectPos(AACInfo[i][AAC_RocketId], X, Y, Z);
				CreateExplosion(X, Y, Z, 7, 25.0);
				DestroyDynamicObject(AACInfo[i][AAC_RocketId]);
				AACInfo[i][AAC_RocketId] = INVALID_OBJECT_ID;
			}
		}
	}
	//Bombs for Rustler and Nevada
	foreach (new i: Player) {
		if (PlayerInfo[i][pBombId] == objectid) {
			new Float: X, Float: Y, Float: Z;

			GetDynamicObjectPos(PlayerInfo[i][pBombId], X, Y, Z);
			Z += 2.0;

			new Float: range = frandom(10.0, 7.5);
			if (PlayerInfo[i][pDonorLevel] >= 5) {
				range = 12.0;
			}

			foreach (new x: Player) {
				if (pTeam[x] != pTeam[i] 
					&& IsPlayerInRangeOfPoint(x, range, X, Y, Z) && x != i) {
					Text_Send(i, $CLIENT_414x, PlayerInfo[x][PlayerName]);
					GivePlayerScore(i, 1);
					DamagePlayer(x, 0.0, i, WEAPON_EXPLOSION, BODY_PART_UNKNOWN, false);

					PlayerInfo[i][pRustlerRocketsHit] ++;
				}
			}

			CreateExplosion(X, Y, Z, 7, 7.5);
			DestroyDynamicObject(PlayerInfo[i][pBombId]);
			PlayerInfo[i][pBombId] = INVALID_OBJECT_ID;
			break;
		}

		if (PlayerInfo[i][pBombIds][0] == objectid) {
			new Float: gPos[3];

			GetDynamicObjectPos(PlayerInfo[i][pBombIds][0], gPos[0], gPos[1], gPos[2]);
			DestroyDynamicObject(PlayerInfo[i][pBombIds][0]);
			PlayerInfo[i][pBombIds][0] = INVALID_OBJECT_ID;
			
			foreach (new x: Player) {
				if (pTeam[x] != pTeam[i] && IsPlayerInRangeOfPoint(x, 10.0, gPos[0], gPos[1], gPos[2]) && x != i
						&& !IsPlayerDying(x)) {
					Text_Send(i, $CLIENT_414x, PlayerInfo[x][PlayerName], x);
					GivePlayerScore(i, 1);

					DamagePlayer(x, 0.0, i, WEAPON_EXPLOSION, BODY_PART_UNKNOWN, false);
				}
			}

			CreateExplosion(gPos[0], gPos[1], gPos[2], 7, 5.0);
			break;  	
		}

		if (PlayerInfo[i][pBombIds][1] == objectid) {
			new Float: gPos[3];

			GetDynamicObjectPos(PlayerInfo[i][pBombIds][1], gPos[0], gPos[1], gPos[2]);
			DestroyDynamicObject(PlayerInfo[i][pBombIds][1]);
			PlayerInfo[i][pBombIds][1] = INVALID_OBJECT_ID;

			foreach (new x: Player) {
				if (pTeam[x] != pTeam[i] && IsPlayerInRangeOfPoint(x, 10.0, gPos[0], gPos[1], gPos[2]) && x != i
						&& !IsPlayerDying(x)) {
					Text_Send(i, $CLIENT_414x, PlayerInfo[x][PlayerName], x);
					GivePlayerScore(i, 1);

					DamagePlayer(x, 0.0, i, WEAPON_EXPLOSION, BODY_PART_UNKNOWN, false);
				}
			}
			
			CreateExplosion(gPos[0], gPos[1], gPos[2], 7, 5.0);
			break;  	
		}

		if (PlayerInfo[i][pBombIds][2] == objectid) {
			new Float: gPos[3];

			GetDynamicObjectPos(PlayerInfo[i][pBombIds][2], gPos[0], gPos[1], gPos[2]);
			DestroyDynamicObject(PlayerInfo[i][pBombIds][2]);
			PlayerInfo[i][pBombIds][2] = INVALID_OBJECT_ID;
			
			foreach (new x: Player) {
				if (pTeam[x] != pTeam[i] && IsPlayerInRangeOfPoint(x, 10.0, gPos[0], gPos[1], gPos[2]) && x != i
						&& !IsPlayerDying(x)) {
					Text_Send(i, $CLIENT_414x, PlayerInfo[x][PlayerName], x);
					GivePlayerScore(i, 1);

					DamagePlayer(x, 0.0, i, WEAPON_EXPLOSION, BODY_PART_UNKNOWN, false);
				}
			}

			CreateExplosion(gPos[0], gPos[1], gPos[2], 7, 5.0);
			break;  	
		}

		if (PlayerInfo[i][pBombIds][3] == objectid) {
			new Float: gPos[3];

			GetDynamicObjectPos(PlayerInfo[i][pBombIds][3], gPos[0], gPos[1], gPos[2]);
			DestroyDynamicObject(PlayerInfo[i][pBombIds][3]);
			PlayerInfo[i][pBombIds][3] = INVALID_OBJECT_ID;

			foreach (new x: Player) {
				if (pTeam[x] != pTeam[i] && IsPlayerInRangeOfPoint(x, 10.0, gPos[0], gPos[1], gPos[2]) && x != i
						&& !IsPlayerDying(x)) {
					Text_Send(i, $CLIENT_414x, PlayerInfo[x][PlayerName], x);
					GivePlayerScore(i, 1);

					DamagePlayer(x, 0.0, i, WEAPON_EXPLOSION, BODY_PART_UNKNOWN, false);
				}
			}

			CreateExplosion(gPos[0], gPos[1], gPos[2], 7, 5.0);
			break;  	
		}	   

		if (PlayerInfo[i][pBombIds][4] == objectid) {
			new Float: gPos[3];

			GetDynamicObjectPos(PlayerInfo[i][pBombIds][4], gPos[0], gPos[1], gPos[2]);
			DestroyDynamicObject(PlayerInfo[i][pBombIds][4]);
			PlayerInfo[i][pBombIds][4] = INVALID_OBJECT_ID;
			
			foreach (new x: Player) {
				if (pTeam[x] != pTeam[i] && IsPlayerInRangeOfPoint(x, 10.0, gPos[0], gPos[1], gPos[2]) && x != i
						&& !IsPlayerDying(x)) {
					Text_Send(i, $CLIENT_414x, PlayerInfo[x][PlayerName], x);
					GivePlayerScore(i, 1);

					DamagePlayer(x, 0.0, i, WEAPON_EXPLOSION, BODY_PART_UNKNOWN, false);
				}
			}

			CreateExplosion(gPos[0], gPos[1], gPos[2], 7, 5.0);
			break;  	
		}	    
	}
}

//End of File
/* (c) H2O Multiplayer 2018-2020. All rights reserved. */