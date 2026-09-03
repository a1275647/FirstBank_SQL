SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[MailLog](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[UnitCode] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[List_Name] [nvarchar](60) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Mail_Type] [int] NULL,
	[Mail_From] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Subject] [nvarchar](255) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Mail_Content] [nvarchar](4000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[IsSystem] [bit] NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
 CONSTRAINT [PK_MailLog] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[MailLog] ADD  CONSTRAINT [DF_MailLog_IsSystem]  DEFAULT ((1)) FOR [IsSystem]
GO
ALTER TABLE [dbo].[MailLog] ADD  CONSTRAINT [DF_MailLog_Create_user]  DEFAULT ('system') FOR [Create_user]
GO
ALTER TABLE [dbo].[MailLog] ADD  CONSTRAINT [DF_MailLog_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
