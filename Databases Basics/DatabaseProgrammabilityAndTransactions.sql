USE SoftUni

GO

CREATE PROCEDURE usp_GetEmployeesSalaryAbove35000
AS
BEGIN
	SELECT FirstName,
		   LastName
		FROM Employees
		WHERE Salary > 35000
END

EXEC usp_GetEmployeesSalaryAbove35000

GO

CREATE PROCEDURE usp_GetEmployeesSalaryAboveNumber(@minSalary DECIMAL(18,4))
AS
BEGIN
	SELECT FirstName,
		   LastName
		FROM Employees
		WHERE Salary >= @minSalary
END

EXEC usp_GetEmployeesSalaryAboveNumber 48100

GO

CREATE PROCEDURE usp_GetTownsStartingWith(@inputString VARCHAR(MAX))
AS 
BEGIN
	SELECT [Name]
		FROM Towns
		WHERE SUBSTRING([Name], 1, LEN(@inputString)) = @inputString
END

EXEC usp_GetTownsStartingWith 'B'

GO

CREATE PROCEDURE usp_GetEmployeesFromTown(@townName VARCHAR(50))
AS
BEGIN
	SELECT FirstName,
		   LastName
		FROM Employees AS e
		JOIN Addresses AS a ON e.AddressID = a.AddressID
		JOIN Towns AS t ON a.TownID = t.TownID
		WHERE t.[Name] = @townName
END

EXEC usp_GetEmployeesFromTown 'Sofia'

GO

CREATE FUNCTION ufn_GetSalaryLevel(@salary DECIMAL(18,4))
RETURNS VARCHAR(7)
AS
BEGIN
	DECLARE @salaryLeveL VARCHAR(7);

	IF (@salary < 30000)
	BEGIN
		SET @salaryLevel = 'Low';
	END
	ELSE IF (@salary <= 50000)
	BEGIN
		SET @salaryLeveL = 'Average';
	END
	ELSE
	BEGIN
		SET @salaryLeveL = 'High';
	END

	RETURN @salaryLeveL;
END

GO

SELECT FirstName,
	   LastName,
	   dbo.ufn_GetSalaryLevel(Salary) AS [SalaryLevel]
FROM Employees

GO

CREATE PROCEDURE usp_EmployeesBySalaryLevel(@salaryLevel VARCHAR(7))
AS
BEGIN
	SELECT FirstName,
		   LastName
		FROM Employees
		WHERE dbo.ufn_GetSalaryLevel(Salary) = @salaryLevel
END

EXEC usp_EmployeesBySalaryLevel 'Average'

GO

CREATE FUNCTION ufn_IsWordComprised(@setOfLetters VARCHAR(50), @word VARCHAR(50))
RETURNS BIT
AS
BEGIN
	DECLARE @currentIndex INT = 1;

	WHILE(@currentIndex <= LEN(@word))
	BEGIN

		DECLARE @currentLetter VARCHAR(1) = SUBSTRING(@word, @currentIndex, 1);

		IF(CHARINDEX(@currentLetter, @setOfLetters) = 0)
		BEGIN
			RETURN 0;
		END

	SET @currentIndex += 1;
	END

	RETURN 1;
END

GO

EXEC ufn_IsWordComprised 'oistmiahf', 'halves'

GO

USE Bank

GO

CREATE PROCEDURE usp_GetHoldersFullName
AS
BEGIN
	SELECT FirstName + ' ' + LastName AS [Full Name] 
		FROM AccountHolders
END

EXEC usp_GetHoldersFullName

GO

CREATE PROCEDURE usp_GetHoldersWithBalanceHigherThan(@minBalance DECIMAL(14, 2))
AS
BEGIN
	SELECT ah.FirstName,
		   ah.LastName
		FROM Accounts AS a
		JOIN AccountHolders AS ah ON a.AccountHolderId = ah.Id
		GROUP BY ah.FirstName, ah.LastName
		HAVING SUM(Balance) > @minBalance
		ORDER BY ah.FirstName, ah.LastName
		
END

EXEC usp_GetHoldersWithBalanceHigherThan 25000

GO

CREATE FUNCTION ufn_CalculateFutureValue(@sum DECIMAL(18, 4), @yir FLOAT, @yearsCount INT)
RETURNS DECIMAL(18, 4)
AS
BEGIN
	DECLARE @futureValue DECIMAL(18, 4);

	SET @futureValue = @sum * (POWER((1 + @yir), @yearsCount));

	RETURN @futureValue;
END

GO

SELECT dbo.ufn_CalculateFutureValue(1000, 0.1, 5)

GO

CREATE PROCEDURE usp_CalculateFutureValueForAccount(@accountID INT, @interestRate FLOAT)
AS
BEGIN
	SELECT ah.Id AS [Account Id],
		   ah.FirstName AS [First Name],
		   ah.LastName AS [Last Name],
		   a.Balance AS [Current Balance],
		   dbo.ufn_CalculateFutureValue(Balance, @interestRate, 5) AS [Balance in 5 years]
		FROM Accounts AS a
		JOIN AccountHolders AS ah ON a.AccountHolderId = ah.Id
		WHERE a.Id = @accountID
END

GO

USE Diablo

CREATE FUNCTION ufn_CashInUsersGames(@gameName NVARCHAR(50))
RETURNS TABLE
AS 
RETURN SELECT (
				SELECT SUM(Cash) AS [SumCash] 
						 FROM (
							  SELECT g.[Name],
							  ug.Cash,
							  ROW_NUMBER() OVER (PARTITION BY g.[Name] ORDER BY ug.Cash DESC) AS [RowNum]
							  FROM Games AS g
							  JOIN UsersGames AS ug ON ug.GameId = g.Id
							  WHERE g.[Name] = @gameName
							  ) AS [RowNumberQuery]
				WHERE RowNum % 2 = 1
              ) AS [SumCash]

