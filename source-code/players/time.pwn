/*
	SWAT vs Terrorists is a team death-match SA-MP game-mode script. 
	Compatible with SA-MP 0.3.7 and later releases.

	Author: H2O
	Licensed under GNU GPLv3

	(c) 2018-2020 H2O Multiplayer. All rights reserved.
	Website: h2omultiplayer.com

	Some code is used from gl_realtime and credits for the code
	go to their respective owners

	This script aims to create a time cycle system based on the
	server's local time and it also aims to 
*/

#include <YSI\y_hooks>

new timestr[32];
new last_weather_update;

task gl_realtime_update[60000]() {
	new hour, minute;
   	gettime(hour, minute);
 
   	format(timestr, 32, "%02d:%02d", hour, minute);
   	TextDrawSetString(txtTimeDisp, timestr);
   	SetWorldTime(hour);
   	
	foreach (new x: Player) {
	    if(GetPlayerState(x) != PLAYER_STATE_NONE) {
	        SetPlayerTime(x, hour, minute);
		}
	}

	// Update weather every hour
	if(!last_weather_update) {
	    UpdateWorldWeather();
	}
	last_weather_update ++;
	if(last_weather_update == 60) {
	    last_weather_update = 0;
	}
}

//Weather system

new fine_weather_ids[] = {1,2,3,4,5,6,7,12,13,14,15,17,18,24,25,26,27,28,29,30,40};
new foggy_weather_ids[] = {9,19,20,31,32};
new wet_weather_ids[] = {8};

stock UpdateWorldWeather()
{
	new next_weather_prob = random(100);
	if(next_weather_prob < 70) 		SetWeather(fine_weather_ids[random(sizeof(fine_weather_ids))]);
	else if(next_weather_prob < 95) SetWeather(foggy_weather_ids[random(sizeof(foggy_weather_ids))]);
	else							SetWeather(wet_weather_ids[random(sizeof(wet_weather_ids))]);
}

//Start using the functions...

hook OnGameModeInit() {
	txtTimeDisp = TextDrawCreate(605.0,25.0,"00:00");
	TextDrawUseBox(txtTimeDisp, 0);
	TextDrawFont(txtTimeDisp, 3);
	TextDrawSetShadow(txtTimeDisp,0);
    TextDrawSetOutline(txtTimeDisp,2);
    TextDrawBackgroundColor(txtTimeDisp,0x000000FF);
    TextDrawColor(txtTimeDisp,0xFFFFFFFF);
    TextDrawAlignment(txtTimeDisp,3);
	TextDrawLetterSize(txtTimeDisp,0.5,1.5);
	
	gl_realtime_update();
	return 1;
}

hook OnPlayerConnect(playerid) {
	//Time and weather
	new hour, minute;
	gettime(hour, minute);
	SetPlayerTime(playerid, hour, minute);
	return 1;
}

hook OnPlayerFullyConnected(playerid) {
	//Time and weather
	new hour, minute;
	gettime(hour, minute);
	SetPlayerTime(playerid, hour, minute);
	return 1;
}

hook OnPlayerSpawn(playerid) {
	new hour, minute;
	gettime(hour, minute);
	SetPlayerTime(playerid, hour, minute);
	return 1;
}

//End of File
/* (c) H2O Multiplayer 2018-2020. All rights reserved. */