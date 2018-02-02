CREATE TABLE [dbo].[AppDataTipUgovora]
(
[PkAppDataTipUgovora] [int] NOT NULL IDENTITY(1, 1),
[TipUgovora] [varchar] (20) COLLATE Croatian_CI_AS NOT NULL,
[TrajanjeUgovora] [varchar] (20) COLLATE Croatian_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AppDataTipUgovora] ADD CONSTRAINT [PK_AppDataTipUgovora] PRIMARY KEY CLUSTERED  ([PkAppDataTipUgovora]) ON [PRIMARY]
GO
