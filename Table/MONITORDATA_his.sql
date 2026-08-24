SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[MONITORDATA_his](
	[Log_Id] [int] IDENTITY(1,1) NOT NULL,
	[LogType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[FlowFormId] [int] NOT NULL,
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
 CONSTRAINT [PK__MONITORD__2D26E78EA4B1BE09] PRIMARY KEY CLUSTERED
(
	[Log_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[MONITORDATA_his] ADD  CONSTRAINT [DF__MONITORDA__SysCr__2C745649]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
ALTER TABLE [dbo].[MONITORDATA_his]  WITH CHECK ADD  CONSTRAINT [FK_MONITORDATA_his_FlowForm] FOREIGN KEY([FlowFormId])
REFERENCES [dbo].[FlowForm] ([PK_Id])
GO
ALTER TABLE [dbo].[MONITORDATA_his] CHECK CONSTRAINT [FK_MONITORDATA_his_FlowForm]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'歷史記錄識別碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MONITORDATA_his', @level2type=N'COLUMN',@level2name=N'Log_Id'
GO
