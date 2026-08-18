SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FinancialRiskFactorPeriodDay](
	[PK_ID] [int] IDENTITY(1,1) NOT NULL,
	[PeriodName] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[MinDays] [int] NOT NULL,
	[MaxDays] [int] NULL,
	[SEQ] [int] NOT NULL,
	[IsActive] [bit] NULL,
	[Create_Date] [datetime] NOT NULL,
	[Create_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Update_Date] [datetime] NOT NULL,
	[Update_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
 CONSTRAINT [PK__Financia__F4A24BC22B9435D7] PRIMARY KEY CLUSTERED
(
	[PK_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
GO
ALTER TABLE [dbo].[FinancialRiskFactorPeriodDay] ADD  CONSTRAINT [DF_FinancialRiskFactorPeriodDay_Create_Date]  DEFAULT (getdate()) FOR [Create_Date]
GO
ALTER TABLE [dbo].[FinancialRiskFactorPeriodDay] ADD  CONSTRAINT [DF_FinancialRiskFactorPeriodDay_Update_Date]  DEFAULT (getdate()) FOR [Update_Date]
GO
