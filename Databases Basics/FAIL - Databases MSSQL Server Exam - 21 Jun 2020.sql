CREATE DATABASE [TripService]

USE [TripService]

--1

CREATE TABLE Cities(
	Id INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(20) NOT NULL,
	CountryCode CHAR(2) NOT NULL,
)

CREATE TABLE Hotels(
	Id INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(30) NOT NULL,
	CityId INT NOT NULL REFERENCES Cities(Id),
	EmployeeCount INT NOT NULL,
	BaseRate DECIMAL(15, 2)
)

CREATE TABLE Rooms(
	Id INT PRIMARY KEY IDENTITY,
	Price DECIMAL(15, 2) NOT NULL,
	[Type] NVARCHAR(20) NOT NULL,
	Beds INT NOT NULL,
	HotelId INT NOT NULL REFERENCES Hotels(Id)
)

CREATE TABLE Trips(
	Id INT PRIMARY KEY IDENTITY,
	RoomId INT NOT NULL REFERENCES Rooms(Id),
	BookDate DATETIME2 NOT NULL,
	ArrivalDate DATETIME2 NOT NULL,
	ReturnDate DATETIME2 NOT NULL,
	CancelDate DATETIME2,
	CONSTRAINT CK_BookDate CHECK (BookDate < ArrivalDate),
	CONSTRAINT CK_ArrivalDate CHECK (ArrivalDate < ReturnDate)
)

CREATE TABLE Accounts(
	Id INT PRIMARY KEY IDENTITY,
	FirstName NVARCHAR(50) NOT NULL,
	MiddleName NVARCHAR(20),
	LastName NVARCHAR(50) NOT NULL,
	CityId INT NOT NULL REFERENCES Cities(Id),
	BirthDate DATETIME2 NOT NULL,
	Email VARCHAR(100) NOT NULL UNIQUE,
)

CREATE TABLE AccountsTrips(
	AccountId INT NOT NULL REFERENCES Accounts(Id),
	TripId INT NOT NULL REFERENCES Trips(Id),
	Luggage INT NOT NULL CHECK(Luggage >= 0),
	PRIMARY KEY(AccountId, TripId)
)

--2

INSERT INTO Accounts(FirstName, MiddleName, LastName, CityId, BirthDate, Email)
VALUES
('John', 'Smith', 'Smith', 34, '1975-07-21', 'j_smith@gmail.com'),
('Gosho', NULL, 'Petrov', 11, '1978-05-16', 'g_petrov@gmail.com'),
('Ivan', 'Petrovich', 'Pavlov', 59, '1849-09-26', 'i_pavlov@softuni.bg'),
('Friedrich', 'Wilhelm', 'Nietzsche', 2, '1844-10-15', 'f_nietzsche@softuni.bg')

INSERT INTO Trips(RoomId, BookDate, ArrivalDate, ReturnDate, CancelDate)
VALUES
(101, '2015-04-12', '2015-04-14', '2015-04-20', '2015-02-02'),
(102, '2015-07-07', '2015-07-15', '2015-07-22', '2015-04-29'),
(103, '2013-07-17', '2013-07-23', '2013-07-24', NULL),
(104, '2012-03-17', '2012-03-31', '2012-04-01', '2012-01-10'),
(109, '2017-08-07', '2017-08-28', '2017-08-29', NULL)

--3

UPDATE Rooms
SET Price += Price * 0.14
WHERE HotelId IN (5, 7, 9)

--4

DELETE FROM AccountsTrips
WHERE AccountId = 47

--5

SELECT a.FirstName,
	   a.LastName,
	   FORMAT(a.BirthDate, 'MM-dd-yyyy') AS [BirthDate],
	   c.[Name],
	   a.Email
	FROM Accounts AS a
	JOIN Cities AS c ON a.CityId = c.Id
	WHERE Email LIKE 'e%'
	ORDER BY c.[Name]

--6

SELECT c.[Name],
	   COUNT(h.Id) AS [Hotels]
	FROM Cities AS c
	JOIN Hotels AS h ON h.CityId = c.Id
	GROUP BY c.[Name]
	ORDER BY Hotels DESC, c.[Name]

--7

SELECT a.Id,
	   a.FirstName + ' ' + a.LastName AS [FullName],
	   MAX(DATEDIFF(DAY, t.ArrivalDate, t.ReturnDate)) AS [LongestTrip],
	   MIN(DATEDIFF(DAY, t.ArrivalDate, t.ReturnDate)) AS [ShortestTrip]
	FROM Trips AS t
	JOIN AccountsTrips AS [at] ON [at].TripId = t.Id
	JOIN Accounts AS a ON [at].AccountId = a.Id
	WHERE a.MiddleName IS NULL AND t.CancelDate IS NULL
	GROUP BY a.Id, a.FirstName, a.LastName
	ORDER BY LongestTrip DESC, ShortestTrip

--8

SELECT TOP(10)
	   c.Id,
	   c.[Name] AS [City],
	   c.CountryCode,
	   COUNT(*) AS [Accounts]
	FROM Cities AS c
    JOIN Accounts AS a ON a.CityId = c.Id
	GROUP BY c.Id, c.[Name], c.CountryCode
	ORDER BY Accounts DESC

--9

SELECT a.Id,
	   a.Email,
	   c.[Name],
	   COUNT(h.Id) AS [Trips]
	FROM AccountsTrips AS [at]
	JOIN Accounts AS a ON [at].AccountId = a.Id
	JOIN Cities AS c ON a.CityId = c.Id
	JOIN Trips AS t ON [at].TripId = t.Id
	JOIN Rooms AS r ON t.RoomId = r.Id
	JOIN Hotels AS h ON r.HotelId = h.Id
	GROUP BY a.Id, a.Email, c.[Name], a.CityId, h.CityId
	HAVING a.CityId = h.CityId
	ORDER BY Trips DESC, a.Id

--10

SELECT t.Id,
	   CONCAT(a.FirstName, ' ', a.MiddleName + ' ', a.LastName) AS [Full Name],
	   c.[Name] AS [From],
	   --To
	   MAX(DATEDIFF(DAY, t.ArrivalDate, t.ReturnDate)) AS [Duration]
	FROM Accounts AS a
    JOIN AccountsTrips AS [at] ON [at].AccountId = a.Id
    JOIN Cities AS c ON a.CityId = c.Id
    JOIN Trips AS t ON [at].TripId = t.Id
    JOIN Rooms AS r ON t.RoomId = r.Id
    JOIN Hotels AS h ON r.HotelId = h.Id
	GROUP BY t.Id, a.FirstName, a.MiddleName, a.LastName, c.[Name]
	ORDER BY [Full Name], t.Id
	