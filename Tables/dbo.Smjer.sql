CREATE TABLE [dbo].[Smjer]
(
[PkSmjer] [int] NOT NULL IDENTITY(1, 1),
[IdStudij] [int] NOT NULL,
[Smjer] [varchar] (50) COLLATE Croatian_CI_AS NOT NULL,
[Studij] [varchar] (50) COLLATE Croatian_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Smjer] ADD CONSTRAINT [PK_Smjer] PRIMARY KEY CLUSTERED  ([PkSmjer]) ON [PRIMARY]
GO
