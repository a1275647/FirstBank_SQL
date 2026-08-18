SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RPA_his](
	[Log_Id] [int] IDENTITY(1,1) NOT NULL,
	[LogType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[FlowFormId] [int] NULL,
	[PK_Id] [int] NULL,
	[Type] [int] NULL,
	[Title] [nvarchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Contents] [nvarchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Url] [nvarchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Release_date] [date] NULL,
	[IsActive] [bit] NULL,
	[Create_date] [datetime] NULL,
	[Create_user] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Update_date] [datetime] NULL,
	[Update_user] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SysCreateDate] [datetime] NULL,
	[SysCreateUser] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
 CONSTRAINT [PK_RPA_his] PRIMARY KEY CLUSTERED
(
	[Log_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
GO
