CREATE TABLE [dbo].[OsobaFunkcija]
(
[PkOsobaFunkcija] [int] NOT NULL IDENTITY(1, 1),
[PkAppDataFunkcija] [int] NOT NULL,
[PkOsoba] [int] NOT NULL,
[PkAppDataTipUgovora] [int] NOT NULL,
[VrijediOd] [date] NOT NULL,
[VrijediDo] [date] NOT NULL,
[StatusFunkcije] [varchar] (10) COLLATE Croatian_CI_AS NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE trigger [dbo].[TriggerOsobaFunkcijaD] on [dbo].[OsobaFunkcija]
after delete
as
begin
	insert into OsobaFunkcijaLog (PkOsobaFunkcija,PkAppDataFunkcija,PkOsoba,PkAppDataTipUgovora,VrijediOd,VrijediDo,DatumBrisanja,StatusFunkcije,Radnja) 
	select PkOsobaFunkcija,PkAppDataFunkcija,PkOsoba,PkAppDataTipUgovora,VrijediOd,VrijediDo,GETDATE(),StatusFunkcije,'delete' as Radnja from deleted

	--if ((select PkOsoba from deleted) in (select PkOsoba from Osoba where PkOsobaOpis=4))
	--begin
	--	update Osoba set PkAppDataOsoba=2 where PkOsoba=(select PkOsoba from deleted)
	--end
end
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create trigger [dbo].[TriggerOsobaFunkcijaI] on [dbo].[OsobaFunkcija]
after insert
as
begin
	insert into OsobaFunkcijaLog (PkOsobaFunkcija,PkAppDataFunkcija,PkOsoba,PkAppDataTipUgovora,VrijediOd,VrijediDo,StatusFunkcije,Radnja) 
	select PkOsobaFunkcija,PkAppDataFunkcija,PkOsoba,PkAppDataTipUgovora,VrijediOd,VrijediDo,StatusFunkcije,'insert' as Radnja from inserted
end
GO
ALTER TABLE [dbo].[OsobaFunkcija] ADD CONSTRAINT [PK_OsobaFunkcija] PRIMARY KEY CLUSTERED  ([PkOsobaFunkcija]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_OsobaFunkcija] ON [dbo].[OsobaFunkcija] ([PkAppDataFunkcija]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_OsobaFunkcija_1] ON [dbo].[OsobaFunkcija] ([PkOsoba]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[OsobaFunkcija] ADD CONSTRAINT [FK_OsobaFunkcija_AppDataFunkcija] FOREIGN KEY ([PkAppDataFunkcija]) REFERENCES [dbo].[AppDataFunkcija] ([PkAppDataFunkcija])
GO
ALTER TABLE [dbo].[OsobaFunkcija] ADD CONSTRAINT [FK_OsobaFunkcija_AppDataTipUgovora] FOREIGN KEY ([PkAppDataTipUgovora]) REFERENCES [dbo].[AppDataTipUgovora] ([PkAppDataTipUgovora])
GO
ALTER TABLE [dbo].[OsobaFunkcija] ADD CONSTRAINT [FK_OsobaFunkcija_Osoba] FOREIGN KEY ([PkOsoba]) REFERENCES [dbo].[Osoba] ([PkOsoba])
GO
