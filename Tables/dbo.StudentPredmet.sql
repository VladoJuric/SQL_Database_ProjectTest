CREATE TABLE [dbo].[StudentPredmet]
(
[PkStudentPredmet] [int] NOT NULL IDENTITY(1, 1),
[PkOsoba] [int] NOT NULL,
[PkPredmet] [int] NULL,
[PkRedIspita] [int] NULL,
[Ocjena] [smallint] NULL,
[BrojIzlazakIspit] [smallint] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE trigger [dbo].[TriggerPStudentPredmetI]  on [dbo].[StudentPredmet]
after insert 
as
begin
	insert into StudentPredmetLog (PkStudentPredmet,PkOsoba,PkPredmet,PkRedIspita,Ocjena,BrojIzlazakIspit,Radnja) 
	select PkStudentPredmet,PkOsoba,PkPredmet,PkRedIspita,Ocjena,BrojIzlazakIspit,'insert' as Radnja from inserted
end
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE trigger [dbo].[TriggerStudentPredmetD]  on [dbo].[StudentPredmet]
after delete 
as
begin
	insert into StudentPredmetLog (PkStudentPredmet,PkOsoba,PkPredmet,PkRedIspita,Ocjena,BrojIzlazakIspit,Radnja) 
	select PkStudentPredmet,PkOsoba,PkPredmet,PkRedIspita,Ocjena,BrojIzlazakIspit,'delete' as Radnja from deleted
end
GO
ALTER TABLE [dbo].[StudentPredmet] ADD CONSTRAINT [PK_StudentPredmet] PRIMARY KEY CLUSTERED  ([PkStudentPredmet]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_StudentPredmet] ON [dbo].[StudentPredmet] ([PkOsoba]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_StudentPredmet_1] ON [dbo].[StudentPredmet] ([PkPredmet]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_StudentPredmet_2] ON [dbo].[StudentPredmet] ([PkRedIspita]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[StudentPredmet] ADD CONSTRAINT [FK_StudentPredmet_Osoba] FOREIGN KEY ([PkOsoba]) REFERENCES [dbo].[Osoba] ([PkOsoba])
GO
ALTER TABLE [dbo].[StudentPredmet] ADD CONSTRAINT [FK_StudentPredmet_Predmet] FOREIGN KEY ([PkPredmet]) REFERENCES [dbo].[Predmet] ([PkPredmet])
GO
ALTER TABLE [dbo].[StudentPredmet] ADD CONSTRAINT [FK_StudentPredmet_RedIspita] FOREIGN KEY ([PkRedIspita]) REFERENCES [dbo].[RedIspita] ([PkRedIspita])
GO
