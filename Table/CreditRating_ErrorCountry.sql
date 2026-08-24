SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[CreditRating_ErrorCountry](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[Type] [int] NOT NULL,
	[FK_RatingAgency_Id] [int] NOT NULL,
	[FK_CountryId] [int] NULL,
	[ErrorMessage] [nvarchar](1000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Create_date] [datetime] NOT NULL,
	[Count] [int] NOT NULL,
 CONSTRAINT [PK_CreditRating_ErrorCountry] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[CreditRating_ErrorCountry] ADD  CONSTRAINT [DF_CreditRating_ErrorCountry_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[CreditRating_ErrorCountry] ADD  CONSTRAINT [DF_CreditRating_ErrorCountry_Count]  DEFAULT ((0)) FOR [Count]
GO
ALTER TABLE [dbo].[CreditRating_ErrorCountry]  WITH CHECK ADD  CONSTRAINT [FK_CreditRating_ErrorCountry_Country] FOREIGN KEY([FK_CountryId])
REFERENCES [dbo].[CountryMaster] ([PK_Id])
GO
ALTER TABLE [dbo].[CreditRating_ErrorCountry] CHECK CONSTRAINT [FK_CreditRating_ErrorCountry_Country]
GO
ALTER TABLE [dbo].[CreditRating_ErrorCountry]  WITH CHECK ADD  CONSTRAINT [FK_CreditRating_ErrorCountry_Global] FOREIGN KEY([Type])
REFERENCES [dbo].[Global] ([Id])
GO
ALTER TABLE [dbo].[CreditRating_ErrorCountry] CHECK CONSTRAINT [FK_CreditRating_ErrorCountry_Global]
GO
ALTER TABLE [dbo].[CreditRating_ErrorCountry]  WITH CHECK ADD  CONSTRAINT [FK_CreditRating_ErrorCountry_RatingAgency] FOREIGN KEY([FK_RatingAgency_Id])
REFERENCES [dbo].[CreditRatingMaster] ([PK_ID])
GO
ALTER TABLE [dbo].[CreditRating_ErrorCountry] CHECK CONSTRAINT [FK_CreditRating_ErrorCountry_RatingAgency]
GO
