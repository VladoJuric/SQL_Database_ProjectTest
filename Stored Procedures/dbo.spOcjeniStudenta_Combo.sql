SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[spOcjeniStudenta_Combo] (
	@ime varchar(25),
	@prezime varchar(25),
	@predmet varchar(50),
	@idstudij int,
	@ocjena smallint,
	@tipispita varchar(20))  
as
begin try
set nocount on
begin transaction

--DEKLARACIJA POTREBNIH VARIJABLI
declare @pkosoba int = null
declare @pkpredmet int = null
declare @pkispit int = NULL
DECLARE @semestar VARCHAR(20) = NULL
DECLARE @semint INT = null
DECLARE @pkredispita INT = null

--PROVJERA UNESENIH PODATAKA
if(len(@ime) <= 25 and
   len(@prezime) <= 25 and
   isnumeric(@ime) <= 0 and
   isnumeric(@prezime) <= 0 and
   len(@predmet) <= 50 and
   @idstudij > 0 and @idstudij < 1000 and
   @ocjena > 0 and @ocjena < 6 and
   len(@tipispita) <= 20) 
begin
	/*
	  - PROCEDURA ZA UNOS OCJENE STUDENTA KOJA POZIVA PROCEDURU ZA UPIS OCJENE S PARAMETRINA PKOSOBA PKPREDEMT I OCJENA
	*/
	if exists (select * from StudentPredmet sp, Osoba o, Predmet p, Smjer s, OsobaOpis oo where o.PkOsoba=sp.PkOsoba and sp.PkPredmet=p.PkPredmet and p.PkSmjer=s.PkSmjer and o.PkOsobaOpis=oo.PkOsobaOpis and o.Ime=@ime and o.Prezime=@prezime and p.Predmet=@predmet and oo.StatusOsobe='Student' and s.IdStudij=@idstudij)
	begin
		select @pkosoba = (select o.PkOsoba from Osoba o, OsobaOpis oo, StudentPredmet sp, Predmet p, Smjer s where o.PkOsobaOpis=oo.PkOsobaOpis and o.PkOsoba=sp.PkOsoba and sp.PkPredmet=p.PkPredmet and p.PkSmjer=s.PkSmjer and Ime=@ime and Prezime=@prezime and s.IdStudij=@idstudij and oo.StatusOsobe='Student' and p.Predmet=@predmet)
		select @pkpredmet = (select p.PkPredmet from Osoba o, OsobaOpis oo, StudentPredmet sp, Predmet p, Smjer s where o.PkOsobaOpis=oo.PkOsobaOpis and o.PkOsoba=sp.PkOsoba and sp.PkPredmet=p.PkPredmet and p.PkSmjer=s.PkSmjer and Ime=@ime and Prezime=@prezime and s.IdStudij=@idstudij and oo.StatusOsobe='Student' and p.Predmet=@predmet)
		
		select @tipispita=upper(@tipispita)

		SELECT @semestar=(SELECT semestar FROM semestar WHERE PkSemestar=(SELECT DISTINCT PkSemestar FROM Predmet WHERE PkSmjer=(SELECT PkSmjer FROM Smjer WHERE IdStudij=@idstudij)))

		IF (@semestar IN ('1. Semestar','3. Semestar','5. Semestar','7. Semestar','9. Semestar'))
			SELECT @semint=1
		IF (@semestar IN ('2. Semestar','4. Semestar','6. Semestar','8. Semestar','10. Semestar'))
			SELECT @semint=2

		set @pkispit = case @tipispita
			when 'PRVI KOLOKVIJ' then 1
			when 'DRUGI KOLOKVIJ' then 2
			when 'PRVI ISPITNI ROK' then 3
			when 'DRUGI ISPITNI ROK' then 4
			when 'TRECI ISPITNI ROK' then 5
			when 'DEKANSKI ROK' then 6
			else null
		END
        
		SELECT @pkredispita=(SELECT PkRedIspita FROM dbo.RedIspita WHERE PkAppDataIspit=@pkispit AND Semestar=@semint)

		if (@pkosoba is not null and @pkpredmet is not NULL AND @pkispit IS NOT NULL AND @pkredispita IS NOT null)
			exec spUpisOcjena @pkosoba, @pkpredmet, @ocjena,@pkredispita, @pkispit
		else
			print 'Nisu pronadeni podaci za osobu '+@ime+' '+@prezime+', predmeta '+@predmet+' s smjera '+@idstudij
	end
	else
		 print 'Pogreska student '+@ime+' '+@prezime+', smjera '+@idstudij+', predmeta '+@predmet+' ne postoji'
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
