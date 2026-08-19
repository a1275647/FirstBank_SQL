SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CreditRating_CountryId](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_AgencyCode_Id] [int] NOT NULL,
	[FK_Country_Id] [int] NOT NULL,
	[EntityId] [int] NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_CountryCreditIdList] PRIMARY KEY CLUSTERED
(
	[FK_AgencyCode_Id] ASC,
	[FK_Country_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
GO
CREATE NONCLUSTERED INDEX [IX_CreditRating_CountryId_Agency_Country] ON [dbo].[CreditRating_CountryId]
(
	[FK_AgencyCode_Id] ASC,
	[FK_Country_Id] ASC
)
INCLUDE([EntityId]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
GO
ALTER TABLE [dbo].[CreditRating_CountryId] ADD  CONSTRAINT [DF_CountryCreditIdList_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[CreditRating_CountryId] ADD  CONSTRAINT [DF_CountryCreditIdList_Create_user]  DEFAULT ('') FOR [Create_user]
GO
ALTER TABLE [dbo].[CreditRating_CountryId] ADD  CONSTRAINT [DF_CountryCreditIdList_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[CreditRating_CountryId] ADD  CONSTRAINT [DF_CountryCreditIdList_Update_user]  DEFAULT ('') FOR [Update_user]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'信評公司ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CreditRating_CountryId', @level2type=N'COLUMN',@level2name=N'FK_AgencyCode_Id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'國家代碼ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CreditRating_CountryId', @level2type=N'COLUMN',@level2name=N'FK_Country_Id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'各家信評公司國家ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CreditRating_CountryId', @level2type=N'COLUMN',@level2name=N'EntityId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建置時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CreditRating_CountryId', @level2type=N'COLUMN',@level2name=N'Create_date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建置者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CreditRating_CountryId', @level2type=N'COLUMN',@level2name=N'Create_user'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'更新時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CreditRating_CountryId', @level2type=N'COLUMN',@level2name=N'Update_date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'更新者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CreditRating_CountryId', @level2type=N'COLUMN',@level2name=N'Update_user'
GO
