/*format(gExecute, sizeof(gExecute), "SELECT * FROM rp_drugs WHERE Owner = %i LIMIT %i", Players[playerid][pID], MAX_DRUGS);
mysql_tquery(gConnection, gExecute, "Drugs_Load", "i", playerid);

under OnPlayerAttemptLogin
*/
forward Drugs_Load(playerid);
public Drugs_Load(playerid)
{
    new
	    rows = cache_get_row_count(gConnection);

    for(new slot = 0,j = MAX_DRUGS; slot < j; slot ++)
    {
        P_DRUGS[playerid][slot][drugID] = 0;
        P_DRUGS[playerid][slot][Owner] = 0;
        P_DRUGS[playerid][slot][Amount] = 0;
        P_DRUGS[playerid][slot][Quality] = 0;
        P_DRUGS[playerid][slot][EffectTime] = 0;
        P_DRUGS[playerid][slot][Addiction] = 0;
        P_DRUGS[playerid][slot][Type] = 0;
    }
    
	for (new i = 0; i < rows; i ++)
	{
	    P_DRUGS[playerid][i][drugID] = cache_get_field_content_int(i, "ID");
	    P_DRUGS[playerid][i][Amount] = cache_get_field_content_float(i, "Amount");
	    P_DRUGS[playerid][i][Quality] = cache_get_field_content_float(i, "Quality");
	    P_DRUGS[playerid][i][Owner] = cache_get_field_content_int(i, "Owner");
	    P_DRUGS[playerid][i][Type] = cache_get_field_content_int(i, "Type");
	    P_DRUGS[playerid][i][EffectTime] = cache_get_field_content_int(i, "EffectTime");
	    P_DRUGS[playerid][i][Addiction] = cache_get_field_content_int(i, "Addiction");
	    cache_get_field_content(i, "Name", P_DRUGS[playerid][i][Name], gConnection, 129);
	    cache_get_field_content(i, "CAS", P_DRUGS[playerid][i][CAS], gConnection, 29);
	    cache_get_field_content(i, "Creator", P_DRUGS[playerid][i][Creator], gConnection, 128);
	}
	printf("(SQL) %i drugs loaded for %s.", rows, ReturnName(playerid));
}

RemoveDrugs(playerid, slot)
{
    P_DRUGS[playerid][slot][drugID] = 0;
    P_DRUGS[playerid][slot][Owner] = 0;
    P_DRUGS[playerid][slot][Amount] = 0;
    P_DRUGS[playerid][slot][Quality] = 0;
    P_DRUGS[playerid][slot][EffectTime] = 0;
    P_DRUGS[playerid][slot][Addiction] = 0;
    P_DRUGS[playerid][slot][Type] = 0;
	format(gExecute, sizeof(gExecute), "DELETE FROM `rp_drugs` WHERE `ID` = %i AND `Owner` = %i", P_DRUGS[playerid][slot][drugID], Players[playerid][pID]);
	mysql_tquery(gConnection, gExecute);
}

SaveDrugs(playerid, slot)
{
	static
	    queryString[2048];

	if (P_DRUGS[playerid][slot][Amount] <= 0.0) return 0;
    if (P_DRUGS[playerid][slot][Owner] != Players[playerid][pID]) return 0;
    
	format(queryString, sizeof(queryString), "UPDATE rp_drugs SET `ID` = %i, `Amount` = '%.1f', `Quality` = '%.2f', `Owner` = '%d', `EffectTime` = '%d', `Addiction` = '%d', `Type` = '%d', `Name` = '%s', `CAS` = '%s', `Creator` = '%s'",
    P_DRUGS[playerid][slot][drugID],
    P_DRUGS[playerid][slot][Amount],
    P_DRUGS[playerid][slot][Quality],
    P_DRUGS[playerid][slot][Owner],
    P_DRUGS[playerid][slot][EffectTime],
    P_DRUGS[playerid][slot][Addiction],
    P_DRUGS[playerid][slot][Type],
    P_DRUGS[playerid][slot][Name],
    P_DRUGS[playerid][slot][CAS],
    P_DRUGS[playerid][slot][Creator]
	);
	return mysql_tquery(gConnection, queryString);
}

stock GetFreeDrugSlot(playerid)
{
	for(new i = 0; i < MAX_DRUGS; i++)
	{
		if(P_DRUGS[playerid][i][drugID] > 0)
			return i;
	}
	return 0;
}


AddDrugs(playerid, name[], cas[], type, Float:amount, Float: quality, effecttime, addiction)
{
	new queryString[1024];
    for(new i = 0,j = MAX_DRUGS; i < j; i ++)
    {
        if(P_DRUGS[playerid][i][Amount] > 0) continue;
        else
        {
        
			format(queryString, sizeof(queryString), "INSERT INTO `playerdrugs`(`Name`, `Owner`, `CAS`, `Type`, `Amount`, `Quality`, `EffectTime`, `Addiction`, `Creator`) VALUES ('%s', %d, '%s', %d, '%.1f', '%.2f', %d, %d, '%s')", name, Players[playerid][pID], cas, type, amount, quality, effecttime, addiction, ReturnNameEx(playerid));
			mysql_tquery(gConnection, queryString);
			
	        P_DRUGS[playerid][i][drugID] = cache_insert_id(gConnection);
		    format(P_DRUGS[playerid][i][Name], 128, name);
		    P_DRUGS[playerid][i][Owner] = Players[playerid][pID];
		    format(P_DRUGS[playerid][i][CAS], 29, cas);
		    P_DRUGS[playerid][i][Type] = type;
		    P_DRUGS[playerid][i][Amount] = amount;
		    P_DRUGS[playerid][i][Quality] = quality;
		    P_DRUGS[playerid][i][EffectTime] = effecttime;
		    P_DRUGS[playerid][i][Addiction] = addiction;
		    format(P_DRUGS[playerid][i][Creator], 128, ReturnNameEx(playerid));
	        break;
        }
    }
	return 1;
}

stock FormatDrugs(playerid, slot)
{
	new tag[64];
	if(P_DRUGS[playerid][slot][Amount] == 0 && (P_DRUGS[playerid][slot][Owner] = Players[playerid][pID])) tag = "Empty";
	else format(tag, sizeof(tag), "%s(%.1fmg)", P_DRUGS[playerid][slot][Name], P_DRUGS[playerid][slot][Amount]);
	return tag;
}

stock ListDrugs(playerid, toplayer)
{
	SendClientMessage(toplayer, 0x33AA33FF, "|______________ %s's drugs ______________|", ReturnNameEx(playerid));
	for(new i = 0; i < MAX_DRUGS; i+=5)
	{
		SendClientMessage(toplayer, COLOR_WHITE, "[ %d. %s ][ %d. %s ][ %d. %s ][ %d. %s ][ %d. %s ]", i, FormatChemical(playerid, i), i+1, FormatChemical(playerid, i+1), i+2, FormatChemical(playerid, i+2), i+3, FormatChemical(playerid, i+3), i+4, FormatChemical(playerid, i+4));
	}
}

