CREATE TABLE [dbo].[AppDataIspit]
(
[PkAppDataIspit] [int] NOT NULL IDENTITY(1, 1),
[TipIspit] [varchar] (20) COLLATE Croatian_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AppDataIspit] ADD CONSTRAINT [PK_AppDataIspit_1] PRIMARY KEY CLUSTERED  ([PkAppDataIspit]) ON [PRIMARY]
GO
