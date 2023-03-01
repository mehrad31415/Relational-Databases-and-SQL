/*
Students at your hometown high school have decided to organize their social network using databases. 

So far, they have collected information about sixteen students in four grades, 9-12. 

Here's the schema:

Highschooler ( ID, name, grade )
English: There is a high school student with unique ID and a given first name in a certain grade.

Friend ( ID1, ID2 )
English: The student with ID1 is friends with the student with ID2. Friendship is mutual, so if (123, 456) is in the Friend table, so is (456, 123).

Likes ( ID1, ID2 )
English: The student with ID1 likes the student with ID2. Liking someone is not necessarily mutual, so if (123, 456) is in the Likes table, there is no guarantee that (456, 123) is also present.
*/


/* Delete the tables if they already exist */
drop table if exists Highschooler;
drop table if exists Friend;
drop table if exists Likes;

/* Create the schema for our tables */
create table Highschooler(ID int, name text, grade int);
create table Friend(ID1 int, ID2 int);
create table Likes(ID1 int, ID2 int);

/* Populate the tables with our data */
insert into Highschooler values (1510, 'Jordan', 9);
insert into Highschooler values (1689, 'Gabriel', 9);
insert into Highschooler values (1381, 'Tiffany', 9);
insert into Highschooler values (1709, 'Cassandra', 9);
insert into Highschooler values (1101, 'Haley', 10);
insert into Highschooler values (1782, 'Andrew', 10);
insert into Highschooler values (1468, 'Kris', 10);
insert into Highschooler values (1641, 'Brittany', 10);
insert into Highschooler values (1247, 'Alexis', 11);
insert into Highschooler values (1316, 'Austin', 11);
insert into Highschooler values (1911, 'Gabriel', 11);
insert into Highschooler values (1501, 'Jessica', 11);
insert into Highschooler values (1304, 'Jordan', 12);
insert into Highschooler values (1025, 'John', 12);
insert into Highschooler values (1934, 'Kyle', 12);
insert into Highschooler values (1661, 'Logan', 12);

insert into Friend values (1510, 1381);
insert into Friend values (1510, 1689);
insert into Friend values (1689, 1709);
insert into Friend values (1381, 1247);
insert into Friend values (1709, 1247);
insert into Friend values (1689, 1782);
insert into Friend values (1782, 1468);
insert into Friend values (1782, 1316);
insert into Friend values (1782, 1304);
insert into Friend values (1468, 1101);
insert into Friend values (1468, 1641);
insert into Friend values (1101, 1641);
insert into Friend values (1247, 1911);
insert into Friend values (1247, 1501);
insert into Friend values (1911, 1501);
insert into Friend values (1501, 1934);
insert into Friend values (1316, 1934);
insert into Friend values (1934, 1304);
insert into Friend values (1304, 1661);
insert into Friend values (1661, 1025);
insert into Friend select ID2, ID1 from Friend;

insert into Likes values(1689, 1709);
insert into Likes values(1709, 1689);
insert into Likes values(1782, 1709);
insert into Likes values(1911, 1247);
insert into Likes values(1247, 1468);
insert into Likes values(1641, 1468);
insert into Likes values(1316, 1304);
insert into Likes values(1501, 1934);
insert into Likes values(1934, 1501);
insert into Likes values(1025, 1101);


/*
Query 1: Find the names of all students who are friends with someone named Gabriel.
*/

SELECT name
FROM (SELECT ID1
FROM Friend
WHERE ID2 in (SELECT ID FROM Highschooler WHERE name = 'Gabriel')) G INNER JOIN Highschooler
WHERE G.ID1=Highschooler.ID;

/*
Query 2: For every student who likes someone 2 or more grades younger than themselves, return that student's name and grade, and the name and grade of the student they like.
*/

SELECT H1.name, H1.grade,  H2.name, H2.grade
FROM likes, highschooler H1, highschooler H2
WHERE likes.ID1=H1.ID and likes.ID2=H2.ID and abs(H2.grade-H1.grade)>1;

/*
Query 3: For every pair of students who both like each other, return the name and grade of both students. Include each pair only once, with the two names in alphabetical order.
*/

SELECT H1.name, H1.grade, H2.name, H2.grade
FROM (SELECT L1.ID1,L1.ID2
FROM likes L1, likes L2
WHERE L1.ID1=L2.ID2 and L1.ID2=L2.ID1 and L1.ID1>L1.ID2) G, highschooler H1, highschooler H2
WHERE G.id1=H1.id and G.id2=H2.id and H1.name <= H2.name
UNION
SELECT H2.name, H2.grade, H1.name, H1.grade
FROM (SELECT L1.ID1,L1.ID2
FROM likes L1, likes L2
WHERE L1.ID1=L2.ID2 and L1.ID2=L2.ID1 and L1.ID1>L1.ID2) G, highschooler H1, highschooler H2
WHERE G.id1=H1.id and G.id2=H2.id and H1.name > H2.name;

/*
Query 4: Find all students who do not appear in the Likes table (as a student who likes or is liked) and return their names and grades. Sort by grade, then by name within each grade.
*/

SELECT name, grade
FROM highschooler
WHERE id not in (SELECT ID1 as id
FROM likes
UNION
SELECT ID2
FROM likes)
ORDER BY grade, name;

/*
Query 5: For every situation where student A likes student B, but we have no information about whom B likes (that is, B does not appear as an ID1 in the Likes table), return A and B's names and grades.
*/

SELECT H1.name, H1.grade, H2.name, H2.grade
FROM (SELECT *
FROM likes
WHERE ID2 not in 
	(
    SELECT ID1
    FROM likes
	)) G, highschooler H1, highschooler H2
WHERE H1.id=G.id1 and H2.id=G.id2;

/*
Query 6: Find names and grades of students who only have friends in the same grade. Return the result sorted by grade, then by name within each grade.
*/

SELECT name, grade
FROM highschooler
WHERE ID not in (
SELECT ID1
FROM friend, highschooler H1, highschooler H2
WHERE ID1=H1.id and ID2=H2.id and H1.grade <> H2.grade
UNION
SELECT ID2
FROM friend, highschooler H1, highschooler H2
WHERE ID1=H1.id and ID2=H2.id and H1.grade <> H2.grade)
ORDER BY grade, name;

/*
Query 7: For each student A who likes a student B where the two are not friends, find if they have a friend C in common (who can introduce them!). For all such trios, return the name and grade of A, B, and C.
*/

SELECT H1.name, H1.grade, H2.name, H2.grade, H3.name, H3.grade
FROM (SELECT G.ID1 as ID1, G.ID2 as ID2, F1.ID2 as ID3
FROM (SELECT *
FROM likes
EXCEPT
SELECT L.ID1, L.ID2
FROM likes L, friend F
WHERE L.ID1 = F.ID1 and L.ID2 = F.ID2) G, Friend F1, Friend F2
WHERE G.ID1=F1.ID1 and G.ID2=F2.ID1 and F1.ID2=F2.ID2) W, highschooler H1, highschooler H2, highschooler H3
WHERE W.ID1=H1.ID and W.ID2=H2.ID and W.ID3=H3.ID;

/*
Query 8: Find the difference between the number of students in the school and the number of different first names.
*/

SELECT abs(SUM(a))
FROM (SELECT -COUNT(ID) as a
FROM Highschooler
UNION
SELECT COUNT(Distinct name)
FROM Highschooler) G;

/*
Query 9: Find the name and grade of all students who are liked by more than one other student.
*/

SELECT name, grade
FROM (SELECT ID2, COUNT(*) as a
FROM Likes
GROUP BY (ID2)
HAVING a>=2) G, Highschooler H
WHERE G.ID2=H.ID;

-- without count and having
/*
SELECT name,grade
FROM (SELECT L1.ID2 as id
FROM Likes L1, Likes L2
WHERE L1.ID2=L2.ID2 and L1.ID1>L2.ID1) G, highschooler H
WHERE G.id=H.id;
*/

/*QUERY EXTRAS*/

/*
QUERY 1: For every situation where student A likes student B, but student B likes a different student C, return the names and grades of A, B, and C.
*/

SELECT H1.name, H1.grade, H2.name, H2.grade, H3.name, H3.grade
FROM (SELECT l1.ID1 as ID1, l1.ID2 as ID2, L2.ID2 as ID3
FROM Likes l1, Likes l2
WHERE l1.ID2=l2.ID1 and l1.ID1<>l2.ID2) G, highschooler H1, highschooler H2, highschooler H3
WHERE H1.ID=G.ID1 and H2.ID=G.ID2 and H3.ID=G.ID3;

/*
QUERY 2: Find those students for whom all of their friends are in different grades from themselves. Return the students' names and grades.
*/

SELECT DISTINCT name, grade
FROM (SELECT ID1
FROM Friend F1
WHERE not exists (
	SELECT *
    FROM Friend F2, highschooler H1, highschooler H2
    WHERE F2.ID1 = F1.ID1 and H1.ID=F2.ID1 and H2.ID=F2.ID2 and H1.grade=H2.grade
    )) G, highschooler HM
WHERE G.ID1=HM.ID;

/*
QUERY 3: What is the average number of friends per student? (Your result should be just one number.)
*/

SELECT c1 / c2 -- in mysql this will result into 2.5 but in sqlite this will result into 2. 
FROM (SELECT COUNT(*) as c1
FROM Friend) G1,
(SELECT COUNT(*) as c2
FROM Highschooler) G2;

/*
QUERY 4: Find the number of students who are either friends with Cassandra or are friends of friends of Cassandra. Do not count Cassandra, even though technically she is a friend of a friend.
*/

SELECT COUNT(*)
FROM (SELECT ID2
FROM Friend
WHERE ID1 = (SELECT ID
FROM highschooler
WHERE name = 'Cassandra')
UNION
SELECT ID2
FROM Friend F2
WHERE ID1 in (SELECT ID2
FROM Friend F1
WHERE ID1 = (SELECT ID
FROM highschooler
WHERE name = 'Cassandra')) and F2.ID2 <> (SELECT ID
FROM highschooler
WHERE name = 'Cassandra')) E;

/*
QUERY 5: Find the name and grade of the student(s) with the greatest number of friends.
*/

SELECT name,grade
FROM highschooler
WHERE id in (SELECT id2
FROM (SELECT MAX(c1) as m
FROM (SELECT ID1 as id1, COUNT(ID2) as c1
FROM Friend
GROUP BY ID1) E1) E3
INNER JOIN
(SELECT ID1 as id2, COUNT(ID2) as c2
FROM Friend
GROUP BY ID1) E2
WHERE E3.m = E2.c2);

/*QUERY related to MODIFICATION*/

/*
QUERY 1: It's time for the seniors to graduate. Remove all 12th graders from Highschooler.
*/

DELETE FROM Highschooler
WHERE grade= 12;

/*
QUERY 2: If two students A and B are friends, and A likes B but not vice-versa, remove the Likes tuple.
*/

DELETE FROM likes
WHERE (ID1,ID2) in 
	(
    SELECT L1.ID1, L1.ID2
	FROM Likes L1, Friend F1
	WHERE L1.ID1=F1.ID1 and L1.ID2=F1.ID2 and L1.ID1 not in 
	(
    SELECT L2.ID2
    FROM Likes L2
    WHERE L2.ID1=L1.ID2
	)
    );

/*
QUERY 3: For all cases where A is friends with B, and B is friends with C, add a new friendship for the pair A and C. Do not add duplicate friendships, friendships that already exist, or friendships with oneself. (This one is a bit challenging; congratulations if you get it right.)
*/

SELECT DISTINCT F1.ID1, F2.ID2
FROM Friend F1, Friend F2
WHERE F1.ID2=F2.ID1 and F1.ID1<>F2.ID2 and (F1.ID1, F2.ID2) NOT IN (SELECT * FROM FRIEND);