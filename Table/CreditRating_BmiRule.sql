SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CreditRating_BmiRule](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[RuleName] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[DisplayName] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[BMI_ColumnName] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[ConditionColumn] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[ConditionValue] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[ScoreLevel] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[MinValue] [decimal](18, 4) NULL,
	[MaxValue] [decimal](18, 4) NULL,
	[Score] [float] NULL,
	[SortOrder] [int] NULL,
	[CalculationNotes] [nvarchar](500) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[IsActive] [bit] NULL,
	[CreatedDate] [datetime2](7) NULL,
	[UpdatedDate] [datetime2](7) NULL,
	[IsDisplay] [bit] NOT NULL,
 CONSTRAINT [PK__BMIScori__F4A24B2259A9FA85] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_BmiRule_RuleName_Active] ON [dbo].[CreditRating_BmiRule]
(
	[RuleName] ASC,
	[IsActive] ASC,
	[ScoreLevel] ASC
)
INCLUDE([MinValue],[MaxValue],[Score]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
GO
ALTER TABLE [dbo].[CreditRating_BmiRule] ADD  CONSTRAINT [DF__CreditRat__IsDis__33E06DE7]  DEFAULT ((1)) FOR [IsDisplay]
GO
