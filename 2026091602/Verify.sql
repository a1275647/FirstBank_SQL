SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
-- =============================================================
-- 2026091602 部署後驗證（唯讀，可在 UAT / 正式機重複執行）
-- 預期：每一段的 Result 都是 OK
-- =============================================================

-- 1. 暫存表存在
SELECT N'1.MONITORDATA_STAGE 存在' AS Item,
       CASE WHEN OBJECT_ID(N'[dbo].[MONITORDATA_STAGE]', N'U') IS NOT NULL THEN N'OK' ELSE N'FAIL' END AS Result;

-- 2. 正式表每個欄位暫存表都有（缺欄位會列出名稱）
SELECT N'2.欄位一致' AS Item,
       CASE WHEN missing.names IS NULL THEN N'OK' ELSE N'FAIL: ' + missing.names END AS Result
FROM (SELECT STUFF((
        SELECT N', ' + m.name
        FROM sys.columns m
        WHERE m.object_id = OBJECT_ID(N'[dbo].[MONITORDATA]')
          AND NOT EXISTS (SELECT 1 FROM sys.columns s
                          WHERE s.object_id = OBJECT_ID(N'[dbo].[MONITORDATA_STAGE]') AND s.name = m.name)
        FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, N'') AS names) missing;

-- 3. 暫存表索引
SELECT N'3.IX_MONITORDATA_STAGE_EXTDATE_SOURCE' AS Item,
       CASE WHEN EXISTS (SELECT 1 FROM sys.indexes
                         WHERE object_id = OBJECT_ID(N'[dbo].[MONITORDATA_STAGE]')
                           AND name = N'IX_MONITORDATA_STAGE_EXTDATE_SOURCE') THEN N'OK' ELSE N'FAIL' END AS Result;

-- 4. 新 SP 存在
SELECT N'4.usp_MonitorData_Publish 存在' AS Item,
       CASE WHEN OBJECT_ID(N'[dbo].[usp_MonitorData_Publish]', N'P') IS NOT NULL THEN N'OK' ELSE N'FAIL' END AS Result;

-- 5. 轉檔相關 SP 已改寫暫存表：以下 27 支的定義內不應再有直接寫正式表的語句
;WITH target AS (
    SELECT name FROM (VALUES
        (N'usp_Souce01_OBBS_By_OS_LNSMSTD_D_MF'), (N'usp_Souce01_OBBS_By_OSBDKF02_MF'),
        (N'usp_Souce01_OBBS_By_OSFXKF02_MF'),    (N'usp_Souce01_OBBS_By_OSISKF02_MF'),
        (N'usp_Souce01_OBBS_By_OSMMKF02_MF'),    (N'usp_Souce04_By_LS_LSRSA_D_MF'),
        (N'usp_Souce06_By_FL_FLMST_D_MF'),       (N'usp_Souce06_By_FM_FMLINE_D_MF'),
        (N'usp_Souce09_By_ARS_SUKBD2_D_MF'),     (N'usp_Souce09_By_ARS_SUKBDO_D_MF'),
        (N'usp_Souce09_By_ARS_SUKFRA_D_MF'),     (N'usp_Souce09_By_ARS_SUKIRO_D_MF'),
        (N'usp_Souce09_By_ARS_SUKMST_D_MF'),     (N'usp_Souce09_By_ARS_SUKNBD1_D_MF'),
        (N'usp_Souce09_By_ARS_SUKNFO_D_MF'),     (N'usp_Souce09_By_ARS_SUKNFX_D_MF'),
        (N'usp_Souce09_By_ARS_SUKNIRS_D_MF'),    (N'usp_Souce09_By_ARS_SUKNMM_D_MF'),
        (N'usp_Souce09_By_ARS_SUKSWP_D_MF'),     (N'usp_Souce01_OBBS_By_OS_LNSLMSD_D_MF'),
        (N'usp_UpdateMonitorDataUnit'),          (N'usp_UpdateMonitorDataCNWeights'),
        (N'usp_UpdateMonitorDataPruduct07RiskFactor'), (N'usp_UpdateMonitorDataFPEXR_RateUSD'),
        (N'usp_UpdateMonitorDataCalculatedUsdAmount'), (N'usp_UpdateMonitorDataLimit'),
        (N'usp_UpdateMonitorDataIndustry')
    ) v(name)
), checkresult AS (
    SELECT t.name,
           CASE
             WHEN p.object_id IS NULL THEN N'MISSING'
             -- 先把 MONITORDATA_STAGE 換掉，再看剩下有沒有直接寫正式表的語句。
             -- 只比對程式碼的寫法（INSERT INTO MonitorData (、FROM MONITORDATA <別名>、UPDATE MONITORDATA 換行/SET），
             -- 避免被 SP 檔頭的說明註解（例如「Update MonitorData 行業別更新」）誤判。DB 定序為 CI，不分大小寫。
             WHEN REPLACE(sm.definition, N'MONITORDATA_STAGE', N'') LIKE N'%INSERT INTO MONITORDATA%(%'
               OR REPLACE(sm.definition, N'MONITORDATA_STAGE', N'') LIKE N'%FROM MONITORDATA M%'
               OR REPLACE(sm.definition, N'MONITORDATA_STAGE', N'') LIKE N'%FROM MONITORDATA A%'
               OR REPLACE(sm.definition, N'MONITORDATA_STAGE', N'') LIKE N'%UPDATE MONITORDATA' + CHAR(13) + N'%'
               OR REPLACE(sm.definition, N'MONITORDATA_STAGE', N'') LIKE N'%UPDATE MONITORDATA' + CHAR(10) + N'%'
               OR REPLACE(sm.definition, N'MONITORDATA_STAGE', N'') LIKE N'%UPDATE MONITORDATA SET%'
                  THEN N'STILL WRITES MONITORDATA'
             ELSE N'OK'
           END AS Result
    FROM target t
    LEFT JOIN sys.procedures p ON p.name = t.name
    LEFT JOIN sys.sql_modules sm ON sm.object_id = p.object_id
)
SELECT N'5.' + name AS Item, Result FROM checkresult ORDER BY Result, name;

-- 6. usp_TransferData 已有 @RetentionDays 參數（代表是新版）
SELECT N'6.usp_TransferData 新版' AS Item,
       CASE WHEN EXISTS (SELECT 1 FROM sys.parameters
                         WHERE object_id = OBJECT_ID(N'[dbo].[usp_TransferData]') AND name = N'@RetentionDays')
            THEN N'OK' ELSE N'FAIL' END AS Result;

-- 7. 2 支未使用的舊 SP 已移除
SELECT N'7.舊 SP 已移除' AS Item,
       CASE WHEN EXISTS (SELECT 1 FROM sys.procedures
                         WHERE name IN (N'usp_Souce01_OBBS_By_OS_LNSMSTD_D_MF_OS_LNSLMSD_D_MF',
                                        N'usp_Souce04_By_LS_LSRSA_D_MF_ACNOD_STG'))
            THEN N'FAIL' ELSE N'OK' END AS Result;

-- 8. ARS_SUKBD2_D_MF 具備 Entity 需要的 13 個欄位（缺的會列出）
SELECT N'8.ARS_SUKBD2_D_MF 欄位' AS Item,
       CASE WHEN missing.names IS NULL THEN N'OK' ELSE N'FAIL: ' + missing.names END AS Result
FROM (SELECT STUFF((
        SELECT N', ' + v.name
        FROM (VALUES (N'SUKBD2_BRANCH_NO'), (N'SUKBD2_TRADE_NO'), (N'SUKBD2_TRADE_TYPE'), (N'SUKBD2_TRADE_DAY'),
                     (N'SUKBD2_END_DATE'), (N'SUKBD2_REPO_CCY'), (N'SUKBD2_REPO_AMOUNT'), (N'SUKBD2_ISSUER_ID'),
                     (N'SUKBD2_ISSUER_APPID'), (N'SUKBD2_ISSUER_COUNTRY'), (N'SUKBD2_EXT_DATE'),
                     (N'Create_date'), (N'Create_user')) v(name)
        WHERE COL_LENGTH(N'dbo.ARS_SUKBD2_D_MF', v.name) IS NULL
        FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, N'') AS names) missing;

-- 8a. ARS_SUKBD2_D_MF 日期欄位型別（Entity 是 DateOnly，應為 date；不是的話要人工調整）
SELECT N'8a.ARS_SUKBD2_D_MF 日期型別' AS Item,
       CASE WHEN (SELECT COUNT(*) FROM sys.columns c JOIN sys.types t ON t.user_type_id = c.user_type_id
                  WHERE c.object_id = OBJECT_ID(N'[dbo].[ARS_SUKBD2_D_MF]')
                    AND c.name IN (N'SUKBD2_TRADE_DAY', N'SUKBD2_END_DATE', N'SUKBD2_EXT_DATE')
                    AND t.name = N'date') = 3 THEN N'OK' ELSE N'FAIL' END AS Result;

-- 9. 應用程式帳號權限（把 <AppUser> 換成 TransferDataAPI 連線用的 DB 使用者後執行）
-- SELECT N'9.權限' AS Item, p.permission_name, p.state_desc, o.name
-- FROM sys.database_permissions p
-- JOIN sys.objects o ON o.object_id = p.major_id
-- WHERE USER_NAME(p.grantee_principal_id) = N'<AppUser>'
--   AND o.name IN (N'MONITORDATA_STAGE', N'ARS_SUKBD2_D_MF', N'usp_MonitorData_Publish', N'usp_TransferData');
