SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FlowDetail](
	[PK_Id] [uniqueidentifier] NOT NULL,
	[FK_Flow_Id] [int] NOT NULL,
	[TitleId] [int] NULL,
	[Name_TN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Name_CN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Name_EN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Name_JP] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[ElsType] [int] NOT NULL,
	[Stage] [int] NOT NULL,
	[Seq] [int] NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [varchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [varchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_FlowDetail] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[FlowDetail] ADD  CONSTRAINT [DF_FlowDetail_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[FlowDetail] ADD  CONSTRAINT [DF_FlowDetail_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[FlowDetail]  WITH CHECK ADD  CONSTRAINT [FK_FlowDetail_Flow] FOREIGN KEY([FK_Flow_Id])
REFERENCES [dbo].[Flow] ([PK_Id])
GO
ALTER TABLE [dbo].[FlowDetail] CHECK CONSTRAINT [FK_FlowDetail_Flow]
GO
