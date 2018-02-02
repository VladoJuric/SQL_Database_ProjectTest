SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[update_predmet](
	@stari_predmet varchar(50),
	@novi_predmet varchar(50),
	@novi_opis varchar(500))
as
begin try
set nocount on
begin transaction

if(len(@stari_predmet) <= 50 and len(@novi_predmet) <= 50 and len(@novi_opis) <= 500)
begin
	if exists (select * from dbo.Predmeti where predmet=@stari_predmet)
	begin
		update dbo.Predmeti set predmet=@novi_predmet, opis=@novi_opis where ID_Predmet = (select ID_Predmet from dbo.Predmeti where predmet=@stari_predmet)
	end
	else
		print 'Pogreska predmet '+@stari_predmet+' ne postoji'
end
	else
		print 'Pogreska prilikom izmjene podataka predmeta'
end try
begin catch
	execute dbo.GetErrorInfo
		if @@TRANCOUNT > 0
		rollback transaction;
end catch;
if @@TRANCOUNT > 0
	commit transaction;
GO
