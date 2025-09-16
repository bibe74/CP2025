USE PO2025;
GO

SELECT
    C.CustomerID,
    C.AccountNumber,
    P.FirstName,
    P.LastName,
    CFOD.FirstOrderDate,
    CLOD.LastOrderDate,
    COC.OrderCount,
    CPTAN.ProductNumber AS MostSoldProductNumber,
    CPTAN.TotalAmount AS MostSoldProductTotalAmount

FROM AdventureWorks2022.Sales.Customer C
LEFT JOIN (
    SELECT
        CustomerID,
        MIN(OrderDate) AS FirstOrderDate

    FROM AdventureWorks2022.Sales.SalesOrderHeader
    GROUP BY CustomerID
) CFOD ON CFOD.CustomerID = C.CustomerID
LEFT JOIN (
    SELECT
        CustomerID,
        MAX(OrderDate) AS LastOrderDate

    FROM AdventureWorks2022.Sales.SalesOrderHeader
    GROUP BY CustomerID
) CLOD ON CLOD.CustomerID = C.CustomerID
LEFT JOIN (
    SELECT
        CustomerID,
        COUNT(DISTINCT SalesOrderID) AS OrderCount

    FROM AdventureWorks2022.Sales.SalesOrderHeader
    GROUP BY CustomerID
) COC ON COC.CustomerID = C.CustomerID
LEFT JOIN (
    SELECT
        CPTA.CustomerID,
        CPTA.ProductID,
        CPTA.ProductNumber,
        CPTA.TotalAmount,
        ROW_NUMBER() OVER (PARTITION BY CPTA.CustomerID ORDER BY CPTA.TotalAmount DESC) AS rn

    FROM (
        SELECT
            SOH.CustomerID,
            P.ProductID,
            P.ProductNumber,
            SUM(SOD.LineTotal) AS TotalAmount

        FROM AdventureWorks2022.Sales.SalesOrderHeader SOH
        INNER JOIN AdventureWorks2022.Sales.SalesOrderDetail SOD ON SOD.SalesOrderID = SOH.SalesOrderID
        INNER JOIN AdventureWorks2022.Production.Product P ON P.ProductID = SOD.ProductID
        GROUP BY SOH.CustomerID,
            P.ProductID,
            P.ProductNumber
    ) CPTA
) CPTAN ON CPTAN.CustomerID = C.CustomerID
    AND CPTAN.rn = 1
INNER JOIN AdventureWorks2022.Person.Person P ON P.BusinessEntityID = C.PersonID
ORDER BY C.CustomerID;
GO

--> Name each subquery

--> Compact CFOD, CLOD and COC

/*
WITH CustomerFirstOrderDate
AS (
    SELECT
        CustomerID,
        MIN(OrderDate) AS FirstOrderDate

    FROM AdventureWorks2022.Sales.SalesOrderHeader
    GROUP BY CustomerID
),
CustomerLastOrderDate
AS (
    SELECT
        CustomerID,
        MAX(OrderDate) AS LastOrderDate

    FROM AdventureWorks2022.Sales.SalesOrderHeader
    GROUP BY CustomerID
),
CustomerOrderCount
AS (
    SELECT
        CustomerID,
        COUNT(DISTINCT SalesOrderID) AS OrderCount

    FROM AdventureWorks2022.Sales.SalesOrderHeader
    GROUP BY CustomerID
),
CustomerProductTotalAmount
AS (
    SELECT
        SOH.CustomerID,
        P.ProductID,
        P.ProductNumber,
        SUM(SOD.LineTotal) AS TotalAmount

    FROM AdventureWorks2022.Sales.SalesOrderHeader SOH
    INNER JOIN AdventureWorks2022.Sales.SalesOrderDetail SOD ON SOD.SalesOrderID = SOH.SalesOrderID
    INNER JOIN AdventureWorks2022.Production.Product P ON P.ProductID = SOD.ProductID
    GROUP BY SOH.CustomerID,
        P.ProductID,
        P.ProductNumber
),
CustomerProductTotalAmountNumbered
AS (
    SELECT
        CPTA.CustomerID,
        CPTA.ProductID,
        CPTA.ProductNumber,
        CPTA.TotalAmount,
        ROW_NUMBER() OVER (PARTITION BY CPTA.CustomerID ORDER BY CPTA.TotalAmount DESC) AS rn

    FROM CustomerProductTotalAmount CPTA
)
SELECT
    C.CustomerID,
    C.AccountNumber,
    P.FirstName,
    P.LastName,
    CFOD.FirstOrderDate,
    CLOD.LastOrderDate,
    COC.OrderCount,
    CPTAN.ProductNumber AS MostSoldProductNumber,
    CPTAN.TotalAmount AS MostSoldProductTotalAmount

FROM AdventureWorks2022.Sales.Customer C
LEFT JOIN CustomerFirstOrderDate CFOD ON CFOD.CustomerID = C.CustomerID
LEFT JOIN CustomerLastOrderDate CLOD ON CLOD.CustomerID = C.CustomerID
LEFT JOIN CustomerOrderCount COC ON COC.CustomerID = C.CustomerID
LEFT JOIN CustomerProductTotalAmountNumbered CPTAN ON CPTAN.CustomerID = C.CustomerID
    AND CPTAN.rn = 1
INNER JOIN AdventureWorks2022.Person.Person P ON P.BusinessEntityID = C.PersonID
ORDER BY C.CustomerID;
GO
*/
