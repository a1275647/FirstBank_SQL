SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[QuickLink](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_Menu_Id] [int] NULL,
	[ParentId] [int] NULL,
	[Name] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[DisplayName] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Type] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Icon] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[IconColor] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Seq] [int] NOT NULL,
	[UserId] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_QuickLink] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[QuickLink]  WITH CHECK ADD  CONSTRAINT [FK_QuickLink_QuickLink] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[QuickLink] CHECK CONSTRAINT [FK_QuickLink_QuickLink]
GO
