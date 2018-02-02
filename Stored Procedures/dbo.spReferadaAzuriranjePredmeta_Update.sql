SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[spReferadaAzuriranjePredmeta_Update] (
	@predmet varchar(50),
	@idstudij int,
	
	@novi_predmet varchar(50),
	@novi_opis varchar(500),

	@novi_ime varchar(25),
	@novi_prezime varchar(25),
	@novi_oib varchar(11))
as
begin try
set nocount on
begin transaction

--DEKLARACIJA POTREBNIH VARIJABLI
declare @stari_predmet varchar(50)
declare @stari_opis varchar(500)

declare @stari_ime varchar(25)
declare @stari_prezime varchar(25)
declare @stari_oib varchar(25)
declare @stari_pkosoba int
declare @novi_pkosoba int

declare @pkpredmet int
declare @pkosoba int

--POSTAVLJANJE STARIH PODATAKA STUDENTA NA OSNOVU OIBA
select @stari_predmet = (select p.Predmet from Predmet p, Smjer s where p.PkSmjer=s.PkSmjer and upper(p.Predmet) = upper(@predmet) and s.IdStudij=@idstudij)
select @stari_opis = (select p.Opis from Predmet p, Smjer s where p.PkSmjer=s.PkSmjer and upper(p.Predmet) = upper(@predmet) and s.IdStudij=@idstudij)

select @stari_ime = (select o.Ime from Osoba o, ProfesorPredmet pp, Predmet p, Smjer s where o.PkOsoba=pp.PkOsoba and pp.PkPredmet=p.PkPredmet and p.PkSmjer=s.PkSmjer and upper(p.Predmet)=upper(@predmet) and s.IdStudij=@idstudij)
select @stari_prezime = (select o.Prezime from Osoba o, ProfesorPredmet pp, Predmet p, Smjer s where o.PkOsoba=pp.PkOsoba and pp.PkPredmet=p.PkPredmet and p.PkSmjer=s.PkSmjer and upper(p.Predmet)=upper(@predmet) and s.IdStudij=@idstudij)
select @stari_oib = (select o.Oib from Osoba o, ProfesorPredmet pp, Predmet p, Smjer s where o.PkOsoba=pp.PkOsoba and pp.PkPredmet=p.PkPredmet and p.PkSmjer=s.PkSmjer and upper(p.Predmet)=upper(@predmet) and s.IdStudij=@idstudij)
select @stari_pkosoba = (select PkOsoba from Osoba where Ime=@stari_ime and Prezime=@stari_prezime and Oib=@stari_oib)

if ((@novi_ime is null or @novi_ime = '') and (@novi_prezime is null or @novi_prezime = '') and (@novi_oib is null or @novi_oib = ''))
	select @novi_pkosoba = null
else
	select @novi_pkosoba = (select PkOsoba from Osoba where Ime=@novi_ime and Prezime=@novi_prezime and Oib=@novi_oib)

--POSTAVLJANJE STARIH PODATAKA U NOVE TJ ONE KOJI SE NE TREBAJU AZURIRAT VRACAJU SE NA STARE VRIJEDNOSTI
if (@novi_predmet is null or @novi_predmet = '') select @novi_predmet=@stari_predmet
if (@novi_opis is null or @novi_opis = '') select @novi_opis=@stari_opis
if (@novi_ime is null or @novi_ime = '') select @novi_ime=@stari_ime
if (@novi_prezime is null or @novi_prezime = '') select @novi_prezime=@stari_prezime
if (@novi_oib is null or @novi_oib = '') select @novi_oib=@stari_oib
if (@novi_pkosoba is null or @novi_pkosoba = '') select @novi_pkosoba=@stari_pkosoba
if (@novi_pkosoba is null) select @novi_pkosoba=@stari_pkosoba

--PROVJERA UNESENIH PODATAKA
if(len(@predmet) <= 50 and
   @idstudij > 0 and @idstudij < 1000 and
   len(@novi_predmet) <= 50 and
   len(@novi_opis) <= 500 and
   len(@novi_ime) <= 25 and
   len(@novi_prezime) <= 25 and
   len(@novi_oib) = 11)
begin
	if exists (select * from Predmet p, Smjer s where p.PkSmjer=s.PkSmjer and upper(p.Predmet)=upper(@predmet) and s.IdStudij=@idstudij)
	begin

		select @novi_pkosoba = (select PkOsoba from Osoba where ime=@novi_ime and Prezime=@novi_prezime and oib=@novi_oib)

		select @pkpredmet = (select p.PkPredmet from Predmet p, Smjer s where p.PkSmjer=s.PkSmjer and upper(p.Predmet)=upper(@predmet) and s.IdStudij=@idstudij)
		select @pkosoba = (select PkOsoba from Osoba where Ime=@novi_ime and Prezime=@novi_prezime and Oib=@novi_oib)

		if (@pkpredmet is not null and @pkosoba is not null)
		begin
			update Predmet set Predmet=@novi_predmet, Opis=@novi_opis where PkPredmet = @pkpredmet and PkSmjer = (select Pksmjer from Smjer where IdStudij=@idstudij)
			update ProfesorPredmet set PkOsoba=@novi_pkosoba, PkPredmet=@pkpredmet where PkOsoba=@stari_pkosoba and PkPredmet=@pkpredmet
			print 'Update podataka je odraden'
		end
		else
			print 'Ne postoje podaci u tablici profesorpredmet'
	end
	else
		print 'Pogreska predmet '+@predmet+' ne postoji'
end
end try
begin catch
	execute dbo.GetErrorInfo;
	if @@TRANCOUNT > 0
		rollback transaction;
end catch;
if @@TRANCOUNT > 0
	commit transaction;
GO
