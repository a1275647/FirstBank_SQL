SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[TitleMapping](
	[TitleCode] [nvarchar](1) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[TitleId] [int] NULL,
	[TitleName] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL
) ON [NCRMS_TAB]';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
