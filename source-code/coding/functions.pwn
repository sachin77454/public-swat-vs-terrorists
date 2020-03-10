/*
	SWAT vs Terrorists is a team death-match SA-MP game-mode script. 
	Compatible with SA-MP 0.3.7 and later releases.

	Author: H2O
	Licensed under GNU GPLv3

	(c) 2018-2020 H2O Multiplayer. All rights reserved.
	Website: h2omultiplayer.com
*/

#include <a_samp>
#include <foreach>
#include <Pawn.Regex>
#include <ColAndreas>

#include <YSI_Coding\y_hooks>

//Support for y_text, load language files...
#include <YSI_Players\y_text> //Y_Less
loadtext mode_text[all], mode_text[client], mode_text[newcs], mode_text[dialogs], mode_text[gametexts];

//Check whether a key was pressed
#define PRESSED(%0) \
	(((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))

//Check whether a player is yet holding the key
#define HOLDING(%0) \
	((newkeys & (%0)) == (%0))

//Check if the player released the key
#define RELEASED(%0) \
	(((newkeys & (%0)) != (%0)) && ((oldkeys & (%0)) == (%0)))

//Define gpci function
#if !defined gpci
	native gpci(playerid, serial[], len);
#endif

//Pagination definition
#define PAGES(%0,%1) (((%0) - 1) / (%1) + 1)

//Check if a message is null
#if !defined isnull
	#define isnull(%1) \
				((!(%1[0])) || (((%1[0]) == '\1') && (!(%1[1]))))
#endif

//Check if a vehicle is valid (add definition)
#if !defined IsValidVehicle
	native IsValidVehicle(vehicleid);
#endif

//Get vehicle boot
#define GetVehicleBoot(%0,%1,%2,%3) \
	(GetVehicleOffset((%0), VEHICLE_OFFSET_BOOT, %1, %2, %3))

//Lighten colors, reduce opcaity
#define ALPHA(%2,%1) ((%2 & ~0xFF) | (clamp(%1,0x00,0xFF)))

//Convert uppercase chars to lowercase ones
#define LOWERCASE(%1) \
		for (new strpos; strpos < strlen(%1); strpos ++) \
			if ( %1[strpos]> 64 && %1[strpos] < 91 ) %1[strpos] += 32

//Delete cars

forward EraseCar(vehicleid);
public EraseCar(vehicleid) {
	if (IsValidVehicle(vehicleid)) {
		DestroyVehicle(vehicleid);
	}
	return 1;
}

//Weapon change

forward OnPlayerWeaponChange(playerid);
public OnPlayerWeaponChange(playerid) {   
	return 1;
}

//Apply carrying animation

forward CarryAnim(playerid);
public CarryAnim(playerid) {
	return ApplyAnimation(playerid, "CARRY", "crry_prtial", 4.1, 0, 1, 1, 1, 1, 1);
}

//Misc

forward ApplyBan(playerid);
public ApplyBan(playerid) {
	Kick(playerid);    
	return 1;
}

forward DelayKick(playerid);
public DelayKick(playerid) {
	Kick(playerid);
	return 1;
}

//Anti c-bug

forward StoppCheckCBug(playerid);
public StoppCheckCBug(playerid) {
	PlayerInfo[playerid][pCheckCBug] = 0;    
	return 1;
}

//==============================================================================

//Free hunter

forward SpawnFreeHunter(playerid);
public SpawnFreeHunter(playerid) {
	CarSpawner(playerid, 425);
	SetVehicleHealth(GetPlayerVehicleID(playerid), 700.0);	
	return 1;
}

/////////////////////////////

//Get object's collision sphere radius (useful for draw-distance)
stock Float:GetColSphereRadius(objectmodel) {
	new Float:tmp, Float:rad;
	if(0 <= objectmodel <= 19999) {
		CA_GetModelBoundingSphere(objectmodel, tmp, tmp, tmp, rad);
		return rad;
	}
	return 0.0;
}

//Get distance between two points
forward Float:GetDistance(Float:x1, Float:y1, Float:z1, Float:x2, Float:y2, Float:z2);
Float:GetDistance(Float:x1, Float:y1, Float:z1, Float:x2, Float:y2, Float:z2) {
	return floatsqroot(floatpower(floatabs(floatsub(x2,x1)),2)+floatpower(floatabs(floatsub(y2,y1)),2)+floatpower(floatabs(floatsub(z2,z1)),2));
}

//GetAngleToPos made by MegaDreams
stock Float: GetAngleToPos(Float: PX, Float: PY, Float: X, Float: Y) {
	new Float:Angle = floatabs(atan((Y-PY)/(X-PX)));
	Angle = (X<=PX && Y>=PY) ? floatsub(180,Angle) : (X<PX && Y<PY) ? floatadd(Angle,180) : (X>=PX && Y<=PY) ? floatsub(360.0,Angle) : Angle;
	Angle = floatsub(Angle, 90.0);
	Angle = (Angle>=360.0) ? floatsub(Angle, 360.0) : Angle;
	return Angle;
}

//Get distance from a point to another
Float:GetPointDistanceToPoint(Float:x1, Float:y1, Float:x2, Float:y2) {
	new Float:x, Float:y;
	x = x1-x2;
	y = y1-y2;
	return floatsqroot(x*x+y*y);
}

//Random float number
Float:frandom(Float:max, Float:min = 0.0, dp = 4) {
	new
		Float:mul = floatpower(10.0, dp),
		imin = floatround(min * mul),
		imax = floatround(max * mul);
	return float(random(imax - imin) + imin) / mul;
}

/////////////

//Text validity verification
IsValidText(text[]) { 
	new Regex:r = Regex_New("[A-Za-z0-9]+"); 
	new check = Regex_Check(text, r); 
	Regex_Delete(r); 
	return check; 
}

//See if a vehicle is driven or not
IsVehicleUsed(vehicleid) {
	foreach (new i: Player) {
		if (IsPlayerConnected(i) && IsPlayerInVehicle(i, vehicleid) && GetPlayerState(i) == PLAYER_STATE_DRIVER) return 1;
	}
	return 0;
}

//Get a vehicle's maximum speed (top speeds are defined in server header)
stock GetVehicleTopSpeed(vehicleid) {
    new model = GetVehicleModel(vehicleid);
    if (model) {
        return s_TopSpeed[(model - 400)];
    }
    return 0;
}

//Is it a plane?
stock IsAirVehicle(vehicleid) {
    new AirVeh[] = { 592, 577, 511, 512, 593, 520, 553, 476, 519, 460, 513, 548, 425, 417, 487, 488, 497, 563, 447, 469 };
    for(new i = 0; i < sizeof(AirVeh); i++) {
        if(GetVehicleModel(vehicleid) == AirVeh[i]) return 1;
    }
    return 0;
}

//Return vehicle's model ID from a given name string (defined in server header)
GetVehicleModelIDFromName(const vname[]) {
	for (new i = 0; i < 211; i++) {
		if (strfind(VehicleNames[i], vname, true) != -1)
			return i + 400;
	}
	return -1;
}

//Extended vehicle functions

//Return a player's vehicle speed
GetPlayerVehicleSpeed(playerid) {
	new Float:X, Float:Y, Float:Z, Float:R;
	if (IsPlayerInAnyVehicle(playerid))
	{
		GetVehicleVelocity(GetPlayerVehicleID(playerid), X, Y, Z);
	}
	R = floatsqroot(floatabs(floatpower(X + Y + Z, 2)));
	return floatround(R * 100 * 1.61);
}

//What was this supposed to do? Get roof/boot/hood offsets? Apparently, it does..
stock GetVehicleOffset(vehicleid, type, &Float:x, &Float:y, &Float:z) {
	new Float:fPos[4], Float:fSize[3];
 
	if (!IsValidVehicle(vehicleid)) {
		x = 0.0;
		y = 0.0;
		z = 0.0;
 
		return 0;
	}
	else
	{
		GetVehiclePos(vehicleid, fPos[0], fPos[1], fPos[2]);
		GetVehicleZAngle(vehicleid, fPos[3]);
		GetVehicleModelInfo(GetVehicleModel(vehicleid), VEHICLE_MODEL_INFO_SIZE, fSize[0], fSize[1], fSize[2]);
 
		switch (type)
		{
			case VEHICLE_OFFSET_BOOT:
			{
				x = fPos[0] - (floatsqroot(fSize[1] + fSize[1]) * floatsin(-fPos[3], degrees));
				y = fPos[1] - (floatsqroot(fSize[1] + fSize[1]) * floatcos(-fPos[3], degrees));
				z = fPos[2];
			}
			case VEHICLE_OFFSET_HOOD:
			{
				x = fPos[0] + (floatsqroot(fSize[1] + fSize[1]) * floatsin(-fPos[3], degrees));
				y = fPos[1] + (floatsqroot(fSize[1] + fSize[1]) * floatcos(-fPos[3], degrees));
				z = fPos[2];
			}
			case VEHICLE_OFFSET_ROOF:
			{
				x = fPos[0];
				y = fPos[1];
				z = fPos[2] + floatsqroot(fSize[2]);
			}
		}
	}    
	return 1;
}

//Identify a vehicle's driver
GetVehicleDriver(vehicleid) {
	foreach (new i: Player) {
		if (GetPlayerState(i) == PLAYER_STATE_DRIVER && IsPlayerInVehicle(i, vehicleid)) {
			return i;
		}
	}
	return INVALID_PLAYER_ID;
}

//--
//---
//Skin validation
IsValidSkin(SkinID) {
	if (SkinID >= 0 && SkinID <= 311 && SkinID != 74) return 1;
	return 0;
}

//Weapon validation
IsValidWeapon(weaponid) {
	if (weaponid > 0 && weaponid < 19 || weaponid > 21 && weaponid < 47) return 1;
	return 0;
}

//Return weapon name from a text string
GetWeaponIDFromName(const WeaponName[]) {
	if (strfind("molotov", WeaponName, true) != -1) return 18;

	for (new i = 0; i < 46; i++) {
		switch (i) {
			case 0, 19, 20, 21, 44, 45: continue;

			default:
			{
				new name[32];
				GetWeaponName(i, name, 32);

				if (strfind(name, WeaponName, true) != -1) return i;
			}
		}
	}

	return -1;
}

//Return weapon model from weapon ID
GetWeaponModel(weaponid) {
	new weapon_model = -1;

	switch (weaponid) {
		case 1: weapon_model = 331;
		case 2: weapon_model = 333;
		case 3: weapon_model = 334;
		case 4: weapon_model = 335;
		case 5: weapon_model = 336;
		case 6: weapon_model = 337;
		case 7: weapon_model = 338;
		case 8: weapon_model = 339;
		case 9: weapon_model = 341;
		case 10: weapon_model = 321;
		case 11: weapon_model = 322;
		case 12: weapon_model = 323;
		case 13: weapon_model = 324;
		case 14: weapon_model = 325;
		case 15: weapon_model = 326;
		case 16: weapon_model = 342;
		case 17: weapon_model = 343;
		case 18: weapon_model = 344;
		case 22: weapon_model = 346;
		case 23: weapon_model = 347;
		case 24: weapon_model = 348;
		case 25: weapon_model = 349;
		case 26: weapon_model = 350;
		case 27: weapon_model = 351;
		case 28: weapon_model = 352;
		case 29: weapon_model = 353;
		case 30: weapon_model = 355;
		case 31: weapon_model = 356;
		case 32: weapon_model = 372;
		case 33: weapon_model = 357;
		case 34: weapon_model = 358;
		case 35: weapon_model = 359;
		case 36: weapon_model = 360;
		case 37: weapon_model = 361;
		case 38: weapon_model = 362;
		case 39: weapon_model = 363;
		case 41: weapon_model = 365;
		case 42: weapon_model = 366;
		case 46: weapon_model = 371;
	}
	return weapon_model;
}

//Remove a player's weapon from the weapon slot
stock RemovePlayerWeapon(playerid, weapon) {
	new weapons[13], ammo[13];
	for(new i; i < 13; i++) GetPlayerWeaponData(playerid, i, weapons[i], ammo[i]);
	ResetPlayerWeapons(playerid);
	for(new i; i < 13; i++) {
		if (weapons[i] == weapon) continue;
		GivePlayerWeapon(playerid, weapons[i], ammo[i]);
	}    
	return 1;
}

//Weapon slot check
GetWeaponSlot(weaponid) {
	switch (weaponid) {
		case 0, 1:          return 0;
		case 2 .. 9:        return 1;
		case 10 .. 15:      return 10;
		case 16 .. 18, 39:  return 8;
		case 22 .. 24:      return 2;
		case 25 .. 27:      return 3;
		case 28, 29, 32:    return 4;
		case 30, 31:        return 5;
		case 33, 34:        return 6;
		case 35 .. 38:      return 7;
		case 40:            return 12;
		case 41 .. 43:      return 9;
		case 44 .. 46:      return 11;
	}
	return -1;
}

//Remove a certain weapon from a slot
stock RemoveWeaponFromSlot(playerid, weaponslot) {
	new weapons[13][2];
	for(new i = 0; i < 13; i++)
		GetPlayerWeaponData(playerid, i, weapons[i][0], weapons[i][1]);
	weapons[weaponslot][0] = 0;
	ResetPlayerWeapons(playerid);

	for(new i = 0; i < 13; i++)
		GivePlayerWeapon(playerid, weapons[i][0], weapons[i][1]);    
	return 1;
}

//Add double ammo to the player
AddAmmo(playerid) {
	new slot, weapon, ammo; 
	for (slot = 0; slot < 13; slot++) {
		GetPlayerWeaponData(playerid, slot, weapon, ammo);
		
		if (IsBulletWeapon(weapon) && weapon != WEAPON_MINIGUN) {
			GivePlayerWeapon(playerid, weapon, ammo);
		}
	}    
	return 1;
}

//Add quad ammo to the player
AddAmmo2(playerid) {
	new slot, weapon, ammo; 
	for (slot = 0; slot < 13; slot++) {
		GetPlayerWeaponData(playerid, slot, weapon, ammo);
		
		if (IsBulletWeapon(weapon) && weapon != WEAPON_MINIGUN) {
			GivePlayerWeapon(playerid, weapon, ammo * 2);
		}
	}    
	return 1;
}

//Add 6x ammo to the player
AddAmmo3(playerid) {
	new slot, weapon, ammo; 
	for (slot = 0; slot < 13; slot++) {
		GetPlayerWeaponData(playerid, slot, weapon, ammo);
		
		if (IsBulletWeapon(weapon) && weapon != WEAPON_MINIGUN) {
			GivePlayerWeapon(playerid, weapon, ammo * 3);
		}
	}    
	return 1;
}

//Maximize player's ammo on all weapons
MaxAmmo(playerid) {
	new slot, weap, ammo;

	for (slot = 0; slot < 13; slot++) {
		GetPlayerWeaponData(playerid, slot, weap, ammo);

		if (IsValidWeapon(weap)) {
			GivePlayerWeapon(playerid, weap, 99999);
		}
	}
	return 1;
}

//Check whether a player is in the given area
IsPlayerInArea(playerid, Float:MinX, Float:MinY, Float:MaxX, Float:MaxY) {
	new Float:X, Float:Y, Float:Z;

	GetPlayerPos(playerid, X, Y, Z);
	if (X >= MinX && X <= MaxX && Y >= MinY && Y <= MaxY) {
		return 1;
	}
	return 0;
}

//As much as IsPlayerInRangeOfPOINT
stock IsPointInRangeOfPoint(Float:x, Float:y, Float:z, Float:x2, Float:y2, Float:z2, Float:range) {
	x2 -= x;
	y2 -= y;
	z2 -= z;
	return ((x2 * x2) + (y2 * y2) + (z2 * z2)) < (range * range);
}

//Useful for projectiles, get coordinates in-front of player at given distance
stock GetXYInFrontOfPlayer(playerid, &Float:x, &Float:y, Float:distance) {
	// Created by Y_Less

	new Float:a;

	GetPlayerPos(playerid, x, y, a);
	GetPlayerFacingAngle(playerid, a);

	if (GetPlayerVehicleID(playerid)) {
		GetVehicleZAngle(GetPlayerVehicleID(playerid), a);
	}

	x += (distance * floatsin(-a, degrees));
	y += (distance * floatcos(-a, degrees));
}

//Force the player's facing angle to given coordinates
SetPlayerLookAt(playerid, Float:X, Float:Y) {
	new Float:Px, Float:Py, Float: Pa;
	GetPlayerPos(playerid, Px, Py, Pa);
	Pa = floatabs(atan((Y-Py)/(X-Px)));
	if (X <= Px && Y >= Py) Pa = floatsub(180, Pa);
	else if (X < Px && Y < Py) Pa = floatadd(Pa, 180);
	else if (X >= Px && Y <= Py) Pa = floatsub(360.0, Pa);
	Pa = floatsub(Pa, 90.0);
	if (Pa >= 360.0) Pa = floatsub(Pa, 360.0);
	SetPlayerFacingAngle(playerid, Pa);
}

//Is a numbers-only string
IsNumeric(const String[]) {
	new numeric = 1;
	for (new i = 0, j = strlen(String); i < j; i++) {
		if (String[i] > '9' || String[i] < '0') {
			numeric = 0;
		}
	}

	return numeric;
}

//Return timestamp in seconds instead of ms
TimeStamp() {
	new time = GetTickCount() / 1000;
	return time;
}

//Compare two timestamps
GetWhen(start, till) {
	new seconds = till - start;

	const MINUTE = 60;
	const HOUR = 60 * MINUTE;
	const DAY = 24 * HOUR;
	const MONTH = 30 * DAY;

	new time_issued[32];
	if (seconds == 1)
		format(time_issued, sizeof (time_issued), "A seconds ago");
	if (seconds < (1 * MINUTE))
		format(time_issued, sizeof (time_issued), "%i seconds ago", seconds);
	else if (seconds < (2 * MINUTE))
		format(time_issued, sizeof (time_issued), "A minute ago");
	else if (seconds < (45 * MINUTE))
		format(time_issued, sizeof (time_issued), "%i minutes ago", (seconds / MINUTE));
	else if (seconds < (90 * MINUTE))
		format(time_issued, sizeof (time_issued), "An hour ago");
	else if (seconds < (24 * HOUR))
		format(time_issued, sizeof (time_issued), "%i hours ago", (seconds / HOUR));
	else if (seconds < (48 * HOUR))
		format(time_issued, sizeof (time_issued), "Yesterday");
	else if (seconds < (30 * DAY))
		format(time_issued, sizeof (time_issued), "%i days ago", (seconds / DAY));
	else if (seconds < (12 * MONTH)) {
		new months = floatround(seconds / DAY / 30);
		if (months <= 1)
			format(time_issued, sizeof (time_issued), "One month ago");
		else
			format(time_issued, sizeof (time_issued), "%i months ago", months);
	}
	else
	{
		new years = floatround(seconds / DAY / 365);
		if (years <= 1)
			format(time_issued, sizeof (time_issued), "One year ago");
		else
			format(time_issued, sizeof (time_issued), "%i years ago", years);
	}
	return time_issued;
}

//Convert numbers? What was this supposed to do..
stock convertNumber(value) {
	// http://forum.sa-mp.com/showthread.php?p=843781#post843781
	new string[24];
	format(string, sizeof(string), "%d", value);

	for(new i = (strlen(string) - 3); i > (value < 0 ? 1 : 0) ; i -= 3) {
		strins(string[i], ",", 0);
	}

	return string;
}

//Convert time to string
stock TimeConvert(time) {
	new minutes;
	new seconds;
	new string[128];
	if (time > 59) {
		minutes = floatround(time/60);
		seconds = floatround(time - minutes*60);
		if (seconds>9)format(string,sizeof(string),"%d:%d",minutes,seconds);
		else format(string,sizeof(string),"%d:0%d",minutes,seconds);
	}
	else {
		seconds = floatround(time);
		if (seconds>9)format(string,sizeof(string),"0:%d",seconds);
		else format(string,sizeof(string),"0:0%d",seconds);
	}
	return string;
}

//Supposed to separate numbers using given separators
stock formatInt(intVariable, iThousandSeparator = ',', iCurrencyChar = '$') {
	/*
		By Kar
		https://gist.github.com/Kar2k/bfb0eafb2caf71a1237b349684e091b9/8849dad7baa863afb1048f40badd103567c005a5#file-formatint-function
	*/
	static
		s_szReturn[ 32 ],
		s_szThousandSeparator[ 2 ] = { ' ', EOS },
		s_szCurrencyChar[ 2 ] = { ' ', EOS },
		s_iVariableLen,
		s_iChar,
		s_iSepPos,
		bool:s_isNegative
	;

	format( s_szReturn, sizeof( s_szReturn ), "%d", intVariable );

	if (s_szReturn[0] == '-')
		s_isNegative = true;
	else
		s_isNegative = false;

	s_iVariableLen = strlen( s_szReturn );

	if ( s_iVariableLen >= 4 && iThousandSeparator) {
		s_szThousandSeparator[ 0 ] = iThousandSeparator;

		s_iChar = s_iVariableLen;
		s_iSepPos = 0;

		while ( --s_iChar > _:s_isNegative ) {
			if ( ++s_iSepPos == 3 ) {
				strins( s_szReturn, s_szThousandSeparator, s_iChar );

				s_iSepPos = 0;
			}
		}
	}
	if (iCurrencyChar) {
		s_szCurrencyChar[ 0 ] = iCurrencyChar;
		strins( s_szReturn, s_szCurrencyChar, _:s_isNegative );
	}
	return s_szReturn;
}

//Random number that actually has a minimum and a maximum value
stock RandomEx(min, max) //Y_Less
	return random(max - min) + min;

stock ConvertToMinutes(time) {
	// http://forum.sa-mp.com/showpost.php?p=3223897&postcount=11
	new string[15];//-2000000000:00 could happen, so make the string 15 chars to avoid any errors
	format(string, sizeof(string), "%02d:%02d", time / 60, time % 60);
	return string;
}

//Make a player visible or invisible..
SetPlayerMarkerVisibility(playerid, alpha = 0xFF) { //Thanks SA:MP wiki
	new oldcolor, newcolor;

	alpha = clamp(alpha, 0x00, 0xFF);
	oldcolor = GetPlayerColor(playerid);

	newcolor = (oldcolor & ~0xFF) | alpha;
	return SetPlayerColor(playerid, newcolor);
}

//Create a scrollbar (I think used by the inventory system?)
ScrollBar(page, totalPages, &Float:y, Float:maxHeight, &Float:height) {
	height = maxHeight / totalPages;
	y += (height * 9) * page;
}

//What was this supposed to do? I can't recall
stock GetOffsetPos(&Float:x, &Float:y, Float:distance, Float: r) {	// Created by Y_Less
	x += (distance * floatsin(-r, degrees));
	y += (distance * floatcos(-r, degrees));
}

//.....
stock Get2DRandomDistanceAway(&Float: fwX, &Float: fwY, min_distance, max_distance = 100) {
	new Float: tempX = fwX, Float: tempY = fwY;
	new rX = random(max_distance);
	new rY = random(max_distance);
	tempX += float(rX-(max_distance/2));
	tempY += float(rY-(max_distance/2));
	while (GetDistance(tempX, tempY, 10.0, fwX, fwY, 10.0) < min_distance/2) {
		tempX = fwX;
		tempY = fwY;
		rX = random(max_distance);
		rY = random(max_distance);
		tempX += float(rX-(max_distance/2));
		tempY += float(rY-(max_distance/2));
	}
	fwX = tempX;
	fwY = tempY;    
	return 1;
}

//...............
stock Get3DRandomDistanceAway(&Float: fwX, &Float: fwY, &Float: fwZ, min_distance, max_distance = 100) {
	new Float: tempX = fwX, Float: tempY = fwY, Float: tempZ = fwZ;
	new rX = random(max_distance);
	new rY = random(max_distance);
	new rZ = random(max_distance);
	tempX += float(rX-(max_distance/2));
	tempY += float(rY-(max_distance/2));
	tempZ += float(rZ-(max_distance/2));
	while (GetDistance(tempX, tempY, tempZ, fwX, fwY, fwZ) < min_distance/2) {
		tempX = fwX;
		tempY = fwY;
		tempZ = fwZ;
		rX = random(max_distance);
		rY = random(max_distance);
		rZ = random(max_distance);
		tempX += float(rX-(max_distance/2));
		tempY += float(rY-(max_distance/2));
		tempZ += float(rZ-(max_distance/2));
	}
	fwX = tempX;
	fwY = tempY;
	fwZ = tempZ;    
	return 1;
}

//Replace a part of the given string
strreplace(string[], const search[], const replacement[], bool:ignorecase = false, pos = 0, limit = -1, maxlength = sizeof(string)) {
	// No need to do anything if the limit is 0.
	if (limit == 0)
		return 0;
	
	new
			 sublen = strlen(search),
			 replen = strlen(replacement),
		bool:packed = ispacked(string),
			 maxlen = maxlength,
			 len = strlen(string),
			 count = 0
	;
	
	
	// "maxlen" holds the max string length (not to be confused with "maxlength", which holds the max. array size).
	// Since packed strings hold 4 characters per array slot, we multiply "maxlen" by 4.
	if (packed)
		maxlen *= 4;
	
	// If the length of the substring is 0, we have nothing to look for..
	if (!sublen)
		return 0;
	
	// In this line we both assign the return value from "strfind" to "pos" then check if it's -1.
	while (-1 != (pos = strfind(string, search, ignorecase, pos))) {
		// Delete the string we found
		strdel(string, pos, pos + sublen);
		
		len -= sublen;
		
		// If there's anything to put as replacement, insert it. Make sure there's enough room first.
		if (replen && len + replen < maxlen) {
			strins(string, replacement, pos, maxlength);
			
			pos += replen;
			len += replen;
		}
		
		// Is there a limit of number of replacements, if so, did we break it?
		if (limit != -1 && ++count >= limit)
			break;
	}
	return count;
}

//Check whether a player is aiming at the target
bool:IsPlayerAimingAtPlayer(playerid, target) {
	new Float:x, Float:y, Float:z;
	GetPlayerPos(target, x, y, z);
	if (IsPlayerAimingAt(playerid, x, y, z-0.75, 0.25)) return true;
	if (IsPlayerAimingAt(playerid, x, y, z-0.25, 0.25)) return true;
	if (IsPlayerAimingAt(playerid, x, y, z+0.25, 0.25)) return true;
	if (IsPlayerAimingAt(playerid, x, y, z+0.75, 0.25)) return true;
	return false;
}

//Make an object face given 3D Coordinates
SetDynamicObjectFaceCoords3D(iObject, Float: fX, Float: fY, Float: fZ, Float: fRollOffset = 0.0, Float: fPitchOffset = 0.0, Float: fYawOffset = 0.0) {
	new
		Float: fOX,
		Float: fOY,
		Float: fOZ,
		Float: fPitch
	;
	GetDynamicObjectPos(iObject, fOX, fOY, fOZ);

	fPitch = floatsqroot(floatpower(fX - fOX, 2.0) + floatpower(fY - fOY, 2.0));
	fPitch = floatabs(atan2(fPitch, fZ - fOZ));

	fZ = atan2(fY - fOY, fX - fOX) - 90.0; // Yaw

	SetDynamicObjectRot(iObject, fRollOffset, fPitch + fPitchOffset, fZ + fYawOffset);
}

//Anti advertisement
//Who made this?
AdCheck(const szStr[], bool:fixedSeparation = false, bool:ignoreNegatives = false, bool:ranges = true) {
	new
		i = 0, ch, lastCh, len = strlen(szStr), trueIPInts = 0, bool:isNumNegative = false, bool:numIsValid = true, // Invalid numbers are 1-1
		numberFound = -1, numLen = 0, numStr[5], numSize = sizeof(numStr),
		lastSpacingPos = -1, numSpacingDiff, numLastSpacingDiff, numSpacingDiffCount // -225\0 (4 len)
	;
	while(i <= len) {
		lastCh = ch;
		ch = szStr[i];
		if (ch >= '0' && ch <= '9' || (ranges == true && ch == '*')) {
			if (numIsValid && numLen < numSize) {
				if (lastCh == '-') {
					if (numLen == 0 && ignoreNegatives == false) {
						isNumNegative = true;
					}
					else if (numLen > 0) {
						numIsValid = false;
					}
				}
				numberFound = strval(numStr);
				if (numLen == (3 + _:isNumNegative) && !(numberFound >= -255 && numberFound <= 255)) { // IP Num is valid up to 4 characters.. -255
					for (numLen = 3; numLen > 0; numLen--) {
						numStr[numLen] = EOS;
					}
				}
				else if (lastCh == '-' && ignoreNegatives) {
					i++;
					continue;
				} else {
					if (numLen == 0 && numIsValid == true && isNumNegative == true && lastCh == '-') {
						numStr[numLen++] = lastCh;
					}
					numStr[numLen++] = ch;
				}
			}
		} else {
			if (numLen && numIsValid) {
				numberFound = strval(numStr);
				if (numberFound >= -255 && numberFound <= 255) {
					if (fixedSeparation) {
						if (lastSpacingPos != -1) {
							numLastSpacingDiff = numSpacingDiff;
							numSpacingDiff = i - lastSpacingPos - numLen;
							if (trueIPInts == 1 || numSpacingDiff == numLastSpacingDiff) {
								++numSpacingDiffCount;
							}
						}
						lastSpacingPos = i;
					}
					if (++trueIPInts >= 4) {
						break;
					}
				}
				for (numLen = 3; numLen > 0; numLen--) {
					numStr[numLen] = EOS;
				}
				isNumNegative = false;
			} else {
				numIsValid = true;
			}
		}
		i++;
	}
	if (fixedSeparation == true && numSpacingDiffCount < 3) {
		return 0;
	}
	return (trueIPInts >= 4);
}

//Thanks to RyDeR`, return a random text string, useful for security codes
stock randomString(strDest[], strLen = 10) {
    while(strLen--)
        strDest[strLen] = random(2) ? (random(26) + (random(2) ? 'a' : 'A')) : (random(10) + '0');
}

//Command syntax message
ShowSyntax(playerid, const message[]) {
	return SendClientMessage(playerid, X11_LIGHTGREEN, message);
}

//S0beit Check (I remember learning this out of a quickview over the Modern Warfare 3 gamescript)
stock IsPlayerBot(playerid) {
    new TempId[80], TempNumb;
    gpci(playerid, TempId, sizeof(TempId));
    for(new i = 0; i < strlen(TempId); i++) {
        if(TempId[i] >= '0' && TempId[i] <= '9')  TempNumb++;
    }
    return (TempNumb >= 30 || strlen(TempId) <= 30) ? true : false;
}

//Animations

AnimPlayer(playerid, animlib[], animname[], Float:speed, looping, lockx, locky, lockz, lp) {
	ApplyAnimation(playerid, animlib, animname, speed, looping, lockx, locky, lockz, lp);
	return true;
}

AnimLoopPlayer(playerid, animlib[], animname[], Float:speed, looping, lockx, locky, lockz, lp) {
	IsPlayerUsingAnims[playerid] = 1;
	ApplyAnimation(playerid, animlib, animname, speed, looping, lockx, locky, lockz, lp);
	//Text_Send(playerid, $END_ANIM);
	return true;
}

StopAnimLoopPlayer(playerid) {
	IsPlayerUsingAnims[playerid] = 0;
	ApplyAnimation(playerid, "CARRY", "crry_prtial", 4.0, 0, 0, 0, 0, 0);    
	return 1;
}

AnimPreloadForPlayer(playerid, animlib[]) {
	ApplyAnimation(playerid, animlib, "null", 0.0, 0, 0, 0, 0, 0);
	return 1;
}

stock IsPlayerInWater(playerid) {
	new anim = GetPlayerAnimationIndex(playerid);
	if (((anim >=  1538) && (anim <= 1542)) || (anim == 1544) || (anim == 1250) || (anim == 1062)) return 1;
	return 0;
}

stock IsPlayerAiming(playerid) {
	new anim = GetPlayerAnimationIndex(playerid);
	if (((anim >= 1160) && (anim <= 1163)) || (anim == 1167) || (anim == 1365) || (anim == 1643) || (anim == 1453) || (anim == 220)) return 1;
	return 0;
}

//Teleport system
SetPlayerPosition(playerid, Place_Name[], World, Int, Float: X, Float: Y, Float: Z, Float: R = 0.0) {
	SetPlayerInterior(playerid, Int);
	SetPlayerVirtualWorld(playerid, World);

	SetPlayerPos(playerid, X, Y, Z);
	SetPlayerFacingAngle(playerid, R);

	if (!isnull(Place_Name)) {
		new string[50];
		format(string, sizeof(string), "%s", Place_Name);
		GameTextForPlayer(playerid, string, 5000, 1);
	}
	return 1;
}

//Illegal vehicle models

iswheelmodel(modelid) {
	new wheelmodels[17] = {1025,1073,1074,1075,1076,1077,1078,1079,1080,1081,1082,1083,1084,1085,1096,1097,1098};
	for(new i = 0, b = sizeof(wheelmodels); i != b; i++) {
		if (modelid == wheelmodels[i])
			return true;

	}
	return false;
}

IllegalCarNitroIde(carmodel) {
	new illegalvehs[29] = { 581, 523, 462, 521, 463, 522, 461, 448, 468, 586, 509, 481, 510, 472, 473, 493, 595, 484, 430, 453, 452, 446, 454, 590, 569, 537, 538, 570, 449 };
	for (new i = 0, b = sizeof(illegalvehs); i != b; i++) {
		if (carmodel == illegalvehs[i])
			return true;
	}
	return false;
}

stock illegal_nos_vehicle(PlayerID) {
	new carid = GetPlayerVehicleID(PlayerID);
	new playercarmodel = GetVehicleModel(carid);
	return IllegalCarNitroIde(playercarmodel);

}

islegalcarmod(vehicleide, componentid) {
	new modok = false;

	if ((iswheelmodel(componentid)) || (componentid == 1086) || (componentid == 1087) || ((componentid >= 1008) && (componentid <= 1010))) {
		new nosblocker = IllegalCarNitroIde(vehicleide);
		if (!nosblocker) {
			modok = true;
		}
	} else {
		for (new i = 0, b = sizeof(legalmods); i != b; i++) {
			if (legalmods[i][0] == vehicleide) {
				for (new j = 1; j < 22; j++) {
					if (legalmods[i][j] == componentid) {
						modok = true;
						break;
					}
				}
			}
		}
	}
	return modok;
}

//Quicksort

QuickSort_Pair(array[][2], bool:desc, left, right) {
	new
		tempLeft = left,
		tempRight = right,
		pivot = array[(left + right) / 2][PAIR_FIST],
		tempVar
	;
	while (tempLeft <= tempRight) {
		if (desc) {
			while (array[tempLeft][PAIR_FIST] > pivot) {
				tempLeft++;
			}
			while (array[tempRight][PAIR_FIST] < pivot) {
				tempRight--;
			}
		}
		else
		{
			while (array[tempLeft][PAIR_FIST] < pivot) {
				tempLeft++;
			}
			while (array[tempRight][PAIR_FIST] > pivot) {
				tempRight--;
			}
		}

		if (tempLeft <= tempRight) {
			tempVar = array[tempLeft][PAIR_FIST];
			array[tempLeft][PAIR_FIST] = array[tempRight][PAIR_FIST];
			array[tempRight][PAIR_FIST] = tempVar;

			tempVar = array[tempLeft][PAIR_SECOND];
			array[tempLeft][PAIR_SECOND] = array[tempRight][PAIR_SECOND];
			array[tempRight][PAIR_SECOND] = tempVar;

			tempLeft++;
			tempRight--;
		}
	}
	if (left < tempRight) {
		QuickSort_Pair(array, desc, left, tempRight);
	}
	if (tempLeft < right) {
		QuickSort_Pair(array, desc, tempLeft, right);
	}
}

//Health

ReturnHealth(playerid) {
	new Float: HP;
	GetPlayerHealth(playerid, HP);

	new floatr;
	floatr = floatround(HP, floatround_ceil);
	return floatr;
}

//XYZ

GetXYZInfrontOfCar(vehicleid, &Float:x, &Float:y, Float:distance) {
	if (IsValidVehicle(vehicleid)) {
		new Float:a;

		GetVehiclePos(vehicleid, x, y, a);
		GetVehicleZAngle(vehicleid, a);

		x += (distance * floatsin(-a, degrees));
		y += (distance * floatcos(-a, degrees));
	}
}

GetXYZInfrontOfPlayer(playerid, &Float:x, &Float:y, Float:distance) {
	new Float:a;

	GetPlayerPos(playerid, x, y, a);
	GetPlayerFacingAngle(playerid, a);

	x += (distance * floatsin(-a, degrees));
	y += (distance * floatcos(-a, degrees));
}

GetXYZInfrontOfAAC(AAC, &Float:x, &Float:y, Float:distance) {
	if (IsValidVehicle(AACInfo[AAC][AAC_Id])) {	
		new Float:a;

		GetVehiclePos(AACInfo[AAC][AAC_Id], x, y, a);
		GetVehicleZAngle(AACInfo[AAC][AAC_Id], a);

		x += (distance * floatsin(-a, degrees));
		y += (distance * floatcos(-a, degrees));
	}	
}

//Tune cars

Tuneacar(VehicleID) {
	AddVehicleComponent(VehicleID, 1010);
	AddVehicleComponent(VehicleID, 1087);
	AddVehicleComponent(VehicleID, 1057);
	AddVehicleComponent(VehicleID, 1086);

	ChangeVehicleColor(VehicleID, 0, 0);
	return 1;
}

CarSpawner(playerid, model) {
	if (IsPlayerInAnyVehicle(playerid)) return Text_Send(playerid, $CLIENT_260x);

	new Float:x, Float:y, Float:z, Float:angle;
	GetPlayerPos(playerid, x, y, z);

	GetPlayerFacingAngle(playerid, angle);

	if (PlayerInfo[playerid][pCar] != -1) DestroyVehicle(PlayerInfo[playerid][pCar]);
	PlayerInfo[playerid][pCar] = -1;
	new vehicleid = CreateVehicle(model, x, y, z, angle, -1, -1, -1);

	if (PlayerInfo[playerid][pDeathmatchId] == -1) {
		SetVehicleVirtualWorld(vehicleid, GetPlayerVirtualWorld(playerid));
		LinkVehicleToInterior(vehicleid, GetPlayerInterior(playerid));
		ChangeVehicleColor(vehicleid, 0, 0);
	}
	else
	{
		SetVehicleVirtualWorld(vehicleid, 405);
		LinkVehicleToInterior(vehicleid, DMInfo[PlayerInfo[playerid][pDeathmatchId]][DM_INT]);
	}

	if (model == 411 && PlayerInfo[playerid][pDonorLevel] >= 4) {
		SetVehicleNumberPlate(vehicleid, "V.I.P");
	}

	pVehId[playerid] = PlayerInfo[playerid][pCar] = vehicleid;
	PutPlayerInVehicle(playerid, vehicleid, 0);

	new query[150];
	mysql_format(Database, query, sizeof(query), "INSERT INTO `VehicleSpawns` (`Player`, `VehId`, `VehModel`, `ActionDate`) VALUES ('%e', '%d', '%d', '%d')", PlayerInfo[playerid][PlayerName], vehicleid, GetVehicleModel(vehicleid), gettime());
	mysql_tquery(Database, query);

	printf("Car spawn: %s[%d] - model: %s[%d] ID: %d", PlayerInfo[playerid][PlayerName], playerid, VehicleNames[model-400], model, vehicleid);
	return 1;
}

CarDeleter(vehicleid) {
	if (!IsValidVehicle(vehicleid)) return 0;

	foreach (new i: Player) {
		new Float:X,Float:Y,Float:Z;
		if (IsPlayerInVehicle(i, vehicleid)) {
			GetPlayerPos(i, X, Y, Z);
			SetPlayerPos(i, X, Y + 3, Z);
			if (PlayerInfo[i][pCar] == vehicleid) {
				PlayerInfo[i][pCar] = -1;
			}
		}
		SetVehicleParamsForPlayer(vehicleid, i, 0, 1);
	}

	KillTimer(KillCar[vehicleid]);
	KillCar[vehicleid] = SetTimerEx("EraseCar", 2500, false, "i", vehicleid);
	printf("Vehicle %d was deleted.", vehicleid);    
	return 1;
}

//Money related

GivePlayerCash(playerid, amount) {
	pMoney[playerid] += amount;
	GivePlayerMoney(playerid, amount);
	
	if (GetPlayerMoney(playerid) > pMoney[playerid]) {
		new difference = GetPlayerMoney(playerid) - pMoney[playerid];
		GivePlayerMoney(playerid, -difference);
	}

	if (pMoney[playerid] < 0) {
		pMoney[playerid] = 0;
	}

	if (amount > 0) {
		PlayerInfo[playerid][pCashAdded] += amount;
	} else {
		PlayerInfo[playerid][pCashReduced] += -amount;
	}
	return 1;
}

ResetPlayerCash(playerid) {
	pMoney[playerid] = 0;
	ResetPlayerMoney(playerid);
	return 1;
}

GetPlayerCash(playerid) {
	return pMoney[playerid];
}

//Weapons

GetWeaponPriceById(weaponid) {
	for (new i = 0; i < sizeof(WeaponInfo); i++) {
		if (weaponid == WeaponInfo[i][Weapon_Id]) {
			return WeaponInfo[i][Weapon_Price];
		}
	}
	return 0;
}

GetWeaponAmmoById(weaponid) {
	for (new i = 0; i < sizeof(WeaponInfo); i++) {
		if (weaponid == WeaponInfo[i][Weapon_Id]) {
			return WeaponInfo[i][Weapon_Ammo];
		}
	}
	return 0;
}

//Playtime

CountPlayedTime(playerid, &d, &h, &m, &s) {
	new seconds = (gettime() - PlayerInfo[playerid][pPlayTick]) + PlayerInfo[playerid][pTimePlayed];

	d = (seconds / 86400);
	h = (seconds / 3600);
	m = (seconds / 60 % 60);
	s = (seconds % 60);
}

RecountPlayedTime(playerid) {
	new seconds = (gettime() - PlayerInfo[playerid][pPlayTick]) + PlayerInfo[playerid][pTimePlayed];

	PlayerInfo[playerid][ppSessionDeathsays] = (seconds / 86400);
	PlayerInfo[playerid][pSessionHours] = (seconds / 3600);
	PlayerInfo[playerid][pSessionMins] = (seconds / 60 % 60);
}

//Score

GivePlayerScore(playerid, Score) {
	if ((GetPlayerScore(playerid) + Score) >= 0) {
		SetPlayerScore(playerid, GetPlayerScore(playerid) + Score);
	} else {
		SetPlayerScore(playerid, 0);
	}

	if (IsPlayerSpawned(playerid)) {
		if (GetPlayerRank(playerid) > PlayerRank[playerid]) {
			PlayerRank[playerid] = GetPlayerRank(playerid);
			Text_Send(playerid, $CLIENT_261x);
			PlayAudioStreamForPlayer(playerid, "http://51.254.181.90/server/progress.mp3", 0.0, 0.0, 0.0, 0.0, 0);
		}
		else if (GetPlayerRank(playerid) < PlayerRank[playerid]) {
			PlayerRank[playerid] = GetPlayerRank(playerid);
			Text_Send(playerid, $CLIENT_262x);
			PlayAudioStreamForPlayer(playerid, "http://51.254.181.90/server/progress.mp3", 0.0, 0.0, 0.0, 0.0, 0);
		}
	}    

	UpdatePlayerHUD(playerid);
	return 1;
}

//Countdown

forward StartCount(cdValue);
public StartCount(cdValue) {
	if (counterOn == 1) {
		if (counterValue > 0) {
			new text[10];
			format(text, sizeof(text), "~w~%d", counterValue);

			counterValue--;

			GameTextForAll(text, 1000, 3);

		} else {

			KillTimer(counterTimer);

			counterValue = -1;
			counterOn = 0;

			GameTextForAll("~r~GO!", 1000, 3);

		}
	}    
	return 1;
}

//End of File
/* (c) H2O Multiplayer 2018-2020. All rights reserved. */