SET NOCOUNT ON;
SET XACT_ABORT ON;

IF OBJECT_ID(N'[dbo].[CreditRating_Country_Log]', N'U') IS NULL
   OR OBJECT_ID(N'[dbo].[CreditRating_Country_Log_Detail]', N'U') IS NULL
   OR OBJECT_ID(N'[dbo].[CreditRating_Country_Current]', N'U') IS NULL
   OR OBJECT_ID(N'[dbo].[CountryMaster]', N'U') IS NULL
    THROW 51300, N'缺少 2026081201 建立的國家信評資料表或 dbo.CountryMaster。', 1;

IF OBJECT_ID(N'[dbo].[CreditRatingMaster]', N'U') IS NULL
   OR COL_LENGTH(N'dbo.CountryMaster', N'CreditRatingScore') IS NULL
   OR COL_LENGTH(N'dbo.CountryMaster', N'CreditRatingScorePublishedAt') IS NULL
    THROW 51301, N'缺少 dbo.CreditRatingMaster 或 CountryMaster 信評欄位。', 1;

IF OBJECT_ID(N'[dbo].[CreditRating_Country_M]', N'U') IS NULL
   OR OBJECT_ID(N'[dbo].[CreditRating_Country]', N'U') IS NULL
    THROW 51302, N'缺少初始化所需的舊表 dbo.CreditRating_Country_M 或 dbo.CreditRating_Country。', 1;

-- 先獨立建立 nullable 欄位，讓下一個 batch 能在舊 schema 上正確完成欄位名稱解析。
IF COL_LENGTH(N'dbo.CreditRating_Country_Log', N'BusinessDate') IS NULL
    ALTER TABLE [dbo].[CreditRating_Country_Log] ADD [BusinessDate] date NULL;

IF COL_LENGTH(N'dbo.CreditRating_Country_Log_Detail', N'BusinessDate') IS NULL
    ALTER TABLE [dbo].[CreditRating_Country_Log_Detail] ADD [BusinessDate] date NULL;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

-- 歷史 Log 保留 legacy int 值；目前值欄位為 tinyint，因此只阻擋無法保存的值。
IF EXISTS (SELECT 1 FROM [dbo].[CreditRating_Country_M] WHERE [Score] NOT BETWEEN 0 AND 255)
    THROW 51305, N'CreditRating_Country_M 存在超出 tinyint 0 至 255 範圍的 Score。', 1;

IF EXISTS
(
    SELECT 1 FROM [dbo].[CreditRating_Country_M]
    GROUP BY [FK_CountryId], CONVERT(date, [Create_date])
    HAVING COUNT_BIG(*) > 1
)
    THROW 51303, N'CreditRating_Country_M 存在同國家、同業務日期多筆資料。', 1;

IF EXISTS
(
    SELECT 1 FROM [dbo].[CreditRating_Country]
    GROUP BY [FK_Country_Id], [FK_RatingAgency_Id], [date]
    HAVING COUNT_BIG(*) > 1
)
    THROW 51304, N'CreditRating_Country 存在同國家、同信評公司、同業務日期多筆資料。', 1;

IF EXISTS
(
    SELECT 1
    FROM [dbo].[CreditRating_Country_M] AS source_row
    LEFT JOIN [dbo].[CountryMaster] AS country ON country.[PK_Id] = source_row.[FK_CountryId]
    WHERE country.[PK_Id] IS NULL
)
    THROW 51306, N'CreditRating_Country_M 存在無法對應 CountryMaster 的資料。', 1;

IF EXISTS
(
    SELECT 1
    FROM [dbo].[CreditRating_Country] AS source_row
    LEFT JOIN [dbo].[CountryMaster] AS country ON country.[PK_Id] = source_row.[FK_Country_Id]
    LEFT JOIN [dbo].[CreditRatingMaster] AS agency ON agency.[PK_ID] = source_row.[FK_RatingAgency_Id]
    WHERE country.[PK_Id] IS NULL OR agency.[PK_ID] IS NULL
)
    THROW 51307, N'CreditRating_Country 存在無法對應 CountryMaster 或 CreditRatingMaster 的資料。', 1;

BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE target_row
       SET target_row.[BusinessDate] = CONVERT(date, target_row.[Create_date])
    FROM [dbo].[CreditRating_Country_Log] AS target_row
    WHERE target_row.[BusinessDate] IS NULL;

    UPDATE target_row
       SET target_row.[BusinessDate] = source_row.[date]
    FROM [dbo].[CreditRating_Country_Log_Detail] AS target_row
    INNER JOIN [dbo].[CreditRating_Country] AS source_row ON source_row.[PK_Id] = target_row.[PK_Id]
    WHERE target_row.[BusinessDate] IS NULL;

    IF EXISTS (SELECT 1 FROM [dbo].[CreditRating_Country_Log] WHERE [BusinessDate] IS NULL)
       OR EXISTS (SELECT 1 FROM [dbo].[CreditRating_Country_Log_Detail] WHERE [BusinessDate] IS NULL)
        THROW 51310, N'既有歷程含無法推得 BusinessDate 的資料，已停止升級。', 1;

    IF EXISTS
    (
        SELECT 1 FROM [dbo].[CreditRating_Country_Log]
        GROUP BY [FK_CountryId], [BusinessDate]
        HAVING COUNT_BIG(*) > 1
    )
        THROW 51311, N'CreditRating_Country_Log 存在重複的國家與 BusinessDate。', 1;

    IF EXISTS
    (
        SELECT 1 FROM [dbo].[CreditRating_Country_Log_Detail]
        GROUP BY [FK_Country_Id], [FK_RatingAgency_Id], [BusinessDate]
        HAVING COUNT_BIG(*) > 1
    )
        THROW 51312, N'CreditRating_Country_Log_Detail 存在重複的國家、信評公司與 BusinessDate。', 1;

    IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE [parent_object_id] = OBJECT_ID(N'[dbo].[CreditRating_Country_Log_Detail]') AND [name] = N'FK_CreditRating_Country_Log_Detail_Log')
        ALTER TABLE [dbo].[CreditRating_Country_Log_Detail] DROP CONSTRAINT [FK_CreditRating_Country_Log_Detail_Log];

    IF EXISTS (SELECT 1 FROM sys.key_constraints WHERE [parent_object_id] = OBJECT_ID(N'[dbo].[CreditRating_Country_Log_Detail]') AND [name] = N'UQ_CreditRating_Country_Log_Detail_Log_Agency')
        ALTER TABLE [dbo].[CreditRating_Country_Log_Detail] DROP CONSTRAINT [UQ_CreditRating_Country_Log_Detail_Log_Agency];

    IF EXISTS (SELECT 1 FROM sys.key_constraints WHERE [parent_object_id] = OBJECT_ID(N'[dbo].[CreditRating_Country_Log]') AND [name] = N'UQ_CreditRating_Country_Log_Country_CreateDate')
        ALTER TABLE [dbo].[CreditRating_Country_Log] DROP CONSTRAINT [UQ_CreditRating_Country_Log_Country_CreateDate];

    IF EXISTS (SELECT 1 FROM sys.key_constraints WHERE [parent_object_id] = OBJECT_ID(N'[dbo].[CreditRating_Country_Log]') AND [name] = N'UQ_CreditRating_Country_Log_Id_Country')
        ALTER TABLE [dbo].[CreditRating_Country_Log] DROP CONSTRAINT [UQ_CreditRating_Country_Log_Id_Country];

    IF COL_LENGTH(N'dbo.CreditRating_Country_Log_Detail', N'FK_CreditRatingCountryLogId') IS NOT NULL
        ALTER TABLE [dbo].[CreditRating_Country_Log_Detail] DROP COLUMN [FK_CreditRatingCountryLogId];

    IF COL_LENGTH(N'dbo.CreditRating_Country_Log_Detail', N'updated_Date') IS NOT NULL
        ALTER TABLE [dbo].[CreditRating_Country_Log_Detail] DROP COLUMN [updated_Date];

    ALTER TABLE [dbo].[CreditRating_Country_Log] ALTER COLUMN [BusinessDate] date NOT NULL;
    ALTER TABLE [dbo].[CreditRating_Country_Log_Detail] ALTER COLUMN [BusinessDate] date NOT NULL;
    ALTER TABLE [dbo].[CreditRating_Country_Log_Detail] ALTER COLUMN [RatingDate] datetime NULL;
    ALTER TABLE [dbo].[CreditRating_Country_Current] ALTER COLUMN [RatingDate] datetime NULL;

    IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE [parent_object_id] = OBJECT_ID(N'[dbo].[CreditRating_Country_Log]') AND [name] = N'UQ_CreditRating_Country_Log_Country_BusinessDate')
        ALTER TABLE [dbo].[CreditRating_Country_Log]
            ADD CONSTRAINT [UQ_CreditRating_Country_Log_Country_BusinessDate] UNIQUE ([FK_CountryId], [BusinessDate]);

    IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE [parent_object_id] = OBJECT_ID(N'[dbo].[CreditRating_Country_Log_Detail]') AND [name] = N'UQ_CreditRating_Country_Log_Detail_Country_Agency_BusinessDate')
        ALTER TABLE [dbo].[CreditRating_Country_Log_Detail]
            ADD CONSTRAINT [UQ_CreditRating_Country_Log_Detail_Country_Agency_BusinessDate] UNIQUE ([FK_Country_Id], [FK_RatingAgency_Id], [BusinessDate]);

    -- 支援失敗後重跑或少量資料已存在：相同 PK／業務鍵不得指向不同內容。
    IF EXISTS
    (
        SELECT 1
        FROM [dbo].[CreditRating_Country_M] AS source_row
        INNER JOIN [dbo].[CreditRating_Country_Log] AS target_row ON target_row.[PK_Id] = source_row.[PK_Id]
        WHERE NOT EXISTS
        (
            SELECT target_row.[FK_CountryId], target_row.[Score], target_row.[BusinessDate], target_row.[Create_date]
            INTERSECT
            SELECT source_row.[FK_CountryId], source_row.[Score], CONVERT(date, source_row.[Create_date]), source_row.[Create_date]
        )
    )
        THROW 51313, N'CreditRating_Country_Log 已有相同 PK 但內容不同的資料。', 1;

    IF EXISTS
    (
        SELECT 1
        FROM [dbo].[CreditRating_Country_M] AS source_row
        INNER JOIN [dbo].[CreditRating_Country_Log] AS target_row
            ON target_row.[FK_CountryId] = source_row.[FK_CountryId]
           AND target_row.[BusinessDate] = CONVERT(date, source_row.[Create_date])
           AND target_row.[PK_Id] <> source_row.[PK_Id]
    )
        THROW 51314, N'CreditRating_Country_Log 已有相同國家與業務日期但不同 PK 的資料。', 1;

    IF EXISTS
    (
        SELECT 1
        FROM [dbo].[CreditRating_Country] AS source_row
        INNER JOIN [dbo].[CreditRating_Country_Log_Detail] AS target_row ON target_row.[PK_Id] = source_row.[PK_Id]
        WHERE NOT EXISTS
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
        THROW 51315, N'CreditRating_Country_Log_Detail 已有相同 PK 但內容不同的資料。', 1;

    IF EXISTS
    (
        SELECT 1
        FROM [dbo].[CreditRating_Country] AS source_row
        INNER JOIN [dbo].[CreditRating_Country_Log_Detail] AS target_row
            ON target_row.[FK_Country_Id] = source_row.[FK_Country_Id]
           AND target_row.[FK_RatingAgency_Id] = source_row.[FK_RatingAgency_Id]
           AND target_row.[BusinessDate] = source_row.[date]
           AND target_row.[PK_Id] <> source_row.[PK_Id]
    )
        THROW 51316, N'CreditRating_Country_Log_Detail 已有相同國家、信評公司與業務日期但不同 PK 的資料。', 1;

    SET IDENTITY_INSERT [dbo].[CreditRating_Country_Log] ON;

    INSERT INTO [dbo].[CreditRating_Country_Log]
    (
        [PK_Id], [FK_CountryId], [Score], [BusinessDate], [Create_date]
    )
    SELECT source_row.[PK_Id], source_row.[FK_CountryId], source_row.[Score],
           CONVERT(date, source_row.[Create_date]), source_row.[Create_date]
    FROM [dbo].[CreditRating_Country_M] AS source_row
    WHERE NOT EXISTS
    (
        SELECT 1 FROM [dbo].[CreditRating_Country_Log] AS target_row
        WHERE target_row.[PK_Id] = source_row.[PK_Id]
    );

    SET IDENTITY_INSERT [dbo].[CreditRating_Country_Log] OFF;
    SET IDENTITY_INSERT [dbo].[CreditRating_Country_Log_Detail] ON;

    INSERT INTO [dbo].[CreditRating_Country_Log_Detail]
    (
        [PK_Id], [FK_Country_Id], [FK_RatingAgency_Id], [AgencyRating], [RatingDate],
        [RatingOutlook], [RatingOutlookDate], [Remarks], [BusinessDate], [Create_date], [Create_user]
    )
    SELECT source_row.[PK_Id], source_row.[FK_Country_Id], source_row.[FK_RatingAgency_Id],
           source_row.[AgencyRating], source_row.[RatingDate], source_row.[RatingOutlook],
           source_row.[RatingOutlookDate], source_row.[Remarks], source_row.[date],
           source_row.[Create_date], source_row.[Create_user]
    FROM [dbo].[CreditRating_Country] AS source_row
    WHERE NOT EXISTS
    (
        SELECT 1 FROM [dbo].[CreditRating_Country_Log_Detail] AS target_row
        WHERE target_row.[PK_Id] = source_row.[PK_Id]
    );

    SET IDENTITY_INSERT [dbo].[CreditRating_Country_Log_Detail] OFF;

    ;WITH latest_detail AS
    (
        SELECT source_row.*,
               ROW_NUMBER() OVER
               (
                   PARTITION BY source_row.[FK_Country_Id], source_row.[FK_RatingAgency_Id]
                   ORDER BY source_row.[BusinessDate] DESC, source_row.[Create_date] DESC, source_row.[PK_Id] DESC
               ) AS [RowNumber]
        FROM [dbo].[CreditRating_Country_Log_Detail] AS source_row
    )
    UPDATE target_row
       SET target_row.[AgencyRating] = source_row.[AgencyRating],
           target_row.[RatingDate] = source_row.[RatingDate],
           target_row.[RatingOutlook] = source_row.[RatingOutlook],
           target_row.[RatingOutlookDate] = source_row.[RatingOutlookDate],
           target_row.[Remarks] = source_row.[Remarks],
           target_row.[updated_Date] = CONVERT(datetime, source_row.[BusinessDate]),
           target_row.[Create_user] = source_row.[Create_user],
           target_row.[PublishedAt] = source_row.[Create_date]
    FROM [dbo].[CreditRating_Country_Current] AS target_row
    INNER JOIN latest_detail AS source_row
        ON source_row.[FK_Country_Id] = target_row.[FK_Country_Id]
       AND source_row.[FK_RatingAgency_Id] = target_row.[FK_RatingAgency_Id]
       AND source_row.[RowNumber] = 1
    WHERE CONVERT(date, target_row.[updated_Date]) < source_row.[BusinessDate];

    ;WITH latest_detail AS
    (
        SELECT source_row.*,
               ROW_NUMBER() OVER
               (
                   PARTITION BY source_row.[FK_Country_Id], source_row.[FK_RatingAgency_Id]
                   ORDER BY source_row.[BusinessDate] DESC, source_row.[Create_date] DESC, source_row.[PK_Id] DESC
               ) AS [RowNumber]
        FROM [dbo].[CreditRating_Country_Log_Detail] AS source_row
    )
    INSERT INTO [dbo].[CreditRating_Country_Current]
    (
        [FK_Country_Id], [FK_RatingAgency_Id], [AgencyRating], [RatingDate],
        [RatingOutlook], [RatingOutlookDate], [Remarks], [updated_Date],
        [Create_date], [Create_user], [PublishedAt]
    )
    SELECT source_row.[FK_Country_Id], source_row.[FK_RatingAgency_Id], source_row.[AgencyRating],
           source_row.[RatingDate], source_row.[RatingOutlook], source_row.[RatingOutlookDate],
           source_row.[Remarks], CONVERT(datetime, source_row.[BusinessDate]), source_row.[Create_date],
           source_row.[Create_user], source_row.[Create_date]
    FROM latest_detail AS source_row
    WHERE source_row.[RowNumber] = 1
      AND NOT EXISTS
      (
          SELECT 1 FROM [dbo].[CreditRating_Country_Current] AS target_row
          WHERE target_row.[FK_Country_Id] = source_row.[FK_Country_Id]
            AND target_row.[FK_RatingAgency_Id] = source_row.[FK_RatingAgency_Id]
      );

    ;WITH latest_score AS
    (
        SELECT source_row.*,
               ROW_NUMBER() OVER
               (
                   PARTITION BY source_row.[FK_CountryId]
                   ORDER BY source_row.[BusinessDate] DESC, source_row.[Create_date] DESC, source_row.[PK_Id] DESC
               ) AS [RowNumber]
        FROM [dbo].[CreditRating_Country_Log] AS source_row
    )
    UPDATE target_row
       SET target_row.[CreditRatingScore] = CONVERT(tinyint, source_row.[Score]),
           target_row.[CreditRatingScorePublishedAt] = source_row.[Create_date]
    FROM [dbo].[CountryMaster] AS target_row
    INNER JOIN latest_score AS source_row
        ON source_row.[FK_CountryId] = target_row.[PK_Id]
       AND source_row.[RowNumber] = 1
    WHERE target_row.[CreditRatingScorePublishedAt] IS NULL
       OR target_row.[CreditRatingScorePublishedAt] < source_row.[Create_date];

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
