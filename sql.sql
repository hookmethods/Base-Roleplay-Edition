# Host: localhost  (Version: 5.5.53)
# Date: 2017-10-23 17:12:20
# Generator: MySQL-Front 5.3  (Build 4.234)

/*!40101 SET NAMES utf8 */;

#
# Structure for table "ajail_logs"
#

DROP TABLE IF EXISTS `ajail_logs`;
CREATE TABLE `ajail_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `JailedDBID` int(11) NOT NULL,
  `JailedName` varchar(32) NOT NULL,
  `Reason` varchar(128) NOT NULL,
  `Date` varchar(90) NOT NULL,
  `JailedBy` varchar(32) NOT NULL,
  `Time` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

#
# Structure for table "ban_logs"
#

DROP TABLE IF EXISTS `ban_logs`;
CREATE TABLE `ban_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `CharacterDBID` int(11) NOT NULL,
  `MasterDBID` int(11) NOT NULL,
  `CharacterName` varchar(32) NOT NULL,
  `Reason` varchar(128) NOT NULL,
  `BannedBy` varchar(32) NOT NULL,
  `Date` varchar(90) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

#
# Structure for table "bannedlist"
#

DROP TABLE IF EXISTS `bannedlist`;
CREATE TABLE `bannedlist` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `CharacterDBID` int(11) NOT NULL,
  `MasterDBID` int(11) NOT NULL,
  `CharacterName` varchar(32) NOT NULL,
  `Reason` varchar(128) NOT NULL,
  `Date` varchar(90) NOT NULL,
  `BannedBy` varchar(32) NOT NULL,
  `IpAddress` varchar(60) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

#
# Structure for table "businesses"
#

DROP TABLE IF EXISTS `businesses`;
CREATE TABLE `businesses` (
  `BusinessDBID` int(11) NOT NULL AUTO_INCREMENT,
  `BusinessOwnerDBID` int(11) NOT NULL DEFAULT '0',
  `BusinessInteriorX` float NOT NULL,
  `BusinessInteriorY` float NOT NULL,
  `BusinessInteriorZ` float NOT NULL,
  `BusinessInteriorWorld` int(11) NOT NULL,
  `BusinessInteriorIntID` int(11) NOT NULL,
  `BusinessEntranceX` float NOT NULL,
  `BusinessEntranceY` float NOT NULL,
  `BusinessEntranceZ` float NOT NULL,
  `BusinessName` varchar(90) NOT NULL DEFAULT 'Nameless',
  `BusinessType` int(11) NOT NULL DEFAULT '0',
  `BusinessLocked` tinyint(1) NOT NULL DEFAULT '0',
  `BusinessEntranceFee` int(11) NOT NULL DEFAULT '1',
  `BusinessLevel` int(11) NOT NULL,
  `BusinessMarketPrice` int(11) NOT NULL DEFAULT '5000',
  `BusinessCashbox` int(11) NOT NULL DEFAULT '0',
  `BusinessProducts` int(11) NOT NULL DEFAULT '0',
  `BusinessBankPickupLocX` float NOT NULL,
  `BusinessBankPickupLocY` float NOT NULL,
  `BusinessBankPickupLocZ` float NOT NULL,
  `BusinessBankPickupWorld` int(11) NOT NULL,
  `RType` int(4) NOT NULL DEFAULT '0',
  `Food1` int(11) NOT NULL DEFAULT '0',
  `Food2` int(11) NOT NULL DEFAULT '1',
  `Food3` int(11) NOT NULL DEFAULT '2',
  `Price1` int(11) NOT NULL DEFAULT '150',
  `Price2` int(11) NOT NULL DEFAULT '350',
  `Price3` int(11) NOT NULL DEFAULT '500',
  PRIMARY KEY (`BusinessDBID`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=latin1;

#
# Structure for table "characters"
#

DROP TABLE IF EXISTS `characters`;
CREATE TABLE `characters` (
  `master_dbid` int(11) NOT NULL,
  `char_dbid` int(11) NOT NULL AUTO_INCREMENT,
  `char_name` varchar(32) NOT NULL,
  `create_date` varchar(60) NOT NULL,
  `create_ip` varchar(60) NOT NULL,
  `pAdmin` int(4) NOT NULL DEFAULT '0',
  `pLastSkin` int(11) NOT NULL DEFAULT '264',
  `pLastPosX` float NOT NULL DEFAULT '1642.02',
  `pLastPosY` float NOT NULL DEFAULT '-2334.05',
  `pLastPosZ` float NOT NULL DEFAULT '13.5469',
  `pLastInterior` int(11) NOT NULL DEFAULT '0',
  `pLastWorld` int(11) NOT NULL DEFAULT '0',
  `pLevel` int(11) NOT NULL DEFAULT '1',
  `pEXP` int(11) NOT NULL DEFAULT '0',
  `pAge` varchar(20) NOT NULL DEFAULT 'Invalid',
  `pOrigin` varchar(60) NOT NULL DEFAULT 'Invalid',
  `pStory` varchar(90) NOT NULL DEFAULT 'Nothing',
  `pStoryTwo` varchar(90) NOT NULL DEFAULT 'Nothing',
  `pMoney` int(11) NOT NULL DEFAULT '5000',
  `pBank` int(11) NOT NULL DEFAULT '15000',
  `pPaycheck` int(11) NOT NULL DEFAULT '5000',
  `pPhone` int(11) NOT NULL,
  `pLastOnline` varchar(90) NOT NULL,
  `pLastOnlineTime` int(11) NOT NULL,
  `pAdminjailed` tinyint(1) NOT NULL,
  `pAdminjailTime` int(11) NOT NULL,
  `pOfflinejailed` tinyint(1) NOT NULL DEFAULT '0',
  `pOfflinejailedReason` varchar(128) NOT NULL,
  `pFaction` int(11) NOT NULL DEFAULT '0',
  `pFactionRank` int(11) NOT NULL DEFAULT '0',
  `pOwnedVehicles1` int(11) NOT NULL DEFAULT '0',
  `pOwnedVehicles2` int(11) NOT NULL DEFAULT '0',
  `pOwnedVehicles3` int(11) NOT NULL DEFAULT '0',
  `pOwnedVehicles4` int(11) NOT NULL DEFAULT '0',
  `pOwnedVehicles5` int(11) NOT NULL DEFAULT '0',
  `pVehicleSpawned` tinyint(1) NOT NULL DEFAULT '0',
  `pVehicleSpawnedID` int(11) NOT NULL DEFAULT '0',
  `pWeapons0` tinyint(4) NOT NULL DEFAULT '0',
  `pWeapons1` tinyint(4) NOT NULL DEFAULT '0',
  `pWeapons2` tinyint(4) NOT NULL DEFAULT '0',
  `pWeapons3` tinyint(4) NOT NULL DEFAULT '0',
  `pWeaponsAmmo0` smallint(6) NOT NULL DEFAULT '0',
  `pWeaponsAmmo1` smallint(6) NOT NULL DEFAULT '0',
  `pWeaponsAmmo2` smallint(6) NOT NULL DEFAULT '0',
  `pWeaponsAmmo3` smallint(6) NOT NULL DEFAULT '0',
  `pTimeplayed` int(11) NOT NULL DEFAULT '0',
  `pMaskID` int(11) NOT NULL,
  `pMaskIDEx` int(11) NOT NULL,
  `pInProperty` int(11) NOT NULL DEFAULT '0',
  `pInBusiness` int(11) NOT NULL DEFAULT '0',
  `pHasRadio` tinyint(1) NOT NULL DEFAULT '0',
  `pRadio1` int(11) NOT NULL DEFAULT '0',
  `pRadio2` int(11) NOT NULL DEFAULT '0',
  `pMainSlot` int(11) NOT NULL DEFAULT '1',
  `pGascan` int(11) NOT NULL DEFAULT '0',
  `pSpawnPoint` int(11) NOT NULL DEFAULT '0',
  `pSpawnPointHouse` int(11) NOT NULL DEFAULT '0',
  `pWeaponsLicense` int(11) NOT NULL DEFAULT '0',
  `pDriversLicense` int(11) NOT NULL DEFAULT '0',
  `pActiveListings` int(11) NOT NULL DEFAULT '0',
  `pPrisonTimes` int(11) NOT NULL DEFAULT '0',
  `pJailTimes` int(11) NOT NULL DEFAULT '0',
  `Donator` int(4) NOT NULL DEFAULT '0',
  `Walk_style` int(4) NOT NULL DEFAULT '0',
  `Chat_style` int(4) NOT NULL DEFAULT '0',
  `Hud_style` int(4) NOT NULL DEFAULT '1',
  `PhonePower` int(11) NOT NULL DEFAULT '10000',
  `Job` int(4) NOT NULL DEFAULT '0',
  `Career` int(4) NOT NULL DEFAULT '0',
  `SideJob` int(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`char_dbid`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

#
# Structure for table "chopshop"
#

DROP TABLE IF EXISTS `chopshop`;
CREATE TABLE `chopshop` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `money` int(11) DEFAULT NULL,
  `offsetX` float DEFAULT NULL,
  `offsetY` float DEFAULT NULL,
  `offsetZ` float DEFAULT NULL,
  `rotX` float DEFAULT NULL,
  `rotY` float DEFAULT NULL,
  `rotZ` float DEFAULT NULL,
  `faction` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=11 DEFAULT CHARSET=utf8 ROW_FORMAT=FIXED;

#
# Structure for table "criminal_record"
#

DROP TABLE IF EXISTS `criminal_record`;
CREATE TABLE `criminal_record` (
  `idx` int(11) NOT NULL AUTO_INCREMENT,
  `player_name` varchar(32) NOT NULL,
  `charge_reason` varchar(128) NOT NULL,
  `add_date` varchar(90) NOT NULL,
  PRIMARY KEY (`idx`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

#
# Structure for table "faction_ranks"
#

DROP TABLE IF EXISTS `faction_ranks`;
CREATE TABLE `faction_ranks` (
  `factionid` int(11) NOT NULL AUTO_INCREMENT,
  `FactionRank1` varchar(60) NOT NULL DEFAULT 'NotSet',
  `FactionRank2` varchar(60) NOT NULL DEFAULT 'NotSet',
  `FactionRank3` varchar(60) NOT NULL DEFAULT 'NotSet',
  `FactionRank4` varchar(60) NOT NULL DEFAULT 'NotSet',
  `FactionRank5` varchar(60) NOT NULL DEFAULT 'NotSet',
  `FactionRank6` varchar(60) NOT NULL DEFAULT 'NotSet',
  `FactionRank7` varchar(60) NOT NULL DEFAULT 'NotSet',
  `FactionRank8` varchar(60) NOT NULL DEFAULT 'NotSet',
  `FactionRank9` varchar(60) NOT NULL DEFAULT 'NotSet',
  `FactionRank10` varchar(60) NOT NULL DEFAULT 'NotSet',
  `FactionRank11` varchar(60) NOT NULL DEFAULT 'NotSet',
  `FactionRank12` varchar(60) NOT NULL DEFAULT 'NotSet',
  `FactionRank13` varchar(60) NOT NULL DEFAULT 'NotSet',
  `FactionRank14` varchar(60) NOT NULL DEFAULT 'NotSet',
  `FactionRank15` varchar(60) NOT NULL DEFAULT 'NotSet',
  `FactionRank16` varchar(60) NOT NULL DEFAULT 'NotSet',
  `FactionRank17` varchar(60) NOT NULL DEFAULT 'NotSet',
  `FactionRank18` varchar(60) NOT NULL DEFAULT 'NotSet',
  `FactionRank19` varchar(60) NOT NULL DEFAULT 'NotSet',
  `FactionRank20` varchar(60) NOT NULL DEFAULT 'NotSet',
  PRIMARY KEY (`factionid`),
  UNIQUE KEY `factionid` (`factionid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

#
# Structure for table "factions"
#

DROP TABLE IF EXISTS `factions`;
CREATE TABLE `factions` (
  `DBID` int(11) NOT NULL AUTO_INCREMENT,
  `FactionName` varchar(90) NOT NULL,
  `FactionAbbrev` varchar(30) NOT NULL,
  `FactionSpawnX` float NOT NULL,
  `FactionSpawnY` float NOT NULL,
  `FactionSpawnZ` float NOT NULL,
  `FactionInterior` int(11) NOT NULL DEFAULT '0',
  `FactionWorld` int(11) NOT NULL DEFAULT '0',
  `FactionJoinRank` int(11) NOT NULL,
  `FactionAlterRank` int(11) NOT NULL,
  `FactionChatRank` int(11) NOT NULL,
  `FactionTowRank` int(11) NOT NULL,
  `FactionChatColor` int(11) NOT NULL,
  `FactionType` tinyint(4) NOT NULL,
  PRIMARY KEY (`DBID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

#
# Structure for table "kick_logs"
#

DROP TABLE IF EXISTS `kick_logs`;
CREATE TABLE `kick_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `KickedDBID` int(11) NOT NULL,
  `KickedName` varchar(32) NOT NULL,
  `Reason` varchar(128) NOT NULL,
  `KickedBy` varchar(32) NOT NULL,
  `Date` varchar(90) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

#
# Structure for table "masters"
#

DROP TABLE IF EXISTS `masters`;
CREATE TABLE `masters` (
  `acc_dbid` int(11) NOT NULL AUTO_INCREMENT,
  `acc_name` varchar(32) NOT NULL,
  `acc_pass` varchar(128) NOT NULL,
  `secret_word` varchar(128) NOT NULL,
  `forum_name` varchar(60) NOT NULL DEFAULT 'Null',
  `register_date` varchar(90) NOT NULL,
  `register_ip` varchar(60) NOT NULL,
  `active_ip` varchar(60) NOT NULL,
  PRIMARY KEY (`acc_dbid`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

#
# Structure for table "payphone"
#

DROP TABLE IF EXISTS `payphone`;
CREATE TABLE `payphone` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `offsetX` float DEFAULT NULL,
  `offsetY` float DEFAULT NULL,
  `offsetZ` float DEFAULT NULL,
  `rotX` float DEFAULT NULL,
  `rotY` float DEFAULT NULL,
  `rotZ` float DEFAULT NULL,
  `coin` int(11) NOT NULL DEFAULT '0',
  `code` int(11) NOT NULL DEFAULT '999',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 ROW_FORMAT=FIXED;

#
# Structure for table "properties"
#

DROP TABLE IF EXISTS `properties`;
CREATE TABLE `properties` (
  `PropertyDBID` int(11) NOT NULL AUTO_INCREMENT,
  `PropertyOwnerDBID` int(11) NOT NULL DEFAULT '0',
  `PropertyType` int(11) NOT NULL,
  `PropertyFaction` int(11) NOT NULL DEFAULT '0',
  `PropertyEntranceX` float NOT NULL,
  `PropertyEntranceY` float NOT NULL,
  `PropertyEntranceZ` float NOT NULL,
  `PropertyEntranceInterior` int(11) NOT NULL,
  `PropertyEntranceWorld` int(11) NOT NULL,
  `PropertyInteriorX` int(11) NOT NULL,
  `PropertyInteriorY` int(11) NOT NULL,
  `PropertyInteriorZ` int(11) NOT NULL,
  `PropertyInteriorIntID` int(11) NOT NULL,
  `PropertyInteriorWorld` int(11) NOT NULL,
  `PropertyMarketPrice` int(11) NOT NULL DEFAULT '1000',
  `PropertyLevel` int(11) NOT NULL DEFAULT '1',
  `PropertyLocked` tinyint(1) NOT NULL DEFAULT '0',
  `PropertyCashbox` int(11) NOT NULL DEFAULT '0',
  `PropertyPlacePosX` float NOT NULL,
  `PropertyPlacePosY` float NOT NULL,
  `PropertyPlacePosZ` float NOT NULL,
  `PropertyWeapon1` int(11) NOT NULL DEFAULT '0',
  `PropertyWeapon2` int(11) NOT NULL DEFAULT '0',
  `PropertyWeapon3` int(11) NOT NULL DEFAULT '0',
  `PropertyWeapon4` int(11) NOT NULL DEFAULT '0',
  `PropertyWeapon5` int(11) NOT NULL DEFAULT '0',
  `PropertyWeapon6` int(11) NOT NULL DEFAULT '0',
  `PropertyWeapon7` int(11) NOT NULL DEFAULT '0',
  `PropertyWeapon8` int(11) NOT NULL DEFAULT '0',
  `PropertyWeapon9` int(11) NOT NULL DEFAULT '0',
  `PropertyWeapon10` int(11) NOT NULL DEFAULT '0',
  `PropertyWeapon11` int(11) NOT NULL DEFAULT '0',
  `PropertyWeapon12` int(11) NOT NULL DEFAULT '0',
  `PropertyWeapon13` int(11) NOT NULL DEFAULT '0',
  `PropertyWeapon14` int(11) NOT NULL DEFAULT '0',
  `PropertyWeapon15` int(11) NOT NULL DEFAULT '0',
  `PropertyWeapon16` int(11) NOT NULL DEFAULT '0',
  `PropertyWeapon17` int(11) NOT NULL DEFAULT '0',
  `PropertyWeapon18` int(11) NOT NULL DEFAULT '0',
  `PropertyWeapon19` int(11) NOT NULL DEFAULT '0',
  `PropertyWeapon20` int(11) NOT NULL DEFAULT '0',
  `PropertyWeaponAmmo1` int(11) NOT NULL DEFAULT '0',
  `PropertyWeaponAmmo2` int(11) NOT NULL DEFAULT '0',
  `PropertyWeaponAmmo3` int(11) NOT NULL DEFAULT '0',
  `PropertyWeaponAmmo4` int(11) NOT NULL DEFAULT '0',
  `PropertyWeaponAmmo5` int(11) NOT NULL DEFAULT '0',
  `PropertyWeaponAmmo6` int(11) NOT NULL DEFAULT '0',
  `PropertyWeaponAmmo7` int(11) NOT NULL DEFAULT '0',
  `PropertyWeaponAmmo8` int(11) NOT NULL DEFAULT '0',
  `PropertyWeaponAmmo9` int(11) NOT NULL DEFAULT '0',
  `PropertyWeaponAmmo10` int(11) NOT NULL DEFAULT '0',
  `PropertyWeaponAmmo11` int(11) NOT NULL DEFAULT '0',
  `PropertyWeaponAmmo12` int(11) NOT NULL DEFAULT '0',
  `PropertyWeaponAmmo13` int(11) NOT NULL DEFAULT '0',
  `PropertyWeaponAmmo14` int(11) NOT NULL DEFAULT '0',
  `PropertyWeaponAmmo15` int(11) NOT NULL DEFAULT '0',
  `PropertyWeaponAmmo16` int(11) NOT NULL DEFAULT '0',
  `PropertyWeaponAmmo17` int(11) NOT NULL DEFAULT '0',
  `PropertyWeaponAmmo18` int(11) NOT NULL DEFAULT '0',
  `PropertyWeaponAmmo19` int(11) NOT NULL DEFAULT '0',
  `PropertyWeaponAmmo20` int(11) NOT NULL DEFAULT '0',
  `PropertyHasBoombox` tinyint(1) NOT NULL DEFAULT '0',
  `PropertyBoomboxPosX` float NOT NULL,
  `PropertyBoomboxPosY` float NOT NULL,
  `PropertyBoomboxPosZ` float NOT NULL,
  `PropertyBoomboxRotX` float NOT NULL,
  `PropertyBoomboxRotY` float NOT NULL,
  `PropertyBoomboxRotZ` float NOT NULL,
  `PropertyAlarm` int(4) NOT NULL DEFAULT '1',
  PRIMARY KEY (`PropertyDBID`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

#
# Structure for table "spray_tag"
#

DROP TABLE IF EXISTS `spray_tag`;
CREATE TABLE `spray_tag` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `modelid` int(11) DEFAULT NULL,
  `offsetX` float DEFAULT NULL,
  `offsetY` float DEFAULT NULL,
  `offsetZ` float DEFAULT NULL,
  `rotX` float DEFAULT NULL,
  `rotY` float DEFAULT NULL,
  `rotZ` float DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;

#
# Structure for table "street_data"
#

DROP TABLE IF EXISTS `street_data`;
CREATE TABLE `street_data` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(28) DEFAULT NULL,
  `circleX` float DEFAULT NULL,
  `circleY` float DEFAULT NULL,
  `size` float DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;

#
# Structure for table "vehicle_trunk"
#

DROP TABLE IF EXISTS `vehicle_trunk`;
CREATE TABLE `vehicle_trunk` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `weapon` int(4) DEFAULT NULL,
  `ammo` int(4) DEFAULT NULL,
  `vehicle` int(11) DEFAULT NULL,
  `offsetX` float NOT NULL DEFAULT '0',
  `offsetY` float NOT NULL DEFAULT '0',
  `offsetZ` float NOT NULL DEFAULT '0',
  `rotX` float NOT NULL DEFAULT '0',
  `rotY` float NOT NULL DEFAULT '0',
  `rotZ` float NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

#
# Structure for table "vehicles"
#

DROP TABLE IF EXISTS `vehicles`;
CREATE TABLE `vehicles` (
  `VehicleDBID` int(11) NOT NULL AUTO_INCREMENT,
  `VehicleOwnerDBID` int(11) NOT NULL,
  `VehicleFaction` int(11) NOT NULL DEFAULT '0',
  `VehicleModel` int(11) NOT NULL,
  `VehicleColor1` int(11) NOT NULL DEFAULT '0',
  `VehicleColor2` int(11) NOT NULL DEFAULT '0',
  `VehiclePaintjob` int(11) NOT NULL DEFAULT '-1',
  `VehicleParkPosX` float NOT NULL,
  `VehicleParkPosY` float NOT NULL,
  `VehicleParkPosZ` float NOT NULL,
  `VehicleParkPosA` float NOT NULL,
  `VehicleParkInterior` int(11) NOT NULL DEFAULT '0',
  `VehicleParkWorld` int(11) NOT NULL DEFAULT '0',
  `VehiclePlates` varchar(32) NOT NULL,
  `VehicleLocked` int(11) NOT NULL,
  `VehicleImpounded` tinyint(1) NOT NULL DEFAULT '0',
  `VehicleImpoundPosX` float NOT NULL,
  `VehicleImpoundPosY` float NOT NULL,
  `VehicleImpoundPosZ` float NOT NULL,
  `VehicleImpoundPosA` float NOT NULL,
  `VehicleSirens` int(11) NOT NULL DEFAULT '0',
  `VehicleFuel` float NOT NULL DEFAULT '100',
  `VehicleWeapons1` int(11) NOT NULL DEFAULT '0',
  `VehicleWeapons2` int(11) NOT NULL DEFAULT '0',
  `VehicleWeapons3` int(11) NOT NULL DEFAULT '0',
  `VehicleWeapons4` int(11) NOT NULL DEFAULT '0',
  `VehicleWeapons5` int(11) NOT NULL DEFAULT '0',
  `VehicleWeaponsAmmo1` int(11) NOT NULL DEFAULT '0',
  `VehicleWeaponsAmmo2` int(11) NOT NULL DEFAULT '0',
  `VehicleWeaponsAmmo3` int(11) NOT NULL DEFAULT '0',
  `VehicleWeaponsAmmo4` int(11) NOT NULL DEFAULT '0',
  `VehicleWeaponsAmmo5` int(11) NOT NULL DEFAULT '0',
  `VehicleLastDrivers1` int(11) NOT NULL DEFAULT '0',
  `VehicleLastDrivers2` int(11) NOT NULL DEFAULT '0',
  `VehicleLastDrivers3` int(11) NOT NULL DEFAULT '0',
  `VehicleLastDrivers4` int(11) NOT NULL DEFAULT '0',
  `VehicleLastPassengers1` int(11) NOT NULL DEFAULT '0',
  `VehicleLastPassengers2` int(11) NOT NULL DEFAULT '0',
  `VehicleLastPassengers3` int(11) NOT NULL DEFAULT '0',
  `VehicleLastPassengers4` int(11) NOT NULL DEFAULT '0',
  `VehicleBattery` float NOT NULL DEFAULT '100',
  `VehicleEngine` float NOT NULL DEFAULT '100',
  `VehicleTimesDestroyed` int(11) NOT NULL DEFAULT '0',
  `VehicleXMR` tinyint(1) NOT NULL DEFAULT '0',
  `VehicleAlarmLevel` int(11) NOT NULL DEFAULT '0',
  `VehicleLockLevel` int(11) NOT NULL DEFAULT '0',
  `VehicleImmobLevel` int(11) NOT NULL DEFAULT '1',
  `VehicleHealth` float NOT NULL DEFAULT '900',
  `Insurance` int(11) NOT NULL DEFAULT '0',
  `InsBill` int(11) NOT NULL DEFAULT '0',
  `InsTime` int(11) NOT NULL DEFAULT '0',
  `Mileage` float NOT NULL DEFAULT '0.1',
  `DamageStatus0` int(11) NOT NULL DEFAULT '0',
  `DamageStatus1` int(11) NOT NULL DEFAULT '0',
  `DamageStatus2` int(11) NOT NULL DEFAULT '0',
  `DamageStatus3` int(11) NOT NULL DEFAULT '0',
  `DamageStatus4` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`VehicleDBID`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;

#
# Structure for table "weaponsettings"
#

DROP TABLE IF EXISTS `weaponsettings`;
CREATE TABLE `weaponsettings` (
  `Name` varchar(24) NOT NULL,
  `WeaponID` tinyint(4) NOT NULL,
  `PosX` float DEFAULT '-0.116',
  `PosY` float DEFAULT '0.189',
  `PosZ` float DEFAULT '0.088',
  `RotX` float DEFAULT '0',
  `RotY` float DEFAULT '44.5',
  `RotZ` float DEFAULT '0',
  `Bone` tinyint(4) NOT NULL DEFAULT '1',
  `Hidden` tinyint(4) NOT NULL DEFAULT '0',
  UNIQUE KEY `weapon` (`Name`,`WeaponID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

#
# Structure for table "xmr_categories"
#

DROP TABLE IF EXISTS `xmr_categories`;
CREATE TABLE `xmr_categories` (
  `XMRDBID` int(11) NOT NULL AUTO_INCREMENT,
  `XMRCategoryName` varchar(90) NOT NULL,
  PRIMARY KEY (`XMRDBID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

#
# Structure for table "xmr_stations"
#

DROP TABLE IF EXISTS `xmr_stations`;
CREATE TABLE `xmr_stations` (
  `XMRStationDBID` int(11) NOT NULL AUTO_INCREMENT,
  `XMRCategory` int(11) NOT NULL,
  `XMRStationName` varchar(90) NOT NULL,
  `XMRStationURL` varchar(128) NOT NULL,
  PRIMARY KEY (`XMRStationDBID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
