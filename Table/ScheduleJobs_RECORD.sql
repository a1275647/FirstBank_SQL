SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ScheduleJobs_RECORD](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_ScheduleJobsID] [int] NOT NULL,
	[Name] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Description] [nvarchar](500) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[JobAPI] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[StartRunTime] [datetime] NULL,
	[EndRunTime] [datetime] NULL,
	[LastError] [nvarchar](500) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_Date] [datetime] NOT NULL,
	[Create_User] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_ScheduleJobs_RECORD] PRIMARY KEY CLUSTERED
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
GO
ALTER TABLE [dbo].[ScheduleJobs_RECORD] ADD  CONSTRAINT [DF_ScheduleJobs_RECORD_Name]  DEFAULT ('') FOR [Name]
GO
ALTER TABLE [dbo].[ScheduleJobs_RECORD] ADD  CONSTRAINT [DF_ScheduleJobs_RECORD_Description]  DEFAULT ('') FOR [Description]
GO
ALTER TABLE [dbo].[ScheduleJobs_RECORD] ADD  CONSTRAINT [DF_ScheduleJobs_RECORD_JobAPI]  DEFAULT ('') FOR [JobAPI]
GO
ALTER TABLE [dbo].[ScheduleJobs_RECORD] ADD  CONSTRAINT [DF_ScheduleJobs_RECORD_LastError]  DEFAULT ('') FOR [LastError]
GO
ALTER TABLE [dbo].[ScheduleJobs_RECORD] ADD  CONSTRAINT [DF_ScheduleJobs_RECORD_Create_Date]  DEFAULT (getdate()) FOR [Create_Date]
GO
ALTER TABLE [dbo].[ScheduleJobs_RECORD] ADD  CONSTRAINT [DF_ScheduleJobs_RECORD_Create_User]  DEFAULT ('') FOR [Create_User]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'排程名稱' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScheduleJobs_RECORD', @level2type=N'COLUMN',@level2name=N'Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'描述' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScheduleJobs_RECORD', @level2type=N'COLUMN',@level2name=N'Description'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'排程作業API' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScheduleJobs_RECORD', @level2type=N'COLUMN',@level2name=N'JobAPI'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'排程啟動時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScheduleJobs_RECORD', @level2type=N'COLUMN',@level2name=N'StartRunTime'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'排程結束時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScheduleJobs_RECORD', @level2type=N'COLUMN',@level2name=N'EndRunTime'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'上次執行錯誤內容' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScheduleJobs_RECORD', @level2type=N'COLUMN',@level2name=N'LastError'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'創建時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScheduleJobs_RECORD', @level2type=N'COLUMN',@level2name=N'Create_Date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建立者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScheduleJobs_RECORD', @level2type=N'COLUMN',@level2name=N'Create_User'
GO
