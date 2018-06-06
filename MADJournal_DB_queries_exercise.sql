/* 1. Date of the latest entry from the user "yehudit". */

SELECT users.username, MAX(entries.date) AS last_entry_date_for_yehudit
FROM entries
JOIN journals
  ON entries.journal_id = journals.id
JOIN users
  ON journals.user_id = users.id
WHERE users.username = 'yehudit'
GROUP BY users.username;

/* alternative solution */
SELECT MAX(date) as last_entry_date_for_yehudit
FROM entries
WHERE journal_id = (
  SELECT id
  FROM journals
  WHERE user_id = (
    SELECT id
    FROM users
    WHERE username = 'yehudit'));

/* 2. List of users sorted by the number of entries in their journal. Most active users at the top of the list. */

SELECT users.username, COUNT(entries.*)
FROM users
JOIN journals
  ON users.id = journals.user_id
JOIN entries
  ON journals.id = entries.journal_id
GROUP BY users.username
ORDER BY COUNT(entries.*) DESC;

/* 3. List of users sorted by the latest activity (users with the most recent additions or modifications at the top of the list). */

SELECT users.username, MAX(entries.date) as latest_entry_date
FROM users
JOIN journals
  ON users.id = journals.user_id
JOIN entries
  ON journals.id = entries.journal_id
GROUP BY users.username
ORDER BY latest_entry_date DESC;

/* 4. List of users who in April added at least 4 entries. */

SELECT users.username, COUNT(entries.*) as entries_number
FROM users
JOIN journals
  ON users.id = journals.user_id
JOIN entries
  ON journals.id = entries.journal_id
WHERE entries.date BETWEEN '2018-04-01 00:00:00' AND '2018-04-30 23:59:59'
GROUP BY users.username
HAVING COUNT(entries.*) >= 4;

/* 5. List of users who in April added more entries than other users on average. */

SELECT users.username, COUNT(entries.*) as entries_number
FROM users
JOIN journals
  ON users.id = journals.user_id
JOIN entries
  ON journals.id = entries.journal_id
WHERE entries.date BETWEEN '2018-04-01 00:00:00' AND '2018-04-30 23:59:59'
GROUP BY username
HAVING COUNT(entries.*) > (SELECT COUNT(*)/COUNT(DISTINCT journal_id) FROM entries);

/* 6. List of users sorted by their average entry length. Authors of the longest posts on average at the top. */

SELECT users.username, ROUND(AVG(LENGTH(entries.content)),2) AS entry_length_avg
FROM entries
JOIN journals
  ON entries.journal_id = journals.id
JOIN users
  ON journals.user_id = users.id
GROUP BY users.username
ORDER BY entry_length_avg DESC;

/* 7. List of users whose average entry length over the last nine weeks was greater than overall average length of posts in that period. */

SELECT journal_id, users.username, ROUND(AVG(length(content)),2) AS entry_length_avg
FROM entries
JOIN journals
  ON entries.journal_id = journals.id
JOIN users
  ON journals.user_id = users.id
WHERE date BETWEEN LOCALTIMESTAMP - INTERVAL '9 weeks' AND LOCALTIMESTAMP
GROUP BY journal_id, users.username
HAVING ROUND(AVG(length(content)),2) > (SELECT ROUND(AVG(length(entries.content)),2) FROM entries)
ORDER BY journal_id;
