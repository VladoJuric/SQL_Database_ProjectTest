SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vPregledSvihNekadZaposlenihKrozPeriod]
AS
SELECT o.Ime,o.Prezime,o.GodinaRodenja,af.VrstaFunkcije,au.TipUgovora,ofl.VrijediOd,ofl.VrijediDo,ofl.DatumBrisanja,ofl.StatusFunkcije,ofl.Radnja
FROM dbo.OsobaFunkcijaLog ofl, dbo.Osoba o, dbo.AppDataFunkcija af, dbo.AppDataTipUgovora au
WHERE ofl.PkOsoba=o.PkOsoba AND ofl.PkAppDataFunkcija=af.PkAppDataFunkcija AND ofl.PkAppDataTipUgovora=au.PkAppDataTipUgovora



GO
