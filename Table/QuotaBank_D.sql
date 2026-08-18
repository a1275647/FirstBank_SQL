SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[QuotaBank_D](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[CountryId] [int] NOT NULL,
	[UnitCode] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[QuotaAmount] [int] NOT NULL,
	[Memo] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
 CONSTRAINT [PK_QuotaBankD] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
GO
ALTER TABLE [dbo].[QuotaBank_D] ADD  CONSTRAINT [DF_QuotaBank_D_Memo]  DEFAULT ('') FOR [Memo]
GO
ALTER TABLE [dbo].[QuotaBank_D] ADD  CONSTRAINT [DF_QuotaBank_D_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[QuotaBank_D] ADD  CONSTRAINT [DF_QuotaBank_D_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
