/*format(gExecute, sizeof(gExecute), "SELECT * FROM rp_chemical WHERE Owner = %i LIMIT %i", Players[playerid][pID], MAX_CHEMICAL);
mysql_tquery(gConnection, gExecute, "Chemical_Load", "i", playerid);

under OnPlayerAttemptLogin
*/
forward Chemical_Load(playerid);
public Chemical_Load(playerid)
{
    new
	    rows = cache_get_row_count(gConnection);

    for(new slot = 0,j = MAX_CHEMICAL; slot < j; slot ++)
    {
        P_CHEMICAL[playerid][slot][insertID] = 0;
        P_CHEMICAL[playerid][slot][Amount] = 0;
        P_CHEMICAL[playerid][slot][ChemicalID] = 0;
        P_CHEMICAL[playerid][slot][Owner] = 0;
    }
    
	for (new i = 0; i < rows; i ++)
	{
	    P_CHEMICAL[playerid][i][insertID] = cache_get_field_content_int(i, "ID");
	    P_CHEMICAL[playerid][i][Amount] = cache_get_field_content_float(i, "Amount");
	    P_CHEMICAL[playerid][i][ChemicalID] = cache_get_field_content_int(i, "Chemical");
	    P_CHEMICAL[playerid][i][Owner] = cache_get_field_content_int(i, "Owner");
	}
	printf("(SQL) %i chemical loaded for %s.", rows, ReturnName(playerid));
}

RemoveChemical(playerid, slot)
{
    P_CHEMICAL[playerid][slot][insertID] = 0;
    P_CHEMICAL[playerid][slot][Amount] = 0;
    P_CHEMICAL[playerid][slot][ChemicalID] = 0;
    P_CHEMICAL[playerid][slot][Owner] = 0;
	format(gExecute, sizeof(gExecute), "DELETE FROM `rp_chemical` WHERE `ID` = %i AND `Owner` = %i", P_CHEMICAL[playerid][slot][insertID], Players[playerid][pID]);
	mysql_tquery(gConnection, gExecute);
}

SaveChemical(playerid, slot)
{
	static
	    queryString[1024];

	if (!P_CHEMICAL[playerid][slot][Amount]) return 0;
    if (P_CHEMICAL[playerid][slot][Owner] != Players[playerid][pID]) return 0;
    
	format(queryString, sizeof(queryString), "UPDATE rp_chemical SET `ID` = %i, `Amount` = '%.1f', `ChemicalID` = %d, Owner = '%d'",
    P_CHEMICAL[playerid][slot][insertID],
    P_CHEMICAL[playerid][slot][Amount],
    P_CHEMICAL[playerid][slot][ChemicalID],
    P_CHEMICAL[playerid][slot][Owner]
	);
	return mysql_tquery(gConnection, queryString);
}

stock GetFreeChemicalSlot(playerid)
{
	for(new i = 0; i < MAX_CHEMICAL; i++)
	{
		if(P_CHEMICAL[playerid][i][ChemicalID] > 0)
			return i;
	}
	return 0;
}
AddChemical(playerid, chemical, Float:amount)
{
    for(new i = 0,j = MAX_CHEMICAL; i < j; i ++)
    {
        if(P_CHEMICAL[playerid][i][ChemicalID] > 0) continue;
        else
        {
			format(queryString, sizeof(queryString), "INSERT INTO `rp_chemical`(`Owner`, `Item`, `Amount`) VALUES (%d, %d, '%.1f')", Players[playerid][pID], chemical, amount);
			mysql_tquery(gConnection, queryString);
	        P_CHEMICAL[playerid][i][insertID] = cache_insert_id(gConnection);
	        P_CHEMICAL[playerid][i][ChemicalID] = chemical;
	        P_CHEMICAL[playerid][i][Amount] = amount;
            P_CHEMICAL[playerid][i][Owner] = Players[playerid][pID];
	        break;
        }
    }
	return 1;
}

stock FormatChemical(playerid, slot)
{
	new tag[32];
	if(P_CHEMICAL[playerid][slot][Amount] == 0 && (P_CHEMICAL[playerid][slot][Owner] = Players[playerid][pID])) tag = "Empty";
	else format(tag, sizeof(tag), "%s(%.1fg)", P_CHEMICAL[playerid][slot][Name], P_CHEMICAL[playerid][slot][Amount]);
	return tag;
}

stock ListChemical(playerid, extra = INVALID_PLAYER_ID)
{
	SendClientMessage(toplayer, 0x33AA33FF, "|______________ %s's chemicals ______________|", ReturnNameEx(playerid, 0));
	for(new i = 0; i < MAX_CHEMICAL; i+=5)
	{
		SendClientMessage(toplayer, COLOR_WHITE, "[ %d. %s ][ %d. %s ][ %d. %s ][ %d. %s ][ %d. %s ]", i, FormatChemical(playerid, i), i+1, FormatChemical(playerid, i+1), i+2, FormatChemical(playerid, i+2), i+3, FormatChemical(playerid, i+3), i+4, FormatChemical(playerid, i+4));
	}
}

