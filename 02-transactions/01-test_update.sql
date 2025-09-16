USE PO2025;
GO

SELECT * FROM dbo.Dischi;
GO

SELECT
    D.IDDisco,
    D.IDAutore,
    A.Autore,
    D.Titolo,
    D.Anno,
    D.IsAscoltato,

    1 AS IsAscoltato_NEW

FROM dbo.Dischi D
INNER JOIN dbo.Autori A ON A.IDAutore = D.IDAutore;
GO

SELECT
    D.IDDisco,
    D.IDAutore,
    D.Titolo,
    D.Anno,
    D.IsAscoltato,

    1 AS IsAscoltato_NEW

FROM dbo.Dischi D
WHERE D.Anno < 2015;
GO

--> UPDATE (CTRL+C, CTRL+V*)
