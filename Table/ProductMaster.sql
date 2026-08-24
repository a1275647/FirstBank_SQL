SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[ProductMaster](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[GroupCode] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[ProductCode] [nvarchar](5) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[ProductName_TN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[ProductName_EN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[ProductName_CN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[ProductName_JP] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_ProductMaster] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[ProductMaster] ADD  CONSTRAINT [DF_ProductMaster_GroupCode]  DEFAULT ('') FOR [GroupCode]
GO
ALTER TABLE [dbo].[ProductMaster] ADD  CONSTRAINT [DF_ProductMaster_ProductName_EN]  DEFAULT ('') FOR [ProductName_EN]
GO
ALTER TABLE [dbo].[ProductMaster] ADD  CONSTRAINT [DF_ProductMaster_ProductName_CN]  DEFAULT ('') FOR [ProductName_CN]
GO
ALTER TABLE [dbo].[ProductMaster] ADD  CONSTRAINT [DF_ProductMaster_ProductName_JP]  DEFAULT ('') FOR [ProductName_JP]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'產品群組' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProductMaster', @level2type=N'COLUMN',@level2name=N'GroupCode'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'產品種類' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProductMaster', @level2type=N'COLUMN',@level2name=N'ProductCode'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'繁中' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProductMaster', @level2type=N'COLUMN',@level2name=N'ProductName_TN'
GO
