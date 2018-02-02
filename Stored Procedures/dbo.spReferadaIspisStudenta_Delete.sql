SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[spReferadaIspisStudenta_Delete] (
	@oib varchar(11))
as
begin try
set nocount on
begin transaction

--DEKLARACIJA POTREBNIH VARIJABLI
declare @ime varchar(25)
declare @prezime varchar(25)
declare @godina_rodenja varchar(10)
declare @datum_upisa varchar(10)
declare @grad varchar(30)
declare @drzava varchar(30)
declare @idstudij int
declare @status varchar(2)
declare @pkosoba int

--POSTAVLJANJE PODATAKA STUDENTA NA OSNOVU OIBA
select @ime = (select Ime from Osoba where oib = @oib)
select @prezime = (select Prezime from Osoba where oib = @oib)
select @godina_rodenja = (select GodinaRodenja from Osoba where oib = @oib)
select @datum_upisa = (select DatumUpisa from Osoba where oib = @oib)
select @grad = (select Grad from Osoba where oib = @oib)
select @drzava = (select Drzava from Osoba where oib = @oib)
select @idstudij = (select IdStudij from Smjer where PkSmjer in (select PkSmjer from Predmet where PkPredmet in (select PkPredmet from StudentPredmet where PkOsoba in (select PkOsoba from Osoba where Oib=@oib))))
select @status =  (select StatusAktivnosti from AppDataOsoba where PkAppDataOsoba = (select PkAppDataOsoba from Osoba where oib = @oib))


--PROVJERA UNESENIH PODATAKA
if(len(@oib) = 11 and
   len(@ime) <= 25 and
   len(@prezime) <= 25 and
   len(@grad) <= 30 and
   len(@drzava) <= 30 and
   isdate(@godina_rodenja) = 1 and
   isdate(@datum_upisa) = 1 and
   isnumeric(@ime) <= 0 and
   isnumeric(@prezime) <= 0 and
   @idstudij > 0 and @idstudij < 1000)
begin
	/*
	  - PROCEDURA PROVJERAVA DALI STUDENT POSTOJI U TABLICAMA TE UKOLIKO POSTOJI POSTAAVLJA NJEGOV STATUS AKTIVNOSTI NA NE
	  - UKOLIKO STUDENT NE POSTOJI ISPISUJE SE POGRESKA DA NAVEDENI STUDENT NE POSTOJI U SUSTAVU I NE PODUZIMA SE NISTA,
		TAKODER SE PROVJERAVA UNOS ULAZNIH PARAMETARA TE SE ISPISUJE GRESKA UKOLIKO PARAMETRI NISU VALJANO UNESENI
	  - UKOLIKO DODE DO NEKE NE NAVEDENE GRESKE TAKODER ISPISUJE O KOJOJ SE GRESCI RADI I RADI ROLLBACK TRANSAKCIJE
	  - UKOLIKO JE SVE UREDU STUDENTU JE AZURIRAN STATUS NA NEAKTIVAN TE JE IZBRISAN IZ SUSTAVA
	*/


	if exists (select * from Osoba o, StudentPredmet sp, Predmet p, Smjer s, AppDataOsoba a, OsobaOpis op
				where o.PkOsoba = sp.PkOsoba and
					  o.PkAppDataOsoba = a.PkAppDataOsoba and
					  sp.PkPredmet = p.PkPredmet and
					  p.PkSmjer = s.PkSmjer and
					  op.PkOsobaOpis = o.PkOsobaOpis and
					  o.Ime = @ime and
					  o.Prezime = @prezime and
					  o.Oib = @oib and
					  o.GodinaRodenja = @godina_rodenja and
					  o.Grad = @grad and
					  o.Drzava = @drzava and
					  o.DatumUpisa = @datum_upisa and
					  a.StatusAktivnosti = 'DA' and
					  s.IdStudij = @idstudij and
					  op.StatusOsobe = 'Student')
	begin
	select @pkosoba = PkOsoba from Osoba where Oib = @oib --= (select distinct o.PkOsoba from Osoba o, StudentPredmet sp, Predmet p, Smjer s, AppDataOsoba a, OsobaOpis op
	--			where o.PkOsoba = sp.PkOsoba and
	--				  o.PkAppDataOsoba = a.PkAppDataOsoba and
	--				  sp.PkPredmet = p.PkPredmet and
	--				  p.PkSmjer = s.PkSmjer and
	--				  op.PkOsobaOpis = o.PkOsobaOpis and
	--				  o.Ime = @ime and
	--				  o.Prezime = @prezime and
	--				  o.Oib = @oib and
	--				  o.GodinaRodenja = @godina_rodenja and
	--				  o.Grad = @grad and
	--				  o.Drzava = @drzava and
	--				  o.DatumUpisa = @datum_upisa and
	--				  a.StatusAktivnosti = 'DA' and
	--				  s.IdStudij = @idstudij and
	--				  op.StatusOsobe = 'Student')
	
		--BRISEM PREDMETAE KOJI IMA OVAJ STUDENT I SPREMAM IH U LOG TABLICU STUDENTPREDMETLOG
		delete StudentPredmet where PkOsoba = @pkosoba
		--UPDATE OSOBE TJ STUDENTS KOJI NE POSTOJI VISET U STATUS AKTIVNOSTI NE
		update Osoba set PkAppDataOsoba = (select PkAppDataOsoba from AppDataOsoba where StatusAktivnosti = 'NE') where PkOsoba = @pkosoba	and Oib=@oib
		print 'Student '+@ime+' '+@prezime+' je izbrisan iz sustava'
	end
	else
		print 'Pogreska student '+@ime+' '+@prezime+' ne postoji u sustavu'
end
else
	print 'Pogreska ulaznih parametara ili je student vec izbrisan'
end try
begin catch
	execute dbo.GetErrorInfo;
	if @@TRANCOUNT > 0
		rollback transaction;
end catch;
if @@TRANCOUNT > 0
	commit transaction;
GO
