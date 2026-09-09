SET NOCOUNT ON;
SET XACT_ABORT ON;

-- 本腳本合併兩個既有批次，讓不確定目標環境現況的情況下也能一次跑到最終狀態，
-- 不需要事先知道該環境跑過哪一批次：
--   1. 2026082101（Table/MONITORDATA_AddTransactionDataIndex.sql）
--      建立索引 IX_MONITORDATA_EXTDATE_MARK_UNIT，INCLUDE 30 個欄位。
--   2. 2026090901（Table/MONITORDATA_ExtendTransactionDataIndexIncludes.sql）
--      以 DROP_EXISTING 重建同一索引，INCLUDE 再補上 TOP_Permit_No、
--      TOP_Limit_USD_Amount 兩欄，共 32 個 INCLUDE 欄位。
-- 鍵值（EXT_DATE, Mark）與 INCLUDE 欄位順序完全沿用原兩個批次。
--
-- 索引用途（節錄自原兩個批次的說明）：
-- 全行額度／產品別／產業別三支動態查詢的交易明細分頁查詢（DimensionService.
-- GetQuotaTransactionDataList／GetProductTransactionDataListAsync／
-- GetIndustryNewTransactionDataList，共用 QueryMonitorDataBase／
-- GetTransactionDataQuery）皆以 EXT_DATE、Mark 過濾，並以 GROUP_NO/UNIT_NO/
-- BRANCH_NO 三欄 OR 篩選權限單位；既有索引 IX_MONITORDATA_ASOFDATE_MARK、
-- IX_MONITORDATA_ASOFDATE_PAGING 領頭欄位是 AS_OF_DATE，跟查詢實際使用的
-- EXT_DATE 對不起來，唯一領頭 EXT_DATE 的 IX_MONITORDATA_DATE 又沒有 INCLUDE，
-- 導致查詢改用 Clustered Index Scan／Key Lookup。
-- 之後 ufn_table_GetMonitorDataLimitAmount 改以 TOP_Permit_No／
-- TOP_Limit_USD_Amount 計算同一根額度下的子額度加總（以根額度上限封頂），
-- 若索引沒有 INCLUDE 這兩欄，覆蓋會再次失效，因此兩批次的最終狀態需一併涵蓋。
--
-- 本腳本會依目標環境現況自動判斷該做什麼，執行後只會落在下列三種結果之一：
--   A. 索引不存在              → 直接建立（32 欄 INCLUDE）。
--   B. 索引存在但缺這兩個新欄位 → 以 DROP_EXISTING 就地重建補上（等同 2026090901）。
--   C. 索引存在且已含這兩欄     → 已是最終狀態，不做任何事，僅印出訊息。
-- 可安全重跑：不論目標環境先前跑過 0、1 或 2 個原批次，重跑本腳本都會收斂到同一
-- 最終狀態，不會有第二個同名索引，也不會對已是最終狀態的環境誤報錯誤。
--
-- 前置條件：
--   1. dbo.MONITORDATA 存在。
--   2. dbo.MONITORDATA 已有 TOP_Permit_No、TOP_Limit_USD_Amount 兩欄
--      （見批次 2026090201，Migration/MONITORDATA_AddTopLineColumns.sql）。
--      若目標環境尚未新增這兩欄，請先執行該批次的 ALTER TABLE 腳本。
--
-- 執行注意事項（沿用原兩個批次）：
-- MONITORDATA 為大型交易明細表，索引建立／重建預設離線（ONLINE = OFF），執行
-- 期間會鎖表；建議於離峰維護時段執行，並確認檔案群組 NCRMS_IDX 有足夠可用空間
-- （INCLUDE 32 個欄位，索引本身會佔用不小的額外空間；情況 B 的重建期間另需
-- 相當於索引大小的暫存空間）。若目標環境為 Enterprise／Developer Edition 且
-- 需要線上建置／重建，可自行將 ONLINE = OFF 改為 ONLINE = ON（本腳本未預設
-- 開啟，以免在 Standard Edition 直接失敗）。

IF OBJECT_ID(N'[dbo].[MONITORDATA]', N'U') IS NULL
    THROW 51600, N'缺少資料表 dbo.MONITORDATA。', 1;

IF NOT EXISTS
(
    SELECT 1
    FROM sys.columns
    WHERE [object_id] = OBJECT_ID(N'[dbo].[MONITORDATA]')
      AND [name] IN (N'TOP_Permit_No', N'TOP_Limit_USD_Amount')
    HAVING COUNT(*) = 2
)
    THROW 51601, N'dbo.MONITORDATA 缺少 TOP_Permit_No／TOP_Limit_USD_Amount，請先執行批次 2026090201（Migration/MONITORDATA_AddTopLineColumns.sql）。', 1;

DECLARE @indexExists bit = CASE WHEN EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE [object_id] = OBJECT_ID(N'[dbo].[MONITORDATA]')
      AND [name] = N'IX_MONITORDATA_EXTDATE_MARK_UNIT'
) THEN 1 ELSE 0 END;

DECLARE @hasTopIncludes bit = CASE WHEN EXISTS
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
) THEN 1 ELSE 0 END;

-- 情況 C：已是最終狀態，不需要做任何事。
IF @indexExists = 1 AND @hasTopIncludes = 1
BEGIN
    PRINT N'IX_MONITORDATA_EXTDATE_MARK_UNIT 已是最終狀態（已存在且已包含 TOP_Permit_No／TOP_Limit_USD_Amount），本腳本不做任何變更。';
    RETURN;
END

BEGIN TRY
    BEGIN TRANSACTION;

    IF @indexExists = 0
    BEGIN
        -- 情況 A：索引不存在，直接建立。
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
            [TOP_Permit_No],[TOP_Limit_USD_Amount]
        )
        WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX];
    END
    ELSE
    BEGIN
        -- 情況 B：索引已存在但缺 TOP_Permit_No／TOP_Limit_USD_Amount，就地重建補上。
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
            -- 2026090901：ufn_table_GetMonitorDataLimitAmount 改用根額度分組計算後，
            -- 這兩欄才被覆蓋，缺一就會退回 Key Lookup。
            [TOP_Permit_No],[TOP_Limit_USD_Amount]
        )
        WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = ON, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX];
    END

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
        THROW 51603, N'IX_MONITORDATA_EXTDATE_MARK_UNIT 執行後未包含預期的 INCLUDE 欄位，請確認執行結果。', 1;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;
