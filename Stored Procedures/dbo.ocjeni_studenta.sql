SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[ocjeni_studenta] (
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
   len(@datum) <= 10 and
   @ocjena > 0 and @ocjena < 6)
begin
	if exists (select * from dbo.StudentPredmetTest where ID_Student=(select ID_Student from dbo.NewStudenti where ime=@ime and prezime=@prez and datum_rodenja=@datum) and ID_Predmet=(select ID_Predmet from dbo.Predmeti where predmet=@predmet))
	begin
		update StudentPredmetTest set ocjena=@ocjena where ID_Student=(select ID_Student from dbo.NewStudenti where ime=@ime and prezime=@prez and datum_rodenja=@datum) and ID_Predmet=(select ID_Predmet from dbo.Predmeti where predmet=@predmet)
	end
	else
		print 'Pogreska prilikom ocjenjivanja studenrta'
end
else
	print 'Uneseni student ili predmet ne postoji'
end try
begin catch
	if @@TRANCOUNT > 0
		rollback transaction;
end catch;
if @@TRANCOUNT > 0
	commit transaction;
GO
