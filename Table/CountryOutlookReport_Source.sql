SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CountryOutlookReport_Source](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_CountryId] [int] NOT NULL,
	[IndustryDistribution] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[MainExportProducts] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[MainExportCountry] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[DataSource] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[EconomicGrowthContent] [nvarchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SolvencyContent] [nvarchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[FinancialSituationContent] [nvarchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CountryRatingContent] [nvarchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[ReportSource] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Create_date] [datetime] NOT NULL,
 CONSTRAINT [PK_CountryOutlookReport_Source] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
GO
ALTER TABLE [dbo].[CountryOutlookReport_Source] ADD  CONSTRAINT [DF_CountryOutlookReport_Source_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
