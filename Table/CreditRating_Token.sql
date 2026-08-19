SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CreditRating_Token](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[Token] [nvarchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Type] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
 CONSTRAINT [PK_CreditRatingsToken] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
GO
ALTER TABLE [dbo].[CreditRating_Token] ADD  CONSTRAINT [DF_CreditRatingsToken_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
