SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ARS_SUKFRA_D_MF](
	[SUKFRA_BRANCH_NO] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKFRA_TRADE_ID] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKFRA_SUPERVISOR] [nvarchar](12) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKFRA_CPTY_BUSINESS] [nvarchar](6) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKFRA_CUSTOMER_ID] [nvarchar](11) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKFRA_CUST_NAME2] [nvarchar](30) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKFRA_CPTY_COUNTRY] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKFRA_CPTY_COUNTRY_RISK] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKFRA_TRADE_DATE] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKFRA_MATURITY] [date] NULL,
	[SUKFRA_BUY_SELL] [nvarchar](1) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKFRA_CCY] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKFRA_RISK_AMT] [decimal](17, 2) NULL,
	[SUKFRA_EXT_DATE] [date] NULL,
	[BUSINS_CODE] [nvarchar](7) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Create_date] [datetime] NOT NULL
)
GO
ALTER TABLE [dbo].[ARS_SUKFRA_D_MF] ADD  CONSTRAINT [DF_ARS_SUKFRA_D_MF_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'分行代號
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKFRA_D_MF', @level2type=N'COLUMN',@level2name=N'SUKFRA_BRANCH_NO'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'交易編號
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKFRA_D_MF', @level2type=N'COLUMN',@level2name=N'SUKFRA_TRADE_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'交易主管別' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKFRA_D_MF', @level2type=N'COLUMN',@level2name=N'SUKFRA_SUPERVISOR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'產業別' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKFRA_D_MF', @level2type=N'COLUMN',@level2name=N'SUKFRA_CPTY_BUSINESS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'客戶代號' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKFRA_D_MF', @level2type=N'COLUMN',@level2name=N'SUKFRA_CUSTOMER_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'客戶名稱2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKFRA_D_MF', @level2type=N'COLUMN',@level2name=N'SUKFRA_CUST_NAME2'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'SUKFRA_CPTY_COUNTRY' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKFRA_D_MF', @level2type=N'COLUMN',@level2name=N'SUKFRA_CPTY_COUNTRY'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'國家代號' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKFRA_D_MF', @level2type=N'COLUMN',@level2name=N'SUKFRA_CPTY_COUNTRY_RISK'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'訂約日' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKFRA_D_MF', @level2type=N'COLUMN',@level2name=N'SUKFRA_TRADE_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'到期日' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKFRA_D_MF', @level2type=N'COLUMN',@level2name=N'SUKFRA_MATURITY'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'買賣別' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKFRA_D_MF', @level2type=N'COLUMN',@level2name=N'SUKFRA_BUY_SELL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'本金幣別' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKFRA_D_MF', @level2type=N'COLUMN',@level2name=N'SUKFRA_CCY'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'SUKFRA_RISK_AMT' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKFRA_D_MF', @level2type=N'COLUMN',@level2name=N'SUKFRA_RISK_AMT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'SUKFRA_EXT_DATE' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKFRA_D_MF', @level2type=N'COLUMN',@level2name=N'SUKFRA_EXT_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建置時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKFRA_D_MF', @level2type=N'COLUMN',@level2name=N'Create_date'
GO
