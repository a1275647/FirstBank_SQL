SET NOCOUNT ON;
SET XACT_ABORT ON;

IF OBJECT_ID(N'[dbo].[DAILY_CIF_TMP]', N'U') IS NULL
    THROW 51060, N'缺少前置資料表 dbo.DAILY_CIF_TMP。', 1;

BEGIN TRY
    BEGIN TRANSACTION;

    IF NOT EXISTS
    (
        SELECT 1
        FROM sys.key_constraints AS kc
        WHERE kc.parent_object_id = OBJECT_ID(N'[dbo].[DAILY_CIF_TMP]')
          AND kc.[type] = N'PK'
          AND kc.[name] = N'PK_DAILY_CIF_TMP'
    )
        THROW 51061, N'dbo.DAILY_CIF_TMP 找不到 PK_DAILY_CIF_TMP，請先確認是否已被移除。', 1;

    -- DAILY_CIF_TMP 每日由 Oracle 全量覆蓋（DataMigrationByDwService 先 ExecuteDeleteAsync
    -- 再 BulkInsertAsync），CIF_ID_NO 誤設為 Clustered PK；來源當天資料若含重複 CIF_ID_NO，
    -- PK 唯一性限制會讓整批寫入失敗。FirstBankContext 對這張表已是 HasNoKey()，改回不建 PK。
    ALTER TABLE [dbo].[DAILY_CIF_TMP]
        DROP CONSTRAINT [PK_DAILY_CIF_TMP];

    IF EXISTS
    (
        SELECT 1
        FROM sys.key_constraints AS kc
        WHERE kc.parent_object_id = OBJECT_ID(N'[dbo].[DAILY_CIF_TMP]')
          AND kc.[type] = N'PK'
          AND kc.[name] = N'PK_DAILY_CIF_TMP'
    )
        THROW 51062, N'dbo.DAILY_CIF_TMP 移除 PK_DAILY_CIF_TMP 失敗，請確認執行結果。', 1;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;
