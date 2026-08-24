SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[Post_his](
	[Log_id] [int] IDENTITY(1,1) NOT NULL,
	[LogType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[FlowFormId] [int] NULL,
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
	[Release_date] [date] NULL,
	[Category] [int] NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK__Post_his__2D21E3B6934210DC] PRIMARY KEY CLUSTERED
(
	[Log_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[Post_his] ADD  CONSTRAINT [DF__Post_his__SysCre__1ACAA75A]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
ALTER TABLE [dbo].[Post_his]  WITH CHECK ADD  CONSTRAINT [FK_Post_his_FlowForm] FOREIGN KEY([FlowFormId])
REFERENCES [dbo].[FlowForm] ([PK_Id])
GO
ALTER TABLE [dbo].[Post_his] CHECK CONSTRAINT [FK_Post_his_FlowForm]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'歷史記錄識別碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Post_his', @level2type=N'COLUMN',@level2name=N'Log_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'異動行為類型 (INSERT/UPDATE/DELETE)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Post_his', @level2type=N'COLUMN',@level2name=N'LogType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'流程表單識別碼（外鍵：FlowForm.PK_ID）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Post_his', @level2type=N'COLUMN',@level2name=N'FlowFormId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立日期時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Post_his', @level2type=N'COLUMN',@level2name=N'SysCreateDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立使用者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Post_his', @level2type=N'COLUMN',@level2name=N'SysCreateUser'
GO
