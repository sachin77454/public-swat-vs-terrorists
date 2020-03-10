/*
	SWAT vs Terrorists is a team death-match SA-MP game-mode script.
	Compatible with SA-MP 0.3.7 and later releases.

	Author: H2O
	Licensed under GNU GPLv3

	(c) 2018-2020 H2O Multiplayer. All rights reserved.
	Website: h2omultiplayer.com

	Alerts Module
*/

#include <YSI\y_hooks>
#include <YSI_Players\y_text> //Y_Less
loadtext mode_text[all], mode_text[client], mode_text[newcs], mode_text[dialogs], mode_text[gametexts];

forward EndNotification(playerid);
public EndNotification(playerid) {
	KillTimer(NotifierTimer[playerid]);
	PlayerTextDrawHide(playerid, Notifier_PTD[playerid]);
	return 1;
}

forward HideCarInfo(playerid);
public HideCarInfo(playerid) {
	PlayerTextDrawHide(playerid, CarInfoPTD[playerid][0]);
	PlayerTextDrawHide(playerid, CarInfoPTD[playerid][1]);
	PlayerTextDrawHide(playerid, CarInfoPTD[playerid][2]);

	TextDrawHideForPlayer(playerid, CarInfoTD[0]);
	TextDrawHideForPlayer(playerid, CarInfoTD[1]);
	TextDrawHideForPlayer(playerid, CarInfoTD[2]);
	TextDrawHideForPlayer(playerid, CarInfoTD[3]);
	PlayerInfo[playerid][pCarInfoDisplayed] = 0;    
	return 1;
}

ShowCarInfo(playerid, car_name[30], car_desc[125], requirements[45]) {
	new string[130];

	format(string, sizeof(string), "~y~Model~w~: %s", car_name);
	PlayerTextDrawSetString(playerid, CarInfoPTD[playerid][0], string);

	format(string, sizeof(string), "~y~Abilities~w~: %s", car_desc);
	PlayerTextDrawSetString(playerid, CarInfoPTD[playerid][1], string);

	format(string, sizeof(string), "~y~Requirments~w~: %s", requirements);
	PlayerTextDrawSetString(playerid, CarInfoPTD[playerid][2], string);

	PlayerTextDrawShow(playerid, CarInfoPTD[playerid][0]);
	PlayerTextDrawShow(playerid, CarInfoPTD[playerid][1]);
	PlayerTextDrawShow(playerid, CarInfoPTD[playerid][2]);

	TextDrawShowForPlayer(playerid, CarInfoTD[0]);
	TextDrawShowForPlayer(playerid, CarInfoTD[1]);
	TextDrawShowForPlayer(playerid, CarInfoTD[2]);
	TextDrawShowForPlayer(playerid, CarInfoTD[3]);

	PlayerInfo[playerid][pCarInfoDisplayed] = 1;
	KillTimer(CarInfoTimer[playerid]);
	CarInfoTimer[playerid] = SetTimerEx("HideCarInfo", 4000, false, "i", playerid);
	return 1;
}

NotifyPlayer(playerid, message[]) {
	if (!PlayerInfo[playerid][pLoggedIn]) return false;
	PlayerTextDrawSetString(playerid, Notifier_PTD[playerid], message);
	PlayerTextDrawShow(playerid, Notifier_PTD[playerid]);
	KillTimer(NotifierTimer[playerid]);
	NotifierTimer[playerid] = SetTimerEx("EndNotification", 7000, false, "i", playerid);
	return 1;
}

//End of File
/* (c) H2O Multiplayer 2018-2020. All rights reserved. */