/* Abel Jara
 * SQL PA1 CSE 132a
 * PID: A10584942
 */
/* PART A */
.mode columns
.headers on
create table sailor (
	sname char not null, 
	rating integer,
	PRIMARY KEY (sname));

create table boat (
	bname char not null, 
	color char not null, 
	rating integer not null,
	PRIMARY KEY (bname));

create table reservation (
	sname char not null, 
	bname char not null, 
	day char not null,
	FOREIGN KEY (bname) REFERENCES boat,
	FOREIGN KEY (sname) REFERENCES sailor);

create table alldays 
	(day char not null);

insert into sailor values ('Brutus', 1);
insert into sailor values  ('Andy', 8);
insert into sailor values ('Horatio', 7);
insert into sailor values ('Rusty', 8);
insert into sailor values ('Bob', 1);

insert into boat values ('SpeedQueen', 'white', 9);
insert into boat values ('Interlake', 'red', 8);
insert into boat values ('Marine', 'blue', 7);
insert into boat values ('Bay', 'red', 3);

insert into reservation values ('Andy', 'Interlake', 'Monday');
insert into reservation values ('Andy', 'Bay', 'Wednesday');
insert into reservation values ('Andy', 'Marine', 'Saturday');
insert into reservation values ('Rusty', 'Bay', 'Sunday');
insert into reservation values ('Rusty', 'Interlake', 'Wednesday');
insert into reservation values ('Rusty', 'Marine', 'Wednesday');
insert into reservation values ('Bob', 'Bay', 'Monday');

insert into alldays values ('Sunday');
insert into alldays values ('Monday');
insert into alldays values ('Tuesday');
insert into alldays values ('Wednesday');
insert into alldays values ('Thursday');
insert into alldays values ('Friday');
insert into alldays values ('Saturday');

/* PART B */
SELECT * FROM sailor, boat, reservation;

/* PART C #1 */
SELECT boat.bname, color FROM reservation, boat
WHERE day = 'Wednesday' AND reservation.bname = boat.bname;

/* PART C #2 (i) */
SELECT sname FROM sailor
WHERE rating = (SELECT MAX(rating) FROM sailor);

/* PART C #2 (ii) */
SELECT sname FROM sailor
WHERE rating NOT IN (SELECT s1.rating FROM sailor s1, sailor s2
		     WHERE s1.rating < s2.rating);

/* PART C #3 */
SELECT DISTINCT r1.sname, r2.sname FROM reservation r1, reservation r2
WHERE r1.day = r2.day 
AND r1.sname <> r2.sname
AND r1.sname < r2.sname; 

/* PART C #4 */
SELECT r1.day, COUNT( distinct r1.bname) as numOfBoats 
FROM reservation r1, boat b1
WHERE r1.bname = b1.bname AND b1.color = 'red' 
AND EXISTS (SELECT COUNT(r2.bname) FROM reservation r2, alldays a1
	    WHERE r2.day = a1.day) -- FIX THE DAYS WHERE NO RESERVATION
GROUP BY day;

/* PART C #5 */
SELECT DISTINCT day FROM reservation
WHERE day NOT IN (SELECT r.day FROM reservation r1, boat b1
		  WHERE r1.bname = b1.bname AND b1.color <> 'red');

/* PART C #6 */ -- FIX
SELECT DISTINCT day FROM reservation
WHERE day NOT IN (SELECT r1.day FROM reservation r1, boat b1
		  WHERE r1.bname = b1.bname AND b1.color <> 'red');

/* PART C #7 */
-- NOT IN PORTION
SELECT DISTINCT day FROM reservation
WHERE day NOT IN (SELECT r1.day FROM reservation r1, boat b1
		  WHERE b1.color = 'red' 
		  AND r1.day NOT IN (SELECT day FROM reservation
				     WHERE  b1.bname = bname));
-- NOT EXISTS
SELECT DISTINCT a.day FROM alldays a
WHERE NOT EXISTS (SELECT * FROM boat b
		  WHERE b.color = 'red'
		  AND NOT EXISTS (SELECT * FROM reservation r
		  WHERE r.day = a.day
		  AND r.bname = b.bname));
-- COUNT
SELECT DISTINCT a.day FROM (SELECT r.day, COUNT(*) AS numRedBoat
			    FROM reservation r, boat b
			    WHERE r.bname = b.bname
			    AND b.color = 'red'
			    GROUP BY r.day)a
		GROUP BY a.day
		HAVING a.numRedBoat = (SELECT COUNT(*) as total
				       FROM boat b
				       WHERE b.color ='red');

/* PART C #8 */
SELECT DISTINCT r1.day, AVG(s1.rating) FROM sailor s1, reservation r1, boat b1
WHERE r1.bname = b1.bname AND r1.sname = s1.sname
GROUP BY day;

/* PART C #9 */
SELECT MAX(day) AS BusiestDay FROM reservation;

/* PART E */
SELECT r.sname, s.rating, r.bname, b.rating, r.day 
FROM reservation r, boat b, sailor s
WHERE r.sname = s.sname AND r.bname = b.bname
AND s.rating < b.rating;

/* PART F */
-- 1.
UPDATE reservation
SET day = CASE 
WHEN day = "Monday" THEN "Wednesday" 
WHEN day = "Wednesday" THEN "Monday"
WHEN day = "Sunday" THEN "Sunday"
WHEN day = "Tuesday" THEN "Tuesday"
WHEN day = "Thursday" THEN "Thursday"
WHEN day = "Friday" THEN "Friday"
WHEN day = "Saturday" THEN "Saturday"
END;

-- 2.
DELETE FROM reservation
WHERE sname IN (SELECT r.sname FROM reservation r, boat b, sailor s
		WHERE r.sname = s.sname
		AND r.bname = b.bname 
		AND s.rating < b.rating);

/* PART G */
SELECT * FROM reservation;
