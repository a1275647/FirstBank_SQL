SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[FeatureDetail](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[MenuId] [int] NULL,
	[Feature_Describe] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Seq] [int] NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_FEATURE] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[FeatureDetail] ADD  CONSTRAINT [DF_FEATURE_Feature_Describe]  DEFAULT ('') FOR [Feature_Describe]
GO
ALTER TABLE [dbo].[FeatureDetail] ADD  CONSTRAINT [DF_FeatureDetail_seq]  DEFAULT ((1)) FOR [Seq]
GO
ALTER TABLE [dbo].[FeatureDetail] ADD  CONSTRAINT [DF_FeatureDetail_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[FeatureDetail] ADD  CONSTRAINT [DF_FEATURE_Update_user]  DEFAULT ('') FOR [Update_user]
GO
ALTER TABLE [dbo].[FeatureDetail] ADD  CONSTRAINT [DF_FeatureDetail_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[FeatureDetail] ADD  CONSTRAINT [DF_FEATURE_Create_user]  DEFAULT ('') FOR [Create_user]
GO
ALTER TABLE [dbo].[FeatureDetail]  WITH CHECK ADD  CONSTRAINT [FK_FeatureDetail_Menu] FOREIGN KEY([MenuId])
REFERENCES [dbo].[Menu] ([PK_Id])
GO
ALTER TABLE [dbo].[FeatureDetail] CHECK CONSTRAINT [FK_FeatureDetail_Menu]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'功能' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FeatureDetail', @level2type=N'COLUMN',@level2name=N'Feature_Describe'
GO
