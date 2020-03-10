-- phpMyAdmin SQL Dump
-- version 4.5.4.1deb2ubuntu2.1
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Aug 14, 2019 at 05:00 AM
-- Server version: 5.7.27-0ubuntu0.16.04.1
-- PHP Version: 7.0.33-0ubuntu0.16.04.5

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
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
-- Table structure for table `PlayersData`
--

CREATE TABLE `PlayersData` (
  `pID` int(16) UNSIGNED NOT NULL,
  `Score` bigint(16) NOT NULL DEFAULT '0',
  `Cash` bigint(16) NOT NULL DEFAULT '0',
  `Kills` int(11) NOT NULL DEFAULT '0',
  `Deaths` int(11) NOT NULL DEFAULT '0',
  `GunFires` int(10) NOT NULL DEFAULT '0',
  `IsJailed` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `JailTime` int(11) NOT NULL DEFAULT '0',
  `Headshots` int(11) NOT NULL DEFAULT '0',
  `Nutshots` mediumint(8) NOT NULL DEFAULT '0',
  `KnifeKills` int(11) NOT NULL DEFAULT '0',
  `RevengeTakes` int(11) NOT NULL DEFAULT '0',
  `JackpotsFound` mediumint(5) NOT NULL DEFAULT '0',
  `DeathmatchKills` int(11) NOT NULL DEFAULT '0',
  `RustlerRockets` int(8) NOT NULL DEFAULT '0',
  `RustlerRocketsHit` int(8) NOT NULL DEFAULT '0',
  `DuelsWon` mediumint(8) NOT NULL DEFAULT '0',
  `DuelsLost` mediumint(8) NOT NULL DEFAULT '0',
  `MedkitsUsed` mediumint(8) NOT NULL DEFAULT '0',
  `ArmourkitsUsed` mediumint(8) NOT NULL DEFAULT '0',
  `SupportAttempts` mediumint(8) NOT NULL DEFAULT '0',
  `EXP` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `KillAssists` int(11) NOT NULL DEFAULT '0',
  `CaptureAssists` int(11) NOT NULL DEFAULT '0',
  `HighestKillStreak` smallint(5) UNSIGNED NOT NULL DEFAULT '0',
  `SawedKills` int(11) NOT NULL DEFAULT '0',
  `AirRocketsFired` int(11) NOT NULL DEFAULT '0',
  `AntiAirRocketsFired` int(11) NOT NULL DEFAULT '0',
  `CarePackagesDropped` int(11) NOT NULL DEFAULT '0',
  `FavWeap` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `FavWeap2` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `FavWeap3` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `DamageRate` float NOT NULL DEFAULT '0',
  `HealthLost` float NOT NULL DEFAULT '0',
  `SMGKills` int(11) NOT NULL DEFAULT '0',
  `ShotgunKills` int(11) NOT NULL DEFAULT '0',
  `HeavyKills` int(11) NOT NULL DEFAULT '0',
  `MeleeKills` int(11) NOT NULL DEFAULT '0',
  `PistolKills` int(11) NOT NULL DEFAULT '0',
  `FistKills` int(11) NOT NULL DEFAULT '0',
  `CloseKills` int(11) NOT NULL DEFAULT '0',
  `DriversStabbed` int(11) NOT NULL DEFAULT '0',
  `SpiesEliminated` int(11) NOT NULL DEFAULT '0',
  `KillsAsSpy` int(11) NOT NULL DEFAULT '0',
  `LongDistanceKills` int(11) UNSIGNED NOT NULL DEFAULT '0',
  `WeaponsDropped` int(11) UNSIGNED NOT NULL DEFAULT '0',
  `WeaponsPicked` int(11) UNSIGNED NOT NULL DEFAULT '0',
  `EventsWon` int(11) UNSIGNED NOT NULL DEFAULT '0',
  `RacesWon` int(11) UNSIGNED NOT NULL DEFAULT '0',
  `ItemsUsed` int(11) UNSIGNED NOT NULL DEFAULT '0',
  `FavSkin` smallint(6) NOT NULL DEFAULT '0',
  `FavTeam` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `SuicideAttempts` int(11) UNSIGNED NOT NULL DEFAULT '0',
  `PlayersHealed` int(11) UNSIGNED NOT NULL DEFAULT '0',
  `CommandsUsed` int(11) UNSIGNED NOT NULL DEFAULT '0',
  `CommandsFailed` int(11) UNSIGNED NOT NULL DEFAULT '0',
  `UnauthorizedActions` int(11) UNSIGNED NOT NULL DEFAULT '0',
  `RCONLogins` int(11) UNSIGNED NOT NULL DEFAULT '0',
  `RCONFailedAttempts` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `ClassAbilitiesUsed` int(11) UNSIGNED NOT NULL DEFAULT '0',
  `DronesExploded` int(11) UNSIGNED NOT NULL DEFAULT '0',
  `HealthGained` float NOT NULL DEFAULT '0',
  `ZonesCaptured` int(11) UNSIGNED NOT NULL DEFAULT '0',
  `InteriorsEntered` int(11) UNSIGNED NOT NULL DEFAULT '0',
  `InteriorsExitted` int(11) UNSIGNED NOT NULL DEFAULT '0',
  `PickupsPicked` int(11) UNSIGNED NOT NULL DEFAULT '0',
  `QuestionsAsked` int(11) UNSIGNED NOT NULL DEFAULT '0',
  `QuestionsAnswered` int(11) UNSIGNED NOT NULL DEFAULT '0',
  `CrashTimes` int(11) UNSIGNED NOT NULL DEFAULT '0',
  `SAMPClient` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `BackupAttempts` int(11) UNSIGNED NOT NULL DEFAULT '0',
  `BackupsResponded` int(11) UNSIGNED NOT NULL DEFAULT '0',
  `BaseRapeAttempts` int(11) UNSIGNED NOT NULL DEFAULT '0',
  `CBugAttempts` int(11) UNSIGNED NOT NULL DEFAULT '0',
  `ChatMessagesSent` int(11) UNSIGNED NOT NULL DEFAULT '0',
  `MoneySent` int(11) UNSIGNED NOT NULL DEFAULT '0',
  `MoneyReceived` int(11) UNSIGNED NOT NULL DEFAULT '0',
  `HighestBet` int(11) UNSIGNED NOT NULL DEFAULT '0',
  `DuelRequests` int(11) UNSIGNED NOT NULL DEFAULT '0',
  `DuelsAccepted` int(11) UNSIGNED NOT NULL DEFAULT '0',
  `DuelsRefusedByPlayer` int(11) UNSIGNED NOT NULL DEFAULT '0',
  `DuelsRefusedByOthers` int(11) UNSIGNED NOT NULL DEFAULT '0',
  `BountyAmount` int(11) UNSIGNED NOT NULL DEFAULT '0',
  `BountyCashSpent` int(11) UNSIGNED NOT NULL DEFAULT '0',
  `CoinsSpent` int(11) UNSIGNED NOT NULL DEFAULT '0',
  `PaymentsAccepted` int(11) UNSIGNED NOT NULL DEFAULT '0',
  `ClanKills` int(11) UNSIGNED NOT NULL DEFAULT '0',
  `ClanDeaths` int(11) UNSIGNED NOT NULL DEFAULT '0',
  `AchsUnlocked` int(11) UNSIGNED NOT NULL DEFAULT '0',
  `HighestCaptures` int(11) UNSIGNED NOT NULL DEFAULT '0',
  `KicksByAdmin` int(11) UNSIGNED NOT NULL DEFAULT '0',
  `LongestKillDistance` float NOT NULL DEFAULT '0',
  `NearestKillDistance` float NOT NULL DEFAULT '0',
  `HighestCaptureAssists` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `HighestKillAssists` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `BountyPlayersKilled` int(11) UNSIGNED NOT NULL DEFAULT '0',
  `ChallengesWon` int(11) UNSIGNED NOT NULL DEFAULT '0',
  `MissionsCompleted` int(11) UNSIGNED NOT NULL DEFAULT '0',
  `PrototypesStolen` int(11) UNSIGNED NOT NULL DEFAULT '0',
  `AntennasDestroyed` int(11) UNSIGNED NOT NULL DEFAULT '0',
  `CratesOpened` mediumint(9) UNSIGNED NOT NULL DEFAULT '0',
  `LastPing` smallint(6) UNSIGNED NOT NULL DEFAULT '0',
  `LastPacketLoss` float NOT NULL DEFAULT '0',
  `HighestPing` smallint(6) UNSIGNED NOT NULL DEFAULT '0',
  `LowestPing` smallint(6) UNSIGNED NOT NULL DEFAULT '0',
  `NukesLaunched` int(11) UNSIGNED NOT NULL DEFAULT '0',
  `AirstrikesCalled` int(11) UNSIGNED NOT NULL DEFAULT '0',
  `FlashBangedPlayers` int(11) UNSIGNED NOT NULL DEFAULT '0',
  `AnthraxIntoxications` int(11) UNSIGNED NOT NULL DEFAULT '0',
  `PUBGEventsWon` int(11) UNSIGNED NOT NULL DEFAULT '0',
  `RopeRappels` int(11) UNSIGNED NOT NULL DEFAULT '0',
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
  `CashAdded` bigint(20) UNSIGNED NOT NULL DEFAULT '0',
  `CashReduced` bigint(20) NOT NULL DEFAULT '0',
  `LastInterior` smallint(6) UNSIGNED NOT NULL DEFAULT '0',
  `LastVirtualWorld` smallint(6) UNSIGNED NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `PlayersData`
--
ALTER TABLE `PlayersData`
  ADD UNIQUE KEY `pID` (`pID`);

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
