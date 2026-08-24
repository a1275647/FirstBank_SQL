SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[MONITORDATA](
	[PK_ID] [int] IDENTITY(1,1) NOT NULL,
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
	[SOURCE] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
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
	[TOP_Limit_USD_Amount] [decimal](18, 2) NULL,
	[TOP_Limit_Amount] [decimal](18, 2) NULL,
	[TRAN_FXRATE] [decimal](18, 10) NULL,
	[LIMIT_FXRATE] [decimal](18, 10) NULL,
	[CAL_TO_USD_AMT] [decimal](18, 2) NULL,
	[CAL_TO_USD_LIMIT] [decimal](18, 2) NULL,
 CONSTRAINT [PK_MONITORDATA] PRIMARY KEY CLUSTERED
(
	[PK_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_PADDING ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE NONCLUSTERED INDEX [IX_MONITORDATA_ASOFDATE_MARK] ON [dbo].[MONITORDATA]
(
	[AS_OF_DATE] ASC,
	[Mark] ASC,
	[PRODUCT_TYPE] ASC,
	[MATURITY_DATE] ASC
)
INCLUDE([PK_ID],[GROUP_NO],[UNIT_NO],[BRANCH_NO],[Create_DateTime],[Create_user]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]';
IF FILEGROUP_ID(N'NCRMS_IDX') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_IDX]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_PADDING ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE NONCLUSTERED INDEX [IX_MONITORDATA_ASOFDATE_PAGING] ON [dbo].[MONITORDATA]
(
	[AS_OF_DATE] ASC,
	[GROUP_NO] ASC,
	[UNIT_NO] ASC,
	[BRANCH_NO] ASC
)
INCLUDE([PK_ID],[TRAN_NO],[Mark],[MATURITY_DATE],[PRODUCT_TYPE]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]';
IF FILEGROUP_ID(N'NCRMS_IDX') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_IDX]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE NONCLUSTERED INDEX [IX_MONITORDATA_DATE] ON [dbo].[MONITORDATA]
(
	[EXT_DATE] ASC,
	[Year] ASC,
	[Month] ASC,
	[Week] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]';
IF FILEGROUP_ID(N'NCRMS_IDX') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_IDX]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[MONITORDATA] ADD  CONSTRAINT [DF_MONITORDATA_REVOLVE_MK]  DEFAULT ((0)) FOR [REVOLVE_MK]
GO
ALTER TABLE [dbo].[MONITORDATA] ADD  CONSTRAINT [DF_MONITORDATA_Create_Date]  DEFAULT (getdate()) FOR [Create_Date]
GO
ALTER TABLE [dbo].[MONITORDATA] ADD  CONSTRAINT [DF_MONITORDATA_Create_DateTime]  DEFAULT (getdate()) FOR [Create_DateTime]
GO
ALTER TABLE [dbo].[MONITORDATA] ADD  CONSTRAINT [DF_MONITORDATA_Create_user]  DEFAULT ('System') FOR [Create_user]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'事業群代號' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MONITORDATA', @level2type=N'COLUMN',@level2name=N'GROUP_NO'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'處級單位代號' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MONITORDATA', @level2type=N'COLUMN',@level2name=N'UNIT_NO'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'分行代碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MONITORDATA', @level2type=N'COLUMN',@level2name=N'BRANCH_NO'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'交易日期' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MONITORDATA', @level2type=N'COLUMN',@level2name=N'TX_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'資料日' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MONITORDATA', @level2type=N'COLUMN',@level2name=N'AS_OF_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'產品別' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MONITORDATA', @level2type=N'COLUMN',@level2name=N'PRODUCT_TYPE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'交易代號' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MONITORDATA', @level2type=N'COLUMN',@level2name=N'TRAN_NO'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'客戶名稱' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MONITORDATA', @level2type=N'COLUMN',@level2name=N'CUSTOMER_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'客戶ID或統編' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MONITORDATA', @level2type=N'COLUMN',@level2name=N'CUSTOMER_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'國家別' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MONITORDATA', @level2type=N'COLUMN',@level2name=N'COUNTRY_COD'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'交易幣別' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MONITORDATA', @level2type=N'COLUMN',@level2name=N'CURENCY_COD'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'交易金額' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MONITORDATA', @level2type=N'COLUMN',@level2name=N'TRAN_AMOUNT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'交易金額(美金)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MONITORDATA', @level2type=N'COLUMN',@level2name=N'TO_USD_AMT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'核准編號' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MONITORDATA', @level2type=N'COLUMN',@level2name=N'PERMIT_NO'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'核准金額' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MONITORDATA', @level2type=N'COLUMN',@level2name=N'LIMIT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'核准幣別' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MONITORDATA', @level2type=N'COLUMN',@level2name=N'LIMIT_COD'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'核准金額(美金)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MONITORDATA', @level2type=N'COLUMN',@level2name=N'TO_USD_LIMIT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'是否循環' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MONITORDATA', @level2type=N'COLUMN',@level2name=N'REVOLVE_MK'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'轉檔的來源' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MONITORDATA', @level2type=N'COLUMN',@level2name=N'FIL9'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'來源別' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MONITORDATA', @level2type=N'COLUMN',@level2name=N'SOURCE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'資料建立者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MONITORDATA', @level2type=N'COLUMN',@level2name=N'CREATOR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'額度到期日' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MONITORDATA', @level2type=N'COLUMN',@level2name=N'LIMIT_MATURITY'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'到期日' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MONITORDATA', @level2type=N'COLUMN',@level2name=N'MATURITY_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'客戶歸檔名稱' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MONITORDATA', @level2type=N'COLUMN',@level2name=N'GROUP_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'產業別' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MONITORDATA', @level2type=N'COLUMN',@level2name=N'INDUSTRY'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'產業別分海內外1=國內 2=海外' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MONITORDATA', @level2type=N'COLUMN',@level2name=N'INDUSTRY_Type'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'PRODUCT_CODE 07衍伸性產品風險係數用' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MONITORDATA', @level2type=N'COLUMN',@level2name=N'PRODUCT_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'買入幣別 07衍伸性產品風險係數用' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MONITORDATA', @level2type=N'COLUMN',@level2name=N'CUR_BOUGHT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'賣出幣別 07衍伸性產品風險係數用' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MONITORDATA', @level2type=N'COLUMN',@level2name=N'CUR_SOLD'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'風險係數' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MONITORDATA', @level2type=N'COLUMN',@level2name=N'RISKFACTOR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'權重' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MONITORDATA', @level2type=N'COLUMN',@level2name=N'WEIGHTS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'指定的轉檔日期' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MONITORDATA', @level2type=N'COLUMN',@level2name=N'DATADATE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建置日' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MONITORDATA', @level2type=N'COLUMN',@level2name=N'Create_Date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建置時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MONITORDATA', @level2type=N'COLUMN',@level2name=N'Create_DateTime'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建置者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MONITORDATA', @level2type=N'COLUMN',@level2name=N'Create_user'
GO
