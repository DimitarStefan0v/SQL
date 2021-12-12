USE [Gringotts]

SELECT COUNT(*) AS [Count]
	FROM WizzardDeposits

SELECT TOP(1) MagicWandSize AS [LongestMagicWand]
	FROM WizzardDeposits
	ORDER BY [LongestMagicWand] DESC
	
SELECT DepositGroup,
	   MAX(MagicWandSize) AS [LongestMagicWand]
	FROM WizzardDeposits
	GROUP BY DepositGroup

SELECT TOP(2) DepositGroup
	FROM WizzardDeposits
	GROUP BY DepositGroup
	ORDER BY AVG(MagicWandSize)

SELECT DepositGroup, SUM(DepositAmount) AS [TotalSum]
	FROM WizzardDeposits
	GROUP BY DepositGroup

SELECT DepositGroup, MagicWandCreator
	FROM WizzardDeposits
	GROUP BY DepositGroup

SELECT DepositGroup, SUM(DepositAmount) AS [TotalSum]
	FROM WizzardDeposits
	WHERE MagicWandCreator = 'Ollivander family'
	GROUP BY DepositGroup

SELECT * FROM 
			(
			SELECT DepositGroup, SUM(DepositAmount) AS [TotalSum]
			FROM WizzardDeposits 
			WHERE MagicWandCreator = 'Ollivander family'
			GROUP BY DepositGroup
			) AS [TotalDepositQuery]
	WHERE TotalSum < 150000
	ORDER BY TotalSum DESC
	
SELECT DepositGroup, MagicWandCreator, MIN(DepositCharge) AS [MinDepositCharge]
	FROM WizzardDeposits
	GROUP BY DepositGroup, MagicWandCreator
	ORDER BY MagicWandCreator, DepositGroup

SELECT AgeGroup, 
	   COUNT(*) AS [WizardCount]
		FROM 
				(	
				SELECT *,
					CASE
						WHEN Age <= 10 THEN '[0-10]'
						WHEN Age BETWEEN 11 AND 20 THEN '[11-20]'
						WHEN Age BETWEEN 21 AND 30 THEN '[21-30]'
						WHEN Age BETWEEN 31 AND 40 THEN '[31-40]'
						WHEN Age BETWEEN 41 AND 50 THEN '[41-50]'
						WHEN Age BETWEEN 51 AND 60 THEN '[51-60]'
						WHEN Age > 60 THEN '[61+]'
					END AS [AgeGroup]
				FROM WizzardDeposits
				) AS [AgeGroupQuery]
	GROUP BY AgeGroup

SELECT DISTINCT LEFT(FirstName, 1)  AS FirstLetter
	FROM WizzardDeposits
	WHERE DepositGroup = 'Troll Chest'
	GROUP BY FirstName
	
SELECT DepositGroup, 
	   IsDepositExpired,
	   AVG(DepositInterest) AS [AverageInterest]
	FROM WizzardDeposits
	WHERE DepositStartDate > '01/01/1985'
	GROUP BY DepositGroup, IsDepositExpired
	ORDER BY DepositGroup DESC, IsDepositExpired ASC

SELECT SUM(Difference) AS [SumDifference] 
	FROM 
			(
			SELECT FirstName AS [Host Wizard],
			   DepositAmount AS [Host Wizard Deposit],
			   LEAD(FirstName) OVER(ORDER BY Id ASC) AS [Guest Wizard],
			   LEAD(DepositAmount) OVER(ORDER BY Id ASC) AS [Guest Wizard Deposit],
			   DepositAmount - LEAD(DepositAmount) OVER(ORDER BY Id ASC) AS [Difference]
			FROM WizzardDeposits
			) AS [HostAndGuestQuery]

USE SoftUni

SELECT DepartmentID,
       SUM(Salary) AS [TotalSalary]
	FROM Employees
	GROUP BY DepartmentID
	ORDER BY DepartmentID

SELECT DepartmentID,
       MIN(Salary) AS [MinimumSalary]
	FROM Employees
	WHERE DepartmentID IN(2, 5, 7) AND HireDate > '01/01/2000'
	GROUP BY DepartmentID

SELECT * INTO EmployeesWithHighSalaries
	FROM Employees
	WHERE Salary > 30000

DELETE FROM EmployeesWithHighSalaries
WHERE ManagerID = 42

UPDATE EmployeesWithHighSalaries
SET Salary += 5000
WHERE DepartmentID = 1

SELECT DepartmentID,
	   AVG(Salary) AS [AverageSalary]
	FROM EmployeesWithHighSalaries
	GROUP BY DepartmentID

SELECT DepartmentID,
       MAX(Salary) AS [MaxSalary]
	FROM Employees
	GROUP BY DepartmentID
	HAVING MAX(Salary) < 30000 OR MAX(Salary) > 70000

SELECT COUNT(*) AS [Count]
	FROM Employees
	WHERE ManagerID IS NULL
	
SELECT DISTINCT DepartmentID,
	   Salary AS [ThirdHighestSalary]
	FROM 
				(
				SELECT DepartmentID,
				       Salary,
					   DENSE_RANK() OVER(PARTITION BY DepartmentID ORDER BY Salary DESC) AS [SalaryRank]
				  FROM Employees
				) AS [SalaryRankingQuery]
WHERE SalaryRank = 3

SELECT TOP(10)
       e1.FirstName,
	   e1.LastName,
	   e1.DepartmentID
	FROM Employees AS e1
	WHERE e1.Salary > (
						SELECT AVG(Salary) AS [AverageSalary]
							FROM Employees AS e2
							WHERE e2.DepartmentID = e1.DepartmentID
						GROUP BY DepartmentID
						) 
	ORDER BY e1.DepartmentID