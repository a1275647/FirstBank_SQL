SET NOCOUNT ON;
SET XACT_ABORT ON;

IF OBJECT_ID(N'[dbo].[CreditRating_Country_M]', N'U') IS NULL
   OR OBJECT_ID(N'[dbo].[CreditRating_Country]', N'U') IS NULL
    THROW 51100, N'缺少來源資料表 dbo.CreditRating_Country_M 或 dbo.CreditRating_Country。', 1;

IF OBJECT_ID(N'[dbo].[CreditRating_Country_Log]', N'U') IS NULL
   OR OBJECT_ID(N'[dbo].[CreditRating_Country_Log_Detail]', N'U') IS NULL
   OR OBJECT_ID(N'[dbo].[CreditRating_Country_Current]', N'U') IS NULL
    THROW 51101, N'請先依 README 建立三張新資料表。', 1;

-- 舊明細以「國家 + 業務日期」對應舊主檔。每筆明細必須且只能找到一筆主檔。
IF EXISTS
(
    SELECT 1
    FROM [dbo].[CreditRating_Country_M]
    GROUP BY [FK_CountryId], CONVERT(date, [Create_date])
    HAVING COUNT_BIG(*) > 1
)
    THROW 51102, N'CreditRating_Country_M 存在同國家、同日期多筆資料，無法安全建立明細關聯。', 1;

IF EXISTS
(
    SELECT 1
    FROM [dbo].[CreditRating_Country] AS d
    OUTER APPLY
    (
        SELECT COUNT_BIG(*) AS [ParentCount]
        FROM [dbo].[CreditRating_Country_M] AS m
        WHERE m.[FK_CountryId] = d.[FK_Country_Id]
          AND CONVERT(date, m.[Create_date]) = d.[date]
    ) AS match_result
    WHERE match_result.[ParentCount] <> 1
)
    THROW 51103, N'CreditRating_Country 存在找不到唯一 CreditRating_Country_M 主檔的資料。', 1;

-- 新 Detail 一個國家日批次、一家信評公司只能有一筆；先阻擋不符合新鍵值的舊資料。
IF EXISTS
(
    SELECT 1
    FROM [dbo].[CreditRating_Country] AS d
    INNER JOIN [dbo].[CreditRating_Country_M] AS m
        ON m.[FK_CountryId] = d.[FK_Country_Id]
       AND CONVERT(date, m.[Create_date]) = d.[date]
    GROUP BY m.[PK_Id], d.[FK_RatingAgency_Id]
    HAVING COUNT_BIG(*) > 1
)
    THROW 51104, N'CreditRating_Country 存在同一國家日批次、同一信評公司多筆資料。', 1;

IF EXISTS
(
    SELECT 1
    FROM [dbo].[CreditRating_Country_M] AS m
    LEFT JOIN [dbo].[CountryMaster] AS c ON c.[PK_Id] = m.[FK_CountryId]
    WHERE c.[PK_Id] IS NULL
)
    THROW 51105, N'CreditRating_Country_M 存在無法對應 CountryMaster 的資料。', 1;

IF EXISTS
(
    SELECT 1
    FROM [dbo].[CreditRating_Country] AS d
    LEFT JOIN [dbo].[CountryMaster] AS c ON c.[PK_Id] = d.[FK_Country_Id]
    LEFT JOIN [dbo].[CreditRatingMaster] AS a ON a.[PK_ID] = d.[FK_RatingAgency_Id]
    WHERE c.[PK_Id] IS NULL OR a.[PK_ID] IS NULL
)
    THROW 51106, N'CreditRating_Country 存在無法對應 CountryMaster 或 CreditRatingMaster 的資料。', 1;

-- 支援安全重跑：相同 PK 已存在時資料必須完全一致。
IF EXISTS
(
    SELECT 1
    FROM [dbo].[CreditRating_Country_M] AS source_row
    INNER JOIN [dbo].[CreditRating_Country_Log] AS target_row
        ON target_row.[PK_Id] = source_row.[PK_Id]
    WHERE NOT EXISTS
    (
        SELECT target_row.[FK_CountryId], target_row.[Score], target_row.[Create_date]
        INTERSECT
        SELECT source_row.[FK_CountryId], source_row.[Score], source_row.[Create_date]
    )
)
    THROW 51107, N'CreditRating_Country_Log 已有相同 PK 但內容不同的資料。', 1;

IF EXISTS
(
    SELECT 1
    FROM [dbo].[CreditRating_Country_M] AS source_row
    INNER JOIN [dbo].[CreditRating_Country_Log] AS target_row
        ON target_row.[FK_CountryId] = source_row.[FK_CountryId]
       AND target_row.[Create_date] = source_row.[Create_date]
       AND target_row.[PK_Id] <> source_row.[PK_Id]
)
    THROW 51108, N'CreditRating_Country_Log 已有相同國家與日期但不同 PK 的資料。', 1;

IF EXISTS
(
    SELECT 1
    FROM [dbo].[CreditRating_Country] AS source_row
    INNER JOIN [dbo].[CreditRating_Country_M] AS source_parent
        ON source_parent.[FK_CountryId] = source_row.[FK_Country_Id]
       AND CONVERT(date, source_parent.[Create_date]) = source_row.[date]
    INNER JOIN [dbo].[CreditRating_Country_Log_Detail] AS target_row
        ON target_row.[PK_Id] = source_row.[PK_Id]
    WHERE NOT EXISTS
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
    THROW 51109, N'CreditRating_Country_Log_Detail 已有相同 PK 但內容不同的資料。', 1;

IF EXISTS
(
    SELECT 1
    FROM [dbo].[CreditRating_Country] AS source_row
    INNER JOIN [dbo].[CreditRating_Country_M] AS source_parent
        ON source_parent.[FK_CountryId] = source_row.[FK_Country_Id]
       AND CONVERT(date, source_parent.[Create_date]) = source_row.[date]
    INNER JOIN [dbo].[CreditRating_Country_Log_Detail] AS target_row
        ON target_row.[FK_CreditRatingCountryLogId] = source_parent.[PK_Id]
       AND target_row.[FK_RatingAgency_Id] = source_row.[FK_RatingAgency_Id]
       AND target_row.[PK_Id] <> source_row.[PK_Id]
)
    THROW 51110, N'CreditRating_Country_Log_Detail 已有相同批次與信評公司但不同 PK 的資料。', 1;

BEGIN TRY
    BEGIN TRANSACTION;

    SET IDENTITY_INSERT [dbo].[CreditRating_Country_Log] ON;

    INSERT INTO [dbo].[CreditRating_Country_Log]
    (
        [PK_Id], [FK_CountryId], [Score], [Create_date]
    )
    SELECT
        source_row.[PK_Id], source_row.[FK_CountryId], source_row.[Score], source_row.[Create_date]
    FROM [dbo].[CreditRating_Country_M] AS source_row
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM [dbo].[CreditRating_Country_Log] AS target_row
        WHERE target_row.[PK_Id] = source_row.[PK_Id]
    );

    SET IDENTITY_INSERT [dbo].[CreditRating_Country_Log] OFF;

    SET IDENTITY_INSERT [dbo].[CreditRating_Country_Log_Detail] ON;

    INSERT INTO [dbo].[CreditRating_Country_Log_Detail]
    (
        [PK_Id], [FK_CreditRatingCountryLogId], [FK_Country_Id], [FK_RatingAgency_Id],
        [AgencyRating], [RatingDate], [RatingOutlook], [RatingOutlookDate], [Remarks],
        [updated_Date], [Create_date], [Create_user]
    )
    SELECT
        source_row.[PK_Id], source_parent.[PK_Id], source_row.[FK_Country_Id],
        source_row.[FK_RatingAgency_Id], source_row.[AgencyRating], source_row.[RatingDate],
        source_row.[RatingOutlook], source_row.[RatingOutlookDate], source_row.[Remarks],
        source_row.[date], source_row.[Create_date], source_row.[Create_user]
    FROM [dbo].[CreditRating_Country] AS source_row
    INNER JOIN [dbo].[CreditRating_Country_M] AS source_parent
        ON source_parent.[FK_CountryId] = source_row.[FK_Country_Id]
       AND CONVERT(date, source_parent.[Create_date]) = source_row.[date]
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM [dbo].[CreditRating_Country_Log_Detail] AS target_row
        WHERE target_row.[PK_Id] = source_row.[PK_Id]
    );

    SET IDENTITY_INSERT [dbo].[CreditRating_Country_Log_Detail] OFF;

    DECLARE @MaxLogId int = (SELECT MAX([PK_Id]) FROM [dbo].[CreditRating_Country_Log]);
    DECLARE @MaxDetailId int = (SELECT MAX([PK_Id]) FROM [dbo].[CreditRating_Country_Log_Detail]);

    IF @MaxLogId IS NOT NULL
        DBCC CHECKIDENT (N'[dbo].[CreditRating_Country_Log]', RESEED, @MaxLogId) WITH NO_INFOMSGS;

    IF @MaxDetailId IS NOT NULL
        DBCC CHECKIDENT (N'[dbo].[CreditRating_Country_Log_Detail]', RESEED, @MaxDetailId) WITH NO_INFOMSGS;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    BEGIN TRY
        SET IDENTITY_INSERT [dbo].[CreditRating_Country_Log] OFF;
    END TRY
    BEGIN CATCH
    END CATCH;

    BEGIN TRY
        SET IDENTITY_INSERT [dbo].[CreditRating_Country_Log_Detail] OFF;
    END TRY
    BEGIN CATCH
    END CATCH;
    THROW;
END CATCH;

SELECT
    (SELECT COUNT_BIG(*) FROM [dbo].[CreditRating_Country_M]) AS [SourceLogCount],
    (SELECT COUNT_BIG(*) FROM [dbo].[CreditRating_Country_Log]) AS [TargetLogCount],
    (SELECT COUNT_BIG(*) FROM [dbo].[CreditRating_Country]) AS [SourceDetailCount],
    (SELECT COUNT_BIG(*) FROM [dbo].[CreditRating_Country_Log_Detail]) AS [TargetDetailCount];
