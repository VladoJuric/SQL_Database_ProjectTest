CREATE TABLE [dbo].[PredmetLog]
(
[PkPredmetLog] [int] NOT NULL IDENTITY(1, 1),
[PkPredmet] [int] NULL,
[PkSmjer] [int] NULL,
[PkSemestar] [int] NULL,
[Predmet] [varchar] (50) COLLATE Croatian_CI_AS NULL,
[Opis] [varchar] (500) COLLATE Croatian_CI_AS NULL,
[Radnja] [varchar] (10) COLLATE Croatian_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PredmetLog] ADD CONSTRAINT [PK_PredmetLog] PRIMARY KEY CLUSTERED  ([PkPredmetLog]) ON [PRIMARY]
GO
