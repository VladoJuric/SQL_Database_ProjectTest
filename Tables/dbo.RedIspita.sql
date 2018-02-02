CREATE TABLE [dbo].[RedIspita]
(
[PkRedIspita] [int] NOT NULL IDENTITY(1, 1),
[PkAppDataIspit] [int] NOT NULL,
[Semestar] [smallint] NOT NULL,
[DatumIspita] [date] NOT NULL,
[Godina] [varchar] (9) COLLATE Croatian_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RedIspita] ADD CONSTRAINT [PK_RedIspita] PRIMARY KEY CLUSTERED  ([PkRedIspita]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RedIspita] ADD CONSTRAINT [FK_RedIspita_AppDataIspit] FOREIGN KEY ([PkAppDataIspit]) REFERENCES [dbo].[AppDataIspit] ([PkAppDataIspit])
GO
