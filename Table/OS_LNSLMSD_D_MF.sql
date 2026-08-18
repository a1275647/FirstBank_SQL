SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OS_LNSLMSD_D_MF](
	[LNSLMSD_BRANCH_NO] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LNSLMSD_LINE_NO] [nvarchar](13) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LNSLMSD_LINE_TYPE] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LNSLMSD_CIRCLE] [nvarchar](1) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LNSLMSD_CURRENCY] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LNSLMSD_APP_AMT] [decimal](17, 2) NULL,
	[LNSLMSD_CUSTOMER_ID] [nvarchar](11) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LNSLMSD_CUSTOMER_NAME] [nvarchar](36) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LNSLMSD_BGN_DATE] [date] NULL,
	[LNSLMSD_MATURITY] [date] NULL,
	[LNSLMSD_REG_COUNTRY] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LNSLMSD_APP_NO] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LNSLMSD_DATA_DATE] [date] NULL,
	[LNSLMSD_COUNTRY_RISK] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LNSLMSD_EXT_DATE] [date] NULL,
	[BUSINS_CODE] [nvarchar](7) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Create_date] [datetime] NOT NULL
)
GO
ALTER TABLE [dbo].[OS_LNSLMSD_D_MF] ADD  CONSTRAINT [DF_OS_LNSLMSD_D_MF_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
