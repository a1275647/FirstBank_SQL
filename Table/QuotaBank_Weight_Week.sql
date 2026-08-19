SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[QuotaBank_Weight_Week](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[QuotaDate] [date] NULL,
	[Year] [int] NOT NULL,
	[Month] [int] NOT NULL,
	[Week] [int] NOT NULL,
	[QuotaBankDetailId] [int] NOT NULL,
	[CountryId] [int] NOT NULL,
	[UnitCode] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[CountryWeightId] [int] NOT NULL,
	[QuotaAmount] [int] NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
 CONSTRAINT [PK_QuotaBank_Weight_Week] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_QuotaBank_Weight_Week] ON [dbo].[QuotaBank_Weight_Week]
(
	[Year] ASC,
	[Month] ASC,
	[Week] ASC,
	[UnitCode] ASC,
	[CountryWeightId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
GO
ALTER TABLE [dbo].[QuotaBank_Weight_Week] ADD  CONSTRAINT [DF_QuotaBank_Weight_Week_QuotaBankDetailId]  DEFAULT ((1)) FOR [QuotaBankDetailId]
GO
ALTER TABLE [dbo].[QuotaBank_Weight_Week] ADD  CONSTRAINT [DF_QuotaBank_Weight_Week_CountryId]  DEFAULT ((0)) FOR [CountryId]
GO
ALTER TABLE [dbo].[QuotaBank_Weight_Week] ADD  CONSTRAINT [DF_QuotaBank_Weight_Week_UnitCode]  DEFAULT ('') FOR [UnitCode]
GO
