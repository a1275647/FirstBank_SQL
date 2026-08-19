SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CreditRating_Country](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_Country_Id] [int] NOT NULL,
	[FK_RatingAgency_Id] [int] NOT NULL,
	[AgencyRating] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[RatingDate] [datetime] NULL,
	[RatingOutlook] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[RatingOutlookDate] [datetime] NULL,
	[Remarks] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[date] [date] NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK__CountryCreditRating_his] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB],
 CONSTRAINT [IX_CreditRating_Country_Week] UNIQUE NONCLUSTERED
(
	[date] ASC,
	[FK_Country_Id] ASC,
	[FK_RatingAgency_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
) ON [NCRMS_TAB]
GO
CREATE NONCLUSTERED INDEX [IX_CreditRating_Country_Lookup] ON [dbo].[CreditRating_Country]
(
	[FK_Country_Id] ASC,
	[FK_RatingAgency_Id] ASC,
	[date] ASC
)
INCLUDE([AgencyRating],[RatingOutlook],[RatingOutlookDate],[RatingDate],[Create_date]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
GO
ALTER TABLE [dbo].[CreditRating_Country] ADD  CONSTRAINT [DF_CountryCreditRating_his_AgencyRating]  DEFAULT ('') FOR [AgencyRating]
GO
ALTER TABLE [dbo].[CreditRating_Country] ADD  CONSTRAINT [DF_CountryCreditRating_his_RatingOutlook]  DEFAULT ('') FOR [RatingOutlook]
GO
ALTER TABLE [dbo].[CreditRating_Country] ADD  CONSTRAINT [DF_CountryCreditRating_his_Remarks]  DEFAULT ('') FOR [Remarks]
GO
ALTER TABLE [dbo].[CreditRating_Country] ADD  CONSTRAINT [DF_CreditRating_Country_Week_date]  DEFAULT (getdate()) FOR [date]
GO
ALTER TABLE [dbo].[CreditRating_Country] ADD  CONSTRAINT [DF_CountryCreditRating_his_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[CreditRating_Country] ADD  CONSTRAINT [DF_CountryCreditRating_his_Create_user]  DEFAULT ('system') FOR [Create_user]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'國家ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CreditRating_Country', @level2type=N'COLUMN',@level2name=N'FK_Country_Id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'信評公司ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CreditRating_Country', @level2type=N'COLUMN',@level2name=N'FK_RatingAgency_Id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'信評評分' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CreditRating_Country', @level2type=N'COLUMN',@level2name=N'AgencyRating'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'評級時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CreditRating_Country', @level2type=N'COLUMN',@level2name=N'RatingDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'未來展望' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CreditRating_Country', @level2type=N'COLUMN',@level2name=N'RatingOutlook'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'未來展望時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CreditRating_Country', @level2type=N'COLUMN',@level2name=N'RatingOutlookDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'備註' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CreditRating_Country', @level2type=N'COLUMN',@level2name=N'Remarks'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建置時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CreditRating_Country', @level2type=N'COLUMN',@level2name=N'Create_date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建置者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CreditRating_Country', @level2type=N'COLUMN',@level2name=N'Create_user'
GO
