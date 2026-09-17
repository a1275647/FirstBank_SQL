SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Allen
-- Create date: 20250923
-- Description:	將指定轉入日期的MonitorData Update WEIGHTS 中國權重
-- =============================================
CREATE PROCEDURE [dbo].[usp_UpdateMonitorDataCNWeights](@EXT_DATE AS DATE)
AS
BEGIN
	SET NOCOUNT ON;
    BEGIN TRY
		-- 指定客戶名稱，且中國交易國的中國權重為0
		-- 建立表格變數存放要排除的客戶
		DECLARE @ExcludedCustomers TABLE (
			CustomerName NVARCHAR(255)
		);
		-- 插入要排除的客戶名稱
		INSERT INTO @ExcludedCustomers (CustomerName) VALUES
			('BOC_CNT'),
			('CCB_TPDBU'),
			('BKCOMM_TPE'),
			('BOC_TPE_DBU'),
			('BANK OF CHINA LTD. TAIPEI'),
			('CHINA CONSTRUCTION BK CORP. TAIPEI'),
			('BANK OF COMMUNICATIONS, TAIPEI'),
			('BANK OF CHINA LIMITED TAIPEI BRANCH');
		-- 中國風險加權計算方式
		-- 1. 指定客戶 為 0
		-- 2. 產品別 04、09 且到期日天數 小於 92 為 20（其他產品別不適用短天期減權）
		-- 3. 其餘 100
		UPDATE M SET WEIGHTS = CASE WHEN EXISTS (
											SELECT 1
											FROM @ExcludedCustomers e
											WHERE e.CustomerName = M.CUSTOMER_NAME
										) THEN '0'
									WHEN M.PRODUCT_TYPE IN ('04','09')
										 AND DATEDIFF(DAY,@EXT_DATE,M.MATURITY_DATE) < 92 THEN 20
									ELSE 100 END
		FROM MONITORDATA_STAGE M
		WHERE M.EXT_DATE = @EXT_DATE AND COUNTRY_COD = 'CN'
	END TRY
    BEGIN CATCH
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT '發生錯誤: ' + @ErrorMsg;
        THROW;
    END CATCH
END
GO
