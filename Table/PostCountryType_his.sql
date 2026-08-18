SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PostCountryType_his](
	[Log_id] [int] IDENTITY(1,1) NOT NULL,
	[LogType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Fk_logId] [int] NOT NULL,
	[PK_Id] [int] NOT NULL,
	[FK_CountryId] [int] NOT NULL,
	[CountryCode2] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CountryName_TN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CountryName_CN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CountryName_EN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CountryName_JP] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK__PostCoun__2D21E3B605E7C15A] PRIMARY KEY CLUSTERED
(
	[Log_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
GO
ALTER TABLE [dbo].[PostCountryType_his] ADD  CONSTRAINT [DF__PostCount__SysCr__1E9B383E]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'歷史記錄識別碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PostCountryType_his', @level2type=N'COLUMN',@level2name=N'Log_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'異動行為類型 (INSERT/UPDATE/DELETE)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PostCountryType_his', @level2type=N'COLUMN',@level2name=N'LogType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立日期時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PostCountryType_his', @level2type=N'COLUMN',@level2name=N'SysCreateDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立使用者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PostCountryType_his', @level2type=N'COLUMN',@level2name=N'SysCreateUser'
GO
