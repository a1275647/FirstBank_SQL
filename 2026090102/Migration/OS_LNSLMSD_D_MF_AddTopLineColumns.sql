SET NOCOUNT ON;
SET XACT_ABORT ON;

-- dbo.OS_LNSLMSD_D_MF 新增 5 個「根額度」欄位，對應 Oracle DTHST.OS_LNSLMSD_D_MF 新增的
-- LNSLMSD_TOP_LINE_LINE_NO / LNSLMSD_TOP_LINE_CCY / LNSLMSD_TOP_LINE_APP_AMT /
-- LNSLMSD_TOP_LINE_CRISK / LNSLMSD_TOP_LINE_MATURITY。
--
-- 注意：LNSLMSD_TOP_LINE_MATURITY 在 Oracle 端是 CHAR(10)（yyyyMMdd 右補空白至 10 碼，
-- 不是原生 DATE），SQL Server 端仍用 date 型別落地，C# 端 OracleDbContext 已用
-- OracleCharDateOnlyConverter（Trim 後以 yyyyMMdd 解析）轉換，比照 EL_ELLSTAPV_D_MF／
-- ACOLRT_STG 既有作法。

IF OBJECT_ID(N'[dbo].[OS_LNSLMSD_D_MF]', N'U') IS NULL
    THROW 59300, N'缺少資料表 dbo.OS_LNSLMSD_D_MF。', 1;

BEGIN TRY
    BEGIN TRANSACTION;

    IF EXISTS (SELECT 1 FROM sys.columns WHERE [object_id] = OBJECT_ID(N'[dbo].[OS_LNSLMSD_D_MF]') AND [name] = N'LNSLMSD_TOP_LINE_LINE_NO')
        THROW 59301, N'dbo.OS_LNSLMSD_D_MF.LNSLMSD_TOP_LINE_LINE_NO 已存在，請先確認是否已執行過本腳本。', 1;

    ALTER TABLE [dbo].[OS_LNSLMSD_D_MF]
        ADD [LNSLMSD_TOP_LINE_LINE_NO] [nvarchar](13) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL;
    EXEC sys.sp_addextendedproperty
        @name = N'MS_Description', @value = N'根額度OBBS額度號碼',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE',  @level1name = N'OS_LNSLMSD_D_MF',
        @level2type = N'COLUMN', @level2name = N'LNSLMSD_TOP_LINE_LINE_NO';

    ALTER TABLE [dbo].[OS_LNSLMSD_D_MF]
        ADD [LNSLMSD_TOP_LINE_CCY] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL;
    EXEC sys.sp_addextendedproperty
        @name = N'MS_Description', @value = N'根額度幣別',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE',  @level1name = N'OS_LNSLMSD_D_MF',
        @level2type = N'COLUMN', @level2name = N'LNSLMSD_TOP_LINE_CCY';

    ALTER TABLE [dbo].[OS_LNSLMSD_D_MF]
        ADD [LNSLMSD_TOP_LINE_APP_AMT] [decimal](17, 2) NULL;
    EXEC sys.sp_addextendedproperty
        @name = N'MS_Description', @value = N'根額度核准金額',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE',  @level1name = N'OS_LNSLMSD_D_MF',
        @level2type = N'COLUMN', @level2name = N'LNSLMSD_TOP_LINE_APP_AMT';

    ALTER TABLE [dbo].[OS_LNSLMSD_D_MF]
        ADD [LNSLMSD_TOP_LINE_CRISK] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL;
    EXEC sys.sp_addextendedproperty
        @name = N'MS_Description', @value = N'根額度風險國別',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE',  @level1name = N'OS_LNSLMSD_D_MF',
        @level2type = N'COLUMN', @level2name = N'LNSLMSD_TOP_LINE_CRISK';

    ALTER TABLE [dbo].[OS_LNSLMSD_D_MF]
        ADD [LNSLMSD_TOP_LINE_MATURITY] [date] NULL;
    EXEC sys.sp_addextendedproperty
        @name = N'MS_Description', @value = N'根額度到期日',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE',  @level1name = N'OS_LNSLMSD_D_MF',
        @level2type = N'COLUMN', @level2name = N'LNSLMSD_TOP_LINE_MATURITY';

    IF NOT EXISTS
    (
        SELECT 1
        FROM sys.columns AS c
        WHERE c.[object_id] = OBJECT_ID(N'[dbo].[OS_LNSLMSD_D_MF]')
          AND c.[name] IN (N'LNSLMSD_TOP_LINE_LINE_NO', N'LNSLMSD_TOP_LINE_CCY', N'LNSLMSD_TOP_LINE_APP_AMT', N'LNSLMSD_TOP_LINE_CRISK', N'LNSLMSD_TOP_LINE_MATURITY')
        HAVING COUNT(*) = 5
    )
        THROW 59302, N'dbo.OS_LNSLMSD_D_MF 新增根額度欄位失敗，請確認執行結果。', 1;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;
