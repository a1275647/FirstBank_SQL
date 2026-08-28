SET NOCOUNT ON;
SET XACT_ABORT ON;

IF OBJECT_ID(N'[dbo].[EL_ELLSTAPV_D_MF]', N'U') IS NULL
    THROW 51050, N'缺少前置資料表 dbo.EL_ELLSTAPV_D_MF。', 1;

BEGIN TRY
    BEGIN TRANSACTION;

    IF EXISTS
    (
        SELECT 1
        FROM sys.columns AS c
        WHERE c.[object_id] = OBJECT_ID(N'[dbo].[EL_ELLSTAPV_D_MF]')
          AND c.[name] = N'ELLSTAPV_EXT_DATE'
    )
        THROW 51051, N'dbo.EL_ELLSTAPV_D_MF.ELLSTAPV_EXT_DATE 已存在，請先確認舊版腳本是否曾執行。', 1;

    -- Oracle DTEL.EL_ELLSTAPV_D_MF.ELLSTAPV_EXT_DATE 來源是 CHAR(8)，轉檔時已在
    -- OracleDbContext 以 CHAR->DateOnly 轉換器處理，SQL Server 端維持一般 date 型別即可。
    ALTER TABLE [dbo].[EL_ELLSTAPV_D_MF]
        ADD [ELLSTAPV_EXT_DATE] [date] NULL;

    EXEC sys.sp_addextendedproperty
        @name = N'MS_Description', @value = N'資料日期',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE',  @level1name = N'EL_ELLSTAPV_D_MF',
        @level2type = N'COLUMN', @level2name = N'ELLSTAPV_EXT_DATE';

    IF NOT EXISTS
    (
        SELECT 1
        FROM sys.columns AS c
        WHERE c.[object_id] = OBJECT_ID(N'[dbo].[EL_ELLSTAPV_D_MF]')
          AND c.[name] = N'ELLSTAPV_EXT_DATE'
    )
        THROW 51052, N'dbo.EL_ELLSTAPV_D_MF 新增 ELLSTAPV_EXT_DATE 失敗，請確認執行結果。', 1;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;
