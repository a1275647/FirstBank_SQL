SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Role_User_Mapping_his](
	[log_Id] [int] IDENTITY(1,1) NOT NULL,
	[logType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[log_Role_Id] [int] NULL,
	[PK_Id] [int] NULL,
	[FK_Role_Id] [int] NOT NULL,
	[FK_User_Id] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_Role_User_Mapping_his] PRIMARY KEY CLUSTERED
(
	[log_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
GO
ALTER TABLE [dbo].[Role_User_Mapping_his] ADD  CONSTRAINT [DF_User_Role_Mapping_his_FK_Role_Id]  DEFAULT ((0)) FOR [FK_Role_Id]
GO
ALTER TABLE [dbo].[Role_User_Mapping_his] ADD  CONSTRAINT [DF_User_Role_Mapping_his_FK_User_Id]  DEFAULT ('') FOR [FK_User_Id]
GO
ALTER TABLE [dbo].[Role_User_Mapping_his] ADD  CONSTRAINT [DF_Role_User_Mapping_his_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[Role_User_Mapping_his] ADD  CONSTRAINT [DF_User_Role_Mapping_his_Create_user]  DEFAULT ('') FOR [Create_user]
GO
ALTER TABLE [dbo].[Role_User_Mapping_his] ADD  CONSTRAINT [DF_Role_User_Mapping_his_SysCreateDate]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
ALTER TABLE [dbo].[Role_User_Mapping_his] ADD  CONSTRAINT [DF_Role_User_Mapping_his_SysCreate_user]  DEFAULT ('') FOR [SysCreateUser]
GO
ALTER TABLE [dbo].[Role_User_Mapping_his]  WITH CHECK ADD  CONSTRAINT [FK_Role_User_Mapping_his_Role_his] FOREIGN KEY([log_Role_Id])
REFERENCES [dbo].[Role_his] ([log_Id])
GO
ALTER TABLE [dbo].[Role_User_Mapping_his] CHECK CONSTRAINT [FK_Role_User_Mapping_his_Role_his]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'紀錄的狀態' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Role_User_Mapping_his', @level2type=N'COLUMN',@level2name=N'logType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'對應到的角色FK' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Role_User_Mapping_his', @level2type=N'COLUMN',@level2name=N'FK_Role_Id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'對應到的User FK' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Role_User_Mapping_his', @level2type=N'COLUMN',@level2name=N'FK_User_Id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'異動日期' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Role_User_Mapping_his', @level2type=N'COLUMN',@level2name=N'Create_date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'異動者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Role_User_Mapping_his', @level2type=N'COLUMN',@level2name=N'Create_user'
GO
