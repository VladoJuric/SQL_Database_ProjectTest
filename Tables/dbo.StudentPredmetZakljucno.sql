CREATE TABLE [dbo].[StudentPredmetZakljucno]
(
[PkStudentPredmetZakljucno] [int] NOT NULL IDENTITY(1, 1),
[PkOsoba] [int] NOT NULL,
[PkPredmet] [int] NOT NULL,
[PkRedIspita] [int] NOT NULL,
[ZakljucnaOcjena] [smallint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[StudentPredmetZakljucno] ADD CONSTRAINT [PK_StudentPredmetZakljucno] PRIMARY KEY CLUSTERED  ([PkStudentPredmetZakljucno]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_StudentPredmetZakljucno] ON [dbo].[StudentPredmetZakljucno] ([PkOsoba]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_StudentPredmetZakljucno_1] ON [dbo].[StudentPredmetZakljucno] ([PkPredmet]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_StudentPredmetZakljucno_2] ON [dbo].[StudentPredmetZakljucno] ([PkRedIspita]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[StudentPredmetZakljucno] ADD CONSTRAINT [FK_StudentPredmetZakljucno_Osoba] FOREIGN KEY ([PkOsoba]) REFERENCES [dbo].[Osoba] ([PkOsoba])
GO
ALTER TABLE [dbo].[StudentPredmetZakljucno] ADD CONSTRAINT [FK_StudentPredmetZakljucno_Predmet] FOREIGN KEY ([PkPredmet]) REFERENCES [dbo].[Predmet] ([PkPredmet])
GO
ALTER TABLE [dbo].[StudentPredmetZakljucno] ADD CONSTRAINT [FK_StudentPredmetZakljucno_RedIspita] FOREIGN KEY ([PkRedIspita]) REFERENCES [dbo].[RedIspita] ([PkRedIspita])
GO
