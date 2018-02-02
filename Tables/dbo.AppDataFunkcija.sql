CREATE TABLE [dbo].[AppDataFunkcija]
(
[PkAppDataFunkcija] [int] NOT NULL IDENTITY(1, 1),
[VrstaFunkcije] [varchar] (20) COLLATE Croatian_CI_AS NOT NULL,
[OpisFunkcije] [varchar] (500) COLLATE Croatian_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AppDataFunkcija] ADD CONSTRAINT [PK_AppDataFunkcija] PRIMARY KEY CLUSTERED  ([PkAppDataFunkcija]) ON [PRIMARY]
GO
