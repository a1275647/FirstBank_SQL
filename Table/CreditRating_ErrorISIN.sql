SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CreditRating_ErrorISIN](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[Type] [int] NOT NULL,
	[FK_RatingAgency_Id] [int] NOT NULL,
	[Value] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[ErrorMessage] [nvarchar](1000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Create_date] [datetime] NOT NULL,
	[Count] [int] NOT NULL,
 CONSTRAINT [PK_CreditRating_ErrorISIN] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
GO
ALTER TABLE [dbo].[CreditRating_ErrorISIN] ADD  CONSTRAINT [DF_CreditRating_ErrorISIN_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[CreditRating_ErrorISIN] ADD  CONSTRAINT [DF_CreditRating_ErrorISIN_Count]  DEFAULT ((0)) FOR [Count]
GO
ALTER TABLE [dbo].[CreditRating_ErrorISIN]  WITH CHECK ADD  CONSTRAINT [FK_CreditRating_ErrorISIN_Global] FOREIGN KEY([Type])
REFERENCES [dbo].[Global] ([Id])
GO
ALTER TABLE [dbo].[CreditRating_ErrorISIN] CHECK CONSTRAINT [FK_CreditRating_ErrorISIN_Global]
GO
ALTER TABLE [dbo].[CreditRating_ErrorISIN]  WITH CHECK ADD  CONSTRAINT [FK_CreditRating_ErrorISIN_RatingAgency] FOREIGN KEY([FK_RatingAgency_Id])
REFERENCES [dbo].[CreditRatingMaster] ([PK_ID])
GO
ALTER TABLE [dbo].[CreditRating_ErrorISIN] CHECK CONSTRAINT [FK_CreditRating_ErrorISIN_RatingAgency]
GO
