SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[spDanPromocija_Combo]
as
begin try
set nocount on
begin transaction

--DEKLARACIJA POTREBNIH VARIJABLI
declare @danas date
declare @promocija date
declare @min int
declare @max int
select @danas = getdate()
select @promocija=ri.DatumIspita from RedIspita ri, AppDataIspit ti where ri.PkAppDataIspit = (select PkAppDataIspit from AppDataIspit where TipIspit = 'Promocija')
	/*
	  - PROCEDURA PROVJERAVA DALI POSTOJE STUDENTI KOJI SU ZAVRSILI STUDIJ A DA IM NIJE PROMJENJEN STATUS NA DAN PROMOCIJE
	    , UKOLIKO POSTOJE MJENJA NJIHOV STATUS U NEAKTIVAN I S TIME JE ZAVRSEN NJIHOV STUDIJ NARAVNO UZ PROVJERU DANA PROMOCIJE
	  - TAKODER SE POSTAVLJA ZAVRSNA OCJENA SVAKOG STUDENTA OVISNO O PROSJEKU SVIH NJEGOVIH PREDMETA
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
			WHERE a.PkAppDataOsoba = 2 and
				  sp.Ocjena > 1 and 
				  ((s.Studij = 'Strucni' and sm.Semestar = '6. Semestar') or
				  (s.Studij = 'Preddiplomski' and sm.Semestar = '10. Semestar')))
begin
	if (@danas >= @promocija)
	begin
	
		--select @min = min(PkOsoba) from vZavrsnaOcjenaStudenata where PkOsoba in (select o.PkOsoba from Osoba o
		--															INNER JOIN StudentPredmet sp   
		--															ON o.PkOsoba=sp.PkOsoba
		--															INNER JOIN AppDataOsoba a
		--															ON o.PkAppDataOsoba=a.PkAppDataOsoba
		--															INNER JOIN Predmet p
		--															ON sp.PkPredmet=p.PkPredmet
		--															INNER JOIN Smjer s
		--															ON p.PkSmjer=s.PkSmjer
		--															INNER JOIN Semestar sm
		--															ON p.PkSemestar=sm.PkSemestar  
		--															WHERE a.PkAppDataOsoba = 'NE' and
		--																  sp.Ocjena > 1 and 
		--																  ((s.Studij = 'Strucni' and sm.Semestar = '6. Semestar') or
		--																  (s.Studij = 'Preddiplomski' and sm.Semestar = '10. Semestar')))
		--select @max = max(PkOsoba) from vZavrsnaOcjenaStudenata where PkOsoba in (select o.PkOsoba from Osoba o
		--															INNER JOIN StudentPredmet sp   
		--															ON o.PkOsoba=sp.PkOsoba
		--															INNER JOIN AppDataOsoba a
		--															ON o.PkAppDataOsoba=a.PkAppDataOsoba
		--															INNER JOIN Predmet p
		--															ON sp.PkPredmet=p.PkPredmet
		--															INNER JOIN Smjer s
		--															ON p.PkSmjer=s.PkSmjer
		--															INNER JOIN Semestar sm
		--															ON p.PkSemestar=sm.PkSemestar  
		--															WHERE a.PkAppDataOsoba = 'NE' and
		--																  sp.Ocjena > 1 and 
		--																  ((s.Studij = 'Strucni' and sm.Semestar = '6. Semestar') or
		--																  (s.Studij = 'Preddiplomski' and sm.Semestar = '10. Semestar')))

		--while (@min <= @max)
		--begin
		--	update Osoba set ZavrsnaOcjena=(select zakljucna_ocjena from vZavrsnaOcjenaStudenata where PkOsoba=@min and PkOsoba in (select o.PkOsoba from Osoba o
		--															INNER JOIN StudentPredmet sp   
		--															ON o.PkOsoba=sp.PkOsoba
		--															INNER JOIN AppDataOsoba a
		--															ON o.PkAppDataOsoba=a.PkAppDataOsoba
		--															INNER JOIN Predmet p
		--															ON sp.PkPredmet=p.PkPredmet
		--															INNER JOIN Smjer s
		--															ON p.PkSmjer=s.PkSmjer
		--															INNER JOIN Semestar sm
		--															ON p.PkSemestar=sm.PkSemestar  
		--															WHERE a.PkAppDataOsoba = 'NE' and
		--																  sp.Ocjena > 1 and 
		--																  ((s.Studij = 'Strucni' and sm.Semestar = '6. Semestar') or
		--																  (s.Studij = 'Preddiplomski' and sm.Semestar = '10. Semestar')))) 
		--						where PkOsoba=@min and PkOsoba in (select o.PkOsoba from Osoba o
		--															INNER JOIN StudentPredmet sp   
		--															ON o.PkOsoba=sp.PkOsoba
		--															INNER JOIN AppDataOsoba a
		--															ON o.PkAppDataOsoba=a.PkAppDataOsoba
		--															INNER JOIN Predmet p
		--															ON sp.PkPredmet=p.PkPredmet
		--															INNER JOIN Smjer s
		--															ON p.PkSmjer=s.PkSmjer
		--															INNER JOIN Semestar sm
		--															ON p.PkSemestar=sm.PkSemestar  
		--															WHERE a.PkAppDataOsoba = 'NE' and
		--																  sp.Ocjena > 1 and 
		--																  ((s.Studij = 'Strucni' and sm.Semestar = '6. Semestar') or
		--																  (s.Studij = 'Preddiplomski' and sm.Semestar = '10. Semestar')))

		--	select @min=@min+1
		--end

		--ZAMJNENJEN UPIT S UPDATE FROM SELECT

		IF EXISTS (SELECT * FROM dbo.vZavrsnaOcjenaStudenata WHERE ZakljucnaOcjena  > 1 AND StatusAktivnosti = 'NE')
		begin
			update o
			set o.ZavrsnaOcjena = zs.ZakljucnaOcjena
			from Osoba o, vZavrsnaOcjenaStudenata zs  
			where o.PkOsoba = zs.PkOsoba and zs.ZakljucnaOcjena > 1 and zs.StatusAktivnosti = 'NE'

			select o.Ime,o.Prezime,o.Oib,o.GodinaRodenja,sm.Semestar,s.Studij,s.Smjer, 'Zavrsen studij' as StatusStudija from Osoba o
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
																			WHERE a.PkAppDataOsoba = (select PkAppDataOsoba from AppDataOsoba where StatusAktivnosti = 'NE') and
																				  sp.Ocjena > 1 and 
																				  ((s.Studij = 'Strucni' and sm.Semestar = '6. Semestar') or
																				  (s.Studij = 'Preddiplomski' and sm.Semestar = '10. Semestar'))
		
			--BRISE STUDENTE IZ LISTE OSOBA I SPREMA IH U STUDENT LOG LISTU

			delete from Osoba where PkAppDataOsoba = (select PkAppDataOsoba from AppDataOsoba where StatusAktivnosti = 'NE' ) and ZavrsnaOcjena > 1
		END

		
	end
	else
		print 'Nazalost datum promocije je dana '+CAST(@promocija as varchar(10))+', te Vas molim da tada pokrenete proceduru'
end
else
	print 'Nema studenata koji cekaju promociju'
end try
begin catch
	execute dbo.GetErrorInfo;
	if @@TRANCOUNT > 0
		rollback transaction;
end catch;
if @@TRANCOUNT > 0
	commit transaction;
GO
