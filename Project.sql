CREATE TABLE IF NOT EXISTS Clubs (
	club_name VARCHAR(50) PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS Faculty (
	faculty_id INT PRIMARY KEY,
	faculty_name VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS Students (
	student_id INT PRIMARY KEY,
	student_name VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS YearlyClubs (
	club_name VARCHAR(50) NOT NULL references Clubs(club_name),
	school_year CHAR(7) NOT NULL,
	PRIMARY KEY (club_name, school_year),
	faculty_id INT NOT NULL references Faculty(faculty_id),
	budget DECIMAL(8, 2) NOT NULL CHECK (budget >= 0)

);

CREATE TABLE IF NOT EXISTS Membership (
	student_id INT NOT NULL references Students(student_id),
	club_name VARCHAR(50) NOT NULL,
	school_year CHAR(7) NOT NULL,
	PRIMARY KEY (student_id, club_name, school_year),
	FOREIGN KEY (club_name, school_year) REFERENCES YearlyClubs(club_name, school_year)
);

CREATE TABLE IF NOT EXISTS Meetings (
	club_name VARCHAR(50) NOT NULL,
	school_year CHAR(7) NOT NULL,
	meeting_id INT NOT NULL,
	PRIMARY KEY (club_name, school_year, meeting_id),
	meeting_date DATE NOT NULL,
	start_time TIME NOT NULL,
	end_time TIME NOT NULL CHECK (end_time > start_time),
	classroom_id INT NOT NULL,
	meeting_description VARCHAR(255) NOT NULL,
	FOREIGN KEY (club_name, school_year) REFERENCES YearlyClubs(club_name, school_year)
	
);

CREATE TABLE IF NOT EXISTS FieldTrips (
	club_name VARCHAR(50) NOT NULL,
	school_year CHAR(7) NOT NULL,
	trip_id INT NOT NULL,
	PRIMARY KEY (club_name, school_year, trip_id),
	trip_date DATE NOT NULL,
	start_time TIME NOT NULL,
	end_time TIME NOT NULL CHECK (end_time > start_time),
	trip_location VARCHAR(255) NOT NULL,
	trip_description VARCHAR(255) NOT NULL,
	FOREIGN KEY (club_name, school_year) REFERENCES YearlyClubs(club_name, school_year)
);

CREATE TABLE IF NOT EXISTS Expenses (
	club_name VARCHAR(50) NOT NULL,
	school_year CHAR(7) NOT NULL,
	expense_id INT NOT NULL,
	PRIMARY KEY (club_name, school_year, expense_id),
	expense_date DATE NOT NULL,
	amount DECIMAL(8, 2) NOT NULL CHECK (amount >= 0),
	expense_description VARCHAR(255) NOT NULL,
	FOREIGN KEY (club_name, school_year) REFERENCES YearlyClubs(club_name, school_year)
);