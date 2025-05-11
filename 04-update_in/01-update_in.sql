-- Elenco province per numero comuni
SELECT
    C.IdProvincia,
    C.DenominazioneProvincia,
    COUNT(1) AS NumeroComuni

FROM dbo.Comune C
GROUP BY C.IdProvincia,
    C.DenominazioneProvincia
ORDER BY NumeroComuni DESC;
GO

-- Update secco > OK
UPDATE dbo.Comune
SET DenominazioneProvincia = N'Bréha'
WHERE IdProvincia = N'BS';
GO

-- Elenco province per numero comuni
SELECT
    C.IdProvincia,
    C.DenominazioneProvincia,
    COUNT(1) AS NumeroComuni

FROM dbo.Comune C
GROUP BY C.IdProvincia,
    C.DenominazioneProvincia
ORDER BY NumeroComuni DESC;
GO

-- Query volutamente errata: il campo IdProvincia non esiste
SELECT IdProvincia FROM dbo.Provincia WHERE Denominazione = N'Brescia';
GO

-- Query corretta
SELECT Id FROM dbo.Provincia WHERE Denominazione = N'Brescia';
GO

-- Update con WHERE IdProvincia IN (SELECT Id FROM ...) > OK
UPDATE dbo.Comune
SET DenominazioneProvincia = N'Bressa'
WHERE IdProvincia IN (SELECT Id FROM dbo.Provincia WHERE Denominazione = N'Brescia');
GO

-- Elenco province per numero comuni
SELECT
    C.IdProvincia,
    C.DenominazioneProvincia,
    COUNT(1) AS NumeroComuni

FROM dbo.Comune C
GROUP BY C.IdProvincia,
    C.DenominazioneProvincia
ORDER BY NumeroComuni DESC;
GO

-- La subquery per recuperare gli IdProvincia da modificare è quella con il nome di campo errato
UPDATE dbo.Comune
SET DenominazioneProvincia = N'Brescia'
WHERE IdProvincia IN (SELECT IdProvincia FROM dbo.Provincia WHERE Denominazione = N'Brescia');
GO

-- Elenco province per numero comuni
SELECT
    C.IdProvincia,
    C.DenominazioneProvincia,
    COUNT(1) AS NumeroComuni

FROM dbo.Comune C
GROUP BY C.IdProvincia,
    C.DenominazioneProvincia
ORDER BY NumeroComuni DESC;
GO

/*

    < WTF?!? >
     --------
            \   ^__^
             \  (oo)\_______
                (__)\       )\/\
                    ||----w |
                    ||     ||

*/
