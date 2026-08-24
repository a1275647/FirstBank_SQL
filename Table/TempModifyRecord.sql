SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[TempModifyRecord](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FormId] [int] NOT NULL,
	[TempId] [int] NOT NULL,
	[StepId] [uniqueidentifier] NOT NULL,
	[Field] [nvarchar](255) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[NewValue] [nvarchar](255) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[OldValue] [nvarchar](255) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_TempModifyRecord] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[TempModifyRecord] ADD  CONSTRAINT [DF_TempModifyRecord_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
