SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[QuotaBank_D_Week](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[QuotaDate] [date] NULL,
	[Year] [int] NOT NULL,
	[Month] [int] NOT NULL,
	[Week] [int] NOT NULL,
	[CountryId] [int] NOT NULL,
	[UnitCode] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[QuotaAmount] [int] NOT NULL,
	[Memo] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
 CONSTRAINT [PK_QuotaBankD_Week] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_PADDING ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE UNIQUE NONCLUSTERED INDEX [IX_QuotaBank_D_Week] ON [dbo].[QuotaBank_D_Week]
(
	[Year] ASC,
	[Month] ASC,
	[Week] ASC,
	[CountryId] ASC,
	[UnitCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]';
IF FILEGROUP_ID(N'NCRMS_IDX') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_IDX]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[QuotaBank_D_Week] ADD  CONSTRAINT [DF_QuotaBank_D_Week_Memo]  DEFAULT ('') FOR [Memo]
GO
ALTER TABLE [dbo].[QuotaBank_D_Week] ADD  CONSTRAINT [DF_QuotaBank_D_Week_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[QuotaBank_D_Week] ADD  CONSTRAINT [DF_QuotaBank_D_Week_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
