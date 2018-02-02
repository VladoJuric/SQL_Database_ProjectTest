SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[delete_student](
	@ime varchar(50),
	@prezime varchar(50))
as
begin try
set nocount on
begin transaction

if(len(@ime) <= 50 and len(@prezime) <= 50)
begin
declare @stud_id int
declare @pred_id int
declare @prof_id int
declare @prof_ime varchar(50)
declare @prof_prezime varchar(50)
declare @predmet varchar(50)
declare @opis varchar(500)

	if exists (select * from dbo.NewStudenti where ime=@ime and prezime=@prezime)
	begin
		select @stud_id=ID_Student from dbo.NewStudenti where ime = @ime and prezime = @prezime
		select @pred_id=ID_Predmet from dbo.StudentPredmet where ID_Student = @stud_id

		delete from dbo.StudentPredmet where ID_Student = @stud_id

		if not exists (select * from dbo.StudentPredmet where ID_Predmet = @pred_id)
		begin
			select @predmet=predmet from dbo.Predmeti where ID_Predmet = @pred_id
			select @opis=opis from dbo.Predmeti where ID_Predmet = @pred_id

			select @prof_id = ID_Profesor from dbo.Predmeti where ID_Predmet = @pred_id

			delete from dbo.Predmeti where ID_Predmet = @pred_id

			print 'Izbrisan predmet '+@predmet+', '+@opis+' posto nema studenata na kolegiju' 

			if not exists (select * from dbo.Predmeti where ID_Profesor = @prof_id)
			begin
				select @prof_ime=ime from dbo.Profesori where ID_Profesor=@prof_id
				select @prof_prezime=prezime from dbo.Profesori where ID_Profesor=@prof_id

				delete from dbo.Profesori where ID_Profesor = @prof_id

				print 'Izbrisan Profesor '+@prof_ime+' '+@prof_prezime+' posto nema predmeta kojih predaje' 
			end
		end

		delete from dbo.NewStudenti where ime=@ime and prezime=@prezime
	end
	else
		print 'Pogreska student '+@ime+' '+@prezime+' ne postoji'
end
else
	print 'Pogreska prilikom unosa podataka za brisanje studenta'
end try
begin catch
	execute dbo.GetErrorInfo

	if(xact_state() = -1)
	begin
		print 'Rollback delete student'
		rollback transaction;
	end

	if(xact_state() = 1)
	begin
		print 'Student is deleted'
		commit transaction;
	end
end catch
GO
