SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[spReferadaAzuriranjeOstalih_Update] (
	@stari_oib varchar(25),
	@funkcija_osobe varchar(20),

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
declare @staro_ime varchar(25)
declare @staro_prezime varchar(25)
declare @stara_godina_rodenja date
declare @stari_datum_upisa date
declare @stari_grad varchar(30)
declare @stara_drzava varchar(30)
declare @stari_status varchar(2)

--POSTAVLJANJE STARIH PODATAKA STUDENTA NA OSNOVU OIBA
select @staro_ime = (select Ime from Osoba where oib = @stari_oib)
select @staro_prezime = (select Prezime from Osoba where oib = @stari_oib)
select @stara_godina_rodenja = (select GodinaRodenja from Osoba where oib = @stari_oib)
select @stari_datum_upisa = (select DatumUpisa from Osoba where oib = @stari_oib)
select @stari_grad = (select Grad from Osoba where oib = @stari_oib)
select @stara_drzava = (select Drzava from Osoba where oib = @stari_oib)
select @stari_status =  (select StatusAktivnosti from AppDataOsoba where PkAppDataOsoba = (select PkAppDataOsoba from Osoba where oib = @stari_oib))

select @novi_status=upper(@novi_status)
select @funkcija_osobe=upper(@funkcija_osobe)
		
--POSTAVLJANJE STARIH PODATAKA U NOVE TJ ONE KOJI SE NE TREBAJU AZURIRAT VRACAJU SE NA STARE VRIJEDNOSTI
if (@oib is null or @oib = '') select @oib=@stari_oib
if (@ime is null or @ime = '') select @ime=@staro_ime
if (@prezime is null or @prezime = '') select @prezime=@staro_prezime
if (@godina_rodenja is null or @godina_rodenja = '') select @godina_rodenja=@stara_godina_rodenja
if (@datum_upisa is null or @datum_upisa = '') select @datum_upisa=@stari_datum_upisa
if (@grad is null or @grad = '') select @grad=@stari_grad
if (@drzava is null or @drzava = '') select @drzava=@stara_drzava
if (@novi_status is null or @novi_status = '') select @novi_status=@stari_status

--PROVJERA UNESENIH PODATAKA
if(len(@stari_oib) = 11 and
   len(@funkcija_osobe) <= 20 and
   len(@oib) = 11 and
   len(@ime) <= 25 and
   len(@prezime) <= 25 and
   len(@grad) <= 30 and
   len(@drzava) <= 30 and
   isdate(cast(@godina_rodenja as varchar(10))) = 1 and
   isdate(cast(@datum_upisa as varchar(10))) = 1 and
   isnumeric(@ime) <= 0 and
   isnumeric(@prezime) <= 0)
begin
	/*
	  - PROCEDURA PROVJERAVA DALI STUDENT VEC POSTOJI U TABLICAMA TE UKOLIKO POSTOJI RADI POTREBNU IZMJENU PODATAKA
	  - UKOLIKO STUDENT NE POSTOJI DODE DO POGRESKE I ISPISUJE SE GRESKA
		TAKODER SE PROVJERAVA UNOS ULAZNIH PARAMETARA TE SE ISPISUJE GRESKA UKOLIKO PARAMETRI NISU VALJANO UNESENI
	  - UKOLIKO DODE DO NEKE NE NAVEDENE GRESKE TAKODER ISPISUJE O KOJOJ SE GRESCI RADI I RADI ROLLBACK TRANSAKCIJE
	  - UKOLIKO JE SVE UREDU STUDENT AZURIRAN
	*/
	if exists (select * from dbo.Osoba where Ime=@staro_ime and Prezime=@staro_prezime and Oib=@stari_oib and GodinaRodenja=@stara_godina_rodenja and PkAppDataOsoba=1 and PkOsobaOpis in (4) and PkOsoba=(select PkOsoba from OsobaFunkcija where PkAppDataFunkcija=(select PkAppDataFunkcija from AppDataFunkcija where upper(VrstaFunkcije) in (@funkcija_osobe))))
	begin

		--PROMJENA STATUSA OSOBE
		if (upper(@novi_status) <> upper(@stari_status))
		begin
			update Osoba set PkAppDataOsoba=(select PkAppDataOsoba from AppDataOsoba where upper(StatusAktivnosti)=@novi_status) where Oib=@stari_oib and PkAppDataOsoba = (select PkAppDataOsoba from AppDataOsoba where upper(StatusAktivnosti)=upper(@stari_status)) and PkOsobaOpis = 4 and PkOsoba=(select PkOsoba from OsobaFunkcija where PkAppDataFunkcija=(select PkAppDataFunkcija from AppDataFunkcija where upper(VrstaFunkcije) in (@funkcija_osobe)))
			print 'Status '+lower(@funkcija_osobe)+', '+@staro_ime+' '+@staro_prezime+' je promjenjen na '+@novi_status
		end

		--AZURIRANJE OSTALIH PODATAKA OSOBE KOJI SE NE ODNOSE NA PROMJENU STATUSA
		if (@ime <> @staro_ime or @prezime <> @staro_prezime or @oib <> @stari_oib or @godina_rodenja <> @stara_godina_rodenja or @datum_upisa <> @stari_datum_upisa or @grad <> @stari_grad or @drzava <> @stara_drzava)
		begin
			update Osoba set Ime=@ime, Prezime=@prezime, Oib=@oib, GodinaRodenja=@godina_rodenja, DatumUpisa=@datum_upisa, Grad=@grad, Drzava=@drzava where Oib=@stari_oib and PkOsobaOpis = 4 and PkOsoba=(select PkOsoba from OsobaFunkcija where PkAppDataFunkcija=(select PkAppDataFunkcija from AppDataFunkcija where upper(VrstaFunkcije) in (@funkcija_osobe)))
						print 'Podaci osobe '+@ime+' '+@prezime+' su azurirani'
		end
	end
	else
		print 'Pogreska osoba (funkcije dekan, prodekan, ostali djelatnici) '+@staro_ime+' '+@staro_prezime+' ne postoji u sustavu'
end
else
	print 'Pogreska ulaznih parametara, osoba (funkcije dekan, prodekan, ostali djelatnici) s oibom '+@stari_oib+' ne postoji u sustavu'
end try
begin catch
	execute dbo.GetErrorInfo;
	if @@TRANCOUNT > 0
		rollback transaction;
end catch;
if @@TRANCOUNT > 0
	commit transaction;
GO
