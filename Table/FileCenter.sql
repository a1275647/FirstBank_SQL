SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FileCenter](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[File_Type] [int] NOT NULL,
	[FilePath] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[FileName] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Memo] [nvarchar](500) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[File_Extension] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_FileCenter] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
GO
ALTER TABLE [dbo].[FileCenter] ADD  CONSTRAINT [DF_FileCenter_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[FileCenter] ADD  CONSTRAINT [DF_FileCenter_Update_user]  DEFAULT ('system') FOR [Update_user]
GO
ALTER TABLE [dbo].[FileCenter] ADD  CONSTRAINT [DF_FileCenter_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[FileCenter] ADD  CONSTRAINT [DF_FileCenter_Create_user]  DEFAULT ('system') FOR [Create_user]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Global內，檔案分類' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FileCenter', @level2type=N'COLUMN',@level2name=N'File_Type'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'檔案絕對路徑' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FileCenter', @level2type=N'COLUMN',@level2name=N'FilePath'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'檔案描述' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FileCenter', @level2type=N'COLUMN',@level2name=N'FileName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'備註' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FileCenter', @level2type=N'COLUMN',@level2name=N'Memo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'副檔名' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FileCenter', @level2type=N'COLUMN',@level2name=N'File_Extension'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'更新時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FileCenter', @level2type=N'COLUMN',@level2name=N'Update_date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'更新者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FileCenter', @level2type=N'COLUMN',@level2name=N'Update_user'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建置時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FileCenter', @level2type=N'COLUMN',@level2name=N'Create_date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建置者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FileCenter', @level2type=N'COLUMN',@level2name=N'Create_user'
GO
