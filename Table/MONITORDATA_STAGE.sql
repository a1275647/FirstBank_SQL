SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
-- =============================================
-- MONITORDATA_STAGE：每日轉檔的暫存表
--   轉檔流程（usp_TransferData、各 usp_Souce*、C# 各 Source、usp_TransferAfterUpdateMonitorData）
--   全部寫入此表，正式表 MONITORDATA 只在最後由 usp_MonitorData_Publish 以短交易換入，
--   避免長時間鎖住正式表。欄位需與 MONITORDATA 完全一致（PK_ID 除外可獨立配號）；
--   MONITORDATA 日後新增欄位時，此表必須同步新增，否則 usp_MonitorData_Publish 會擋下並報錯。
--   只建 (EXT_DATE, SOURCE) 索引供清除與去重查詢使用，不複製正式表其他索引，寫入更快。
-- =============================================
IF OBJECT_ID(N'[dbo].[MONITORDATA_STAGE]', N'U') IS NULL
BEGIN
	DECLARE @FilegroupSql NVARCHAR(MAX) = N'';
	SET @FilegroupSql += N'CREATE TABLE [dbo].[MONITORDATA_STAGE](
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
	[REVOLVE_MK] [bit] NOT NULL CONSTRAINT [DF_MONITORDATA_STAGE_REVOLVE_MK] DEFAULT ((0)),
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
	[Create_Date] [date] NULL CONSTRAINT [DF_MONITORDATA_STAGE_Create_Date] DEFAULT (getdate()),
	[Create_DateTime] [datetime] NULL CONSTRAINT [DF_MONITORDATA_STAGE_Create_DateTime] DEFAULT (getdate()),
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL CONSTRAINT [DF_MONITORDATA_STAGE_Create_user] DEFAULT (''System''),
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
	[TOP_Permit_No] [nvarchar](13) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[TOP_Limit_Cod] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[TOP_Country_Cod] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[TOP_Limit_Maturity] [date] NULL,
 CONSTRAINT [PK_MONITORDATA_STAGE] PRIMARY KEY CLUSTERED
(
	[PK_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]';
	IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
		SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
	EXEC sys.sp_executesql @FilegroupSql;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_MONITORDATA_STAGE_EXTDATE_SOURCE' AND object_id = OBJECT_ID(N'[dbo].[MONITORDATA_STAGE]'))
BEGIN
	DECLARE @IndexSql NVARCHAR(MAX) = N'';
	SET @IndexSql += N'CREATE NONCLUSTERED INDEX [IX_MONITORDATA_STAGE_EXTDATE_SOURCE] ON [dbo].[MONITORDATA_STAGE]
(
	[EXT_DATE] ASC,
	[SOURCE] ASC
)
INCLUDE([BRANCH_NO],[PERMIT_NO],[FIL9]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]';
	IF FILEGROUP_ID(N'NCRMS_IDX') IS NULL
		SET @IndexSql = REPLACE(@IndexSql, N'[NCRMS_IDX]', N'[PRIMARY]');
	EXEC sys.sp_executesql @IndexSql;
END
GO

-- 部署後即刻驗證：正式表的每個欄位在暫存表都要存在，缺任何一個就停止部署
IF EXISTS (
	SELECT 1
	FROM sys.columns m
	WHERE m.object_id = OBJECT_ID(N'[dbo].[MONITORDATA]')
	  AND NOT EXISTS (
		SELECT 1 FROM sys.columns s
		WHERE s.object_id = OBJECT_ID(N'[dbo].[MONITORDATA_STAGE]') AND s.name = m.name))
BEGIN
	DECLARE @Missing NVARCHAR(MAX) = (
		SELECT STUFF((
			SELECT N', ' + m.name
			FROM sys.columns m
			WHERE m.object_id = OBJECT_ID(N'[dbo].[MONITORDATA]')
			  AND NOT EXISTS (
				SELECT 1 FROM sys.columns s
				WHERE s.object_id = OBJECT_ID(N'[dbo].[MONITORDATA_STAGE]') AND s.name = m.name)
			FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, N''));
	DECLARE @Msg NVARCHAR(4000) = N'MONITORDATA_STAGE 缺少 MONITORDATA 的欄位：' + @Missing + N'，請先補齊欄位再繼續部署。';
	THROW 50010, @Msg, 1;
END
GO
