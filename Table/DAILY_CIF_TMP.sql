SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[DAILY_CIF_TMP](
	[CIF_ID_NO] [char](11) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[CIF_CUST_NAME] [char](40) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CIF_NATION_CODE] [char](4) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CIF_EXT_DATE] [date] NULL,
	[CIF_LOAD_DATE] [char](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CIF_LOAD_TIME] [char](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
 CONSTRAINT [PK_DAILY_CIF_TMP] PRIMARY KEY CLUSTERED
(
	[CIF_ID_NO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_PADDING OFF
GO
