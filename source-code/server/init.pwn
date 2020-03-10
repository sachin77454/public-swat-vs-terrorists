/*
	SWAT vs Terrorists is a team death-match SA-MP game-mode script.
	Compatible with SA-MP 0.3.7 and later releases.

	Author: H2O
	Licensed under GNU GPLv3

	(c) 2018-2020 H2O Multiplayer. All rights reserved.
	Website: h2omultiplayer.com

	Gamemode Init
*/

#include <YSI\y_hooks>

//Initialize Game

hook OnGameModeInit() {
	//Conifg
	svtconf[max_admin_level] = 8,
	svtconf[kick_bad_nicknames] = 1,
	svtconf[anti_spam] = 1,
	svtconf[anti_swear] = 1,
	svtconf[anti_caps] = 1,
	svtconf[server_open] = 1,
	svtconf[read_admin_cmds] = 1,
	svtconf[disable_chat] = 0,
	svtconf[read_player_cmds] = 1,
	svtconf[anti_adv] = 1,
	svtconf[read_pms] = 1,
	svtconf[max_ping] = 800,
	svtconf[max_ping_kick] = 1,
	svtconf[max_warns] = 3,
	svtconf[max_duel_bets] = 25000,
	svtconf[safe_restart] = 0;
	format(svtconf[server_owner], MAX_PLAYER_NAME, "[SvT]H2O");

	//Initialization time
	new Success = GetTickCount();

	//Presets
	SendRconCommand("hostname »••••• SWAT vs Terrorists [Updated] •••••«"); //Force our server's name
	SendRconCommand("language English/Español/Russian/Brasil"); //Force our languages field
	SetGameModeText("COD|SvT|GANG WARS|TDM|SWAT");
	SetWeather(10); //Set default weather
	SetVehiclePassengerDamage(true); //Allow vehicle passenger damage
	SetDisableSyncBugs(true); //Fix sync bugs
	SetRespawnTime(3000); //Player respawns in 3 seconds after death
	DisableInteriorEnterExits(); //No players going out of interiors
	//SetMaxConnections(5, e_FLOOD_ACTION_FBAN); //Limit connections
	//ToggleKnifeShootForAll(true);
	EnableStuntBonusForAll(false);
	UsePlayerPedAnims();
	Streamer_TickRate(60);
	Streamer_VisibleItems(STREAMER_TYPE_OBJECT, 650);
	SetNameTagDrawDistance(100.0);

	//Load skins from file
	skinlist = LoadModelSelectionMenu("skins.txt");
	tskinlist = LoadModelSelectionMenu("terroristskins.txt");
	sskinlist = LoadModelSelectionMenu("swatskins.txt");
	toyslist = LoadModelSelectionMenu("toys.txt");

	//Localization - add languages
	SetColour("ADMIN", 0x2281C8FF);
	English = Langs_AddLanguage("EN", "English");
	//Spanish = Langs_AddLanguage("ES", "Spanish");

	for (new i = 0; i < sizeof(Interiors); i++) {
		Interiors[i][IntEnterPickup] = CreateDynamicPickup(19130, 1, Interiors[i][IntEnterPos][0], Interiors[i][IntEnterPos][1], Interiors[i][IntEnterPos][2]);
		Interiors[i][IntExitPickup] = CreateDynamicPickup(19130, 1, Interiors[i][IntExitPos][0], Interiors[i][IntExitPos][1], Interiors[i][IntExitPos][2]);
	
		new string[95];
		format(string, sizeof(string), "%s\n"IVORY"Entrance", Interiors[i][IntName]);
		Interiors[i][IntEnterLabel] = CreateDynamic3DTextLabel(string, COLOR_TOMATO, Interiors[i][IntEnterPos][0], Interiors[i][IntEnterPos][1], Interiors[i][IntEnterPos][2], 20.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, 0, 0);
		format(string, sizeof(string), "%s\n"IVORY"Exit", Interiors[i][IntName]);
		Interiors[i][IntExitLabel] = CreateDynamic3DTextLabel(string, COLOR_TOMATO, Interiors[i][IntExitPos][0], Interiors[i][IntExitPos][1], Interiors[i][IntExitPos][2], 10.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, 0, 0);
	
		if (Interiors[i][IntIco] != -1) {
			CreateDynamicMapIcon(Interiors[i][IntEnterPos][0], Interiors[i][IntEnterPos][1], Interiors[i][IntEnterPos][2], Interiors[i][IntIco], 0, 0, 0, -1, 450.0, MAPICON_LOCAL);
		}
	}

	CreateDynamicObject(18762, 272.3060, 1826.0844, 17.5088, 0.0, 0.0, 90.0);
	CreateDynamicObject(18762, 272.3060, 1825.5844, 17.5088, 0.0, 0.0, 90.0);

	//--------------------
	//Security Center

	//Camera
	gCameraId = CreateDynamicObject(1622, -185.50005, 1554.98340, 40.94810,   0.00000, -6.00000, 121.00000);
	CreateDynamicMapIcon(-185.50005, 1554.98340, 40.94810, 30, 0, 0, 0, -1, 450.0, MAPICON_LOCAL);


	//Watchroom Pickup
	gWatchRoom = CreateDynamicPickup(19130, 1, -259.4019, 1532.8566, 29.3609);
	CreateDynamic3DTextLabel("[ Watch Room ]", COLOR_TOMATO, -259.4019, 1532.8566, 29.3609, 10.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, 0, 0);

	//--------------------

	///////////////////////

	ShopActors[0] = CreateActor(28, -404.0046,2156.6101,52.7544,355.4401); //Terrorists
	ShopActors[1] = CreateActor(285, 201.8225,1870.9551,13.1406,272.6534); //SWAT
	ShopActors[2] = CreateActor(165, -1715.6852,2566.6292,106.0078,270.3348); //VIP

	//------------------
	//Some whores

	new dance1 = CreateActor(87, 1213.8302,-30.2960,1000.9531,44.0354);
	new dance2 = CreateActor(140, 1208.5111,-27.6828,1000.9531,232.6639);
	new dance3 = CreateActor(91, 1206.5964,-35.4083,1000.9531,349.2249);
	new dance4 = CreateActor(90, 1209.0974,-35.5458,1001.4844,14.9186);
	new dance5 = CreateActor(178, 1209.6107,-38.5748,1001.4844,324.1581);
	new dance6 = CreateActor(246, 1213.0743,-39.9945,1001.4844,346.7183);
	new dance7 = CreateActor(244, 1212.0743,-37.9945,1001.4844,346.7183);
	new dance8 = CreateActor(245, 1206.2000,-30.3105,1000.9606,271.5409);

	ApplyActorAnimation(dance1, "DANCING", "DAN_Down_A", 3.0, 1, 0, 0, 0, 0);
	ApplyActorAnimation(dance2, "DANCING", "DAN_Left_A", 3.0, 1, 0, 0, 0, 0);
	ApplyActorAnimation(dance3, "DANCING", "DAN_Loop_A", 3.0, 1, 0, 0, 0, 0);
	ApplyActorAnimation(dance4, "DANCING", "dnce_M_a", 3.0, 1, 0, 0, 0, 0);
	ApplyActorAnimation(dance5, "DANCING", "dnce_M_b", 3.0, 1, 0, 0, 0, 0);
	ApplyActorAnimation(dance6, "DANCING", "bd_clap", 3.0, 1, 0, 0, 0, 0);
	ApplyActorAnimation(dance7, "DANCING", "DAN_Right_A", 3.0, 1, 0, 0, 0, 0);
	ApplyActorAnimation(dance8, "DANCING", "dance_loop", 3.0, 1, 0, 0, 0, 0);

	//Spectators for the whores below
 
	new spec1 = CreateActor(84, 1210.9200,-35.7031,1000.9606,111.4261);
	new spec2 = CreateActor(82, 1211.2236,-37.4733,1000.9606,113.6194);

	ApplyActorAnimation(spec1, "KISSING", "gfwave2", 3.0, 1, 0, 0, 0, 0);
	ApplyActorAnimation(spec2, "KISSING", "gfwave2", 3.0, 1, 0, 0, 0, 0);

	//Guard

	CreateActor(163, 1210.0093,-26.0043,1000.9531,183.3484);

	//=========================================================================

	//Create various server pickups

	g_pickups[0] = CreatePickup(1318, 1, -247.2287,2301.2598,111.9679, -1); // Terrorist Pickup
	CreateDynamic3DTextLabel("*DOWN*", X11_GREEN, -247.2287,2301.2598,111.9679, 50.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, 0, 0);
	
	g_pickups[1] = CreatePickup(1318, 1, -375.7708,2184.0601,51.2200, -1); // Terrorist Pickup
	CreateDynamic3DTextLabel("*UP*", X11_GREEN, -375.7708,2184.0601,51.2200, 50.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, 0, 0);

	g_pickups[2] = CreatePickup(364, 1, -352.8720,1584.9048,76.5136, -1); // Nuke Pickup
	nukeRemoteLabel = CreateDynamic3DTextLabel("Nuke\n{00CC00}Online", 0xFFFFFFFF, -352.8720,1584.9048,76.5136, 50.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, 0, 0);

	g_pickups[3] = CreatePickup(358, 1, 476.2704,2317.9246,38.0893, -1); // Sniper Pickup
	CreateDynamic3DTextLabel("*RIFLE*", X11_DEEPSKYBLUE, 476.2704,2317.9246,38.0893, 50.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, 0, 0);

	g_pickups[5] = CreatePickup(1318, 1, -103.4188,2273.0049,121.1062, -1); // Hill Pickup
	CreateDynamic3DTextLabel("*DOWN*", X11_GREEN, -103.4188,2273.0049,121.1062, 50.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, 0, 0);
	
	g_pickups[6] = CreatePickup(1318, 1, -101.5193,2339.4768,20.9152, -1); // Hill Pickup
	CreateDynamic3DTextLabel("*UP*", X11_GREEN, -101.5193,2339.4768,20.9152, 50.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, 0, 0);

	LoadZones(); //Load capture zones
	CreateUI(); //Create the server's User Interface

	//Load forbidden lists
	mysql_tquery(Database, "SELECT * FROM `ForbiddenList` WHERE `Type` = 'Word'", "LoadForbiddenWords");
	mysql_tquery(Database, "SELECT * FROM `ForbiddenList` WHERE `Type` = 'Name'", "LoadForbiddenNames");
	/////////////////////////////////////////

	printf("Server was initialized in %d ms!", GetTickCount() - Success);
	print("(c) H2O Multiplayer 2018-2019. All rights reserved.");
	return 1;
}

hook OnGameModeExit() {
	new Success = GetTickCount();

	//Remove capture zones
	UnloadZones();

	//Remove some pickups
	DestroyPickup(g_pickups[0]);
	DestroyPickup(g_pickups[1]);
	DestroyPickup(g_pickups[2]);
	DestroyPickup(g_pickups[3]);
	DestroyPickup(g_pickups[4]);
	DestroyPickup(g_pickups[5]);
	DestroyPickup(g_pickups[6]);

	//Unload streamer content
	DestroyAllDynamicObjects();
	DestroyAllDynamic3DTextLabels();

	DestroyAllDynamicCPs();
	DestroyAllDynamicRaceCPs();

	DestroyAllDynamicAreas();
	DestroyAllDynamicMapIcons();

	//Erase User Interface
	RemoveUI();

	printf("SWAT vs Terrorists was unloaded in %d ms.", GetTickCount() - Success);
	return 1;
}

//End of File
/* (c) H2O Multiplayer 2018-2020. All rights reserved. */