SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		AllenChen
-- Create date: 2025/10/17
-- Description:	轉檔流程呼叫入口
--   2026/09/16 改為寫入 MONITORDATA_STAGE（暫存表），正式表 MONITORDATA 由
--              usp_MonitorData_Publish 在所有來源都完成後以短交易一次換入，
--              避免長時間鎖住正式表影響前端查詢。
--   參數：
--     @EXT_DATE        轉檔日期
--     @RetentionDays   STAGE 保留天數；開頭會清掉 EXT_DATE 早於 (@EXT_DATE - @RetentionDays) 的暫存資料，
--                      預設 7 天，留幾天供事後對照，避免暫存表無限長大
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[usp_TransferData]
	@EXT_DATE AS DATE,
	@RetentionDays INT = 7
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		IF @EXT_DATE IS NULL
			THROW 50000, '@EXT_DATE 為空值', 1;
		IF @RetentionDays IS NULL OR @RetentionDays < 0
			SET @RetentionDays = 7;

		-- 清掉本次日期在暫存表的舊資料（重跑時不會累積），以及超過保留天數的歷史暫存資料
		DELETE MONITORDATA_STAGE
		WHERE EXT_DATE = @EXT_DATE
		   OR EXT_DATE < DATEADD(DAY, -@RetentionDays, @EXT_DATE);

		-- DW 資料轉檔（以下 SP 皆寫入 MONITORDATA_STAGE）
		exec usp_Souce01_OBBS_By_OS_LNSMSTD_D_MF @EXT_DATE -- 交易檔
		exec usp_Souce01_OBBS_By_OSBDKF02_MF @EXT_DATE -- 交易檔
		exec usp_Souce01_OBBS_By_OSFXKF02_MF @EXT_DATE -- 交易檔
		exec usp_Souce01_OBBS_By_OSISKF02_MF @EXT_DATE -- 交易檔
		exec usp_Souce01_OBBS_By_OSMMKF02_MF @EXT_DATE -- 交易檔
		exec usp_Souce04_By_LS_LSRSA_D_MF @EXT_DATE  -- 交易檔
		exec usp_Souce06_By_FL_FLMST_D_MF @EXT_DATE  -- 交易檔
		exec usp_Souce09_By_ARS_SUKBD2_D_MF @EXT_DATE -- 交易檔
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
		exec usp_Souce01_OBBS_By_OS_LNSLMSD_D_MF @EXT_DATE -- 額度檔
		exec usp_Souce06_By_FM_FMLINE_D_MF @EXT_DATE  -- 額度檔

	END TRY
	BEGIN CATCH
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT '發生錯誤: ' + @ErrorMsg;
		THROW;
	END CATCH

END
GO
