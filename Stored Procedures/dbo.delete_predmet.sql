SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[delete_predmet](
	@predmet varchar(50),
	@opis varchar(500))
as
begin try
set nocount on
begin transaction

if(len(@predmet) <= 50 and len(@opis) <= 500)
begin
declare @prof_id int
declare @ime varchar(50)
declare @prezime varchar(50)
declare @pred_id int
declare @ispis varchar(500)
declare @count int
declare @max int

	if exists (select * from dbo.Predmeti where predmet=@predmet)
	begin
		select @prof_id = ID_Profesor from dbo.Predmeti where predmet=@predmet
		select @pred_id = ID_Predmet from dbo.Predmeti where predmet=@predmet

		delete from dbo.Predmeti where predmet = @predmet

		if not exists (select * from dbo.Predmeti where ID_Profesor=@prof_id)
		begin
			select @ime=ime from dbo.Profesori where ID_Profesor=@prof_id
			select @prezime=prezime from dbo.Profesori where ID_Profesor=@prof_id

			delete from dbo.Profesori where ID_Profesor = @prof_id

			print 'Izbrisan profesor '+@ime+' '+@prezime+' posto ne predaje nijedan predmet'
		end

		if exists (select * from dbo.StudentPredmetTest where ID_Predmet =  @pred_id)
		begin
			delete from dbo.StudentPredmetTest  where ID_Predmet = @pred_id

			select @max = max(ID_Student) from dbo.StudentPredmetTest where ID_Predmet = @pred_id
			select @count = min(ID_Student) from dbo.StudentPredmetTest where ID_Predmet = @pred_id
			select @ispis = 'S predmeta '+@predmet+', izbrisani su studenti: '
			
			while(@count <= @max)
			begin
				if exists (select * from dbo.NewStudenti where ID_Student = @count)
					select @ispis = @ispis + (select ime from dbo.NewStudenti where ID_Student = @count) + ' ' + (select prezime from dbo.NewStudenti where ID_Student = @count) + ', '
				select @count = @count + 1
			end

			print @ispis
			--print 'S predemta '+@predmet+' izbrisani su studenti '+@ select ime, prezime from dbo.NewStudenti where ID_Student in (select ID_Student from dbo.StudentPredmet where ID_Predmet = @pred_id)
		end
	end
	else
		print 'Pogreska predmet '+@predmet+', '+@opis+' ne postoji'
	--commit transaction;
end
else
	print 'Pogreska prilikom unosa predmeta'
end try
begin catch
	execute dbo.GetErrorInfo

	if(xact_state() = -1)
	begin
		print 'Rollback delete predmet'
		rollback transaction;
	end

	if(xact_state() = 1)
	begin
		print 'Predmet is deleted'
		commit transaction;
	end
end catch
GO
