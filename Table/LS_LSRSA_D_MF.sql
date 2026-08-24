SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[LS_LSRSA_D_MF](
	[ACC_CODE] [nvarchar](9) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[ENG_NAME] [nvarchar](42) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[ISIN_CD] [nvarchar](11) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[APRV_NO] [nvarchar](38) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CURRENCY] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LN_BAL] [decimal](15, 2) NULL,
	[COUNTRY] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[EXT_DATE] [date] NULL,
	[BUSINS_CODE] [nvarchar](7) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL
) ON [NCRMS_TAB]';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
