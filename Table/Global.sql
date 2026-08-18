SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Global](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Code] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[GroupId] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Name_TN] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Name_CN] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Name_EN] [nvarchar](300) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Name_JP] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Seq] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[Memo] [nvarchar](4000) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [varchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_user] [varchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Field1] [nvarchar](4000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
 CONSTRAINT [PK_M_Combolist_1] PRIMARY KEY CLUSTERED
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[Global] ADD  CONSTRAINT [DF_Global_Code]  DEFAULT ('') FOR [Code]
GO
ALTER TABLE [dbo].[Global] ADD  CONSTRAINT [DF_Global_Name_TN]  DEFAULT ('') FOR [Name_TN]
GO
ALTER TABLE [dbo].[Global] ADD  CONSTRAINT [DF_Global_Name_CN]  DEFAULT ('') FOR [Name_CN]
GO
ALTER TABLE [dbo].[Global] ADD  CONSTRAINT [DF_Global_Name_EN]  DEFAULT ('') FOR [Name_EN]
GO
ALTER TABLE [dbo].[Global] ADD  CONSTRAINT [DF_Global_Name_JP]  DEFAULT ('') FOR [Name_JP]
GO
ALTER TABLE [dbo].[Global] ADD  CONSTRAINT [DF_Global_Seq]  DEFAULT ((1)) FOR [Seq]
GO
ALTER TABLE [dbo].[Global] ADD  CONSTRAINT [DF_Global_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[Global] ADD  CONSTRAINT [DF_Global_Memo]  DEFAULT ('') FOR [Memo]
GO
ALTER TABLE [dbo].[Global] ADD  CONSTRAINT [DF_Global_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[Global] ADD  CONSTRAINT [DF_Global_Update_user]  DEFAULT ('system') FOR [Update_user]
GO
ALTER TABLE [dbo].[Global] ADD  CONSTRAINT [DF_Global_Create_user]  DEFAULT ('system') FOR [Create_user]
GO
ALTER TABLE [dbo].[Global] ADD  CONSTRAINT [DF_Global_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
