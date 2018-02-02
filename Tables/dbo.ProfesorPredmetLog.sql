CREATE TABLE [dbo].[ProfesorPredmetLog]
(
[PkProfesorPredmetLog] [int] NOT NULL IDENTITY(1, 1),
[PkProfesorPredmet] [int] NULL,
[PkOsoba] [int] NULL,
[PkPredmet] [int] NULL,
[Radnja] [varchar] (10) COLLATE Croatian_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProfesorPredmetLog] ADD CONSTRAINT [PK_ProfesorPredmetLog] PRIMARY KEY CLUSTERED  ([PkProfesorPredmetLog]) ON [PRIMARY]
GO
