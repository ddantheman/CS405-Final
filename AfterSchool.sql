CREATE DATABASE IF NOT EXISTS AfterSchoolClubs;
USE AfterSchoolClubs;

DROP TABLE IF EXISTS Expenses;
DROP TABLE IF EXISTS FieldTrips;
DROP TABLE IF EXISTS Meetings;
DROP TABLE IF EXISTS Membership;
DROP TABLE IF EXISTS YearlyClubs;
DROP TABLE IF EXISTS Students;
DROP TABLE IF EXISTS Faculty;

CREATE TABLE IF NOT EXISTS Faculty (
    faculty_id INT PRIMARY KEY,
    faculty_name VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS Students (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS YearlyClubs (
    club_name VARCHAR(50) NOT NULL,
    school_year CHAR(7) NOT NULL,
    faculty_id INT NOT NULL,
    budget DECIMAL(8, 2) NOT NULL CHECK (budget >= 0),
    PRIMARY KEY (club_name, school_year),
    FOREIGN KEY (faculty_id) REFERENCES Faculty(faculty_id)
);

CREATE TABLE IF NOT EXISTS Membership (
    student_id INT NOT NULL,
    club_name VARCHAR(50) NOT NULL,
    school_year CHAR(7) NOT NULL,
    PRIMARY KEY (student_id, club_name, school_year),
    FOREIGN KEY (student_id) REFERENCES Students(student_id),
    FOREIGN KEY (club_name, school_year) REFERENCES YearlyClubs(club_name, school_year)
);

CREATE TABLE IF NOT EXISTS Meetings (
    club_name VARCHAR(50) NOT NULL,
    school_year CHAR(7) NOT NULL,
    meeting_id INT NOT NULL,
    meeting_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    classroom_id INT NOT NULL,
    meeting_description VARCHAR(255) NOT NULL,
    PRIMARY KEY (club_name, school_year, meeting_id),
    FOREIGN KEY (club_name, school_year) REFERENCES YearlyClubs(club_name, school_year),
    CHECK (end_time > start_time)
);

CREATE TABLE IF NOT EXISTS FieldTrips (
    club_name VARCHAR(50) NOT NULL,
    school_year CHAR(7) NOT NULL,
    trip_id INT NOT NULL,
    trip_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    trip_location VARCHAR(255) NOT NULL,
    trip_description VARCHAR(255) NOT NULL,
    PRIMARY KEY (club_name, school_year, trip_id),
    FOREIGN KEY (club_name, school_year) REFERENCES YearlyClubs(club_name, school_year),
    CHECK (end_time > start_time)
);

CREATE TABLE IF NOT EXISTS Expenses (
    club_name VARCHAR(50) NOT NULL,
    school_year CHAR(7) NOT NULL,
    expense_id INT NOT NULL,
    expense_date DATE NOT NULL,
    amount DECIMAL(8, 2) NOT NULL CHECK (amount > 0),
    expense_description VARCHAR(255) NOT NULL,
    PRIMARY KEY (club_name, school_year, expense_id),
    FOREIGN KEY (club_name, school_year) REFERENCES YearlyClubs(club_name, school_year)
);

INSERT INTO Faculty (faculty_id, faculty_name) VALUES
    (1, 'Amanda Lewis'),
    (2, 'Brian Patel'),
    (3, 'Caroline Smith'),
    (4, 'David Nguyen'),
    (5, 'Elena Garcia');

INSERT INTO Students (student_id, student_name) VALUES
    (101, 'Ava Johnson'),
    (102, 'Liam Williams'),
    (103, 'Noah Brown'),
    (104, 'Emma Davis'),
    (105, 'Olivia Miller'),
    (106, 'Mason Wilson'),
    (107, 'Sophia Moore'),
    (108, 'Ethan Taylor'),
    (109, 'Isabella Anderson'),
    (110, 'Lucas Thomas');

INSERT INTO YearlyClubs (club_name, school_year, faculty_id, budget) VALUES
    ('Band', '2024-25', 1, 2400.00),
    ('MathCounts', '2024-25', 2, 900.00),
    ('Robotics', '2024-25', 3, 3200.00),
    ('Band', '2025-26', 1, 2750.00),
    ('Choir', '2025-26', 5, 1800.00),
    ('MathCounts', '2025-26', 2, 1100.00),
    ('Robotics', '2025-26', 4, 3500.00),
    ('Speech', '2025-26', 3, 1250.00);

INSERT INTO Membership (student_id, club_name, school_year) VALUES
    (101, 'Band', '2024-25'),
    (102, 'Band', '2024-25'),
    (103, 'MathCounts', '2024-25'),
    (105, 'Robotics', '2024-25'),
    (101, 'Band', '2025-26'),
    (102, 'Band', '2025-26'),
    (109, 'Band', '2025-26'),
    (101, 'Choir', '2025-26'),
    (107, 'Choir', '2025-26'),
    (103, 'MathCounts', '2025-26'),
    (104, 'MathCounts', '2025-26'),
    (110, 'MathCounts', '2025-26'),
    (105, 'Robotics', '2025-26'),
    (106, 'Robotics', '2025-26'),
    (109, 'Robotics', '2025-26'),
    (107, 'Speech', '2025-26'),
    (108, 'Speech', '2025-26'),
    (110, 'Speech', '2025-26');

INSERT INTO Meetings (club_name, school_year, meeting_id, meeting_date, start_time, end_time, classroom_id, meeting_description) VALUES
    ('Band', '2024-25', 1, '2024-09-10', '15:15:00', '16:15:00', 101, 'First rehearsal and instrument assignments'),
    ('MathCounts', '2024-25', 1, '2024-09-11', '15:30:00', '16:30:00', 102, 'Problem-solving practice'),
    ('Robotics', '2024-25', 1, '2024-09-12', '15:15:00', '17:00:00', 104, 'Robot design kickoff'),
    ('Band', '2025-26', 1, '2025-09-08', '15:15:00', '16:15:00', 101, 'Welcome meeting and fall concert planning'),
    ('MathCounts', '2025-26', 1, '2025-09-08', '15:15:00', '16:15:00', 102, 'Competition overview and team practice'),
    ('Robotics', '2025-26', 1, '2025-09-08', '16:30:00', '17:30:00', 101, 'Build team safety training'),
    ('Speech', '2025-26', 1, '2025-09-09', '15:15:00', '16:00:00', 103, 'Speech topic selection'),
    ('Choir', '2025-26', 1, '2025-09-09', '16:15:00', '17:00:00', 103, 'Voice placement and rehearsal');

INSERT INTO FieldTrips (club_name, school_year, trip_id, trip_date, start_time, end_time, trip_location, trip_description) VALUES
    ('Band', '2024-25', 1, '2024-12-06', '09:00:00', '14:00:00', 'City Music Hall', 'Attend winter performance'),
    ('Robotics', '2024-25', 1, '2025-02-20', '08:30:00', '15:30:00', 'Regional STEM Center', 'Robotics scrimmage'),
    ('Band', '2025-26', 1, '2025-12-05', '09:00:00', '14:00:00', 'City Music Hall', 'Attend winter performance'),
    ('MathCounts', '2025-26', 1, '2026-01-17', '08:00:00', '13:00:00', 'County Middle School', 'MathCounts chapter competition'),
    ('Robotics', '2025-26', 1, '2026-02-14', '08:30:00', '15:30:00', 'Regional STEM Center', 'Robotics tournament'),
    ('Speech', '2025-26', 1, '2026-03-07', '08:00:00', '12:30:00', 'Central High School', 'Speech showcase');

INSERT INTO Expenses (club_name, school_year, expense_id, expense_date, amount, expense_description) VALUES
    ('Band', '2024-25', 1, '2024-09-20', 425.00, 'Sheet music and reeds'),
    ('MathCounts', '2024-25', 1, '2024-10-05', 150.00, 'Practice workbooks'),
    ('Robotics', '2024-25', 1, '2024-10-12', 875.00, 'Robot parts'),
    ('Band', '2025-26', 1, '2025-09-12', 500.00, 'Instrument repairs'),
    ('Band', '2025-26', 2, '2025-10-03', 300.00, 'Concert music'),
    ('Choir', '2025-26', 1, '2025-09-18', 210.00, 'Folders and sheet music'),
    ('MathCounts', '2025-26', 1, '2025-09-22', 175.00, 'Competition registration'),
    ('MathCounts', '2025-26', 2, '2025-10-02', 95.00, 'Practice materials'),
    ('Robotics', '2025-26', 1, '2025-09-25', 950.00, 'Microcontrollers and sensors'),
    ('Robotics', '2025-26', 2, '2025-10-06', 400.00, 'Tournament registration'),
    ('Speech', '2025-26', 1, '2025-09-28', 125.00, 'Practice binders');