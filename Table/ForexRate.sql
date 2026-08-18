SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ForexRate](
	[ForexRateCode] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[ForexRateDate] [date] NOT NULL,
	[CURNCY_Code] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[CURNCY_Name] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[ForexRateValue] [decimal](18, 4) NOT NULL,
	[Create_date] [datetime] NOT NULL,
 CONSTRAINT [PK_ForexRate_1] PRIMARY KEY CLUSTERED
(
	[ForexRateCode] ASC,
	[ForexRateDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
GO
