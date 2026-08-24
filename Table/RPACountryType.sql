SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[RPACountryType](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_RPAId] [int] NOT NULL,
	[FK_CountryId] [int] NOT NULL,
 CONSTRAINT [PK_RPACountryType] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[RPACountryType]  WITH CHECK ADD  CONSTRAINT [FK_RPACountryType_CountryMaster] FOREIGN KEY([FK_CountryId])
REFERENCES [dbo].[CountryMaster] ([PK_Id])
GO
ALTER TABLE [dbo].[RPACountryType] CHECK CONSTRAINT [FK_RPACountryType_CountryMaster]
GO
ALTER TABLE [dbo].[RPACountryType]  WITH CHECK ADD  CONSTRAINT [FK_RPACountryType_RPA] FOREIGN KEY([FK_RPAId])
REFERENCES [dbo].[RPA] ([PK_Id])
GO
ALTER TABLE [dbo].[RPACountryType] CHECK CONSTRAINT [FK_RPACountryType_RPA]
GO
