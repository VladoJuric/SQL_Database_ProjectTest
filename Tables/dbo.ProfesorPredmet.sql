CREATE TABLE [dbo].[ProfesorPredmet]
(
[PkProfesorPredmet] [int] NOT NULL IDENTITY(1, 1),
[PkOsoba] [int] NOT NULL,
[PkPredmet] [int] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create trigger [dbo].[TriggerProfesorPredmetD]  on [dbo].[ProfesorPredmet]
after delete 
as
begin
	--declare @min int
	--declare @max int
	--select @min = min(PkProfesorPredmet) from deleted
	--select @max = max(PkProfesorPredmet) from deleted

	--while (@min <= @max)
	--begin
	--	insert into ProfesorPredmetLog (PkProfesorPredmet,PkOsoba,PkPredmet,Radnja)
	--	values ((select PkProfesorPredmet from deleted where PkProfesorPredmet = @min),
	--			(select PkOsoba from deleted where PkProfesorPredmet = @min),
	--			(select PkPredmet from deleted where PkProfesorPredmet = @min),
	--			'delete')
	--	select @min = @min +1
	--end

	insert into ProfesorPredmetLog (PkProfesorPredmet,PkOsoba,PkPredmet,Radnja) select PkProfesorPredmet,PkOsoba,PkPredmet,'delete' as Radnja from deleted
end
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create trigger [dbo].[TriggerProfesorPredmetI]  on [dbo].[ProfesorPredmet]
after insert 
as
begin
	insert into ProfesorPredmetLog (PkProfesorPredmet,PkOsoba,PkPredmet,Radnja) select PkProfesorPredmet,PkOsoba,PkPredmet,'insert' as Radnja from inserted
end
GO
ALTER TABLE [dbo].[ProfesorPredmet] ADD CONSTRAINT [PK_ProfesorPredmet] PRIMARY KEY CLUSTERED  ([PkProfesorPredmet]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ProfesorPredmet] ON [dbo].[ProfesorPredmet] ([PkOsoba]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ProfesorPredmet_1] ON [dbo].[ProfesorPredmet] ([PkPredmet]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProfesorPredmet] ADD CONSTRAINT [FK_ProfesorPredmet_Osoba] FOREIGN KEY ([PkOsoba]) REFERENCES [dbo].[Osoba] ([PkOsoba])
GO
ALTER TABLE [dbo].[ProfesorPredmet] ADD CONSTRAINT [FK_ProfesorPredmet_Predmet] FOREIGN KEY ([PkPredmet]) REFERENCES [dbo].[Predmet] ([PkPredmet])
GO
