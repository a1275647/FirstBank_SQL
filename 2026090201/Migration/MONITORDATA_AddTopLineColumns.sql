SET NOCOUNT ON;
SET XACT_ABORT ON;

-- dbo.MONITORDATA 已有 TOP_Limit_Amount／TOP_Limit_USD_Amount（根額度核准金額／美金）。
-- 這裡補上剩下 4 個「根額度」欄位，對應 OS_LNSLMSD_D_MF 新增的
-- LNSLMSD_TOP_LINE_LINE_NO / LNSLMSD_TOP_LINE_CCY / LNSLMSD_TOP_LINE_CRISK /
-- LNSLMSD_TOP_LINE_MATURITY（見 2026090102），未來轉檔進 MONITORDATA 時會用到。
-- 命名比照既有 TOP_Limit_Amount 的風格：TOP_ 前綴 + 對應既有欄位語意
-- （PERMIT_NO／LIMIT_COD／COUNTRY_COD／LIMIT_MATURITY）。
--
-- 本批次只新增欄位，不異動任何 usp_SouceXX SP 或 C# Entity／DTO——目前 TOP_Limit_Amount／
-- TOP_Limit_USD_Amount 本身也還沒有對應到 MONITORDATA.cs／MONITORDATA_his.cs／
-- MONITORDATA_temp.cs，這 4 個新欄位比照維持同樣狀態，先讓 DB schema 就緒。

IF OBJECT_ID(N'[dbo].[MONITORDATA]', N'U') IS NULL
    THROW 59400, N'缺少資料表 dbo.MONITORDATA。', 1;

BEGIN TRY
    BEGIN TRANSACTION;

    IF EXISTS (SELECT 1 FROM sys.columns WHERE [object_id] = OBJECT_ID(N'[dbo].[MONITORDATA]') AND [name] = N'TOP_Permit_No')
        THROW 59401, N'dbo.MONITORDATA.TOP_Permit_No 已存在，請先確認是否已執行過本腳本。', 1;

    ALTER TABLE [dbo].[MONITORDATA]
        ADD [TOP_Permit_No] [nvarchar](13) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL;
    EXEC sys.sp_addextendedproperty
        @name = N'MS_Description', @value = N'根額度OBBS額度號碼',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE',  @level1name = N'MONITORDATA',
        @level2type = N'COLUMN', @level2name = N'TOP_Permit_No';

    ALTER TABLE [dbo].[MONITORDATA]
        ADD [TOP_Limit_Cod] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL;
    EXEC sys.sp_addextendedproperty
        @name = N'MS_Description', @value = N'根額度幣別',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE',  @level1name = N'MONITORDATA',
        @level2type = N'COLUMN', @level2name = N'TOP_Limit_Cod';

    ALTER TABLE [dbo].[MONITORDATA]
        ADD [TOP_Country_Cod] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL;
    EXEC sys.sp_addextendedproperty
        @name = N'MS_Description', @value = N'根額度風險國別',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE',  @level1name = N'MONITORDATA',
        @level2type = N'COLUMN', @level2name = N'TOP_Country_Cod';

    ALTER TABLE [dbo].[MONITORDATA]
        ADD [TOP_Limit_Maturity] [date] NULL;
    EXEC sys.sp_addextendedproperty
        @name = N'MS_Description', @value = N'根額度到期日',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE',  @level1name = N'MONITORDATA',
        @level2type = N'COLUMN', @level2name = N'TOP_Limit_Maturity';

    IF NOT EXISTS
    (
        SELECT 1
        FROM sys.columns AS c
        WHERE c.[object_id] = OBJECT_ID(N'[dbo].[MONITORDATA]')
          AND c.[name] IN (N'TOP_Permit_No', N'TOP_Limit_Cod', N'TOP_Country_Cod', N'TOP_Limit_Maturity')
        HAVING COUNT(*) = 4
    )
        THROW 59402, N'dbo.MONITORDATA 新增根額度欄位失敗，請確認執行結果。', 1;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;
