SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BankBranch_his](
	[Log_Id] [int] IDENTITY(1,1) NOT NULL,
	[LogType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[FlowFormId] [int] NOT NULL,
	[PK_Id] [int] NULL,
	[FK_BankUnit] [int] NULL,
	[BankCode] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[BankName_TN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[BankName_EN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[BankName_CN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[BankName_JP] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Latitude] [decimal](13, 10) NULL,
	[Longitude] [decimal](13, 10) NULL,
	[IsActive] [bit] NOT NULL,
	[IsSave] [bit] NOT NULL,
	[Memo] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_BankBranch_his] PRIMARY KEY CLUSTERED
(
	[Log_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
GO
ALTER TABLE [dbo].[BankBranch_his] ADD  CONSTRAINT [DF_BankBranch_his_BankCode]  DEFAULT ('') FOR [BankCode]
GO
ALTER TABLE [dbo].[BankBranch_his] ADD  CONSTRAINT [DF_BankBranch_his_Name_EN]  DEFAULT ('') FOR [BankName_TN]
GO
ALTER TABLE [dbo].[BankBranch_his] ADD  CONSTRAINT [DF_BankBranch_his_Name_TN]  DEFAULT ('') FOR [BankName_EN]
GO
ALTER TABLE [dbo].[BankBranch_his] ADD  CONSTRAINT [DF_BankBranch_his_Name_CN]  DEFAULT ('') FOR [BankName_CN]
GO
ALTER TABLE [dbo].[BankBranch_his] ADD  CONSTRAINT [DF_BankBranch_his_Name_JP]  DEFAULT ('') FOR [BankName_JP]
GO
ALTER TABLE [dbo].[BankBranch_his] ADD  CONSTRAINT [DF_BankBranch_his_IsActicve]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[BankBranch_his] ADD  CONSTRAINT [DF_BankBranch_his_IsSave]  DEFAULT ((0)) FOR [IsSave]
GO
ALTER TABLE [dbo].[BankBranch_his] ADD  CONSTRAINT [DF_BankBranch_his_Memo]  DEFAULT ('') FOR [Memo]
GO
ALTER TABLE [dbo].[BankBranch_his] ADD  CONSTRAINT [DF_BankBranch_his_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[BankBranch_his] ADD  CONSTRAINT [DF_BankBranch_his_Update_user]  DEFAULT ('system') FOR [Update_user]
GO
ALTER TABLE [dbo].[BankBranch_his] ADD  CONSTRAINT [DF_BankBranch_his_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[BankBranch_his] ADD  CONSTRAINT [DF_BankBranch_his_Create_user]  DEFAULT ('system') FOR [Create_user]
GO
ALTER TABLE [dbo].[BankBranch_his] ADD  CONSTRAINT [DF_BankBranch_his_SysCreate_date]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
ALTER TABLE [dbo].[BankBranch_his]  WITH CHECK ADD  CONSTRAINT [FK_BankBranch_his_FlowForm] FOREIGN KEY([FlowFormId])
REFERENCES [dbo].[FlowForm] ([PK_Id])
GO
ALTER TABLE [dbo].[BankBranch_his] CHECK CONSTRAINT [FK_BankBranch_his_FlowForm]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'紀錄的狀態' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankBranch_his', @level2type=N'COLUMN',@level2name=N'LogType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'業務處關聯用' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankBranch_his', @level2type=N'COLUMN',@level2name=N'FK_BankUnit'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'分行代碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankBranch_his', @level2type=N'COLUMN',@level2name=N'BankCode'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'繁中' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankBranch_his', @level2type=N'COLUMN',@level2name=N'BankName_TN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'英' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankBranch_his', @level2type=N'COLUMN',@level2name=N'BankName_EN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'簡中' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankBranch_his', @level2type=N'COLUMN',@level2name=N'BankName_CN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'日' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankBranch_his', @level2type=N'COLUMN',@level2name=N'BankName_JP'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'經度' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankBranch_his', @level2type=N'COLUMN',@level2name=N'Latitude'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'緯度' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankBranch_his', @level2type=N'COLUMN',@level2name=N'Longitude'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'是否啟用' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankBranch_his', @level2type=N'COLUMN',@level2name=N'IsActive'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'是否為保留額度' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankBranch_his', @level2type=N'COLUMN',@level2name=N'IsSave'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'更新時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankBranch_his', @level2type=N'COLUMN',@level2name=N'Update_date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'更新者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankBranch_his', @level2type=N'COLUMN',@level2name=N'Update_user'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建置時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankBranch_his', @level2type=N'COLUMN',@level2name=N'Create_date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建置者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankBranch_his', @level2type=N'COLUMN',@level2name=N'Create_user'
GO
