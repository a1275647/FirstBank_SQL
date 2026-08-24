SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[MailToMapping](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_MailId] [int] NOT NULL,
	[FK_UserId] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_MailToMapping] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[MailToMapping]  WITH CHECK ADD  CONSTRAINT [Fk_MailToMapping_FKMailId_Mail_Id] FOREIGN KEY([FK_MailId])
REFERENCES [dbo].[Mail] ([PK_Id])
GO
ALTER TABLE [dbo].[MailToMapping] CHECK CONSTRAINT [Fk_MailToMapping_FKMailId_Mail_Id]
GO
ALTER TABLE [dbo].[MailToMapping]  WITH CHECK ADD  CONSTRAINT [FK_MailToMapping_UserId_Users_UserId] FOREIGN KEY([FK_UserId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[MailToMapping] CHECK CONSTRAINT [FK_MailToMapping_UserId_Users_UserId]
GO
