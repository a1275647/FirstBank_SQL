SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Customer_his](
	[Log_Id] [int] IDENTITY(1,1) NOT NULL,
	[LogType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[FlowFormId] [int] NOT NULL,
	[PK_Id] [int] NOT NULL,
	[GroupId] [int] NULL,
	[CustomerName] [nvarchar](500) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Unit] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CustomerId] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SwiftCode] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LEI] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[ISIN] [nvarchar](12) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Remark] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[IsSystem] [bit] NOT NULL,
	[System_date] [datetime] NOT NULL,
	[Update_date] [datetime] NULL,
	[Update_user] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Create_date] [datetime] NULL,
	[Create_user] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[CustomerMark] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
 CONSTRAINT [PK__Customer__2D26E78E5F476C2D] PRIMARY KEY CLUSTERED
(
	[Log_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
GO
ALTER TABLE [dbo].[Customer_his] ADD  CONSTRAINT [DF__Customer___SysCr__25083EAB]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
ALTER TABLE [dbo].[Customer_his]  WITH CHECK ADD  CONSTRAINT [FK_Customer_his_FlowForm] FOREIGN KEY([FlowFormId])
REFERENCES [dbo].[FlowForm] ([PK_Id])
GO
ALTER TABLE [dbo].[Customer_his] CHECK CONSTRAINT [FK_Customer_his_FlowForm]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'歷史記錄識別碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer_his', @level2type=N'COLUMN',@level2name=N'Log_Id'
GO
