SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FinancialRiskFactorData](
	[PK_ID] [int] IDENTITY(1,1) NOT NULL,
	[FK_ProductID] [int] NOT NULL,
	[FK_PeriodID] [int] NOT NULL,
	[RiskFactor] [decimal](10, 2) NULL,
	[Version] [int] NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
 CONSTRAINT [PK__Financia__F4A24BC24E8BFDB1] PRIMARY KEY CLUSTERED
(
	[PK_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
GO
ALTER TABLE [dbo].[FinancialRiskFactorData] ADD  CONSTRAINT [DF_FinancialRiskFactorData_Create_Date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[FinancialRiskFactorData] ADD  CONSTRAINT [DF_FinancialRiskFactorData_Update_Date]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[FinancialRiskFactorData]  WITH CHECK ADD  CONSTRAINT [FK_FinancialRiskFactorData_PeriodID_FinancialRiskFactorPeriodDay_PKID] FOREIGN KEY([FK_PeriodID])
REFERENCES [dbo].[FinancialRiskFactorPeriodDay] ([PK_ID])
GO
ALTER TABLE [dbo].[FinancialRiskFactorData] CHECK CONSTRAINT [FK_FinancialRiskFactorData_PeriodID_FinancialRiskFactorPeriodDay_PKID]
GO
ALTER TABLE [dbo].[FinancialRiskFactorData]  WITH CHECK ADD  CONSTRAINT [FK_FinancialRiskFactorData_ProductID_FinancialProductMaster_PKID] FOREIGN KEY([FK_ProductID])
REFERENCES [dbo].[FinancialProductMaster] ([PK_ID])
GO
ALTER TABLE [dbo].[FinancialRiskFactorData] CHECK CONSTRAINT [FK_FinancialRiskFactorData_ProductID_FinancialProductMaster_PKID]
GO
