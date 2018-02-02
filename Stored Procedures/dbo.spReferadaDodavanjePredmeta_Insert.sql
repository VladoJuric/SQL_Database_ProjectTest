SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[spReferadaDodavanjePredmeta_Insert] (
	@oib varchar(11),
	@tip_osobe varchar(20),
	@idstudij int,
	@semestar varchar(20),

	@predmet1 varchar(50),
	@predmet2 varchar(50),
	@predmet3 varchar(50),
	@predmet4 varchar(50),
	@predmet5 varchar(50),
	@predmet6 varchar(50))
as
begin try
set nocount on
begin transaction

if (@oib ='') select @oib = null
if (@tip_osobe ='') select @tip_osobe = null
if (@idstudij ='') select @idstudij = null
if (@semestar ='') select @semestar = null

--DEKLARACIJA POTREBNIH VARIJABLI
declare @ime varchar(25)
declare @prezime varchar(25)
declare @pkosoba int
declare @pksmjer int
declare @pksemestar int

--POSTAVLJANJE VRIJENDOSTI PRAZNIH PREDEMTA NA DEFAULT VRIJEDNOST
if (@predmet1 is null or @predmet1 = '') select @predmet1 = 'PRAZNO'
if (@predmet2 is null or @predmet2 = '') select @predmet2 = 'PRAZNO'
if (@predmet3 is null or @predmet3 = '') select @predmet3 = 'PRAZNO'
if (@predmet4 is null or @predmet4 = '') select @predmet4 = 'PRAZNO'
if (@predmet5 is null or @predmet5 = '') select @predmet5 = 'PRAZNO'
if (@predmet6 is null or @predmet6 = '') select @predmet6 = 'PRAZNO'
select upper(@predmet1)
select upper(@predmet2)
select upper(@predmet3)
select upper(@predmet4)
select upper(@predmet5)
select upper(@predmet6)

--PROVJERA UNESENIH PODATAKA
if(len(@tip_osobe) <= 20 and
   len(@oib) = 11 and
   len(@semestar) <= 20 and
   @idstudij > 0 and @idstudij < 1000 and
   
   len(@predmet1) <= 50 and
   len(@predmet2) <= 50 and
   len(@predmet3) <= 50 and
   len(@predmet4) <= 50 and
   len(@predmet5) <= 50 and
   len(@predmet6) <= 50)
begin
	/*
	  - PROCEDURA OMOGUCAVA UNOS DO 6 PREDMETA S POJEDINOG STUDIJA 
	  - PROCEDURA PROVJERAVA DALI SU PODACI ISPRAVNO UNESENI TE UKOLIKO NISU ISPISUJE GRESKU
	  - TAKODER PROVJERAVA DALI POSTOJI TRAZENI PROFESOR ILI ASISTENT U BAZI KOJEM SE MOGU DODJELITI PREDMETI
	  - UKOLIKO JE SVE UREDU KREIRA SE PRIVREMENA TABLICA PREDMETA IZ KOJE SE KASNIJE TI PREDMETI DODJELJUJU PROFESORU
	  - TAKODER MOZE SU UKLJUCITI PROVJERA DALI SU TI PREDMETI VEC DODJELJENI NEKOM PROFESORU (ZA SADA ISKLJUCENO)
	*/
	if exists (select * from dbo.Osoba where Oib=@oib and PkOsobaOpis in (1,2))
	begin
		if (@idstudij in (select IdStudij from Smjer) and upper(@semestar) in (select upper(Semestar) from Semestar))
		begin
			select upper(@tip_osobe)
			select @ime = Ime from Osoba where Oib = @oib and PkOsobaOpis in (1,2)
			select @prezime = Prezime from Osoba where Oib = @oib and PkOsobaOpis in (1,2)
			select @pkosoba = PkOsoba from Osoba where Oib=@oib
			select @pksmjer = PkSmjer from Smjer where IdStudij = @idstudij
			select @pksemestar = PkSemestar from Semestar where Semestar = @semestar

			if (@tip_osobe = 'PROFESOR' or @tip_osobe = 'ASISTENT')
			begin
				--if exists (select * from ProfesorPredmet where PkPredmet = (select PkPredmet from #TmpTable))
				--begin
					create table #TmpTable (PkPredmet int,Predmet varchar(50),PkOsoba int)
					insert into #TmpTable (PkOsoba,PkPredmet,Predmet) select @pkosoba,PkPredmet,Predmet from Predmet where upper(Predmet) in (@predmet1,@predmet2,@predmet3,@predmet4,@predmet5,@predmet6) and PkSemestar = @pksemestar and PkSmjer = @pksmjer

					insert into ProfesorPredmet (PkOsoba,PkPredmet) select PkOsoba,PKpredmet from #TmpTable
					print 'Uneseni su novi predmeti za profesora '+@ime+' '+@prezime
					drop table #TmpTable
				--end
			end
			else
				print 'Unjeli ste '+@tip_osobe+' za tip osobe, molim unesite (profesor ili asistent)'
		end
		else
			print 'Osoba '+@ime+' '+@prezime+' ne postoji u sustavu'
	end
	else
		print 'Pogreska krivi semsestar ili studij'
end
else
	print 'Pogreska ulaznih parametara'
end try
begin catch
	execute dbo.GetErrorInfo;
	if @@TRANCOUNT > 0
		rollback transaction;
end catch;
if @@TRANCOUNT > 0
	commit transaction;
GO
