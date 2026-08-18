SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OldData_Quota](
	[ExcelName] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[CountryCode2] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[RatingLevel] [int] NOT NULL,
	[TotalQuota] [int] NOT NULL,
	[TotalTranAmount] [decimal](18, 2) NOT NULL,
 CONSTRAINT [PK_OldData_Quota] PRIMARY KEY CLUSTERED
(
	[ExcelName] ASC,
	[CountryCode2] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
GO
