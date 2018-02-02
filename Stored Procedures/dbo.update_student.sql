SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[update_student](
	@staro_ime varchar(50),
	@staro_prezime varchar(50),
	@stari_datum varchar(10),
	@novo_ime varchar(50),
	@novo_prezime varchar(50),
	@novi_datum varchar(10),
	@novi_grad varchar(50),
	@nova_drzava varchar(50))
as
begin try
set nocount on
begin transaction
set dateformat dmy

if(len(@staro_ime) <= 50 and 
   len(@staro_prezime) <= 50 and
   len(@stari_datum) <= 10 and
   len(@novo_ime) <= 50 and
   len(@novo_prezime) <= 50 and
   len(@novi_datum) <= 10 and
   isnumeric(@novo_ime) <= 0 and
   isnumeric(@novo_prezime) <= 0 and
   isdate(@novi_datum) = 1)
begin
	if exists (select * from dbo.NewStudenti where ime=@staro_ime and prezime=@staro_prezime and datum_rodenja=@stari_datum)
	begin
		--NOVA TABLICA
		if((@novi_grad is null and @nova_drzava is null) or (@novi_grad='' and @nova_drzava=''))
			update dbo.NewStudenti set ime=@novo_ime, prezime=@novo_prezime, datum_rodenja=@novi_datum where ID_Student=(select ID_Student from dbo.NewStudenti where ime = @staro_ime and prezime = @staro_prezime and datum_rodenja = @stari_datum)			
		else if(@nova_drzava is null or @nova_drzava='')
			update dbo.NewStudenti set ime=@novo_ime, prezime=@novo_prezime, datum_rodenja=@novi_datum, grad=@novi_grad where ID_Student=(select ID_Student from dbo.NewStudenti where ime = @staro_ime and prezime = @staro_prezime and datum_rodenja = @stari_datum)		
		else if(@novi_grad is null or @novi_grad = '')
			update dbo.NewStudenti set ime=@novo_ime, prezime=@novo_prezime, datum_rodenja=@novi_datum, drzava=@nova_drzava where ID_Student=(select ID_Student from dbo.NewStudenti where ime = @staro_ime and prezime = @staro_prezime and datum_rodenja = @stari_datum)
		--KRAJ NOVE TABLICE

		--update dbo.Studenti set ime=@novo_ime, prezime=@novo_prezime, datum_rodenja=@novi_datum where ID_Student = (select ID_Student from dbo.Studenti where ime = @staro_ime and prezime = @staro_prezime and datum_rodenja = @stari_datum)
	end
	else
		print 'Pogreska student '+@staro_ime+' '+@staro_prezime+' ne postoji'
end
else
	print 'Pogreska prilikom izmjene podataka studenta'
end try
begin catch
	execute dbo.GetErrorInfo
		if @@TRANCOUNT > 0
		rollback transaction;
end catch;
if @@TRANCOUNT > 0
	commit transaction;
GO
