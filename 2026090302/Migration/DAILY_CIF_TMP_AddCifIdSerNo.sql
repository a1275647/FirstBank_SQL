SET NOCOUNT ON;
SET XACT_ABORT ON;

-- dbo.DAILY_CIF_TMP 新增 CIF_ID_SER_NO（統一編號序號），對應 Oracle DTCIF.DAILY_CIF_TMP
-- 的 CIF_ID_SER_NO CHAR(1)，供 DataMigrationByDwService.MigrateAllAsync 一併同步帶入。

IF OBJECT_ID(N'[dbo].[DAILY_CIF_TMP]', N'U') IS NULL
    THROW 51500, N'缺少資料表 dbo.DAILY_CIF_TMP。', 1;

BEGIN TRY
    BEGIN TRANSACTION;

    IF EXISTS (SELECT 1 FROM sys.columns WHERE [object_id] = OBJECT_ID(N'[dbo].[DAILY_CIF_TMP]') AND [name] = N'CIF_ID_SER_NO')
        THROW 51501, N'dbo.DAILY_CIF_TMP.CIF_ID_SER_NO 已存在，請先確認是否已執行過本腳本。', 1;

    ALTER TABLE [dbo].[DAILY_CIF_TMP]
        ADD [CIF_ID_SER_NO] [nvarchar](1) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL;
    EXEC sys.sp_addextendedproperty
        @name = N'MS_Description', @value = N'統一編號序號',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE',  @level1name = N'DAILY_CIF_TMP',
        @level2type = N'COLUMN', @level2name = N'CIF_ID_SER_NO';

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE [object_id] = OBJECT_ID(N'[dbo].[DAILY_CIF_TMP]') AND [name] = N'CIF_ID_SER_NO')
        THROW 51502, N'dbo.DAILY_CIF_TMP 新增 CIF_ID_SER_NO 失敗，請確認執行結果。', 1;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;
