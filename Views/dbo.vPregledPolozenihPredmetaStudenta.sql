SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE VIEW [dbo].[vPregledPolozenihPredmetaStudenta]
AS
SELECT DISTINCT o.Ime, o.Prezime, sm.Semestar,s.IdStudij, s.Smjer, s.Studij , CAST(COUNT(IIF(sp.Ocjena>1,sp.Ocjena,null)) AS VARCHAR(10)) +'/'+ (CAST(COUNT(p.Predmet) AS VARCHAR(10))) AS polozeno_predmeta
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
WHERE			oo.StatusOsobe = 'Student' AND
				ao.StatusAktivnosti = 'DA'
GROUP BY o.Ime,o.Prezime,sm.Semestar, s.IdStudij, s.Smjer, s.Studij




GO
