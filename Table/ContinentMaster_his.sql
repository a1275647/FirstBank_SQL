SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ContinentMaster_his](
	[Log_id] [int] IDENTITY(1,1) NOT NULL,
	[LogType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[FlowFormId] [int] NULL,
	[PK_Id] [int] NOT NULL,
	[ContinentCode] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[ContinentName_TN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[ContinentName_EN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[ContinentName_CN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[ContinentName_JP] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[IsActive] [bit] NOT NULL,
	[IsContinent] [bit] NOT NULL,
	[seq] [int] NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK__Continen__2D21E3B63171B2E4] PRIMARY KEY CLUSTERED
(
	[Log_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
GO
ALTER TABLE [dbo].[ContinentMaster_his] ADD  CONSTRAINT [DF__Continent__Conti__0A7E65A1]  DEFAULT ('') FOR [ContinentCode]
GO
ALTER TABLE [dbo].[ContinentMaster_his] ADD  CONSTRAINT [DF__Continent__Conti__0B7289DA]  DEFAULT ('') FOR [ContinentName_TN]
GO
ALTER TABLE [dbo].[ContinentMaster_his] ADD  CONSTRAINT [DF__Continent__Conti__0C66AE13]  DEFAULT ('') FOR [ContinentName_EN]
GO
ALTER TABLE [dbo].[ContinentMaster_his] ADD  CONSTRAINT [DF__Continent__Conti__0D5AD24C]  DEFAULT ('') FOR [ContinentName_CN]
GO
ALTER TABLE [dbo].[ContinentMaster_his] ADD  CONSTRAINT [DF__Continent__Conti__0E4EF685]  DEFAULT ('') FOR [ContinentName_JP]
GO
ALTER TABLE [dbo].[ContinentMaster_his] ADD  CONSTRAINT [DF__Continent__IsAct__0F431ABE]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[ContinentMaster_his] ADD  CONSTRAINT [DF__Continent__IsCon__10373EF7]  DEFAULT ((0)) FOR [IsContinent]
GO
ALTER TABLE [dbo].[ContinentMaster_his] ADD  CONSTRAINT [DF__ContinentMa__seq__112B6330]  DEFAULT ((1)) FOR [seq]
GO
ALTER TABLE [dbo].[ContinentMaster_his] ADD  CONSTRAINT [DF__Continent__Updat__121F8769]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[ContinentMaster_his] ADD  CONSTRAINT [DF__Continent__Updat__1313ABA2]  DEFAULT ('') FOR [Update_user]
GO
ALTER TABLE [dbo].[ContinentMaster_his] ADD  CONSTRAINT [DF__Continent__Creat__1407CFDB]  DEFAULT ('') FOR [Create_user]
GO
ALTER TABLE [dbo].[ContinentMaster_his] ADD  CONSTRAINT [DF__Continent__Creat__14FBF414]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[ContinentMaster_his] ADD  CONSTRAINT [DF__Continent__SysCr__15F0184D]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
ALTER TABLE [dbo].[ContinentMaster_his]  WITH CHECK ADD  CONSTRAINT [FK_ContinentMaster_his_FlowForm] FOREIGN KEY([FlowFormId])
REFERENCES [dbo].[FlowForm] ([PK_Id])
GO
ALTER TABLE [dbo].[ContinentMaster_his] CHECK CONSTRAINT [FK_ContinentMaster_his_FlowForm]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'歷史記錄識別碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ContinentMaster_his', @level2type=N'COLUMN',@level2name=N'Log_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'異動行為類型 (INSERT/UPDATE/DELETE)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ContinentMaster_his', @level2type=N'COLUMN',@level2name=N'LogType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'流程表單識別碼（外鍵：FlowForm.PK_ID）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ContinentMaster_his', @level2type=N'COLUMN',@level2name=N'FlowFormId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立日期時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ContinentMaster_his', @level2type=N'COLUMN',@level2name=N'SysCreateDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立使用者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ContinentMaster_his', @level2type=N'COLUMN',@level2name=N'SysCreateUser'
GO
