SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Create date: 20260807
-- Description:	依 WEIGHTS（usp_UpdateMonitorDataCNWeights）與 RISKFACTOR
--   （usp_UpdateMonitorDataPruduct07RiskFactor）套用後的計算後美金金額，
--   落地至 CAL_TO_USD_AMT／CAL_TO_USD_LIMIT。
-- 執行順序：必須排在 usp_UpdateMonitorDataFPEXR_RateUSD、
--   usp_UpdateMonitorDataCNWeights、usp_UpdateMonitorDataPruduct07RiskFactor 之後執行。
-- TODO：CAL_TO_USD_AMT／CAL_TO_USD_LIMIT 的實際計算公式待補（依 WEIGHTS/RISKFACTOR
--   套用規則），目前僅建立 SP 骨架與欄位落地位置，SET 子句先寫成 no-op。
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[usp_UpdateMonitorDataCalculatedUsdAmount](@EXT_DATE AS DATE)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		UPDATE M
		SET
			-- TODO: 套用 WEIGHTS/RISKFACTOR 的計算公式，例如：
			CAL_TO_USD_AMT = isnull(M.TO_USD_AMT,0)  * (isnull(M.RISKFACTOR,100)/100),
			-- TODO: 套用 WEIGHTS/RISKFACTOR 的計算公式
			CAL_TO_USD_LIMIT = isnull(M.TO_USD_LIMIT,0) * (isnull(M.RISKFACTOR,100)/100)
		FROM MONITORDATA_STAGE M
		WHERE M.EXT_DATE = @EXT_DATE;
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
		PRINT '發生錯誤: ' + @ErrorMsg;
		THROW;
	END CATCH
END
GO



