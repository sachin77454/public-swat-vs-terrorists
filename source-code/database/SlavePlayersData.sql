-- phpMyAdmin SQL Dump
-- version 4.8.3
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Aug 02, 2019 at 03:31 AM
-- Server version: 10.1.35-MariaDB
-- PHP Version: 7.2.9

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `zahmedh2o19990`
--

-- --------------------------------------------------------

--
-- Table structure for table `SlavePlayersData`
--


CREATE TABLE `SlavePlayersData` (
  `sID` int(16) UNSIGNED NOT NULL,
  `pID` int(16) UNSIGNED NOT NULL,
  `Score` mediumint(10) UNSIGNED NOT NULL DEFAULT '0',
  `Cash` int(11) NOT NULL DEFAULT '0',
  `Kills` int(11) UNSIGNED NOT NULL DEFAULT '0',
  `Deaths` int(11) UNSIGNED NOT NULL DEFAULT '0',
  `GunFires` int(10) NOT NULL DEFAULT '0',
  `IsJailed` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `JailTime` mediumint(5) UNSIGNED NOT NULL DEFAULT '0',
  `Headshots` int(11) UNSIGNED NOT NULL DEFAULT '0',
  `Nutshots` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `KnifeKills` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `RevengeTakes` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `JackpotsFound` smallint(5) UNSIGNED NOT NULL DEFAULT '0',
  `DeathmatchKills` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `RustlerRockets` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `RustlerRocketsHit` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `DuelsWon` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `DuelsLost` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `MedkitsUsed` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `ArmourkitsUsed` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `SupportAttempts` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `EXP` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `KillAssists` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `CaptureAssists` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `HighestKillStreak` smallint(5) UNSIGNED NOT NULL DEFAULT '0',
  `SawedKills` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `AirRocketsFired` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `AntiAirRocketsFired` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `CarePackagesDropped` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `FavWeap` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `FavWeap2` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `FavWeap3` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `DamageRate` float UNSIGNED NOT NULL DEFAULT '0',
  `HealthLost` float UNSIGNED NOT NULL DEFAULT '0',
  `SMGKills` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `ShotgunKills` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `HeavyKills` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `MeleeKills` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `PistolKills` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `FistKills` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `CloseKills` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `DriversStabbed` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `SpiesEliminated` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `KillsAsSpy` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `LongDistanceKills` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `WeaponsDropped` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `WeaponsPicked` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `EventsWon` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `RacesWon` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `ItemsUsed` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `FavSkin` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `FavTeam` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `SuicideAttempts` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `PlayersHealed` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `CommandsUsed` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `CommandsFailed` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `UnauthorizedActions` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `RCONLogins` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `RCONFailedAttempts` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `ClassAbilitiesUsed` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `DronesExploded` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `HealthGained` float NOT NULL DEFAULT '0',
  `ZonesCaptured` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `InteriorsEntered` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `InteriorsExitted` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `PickupsPicked` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `HousesPurchased` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `QuestionsAsked` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `QuestionsAnswered` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `CrashTimes` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `SAMPClient` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `BackupAttempts` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `BackupsResponded` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `BaseRapeAttempts` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `CBugAttempts` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `ChatMessagesSent` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `MoneySent` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `MoneyReceived` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `HighestBet` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `DuelRequests` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `DuelsAccepted` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `DuelsRefusedByPlayer` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `DuelsRefusedByOthers` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `BountyAmount` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `BountyCashSpent` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `CoinsSpent` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `PaymentsAccepted` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `ClanKills` int(10) UNSIGNED NOT NULL DEFAULT '0',
  `ClanDeaths` int(10) UNSIGNED NOT NULL DEFAULT '0',
  `AchsUnlocked` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `HighestCaptures` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `KicksByAdmin` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `LongestKillDistance` float NOT NULL DEFAULT '0',
  `NearestKillDistance` float NOT NULL DEFAULT '0',
  `HighestCaptureAssists` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `HighestKillAssists` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `BountyPlayersKilled` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `ChallengesWon` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `MissionsCompleted` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `PrototypesStolen` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `AntennasDestroyed` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `CratesOpened` mediumint(9) UNSIGNED NOT NULL DEFAULT '0',
  `LastPing` smallint(6) UNSIGNED NOT NULL DEFAULT '0',
  `LastPacketLoss` float NOT NULL DEFAULT '0',
  `HighestPing` smallint(6) UNSIGNED NOT NULL DEFAULT '0',
  `LowestPing` smallint(6) UNSIGNED NOT NULL DEFAULT '0',
  `NukesLaunched` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `AirstrikesCalled` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `FlashBangedPlayers` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `AnthraxIntoxications` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `PUBGEventsWon` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `SafesRobbed` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `RopeRappels` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `AreasEntered` int(16) UNSIGNED NOT NULL DEFAULT '0',
  `LastAreaId` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `LastPosX` float NOT NULL DEFAULT '0',
  `LastPosY` float NOT NULL DEFAULT '0',
  `LastPosZ` float NOT NULL DEFAULT '0',
  `LastHealth` float NOT NULL DEFAULT '0',
  `LastArmour` float NOT NULL DEFAULT '0',
  `TimeSpentOnFoot` int(16) UNSIGNED NOT NULL DEFAULT '0',
  `TimeSpentInCar` int(16) UNSIGNED NOT NULL DEFAULT '0',
  `TimeSpentAsPassenger` int(16) UNSIGNED NOT NULL DEFAULT '0',
  `TimeSpentInSelection` int(16) UNSIGNED NOT NULL DEFAULT '0',
  `TimeSpentAFK` int(16) UNSIGNED NOT NULL DEFAULT '0',
  `DriveByKills` int(16) UNSIGNED NOT NULL DEFAULT '0',
  `MathCalculations` int(16) UNSIGNED NOT NULL DEFAULT '0',
  `CashAdded` int(16) UNSIGNED NOT NULL DEFAULT '0',
  `CashReduced` int(16) UNSIGNED NOT NULL DEFAULT '0',
  `LastInterior` smallint(6) UNSIGNED NOT NULL DEFAULT '0',
  `LastVirtualWorld` smallint(6) UNSIGNED NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Indexes for dumped tables
--
ALTER TABLE `SlavePlayersData`
  ADD PRIMARY KEY `sID` (`sID`);
COMMIT;

--
-- Indexes for table `SlavePlayersData`
--

ALTER TABLE `SlavePlayersData`
  MODIFY `sID` int(16) NOT NULL AUTO_INCREMENT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
