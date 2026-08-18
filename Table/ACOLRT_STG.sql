SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ACOLRT_STG](
	[ACOLRT_DATE] [date] NULL,
	[ACOLRT_BRANCH] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[ACOLRT_CURENCY] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[ACOLRT_LOCAL_CURENCY] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[ACOLRT_RATE] [decimal](18, 10) NULL,
	[ACOLRT_EXT_DATE] [date] NULL,
	[ACOLRT_LOAD_DATE] [datetime] NULL,
	[Create_Date] [datetime] NOT NULL
)
GO
ALTER TABLE [dbo].[ACOLRT_STG] ADD  CONSTRAINT [DF_ACOLRT_STG_Create_Date]  DEFAULT (getdate()) FOR [Create_Date]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建置時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ACOLRT_STG', @level2type=N'COLUMN',@level2name=N'Create_Date'
GO
