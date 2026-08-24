SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[ARS_SUKMST_D_MF](
	[SUKMST_BRANCH_NO] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKMST_TRAN_NO] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKMST_SUPERVISOR] [nvarchar](12) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKMST_CPTY_BUSINESS] [nvarchar](6) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKMST_CUSTOMER_ID] [nvarchar](11) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKMST_CUST_NAME2] [nvarchar](30) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKMST_CPTY_COUNTRY_RISK] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKMST_TRADE_DATE] [date] NULL,
	[SUKMST_MATURITY] [date] NULL,
	[SUKMST_BUY_SELL] [nvarchar](1) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKMST_OUT_CCY] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKMST_RISK_AMT] [decimal](17, 2) NULL,
	[SUKMST_ESTIMATE_FX] [decimal](17, 2) NULL,
	[SUKMST_DEPOSIT_LINK] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKMST_EXT_DATE] [date] NULL,
	[Create_date] [datetime] NOT NULL
) ON [NCRMS_TAB]';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[ARS_SUKMST_D_MF] ADD  CONSTRAINT [DF_ARS_SUKMST_D_MF_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'分行代號' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKMST_D_MF', @level2type=N'COLUMN',@level2name=N'SUKMST_BRANCH_NO'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'交易編號' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKMST_D_MF', @level2type=N'COLUMN',@level2name=N'SUKMST_TRAN_NO'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'交易主管別' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKMST_D_MF', @level2type=N'COLUMN',@level2name=N'SUKMST_SUPERVISOR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'交易對手行業別' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKMST_D_MF', @level2type=N'COLUMN',@level2name=N'SUKMST_CPTY_BUSINESS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'客戶代號' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKMST_D_MF', @level2type=N'COLUMN',@level2name=N'SUKMST_CUSTOMER_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'客戶名稱2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKMST_D_MF', @level2type=N'COLUMN',@level2name=N'SUKMST_CUST_NAME2'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'國家代號' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKMST_D_MF', @level2type=N'COLUMN',@level2name=N'SUKMST_CPTY_COUNTRY_RISK'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'訂約日' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKMST_D_MF', @level2type=N'COLUMN',@level2name=N'SUKMST_TRADE_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'到期日' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKMST_D_MF', @level2type=N'COLUMN',@level2name=N'SUKMST_MATURITY'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'選擇權買賣別' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKMST_D_MF', @level2type=N'COLUMN',@level2name=N'SUKMST_BUY_SELL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'換出利率幣別' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKMST_D_MF', @level2type=N'COLUMN',@level2name=N'SUKMST_OUT_CCY'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'本筆使用風險額度' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKMST_D_MF', @level2type=N'COLUMN',@level2name=N'SUKMST_RISK_AMT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'評估損益（local）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKMST_D_MF', @level2type=N'COLUMN',@level2name=N'SUKMST_ESTIMATE_FX'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'存款連結商品' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKMST_D_MF', @level2type=N'COLUMN',@level2name=N'SUKMST_DEPOSIT_LINK'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'萃取日' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKMST_D_MF', @level2type=N'COLUMN',@level2name=N'SUKMST_EXT_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建置時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKMST_D_MF', @level2type=N'COLUMN',@level2name=N'Create_date'
GO
