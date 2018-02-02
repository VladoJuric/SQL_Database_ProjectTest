SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[spReferadaAzuriranjeStudenta_Update] (
	@stari_oib varchar(25),
	@idstudij int,

	@oib varchar(11),
	@ime varchar(25),
	@prezime varchar(25),
	@godina_rodenja date,
	@datum_upisa date,
	@grad varchar(30),
	@drzava varchar(30),
	@novi_status varchar(2))
as
begin try
set nocount on
begin transaction

--DEKLARACIJA POTREBNIH VARIJABLI
declare @pks int
declare @sm varchar(50)
declare @st varchar(50)

declare @staro_ime varchar(25)
declare @staro_prezime varchar(25)
declare @stara_godina_rodenja date
declare @stari_datum_upisa date
declare @stari_grad varchar(30)
declare @stara_drzava varchar(30)
declare @stari_idstudij int
declare @stari_status varchar(2)

--POSTAVLJANJE STARIH PODATAKA STUDENTA NA OSNOVU OIBA
select @staro_ime = (select Ime from Osoba where oib = @stari_oib)
select @staro_prezime = (select Prezime from Osoba where oib = @stari_oib)
select @stara_godina_rodenja = (select GodinaRodenja from Osoba where oib = @stari_oib)
select @stari_datum_upisa = (select DatumUpisa from Osoba where oib = @stari_oib)
select @stari_grad = (select Grad from Osoba where oib = @stari_oib)
select @stara_drzava = (select Drzava from Osoba where oib = @stari_oib)
select @stari_idstudij = (select distinct IdStudij from Smjer where PkSmjer in (select PkSmjer from Predmet where PkPredmet in (select PkPredmet from StudentPredmet where PkOsoba = (select PkOsoba from Osoba where Oib=@stari_oib))))
select @stari_status =  (select StatusAktivnosti from AppDataOsoba where PkAppDataOsoba = (select PkAppDataOsoba from Osoba where oib = @stari_oib))

select @novi_status=upper(@novi_status)
		
--POSTAVLJANJE STARIH PODATAKA U NOVE TJ ONE KOJI SE NE TREBAJU AZURIRAT VRACAJU SE NA STARE VRIJEDNOSTI
if (@oib is null or @oib = '') select @oib=@stari_oib
if (@ime is null or @ime = '') select @ime=@staro_ime
if (@prezime is null or @prezime = '') select @prezime=@staro_prezime
if (@godina_rodenja is null or @godina_rodenja = '') select @godina_rodenja=@stara_godina_rodenja
if (@datum_upisa is null or @datum_upisa = '') select @datum_upisa=@stari_datum_upisa
if (@grad is null or @grad = '') select @grad=@stari_grad
if (@drzava is null or @drzava = '') select @drzava=@stara_drzava
if (@idstudij is null or @idstudij = '') select @idstudij=@stari_idstudij
if (@novi_status is null or @novi_status = '') select @novi_status=@stari_status

--PROVJERA UNESENIH PODATAKA
if(len(@stari_oib) = 11 and

   len(@oib) = 11 and
   len(@ime) <= 25 and
   len(@prezime) <= 25 and
   len(@grad) <= 30 and
   len(@drzava) <= 30 and
   isdate(cast(@godina_rodenja as varchar(10))) = 1 and
   isdate(cast(@datum_upisa as varchar(10))) = 1 and
   isnumeric(@ime) <= 0 and
   isnumeric(@prezime) <= 0 and
   @idstudij > 0 and @idstudij < 1000)
begin
	/*
	  - PROCEDURA PROVJERAVA DALI STUDENT VEC POSTOJI U TABLICAMA TE UKOLIKO POSTOJI RADI POTREBNU IZMJENU PODATAKA
	  - UKOLIKO STUDENT NE POSTOJI DODE DO POGRESKE I ISPISUJE SE GRESKA
		TAKODER SE PROVJERAVA UNOS ULAZNIH PARAMETARA TE SE ISPISUJE GRESKA UKOLIKO PARAMETRI NISU VALJANO UNESENI
	  - UKOLIKO DODE DO NEKE NE NAVEDENE GRESKE TAKODER ISPISUJE O KOJOJ SE GRESCI RADI I RADI ROLLBACK TRANSAKCIJE
	  - PROCEDURA OMOGUCUJE ISPIS I UPIS STUDENTA NA NOVI SMJER S TIME DA BRISE SVE STARE PREDMETE I UNOSI NOVE PREDMET
	  - UKOLIKO JE SVE UREDU STUDENT AZURIRAN
	*/
	if exists (select * from dbo.Osoba where Ime=@staro_ime and Prezime=@staro_prezime and Oib=@stari_oib and GodinaRodenja=@stara_godina_rodenja and PkAppDataOsoba=1 and PkOsobaOpis = 3)
	begin

		--PROMJENA STATUSA STUDENTA
		if (@novi_status <> @stari_status)
		begin
			update Osoba set PkAppDataOsoba=(select PkAppDataOsoba from AppDataOsoba where upper(StatusAktivnosti)=upper(@novi_status)) where Oib=@stari_oib and PkAppDataOsoba = (select PkAppDataOsoba from AppDataOsoba where upper(StatusAktivnosti)=upper(@stari_status)) and PkOsobaOpis in (3)
			print 'Status studenta '+@staro_ime+' '+@staro_prezime+' je promjenjen na '+@novi_status
		end

		--PROMJENA STUDIJA STUDENTA SKUPA S SVIM PREDMETIMA TOG STUDIJA I DATUM UPISA SE POSTAVLJA NA DATUM IZMJENE PODATAKA
		if (@stari_idstudij <> @idstudij)
		begin
			if exists (select * from Smjer where IdStudij=@idstudij)
			begin
				--BRISE PODATKE O STUDENTU I SPREMA IH U STUDENTPREDMETLOG TABLICU
				delete from StudentPredmet where PkOsoba=(select PkOsoba from Osoba where Ime=@staro_ime and Prezime=@staro_prezime and Oib=@stari_oib and GodinaRodenja=@stara_godina_rodenja)

				select @pks = (select PkOsoba from Osoba where Ime=@ime and Prezime=@prezime and Oib=@oib and GodinaRodenja=@godina_rodenja and Grad=@grad and Drzava=@drzava)
				
				--create table #TmpTable (PkPredmet int)
				--insert into #TmpTable (PkPredmet) select PkPredmet from Predmet where PkSemestar=1 and PkSmjer=(select PkSmjer from Smjer where IdStudij=@idstudij)

				--select @min=min(PkPredmet) from #TmpTable
				--select @max=max(PkPredmet) from #TmpTable

				--while(@min <= @max)
				--begin
				--	if (@min in (select PkPredmet from #TmpTable))
				--	begin
				--		insert into StudentPredmet (PkOsoba,PkPredmet) 
				--		values ((select PkOsoba from Osoba where Ime=@ime and Prezime=@prezime and Oib=@oib and GodinaRodenja=@godina_rodenja and Grad=@grad and Drzava=@drzava),@min)
				--	end
				--	select @min=@min+1
				--end
				
				--drop table #TmpTable
				--ZAMJENA ZA KOD POVISE INSERT FROM SELECT			
				insert into StudentPredmet (PkOsoba,PkPredmet) select @pks as PkOsoba, PkPredmet from Predmet where PkSemestar=1 and PkSmjer=(select PkSmjer from Smjer where IdStudij=@idstudij)

				update Osoba set DatumUpisa=@datum_upisa where Oib=@oib
				print 'Student '+@ime+' '+@prezime+' je izbrisan sa studija '+cast(@stari_idstudij as varchar(4))+', te upisan na novi studij '+cast(@idstudij as varchar(4))
			end
			else
			begin
				select @sm = Smjer from Smjer where IdStudij=@idstudij
				select @st = Studij from Smjer where IdStudij=@idstudij

				print 'Pogreska smjer '+@sm+' i '+@st+' ne postoje u sustavu'
			end
		end

		--AZURIRANJE OSTALIH PODATAKA STUDENTA KOJI SE NE ODNOSE NA PROMJENU STUDIJA ILI STATUSA
		if (@ime <> @staro_ime or @prezime <> @staro_prezime or @oib <> @stari_oib or @godina_rodenja <> @stara_godina_rodenja or @datum_upisa <> @stari_datum_upisa or @grad <> @stari_grad or @drzava <> @stara_drzava)
		begin
			update Osoba set Ime=@ime, Prezime=@prezime, Oib=@oib, GodinaRodenja=@godina_rodenja, DatumUpisa=@datum_upisa, Grad=@grad, Drzava=@drzava where Oib=@stari_oib and PkOsobaOpis in (3)
			print 'Podaci su azurirani'
		end
	end
	else
		print 'Pogreska student '+@staro_ime+' '+@staro_prezime+' ne postoji u sustavu'
end
else
	print 'Pogreska ulaznih parametara, student s oibom '+@stari_oib+' ne postoji u sustavu'
end try
begin catch
	execute dbo.GetErrorInfo;
	if @@TRANCOUNT > 0
		rollback transaction;
end catch;
if @@TRANCOUNT > 0
	commit transaction;
GO
