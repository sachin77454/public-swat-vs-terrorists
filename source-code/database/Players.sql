-- phpMyAdmin SQL Dump
-- version 4.8.3
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Mar 10, 2020 at 06:06 PM
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
-- Database: `newsvt`
--

-- --------------------------------------------------------

--
-- Table structure for table `Players`
--

CREATE TABLE `Players` (
  `ID` int(16) NOT NULL,
  `Username` varchar(24) COLLATE utf8mb4_unicode_ci NOT NULL,
  `EmailAddress` varchar(65) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `EmailVerified` tinyint(1) NOT NULL DEFAULT '0',
  `EmailAttempts` tinyint(2) NOT NULL DEFAULT '0',
  `Password` varchar(65) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Salt` varchar(11) COLLATE utf8mb4_unicode_ci NOT NULL,
  `IP` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `GPCI` varchar(41) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `TFAKey` tinytext COLLATE utf8mb4_unicode_ci NOT NULL,
  `SupportKey` tinytext COLLATE utf8mb4_unicode_ci,
  `Coins` float NOT NULL DEFAULT '0',
  `RegDate` int(16) NOT NULL DEFAULT '0',
  `LastVisit` int(16) NOT NULL DEFAULT '0',
  `PlayTime` int(16) NOT NULL DEFAULT '0',
  `ClanId` mediumint(5) NOT NULL DEFAULT '-1',
  `ClanRank` tinyint(2) NOT NULL DEFAULT '0',
  `IsBanned` tinyint(2) NOT NULL DEFAULT '0',
  `Warnings` tinyint(2) NOT NULL DEFAULT '0',
  `IsModerator` tinyint(2) NOT NULL DEFAULT '0',
  `AdminLevel` tinyint(2) NOT NULL DEFAULT '0',
  `TimesLoggedIn` int(16) NOT NULL DEFAULT '0',
  `AntiCheatWarnings` int(16) NOT NULL DEFAULT '0',
  `PlayerReports` int(16) NOT NULL DEFAULT '0',
  `SpamAttempts` int(16) NOT NULL DEFAULT '0',
  `AdvAttempts` int(16) NOT NULL DEFAULT '0',
  `AntiSwearBlocks` int(16) NOT NULL DEFAULT '0',
  `TagPermitted` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `ReportAttempts` int(16) NOT NULL DEFAULT '0',
  `BannedTimes` tinyint(5) NOT NULL DEFAULT '0',
  `DonorLevel` tinyint(6) NOT NULL DEFAULT '0',
  `TFA` tinyint(1) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `Players`
--
ALTER TABLE `Players`
  ADD PRIMARY KEY (`ID`),
  ADD UNIQUE KEY `Username` (`Username`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `Players`
--
ALTER TABLE `Players`
  MODIFY `ID` int(16) NOT NULL AUTO_INCREMENT;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;