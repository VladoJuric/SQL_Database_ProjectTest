CREATE TABLE [dbo].[Predmeti]
(
[ID_Predmet] [int] NOT NULL IDENTITY(1, 1),
[predmet] [varchar] (50) COLLATE Croatian_CI_AS NULL,
[opis] [varchar] (500) COLLATE Croatian_CI_AS NULL,
[ID_Profesor] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE trigger [dbo].[after_delete_predmet]  on [dbo].[Predmeti]
after delete 
as
begin
	delete from dbo.StudentPredmetTest where ID_Predmet = (select ID_Predmet from deleted)
end
GO
ALTER TABLE [dbo].[Predmeti] ADD CONSTRAINT [PK_Predmeti] PRIMARY KEY CLUSTERED  ([ID_Predmet]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [prof_pred_index] ON [dbo].[Predmeti] ([ID_Profesor]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Predmeti] ADD CONSTRAINT [FK_Predmeti_Profesori] FOREIGN KEY ([ID_Profesor]) REFERENCES [dbo].[Profesori] ([ID_Profesor])
GO
