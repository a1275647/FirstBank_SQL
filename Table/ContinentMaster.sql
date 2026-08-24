SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[ContinentMaster](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[ContinentCode] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[ContinentName_TN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[ContinentName_EN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[ContinentName_CN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[ContinentName_JP] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[IsActive] [bit] NOT NULL,
	[IsContinent] [bit] NOT NULL,
	[seq] [int] NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
 CONSTRAINT [PK_ContinentMaster] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[ContinentMaster] ADD  CONSTRAINT [DF_ContinentMaster_ContinentCode]  DEFAULT ('') FOR [ContinentCode]
GO
ALTER TABLE [dbo].[ContinentMaster] ADD  CONSTRAINT [DF_ContinentMaster_ContinentName_TN]  DEFAULT ('') FOR [ContinentName_TN]
GO
ALTER TABLE [dbo].[ContinentMaster] ADD  CONSTRAINT [DF_ContinentMaster_ContinentName_EN]  DEFAULT ('') FOR [ContinentName_EN]
GO
ALTER TABLE [dbo].[ContinentMaster] ADD  CONSTRAINT [DF_ContinentMaster_ContinentName_CN]  DEFAULT ('') FOR [ContinentName_CN]
GO
ALTER TABLE [dbo].[ContinentMaster] ADD  CONSTRAINT [DF_ContinentMaster_ContinentName_JP]  DEFAULT ('') FOR [ContinentName_JP]
GO
ALTER TABLE [dbo].[ContinentMaster] ADD  CONSTRAINT [DF_ContinentMaster_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[ContinentMaster] ADD  CONSTRAINT [DF_ContinentMaster_IsContinent]  DEFAULT ((0)) FOR [IsContinent]
GO
ALTER TABLE [dbo].[ContinentMaster] ADD  CONSTRAINT [DF_ContinentMaster_seq]  DEFAULT ((1)) FOR [seq]
GO
ALTER TABLE [dbo].[ContinentMaster] ADD  CONSTRAINT [DF_ContinentMaster_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[ContinentMaster] ADD  CONSTRAINT [DF_ContinentMaster_Update_user]  DEFAULT ('') FOR [Update_user]
GO
ALTER TABLE [dbo].[ContinentMaster] ADD  CONSTRAINT [DF_ContinentMaster_Create_user]  DEFAULT ('') FOR [Create_user]
GO
ALTER TABLE [dbo].[ContinentMaster] ADD  CONSTRAINT [DF_ContinentMaster_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'州、特殊區域代碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ContinentMaster', @level2type=N'COLUMN',@level2name=N'ContinentCode'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'中' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ContinentMaster', @level2type=N'COLUMN',@level2name=N'ContinentName_TN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'英' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ContinentMaster', @level2type=N'COLUMN',@level2name=N'ContinentName_EN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'簡' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ContinentMaster', @level2type=N'COLUMN',@level2name=N'ContinentName_CN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'日' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ContinentMaster', @level2type=N'COLUMN',@level2name=N'ContinentName_JP'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'是否啟用' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ContinentMaster', @level2type=N'COLUMN',@level2name=N'IsActive'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'州別 = true 特殊區域 false' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ContinentMaster', @level2type=N'COLUMN',@level2name=N'IsContinent'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'排序' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ContinentMaster', @level2type=N'COLUMN',@level2name=N'seq'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'更新時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ContinentMaster', @level2type=N'COLUMN',@level2name=N'Update_date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'更新者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ContinentMaster', @level2type=N'COLUMN',@level2name=N'Update_user'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建立者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ContinentMaster', @level2type=N'COLUMN',@level2name=N'Create_user'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建立時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ContinentMaster', @level2type=N'COLUMN',@level2name=N'Create_date'
GO
