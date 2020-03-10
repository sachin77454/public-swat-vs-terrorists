-- phpMyAdmin SQL Dump
-- version 4.8.3
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Aug 02, 2019 at 08:16 PM
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
-- Table structure for table `Punishments`
--

CREATE TABLE `Punishments` (
  `ActionId` int(11) NOT NULL,
  `PunishedPlayer` varchar(24) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Punisher` varchar(24) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Action` varchar(24) COLLATE utf8mb4_unicode_ci NOT NULL,
  `ActionReason` varchar(128) COLLATE utf8mb4_unicode_ci NULL,
  `PunishmentTime` varchar(24) NULL,
  `ActionDate` int(11) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `Punishments`
--
ALTER TABLE `Punishments`
  ADD PRIMARY KEY (`ActionId`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `Punishments`
--
ALTER TABLE `Punishments`
  MODIFY `ActionId` int(11) NOT NULL AUTO_INCREMENT;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
