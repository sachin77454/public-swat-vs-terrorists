#include <sscanf2>
#include <YSI_Coding\y_va>
#include <discord-connector>

new DCC_Channel:BotChannel;

#define DC_CMD:%0(%1,%2,%3)          \
			forward dc_cmd_%0(%1[],%2[],%3[]); \
			public dc_cmd_%0(%1[],%2[],%3[])

//Functions
static strreplace(string[], const search[], const replacement[], bool:ignorecase = false, pos = 0, limit = -1, maxlength = sizeof(string)) {
	// No need to do anything if the limit is 0.
	if (limit == 0)
		return 0;
	
	new
			 sublen = strlen(search),
			 replen = strlen(replacement),
		bool:packed = ispacked(string),
			 maxlen = maxlength,
			 len = strlen(string),
			 count = 0
	;
	
	
	// "maxlen" holds the max string length (not to be confused with "maxlength", which holds the max. array size).
	// Since packed strings hold 4 characters per array slot, we multiply "maxlen" by 4.
	if (packed)
		maxlen *= 4;
	
	// If the length of the substring is 0, we have nothing to look for..
	if (!sublen)
		return 0;
	
	// In this line we both assign the return value from "strfind" to "pos" then check if it's -1.
	while (-1 != (pos = strfind(string, search, ignorecase, pos))) {
		// Delete the string we found
		strdel(string, pos, pos + sublen);
		
		len -= sublen;
		
		// If there's anything to put as replacement, insert it. Make sure there's enough room first.
		if (replen && len + replen < maxlen) {
			strins(string, replacement, pos, maxlength);
			
			pos += replen;
			len += replen;
		}
		
		// Is there a limit of number of replacements, if so, did we break it?
		if (limit != -1 && ++count >= limit)
			break;
	}
	return count;
}

stock SendDCByName(channel[], const fmat[], va_args<31>)
{
    new
        str[256];
    va_format(str, sizeof (str), fmat, va_start<2>);
	BotChannel = DCC_FindChannelByName(channel);
    return DCC_SendChannelMessage(BotChannel, str);
}

//Processing

public DCC_OnChannelMessage(DCC_Channel:channel, DCC_User:author, const message[])
{
	new channel_name[100 + 1];
	if(!DCC_GetChannelName(channel, channel_name))
		return 0;

	new user_name[32 + 1];
	if (!DCC_GetUserName(author, user_name))
		return 0;
	
	new messageEx[256];
	format(messageEx, 256, message);
	strreplace(messageEx, "%", " ");
	if(!strcmp(user_name, BOT_NAME, true)) return 1;
	if(strlen(user_name) > 0) {
		new command[10], args[246];
		sscanf(messageEx, "s[10]s[246]", command, args);
		if(strfind(command, CMD_PREFIX, true) != -1) {
			new callfucn[20];
			strdel(command, 0, 1);
			format(callfucn, sizeof(callfucn), "dc_cmd_%s", command);
			if (!isnull(args)) {
				CallLocalFunction(callfucn, "sss", user_name, args, channel_name);		
			} else {
				CallLocalFunction(callfucn, "sis", user_name, "\1", channel_name);		
			}
		}
	}
	return 1;
}