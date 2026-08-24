SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[INDUSTRY](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[INDCODE] [nvarchar](6) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[TYPE] [int] NOT NULL,
	[Medium_Code] [nvarchar](6) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Medium_Name] [nvarchar](255) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Major_Code] [nvarchar](6) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Major_Name] [nvarchar](255) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_INDUSTRY] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB],
 CONSTRAINT [IX_INDUSTRY] UNIQUE NONCLUSTERED
(
	[INDCODE] ASC,
	[TYPE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
) ON [NCRMS_TAB]';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
IF FILEGROUP_ID(N'NCRMS_IDX') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_IDX]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[INDUSTRY] ADD  CONSTRAINT [DF_INDUSTRY_major_name]  DEFAULT ('') FOR [Major_Name]
GO
ALTER TABLE [dbo].[INDUSTRY] ADD  CONSTRAINT [DF_INDUSTRY_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[INDUSTRY] ADD  CONSTRAINT [DF_INDUSTRY_Update_user]  DEFAULT ('system') FOR [Update_user]
GO
ALTER TABLE [dbo].[INDUSTRY] ADD  CONSTRAINT [DF_INDUSTRY_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[INDUSTRY] ADD  CONSTRAINT [DF_INDUSTRY_Create_user]  DEFAULT ('system') FOR [Create_user]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'國內產業編號' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'INDUSTRY', @level2type=N'COLUMN',@level2name=N'INDCODE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1=國內,2=國外' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'INDUSTRY', @level2type=N'COLUMN',@level2name=N'TYPE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'中類編號' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'INDUSTRY', @level2type=N'COLUMN',@level2name=N'Medium_Code'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'放款中類行業名稱' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'INDUSTRY', @level2type=N'COLUMN',@level2name=N'Medium_Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'大類編號' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'INDUSTRY', @level2type=N'COLUMN',@level2name=N'Major_Code'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'放款大類行業' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'INDUSTRY', @level2type=N'COLUMN',@level2name=N'Major_Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'更新時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'INDUSTRY', @level2type=N'COLUMN',@level2name=N'Update_date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'更新者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'INDUSTRY', @level2type=N'COLUMN',@level2name=N'Update_user'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建置時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'INDUSTRY', @level2type=N'COLUMN',@level2name=N'Create_date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建置者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'INDUSTRY', @level2type=N'COLUMN',@level2name=N'Create_user'
GO
