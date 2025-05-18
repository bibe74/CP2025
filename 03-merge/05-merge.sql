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
    WHERE E.CurrentFlag = 1
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
    TGT.ChangeHashKey = CONVERT(VARBINARY(20), ''),
    TGT.UpdateDatetime = CURRENT_TIMESTAMP

OUTPUT
    CURRENT_TIMESTAMP AS merge_datetime,
    ----$action AS merge_action,
    CASE WHEN Inserted.IsDeleted = CAST(1 AS BIT) THEN N'DELETE' ELSE $action END AS merge_action,
    'Dim.Employee' AS full_olap_table_name,
    'FirstName = ' + CAST(COALESCE(inserted.FirstName, deleted.FirstName) AS NVARCHAR)
        + ', LastName = ' + CAST(COALESCE(inserted.LastName, deleted.LastName) AS NVARCHAR) AS primary_key_description;

END;
GO

EXEC Dim.usp_Merge_Employee;
GO

SELECT * FROM Dim.Employee;
GO

/* Update #1: Isabella Richardson gets hired as a Sales Representative */

SELECT * FROM AdventureWorks2022.Person.Person WHERE BusinessEntityID = 20774;
GO

INSERT INTO AdventureWorks2022.HumanResources.Employee (
    BusinessEntityID,
    NationalIDNumber,
    LoginID,
    OrganizationNode,
    JobTitle,
    BirthDate,
    MaritalStatus,
    Gender,
    HireDate,
    SalariedFlag,
    VacationHours,
    SickLeaveHours,
    CurrentFlag,
    rowguid,
    ModifiedDate
)
VALUES
(
    20774,                              -- BusinessEntityID - int
    N'15483774',                        -- NationalIDNumber - nvarchar(15)
    N'adventure-works\isabella0',       -- LoginID - nvarchar(256)
    NULL,                               -- OrganizationNode - hierarchyid
    N'Sales Representative',            -- JobTitle - nvarchar(50)
    '1974-02-15',                       -- BirthDate - date
    N'S',                               -- MaritalStatus - nchar(1)
    N'F',                               -- Gender - nchar(1)
    CONVERT(DATE, CURRENT_TIMESTAMP),   -- HireDate - date
    DEFAULT,                            -- SalariedFlag - Flag
    DEFAULT,                            -- VacationHours - smallint
    DEFAULT,                            -- SickLeaveHours - smallint
    DEFAULT,                            -- CurrentFlag - Flag
    DEFAULT,                            -- rowguid - uniqueidentifier
    DEFAULT                             -- ModifiedDate - datetime
);
GO

/* Update #2: Terri Duffy (#2) & Rob Walters (#4) get married */

SELECT * FROM AdventureWorks2022.HumanResources.Employee WHERE BusinessEntityID IN (2, 4);
GO

UPDATE AdventureWorks2022.HumanResources.Employee
SET MaritalStatus = 'M'
WHERE BusinessEntityID IN (2, 14);
GO

/* Update #3: Roberto Tamburello (#3) calls in sick for the day */

SELECT * FROM AdventureWorks2022.HumanResources.Employee WHERE BusinessEntityID = 3;
GO

UPDATE AdventureWorks2022.HumanResources.Employee
SET SickLeaveHours = SickLeaveHours + 8
WHERE BusinessEntityID = 3;
GO

/* Update #4: Ranjit Varkey Chudukatil (#290) leaves the organization */

SELECT * FROM AdventureWorks2022.HumanResources.Employee WHERE BusinessEntityID = 290;
GO

UPDATE AdventureWorks2022.HumanResources.Employee SET CurrentFlag = 0 WHERE BusinessEntityID = 290;
GO

/* Let's merge! */

EXEC Dim.usp_Merge_Employee;
GO

SELECT * FROM Dim.Employee ORDER BY UpdateDatetime DESC, BusinessEntityID;
GO

/* Test

BEGIN TRANSACTION 

INSERT INTO AdventureWorks2022.HumanResources.Employee (
    BusinessEntityID,
    NationalIDNumber,
    LoginID,
    OrganizationNode,
    JobTitle,
    BirthDate,
    MaritalStatus,
    Gender,
    HireDate,
    SalariedFlag,
    VacationHours,
    SickLeaveHours,
    CurrentFlag,
    rowguid,
    ModifiedDate
)
VALUES
(
    20774,                              -- BusinessEntityID - int
    N'15483774',                        -- NationalIDNumber - nvarchar(15)
    N'adventure-works\isabella0',       -- LoginID - nvarchar(256)
    NULL,                               -- OrganizationNode - hierarchyid
    N'Sales Representative',            -- JobTitle - nvarchar(50)
    '1974-02-15',                       -- BirthDate - date
    N'S',                               -- MaritalStatus - nchar(1)
    N'F',                               -- Gender - nchar(1)
    CONVERT(DATE, CURRENT_TIMESTAMP),   -- HireDate - date
    DEFAULT,                            -- SalariedFlag - Flag
    DEFAULT,                            -- VacationHours - smallint
    DEFAULT,                            -- SickLeaveHours - smallint
    DEFAULT,                            -- CurrentFlag - Flag
    DEFAULT,                            -- rowguid - uniqueidentifier
    DEFAULT                             -- ModifiedDate - datetime
);

UPDATE AdventureWorks2022.HumanResources.Employee
SET MaritalStatus = 'M'
WHERE BusinessEntityID IN (2, 14);

UPDATE AdventureWorks2022.HumanResources.Employee
SET SickLeaveHours = SickLeaveHours + 8
WHERE BusinessEntityID = 3;

UPDATE AdventureWorks2022.HumanResources.Employee SET CurrentFlag = 0 WHERE BusinessEntityID = 290;

EXEC Dim.usp_Merge_Employee;

SELECT * FROM Dim.Employee ORDER BY UpdateDatetime DESC, BusinessEntityID;

ROLLBACK TRANSACTION 
GO

*/

--> Add another field to the dimension

--> Log to a table

DROP TABLE IF EXISTS audit.merge_log_details;
GO

IF OBJECT_ID('audit.merge_log_details', 'U') IS NULL
BEGIN

    CREATE TABLE audit.merge_log_details (
        merge_datetime          DATETIME CONSTRAINT DFT_audit_merge_log_details_merge_datetime DEFAULT(CURRENT_TIMESTAMP) NOT NULL,
        merge_action            NVARCHAR(10) NOT NULL,
        full_olap_table_name    NVARCHAR(261) NOT NULL,
        primary_key_description NVARCHAR(1000) NOT NULL
    );

    CREATE NONCLUSTERED INDEX IX_audit_merge_log_details ON audit.merge_log_details (merge_datetime, merge_action, full_olap_table_name);

END;
GO

CREATE OR ALTER VIEW audit.merge_logView
AS
SELECT
    merge_datetime,
    full_olap_table_name,
    COALESCE ([1], 0) AS inserted_rows,
    COALESCE ([2], 0) AS updated_rows,
    COALESCE ([3], 0) AS deleted_rows

FROM (
    SELECT
        MLD.merge_datetime,
        MLD.full_olap_table_name,
        A.merge_action_id,
        1 AS recordCount

    FROM audit.merge_log_details MLD
    INNER JOIN (
        SELECT
            1 AS merge_action_id,
            'INSERT' AS merge_action

        UNION ALL SELECT 2, 'UPDATE'
        UNION ALL SELECT 3, 'DELETE'
    ) A ON MLD.merge_action = A.merge_action
) AS SourceTable
PIVOT (
    COUNT(SourceTable.recordCount)
    FOR merge_action_id IN (
        [1],
        [2],
        [3]
    )
) AS PivotTable;
GO

DROP TABLE IF EXISTS audit.merge_log;
GO

IF OBJECT_ID('audit.merge_log', N'U') IS NULL
BEGIN

    CREATE TABLE audit.merge_log (
        merge_datetime DATETIME CONSTRAINT DFT_audit_merge_log_merge_datetime DEFAULT (CURRENT_TIMESTAMP) NOT NULL,
        full_olap_table_name NVARCHAR(261) NOT NULL,
        inserted_rows INT CONSTRAINT DFT_audit_merge_log_inserted_rows DEFAULT (0) NOT NULL,
        updated_rows INT CONSTRAINT DFT_audit_merge_log_updated_rows DEFAULT (0) NOT NULL,
        deleted_rows INT CONSTRAINT DFT_audit_merge_log_deleted_rows DEFAULT (0) NOT NULL,

        CONSTRAINT PK_audit_merge_log
            PRIMARY KEY CLUSTERED (
                merge_datetime,
                full_olap_table_name
            )
    );

END;
GO

CREATE OR ALTER PROCEDURE audit.usp_compact_merge_log
AS
BEGIN

    SET NOCOUNT ON;

    INSERT INTO audit.merge_log
    SELECT * FROM audit.merge_logView
    ORDER BY merge_datetime,
            full_olap_table_name;

    TRUNCATE TABLE audit.merge_log_details;

END;
GO

EXEC audit.usp_compact_merge_log;
GO
