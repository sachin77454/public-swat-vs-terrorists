// Anti connection spoofing patch by [uL]Pottus

forward OnAntiCheatPlayerSpoof(playerid);

static bool:PlayerConnected[MAX_PLAYERS];
static PlayerNames[MAX_PLAYERS][MAX_PLAYER_NAME];

public OnPlayerConnect(playerid)
{
	// User was already connected cheat detected
	if(PlayerConnected[playerid])
	{
		SetPlayerName(playerid, PlayerNames[playerid]);
		CallLocalFunction("OnAntiCheatPlayerSpoof", "i", playerid);
		return 1;
	}
	else
	{
		GetPlayerName(playerid, PlayerNames[playerid], MAX_PLAYER_NAME);
		PlayerConnected[playerid] = true;
	}

	if (funcidx("AntiSpoof_OnPlayerConnect") != -1)
  	{
    	return CallLocalFunction("AntiSpoof_OnPlayerConnect", "i", playerid);
  	}
  	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	PlayerConnected[playerid] = false;

	if (funcidx("AntiSpoof_OnPlayerDisconnect") != -1)
  	{
    	return CallLocalFunction("AntiSpoof_OnPlayerDisconnect", "ii", playerid, reason);
  	}
  	return 1;
}


#if defined _ALS_OnPlayerConnect
	#undef OnPlayerConnect
#else
	#define _ALS_OnPlayerConnect
#endif
#define OnPlayerConnect AntiSpoof_OnPlayerConnect

forward AntiSpoof_OnPlayerConnect(playerid);

#if defined _ALS_OnPlayerDisconnect
	#undef OnPlayerDisconnect
#else
	#define _ALS_OnPlayerDisconnect
#endif
#define OnPlayerDisconnect AntiSpoof_OnPlayerDisconnect

forward AntiSpoof_OnPlayerDisconnect(playerid, reason);