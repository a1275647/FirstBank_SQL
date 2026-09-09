SET NOCOUNT ON;
SET XACT_ABORT ON;

-- 2026082101 建立 IX_MONITORDATA_EXTDATE_MARK_UNIT 時，INCLUDE 清單完整涵蓋當時
-- ufn_table_GetMonitorDataLimitAmount 會讀到的欄位。之後 2026090201 幫 MONITORDATA 新增
-- 根額度欄位，TVF 改以 TOP_Permit_No／TOP_Limit_USD_Amount 計算 SUM_TO_USD_LIMIT（根額度封頂），
-- 但索引沒有跟著補這兩欄，覆蓋因此失效：最佳化工具退回窄索引 IX_MONITORDATA_DATE
-- （只有 EXT_DATE/Year/Month/Week、無 INCLUDE）再逐列回 clustered index 取值。
--
-- 實測（EXT_DATE = '2026-08-06'，18,658 筆）：
--   只讀索引內欄位            →    646 logical reads，走 IX_MONITORDATA_EXTDATE_MARK_UNIT，無 Key Lookup
--   多讀 TOP_Permit_No 等兩欄 → 59,593 logical reads，退回窄索引 + Key Lookup
-- 全行額度動態查詢在 100 併發下，TVF 平均每次 202,570 logical reads，執行計畫中回表
-- （Clustered Index Seek）節點佔總成本約 90%。
--
-- 本腳本以 DROP_EXISTING = ON 就地重建同名索引，鍵值與既有 INCLUDE 順序完全不變，
-- 只在最後補上 TOP_Permit_No、TOP_Limit_USD_Amount 兩欄。

IF OBJECT_ID(N'[dbo].[MONITORDATA]', N'U') IS NULL
    THROW 51310, N'缺少資料表 dbo.MONITORDATA。', 1;

IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE [object_id] = OBJECT_ID(N'[dbo].[MONITORDATA]')
      AND [name] = N'IX_MONITORDATA_EXTDATE_MARK_UNIT'
)
    THROW 51311, N'缺少索引 IX_MONITORDATA_EXTDATE_MARK_UNIT，請先執行 2026082101 批次。', 1;

IF EXISTS
(
    SELECT 1
    FROM sys.index_columns AS ic
    JOIN sys.indexes AS i
        ON i.[object_id] = ic.[object_id] AND i.[index_id] = ic.[index_id]
    JOIN sys.columns AS c
        ON c.[object_id] = ic.[object_id] AND c.[column_id] = ic.[column_id]
    WHERE ic.[object_id] = OBJECT_ID(N'[dbo].[MONITORDATA]')
      AND i.[name] = N'IX_MONITORDATA_EXTDATE_MARK_UNIT'
      AND c.[name] = N'TOP_Permit_No'
)
    THROW 51312, N'IX_MONITORDATA_EXTDATE_MARK_UNIT 已包含 TOP_Permit_No，請先確認是否已執行過本腳本。', 1;

IF NOT EXISTS
(
    SELECT 1
    FROM sys.columns
    WHERE [object_id] = OBJECT_ID(N'[dbo].[MONITORDATA]')
      AND [name] IN (N'TOP_Permit_No', N'TOP_Limit_USD_Amount')
    HAVING COUNT(*) = 2
)
    THROW 51313, N'dbo.MONITORDATA 缺少 TOP_Permit_No／TOP_Limit_USD_Amount，請先執行 2026090201 批次。', 1;

BEGIN TRY
    BEGIN TRANSACTION;

    CREATE NONCLUSTERED INDEX [IX_MONITORDATA_EXTDATE_MARK_UNIT] ON [dbo].[MONITORDATA]
    (
        [EXT_DATE] ASC,
        [Mark] ASC
    )
    INCLUDE
    (
        [GROUP_NO],[UNIT_NO],[BRANCH_NO],
        [COUNTRY_COD],[PRODUCT_TYPE],[PRODUCT_CODE],[TRAN_NO],[TX_DATE],[PERMIT_NO],
        [CUSTOMER_ID],[CUSTOMER_NAME],[TO_USD_AMT],[TO_USD_LIMIT],[TRAN_AMOUNT],
        [CURENCY_COD],[LIMIT],[LIMIT_COD],[AS_OF_DATE],[MATURITY_DATE],[LIMIT_MATURITY],
        [RISKFACTOR],[INDUSTRY],[INDUSTRY_Type],[WEIGHTS],[CUR_BOUGHT],[CUR_SOLD],
        [TRAN_FXRATE],[LIMIT_FXRATE],[CAL_TO_USD_AMT],[CAL_TO_USD_LIMIT],
        -- 2026090901 新增：讓 ufn_table_GetMonitorDataLimitAmount 的根額度封頂計算重新被覆蓋
        [TOP_Permit_No],[TOP_Limit_USD_Amount]
    )
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = ON, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX];

    IF NOT EXISTS
    (
        SELECT 1
        FROM sys.index_columns AS ic
        JOIN sys.indexes AS i
            ON i.[object_id] = ic.[object_id] AND i.[index_id] = ic.[index_id]
        JOIN sys.columns AS c
            ON c.[object_id] = ic.[object_id] AND c.[column_id] = ic.[column_id]
        WHERE ic.[object_id] = OBJECT_ID(N'[dbo].[MONITORDATA]')
          AND i.[name] = N'IX_MONITORDATA_EXTDATE_MARK_UNIT'
          AND ic.[is_included_column] = 1
          AND c.[name] IN (N'TOP_Permit_No', N'TOP_Limit_USD_Amount')
        HAVING COUNT(*) = 2
    )
        THROW 51314, N'IX_MONITORDATA_EXTDATE_MARK_UNIT 重建後未包含新增的兩個 INCLUDE 欄位，請確認執行結果。', 1;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;
