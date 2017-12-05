IsABike(vehicleid)
{
    new model = GetVehicleModel(vehicleid);

    switch(model)
    {
        case 509, 481, 510: return 1;
   }

    return 0;
}

IsAMotorBike(vehicleid)
{
    new model = GetVehicleModel(vehicleid);

    switch(model)
    {
        case 509, 481, 510, 462, 448, 581, 522, 461, 421, 523, 463, 586, 468, 471: return 1;
   }

    return 0;
}

stock GetComponentName(component)
{
    new modname[50];
    switch(component)
    {
       case 1000: format(modname, sizeof(modname), "Pro Spoiler");
       case 1001: format(modname, sizeof(modname), "Win Spoiler");
       case 1002: format(modname, sizeof(modname), "Drag Spoiler");
       case 1003: format(modname, sizeof(modname), "Alpha Spoiler");
       case 1004: format(modname, sizeof(modname), "Champ Scoop");
       case 1005: format(modname, sizeof(modname), "Fury Scoop");
       case 1006: format(modname, sizeof(modname), "Roof Scoop");
       case 1007: format(modname, sizeof(modname), "Right Sideskirt");
       case 1008: format(modname, sizeof(modname), "Nitrous x5");
       case 1009: format(modname, sizeof(modname), "Nitrous x2");
       case 1010: format(modname, sizeof(modname), "Nitrous x10");
       case 1011: format(modname, sizeof(modname), "Race Scoop");
       case 1012: format(modname, sizeof(modname), "Worx Scoop");
       case 1013: format(modname, sizeof(modname), "Round Fog Lights");
       case 1014: format(modname, sizeof(modname), "Champ Spoiler");
       case 1015: format(modname, sizeof(modname), "Race Spoiler");
       case 1016: format(modname, sizeof(modname), "Worx Spoiler");
       case 1017: format(modname, sizeof(modname), "Left Sideskirt");
       case 1018: format(modname, sizeof(modname), "Upswept Exhaust");
       case 1019: format(modname, sizeof(modname), "Twin Exhaust");
       case 1020: format(modname, sizeof(modname), "Large Exhaust");
       case 1021: format(modname, sizeof(modname), "Medium Exhaust");
       case 1022: format(modname, sizeof(modname), "Small Exhaust");
       case 1023: format(modname, sizeof(modname), "Fury Spoiler");
       case 1024: format(modname, sizeof(modname), "Square Fog Lights");
       case 1025: format(modname, sizeof(modname), "Offroad Wheels");
       case 1026, 1036, 1047, 1056, 1069, 1090: format(modname, sizeof(modname), "Right Alien Sideskirt");
       case 1027, 1040, 1051, 1062, 1071, 1094: format(modname, sizeof(modname), "Left Alien Sideskirt");
       case 1028, 1034, 1046, 1064, 1065, 1092: format(modname, sizeof(modname), "Alien Exhaust");
       case 1029, 1037, 1045, 1059, 1066, 1089: format(modname, sizeof(modname), "X-Flow Exhaust");
       case 1030, 1039, 1048, 1057, 1070, 1095: format(modname, sizeof(modname), "Right X-Flow Sideskirt");
       case 1031, 1041, 1052, 1063, 1072, 1093: format(modname, sizeof(modname), "Left X-Flow Sideskirt");
       case 1032, 1038, 1054, 1055, 1067, 1088: format(modname, sizeof(modname), "Alien Roof Vent");
       case 1033, 1035, 1053, 1061, 1068, 1091: format(modname, sizeof(modname), "X-Flow Roof Vent");
       case 1042: format(modname, sizeof(modname), "Right Chrome Sideskirt");
       case 1099: format(modname, sizeof(modname), "Left Chrome Sideskirt");
       case 1043, 1105, 1114, 1127, 1132, 1135: format(modname, sizeof(modname), "Slamin Exhaust");
       case 1044, 1104, 1113, 1126, 1129, 1136: format(modname, sizeof(modname), "Chrome Exhaust");
       case 1050, 1058, 1139, 1146, 1158, 1163: format(modname, sizeof(modname), "X-Flow Spoiler");
       case 1049, 1060, 1138, 1147, 1162, 1164: format(modname, sizeof(modname), "Alien Spoiler");
       case 1073: format(modname, sizeof(modname), "Shadow Wheels");
       case 1074: format(modname, sizeof(modname), "Mega Wheels");
       case 1075: format(modname, sizeof(modname), "Rimshine Wheels");
       case 1076: format(modname, sizeof(modname), "Wires Wheels");
       case 1077: format(modname, sizeof(modname), "Classic Wheels");
       case 1078: format(modname, sizeof(modname), "Twist Wheels");
       case 1079: format(modname, sizeof(modname), "Cutter Wheels");
       case 1080: format(modname, sizeof(modname), "Stitch Wheels");
       case 1081: format(modname, sizeof(modname), "Grove Wheels");
       case 1082: format(modname, sizeof(modname), "Import Wheels");
       case 1083: format(modname, sizeof(modname), "Dollar Wheels");
       case 1084: format(modname, sizeof(modname), "Trance Wheels");
       case 1085: format(modname, sizeof(modname), "Atomic Wheels");
       case 1086: format(modname, sizeof(modname), "Stereo");
       case 1087: format(modname, sizeof(modname), "Hydraulics");
       case 1096: format(modname, sizeof(modname), "Ahab Wheels");
       case 1097: format(modname, sizeof(modname), "Virtual Wheels");
       case 1098: format(modname, sizeof(modname), "Access Wheels");
       case 1100: format(modname, sizeof(modname), "Chrome Grill");
       case 1101: format(modname, sizeof(modname), "Left Chrome Flames Sideskirt");
       case 1102, 1107: format(modname, sizeof(modname), "Left Chrome Strip Sideskirt");
       case 1103: format(modname, sizeof(modname), "Convertible Roof");
       case 1106, 1124, 1137: format(modname, sizeof(modname), "Left Chrome Arches Sideskirt");
       case 1108, 1133, 1134: format(modname, sizeof(modname), "Right Chrome Strip Sideskirt");
       case 1109: format(modname, sizeof(modname), "Chrome Rear Bullbars");
       case 1110: format(modname, sizeof(modname), "Slamin Rear Bullbars");
       case 1111, 1112: format(modname, sizeof(modname), "Front Sign");
       case 1115: format(modname, sizeof(modname), "Chrome Front Bullbars");
       case 1116: format(modname, sizeof(modname), "Slamin Front Bullbars");
       case 1117, 1174, 1179, 1182, 1189, 1191: format(modname, sizeof(modname), "Chrome Front Bumper");
       case 1175, 1181, 1185, 1188, 1190: format(modname, sizeof(modname), "Slamin Front Bumper");
       case 1176, 1180, 1184, 1187, 1192: format(modname, sizeof(modname), "Chrome Rear Bumper");
       case 1177, 1178, 1183, 1186, 1193: format(modname, sizeof(modname), "Slamin Rear Bumper");
       case 1118: format(modname, sizeof(modname), "Right Chrome Trim Sideskirt");
       case 1119: format(modname, sizeof(modname), "Right Wheelcovers Sideskirt");
       case 1120: format(modname, sizeof(modname), "Left Chrome Trim Sideskirt");
       case 1121: format(modname, sizeof(modname), "Left Wheelcovers Sideskirt");
       case 1122: format(modname, sizeof(modname), "Right Chrome Flames Sideskirt");
       case 1123: format(modname, sizeof(modname), "Bullbar Chrome Bars");
       case 1125: format(modname, sizeof(modname), "Bullbar Chrome Lights");
       case 1128: format(modname, sizeof(modname), "Vinyl Hardtop Roof");
       case 1130: format(modname, sizeof(modname), "Hardtop Roof");
       case 1131: format(modname, sizeof(modname), "Softtop Roof");
       case 1140, 1148, 1151, 1156, 1161, 1167: format(modname, sizeof(modname), "X-Flow Rear Bumper");
       case 1141, 1149, 1150, 1154, 1159, 1168: format(modname, sizeof(modname), "Alien Rear Bumper");
       case 1142: format(modname, sizeof(modname), "Left Oval Vents");
       case 1143: format(modname, sizeof(modname), "Right Oval Vents");
       case 1144: format(modname, sizeof(modname), "Left Square Vents");
       case 1145: format(modname, sizeof(modname), "Right Square Vents");
       case 1152, 1157, 1165, 1170, 1172, 1173: format(modname, sizeof(modname), "X-Flow Front Bumper");
       case 1153, 1155, 1160, 1166, 1169, 1171: format(modname, sizeof(modname), "Alien Front Bumper");

    }
    return modname;
}

GetVehicleComponentCount(category, model)
{
    switch(category)
    {
        case 0: return GetVehicleSpoilerCount(model);
        case 1: return GetVehicleHoodCount(model);
        case 2: return GetVehicleExhaustCount(model);
        case 3: return GetVehicleFBumperCount(model);
        case 4: return GetVehicleBBumperCount(model);
        case 5: return GetVehicleRoofCount(model);
        case 6: return GetVehicleWheelCount(model);
        case 7: return GetVehicleHydraulicCount(model);
        case 8: return GetVehicleNitroCount(model);
        case 9: return GetVehicleLeftSSCount(model);
        case 10: return GetVehiclePaintJobCount(model);
   }

    return 0;
}

GetComponentPrice(componentid, &price = 0)
{
    switch(componentid)
    {
        case 1004..1007, 1011..1013, 1017, 1024, 1026, 1027, 1030, 1031, 1036, 1039..1042, 1047, 1048, 1051, 1052, 1056, 1057, 1062, 1063, 1069..1072, 1090, 1093..1095, 1099, 1101, 1102, 1106..1108, 1118..1122, 1124, 1133, 1134, 1137, 1142..1145: price = 4000;
        case 1018..1022, 1025, 1028, 1029, 1032..1035, 1037, 1038, 1043..1046, 1053..1055, 1059, 1061, 1064..1068, 1073..1085, 1088, 1089, 1091, 1092, 1096..1098, 1103..1105, 1111..1114, 1126, 1127, 1129, 1132, 1135, 1136: price = 5000;
        case 1100, 1109, 1110, 1115, 1117, 1123, 1125, 1140, 1141, 1148..1157, 1159..1161, 1165..1193: price = 6000;
        case 1000..1003, 1009, 1014..1016, 1023, 1049, 1050, 1058, 1060, 1087, 1128, 1130, 1131, 1138, 1139, 1146, 1147, 1158, 1162..1164: price = 7500;
        case 1008, 1086: price = 12500;
        case 1010: price = 17500;
   }
    return price;
}

GetVehicleSpoilerCount(model, &count = 0)
{
    switch(model)
    {
        case 401, 418, 420, 426, 436, 492, 540, 542, 549, 558, 559, 560, 561, 562, 565, 580, 589, 603: count = 2;
        case 404, 410, 415, 439, 489, 491, 518, 527, 529, 546, 547, 550, 585: count = 3;
        case 405, 421, 496, 516, 517, 551: count = 4;
   }
    return count;
}

GetVehicleCompatibleSpoiler(model, count, &componentid = 0)
{
    switch(model)
    {
        case 401:
        {
            switch(count)
            {
                case 1: componentid = 1001;
                case 2: componentid = 1003;
           }
       }
        case 404:
        {
            switch(count)
            {
                case 1: componentid = 1000;
                case 2: componentid = 1002;
                case 3: componentid = 1016;
           }
       }
        case 405:
        {
            switch(count)
            {
                case 1: componentid = 1000;
                case 2: componentid = 1001;
                case 3: componentid = 1014;
                case 4: componentid = 1023;
           }
       }
        case 410:
        {
            switch(count)
            {
                case 1: componentid = 1001;
                case 2: componentid = 1003;
                case 3: componentid = 1023;
           }
       }
        case 415:
        {
            switch(count)
            {
                case 1: componentid = 1001;
                case 2: componentid = 1003;
                case 3: componentid = 1023;
           }
       }
        case 418:
        {
            switch(count)
            {
                case 1: componentid = 1002;
                case 2: componentid = 1016;
           }
       }
        case 420:
        {
            switch(count)
            {
                case 1: componentid = 1001;
                case 2: componentid = 1003;
           }
       }
        case 421:
        {
            switch(count)
            {
                case 1: componentid = 1000;
                case 2: componentid = 1014;
                case 3: componentid = 1016;
                case 4: componentid = 1023;
           }
       }
        case 426:
        {
            switch(count)
            {
                case 1: componentid = 1001;
                case 2: componentid = 1003;
           }
       }
        case 436:
        {
            switch(count)
            {
                case 1: componentid = 1001;
                case 2: componentid = 1003;
           }
       }
        case 439:
        {
            switch(count)
            {
                case 1: componentid = 1001;
                case 2: componentid = 1003;
                case 3: componentid = 1023;
           }
       }
        case 489:
        {
            switch(count)
            {
                case 1: componentid = 1000;
                case 2: componentid = 1002;
                case 3: componentid = 1016;
           }
       }
        case 491:
        {
            switch(count)
            {
                case 1: componentid = 1003;
                case 2: componentid = 1014;
                case 3: componentid = 1023;
           }
       }
        case 492:
        {
            switch(count)
            {
                case 1: componentid = 1000;
                case 2: componentid = 1016;
           }
       }
        case 496:
        {
            switch(count)
            {
                case 1: componentid = 1001;
                case 2: componentid = 1002;
                case 3: componentid = 1003;
                case 4: componentid = 1023;
           }
       }
        case 516:
        {
            switch(count)
            {
                case 1: componentid = 1000;
                case 2: componentid = 1002;
                case 3: componentid = 1015;
                case 4: componentid = 1016;
           }
       }
        case 517:
        {
            switch(count)
            {
                case 1: componentid = 1002;
                case 2: componentid = 1003;
                case 3: componentid = 1016;
                case 4: componentid = 1023;
           }
       }
        case 518:
        {
            switch(count)
            {
                case 1: componentid = 1001;
                case 2: componentid = 1003;
                case 3: componentid = 1023;
           }
       }
        case 527:
        {
            switch(count)
            {
                case 1: componentid = 1001;
                case 2: componentid = 1014;
                case 3: componentid = 1015;
           }
       }
        case 529:
        {
            switch(count)
            {
                case 1: componentid = 1001;
                case 2: componentid = 1003;
                case 3: componentid = 1023;
           }
       }
        case 540:
        {
            switch(count)
            {
                case 1: componentid = 1001;
                case 2: componentid = 1023;
           }
       }
        case 542:
        {
            switch(count)
            {
                case 1: componentid = 1014;
                case 2: componentid = 1015;
           }
       }
        case 546:
        {
            switch(count)
            {
                case 1: componentid = 1001;
                case 2: componentid = 1002;
                case 3: componentid = 1023;
           }
       }
        case 547:
        {
            switch(count)
            {
                case 1: componentid = 1000;
                case 2: componentid = 1003;
                case 3: componentid = 1016;
           }
       }
        case 549:
        {
            switch(count)
            {
                case 1: componentid = 1001;
                case 2: componentid = 1023;
           }
       }
        case 550:
        {
            switch(count)
            {
                case 1: componentid = 1001;
                case 2: componentid = 1003;
                case 3: componentid = 1023;
           }
       }
        case 551:
        {
            switch(count)
            {
                case 1: componentid = 1002;
                case 2: componentid = 1003;
                case 3: componentid = 1016;
                case 4: componentid = 1023;
           }
       }
        case 558:
        {
            switch(count)
            {
                case 1: componentid = 1163;
                case 2: componentid = 1164;
           }
       }
        case 559:
        {
            switch(count)
            {
                case 1: componentid = 1158;
                case 2: componentid = 1162;
           }
       }
        case 560:
        {
            switch(count)
            {
                case 1: componentid = 1138;
                case 2: componentid = 1139;
           }
       }
        case 561:
        {
            switch(count)
            {
                case 1: componentid = 1058;
                case 2: componentid = 1060;
           }
       }
        case 562:
        {
            switch(count)
            {
                case 1: componentid = 1146;
                case 2: componentid = 1147;
           }
       }
        case 565:
        {
            switch(count)
            {
                case 1: componentid = 1049;
                case 2: componentid = 1050;
           }
       }
        case 580:
        {
            switch(count)
            {
                case 1: componentid = 1001;
                case 2: componentid = 1023;
           }
       }
        case 585:
        {
            switch(count)
            {
                case 1: componentid = 1001;
                case 2: componentid = 1003;
                case 3: componentid = 1023;
           }
       }
        case 589:
        {
            switch(count)
            {
                case 1: componentid = 1000;
                case 2: componentid = 1016;
           }
       }
        case 603:
        {
            switch(count)
            {
                case 1: componentid = 1001;
                case 2: componentid = 1023;
           }
       }
   }
    return componentid;
}

GetVehicleHoodCount(model, &count = 0)
{
    switch(model)
    {
        case 496, 516, 518, 540, 546, 551: count = 1;
        case 401, 420, 426, 489, 492, 529, 549, 550, 589, 600: count = 2;
        case 478: count = 3;
   }
    return count;
}

GetVehicleCompatibleHood(model, count, &componentid = 0)
{
    switch(model)
    {
        case 401:
        {
            switch(count)
            {
                case 1: componentid = 1004;
                case 2: componentid = 1005;
           }
       }
        case 420:
        {
            switch(count)
            {
                case 1: componentid = 1004;
                case 2: componentid = 1005;
           }
       }
        case 426:
        {
            switch(count)
            {
                case 1: componentid = 1004;
                case 2: componentid = 1005;
           }
       }
        case 478:
        {
            switch(count)
            {
                case 1: componentid = 1004;
                case 2: componentid = 1005;
                case 3: componentid = 1012;
           }
       }
        case 489:
        {
            switch(count)
            {
                case 1: componentid = 1004;
                case 2: componentid = 1005;
           }
       }
        case 492:
        {
            switch(count)
            {
                case 1: componentid = 1004;
                case 2: componentid = 1005;
           }
       }
        case 496:
        {
            switch(count)
            {
                case 1: componentid = 1011;
           }
       }
        case 516:
        {
            switch(count)
            {
                case 1: componentid = 1004;
           }
       }
        case 518:
        {
            switch(count)
            {
                case 1: componentid = 1005;
           }
       }
        case 529:
        {
            switch(count)
            {
                case 1: componentid = 1011;
                case 2: componentid = 1012;
           }
       }
        case 540:
        {
            switch(count)
            {
                case 1: componentid = 1004;
           }
       }
        case 546:
        {
            switch(count)
            {
                case 1: componentid = 1004;
           }
       }
        case 549:
        {
            switch(count)
            {
                case 1: componentid = 1011;
                case 2: componentid = 1012;
           }
       }
        case 550:
        {
            switch(count)
            {
                case 1: componentid = 1004;
                case 2: componentid = 1005;
           }
       }
        case 551:
        {
            switch(count)
            {
                case 1: componentid = 1005;
           }
       }
        case 589:
        {
            switch(count)
            {
                case 1: componentid = 1004;
                case 2: componentid = 1005;
           }
       }
        case 600:
        {
            switch(count)
            {
                case 1: componentid = 1004;
                case 2: componentid = 1005;
           }
       }
   }
    return componentid;
}

GetVehicleExhaustCount(model, &count = 0)
{
    switch(model)
    {
        case 401, 415, 418, 420, 426, 496, 518, 534, 535, 536, 546, 558, 559, 560, 561, 562, 565, 567, 575, 576, 580, 589: count = 2;
        case 404, 410, 422, 478, 489, 500, 517, 527, 529, 540, 549, 550, 585, 600, 603: count = 3;
        case 400, 405, 421, 436, 477, 491, 516, 542, 547, 551: count = 4;
   }
    return count;
}

GetVehicleCompatibleExhaust(model, count, &componentid = 0)
{
    switch(model)
    {
        case 400:
        {
            switch(count)
            {
                case 1: componentid = 1018;
                case 2: componentid = 1019;
                case 3: componentid = 1020;
                case 4: componentid = 1021;
           }
       }
        case 401:
        {
            switch(count)
            {
                case 1: componentid = 1019;
                case 2: componentid = 1020;
           }
       }
        case 404:
        {
            switch(count)
            {
                case 1: componentid = 1019;
                case 2: componentid = 1020;
                case 3: componentid = 1021;
           }
       }
        case 405:
        {
            switch(count)
            {
                case 1: componentid = 1018;
                case 2: componentid = 1019;
                case 3: componentid = 1020;
                case 4: componentid = 1021;
           }
       }
        case 410:
        {
            switch(count)
            {
                case 1: componentid = 1019;
                case 2: componentid = 1020;
                case 3: componentid = 1021;
           }
       }
        case 415:
        {
            switch(count)
            {
                case 1: componentid = 1018;
                case 2: componentid = 1019;
           }
       }
        case 418:
        {
            switch(count)
            {
                case 1: componentid = 1020;
                case 2: componentid = 1021;
           }
       }
        case 420:
        {
            switch(count)
            {
                case 1: componentid = 1019;
                case 2: componentid = 1021;
           }
       }
        case 421:
        {
            switch(count)
            {
                case 1: componentid = 1018;
                case 2: componentid = 1019;
                case 3: componentid = 1020;
                case 4: componentid = 1021;
           }
       }
        case 422:
        {
            switch(count)
            {
                case 1: componentid = 1019;
                case 2: componentid = 1020;
                case 3: componentid = 1021;
           }
       }
        case 426:
        {
            switch(count)
            {
                case 1: componentid = 1019;
                case 2: componentid = 1021;
           }
       }
        case 436:
        {
            switch(count)
            {
                case 1: componentid = 1019;
                case 2: componentid = 1020;
                case 3: componentid = 1021;
                case 4: componentid = 1022;
           }
       }
        case 477:
        {
            switch(count)
            {
                case 1: componentid = 1018;
                case 2: componentid = 1019;
                case 3: componentid = 1020;
                case 4: componentid = 1021;
           }
       }
        case 478:
        {
            switch(count)
            {
                case 1: componentid = 1020;
                case 2: componentid = 1021;
                case 3: componentid = 1022;
           }
       }
        case 489:
        {
            switch(count)
            {
                case 1: componentid = 1018;
                case 2: componentid = 1019;
                case 3: componentid = 1020;
           }
       }
        case 491:
        {
            switch(count)
            {
                case 1: componentid = 1018;
                case 2: componentid = 1019;
                case 3: componentid = 1020;
                case 4: componentid = 1021;
           }
       }
        case 496:
        {
            switch(count)
            {
                case 1: componentid = 1019;
                case 2: componentid = 1020;
           }
       }
        case 500:
        {
            switch(count)
            {
                case 1: componentid = 1019;
                case 2: componentid = 1020;
                case 3: componentid = 1021;
           }
       }
        case 516:
        {
            switch(count)
            {
                case 1: componentid = 1018;
                case 2: componentid = 1019;
                case 3: componentid = 1020;
                case 4: componentid = 1021;
           }
       }
        case 517:
        {
            switch(count)
            {
                case 1: componentid = 1018;
                case 2: componentid = 1019;
                case 3: componentid = 1020;
           }
       }
        case 518:
        {
            switch(count)
            {
                case 1: componentid = 1018;
                case 2: componentid = 1020;
           }
       }
        case 527:
        {
            switch(count)
            {
                case 1: componentid = 1018;
                case 2: componentid = 1020;
                case 3: componentid = 1021;
           }
       }
        case 529:
        {
            switch(count)
            {
                case 1: componentid = 1018;
                case 2: componentid = 1019;
                case 3: componentid = 1020;
           }
       }
        case 534:
        {
            switch(count)
            {
                case 1: componentid = 1126;
                case 2: componentid = 1127;
           }
       }
        case 535:
        {
            switch(count)
            {
                case 1: componentid = 1113;
                case 2: componentid = 1114;
           }
       }
        case 536:
        {
            switch(count)
            {
                case 1: componentid = 1104;
                case 2: componentid = 1105;
           }
       }
        case 540:
        {
            switch(count)
            {
                case 1: componentid = 1018;
                case 2: componentid = 1019;
                case 3: componentid = 1020;
           }
       }
        case 542:
        {
            switch(count)
            {
                case 1: componentid = 1018;
                case 2: componentid = 1019;
                case 3: componentid = 1020;
                case 4: componentid = 1021;
           }
       }
        case 546:
        {
            switch(count)
            {
                case 1: componentid = 1018;
                case 2: componentid = 1019;
           }
       }
        case 547:
        {
            switch(count)
            {
                case 1: componentid = 1018;
                case 2: componentid = 1019;
                case 3: componentid = 1020;
                case 4: componentid = 1021;
           }
       }
        case 549:
        {
            switch(count)
            {
                case 1: componentid = 1018;
                case 2: componentid = 1019;
                case 3: componentid = 1020;
           }
       }
        case 550:
        {
            switch(count)
            {
                case 1: componentid = 1018;
                case 2: componentid = 1019;
                case 3: componentid = 1020;
           }
       }
        case 551:
        {
            switch(count)
            {
                case 1: componentid = 1018;
                case 2: componentid = 1019;
                case 3: componentid = 1020;
                case 4: componentid = 1021;
           }
       }
        case 558:
        {
            switch(count)
            {
                case 1: componentid = 1089;
                case 2: componentid = 1092;
           }
       }
        case 559:
        {
            switch(count)
            {
                case 1: componentid = 1065;
                case 2: componentid = 1066;
           }
       }
        case 560:
        {
            switch(count)
            {
                case 1: componentid = 1028;
                case 2: componentid = 1029;
           }
       }
        case 561:
        {
            switch(count)
            {
                case 1: componentid = 1059;
                case 2: componentid = 1064;
           }
       }
        case 562:
        {
            switch(count)
            {
                case 1: componentid = 1034;
                case 2: componentid = 1037;
           }
       }
        case 565:
        {
            switch(count)
            {
                case 1: componentid = 1045;
                case 2: componentid = 1046;
           }
       }
        case 567:
        {
            switch(count)
            {
                case 1: componentid = 1129;
                case 2: componentid = 1132;
           }
       }
        case 575:
        {
            switch(count)
            {
                case 1: componentid = 1043;
                case 2: componentid = 1044;
           }
       }
        case 576:
        {
            switch(count)
            {
                case 1: componentid = 1135;
                case 2: componentid = 1136;
           }
       }
        case 580:
        {
            switch(count)
            {
                case 1: componentid = 1018;
                case 2: componentid = 1020;
           }
       }
        case 585:
        {
            switch(count)
            {
                case 1: componentid = 1018;
                case 2: componentid = 1019;
                case 3: componentid = 1020;
           }
       }
        case 589:
        {
            switch(count)
            {
                case 1: componentid = 1018;
                case 2: componentid = 1020;
           }
       }
        case 600:
        {
            switch(count)
            {
                case 1: componentid = 1018;
                case 2: componentid = 1020;
                case 3: componentid = 1022;
           }
       }
        case 603:
        {
            switch(count)
            {
                case 1: componentid = 1018;
                case 2: componentid = 1019;
                case 3: componentid = 1020;
           }
       }
   }
    return componentid;
}

GetVehicleFBumperCount(model, &count = 0)
{
    switch(model)
    {
        case 535: count = 1;
        case 534, 536, 558, 559, 560, 561, 562, 565, 567, 575, 576: count = 2;
   }
    return count;
}

GetVehicleCompatibleFBumper(model, count, &componentid = 0)
{
    switch(model)
    {
        case 534:
        {
            switch(count)
            {
                case 1: componentid = 1179;
                case 2: componentid = 1185;
           }
       }
        case 535:
        {
            switch(count)
            {
                case 1: componentid = 1117;
           }
       }
        case 536:
        {
            switch(count)
            {
                case 1: componentid = 1181;
                case 2: componentid = 1182;
           }
       }
        case 558:
        {
            switch(count)
            {
                case 1: componentid = 1165;
                case 2: componentid = 1166;
           }
       }
        case 559:
        {
            switch(count)
            {
                case 1: componentid = 1160;
                case 2: componentid = 1173;
           }
       }
        case 560:
        {
            switch(count)
            {
                case 1: componentid = 1169;
                case 2: componentid = 1170;
           }
       }
        case 561:
        {
            switch(count)
            {
                case 1: componentid = 1155;
                case 2: componentid = 1157;
           }
       }
        case 562:
        {
            switch(count)
            {
                case 1: componentid = 1171;
                case 2: componentid = 1172;
           }
       }
        case 565:
        {
            switch(count)
            {
                case 1: componentid = 1152;
                case 2: componentid = 1153;
           }
       }
        case 567:
        {
            switch(count)
            {
                case 1: componentid = 1188;
                case 2: componentid = 1189;
           }
       }
        case 575:
        {
            switch(count)
            {
                case 1: componentid = 1174;
                case 2: componentid = 1176;
           }
       }
        case 576:
        {
            switch(count)
            {
                case 1: componentid = 1190;
                case 2: componentid = 1191;
           }
       }
   }
    return componentid;
}

GetVehicleBBumperCount(model, &count = 0)
{
    switch(model)
    {
        case 534, 536, 558, 559, 560, 561, 562, 565, 567, 575, 576: count = 2;
   }
    return count;
}

GetVehicleCompatibleBBumper(model, count, &componentid = 0)
{
    switch(model)
    {
        case 534:
        {
            switch(count)
            {
                case 1: componentid = 1178;
                case 2: componentid = 1180;
           }
       }
        case 536:
        {
            switch(count)
            {
                case 1: componentid = 1183;
                case 2: componentid = 1184;
           }
       }
        case 558:
        {
            switch(count)
            {
                case 1: componentid = 1167;
                case 2: componentid = 1168;
           }
       }
        case 559:
        {
            switch(count)
            {
                case 1: componentid = 1159;
                case 2: componentid = 1161;
           }
       }
        case 560:
        {
            switch(count)
            {
                case 1: componentid = 1140;
                case 2: componentid = 1141;
           }
       }
        case 561:
        {
            switch(count)
            {
                case 1: componentid = 1154;
                case 2: componentid = 1156;
           }
       }
        case 562:
        {
            switch(count)
            {
                case 1: componentid = 1148;
                case 2: componentid = 1149;
           }
       }
        case 565:
        {
            switch(count)
            {
                case 1: componentid = 1150;
                case 2: componentid = 1151;
           }
       }
        case 567:
        {
            switch(count)
            {
                case 1: componentid = 1186;
                case 2: componentid = 1187;
           }
       }
        case 575:
        {
            switch(count)
            {
                case 1: componentid = 1175;
                case 2: componentid = 1177;
           }
       }
        case 576:
        {
            switch(count)
            {
                case 1: componentid = 1192;
                case 2: componentid = 1193;
           }
       }
   }
    return componentid;
}

GetVehicleRoofCount(model, &count = 0)
{
    switch(model)
    {
        case 401, 418, 426, 436, 477, 489, 492, 496, 518, 529, 540, 546, 550, 551, 580, 585, 589, 600, 603: count = 1;
        case 536, 558, 559, 560, 561, 562, 565, 567: count = 2;
   }
    return count;
}

GetVehicleCompatibleRoof(model, count, &componentid = 0)
{
    switch(model)
    {
        case 401:
        {
            switch(count)
            {
                case 1: componentid = 1006;
           }
       }
        case 418:
        {
            switch(count)
            {
                case 1: componentid = 1006;
           }
       }
        case 426:
        {
            switch(count)
            {
                case 1: componentid = 1006;
           }
       }
        case 436:
        {
            switch(count)
            {
                case 1: componentid = 1006;
           }
       }
        case 477:
        {
            switch(count)
            {
                case 1: componentid = 1006;
           }
       }
        case 489:
        {
            switch(count)
            {
                case 1: componentid = 1006;
           }
       }
        case 492:
        {
            switch(count)
            {
                case 1: componentid = 1006;
           }
       }
        case 496:
        {
            switch(count)
            {
                case 1: componentid = 1006;
           }
       }
        case 518:
        {
            switch(count)
            {
                case 1: componentid = 1006;
           }
       }
        case 529:
        {
            switch(count)
            {
                case 1: componentid = 1006;
           }
       }
        case 536:
        {
            switch(count)
            {
                case 1: componentid = 1103;
                case 2: componentid = 1128;
           }
       }
        case 540:
        {
            switch(count)
            {
                case 1: componentid = 1006;
           }
       }
        case 546:
        {
            switch(count)
            {
                case 1: componentid = 1006;
           }
       }
        case 550:
        {
            switch(count)
            {
                case 1: componentid = 1006;
           }
       }
        case 551:
        {
            switch(count)
            {
                case 1: componentid = 1006;
           }
       }
        case 558:
        {
            switch(count)
            {
                case 1: componentid = 1088;
                case 2: componentid = 1091;
           }
       }
        case 559:
        {
            switch(count)
            {
                case 1: componentid = 1067;
                case 2: componentid = 1068;
           }
       }
        case 560:
        {
            switch(count)
            {
                case 1: componentid = 1032;
                case 2: componentid = 1033;
           }
       }
        case 561:
        {
            switch(count)
            {
                case 1: componentid = 1055;
                case 2: componentid = 1061;
           }
       }
        case 562:
        {
            switch(count)
            {
                case 1: componentid = 1035;
                case 2: componentid = 1038;
           }
       }
        case 565:
        {
            switch(count)
            {
                case 1: componentid = 1053;
                case 2: componentid = 1054;
           }
       }
        case 567:
        {
            switch(count)
            {
                case 1: componentid = 1130;
                case 2: componentid = 1131;
           }
       }
        case 580:
        {
            switch(count)
            {
                case 1: componentid = 1006;
           }
       }
        case 585:
        {
            switch(count)
            {
                case 1: componentid = 1006;
           }
       }
        case 589:
        {
            switch(count)
            {
                case 1: componentid = 1006;
           }
       }
        case 600:
        {
            switch(count)
            {
                case 1: componentid = 1006;
           }
       }
        case 603:
        {
            switch(count)
            {
                case 1: componentid = 1006;
           }
       }
   }
    return componentid;
}

GetVehicleWheelCount(model, &count = 0)
{
    switch(model)
    {
        case 400,401,404,405,410,415,418,420..422,426,436,439,477,478,489,491,492,496,500,516..518,527,529,534..536,540,542,546,547,549..551,558..562,565,567,575,576,580,585,589,600,603: count = 17;
        case 402,403,406..409,411..414,416,419,423,424,427..429,431..435,437,438,440..445,448,450,451,455..459,461..463,466..468,470,471,474,475,479..486,490,494,495,498,499,502..510,514,515,521..526,528,530..533,541,552,543..545,554..557,566,568,578,571..574,579,581..584,586..588,591,594,596..599,601,602,604..611: count = 17;
   }
    return count;
}

GetVehicleCompatibleWheel(model, count, &componentid = 0)
{
    switch(model)
    {
        case 400,401,404,405,410,415,418,420..422,426,436,439,477,478,489,491,492,496,500,516..518,527,529,534..536,540,542,546,547,549..551,558..562,565,567,575,576,580,585,589,600,603:
        {
            switch(count)
            {
                case 1: componentid = 1025;
                case 2: componentid = 1073;
                case 3: componentid = 1074;
                case 4: componentid = 1075;
                case 5: componentid = 1076;
                case 6: componentid = 1077;
                case 7: componentid = 1078;
                case 8: componentid = 1079;
                case 9: componentid = 1080;
                case 10: componentid = 1081;
                case 11: componentid = 1082;
                case 12: componentid = 1083;
                case 13: componentid = 1084;
                case 14: componentid = 1085;
                case 15: componentid = 1096;
                case 16: componentid = 1097;
                case 17: componentid = 1098;
           }
       }
        case 402,403,406..409,411..414,416,419,423,424,427..429,431..435,437,438,440..445,448,450,451,455..459,461..463,466..468,470,471,474,475,479..486,490,494,495,498,499,502..510,514,515,521..526,528,530..533,541,552,543..545,554..557,566,568,578,571..574,579,581..584,586..588,591,594,596..599,601,602,604..611:
        {
            switch(count)
            {
                case 1: componentid = 1025;
                case 2: componentid = 1073;
                case 3: componentid = 1074;
                case 4: componentid = 1075;
                case 5: componentid = 1076;
                case 6: componentid = 1077;
                case 7: componentid = 1078;
                case 8: componentid = 1079;
                case 9: componentid = 1080;
                case 10: componentid = 1081;
                case 11: componentid = 1082;
                case 12: componentid = 1083;
                case 13: componentid = 1084;
                case 14: componentid = 1085;
                case 15: componentid = 1096;
                case 16: componentid = 1097;
                case 17: componentid = 1098;
           }
       }
   }
    return componentid;
}

GetVehicleHydraulicCount(model, &count = 0)
{
    switch(model)
    {
        case 400,401,404,405,410,415,418,420..422,426,436,439,477,478,489,491,492,496,500,516..518,527,529,534..536,540,542,546,547,549..551,558..562,565,567,575,576,580,585,589,600,603: count = 1;
        case 402,403,406..409,411..414,416,419,423,424,427..429,431..435,437,438,440..445,448,450,451,455..459,461..463,466..468,470,471,474,475,479..486,490,494,495,498,499,502..510,514,515,521..526,528,530..533,541,552,543..545,554..557,566,568,578,571..574,579,581..584,586..588,591,594,596..599,601,602,604..611: count = 1;
   }
    return count;
}

GetVehicleCompatibleHydraulic(model, count, &componentid = 0)
{
    switch(model)
    {
        case 400,401,404,405,410,415,418,420..422,426,436,439,477,478,489,491,492,496,500,516..518,527,529,534..536,540,542,546,547,549..551,558..562,565,567,575,576,580,585,589,600,603:
        {
            switch(count)
            {
                case 1: componentid = 1087;
           }
       }
        case 402,403,406..409,411..414,416,419,423,424,427..429,431..435,437,438,440..445,448,450,451,455..459,461..463,466..468,470,471,474,475,479..486,490,494,495,498,499,502..510,514,515,521..526,528,530..533,541,552,543..545,554..557,566,568,578,571..574,579,581..584,586..588,591,594,596..599,601,602,604..611:
        {
            switch(count)
            {
                case 1: componentid = 1087;
           }
       }
   }
    return componentid;
}

GetVehicleNitroCount(model, &count = 0)
{
    switch(model)
    {
        case 400,401,404,405,410,415,418,420..422,426,436,439,477,478,489,491,492,496,500,516..518,527,529,534..536,540,542,546,547,549..551,558..562,565,567,575,576,580,585,589,600,603: count = 3;
        case 402,403,406..409,411..414,416,419,423,424,427..429,431..435,437,438,440..445,448,450,451,455..459,461..463,466..468,470,471,474,475,479..486,490,494,495,498,499,502..510,514,515,521..526,528,530..533,541,552,543..545,554..557,566,568,578,571..574,579,581..584,586..588,591,594,596..599,601,602,604..611: count = 3;
   }
    return count;
}

GetVehicleCompatibleNitro(model, count, &componentid = 0)
{
    switch(model)
    {
        case 400,401,404,405,410,415,418,420..422,426,436,439,477,478,489,491,492,496,500,516..518,527,529,534..536,540,542,546,547,549..551,558..562,565,567,575,576,580,585,589,600,603:
        {
            switch(count)
            {
                case 1: componentid = 1009;
                case 2: componentid = 1008;
                case 3: componentid = 1010;
           }
       }
        case 402,403,406..409,411..414,416,419,423,424,427..429,431..435,437,438,440..445,448,450,451,455..459,461..463,466..468,470,471,474,475,479..486,490,494,495,498,499,502..510,514,515,521..526,528,530..533,541,552,543..545,554..557,566,568,578,571..574,579,581..584,586..588,591,594,596..599,601,602,604..611:
        {
            switch(count)
            {
                case 1: componentid = 1009;
                case 2: componentid = 1008;
                case 3: componentid = 1010;
           }
       }
   }
    return componentid;
}

stock GetVehicleRightSSCount(model, &count = 0)
{
    switch(model)
    {
        case 401, 404, 410, 415, 422, 436, 439, 477, 491, 496, 516, 517, 518, 527, 529, 536, 540, 546, 549, 575, 576, 580, 585, 589, 600, 603: count = 1;
        case 534, 535, 558..562, 565: count = 2;
   }
    return count;
}

stock GetVehicleCompatibleRightSS(model, count, &componentid = 0)
{
    switch(model)
    {
        case 401:
        {
            switch(count)
            {
                case 1: componentid = 1007;
           }
       }
        case 404:
        {
            switch(count)
            {
                case 1: componentid = 1007;
           }
       }
        case 410:
        {
            switch(count)
            {
                case 1: componentid = 1007;
           }
       }
        case 415:
        {
            switch(count)
            {
                case 1: componentid = 1007;
           }
       }
        case 422:
        {
            switch(count)
            {
                case 1: componentid = 1007;
           }
       }
        case 436:
        {
            switch(count)
            {
                case 1: componentid = 1007;
           }
       }
        case 439:
        {
            switch(count)
            {
                case 1: componentid = 1007;
           }
       }
        case 477:
        {
            switch(count)
            {
                case 1: componentid = 1007;
           }
       }
        case 491:
        {
            switch(count)
            {
                case 1: componentid = 1007;
           }
       }
        case 496:
        {
            switch(count)
            {
                case 1: componentid = 1007;
           }
       }
        case 516:
        {
            switch(count)
            {
                case 1: componentid = 1007;
           }
       }
        case 517:
        {
            switch(count)
            {
                case 1: componentid = 1007;
           }
       }
        case 518:
        {
            switch(count)
            {
                case 1: componentid = 1007;
           }
       }
        case 527:
        {
            switch(count)
            {
                case 1: componentid = 1007;
           }
       }
        case 529:
        {
            switch(count)
            {
                case 1: componentid = 1007;
           }
       }
        case 534:
        {
            switch(count)
            {
                case 1: componentid = 1106;
                case 2: componentid = 1122;
           }
       }
        case 535:
        {
            switch(count)
            {
                case 1: componentid = 1118;
                case 2: componentid = 1119;
           }
       }
        case 536:
        {
            switch(count)
            {
                case 1: componentid = 1108;
           }
       }
        case 540:
        {
            switch(count)
            {
                case 1: componentid = 1007;
           }
       }
        case 546:
        {
            switch(count)
            {
                case 1: componentid = 1007;
           }
       }
        case 549:
        {
            switch(count)
            {
                case 1: componentid = 1007;
           }
       }
        case 558:
        {
            switch(count)
            {
                case 1: componentid = 1090;
                case 2: componentid = 1095;
           }
       }
        case 559:
        {
            switch(count)
            {
                case 1: componentid = 1069;
                case 2: componentid = 1070;
           }
       }
        case 560:
        {
            switch(count)
            {
                case 1: componentid = 1026;
                case 2: componentid = 1031;
           }
       }
        case 561:
        {
            switch(count)
            {
                case 1: componentid = 1056;
                case 2: componentid = 1057;
           }
       }
        case 562:
        {
            switch(count)
            {
                case 1: componentid = 1036;
                case 2: componentid = 1041;
           }
       }
        case 565:
        {
            switch(count)
            {
                case 1: componentid = 1047;
                case 2: componentid = 1048;
           }
       }
        case 567:
        {
            switch(count)
            {
                case 1: componentid = 1133;
           }
       }
        case 575:
        {
            switch(count)
            {
                case 1: componentid = 1042;
           }
       }
        case 576:
        {
            switch(count)
            {
                case 1: componentid = 1134;
           }
       }
        case 580:
        {
            switch(count)
            {
                case 1: componentid = 1007;
           }
       }
        case 585:
        {
            switch(count)
            {
                case 1: componentid = 1007;
           }
       }
        case 589:
        {
            switch(count)
            {
                case 1: componentid = 1007;
           }
       }
        case 600:
        {
            switch(count)
            {
                case 1: componentid = 1007;
           }
       }
        case 603:
        {
            switch(count)
            {
                case 1: componentid = 1007;
           }
       }
   }
    return componentid;
}

stock GetVehicleLeftSSCount(model, &count = 0)
{
    switch(model)
    {
        case 401, 404, 410, 415, 422, 436, 439, 477, 491, 496, 516, 517, 518, 527, 529, 536, 540, 546, 549, 575, 576, 580, 585, 589, 600, 603: count = 1;
        case 534, 535, 558..562, 565: count = 2;
   }
    return count;
}

stock GetVehicleCompatibleLeftSS(model, count, &componentid = 0)
{
    switch(model)
    {
        case 401:
        {
            switch(count)
            {
                case 1: componentid = 1017;
           }
       }
        case 404:
        {
            switch(count)
            {
                case 1: componentid = 1017;
           }
       }
        case 410:
        {
            switch(count)
            {
                case 1: componentid = 1017;
           }
       }
        case 415:
        {
            switch(count)
            {
                case 1: componentid = 1017;
           }
       }
        case 422:
        {
            switch(count)
            {
                case 1: componentid = 1017;
           }
       }
        case 436:
        {
            switch(count)
            {
                case 1: componentid = 1017;
           }
       }
        case 439:
        {
            switch(count)
            {
                case 1: componentid = 1017;
           }
       }
        case 477:
        {
            switch(count)
            {
                case 1: componentid = 1017;
           }
       }
        case 491:
        {
            switch(count)
            {
                case 1: componentid = 1017;
           }
       }
        case 496:
        {
            switch(count)
            {
                case 1: componentid = 1017;
           }
       }
        case 516:
        {
            switch(count)
            {
                case 1: componentid = 1017;
           }
       }
        case 517:
        {
            switch(count)
            {
                case 1: componentid = 1017;
           }
       }
        case 518:
        {
            switch(count)
            {
                case 1: componentid = 1017;
           }
       }
        case 527:
        {
            switch(count)
            {
                case 1: componentid = 1017;
           }
       }
        case 529:
        {
            switch(count)
            {
                case 1: componentid = 1017;
           }
       }
        case 534:
        {
            switch(count)
            {
                case 1: componentid = 1101;
                case 2: componentid = 1124;
           }
       }
        case 535:
        {
            switch(count)
            {
                case 1: componentid = 1120;
                case 2: componentid = 1121;
           }
       }
        case 536:
        {
            switch(count)
            {
                case 1: componentid = 1107;
           }
       }
        case 540:
        {
            switch(count)
            {
                case 1: componentid = 1017;
           }
       }
        case 546:
        {
            switch(count)
            {
                case 1: componentid = 1017;
           }
       }
        case 549:
        {
            switch(count)
            {
                case 1: componentid = 1017;
           }
       }
        case 558:
        {
            switch(count)
            {
                case 1: componentid = 1093;
                case 2: componentid = 1094;
           }
       }
        case 559:
        {
            switch(count)
            {
                case 1: componentid = 1071;
                case 2: componentid = 1072;
           }
       }
        case 560:
        {
            switch(count)
            {
                case 1: componentid = 1027;
                case 2: componentid = 1030;
           }
       }
        case 561:
        {
            switch(count)
            {
                case 1: componentid = 1062;
                case 2: componentid = 1063;
           }
       }
        case 562:
        {
            switch(count)
            {
                case 1: componentid = 1039;
                case 2: componentid = 1040;
           }
       }
        case 565:
        {
            switch(count)
            {
                case 1: componentid = 1051;
                case 2: componentid = 1052;
           }
       }
        case 567:
        {
            switch(count)
            {
                case 1: componentid = 1102;
           }
       }
        case 575:
        {
            switch(count)
            {
                case 1: componentid = 1099;
           }
       }
        case 576:
        {
            switch(count)
            {
                case 1: componentid = 1137;
           }
       }
        case 580:
        {
            switch(count)
            {
                case 1: componentid = 1017;
           }
       }
        case 585:
        {
            switch(count)
            {
                case 1: componentid = 1017;
           }
       }
        case 589:
        {
            switch(count)
            {
                case 1: componentid = 1017;
           }
       }
        case 600:
        {
            switch(count)
            {
                case 1: componentid = 1017;
           }
       }
        case 603:
        {
            switch(count)
            {
                case 1: componentid = 1017;
           }
       }
   }
    return componentid;
}

stock GetVehiclePaintJobCount(model, &count = 0)
{
    switch(model)
    {
        case 483: count = 1;
        case 575: count = 2;
        case 534, 535, 536, 558..562, 565, 567, 576: count = 3;
   }
    return count;
}

stock GetVehicleCompatiblePaintJob(model, count, &componentid = 0)
{
    switch(model)
    {
        case 483:
        {
            switch(count)
            {
                case 1: componentid = 0;
           }
       }
        case 534:
        {
            switch(count)
            {
                case 1: componentid = 0;
                case 2: componentid = 1;
                case 3: componentid = 2;
           }
       }
        case 535:
        {
            switch(count)
            {
                case 1: componentid = 0;
                case 2: componentid = 1;
                case 3: componentid = 2;
           }
       }
        case 536:
        {
            switch(count)
            {
                case 1: componentid = 0;
                case 2: componentid = 1;
                case 3: componentid = 2;
           }
       }
        case 558..562:
        {
            switch(count)
            {
                case 1: componentid = 0;
                case 2: componentid = 1;
                case 3: componentid = 2;
           }
       }
        case 565:
        {
            switch(count)
            {
                case 1: componentid = 0;
                case 2: componentid = 1;
                case 3: componentid = 2;
           }
       }
        case 567:
        {
            switch(count)
            {
                case 1: componentid = 0;
                case 2: componentid = 1;
                case 3: componentid = 2;
           }
       }
        case 575:
        {
            switch(count)
            {
                case 1: componentid = 0;
                case 2: componentid = 1;
           }
       }
        case 576:
        {
            switch(count)
            {
                case 1: componentid = 0;
                case 2: componentid = 1;
                case 3:componentid = 2;
           }
       }
   }
    return componentid;
}



GetVehicleCompatibleComponent(category, model, listitem)
{
    switch(category)
    {
        case 0: return GetVehicleCompatibleSpoiler(model, listitem);
        case 1: return GetVehicleCompatibleHood(model, listitem);
        case 2: return GetVehicleCompatibleExhaust(model, listitem);
        case 3: return GetVehicleCompatibleFBumper(model, listitem);
        case 4: return GetVehicleCompatibleBBumper(model, listitem);
        case 5: return GetVehicleCompatibleRoof(model, listitem);
        case 6: return GetVehicleCompatibleWheel(model, listitem);
        case 7: return GetVehicleCompatibleHydraulic(model, listitem);
        case 8: return GetVehicleCompatibleNitro(model, listitem);
        case 9: return GetVehicleCompatibleLeftSS(model, listitem);
        case 10: return GetVehicleCompatiblePaintJob(model, listitem);
   }

    return 0;
}

SetPlayerTuningCameraPos(playerid, category)
{
    switch(category)
    {
        case 0:
        {
            SetPlayerCameraPos(playerid, 441.1662, -1302.0037, 18.0385);
            SetPlayerCameraLookAt(playerid, 440.2185, -1301.6881, 17.6184);
       }
        case 1:
        {
            InterpolateCameraPos(playerid, 441.1662, -1302.0037, 18.0385, 433.8757, -1306.9038, 17.3670, 2000, CAMERA_MOVE);
            InterpolateCameraLookAt(playerid, 440.2185, -1301.6881, 17.6184, 433.8736, -1305.9052, 16.9670, 2000, CAMERA_MOVE);
       }
        case 2:
        {
            InterpolateCameraPos(playerid, 433.8757, -1306.9038, 17.3670, 434.0576, -1291.3750, 14.7338, 2000, CAMERA_MOVE);
            InterpolateCameraLookAt(playerid, 433.8736, -1305.9052, 16.9670, 434.0497, -1292.3737, 14.6737, 2000, CAMERA_MOVE);
       }
        case 3:
        {
            InterpolateCameraPos(playerid, 434.0576, -1291.3750, 14.7338, 434.3085, -1308.4880, 15.5030, 2000, CAMERA_MOVE);
            InterpolateCameraLookAt(playerid, 434.0497, -1292.3737, 14.6737, 434.2510, -1307.4908, 15.4430, 2000, CAMERA_MOVE);
       }
        case 4:
        {
            InterpolateCameraPos(playerid, 434.3085, -1308.4880, 15.5030, 434.0576, -1291.3750, 14.7338, 2000, CAMERA_MOVE);
            InterpolateCameraLookAt(playerid, 434.2510, -1307.4908, 15.4430, 434.0497, -1292.3737, 14.6737, 2000, CAMERA_MOVE);
       }
        case 5:
        {
            InterpolateCameraPos(playerid, 434.0576, -1291.3750, 14.7338, 434.1084, -1302.1560, 18.7596, 2000, CAMERA_MOVE);
            InterpolateCameraLookAt(playerid, 434.0497, -1292.3737, 14.6737, 434.0650, -1301.1581, 17.5145, 2000, CAMERA_MOVE);
       }
        case 6:
        {
            InterpolateCameraPos(playerid, 434.1084, -1302.1560, 18.7596, 437.3644, -1301.3735, 15.4735, 2000, CAMERA_MOVE);
            InterpolateCameraLookAt(playerid, 434.0650, -1301.1581, 17.5145, 436.5263, -1300.8302, 15.2985, 2000, CAMERA_MOVE);
       }
        case 7:
        {
            InterpolateCameraPos(playerid, 437.3644, -1301.3735, 15.4735, 437.6285, -1305.2942, 15.9692, 2000, CAMERA_MOVE);
            InterpolateCameraLookAt(playerid, 436.5263, -1300.8302, 15.2985, 437.0403, -1304.4867, 15.7142, 2000, CAMERA_MOVE);
       }
        case 8:
        {
            InterpolateCameraPos(playerid, 437.6285, -1305.2942, 15.9692, 434.1383, -1293.2971, 19.6626, 2000, CAMERA_MOVE);
            InterpolateCameraLookAt(playerid, 437.0403, -1304.4867, 15.7142, 434.1313, -1294.2961, 18.7776, 2000, CAMERA_MOVE);
       }
        case 9:
        {
            InterpolateCameraPos(playerid, 434.1383, -1293.2971, 19.6626, 438.7916, -1299.0066, 15.9129, 2000, CAMERA_MOVE);
            InterpolateCameraLookAt(playerid, 434.1313, -1294.2961, 18.7776, 437.7929, -1299.0272, 15.7329, 2000, CAMERA_MOVE);
       }
        case 10:
        {
            InterpolateCameraPos(playerid, 438.7916, -1299.0066, 15.9129, 433.8757, -1306.9038, 17.3670, 2000, CAMERA_MOVE);
            InterpolateCameraLookAt(playerid, 437.7929, -1299.0272, 15.7329, 433.8736, -1305.9052, 16.9670, 2000, CAMERA_MOVE);
       }
        default: return 0;
   }

    return 1;
}
