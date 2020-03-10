/*
	SWAT vs Terrorists is a team death-match SA-MP game-mode script. 
	Compatible with SA-MP 0.3.7 and later releases.

	Author: H2O
	Licensed under GNU GPLv3

	(c) 2018-2020 H2O Multiplayer. All rights reserved.
	Website: h2omultiplayer.com

	Create stuff for the toys system
*/

#include <YSI\y_hooks>
#include <YSI\y_text>
loadtext mode_text[all], mode_text[client], mode_text[newcs], mode_text[dialogs], mode_text[gametexts];

AttachHelmet(playerid) {
	if (IsPlayerAttachedObjectSlotUsed(playerid, 2)) {
		return 1;
	}
	switch (pItems[playerid][HELMET]) {
		case 1: {
			if (!PlayerInfo[playerid][pAdjustedHelmet]) {
				SetPlayerAttachedObject(playerid, 2, 19102, 2, 0.15, 0.00, 0.00, 0.00, 0.00, 0.00, 1.00, 1.00, 1.00);
			} else {
				SetPlayerAttachedObject(playerid, 2, 19102, 2, ao[playerid][2][ao_x], ao[playerid][2][ao_y], ao[playerid][2][ao_z], ao[playerid][2][ao_rx], ao[playerid][2][ao_ry], ao[playerid][2][ao_rz], ao[playerid][2][ao_sx], ao[playerid][2][ao_sy], ao[playerid][2][ao_sz]);
			}
		}
		case 2: {
			if (!PlayerInfo[playerid][pAdjustedHelmet]) {
				SetPlayerAttachedObject(playerid, 2, 19108, 2, 0.15, 0.00, 0.00, 0.00, 0.00, 0.00, 1.00, 1.00, 1.00);
			} else {
				SetPlayerAttachedObject(playerid, 2, 19108, 2, ao[playerid][2][ao_x], ao[playerid][2][ao_y], ao[playerid][2][ao_z], ao[playerid][2][ao_rx], ao[playerid][2][ao_ry], ao[playerid][2][ao_rz], ao[playerid][2][ao_sx], ao[playerid][2][ao_sy], ao[playerid][2][ao_sz]);
			}
		}
	}
	printf("Added helmet to %s[%d]", PlayerInfo[playerid][PlayerName], playerid);
	return 1;
}

AttachMask(playerid) {
	if (IsPlayerAttachedObjectSlotUsed(playerid, 3)) {
		RemovePlayerAttachedObject(playerid, 3);
	}
	if (pItems[playerid][MASK]) {
		if (!PlayerInfo[playerid][pAdjustedMask]) {
			SetPlayerAttachedObject(playerid, 3, 19472, 2, 0.00, 0.14, 0.01, 0.00, 88.60, 94.49, 1.04, 1.09, 1.05);
		} else {
			SetPlayerAttachedObject(playerid, 3, 19472, 2, ao[playerid][3][ao_x], ao[playerid][3][ao_y], ao[playerid][3][ao_z], ao[playerid][3][ao_rx], ao[playerid][3][ao_ry], ao[playerid][3][ao_rz], ao[playerid][3][ao_sx], ao[playerid][3][ao_sy], ao[playerid][3][ao_sz]);
		}
	}	
	printf("Added mask to %s[%d]", PlayerInfo[playerid][PlayerName], playerid);
	return 1;
}

AttachDynamite(playerid) {
	if (IsPlayerAttachedObjectSlotUsed(playerid, 5)) {
		RemovePlayerAttachedObject(playerid, 5);
	}	
	
	if (pItems[playerid][DYNAMITE]) {
		if (!PlayerInfo[playerid][pAdjustedDynamite]) {
			SetPlayerAttachedObject(playerid, 5, 1654, 1, 0.11, -0.11, 0.00, 0.00, -59.70, 0.00, 1.00, 1.00, 1.00);
		} else {
			SetPlayerAttachedObject(playerid, 5, 1654, 1, ao[playerid][5][ao_x], ao[playerid][5][ao_y], ao[playerid][5][ao_z], ao[playerid][5][ao_rx], ao[playerid][5][ao_ry], ao[playerid][5][ao_rz], ao[playerid][5][ao_sx], ao[playerid][5][ao_sy], ao[playerid][5][ao_sz]);
		}
	}
	
	printf("Added dynamite to %s[%d]", PlayerInfo[playerid][PlayerName], playerid);
	return 1;
}

ResetToysData(playerid) {
	new clear_ao[attached_object_data];
	for (new i = 0; i < MAX_PLAYER_ATTACHED_OBJECTS; i++) {
		ao[playerid][i] = clear_ao;
	}
	return 1;
}

//Hooks

hook OnPlayerStateChange(playerid, newstate, oldstate) {
	if ((newstate == PLAYER_STATE_DRIVER || newstate == PLAYER_STATE_PASSENGER) && oldstate == PLAYER_STATE_ONFOOT) {
		if (IsPlayerAttachedObjectSlotUsed(playerid, 2) && GetPlayerWeapon(playerid) == 34) {
			RemovePlayerAttachedObject(playerid, 2);
			pHelmetAttached[playerid] = 1;
		}
		if (IsPlayerAttachedObjectSlotUsed(playerid, 3) && GetPlayerWeapon(playerid) == 34)
		{
			RemovePlayerAttachedObject(playerid, 3);
			pMaskAttached[playerid] = 1;
		}
	} else if (newstate == PLAYER_STATE_ONFOOT && (oldstate == PLAYER_STATE_DRIVER || oldstate == PLAYER_STATE_PASSENGER)) {
		if (pHelmetAttached[playerid]) {
			AttachHelmet(playerid);
			pHelmetAttached[playerid] = 0;
		}
		if (pMaskAttached[playerid]) {
			AttachMask(playerid);
			pMaskAttached[playerid] = 0;
		}
	}
	return 1;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
	//Sync
	if (HOLDING(KEY_HANDBRAKE)) {
		if (IsPlayerAttachedObjectSlotUsed(playerid, 2)  && GetPlayerWeapon(playerid) == 34) {
			RemovePlayerAttachedObject(playerid, 2);
			pHelmetAttached[playerid] = 1;
		}
		if (IsPlayerAttachedObjectSlotUsed(playerid, 3) && GetPlayerWeapon(playerid) == 34)
		{
			RemovePlayerAttachedObject(playerid, 3);
			pMaskAttached[playerid] = 1;
		}
	} else if (RELEASED(KEY_HANDBRAKE)) {
		if (pHelmetAttached[playerid]) {
			AttachHelmet(playerid);
			pHelmetAttached[playerid] = 0;
		}	
		if (pMaskAttached[playerid]) {
			AttachMask(playerid);
			pMaskAttached[playerid] = 0;
		}	
	}
	return 1;
}

hook OnPlayerModelSelection(playerid, response, listid, modelid) {
	if (listid == toyslist) {
		if (!response) return Text_Send(playerid, $BODY_TOYS_CANCEL);
		gEditModel[playerid] = modelid;

		inline ToysBodyPart(pid, dialogid, diagresponse, listitem, string:inputtext[]) {
			#pragma unused dialogid, inputtext
			if (!diagresponse) return PC_EmulateCommand(pid, "/toys");
			SetPlayerAttachedObject(pid, gEditSlot[pid], gEditModel[pid], listitem + 1);
			EditAttachedObject(pid, gEditSlot[pid]);
			Text_Send(pid, $BODY_TOY_ADDED, gEditSlot[pid], gEditSlot[pid]);
			gModelsObj[pid][gEditList[pid]] = gEditModel[pid];
			gModelsSlot[pid][gEditList[pid]] = gEditSlot[pid];
			gModelsPart[pid][gEditList[pid]] = listitem + 1;
			gEditModel[pid] = -1;
			gEditList[pid] = 0;
			gEditSlot[pid] = -1;
		}
		Text_DialogBox(playerid, DIALOG_STYLE_LIST, using inline ToysBodyPart, $DIALOG_SELECT_CAP, $BODY_TOYS_DESC, $DIALOG_SELECT, $DIALOG_CANCEL);
	}
	return 1;
}

hook OnPlayerEditAttachedObj(playerid, response, index, modelid, boneid, Float:fOffsetX, Float:fOffsetY, Float:fOffsetZ, Float:fRotX, Float:fRotY, Float:fRotZ, Float:fScaleX, Float:fScaleY, Float:fScaleZ) {
	if (response) { 
		ao[playerid][index][ao_x] = fOffsetX;
		ao[playerid][index][ao_y] = fOffsetY;
		ao[playerid][index][ao_z] = fOffsetZ;
		ao[playerid][index][ao_rx] = fRotX;
		ao[playerid][index][ao_ry] = fRotY;
		ao[playerid][index][ao_rz] = fRotZ;
		ao[playerid][index][ao_sx] = fScaleX;
		ao[playerid][index][ao_sy] = fScaleY;
		ao[playerid][index][ao_sz] = fScaleZ;

		printf("Attached object at: %0.3f, %0.3f, %0.3f, %0.3f, %0.3f, %0.3f, %0.3f, %0.3f, %0.3f",
			fOffsetX, fOffsetY, fOffsetZ, fRotX, fRotY, fRotZ, fScaleX, fScaleY, fScaleZ);

		switch (index) {
			case 2: PlayerInfo[playerid][pAdjustedHelmet] = 1;
			case 3: PlayerInfo[playerid][pAdjustedMask] = 1;
			case 5: PlayerInfo[playerid][pAdjustedDynamite] = 1;
		}
	}
	else
	{
		switch (index) {
			case 2: PlayerInfo[playerid][pAdjustedHelmet] = 0, AttachHelmet(playerid);
			case 3: PlayerInfo[playerid][pAdjustedMask] = 0, AttachMask(playerid);
			case 5: PlayerInfo[playerid][pAdjustedDynamite] = 0, AttachDynamite(playerid);
		}
	}    
	return 1;
}

//Commands

CMD:toys(playerid) {
	inline ToysBodySlots(pid, dialogid, response, listitem, string:inputtext[]) {
		#pragma unused dialogid, inputtext
		if (!response) return PC_EmulateCommand(pid, "/toys");
		switch (listitem) {
			case 0: gEditSlot[pid] = 0;
			case 1: gEditSlot[pid] = 1;
			case 2: gEditSlot[pid] = 6;
			case 3: gEditSlot[pid] = 9;
		}
		gEditList[pid] = listitem;
		ShowModelSelectionMenu(pid, toyslist, "Body Toys", 0x000000CC, X11_DEEPPINK, X11_IVORY);
	}
	if (!PlayerInfo[playerid][pDonorLevel]) return Text_Send(playerid, $CLIENT_362x);
	new toys_dialog2[506];
	format(toys_dialog2, sizeof(toys_dialog2), "Body Slot 1\t%s\n\
			Body Slot 2\t%s\n\
			Body Slot 3\t%s\n\
			Body Slot 4\t%s",
				(IsPlayerAttachedObjectSlotUsed(playerid, 0) == 1) ? (""GREEN"[USED]") : (""RED2"[UNUSED]"),
				(IsPlayerAttachedObjectSlotUsed(playerid, 1) == 1) ? (""GREEN"[USED]") : (""RED2"[UNUSED]"),
				(IsPlayerAttachedObjectSlotUsed(playerid, 6) == 1) ? (""GREEN"[USED]") : (""RED2"[UNUSED]"),
				(IsPlayerAttachedObjectSlotUsed(playerid, 9) == 1) ? (""GREEN"[USED]") : (""RED2"[UNUSED]"));				
	Dialog_ShowCallback(playerid, using inline ToysBodySlots, DIALOG_STYLE_TABLIST, ""RED2"SvT - Body Toys", toys_dialog2, ">>", "<<");
	return 1;
}

CMD:edittoy(playerid, params[]) {
	if (IsPlayerAttachedObjectSlotUsed(playerid, strval(params))) {
		EditAttachedObject(playerid, strval(params));
		GameTextForPlayer(playerid, "~y~EDIT BODY TOY", 1000, 3);
	}
	return 1;
}

CMD:rmtoy(playerid, params[]) {
	if (IsPlayerAttachedObjectSlotUsed(playerid, strval(params))) {
		RemovePlayerAttachedObject(playerid, strval(params));
		GameTextForPlayer(playerid, "~r~REMOVED BODY TOY", 1000, 3);
	}
	return 1;
}

CMD:edithelmet(playerid) {
	if (IsPlayerAttachedObjectSlotUsed(playerid, 2)) {
		EditAttachedObject(playerid, 2);
	} 
	return 1;
}

CMD:editmask(playerid) {
	if (IsPlayerAttachedObjectSlotUsed(playerid, 3)) {
		EditAttachedObject(playerid, 3);
	}
	return 1;
}

CMD:editdynamite(playerid) {
	if (IsPlayerAttachedObjectSlotUsed(playerid, 5)) {
		EditAttachedObject(playerid, 5);
	}
	return 1;
}

//End of File
/* (c) H2O Multiplayer 2018-2020. All rights reserved. */