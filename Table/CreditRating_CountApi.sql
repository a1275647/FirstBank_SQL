SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[CreditRating_CountApi](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_RatingAgency_Id] [int] NOT NULL,
	[CreditRatingType] [int] NOT NULL,
	[Year] [int] NOT NULL,
	[Count] [int] NOT NULL,
	[Create_date] [datetime] NOT NULL,
 CONSTRAINT [PK_CreditRating_CountApi] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE NONCLUSTERED INDEX [IX_CreditRating_CountApi_Agency_Type] ON [dbo].[CreditRating_CountApi]
(
	[FK_RatingAgency_Id] ASC,
	[CreditRatingType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]';
IF FILEGROUP_ID(N'NCRMS_IDX') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_IDX]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[CreditRating_CountApi] ADD  CONSTRAINT [DF_CreditRating_CountApi_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[CreditRating_CountApi]  WITH CHECK ADD  CONSTRAINT [FK_CreditRating_CountApi_Global] FOREIGN KEY([CreditRatingType])
REFERENCES [dbo].[Global] ([Id])
GO
ALTER TABLE [dbo].[CreditRating_CountApi] CHECK CONSTRAINT [FK_CreditRating_CountApi_Global]
GO
ALTER TABLE [dbo].[CreditRating_CountApi]  WITH CHECK ADD  CONSTRAINT [FK_CreditRating_CountApi_RatingAgency] FOREIGN KEY([FK_RatingAgency_Id])
REFERENCES [dbo].[CreditRatingMaster] ([PK_ID])
GO
ALTER TABLE [dbo].[CreditRating_CountApi] CHECK CONSTRAINT [FK_CreditRating_CountApi_RatingAgency]
GO
