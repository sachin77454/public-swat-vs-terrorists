-- phpMyAdmin SQL Dump
-- version 4.8.3
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Aug 02, 2019 at 05:12 PM
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
-- Table structure for table `Achievements`
--

CREATE TABLE `Achievements` (
  `pID` int(11) UNSIGNED NOT NULL,
  `A1` tinyint(2) NOT NULL DEFAULT '0',
  `A2` tinyint(2) NOT NULL DEFAULT '0',
  `A3` tinyint(2) NOT NULL DEFAULT '0',
  `A4` tinyint(2) NOT NULL DEFAULT '0',
  `A5` tinyint(2) NOT NULL DEFAULT '0',
  `A6` tinyint(2) NOT NULL DEFAULT '0',
  `A7` tinyint(2) NOT NULL DEFAULT '0',
  `A8` tinyint(2) NOT NULL DEFAULT '0',
  `A9` tinyint(2) NOT NULL DEFAULT '0',
  `A10` tinyint(2) NOT NULL DEFAULT '0',
  `A11` tinyint(2) NOT NULL DEFAULT '0',
  `A12` tinyint(2) NOT NULL DEFAULT '0',
  `A13` tinyint(2) NOT NULL DEFAULT '0',
  `A14` tinyint(2) NOT NULL DEFAULT '0',
  `A15` tinyint(2) NOT NULL DEFAULT '0',
  `A16` tinyint(2) NOT NULL DEFAULT '0',
  `A17` tinyint(2) NOT NULL DEFAULT '0',
  `A18` tinyint(2) NOT NULL DEFAULT '0',
  `A19` tinyint(2) NOT NULL DEFAULT '0',
  `A20` tinyint(2) NOT NULL DEFAULT '0',
  `A21` tinyint(2) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `Achievements`
--
ALTER TABLE `Achievements`
  ADD UNIQUE KEY `pID` (`pID`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
