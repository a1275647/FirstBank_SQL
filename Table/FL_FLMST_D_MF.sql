SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[FL_FLMST_D_MF](
	[FLMST_CUST_ID] [nvarchar](11) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[FLMST_LC_NO] [nvarchar](11) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[FLMST_DATA_TYPE] [nvarchar](1) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[FLMST_RECV_BRANCH] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[FLMST_CURENCY] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[FLMST_DATA_STATUS] [nvarchar](1) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[FLMST_ACNT_BRANCH] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[FLMST_MATURITY] [date] NULL,
	[FLMST_NEGO_DATE] [date] NULL,
	[FLMST_LOAN_TYPE] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[FLMST_ADVANCE_BALANCE] [decimal](15, 2) NULL,
	[FLMST_SUBSTITUTE_REMIT_MK] [nvarchar](1) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[FLMST_APRV_NO_1] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[FLMST_APRV_TYPE_1] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[FLMST_APRV_CUR_1] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[FLMST_EXT_DATE] [date] NULL,
	[FLMST_FINAL_RISK_CNTY] [nvarchar](4) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[BUSINS_CODE] [nvarchar](7) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Create_Date] [date] NULL
) ON [NCRMS_TAB]';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[FL_FLMST_D_MF] ADD  CONSTRAINT [DF_FL_FLMST_D_MF_Create_Date]  DEFAULT (getdate()) FOR [Create_Date]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'統編
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FL_FLMST_D_MF', @level2type=N'COLUMN',@level2name=N'FLMST_CUST_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'外幣貸款編號
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FL_FLMST_D_MF', @level2type=N'COLUMN',@level2name=N'FLMST_LC_NO'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'資料種類
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FL_FLMST_D_MF', @level2type=N'COLUMN',@level2name=N'FLMST_DATA_TYPE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'受理行' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FL_FLMST_D_MF', @level2type=N'COLUMN',@level2name=N'FLMST_RECV_BRANCH'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'幣別
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FL_FLMST_D_MF', @level2type=N'COLUMN',@level2name=N'FLMST_CURENCY'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'主檔狀況' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FL_FLMST_D_MF', @level2type=N'COLUMN',@level2name=N'FLMST_DATA_STATUS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'帳務單位' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FL_FLMST_D_MF', @level2type=N'COLUMN',@level2name=N'FLMST_ACNT_BRANCH'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'貸款到期日' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FL_FLMST_D_MF', @level2type=N'COLUMN',@level2name=N'FLMST_MATURITY'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'押匯日(初貸日)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FL_FLMST_D_MF', @level2type=N'COLUMN',@level2name=N'FLMST_NEGO_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'貸放種類
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FL_FLMST_D_MF', @level2type=N'COLUMN',@level2name=N'FLMST_LOAN_TYPE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'墊款餘額(放款餘額)
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FL_FLMST_D_MF', @level2type=N'COLUMN',@level2name=N'FLMST_ADVANCE_BALANCE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'資金用途' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FL_FLMST_D_MF', @level2type=N'COLUMN',@level2name=N'FLMST_SUBSTITUTE_REMIT_MK'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'核准號碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FL_FLMST_D_MF', @level2type=N'COLUMN',@level2name=N'FLMST_APRV_NO_1'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'額度種類
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FL_FLMST_D_MF', @level2type=N'COLUMN',@level2name=N'FLMST_APRV_TYPE_1'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'核准幣別' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FL_FLMST_D_MF', @level2type=N'COLUMN',@level2name=N'FLMST_APRV_CUR_1'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'資料日期
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FL_FLMST_D_MF', @level2type=N'COLUMN',@level2name=N'FLMST_EXT_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'最終風險國家
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FL_FLMST_D_MF', @level2type=N'COLUMN',@level2name=N'FLMST_FINAL_RISK_CNTY'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'產業別' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FL_FLMST_D_MF', @level2type=N'COLUMN',@level2name=N'BUSINS_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建置時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FL_FLMST_D_MF', @level2type=N'COLUMN',@level2name=N'Create_Date'
GO
