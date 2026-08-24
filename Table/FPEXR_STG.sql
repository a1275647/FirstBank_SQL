SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[FPEXR_STG](
	[FPEXR_CRCY_CODE] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[FPEXR_DATE] [date] NOT NULL,
	[FPEXR_RATE] [decimal](17, 10) NULL,
	[FPEXR_SORT] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[FPEXR_LOAD_DATE] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[FPEXR_EXT_DATE] [date] NOT NULL,
	[FPEXR_LOAD_TIME] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
 CONSTRAINT [PK_FPEXR_STG] PRIMARY KEY CLUSTERED
(
	[FPEXR_CRCY_CODE] ASC,
	[FPEXR_DATE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
