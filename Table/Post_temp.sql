SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[Post_temp](
	[TempId] [int] IDENTITY(1,1) NOT NULL,
	[FlowFormId] [int] NULL,
	[ModifyType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[FK_NewsPostId] [int] NULL,
	[PK_Id] [int] NOT NULL,
	[Type] [int] NULL,
	[Title] [nvarchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Contents] [nvarchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Url] [nvarchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[IsActive] [bit] NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Release_date] [date] NULL,
	[Category] [int] NULL,
 CONSTRAINT [PK__Post_tem__06C703C18F5452D8] PRIMARY KEY CLUSTERED
(
	[TempId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[Post_temp] ADD  CONSTRAINT [DF__Post_temp__SysCr__18EC8089]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
ALTER TABLE [dbo].[Post_temp]  WITH CHECK ADD  CONSTRAINT [FK_Post_temp_FlowForm] FOREIGN KEY([FlowFormId])
REFERENCES [dbo].[FlowForm] ([PK_Id])
GO
ALTER TABLE [dbo].[Post_temp] CHECK CONSTRAINT [FK_Post_temp_FlowForm]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'暫存資料識別碼（流水號）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Post_temp', @level2type=N'COLUMN',@level2name=N'TempId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'流程表單識別碼（外鍵：FlowForm.PK_ID）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Post_temp', @level2type=N'COLUMN',@level2name=N'FlowFormId'
GO
