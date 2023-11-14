-- Again, fn+F9 to run queries
-- Select the line you wanna run and fn+F9
-- long press command and click on the table name I SELECT to view the data types in a popped-out window

/* the crime was a "​murder"​ that occurred sometime on ​Jan.15, 2018​ 
and that it took place in ​SQL City​.
*/
SELECT * FROM crime_scene_report
WHERE date == 20180115
AND
type == 'murder'
AND
city == 'SQL City'; -- the report found

/* From the report, we know that the Security footage shows that there were 2 witnesses. 
The first witness lives at the last house on "Northwestern Dr". 
The second witness, named Annabel, lives somewhere on "Franklin Ave". */

SELECT * FROM person
WHERE address_street_name == 'Northwestern Dr'
ORDER BY address_number desc; -- The first witness: Morty Schapiro with id 14887

SELECT * FROM person 
WHERE address_street_name == 'Franklin Ave'
AND
/* To use wildcard to select girls with the first name called Annabel, you need to use LIKE but not ==,
refer to https://mystery.knightlab.com/walkthrough.html */
/* % wildcard in a query string, the SQL system will return results that match the rest of the string exactly, 
and have anything (or nothing) where the wildcard is */
name LIKE '%Annabel%'; -- The second witness: Annabel Miller with id 16371

-- Go to the interview table to see what they said
SELECT * FROM interview
WHERE person_id == 14887
OR person_id == 16371;
/* 14887: I heard a gunshot and then saw a man run out. He had a "Get Fit Now Gym" bag. 
The membership number on the bag started with "48Z". Only gold members have those bags. 
The man got into a car with a plate that included "H42W". */
/* 16371: I saw the murder happen, and I recognized the killer from my gym 
when I was working out last week on January the 9th. */

-- Go to the two gym tables to find the suspect
-- Merge the two clues together --
SELECT * FROM get_fit_now_member
JOIN get_fit_now_check_in
ON
get_fit_now_member.id == get_fit_now_check_in.membership_id
WHERE get_fit_now_member.id LIKE '48Z%'
AND
get_fit_now_member.membership_status == 'gold'
AND
get_fit_now_check_in.check_in_date == 20180109; -- Still the same two suspects as from clue 1

--** I want to join the person table from the license id to find out its id to match with the results above
SELECT * FROM person
JOIN drivers_license
ON person.license_id == drivers_license.id
WHERE plate_number LIKE '%H42W%'; -- I am certain that the suspect is Jeremy Bowers with person id 67318


-- To test my answer (copy the below and paste it on https://mystery.knightlab.com/)
INSERT INTO solution VALUES (1, 'Jeremy Bowers');  
        SELECT value FROM solution;
/*Congrats, you found the murderer! But wait, there's more... If you think you're up for a challenge, 
try querying the interview transcript of the murderer to find the real villain behind this crime. 
If you feel especially confident in your SQL skills, try to complete this final step with no more 
than 2 queries. Use this same INSERT statement with your new suspect to check your answer. */

-- Time to master my SQL skills --
-- Query 1
SELECT * FROM interview
WHERE person_id == 67318;
/* I was hired by a woman with a lot of money. 
I don't know her name but I know she's around 5'5" (65") or 5'7" (67"). 
She has red hair and she drives a Tesla Model S. 
I know that she attended the SQL Symphony Concert 3 times in December 2017.
*/
-- Query 2
-- Below is the useful info from each table with * as the keys to use for join 
-- For person table: *id, name, *license_id
-- For drivers_license table: *license_id, height, hair_color, car_model
-- For fb event table: *person_id, event_id, event_name, date
-- To me, after trying, I think I need to use WITH to make a temp table for the event first
WITH temp AS(
SELECT * FROM facebook_event_checkin
WHERE event_name == 'SQL Symphony Concert' AND
date LIKE '201712%'
GROUP BY person_id
HAVING COUNT(*) == 3
) -- in aggregation, only HAVING is allowed but not WHERE. ALSO, I should group by first before using conditions
--SELECT * FROM temp; -- 24556 or 99716. It worked!

SELECT id, name FROM person
JOIN drivers_license
ON person.license_id == drivers_license.id
JOIN temp
ON person.id == temp.person_id
WHERE drivers_license.height BETWEEN 65 AND 67
AND
drivers_license.hair_color == 'red'
AND
drivers_license.car_model == 'Model S'; -- If I want to be more precise, I can specify the car_make is Tesla, but no need here.

-- Final check
INSERT INTO solution VALUES (1, 'Miranda Priestly');  
        SELECT value FROM solution; -- Done!
        