SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[spReferadaIspisProfesora_Delete] (
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
declare @status varchar(2)
declare @pkosoba int

--POSTAVLJANJE PODATAKA STUDENTA NA OSNOVU OIBA
select @ime = (select Ime from Osoba where oib = @oib)
select @prezime = (select Prezime from Osoba where oib = @oib)
select @godina_rodenja = (select GodinaRodenja from Osoba where oib = @oib)
select @datum_upisa = (select DatumUpisa from Osoba where oib = @oib)
select @grad = (select Grad from Osoba where oib = @oib)
select @drzava = (select Drzava from Osoba where oib = @oib)
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
   isnumeric(@prezime) <= 0)
begin
	/*
	  - PROCEDURA PROVJERAVA DALI PROFESOR POSTOJI U TABLICAMA TE UKOLIKO POSTOJI POSTAAVLJA NJEGOV STATUS AKTIVNOSTI NA NE
	  - UKOLIKO PROFESOR NE POSTOJI ISPISUJE SE POGRESKA DA NAVEDENI PROFESOR NE POSTOJI U SUSTAVU I NE PODUZIMA SE NISTA,
		TAKODER SE PROVJERAVA UNOS ULAZNIH PARAMETARA TE SE ISPISUJE GRESKA UKOLIKO PARAMETRI NISU VALJANO UNESENI
	  - UKOLIKO DODE DO NEKE NE NAVEDENE GRESKE TAKODER ISPISUJE O KOJOJ SE GRESCI RADI
	  - UKOLIKO JE SVE UREDU PROFESOR JE AZURIRAN STATUS NA NEAKTIVAN TE JE IZBRISAN IZ SUSTAVA
	*/


	if exists (select * from Osoba o, AppDataOsoba a, OsobaOpis op
				where o.PkAppDataOsoba = a.PkAppDataOsoba and
					  op.PkOsobaOpis = o.PkOsobaOpis and
					  o.Ime = @ime and
					  o.Prezime = @prezime and
					  o.Oib = @oib and
					  o.GodinaRodenja = @godina_rodenja and
					  o.Grad = @grad and
					  o.Drzava = @drzava and
					  o.DatumUpisa = @datum_upisa and
					  a.StatusAktivnosti = 'DA' and
					  op.StatusOsobe in ('Profesor','Asistent'))
	begin
	select @pkosoba = PkOsoba from Osoba where Oib = @oib --= (select o.PkOsoba from Osoba o, ProfesorPredmet sp, Predmet p, Smjer s, AppDataOsoba a, OsobaOpis op
	--							where o.PkOsoba = sp.PkOsoba and
	--							  o.PkAppDataOsoba = a.PkAppDataOsoba and
	--							  sp.PkPredmet = p.PkPredmet and
	--							  p.PkSmjer = s.PkSmjer and
	--							  op.PkOsobaOpis = o.PkOsobaOpis and
	--							  o.Ime = @ime and
	--							  o.Prezime = @prezime and
	--							  o.Oib = @oib and
	--							  o.GodinaRodenja = @godina_rodenja and
	--							  o.Grad = @grad and
	--							  o.Drzava = @drzava and
	--							  o.DatumUpisa = @datum_upisa and
	--							  a.StatusAktivnosti = 'DA' and
	--							  op.StatusOsobe in ('Profesor','Asistent'))

		--BRISEM PREDMETAE KOJI PREDAJE OVAJ PROFESOR I SPREMAM IH U LOG TABLICU PROFESORPREDMETLOG
		delete ProfesorPredmet where PkOsoba = @pkosoba
		--UPDATE OSOBE TJ PROFESORA KOJI NE PREDAJE VISE NIJEDAN PREDMET U STATUS AKTIVNOSTI NE
		update Osoba set PkAppDataOsoba = (select PkAppDataOsoba from AppDataOsoba where StatusAktivnosti = 'NE') where PkOsoba = @pkosoba and Oib = @oib
		print 'Profesor/Asistent '+@ime+' '+@prezime+' je izbrisan iz sustava'
	end
	else
		print 'Pogreska profesor/asistent '+@ime+' '+@prezime+' ne postoji u sustavu'
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
