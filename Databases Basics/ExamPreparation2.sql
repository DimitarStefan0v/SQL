CREATE DATABASE [School]

USE [School]

--1

CREATE TABLE Students(
	Id INT PRIMARY KEY IDENTITY,
	FirstName NVARCHAR(30) NOT NULL,
	MiddleName NVARCHAR(25),
	LastName NVARCHAR(30) NOT NULL,
	Age TINYINT CHECK(Age >= 5 AND Age <= 100),
	[Address] NVARCHAR(50),
	Phone NCHAR(10)
)

CREATE TABLE Subjects(
	Id INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(20) NOT NULL,
	Lessons INT NOT NULL CHECK(Lessons > 0)
)

CREATE TABLE StudentsSubjects(
	Id INT PRIMARY KEY IDENTITY,
	StudentId INT NOT NULL REFERENCES Students(Id),
	SubjectId INT NOT NULL REFERENCES Subjects(Id),
	Grade DECIMAL(3, 2) NOT NULL CHECK(Grade >= 2 AND Grade <= 6)
)

CREATE TABLE Exams(
	Id INT PRIMARY KEY IDENTITY,
	[Date] DATETIME2,
	SubjectId INT NOT NULL REFERENCES Subjects(Id)
)

CREATE TABLE StudentsExams(
	StudentId INT NOT NULL REFERENCES Students(Id),
	ExamId INT NOT NULL REFERENCES Exams(Id),
	Grade DECIMAL(3, 2) NOT NULL CHECK(Grade >= 2 AND Grade <= 6),
	PRIMARY KEY(StudentId, ExamId)
)

CREATE TABLE Teachers(
	Id INT PRIMARY KEY IDENTITY,
	FirstName NVARCHAR(20) NOT NULL,
	LastName NVARCHAR(20) NOT NULL,
	[Address] NVARCHAR(20) NOT NULL,
	Phone CHAR(10),
	SubjectId INT NOT NULL REFERENCES Subjects(Id)
)

CREATE TABLE StudentsTeachers(
	StudentId INT NOT NULL REFERENCES Students(Id),
	TeacherId INT NOT NULL REFERENCES Teachers(Id),
	PRIMARY KEY(StudentId, TeacherId)
)

--2

INSERT INTO Teachers(FirstName, LastName, [Address], Phone, SubjectId)
	VALUES('Ruthanne', 'Bamb', '84948 Mesta Junction', '3105500146', 6),
		  ('Gerrard', 'Lowin', '370 Talisman Plaza', '3324874824', 2),
		  ('Merrile', 'Lambdin', '81 Dahle Plaza', '4373065154', 5),
		  ('Bert', 'Ivie', '2 Gateway Circle', '4409584510', 4)

INSERT INTO Subjects([Name], Lessons)
	VALUES('Geometry', 12),
		  ('Health', 10),
		  ('Drama', 7),
		  ('Sports', 9)

--3

UPDATE StudentsSubjects
SET Grade = 6
WHERE SubjectId IN (1, 2) AND Grade >= 5.5

--4

DELETE FROM StudentsTeachers
WHERE TeacherId IN (SELECT Id FROM Teachers WHERE Phone LIKE '%72%')

DELETE FROM Teachers
WHERE Phone LIKE '%72%'

--5

SELECT FirstName,
	   LastName,
	   Age
	FROM Students
	WHERE Age >= 12
	ORDER BY FirstName, LastName

--6

SELECT s.FirstName,
       s.LastName,
	   COUNT(*) AS [TeachersCount]
	FROM Students AS s
	JOIN StudentsTeachers AS st ON st.StudentId = s.Id
	GROUP BY s.FirstName, s.LastName

--7

SELECT s.FirstName + ' ' + s.LastName AS [Full Name]	
	FROM Students AS s
	LEFT JOIN StudentsExams AS se ON se.StudentId = s.Id
	WHERE se.ExamId IS NULL
	ORDER BY [Full Name]

--8

SELECT TOP(10)
       s.FirstName,
	   s.LastName,
	   CONVERT(DECIMAL(3, 2), AVG(se.Grade)) AS [Grade]
	FROM Students AS s
	JOIN StudentsExams AS se ON se.StudentId = s.Id
	GROUP BY s.FirstName, s.LastName
	ORDER BY Grade DESC, s.FirstName, s.LastName

--9

SELECT CONCAT(st.FirstName, ' ', st.MiddleName + ' ', st.LastName) AS [Full Name]
	FROM Students AS st
	LEFT JOIN StudentsSubjects AS ss ON ss.StudentId = st.Id
	WHERE ss.SubjectId IS NULL
	ORDER BY [Full Name]

--10

SELECT su.[Name],
       AVG(ss.Grade) AS [AverageGrade]
	FROM Subjects AS su
	JOIN StudentsSubjects AS ss ON ss.SubjectId = su.Id
	GROUP BY su.Id, su.[Name]
	ORDER BY su.Id

--11

GO

CREATE FUNCTION udf_ExamGradesToUpdate(@studentId INT, @grade DECIMAL(3, 2))
RETURNS VARCHAR(100)
AS
BEGIN
	DECLARE @existingStudent INT = (
							  SELECT TOP(1) StudentId 
									FROM StudentsSubjects
									WHERE StudentId = @studentId
							       );

	IF(@existingStudent IS NULL)
	BEGIN
		RETURN 'The student with provided id does not exist in the school!';
	END

	IF(@grade > 6)
	BEGIN
		RETURN 'Grade cannot be above 6.00!'
	END

	DECLARE @maxGrade DECIMAL(3, 2) = @grade + 0.5

	DECLARE @countGrades INT = (
								SELECT COUNT(Grade) 
										FROM StudentsSubjects
										WHERE StudentId = @existingStudent AND
										Grade > @grade AND Grade <= @maxGrade
								);

	DECLARE @firstName VARCHAR(50) = (
									  SELECT TOP(1) s.FirstName 
											FROM Students AS s
											JOIN StudentsSubjects AS ss 
											ON ss.StudentId = s.Id
											WHERE ss.StudentId = @existingStudent
							          );

	RETURN 'You have to update ' + CONVERT(VARCHAR(100), @countGrades) + ' grades for the student ' + CONVERT(VARCHAR(50), @firstName);
END

SELECT dbo.udf_ExamGradesToUpdate(12, 6.20)

SELECT dbo.udf_ExamGradesToUpdate(12, 5.50)

SELECT dbo.udf_ExamGradesToUpdate(121, 5.50)

--12

GO

CREATE PROCEDURE usp_ExcludeFromSchool(@StudentId INT)
AS
BEGIN
	DECLARE @existingStudent INT = (
									SELECT Id 
											FROM Students 
											WHERE Id = @StudentId
								   );

	IF(@existingStudent IS NULL)
	BEGIN
		RETURN 'This school has no student with the provided id!'
	END

	DELETE FROM StudentsTeachers
	WHERE StudentId = @existingStudent

	DELETE FROM StudentsSubjects
	WHERE StudentId = @existingStudent

	DELETE FROM StudentsExams
	WHERE StudentId = @existingStudent

	DELETE FROM Students
	WHERE Id = @existingStudent
END