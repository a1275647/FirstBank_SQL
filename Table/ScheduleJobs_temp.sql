SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ScheduleJobs_temp](
	[TempId] [int] IDENTITY(1,1) NOT NULL,
	[FlowFormId] [int] NULL,
	[ModifyType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
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
 CONSTRAINT [PK__Schedule__06C703C15BB935D9] PRIMARY KEY CLUSTERED
(
	[TempId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
GO
ALTER TABLE [dbo].[ScheduleJobs_temp] ADD  CONSTRAINT [DF__ScheduleJo__Name__44B5F42E]  DEFAULT ('') FOR [Name]
GO
ALTER TABLE [dbo].[ScheduleJobs_temp] ADD  CONSTRAINT [DF__ScheduleJ__Descr__45AA1867]  DEFAULT ('') FOR [Description]
GO
ALTER TABLE [dbo].[ScheduleJobs_temp] ADD  CONSTRAINT [DF__ScheduleJ__CronE__469E3CA0]  DEFAULT (N'* * * * *') FOR [CronExpression]
GO
ALTER TABLE [dbo].[ScheduleJobs_temp] ADD  CONSTRAINT [DF__ScheduleJ__JobAP__479260D9]  DEFAULT ('') FOR [JobAPI]
GO
ALTER TABLE [dbo].[ScheduleJobs_temp] ADD  CONSTRAINT [DF__ScheduleJ__IsAct__48868512]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[ScheduleJobs_temp] ADD  CONSTRAINT [DF__ScheduleJ__ISRun__497AA94B]  DEFAULT ((0)) FOR [ISRunning]
GO
ALTER TABLE [dbo].[ScheduleJobs_temp] ADD  CONSTRAINT [DF__ScheduleJ__TimeO__4A6ECD84]  DEFAULT ((1)) FOR [TimeOutMinutes]
GO
ALTER TABLE [dbo].[ScheduleJobs_temp] ADD  CONSTRAINT [DF__ScheduleJ__Updat__4B62F1BD]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[ScheduleJobs_temp] ADD  CONSTRAINT [DF__ScheduleJ__Updat__4C5715F6]  DEFAULT ('system') FOR [Update_user]
GO
ALTER TABLE [dbo].[ScheduleJobs_temp] ADD  CONSTRAINT [DF__ScheduleJ__Creat__4D4B3A2F]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[ScheduleJobs_temp] ADD  CONSTRAINT [DF__ScheduleJ__Creat__4E3F5E68]  DEFAULT ('system') FOR [Create_user]
GO
ALTER TABLE [dbo].[ScheduleJobs_temp] ADD  CONSTRAINT [DF__ScheduleJ__LastE__4F3382A1]  DEFAULT ('') FOR [LastError]
GO
ALTER TABLE [dbo].[ScheduleJobs_temp] ADD  CONSTRAINT [DF__ScheduleJ__SysCr__5027A6DA]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
ALTER TABLE [dbo].[ScheduleJobs_temp]  WITH CHECK ADD  CONSTRAINT [FK_ScheduleJobs_temp_FlowForm] FOREIGN KEY([FlowFormId])
REFERENCES [dbo].[FlowForm] ([PK_Id])
GO
ALTER TABLE [dbo].[ScheduleJobs_temp] CHECK CONSTRAINT [FK_ScheduleJobs_temp_FlowForm]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'暫存資料識別碼（流水號）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScheduleJobs_temp', @level2type=N'COLUMN',@level2name=N'TempId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'流程表單識別碼（外鍵：FlowForm.PK_ID）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScheduleJobs_temp', @level2type=N'COLUMN',@level2name=N'FlowFormId'
GO
