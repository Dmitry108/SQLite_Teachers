-- homework 2
.open teachers.db

DROP TABLE IF EXISTS teachers;
CREATE TABLE IF NOT EXISTS teachers (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	surname TEXT NOT NULL,
	name TEXT NOT NULL,
	email TEXT
);

DROP TABLE IF EXISTS courses;
CREATE TABLE IF NOT EXISTS courses (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	course TEXT NOT NULL
);

DROP TABLE IF EXISTS streams;
CREATE TABLE IF NOT EXISTS streams (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	course_id INTEGER NOT NULL,
	number INTEGER NOT NULL UNIQUE,
	start_date TEXT NOT NULL,
	students_amount INTEGER NOT NULL,
	FOREIGN KEY (course_id) REFERENCES courses(id)
);

DROP TABLE IF EXISTS grades;
CREATE TABLE IF NOT EXISTS grades (
	teacher_id INTEGER NOT NULL,
	stream_id INTEGER NOT NULL,
	grade REAL NOT NULL,
	PRIMARY KEY (teacher_id, stream_id),
	FOREIGN KEY (teacher_id) REFERENCES teachers(id),
	FOREIGN KEY (stream_id) REFERENCES streams(id)
);

.schema

-- homework 3
-- .open teachers.db
-- .tables
-- .schema streams

ALTER TABLE streams RENAME COLUMN start_date TO started_at;
-- ALTER TABLE streams ADD COLUMN finished_at TEXT;
-- .schema streams

INSERT INTO teachers (name, surname, email) VALUES
	('Николай', 'Савельев', 'saveliev.n@mai.ru'),
	('Наталья', 'Петрова', 'petrova.n@yandex.ru'),
	('Елена', 'Малышева', 'malisheva.e@google.com');
INSERT INTO courses (course) VALUES 
	('Базы данных'), 
	('Основы Python'),
	('Linux. Рабочая станция');
INSERT INTO streams (course_id, number, started_at, students_amount) VALUES
	(3, 165, '18.08.2020', 34),
	(2, 178, '02.10.2020', 37),
	(1, 203, '12.11.2020', 35),
	(1, 210, '03.12.2020', 41);
INSERT INTO grades (teacher_id, stream_id, grade) VALUES
	(3, 1, 4.7),
	(2, 2, 4.9),
	(1, 3, 4.8),
	(1, 4, 4.9);
.headers on
.mode column
SELECT * FROM teachers;
SELECT * FROM courses;
SELECT * FROM streams;
SELECT * FROM grades;

-- ALTER TABLE grades RENAME TO grades_old;
-- CREATE TABLE grades (
	-- teacher_id INTEGER NOT NULL,
	-- stream_id REAL NOT NULL,
	-- grade REAL NOT NULL,
	-- PRIMARY KEY (teacher_id, stream_id),
	-- FOREIGN KEY (teacher_id) REFERENCES teachers(id),
	-- FOREIGN KEY (stream_id) REFERENCES streams(id)
-- );
-- INSERT INTO grades SELECT * FROM grades_old;
-- DROP TABLE grades_old;
-- .tables
-- SELECT * FROM grades;

-- homework 4
-- task 1
UPDATE streams SET started_at = SUBSTR(started_at, 7, 4) || '-' || SUBSTR(started_at, 4, 2) || '-' || SUBSTR(started_at, 1, 2);
.headers on
.mode column
SELECT * FROM streams;

-- task 2
SELECT id, number FROM streams ORDER BY started_at DESC LIMIT 1;

-- task 3
SELECT DISTINCT(SUBSTR(started_at, 1, 4)) FROM streams;

-- task 4
SELECT COUNT(*) AS total_teachers FROM teachers;

-- task 5
SELECT started_at FROM streams ORDER BY started_at DESC LIMIT 2;

-- task 6
SELECT AVG(grade) AS avg_grade FROM grades WHERE teacher_id = 1;

-- task 7
SELECT teacher_id, AVG(grade) AS avg_grade FROM grades GROUP BY teacher_id HAVING avg_grade < 4.8;

-- homework 5
-- task 1
-- Найдите потоки, количество учеников в которых больше или равно 40. 
-- В отчет выведите номер потока, название курса и количество учеников.
SELECT number,
	(SELECT course FROM courses WHERE courses.id = streams.course_id) AS 'course',
	students_amount
FROM streams WHERE streams.students_amount >= 40; 

-- task 2
-- Найдите два потока с самыми низкими значениями успеваемости. 
-- В отчет выведите номер потока, название курса, фамилию и имя преподавателя (одним столбцом), оценку успеваемости.
SELECT 
	(SELECT number FROM streams WHERE id = grades.stream_id) AS 'stream_id',
	(SELECT course FROM courses WHERE id = 
		(SELECT course_id FROM streams WHERE streams.id = grades.stream_id)) AS 'course',
	(SELECT surname || " " || name FROM teachers WHERE teachers.id = grades.teacher_id) AS 'surname and name',
	grade
FROM grades ORDER BY grade ASC LIMIT 2;

-- task 3
-- Найдите среднюю успеваемость всех потоков преподавателя Николая Савельева. 
-- В отчёт выведите идентификатор преподавателя и среднюю оценку по потокам.
SELECT teacher_id, AVG(grade) AS avg_grade FROM grades WHERE grades.teacher_id =
	(SELECT id FROM teachers WHERE teachers.surname LIKE 'Савельев' AND teachers.name LIKE 'Николай');

-- task 4
-- Найдите потоки преподавателя Натальи Петровой, а также потоки, по которым успеваемость ниже 4.8. 
-- В отчёт выведите идентификатор потока, фамилию и имя преподавателя.	
-- решение с помощью UNION
SELECT 
	stream_id,
	(SELECT surname || " " || name FROM teachers WHERE teachers.id = grades.teacher_id) AS 'surname and name'
FROM grades
WHERE grades.teacher_id = 
	(SELECT id FROM teachers WHERE teachers.surname LIKE 'Петрова' AND teachers.name LIKE 'Наталья')
UNION
SELECT 
	stream_id,
	(SELECT surname || " " || name FROM teachers WHERE teachers.id = grades.teacher_id) AS 'surname and name'
FROM grades
WHERE grades.grade < 4.8;

-- решение в стиле "Don't repeat yourself"
SELECT 
	stream_id,
	(SELECT surname || " " || name FROM teachers WHERE teachers.id = grades.teacher_id) AS 'surname and name'
FROM grades
WHERE grades.teacher_id = 
	(SELECT id FROM teachers WHERE teachers.surname LIKE 'Петрова' AND teachers.name LIKE 'Наталья')
	OR
	grades.grade < 4.8;

-- task 5
-- Дополнительное задание. Найдите разницу между средней успеваемостью преподавателя с наивысшим соответствующим значением 
-- и средней успеваемостью преподавателя с наименьшим значением. Средняя успеваемость считается по всем потокам преподавателя.
SELECT MAX(avg_grade) - MIN(avg_grade) FROM
	(SELECT AVG(grade) AS avg_grade FROM grades GROUP BY grades.teacher_id);

-- homework 6
-- task 1
-- Покажите информацию по потокам. В отчет выведите номер потока, название курса и дату начала занятий.
SELECT number, course, started_at 
FROM streams JOIN courses 
ON courses.id = streams.course_id;

-- task 2
-- Найдите общее количество учеников для каждого курса. 
-- В отчёт выведите название курса и количество учеников по всем потокам курса.
SELECT course, SUM(students_amount) 
FROM streams JOIN courses ON courses.id = streams.course_id
GROUP BY course;

-- task 3
-- Для всех учителей найдите среднюю оценку по всем проведённым потокам. 
-- В отчёт выведите идентификатор, фамилию и имя учителя, среднюю оценку по всем проведенным потокам. 
-- Важно чтобы учителя, у которых не было потоков, также попали в выборку.
SELECT id, surname, name, AVG(grade) AS avg_grade
FROM teachers LEFT JOIN grades ON teachers.id = grades.teacher_id
GROUP BY teachers.id;

-- task 4
-- Для каждого преподавателя выведите имя, фамилию, минимальное значение успеваемости по всем потокам преподавателя, 
-- название курса, который соответствует потоку с минимальным значением успеваемости, 
-- максимальное значение успеваемости по всем потокам преподавателя, 
-- название курса, соответствующий потоку с максимальным значением успеваемости, 
-- дату начала следующего потока.
SELECT
	name,
	surname,
	min_grade,
	course_min,
	max_grade,
	course_max,
	(SELECT 
		MIN(started_at) 
	FROM streams JOIN grades ON streams.id = grades.stream_id 
	WHERE started_at > date('2020-09-01') AND grades.teacher_id = teachers.id) 
	AS next_stream_at
FROM teachers 
	JOIN (SELECT 
			grade AS min_grade, 
			course AS course_min, 
			stream_id AS stream_min, 
			teacher_id AS teacher_min
		FROM grades 
			JOIN streams ON streams.id = stream_min 
			JOIN courses ON streams.course_id = courses.id
		GROUP BY teacher_id
		HAVING MIN(grade)) 
	ON teacher_min = teachers.id
	JOIN (SELECT
			grade AS max_grade, 
			course AS course_max, 
			stream_id AS stream_max, 
			teacher_id AS teacher_max
		FROM grades 
			JOIN streams ON streams.id = stream_max 
			JOIN courses ON streams.course_id = courses.id
		GROUP BY teacher_id
		HAVING MAX(grade)) 
	ON teacher_max = teachers.id;

-- Решение с применением только JOIN
SELECT
	name || " " || surname AS name_surname,
	MIN(grades.grade || " " || courses.course) AS min_grade,
	MAX(grades.grade || " " || courses.course) AS max_grade,
	MIN(date_streams.started_at)
FROM teachers 
	JOIN grades ON teachers.id = grades.teacher_id
	JOIN streams ON grades.stream_id = streams.id
	JOIN courses ON streams.course_id = courses.id
	LEFT JOIN streams AS date_streams 
	ON date_streams.course_id = courses.id AND date_streams.started_at > DATE('2020-09-01')
GROUP BY teachers.id;

-- homework 7
-- task 1
-- Создайте представление, которое для каждого курса выводит название, номер последнего потока, 
-- дату начала обучения последнего потока и среднюю успеваемость курса по всем потокам.
DROP VIEW IF EXISTS courses_info;
CREATE VIEW courses_info AS SELECT
	courses.course,
	streams.number,
	streams.started_at,
	AVG(grades.grade) AS avg_grade
	FROM courses
		LEFT JOIN streams ON courses.id = streams.course_id
		LEFT JOIN grades ON streams.id = grades.stream_id
	GROUP BY courses.course HAVING MAX(streams.started_at);
SELECT * FROM courses_info;

-- task 2
-- Удалите из базы данных всю информацию, которая относится к преподавателю с идентификатором, равным 3. 
-- Используйте транзакцию.
BEGIN TRANSACTION;
	-- DELETE FROM streams WHERE streams.id = (SELECT stream_id FROM grades WHERE teacher_id = 3);
	DELETE FROM grades WHERE grades.teacher_id = 3;
	DELETE FROM teachers WHERE teachers.id = 3;
COMMIT;
SELECT * FROM streams;
SELECT * FROM grades;
SELECT * FROM teachers;

-- task 3
-- Создайте триггер для таблицы успеваемости, который проверяет значение успеваемости 
-- на соответствие диапазону чисел от 0 до 5 включительно.
CREATE TRIGGER on_insert_grade BEFORE INSERT ON grades
BEGIN
	SELECT CASE
		WHEN NEW.grade NOT BETWEEN 1 AND 5
		THEN RAISE (ABORT, 'Incorrect grade')
	END;
END;
INSERT INTO grades (teacher_id, stream_id, grade) VALUES (2, 5, 4.7);

-- task 4
-- Создайте триггер для таблицы потоков, который проверяет, что дата начала потока больше текущей даты, 
-- а номер потока имеет наибольшее значение среди существующих номеров. При невыполнении условий необходимо вызвать ошибку с информативным сообщением.
DROP TRIGGER IF EXISTS on_insert_date_stream;
CREATE TRIGGER on_insert_date_stream BEFORE INSERT ON streams
BEGIN
	SELECT CASE
		WHEN NEW.started_at <= DATE('now')
			OR NEW.number <= (SELECT MAX(number) FROM streams)
		THEN RAISE (ABORT, 'Incorrect date of start or number!')
	END;
END;

-- homework 8
-- task 1
-- Найдите общее количество учеников для каждого курса. 
-- В отчёт выведите название курса и количество учеников по всем потокам курса. 
-- Решите задание с применением оконных функций.
SELECT DISTINCT
	course,
	SUM(students_amount) OVER(PARTITION BY streams.course_id) AS total_amount
	FROM courses
		LEFT JOIN streams ON streams.course_id = courses.id;

-- task 2
-- Найдите среднюю оценку по всем потокам для всех учителей. 
-- В отчёт выведите идентификатор, фамилию и имя учителя, среднюю оценку по всем проведённым потокам. 
-- Учителя, у которых не было потоков, также должны попасть в выборку. Решите задание с применением оконных функций.
SELECT DISTINCT
	teachers.id,
	teachers.surname,
	teachers.name,
	AVG(grades.grade) OVER(PARTITION BY grades.teacher_id) AS avg_grade
	FROM teachers LEFT JOIN grades ON grades.teacher_id = teachers.id;

-- task 3
-- Какие индексы надо создать для максимально быстрого выполнения представленного запроса?
-- SELECT surname, name, number, performance 
-- FROM academic_performance JOIN teachers ON academic_performance.teacher_id = teachers.id
-- 		JOIN streams ON academic_performance.stream_id = streams.id
-- WHERE number >= 200;
CREATE INDEX streams_number_idx ON streams(number);
CREATE INDEX teachers_surmane_name_idx ON teachers(surname, name);
-- индекс по первичному ключу в таблице grades уже есть по умолчанию

-- task 4
-- Установите SQLiteStudio, подключите базу данных учителей, выполните в графическом клиенте любой запрос.

-- task 5
-- Для каждого преподавателя выведите имя, фамилию, минимальное значение успеваемости по всем потокам преподавателя, 
-- название курса, который соответствует потоку с минимальным значением успеваемости, 
-- максимальное значение успеваемости по всем потокам преподавателя, название курса, 
-- соответствующий потоку с максимальным значением успеваемости, дату начала следующего потока. 
-- Выполните задачу с использованием оконных функций.
SELECT DISTINCT
	name,
	surname,
	FIRST_VALUE(grade) OVER(grades_asc) AS min_grade,
	FIRST_VALUE(course) OVER(grades_asc) AS course_min,
	FIRST_VALUE(grade) OVER(grades_desc) AS max_grade,
	FIRST_VALUE(course) OVER(grades_desc) AS course_max,
	'next_stream_at'
FROM teachers 
	JOIN grades ON teachers.id = grades.teacher_id
	JOIN streams ON grades.stream_id = streams.id
	JOIN courses ON streams.course_id = courses.id
	LEFT JOIN streams AS date_streams 
	ON date_streams.course_id = courses.id AND date_streams.started_at > DATE('2020-09-01')
WINDOW
	grades_asc AS (PARTITION BY teachers.id ORDER BY grade ASC),
	grades_desc AS (PARTITION BY teachers.id ORDER BY grade DESC)
;

SELECT
	name,
	surname,
	course,
	grade
	FROM teachers
	JOIN grades ON teachers.id = grades.teacher_id
	JOIN streams ON grades.stream_id = streams.id
	JOIN courses ON streams.course_id = courses.id;

-- Решение с применением только JOIN
SELECT
	name || " " || surname AS name_surname,
	MIN(grades.grade || " " || courses.course) AS min_grade,
	MAX(grades.grade || " " || courses.course) AS max_grade,
	MIN(date_streams.started_at)
FROM teachers 
	JOIN grades ON teachers.id = grades.teacher_id
	JOIN streams ON grades.stream_id = streams.id
	JOIN courses ON streams.course_id = courses.id
	LEFT JOIN streams AS date_streams 
	ON date_streams.course_id = courses.id AND date_streams.started_at > DATE('2020-09-01')
GROUP BY teachers.id;

INSERT INTO streams (course_id, number, started_at, students_amount) VALUES
	(3, 215, '2021-02-01', 35),
	(2, 220, '2021-02-21', 38);
INSERT INTO grades (teacher_id, stream_id, grade) VALUES
	(2, 5, 4.7),
	(3, 6, 4.8);
UPDATE grades SET stream_id  = 7 WHERE teacher_id = 2 AND stream_id = 5;
UPDATE grades SET stream_id  = 8 WHERE teacher_id = 3 AND stream_id = 6;