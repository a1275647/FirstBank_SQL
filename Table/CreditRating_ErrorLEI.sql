SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CreditRating_ErrorLEI](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[Type] [int] NOT NULL,
	[FK_RatingAgency_Id] [int] NOT NULL,
	[Value] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[ErrorMessage] [nvarchar](1000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Create_date] [datetime] NOT NULL,
	[Count] [int] NOT NULL,
 CONSTRAINT [PK_CreditRating_ErrorLEI] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
GO
ALTER TABLE [dbo].[CreditRating_ErrorLEI] ADD  CONSTRAINT [DF_CreditRating_ErrorLEI_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[CreditRating_ErrorLEI] ADD  CONSTRAINT [DF_CreditRating_ErrorLEI_Count]  DEFAULT ((0)) FOR [Count]
GO
ALTER TABLE [dbo].[CreditRating_ErrorLEI]  WITH CHECK ADD  CONSTRAINT [FK_CreditRating_ErrorLEI_Global] FOREIGN KEY([Type])
REFERENCES [dbo].[Global] ([Id])
GO
ALTER TABLE [dbo].[CreditRating_ErrorLEI] CHECK CONSTRAINT [FK_CreditRating_ErrorLEI_Global]
GO
ALTER TABLE [dbo].[CreditRating_ErrorLEI]  WITH CHECK ADD  CONSTRAINT [FK_CreditRating_ErrorLEI_RatingAgency] FOREIGN KEY([FK_RatingAgency_Id])
REFERENCES [dbo].[CreditRatingMaster] ([PK_ID])
GO
ALTER TABLE [dbo].[CreditRating_ErrorLEI] CHECK CONSTRAINT [FK_CreditRating_ErrorLEI_RatingAgency]
GO
