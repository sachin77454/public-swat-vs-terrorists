/*
Local machine/Production:
*/

#include <YSI_Coding\y_hooks>

/*define MYSQL_HOST 			"localhost"
#define MYSQL_USER 			"root"
#define MYSQL_PASSWORD 		""
#define MYSQL_DATABASE		"newsvt"*/

hook OnGameModeInit() {
	new MySQLOpt: option_id = mysql_init_options();
	mysql_set_option(option_id, AUTO_RECONNECT, true);
	Database = mysql_connect(MYSQL_HOST, MYSQL_USER, MYSQL_PASSWORD, MYSQL_DATABASE, option_id);
	if (Database == MYSQL_INVALID_HANDLE || mysql_errno(Database) != 0) {
		print("Invalid MySQL server... Restarting.");
		SendRconCommand("gmx");
	}
}

hook OnGameModeExit() {
	//Stop the mysql connection
	mysql_close(Database);
}

//End of File
/* (c) H2O Multiplayer 2018-2020. All rights reserved. */