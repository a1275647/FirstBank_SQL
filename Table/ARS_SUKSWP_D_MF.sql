SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[ARS_SUKSWP_D_MF](
	[SUKSWP_BRANCH_NO] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKSWP_TX_DATE] [date] NULL,
	[SUKSWP_SUPERVISOR] [nvarchar](12) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKSWP_CUSTOMER_ID] [nvarchar](11) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKSWP_CUST_NAME] [nvarchar](40) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKSWP_CPTY_COUNTRY_RISK] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKSWP_EXTERNAL_ID] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKSWP_BUY_SELL] [nvarchar](1) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKSWP_OPTIONEXPIRYDATE] [date] NULL,
	[SUKSWP_CPTY_BUSINESS] [nvarchar](6) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKSWP_CURRENCY] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKSWP_RISK_AMT] [decimal](17, 2) NULL,
	[SUKSWP_EXT_DATE] [date] NULL,
	[Create_date] [datetime] NOT NULL
) ON [NCRMS_TAB]';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[ARS_SUKSWP_D_MF] ADD  CONSTRAINT [DF_ARS_SUKSWP_D_MF_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建置時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKSWP_D_MF', @level2type=N'COLUMN',@level2name=N'Create_date'
GO
