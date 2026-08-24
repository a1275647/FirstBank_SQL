SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[MailGroupUser](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[MailGroup_Id] [int] NOT NULL,
	[UserId] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_MailGroupUser] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE NONCLUSTERED INDEX [IX_MailGroupUser] ON [dbo].[MailGroupUser]
(
	[PK_Id] ASC,
	[MailGroup_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]';
IF FILEGROUP_ID(N'NCRMS_IDX') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_IDX]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[MailGroupUser] ADD  CONSTRAINT [DF_MailGroupUser_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[MailGroupUser]  WITH CHECK ADD  CONSTRAINT [FK_MailGroupUser_MailGroupId_Group_Id] FOREIGN KEY([MailGroup_Id])
REFERENCES [dbo].[MailGroup] ([PK_Id])
GO
ALTER TABLE [dbo].[MailGroupUser] CHECK CONSTRAINT [FK_MailGroupUser_MailGroupId_Group_Id]
GO
ALTER TABLE [dbo].[MailGroupUser]  WITH CHECK ADD  CONSTRAINT [FK_MailGroupUser_UserId_Users_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[MailGroupUser] CHECK CONSTRAINT [FK_MailGroupUser_UserId_Users_UserId]
GO
