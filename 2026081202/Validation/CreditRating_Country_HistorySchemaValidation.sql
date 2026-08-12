SET NOCOUNT ON;

IF OBJECT_ID(N'[dbo].[CreditRating_Country_Log]', N'U') IS NULL
   OR OBJECT_ID(N'[dbo].[CreditRating_Country_Log_Detail]', N'U') IS NULL
   OR OBJECT_ID(N'[dbo].[CreditRating_Country_Current]', N'U') IS NULL
   OR OBJECT_ID(N'[dbo].[CreditRating_Country_M]', N'U') IS NULL
   OR OBJECT_ID(N'[dbo].[CreditRating_Country]', N'U') IS NULL
    THROW 51400, N'來源表或目標表不存在，無法驗證。', 1;

IF COL_LENGTH(N'dbo.CountryMaster', N'CreditRatingScore') IS NULL
   OR COL_LENGTH(N'dbo.CountryMaster', N'CreditRatingScorePublishedAt') IS NULL
    THROW 51401, N'CountryMaster 的信評欄位不存在。', 1;

IF COL_LENGTH(N'dbo.CreditRating_Country_Log', N'BusinessDate') IS NULL
   OR NOT EXISTS
      (
          SELECT 1
          FROM sys.columns AS c
          INNER JOIN sys.types AS t ON t.user_type_id = c.user_type_id
          WHERE c.[object_id] = OBJECT_ID(N'[dbo].[CreditRating_Country_Log]')
            AND c.[name] = N'BusinessDate' AND t.[name] = N'date' AND c.is_nullable = 0
      )
   OR NOT EXISTS
      (
          SELECT 1 FROM sys.key_constraints
          WHERE [parent_object_id] = OBJECT_ID(N'[dbo].[CreditRating_Country_Log]')
            AND [name] = N'UQ_CreditRating_Country_Log_Country_BusinessDate'
      )
    THROW 51402, N'CreditRating_Country_Log 的 BusinessDate 或唯一鍵不符合最終契約。', 1;

IF EXISTS (SELECT 1 FROM [dbo].[CreditRating_Country_Log] WHERE [Score] NOT BETWEEN 0 AND 255)
    THROW 51410, N'CreditRating_Country_Log 存在超出目前值 tinyint 0 至 255 範圍的 Score。', 1;

IF COL_LENGTH(N'dbo.CreditRating_Country_Log_Detail', N'FK_CreditRatingCountryLogId') IS NOT NULL
   OR COL_LENGTH(N'dbo.CreditRating_Country_Log_Detail', N'updated_Date') IS NOT NULL
   OR COL_LENGTH(N'dbo.CreditRating_Country_Log_Detail', N'BusinessDate') IS NULL
   OR NOT EXISTS
      (
          SELECT 1
          FROM sys.columns AS c
          INNER JOIN sys.types AS t ON t.user_type_id = c.user_type_id
          WHERE c.[object_id] = OBJECT_ID(N'[dbo].[CreditRating_Country_Log_Detail]')
            AND c.[name] = N'BusinessDate' AND t.[name] = N'date' AND c.is_nullable = 0
      )
   OR NOT EXISTS
      (
          SELECT 1 FROM sys.columns
          WHERE [object_id] = OBJECT_ID(N'[dbo].[CreditRating_Country_Log_Detail]')
            AND [name] = N'RatingDate' AND is_nullable = 1
      )
   OR NOT EXISTS
      (
          SELECT 1 FROM sys.key_constraints
          WHERE [parent_object_id] = OBJECT_ID(N'[dbo].[CreditRating_Country_Log_Detail]')
            AND [name] = N'UQ_CreditRating_Country_Log_Detail_Country_Agency_BusinessDate'
      )
   OR EXISTS
      (
          SELECT 1 FROM sys.foreign_keys
          WHERE [parent_object_id] = OBJECT_ID(N'[dbo].[CreditRating_Country_Log_Detail]')
            AND [name] = N'FK_CreditRating_Country_Log_Detail_Log'
      )
   OR EXISTS
      (
          SELECT 1 FROM sys.key_constraints
          WHERE [parent_object_id] = OBJECT_ID(N'[dbo].[CreditRating_Country_Log_Detail]')
            AND [name] = N'UQ_CreditRating_Country_Log_Detail_Log_Agency'
      )
    THROW 51403, N'CreditRating_Country_Log_Detail 尚未完成獨立歷程 schema 修正。', 1;

IF NOT EXISTS
(
    SELECT 1 FROM sys.columns
    WHERE [object_id] = OBJECT_ID(N'[dbo].[CreditRating_Country_Current]')
      AND [name] = N'RatingDate' AND is_nullable = 1
)
    THROW 51404, N'CreditRating_Country_Current.RatingDate 尚未改為 nullable。', 1;

IF EXISTS
(
    SELECT 1
    FROM [dbo].[CreditRating_Country_M] AS source_row
    LEFT JOIN [dbo].[CreditRating_Country_Log] AS target_row ON target_row.[PK_Id] = source_row.[PK_Id]
    WHERE target_row.[PK_Id] IS NULL
       OR NOT EXISTS
          (
              SELECT target_row.[FK_CountryId], target_row.[Score], target_row.[BusinessDate], target_row.[Create_date]
              INTERSECT
              SELECT source_row.[FK_CountryId], source_row.[Score], CONVERT(date, source_row.[Create_date]), source_row.[Create_date]
          )
)
    THROW 51405, N'CreditRating_Country_M 尚未完整或正確搬入 CreditRating_Country_Log。', 1;

IF EXISTS
(
    SELECT 1
    FROM [dbo].[CreditRating_Country] AS source_row
    LEFT JOIN [dbo].[CreditRating_Country_Log_Detail] AS target_row ON target_row.[PK_Id] = source_row.[PK_Id]
    WHERE target_row.[PK_Id] IS NULL
       OR NOT EXISTS
          (
              SELECT target_row.[FK_Country_Id], target_row.[FK_RatingAgency_Id],
                     target_row.[AgencyRating], target_row.[RatingDate], target_row.[RatingOutlook],
                     target_row.[RatingOutlookDate], target_row.[Remarks], target_row.[BusinessDate],
                     target_row.[Create_date], target_row.[Create_user]
              INTERSECT
              SELECT source_row.[FK_Country_Id], source_row.[FK_RatingAgency_Id],
                     source_row.[AgencyRating], source_row.[RatingDate], source_row.[RatingOutlook],
                     source_row.[RatingOutlookDate], source_row.[Remarks], source_row.[date],
                     source_row.[Create_date], source_row.[Create_user]
          )
)
    THROW 51406, N'CreditRating_Country 尚未完整或正確搬入 CreditRating_Country_Log_Detail。', 1;

IF EXISTS
(
    SELECT 1
    FROM
    (
        SELECT source_row.[FK_Country_Id], source_row.[FK_RatingAgency_Id], source_row.[BusinessDate],
               ROW_NUMBER() OVER
               (
                   PARTITION BY source_row.[FK_Country_Id], source_row.[FK_RatingAgency_Id]
                   ORDER BY source_row.[BusinessDate] DESC, source_row.[Create_date] DESC, source_row.[PK_Id] DESC
               ) AS [RowNumber]
        FROM [dbo].[CreditRating_Country_Log_Detail] AS source_row
    ) AS source_row
    LEFT JOIN [dbo].[CreditRating_Country_Current] AS target_row
        ON target_row.[FK_Country_Id] = source_row.[FK_Country_Id]
       AND target_row.[FK_RatingAgency_Id] = source_row.[FK_RatingAgency_Id]
    WHERE source_row.[RowNumber] = 1
      AND
      (
          target_row.[PK_Id] IS NULL
          OR CONVERT(date, target_row.[updated_Date]) < source_row.[BusinessDate]
      )
)
    THROW 51407, N'CreditRating_Country_Current 尚未初始化，或目前值早於最新歷程。', 1;

IF EXISTS
(
    SELECT 1
    FROM
    (
        SELECT source_row.[FK_CountryId], source_row.[Score], source_row.[Create_date],
               ROW_NUMBER() OVER
               (
                   PARTITION BY source_row.[FK_CountryId]
                   ORDER BY source_row.[BusinessDate] DESC, source_row.[Create_date] DESC, source_row.[PK_Id] DESC
               ) AS [RowNumber]
        FROM [dbo].[CreditRating_Country_Log] AS source_row
    ) AS source_row
    INNER JOIN [dbo].[CountryMaster] AS target_row ON target_row.[PK_Id] = source_row.[FK_CountryId]
    WHERE source_row.[RowNumber] = 1
      AND
      (
          target_row.[CreditRatingScorePublishedAt] IS NULL
          OR target_row.[CreditRatingScorePublishedAt] < source_row.[Create_date]
          OR
          (
              target_row.[CreditRatingScorePublishedAt] = source_row.[Create_date]
              AND target_row.[CreditRatingScore] <> source_row.[Score]
          )
      )
)
    THROW 51408, N'CountryMaster 尚未初始化，或目前分數早於最新日結。', 1;

IF EXISTS
(
    SELECT 1
    FROM sys.foreign_keys
    WHERE [parent_object_id] IN
          (
              OBJECT_ID(N'[dbo].[CreditRating_Country_Log]'),
              OBJECT_ID(N'[dbo].[CreditRating_Country_Log_Detail]'),
              OBJECT_ID(N'[dbo].[CreditRating_Country_Current]')
          )
      AND ([is_disabled] = 1 OR [is_not_trusted] = 1)
)
    THROW 51409, N'新信評資料表存在停用或未受信任的 foreign key。', 1;

SELECT
    (SELECT COUNT_BIG(*) FROM [dbo].[CreditRating_Country_M]) AS [SourceLogCount],
    (SELECT COUNT_BIG(*) FROM [dbo].[CreditRating_Country_Log]) AS [TargetLogCount],
    (SELECT COUNT_BIG(*) FROM [dbo].[CreditRating_Country]) AS [SourceDetailCount],
    (SELECT COUNT_BIG(*) FROM [dbo].[CreditRating_Country_Log_Detail]) AS [TargetDetailCount],
    (SELECT COUNT_BIG(*) FROM [dbo].[CreditRating_Country_Current]) AS [CurrentCount],
    (SELECT COUNT_BIG(*) FROM [dbo].[CountryMaster] WHERE [CreditRatingScorePublishedAt] IS NOT NULL) AS [PublishedCountryScoreCount];
