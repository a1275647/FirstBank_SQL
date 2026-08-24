SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[OS_LNSMSTD_D_MF](
	[LNSMSTD_STATUS] [nvarchar](1) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LNSMSTD_BRANCH_NO] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LNSMSTD_TX_TYPE] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LNSMSTD_TX_NO] [nvarchar](25) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LNSMSTD_CURRENCY] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LNSMSTD_CUSTOMER_ID] [nvarchar](11) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LNSMSTD_LINE_NO] [nvarchar](13) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LNSMSTD_BALANCE] [decimal](15, 2) NULL,
	[LNSMSTD_BEGIN_DATE] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LNSMSTD_MATURITY] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LNSMSTD_ACCRUE_INT] [decimal](15, 2) NULL,
	[LNSMSTD_ACC_CODE_INT_9] [nchar](9) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LNSMSTD_DATA_DATE] [date] NULL,
	[LNSMSTD_EXT_DATE] [date] NULL,
	[BUSINS_CODE] [nvarchar](7) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Create_date] [datetime] NOT NULL
) ON [NCRMS_TAB]';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[OS_LNSMSTD_D_MF] ADD  CONSTRAINT [DF_OS_LNSMSTD_D_MF_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'利息' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'OS_LNSMSTD_D_MF', @level2type=N'COLUMN',@level2name=N'LNSMSTD_ACCRUE_INT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'用來判斷是否為交易利息 ''135850003'',''135850004''  是交易利息 ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'OS_LNSMSTD_D_MF', @level2type=N'COLUMN',@level2name=N'LNSMSTD_ACC_CODE_INT_9'
GO
