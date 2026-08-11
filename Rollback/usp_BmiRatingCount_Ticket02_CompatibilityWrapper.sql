USE [NCRMS]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Ticket 03 rollback point. Run only after the AP has been rolled back to the
-- Ticket 02 build that calls dbo.usp_BmiRatingCount_Core directly.
CREATE OR ALTER PROCEDURE [dbo].[usp_BmiRatingCount]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Date DATE = CONVERT(DATE, GETDATE());
    DECLARE @CountryRatings [dbo].[CountryRatingResultType];

    INSERT INTO @CountryRatings (FK_Country_Id, FinalRating, Score)
    SELECT FK_Country_Id, FinalRating, Score
    FROM [dbo].[ufn_table_GetCountryRating](@Date);

    EXEC [dbo].[usp_BmiRatingCount_Core]
        @Date = @Date,
        @CountryRatings = @CountryRatings;
END
GO
