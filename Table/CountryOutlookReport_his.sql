SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[CountryOutlookReport_his](
	[Log_id] [int] IDENTITY(1,1) NOT NULL,
	[LogType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[FlowFormId] [int] NULL,
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
 CONSTRAINT [PK__CountryO__2D21E3B62FDE61CC] PRIMARY KEY CLUSTERED
(
	[Log_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[CountryOutlookReport_his] ADD  CONSTRAINT [DF__CountryOu__IsAct__6715F92A]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[CountryOutlookReport_his] ADD  CONSTRAINT [DF__CountryOu__Updat__680A1D63]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[CountryOutlookReport_his] ADD  CONSTRAINT [DF__CountryOu__Creat__68FE419C]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[CountryOutlookReport_his] ADD  CONSTRAINT [DF__CountryOu__SysCr__69F265D5]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
ALTER TABLE [dbo].[CountryOutlookReport_his]  WITH CHECK ADD  CONSTRAINT [FK_CountryOutlookReport_his_FlowForm] FOREIGN KEY([FlowFormId])
REFERENCES [dbo].[FlowForm] ([PK_Id])
GO
ALTER TABLE [dbo].[CountryOutlookReport_his] CHECK CONSTRAINT [FK_CountryOutlookReport_his_FlowForm]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'歷史記錄識別碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryOutlookReport_his', @level2type=N'COLUMN',@level2name=N'Log_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'異動行為類型 (INSERT/UPDATE/DELETE)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryOutlookReport_his', @level2type=N'COLUMN',@level2name=N'LogType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'流程表單識別碼（外鍵：FlowForm.PK_ID）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryOutlookReport_his', @level2type=N'COLUMN',@level2name=N'FlowFormId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立日期時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryOutlookReport_his', @level2type=N'COLUMN',@level2name=N'SysCreateDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立使用者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryOutlookReport_his', @level2type=N'COLUMN',@level2name=N'SysCreateUser'
GO
