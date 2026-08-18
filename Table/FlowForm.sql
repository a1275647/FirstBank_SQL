SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FlowForm](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[ParentId] [int] NULL,
	[RootFlowFormId] [int] NULL,
	[FormType] [int] NULL,
	[FlowId] [int] NOT NULL,
	[FlowActionType] [int] NOT NULL,
	[ApplicantId] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[ApplicantGroupCode] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[ApplicantUnitCode] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[ApplicantBranchCode] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[ApplicantDepartmentCode] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[ApplicantTitleId] [int] NOT NULL,
	[ApplicantContent] [nvarchar](500) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[StepId] [uniqueidentifier] NOT NULL,
	[Handler] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[HandlerGroupCode] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[HandlerUnitCode] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[HandlerBranchCode] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[HandlerDepartmentCode] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[HandlerTitleCode] [int] NOT NULL,
	[TotalSteps] [int] NOT NULL,
	[EndDate] [datetime] NULL,
	[EndStepId] [uniqueidentifier] NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK__FLOW_FOR__F4A24BC2CE3A3F8B] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
GO
ALTER TABLE [dbo].[FlowForm] ADD  CONSTRAINT [DF_FlowForm_ApplicantGroupCode]  DEFAULT ('') FOR [ApplicantGroupCode]
GO
ALTER TABLE [dbo].[FlowForm] ADD  CONSTRAINT [DF_FlowForm_ApplicantDepartmentCode]  DEFAULT ('') FOR [ApplicantDepartmentCode]
GO
ALTER TABLE [dbo].[FlowForm] ADD  CONSTRAINT [DF_FlowForm_HandlerGroupCode]  DEFAULT ('') FOR [HandlerGroupCode]
GO
ALTER TABLE [dbo].[FlowForm] ADD  CONSTRAINT [DF_FlowForm_HandlerUnitCode]  DEFAULT ('') FOR [HandlerUnitCode]
GO
ALTER TABLE [dbo].[FlowForm] ADD  CONSTRAINT [DF_FlowForm_HandlerDepartmentCode]  DEFAULT ('') FOR [HandlerDepartmentCode]
GO
ALTER TABLE [dbo].[FlowForm] ADD  CONSTRAINT [DF_FlowForm_HandlerTitleCode]  DEFAULT ((0)) FOR [HandlerTitleCode]
GO
ALTER TABLE [dbo].[FlowForm] ADD  CONSTRAINT [DF_FlowForm_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[FlowForm] ADD  CONSTRAINT [DF_FlowForm_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[FlowForm]  WITH CHECK ADD  CONSTRAINT [FK_FlowForm_Flow] FOREIGN KEY([FlowId])
REFERENCES [dbo].[Flow] ([PK_Id])
GO
ALTER TABLE [dbo].[FlowForm] CHECK CONSTRAINT [FK_FlowForm_Flow]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'48 = 加簽單' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FlowForm', @level2type=N'COLUMN',@level2name=N'FormType'
GO
