SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Permissions_his](
	[log_Id] [int] IDENTITY(1,1) NOT NULL,
	[logType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[log_Role_Id] [int] NULL,
	[PK_Id] [int] NULL,
	[FK_Role_Id] [int] NOT NULL,
	[FK_Feature_Id] [int] NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_Permissions_his] PRIMARY KEY CLUSTERED
(
	[log_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
GO
ALTER TABLE [dbo].[Permissions_his] ADD  CONSTRAINT [DF_Permissions_his_FK_Role_Id]  DEFAULT ('') FOR [FK_Role_Id]
GO
ALTER TABLE [dbo].[Permissions_his] ADD  CONSTRAINT [DF_Permissions_his_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[Permissions_his] ADD  CONSTRAINT [DF_Permissions_his_SysCreateDate]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
ALTER TABLE [dbo].[Permissions_his] ADD  CONSTRAINT [DF_Permissions_his_SysCreate_user]  DEFAULT ('') FOR [SysCreateUser]
GO
ALTER TABLE [dbo].[Permissions_his]  WITH CHECK ADD  CONSTRAINT [FK_Permissions_his_Role_his] FOREIGN KEY([log_Role_Id])
REFERENCES [dbo].[Role_his] ([log_Id])
GO
ALTER TABLE [dbo].[Permissions_his] CHECK CONSTRAINT [FK_Permissions_his_Role_his]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'異動狀態' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Permissions_his', @level2type=N'COLUMN',@level2name=N'logType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'對應到的角色ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Permissions_his', @level2type=N'COLUMN',@level2name=N'FK_Role_Id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'權限對應到的功能ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Permissions_his', @level2type=N'COLUMN',@level2name=N'FK_Feature_Id'
GO
