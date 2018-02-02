CREATE TABLE [dbo].[OsobaOpis]
(
[PkOsobaOpis] [int] NOT NULL IDENTITY(1, 1),
[StatusOsobe] [varchar] (25) COLLATE Croatian_CI_AS NOT NULL,
[Opis] [varchar] (500) COLLATE Croatian_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[OsobaOpis] ADD CONSTRAINT [PK_OsobaOpis] PRIMARY KEY CLUSTERED  ([PkOsobaOpis]) ON [PRIMARY]
GO
