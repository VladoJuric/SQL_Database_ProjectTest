SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[vZavrsnaOcjenaStudenata]
AS
--SELECT DISTINCT o.PkOsoba, o.Ime, o.Prezime, p.Predmet, ao.StatusAktivnosti, sm.Semestar,s.IdStudij, s.Smjer, s.Studij, CAST((SUM(ISNULL(sp.Ocjena,0)) / (COUNT(p.Predmet))) AS DECIMAL(2,1)) AS prosjecna_ocjena, CONVERT(INT,(CAST((SUM(ISNULL(sp.Ocjena,0)) / (COUNT(p.Predmet))) AS DECIMAL(2,1))) + 0.5) AS zakljucna_ocjena
--FROM            StudentPredmet AS sp 
--				INNER JOIN Osoba AS o 
--				ON sp.PkOsoba = o.PkOsoba
--				INNER JOIN Predmet p
--				ON sp.PkPredmet = p.PkPredmet
--				INNER JOIN Smjer s
--				ON p.PkSmjer = s.PkSmjer
--				INNER JOIN Semestar sm
--				ON p.PkSemestar = sm.PkSemestar
--				INNER JOIN AppDataOsoba ao
--				ON ao.PkAppDataOsoba = o.PkAppDataOsoba
--				INNER JOIN OsobaOpis oo
--				ON oo.PkOsobaOpis = o.PkOsobaOpis
--WHERE			oo.StatusOsobe = 'Student' AND
--				ao.StatusAktivnosti = 'NE' AND
--				sp.Ocjena > 1 AND
--				(sm.Semestar = '6. Semestar' AND s.Studij = 'Strucni') OR
--				(sm.Semestar = '10. Semestar' AND s.Studij = 'Preddiplomski')
--GROUP BY o.PkOsoba, o.Ime,o.Prezime,p.Predmet,ao.StatusAktivnosti, sm.Semestar, s.IdStudij, s.Smjer, s.Studij

SELECT DISTINCT o.PkOsoba, o.Ime, o.Prezime, p.Predmet, ao.StatusAktivnosti, sm.Semestar,s.IdStudij, s.Smjer, s.Studij, spz.ZakljucnaOcjena
FROM            StudentPredmet AS sp 
				INNER JOIN Osoba AS o 
				ON sp.PkOsoba = o.PkOsoba
				INNER JOIN Predmet p
				ON sp.PkPredmet = p.PkPredmet
				INNER JOIN Smjer s
				ON p.PkSmjer = s.PkSmjer
				INNER JOIN Semestar sm
				ON p.PkSemestar = sm.PkSemestar
				INNER JOIN AppDataOsoba ao
				ON ao.PkAppDataOsoba = o.PkAppDataOsoba
				INNER JOIN OsobaOpis oo
				ON oo.PkOsobaOpis = o.PkOsobaOpis
				INNER JOIN dbo.StudentPredmetZakljucno spz
				ON sp.PkOsoba=spz.PkOsoba AND sp.PkPredmet=spz.PkOsoba
WHERE			oo.StatusOsobe = 'Student' AND
				ao.StatusAktivnosti = 'NE' AND
				sp.Ocjena > 1 AND
				(sm.Semestar = '6. Semestar' AND s.Studij = 'Strucni') OR
				(sm.Semestar = '10. Semestar' AND s.Studij = 'Preddiplomski')
GO
