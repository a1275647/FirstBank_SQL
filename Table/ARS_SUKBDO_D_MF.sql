SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[ARS_SUKBDO_D_MF](
	[SUKBDO_BRANCH_NO] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKBDO_TX_DATE] [date] NULL,
	[SUKBDO_DESK] [nvarchar](12) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKBDO_CUSTOMER_ID] [nvarchar](11) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKBDO_CUST_NAME] [nvarchar](40) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKBDO_CPTY_COUNTRY] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKBDO_CPTY_COUNTRY_RISK] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKBDO_POSITIONID] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKBDO_BUY_SELL] [nvarchar](1) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKBDO_OPTIONEXPIRYDATE] [date] NULL,
	[SUKBDO_RISK_AMT] [decimal](17, 2) NULL,
	[SUKBDO_EXT_DATE] [date] NULL,
	[BUSINS_CODE] [nvarchar](7) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Create_date] [datetime] NOT NULL
) ON [NCRMS_TAB]';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[ARS_SUKBDO_D_MF] ADD  CONSTRAINT [DF_ARS_SUKBDO_D_MF_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'分行代號' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKBDO_D_MF', @level2type=N'COLUMN',@level2name=N'SUKBDO_BRANCH_NO'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'交易員主管別' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKBDO_D_MF', @level2type=N'COLUMN',@level2name=N'SUKBDO_DESK'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'交易對手代號' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKBDO_D_MF', @level2type=N'COLUMN',@level2name=N'SUKBDO_CUSTOMER_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'交易對手名稱' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKBDO_D_MF', @level2type=N'COLUMN',@level2name=N'SUKBDO_CUST_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'交易對手國家別' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKBDO_D_MF', @level2type=N'COLUMN',@level2name=N'SUKBDO_CPTY_COUNTRY'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'國家代號' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKBDO_D_MF', @level2type=N'COLUMN',@level2name=N'SUKBDO_CPTY_COUNTRY_RISK'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'交易代號' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKBDO_D_MF', @level2type=N'COLUMN',@level2name=N'SUKBDO_POSITIONID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'選擇權買賣別' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKBDO_D_MF', @level2type=N'COLUMN',@level2name=N'SUKBDO_BUY_SELL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'選擇權到期日' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKBDO_D_MF', @level2type=N'COLUMN',@level2name=N'SUKBDO_OPTIONEXPIRYDATE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'本筆使用風險額度' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKBDO_D_MF', @level2type=N'COLUMN',@level2name=N'SUKBDO_RISK_AMT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'萃取日' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKBDO_D_MF', @level2type=N'COLUMN',@level2name=N'SUKBDO_EXT_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'產業別' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKBDO_D_MF', @level2type=N'COLUMN',@level2name=N'BUSINS_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建置時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKBDO_D_MF', @level2type=N'COLUMN',@level2name=N'Create_date'
GO
