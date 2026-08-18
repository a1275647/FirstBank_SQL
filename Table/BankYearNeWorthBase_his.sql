SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BankYearNeWorthBase_his](
	[Log_id] [int] IDENTITY(1,1) NOT NULL,
	[LogType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[FlowFormId] [int] NULL,
	[PK_Id] [int] NOT NULL,
	[Year] [int] NOT NULL,
	[NTDToUSDEXRate] [decimal](18, 4) NOT NULL,
	[NetWorthNTD] [decimal](18, 2) NOT NULL,
	[NetWorthUSD] [decimal](18, 2) NOT NULL,
	[TotalRiskRatio] [int] NOT NULL,
	[TotalNetWorthNTD] [decimal](18, 2) NOT NULL,
	[TotalNetWorthUSD] [decimal](18, 2) NOT NULL,
	[WarningPercent] [int] NOT NULL,
	[WarningAmountNTD] [decimal](18, 2) NOT NULL,
	[WarningAmountUSD] [decimal](18, 2) NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK__BankYear__2D21E3B6DFB7F344] PRIMARY KEY CLUSTERED
(
	[Log_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
GO
ALTER TABLE [dbo].[BankYearNeWorthBase_his] ADD  CONSTRAINT [DF__BankYearNe__Year__2B754518]  DEFAULT (datepart(year,getdate())) FOR [Year]
GO
ALTER TABLE [dbo].[BankYearNeWorthBase_his] ADD  CONSTRAINT [DF__BankYearN__NTDTo__2C696951]  DEFAULT ((0)) FOR [NTDToUSDEXRate]
GO
ALTER TABLE [dbo].[BankYearNeWorthBase_his] ADD  CONSTRAINT [DF__BankYearN__Creat__2D5D8D8A]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[BankYearNeWorthBase_his] ADD  CONSTRAINT [DF__BankYearN__Creat__2E51B1C3]  DEFAULT ('') FOR [Create_user]
GO
ALTER TABLE [dbo].[BankYearNeWorthBase_his] ADD  CONSTRAINT [DF__BankYearN__Updat__2F45D5FC]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[BankYearNeWorthBase_his] ADD  CONSTRAINT [DF__BankYearN__Updat__3039FA35]  DEFAULT ('') FOR [Update_user]
GO
ALTER TABLE [dbo].[BankYearNeWorthBase_his] ADD  CONSTRAINT [DF__BankYearN__SysCr__312E1E6E]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
ALTER TABLE [dbo].[BankYearNeWorthBase_his]  WITH CHECK ADD  CONSTRAINT [FK_BankYearNeWorthBase_his_FlowForm] FOREIGN KEY([FlowFormId])
REFERENCES [dbo].[FlowForm] ([PK_Id])
GO
ALTER TABLE [dbo].[BankYearNeWorthBase_his] CHECK CONSTRAINT [FK_BankYearNeWorthBase_his_FlowForm]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'歷史記錄識別碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankYearNeWorthBase_his', @level2type=N'COLUMN',@level2name=N'Log_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'異動行為類型 (INSERT/UPDATE/DELETE)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankYearNeWorthBase_his', @level2type=N'COLUMN',@level2name=N'LogType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'流程表單識別碼（外鍵：FlowForm.PK_ID）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankYearNeWorthBase_his', @level2type=N'COLUMN',@level2name=N'FlowFormId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立日期時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankYearNeWorthBase_his', @level2type=N'COLUMN',@level2name=N'SysCreateDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立使用者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankYearNeWorthBase_his', @level2type=N'COLUMN',@level2name=N'SysCreateUser'
GO
