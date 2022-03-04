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