/*
	SWAT vs Terrorists is a team death-match SA-MP game-mode script. 
	Compatible with SA-MP 0.3.7 and later releases.

	Author: H2O
	Licensed under GNU GPLv3

	(c) 2018-2020 H2O Multiplayer. All rights reserved.
	Website: h2omultiplayer.com

	Stuff related to the inventory system
*/

#include <YSI\y_hooks>
#include <YSI\y_text>
loadtext mode_text[all], mode_text[client], mode_text[newcs], mode_text[dialogs], mode_text[gametexts];

forward DestroyMedkit(medkitid);
public DestroyMedkit(medkitid) {
	DestroyDynamicObject(medkitid);
	return 1;
}

forward DestroyArmourkit(armourkitid);
public DestroyArmourkit(armourkitid) {
	DestroyDynamicObject(armourkitid);
	return 1;
}

forward PickupItem(playerid, objectid);
public PickupItem(playerid, objectid) {
	foreach (new i: Player) { 
		Inv_UpdatePlayerPickupTextDraw(playerid); 
	}
	if (gLootAmt[objectid]) {
		gLootPickable[objectid] = 0;

		if (IsValidDynamicObject(gLootObj[objectid])) {
			DestroyDynamicObject(gLootObj[objectid]);
		}
		gLootObj[objectid] = INVALID_OBJECT_ID;
		if (IsValidDynamicArea(gLootArea[objectid])) {
			DestroyDynamicArea(gLootArea[objectid]);
		}
		if (gLootAmt[objectid] > 0) {
			AddPlayerItem(playerid, gLootItem[objectid], gLootAmt[objectid]);
				
			new message[95];
			format(message, sizeof(message), "Picked up a/an %s", ItemsInfo[gLootItem[objectid]][Item_Name]);
			NotifyPlayer(playerid, message);

			gLootAmt[objectid] = 0;
			gLootItem[objectid] = 0;
			ApplyAnimation(playerid, "MISC", "PICKUP_box", 3.0, 0, 0, 0, 0, 0);
		}
	}
	
	KillTimer(gLootTimer[objectid]);
	gLootExists[objectid] = 0;
	return 1;
}

forward AlterLootPickup(objectid);
public AlterLootPickup(objectid) {
	gLootExists[objectid] = 0;
	gLootPickable[objectid] = 0;
	gLootItem[objectid] = 0;
	if (IsValidDynamicObject(gLootObj[objectid])) {
		DestroyDynamicObject(gLootObj[objectid]);
		gLootObj[objectid] = INVALID_OBJECT_ID;
	}
	gLootObj[objectid] = INVALID_OBJECT_ID;
	if (IsValidDynamicArea(gLootArea[objectid])) {
		DestroyDynamicArea(gLootArea[objectid]);
		gLootArea[objectid] = -1;
	}
	gLootAmt[objectid] = 0;
	return 1;
}

//Medic kits

forward UseMK(playerid);
public UseMK(playerid) {
	new Float:HP;
	GetPlayerHealth(playerid, HP);
	if (gMedicKitHP[playerid] > 0.0) {
		gMedicKitHP[playerid] -= 1.0;
		SetPlayerHealth(playerid, ReturnHealth(playerid) + 1.0);
		GameTextForPlayer(playerid, "~g~+1 HP", 900, 3);
		PlayerInfo[playerid][pHealthGained] += 5.0;
	} else {
		gMedicKitStarted[playerid] = false;
		Text_Send(playerid, $PLAYER_USEMK, pItems[playerid][MK]);
		Text_Send(@pVerified, $SERVER_5x, PlayerInfo[playerid][PlayerName]);

		PlayerPlaySound(playerid, 0, 0.0, 0.0, 0.0);
		KillTimer(RecoverTimer[playerid]);
		AddPlayerItem(playerid, MK, -1);
		PlayerInfo[playerid][pMedkitsUsed]++;
	}
	return 1;
}

//Armour kits

forward UseAK(playerid);
public UseAK(playerid) {
	new Float: AR;
	GetPlayerArmour(playerid, AR);	

	AddPlayerItem(playerid, AK, -1);
	PlayerInfo[playerid][pArmourkitsUsed]++;

	Text_Send(playerid, $PLAYER_USEAK, pItems[playerid][AK]);

	SetPlayerArmour(playerid, AR + 25.0);
	GetPlayerArmour(playerid, AR);

	Text_Send(@pVerified, $SERVER_6x, PlayerInfo[playerid][PlayerName], playerid, AR);

	PlayerPlaySound(playerid, 0, 0.0, 0.0, 0.0);
	return 1;
}

//Functions

//Landmines

forward AlterLandmine(mineid);
public AlterLandmine(mineid) {
	DestroyDynamicObject(gLandmineObj[mineid]);
	gLandmineObj[mineid] = INVALID_OBJECT_ID;
	DestroyDynamicArea(gLandmineArea[mineid]);
	gLandmineExists[mineid] = 0;
	gLandminePlacer[mineid] = INVALID_PLAYER_ID;
	return 1;
}

forward AlterDynamite(dynid);
public AlterDynamite(dynid) {
	DestroyDynamicObject(gDynamiteObj[dynid]);
	gDynamiteObj[dynid] = INVALID_OBJECT_ID;
	DestroyDynamicArea(gDynamiteArea[dynid]);
	gDynamiteExists[dynid] = 0;
	gDynamitePlacer[dynid] = INVALID_PLAYER_ID;
	gDynamiteCD[dynid] = 0;
	KillTimer(gDynamiteTimer[dynid]);
	return 1;
}

//Weapon pickups

forward AlterWeaponPickup(playerid, objectid);
public AlterWeaponPickup(playerid, objectid) {
	DestroyDynamicObject(gWeaponObj[objectid]);
	gWeaponObj[objectid] = INVALID_OBJECT_ID;
	DestroyDynamic3DTextLabel(gWeapon3DLabel[objectid]);
	DestroyDynamicArea(gWeaponArea[objectid]);

	gWeaponExists[objectid] = 0;
	gWeaponPickable[objectid] = 0;

	if (playerid != INVALID_PLAYER_ID && IsPlayerConnected(playerid)) {
		GivePlayerWeapon(playerid, gWeaponID[objectid], gWeaponAmmo[objectid]);
		PlayerInfo[playerid][pPickedWeap] = 0;
		ApplyAnimation(playerid, "MISC", "PICKUP_box", 3.0, 0, 0, 0, 0, 0);
	}
	return 1;
}

//////--------------------------------**

hook OnGameModeInit() {
	for (new i = 0; i < MAX_SLOTS; i++) {
		KillTimer(gLandmineTimer[i]);
		KillTimer(gDynamiteTimer[i]);
		gLandmineExists[i] = 0;
		gLandminePos[i][0] = gLandminePos[i][1] = gLandminePos[i][2] = 0.0;
		gLandminePlacer[i] = INVALID_PLAYER_ID;
		gDynamiteExists[i] = 0;
		gDynamitePos[i][0] = gDynamitePos[i][1] = gDynamitePos[i][2] = 0.0;
		gDynamitePlacer[i] = INVALID_PLAYER_ID;
		gWeaponID[i] = 0;
		gWeaponAmmo[i] = 0;
		gWeaponExists[i] = 0;
		gWeaponPickable[i] = 0;
		gLootItem[i] = 0;
		gLootAmt[i] = 0;
		gLootPickable[i] = 0;
		KillTimer(gLootTimer[i]);
		gLootExists[i] = 0;
	}
	return 1;
}

hook OnPlayerClickTextDraw(playerid, Text:clickedid) {
	if (playerUsingMenu[playerid]) {
		if (clickedid == Text:INVALID_TEXT_DRAW) {
			return Inv_Hide(playerid);
		} else {
			for (new i; i < MAX_LEFT_MENU_ROWS; i++) {
				if (clickedid == menuTextDraw[menuTextDrawID[E_MENU_TEXTDRAW_LEFT_BOX][i]] || clickedid == menuTextDraw[menuTextDrawID[E_MENU_TEXTDRAW_LEFT_MODEL][i]]) {
					if (playerLeftMenuListitem[playerid] == i) {
						if ((GetTickCount() - playerLeftMenuClickTickCount[playerid][i]) <= 200) {
							return OnPlayerClickTextDraw(playerid, menuTextDraw[menuTextDrawID[E_MENU_TEXTDRAW_LEFTBTN]]);
						}
						playerLeftMenuClickTickCount[playerid][i] = GetTickCount();
						return 1;
					}

					playerLeftMenuListitem[playerid] = i;
					Inv_UpdateLeftMenu(playerid);
					return 1;
				}
			}

			for (new i; i < (MAX_RIGHT_MENU_COLUMNS * MAX_RIGHT_MENU_ROWS); i++) {
				if (clickedid == menuTextDraw[menuTextDrawID[E_MENU_TEXTDRAW_RIGHT_MODEL][i]]) {
					if (playerRightMenuListitem[playerid] == i) {
						if ((GetTickCount() - playerRightMenuClickTickCount[playerid][i]) <= 200) {
							return OnPlayerClickTextDraw(playerid, menuTextDraw[menuTextDrawID[E_MENU_TEXTDRAW_MIDDLEBTN]]);
						}
						playerRightMenuClickTickCount[playerid][i] = GetTickCount();
						return 1;
					}

					playerRightMenuListitem[playerid] = i;
					Inv_UpdateRightMenu(playerid);
					return 1;
				}
			}

			if (clickedid == menuTextDraw[menuTextDrawID[E_MENU_TEXTDRAW_SCROLL_UP]]) {
				if (playerLeftMenuPage[playerid] == 0) {
					return 0;
				}

				playerLeftMenuPage[playerid]--;
				playerLeftMenuListitem[playerid] = (MAX_LEFT_MENU_ROWS - 1);
				Inv_UpdateLeftMenu(playerid);
				return 1;
			}

			if (clickedid == menuTextDraw[menuTextDrawID[E_MENU_TEXTDRAW_SCROLL_DOWN]]) {
				if (playerLeftMenuPage[playerid] == (PAGES(nearbyItemsCount[playerid], MAX_LEFT_MENU_ROWS) - 1)) {
					return 0;
				}

				playerLeftMenuPage[playerid]++;
				playerLeftMenuListitem[playerid] = 0;
				Inv_UpdateLeftMenu(playerid);
				Inv_UpdateRightMenu(playerid);
				Inv_UpdatePlayerPickupTextDraw(playerid);
				return 1;
			}

			if (clickedid == menuTextDraw[menuTextDrawID[E_MENU_TEXTDRAW_LEFTBTN]]) {
				if (nearbyItemsCount[playerid] == 0) {
					return Text_Send(playerid, $NO_ITEMS_NEARBY);
				}

				new itemidx = nearbyItemsIdx[playerid][playerLeftMenuListitem[playerid] + (playerLeftMenuPage[playerid] * MAX_LEFT_MENU_ROWS)];
				new itemid = nearbyItems[playerid][playerLeftMenuListitem[playerid] + (playerLeftMenuPage[playerid] * MAX_LEFT_MENU_ROWS)];
				PickupItem(playerid, itemidx);

				new string[128] = "Picking Up ";
				strcat(string, ItemsInfo[itemid][Item_Name]);
				NotifyPlayer(playerid, string);
				Inv_UpdateLeftMenu(playerid);
				Inv_UpdateRightMenu(playerid);
				Inv_UpdatePlayerPickupTextDraw(playerid);
				ApplyAnimation(playerid, "MISC", "PICKUP_box", 3.0, 0, 0, 0, 0, 0);
				return 1;
			}

			if (clickedid == menuTextDraw[menuTextDrawID[E_MENU_TEXTDRAW_RIGHTBTN]]) {
				new items;
				for (new i = 0; i < MAX_ITEMS; i ++) {
					if (pItems[playerid][i]) items ++;
				}
				
				if (items == 0) {
					return Text_Send(playerid, $EMPTY_INVENTORY);
				}

				new itemid = DropPlayerItem(playerid, ownedItems[playerid][playerRightMenuListitem[playerid]], 1);
				if (itemid == -1) return 1;

				new string[128] = "Dropping ";
				strcat(string, ItemsInfo[itemid][Item_Name]);
				NotifyPlayer(playerid, string);
				
				pItems[playerid][playerRightMenuListitem[playerid]] = 0;
				Inv_UpdateLeftMenu(playerid);
				Inv_UpdateRightMenu(playerid);
				Inv_UpdatePlayerPickupTextDraw(playerid);
				Inv_Show(playerid);
				ApplyAnimation(playerid, "GRENADE", "WEAPON_throwu", 3.0, 0, 0, 0, 0, 0);
				return 1;
			}

			if (clickedid == menuTextDraw[menuTextDrawID[E_MENU_TEXTDRAW_MIDDLEBTN]]) {
				new items;
				for (new i = 0; i < MAX_ITEMS; i ++) {
					if (pItems[playerid][i]) items ++;
				}

				if (items == 0) {
					return Text_Send(playerid, $EMPTY_INVENTORY);
				}

				new itemid = ownedItems[playerid][playerRightMenuListitem[playerid]];

				new string[128] = "Using ";
				strcat(string, ItemsInfo[itemid][Item_Name]);
				NotifyPlayer(playerid, string);

				switch (itemid) {
					case MK: PC_EmulateCommand(playerid, "/mk");
					case SK:
					{
						if (!PlayerInfo[playerid][pIsSpying])
						{
							PC_EmulateCommand(playerid, "/spy");
						}
						else PC_EmulateCommand(playerid, "/nospy");
					}
					case LANDMINES: PC_EmulateCommand(playerid, "/landmine");
					case PL: Text_Send(playerid, $PL_INUSE);
					case HELMET: Text_Send(playerid, $HL_INUSE);
					case MASK: Text_Send(playerid, $MSK_INUSE);
					case DYNAMITE: PC_EmulateCommand(playerid, "/suicide");
					case TOOLKIT: PC_EmulateCommand(playerid, "/repair");
					case JETPACK: PC_EmulateCommand(playerid, "/jp");
					case PYROKIT:PC_EmulateCommand(playerid, "/fr");
					case AK: PC_EmulateCommand(playerid, "/ak");
				}
				
				foreach (new i: Player)
				{
					if (IsPlayerConnected(i) && playerUsingMenu[i]) {
						Inv_UpdateLeftMenu(i);
						Inv_UpdatePlayerPickupTextDraw(i);
					}
				}
				
				Inv_Hide(playerid);
				return 1;
			}

			if (clickedid == menuTextDraw[menuTextDrawID[E_MENU_TEXTDRAW_CLOSE]]) {
				return Inv_Hide(playerid);
			}
		}
	}
	return 1;
}

Inv_UpdatePlayerPickupTextDraw(playerid) {
	new count;
	new latest;
	
	for (new i; i < MAX_SLOTS; i++) {
		if (!gLootExists[i]) {
			continue;
		}

		if (gLootPickable[i] && IsPlayerInDynamicArea(playerid, gLootArea[i])) {
			count++;
			latest = gLootItem[i];
		}
	}

	new string[64];
	if (count == 1) {
		format(string, sizeof string, "Press ~k~~CONVERSATION_NO~ to pickup %s", ItemsInfo[latest][Item_Name]);
		NotifyPlayer(playerid, string);
	}
	else if (count == 2) {
		format(string, sizeof string, "Press ~k~~CONVERSATION_NO~ to pickup %s and 1 more item", ItemsInfo[latest][Item_Name]);
		NotifyPlayer(playerid, string);
	}
	else if (count > 2) {
		format(string, sizeof string, "Press ~k~~CONVERSATION_NO~ to pickup %s and %i more items", ItemsInfo[latest][Item_Name], count);
		NotifyPlayer(playerid, string);
	}
}

Inv_Show(playerid) {
	playerLeftMenuPage[playerid] = 0;
	playerLeftMenuListitem[playerid] = 0;
	playerRightMenuListitem[playerid] = 0;

	new bool:skip;
	for (new i; i < menuTextDrawCount; i++) {
		if (menuTextDrawID[E_MENU_TEXTDRAW_EMPTY_LEFT][0] == i || menuTextDrawID[E_MENU_TEXTDRAW_EMPTY_LEFT][1] == i) {
			continue;
		}

		if (menuTextDrawID[E_MENU_TEXTDRAW_EMPTY_RIGHT][0] == i || menuTextDrawID[E_MENU_TEXTDRAW_EMPTY_RIGHT][1] == i) {
			continue;
		}

		for (new x; x < MAX_LEFT_MENU_ROWS; x++) {
			if (menuTextDrawID[E_MENU_TEXTDRAW_LEFT_BOX][x] == i || menuTextDrawID[E_MENU_TEXTDRAW_LEFT_MODEL][x] == i)
			{
				skip = true;
				break;
			}
		}

		for (new x; x < (MAX_RIGHT_MENU_ROWS * MAX_RIGHT_MENU_COLUMNS); x++) {
			if (menuTextDrawID[E_MENU_TEXTDRAW_RIGHT_MODEL][x] == i || menuTextDrawID[E_MENU_TEXTDRAW_RIGHT_NUMBER][x] == i)
			{
				skip = true;
				break;
			}
		}

		if (skip) {
			skip = false;
			continue;
		}
		TextDrawShowForPlayer(playerid, menuTextDraw[i]);
	}

	for (new i; i < menuPlayerTextDrawCount[playerid]; i++) {
		for (new x; x < MAX_LEFT_MENU_ROWS; x++) {
			if (menuPlayerTextDrawID[playerid][E_MENU_TEXTDRAW_LEFT_TEXT][x] == i)
			{
				skip = true;
				break;
			}
		}

		for (new x; x < (MAX_RIGHT_MENU_ROWS * MAX_RIGHT_MENU_COLUMNS); x++) {
			if (menuPlayerTextDrawID[playerid][E_MENU_TEXTDRAW_RIGHT_TEXT][x] == i)
			{
				skip = true;
				break;
			}
		}

		if (skip) {
			skip = false;
			continue;
		}
		PlayerTextDrawShow(playerid, menuPlayerTextDraw[playerid][i]);
	}

	playerUsingMenu[playerid] = true;
	Inv_UpdateLeftMenu(playerid);
	Inv_UpdateRightMenu(playerid);

	return SelectTextDraw(playerid, X11_MAROON);
}

Inv_Hide(playerid) {
	for (new i; i < menuTextDrawCount; i++) {
		TextDrawHideForPlayer(playerid, menuTextDraw[i]);
	}

	for (new i; i < menuPlayerTextDrawCount[playerid]; i++) {
		PlayerTextDrawHide(playerid, menuPlayerTextDraw[playerid][i]);
	}

	playerUsingMenu[playerid] = false;
	return CancelSelectTextDraw(playerid);
}

Inv_UpdateLeftMenu(playerid) {
	if (!playerUsingMenu[playerid]) return 1;
	nearbyItemsCount[playerid] = 0;

	for (new i; i < MAX_SLOTS; i++) {
		if (gLootExists[i] && gLootPickable[i]) {
			if (IsPlayerInDynamicArea(playerid, gLootArea[i])) {
				nearbyItemsIdx[playerid][nearbyItemsCount[playerid]] = i;
				nearbyItems[playerid][nearbyItemsCount[playerid]] = gLootItem[i];
				nearbyItemsCount[playerid]++;
			}
		}
	}

	if (nearbyItemsCount[playerid] == 0) {
		for (new i; i < MAX_LEFT_MENU_ROWS; i++) {
			TextDrawHideForPlayer(playerid, menuTextDraw[menuTextDrawID[E_MENU_TEXTDRAW_LEFT_BOX][i]]);
			TextDrawHideForPlayer(playerid, menuTextDraw[menuTextDrawID[E_MENU_TEXTDRAW_LEFT_MODEL][i]]);
			PlayerTextDrawHide(playerid, menuPlayerTextDraw[playerid][menuPlayerTextDrawID[playerid][E_MENU_TEXTDRAW_LEFT_TEXT][i]]);
		}
	}
	else
	{
		new pages = PAGES(nearbyItemsCount[playerid], MAX_LEFT_MENU_ROWS);
		if (playerLeftMenuPage[playerid] >= pages)
		{
			playerLeftMenuPage[playerid] = pages - 1;
			playerLeftMenuListitem[playerid] = MAX_LEFT_MENU_ROWS - 1;
		}
		else
		{
			if ((playerLeftMenuListitem[playerid] + (playerLeftMenuPage[playerid] * MAX_LEFT_MENU_ROWS)) >= nearbyItemsCount[playerid]) {
				playerLeftMenuListitem[playerid] = ((nearbyItemsCount[playerid] - 1) - (playerLeftMenuPage[playerid] * MAX_LEFT_MENU_ROWS));
			}
		}

		new index;
		for (new i; i < MAX_LEFT_MENU_ROWS; i++) {
			index = (i + (playerLeftMenuPage[playerid] * MAX_LEFT_MENU_ROWS));
			if (index >= nearbyItemsCount[playerid]) {
				TextDrawHideForPlayer(playerid, menuTextDraw[menuTextDrawID[E_MENU_TEXTDRAW_LEFT_BOX][i]]);
				TextDrawHideForPlayer(playerid, menuTextDraw[menuTextDrawID[E_MENU_TEXTDRAW_LEFT_MODEL][i]]);
				PlayerTextDrawHide(playerid, menuPlayerTextDraw[playerid][menuPlayerTextDrawID[playerid][E_MENU_TEXTDRAW_LEFT_TEXT][i]]);
			}
			else
			{
				if (playerLeftMenuListitem[playerid] == i) {
					TextDrawBoxColor(menuTextDraw[menuTextDrawID[E_MENU_TEXTDRAW_LEFT_BOX][i]], SELECTED);

					new itemName[10 + 3];
					for (new x; x < (sizeof itemName - 3); x++) {
						itemName[x] = ItemsInfo[nearbyItems[playerid][index]][Item_Name][x];
					}
					if (strlen(ItemsInfo[nearbyItems[playerid][index]][Item_Name]) > (sizeof itemName - 3)) {
						strcat(itemName, "...");
					}
				}
				else
				{
					TextDrawBoxColor(menuTextDraw[menuTextDrawID[E_MENU_TEXTDRAW_LEFT_BOX][i]], 50);
				}

				TextDrawShowForPlayer(playerid, menuTextDraw[menuTextDrawID[E_MENU_TEXTDRAW_LEFT_BOX][i]]);

				TextDrawSetPreviewModel(menuTextDraw[menuTextDrawID[E_MENU_TEXTDRAW_LEFT_MODEL][i]], ItemsInfo[nearbyItems[playerid][index]][Item_Object]);
				TextDrawShowForPlayer(playerid, menuTextDraw[menuTextDrawID[E_MENU_TEXTDRAW_LEFT_MODEL][i]]);

				PlayerTextDrawSetString(playerid, menuPlayerTextDraw[playerid][menuPlayerTextDrawID[playerid][E_MENU_TEXTDRAW_LEFT_TEXT][i]], ItemsInfo[nearbyItems[playerid][index]][Item_Name]);
				PlayerTextDrawShow(playerid, menuPlayerTextDraw[playerid][menuPlayerTextDrawID[playerid][E_MENU_TEXTDRAW_LEFT_TEXT][i]]);
			}
		}
	}

	new pages = PAGES(nearbyItemsCount[playerid], MAX_LEFT_MENU_ROWS);
	if (pages > 1) {
		if (playerLeftMenuPage[playerid] < 0) {
			playerLeftMenuPage[playerid] = 0;
		}
		else if (playerLeftMenuPage[playerid] >= pages) {
			playerLeftMenuPage[playerid] = pages - 1;
		}

		new Float:y = 172.000000;
		new Float:height;
		ScrollBar(playerLeftMenuPage[playerid], pages, y, 14.6, height);

		PlayerTextDrawDestroy(playerid, menuPlayerTextDraw[playerid][menuPlayerTextDrawID[playerid][E_MENU_TEXTDRAW_SCROLL]]);

		menuPlayerTextDraw[playerid][menuPlayerTextDrawID[playerid][E_MENU_TEXTDRAW_SCROLL]] = CreatePlayerTextDraw(playerid, 246.000000, y, "_");
		PlayerTextDrawBackgroundColor(playerid, menuPlayerTextDraw[playerid][menuPlayerTextDrawID[playerid][E_MENU_TEXTDRAW_SCROLL]], 255);
		PlayerTextDrawFont(playerid, menuPlayerTextDraw[playerid][menuPlayerTextDrawID[playerid][E_MENU_TEXTDRAW_SCROLL]], 1);
		PlayerTextDrawLetterSize(playerid, menuPlayerTextDraw[playerid][menuPlayerTextDrawID[playerid][E_MENU_TEXTDRAW_SCROLL]], 0.000000, height);
		PlayerTextDrawColor(playerid, menuPlayerTextDraw[playerid][menuPlayerTextDrawID[playerid][E_MENU_TEXTDRAW_SCROLL]], -1);
		PlayerTextDrawSetOutline(playerid, menuPlayerTextDraw[playerid][menuPlayerTextDrawID[playerid][E_MENU_TEXTDRAW_SCROLL]], 0);
		PlayerTextDrawSetProportional(playerid, menuPlayerTextDraw[playerid][menuPlayerTextDrawID[playerid][E_MENU_TEXTDRAW_SCROLL]], 1);
		PlayerTextDrawSetShadow(playerid, menuPlayerTextDraw[playerid][menuPlayerTextDrawID[playerid][E_MENU_TEXTDRAW_SCROLL]], 1);
		PlayerTextDrawUseBox(playerid, menuPlayerTextDraw[playerid][menuPlayerTextDrawID[playerid][E_MENU_TEXTDRAW_SCROLL]], 1);
		PlayerTextDrawBoxColor(playerid, menuPlayerTextDraw[playerid][menuPlayerTextDrawID[playerid][E_MENU_TEXTDRAW_SCROLL]], -1768515896);
		PlayerTextDrawTextSize(playerid, menuPlayerTextDraw[playerid][menuPlayerTextDrawID[playerid][E_MENU_TEXTDRAW_SCROLL]], 247.000000, 0.000000);
		PlayerTextDrawSetSelectable(playerid, menuPlayerTextDraw[playerid][menuPlayerTextDrawID[playerid][E_MENU_TEXTDRAW_SCROLL]], 0);

		PlayerTextDrawShow(playerid, menuPlayerTextDraw[playerid][menuPlayerTextDrawID[playerid][E_MENU_TEXTDRAW_SCROLL]]);
	}
	else
	{
		PlayerTextDrawHide(playerid, menuPlayerTextDraw[playerid][menuPlayerTextDrawID[playerid][E_MENU_TEXTDRAW_SCROLL]]);
	}

	new string[128];
	format(string, sizeof string, "Items close to you: ~y~%i", nearbyItemsCount[playerid]);
	PlayerTextDrawSetString(playerid, menuPlayerTextDraw[playerid][menuPlayerTextDrawID[playerid][E_MENU_TEXTDRAW_LEFT_COUNT]], string);

	if (nearbyItemsCount[playerid] == 0) {
		TextDrawShowForPlayer(playerid, menuTextDraw[menuTextDrawID[E_MENU_TEXTDRAW_EMPTY_LEFT][0]]);
		TextDrawShowForPlayer(playerid, menuTextDraw[menuTextDrawID[E_MENU_TEXTDRAW_EMPTY_LEFT][1]]);
	}
	else
	{
		TextDrawHideForPlayer(playerid, menuTextDraw[menuTextDrawID[E_MENU_TEXTDRAW_EMPTY_LEFT][0]]);
		TextDrawHideForPlayer(playerid, menuTextDraw[menuTextDrawID[E_MENU_TEXTDRAW_EMPTY_LEFT][1]]);
	}    
	return 1;
}

Inv_UpdateRightMenu(playerid) {
	if (!playerUsingMenu[playerid]) return 1;

	ownedItemsCount[playerid] = 0;

	new items, max_items;
	for (new i = 0; i < MAX_ITEMS; i ++) {
		if (pItems[playerid][i]) {
			ownedItems[playerid][ownedItemsCount[playerid]] = i;
			ownedItemsCount[playerid] ++;
			items += pItems[playerid][i];
		}
		max_items += ItemsInfo[i][Item_Max];
	}
	if (!ownedItemsCount[playerid]) {
		for (new i; i < ownedItemsCount[playerid]; i++) {
			TextDrawHideForPlayer(playerid, menuTextDraw[menuTextDrawID[E_MENU_TEXTDRAW_RIGHT_MODEL][i]]);
			TextDrawHideForPlayer(playerid, menuTextDraw[menuTextDrawID[E_MENU_TEXTDRAW_RIGHT_NUMBER][i]]);
			PlayerTextDrawHide(playerid, menuPlayerTextDraw[playerid][menuPlayerTextDrawID[playerid][E_MENU_TEXTDRAW_RIGHT_TEXT][i]]);
		}

		new string[128];
		format(string, sizeof string, "Items in your inventory: ~y~0/%i", max_items);
		PlayerTextDrawSetString(playerid, menuPlayerTextDraw[playerid][menuPlayerTextDrawID[playerid][E_MENU_TEXTDRAW_RIGHT_COUNT]], string);

		TextDrawShowForPlayer(playerid, menuTextDraw[menuTextDrawID[E_MENU_TEXTDRAW_EMPTY_RIGHT][0]]);
		TextDrawShowForPlayer(playerid, menuTextDraw[menuTextDrawID[E_MENU_TEXTDRAW_EMPTY_RIGHT][1]]);
	}
	else
	{
		if (playerRightMenuListitem[playerid] > ownedItemsCount[playerid]) {
			playerRightMenuListitem[playerid] = ownedItemsCount[playerid];
		}

		for (new i; i < ownedItemsCount[playerid]; i++) {
			if (ownedItems[playerid][i]) {
				if (playerRightMenuListitem[playerid] == i) {
					TextDrawBackgroundColor(menuTextDraw[menuTextDrawID[E_MENU_TEXTDRAW_RIGHT_MODEL][i]], SELECTED);
				} else {
					TextDrawBackgroundColor(menuTextDraw[menuTextDrawID[E_MENU_TEXTDRAW_RIGHT_MODEL][i]], 100);
				}

				new itemName[30];
				format(itemName, sizeof(itemName) - 3, "%s (%d)", ItemsInfo[ownedItems[playerid][i]][Item_Name], pItems[playerid][ownedItems[playerid][i]]);
				if (strlen(ItemsInfo[ownedItems[playerid][i]][Item_Name]) > (sizeof itemName - 3)) {
					strcat(itemName, "...");
				}
				PlayerTextDrawSetString(playerid, menuPlayerTextDraw[playerid][menuPlayerTextDrawID[playerid][E_MENU_TEXTDRAW_RIGHT_TEXT][i]], itemName);

				TextDrawSetPreviewModel(menuTextDraw[menuTextDrawID[E_MENU_TEXTDRAW_RIGHT_MODEL][i]], ItemsInfo[ownedItems[playerid][i]][Item_Object]);
				TextDrawShowForPlayer(playerid, menuTextDraw[menuTextDrawID[E_MENU_TEXTDRAW_RIGHT_MODEL][i]]);

				TextDrawShowForPlayer(playerid, menuTextDraw[menuTextDrawID[E_MENU_TEXTDRAW_RIGHT_NUMBER][i]]);
				PlayerTextDrawShow(playerid, menuPlayerTextDraw[playerid][menuPlayerTextDrawID[playerid][E_MENU_TEXTDRAW_RIGHT_TEXT][i]]);
			}
		}

		for (new i = ownedItemsCount[playerid]; i < MAX_ITEMS; i++) {
			TextDrawHideForPlayer(playerid, menuTextDraw[menuTextDrawID[E_MENU_TEXTDRAW_RIGHT_MODEL][i]]);
			TextDrawHideForPlayer(playerid, menuTextDraw[menuTextDrawID[E_MENU_TEXTDRAW_RIGHT_NUMBER][i]]);
			PlayerTextDrawHide(playerid, menuPlayerTextDraw[playerid][menuPlayerTextDrawID[playerid][E_MENU_TEXTDRAW_RIGHT_TEXT][i]]);
		}

		new string[128];
		format(string, sizeof string, "Items in your inventory: ~y~%i/%i", items, max_items);
		PlayerTextDrawSetString(playerid, menuPlayerTextDraw[playerid][menuPlayerTextDrawID[playerid][E_MENU_TEXTDRAW_RIGHT_COUNT]], string);

		TextDrawHideForPlayer(playerid, menuTextDraw[menuTextDrawID[E_MENU_TEXTDRAW_EMPTY_RIGHT][0]]);
		TextDrawHideForPlayer(playerid, menuTextDraw[menuTextDrawID[E_MENU_TEXTDRAW_EMPTY_RIGHT][1]]);
	}    
	return 1;
}

//Loot system

DropPlayerItem(playerid, item, amount) {
	if (GetPlayerInterior(playerid) != 0 || GetPlayerVirtualWorld(playerid) != 0 || item == PL || amount == 0 ||
		pItems[playerid][item] < amount) return -1;
	pItems[playerid][item] -= amount;

	new Float: Checkpos[3], Float: Check_X;
	GetPlayerPos(playerid, Checkpos[0], Checkpos[1], Checkpos[2]);

	CA_FindZ_For2DCoord(Checkpos[0], Checkpos[1], Check_X);
	if (Checkpos[2] < Check_X) return -1;

	new
		Float: FX,
		Float: FY,
		Float: FZ
	;

	GetPlayerPos(playerid, FX, FY, FZ);
	
	new dropped = 0;

	for (new i = 0; i < MAX_SLOTS; i++) {
		if (!gLootExists[i]) {	
			GetPlayerPos(playerid, FX, FY, FZ);
			CA_FindZ_For2DCoord(FX, FY, FZ);

			gLootExists[i] = 1;
			gLootPickable[i] = 0;
			
			gLootItem[i] = item;
			gLootAmt[i] = amount;
			
			new Float: RX = 0.0;
			
			if (item != MASK && item != HELMET && item != LANDMINES) {
				RX = 90.0;
			}
			
			gLootObj[i] = CreateDynamicObject(ItemsInfo[item][Item_Object], FX + 0.5, FY, FZ + 0.1, RX, 0.0, 12.5);
			gLootPickable[i] = 1;
			
			gLootArea[i] = CreateDynamicCircle(FX, FY, 1.0);
			
			KillTimer(gLootTimer[i]);
			gLootTimer[i] = SetTimerEx("AlterLootPickup", 55000, false, "i", i);
			
			dropped = 1;

			break;
		}
	}
	
	if (!dropped) return -1;
	
	Inv_UpdateRightMenu(playerid);

	return item;
}

stock DropPlayerItems(playerid) {
	if (GetPlayerInterior(playerid) != 0 || GetPlayerVirtualWorld(playerid) != 0) return 1;

	new Float: Checkpos[3], Float: Check_X;
	GetPlayerPos(playerid, Checkpos[0], Checkpos[1], Checkpos[2]);

	CA_FindZ_For2DCoord(Checkpos[0], Checkpos[1], Check_X);
	if (Checkpos[2] < Check_X) return 1;

	new pitems;
	for (new i = 0; i < sizeof(ItemsInfo); i++) {
		if (pItems[playerid][i] && i != PL) {
			pitems ++;
		}
	}

	new
		Float: FX,
		Float: FY,
		Float: FZ
	;

	GetPlayerPos(playerid, FX, FY, FZ);

	if (pitems) {
		for (new i = 0; i < MAX_SLOTS; i++) {
			if (!gLootExists[i]) {
				for (new x = 0; x < MAX_ITEMS; x++) {
					if (pItems[playerid][x] > 0 && x != PL) {
						new Float: RX = 0.0;

						if (x != MASK && x != HELMET && x != LANDMINES) {
							RX = 90.0;
						}
					
						gLootPickable[i] = 0;
						CA_FindZ_For2DCoord(FX, FY, FZ);
						gLootItem[i] = x;
						gLootAmt[i] = pItems[playerid][x];
						gLootObj[i] = CreateDynamicObject(ItemsInfo[x][Item_Object], FX, FY, FZ + 0.1, RX, 0.0, 12.5);
						gLootArea[i] = CreateDynamicCircle(FX, FY, 1.0);
						gLootPickable[i] = 1;
						RemovePlayerItem(playerid, x);

						new randposchange = random(7);
						switch (randposchange) {
							case 0: FX += 2.0, FY -= 2.0;
							case 1: FX += 2.2, FY -= 2.2;
							case 2: FX += 2.4, FY -= 2.4;
							case 3: FX += 2.6, FY -= 2.6;
							case 4: FX -= 2.0, FY += 2.0;
							case 5: FX -= 2.2, FY += 2.2;
							case 6: FX -= 2.4, FY += 2.4;
						}
						KillTimer(gLootTimer[i]);
						gLootTimer[i] = SetTimerEx("AlterLootPickup", 7000, false, "i", i);
						gLootExists[i] = 1;
						break;
					}
				}
			}
		}
	}
	
	Inv_UpdateRightMenu(playerid);
	return 1;
}

//Player items

MaxPlayerItem(item) {
	return ItemsInfo[item][Item_Max];
}

ResetPlayerItems(playerid) {
	if (IsPlayerAttachedObjectSlotUsed(playerid, 2))
	{
		RemovePlayerAttachedObject(playerid, 2);
	}

	if (IsPlayerAttachedObjectSlotUsed(playerid, 3))
	{
		RemovePlayerAttachedObject(playerid, 3);
	}

	if (IsPlayerAttachedObjectSlotUsed(playerid, 5))
	{
		RemovePlayerAttachedObject(playerid, 5);
	}  

	for (new i = 0; i < MAX_ITEMS; i++) {
		pItems[playerid][i] = 0;
		pItemList[i][playerid] = 0;
		pSlotList[i][playerid] = 0;
	}    
	return 1;
}

//Items core

AddPlayerItem(playerid, item, amount) {
	new maximum = ItemsInfo[item][Item_Max];

	switch (item) {
		case HELMET, MASK, PL:
		{
			if (pItems[playerid][item] + amount > maximum) {		
				DropPlayerItem(playerid, item, (pItems[playerid][item] + amount) - maximum);

				if (pItems[playerid][item] + amount > maximum) {
					pItems[playerid][item] = maximum;
				}

				printf("[Inventory] Couldn't add %d of %s to %s[%d]", amount, ItemsInfo[item][Item_Name], PlayerInfo[playerid][PlayerName], playerid);
			}
			else
			{
				if (pItems[playerid][item] + amount > pItems[playerid][item]) {	
					pItems[playerid][item] += amount;
					printf("[Inventory] Added %d of %s to %s[%d] - total: %d", amount, ItemsInfo[item][Item_Name], PlayerInfo[playerid][PlayerName], playerid, pItems[playerid][item]);
				}
				else
				{	
					pItems[playerid][item] += amount;
					printf("[Inventory] Added %d of %s to %s[%d] - total: %d", amount, ItemsInfo[item][Item_Name], PlayerInfo[playerid][PlayerName], playerid, pItems[playerid][item]);
				}
			}
		}
		default:
		{
			if (pItems[playerid][item] + amount > maximum) {
				DropPlayerItem(playerid, item, (pItems[playerid][item] + amount) - maximum);
				pItems[playerid][item] = maximum;	
				printf("[Inventory] Couldn't add %d of %s to %s[%d], max: %d", amount, ItemsInfo[item][Item_Name], PlayerInfo[playerid][PlayerName], playerid, maximum);
			}
			else
			{
				if (pItems[playerid][item] + amount > pItems[playerid][item]) {	
					pItems[playerid][item] += amount;
					printf("[Inventory] Added %d of %s to %s[%d] - total: %d", amount, ItemsInfo[item][Item_Name], PlayerInfo[playerid][PlayerName], playerid, pItems[playerid][item]);
				}
				else
				{	
					pItems[playerid][item] += amount;
					printf("[Inventory] Taken %d of %s to %s[%d], total: %d", amount, ItemsInfo[item][Item_Name], PlayerInfo[playerid][PlayerName], playerid, pItems[playerid][item]);
				}
			}		
		}
	}

	switch (item) {
		case HELMET: 
		{
			AttachHelmet(playerid);
		}
		case MASK: 
		{
			AttachMask(playerid);
		}
		case DYNAMITE: 
		{
			AttachDynamite(playerid);
		}
	}
	
	Inv_UpdateRightMenu(playerid);
	return 1;
}


RemovePlayerItem(playerid, item) {
	pItems[playerid][item] = 0;

	switch (item) {
		case HELMET: AttachHelmet(playerid);
		case MASK: AttachMask(playerid);
		case DYNAMITE: AttachDynamite(playerid);
	}
	
	Inv_UpdateRightMenu(playerid);
	return 1;
}

//Hooks

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
	if (PRESSED(KEY_CTRL_BACK)) {
		if (GetPlayerAmmo(playerid) != 0 && GetWeaponModel(GetPlayerWeapon(playerid)) != -1 && GetPlayerState(playerid) == PLAYER_STATE_ONFOOT && GetPlayerInterior(playerid) == 0
			&& GetWeaponSlot(GetPlayerWeapon(playerid)) != 0) {
			new Float: Checkpos[3], Float: Check_X;
			GetPlayerPos(playerid, Checkpos[0], Checkpos[1], Checkpos[2]);

			CA_FindZ_For2DCoord(Checkpos[0], Checkpos[1], Check_X);
			if (Checkpos[2] < Check_X) return 1;

			for (new a = 0; a < MAX_SLOTS; a++) {
				if (!gWeaponExists[a]) {
					new
						Float: X,
						Float: Y,
						Float: Z
					;

					GetPlayerPos(playerid, X, Y, Z);
					CA_FindZ_For2DCoord(X, Y, Z);

					gWeaponExists[a] = 1;
					gWeaponPickable[a] = 0;

					gWeaponObj[a] = CreateDynamicObject(GetWeaponModel(GetPlayerWeapon(playerid)), X, Y, Z, 90.0, 0.0, 0.0);

					new weap_label[45];
					format(weap_label, sizeof(weap_label), "%s(%d)", ReturnWeaponName(GetPlayerWeapon(playerid)), GetPlayerAmmo(playerid));
					gWeapon3DLabel[a] = CreateDynamic3DTextLabel(weap_label, 0xFFFFFFFF, X, Y, Z, 50.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, 0, 0);

					gWeaponID[a] = GetPlayerWeapon(playerid);
					gWeaponAmmo[a] = GetPlayerAmmo(playerid);

					gWeaponPickable[a] = 1;
					gWeaponTimer[a] = SetTimerEx("AlterWeaponPickup", 45000, false, "ii", INVALID_PLAYER_ID, a);
					SetPlayerAmmo(playerid, GetPlayerWeapon(playerid), 0);

					gWeaponArea[a] = CreateDynamicCircle(X, Y, 2.5);
					PlayerInfo[playerid][pWeaponsDropped] ++;

					break;
				}
			}
		}
	}
	if (PRESSED(KEY_NO)) {
		if (pPickupCD[playerid] <= GetTickCount()) {
			for (new x = 0; x < MAX_SLOTS; x++) {
				if (gLootExists[x]) {
					if (gLootPickable[x] && IsPlayerInDynamicArea(playerid, gLootArea[x])) {
						PickupItem(playerid, x);
						gLootPickable[x] = 0;
						pPickupCD[playerid] = GetTickCount() + 1000;
						break;
					}
				} 

				if (gWeaponExists[x] && gWeaponPickable[x]) {
					if (IsPlayerInDynamicArea(playerid, gWeaponArea[x])) {
						if (!PlayerInfo[playerid][pPickedWeap]) {
							new weapon, ammo;
							GetPlayerWeaponData(playerid, GetWeaponSlot(gWeaponID[x]), weapon, ammo);

							if (weapon && weapon != gWeaponID[x]) {
								if (PlayerInfo[playerid][pAcceptedWeap] == 0) {
									new weapon_name[2][35];

									GetWeaponName(weapon, weapon_name[0], 35);
									GetWeaponName(gWeaponID[x], weapon_name[1], 35);

									Text_Send(playerid, $CLIENT_410x, weapon_name[0], weapon_name[1]);
									PlayerInfo[playerid][pAcceptedWeap] = 1;
								} else {
									gWeaponPickable[x] = 0;

									PlayerInfo[playerid][pPickedWeap] = 1;
									PlayerInfo[playerid][pAcceptedWeap] = 0;

									KillTimer(gWeaponTimer[x]);

									AlterWeaponPickup(playerid, x);
									PlayerInfo[playerid][pAcceptedWeap] = 0;
									pPickupCD[playerid] = GetTickCount() + 3000;
									PlayerInfo[playerid][pWeaponsPicked] ++;
								}
							} else {
								gWeaponPickable[x] = 0;
								PlayerInfo[playerid][pPickedWeap] = 1;

								KillTimer(gWeaponTimer[x]);
								AlterWeaponPickup(playerid, x);
								pPickupCD[playerid] = GetTickCount() + 3000;
								PlayerInfo[playerid][pWeaponsPicked] ++;
							}

							break;
						}
					}
				}
			}
		}
	}
	if (PRESSED(KEY_FIRE)) {
		if (!PlayerInfo[playerid][pAdminDuty] && GetPlayerWeapon(playerid) == WEAPON_TEARGAS && GetPlayerState(playerid) == PLAYER_STATE_ONFOOT) {
			new Float: X, Float: Y, Float: Z;
			GetPlayerPos(playerid, X, Y, Z);
			GetXYZInfrontOfPlayer(playerid, X, Y, 3.7);

			foreach (new i: Player) {
				if (IsPlayerInRangeOfPoint(i, 5.0, X, Y, Z) && pCooldown[playerid][32] <= gettime()) {
					if (GetPlayerState(i) == PLAYER_STATE_ONFOOT && i != playerid && !PlayerInfo[i][pAdminDuty]) {
						pCooldown[playerid][32] = gettime() + 7;

						if (IsPlayerAttachedObjectSlotUsed(playerid, 3)) {	
							switch (pItems[i][MASK]) {
								case 1: {
									DamagePlayer(i, 3.5, playerid, WEAPON_TEARGAS, BODY_PART_UNKNOWN, true);
									ApplyAnimation(i, "ped", "gas_cwr", 4.1, 0, 0, 0, 0, 0);
								}   
								case 2: {
									DamagePlayer(i, 2.3, playerid, WEAPON_TEARGAS, BODY_PART_UNKNOWN, true);
									ApplyAnimation(i, "ped", "gas_cwr", 4.1, 0, 0, 0, 0, 0);		         	    	
								}			         	    			         	    
							}    
						} else {
							DamagePlayer(i, 10.5, playerid, WEAPON_TEARGAS, BODY_PART_UNKNOWN, true);
							ApplyAnimation(i, "ped", "gas_cwr", 4.1, 0, 0, 0, 0, 0);
						}
					}
				}
			}
		}
	}
	return 1;
}

hook OnPlayerEnterDynArea(playerid, areaid) {
	Inv_UpdatePlayerPickupTextDraw(playerid);
	for (new i = 0; i < MAX_SLOTS; i++) {
		if (gWeaponExists[i] && gWeaponArea[i] == areaid) {
			new message[100];
			format(message, sizeof(message), "Press N to pickup %s.", ReturnWeaponName(gWeaponID[i]));
			NotifyPlayer(playerid, message);
			break;
		}
	}

	if (IsPlayerSpawned(playerid) && !GetPlayerInterior(playerid) && !GetPlayerVirtualWorld(playerid) && !AntiSK[playerid]) {
		for (new x = 0; x < MAX_SLOTS; x++) {
			if (gLandmineExists[x] == 1 && gLandmineArea[x] == areaid) {
				if (gLandminePlacer[x] == INVALID_PLAYER_ID || (gLandminePlacer[x] != INVALID_PLAYER_ID && pTeam[gLandminePlacer[x]] != pTeam[playerid])) {
					KillTimer(gLandmineTimer[x]);
					AlterLandmine(x);

					CreateExplosion(gLandminePos[x][0], gLandminePos[x][1], gLandminePos[x][2], 1, 0.3);

					if (gLandminePlacer[x] != INVALID_PLAYER_ID) {
						DamagePlayer(playerid, 85.6, INVALID_PLAYER_ID, WEAPON_EXPLOSION, BODY_PART_UNKNOWN, false);
					}
					else {
						DamagePlayer(playerid, 85.6, gLandminePlacer[x], WEAPON_EXPLOSION, BODY_PART_UNKNOWN, false);
					}

					gLandminePlacer[x] = INVALID_PLAYER_ID;
					break;
				}
			}
		}

		for (new i = 0; i < MAX_SLOTS; i++) {
			if (gCarepackExists[i] && gCarepackArea[i] == areaid && gCarepackUsable[i]) {
				gCarepackUsable[i] = 0;
				new random_event = random(6);
				switch (random_event) {
					case 0:  {
						NotifyPlayer(playerid, "~r~Unpack: ~w~3 Medkits, Sniper Rifle and $5000.");
						GivePlayerCash(playerid, 5000);
						AddPlayerItem(playerid, MK, 3);
						GivePlayerWeapon(playerid, WEAPON_SNIPER, 25);
					}	
					case 1:  {
						NotifyPlayer(playerid, "~r~Unpack: ~w~5 Medkits, Desert Eagle and $10000.");
						GivePlayerCash(playerid, 10000);
						AddPlayerItem(playerid, MK, 5);
						GivePlayerWeapon(playerid, WEAPON_DEAGLE, 55);
					}
					case 2:  {
						NotifyPlayer(playerid, "~r~Unpack: ~w~2 Medkit, Grenade and Sniper Rifle.");
						AddPlayerItem(playerid, MK, 2);
						GivePlayerWeapon(playerid, WEAPON_SNIPER, 65);
						GivePlayerWeapon(playerid, WEAPON_GRENADE, 7);
					}
					case 3:  {
						NotifyPlayer(playerid, "~r~Unpack: ~w~2 Spy kits, Tear-gas, 5 Medkits and $15,000.");
						GivePlayerCash(playerid, 15000);
						AddPlayerItem(playerid, MK, 5);
						AddPlayerItem(playerid, SK, 2);
					}
					case 4:  {
						NotifyPlayer(playerid, "~r~Unpack: ~w~Rocket Launcher and Pilot License (level 1).");
						AddPlayerItem(playerid, PL, 1);
						GivePlayerWeapon(playerid, WEAPON_ROCKETLAUNCHER, 5);
					}
					case 5:  {
						NotifyPlayer(playerid, "~r~Unpack: ~w~Grenade, Silenced Pistol, Sniper Rifle and $25,000.");
						GivePlayerCash(playerid, 25000);
						GivePlayerWeapon(playerid, WEAPON_SNIPER, 50);
						GivePlayerWeapon(playerid, WEAPON_SILENCED, 95);
						GivePlayerWeapon(playerid, WEAPON_GRENADE, 7);
					}																														
				}

				KillTimer(gCarepackTimer[i]);
				DestroyDynamicObject(gCarepackObj[i]);
				gCarepackObj[i] = INVALID_OBJECT_ID;
				DestroyDynamic3DTextLabel(gCarepack3DLabel[i]);

				DestroyDynamicArea(areaid);
				gCarepackPos[i][0] = gCarepackPos[i][1] = gCarepackPos[2][0] = 0.0;
				gCarepackExists[i] = 0;

				ApplyAnimation(playerid, "BOMBER", "BOM_Plant", 4.0, 0, 0, 0, 0, 0);
				break;
			}
		}
	}
	return 1;
}

hook OnPlayerLeaveDynArea(playerid, areaid) {
	Inv_UpdatePlayerPickupTextDraw(playerid);
	return 1;
}

//Inventory Commands

alias:inv("inventory");
CMD:inv(playerid) {
	if (pDuelInfo[playerid][pDInMatch] == 1) return Text_Send(playerid, $COMMAND_INDUEL);
	if (PlayerInfo[playerid][pDeathmatchId] > -1) return Text_Send(playerid, $COMMAND_INDM);
	if (Iter_Contains(ePlayers, playerid)) return Text_Send(playerid, $COMMAND_INEVENT);
	if (Iter_Contains(CWCLAN1, playerid) || Iter_Contains(CWCLAN2, playerid)) return Text_Send(playerid, $COMMAND_INCW);
	if (!IsPlayerSpawned(playerid)) return Text_Send(playerid, $COMMAND_NOTSPAWNED);
	if (PlayerInfo[playerid][pAdminDuty]) return Text_Send(playerid, $COMMAND_ADMINDUTY);

	Inv_Show(playerid);
	return 1;
}

//Camouflage

CMD:camo(playerid) {
	if (pDuelInfo[playerid][pDInMatch] == 1) return Text_Send(playerid, $COMMAND_INDUEL);
	if (PlayerInfo[playerid][pDeathmatchId] > -1) return Text_Send(playerid, $COMMAND_INDM);
	if (Iter_Contains(ePlayers, playerid)) return Text_Send(playerid, $COMMAND_INEVENT);
	if (Iter_Contains(CWCLAN1, playerid) || Iter_Contains(CWCLAN2, playerid)) return Text_Send(playerid, $COMMAND_INCW);
	if (Iter_Contains(PUBGPlayers, playerid)) return Text_Send(playerid, $COMMAND_INPUBG);
	if (!pCamo[playerid]) return Text_Send(playerid, $CLIENT_446x);
	if (PlayerInfo[playerid][pLastHitTick] > gettime()) return Text_Send(playerid, $JUSTHIT, PlayerInfo[playerid][pLastHitTick] - gettime());
	if (gInvisible[playerid]) return Text_Send(playerid, $CLIENT_447x);

	if (gCamoActivated[playerid]) {
		gCamoActivated[playerid] = 0;
		SetPlayerColor(playerid, TeamInfo[pTeam[playerid]][Team_Color]);
		PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
	}
	else
	{
		gCamoActivated[playerid] = 1;
		gCamoTime[playerid] = gettime() + 500;
		PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
		Text_Send(playerid, $CAMO_ALERT);
		SetPlayerColor(playerid, TeamInfo[pTeam[playerid]][Team_Inv_Color]);
	}    
	return 1;
}

//Medic kits

CMD:mk(playerid) {
	if (pDuelInfo[playerid][pDInMatch] == 1) return Text_Send(playerid, $COMMAND_INDUEL);
	if (PlayerInfo[playerid][pDeathmatchId] > -1) return Text_Send(playerid, $COMMAND_INDM);
	if (Iter_Contains(ePlayers, playerid)) return Text_Send(playerid, $COMMAND_INEVENT);
	if (Iter_Contains(CWCLAN1, playerid) || Iter_Contains(CWCLAN2, playerid)) return Text_Send(playerid, $COMMAND_INCW);

	if (pItems[playerid][MK] > 0) {
		if (pCooldown[playerid][25] < gettime()) {
			if (ReturnHealth(playerid) >= 100) return Text_Send(playerid, $CLIENT_448x);

			pCooldown[playerid][25] = gettime() + 15;

			KillTimer(RecoverTimer[playerid]);
			gMedicKitStarted[playerid] = true;
			gMedicKitHP[playerid] = 100.0 - ReturnHealth(playerid);
			RecoverTimer[playerid] = SetTimerEx("UseMK", 100, true, "i", playerid);
			PlayerPlaySound(playerid, 1068, 0.0, 0.0, 0.0);
			AnimPlayer(playerid, "ROB_BANK", "CAT_Safe_Open", 8.0, 0, 0, 0, 0, 0);

			new Float: X, Float: Y, Float: Z;
			GetXYZInfrontOfPlayer(playerid, X, Y, 0.7);
			CA_FindZ_For2DCoord(X, Y, Z);

			new medkit = CreateDynamicObject(11738, X, Y, Z, 0.0, 0.0, 0.0);
			SetTimerEx("DestroyMedkit", 3500, false, "i", medkit);
		} else {
			Text_Send(playerid, $COOLDOWN_TIMELEFT, pCooldown[playerid][25] - gettime());
		}
	}  else Text_Send(playerid, $CLIENT_446x);
	return 1;
}

//Armour kits

CMD:ak(playerid) {
	if (pDuelInfo[playerid][pDInMatch] == 1) return Text_Send(playerid, $COMMAND_INDUEL);
	if (PlayerInfo[playerid][pDeathmatchId] > -1) return Text_Send(playerid, $COMMAND_INDM);
	if (Iter_Contains(ePlayers, playerid)) return Text_Send(playerid, $COMMAND_INEVENT);
	if (Iter_Contains(CWCLAN1, playerid) || Iter_Contains(CWCLAN2, playerid)) return Text_Send(playerid, $COMMAND_INCW);

	if (pItems[playerid][AK] > 0) {
		if (pCooldown[playerid][37] < gettime()) {
			new Float: AR;
			GetPlayerArmour(playerid, AR);
			if (AR >= 100) return Text_Send(playerid, $CLIENT_448x);

			pCooldown[playerid][37] = gettime() + 15;

			KillTimer(RecoverTimer[playerid]);
			RecoverTimer[playerid] = SetTimerEx("UseAK", 3000, false, "i", playerid);
			PlayerPlaySound(playerid, 1068, 0.0, 0.0, 0.0);
			AnimPlayer(playerid, "ROB_BANK", "CAT_Safe_Open", 8.0, 0, 0, 0, 0, 0);

			new Float: X, Float: Y, Float: Z;
			GetXYZInfrontOfPlayer(playerid, X, Y, 0.7);
			CA_FindZ_For2DCoord(X, Y, Z);

			new armourkit = CreateDynamicObject(19515, X, Y, Z + 0.1, 90.0, 0.0, 0.0);
			SetTimerEx("DestroyArmourkit", 3500, false, "i", armourkit);
		} else {
			Text_Send(playerid, $COOLDOWN_TIMELEFT, pCooldown[playerid][37] - gettime());
		}
	}  else Text_Send(playerid, $CLIENT_446x);
	return 1;
}

//Landmines

alias:landmine("pmine", "plm");
CMD:landmine(playerid) {
	if (pDuelInfo[playerid][pDInMatch] == 1) return Text_Send(playerid, $COMMAND_INDUEL);
	if (PlayerInfo[playerid][pDeathmatchId] > -1) return Text_Send(playerid, $COMMAND_INDM);
	if (Iter_Contains(ePlayers, playerid)) return Text_Send(playerid, $COMMAND_INEVENT);
	if (Iter_Contains(CWCLAN1, playerid) || Iter_Contains(CWCLAN2, playerid)) return Text_Send(playerid, $COMMAND_INCW);

	if (!pItems[playerid][LANDMINES]) return Text_Send(playerid, $CLIENT_446x);
	if (GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) return Text_Send(playerid, $CLIENT_445x);
	if (GetPlayerInterior(playerid) != 0 || GetPlayerVirtualWorld(playerid) != 0) return Text_Send(playerid, $CLIENT_463x);

	new Float: Checkpos[3], Float: Check_X;
	GetPlayerPos(playerid, Checkpos[0], Checkpos[1], Checkpos[2]);

	CA_FindZ_For2DCoord(Checkpos[0], Checkpos[1], Check_X);
	if (Checkpos[2] < Check_X) return Text_Send(playerid, $CLIENT_463x);

	for (new i = 0; i < MAX_SLOTS; i++) {
		if (!gLandmineExists[i]) {
			if (pCooldown[playerid][9] < gettime()) {
				pCooldown[playerid][9] = gettime() + 35;

				new Float: X, Float: Y, Float: Z;

				GetPlayerPos(playerid, X, Y, Z);
				CA_FindZ_For2DCoord(X, Y, Z);

				gLandmineExists[i] = 1;

				gLandminePlacer[i] = playerid;
				gLandmineObj[i] = CreateDynamicObject(19602, X, Y, Z, 0.0, 0.0, 0.0);
				gLandmineArea[i] = CreateDynamicCircle(X, Y, 2.0);

				gLandminePos[i][0] = X;
				gLandminePos[i][1] = Y;
				gLandminePos[i][2] = Z;

				AddPlayerItem(playerid, LANDMINES, -1);
				PlayerInfo[playerid][pItemsUsed] ++;
				gLandmineTimer[i] = SetTimerEx("AlterLandmine", 50000, false, "i", i);
				ApplyAnimation(playerid, "MISC", "PICKUP_box", 3.0, 0, 0, 0, 0, 0);

				break;
			} else {
				Text_Send(playerid, $COOLDOWN_TIMELEFT, pCooldown[playerid][9] - gettime());
			}
		}
	}
	return 1;
}

//End of File
/* (c) H2O Multiplayer 2018-2020. All rights reserved. */