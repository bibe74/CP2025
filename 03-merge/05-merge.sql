USE CP2025;
GO

CREATE OR ALTER VIEW Dim.EmployeeView
AS
WITH TableData
AS (
    SELECT
        CONVERT(VARBINARY(20), HASHBYTES('MD5', CONCAT(
            E.BusinessEntityID,
            ' '
        ))) AS HistoricalHashKey,
        CONVERT(VARBINARY(20), HASHBYTES('MD5', CONCAT(
            E.LoginID,
            P.FirstName,
            P.LastName,
            E.JobTitle,
            E.BirthDate,
            E.MaritalStatus,
            E.Gender,
            E.HireDate,
            ' '
        ))) AS ChangeHashKey,
        CURRENT_TIMESTAMP AS InsertDatetime,
        CURRENT_TIMESTAMP AS UpdateDatetime,

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
    INNER JOIN AdventureWorks2022.Person.Person P ON P.BusinessEntityID = E.BusinessEntityID
)
SELECT
    -- Chiavi
    TD.BusinessEntityID,

    -- Campi per sincronizzazione
    TD.HistoricalHashKey,
    TD.ChangeHashKey,
    TD.InsertDatetime,
    TD.UpdateDatetime,
    CAST(0 AS BIT) AS IsDeleted,

    -- Altri campi
    TD.LoginID,
    TD.FirstName,
    TD.LastName,
    TD.JobTitle,
    TD.BirthDate,
    TD.MaritalStatus,
    TD.Gender,
    TD.HireDate

FROM TableData TD;
GO

DROP TABLE IF EXISTS Dim.Employee;
GO

IF OBJECT_ID(N'Dim.Employee', N'U') IS NULL
BEGIN
    SELECT TOP 0 * INTO Dim.Employee FROM Dim.EmployeeView;

    ALTER TABLE Dim.Employee ADD CONSTRAINT PK_Dim_Employee PRIMARY KEY CLUSTERED (UpdateDatetime, BusinessEntityID);

    CREATE UNIQUE NONCLUSTERED INDEX IX_Dim_Employee_BusinessKey ON Dim.Employee (BusinessEntityID);
END;
GO

CREATE OR ALTER PROCEDURE Dim.usp_Merge_Employee
AS
BEGIN
SET NOCOUNT ON;

MERGE INTO Dim.Employee AS TGT
USING Dim.EmployeeView AS SRC
ON SRC.BusinessEntityID = TGT.BusinessEntityID

WHEN MATCHED AND (SRC.ChangeHashKey <> TGT.ChangeHashKey)
  THEN UPDATE SET
    TGT.ChangeHashKey = SRC.ChangeHashKey,
    --TGT.InsertDatetime = SRC.InsertDatetime,
    TGT.UpdateDatetime = SRC.UpdateDatetime,
    TGT.IsDeleted = SRC.IsDeleted,
    TGT.LoginID = SRC.LoginID,
    TGT.FirstName = SRC.FirstName,
    TGT.LastName = SRC.LastName,
    TGT.JobTitle = SRC.JobTitle,
    TGT.BirthDate = SRC.BirthDate,
    TGT.MaritalStatus = SRC.MaritalStatus,
    TGT.Gender = SRC.Gender,
    TGT.HireDate = SRC.HireDate

WHEN NOT MATCHED AND SRC.IsDeleted = CAST(0 AS BIT)
  THEN INSERT VALUES (
    SRC.BusinessEntityID,
    HistoricalHashKey,
    ChangeHashKey,
    InsertDatetime,
    UpdateDatetime,
    IsDeleted,
    SRC.LoginID,
    SRC.FirstName,
    SRC.LastName,
    SRC.JobTitle,
    SRC.BirthDate,
    SRC.MaritalStatus,
    SRC.Gender,
    SRC.HireDate
  )

WHEN NOT MATCHED BY SOURCE
    AND TGT.IsDeleted = CAST(0 AS BIT)
  THEN UPDATE SET TGT.IsDeleted = CAST(1 AS BIT),
    TGT.ChangeHashKey = CONVERT(VARBINARY(20), '')

OUTPUT
    CURRENT_TIMESTAMP AS merge_datetime,
    ----$action AS merge_action,
    CASE WHEN Inserted.IsDeleted = CAST(1 AS BIT) THEN N'DELETE' ELSE $action END AS merge_action,
    'Dim.Employee' AS full_olap_table_name,
    'BusinessEntityID = ' + CAST(COALESCE(inserted.BusinessEntityID, deleted.BusinessEntityID) AS NVARCHAR) AS primary_key_description;

END;
GO

EXEC Dim.usp_Merge_Employee;
GO

SELECT * FROM Dim.Employee;
GO
