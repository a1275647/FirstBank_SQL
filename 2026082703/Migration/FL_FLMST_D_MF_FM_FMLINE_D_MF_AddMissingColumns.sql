SET NOCOUNT ON;

-------------------------------------------------------------------------------
-- dbo.FL_FLMST_D_MF：對照 FirstBankContext 目前 entity 設定，逐欄檢查是否存在
-------------------------------------------------------------------------------

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE [object_id] = OBJECT_ID(N'[dbo].[FL_FLMST_D_MF]') AND [name] = N'FLMST_CUST_ID')
    ALTER TABLE [dbo].[FL_FLMST_D_MF] ADD [FLMST_CUST_ID] [nvarchar](11) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE [object_id] = OBJECT_ID(N'[dbo].[FL_FLMST_D_MF]') AND [name] = N'FLMST_LC_NO')
    ALTER TABLE [dbo].[FL_FLMST_D_MF] ADD [FLMST_LC_NO] [nvarchar](11) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE [object_id] = OBJECT_ID(N'[dbo].[FL_FLMST_D_MF]') AND [name] = N'FLMST_DATA_TYPE')
    ALTER TABLE [dbo].[FL_FLMST_D_MF] ADD [FLMST_DATA_TYPE] [nvarchar](1) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE [object_id] = OBJECT_ID(N'[dbo].[FL_FLMST_D_MF]') AND [name] = N'FLMST_RECV_BRANCH')
    ALTER TABLE [dbo].[FL_FLMST_D_MF] ADD [FLMST_RECV_BRANCH] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE [object_id] = OBJECT_ID(N'[dbo].[FL_FLMST_D_MF]') AND [name] = N'FLMST_CURENCY')
    ALTER TABLE [dbo].[FL_FLMST_D_MF] ADD [FLMST_CURENCY] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE [object_id] = OBJECT_ID(N'[dbo].[FL_FLMST_D_MF]') AND [name] = N'FLMST_DATA_STATUS')
    ALTER TABLE [dbo].[FL_FLMST_D_MF] ADD [FLMST_DATA_STATUS] [nvarchar](1) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE [object_id] = OBJECT_ID(N'[dbo].[FL_FLMST_D_MF]') AND [name] = N'FLMST_ACNT_BRANCH')
    ALTER TABLE [dbo].[FL_FLMST_D_MF] ADD [FLMST_ACNT_BRANCH] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE [object_id] = OBJECT_ID(N'[dbo].[FL_FLMST_D_MF]') AND [name] = N'FLMST_MATURITY')
    ALTER TABLE [dbo].[FL_FLMST_D_MF] ADD [FLMST_MATURITY] [date] NULL;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE [object_id] = OBJECT_ID(N'[dbo].[FL_FLMST_D_MF]') AND [name] = N'FLMST_NEGO_DATE')
    ALTER TABLE [dbo].[FL_FLMST_D_MF] ADD [FLMST_NEGO_DATE] [date] NULL;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE [object_id] = OBJECT_ID(N'[dbo].[FL_FLMST_D_MF]') AND [name] = N'FLMST_LOAN_TYPE')
    ALTER TABLE [dbo].[FL_FLMST_D_MF] ADD [FLMST_LOAN_TYPE] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE [object_id] = OBJECT_ID(N'[dbo].[FL_FLMST_D_MF]') AND [name] = N'FLMST_ADVANCE_BALANCE')
    ALTER TABLE [dbo].[FL_FLMST_D_MF] ADD [FLMST_ADVANCE_BALANCE] [decimal](18, 5) NULL;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE [object_id] = OBJECT_ID(N'[dbo].[FL_FLMST_D_MF]') AND [name] = N'FLMST_CLOSE_DATE')
    ALTER TABLE [dbo].[FL_FLMST_D_MF] ADD [FLMST_CLOSE_DATE] [date] NULL;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE [object_id] = OBJECT_ID(N'[dbo].[FL_FLMST_D_MF]') AND [name] = N'FLMST_DISCOUNT_INT')
    ALTER TABLE [dbo].[FL_FLMST_D_MF] ADD [FLMST_DISCOUNT_INT] [decimal](18, 5) NULL;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE [object_id] = OBJECT_ID(N'[dbo].[FL_FLMST_D_MF]') AND [name] = N'FLMST_SUBSTITUTE_REMIT_MK')
    ALTER TABLE [dbo].[FL_FLMST_D_MF] ADD [FLMST_SUBSTITUTE_REMIT_MK] [nvarchar](1) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE [object_id] = OBJECT_ID(N'[dbo].[FL_FLMST_D_MF]') AND [name] = N'FLMST_APRV_NO_1')
    ALTER TABLE [dbo].[FL_FLMST_D_MF] ADD [FLMST_APRV_NO_1] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE [object_id] = OBJECT_ID(N'[dbo].[FL_FLMST_D_MF]') AND [name] = N'FLMST_APRV_TYPE_1')
    ALTER TABLE [dbo].[FL_FLMST_D_MF] ADD [FLMST_APRV_TYPE_1] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE [object_id] = OBJECT_ID(N'[dbo].[FL_FLMST_D_MF]') AND [name] = N'FLMST_APRV_CUR_1')
    ALTER TABLE [dbo].[FL_FLMST_D_MF] ADD [FLMST_APRV_CUR_1] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE [object_id] = OBJECT_ID(N'[dbo].[FL_FLMST_D_MF]') AND [name] = N'FLMST_EXT_DATE')
    ALTER TABLE [dbo].[FL_FLMST_D_MF] ADD [FLMST_EXT_DATE] [date] NULL;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE [object_id] = OBJECT_ID(N'[dbo].[FL_FLMST_D_MF]') AND [name] = N'FLMST_FINAL_RISK_CNTY')
    ALTER TABLE [dbo].[FL_FLMST_D_MF] ADD [FLMST_FINAL_RISK_CNTY] [nvarchar](4) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE [object_id] = OBJECT_ID(N'[dbo].[FL_FLMST_D_MF]') AND [name] = N'BUSINS_CODE')
    ALTER TABLE [dbo].[FL_FLMST_D_MF] ADD [BUSINS_CODE] [nvarchar](7) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE [object_id] = OBJECT_ID(N'[dbo].[FL_FLMST_D_MF]') AND [name] = N'Create_Date')
BEGIN
    ALTER TABLE [dbo].[FL_FLMST_D_MF] ADD [Create_Date] [date] NULL CONSTRAINT [DF_FL_FLMST_D_MF_Create_Date] DEFAULT (getdate());
END

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE [object_id] = OBJECT_ID(N'[dbo].[FL_FLMST_D_MF]') AND [name] = N'Create_user')
BEGIN
    ALTER TABLE [dbo].[FL_FLMST_D_MF] ADD [Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL CONSTRAINT [DF_FL_FLMST_D_MF_Create_user] DEFAULT (N'system');
END

-------------------------------------------------------------------------------
-- dbo.FM_FMLINE_D_MF：對照 FirstBankContext 目前 entity 設定，逐欄檢查是否存在
-------------------------------------------------------------------------------

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE [object_id] = OBJECT_ID(N'[dbo].[FM_FMLINE_D_MF]') AND [name] = N'FMLINE_CUST_ID')
    ALTER TABLE [dbo].[FM_FMLINE_D_MF] ADD [FMLINE_CUST_ID] [nvarchar](11) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE [object_id] = OBJECT_ID(N'[dbo].[FM_FMLINE_D_MF]') AND [name] = N'FMLINE_DATE_TYPE')
    ALTER TABLE [dbo].[FM_FMLINE_D_MF] ADD [FMLINE_DATE_TYPE] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE [object_id] = OBJECT_ID(N'[dbo].[FM_FMLINE_D_MF]') AND [name] = N'FMLINE_BRANCH')
    ALTER TABLE [dbo].[FM_FMLINE_D_MF] ADD [FMLINE_BRANCH] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE [object_id] = OBJECT_ID(N'[dbo].[FM_FMLINE_D_MF]') AND [name] = N'FMLINE_LINE_TYPE')
    ALTER TABLE [dbo].[FM_FMLINE_D_MF] ADD [FMLINE_LINE_TYPE] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE [object_id] = OBJECT_ID(N'[dbo].[FM_FMLINE_D_MF]') AND [name] = N'FMLINE_APRV_NO')
    ALTER TABLE [dbo].[FM_FMLINE_D_MF] ADD [FMLINE_APRV_NO] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE [object_id] = OBJECT_ID(N'[dbo].[FM_FMLINE_D_MF]') AND [name] = N'FMLINE_REVOLING_TYPE')
    ALTER TABLE [dbo].[FM_FMLINE_D_MF] ADD [FMLINE_REVOLING_TYPE] [nvarchar](1) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE [object_id] = OBJECT_ID(N'[dbo].[FM_FMLINE_D_MF]') AND [name] = N'FMLINE_LINE_EXPIRY')
    ALTER TABLE [dbo].[FM_FMLINE_D_MF] ADD [FMLINE_LINE_EXPIRY] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE [object_id] = OBJECT_ID(N'[dbo].[FM_FMLINE_D_MF]') AND [name] = N'FMLINE_LINE_AMT')
    ALTER TABLE [dbo].[FM_FMLINE_D_MF] ADD [FMLINE_LINE_AMT] [decimal](15, 2) NULL;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE [object_id] = OBJECT_ID(N'[dbo].[FM_FMLINE_D_MF]') AND [name] = N'FMLINE_FINAL_RISK_CNTY')
    ALTER TABLE [dbo].[FM_FMLINE_D_MF] ADD [FMLINE_FINAL_RISK_CNTY] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE [object_id] = OBJECT_ID(N'[dbo].[FM_FMLINE_D_MF]') AND [name] = N'FMLINE_MULT_MERGED_MARK')
    ALTER TABLE [dbo].[FM_FMLINE_D_MF] ADD [FMLINE_MULT_MERGED_MARK] [nvarchar](1) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE [object_id] = OBJECT_ID(N'[dbo].[FM_FMLINE_D_MF]') AND [name] = N'FMLINE_MULT_MERGED_APRV_NO')
    ALTER TABLE [dbo].[FM_FMLINE_D_MF] ADD [FMLINE_MULT_MERGED_APRV_NO] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE [object_id] = OBJECT_ID(N'[dbo].[FM_FMLINE_D_MF]') AND [name] = N'FMLINE_EXT_DATE')
    ALTER TABLE [dbo].[FM_FMLINE_D_MF] ADD [FMLINE_EXT_DATE] [date] NULL;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE [object_id] = OBJECT_ID(N'[dbo].[FM_FMLINE_D_MF]') AND [name] = N'BUSINS_CODE')
    ALTER TABLE [dbo].[FM_FMLINE_D_MF] ADD [BUSINS_CODE] [nvarchar](7) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE [object_id] = OBJECT_ID(N'[dbo].[FM_FMLINE_D_MF]') AND [name] = N'Create_Date')
    ALTER TABLE [dbo].[FM_FMLINE_D_MF] ADD [Create_Date] [date] NOT NULL CONSTRAINT [DF_FM_FMLINE_D_MF_Create_Date] DEFAULT (getdate());

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE [object_id] = OBJECT_ID(N'[dbo].[FM_FMLINE_D_MF]') AND [name] = N'Create_user')
BEGIN
    ALTER TABLE [dbo].[FM_FMLINE_D_MF] ADD [Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL CONSTRAINT [DF_FM_FMLINE_D_MF_Create_user] DEFAULT (N'system');
END
