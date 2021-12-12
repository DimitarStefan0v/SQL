USE SoftUni

SELECT FirstName, LastName
	FROM Employees
	WHERE FirstName LIKE 'SA%'

SELECT FirstName, LastName 
	FROM Employees
	WHERE LastName LIKE '%ei%'

SELECT * 
	FROM Employees
	WHERE DATEPART(YEAR, HireDate) BETWEEN '1995' AND '2005' AND  DepartmentID IN(3, 10) 

SELECT FirstName, LastName 
	FROM Employees
	WHERE JobTitle NOT LIKE '%engineer%'

SELECT [Name] 
	FROM Towns
	WHERE LEN([Name]) = 5 OR  LEN([Name]) = 6
	ORDER BY [Name] 

SELECT *
	FROM Towns
	WHERE [Name] LIKE '[MKBE]%'
	ORDER BY [Name]

SELECT *
	FROM Towns
	WHERE LEFT([Name], 1) NOT IN ('R', 'B', 'D')
	ORDER BY [Name]

CREATE VIEW V_EmployeesHiredAfter2000 AS
SELECT FirstName, LastName
	FROM Employees
	WHERE DATEPART(YEAR, HireDate) > '2000'

SELECT FirstName, LastName 
	FROM Employees
	WHERE LEN(LastName) = 5


SELECT * FROM (SELECT EmployeeID, FirstName, LastName, Salary,
				DENSE_RANK() OVER (PARTITION BY Salary ORDER BY EmployeeID) AS [Rank]
				FROM Employees
				WHERE Salary BETWEEN 10000 AND 50000) AS [VIRTUAL TABLE]
	WHERE [Rank] = 2
	ORDER BY Salary DESC


USE Geography

SELECT CountryName, IsoCode
	FROM Countries
	WHERE CountryName LIKE '%a%a%a%'
	ORDER BY IsoCode

SELECT Peaks.PeakName, 
	Rivers.RiverName,
	LOWER(CONCAT(LEFT(Peaks.PeakName, LEN(Peaks.PeakName) - 1), Rivers.RiverName)) AS Mix
	FROM Peaks
	JOIN Rivers ON RIGHT(Peaks.PeakName, 1) = LEFT(Rivers.RiverName, 1)
	ORDER BY Mix

USE Diablo

SELECT TOP(50) [Name],
	FORMAT([Start], 'yyyy-MM-dd') AS [Start]
	FROM Games
	WHERE DATEPART(YEAR, Start) IN(2011, 2012)
	ORDER BY Start, [Name]

SELECT Username,
	RIGHT(Email, LEN(Email) - CHARINDEX('@', Email)) AS EmailProvider
	FROM Users
	ORDER BY EmailProvider, Username

SELECT Username, IpAddress
	FROM Users
	WHERE IpAddress LIKE '___.1_%._%.___' 
	ORDER BY Username

SELECT [Name],
	CASE
		WHEN DATEPART(HOUR, [Start]) BETWEEN 0 AND 11 THEN 'Morning'
		WHEN DATEPART(HOUR, [Start]) BETWEEN 12 AND 17 THEN 'Afternoon'
		ELSE 'Evening'
	END AS [Part of the Day],
	CASE
		WHEN DURATION <= 3 THEN 'Extra Short'
		WHEN DURATION BETWEEN 4 AND 6 THEN 'Short'
		WHEN DURATION > 6 THEN 'Long'
		ELSE 'Extra Long'
	END AS [Duration]
 	FROM Games
	ORDER BY [Name], Duration, [Part of the Day]

USE Orders

SELECT ProductName,
	OrderDate,
	DATEADD(DAY, 3, OrderDate) AS [Pay Due],
	DATEADD(MONTH, 1, OrderDate) AS [Deliver Due]
	FROM Orders

CREATE TABLE People(
	Id INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(50) NOT NULL,
	Birthdate DATETIME2 NOT NULL
)

INSERT INTO People([Name], Birthdate)
	VALUES
		('Victor', '2000-12-07 00:00:00.000'),
		('Steven', '1992-09-10 00:00:00.000'),
		('Stephen', '1910-09-19 00:00:00.000'),
		('John', '2010-01-06 00:00:00.000');

SELECT [Name],
	DATEDIFF(YEAR, Birthdate, GETDATE()) AS [Age in Years],
	DATEDIFF(MONTH, Birthdate, GETDATE()) AS [Age in Months],
    DATEDIFF(DAY, Birthdate, GETDATE()) AS [Age in Days],
    DATEDIFF(MINUTE, Birthdate, GETDATE()) AS [Age in Minutes]
	FROM People

DROP TABLE People