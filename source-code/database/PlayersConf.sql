-- phpMyAdmin SQL Dump
-- version 4.8.3
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Aug 02, 2019 at 08:05 PM
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
-- Table structure for table `PlayersConf`
--

CREATE TABLE `PlayersConf` (
  `pID` int(11) UNSIGNED NOT NULL,
  `DoNotDisturb` tinyint(2) UNSIGNED NOT NULL DEFAULT '0',
  `NoDuel` tinyint(2) UNSIGNED NOT NULL DEFAULT '0',
  `HitIndicator` tinyint(2) UNSIGNED NOT NULL DEFAULT '1',
  `GUIEnabled` tinyint(2) UNSIGNED NOT NULL DEFAULT '1',
  `WeaponLaser` tinyint(2) UNSIGNED NOT NULL DEFAULT '1',
  `LaserColor` smallint(6) UNSIGNED NOT NULL DEFAULT '19082',
  `WeaponBodyToys` tinyint(2) UNSIGNED NOT NULL DEFAULT '1',
  `SpawnKillTime` smallint(4) NOT NULL DEFAULT '7',
  `UseHelmet` tinyint(2) UNSIGNED NOT NULL DEFAULT '1',
  `UseGasMask` tinyint(2) UNSIGNED NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `PlayersConf`
--
ALTER TABLE `PlayersConf`
  ADD UNIQUE KEY `pID` (`pID`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
