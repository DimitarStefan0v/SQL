CREATE DATABASE [ColonialJourney]

USE [ColonialJourney]

--1

CREATE TABLE Planets(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(30) NOT NULL
)

CREATE TABLE Spaceports(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL,
	PlanetId INT NOT NULL REFERENCES Planets(Id)
)

CREATE TABLE Spaceships(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL,
	Manufacturer VARCHAR(30) NOT NULL,
	LightSpeedRate INT DEFAULT 0
)

CREATE TABLE Colonists(
	Id INT PRIMARY KEY IDENTITY,
	FirstName VARCHAR(20) NOT NULL,
	LastName VARCHAR(20) NOT NULL,
	Ucn VARCHAR(10) NOT NULL UNIQUE,
	BirthDate DATETIME2 NOT NULL
)

CREATE TABLE Journeys(
	Id INT PRIMARY KEY IDENTITY,
	JourneyStart DATETIME2 NOT NULL,
	JourneyEnd DATETIME2 NOT NULL,
	Purpose VARCHAR(11) NOT NULL CHECK(Purpose = 'Medical' OR Purpose = 'Technical'
	OR Purpose = 'Educational' OR Purpose = 'Military'),
	DestinationSpaceportId INT NOT NULL REFERENCES Spaceports(Id),
	SpaceshipId INT NOT NULL REFERENCES Spaceships(Id)
)

CREATE TABLE TravelCards(
	Id INT PRIMARY KEY IDENTITY,
	CardNumber CHAR(10) NOT NULL UNIQUE,
	JobDuringJourney VARCHAR(8) NOT NULL CHECK(JobDuringJourney = 'Pilot' OR 
	JobDuringJourney = 'Engineer' OR JobDuringJourney = 'Trooper' OR
	JobDuringJourney = 'Cleaner' OR JobDuringJourney = 'Cook'),
	ColonistId INT NOT NULL REFERENCES Colonists(Id),
	JourneyId INT NOT NULL REFERENCES Journeys(Id)
)

--2

INSERT INTO Planets([Name])
	VALUES('Mars'),
	      ('Earth'),
		  ('Jupiter'),
		  ('Saturn')

INSERT INTO Spaceships([Name], Manufacturer, LightSpeedRate)
	VALUES('Golf', 'VW', 3),
	      ('WakaWaka', 'Wakanda', 4),
		  ('Falcon9', 'SpaceX', 1),
		  ('Bed', 'Vidolov', 6)

--3

UPDATE Spaceships
SET LightSpeedRate += 1
WHERE Id BETWEEN 8 AND 12

--4

DELETE FROM TravelCards
WHERE JourneyId BETWEEN 1 AND 3

DELETE FROM Journeys
WHERE Id BETWEEN 1 AND 3

--5

SELECT Id,
	   FORMAT(JourneyStart, 'dd/MM/yyyy') AS [JourneyStart],
	   FORMAT(JourneyEnd, 'dd/MM/yyyy') AS [JourneyEnd]
	FROM Journeys 
	WHERE Purpose = 'Military'
	ORDER BY JourneyStart ASC

--6

SELECT c.Id,
	   c.FirstName + ' ' + c.LastName AS [full_name]
	FROM Colonists AS c
	JOIN TravelCards AS tc ON tc.ColonistId = c.Id
	WHERE tc.JobDuringJourney = 'Pilot'
	ORDER BY c.Id

--7

SELECT COUNT(*) AS [count]
	FROM Colonists AS c
	JOIN TravelCards AS tc ON tc.ColonistId = c.Id
	JOIN Journeys AS j ON tc.JourneyId = j.Id
	WHERE j.Purpose = 'Technical'

--8

SELECT s.[Name],
       s.Manufacturer
	FROM Colonists AS c
	JOIN TravelCards AS tc ON tc.ColonistId = c.Id
	JOIN Journeys AS j ON tc.JourneyId = j.Id
	JOIN Spaceships AS s ON j.SpaceshipId = s.Id
	WHERE tc.JobDuringJourney = 'Pilot' AND c.BirthDate > '01/01/1989'
	ORDER BY s.[Name]

--9

SELECT p.[Name] AS [PlanetName],
       COUNT(*) AS [JourneysCount]
	FROM Planets AS p
	JOIN Spaceports AS sp ON sp.PlanetId = p.Id
	JOIN Journeys AS j ON j.DestinationSpaceportId = sp.Id
	GROUP BY p.[Name]
	ORDER BY JourneysCount DESC, PlanetName

--10

SELECT * FROM
			(
			 SELECT tc.JobDuringJourney ,
			        c.FirstName + ' ' + c.LastName AS [FullName],
				    DENSE_RANK() OVER(PARTITION BY tc.JobDuringJourney ORDER BY c.BirthDate) AS [JobRank]
				    FROM TravelCards AS tc
		            JOIN Colonists AS c ON tc.ColonistId = c.Id
			) AS [JobRankQuery]
		WHERE JobRank = 2

--11
GO

CREATE FUNCTION udf_GetColonistsCount(@PlanetName VARCHAR(30)) 
RETURNS INT
AS 
BEGIN
    DECLARE @countColonists INT = (SELECT COUNT(c.Id)
	                                  FROM Planets AS p
	                                  JOIN Spaceports AS sp ON sp.PlanetId = p.Id
	                                  JOIN Journeys AS j ON j.DestinationSpaceportId = sp.Id
	                                  JOIN TravelCards AS tc ON tc.JourneyId = j.Id
	                                  JOIN Colonists AS c ON tc.ColonistId = c.Id
									  WHERE p.[Name] = @PlanetName
	                                  GROUP BY p.Name);

	RETURN @countColonists;
	
END

SELECT dbo.udf_GetColonistsCount('Otroyphus')

--12

GO

CREATE PROCEDURE usp_ChangeJourneyPurpose(@JourneyId INT, @NewPurpose VARCHAR(11))
AS 
BEGIN
	DECLARE @existingJourney INT = (SELECT TOP(1) Id 
										FROM Journeys 
										WHERE Id = @JourneyId
								  );

	IF(@existingJourney IS NULL)
	BEGIN
		RETURN 'The journey does not exist!'
	END

	DECLARE @tempPurpose VARCHAR(11) = (SELECT Purpose 
												FROM Journeys 
												WHERE Id = @existingJourney
									    );

	IF(@tempPurpose = @NewPurpose)
	BEGIN
		RETURN 'You cannot change the purpose!'
	END

	UPDATE Journeys
	SET Purpose = @NewPurpose
	WHERE Id = @existingJouRney

END

EXEC usp_ChangeJourneyPurpose 4, 'Technical'

EXEC usp_ChangeJourneyPurpose 2, 'Educational'