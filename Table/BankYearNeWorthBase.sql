SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BankYearNeWorthBase](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
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
 CONSTRAINT [PK__BankYear__F4A24B22679E0D0C] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF),
 CONSTRAINT [UQ__BankYear__D4BD60544D11DEBB] UNIQUE NONCLUSTERED
(
	[Year] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
GO
ALTER TABLE [dbo].[BankYearNeWorthBase] ADD  CONSTRAINT [DF_BankYearNeWorthBase_Year]  DEFAULT (datepart(year,getdate())) FOR [Year]
GO
ALTER TABLE [dbo].[BankYearNeWorthBase] ADD  CONSTRAINT [DF_BankYearNeWorthBase_NTDToUSDEXRate]  DEFAULT ((0)) FOR [NTDToUSDEXRate]
GO
ALTER TABLE [dbo].[BankYearNeWorthBase] ADD  CONSTRAINT [DF_BankYearNeWorthBase_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[BankYearNeWorthBase] ADD  CONSTRAINT [DF_BankYearNeWorthBase_Create_user]  DEFAULT ('') FOR [Create_user]
GO
ALTER TABLE [dbo].[BankYearNeWorthBase] ADD  CONSTRAINT [DF_BankYearNeWorthBase_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[BankYearNeWorthBase] ADD  CONSTRAINT [DF_BankYearNeWorthBase_Update_user]  DEFAULT ('') FOR [Update_user]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'年' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankYearNeWorthBase', @level2type=N'COLUMN',@level2name=N'Year'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'台幣與美金匯率' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankYearNeWorthBase', @level2type=N'COLUMN',@level2name=N'NTDToUSDEXRate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'全行淨值(台幣)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankYearNeWorthBase', @level2type=N'COLUMN',@level2name=N'NetWorthNTD'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'全行淨值(美金)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankYearNeWorthBase', @level2type=N'COLUMN',@level2name=N'NetWorthUSD'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'全行淨值倍率' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankYearNeWorthBase', @level2type=N'COLUMN',@level2name=N'TotalRiskRatio'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'全行風控總淨值(台幣)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankYearNeWorthBase', @level2type=N'COLUMN',@level2name=N'TotalNetWorthNTD'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'全行風控總淨值(美金)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankYearNeWorthBase', @level2type=N'COLUMN',@level2name=N'TotalNetWorthUSD'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'風控警示額度(台幣)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankYearNeWorthBase', @level2type=N'COLUMN',@level2name=N'WarningAmountNTD'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'風控警示額度(美金)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankYearNeWorthBase', @level2type=N'COLUMN',@level2name=N'WarningAmountUSD'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建立時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankYearNeWorthBase', @level2type=N'COLUMN',@level2name=N'Create_date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建立者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankYearNeWorthBase', @level2type=N'COLUMN',@level2name=N'Create_user'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'更新時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankYearNeWorthBase', @level2type=N'COLUMN',@level2name=N'Update_date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'更新者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankYearNeWorthBase', @level2type=N'COLUMN',@level2name=N'Update_user'
GO
