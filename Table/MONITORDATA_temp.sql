SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MONITORDATA_temp](
	[TempId] [int] IDENTITY(1,1) NOT NULL,
	[FlowFormId] [int] NULL,
	[ModifyType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[PK_ID] [int] NOT NULL,
	[GROUP_NO] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[UNIT_NO] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[BRANCH_NO] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[TX_DATE] [date] NULL,
	[AS_OF_DATE] [date] NULL,
	[PRODUCT_TYPE] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[TRAN_NO] [nvarchar](25) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CUSTOMER_NAME] [nvarchar](40) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CUSTOMER_ID] [nvarchar](11) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[COUNTRY_COD] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CURENCY_COD] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[TRAN_AMOUNT] [decimal](18, 2) NULL,
	[TO_USD_AMT] [decimal](18, 2) NULL,
	[PERMIT_NO] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LIMIT] [decimal](18, 2) NULL,
	[LIMIT_COD] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[TO_USD_LIMIT] [decimal](18, 2) NULL,
	[REVOLVE_MK] [bit] NOT NULL,
	[FIL9] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SOURCE] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CREATOR] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LIMIT_MATURITY] [date] NULL,
	[MATURITY_DATE] [date] NULL,
	[GROUP_NAME] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[INDUSTRY] [nvarchar](6) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[INDUSTRY_Type] [int] NULL,
	[PRODUCT_CODE] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CUR_BOUGHT] [nchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CUR_SOLD] [nchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[RISKFACTOR] [decimal](10, 2) NULL,
	[WEIGHTS] [int] NULL,
	[DATADATE] [date] NULL,
	[Create_Date] [date] NULL,
	[Create_DateTime] [datetime] NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Year] [int] NULL,
	[Month] [int] NULL,
	[Week] [int] NULL,
	[EXT_DATE] [date] NULL,
	[Mark] [bit] NULL,
	[Lock] [bit] NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[TRAN_FXRATE] [decimal](18, 10) NULL,
	[LIMIT_FXRATE] [decimal](18, 10) NULL,
	[CAL_TO_USD_AMT] [decimal](18, 2) NULL,
	[CAL_TO_USD_LIMIT] [decimal](18, 2) NULL,
 CONSTRAINT [PK__MONITORD__06C703C13456C90D] PRIMARY KEY CLUSTERED
(
	[TempId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
GO
ALTER TABLE [dbo].[MONITORDATA_temp] ADD  CONSTRAINT [DF__MONITORDA__REVOL__24D33481]  DEFAULT ((0)) FOR [REVOLVE_MK]
GO
ALTER TABLE [dbo].[MONITORDATA_temp] ADD  CONSTRAINT [DF__MONITORDA__Creat__25C758BA]  DEFAULT (getdate()) FOR [Create_Date]
GO
ALTER TABLE [dbo].[MONITORDATA_temp] ADD  CONSTRAINT [DF__MONITORDA__Creat__26BB7CF3]  DEFAULT (getdate()) FOR [Create_DateTime]
GO
ALTER TABLE [dbo].[MONITORDATA_temp] ADD  CONSTRAINT [DF__MONITORDA__Creat__27AFA12C]  DEFAULT ('System') FOR [Create_user]
GO
ALTER TABLE [dbo].[MONITORDATA_temp] ADD  CONSTRAINT [DF__MONITORDA__SysCr__28A3C565]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
ALTER TABLE [dbo].[MONITORDATA_temp]  WITH CHECK ADD  CONSTRAINT [FK_MONITORDATA_temp_FlowForm] FOREIGN KEY([FlowFormId])
REFERENCES [dbo].[FlowForm] ([PK_Id])
GO
ALTER TABLE [dbo].[MONITORDATA_temp] CHECK CONSTRAINT [FK_MONITORDATA_temp_FlowForm]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'暫存資料識別碼（流水號）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MONITORDATA_temp', @level2type=N'COLUMN',@level2name=N'TempId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'流程表單識別碼（外鍵：FlowForm.PK_ID）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MONITORDATA_temp', @level2type=N'COLUMN',@level2name=N'FlowFormId'
GO
