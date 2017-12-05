#if defined _evi_included
   #endinput
 #endif
 #define _evi_included
 
 #include <a_samp>

#if !defined IsValidVehicle
    native IsValidVehicle(vehicleid);
#endif

 enum modelFlags (<<= 1)
 {
   MFLAG_IS_VAN = 1,
   MFLAG_IS_BUS,
   MFLAG_IS_LOW,
   MFLAG_IS_BIG,
   MFLAG_REVERSE_BONNET,
   MFLAG_HANGING_BOOT,
   MFLAG_TAILGATE_BOOT,
   MFLAG_NOSWING_BOOT,
   MFLAG_NO_DOORS,
   MFLAG_TANDEM_SEATS,
   MFLAG_SIT_IN_BOAT,
   MFLAG_CONVERTIBLE,
   MFLAG_NO_EXHAUST,
   MFLAG_DOUBLE_EXHAUST,
   MFLAG_NO1FPS_LOOK_BEHIND,
   MFLAG_FORCE_DOOR_CHECK,
   MFLAG_AXLE_F_NOTILT,
   MFLAG_AXLE_F_SOLID,
   MFLAG_AXLE_F_MCPHERSON,
   MFLAG_AXLE_F_REVERSE,
   MFLAG_AXLE_R_NOTILT,
   MFLAG_AXLE_R_SOLID,
   MFLAG_AXLE_R_MCPHERSON,
   MFLAG_AXLE_R_REVERSE,
   MFLAG_IS_BIKE,
   MFLAG_IS_HELI,
   MFLAG_IS_PLANE,
   MFLAG_IS_BOAT,
   MFLAG_BOUNCE_PANELS,
   MFLAG_DOUBLE_RWHEELS,
   MFLAG_FORCE_GROUND_CLEARANCE,
   MFLAG_IS_HATCHBACK
 };
 
 enum handlingFlags (<<= 1)
 {
   HFLAG_1G_BOOST = 1,
   HFLAG_2G_BOOST,
   HFLAG_NPC_ANTI_ROLL,
   HFLAG_NPC_NEUTRAL_HANDL,
   HFLAG_NO_HANDBRAKE,
   HFLAG_STEER_REARWHEELS,
   HFLAG_HB_REARWHEEL_STEER,
   HFLAG_ALT_STEER_OPT,
   HFLAG_WHEEL_F_NARROW2,
   HFLAG_WHEEL_F_NARROW,
   HFLAG_WHEEL_F_WIDE,
   HFLAG_WHEEL_F_WIDE2,
   HFLAG_WHEEL_R_NARROW2,
   HFLAG_WHEEL_R_NARROW,
   HFLAG_WHEEL_R_WIDE,
   HFLAG_WHEEL_R_WIDE2,
   HFLAG_HYDRAULIC_GEOM,
   HFLAG_HYDRAULIC_INST,
   HFLAG_HYDRAULIC_NONE,
   HFLAG_NOS_INST,
   HFLAG_OFFROAD_ABILITY,
   HFLAG_OFFROAD_ABILITY2,
   HFLAG_HALOGEN_LIGHTS,
   HFLAG_PROC_REARWHEEL_1ST,
   HFLAG_USE_MAXSP_LIMIT,
   HFLAG_LOW_RIDER,
   HFLAG_STREET_RACER,
   HFLAG_UNUSED_FLAG, // Unused in data files. Required for continuity. Do not remove.
   HFLAG_SWINGING_CHASSIS
 }
 
 // -----------------------------------------------------------------------------
 
 static DB:dbfile;
 
 public OnGameModeInit()
 {
   dbfile = db_open("handling.db");
   if (funcidx("evi_OnGameModeInit") != -1)
   {
     return CallLocalFunction("evi_OnGameModeInit", "");
   }
   return 1;
 }
 
 public OnGameModeExit()
 {
   db_close(dbfile);
   if (funcidx("evi_OnGameModeExit") != -1)
   {
     return CallLocalFunction("evi_OnGameModeExit", "");
   }
   return 1;
 }
 
 public OnFilterScriptInit()
 {
   dbfile = db_open("handling.db");
   if (funcidx("evi_OnFilterScriptInit") != -1)
   {
     return CallLocalFunction("evi_OnFilterScriptInit", "");
   }
   return 1;
 }
 
 public OnFilterScriptExit()
 {
   db_close(dbfile);
   if (funcidx("evi_OnFilterScriptExit") != -1)
   {
     return CallLocalFunction("evi_OnFilterScriptExit", "");
   }
   return 1;
 }
 
 #if defined _ALS_OnGameModeInit
   #undef OnGameModeInit
 #else
   #define _ALS_OnGameModeInit
 #endif
 #define OnGameModeInit evi_OnGameModeInit
 
 #if defined _ALS_OnGameModeExit
   #undef OnGameModeExit
 #else
   #define _ALS_OnGameModeExit
 #endif
 #define OnGameModeExit evi_OnGameModeExit
 
 #if defined _ALS_OnFilterScriptInit
   #undef OnFilterScriptInit
 #else
   #define _ALS_OnFilterScriptInit
 #endif
 #define OnFilterScriptInit evi_OnFilterScriptInit
 
 #if defined _ALS_OnFilterScriptExit
   #undef OnFilterScriptExit
 #else
   #define _ALS_OnFilterScriptExit
 #endif
 #define OnFilterScriptExit evi_OnFilterScriptExit
 
 forward evi_OnGameModeInit();
 forward evi_OnGameModeExit();
 forward evi_OnFilterScriptInit();
 forward evi_OnFilterScriptExit();
 
 forward GetVehicleModelInfoAsInt(vehiclemodel, infotype[]);
 forward Float:GetVehicleModelInfoAsFloat(vehiclemodel, infotype[]);
 forward GetVehicleModelFlag(vehiclemodel, modelFlags:flag);
 forward GetVehicleHandlingFlag(vehiclemodel, handlingFlags:flag);
 
 public GetVehicleModelInfoAsInt(vehiclemodel, infotype[])
 {
   new
       sqlquery[80],
       DBResult:qresult;
 
   format(sqlquery, sizeof(sqlquery), "SELECT `%q` FROM `vehicle_main` WHERE `id` = %d", infotype, vehiclemodel);
   qresult = db_query(dbfile, sqlquery);
   
   db_get_field(qresult, 0, sqlquery, sizeof(sqlquery));
   db_free_result(qresult);
   
   if(strfind(infotype, "DriveType", true) != -1 || strfind(infotype, "EngineType", true) != -1) // saved as characters
       return sqlquery[0];
 
   return strval(sqlquery);
 }
 
 public Float:GetVehicleModelInfoAsFloat(vehiclemodel, infotype[])
 {
   new
       sqlquery[100],
       DBResult:qresult;
 
   format(sqlquery, sizeof(sqlquery), "SELECT `%q` FROM `vehicle_main` WHERE `id` = %d", infotype, vehiclemodel);
   qresult = db_query(dbfile, sqlquery);
 
   db_get_field(qresult, 0, sqlquery, sizeof(sqlquery));
   db_free_result(qresult);
 
   return floatstr(sqlquery);
 }
 
 public GetVehicleModelFlag(vehiclemodel, modelFlags:flag)
 {
   new
       query[100],
       DBResult:qresult,
       value;
       
   format(query, sizeof(query), "SELECT nModelFlags FROM vehicle_main WHERE id = %d AND nModelFlags & %d;", vehiclemodel, flag);
   qresult = db_query(dbfile, query);
   
   value = db_num_rows(qresult);
   db_free_result(qresult);
   
   return value;
 }
 
 public GetVehicleHandlingFlag(vehiclemodel, handlingFlags:flag)
 {
   new
       query[100],
       DBResult:qresult,
       value;
 
   format(query, sizeof(query), "SELECT nHandlingFlags FROM vehicle_main WHERE id = %d AND nHandlingFlags & %d;", vehiclemodel, flag);
   qresult = db_query(dbfile, query);
 
   value = db_num_rows(qresult);
   db_free_result(qresult);
 
   return value;
 }
 
 
 