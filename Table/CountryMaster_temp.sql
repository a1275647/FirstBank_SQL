SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CountryMaster_temp](
	[TempId] [int] IDENTITY(1,1) NOT NULL,
	[FlowFormId] [int] NULL,
	[ModifyType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[PK_Id] [int] NULL,
	[FK_Continent] [int] NULL,
	[CountryCode2] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CountryCode3] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CountryCode4] [nvarchar](4) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CountryName_TN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CountryName_EN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CountryName_JP] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CountryName_CN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[HASFCBBRANCH] [bit] NULL,
	[BusinessPoint] [decimal](5, 1) NULL,
	[CDSPoint] [decimal](5, 1) NULL,
	[ISIMFAE] [bit] NULL,
	[WarningUsePercent] [int] NULL,
	[IsActive] [bit] NULL,
	[IsException] [bit] NULL,
	[ExceptionExplain] [nvarchar](255) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[IsFocus] [bit] NULL,
	[FocusExplain] [nvarchar](255) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Create_date] [datetime] NOT NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK__CountryM__06C703C165F6C02C] PRIMARY KEY CLUSTERED
(
	[TempId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
GO
ALTER TABLE [dbo].[CountryMaster_temp] ADD  CONSTRAINT [DF_CountryMaster_temp_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[CountryMaster_temp] ADD  CONSTRAINT [DF_CountryMaster_temp_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[CountryMaster_temp] ADD  CONSTRAINT [DF_CountryMaster_temp_SysCreateDate]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
ALTER TABLE [dbo].[CountryMaster_temp]  WITH CHECK ADD  CONSTRAINT [FK_CountryMaster_temp_FlowForm] FOREIGN KEY([FlowFormId])
REFERENCES [dbo].[FlowForm] ([PK_Id])
GO
ALTER TABLE [dbo].[CountryMaster_temp] CHECK CONSTRAINT [FK_CountryMaster_temp_FlowForm]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'暫存資料識別碼（流水號）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryMaster_temp', @level2type=N'COLUMN',@level2name=N'TempId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'流程表單識別碼（外鍵：FLOW_FORM.PK_ID）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryMaster_temp', @level2type=N'COLUMN',@level2name=N'FlowFormId'
GO
