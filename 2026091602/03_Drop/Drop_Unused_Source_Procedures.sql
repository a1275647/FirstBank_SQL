-- =============================================
-- 移除已不再被 usp_TransferData 呼叫、仍直接寫正式表 MONITORDATA 的舊來源 SP，
-- 避免日後誤呼叫繞過暫存表流程。可重複執行。
--   usp_Souce01_OBBS_By_OS_LNSMSTD_D_MF_OS_LNSLMSD_D_MF：已拆成 LNSMSTD／LNSLMSD 兩支
--   usp_Souce04_By_LS_LSRSA_D_MF_ACNOD_STG：ACNOD_STG 合併改由 C# 端處理，改呼叫 usp_Souce04_By_LS_LSRSA_D_MF
-- =============================================
DROP PROCEDURE IF EXISTS [dbo].[usp_Souce01_OBBS_By_OS_LNSMSTD_D_MF_OS_LNSLMSD_D_MF];
GO
DROP PROCEDURE IF EXISTS [dbo].[usp_Souce04_By_LS_LSRSA_D_MF_ACNOD_STG];
GO
