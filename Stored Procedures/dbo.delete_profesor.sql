SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[delete_profesor](
	@ime varchar(50),
	@prezime varchar(50),
	@soba smallint)
as
begin try
set nocount on
begin transaction

if(len(@ime) <= 50 and len(@prezime) <= 50 and @soba > 0)
begin
declare @prof_id int
	if exists (select * from dbo.Profesori where ime=@ime and prezime=@prezime and soba=@soba)
	begin
		select @prof_id=ID_Profesor from dbo.Profesori where ime=@ime and prezime=@prezime and soba=@soba

		if exists (select * from dbo.Predmeti where ID_Profesor=@prof_id)
		begin
			delete from dbo.Predmeti where ID_Profesor=@prof_id
			print 'Izbrisani predmeti profesora '+@ime+' '+@prezime 
		end

		delete from dbo.Profesori where ID_Profesor=@prof_id
		print 'Izbrisan profesor '+@ime+' '+@prezime
	end
	else
		print 'Pogreska profesor '+@ime+' '+@prezime+' ne postoji'
end
end try
begin catch
	execute dbo.GetErrorInfo
	if(xact_state() = -1)
	begin
		print 'Rollback delete profesor'
		rollback transaction;
	end
	if(xact_state() = 1)
	begin
		print 'Profesor is deleted'
		commit transaction;
	end
end catch
GO
