SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[spAzuriranjeUgovora_Combo](
	@oib VARCHAR(11),
	@funkcija VARCHAR(20),
	@ugovor VARCHAR(20),
	@pocetak_ugovora DATE,
	
	@tip_ugovora VARCHAR(20),
	
	@status_ugovora VARCHAR(20))
AS
BEGIN TRY
set nocount on
begin transaction

declare @ime varchar(25)
declare @prezime varchar(25)
declare @funk varchar(20)
declare @kraj_ugovora date
declare @status varchar(20)
declare @info varchar(20)
declare @trajanje INT
DECLARE @pkosoba int

if (@oib ='') select @oib = null
if (@funkcija ='') select @funkcija = null
if (@ugovor ='') select @ugovor = null
if (@pocetak_ugovora ='') select @pocetak_ugovora = null

select @ugovor=upper(@ugovor)
select @funkcija=upper(@funkcija)

if (upper(@ugovor)='POSTOJECI' and (@tip_ugovora ='' or @tip_ugovora is null)) select @tip_ugovora=(select TipUgovora from AppDataTipUgovora where PkAppDataTipUgovora=(select PkAppDataTipUgovora from OsobaFunkcija where PkOsoba=(select PkOsoba from Osoba where Oib=@oib and PkAppDataOsoba = 1 and PkOsobaOpis in (1,2,4))))
if (upper(@ugovor)='POSTOJECI' and (@funkcija ='' or @funkcija is null)) select @funkcija=(select VrstaFunkcije from AppDataFunkcija where PkAppDataFunkcija=(select PkAppDataFunkcija from OsobaFunkcija where PkOsoba=(select PkOsoba from Osoba where Oib=@oib and PkAppDataOsoba = 1 and PkOsobaOpis in (1,2,4))))
if (upper(@status_ugovora) = 'NEAKTIVNO') select @status_ugovora='Neaktivno' ELSE SELECT @status_ugovora=NULL

IF(LEN(@oib) = 11 AND
   --len(@status_ugovora) <= 20 and
   --isdate(cast(@pocetak_ugovora as varchar(10))) = 1 and
   --len(@ugovor) <= 20 and
   LEN(@funkcija) <= 20)
BEGIN
	IF EXISTS (SELECT * FROM OsobaFunkcija WHERE PkOsoba=(SELECT PkOsoba FROM Osoba WHERE Oib=@oib AND PkAppDataOsoba=1 AND PkOsobaOpis IN (1,2,4)))
	BEGIN
		select @ime=(select Ime from Osoba where Oib=@oib and PkAppDataOsoba=1 and PkOsobaOpis in (1,2,4))
		select @prezime=(select Prezime from Osoba where Oib=@oib and PkAppDataOsoba=1 and PkOsobaOpis in (1,2,4))
		select @funk=(select VrstaFunkcije from AppDataFunkcija where PkAppDataFunkcija=(select PkAppDataFunkcija from OsobaFunkcija where PkOsoba=(select PkOsoba from Osoba where Oib=@oib and PkAppDataOsoba=1 and PkOsobaOpis in (1,2,4))))

		IF (@status_ugovora='Neaktivno')
		BEGIN
			IF ((SELECT PkosobaOpis FROM Osoba WHERE Oib=@oib) IN (1,2))
			begin
				update OsobaFunkcija set StatusFunkcije=@status_ugovora where PkOsoba=(select PkOsoba from Osoba where Oib=@oib and PkAppDataOsoba=1 and PkOsobaOpis in (1,2))
				delete OsobaFunkcija where PkOsoba=(select PkOsoba from Osoba where Oib=@oib and PkAppDataOsoba=1 and PkOsobaOpis in (1,2))
				PRINT 'Profesor/Asistent '+@ime+' '+@prezime+' je dobio otkaz kao '+@funk
			END
			ELSE
			BEGIN
				update OsobaFunkcija set StatusFunkcije=@status_ugovora where PkOsoba=(select PkOsoba from Osoba where Oib=@oib and PkAppDataOsoba=1 and PkOsobaOpis = 4)
				update Osoba set PkAppDataOsoba=2 where Oib=@oib and PkOsobaOpis=4
				DELETE OsobaFunkcija WHERE PkOsoba=(SELECT PkOsoba FROM Osoba WHERE Oib=@oib AND PkAppDataOsoba=2 AND PkOsobaOpis = 4)
				PRINT @funk+' '+@ime+' '+@prezime+' je dobio otkaz'
			END		
		END

		IF (ISDATE(CAST(@pocetak_ugovora AS VARCHAR(10))) = 1 AND LEN(@ugovor) <= 20)
		BEGIN
			IF (@ugovor='NOVI' OR @ugovor='POSTOJECI')
			BEGIN
				SELECT @pkosoba=(SELECT PkOsoba FROM Osoba WHERE Oib=@oib AND PkAppDataOsoba=1 AND PkOsobaOpis IN (1,2,4))

				SELECT @info=(SELECT TrajanjeUgovora FROM AppDataTipUgovora WHERE TipUgovora=@tip_ugovora)
				SELECT @trajanje=SUBSTRING(@info, PATINDEX('%[0-9]%', @info), PATINDEX('%[0-9][^0-9]%', @info + 't') - PATINDEX('%[0-9]%', @info) + 1)
			
				SELECT @kraj_ugovora=@pocetak_ugovora
				SELECT @kraj_ugovora=DATEADD(MONTH, @trajanje, @kraj_ugovora)

				IF (@pocetak_ugovora < GETDATE())
							SELECT @status = 'Aktivno'
						ELSE
							SELECT @status = 'Neaktivno'
				
				DELETE FROM OsobaFunkcija WHERE PkOsoba=(SELECT PkOsoba FROM Osoba WHERE Oib=@oib AND PkAppDataOsoba=1 AND PkOsobaOpis IN (1,2,4))

				INSERT INTO OsobaFunkcija (PkAppDataFunkcija,PkOsoba,PkAppDataTipUgovora,VrijediOd,VrijediDo,StatusFunkcije)
				VALUES ((SELECT PkAppDataFunkcija FROM AppDataFunkcija WHERE UPPER(VrstaFunkcije)=UPPER(@funkcija)),
						@pkosoba,
						(SELECT PkAppDataTipUgovora FROM AppDataTipUgovora WHERE UPPER(TipUgovora)=UPPER(@tip_ugovora)),
						@pocetak_ugovora,
						@kraj_ugovora,
						@status)

				PRINT 'Osoba '+@ime+' '+@prezime+' ima novi ugovor'
			END
			ELSE
				PRINT 'Tip ugovora nije NOVI ili POSTOJECI'
		END
	END
	ELSE
		PRINT 'Osoba ne postoji ili je neaktivna'
END
ELSE
	PRINT 'Pogreska ulaznih parametara'
END TRY
BEGIN CATCH
	EXECUTE dbo.GetErrorInfo;
	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;
END CATCH;
IF @@TRANCOUNT > 0
	COMMIT TRANSACTION;
GO
