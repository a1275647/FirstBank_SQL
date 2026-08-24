SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[OSFXKF02_MF](
	[OSFXKF02_BRANCH_NO] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[OSFXKF02_TRAN_NO] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[OSFXKF02_TX_DATE] [date] NULL,
	[OSFXKF02_TX_TYPE] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[OSFXKF02_CUATOMER_ID] [nvarchar](11) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[OSFXKF02_CUST_NAME1] [nvarchar](40) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[OSFXKF02_CPTY_COUNTRY] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[OSFXKF02_CPTY_COUNTRY_RISK] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[OSFXKF02_DEL_DATE] [date] NULL,
	[OSFXKF02_VALUE_DATE0] [date] NULL,
	[OSFXKF02_OBJECT_CCY] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[OSFXKF02_OBJECT_AMT] [decimal](17, 2) NULL,
	[OSFXKF02_CUR_BOUGHT] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[OSFXKF02_CUR_SOLD] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[OSFXKF02_EXT_DATE] [date] NULL,
	[BUSINS_CODE] [nvarchar](7) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Create_date] [datetime] NOT NULL
) ON [NCRMS_TAB]';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[OSFXKF02_MF] ADD  CONSTRAINT [DF_OSFXKF02_MF_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
