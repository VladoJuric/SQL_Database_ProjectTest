SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE view [dbo].[vPregledStudenataKojiZavrsavajuStudij]
as
select distinct o.Ime,o.Prezime,sm.Semestar,s.Studij,s.Smjer
        from Osoba o
		INNER JOIN StudentPredmet sp   
		ON o.PkOsoba=sp.PkOsoba
		INNER JOIN AppDataOsoba a
		ON o.PkAppDataOsoba=a.PkAppDataOsoba
		INNER JOIN Predmet p
		ON sp.PkPredmet=p.PkPredmet
		INNER JOIN Smjer s
		ON p.PkSmjer=s.PkSmjer
		INNER JOIN Semestar sm
		ON p.PkSemestar=sm.PkSemestar  
        WHERE a.PkAppDataOsoba = 1 and
			  sp.Ocjena > 1 and
			  a.StatusAktivnosti = 'DA' and
			  ((s.Studij = 'Strucni' and sm.Semestar = '6. Semestar') or
			  (s.Studij = 'Preddiplomski' and sm.Semestar = '10. Semestar'))
GO
