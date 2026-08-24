SET NOCOUNT ON;
SET XACT_ABORT ON;

IF OBJECT_ID(N'[dbo].[Users_log]', N'U') IS NULL
    THROW 51044, N'缺少前置資料表 dbo.Users_log。', 1;

BEGIN TRY
    BEGIN TRANSACTION;

    IF EXISTS
    (
        SELECT 1
        FROM sys.columns AS c
        INNER JOIN sys.types AS t ON t.user_type_id = c.user_type_id
        WHERE c.[object_id] = OBJECT_ID(N'[dbo].[Users_log]')
          AND c.[name] = N'UserName'
          AND t.[name] = N'nvarchar'
          AND c.max_length = 255 * 2
    )
        THROW 51045, N'dbo.Users_log.UserName 已經是 nvarchar(255)，請先確認舊版腳本是否曾執行。', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM sys.columns AS c
        INNER JOIN sys.types AS t ON t.user_type_id = c.user_type_id
        WHERE c.[object_id] = OBJECT_ID(N'[dbo].[Users_log]')
          AND c.[name] = N'UserName'
          AND t.[name] = N'nvarchar'
          AND c.max_length = 20 * 2
          AND c.is_nullable = 1
    )
        THROW 51046, N'dbo.Users_log.UserName 目前型別不是預期中的 NULL nvarchar(20)，請確認現況後再執行。', 1;

    -- Users_log 是 Users 的異動歷程快照表，UserName 沒有被任何索引或條件約束引用，
    -- 直接加寬即可，不需要處理索引重建。
    ALTER TABLE [dbo].[Users_log]
        ALTER COLUMN [UserName] [nvarchar](255) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL;

    IF NOT EXISTS
    (
        SELECT 1
        FROM sys.columns AS c
        INNER JOIN sys.types AS t ON t.user_type_id = c.user_type_id
        WHERE c.[object_id] = OBJECT_ID(N'[dbo].[Users_log]')
          AND c.[name] = N'UserName'
          AND t.[name] = N'nvarchar'
          AND c.max_length = 255 * 2
          AND c.is_nullable = 1
    )
        THROW 51047, N'dbo.Users_log.UserName 加寬為 nvarchar(255) 失敗，請確認執行結果。', 1;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;
