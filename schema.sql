-- ========================================
-- Fitness Academy Management System
-- Database Schema
-- ========================================
-- Created: 2025-12-04
-- Database: MySQL 5.7+
-- Character Set: utf8mb4
-- Collation: utf8mb4_unicode_ci
-- ========================================

SET FOREIGN_KEY_CHECKS = 0;
SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";

-- ========================================
-- Database Setup
-- ========================================

CREATE DATABASE IF NOT EXISTS `fitness_academy` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `fitness_academy`;

-- ========================================
-- Table: users
-- Core user management for all roles
-- ========================================

DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `UserID` int(11) NOT NULL AUTO_INCREMENT,
  `Username` varchar(50) NOT NULL,
  `PasswordHash` varchar(255) NOT NULL,
  `Email` varchar(100) NOT NULL,
  `Role` enum('Admin','Member','Coach','Staff') NOT NULL DEFAULT 'Member',
  `First_Name` varchar(50) DEFAULT NULL,
  `Last_Name` varchar(50) DEFAULT NULL,
  `Phone` varchar(20) DEFAULT NULL,
  `Address` text DEFAULT NULL,
  `DateOfBirth` date DEFAULT NULL,
  `ProfileImage` varchar(255) DEFAULT NULL,
  `IsActive` tinyint(1) DEFAULT 1,
  `RegistrationDate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `is_approved` tinyint(1) DEFAULT 0,
  `email_confirmed` tinyint(1) DEFAULT 0,
  `account_status` enum('active','inactive','suspended') DEFAULT 'active',
  `last_activity_date` datetime DEFAULT NULL,
  `membership_plan` varchar(100) DEFAULT NULL,
  `membership_start_date` date DEFAULT NULL,
  `membership_end_date` date DEFAULT NULL,
  `membership_price` decimal(10,2) DEFAULT NULL,
  `plan_id` int(11) DEFAULT NULL,
  `current_sessions_remaining` int(11) DEFAULT 0,
  PRIMARY KEY (`UserID`),
  UNIQUE KEY `Username` (`Username`),
  UNIQUE KEY `Email` (`Email`),
  KEY `idx_role` (`Role`),
  KEY `idx_email` (`Email`),
  KEY `idx_active` (`IsActive`),
  KEY `idx_account_status` (`account_status`),
  KEY `idx_plan_id` (`plan_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================
-- Table: membershipplans
-- Membership plan products
-- ========================================

DROP TABLE IF EXISTS `membershipplans`;
CREATE TABLE `membershipplans` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `plan_type` enum('session','monthly') NOT NULL DEFAULT 'session',
  `session_count` int(11) DEFAULT NULL,
  `duration_months` int(11) DEFAULT NULL,
  `name` varchar(100) NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `description` text DEFAULT NULL,
  `features` text DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `sort_order` int(11) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_active` (`is_active`),
  KEY `idx_sort_order` (`sort_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================
-- Table: memberships
-- Active membership records
-- ========================================

DROP TABLE IF EXISTS `memberships`;
CREATE TABLE `memberships` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `plan_id` int(11) NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `status` enum('active','expired','cancelled') DEFAULT 'active',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_plan_id` (`plan_id`),
  KEY `idx_status` (`status`),
  KEY `idx_end_date` (`end_date`),
  CONSTRAINT `fk_memberships_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`UserID`) ON DELETE CASCADE,
  CONSTRAINT `fk_memberships_plan` FOREIGN KEY (`plan_id`) REFERENCES `membershipplans` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================
-- Table: classes
-- Fitness class schedules
-- ========================================

DROP TABLE IF EXISTS `classes`;
CREATE TABLE `classes` (
  `class_id` int(11) NOT NULL AUTO_INCREMENT,
  `coach_id` int(11) NOT NULL,
  `class_name` varchar(100) NOT NULL,
  `class_description` text DEFAULT NULL,
  `class_date` date NOT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  `difficulty_level` enum('Beginner','Intermediate','Advanced') DEFAULT 'Beginner',
  `requirements` text DEFAULT NULL,
  `max_participants` int(11) DEFAULT 20,
  `price` decimal(10,2) DEFAULT 0.00,
  `status` enum('scheduled','completed','cancelled') DEFAULT 'scheduled',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`class_id`),
  KEY `idx_coach_id` (`coach_id`),
  KEY `idx_class_date` (`class_date`),
  KEY `idx_status` (`status`),
  CONSTRAINT `fk_classes_coach` FOREIGN KEY (`coach_id`) REFERENCES `users` (`UserID`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================
-- Table: classenrollments
-- Class enrollment records
-- ========================================

DROP TABLE IF EXISTS `classenrollments`;
CREATE TABLE `classenrollments` (
  `enrollment_id` int(11) NOT NULL AUTO_INCREMENT,
  `class_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `enrollment_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `status` enum('enrolled','completed','cancelled','dropped') DEFAULT 'enrolled',
  `payment_status` enum('pending','paid','refunded') DEFAULT 'pending',
  `payment_reference` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`enrollment_id`),
  UNIQUE KEY `unique_enrollment` (`class_id`,`user_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_class_id` (`class_id`),
  KEY `idx_status` (`status`),
  CONSTRAINT `fk_enrollments_class` FOREIGN KEY (`class_id`) REFERENCES `classes` (`class_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_enrollments_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`UserID`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================
-- Table: payments
-- Payment transaction records
-- ========================================

DROP TABLE IF EXISTS `payments`;
CREATE TABLE `payments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `transaction_id` varchar(255) DEFAULT NULL,
  `amount` decimal(10,2) NOT NULL,
  `payment_method` varchar(50) DEFAULT NULL,
  `payment_type` enum('membership','class','subscription','product') DEFAULT 'membership',
  `status` enum('pending','completed','failed','refunded') DEFAULT 'pending',
  `payment_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `description` text DEFAULT NULL,
  `metadata` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_transaction_id` (`transaction_id`),
  KEY `idx_status` (`status`),
  KEY `idx_payment_date` (`payment_date`),
  KEY `idx_payment_type` (`payment_type`),
  CONSTRAINT `fk_payments_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`UserID`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================
-- Table: payment_sessions
-- Temporary payment session tracking
-- ========================================

DROP TABLE IF EXISTS `payment_sessions`;
CREATE TABLE `payment_sessions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `session_id` varchar(255) NOT NULL,
  `user_data` text NOT NULL,
  `plan_data` text NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `status` enum('pending','completed','expired') DEFAULT 'pending',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `expires_at` timestamp NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `session_id` (`session_id`),
  KEY `idx_status` (`status`),
  KEY `idx_expires_at` (`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================
-- Table: attendance_records
-- Member check-in/check-out records
-- ========================================

DROP TABLE IF EXISTS `attendance_records`;
CREATE TABLE `attendance_records` (
  `AttendanceID` int(11) NOT NULL AUTO_INCREMENT,
  `UserID` int(11) NOT NULL,
  `CheckInTime` datetime NOT NULL,
  `CheckOutTime` datetime DEFAULT NULL,
  `SessionID` varchar(50) DEFAULT NULL,
  `scanned_by` int(11) DEFAULT NULL,
  `scanner_role` varchar(20) DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `notes` text DEFAULT NULL,
  PRIMARY KEY (`AttendanceID`),
  KEY `idx_user_id` (`UserID`),
  KEY `idx_checkin_time` (`CheckInTime`),
  KEY `idx_session_id` (`SessionID`),
  KEY `idx_scanned_by` (`scanned_by`),
  CONSTRAINT `fk_attendance_user` FOREIGN KEY (`UserID`) REFERENCES `users` (`UserID`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================
-- Table: coach_videos
-- Coach educational video content
-- ========================================

DROP TABLE IF EXISTS `coach_videos`;
CREATE TABLE `coach_videos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `coach_id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `video_path` varchar(255) NOT NULL,
  `thumbnail_path` varchar(255) DEFAULT NULL,
  `access_type` enum('free','paid') DEFAULT 'free',
  `subscription_price` decimal(10,2) DEFAULT 0.00,
  `status` enum('pending','approved','rejected') DEFAULT 'pending',
  `views_count` int(11) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_coach_id` (`coach_id`),
  KEY `idx_status` (`status`),
  KEY `idx_access_type` (`access_type`),
  CONSTRAINT `fk_videos_coach` FOREIGN KEY (`coach_id`) REFERENCES `users` (`UserID`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================
-- Table: coach_subscriptions
-- Member subscriptions to coach content
-- ========================================

DROP TABLE IF EXISTS `coach_subscriptions`;
CREATE TABLE `coach_subscriptions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `member_id` int(11) NOT NULL,
  `coach_id` int(11) NOT NULL,
  `subscription_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `end_date` timestamp NULL DEFAULT NULL,
  `status` enum('active','expired','cancelled') DEFAULT 'active',
  `amount_paid` decimal(10,2) NOT NULL,
  `payment_reference` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_subscription` (`member_id`,`coach_id`),
  KEY `idx_coach_id` (`coach_id`),
  KEY `idx_status` (`status`),
  CONSTRAINT `fk_subscriptions_coach` FOREIGN KEY (`coach_id`) REFERENCES `users` (`UserID`) ON DELETE CASCADE,
  CONSTRAINT `fk_subscriptions_member` FOREIGN KEY (`member_id`) REFERENCES `users` (`UserID`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================
-- Table: video_views
-- Video view tracking
-- ========================================

DROP TABLE IF EXISTS `video_views`;
CREATE TABLE `video_views` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `video_id` int(11) NOT NULL,
  `member_id` int(11) NOT NULL,
  `view_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_video_id` (`video_id`),
  KEY `idx_member_id` (`member_id`),
  KEY `idx_view_date` (`view_date`),
  CONSTRAINT `fk_views_member` FOREIGN KEY (`member_id`) REFERENCES `users` (`UserID`) ON DELETE CASCADE,
  CONSTRAINT `fk_views_video` FOREIGN KEY (`video_id`) REFERENCES `coach_videos` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================
-- Table: coach_announcements
-- Coach announcements for members
-- ========================================

DROP TABLE IF EXISTS `coach_announcements`;
CREATE TABLE `coach_announcements` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `coach_id` int(11) NOT NULL,
  `announcement` text NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_coach_id` (`coach_id`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `fk_announcements_coach` FOREIGN KEY (`coach_id`) REFERENCES `users` (`UserID`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================
-- Table: coach_applications
-- Coach application submissions
-- ========================================

DROP TABLE IF EXISTS `coach_applications`;
CREATE TABLE `coach_applications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `first_name` varchar(50) NOT NULL,
  `last_name` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `phone` varchar(20) NOT NULL,
  `address` text NOT NULL,
  `birthdate` date NOT NULL,
  `license_number` varchar(50) DEFAULT NULL,
  `experience` text DEFAULT NULL,
  `specialization` varchar(255) DEFAULT NULL,
  `why_coach` text DEFAULT NULL,
  `resume_path` varchar(255) DEFAULT NULL,
  `status` enum('pending','approved','rejected') DEFAULT 'pending',
  `admin_notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `processed_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_email` (`email`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================
-- Table: clientprogress
-- Client progress tracking by coaches
-- ========================================

DROP TABLE IF EXISTS `clientprogress`;
CREATE TABLE `clientprogress` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `date` date NOT NULL,
  `weight` decimal(5,2) DEFAULT NULL,
  `height` decimal(5,2) DEFAULT NULL,
  `bmi` decimal(5,2) DEFAULT NULL,
  `body_fat` decimal(5,2) DEFAULT NULL,
  `workout_duration_min` int(11) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `data_source` enum('manual','ocr','api') DEFAULT 'manual',
  `recorded_by` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_date` (`date`),
  KEY `idx_recorded_by` (`recorded_by`),
  CONSTRAINT `fk_clientprogress_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`UserID`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================
-- Table: memberprogress
-- Member self-reported progress
-- ========================================

DROP TABLE IF EXISTS `memberprogress`;
CREATE TABLE `memberprogress` (
  `ProgressID` int(11) NOT NULL AUTO_INCREMENT,
  `UserID` int(11) NOT NULL,
  `Weight` decimal(5,2) DEFAULT NULL,
  `Height` decimal(5,2) DEFAULT NULL,
  `Goal` text DEFAULT NULL,
  `RecordedAt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`ProgressID`),
  KEY `idx_user_id` (`UserID`),
  KEY `idx_recorded_at` (`RecordedAt`),
  CONSTRAINT `fk_memberprogress_user` FOREIGN KEY (`UserID`) REFERENCES `users` (`UserID`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================
-- Table: audit_trail
-- System audit log
-- ========================================

DROP TABLE IF EXISTS `audit_trail`;
CREATE TABLE `audit_trail` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(50) DEFAULT NULL,
  `action` varchar(255) NOT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_username` (`username`),
  KEY `idx_timestamp` (`timestamp`),
  KEY `idx_action` (`action`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================
-- Table: user_activity_log
-- Detailed user activity tracking
-- ========================================

DROP TABLE IF EXISTS `user_activity_log`;
CREATE TABLE `user_activity_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `activity_type` varchar(50) NOT NULL,
  `activity_description` text DEFAULT NULL,
  `activity_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_activity_type` (`activity_type`),
  KEY `idx_timestamp` (`activity_timestamp`),
  CONSTRAINT `fk_activity_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`UserID`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================
-- Table: user_status_history
-- User status change history
-- ========================================

DROP TABLE IF EXISTS `user_status_history`;
CREATE TABLE `user_status_history` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `previous_status` varchar(20) DEFAULT NULL,
  `new_status` varchar(20) NOT NULL,
  `change_reason` text DEFAULT NULL,
  `changed_by` int(11) DEFAULT NULL,
  `changed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_changed_at` (`changed_at`),
  CONSTRAINT `fk_status_history_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`UserID`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================
-- Table: password_resets
-- Password reset token management
-- ========================================

DROP TABLE IF EXISTS `password_resets`;
CREATE TABLE `password_resets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(100) NOT NULL,
  `token` varchar(255) NOT NULL,
  `expires_at` timestamp NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `used` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `token` (`token`),
  KEY `idx_email` (`email`),
  KEY `idx_expires_at` (`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================
-- Table: user_discounts
-- User discount tracking for ID uploads
-- ========================================

DROP TABLE IF EXISTS `user_discounts`;
CREATE TABLE `user_discounts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `discount_type` varchar(50) NOT NULL,
  `discount_value` decimal(10,2) NOT NULL,
  `id_image_path` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  CONSTRAINT `fk_discounts_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`UserID`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================
-- Administrator setup
-- ========================================
-- No default administrator is created by this schema. Create the first
-- administrator through a protected setup process and use a unique password.

-- ========================================
-- Sample Membership Plans
-- ========================================

INSERT INTO `membershipplans` (`plan_type`, `session_count`, `duration_months`, `name`, `price`, `description`, `features`, `is_active`, `sort_order`) VALUES
('session', 10, NULL, '10 Session Pack', 2500.00, 'Perfect for trying out our services', 'Gym access|Equipment use|Locker access|Valid for 60 days', 1, 1),
('session', 20, NULL, '20 Session Pack', 4500.00, 'Best value for regular gym-goers', 'Gym access|Equipment use|Locker access|1 Free fitness assessment|Valid for 90 days', 1, 2),
('monthly', NULL, 1, '1 Month Membership', 1500.00, 'Full access for one month', 'Unlimited gym access|Equipment use|Locker access|Group classes|Free wifi', 1, 3),
('monthly', NULL, 3, '3 Month Membership', 4000.00, 'Best value for committed members', 'Unlimited gym access|Equipment use|Locker access|Group classes|Free wifi|1 Personal training session', 1, 4),
('monthly', NULL, 6, '6 Month Membership', 7500.00, 'Long-term commitment savings', 'Unlimited gym access|Equipment use|Locker access|Group classes|Free wifi|2 Personal training sessions|Nutrition consultation', 1, 5),
('monthly', NULL, 12, '1 Year Membership', 14000.00, 'Ultimate annual package', 'Unlimited gym access|Equipment use|Locker access|Group classes|Free wifi|4 Personal training sessions|Monthly nutrition consultation|Guest passes', 1, 6);

-- ========================================
-- Indexes for Performance Optimization
-- ========================================

-- Additional composite indexes for common queries
ALTER TABLE `users` ADD INDEX `idx_role_active` (`Role`, `IsActive`);
ALTER TABLE `users` ADD INDEX `idx_membership_dates` (`membership_start_date`, `membership_end_date`);
ALTER TABLE `payments` ADD INDEX `idx_user_status` (`user_id`, `status`);
ALTER TABLE `classes` ADD INDEX `idx_coach_date` (`coach_id`, `class_date`);
ALTER TABLE `attendance_records` ADD INDEX `idx_user_checkin` (`UserID`, `CheckInTime`);

-- ========================================
-- Views for Common Queries
-- ========================================

-- View: Active Members with Membership Info
CREATE OR REPLACE VIEW `view_active_members` AS
SELECT 
    u.UserID,
    u.Username,
    u.Email,
    u.First_Name,
    u.Last_Name,
    u.Phone,
    u.membership_plan,
    u.membership_start_date,
    u.membership_end_date,
    u.current_sessions_remaining,
    mp.name as plan_name,
    mp.plan_type
FROM users u
LEFT JOIN membershipplans mp ON u.plan_id = mp.id
WHERE u.Role = 'Member' 
  AND u.IsActive = 1 
  AND u.account_status = 'active';

-- View: Today's Classes
CREATE OR REPLACE VIEW `view_todays_classes` AS
SELECT 
    c.class_id,
    c.class_name,
    c.class_description,
    c.class_date,
    c.start_time,
    c.end_time,
    c.difficulty_level,
    c.max_participants,
    c.price,
    u.First_Name as coach_first_name,
    u.Last_Name as coach_last_name,
    COUNT(ce.enrollment_id) as enrolled_count
FROM classes c
INNER JOIN users u ON c.coach_id = u.UserID
LEFT JOIN classenrollments ce ON c.class_id = ce.class_id AND ce.status = 'enrolled'
WHERE c.class_date = CURDATE() AND c.status = 'scheduled'
GROUP BY c.class_id;

-- View: Revenue Summary
CREATE OR REPLACE VIEW `view_revenue_summary` AS
SELECT 
    DATE(payment_date) as date,
    payment_type,
    COUNT(*) as transaction_count,
    SUM(amount) as total_amount
FROM payments
WHERE status = 'completed'
GROUP BY DATE(payment_date), payment_type;

-- ========================================
-- Triggers
-- ========================================

-- Trigger: Update membership plan sessions on enrollment
DELIMITER $$

DROP TRIGGER IF EXISTS `after_enrollment_insert`$$
CREATE TRIGGER `after_enrollment_insert` 
AFTER INSERT ON `classenrollments`
FOR EACH ROW
BEGIN
    -- Decrement session count if user has session-based plan
    UPDATE users 
    SET current_sessions_remaining = GREATEST(current_sessions_remaining - 1, 0)
    WHERE UserID = NEW.user_id 
      AND current_sessions_remaining > 0;
END$$

-- Trigger: Update video views count
DROP TRIGGER IF EXISTS `after_video_view_insert`$$
CREATE TRIGGER `after_video_view_insert` 
AFTER INSERT ON `video_views`
FOR EACH ROW
BEGIN
    UPDATE coach_videos 
    SET views_count = views_count + 1
    WHERE id = NEW.video_id;
END$$

-- Trigger: Log user status changes
DROP TRIGGER IF EXISTS `after_user_status_update`$$
CREATE TRIGGER `after_user_status_update` 
AFTER UPDATE ON `users`
FOR EACH ROW
BEGIN
    IF OLD.account_status != NEW.account_status THEN
        INSERT INTO user_status_history (user_id, previous_status, new_status, change_reason)
        VALUES (NEW.UserID, OLD.account_status, NEW.account_status, 'Status changed');
    END IF;
END$$

DELIMITER ;

-- ========================================
-- Stored Procedures
-- ========================================

DELIMITER $$

-- Procedure: Get member statistics
DROP PROCEDURE IF EXISTS `sp_get_member_stats`$$
CREATE PROCEDURE `sp_get_member_stats`()
BEGIN
    SELECT 
        COUNT(*) as total_members,
        SUM(CASE WHEN IsActive = 1 THEN 1 ELSE 0 END) as active_members,
        SUM(CASE WHEN account_status = 'inactive' THEN 1 ELSE 0 END) as inactive_members,
        SUM(CASE WHEN MONTH(RegistrationDate) = MONTH(CURRENT_DATE()) THEN 1 ELSE 0 END) as new_this_month
    FROM users 
    WHERE Role = 'Member';
END$$

-- Procedure: Get revenue for date range
DROP PROCEDURE IF EXISTS `sp_get_revenue_by_date`$$
CREATE PROCEDURE `sp_get_revenue_by_date`(
    IN start_date DATE,
    IN end_date DATE
)
BEGIN
    SELECT 
        DATE(payment_date) as date,
        payment_type,
        COUNT(*) as transactions,
        SUM(amount) as total_revenue
    FROM payments
    WHERE status = 'completed'
      AND DATE(payment_date) BETWEEN start_date AND end_date
    GROUP BY DATE(payment_date), payment_type
    ORDER BY date DESC;
END$$

-- Procedure: Check and update expired memberships
DROP PROCEDURE IF EXISTS `sp_update_expired_memberships`$$
CREATE PROCEDURE `sp_update_expired_memberships`()
BEGIN
    -- Update users with expired time-based memberships
    UPDATE users
    SET account_status = 'inactive',
        IsActive = 0
    WHERE membership_end_date < CURDATE()
      AND membership_end_date IS NOT NULL
      AND account_status = 'active'
      AND Role = 'Member';
    
    -- Update membership records
    UPDATE memberships
    SET status = 'expired'
    WHERE end_date < CURDATE()
      AND status = 'active';
END$$

DELIMITER ;

-- ========================================
-- Events for Automated Tasks
-- ========================================

-- Enable event scheduler
SET GLOBAL event_scheduler = ON;

-- Event: Daily cleanup of expired password reset tokens
DROP EVENT IF EXISTS `event_cleanup_password_resets`;
CREATE EVENT `event_cleanup_password_resets`
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_DATE + INTERVAL 1 DAY
DO
    DELETE FROM password_resets 
    WHERE expires_at < NOW() OR used = 1;

-- Event: Daily check for expired memberships
DROP EVENT IF EXISTS `event_check_expired_memberships`;
CREATE EVENT `event_check_expired_memberships`
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_DATE + INTERVAL 1 DAY
DO
    CALL sp_update_expired_memberships();

-- ========================================
-- Completion
-- ========================================

SET FOREIGN_KEY_CHECKS = 1;
COMMIT;

-- ========================================
-- Schema Information
-- ========================================
-- Total Tables: 20
-- Total Views: 3
-- Total Triggers: 3
-- Total Procedures: 3
-- Total Events: 2
-- 
-- Initial setup complete.
-- No administrator account is seeded. Create the first administrator through
-- a protected setup process and assign a unique password.
-- ========================================
