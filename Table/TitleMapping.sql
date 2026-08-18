SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TitleMapping](
	[TitleCode] [nvarchar](1) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[TitleId] [int] NULL,
	[TitleName] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL
)
GO
