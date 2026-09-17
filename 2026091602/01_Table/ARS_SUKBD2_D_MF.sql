SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
-- =============================================
-- ARS_SUKBD2_D_MF：DW（DTARS.ARS_SUKBD2_D_MF）附買回／附賣回交易檔在 SQL Server 的落地表
--   由 TransferDataAPI DataMigrationByDwService 每日以 EXT_DATE 刪除後 BulkInsert，
--   再由 usp_Souce09_By_ARS_SUKBD2_D_MF 轉進 MONITORDATA_STAGE。
--   只保留 Entity（FirstBank_Entity/DWEntity/ARS_SUKBD2_D_MF.cs）用到的欄位。
--   SUKBD2_TRADE_DAY／SUKBD2_END_DATE 在 Oracle 是 CHAR(8) yyyyMMdd，轉入時已解析成 date。
--
--   正式機此表先前為手動建立、欄位不明，本腳本採「不存在就建；存在則逐欄補齊缺少的欄位」，
--   可重複執行。既有欄位若型別不同不會自動改，請以 SqlServerSchemaValidation 結果人工處理。
-- =============================================
IF OBJECT_ID(N'[dbo].[ARS_SUKBD2_D_MF]', N'U') IS NULL
BEGIN
	DECLARE @FilegroupSql NVARCHAR(MAX) = N'';
	SET @FilegroupSql += N'CREATE TABLE [dbo].[ARS_SUKBD2_D_MF](
	[SUKBD2_BRANCH_NO] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKBD2_TRADE_NO] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKBD2_TRADE_TYPE] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKBD2_TRADE_DAY] [date] NULL,
	[SUKBD2_END_DATE] [date] NULL,
	[SUKBD2_REPO_CCY] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKBD2_REPO_AMOUNT] [decimal](17, 2) NULL,
	[SUKBD2_ISSUER_ID] [nvarchar](40) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKBD2_ISSUER_APPID] [nvarchar](11) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKBD2_ISSUER_COUNTRY] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKBD2_EXT_DATE] [date] NULL,
	[Create_date] [datetime] NOT NULL CONSTRAINT [DF_ARS_SUKBD2_D_MF_Create_date] DEFAULT (getdate()),
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL CONSTRAINT [DF_ARS_SUKBD2_D_MF_Create_user] DEFAULT (''system'')
) ON [NCRMS_TAB]';
	IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
		SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
	EXEC sys.sp_executesql @FilegroupSql;
END
GO

-- 既有表逐欄補齊（正式機手動建立的版本可能缺欄位）
IF COL_LENGTH(N'dbo.ARS_SUKBD2_D_MF', N'SUKBD2_BRANCH_NO') IS NULL
	ALTER TABLE [dbo].[ARS_SUKBD2_D_MF] ADD [SUKBD2_BRANCH_NO] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL;
IF COL_LENGTH(N'dbo.ARS_SUKBD2_D_MF', N'SUKBD2_TRADE_NO') IS NULL
	ALTER TABLE [dbo].[ARS_SUKBD2_D_MF] ADD [SUKBD2_TRADE_NO] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL;
IF COL_LENGTH(N'dbo.ARS_SUKBD2_D_MF', N'SUKBD2_TRADE_TYPE') IS NULL
	ALTER TABLE [dbo].[ARS_SUKBD2_D_MF] ADD [SUKBD2_TRADE_TYPE] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL;
IF COL_LENGTH(N'dbo.ARS_SUKBD2_D_MF', N'SUKBD2_TRADE_DAY') IS NULL
	ALTER TABLE [dbo].[ARS_SUKBD2_D_MF] ADD [SUKBD2_TRADE_DAY] [date] NULL;
IF COL_LENGTH(N'dbo.ARS_SUKBD2_D_MF', N'SUKBD2_END_DATE') IS NULL
	ALTER TABLE [dbo].[ARS_SUKBD2_D_MF] ADD [SUKBD2_END_DATE] [date] NULL;
IF COL_LENGTH(N'dbo.ARS_SUKBD2_D_MF', N'SUKBD2_REPO_CCY') IS NULL
	ALTER TABLE [dbo].[ARS_SUKBD2_D_MF] ADD [SUKBD2_REPO_CCY] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL;
IF COL_LENGTH(N'dbo.ARS_SUKBD2_D_MF', N'SUKBD2_REPO_AMOUNT') IS NULL
	ALTER TABLE [dbo].[ARS_SUKBD2_D_MF] ADD [SUKBD2_REPO_AMOUNT] [decimal](17, 2) NULL;
IF COL_LENGTH(N'dbo.ARS_SUKBD2_D_MF', N'SUKBD2_ISSUER_ID') IS NULL
	ALTER TABLE [dbo].[ARS_SUKBD2_D_MF] ADD [SUKBD2_ISSUER_ID] [nvarchar](40) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL;
IF COL_LENGTH(N'dbo.ARS_SUKBD2_D_MF', N'SUKBD2_ISSUER_APPID') IS NULL
	ALTER TABLE [dbo].[ARS_SUKBD2_D_MF] ADD [SUKBD2_ISSUER_APPID] [nvarchar](11) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL;
IF COL_LENGTH(N'dbo.ARS_SUKBD2_D_MF', N'SUKBD2_ISSUER_COUNTRY') IS NULL
	ALTER TABLE [dbo].[ARS_SUKBD2_D_MF] ADD [SUKBD2_ISSUER_COUNTRY] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL;
IF COL_LENGTH(N'dbo.ARS_SUKBD2_D_MF', N'SUKBD2_EXT_DATE') IS NULL
	ALTER TABLE [dbo].[ARS_SUKBD2_D_MF] ADD [SUKBD2_EXT_DATE] [date] NULL;
IF COL_LENGTH(N'dbo.ARS_SUKBD2_D_MF', N'Create_date') IS NULL
	ALTER TABLE [dbo].[ARS_SUKBD2_D_MF] ADD [Create_date] [datetime] NOT NULL CONSTRAINT [DF_ARS_SUKBD2_D_MF_Create_date] DEFAULT (getdate());
IF COL_LENGTH(N'dbo.ARS_SUKBD2_D_MF', N'Create_user') IS NULL
	ALTER TABLE [dbo].[ARS_SUKBD2_D_MF] ADD [Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL CONSTRAINT [DF_ARS_SUKBD2_D_MF_Create_user] DEFAULT ('system');
GO

-- 每日轉檔以 EXT_DATE 刪除／SP 以 MAX(EXT_DATE) 找最新批次，需要此索引（2026090101 已建者略過）
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [object_id] = OBJECT_ID(N'[dbo].[ARS_SUKBD2_D_MF]') AND [name] = N'IX_ARS_SUKBD2_D_MF_ExtDate')
BEGIN
	DECLARE @IndexSql NVARCHAR(MAX) = N'CREATE NONCLUSTERED INDEX [IX_ARS_SUKBD2_D_MF_ExtDate] ON [dbo].[ARS_SUKBD2_D_MF] ([SUKBD2_EXT_DATE] ASC) ON [NCRMS_IDX]';
	IF FILEGROUP_ID(N'NCRMS_IDX') IS NULL
		SET @IndexSql = REPLACE(@IndexSql, N'[NCRMS_IDX]', N'[PRIMARY]');
	EXEC sys.sp_executesql @IndexSql;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.extended_properties
               WHERE major_id = OBJECT_ID(N'[dbo].[ARS_SUKBD2_D_MF]') AND name = N'MS_Description'
                 AND minor_id = COLUMNPROPERTY(OBJECT_ID(N'[dbo].[ARS_SUKBD2_D_MF]'), N'Create_date', 'ColumnId'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建置時間', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKBD2_D_MF', @level2type=N'COLUMN',@level2name=N'Create_date';
GO
