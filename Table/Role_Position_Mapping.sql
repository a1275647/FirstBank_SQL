SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[Role_Position_Mapping](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_Role_Id] [int] NOT NULL,
	[FK_Branch_Code] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[FK_Department_Code] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[TitleCode] [int] NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_Title_Permissions_Mapping] PRIMARY KEY CLUSTERED
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
SET @FilegroupSql += N'CREATE NONCLUSTERED INDEX [IX_Role_Position_Mapping] ON [dbo].[Role_Position_Mapping]
(
	[TitleCode] ASC,
	[FK_Branch_Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]';
IF FILEGROUP_ID(N'NCRMS_IDX') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_IDX]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_PADDING ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE NONCLUSTERED INDEX [IX_Role_Position_Mapping_1] ON [dbo].[Role_Position_Mapping]
(
	[TitleCode] ASC,
	[FK_Department_Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]';
IF FILEGROUP_ID(N'NCRMS_IDX') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_IDX]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[Role_Position_Mapping] ADD  CONSTRAINT [DF_Role_Position_Mapping_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[Role_Position_Mapping] ADD  CONSTRAINT [DF_Role_Position_Mapping_Create_user]  DEFAULT ('') FOR [Create_user]
GO
ALTER TABLE [dbo].[Role_Position_Mapping]  WITH CHECK ADD  CONSTRAINT [FK_Role_Position_Mapping_Role] FOREIGN KEY([FK_Role_Id])
REFERENCES [dbo].[Role] ([PK_Id])
GO
ALTER TABLE [dbo].[Role_Position_Mapping] CHECK CONSTRAINT [FK_Role_Position_Mapping_Role]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'異動日' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Role_Position_Mapping', @level2type=N'COLUMN',@level2name=N'Create_date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'異動者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Role_Position_Mapping', @level2type=N'COLUMN',@level2name=N'Create_user'
GO
