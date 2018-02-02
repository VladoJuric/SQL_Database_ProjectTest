CREATE TABLE [dbo].[AppDataOsoba]
(
[PkAppDataOsoba] [int] NOT NULL IDENTITY(1, 1),
[StatusAktivnosti] [varchar] (2) COLLATE Croatian_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AppDataOsoba] ADD CONSTRAINT [PK_AppDataOsoba] PRIMARY KEY CLUSTERED  ([PkAppDataOsoba]) ON [PRIMARY]
GO
