-- =========================================
-- EVENT MANAGEMENT SYSTEM DATABASE
-- Milestone 4 - DDL Scripts
-- =========================================

-- CREATE DATABASE
CREATE DATABASE IF NOT EXISTS event_management_system;

USE event_management_system;

-- =========================================
-- USERS TABLE
-- =========================================

CREATE TABLE users (
user_id INT AUTO_INCREMENT PRIMARY KEY,
name VARCHAR(100) NOT NULL,
email VARCHAR(100) NOT NULL UNIQUE,
password VARCHAR(255) NOT NULL,
role ENUM('admin', 'user', 'customer') NOT NULL,
phone VARCHAR(20) UNIQUE,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =========================================
-- CATEGORIES TABLE
-- =========================================

CREATE TABLE categories (
category_id INT AUTO_INCREMENT PRIMARY KEY,
category_name VARCHAR(100) NOT NULL UNIQUE,
description TEXT,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =========================================
-- ORGANIZERS TABLE
-- =========================================

CREATE TABLE organizers (
organizer_id INT AUTO_INCREMENT PRIMARY KEY,
organizer_name VARCHAR(100) NOT NULL,
email VARCHAR(100) NOT NULL UNIQUE,
phone VARCHAR(20) UNIQUE,
organization VARCHAR(150),
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =========================================
-- EVENTS TABLE
-- =========================================

CREATE TABLE events (
event_id INT AUTO_INCREMENT PRIMARY KEY,


category_id INT NOT NULL,
organizer_id INT NOT NULL,

event_name VARCHAR(150) NOT NULL,
event_date DATE NOT NULL,
event_time TIME NOT NULL,
venue VARCHAR(150) NOT NULL,

total_seats INT NOT NULL,
available_seats INT NOT NULL,

status ENUM('upcoming', 'completed', 'cancelled') NOT NULL,

description TEXT,

created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

CONSTRAINT chk_total_seats
    CHECK (total_seats > 0),

CONSTRAINT chk_available_seats
    CHECK (available_seats >= 0),

CONSTRAINT fk_event_category
    FOREIGN KEY (category_id)
    REFERENCES categories(category_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,

CONSTRAINT fk_event_organizer
    FOREIGN KEY (organizer_id)
    REFERENCES organizers(organizer_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE


);

-- =========================================
-- BOOKINGS TABLE
-- =========================================

CREATE TABLE bookings (
booking_id INT AUTO_INCREMENT PRIMARY KEY,


user_id INT NOT NULL,
event_id INT NOT NULL,

seats_booked INT NOT NULL,

booking_status ENUM('confirmed', 'pending', 'cancelled') NOT NULL,

booking_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

notes TEXT,

CONSTRAINT chk_seats_booked
    CHECK (seats_booked > 0),

CONSTRAINT fk_booking_user
    FOREIGN KEY (user_id)
    REFERENCES users(user_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,

CONSTRAINT fk_booking_event
    FOREIGN KEY (event_id)
    REFERENCES events(event_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE


);

-- =========================================
-- FEEDBACK TABLE
-- =========================================

CREATE TABLE feedback (
feedback_id INT AUTO_INCREMENT PRIMARY KEY,

user_id INT NOT NULL,
event_id INT NOT NULL,

rating INT NOT NULL,

comment TEXT,

submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

CONSTRAINT chk_rating
    CHECK (rating BETWEEN 1 AND 5),

CONSTRAINT fk_feedback_user
    FOREIGN KEY (user_id)
    REFERENCES users(user_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,

CONSTRAINT fk_feedback_event
    FOREIGN KEY (event_id)
    REFERENCES events(event_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE

);

-- =========================================
-- INDEXES
-- =========================================

CREATE INDEX idx_event_category
ON events(category_id);

CREATE INDEX idx_event_organizer
ON events(organizer_id);

CREATE INDEX idx_booking_user
ON bookings(user_id);

CREATE INDEX idx_booking_event
ON bookings(event_id);

CREATE INDEX idx_feedback_user
ON feedback(user_id);

CREATE INDEX idx_feedback_event
ON feedback(event_id);

-- =========================================
-- SHOW TABLES
-- =========================================

SHOW TABLES;
