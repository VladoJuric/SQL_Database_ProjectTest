SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[spReferadaUpisNoveOsobe_Insert] (
	@tip_osobe varchar(20),
	@funkcija_osobe varchar(20), --NOVA FUNKCIJA
	@datum_pocetka varchar(20), --NOVA FUNKCIJA

	@oib varchar(11),
	@ime varchar(25),
	@prezime varchar(25),
	@godina_rodenja date,
	@datum_upisa date,
	@grad varchar(30),
	@drzava varchar(30),
	@idstudij int)
as
begin try
set nocount on
begin transaction

--DEKLARACIJA POTREBNIH VARIJABLI
declare @sm varchar(50)
declare @st varchar(50)
declare @status varchar(20)
declare @info varchar(20)
declare @trajanje int
declare @datum_kraja date

--POSTAVLJANJE VARIJABLI NA VRIJEDNOSTI UKOLIKO NISU UNESENE
if (@datum_upisa is null or @datum_upisa = '') select @datum_upisa = getdate()
if (upper(@tip_osobe) = 'STUDENT') begin select @idstudij = @idstudij end else select @idstudij = null

if (@funkcija_osobe ='') select @funkcija_osobe = null
if (@datum_pocetka ='') select @datum_pocetka = null
if (@tip_osobe ='') select @tip_osobe = null
if (@oib ='') select @oib = null
if (@ime ='') select @ime = null
if (@prezime ='') select @prezime = null
if (@godina_rodenja ='') select @godina_rodenja = null
if (@grad ='') select @grad = null
if (@drzava ='') select @drzava = null
if (@idstudij = '') select @idstudij = null

--PROVJERA UNESENIH PODATAKA
if(len(@tip_osobe) <= 20 and
   len(@oib) = 11 and
   len(@ime) <= 25 and
   len(@prezime) <= 25 and
   len(@grad) <= 30 and
   len(@drzava) <= 30 and
   len(@funkcija_osobe) <= 20 and
   isdate(cast(@godina_rodenja as varchar(10))) = 1 and
   isdate(cast(@datum_upisa as varchar(10))) = 1 and
   isdate(cast(@datum_pocetka as varchar(10))) = 1 and
   isnumeric(@ime) <= 0 and
   isnumeric(@prezime) <= 0)
begin
	/*
	  - PROCEDURA PROVJERAVA DALI OSOBA VEC POSTOJI U TABLICAMA TE UKOLIKO POSTOJI ISPISUJE GRESKU O POSTOJANJU TE OSOBE
	  - PROCEDURA UNOSI PODATKE NOVE OSOBE U SUSTAV I AZURIRA STARE PODATKE U SLUCAJU DEKANA ILI PRODEKANA
	    TAKODER SE PROVJERAVA UNOS ULAZNIH PARAMETARA TE SE ISPISUJE GRESKA UKOLIKO PARAMETRI NISU VALJANO UNESENI
	  - PRILIKOM UNOSA OSOBE TIPA STUDENT, PROFESOR ILI ASISTENT POZIVAJU SE POTREBNE PROCEDURE ZA TO 
	  - UKOLIKO DODE DO NEKE NE NAVEDENE GRESKE TAKODER ISPISUJE O KOJOJ SE GRESCI RADI
	  - UKOLOIKO SE NE UNESE PARAMETAR DATUM UPISA UZIMA SE SISTEMSKO VRIJEME
	  - UKOLIKO JE SVE UREDU NOVA OSOBA JE UNESENA U SUSTAV
	*/
	select @tip_osobe=upper(@tip_osobe)
	SELECT @funkcija_osobe=upper(@funkcija_osobe)

	if not exists (select * from dbo.Osoba where Ime=@ime and Prezime=@prezime and Oib=@oib and GodinaRodenja=@godina_rodenja and Grad=@grad and Drzava=@drzava and PkOsobaOpis in (select PkOsobaOpis from OsobaOpis where upper(StatusOsobe) = upper(@tip_osobe)))
	begin
		if (@tip_osobe = 'OSTALI' and (@funkcija_osobe = 'DEKAN' or @funkcija_osobe = 'PRODEKAN' or @funkcija_osobe = 'OSTALI DJELATNICI'))
		begin
			
			insert into Osoba (PkOsobaOpis,PkAppDataOsoba,Oib,Ime,Prezime,GodinaRodenja,DatumUpisa,Grad,Drzava)
			values (4,1,@oib,@ime,@prezime,@godina_rodenja,@datum_upisa,@grad,@drzava)

			if (@funkcija_osobe = 'DEKAN')
			begin
				if not exists (select * from OsobaFunkcija where PkAppDataFunkcija = 1 and StatusFunkcije = 'Aktivno')
				begin
					--insert into Osoba (PkOsobaOpis,PkAppDataOsoba,Oib,Ime,Prezime,GodinaRodenja,DatumUpisa,Grad,Drzava)
					--values (4,1,@oib,@ime,@prezime,@godina_rodenja,@datum_upisa,@grad,@drzava)

					if (@datum_pocetka < getdate())
						select @status = 'Aktivno'
					else
						select @status = 'Neaktivno'

					select @info=(select TrajanjeUgovora from AppDataTipUgovora where TipUgovora='Mandatski')
					select @trajanje=substring(@info, patindex('%[0-9]%', @info), patindex('%[0-9][^0-9]%', @info + 't') - patindex('%[0-9]%', @info) + 1)
					select @datum_kraja=@datum_pocetka
					select @datum_kraja=dateadd(month, @trajanje, @datum_kraja)

					insert into OsobaFunkcija (PkAppDataFunkcija,PkOsoba,PKappDataTipUgovora,VrijediOd,VrijediDo,StatusFunkcije)
					values ((select PkAppDataFunkcija from AppDataFunkcija where OpisFunkcije = 'Dekan'),
							(select PkOsoba from Osoba where Oib=@oib and PkOsobaOpis = 4 and PkAppDataOsoba = 1),
							(select PKappDataTipUgovora from AppDataTipUgovora where TipUgovora = 'Mandatski'),
							@datum_pocetka,
							@datum_kraja,
							@status)
					print 'Novi Dekan '+@ime+' '+@prezime+' je u sustavu i ugovor mu traje od '+cast(@datum_pocetka as varchar(10))+' do '+cast(@datum_kraja as varchar(10))
				end
				else
				begin
					--insert into Osoba (PkOsobaOpis,PkAppDataOsoba,Oib,Ime,Prezime,GodinaRodenja,DatumUpisa,Grad,Drzava)
					--values (4,1,@oib,@ime,@prezime,@godina_rodenja,@datum_upisa,@grad,@drzava)

					select @datum_pocetka=(select VrijediDo from OsobaFunkcija where PkAppDataFunkcija=1 and StatusFunkcije='Aktivno')

					if (@datum_pocetka < getdate())
						select @status = 'Aktivno'
					else
						select @status = 'Neaktivno'

					select @info=(select TrajanjeUgovora from AppDataTipUgovora where TipUgovora='Mandatski')
					select @trajanje=substring(@info, patindex('%[0-9]%', @info), patindex('%[0-9][^0-9]%', @info + 't') - patindex('%[0-9]%', @info) + 1)
					select @datum_kraja=@datum_pocetka
					select @datum_kraja=dateadd(month, @trajanje, @datum_kraja)

					insert into OsobaFunkcija (PkAppDataFunkcija,PkOsoba,PKappDataTipUgovora,VrijediOd,VrijediDo,StatusFunkcije)
					values ((select PkAppDataFunkcija from AppDataFunkcija where OpisFunkcije = 'Dekan'),
							(select PkOsoba from Osoba where Oib=@oib and PkOsobaOpis = 4 and PkAppDataOsoba = 1),
							(select PKappDataTipUgovora from AppDataTipUgovora where TipUgovora = 'Mandatski'),
							@datum_pocetka,
							@datum_kraja,
							@status)
					print 'Novi Dekan '+@ime+' '+@prezime+' je u sustavu i ugovor mu pocima trajati od '+cast(@datum_pocetka as varchar(10))+' do '+cast(@datum_kraja as varchar(10))
				end
			end
			if (@funkcija_osobe = 'PRODEKAN')
			begin
				if not exists (select * from OsobaFunkcija where PkAppDataFunkcija = 2 and StatusFunkcije = 'Aktivno')
				begin
					--insert into Osoba (PkOsobaOpis,PkAppDataOsoba,Oib,Ime,Prezime,GodinaRodenja,DatumUpisa,Grad,Drzava)
					--values (4,1,@oib,@ime,@prezime,@godina_rodenja,@datum_upisa,@grad,@drzava)

					if (@datum_pocetka < getdate())
						select @status = 'Aktivno'
					else
						select @status = 'Neaktivno'

					select @info=(select TrajanjeUgovora from AppDataTipUgovora where TipUgovora='Mandatski')
					select @trajanje=substring(@info, patindex('%[0-9]%', @info), patindex('%[0-9][^0-9]%', @info + 't') - patindex('%[0-9]%', @info) + 1)
					select @datum_kraja=@datum_pocetka
					select @datum_kraja=dateadd(month, @trajanje, @datum_kraja)

					insert into OsobaFunkcija (PkAppDataFunkcija,PkOsoba,PKappDataTipUgovora,VrijediOd,VrijediDo,StatusFunkcije)
					values ((select PkAppDataFunkcija from AppDataFunkcija where OpisFunkcije = 'Prodekan'),
							(select PkOsoba from Osoba where Oib=@oib and PkOsobaOpis = 4 and PkAppDataOsoba = 1),
							(select PKappDataTipUgovora from AppDataTipUgovora where TipUgovora = 'Mandatski'),
							@datum_pocetka,
							@datum_kraja,
							@status)
					print 'Novi Prodekan '+@ime+' '+@prezime+' je u sustavu i ugovor mu traje od '+cast(@datum_pocetka as varchar(10))+' do '+cast(@datum_kraja as varchar(10))
				end
				else
				begin
					--insert into Osoba (PkOsobaOpis,PkAppDataOsoba,Oib,Ime,Prezime,GodinaRodenja,DatumUpisa,Grad,Drzava)
					--values (4,1,@oib,@ime,@prezime,@godina_rodenja,@datum_upisa,@grad,@drzava)

					select @datum_pocetka=(select VrijediDo from OsobaFunkcija where PkAppDataFunkcija=2 and StatusFunkcije='Aktivno')

					if (@datum_pocetka < getdate())
						select @status = 'Aktivno'
					else
						select @status = 'Neaktivno'

					select @info=(select TrajanjeUgovora from AppDataTipUgovora where TipUgovora='Mandatski')
					select @trajanje=substring(@info, patindex('%[0-9]%', @info), patindex('%[0-9][^0-9]%', @info + 't') - patindex('%[0-9]%', @info) + 1)
					select @datum_kraja=@datum_pocetka
					select @datum_kraja=dateadd(month, @trajanje, @datum_kraja)

					insert into OsobaFunkcija (PkAppDataFunkcija,PkOsoba,PKappDataTipUgovora,VrijediOd,VrijediDo,StatusFunkcije)
					values ((select PkAppDataFunkcija from AppDataFunkcija where OpisFunkcije = 'Prodekan'),
							(select PkOsoba from Osoba where Oib=@oib and PkOsobaOpis = 4 and PkAppDataOsoba = 1),
							(select PKappDataTipUgovora from AppDataTipUgovora where TipUgovora = 'Mandatski'),
							@datum_pocetka,
							@datum_kraja,
							@status)
					print 'Novi Prodekan '+@ime+' '+@prezime+' je u sustavu i ugovor mu pocima trajati od '+cast(@datum_pocetka as varchar(10))+' do '+cast(@datum_kraja as varchar(10))
				end
			end
			if (@funkcija_osobe = 'OSTALI DJELATNICI')
			begin
				if not exists (select * from OsobaFunkcija where PkOsoba=(select Pkosoba from Osoba where Oib=@oib and PkOsobaOpis=4 and PkAppDataOsoba=1))
				begin
					--insert into Osoba (PkOsobaOpis,PkAppDataOsoba,Oib,Ime,Prezime,GodinaRodenja,DatumUpisa,Grad,Drzava)
					--values (4,1,@oib,@ime,@prezime,@godina_rodenja,@datum_upisa,@grad,@drzava)

					if (@datum_pocetka < getdate())
						select @status = 'Aktivno'
					else
						select @status = 'Neaktivno'

					select @info=(select TrajanjeUgovora from AppDataTipUgovora where TipUgovora='Odredeno')
					select @trajanje=substring(@info, patindex('%[0-9]%', @info), patindex('%[0-9][^0-9]%', @info + 't') - patindex('%[0-9]%', @info) + 1)
					select @datum_kraja=@datum_pocetka
					select @datum_kraja=dateadd(month, @trajanje, @datum_kraja)

					insert into OsobaFunkcija (PkAppDataFunkcija,PkOsoba,PKappDataTipUgovora,VrijediOd,VrijediDo,StatusFunkcije)
					values ((select PkAppDataFunkcija from AppDataFunkcija where OpisFunkcije = 'Ostali Djelatnici'),
							(select PkOsoba from Osoba where Oib=@oib and PkOsobaOpis = 4 and PkAppDataOsoba = 1),
							(select PKappDataTipUgovora from AppDataTipUgovora where TipUgovora = 'Odredeno'),
							@datum_pocetka,
							@datum_kraja,
							@status)
					print 'Novi ostali '+@ime+' '+@prezime+' je u sustavu i ugovor mu traje od '+cast(@datum_pocetka as varchar(10))+' do '+cast(@datum_kraja as varchar(10))
				end
				else
					print 'Osoba '+@ime+' '+@prezime+' je vec u radnom odnosu'
			end
		end
		else if (@tip_osobe = 'STUDENT')
		begin
			--POZIVA SE PROCEDURA ZA UPIS NOVOG STUDENTA
			exec spReferadaUpisNovogStudenta @oib,@ime,@prezime,@godina_rodenja,@datum_upisa,@grad,@drzava,@idstudij
		end
		else if (@tip_osobe = 'PROFESOR' or @tip_osobe = 'ASISTENT')
		begin
			--POZIVA SE PROCEDURA ZA UPIS NOVOG PROFESORA
			exec spReferadaUpisNovogProfesora @tip_osobe,@oib,@ime,@prezime,@godina_rodenja,@datum_upisa,@grad,@drzava
		end
		else
			print 'Pogreska ulaznog parametra tip_osobe nova osoba nije u sustavu'
	end
	else
		print 'Pogreska osoba '+@ime+' '+@prezime+' vec postoji u sustavu kao '+lower(@tip_osobe)
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
