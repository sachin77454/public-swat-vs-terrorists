#define         MAX_VEHICLE_ID_CHANGES          5

static LastVehicleID[MAX_PLAYERS];
static VehicleIDChanges[MAX_PLAYERS];
static VehicleIDChangeTime[MAX_PLAYERS];

forward OnAntiCheatLagTroll(playerid);

public OnPlayerUpdate(playerid)
{
    new vid = GetPlayerVehicleID(playerid);
    if(vid > 0)
    {
        if(vid != LastVehicleID[playerid])
        {
            if(GetTickCount() - VehicleIDChangeTime[playerid] < 5000)
            {
                VehicleIDChanges[playerid]++;
                if(VehicleIDChanges[playerid] > MAX_VEHICLE_ID_CHANGES)
                {
                    CallLocalFunction("OnAntiCheatLagTroll", "i", playerid);
                    return 0;
                }
            }
            else VehicleIDChanges[playerid] = 1;
        }
        LastVehicleID[playerid] = vid;
        VehicleIDChangeTime[playerid] = GetTickCount();
    }

    if (funcidx("AntiLT_OnPlayerUpdate") != -1)
    {
        return CallLocalFunction("AntiLT_OnPlayerUpdate", "i", playerid);
    }
    return 1;
}

#if defined _ALS_OnPlayerUpdate
    #undef OnPlayerUpdate
#else
    #define _ALS_OnPlayerUpdate
#endif
#define OnPlayerUpdate AntiLT_OnPlayerUpdate

forward AntiLT_OnPlayerUpdate(playerid);
