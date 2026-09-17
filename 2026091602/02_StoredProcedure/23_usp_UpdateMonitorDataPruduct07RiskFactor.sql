SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Allen
-- Create date: 20250923
-- Description:	將MonitorData指定轉入日期 and 產品類別為 07 衍伸性金融商品
--				根據到期日與轉檔日得出剩餘天數 與 風險類型 取得風險係數，Update 交易額度與核准額度
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[usp_UpdateMonitorDataPruduct07RiskFactor](@EXT_DATE AS DATE)
AS
BEGIN
	SET NOCOUNT ON;
    BEGIN TRY
		UPDATE MONITORDATA_STAGE
		SET RISKFACTOR = dbo.ufn_FinancialRiskFactor(DATEDIFF(DAY, @EXT_DATE, MATURITY_DATE),
			PRODUCT_CODE,CUR_BOUGHT,CUR_SOLD)
		WHERE EXT_DATE = @EXT_DATE AND PRODUCT_TYPE = '07';
	END TRY
    BEGIN CATCH
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT '發生錯誤: ' + @ErrorMsg;
        THROW;
    END CATCH
END
--SELECT
--	pm.FK_GlobalID_FinancialProductCategory,
--    G.Name_TN,
--    PM.ProductTypeName,
--    PM.ProductCode,
--	RFD.FK_ProductID,
--	RFD.FK_PeriodID,
--    PD.PeriodName,
--    PD.MinDays,
--    PD.MaxDays,
--    RFD.RiskFactor
--FROM FinancialRiskFactorData RFD
--INNER JOIN FinancialProductMaster PM ON RFD.FK_ProductID = PM.PK_ID
--INNER JOIN Global G ON PM.FK_GlobalID_FinancialProductCategory = G.Id
--INNER JOIN FinancialRiskFactorPeriodDay PD ON RFD.FK_PeriodID = PD.PK_ID
----ORDER BY PM.PK_ID

--SELECT
--    G.Name_TN AS ProductCategory,
--    PM.ProductTypeName,
--    PM.ProductCode,
--    [1] AS 'Days_2',
--    [2] AS 'Days_7',
--    [3] AS 'Days_30',
--    [4] AS 'Days_31_60',
--    [5] AS 'Days_61_91',
--    [6] AS 'Days_92_182',
--    [7] AS 'Days_183_270',
--    [8] AS 'Days_271_365',
--    [9] AS 'Days_366_456',
--    [10] AS 'Days_457_547',
--    [11] AS 'Days_548_635',
--    [12] AS 'Days_636_730',
--    [13] AS 'Days_731_1095',
--    [14] AS 'Days_1096_1825',
--    [15] AS 'Days_1826_2555',
--    [16] AS 'Days_2556_3650',
--    [17] AS 'Days_3651_5475',
--    [18] AS 'Days_5476_7300',
--    [19] AS 'Days_7301_9131',
--    [20] AS 'Days_9132_10958'
--FROM (
--    SELECT
--        G.Name_TN,
--        PM.ProductTypeName,
--        PM.ProductCode,
--        PM.PK_ID,
--        RFD.FK_PeriodID,
--        RFD.RiskFactor
--    FROM FinancialRiskFactorData RFD
--    INNER JOIN FinancialProductMaster PM ON RFD.FK_ProductID = PM.PK_ID
--    INNER JOIN Global G ON PM.FK_GlobalID_FinancialProductCategory = G.Id
--) AS SourceTable
--PIVOT (
--    MAX(RiskFactor)
--    FOR FK_PeriodID IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20])
--) AS PivotTable
--INNER JOIN FinancialProductMaster PM ON PivotTable.PK_ID = PM.PK_ID
--INNER JOIN Global G ON PM.FK_GlobalID_FinancialProductCategory = G.Id
--ORDER BY PM.PK_ID;
GO
