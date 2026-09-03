-- ============================================================================
-- RaceDay Database Schema & Seed Script
-- SSMS Target: SQL Server 2019 / 2022 / Azure SQL
-- File Name: schema.sql
-- ============================================================================

USE master;
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = N'RaceDayDB')
BEGIN
    ALTER DATABASE RaceDayDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE RaceDayDB;
END
GO

CREATE DATABASE RaceDayDB;
GO

USE RaceDayDB;
GO

-- ============================================================================
-- 1. TABLE CREATION
-- ============================================================================

-- Roles Table
CREATE TABLE Roles (
    role_id INT IDENTITY(1,1) NOT NULL,
    role_name VARCHAR(50) NOT NULL,
    CONSTRAINT PK_Roles PRIMARY KEY (role_id),
    CONSTRAINT UQ_Roles_RoleName UNIQUE (role_name)
);

-- Users Table
CREATE TABLE Users (
    user_id INT IDENTITY(1,1) NOT NULL,
    role_id INT NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_Users PRIMARY KEY (user_id),
    CONSTRAINT UQ_Users_Email UNIQUE (email),
    CONSTRAINT FK_Users_Roles FOREIGN KEY (role_id) REFERENCES Roles(role_id) ON DELETE NO ACTION
);

-- Categories Table
CREATE TABLE Categories (
    category_id INT IDENTITY(1,1) NOT NULL,
    category_name VARCHAR(50) NOT NULL,
    description VARCHAR(255) NULL,
    CONSTRAINT PK_Categories PRIMARY KEY (category_id),
    CONSTRAINT UQ_Categories_CategoryName UNIQUE (category_name)
);

-- Events Table
CREATE TABLE Events (
    event_id INT IDENTITY(1,1) NOT NULL,
    organiser_id INT NOT NULL,
    category_id INT NOT NULL,
    title VARCHAR(100) NOT NULL,
    description VARCHAR(MAX) NULL,
    event_date DATETIME NOT NULL,
    location VARCHAR(150) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_Events PRIMARY KEY (event_id),
    CONSTRAINT FK_Events_Organiser FOREIGN KEY (organiser_id) REFERENCES Users(user_id) ON DELETE NO ACTION,
    CONSTRAINT FK_Events_Category FOREIGN KEY (category_id) REFERENCES Categories(category_id) ON DELETE NO ACTION
);

-- EventEnrolments Table
CREATE TABLE EventEnrolments (
    enrolment_id INT IDENTITY(1,1) NOT NULL,
    event_id INT NOT NULL,
    participant_id INT NOT NULL,
    enrolment_date DATETIME NOT NULL DEFAULT GETDATE(),
    status VARCHAR(20) NOT NULL DEFAULT 'Registered',
    CONSTRAINT PK_EventEnrolments PRIMARY KEY (enrolment_id),
    CONSTRAINT UQ_EventEnrolments_EventParticipant UNIQUE (event_id, participant_id),
    CONSTRAINT FK_EventEnrolments_Event FOREIGN KEY (event_id) REFERENCES Events(event_id) ON DELETE CASCADE,
    CONSTRAINT FK_EventEnrolments_Participant FOREIGN KEY (participant_id) REFERENCES Users(user_id) ON DELETE NO ACTION,
    CONSTRAINT CK_EventEnrolments_Status CHECK (status IN ('Registered', 'Cancelled'))
);

-- Results Table
CREATE TABLE Results (
    result_id INT IDENTITY(1,1) NOT NULL,
    enrolment_id INT NOT NULL,
    finish_time_seconds INT NULL,
    position INT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'Finished',
    CONSTRAINT PK_Results PRIMARY KEY (result_id),
    CONSTRAINT UQ_Results_Enrolment UNIQUE (enrolment_id),
    CONSTRAINT FK_Results_Enrolment FOREIGN KEY (enrolment_id) REFERENCES EventEnrolments(enrolment_id) ON DELETE CASCADE,
    CONSTRAINT CK_Results_Status CHECK (status IN ('Finished', 'DNF', 'DNS'))
);
GO

-- ============================================================================
-- 2. SEED DATA ASSIGNMENT REQUIREMENTS
-- Min Requirements: 2 Organisers, 2 Participants, 3 Events, Categories, Enrolments
-- ============================================================================

-- Insert Roles
INSERT INTO Roles (role_name) VALUES
('Organiser'),
('Participant');

-- Insert Users (2 Organisers, 2 Participants)
-- Passwords shown are dummy bcrypt hashed strings
INSERT INTO Users (role_id, first_name, last_name, email, password_hash) VALUES
(1, 'Sipho', 'Nkosi', 'sipho.organiser@raceday.co.za', '$2a$12$eImiTXuWVxfM37uY4JANjO.GkK92eE8fN8e52U/9Y6p5Y6P5Y6P5Y'), -- User 1 (Organiser 1)
(1, 'Lindiwe', 'Dlamini', 'lindiwe.events@raceday.co.za', '$2a$12$eImiTXuWVxfM37uY4JANjO.GkK92eE8fN8e52U/9Y6p5Y6P5Y6P5Y'), -- User 2 (Organiser 2)
(2, 'Thabo', 'Mokoena', 'thabo.runner@gmail.com', '$2a$12$eImiTXuWVxfM37uY4JANjO.GkK92eE8fN8e52U/9Y6p5Y6P5Y6P5Y'), -- User 3 (Participant 1)
(2, 'Jessica', 'Taylor', 'jessica.t@gmail.com', '$2a$12$eImiTXuWVxfM37uY4JANjO.GkK92eE8fN8e52U/9Y6p5Y6P5Y6P5Y'); -- User 4 (Participant 2)

-- Insert Categories
INSERT INTO Categories (category_name, description) VALUES
('Road Running', 'Long-distance running events held on paved roads'),
('Cycling', 'On-road and off-road competitive bicycle races'),
('Trail Running', 'Off-road running over varied terrain and mountain paths');

-- Insert 3 Events
INSERT INTO Events (organiser_id, category_id, title, description, event_date, location) VALUES
(1, 1, 'Joburg City 10k Express', 'Fast 10km road race through Johannesburg CBD.', '2026-10-15 07:00:00', 'Braamfontein, Johannesburg'),
(1, 2, 'Cradle Cycle Challenge', '90km competitive road cycling event.', '2026-11-01 06:30:00', 'Cradle of Humankind'),
(2, 3, 'Drakensberg Mountain Trail', 'Extreme 21km trail run through scenic mountain paths.', '2026-12-05 05:30:00', 'Monks Cowl, Drakensberg');

-- Insert Sample Enrolments
INSERT INTO EventEnrolments (event_id, participant_id, status) VALUES
(1, 3, 'Registered'), -- Thabo in 10k Express
(1, 4, 'Registered'), -- Jessica in 10k Express
(2, 3, 'Registered'), -- Thabo in Cycle Challenge
(3, 4, 'Registered'); -- Jessica in Trail Run

-- Insert Sample Results
INSERT INTO Results (enrolment_id, finish_time_seconds, position, status) VALUES
(1, 2400, 1, 'Finished'), -- Thabo 40 mins
(2, 2750, 2, 'Finished'); -- Jessica 45.8 mins
GO

-- Verification Queries
SELECT 'Users' AS Entity, COUNT(*) AS TotalCount FROM Users
UNION ALL
SELECT 'Events', COUNT(*) FROM Events
UNION ALL
SELECT 'EventEnrolments', COUNT(*) FROM EventEnrolments
UNION ALL
SELECT 'Results', COUNT(*) FROM Results;
GO