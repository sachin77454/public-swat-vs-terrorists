/*
	█▀▀ █░░░█ █▀▀█ ▀▀█▀▀   ▀█░█▀ █▀▀   ▀▀█▀▀ █▀▀ █▀▀█ █▀▀█ █▀▀█ █▀▀█ ░▀░ █▀▀ ▀▀█▀▀ █▀▀
	▀▀█ █▄█▄█ █▄▄█ ░░█░░   ░█▄█░ ▀▀█   ░░█░░ █▀▀ █▄▄▀ █▄▄▀ █░░█ █▄▄▀ ▀█▀ ▀▀█ ░░█░░ ▀▀█
	▀▀▀ ░▀░▀░ ▀░░▀ ░░▀░░   ░░▀░░ ▀▀▀   ░░▀░░ ▀▀▀ ▀░▀▀ ▀░▀▀ ▀▀▀▀ ▀░▀▀ ▀▀▀ ▀▀▀ ░░▀░░ ▀▀▀

	SWAT vs Terrorists is a team death-match SA-MP game-mode script.
	Compatible with SA-MP 0.3.7 and later releases.

	Author: H2O
	Licensed under GNU GPLv3

	(c) 2018-2020 H2O Multiplayer. All rights reserved.
	Website: h2omultiplayer.com
*/

//Viva la samp!
#include <a_samp>

//Redefine maximum players...
#undef MAX_PLAYERS
#define MAX_PLAYERS 100

//Debug
#include <crashdetect> //Zeex

//Manage server variables
#define MODE_NAME "svtsamp"
#include <YSI_Storage\y_svar>

enum e_svtconf {
	max_admin_level,
	kick_bad_nicknames,
	anti_spam,
	anti_swear,
	anti_caps,
	server_open,
	read_admin_cmds,
	disable_chat,
	read_player_cmds,
	anti_adv,
	read_pms,
	max_ping,
	max_ping_kick,
	max_warns,
	max_duel_bets,
	safe_restart,
	server_owner[MAX_PLAYER_NAME]
};
svar svtconf[e_svtconf]; //Doesn't work

//Configure the game

main() {}

//Include the main files

#include "server/header.pwn"
#include "server/database.pwn" //Establish database connection
#include "server/init.pwn"
#include "players/header.pwn"
#include "server/tasks.pwn"

//Include the top-level functions and hooks

#include "coding/hooks.pwn" //Hooked common functions and callbacks
#include "coding/functions.pwn" //Common functions

//Include the map modules

#include "server/server-maps.pwn" //Create server map in a separate module
#include "server/bunker-map.pwn" //Create bunker map in a separate module

//Admin system
#include "players/admin.pwn"

//Init player main modules
#include "players/init.pwn"
#include "players/anti-cheat.pwn"
#include "players/ui.pwn"
#include "players/exit.pwn"
#include "players/reset.pwn"
#include "players/sync.pwn"
#include "players/pickups.pwn"
#include "players/vehicles.pwn"
#include "players/update.pwn"
#include "players/states.pwn"
#include "players/damage.pwn"
#include "players/death.pwn"
#include "players/chat.pwn"
#include "players/commands.pwn"

//Server authentication for players
#include "players/auth/email.pwn"
#include "players/auth.pwn" //Player authentication system

//Other systems will be included below
//#include <>
#include "players/teams.pwn"
#include "players/classes.pwn"
#include "players/spawn.pwn"
#include "players/inventory.pwn"
#include "players/stats.pwn"
#include "players/events.pwn"
#include "players/pubg.pwn"
#include "players/zones.pwn"
#include "players/toys.pwn"
#include "players/premium.pwn"
#include "players/duels.pwn"
#include "players/crates.pwn"
#include "players/races.pwn"
#include "players/clans.pwn"
#include "players/deathmatch.pwn"
#include "players/discord.pwn"
#include "players/time.pwn"
#include "players/votekick.pwn"
#include "players/airstrike.pwn"
#include "players/ranks.pwn"
#include "players/notifiers.pwn"
#include "players/tasks.pwn"
#include "players/config.pwn"

//Modified dependencies
#include <Knife> //By AbyssMorgan, synced with players/teams.pwn

//Miscellaneous
#include "players/miscellaneous.pwn"

//End of File
/* (c) H2O Multiplayer 2018-2020. All rights reserved. */