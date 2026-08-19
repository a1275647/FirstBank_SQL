SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LoanApprovalEntry](
	[LoanMainId] [int] NOT NULL,
	[BranchCode] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[EntryNo] [nvarchar](30) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Status] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Amt] [decimal](18, 2) NULL,
	[SortOrder] [int] NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_LoanApprovalEntry] PRIMARY KEY CLUSTERED
(
	[LoanMainId] ASC,
	[BranchCode] ASC,
	[EntryNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
GO
ALTER TABLE [dbo].[LoanApprovalEntry] ADD  CONSTRAINT [DF__LoanAppro__SortO__51E5D21A]  DEFAULT ((0)) FOR [SortOrder]
GO
ALTER TABLE [dbo].[LoanApprovalEntry]  WITH NOCHECK ADD  CONSTRAINT [FK_LoanApprovalEntry_BranchData] FOREIGN KEY([LoanMainId])
REFERENCES [dbo].[LoanBranchData] ([LoanMainId])
GO
ALTER TABLE [dbo].[LoanApprovalEntry] CHECK CONSTRAINT [FK_LoanApprovalEntry_BranchData]
GO
