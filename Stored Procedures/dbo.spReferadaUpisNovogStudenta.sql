SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[spReferadaUpisNovogStudenta] (
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
declare @pks int
declare @sm varchar(50)
declare @st varchar(50)

--POSTAVLJANJE VARIJABLI NA VRIJEDNOSTI UKOLIKO NISU UNESENE
if (@datum_upisa is null or @datum_upisa = '') select @datum_upisa = getdate()

if (@oib ='') select @oib = null
if (@ime ='') select @ime = null
if (@prezime ='') select @prezime = null
if (@godina_rodenja ='') select @godina_rodenja = null
if (@grad ='') select @grad = null
if (@drzava ='') select @drzava = null
if (@idstudij ='') select @idstudij = null

--PROVJERA UNESENIH PODATAKA
if(len(@oib) = 11 and
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
	  - PROCEDURA PROVJERAVA DALI STUDENT VEC POSTOJI U TABLICAMA TE UKOLIKO POSTOJI ISPISUJE GRESKU O POSTOJANJU ISTOG STUDENTA
	  - UKOLIKO STUDENT NE POSTOJI UNOSI SE U SUSTAV S SVIM PREDMETIMA S ZELJENOG STUDIJA I SMJERA KOJI JE UPISAN, UKOLIKO DODE DO POGRESKE UNESENOG
		STUDIJA ISPISUJE SE GRESKA DA TAJ STUDIJ NE POSTOJI U SUSTAVU TE RADI ROOLBACK TRANSAKCIJE TJ. DO SADA ODRADENIH INSERTA
		TAKODER SE PROVJERAVA UNOS ULAZNIH PARAMETARA TE SE ISPISUJE GRESKA UKOLIKO PARAMETRI NISU VALJANO UNESENI
	  - UKOLIKO DODE DO NEKE NE NAVEDENE GRESKE TAKODER ISPISUJE O KOJOJ SE GRESCI RADI I RADI ROLLBACK TRANSAKCIJE
	  - UKOLIKO SE NE UNESE PARAMETAR DATUM UPISA UZIMA SE AUTOMATSKI SISTEMSKO VRIJEME
	  - UKOLIKO JE SVE UREDU NOVI STUDENT JE UNESEN U SUSTAV S SVIM PREDMETIMA S UPISANOG SMJERA
	*/
	if not exists (select * from dbo.Osoba where Ime=@ime and Prezime=@prezime and Oib=@oib and GodinaRodenja=@godina_rodenja and Grad=@grad and Drzava=@drzava and PkOsobaOpis in (select PkOsobaOpis from OsobaOpis where upper(StatusOsobe) in ('STUDENT')))
	begin
		insert into Osoba (PkOsobaOpis,PkAppDataOsoba,Oib,Ime,Prezime,GodinaRodenja,DatumUpisa,Grad,Drzava)
		values ((select PkOsobaOpis from OsobaOpis where StatusOsobe = 'Student'),1,@oib,@ime,@prezime,@godina_rodenja,@datum_upisa,@grad,@drzava)
		print 'Novi student '+@ime+' '+@prezime+' je u sustavu'

		if exists (select * from Smjer where IdStudij=@idstudij)
		begin

			select @pks = (select PkOsoba from Osoba where Ime=@ime and Prezime=@prezime and Oib=@oib and GodinaRodenja=@godina_rodenja and Grad=@grad and Drzava=@drzava)
			insert into StudentPredmet (PkOsoba,PkPredmet) select @pks as PkOsoba, PkPredmet from Predmet where PkSemestar=1 and PkSmjer=(select PkSmjer from Smjer where IdStudij=@idstudij)

			--create table #TmpTable (PkPredmet int)
			--insert into #TmpTable (PkPredmet) select PkPredmet from Predmet where PkSemestar=1 and PkSmjer=(select PkSmjer from Smjer where IdStudij=@idstudij)

			--select @min=min(PkPredmet) from #TmpTable
			--select @max=max(PkPredmet) from #TmpTable

			--while(@min <= @max)
			--begin
			--	if (@min in (select PkPredmet from #TmpTable))
			--	begin
			--		insert into StudentPredmet (PkOsoba,PkPredmet) 
			--		values ((select PkOsoba from Osoba where Ime=@ime and Prezime=@prezime and Oib=@oib and GodinaRodenja=@godina_rodenja and Grad=@grad and Drzava=@drzava and PkOsobaOpis in (3)),@min)
			--	end

			--	select @min=@min+1
			--end
			
			--drop table #TmpTable
			print 'Novi student '+@ime+' '+@prezime+' je u sustavu s pripadajucim predmetima smjera '+cast(@idstudij as varchar(4))
		end
		else
		begin
			select @sm = Smjer from Smjer where IdStudij=@idstudij
			select @st = Studij from Smjer where IdStudij=@idstudij

			print 'Pogreska smjer '+@sm+' i '+@st+' ne postoje u sustavu'
			rollback transaction
		end
	end
	else
		print 'Pogreska student '+@ime+' '+@prezime+' vec postoji u sustavu'
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
