CREATE TABLE [dbo].[StudentPredmetLog]
(
[PkStudentPredmetLog] [int] NOT NULL IDENTITY(1, 1),
[PkStudentPredmet] [int] NULL,
[PkOsoba] [int] NULL,
[PkPredmet] [int] NULL,
[PkRedIspita] [int] NULL,
[Ocjena] [smallint] NULL,
[BrojIzlazakIspit] [smallint] NULL,
[Radnja] [varchar] (10) COLLATE Croatian_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[StudentPredmetLog] ADD CONSTRAINT [PK_StudentPredmetLog] PRIMARY KEY CLUSTERED  ([PkStudentPredmetLog]) ON [PRIMARY]
GO
