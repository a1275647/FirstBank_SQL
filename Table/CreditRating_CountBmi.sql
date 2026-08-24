SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[CreditRating_CountBmi](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_Country_Id] [int] NULL,
	[CountryName] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CountryRating] [int] NULL,
	[TitleCountryRating] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[NominalGDP_Score] [float] NULL,
	[NominalGDP] [float] NULL,
	[RealGDPGrowthIMFAE_Score] [float] NULL,
	[RealGDPGrowthIMFAE] [float] NULL,
	[RealGDPGrowth_Score] [float] NULL,
	[RealGDPGrowth] [float] NULL,
	[ConsumerPriceIMFAE_Score] [float] NULL,
	[ConsumerPriceIMFAE] [float] NULL,
	[ConsumerPrice_Score] [float] NULL,
	[ConsumerPrice] [float] NULL,
	[Unemployment_Score] [float] NULL,
	[Unemployment] [float] NULL,
	[ImportCoverMonths_Score] [float] NULL,
	[ImportCoverMonths] [float] NULL,
	[TotalExternalDebtStock_Score] [float] NULL,
	[TotalExternalDebtStock] [float] NULL,
	[ShortTermExternalDebt_Score] [float] NULL,
	[ShortTermExternalDebt] [float] NULL,
	[BudgetBalance_Score] [float] NULL,
	[BudgetBalance] [float] NULL,
	[TotalGovernmentDebt_Score] [float] NULL,
	[TotalGovernmentDebt] [float] NULL,
	[PoliticalRisk_Score] [int] NULL,
	[PoliticalRisk] [float] NULL,
	[SecurityRisk_Score] [int] NULL,
	[SecurityRisk] [float] NULL,
	[BusinessStrategy_Explain] [nvarchar](500) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[BusinessStrategy] [decimal](5, 1) NULL,
	[CreditRating_Explain] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CreditRating] [int] NULL,
	[Outlook_Explain] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Outlook] [int] NULL,
	[Other_Explain] [nvarchar](500) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Other] [decimal](5, 1) NULL,
	[End_Explain] [nvarchar](500) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[AssessmentDay] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
 CONSTRAINT [PK_TotalCountryRating] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
