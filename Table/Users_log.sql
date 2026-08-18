SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Users_log](
	[logType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[UserId] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[UserName] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Email] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[GroupCode] [nvarchar](5) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[UnitCode] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[BranchCode] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[DepartmentCode] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[DepartmentName] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Chief] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[TitleCode] [int] NULL,
	[TitleName] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[IsActive] [bit] NULL,
	[IsEmployed] [bit] NULL,
	[Leave_Start] [datetime] NULL,
	[Leave_End] [datetime] NULL,
	[Acting_Person] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Create_date] [datetime] NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_User] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Memo] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SysCreateDate] [datetime] NOT NULL
)
GO
ALTER TABLE [dbo].[Users_log] ADD  CONSTRAINT [DF_Users_his_IsActive]  DEFAULT ((0)) FOR [IsActive]
GO
ALTER TABLE [dbo].[Users_log] ADD  CONSTRAINT [DF_Users_his_IsEmployed]  DEFAULT ((1)) FOR [IsEmployed]
GO
ALTER TABLE [dbo].[Users_log] ADD  CONSTRAINT [DF_Users_his_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[Users_log] ADD  CONSTRAINT [DF_Users_his_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[Users_log] ADD  CONSTRAINT [DF_Users_his_Update_User]  DEFAULT ('system') FOR [Update_User]
GO
ALTER TABLE [dbo].[Users_log] ADD  CONSTRAINT [DF_Users_his_Memo]  DEFAULT ('') FOR [Memo]
GO
ALTER TABLE [dbo].[Users_log] ADD  CONSTRAINT [DF_Users_his_SysCreateDate]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'紀錄的狀態' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Users_log', @level2type=N'COLUMN',@level2name=N'logType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'員工編號' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Users_log', @level2type=N'COLUMN',@level2name=N'UserId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'員工姓名' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Users_log', @level2type=N'COLUMN',@level2name=N'UserName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Mail' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Users_log', @level2type=N'COLUMN',@level2name=N'Email'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'事業群代碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Users_log', @level2type=N'COLUMN',@level2name=N'GroupCode'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'處或分行代碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Users_log', @level2type=N'COLUMN',@level2name=N'UnitCode'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'分行代碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Users_log', @level2type=N'COLUMN',@level2name=N'BranchCode'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'部門代號' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Users_log', @level2type=N'COLUMN',@level2name=N'DepartmentCode'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'部門名稱' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Users_log', @level2type=N'COLUMN',@level2name=N'DepartmentName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'直接主管代號' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Users_log', @level2type=N'COLUMN',@level2name=N'Chief'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'職稱代號' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Users_log', @level2type=N'COLUMN',@level2name=N'TitleCode'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'職稱名稱' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Users_log', @level2type=N'COLUMN',@level2name=N'TitleName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'是否啟用(HRIS沒資料=0)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Users_log', @level2type=N'COLUMN',@level2name=N'IsActive'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'是否在職' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Users_log', @level2type=N'COLUMN',@level2name=N'IsEmployed'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'請假起始時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Users_log', @level2type=N'COLUMN',@level2name=N'Leave_Start'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'請假結束時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Users_log', @level2type=N'COLUMN',@level2name=N'Leave_End'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'代理人' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Users_log', @level2type=N'COLUMN',@level2name=N'Acting_Person'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建立日期' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Users_log', @level2type=N'COLUMN',@level2name=N'Create_date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'更新時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Users_log', @level2type=N'COLUMN',@level2name=N'Update_date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'更新者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Users_log', @level2type=N'COLUMN',@level2name=N'Update_User'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'備註' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Users_log', @level2type=N'COLUMN',@level2name=N'Memo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'紀錄時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Users_log', @level2type=N'COLUMN',@level2name=N'SysCreateDate'
GO
