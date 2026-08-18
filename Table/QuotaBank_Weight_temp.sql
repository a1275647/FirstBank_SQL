SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[QuotaBank_Weight_temp](
	[TempId] [int] IDENTITY(1,1) NOT NULL,
	[FK_TempId] [int] NOT NULL,
	[ModifyType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[QuotaBankDetailId] [int] NOT NULL,
	[WeightPercent] [int] NOT NULL,
	[QuotaAmount] [int] NOT NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK__QuotaBan__06C703C1486D8CE9] PRIMARY KEY CLUSTERED
(
	[TempId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
GO
ALTER TABLE [dbo].[QuotaBank_Weight_temp] ADD  CONSTRAINT [DF__QuotaBank__SysCr__73FAF2FC]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
ALTER TABLE [dbo].[QuotaBank_Weight_temp]  WITH CHECK ADD  CONSTRAINT [FK_QuotaBank_Weight_temp_QuotaBank_D_temp] FOREIGN KEY([FK_TempId])
REFERENCES [dbo].[QuotaBank_D_temp] ([TempId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[QuotaBank_Weight_temp] CHECK CONSTRAINT [FK_QuotaBank_Weight_temp_QuotaBank_D_temp]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'暫存資料識別碼（流水號）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QuotaBank_Weight_temp', @level2type=N'COLUMN',@level2name=N'TempId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'主表暫存資料外鍵' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QuotaBank_Weight_temp', @level2type=N'COLUMN',@level2name=N'FK_TempId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'異動類型' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QuotaBank_Weight_temp', @level2type=N'COLUMN',@level2name=N'ModifyType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立日期時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QuotaBank_Weight_temp', @level2type=N'COLUMN',@level2name=N'SysCreateDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立使用者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QuotaBank_Weight_temp', @level2type=N'COLUMN',@level2name=N'SysCreateUser'
GO
