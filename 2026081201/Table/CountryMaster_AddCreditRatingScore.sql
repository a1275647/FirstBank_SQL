SET NOCOUNT ON;
SET XACT_ABORT ON;

IF OBJECT_ID(N'[dbo].[CountryMaster]', N'U') IS NULL
    THROW 51030, N'缺少前置資料表 dbo.CountryMaster。', 1;

BEGIN TRY
    BEGIN TRANSACTION;

    IF COL_LENGTH(N'dbo.CountryMaster', N'CreditRatingScoreDate') IS NOT NULL
        THROW 51031, N'dbo.CountryMaster.CreditRatingScoreDate 已存在，請先確認舊版腳本是否曾執行。', 1;

    IF COL_LENGTH(N'dbo.CountryMaster', N'CreditRatingScore') IS NULL
        ALTER TABLE [dbo].[CountryMaster]
            ADD [CreditRatingScore] tinyint NOT NULL
                CONSTRAINT [DF_CountryMaster_CreditRatingScore] DEFAULT (5) WITH VALUES;
    ELSE IF NOT EXISTS
    (
        SELECT 1
        FROM sys.columns AS c
        INNER JOIN sys.types AS t ON t.user_type_id = c.user_type_id
        WHERE c.[object_id] = OBJECT_ID(N'[dbo].[CountryMaster]')
          AND c.[name] = N'CreditRatingScore'
          AND t.[name] = N'tinyint'
          AND c.is_nullable = 0
    )
        THROW 51032, N'dbo.CountryMaster.CreditRatingScore 已存在，但型別不是 NOT NULL tinyint。', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM sys.default_constraints AS dc
        INNER JOIN sys.columns AS c
            ON c.[object_id] = dc.[parent_object_id]
           AND c.[column_id] = dc.[parent_column_id]
        WHERE dc.[parent_object_id] = OBJECT_ID(N'[dbo].[CountryMaster]')
          AND c.[name] = N'CreditRatingScore'
          AND REPLACE(REPLACE(REPLACE(dc.[definition], N'(', N''), N')', N''), N' ', N'') = N'5'
    )
        THROW 51033, N'dbo.CountryMaster.CreditRatingScore 缺少預設值 5。', 1;

    IF COL_LENGTH(N'dbo.CountryMaster', N'CreditRatingScorePublishedAt') IS NULL
        ALTER TABLE [dbo].[CountryMaster]
            ADD [CreditRatingScorePublishedAt] datetime NULL;
    ELSE IF NOT EXISTS
    (
        SELECT 1
        FROM sys.columns AS c
        INNER JOIN sys.types AS t ON t.user_type_id = c.user_type_id
        WHERE c.[object_id] = OBJECT_ID(N'[dbo].[CountryMaster]')
          AND c.[name] = N'CreditRatingScorePublishedAt'
          AND t.[name] = N'datetime'
          AND c.is_nullable = 1
    )
        THROW 51034, N'dbo.CountryMaster.CreditRatingScorePublishedAt 已存在，但型別不是 nullable datetime。', 1;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;
