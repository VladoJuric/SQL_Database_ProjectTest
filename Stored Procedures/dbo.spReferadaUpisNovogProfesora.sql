SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[spReferadaUpisNovogProfesora] (
	@tip_profesora varchar(20),
	@oib varchar(11),
	@ime varchar(25),
	@prezime varchar(25),
	@godina_rodenja date,
	@datum_upisa date,
	@grad varchar(30),
	@drzava varchar(30))
as
begin try
set nocount on
begin transaction

--DEKLARACIJA POTREBNIH VARIJABLI
declare @min int
declare @max int
declare @sm varchar(50)
declare @st varchar(50)

--UKOLIKO DATUM UPISA NIJE SPECIFICIRAN UZIMA SE TRENUTNI DATUM
if (@datum_upisa is null or @datum_upisa = '') select @datum_upisa = getdate()

if (upper(@tip_profesora) not in ('PROFESOR','ASISTENT')) select @tip_profesora = null
if (@oib ='') select @oib = null
if (@ime ='') select @ime = null
if (@prezime ='') select @prezime = null
if (@godina_rodenja ='') select @godina_rodenja = null
if (@grad ='') select @grad = null
if (@drzava ='') select @drzava = null

--PROVJERA UNESENIH PODATAKA
if(len(@tip_profesora) <= 20 and
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
	  - PROCEDURA PROVJERAVA DALI PROFESOR VEC POSTOJI U TABLICAMA TE UKOLIKO POSTOJI ISPISUJE GRESKU O POSTOJANJU ISTOG PROFESORA
	  - PROCEDURA UNOSI PODATKE NOVOG PROFESORA ILI ASISTENTA U SUSTAV
	    TAKODER SE PROVJERAVA UNOS ULAZNIH PARAMETARA TE SE ISPISUJE GRESKA UKOLIKO PARAMETRI NISU VALJANO UNESENI
	  - UKOLIKO DODE DO NEKE NE NAVEDENE GRESKE TAKODER ISPISUJE O KOJOJ SE GRESCI RADI I RADI ROLLBACK TRANSAKCIJE
	  - UKOLOIKO SE NE UNESE PARAMETAR DATUM UPISA UZIMA SE SISTEMSKO VRIJEME
	  - UKOLIKO JE SVE UREDU NOVI PROFESOR JE UNESEN U SUSTAV
	*/
	select @tip_profesora=upper(@tip_profesora)

	if not exists (select * from dbo.Osoba where Ime=@ime and Prezime=@prezime and Oib=@oib and GodinaRodenja=@godina_rodenja and Grad=@grad and Drzava=@drzava and PkOsobaOpis in (select PkOsobaOpis from OsobaOpis where upper(StatusOsobe) in (upper(@tip_profesora))))
	begin
		if (@tip_profesora = 'PROFESOR')
		begin
			insert into Osoba (PkOsobaOpis,PkAppDataOsoba,Oib,Ime,Prezime,GodinaRodenja,DatumUpisa,Grad,Drzava)
			values ((select PkOsobaOpis from OsobaOpis where StatusOsobe = 'Profesor'),1,@oib,@ime,@prezime,@godina_rodenja,@datum_upisa,@grad,@drzava)
			print 'Novi  profesor '+@ime+' '+@prezime+' je u sustavu'
		end
		else if (@tip_profesora = 'ASISTENT')
		begin
			insert into Osoba (PkOsobaOpis,PkAppDataOsoba,Oib,Ime,Prezime,GodinaRodenja,DatumUpisa,Grad,Drzava)
			values ((select PkOsobaOpis from OsobaOpis where StatusOsobe = 'Asistent'),1,@oib,@ime,@prezime,@godina_rodenja,@datum_upisa,@grad,@drzava)
			print 'Novi asistent '+@ime+' '+@prezime+' je u sustavu'
		end
		else
			print 'Pogreska novi profesor ili asistent nije unesen u sustav'
	end
	else
		print 'Pogreska profesor '+@ime+' '+@prezime+' vec postoji u sustavu'
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
