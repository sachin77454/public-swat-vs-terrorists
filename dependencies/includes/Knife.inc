/****************************************************************************************************
 *                                                                                                  *
 *                                        Knife Shoot Script                                        *
 *                                                                                                  *
 * Copyright � 2019 Abyss Morgan. All rights reserved.                                              *
 * Contributors: Katarina Calzaghe                                                                  *
 *                                                                                                  *
 * Website:  adm.ct8.pl                                                                             *
 * Download: adm.ct8.pl/r/download                                                                  *
 *                                                                                                  *
 * Plugins: Streamer, ColAndreas                                                                    *
 * Modules: 3DTryg                                                                                  *
 *                                                                                                  *
 * File Version: 2.6.1                                                                              *
 * Streamer Version: 2.9.4                                                                          *
 * ColAndreas Version: 1.4.0                                                                        *
 * 3DTryg Version: 4.7.1X                                                                           *
 *                                                                                                  *
 * Functions:                                                                                       *
 * ToggleUseTeamKnifeShoot(bool:toggle);            //default: false                                *
 * bool:IsToggleUseTeamKnifeShoot();                                                                *
 * ToggleKnifeShootForAll(bool:toggle);             //default: true                                 *
 * bool:IsToggleKnifeShootForAll();                                                                 *
 * ToggleKnifeShootForPlayer(playerid,bool:toggle); //default: false                                *
 * bool:IsToggleKnifeShootForPlayer(playerid);                                                      *
 * Float:GetKnifeShootDamage(playerid);                                                             *
 * SetKnifeShootDamage(playerid,Float:amount);                                                      *
 * Float:GetKnifeShootSpeed(playerid);                                                              *
 * SetKnifeShootSpeed(playerid,Float:speed);                                                        *
 * Float:GetKnifeShootRange(playerid);                                                              *
 * SetKnifeShootRange(playerid,Float:range);                                                        *
 * GetKnifeShootAmmo(playerid);                                                                     *
 * SetKnifeShootAmmo(playerid,ammo);                                                                *
 *                                                                                                  *
 * Callbacks:                                                                                       *
 * OnPlayerRequestKnifeShot(playerid,targetid);                                                     *
 *                                                                                                  *
 ****************************************************************************************************/

#if defined _knife_shot
	#endinput
#endif
#define _knife_shot
#define DYNAMIC_FILTERSCRIPT				"ALS:HOOK:METHOD"

#if defined _samp_included
	#if (!defined GetPlayerPoolSize || !defined GetSVarInt)
		#error [ADM] This include requires SA:MP version 0.3.7 (adm.ct8.pl/r/download)
	#endif
#else
	#error [ADM] This include requires SA:MP Include
#endif

#if ((!defined Streamer_GetItemPos) || (!defined INVALID_STREAMER_ID) || (!defined STREAMER_TYPE_ACTOR))
	#error [ADM] You need Streamer v2.9.4 (github.com/samp-incognito/samp-streamer-plugin/releases)
#endif

#if !defined COLANDREAS
	#error [ADM] You need ColAndreas v1.4.0 (github.com/Pottus/ColAndreas/releases)
#endif


//Check Version 3DTryg.inc
#if !defined TRYG3D_SAMP_INCLUDE
	#error [ADM] You need 3DTryg.inc v4.7.1X (adm.ct8.pl/d/3DTryg.inc)
#elseif !defined TRYG3D_VERSION
	#error [ADM] Update you 3DTryg.inc to v4.7.1X (adm.ct8.pl/d/3DTryg.inc)
#elseif (TRYG3D_VERSION < 40701)
	#error [ADM] Update you 3DTryg.inc to v4.7.1X (adm.ct8.pl/d/3DTryg.inc)
#endif

#define KNIFE_SPEED 						(20.0)
#define KNIFE_MAX_RADIUS					(15.0)
#define KNIFE_REFRESH_ACTION				(7000)	//7 sec
#define KNIFE_REFRESH_MISS					(5000)	//5 sec
#define KNIFE_DAMAGE						(27.2)
#define KNIFE_WEAPON_AMMO_INFINITY			(-1)

new KnifeLockTarget[MAX_PLAYERS],
	KnifeTime[MAX_PLAYERS],
	Float:KnifeShootDamage[MAX_PLAYERS],
	Float:KnifeShootSpeed[MAX_PLAYERS],
	Float:KnifeShootRange[MAX_PLAYERS],
	KnifeShootAmmo[MAX_PLAYERS],
	bool:KnifeEnabledForPlayer[MAX_PLAYERS],
	bool:KnifeEnabledForAll = true;

#define ToggleKnifeShootForAll(%0)			KnifeEnabledForAll = (%0)
#define IsToggleKnifeShootForAll()			KnifeEnabledForAll
#define ToggleKnifeShootForPlayer(%0,%1)	KnifeEnabledForPlayer[(%0)] = (%1)
#define IsToggleKnifeShootForPlayer(%0)		KnifeEnabledForPlayer[(%0)]
#define GetKnifeShootDamage(%0)				KnifeShootDamage[(%0)]
#define SetKnifeShootDamage(%0,%1)			KnifeShootDamage[(%0)] = (%1)
#define GetKnifeShootSpeed(%0)				KnifeShootSpeed[(%0)]
#define SetKnifeShootSpeed(%0,%1)			KnifeShootSpeed[(%0)] = (%1)
#define GetKnifeShootRange(%0)				KnifeShootRange[(%0)]
#define SetKnifeShootRange(%0,%1)			KnifeShootRange[(%0)] = (%1)
#define GetKnifeShootAmmo(%0)				KnifeShootAmmo[(%0)]
#define SetKnifeShootAmmo(%0,%1)			KnifeShootAmmo[(%0)] = (%1)

#if defined OnPlayerRequestKnifeShot
	forward OnPlayerRequestKnifeShot(playerid,targetid);
#endif

T3D:function KnifeShot(playerid) {
	new Float:mx, Float:my, Float:mz, Float:mrz, Float:mtx, Float:mty, Float:mtz, mvw, mint, Float:trz,
		Float:px, Float:py, Float:pz, mtime, Float:dist;
	GetPlayerPos(playerid,mx,my,mz);
	GetPlayerFacingAngle(playerid,mrz);
	mvw = GetPlayerVirtualWorld(playerid);
	mint = GetPlayerInterior(playerid);
	GetPointInFront2D(mx,my,mrz,GetKnifeShootRange(playerid),mtx,mty);
	KnifeLockTarget[playerid] = INVALID_PLAYER_ID;
	new Float:ldist = 20000;
	
	Tryg3D::Foreach(i){
		if(i != playerid) {
			if(Tryg3D::IsPlayerSpawned(i)){
				GetPlayerPos(i,px,py,pz);
				if(GetPlayerVirtualWorld(i) == mvw && GetPlayerInterior(i) == mint){
					if(Area::PointInCylinder3D(px,py,pz, mx,my,mz, mtx,mty,mz, 2.0)){
						if((dist = GetDistanceBetweenPoints3D(px,py,pz,mx,my,mz)) < ldist){
							ldist = dist;
							KnifeLockTarget[playerid] = i;
						}
					}
				}
			}
		}
	}
	
	#if defined OnPlayerRequestKnifeShot
		if(!OnPlayerRequestKnifeShot(playerid,KnifeLockTarget[playerid])) return INVALID_PLAYER_ID;
	#endif
	
	if(GetKnifeShootAmmo(playerid) != KNIFE_WEAPON_AMMO_INFINITY){
		if(GetKnifeShootAmmo(playerid) <= 0) return 1;
		SetKnifeShootAmmo(playerid,GetKnifeShootAmmo(playerid)-1);
	}
	
	if(KnifeLockTarget[playerid] == INVALID_PLAYER_ID){
		trz = Tryg3D::CompressRotation(mrz+90.0);
		new tmpobj = CreateDynamicObject(335,mx,my,mz,0.0,90.0,trz,mvw,mint,-1);
		GetPointInFront3DCol(mx,my,mz,356.7,mrz,GetKnifeShootRange(playerid),mtx,mty,mtz);		
		GetMoveTime(mx,my,mz,mtx,mty,mtz,GetKnifeShootSpeed(playerid),mtime);
		MoveDynamicObject(tmpobj,mtx,mty,mtz,GetKnifeShootSpeed(playerid),0.0,110.0,trz);
		SetTimerEx("KnifeDestroy",mtime+KNIFE_REFRESH_MISS,0,"ddd",tmpobj,INVALID_PLAYER_ID,playerid);
	} else {
		GetPlayerPos(KnifeLockTarget[playerid],px,py,pz);
		GetRotationFor2Point2D(mx,my,px,py,trz);
		trz = Tryg3D::CompressRotation(trz+90.0);
		new tmpobj = CreateDynamicObject(335,mx,my,mz,0.0,90.0,trz,mvw,mint,-1);
		GetMoveTime(mx,my,mz,px,py,pz,GetKnifeShootSpeed(playerid),mtime);
		MoveDynamicObject(tmpobj,px,py,pz,GetKnifeShootSpeed(playerid),0.0,90.0,trz);
		SetTimerEx("KnifeDestroy",mtime,0,"ddd",tmpobj,KnifeLockTarget[playerid],playerid);
	}
	KnifeTime[playerid] = GetTickCount() + KNIFE_REFRESH_ACTION;
	return KnifeLockTarget[playerid];
}

T3D:function KnifeDestroy(objectid,targetid,playerid){
	if(IsValidDynamicObject(objectid)) DestroyDynamicObject(objectid);
	if(targetid != INVALID_PLAYER_ID &&
			pTeam[playerid] != pTeam[targetid]){
		DamagePlayer(targetid, GetKnifeShootDamage(playerid), playerid, 4, BODY_PART_UNKNOWN, true);
		ApplyAnimation(targetid,"ped","SHOT_partial",4.1,0,1,1,1,1,1);
	}
	return 1;
}

T3D:function KnifeInit(){
	for(new i = 0; i < MAX_PLAYERS; i++){
		SetKnifeShootDamage(i,KNIFE_DAMAGE);
		SetKnifeShootSpeed(i,KNIFE_SPEED);
		SetKnifeShootRange(i,KNIFE_MAX_RADIUS);
		SetKnifeShootAmmo(i,KNIFE_WEAPON_AMMO_INFINITY);
	}
}

new CRC_KnifeInit = true;

//Hook: OnPlayerKeyStateChange
public OnPlayerKeyStateChange(playerid,newkeys,oldkeys){
	if(IsToggleKnifeShootForAll() || IsToggleKnifeShootForPlayer(playerid)){
		if((newkeys & KEY_FIRE | KEY_HANDBRAKE)
			&& GetPlayerState(playerid) == PLAYER_STATE_ONFOOT && GetPlayerWeapon(playerid) == WEAPON_KNIFE && GetTickCount() > KnifeTime[playerid]){
			KnifeShot(playerid);
		}
	}
	#if defined Knife_OnPlayerKeyStateChange
		Knife_OnPlayerKeyStateChange(playerid,newkeys,oldkeys);
	#endif
	return 1;
}

#if defined _ALS_OnPlayerKeyStateChange
	#undef OnPlayerKeyStateChange
#else
	#define _ALS_OnPlayerKeyStateChange
#endif
#define OnPlayerKeyStateChange Knife_OnPlayerKeyStateChange
#if defined Knife_OnPlayerKeyStateChange
	forward Knife_OnPlayerKeyStateChange(playerid,newkeys,oldkeys);
#endif

//Hook: OnFilterScriptInit
public OnFilterScriptInit(){
	if(CRC_KnifeInit){
		CRC_KnifeInit = false;
		KnifeInit();
	}
	#if defined Knife_OnFilterScriptInit
		Knife_OnFilterScriptInit();
	#endif
	return 1;
}

#if defined _ALS_OnFilterScriptInit
	#undef OnFilterScriptInit
#else
	#define _ALS_OnFilterScriptInit
#endif
#define OnFilterScriptInit Knife_OnFilterScriptInit
#if defined Knife_OnFilterScriptInit
	forward Knife_OnFilterScriptInit();
#endif

//Hook: OnGameModeInit
public OnGameModeInit(){
	if(CRC_KnifeInit){
		CRC_KnifeInit = false;
		KnifeInit();
	}
	#if defined Knife_OnGameModeInit
		Knife_OnGameModeInit();
	#endif
	return 1;
}

#if defined _ALS_OnGameModeInit
	#undef OnGameModeInit
#else
	#define _ALS_OnGameModeInit
#endif
#define OnGameModeInit Knife_OnGameModeInit
#if defined Knife_OnGameModeInit
	forward Knife_OnGameModeInit();
#endif

//EOF