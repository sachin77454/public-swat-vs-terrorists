/*
	SWAT vs Terrorists is a team death-match SA-MP game-mode script. 
	Compatible with SA-MP 0.3.7 and later releases.

	Author: H2O
	Licensed under GNU GPLv3

	(c) 2018-2020 H2O Multiplayer. All rights reserved.
	Website: h2omultiplayer.com
*/

#if defined SERVER_HEADER_INCLUDED
	#endinput
#endif
#define SERVER_HEADER_INCLUDED

//-----------
//Includes

//First Tier Anti Cheat
#include <antilag> //Pottus & Southclaws
#include <antispoof> //Pottus & Southclaws
#include <OPBA> //RogueDrifter
#include <rAsc> //RogueDrifter

//Anti Aimbot
#define BUSTAIM_MAX_PL_PERCENTAGE           30.0
#define BUSTAIM_PROAIM_TELEPORT_PROBES      1
#define BUSTAIM_RANDOM_AIM_PROBES           3
#define BUSTAIM_MAX_CONTINOUS_SHOTS         10
#define BUSTAIM_MAX_PING                    450
#define BUSTAIM_SKIP_WEAPON_IDS             38
#include <BustAim> //Yashas

//MySQL Plugin
#include <a_mysql> //BlueG & maddinat0r

//Miscellaneous
#include <sscanf2> //Y_Less
#include <streamer> //Incognito

//YSI Includes
#include <YSI_Coding\y_hooks> //Y_Less
#include <YSI_Data\y_iterate> //Y_Less
#include <YSI_Server\y_colors> //Y_Less

#include <YSI_Players\y_languages> //Y_Less
#include <YSI_Visual\y_dialog> //Y_Less
//#include <YSI\y_flooding> //Y_Less

#define MASTER 14
#include <YSI\y_master>

//Damage System
#include <weapon-config> //Slice

//Anti Cheat
#include <anti-weapon> //Lorenc_
#include <anti-fly> //Lorenc_

//urShadow
#include <Pawn.CMD> //urShadow
#include <Pawn.Regex> //urShadow
#include <Pawn.RakNet> //urShadow

//Collisions
#include <ColAndreas> //Pottus & Crayder

//UI
#include <mselection> //d0

//Gangzones
#include <gz_shapes> // R2D

//Progress bars
#include <progress2> //Southclaws

//Name text highlighting / mention system
#include <HN> //jlalt

//Timestamp
#include <timestamp> //Crayder

//3DTryg for projectiles
#define ENABLE_3D_TRYG_YSI_SUPPORT
#include <3DTryg> //AbyssMorgan

//Knife System
//#include <Knife> //AbyssMorgan

//Discord
//#define BOT_NAME 					"Modernizer"
//#define CHANNEL_STAFF_NAME 			"modernizer"
//#define CHANNEL_PAYMENTS_NAME		"payments"
//#define CMD_PREFIX                  "!"
#include <dcc>

//Set information
#define WEBSITE 		            "h2omultiplayer.com"
#define BUILD      		            "v12.5"

//Define command types
#define CMD_SECRET 					(1)
#define CMD_ADMIN  					(2)
#define CMD_MOD  					(3)
#define CMD_SYSTEM					(4)

//Limits

#define MAX_CHECKPOINTS             (150) //Maximum no. of race checkpoints (may be used for spawn points too)
#define MAX_SLOTS 	      		    (500) //Maximum no. of dynamic slots for various server features
#define MAX_ITEMS    		        (11) //Maximum no. of items a player can have
#define MAX_REPORTS 			    (10) //Maximum reports to display in /reports
#define MAX_MESSAGES                (7) //Spammy messages limit
#define SPAM_TIMELIMIT              (8) //Spam cooldown time limit in seconds
#define MAX_MENU_TEXTDRAWS 		    (100) //Inventory maximum no. of textdraws
#define MAX_MENU_PLAYER_TEXTDRAWS   (100) //Inventory maximum no. of per player textdraws
#define MAX_RIGHT_MENU_COLUMNS 	    (5) //Inventory right menu colums limit
#define MAX_RIGHT_MENU_ROWS 	    (3) //Inventory right menu rows limit
#define MAX_LEFT_MENU_ROWS 		    (7) //Invetory left menu limit
#define MAX_ITEM_NAME 			    (64) //Maximum length of item names
#define MAX_FORBIDS 				(100) //Maximum no. of forbidden words and names
#define MAX_ROPES 					(50) //Rope rappelling maximum no. of ropes
#define MAX_TEAMS 					(3) //Maximum no. of teams
#define MAX_CLANS 					(100) //Maximum no. of clans that can be loaded at one time

//Team definitions

#define TERRORIST 					(0)
#define SWAT 	  					(1)
#define VIP 	  					(2)

//Class definitions

#define ASSAULT 					(0)
#define SNIPER 						(1)
#define MECHANIC	    			(2)
#define JETTROOPER 					(3)
#define MEDIC 						(4)
#define SPY 						(5)
#define GUNNER 						(6)
#define DEMOLISHER 					(7)
#define SCOUT		    			(8)
#define SUICIDER        			(9)
#define PILOT           			(10)
#define RECON           			(11)
#define CUSTODIAN					(12)
#define KAMIKAZE        			(13)
#define SUPPORT         			(14)

//Zones that provide players with spawn perks

#define MEDKIT_ZONE					(26) //Hospital
#define HELMET_ZONE					(6) //Sniperhut

//Zones that are used in a system or multiple systems

#define SNIPERHUT  		 			(6)
#define NUKE_STATION	 			(18)
#define LV_AIR 			 			(0)
#define WEAPONDEPOT	  	 			(20)
#define AMMODEPOT	  	 			(12)
#define DESERTCAMP       			(9)
#define BATTLESHIP       			(16)
#define HOSPITAL   		 			(26)
#define RECHARGEPOINT    			(22)

//Inventory definitions

#define HELMET    		 			(0)
#define MASK      				 	(1)
#define MK        	 	 			(2)
#define AK        	     			(3)
#define PL     			 			(4)
#define SK           	 			(5)
#define LANDMINES        			(6)
#define DYNAMITE         			(7)
#define TOOLKIT          			(8)
#define JETPACK          			(9)
#define PYROKIT          			(10)

#define WEAPONSLOT       			MAX_ITEMS

//System color definitions

#define COLOR_TOMATO 				0xFF6347FF
#define COL_TOMATO 		 			"{FF6347}"

#define COLOR_DEFAULT 	 			0xA9C4E4FF
#define COL_DEFAULT 	 			"{A9C4E4}"

//Admin spectator mode types
#define ADMIN_SPEC_TYPE_NONE      	(0)
#define ADMIN_SPEC_TYPE_PLAYER    	(1)
#define ADMIN_SPEC_TYPE_VEHICLE   	(2)

//Event spawn types
#define EVENT_SPAWN_INVALID    		(-1)
#define EVENT_SPAWN_RANDOM          (0)
#define EVENT_SPAWN_ADMIN           (1)

//Quicksort Pairs
#define PAIR_FIST 					(0)
#define PAIR_SECOND 				(1)

//Virtual Worlds
#define BF_WORLD					(0)
#define LONE_WORLD					(100)
#define DM_WORLD					(201)
#define CW_WORLD					(202)
#define DUEL_WORLD					(203)
#define JAIL_WORLD					(420)
#define PUBG_WORLD					(666)
#define SPECIAL_WORLD				(999)

//Declarations

//Create the MySQL handle
new MySQL: Database;

//Localization

new Language: English;
//new Language: Spanish;

//Admin System

//Admin commands array

enum E_ACMDS_ENUM {
	Adm_Command[40],
	Adm_Level
};

new const ACmds[][E_ACMDS_ENUM] = {
	{"mcmds", 1},
	{"m", 1},
	{"acmds", 1},
	{"ad", 1},
	{"slap", 1},
	{"spec", 1},
	{"specoff", 1},
	{"weaps", 1},
	{"bstats", 1},
 	{"items", 1},
 	{"specs", 1},
	{"breset", 1},
 	{"getinfo", 1},
	{"reports", 1},
	{"warn", 1},
 	{"kick", 1},
	{"answer", 1},
	{"ip", 5},
 	{"rangecheck", 5},
	{"aduty", 1},
	{"adminarea", 1},
	{"miniguns", 1},
	{"hseeks", 1},
	{"mute", 2},
	{"unmute", 2},
	{"muted", 1},
	{"lastseen", 1},
	{"explode", 2},
	{"burn", 2},
	{"afk", 2},
 	{"jail", 2},
	{"unjail", 2},
	{"jailed", 1},
	{"apm", 2},
 	{"customweapons", 1},
	{"ban", 2},
	{"disarm", 3},
	{"eject", 3},
	{"spawn", 2},
	{"asay", 1},
 	{"forcerules", 2},
	{"acar", 2},
 	{"disablecaps", 2},
	{"morning", 2},
	{"jetpack", 2},
	{"rac", 3},
	{"cc", 2},
	{"unban", 4},
	{"offlineban", 3},
	{"ann", 2},
	{"ann2", 2},
	{"screen", 3},
	{"settime", 3},
	{"setweather", 3},
	{"setskin", 4},
 	{"sethealth", 3},
	{"setarmour", 3},
	{"healall", 3},
	{"armourall", 3},
	{"atune", 3},
	{"anos", 3},
	{"afix", 3},
	{"aflip", 3},
	{"hy", 3},
	{"atc", 3},
	{"sv", 3},
	{"get", 4},
	{"goto", 3},
	{"vgoto", 3},
	{"vslap", 3},
	{"aka", 3},
	{"teamwar", 4},
	{"endwar", 4},
	{"destroycar", 2},
	{"abike", 2},
	{"aheli", 2},
	{"aplane", 2},
	{"aboat", 2},
	{"freeze", 2},
	{"unfreeze", 2},
	{"frozen", 1},
	{"setalltime", 3},
	{"setallweather", 3},
	{"aweaps", 3},
	{"aammo", 3},
	{"setcolor", 3},
	{"carhealth", 3},
	{"carcolor", 3},
	{"removewarnings", 3},
	{"lockcar", 2},
	{"unlockcar", 2},
	{"car", 4},
	{"teleplayer", 3},
 	{"force", 2},
	{"forceteam", 3},
	{"banip", 4},
	{"unbanip", 4},
	{"teles", 4},
	{"spubg", 4},
 	{"epubg", 4},
 	{"giveall", 4},
	{"giveallweapon", 3},
	{"giveallscore", 4},
	{"giveallcash", 4},
	{"event", 3},
	{"pufa", 5},
	{"sufa", 5},
	{"vget", 4},
	{"givecar", 3},
	{"giveweapon", 3},
	{"gotozone", 8},
	{"eopen", 3},
	{"estart", 3},
	{"ehealth", 3},
	{"earmour", 3},
	{"eskin", 3},
	{"countdown", 3},
	{"cp", 3},
	{"rheal", 3},
	{"here", 3},
	{"getbans", 3},
	{"getkicks", 3},
	{"getwarns", 3},
	{"getjails", 3},
	{"getfreezes", 3},
	{"getunbans", 3},
	{"getnames", 3},
	{"getmutes", 3},
 	{"setinterior", 3},
	{"setworld", 3},
	{"gwteam", 4},
 	{"gsteam", 4},
	{"gcteam", 4},
	{"fteam", 4},
	{"ufteam", 4},
	{"dteam", 4},
	{"gteam", 4},
	{"steam", 4},
	{"setallworld", 4},
	{"setallinterior", 4},
	{"setscore", 4},
	{"setcash", 4},
	{"setkills", 4},
	{"setakills", 4},
	{"setrevenges", 4},
	{"setacaptures", 4},
	{"setxp", 4},
	{"setdeaths", 4},
	{"setzones", 4},
	{"seths", 4},
	{"setns", 4},
	{"setname", 5},
	{"getall", 5},
	{"spawnall", 5},
	{"killall", 6},
	{"freezeall", 5},
	{"unfreezeall", 5},
	{"disarmall", 5},
	{"explodeall", 5},
	{"slapall", 5},
	{"ejectall", 5},
	{"muteall", 8},
	{"unmuteall", 8},
	{"givescore", 4},
	{"givecash", 4},
	{"osetkills", 5},
	{"osetdeaths", 5},
	{"osetcash", 5},
	{"osetscore", 5},
	{"osetname", 5},
	{"setlevel", 7},
	{"sethelper", 6},
	{"unsethelper", 6},
	{"setpass", 7},
	{"saveallstats", 5},
	{"kickall", 8},
	{"crash", 8},
	{"removeaccount", 8},
	{"forbidword", 8},
	{"unforbidword", 8},
	{"forbidname", 8},
	{"unforbidname", 8},
	{"osethelper", 8},
 	{"osetlevel", 8},
	{"osetvip", 8},
	{"setvip", 7},
 	{"audit", 8},
	{"dv", 8},
	{"kickall", 8},
	{"rclan", 8},
	{"setclanname", 8},
	{"setclantag", 8},
	{"setcoins", 8},
 	{"givecoins", 8},
 	{"setclanweap", 8},
 	{"setclanskin", 8},
	{"setclanwallet", 8},
	{"setclanxp", 8},
	{"giveclanwallet", 8},
	{"giveclanxp", 8},
 	{"acw", 8},
 	{"acwstart", 8},
	{"acwend", 8},
 	{"forcejoincw", 8},
 	{"cwkick", 8},
 	{"cwskip", 8},
 	{"cwgoto", 8},
 	{"cwget", 8},
	{"setping", 8},
	{"setwarns", 8},
	{"setclan", 8},
	{"clankick", 8},
 	{"xyz", 8},
 	{"query", 8},
 	{"gmx", 8},
	{"freehunter", 8}
};

new ForbiddenWords[MAX_FORBIDS][25];
new ForbiddenNames[MAX_FORBIDS][25];

//General textdraws

new Text: Stats_TD[6];
new Text: CarInfoTD[4];
new Text: Box_TD[2];
new Text: Site_TD;
new Text: SvT_TD;
new Text: SvTTD[7];
new Text: DMBox;
new Text: DMText;
new Text: DMText2[4];
new Text: txtTimeDisp; //Time cycle

//Spec UI
new Text: aSpecTD[12];

//PUBG UI

new Text: PUBGAreaTD;
new Text: PUBGKillsTD;
new Text: PUBGAliveTD;
new Text: PUBGKillTD;
new Text: PUBGWinnerTD[5];

//Team System

enum E_TEAM_ENUM {
	Chat_Bub[17],
	Team_Name[45],

	Shop_Color,
	Team_Color,
	Team_Inv_Color,

	Float: Team_MapArea[4],

	Float: Spawn_1[4],
	Float: Spawn_2[4],
	Float: Spawn_3[4],

	Team_Area,
	Team_Gangzone
};

new const TeamInfo[][E_TEAM_ENUM] =
{
	{"~r~~h~~h~", "Terrorists", 0xDC1E1EFF, 0xDC1E1ECC, 0xDC1E1E00, {-497.0, 2120.0, -186.0, 2428.0},
	{-446.1587,2220.5933,51.2160,353.3568}, {-446.2298,2238.6868,51.2160,181.6719}, {-425.0290,2239.4160,51.2160,176.9717}},

	{"~b~~h~~h~", "SWAT", 0x4470ADFF, 0x4470ADFF, 0x4470ADFF, {68.0, 1779.0, 399.0, 2106.0},
    {221.9867,1862.6287,13.1470,91.0086}, {269.2594,1866.2292,17.7414,181.5195}, {273.2289,1951.7023,17.6813,268.0002}},

	{"~g~~h~~h~", "VIP/Donor", 0x5CCD82FF, 0x5CCD82CC, 0x5CCD8200, {-1954.0, 2361.0, -1176.0, 2841.0},
    {-1718.3947,2534.8057,106.0078,0.3778}, {-1717.8120,2500.3445,106.0078,0.0644}, {-1717.8120,2500.3445,106.0078,0.0644}}
};

//Team War
new Text: War_TD;
new Text: War_TDBox;

//Create the team war array
enum WarData {
	War_Team1,
	War_Team2,
	War_Time,
	War_Started,

	Team1_Score,
	Team2_Score
};

new WarInfo[WarData];

//Team war time counter
new war_time = 0;

//===========================
//Shopping
//===========================

enum ShopData {
	Float: Shop_Pos[3],	
	Float: Shop_aPos[4],
	Zone_Id,
	Shop_Id,
	Text3D: Shop_Label,
	Shop_Area
};

new const ShopInfo[][ShopData] =
{
	{{-405.6048,2161.0398,52.7598}},
	{{204.2630,1871.2024,13.1406}},
	{{-1713.8392,2566.6274,106.0078}}
};

//===========================
//Antenna
//===========================

enum AntennaData {
	Float: Antenna_Pos[4],
	Antenna_Id,
	Antenna_Exists,
	Antenna_Hits,
	Antenna_Kill_Time,
	Text3D: Antenna_Label
};

new const AntennaInfo[][AntennaData] =
{
	{		{-299.5922,2337.6794,111.1899,224.5988}				},
	{		{249.5732,1960.7516,17.6406,118.2489}				},
	{		{-1249.3491,2625.2490,88.6355,12.6989}				}
};

//===========================
//Prototype
//===========================

enum PrototypeData {
	Prototype_Owner,
	Float: Prototype_Pos[4],
	Prototype_Attacker,
	Prototype_Id,
	Text3D: Prototype_Text,
	Prototype_Cooldown
};

new const PrototypeInfo[][PrototypeData] =
{
	{SWAT, {221.2865,1856.7158,12.7310,357.9090}},
	{TERRORIST, {-367.7220,2184.5767,51.3454,45.7451}},
	{VIP, {-1547.7971,2638.8337,71.4354,0.0}}
};

//Ranks System

enum RanksData {
	Float: Rank_Armour,
	Rank_Name[30],
	Rank_Score
};

new const RankInfo[][RanksData] =
{
			//AR  	//Name             		   		 //Score       
	{		10.0, 	"Private", 						     0 							},
	{		15.0, 	"Corporal", 	        		   100 							},
	{		20.0, 	"Sergeant",           			   250 							},
	{		25.0, 	"Lieutenant",    			 	   500 							},
	{		30.0, 	"Captain",	         			  1000  						},
	{		35.0, 	"Major",				   		  5000 	      					},
	{		40.0, 	"Lieutenant Colonel",   		  9500 							},
	{		45.0, 	"Colonel",  					 15000 							},
	{		50.0, 	"Brigadier",		 			 20000 							},
	{		55.0, 	"Brigadier General", 			 25000 							},
	{		60.0, 	"Major General",				 50000 	      					},
	{		65.0, 	"Lieutenant General",		 	 60000 		  					},
	{		70.0, 	"General",   		      	     75000	      					},
	{		75.0, 	"Field Marshal",				125000		  					},
	{		80.0, 	"Vice President",		   		150000							},
	{		90.0, 	"President",	  	            200000							},
	{		100.0,  "God of War", 	    			400000							}
};

//---------------------------------------------------------
//Max Velocities

new const s_TopSpeed[212] = {
    157, 147, 186, 110, 133, 164, 110, 148, 100, 158, 129, 221, 168, 110, 105, 192, 154, 270,
    115, 149, 145, 154, 140, 99, 135, 270, 173, 165, 157, 201, 190, 130, 94, 110, 167, 0, 149,
    158, 142, 168, 136, 145, 139, 126, 110, 164, 270, 270, 111, 0, 0, 193, 270, 60, 135, 157,
    106, 95, 157, 136, 270, 160, 111, 142, 145, 145, 147, 140, 144, 270, 157, 110, 190, 190,
    149, 173, 270, 186, 117, 140, 184, 73, 156, 122, 190, 99, 64, 270, 270, 139, 157, 149, 140,
    270, 214, 176, 162, 270, 108, 123, 140, 145, 216, 216, 173, 140, 179, 166, 108, 79, 101, 270,
    270, 270, 120, 142, 157, 157, 164, 270, 270, 160, 176, 151, 130, 160, 158, 149, 176, 149, 60,
    70, 110, 167, 168, 158, 173, 0, 0, 270, 149, 203, 164, 151, 150, 147, 149, 142, 270, 153, 145,
    157, 121, 270, 144, 158, 113, 113, 156, 178, 169, 154, 178, 270, 145, 165, 160, 173, 146, 0, 0,
    93, 60, 110, 60, 158, 158, 270, 130, 158, 153, 151, 136, 85, 0, 153, 142, 165, 108, 162, 0, 0,
    270, 270, 130, 190, 175, 175, 175, 158, 151, 110, 169, 171, 148, 152, 0, 0, 0, 108, 0, 0
};

//---------------------------------------------------------
//Inventory

enum InvData {
	Item_Name[20],
	Item_Max,
	Item_Object
};

new const ItemsInfo[MAX_ITEMS][InvData] =
{
	{	"Helmet", 		 3,	19102	  }, //19102
	{   "Gasmask", 		 3,	19472	  }, //19472
	{	"Medkit",		 7,	11738     }, //11738
	{   "Armour Kit", 	 7,	19515     }, //19515
	{	"Pilot License", 1,	520       }, //520
	{	"Spy Kit",       5,	1210      }, //1210
	{	"Landmine",      5,	19602     }, //19602
	{	"Dynamite",      5,	1654      }, //1654
	{	"Toolkit",       5,	18635     }, //18635
	{	"Jetpack",       1,	370       }, //370
	{	"Pyrokit",       5,	361       } //361
};

//-------------
//Loot system

new gLootObj[MAX_SLOTS];
new gLootItem[MAX_SLOTS];
new gLootAmt[MAX_SLOTS];
new gLootExists[MAX_SLOTS];
new gLootPickable[MAX_SLOTS];
new gLootTimer[MAX_SLOTS];
new gLootArea[MAX_SLOTS];

//////////////////////////////////////////////////
//Classes

enum ClassData {
	Class_Name[30],
	aClass_Name[30],
	Class_Score,
	Class_XP,
	Class_Weapon1[2],
	Class_Weapon2[2],
	Class_Weapon3[2],
	Class_Weapon4[2],
	Class_Weapon5[2],
	Class_Ability[120],
	aClass_Ability[120]
};

new const ClassInfo[][ClassData] = {
	{
		"Assault",
		"Rifleman",
		0,
		2000,
		{WEAPON_AK47, 200},
		{WEAPON_DEAGLE, 200},
		{WEAPON_UZI, 200},
		{WEAPON_NITESTICK, 1},
		{WEAPON_ROCKETLAUNCHER, 1},
		"Nothing",
		"Unlock Rhino tanks & get +150 Rhino HP"
	},
	{
		"Sniper",
		"Ghost",
		300,
		750,
		{WEAPON_SNIPER, 150},
		{WEAPON_M4, 100},
		{WEAPON_SILENCED, 100},
		{WEAPON_MOLTOV, 3},
		{WEAPON_KNIFE, 1},
		"Headshot enemies",
		"Invisible off the radar"
	},
	{
		"Mechanic",
		"Veteran Mechanic",
		750,
		1000,
		{WEAPON_M4, 200},
		{WEAPON_DEAGLE, 200},
		{WEAPON_UZI, 300},
		{WEAPON_SHOTGUN, 155},
		{WEAPON_SPRAYCAN, 1000},
		"Repair damaged vehicles using the spraycan",
		"+5 VHP on repairing vehicles & rebuild destroyed radio antennas [/rebuildantenna]"
	},
	{
		"Jet-Trooper",
		"Veteran Trooper",
		1000,
		1250,
		{WEAPON_TEC9, 200},
		{WEAPON_SHOTGSPA, 200},
		{WEAPON_COLT45, 200},
		{WEAPON_GRENADE, 3},
		{WEAPON_FLAMETHROWER, 80},
		"Unlock jetpack [CMD: /jp]",
		"Pilot seasparrows"
	},
	{
		"Paramedic",
		"Medic",
		1250,
		1500,
		{WEAPON_MP5, 500},
		{WEAPON_M4, 200},
		{WEAPON_COLT45, 300},
		{WEAPON_KNIFE, 1},
		{WEAPON_SHOTGSPA, 255},
		"In-range teammate healing at 7.5m [/heal]",
		"Out-range teammate healing at 15.0m & automatic self-healing"
	},
	{
		"Spy",
		"Veteran Spy",
		1500,
		2000,
		{WEAPON_SILENCED, 300},
		{WEAPON_SHOTGSPA, 200},
		{WEAPON_M4, 300},
		{WEAPON_GRENADE, 3},
		{WEAPON_UZI, 300},
		"Disguise enemy teams [/spy or /nospy]",
		"Backstab enemies in their vehicle when at backseat [/stab]"
	},
	{
		"Machine Gunner",
		"Veteran MG",
		2000,
		2500,
		{WEAPON_MINIGUN, 25},
		{WEAPON_M4, 50},
		{WEAPON_SILENCED, 100},
		{WEAPON_GRENADE, 1},
		{WEAPON_UZI, 200},
		"Unlock minigun on spawn (25 bullets)",
		"Shorter cooldown on minigun overheat"
	},
	{
		"Pyroman",
		"Veteran Pyroman",
		2500,
		3000,
		{WEAPON_FLAMETHROWER, 500},
		{WEAPON_MOLTOV, 10},
		{WEAPON_COLT45, 200},
		{WEAPON_RIFLE, 50},
		{WEAPON_TEC9, 300},
		"Plant dynamite on ground/in vehicles [/pb or /ex]",
		"Bburn nearby enemy vehicles [CMD: /fr]"
	},
	{
		"Scout",
		"Elite Scout",
		3000,
		3500,
		{WEAPON_SAWEDOFF, 500},
		{WEAPON_MOLTOV, 10},
		{WEAPON_SILENCED, 200},
		{WEAPON_RIFLE, 25},
		{WEAPON_MP5, 300},
		"Flashbang [y key], unlock submarines & +7 damage points with sniper",
		"Larger flashbang radius & double sawn-off shotgun"
	},
	{
		"Suicider",
		"Bomber",
		4000,
		4500,
		{WEAPON_SAWEDOFF, 500},
		{WEAPON_MOLTOV, 10},
		{WEAPON_DEAGLE, 200},
		{WEAPON_RIFLE, 25},
		{WEAPON_MP5, 300},
		"Suicide [/suicide]",
		"Extra (+4.50m) explosion radius on suicide"
	},
	{
		"Pilot",
		"Veteran Pilot",
		4500,
		5000,
		{WEAPON_SAWEDOFF, 250},
		{WEAPON_MOLTOV, 10},
		{WEAPON_DEAGLE, 200},
		{WEAPON_RIFLE, 25},
		{WEAPON_MP5, 300},
		"Drive air vehicles (seasparrow, hydra, hunter, cropduster, rustler and nevada [/dcp to drop carepack])",
		"Extra (+500hp) on air vehicles (seasparrow, hydra, hunter, cropduster, rustler and nevada)"
	},
	{
		"Recon",
		"Veteran Recon",
		5000,
		5500,
		{WEAPON_SAWEDOFF, 100},
		{WEAPON_MOLTOV, 10},
		{WEAPON_DEAGLE, 200},
		{WEAPON_AK47, 250},
		{WEAPON_MP5, 300},
		"Invisible off the radar, can find players [/locate] & +7 damage points with sniper",
		"Spawn drone [/drone] and explode it [n key]"
	},
	{
		"Sentinel",
		"Custodian",
		5500,
		6000,
		{WEAPON_SHOTGSPA, 250},
		{WEAPON_GRENADE, 5},
		{WEAPON_DEAGLE, 150},
		{WEAPON_M4, 200},
		{WEAPON_SAWEDOFF, 250},
		"Vest all the nearby teammates in a 10 meters range with +25 AR [/vest]",
		"Vest all the nearby teammates in a 15 meters range with +50 AR [/vest]"
	},
	{
		"Kamikaze",
		"Veteran Kamikaze",
		6000,
		6500,
		{WEAPON_FLAMETHROWER, 200},
		{WEAPON_AK47, 150},
		{WEAPON_DEAGLE, 100},
		{WEAPON_TEC9, 200},
		{WEAPON_GRENADE, 3},
		"Rustler self-destruction at a range of 10 meters [r key]",
		"Rustler self-destruction at a range of 15 meters [r key]"
	},
	{
		"Supporter",
		"Veteran Supporter",
		7000,
		7500,
		{WEAPON_SHOTGSPA, 100},
		{WEAPON_M4, 150},
		{WEAPON_SILENCED, 100},
		{WEAPON_MP5, 200},
		{WEAPON_MOLTOV, 3},
		"Support teammates in range of 10 meters [y key]",
		"+5 meters support range & unlock Anti-Air Vehicles"
	}
};

//Streaks

enum SpreeData {
	Spree_Name[35],
	Spree_Kills,
	Spree_Score,
	Spree_Cash,
	Spree_MK,
	Spree_WantedLevel
};

new const SpreeInfo[][SpreeData] =
{
			//Spree Name        //Kills     //Score 	//Money     //MKs 	//Wanted Level
	{		"Triple Kill",		3, 			3, 			5000, 		1,		1},
	{		"Rampage",			5, 			5, 			7000, 		2,		1},
	{		"Dominating",		10, 		7, 			8000, 		3,		2},
	{		"Ultimate",		    15, 		10, 		10000, 		5,		2},
	{		"Ragemode",			20, 		12, 		12500, 		7,		2},
	{		"Hunter",			25, 		14, 		15000, 		9,		3},
	{		"Frenzy",			30, 		17, 		20000, 		10,		3},
	{		"Godlike",			35, 		20, 		25000, 		11,		3},
	{		"Undertaker",		40, 		22,			45000, 		12,		3},
	{		"Zombie",			45, 		25, 		70000, 		12,		4},
	{		"Unstoppable",		50, 		30, 		100000,		12,		4},
	{		"Unbeatable",		75, 		50,			125000, 	12,		4},
	{		"Killerman",		100, 		55, 		150000,		25,		4},
	{		"Impossible",		150, 		75, 		200000,		30,		5},
	{		"God of War",		250, 		90, 		250000, 	32,		5},
	{		"God of Universe",  575, 		250, 		300000, 	35,		6}
};

//-----------------
//PUBG Event

new PUBGCircle, bool: PUBGOpened, bool: PUBGStarted, PUBGTimer, PUBGKills, PUBGKillTick;
new Float:Multiplier, Float: PUBGRadius;
new PUBGVehicles[5];
new Float: PUBGMeters;

new Float: PUBGArray[][4] = {    
	{3300.2144,3613.9907,9.6755,47.3393}, // LOOT
	{3299.2847,3619.1726,9.6936,356.6573}, // LOOT
	{3305.0471,3623.0735,9.6776,285.0993}, // LOOT
	{3313.5674,3617.5730,9.6849,224.8249}, // LOOT
	{3320.7900,3610.3044,9.6760,224.8160}, // LOOT
	{3338.6411,3606.8618,9.6782,280.9544}, // LOOT
	{3349.4531,3614.0320,9.6771,313.5122}, // LOOT
	{3353.2351,3630.1733,9.6775,5.8152}, // LOOT
	{3352.1401,3640.9290,9.6765,5.8387}, // LOOT
	{3324.0688,3770.9355,9.6151,43.6691}, // LOOT
	{3318.1472,3772.5173,9.6182,83.7547}, // LOOT
	{3312.7847,3768.2925,9.6243,156.0100}, // LOOT
	{3311.3757,3761.3760,9.6195,173.6460}, // LOOT
	{3315.0103,3755.4656,9.6220,232.5703}, // LOOT
	{3320.8455,3754.7292,9.6193,275.0132}, // LOOT
	{3326.5439,3757.8213,9.6150,311.4775}, // LOOT
	{3318.0061,3761.6248,9.6181,109.2235}, // LOOT
	{3312.2048,3764.9097,9.6241,38.3268}, // LOOT
	{3347.5413,3748.1277,10.9573,232.3458}, // LOOT
	{3351.1841,3747.4653,11.0956,265.3982}, // LOOT
	{3359.5525,3738.5134,9.4588,202.5752}, // LOOT
	{3365.1340,3735.9063,7.3752,266.9826}, // LOOT
	{3341.2559,3700.5833,9.6777,179.8301}, // LOOT
	{3342.2546,3680.2334,9.6774,184.0620}, // LOOT
	{3344.4163,3649.8101,9.6771,184.0643}, // LOOT
	{3503.0806,3719.6455,7.7507,309.1586}, // LOOT
	{3506.1973,3717.4229,7.7507,219.1585}, // LOOT
	{3507.1765,3720.1003,7.7451,354.1586}, // LOOT
	{3504.0500,3712.5596,5.2998,327.3321}, // LOOT
	{3506.5508,3711.2146,5.3048,237.3320}, // LOOT
	{3505.0537,3708.4717,5.2998,147.3321}, // LOOT
	{3506.8628,3677.4868,6.0498,174.4240}, // LOOT
	{3504.0950,3677.5432,6.0498,84.4239}, // LOOT
	{3505.1624,3675.5742,6.0498,219.4240}, // LOOT
	{3505.0659,3674.1025,6.0498,174.4240}, // LOOT
	{3504.8367,3671.7593,6.0498,174.4240}, // LOOT
	{3504.5945,3669.2866,6.0262,174.4240}, // LOOT
	{3504.6030,3667.2844,6.3546,174.4240}, // LOOT
	{3504.7534,3660.1782,7.4755,174.4240}, // LOOT
	{3504.5906,3657.7119,7.6453,174.4240}, // LOOT
	{3616.3623,3567.5879,7.3402,273.9901}, // LOOT
	{3618.8010,3569.7222,7.3402,3.9901}, // LOOT
	{3623.3262,3566.2336,7.3402,273.9901}, // LOOT
	{3655.8186,3574.0972,7.5263,273.9901}, // LOOT
	{3659.4194,3574.3484,8.0906,273.9901}, // LOOT
	{3662.6797,3574.5762,8.6015,273.9901}, // LOOT
	{3666.3340,3573.4829,8.6752,273.9901}, // LOOT
	{3667.6655,3574.9248,8.6752,3.9901}, // LOOT
	{3709.6333,3564.2324,43.1373,157.7423}, // LOOT
	{3707.6694,3562.3010,43.1373,157.7423}, // LOOT
	{3710.4966,3560.9102,43.1373,247.7423}, // LOOT
	{3951.5977,3463.4067,13.5768,54.2039}, // LOOT
	{3948.2009,3475.4136,13.5768,54.2039}, // LOOT
	{3950.5288,3490.2427,13.5768,54.2039}, // LOOT
	{3945.4370,3490.4941,13.5768,108.7245}, // LOOT
	{3940.4026,3490.9526,13.5768,108.7245}, // LOOT
	{3934.9717,3491.8113,13.5768,108.7245}, // LOOT
	{3933.8518,3488.1514,13.5768,198.7245}, // LOOT
	{3935.1326,3484.3745,13.5768,198.7245}, // LOOT
	{3958.2761,3484.6011,13.5768,265.3692}, // LOOT
	{3960.3823,3487.9941,13.5768,310.3692}, // LOOT
	{3964.8811,3485.2195,13.5768,265.3692}, // LOOT
	{3965.1760,3480.9612,13.5768,175.3692}, // LOOT
	{4046.5950,3525.7671,13.5768,339.0034}, // LOOT
	{4041.1042,3528.1091,13.5768,69.0034}, // LOOT
	{4040.9851,3532.2190,13.5768,339.0034}, // LOOT
	{4043.2297,3538.0637,13.5768,339.0034}, // LOOT
	{4046.8813,3541.1670,13.5768,303.7893}, // LOOT
	{4051.0886,3541.5234,13.5768,258.7893}, // LOOT
	{4055.2026,3540.7085,13.5768,258.7893}, // LOOT
	{4058.2974,3538.4382,14.3699,153.8216}, // LOOT
	{4058.8809,3536.5823,14.3126,198.8216}, // LOOT
	{3802.5630,3655.0566,4.3402,225.1663}, // LOOT
	{3804.9773,3657.1750,4.3402,315.1664}, // LOOT
	{3803.8481,3658.6445,4.3402,45.1664}, // LOOT
	{3775.5781,3625.1357,5.8159,163.8249}, // LOOT
	{3777.0610,3621.8062,5.8159,208.8249}, // LOOT
	{3774.0244,3619.0413,5.8159,163.8249}, // LOOT
	{3776.8574,3614.8962,5.8159,253.8250}, // LOOT
	{3773.5564,3610.3047,5.8159,163.8249}, // LOOT
	{3777.6392,3605.0088,5.8159,163.8249}, // LOOT
	{3738.6438,3785.2717,10.1571,28.4637}, // LOOT
	{3739.2646,3788.2561,10.1571,28.4637}, // LOOT
	{3736.4043,3787.4326,10.1571,118.4637}, // LOOT
	{3738.2053,3789.2751,10.1571,298.4636}, // LOOT
	{3739.8550,3784.6970,10.1571,118.4637}, // LOOT
	{3684.6597,3783.5354,11.7561,67.9440}, // LOOT
	{3683.9170,3785.6824,11.7561,337.9440}, // LOOT
	{3685.8145,3786.8518,11.7561,247.9440}, // LOOT
	{3518.0425,3788.1743,13.6202,59.1706}, // LOOT
	{3516.7925,3787.8953,13.6202,104.7973}, // LOOT
	{3515.6763,3789.1919,13.6202,59.7973}, // LOOT
	{3513.8555,3790.4993,13.6202,59.1706}, // LOOT
	{3514.0706,3786.4067,13.6202,119.9579}, // LOOT
	{3510.4126,3788.3132,10.1571,250.7396}, // LOOT
	{3511.0459,3787.1147,10.1571,205.7395}, // LOOT
	{3512.0242,3788.5830,10.1571,340.7396}, // LOOT
	{3513.6250,3826.6968,13.6202,244.6657}, // LOOT
	{3515.1042,3825.3254,13.6202,244.6657}, // LOOT
	{3517.4521,3824.2139,13.6202,244.6657}, // LOOT
	{3518.8628,3826.6721,13.6202,334.6658}, // LOOT
	{3525.3643,3825.6599,10.1571,286.9662}, // LOOT
	{3523.5562,3827.1069,10.1571,61.9661}, // LOOT
	{3522.9858,3823.5129,10.1571,106.9661}, // LOOT
	{3551.4875,3830.8523,10.1571,291.0395}, // LOOT
	{3552.7383,3833.3262,10.1571,336.0395}, // LOOT
	{3554.3289,3830.3828,10.1571,201.0395}, // LOOT
	{3557.5066,3827.4380,10.1571,291.0395}, // LOOT
	{3555.9983,3824.8486,10.1571,201.0395}, // LOOT
	{3558.5220,3824.4087,10.1571,291.0395}, // LOOT
	{3730.3970,3935.2017,10.1571,302.6329}, // LOOT
	{3732.9172,3935.3923,10.1571,302.6329}, // LOOT
	{3735.7715,3935.5068,10.1571,302.6329}, // LOOT
	{3736.9922,3937.8262,10.1571,347.6329}, // LOOT
	{3739.3284,3939.3816,10.1571,302.6329}, // LOOT
	{3832.0027,3910.0945,26.0100,43.5997}, // LOOT
	{3836.2754,3910.7434,26.0100,313.5996}, // LOOT
	{3838.8481,3908.3643,26.0100,223.5996}, // LOOT
	{3841.1292,3905.9673,26.0100,223.5996}, // LOOT
	{3840.7744,3905.3276,26.0100,133.5996}, // LOOT
	{3838.7273,3903.3784,26.0100,133.5996}, // LOOT
	{3836.5239,3901.2808,26.0100,133.5996}, // LOOT
	{3833.9146,3898.7964,26.0100,133.5996}, // LOOT
	{3830.4241,3895.4734,26.0100,133.5996}, // LOOT
	{3827.9102,3897.7930,26.0048,43.5997}, // LOOT
	{3828.7954,3890.5264,26.0048,223.5996}, // LOOT
	{3832.0520,3890.5481,26.0100,313.5996}, // LOOT
	{3834.1995,3892.5938,26.0100,313.5996}, // LOOT
	{3838.1875,3893.4302,26.0100,313.5996}, // LOOT
	{3842.3340,3894.7810,26.0100,313.5996}, // LOOT
	{3844.5293,3896.8696,26.0100,313.5996}, // LOOT
	{3844.8994,3899.6606,26.0100,358.5996}, // LOOT
	{3848.6372,3898.0076,26.0100,223.5996}, // LOOT
	{3851.5449,3894.9541,26.0100,223.5996}, // LOOT
	{3852.0962,3897.6042,26.0100,358.5996}, // LOOT
	{3856.6062,3899.2512,26.0100,313.5996}, // LOOT
	{3856.7639,3903.0376,26.0100,358.5996}, // LOOT
	{3860.2451,3903.7961,26.0100,313.5996}, // LOOT
	{3866.7336,3908.3381,25.9976,313.5996}, // LOOT
	{3870.3242,3908.6968,24.6428,313.5996}, // LOOT
	{3871.0557,3910.9619,24.6428,108.4603}, // LOOT
	{4060.8638,3924.8091,10.1511,280.0727}, // LOOT
	{4064.3550,3922.9863,10.1385,280.0727}, // LOOT
	{4066.3457,3926.1353,10.1566,325.0727}, // LOOT
	{4062.6638,3928.9919,10.0990,55.0727}, // LOOT
	{4059.7271,3925.1650,10.1470,145.0727}, // LOOT
	{4065.7495,3920.6267,10.1267,235.0727}, // LOOT
	{4063.6265,3918.2996,10.0721,100.0727}, // LOOT
	{4059.9731,3920.6243,10.1050,55.0727}, // LOOT
	{4056.6252,3917.0415,10.0654,100.0727}, // LOOT
	{4053.3716,3919.1882,10.1059,55.0727}, // LOOT
	{4530.4141,4090.3621,8.9028,299.1862}, // LOOT
	{4527.8975,4089.8020,8.9028,119.1861}, // LOOT
	{4524.2461,4090.7488,8.9028,74.1861}, // LOOT
	{4520.2178,4091.8818,8.9028,74.1861}, // LOOT
	{4516.6045,4092.9043,8.9028,74.1861}, // LOOT
	{4658.1626,4071.8782,8.4629,334.9066}, // LOOT
	{4660.8921,4070.8455,8.4629,244.9065}, // LOOT
	{4659.8643,4068.1311,8.4629,154.9065}, // LOOT
	{4657.3936,4066.7314,8.4629,109.9065}, // LOOT
	{4657.7485,4062.5225,8.4629,154.9065}, // LOOT
	{4660.4648,4063.6423,8.4629,334.9066}, // LOOT
	{4664.4551,4068.2722,8.4629,334.9066}, // LOOT
	{4670.6084,4065.9504,8.4629,244.9065}, // LOOT
	{3699.0308,3482.0781,6.8201,294.3886}, // LOOT
	{3703.2285,3476.0376,6.6017,229.5136}, // LOOT
	{3707.6799,3478.1021,6.9186,294.3886}, // LOOT
	{3711.0071,3472.4314,7.8727,249.3886}, // LOOT
	{3714.6531,3474.2258,8.5109,339.3887}, // LOOT
	{3718.0579,3470.0066,6.7273,249.3886}, // LOOT
	{3723.3083,3472.2561,4.9942,294.3886}, // LOOT
	{3726.1611,3467.9006,6.8242,249.3886}, // LOOT
	{3725.0378,3464.2510,8.7310,159.3886}, // LOOT
	{3723.5430,3460.2771,10.4116,159.3886} // LOOT
};

//-------------------
//Vehicles

new VehicleNames[212][] =
{
	"Landstalker", "Bravura", "Buffalo", "Linerunner", "Pereniel", "Sentinel", "Dumper", "Firetruck", "Trashmaster", "Stretch", "Manana", "Infernus",
	"Voodoo", "Pony", "Mule", "Cheetah", "Ambulance", "Leviathan", "Moonbeam", "Esperanto", "Taxi", "Washington", "Bobcat", "Mr Whoopee", "BF Injection",
	"Hunter", "Premier", "Enforcer", "Securicar", "Banshee", "Elite MG", "Bus", "Rhino", "Barracks", "Hotknife", "Trailer", "Previon", "Coach", "Cabbie",
	"Stallion", "Rumpo", "RC Bandit", "Romero", "Packer", "Monster", "Admiral", "Squalo", "Seasparrow", "Pizzaboy", "Tram", "Trailer", "Turismo", "Speeder",
	"Reefer", "Tropic", "Flatbed", "Yankee", "Caddy", "Solair", "Berkley's RC Van", "Skimmer", "PCJ-600", "Faggio", "Freeway", "RC Baron", "RC Raider",
	"Glendale", "Oceanic", "Sanchez", "Sparrow", "Patriot", "Quad", "Coastguard", "Dinghy", "Hermes", "Sabre", "Rustler", "ZR3 50", "Walton", "Regina",
	"Comet", "BMX", "Burrito", "Camper", "Marquis", "Baggage", "Dozer", "Maverick", "new stocks Chopper", "Rancher", "USA Rancher", "Virgo", "Greenwood",
	"Jetmax", "Hotring", "Sandking", "Blista Compact", "Police Maverick", "Boxville", "Benson", "Mesa", "RC Goblin", "Hotring Racer A", "Hotring Racer B",
	"Bloodring Banger", "Rancher", "Super GT", "Elegant", "Journey", "Bike", "Mountain Bike", "Beagle", "Cropdust", "Stunt", "Tanker", "RoadTrain",
	"Nebula", "Majestic", "Buccaneer", "Shamal", "Hydra", "FCR-900", "NRG-500", "HPV1000", "Cement Truck", "Tow Truck", "Fortune", "Cadrona", "USA Truck",
	"Willard", "Forklift", "Tractor", "Combine", "Feltzer", "Remington", "Slamvan", "Blade", "Freight", "Streak", "Vortex", "Vincent", "Bullet", "Clover",
	"Sadler", "Firetruck", "Hustler", "Intruder", "Primo", "Cargobob", "Tampa", "Sunrise", "Merit", "Utility", "Nevada", "Yosemite", "Windsor", "Monster A",
	"Monster B", "Uranus", "Jester", "Sultan", "Stratum", "Elegy", "Raindance", "RC Tiger", "Flash", "Tahoma", "Savanna", "Bandito", "Freight", "Trailer",
	"Kart", "Mower", "Duneride", "Sweeper", "Broadway", "Tornado", "AT-400", "DFT-30", "Huntley", "Stafford", "BF-400", "new stocksvan", "Tug", "Trailer A", "Emperor",
	"Wayfarer", "Euros", "Hotdog", "Club", "Trailer B", "Trailer C", "Andromada", "Dodo", "RC Cam", "Launch", "Police Car (LSPD)", "Police Car (SFPD)",
	"Police Car (LVPD)", "Police Ranger", "Picador", "SWAT. Van", "Alpha", "Phoenix", "Glendale", "Sadler", "Luggage Trailer A", "Luggage Trailer B",
	"Stair Trailer", "Boxville", "Farm Plow", "Utility Trailer"
};

//Legal modifications

//Modifications
new legalmods[48][22] = {
		{400, 1024,1021,1020,1019,1018,1013,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000},
		{401, 1145,1144,1143,1142,1020,1019,1017,1013,1007,1006,1005,1004,1003,1001,0000,0000,0000,0000},
		{404, 1021,1020,1019,1017,1016,1013,1007,1002,1000,0000,0000,0000,0000,0000,0000,0000,0000,0000},
		{405, 1023,1021,1020,1019,1018,1014,1001,1000,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000},
		{410, 1024,1023,1021,1020,1019,1017,1013,1007,1003,1001,0000,0000,0000,0000,0000,0000,0000,0000},
		{415, 1023,1019,1018,1017,1007,1003,1001,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000},
		{418, 1021,1020,1016,1006,1002,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000},
		{420, 1021,1019,1005,1004,1003,1001,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000},
		{421, 1023,1021,1020,1019,1018,1016,1014,1000,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000},
		{422, 1021,1020,1019,1017,1013,1007,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000},
		{426, 1021,1019,1006,1005,1004,1003,1001,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000},
		{436, 1022,1021,1020,1019,1017,1013,1007,1006,1003,1001,0000,0000,0000,0000,0000,0000,0000,0000},
		{439, 1145,1144,1143,1142,1023,1017,1013,1007,1003,1001,0000,0000,0000,0000,0000,0000,0000,0000},
		{477, 1021,1020,1019,1018,1017,1007,1006,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000},
		{478, 1024,1022,1021,1020,1013,1012,1005,1004,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000},
		{489, 1024,1020,1019,1018,1016,1013,1006,1005,1004,1002,1000,0000,0000,0000,0000,0000,0000,0000},
		{491, 1145,1144,1143,1142,1023,1021,1020,1019,1018,1017,1014,1007,1003,0000,0000,0000,0000,0000},
		{492, 1016,1006,1005,1004,1000,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000},
		{496, 1143,1142,1023,1020,1019,1017,1011,1007,1006,1003,1002,1001,0000,0000,0000,0000,0000,0000},
		{500, 1024,1021,1020,1019,1013,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000},
		{516, 1021,1020,1019,1018,1017,1016,1015,1007,1004,1002,1000,0000,0000,0000,0000,0000,0000,0000},
		{517, 1145,1144,1143,1142,1023,1020,1019,1018,1017,1016,1007,1003,1002,0000,0000,0000,0000,0000},
		{518, 1145,1144,1143,1142,1023,1020,1018,1017,1013,1007,1006,1005,1003,1001,0000,0000,0000,0000},
		{527, 1021,1020,1018,1017,1015,1014,1007,1001,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000},
		{529, 1023,1020,1019,1018,1017,1012,1011,1007,1006,1003,1001,0000,0000,0000,0000,0000,0000,0000},
		{534, 1185,1180,1179,1178,1127,1126,1125,1124,1123,1122,1106,1101,1100,0000,0000,0000,0000,0000},
		{535, 1121,1120,1119,1118,1117,1116,1115,1114,1113,1110,1109,0000,0000,0000,0000,0000,0000,0000},
		{536, 1184,1183,1182,1181,1128,1108,1107,1105,1104,1103,0000,0000,0000,0000,0000,0000,0000,0000},
		{540, 1145,1144,1143,1142,1024,1023,1020,1019,1018,1017,1007,1006,1004,1001,0000,0000,0000,0000},
		{542, 1145,1144,1021,1020,1019,1018,1015,1014,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000},
		{546, 1145,1144,1143,1142,1024,1023,1019,1018,1017,1007,1006,1004,1002,1001,0000,0000,0000,0000},
		{547, 1143,1142,1021,1020,1019,1018,1016,1003,1000,0000,0000,0000,0000,0000,0000,0000,0000,0000},
		{549, 1145,1144,1143,1142,1023,1020,1019,1018,1017,1012,1011,1007,1003,1001,0000,0000,0000,0000},
		{550, 1145,1144,1143,1142,1023,1020,1019,1018,1006,1005,1004,1003,1001,0000,0000,0000,0000,0000},
		{551, 1023,1021,1020,1019,1018,1016,1006,1005,1003,1002,0000,0000,0000,0000,0000,0000,0000,0000},
		{558, 1168,1167,1166,1165,1164,1163,1095,1094,1093,1092,1091,1090,1089,1088,0000,0000,0000,0000},
		{559, 1173,1162,1161,1160,1159,1158,1072,1071,1070,1069,1068,1067,1066,1065,0000,0000,0000,0000},
		{560, 1170,1169,1141,1140,1139,1138,1033,1032,1031,1030,1029,1028,1027,1026,0000,0000,0000,0000},
		{561, 1157,1156,1155,1154,1064,1063,1062,1061,1060,1059,1058,1057,1056,1055,1031,1030,1027,1026},
		{562, 1172,1171,1149,1148,1147,1146,1041,1040,1039,1038,1037,1036,1035,1034,0000,0000,0000,0000},
		{565, 1153,1152,1151,1150,1054,1053,1052,1051,1050,1049,1048,1047,1046,1045,0000,0000,0000,0000},
		{567, 1189,1188,1187,1186,1133,1132,1131,1130,1129,1102,0000,0000,0000,0000,0000,0000,0000,0000},
		{575, 1177,1176,1175,1174,1099,1044,1043,1042,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000},
		{576, 1193,1192,1191,1190,1137,1136,1135,1134,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000},
		{580, 1023,1020,1018,1017,1007,1006,1001,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000},
		{589, 1145,1144,1024,1020,1018,1017,1016,1013,1007,1006,1005,1004,1000,0000,0000,0000,0000,0000},
		{600, 1022,1020,1018,1017,1013,1007,1006,1005,1004,0000,0000,0000,0000,0000,0000,0000,0000,0000},
		{603, 1145,1144,1143,1142,1024,1023,1020,1019,1018,1017,1007,1006,1001,0000,0000,0000,0000,0000}
};

//Nuke

new nukeIsLaunched;
new nukeCooldown;

new Nuke_Area;
new nukePlayerId;
new Nuke_Priority;

//Weapon shop actors
new ShopActors[MAX_TEAMS];

//Skins list
new clanskinlist, skinlist, tskinlist, sskinlist;

//Toys list
new toyslist;

new KillCar[MAX_VEHICLES];
new Rustler_Rockets[MAX_VEHICLES][4];

new firstblood = INVALID_PLAYER_ID;

//Labels
new Text3D: nukeRemoteLabel;

//Countdown
new counterOn = 0, counterValue = -1, counterTimer;

//Pickups array
new g_pickups[7];

//Server timers

//Timers
new bedTimer;
new castleTimer;

//Landmines
new gLandmineObj[MAX_SLOTS];
new gLandmineExists[MAX_SLOTS];
new Float: gLandminePos[MAX_SLOTS][3];
new gLandminePlacer[MAX_SLOTS];
new gLandmineTimer[MAX_SLOTS];
new gLandmineArea[MAX_SLOTS];

//Dynamite
new gDynamiteObj[MAX_SLOTS];
new gDynamiteExists[MAX_SLOTS];
new Float: gDynamitePos[MAX_SLOTS][3];
new gDynamitePlacer[MAX_SLOTS];
new gDynamiteTimer[MAX_SLOTS];
new gDynamiteArea[MAX_SLOTS];
new gDynamiteCD[MAX_SLOTS];

//Weapon drop
new gWeaponObj[MAX_SLOTS];
new Text3D: gWeapon3DLabel[MAX_SLOTS];
new gWeaponID[MAX_SLOTS];
new gWeaponAmmo[MAX_SLOTS];
new gWeaponExists[MAX_SLOTS];
new gWeaponPickable[MAX_SLOTS];
new gWeaponTimer[MAX_SLOTS];
new gWeaponArea[MAX_SLOTS];

//Airstrike
new gAirstrikePlanes[MAX_SLOTS][3];
new gAirstrikeRocket[MAX_SLOTS];
new Float: gAirstrikePos[MAX_SLOTS][3];
new gAirstrikeExists[MAX_SLOTS];
new gAirstrikeTimer[MAX_SLOTS];

//Carepack
new gCarepackObj[MAX_SLOTS];
new Float: gCarepackPos[MAX_SLOTS][3];
new gCarepackExists[MAX_SLOTS];
new gCarepackUsable[MAX_SLOTS];
new gCarepackArea[MAX_SLOTS];
new Text3D: gCarepack3DLabel[MAX_SLOTS];
new gCarepackTimer[MAX_SLOTS];
new gCarepackCaller[MAX_SLOTS][MAX_PLAYER_NAME];

//Anthrax
new Anthrax_Area;
new gAnthraxOwner;
new gAnthraxCooldown;

//Anthrax planes
enum AnthraxData {
	Text3D: Anthrax_Label,
	Anthrax_Cooldown,
	Anthrax_Rockets
};

new CropAnthrax[MAX_VEHICLES][AnthraxData];
///////////////////////////////////////////

//Anti Aircraft

enum E_AAC_DATA {
	AAC_Model,
	Float: AAC_Pos[4],
	AAC_Id,
	Text3D: AAC_Text,
	AAC_Rockets,
	AAC_Regen_Timer,
	AAC_Samsite,
	AAC_Target,
	AAC_Driver,
	AAC_RocketId
};

//Anti air vehicle models: 515, 422
new const AACInfo[][E_AAC_DATA] = {
	{515, {260.9089,1832.2035,18.6603,359.8263}}, // SWAT Forces
	{515, {163.8836,1908.2328,19.5910,270.5557}}, // SWAT Forces
	{515, {260.1673,1938.3888,18.6572,180.2284}}, // SWAT Forces
	{515, {96.6225,2118.4189,19.0362,268.1355}}, // SWAT Forces
	{515, {125.3048,2117.3105,19.3821,267.6613}}, // SWAT Forces
	{515, {187.6313,2073.7795,23.6611,88.2849}}, // SWAT Forces
	{422, {-448.1489,2255.1614,51.2067,269.3884}}, //Terrorists
	{422, {-447.7226,2194.1311,51.2030,0.5733}}, //Terrorists
	{422, {-363.0200,2237.6965,51.2056,180.7937}}, //Terrorists
	{422, {-362.8414,2224.8118,51.2051,180.7937}} //Terrorists
};

//Terrorists' Balloon

new ballonObjectId, Text3D: Balloon_Label, ballonDestination, bRouteCoords, Balloon_Timer, Balloontimer;
new const Float: ballonRouteArray[][3] = {
	{-342.6397, 2233.2332, 50.1024},
	{-342.6397, 2233.2332, 127.5192},
	{-240.2876, 2049.5674, 127.5192},
	{-112.6949, 1954.8041, 127.5192},
	{-1.4347, 1997.8418, 127.5192},
	{211.9493, 1976.5756, 127.5192},
	{199.3438, 1943.7891, 17.2031}
};

//Deathmatch

enum DeathmatchData {
	DM_SHORTCUT[7],
	DM_SKIN,
	Float: DM_HP,
	Float: DM_AR,
	DM_NAME[32],
	DM_WEAP_1[2],
	DM_WEAP_2[2],
	DM_WEAP_3[2],
	DM_WEAP_4[2],
	Float: DM_SPAWN_1[4],
	Float: DM_SPAWN_2[4],
	Float: DM_SPAWN_3[4],
	DM_INT
};

new const DMInfo[][DeathmatchData] = {
	{"WW", 230, {100.0}, {100.0}, "Walking Weapons", {24, 5000}, {25, 5000}, {16, 1}, {10, 1}, {1249.8789,-45.7439,1001.0295,357.8067}, {1287.7396,-52.8278,1002.5090,357.4934}, {1305.4907,4.0674,1001.0273,179.2284}, 18},
	{"RW", 230, {100.0}, {100.0}, "Running Weapons", {0, 0}, {26, 5000}, {32, 5000}, {0, 0}, {-3126.1147,1780.8942,20.0274,268.8700}, {-3152.1655,1758.8895,20.0109,272.3166}, {-3054.5188,1728.0973,20.0274,93.4250}, 1},
	{"RL", 230, {100.0}, {0.0}, "Rocket Launcher", {35, 1000}, {0, 0}, {0, 0}, {0, 0}, {366.5641,213.0788,1008.3828,178.7679}, {369.8232,186.4829,1008.3893,182.2146}, {383.4497,173.7858,1008.3828,89.4904}, 3},
	{"MG", 230, {100.0}, {0.0}, "Minigun", {38, 70000}, {0, 0}, {0, 0}, {0, 0}, {2229.2783,1575.8412,999.9708,359.5631}, {2205.1995,1609.7264,999.9728,359.5864}, {2176.0613,1578.7721,999.9686,1.1531}, 1},
	{"FT", 230, {25.0}, {0.0}, "Flamethrower", {18, 400}, {37, 9000}, {42, 9000}, {0, 0}, {238.9707,142.0773,1003.0234,357.2343}, {238.7806,194.0478,1008.1719,181.1065}, {288.7460,169.3510,1007.1719,0.0000}, 3},
	{"RC", 230, {100.0}, {0.0}, "RC Baron", {0, 0}, {0, 0}, {0, 0}, {0, 0}, {-974.5394,1061.1886,1344.9669,90.5630}, {-1130.9128,1057.7189,1345.7155,270.3982}, {-1130.9128,1057.7189,1345.7155,270.3982}, 10},
	{"SDM", 230, {100.0}, {0.0}, "Sniper", {34, 950}, {17, 1}, {0, 0}, {0, 0}, {-1018.2189,1056.7441,1342.9358,53.6926}, {-1053.4242,1087.2908,1343.0204,230.7042}, {-1053.4242,1087.2908,1343.0204,230.7042}, 10},
	{"TW", 230, {100.0}, {0.0}, "Tank War", {0, 0}, {0, 0}, {0, 0}, {0, 0}, {302.9792,2032.7242,17.7537,179.2502}, {206.6381,1914.5846,17.6490,269.3657}, {238.7171,1819.5065,17.6524,270.9355}, 0},
	{"BDM", 230, {100.0}, {0.0}, "Bunker", {24, 500}, {31, 520}, {16, 7}, {38, 10}, {-1580.6182,-2554.4697,28.8284,31.7445}, {-1596.8790,-2567.3677,-5.9774,300.1802}, {-1596.3083,-2713.4727,2.0524,270.4133}, 0}
};

//Beds global iterator
new Iterator: Beds<10002>;

//Anti bot declarations
new g_LastIp[30], g_Connections = 0, g_Tick = 0;

//Hunter-spawn event
new bool: FreeHunter = false;

//Camera object
new gCameraId = INVALID_OBJECT_ID;
new gWatchRoom;

//Capture System

enum E_CAPTURE_DATA {
	Zone_Name[35],
	Zone_MapArea[4],
	Float: Zone_CapturePoint[3],
	Zone_Owner,
	Zone_Attacker,
	Float: Zone_CapTime,
	Zone_Id,
	Zone_Attackers,
	Zone_PickupId,
	Text3D: Zone_Label,
	bool: Zone_Attacked,
	Zone_Timer,
	Zone_Checkpoint,
	Capture_Area[4]
};

new ZoneInfo[][E_CAPTURE_DATA] = {
	//Zone Name                 //Gang Zone                 //Capture Point                                 //Default Team
	{"LV Airbase",				{1231, 1203, 1628, 1867}, 	{1312.2656,1617.3121,10.8203},          		TERRORIST}, //ID = 0
	{"Submarine Port",			{-10, 2912, 544, 3255}, 	{263.7045,3031.9456,11.2221}, 			   		TERRORIST}, //1
	{"Data Center",				{-605, 2537, -493, 2654}, 	{-537.8996,2591.4229,54.4992},         			TERRORIST}, //2
	{"Chemical Refinery",		{103, 1331, 295, 1487}, 	{173.1359,1397.8148,23.3750},       			TERRORIST}, //3
	{"Desert Zone",				{-376, 1801, -241, 1916}, 	{-305.4872,1838.8951,42.2891},          		TERRORIST}, //4
	{"Crates Site",				{-140, 1869, -91, 1931}, 	{-120.6943,1903.2755,15.3800},   		 		TERRORIST}, //5
	{"Sniperhut",				{433, 2272, 507, 2346}, 	{481.8103,2308.1157,38.8940},           		TERRORIST}, //6
	{"Ranch Shack",				{675, 1951, 732, 2004}, 	{703.2129,1963.0461,5.5391},       				TERRORIST}, //7
	{"Ammunation",				{757, 1847, 806, 1909}, 	{782.3793,1871.3038,4.8533},           			TERRORIST}, //8
	{"Desert Camp",				{773, 1600, 826, 1734}, 	{799.0922,1686.9808,5.2813},  	        		TERRORIST}, //9
	{"Octane Springs",			{530, 1192, 695, 1272}, 	{609.1064,1208.5597,11.7188},           	    TERRORIST}, //10
	{"Cluckin' Bell",			{147, 1155, 204, 1199}, 	{171.5608,1174.5854,14.7578},           		TERRORIST}, //11
	{"Ammo Depot",				{1397, 2320, 1558, 2383},	{1444.2500,2360.1401,10.8203},          		TERRORIST}, //12
	{"Factory",					{916, 2046, 999, 2184}, 	{972.2277,2071.9954,10.8203},           		TERRORIST}, //13
	{"Cargo",					{1532, 525, 1710, 622}, 	{1672.1604,559.6873,7.1328},           			TERRORIST}, //14
	{"Whitewood Church",		{915, 1861, 969, 1912}, 	{929.4318,1891.6390,12.8379},  					TERRORIST}, //15
	{"Battleship",				{-869, 2171, -573, 2230}, 	{-645.3881,2203.3589,51.2932},          		TERRORIST}, //16
	{"Tierra Bridge",			{-1138, 2661, -867, 2741}, 	{-906.7224,2698.2632,41.9279},   	       		TERRORIST}, //17
	{"Nuke Station",			{-409, 1497, -232, 1647}, 	{-347.7741,1580.8589,76.3168},          		TERRORIST}, //18
	{"Medical Center",			{-343, 1007, -285, 1066}, 	{-320.2253,1048.7714,20.3403},       			TERRORIST}, //19
	{"Weapon Depot",			{-354, 797, -296, 861}, 	{-315.2905,829.8641,14.2422},           		TERRORIST}, //20
	{"Blackfield",				{1018, 1204, 1178, 1364}, 	{1166.5272,1348.1775,10.9219},      			TERRORIST}, //21
	{"Recharge Point",			{-58, 2309, 5, 2372}, 		{-49.5880,2353.1509,24.4427},           		TERRORIST}, //22
	{"Xoomer",					{539, 1619, 698, 1759}, 	{636.9102,1687.9380,6.9922},     		   		TERRORIST}, //23
	{"Headquarters",			{3076,2057,3158,2106}, 		{3092.2126,2094.6006,21.6919},    				TERRORIST}, //24
	{"Petrol Refinery",			{-77, 1461, 84, 1591}, 		{-38.7557,1535.7911,12.8000},   		   	    TERRORIST}, //25
	{"Hospital",				{1018, 1721, 1117, 1803}, 	{1054.4314,1758.7367,10.9157},       			TERRORIST}, //26
	{"Desert Airport",			{89, 2367, 477, 2650}, 		{426.4098,2500.9263,17.6634},    		  		TERRORIST}, //27
	{"Quarry",					{384, 715, 837, 1038},		{590.0967,869.7262,-42.4973}, 					TERRORIST}, //28
	{"Military Port",			{214, 348, 521, 618}, 		{295.1580,406.9670,6.4504},   	 	  	    	TERRORIST}, //29
	{"North Tower",				{662, 2760, 876, 2901}, 	{712.8585,2780.5520,96.4743},   	 	  		TERRORIST}, //30
	{"Command Center",			{-1278, 2113, -1099, 2210}, {-1230.3333,2184.3452,100.9999},	  		  	TERRORIST}, //31
	{"Outpost",					{-1540, 1927, -1420, 2075}, {-1494.8730,1972.1803,48.4219},   	 	  	  	TERRORIST}, //32
	{"Bunker",					{-1410, 2019, -1350, 2075}, {-1381.5803,2044.0314,52.5568},   	 	  		TERRORIST}, //33
	{"Parasite",  				{897, 2199, 1012, 2439}, 	{984.5773,2252.2468,11.1261},                   TERRORIST} //34
};

//Weapon System

enum WeaponData {
	Weapon_Id,
	Weapon_Ammo,
	Weapon_Price
};

new const WeaponInfo[][WeaponData] = {
	//    	ID          Ammo        Costs       
	{		4, 			1, 			25000		},
	{		16, 		3, 			5000		},
	{		18, 		5, 			4500	    },
	{		22, 		50, 		8000		},
	{		23, 		100, 		8500		},
	{		24, 		95, 		9500		},
	{		25,			100, 		9000		},
	{		17, 		1, 			10000		},
	{		26, 		150, 		10590		},
	{		27, 		35, 		9520		},
	{		28, 		50, 		12000		},
	{		29, 		50, 		12590		},
	{		30, 		200, 		13000		},
	{		31, 		150, 		10000		},
	{		32, 		350, 		9500		},
	{		33, 		50, 		12000		},
	{		34, 		20,			12500		},
	{		35, 		1, 			9500		},
	{		37, 		500, 		10000		},
	{		36, 		1, 			25000		},
	{		38, 		5, 			25000		},
	{		9, 			1, 			75000		}
};

//Vehicle offsets
enum e_OffsetTypes {
	VEHICLE_OFFSET_BOOT,
	VEHICLE_OFFSET_HOOD,
	VEHICLE_OFFSET_ROOF
};

//----------------
//Clan

enum ClanData {
	Clan_Id,
	Clan_Name[35],
	Clan_Tag[7],
	Clan_Motd[60],	
	Clan_Weapon,
	Clan_Wallet,
	Clan_Kills,
	Clan_Deaths,
	Clan_XP,
	Clan_Rank1[20],
	Clan_Rank2[20],
	Clan_Rank3[20],
	Clan_Rank4[20],
	Clan_Rank5[20],
	Clan_Rank6[20],
	Clan_Rank7[20],
	Clan_Rank8[20],
	Clan_Rank9[20],
	Clan_Rank10[20],
	Clan_Level,
	Clan_Skin,
	Clan_Addlevel,
	Clan_Warlevel,
	Clan_Setlevel,
	Clan_Baseperk,
	Clan_Team
};

//----------------
//Clan war

enum CWData {
	cw_clan1[35],
	cw_clan2[35],

	cw_clan1score,
	cw_clan2score,

	cw_rounds,
	cw_ready,

	cw_started,
	cw_plantime,

	cw_weap1,
	cw_weap2,
	cw_weap3,
	cw_weap4,
	cw_maxrounds,

	cw_map,
	cw_skin1,
	cw_skin2,
	cw_admin
};

new cwInfo[CWData];

//Clan array
new ClanInfo[MAX_CLANS][ClanData];

new clans, 
	gClanLVAOwner = 0, 
	gClanLVAWar, 
	gClanLVACD
;

enum L_ClanData {
	C_LevelName[30],
	C_LevelXP
};

new const ClanRanks[][L_ClanData] = {
	{"Unranked", 0},
	{"Bronze", 1000},
	{"Silver", 5000},
	{"Gold", 25000},
	{"Platinum", 40000},
	{"Diamond", 80000},
	{"Conqueror", 124000},
	{"Crown", 150000},
	{"Legendary", 300000},
	{"Godlike", 600000},
	{"Ultimate", 1200000}
};

//--------------------------------------------------------//

//Rustler rockets variable
new Text3D: gRustlerLabel[MAX_VEHICLES];
new gRustlerRockets[MAX_VEHICLES];

//Nevada rockets variable
new Text3D: gNevadaLabel[MAX_VEHICLES];
new gNevadaRockets[MAX_VEHICLES];

//---------------------------------------------------------
//Submarines

enum SubData {
	Float: Sub_Pos[4],
	Sub_Id,
	Text3D: Sub_Label,
	Sub_VID
};

new SubInfo[][SubData] = {
	{{2359.7698,518.5786,0.0653,269.3787}},
	{{-923.4133,2650.9199,40.8446,135.7052}},
	{{-1864.8335,2125.1816,0.2410,43.7085}},
	{{-2324.6838,2300.4482,0.1644,179.1869}},
	{{350.4997,205.7276,0.2127,128.4050}},
	{{89.7057,256.7176,0.2673,68.4656}},
	{{-12.2844,336.0608,0.2693,65.0117}},
	{{-501.0495,1134.8297,0.1871,8.1159}},
	{{-577.3995,1245.0864,0.1892,22.3024}},
	{{-562.5742,1390.8442,0.2110,357.0938}},
	{{-529.9067,1582.6030,0.1923,32.6477}},
	{{-613.4544,1645.5481,0.1936,43.1881}}
};

//---------------------------------------------------------
//Interiors

enum IntData {
	IntIco,
	IntName[25],
	Float:IntEnterPos[4],
	Float:IntExitPos[4],
	IntId,	
	IntEnterPickup,
	IntExitPickup,
	Text3D:IntEnterLabel,
	Text3D:IntExitLabel
};

new const Interiors[][IntData] = {
	{25, "Casino", {2194.5601,1677.0518,12.3672}, {2233.8896,1714.1279,1012.3506}, 1},
	{17, "Ranch Shack", {693.7056,1964.3248,5.5391}, {1211.5396,-26.1660,1000.9531}, 3},
	{-1, "LV Gymnasium", {1968.8049,2294.8923,16.4559}, {773.5827,-77.0281,1000.6550}, 7},
	{-1, "North Tower", {704.0296,2778.8835,87.1859}, {719.7679,2775.7905,87.1859}, 0},
	{-1, "Data Center", {468.3531,-2397.0544,20.9015}, {-543.7177,2591.4177,54.4992}, 0},
	{-1, "Security Center", {-184.8809,1552.9513,38.5665}, {-240.0724,1529.7758,29.3609}, 0}
};

//Events

enum E_DATA_ENUM {
	E_NAME[30],

	E_WEAP1[2],
	E_WEAP2[2],
	E_WEAP3[2],
	E_WEAP4[2],

	E_SCORE,
	E_CASH,

	E_TYPE,
	E_SPAWN_TYPE,

	E_SPAWNS,

	E_OPENED,
	E_STARTED,

	E_FREEZE,
	E_INTERIOR,
	E_WORLD,

	E_CHECKPOINTS,
	E_ALLOWLEAVECARS,
	E_MAX_PLAYERS,

	E_AUTO
};

new EventInfo[E_DATA_ENUM];

///////////////////////////////

enum E_RACE_ENUM {
	Float: R_COORDS[3],
	R_TYPE
};

new RaceInfo[MAX_CHECKPOINTS][E_RACE_ENUM];

enum E_SPAWN_ENUM {
	Float: S_COORDS[4]
};

new SpawnInfo[MAX_CHECKPOINTS][E_SPAWN_ENUM];

//---------------------------------------------------------
//Reports system

enum E_REPORT {
	bool:R_VALID,
	R_AGAINST_ID,
	R_AGAINST_NAME[MAX_PLAYER_NAME],
	R_FROM_ID,
	R_FROM_NAME[MAX_PLAYER_NAME],
	R_TIMESTAMP,
	R_REASON[65],
	bool:R_CHECKED,
	R_READ
};

new ReportInfo[MAX_REPORTS][E_REPORT];

//End of File
/* (c) H2O Multiplayer 2018-2020. All rights reserved. */