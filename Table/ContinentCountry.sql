SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ContinentCountry](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[ContinentId] [int] NOT NULL,
	[CountryId] [int] NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_ContinentCountry] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
GO
CREATE NONCLUSTERED INDEX [IX_ContinentCountry] ON [dbo].[ContinentCountry]
(
	[ContinentId] ASC,
	[CountryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
GO
ALTER TABLE [dbo].[ContinentCountry] ADD  CONSTRAINT [DF_CONTINENTCOUNTRY_CONTINENTCODE]  DEFAULT ('') FOR [ContinentId]
GO
ALTER TABLE [dbo].[ContinentCountry] ADD  CONSTRAINT [DF_CONTINENTCOUNTRY_CountryCode2]  DEFAULT ('') FOR [CountryId]
GO
ALTER TABLE [dbo].[ContinentCountry] ADD  CONSTRAINT [DF_ContinentCountry_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[ContinentCountry] ADD  CONSTRAINT [DF_CONTINENTCOUNTRY_Create_user]  DEFAULT ('') FOR [Create_user]
GO
ALTER TABLE [dbo].[ContinentCountry]  WITH CHECK ADD  CONSTRAINT [FK_ContinentCountry_ContinentMaster] FOREIGN KEY([ContinentId])
REFERENCES [dbo].[ContinentMaster] ([PK_Id])
GO
ALTER TABLE [dbo].[ContinentCountry] CHECK CONSTRAINT [FK_ContinentCountry_ContinentMaster]
GO
ALTER TABLE [dbo].[ContinentCountry]  WITH CHECK ADD  CONSTRAINT [FK_ContinentCountry_CountryMaster] FOREIGN KEY([CountryId])
REFERENCES [dbo].[CountryMaster] ([PK_Id])
GO
ALTER TABLE [dbo].[ContinentCountry] CHECK CONSTRAINT [FK_ContinentCountry_CountryMaster]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'特殊區域代碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ContinentCountry', @level2type=N'COLUMN',@level2name=N'ContinentId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'國家代碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ContinentCountry', @level2type=N'COLUMN',@level2name=N'CountryId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建置時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ContinentCountry', @level2type=N'COLUMN',@level2name=N'Create_date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建置者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ContinentCountry', @level2type=N'COLUMN',@level2name=N'Create_user'
GO
