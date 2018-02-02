CREATE TABLE [dbo].[OsobaLog]
(
[PkOsobaLog] [int] NOT NULL IDENTITY(1, 1),
[PkOsoba] [int] NULL,
[PkOsobaOpis] [int] NULL,
[PkAppDataOsoba] [int] NULL,
[Oib] [varchar] (11) COLLATE Croatian_CI_AS NULL,
[Ime] [nchar] (25) COLLATE Croatian_CI_AS NULL,
[Prezime] [varchar] (25) COLLATE Croatian_CI_AS NULL,
[GodinaRodenja] [date] NULL,
[DatumUpisa] [date] NULL,
[Grad] [varchar] (30) COLLATE Croatian_CI_AS NULL,
[Drzava] [varchar] (30) COLLATE Croatian_CI_AS NULL,
[Radnja] [varchar] (10) COLLATE Croatian_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[OsobaLog] ADD CONSTRAINT [PK_OsobaLog] PRIMARY KEY CLUSTERED  ([PkOsobaLog]) ON [PRIMARY]
GO
