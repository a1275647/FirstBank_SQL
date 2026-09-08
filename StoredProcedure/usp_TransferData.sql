SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		AllenChen
-- Create date: 2025/10/17
-- Description:	轉檔流程呼叫入口

-- =============================================
ALTER PROCEDURE [dbo].[usp_TransferData] @EXT_DATE AS DATE
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		IF @EXT_DATE IS NULL
			THROW 50000, '@EXT_DATE 為空值', 1;
		Delete MONITORDATA
		Where DATADATE = @EXT_DATE
		-- DW 資料轉檔
		exec usp_Souce01_OBBS_By_OS_LNSMSTD_D_MF @EXT_DATE -- 交易檔
		exec usp_Souce01_OBBS_By_OSBDKF02_MF @EXT_DATE -- 交易檔
		exec usp_Souce01_OBBS_By_OSFXKF02_MF @EXT_DATE -- 交易檔
		exec usp_Souce01_OBBS_By_OSISKF02_MF @EXT_DATE -- 交易檔
		exec usp_Souce01_OBBS_By_OSMMKF02_MF @EXT_DATE -- 交易檔
		exec usp_Souce04_By_LS_LSRSA_D_MF_ACNOD_STG @EXT_DATE  -- 交易檔
		exec usp_Souce06_By_FL_FLMST_D_MF @EXT_DATE  -- 交易檔
		exec usp_Souce09_By_ARS_SUKBDO_D_MF @EXT_DATE -- 交易檔
		exec usp_Souce09_By_ARS_SUKFRA_D_MF @EXT_DATE -- 交易檔
		exec usp_Souce09_By_ARS_SUKIRO_D_MF @EXT_DATE -- 交易檔
		exec usp_Souce09_By_ARS_SUKMST_D_MF @EXT_DATE -- 交易檔
		exec usp_Souce09_By_ARS_SUKNBD1_D_MF @EXT_DATE -- 交易檔
		exec usp_Souce09_By_ARS_SUKNFO_D_MF @EXT_DATE -- 交易檔
		exec usp_Souce09_By_ARS_SUKNFX_D_MF @EXT_DATE -- 交易檔
		exec usp_Souce09_By_ARS_SUKNIRS_D_MF @EXT_DATE -- 交易檔
		exec usp_Souce09_By_ARS_SUKNMM_D_MF @EXT_DATE -- 交易檔
		exec usp_Souce09_By_ARS_SUKSWP_D_MF @EXT_DATE -- 交易檔
		exec usp_Souce01_OBBS_By_OS_LNSLMSD_D_MF -- 額度檔

	END TRY
	BEGIN CATCH
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT '發生錯誤: ' + @ErrorMsg;
		THROW;
	END CATCH

END
GO



