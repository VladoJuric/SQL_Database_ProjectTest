CREATE TABLE [dbo].[OsobaFunkcijaLog]
(
[PkOsobaFunkcijaLog] [int] NOT NULL IDENTITY(1, 1),
[PkOsobaFunkcija] [int] NULL,
[PkAppDataFunkcija] [int] NULL,
[PkOsoba] [int] NULL,
[PkAppDataTipUgovora] [int] NULL,
[VrijediOd] [date] NULL,
[VrijediDo] [date] NULL,
[DatumBrisanja] [date] NULL,
[StatusFunkcije] [varchar] (10) COLLATE Croatian_CI_AS NULL,
[Radnja] [varchar] (10) COLLATE Croatian_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[OsobaFunkcijaLog] ADD CONSTRAINT [PK_OsobaFunkcijaLog] PRIMARY KEY CLUSTERED  ([PkOsobaFunkcijaLog]) ON [PRIMARY]
GO
