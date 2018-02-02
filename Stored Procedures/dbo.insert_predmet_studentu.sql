SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[insert_predmet_studentu] (
	@ime varchar(50),
	@prez varchar(50),
	@datum varchar(10),
	@predmet varchar(50),
	@ocjena smallint)
as
begin try
set nocount on
begin transaction
set dateformat dmy

if(len(@ime) <= 50 and 
   len(@prez) <= 50 and
   isnumeric(@ime) <= 0 and
   isnumeric(@prez) <= 0 and
   len(@predmet) <= 50 and
   len(@datum) <= 10)
begin
	if exists (select * from dbo.NewStudenti where ime=@ime and prezime=@prez and datum_rodenja=@datum)
	begin
		if exists (select * from dbo.Predmeti where predmet=@predmet)
		begin
			if(@ocjena is null or @ocjena = '')
				insert into dbo.StudentPredmetTest (ID_Predmet,ID_Student) values((select ID_Predmet from dbo.Predmeti where predmet=@predmet),(select ID_Student from dbo.NewStudenti where ime=@ime and prezime=@prez and datum_rodenja=@datum))
			else if(@ocjena > 0 and @ocjena < 6)
				insert into dbo.StudentPredmetTest (ID_Predmet,ID_Student,ocjena) values((select ID_Predmet from dbo.Predmeti where predmet=@predmet),(select ID_Student from dbo.NewStudenti where ime=@ime and prezime=@prez and datum_rodenja=@datum),@ocjena)			
			else
				print 'Pogreska prilikom unosa ocjene predmeta'
		end
		else
			print 'Pogreska '+@predmet+' ne postoji'
	end
	else
		print 'Pogreska student '+@ime+' '+@prez+' ne postoji'
end
else
	print 'Pogreska prilikom dodavanja predmeta za studenta'
end try
begin catch
	if @@TRANCOUNT > 0
		rollback transaction;
end catch;
if @@TRANCOUNT > 0
	commit transaction;
GO
