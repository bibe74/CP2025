USE PO2025;
GO

CREATE OR ALTER VIEW Dim.EmployeeView
AS
SELECT
    E.BusinessEntityID,
    E.LoginID,
    P.FirstName,
    P.LastName,
    E.JobTitle,
    E.BirthDate,
    E.MaritalStatus,
    E.Gender,
    E.HireDate

FROM AdventureWorks2022.HumanResources.Employee E
INNER JOIN AdventureWorks2022.Person.Person P ON P.BusinessEntityID = E.BusinessEntityID;
GO

DROP TABLE IF EXISTS Dim.Employee;
GO

IF OBJECT_ID('Dim.Employee', 'U') IS NULL
BEGIN

    SELECT TOP (0) * INTO Dim.Employee FROM Dim.EmployeeView;

    ALTER TABLE Dim.Employee ADD CONSTRAINT PK_Dim_Employee PRIMARY KEY CLUSTERED (BusinessEntityID);

END;
GO

SELECT * FROM Dim.Employee;
GO

CREATE OR ALTER PROCEDURE Dim.usp_Reload_Employee
AS
BEGIN

    TRUNCATE TABLE Dim.Employee;
    
    INSERT INTO Dim.Employee SELECT * FROM Dim.EmployeeView;

END;
GO

EXEC Dim.usp_Reload_Employee;
GO

SELECT * FROM Dim.Employee;
