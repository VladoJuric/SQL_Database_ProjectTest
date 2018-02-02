SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[insert_all_data] (
	@s_ime varchar(50), 
	@s_prez varchar(50),
	@s_datum varchar(10),
	@s_grad varchar(50),
	@s_drzava varchar(50), 
	@pr_predm varchar(50),
	@pr_opis varchar(500),
	@p_ime varchar(50),
	@p_prez varchar(50),
	@p_soba int,
	@s_ocjena smallint)
as
begin try
set nocount on
begin transaction

if(len(@s_ime) <= 50 and
   len(@s_prez) <= 50 and
   len(@s_datum) <= 10 and
   len(@s_grad) <= 50 and
   len(@s_drzava) <= 50 and
   len(@pr_predm) <= 50 and
   len(@pr_opis) <= 500 and
   len(@p_ime) <= 50 and
   len(@p_prez) <= 50 and
   @p_soba > 0 and
   @s_ocjena > 0 and @s_ocjena < 6)
begin
	if(isnumeric(@s_ime) <= 0 and 
	   isnumeric(@s_prez) <= 0 and 
	   isnumeric(@p_ime) <= 0 and 
	   isnumeric(@p_prez) <= 0 and 
	   isnumeric(@s_grad) <= 0 and 
	   isnumeric(@s_drzava) <= 0)
	   begin
			if not exists (select * from dbo.NewStudenti where ime = @s_ime and prezime = @s_prez)
			begin
				set dateformat dmy
				if(isdate(@s_datum) = 1)
				begin
					insert into dbo.NewStudenti (ime,prezime,datum_rodenja,grad,drzava) values(@s_ime,@s_prez,@s_datum,@s_grad,@s_drzava)
					--insert into dbo.Studenti (ime,prezime,datum_rodenja) values(@s_ime,@s_prez,@s_datum)
					--insert into dbo.Drzava (grad,drzava,ID_Student) values(@s_grad,@s_drzava,(select ID_Student from dbo.Studenti where ime=@s_ime and prezime=@s_prez and datum_rodenja=@s_datum))
				end
				else
				begin
					print 'Greska !!! Datum rodenja studenta nije u ispravnom formatu (**/**/****)'
				end
			end
			else
				print 'Student '+@s_ime+' '+@s_prez+' nije unesen u sustav vec postoji u sustavu !!!'
		
			if not exists (select * from dbo.Profesori where ime=@p_ime and prezime=@p_prez and soba=@p_soba)
			begin
				insert into dbo.Profesori (ime,prezime,soba) values(@p_ime,@p_prez,@p_soba)
			end
			else
			begin
				print 'Profesor '+@p_ime+' '+@p_prez+' nije unesen u sustav vec postoji u sustavu !!!'
			end

			if not exists (select * from dbo.Predmeti where predmet=@pr_predm)
			begin
				insert into dbo.Predmeti (predmet,opis,ID_Profesor) values(@pr_predm,@pr_opis,(select ID_Profesor from dbo.Profesori where ime=@p_ime and prezime=@p_prez and soba=@p_soba))
			end
			else
			begin
				print 'Predmet '+@pr_predm+' nije unesen u sustav vec postoji u sustavu !!!'
			end

			insert into dbo.StudentPredmet(ID_Predmet,ID_Student,ocjena) values((select ID_Predmet from dbo.Predmeti where predmet=@pr_predm),(select ID_Student from dbo.NewStudenti where ime=@s_ime and prezime=@s_prez),@s_ocjena)
		
		end
		else
			print 'Pogreska u unosu (unjeli ste broj umijesto slova)'
end
else
	print 'Pogreska u unosu (unjeli ste preduge podatke (max 50 slova, 10 brojeva, ocjena od 1 do 5 ))'
end try
begin catch
	execute dbo.GetErrorInfo;
	if @@TRANCOUNT > 0
		rollback transaction;
end catch;
if @@TRANCOUNT > 0
	commit transaction;
GO
