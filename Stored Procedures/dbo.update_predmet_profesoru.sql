SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[update_predmet_profesoru] (
	@stari_ime varchar(50),
	@stari_prezime varchar(50),
	@novi_ime varchar(50),
	@novi_prezime varchar(50),
	@predmet varchar(50))
as
begin try
set nocount on
begin transaction

if(len(@stari_ime) <= 50 and
   len(@stari_prezime) <= 50 and
   len(@novi_ime) <= 50 and
   len(@novi_prezime) <= 50 and
   len(@predmet) <= 50)
begin
	if exists (select * from dbo.Profesori where ime=@stari_ime and prezime=@stari_prezime)
	begin
		if exists (select * from dbo.Profesori where ime=@novi_ime and prezime=@novi_prezime)
		begin
			if exists (select * from dbo.Predmeti where predmet=@predmet)
			begin
				update dbo.Predmeti set ID_Profesor=(select ID_Profesor from dbo.Profesori where ime=@novi_ime and prezime=@novi_prezime) where predmet=@predmet 
			end
			else
				print 'Pogreska predmet '+@predmet+' ne postoji'
		end
		else
			print 'Pogreska profesor '+@novi_ime+' '+@novi_prezime+' ne postoji'
	end
	else
		print 'Pogreska profesor '+@stari_ime+' '+@stari_prezime+' ne postoji'
end
	else
		print 'Pogreska prilikom izmjene predavaca za predmet '+@predmet
end try
begin catch
	execute dbo.GetErrorInfo
		if @@TRANCOUNT > 0
		rollback transaction;
end catch;
if @@TRANCOUNT > 0
	commit transaction;
GO
