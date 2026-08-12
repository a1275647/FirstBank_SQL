SET NOCOUNT ON;

-- 首次部署、尚未由新版 CreditRatings 成功發布資料時應維持 1。
-- 若日後只想重驗歷史搬移，可由執行人員明確改為 0。
DECLARE @ExpectUninitialized bit = 1;

IF OBJECT_ID(N'[dbo].[CreditRating_Country_M]', N'U') IS NULL
   OR OBJECT_ID(N'[dbo].[CreditRating_Country]', N'U') IS NULL
   OR OBJECT_ID(N'[dbo].[CreditRating_Country_Log]', N'U') IS NULL
   OR OBJECT_ID(N'[dbo].[CreditRating_Country_Log_Detail]', N'U') IS NULL
   OR OBJECT_ID(N'[dbo].[CreditRating_Country_Current]', N'U') IS NULL
    THROW 51200, N'來源表或目標表不存在，無法驗證。', 1;

IF COL_LENGTH(N'dbo.CountryMaster', N'CreditRatingScore') IS NULL
   OR COL_LENGTH(N'dbo.CountryMaster', N'CreditRatingScorePublishedAt') IS NULL
    THROW 51201, N'CountryMaster 的信評分數欄位尚未建立。', 1;

IF EXISTS
(
    SELECT 1
    FROM [dbo].[CreditRating_Country_M] AS source_row
    LEFT JOIN [dbo].[CreditRating_Country_Log] AS target_row
        ON target_row.[PK_Id] = source_row.[PK_Id]
    WHERE target_row.[PK_Id] IS NULL
       OR NOT EXISTS
          (
              SELECT target_row.[FK_CountryId], target_row.[Score], target_row.[Create_date]
              INTERSECT
              SELECT source_row.[FK_CountryId], source_row.[Score], source_row.[Create_date]
          )
)
    THROW 51202, N'CreditRating_Country_M 尚未完整或正確搬入 CreditRating_Country_Log。', 1;

IF EXISTS
(
    SELECT 1
    FROM [dbo].[CreditRating_Country] AS source_row
    LEFT JOIN [dbo].[CreditRating_Country_M] AS source_parent
        ON source_parent.[FK_CountryId] = source_row.[FK_Country_Id]
       AND CONVERT(date, source_parent.[Create_date]) = source_row.[date]
    LEFT JOIN [dbo].[CreditRating_Country_Log_Detail] AS target_row
        ON target_row.[PK_Id] = source_row.[PK_Id]
    WHERE source_parent.[PK_Id] IS NULL
       OR target_row.[PK_Id] IS NULL
       OR NOT EXISTS
          (
              SELECT
                  target_row.[FK_CreditRatingCountryLogId], target_row.[FK_Country_Id],
                  target_row.[FK_RatingAgency_Id], target_row.[AgencyRating], target_row.[RatingDate],
                  target_row.[RatingOutlook], target_row.[RatingOutlookDate], target_row.[Remarks],
                  target_row.[updated_Date], target_row.[Create_date], target_row.[Create_user]
              INTERSECT
              SELECT
                  source_parent.[PK_Id], source_row.[FK_Country_Id],
                  source_row.[FK_RatingAgency_Id], source_row.[AgencyRating], source_row.[RatingDate],
                  source_row.[RatingOutlook], source_row.[RatingOutlookDate], source_row.[Remarks],
                  source_row.[date], source_row.[Create_date], source_row.[Create_user]
          )
)
    THROW 51203, N'CreditRating_Country 尚未完整或正確搬入 CreditRating_Country_Log_Detail。', 1;

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
    THROW 51204, N'新信評資料表存在停用或未受信任的 foreign key。', 1;

IF @ExpectUninitialized = 1
BEGIN
    IF EXISTS (SELECT 1 FROM [dbo].[CreditRating_Country_Current])
        THROW 51205, N'首次部署時 CreditRating_Country_Current 應維持空表。', 1;

    IF EXISTS
    (
        SELECT 1
        FROM [dbo].[CountryMaster]
        WHERE [CreditRatingScore] <> 5
           OR [CreditRatingScorePublishedAt] IS NOT NULL
    )
        THROW 51206, N'首次部署時 CountryMaster 信評分數應維持預設值 5，發布時間應維持 NULL。', 1;
END;

SELECT
    (SELECT COUNT_BIG(*) FROM [dbo].[CreditRating_Country_M]) AS [SourceLogCount],
    (SELECT COUNT_BIG(*) FROM [dbo].[CreditRating_Country_Log] AS target_row
     WHERE EXISTS (SELECT 1 FROM [dbo].[CreditRating_Country_M] AS source_row WHERE source_row.[PK_Id] = target_row.[PK_Id])) AS [MigratedLogCount],
    (SELECT COUNT_BIG(*) FROM [dbo].[CreditRating_Country]) AS [SourceDetailCount],
    (SELECT COUNT_BIG(*) FROM [dbo].[CreditRating_Country_Log_Detail] AS target_row
     WHERE EXISTS (SELECT 1 FROM [dbo].[CreditRating_Country] AS source_row WHERE source_row.[PK_Id] = target_row.[PK_Id])) AS [MigratedDetailCount],
    (SELECT COUNT_BIG(*) FROM [dbo].[CreditRating_Country_Current]) AS [CurrentCount],
    (SELECT COUNT_BIG(*) FROM [dbo].[CountryMaster]
     WHERE [CreditRatingScore] <> 5 OR [CreditRatingScorePublishedAt] IS NOT NULL) AS [InitializedCountryScoreCount];
