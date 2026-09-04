SET NOCOUNT ON;
SET XACT_ABORT ON;

-- DataMigrationByDwService.MigrateAsync 每日對 DAILY_CIF_TMP 執行
--   ExecuteDeleteAsync()  WHERE CIF_EXT_DATE = @date
-- 再整批 BulkInsertAsync 寫回。2026082702 移除了誤設的 Clustered PK（PK_DAILY_CIF_TMP，
-- 建在 CIF_ID_NO 上）之後，這張表變成純 heap table；2026090101 的
-- Source06_AddJoinIndexes.sql 雖然有幫這張表補索引，但補的是 usp_Souce06_By_FL_FLMST_D_MF
-- 這支 SP 需要的 CIF_ID_NO（IX_DAILY_CIF_TMP_CifIdNo），並未涵蓋轉檔服務實際篩選用的
-- CIF_EXT_DATE，所以每天的 ExecuteDeleteAsync 仍是全表掃描，資料量長大後就會逾時
-- （已實際觀測到 CommandTimeout=30 逾時失敗）。這裡補上 CIF_EXT_DATE 的索引。

IF OBJECT_ID(N'[dbo].[DAILY_CIF_TMP]', N'U') IS NULL
    THROW 59410, N'缺少資料表 dbo.DAILY_CIF_TMP。', 1;

IF EXISTS (SELECT 1 FROM sys.indexes WHERE [object_id] = OBJECT_ID(N'[dbo].[DAILY_CIF_TMP]') AND [name] = N'IX_DAILY_CIF_TMP_ExtDate')
    THROW 59411, N'dbo.DAILY_CIF_TMP 已存在索引 IX_DAILY_CIF_TMP_ExtDate，請先確認是否已執行過本腳本。', 1;

BEGIN TRY
    BEGIN TRANSACTION;

    CREATE NONCLUSTERED INDEX [IX_DAILY_CIF_TMP_ExtDate] ON [dbo].[DAILY_CIF_TMP]
    (
        [CIF_EXT_DATE] ASC
    )
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX];

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;
