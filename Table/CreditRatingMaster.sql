SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CreditRatingMaster](
	[PK_ID] [int] IDENTITY(1,1) NOT NULL,
	[AgencyCode] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[AgencyName] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK__RatingMa__F4A24BC2B3AEF876] PRIMARY KEY CLUSTERED
(
	[PK_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
GO
ALTER TABLE [dbo].[CreditRatingMaster] ADD  CONSTRAINT [DF_RatingAgencyMaster_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[CreditRatingMaster] ADD  CONSTRAINT [DF_RatingAgencyMaster_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
