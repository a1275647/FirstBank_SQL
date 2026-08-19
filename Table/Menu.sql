SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Menu](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[SystemId] [int] NOT NULL,
	[ParentId] [int] NULL,
	[Name_TN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Name_CN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Name_EN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Name_JP] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[MenuType] [int] NULL,
	[Seq] [int] NULL,
	[RouteName] [varchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[IsActive] [bit] NOT NULL,
	[ISSystem] [bit] NOT NULL,
	[ISNEEDFLOW] [bit] NOT NULL,
	[Icon] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [varchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_user] [varchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
 CONSTRAINT [PK_Menu_1] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[Menu] ADD  CONSTRAINT [DF_Menu_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[Menu] ADD  CONSTRAINT [DF_Menu_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
