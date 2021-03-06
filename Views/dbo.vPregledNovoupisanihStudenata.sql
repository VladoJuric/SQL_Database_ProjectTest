SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vPregledNovoupisanihStudenata]
AS
SELECT DISTINCT dbo.Osoba.Ime, dbo.Osoba.Prezime, dbo.Semestar.Semestar, dbo.Smjer.Smjer, dbo.Smjer.Studij
FROM            dbo.Semestar INNER JOIN
                         dbo.Predmet ON dbo.Semestar.PkSemestar = dbo.Predmet.PkSemestar INNER JOIN
                         dbo.Smjer ON dbo.Predmet.PkSmjer = dbo.Smjer.PkSmjer INNER JOIN
                         dbo.StudentPredmet ON dbo.Predmet.PkPredmet = dbo.StudentPredmet.PkPredmet INNER JOIN
                         dbo.Osoba INNER JOIN
                         dbo.OsobaOpis ON dbo.Osoba.PkOsobaOpis = dbo.OsobaOpis.PkOsobaOpis ON dbo.StudentPredmet.PkOsoba = dbo.Osoba.PkOsoba INNER JOIN
                         dbo.AppDataOsoba ON dbo.Osoba.PkAppDataOsoba = dbo.AppDataOsoba.PkAppDataOsoba
WHERE        (dbo.Semestar.Semestar = '1. Semestar') AND (dbo.OsobaOpis.StatusOsobe = 'Student') AND (dbo.AppDataOsoba.StatusAktivnosti = 'DA')

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
         Begin Table = "Semestar"
            Begin Extent = 
               Top = 139
               Left = 550
               Bottom = 269
               Right = 720
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Predmet"
            Begin Extent = 
               Top = 5
               Left = 661
               Bottom = 135
               Right = 831
            End
            DisplayFlags = 280
            TopColumn = 1
         End
         Begin Table = "Smjer"
            Begin Extent = 
               Top = 65
               Left = 928
               Bottom = 195
               Right = 1098
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "StudentPredmet"
            Begin Extent = 
               Top = 9
               Left = 383
               Bottom = 139
               Right = 571
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Osoba"
            Begin Extent = 
               Top = 4
               Left = 181
               Bottom = 134
               Right = 357
            End
            DisplayFlags = 280
            TopColumn = 3
         End
         Begin Table = "OsobaOpis"
            Begin Extent = 
               Top = 5
               Left = 0
               Bottom = 118
               Right = 170
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "AppDataOsoba"
            Begin Extent = 
               Top = 138
               Left = 38
               Bottom = 234
               Right = 214
            End
            DisplayFlags', 'SCHEMA', N'dbo', 'VIEW', N'vPregledNovoupisanihStudenata', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_DiagramPane2', N' = 280
            TopColumn = 0
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
      Begin ColumnWidths = 11
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
         Or = 1350
      End
   End
End
', 'SCHEMA', N'dbo', 'VIEW', N'vPregledNovoupisanihStudenata', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=2
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'dbo', 'VIEW', N'vPregledNovoupisanihStudenata', NULL, NULL
GO
