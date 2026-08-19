SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MailGroupCcMapping](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[MailId] [int] NOT NULL,
	[MailGroupId] [int] NOT NULL,
	[Create_date] [datetime] NULL,
	[Create_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
 CONSTRAINT [PK_MailGroupToCCMapping] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
GO
ALTER TABLE [dbo].[MailGroupCcMapping] ADD  CONSTRAINT [DF_MailGroupToCCMapping_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[MailGroupCcMapping]  WITH CHECK ADD  CONSTRAINT [FK_MailGroupCcMapping_FKMailId_Mail_Id] FOREIGN KEY([MailId])
REFERENCES [dbo].[Mail] ([PK_Id])
GO
ALTER TABLE [dbo].[MailGroupCcMapping] CHECK CONSTRAINT [FK_MailGroupCcMapping_FKMailId_Mail_Id]
GO
ALTER TABLE [dbo].[MailGroupCcMapping]  WITH CHECK ADD  CONSTRAINT [FK_MailGroupCcMapping_MailGroupId_Group_Id] FOREIGN KEY([MailGroupId])
REFERENCES [dbo].[MailGroup] ([PK_Id])
GO
ALTER TABLE [dbo].[MailGroupCcMapping] CHECK CONSTRAINT [FK_MailGroupCcMapping_MailGroupId_Group_Id]
GO
