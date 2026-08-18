SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_CreateHistoryTable_Detail]
    @TableName NVARCHAR(128)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @HistoryTableName NVARCHAR(128) = @TableName + '_his';
    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @ColumnDefinitions NVARCHAR(MAX) = '';
    DECLARE @SchemaName NVARCHAR(128) = 'dbo';
    -- 檢查原始表是否存在
    IF NOT EXISTS (
        SELECT 1
        FROM INFORMATION_SCHEMA.TABLES
        WHERE TABLE_NAME = @TableName
    )
    BEGIN
        RAISERROR('原始表 %s 不存在', 16, 1, @TableName);
        RETURN;
    END

    -- 檢查歷史表是否已存在
    IF EXISTS (
        SELECT 1
        FROM INFORMATION_SCHEMA.TABLES
        WHERE TABLE_NAME = @HistoryTableName
    )
    BEGIN
        RAISERROR('歷史表 %s 已經存在', 16, 1, @HistoryTableName);
        RETURN;
    END

    -- 取得原始表的欄位定義
    SELECT @ColumnDefinitions = @ColumnDefinitions +
        QUOTENAME(COLUMN_NAME) + ' ' +
        DATA_TYPE +
        CASE
            WHEN DATA_TYPE IN ('varchar', 'char', 'nvarchar', 'nchar')
            THEN '(' + CASE WHEN CHARACTER_MAXIMUM_LENGTH = -1
                           THEN 'MAX'
                           ELSE CAST(CHARACTER_MAXIMUM_LENGTH AS VARCHAR(10))
                       END + ')'
            WHEN DATA_TYPE IN ('decimal', 'numeric')
            THEN '(' + CAST(NUMERIC_PRECISION AS VARCHAR(10)) + ',' +
                      CAST(NUMERIC_SCALE AS VARCHAR(10)) + ')'
            ELSE ''
        END +
        CASE WHEN IS_NULLABLE = 'NO' THEN ' NOT NULL' ELSE ' NULL' END +
        ',' + CHAR(13) + CHAR(10)
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = @TableName
    ORDER BY ORDINAL_POSITION;

    -- 移除最後一個逗號和換行
    IF LEN(@ColumnDefinitions) > 0
    BEGIN
        SET @ColumnDefinitions = LEFT(@ColumnDefinitions, LEN(@ColumnDefinitions) - 3);
    END

    -- 建立歷史表的 SQL
    SET @SQL =
        'CREATE TABLE ' + QUOTENAME(@HistoryTableName) + ' (' + CHAR(13) + CHAR(10) +
        '    Log_id int IDENTITY(1,1) PRIMARY KEY,' + CHAR(13) + CHAR(10) +
        '    LogType NVARCHAR(10) NOT NULL,' + CHAR(13) + CHAR(10) +
		'	 Fk_logId Int NOT NULL,' + CHAR(13) + CHAR(10) +
        @ColumnDefinitions + ',' + CHAR(13) + CHAR(10) +
        '    SysCreateDate DATETIME NOT NULL DEFAULT GETDATE(),' + CHAR(13) + CHAR(10) +
        '    SysCreateUser NVARCHAR(100) NOT NULL' + CHAR(13) + CHAR(10) +
        ');';
    BEGIN TRY
    -- 執行建立表的 SQL
    EXEC sp_executesql @SQL;
    PRINT '成功建立歷史表: ' + @HistoryTableName;
	END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('建立歷史表失敗: %s', 16, 1, @ErrorMessage);
        RETURN;
    END CATCH
	-- ========== 新增：加入欄位註釋 ==========
    EXEC sys.sp_addextendedproperty
        @name = N'MS_Description',
        @value = N'歷史記錄識別碼',
        @level0type = N'SCHEMA', @level0name = @SchemaName,
        @level1type = N'TABLE',  @level1name = @HistoryTableName,
        @level2type = N'COLUMN', @level2name = N'log_id';

    EXEC sys.sp_addextendedproperty
        @name = N'MS_Description',
        @value = N'異動行為類型 (INSERT/UPDATE/DELETE)',
        @level0type = N'SCHEMA', @level0name = @SchemaName,
        @level1type = N'TABLE',  @level1name = @HistoryTableName,
        @level2type = N'COLUMN', @level2name = N'LogType';

    EXEC sys.sp_addextendedproperty
        @name = N'MS_Description',
        @value = N'系統建立日期時間',
        @level0type = N'SCHEMA', @level0name = @SchemaName,
        @level1type = N'TABLE',  @level1name = @HistoryTableName,
        @level2type = N'COLUMN', @level2name = N'SysCreateDate';

    EXEC sys.sp_addextendedproperty
        @name = N'MS_Description',
        @value = N'系統建立使用者',
        @level0type = N'SCHEMA', @level0name = @SchemaName,
        @level1type = N'TABLE',  @level1name = @HistoryTableName,
        @level2type = N'COLUMN', @level2name = N'SysCreateUser';

    PRINT '✓ 成功加入欄位註釋';
    -- ========================================
    PRINT '完成!';
END;
GO
