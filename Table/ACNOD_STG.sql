SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ACNOD_STG](
	[ACNOD_BRANCH_CODE] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[ACNOD_CRCY_CODE] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[ACNOD_ACC5_CODE] [nvarchar](5) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[ACNOD_ACC5_SUB_CODE] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[ACNOD_OPER_DATE_BAL_INF] [decimal](17, 2) NULL,
	[ACNOD_LAST_BAL_MARK] [nvarchar](1) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[ACNOD_EXT_DATE] [date] NULL,
	[Create_Date] [datetime] NOT NULL
) ON [NCRMS_TAB]
GO
CREATE NONCLUSTERED INDEX [IX_ACNOD_STG] ON [dbo].[ACNOD_STG]
(
	[ACNOD_EXT_DATE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
GO
ALTER TABLE [dbo].[ACNOD_STG] ADD  CONSTRAINT [DF_ACNOD_STG_Create_Date]  DEFAULT (getdate()) FOR [Create_Date]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'帳務行' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ACNOD_STG', @level2type=N'COLUMN',@level2name=N'ACNOD_BRANCH_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'幣別' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ACNOD_STG', @level2type=N'COLUMN',@level2name=N'ACNOD_CRCY_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'會計科目(5碼)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ACNOD_STG', @level2type=N'COLUMN',@level2name=N'ACNOD_ACC5_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'會計科目(5碼)-分戶代號' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ACNOD_STG', @level2type=N'COLUMN',@level2name=N'ACNOD_ACC5_SUB_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'餘額' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ACNOD_STG', @level2type=N'COLUMN',@level2name=N'ACNOD_OPER_DATE_BAL_INF'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'最後一筆餘額註記' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ACNOD_STG', @level2type=N'COLUMN',@level2name=N'ACNOD_LAST_BAL_MARK'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'資料日' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ACNOD_STG', @level2type=N'COLUMN',@level2name=N'ACNOD_EXT_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建置時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ACNOD_STG', @level2type=N'COLUMN',@level2name=N'Create_Date'
GO
