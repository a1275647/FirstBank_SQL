SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RatingRatioMasterBase](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[RatingLevel] [int] NOT NULL,
	[RatingLevelName] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[RiskRatio] [int] NOT NULL,
	[HasFCBBranch] [bit] NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_RatingRatioMasterBase__F4A24B2232D6980E] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
GO
ALTER TABLE [dbo].[RatingRatioMasterBase] ADD  CONSTRAINT [DF_RatingRatioMasterBase_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[RatingRatioMasterBase] ADD  CONSTRAINT [DF_RatingRatioMasterBase_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
