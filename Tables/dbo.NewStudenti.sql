CREATE TABLE [dbo].[NewStudenti]
(
[ID_Student] [int] NOT NULL IDENTITY(1, 1),
[ime] [varchar] (50) COLLATE Croatian_CI_AS NOT NULL,
[prezime] [varchar] (50) COLLATE Croatian_CI_AS NOT NULL,
[datum_rodenja] [varchar] (10) COLLATE Croatian_CI_AS NULL,
[grad] [varchar] (50) COLLATE Croatian_CI_AS NULL,
[drzava] [varchar] (50) COLLATE Croatian_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NewStudenti] ADD CONSTRAINT [PK_NewStudenti] PRIMARY KEY CLUSTERED  ([ID_Student]) ON [PRIMARY]
GO
