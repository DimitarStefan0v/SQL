CREATE DATABASE [Airport]

USE [Airport]

--1

CREATE TABLE Planes(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(30) NOT NULL,
	Seats INT NOT NULL,
	[Range] INT NOT NULL
)

CREATE TABLE Flights(
	Id INT PRIMARY KEY IDENTITY,
	DepartureTime DATETIME2,
	ArrivalTime DATETIME2,
	Origin VARCHAR(50) NOT NULL,
	Destination VARCHAR(50) NOT NULL,
	PlaneId INT NOT NULL REFERENCES Planes(Id)
)

CREATE TABLE Passengers(
	Id INT PRIMARY KEY IDENTITY,
	FirstName VARCHAR(30) NOT NULL,
	LastName VARCHAR(30) NOT NULL,
	Age INT NOT NULL,
	[Address] VARCHAR(30) NOT NULL,
	PassportId CHAR(11) NOT NULL
)

CREATE TABLE LuggageTypes(
	Id INT PRIMARY KEY IDENTITY,
	[Type] VARCHAR(30) NOT NULL
)

CREATE TABLE Luggages(
	Id INT PRIMARY KEY IDENTITY,
	LuggageTypeId INT NOT NULL REFERENCES LuggageTypes(Id),
	PassengerId INT NOT NULL REFERENCES Passengers(Id)
)

CREATE TABLE Tickets(
	Id INT PRIMARY KEY IDENTITY,
	PassengerId INT NOT NULL REFERENCES Passengers(Id),
	FlightId INT NOT NULL REFERENCES Flights(Id),
	LuggageId INT NOT NULL REFERENCES Luggages(Id),
	Price DECIMAL(16, 2) NOT NULL
)

--2

INSERT INTO Planes([Name], Seats, [Range])
	VALUES('Airbus 336', 112, 5132),
		  ('Airbus 330', 432, 5325),
		  ('Boeing 369', 231, 2355),
		  ('Stelt 297', 254, 2143),
		  ('Boeing 338', 165, 5111),
		  ('Airbus 558', 387, 1342),
		  ('Boeing 128', 345, 5541)

INSERT INTO LuggageTypes([Type])
	VALUES('Crossbody Bag'),
		  ('School Backpack'),
		  ('Shoulder Bag')

--3

UPDATE Tickets 
SET Price = Price * 1.13
WHERE FlightId = (
				  SELECT t.FlightId 
						FROM Flights AS f
						JOIN Planes AS p ON f.PlaneId = p.Id
						JOIN Tickets AS t ON t.FlightId = f.Id
						WHERE f.Destination = 'Carlsbad'
				  ) 

--4

DELETE FROM Tickets
WHERE FlightId IN (
				   SELECT Id 
						FROM Flights
						WHERE Destination = 'Ayn Halagim'
				   )

DELETE FROM Flights
WHERE Destination = 'Ayn Halagim'

--5

SELECT *
	FROM Planes
	WHERE [Name] LIKE '%tr%'
	ORDER BY Id, [Name], Seats, [Range]

--6

SELECT t.FlightId,
	   SUM(t.Price) AS Price
	FROM Flights AS f
	JOIN Tickets AS t ON t.FlightId = f.Id
	GROUP BY t.FlightId
	ORDER BY Price DESC, t.FlightId

--7	

SELECT p.FirstName + ' ' + p.LastName AS [Full Name],
	   f.Origin,
	   f.Destination
	FROM Passengers AS p
    JOIN Tickets AS t ON t.PassengerId = p.Id
	JOIN Flights AS f ON t.FlightId = f.Id
	ORDER BY [Full Name], f.Origin, f.Destination

--8

SELECT p.FirstName AS [First Name],
       p.LastName AS [Last Name],
	   p.Age
	FROM Passengers AS p
	LEFT JOIN Tickets AS t ON t.PassengerId = p.Id
	WHERE t.FlightId IS NULL
	ORDER BY p.Age DESC, p.FirstName, p.LastName
	
--9

SELECT p.FirstName + ' ' + p.LastName AS [Full Name],
       pl.[Name] AS [Plane Name],
	   f.Origin + ' - ' + f.Destination AS [Trip],
	   lt.[Type] AS [Luggage Type]
	FROM Passengers AS p
	JOIN Tickets AS t ON t.PassengerId = p.Id
	JOIN Flights AS f ON t.FlightId = f.Id
	JOIN Planes AS pl ON f.PlaneId = pl.Id
	JOIN Luggages AS l ON t.LuggageId = l.Id
	JOIN LuggageTypes AS lt ON l.LuggageTypeId = lt.Id
	ORDER BY [Full Name], pl.[Name], f.Origin, f.Destination, lt.[Type]

--10

SELECT pl.[Name],
	   pl.Seats,
	   COUNT(pa.Id) AS [Passengers Count]
	FROM Planes AS pl
    LEFT JOIN Flights AS f ON f.PlaneId = pl.Id
	LEFT JOIN Tickets AS t ON t.FlightId = f.Id
	LEFT JOIN Passengers AS pa ON t.PassengerId = pa.Id
	GROUP BY pl.[Name], pl.Seats
	ORDER BY [Passengers Count] DESC, pl.[Name], pl.Seats

--11

GO

CREATE FUNCTION udf_CalculateTickets(@origin VARCHAR(50), @destination VARCHAR(50), @peopleCount INT)
RETURNS VARCHAR(100)
AS
BEGIN
	IF(@peopleCount <= 0)
	BEGIN
		RETURN 'Invalid people count!';
	END

	DECLARE @flightId INT = (
					     SELECT Id 
								FROM Flights 
								WHERE Origin = @origin AND Destination = @destination
						    );

	IF(@flightId IS NULL)
	BEGIN
		RETURN 'Invalid flight!';
	END

	DECLARE @pricePerPerson DECIMAL(16, 2) = (
										  SELECT Price 
												FROM Tickets
												WHERE FlightId = @flightId 
										     );

	DECLARE @totalPrice DECIMAL(16, 2) = @pricePerPerson * @peopleCount;

	RETURN 'Total price ' + TRY_CONVERT(VARCHAR(20), @totalPrice);
END

GO

SELECT dbo.udf_CalculateTickets('Invalid','Rancabolang', 33)


SELECT dbo.udf_CalculateTickets('Kolyshley','Rancabolang', 10)

--12

GO

CREATE PROCEDURE usp_CancelFlights
AS
BEGIN
	UPDATE Flights 
	SET ArrivalTime = NULL, DepartureTime = NULL
	WHERE ArrivalTime > DepartureTime
END

EXEC usp_CancelFlights