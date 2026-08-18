SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_CreateTempTable]
    @TableName NVARCHAR(128)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TempTableName NVARCHAR(128) = @TableName + '_temp';
    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @ColumnDefinitions NVARCHAR(MAX) = '';
    DECLARE @SchemaName NVARCHAR(128) = 'dbo';
    DECLARE @ObjectId INT;

    -- 檢查原始表是否存在
    IF NOT EXISTS (
        SELECT 1
        FROM INFORMATION_SCHEMA.TABLES
        WHERE TABLE_NAME = @TableName
          AND TABLE_SCHEMA = @SchemaName
    )
    BEGIN
        RAISERROR('原始表 %s 不存在', 16, 1, @TableName);
        RETURN;
    END

    -- 取得 Object ID
    SET @ObjectId = OBJECT_ID(@SchemaName + '.' + @TableName);

    IF @ObjectId IS NULL
    BEGIN
        RAISERROR('無法取得表 %s 的 Object ID', 16, 1, @TableName);
        RETURN;
    END

    -- 檢查 Temp 表是否已存在
    IF EXISTS (
        SELECT 1
        FROM INFORMATION_SCHEMA.TABLES
        WHERE TABLE_NAME = @TempTableName
          AND TABLE_SCHEMA = @SchemaName
    )
    BEGIN
        RAISERROR('Temp 表 %s 已經存在', 16, 1, @TempTableName);
        RETURN;
    END

    -- 檢查 FlowForm 表是否存在
    IF NOT EXISTS (
        SELECT 1
        FROM INFORMATION_SCHEMA.TABLES
        WHERE TABLE_NAME = 'FlowForm'
          AND TABLE_SCHEMA = @SchemaName
    )
    BEGIN
        RAISERROR('FlowForm 表不存在，無法建立外鍵', 16, 1);
        RETURN;
    END

    -- 取得原始表的欄位定義（包含 NULL/NOT NULL 和預設值）
    SELECT @ColumnDefinitions = @ColumnDefinitions +
        '    ' + QUOTENAME(c.COLUMN_NAME) + ' ' +
        c.DATA_TYPE +
        CASE
            WHEN c.DATA_TYPE IN ('varchar', 'char', 'nvarchar', 'nchar')
            THEN '(' + CASE WHEN c.CHARACTER_MAXIMUM_LENGTH = -1
                           THEN 'MAX'
                           ELSE CAST(c.CHARACTER_MAXIMUM_LENGTH AS VARCHAR(10))
                       END + ')'
            WHEN c.DATA_TYPE IN ('decimal', 'numeric')
            THEN '(' + CAST(c.NUMERIC_PRECISION AS VARCHAR(10)) + ',' +
                      CAST(c.NUMERIC_SCALE AS VARCHAR(10)) + ')'
            WHEN c.DATA_TYPE IN ('datetime2', 'time', 'datetimeoffset')
            THEN '(' + CAST(c.DATETIME_PRECISION AS VARCHAR(10)) + ')'
            ELSE ''
        END +
        -- 保留原始表的 NULL/NOT NULL 設定
        CASE WHEN c.IS_NULLABLE = 'NO' THEN ' NOT NULL' ELSE ' NULL' END +
        -- 加入預設值
        CASE
            WHEN dc.definition IS NOT NULL
            THEN ' DEFAULT ' + dc.definition
            ELSE ''
        END +
        ',' + CHAR(13) + CHAR(10)
    FROM INFORMATION_SCHEMA.COLUMNS c
    LEFT JOIN sys.columns sc
        ON sc.object_id = @ObjectId
        AND sc.name = c.COLUMN_NAME
    LEFT JOIN sys.default_constraints dc
        ON dc.parent_object_id = @ObjectId
        AND dc.parent_column_id = sc.column_id
    WHERE c.TABLE_NAME = @TableName
      AND c.TABLE_SCHEMA = @SchemaName
    ORDER BY c.ORDINAL_POSITION;

    -- 檢查欄位定義是否為空
    IF LEN(@ColumnDefinitions) = 0
    BEGIN
        RAISERROR('錯誤: 無法取得表 %s 的欄位定義', 16, 1, @TableName);
        RETURN;
    END

    -- 移除最後一個逗號和換行
    SET @ColumnDefinitions = LEFT(@ColumnDefinitions, LEN(@ColumnDefinitions) - 3);

    -- 建立 Temp 表的 SQL
    SET @SQL =
        'CREATE TABLE ' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TempTableName) + ' (' + CHAR(13) + CHAR(10) +
        '    [TempId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,' + CHAR(13) + CHAR(10) +
        '    [FlowFormId] INT NULL,' + CHAR(13) + CHAR(10) +
        '    [ModifyType] NVARCHAR(10) NOT NULL,' + CHAR(13) + CHAR(10) +
        @ColumnDefinitions + ',' + CHAR(13) + CHAR(10) +
        '    [SysCreateDate] DATETIME NOT NULL DEFAULT GETDATE(),' + CHAR(13) + CHAR(10) +
        '    [SysCreateUser] NVARCHAR(100) NOT NULL,' + CHAR(13) + CHAR(10) +
        '    CONSTRAINT [FK_' + @TempTableName + '_FlowForm] FOREIGN KEY ([FlowFormId]) ' + CHAR(13) + CHAR(10) +
        '        REFERENCES ' + QUOTENAME(@SchemaName) + '.[FlowForm]([PK_ID])' + CHAR(13) + CHAR(10) +
        ');';

    BEGIN TRY
        -- 執行建立表的 SQL
        EXEC sp_executesql @SQL;
        PRINT '✓ 成功建立 Temp 表: ' + @TempTableName;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('建立 Temp 表失敗: %s', 16, 1, @ErrorMessage);
        RETURN;
    END CATCH

    -- ========== 加入欄位註釋 ==========
    BEGIN TRY
        EXEC sys.sp_addextendedproperty
            @name = N'MS_Description',
            @value = N'暫存資料識別碼（流水號）',
            @level0type = N'SCHEMA', @level0name = @SchemaName,
            @level1type = N'TABLE',  @level1name = @TempTableName,
            @level2type = N'COLUMN', @level2name = N'TempId';

        EXEC sys.sp_addextendedproperty
            @name = N'MS_Description',
            @value = N'流程表單識別碼（外鍵：FlowForm.PK_ID）',
            @level0type = N'SCHEMA', @level0name = @SchemaName,
            @level1type = N'TABLE',  @level1name = @TempTableName,
            @level2type = N'COLUMN', @level2name = N'FlowFormId';

        PRINT '✓ 成功加入欄位註釋';
    END TRY
    BEGIN CATCH
        PRINT '⚠ 加入欄位註釋時發生警告: ' + ERROR_MESSAGE();
    END CATCH

    PRINT '========================================';
    PRINT '✓ 完成! Temp 表建立成功: ' + @TempTableName;
END;
GO
