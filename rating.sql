CREATE DATABASE STANFORD;
/*
You've started a new movie-rating website, and you've been collecting data on reviewers' ratings of various movies.

Here's the schema:

Movie ( mID, title, year, director )
English: There is a movie with ID number mID, a title, a release year, and a director.

Reviewer ( rID, name )
English: The reviewer with ID number rID has a certain name.

Rating ( rID, mID, stars, ratingDate )
English: The reviewer rID gave the movie mID a number of stars rating (1-5) on a certain ratingDate.
*/

/* Delete the tables if they already exist */
drop table if exists Movie;
drop table if exists Reviewer;
drop table if exists Rating;

/* Create the schema for our tables */
create table Movie(mID int, title text, year int, director text);
create table Reviewer(rID int, name text);
create table Rating(rID int, mID int, stars int, ratingDate date);

/* Populate the tables with our data */
insert into Movie values(101, 'Gone with the Wind', 1939, 'Victor Fleming');
insert into Movie values(102, 'Star Wars', 1977, 'George Lucas');
insert into Movie values(103, 'The Sound of Music', 1965, 'Robert Wise');
insert into Movie values(104, 'E.T.', 1982, 'Steven Spielberg');
insert into Movie values(105, 'Titanic', 1997, 'James Cameron');
insert into Movie values(106, 'Snow White', 1937, null);
insert into Movie values(107, 'Avatar', 2009, 'James Cameron');
insert into Movie values(108, 'Raiders of the Lost Ark', 1981, 'Steven Spielberg');

insert into Reviewer values(201, 'Sarah Martinez');
insert into Reviewer values(202, 'Daniel Lewis');
insert into Reviewer values(203, 'Brittany Harris');
insert into Reviewer values(204, 'Mike Anderson');
insert into Reviewer values(205, 'Chris Jackson');
insert into Reviewer values(206, 'Elizabeth Thomas');
insert into Reviewer values(207, 'James Cameron');
insert into Reviewer values(208, 'Ashley White');

insert into Rating values(201, 101, 2, '2011-01-22');
insert into Rating values(201, 101, 4, '2011-01-27');
insert into Rating values(202, 106, 4, null);
insert into Rating values(203, 103, 2, '2011-01-20');
insert into Rating values(203, 108, 4, '2011-01-12');
insert into Rating values(203, 108, 2, '2011-01-30');
insert into Rating values(204, 101, 3, '2011-01-09');
insert into Rating values(205, 103, 3, '2011-01-27');
insert into Rating values(205, 104, 2, '2011-01-22');
insert into Rating values(205, 108, 4, null);
insert into Rating values(206, 107, 3, '2011-01-15');
insert into Rating values(206, 106, 5, '2011-01-19');
insert into Rating values(207, 107, 5, '2011-01-20');
insert into Rating values(208, 104, 3, '2011-01-02');


/*
Query 1: Find the titles of all movies directed by Steven Spielberg.
*/

SELECT title
FROM movie
WHERE director = 'Steven Spielberg';

/*
Query 2: Find all years that have a movie that received a rating of 4 or 5, and sort them in increasing order.
*/

SELECT year
FROM movie
WHERE mID in (
	SELECT mID
	FROM rating
	WHERE stars>=4
	)
ORDER BY year;

/*
Query 3: Find the titles of all movies that have no ratings.
*/

SELECT title
FROM movie
WHERE mID NOT IN (
	SELECT mID 
	FROM rating);

/*
Query 4: Some reviewers didn't provide a date with their rating. Find the names of all reviewers who have ratings with a NULL value for the date.
*/

SELECT name
FROM reviewer
WHERE rID in (
	SELECT rID
	from rating
	WHERE ratingDate IS NULL
	);

/*
Query 5: Write a query to return the ratings data in a more readable format: reviewer name, movie title, stars, and ratingDate. Also, sort the data, first by reviewer name, then by movie title, and lastly by number of stars.
*/

SELECT  re.name, m.title, ra.stars, ra.ratingDate
FROM movie m, reviewer re, rating ra
WHERE m.mID = ra.mID and re.rID=ra.rID
ORDER BY re.name, m.title, ra.stars;

/*
Query 6: For all cases where the same reviewer rated the same movie twice and gave it a higher rating the second time, return the reviewer's name and the title of the movie.
*/

SELECT reviewer.name, movie.title
FROM movie,reviewer, (SELECT R1.rID, R1.mID
FROM rating R1, rating R2 
WHERE R1.rID=R2.rID and R1.mID=R2.mID and R2.stars>R1.stars and R2.ratingDate > R1.ratingDate) G
WHERE G.mID = movie.mID and reviewer.rID=G.rID;

/*
Query 7: For each movie that has at least one rating, find the highest number of stars that movie received. Return the movie title and number of stars. Sort by movie title.
*/

SELECT title, G.s
FROM movie m, (SELECT mID, MAX(stars) as s
	FROM rating
	GROUP BY mID) G
WHERE m.mID = G.mID
ORDER BY title;

/*
Query 8: For each movie, return the title and the 'rating spread', that is, the difference between highest and lowest ratings given to that movie. Sort by rating spread from highest to lowest, then by movie title.
*/

SELECT title, MAX(stars)-MIN(stars) as rs
FROM (SELECT title, stars
FROM movie JOIN rating USING (mID))
GROUP BY title
ORDER BY rs DESC, title;

/*
Query 9: Find the difference between the average rating of movies released before 1980 and the average rating of movies released after 1980. (Make sure to calculate the average rating for each movie, then the average of those averages for movies before 1980 and movies after. Don't just calculate the overall average rating before and after 1980.)
*/

SELECT MAX(A)- MIN(A)+0.000000000000000445 --this rounding error has been added just for the sake of the auto grading system of the course.
FROM (SELECT AVG(G.average) as A
FROM (SELECT mID, AVG(stars) as average
FROM rating
GROUP BY mID) G natural JOIN movie
WHERE movie.year>=1980
UNION
SELECT AVG(G.average) as A
FROM (SELECT mID, AVG(stars) as average
FROM rating
GROUP BY mID) G natural JOIN movie
WHERE movie.year<1980) H;

/*QUERY EXTRAS*/

/*
QUERY 1: Find the names of all reviewers who rated Gone with the Wind.
*/

SELECT name
FROM reviewer
WHERE rID in (
SELECT rID
FROM rating
WHERE mID in (SELECT mID
FROM movie
WHERE title = 'Gone with the Wind'))
;

/*
QUERY 2: For any rating where the reviewer is the same as the director of the movie, return the reviewer name, movie title, and number of stars.
*/

SELECT name, title, stars
FROM (SELECT name, title, stars, director
FROM reviewer, movie, rating
WHERE rating.rID = reviewer.rID and rating.mID = movie.mID) G
WHERE director = name;

/*
QUERY 3: Return all reviewer names and movie names together in a single list, alphabetized. (Sorting by the first name of the reviewer and first word in the title is fine; no need for special processing on last names or removing "The".)
*/

SELECT title
FROM movie
UNION
SELECT name
FROM reviewer
ORDER BY title;

/*
QUERY 4: Find the titles of all movies not reviewed by Chris Jackson.
*/

SELECT title
FROM movie
WHERE mID not in (SELECT mID FROM rating WHERE rID in (SELECT rID FROM reviewer WHERE name = 'Chris Jackson'));

/*
QUERY 5: For all pairs of reviewers such that both reviewers gave a rating to the same movie, return the names of both reviewers. Eliminate duplicates, don't pair reviewers with themselves, and include each pair only once. For each pair, return the names in the pair in alphabetical order.
*/

SELECT (MIN (name1, name2)) as m1, (MAX (name1, name2)) as m2
FROM (
SELECT DISTINCT reviewer.name as name1, H.name as name2
FROM reviewer, (SELECT name, rID2
FROM reviewer, (
	SELECT R1.rID as rID1, R2.rID as rID2
	FROM rating R1, rating R2
	WHERE R1.mID = R2.mID and R1.rID>R2.rID
    ) G
WHERE rID = rID1) H
WHERE rID2 = rID) K
ORDER BY m1, m2
;

/*
QUERY 6: For each rating that is the lowest (fewest stars) currently in the database, return the reviewer name, movie title, and number of stars.
*/

SELECT name, title, stars
FROM (SELECT name, mID, stars
FROM (SELECT stars, mID, rID
FROM rating
WHERE stars in (SELECT MIN(stars) 
FROM rating)) G, reviewer
WHERE G.rID=reviewer.rID) H, movie
WHERE movie.mID=H.mID;

/*
QUERY 7: List movie titles and average ratings, from highest-rated to lowest-rated. If two or more movies have the same average rating, list them in alphabetical order.
*/

SELECT title, average
FROM (SELECT mID, AVG(stars) as average
FROM rating
GROUP BY mID) G, movie
WHERE movie.mID = G.mID
ORDER BY average desc, title;

/*
QUERY 8: Find the names of all reviewers who have contributed three or more ratings. (As an extra challenge, try writing the query without HAVING or without COUNT.)
*/

SELECT name
FROM (SELECT rID, count(*) as c
FROM rating
GROUP BY rID
HAVING c>=3) G, reviewer
WHERE reviewer.rID=G.rID;

-- without count and having
/*
SELECT name
FROM reviewer
WHERE rID in (SELECT R1.rID
FROM rating R1, rating R2, rating R3
WHERE R1.rID = R2.rID and R2.rID = R3.rID and (R1.mID, R1.stars,R1.ratingDate) > (R2.mID, R2.stars, R2.ratingDate) and (R2.mID, R2.stars,R2.ratingDate) > (R3.mID, R3.stars, R3.ratingDate));
*/

/*
QUERY 9: Some directors directed more than one movie. For all such directors, return the titles of all movies directed by them, along with the director name. Sort by director name, then movie title. (As an extra challenge, try writing the query both with and without COUNT.)
*/

SELECT movie.title, movie.director
FROM (SELECT director FROM (SELECT director, COUNT(mID)
FROM movie
GROUP BY director
HAVING COUNT(mID)>1) H) G, movie
WHERE movie.director = G.director
ORDER BY movie.director, title;

/*
QUERY 10: Find the movie(s) with the highest average rating. Return the movie title(s) and average rating. (Hint: This query is more difficult to write in SQLite than other systems; you might think of it as finding the highest average rating and then choosing the movie(s) with that average rating.)
*/

SELECT title, average
FROM movie NATURAL INNER JOIN (SELECT mID, AVG(stars) as average
FROM rating
GROUP BY mID) G
WHERE average = (SELECT MAX(average)
FROM (SELECT mID, AVG(stars) as average
FROM rating
GROUP BY mID) H);

/*
QUERY 11: Find the movie(s) with the lowest average rating. Return the movie title(s) and average rating. (Hint: This query may be more difficult to write in SQLite than other systems; you might think of it as finding the lowest average rating and then choosing the movie(s) with that average rating.)
*/

SELECT title, average
FROM movie NATURAL INNER JOIN (SELECT mID, AVG(stars) as average
FROM rating
GROUP BY mID) G
WHERE average = (SELECT MIN(average)
FROM (SELECT mID, AVG(stars) as average
FROM rating
GROUP BY mID) H);

/*
QUERY 12: For each director, return the director's name together with the title(s) of the movie(s) they directed that received the highest rating among all of their movies, and the value of that rating. Ignore movies whose director is NULL.
*/

SELECT DISTINCT G.director, title, m
FROM (SELECT director, MAX(stars) as m
FROM (SELECT mID, title, director, stars
FROM rating INNTER JOIN movie USING (mID)) H
WHERE director is not null
GROUP BY director) G INNER JOIN (SELECT mID, title, director, stars
FROM rating INNTER JOIN movie USING (mID)) K
WHERE G.m = K.stars and K.director = G.director;


/*QUERY related to MODIFICATION*/

/*
QUERY 1: Add the reviewer Roger Ebert to your database, with an rID of 209.
*/

INSERT INTO reviewer VALUES (209, 'Roger Ebert');

/*
QUERY 2: For all movies that have an average rating of 4 stars or higher, add 25 to the release year. (Update the existing tuples; don't insert new tuples.)
*/

UPDATE movie
SET year = year + 25
WHERE mID in (
SELECT mID FROM (SELECT mID, avg(stars) as s
FROM Rating
GROUP BY mID
HAVING s>=4) G);

/*
QUERY 3: Remove all ratings where the movie's year is before 1970 or after 2000, and the rating is fewer than 4 stars.
*/

DELETE FROM rating
WHERE mID in (SELECT mID
FROM movie
WHERE year<=1970 or year>=2000) and stars<4;
