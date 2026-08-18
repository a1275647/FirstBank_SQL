SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CreditRating_LEI](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[CustomerId] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[MoodyLong] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[MoodyShort] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SpLong] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SpShort] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[TrcLong] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[TrcShort] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[FitchLong] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[FitchShort] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[FitchTwLong] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[FitchTwShort] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Create_date] [datetime] NOT NULL,
 CONSTRAINT [PK_CreditRating_LEI] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
GO
ALTER TABLE [dbo].[CreditRating_LEI] ADD  CONSTRAINT [DF_CreditRating_LEI_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
