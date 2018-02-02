SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[vPregledPredmetaPoProfesoruAsistentu]
AS
SELECT DISTINCT dbo.Osoba.Ime, dbo.Osoba.Prezime, dbo.OsobaOpis.StatusOsobe, COUNT(dbo.Predmet.Predmet) AS broj_predmeta
FROM            dbo.Osoba INNER JOIN
                         dbo.OsobaOpis ON dbo.Osoba.PkOsobaOpis = dbo.OsobaOpis.PkOsobaOpis INNER JOIN
                         dbo.AppDataOsoba ON dbo.Osoba.PkAppDataOsoba = dbo.AppDataOsoba.PkAppDataOsoba INNER JOIN
                         dbo.ProfesorPredmet ON dbo.Osoba.PkOsoba = dbo.ProfesorPredmet.PkOsoba INNER JOIN
                         dbo.Predmet ON dbo.ProfesorPredmet.PkPredmet = dbo.Predmet.PkPredmet
WHERE        (dbo.AppDataOsoba.StatusAktivnosti = 'DA') AND (dbo.OsobaOpis.StatusOsobe = 'Profesor' OR
                         dbo.OsobaOpis.StatusOsobe = 'Asistent')
GROUP BY dbo.OsobaOpis.StatusOsobe, dbo.Osoba.Ime, dbo.Osoba.Prezime
GO
EXEC sp_addextendedproperty N'MS_DiagramPane1', N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "Osoba"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 214
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "OsobaOpis"
            Begin Extent = 
               Top = 6
               Left = 252
               Bottom = 119
               Right = 422
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "AppDataOsoba"
            Begin Extent = 
               Top = 6
               Left = 460
               Bottom = 102
               Right = 636
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ProfesorPredmet"
            Begin Extent = 
               Top = 6
               Left = 674
               Bottom = 119
               Right = 865
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Predmet"
            Begin Extent = 
               Top = 148
               Left = 683
               Bottom = 278
               Right = 853
            End
            DisplayFlags = 280
            TopColumn = 1
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
       ', 'SCHEMA', N'dbo', 'VIEW', N'vPregledPredmetaPoProfesoruAsistentu', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_DiagramPane2', N'  Or = 1350
      End
   End
End
', 'SCHEMA', N'dbo', 'VIEW', N'vPregledPredmetaPoProfesoruAsistentu', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=2
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'dbo', 'VIEW', N'vPregledPredmetaPoProfesoruAsistentu', NULL, NULL
GO
