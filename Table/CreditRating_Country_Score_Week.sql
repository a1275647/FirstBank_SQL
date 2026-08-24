SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[CreditRating_Country_Score_Week](
    [PK_Id] [int] IDENTITY(1,1) NOT NULL,
    [Year] [int] NOT NULL,
    [Month] [int] NOT NULL,
    [Week] [int] NOT NULL,
    [DataDate] [date] NOT NULL,
    [FK_Country_Id] [int] NOT NULL,
    [CreditRatingScore] [tinyint] NOT NULL,
    [CreditRatingScorePublishedAt] [datetime] NULL,
    [IsActive] [bit] NOT NULL,
    [Create_date] [datetime] NOT NULL,
    [Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
 CONSTRAINT [PK_CreditRating_Country_Score_Week] PRIMARY KEY CLUSTERED
(
    [PK_Id] ASC
) ON [NCRMS_TAB],
 CONSTRAINT [UQ_CreditRating_Country_Score_Week_Period_Country] UNIQUE NONCLUSTERED
(
    [Year] ASC,
    [Month] ASC,
    [Week] ASC,
    [FK_Country_Id] ASC
) ON [NCRMS_IDX]
) ON [NCRMS_TAB]';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
IF FILEGROUP_ID(N'NCRMS_IDX') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_IDX]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE NONCLUSTERED INDEX [IX_CreditRating_Country_Score_Week_Year_Month_Week] ON [dbo].[CreditRating_Country_Score_Week]
(
    [Year] ASC,
    [Month] ASC,
    [Week] ASC
) ON [NCRMS_IDX]';
IF FILEGROUP_ID(N'NCRMS_IDX') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_IDX]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
