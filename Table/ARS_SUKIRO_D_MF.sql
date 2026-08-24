SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[ARS_SUKIRO_D_MF](
	[SUKIRO_BRANCH_NO] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKIRO_TRADE_ID] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKIRO_SUPERVISOR] [nvarchar](12) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKIRO_CPTY_BUSINESS] [nvarchar](6) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKIRO_CUSTOMER_ID] [nvarchar](11) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKIRO_CUST_NAME2] [nvarchar](30) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKIRO_CPTY_COUNTRY_RISK] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKIRO_TRADE_DATE] [date] NULL,
	[SUKIRO_MATURITY_DATE] [date] NULL,
	[SUKIRO_BUY_SELL] [nvarchar](1) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKIRO_CCY] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKIRO_RISK_AMT] [decimal](17, 2) NULL,
	[SUKIRO_EXT_DATE] [date] NULL,
	[Create_date] [datetime] NOT NULL
) ON [NCRMS_TAB]';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[ARS_SUKIRO_D_MF] ADD  CONSTRAINT [DF_ARS_SUKIRO_D_MF_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'分行代號' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKIRO_D_MF', @level2type=N'COLUMN',@level2name=N'SUKIRO_BRANCH_NO'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'交易代號' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKIRO_D_MF', @level2type=N'COLUMN',@level2name=N'SUKIRO_TRADE_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'交易主管別' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKIRO_D_MF', @level2type=N'COLUMN',@level2name=N'SUKIRO_SUPERVISOR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'交易對手行業別' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKIRO_D_MF', @level2type=N'COLUMN',@level2name=N'SUKIRO_CPTY_BUSINESS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'交易對手代號' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKIRO_D_MF', @level2type=N'COLUMN',@level2name=N'SUKIRO_CUSTOMER_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'客戶名稱2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKIRO_D_MF', @level2type=N'COLUMN',@level2name=N'SUKIRO_CUST_NAME2'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'國家代號' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKIRO_D_MF', @level2type=N'COLUMN',@level2name=N'SUKIRO_CPTY_COUNTRY_RISK'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'訂約日
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKIRO_D_MF', @level2type=N'COLUMN',@level2name=N'SUKIRO_TRADE_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'到期日' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKIRO_D_MF', @level2type=N'COLUMN',@level2name=N'SUKIRO_MATURITY_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'買賣別
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKIRO_D_MF', @level2type=N'COLUMN',@level2name=N'SUKIRO_BUY_SELL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'幣別' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKIRO_D_MF', @level2type=N'COLUMN',@level2name=N'SUKIRO_CCY'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'本筆使用風險額度' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKIRO_D_MF', @level2type=N'COLUMN',@level2name=N'SUKIRO_RISK_AMT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'萃取日' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKIRO_D_MF', @level2type=N'COLUMN',@level2name=N'SUKIRO_EXT_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建置時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKIRO_D_MF', @level2type=N'COLUMN',@level2name=N'Create_date'
GO
