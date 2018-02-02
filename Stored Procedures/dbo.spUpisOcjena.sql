SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spUpisOcjena] (
	@PkStudent int,
	@PkPredmet int,
	@Ocjena smallint,
	@PkRedIspita INT,
	@PkIspit int)  
as
begin try
set nocount on
begin transaction

--DEKLARACIJA POTREBNIH VARIJABLI
declare @ime varchar(25)
declare @prezime varchar(25)
declare @predmet varchar(50)
declare @tip varchar(20)
declare @brojiz int

	/*
	  - PROCEDURA ZA UPDATE OCJENE STUDENTA NA OSNOVU PKOSOBE I PKPREDMETA
	*/   
if exists (select * from StudentPredmet where PkOsoba=@PkStudent and PkPredmet=@PkPredmet)
begin
	if(@PkIspit in (1,2,3,4,5,6))
	begin
		select @ime = (select Ime from Osoba where PkOsoba=@PkStudent)
		select @prezime = (select Prezime from Osoba where PkOsoba=@PkStudent)
		select @predmet = (select p.Predmet from Predmet p, StudentPredmet sp where sp.PkPredmet=p.PkPredmet and sp.PkOsoba=@PkStudent and p.PkPredmet=@PkPredmet)
		select @tip = (select TipIspit from AppDataIspit where PkAppDataIspit=@PkIspit)
		select @brojiz = (select max(BrojIzlazakIspit) from StudentPredmet where PkOsoba=@PkStudent and PkPredmet=@PkPredmet)
		select @brojiz=+1

		if not exists (select * from StudentPredmet sp, RedIspita ri where sp.PkRedIspita=ri.PkRedIspita and sp.PkOsoba=@PkStudent and sp.PkPredmet=@PkPredmet and sp.PkRedIspita = (select PkRedIspita from RedIspita where PkAppDataIspit=@PkIspit))
		begin
			insert into StudentPredmet (PkOsoba,PkPredmet,PkRedIspita,Ocjena,BrojIzlazakIspit) values(@PkStudent,@PkPredmet,@PkRedIspita,@Ocjena,@brojiz)
			print 'Studentu '+@ime+' '+@prezime+' unesena je ocjena '+cast(@Ocjena as varchar(2))+' za predmet '+@predmet+' na ispitu '+@tip
		end
		else
			print 'Student '+@ime+' '+@prezime+' veci ima ocjenu za predmet '+@predmet+' na ispitu '+@tip
	end
	else
		print 'Tip ispita ne postoji u sustavu'
end
else
	 print 'Greska prilikom updatea ocjene' 
end try
begin catch
	execute dbo.GetErrorInfo;
	if @@TRANCOUNT > 0
		rollback transaction;
end catch;
if @@TRANCOUNT > 0
	commit transaction;
GO
