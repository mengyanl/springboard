/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 1 of the case study, which means that there'll be more guidance for you about how to 
setup your local SQLite connection in PART 2 of the case study. 

The questions in the case study are exactly the same as with Tier 2. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */
Select name From Facilities
Where membercost > 0.0;

/* Q2: How many facilities do not charge a fee to members? */
Select count(facid) From Facilities
Where membercost = 0.0;

/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */
Select Facid, name, membercost, monthlymaintenance
From Facilities
Where membercost > 0.0 and membercost < 0.2*monthlymaintenance;

/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */
Select * From Facilities
Where facid IN (1, 5);

/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */
Select name, monthlymaintenance,
Case When monthlymaintenance > 100 Then 'expensive'
     Else 'cheap' END As exp
From Facilities;

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */
SELECT surname, firstname, Max(joindate)
FROM Members;

/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */
SELECT DISTINCT sub1.name, Names.wholename
From (select F.name, F.facid, B.memid From Facilities AS F
     inner Join Bookings as B
     ON B.facid = F. facid
     Where F.name LIKE 'tennis%') AS sub1
Inner join (SELECT memid, CONCAT(firstname, ' ', surname) AS wholename FROM Members) as Names
ON sub1.memid = Names.memid
order by wholename


/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

/* This is from Reza */
SELECT f.name AS fac, CONCAT(m.firstname,' ',m.surname) AS member,
	CASE WHEN b.memid = 0 THEN f.guestcost * b.slots
	ELSE f.membercost * b.slots END AS cost
FROM Bookings AS b
	LEFT JOIN Facilities AS f
		ON b.facid = f.facid
	LEFT JOIN Members AS m
		ON b.memid = m.memid
WHERE b.starttime LIKE '2012-09-14%'
HAVING cost > 30
ORDER BY cost DESC;


/* Select name, wholename, cost From
(Select F.name,CONCAT(firstname, ' ', surname) AS wholename, 
       Case When B.memid = 0 Then (B.slots*F.guestcost)
       Else (B.slots*F.membercost) END AS cost
From Facilities as F
Inner join Bookings as B
ON F.facid = B.facid
Inner Join Members as M
ON B.memid = M.memid
Where B.starttime LIKE '2012-09-14%') As X
Where cost >30.0
Order by Cost DESC; */


/* Q9: This time, produce the same result as in Q8, but using a subquery. */
Select Sub1.name,
       CONCAT(firstname, ' ', surname) AS wholename,
       Cost
From (Select F.name, F.facid, B.memid, 
      Case When B.memid = 0 Then (B.slots*F.guestcost)
      Else (B.slots*F.membercost) END AS Cost
      From Facilities as F
      Inner join Bookings as B
      ON F.facid = B.facid
      Where B.starttime LIKE '2012-09-14%') as Sub1
Inner Join Members as M
ON Sub1.memid = M.memid
Where Cost > 30.0
Order by Cost DESC;
       

/* PART 2: SQLite
/* We now want you to jump over to a local instance of the database on your machine. 

Copy and paste the LocalSQLConnection.py script into an empty Jupyter notebook, and run it. 

Make sure that the SQLFiles folder containing thes files is in your working directory, and
that you haven't changed the name of the .db file from 'sqlite\db\pythonsqlite'.

You should see the output from the initial query 'SELECT * FROM FACILITIES'.

Complete the remaining tasks in the Jupyter interface. If you struggle, feel free to go back
to the PHPMyAdmin interface as and when you need to. 

You'll need to paste your query into value of the 'query1' variable and run the code block again to get an output.
 
QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

Select Final.name, Final.revenue
From (
Select Cal.name, sum(Cal.cost) as revenue
From (Select F.name, 
       Case When B.memid = 0 Then (F.guestcost*B.slots)
       Else (F.membercost*B.slots) End AS cost
From Facilities as F
Inner Join Bookings as B
ON F.facid=B.facid
) As Cal
Group by name
order by revenue) As Final
Where revenue < 1000.0

       
/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */
Select 
      L.surname, L.firstname, 
      R.surname As R_surname, R.firstname As R_firstname
From Members as L
Inner Join Members as R
ON L.recommendedby = R.memid 
Where L.recommendedby <> 0
Order by L.surname, L.firstname

/* Q12: Find the facilities with their usage by member, but not guests */

Select 
       F.name AS Name,
       sum(B.slots) As fusage
From Facilities As F
Inner Join Bookings As B
ON F.facid = B.facid
Where B.memid <> 0
Group by Name
Order by fusage


/* Q13: Find the facilities usage by month, but not guests */

SELECT strftime('%Y %m', B.starttime) AS Month,
       F.name,
       sum(B.slots) As MemberUsage
From Facilities As F
Inner Join Bookings As B
ON F.facid = B.facid
Where B.memid <> 0
Group by name, Month

/* This is for MySQL */
Select YEAR(B.starttime) As Year,
       MONTH(B.starttime) As Month, 
       F.name,
       sum(B.slots) As MemberUsage
From Facilities As F
Inner Join Bookings As B
ON F.facid = B.facid
Where B.memid <> 0
Group by name,Year, Month


