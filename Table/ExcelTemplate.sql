SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ExcelTemplate](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[Excel_Template_Code] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Excel_Sheet_Name] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Excel_Template_Filename] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Column_Id] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Column_Name] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Row] [int] NOT NULL,
	[Col] [int] NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_ExcelTemplate] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_ExcelTemplate] ON [dbo].[ExcelTemplate]
(
	[Excel_Template_Code] ASC,
	[Excel_Template_Filename] ASC,
	[Excel_Sheet_Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
GO
ALTER TABLE [dbo].[ExcelTemplate] ADD  CONSTRAINT [DF_ExcelTemplate_Excel_Template_Code]  DEFAULT ('') FOR [Excel_Template_Code]
GO
ALTER TABLE [dbo].[ExcelTemplate] ADD  CONSTRAINT [DF_ExcelTemplate_Excel_Template_Filename]  DEFAULT ('') FOR [Excel_Template_Filename]
GO
ALTER TABLE [dbo].[ExcelTemplate] ADD  CONSTRAINT [DF_ExcelTemplate_Column_Id]  DEFAULT ('') FOR [Column_Id]
GO
ALTER TABLE [dbo].[ExcelTemplate] ADD  CONSTRAINT [DF_ExcelTemplate_Column_Name]  DEFAULT ('') FOR [Column_Name]
GO
ALTER TABLE [dbo].[ExcelTemplate] ADD  CONSTRAINT [DF_ExcelTemplate_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[ExcelTemplate] ADD  CONSTRAINT [DF_ExcelTemplate_Update_user]  DEFAULT ('system') FOR [Update_user]
GO
ALTER TABLE [dbo].[ExcelTemplate] ADD  CONSTRAINT [DF_ExcelTemplate_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[ExcelTemplate] ADD  CONSTRAINT [DF_ExcelTemplate_Create_user]  DEFAULT ('system') FOR [Create_user]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'範本Code' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExcelTemplate', @level2type=N'COLUMN',@level2name=N'Excel_Template_Code'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'範本名稱' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExcelTemplate', @level2type=N'COLUMN',@level2name=N'Excel_Sheet_Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'範本檔名' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExcelTemplate', @level2type=N'COLUMN',@level2name=N'Excel_Template_Filename'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'對應Dto參數名' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExcelTemplate', @level2type=N'COLUMN',@level2name=N'Column_Id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'參數名稱' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExcelTemplate', @level2type=N'COLUMN',@level2name=N'Column_Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'列' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExcelTemplate', @level2type=N'COLUMN',@level2name=N'Row'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'欄' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExcelTemplate', @level2type=N'COLUMN',@level2name=N'Col'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'更新時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExcelTemplate', @level2type=N'COLUMN',@level2name=N'Update_date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'更新者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExcelTemplate', @level2type=N'COLUMN',@level2name=N'Update_user'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建置時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExcelTemplate', @level2type=N'COLUMN',@level2name=N'Create_date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建置者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExcelTemplate', @level2type=N'COLUMN',@level2name=N'Create_user'
GO
