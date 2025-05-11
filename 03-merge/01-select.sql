USE CP2025;
GO

SELECT
    -- Primary key
    E.BusinessEntityID,

    E.NationalIDNumber,

    -- Unique key
    E.LoginID,

    E.OrganizationNode,
    E.OrganizationLevel,
    E.JobTitle,
    E.BirthDate,
    E.MaritalStatus,
    E.Gender,
    E.HireDate,
    E.SalariedFlag,
    E.VacationHours,
    E.SickLeaveHours,
    E.CurrentFlag,
    E.rowguid,
    E.ModifiedDate,
    P.BusinessEntityID,
    P.PersonType,
    P.NameStyle,
    P.Title,
    P.FirstName,
    P.MiddleName,
    P.LastName,
    P.Suffix,
    P.EmailPromotion,
    P.AdditionalContactInfo,
    P.Demographics,
    P.rowguid,
    P.ModifiedDate

FROM AdventureWorks2022.HumanResources.Employee E
INNER JOIN AdventureWorks2022.Person.Person P ON P.BusinessEntityID = E.BusinessEntityID;
GO

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
