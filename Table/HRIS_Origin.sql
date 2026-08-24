SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[HRIS_Origin](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [nvarchar](255) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[UserName] [nvarchar](255) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[GroupCode] [nvarchar](255) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[GroupName] [nvarchar](255) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[UnitBranchCode] [nvarchar](255) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[UnitBranchName] [nvarchar](255) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[DepartmentCode] [nvarchar](255) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[DepartmentName] [nvarchar](255) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[JobTitleCode] [nvarchar](255) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[JobTitleName] [nvarchar](255) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Chief] [nvarchar](255) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[TitleCode] [nvarchar](255) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Leave_Start] [datetime] NULL,
	[Leave_End] [datetime] NULL,
	[Acting_Person] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Create_date] [datetime] NOT NULL,
 CONSTRAINT [PK_HRIS_Origin] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[HRIS_Origin] ADD  CONSTRAINT [DF_HRIS_Origin_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
