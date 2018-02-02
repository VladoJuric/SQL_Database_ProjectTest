CREATE TABLE [dbo].[Profesori]
(
[ID_Profesor] [int] NOT NULL IDENTITY(1, 1),
[ime] [varchar] (50) COLLATE Croatian_CI_AS NOT NULL,
[prezime] [varchar] (50) COLLATE Croatian_CI_AS NOT NULL,
[soba] [int] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create trigger [dbo].[after_delete_profesor]  on [dbo].[Profesori]
after delete 
as
begin
	delete from dbo.Predmeti where ID_Profesor = (select ID_Profesor from deleted)
end
GO
ALTER TABLE [dbo].[Profesori] ADD CONSTRAINT [PK_Profesori] PRIMARY KEY CLUSTERED  ([ID_Profesor]) ON [PRIMARY]
GO
