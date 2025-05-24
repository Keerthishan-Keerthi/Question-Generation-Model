-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jun 26, 2024 at 08:08 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `interviewsupportsystem`
--

-- --------------------------------------------------------

--
-- Table structure for table `advertisement`
--

CREATE TABLE `advertisement` (
  `A_ID` varchar(150) NOT NULL,
  `I_Email` varchar(150) NOT NULL,
  `A_Description` varchar(150) NOT NULL,
  `A_Link` varchar(100) NOT NULL,
  `Deadline` datetime NOT NULL,
  `Job_Title` varchar(100) NOT NULL,
  `Qualifications` varchar(150) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `candidate`
--

CREATE TABLE `candidate` (
  `C_Email` varchar(150) NOT NULL,
  `C_password` varchar(255) NOT NULL,
  `Mobile_No` int(11) NOT NULL,
  `NIC_No` varchar(15) NOT NULL,
  `Civil_Status` varchar(10) NOT NULL,
  `DOB` datetime NOT NULL,
  `District` varchar(50) NOT NULL,
  `Reason` varchar(150) NOT NULL,
  `status` tinyint(1) DEFAULT NULL,
  `reset_token` varchar(255) DEFAULT NULL,
  `Work_Preference` varchar(50) NOT NULL,
  `Availability` varchar(50) NOT NULL,
  `Job_Position` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `candidate`
--



-- --------------------------------------------------------

--
-- Table structure for table `interviewer`
--

CREATE TABLE `interviewer` (
  `I_Email` varchar(150) NOT NULL,
  `I_password` varchar(255) NOT NULL,
  `status` tinyint(1) DEFAULT NULL,
  `reset_token` varchar(255) DEFAULT NULL,
  `phone_number` varchar(20) DEFAULT NULL,
  `linkedin_profile` varchar(255) DEFAULT NULL,
  `preferred_communication` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `interviewer`
--


-- --------------------------------------------------------

--
-- Table structure for table `process`
--

CREATE TABLE `process` (
  `I_Email` varchar(150) NOT NULL,
  `Process_Date` datetime NOT NULL,
  `Process_Time` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `resumes`
--

CREATE TABLE `resumes` (
  `Resume_ID` varchar(150) NOT NULL,
  `C_Email` varchar(150) NOT NULL,
  `Job_Title` varchar(100) NOT NULL,
  `R_Link` blob DEFAULT NULL,
  `similarity_score` int(11) DEFAULT NULL,
  `Structured_Resume` blob DEFAULT NULL,
  `Ip_Score` int(11) DEFAULT NULL,
  `Ego_Score` int(11) DEFAULT NULL,
  `Questions` blob DEFAULT NULL,
  `skills` int(11) NOT NULL,
  `experience` int(11) NOT NULL,
  `education` int(11) NOT NULL,
  `location` int(11) NOT NULL,
  `performance` varchar(2) NOT NULL DEFAULT '0',
  `category` varchar(10) NOT NULL,
  `comments` varchar(100) NOT NULL,
  `i_status` varchar(15) NOT NULL DEFAULT 'Waiting'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `resumes`
--


-- --------------------------------------------------------

--
-- Table structure for table `upload`
--

CREATE TABLE `upload` (
  `C_Email` varchar(150) NOT NULL,
  `Upload_Date` datetime NOT NULL,
  `Upload_Time` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `user`
--

CREATE TABLE `user` (
  `Email` varchar(150) NOT NULL,
  `First_Name` varchar(150) NOT NULL,
  `Last_Name` varchar(150) NOT NULL,
  `role` enum('Candidate','Interviewer') DEFAULT NULL,
  `Password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `activation_token` varchar(32) DEFAULT NULL,
  `reset_token` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `status` tinyint(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `user`
--


--
-- Indexes for dumped tables
--

--
-- Indexes for table `advertisement`
--
ALTER TABLE `advertisement`
  ADD PRIMARY KEY (`A_ID`),
  ADD KEY `I_Email` (`I_Email`);

--
-- Indexes for table `candidate`
--
ALTER TABLE `candidate`
  ADD KEY `C_Email` (`C_Email`);

--
-- Indexes for table `interviewer`
--
ALTER TABLE `interviewer`
  ADD KEY `I_Email` (`I_Email`);

--
-- Indexes for table `process`
--
ALTER TABLE `process`
  ADD KEY `I_Email` (`I_Email`);

--
-- Indexes for table `resumes`
--
ALTER TABLE `resumes`
  ADD PRIMARY KEY (`Resume_ID`),
  ADD KEY `C_Email` (`C_Email`);

--
-- Indexes for table `upload`
--
ALTER TABLE `upload`
  ADD KEY `C_Email` (`C_Email`);

--
-- Indexes for table `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`Email`);

--
-- Constraints for dumped tables
--

--
-- Constraints for table `advertisement`
--
ALTER TABLE `advertisement`
  ADD CONSTRAINT `advertisement_ibfk_1` FOREIGN KEY (`I_Email`) REFERENCES `user` (`Email`);

--
-- Constraints for table `candidate`
--
ALTER TABLE `candidate`
  ADD CONSTRAINT `candidate_ibfk_1` FOREIGN KEY (`C_Email`) REFERENCES `user` (`Email`);

--
-- Constraints for table `interviewer`
--
ALTER TABLE `interviewer`
  ADD CONSTRAINT `interviewer_ibfk_1` FOREIGN KEY (`I_Email`) REFERENCES `user` (`Email`);

--
-- Constraints for table `process`
--
ALTER TABLE `process`
  ADD CONSTRAINT `process_ibfk_1` FOREIGN KEY (`I_Email`) REFERENCES `user` (`Email`);

--
-- Constraints for table `resumes`
--
ALTER TABLE `resumes`
  ADD CONSTRAINT `resumes_ibfk_1` FOREIGN KEY (`C_Email`) REFERENCES `user` (`Email`);

--
-- Constraints for table `upload`
--
ALTER TABLE `upload`
  ADD CONSTRAINT `upload_ibfk_1` FOREIGN KEY (`C_Email`) REFERENCES `user` (`Email`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
