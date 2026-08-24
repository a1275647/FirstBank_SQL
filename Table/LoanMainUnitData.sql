SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[LoanMainUnitData](
	[LoanMainId] [int] NOT NULL,
	[SelectedUnitCode] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[IsNeedRunLoanUnit] [bit] NOT NULL,
	[LoanApplyMainFormId] [int] NULL,
	[LoanMainUnitFormId] [int] NULL,
	[LoanOtherUnitFormId] [int] NULL,
	[WindRiskFormId] [int] NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_LoanMainUnitData] PRIMARY KEY CLUSTERED
(
	[LoanMainId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[LoanMainUnitData] ADD  CONSTRAINT [DF__LoanMainU__IsNee__5892CFA9]  DEFAULT ((0)) FOR [IsNeedRunLoanUnit]
GO
ALTER TABLE [dbo].[LoanMainUnitData]  WITH CHECK ADD  CONSTRAINT [FK_LoanMainUnitData_LoanMain] FOREIGN KEY([LoanMainId])
REFERENCES [dbo].[FlowForm_LoanMain] ([FlowFormId])
GO
ALTER TABLE [dbo].[LoanMainUnitData] CHECK CONSTRAINT [FK_LoanMainUnitData_LoanMain]
GO
