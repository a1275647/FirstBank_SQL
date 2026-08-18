SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MailCustomCcMapping](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_MailId] [int] NOT NULL,
	[CustomMail] [nvarchar](300) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_MailCustomCcMapping] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
GO
ALTER TABLE [dbo].[MailCustomCcMapping]  WITH CHECK ADD  CONSTRAINT [FK_MailCustomCcMapping_FKMailId_Mail_Id] FOREIGN KEY([FK_MailId])
REFERENCES [dbo].[Mail] ([PK_Id])
GO
ALTER TABLE [dbo].[MailCustomCcMapping] CHECK CONSTRAINT [FK_MailCustomCcMapping_FKMailId_Mail_Id]
GO
