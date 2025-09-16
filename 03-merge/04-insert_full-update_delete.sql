USE PO2025;
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

    -- Update records with any modified field
    UPDATE T
    SET T.LoginID = V.LoginID,
        T.FirstName = V.FirstName,
        T.LastName = V.LastName,
        T.JobTitle = V.JobTitle,
        T.BirthDate = V.BirthDate,
        T.MaritalStatus = V.MaritalStatus,
        T.Gender = V.Gender,
        T.HireDate = V.HireDate

    FROM Dim.EmployeeView V
    INNER JOIN Dim.Employee T ON T.BusinessEntityID = V.BusinessEntityID
    WHERE V.LoginID <> T.LoginID
        OR V.FirstName <> T.FirstName
        OR V.LastName <> T.LastName
        OR V.JobTitle <> T.JobTitle
        OR V.BirthDate <> T.BirthDate
        OR V.MaritalStatus <> T.MaritalStatus
        OR V.Gender <> T.Gender
        OR V.HireDate <> T.HireDate;

    -- Delete deleted records
    DELETE T

    FROM Dim.EmployeeView V
    RIGHT JOIN Dim.Employee T ON T.BusinessEntityID = V.BusinessEntityID
    WHERE V.BusinessEntityID IS NULL;

END;
GO

EXEC Dim.usp_Update_Employee;
GO
