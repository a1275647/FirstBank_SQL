SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[LoanExtApp](
	[ExtFlowFormId] [int] NOT NULL,
	[LoanMainId] [int] NOT NULL,
	[Reason] [nvarchar](max) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[ExtDate] [date] NOT NULL,
	[OriginalTrackingDate] [date] NULL,
	[LatestComment] [nvarchar](max) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_LoanExtApp] PRIMARY KEY CLUSTERED
(
	[ExtFlowFormId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[LoanExtApp]  WITH CHECK ADD  CONSTRAINT [FK_LoanExtApp_LoanMain] FOREIGN KEY([LoanMainId])
REFERENCES [dbo].[LoanBranchData] ([LoanMainId])
GO
ALTER TABLE [dbo].[LoanExtApp] CHECK CONSTRAINT [FK_LoanExtApp_LoanMain]
GO
