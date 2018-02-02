SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[spReferadaNoviDatumIspita_Insert] (
		@tip varchar(20),
		@datum date,
		@fakultetska_godina varchar(9))
as
begin try
set nocount on
begin transaction
DECLARE @semestar SMALLINT

if (@tip ='') select @tip = null
if (@datum ='') select @datum = null
if (@fakultetska_godina ='') select @fakultetska_godina = null
IF (UPPER(@tip) = 'PROMOCIJA') SELECT @datum = DATEADD(YEAR,-1,@datum)
IF (@datum BETWEEN (SELECT DatumPocetka FROM dbo.Semestar WHERE semestar = '1. Semestar' AND Godina=@fakultetska_godina) AND ((SELECT DatumKraja FROM dbo.Semestar WHERE semestar = '1. Semestar' AND Godina=@fakultetska_godina))) SELECT @semestar=1 
ELSE IF (@datum BETWEEN (SELECT DatumPocetka FROM dbo.Semestar WHERE semestar = '2. Semestar' AND Godina=@fakultetska_godina) AND ((SELECT DatumKraja FROM dbo.Semestar WHERE semestar = '2. Semestar' AND Godina=@fakultetska_godina))) SELECT @semestar=2 
ELSE SELECT @semestar=0

--PROVJERA UNESENIH PODATAKA
if(len(@tip) <= 20 and
   isdate(cast(@datum as varchar(10))) = 1 and
   len(@fakultetska_godina) = 9)
begin
	/*
	  - PROCEDURE PROVJERAVA I AZURIRA DATUM POJEDINIH ISPITA OVISNO O SEMESTRU, SAMA RADI KALKULACIJU DALI SE MIJENJA DATUM
	    U 1. SEMSETRU ILI U 2. SEMSETRU OVISNO U ULAZNOM PARAMETRU DATUM
	    TAKODER SE PROVJERAVA UNOS ULAZNIH PARAMETARA TE SE ISPISUJE GRESKA UKOLIKO PARAMETRI NISU VALJANO UNESENI
	  - UKOLIKO DODE DO NEKE NE NAVEDENE GRESKE TAKODER ISPISUJE O KOJOJ SE GRESCI RADI
	*/
	--if ((select COUNT(ri.PkRedIspita) from AppDataIspit ai, RedIspita ri where ai.PkAppDataIspit=ri.PkAppDataIspit and upper(ai.TipIspit)=upper(@tip) and upper(ri.Godina)=upper(@fakultetska_godina) AND ri.Semestar=1) < 2 OR (select COUNT(ri.PkRedIspita) from AppDataIspit ai, RedIspita ri where ai.PkAppDataIspit=ri.PkAppDataIspit and upper(ai.TipIspit)=upper(@tip) and upper(ri.Godina)=upper(@fakultetska_godina) AND ri.Semestar=2  ) < 1)
	IF NOT EXISTS (SELECT * FROM dbo.RedIspita WHERE Semestar = @semestar AND Godina=@fakultetska_godina AND PkAppDataIspit=(SELECT PkAppDataIspit FROM dbo.AppDataIspit WHERE UPPER(TipIspit)=UPPER(@tip)))
	BEGIN
		if (upper(@tip) = 'PROMOCIJA' and @datum > (select DatumPocetka from Semestar where Semestar = '1. Semestar' and Godina=@fakultetska_godina) and @datum < (select DatumKraja from Semestar where Semestar = '2. Semestar' and Godina=@fakultetska_godina))
		BEGIN
			SELECT @datum=DATEADD(YEAR,1,@datum)

			INSERT into RedIspita (PkAppDataIspit,DatumIspita,Godina) values((select PkAppDataIspit from AppDataIspit where upper(TipIspit)=upper(@tip)),@datum,@fakultetska_godina)
			--update RedIspita set DatumIspita=@datum where PkAppDataIspit = (select PkAppDataIspit from AppDataIspit where upper(AppDataIspit) = upper(@tip))
			print 'Datum nove promocije za godinu '+@fakultetska_godina+' je '+cast(@datum as varchar(10))
		end
		else if (upper(@tip) in ('PRVI KOLOKVIJ','DRUGI KOLOKVIJ','PRVI ISPITNI ROK') and @datum > (select DatumPocetka from Semestar where Semestar = '1. Semestar' and Godina=@fakultetska_godina) and @datum < (select DatumKraja from Semestar where Semestar = '1. Semestar' and Godina=@fakultetska_godina))
		begin
			insert into RedIspita (PkAppDataIspit,Semestar,DatumIspita,Godina) values((select PkAppDataIspit from AppDataIspit where upper(TipIspit)=upper(@tip)),1,@datum,@fakultetska_godina)
			--update RedIspita set DatumIspita=@datum 
			--where DatumIspita > (select DatumPocetka from Semestar where Semestar = '1. Semestar') and 
			--	  DatumIspita < (select DatumKraja from Semestar where Semestar = '1. Semestar') and 
			--	  PkAppDataIspit = (select PkAppDataIspit from AppDataIspit where upper(TipIspit) = upper(@tip))
			print 'Datum ispita '+@tip+' u 1. Semestru za godinu '+@fakultetska_godina+' je postavljen na datum '+cast(@datum as varchar(10))
		end
		else if (upper(@tip) in ('PRVI KOLOKVIJ','DRUGI KOLOKVIJ','PRVI ISPITNI ROK','DRUGI ISPITNI ROK','TRECI ISPITNI ROK','DEKANSKI ROK') and @datum > (select DatumPocetka from Semestar where Semestar = '2. Semestar' and Godina=@fakultetska_godina) and @datum < (select DatumKraja from Semestar where Semestar = '2. Semestar' and Godina=@fakultetska_godina))
		begin
			insert into RedIspita (PkAppDataIspit,Semestar,DatumIspita,Godina) values((select PkAppDataIspit from AppDataIspit where upper(TipIspit)=upper(@tip)),2,@datum,@fakultetska_godina)
			--update RedIspita set DatumIspita=@datum 
			--where DatumIspita > (select DatumPocetka from Semestar where Semestar = '2. Semestar') and 
			--	  DatumIspita < (select DatumKraja from Semestar where Semestar = '2. Semestar') and 
			--	  PkAppDataIspit = (select PkAppDataIspit from AppDataIspit where upper(TipIspit) = upper(@tip))
			print 'Datum ispita '+@tip+' u 2. Semestru za godinu '+@fakultetska_godina+' je postavljen na datum '+cast(@datum as varchar(10))

		end
		else
			print 'Nisu dodan novi datum za '+@tip+' u godini '+@fakultetska_godina
	end
	else
		print 'Tip ispita '+@tip+' za godinu '+@fakultetska_godina+' vec postoji u sustavu ili ne postoje uneseni semestri za '+@fakultetska_godina+' godinu, pokrenite proceduru NoviDatumSemestra'
end
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
