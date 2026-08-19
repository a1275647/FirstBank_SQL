SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CountryOutlookReport_temp](
	[TempId] [int] IDENTITY(1,1) NOT NULL,
	[FlowFormId] [int] NULL,
	[ModifyType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[PK_Id] [int] NOT NULL,
	[FK_CountryId] [int] NOT NULL,
	[Gdp] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Population] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[IndustryDistribution] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[MainExportCountry] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[MainExportProducts] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[EconomicGrowthContent] [nvarchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SolvencyContent] [nvarchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[FinancialSituationContent] [nvarchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CountryRatingContent] [nvarchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[DataSource] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[ReportSource] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LastYearCDS] [decimal](18, 2) NULL,
	[LastMonthCDS] [decimal](18, 2) NULL,
	[LastWeekCDS] [decimal](18, 2) NULL,
	[LastDayCDS] [decimal](18, 2) NULL,
	[LastDayCDS_date] [date] NULL,
	[IsActive] [bit] NOT NULL,
	[Release_date] [date] NOT NULL,
	[Update_user] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[LastYearHighCDS] [decimal](18, 2) NULL,
	[LastYearHighCDS_date] [date] NULL,
	[LastYearLowCDS] [decimal](18, 2) NULL,
	[LastYearLowCDS_date] [date] NULL,
	[LastYearAvgCDS] [decimal](18, 2) NULL,
	[GdpGrowth] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
 CONSTRAINT [PK__CountryO__06C703C14759D8AC] PRIMARY KEY CLUSTERED
(
	[TempId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
GO
ALTER TABLE [dbo].[CountryOutlookReport_temp] ADD  CONSTRAINT [DF__CountryOu__IsAct__6068FB9B]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[CountryOutlookReport_temp] ADD  CONSTRAINT [DF__CountryOu__Updat__615D1FD4]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[CountryOutlookReport_temp] ADD  CONSTRAINT [DF__CountryOu__Creat__6251440D]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[CountryOutlookReport_temp] ADD  CONSTRAINT [DF__CountryOu__SysCr__63456846]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
ALTER TABLE [dbo].[CountryOutlookReport_temp]  WITH CHECK ADD  CONSTRAINT [FK_CountryOutlookReport_temp_FlowForm] FOREIGN KEY([FlowFormId])
REFERENCES [dbo].[FlowForm] ([PK_Id])
GO
ALTER TABLE [dbo].[CountryOutlookReport_temp] CHECK CONSTRAINT [FK_CountryOutlookReport_temp_FlowForm]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'暫存資料識別碼（流水號）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryOutlookReport_temp', @level2type=N'COLUMN',@level2name=N'TempId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'流程表單識別碼（外鍵：FlowForm.PK_ID）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryOutlookReport_temp', @level2type=N'COLUMN',@level2name=N'FlowFormId'
GO
