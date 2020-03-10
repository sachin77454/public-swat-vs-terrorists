-- phpMyAdmin SQL Dump
-- version 4.8.3
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Aug 12, 2019 at 04:53 PM
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
-- Table structure for table `RacesData`
--

CREATE TABLE `RacesData` (
  `RaceId` int(16) NOT NULL,
  `RaceName` varchar(24) COLLATE utf8mb4_unicode_ci NOT NULL,
  `RaceMaker` varchar(24) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `RaceVehicle` smallint(5) NOT NULL DEFAULT '-1',
  `RaceInt` smallint(6) NOT NULL DEFAULT '0',
  `RaceWorld` smallint(6) NOT NULL DEFAULT '0',
  `RaceDate` int(16) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `RacesData`
--
ALTER TABLE `RacesData`
  ADD PRIMARY KEY (`RaceId`),
  ADD UNIQUE KEY `RaceName` (`RaceName`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `RacesData`
--
ALTER TABLE `RacesData`
  MODIFY `RaceId` int(16) NOT NULL AUTO_INCREMENT;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
