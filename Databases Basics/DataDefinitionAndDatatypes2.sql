CREATE DATABASE Minions

USE Minions


CREATE TABLE Minions(
	Id INT PRIMARY KEY NOT NULL,
	[Name] VARCHAR(30) NOT NULL,
	Age INT,
)

CREATE TABLE Towns(
	Id INT PRIMARY KEY NOT NULL,
	[Name] VARCHAR(30) NOT NULL
)

ALTER TABLE Minions
ADD TownId INT FOREIGN KEY REFERENCES Towns(Id) NOT NULL

INSERT INTO Towns(Id, [Name])
	VALUES
		(1, 'Sofia'),
		(2, 'Plovdiv'),
		(3, 'Varna')

INSERT INTO Minions(Id, [Name], Age, TownId)
	VALUES
		(1, 'Kevin', 22, 1),
		(2, 'Bob', 15, 3),
		(3, 'Steward', NULL, 2)

SELECT * FROM Minions

SELECT * FROM Towns

ALTER TABLE Minions
DROP CONSTRAINT [FK__Minions__TownId__4222D4EF]

TRUNCATE TABLE Towns

TRUNCATE TABLE Minions

DROP TABLE Towns

DROP TABLE Minions

CREATE TABLE People(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	[Name] NVARCHAR(200) NOT NULL,
	Picture VARBINARY(MAX),
	Height DECIMAL(3, 2),
	[Weight] DECIMAL(5, 2),
	Gender CHAR NOT NULL CHECK(Gender = 'm' OR Gender = 'f'),
	Birthdate DATE NOT NULL,
	Biography NVARCHAR(MAX)
)

INSERT INTO People([Name], Picture, Height, [Weight], Gender, Birthdate, Biography)
	VALUES
		('Pesho1', NULL, 1.80, 95.50, 'm', '1980-08-20', NULL),
		('Pesho2', NULL, 1.70, 85.50, 'm', '1970-08-20', NULL),
		('Pesho3', NULL, 1.60, 75.50, 'm', '1960-08-20', NULL),
		('Pesho4', NULL, 1.50, 65.50, 'm', '1950-08-20', NULL),
		('Pesho5', NULL, 1.40, 55.50, 'm', '1940-08-20', NULL)

SELECT * FROM People ORDER BY Height

CREATE TABLE Users(
	Id BIGINT PRIMARY KEY IDENTITY,
	Username VARCHAR(30) UNIQUE NOT NULL,
	[Password] VARCHAR(26) UNIQUE NOT NULL,
	ProfilePicture VARBINARY(MAX) CHECK(DATALENGTH(ProfilePicture) <= 900 * 1024),
	LastLoginTime DATETIME2 NOT NULL,
	IsDeleted BIT NOT NULL
)

INSERT INTO Users(Username, [Password], ProfilePicture, LastLoginTime, IsDeleted)
	VALUES
		('Artificial Intelligence1', '111111111', NULL, '2020-05-21', 0),
		('Artificial Intelligence2', '222222222', NULL, '2020-04-21', 0),
		('Artificial Intelligence3', '333333333', NULL, '2020-05-20', 1),
		('Artificial Intelligence4', '444444444', NULL, '2018-05-11', 0),
		('Artificial Intelligence5', '555555555', NULL, '2017-05-07', 0)

SELECT * FROM Users ORDER BY LastLoginTime DESC

ALTER TABLE Users
DROP CONSTRAINT [PK__Users__3214EC07C10EB170]

ALTER TABLE Users
ADD CONSTRAINT Users_IdUsername
PRIMARY KEY (Id, Username)

ALTER TABLE Users
ADD CONSTRAINT CK_PasswordLength
CHECK(LEN([Password]) >= 5)

ALTER TABLE Users
ADD CONSTRAINT DF_Users
DEFAULT GETDATE() FOR LastLoginTime

ALTER TABLE Users
DROP CONSTRAINT [Users_IdUsername]

ALTER TABLE Users
ADD CONSTRAINT PK_UsersId
PRIMARY KEY (Id)

ALTER TABLE Users
ADD CONSTRAINT CK_UsernameLength
CHECK(LEN(Username) >= 3)

CREATE DATABASE Movies

USE Movies

CREATE TABLE Directors(
	Id INT PRIMARY KEY IDENTITY,
	DirectorName NVARCHAR(50) NOT NULL,
	Notes NVARCHAR(MAX)
)

INSERT INTO Directors(DirectorName)
	VALUES
		('Steven Spielberg1'),
		('Steven Spielberg2'),
		('Steven Spielberg3'),
		('Steven Spielberg4'),
		('Steven Spielberg5')

CREATE TABLE Genres(
	Id INT PRIMARY KEY IDENTITY,
	GenreName NVARCHAR(50) NOT NULL,
	Notes NVARCHAR(MAX)
)

INSERT INTO Genres(GenreName)
	VALUES
		('Sci-Fi1'),
		('Sci-Fi2'),
		('Sci-Fi3'),
		('Sci-Fi4'),
		('Sci-Fi5')

CREATE TABLE Categories(
	Id INT PRIMARY KEY IDENTITY,
	CategoryName NVARCHAR(50) NOT NULL,
	Notes NVARCHAR(MAX)
)

INSERT INTO Categories(CategoryName)
	VALUES
		('Fantasy1'),
		('Fantasy2'),
		('Fantasy3'),
		('Fantasy4'),
		('Fantasy5')

CREATE TABLE Movies(
	Id INT PRIMARY KEY IDENTITY,
	Title NVARCHAR(50) NOT NULL,
	DirectorId INT FOREIGN KEY REFERENCES Directors(Id) NOT NULL,
	CopyrightYear DATE,
	[Length] TIME,
	GenreId INT FOREIGN KEY REFERENCES Genres(Id) NOT NULL,
	CategoryId INT FOREIGN KEY REFERENCES Categories(Id) NOT NULL,
	Rating DECIMAL(4,2) NOT NULL,
	Notes NVARCHAR(MAX)
)

INSERT INTO Movies(Title, DirectorId, GenreId, CategoryId, Rating)
	VALUES
		('Rush Hour 1', 1, 1, 1, 10.00),
		('Rush Hour 2', 2, 2, 2, 5.00),
		('Rush Hour 3', 3, 3, 3, 4.00),
		('Rush Hour 4', 4, 4, 4, 2.00),
		('Rush Hour 5', 5, 5, 5, 9.99)

CREATE DATABASE CarRental

USE CarRental

CREATE TABLE Categories(
	Id INT PRIMARY KEY IDENTITY,
	CategoryName NVARCHAR(50) NOT NULL,
	DailyRate DECIMAL(5, 2) NOT NULL,
	WeeklyRate DECIMAL(6, 2) NOT NULL,
	MonthlyRate DECIMAL(6, 2) NOT NULL,
	WeekendRate DECIMAL(5, 2) NOT NULL
)

INSERT INTO Categories(CategoryName, DailyRate, WeeklyRate, MonthlyRate, WeekendRate)
	VALUES
		('Standard', 6.00, 42.00, 125.50, 0),
		('Standard2', 7.00, 52.00, 155.50, 2),
		('Standard3', 2.00, 22.00, 95.50, 0)

CREATE TABLE Cars(
	Id INT PRIMARY KEY IDENTITY,
	PlateNumber NVARCHAR(20) UNIQUE NOT NULL,
	Manufacturer NVARCHAR(30) NOT NULL,
	Model NVARCHAR(20) NOT NULL,
	CarYear DATE NOT NULL,
	CategoryId INT FOREIGN KEY REFERENCES Categories(Id) NOT NULL,
	Doors INT NOT NULL,
	Picture VARBINARY(MAX),
	Condition NVARCHAR(50) NOT NULL,
	Available BIT NOT NULL,
)

INSERT INTO Cars(PlateNumber, Manufacturer, Model, CarYear, CategoryId, Doors, Condition, Available)
	VALUES
		('CA5495AC', 'Mitsubishi', 'Outlander', '2019-05-20', 1, 4, 'New', 1),
		('CA4695AC', 'Mitsubishi', 'Mirage G4', '2017-05-20', 2, 4, 'New', 0),
		('CA5895AC', 'Mitsubishi', 'Eclipse Cross', '2018-05-20', 3, 4, 'New', 1)

CREATE TABLE Employees(
	Id INT PRIMARY KEY IDENTITY,
	FirstName NVARCHAR(50) NOT NULL,
	LastName NVARCHAR(50) NOT NULL,
	Title NVARCHAR(50) NOT NULL,
	Notes NVARCHAR(MAX)
)

INSERT INTO Employees(FirstName, LastName, Title)
	VALUES
		('Pesho1', 'Gorski1', 'Manager'),
		('Pesho2', 'Gorski2', 'Executive'),
		('Pesho3', 'Gorski3', 'CEO')

CREATE TABLE Customers(
	Id INT PRIMARY KEY IDENTITY,
	DriverLicenceNumber INT UNIQUE NOT NULL,
	FullName NVARCHAR(100) NOT NULL,
	[Address] NVARCHAR(MAX) NOT NULL,
	City NVARCHAR(50) NOT NULL,
	ZIPCode VARCHAR(50) NOT NULL,
	Notes NVARCHAR(MAX)
)

INSERT INTO Customers(DriverLicenceNumber, FullName, [Address], City, ZIPCode)
	VALUES
		(56588448, 'Pesho Gorski1', 'Pliska Str.', 'Cherven briag', '5980'),
		(56577448, 'Pesho Gorski2', 'Pliska Str.', 'Cherven briag', '5980'),
		(56568448, 'Pesho Gorski3', 'Pliska Str.', 'Cherven briag', '5980')

CREATE TABLE RentalOrders(
	Id INT PRIMARY KEY IDENTITY,
	EmployeeId INT FOREIGN KEY REFERENCES Employees(Id) NOT NULL,
	CustomerId INT FOREIGN KEY REFERENCES Customers(Id) NOT NULL,
	CarId INT FOREIGN KEY REFERENCES Cars(Id) NOT NULL,
	TankLevel INT NOT NULL,
	KilometrageStart BIGINT NOT NULL,
	KilometrageEnd BIGINT NOT NULL,
	TotalKilometrage BIGINT NOT NULL,
	StartDate DATE NOT NULL,
	EndDate DATE NOT NULL,
	TotalDays INT NOT NULL,
	RateApplied DECIMAL(5, 2) NOT NULL,
	TaxRate DECIMAL(4, 2) NOT NULL,
	OrderStatus VARCHAR(50) NOT NULL,
	Notes NVARCHAR(MAX)
)

INSERT INTO RentalOrders(EmployeeId, CustomerId, CarId, TankLevel, KilometrageStart, KilometrageEnd, 
TotalKilometrage, StartDate, EndDate, TotalDays, RateApplied, TaxRate, OrderStatus)
	VALUES
		(1, 1, 1, 30, 100, 1000, 50000, '2018-02-19', '2018-02-25', 6, 6.00, 36, 'Returned'),
		(2, 2, 2, 40, 200, 2000, 100000, '2017-02-19', '2017-02-25', 6, 6.00, 36, 'Returned'),
		(3, 3, 3, 50, 500, 5000, 500000, '2016-02-19', '2016-02-25', 6, 6.00, 36, 'Returned')

CREATE DATABASE Hotel

USE Hotel

CREATE TABLE Employees(
	Id INT PRIMARY KEY IDENTITY,
	FirstName NVARCHAR(50) NOT NULL,
	LastName NVARCHAR(50) NOT NULL,
	Title NVARCHAR(50) NOT NULL,
	Notes NVARCHAR(MAX)
)

INSERT INTO Employees(FirstName, LastName, Title)
	VALUES
		('Pesho1', 'Peshkov1', 'Manager1'),
		('Pesho2', 'Peshkov2', 'Manager2'),
		('Pesho3', 'Peshkov3', 'Manager3')

CREATE TABLE Customers(
	AccountNumber INT PRIMARY KEY IDENTITY,
	FirstName NVARCHAR(50) NOT NULL,
	LastName NVARCHAR(50) NOT NULL,
	PhoneNumber BIGINT NOT NULL,
	EmergencyName NVARCHAR(50) NOT NULL,
	EmergencyNumber BIGINT NOT NULL,
	Notes NVARCHAR(MAX)
)

INSERT INTO Customers(FirstName, LastName, PhoneNumber, EmergencyName, EmergencyNumber)
	VALUES
		('Gosho1', 'Goshkov1', 123456789, 'Pesho1', 555555555),
		('Gosho2', 'Goshkov2', 123256789, 'Pesho2', 555556555),
		('Gosho1', 'Goshkov1', 1234516789, 'Pesho3', 555355555)

CREATE TABLE RoomStatus(
	RoomStatus NVARCHAR(50) PRIMARY KEY,
	Notes NVARCHAR(50)
)

INSERT INTO RoomStatus(RoomStatus, Notes)
	VALUES
		('1', 'Резервирана'),
		('2', 'В ремонт'),
		('3', 'Свободна')

CREATE TABLE RoomTypes(
	RoomType NVARCHAR(50) PRIMARY KEY,
	Notes NVARCHAR(MAX)
)

INSERT INTO RoomTypes(RoomType, Notes)
	VALUES
		('Апартамент', 'A'),
		('Двойна стая', 'B'),
		('Единична стая', 'C')


CREATE TABLE BedTypes(
	BedType NVARCHAR(50) PRIMARY KEY,
	Notes NVARCHAR(MAX)
)

INSERT INTO BedTypes(BedType)
	VALUES
		('Двойно легло'),
		('Единично легло'),
		('Кралско легло')

CREATE TABLE Rooms(
	RoomNumber INT PRIMARY KEY IDENTITY,
	RoomType NVARCHAR(50) FOREIGN KEY REFERENCES RoomTypes(RoomType) NOT NULL,
	BedType NVARCHAR(50) FOREIGN KEY REFERENCES BedTypes(BedType) NOT NULL,
	Rate DECIMAL(3, 2) NOT NULL,
	RoomStatus NVARCHAR(50) FOREIGN KEY REFERENCES RoomStatus(RoomStatus) NOT NULL,
	Notes NVARCHAR(MAX)
)

INSERT INTO Rooms(RoomType, BedType, Rate, RoomStatus)
	VALUES
		('Апартамент', 'Двойно легло', 4.55, '1'),
		('Двойна стая', 'Единично легло', 3.55, '2'),
		('Единична стая', 'Кралско легло', 4.95, '3')
		

CREATE TABLE Payments(
	Id INT PRIMARY KEY IDENTITY,
	EmployeeId INT FOREIGN KEY REFERENCES Employees(Id) NOT NULL,
	PaymentDate DATE NOT NULL,
	AccountNumber INT FOREIGN KEY REFERENCES Customers(AccountNumber) NOT NULL,
	FirstDateOccupied DATE NOT NULL,
	LastDateOccupied DATE NOT NULL,
	TotalDays INT NOT NULL,
	AmountCharged DECIMAL(6, 2) NOT NULL,
	TaxRate DECIMAL(4, 2) NOT NULL,
	TaxAmount DECIMAL(5, 2) NOT NULL,
	PaymentTotal DECIMAL(6, 2) NOT NULL,
	Notes NVARCHAR(MAX)
)

INSERT INTO Payments(EmployeeId, PaymentDate, AccountNumber, FirstDateOccupied, LastDateOccupied,
TotalDays, AmountCharged, TaxRate, TaxAmount, PaymentTotal)
	VALUES
		(1, '2020-05-22', 1, '2020-05-21', '2020-05-22', 1, 120.00, 20, 20, 120),
		(2, '2020-05-22', 2, '2020-05-21', '2020-05-22', 2, 110.00, 15, 15, 150),
		(3, '2020-05-22', 3, '2020-05-21', '2020-05-22', 3, 100.00, 10, 10, 100)

CREATE TABLE Occupancies(
	Id INT PRIMARY KEY IDENTITY,
	EmployeeId INT FOREIGN KEY REFERENCES Employees(Id) NOT NULL,
	DateOccupied DATE NOT NULL,
	AccountNumber INT FOREIGN KEY REFERENCES Customers(AccountNumber) NOT NULL,
	RoomNumber INT FOREIGN KEY REFERENCES Rooms(RoomNumber) NOT NULL,
	RateApplied DECIMAL(4, 2) NOT NULL,
	PhoneCharge DECIMAL(5, 2),
	Notes NVARCHAR(MAX)
)

INSERT INTO Occupancies(EmployeeId, DateOccupied, AccountNumber, RoomNumber, RateApplied)
	VALUES
		(1, '2020-05-21', 1, 2, 10),
		(2, '2020-05-21', 2, 3, 10),
		(3, '2020-05-21', 3, 4, 10)

