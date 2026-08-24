SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[CreditRating_Country_Current](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_Country_Id] [int] NOT NULL,
	[FK_RatingAgency_Id] [int] NOT NULL,
	[AgencyRating] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[RatingDate] [datetime] NULL,
	[RatingOutlook] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[RatingOutlookDate] [datetime] NULL,
	[Remarks] [nvarchar](500) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[updated_Date] [datetime] NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[PublishedAt] [datetime] NOT NULL,
 CONSTRAINT [PK_CreditRating_Country_Current] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB],
 CONSTRAINT [UQ_CreditRating_Country_Current_Agency_Country] UNIQUE NONCLUSTERED
(
	[FK_RatingAgency_Id] ASC,
	[FK_Country_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
) ON [NCRMS_TAB]';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
IF FILEGROUP_ID(N'NCRMS_IDX') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_IDX]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[CreditRating_Country_Current]  WITH CHECK ADD  CONSTRAINT [FK_CreditRating_Country_Current_CountryMaster] FOREIGN KEY([FK_Country_Id])
REFERENCES [dbo].[CountryMaster] ([PK_Id])
GO
ALTER TABLE [dbo].[CreditRating_Country_Current] CHECK CONSTRAINT [FK_CreditRating_Country_Current_CountryMaster]
GO
ALTER TABLE [dbo].[CreditRating_Country_Current]  WITH CHECK ADD  CONSTRAINT [FK_CreditRating_Country_Current_CreditRatingMaster] FOREIGN KEY([FK_RatingAgency_Id])
REFERENCES [dbo].[CreditRatingMaster] ([PK_ID])
GO
ALTER TABLE [dbo].[CreditRating_Country_Current] CHECK CONSTRAINT [FK_CreditRating_Country_Current_CreditRatingMaster]
GO
