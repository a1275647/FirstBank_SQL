SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[Role](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_Unit_Code] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[RoleName_TN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[RoleName_CN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[RoleName_EN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[RoleName_JP] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_ROLE] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_PADDING ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE NONCLUSTERED INDEX [IX_Role_FK_Unit_Code] ON [dbo].[Role]
(
	[FK_Unit_Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]';
IF FILEGROUP_ID(N'NCRMS_IDX') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_IDX]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[Role] ADD  CONSTRAINT [DF_Role_RoleName_TN]  DEFAULT ('') FOR [RoleName_TN]
GO
ALTER TABLE [dbo].[Role] ADD  CONSTRAINT [DF_Role_RoleName_CN]  DEFAULT ('') FOR [RoleName_CN]
GO
ALTER TABLE [dbo].[Role] ADD  CONSTRAINT [DF_Role_RoleName_EN]  DEFAULT ('') FOR [RoleName_EN]
GO
ALTER TABLE [dbo].[Role] ADD  CONSTRAINT [DF_Role_RoleName_JP]  DEFAULT ('') FOR [RoleName_JP]
GO
ALTER TABLE [dbo].[Role] ADD  CONSTRAINT [DF_Role_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[Role] ADD  CONSTRAINT [DF_Role_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'角色綁定的處' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Role', @level2type=N'COLUMN',@level2name=N'FK_Unit_Code'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'角色名稱中文' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Role', @level2type=N'COLUMN',@level2name=N'RoleName_TN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'角色名稱簡中' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Role', @level2type=N'COLUMN',@level2name=N'RoleName_CN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'角色名稱英文' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Role', @level2type=N'COLUMN',@level2name=N'RoleName_EN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'角色名稱日文' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Role', @level2type=N'COLUMN',@level2name=N'RoleName_JP'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'修改時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Role', @level2type=N'COLUMN',@level2name=N'Update_date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'修改者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Role', @level2type=N'COLUMN',@level2name=N'Update_user'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'新增時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Role', @level2type=N'COLUMN',@level2name=N'Create_date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'新增使用者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Role', @level2type=N'COLUMN',@level2name=N'Create_user'
GO
