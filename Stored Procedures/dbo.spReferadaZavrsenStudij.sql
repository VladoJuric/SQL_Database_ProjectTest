SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[spReferadaZavrsenStudij]
as
begin try
set nocount on
begin transaction

declare @danas date
declare @kraj date
select @kraj=DatumKraja from Semestar where Semestar = '10. Semestar'
select @danas = getdate()
	/*
	  - PROCEDURA PROVJERAVA DALI POSTOJE STUDENTI KOJI SU ZAVRSILI STUDIJ TE OBAVJESTAVA REFERADU O TOME I PRIPREMI PROMOCIJE
	    POTREBNO JE POKRENUTI PROCEDURU O PROMOCIJI DA SE STUDENTIMA DODJELE DIPLOME SA ZAVRSNIM OCJENAMA I S TIME JE ZAVRSEN NJIHOV STUDIJ
	*/
if exists (select o.Ime,o.Prezime,sm.Semestar,s.Studij,s.Smjer
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
			INNER JOIN dbo.StudentPredmetZakljucno spz
			ON sp.PkOsoba=spz.PkOsoba AND sp.PkPredmet=spz.PkPredmet
			WHERE a.PkAppDataOsoba = 1 and
				  spz.ZakljucnaOcjena > 1 and 
				  ((s.Studij = 'Strucni' and sm.Semestar = '6. Semestar') or
				  (s.Studij = 'Preddiplomski' and sm.Semestar = '10. Semestar')))
begin
	if (@danas >= @kraj)
	begin
		update Osoba set PkAppDataOsoba = (select PkAppDataOsoba from AppDataOsoba where StatusAktivnosti = 'NE') 
											where PkOsoba in (select o.PkOsoba
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
																INNER JOIN dbo.StudentPredmetZakljucno spz
																ON sp.PkOsoba=spz.PkOsoba AND sp.PkPredmet=spz.PkPredmet
																WHERE a.PkAppDataOsoba = 1 and
																		spz.ZakljucnaOcjena > 1 and 
																		((s.Studij = 'Strucni' and sm.Semestar = '6. Semestar') or
																		(s.Studij = 'Preddiplomski' and sm.Semestar = '10. Semestar')))


		--select o.Ime,o.Prezime,o.Oib,o.GodinaRodenja,sm.Semestar,s.Studij,s.Smjer, 'Cekanje promocije' as StatusStudija
		--	from Osoba o
		--	INNER JOIN StudentPredmet sp   
		--	ON o.PkOsoba=sp.PkOsoba
		--	INNER JOIN AppDataOsoba a
		--	ON o.PkAppDataOsoba=a.PkAppDataOsoba
		--	INNER JOIN Predmet p
		--	ON sp.PkPredmet=p.PkPredmet
		--	INNER JOIN Smjer s
		--	ON p.PkSmjer=s.PkSmjer
		--	INNER JOIN Semestar sm
		--	ON p.PkSemestar=sm.PkSemestar  
		--	WHERE a.PkAppDataOsoba = (select PkAppDataOsoba from AppDataOsoba where StatusAktivnosti = 'NE') and
		--		  sp.Ocjena > 1 and
		--		  ((s.Studij = 'Strucni' and sm.Semestar = '6. Semestar') or
		--		  (s.Studij = 'Preddiplomski' and sm.Semestar = '10. Semestar'))

		SELECT o.Ime,o.Prezime,o.Oib,o.GodinaRodenja,sm.Semestar,s.Studij,s.Smjer, 'Cekanje promocije' as StatusStudija
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
			INNER JOIN dbo.StudentPredmetZakljucno spz
			ON sp.PkOsoba=spz.PkOsoba AND sp.PkPredmet=spz.PkPredmet
			WHERE a.PkAppDataOsoba = 1 and
				  spz.ZakljucnaOcjena > 1 and 
				  ((s.Studij = 'Strucni' and sm.Semestar = '6. Semestar') or
				  (s.Studij = 'Preddiplomski' and sm.Semestar = '10. Semestar'))

	end
	else
		print 'Nazalost datum kraja semestra je dana '+CAST(@kraj as varchar(10))+', te Vas molim da tada pokrenete proceduru'
END
PRINT 'Nema studenata koji uskoro zavrsavaju studij'
end try
begin catch
	execute dbo.GetErrorInfo;
	if @@TRANCOUNT > 0
		rollback transaction;
end catch;
if @@TRANCOUNT > 0
	commit transaction;
GO
