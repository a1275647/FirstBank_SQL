SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[Mail](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[UnitCode] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[List_Name] [nvarchar](60) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Mail_Type] [int] NOT NULL,
	[Subject] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Mail_Content] [nvarchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[IsSystem] [bit] NOT NULL,
 CONSTRAINT [PK_Mail] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[Mail] ADD  CONSTRAINT [DF_Mail_List_Name]  DEFAULT ('') FOR [List_Name]
GO
ALTER TABLE [dbo].[Mail] ADD  CONSTRAINT [DF_Mail_Mail_Content]  DEFAULT ('') FOR [Mail_Content]
GO
ALTER TABLE [dbo].[Mail] ADD  CONSTRAINT [DF_Mail_Update_user]  DEFAULT ('system') FOR [Update_user]
GO
ALTER TABLE [dbo].[Mail] ADD  CONSTRAINT [DF_Mail_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[Mail] ADD  CONSTRAINT [DF_Mail_Create_user]  DEFAULT (N'system') FOR [Create_user]
GO
ALTER TABLE [dbo].[Mail] ADD  CONSTRAINT [DF_Mail_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[Mail] ADD  CONSTRAINT [DF_Mail_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[Mail] ADD  CONSTRAINT [DF_Mail_IsSystem]  DEFAULT ((0)) FOR [IsSystem]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'範本名稱' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Mail', @level2type=N'COLUMN',@level2name=N'List_Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'類型' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Mail', @level2type=N'COLUMN',@level2name=N'Mail_Type'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'標題' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Mail', @level2type=N'COLUMN',@level2name=N'Subject'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'內容' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Mail', @level2type=N'COLUMN',@level2name=N'Mail_Content'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'更新者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Mail', @level2type=N'COLUMN',@level2name=N'Update_user'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'更新時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Mail', @level2type=N'COLUMN',@level2name=N'Update_date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'是否啟用' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Mail', @level2type=N'COLUMN',@level2name=N'IsActive'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'是否是系統信件範本' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Mail', @level2type=N'COLUMN',@level2name=N'IsSystem'
GO
