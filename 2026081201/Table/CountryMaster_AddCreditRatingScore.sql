SET NOCOUNT ON;
SET XACT_ABORT ON;

IF OBJECT_ID(N'[dbo].[CountryMaster]', N'U') IS NULL
    THROW 51030, N'缺少前置資料表 dbo.CountryMaster。', 1;

BEGIN TRY
    BEGIN TRANSACTION;

    IF COL_LENGTH(N'dbo.CountryMaster', N'CreditRatingScore') IS NULL
        ALTER TABLE [dbo].[CountryMaster]
            ADD [CreditRatingScore] int NULL;
    ELSE IF NOT EXISTS
    (
        SELECT 1
        FROM sys.columns AS c
        INNER JOIN sys.types AS t ON t.user_type_id = c.user_type_id
        WHERE c.[object_id] = OBJECT_ID(N'[dbo].[CountryMaster]')
          AND c.[name] = N'CreditRatingScore'
          AND t.[name] = N'int'
          AND c.is_nullable = 1
    )
        THROW 51031, N'dbo.CountryMaster.CreditRatingScore 已存在，但型別不是 nullable int。', 1;

    IF COL_LENGTH(N'dbo.CountryMaster', N'CreditRatingScoreDate') IS NULL
        ALTER TABLE [dbo].[CountryMaster]
            ADD [CreditRatingScoreDate] date NULL;
    ELSE IF NOT EXISTS
    (
        SELECT 1
        FROM sys.columns AS c
        INNER JOIN sys.types AS t ON t.user_type_id = c.user_type_id
        WHERE c.[object_id] = OBJECT_ID(N'[dbo].[CountryMaster]')
          AND c.[name] = N'CreditRatingScoreDate'
          AND t.[name] = N'date'
          AND c.is_nullable = 1
    )
        THROW 51032, N'dbo.CountryMaster.CreditRatingScoreDate 已存在，但型別不是 nullable date。', 1;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;
