SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[OS_LNSSECD_D_MF](
	[LNSSECD_BRANCH_NO] [char](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LNSSECD_CUSTOMER_ID] [char](11) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LNSSECD_SEC_NO] [char](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LNSSECD_SECURITY_TYPE] [char](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LNSSECD_CURRENCY] [char](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LNSSECD_SET_AMOUNT] [decimal](15, 2) NULL,
	[LNSSECD_SET_AMOUNT_USD] [decimal](15, 2) NULL,
	[LNSSECD_PRIORITY] [char](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LNSSECD_SET_AMOUNT_OTHERS] [decimal](15, 2) NULL,
	[LNSSECD_SET_AMOUNT_OTHERS_USD] [decimal](15, 2) NULL,
	[LNSSECD_CREDIT_LIMIT] [decimal](15, 2) NULL,
	[LNSSECD_CREDIT_LIMIT_USD] [decimal](15, 2) NULL,
	[LNSSECD_REF_PRICE] [decimal](15, 2) NULL,
	[LNSSECD_REF_PRICE_USD] [decimal](15, 2) NULL,
	[LNSSECD_REF_PRICE_DATE] [date] NULL,
	[LNSSECD_EVALUATE_PRICE] [decimal](15, 2) NULL,
	[LNSSECD_EVALUATE_PRICE_USD] [decimal](15, 2) NULL,
	[LNSSECD_EVALUATE_PRICE_DATE] [date] NULL,
	[LNSSECD_MATURITY] [date] NULL,
	[LNSSECD_EST_FR] [decimal](5, 0) NULL,
	[LNSSECD_SANDP] [char](6) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LNSSECD_MOODY] [char](6) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LNSSECD_FITCH] [char](6) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LNSSECD_DATA_DATE] [date] NULL,
	[LNSSECD_EXT_DATE] [date] NULL,
	[LNSSECD_LOAD_DATE] [date] NULL,
	[LNSSECD_LOAD_TIME] [char](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Create_date] [datetime] NOT NULL
) ON [NCRMS_TAB]';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[OS_LNSSECD_D_MF] ADD  CONSTRAINT [DF_OS_LNSSECD_D_MF_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
