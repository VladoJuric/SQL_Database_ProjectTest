SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spProvjeraAktivnosti_Combo]
as
begin try
set nocount on
begin transaction
	
declare @danas date
declare @ime varchar(25)
declare @prezime varchar(25)
declare @do date

	select @danas=getdate()

	--create table #Tmp_table (PkOsobaFunkcija int, PkAppDataFunkcija int, PkOsoba int, PkAppDataTipUgovora int, VrijediOd date, VrijediDo date, StatusFunkcije varchar(10))
	--insert into #Tmp_table select PkOsobaFunkcija, PkAppDataFunkcija, PkOsoba, PkAppDataTipUgovora, VrijediOd, VrijediDo, StatusFunkcije from OsobaFunkcija
	
	if exists (select * from OsobaFunkcija where PkAppDataFunkcija in (1) and VrijediDo <= @danas and StatusFunkcije='Aktivno')
	begin
		select @do=(select VrijediDo from OsobaFunkcija where PkAppDataFunkcija in (1) and VrijediDo <= @danas and StatusFunkcije='Aktivno')

		update OsobaFunkcija set StatusFunkcije = 'Neaktivno' where PkAppDataFunkcija=1 and VrijediDo <= @danas and StatusFunkcije='Aktivno'

		delete OsobaFunkcija where PkAppDataFunkcija=1 and VrijediDo=@do and StatusFunkcije='Neaktivno'

		select @ime=(select Ime from Osoba where PkOsoba=(select PkOsoba from OsobaFunkcija where PkAppDataFunkcija=1 and VrijediDo <= @danas and StatusFunkcije='Aktivno'))
		select @prezime=(select Prezime from Osoba where PkOsoba=(select PkOsoba from OsobaFunkcija where PkAppDataFunkcija=1 and VrijediDo <= @danas and StatusFunkcije='Aktivno'))
		print 'Dekan '+@ime+' '+@prezime+' vise ne obnasa duznost dekana'

		if exists (select * from OsobaFunkcija where PkAppDataFunkcija in (1) and VrijediOd >= @do and StatusFunkcije='Neaktivno')
		begin
			update OsobaFunkcija set StatusFunkcije = 'Aktivno' where PkAppDataFunkcija=1 and VrijediOd >= @do and StatusFunkcije='Neaktivno'

			select @ime=(select Ime from Osoba where PkOsoba=(select PkOsoba from OsobaFunkcija where PkAppDataFunkcija=1 and VrijediOd >= @do and StatusFunkcije='Aktivno'))
			select @prezime=(select Prezime from Osoba where PkOsoba=(select PkOsoba from OsobaFunkcija where PkAppDataFunkcija=1 and VrijediOd >= @do and StatusFunkcije='Aktivno')) 

			print 'Novi Dekan je '+@ime+' '+@prezime
		end
		else
			print 'U sustavu ne postoji novi dekan stoga nijedan nije imenovan, molim pokrenite proceduru spUpisNoveOsobe Dekan'
	end
	else
		print 'Ne postoji Dekan kojem je istekao ugovor'

	if exists (select * from OsobaFunkcija where PkAppDataFunkcija in (2) and VrijediDo <= @danas and StatusFunkcije='Aktivno')
	begin
		select @do=(select VrijediDo from OsobaFunkcija where PkAppDataFunkcija in (2) and VrijediDo <= @danas and StatusFunkcije='Aktivno')

		update OsobaFunkcija set StatusFunkcije = 'Neaktivno' where PkAppDataFunkcija=2 and VrijediDo <= @danas and StatusFunkcije='Aktivno'

		delete OsobaFunkcija where PkAppDataFunkcija=2 and VrijediDo=@do and StatusFunkcije='Neaktivno'

		select @ime=(select Ime from Osoba where PkOsoba=(select PkOsoba from OsobaFunkcija where PkAppDataFunkcija=2 and VrijediDo <= @danas and StatusFunkcije='Aktivno'))
		select @prezime=(select Prezime from Osoba where PkOsoba=(select PkOsoba from OsobaFunkcija where PkAppDataFunkcija=2 and VrijediDo <= @danas and StatusFunkcije='Aktivno'))
		print 'Prodekan '+@ime+' '+@prezime+' vise ne obnasa duznost dekana'

		if exists (select * from OsobaFunkcija where PkAppDataFunkcija in (2) and VrijediOd >= @do and StatusFunkcije='Neaktivno')
		begin
			update OsobaFunkcija set StatusFunkcije = 'Aktivno' where PkAppDataFunkcija=2 and VrijediOd >= @do and StatusFunkcije='Neaktivno'

			select @ime=(select Ime from Osoba where PkOsoba=(select PkOsoba from OsobaFunkcija where PkAppDataFunkcija=2 and VrijediOd >= @do and StatusFunkcije='Aktivno'))
			select @prezime=(select Prezime from Osoba where PkOsoba=(select PkOsoba from OsobaFunkcija where PkAppDataFunkcija=2 and VrijediOd >= @do and StatusFunkcije='Aktivno')) 

			print 'Novi Prodekan je '+@ime+' '+@prezime
		end
		else
			print 'U sustavu ne postoji novi prodekan stoga nijedan nije imenovan, molim pokrenite proceduru spUpisNoveOsobe Prodekan'
	end
	else
		print 'Ne postoji Prodekan kojem je istekao ugovor'

	if exists (select * from OsobaFunkcija where PkAppDataFunkcija in (3) AND VrijediDo <= @danas and StatusFunkcije='Aktivno' and PkAppDataFunkcija=3)
	BEGIN
		update OsobaFunkcija set StatusFunkcije='Neaktivno' where VrijediDo <= @danas and StatusFunkcije='Aktivno' and PkAppDataFunkcija=3

		CREATE TABLE #tmp (PkOsoba int)
		INSERT INTO #tmp SELECT PkOsoba FROM dbo.OsobaFunkcija where VrijediDo <= @danas and StatusFunkcije='Aktivno' and PkAppDataFunkcija=3

		delete OsobaFunkcija where VrijediDo <= @danas and StatusFunkcije='Neaktivno' and PkAppDataFunkcija=3

		UPDATE Osoba SET PkAppDataOsoba=2 WHERE PkOsoba IN (SELECT PkOsoba FROM #tmp)

		DROP TABLE #tmp
		print 'Osobe kojima je istekao ugovor vise nisu u radnom odnosu s Fakultetom'
	end
	else
		print 'Ne postoji Ostali djelatnici kojima je istekao ugovor'

	if exists (select * from OsobaFunkcija where PkAppDataFunkcija in (3) AND StatusFunkcije='Neaktivno' and PkAppDataFunkcija=3)
	BEGIN
		CREATE TABLE #tmp1 (PkOsoba int)
		INSERT INTO #tmp1 SELECT PkOsoba FROM dbo.OsobaFunkcija WHERE StatusFunkcije='Neaktivno' and PkAppDataFunkcija=3

		delete OsobaFunkcija where StatusFunkcije='Neaktivno' and PkAppDataFunkcija=3

		UPDATE Osoba SET PkAppDataOsoba=2 WHERE PkOsoba IN (SELECT PkOsoba FROM #tmp1)

		DROP TABLE #tmp1
		print 'Osobe kojima je istekao ugovor vise nisu u radnom odnosu s Fakultetom'
	end
	else
		print 'Ne postoji Ostali djelatnici kojima je status Neaktivno'

end try
begin catch
	execute dbo.GetErrorInfo;
	if @@TRANCOUNT > 0
		rollback transaction;
end catch;
if @@TRANCOUNT > 0
	commit transaction;
GO
