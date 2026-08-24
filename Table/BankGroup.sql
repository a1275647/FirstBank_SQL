SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[BankGroup](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[GroupCode] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[GroupName_EN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[GroupName_TN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[GroupName_CN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[GroupName_JP] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[IsActive] [bit] NOT NULL,
	[IsBusinessUnit] [bit] NOT NULL,
	[Memo] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[IsEmployed] [bit] NOT NULL,
	[Seq] [int] NOT NULL,
 CONSTRAINT [PK_BankGroup] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB],
 CONSTRAINT [IX_BankGroup] UNIQUE NONCLUSTERED
(
	[GroupCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX],
 CONSTRAINT [UQ__BankGrou__3B97438087DD735B] UNIQUE NONCLUSTERED
(
	[GroupCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
) ON [NCRMS_TAB]';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
IF FILEGROUP_ID(N'NCRMS_IDX') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_IDX]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[BankGroup] ADD  CONSTRAINT [DF_BankGroup_GroupCode]  DEFAULT ('') FOR [GroupCode]
GO
ALTER TABLE [dbo].[BankGroup] ADD  CONSTRAINT [DF_BankGroup_Name_EN]  DEFAULT ('') FOR [GroupName_EN]
GO
ALTER TABLE [dbo].[BankGroup] ADD  CONSTRAINT [DF_BankGroup_Name_TN]  DEFAULT ('') FOR [GroupName_TN]
GO
ALTER TABLE [dbo].[BankGroup] ADD  CONSTRAINT [DF_BankGroup_Name_CN]  DEFAULT ('') FOR [GroupName_CN]
GO
ALTER TABLE [dbo].[BankGroup] ADD  CONSTRAINT [DF_BankGroup_Name_JP]  DEFAULT ('') FOR [GroupName_JP]
GO
ALTER TABLE [dbo].[BankGroup] ADD  CONSTRAINT [DF_BankGroup_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[BankGroup] ADD  CONSTRAINT [DF_BankGroup_Memo]  DEFAULT ('') FOR [Memo]
GO
ALTER TABLE [dbo].[BankGroup] ADD  CONSTRAINT [DF_BankGroup_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[BankGroup] ADD  CONSTRAINT [DF_BankGroup_Update_user]  DEFAULT ('system') FOR [Update_user]
GO
ALTER TABLE [dbo].[BankGroup] ADD  CONSTRAINT [DF_BankGroup_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[BankGroup] ADD  CONSTRAINT [DF_BankGroup_Create_user]  DEFAULT ('system') FOR [Create_user]
GO
ALTER TABLE [dbo].[BankGroup] ADD  CONSTRAINT [DF__BankGroup__IsEmp__3079F157]  DEFAULT ((1)) FOR [IsEmployed]
GO
ALTER TABLE [dbo].[BankGroup] ADD  CONSTRAINT [DF_BankGroup_Seq]  DEFAULT ((99)) FOR [Seq]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'事業群代碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankGroup', @level2type=N'COLUMN',@level2name=N'GroupCode'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'英' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankGroup', @level2type=N'COLUMN',@level2name=N'GroupName_EN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'繁中' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankGroup', @level2type=N'COLUMN',@level2name=N'GroupName_TN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'簡中' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankGroup', @level2type=N'COLUMN',@level2name=N'GroupName_CN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'日' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankGroup', @level2type=N'COLUMN',@level2name=N'GroupName_JP'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'是否啟用' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankGroup', @level2type=N'COLUMN',@level2name=N'IsActive'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'是否為業務單位' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankGroup', @level2type=N'COLUMN',@level2name=N'IsBusinessUnit'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'更新時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankGroup', @level2type=N'COLUMN',@level2name=N'Update_date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'更新者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankGroup', @level2type=N'COLUMN',@level2name=N'Update_user'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建置時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankGroup', @level2type=N'COLUMN',@level2name=N'Create_date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建置者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankGroup', @level2type=N'COLUMN',@level2name=N'Create_user'
GO
