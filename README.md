# public-swat-vs-terrorists
The public SWAT vs Terrorists repository!

# History
This gamescript was developed from early 2016 till this day, many features were added and many were removed, till it reached a good taste that people liked, and that made it the SWAT vs Terrorists it is today.

A team-deathmatch gamescript with a lot of interesting features coded in a beautiful way and tested for too long, till it reached a stable state that people enjoyed playing.

# Dependencies
This game script depends on the following packages in order to work:

* SA-MP default includes!
* YSI 4.x [https://github.com/pawn-lang/YSI-Includes]
* SA-MP MySQL Plugin R41-2 [https://github.com/pBlueG/SA-MP-MySQL/releases]
* BustAim [https://github.com/YashasSamaga/BA-AntiAimbot]
* weapon-config [depends on SKY plugin] [https://forum.sa-mp.com/showthread.php?t=563387]
* SKY Plugin [https://github.com/oscar-broman/SKY]
* SA-MP Streamer Plugin [https://github.com/samp-incognito/samp-streamer-plugin/releases]
* sscanf2 Plugin [https://github.com/maddinat0r/sscanf/releases]
* Pawn.Regex Plugin [https://github.com/urShadow/Pawn.Regex]
* Pawn.CMD Plugin [https://github.com/urShadow/Pawn.CMD/releases]
* Pawn.RakNet Plugin [https://github.com/urShadow/Pawn.RakNet]
* ColAndreas Plugin [https://github.com/Pottus/ColAndreas]
* gz_shapes [https://forum.sa-mp.com/showthread.php?t=644449]
* 3DTryg (by AbyssMorgan, added within the game script)
* HN (by jlalt, highlight nicknames, added within the game script)
* timestamp (by Crayder, added within the game script)
* Discord Connector Plugin [https://github.com/maddinat0r/samp-discord-connector]
* mSelection [https://forum.sa-mp.com/showthread.php?t=407045]
* rAsc and OPBA anti-cheat patches by RogueDrifter [built in]
* antilag and antispoof anti-cheat patches by Pottus and Southclaws [built in]
* anti-weapon and anti-fly anti-cheat patches by Lorenc_ [built in]
* Custom version of Discord Command Processor written by H2O (me) [built in]

Some dependencies are included within the repository - some are not (i.e. SA-MP includes and YSI 4.x, you have to download those)

# Compiling

I remember using the community compiler (I think it's available on GitHub, search for it). Some dependencies mentioned above might require other stuff in order to work, I'm sure you will figure that out as you compile the script.

# Important Notes
* You may not use the same name styling as we do for the hostname, or attempt to copy our server
* You may not use this source code to exploit our server
* You may not link your server with h2omultiplayer.com
* You have to keep all the credits, but you can add your name to the credits!
* I'm providing this script as-is and can tell that it is licensed under GNU GPL v3 at the moment

# Credits
* Me for coding this script from scratch
* Y_Less for YSI which has the most useful includes I used actually
* Include developers mentioned above in #Dependencies
* Some mapping and code snippets were taken from the MW3 game script
* Anyone whose work is used in this script is credited, thank you!
* You for editing this script, but be nice and keep a credit for people you use their work :)

# Pre-Installation Requirements

* A functional MySQL server with a user that actually has access to a database
* A discord bot token for the bot to work, more information can be found on the official plugin's GitHub Repository https://github.com/maddinat0r/samp-discord-connector

* SA-MP 0.3.7 (or later) Server Executable Files [https://www.sa-mp.com/download.php]
* A little knowledge in how to get things working
* A mail php script to handle HTTP requests in "players/auth/email.pwn" I commented it, but it's actually needed!

# Installation:

* Import database .SQL files in "gamemodes/database" to your MySQL database
* Edit "gamemodes/server/database.pwn" with your MySQL connection details
* Edit "gamemodes/server/header.pwn" with your discord information (above dcc include)
* Modify server information under OnGameModeInit [in gamemodes/server/init.pwn] and in the header files [in gamemodes/server/header.pwn] (i.e. for bot config, hostname and so on)
* Recompile the gamemode script
* Modify server.cfg with your discord bot token
* Move the .exe files from the SA-MP Server package you downloaded to the server's directory
* Launch samp-server.exe!

# Fun Facts
* This script included an achievements system that was nice but wasn't really important so I decided to remove it, but it will be nice if you make one
* Most server messages (excluding admin messages that are sent to admins) are available in language files that are located in scriptfiles/YSI so you can have more than one language
* Important declarations and are available in the header files, including team names and so on
* Implementations are available in various models

# Final words...

I, H2O and known as Variable am proud to present this script to you all. It's been a pleasure working on this script, I learnt much as I developed it, and today I'm happy to share my knowledge with you. I know you may not use this script to create a server but you probably want to learn how other big servers like this one has been, was developed. I want you to use it wisely, learn how stuff were implemented and do better. I don't promise updating this script anymore, but I have seriously been working on this script from early 2016 and till this day, adding features and removing useless ones, following standard coding styles and modern techniques to provide this script finally in 2020. This script ran with over 90 players smoothly, never lagged or encountered troubles handling large player numbers for days, weeks and months. But today, the server isn't even as active as it used to be, and I would like people to learn how it was developed, and to make better than it. Thanks SA-MP for letting me get into programming and making me interesting in learning other programming languages to make my own server. I spent a long time in SA-MP, and it's time to pay-back this community for how helpful it was to me during my time on it.

Thank you SA-MP, Y_Less, anyone who helped make this script or test it, and everyone who spent time in the community. Thanks for the donors and sponsors who kept the community running smoothly for all those years.

Thanks to anyone whose discussions helped me learn more stuff, and especially the management team.

Thank you all.
Peace and love, love and peace.
H2O MULTIPLAYER!
https://h2omultiplayer.com/
