SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[ARS_SUKNBD1_D_MF](
	[SUKBD1_BRANCH_NO] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKBD1_TRAN_NO] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKBD1_TX_DATE] [date] NULL,
	[SUKBD1_SWIFT_ID] [nvarchar](11) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKBD1_CUST_NAME1] [nvarchar](40) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKBD1_MATURITY_DATE] [date] NULL,
	[SUKBD1_CURENCY_COD] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKBD1_BALANCE_AMT] [decimal](17, 2) NULL,
	[SUKBD1_LINE_PERMIT_NO] [nvarchar](13) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKBD1_SUPERVISOR] [nvarchar](12) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKBD1_ISSUER_BUSINESS] [nvarchar](6) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKBD1_ISSUER_COUNTRY] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKBD1_BUY_SELL] [nvarchar](1) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKBD1_SECURITY_TYPE] [nvarchar](9) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKBD1_SEC_SUB_TYPE] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKBD1_EXT_DATE] [date] NULL,
	[SUKBD1_GU_LOG_CTY] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Create_date] [datetime] NOT NULL
) ON [NCRMS_TAB]';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[ARS_SUKNBD1_D_MF] ADD  CONSTRAINT [DF_ARS_SUKNBD1_D_MF_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建置時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKNBD1_D_MF', @level2type=N'COLUMN',@level2name=N'Create_date'
GO
