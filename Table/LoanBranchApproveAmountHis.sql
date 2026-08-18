SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LoanBranchApproveAmountHis](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FlowFromId] [int] NOT NULL,
	[ApplyDate] [datetime] NOT NULL,
	[ApplyAmount] [int] NOT NULL,
	[ApproveDate] [datetime] NULL,
	[ApproveAmount] [int] NULL,
 CONSTRAINT [PK_LoanBranchApproveAmountHis] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
GO
ALTER TABLE [dbo].[LoanBranchApproveAmountHis]  WITH CHECK ADD  CONSTRAINT [FK_LoanBranchApproveAmountHis_BranchData] FOREIGN KEY([FlowFromId])
REFERENCES [dbo].[LoanBranchData] ([LoanMainId])
GO
ALTER TABLE [dbo].[LoanBranchApproveAmountHis] CHECK CONSTRAINT [FK_LoanBranchApproveAmountHis_BranchData]
GO
