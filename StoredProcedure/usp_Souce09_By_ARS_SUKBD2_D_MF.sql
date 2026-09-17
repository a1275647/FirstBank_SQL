SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		AllenChen
-- Create date: 2025/10/17
-- Description:	09SUKBD2附買回之資料擷取 交易最大日期
-- =============================================
Alter PROCEDURE [dbo].[usp_Souce09_By_ARS_SUKBD2_D_MF] @EXT_DATE DATE
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY

		--Declare @EXT_DATE Date = '2026-09-01';
		Declare @BufferDate INT = 14;

        INSERT INTO MONITORDATA_STAGE (
            BRANCH_NO, UNIT_NO, PRODUCT_TYPE, TRAN_NO, GROUP_NO, TX_DATE,
            CUSTOMER_NAME, CUSTOMER_ID, COUNTRY_COD, CURENCY_COD, TRAN_AMOUNT,
            PERMIT_NO, LIMIT, LIMIT_COD, MATURITY_DATE, AS_OF_DATE, FIL9,
            SOURCE, CREATOR, LIMIT_MATURITY, EXT_DATE)
        SELECT
            TRIM(MF.SUKBD2_BRANCH_NO)                                           AS BRANCH_NO,
            --TRIM(MF.SUKBD2_ACC_BRANCH_NO)                                       AS UNIT_NO,
			TRIM(MF.SUKBD2_BRANCH_NO)                                       AS UNIT_NO,
            '07'                                                                 AS PRODUCT_TYPE,
            TRIM(MF.SUKBD2_TRADE_NO)                                            AS TRAN_NO,
            '016'                                                                AS GROUP_NO,
            MF.SUKBD2_TRADE_DAY                                                 AS TX_DATE,
            TRIM(MF.SUKBD2_ISSUER_ID)                                           AS CUSTOMER_NAME,
            TRIM(MF.SUKBD2_ISSUER_APPID)                                        AS CUSTOMER_ID,
            TRIM(MF.SUKBD2_ISSUER_COUNTRY)                                      AS COUNTRY_COD,
            TRIM(MF.SUKBD2_REPO_CCY)                                            AS CURENCY_COD,
            MF.SUKBD2_REPO_AMOUNT                                                AS TRAN_AMOUNT,
            NULL                                                                 AS PERMIT_NO,
            MF.SUKBD2_REPO_AMOUNT                                                AS [LIMIT],
            NULL                                                                 AS LIMIT_COD,
            MF.SUKBD2_END_DATE                                                   AS MATURITY_DATE,
            MF.SUKBD2_EXT_DATE                                                   AS AS_OF_DATE,
            'ARS_SUKBD2_D_MF'                                                   AS FIL9,
            '09'                                                                 AS SOURCE,
            'system'                                                             AS CREATOR,
            MF.SUKBD2_END_DATE                                                   AS LIMIT_MATURITY,
            --TRIM(MF.BUSINS_CODE)                                                 AS INDUSTRY,
            --1                                                                    AS INDUSTRY_Type,
            @EXT_DATE                                                            AS EXT_DATE
        FROM ARS_SUKBD2_D_MF MF
        WHERE MF.SUKBD2_EXT_DATE = (
                SELECT MAX(SUKBD2_EXT_DATE)
                FROM ARS_SUKBD2_D_MF
                WHERE SUKBD2_EXT_DATE <= @EXT_DATE
              ) AND
              MF.SUKBD2_TRADE_TYPE <> 'RP' AND
              TRIM(MF.SUKBD2_ISSUER_COUNTRY) <> 'TW' AND
			  (MF.SUKBD2_END_DATE is null or DATEADD(DAY,@BufferDate,MF.SUKBD2_END_DATE) >= @EXT_DATE)

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT '發生錯誤: ' + @ErrorMsg;
        THROW;
    END CATCH
END
GO
