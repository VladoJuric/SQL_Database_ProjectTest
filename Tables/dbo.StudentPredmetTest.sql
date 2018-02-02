CREATE TABLE [dbo].[StudentPredmetTest]
(
[ID_StudentPredmet] [int] NOT NULL IDENTITY(1, 1),
[ID_Predmet] [int] NOT NULL,
[ID_Student] [int] NOT NULL,
[ocjena] [smallint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[StudentPredmetTest] ADD CONSTRAINT [PK_StudentPredmet] PRIMARY KEY CLUSTERED  ([ID_StudentPredmet]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [stpr_pred_index] ON [dbo].[StudentPredmetTest] ([ID_Predmet]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [stpr_stud_index] ON [dbo].[StudentPredmetTest] ([ID_Student]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[StudentPredmetTest] ADD CONSTRAINT [FK_StudentPredmet_NewStudenti] FOREIGN KEY ([ID_Student]) REFERENCES [dbo].[NewStudenti] ([ID_Student])
GO
ALTER TABLE [dbo].[StudentPredmetTest] ADD CONSTRAINT [FK_StudentPredmet_Predmeti] FOREIGN KEY ([ID_Predmet]) REFERENCES [dbo].[Predmeti] ([ID_Predmet])
GO
