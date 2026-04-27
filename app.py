import getpass
import mysql.connector
import os

password = getpass.getpass("MySQL password: ")

db = mysql.connector.connect(
    host="localhost",
    user="alex",
    password="alex123",
    database="AfterSchoolClubs"
)

cursor = db.cursor()


def show(sql, values=()):
    try:
        cursor.execute(sql, values)
        rows = cursor.fetchall()
        columns = cursor.column_names

        # Compute max width for each column
        col_widths = []
        for i in range(len(columns)):
            max_len = len(columns[i])
            for row in rows:
                max_len = max(max_len, len(str(row[i])))
            col_widths.append(max_len)

        # Print header
        header = " | ".join(columns[i].ljust(col_widths[i]) for i in range(len(columns)))
        print("\n" + header)

        # Print separator
        print("-" * len(header))

        # Print rows
        for row in rows:
            print(" | ".join(str(row[i]).ljust(col_widths[i]) for i in range(len(row))))

        input("\nPress Enter to return to menu...")

    except mysql.connector.Error as error:
        print("Error:", error)


def change(sql, values=()):
	try:
		cursor.execute(sql, values)
		db.commit()
		print("Done.")
	except mysql.connector.Error as error:
		db.rollback()
		print("Error:", error)


def meeting_conflict(club_name, school_year, meeting_date, start_time, end_time, classroom_id):
	sql = """
		SELECT COUNT(*)
		FROM Meetings
		WHERE meeting_date = %s
			AND %s < end_time
			AND %s > start_time
			AND (classroom_id = %s OR (club_name = %s AND school_year = %s))
	"""
	cursor.execute(sql, (meeting_date, start_time, end_time, classroom_id, club_name, school_year))
	return cursor.fetchone()[0] > 0


while True:
	os.system("clear")
	print("==================================")
	print("After-School Club Database")
	print("==================================")
	print("0. Quit")
	print("1. View a table")
	print("2. Add meeting")
	print("3. Delete meeting")
	print("4. Add field trip")
	print("5. Delete field trip")
	print("6. Update club budget")
	print("7. Add expense")
	print("8. Assign faculty advisor")
	print("9. Student joins club")
	print("10. Student leaves club")
	print("11. Students in a club/year")
	print("12. Clubs and advisors for a year")
	print("13. Meetings and field trips for a club/year")
	print("14. Expenses and remaining budget")
	print("15. Total budget for a year")
	print("16. Clubs advised by faculty")
	print("17. Clubs for a student")
	print("18. Student events on a date")

	choice = input("Choose: ")

	if choice == "0":
		break

	elif choice == "1":
		table = input("Table name: ")
		if table in ["Clubs", "Faculty", "Students", "YearlyClubs", "Membership", "Meetings", "FieldTrips", "Expenses"]:
			show("SELECT * FROM " + table)
		else:
			print("Invalid table name.")

	elif choice == "2":
		club_name = input("Club name: ")
		school_year = input("School year: ")
		meeting_id = input("Meeting ID: ")
		meeting_date = input("Meeting date YYYY-MM-DD: ")
		start_time = input("Start time HH:MM:SS: ")
		end_time = input("End time HH:MM:SS: ")
		classroom_id = input("Classroom ID: ")
		description = input("Description: ")

		if meeting_conflict(club_name, school_year, meeting_date, start_time, end_time, classroom_id):
			print("Meeting not added because it has a scheduling conflict.")
			input("\nPress Enter to return to menu...")
		else:
			sql = """
				INSERT INTO Meetings
				(club_name, school_year, meeting_id, meeting_date, start_time, end_time, classroom_id, meeting_description)
				VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
			"""
			change(sql, (club_name, school_year, meeting_id, meeting_date, start_time, end_time, classroom_id, description))

	elif choice == "3":
		club_name = input("Club name: ")
		school_year = input("School year: ")
		meeting_id = input("Meeting ID: ")
		change("DELETE FROM Meetings WHERE club_name = %s AND school_year = %s AND meeting_id = %s", (club_name, school_year, meeting_id))

	elif choice == "4":
		club_name = input("Club name: ")
		school_year = input("School year: ")
		trip_id = input("Trip ID: ")
		trip_date = input("Trip date YYYY-MM-DD: ")
		start_time = input("Start time HH:MM:SS: ")
		end_time = input("End time HH:MM:SS: ")
		location = input("Location: ")
		description = input("Description: ")
		sql = """
			INSERT INTO FieldTrips
			(club_name, school_year, trip_id, trip_date, start_time, end_time, trip_location, trip_description)
			VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
		"""
		change(sql, (club_name, school_year, trip_id, trip_date, start_time, end_time, location, description))

	elif choice == "5":
		club_name = input("Club name: ")
		school_year = input("School year: ")
		trip_id = input("Trip ID: ")
		change("DELETE FROM FieldTrips WHERE club_name = %s AND school_year = %s AND trip_id = %s", (club_name, school_year, trip_id))

	elif choice == "6":
		club_name = input("Club name: ")
		school_year = input("School year: ")
		budget = input("New budget: ")
		change("UPDATE YearlyClubs SET budget = %s WHERE club_name = %s AND school_year = %s", (budget, club_name, school_year))

	elif choice == "7":
		club_name = input("Club name: ")
		school_year = input("School year: ")
		expense_id = input("Expense ID: ")
		expense_date = input("Expense date YYYY-MM-DD: ")
		amount = float(input("Amount: "))
		description = input("Description: ")
		# Get budget and current expenses
		sql = """
			SELECT yc.budget, IFNULL(SUM(e.amount), 0)
			FROM YearlyClubs yc
			LEFT JOIN Expenses e
			ON yc.club_name = e.club_name AND yc.school_year = e.school_year
			WHERE yc.club_name = %s AND yc.school_year = %s
			GROUP BY yc.budget
		"""
		
		cursor.execute(sql, (club_name, school_year))
		result = cursor.fetchone()

		if result:
			budget, current_expenses = result
			budget = float(budget)
			current_expenses = float(current_expenses)

			# Check if new expense exceeds budget
			if current_expenses + amount > budget:
				print("Cannot add expense: exceeds club budget.")
				input("\nPress Enter to return to menu...")
			else:
				# Insert if valid
				insert_sql = """
					INSERT INTO Expenses
					(club_name, school_year, expense_id, expense_date, amount, expense_description)
					VALUES (%s, %s, %s, %s, %s, %s)
				"""
				change(insert_sql, (club_name, school_year, expense_id, expense_date, amount, description))
		else:
			print("Club/year not found.")

	elif choice == "8":
		club_name = input("Club name: ")
		school_year = input("School year: ")
		faculty_id = input("Faculty ID: ")
		change("UPDATE YearlyClubs SET faculty_id = %s WHERE club_name = %s AND school_year = %s", (faculty_id, club_name, school_year))

	elif choice == "9":
		student_id = input("Student ID: ")
		club_name = input("Club name: ")
		school_year = input("School year: ")
		change("INSERT INTO Membership (student_id, club_name, school_year) VALUES (%s, %s, %s)", (student_id, club_name, school_year))

	elif choice == "10":
		student_id = input("Student ID: ")
		club_name = input("Club name: ")
		school_year = input("School year: ")
		change("DELETE FROM Membership WHERE student_id = %s AND club_name = %s AND school_year = %s", (student_id, club_name, school_year))

	elif choice == "11":
		club_name = input("Club name: ")
		school_year = input("School year: ")
		sql = """
			SELECT Students.student_id, Students.student_name
			FROM Students
			JOIN Membership ON Students.student_id = Membership.student_id
			WHERE Membership.club_name = %s AND Membership.school_year = %s
		"""
		show(sql, (club_name, school_year))

	elif choice == "12":
		school_year = input("School year: ")
		sql = """
			SELECT YearlyClubs.club_name, Faculty.faculty_name
			FROM YearlyClubs
			JOIN Faculty ON YearlyClubs.faculty_id = Faculty.faculty_id
			WHERE YearlyClubs.school_year = %s
		"""
		show(sql, (school_year,))

	elif choice == "13":
		club_name = input("Club name: ")
		school_year = input("School year: ")
		sql = """
			SELECT 'Meeting' AS event_type, meeting_date, start_time, end_time, classroom_id, meeting_description
			FROM Meetings
			WHERE club_name = %s AND school_year = %s
			UNION ALL
			SELECT 'Field Trip' AS event_type, trip_date, start_time, end_time, trip_location, trip_description
			FROM FieldTrips
			WHERE club_name = %s AND school_year = %s
		"""
		show(sql, (club_name, school_year, club_name, school_year))

	elif choice == "14":
		club_name = input("Club name: ")
		school_year = input("School year: ")
		sql = """
			SELECT YearlyClubs.club_name, YearlyClubs.school_year, YearlyClubs.budget,
				IFNULL(SUM(Expenses.amount), 0) AS total_expenses,
				YearlyClubs.budget - IFNULL(SUM(Expenses.amount), 0) AS remaining_budget
			FROM YearlyClubs
			LEFT JOIN Expenses
				ON YearlyClubs.club_name = Expenses.club_name
				AND YearlyClubs.school_year = Expenses.school_year
			WHERE YearlyClubs.club_name = %s AND YearlyClubs.school_year = %s
			GROUP BY YearlyClubs.club_name, YearlyClubs.school_year, YearlyClubs.budget
		"""
		show(sql, (club_name, school_year))

	elif choice == "15":
		school_year = input("School year: ")
		show("SELECT school_year, SUM(budget) AS total_budget FROM YearlyClubs WHERE school_year = %s GROUP BY school_year", (school_year,))

	elif choice == "16":
		faculty_id = input("Faculty ID: ")
		sql = """
			SELECT Faculty.faculty_name, YearlyClubs.club_name, YearlyClubs.school_year
			FROM Faculty
			JOIN YearlyClubs ON Faculty.faculty_id = YearlyClubs.faculty_id
			WHERE Faculty.faculty_id = %s
		"""
		show(sql, (faculty_id,))

	elif choice == "17":
		student_id = input("Student ID: ")
		sql = """
			SELECT Students.student_name, Membership.club_name, Membership.school_year
			FROM Students
			JOIN Membership ON Students.student_id = Membership.student_id
			WHERE Students.student_id = %s
		"""
		show(sql, (student_id,))

	elif choice == "18":
		student_id = input("Student ID: ")
		event_date = input("Date YYYY-MM-DD: ")
		sql = """
			SELECT Meetings.club_name, 'Meeting' AS event_type, Meetings.meeting_date,
				Meetings.start_time, Meetings.end_time, Meetings.classroom_id,
				Meetings.meeting_description
			FROM Membership
			JOIN Meetings
				ON Membership.club_name = Meetings.club_name
				AND Membership.school_year = Meetings.school_year
			WHERE Membership.student_id = %s AND Meetings.meeting_date = %s
			UNION ALL
			SELECT FieldTrips.club_name, 'Field Trip' AS event_type, FieldTrips.trip_date,
				FieldTrips.start_time, FieldTrips.end_time, FieldTrips.trip_location,
				FieldTrips.trip_description
			FROM Membership
			JOIN FieldTrips
				ON Membership.club_name = FieldTrips.club_name
				AND Membership.school_year = FieldTrips.school_year
			WHERE Membership.student_id = %s AND FieldTrips.trip_date = %s
		"""
		show(sql, (student_id, event_date, student_id, event_date))

	else:
		print("Invalid option.")


cursor.close()
db.close()
print("Goodbye.")
