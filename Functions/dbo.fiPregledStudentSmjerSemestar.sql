SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE function [dbo].[fiPregledStudentSmjerSemestar] 
	(@semestar varchar(20),
	 @idstudij int)  
returns @rez table   
(  
    Ime varchar(25) NOT NULL,  
    Prezime varchar(25) NOT NULL,  
    Semestar varchar(20) NOT NULL,  
    Studij varchar(50) NOT NULL,  
    Smjer varchar(50) NOT NULL  
)   
as
begin
/*  - FUNKCIJA PRIMA 2 PARAMETRA IdStudij I Semestar TE KREIRA I PUNI TABLICU PODACIMA IZ CTE TABLICE KOJU VRACA 
	  KORISNIKU NA PRIKAZ OVISNO O ULAZNIM PARAMETRIMA */
with TMP_cte(ime,prezime,semestar,studij,smjer)
    as
	( 
        select o.Ime,o.Prezime,sm.Semestar,s.Studij,s.Smjer
        from Osoba o
		INNER JOIN StudentPredmet sp   
		ON o.PkOsoba=sp.PkOsoba
		INNER JOIN AppDataOsoba a
		ON o.PkAppDataOsoba=a.PkAppDataOsoba
		INNER JOIN Predmet p
		ON sp.PkPredmet=p.PkPredmet
		INNER JOIN Smjer s
		ON p.PkSmjer=s.PkSmjer
		INNER JOIN Semestar sm
		ON p.PkSemestar=sm.PkSemestar  
        WHERE s.IdStudij = @idstudij and
			  sm.Semestar = @semestar and
			  a.PkAppDataOsoba = 1
	)
	insert @rez  
	select ime, prezime, semestar, studij, smjer
	from TMP_cte   
return
end;
GO
