SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[insert_predmet_profesoru] (
	@ime varchar(50),
	@prez varchar(50),
	@soba int,
	@predmet varchar(50),
	@opis varchar(500))
as
begin try
set nocount on
begin transaction

if(len(@ime) <= 50 and 
   len(@prez) <= 50 and
   isnumeric(@ime) <= 0 and
   isnumeric(@prez) <= 0 and
   len(@predmet) <= 50 and
   len(@opis) <= 500 and
   @soba > 0)
begin
	if not exists (select * from dbo.Predmeti where predmet=@predmet and opis=@opis)
	begin
		if exists (select * from dbo.Profesori where ime=@ime and prezime=@prez and soba=@soba)
		begin
			insert into dbo.Predmeti (predmet,opis,ID_Profesor) values(@predmet,@opis,(select ID_Profesor from dbo.Profesori where ime=@ime and prezime=@prez and soba=@soba))
		end
	end
	else
		print 'Pogreska u unosu predmeta '+@predmet+' i opisa '+@opis
end
end try
begin catch
	if @@TRANCOUNT > 0
		rollback transaction;
end catch;
if @@TRANCOUNT > 0
	commit transaction;
GO
