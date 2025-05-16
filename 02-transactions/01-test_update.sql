USE CP2025;
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
INNER JOIN dbo.Autori A ON A.IDAutore = D.IDAutore
WHERE D.Anno < 2015;
GO

BEGIN TRANSACTION 

UPDATE dbo.Dischi
SET IsAscoltato = 1;

ROLLBACK TRANSACTION 
GO
