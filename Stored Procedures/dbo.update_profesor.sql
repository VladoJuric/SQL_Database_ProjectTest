SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[update_profesor](
	@staro_ime varchar(50),
	@staro_prezime varchar(50),
	@stara_soba varchar(50),
	@novo_ime varchar(50),
	@novo_prezime varchar(50),
	@nova_soba varchar(50))
as
begin try
set nocount on
begin transaction

if(len(@staro_ime) <= 50 and
   len(@staro_prezime) <= 50 and
   len(@novo_ime) <= 50 and
   len(@novo_prezime) <= 50 and
   @nova_soba > 0 and
   isnumeric(@novo_ime) <= 0 and
   isnumeric(@novo_prezime) <= 0)
begin
	if exists (select * from dbo.Profesori where ime=@staro_ime and prezime=@staro_prezime and soba=@stara_soba)
	begin
		update dbo.Profesori set ime=@novo_ime, prezime=@novo_prezime, soba=@nova_soba where ID_Profesor = (select ID_Profesor from dbo.Profesori where ime=@staro_ime and prezime=@staro_prezime and soba=@stara_soba)
	end
	else
		print 'Pogreska profesor '+@staro_ime+' '+@staro_prezime+' ne psotoji'
end
	else
		print 'Pogreska prilikom izmjene podataka profesora'
end try
begin catch
	execute dbo.GetErrorInfo
		if @@TRANCOUNT > 0
		rollback transaction;
end catch;
if @@TRANCOUNT > 0
	commit transaction;
GO
