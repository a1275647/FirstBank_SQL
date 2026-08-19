SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RiskLineD](
	[GroupCode] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[UnitCode] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[BranchCode] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[CustomerId] [nvarchar](11) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[CustomerName] [nvarchar](40) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[LoanType] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[SYNDICATED_LOAN_MK] [bit] NOT NULL,
	[Apply_NO] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Apply_CURENCY_COD] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Apply_Amount] [decimal](18, 2) NOT NULL,
	[Apply_Date] [date] NOT NULL,
	[CountryCode2] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[PERMIT_NO] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[PERMIT_CURENCY_COD] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[PERMIT_Amount] [decimal](18, 2) NULL,
	[PERMIT_Date] [date] NULL,
	[REVOLVE_MK] [bit] NULL,
	[MATURITY_DATE] [date] NULL,
	[Approval_Status] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Memo] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Update_date] [datetime] NOT NULL,
 CONSTRAINT [PK_RiskLineD] PRIMARY KEY CLUSTERED
(
	[BranchCode] ASC,
	[Apply_NO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
GO
