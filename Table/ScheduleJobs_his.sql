SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[ScheduleJobs_his](
	[Log_id] [int] IDENTITY(1,1) NOT NULL,
	[LogType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[FlowFormId] [int] NULL,
	[PK_Id] [int] NOT NULL,
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
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK__Schedule__2D21E3B610EB64F6] PRIMARY KEY CLUSTERED
(
	[Log_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[ScheduleJobs_his] ADD  CONSTRAINT [DF__ScheduleJo__Name__53F837BE]  DEFAULT ('') FOR [Name]
GO
ALTER TABLE [dbo].[ScheduleJobs_his] ADD  CONSTRAINT [DF__ScheduleJ__Descr__54EC5BF7]  DEFAULT ('') FOR [Description]
GO
ALTER TABLE [dbo].[ScheduleJobs_his] ADD  CONSTRAINT [DF__ScheduleJ__CronE__55E08030]  DEFAULT (N'* * * * *') FOR [CronExpression]
GO
ALTER TABLE [dbo].[ScheduleJobs_his] ADD  CONSTRAINT [DF__ScheduleJ__JobAP__56D4A469]  DEFAULT ('') FOR [JobAPI]
GO
ALTER TABLE [dbo].[ScheduleJobs_his] ADD  CONSTRAINT [DF__ScheduleJ__IsAct__57C8C8A2]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[ScheduleJobs_his] ADD  CONSTRAINT [DF__ScheduleJ__ISRun__58BCECDB]  DEFAULT ((0)) FOR [ISRunning]
GO
ALTER TABLE [dbo].[ScheduleJobs_his] ADD  CONSTRAINT [DF__ScheduleJ__TimeO__59B11114]  DEFAULT ((1)) FOR [TimeOutMinutes]
GO
ALTER TABLE [dbo].[ScheduleJobs_his] ADD  CONSTRAINT [DF__ScheduleJ__Updat__5AA5354D]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[ScheduleJobs_his] ADD  CONSTRAINT [DF__ScheduleJ__Updat__5B995986]  DEFAULT ('system') FOR [Update_user]
GO
ALTER TABLE [dbo].[ScheduleJobs_his] ADD  CONSTRAINT [DF__ScheduleJ__Creat__5C8D7DBF]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[ScheduleJobs_his] ADD  CONSTRAINT [DF__ScheduleJ__Creat__5D81A1F8]  DEFAULT ('system') FOR [Create_user]
GO
ALTER TABLE [dbo].[ScheduleJobs_his] ADD  CONSTRAINT [DF__ScheduleJ__LastE__5E75C631]  DEFAULT ('') FOR [LastError]
GO
ALTER TABLE [dbo].[ScheduleJobs_his] ADD  CONSTRAINT [DF__ScheduleJ__SysCr__5F69EA6A]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
ALTER TABLE [dbo].[ScheduleJobs_his]  WITH CHECK ADD  CONSTRAINT [FK_ScheduleJobs_his_FlowForm] FOREIGN KEY([FlowFormId])
REFERENCES [dbo].[FlowForm] ([PK_Id])
GO
ALTER TABLE [dbo].[ScheduleJobs_his] CHECK CONSTRAINT [FK_ScheduleJobs_his_FlowForm]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'歷史記錄識別碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScheduleJobs_his', @level2type=N'COLUMN',@level2name=N'Log_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'異動行為類型 (INSERT/UPDATE/DELETE)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScheduleJobs_his', @level2type=N'COLUMN',@level2name=N'LogType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'流程表單識別碼（外鍵：FlowForm.PK_ID）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScheduleJobs_his', @level2type=N'COLUMN',@level2name=N'FlowFormId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立日期時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScheduleJobs_his', @level2type=N'COLUMN',@level2name=N'SysCreateDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立使用者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScheduleJobs_his', @level2type=N'COLUMN',@level2name=N'SysCreateUser'
GO
