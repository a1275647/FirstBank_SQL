SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[i18nText](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[Name_TN] [nvarchar](500) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Name_CN] [nvarchar](500) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Name_EN] [nvarchar](500) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Name_JP] [nvarchar](500) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[KeyValue] [nvarchar](500) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Update_Time] [datetime] NULL,
	[Update_User] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_i18n_text] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
