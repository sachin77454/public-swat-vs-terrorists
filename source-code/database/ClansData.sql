-- phpMyAdmin SQL Dump
-- version 4.8.3
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Aug 01, 2019 at 07:03 PM
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
-- Database: `dww`
--

-- --------------------------------------------------------

--
-- Table structure for table `ClansData`
--

CREATE TABLE `ClansData` (
  `ClanId` int(10) AUTO_INCREMENT UNSIGNED NOT NULL,
  `ClanName` varchar(35) COLLATE utf8mb4_unicode_ci NOT NULL,
  `ClanTag` varchar(7) COLLATE utf8mb4_unicode_ci NOT NULL,
  `ClanMotd` varchar(60) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'New Message',
  `ClanWeap` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `ClanWallet` int(10) UNSIGNED NOT NULL DEFAULT '0',
  `ClanKills` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `ClanDeaths` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `ClanPoints` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `Rank1` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Member',
  `Rank2` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Member',
  `Rank3` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Member',
  `Rank4` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Member',
  `Rank5` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Member',
  `Rank6` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Member',
  `Rank7` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Member',
  `Rank8` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Member',
  `Rank9` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Co-Leader',
  `Rank10` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Leader',
  `ClanLevel` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `ClanSkin` smallint(5) UNSIGNED NOT NULL DEFAULT '0',
  `BasePurchaseTime` int(11) NOT NULL DEFAULT '0',
  `InviteClanLevel` tinyint(4) NOT NULL DEFAULT '10',
  `ClanWarLevel` tinyint(4) NOT NULL DEFAULT '10',
  `ClanPermsLevel` tinyint(4) NOT NULL DEFAULT '10',
  `PreferredTeam` tinyint(4) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `ClansData`
--
ALTER TABLE `ClansData`
  ADD PRIMARY KEY (`ClanId`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
