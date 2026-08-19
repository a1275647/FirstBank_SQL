SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Permissions](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_Role_Id] [int] NOT NULL,
	[FK_Feature_Id] [int] NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_PERMISSIONS] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
GO
ALTER TABLE [dbo].[Permissions] ADD  CONSTRAINT [DF_PERMISSIONS_FK_Role_Id]  DEFAULT ((0)) FOR [FK_Role_Id]
GO
ALTER TABLE [dbo].[Permissions] ADD  CONSTRAINT [DF_Permissions_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[Permissions]  WITH CHECK ADD  CONSTRAINT [FK_Permissions_FeatureDetail] FOREIGN KEY([FK_Feature_Id])
REFERENCES [dbo].[FeatureDetail] ([PK_Id])
GO
ALTER TABLE [dbo].[Permissions] CHECK CONSTRAINT [FK_Permissions_FeatureDetail]
GO
ALTER TABLE [dbo].[Permissions]  WITH CHECK ADD  CONSTRAINT [FK_Permissions_Role] FOREIGN KEY([FK_Role_Id])
REFERENCES [dbo].[Role] ([PK_Id])
GO
ALTER TABLE [dbo].[Permissions] CHECK CONSTRAINT [FK_Permissions_Role]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'權限對定的角色' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Permissions', @level2type=N'COLUMN',@level2name=N'FK_Role_Id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'權限對應的功能' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Permissions', @level2type=N'COLUMN',@level2name=N'FK_Feature_Id'
GO
