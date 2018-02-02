SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[spProvjeraTrajanjaUgovoraKraj_Select] (
	@oib varchar(11) null)
as
begin try
set nocount on
begin transaction

--DEKLARACIJA POTREBNIH VARIJABLI
declare @danas date = getdate() +30

	/*
	  - PRIKAZ SVIH UGOVORA ILI UGOVORA ZA ODREDENU OSOBU UKOLIKO JE OSTALO JOS 30 DANA DO KRAJA UGOVORA
	*/

	--AKO SE NE UNESE OIB I OSTALI PODACI
	if (@oib is null)
	begin
		if exists (select * from Osoba o, OsobaFunkcija fo, AppDataFunkcija af, AppDataTipUgovora au where o.PkOsoba=fo.PkOsoba and fo.PkAppDataFunkcija=af.PkAppDataFunkcija  AND fo.PkAppDataTipUgovora=au.PkAppDataTipUgovora and  VrijediDo <= @danas and StatusFunkcije='Aktivno')
		begin
			create table #Tmp_table (Ime varchar(25),Prezime varchar(25), VrstaFunkcije varchar(20), VrijediOd date, VrijediDo date, TipUgovora varchar(20) ,StatusFunkcije varchar(10))
			--insert into #Tmp_table select PkOsobaFunkcija,PkAppDataFunkcija,PkOsoba,PkAppDataTipUgovora,VrijediOd,VrijediDo,StatusFunkcije from OsobaFunkcija where VrijediDo <= @danas and StatusFunkcije='Aktivno'

			insert into #Tmp_table 	select o.Ime, o.Prezime, af.VrstaFunkcije, fo.VrijediOd, fo.VrijediDo, au.TipUgovora, fo.StatusFunkcije 
									from Osoba o, OsobaFunkcija fo ,AppDataFunkcija af, AppDataTipUgovora au
									where o.PkOsoba=fo.PkOsoba and
										  fo.PkAppDataFunkcija=af.PkAppDataFunkcija and
										  fo.PkAppDataTipUgovora=au.PkAppDataTipUgovora and 
										  VrijediDo <= @danas and StatusFunkcije='Aktivno'

			select * from #Tmp_table
			drop table #Tmp_table
		END
        ELSE
			PRINT 'Nema osoba kojima je ugovor pred istekom kroz 30 dana'
	END

	--AKO SE UNESE OIB
	if (@oib is not null and len(@oib) = 11)
	begin
		if exists (select * from Osoba o, OsobaFunkcija fo, AppDataFunkcija af where o.PkOsoba=fo.PkOsoba and fo.PkAppDataFunkcija=af.PkAppDataFunkcija and o.Oib=@oib)
		begin
			select o.Ime, o.Prezime, af.VrstaFunkcije, fo.VrijediOd, fo.VrijediDo, au.TipUgovora, fo.StatusFunkcije 
									from Osoba o, OsobaFunkcija fo ,AppDataFunkcija af, AppDataTipUgovora au
									where o.PkOsoba=fo.PkOsoba and
										  fo.PkAppDataFunkcija=af.PkAppDataFunkcija and
										  fo.PkAppDataTipUgovora=au.PkAppDataTipUgovora and 
										  VrijediDo <= @danas and StatusFunkcije='Aktivno' and
										  o.PkOsoba=(select PkOsoba from Osoba where Oib=@oib)
		END
        ELSE
			PRINT 'Osobi oib-a '+@oib+' ne istjece ugovor kroz 30 dana'
	END
end try
begin catch
	execute dbo.GetErrorInfo;
	if @@TRANCOUNT > 0
		rollback transaction;
end catch;
if @@TRANCOUNT > 0
	commit transaction;
GO
