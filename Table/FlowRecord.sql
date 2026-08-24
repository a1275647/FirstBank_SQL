SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[FlowRecord](
	[PK_id] [int] IDENTITY(1,1) NOT NULL,
	[FlowFormId] [int] NOT NULL,
	[FlowDetailId] [uniqueidentifier] NOT NULL,
	[OriginHandler] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[OriginHandlerGroupCode] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[OriginHandlerUnitCode] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[OriginHandlerBranchCode] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[OriginHandlerTitleCode] [int] NOT NULL,
	[OriginDepartmentCode] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[ApproverId] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[ApproverTitleId] [int] NOT NULL,
	[ApproverUnitCode] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[FlowActionType] [int] NULL,
	[ApproverComments] [nvarchar](255) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
 CONSTRAINT [PK__FLOW_REC__F4A5475AB0442D71] PRIMARY KEY CLUSTERED
(
	[PK_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[FlowRecord] ADD  CONSTRAINT [DF_FlowRecord_OriginHandler]  DEFAULT ('') FOR [OriginHandler]
GO
ALTER TABLE [dbo].[FlowRecord] ADD  CONSTRAINT [DF_FlowRecord_OriginHnadlerGroupCode]  DEFAULT ('') FOR [OriginHandlerGroupCode]
GO
ALTER TABLE [dbo].[FlowRecord] ADD  CONSTRAINT [DF_FlowRecord_OriginHandlerUnitCode]  DEFAULT ('') FOR [OriginHandlerUnitCode]
GO
ALTER TABLE [dbo].[FlowRecord] ADD  CONSTRAINT [DF_FlowRecord_OriginHandlerTitleCode]  DEFAULT ((0)) FOR [OriginHandlerTitleCode]
GO
ALTER TABLE [dbo].[FlowRecord] ADD  CONSTRAINT [DF_FlowRecord_OriginDepartmentCode]  DEFAULT ('') FOR [OriginDepartmentCode]
GO
ALTER TABLE [dbo].[FlowRecord] ADD  CONSTRAINT [DF_FlowRecord_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[FlowRecord]  WITH CHECK ADD  CONSTRAINT [FK_FlowRecord_FlowDetail] FOREIGN KEY([FlowDetailId])
REFERENCES [dbo].[FlowDetail] ([PK_Id])
GO
ALTER TABLE [dbo].[FlowRecord] CHECK CONSTRAINT [FK_FlowRecord_FlowDetail]
GO
ALTER TABLE [dbo].[FlowRecord]  WITH CHECK ADD  CONSTRAINT [FK_FlowRecord_FlowForm] FOREIGN KEY([FlowFormId])
REFERENCES [dbo].[FlowForm] ([PK_Id])
GO
ALTER TABLE [dbo].[FlowRecord] CHECK CONSTRAINT [FK_FlowRecord_FlowForm]
GO
