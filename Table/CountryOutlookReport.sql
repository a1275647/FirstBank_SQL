SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CountryOutlookReport](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_CountryId] [int] NOT NULL,
	[Gdp] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Population] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[IndustryDistribution] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[MainExportCountry] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[MainExportProducts] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[EconomicGrowthContent] [nvarchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SolvencyContent] [nvarchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[FinancialSituationContent] [nvarchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CountryRatingContent] [nvarchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[DataSource] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[ReportSource] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LastYearCDS] [decimal](18, 2) NULL,
	[LastMonthCDS] [decimal](18, 2) NULL,
	[LastWeekCDS] [decimal](18, 2) NULL,
	[LastDayCDS] [decimal](18, 2) NULL,
	[LastDayCDS_date] [date] NULL,
	[IsActive] [bit] NOT NULL,
	[Release_date] [date] NOT NULL,
	[Update_user] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[LastYearHighCDS] [decimal](18, 2) NULL,
	[LastYearHighCDS_date] [date] NULL,
	[LastYearLowCDS] [decimal](18, 2) NULL,
	[LastYearLowCDS_date] [date] NULL,
	[LastYearAvgCDS] [decimal](18, 2) NULL,
	[FK_FileId] [int] NULL,
	[GdpGrowth] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
 CONSTRAINT [PK_CountryOutlookReport] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
GO
ALTER TABLE [dbo].[CountryOutlookReport] ADD  CONSTRAINT [DF_CountryOutlookReport_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[CountryOutlookReport] ADD  CONSTRAINT [DF_CountryOutlookReport_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[CountryOutlookReport] ADD  CONSTRAINT [DF_CountryOutlookReport_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
