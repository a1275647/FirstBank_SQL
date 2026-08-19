SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ScheduleJobs](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Description] [nvarchar](500) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[CronExpression] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[JobAPI] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[IsActive] [bit] NOT NULL,
	[ISRunning] [bit] NOT NULL,
	[TimeOutMinutes] [int] NOT NULL,
	[LastStartRunTime] [datetime] NULL,
	[LastEndRunTime] [datetime] NULL,
	[NextRunTime] [datetime] NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[LastError] [nvarchar](500) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_ScheduleJobs] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
GO
ALTER TABLE [dbo].[ScheduleJobs] ADD  CONSTRAINT [DF_ScheduleJobs_Name]  DEFAULT ('') FOR [Name]
GO
ALTER TABLE [dbo].[ScheduleJobs] ADD  CONSTRAINT [DF_ScheduleJobs_Description]  DEFAULT ('') FOR [Description]
GO
ALTER TABLE [dbo].[ScheduleJobs] ADD  CONSTRAINT [DF_ScheduleJobs_CronExpression]  DEFAULT (N'* * * * *') FOR [CronExpression]
GO
ALTER TABLE [dbo].[ScheduleJobs] ADD  CONSTRAINT [DF_ScheduleJobs_JobAPI]  DEFAULT ('') FOR [JobAPI]
GO
ALTER TABLE [dbo].[ScheduleJobs] ADD  CONSTRAINT [DF__ScheduleJ__IsEna__53F837BE]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[ScheduleJobs] ADD  CONSTRAINT [DF_ScheduleJobs_ISRunning]  DEFAULT ((0)) FOR [ISRunning]
GO
ALTER TABLE [dbo].[ScheduleJobs] ADD  CONSTRAINT [DF_ScheduleJobs_TimeOutMinutes]  DEFAULT ((1)) FOR [TimeOutMinutes]
GO
ALTER TABLE [dbo].[ScheduleJobs] ADD  CONSTRAINT [DF_ScheduleJobs_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[ScheduleJobs] ADD  CONSTRAINT [DF_ScheduleJobs_Update_user]  DEFAULT ('system') FOR [Update_user]
GO
ALTER TABLE [dbo].[ScheduleJobs] ADD  CONSTRAINT [DF_ScheduleJobs_Create_Date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[ScheduleJobs] ADD  CONSTRAINT [DF_ScheduleJobs_Create_User]  DEFAULT ('system') FOR [Create_user]
GO
ALTER TABLE [dbo].[ScheduleJobs] ADD  CONSTRAINT [DF_ScheduleJobs_LastError]  DEFAULT ('') FOR [LastError]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'排程名稱' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScheduleJobs', @level2type=N'COLUMN',@level2name=N'Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'描述' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScheduleJobs', @level2type=N'COLUMN',@level2name=N'Description'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Cron時間語言' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScheduleJobs', @level2type=N'COLUMN',@level2name=N'CronExpression'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'排程作業API' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScheduleJobs', @level2type=N'COLUMN',@level2name=N'JobAPI'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'是否啟用' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScheduleJobs', @level2type=N'COLUMN',@level2name=N'IsActive'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'是否執行中' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScheduleJobs', @level2type=N'COLUMN',@level2name=N'ISRunning'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'逾期時間(分鐘)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScheduleJobs', @level2type=N'COLUMN',@level2name=N'TimeOutMinutes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'上次執行開始時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScheduleJobs', @level2type=N'COLUMN',@level2name=N'LastStartRunTime'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'上次執行結束時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScheduleJobs', @level2type=N'COLUMN',@level2name=N'LastEndRunTime'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'下次執行時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScheduleJobs', @level2type=N'COLUMN',@level2name=N'NextRunTime'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'更新時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScheduleJobs', @level2type=N'COLUMN',@level2name=N'Update_date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'更新者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScheduleJobs', @level2type=N'COLUMN',@level2name=N'Update_user'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'創建時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScheduleJobs', @level2type=N'COLUMN',@level2name=N'Create_date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建立者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScheduleJobs', @level2type=N'COLUMN',@level2name=N'Create_user'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'上次執行錯誤內容' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScheduleJobs', @level2type=N'COLUMN',@level2name=N'LastError'
GO
