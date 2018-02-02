CREATE TABLE [dbo].[Osoba]
(
[PkOsoba] [int] NOT NULL IDENTITY(1, 1),
[PkOsobaOpis] [int] NOT NULL,
[PkAppDataOsoba] [int] NOT NULL,
[Oib] [varchar] (11) COLLATE Croatian_CI_AS NOT NULL,
[Ime] [varchar] (25) COLLATE Croatian_CI_AS NOT NULL,
[Prezime] [varchar] (25) COLLATE Croatian_CI_AS NOT NULL,
[GodinaRodenja] [date] NOT NULL,
[DatumUpisa] [date] NOT NULL,
[Grad] [varchar] (30) COLLATE Croatian_CI_AS NOT NULL,
[Drzava] [varchar] (30) COLLATE Croatian_CI_AS NOT NULL,
[ZavrsnaOcjena] [smallint] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create trigger [dbo].[TriggerOsobaD]  on [dbo].[Osoba]
after delete 
as
begin
	insert into OsobaLog (PkOsoba,PkOsobaOpis,PkAppDataOsoba,Oib,Ime,Prezime,GodinaRodenja,DatumUpisa,Grad,Drzava,Radnja) 
	select PkOsoba,PkOsobaOpis,PkAppDataOsoba,Oib,Ime,Prezime,GodinaRodenja,DatumUpisa,Grad,Drzava,'delete' as Radnja from deleted
end
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[TriggerOsobaI]  on [dbo].[Osoba]
after insert 
as
begin
	insert into OsobaLog (PkOsoba,PkOsobaOpis,PkAppDataOsoba,Oib,Ime,Prezime,GodinaRodenja,DatumUpisa,Grad,Drzava,Radnja) 
	select PkOsoba,PkOsobaOpis,PkAppDataOsoba,Oib,Ime,Prezime,GodinaRodenja,DatumUpisa,Grad,Drzava,'insert' as Radnja from inserted
end
GO
ALTER TABLE [dbo].[Osoba] ADD CONSTRAINT [PK_Osoba] PRIMARY KEY CLUSTERED  ([PkOsoba]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Osoba_2] ON [dbo].[Osoba] ([Oib]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Osoba_1] ON [dbo].[Osoba] ([PkAppDataOsoba]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Osoba] ON [dbo].[Osoba] ([PkOsobaOpis]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Osoba] ADD CONSTRAINT [FK_Osoba_AppDataOsoba] FOREIGN KEY ([PkAppDataOsoba]) REFERENCES [dbo].[AppDataOsoba] ([PkAppDataOsoba])
GO
ALTER TABLE [dbo].[Osoba] ADD CONSTRAINT [FK_Osoba_OsobaOpis] FOREIGN KEY ([PkOsobaOpis]) REFERENCES [dbo].[OsobaOpis] ([PkOsobaOpis])
GO
