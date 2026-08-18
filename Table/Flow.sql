SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Flow](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_Menu_ID] [int] NOT NULL,
	[Name_TN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Name_CN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Name_EN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Name_JP] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[IsActive] [bit] NOT NULL,
	[VersionNo] [varchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [varchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [varchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_Flow] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[Flow] ADD  CONSTRAINT [DF_Flow_VersionNo]  DEFAULT ('1.0.0') FOR [VersionNo]
GO
ALTER TABLE [dbo].[Flow] ADD  CONSTRAINT [DF_Flow_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[Flow] ADD  CONSTRAINT [DF_Flow_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[Flow]  WITH CHECK ADD  CONSTRAINT [FK_Flow_Menu] FOREIGN KEY([FK_Menu_ID])
REFERENCES [dbo].[Menu] ([PK_Id])
GO
ALTER TABLE [dbo].[Flow] CHECK CONSTRAINT [FK_Flow_Menu]
GO
