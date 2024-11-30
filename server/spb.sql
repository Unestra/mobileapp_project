-- phpMyAdmin SQL Dump
-- version 5.1.3
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Nov 30, 2024 at 11:01 AM
-- Server version: 10.4.24-MariaDB
-- PHP Version: 7.4.29

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `spb`
--

-- --------------------------------------------------------

--
-- Table structure for table `assets`
--

CREATE TABLE `assets` (
  `asset_id` int(11) NOT NULL,
  `asset_name` varchar(100) DEFAULT NULL,
  `status` enum('Available','Pending','Borrowed','Disabled') DEFAULT NULL,
  `asset_image` varchar(255) DEFAULT NULL,
  `assets_description` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `assets`
--

INSERT INTO `assets` (`asset_id`, `asset_name`, `status`, `asset_image`, `assets_description`) VALUES
(1, 'Footbal', 'Available', 'assets/images/football.png', 'play footbal with your frainds'),
(2, 'Volleyballllllll', 'Available', 'assets/images/football.png', 'play with boyfraind only hahahahahhhhhhhhhhhhhhhhhhhhhhh'),
(3, 'Ping Pong Paddle', 'Available', 'assets/images/pingpong_paddle.jpg', 'A high-quality Ping Pong paddle for competitive play.'),
(4, 'Basketball', 'Available', 'assets/images/basketball.png', 'An official size 7 basketball suitable for both indoor and outdoor use.'),
(5, 'Badminton racket', 'Available', 'assets/images/badminton_racket.jpg', 'Updated description'),
(6, 'Tennis Racket', 'Available', 'assets/images/tennis_racket.jpg', 'A durable tennis racket suitable for all court surfaces.'),
(7, 'Cricket Bat', 'Available', 'assets/images/cricket_ba.jpg', 'A full-size cricket bat made from high-quality wood.'),
(8, 'Baseball Glove', 'Available', 'assets/images/baseball_glove.png', 'A left-handed baseball glove suitable for fielding practice.'),
(9, 'Hockey Stick', 'Available', 'assets/images/hockey_stick.png', 'A standard hockey stick for field hockey games.'),
(10, 'Soccer Goal Net', 'Available', 'assets/images/soccer_goal_net.jpg', 'A durable soccer goal net suitable for outdoor matches.'),
(21, 'biker', 'Available', 'assets/images/pngtree-bicycle-sport-biker.png', 'bikerrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr');

-- --------------------------------------------------------

--
-- Table structure for table `borrowrequests`
--

CREATE TABLE `borrowrequests` (
  `request_id` int(11) NOT NULL,
  `borrower_id` int(11) NOT NULL,
  `asset_id` int(11) NOT NULL,
  `approved_by` int(11) DEFAULT NULL,
  `borrow_date` date DEFAULT NULL,
  `return_date` date DEFAULT NULL,
  `status` enum('Pending','Approved','Rejected') DEFAULT 'Pending'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `borrowrequests`
--

INSERT INTO `borrowrequests` (`request_id`, `borrower_id`, `asset_id`, `approved_by`, `borrow_date`, `return_date`, `status`) VALUES
(23, 18, 1, 2, '2024-11-25', '2024-11-26', 'Approved');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `user_id` int(11) NOT NULL,
  `username` varchar(50) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `role` enum('Student','Staff','Lender') DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`user_id`, `username`, `password`, `role`, `email`) VALUES
(1, 'Thongchai', '$2b$10$lfRLQurEWVCLoq9yentUhu2pqwYBWFFNsJT5hrQliSbpve0SaDwFm', 'Staff', 'thongchai@test.com'),
(2, 'Sura', '$2b$10$rY07BWPaYEBBulDPGhuahesX0fK8BGDb3kVgYk4NejlKncDf3kRqO', 'Lender', 'docker@test.com'),
(11, 'dimon', '$2b$10$vsKq8ScdCcrRYEDT89KzKeE7OiGmAtiQmcm51lnK0KTz2s25i1p9u', 'Student', 'dimon@test.com'),
(12, 'nuta', '$2b$10$mvGEvICdJ6E9Xn9Otue10eYzKTinGr8OrnI5QQM1qgIxtExlVsQDG', 'Student', 'nuta@gmail.com'),
(15, 'jumjim', '$2b$10$0IieinESuv4NG7QE12wN0uKWimca1Gbtqnng7m8k7hJghI7X4ALOq', 'Student', 'jumjim'),
(16, 'katui', '$2b$10$0CQvP9vzNCbvNtGF7V3E4ebCeuNta6QBHTLlLSrwpW0i8MQJInwjS', 'Student', 'katui'),
(17, 'numjun', '$2b$10$f.XAKM5wdwDOYUaGseuksen648Og0KrTvr0/GH6QHnLx4ImAA/VEK', 'Student', 'numjun'),
(18, 'duyum', '$2b$10$LovIflaEGL8cM5KizMJaFOEErFAKeoPvKv.QmFuhiPOgCjZVWqAvy', 'Student', 'duyum'),
(19, 'Sura1', '$2b$10$rY07BWPaYEBBulDPGhuahesX0fK8BGDb3kVgYk4NejlKncDf3kRqO', 'Lender', 'docker@test.com');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `assets`
--
ALTER TABLE `assets`
  ADD PRIMARY KEY (`asset_id`);

--
-- Indexes for table `borrowrequests`
--
ALTER TABLE `borrowrequests`
  ADD PRIMARY KEY (`request_id`),
  ADD KEY `borrower_id` (`borrower_id`),
  ADD KEY `asset_id` (`asset_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `assets`
--
ALTER TABLE `assets`
  MODIFY `asset_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT for table `borrowrequests`
--
ALTER TABLE `borrowrequests`
  MODIFY `request_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=24;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `borrowrequests`
--
ALTER TABLE `borrowrequests`
  ADD CONSTRAINT `borrowrequests_ibfk_1` FOREIGN KEY (`borrower_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `borrowrequests_ibfk_2` FOREIGN KEY (`asset_id`) REFERENCES `assets` (`asset_id`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
