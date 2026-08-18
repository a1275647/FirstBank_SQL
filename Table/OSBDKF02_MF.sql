SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OSBDKF02_MF](
	[OSBDKF02_BRANCH_NO] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[OSBDKF02_TRAN_NO] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[OSBDKF02_TX_DATE] [date] NULL,
	[OSBDKF02_SWIFT_ID] [nvarchar](11) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[OSBDKF02_CUST_NAME1] [nvarchar](40) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[OSBDKF02_DOWN_DATE] [date] NULL,
	[OSBDKF02_MATURITY_DATE] [date] NULL,
	[OSBDKF02_CURENCY_COD] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[OSBDKF02_BALANCE_AMT] [decimal](17, 2) NULL,
	[OSBDKF02_BOND_PRICE] [decimal](17, 2) NULL,
	[OSBDKF02_LINE_PERMIT_NO] [nvarchar](13) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[OSBDKF02_ISSUER_COUNTRY] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[OSBDKF02_AC_9] [nvarchar](9) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[OSBDKF02_PRICE] [decimal](11, 5) NULL,
	[OSBDKF02_EXT_DATE] [date] NULL,
	[BUSINS_CODE] [nvarchar](7) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Create_date] [datetime] NOT NULL
)
GO
ALTER TABLE [dbo].[OSBDKF02_MF] ADD  CONSTRAINT [DF_OSBDKF02_MF_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'交易金額新的' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'OSBDKF02_MF', @level2type=N'COLUMN',@level2name=N'OSBDKF02_BALANCE_AMT'
GO
