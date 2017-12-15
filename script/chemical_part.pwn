/*
	STILL IN WORKING
	PART: Selected Listitem + 1
*/
new gString[256];
#define Part_Mixing   9990
#define Extra_Mixing  9991
#define Final_Mixing  9992
#define Purification  9993
#define ControlSelect 9994
#define ControlInput  9995

stock GetFurnitureWorkType(furnitureid)
{
	new type = INVALID_ID;
    if (!Furniture[furnitureid][fExists]) return INVALID_ID;
	switch(Furniture[furnitureid][fModel])
	{
	    case 3287: type = 1; // dryer
	    case 19830: type = 2; // centrifuge
	    case 19585: type = 3; // mixer
	    case 2360: type = 4; // reactor
	    case 2002: type = 5; // dehydrater
	    case 1244: type = 6; // Pickup pump
	}
	return type;
}

stock ShowMixingDialog(playerid, part = Part_Mixing)
{
	if(!GetClosestFurniture(playerid, 2.0, 19585)) return SendClientMessage(playerid, COLOR_LIGHTRED, "ERROR: You are not in a range of any mixers.");

	new pickDialog[1024], count = 0, title[64];
	ClearListedItems(playerid);
    format(gString, sizeof(gString), "{33aa33}Slot\t{33aa33}Chemical\t{33aa33}Formula\t{33aa33}Amount\n");
    strcat(pickDialog, gString);
	for(new g = 0; g < MAX_CHEMICAL; g++)
	{
	    if(P_CHEMICAL[playerid][g][ChemicalID] == 0) continue;
	    format(gString, sizeof(gString), "%s%d\t%s%s\t%s%s\t%s%.1f mg\n", P_CHEMICAL[playerid][g][Selected] ? ("{FFFF00}") : ("{FFFFFF}"), g, P_CHEMICAL[playerid][g][Selected] ? ("{FFFF00}") : ("{FFFFFF}"), E_CHEMICAL[P_CHEMICAL[playerid][g][ChemicalID]][NAME], P_CHEMICAL[playerid][g][Selected] ? ("{FFFF00}") : ("{FFFFFF}"), E_CHEMICAL[P_CHEMICAL[playerid][g][ChemicalID]][CODE], P_CHEMICAL[playerid][g][Selected] ? ("{FFFF00}") : ("{FFFFFF}"), P_CHEMICAL[playerid][g][Amount],P_CHEMICAL[playerid][g][Selected] ? ("{FFFF00}") : ("{FFFFFF}"));
	    strcat(pickDialog, gString);
	    gListedItems[playerid][count++] = g;
	}
	if(count <= 0) Dialog_Show(playerid, LackOfMaterial, DIALOG_STYLE_MSGBOX, title, "You don't have any chemicals in hand..", ">>", "");
	else ShowPlayerDialog(playerid, part, DIALOG_STYLE_TABLIST_HEADERS, "Mixer", pickDialog, "Progress", "<<");
	return 1;
}

stock ResetMixingInfo(playerid)
{
	for(new g = 0; g < MAX_CHEMICAL; g++)
	{
	    P_CHEMICAL[playerid][g][Selected] = false;
	}
	DeletePVar(playerid, "chosingItem");
	DeletePVar(playerid, "chemicalItem");
	DeletePVar(playerid, "chemicalItem1");
	return 1;
}
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
		case Part_Mixing:
		{
		    if(!response) return ResetMixingInfo(playerid);

		    SetPVarInt(playerid, "chosingItem", 1);
		    SetPVarInt(playerid, "chemicalItem", listitem);
		    P_CHEMICAL[playerid][listitem][Selected] = true;
		    ShowMixingDialog(playerid, Extra_Mixing);
	    }
	    case Extra_Mixing:
	    {
		    if(!response) return ResetMixingInfo(playerid);

		    SetPVarInt(playerid, "chosingItem", 1);
		    SetPVarInt(playerid, "chemicalItem1", listitem);
		    P_CHEMICAL[playerid][listitem][Selected] = true;
		    ShowMixingDialog(playerid, Final_Mixing);
	    }
	    case Final_Mixing:
	    {
		    if(!response) return ResetMixingInfo(playerid);

			if(P_CHEMICAL[playerid][listitem][ChemicalID] == P_CHEMICAL[playerid][GetPVarInt(playerid, "chemicalItem")][ChemicalID] && P_CHEMICAL[playerid][listitem][ChemicalID] == P_CHEMICAL[playerid][GetPVarInt(playerid, "chemicalItem1")][ChemicalID])
			{
			    ResetMixingInfo(playerid);
			    ShowMixingDialog(playerid, Part_Mixing);
			    return 1;
			}
			new saf = GetClosestFurniture(playerid, 2.0, 19585);
		    Chemistry[saf][Extra][0] = P_CHEMICAL[playerid][GetPVarInt(playerid, "chemicalItem")][ChemicalID];
		    Chemistry[saf][Extra][1] = P_CHEMICAL[playerid][GetPVarInt(playerid, "chemicalItem1")][ChemicalID];
		    Chemistry[saf][Extra][2] = P_CHEMICAL[playerid][listitem][ChemicalID];

			SendFormatMessage(playerid, COLOR_LIGHTRED, "Mixer Helps: %.1f >>> %s, Degree > %.1f", P_CHEMICAL[playerid][GetPVarInt(playerid, "chemicalItem")][Amount] + P_CHEMICAL[playerid][GetPVarInt(playerid, "chemicalItem1")][Amount] + P_CHEMICAL[playerid][listitem][Amount]);
			new cal = floatround((P_CHEMICAL[playerid][GetPVarInt(playerid, "chemicalItem")][Amount] + P_CHEMICAL[playerid][GetPVarInt(playerid, "chemicalItem1")][Amount] + P_CHEMICAL[playerid][listitem][Amount]) * 1.5);
			new found = 1, quality = randomEx(10,40), type = 1, native_int = 1;

			if(GetPVarInt(playerid, "chemicalItem") > GetPVarInt(playerid, "chemicalItem1") && GetPVarInt(playerid, "chemicalItem") > listitem) found = 1;
			else if(GetPVarInt(playerid, "chemicalItem1") > GetPVarInt(playerid, "chemicalItem") && GetPVarInt(playerid, "chemicalItem1") > listitem) found = 2;
			else if(listitem > GetPVarInt(playerid, "chemicalItem") && listitem > GetPVarInt(playerid, "chemicalItem1")) found = 3;

			if(found == 0)
			{
			    native_int = P_CHEMICAL[playerid][GetPVarInt(playerid, "chemicalItem")][ChemicalID];
			    type = E_CHEMICAL[P_CHEMICAL[playerid][GetPVarInt(playerid, "chemicalItem")][ChemicalID]][TYPE];
		        if(chanceHandler(20))
		        {
		            quality = 80;
		        }
			}
			else
			{
				type = found;
			}

			native_int = P_CHEMICAL[playerid][listitem][ChemicalID];
			SendFormatMessage(playerid, COLOR_LIGHTRED, "Technology: %s > %s > %s", E_CHEMICAL[P_CHEMICAL[playerid][GetPVarInt(playerid, "chemicalItem")][ChemicalID]][NAME], E_CHEMICAL[P_CHEMICAL[playerid][GetPVarInt(playerid, "chemicalItem1")][ChemicalID]][NAME], E_CHEMICAL[P_CHEMICAL[playerid][listitem][ChemicalID]][NAME]);
			StartMixingDrug(playerid, saf, cal, cal*randomEx(1,10), float(quality), type, native_int);
			P_CHEMICAL[playerid][GetPVarInt(playerid, "chemicalItem")][ChemicalID] = 0;
			P_CHEMICAL[playerid][GetPVarInt(playerid, "chemicalItem")][Amount] = 0;
			P_CHEMICAL[playerid][GetPVarInt(playerid, "chemicalItem1")][ChemicalID] = 0;
			P_CHEMICAL[playerid][GetPVarInt(playerid, "chemicalItem1")][Amount] = 0;
			P_CHEMICAL[playerid][listitem][ChemicalID] = 0;
			P_CHEMICAL[playerid][listitem][Amount] = 0;
			RemoveChemical(playerid, GetPVarInt(playerid, "chemicalItem"));
			RemoveChemical(playerid,GetPVarInt(playerid, "chemicalItem1"));
			RemoveChemical(playerid, listitem);
			ResetMixingInfo(playerid);
	    }
	    case Purification:
	    {
		    if(!response) return 1;
		    
		    new furn = GetClosestFurniture(playerid, 2.0, 2360);
		    new bb1 = Chemistry[furn][Extra][0];
		    new bb2 = Chemistry[furn][Extra][1];
		    new bb3 = Chemistry[furn][Extra][2];

		    if(bb1 == 4 && bb2 == 6 && bb3 == 7) // formula for meth
		    {
		        AddDrugs(playerid, "Meth", E_CHEMICAL[ Chemistry[ furn ][Material] ][CODE], E_CHEMICAL[ Chemistry[ furn ][Material] ][TYPE], Chemistry[ furn ][Amount], Chemistry[ furn ][Quality], floatround((Chemistry[ furn ][Amount]+Chemistry[ furn ][Quality])*1.35), floatround(Chemistry[ furn ][Quality]+20));
	            ClearFurnitureData(furn);
				return 1;
		    }
		    else if(bb1 == 3 && bb2 == 2 && bb3 == 1) // formula for pcp
		    {
		        AddDrugs(playerid, "PCP", E_CHEMICAL[ Chemistry[ furn ][Material] ][CODE], E_CHEMICAL[ Chemistry[ furn ][Material] ][TYPE], Chemistry[ furn ][Amount], Chemistry[ furn ][Quality], floatround((Chemistry[ furn ][Amount]+Chemistry[ furn ][Quality])*1.35), floatround(Chemistry[ furn ][Quality]+20));
	            ClearFurnitureData(furn);
				return 1;
		    }
		    else if(bb1 == 5 && bb2 == 6 && bb3 == 8) // formula for heroin
		    {
		        AddDrugs(playerid, "Heroin", E_CHEMICAL[ Chemistry[ furn ][Material] ][CODE], E_CHEMICAL[ Chemistry[ furn ][Material] ][TYPE], Chemistry[ furn ][Amount], Chemistry[ furn ][Quality], floatround((Chemistry[ furn ][Amount]+Chemistry[ furn ][Quality])*1.35), floatround(Chemistry[ furn ][Quality]+20));
	            ClearFurnitureData(furn);
				return 1;
		    }
		    else
		    {
		        format(gString, sizeof(gString), "{ffffff}Reactor\n{b5c8b6}Marker Residue: %s", E_CHEMICAL[ Chemistry[ furn ][Material] ][NAME]);
		        UpdateDynamic3DTextLabelText(Chemistry[ furn ][osLabel], 0x008080FF, gString);

		        //ShowPlayerDialog(playerid, DIALOG_DRUGNAME, DIALOG_STYLE_INPUT, "毒品名称", "请输入毒品名称..", ">>", "取消");
				//AddDrugs(playerid, inputtext, E_CHEMICAL[ hInfo[InHouse[playerid]][D_DrugID] ][CODE], E_CHEMICAL[ hInfo[InHouse[playerid]][D_DrugID] ][TYPE], hInfo[InHouse[playerid]][D_Amount], hInfo[InHouse[playerid]][D_Quality], floatround((hInfo[InHouse[playerid]][D_Amount]+hInfo[InHouse[playerid]][D_Quality])*0.5), floatround(hInfo[InHouse[playerid]][D_Quality]-10));
		    }
	    }
	    case ControlSelect:
	    {
	        new param = GetClosestFurniture(playerid, 2.0, 2360);
	        if(response)
	        {
	            Chemistry[param][Control] = 1;
				ShowPlayerDialog(playerid, ControlInput, DIALOG_STYLE_INPUT, "TEMPERATURE", "\tPLEASE TYPE THE TEMPERATURE RATE HERE:", "Adjust", "Cancel");
			}
			else
			{
			    Chemistry[param][Control] = 0;
			    ShowPlayerDialog(playerid, ControlInput, DIALOG_STYLE_INPUT, "TEMPERATURE", "\tPLEASE TYPE THE TEMPERATURE RATE HERE:", "Adjust", "Cancel");
			}
	    }
	    case ControlInput:
	    {
	        new param = GetClosestFurniture(playerid, 2.0, 2360);
	        Chemistry[param][Temperature] = strval(inputtext);
	    }
    }
	return 1;
}

stock StartMixingDrug(playerid, mixerid, mix_time, mix_amount, Float: mix_quality, mix_type, mix_native)
{
    Chemistry[mixerid][Material] = mix_native;
    Chemistry[mixerid][Type] = mix_type;
    Chemistry[mixerid][NeedTime] = mix_time;
    Chemistry[mixerid][Quality] = mix_quality;
	Chemistry[mixerid][Amount] = mix_amount;
    Chemistry[mixerid][IsWorking] = true;
    Chemistry[mixerid][WorkType] = GetFurnitureWorkType(mixerid);

    SendFormatMessage(playerid, COLOR_LIGHTRED, "Ingredient: %s", E_CHEMICAL[mix_native][CODE]);

    DestroyDynamic3DTextLabel(Chemistry[mixerid][osLabel]);
	format(gString, sizeof(gString), "{FFFFFF}Mixer\n{b5c8b6}(%s)\n{39c622}%d mintues left.", E_CHEMICAL[mix_native][CODE], Chemistry[mixerid][NeedTime]);

	Chemistry[mixerid][osLabel] = CreateDynamic3DTextLabel(gString, 0x008080FF, Furniture[mixerid][fSpawn][0], Furniture[mixerid][fSpawn][1]-0.2, Furniture[mixerid][fSpawn][2]+0.4, 5.0, -1, -1, 0, Furniture[mixerid][fWorld], -1, -1, 5.0);
	Chemistry[mixerid][Timer] = SetTimerEx("mintueMixing", 60000, true, "d", mixerid);
	return 1;
}

forward mintueMixing(mixerid);
public mintueMixing(mixerid)
{
	if(Chemistry[mixerid][IsWorking])
	{
		if(Chemistry[mixerid][NeedTime] > 0)
		{
		    Chemistry[mixerid][NeedTime]--;
			format(gString, sizeof(gString), "{FFFFFF}Mixer\n{b5c8b6}(%s)\n{39c622}%d mintues left.", E_CHEMICAL[Chemistry[mixerid][Material]][CODE], Chemistry[mixerid][NeedTime]);
			UpdateDynamic3DTextLabelText(Chemistry[mixerid][osLabel], 0x008080FF, gString);
			if(Chemistry[mixerid][NeedTime] == 0)
			{
			    Chemistry[mixerid][IsWorking] = false;
				format(gString, sizeof(gString), "{FFFFFF}Mixer\n{C3C3C3}/reactdrug"); // if /reactdrug called, remove label
				UpdateDynamic3DTextLabelText(Chemistry[mixerid][osLabel], 0xFFFFFFFF, gString);
				KillTimer(Chemistry[mixerid][Timer]);
			}
	    }
    }
}
CMD:controldrug(playerid, params[])
{
    ShowPlayerDialog(playerid, ControlSelect, DIALOG_STYLE_MSGBOX, "TEMPERATURE TOGGLE", "\tSELECT MODE:", "Heating", "Cooling");
	return 1;
}
CMD:reactdrug(playerid, params[])
{
    new saf = GetClosestFurniture(playerid, 2.0, 19585);
	if(saf == -1) return SendClientMessage(playerid, -1, "You are not in a range of a mixer.");
	//if(Chemistry[saf][Working] == 0 && Chemistry[saf][Amount] > 0)
	//{
    SetPlayerSpecialAction(playerid, SPECIAL_ACTION_CARRY);
    SetPlayerAttachedObject(playerid, 9, 19636, 1, -0.039999, 0.414759, -0.042998, -31.400018, 92.117507, 112.900047);
    SetPVarInt(playerid, "nativeCAS", Chemistry[saf][Material]);

	SetPlayerHoldingCrate(playerid,
	E_CHEMICAL[Chemistry[saf][Material]][CODE],
	Chemistry[saf][Type],
	Chemistry[saf][Amount],
	Chemistry[saf][Quality],
	floatround((Chemistry[saf][Amount]+Chemistry[saf][Quality])*0.5),
	floatround(Chemistry[saf][Quality]-10),
	Chemistry[saf][Extra][0],
	Chemistry[saf][Extra][1],
	Chemistry[saf][Extra][2]);
	
	ApplyAnimation(playerid, "carry", "liftup", 1, 0, 1, 1, 0, 1000);
    ApplyAnimation(playerid, "carry", "liftup", 1, 0, 1, 1, 0, 1000);
    DestroyDynamic3DTextLabel(Chemistry[saf][osLabel]);
    
	Chemistry[saf][NeedTime] = 0;
	Chemistry[saf][Material] = 0;
	Chemistry[saf][IsWorking] = false;
    Chemistry[saf][Quality] = 0;
    Chemistry[saf][Amount] = 0;
		//AddDrugs(playerid, params[0], E_CHEMICAL[DrugMix[saf][Material]][CODE], DrugMix[saf][Type], float(DrugMix[saf][Amount]), DrugMix[saf][Quality], floatround((DrugMix[saf][Amount]+DrugMix[saf][Quality])*0.5), floatround(DrugMix[saf][Quality]-10));
	//}
	return 1;
}

CMD:piledrug(playerid, params[])
{
	new param = GetClosestFurniture(playerid, 2.0, 2360);
	if(param == -1) return SendClientMessage(playerid, COLOR_LIGHTRED, "There's no reactor.");
	if(GetPVarInt(playerid, "CarryingDrugCrate") == 1)
	{
        ReactDrug(playerid, GetPVarInt(playerid, "nativeCAS"), GetPVarFloat(playerid, "tdrug_Amount"), GetPVarFloat(playerid, "tdrug_Quality"),  GetPVarInt(playerid, "BreakingBad_1"),  GetPVarInt(playerid, "BreakingBad_2"),  GetPVarInt(playerid, "BreakingBad_2"), param);
        ResetDrugCrate(playerid);
        ApplyAnimation(playerid, "carry", "putdwn", 1, 0, 1, 1, 0, 1000);
        ApplyAnimation(playerid, "carry", "putdwn", 1, 0, 1, 1, 0, 1000);
	}
	else SendClientMessage(playerid, COLOR_LIGHTRED, "You don't have mixed chemical.");
	return 1;
}

CMD:checkreaction(playerid, params[])
{
	new title[64];
	new param = GetClosestFurniture(playerid, 2.0, 2360);
	if(param == -1) return SendClientMessage(playerid, COLOR_LIGHTRED, "There's no reactor around.");
    //if(hInfo[InHouse[playerid]][D_DrugID] > 0 && hInfo[InHouse[playerid]][D_Time] != hInfo[InHouse[playerid]][WantedTime]) return CPF(playerid, COLOR_GRAY, "暂时还未结晶成功.");
	format(title, sizeof(title), "%s", E_CHEMICAL[Chemistry[ param ][Material]][NAME]);
	format(gString, sizeof(gString), "Element Structure %s >> Purity {FFFF00}%.1f%%{FFFFFF}\n\n\tAnalysis: %.1f / MOL", E_CHEMICAL[Chemistry[ param ][Material]][CODE], Chemistry[ param ][Quality], Chemistry[ param ][Amount]);
	Dialog_Show(playerid, REACTDRUG, DIALOG_STYLE_MSGBOX, title, gString, "Purify", "<<");
	return 1;
}

CMD:mixdrug(playerid, params[])
{
    if(!GetClosestFurniture(playerid, 2.0, 19585)) return 1;
	ShowMixingDialog(playerid, Part_Mixing);
	return 1;
}

stock ReactDrug(playerid, drugid, Float: amount, Float: quality, extra1, extra2, extra3, saf)
{
    RemovePlayerAttachedObject(playerid, 9);
	Chemistry[saf][IsWorking] = true;
	Chemistry[saf][WorkType] = GetFurnitureWorkType(saf);
	Chemistry[saf][Temperature] = 0.0;
	Chemistry[saf][Material] = drugid;
	Chemistry[saf][Amount] = amount;
	Chemistry[saf][Quality] = quality;
	Chemistry[saf][Extra][0] = extra1;
	Chemistry[saf][Extra][1] = extra2;
	Chemistry[saf][Extra][2] = extra3;

	format(gString, sizeof(gString), "{ffffff}Reactor\n{b5c8b6}%.1f / MOL", amount);
	Chemistry[saf][osLabel] = CreateDynamic3DTextLabel(gString, 0x008080FF, Furniture[saf][fSpawn][0], Furniture[saf][fSpawn][1]-0.2, Furniture[saf][fSpawn][2]+0.4, 5.0, -1, -1, 0, Furniture[saf][fWorld], -1, -1, 5.0);
	Chemistry[saf][Timer] = SetTimerEx("startReacting", 500, true, "d", saf);
	ResetDrugCrate(playerid);
}

stock SetPlayerHoldingCrate(playerid, cas[], type, Float:amount, Float: quality, effecttime, addiction, native_main, native_extra, native_last)
{
    SetPVarInt(playerid, "CarryingDrugCrate", 1);
	SetStringVar(playerid, "tdrug_CAS", cas);
	SetPVarInt(playerid, "tdrug_Type", type);
	SetPVarFloat(playerid, "tdrug_Amount", amount);
	SetPVarFloat(playerid, "tdrug_Quality", quality);
	SetPVarInt(playerid, "tdrug_EffectTime", effecttime);
	SetPVarInt(playerid, "tdrug_Addiction", addiction);
    SetPVarInt(playerid, "BreakingBad_1", native_main);
    SetPVarInt(playerid, "BreakingBad_2", native_extra);
    SetPVarInt(playerid, "BreakingBad_3", native_last);
	return 1;
}

stock ResetDrugCrate(playerid)
{
	DeletePVar(playerid, "CarryingDrugCrate");
	DeletePVar(playerid, "tdrug_CAS");
	DeletePVar(playerid, "tdrug_Type");
	DeletePVar(playerid, "tdrug_Amount");
	DeletePVar(playerid, "tdrug_Quality");
	DeletePVar(playerid, "tdrug_EffectTime");
	DeletePVar(playerid, "tdrug_Addiction");
	DeletePVar(playerid, "nativeCAS");
	DeletePVar(playerid, "BreakingBad_1");
	DeletePVar(playerid, "BreakingBad_2");
	DeletePVar(playerid, "BreakingBad_3");
    RemovePlayerAttachedObject(playerid, 9);
    SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
    return 1;
}

forward startReacting(saf);
public startReacting(saf)
{
	if(Chemistry[saf][Temperature] > 0)
	{
	    Chemistry[saf][curTemperature] += 0.01*random(5);
	    if(Chemistry[saf][curTemperature] > 10.0) Chemistry[saf][curTemperature] += 0.1*random(5);
	    if(Chemistry[saf][curTemperature] > 50.0) Chemistry[saf][curTemperature] += 0.2*random(10);

        format(gString, sizeof(gString), "{ffffff}Reactor\n{b5c8b6}%.1f / MOL\n\n{FFFF00}Temperature: %s%.2f F", Chemistry[saf][Control] ? ("+") : ("-"), Chemistry[saf][Amount], Chemistry[saf][curTemperature]);
        UpdateDynamic3DTextLabelText(Chemistry[saf][osLabel], 0x008080FF, gString);
        if(Chemistry[saf][curTemperature] > E_CHEMICAL[Chemistry[saf][Material]][POINT] + 3.0)
        {
            Chemistry[saf][OverPoint] ++;
            if(Chemistry[saf][OverPoint] >= 10)
            {
	            switch(E_CHEMICAL[Chemistry[saf][Material]][STATUS])
	            {
	                case 0: // labile
	                {
						/* 	Aether is a very labile chemical,
							if it's overheating for seconds, who ever near by will get killed and everything in house will destroy
						*/
	                    print("LABILE CALLED");

	                }
	                case 1: // stable
	                {
	                    ClearFurnitureData(saf);
	                    print("ClearFurnitureData CALLED");
	                }
	            }
            }
        }
        else if(Chemistry[saf][curTemperature] == E_CHEMICAL[Chemistry[saf][Material]][POINT])
		{
			Chemistry[saf][OverPoint] ++;
			if(Chemistry[saf][OverPoint] == 50)
			{
				Chemistry[saf][OverPoint] = -1;
			}
		}
		else Chemistry[saf][OverPoint] = 0;
	    if(Chemistry[saf][OverPoint] == -1)
	    {
	        KillTimer(Chemistry[saf][Timer]);
	        Chemistry[saf][curTemperature] = 0.0;
	        Chemistry[saf][Temperature] = 0.0;
	        format(gString, sizeof(gString), "{ffffff}Reactor\n{FFFF00}semi-crystal >> %s {C3C3C3}(OAS: %.1f%%)\n{C0C0C0}/checkreaction", E_CHEMICAL[Chemistry[saf][Material]][NAME], Chemistry[saf][Quality]);
	        UpdateDynamic3DTextLabelText(Chemistry[saf][osLabel], 0x008080FF, gString);
	        Chemistry[saf][OverPoint] = 0;
	    }
	}
}

ClearFurnitureData(furnitureid)
{
    KillTimer(Chemistry[furnitureid][Timer]);
    KillTimer(Chemistry[furnitureid][Timer]);
    DestroyDynamic3DTextLabel(Chemistry[furnitureid][osLabel]);
    Chemistry[furnitureid][curTemperature] = 0.0;
    Chemistry[furnitureid][Temperature] = 0.0;
	Chemistry[furnitureid][IsWorking] = false;
	Chemistry[furnitureid][WorkType] = -1;
	Chemistry[furnitureid][Temperature] = 0.0;
	Chemistry[furnitureid][Material] = -1;
	Chemistry[furnitureid][Amount] = -1;
	Chemistry[furnitureid][Quality] = -1;
	Chemistry[furnitureid][Extra][0] = -1;
	Chemistry[furnitureid][Extra][1] = -1;
	Chemistry[furnitureid][Extra][2] = -1;
	Chemistry[furnitureid][Control] = -1;
	Chemistry[furnitureid][OverPoint] = 0;
	return 1;
}
