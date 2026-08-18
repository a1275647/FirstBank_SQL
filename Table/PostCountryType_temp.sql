SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PostCountryType_temp](
	[TempId] [int] IDENTITY(1,1) NOT NULL,
	[FK_TempId] [int] NOT NULL,
	[ModifyType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[PK_Id] [int] NULL,
	[FK_CountryId] [int] NULL,
	[FK_PostId] [int] NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK__PostCoun__06C703C11BBDA5A7] PRIMARY KEY CLUSTERED
(
	[TempId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
GO
ALTER TABLE [dbo].[PostCountryType_temp] ADD  CONSTRAINT [DF__PostCount__SysCr__683F278D]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'暫存資料識別碼（流水號）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PostCountryType_temp', @level2type=N'COLUMN',@level2name=N'TempId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'主表暫存資料外鍵' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PostCountryType_temp', @level2type=N'COLUMN',@level2name=N'FK_TempId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'異動類型' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PostCountryType_temp', @level2type=N'COLUMN',@level2name=N'ModifyType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立日期時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PostCountryType_temp', @level2type=N'COLUMN',@level2name=N'SysCreateDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立使用者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PostCountryType_temp', @level2type=N'COLUMN',@level2name=N'SysCreateUser'
GO
