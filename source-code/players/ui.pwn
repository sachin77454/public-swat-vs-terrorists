/*
	SWAT vs Terrorists is a team death-match SA-MP game-mode script. 
	Compatible with SA-MP 0.3.7 and later releases.

	Author: H2O
	Licensed under GNU GPLv3

	(c) 2018-2020 H2O Multiplayer. All rights reserved.
	Website: h2omultiplayer.com

	Separate server UI from the main code
*/

CreateUI() {
	//===============================================================
	//Intro

	SvTTD[0] = TextDrawCreate(281.000000, 182.000000, "ld_drv:golfly");
	TextDrawFont(SvTTD[0], 4);
	TextDrawLetterSize(SvTTD[0], 0.600000, 2.000000);
	TextDrawTextSize(SvTTD[0], 62.500000, 62.000000);
	TextDrawSetOutline(SvTTD[0], 1);
	TextDrawSetShadow(SvTTD[0], 0);
	TextDrawAlignment(SvTTD[0], 1);
	TextDrawColor(SvTTD[0], -1);
	TextDrawBackgroundColor(SvTTD[0], 255);
	TextDrawBoxColor(SvTTD[0], 50);
	TextDrawUseBox(SvTTD[0], 1);
	TextDrawSetProportional(SvTTD[0], 1);
	TextDrawSetSelectable(SvTTD[0], 0);

	SvTTD[1] = TextDrawCreate(313.000000, 204.000000, "WELCOME TO");
	TextDrawFont(SvTTD[1], 3);
	TextDrawLetterSize(SvTTD[1], 0.600000, 2.000000);
	TextDrawTextSize(SvTTD[1], 404.500000, 133.500000);
	TextDrawSetOutline(SvTTD[1], 1);
	TextDrawSetShadow(SvTTD[1], 0);
	TextDrawAlignment(SvTTD[1], 2);
	TextDrawColor(SvTTD[1], -2686721);
	TextDrawBackgroundColor(SvTTD[1], 255);
	TextDrawBoxColor(SvTTD[1], 183);
	TextDrawUseBox(SvTTD[1], 0);
	TextDrawSetProportional(SvTTD[1], 1);
	TextDrawSetSelectable(SvTTD[1], 0);

	SvTTD[2] = TextDrawCreate(313.000000, 223.000000, "SWAT VS TERRORISTS");
	TextDrawFont(SvTTD[2], 2);
	TextDrawLetterSize(SvTTD[2], 0.612500, 2.099999);
	TextDrawTextSize(SvTTD[2], 513.000000, 282.500000);
	TextDrawSetOutline(SvTTD[2], 1);
	TextDrawSetShadow(SvTTD[2], 0);
	TextDrawAlignment(SvTTD[2], 2);
	TextDrawColor(SvTTD[2], -1);
	TextDrawBackgroundColor(SvTTD[2], 255);
	TextDrawBoxColor(SvTTD[2], 183);
	TextDrawUseBox(SvTTD[2], 0);
	TextDrawSetProportional(SvTTD[2], 1);
	TextDrawSetSelectable(SvTTD[2], 0);

	SvTTD[3] = TextDrawCreate(313.000000, 249.000000, "www.H2OMULTIPLAYER.com");
	TextDrawFont(SvTTD[3], 1);
	TextDrawLetterSize(SvTTD[3], 0.333333, 1.450000);
	TextDrawTextSize(SvTTD[3], 513.000000, 282.500000);
	TextDrawSetOutline(SvTTD[3], 1);
	TextDrawSetShadow(SvTTD[3], 0);
	TextDrawAlignment(SvTTD[3], 2);
	TextDrawColor(SvTTD[3], 1687547391);
	TextDrawBackgroundColor(SvTTD[3], 255);
	TextDrawBoxColor(SvTTD[3], 183);
	TextDrawUseBox(SvTTD[3], 0);
	TextDrawSetProportional(SvTTD[3], 1);
	TextDrawSetSelectable(SvTTD[3], 0);

	SvTTD[4] = TextDrawCreate(212.000000, 217.000000, "Preview_Model");
	TextDrawFont(SvTTD[4], 5);
	TextDrawLetterSize(SvTTD[4], 0.600000, 2.000000);
	TextDrawTextSize(SvTTD[4], 115.000000, 129.000000);
	TextDrawSetOutline(SvTTD[4], 0);
	TextDrawSetShadow(SvTTD[4], 0);
	TextDrawAlignment(SvTTD[4], 1);
	TextDrawColor(SvTTD[4], -1);
	TextDrawBackgroundColor(SvTTD[4], 0);
	TextDrawBoxColor(SvTTD[4], 0);
	TextDrawUseBox(SvTTD[4], 0);
	TextDrawSetProportional(SvTTD[4], 1);
	TextDrawSetSelectable(SvTTD[4], 0);
	TextDrawSetPreviewModel(SvTTD[4], 355);
	TextDrawSetPreviewRot(SvTTD[4], 0.000000, -20.000000, 0.000000, 2.309998);
	TextDrawSetPreviewVehCol(SvTTD[4], 1, 1);

	SvTTD[5] = TextDrawCreate(302.000000, 217.000000, "Preview_Model");
	TextDrawFont(SvTTD[5], 5);
	TextDrawLetterSize(SvTTD[5], 0.600000, 2.000000);
	TextDrawTextSize(SvTTD[5], 115.000000, 129.000000);
	TextDrawSetOutline(SvTTD[5], 0);
	TextDrawSetShadow(SvTTD[5], 0);
	TextDrawAlignment(SvTTD[5], 1);
	TextDrawColor(SvTTD[5], -1);
	TextDrawBackgroundColor(SvTTD[5], 0);
	TextDrawBoxColor(SvTTD[5], 0);
	TextDrawUseBox(SvTTD[5], 0);
	TextDrawSetProportional(SvTTD[5], 1);
	TextDrawSetSelectable(SvTTD[5], 0);
	TextDrawSetPreviewModel(SvTTD[5], 355);
	TextDrawSetPreviewRot(SvTTD[5], 0.000000, 20.000000, 180.000000, 2.309998);
	TextDrawSetPreviewVehCol(SvTTD[5], 1, 1);

	SvTTD[6] = TextDrawCreate(225.000000, 163.000000, "particle:cloudmasked");
	TextDrawFont(SvTTD[6], 4);
	TextDrawLetterSize(SvTTD[6], 0.600000, 2.000000);
	TextDrawTextSize(SvTTD[6], 164.500000, 165.500000);
	TextDrawSetOutline(SvTTD[6], 1);
	TextDrawSetShadow(SvTTD[6], 0);
	TextDrawAlignment(SvTTD[6], 1);
	TextDrawColor(SvTTD[6], 255);
	TextDrawBackgroundColor(SvTTD[6], 0);
	TextDrawBoxColor(SvTTD[6], 0);
	TextDrawUseBox(SvTTD[6], 1);
	TextDrawSetProportional(SvTTD[6], 1);
	TextDrawSetSelectable(SvTTD[6], 0);

	//===============================================================
	//Team war TD

	War_TD = TextDrawCreate(483.000000, 423.000000, "_");
	TextDrawFont(War_TD, 1);
	TextDrawLetterSize(War_TD, 0.150000, 0.649999);
	TextDrawTextSize(War_TD, 400.000000, 131.500000);
	TextDrawSetOutline(War_TD, 1);
	TextDrawSetShadow(War_TD, 0);
	TextDrawAlignment(War_TD, 2);
	TextDrawColor(War_TD, -1);
	TextDrawBackgroundColor(War_TD, 255);
	TextDrawBoxColor(War_TD, 50);
	TextDrawUseBox(War_TD, 0);
	TextDrawSetProportional(War_TD, 1);
	TextDrawSetSelectable(War_TD, 0);

	War_TDBox = TextDrawCreate(483.000000, 422.000000, "_");
	TextDrawFont(War_TDBox, 1);
	TextDrawLetterSize(War_TDBox, 0.620832, 0.849990);
	TextDrawTextSize(War_TDBox, 309.500000, 108.500000);
	TextDrawSetOutline(War_TDBox, 1);
	TextDrawSetShadow(War_TDBox, 0);
	TextDrawAlignment(War_TDBox, 2);
	TextDrawColor(War_TDBox, -1);
	TextDrawBackgroundColor(War_TDBox, 255);
	TextDrawBoxColor(War_TDBox, 70);
	TextDrawUseBox(War_TDBox, 1);
	TextDrawSetProportional(War_TDBox, 1);
	TextDrawSetSelectable(War_TDBox, 0);

	//===============================================================
	//PUBG TDs

	PUBGWinnerTD[0] = TextDrawCreate(-3.000000, -1.000000, "_");
	TextDrawFont(PUBGWinnerTD[0], 1);
	TextDrawLetterSize(PUBGWinnerTD[0], 0.600000, 50.300003);
	TextDrawTextSize(PUBGWinnerTD[0], 654.500000, 127.000000);
	TextDrawSetOutline(PUBGWinnerTD[0], 1);
	TextDrawSetShadow(PUBGWinnerTD[0], 0);
	TextDrawAlignment(PUBGWinnerTD[0], 1);
	TextDrawColor(PUBGWinnerTD[0], -1);
	TextDrawBackgroundColor(PUBGWinnerTD[0], 255);
	TextDrawBoxColor(PUBGWinnerTD[0], 135);
	TextDrawUseBox(PUBGWinnerTD[0], 1);
	TextDrawSetProportional(PUBGWinnerTD[0], 1);
	TextDrawSetSelectable(PUBGWinnerTD[0], 0);

	PUBGWinnerTD[1] = TextDrawCreate(33.000000, 124.000000, "H2O");
	TextDrawFont(PUBGWinnerTD[1], 2);
	TextDrawLetterSize(PUBGWinnerTD[1], 0.600000, 2.000000);
	TextDrawTextSize(PUBGWinnerTD[1], 400.000000, 17.000000);
	TextDrawSetOutline(PUBGWinnerTD[1], 0);
	TextDrawSetShadow(PUBGWinnerTD[1], 0);
	TextDrawAlignment(PUBGWinnerTD[1], 1);
	TextDrawColor(PUBGWinnerTD[1], -1);
	TextDrawBackgroundColor(PUBGWinnerTD[1], 255);
	TextDrawBoxColor(PUBGWinnerTD[1], 50);
	TextDrawUseBox(PUBGWinnerTD[1], 0);
	TextDrawSetProportional(PUBGWinnerTD[1], 1);
	TextDrawSetSelectable(PUBGWinnerTD[1], 0);

	PUBGWinnerTD[2] = TextDrawCreate(33.000000, 144.000000, "WINNER WINNER CHICKEN DINNER!");
	TextDrawFont(PUBGWinnerTD[2], 2);
	TextDrawLetterSize(PUBGWinnerTD[2], 0.600000, 2.000000);
	TextDrawTextSize(PUBGWinnerTD[2], 435.000000, 132.500000);
	TextDrawSetOutline(PUBGWinnerTD[2], 0);
	TextDrawSetShadow(PUBGWinnerTD[2], 0);
	TextDrawAlignment(PUBGWinnerTD[2], 1);
	TextDrawColor(PUBGWinnerTD[2], -294256385);
	TextDrawBackgroundColor(PUBGWinnerTD[2], 255);
	TextDrawBoxColor(PUBGWinnerTD[2], 50);
	TextDrawUseBox(PUBGWinnerTD[2], 0);
	TextDrawSetProportional(PUBGWinnerTD[2], 1);
	TextDrawSetSelectable(PUBGWinnerTD[2], 0);

	PUBGWinnerTD[3] = TextDrawCreate(33.000000, 164.000000, "~w~Kills: ~g~5000            ~w~REWARD: ~g~$500000 & 100 Score");
	TextDrawFont(PUBGWinnerTD[3], 2);
	TextDrawLetterSize(PUBGWinnerTD[3], 0.420833, 2.000000);
	TextDrawTextSize(PUBGWinnerTD[3], 685.000000, 329.500000);
	TextDrawSetOutline(PUBGWinnerTD[3], 0);
	TextDrawSetShadow(PUBGWinnerTD[3], 0);
	TextDrawAlignment(PUBGWinnerTD[3], 1);
	TextDrawColor(PUBGWinnerTD[3], -294256385);
	TextDrawBackgroundColor(PUBGWinnerTD[3], 255);
	TextDrawBoxColor(PUBGWinnerTD[3], 50);
	TextDrawUseBox(PUBGWinnerTD[3], 0);
	TextDrawSetProportional(PUBGWinnerTD[3], 1);
	TextDrawSetSelectable(PUBGWinnerTD[3], 0);

	PUBGWinnerTD[4] = TextDrawCreate(26.000000, 186.000000, "o");
	TextDrawFont(PUBGWinnerTD[4], 1);
	TextDrawLetterSize(PUBGWinnerTD[4], 20.733312, 0.200000);
	TextDrawTextSize(PUBGWinnerTD[4], 400.000000, 17.000000);
	TextDrawSetOutline(PUBGWinnerTD[4], 0);
	TextDrawSetShadow(PUBGWinnerTD[4], 0);
	TextDrawAlignment(PUBGWinnerTD[4], 1);
	TextDrawColor(PUBGWinnerTD[4], -1);
	TextDrawBackgroundColor(PUBGWinnerTD[4], 255);
	TextDrawBoxColor(PUBGWinnerTD[4], 50);
	TextDrawUseBox(PUBGWinnerTD[4], 0);
	TextDrawSetProportional(PUBGWinnerTD[4], 1);
	TextDrawSetSelectable(PUBGWinnerTD[4], 0);

	PUBGAreaTD = TextDrawCreate(88.000000, 322.000000, "Restricting area in 4 minutes");
	TextDrawFont(PUBGAreaTD, 1);
	TextDrawLetterSize(PUBGAreaTD, 0.191667, 0.899999);
	TextDrawTextSize(PUBGAreaTD, 127.500000, 104.000000);
	TextDrawSetOutline(PUBGAreaTD, 1);
	TextDrawSetShadow(PUBGAreaTD, 0);
	TextDrawAlignment(PUBGAreaTD, 2);
	TextDrawColor(PUBGAreaTD, -1);
	TextDrawBackgroundColor(PUBGAreaTD, 255);
	TextDrawBoxColor(PUBGAreaTD, 50);
	TextDrawUseBox(PUBGAreaTD, 1);
	TextDrawSetProportional(PUBGAreaTD, 1);
	TextDrawSetSelectable(PUBGAreaTD, 0);

	PUBGKillsTD = TextDrawCreate(52.000000, 250.000000, "50 KILLED");
	TextDrawFont(PUBGKillsTD, 2);
	TextDrawLetterSize(PUBGKillsTD, 0.262499, 1.750000);
	TextDrawTextSize(PUBGKillsTD, 123.000000, 55.000000);
	TextDrawSetOutline(PUBGKillsTD, 0);
	TextDrawSetShadow(PUBGKillsTD, 0);
	TextDrawAlignment(PUBGKillsTD, 2);
	TextDrawColor(PUBGKillsTD, -1);
	TextDrawBackgroundColor(PUBGKillsTD, 255);
	TextDrawBoxColor(PUBGKillsTD, 145);
	TextDrawUseBox(PUBGKillsTD, 1);
	TextDrawSetProportional(PUBGKillsTD, 1);
	TextDrawSetSelectable(PUBGKillsTD, 0);

	PUBGAliveTD = TextDrawCreate(123.000000, 250.000000, "50 ALIVE");
	TextDrawFont(PUBGAliveTD, 2);
	TextDrawLetterSize(PUBGAliveTD, 0.262499, 1.750000);
	TextDrawTextSize(PUBGAliveTD, 123.000000, 55.000000);
	TextDrawSetOutline(PUBGAliveTD, 0);
	TextDrawSetShadow(PUBGAliveTD, 0);
	TextDrawAlignment(PUBGAliveTD, 2);
	TextDrawColor(PUBGAliveTD, -1);
	TextDrawBackgroundColor(PUBGAliveTD, 255);
	TextDrawBoxColor(PUBGAliveTD, 145);
	TextDrawUseBox(PUBGAliveTD, 1);
	TextDrawSetProportional(PUBGAliveTD, 1);
	TextDrawSetSelectable(PUBGAliveTD, 0);

	PUBGKillTD = TextDrawCreate(321.000000, 178.000000, "~r~H2O ~w~killed ~r~Broman ~w~with an MP5");
	TextDrawFont(PUBGKillTD, 2);
	TextDrawLetterSize(PUBGKillTD, 0.266667, 1.450000);
	TextDrawTextSize(PUBGKillTD, 400.000000, 387.000000);
	TextDrawSetOutline(PUBGKillTD, 0);
	TextDrawSetShadow(PUBGKillTD, 0);
	TextDrawAlignment(PUBGKillTD, 2);
	TextDrawColor(PUBGKillTD, -1);
	TextDrawBackgroundColor(PUBGKillTD, 255);
	TextDrawBoxColor(PUBGKillTD, 50);
	TextDrawUseBox(PUBGKillTD, 0);
	TextDrawSetProportional(PUBGKillTD, 1);
	TextDrawSetSelectable(PUBGKillTD, 0);

	//===============================================================
	//Menu TDs

	menuTextDraw[menuTextDrawCount] = TextDrawCreate(160.000000, 149.000000, "_");
	TextDrawBackgroundColor(menuTextDraw[menuTextDrawCount], 255);
	TextDrawFont(menuTextDraw[menuTextDrawCount], 1);
	TextDrawLetterSize(menuTextDraw[menuTextDrawCount], 0.000000, 22.500001);
	TextDrawColor(menuTextDraw[menuTextDrawCount], -1);
	TextDrawSetOutline(menuTextDraw[menuTextDrawCount], 0);
	TextDrawSetProportional(menuTextDraw[menuTextDrawCount], 1);
	TextDrawSetShadow(menuTextDraw[menuTextDrawCount], 1);
	TextDrawUseBox(menuTextDraw[menuTextDrawCount], 1);
	TextDrawBoxColor(menuTextDraw[menuTextDrawCount], BACKGROUND);
	TextDrawTextSize(menuTextDraw[menuTextDrawCount], 490.000000, 0.000000);
	TextDrawSetSelectable(menuTextDraw[menuTextDrawCount++], 0);

	menuTextDraw[menuTextDrawCount] = TextDrawCreate(163.000000, 161.000000, "_");
	TextDrawBackgroundColor(menuTextDraw[menuTextDrawCount], 255);
	TextDrawFont(menuTextDraw[menuTextDrawCount], 1);
	TextDrawLetterSize(menuTextDraw[menuTextDrawCount], 0.000000, 17.000000);
	TextDrawColor(menuTextDraw[menuTextDrawCount], -1);
	TextDrawSetOutline(menuTextDraw[menuTextDrawCount], 0);
	TextDrawSetProportional(menuTextDraw[menuTextDrawCount], 1);
	TextDrawSetShadow(menuTextDraw[menuTextDrawCount], 1);
	TextDrawUseBox(menuTextDraw[menuTextDrawCount], 1);
	TextDrawBoxColor(menuTextDraw[menuTextDrawCount], LEFT_BACKGROUND);
	TextDrawTextSize(menuTextDraw[menuTextDrawCount], 249.000000, 0.000000);
	TextDrawSetSelectable(menuTextDraw[menuTextDrawCount++], 0);

	menuTextDraw[menuTextDrawCount] = TextDrawCreate(257.000000, 161.000000, "_");
	TextDrawBackgroundColor(menuTextDraw[menuTextDrawCount], 255);
	TextDrawFont(menuTextDraw[menuTextDrawCount], 1);
	TextDrawLetterSize(menuTextDraw[menuTextDrawCount], 0.000000, 17.000000);
	TextDrawColor(menuTextDraw[menuTextDrawCount], -1);
	TextDrawSetOutline(menuTextDraw[menuTextDrawCount], 0);
	TextDrawSetProportional(menuTextDraw[menuTextDrawCount], 1);
	TextDrawSetShadow(menuTextDraw[menuTextDrawCount], 1);
	TextDrawUseBox(menuTextDraw[menuTextDrawCount], 1);
	TextDrawBoxColor(menuTextDraw[menuTextDrawCount], RIGHT_BACKGROUND);
	TextDrawTextSize(menuTextDraw[menuTextDrawCount], 487.000000, 0.000000);
	TextDrawSetSelectable(menuTextDraw[menuTextDrawCount++], 0);

	menuTextDraw[menuTextDrawCount] = TextDrawCreate(245.000000, 170.000000, "_");
	TextDrawBackgroundColor(menuTextDraw[menuTextDrawCount], 255);
	TextDrawFont(menuTextDraw[menuTextDrawCount], 1);
	TextDrawLetterSize(menuTextDraw[menuTextDrawCount], 0.000000, 15.199996);
	TextDrawColor(menuTextDraw[menuTextDrawCount], -1);
	TextDrawSetOutline(menuTextDraw[menuTextDrawCount], 0);
	TextDrawSetProportional(menuTextDraw[menuTextDrawCount], 1);
	TextDrawSetShadow(menuTextDraw[menuTextDrawCount], 1);
	TextDrawUseBox(menuTextDraw[menuTextDrawCount], 1);
	TextDrawBoxColor(menuTextDraw[menuTextDrawCount], 842150600);
	TextDrawTextSize(menuTextDraw[menuTextDrawCount], 248.000000, 0.000000);
	TextDrawSetSelectable(menuTextDraw[menuTextDrawCount++], 0);

	menuTextDrawID[E_MENU_TEXTDRAW_SCROLL_UP] = menuTextDrawCount;
	menuTextDraw[menuTextDrawCount] = TextDrawCreate(243.000000, 161.000000, "LD_POOL:ball");
	TextDrawBackgroundColor(menuTextDraw[menuTextDrawCount], 0);
	TextDrawFont(menuTextDraw[menuTextDrawCount], 4);
	TextDrawLetterSize(menuTextDraw[menuTextDrawCount], 0.159999, 0.899999);
	TextDrawColor(menuTextDraw[menuTextDrawCount], 842150600);
	TextDrawSetOutline(menuTextDraw[menuTextDrawCount], 0);
	TextDrawSetProportional(menuTextDraw[menuTextDrawCount], 1);
	TextDrawSetShadow(menuTextDraw[menuTextDrawCount], 1);
	TextDrawUseBox(menuTextDraw[menuTextDrawCount], 1);
	TextDrawBoxColor(menuTextDraw[menuTextDrawCount], 255);
	TextDrawTextSize(menuTextDraw[menuTextDrawCount], 7.000000, 9.000000);
	TextDrawSetSelectable(menuTextDraw[menuTextDrawCount++], 1);

	menuTextDraw[menuTextDrawCount] = TextDrawCreate(244.000000, 162.000000, "LD_BEAT:up");
	TextDrawBackgroundColor(menuTextDraw[menuTextDrawCount], 0);
	TextDrawFont(menuTextDraw[menuTextDrawCount], 4);
	TextDrawLetterSize(menuTextDraw[menuTextDrawCount], 0.159999, 0.899999);
	TextDrawColor(menuTextDraw[menuTextDrawCount], -56);
	TextDrawSetOutline(menuTextDraw[menuTextDrawCount], 0);
	TextDrawSetProportional(menuTextDraw[menuTextDrawCount], 1);
	TextDrawSetShadow(menuTextDraw[menuTextDrawCount], 1);
	TextDrawUseBox(menuTextDraw[menuTextDrawCount], 1);
	TextDrawBoxColor(menuTextDraw[menuTextDrawCount], 255);
	TextDrawTextSize(menuTextDraw[menuTextDrawCount], 5.000000, 7.000000);
	TextDrawSetSelectable(menuTextDraw[menuTextDrawCount++], 0);

	menuTextDrawID[E_MENU_TEXTDRAW_SCROLL_DOWN] = menuTextDrawCount;
	menuTextDraw[menuTextDrawCount] = TextDrawCreate(243.000000, 306.000000, "LD_POOL:ball");
	TextDrawBackgroundColor(menuTextDraw[menuTextDrawCount], 0);
	TextDrawFont(menuTextDraw[menuTextDrawCount], 4);
	TextDrawLetterSize(menuTextDraw[menuTextDrawCount], 0.159999, 0.899999);
	TextDrawColor(menuTextDraw[menuTextDrawCount], 842150600);
	TextDrawSetOutline(menuTextDraw[menuTextDrawCount], 0);
	TextDrawSetProportional(menuTextDraw[menuTextDrawCount], 1);
	TextDrawSetShadow(menuTextDraw[menuTextDrawCount], 1);
	TextDrawUseBox(menuTextDraw[menuTextDrawCount], 1);
	TextDrawBoxColor(menuTextDraw[menuTextDrawCount], 255);
	TextDrawTextSize(menuTextDraw[menuTextDrawCount], 7.000000, 9.000000);
	TextDrawSetSelectable(menuTextDraw[menuTextDrawCount++], 1);

	menuTextDraw[menuTextDrawCount] = TextDrawCreate(244.000000, 307.000000, "LD_BEAT:down");
	TextDrawBackgroundColor(menuTextDraw[menuTextDrawCount], 0);
	TextDrawFont(menuTextDraw[menuTextDrawCount], 4);
	TextDrawLetterSize(menuTextDraw[menuTextDrawCount], 0.159999, 0.899999);
	TextDrawColor(menuTextDraw[menuTextDrawCount], -56);
	TextDrawSetOutline(menuTextDraw[menuTextDrawCount], 0);
	TextDrawSetProportional(menuTextDraw[menuTextDrawCount], 1);
	TextDrawSetShadow(menuTextDraw[menuTextDrawCount], 1);
	TextDrawUseBox(menuTextDraw[menuTextDrawCount], 1);
	TextDrawBoxColor(menuTextDraw[menuTextDrawCount], 255);
	TextDrawTextSize(menuTextDraw[menuTextDrawCount], 5.000000, 7.000000);
	TextDrawSetSelectable(menuTextDraw[menuTextDrawCount++], 0);

	for (new i; i < MAX_LEFT_MENU_ROWS; i++) {
		menuTextDrawID[E_MENU_TEXTDRAW_LEFT_BOX][i] = menuTextDrawCount;
		menuTextDraw[menuTextDrawCount] = TextDrawCreate(165.000000, (163.000000 + (i * 22.000000)), "_");
		TextDrawBackgroundColor(menuTextDraw[menuTextDrawCount], 0);
		TextDrawFont(menuTextDraw[menuTextDrawCount], 2);
		TextDrawLetterSize(menuTextDraw[menuTextDrawCount], 0.389999, 1.999999);
		TextDrawColor(menuTextDraw[menuTextDrawCount], 0);
		TextDrawSetOutline(menuTextDraw[menuTextDrawCount], 0);
		TextDrawSetProportional(menuTextDraw[menuTextDrawCount], 1);
		TextDrawSetShadow(menuTextDraw[menuTextDrawCount], 1);
		TextDrawUseBox(menuTextDraw[menuTextDrawCount], 1);
		TextDrawBoxColor(menuTextDraw[menuTextDrawCount], 50);
		TextDrawTextSize(menuTextDraw[menuTextDrawCount], 238.000000, 100.000000);
		TextDrawSetSelectable(menuTextDraw[menuTextDrawCount++], 1);

		menuTextDrawID[E_MENU_TEXTDRAW_LEFT_MODEL][i] = menuTextDrawCount;
		menuTextDraw[menuTextDrawCount] = TextDrawCreate(165.000000, (163.000000 + (i * 22.000000)), "Item_model");
		TextDrawBackgroundColor(menuTextDraw[menuTextDrawCount], 100);
		TextDrawFont(menuTextDraw[menuTextDrawCount], 5);
		TextDrawLetterSize(menuTextDraw[menuTextDrawCount], 0.000000, 2.000000);
		TextDrawColor(menuTextDraw[menuTextDrawCount], -1);
		TextDrawSetOutline(menuTextDraw[menuTextDrawCount], 0);
		TextDrawSetProportional(menuTextDraw[menuTextDrawCount], 1);
		TextDrawSetShadow(menuTextDraw[menuTextDrawCount], 1);
		TextDrawUseBox(menuTextDraw[menuTextDrawCount], 1);
		TextDrawBoxColor(menuTextDraw[menuTextDrawCount], 0);
		TextDrawTextSize(menuTextDraw[menuTextDrawCount], 19.000000, 18.000000);
		TextDrawSetPreviewModel(menuTextDraw[menuTextDrawCount], 18631);
		TextDrawSetPreviewRot(menuTextDraw[menuTextDrawCount], 0.000000, 0.000000, 0.000000, 1.000000);
		TextDrawSetSelectable(menuTextDraw[menuTextDrawCount++], 1);
	}

	new string[3];
	for (new a; a < MAX_RIGHT_MENU_ROWS; a++) {
		for (new b; b < MAX_RIGHT_MENU_COLUMNS; b++)
		{
			menuTextDrawID[E_MENU_TEXTDRAW_RIGHT_MODEL][(a * MAX_RIGHT_MENU_COLUMNS) + b] = menuTextDrawCount;
			menuTextDraw[menuTextDrawCount] = TextDrawCreate((257.000000 + (b * 46.000000)), (161.000000 + (a * 51.000000)), "Item_model");
			TextDrawBackgroundColor(menuTextDraw[menuTextDrawCount], 100);
			TextDrawFont(menuTextDraw[menuTextDrawCount], 5);
			TextDrawLetterSize(menuTextDraw[menuTextDrawCount], 0.000000, 2.000000);
			TextDrawColor(menuTextDraw[menuTextDrawCount], -1);
			TextDrawSetOutline(menuTextDraw[menuTextDrawCount], 0);
			TextDrawSetProportional(menuTextDraw[menuTextDrawCount], 1);
			TextDrawSetShadow(menuTextDraw[menuTextDrawCount], 1);
			TextDrawUseBox(menuTextDraw[menuTextDrawCount], 1);
			TextDrawBoxColor(menuTextDraw[menuTextDrawCount], 0);
			TextDrawTextSize(menuTextDraw[menuTextDrawCount], 45.000000, 50.000000);
			TextDrawSetPreviewModel(menuTextDraw[menuTextDrawCount], 18631);
			TextDrawSetPreviewRot(menuTextDraw[menuTextDrawCount], 0.000000, 0.000000, 0.000000, 1.000000);
			TextDrawSetSelectable(menuTextDraw[menuTextDrawCount++], 1);

			menuTextDrawID[E_MENU_TEXTDRAW_RIGHT_NUMBER][(a * MAX_RIGHT_MENU_COLUMNS) + b] = menuTextDrawCount;
			format(string, sizeof string, "%i.", (((a * MAX_RIGHT_MENU_COLUMNS) + b) + 1));
			menuTextDraw[menuTextDrawCount] = TextDrawCreate((260.000000 + (b * 46.000000)), (164.000000 + (a * 51.000000)), string);
			TextDrawBackgroundColor(menuTextDraw[menuTextDrawCount], 0);
			TextDrawFont(menuTextDraw[menuTextDrawCount], FONT);
			TextDrawLetterSize(menuTextDraw[menuTextDrawCount], 0.189999, 0.899999);
			TextDrawColor(menuTextDraw[menuTextDrawCount], -926365441);
			TextDrawSetOutline(menuTextDraw[menuTextDrawCount], 0);
			TextDrawSetProportional(menuTextDraw[menuTextDrawCount], 1);
			TextDrawSetShadow(menuTextDraw[menuTextDrawCount], 1);
			TextDrawSetSelectable(menuTextDraw[menuTextDrawCount++], 0);
		}
	}

	menuTextDrawID[E_MENU_TEXTDRAW_LEFTBTN] = menuTextDrawCount;
	menuTextDraw[menuTextDrawCount] = TextDrawCreate(235.000000, 318.000000, "LD_POOL:ball");
	TextDrawBackgroundColor(menuTextDraw[menuTextDrawCount], 0);
	TextDrawFont(menuTextDraw[menuTextDrawCount], 4);
	TextDrawLetterSize(menuTextDraw[menuTextDrawCount], 0.159999, 0.899999);
	TextDrawColor(menuTextDraw[menuTextDrawCount], 842150550);
	TextDrawSetOutline(menuTextDraw[menuTextDrawCount], 0);
	TextDrawSetProportional(menuTextDraw[menuTextDrawCount], 1);
	TextDrawSetShadow(menuTextDraw[menuTextDrawCount], 1);
	TextDrawUseBox(menuTextDraw[menuTextDrawCount], 1);
	TextDrawBoxColor(menuTextDraw[menuTextDrawCount], 255);
	TextDrawTextSize(menuTextDraw[menuTextDrawCount], 13.000000, 16.000000);
	TextDrawSetSelectable(menuTextDraw[menuTextDrawCount++], 1);

	menuTextDraw[menuTextDrawCount] = TextDrawCreate(238.000000, 321.000000, "LD_BEAT:right");
	TextDrawBackgroundColor(menuTextDraw[menuTextDrawCount], 0);
	TextDrawFont(menuTextDraw[menuTextDrawCount], 4);
	TextDrawLetterSize(menuTextDraw[menuTextDrawCount], 0.159999, 0.899999);
	TextDrawColor(menuTextDraw[menuTextDrawCount], -56);
	TextDrawSetOutline(menuTextDraw[menuTextDrawCount], 0);
	TextDrawSetProportional(menuTextDraw[menuTextDrawCount], 1);
	TextDrawSetShadow(menuTextDraw[menuTextDrawCount], 1);
	TextDrawUseBox(menuTextDraw[menuTextDrawCount], 1);
	TextDrawBoxColor(menuTextDraw[menuTextDrawCount], 255);
	TextDrawTextSize(menuTextDraw[menuTextDrawCount], 8.000000, 10.000000);
	TextDrawSetSelectable(menuTextDraw[menuTextDrawCount++], 0);

	menuTextDraw[menuTextDrawCount] = TextDrawCreate(242.000000, 335.000000, "PICKUP~n~ITEM");
	TextDrawAlignment(menuTextDraw[menuTextDrawCount], 2);
	TextDrawBackgroundColor(menuTextDraw[menuTextDrawCount], 0);
	TextDrawFont(menuTextDraw[menuTextDrawCount], 1);
	TextDrawLetterSize(menuTextDraw[menuTextDrawCount], 0.119998, 0.599999);
	TextDrawColor(menuTextDraw[menuTextDrawCount], -926365441);
	TextDrawSetOutline(menuTextDraw[menuTextDrawCount], 0);
	TextDrawSetProportional(menuTextDraw[menuTextDrawCount], 1);
	TextDrawSetShadow(menuTextDraw[menuTextDrawCount], 1);
	TextDrawSetSelectable(menuTextDraw[menuTextDrawCount++], 0);

	menuTextDrawID[E_MENU_TEXTDRAW_RIGHTBTN] = menuTextDrawCount;
	menuTextDraw[menuTextDrawCount] = TextDrawCreate(258.000000, 318.000000, "LD_POOL:ball");
	TextDrawBackgroundColor(menuTextDraw[menuTextDrawCount], 0);
	TextDrawFont(menuTextDraw[menuTextDrawCount], 4);
	TextDrawLetterSize(menuTextDraw[menuTextDrawCount], 0.159999, 0.899999);
	TextDrawColor(menuTextDraw[menuTextDrawCount], 842150550);
	TextDrawSetOutline(menuTextDraw[menuTextDrawCount], 0);
	TextDrawSetProportional(menuTextDraw[menuTextDrawCount], 1);
	TextDrawSetShadow(menuTextDraw[menuTextDrawCount], 1);
	TextDrawUseBox(menuTextDraw[menuTextDrawCount], 1);
	TextDrawBoxColor(menuTextDraw[menuTextDrawCount], 255);
	TextDrawTextSize(menuTextDraw[menuTextDrawCount], 13.000000, 16.000000);
	TextDrawSetSelectable(menuTextDraw[menuTextDrawCount++], 1);

	menuTextDraw[menuTextDrawCount] = TextDrawCreate(260.000000, 321.000000, "LD_BEAT:left");
	TextDrawBackgroundColor(menuTextDraw[menuTextDrawCount], 0);
	TextDrawFont(menuTextDraw[menuTextDrawCount], 4);
	TextDrawLetterSize(menuTextDraw[menuTextDrawCount], 0.159999, 0.899999);
	TextDrawColor(menuTextDraw[menuTextDrawCount], -56);
	TextDrawSetOutline(menuTextDraw[menuTextDrawCount], 0);
	TextDrawSetProportional(menuTextDraw[menuTextDrawCount], 1);
	TextDrawSetShadow(menuTextDraw[menuTextDrawCount], 1);
	TextDrawUseBox(menuTextDraw[menuTextDrawCount], 1);
	TextDrawBoxColor(menuTextDraw[menuTextDrawCount], 255);
	TextDrawTextSize(menuTextDraw[menuTextDrawCount], 8.000000, 10.000000);
	TextDrawSetSelectable(menuTextDraw[menuTextDrawCount++], 0);

	menuTextDraw[menuTextDrawCount] = TextDrawCreate(265.000000, 335.000000, "DROP~n~ITEM");
	TextDrawAlignment(menuTextDraw[menuTextDrawCount], 2);
	TextDrawBackgroundColor(menuTextDraw[menuTextDrawCount], 0);
	TextDrawFont(menuTextDraw[menuTextDrawCount], FONT);
	TextDrawLetterSize(menuTextDraw[menuTextDrawCount], 0.119998, 0.599999);
	TextDrawColor(menuTextDraw[menuTextDrawCount], -926365441);
	TextDrawSetOutline(menuTextDraw[menuTextDrawCount], 0);
	TextDrawSetProportional(menuTextDraw[menuTextDrawCount], 1);
	TextDrawSetShadow(menuTextDraw[menuTextDrawCount], 1);
	TextDrawSetSelectable(menuTextDraw[menuTextDrawCount++], 0);

	menuTextDrawID[E_MENU_TEXTDRAW_MIDDLEBTN] = menuTextDrawCount;
	menuTextDraw[menuTextDrawCount] = TextDrawCreate(281.000000, 318.000000, "LD_POOL:ball");
	TextDrawBackgroundColor(menuTextDraw[menuTextDrawCount], 0);
	TextDrawFont(menuTextDraw[menuTextDrawCount], 4);
	TextDrawLetterSize(menuTextDraw[menuTextDrawCount], 0.159999, 0.899999);
	TextDrawColor(menuTextDraw[menuTextDrawCount], 842150550);
	TextDrawSetOutline(menuTextDraw[menuTextDrawCount], 0);
	TextDrawSetProportional(menuTextDraw[menuTextDrawCount], 1);
	TextDrawSetShadow(menuTextDraw[menuTextDrawCount], 1);
	TextDrawUseBox(menuTextDraw[menuTextDrawCount], 1);
	TextDrawBoxColor(menuTextDraw[menuTextDrawCount], 255);
	TextDrawTextSize(menuTextDraw[menuTextDrawCount], 13.000000, 16.000000);
	TextDrawSetSelectable(menuTextDraw[menuTextDrawCount++], 1);

	menuTextDraw[menuTextDrawCount] = TextDrawCreate(287.000000, 323.000000, "USE");
	TextDrawAlignment(menuTextDraw[menuTextDrawCount], 2);
	TextDrawBackgroundColor(menuTextDraw[menuTextDrawCount], 0);
	TextDrawFont(menuTextDraw[menuTextDrawCount], 1);
	TextDrawLetterSize(menuTextDraw[menuTextDrawCount], 0.149999, 0.699999);
	TextDrawColor(menuTextDraw[menuTextDrawCount], -1263225601);
	TextDrawSetOutline(menuTextDraw[menuTextDrawCount], 0);
	TextDrawSetProportional(menuTextDraw[menuTextDrawCount], 1);
	TextDrawSetShadow(menuTextDraw[menuTextDrawCount], 1);
	TextDrawSetSelectable(menuTextDraw[menuTextDrawCount++], 0);

	menuTextDraw[menuTextDrawCount] = TextDrawCreate(288.000000, 335.000000, "USE~n~ITEM");
	TextDrawAlignment(menuTextDraw[menuTextDrawCount], 2);
	TextDrawBackgroundColor(menuTextDraw[menuTextDrawCount], 0);
	TextDrawFont(menuTextDraw[menuTextDrawCount], FONT);
	TextDrawLetterSize(menuTextDraw[menuTextDrawCount], 0.119998, 0.599999);
	TextDrawColor(menuTextDraw[menuTextDrawCount], -926365441);
	TextDrawSetOutline(menuTextDraw[menuTextDrawCount], 0);
	TextDrawSetProportional(menuTextDraw[menuTextDrawCount], 1);
	TextDrawSetShadow(menuTextDraw[menuTextDrawCount], 1);
	TextDrawUseBox(menuTextDraw[menuTextDrawCount], 1);
	TextDrawBoxColor(menuTextDraw[menuTextDrawCount], 0);
	TextDrawTextSize(menuTextDraw[menuTextDrawCount], 238.000000, 0.000000);
	TextDrawSetSelectable(menuTextDraw[menuTextDrawCount++], 0);

	menuTextDrawID[E_MENU_TEXTDRAW_CLOSE] = menuTextDrawCount;
	menuTextDraw[menuTextDrawCount] = TextDrawCreate(476.000000, 318.000000, "LD_POOL:ball");
	TextDrawBackgroundColor(menuTextDraw[menuTextDrawCount], 0);
	TextDrawFont(menuTextDraw[menuTextDrawCount], 4);
	TextDrawLetterSize(menuTextDraw[menuTextDrawCount], 0.159999, 0.899999);
	TextDrawColor(menuTextDraw[menuTextDrawCount], 842150550);
	TextDrawSetOutline(menuTextDraw[menuTextDrawCount], 0);
	TextDrawSetProportional(menuTextDraw[menuTextDrawCount], 1);
	TextDrawSetShadow(menuTextDraw[menuTextDrawCount], 1);
	TextDrawUseBox(menuTextDraw[menuTextDrawCount], 1);
	TextDrawBoxColor(menuTextDraw[menuTextDrawCount], 255);
	TextDrawTextSize(menuTextDraw[menuTextDrawCount], 13.000000, 16.000000);
	TextDrawSetSelectable(menuTextDraw[menuTextDrawCount++], 1);

	menuTextDraw[menuTextDrawCount] = TextDrawCreate(483.000000, 322.000000, "~r~~h~~h~X");
	TextDrawAlignment(menuTextDraw[menuTextDrawCount], 2);
	TextDrawBackgroundColor(menuTextDraw[menuTextDrawCount], 0);
	TextDrawFont(menuTextDraw[menuTextDrawCount], 1);
	TextDrawLetterSize(menuTextDraw[menuTextDrawCount], 0.220000, 0.899999);
	TextDrawColor(menuTextDraw[menuTextDrawCount], -1263225601);
	TextDrawSetOutline(menuTextDraw[menuTextDrawCount], 0);
	TextDrawSetProportional(menuTextDraw[menuTextDrawCount], 1);
	TextDrawSetShadow(menuTextDraw[menuTextDrawCount], 1);
	TextDrawSetSelectable(menuTextDraw[menuTextDrawCount++], 0);

	menuTextDraw[menuTextDrawCount] = TextDrawCreate(487.000000, 335.000000, "~r~~h~~h~CLOSE~n~~r~~h~~h~INVENTORY~n~");
	TextDrawAlignment(menuTextDraw[menuTextDrawCount], 3);
	TextDrawBackgroundColor(menuTextDraw[menuTextDrawCount], 0);
	TextDrawFont(menuTextDraw[menuTextDrawCount], FONT);
	TextDrawLetterSize(menuTextDraw[menuTextDrawCount], 0.119998, 0.599999);
	TextDrawColor(menuTextDraw[menuTextDrawCount], -926365441);
	TextDrawSetOutline(menuTextDraw[menuTextDrawCount], 0);
	TextDrawSetProportional(menuTextDraw[menuTextDrawCount], 1);
	TextDrawSetShadow(menuTextDraw[menuTextDrawCount], 1);
	TextDrawSetSelectable(menuTextDraw[menuTextDrawCount++], 0);

	menuTextDrawID[E_MENU_TEXTDRAW_EMPTY_LEFT][0] = menuTextDrawCount;
	menuTextDraw[menuTextDrawCount] = TextDrawCreate(167.000000, 237.000000, "_");
	TextDrawBackgroundColor(menuTextDraw[menuTextDrawCount], 255);
	TextDrawFont(menuTextDraw[menuTextDrawCount], 1);
	TextDrawLetterSize(menuTextDraw[menuTextDrawCount], 0.000000, -0.200001);
	TextDrawColor(menuTextDraw[menuTextDrawCount], -1);
	TextDrawSetOutline(menuTextDraw[menuTextDrawCount], 0);
	TextDrawSetProportional(menuTextDraw[menuTextDrawCount], 1);
	TextDrawSetShadow(menuTextDraw[menuTextDrawCount], 1);
	TextDrawUseBox(menuTextDraw[menuTextDrawCount], 1);
	TextDrawBoxColor(menuTextDraw[menuTextDrawCount], 1179010710);
	TextDrawTextSize(menuTextDraw[menuTextDrawCount], 241.000000, 0.000000);
	TextDrawSetSelectable(menuTextDraw[menuTextDrawCount++], 0);

	menuTextDrawID[E_MENU_TEXTDRAW_EMPTY_LEFT][1] = menuTextDrawCount;
	menuTextDraw[menuTextDrawCount] = TextDrawCreate(204.000000, 232.000000, "NOTHING CLOSE TO YOU");
	TextDrawAlignment(menuTextDraw[menuTextDrawCount], 2);
	TextDrawBackgroundColor(menuTextDraw[menuTextDrawCount], 0);
	TextDrawFont(menuTextDraw[menuTextDrawCount], FONT);
	TextDrawLetterSize(menuTextDraw[menuTextDrawCount], 0.149998, 0.899998);
	TextDrawColor(menuTextDraw[menuTextDrawCount], 1179010815);
	TextDrawSetOutline(menuTextDraw[menuTextDrawCount], 0);
	TextDrawSetProportional(menuTextDraw[menuTextDrawCount], 1);
	TextDrawSetShadow(menuTextDraw[menuTextDrawCount], 1);
	TextDrawSetSelectable(menuTextDraw[menuTextDrawCount++], 0);

	menuTextDrawID[E_MENU_TEXTDRAW_EMPTY_RIGHT][0] = menuTextDrawCount;
	menuTextDraw[menuTextDrawCount] = TextDrawCreate(262.000000, 237.000000, "_");
	TextDrawBackgroundColor(menuTextDraw[menuTextDrawCount], 255);
	TextDrawFont(menuTextDraw[menuTextDrawCount], 1);
	TextDrawLetterSize(menuTextDraw[menuTextDrawCount], 0.000000, -0.200001);
	TextDrawColor(menuTextDraw[menuTextDrawCount], -1);
	TextDrawSetOutline(menuTextDraw[menuTextDrawCount], 0);
	TextDrawSetProportional(menuTextDraw[menuTextDrawCount], 1);
	TextDrawSetShadow(menuTextDraw[menuTextDrawCount], 1);
	TextDrawUseBox(menuTextDraw[menuTextDrawCount], 1);
	TextDrawBoxColor(menuTextDraw[menuTextDrawCount], 1179010710);
	TextDrawTextSize(menuTextDraw[menuTextDrawCount], 481.000000, 0.000000);
	TextDrawSetSelectable(menuTextDraw[menuTextDrawCount++], 0);

	menuTextDrawID[E_MENU_TEXTDRAW_EMPTY_RIGHT][1] = menuTextDrawCount;
	menuTextDraw[menuTextDrawCount] = TextDrawCreate(373.000000, 232.000000, "NOTHING IN YOUR INVENTORY");
	TextDrawAlignment(menuTextDraw[menuTextDrawCount], 2);
	TextDrawBackgroundColor(menuTextDraw[menuTextDrawCount], 0);
	TextDrawFont(menuTextDraw[menuTextDrawCount], FONT);
	TextDrawLetterSize(menuTextDraw[menuTextDrawCount], 0.149998, 0.899998);
	TextDrawColor(menuTextDraw[menuTextDrawCount], 1179010815);
	TextDrawSetOutline(menuTextDraw[menuTextDrawCount], 0);
	TextDrawSetProportional(menuTextDraw[menuTextDrawCount], 1);
	TextDrawSetShadow(menuTextDraw[menuTextDrawCount], 1);
	TextDrawSetSelectable(menuTextDraw[menuTextDrawCount++], 0);

	//===============================================================
	//Car Information TDs

	CarInfoTD[0] = TextDrawCreate(311.000000, 142.000000, "_");
	TextDrawFont(CarInfoTD[0], 1);
	TextDrawLetterSize(CarInfoTD[0], 0.600000, 3.650000);
	TextDrawTextSize(CarInfoTD[0], 298.500000, 174.500000);
	TextDrawSetOutline(CarInfoTD[0], 1);
	TextDrawSetShadow(CarInfoTD[0], 0);
	TextDrawAlignment(CarInfoTD[0], 2);
	TextDrawColor(CarInfoTD[0], -1);
	TextDrawBackgroundColor(CarInfoTD[0], 255);
	TextDrawBoxColor(CarInfoTD[0], 255);
	TextDrawUseBox(CarInfoTD[0], 1);
	TextDrawSetProportional(CarInfoTD[0], 1);
	TextDrawSetSelectable(CarInfoTD[0], 0);

	CarInfoTD[1] = TextDrawCreate(311.000000, 144.000000, "_");
	TextDrawFont(CarInfoTD[1], 1);
	TextDrawLetterSize(CarInfoTD[1], 0.600000, 3.250000);
	TextDrawTextSize(CarInfoTD[1], 298.500000, 174.500000);
	TextDrawSetOutline(CarInfoTD[1], 1);
	TextDrawSetShadow(CarInfoTD[1], 0);
	TextDrawAlignment(CarInfoTD[1], 2);
	TextDrawColor(CarInfoTD[1], -1);
	TextDrawBackgroundColor(CarInfoTD[1], 255);
	TextDrawBoxColor(CarInfoTD[1], 1296911791);
	TextDrawUseBox(CarInfoTD[1], 1);
	TextDrawSetProportional(CarInfoTD[1], 1);
	TextDrawSetSelectable(CarInfoTD[1], 0);

	CarInfoTD[2] = TextDrawCreate(389.000000, 135.000000, "ld_chat:badchat");
	TextDrawFont(CarInfoTD[2], 4);
	TextDrawLetterSize(CarInfoTD[2], 0.600000, 2.000000);
	TextDrawTextSize(CarInfoTD[2], 17.000000, 17.000000);
	TextDrawSetOutline(CarInfoTD[2], 1);
	TextDrawSetShadow(CarInfoTD[2], 0);
	TextDrawAlignment(CarInfoTD[2], 1);
	TextDrawColor(CarInfoTD[2], -1);
	TextDrawBackgroundColor(CarInfoTD[2], 255);
	TextDrawBoxColor(CarInfoTD[2], 50);
	TextDrawUseBox(CarInfoTD[2], 1);
	TextDrawSetProportional(CarInfoTD[2], 1);
	TextDrawSetSelectable(CarInfoTD[2], 0);

	CarInfoTD[3] = TextDrawCreate(242.000000, 153.000000, "\\");
	TextDrawFont(CarInfoTD[3], 1);
	TextDrawLetterSize(CarInfoTD[3], 0.195832, 0.899999);
	TextDrawTextSize(CarInfoTD[3], 400.000000, 180.500000);
	TextDrawSetOutline(CarInfoTD[3], 1);
	TextDrawSetShadow(CarInfoTD[3], 0);
	TextDrawAlignment(CarInfoTD[3], 2);
	TextDrawColor(CarInfoTD[3], -1523963137);
	TextDrawBackgroundColor(CarInfoTD[3], 255);
	TextDrawBoxColor(CarInfoTD[3], 1097457995);
	TextDrawUseBox(CarInfoTD[3], 0);
	TextDrawSetProportional(CarInfoTD[3], 1);
	TextDrawSetSelectable(CarInfoTD[3], 0);

	//===============================================================
	//Spec TDs

	aSpecTD[0] = TextDrawCreate(319.000000, 360.000000, "_");
	TextDrawFont(aSpecTD[0], 1);
	TextDrawLetterSize(aSpecTD[0], 0.600000, 4.699991);
	TextDrawTextSize(aSpecTD[0], 302.500000, 117.500000);
	TextDrawSetOutline(aSpecTD[0], 1);
	TextDrawSetShadow(aSpecTD[0], 0);
	TextDrawAlignment(aSpecTD[0], 2);
	TextDrawColor(aSpecTD[0], -1);
	TextDrawBackgroundColor(aSpecTD[0], 255);
	TextDrawBoxColor(aSpecTD[0], -1094795596);
	TextDrawUseBox(aSpecTD[0], 1);
	TextDrawSetProportional(aSpecTD[0], 1);
	TextDrawSetSelectable(aSpecTD[0], 0);

	aSpecTD[1] = TextDrawCreate(370.000000, 358.000000, "LD_Beat:cross");
	TextDrawFont(aSpecTD[1], 4);
	TextDrawLetterSize(aSpecTD[1], 0.600000, 2.000000);
	TextDrawTextSize(aSpecTD[1], 10.500000, 11.000000);
	TextDrawSetOutline(aSpecTD[1], 1);
	TextDrawSetShadow(aSpecTD[1], 0);
	TextDrawAlignment(aSpecTD[1], 1);
	TextDrawColor(aSpecTD[1], -1);
	TextDrawBackgroundColor(aSpecTD[1], 255);
	TextDrawBoxColor(aSpecTD[1], 50);
	TextDrawUseBox(aSpecTD[1], 1);
	TextDrawSetProportional(aSpecTD[1], 1);
	TextDrawSetSelectable(aSpecTD[1], 1);

	aSpecTD[2] = TextDrawCreate(246.000000, 360.000000, "_");
	TextDrawFont(aSpecTD[2], 1);
	TextDrawLetterSize(aSpecTD[2], 0.600000, 4.699991);
	TextDrawTextSize(aSpecTD[2], 302.500000, 14.000000);
	TextDrawSetOutline(aSpecTD[2], 1);
	TextDrawSetShadow(aSpecTD[2], 0);
	TextDrawAlignment(aSpecTD[2], 2);
	TextDrawColor(aSpecTD[2], -1);
	TextDrawBackgroundColor(aSpecTD[2], 255);
	TextDrawBoxColor(aSpecTD[2], -1094795596);
	TextDrawUseBox(aSpecTD[2], 1);
	TextDrawSetProportional(aSpecTD[2], 1);
	TextDrawSetSelectable(aSpecTD[2], 0);

	aSpecTD[3] = TextDrawCreate(392.000000, 360.000000, "_");
	TextDrawFont(aSpecTD[3], 1);
	TextDrawLetterSize(aSpecTD[3], 0.600000, 4.699991);
	TextDrawTextSize(aSpecTD[3], 302.500000, 14.000000);
	TextDrawSetOutline(aSpecTD[3], 1);
	TextDrawSetShadow(aSpecTD[3], 0);
	TextDrawAlignment(aSpecTD[3], 2);
	TextDrawColor(aSpecTD[3], -1);
	TextDrawBackgroundColor(aSpecTD[3], 255);
	TextDrawBoxColor(aSpecTD[3], -1094795596);
	TextDrawUseBox(aSpecTD[3], 1);
	TextDrawSetProportional(aSpecTD[3], 1);
	TextDrawSetSelectable(aSpecTD[3], 0);

	aSpecTD[4] = TextDrawCreate(239.000000, 372.000000, "LD_BEAT:left");
	TextDrawFont(aSpecTD[4], 4);
	TextDrawLetterSize(aSpecTD[4], 0.600000, 2.000000);
	TextDrawTextSize(aSpecTD[4], 13.500000, 18.500000);
	TextDrawSetOutline(aSpecTD[4], 1);
	TextDrawSetShadow(aSpecTD[4], 0);
	TextDrawAlignment(aSpecTD[4], 1);
	TextDrawColor(aSpecTD[4], -1);
	TextDrawBackgroundColor(aSpecTD[4], 255);
	TextDrawBoxColor(aSpecTD[4], 50);
	TextDrawUseBox(aSpecTD[4], 1);
	TextDrawSetProportional(aSpecTD[4], 1);
	TextDrawSetSelectable(aSpecTD[4], 1);

	aSpecTD[5] = TextDrawCreate(386.000000, 372.000000, "LD_BEAT:right");
	TextDrawFont(aSpecTD[5], 4);
	TextDrawLetterSize(aSpecTD[5], 0.600000, 2.000000);
	TextDrawTextSize(aSpecTD[5], 13.500000, 18.500000);
	TextDrawSetOutline(aSpecTD[5], 1);
	TextDrawSetShadow(aSpecTD[5], 0);
	TextDrawAlignment(aSpecTD[5], 1);
	TextDrawColor(aSpecTD[5], -1);
	TextDrawBackgroundColor(aSpecTD[5], 255);
	TextDrawBoxColor(aSpecTD[5], 50);
	TextDrawUseBox(aSpecTD[5], 1);
	TextDrawSetProportional(aSpecTD[5], 1);
	TextDrawSetSelectable(aSpecTD[5], 1);

	aSpecTD[6] = TextDrawCreate(319.000000, 409.000000, "_");
	TextDrawFont(aSpecTD[6], 1);
	TextDrawLetterSize(aSpecTD[6], 0.550000, 1.449991);
	TextDrawTextSize(aSpecTD[6], 302.500000, 160.000000);
	TextDrawSetOutline(aSpecTD[6], 1);
	TextDrawSetShadow(aSpecTD[6], 0);
	TextDrawAlignment(aSpecTD[6], 2);
	TextDrawColor(aSpecTD[6], -1);
	TextDrawBackgroundColor(aSpecTD[6], 255);
	TextDrawBoxColor(aSpecTD[6], -1094795596);
	TextDrawUseBox(aSpecTD[6], 1);
	TextDrawSetProportional(aSpecTD[6], 1);
	TextDrawSetSelectable(aSpecTD[6], 0);

	aSpecTD[7] = TextDrawCreate(240.000000, 411.000000, "WEAPS");
	TextDrawFont(aSpecTD[7], 2);
	TextDrawLetterSize(aSpecTD[7], 0.183333, 0.900000);
	TextDrawTextSize(aSpecTD[7], 266.000000, 17.000000);
	TextDrawSetOutline(aSpecTD[7], 1);
	TextDrawSetShadow(aSpecTD[7], 0);
	TextDrawAlignment(aSpecTD[7], 1);
	TextDrawColor(aSpecTD[7], -1);
	TextDrawBackgroundColor(aSpecTD[7], 255);
	TextDrawBoxColor(aSpecTD[7], 50);
	TextDrawUseBox(aSpecTD[7], 0);
	TextDrawSetProportional(aSpecTD[7], 1);
	TextDrawSetSelectable(aSpecTD[7], 1);

	aSpecTD[8] = TextDrawCreate(273.000000, 411.000000, "Items");
	TextDrawFont(aSpecTD[8], 2);
	TextDrawLetterSize(aSpecTD[8], 0.183333, 0.900000);
	TextDrawTextSize(aSpecTD[8], 295.000000, 17.000000);
	TextDrawSetOutline(aSpecTD[8], 1);
	TextDrawSetShadow(aSpecTD[8], 0);
	TextDrawAlignment(aSpecTD[8], 1);
	TextDrawColor(aSpecTD[8], -1);
	TextDrawBackgroundColor(aSpecTD[8], 255);
	TextDrawBoxColor(aSpecTD[8], 50);
	TextDrawUseBox(aSpecTD[8], 0);
	TextDrawSetProportional(aSpecTD[8], 1);
	TextDrawSetSelectable(aSpecTD[8], 1);

	aSpecTD[9] = TextDrawCreate(302.000000, 411.000000, "BSTATS");
	TextDrawFont(aSpecTD[9], 2);
	TextDrawLetterSize(aSpecTD[9], 0.183333, 0.900000);
	TextDrawTextSize(aSpecTD[9], 331.000000, 17.000000);
	TextDrawSetOutline(aSpecTD[9], 1);
	TextDrawSetShadow(aSpecTD[9], 0);
	TextDrawAlignment(aSpecTD[9], 1);
	TextDrawColor(aSpecTD[9], -1);
	TextDrawBackgroundColor(aSpecTD[9], 255);
	TextDrawBoxColor(aSpecTD[9], 50);
	TextDrawUseBox(aSpecTD[9], 0);
	TextDrawSetProportional(aSpecTD[9], 1);
	TextDrawSetSelectable(aSpecTD[9], 1);

	aSpecTD[10] = TextDrawCreate(338.000000, 411.000000, "Info");
	TextDrawFont(aSpecTD[10], 2);
	TextDrawLetterSize(aSpecTD[10], 0.183333, 0.900000);
	TextDrawTextSize(aSpecTD[10], 355.000000, 17.000000);
	TextDrawSetOutline(aSpecTD[10], 1);
	TextDrawSetShadow(aSpecTD[10], 0);
	TextDrawAlignment(aSpecTD[10], 1);
	TextDrawColor(aSpecTD[10], -1);
	TextDrawBackgroundColor(aSpecTD[10], 255);
	TextDrawBoxColor(aSpecTD[10], 50);
	TextDrawUseBox(aSpecTD[10], 0);
	TextDrawSetProportional(aSpecTD[10], 1);
	TextDrawSetSelectable(aSpecTD[10], 1);

	aSpecTD[11] = TextDrawCreate(362.000000, 411.000000, "Panel");
	TextDrawFont(aSpecTD[11], 2);
	TextDrawLetterSize(aSpecTD[11], 0.183333, 0.900000);
	TextDrawTextSize(aSpecTD[11], 387.000000, 17.000000);
	TextDrawSetOutline(aSpecTD[11], 1);
	TextDrawSetShadow(aSpecTD[11], 0);
	TextDrawAlignment(aSpecTD[11], 1);
	TextDrawColor(aSpecTD[11], -1);
	TextDrawBackgroundColor(aSpecTD[11], 255);
	TextDrawBoxColor(aSpecTD[11], 50);
	TextDrawUseBox(aSpecTD[11], 0);
	TextDrawSetProportional(aSpecTD[11], 1);
	TextDrawSetSelectable(aSpecTD[11], 1);

	//===============================================================
	//Stats TDs

	Stats_TD[0] = TextDrawCreate(320.399902, 187.013320, "box");
	TextDrawLetterSize(Stats_TD[0], 0.000000, 11.999999);
	TextDrawTextSize(Stats_TD[0], 0.000000, 315.000000);
	TextDrawAlignment(Stats_TD[0], 2);
	TextDrawColor(Stats_TD[0], -1);
	TextDrawUseBox(Stats_TD[0], 1);
	TextDrawBoxColor(Stats_TD[0], 255);
	TextDrawSetShadow(Stats_TD[0], 0);
	TextDrawBackgroundColor(Stats_TD[0], 255);
	TextDrawFont(Stats_TD[0], 1);
	TextDrawSetProportional(Stats_TD[0], 1);

	Stats_TD[1] = TextDrawCreate(162.799942, 187.760025, "box");
	TextDrawLetterSize(Stats_TD[1], 0.000000, 11.759998);
	TextDrawTextSize(Stats_TD[1], 478.000000, 0.000000);
	TextDrawAlignment(Stats_TD[1], 1);
	TextDrawColor(Stats_TD[1], -1);
	TextDrawUseBox(Stats_TD[1], 1);
	TextDrawBoxColor(Stats_TD[1], -2109750253);
	TextDrawSetShadow(Stats_TD[1], 0);
	TextDrawBackgroundColor(Stats_TD[1], 255);
	TextDrawFont(Stats_TD[1], 1);
	TextDrawSetProportional(Stats_TD[1], 1);

	Stats_TD[2] = TextDrawCreate(438.599914, 274.466735, "LD_BEAT:left");
	TextDrawTextSize(Stats_TD[2], 16.000000, 20.000000);
	TextDrawAlignment(Stats_TD[2], 1);
	TextDrawColor(Stats_TD[2], -1);
	TextDrawSetShadow(Stats_TD[2], 0);
	TextDrawBackgroundColor(Stats_TD[2], 255);
	TextDrawFont(Stats_TD[2], 4);
	TextDrawSetProportional(Stats_TD[2], 0);
	TextDrawSetSelectable(Stats_TD[2], true);

	Stats_TD[3] = TextDrawCreate(460.999938, 274.466735, "LD_BEAT:right");
	TextDrawTextSize(Stats_TD[3], 16.000000, 20.000000);
	TextDrawAlignment(Stats_TD[3], 1);
	TextDrawColor(Stats_TD[3], -1);
	TextDrawSetShadow(Stats_TD[3], 0);
	TextDrawBackgroundColor(Stats_TD[3], 255);
	TextDrawFont(Stats_TD[3], 4);
	TextDrawSetProportional(Stats_TD[3], 0);
	TextDrawSetSelectable(Stats_TD[3], true);

	Stats_TD[4] = TextDrawCreate(463.399963, 188.600143, "LD_BEAT:cross");
	TextDrawTextSize(Stats_TD[4], 15.000000, 17.000000);
	TextDrawAlignment(Stats_TD[4], 1);
	TextDrawColor(Stats_TD[4], -1);
	TextDrawSetShadow(Stats_TD[4], 0);
	TextDrawBackgroundColor(Stats_TD[4], 255);
	TextDrawFont(Stats_TD[4], 4);
	TextDrawSetProportional(Stats_TD[4], 0);
	TextDrawSetSelectable(Stats_TD[4], true);

	Stats_TD[5] = TextDrawCreate(245.200012, 205.680038, "o");
	TextDrawLetterSize(Stats_TD[5], 7.507999, 0.248533);
	TextDrawTextSize(Stats_TD[5], 34.000000, 0.000000);
	TextDrawAlignment(Stats_TD[5], 1);
	TextDrawColor(Stats_TD[5], -1);
	TextDrawSetShadow(Stats_TD[5], 0);
	TextDrawBackgroundColor(Stats_TD[5], 255);
	TextDrawFont(Stats_TD[5], 1);
	TextDrawSetProportional(Stats_TD[5], 1);

	//===============================================================
	//Box Interface

	Box_TD[0] = TextDrawCreate(527.000000, 434.000000, "_");
	TextDrawFont(Box_TD[0], 1);
	TextDrawLetterSize(Box_TD[0], 0.620832, 1.099990);
	TextDrawTextSize(Box_TD[0], 309.500000, 247.000000);
	TextDrawSetOutline(Box_TD[0], 1);
	TextDrawSetShadow(Box_TD[0], 0);
	TextDrawAlignment(Box_TD[0], 2);
	TextDrawColor(Box_TD[0], -1);
	TextDrawBackgroundColor(Box_TD[0], 255);
	TextDrawBoxColor(Box_TD[0], 255);
	TextDrawUseBox(Box_TD[0], 1);
	TextDrawSetProportional(Box_TD[0], 1);
	TextDrawSetSelectable(Box_TD[0], 0);

	Box_TD[1] = TextDrawCreate(611.000000, 436.000000, "_");
	TextDrawFont(Box_TD[1], 1);
	TextDrawLetterSize(Box_TD[1], 0.620832, 0.699990);
	TextDrawTextSize(Box_TD[1], 309.500000, 74.000000);
	TextDrawSetOutline(Box_TD[1], 1);
	TextDrawSetShadow(Box_TD[1], 0);
	TextDrawAlignment(Box_TD[1], 2);
	TextDrawColor(Box_TD[1], -1);
	TextDrawBackgroundColor(Box_TD[1], 255);
	TextDrawBoxColor(Box_TD[1], 1097458175);
	TextDrawUseBox(Box_TD[1], 1);
	TextDrawSetProportional(Box_TD[1], 1);
	TextDrawSetSelectable(Box_TD[1], 0);

	//===============================================================
	//Site TD

	Site_TD = TextDrawCreate(614.000000, 5.000000, "H2OMULTIPLAYER.COM");
	TextDrawFont(Site_TD, 1);
	TextDrawLetterSize(Site_TD, 0.150000, 0.649999);
	TextDrawTextSize(Site_TD, 400.000000, 17.000000);
	TextDrawSetOutline(Site_TD, 1);
	TextDrawSetShadow(Site_TD, 0);
	TextDrawAlignment(Site_TD, 3);
	TextDrawColor(Site_TD, -1);
	TextDrawBackgroundColor(Site_TD, 255);
	TextDrawBoxColor(Site_TD, 50);
	TextDrawUseBox(Site_TD, 0);
	TextDrawSetProportional(Site_TD, 1);
	TextDrawSetSelectable(Site_TD, 0);

	SvT_TD = TextDrawCreate(633.000000, 436.000000, "SWAT vs Terrorists");
	TextDrawFont(SvT_TD, 1);
	TextDrawLetterSize(SvT_TD, 0.150000, 0.649999);
	TextDrawTextSize(SvT_TD, 400.000000, 17.000000);
	TextDrawSetOutline(SvT_TD, 1);
	TextDrawSetShadow(SvT_TD, 0);
	TextDrawAlignment(SvT_TD, 3);
	TextDrawColor(SvT_TD, -1);
	TextDrawBackgroundColor(SvT_TD, 255);
	TextDrawBoxColor(SvT_TD, 50);
	TextDrawUseBox(SvT_TD, 0);
	TextDrawSetProportional(SvT_TD, 1);
	TextDrawSetSelectable(SvT_TD, 0);

	//===============================================================
	//DM Textdraws

	DMBox = TextDrawCreate(424.137634, 47.583335, "usebox");
	TextDrawLetterSize(DMBox, 0.000000, 1.692592);
	TextDrawTextSize(DMBox, 227.575408, 0.000000);
	TextDrawAlignment(DMBox, 1);
	TextDrawColor(DMBox, 0);
	TextDrawUseBox(DMBox, true);
	TextDrawBoxColor(DMBox, 102);
	TextDrawSetShadow(DMBox, 0);
	TextDrawSetOutline(DMBox, 0);
	TextDrawFont(DMBox, 0);

	DMText = TextDrawCreate(236.603118, 47.249961, "ELIMINATE ALL ENEMIES");
	TextDrawLetterSize(DMText, 0.449999, 1.600000);
	TextDrawAlignment(DMText, 1);
	TextDrawColor(DMText, -1);
	TextDrawSetShadow(DMText, 0);
	TextDrawSetOutline(DMText, 1);
	TextDrawBackgroundColor(DMText, 51);
	TextDrawFont(DMText, 1);
	TextDrawSetProportional(DMText, 1);

	DMText2[0] = TextDrawCreate(96.000000, 171.000000, "_");
	TextDrawFont(DMText2[0], 1);
	TextDrawLetterSize(DMText2[0], 0.600000, 10.300003);
	TextDrawTextSize(DMText2[0], 410.500000, 116.000000);
	TextDrawSetOutline(DMText2[0], 1);
	TextDrawSetShadow(DMText2[0], 0);
	TextDrawAlignment(DMText2[0], 2);
	TextDrawColor(DMText2[0], -1);
	TextDrawBackgroundColor(DMText2[0], 255);
	TextDrawBoxColor(DMText2[0], 135);
	TextDrawUseBox(DMText2[0], 1);
	TextDrawSetProportional(DMText2[0], 1);
	TextDrawSetSelectable(DMText2[0], 0);

	DMText2[1] = TextDrawCreate(107.000000, 182.000000, ".");
	TextDrawFont(DMText2[1], 1);
	TextDrawLetterSize(DMText2[1], 13.116702, 0.350001);
	TextDrawTextSize(DMText2[1], 400.000000, 17.000000);
	TextDrawSetOutline(DMText2[1], 0);
	TextDrawSetShadow(DMText2[1], 0);
	TextDrawAlignment(DMText2[1], 2);
	TextDrawColor(DMText2[1], -1);
	TextDrawBackgroundColor(DMText2[1], 255);
	TextDrawBoxColor(DMText2[1], 50);
	TextDrawUseBox(DMText2[1], 0);
	TextDrawSetProportional(DMText2[1], 1);
	TextDrawSetSelectable(DMText2[1], 0);

	DMText2[2] = TextDrawCreate(38.000000, 166.000000, "Top Deathmatchers");
	TextDrawFont(DMText2[2], 2);
	TextDrawLetterSize(DMText2[2], 0.254167, 2.000000);
	TextDrawTextSize(DMText2[2], 400.000000, 17.000000);
	TextDrawSetOutline(DMText2[2], 1);
	TextDrawSetShadow(DMText2[2], 0);
	TextDrawAlignment(DMText2[2], 1);
	TextDrawColor(DMText2[2], -1);
	TextDrawBackgroundColor(DMText2[2], 255);
	TextDrawBoxColor(DMText2[2], 50);
	TextDrawUseBox(DMText2[2], 0);
	TextDrawSetProportional(DMText2[2], 1);
	TextDrawSetSelectable(DMText2[2], 0);

	DMText2[3] = TextDrawCreate(38.000000, 185.000000, "_");
	TextDrawFont(DMText2[3], 1);
	TextDrawLetterSize(DMText2[3], 0.220833, 1.600000);
	TextDrawTextSize(DMText2[3], 400.000000, 17.000000);
	TextDrawSetOutline(DMText2[3], 1);
	TextDrawSetShadow(DMText2[3], 0);
	TextDrawAlignment(DMText2[3], 1);
	TextDrawColor(DMText2[3], -1);
	TextDrawBackgroundColor(DMText2[3], 255);
	TextDrawBoxColor(DMText2[3], 50);
	TextDrawUseBox(DMText2[3], 0);
	TextDrawSetProportional(DMText2[3], 1);
	TextDrawSetSelectable(DMText2[3], 0);
	return 1;
}

RemoveUI() {
	for (new i = 0; i < sizeof(SvTTD); i++) {
		TextDrawDestroy(SvTTD[i]);
	}

	for (new i = 0; i < sizeof(Stats_TD); i++) {
		TextDrawDestroy(Stats_TD[i]);
	}
	for (new i = 0; i < sizeof(aSpecTD); i++) {
		TextDrawDestroy(aSpecTD[i]);
	}
	for (new i; i < menuTextDrawCount; i++) {
		TextDrawDestroy(menuTextDraw[i]);
	}
	for (new i = 0; i < sizeof(PUBGWinnerTD); i++) {
		TextDrawDestroy(PUBGWinnerTD[i]);
	}

	TextDrawDestroy(PUBGAreaTD);
	TextDrawDestroy(PUBGKillsTD);
	TextDrawDestroy(PUBGAliveTD);
	TextDrawDestroy(PUBGKillTD);
	TextDrawDestroy(CarInfoTD[0]);
	TextDrawDestroy(CarInfoTD[1]);
	TextDrawDestroy(CarInfoTD[2]);
	TextDrawDestroy(CarInfoTD[3]);
	for (new i = 0; i < sizeof(Box_TD); i++) {
		TextDrawDestroy(Box_TD[i]);
	}
	TextDrawDestroy(Site_TD);
	TextDrawDestroy(SvT_TD);
	TextDrawDestroy(War_TD);
	TextDrawDestroy(War_TDBox);
	TextDrawDestroy(DMText);
	TextDrawDestroy(DMText2[0]);
	TextDrawDestroy(DMText2[1]);
	TextDrawDestroy(DMText2[2]);
	TextDrawDestroy(DMText2[3]);
	TextDrawDestroy(DMBox);
	return 1;
}

CreatePlayerUI(playerid) {
	//Capture progress bar
	Player_ProgressBar[playerid] = CreatePlayerProgressBar(playerid, 54.000000, 323.000000, 75.0000000, 2.400000, 0xB9C9BFFF, 20, BAR_DIRECTION_RIGHT);

	//Stats textdraws
	Stats_PTD[playerid][0] = CreatePlayerTextDraw(playerid, 320.399597, 187.012878, "_");
	PlayerTextDrawLetterSize(playerid, Stats_PTD[playerid][0], 0.501599, 1.883733);
	PlayerTextDrawTextSize(playerid, Stats_PTD[playerid][0], 0.000000, 230.000000);
	PlayerTextDrawAlignment(playerid, Stats_PTD[playerid][0], 2);
	PlayerTextDrawColor(playerid, Stats_PTD[playerid][0], -1);
	PlayerTextDrawSetShadow(playerid, Stats_PTD[playerid][0], 0);
	PlayerTextDrawSetOutline(playerid, Stats_PTD[playerid][0], 1);
	PlayerTextDrawBackgroundColor(playerid, Stats_PTD[playerid][0], 255);
	PlayerTextDrawFont(playerid, Stats_PTD[playerid][0], 3);
	PlayerTextDrawSetProportional(playerid, Stats_PTD[playerid][0], 1);

	Stats_PTD[playerid][1] = CreatePlayerTextDraw(playerid, 165.999984, 215.386611, "_");
	PlayerTextDrawLetterSize(playerid, Stats_PTD[playerid][1], 0.232799, 0.927999);
	PlayerTextDrawTextSize(playerid, Stats_PTD[playerid][1], 331.000000, 0.000000);
	PlayerTextDrawAlignment(playerid, Stats_PTD[playerid][1], 1);
	PlayerTextDrawColor(playerid, Stats_PTD[playerid][1], -1);
	PlayerTextDrawSetShadow(playerid, Stats_PTD[playerid][1], 0);
	PlayerTextDrawSetOutline(playerid, Stats_PTD[playerid][1], -1);
	PlayerTextDrawBackgroundColor(playerid, Stats_PTD[playerid][1], 255);
	PlayerTextDrawFont(playerid, Stats_PTD[playerid][1], 2);
	PlayerTextDrawSetProportional(playerid, Stats_PTD[playerid][1], 1);

	Stats_PTD[playerid][2] = CreatePlayerTextDraw(playerid, 285.199737, 215.386688, "_");
	PlayerTextDrawLetterSize(playerid, Stats_PTD[playerid][2], 0.232799, 0.927999);
	PlayerTextDrawTextSize(playerid, Stats_PTD[playerid][2], 519.000000, 0.000000);
	PlayerTextDrawAlignment(playerid, Stats_PTD[playerid][2], 1);
	PlayerTextDrawColor(playerid, Stats_PTD[playerid][2], -1);
	PlayerTextDrawSetShadow(playerid, Stats_PTD[playerid][2], 0);
	PlayerTextDrawSetOutline(playerid, Stats_PTD[playerid][2], -1);
	PlayerTextDrawBackgroundColor(playerid, Stats_PTD[playerid][2], 255);
	PlayerTextDrawFont(playerid, Stats_PTD[playerid][2], 2);
	PlayerTextDrawSetProportional(playerid, Stats_PTD[playerid][2], 1);   

	//Inventory system
	menuPlayerTextDrawID[playerid][E_MENU_TEXTDRAW_SCROLL] = menuPlayerTextDrawCount[playerid];
	menuPlayerTextDraw[playerid][menuPlayerTextDrawCount[playerid]] = CreatePlayerTextDraw(playerid, 246.000000, 172.000000, "_");
	PlayerTextDrawBackgroundColor(playerid, menuPlayerTextDraw[playerid][menuPlayerTextDrawCount[playerid]], 255);
	PlayerTextDrawFont(playerid, menuPlayerTextDraw[playerid][menuPlayerTextDrawCount[playerid]], 1);
	PlayerTextDrawLetterSize(playerid, menuPlayerTextDraw[playerid][menuPlayerTextDrawCount[playerid]], 0.000000, 14.599998);
	PlayerTextDrawColor(playerid, menuPlayerTextDraw[playerid][menuPlayerTextDrawCount[playerid]], -1);
	PlayerTextDrawSetOutline(playerid, menuPlayerTextDraw[playerid][menuPlayerTextDrawCount[playerid]], 0);
	PlayerTextDrawSetProportional(playerid, menuPlayerTextDraw[playerid][menuPlayerTextDrawCount[playerid]], 1);
	PlayerTextDrawSetShadow(playerid, menuPlayerTextDraw[playerid][menuPlayerTextDrawCount[playerid]], 1);
	PlayerTextDrawUseBox(playerid, menuPlayerTextDraw[playerid][menuPlayerTextDrawCount[playerid]], 1);
	PlayerTextDrawBoxColor(playerid, menuPlayerTextDraw[playerid][menuPlayerTextDrawCount[playerid]], -1768515896);
	PlayerTextDrawTextSize(playerid, menuPlayerTextDraw[playerid][menuPlayerTextDrawCount[playerid]], 247.000000, 0.000000);
	PlayerTextDrawSetSelectable(playerid, menuPlayerTextDraw[playerid][menuPlayerTextDrawCount[playerid]++], 0);

	menuPlayerTextDrawID[playerid][E_MENU_TEXTDRAW_LEFT_COUNT] = menuPlayerTextDrawCount[playerid];
	menuPlayerTextDraw[playerid][menuPlayerTextDrawCount[playerid]] = CreatePlayerTextDraw(playerid,162.000000, 150.000000, "Items close to you: ~y~0");
	PlayerTextDrawBackgroundColor(playerid,menuPlayerTextDraw[playerid][menuPlayerTextDrawCount[playerid]], 0);
	PlayerTextDrawFont(playerid,menuPlayerTextDraw[playerid][menuPlayerTextDrawCount[playerid]], FONT);
	PlayerTextDrawLetterSize(playerid,menuPlayerTextDraw[playerid][menuPlayerTextDrawCount[playerid]], 0.159998, 0.899999);
	PlayerTextDrawColor(playerid,menuPlayerTextDraw[playerid][menuPlayerTextDrawCount[playerid]], -1);
	PlayerTextDrawSetOutline(playerid,menuPlayerTextDraw[playerid][menuPlayerTextDrawCount[playerid]], 0);
	PlayerTextDrawSetProportional(playerid,menuPlayerTextDraw[playerid][menuPlayerTextDrawCount[playerid]], 1);
	PlayerTextDrawSetShadow(playerid,menuPlayerTextDraw[playerid][menuPlayerTextDrawCount[playerid]], 1);
	PlayerTextDrawSetSelectable(playerid,menuPlayerTextDraw[playerid][menuPlayerTextDrawCount[playerid]++], 0);

	menuPlayerTextDrawID[playerid][E_MENU_TEXTDRAW_RIGHT_COUNT] = menuPlayerTextDrawCount[playerid];
	menuPlayerTextDraw[playerid][menuPlayerTextDrawCount[playerid]] = CreatePlayerTextDraw(playerid,255.000000, 150.000000, "Items in your inventory: ~y~13/15");
	PlayerTextDrawBackgroundColor(playerid,menuPlayerTextDraw[playerid][menuPlayerTextDrawCount[playerid]], 0);
	PlayerTextDrawFont(playerid,menuPlayerTextDraw[playerid][menuPlayerTextDrawCount[playerid]], FONT);
	PlayerTextDrawLetterSize(playerid,menuPlayerTextDraw[playerid][menuPlayerTextDrawCount[playerid]], 0.159998, 0.899999);
	PlayerTextDrawColor(playerid,menuPlayerTextDraw[playerid][menuPlayerTextDrawCount[playerid]], -1);
	PlayerTextDrawSetOutline(playerid,menuPlayerTextDraw[playerid][menuPlayerTextDrawCount[playerid]], 0);
	PlayerTextDrawSetProportional(playerid,menuPlayerTextDraw[playerid][menuPlayerTextDrawCount[playerid]], 1);
	PlayerTextDrawSetShadow(playerid,menuPlayerTextDraw[playerid][menuPlayerTextDrawCount[playerid]], 1);
	PlayerTextDrawSetSelectable(playerid,menuPlayerTextDraw[playerid][menuPlayerTextDrawCount[playerid]++], 0);

	for (new i; i < MAX_LEFT_MENU_ROWS; i++) {
		menuPlayerTextDrawID[playerid][E_MENU_TEXTDRAW_LEFT_TEXT][i] = menuPlayerTextDrawCount[playerid];
		menuPlayerTextDraw[playerid][menuPlayerTextDrawCount[playerid]] = CreatePlayerTextDraw(playerid, 186.000000, (164.000000 + (i * 22.000000)), "-");
		PlayerTextDrawBackgroundColor(playerid,menuPlayerTextDraw[playerid][menuPlayerTextDrawCount[playerid]], 0);
		PlayerTextDrawFont(playerid,menuPlayerTextDraw[playerid][menuPlayerTextDrawCount[playerid]], FONT);
		PlayerTextDrawLetterSize(playerid,menuPlayerTextDraw[playerid][menuPlayerTextDrawCount[playerid]], 0.119998, 0.699998);
		PlayerTextDrawColor(playerid,menuPlayerTextDraw[playerid][menuPlayerTextDrawCount[playerid]], -926365441);
		PlayerTextDrawSetOutline(playerid,menuPlayerTextDraw[playerid][menuPlayerTextDrawCount[playerid]], 0);
		PlayerTextDrawSetProportional(playerid,menuPlayerTextDraw[playerid][menuPlayerTextDrawCount[playerid]], 1);
		PlayerTextDrawSetShadow(playerid,menuPlayerTextDraw[playerid][menuPlayerTextDrawCount[playerid]], 1);
		PlayerTextDrawUseBox(playerid,menuPlayerTextDraw[playerid][menuPlayerTextDrawCount[playerid]], 1);
		PlayerTextDrawBoxColor(playerid,menuPlayerTextDraw[playerid][menuPlayerTextDrawCount[playerid]], 0);
		PlayerTextDrawTextSize(playerid,menuPlayerTextDraw[playerid][menuPlayerTextDrawCount[playerid]], 238.000000, 0.000000);
		PlayerTextDrawSetSelectable(playerid,menuPlayerTextDraw[playerid][menuPlayerTextDrawCount[playerid]++], 0);
	}

	for (new a; a < MAX_RIGHT_MENU_ROWS; a++) {
		for (new b; b < MAX_RIGHT_MENU_COLUMNS; b++) {
			menuPlayerTextDrawID[playerid][E_MENU_TEXTDRAW_RIGHT_TEXT][(a * MAX_RIGHT_MENU_COLUMNS) + b] = menuPlayerTextDrawCount[playerid];
			menuPlayerTextDraw[playerid][menuPlayerTextDrawCount[playerid]] = CreatePlayerTextDraw(playerid, (260.000000 + (b * 46.000000)), (193.000000 + (a * 51.000000)), "-");
			PlayerTextDrawBackgroundColor(playerid,menuPlayerTextDraw[playerid][menuPlayerTextDrawCount[playerid]], 0);
			PlayerTextDrawFont(playerid,menuPlayerTextDraw[playerid][menuPlayerTextDrawCount[playerid]], FONT);
			PlayerTextDrawLetterSize(playerid,menuPlayerTextDraw[playerid][menuPlayerTextDrawCount[playerid]], 0.149999, 0.799998);
			PlayerTextDrawColor(playerid,menuPlayerTextDraw[playerid][menuPlayerTextDrawCount[playerid]], -926365441);
			PlayerTextDrawSetOutline(playerid,menuPlayerTextDraw[playerid][menuPlayerTextDrawCount[playerid]], 0);
			PlayerTextDrawSetProportional(playerid,menuPlayerTextDraw[playerid][menuPlayerTextDrawCount[playerid]], 1);
			PlayerTextDrawSetShadow(playerid,menuPlayerTextDraw[playerid][menuPlayerTextDrawCount[playerid]], 1);
			PlayerTextDrawUseBox(playerid,menuPlayerTextDraw[playerid][menuPlayerTextDrawCount[playerid]], 1);
			PlayerTextDrawBoxColor(playerid,menuPlayerTextDraw[playerid][menuPlayerTextDrawCount[playerid]], 0);
			PlayerTextDrawTextSize(playerid,menuPlayerTextDraw[playerid][menuPlayerTextDrawCount[playerid]], (300.000000 + (b * 46.000000)), (0.000000 + (a * 51.000000)));
			PlayerTextDrawSetSelectable(playerid,menuPlayerTextDraw[playerid][menuPlayerTextDrawCount[playerid]++], 0);
		}
	}

	//Car information system
	CarInfoPTD[playerid][0] = CreatePlayerTextDraw(playerid, 309.000000, 144.000000, "~y~Model~w~: Anti-Aircraft");
	PlayerTextDrawFont(playerid, CarInfoPTD[playerid][0], 1);
	PlayerTextDrawLetterSize(playerid, CarInfoPTD[playerid][0], 0.195832, 0.899999);
	PlayerTextDrawTextSize(playerid, CarInfoPTD[playerid][0], 400.000000, 180.500000);
	PlayerTextDrawSetOutline(playerid, CarInfoPTD[playerid][0], 0);
	PlayerTextDrawSetShadow(playerid, CarInfoPTD[playerid][0], 0);
	PlayerTextDrawAlignment(playerid, CarInfoPTD[playerid][0], 2);
	PlayerTextDrawColor(playerid, CarInfoPTD[playerid][0], -1);
	PlayerTextDrawBackgroundColor(playerid, CarInfoPTD[playerid][0], 255);
	PlayerTextDrawBoxColor(playerid, CarInfoPTD[playerid][0], 1097457995);
	PlayerTextDrawUseBox(playerid, CarInfoPTD[playerid][0], 0);
	PlayerTextDrawSetProportional(playerid, CarInfoPTD[playerid][0], 1);
	PlayerTextDrawSetSelectable(playerid, CarInfoPTD[playerid][0], 0);

	CarInfoPTD[playerid][1] = CreatePlayerTextDraw(playerid, 312.000000, 155.000000, "~y~Abilities~w~: Can fire rockets");
	PlayerTextDrawFont(playerid, CarInfoPTD[playerid][1], 1);
	PlayerTextDrawLetterSize(playerid, CarInfoPTD[playerid][1], 0.195832, 0.899999);
	PlayerTextDrawTextSize(playerid, CarInfoPTD[playerid][1], 400.000000, 180.500000);
	PlayerTextDrawSetOutline(playerid, CarInfoPTD[playerid][1], 0);
	PlayerTextDrawSetShadow(playerid, CarInfoPTD[playerid][1], 0);
	PlayerTextDrawAlignment(playerid, CarInfoPTD[playerid][1], 2);
	PlayerTextDrawColor(playerid, CarInfoPTD[playerid][1], -1);
	PlayerTextDrawBackgroundColor(playerid, CarInfoPTD[playerid][1], 255);
	PlayerTextDrawBoxColor(playerid, CarInfoPTD[playerid][1], 1097457995);
	PlayerTextDrawUseBox(playerid, CarInfoPTD[playerid][1], 0);
	PlayerTextDrawSetProportional(playerid, CarInfoPTD[playerid][1], 1);
	PlayerTextDrawSetSelectable(playerid, CarInfoPTD[playerid][1], 0);

	CarInfoPTD[playerid][2] = CreatePlayerTextDraw(playerid, 310.000000, 166.000000, "~y~Requirments~w~: 3000 score");
	PlayerTextDrawFont(playerid, CarInfoPTD[playerid][2], 1);
	PlayerTextDrawLetterSize(playerid, CarInfoPTD[playerid][2], 0.195832, 0.899999);
	PlayerTextDrawTextSize(playerid, CarInfoPTD[playerid][2], 400.000000, 180.500000);
	PlayerTextDrawSetOutline(playerid, CarInfoPTD[playerid][2], 0);
	PlayerTextDrawSetShadow(playerid, CarInfoPTD[playerid][2], 0);
	PlayerTextDrawAlignment(playerid, CarInfoPTD[playerid][2], 2);
	PlayerTextDrawColor(playerid, CarInfoPTD[playerid][2], -1);
	PlayerTextDrawBackgroundColor(playerid, CarInfoPTD[playerid][2], 255);
	PlayerTextDrawBoxColor(playerid, CarInfoPTD[playerid][2], 1097457995);
	PlayerTextDrawUseBox(playerid, CarInfoPTD[playerid][2], 0);
	PlayerTextDrawSetProportional(playerid, CarInfoPTD[playerid][2], 1);
	PlayerTextDrawSetSelectable(playerid, CarInfoPTD[playerid][2], 0);

	//PUBG event
	PUBGBonusTD[playerid] = CreatePlayerTextDraw(playerid, 321.000000, 192.000000, "~g~+2 Score & $5000");
	PlayerTextDrawFont(playerid, PUBGBonusTD[playerid], 2);
	PlayerTextDrawLetterSize(playerid, PUBGBonusTD[playerid], 0.266667, 1.450000);
	PlayerTextDrawTextSize(playerid, PUBGBonusTD[playerid], 400.000000, 387.000000);
	PlayerTextDrawSetOutline(playerid, PUBGBonusTD[playerid], 0);
	PlayerTextDrawSetShadow(playerid, PUBGBonusTD[playerid], 0);
	PlayerTextDrawAlignment(playerid, PUBGBonusTD[playerid], 2);
	PlayerTextDrawColor(playerid, PUBGBonusTD[playerid], -1);
	PlayerTextDrawBackgroundColor(playerid, PUBGBonusTD[playerid], 255);
	PlayerTextDrawBoxColor(playerid, PUBGBonusTD[playerid], 50);
	PlayerTextDrawUseBox(playerid, PUBGBonusTD[playerid], 0);
	PlayerTextDrawSetProportional(playerid, PUBGBonusTD[playerid], 1);
	PlayerTextDrawSetSelectable(playerid, PUBGBonusTD[playerid], 0);

	//Flashbang
	FlashTD[playerid] = CreatePlayerTextDraw(playerid, 345.000000, -10.000000, "_");
	PlayerTextDrawAlignment(playerid, FlashTD[playerid], 2);
	PlayerTextDrawBackgroundColor(playerid, FlashTD[playerid], 255);
	PlayerTextDrawFont(playerid, FlashTD[playerid], 3);
	PlayerTextDrawLetterSize(playerid, FlashTD[playerid], 0.210000, 51.300003);
	PlayerTextDrawColor(playerid, FlashTD[playerid], -1);
	PlayerTextDrawSetOutline(playerid, FlashTD[playerid], 0);
	PlayerTextDrawSetProportional(playerid, FlashTD[playerid], 1);
	PlayerTextDrawSetShadow(playerid, FlashTD[playerid], 546);
	PlayerTextDrawUseBox(playerid, FlashTD[playerid], 1);
	PlayerTextDrawBoxColor(playerid, FlashTD[playerid], 0xFFFFFFFF);
	PlayerTextDrawTextSize(playerid, FlashTD[playerid], 152.000000, 706.000000);	

	//Spec system
	aSpecPTD[playerid][0] = CreatePlayerTextDraw(playerid, 260.000000, 360.000000, "Preview_Model");
	PlayerTextDrawFont(playerid, aSpecPTD[playerid][0], 5);
	PlayerTextDrawLetterSize(playerid, aSpecPTD[playerid][0], 0.600000, 2.000000);
	PlayerTextDrawTextSize(playerid, aSpecPTD[playerid][0], 36.500000, 42.000000);
	PlayerTextDrawSetOutline(playerid, aSpecPTD[playerid][0], 0);
	PlayerTextDrawSetShadow(playerid, aSpecPTD[playerid][0], 0);
	PlayerTextDrawAlignment(playerid, aSpecPTD[playerid][0], 1);
	PlayerTextDrawColor(playerid, aSpecPTD[playerid][0], -1);
	PlayerTextDrawBackgroundColor(playerid, aSpecPTD[playerid][0], 125);
	PlayerTextDrawBoxColor(playerid, aSpecPTD[playerid][0], 255);
	PlayerTextDrawUseBox(playerid, aSpecPTD[playerid][0], 0);
	PlayerTextDrawSetProportional(playerid, aSpecPTD[playerid][0], 1);
	PlayerTextDrawSetSelectable(playerid, aSpecPTD[playerid][0], 0);
	PlayerTextDrawSetPreviewModel(playerid, aSpecPTD[playerid][0], 0);
	PlayerTextDrawSetPreviewRot(playerid, aSpecPTD[playerid][0], -10.000000, 0.000000, -20.000000, 1.000000);
	PlayerTextDrawSetPreviewVehCol(playerid, aSpecPTD[playerid][0], 1, 1);

	aSpecPTD[playerid][1] = CreatePlayerTextDraw(playerid, 299.000000, 360.000000, "_");
	PlayerTextDrawFont(playerid, aSpecPTD[playerid][1], 1);
	PlayerTextDrawLetterSize(playerid, aSpecPTD[playerid][1], 0.225000, 0.800000);
	PlayerTextDrawTextSize(playerid, aSpecPTD[playerid][1], 400.000000, 17.000000);
	PlayerTextDrawSetOutline(playerid, aSpecPTD[playerid][1], 1);
	PlayerTextDrawSetShadow(playerid, aSpecPTD[playerid][1], 0);
	PlayerTextDrawAlignment(playerid, aSpecPTD[playerid][1], 1);
	PlayerTextDrawColor(playerid, aSpecPTD[playerid][1], -8388353);
	PlayerTextDrawBackgroundColor(playerid, aSpecPTD[playerid][1], 255);
	PlayerTextDrawBoxColor(playerid, aSpecPTD[playerid][1], 50);
	PlayerTextDrawUseBox(playerid, aSpecPTD[playerid][1], 0);
	PlayerTextDrawSetProportional(playerid, aSpecPTD[playerid][1], 1);
	PlayerTextDrawSetSelectable(playerid, aSpecPTD[playerid][1], 0);

	aSpecPTD[playerid][2] = CreatePlayerTextDraw(playerid, 299.000000, 372.000000, "_");
	PlayerTextDrawFont(playerid, aSpecPTD[playerid][2], 1);
	PlayerTextDrawLetterSize(playerid, aSpecPTD[playerid][2], 0.183333, 0.900000);
	PlayerTextDrawTextSize(playerid, aSpecPTD[playerid][2], 400.000000, 17.000000);
	PlayerTextDrawSetOutline(playerid, aSpecPTD[playerid][2], 1);
	PlayerTextDrawSetShadow(playerid, aSpecPTD[playerid][2], 0);
	PlayerTextDrawAlignment(playerid, aSpecPTD[playerid][2], 1);
	PlayerTextDrawColor(playerid, aSpecPTD[playerid][2], -1);
	PlayerTextDrawBackgroundColor(playerid, aSpecPTD[playerid][2], 255);
	PlayerTextDrawBoxColor(playerid, aSpecPTD[playerid][2], 50);
	PlayerTextDrawUseBox(playerid, aSpecPTD[playerid][2], 0);
	PlayerTextDrawSetProportional(playerid, aSpecPTD[playerid][2], 1);
	PlayerTextDrawSetSelectable(playerid, aSpecPTD[playerid][2], 0);

	//Kill system

	killedby[playerid] = CreatePlayerTextDraw(playerid,251.127502, 309.749847, "_");
	PlayerTextDrawLetterSize(playerid,killedby[playerid], 0.431259, 1.780833);
	PlayerTextDrawAlignment(playerid,killedby[playerid], 1);
	PlayerTextDrawColor(playerid,killedby[playerid], 8388863);
	PlayerTextDrawSetShadow(playerid,killedby[playerid], 0);
	PlayerTextDrawSetOutline(playerid,killedby[playerid], 0);
	PlayerTextDrawBackgroundColor(playerid,killedby[playerid], -2147450625);
	PlayerTextDrawFont(playerid,killedby[playerid], 1);

	deathbox[playerid] = CreatePlayerTextDraw(playerid,641.531494, 300.166687, "usebox");
	PlayerTextDrawLetterSize(playerid,deathbox[playerid], 0.000000, 4.609256);
	PlayerTextDrawTextSize(playerid,deathbox[playerid], -2.000000, 0.000000);
	PlayerTextDrawAlignment(playerid,deathbox[playerid], 1);
	PlayerTextDrawColor(playerid,deathbox[playerid], 0);
	PlayerTextDrawUseBox(playerid,deathbox[playerid], true);
	PlayerTextDrawBoxColor(playerid,deathbox[playerid], 102);
	PlayerTextDrawSetShadow(playerid,deathbox[playerid], 0);
	PlayerTextDrawSetOutline(playerid,deathbox[playerid], 0);
	PlayerTextDrawFont(playerid,deathbox[playerid], 0);

	killedtext[playerid] = CreatePlayerTextDraw(playerid,283.455261, 106.749977, "_");
	PlayerTextDrawLetterSize(playerid,killedtext[playerid], 0.449999, 1.600000);
	PlayerTextDrawAlignment(playerid,killedtext[playerid], 1);
	PlayerTextDrawColor(playerid,killedtext[playerid], -5963521);
	PlayerTextDrawSetShadow(playerid,killedtext[playerid], 0);
	PlayerTextDrawSetOutline(playerid,killedtext[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid,killedtext[playerid], 51);
	PlayerTextDrawFont(playerid,killedtext[playerid], 1);
	PlayerTextDrawSetProportional(playerid,killedtext[playerid], 1);

	killedbox[playerid] = CreatePlayerTextDraw(playerid,641.531494, 94.250000, "usebox");
	PlayerTextDrawLetterSize(playerid,killedbox[playerid], 0.000000, 4.349999);
	PlayerTextDrawTextSize(playerid,killedbox[playerid], -2.000000, 0.000000);
	PlayerTextDrawAlignment(playerid,killedbox[playerid], 1);
	PlayerTextDrawColor(playerid,killedbox[playerid], 0);
	PlayerTextDrawUseBox(playerid,killedbox[playerid], true);
	PlayerTextDrawBoxColor(playerid,killedbox[playerid], 102);
	PlayerTextDrawSetShadow(playerid,killedbox[playerid], 0);
	PlayerTextDrawSetOutline(playerid,killedbox[playerid], 0);
	PlayerTextDrawFont(playerid,killedbox[playerid], 0);

	//Notifier

	Notifier_PTD[playerid] = CreatePlayerTextDraw(playerid, 174.000000, 436.000000, "Feel bored ? Type /q and take some rest.");
	PlayerTextDrawFont(playerid, Notifier_PTD[playerid], 1);
	PlayerTextDrawLetterSize(playerid, Notifier_PTD[playerid], 0.150000, 0.649999);
	PlayerTextDrawTextSize(playerid, Notifier_PTD[playerid], 440.000000, 197.000000);
	PlayerTextDrawSetOutline(playerid, Notifier_PTD[playerid], 1);
	PlayerTextDrawSetShadow(playerid, Notifier_PTD[playerid], 0);
	PlayerTextDrawAlignment(playerid, Notifier_PTD[playerid], 2);
	PlayerTextDrawColor(playerid, Notifier_PTD[playerid], -1);
	PlayerTextDrawBackgroundColor(playerid, Notifier_PTD[playerid], 255);
	PlayerTextDrawBoxColor(playerid, Notifier_PTD[playerid], 255);
	PlayerTextDrawUseBox(playerid, Notifier_PTD[playerid], 0);
	PlayerTextDrawSetProportional(playerid, Notifier_PTD[playerid], 1);
	PlayerTextDrawSetSelectable(playerid, Notifier_PTD[playerid], 0);

	//Capture system

	ProgressTD[playerid] = CreatePlayerTextDraw(playerid, 89.000000, 310.000000, "_");
	PlayerTextDrawAlignment(playerid,ProgressTD[playerid], 2);
	PlayerTextDrawBackgroundColor(playerid,ProgressTD[playerid], 255);
	PlayerTextDrawFont(playerid,ProgressTD[playerid], 1);
	PlayerTextDrawLetterSize(playerid,ProgressTD[playerid], 0.240000, 1.000000);
	PlayerTextDrawColor(playerid,ProgressTD[playerid], -1);
	PlayerTextDrawSetOutline(playerid,ProgressTD[playerid], 1);
	PlayerTextDrawSetProportional(playerid,ProgressTD[playerid], 1);
	PlayerTextDrawSetSelectable(playerid,ProgressTD[playerid], 0);

	//Stats

	Stats_UIPTD[playerid] = CreatePlayerTextDraw(playerid, 488.000000, 435.000000, "_");
	PlayerTextDrawFont(playerid, Stats_UIPTD[playerid], 2);
	PlayerTextDrawLetterSize(playerid, Stats_UIPTD[playerid], 0.124999, 0.750000);
	PlayerTextDrawTextSize(playerid, Stats_UIPTD[playerid], 12.000000, 640.000000);
	PlayerTextDrawSetOutline(playerid, Stats_UIPTD[playerid], 0);
	PlayerTextDrawSetShadow(playerid, Stats_UIPTD[playerid], 0);
	PlayerTextDrawAlignment(playerid, Stats_UIPTD[playerid], 2);
	PlayerTextDrawColor(playerid, Stats_UIPTD[playerid], -1);
	PlayerTextDrawBackgroundColor(playerid, Stats_UIPTD[playerid], 255);
	PlayerTextDrawBoxColor(playerid, Stats_UIPTD[playerid], 101);
	PlayerTextDrawUseBox(playerid, Stats_UIPTD[playerid], 0);
	PlayerTextDrawSetProportional(playerid, Stats_UIPTD[playerid], 1);
	PlayerTextDrawSetSelectable(playerid, Stats_UIPTD[playerid], 0);
	return 1;
}

RemovePlayerUI(playerid) {
	for (new i = 0; i < sizeof(Stats_TD); i++) {
		TextDrawHideForPlayer(playerid, Stats_TD[i]);
	}
	
	for (new i; i < menuPlayerTextDrawCount[playerid]; i++) {
		PlayerTextDrawDestroy(playerid, menuPlayerTextDraw[playerid][i]);
	}

	PlayerTextDrawDestroy(playerid, FlashTD[playerid]);
	PlayerTextDrawDestroy(playerid, PUBGBonusTD[playerid]);

	TextDrawHideForPlayer(playerid, DMBox);
	TextDrawHideForPlayer(playerid, DMText);
	TextDrawHideForPlayer(playerid, DMText2[0]);
	TextDrawHideForPlayer(playerid, DMText2[1]);
	TextDrawHideForPlayer(playerid, DMText2[2]);
	TextDrawHideForPlayer(playerid, DMText2[3]);    

	TextDrawHideForPlayer(playerid, War_TD);

	PlayerTextDrawDestroy(playerid, Stats_PTD[playerid][0]);
	PlayerTextDrawDestroy(playerid, Stats_PTD[playerid][1]);
	PlayerTextDrawDestroy(playerid, Stats_PTD[playerid][2]);

	PlayerTextDrawDestroy(playerid, aSpecPTD[playerid][0]);
	PlayerTextDrawDestroy(playerid, aSpecPTD[playerid][1]);
	PlayerTextDrawDestroy(playerid, aSpecPTD[playerid][2]);

	HidePlayerHUD(playerid);
	PlayerTextDrawDestroy(playerid, Notifier_PTD[playerid]);

	PlayerTextDrawDestroy(playerid, CarInfoPTD[playerid][0]);
	PlayerTextDrawDestroy(playerid, CarInfoPTD[playerid][1]);
	PlayerTextDrawDestroy(playerid, CarInfoPTD[playerid][2]);    
	
	PlayerTextDrawDestroy(playerid, killedby[playerid]);
	PlayerTextDrawDestroy(playerid, deathbox[playerid]);
	PlayerTextDrawDestroy(playerid, killedtext[playerid]);
	PlayerTextDrawDestroy(playerid, killedbox[playerid]);

	PlayerTextDrawDestroy(playerid, Stats_UIPTD[playerid]);
	PlayerTextDrawDestroy(playerid, ProgressTD[playerid]);

	//Progress bars
	DestroyPlayerProgressBar(playerid, Player_ProgressBar[playerid]); // Capture System
	return 1;
}

ShowPlayerHUD(playerid) {
	TextDrawShowForPlayer(playerid, txtTimeDisp);
	PlayerTextDrawShow(playerid, Stats_UIPTD[playerid]);
	for (new i = 0; i < sizeof(Box_TD); i++) {
		TextDrawShowForPlayer(playerid, Box_TD[i]);
	}
	return 1;
}

HidePlayerHUD(playerid) {
	TextDrawHideForPlayer(playerid, txtTimeDisp);
	PlayerTextDrawHide(playerid, Stats_UIPTD[playerid]);
	for (new i = 0; i < sizeof(Box_TD); i++) {
		TextDrawHideForPlayer(playerid, Box_TD[i]);
	}
	return 1;
}

//Update player information on the UI

UpdatePlayerHUD(playerid) {
	new format_rank[128];

	new Float:KDR = floatdiv(PlayerInfo[playerid][pKills], PlayerInfo[playerid][pDeaths]);
	if (PlayerRank[playerid] < sizeof(RankInfo) - 1) {
		format(format_rank, sizeof(format_rank), "%sScore: ~g~%d~w~/~r~%d",
			TeamInfo[pTeam[playerid]][Chat_Bub], GetPlayerScore(playerid), RankInfo[PlayerRank[playerid] + 1][Rank_Score]);
	} else {
		format(format_rank, sizeof(format_rank), "%sScore: ~g~%s", TeamInfo[pTeam[playerid]][Chat_Bub], RankInfo[PlayerRank[playerid]][Rank_Name]);
	}
	format(format_rank, sizeof(format_rank), "%s %sKills: ~w~%d %sDeaths: ~w~%d %sKDR: ~w~%0.1f %sXP: ~w~%d", format_rank, TeamInfo[pTeam[playerid]][Chat_Bub], PlayerInfo[playerid][pKills],
		TeamInfo[pTeam[playerid]][Chat_Bub], PlayerInfo[playerid][pDeaths], TeamInfo[pTeam[playerid]][Chat_Bub], KDR,
		TeamInfo[pTeam[playerid]][Chat_Bub], PlayerInfo[playerid][pEXPEarned]);
	PlayerTextDrawSetString(playerid, Stats_UIPTD[playerid], format_rank);
	if (!PlayerInfo[playerid][pSelecting] && PlayerInfo[playerid][pLoggedIn] && !IsPlayerDying(playerid)
		&& IsPlayerSpawned(playerid))
	{
		if (GetPlayerConfigValue(playerid, "HUD") == 1) {
			if (WarInfo[War_Started]) {
				TextDrawShowForPlayer(playerid, War_TD);
				TextDrawShowForPlayer(playerid, War_TDBox);
			}
			ShowPlayerHUD(playerid);
		} else {
			if (WarInfo[War_Started]) {
				TextDrawHideForPlayer(playerid, War_TD);
				TextDrawHideForPlayer(playerid, War_TDBox);
			}
			HidePlayerHUD(playerid);
		}
	} else {
		if (WarInfo[War_Started]) {
			TextDrawHideForPlayer(playerid, War_TD);
			TextDrawHideForPlayer(playerid, War_TDBox);
		}
		HidePlayerHUD(playerid);
		SetHealthBarVisible(playerid, false);
	}
	UpdateLabelText(playerid);
	return 1;
}

//Update label text above head

UpdateLabelText(playerid) {
	if (!IsPlayerDying(playerid)) {
		new String[50];

		Update3DTextLabelText(RankLabel[playerid], 0xFFFFFF80, " ");
		PlayerRank[playerid] = GetPlayerRank(playerid);

		format(String, sizeof(String), "");

		if (!PlayerInfo[playerid][pIsAFK]) {
			if (PlayerInfo[playerid][pAdminDuty])
			{
				Update3DTextLabelText(RankLabel[playerid], X11_DEEPPINK, "*ON DUTY*");
				return 1;
			}
			if (!PlayerInfo[playerid][pIsSpying]) {
				if (pTeam[playerid] == TERRORIST) {
					format(String, sizeof(String), "Terrorist\n%s", GetPlayerClass(playerid));
				} else if (pTeam[playerid] == SWAT) {
					format(String, sizeof(String), "SWAT Soldier\n%s", GetPlayerClass(playerid));
				} else {
					format(String, sizeof(String), "VIP");
				}
			} else {
				format(String, sizeof(String), "%s\nAssault", TeamInfo[PlayerInfo[playerid][pSpyTeam]][Team_Name]);
			}

			if (PlayerInfo[playerid][pDeathmatchId] == -1) {
				if (!pDuelInfo[playerid][pDInMatch])  {
					if (!PlayerInfo[playerid][pIsSpying]) {
						Update3DTextLabelText(RankLabel[playerid], TeamInfo[pTeam[playerid]][Team_Color], String);
					} else {
						Update3DTextLabelText(RankLabel[playerid], TeamInfo[PlayerInfo[playerid][pSpyTeam]][Team_Color], String);
					}
				}
				else {
					Update3DTextLabelText(RankLabel[playerid], 0xFFFFFFCC, "Dueler");			    	
				}   
			}    
			else {
				Update3DTextLabelText(RankLabel[playerid], 0xFFFFFFCC, "Deathmatcher");
			}  		    
		}
	}
	else
	{
		Update3DTextLabelText(RankLabel[playerid], 0xC4C4C4CC, "..DEAD..");
	}
	if (pFlashLvl[playerid]) Update3DTextLabelText(RankLabel[playerid], COLOR_TOMATO, "..FLASH BANGED..");
	
	if (!gInvisible[playerid] && !gCamoActivated[playerid]) {
		SetPlayerMarkerVisibility(playerid, 0xFF);
	} else {
		SetPlayerMarkerVisibility(playerid, 0x00);
	}    
	return 1;
}

//End of File
/* (c) H2O Multiplayer 2018-2020. All rights reserved. */