SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[OSISKF02_MF](
	[OSISKF02_BRANCH_NO] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[OSISKF02_TRAN_NO] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[OSISKF02_TX_DATE] [date] NULL,
	[OSISKF02_CUATOMER_ID] [nvarchar](11) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[OSISKF02_CUST_NAME1] [nvarchar](40) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[OSISKF02_CPTY_COUNTRY] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[OSISKF02_CPTY_COUNTRY_RISK] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[OSISKF02_TRADE_DATE] [date] NULL,
	[OSISKF02_MATURITY] [date] NULL,
	[OSISKF02_IN_CCY] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[OSISKF02_RISK_AMT] [decimal](17, 2) NULL,
	[OSISKF02_EXT_DATE] [date] NULL,
	[BUSINS_CODE] [nvarchar](7) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Create_date] [datetime] NOT NULL
) ON [NCRMS_TAB]';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[OSISKF02_MF] ADD  CONSTRAINT [DF_OSISKF02_MF_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
