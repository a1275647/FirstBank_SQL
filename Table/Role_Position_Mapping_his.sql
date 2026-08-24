SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[Role_Position_Mapping_his](
	[log_Id] [int] IDENTITY(1,1) NOT NULL,
	[logType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[log_Role_Id] [int] NULL,
	[PK_Id] [int] NULL,
	[FK_Role_Id] [int] NOT NULL,
	[FK_Branch_Code] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[FK_Department_Code] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[TitleCode] [int] NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_Role_Position_Mapping_his] PRIMARY KEY CLUSTERED
(
	[log_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[Role_Position_Mapping_his] ADD  CONSTRAINT [DF_Role_Position_Mapping_his_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[Role_Position_Mapping_his] ADD  CONSTRAINT [DF_Position_Role_Mapping_his_Create_user]  DEFAULT ('') FOR [Create_user]
GO
ALTER TABLE [dbo].[Role_Position_Mapping_his] ADD  CONSTRAINT [DF_Role_Position_Mapping_his_SysCreateDate]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
ALTER TABLE [dbo].[Role_Position_Mapping_his] ADD  CONSTRAINT [DF_Role_Position_Mapping_his_SysCreate_user]  DEFAULT ('') FOR [SysCreateUser]
GO
ALTER TABLE [dbo].[Role_Position_Mapping_his]  WITH CHECK ADD  CONSTRAINT [FK_Role_Position_Mapping_his_Role_his] FOREIGN KEY([log_Role_Id])
REFERENCES [dbo].[Role_his] ([log_Id])
GO
ALTER TABLE [dbo].[Role_Position_Mapping_his] CHECK CONSTRAINT [FK_Role_Position_Mapping_his_Role_his]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'紀錄的狀態' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Role_Position_Mapping_his', @level2type=N'COLUMN',@level2name=N'logType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'對應的角色FK' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Role_Position_Mapping_his', @level2type=N'COLUMN',@level2name=N'FK_Role_Id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'對應的分行Code FK' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Role_Position_Mapping_his', @level2type=N'COLUMN',@level2name=N'FK_Branch_Code'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'對應的部Code FK' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Role_Position_Mapping_his', @level2type=N'COLUMN',@level2name=N'FK_Department_Code'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'對應的職稱代碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Role_Position_Mapping_his', @level2type=N'COLUMN',@level2name=N'TitleCode'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'異動日' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Role_Position_Mapping_his', @level2type=N'COLUMN',@level2name=N'Create_date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'異動者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Role_Position_Mapping_his', @level2type=N'COLUMN',@level2name=N'Create_user'
GO
