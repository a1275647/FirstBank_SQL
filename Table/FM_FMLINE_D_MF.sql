SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[FM_FMLINE_D_MF](
	[FMLINE_CUST_ID] [nvarchar](11) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[FMLINE_DATE_TYPE] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[FMLINE_BRANCH] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[FMLINE_LINE_TYPE] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[FMLINE_APRV_NO] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[FMLINE_APRV_DATE] [date] NULL,
	[FMLINE_REVOLING_TYPE] [nvarchar](1) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[FMLINE_LINE_EXPIRY] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[FMLINE_LINE_AMT] [decimal](15, 2) NULL,
	[FMLINE_MULT_MERGED_MARK] [nvarchar](1) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[FMLINE_MULT_MERGED_APRV_NO] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[FMLINE_LINE_CURENCY] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[FMLINE_EXT_DATE] [date] NULL,
	[BUSINS_CODE] [nvarchar](7) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Create_Date] [date] NOT NULL
) ON [NCRMS_TAB]';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[FM_FMLINE_D_MF] ADD  CONSTRAINT [DF_FM_FMLINE_D_MF_Create_Date]  DEFAULT (getdate()) FOR [Create_Date]
GO
