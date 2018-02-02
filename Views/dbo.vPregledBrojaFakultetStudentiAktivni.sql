SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[vPregledBrojaFakultetStudentiAktivni]
as
select distinct (select count(o.oib) from Osoba o, OsobaFunkcija fo, AppDataFunkcija af where o.PkOsoba=fo.PkOsoba and fo.PkAppDataFunkcija=af.PkAppDataFunkcija and o.PkAppDataOsoba=1 and o.PkOsobaOpis = 4 and af.VrstaFunkcije = 'Dekan') as broj_dekana,
				(select count(o.oib) from Osoba o, OsobaFunkcija fo, AppDataFunkcija af where o.PkOsoba=fo.PkOsoba and fo.PkAppDataFunkcija=af.PkAppDataFunkcija and o.PkAppDataOsoba=1 and o.PkOsobaOpis = 4 and af.VrstaFunkcije = 'Prodekan') as broj_prodekana,
				(select count(oib) from Osoba where  PkAppDataOsoba=1 and PkOsobaOpis = 1) as broj_asistenata,
				(select count(oib) from Osoba where PkAppDataOsoba=1 and PkOsobaOpis = 2) as broj_profesora,
				(select count(oib) from Osoba where PkAppDataOsoba=1 and PkOsobaOpis = 3) as broj_studenata,
				(select count(o.oib) from Osoba o, OsobaFunkcija fo, AppDataFunkcija af where o.PkOsoba=fo.PkOsoba and fo.PkAppDataFunkcija=af.PkAppDataFunkcija and o.PkAppDataOsoba=1 and o.PkOsobaOpis = 4 and af.VrstaFunkcije = 'Portir') as broj_portira,
				(select count(o.oib) from Osoba o, OsobaFunkcija fo, AppDataFunkcija af where o.PkOsoba=fo.PkOsoba and fo.PkAppDataFunkcija=af.PkAppDataFunkcija and o.PkAppDataOsoba=1 and o.PkOsobaOpis = 4 and af.VrstaFunkcije = 'Domar') as broj_domara,
				(select count(o.oib) from Osoba o, OsobaFunkcija fo, AppDataFunkcija af where o.PkOsoba=fo.PkOsoba and fo.PkAppDataFunkcija=af.PkAppDataFunkcija and o.PkAppDataOsoba=1 and o.PkOsobaOpis = 4 and af.VrstaFunkcije = 'Cistac') as broj_cistaca,
				(select count(oib) from Osoba where PkAppDataOsoba=1 and PkOsobaOpis in (4)) as ukupno_zaposlanih,
				(select count(oib) from Osoba where PkAppDataOsoba=1 and PkOsobaOpis in (1,2)) as ukupno_profesora,
				(select count(oib) from Osoba where PkAppDataOsoba=1 and PkOsobaOpis in (3)) as ukupno_studenata,
				(select count(oib) from Osoba where PkAppDataOsoba=1 and PkOsobaOpis in (1,2,3,4)) as ukupno_svih

GO
