SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[spReferadaOtkazOsoblju_Update] (
	@oib varchar(11))
as
begin try
set nocount on
begin transaction

if (@oib ='') select @oib = null

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
	  - PROCEDURA PROVJERAVA DALI OSOBA POSTOJI U TABLICAMA TE UKOLIKO POSTOJI POSTAAVLJA NJEGOV STATUS AKTIVNOSTI NA NE
	  - UKOLIKO OSOBA NE POSTOJI ISPISUJE SE POGRESKA DA NAVEDENA OSOBA NE POSTOJI U SUSTAVU I NE PODUZIMA SE NISTA,
		TAKODER SE PROVJERAVA UNOS ULAZNIH PARAMETARA TE SE ISPISUJE GRESKA UKOLIKO PARAMETRI NISU VALJANO UNESENI
	  - UKOLIKO DODE DO NEKE NE NAVEDENE GRESKE TAKODER ISPISUJE O KOJOJ SE GRESCI RADI I RADI ROLLBACK TRANSAKCIJE
	  - UKOLIKO JE SVE UREDU OSOBA JE AZURIRAN STATUS NA NEAKTIVAN TE JE IZBRISAN IZ SUSTAVA
	*/
	if exists (select * from Osoba o, AppDataOsoba a, OsobaOpis op, OsobaFunkcija fo, AppDataFunkcija af
				where o.PkAppDataOsoba = a.PkAppDataOsoba and
					  o.PkOsobaOpis = op.PkOsobaOpis and
					  fo.PkOsoba = o.PkOsoba and
					  fo.PkAppDataFunkcija = af.PkAppDataFunkcija and
					  o.Ime = @ime and
					  o.Prezime = @prezime and
					  o.Oib = @oib and
					  o.GodinaRodenja = @godina_rodenja and
					  o.Grad = @grad and
					  o.Drzava = @drzava and
					  o.DatumUpisa = @datum_upisa and
					  a.StatusAktivnosti = 'DA' and
					  o.PkOsobaOpis = 4 and
					  af.VrstaFunkcije = 'Ostali djelatnici')
	begin

	select @pkosoba = PkOsoba from Osoba where PkOsoba = (select o.PkOsoba from Osoba o, AppDataOsoba a, OsobaOpis op, OsobaFunkcija fo, AppDataFunkcija af
								where o.PkAppDataOsoba = a.PkAppDataOsoba and
									  o.PkOsobaOpis = op.PkOsobaOpis and
									  o.PkOsoba = fo.PkOsoba and
									  fo.PkAppDataFunkcija = af.PkAppDataFunkcija and
									  o.Ime = @ime and
									  o.Prezime = @prezime and
									  o.Oib = @oib and
									  o.GodinaRodenja = @godina_rodenja and
									  o.Grad = @grad and
									  o.Drzava = @drzava and
									  o.DatumUpisa = @datum_upisa and
									  a.StatusAktivnosti = 'DA' and
									  o.PkOsobaOpis = 4 and
									  af.VrstaFunkcije = 'Ostali djelatnici')

		--UPDATE OSOBE TJ PROFESORA KOJI NE PREDAJE VISE NIJEDAN PREDMET U STATUS AKTIVNOSTI NE
		update Osoba set PkAppDataOsoba = (select PkAppDataOsoba from AppDataOsoba where StatusAktivnosti = 'NE') where PkOsoba = @pkosoba	and PkOsobaOpis = 4
		print 'Osoba '+@ime+' '+@prezime+' vise nije u radnom odnosu s fakultetom'
	end
	else
		print 'Pogreska osoba '+@ime+' '+@prezime+' ne postoji u sustavu kao Ostali djelatnici'
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
