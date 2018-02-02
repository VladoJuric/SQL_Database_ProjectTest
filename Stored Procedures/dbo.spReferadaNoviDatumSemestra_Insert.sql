SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[spReferadaNoviDatumSemestra_Insert] (
	@semestar varchar(20),
	@datum_pocetka date,
	@datum_kraja date,
	@fakultetska_godina varchar(9))
as
begin try
set nocount on
begin transaction

if (@semestar ='') select @semestar = null
if (@datum_pocetka ='') select @datum_pocetka = null
if (@datum_kraja ='') select @datum_kraja = null
if (@fakultetska_godina ='') select @fakultetska_godina = null

--PITAT ZA PROVJERU ULAZNIH PARAMETARA DATUM !!!!!!!!!!!
--PROVJERA UNESENIH PODATAKA
if(len(@semestar) <= 20 and
   isdate(cast(@datum_pocetka as varchar(10))) = 1 and
   isdate(cast(@datum_kraja as varchar(10))) = 1 and
   @fakultetska_godina = 9)
begin
	/*
	  - PROCEDURA UNOSI NOVI DATUMA POCETKA I KRAJA ZA POJEDNIN SEMSETAR
	*/
	select @semestar=upper(@semestar)

	IF (@semestar IN ('1. SEMESTAR','2. SEMESTAR'))
	begin
		if not exists (select * from Semestar where upper(Semestar) = upper(@semestar) and Godina=@fakultetska_godina)
		begin
			if (@semestar = '1. SEMESTAR')
			begin
				select @semestar = '1. Semestar'
				insert into Semestar (Semestar,DatumPocetka,DatumKraja,Godina) values(@semestar,@datum_pocetka,@datum_kraja,@fakultetska_godina)
				select @semestar = '3. Semestar'
				insert into Semestar (Semestar,DatumPocetka,DatumKraja,Godina) values(@semestar,@datum_pocetka,@datum_kraja,@fakultetska_godina)
				select @semestar = '5. Semestar'
				insert into Semestar (Semestar,DatumPocetka,DatumKraja,Godina) values(@semestar,@datum_pocetka,@datum_kraja,@fakultetska_godina)
				select @semestar = '7. Semestar'
				insert into Semestar (Semestar,DatumPocetka,DatumKraja,Godina) values(@semestar,@datum_pocetka,@datum_kraja,@fakultetska_godina)
				select @semestar = '9. Semestar'
				insert into Semestar (Semestar,DatumPocetka,DatumKraja,Godina) values(@semestar,@datum_pocetka,@datum_kraja,@fakultetska_godina)
				--insert into Semestar (Semestar,DatumPocetka,DatumKraja,Godina) select(select Semestar from Semestar where PkSemestar in (1,3,5,7,9)),(select @datum_pocetka) as DatumPocetka,(select @datum_kraja) as DatumKraja,(select @fakultetska_godina) as Godina
				--update Semestar set DatumPocetka=@datum_pocetka, DatumKraja=@datum_kraja where PkSemestar in (1,3,5,7,9)
				print 'Novi datum pocetka i kraja 1. Semestra je dodan'
			end
			if (@semestar = '2. SEMESTAR')
			begin
				select @semestar = '2. Semestar'
				insert into Semestar (Semestar,DatumPocetka,DatumKraja,Godina) values(@semestar,@datum_pocetka,@datum_kraja,@fakultetska_godina)
				select @semestar = '4. Semestar'
				insert into Semestar (Semestar,DatumPocetka,DatumKraja,Godina) values(@semestar,@datum_pocetka,@datum_kraja,@fakultetska_godina)
				select @semestar = '6. Semestar'
				insert into Semestar (Semestar,DatumPocetka,DatumKraja,Godina) values(@semestar,@datum_pocetka,@datum_kraja,@fakultetska_godina)
				select @semestar = '8. Semestar'
				insert into Semestar (Semestar,DatumPocetka,DatumKraja,Godina) values(@semestar,@datum_pocetka,@datum_kraja,@fakultetska_godina)
				select @semestar = '10. Semestar'
				insert into Semestar (Semestar,DatumPocetka,DatumKraja,Godina) values(@semestar,@datum_pocetka,@datum_kraja,@fakultetska_godina)
				--update Semestar set DatumPocetka=@datum_pocetka, DatumKraja=@datum_kraja where PkSemestar in (2,4,6,8,10)
				print 'Novi datum pocetka i kraja 2. Semestra je dodan'
			end
		end
		else
			print 'Pogreska '+@semestar+' za godinu '+@fakultetska_godina+' vec postoji u sustavu'
	END
    ELSE
		PRINT 'Semestar treba biti 1. Semestar ili 2. Semestar'
END
else
	print 'Pogreska ulaznih parametara'
end try
begin catch
	execute dbo.GetErrorInfo;
	if @@TRANCOUNT > 0
		rollback transaction;
end catch;
if @@TRANCOUNT > 0
	commit transaction;


GO
