SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[Post](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[Type] [int] NULL,
	[Title] [nvarchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Contents] [nvarchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Url] [nvarchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[IsActive] [bit] NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Release_date] [date] NULL,
	[Category] [int] NULL,
 CONSTRAINT [PK_Post] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[Post] ADD  CONSTRAINT [DF_Post_Contents]  DEFAULT ('') FOR [Contents]
GO
ALTER TABLE [dbo].[Post] ADD  CONSTRAINT [DF_Post_Url]  DEFAULT ('') FOR [Url]
GO
