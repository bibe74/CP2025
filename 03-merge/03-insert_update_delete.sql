USE CP2025;
GO

CREATE OR ALTER PROCEDURE Dim.usp_Update_Employee
AS
BEGIN

    -- Insert new record(s)
    INSERT INTO Dim.Employee (
        BusinessEntityID,
        LoginID,
        FirstName,
        LastName,
        JobTitle,
        BirthDate,
        MaritalStatus,
        Gender,
        HireDate
    )
    SELECT
        V.BusinessEntityID,
        V.LoginID,
        V.FirstName,
        V.LastName,
        V.JobTitle,
        V.BirthDate,
        V.MaritalStatus,
        V.Gender,
        V.HireDate

    FROM Dim.EmployeeView V
    LEFT JOIN Dim.Employee T ON T.BusinessEntityID = V.BusinessEntityID
    WHERE T.BusinessEntityID IS NULL;

    -- Update records with modified LoginID
    UPDATE T
    SET T.LoginID = V.LoginID

    FROM Dim.EmployeeView V
    INNER JOIN Dim.Employee T ON T.BusinessEntityID = V.BusinessEntityID
    WHERE V.LoginID <> T.LoginID;

    -- Repeat for each field
    -- ...
    
    -- Delete deleted records
    DELETE T

    FROM Dim.EmployeeView V
    RIGHT JOIN Dim.Employee T ON T.BusinessEntityID = V.BusinessEntityID
    WHERE V.BusinessEntityID IS NULL;

END;
GO

EXEC Dim.usp_Update_Employee;
GO
