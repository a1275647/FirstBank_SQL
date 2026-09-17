SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		allen
-- Create date: 20260424
-- Description:	更新指定轉檔日期MonitorData資料
-- =============================================
Alter PROCEDURE [dbo].[usp_UpdateMonitorDataLimit] @EXT_DATE as date
AS
BEGIN
	SET NOCOUNT ON;
    BEGIN TRY
		update m set CAL_TO_USD_LIMIT = CAL_TO_USD_AMT
		from MONITORDATA_STAGE m
		where m.EXT_DATE = @EXT_DATE AND LIMIT_MATURITY <= @EXT_DATE
	END TRY
    BEGIN CATCH
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT '發生錯誤: ' + @ErrorMsg;
        THROW;
    END CATCH
END
GO
