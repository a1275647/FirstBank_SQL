SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RatingRatioMaster](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[Year] [int] NOT NULL,
	[RatingLevel] [int] NOT NULL,
	[RiskRatio] [int] NOT NULL,
	[HasFCBBranch] [bit] NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK__RatingMu__F4A24B2232D6980E] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
GO
CREATE NONCLUSTERED INDEX [IX_RatingRatioMaster] ON [dbo].[RatingRatioMaster]
(
	[Year] ASC,
	[RatingLevel] ASC,
	[HasFCBBranch] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
ALTER TABLE [dbo].[RatingRatioMaster] ADD  CONSTRAINT [DF_RatingRatioMaster_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[RatingRatioMaster] ADD  CONSTRAINT [DF_RatingRatioMaster_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
