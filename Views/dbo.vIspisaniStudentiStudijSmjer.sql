SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vIspisaniStudentiStudijSmjer]
AS
SELECT        dbo.Osoba.Ime, dbo.Osoba.Prezime, dbo.Predmet.Predmet, dbo.Smjer.Smjer, dbo.Smjer.Studij, dbo.Semestar.Semestar
FROM            dbo.Osoba INNER JOIN
                         dbo.StudentPredmet ON dbo.Osoba.PkOsoba = dbo.StudentPredmet.PkOsoba INNER JOIN
                         dbo.Predmet ON dbo.StudentPredmet.PkPredmet = dbo.Predmet.PkPredmet INNER JOIN
                         dbo.Smjer ON dbo.Predmet.PkSmjer = dbo.Smjer.PkSmjer INNER JOIN
                         dbo.AppDataOsoba ON dbo.Osoba.PkAppDataOsoba = dbo.AppDataOsoba.PkAppDataOsoba INNER JOIN
                         dbo.OsobaOpis ON dbo.Osoba.PkOsobaOpis = dbo.OsobaOpis.PkOsobaOpis INNER JOIN
                         dbo.Semestar ON dbo.Predmet.PkSemestar = dbo.Semestar.PkSemestar
WHERE        (dbo.OsobaOpis.StatusOsobe = 'Student') AND (dbo.AppDataOsoba.StatusAktivnosti = 'NE')


GO
