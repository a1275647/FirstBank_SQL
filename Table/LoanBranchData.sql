SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LoanBranchData](
	[LoanMainId] [int] NOT NULL,
	[LoanFlowRoute] [int] NOT NULL,
	[IsFirstTime] [bit] NOT NULL,
	[HaihuIsNeedRunLoanUnit] [bit] NULL,
	[TrackingDate] [date] NULL,
	[ApplyTrackingDate] [date] NULL,
	[WindRiskFormId] [int] NULL,
	[WindRiskIsTracking] [bit] NULL,
	[HaihuFormId] [int] NULL,
	[HaihuIsTracking] [bit] NULL,
	[HaihuLoanMethod] [int] NULL,
	[HaihuSelectedUnitCode] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_LoanBranchData] PRIMARY KEY CLUSTERED
(
	[LoanMainId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
GO
ALTER TABLE [dbo].[LoanBranchData] ADD  CONSTRAINT [DF__LoanBranc__IsFir__4A44B052]  DEFAULT ((1)) FOR [IsFirstTime]
GO
ALTER TABLE [dbo].[LoanBranchData]  WITH CHECK ADD  CONSTRAINT [FK_LoanBranchData_LoanMain] FOREIGN KEY([LoanMainId])
REFERENCES [dbo].[FlowForm_LoanMain] ([FlowFormId])
GO
ALTER TABLE [dbo].[LoanBranchData] CHECK CONSTRAINT [FK_LoanBranchData_LoanMain]
GO
