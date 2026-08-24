SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[MailLog_Mapping](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_LogId] [int] NOT NULL,
	[FK_UserId] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_MailLog_Mapping] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[MailLog_Mapping]  WITH CHECK ADD  CONSTRAINT [FK_MailLog_Mapping_MailLog] FOREIGN KEY([FK_LogId])
REFERENCES [dbo].[MailLog] ([PK_Id])
GO
ALTER TABLE [dbo].[MailLog_Mapping] CHECK CONSTRAINT [FK_MailLog_Mapping_MailLog]
GO
ALTER TABLE [dbo].[MailLog_Mapping]  WITH CHECK ADD  CONSTRAINT [FK_MailLog_Mapping_Users] FOREIGN KEY([FK_UserId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[MailLog_Mapping] CHECK CONSTRAINT [FK_MailLog_Mapping_Users]
GO
