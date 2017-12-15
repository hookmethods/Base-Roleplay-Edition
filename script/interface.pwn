//camera effect credits goes to Mmartin? or LS-RP dev.
new cameraSession[MAX_PLAYERS];

forward SetPlayerCameraEffect(playerid, amount_of_shakes);
public SetPlayerCameraEffect(playerid, amount_of_shakes)
{
	if(amount_of_shakes < cameraSession[playerid])
		return 0;

	cameraSession[playerid] = amount_of_shakes;
	return shakeEffects(playerid, 10, false);
}
forward shakeEffects(playerid, interval, bool:status);
public shakeEffects(playerid, interval, bool:status)
{
	if(cameraSession[playerid] <= 0)
		return SetPlayerDrunkLevel(playerid, 0);

	cameraSession[playerid] -- ;
	if(status)
	{
		SetPlayerDrunkLevel(playerid, 3000);
	} else { SetPlayerDrunkLevel(playerid, 50000); }

	return SetTimerEx( "shakeEffects", interval, false, "iii", playerid, interval, !status);
}

MulStringHandler(string[]) // text cut off for drugs effect
{
    new mulstr[256];
	strcat(mulstr, string);
	for(new charSet = 0; charSet < strlen(longText); charSet += random(5) + 2) {
	   if(mulstr[charSet] != ' ') {
	      strins(mulstr, ".. ", charSet);
	   }
	}
	return mulstr;
}

bool:chanceHandler(var)
{
	if(var <= 0) return false;
	if(var >= 100) return true;
	new try = random(100), drop = (0);
	for(new i = 0;i <= var-1;i++){
		if(try == i){
			drop = (1);
			break;
		}
	}
	if(drop == 1) return true;
	return false;
}

Float:GetDistanceBetweenPoints(Float:x,Float:y,Float:tx,Float:ty)
{
  new Float:temp1, Float:temp2;
  temp1 = x-tx;temp2 = y-ty;
  return floatsqroot(temp1*temp1+temp2*temp2);
}
