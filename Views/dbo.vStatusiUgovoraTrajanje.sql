SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE view [dbo].[vStatusiUgovoraTrajanje]
as
select o.Ime, o.Prezime, af.VrstaFunkcije, fo.VrijediOd, fo.VrijediDo, au.TipUgovora, fo.StatusFunkcije 
from Osoba o, OsobaFunkcija fo ,AppDataFunkcija af, AppDataTipUgovora au
where o.PkOsoba=fo.PkOsoba and
	  fo.PkAppDataFunkcija=af.PkAppDataFunkcija and
	  fo.PkAppDataTipUgovora=au.PkAppDataTipUgovora
GO
