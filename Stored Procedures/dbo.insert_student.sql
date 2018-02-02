SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[insert_student] (
	@s_ime varchar(50),
	@s_prez varchar(50),
	@s_datum varchar(10),
	@s_grad varchar(50),
	@s_drzava varchar(50))
as
begin try
set nocount on
begin transaction

set dateformat dmy
if(len(@s_ime) <= 50 and
   len(@s_prez) <= 50 and
   len(@s_datum) <= 10 and
   len(@s_grad) <= 50 and
   len(@s_drzava) <= 50 and
   isnumeric(@s_ime) <= 0 and
   isnumeric(@s_prez) <= 0 and
   isdate(@s_datum) = 1)
begin
	if not exists (select * from dbo.NewStudenti where ime=@s_ime and prezime=@s_prez and datum_rodenja=@s_datum)
	begin
		--NOVA TABLICA
		insert into dbo.NewStudenti (ime,prezime,datum_rodenja,grad,drzava) values (@s_ime,@s_prez,@s_datum,@s_grad,@s_drzava)
		--KRAJ NOVE TABLICE

		--insert into dbo.Studenti (ime,prezime,datum_rodenja) values(@s_ime,@s_prez,@s_datum)
		--insert into dbo.Drzava (grad,drzava,ID_Student) values (@s_grad,@s_drzava,(select ID_Student from dbo.Studenti where ime=@s_ime and prezime=@s_prez and datum_rodenja=@s_datum))
	end
	else
		print 'Student '+@s_ime+' '+@s_prez+' nije unesen u sustav !!!'
end
else
	print 'Greska prilikom unosa studenta'
end try
begin catch
	execute dbo.GetErrorInfo;
	if @@TRANCOUNT > 0
		rollback transaction;
end catch;
if @@TRANCOUNT > 0
	commit transaction;
GO
