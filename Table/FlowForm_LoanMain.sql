SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[FlowForm_LoanMain](
	[FlowFormId] [int] NOT NULL,
	[LoanCountryId] [int] NOT NULL,
	[LoanMethodType] [int] NOT NULL,
	[LoanUnit] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[FinalLoanUnit] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[ApplyUSDAmount] [int] NOT NULL,
	[ApplyUSDDate] [datetime] NOT NULL,
	[ApproveUSDAmount] [int] NULL,
	[IsRepay] [bit] NOT NULL,
	[RealRepayDate] [datetime] NULL,
	[IsApproved] [bit] NOT NULL,
	[RepayDate] [date] NOT NULL,
	[ApproveDate] [datetime] NULL,
	[EndDate] [datetime] NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_FlowForm_LoanMain] PRIMARY KEY CLUSTERED
(
	[FlowFormId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[FlowForm_LoanMain] ADD  CONSTRAINT [DF__FlowForm___LoanM__46741F6E]  DEFAULT ((0)) FOR [LoanMethodType]
GO
ALTER TABLE [dbo].[FlowForm_LoanMain] ADD  CONSTRAINT [DF__FlowForm___IsRep__476843A7]  DEFAULT ((0)) FOR [IsRepay]
GO
ALTER TABLE [dbo].[FlowForm_LoanMain] ADD  CONSTRAINT [DF_FlowForm_LoanMain_IsApproved]  DEFAULT ((0)) FOR [IsApproved]
GO
