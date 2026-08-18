SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MailGroupMapping](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[MailId] [int] NOT NULL,
	[MailGroupId] [int] NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_MailGroupMapping] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
GO
ALTER TABLE [dbo].[MailGroupMapping] ADD  CONSTRAINT [DF_MailGroupMapping_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[MailGroupMapping]  WITH CHECK ADD  CONSTRAINT [FK_MailGroupMapping_FKMailId_Mail_Id] FOREIGN KEY([MailId])
REFERENCES [dbo].[Mail] ([PK_Id])
GO
ALTER TABLE [dbo].[MailGroupMapping] CHECK CONSTRAINT [FK_MailGroupMapping_FKMailId_Mail_Id]
GO
ALTER TABLE [dbo].[MailGroupMapping]  WITH CHECK ADD  CONSTRAINT [FK_MailGroupMapping_MailGroupId_Group_Id] FOREIGN KEY([MailGroupId])
REFERENCES [dbo].[MailGroup] ([PK_Id])
GO
ALTER TABLE [dbo].[MailGroupMapping] CHECK CONSTRAINT [FK_MailGroupMapping_MailGroupId_Group_Id]
GO
