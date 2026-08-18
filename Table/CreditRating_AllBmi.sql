SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CreditRating_AllBmi](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[Year] [int] NOT NULL,
	[FK_Country_Id] [int] NOT NULL,
	[FK_CategoriesId] [int] NOT NULL,
	[Score] [float] NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_BMICountryRisk_temp] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
GO
CREATE NONCLUSTERED INDEX [IX_CreditRating_AllBmi_Country_Year_Category] ON [dbo].[CreditRating_AllBmi]
(
	[FK_Country_Id] ASC,
	[Year] ASC,
	[FK_CategoriesId] ASC
)
INCLUDE([Score]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
ALTER TABLE [dbo].[CreditRating_AllBmi] ADD  CONSTRAINT [DF_BMICountryRisk_temp_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
