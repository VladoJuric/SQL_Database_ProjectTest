CREATE TABLE [dbo].[Semestar]
(
[PkSemestar] [int] NOT NULL IDENTITY(1, 1),
[Semestar] [varchar] (20) COLLATE Croatian_CI_AS NOT NULL,
[DatumPocetka] [date] NOT NULL,
[DatumKraja] [date] NOT NULL,
[Godina] [varchar] (9) COLLATE Croatian_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Semestar] ADD CONSTRAINT [PK_Semestar] PRIMARY KEY CLUSTERED  ([PkSemestar]) ON [PRIMARY]
GO
