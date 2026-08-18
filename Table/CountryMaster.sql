SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CountryMaster](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_Continent] [int] NOT NULL,
	[CountryCode2] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[CountryCode3] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[CountryCode4] [nvarchar](4) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[CountryName_TN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[CountryName_EN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[CountryName_JP] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[CountryName_CN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[HASFCBBRANCH] [bit] NOT NULL,
	[BusinessPoint] [decimal](5, 1) NULL,
	[CDSPoint] [decimal](5, 1) NULL,
	[ISIMFAE] [bit] NOT NULL,
	[WarningUsePercent] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[IsException] [bit] NOT NULL,
	[ExceptionExplain] [nvarchar](255) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[IsFocus] [bit] NOT NULL,
	[FocusExplain] [nvarchar](255) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[CreditRatingScore] [tinyint] NOT NULL,
	[CreditRatingScorePublishedAt] [datetime] NULL,
 CONSTRAINT [PK_CountryMaster] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF),
 CONSTRAINT [IX_CountryMaster_1] UNIQUE NONCLUSTERED
(
	[CountryCode2] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
GO
ALTER TABLE [dbo].[CountryMaster] ADD  CONSTRAINT [DF_CountryMaster_CountryCode2]  DEFAULT ('') FOR [CountryCode2]
GO
ALTER TABLE [dbo].[CountryMaster] ADD  CONSTRAINT [DF_CountryMaster_CountryCode]  DEFAULT ('') FOR [CountryCode3]
GO
ALTER TABLE [dbo].[CountryMaster] ADD  CONSTRAINT [DF_CountryMaster_CountryCode21]  DEFAULT ('') FOR [CountryCode4]
GO
ALTER TABLE [dbo].[CountryMaster] ADD  CONSTRAINT [DF_CountryMaster_CountryName_TN]  DEFAULT ('') FOR [CountryName_TN]
GO
ALTER TABLE [dbo].[CountryMaster] ADD  CONSTRAINT [DF_CountryMaster_CountryName_EN]  DEFAULT ('') FOR [CountryName_EN]
GO
ALTER TABLE [dbo].[CountryMaster] ADD  CONSTRAINT [DF_CountryMaster_CountryName_JP]  DEFAULT ('') FOR [CountryName_JP]
GO
ALTER TABLE [dbo].[CountryMaster] ADD  CONSTRAINT [DF_CountryMaster_CountryName_CN]  DEFAULT ('') FOR [CountryName_CN]
GO
ALTER TABLE [dbo].[CountryMaster] ADD  CONSTRAINT [DF_CountryMaster_HASFCBBRANCH]  DEFAULT ((0)) FOR [HASFCBBRANCH]
GO
ALTER TABLE [dbo].[CountryMaster] ADD  CONSTRAINT [DF_CountryMaster_BusinessRating]  DEFAULT ((9)) FOR [BusinessPoint]
GO
ALTER TABLE [dbo].[CountryMaster] ADD  CONSTRAINT [DF_CountryMaster_CDSPoint]  DEFAULT ((5)) FOR [CDSPoint]
GO
ALTER TABLE [dbo].[CountryMaster] ADD  CONSTRAINT [DF_CountryMaster_WarningUsePercent]  DEFAULT ((80)) FOR [WarningUsePercent]
GO
ALTER TABLE [dbo].[CountryMaster] ADD  CONSTRAINT [DF_CountryMaster_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[CountryMaster] ADD  CONSTRAINT [DF_CountryMaster_IsException]  DEFAULT ((0)) FOR [IsException]
GO
ALTER TABLE [dbo].[CountryMaster] ADD  CONSTRAINT [DF_CountryMaster_ExceptionExplain]  DEFAULT ('') FOR [ExceptionExplain]
GO
ALTER TABLE [dbo].[CountryMaster] ADD  CONSTRAINT [DF_CountryMaster_IsFocus]  DEFAULT ((0)) FOR [IsFocus]
GO
ALTER TABLE [dbo].[CountryMaster] ADD  CONSTRAINT [DF_CountryMaster_FocusExplain]  DEFAULT ('') FOR [FocusExplain]
GO
ALTER TABLE [dbo].[CountryMaster] ADD  CONSTRAINT [DF_CountryMaster_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[CountryMaster] ADD  CONSTRAINT [DF_CountryMaster_Update_user]  DEFAULT ('system') FOR [Update_user]
GO
ALTER TABLE [dbo].[CountryMaster] ADD  CONSTRAINT [DF_CountryMaster_Create_user]  DEFAULT ('system') FOR [Create_user]
GO
ALTER TABLE [dbo].[CountryMaster] ADD  CONSTRAINT [DF_CountryMaster_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[CountryMaster] ADD  CONSTRAINT [DF_CountryMaster_CreditRatingScore]  DEFAULT ((5)) FOR [CreditRatingScore]
GO
ALTER TABLE [dbo].[CountryMaster]  WITH CHECK ADD  CONSTRAINT [FK_CountryMaster_ContinentMaster] FOREIGN KEY([FK_Continent])
REFERENCES [dbo].[ContinentMaster] ([PK_Id])
GO
ALTER TABLE [dbo].[CountryMaster] CHECK CONSTRAINT [FK_CountryMaster_ContinentMaster]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'州別關聯' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryMaster', @level2type=N'COLUMN',@level2name=N'FK_Continent'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ISO 3166-1 alpha-2: TW, US, CN' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryMaster', @level2type=N'COLUMN',@level2name=N'CountryCode2'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ISO 3166-1 alpha-3: TWN, USA, CHN' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryMaster', @level2type=N'COLUMN',@level2name=N'CountryCode3'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'四碼自定義 1001,0000' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryMaster', @level2type=N'COLUMN',@level2name=N'CountryCode4'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'中' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryMaster', @level2type=N'COLUMN',@level2name=N'CountryName_TN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'英' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryMaster', @level2type=N'COLUMN',@level2name=N'CountryName_EN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'日' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryMaster', @level2type=N'COLUMN',@level2name=N'CountryName_JP'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'簡中' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryMaster', @level2type=N'COLUMN',@level2name=N'CountryName_CN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'該國是否有分行' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryMaster', @level2type=N'COLUMN',@level2name=N'HASFCBBRANCH'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'業務策略分數(計算國家評分用' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryMaster', @level2type=N'COLUMN',@level2name=N'BusinessPoint'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'CDS價格及其他因素(計算國家評分用' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryMaster', @level2type=N'COLUMN',@level2name=N'CDSPoint'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'是否是已開發國家' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryMaster', @level2type=N'COLUMN',@level2name=N'ISIMFAE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'警示佔用額度百分比' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryMaster', @level2type=N'COLUMN',@level2name=N'WarningUsePercent'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'啟用' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryMaster', @level2type=N'COLUMN',@level2name=N'IsActive'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'是否例外國家' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryMaster', @level2type=N'COLUMN',@level2name=N'IsException'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'說明' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryMaster', @level2type=N'COLUMN',@level2name=N'ExceptionExplain'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'是否近期關注' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryMaster', @level2type=N'COLUMN',@level2name=N'IsFocus'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'近期關注說明' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryMaster', @level2type=N'COLUMN',@level2name=N'FocusExplain'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'更新時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryMaster', @level2type=N'COLUMN',@level2name=N'Update_date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'更新者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryMaster', @level2type=N'COLUMN',@level2name=N'Update_user'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'創建者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryMaster', @level2type=N'COLUMN',@level2name=N'Create_user'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'創建時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryMaster', @level2type=N'COLUMN',@level2name=N'Create_date'
GO
