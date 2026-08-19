SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Role_User_Mapping](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_Role_Id] [int] NOT NULL,
	[FK_User_Id] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_USER_PERMISSIONS_MAPPING] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_Role_User_Mapping] ON [dbo].[Role_User_Mapping]
(
	[FK_User_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
GO
CREATE NONCLUSTERED INDEX [IX_Role_User_Mapping_1] ON [dbo].[Role_User_Mapping]
(
	[FK_Role_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
GO
ALTER TABLE [dbo].[Role_User_Mapping] ADD  CONSTRAINT [DF_USER_PERMISSIONS_MAPPING_FK_Role_Id]  DEFAULT ((0)) FOR [FK_Role_Id]
GO
ALTER TABLE [dbo].[Role_User_Mapping] ADD  CONSTRAINT [DF_USER_PERMISSIONS_MAPPING_FK_User_Id]  DEFAULT ((0)) FOR [FK_User_Id]
GO
ALTER TABLE [dbo].[Role_User_Mapping] ADD  CONSTRAINT [DF_Role_User_Mapping_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[Role_User_Mapping] ADD  CONSTRAINT [DF_Role_User_Mapping_Create_user]  DEFAULT ('') FOR [Create_user]
GO
ALTER TABLE [dbo].[Role_User_Mapping]  WITH CHECK ADD  CONSTRAINT [FK_Role_User_Mapping_Role] FOREIGN KEY([FK_Role_Id])
REFERENCES [dbo].[Role] ([PK_Id])
GO
ALTER TABLE [dbo].[Role_User_Mapping] CHECK CONSTRAINT [FK_Role_User_Mapping_Role]
GO
ALTER TABLE [dbo].[Role_User_Mapping]  WITH CHECK ADD  CONSTRAINT [FK_Role_User_Mapping_Users] FOREIGN KEY([FK_User_Id])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[Role_User_Mapping] CHECK CONSTRAINT [FK_Role_User_Mapping_Users]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'使用者對訂到的角色' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Role_User_Mapping', @level2type=N'COLUMN',@level2name=N'FK_Role_Id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'對應到的使用者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Role_User_Mapping', @level2type=N'COLUMN',@level2name=N'FK_User_Id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'異動日期' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Role_User_Mapping', @level2type=N'COLUMN',@level2name=N'Create_date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'異動者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Role_User_Mapping', @level2type=N'COLUMN',@level2name=N'Create_user'
GO
