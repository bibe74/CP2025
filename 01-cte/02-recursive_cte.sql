USE PO2025;
GO

SELECT * FROM AW2022.Employee;
GO

SELECT
    E.BusinessEntityID,
    E.FirstName,
    E.LastName,
    E.JobTitle,
    E.ManagerBusinessEntityID,
    M.FirstName,
    M.LastName,
    M.JobTitle

FROM AW2022.Employee E
LEFT JOIN AW2022.Employee M ON M.BusinessEntityID = E.ManagerBusinessEntityID;
GO

-- Level 0 (CEO)
SELECT
    E.BusinessEntityID,
    0 AS OrganizationLevel,
    E.FirstName,
    E.LastName,
    E.JobTitle,
    E.ManagerBusinessEntityID

FROM AW2022.Employee E
LEFT JOIN AW2022.Employee M ON M.BusinessEntityID = E.ManagerBusinessEntityID
WHERE M.BusinessEntityID IS NULL;
GO

-- Level 1 (reports to the CEO) 
SELECT
    E.BusinessEntityID,
    1 AS OrganizationLevel,
    E.FirstName,
    E.LastName,
    E.JobTitle,
    E.ManagerBusinessEntityID,
    M.FirstName AS ManagerFirstName,
    M.LastName AS ManagerLastName,
    M.JobTitle AS ManagerJobTitle

FROM AW2022.Employee E
INNER JOIN AW2022.Employee M ON M.BusinessEntityID = E.ManagerBusinessEntityID
WHERE M.BusinessEntityID = 1;
GO

-- Level 2 (reports to someone who reports to the CEO) 
SELECT
    E.BusinessEntityID,
    2 AS OrganizationLevel,
    E.FirstName,
    E.LastName,
    E.JobTitle,
    E.ManagerBusinessEntityID,
    M.FirstName AS ManagerFirstName,
    M.LastName AS ManagerLastName,
    M.JobTitle AS ManagerJobTitle,
    M.ManagerBusinessEntityID AS ManagerManagerBusinessEntityID,
    MM.FirstName AS ManagerManagerFirstName,
    MM.LastName AS ManagerManagerLastName,
    MM.JobTitle AS ManagerManagerJobTitle

FROM AW2022.Employee E
INNER JOIN AW2022.Employee M ON M.BusinessEntityID = E.ManagerBusinessEntityID
INNER JOIN AW2022.Employee MM ON MM.BusinessEntityID = M.ManagerBusinessEntityID
WHERE M.ManagerBusinessEntityID = 1;
GO

--> Recursive CTE: anchor, recursive expression

--> Add breadcrumbs

--> Infinite loop

--> Solve and check infinite loops

/*
WITH Organization
AS (
    SELECT
        E.BusinessEntityID,
        0 AS OrganizationLevel,
        E.ManagerBusinessEntityID,
        E.Title,
        E.FirstName,
        E.LastName,
        E.Suffix,
        E.LoginID,
        E.JobTitle,
        E.BirthDate,
        E.MaritalStatus,
        E.Gender,
        E.HireDate,
        E.VacationHours,
        E.SickLeaveHours

    FROM AW2022.Employee E
    LEFT JOIN AW2022.Employee M ON M.BusinessEntityID = E.ManagerBusinessEntityID
    WHERE M.BusinessEntityID IS NULL
    
    UNION ALL

    SELECT
        E.BusinessEntityID,
        O.OrganizationLevel + 1,
        E.ManagerBusinessEntityID,
        E.Title,
        E.FirstName,
        E.LastName,
        E.Suffix,
        E.LoginID,
        E.JobTitle,
        E.BirthDate,
        E.MaritalStatus,
        E.Gender,
        E.HireDate,
        E.VacationHours,
        E.SickLeaveHours

    FROM Organization O
    INNER JOIN AW2022.Employee E ON E.ManagerBusinessEntityID = O.BusinessEntityID
)
SELECT
    *
    
FROM Organization O
ORDER BY O.OrganizationLevel,
    O.BusinessEntityID;
GO
*/
