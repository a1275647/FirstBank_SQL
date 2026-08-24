SET NOCOUNT ON;
SET XACT_ABORT ON;

IF OBJECT_ID(N'[dbo].[Users]', N'U') IS NULL
    THROW 51040, N'缺少前置資料表 dbo.Users。', 1;

BEGIN TRY
    BEGIN TRANSACTION;

    IF EXISTS
    (
        SELECT 1
        FROM sys.columns AS c
        INNER JOIN sys.types AS t ON t.user_type_id = c.user_type_id
        WHERE c.[object_id] = OBJECT_ID(N'[dbo].[Users]')
          AND c.[name] = N'UserName'
          AND t.[name] = N'nvarchar'
          AND c.max_length = 255 * 2
    )
        THROW 51041, N'dbo.Users.UserName 已經是 nvarchar(255)，請先確認舊版腳本是否曾執行。', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM sys.columns AS c
        INNER JOIN sys.types AS t ON t.user_type_id = c.user_type_id
        WHERE c.[object_id] = OBJECT_ID(N'[dbo].[Users]')
          AND c.[name] = N'UserName'
          AND t.[name] = N'nvarchar'
          AND c.max_length = 20 * 2
          AND c.is_nullable = 0
    )
        THROW 51042, N'dbo.Users.UserName 目前型別不是預期中的 NOT NULL nvarchar(20)，請確認現況後再執行。', 1;

    -- UserName 是 IX_Users(UserId, UserName) 唯一索引的鍵欄位之一；加寬 nvarchar 長度
    -- SQL Server 會直接就地更新索引 metadata，不需要另外 DROP/CREATE INDEX。
    ALTER TABLE [dbo].[Users]
        ALTER COLUMN [UserName] [nvarchar](255) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL;

    IF NOT EXISTS
    (
        SELECT 1
        FROM sys.columns AS c
        INNER JOIN sys.types AS t ON t.user_type_id = c.user_type_id
        WHERE c.[object_id] = OBJECT_ID(N'[dbo].[Users]')
          AND c.[name] = N'UserName'
          AND t.[name] = N'nvarchar'
          AND c.max_length = 255 * 2
          AND c.is_nullable = 0
    )
        THROW 51043, N'dbo.Users.UserName 加寬為 nvarchar(255) 失敗，請確認執行結果。', 1;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;
