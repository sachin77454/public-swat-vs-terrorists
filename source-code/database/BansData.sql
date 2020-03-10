-- phpMyAdmin SQL Dump
-- version 4.5.4.1deb2ubuntu2.1
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Aug 14, 2019 at 01:26 AM
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
-- Table structure for table `BansData`
--

CREATE TABLE `BansData` (
  `BanId` int(11) NOT NULL,
  `BannedName` varchar(24) COLLATE utf8mb4_unicode_ci NOT NULL,
  `AdminName` varchar(24) COLLATE utf8mb4_unicode_ci NOT NULL,
  `BanReason` varchar(25) COLLATE utf8mb4_unicode_ci NOT NULL,
  `ExpiryDate` int(16) NOT NULL,
  `BanDate` varchar(24) NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `BansData`
--
ALTER TABLE `BansData`
  ADD PRIMARY KEY (`BanId`),
  ADD UNIQUE KEY `BannedName` (`BannedName`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `BansData`
--
ALTER TABLE `BansData`
  MODIFY `BanId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;