SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[FinancialRiskFactorPeriodDay_temp](
	[TempId] [int] IDENTITY(1,1) NOT NULL,
	[FK_TempId] [int] NOT NULL,
	[ModifyType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[PK_ID] [int] NULL,
	[PeriodName] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[MinDays] [int] NULL,
	[MaxDays] [int] NULL,
	[SEQ] [int] NULL,
	[IsActive] [bit] NULL,
	[Create_date] [datetime] NULL,
	[Create_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Update_date] [datetime] NULL,
	[Update_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK__Financia__06C703C1D1A2D7A9] PRIMARY KEY CLUSTERED
(
	[TempId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[FinancialRiskFactorPeriodDay_temp] ADD  CONSTRAINT [DF__Financial__Creat__3FE65219]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[FinancialRiskFactorPeriodDay_temp] ADD  CONSTRAINT [DF__Financial__Updat__40DA7652]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[FinancialRiskFactorPeriodDay_temp] ADD  CONSTRAINT [DF__Financial__SysCr__41CE9A8B]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'暫存資料識別碼（流水號）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FinancialRiskFactorPeriodDay_temp', @level2type=N'COLUMN',@level2name=N'TempId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'主表暫存資料外鍵' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FinancialRiskFactorPeriodDay_temp', @level2type=N'COLUMN',@level2name=N'FK_TempId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'異動類型' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FinancialRiskFactorPeriodDay_temp', @level2type=N'COLUMN',@level2name=N'ModifyType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立日期時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FinancialRiskFactorPeriodDay_temp', @level2type=N'COLUMN',@level2name=N'SysCreateDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立使用者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FinancialRiskFactorPeriodDay_temp', @level2type=N'COLUMN',@level2name=N'SysCreateUser'
GO
