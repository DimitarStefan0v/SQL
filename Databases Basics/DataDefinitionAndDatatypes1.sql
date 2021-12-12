CREATE DATABASE Minions

USE Minions

CREATE TABLE Minions(
		Id INT PRIMARY KEY NOT NULL,
		[Name] NVARCHAR(50) NOT NULL,
		Age TINYINT
)

CREATE TABLE Towns(
		Id INT PRIMARY KEY NOT NULL,
		[Name] NVARCHAR(50) NOT NULL
)

ALTER TABLE Minions
ADD TownId INT FOREIGN KEY REFERENCES Towns(Id)

INSERT INTO Towns(Id, [Name])
	VALUES
		(1, 'Sofia'),
		(2, 'Plovdiv'),
		(3, 'Varna')

SELECT * FROM Towns

INSERT INTO Minions(Id, [Name], Age, TownId)
	VALUES
		(1, 'Kevin', 22, 1),
		(2, 'Bob', 15, 3),
		(3, 'Steward', NULL, 2)

TRUNCATE TABLE Minions

SELECT * FROM Minions

DROP TABLE Minions
DROP TABLE Towns

CREATE TABLE People(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	[Name] NVARCHAR(200) NOT NULL,
	Picture VARBINARY(MAX),
	Height NUMERIC(3,2),
	[Weight] NUMERIC(5,2),
	Gender CHAR(1) NOT NULL CHECK(Gender = 'm' OR Gender = 'f'),
	Birthdate DATE NOT NULL,
	Biography NVARCHAR(MAX)
)

INSERT INTO People([Name], Picture, Height, [Weight], Gender, Birthdate, Biography)
	VALUES
		('Stela',Null,1.65,44.55,'f','2000-09-22',Null),
		('Ivan',Null,2.15,95.55,'m','1989-11-02',Null),
		('Qvor',Null,1.55,33.00,'m','2010-04-11',Null),
		('Karolina',Null,2.15,55.55,'f','2001-11-11',Null),
		('Pesho',Null,1.85,90.00,'m','1983-07-22',Null)

SELECT * FROM People

CREATE TABLE Users(
	Id BIGINT PRIMARY KEY IDENTITY NOT NULL,
	Username VARCHAR(30) UNIQUE NOT NULL,
	[Password] VARCHAR(26) UNIQUE NOT NULL,
	ProfilePicture VARBINARY(MAX) CHECK(DATALENGTH(ProfilePicture) <= 900 * 1024),
	LastLoginTime DATETIME2 NOT NULL,
	IsDeleted BIT NOT NULL
)

INSERT INTO Users(Username, [Password], LastLoginTime, IsDeleted)
	VALUES
		('Mitko',45545,'1994-08-29',0),
		('Ivan',54545,'1989-11-02',0),
		('Qvor',24545,'2010-04-11',0),
		('Karolina',24255,'2001-11-11',0),
		('Pesho',4545,'1983-07-22',1)

SELECT * FROM Users

ALTER TABLE Users
DROP CONSTRAINT [PK__Users__3214EC07319013DD]

ALTER TABLE Users
ADD CONSTRAINT PK_Users_CompositeIdUsername
PRIMARY KEY(Id, Username)

ALTER TABLE Users
ADD CONSTRAINT CK_Users_PasswordLength
CHECK(LEN([Password]) >= 5)

ALTER TABLE Users
ADD CONSTRAINT DF_Users_LastLoginTime
DEFAULT GETDATE() FOR LastLoginTime

ALTER TABLE Users
DROP CONSTRAINT PK_Users_CompositeIdUsername

ALTER TABLE Users
ADD CONSTRAINT PK_Users_Id
PRIMARY KEY(Id)

ALTER TABLE Users
ADD CONSTRAINT CK_Users_UsernameLength
CHECK(LEN(Username) >= 3)

CREATE DATABASE Movies

USE Movies

CREATE TABLE Directors(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	DirectorName NVARCHAR(50) NOT NULL,
	Notes VARCHAR(MAX)
)

INSERT INTO Directors(DirectorName, Notes)
	VALUES
		('Pesho1', NULL),
		('Pesho2', 'Some bullshit'),
		('Pesho3', NULL),
		('Pesho4', NULL),
		('Pesho5', NULL)

SELECT * FROM Directors

CREATE TABLE Genres(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	GenreName VARCHAR(20) NOT NULL,
	Notes VARCHAR(MAX)
)

INSERT INTO Genres(GenreName, Notes)
	VALUES
		('Comedy1', NULL),
		('Comedy2', 'Some bullshit'),
		('Comedy3', NULL),
		('Comedy4', NULL),
		('Comedy5', NULL)

SELECT * FROM Genres

CREATE TABLE Categories(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	CategoryName VARCHAR(50) NOT NULL,
	Notes VARCHAR(MAX)
)

INSERT INTO Categories(CategoryName, Notes)
	VALUES
		('Documentary1', NULL),
		('Documentary2', 'Some bullshit'),
		('Documentary3', NULL),
		('Documentary4', NULL),
		('Documentary5', NULL)

SELECT * FROM Categories

CREATE TABLE Movies(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	Title NVARCHAR(30) NOT NULL,
	DirectorId INT NOT NULL,
	CopyrightYear DATETIME2,
	[Length] DECIMAL(3,2),
	GenreId INT NOT NULL,
	CategoryId INT NOT NULL,
	Rating DECIMAL(3,2),
	Notes VARCHAR(MAX)
)

INSERT INTO Movies(Title, DirectorId, CopyrightYear, [Length], GenreId, CategoryId, Rating, Notes)
	VALUES
		('RushHour1', 1, NULL, NULL, 1, 1, 9.20, NULL),
		('RushHour2', 2, NULL, NULL, 2, 2, 8.20, NULL),
		('RushHour3', 3, NULL, NULL, 3, 3, 7.20, NULL),
		('RushHour4', 4, NULL, NULL, 4, 4, 6.20, NULL),
		('RushHour5', 5, NULL, NULL, 5, 5, 5.20, NULL)

SELECT * FROM Movies

CREATE DATABASE SoftUni

USE SoftUni

CREATE TABLE Towns(
	Id INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(50) NOT NULL
)

CREATE TABLE Addresses(
	Id INT PRIMARY KEY IDENTITY,
	AddressText NVARCHAR(100) NOT NULL,
	TownId INT FOREIGN KEY REFERENCES Towns(Id) NOT NULL
)

CREATE TABLE Departments(
	Id INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(50) NOT NULL
)

CREATE TABLE Employees(
	Id INT PRIMARY KEY IDENTITY,
	FirstName NVARCHAR(30) NOT NULL,
	MiddleName NVARCHAR(30),
	LastName NVARCHAR(30) NOT NULL,
	JobTitle NVARCHAR(30) NOT NULL,
	DepartmentId INT FOREIGN KEY REFERENCES Departments(Id) NOT NULL,
	HireDate DATE NOT NULL,
	Salary DECIMAL(7, 2) NOT NULL,
	AddressId INT FOREIGN KEY REFERENCES Addresses(Id)
)

INSERT INTO Towns([Name])
	VALUES
		('Sofia'),
		('Plovdiv'),
		('Varna'),
		('Burgas')

INSERT INTO Departments([Name])
	VALUES
		('Engineering'),
		('Sales'),
		('Marketing'),
		('Software Development'),
		('Quality Assurance')

INSERT INTO Employees(FirstName, MiddleName, LastName, JobTitle, DepartmentId, HireDate, Salary)
	VALUES
		('Ivan', 'Ivanov', 'Ivanov', '.NET Developer', 4, '02/01/2013', 3500.00),
		('Petar', 'Petrov', 'Petrov', 'Senior Engineer', 1, '03/02/2004', 4000.00),
		('Maria', 'Petrova', 'Ivanova', 'Intern', 5, '08/28/2016', 525.25),
		('Georgi', 'Teziev', 'Ivanov', 'CEO', 2, '12/09/2007', 3000.00),
		('Peter', 'Pan', 'Pan', 'Intern', 3, '08/28/2016', 599.88)

SELECT [Name] FROM Towns ORDER BY [Name] ASC

SELECT [Name] FROM Departments ORDER BY [Name] ASC

SELECT FirstName, LastName, JobTitle, Salary FROM Employees ORDER BY Salary DESC

UPDATE Employees
SET Salary += Salary * 0.1

SELECT Salary FROM Employees