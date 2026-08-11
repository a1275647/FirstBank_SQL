USE [NCRMS]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 正式 AP 契約：部署前須先建立 dbo.CountryRatingResultType 與
-- dbo.usp_BmiRatingCount_Core。此程序不再解析系統日期或重算國家評等。
CREATE OR ALTER PROCEDURE [dbo].[usp_BmiRatingCount]
    @Date DATE,
    @CountryRatings [dbo].[CountryRatingResultType] READONLY
AS
BEGIN
    SET NOCOUNT ON;

    EXEC [dbo].[usp_BmiRatingCount_Core]
        @Date = @Date,
        @CountryRatings = @CountryRatings;
END
GO
