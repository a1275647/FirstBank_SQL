SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Customer_temp](
	[TempId] [int] IDENTITY(1,1) NOT NULL,
	[FlowFormId] [int] NULL,
	[ModifyType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
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
 CONSTRAINT [PK__Customer__06C703C189975D63] PRIMARY KEY CLUSTERED
(
	[TempId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
GO
ALTER TABLE [dbo].[Customer_temp] ADD  CONSTRAINT [DF__Customer___IsSys__1B7ED471]  DEFAULT ((1)) FOR [IsSystem]
GO
ALTER TABLE [dbo].[Customer_temp] ADD  CONSTRAINT [DF__Customer___Syste__1C72F8AA]  DEFAULT (getdate()) FOR [System_date]
GO
ALTER TABLE [dbo].[Customer_temp] ADD  CONSTRAINT [DF__Customer___Updat__1D671CE3]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[Customer_temp] ADD  CONSTRAINT [DF__Customer___Updat__1E5B411C]  DEFAULT (N'system') FOR [Update_user]
GO
ALTER TABLE [dbo].[Customer_temp] ADD  CONSTRAINT [DF__Customer___Creat__1F4F6555]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[Customer_temp] ADD  CONSTRAINT [DF__Customer___Creat__2043898E]  DEFAULT (N'system') FOR [Create_user]
GO
ALTER TABLE [dbo].[Customer_temp] ADD  CONSTRAINT [DF__Customer___SysCr__2137ADC7]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
ALTER TABLE [dbo].[Customer_temp]  WITH CHECK ADD  CONSTRAINT [FK_Customer_temp_FlowForm] FOREIGN KEY([FlowFormId])
REFERENCES [dbo].[FlowForm] ([PK_Id])
GO
ALTER TABLE [dbo].[Customer_temp] CHECK CONSTRAINT [FK_Customer_temp_FlowForm]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'暫存資料識別碼（流水號）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer_temp', @level2type=N'COLUMN',@level2name=N'TempId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'流程表單識別碼（外鍵：FlowForm.PK_ID）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer_temp', @level2type=N'COLUMN',@level2name=N'FlowFormId'
GO
