SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RatingRatioMaster_temp](
	[TempId] [int] IDENTITY(1,1) NOT NULL,
	[FK_TempId] [int] NOT NULL,
	[ModifyType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[PK_Id] [int] NULL,
	[Year] [int] NULL,
	[RatingLevel] [int] NULL,
	[RiskRatio] [int] NULL,
	[HasFCBBranch] [bit] NULL,
	[Create_date] [datetime] NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Update_date] [datetime] NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK__RatingRa__06C703C1BF4C0345] PRIMARY KEY CLUSTERED
(
	[TempId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
GO
ALTER TABLE [dbo].[RatingRatioMaster_temp] ADD  CONSTRAINT [DF__RatingRat__Creat__0A495B77]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[RatingRatioMaster_temp] ADD  CONSTRAINT [DF__RatingRat__Updat__0B3D7FB0]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[RatingRatioMaster_temp] ADD  CONSTRAINT [DF__RatingRat__SysCr__0C31A3E9]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
ALTER TABLE [dbo].[RatingRatioMaster_temp]  WITH CHECK ADD  CONSTRAINT [FK_RatingRatioMaster_temp_BankYearNeWorthBase_temp] FOREIGN KEY([FK_TempId])
REFERENCES [dbo].[BankYearNeWorthBase_temp] ([TempId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[RatingRatioMaster_temp] CHECK CONSTRAINT [FK_RatingRatioMaster_temp_BankYearNeWorthBase_temp]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'暫存資料識別碼（流水號）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RatingRatioMaster_temp', @level2type=N'COLUMN',@level2name=N'TempId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'主表暫存資料外鍵' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RatingRatioMaster_temp', @level2type=N'COLUMN',@level2name=N'FK_TempId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'異動類型' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RatingRatioMaster_temp', @level2type=N'COLUMN',@level2name=N'ModifyType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立日期時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RatingRatioMaster_temp', @level2type=N'COLUMN',@level2name=N'SysCreateDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立使用者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RatingRatioMaster_temp', @level2type=N'COLUMN',@level2name=N'SysCreateUser'
GO
