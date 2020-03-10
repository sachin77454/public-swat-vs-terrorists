#if defined _HN_Included_
	#endinput
#endif

#include <a_samp>
#define _HN_Included_

stock GetPlayerCalledName(playerid, const text[], newtext[], len = sizeof newtext, defaultcolor[] = "", bool:nowhite = true)
{
	new where = -1, tlen = strlen(text), howmuchpass = 0, defcolorlen = strlen(defaultcolor), oldcounts = 0, bool:diditbefore = false;
	format(newtext, len, text);
	while((where = strfind(text, "@", true, where + 1)) != -1)
	{
	    if(tlen > where)
	    {
	        new playernamez[MAX_PLAYER_NAME];
	        where++;
	        for(new i = where; i < tlen; i++)
	        {
	            if(text[i] == ' ' || text[i] == ',' || text[i] == EOS || (i - where) >= MAX_PLAYER_NAME)
	            {
	                break;
	            }
	            else
	            {
	                playernamez[i - where] = text[i];
	            }
	        }
	        new pnamelen = strlen(playernamez);
	        if(pnamelen > 2)
	        {
	            new player1 = playerid;
		        new color = GetPlayerHextColorByName(playernamez, player1);
		        if(player1 != playerid && color != -255)
		        {
		            where--;
              		new colorstr[15];
		            if(!nowhite || color != 0xFFFFFF)
		            	format(colorstr, sizeof colorstr, "{%06x}", color);
					else
					    format(colorstr, sizeof colorstr, "{FF0000}");
		            strins(newtext, colorstr, where + howmuchpass, len);

		            new whereizit = (where + howmuchpass) + strlen(colorstr) + strlen(playernamez) + 1;
		            if(whereizit < len)
		            {
		                if(NextCharIsNotColored(text, (where + 1) + pnamelen) == 0)
						{
                            if(!defcolorlen)
			                {
			                	strins(newtext, "{FFFFFF}", (where + howmuchpass) + strlen(colorstr) + strlen(playernamez) + 1, len);
			                }
			                else
			                {
			                    new colorstr2[15];
			                    format(colorstr2, sizeof colorstr2, "{%s}", defaultcolor);
			                	strins(newtext, colorstr2, (where + howmuchpass) + strlen(colorstr) + strlen(playernamez) + 1, len);
			                }
			            	howmuchpass += strlen(colorstr) + 8;
						}
						else
						{
						    oldcounts = (where + howmuchpass) + strlen(colorstr) + strlen(playernamez) + 1;
						    diditbefore = true;
						    howmuchpass += strlen(colorstr);
						}
					}
					else
					{
					    break;
					}
		        }
		        else
		        {
			        if(diditbefore)
		            {
		                if(!defcolorlen)
		                {
		                	strins(newtext, "{FFFFFF}", oldcounts, len);
		                }
		                else
		                {
		                    new colorstr2[15];
		                    format(colorstr2, sizeof colorstr2, "{%s}", defaultcolor);
		                	strins(newtext, colorstr2, oldcounts, len);
		                }
		                howmuchpass += 8;
		                diditbefore = false;
		            }
		        }
	        }
	        else
	        {
	            if(diditbefore)
	            {
	                if(!defcolorlen)
	                {
	                	strins(newtext, "{FFFFFF}", oldcounts, len);
	                }
	                else
	                {
	                    new colorstr2[15];
	                    format(colorstr2, sizeof colorstr2, "{%s}", defaultcolor);
	                	strins(newtext, colorstr2, oldcounts, len);
	                }
	                howmuchpass += 8;
	                diditbefore = false;
	            }
	        }
	        where += strlen(playernamez);
	    }
	}
}

stock GetPlayerHextColorByName(const playernamew[], &playeridz)
{
	new playernamez[MAX_PLAYER_NAME], playerid = -1;
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
	    if(IsPlayerConnected(i))
	    {
	        GetPlayerName(i, playernamez, sizeof playernamez);
	        if(strfind(playernamez, playernamew, true) != -1)
	        {
	            if(playeridz != i)
	            	PlayerPlaySound(i, 1085, 0.0, 0.0, 0.0);
	            if(playerid == -1)
	            	playerid = i;
	        }
	    }
	}
	playeridz = playerid;
	if(playerid != -1)
    	return GetPlayerColor(playerid) >>> 8;
	else
	    return -255;
}

stock NextCharIsNotColored(const str[], startplace)
{
	new len = strlen(str);
	if(len < startplace)
	{
	    return 0;
	}
	else
	{
	    for(new i = startplace; i < len; i++)
	    {
	        if(str[i] == '@')
	        {
	            return 1;
	        }
	        else if(str[i] != ' ')
	        {
	            return 0;
	        }
	    }
	}
	return 0;
}