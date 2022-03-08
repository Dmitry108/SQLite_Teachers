-- homework 2
.open teachers.db

CREATE TABLE teachers (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	surname TEXT NOT NULL,
	name TEXT NOT NULL,
	email TEXT
);

CREATE TABLE courses (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	course TEXT NOT NULL
);

CREATE TABLE streams (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	course_id INTEGER NOT NULL,
	number INTEGER NOT NULL UNIQUE,
	start_date TEXT NOT NULL,
	students_amount INTEGER NOT NULL,
	FOREIGN KEY (course_id) REFERENCES courses(id)
);

CREATE TABLE grades (
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
-- .headers on
-- .mode column
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