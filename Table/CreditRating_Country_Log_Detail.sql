SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CreditRating_Country_Log_Detail](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_Country_Id] [int] NOT NULL,
	[FK_RatingAgency_Id] [int] NOT NULL,
	[AgencyRating] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[RatingDate] [datetime] NULL,
	[RatingOutlook] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[RatingOutlookDate] [datetime] NULL,
	[Remarks] [nvarchar](500) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[BusinessDate] [date] NOT NULL,
 CONSTRAINT [PK_CreditRating_Country_Log_Detail] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF),
 CONSTRAINT [UQ_CreditRating_Country_Log_Detail_Country_Agency_BusinessDate] UNIQUE NONCLUSTERED
(
	[FK_Country_Id] ASC,
	[FK_RatingAgency_Id] ASC,
	[BusinessDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
GO
ALTER TABLE [dbo].[CreditRating_Country_Log_Detail]  WITH CHECK ADD  CONSTRAINT [FK_CreditRating_Country_Log_Detail_CountryMaster] FOREIGN KEY([FK_Country_Id])
REFERENCES [dbo].[CountryMaster] ([PK_Id])
GO
ALTER TABLE [dbo].[CreditRating_Country_Log_Detail] CHECK CONSTRAINT [FK_CreditRating_Country_Log_Detail_CountryMaster]
GO
ALTER TABLE [dbo].[CreditRating_Country_Log_Detail]  WITH CHECK ADD  CONSTRAINT [FK_CreditRating_Country_Log_Detail_CreditRatingMaster] FOREIGN KEY([FK_RatingAgency_Id])
REFERENCES [dbo].[CreditRatingMaster] ([PK_ID])
GO
ALTER TABLE [dbo].[CreditRating_Country_Log_Detail] CHECK CONSTRAINT [FK_CreditRating_Country_Log_Detail_CreditRatingMaster]
GO
