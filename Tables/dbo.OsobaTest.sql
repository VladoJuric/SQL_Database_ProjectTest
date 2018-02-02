CREATE TABLE [dbo].[OsobaTest]
(
[PkOsoba] [float] NULL,
[PkOsobaOpis] [float] NULL,
[PkAppDataOsoba] [float] NULL,
[Oib] [float] NULL,
[Ime] [nvarchar] (255) COLLATE Croatian_CI_AS NULL,
[Prezime] [nvarchar] (255) COLLATE Croatian_CI_AS NULL,
[GodinaRodenja] [date] NULL,
[DatumUpisa] [date] NULL,
[Grad] [nvarchar] (255) COLLATE Croatian_CI_AS NULL,
[Drzava] [nvarchar] (255) COLLATE Croatian_CI_AS NULL,
[ZavrsnaOcjena] [nvarchar] (255) COLLATE Croatian_CI_AS NULL
) ON [PRIMARY]
GO
