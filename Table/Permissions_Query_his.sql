SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Permissions_Query_his](
	[log_id] [int] IDENTITY(1,1) NOT NULL,
	[logtype] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[log_Role_Id] [int] NOT NULL,
	[PK_Id] [int] NOT NULL,
	[FK_Role_Id] [int] NOT NULL,
	[LevelCode] [int] NOT NULL,
	[OrgCode] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK__Permissi__9E2397E072A11B54] PRIMARY KEY CLUSTERED
(
	[log_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
GO
ALTER TABLE [dbo].[Permissions_Query_his] ADD  CONSTRAINT [DF_Permissions_Query_his_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[Permissions_Query_his] ADD  CONSTRAINT [DF_Permissions_Query_his_SysCreateDate]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
ALTER TABLE [dbo].[Permissions_Query_his]  WITH CHECK ADD  CONSTRAINT [FK_Permissions_Query_his_Role_his] FOREIGN KEY([log_Role_Id])
REFERENCES [dbo].[Role_his] ([log_Id])
GO
ALTER TABLE [dbo].[Permissions_Query_his] CHECK CONSTRAINT [FK_Permissions_Query_his_Role_his]
GO
