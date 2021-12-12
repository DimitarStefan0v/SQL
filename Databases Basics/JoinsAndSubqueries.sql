USE SoftUni

SELECT TOP(5) e.EmployeeID, 
		      e.JobTitle, 
	          e.AddressID, 
	          a.AddressText 
	FROM Employees AS e
	JOIN Addresses AS a ON e.AddressID = a.AddressID
	ORDER BY e.AddressID

SELECT TOP(50) 
		e.FirstName, 
		e.LastName, 
		t.[Name] AS Town, 
		a.AddressText	
	FROM Addresses AS a
	JOIN Towns AS t ON a.TownID = t.TownID
	JOIN Employees AS e ON a.AddressID = e.AddressID
	ORDER BY e.FirstName, e.LastName

SELECT e.EmployeeID, 
	   e.FirstName, 
	   e.LastName, 
	   d.[Name] AS DepartmentName 
	FROM Employees AS e
	JOIN Departments AS d ON e.DepartmentID = d.DepartmentID
	WHERE d.[Name] = 'Sales'
	ORDER BY e.EmployeeID

SELECT TOP(5) 
		e.EmployeeID, 
		e.FirstName, 
		e.Salary, 
		d.[Name] AS DepartmentName
	FROM Employees AS e
	JOIN Departments AS d ON e.DepartmentID = d.DepartmentID
	WHERE e.Salary > 15000
	ORDER BY d.DepartmentID

SELECT TOP(3) e.EmployeeID, e.FirstName
	FROM Employees AS e
	LEFT JOIN EmployeesProjects AS ep ON e.EmployeeID = ep.EmployeeID
	WHERE ep.ProjectID IS NULL
	ORDER BY e.EmployeeID
	
SELECT e.FirstName, 
	   e.LastName,
	   e.HireDate, 
	   d.[Name] AS DeptName
	FROM Employees AS e
	JOIN Departments AS d ON e.DepartmentID = d.DepartmentID
	WHERE e.HireDate > '1999-01-01' AND d.[Name] IN('Sales', 'Finance')
	ORDER BY e.HireDate

SELECT TOP(5) 
		e.EmployeeID,
		e.FirstName, 
		p.[Name] AS ProjectName
	FROM Employees AS e
	JOIN EmployeesProjects AS ep ON e.EmployeeID = ep.EmployeeID
	JOIN Projects AS p ON ep.ProjectID = p.ProjectID
	WHERE p.StartDate > '2002-08-13' AND p.EndDate IS NULL
	ORDER BY e.EmployeeID

SELECT e.EmployeeID, e.FirstName,
	    CASE
			WHEN DATEPART(YEAR, p.StartDate) >= '2005' 
			THEN NULL 
			ELSE p.[Name] 
			END AS [ProjectName]
		FROM Employees AS e
	    JOIN EmployeesProjects AS ep ON e.EmployeeID = ep.EmployeeID
	    JOIN Projects AS p ON ep.ProjectID = p.ProjectID
	    WHERE e.EmployeeID = 24
	
SELECT e.EmployeeID, e.FirstName, e.ManagerID, em.FirstName AS ManagerName
	FROM Employees AS e
	JOIN Employees AS em ON em.EmployeeID = e.ManagerID
	WHERE e.ManagerID IN (3, 7)
	ORDER BY e.EmployeeID

SELECT TOP(50) 
		e1.EmployeeID,
		e1.FirstName + ' ' + e1.LastName AS EmployeeName,
		e2.FirstName + ' ' + e2.LastName AS ManagerName,
		d.[Name] AS DepartmentName
	FROM Employees AS e1
	LEFT JOIN Employees AS e2 ON e1.ManagerID = e2.EmployeeID
	JOIN Departments AS d ON e1.DepartmentID = d.DepartmentID
	ORDER BY e1.EmployeeID

SELECT MIN([Average Salary]) AS MinAverageSalary
		FROM 
		(SELECT AVG(Salary) AS [Average Salary]
		FROM Employees
		GROUP BY DepartmentID) AS [Average Salary Query]

USE Geography

SELECT mc.CountryCode, 
       m.MountainRange, 
       p.PeakName, 
       p.Elevation 
	FROM MountainsCountries AS mc
	JOIN Mountains AS m ON mc.MountainId = m.Id
	JOIN Peaks AS p ON p.MountainId = m.Id
	WHERE mc.CountryCode = 'BG' AND p.Elevation > 2835
	ORDER BY p.Elevation DESC
	
SELECT mc.CountryCode, COUNT(mc.CountryCode) AS MountainRanges
	FROM Mountains AS m
	JOIN MountainsCountries AS mc ON mc.MountainId = m.Id
	WHERE mc.CountryCode IN ('BG', 'RU', 'US')
	GROUP BY mc.CountryCode

SELECT TOP(5)
		c.CountryName, 
		r.RiverName
	FROM Countries AS c
	LEFT JOIN CountriesRivers AS cr ON c.CountryCode = cr.CountryCode
	LEFT JOIN Rivers AS r ON cr.RiverId = r.Id
	WHERE c.ContinentCode = 'AF'
	ORDER BY c.CountryName

SELECT ContinentCode, CurrencyCode, CurrencyCount AS [CurrencyUsage] FROM (SELECT ContinentCode, 
			CurrencyCode, 
			[CurrencyCount], 
			DENSE_RANK() OVER 
			(PARTITION BY ContinentCode ORDER BY CurrencyCount DESC) AS [CurrencyRank]
		FROM
			(SELECT ContinentCode, 
					CurrencyCode, 
					COUNT(*) AS [CurrencyCount]
			FROM Countries
			GROUP BY ContinentCode, CurrencyCode) AS [CurrencyCountQuery]
			WHERE CurrencyCount > 1 ) AS [CurrencyRankingQuery]
		WHERE CurrencyRank = 1


SELECT COUNT(c.CountryCode) AS [Count]
	FROM Countries AS c
	LEFT JOIN MountainsCountries AS mc ON mc.CountryCode = c.CountryCode 
	WHERE mc.MountainId IS NULL

SELECT TOP(5) CountryName,
	   MAX(p.Elevation) AS [HighestPeakElevation],
	   MAX(r.[Length]) AS [LongestRiverLength]
	FROM Countries AS c
	LEFT JOIN CountriesRivers AS cr ON cr.CountryCode = c.CountryCode
	LEFT JOIN Rivers AS r ON cr.RiverId = r.Id
	LEFT JOIN MountainsCountries AS mc ON c.CountryCode = mc.CountryCode
	LEFT JOIN Mountains AS m ON mc.MountainId = m.Id
	LEFT JOIN Peaks AS p ON p.MountainId = m.Id
	GROUP BY c.CountryName 
	ORDER BY HighestPeakElevation DESC, LongestRiverLength DESC, CountryName

SELECT TOP(5) Country, 
	   CASE	
			WHEN PeakName IS NULL THEN '(no highest peak)'
			ELSE PeakName
		END AS [Highest Peak Name],
	   CASE
			WHEN Elevation IS NULL THEN 0
			ELSE Elevation
		END AS [Highest Peak Elevation],
	   CASE
			WHEN MountainRange IS NULL THEN '(no mountain)'
			ELSE MountainRange
		END AS [Mountain]
			FROM (SELECT *,  DENSE_RANK() OVER
			(PARTITION BY [Country] ORDER BY [Elevation] DESC) AS [PeakRank]
		FROM   
			(
			SELECT CountryName AS [Country] ,
					p.PeakName,
					P.Elevation,
					m.MountainRange
			FROM Countries AS c
			LEFT JOIN MountainsCountries AS mc ON c.CountryCode = mc.CountryCode
			LEFT JOIN Mountains AS m ON mc.MountainId = m.Id
			LEFT JOIN Peaks AS p ON p.MountainId = m.Id
			) AS [FullInfoQuery]) AS [PeakRankingsQuery]
		WHERE PeakRank = 1
		ORDER BY Country, [Highest Peak Name]
