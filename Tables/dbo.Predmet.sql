CREATE TABLE [dbo].[Predmet]
(
[PkPredmet] [int] NOT NULL IDENTITY(1, 1),
[PkSmjer] [int] NOT NULL,
[PkSemestar] [int] NOT NULL,
[Predmet] [varchar] (50) COLLATE Croatian_CI_AS NOT NULL,
[Opis] [varchar] (500) COLLATE Croatian_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create trigger [dbo].[TriggerPredmetD]  on [dbo].[Predmet]
after delete 
as
begin
	insert into PredmetLog (PkPredmet,PkSmjer,PkSemestar,Predmet,Opis,Radnja) 
	select PkPredmet,PkSmjer,PkSemestar,Predmet,Opis,'delete' as Radnja from deleted
end
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[TriggerPredmetI]  on [dbo].[Predmet]
after insert 
as
begin
	insert into PredmetLog (PkPredmet,PkSmjer,PkSemestar,Predmet,Opis,Radnja) 
	select PkPredmet,PkSmjer,PkSemestar,Predmet,Opis,'insert' as Radnja from inserted
end
GO
ALTER TABLE [dbo].[Predmet] ADD CONSTRAINT [PK_Predmet] PRIMARY KEY CLUSTERED  ([PkPredmet]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Predmet_1] ON [dbo].[Predmet] ([PkSemestar]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Predmet] ON [dbo].[Predmet] ([PkSmjer]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Predmet] ADD CONSTRAINT [FK_Predmet_Semestar] FOREIGN KEY ([PkSemestar]) REFERENCES [dbo].[Semestar] ([PkSemestar])
GO
ALTER TABLE [dbo].[Predmet] ADD CONSTRAINT [FK_Predmet_Smjer] FOREIGN KEY ([PkSmjer]) REFERENCES [dbo].[Smjer] ([PkSmjer])
GO
