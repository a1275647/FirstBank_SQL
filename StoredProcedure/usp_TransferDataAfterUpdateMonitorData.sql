SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		AllenChen
-- Create date: 2025/10/17
-- Description:	Update MonitorData

-- =============================================
Create PROCEDURE [dbo].[usp_TransferAfterUpdateMonitorData] @EXT_DATE AS DATE
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		IF @EXT_DATE IS NULL
			THROW 50000, '@EXT_DATE 為空值', 1;
		
		--Declare @EXT_DATE Date = '2026-09-01';
		exec usp_UpdateMonitorDataUnit @EXT_DATE -- 單位 與 年月週
		exec usp_UpdateMonitorDataCNWeights @EXT_DATE -- 中國加權
		exec usp_UpdateMonitorDataPruduct07RiskFactor @EXT_DATE -- 衍生性商品風險係數
		exec usp_UpdateMonitorDataFPEXR_RateUSD @EXT_DATE -- 匯率 與 換算美金
		exec usp_UpdateMonitorDataCalculatedUsdAmount @EXT_DATE -- 計算後美金
		exec usp_UpdateMonitorDataLimit @EXT_DATE -- 額度到期日到期的按照餘額
		exec usp_UpdateMonitorDataIndustry @EXT_DATE -- 行業別更新

	END TRY
	BEGIN CATCH
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT '發生錯誤: ' + @ErrorMsg;
		THROW;
	END CATCH

END
GO


