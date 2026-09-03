-- PHASE 1 OF 2: TABLE SCHEMA
-- SSMS ready-to-run instructions:
--   1. Connect to the intended production SQL Server.
--   2. Open this complete file in a normal SSMS query window (SQLCMD Mode is not required).
--   3. Press F5 without selecting only part of this file.
--   4. Run 02_DropCreateProgrammableObjects.sql only after this script prints PHASE 1 COMPLETED.
-- No script edits are required. This file performs a destructive table-schema rebuild of database NCRMS.
USE [NCRMS];
GO
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO
DECLARE @PreflightError nvarchar(2048) = NULL;

IF DB_NAME() <> N'NCRMS'
    SET @PreflightError = N'Target database mismatch. Expected NCRMS but connected to ' + QUOTENAME(DB_NAME()) + N'.';

IF @PreflightError IS NULL
BEGIN
    IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
        PRINT N'NCRMS_TAB is unavailable; table and clustered-index DDL will use PRIMARY.';
    ELSE
        PRINT N'NCRMS_TAB is available; table and clustered-index DDL will use NCRMS_TAB.';

    IF FILEGROUP_ID(N'NCRMS_IDX') IS NULL
        PRINT N'NCRMS_IDX is unavailable; nonclustered-index DDL will use PRIMARY.';
    ELSE
        PRINT N'NCRMS_IDX is available; nonclustered-index DDL will use NCRMS_IDX.';
END;

IF @PreflightError IS NOT NULL
BEGIN
    PRINT N'DEPLOYMENT HALTED: ' + @PreflightError;
    SET NOEXEC ON;
END;
GO

-- Deployment-driver permission model:
--   * Requires DDL rights for the target database objects.
--   * Uses NCRMS_TAB/NCRMS_IDX when present and falls back to PRIMARY when either is absent.
--   * Does not INSERT, UPDATE, DELETE, or SELECT rows from application tables.
--   * DML text inside procedure/trigger definitions is compiled only and is not executed here.
-- Preconditions:
--   * The target database contains no data that must be retained.
--   * An FK from a non-target table into a deployment target must be removed separately; deployment halts before DROP TABLE.
BEGIN TRANSACTION;
GO

-- Discover the target database's current FK names instead of relying on exported constraint names.
-- Only FKs whose referencing and referenced tables are both rebuilt by this deployment are removed.
-- An external table referencing a deployment target halts the deployment so its FK is not silently lost.
DECLARE @ManagedForeignKeyCount int = 0;
DECLARE @ExternalInboundForeignKeyCount int = 0;
DECLARE @DropManagedForeignKeysSql nvarchar(max) = NULL;
DECLARE @ExternalInboundForeignKeys nvarchar(max) = NULL;

-- Dynamic FK cleanup target list begins.
;WITH TargetTableNames AS
(
    SELECT target.SchemaName, target.TableName
    FROM (VALUES
        (N'dbo', N'UserToken'),
        (N'dbo', N'UserTextLibrary'),
        (N'dbo', N'Users_log'),
        (N'dbo', N'TitleMapping'),
        (N'dbo', N'Title'),
        (N'dbo', N'TempModifyRecord'),
        (N'dbo', N'SysLog'),
        (N'dbo', N'SysData'),
        (N'dbo', N'ScheduleJobs_temp'),
        (N'dbo', N'ScheduleJobs_RECORD'),
        (N'dbo', N'ScheduleJobs_his'),
        (N'dbo', N'ScheduleJobs'),
        (N'dbo', N'RPAFileMapping_temp'),
        (N'dbo', N'RPAFileMapping_his'),
        (N'dbo', N'RPAFileMapping'),
        (N'dbo', N'RPACountryType_temp'),
        (N'dbo', N'RPACountryType_his'),
        (N'dbo', N'RPACountryType'),
        (N'dbo', N'RPA_Views'),
        (N'dbo', N'RPA_temp'),
        (N'dbo', N'RPA_Source'),
        (N'dbo', N'RPA_his'),
        (N'dbo', N'Role_User_Mapping_his'),
        (N'dbo', N'Role_User_Mapping'),
        (N'dbo', N'Role_Position_Mapping_his'),
        (N'dbo', N'Role_Position_Mapping'),
        (N'dbo', N'RiskLineO'),
        (N'dbo', N'RiskLineD'),
        (N'dbo', N'RatingRatioMasterBase'),
        (N'dbo', N'RatingRatioMaster_Week'),
        (N'dbo', N'RatingRatioMaster_temp'),
        (N'dbo', N'RatingRatioMaster_his'),
        (N'dbo', N'RatingRatioMaster'),
        (N'dbo', N'QuotaBank_Weight_Week'),
        (N'dbo', N'QuotaBank_Weight_temp'),
        (N'dbo', N'QuotaBank_Weight_his'),
        (N'dbo', N'QuotaBank_Weight_Form_AllData'),
        (N'dbo', N'QuotaBank_Weight'),
        (N'dbo', N'QuotaBank_M_Week'),
        (N'dbo', N'QuotaBank_M'),
        (N'dbo', N'QuotaBank_Form_ParentWeight'),
        (N'dbo', N'QuotaBank_Form_Data'),
        (N'dbo', N'QuotaBank_D_Week'),
        (N'dbo', N'QuotaBank_D'),
        (N'dbo', N'QuickLink'),
        (N'dbo', N'ProductMaster'),
        (N'dbo', N'PostFileMapping_temp'),
        (N'dbo', N'PostFileMapping_his'),
        (N'dbo', N'PostFileMapping'),
        (N'dbo', N'PostCountryType_temp'),
        (N'dbo', N'PostCountryType_his'),
        (N'dbo', N'PostCountryType'),
        (N'dbo', N'Post_Views'),
        (N'dbo', N'Post_temp'),
        (N'dbo', N'Post_his'),
        (N'dbo', N'Permissions_Query_his'),
        (N'dbo', N'Permissions_Query'),
        (N'dbo', N'Permissions_his'),
        (N'dbo', N'Permissions'),
        (N'dbo', N'OSMMKF02_MF'),
        (N'dbo', N'OSISKF02_MF'),
        (N'dbo', N'OSFXKF02_MF'),
        (N'dbo', N'OSBDKF02_MF'),
        (N'dbo', N'OS_LNSSECD_D_MF'),
        (N'dbo', N'OS_LNSMSTD_D_MF'),
        (N'dbo', N'OS_LNSLNKD_D_MF'),
        (N'dbo', N'OS_LNSLMSD_D_MF'),
        (N'dbo', N'OldData_Rating'),
        (N'dbo', N'OldData_QuotaWeight'),
        (N'dbo', N'OldData_Quota'),
        (N'dbo', N'NoticeUser'),
        (N'dbo', N'NewsFileMapping_temp'),
        (N'dbo', N'NewsFileMapping_his'),
        (N'dbo', N'NewsFileMapping'),
        (N'dbo', N'NewsCountryType_temp'),
        (N'dbo', N'NewsCountryType_his'),
        (N'dbo', N'NewsCountryType'),
        (N'dbo', N'News_Views'),
        (N'dbo', N'News_temp'),
        (N'dbo', N'News_his'),
        (N'dbo', N'MONITORDATA_temp'),
        (N'dbo', N'MONITORDATA_his'),
        (N'dbo', N'MONITORDATA'),
        (N'dbo', N'MIS_CRCY_REF'),
        (N'dbo', N'MailToMapping_temp'),
        (N'dbo', N'MailToMapping_his'),
        (N'dbo', N'MailToMapping'),
        (N'dbo', N'MailLog_Mapping'),
        (N'dbo', N'MailLog_GroupMapping'),
        (N'dbo', N'MailLog_FileMapping'),
        (N'dbo', N'MailLog_CustomMapping'),
        (N'dbo', N'MailLog_CcMapping'),
        (N'dbo', N'MailLog_CcGroupMapping'),
        (N'dbo', N'MailLog_CcCustomMapping'),
        (N'dbo', N'MailGroupUser'),
        (N'dbo', N'MailGroupMapping_temp'),
        (N'dbo', N'MailGroupMapping_his'),
        (N'dbo', N'MailGroupMapping'),
        (N'dbo', N'MailGroupCcMapping_temp'),
        (N'dbo', N'MailGroupCcMapping_his'),
        (N'dbo', N'MailGroupCcMapping'),
        (N'dbo', N'MailCustomToMapping_temp'),
        (N'dbo', N'MailCustomToMapping_his'),
        (N'dbo', N'MailCustomToMapping'),
        (N'dbo', N'MailCustomCcMapping_temp'),
        (N'dbo', N'MailCustomCcMapping_his'),
        (N'dbo', N'MailCustomCcMapping'),
        (N'dbo', N'MailCcMapping_temp'),
        (N'dbo', N'MailCcMapping_his'),
        (N'dbo', N'MailCcMapping'),
        (N'dbo', N'Mail_his'),
        (N'dbo', N'LS_LSRSA_D_MF'),
        (N'dbo', N'LoanMainUnitData'),
        (N'dbo', N'LoanExtApp'),
        (N'dbo', N'LoanBranchApproveAmountHis'),
        (N'dbo', N'LoanApprovalEntry'),
        (N'dbo', N'INDUSTRY_Overseas'),
        (N'dbo', N'INDUSTRY_Internal'),
        (N'dbo', N'INDUSTRY'),
        (N'dbo', N'i18nText'),
        (N'dbo', N'HRIS_Origin'),
        (N'dbo', N'GroupIdCounter'),
        (N'dbo', N'FPEXR_STG'),
        (N'dbo', N'ForexRate'),
        (N'dbo', N'FM_FMLINE_D_MF'),
        (N'dbo', N'FlowUserReset'),
        (N'dbo', N'FlowModifyRecord'),
        (N'dbo', N'FlowFileMapping'),
        (N'dbo', N'FL_FLMST_D_MF'),
        (N'dbo', N'FinancialRiskFactorPeriodDay_temp'),
        (N'dbo', N'FinancialRiskFactorPeriodDay_his'),
        (N'dbo', N'FinancialRiskFactorData_temp'),
        (N'dbo', N'FinancialRiskFactorData_his'),
        (N'dbo', N'FinancialRiskFactorData'),
        (N'dbo', N'FinancialProductMaster_temp'),
        (N'dbo', N'FinancialProductMaster_his'),
        (N'dbo', N'FileCenter_Downloads'),
        (N'dbo', N'ExcelTemplate'),
        (N'dbo', N'DAILY_CIF_TMP'),
        (N'dbo', N'Customer_temp'),
        (N'dbo', N'Customer_his'),
        (N'dbo', N'Customer'),
        (N'dbo', N'CreditRating_Token'),
        (N'dbo', N'CreditRating_ScoreMapping_temp'),
        (N'dbo', N'CreditRating_ScoreMapping_his'),
        (N'dbo', N'CreditRating_ScoreMapping'),
        (N'dbo', N'CreditRating_LEI'),
        (N'dbo', N'CreditRating_ErrorLEI'),
        (N'dbo', N'CreditRating_ErrorISIN'),
        (N'dbo', N'CreditRating_ErrorCountry'),
        (N'dbo', N'CreditRating_CountryId'),
        (N'dbo', N'CreditRating_Country_M'),
        (N'dbo', N'CreditRating_Country_Log_Detail'),
        (N'dbo', N'CreditRating_Country_Log'),
        (N'dbo', N'CreditRating_Country_Current'),
        (N'dbo', N'CreditRating_Country'),
        (N'dbo', N'CreditRating_CountBmi'),
        (N'dbo', N'CreditRating_CountApi'),
        (N'dbo', N'CreditRating_BmiRule'),
        (N'dbo', N'CreditRating_Bmi'),
        (N'dbo', N'CreditRating_AllBmi'),
        (N'dbo', N'CountryWeightPercent'),
        (N'dbo', N'CountryOutlookReport_Views'),
        (N'dbo', N'CountryOutlookReport_temp'),
        (N'dbo', N'CountryOutlookReport_Source'),
        (N'dbo', N'CountryOutlookReport_his'),
        (N'dbo', N'CountryMaster_temp'),
        (N'dbo', N'CountryMaster_his'),
        (N'dbo', N'CountryForexRateMapping'),
        (N'dbo', N'CountryFocus_temp'),
        (N'dbo', N'CountryFocus_his'),
        (N'dbo', N'CountryFocus'),
        (N'dbo', N'CountryExceptionBankGroup_temp'),
        (N'dbo', N'CountryExceptionBankGroup_his'),
        (N'dbo', N'CountryExceptionBankGroup'),
        (N'dbo', N'CountryException_his'),
        (N'dbo', N'ContinentMaster_his'),
        (N'dbo', N'ContinentCountry_temp'),
        (N'dbo', N'ContinentCountry_his'),
        (N'dbo', N'ContinentCountry'),
        (N'dbo', N'CDS'),
        (N'dbo', N'BankYearNeWorthBase_Week'),
        (N'dbo', N'BankYearNeWorthBase_his'),
        (N'dbo', N'BankYearNeWorthBase'),
        (N'dbo', N'BankUnit'),
        (N'dbo', N'BankGroup'),
        (N'dbo', N'BankBranch_temp'),
        (N'dbo', N'BankBranch_his'),
        (N'dbo', N'BankBranch'),
        (N'dbo', N'ARS_SUKSWP_D_MF'),
        (N'dbo', N'ARS_SUKNMM_D_MF'),
        (N'dbo', N'ARS_SUKNIRS_D_MF'),
        (N'dbo', N'ARS_SUKNFX_D_MF'),
        (N'dbo', N'ARS_SUKNFO_D_MF'),
        (N'dbo', N'ARS_SUKNBD1_D_MF'),
        (N'dbo', N'ARS_SUKMST_D_MF'),
        (N'dbo', N'ARS_SUKIRO_D_MF'),
        (N'dbo', N'ARS_SUKFRA_D_MF'),
        (N'dbo', N'ARS_SUKBDO_D_MF'),
        (N'dbo', N'ACOLRT_STG'),
        (N'dbo', N'ACNOD_STG'),
        (N'dbo', N'Users'),
        (N'dbo', N'RPA'),
        (N'dbo', N'Role_his'),
        (N'dbo', N'Role'),
        (N'dbo', N'QuotaBank_D_temp'),
        (N'dbo', N'QuotaBank_D_his'),
        (N'dbo', N'QuotaBank_D_Form_AllData'),
        (N'dbo', N'Post'),
        (N'dbo', N'Notice'),
        (N'dbo', N'News'),
        (N'dbo', N'MailLog'),
        (N'dbo', N'MailGroup'),
        (N'dbo', N'Mail_temp'),
        (N'dbo', N'Mail'),
        (N'dbo', N'LoanBranchData'),
        (N'dbo', N'Global'),
        (N'dbo', N'FlowRecord'),
        (N'dbo', N'FinancialRiskFactorPeriodDay'),
        (N'dbo', N'FinancialProductMaster'),
        (N'dbo', N'FileCenter'),
        (N'dbo', N'FeatureDetail'),
        (N'dbo', N'CreditRatingMaster'),
        (N'dbo', N'CountryOutlookReport'),
        (N'dbo', N'CountryMaster'),
        (N'dbo', N'CountryException_temp'),
        (N'dbo', N'CountryException'),
        (N'dbo', N'ContinentMaster_temp'),
        (N'dbo', N'BankYearNeWorthBase_temp'),
        (N'dbo', N'QuotaBank_M_temp'),
        (N'dbo', N'QuotaBank_M_his'),
        (N'dbo', N'QuotaBank_M_Form_AllData'),
        (N'dbo', N'FlowForm_LoanMain'),
        (N'dbo', N'FlowDetail'),
        (N'dbo', N'ContinentMaster'),
        (N'dbo', N'FlowForm'),
        (N'dbo', N'Flow'),
        (N'dbo', N'Menu')
    ) AS target (SchemaName, TableName)
)
-- Dynamic FK cleanup target list ends.
, TargetTables AS
(
    SELECT table_object.object_id
    FROM TargetTableNames AS target
    INNER JOIN sys.schemas AS table_schema
        ON table_schema.name = target.SchemaName
    INNER JOIN sys.tables AS table_object
        ON table_object.schema_id = table_schema.schema_id
       AND table_object.name = target.TableName
)
, InboundForeignKeys AS
(
    SELECT
        fk.name AS ForeignKeyName,
        referencing_schema.name AS ReferencingSchemaName,
        referencing_table.name AS ReferencingTableName,
        CASE WHEN referencing_target.object_id IS NULL THEN 0 ELSE 1 END AS IsManagedRelationship
    FROM sys.foreign_keys AS fk
    INNER JOIN TargetTables AS referenced_target
        ON referenced_target.object_id = fk.referenced_object_id
    INNER JOIN sys.tables AS referencing_table
        ON referencing_table.object_id = fk.parent_object_id
    INNER JOIN sys.schemas AS referencing_schema
        ON referencing_schema.schema_id = referencing_table.schema_id
    LEFT JOIN TargetTables AS referencing_target
        ON referencing_target.object_id = fk.parent_object_id
)
SELECT
    @ManagedForeignKeyCount = COALESCE(SUM(CASE WHEN IsManagedRelationship = 1 THEN 1 ELSE 0 END), 0),
    @ExternalInboundForeignKeyCount = COALESCE(SUM(CASE WHEN IsManagedRelationship = 0 THEN 1 ELSE 0 END), 0),
    @DropManagedForeignKeysSql = STRING_AGG(
        CASE WHEN IsManagedRelationship = 1 THEN
            CONVERT(nvarchar(max),
                N'ALTER TABLE ' + QUOTENAME(ReferencingSchemaName) + N'.' + QUOTENAME(ReferencingTableName) +
                N' DROP CONSTRAINT ' + QUOTENAME(ForeignKeyName) + N';')
        END,
        NCHAR(13) + NCHAR(10)),
    @ExternalInboundForeignKeys = STRING_AGG(
        CASE WHEN IsManagedRelationship = 0 THEN
            CONVERT(nvarchar(max),
                QUOTENAME(ReferencingSchemaName) + N'.' + QUOTENAME(ReferencingTableName) +
                N'.' + QUOTENAME(ForeignKeyName))
        END,
        N', ')
FROM InboundForeignKeys;

IF @ExternalInboundForeignKeyCount > 0
BEGIN
    PRINT N'DEPLOYMENT HALTED: ' + CONVERT(nvarchar(20), @ExternalInboundForeignKeyCount) +
        N' external foreign key(s) reference deployment target tables: ' +
        COALESCE(@ExternalInboundForeignKeys, N'(metadata unavailable)');
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    SET NOEXEC ON;
END
ELSE IF @ManagedForeignKeyCount > 0
BEGIN
    PRINT N'Dropping ' + CONVERT(nvarchar(20), @ManagedForeignKeyCount) +
        N' managed foreign key(s) discovered from sys.foreign_keys.';
    EXEC sys.sp_executesql @DropManagedForeignKeysSql;
END
ELSE
BEGIN
    PRINT N'No managed foreign keys were discovered for the existing deployment target tables.';
END;
GO
DROP TABLE IF EXISTS [dbo].[UserToken];
GO
DROP TABLE IF EXISTS [dbo].[UserTextLibrary];
GO
DROP TABLE IF EXISTS [dbo].[Users_log];
GO
DROP TABLE IF EXISTS [dbo].[TitleMapping];
GO
DROP TABLE IF EXISTS [dbo].[Title];
GO
DROP TABLE IF EXISTS [dbo].[TempModifyRecord];
GO
DROP TABLE IF EXISTS [dbo].[SysLog];
GO
DROP TABLE IF EXISTS [dbo].[SysData];
GO
DROP TABLE IF EXISTS [dbo].[ScheduleJobs_temp];
GO
DROP TABLE IF EXISTS [dbo].[ScheduleJobs_RECORD];
GO
DROP TABLE IF EXISTS [dbo].[ScheduleJobs_his];
GO
DROP TABLE IF EXISTS [dbo].[ScheduleJobs];
GO
DROP TABLE IF EXISTS [dbo].[RPAFileMapping_temp];
GO
DROP TABLE IF EXISTS [dbo].[RPAFileMapping_his];
GO
DROP TABLE IF EXISTS [dbo].[RPAFileMapping];
GO
DROP TABLE IF EXISTS [dbo].[RPACountryType_temp];
GO
DROP TABLE IF EXISTS [dbo].[RPACountryType_his];
GO
DROP TABLE IF EXISTS [dbo].[RPACountryType];
GO
DROP TABLE IF EXISTS [dbo].[RPA_Views];
GO
DROP TABLE IF EXISTS [dbo].[RPA_temp];
GO
DROP TABLE IF EXISTS [dbo].[RPA_Source];
GO
DROP TABLE IF EXISTS [dbo].[RPA_his];
GO
DROP TABLE IF EXISTS [dbo].[Role_User_Mapping_his];
GO
DROP TABLE IF EXISTS [dbo].[Role_User_Mapping];
GO
DROP TABLE IF EXISTS [dbo].[Role_Position_Mapping_his];
GO
DROP TABLE IF EXISTS [dbo].[Role_Position_Mapping];
GO
DROP TABLE IF EXISTS [dbo].[RiskLineO];
GO
DROP TABLE IF EXISTS [dbo].[RiskLineD];
GO
DROP TABLE IF EXISTS [dbo].[RatingRatioMasterBase];
GO
DROP TABLE IF EXISTS [dbo].[RatingRatioMaster_Week];
GO
DROP TABLE IF EXISTS [dbo].[RatingRatioMaster_temp];
GO
DROP TABLE IF EXISTS [dbo].[RatingRatioMaster_his];
GO
DROP TABLE IF EXISTS [dbo].[RatingRatioMaster];
GO
DROP TABLE IF EXISTS [dbo].[QuotaBank_Weight_Week];
GO
DROP TABLE IF EXISTS [dbo].[QuotaBank_Weight_temp];
GO
DROP TABLE IF EXISTS [dbo].[QuotaBank_Weight_his];
GO
DROP TABLE IF EXISTS [dbo].[QuotaBank_Weight_Form_AllData];
GO
DROP TABLE IF EXISTS [dbo].[QuotaBank_Weight];
GO
DROP TABLE IF EXISTS [dbo].[QuotaBank_M_Week];
GO
DROP TABLE IF EXISTS [dbo].[QuotaBank_M];
GO
DROP TABLE IF EXISTS [dbo].[QuotaBank_Form_ParentWeight];
GO
DROP TABLE IF EXISTS [dbo].[QuotaBank_Form_Data];
GO
DROP TABLE IF EXISTS [dbo].[QuotaBank_D_Week];
GO
DROP TABLE IF EXISTS [dbo].[QuotaBank_D];
GO
DROP TABLE IF EXISTS [dbo].[QuickLink];
GO
DROP TABLE IF EXISTS [dbo].[ProductMaster];
GO
DROP TABLE IF EXISTS [dbo].[PostFileMapping_temp];
GO
DROP TABLE IF EXISTS [dbo].[PostFileMapping_his];
GO
DROP TABLE IF EXISTS [dbo].[PostFileMapping];
GO
DROP TABLE IF EXISTS [dbo].[PostCountryType_temp];
GO
DROP TABLE IF EXISTS [dbo].[PostCountryType_his];
GO
DROP TABLE IF EXISTS [dbo].[PostCountryType];
GO
DROP TABLE IF EXISTS [dbo].[Post_Views];
GO
DROP TABLE IF EXISTS [dbo].[Post_temp];
GO
DROP TABLE IF EXISTS [dbo].[Post_his];
GO
DROP TABLE IF EXISTS [dbo].[Permissions_Query_his];
GO
DROP TABLE IF EXISTS [dbo].[Permissions_Query];
GO
DROP TABLE IF EXISTS [dbo].[Permissions_his];
GO
DROP TABLE IF EXISTS [dbo].[Permissions];
GO
DROP TABLE IF EXISTS [dbo].[OSMMKF02_MF];
GO
DROP TABLE IF EXISTS [dbo].[OSISKF02_MF];
GO
DROP TABLE IF EXISTS [dbo].[OSFXKF02_MF];
GO
DROP TABLE IF EXISTS [dbo].[OSBDKF02_MF];
GO
DROP TABLE IF EXISTS [dbo].[OS_LNSSECD_D_MF];
GO
DROP TABLE IF EXISTS [dbo].[OS_LNSMSTD_D_MF];
GO
DROP TABLE IF EXISTS [dbo].[OS_LNSLNKD_D_MF];
GO
DROP TABLE IF EXISTS [dbo].[OS_LNSLMSD_D_MF];
GO
DROP TABLE IF EXISTS [dbo].[OldData_Rating];
GO
DROP TABLE IF EXISTS [dbo].[OldData_QuotaWeight];
GO
DROP TABLE IF EXISTS [dbo].[OldData_Quota];
GO
DROP TABLE IF EXISTS [dbo].[NoticeUser];
GO
DROP TABLE IF EXISTS [dbo].[NewsFileMapping_temp];
GO
DROP TABLE IF EXISTS [dbo].[NewsFileMapping_his];
GO
DROP TABLE IF EXISTS [dbo].[NewsFileMapping];
GO
DROP TABLE IF EXISTS [dbo].[NewsCountryType_temp];
GO
DROP TABLE IF EXISTS [dbo].[NewsCountryType_his];
GO
DROP TABLE IF EXISTS [dbo].[NewsCountryType];
GO
DROP TABLE IF EXISTS [dbo].[News_Views];
GO
DROP TABLE IF EXISTS [dbo].[News_temp];
GO
DROP TABLE IF EXISTS [dbo].[News_his];
GO
DROP TABLE IF EXISTS [dbo].[MONITORDATA_temp];
GO
DROP TABLE IF EXISTS [dbo].[MONITORDATA_his];
GO
DROP TABLE IF EXISTS [dbo].[MONITORDATA];
GO
DROP TABLE IF EXISTS [dbo].[MIS_CRCY_REF];
GO
DROP TABLE IF EXISTS [dbo].[MailToMapping_temp];
GO
DROP TABLE IF EXISTS [dbo].[MailToMapping_his];
GO
DROP TABLE IF EXISTS [dbo].[MailToMapping];
GO
DROP TABLE IF EXISTS [dbo].[MailLog_Mapping];
GO
DROP TABLE IF EXISTS [dbo].[MailLog_GroupMapping];
GO
DROP TABLE IF EXISTS [dbo].[MailLog_FileMapping];
GO
DROP TABLE IF EXISTS [dbo].[MailLog_CustomMapping];
GO
DROP TABLE IF EXISTS [dbo].[MailLog_CcMapping];
GO
DROP TABLE IF EXISTS [dbo].[MailLog_CcGroupMapping];
GO
DROP TABLE IF EXISTS [dbo].[MailLog_CcCustomMapping];
GO
DROP TABLE IF EXISTS [dbo].[MailGroupUser];
GO
DROP TABLE IF EXISTS [dbo].[MailGroupMapping_temp];
GO
DROP TABLE IF EXISTS [dbo].[MailGroupMapping_his];
GO
DROP TABLE IF EXISTS [dbo].[MailGroupMapping];
GO
DROP TABLE IF EXISTS [dbo].[MailGroupCcMapping_temp];
GO
DROP TABLE IF EXISTS [dbo].[MailGroupCcMapping_his];
GO
DROP TABLE IF EXISTS [dbo].[MailGroupCcMapping];
GO
DROP TABLE IF EXISTS [dbo].[MailCustomToMapping_temp];
GO
DROP TABLE IF EXISTS [dbo].[MailCustomToMapping_his];
GO
DROP TABLE IF EXISTS [dbo].[MailCustomToMapping];
GO
DROP TABLE IF EXISTS [dbo].[MailCustomCcMapping_temp];
GO
DROP TABLE IF EXISTS [dbo].[MailCustomCcMapping_his];
GO
DROP TABLE IF EXISTS [dbo].[MailCustomCcMapping];
GO
DROP TABLE IF EXISTS [dbo].[MailCcMapping_temp];
GO
DROP TABLE IF EXISTS [dbo].[MailCcMapping_his];
GO
DROP TABLE IF EXISTS [dbo].[MailCcMapping];
GO
DROP TABLE IF EXISTS [dbo].[Mail_his];
GO
DROP TABLE IF EXISTS [dbo].[LS_LSRSA_D_MF];
GO
DROP TABLE IF EXISTS [dbo].[LoanMainUnitData];
GO
DROP TABLE IF EXISTS [dbo].[LoanExtApp];
GO
DROP TABLE IF EXISTS [dbo].[LoanBranchApproveAmountHis];
GO
DROP TABLE IF EXISTS [dbo].[LoanApprovalEntry];
GO
DROP TABLE IF EXISTS [dbo].[INDUSTRY_Overseas];
GO
DROP TABLE IF EXISTS [dbo].[INDUSTRY_Internal];
GO
DROP TABLE IF EXISTS [dbo].[INDUSTRY];
GO
DROP TABLE IF EXISTS [dbo].[i18nText];
GO
DROP TABLE IF EXISTS [dbo].[HRIS_Origin];
GO
DROP TABLE IF EXISTS [dbo].[GroupIdCounter];
GO
DROP TABLE IF EXISTS [dbo].[FPEXR_STG];
GO
DROP TABLE IF EXISTS [dbo].[ForexRate];
GO
DROP TABLE IF EXISTS [dbo].[FM_FMLINE_D_MF];
GO
DROP TABLE IF EXISTS [dbo].[FlowUserReset];
GO
DROP TABLE IF EXISTS [dbo].[FlowModifyRecord];
GO
DROP TABLE IF EXISTS [dbo].[FlowFileMapping];
GO
DROP TABLE IF EXISTS [dbo].[FL_FLMST_D_MF];
GO
DROP TABLE IF EXISTS [dbo].[FinancialRiskFactorPeriodDay_temp];
GO
DROP TABLE IF EXISTS [dbo].[FinancialRiskFactorPeriodDay_his];
GO
DROP TABLE IF EXISTS [dbo].[FinancialRiskFactorData_temp];
GO
DROP TABLE IF EXISTS [dbo].[FinancialRiskFactorData_his];
GO
DROP TABLE IF EXISTS [dbo].[FinancialRiskFactorData];
GO
DROP TABLE IF EXISTS [dbo].[FinancialProductMaster_temp];
GO
DROP TABLE IF EXISTS [dbo].[FinancialProductMaster_his];
GO
DROP TABLE IF EXISTS [dbo].[FileCenter_Downloads];
GO
DROP TABLE IF EXISTS [dbo].[ExcelTemplate];
GO
DROP TABLE IF EXISTS [dbo].[DAILY_CIF_TMP];
GO
DROP TABLE IF EXISTS [dbo].[Customer_temp];
GO
DROP TABLE IF EXISTS [dbo].[Customer_his];
GO
DROP TABLE IF EXISTS [dbo].[Customer];
GO
DROP TABLE IF EXISTS [dbo].[CreditRating_Token];
GO
DROP TABLE IF EXISTS [dbo].[CreditRating_ScoreMapping_temp];
GO
DROP TABLE IF EXISTS [dbo].[CreditRating_ScoreMapping_his];
GO
DROP TABLE IF EXISTS [dbo].[CreditRating_ScoreMapping];
GO
DROP TABLE IF EXISTS [dbo].[CreditRating_LEI];
GO
DROP TABLE IF EXISTS [dbo].[CreditRating_ErrorLEI];
GO
DROP TABLE IF EXISTS [dbo].[CreditRating_ErrorISIN];
GO
DROP TABLE IF EXISTS [dbo].[CreditRating_ErrorCountry];
GO
DROP TABLE IF EXISTS [dbo].[CreditRating_CountryId];
GO
DROP TABLE IF EXISTS [dbo].[CreditRating_Country_M];
GO
DROP TABLE IF EXISTS [dbo].[CreditRating_Country_Log_Detail];
GO
DROP TABLE IF EXISTS [dbo].[CreditRating_Country_Log];
GO
DROP TABLE IF EXISTS [dbo].[CreditRating_Country_Current];
GO
DROP TABLE IF EXISTS [dbo].[CreditRating_Country];
GO
DROP TABLE IF EXISTS [dbo].[CreditRating_CountBmi];
GO
DROP TABLE IF EXISTS [dbo].[CreditRating_CountApi];
GO
DROP TABLE IF EXISTS [dbo].[CreditRating_BmiRule];
GO
DROP TABLE IF EXISTS [dbo].[CreditRating_Bmi];
GO
DROP TABLE IF EXISTS [dbo].[CreditRating_AllBmi];
GO
DROP TABLE IF EXISTS [dbo].[CountryWeightPercent];
GO
DROP TABLE IF EXISTS [dbo].[CountryOutlookReport_Views];
GO
DROP TABLE IF EXISTS [dbo].[CountryOutlookReport_temp];
GO
DROP TABLE IF EXISTS [dbo].[CountryOutlookReport_Source];
GO
DROP TABLE IF EXISTS [dbo].[CountryOutlookReport_his];
GO
DROP TABLE IF EXISTS [dbo].[CountryMaster_temp];
GO
DROP TABLE IF EXISTS [dbo].[CountryMaster_his];
GO
DROP TABLE IF EXISTS [dbo].[CountryForexRateMapping];
GO
DROP TABLE IF EXISTS [dbo].[CountryFocus_temp];
GO
DROP TABLE IF EXISTS [dbo].[CountryFocus_his];
GO
DROP TABLE IF EXISTS [dbo].[CountryFocus];
GO
DROP TABLE IF EXISTS [dbo].[CountryExceptionBankGroup_temp];
GO
DROP TABLE IF EXISTS [dbo].[CountryExceptionBankGroup_his];
GO
DROP TABLE IF EXISTS [dbo].[CountryExceptionBankGroup];
GO
DROP TABLE IF EXISTS [dbo].[CountryException_his];
GO
DROP TABLE IF EXISTS [dbo].[ContinentMaster_his];
GO
DROP TABLE IF EXISTS [dbo].[ContinentCountry_temp];
GO
DROP TABLE IF EXISTS [dbo].[ContinentCountry_his];
GO
DROP TABLE IF EXISTS [dbo].[ContinentCountry];
GO
DROP TABLE IF EXISTS [dbo].[CDS];
GO
DROP TABLE IF EXISTS [dbo].[BankYearNeWorthBase_Week];
GO
DROP TABLE IF EXISTS [dbo].[BankYearNeWorthBase_his];
GO
DROP TABLE IF EXISTS [dbo].[BankYearNeWorthBase];
GO
DROP TABLE IF EXISTS [dbo].[BankUnit];
GO
DROP TABLE IF EXISTS [dbo].[BankGroup];
GO
DROP TABLE IF EXISTS [dbo].[BankBranch_temp];
GO
DROP TABLE IF EXISTS [dbo].[BankBranch_his];
GO
DROP TABLE IF EXISTS [dbo].[BankBranch];
GO
DROP TABLE IF EXISTS [dbo].[ARS_SUKSWP_D_MF];
GO
DROP TABLE IF EXISTS [dbo].[ARS_SUKNMM_D_MF];
GO
DROP TABLE IF EXISTS [dbo].[ARS_SUKNIRS_D_MF];
GO
DROP TABLE IF EXISTS [dbo].[ARS_SUKNFX_D_MF];
GO
DROP TABLE IF EXISTS [dbo].[ARS_SUKNFO_D_MF];
GO
DROP TABLE IF EXISTS [dbo].[ARS_SUKNBD1_D_MF];
GO
DROP TABLE IF EXISTS [dbo].[ARS_SUKMST_D_MF];
GO
DROP TABLE IF EXISTS [dbo].[ARS_SUKIRO_D_MF];
GO
DROP TABLE IF EXISTS [dbo].[ARS_SUKFRA_D_MF];
GO
DROP TABLE IF EXISTS [dbo].[ARS_SUKBDO_D_MF];
GO
DROP TABLE IF EXISTS [dbo].[ACOLRT_STG];
GO
DROP TABLE IF EXISTS [dbo].[ACNOD_STG];
GO
DROP TABLE IF EXISTS [dbo].[Users];
GO
DROP TABLE IF EXISTS [dbo].[RPA];
GO
DROP TABLE IF EXISTS [dbo].[Role_his];
GO
DROP TABLE IF EXISTS [dbo].[Role];
GO
DROP TABLE IF EXISTS [dbo].[QuotaBank_D_temp];
GO
DROP TABLE IF EXISTS [dbo].[QuotaBank_D_his];
GO
DROP TABLE IF EXISTS [dbo].[QuotaBank_D_Form_AllData];
GO
DROP TABLE IF EXISTS [dbo].[Post];
GO
DROP TABLE IF EXISTS [dbo].[Notice];
GO
DROP TABLE IF EXISTS [dbo].[News];
GO
DROP TABLE IF EXISTS [dbo].[MailLog];
GO
DROP TABLE IF EXISTS [dbo].[MailGroup];
GO
DROP TABLE IF EXISTS [dbo].[Mail_temp];
GO
DROP TABLE IF EXISTS [dbo].[Mail];
GO
DROP TABLE IF EXISTS [dbo].[LoanBranchData];
GO
DROP TABLE IF EXISTS [dbo].[Global];
GO
DROP TABLE IF EXISTS [dbo].[FlowRecord];
GO
DROP TABLE IF EXISTS [dbo].[FinancialRiskFactorPeriodDay];
GO
DROP TABLE IF EXISTS [dbo].[FinancialProductMaster];
GO
DROP TABLE IF EXISTS [dbo].[FileCenter];
GO
DROP TABLE IF EXISTS [dbo].[FeatureDetail];
GO
DROP TABLE IF EXISTS [dbo].[CreditRatingMaster];
GO
DROP TABLE IF EXISTS [dbo].[CountryOutlookReport];
GO
DROP TABLE IF EXISTS [dbo].[CountryMaster];
GO
DROP TABLE IF EXISTS [dbo].[CountryException_temp];
GO
DROP TABLE IF EXISTS [dbo].[CountryException];
GO
DROP TABLE IF EXISTS [dbo].[ContinentMaster_temp];
GO
DROP TABLE IF EXISTS [dbo].[BankYearNeWorthBase_temp];
GO
DROP TABLE IF EXISTS [dbo].[QuotaBank_M_temp];
GO
DROP TABLE IF EXISTS [dbo].[QuotaBank_M_his];
GO
DROP TABLE IF EXISTS [dbo].[QuotaBank_M_Form_AllData];
GO
DROP TABLE IF EXISTS [dbo].[FlowForm_LoanMain];
GO
DROP TABLE IF EXISTS [dbo].[FlowDetail];
GO
DROP TABLE IF EXISTS [dbo].[ContinentMaster];
GO
DROP TABLE IF EXISTS [dbo].[FlowForm];
GO
DROP TABLE IF EXISTS [dbo].[Flow];
GO
DROP TABLE IF EXISTS [dbo].[Menu];
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[ACNOD_STG](
	[ACNOD_BRANCH_CODE] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[ACNOD_CRCY_CODE] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[ACNOD_ACC5_CODE] [nvarchar](5) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[ACNOD_ACC5_SUB_CODE] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[ACNOD_OPER_DATE_BAL_INF] [decimal](17, 2) NULL,
	[ACNOD_LAST_BAL_MARK] [nvarchar](1) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[ACNOD_EXT_DATE] [date] NULL,
	[Create_Date] [datetime] NOT NULL
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE NONCLUSTERED INDEX [IX_ACNOD_STG] ON [dbo].[ACNOD_STG]
(
	[ACNOD_EXT_DATE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
';
IF FILEGROUP_ID(N'NCRMS_IDX') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_IDX]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[ACNOD_STG] ADD  CONSTRAINT [DF_ACNOD_STG_Create_Date]  DEFAULT (getdate()) FOR [Create_Date]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'帳務行' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ACNOD_STG', @level2type=N'COLUMN',@level2name=N'ACNOD_BRANCH_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'幣別' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ACNOD_STG', @level2type=N'COLUMN',@level2name=N'ACNOD_CRCY_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'會計科目(5碼)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ACNOD_STG', @level2type=N'COLUMN',@level2name=N'ACNOD_ACC5_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'會計科目(5碼)-分戶代號' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ACNOD_STG', @level2type=N'COLUMN',@level2name=N'ACNOD_ACC5_SUB_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'餘額' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ACNOD_STG', @level2type=N'COLUMN',@level2name=N'ACNOD_OPER_DATE_BAL_INF'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'最後一筆餘額註記' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ACNOD_STG', @level2type=N'COLUMN',@level2name=N'ACNOD_LAST_BAL_MARK'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'資料日' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ACNOD_STG', @level2type=N'COLUMN',@level2name=N'ACNOD_EXT_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建置時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ACNOD_STG', @level2type=N'COLUMN',@level2name=N'Create_Date'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[ACOLRT_STG](
	[ACOLRT_DATE] [date] NULL,
	[ACOLRT_BRANCH] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[ACOLRT_CURENCY] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[ACOLRT_LOCAL_CURENCY] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[ACOLRT_RATE] [decimal](18, 10) NULL,
	[ACOLRT_EXT_DATE] [date] NULL,
	[ACOLRT_LOAD_DATE] [datetime] NULL,
	[Create_Date] [datetime] NOT NULL
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[ACOLRT_STG] ADD  CONSTRAINT [DF_ACOLRT_STG_Create_Date]  DEFAULT (getdate()) FOR [Create_Date]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建置時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ACOLRT_STG', @level2type=N'COLUMN',@level2name=N'Create_Date'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[ARS_SUKBDO_D_MF](
	[SUKBDO_BRANCH_NO] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKBDO_TX_DATE] [date] NULL,
	[SUKBDO_DESK] [nvarchar](12) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKBDO_CUSTOMER_ID] [nvarchar](11) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKBDO_CUST_NAME] [nvarchar](40) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKBDO_CPTY_COUNTRY] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKBDO_CPTY_COUNTRY_RISK] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKBDO_POSITIONID] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKBDO_BUY_SELL] [nvarchar](1) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKBDO_OPTIONEXPIRYDATE] [date] NULL,
	[SUKBDO_RISK_AMT] [decimal](17, 2) NULL,
	[SUKBDO_EXT_DATE] [date] NULL,
	[BUSINS_CODE] [nvarchar](7) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Create_date] [datetime] NOT NULL
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[ARS_SUKBDO_D_MF] ADD  CONSTRAINT [DF_ARS_SUKBDO_D_MF_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'分行代號' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKBDO_D_MF', @level2type=N'COLUMN',@level2name=N'SUKBDO_BRANCH_NO'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'交易員主管別' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKBDO_D_MF', @level2type=N'COLUMN',@level2name=N'SUKBDO_DESK'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'交易對手代號' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKBDO_D_MF', @level2type=N'COLUMN',@level2name=N'SUKBDO_CUSTOMER_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'交易對手名稱' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKBDO_D_MF', @level2type=N'COLUMN',@level2name=N'SUKBDO_CUST_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'交易對手國家別' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKBDO_D_MF', @level2type=N'COLUMN',@level2name=N'SUKBDO_CPTY_COUNTRY'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'國家代號' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKBDO_D_MF', @level2type=N'COLUMN',@level2name=N'SUKBDO_CPTY_COUNTRY_RISK'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'交易代號' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKBDO_D_MF', @level2type=N'COLUMN',@level2name=N'SUKBDO_POSITIONID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'選擇權買賣別' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKBDO_D_MF', @level2type=N'COLUMN',@level2name=N'SUKBDO_BUY_SELL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'選擇權到期日' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKBDO_D_MF', @level2type=N'COLUMN',@level2name=N'SUKBDO_OPTIONEXPIRYDATE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'本筆使用風險額度' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKBDO_D_MF', @level2type=N'COLUMN',@level2name=N'SUKBDO_RISK_AMT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'萃取日' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKBDO_D_MF', @level2type=N'COLUMN',@level2name=N'SUKBDO_EXT_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'產業別' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKBDO_D_MF', @level2type=N'COLUMN',@level2name=N'BUSINS_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建置時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKBDO_D_MF', @level2type=N'COLUMN',@level2name=N'Create_date'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[ARS_SUKFRA_D_MF](
	[SUKFRA_BRANCH_NO] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKFRA_TRADE_ID] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKFRA_SUPERVISOR] [nvarchar](12) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKFRA_CPTY_BUSINESS] [nvarchar](6) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKFRA_CUSTOMER_ID] [nvarchar](11) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKFRA_CUST_NAME2] [nvarchar](30) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKFRA_CPTY_COUNTRY] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKFRA_CPTY_COUNTRY_RISK] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKFRA_TRADE_DATE] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKFRA_MATURITY] [date] NULL,
	[SUKFRA_BUY_SELL] [nvarchar](1) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKFRA_CCY] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKFRA_RISK_AMT] [decimal](17, 2) NULL,
	[SUKFRA_EXT_DATE] [date] NULL,
	[BUSINS_CODE] [nvarchar](7) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Create_date] [datetime] NOT NULL
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[ARS_SUKFRA_D_MF] ADD  CONSTRAINT [DF_ARS_SUKFRA_D_MF_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'分行代號
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKFRA_D_MF', @level2type=N'COLUMN',@level2name=N'SUKFRA_BRANCH_NO'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'交易編號
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKFRA_D_MF', @level2type=N'COLUMN',@level2name=N'SUKFRA_TRADE_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'交易主管別' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKFRA_D_MF', @level2type=N'COLUMN',@level2name=N'SUKFRA_SUPERVISOR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'產業別' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKFRA_D_MF', @level2type=N'COLUMN',@level2name=N'SUKFRA_CPTY_BUSINESS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'客戶代號' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKFRA_D_MF', @level2type=N'COLUMN',@level2name=N'SUKFRA_CUSTOMER_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'客戶名稱2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKFRA_D_MF', @level2type=N'COLUMN',@level2name=N'SUKFRA_CUST_NAME2'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'SUKFRA_CPTY_COUNTRY' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKFRA_D_MF', @level2type=N'COLUMN',@level2name=N'SUKFRA_CPTY_COUNTRY'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'國家代號' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKFRA_D_MF', @level2type=N'COLUMN',@level2name=N'SUKFRA_CPTY_COUNTRY_RISK'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'訂約日' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKFRA_D_MF', @level2type=N'COLUMN',@level2name=N'SUKFRA_TRADE_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'到期日' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKFRA_D_MF', @level2type=N'COLUMN',@level2name=N'SUKFRA_MATURITY'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'買賣別' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKFRA_D_MF', @level2type=N'COLUMN',@level2name=N'SUKFRA_BUY_SELL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'本金幣別' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKFRA_D_MF', @level2type=N'COLUMN',@level2name=N'SUKFRA_CCY'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'SUKFRA_RISK_AMT' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKFRA_D_MF', @level2type=N'COLUMN',@level2name=N'SUKFRA_RISK_AMT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'SUKFRA_EXT_DATE' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKFRA_D_MF', @level2type=N'COLUMN',@level2name=N'SUKFRA_EXT_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建置時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKFRA_D_MF', @level2type=N'COLUMN',@level2name=N'Create_date'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[ARS_SUKIRO_D_MF](
	[SUKIRO_BRANCH_NO] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKIRO_TRADE_ID] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKIRO_SUPERVISOR] [nvarchar](12) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKIRO_CPTY_BUSINESS] [nvarchar](6) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKIRO_CUSTOMER_ID] [nvarchar](11) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKIRO_CUST_NAME2] [nvarchar](30) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKIRO_CPTY_COUNTRY_RISK] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKIRO_TRADE_DATE] [date] NULL,
	[SUKIRO_MATURITY_DATE] [date] NULL,
	[SUKIRO_BUY_SELL] [nvarchar](1) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKIRO_CCY] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKIRO_RISK_AMT] [decimal](17, 2) NULL,
	[SUKIRO_EXT_DATE] [date] NULL,
	[Create_date] [datetime] NOT NULL
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[ARS_SUKIRO_D_MF] ADD  CONSTRAINT [DF_ARS_SUKIRO_D_MF_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'分行代號' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKIRO_D_MF', @level2type=N'COLUMN',@level2name=N'SUKIRO_BRANCH_NO'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'交易代號' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKIRO_D_MF', @level2type=N'COLUMN',@level2name=N'SUKIRO_TRADE_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'交易主管別' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKIRO_D_MF', @level2type=N'COLUMN',@level2name=N'SUKIRO_SUPERVISOR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'交易對手行業別' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKIRO_D_MF', @level2type=N'COLUMN',@level2name=N'SUKIRO_CPTY_BUSINESS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'交易對手代號' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKIRO_D_MF', @level2type=N'COLUMN',@level2name=N'SUKIRO_CUSTOMER_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'客戶名稱2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKIRO_D_MF', @level2type=N'COLUMN',@level2name=N'SUKIRO_CUST_NAME2'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'國家代號' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKIRO_D_MF', @level2type=N'COLUMN',@level2name=N'SUKIRO_CPTY_COUNTRY_RISK'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'訂約日
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKIRO_D_MF', @level2type=N'COLUMN',@level2name=N'SUKIRO_TRADE_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'到期日' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKIRO_D_MF', @level2type=N'COLUMN',@level2name=N'SUKIRO_MATURITY_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'買賣別
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKIRO_D_MF', @level2type=N'COLUMN',@level2name=N'SUKIRO_BUY_SELL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'幣別' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKIRO_D_MF', @level2type=N'COLUMN',@level2name=N'SUKIRO_CCY'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'本筆使用風險額度' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKIRO_D_MF', @level2type=N'COLUMN',@level2name=N'SUKIRO_RISK_AMT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'萃取日' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKIRO_D_MF', @level2type=N'COLUMN',@level2name=N'SUKIRO_EXT_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建置時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKIRO_D_MF', @level2type=N'COLUMN',@level2name=N'Create_date'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[ARS_SUKMST_D_MF](
	[SUKMST_BRANCH_NO] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKMST_TRAN_NO] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKMST_SUPERVISOR] [nvarchar](12) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKMST_CPTY_BUSINESS] [nvarchar](6) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKMST_CUSTOMER_ID] [nvarchar](11) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKMST_CUST_NAME2] [nvarchar](30) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKMST_CPTY_COUNTRY_RISK] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKMST_TRADE_DATE] [date] NULL,
	[SUKMST_MATURITY] [date] NULL,
	[SUKMST_BUY_SELL] [nvarchar](1) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKMST_OUT_CCY] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKMST_RISK_AMT] [decimal](17, 2) NULL,
	[SUKMST_ESTIMATE_FX] [decimal](17, 2) NULL,
	[SUKMST_DEPOSIT_LINK] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKMST_EXT_DATE] [date] NULL,
	[Create_date] [datetime] NOT NULL
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[ARS_SUKMST_D_MF] ADD  CONSTRAINT [DF_ARS_SUKMST_D_MF_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'分行代號' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKMST_D_MF', @level2type=N'COLUMN',@level2name=N'SUKMST_BRANCH_NO'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'交易編號' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKMST_D_MF', @level2type=N'COLUMN',@level2name=N'SUKMST_TRAN_NO'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'交易主管別' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKMST_D_MF', @level2type=N'COLUMN',@level2name=N'SUKMST_SUPERVISOR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'交易對手行業別' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKMST_D_MF', @level2type=N'COLUMN',@level2name=N'SUKMST_CPTY_BUSINESS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'客戶代號' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKMST_D_MF', @level2type=N'COLUMN',@level2name=N'SUKMST_CUSTOMER_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'客戶名稱2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKMST_D_MF', @level2type=N'COLUMN',@level2name=N'SUKMST_CUST_NAME2'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'國家代號' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKMST_D_MF', @level2type=N'COLUMN',@level2name=N'SUKMST_CPTY_COUNTRY_RISK'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'訂約日' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKMST_D_MF', @level2type=N'COLUMN',@level2name=N'SUKMST_TRADE_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'到期日' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKMST_D_MF', @level2type=N'COLUMN',@level2name=N'SUKMST_MATURITY'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'選擇權買賣別' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKMST_D_MF', @level2type=N'COLUMN',@level2name=N'SUKMST_BUY_SELL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'換出利率幣別' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKMST_D_MF', @level2type=N'COLUMN',@level2name=N'SUKMST_OUT_CCY'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'本筆使用風險額度' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKMST_D_MF', @level2type=N'COLUMN',@level2name=N'SUKMST_RISK_AMT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'評估損益（local）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKMST_D_MF', @level2type=N'COLUMN',@level2name=N'SUKMST_ESTIMATE_FX'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'存款連結商品' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKMST_D_MF', @level2type=N'COLUMN',@level2name=N'SUKMST_DEPOSIT_LINK'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'萃取日' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKMST_D_MF', @level2type=N'COLUMN',@level2name=N'SUKMST_EXT_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建置時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKMST_D_MF', @level2type=N'COLUMN',@level2name=N'Create_date'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[ARS_SUKNBD1_D_MF](
	[SUKBD1_BRANCH_NO] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKBD1_TRAN_NO] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKBD1_TX_DATE] [date] NULL,
	[SUKBD1_SWIFT_ID] [nvarchar](11) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKBD1_CUST_NAME1] [nvarchar](40) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKBD1_MATURITY_DATE] [date] NULL,
	[SUKBD1_CURENCY_COD] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKBD1_BALANCE_AMT] [decimal](17, 2) NULL,
	[SUKBD1_LINE_PERMIT_NO] [nvarchar](13) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKBD1_SUPERVISOR] [nvarchar](12) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKBD1_ISSUER_BUSINESS] [nvarchar](6) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKBD1_ISSUER_COUNTRY] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKBD1_BUY_SELL] [nvarchar](1) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKBD1_SECURITY_TYPE] [nvarchar](9) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKBD1_SEC_SUB_TYPE] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKBD1_EXT_DATE] [date] NULL,
	[SUKBD1_GU_LOG_CTY] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Create_date] [datetime] NOT NULL
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[ARS_SUKNBD1_D_MF] ADD  CONSTRAINT [DF_ARS_SUKNBD1_D_MF_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建置時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKNBD1_D_MF', @level2type=N'COLUMN',@level2name=N'Create_date'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[ARS_SUKNFO_D_MF](
	[SUKFO_TRADE_ID] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKFO_CPTY_NAME] [nvarchar](40) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKFO_TRADE_DATE] [date] NULL,
	[SUKFO_TRAN_TYPE] [nvarchar](1) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKFO_TRAN_BUY] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKFO_TRAN_SELL] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKFO_OBJECT_CCY] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKFO_OBJECT_AMT] [decimal](17, 2) NULL,
	[SUKFO_VALUE_DATE0] [date] NULL,
	[SUKFO_TRADE] [nvarchar](1) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKFO_BANK_SWIFT_ID] [nvarchar](11) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKFO_ACC_BRANCH_NO] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKFO_PRAM_CCY] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKFO_SUPERVISOR] [nvarchar](12) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKFO_CPTY_BUSINESS] [nvarchar](6) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKFO_CPTY_COUNTRY_RISK] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKFO_EXT_DATE] [date] NULL,
	[Create_date] [datetime] NOT NULL
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[ARS_SUKNFO_D_MF] ADD  CONSTRAINT [DF_ARS_SUKNFO_D_MF_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建置時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKNFO_D_MF', @level2type=N'COLUMN',@level2name=N'Create_date'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[ARS_SUKNFX_D_MF](
	[SUKFX_BRANCH_NO] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKFX_TRAN_NO] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKFX_TX_DATE] [date] NULL,
	[SUKFX_TX_TYPE] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKFX_SUPERVISOR] [nvarchar](12) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKFX_CPTY_BUSINESS] [nvarchar](6) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKFX_CUSTOMER_ID] [nvarchar](11) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKFX_CUST_NAME1] [nvarchar](40) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKFX_CPTY_COUNTRY_RISK] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKFX_VALUE_DATE0] [date] NULL,
	[SUKFX_OBJECT_CCY] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKFX_OBJECT_AMT] [decimal](17, 2) NULL,
	[SUKFX_CUR_BOUGHT] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKFX_CUR_SOLD] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKFX_EXT_DATE] [date] NULL,
	[Create_date] [datetime] NOT NULL
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[ARS_SUKNFX_D_MF] ADD  CONSTRAINT [DF_ARS_SUKNFX_D_MF_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建置時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKNFX_D_MF', @level2type=N'COLUMN',@level2name=N'Create_date'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[ARS_SUKNIRS_D_MF](
	[SUKIRS_BRANCH_NO] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKIRS_TRAN_NO] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKIRS_TX_DATE] [date] NULL,
	[SUKIRS_TX_TYPE] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKIRS_SUPERVISOR] [nvarchar](12) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKIRS_CPTY_BUSINESS] [nvarchar](6) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKIRS_CUSTOMER_ID] [nvarchar](11) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKIRS_CUST_NAME1] [nvarchar](40) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKIRS_CPTY_COUNTRY_RISK] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKIRS_MATURITY] [date] NULL,
	[SUKIRS_IN_CCY] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKIRS_IN_AMT] [decimal](17, 2) NULL,
	[SUKIRS_DEPOSIT_LINK] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKIRS_EXT_DATE] [date] NULL,
	[Create_date] [datetime] NOT NULL
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[ARS_SUKNIRS_D_MF] ADD  CONSTRAINT [DF_ARS_SUKNIRS_D_MF_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建置時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKNIRS_D_MF', @level2type=N'COLUMN',@level2name=N'Create_date'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[ARS_SUKNMM_D_MF](
	[SUKMM_BRANCH_NO] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKMM_TRAN_NO] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKMM_TX_DATE] [date] NULL,
	[SUKMM_TRN_TYPE] [nvarchar](1) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKMM_SWIFT_ID] [nvarchar](11) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKMM_CUST_NAME1] [nvarchar](40) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKMM_CURENCY_COD] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKMM_TRAN_AMOUNT] [decimal](17, 2) NULL,
	[SUKMM_MATURITY_DATE] [date] NULL,
	[SUKMM_SUPERVISOR] [nvarchar](12) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKMM_COUNTRY_RISK] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKMM_CPTY_TYPE] [nvarchar](6) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKMM_EXT_DATE] [date] NULL,
	[Create_date] [datetime] NOT NULL
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[ARS_SUKNMM_D_MF] ADD  CONSTRAINT [DF_ARS_SUKNMM_D_MF_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建置時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKNMM_D_MF', @level2type=N'COLUMN',@level2name=N'Create_date'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[ARS_SUKSWP_D_MF](
	[SUKSWP_BRANCH_NO] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKSWP_TX_DATE] [date] NULL,
	[SUKSWP_SUPERVISOR] [nvarchar](12) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKSWP_CUSTOMER_ID] [nvarchar](11) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKSWP_CUST_NAME] [nvarchar](40) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKSWP_CPTY_COUNTRY_RISK] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKSWP_EXTERNAL_ID] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKSWP_BUY_SELL] [nvarchar](1) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKSWP_OPTIONEXPIRYDATE] [date] NULL,
	[SUKSWP_CPTY_BUSINESS] [nvarchar](6) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKSWP_CURRENCY] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SUKSWP_RISK_AMT] [decimal](17, 2) NULL,
	[SUKSWP_EXT_DATE] [date] NULL,
	[Create_date] [datetime] NOT NULL
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[ARS_SUKSWP_D_MF] ADD  CONSTRAINT [DF_ARS_SUKSWP_D_MF_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建置時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKSWP_D_MF', @level2type=N'COLUMN',@level2name=N'Create_date'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[BankBranch](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_BankUnit] [int] NULL,
	[BankCode] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[BankName_TN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[BankName_EN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[BankName_CN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[BankName_JP] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Latitude] [decimal](13, 10) NULL,
	[Longitude] [decimal](13, 10) NULL,
	[IsActive] [bit] NOT NULL,
	[IsSave] [bit] NOT NULL,
	[Memo] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[IsEmployed] [bit] NOT NULL,
 CONSTRAINT [PK_BankBranch] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB],
 CONSTRAINT [UQ__BankBran__93AE04F7B8522DBF] UNIQUE NONCLUSTERED
(
	[BankCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
IF FILEGROUP_ID(N'NCRMS_IDX') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_IDX]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[BankBranch] ADD  CONSTRAINT [DF_BankBranch_BankCode]  DEFAULT ('') FOR [BankCode]
GO
ALTER TABLE [dbo].[BankBranch] ADD  CONSTRAINT [DF_BankBranch_Name_EN]  DEFAULT ('') FOR [BankName_TN]
GO
ALTER TABLE [dbo].[BankBranch] ADD  CONSTRAINT [DF_BankBranch_Name_TN]  DEFAULT ('') FOR [BankName_EN]
GO
ALTER TABLE [dbo].[BankBranch] ADD  CONSTRAINT [DF_BankBranch_Name_CN]  DEFAULT ('') FOR [BankName_CN]
GO
ALTER TABLE [dbo].[BankBranch] ADD  CONSTRAINT [DF_BankBranch_Name_JP]  DEFAULT ('') FOR [BankName_JP]
GO
ALTER TABLE [dbo].[BankBranch] ADD  CONSTRAINT [DF_BankBranch_IsActicve]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[BankBranch] ADD  CONSTRAINT [DF_BankBranch_IsSave]  DEFAULT ((0)) FOR [IsSave]
GO
ALTER TABLE [dbo].[BankBranch] ADD  CONSTRAINT [DF_BankBranch_Memo]  DEFAULT ('') FOR [Memo]
GO
ALTER TABLE [dbo].[BankBranch] ADD  CONSTRAINT [DF_BankBranch_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[BankBranch] ADD  CONSTRAINT [DF_BankBranch_Update_user]  DEFAULT ('system') FOR [Update_user]
GO
ALTER TABLE [dbo].[BankBranch] ADD  CONSTRAINT [DF_BankBranch_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[BankBranch] ADD  CONSTRAINT [DF_BankBranch_Create_user]  DEFAULT ('system') FOR [Create_user]
GO
ALTER TABLE [dbo].[BankBranch] ADD  CONSTRAINT [DF__BankBranc__IsEmp__344A823B]  DEFAULT ((1)) FOR [IsEmployed]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'業務處關聯用' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankBranch', @level2type=N'COLUMN',@level2name=N'FK_BankUnit'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'分行代碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankBranch', @level2type=N'COLUMN',@level2name=N'BankCode'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'繁中' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankBranch', @level2type=N'COLUMN',@level2name=N'BankName_TN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'英' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankBranch', @level2type=N'COLUMN',@level2name=N'BankName_EN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'簡中' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankBranch', @level2type=N'COLUMN',@level2name=N'BankName_CN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'日' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankBranch', @level2type=N'COLUMN',@level2name=N'BankName_JP'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'經度' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankBranch', @level2type=N'COLUMN',@level2name=N'Latitude'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'緯度' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankBranch', @level2type=N'COLUMN',@level2name=N'Longitude'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'是否啟用' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankBranch', @level2type=N'COLUMN',@level2name=N'IsActive'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'是否為保留額度' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankBranch', @level2type=N'COLUMN',@level2name=N'IsSave'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'更新時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankBranch', @level2type=N'COLUMN',@level2name=N'Update_date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'更新者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankBranch', @level2type=N'COLUMN',@level2name=N'Update_user'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建置時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankBranch', @level2type=N'COLUMN',@level2name=N'Create_date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建置者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankBranch', @level2type=N'COLUMN',@level2name=N'Create_user'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[BankBranch_his](
	[Log_Id] [int] IDENTITY(1,1) NOT NULL,
	[LogType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[FlowFormId] [int] NOT NULL,
	[PK_Id] [int] NULL,
	[FK_BankUnit] [int] NULL,
	[BankCode] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[BankName_TN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[BankName_EN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[BankName_CN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[BankName_JP] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Latitude] [decimal](13, 10) NULL,
	[Longitude] [decimal](13, 10) NULL,
	[IsActive] [bit] NOT NULL,
	[IsSave] [bit] NOT NULL,
	[Memo] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_BankBranch_his] PRIMARY KEY CLUSTERED
(
	[Log_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[BankBranch_his] ADD  CONSTRAINT [DF_BankBranch_his_BankCode]  DEFAULT ('') FOR [BankCode]
GO
ALTER TABLE [dbo].[BankBranch_his] ADD  CONSTRAINT [DF_BankBranch_his_Name_EN]  DEFAULT ('') FOR [BankName_TN]
GO
ALTER TABLE [dbo].[BankBranch_his] ADD  CONSTRAINT [DF_BankBranch_his_Name_TN]  DEFAULT ('') FOR [BankName_EN]
GO
ALTER TABLE [dbo].[BankBranch_his] ADD  CONSTRAINT [DF_BankBranch_his_Name_CN]  DEFAULT ('') FOR [BankName_CN]
GO
ALTER TABLE [dbo].[BankBranch_his] ADD  CONSTRAINT [DF_BankBranch_his_Name_JP]  DEFAULT ('') FOR [BankName_JP]
GO
ALTER TABLE [dbo].[BankBranch_his] ADD  CONSTRAINT [DF_BankBranch_his_IsActicve]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[BankBranch_his] ADD  CONSTRAINT [DF_BankBranch_his_IsSave]  DEFAULT ((0)) FOR [IsSave]
GO
ALTER TABLE [dbo].[BankBranch_his] ADD  CONSTRAINT [DF_BankBranch_his_Memo]  DEFAULT ('') FOR [Memo]
GO
ALTER TABLE [dbo].[BankBranch_his] ADD  CONSTRAINT [DF_BankBranch_his_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[BankBranch_his] ADD  CONSTRAINT [DF_BankBranch_his_Update_user]  DEFAULT ('system') FOR [Update_user]
GO
ALTER TABLE [dbo].[BankBranch_his] ADD  CONSTRAINT [DF_BankBranch_his_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[BankBranch_his] ADD  CONSTRAINT [DF_BankBranch_his_Create_user]  DEFAULT ('system') FOR [Create_user]
GO
ALTER TABLE [dbo].[BankBranch_his] ADD  CONSTRAINT [DF_BankBranch_his_SysCreate_date]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'紀錄的狀態' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankBranch_his', @level2type=N'COLUMN',@level2name=N'LogType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'業務處關聯用' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankBranch_his', @level2type=N'COLUMN',@level2name=N'FK_BankUnit'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'分行代碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankBranch_his', @level2type=N'COLUMN',@level2name=N'BankCode'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'繁中' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankBranch_his', @level2type=N'COLUMN',@level2name=N'BankName_TN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'英' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankBranch_his', @level2type=N'COLUMN',@level2name=N'BankName_EN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'簡中' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankBranch_his', @level2type=N'COLUMN',@level2name=N'BankName_CN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'日' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankBranch_his', @level2type=N'COLUMN',@level2name=N'BankName_JP'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'經度' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankBranch_his', @level2type=N'COLUMN',@level2name=N'Latitude'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'緯度' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankBranch_his', @level2type=N'COLUMN',@level2name=N'Longitude'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'是否啟用' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankBranch_his', @level2type=N'COLUMN',@level2name=N'IsActive'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'是否為保留額度' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankBranch_his', @level2type=N'COLUMN',@level2name=N'IsSave'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'更新時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankBranch_his', @level2type=N'COLUMN',@level2name=N'Update_date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'更新者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankBranch_his', @level2type=N'COLUMN',@level2name=N'Update_user'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建置時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankBranch_his', @level2type=N'COLUMN',@level2name=N'Create_date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建置者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankBranch_his', @level2type=N'COLUMN',@level2name=N'Create_user'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[BankBranch_temp](
	[TempId] [int] IDENTITY(1,1) NOT NULL,
	[FlowFormId] [int] NULL,
	[ModifyType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[PK_Id] [int] NOT NULL,
	[FK_BankUnit] [int] NULL,
	[BankCode] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[BankName_TN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[BankName_EN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[BankName_CN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[BankName_JP] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Latitude] [decimal](13, 10) NULL,
	[Longitude] [decimal](13, 10) NULL,
	[IsActive] [bit] NOT NULL,
	[IsSave] [bit] NOT NULL,
	[Memo] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK__BankBran__06C703C149E1DA90] PRIMARY KEY CLUSTERED
(
	[TempId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[BankBranch_temp] ADD  CONSTRAINT [DF__BankBranc__BankC__0134F289]  DEFAULT ('') FOR [BankCode]
GO
ALTER TABLE [dbo].[BankBranch_temp] ADD  CONSTRAINT [DF__BankBranc__BankN__022916C2]  DEFAULT ('') FOR [BankName_TN]
GO
ALTER TABLE [dbo].[BankBranch_temp] ADD  CONSTRAINT [DF__BankBranc__BankN__031D3AFB]  DEFAULT ('') FOR [BankName_EN]
GO
ALTER TABLE [dbo].[BankBranch_temp] ADD  CONSTRAINT [DF__BankBranc__BankN__04115F34]  DEFAULT ('') FOR [BankName_CN]
GO
ALTER TABLE [dbo].[BankBranch_temp] ADD  CONSTRAINT [DF__BankBranc__BankN__0505836D]  DEFAULT ('') FOR [BankName_JP]
GO
ALTER TABLE [dbo].[BankBranch_temp] ADD  CONSTRAINT [DF__BankBranc__IsAct__05F9A7A6]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[BankBranch_temp] ADD  CONSTRAINT [DF__BankBranc__IsSav__06EDCBDF]  DEFAULT ((0)) FOR [IsSave]
GO
ALTER TABLE [dbo].[BankBranch_temp] ADD  CONSTRAINT [DF__BankBranch__Memo__07E1F018]  DEFAULT ('') FOR [Memo]
GO
ALTER TABLE [dbo].[BankBranch_temp] ADD  CONSTRAINT [DF__BankBranc__Updat__08D61451]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[BankBranch_temp] ADD  CONSTRAINT [DF__BankBranc__Updat__09CA388A]  DEFAULT ('system') FOR [Update_user]
GO
ALTER TABLE [dbo].[BankBranch_temp] ADD  CONSTRAINT [DF__BankBranc__Creat__0ABE5CC3]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[BankBranch_temp] ADD  CONSTRAINT [DF__BankBranc__Creat__0BB280FC]  DEFAULT ('system') FOR [Create_user]
GO
ALTER TABLE [dbo].[BankBranch_temp] ADD  CONSTRAINT [DF__BankBranc__SysCr__0CA6A535]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'暫存資料識別碼（流水號）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankBranch_temp', @level2type=N'COLUMN',@level2name=N'TempId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'流程表單識別碼（外鍵：FlowForm.PK_ID）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankBranch_temp', @level2type=N'COLUMN',@level2name=N'FlowFormId'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[BankGroup](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[GroupCode] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[GroupName_EN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[GroupName_TN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[GroupName_CN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[GroupName_JP] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[IsActive] [bit] NOT NULL,
	[IsBusinessUnit] [bit] NOT NULL,
	[Memo] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[IsEmployed] [bit] NOT NULL,
	[Seq] [int] NOT NULL,
 CONSTRAINT [PK_BankGroup] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB],
 CONSTRAINT [IX_BankGroup] UNIQUE NONCLUSTERED
(
	[GroupCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX],
 CONSTRAINT [UQ__BankGrou__3B97438087DD735B] UNIQUE NONCLUSTERED
(
	[GroupCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
IF FILEGROUP_ID(N'NCRMS_IDX') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_IDX]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[BankGroup] ADD  CONSTRAINT [DF_BankGroup_GroupCode]  DEFAULT ('') FOR [GroupCode]
GO
ALTER TABLE [dbo].[BankGroup] ADD  CONSTRAINT [DF_BankGroup_Name_EN]  DEFAULT ('') FOR [GroupName_EN]
GO
ALTER TABLE [dbo].[BankGroup] ADD  CONSTRAINT [DF_BankGroup_Name_TN]  DEFAULT ('') FOR [GroupName_TN]
GO
ALTER TABLE [dbo].[BankGroup] ADD  CONSTRAINT [DF_BankGroup_Name_CN]  DEFAULT ('') FOR [GroupName_CN]
GO
ALTER TABLE [dbo].[BankGroup] ADD  CONSTRAINT [DF_BankGroup_Name_JP]  DEFAULT ('') FOR [GroupName_JP]
GO
ALTER TABLE [dbo].[BankGroup] ADD  CONSTRAINT [DF_BankGroup_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[BankGroup] ADD  CONSTRAINT [DF_BankGroup_Memo]  DEFAULT ('') FOR [Memo]
GO
ALTER TABLE [dbo].[BankGroup] ADD  CONSTRAINT [DF_BankGroup_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[BankGroup] ADD  CONSTRAINT [DF_BankGroup_Update_user]  DEFAULT ('system') FOR [Update_user]
GO
ALTER TABLE [dbo].[BankGroup] ADD  CONSTRAINT [DF_BankGroup_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[BankGroup] ADD  CONSTRAINT [DF_BankGroup_Create_user]  DEFAULT ('system') FOR [Create_user]
GO
ALTER TABLE [dbo].[BankGroup] ADD  CONSTRAINT [DF__BankGroup__IsEmp__3079F157]  DEFAULT ((1)) FOR [IsEmployed]
GO
ALTER TABLE [dbo].[BankGroup] ADD  CONSTRAINT [DF_BankGroup_Seq]  DEFAULT ((99)) FOR [Seq]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'事業群代碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankGroup', @level2type=N'COLUMN',@level2name=N'GroupCode'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'英' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankGroup', @level2type=N'COLUMN',@level2name=N'GroupName_EN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'繁中' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankGroup', @level2type=N'COLUMN',@level2name=N'GroupName_TN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'簡中' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankGroup', @level2type=N'COLUMN',@level2name=N'GroupName_CN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'日' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankGroup', @level2type=N'COLUMN',@level2name=N'GroupName_JP'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'是否啟用' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankGroup', @level2type=N'COLUMN',@level2name=N'IsActive'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'是否為業務單位' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankGroup', @level2type=N'COLUMN',@level2name=N'IsBusinessUnit'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'更新時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankGroup', @level2type=N'COLUMN',@level2name=N'Update_date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'更新者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankGroup', @level2type=N'COLUMN',@level2name=N'Update_user'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建置時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankGroup', @level2type=N'COLUMN',@level2name=N'Create_date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建置者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankGroup', @level2type=N'COLUMN',@level2name=N'Create_user'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[BankUnit](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_BankGroup] [int] NOT NULL,
	[UnitCode] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[UnitName_EN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[UnitName_TN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[UnitName_CN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[UnitName_JP] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[IsMain] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[IsBusinessUnit] [bit] NULL,
	[IsSave] [bit] NOT NULL,
	[Memo] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[IsEmployed] [bit] NOT NULL,
	[Seq] [int] NOT NULL,
 CONSTRAINT [PK_BankUnit] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB],
 CONSTRAINT [UQ__BankUnit__0665E6D9CD3FA132] UNIQUE NONCLUSTERED
(
	[UnitCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
IF FILEGROUP_ID(N'NCRMS_IDX') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_IDX]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[BankUnit] ADD  CONSTRAINT [DF_BankUnit_FK_BankGroup]  DEFAULT ('') FOR [FK_BankGroup]
GO
ALTER TABLE [dbo].[BankUnit] ADD  CONSTRAINT [DF_BankUnit_UnitCode]  DEFAULT ('') FOR [UnitCode]
GO
ALTER TABLE [dbo].[BankUnit] ADD  CONSTRAINT [DF_BankUnit_Name_EN]  DEFAULT ('') FOR [UnitName_EN]
GO
ALTER TABLE [dbo].[BankUnit] ADD  CONSTRAINT [DF_BankUnit_Name_TN]  DEFAULT ('') FOR [UnitName_TN]
GO
ALTER TABLE [dbo].[BankUnit] ADD  CONSTRAINT [DF_BankUnit_Name_CN]  DEFAULT ('') FOR [UnitName_CN]
GO
ALTER TABLE [dbo].[BankUnit] ADD  CONSTRAINT [DF_BankUnit_Name_JP]  DEFAULT ('') FOR [UnitName_JP]
GO
ALTER TABLE [dbo].[BankUnit] ADD  CONSTRAINT [DF_BankUnit_IsMain]  DEFAULT ((0)) FOR [IsMain]
GO
ALTER TABLE [dbo].[BankUnit] ADD  CONSTRAINT [DF_BankUnit_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[BankUnit] ADD  CONSTRAINT [DF_BankUnit_IsSave]  DEFAULT ((0)) FOR [IsSave]
GO
ALTER TABLE [dbo].[BankUnit] ADD  CONSTRAINT [DF_BankUnit_Memo]  DEFAULT ('') FOR [Memo]
GO
ALTER TABLE [dbo].[BankUnit] ADD  CONSTRAINT [DF_BankUnit_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[BankUnit] ADD  CONSTRAINT [DF_BankUnit_Update_user]  DEFAULT ('system') FOR [Update_user]
GO
ALTER TABLE [dbo].[BankUnit] ADD  CONSTRAINT [DF_BankUnit_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[BankUnit] ADD  CONSTRAINT [DF_BankUnit_Create_user]  DEFAULT ('system') FOR [Create_user]
GO
ALTER TABLE [dbo].[BankUnit] ADD  CONSTRAINT [DF__BankUnit__IsEmpl__326239C9]  DEFAULT ((1)) FOR [IsEmployed]
GO
ALTER TABLE [dbo].[BankUnit] ADD  CONSTRAINT [DF_BankUnit_Seq]  DEFAULT ((99)) FOR [Seq]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'事業群關聯用' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankUnit', @level2type=N'COLUMN',@level2name=N'FK_BankGroup'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'處代碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankUnit', @level2type=N'COLUMN',@level2name=N'UnitCode'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'英' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankUnit', @level2type=N'COLUMN',@level2name=N'UnitName_EN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'繁中' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankUnit', @level2type=N'COLUMN',@level2name=N'UnitName_TN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'簡中' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankUnit', @level2type=N'COLUMN',@level2name=N'UnitName_CN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'日' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankUnit', @level2type=N'COLUMN',@level2name=N'UnitName_JP'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'事業群主要業管處' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankUnit', @level2type=N'COLUMN',@level2name=N'IsMain'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'是否啟用' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankUnit', @level2type=N'COLUMN',@level2name=N'IsActive'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'是否為業務單位' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankUnit', @level2type=N'COLUMN',@level2name=N'IsBusinessUnit'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'是否為保留額度' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankUnit', @level2type=N'COLUMN',@level2name=N'IsSave'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'更新時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankUnit', @level2type=N'COLUMN',@level2name=N'Update_date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'更新者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankUnit', @level2type=N'COLUMN',@level2name=N'Update_user'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建置時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankUnit', @level2type=N'COLUMN',@level2name=N'Create_date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建置者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankUnit', @level2type=N'COLUMN',@level2name=N'Create_user'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[BankYearNeWorthBase](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[Year] [int] NOT NULL,
	[NTDToUSDEXRate] [decimal](18, 4) NOT NULL,
	[NetWorthNTD] [decimal](18, 2) NOT NULL,
	[NetWorthUSD] [decimal](18, 2) NOT NULL,
	[TotalRiskRatio] [int] NOT NULL,
	[TotalNetWorthNTD] [decimal](18, 2) NOT NULL,
	[TotalNetWorthUSD] [decimal](18, 2) NOT NULL,
	[WarningPercent] [int] NOT NULL,
	[WarningAmountNTD] [decimal](18, 2) NOT NULL,
	[WarningAmountUSD] [decimal](18, 2) NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK__BankYear__F4A24B22679E0D0C] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB],
 CONSTRAINT [UQ__BankYear__D4BD60544D11DEBB] UNIQUE NONCLUSTERED
(
	[Year] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
IF FILEGROUP_ID(N'NCRMS_IDX') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_IDX]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[BankYearNeWorthBase] ADD  CONSTRAINT [DF_BankYearNeWorthBase_Year]  DEFAULT (datepart(year,getdate())) FOR [Year]
GO
ALTER TABLE [dbo].[BankYearNeWorthBase] ADD  CONSTRAINT [DF_BankYearNeWorthBase_NTDToUSDEXRate]  DEFAULT ((0)) FOR [NTDToUSDEXRate]
GO
ALTER TABLE [dbo].[BankYearNeWorthBase] ADD  CONSTRAINT [DF_BankYearNeWorthBase_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[BankYearNeWorthBase] ADD  CONSTRAINT [DF_BankYearNeWorthBase_Create_user]  DEFAULT ('') FOR [Create_user]
GO
ALTER TABLE [dbo].[BankYearNeWorthBase] ADD  CONSTRAINT [DF_BankYearNeWorthBase_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[BankYearNeWorthBase] ADD  CONSTRAINT [DF_BankYearNeWorthBase_Update_user]  DEFAULT ('') FOR [Update_user]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'年' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankYearNeWorthBase', @level2type=N'COLUMN',@level2name=N'Year'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'台幣與美金匯率' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankYearNeWorthBase', @level2type=N'COLUMN',@level2name=N'NTDToUSDEXRate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'全行淨值(台幣)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankYearNeWorthBase', @level2type=N'COLUMN',@level2name=N'NetWorthNTD'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'全行淨值(美金)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankYearNeWorthBase', @level2type=N'COLUMN',@level2name=N'NetWorthUSD'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'全行淨值倍率' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankYearNeWorthBase', @level2type=N'COLUMN',@level2name=N'TotalRiskRatio'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'全行風控總淨值(台幣)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankYearNeWorthBase', @level2type=N'COLUMN',@level2name=N'TotalNetWorthNTD'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'全行風控總淨值(美金)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankYearNeWorthBase', @level2type=N'COLUMN',@level2name=N'TotalNetWorthUSD'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'風控警示額度(台幣)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankYearNeWorthBase', @level2type=N'COLUMN',@level2name=N'WarningAmountNTD'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'風控警示額度(美金)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankYearNeWorthBase', @level2type=N'COLUMN',@level2name=N'WarningAmountUSD'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建立時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankYearNeWorthBase', @level2type=N'COLUMN',@level2name=N'Create_date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建立者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankYearNeWorthBase', @level2type=N'COLUMN',@level2name=N'Create_user'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'更新時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankYearNeWorthBase', @level2type=N'COLUMN',@level2name=N'Update_date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'更新者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankYearNeWorthBase', @level2type=N'COLUMN',@level2name=N'Update_user'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[BankYearNeWorthBase_his](
	[Log_id] [int] IDENTITY(1,1) NOT NULL,
	[LogType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[FlowFormId] [int] NULL,
	[PK_Id] [int] NOT NULL,
	[Year] [int] NOT NULL,
	[NTDToUSDEXRate] [decimal](18, 4) NOT NULL,
	[NetWorthNTD] [decimal](18, 2) NOT NULL,
	[NetWorthUSD] [decimal](18, 2) NOT NULL,
	[TotalRiskRatio] [int] NOT NULL,
	[TotalNetWorthNTD] [decimal](18, 2) NOT NULL,
	[TotalNetWorthUSD] [decimal](18, 2) NOT NULL,
	[WarningPercent] [int] NOT NULL,
	[WarningAmountNTD] [decimal](18, 2) NOT NULL,
	[WarningAmountUSD] [decimal](18, 2) NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK__BankYear__2D21E3B6DFB7F344] PRIMARY KEY CLUSTERED
(
	[Log_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[BankYearNeWorthBase_his] ADD  CONSTRAINT [DF__BankYearNe__Year__2B754518]  DEFAULT (datepart(year,getdate())) FOR [Year]
GO
ALTER TABLE [dbo].[BankYearNeWorthBase_his] ADD  CONSTRAINT [DF__BankYearN__NTDTo__2C696951]  DEFAULT ((0)) FOR [NTDToUSDEXRate]
GO
ALTER TABLE [dbo].[BankYearNeWorthBase_his] ADD  CONSTRAINT [DF__BankYearN__Creat__2D5D8D8A]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[BankYearNeWorthBase_his] ADD  CONSTRAINT [DF__BankYearN__Creat__2E51B1C3]  DEFAULT ('') FOR [Create_user]
GO
ALTER TABLE [dbo].[BankYearNeWorthBase_his] ADD  CONSTRAINT [DF__BankYearN__Updat__2F45D5FC]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[BankYearNeWorthBase_his] ADD  CONSTRAINT [DF__BankYearN__Updat__3039FA35]  DEFAULT ('') FOR [Update_user]
GO
ALTER TABLE [dbo].[BankYearNeWorthBase_his] ADD  CONSTRAINT [DF__BankYearN__SysCr__312E1E6E]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'歷史記錄識別碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankYearNeWorthBase_his', @level2type=N'COLUMN',@level2name=N'Log_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'異動行為類型 (INSERT/UPDATE/DELETE)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankYearNeWorthBase_his', @level2type=N'COLUMN',@level2name=N'LogType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'流程表單識別碼（外鍵：FlowForm.PK_ID）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankYearNeWorthBase_his', @level2type=N'COLUMN',@level2name=N'FlowFormId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立日期時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankYearNeWorthBase_his', @level2type=N'COLUMN',@level2name=N'SysCreateDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立使用者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankYearNeWorthBase_his', @level2type=N'COLUMN',@level2name=N'SysCreateUser'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[BankYearNeWorthBase_temp](
	[TempId] [int] IDENTITY(1,1) NOT NULL,
	[FlowFormId] [int] NULL,
	[ModifyType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[PK_Id] [int] NOT NULL,
	[Year] [int] NOT NULL,
	[NTDToUSDEXRate] [decimal](18, 4) NOT NULL,
	[NetWorthNTD] [decimal](18, 2) NOT NULL,
	[NetWorthUSD] [decimal](18, 2) NOT NULL,
	[TotalRiskRatio] [int] NOT NULL,
	[TotalNetWorthNTD] [decimal](18, 2) NOT NULL,
	[TotalNetWorthUSD] [decimal](18, 2) NOT NULL,
	[WarningPercent] [int] NOT NULL,
	[WarningAmountNTD] [decimal](18, 2) NOT NULL,
	[WarningAmountUSD] [decimal](18, 2) NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK__BankYear__06C703C135832B7A] PRIMARY KEY CLUSTERED
(
	[TempId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[BankYearNeWorthBase_temp] ADD  CONSTRAINT [DF__BankYearNe__Year__21EBDADE]  DEFAULT (datepart(year,getdate())) FOR [Year]
GO
ALTER TABLE [dbo].[BankYearNeWorthBase_temp] ADD  CONSTRAINT [DF__BankYearN__NTDTo__22DFFF17]  DEFAULT ((0)) FOR [NTDToUSDEXRate]
GO
ALTER TABLE [dbo].[BankYearNeWorthBase_temp] ADD  CONSTRAINT [DF__BankYearN__Creat__23D42350]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[BankYearNeWorthBase_temp] ADD  CONSTRAINT [DF__BankYearN__Creat__24C84789]  DEFAULT ('') FOR [Create_user]
GO
ALTER TABLE [dbo].[BankYearNeWorthBase_temp] ADD  CONSTRAINT [DF__BankYearN__Updat__25BC6BC2]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[BankYearNeWorthBase_temp] ADD  CONSTRAINT [DF__BankYearN__Updat__26B08FFB]  DEFAULT ('') FOR [Update_user]
GO
ALTER TABLE [dbo].[BankYearNeWorthBase_temp] ADD  CONSTRAINT [DF__BankYearN__SysCr__27A4B434]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'暫存資料識別碼（流水號）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankYearNeWorthBase_temp', @level2type=N'COLUMN',@level2name=N'TempId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'流程表單識別碼（外鍵：FlowForm.PK_ID）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankYearNeWorthBase_temp', @level2type=N'COLUMN',@level2name=N'FlowFormId'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[BankYearNeWorthBase_Week](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[Year] [int] NOT NULL,
	[Month] [int] NOT NULL,
	[Week] [int] NOT NULL,
	[DataDate] [date] NULL,
	[NTDToUSDEXRate] [decimal](18, 4) NOT NULL,
	[NetWorthNTD] [decimal](18, 2) NOT NULL,
	[NetWorthUSD] [decimal](18, 2) NOT NULL,
	[TotalRiskRatio] [int] NOT NULL,
	[TotalNetWorthNTD] [decimal](18, 2) NOT NULL,
	[TotalNetWorthUSD] [decimal](18, 2) NOT NULL,
	[WarningPercent] [int] NOT NULL,
	[WarningAmountNTD] [decimal](18, 2) NOT NULL,
	[WarningAmountUSD] [decimal](18, 2) NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_BankYearNeWorthBase_Week] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE NONCLUSTERED INDEX [IX_BankYearNeWorthBase_Week] ON [dbo].[BankYearNeWorthBase_Week]
(
	[Year] ASC,
	[Month] ASC,
	[Week] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
';
IF FILEGROUP_ID(N'NCRMS_IDX') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_IDX]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[BankYearNeWorthBase_Week] ADD  CONSTRAINT [DF_BankYearNeWorthBase_Week_Year]  DEFAULT (datepart(year,getdate())) FOR [Year]
GO
ALTER TABLE [dbo].[BankYearNeWorthBase_Week] ADD  CONSTRAINT [DF_BankYearNeWorthBase_Week_NTDToUSDEXRate]  DEFAULT ((0)) FOR [NTDToUSDEXRate]
GO
ALTER TABLE [dbo].[BankYearNeWorthBase_Week] ADD  CONSTRAINT [DF_BankYearNeWorthBase_Week_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[BankYearNeWorthBase_Week] ADD  CONSTRAINT [DF_BankYearNeWorthBase_Week_Create_user]  DEFAULT ('') FOR [Create_user]
GO
ALTER TABLE [dbo].[BankYearNeWorthBase_Week] ADD  CONSTRAINT [DF_BankYearNeWorthBase_Week_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[BankYearNeWorthBase_Week] ADD  CONSTRAINT [DF_BankYearNeWorthBase_Week_Update_user]  DEFAULT ('') FOR [Update_user]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'年' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankYearNeWorthBase_Week', @level2type=N'COLUMN',@level2name=N'Year'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'台幣與美金匯率' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankYearNeWorthBase_Week', @level2type=N'COLUMN',@level2name=N'NTDToUSDEXRate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'全行淨值(台幣)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankYearNeWorthBase_Week', @level2type=N'COLUMN',@level2name=N'NetWorthNTD'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'全行淨值(美金)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankYearNeWorthBase_Week', @level2type=N'COLUMN',@level2name=N'NetWorthUSD'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'全行淨值倍率' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankYearNeWorthBase_Week', @level2type=N'COLUMN',@level2name=N'TotalRiskRatio'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'全行風控總淨值(台幣)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankYearNeWorthBase_Week', @level2type=N'COLUMN',@level2name=N'TotalNetWorthNTD'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'全行風控總淨值(美金)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankYearNeWorthBase_Week', @level2type=N'COLUMN',@level2name=N'TotalNetWorthUSD'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'風控警示額度(台幣)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankYearNeWorthBase_Week', @level2type=N'COLUMN',@level2name=N'WarningAmountNTD'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'風控警示額度(美金)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankYearNeWorthBase_Week', @level2type=N'COLUMN',@level2name=N'WarningAmountUSD'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建立時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankYearNeWorthBase_Week', @level2type=N'COLUMN',@level2name=N'Create_date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建立者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankYearNeWorthBase_Week', @level2type=N'COLUMN',@level2name=N'Create_user'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'更新時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankYearNeWorthBase_Week', @level2type=N'COLUMN',@level2name=N'Update_date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'更新者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankYearNeWorthBase_Week', @level2type=N'COLUMN',@level2name=N'Update_user'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[CDS](
	[CountryCode2] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[CDS_date] [date] NOT NULL,
	[CountryName] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[CDS_Value] [decimal](18, 3) NOT NULL,
	[Create_date] [datetime] NOT NULL,
 CONSTRAINT [PK_CDS_1] PRIMARY KEY CLUSTERED
(
	[CountryCode2] ASC,
	[CDS_date] ASC,
	[CountryName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[ContinentCountry](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[ContinentId] [int] NOT NULL,
	[CountryId] [int] NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_ContinentCountry] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE NONCLUSTERED INDEX [IX_ContinentCountry] ON [dbo].[ContinentCountry]
(
	[ContinentId] ASC,
	[CountryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
';
IF FILEGROUP_ID(N'NCRMS_IDX') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_IDX]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[ContinentCountry] ADD  CONSTRAINT [DF_CONTINENTCOUNTRY_CONTINENTCODE]  DEFAULT ('') FOR [ContinentId]
GO
ALTER TABLE [dbo].[ContinentCountry] ADD  CONSTRAINT [DF_CONTINENTCOUNTRY_CountryCode2]  DEFAULT ('') FOR [CountryId]
GO
ALTER TABLE [dbo].[ContinentCountry] ADD  CONSTRAINT [DF_ContinentCountry_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[ContinentCountry] ADD  CONSTRAINT [DF_CONTINENTCOUNTRY_Create_user]  DEFAULT ('') FOR [Create_user]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'特殊區域代碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ContinentCountry', @level2type=N'COLUMN',@level2name=N'ContinentId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'國家代碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ContinentCountry', @level2type=N'COLUMN',@level2name=N'CountryId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建置時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ContinentCountry', @level2type=N'COLUMN',@level2name=N'Create_date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建置者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ContinentCountry', @level2type=N'COLUMN',@level2name=N'Create_user'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[ContinentCountry_his](
	[Log_id] [int] IDENTITY(1,1) NOT NULL,
	[LogType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Fk_logId] [int] NOT NULL,
	[PK_Id] [int] NOT NULL,
	[ContinentId] [int] NOT NULL,
	[CountryId] [int] NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK__Continen__2D21E3B6751AFBD0] PRIMARY KEY CLUSTERED
(
	[Log_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[ContinentCountry_his] ADD  CONSTRAINT [DF__Continent__SysCr__19C0A931]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'歷史記錄識別碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ContinentCountry_his', @level2type=N'COLUMN',@level2name=N'Log_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'異動行為類型 (INSERT/UPDATE/DELETE)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ContinentCountry_his', @level2type=N'COLUMN',@level2name=N'LogType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立日期時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ContinentCountry_his', @level2type=N'COLUMN',@level2name=N'SysCreateDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立使用者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ContinentCountry_his', @level2type=N'COLUMN',@level2name=N'SysCreateUser'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[ContinentCountry_temp](
	[TempId] [int] IDENTITY(1,1) NOT NULL,
	[FK_TempId] [int] NOT NULL,
	[ModifyType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[PK_Id] [int] NULL,
	[ContinentId] [int] NULL,
	[CountryId] [int] NULL,
	[Create_date] [datetime] NULL,
	[Create_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK__Continen__06C703C1E58220A3] PRIMARY KEY CLUSTERED
(
	[TempId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[ContinentCountry_temp] ADD  CONSTRAINT [DF__Continent__Conti__1C9D15DC]  DEFAULT ('') FOR [ContinentId]
GO
ALTER TABLE [dbo].[ContinentCountry_temp] ADD  CONSTRAINT [DF__Continent__Count__1D913A15]  DEFAULT ('') FOR [CountryId]
GO
ALTER TABLE [dbo].[ContinentCountry_temp] ADD  CONSTRAINT [DF__Continent__Creat__1E855E4E]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[ContinentCountry_temp] ADD  CONSTRAINT [DF__Continent__Creat__1F798287]  DEFAULT ('') FOR [Create_user]
GO
ALTER TABLE [dbo].[ContinentCountry_temp] ADD  CONSTRAINT [DF__Continent__SysCr__206DA6C0]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'暫存資料識別碼（流水號）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ContinentCountry_temp', @level2type=N'COLUMN',@level2name=N'TempId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'主表暫存資料外鍵' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ContinentCountry_temp', @level2type=N'COLUMN',@level2name=N'FK_TempId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'異動類型' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ContinentCountry_temp', @level2type=N'COLUMN',@level2name=N'ModifyType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立日期時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ContinentCountry_temp', @level2type=N'COLUMN',@level2name=N'SysCreateDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立使用者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ContinentCountry_temp', @level2type=N'COLUMN',@level2name=N'SysCreateUser'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[ContinentMaster](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[ContinentCode] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[ContinentName_TN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[ContinentName_EN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[ContinentName_CN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[ContinentName_JP] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[IsActive] [bit] NOT NULL,
	[IsContinent] [bit] NOT NULL,
	[seq] [int] NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
 CONSTRAINT [PK_ContinentMaster] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[ContinentMaster] ADD  CONSTRAINT [DF_ContinentMaster_ContinentCode]  DEFAULT ('') FOR [ContinentCode]
GO
ALTER TABLE [dbo].[ContinentMaster] ADD  CONSTRAINT [DF_ContinentMaster_ContinentName_TN]  DEFAULT ('') FOR [ContinentName_TN]
GO
ALTER TABLE [dbo].[ContinentMaster] ADD  CONSTRAINT [DF_ContinentMaster_ContinentName_EN]  DEFAULT ('') FOR [ContinentName_EN]
GO
ALTER TABLE [dbo].[ContinentMaster] ADD  CONSTRAINT [DF_ContinentMaster_ContinentName_CN]  DEFAULT ('') FOR [ContinentName_CN]
GO
ALTER TABLE [dbo].[ContinentMaster] ADD  CONSTRAINT [DF_ContinentMaster_ContinentName_JP]  DEFAULT ('') FOR [ContinentName_JP]
GO
ALTER TABLE [dbo].[ContinentMaster] ADD  CONSTRAINT [DF_ContinentMaster_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[ContinentMaster] ADD  CONSTRAINT [DF_ContinentMaster_IsContinent]  DEFAULT ((0)) FOR [IsContinent]
GO
ALTER TABLE [dbo].[ContinentMaster] ADD  CONSTRAINT [DF_ContinentMaster_seq]  DEFAULT ((1)) FOR [seq]
GO
ALTER TABLE [dbo].[ContinentMaster] ADD  CONSTRAINT [DF_ContinentMaster_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[ContinentMaster] ADD  CONSTRAINT [DF_ContinentMaster_Update_user]  DEFAULT ('') FOR [Update_user]
GO
ALTER TABLE [dbo].[ContinentMaster] ADD  CONSTRAINT [DF_ContinentMaster_Create_user]  DEFAULT ('') FOR [Create_user]
GO
ALTER TABLE [dbo].[ContinentMaster] ADD  CONSTRAINT [DF_ContinentMaster_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'州、特殊區域代碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ContinentMaster', @level2type=N'COLUMN',@level2name=N'ContinentCode'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'中' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ContinentMaster', @level2type=N'COLUMN',@level2name=N'ContinentName_TN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'英' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ContinentMaster', @level2type=N'COLUMN',@level2name=N'ContinentName_EN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'簡' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ContinentMaster', @level2type=N'COLUMN',@level2name=N'ContinentName_CN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'日' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ContinentMaster', @level2type=N'COLUMN',@level2name=N'ContinentName_JP'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'是否啟用' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ContinentMaster', @level2type=N'COLUMN',@level2name=N'IsActive'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'州別 = true 特殊區域 false' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ContinentMaster', @level2type=N'COLUMN',@level2name=N'IsContinent'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'排序' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ContinentMaster', @level2type=N'COLUMN',@level2name=N'seq'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'更新時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ContinentMaster', @level2type=N'COLUMN',@level2name=N'Update_date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'更新者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ContinentMaster', @level2type=N'COLUMN',@level2name=N'Update_user'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建立者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ContinentMaster', @level2type=N'COLUMN',@level2name=N'Create_user'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建立時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ContinentMaster', @level2type=N'COLUMN',@level2name=N'Create_date'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[ContinentMaster_his](
	[Log_id] [int] IDENTITY(1,1) NOT NULL,
	[LogType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[FlowFormId] [int] NULL,
	[PK_Id] [int] NOT NULL,
	[ContinentCode] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[ContinentName_TN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[ContinentName_EN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[ContinentName_CN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[ContinentName_JP] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[IsActive] [bit] NOT NULL,
	[IsContinent] [bit] NOT NULL,
	[seq] [int] NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK__Continen__2D21E3B63171B2E4] PRIMARY KEY CLUSTERED
(
	[Log_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[ContinentMaster_his] ADD  CONSTRAINT [DF__Continent__Conti__0A7E65A1]  DEFAULT ('') FOR [ContinentCode]
GO
ALTER TABLE [dbo].[ContinentMaster_his] ADD  CONSTRAINT [DF__Continent__Conti__0B7289DA]  DEFAULT ('') FOR [ContinentName_TN]
GO
ALTER TABLE [dbo].[ContinentMaster_his] ADD  CONSTRAINT [DF__Continent__Conti__0C66AE13]  DEFAULT ('') FOR [ContinentName_EN]
GO
ALTER TABLE [dbo].[ContinentMaster_his] ADD  CONSTRAINT [DF__Continent__Conti__0D5AD24C]  DEFAULT ('') FOR [ContinentName_CN]
GO
ALTER TABLE [dbo].[ContinentMaster_his] ADD  CONSTRAINT [DF__Continent__Conti__0E4EF685]  DEFAULT ('') FOR [ContinentName_JP]
GO
ALTER TABLE [dbo].[ContinentMaster_his] ADD  CONSTRAINT [DF__Continent__IsAct__0F431ABE]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[ContinentMaster_his] ADD  CONSTRAINT [DF__Continent__IsCon__10373EF7]  DEFAULT ((0)) FOR [IsContinent]
GO
ALTER TABLE [dbo].[ContinentMaster_his] ADD  CONSTRAINT [DF__ContinentMa__seq__112B6330]  DEFAULT ((1)) FOR [seq]
GO
ALTER TABLE [dbo].[ContinentMaster_his] ADD  CONSTRAINT [DF__Continent__Updat__121F8769]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[ContinentMaster_his] ADD  CONSTRAINT [DF__Continent__Updat__1313ABA2]  DEFAULT ('') FOR [Update_user]
GO
ALTER TABLE [dbo].[ContinentMaster_his] ADD  CONSTRAINT [DF__Continent__Creat__1407CFDB]  DEFAULT ('') FOR [Create_user]
GO
ALTER TABLE [dbo].[ContinentMaster_his] ADD  CONSTRAINT [DF__Continent__Creat__14FBF414]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[ContinentMaster_his] ADD  CONSTRAINT [DF__Continent__SysCr__15F0184D]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'歷史記錄識別碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ContinentMaster_his', @level2type=N'COLUMN',@level2name=N'Log_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'異動行為類型 (INSERT/UPDATE/DELETE)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ContinentMaster_his', @level2type=N'COLUMN',@level2name=N'LogType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'流程表單識別碼（外鍵：FlowForm.PK_ID）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ContinentMaster_his', @level2type=N'COLUMN',@level2name=N'FlowFormId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立日期時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ContinentMaster_his', @level2type=N'COLUMN',@level2name=N'SysCreateDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立使用者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ContinentMaster_his', @level2type=N'COLUMN',@level2name=N'SysCreateUser'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[ContinentMaster_temp](
	[TempId] [int] IDENTITY(1,1) NOT NULL,
	[FlowFormId] [int] NULL,
	[ModifyType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[PK_Id] [int] NOT NULL,
	[ContinentCode] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[ContinentName_TN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[ContinentName_EN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[ContinentName_CN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[ContinentName_JP] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[IsActive] [bit] NOT NULL,
	[IsContinent] [bit] NOT NULL,
	[seq] [int] NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK__Continen__06C703C1D3342835] PRIMARY KEY CLUSTERED
(
	[TempId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[ContinentMaster_temp] ADD  CONSTRAINT [DF__Continent__Conti__7B3C2211]  DEFAULT ('') FOR [ContinentCode]
GO
ALTER TABLE [dbo].[ContinentMaster_temp] ADD  CONSTRAINT [DF__Continent__Conti__7C30464A]  DEFAULT ('') FOR [ContinentName_TN]
GO
ALTER TABLE [dbo].[ContinentMaster_temp] ADD  CONSTRAINT [DF__Continent__Conti__7D246A83]  DEFAULT ('') FOR [ContinentName_EN]
GO
ALTER TABLE [dbo].[ContinentMaster_temp] ADD  CONSTRAINT [DF__Continent__Conti__7E188EBC]  DEFAULT ('') FOR [ContinentName_CN]
GO
ALTER TABLE [dbo].[ContinentMaster_temp] ADD  CONSTRAINT [DF__Continent__Conti__7F0CB2F5]  DEFAULT ('') FOR [ContinentName_JP]
GO
ALTER TABLE [dbo].[ContinentMaster_temp] ADD  CONSTRAINT [DF__Continent__IsAct__0000D72E]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[ContinentMaster_temp] ADD  CONSTRAINT [DF__Continent__IsCon__00F4FB67]  DEFAULT ((0)) FOR [IsContinent]
GO
ALTER TABLE [dbo].[ContinentMaster_temp] ADD  CONSTRAINT [DF__ContinentMa__seq__01E91FA0]  DEFAULT ((1)) FOR [seq]
GO
ALTER TABLE [dbo].[ContinentMaster_temp] ADD  CONSTRAINT [DF__Continent__Updat__02DD43D9]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[ContinentMaster_temp] ADD  CONSTRAINT [DF__Continent__Updat__03D16812]  DEFAULT ('') FOR [Update_user]
GO
ALTER TABLE [dbo].[ContinentMaster_temp] ADD  CONSTRAINT [DF__Continent__Creat__04C58C4B]  DEFAULT ('') FOR [Create_user]
GO
ALTER TABLE [dbo].[ContinentMaster_temp] ADD  CONSTRAINT [DF__Continent__Creat__05B9B084]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[ContinentMaster_temp] ADD  CONSTRAINT [DF__Continent__SysCr__06ADD4BD]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'暫存資料識別碼（流水號）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ContinentMaster_temp', @level2type=N'COLUMN',@level2name=N'TempId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'流程表單識別碼（外鍵：FlowForm.PK_ID）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ContinentMaster_temp', @level2type=N'COLUMN',@level2name=N'FlowFormId'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[CountryException](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_CountryId] [int] NOT NULL,
	[IsException] [bit] NOT NULL,
	[ExceptionExplain] [nvarchar](255) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Approval_date] [date] NOT NULL,
	[Update_user] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
 CONSTRAINT [PK_CountryException] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[CountryException] ADD  CONSTRAINT [DF_CountryException_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[CountryException] ADD  CONSTRAINT [DF_CountryException_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[CountryException_his](
	[Log_Id] [int] IDENTITY(1,1) NOT NULL,
	[FlowFormId] [int] NOT NULL,
	[LogType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[PK_Id] [int] NOT NULL,
	[FK_CountryId] [int] NULL,
	[CountryName_TN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CountryName_CN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CountryName_EN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CountryName_JP] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CountryCode2] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[IsException] [bit] NOT NULL,
	[ExceptionExplain] [nvarchar](255) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Approval_date] [date] NULL,
	[Update_user] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_CountryException_his] PRIMARY KEY CLUSTERED
(
	[Log_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[CountryException_his] ADD  CONSTRAINT [DF_CountryException_his_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[CountryException_his] ADD  CONSTRAINT [DF_CountryException_his_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[CountryException_his] ADD  CONSTRAINT [DF_CountryException_his_SysCreateDate]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[CountryException_temp](
	[TempId] [int] IDENTITY(1,1) NOT NULL,
	[FlowFormId] [int] NULL,
	[ModifyType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[PK_Id] [int] NOT NULL,
	[FK_CountryId] [int] NULL,
	[IsException] [bit] NOT NULL,
	[ExceptionExplain] [nvarchar](255) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Approval_date] [date] NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_CountryException_temp] PRIMARY KEY CLUSTERED
(
	[TempId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[CountryException_temp] ADD  CONSTRAINT [DF_CountryException_temp_SysCreateDate]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[CountryExceptionBankGroup](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_CountryExceptionId] [int] NOT NULL,
	[FK_BankGroupCode] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[CreditBusiness] [bit] NULL,
	[InterbankDepositBusiness] [bit] NULL,
	[InvestmentBusiness] [bit] NULL,
 CONSTRAINT [PK_CountryExceptionBankGroup] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'授信業務' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryExceptionBankGroup', @level2type=N'COLUMN',@level2name=N'CreditBusiness'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'拆存業務' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryExceptionBankGroup', @level2type=N'COLUMN',@level2name=N'InterbankDepositBusiness'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'投資業務' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryExceptionBankGroup', @level2type=N'COLUMN',@level2name=N'InvestmentBusiness'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[CountryExceptionBankGroup_his](
	[Log_Id] [int] IDENTITY(1,1) NOT NULL,
	[Fk_LogId] [int] NOT NULL,
	[LogType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[PK_Id] [int] NULL,
	[FK_CountryExceptionId] [int] NULL,
	[FK_BankGroupCode] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CreditBusiness] [bit] NULL,
	[InterbankDepositBusiness] [bit] NULL,
	[InvestmentBusiness] [bit] NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_CountryExceptionBankGroup_his] PRIMARY KEY CLUSTERED
(
	[Log_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[CountryExceptionBankGroup_his] ADD  CONSTRAINT [DF_CountryExceptionBankGroup_his_SysCreateDate]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'授信業務' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryExceptionBankGroup_his', @level2type=N'COLUMN',@level2name=N'CreditBusiness'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'拆存業務' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryExceptionBankGroup_his', @level2type=N'COLUMN',@level2name=N'InterbankDepositBusiness'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'投資業務' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryExceptionBankGroup_his', @level2type=N'COLUMN',@level2name=N'InvestmentBusiness'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[CountryExceptionBankGroup_temp](
	[TempId] [int] IDENTITY(1,1) NOT NULL,
	[FK_TempId] [int] NOT NULL,
	[ModifyType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[PK_Id] [int] NULL,
	[FK_CountryExceptionId] [int] NULL,
	[FK_BankGroupCode] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[CreditBusiness] [bit] NOT NULL,
	[InterbankDepositBusiness] [bit] NOT NULL,
	[InvestmentBusiness] [bit] NOT NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_Table_1] PRIMARY KEY CLUSTERED
(
	[TempId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[CountryExceptionBankGroup_temp] ADD  CONSTRAINT [DF_CountryExceptionBankGroup_temp_CreditBusiness]  DEFAULT ((0)) FOR [CreditBusiness]
GO
ALTER TABLE [dbo].[CountryExceptionBankGroup_temp] ADD  CONSTRAINT [DF_CountryExceptionBankGroup_temp_InterbankDepositBusiness]  DEFAULT ((0)) FOR [InterbankDepositBusiness]
GO
ALTER TABLE [dbo].[CountryExceptionBankGroup_temp] ADD  CONSTRAINT [DF_CountryExceptionBankGroup_temp_InvestmentBusiness]  DEFAULT ((0)) FOR [InvestmentBusiness]
GO
ALTER TABLE [dbo].[CountryExceptionBankGroup_temp] ADD  CONSTRAINT [DF_Table_1_SysCreateDate]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'授信業務' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryExceptionBankGroup_temp', @level2type=N'COLUMN',@level2name=N'CreditBusiness'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'拆存業務' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryExceptionBankGroup_temp', @level2type=N'COLUMN',@level2name=N'InterbankDepositBusiness'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'投資業務' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryExceptionBankGroup_temp', @level2type=N'COLUMN',@level2name=N'InvestmentBusiness'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[CountryFocus](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_CountryId] [int] NOT NULL,
	[IsFocus] [bit] NOT NULL,
	[FocusExplain] [nvarchar](255) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Approval_date] [date] NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_CountryFocus] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[CountryFocus_his](
	[Log_Id] [int] IDENTITY(1,1) NOT NULL,
	[FlowFormId] [int] NOT NULL,
	[LogType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[PK_Id] [int] NOT NULL,
	[FK_CountryId] [int] NULL,
	[CountryCode2] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[CountryName_TN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[CountryName_CN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[CountryName_EN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[CountryName_JP] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[IsFocus] [bit] NOT NULL,
	[FocusExplain] [nvarchar](255) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Approval_date] [date] NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_CountryFocus_his] PRIMARY KEY CLUSTERED
(
	[Log_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[CountryFocus_his] ADD  CONSTRAINT [DF_CountryFocus_his_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[CountryFocus_his] ADD  CONSTRAINT [DF_CountryFocus_his_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[CountryFocus_temp](
	[TempId] [int] IDENTITY(1,1) NOT NULL,
	[FlowFormId] [int] NULL,
	[ModifyType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[PK_Id] [int] NOT NULL,
	[FK_CountryId] [int] NULL,
	[IsFocus] [bit] NOT NULL,
	[FocusExplain] [nvarchar](255) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Approval_date] [date] NULL,
	[Update_date] [datetime] NULL,
	[Update_user] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Create_date] [datetime] NULL,
	[Create_user] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SysCreateDate] [datetime] NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_CountryFocus_temp] PRIMARY KEY CLUSTERED
(
	[TempId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[CountryFocus_temp] ADD  CONSTRAINT [DF_CountryFocus_temp_Completion_date]  DEFAULT (getdate()) FOR [Approval_date]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[CountryForexRateMapping](
	[CountryCode2] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[ForexRateCode] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
 CONSTRAINT [PK_CountryForexRateMapping] PRIMARY KEY CLUSTERED
(
	[CountryCode2] ASC,
	[ForexRateCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[CountryMaster](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_Continent] [int] NOT NULL,
	[CountryCode2] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[CountryCode3] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[CountryCode4] [nvarchar](4) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[CountryName_TN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[CountryName_EN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[CountryName_JP] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[CountryName_CN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[HASFCBBRANCH] [bit] NOT NULL,
	[BusinessPoint] [decimal](5, 1) NULL,
	[CDSPoint] [decimal](5, 1) NULL,
	[ISIMFAE] [bit] NOT NULL,
	[WarningUsePercent] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[IsException] [bit] NOT NULL,
	[ExceptionExplain] [nvarchar](255) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[IsFocus] [bit] NOT NULL,
	[FocusExplain] [nvarchar](255) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[CreditRatingScore] [tinyint] NOT NULL,
	[CreditRatingScorePublishedAt] [datetime] NULL,
 CONSTRAINT [PK_CountryMaster] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB],
 CONSTRAINT [IX_CountryMaster_1] UNIQUE NONCLUSTERED
(
	[CountryCode2] ASC
)WITH (PAD_INDEX = OFF';
SET @FilegroupSql += N', STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
IF FILEGROUP_ID(N'NCRMS_IDX') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_IDX]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[CountryMaster] ADD  CONSTRAINT [DF_CountryMaster_CountryCode2]  DEFAULT ('') FOR [CountryCode2]
GO
ALTER TABLE [dbo].[CountryMaster] ADD  CONSTRAINT [DF_CountryMaster_CountryCode]  DEFAULT ('') FOR [CountryCode3]
GO
ALTER TABLE [dbo].[CountryMaster] ADD  CONSTRAINT [DF_CountryMaster_CountryCode21]  DEFAULT ('') FOR [CountryCode4]
GO
ALTER TABLE [dbo].[CountryMaster] ADD  CONSTRAINT [DF_CountryMaster_CountryName_TN]  DEFAULT ('') FOR [CountryName_TN]
GO
ALTER TABLE [dbo].[CountryMaster] ADD  CONSTRAINT [DF_CountryMaster_CountryName_EN]  DEFAULT ('') FOR [CountryName_EN]
GO
ALTER TABLE [dbo].[CountryMaster] ADD  CONSTRAINT [DF_CountryMaster_CountryName_JP]  DEFAULT ('') FOR [CountryName_JP]
GO
ALTER TABLE [dbo].[CountryMaster] ADD  CONSTRAINT [DF_CountryMaster_CountryName_CN]  DEFAULT ('') FOR [CountryName_CN]
GO
ALTER TABLE [dbo].[CountryMaster] ADD  CONSTRAINT [DF_CountryMaster_HASFCBBRANCH]  DEFAULT ((0)) FOR [HASFCBBRANCH]
GO
ALTER TABLE [dbo].[CountryMaster] ADD  CONSTRAINT [DF_CountryMaster_BusinessRating]  DEFAULT ((9)) FOR [BusinessPoint]
GO
ALTER TABLE [dbo].[CountryMaster] ADD  CONSTRAINT [DF_CountryMaster_CDSPoint]  DEFAULT ((5)) FOR [CDSPoint]
GO
ALTER TABLE [dbo].[CountryMaster] ADD  CONSTRAINT [DF_CountryMaster_WarningUsePercent]  DEFAULT ((80)) FOR [WarningUsePercent]
GO
ALTER TABLE [dbo].[CountryMaster] ADD  CONSTRAINT [DF_CountryMaster_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[CountryMaster] ADD  CONSTRAINT [DF_CountryMaster_IsException]  DEFAULT ((0)) FOR [IsException]
GO
ALTER TABLE [dbo].[CountryMaster] ADD  CONSTRAINT [DF_CountryMaster_ExceptionExplain]  DEFAULT ('') FOR [ExceptionExplain]
GO
ALTER TABLE [dbo].[CountryMaster] ADD  CONSTRAINT [DF_CountryMaster_IsFocus]  DEFAULT ((0)) FOR [IsFocus]
GO
ALTER TABLE [dbo].[CountryMaster] ADD  CONSTRAINT [DF_CountryMaster_FocusExplain]  DEFAULT ('') FOR [FocusExplain]
GO
ALTER TABLE [dbo].[CountryMaster] ADD  CONSTRAINT [DF_CountryMaster_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[CountryMaster] ADD  CONSTRAINT [DF_CountryMaster_Update_user]  DEFAULT ('system') FOR [Update_user]
GO
ALTER TABLE [dbo].[CountryMaster] ADD  CONSTRAINT [DF_CountryMaster_Create_user]  DEFAULT ('system') FOR [Create_user]
GO
ALTER TABLE [dbo].[CountryMaster] ADD  CONSTRAINT [DF_CountryMaster_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[CountryMaster] ADD  CONSTRAINT [DF_CountryMaster_CreditRatingScore]  DEFAULT ((5)) FOR [CreditRatingScore]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'州別關聯' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryMaster', @level2type=N'COLUMN',@level2name=N'FK_Continent'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ISO 3166-1 alpha-2: TW, US, CN' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryMaster', @level2type=N'COLUMN',@level2name=N'CountryCode2'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ISO 3166-1 alpha-3: TWN, USA, CHN' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryMaster', @level2type=N'COLUMN',@level2name=N'CountryCode3'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'四碼自定義 1001,0000' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryMaster', @level2type=N'COLUMN',@level2name=N'CountryCode4'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'中' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryMaster', @level2type=N'COLUMN',@level2name=N'CountryName_TN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'英' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryMaster', @level2type=N'COLUMN',@level2name=N'CountryName_EN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'日' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryMaster', @level2type=N'COLUMN',@level2name=N'CountryName_JP'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'簡中' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryMaster', @level2type=N'COLUMN',@level2name=N'CountryName_CN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'該國是否有分行' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryMaster', @level2type=N'COLUMN',@level2name=N'HASFCBBRANCH'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'業務策略分數(計算國家評分用' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryMaster', @level2type=N'COLUMN',@level2name=N'BusinessPoint'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'CDS價格及其他因素(計算國家評分用' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryMaster', @level2type=N'COLUMN',@level2name=N'CDSPoint'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'是否是已開發國家' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryMaster', @level2type=N'COLUMN',@level2name=N'ISIMFAE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'警示佔用額度百分比' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryMaster', @level2type=N'COLUMN',@level2name=N'WarningUsePercent'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'啟用' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryMaster', @level2type=N'COLUMN',@level2name=N'IsActive'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'是否例外國家' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryMaster', @level2type=N'COLUMN',@level2name=N'IsException'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'說明' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryMaster', @level2type=N'COLUMN',@level2name=N'ExceptionExplain'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'是否近期關注' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryMaster', @level2type=N'COLUMN',@level2name=N'IsFocus'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'近期關注說明' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryMaster', @level2type=N'COLUMN',@level2name=N'FocusExplain'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'更新時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryMaster', @level2type=N'COLUMN',@level2name=N'Update_date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'更新者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryMaster', @level2type=N'COLUMN',@level2name=N'Update_user'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'創建者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryMaster', @level2type=N'COLUMN',@level2name=N'Create_user'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'創建時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryMaster', @level2type=N'COLUMN',@level2name=N'Create_date'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[CountryMaster_his](
	[log_id] [int] IDENTITY(1,1) NOT NULL,
	[Logtype] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[FlowFormId] [int] NOT NULL,
	[PK_Id] [int] NOT NULL,
	[FK_Continent] [int] NOT NULL,
	[CountryCode2] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[CountryCode3] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[CountryCode4] [nvarchar](4) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[CountryName_TN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[CountryName_EN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[CountryName_JP] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[CountryName_CN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[HASFCBBRANCH] [bit] NOT NULL,
	[BusinessPoint] [decimal](5, 1) NULL,
	[CDSPoint] [decimal](5, 1) NULL,
	[ISIMFAE] [bit] NOT NULL,
	[WarningUsePercent] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[IsException] [bit] NOT NULL,
	[ExceptionExplain] [nvarchar](255) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[IsFocus] [bit] NOT NULL,
	[FocusExplain] [nvarchar](255) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK__CountryM__9E2397E0E71DF61A] PRIMARY KEY CLUSTERED
(
	[log_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON';
SET @FilegroupSql += N', ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[CountryMaster_his] ADD  CONSTRAINT [DF_CountryMaster_his_ExceptionExplain]  DEFAULT ('') FOR [ExceptionExplain]
GO
ALTER TABLE [dbo].[CountryMaster_his] ADD  CONSTRAINT [DF_CountryMaster_his_FocusExplain]  DEFAULT ('') FOR [FocusExplain]
GO
ALTER TABLE [dbo].[CountryMaster_his] ADD  CONSTRAINT [DF_CountryMaster_his_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[CountryMaster_his] ADD  CONSTRAINT [DF_CountryMaster_his_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[CountryMaster_his] ADD  CONSTRAINT [DF_CountryMaster_his_SysCreateDate]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'歷史記錄識別碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryMaster_his', @level2type=N'COLUMN',@level2name=N'log_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'異動行為類型 (INSERT/UPDATE/DELETE)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryMaster_his', @level2type=N'COLUMN',@level2name=N'Logtype'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立日期時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryMaster_his', @level2type=N'COLUMN',@level2name=N'SysCreateDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立使用者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryMaster_his', @level2type=N'COLUMN',@level2name=N'SysCreateUser'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[CountryMaster_temp](
	[TempId] [int] IDENTITY(1,1) NOT NULL,
	[FlowFormId] [int] NULL,
	[ModifyType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[PK_Id] [int] NULL,
	[FK_Continent] [int] NULL,
	[CountryCode2] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CountryCode3] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CountryCode4] [nvarchar](4) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CountryName_TN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CountryName_EN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CountryName_JP] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CountryName_CN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[HASFCBBRANCH] [bit] NULL,
	[BusinessPoint] [decimal](5, 1) NULL,
	[CDSPoint] [decimal](5, 1) NULL,
	[ISIMFAE] [bit] NULL,
	[WarningUsePercent] [int] NULL,
	[IsActive] [bit] NULL,
	[IsException] [bit] NULL,
	[ExceptionExplain] [nvarchar](255) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[IsFocus] [bit] NULL,
	[FocusExplain] [nvarchar](255) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Create_date] [datetime] NOT NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK__CountryM__06C703C165F6C02C] PRIMARY KEY CLUSTERED
(
	[TempId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
';
SET @FilegroupSql += N') ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[CountryMaster_temp] ADD  CONSTRAINT [DF_CountryMaster_temp_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[CountryMaster_temp] ADD  CONSTRAINT [DF_CountryMaster_temp_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[CountryMaster_temp] ADD  CONSTRAINT [DF_CountryMaster_temp_SysCreateDate]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'暫存資料識別碼（流水號）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryMaster_temp', @level2type=N'COLUMN',@level2name=N'TempId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'流程表單識別碼（外鍵：FLOW_FORM.PK_ID）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryMaster_temp', @level2type=N'COLUMN',@level2name=N'FlowFormId'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[CountryOutlookReport](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_CountryId] [int] NOT NULL,
	[Gdp] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Population] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[IndustryDistribution] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[MainExportCountry] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[MainExportProducts] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[EconomicGrowthContent] [nvarchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SolvencyContent] [nvarchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[FinancialSituationContent] [nvarchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CountryRatingContent] [nvarchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[DataSource] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[ReportSource] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LastYearCDS] [decimal](18, 2) NULL,
	[LastMonthCDS] [decimal](18, 2) NULL,
	[LastWeekCDS] [decimal](18, 2) NULL,
	[LastDayCDS] [decimal](18, 2) NULL,
	[LastDayCDS_date] [date] NULL,
	[IsActive] [bit] NOT NULL,
	[Release_date] [date] NOT NULL,
	[Update_user] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[LastYearHighCDS] [decimal](18, 2) NULL,
	[LastYearHighCDS_date] [date] NULL,
	[LastYearLowCDS] [decimal](18, 2) NULL,
	[LastYearLowCDS_date] [date] NULL,
	[LastYearAvgCDS] [decimal](18, 2) NULL,
	[FK_FileId] [int] NULL,
	[GdpGrowth] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_';
SET @FilegroupSql += N'CI_AS NULL,
 CONSTRAINT [PK_CountryOutlookReport] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[CountryOutlookReport] ADD  CONSTRAINT [DF_CountryOutlookReport_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[CountryOutlookReport] ADD  CONSTRAINT [DF_CountryOutlookReport_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[CountryOutlookReport] ADD  CONSTRAINT [DF_CountryOutlookReport_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[CountryOutlookReport_his](
	[Log_id] [int] IDENTITY(1,1) NOT NULL,
	[LogType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[FlowFormId] [int] NULL,
	[PK_Id] [int] NOT NULL,
	[FK_CountryId] [int] NOT NULL,
	[Gdp] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Population] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[IndustryDistribution] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[MainExportCountry] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[MainExportProducts] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[EconomicGrowthContent] [nvarchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SolvencyContent] [nvarchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[FinancialSituationContent] [nvarchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CountryRatingContent] [nvarchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[DataSource] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[ReportSource] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LastYearCDS] [decimal](18, 2) NULL,
	[LastMonthCDS] [decimal](18, 2) NULL,
	[LastWeekCDS] [decimal](18, 2) NULL,
	[LastDayCDS] [decimal](18, 2) NULL,
	[LastDayCDS_date] [date] NULL,
	[IsActive] [bit] NOT NULL,
	[Release_date] [date] NOT NULL,
	[Update_user] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[LastYearHighCDS] [decimal](18, 2) N';
SET @FilegroupSql += N'ULL,
	[LastYearHighCDS_date] [date] NULL,
	[LastYearLowCDS] [decimal](18, 2) NULL,
	[LastYearLowCDS_date] [date] NULL,
	[LastYearAvgCDS] [decimal](18, 2) NULL,
	[GdpGrowth] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
 CONSTRAINT [PK__CountryO__2D21E3B62FDE61CC] PRIMARY KEY CLUSTERED
(
	[Log_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[CountryOutlookReport_his] ADD  CONSTRAINT [DF__CountryOu__IsAct__6715F92A]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[CountryOutlookReport_his] ADD  CONSTRAINT [DF__CountryOu__Updat__680A1D63]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[CountryOutlookReport_his] ADD  CONSTRAINT [DF__CountryOu__Creat__68FE419C]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[CountryOutlookReport_his] ADD  CONSTRAINT [DF__CountryOu__SysCr__69F265D5]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'歷史記錄識別碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryOutlookReport_his', @level2type=N'COLUMN',@level2name=N'Log_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'異動行為類型 (INSERT/UPDATE/DELETE)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryOutlookReport_his', @level2type=N'COLUMN',@level2name=N'LogType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'流程表單識別碼（外鍵：FlowForm.PK_ID）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryOutlookReport_his', @level2type=N'COLUMN',@level2name=N'FlowFormId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立日期時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryOutlookReport_his', @level2type=N'COLUMN',@level2name=N'SysCreateDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立使用者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryOutlookReport_his', @level2type=N'COLUMN',@level2name=N'SysCreateUser'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[CountryOutlookReport_Source](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_CountryId] [int] NOT NULL,
	[IndustryDistribution] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[MainExportProducts] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[MainExportCountry] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[DataSource] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[EconomicGrowthContent] [nvarchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SolvencyContent] [nvarchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[FinancialSituationContent] [nvarchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CountryRatingContent] [nvarchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[ReportSource] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Create_date] [datetime] NOT NULL,
 CONSTRAINT [PK_CountryOutlookReport_Source] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[CountryOutlookReport_Source] ADD  CONSTRAINT [DF_CountryOutlookReport_Source_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[CountryOutlookReport_temp](
	[TempId] [int] IDENTITY(1,1) NOT NULL,
	[FlowFormId] [int] NULL,
	[ModifyType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[PK_Id] [int] NOT NULL,
	[FK_CountryId] [int] NOT NULL,
	[Gdp] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Population] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[IndustryDistribution] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[MainExportCountry] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[MainExportProducts] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[EconomicGrowthContent] [nvarchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SolvencyContent] [nvarchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[FinancialSituationContent] [nvarchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CountryRatingContent] [nvarchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[DataSource] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[ReportSource] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LastYearCDS] [decimal](18, 2) NULL,
	[LastMonthCDS] [decimal](18, 2) NULL,
	[LastWeekCDS] [decimal](18, 2) NULL,
	[LastDayCDS] [decimal](18, 2) NULL,
	[LastDayCDS_date] [date] NULL,
	[IsActive] [bit] NOT NULL,
	[Release_date] [date] NOT NULL,
	[Update_user] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[LastYearHighCDS] [decimal](18, ';
SET @FilegroupSql += N'2) NULL,
	[LastYearHighCDS_date] [date] NULL,
	[LastYearLowCDS] [decimal](18, 2) NULL,
	[LastYearLowCDS_date] [date] NULL,
	[LastYearAvgCDS] [decimal](18, 2) NULL,
	[GdpGrowth] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
 CONSTRAINT [PK__CountryO__06C703C14759D8AC] PRIMARY KEY CLUSTERED
(
	[TempId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[CountryOutlookReport_temp] ADD  CONSTRAINT [DF__CountryOu__IsAct__6068FB9B]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[CountryOutlookReport_temp] ADD  CONSTRAINT [DF__CountryOu__Updat__615D1FD4]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[CountryOutlookReport_temp] ADD  CONSTRAINT [DF__CountryOu__Creat__6251440D]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[CountryOutlookReport_temp] ADD  CONSTRAINT [DF__CountryOu__SysCr__63456846]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'暫存資料識別碼（流水號）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryOutlookReport_temp', @level2type=N'COLUMN',@level2name=N'TempId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'流程表單識別碼（外鍵：FlowForm.PK_ID）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryOutlookReport_temp', @level2type=N'COLUMN',@level2name=N'FlowFormId'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[CountryOutlookReport_Views](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_ReportId] [int] NOT NULL,
	[Views] [int] NOT NULL,
 CONSTRAINT [PK_CountryOutlookReport_Views] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[CountryOutlookReport_Views] ADD  CONSTRAINT [DF_CountryOutlookReport_Views_Views]  DEFAULT ((0)) FOR [Views]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[CountryWeightPercent](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[CountryId] [int] NOT NULL,
	[WeightPercent] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_CountryWeightPercent] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE NONCLUSTERED INDEX [IX_CountryWeightPercent] ON [dbo].[CountryWeightPercent]
(
	[CountryId] ASC,
	[WeightPercent] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
';
IF FILEGROUP_ID(N'NCRMS_IDX') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_IDX]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[CountryWeightPercent] ADD  CONSTRAINT [DF_CountryWeightPercent_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[CreditRating_AllBmi](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[Year] [int] NOT NULL,
	[FK_Country_Id] [int] NOT NULL,
	[FK_CategoriesId] [int] NOT NULL,
	[Score] [float] NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_BMICountryRisk_temp] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE NONCLUSTERED INDEX [IX_CreditRating_AllBmi_Country_Year_Category] ON [dbo].[CreditRating_AllBmi]
(
	[FK_Country_Id] ASC,
	[Year] ASC,
	[FK_CategoriesId] ASC
)
INCLUDE([Score]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
';
IF FILEGROUP_ID(N'NCRMS_IDX') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_IDX]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[CreditRating_AllBmi] ADD  CONSTRAINT [DF_BMICountryRisk_temp_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[CreditRating_Bmi](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_Country_Id] [int] NOT NULL,
	[Year] [int] NULL,
	[BMI_GDP_REAL_PCTCH] [decimal](18, 4) NULL,
	[BMI_GDP_NOM_USD_AVE] [decimal](38, 4) NULL,
	[BMI_GDP_NOM_USD_PERCAP_AVE] [decimal](18, 4) NULL,
	[BMI_GDP_C_REAL_PCTCH] [decimal](18, 4) NULL,
	[BMI_GDP_G_REAL_PCTCH] [decimal](18, 4) NULL,
	[BMI_GDP_I_REAL_PCTCH] [decimal](18, 4) NULL,
	[BMI_GDP_X_REAL_PCTCH] [decimal](18, 4) NULL,
	[BMI_GDP_M_REAL_PCTCH] [decimal](18, 4) NULL,
	[BMI_OUTPUT_IP_PCTCH] [decimal](18, 4) NULL,
	[BMI_INFLATION_CPI_AVE_UNIT] [decimal](18, 4) NULL,
	[BMI_INFLATION_PPI_AVE_UNIT] [decimal](18, 4) NULL,
	[BMI_FISCAL_BALANCE_PCTGDP] [decimal](18, 4) NULL,
	[BMI_DEBT_GOVT_PCGDP] [decimal](18, 4) NULL,
	[BMI_POPN_TOTAL_UNIT] [bigint] NULL,
	[BMI_LABOUR_UNEMP_PCT_AVE_UNIT] [decimal](18, 4) NULL,
	[BMI_BOP_CA_BAL_GCU] [decimal](38, 4) NULL,
	[BMI_BOP_CA_BAL_PCGDP] [decimal](18, 4) NULL,
	[BMI_BOP_GS_NX_GCU] [decimal](38, 4) NULL,
	[BMI_BOP_GS_NX_PCGDP] [decimal](18, 4) NULL,
	[BMI_BOP_G_X_GCU] [decimal](38, 4) NULL,
	[BMI_BOP_G_M_GCU] [decimal](38, 4) NULL,
	[BMI_FX_LCU_USD_AVE_UNIT] [decimal](18, 6) NULL,
	[BMI_RESERVES_EXGOLD_GCU] [decimal](38, 4) NULL,
	[BMI_RESERVES_IMPCOVER] [decimal](18, 4) NULL,
	[BMI_DEBT_EXT_GCU] [decimal](38, 4) NULL,
	[BMI_DEBT_EXT_PCGDP] [decimal](18, 4) NULL,
	[BMI_DEBT_EXT_ST_GCU] [decimal](38, 4) NULL,
	[BMI_DEBT_EXT_ST_PCTEXTDEBT] [decimal](18, 4) NULL,
	[BMI_DEBT_EXT_ST_PCTRESERVES] [decimal](18, 4) NULL,
	[BMI_DEBT_EXT_SERV_GCU] [decimal](38, 4) NULL,
	[BMI_INDEX_POLRISK_UNIT_50046_E] [decimal](18, 4) NULL,
	[BMI_INDEX_POLRISK_SECURITY_UNIT_10012_E] [decimal](18, 4) NULL,
	[Update_date] [datetime] NOT NULL';
SET @FilegroupSql += N',
	[Update_user] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
 CONSTRAINT [PK_BMICountryRisk] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE NONCLUSTERED INDEX [IX_Bmi_CountryYear] ON [dbo].[CreditRating_Bmi]
(
	[FK_Country_Id] ASC,
	[Year] ASC
)
INCLUDE([BMI_GDP_NOM_USD_AVE],[BMI_GDP_REAL_PCTCH],[BMI_INFLATION_CPI_AVE_UNIT],[BMI_LABOUR_UNEMP_PCT_AVE_UNIT],[BMI_RESERVES_IMPCOVER],[BMI_DEBT_EXT_PCGDP],[BMI_DEBT_EXT_ST_PCTEXTDEBT],[BMI_FISCAL_BALANCE_PCTGDP],[BMI_DEBT_GOVT_PCGDP],[BMI_INDEX_POLRISK_UNIT_50046_E],[BMI_INDEX_POLRISK_SECURITY_UNIT_10012_E]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
';
IF FILEGROUP_ID(N'NCRMS_IDX') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_IDX]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[CreditRating_Bmi] ADD  CONSTRAINT [DF_BMICountryRisk_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[CreditRating_Bmi] ADD  CONSTRAINT [DF_BMICountryRisk_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'年' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CreditRating_Bmi', @level2type=N'COLUMN',@level2name=N'Year'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[CreditRating_BmiRule](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[RuleName] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[DisplayName] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[BMI_ColumnName] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[ConditionColumn] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[ConditionValue] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[ScoreLevel] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[MinValue] [decimal](18, 4) NULL,
	[MaxValue] [decimal](18, 4) NULL,
	[Score] [float] NULL,
	[SortOrder] [int] NULL,
	[CalculationNotes] [nvarchar](500) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[IsActive] [bit] NULL,
	[CreatedDate] [datetime2](7) NULL,
	[UpdatedDate] [datetime2](7) NULL,
	[IsDisplay] [bit] NOT NULL,
 CONSTRAINT [PK__BMIScori__F4A24B2259A9FA85] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_PADDING ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE NONCLUSTERED INDEX [IX_BmiRule_RuleName_Active] ON [dbo].[CreditRating_BmiRule]
(
	[RuleName] ASC,
	[IsActive] ASC,
	[ScoreLevel] ASC
)
INCLUDE([MinValue],[MaxValue],[Score]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
';
IF FILEGROUP_ID(N'NCRMS_IDX') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_IDX]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[CreditRating_BmiRule] ADD  CONSTRAINT [DF__CreditRat__IsDis__33E06DE7]  DEFAULT ((1)) FOR [IsDisplay]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[CreditRating_CountApi](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_RatingAgency_Id] [int] NOT NULL,
	[CreditRatingType] [int] NOT NULL,
	[Year] [int] NOT NULL,
	[Count] [int] NOT NULL,
	[Create_date] [datetime] NOT NULL,
 CONSTRAINT [PK_CreditRating_CountApi] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE NONCLUSTERED INDEX [IX_CreditRating_CountApi_Agency_Type] ON [dbo].[CreditRating_CountApi]
(
	[FK_RatingAgency_Id] ASC,
	[CreditRatingType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
';
IF FILEGROUP_ID(N'NCRMS_IDX') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_IDX]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[CreditRating_CountApi] ADD  CONSTRAINT [DF_CreditRating_CountApi_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[CreditRating_CountBmi](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_Country_Id] [int] NULL,
	[CountryName] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CountryRating] [int] NULL,
	[TitleCountryRating] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[NominalGDP_Score] [float] NULL,
	[NominalGDP] [float] NULL,
	[RealGDPGrowthIMFAE_Score] [float] NULL,
	[RealGDPGrowthIMFAE] [float] NULL,
	[RealGDPGrowth_Score] [float] NULL,
	[RealGDPGrowth] [float] NULL,
	[ConsumerPriceIMFAE_Score] [float] NULL,
	[ConsumerPriceIMFAE] [float] NULL,
	[ConsumerPrice_Score] [float] NULL,
	[ConsumerPrice] [float] NULL,
	[Unemployment_Score] [float] NULL,
	[Unemployment] [float] NULL,
	[ImportCoverMonths_Score] [float] NULL,
	[ImportCoverMonths] [float] NULL,
	[TotalExternalDebtStock_Score] [float] NULL,
	[TotalExternalDebtStock] [float] NULL,
	[ShortTermExternalDebt_Score] [float] NULL,
	[ShortTermExternalDebt] [float] NULL,
	[BudgetBalance_Score] [float] NULL,
	[BudgetBalance] [float] NULL,
	[TotalGovernmentDebt_Score] [float] NULL,
	[TotalGovernmentDebt] [float] NULL,
	[PoliticalRisk_Score] [int] NULL,
	[PoliticalRisk] [float] NULL,
	[SecurityRisk_Score] [int] NULL,
	[SecurityRisk] [float] NULL,
	[BusinessStrategy_Explain] [nvarchar](500) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[BusinessStrategy] [decimal](5, 1) NULL,
	[CreditRating_Explain] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CreditRating] [int] NULL,
	[Outlook_Explain] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Outlook] [int] NULL,
	[Other_Explain] [nvarchar](500) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Other] [decimal](5, 1) NULL,
	[End_Explain] [nvarchar](500) C';
SET @FilegroupSql += N'OLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[AssessmentDay] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
 CONSTRAINT [PK_TotalCountryRating] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[CreditRating_Country](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_Country_Id] [int] NOT NULL,
	[FK_RatingAgency_Id] [int] NOT NULL,
	[AgencyRating] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[RatingDate] [datetime] NULL,
	[RatingOutlook] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[RatingOutlookDate] [datetime] NULL,
	[Remarks] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[date] [date] NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK__CountryCreditRating_his] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB],
 CONSTRAINT [IX_CreditRating_Country_Week] UNIQUE NONCLUSTERED
(
	[date] ASC,
	[FK_Country_Id] ASC,
	[FK_RatingAgency_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
IF FILEGROUP_ID(N'NCRMS_IDX') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_IDX]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE NONCLUSTERED INDEX [IX_CreditRating_Country_Lookup] ON [dbo].[CreditRating_Country]
(
	[FK_Country_Id] ASC,
	[FK_RatingAgency_Id] ASC,
	[date] ASC
)
INCLUDE([AgencyRating],[RatingOutlook],[RatingOutlookDate],[RatingDate],[Create_date]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
';
IF FILEGROUP_ID(N'NCRMS_IDX') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_IDX]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[CreditRating_Country] ADD  CONSTRAINT [DF_CountryCreditRating_his_AgencyRating]  DEFAULT ('') FOR [AgencyRating]
GO
ALTER TABLE [dbo].[CreditRating_Country] ADD  CONSTRAINT [DF_CountryCreditRating_his_RatingOutlook]  DEFAULT ('') FOR [RatingOutlook]
GO
ALTER TABLE [dbo].[CreditRating_Country] ADD  CONSTRAINT [DF_CountryCreditRating_his_Remarks]  DEFAULT ('') FOR [Remarks]
GO
ALTER TABLE [dbo].[CreditRating_Country] ADD  CONSTRAINT [DF_CreditRating_Country_Week_date]  DEFAULT (getdate()) FOR [date]
GO
ALTER TABLE [dbo].[CreditRating_Country] ADD  CONSTRAINT [DF_CountryCreditRating_his_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[CreditRating_Country] ADD  CONSTRAINT [DF_CountryCreditRating_his_Create_user]  DEFAULT ('system') FOR [Create_user]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'國家ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CreditRating_Country', @level2type=N'COLUMN',@level2name=N'FK_Country_Id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'信評公司ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CreditRating_Country', @level2type=N'COLUMN',@level2name=N'FK_RatingAgency_Id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'信評評分' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CreditRating_Country', @level2type=N'COLUMN',@level2name=N'AgencyRating'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'評級時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CreditRating_Country', @level2type=N'COLUMN',@level2name=N'RatingDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'未來展望' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CreditRating_Country', @level2type=N'COLUMN',@level2name=N'RatingOutlook'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'未來展望時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CreditRating_Country', @level2type=N'COLUMN',@level2name=N'RatingOutlookDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'備註' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CreditRating_Country', @level2type=N'COLUMN',@level2name=N'Remarks'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建置時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CreditRating_Country', @level2type=N'COLUMN',@level2name=N'Create_date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建置者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CreditRating_Country', @level2type=N'COLUMN',@level2name=N'Create_user'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[CreditRating_Country_Current](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_Country_Id] [int] NOT NULL,
	[FK_RatingAgency_Id] [int] NOT NULL,
	[AgencyRating] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[RatingDate] [datetime] NULL,
	[RatingOutlook] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[RatingOutlookDate] [datetime] NULL,
	[Remarks] [nvarchar](500) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[updated_Date] [datetime] NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[PublishedAt] [datetime] NOT NULL,
 CONSTRAINT [PK_CreditRating_Country_Current] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB],
 CONSTRAINT [UQ_CreditRating_Country_Current_Agency_Country] UNIQUE NONCLUSTERED
(
	[FK_RatingAgency_Id] ASC,
	[FK_Country_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
IF FILEGROUP_ID(N'NCRMS_IDX') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_IDX]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[CreditRating_Country_Log](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_CountryId] [int] NOT NULL,
	[Score] [int] NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[BusinessDate] [date] NOT NULL,
 CONSTRAINT [PK_CreditRating_Country_Log] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB],
 CONSTRAINT [UQ_CreditRating_Country_Log_Country_BusinessDate] UNIQUE NONCLUSTERED
(
	[FK_CountryId] ASC,
	[BusinessDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
IF FILEGROUP_ID(N'NCRMS_IDX') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_IDX]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[CreditRating_Country_Log_Detail](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_Country_Id] [int] NOT NULL,
	[FK_RatingAgency_Id] [int] NOT NULL,
	[AgencyRating] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[RatingDate] [datetime] NULL,
	[RatingOutlook] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[RatingOutlookDate] [datetime] NULL,
	[Remarks] [nvarchar](500) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[BusinessDate] [date] NOT NULL,
 CONSTRAINT [PK_CreditRating_Country_Log_Detail] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB],
 CONSTRAINT [UQ_CreditRating_Country_Log_Detail_Country_Agency_BusinessDate] UNIQUE NONCLUSTERED
(
	[FK_Country_Id] ASC,
	[FK_RatingAgency_Id] ASC,
	[BusinessDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
IF FILEGROUP_ID(N'NCRMS_IDX') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_IDX]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[CreditRating_Country_M](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_CountryId] [int] NOT NULL,
	[Score] [int] NOT NULL,
	[Create_date] [datetime] NULL,
 CONSTRAINT [PK_CreditRating_Country_M] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE NONCLUSTERED INDEX [IX_CreditRating_Country_M_Country_CreateDate] ON [dbo].[CreditRating_Country_M]
(
	[FK_CountryId] ASC,
	[Create_date] DESC
)
INCLUDE([Score]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
';
IF FILEGROUP_ID(N'NCRMS_IDX') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_IDX]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[CreditRating_Country_M] ADD  CONSTRAINT [DF_CreditRating_Country_M_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[CreditRating_CountryId](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_AgencyCode_Id] [int] NOT NULL,
	[FK_Country_Id] [int] NOT NULL,
	[EntityId] [int] NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_CountryCreditIdList] PRIMARY KEY CLUSTERED
(
	[FK_AgencyCode_Id] ASC,
	[FK_Country_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE NONCLUSTERED INDEX [IX_CreditRating_CountryId_Agency_Country] ON [dbo].[CreditRating_CountryId]
(
	[FK_AgencyCode_Id] ASC,
	[FK_Country_Id] ASC
)
INCLUDE([EntityId]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
';
IF FILEGROUP_ID(N'NCRMS_IDX') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_IDX]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[CreditRating_CountryId] ADD  CONSTRAINT [DF_CountryCreditIdList_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[CreditRating_CountryId] ADD  CONSTRAINT [DF_CountryCreditIdList_Create_user]  DEFAULT ('') FOR [Create_user]
GO
ALTER TABLE [dbo].[CreditRating_CountryId] ADD  CONSTRAINT [DF_CountryCreditIdList_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[CreditRating_CountryId] ADD  CONSTRAINT [DF_CountryCreditIdList_Update_user]  DEFAULT ('') FOR [Update_user]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'信評公司ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CreditRating_CountryId', @level2type=N'COLUMN',@level2name=N'FK_AgencyCode_Id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'國家代碼ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CreditRating_CountryId', @level2type=N'COLUMN',@level2name=N'FK_Country_Id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'各家信評公司國家ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CreditRating_CountryId', @level2type=N'COLUMN',@level2name=N'EntityId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建置時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CreditRating_CountryId', @level2type=N'COLUMN',@level2name=N'Create_date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建置者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CreditRating_CountryId', @level2type=N'COLUMN',@level2name=N'Create_user'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'更新時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CreditRating_CountryId', @level2type=N'COLUMN',@level2name=N'Update_date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'更新者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CreditRating_CountryId', @level2type=N'COLUMN',@level2name=N'Update_user'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[CreditRating_ErrorCountry](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[Type] [int] NOT NULL,
	[FK_RatingAgency_Id] [int] NOT NULL,
	[FK_CountryId] [int] NULL,
	[ErrorMessage] [nvarchar](1000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Create_date] [datetime] NOT NULL,
	[Count] [int] NOT NULL,
 CONSTRAINT [PK_CreditRating_ErrorCountry] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[CreditRating_ErrorCountry] ADD  CONSTRAINT [DF_CreditRating_ErrorCountry_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[CreditRating_ErrorCountry] ADD  CONSTRAINT [DF_CreditRating_ErrorCountry_Count]  DEFAULT ((0)) FOR [Count]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[CreditRating_ErrorISIN](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[Type] [int] NOT NULL,
	[FK_RatingAgency_Id] [int] NOT NULL,
	[Value] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[ErrorMessage] [nvarchar](1000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Create_date] [datetime] NOT NULL,
	[Count] [int] NOT NULL,
 CONSTRAINT [PK_CreditRating_ErrorISIN] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[CreditRating_ErrorISIN] ADD  CONSTRAINT [DF_CreditRating_ErrorISIN_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[CreditRating_ErrorISIN] ADD  CONSTRAINT [DF_CreditRating_ErrorISIN_Count]  DEFAULT ((0)) FOR [Count]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[CreditRating_ErrorLEI](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[Type] [int] NOT NULL,
	[FK_RatingAgency_Id] [int] NOT NULL,
	[Value] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[ErrorMessage] [nvarchar](1000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Create_date] [datetime] NOT NULL,
	[Count] [int] NOT NULL,
 CONSTRAINT [PK_CreditRating_ErrorLEI] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[CreditRating_ErrorLEI] ADD  CONSTRAINT [DF_CreditRating_ErrorLEI_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[CreditRating_ErrorLEI] ADD  CONSTRAINT [DF_CreditRating_ErrorLEI_Count]  DEFAULT ((0)) FOR [Count]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[CreditRating_LEI](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[CustomerId] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[MoodyLong] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[MoodyShort] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SpLong] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SpShort] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[TrcLong] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[TrcShort] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[FitchLong] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[FitchShort] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[FitchTwLong] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[FitchTwShort] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Create_date] [datetime] NOT NULL,
 CONSTRAINT [PK_CreditRating_LEI] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[CreditRating_LEI] ADD  CONSTRAINT [DF_CreditRating_LEI_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[CreditRating_ScoreMapping](
	[PK_ID] [int] IDENTITY(1,1) NOT NULL,
	[FK_RatingAgencyID] [int] NOT NULL,
	[AgencyRating] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[InternalRatingLevel] [int] NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
 CONSTRAINT [PK__RatingSc__F4A24BC2734E8330] PRIMARY KEY CLUSTERED
(
	[PK_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[CreditRating_ScoreMapping] ADD  CONSTRAINT [DF_RatingScoreMapping_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[CreditRating_ScoreMapping] ADD  CONSTRAINT [DF_RatingScoreMapping_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[CreditRating_ScoreMapping_his](
	[log_id] [int] IDENTITY(1,1) NOT NULL,
	[LogType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[FlowFormId] [int] NULL,
	[PK_ID] [int] NOT NULL,
	[FK_RatingAgencyID] [int] NOT NULL,
	[AgencyRating] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[InternalRatingLevel] [int] NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK__RatingSc__9E2397E01936EAFB] PRIMARY KEY CLUSTERED
(
	[log_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[CreditRating_ScoreMapping_his] ADD  CONSTRAINT [DF_RatingScoreMapping_his_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[CreditRating_ScoreMapping_his] ADD  CONSTRAINT [DF_RatingScoreMapping_his_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[CreditRating_ScoreMapping_his] ADD  CONSTRAINT [DF_RatingScoreMapping_his_SysCreateDate]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'歷史記錄識別碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CreditRating_ScoreMapping_his', @level2type=N'COLUMN',@level2name=N'log_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'異動行為類型 (INSERT/UPDATE/DELETE)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CreditRating_ScoreMapping_his', @level2type=N'COLUMN',@level2name=N'LogType'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[CreditRating_ScoreMapping_temp](
	[TempId] [int] IDENTITY(1,1) NOT NULL,
	[TempType] [int] NOT NULL,
	[FlowFormId] [int] NULL,
	[ModifyType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[PK_ID] [int] NULL,
	[FK_RatingAgencyID] [int] NULL,
	[AgencyRating] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[InternalRatingLevel] [int] NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK__RatingSc__06C703C17AFF38CC] PRIMARY KEY CLUSTERED
(
	[TempId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[CreditRating_ScoreMapping_temp] ADD  CONSTRAINT [DF_RatingScoreMapping_temp_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[CreditRating_ScoreMapping_temp] ADD  CONSTRAINT [DF_RatingScoreMapping_temp_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[CreditRating_ScoreMapping_temp] ADD  CONSTRAINT [DF_RatingScoreMapping_temp_SysCreateDate]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'暫存資料識別碼（流水號）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CreditRating_ScoreMapping_temp', @level2type=N'COLUMN',@level2name=N'TempId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'暫存類型' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CreditRating_ScoreMapping_temp', @level2type=N'COLUMN',@level2name=N'TempType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'流程表單識別碼（外鍵：FLOW_FORM.PK_ID）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CreditRating_ScoreMapping_temp', @level2type=N'COLUMN',@level2name=N'FlowFormId'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[CreditRating_Token](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[Token] [nvarchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Type] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
 CONSTRAINT [PK_CreditRatingsToken] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[CreditRating_Token] ADD  CONSTRAINT [DF_CreditRatingsToken_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[CreditRatingMaster](
	[PK_ID] [int] IDENTITY(1,1) NOT NULL,
	[AgencyCode] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[AgencyName] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK__RatingMa__F4A24BC2B3AEF876] PRIMARY KEY CLUSTERED
(
	[PK_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[CreditRatingMaster] ADD  CONSTRAINT [DF_RatingAgencyMaster_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[CreditRatingMaster] ADD  CONSTRAINT [DF_RatingAgencyMaster_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[Customer](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[GroupId] [int] NULL,
	[CustomerName] [nvarchar](500) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Unit] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CustomerId] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SwiftCode] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LEI] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[ISIN] [nvarchar](12) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Remark] [nvarchar](500) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[IsSystem] [bit] NOT NULL,
	[System_date] [datetime] NOT NULL,
	[Update_date] [datetime] NULL,
	[Update_user] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Create_date] [datetime] NULL,
	[Create_user] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CustomerMark] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SwiftCode4]  AS (left([SwiftCode],(4))),
 CONSTRAINT [PK_Customer] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_PADDING ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE NONCLUSTERED INDEX [IX_Customer_CustomerMark_Match] ON [dbo].[Customer]
(
	[GroupId] ASC,
	[CustomerMark] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
';
IF FILEGROUP_ID(N'NCRMS_IDX') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_IDX]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE NONCLUSTERED INDEX [IX_Customer_GroupId] ON [dbo].[Customer]
(
	[GroupId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
';
IF FILEGROUP_ID(N'NCRMS_IDX') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_IDX]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_PADDING ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE NONCLUSTERED INDEX [IX_Customer_ISIN] ON [dbo].[Customer]
(
	[ISIN] ASC
)
INCLUDE([GroupId]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
';
IF FILEGROUP_ID(N'NCRMS_IDX') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_IDX]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_PADDING ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE NONCLUSTERED INDEX [IX_Customer_ISIN_Match] ON [dbo].[Customer]
(
	[ISIN] ASC
)
INCLUDE([GroupId])
WHERE ([ISIN] IS NOT NULL AND [ISIN]<>'''')
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
';
IF FILEGROUP_ID(N'NCRMS_IDX') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_IDX]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_PADDING ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE NONCLUSTERED INDEX [IX_Customer_LEI] ON [dbo].[Customer]
(
	[LEI] ASC
)
INCLUDE([GroupId]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
';
IF FILEGROUP_ID(N'NCRMS_IDX') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_IDX]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_PADDING ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE NONCLUSTERED INDEX [IX_Customer_LEI_Match] ON [dbo].[Customer]
(
	[LEI] ASC
)
INCLUDE([GroupId])
WHERE ([LEI] IS NOT NULL AND [LEI]<>'''')
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
';
IF FILEGROUP_ID(N'NCRMS_IDX') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_IDX]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_PADDING ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE NONCLUSTERED INDEX [IX_Customer_SwiftCode] ON [dbo].[Customer]
(
	[SwiftCode] ASC
)
INCLUDE([GroupId]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
';
IF FILEGROUP_ID(N'NCRMS_IDX') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_IDX]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE NONCLUSTERED INDEX [IX_Customer_SwiftCode4_Match] ON [dbo].[Customer]
(
	[SwiftCode4] ASC
)
INCLUDE([GroupId])
WHERE ([SwiftCode] IS NOT NULL AND [SwiftCode]<>'''')
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
';
IF FILEGROUP_ID(N'NCRMS_IDX') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_IDX]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_PADDING ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE UNIQUE NONCLUSTERED INDEX [UX_Customer_Name_Unit] ON [dbo].[Customer]
(
	[CustomerName] ASC,
	[Unit] ASC,
	[CustomerId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
';
IF FILEGROUP_ID(N'NCRMS_IDX') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_IDX]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[Customer] ADD  CONSTRAINT [DF_Customer_IsSystem]  DEFAULT ((1)) FOR [IsSystem]
GO
ALTER TABLE [dbo].[Customer] ADD  CONSTRAINT [DF_Customer_System_date]  DEFAULT (getdate()) FOR [System_date]
GO
ALTER TABLE [dbo].[Customer] ADD  CONSTRAINT [DF_Customer_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[Customer] ADD  CONSTRAINT [DF_Customer_Update_user]  DEFAULT (N'system') FOR [Update_user]
GO
ALTER TABLE [dbo].[Customer] ADD  CONSTRAINT [DF_Customer_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[Customer] ADD  CONSTRAINT [DF_Customer_Create_user]  DEFAULT (N'system') FOR [Create_user]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'客戶名稱' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'CustomerName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'客戶單位' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'Unit'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'客戶Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'CustomerId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'註記' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'Remark'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'是否為系統自動歸戶' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'IsSystem'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'歸戶時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'System_date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'客戶自行標記(歸戶用)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'CustomerMark'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[Customer_his](
	[Log_Id] [int] IDENTITY(1,1) NOT NULL,
	[LogType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[FlowFormId] [int] NOT NULL,
	[PK_Id] [int] NOT NULL,
	[GroupId] [int] NULL,
	[CustomerName] [nvarchar](500) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Unit] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CustomerId] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SwiftCode] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LEI] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[ISIN] [nvarchar](12) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Remark] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[IsSystem] [bit] NOT NULL,
	[System_date] [datetime] NOT NULL,
	[Update_date] [datetime] NULL,
	[Update_user] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Create_date] [datetime] NULL,
	[Create_user] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[CustomerMark] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
 CONSTRAINT [PK__Customer__2D26E78E5F476C2D] PRIMARY KEY CLUSTERED
(
	[Log_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[Customer_his] ADD  CONSTRAINT [DF__Customer___SysCr__25083EAB]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'歷史記錄識別碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer_his', @level2type=N'COLUMN',@level2name=N'Log_Id'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[Customer_temp](
	[TempId] [int] IDENTITY(1,1) NOT NULL,
	[FlowFormId] [int] NULL,
	[ModifyType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[PK_Id] [int] NOT NULL,
	[GroupId] [int] NULL,
	[CustomerName] [nvarchar](500) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Unit] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CustomerId] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SwiftCode] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LEI] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[ISIN] [nvarchar](12) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Remark] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[IsSystem] [bit] NOT NULL,
	[System_date] [datetime] NOT NULL,
	[Update_date] [datetime] NULL,
	[Update_user] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Create_date] [datetime] NULL,
	[Create_user] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[CustomerMark] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
 CONSTRAINT [PK__Customer__06C703C189975D63] PRIMARY KEY CLUSTERED
(
	[TempId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[Customer_temp] ADD  CONSTRAINT [DF__Customer___IsSys__1B7ED471]  DEFAULT ((1)) FOR [IsSystem]
GO
ALTER TABLE [dbo].[Customer_temp] ADD  CONSTRAINT [DF__Customer___Syste__1C72F8AA]  DEFAULT (getdate()) FOR [System_date]
GO
ALTER TABLE [dbo].[Customer_temp] ADD  CONSTRAINT [DF__Customer___Updat__1D671CE3]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[Customer_temp] ADD  CONSTRAINT [DF__Customer___Updat__1E5B411C]  DEFAULT (N'system') FOR [Update_user]
GO
ALTER TABLE [dbo].[Customer_temp] ADD  CONSTRAINT [DF__Customer___Creat__1F4F6555]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[Customer_temp] ADD  CONSTRAINT [DF__Customer___Creat__2043898E]  DEFAULT (N'system') FOR [Create_user]
GO
ALTER TABLE [dbo].[Customer_temp] ADD  CONSTRAINT [DF__Customer___SysCr__2137ADC7]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'暫存資料識別碼（流水號）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer_temp', @level2type=N'COLUMN',@level2name=N'TempId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'流程表單識別碼（外鍵：FlowForm.PK_ID）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer_temp', @level2type=N'COLUMN',@level2name=N'FlowFormId'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[DAILY_CIF_TMP](
	[CIF_ID_NO] [char](11) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[CIF_CUST_NAME] [char](40) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CIF_NATION_CODE] [char](4) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CIF_EXT_DATE] [date] NULL,
	[CIF_LOAD_DATE] [char](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CIF_LOAD_TIME] [char](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
 CONSTRAINT [PK_DAILY_CIF_TMP] PRIMARY KEY CLUSTERED
(
	[CIF_ID_NO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_PADDING OFF
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[ExcelTemplate](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[Excel_Template_Code] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Excel_Sheet_Name] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Excel_Template_Filename] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Column_Id] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Column_Name] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Row] [int] NOT NULL,
	[Col] [int] NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_ExcelTemplate] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_PADDING ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE NONCLUSTERED INDEX [IX_ExcelTemplate] ON [dbo].[ExcelTemplate]
(
	[Excel_Template_Code] ASC,
	[Excel_Template_Filename] ASC,
	[Excel_Sheet_Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
';
IF FILEGROUP_ID(N'NCRMS_IDX') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_IDX]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[ExcelTemplate] ADD  CONSTRAINT [DF_ExcelTemplate_Excel_Template_Code]  DEFAULT ('') FOR [Excel_Template_Code]
GO
ALTER TABLE [dbo].[ExcelTemplate] ADD  CONSTRAINT [DF_ExcelTemplate_Excel_Template_Filename]  DEFAULT ('') FOR [Excel_Template_Filename]
GO
ALTER TABLE [dbo].[ExcelTemplate] ADD  CONSTRAINT [DF_ExcelTemplate_Column_Id]  DEFAULT ('') FOR [Column_Id]
GO
ALTER TABLE [dbo].[ExcelTemplate] ADD  CONSTRAINT [DF_ExcelTemplate_Column_Name]  DEFAULT ('') FOR [Column_Name]
GO
ALTER TABLE [dbo].[ExcelTemplate] ADD  CONSTRAINT [DF_ExcelTemplate_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[ExcelTemplate] ADD  CONSTRAINT [DF_ExcelTemplate_Update_user]  DEFAULT ('system') FOR [Update_user]
GO
ALTER TABLE [dbo].[ExcelTemplate] ADD  CONSTRAINT [DF_ExcelTemplate_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[ExcelTemplate] ADD  CONSTRAINT [DF_ExcelTemplate_Create_user]  DEFAULT ('system') FOR [Create_user]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'範本Code' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExcelTemplate', @level2type=N'COLUMN',@level2name=N'Excel_Template_Code'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'範本名稱' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExcelTemplate', @level2type=N'COLUMN',@level2name=N'Excel_Sheet_Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'範本檔名' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExcelTemplate', @level2type=N'COLUMN',@level2name=N'Excel_Template_Filename'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'對應Dto參數名' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExcelTemplate', @level2type=N'COLUMN',@level2name=N'Column_Id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'參數名稱' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExcelTemplate', @level2type=N'COLUMN',@level2name=N'Column_Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'列' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExcelTemplate', @level2type=N'COLUMN',@level2name=N'Row'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'欄' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExcelTemplate', @level2type=N'COLUMN',@level2name=N'Col'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'更新時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExcelTemplate', @level2type=N'COLUMN',@level2name=N'Update_date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'更新者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExcelTemplate', @level2type=N'COLUMN',@level2name=N'Update_user'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建置時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExcelTemplate', @level2type=N'COLUMN',@level2name=N'Create_date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建置者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExcelTemplate', @level2type=N'COLUMN',@level2name=N'Create_user'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[FeatureDetail](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[MenuId] [int] NULL,
	[Feature_Describe] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Seq] [int] NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_FEATURE] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[FeatureDetail] ADD  CONSTRAINT [DF_FEATURE_Feature_Describe]  DEFAULT ('') FOR [Feature_Describe]
GO
ALTER TABLE [dbo].[FeatureDetail] ADD  CONSTRAINT [DF_FeatureDetail_seq]  DEFAULT ((1)) FOR [Seq]
GO
ALTER TABLE [dbo].[FeatureDetail] ADD  CONSTRAINT [DF_FeatureDetail_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[FeatureDetail] ADD  CONSTRAINT [DF_FEATURE_Update_user]  DEFAULT ('') FOR [Update_user]
GO
ALTER TABLE [dbo].[FeatureDetail] ADD  CONSTRAINT [DF_FeatureDetail_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[FeatureDetail] ADD  CONSTRAINT [DF_FEATURE_Create_user]  DEFAULT ('') FOR [Create_user]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'功能' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FeatureDetail', @level2type=N'COLUMN',@level2name=N'Feature_Describe'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[FileCenter](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[File_Type] [int] NOT NULL,
	[FilePath] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[FileName] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Memo] [nvarchar](500) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[File_Extension] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_FileCenter] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[FileCenter] ADD  CONSTRAINT [DF_FileCenter_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[FileCenter] ADD  CONSTRAINT [DF_FileCenter_Update_user]  DEFAULT ('system') FOR [Update_user]
GO
ALTER TABLE [dbo].[FileCenter] ADD  CONSTRAINT [DF_FileCenter_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[FileCenter] ADD  CONSTRAINT [DF_FileCenter_Create_user]  DEFAULT ('system') FOR [Create_user]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Global內，檔案分類' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FileCenter', @level2type=N'COLUMN',@level2name=N'File_Type'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'檔案絕對路徑' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FileCenter', @level2type=N'COLUMN',@level2name=N'FilePath'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'檔案描述' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FileCenter', @level2type=N'COLUMN',@level2name=N'FileName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'備註' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FileCenter', @level2type=N'COLUMN',@level2name=N'Memo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'副檔名' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FileCenter', @level2type=N'COLUMN',@level2name=N'File_Extension'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'更新時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FileCenter', @level2type=N'COLUMN',@level2name=N'Update_date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'更新者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FileCenter', @level2type=N'COLUMN',@level2name=N'Update_user'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建置時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FileCenter', @level2type=N'COLUMN',@level2name=N'Create_date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建置者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FileCenter', @level2type=N'COLUMN',@level2name=N'Create_user'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[FileCenter_Downloads](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_FileId] [int] NOT NULL,
	[Downloads] [int] NOT NULL,
 CONSTRAINT [PK_FileCenter_Downloads] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[FileCenter_Downloads] ADD  CONSTRAINT [DF_FileCenter_Downloads_Downloads]  DEFAULT ((0)) FOR [Downloads]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[FinancialProductMaster](
	[PK_ID] [int] IDENTITY(1,1) NOT NULL,
	[FK_GlobalID_FinancialProductCategory] [int] NOT NULL,
	[ProductTypeName] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[ProductCode] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[IsActive] [bit] NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK__Financia__F4A24BC2373C7412] PRIMARY KEY CLUSTERED
(
	[PK_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[FinancialProductMaster] ADD  CONSTRAINT [DF_FinancialProductMaster_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[FinancialProductMaster] ADD  CONSTRAINT [DF_FinancialProductMaster_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[FinancialProductMaster] ADD  CONSTRAINT [DF_FinancialProductMaster_Update_user]  DEFAULT ('system') FOR [Update_user]
GO
ALTER TABLE [dbo].[FinancialProductMaster] ADD  CONSTRAINT [DF_FinancialProductMaster_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[FinancialProductMaster] ADD  CONSTRAINT [DF_FinancialProductMaster_Create_user]  DEFAULT ('system') FOR [Create_user]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'商品分類，Global內' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FinancialProductMaster', @level2type=N'COLUMN',@level2name=N'FK_GlobalID_FinancialProductCategory'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'描述' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FinancialProductMaster', @level2type=N'COLUMN',@level2name=N'ProductTypeName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'代碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FinancialProductMaster', @level2type=N'COLUMN',@level2name=N'ProductCode'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'是否啟用' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FinancialProductMaster', @level2type=N'COLUMN',@level2name=N'IsActive'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'更新時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FinancialProductMaster', @level2type=N'COLUMN',@level2name=N'Update_date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'更新者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FinancialProductMaster', @level2type=N'COLUMN',@level2name=N'Update_user'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建置時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FinancialProductMaster', @level2type=N'COLUMN',@level2name=N'Create_date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建置者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FinancialProductMaster', @level2type=N'COLUMN',@level2name=N'Create_user'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[FinancialProductMaster_his](
	[Log_Id] [int] IDENTITY(1,1) NOT NULL,
	[LogType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[FlowFormId] [int] NOT NULL,
	[PK_ID] [int] NOT NULL,
	[FK_GlobalID_FinancialProductCategory] [int] NOT NULL,
	[ProductTypeName] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[ProductCode] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[IsActive] [bit] NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK__Financia__2D26E78E6A71B569] PRIMARY KEY CLUSTERED
(
	[Log_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[FinancialProductMaster_his] ADD  CONSTRAINT [DF__Financial__SysCr__2CD37DA5]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'歷史記錄識別碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FinancialProductMaster_his', @level2type=N'COLUMN',@level2name=N'Log_Id'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[FinancialProductMaster_temp](
	[TempId] [int] IDENTITY(1,1) NOT NULL,
	[FlowFormId] [int] NULL,
	[ModifyType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[PK_ID] [int] NOT NULL,
	[FK_GlobalID_FinancialProductCategory] [int] NOT NULL,
	[ProductTypeName] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[ProductCode] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[IsActive] [bit] NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK__Financia__06C703C14E5F190D] PRIMARY KEY CLUSTERED
(
	[TempId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[FinancialProductMaster_temp] ADD  CONSTRAINT [DF__Financial__IsAct__2FAFEA50]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[FinancialProductMaster_temp] ADD  CONSTRAINT [DF__Financial__Updat__30A40E89]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[FinancialProductMaster_temp] ADD  CONSTRAINT [DF__Financial__Updat__319832C2]  DEFAULT ('system') FOR [Update_user]
GO
ALTER TABLE [dbo].[FinancialProductMaster_temp] ADD  CONSTRAINT [DF__Financial__Creat__328C56FB]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[FinancialProductMaster_temp] ADD  CONSTRAINT [DF__Financial__Creat__33807B34]  DEFAULT ('system') FOR [Create_user]
GO
ALTER TABLE [dbo].[FinancialProductMaster_temp] ADD  CONSTRAINT [DF__Financial__SysCr__34749F6D]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'暫存資料識別碼（流水號）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FinancialProductMaster_temp', @level2type=N'COLUMN',@level2name=N'TempId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'流程表單識別碼（外鍵：FlowForm.PK_ID）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FinancialProductMaster_temp', @level2type=N'COLUMN',@level2name=N'FlowFormId'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[FinancialRiskFactorData](
	[PK_ID] [int] IDENTITY(1,1) NOT NULL,
	[FK_ProductID] [int] NOT NULL,
	[FK_PeriodID] [int] NOT NULL,
	[RiskFactor] [decimal](10, 2) NULL,
	[Version] [int] NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
 CONSTRAINT [PK__Financia__F4A24BC24E8BFDB1] PRIMARY KEY CLUSTERED
(
	[PK_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[FinancialRiskFactorData] ADD  CONSTRAINT [DF_FinancialRiskFactorData_Create_Date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[FinancialRiskFactorData] ADD  CONSTRAINT [DF_FinancialRiskFactorData_Update_Date]  DEFAULT (getdate()) FOR [Update_date]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[FinancialRiskFactorData_his](
	[Log_id] [int] IDENTITY(1,1) NOT NULL,
	[LogType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Fk_logId] [int] NOT NULL,
	[PK_ID] [int] NOT NULL,
	[FK_ProductID] [int] NOT NULL,
	[FK_PeriodID] [int] NOT NULL,
	[RiskFactor] [decimal](10, 2) NOT NULL,
	[Version] [int] NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK__Financia__2D21E3B6961DAD7C] PRIMARY KEY CLUSTERED
(
	[Log_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[FinancialRiskFactorData_his] ADD  CONSTRAINT [DF__Financial__SysCr__38453051]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'歷史記錄識別碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FinancialRiskFactorData_his', @level2type=N'COLUMN',@level2name=N'Log_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'異動行為類型 (INSERT/UPDATE/DELETE)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FinancialRiskFactorData_his', @level2type=N'COLUMN',@level2name=N'LogType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立日期時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FinancialRiskFactorData_his', @level2type=N'COLUMN',@level2name=N'SysCreateDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立使用者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FinancialRiskFactorData_his', @level2type=N'COLUMN',@level2name=N'SysCreateUser'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[FinancialRiskFactorData_temp](
	[TempId] [int] IDENTITY(1,1) NOT NULL,
	[FK_TempId] [int] NOT NULL,
	[ModifyType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[PK_ID] [int] NULL,
	[FK_ProductID] [int] NULL,
	[FK_PeriodID] [int] NULL,
	[RiskFactor] [decimal](10, 2) NULL,
	[Version] [int] NULL,
	[Create_date] [datetime] NULL,
	[Create_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Update_date] [datetime] NULL,
	[Update_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK__Financia__06C703C1E0839792] PRIMARY KEY CLUSTERED
(
	[TempId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[FinancialRiskFactorData_temp] ADD  CONSTRAINT [DF__Financial__Creat__3B219CFC]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[FinancialRiskFactorData_temp] ADD  CONSTRAINT [DF__Financial__Updat__3C15C135]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[FinancialRiskFactorData_temp] ADD  CONSTRAINT [DF__Financial__SysCr__3D09E56E]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'暫存資料識別碼（流水號）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FinancialRiskFactorData_temp', @level2type=N'COLUMN',@level2name=N'TempId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'主表暫存資料外鍵' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FinancialRiskFactorData_temp', @level2type=N'COLUMN',@level2name=N'FK_TempId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'異動類型' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FinancialRiskFactorData_temp', @level2type=N'COLUMN',@level2name=N'ModifyType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立日期時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FinancialRiskFactorData_temp', @level2type=N'COLUMN',@level2name=N'SysCreateDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立使用者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FinancialRiskFactorData_temp', @level2type=N'COLUMN',@level2name=N'SysCreateUser'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[FinancialRiskFactorPeriodDay](
	[PK_ID] [int] IDENTITY(1,1) NOT NULL,
	[PeriodName] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[MinDays] [int] NOT NULL,
	[MaxDays] [int] NULL,
	[SEQ] [int] NOT NULL,
	[IsActive] [bit] NULL,
	[Create_Date] [datetime] NOT NULL,
	[Create_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Update_Date] [datetime] NOT NULL,
	[Update_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
 CONSTRAINT [PK__Financia__F4A24BC22B9435D7] PRIMARY KEY CLUSTERED
(
	[PK_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[FinancialRiskFactorPeriodDay] ADD  CONSTRAINT [DF_FinancialRiskFactorPeriodDay_Create_Date]  DEFAULT (getdate()) FOR [Create_Date]
GO
ALTER TABLE [dbo].[FinancialRiskFactorPeriodDay] ADD  CONSTRAINT [DF_FinancialRiskFactorPeriodDay_Update_Date]  DEFAULT (getdate()) FOR [Update_Date]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[FinancialRiskFactorPeriodDay_his](
	[Log_id] [int] IDENTITY(1,1) NOT NULL,
	[LogType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Fk_logId] [int] NOT NULL,
	[PK_ID] [int] NOT NULL,
	[PeriodName] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[MinDays] [int] NOT NULL,
	[MaxDays] [int] NULL,
	[SEQ] [int] NOT NULL,
	[IsActive] [bit] NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK__Financia__2D21E3B63246A814] PRIMARY KEY CLUSTERED
(
	[Log_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[FinancialRiskFactorPeriodDay_his] ADD  CONSTRAINT [DF__Financial__SysCr__44AB0736]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'歷史記錄識別碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FinancialRiskFactorPeriodDay_his', @level2type=N'COLUMN',@level2name=N'Log_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'異動行為類型 (INSERT/UPDATE/DELETE)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FinancialRiskFactorPeriodDay_his', @level2type=N'COLUMN',@level2name=N'LogType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立日期時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FinancialRiskFactorPeriodDay_his', @level2type=N'COLUMN',@level2name=N'SysCreateDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立使用者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FinancialRiskFactorPeriodDay_his', @level2type=N'COLUMN',@level2name=N'SysCreateUser'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[FinancialRiskFactorPeriodDay_temp](
	[TempId] [int] IDENTITY(1,1) NOT NULL,
	[FK_TempId] [int] NOT NULL,
	[ModifyType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[PK_ID] [int] NULL,
	[PeriodName] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[MinDays] [int] NULL,
	[MaxDays] [int] NULL,
	[SEQ] [int] NULL,
	[IsActive] [bit] NULL,
	[Create_date] [datetime] NULL,
	[Create_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Update_date] [datetime] NULL,
	[Update_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK__Financia__06C703C1D1A2D7A9] PRIMARY KEY CLUSTERED
(
	[TempId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[FinancialRiskFactorPeriodDay_temp] ADD  CONSTRAINT [DF__Financial__Creat__3FE65219]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[FinancialRiskFactorPeriodDay_temp] ADD  CONSTRAINT [DF__Financial__Updat__40DA7652]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[FinancialRiskFactorPeriodDay_temp] ADD  CONSTRAINT [DF__Financial__SysCr__41CE9A8B]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'暫存資料識別碼（流水號）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FinancialRiskFactorPeriodDay_temp', @level2type=N'COLUMN',@level2name=N'TempId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'主表暫存資料外鍵' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FinancialRiskFactorPeriodDay_temp', @level2type=N'COLUMN',@level2name=N'FK_TempId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'異動類型' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FinancialRiskFactorPeriodDay_temp', @level2type=N'COLUMN',@level2name=N'ModifyType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立日期時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FinancialRiskFactorPeriodDay_temp', @level2type=N'COLUMN',@level2name=N'SysCreateDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立使用者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FinancialRiskFactorPeriodDay_temp', @level2type=N'COLUMN',@level2name=N'SysCreateUser'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[FL_FLMST_D_MF](
	[FLMST_CUST_ID] [nvarchar](11) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[FLMST_LC_NO] [nvarchar](11) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[FLMST_DATA_TYPE] [nvarchar](1) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[FLMST_RECV_BRANCH] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[FLMST_CURENCY] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[FLMST_DATA_STATUS] [nvarchar](1) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[FLMST_ACNT_BRANCH] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[FLMST_MATURITY] [date] NULL,
	[FLMST_NEGO_DATE] [date] NULL,
	[FLMST_LOAN_TYPE] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[FLMST_ADVANCE_BALANCE] [decimal](15, 2) NULL,
	[FLMST_SUBSTITUTE_REMIT_MK] [nvarchar](1) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[FLMST_APRV_NO_1] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[FLMST_APRV_TYPE_1] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[FLMST_APRV_CUR_1] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[FLMST_EXT_DATE] [date] NULL,
	[FLMST_FINAL_RISK_CNTY] [nvarchar](4) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[BUSINS_CODE] [nvarchar](7) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Create_Date] [date] NULL
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[FL_FLMST_D_MF] ADD  CONSTRAINT [DF_FL_FLMST_D_MF_Create_Date]  DEFAULT (getdate()) FOR [Create_Date]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'統編
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FL_FLMST_D_MF', @level2type=N'COLUMN',@level2name=N'FLMST_CUST_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'外幣貸款編號
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FL_FLMST_D_MF', @level2type=N'COLUMN',@level2name=N'FLMST_LC_NO'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'資料種類
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FL_FLMST_D_MF', @level2type=N'COLUMN',@level2name=N'FLMST_DATA_TYPE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'受理行' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FL_FLMST_D_MF', @level2type=N'COLUMN',@level2name=N'FLMST_RECV_BRANCH'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'幣別
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FL_FLMST_D_MF', @level2type=N'COLUMN',@level2name=N'FLMST_CURENCY'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'主檔狀況' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FL_FLMST_D_MF', @level2type=N'COLUMN',@level2name=N'FLMST_DATA_STATUS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'帳務單位' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FL_FLMST_D_MF', @level2type=N'COLUMN',@level2name=N'FLMST_ACNT_BRANCH'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'貸款到期日' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FL_FLMST_D_MF', @level2type=N'COLUMN',@level2name=N'FLMST_MATURITY'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'押匯日(初貸日)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FL_FLMST_D_MF', @level2type=N'COLUMN',@level2name=N'FLMST_NEGO_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'貸放種類
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FL_FLMST_D_MF', @level2type=N'COLUMN',@level2name=N'FLMST_LOAN_TYPE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'墊款餘額(放款餘額)
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FL_FLMST_D_MF', @level2type=N'COLUMN',@level2name=N'FLMST_ADVANCE_BALANCE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'資金用途' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FL_FLMST_D_MF', @level2type=N'COLUMN',@level2name=N'FLMST_SUBSTITUTE_REMIT_MK'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'核准號碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FL_FLMST_D_MF', @level2type=N'COLUMN',@level2name=N'FLMST_APRV_NO_1'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'額度種類
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FL_FLMST_D_MF', @level2type=N'COLUMN',@level2name=N'FLMST_APRV_TYPE_1'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'核准幣別' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FL_FLMST_D_MF', @level2type=N'COLUMN',@level2name=N'FLMST_APRV_CUR_1'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'資料日期
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FL_FLMST_D_MF', @level2type=N'COLUMN',@level2name=N'FLMST_EXT_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'最終風險國家
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FL_FLMST_D_MF', @level2type=N'COLUMN',@level2name=N'FLMST_FINAL_RISK_CNTY'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'產業別' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FL_FLMST_D_MF', @level2type=N'COLUMN',@level2name=N'BUSINS_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建置時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FL_FLMST_D_MF', @level2type=N'COLUMN',@level2name=N'Create_Date'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[Flow](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_Menu_ID] [int] NOT NULL,
	[Name_TN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Name_CN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Name_EN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Name_JP] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[IsActive] [bit] NOT NULL,
	[VersionNo] [varchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [varchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [varchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_Flow] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[Flow] ADD  CONSTRAINT [DF_Flow_VersionNo]  DEFAULT ('1.0.0') FOR [VersionNo]
GO
ALTER TABLE [dbo].[Flow] ADD  CONSTRAINT [DF_Flow_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[Flow] ADD  CONSTRAINT [DF_Flow_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[FlowDetail](
	[PK_Id] [uniqueidentifier] NOT NULL,
	[FK_Flow_Id] [int] NOT NULL,
	[TitleId] [int] NULL,
	[Name_TN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Name_CN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Name_EN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Name_JP] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[ElsType] [int] NOT NULL,
	[Stage] [int] NOT NULL,
	[Seq] [int] NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [varchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [varchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_FlowDetail] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[FlowDetail] ADD  CONSTRAINT [DF_FlowDetail_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[FlowDetail] ADD  CONSTRAINT [DF_FlowDetail_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[FlowFileMapping](
	[PK_ID] [int] IDENTITY(1,1) NOT NULL,
	[FlowRecordId] [int] NOT NULL,
	[FileCenterId] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK__Flow_att__F4A24BC22201BC54] PRIMARY KEY CLUSTERED
(
	[PK_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[FlowFileMapping] ADD  CONSTRAINT [DF_FlowFileMapping_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[FlowForm](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[ParentId] [int] NULL,
	[RootFlowFormId] [int] NULL,
	[FormType] [int] NULL,
	[FlowId] [int] NOT NULL,
	[FlowActionType] [int] NOT NULL,
	[ApplicantId] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[ApplicantGroupCode] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[ApplicantUnitCode] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[ApplicantBranchCode] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[ApplicantDepartmentCode] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[ApplicantTitleId] [int] NOT NULL,
	[ApplicantContent] [nvarchar](500) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[StepId] [uniqueidentifier] NOT NULL,
	[Handler] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[HandlerGroupCode] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[HandlerUnitCode] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[HandlerBranchCode] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[HandlerDepartmentCode] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[HandlerTitleCode] [int] NOT NULL,
	[TotalSteps] [int] NOT NULL,
	[EndDate] [datetime] NULL,
	[EndStepId] [uniqueidentifier] NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK__FLOW_FOR__F4A24BC2CE3A3F8B] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PA';
SET @FilegroupSql += N'GE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[FlowForm] ADD  CONSTRAINT [DF_FlowForm_ApplicantGroupCode]  DEFAULT ('') FOR [ApplicantGroupCode]
GO
ALTER TABLE [dbo].[FlowForm] ADD  CONSTRAINT [DF_FlowForm_ApplicantDepartmentCode]  DEFAULT ('') FOR [ApplicantDepartmentCode]
GO
ALTER TABLE [dbo].[FlowForm] ADD  CONSTRAINT [DF_FlowForm_HandlerGroupCode]  DEFAULT ('') FOR [HandlerGroupCode]
GO
ALTER TABLE [dbo].[FlowForm] ADD  CONSTRAINT [DF_FlowForm_HandlerUnitCode]  DEFAULT ('') FOR [HandlerUnitCode]
GO
ALTER TABLE [dbo].[FlowForm] ADD  CONSTRAINT [DF_FlowForm_HandlerDepartmentCode]  DEFAULT ('') FOR [HandlerDepartmentCode]
GO
ALTER TABLE [dbo].[FlowForm] ADD  CONSTRAINT [DF_FlowForm_HandlerTitleCode]  DEFAULT ((0)) FOR [HandlerTitleCode]
GO
ALTER TABLE [dbo].[FlowForm] ADD  CONSTRAINT [DF_FlowForm_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[FlowForm] ADD  CONSTRAINT [DF_FlowForm_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'48 = 加簽單' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FlowForm', @level2type=N'COLUMN',@level2name=N'FormType'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[FlowForm_LoanMain](
	[FlowFormId] [int] NOT NULL,
	[LoanCountryId] [int] NOT NULL,
	[LoanMethodType] [int] NOT NULL,
	[LoanUnit] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[FinalLoanUnit] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[ApplyUSDAmount] [int] NOT NULL,
	[ApplyUSDDate] [datetime] NOT NULL,
	[ApproveUSDAmount] [int] NULL,
	[IsRepay] [bit] NOT NULL,
	[RealRepayDate] [datetime] NULL,
	[IsApproved] [bit] NOT NULL,
	[RepayDate] [date] NOT NULL,
	[ApproveDate] [datetime] NULL,
	[EndDate] [datetime] NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_FlowForm_LoanMain] PRIMARY KEY CLUSTERED
(
	[FlowFormId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[FlowForm_LoanMain] ADD  CONSTRAINT [DF__FlowForm___LoanM__46741F6E]  DEFAULT ((0)) FOR [LoanMethodType]
GO
ALTER TABLE [dbo].[FlowForm_LoanMain] ADD  CONSTRAINT [DF__FlowForm___IsRep__476843A7]  DEFAULT ((0)) FOR [IsRepay]
GO
ALTER TABLE [dbo].[FlowForm_LoanMain] ADD  CONSTRAINT [DF_FlowForm_LoanMain_IsApproved]  DEFAULT ((0)) FOR [IsApproved]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[FlowModifyRecord](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FormId] [int] NOT NULL,
	[StepId] [uniqueidentifier] NOT NULL,
	[Field] [nvarchar](255) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[NewValue] [nvarchar](255) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[OldValue] [nvarchar](255) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_FlowModifyRecord] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[FlowModifyRecord] ADD  CONSTRAINT [DF_FlowModifyRecord_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[FlowRecord](
	[PK_id] [int] IDENTITY(1,1) NOT NULL,
	[FlowFormId] [int] NOT NULL,
	[FlowDetailId] [uniqueidentifier] NOT NULL,
	[OriginHandler] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[OriginHandlerGroupCode] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[OriginHandlerUnitCode] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[OriginHandlerBranchCode] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[OriginHandlerTitleCode] [int] NOT NULL,
	[OriginDepartmentCode] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[ApproverId] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[ApproverTitleId] [int] NOT NULL,
	[ApproverUnitCode] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[FlowActionType] [int] NULL,
	[ApproverComments] [nvarchar](255) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
 CONSTRAINT [PK__FLOW_REC__F4A5475AB0442D71] PRIMARY KEY CLUSTERED
(
	[PK_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[FlowRecord] ADD  CONSTRAINT [DF_FlowRecord_OriginHandler]  DEFAULT ('') FOR [OriginHandler]
GO
ALTER TABLE [dbo].[FlowRecord] ADD  CONSTRAINT [DF_FlowRecord_OriginHnadlerGroupCode]  DEFAULT ('') FOR [OriginHandlerGroupCode]
GO
ALTER TABLE [dbo].[FlowRecord] ADD  CONSTRAINT [DF_FlowRecord_OriginHandlerUnitCode]  DEFAULT ('') FOR [OriginHandlerUnitCode]
GO
ALTER TABLE [dbo].[FlowRecord] ADD  CONSTRAINT [DF_FlowRecord_OriginHandlerTitleCode]  DEFAULT ((0)) FOR [OriginHandlerTitleCode]
GO
ALTER TABLE [dbo].[FlowRecord] ADD  CONSTRAINT [DF_FlowRecord_OriginDepartmentCode]  DEFAULT ('') FOR [OriginDepartmentCode]
GO
ALTER TABLE [dbo].[FlowRecord] ADD  CONSTRAINT [DF_FlowRecord_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[FlowUserReset](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FlowId] [int] NOT NULL,
	[WarningType] [int] NOT NULL,
	[UserId_Before] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[UserId_After] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_FlowUserReset] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[FM_FMLINE_D_MF](
	[FMLINE_CUST_ID] [nvarchar](11) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[FMLINE_DATE_TYPE] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[FMLINE_BRANCH] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[FMLINE_LINE_TYPE] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[FMLINE_APRV_NO] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[FMLINE_APRV_DATE] [date] NULL,
	[FMLINE_REVOLING_TYPE] [nvarchar](1) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[FMLINE_LINE_EXPIRY] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[FMLINE_LINE_AMT] [decimal](15, 2) NULL,
	[FMLINE_MULT_MERGED_MARK] [nvarchar](1) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[FMLINE_MULT_MERGED_APRV_NO] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[FMLINE_LINE_CURENCY] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[FMLINE_EXT_DATE] [date] NULL,
	[BUSINS_CODE] [nvarchar](7) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Create_Date] [date] NOT NULL
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[FM_FMLINE_D_MF] ADD  CONSTRAINT [DF_FM_FMLINE_D_MF_Create_Date]  DEFAULT (getdate()) FOR [Create_Date]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[ForexRate](
	[ForexRateCode] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[ForexRateDate] [date] NOT NULL,
	[CURNCY_Code] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[CURNCY_Name] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[ForexRateValue] [decimal](18, 4) NOT NULL,
	[Create_date] [datetime] NOT NULL,
 CONSTRAINT [PK_ForexRate_1] PRIMARY KEY CLUSTERED
(
	[ForexRateCode] ASC,
	[ForexRateDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[FPEXR_STG](
	[FPEXR_CRCY_CODE] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[FPEXR_DATE] [date] NOT NULL,
	[FPEXR_RATE] [decimal](17, 10) NULL,
	[FPEXR_SORT] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[FPEXR_LOAD_DATE] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[FPEXR_EXT_DATE] [date] NOT NULL,
	[FPEXR_LOAD_TIME] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
 CONSTRAINT [PK_FPEXR_STG] PRIMARY KEY CLUSTERED
(
	[FPEXR_CRCY_CODE] ASC,
	[FPEXR_DATE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[Global](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Code] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[GroupId] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Name_TN] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Name_CN] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Name_EN] [nvarchar](300) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Name_JP] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Seq] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[Memo] [nvarchar](4000) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [varchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_user] [varchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Field1] [nvarchar](4000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
 CONSTRAINT [PK_M_Combolist_1] PRIMARY KEY CLUSTERED
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[Global] ADD  CONSTRAINT [DF_Global_Code]  DEFAULT ('') FOR [Code]
GO
ALTER TABLE [dbo].[Global] ADD  CONSTRAINT [DF_Global_Name_TN]  DEFAULT ('') FOR [Name_TN]
GO
ALTER TABLE [dbo].[Global] ADD  CONSTRAINT [DF_Global_Name_CN]  DEFAULT ('') FOR [Name_CN]
GO
ALTER TABLE [dbo].[Global] ADD  CONSTRAINT [DF_Global_Name_EN]  DEFAULT ('') FOR [Name_EN]
GO
ALTER TABLE [dbo].[Global] ADD  CONSTRAINT [DF_Global_Name_JP]  DEFAULT ('') FOR [Name_JP]
GO
ALTER TABLE [dbo].[Global] ADD  CONSTRAINT [DF_Global_Seq]  DEFAULT ((1)) FOR [Seq]
GO
ALTER TABLE [dbo].[Global] ADD  CONSTRAINT [DF_Global_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[Global] ADD  CONSTRAINT [DF_Global_Memo]  DEFAULT ('') FOR [Memo]
GO
ALTER TABLE [dbo].[Global] ADD  CONSTRAINT [DF_Global_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[Global] ADD  CONSTRAINT [DF_Global_Update_user]  DEFAULT ('system') FOR [Update_user]
GO
ALTER TABLE [dbo].[Global] ADD  CONSTRAINT [DF_Global_Create_user]  DEFAULT ('system') FOR [Create_user]
GO
ALTER TABLE [dbo].[Global] ADD  CONSTRAINT [DF_Global_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[GroupIdCounter](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[GroupName] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[GroupCount] [int] NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_GroupIdCounter] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[GroupIdCounter] ADD  CONSTRAINT [DF_GroupIdCounter_GroupCount]  DEFAULT ((0)) FOR [GroupCount]
GO
ALTER TABLE [dbo].[GroupIdCounter] ADD  CONSTRAINT [DF_GroupIdCounter_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[HRIS_Origin](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [nvarchar](255) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[UserName] [nvarchar](255) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[GroupCode] [nvarchar](255) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[GroupName] [nvarchar](255) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[UnitBranchCode] [nvarchar](255) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[UnitBranchName] [nvarchar](255) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[DepartmentCode] [nvarchar](255) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[DepartmentName] [nvarchar](255) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[JobTitleCode] [nvarchar](255) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[JobTitleName] [nvarchar](255) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Chief] [nvarchar](255) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[TitleCode] [nvarchar](255) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Leave_Start] [datetime] NULL,
	[Leave_End] [datetime] NULL,
	[Acting_Person] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Create_date] [datetime] NOT NULL,
 CONSTRAINT [PK_HRIS_Origin] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[HRIS_Origin] ADD  CONSTRAINT [DF_HRIS_Origin_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[i18nText](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[Name_TN] [nvarchar](500) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Name_CN] [nvarchar](500) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Name_EN] [nvarchar](500) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Name_JP] [nvarchar](500) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[KeyValue] [nvarchar](500) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Update_Time] [datetime] NULL,
	[Update_User] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_i18n_text] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[INDUSTRY](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[INDCODE] [nvarchar](6) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[TYPE] [int] NOT NULL,
	[Medium_Code] [nvarchar](6) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Medium_Name] [nvarchar](255) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Major_Code] [nvarchar](6) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Major_Name] [nvarchar](255) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_INDUSTRY] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB],
 CONSTRAINT [IX_INDUSTRY] UNIQUE NONCLUSTERED
(
	[INDCODE] ASC,
	[TYPE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
IF FILEGROUP_ID(N'NCRMS_IDX') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_IDX]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[INDUSTRY] ADD  CONSTRAINT [DF_INDUSTRY_major_name]  DEFAULT ('') FOR [Major_Name]
GO
ALTER TABLE [dbo].[INDUSTRY] ADD  CONSTRAINT [DF_INDUSTRY_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[INDUSTRY] ADD  CONSTRAINT [DF_INDUSTRY_Update_user]  DEFAULT ('system') FOR [Update_user]
GO
ALTER TABLE [dbo].[INDUSTRY] ADD  CONSTRAINT [DF_INDUSTRY_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[INDUSTRY] ADD  CONSTRAINT [DF_INDUSTRY_Create_user]  DEFAULT ('system') FOR [Create_user]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'國內產業編號' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'INDUSTRY', @level2type=N'COLUMN',@level2name=N'INDCODE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1=國內,2=國外' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'INDUSTRY', @level2type=N'COLUMN',@level2name=N'TYPE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'中類編號' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'INDUSTRY', @level2type=N'COLUMN',@level2name=N'Medium_Code'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'放款中類行業名稱' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'INDUSTRY', @level2type=N'COLUMN',@level2name=N'Medium_Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'大類編號' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'INDUSTRY', @level2type=N'COLUMN',@level2name=N'Major_Code'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'放款大類行業' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'INDUSTRY', @level2type=N'COLUMN',@level2name=N'Major_Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'更新時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'INDUSTRY', @level2type=N'COLUMN',@level2name=N'Update_date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'更新者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'INDUSTRY', @level2type=N'COLUMN',@level2name=N'Update_user'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建置時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'INDUSTRY', @level2type=N'COLUMN',@level2name=N'Create_date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建置者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'INDUSTRY', @level2type=N'COLUMN',@level2name=N'Create_user'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[INDUSTRY_Internal](
	[CustomerId] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[INDCODE] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
 CONSTRAINT [PK_INDUSTRY_Internal] PRIMARY KEY CLUSTERED
(
	[CustomerId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[INDUSTRY_Overseas](
	[BranchCode] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[CustomerId] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[INDCODE] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_INDUSTRY_Overseas] PRIMARY KEY CLUSTERED
(
	[BranchCode] ASC,
	[CustomerId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[LoanApprovalEntry](
	[LoanMainId] [int] NOT NULL,
	[BranchCode] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[EntryNo] [nvarchar](30) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Status] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Amt] [decimal](18, 2) NULL,
	[SortOrder] [int] NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_LoanApprovalEntry] PRIMARY KEY CLUSTERED
(
	[LoanMainId] ASC,
	[BranchCode] ASC,
	[EntryNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[LoanApprovalEntry] ADD  CONSTRAINT [DF__LoanAppro__SortO__51E5D21A]  DEFAULT ((0)) FOR [SortOrder]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[LoanBranchApproveAmountHis](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FlowFromId] [int] NOT NULL,
	[ApplyDate] [datetime] NOT NULL,
	[ApplyAmount] [int] NOT NULL,
	[ApproveDate] [datetime] NULL,
	[ApproveAmount] [int] NULL,
 CONSTRAINT [PK_LoanBranchApproveAmountHis] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[LoanBranchData](
	[LoanMainId] [int] NOT NULL,
	[LoanFlowRoute] [int] NOT NULL,
	[IsFirstTime] [bit] NOT NULL,
	[HaihuIsNeedRunLoanUnit] [bit] NULL,
	[TrackingDate] [date] NULL,
	[ApplyTrackingDate] [date] NULL,
	[WindRiskFormId] [int] NULL,
	[WindRiskIsTracking] [bit] NULL,
	[HaihuFormId] [int] NULL,
	[HaihuIsTracking] [bit] NULL,
	[HaihuLoanMethod] [int] NULL,
	[HaihuSelectedUnitCode] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_LoanBranchData] PRIMARY KEY CLUSTERED
(
	[LoanMainId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[LoanBranchData] ADD  CONSTRAINT [DF__LoanBranc__IsFir__4A44B052]  DEFAULT ((1)) FOR [IsFirstTime]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[LoanExtApp](
	[ExtFlowFormId] [int] NOT NULL,
	[LoanMainId] [int] NOT NULL,
	[Reason] [nvarchar](max) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[ExtDate] [date] NOT NULL,
	[OriginalTrackingDate] [date] NULL,
	[LatestComment] [nvarchar](max) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_LoanExtApp] PRIMARY KEY CLUSTERED
(
	[ExtFlowFormId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[LoanMainUnitData](
	[LoanMainId] [int] NOT NULL,
	[SelectedUnitCode] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[IsNeedRunLoanUnit] [bit] NOT NULL,
	[LoanApplyMainFormId] [int] NULL,
	[LoanMainUnitFormId] [int] NULL,
	[LoanOtherUnitFormId] [int] NULL,
	[WindRiskFormId] [int] NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_LoanMainUnitData] PRIMARY KEY CLUSTERED
(
	[LoanMainId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[LoanMainUnitData] ADD  CONSTRAINT [DF__LoanMainU__IsNee__5892CFA9]  DEFAULT ((0)) FOR [IsNeedRunLoanUnit]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[LS_LSRSA_D_MF](
	[ACC_CODE] [nvarchar](9) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[ENG_NAME] [nvarchar](42) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[ISIN_CD] [nvarchar](11) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[APRV_NO] [nvarchar](38) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CURRENCY] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LN_BAL] [decimal](15, 2) NULL,
	[COUNTRY] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[EXT_DATE] [date] NULL,
	[BUSINS_CODE] [nvarchar](7) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[Mail](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[UnitCode] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[List_Name] [nvarchar](60) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Mail_Type] [int] NOT NULL,
	[Subject] [nvarchar](255) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Mail_Content] [nvarchar](4000) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[IsSystem] [bit] NOT NULL,
 CONSTRAINT [PK_Mail] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[Mail] ADD  CONSTRAINT [DF_Mail_List_Name]  DEFAULT ('') FOR [List_Name]
GO
ALTER TABLE [dbo].[Mail] ADD  CONSTRAINT [DF_Mail_Mail_Content]  DEFAULT ('') FOR [Mail_Content]
GO
ALTER TABLE [dbo].[Mail] ADD  CONSTRAINT [DF_Mail_Update_user]  DEFAULT ('system') FOR [Update_user]
GO
ALTER TABLE [dbo].[Mail] ADD  CONSTRAINT [DF_Mail_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[Mail] ADD  CONSTRAINT [DF_Mail_Create_user]  DEFAULT (N'system') FOR [Create_user]
GO
ALTER TABLE [dbo].[Mail] ADD  CONSTRAINT [DF_Mail_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[Mail] ADD  CONSTRAINT [DF_Mail_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[Mail] ADD  CONSTRAINT [DF_Mail_IsSystem]  DEFAULT ((0)) FOR [IsSystem]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'範本名稱' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Mail', @level2type=N'COLUMN',@level2name=N'List_Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'類型' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Mail', @level2type=N'COLUMN',@level2name=N'Mail_Type'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'標題' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Mail', @level2type=N'COLUMN',@level2name=N'Subject'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'內容' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Mail', @level2type=N'COLUMN',@level2name=N'Mail_Content'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'更新者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Mail', @level2type=N'COLUMN',@level2name=N'Update_user'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'更新時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Mail', @level2type=N'COLUMN',@level2name=N'Update_date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'是否啟用' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Mail', @level2type=N'COLUMN',@level2name=N'IsActive'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'是否是系統信件範本' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Mail', @level2type=N'COLUMN',@level2name=N'IsSystem'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[Mail_his](
	[Log_Id] [int] IDENTITY(1,1) NOT NULL,
	[LogType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[PK_Id] [int] NOT NULL,
	[FlowFormId] [int] NOT NULL,
	[UnitCode] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[List_Name] [nvarchar](60) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Mail_Type] [int] NOT NULL,
	[Subject] [nvarchar](255) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Mail_Content] [nvarchar](4000) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[IsSystem] [bit] NOT NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK__Mail_his__2D26E78EB60E73D1] PRIMARY KEY CLUSTERED
(
	[Log_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[Mail_his] ADD  CONSTRAINT [DF__Mail_his__SysCre__0BA79404]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'歷史記錄識別碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Mail_his', @level2type=N'COLUMN',@level2name=N'Log_Id'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[Mail_temp](
	[TempId] [int] IDENTITY(1,1) NOT NULL,
	[FlowFormId] [int] NULL,
	[ModifyType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[PK_Id] [int] NULL,
	[UnitCode] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[List_Name] [nvarchar](60) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Mail_Type] [int] NULL,
	[Subject] [nvarchar](255) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Mail_Content] [nvarchar](4000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Update_date] [datetime] NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Create_date] [datetime] NULL,
	[IsActive] [bit] NULL,
	[IsSystem] [bit] NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK__Mail_tem__06C703C1D1BB657D] PRIMARY KEY CLUSTERED
(
	[TempId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_PADDING ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE NONCLUSTERED INDEX [IX_Mail_temp_UnitCode_FlowFormId] ON [dbo].[Mail_temp]
(
	[UnitCode] ASC,
	[FlowFormId] ASC
)
INCLUDE([PK_Id],[TempId],[Mail_Type]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
';
IF FILEGROUP_ID(N'NCRMS_IDX') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_IDX]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[Mail_temp] ADD  CONSTRAINT [DF__Mail_temp__SysCr__0E8400AF]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'暫存資料識別碼（流水號）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Mail_temp', @level2type=N'COLUMN',@level2name=N'TempId'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[MailCcMapping](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_MailId] [int] NOT NULL,
	[FK_UserId] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_MailCcMapping] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[MailCcMapping_his](
	[Log_id] [int] IDENTITY(1,1) NOT NULL,
	[LogType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Fk_logId] [int] NOT NULL,
	[PK_Id] [int] NOT NULL,
	[FK_MailId] [int] NOT NULL,
	[FK_UserId] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK__MailCcMa__2D21E3B66A268ACA] PRIMARY KEY CLUSTERED
(
	[Log_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[MailCcMapping_his] ADD  CONSTRAINT [DF__MailCcMap__SysCr__501CB9E2]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'歷史記錄識別碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MailCcMapping_his', @level2type=N'COLUMN',@level2name=N'Log_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'異動行為類型 (INSERT/UPDATE/DELETE)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MailCcMapping_his', @level2type=N'COLUMN',@level2name=N'LogType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立日期時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MailCcMapping_his', @level2type=N'COLUMN',@level2name=N'SysCreateDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立使用者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MailCcMapping_his', @level2type=N'COLUMN',@level2name=N'SysCreateUser'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[MailCcMapping_temp](
	[TempId] [int] IDENTITY(1,1) NOT NULL,
	[FK_TempId] [int] NOT NULL,
	[ModifyType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[PK_Id] [int] NULL,
	[FK_MailId] [int] NULL,
	[FK_UserId] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Create_date] [datetime] NULL,
	[Create_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK__MailCcMa__06C703C1A952591A] PRIMARY KEY CLUSTERED
(
	[TempId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE NONCLUSTERED INDEX [IX_MailCcMapping_temp_FK_TempId] ON [dbo].[MailCcMapping_temp]
(
	[FK_TempId] ASC
)
INCLUDE([FK_UserId],[PK_Id]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
';
IF FILEGROUP_ID(N'NCRMS_IDX') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_IDX]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[MailCcMapping_temp] ADD  CONSTRAINT [DF__MailCcMap__SysCr__52F9268D]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'暫存資料識別碼（流水號）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MailCcMapping_temp', @level2type=N'COLUMN',@level2name=N'TempId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'主表暫存資料外鍵' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MailCcMapping_temp', @level2type=N'COLUMN',@level2name=N'FK_TempId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'異動類型' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MailCcMapping_temp', @level2type=N'COLUMN',@level2name=N'ModifyType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立日期時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MailCcMapping_temp', @level2type=N'COLUMN',@level2name=N'SysCreateDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立使用者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MailCcMapping_temp', @level2type=N'COLUMN',@level2name=N'SysCreateUser'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[MailCustomCcMapping](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_MailId] [int] NOT NULL,
	[CustomMail] [nvarchar](300) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_MailCustomCcMapping] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[MailCustomCcMapping_his](
	[Log_id] [int] IDENTITY(1,1) NOT NULL,
	[LogType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Fk_logId] [int] NOT NULL,
	[PK_Id] [int] NOT NULL,
	[FK_MailId] [int] NOT NULL,
	[CustomMail] [nvarchar](300) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK__MailCust__2D21E3B679C2AF6D] PRIMARY KEY CLUSTERED
(
	[Log_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[MailCustomCcMapping_his] ADD  CONSTRAINT [DF__MailCusto__SysCr__7B0717E7]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'歷史記錄識別碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MailCustomCcMapping_his', @level2type=N'COLUMN',@level2name=N'Log_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'異動行為類型 (INSERT/UPDATE/DELETE)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MailCustomCcMapping_his', @level2type=N'COLUMN',@level2name=N'LogType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立日期時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MailCustomCcMapping_his', @level2type=N'COLUMN',@level2name=N'SysCreateDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立使用者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MailCustomCcMapping_his', @level2type=N'COLUMN',@level2name=N'SysCreateUser'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[MailCustomCcMapping_temp](
	[TempId] [int] IDENTITY(1,1) NOT NULL,
	[FK_TempId] [int] NOT NULL,
	[ModifyType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[PK_Id] [int] NULL,
	[FK_MailId] [int] NULL,
	[CustomMail] [nvarchar](300) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Create_date] [datetime] NULL,
	[Create_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK__MailCust__06C703C1C4805123] PRIMARY KEY CLUSTERED
(
	[TempId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[MailCustomCcMapping_temp] ADD  CONSTRAINT [DF__MailCusto__SysCr__55D59338]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'暫存資料識別碼（流水號）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MailCustomCcMapping_temp', @level2type=N'COLUMN',@level2name=N'TempId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'主表暫存資料外鍵' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MailCustomCcMapping_temp', @level2type=N'COLUMN',@level2name=N'FK_TempId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'異動類型' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MailCustomCcMapping_temp', @level2type=N'COLUMN',@level2name=N'ModifyType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立日期時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MailCustomCcMapping_temp', @level2type=N'COLUMN',@level2name=N'SysCreateDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立使用者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MailCustomCcMapping_temp', @level2type=N'COLUMN',@level2name=N'SysCreateUser'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[MailCustomToMapping](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_MailId] [int] NOT NULL,
	[CustomMail] [nvarchar](300) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_MailCustomToMapping] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[MailCustomToMapping_his](
	[Log_id] [int] IDENTITY(1,1) NOT NULL,
	[LogType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Fk_logId] [int] NOT NULL,
	[PK_Id] [int] NOT NULL,
	[FK_MailId] [int] NOT NULL,
	[CustomMail] [nvarchar](300) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK__MailCust__2D21E3B6EEC8E570] PRIMARY KEY CLUSTERED
(
	[Log_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[MailCustomToMapping_his] ADD  CONSTRAINT [DF__MailCusto__SysCr__7DE38492]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'歷史記錄識別碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MailCustomToMapping_his', @level2type=N'COLUMN',@level2name=N'Log_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'異動行為類型 (INSERT/UPDATE/DELETE)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MailCustomToMapping_his', @level2type=N'COLUMN',@level2name=N'LogType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立日期時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MailCustomToMapping_his', @level2type=N'COLUMN',@level2name=N'SysCreateDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立使用者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MailCustomToMapping_his', @level2type=N'COLUMN',@level2name=N'SysCreateUser'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[MailCustomToMapping_temp](
	[TempId] [int] IDENTITY(1,1) NOT NULL,
	[FK_TempId] [int] NOT NULL,
	[ModifyType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[PK_Id] [int] NULL,
	[FK_MailId] [int] NULL,
	[CustomMail] [nvarchar](300) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Create_date] [datetime] NULL,
	[Create_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK__MailCust__06C703C1831CEE1B] PRIMARY KEY CLUSTERED
(
	[TempId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[MailCustomToMapping_temp] ADD  CONSTRAINT [DF__MailCusto__SysCr__58B1FFE3]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'暫存資料識別碼（流水號）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MailCustomToMapping_temp', @level2type=N'COLUMN',@level2name=N'TempId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'主表暫存資料外鍵' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MailCustomToMapping_temp', @level2type=N'COLUMN',@level2name=N'FK_TempId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'異動類型' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MailCustomToMapping_temp', @level2type=N'COLUMN',@level2name=N'ModifyType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立日期時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MailCustomToMapping_temp', @level2type=N'COLUMN',@level2name=N'SysCreateDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立使用者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MailCustomToMapping_temp', @level2type=N'COLUMN',@level2name=N'SysCreateUser'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[MailGroup](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[UnitCode] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Text_TN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Text_CN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Text_EN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Text_JP] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK_MailGroup] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[MailGroup] ADD  CONSTRAINT [DF_MailGroup_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[MailGroup] ADD  CONSTRAINT [DF_MailGroup_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[MailGroup] ADD  CONSTRAINT [DF_MailGroup_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[MailGroupCcMapping](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[MailId] [int] NOT NULL,
	[MailGroupId] [int] NOT NULL,
	[Create_date] [datetime] NULL,
	[Create_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
 CONSTRAINT [PK_MailGroupToCCMapping] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[MailGroupCcMapping] ADD  CONSTRAINT [DF_MailGroupToCCMapping_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[MailGroupCcMapping_his](
	[Log_id] [int] IDENTITY(1,1) NOT NULL,
	[LogType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Fk_logId] [int] NOT NULL,
	[PK_Id] [int] NOT NULL,
	[MailId] [int] NOT NULL,
	[MailGroupId] [int] NOT NULL,
	[Create_date] [datetime] NULL,
	[Create_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK__MailGrou__2D21E3B6D265B29C] PRIMARY KEY CLUSTERED
(
	[Log_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[MailGroupCcMapping_his] ADD  CONSTRAINT [DF__MailGroup__SysCr__26268016]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'歷史記錄識別碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MailGroupCcMapping_his', @level2type=N'COLUMN',@level2name=N'Log_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'異動行為類型 (INSERT/UPDATE/DELETE)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MailGroupCcMapping_his', @level2type=N'COLUMN',@level2name=N'LogType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立日期時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MailGroupCcMapping_his', @level2type=N'COLUMN',@level2name=N'SysCreateDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立使用者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MailGroupCcMapping_his', @level2type=N'COLUMN',@level2name=N'SysCreateUser'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[MailGroupCcMapping_temp](
	[TempId] [int] IDENTITY(1,1) NOT NULL,
	[FK_TempId] [int] NOT NULL,
	[ModifyType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[PK_Id] [int] NULL,
	[MailId] [int] NULL,
	[MailGroupId] [int] NULL,
	[Create_date] [datetime] NULL,
	[Create_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK__MailGrou__06C703C18AB44C7F] PRIMARY KEY CLUSTERED
(
	[TempId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE NONCLUSTERED INDEX [IX_MailGroupToCCMapping_temp_FK_TempId] ON [dbo].[MailGroupCcMapping_temp]
(
	[FK_TempId] ASC
)
INCLUDE([MailGroupId],[PK_Id]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
';
IF FILEGROUP_ID(N'NCRMS_IDX') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_IDX]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[MailGroupCcMapping_temp] ADD  CONSTRAINT [DF__MailGroup__Creat__2902ECC1]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[MailGroupCcMapping_temp] ADD  CONSTRAINT [DF__MailGroup__SysCr__29F710FA]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'暫存資料識別碼（流水號）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MailGroupCcMapping_temp', @level2type=N'COLUMN',@level2name=N'TempId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'主表暫存資料外鍵' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MailGroupCcMapping_temp', @level2type=N'COLUMN',@level2name=N'FK_TempId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'異動類型' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MailGroupCcMapping_temp', @level2type=N'COLUMN',@level2name=N'ModifyType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立日期時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MailGroupCcMapping_temp', @level2type=N'COLUMN',@level2name=N'SysCreateDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立使用者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MailGroupCcMapping_temp', @level2type=N'COLUMN',@level2name=N'SysCreateUser'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[MailGroupMapping](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[MailId] [int] NOT NULL,
	[MailGroupId] [int] NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_MailGroupMapping] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[MailGroupMapping] ADD  CONSTRAINT [DF_MailGroupMapping_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[MailGroupMapping_his](
	[Log_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_LogId] [int] NULL,
	[LogType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[PK_Id] [int] NOT NULL,
	[MailId] [int] NOT NULL,
	[MailGroupId] [int] NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK__MailGrou__2D26E78E3C4A8F62] PRIMARY KEY CLUSTERED
(
	[Log_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[MailGroupMapping_his] ADD  CONSTRAINT [DF__MailGroup__SysCr__33B5855E]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'歷史記錄識別碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MailGroupMapping_his', @level2type=N'COLUMN',@level2name=N'Log_Id'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[MailGroupMapping_temp](
	[TempId] [int] IDENTITY(1,1) NOT NULL,
	[FK_TempId] [int] NULL,
	[PK_Id] [int] NULL,
	[MailId] [int] NULL,
	[MailGroupId] [int] NULL,
	[ModifyType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Create_date] [datetime] NULL,
	[Create_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK__MailGrou__06C703C1E617227D] PRIMARY KEY CLUSTERED
(
	[TempId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE NONCLUSTERED INDEX [IX_MailGroupMapping_temp_FK_TempId] ON [dbo].[MailGroupMapping_temp]
(
	[FK_TempId] ASC
)
INCLUDE([MailGroupId],[PK_Id]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
';
IF FILEGROUP_ID(N'NCRMS_IDX') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_IDX]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[MailGroupMapping_temp] ADD  CONSTRAINT [DF__MailGroup__SysCr__2FE4F47A]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'暫存資料識別碼（流水號）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MailGroupMapping_temp', @level2type=N'COLUMN',@level2name=N'TempId'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[MailGroupUser](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[MailGroup_Id] [int] NOT NULL,
	[UserId] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_MailGroupUser] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE NONCLUSTERED INDEX [IX_MailGroupUser] ON [dbo].[MailGroupUser]
(
	[PK_Id] ASC,
	[MailGroup_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
';
IF FILEGROUP_ID(N'NCRMS_IDX') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_IDX]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[MailGroupUser] ADD  CONSTRAINT [DF_MailGroupUser_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[MailLog](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[UnitCode] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[List_Name] [nvarchar](60) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Mail_Type] [int] NULL,
	[Mail_From] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Subject] [nvarchar](255) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Mail_Content] [nvarchar](4000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[IsSystem] [bit] NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
 CONSTRAINT [PK_MailLog] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[MailLog] ADD  CONSTRAINT [DF_MailLog_IsSystem]  DEFAULT ((1)) FOR [IsSystem]
GO
ALTER TABLE [dbo].[MailLog] ADD  CONSTRAINT [DF_MailLog_Create_user]  DEFAULT ('system') FOR [Create_user]
GO
ALTER TABLE [dbo].[MailLog] ADD  CONSTRAINT [DF_MailLog_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[MailLog_CcCustomMapping](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_LogId] [int] NOT NULL,
	[CustomMail] [nvarchar](300) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_MailLog_CcCustomMapping] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[MailLog_CcGroupMapping](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_LogId] [int] NOT NULL,
	[FK_MailGroupId] [int] NOT NULL,
 CONSTRAINT [PK_Mail_CcGroupMapping] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[MailLog_CcMapping](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_LogId] [int] NOT NULL,
	[FK_UserId] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_MailLog_CcMapping] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[MailLog_CustomMapping](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_LogId] [int] NOT NULL,
	[CustomMail] [nvarchar](300) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_MailLog_CustomMapping] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[MailLog_FileMapping](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_LogId] [int] NOT NULL,
	[FileName] [nvarchar](300) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[FileExtenstion] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_MailLog_FileMapping] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[MailLog_GroupMapping](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_LogId] [int] NOT NULL,
	[FK_MailGroupId] [int] NOT NULL,
 CONSTRAINT [PK_MailLog_GroupMapping] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[MailLog_Mapping](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_LogId] [int] NOT NULL,
	[FK_UserId] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_MailLog_Mapping] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[MailToMapping](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_MailId] [int] NOT NULL,
	[FK_UserId] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_MailToMapping] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[MailToMapping_his](
	[Log_id] [int] IDENTITY(1,1) NOT NULL,
	[LogType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Fk_logId] [int] NOT NULL,
	[PK_Id] [int] NOT NULL,
	[FK_MailId] [int] NOT NULL,
	[FK_UserId] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK__MailToMa__2D21E3B6B50010F2] PRIMARY KEY CLUSTERED
(
	[Log_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[MailToMapping_his] ADD  CONSTRAINT [DF__MailToMap__SysCr__6F95653B]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'歷史記錄識別碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MailToMapping_his', @level2type=N'COLUMN',@level2name=N'Log_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'異動行為類型 (INSERT/UPDATE/DELETE)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MailToMapping_his', @level2type=N'COLUMN',@level2name=N'LogType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立日期時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MailToMapping_his', @level2type=N'COLUMN',@level2name=N'SysCreateDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立使用者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MailToMapping_his', @level2type=N'COLUMN',@level2name=N'SysCreateUser'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[MailToMapping_temp](
	[TempId] [int] IDENTITY(1,1) NOT NULL,
	[FK_TempId] [int] NOT NULL,
	[ModifyType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[PK_Id] [int] NULL,
	[FK_MailId] [int] NULL,
	[FK_UserId] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Create_date] [datetime] NULL,
	[Create_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK__MailToMa__06C703C1BC325BD3] PRIMARY KEY CLUSTERED
(
	[TempId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE NONCLUSTERED INDEX [IX_MailToMapping_temp_FK_TempId] ON [dbo].[MailToMapping_temp]
(
	[FK_TempId] ASC
)
INCLUDE([FK_UserId],[PK_Id]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
';
IF FILEGROUP_ID(N'NCRMS_IDX') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_IDX]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[MailToMapping_temp] ADD  CONSTRAINT [DF__MailToMap__SysCr__5B8E6C8E]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'暫存資料識別碼（流水號）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MailToMapping_temp', @level2type=N'COLUMN',@level2name=N'TempId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'主表暫存資料外鍵' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MailToMapping_temp', @level2type=N'COLUMN',@level2name=N'FK_TempId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'異動類型' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MailToMapping_temp', @level2type=N'COLUMN',@level2name=N'ModifyType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立日期時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MailToMapping_temp', @level2type=N'COLUMN',@level2name=N'SysCreateDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立使用者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MailToMapping_temp', @level2type=N'COLUMN',@level2name=N'SysCreateUser'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[Menu](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[SystemId] [int] NOT NULL,
	[ParentId] [int] NULL,
	[Name_TN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Name_CN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Name_EN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Name_JP] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[MenuType] [int] NULL,
	[Seq] [int] NULL,
	[RouteName] [varchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[IsActive] [bit] NOT NULL,
	[ISSystem] [bit] NOT NULL,
	[ISNEEDFLOW] [bit] NOT NULL,
	[Icon] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [varchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_user] [varchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
 CONSTRAINT [PK_Menu_1] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[Menu] ADD  CONSTRAINT [DF_Menu_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[Menu] ADD  CONSTRAINT [DF_Menu_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[MIS_CRCY_REF](
	[CRCY_CHN_NAME] [char](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CRCY_ENG_NAME] [char](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[CRCY_CODE] [char](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_MIS_CRCY_REF_1] PRIMARY KEY CLUSTERED
(
	[CRCY_CODE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_PADDING OFF
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[MONITORDATA](
	[PK_ID] [int] IDENTITY(1,1) NOT NULL,
	[GROUP_NO] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[UNIT_NO] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[BRANCH_NO] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[TX_DATE] [date] NULL,
	[AS_OF_DATE] [date] NULL,
	[PRODUCT_TYPE] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[TRAN_NO] [nvarchar](25) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CUSTOMER_NAME] [nvarchar](40) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CUSTOMER_ID] [nvarchar](11) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[COUNTRY_COD] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CURENCY_COD] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[TRAN_AMOUNT] [decimal](18, 2) NULL,
	[TO_USD_AMT] [decimal](18, 2) NULL,
	[PERMIT_NO] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LIMIT] [decimal](18, 2) NULL,
	[LIMIT_COD] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[TO_USD_LIMIT] [decimal](18, 2) NULL,
	[REVOLVE_MK] [bit] NOT NULL,
	[FIL9] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SOURCE] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CREATOR] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LIMIT_MATURITY] [date] NULL,
	[MATURITY_DATE] [date] NULL,
	[GROUP_NAME] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[INDUSTRY] [nvarchar](6) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[INDUSTRY_Type] [int] NULL,
	[PRODUCT_CODE] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CUR_BOUGHT] [nchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CUR_SOLD] [nchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[RISKFAC';
SET @FilegroupSql += N'TOR] [decimal](10, 2) NULL,
	[WEIGHTS] [int] NULL,
	[DATADATE] [date] NULL,
	[Create_Date] [date] NULL,
	[Create_DateTime] [datetime] NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Year] [int] NULL,
	[Month] [int] NULL,
	[Week] [int] NULL,
	[EXT_DATE] [date] NULL,
	[Mark] [bit] NULL,
	[Lock] [bit] NULL,
	[TOP_Limit_USD_Amount] [decimal](18, 2) NULL,
	[TOP_Limit_Amount] [decimal](18, 2) NULL,
	[TRAN_FXRATE] [decimal](18, 10) NULL,
	[LIMIT_FXRATE] [decimal](18, 10) NULL,
	[CAL_TO_USD_AMT] [decimal](18, 2) NULL,
	[CAL_TO_USD_LIMIT] [decimal](18, 2) NULL,
 CONSTRAINT [PK_MONITORDATA] PRIMARY KEY CLUSTERED
(
	[PK_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_PADDING ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE NONCLUSTERED INDEX [IX_MONITORDATA_ASOFDATE_MARK] ON [dbo].[MONITORDATA]
(
	[AS_OF_DATE] ASC,
	[Mark] ASC,
	[PRODUCT_TYPE] ASC,
	[MATURITY_DATE] ASC
)
INCLUDE([PK_ID],[GROUP_NO],[UNIT_NO],[BRANCH_NO],[Create_DateTime],[Create_user]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
';
IF FILEGROUP_ID(N'NCRMS_IDX') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_IDX]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_PADDING ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE NONCLUSTERED INDEX [IX_MONITORDATA_ASOFDATE_PAGING] ON [dbo].[MONITORDATA]
(
	[AS_OF_DATE] ASC,
	[GROUP_NO] ASC,
	[UNIT_NO] ASC,
	[BRANCH_NO] ASC
)
INCLUDE([PK_ID],[TRAN_NO],[Mark],[MATURITY_DATE],[PRODUCT_TYPE]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
';
IF FILEGROUP_ID(N'NCRMS_IDX') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_IDX]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE NONCLUSTERED INDEX [IX_MONITORDATA_DATE] ON [dbo].[MONITORDATA]
(
	[EXT_DATE] ASC,
	[Year] ASC,
	[Month] ASC,
	[Week] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
';
IF FILEGROUP_ID(N'NCRMS_IDX') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_IDX]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[MONITORDATA] ADD  CONSTRAINT [DF_MONITORDATA_REVOLVE_MK]  DEFAULT ((0)) FOR [REVOLVE_MK]
GO
ALTER TABLE [dbo].[MONITORDATA] ADD  CONSTRAINT [DF_MONITORDATA_Create_Date]  DEFAULT (getdate()) FOR [Create_Date]
GO
ALTER TABLE [dbo].[MONITORDATA] ADD  CONSTRAINT [DF_MONITORDATA_Create_DateTime]  DEFAULT (getdate()) FOR [Create_DateTime]
GO
ALTER TABLE [dbo].[MONITORDATA] ADD  CONSTRAINT [DF_MONITORDATA_Create_user]  DEFAULT ('System') FOR [Create_user]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'事業群代號' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MONITORDATA', @level2type=N'COLUMN',@level2name=N'GROUP_NO'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'處級單位代號' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MONITORDATA', @level2type=N'COLUMN',@level2name=N'UNIT_NO'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'分行代碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MONITORDATA', @level2type=N'COLUMN',@level2name=N'BRANCH_NO'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'交易日期' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MONITORDATA', @level2type=N'COLUMN',@level2name=N'TX_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'資料日' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MONITORDATA', @level2type=N'COLUMN',@level2name=N'AS_OF_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'產品別' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MONITORDATA', @level2type=N'COLUMN',@level2name=N'PRODUCT_TYPE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'交易代號' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MONITORDATA', @level2type=N'COLUMN',@level2name=N'TRAN_NO'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'客戶名稱' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MONITORDATA', @level2type=N'COLUMN',@level2name=N'CUSTOMER_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'客戶ID或統編' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MONITORDATA', @level2type=N'COLUMN',@level2name=N'CUSTOMER_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'國家別' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MONITORDATA', @level2type=N'COLUMN',@level2name=N'COUNTRY_COD'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'交易幣別' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MONITORDATA', @level2type=N'COLUMN',@level2name=N'CURENCY_COD'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'交易金額' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MONITORDATA', @level2type=N'COLUMN',@level2name=N'TRAN_AMOUNT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'交易金額(美金)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MONITORDATA', @level2type=N'COLUMN',@level2name=N'TO_USD_AMT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'核准編號' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MONITORDATA', @level2type=N'COLUMN',@level2name=N'PERMIT_NO'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'核准金額' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MONITORDATA', @level2type=N'COLUMN',@level2name=N'LIMIT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'核准幣別' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MONITORDATA', @level2type=N'COLUMN',@level2name=N'LIMIT_COD'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'核准金額(美金)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MONITORDATA', @level2type=N'COLUMN',@level2name=N'TO_USD_LIMIT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'是否循環' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MONITORDATA', @level2type=N'COLUMN',@level2name=N'REVOLVE_MK'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'轉檔的來源' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MONITORDATA', @level2type=N'COLUMN',@level2name=N'FIL9'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'來源別' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MONITORDATA', @level2type=N'COLUMN',@level2name=N'SOURCE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'資料建立者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MONITORDATA', @level2type=N'COLUMN',@level2name=N'CREATOR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'額度到期日' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MONITORDATA', @level2type=N'COLUMN',@level2name=N'LIMIT_MATURITY'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'到期日' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MONITORDATA', @level2type=N'COLUMN',@level2name=N'MATURITY_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'客戶歸檔名稱' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MONITORDATA', @level2type=N'COLUMN',@level2name=N'GROUP_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'產業別' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MONITORDATA', @level2type=N'COLUMN',@level2name=N'INDUSTRY'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'產業別分海內外1=國內 2=海外' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MONITORDATA', @level2type=N'COLUMN',@level2name=N'INDUSTRY_Type'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'PRODUCT_CODE 07衍伸性產品風險係數用' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MONITORDATA', @level2type=N'COLUMN',@level2name=N'PRODUCT_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'買入幣別 07衍伸性產品風險係數用' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MONITORDATA', @level2type=N'COLUMN',@level2name=N'CUR_BOUGHT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'賣出幣別 07衍伸性產品風險係數用' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MONITORDATA', @level2type=N'COLUMN',@level2name=N'CUR_SOLD'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'風險係數' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MONITORDATA', @level2type=N'COLUMN',@level2name=N'RISKFACTOR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'權重' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MONITORDATA', @level2type=N'COLUMN',@level2name=N'WEIGHTS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'指定的轉檔日期' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MONITORDATA', @level2type=N'COLUMN',@level2name=N'DATADATE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建置日' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MONITORDATA', @level2type=N'COLUMN',@level2name=N'Create_Date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建置時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MONITORDATA', @level2type=N'COLUMN',@level2name=N'Create_DateTime'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建置者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MONITORDATA', @level2type=N'COLUMN',@level2name=N'Create_user'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[MONITORDATA_his](
	[Log_Id] [int] IDENTITY(1,1) NOT NULL,
	[LogType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[FlowFormId] [int] NOT NULL,
	[PK_ID] [int] NOT NULL,
	[GROUP_NO] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[UNIT_NO] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[BRANCH_NO] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[TX_DATE] [date] NULL,
	[AS_OF_DATE] [date] NULL,
	[PRODUCT_TYPE] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[TRAN_NO] [nvarchar](25) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CUSTOMER_NAME] [nvarchar](40) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CUSTOMER_ID] [nvarchar](11) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[COUNTRY_COD] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CURENCY_COD] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[TRAN_AMOUNT] [decimal](18, 2) NULL,
	[TO_USD_AMT] [decimal](18, 2) NULL,
	[PERMIT_NO] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LIMIT] [decimal](18, 2) NULL,
	[LIMIT_COD] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[TO_USD_LIMIT] [decimal](18, 2) NULL,
	[REVOLVE_MK] [bit] NOT NULL,
	[FIL9] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SOURCE] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CREATOR] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LIMIT_MATURITY] [date] NULL,
	[MATURITY_DATE] [date] NULL,
	[GROUP_NAME] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[INDUSTRY] [nvarchar](6) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[INDUSTRY_Type] [int] NULL,
	[PRODUCT_CODE] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CUR_BOUG';
SET @FilegroupSql += N'HT] [nchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CUR_SOLD] [nchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[RISKFACTOR] [decimal](10, 2) NULL,
	[WEIGHTS] [int] NULL,
	[DATADATE] [date] NULL,
	[Create_Date] [date] NULL,
	[Create_DateTime] [datetime] NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Year] [int] NULL,
	[Month] [int] NULL,
	[Week] [int] NULL,
	[EXT_DATE] [date] NULL,
	[Mark] [bit] NULL,
	[Lock] [bit] NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[TRAN_FXRATE] [decimal](18, 10) NULL,
	[LIMIT_FXRATE] [decimal](18, 10) NULL,
	[CAL_TO_USD_AMT] [decimal](18, 2) NULL,
	[CAL_TO_USD_LIMIT] [decimal](18, 2) NULL,
 CONSTRAINT [PK__MONITORD__2D26E78EA4B1BE09] PRIMARY KEY CLUSTERED
(
	[Log_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[MONITORDATA_his] ADD  CONSTRAINT [DF__MONITORDA__SysCr__2C745649]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'歷史記錄識別碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MONITORDATA_his', @level2type=N'COLUMN',@level2name=N'Log_Id'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[MONITORDATA_temp](
	[TempId] [int] IDENTITY(1,1) NOT NULL,
	[FlowFormId] [int] NULL,
	[ModifyType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[PK_ID] [int] NOT NULL,
	[GROUP_NO] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[UNIT_NO] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[BRANCH_NO] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[TX_DATE] [date] NULL,
	[AS_OF_DATE] [date] NULL,
	[PRODUCT_TYPE] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[TRAN_NO] [nvarchar](25) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CUSTOMER_NAME] [nvarchar](40) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CUSTOMER_ID] [nvarchar](11) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[COUNTRY_COD] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CURENCY_COD] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[TRAN_AMOUNT] [decimal](18, 2) NULL,
	[TO_USD_AMT] [decimal](18, 2) NULL,
	[PERMIT_NO] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LIMIT] [decimal](18, 2) NULL,
	[LIMIT_COD] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[TO_USD_LIMIT] [decimal](18, 2) NULL,
	[REVOLVE_MK] [bit] NOT NULL,
	[FIL9] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SOURCE] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CREATOR] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LIMIT_MATURITY] [date] NULL,
	[MATURITY_DATE] [date] NULL,
	[GROUP_NAME] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[INDUSTRY] [nvarchar](6) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[INDUSTRY_Type] [int] NULL,
	[PRODUCT_CODE] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CUR_BOUG';
SET @FilegroupSql += N'HT] [nchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CUR_SOLD] [nchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[RISKFACTOR] [decimal](10, 2) NULL,
	[WEIGHTS] [int] NULL,
	[DATADATE] [date] NULL,
	[Create_Date] [date] NULL,
	[Create_DateTime] [datetime] NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Year] [int] NULL,
	[Month] [int] NULL,
	[Week] [int] NULL,
	[EXT_DATE] [date] NULL,
	[Mark] [bit] NULL,
	[Lock] [bit] NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[TRAN_FXRATE] [decimal](18, 10) NULL,
	[LIMIT_FXRATE] [decimal](18, 10) NULL,
	[CAL_TO_USD_AMT] [decimal](18, 2) NULL,
	[CAL_TO_USD_LIMIT] [decimal](18, 2) NULL,
 CONSTRAINT [PK__MONITORD__06C703C13456C90D] PRIMARY KEY CLUSTERED
(
	[TempId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[MONITORDATA_temp] ADD  CONSTRAINT [DF__MONITORDA__REVOL__24D33481]  DEFAULT ((0)) FOR [REVOLVE_MK]
GO
ALTER TABLE [dbo].[MONITORDATA_temp] ADD  CONSTRAINT [DF__MONITORDA__Creat__25C758BA]  DEFAULT (getdate()) FOR [Create_Date]
GO
ALTER TABLE [dbo].[MONITORDATA_temp] ADD  CONSTRAINT [DF__MONITORDA__Creat__26BB7CF3]  DEFAULT (getdate()) FOR [Create_DateTime]
GO
ALTER TABLE [dbo].[MONITORDATA_temp] ADD  CONSTRAINT [DF__MONITORDA__Creat__27AFA12C]  DEFAULT ('System') FOR [Create_user]
GO
ALTER TABLE [dbo].[MONITORDATA_temp] ADD  CONSTRAINT [DF__MONITORDA__SysCr__28A3C565]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'暫存資料識別碼（流水號）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MONITORDATA_temp', @level2type=N'COLUMN',@level2name=N'TempId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'流程表單識別碼（外鍵：FlowForm.PK_ID）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MONITORDATA_temp', @level2type=N'COLUMN',@level2name=N'FlowFormId'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[News](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[Type] [int] NULL,
	[Title] [nvarchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Contents] [nvarchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Url] [nvarchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[IsActive] [bit] NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Release_date] [date] NULL,
 CONSTRAINT [PK_News] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[News] ADD  CONSTRAINT [DF_News_Contents]  DEFAULT ('') FOR [Contents]
GO
ALTER TABLE [dbo].[News] ADD  CONSTRAINT [DF_News_Url]  DEFAULT ('') FOR [Url]
GO
ALTER TABLE [dbo].[News] ADD  CONSTRAINT [DF_News_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[News] ADD  CONSTRAINT [DF_News_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[News_his](
	[Log_id] [int] IDENTITY(1,1) NOT NULL,
	[LogType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[FlowFormId] [int] NULL,
	[PK_Id] [int] NOT NULL,
	[Type] [int] NULL,
	[Title] [nvarchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Contents] [nvarchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Url] [nvarchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[IsActive] [bit] NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Release_date] [date] NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK__News_his__2D21E3B6405A97AA] PRIMARY KEY CLUSTERED
(
	[Log_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[News_his] ADD  CONSTRAINT [DF__News_his__Update__05CF8A74]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[News_his] ADD  CONSTRAINT [DF__News_his__Create__06C3AEAD]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[News_his] ADD  CONSTRAINT [DF__News_his__SysCre__07B7D2E6]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'歷史記錄識別碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'News_his', @level2type=N'COLUMN',@level2name=N'Log_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'異動行為類型 (INSERT/UPDATE/DELETE)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'News_his', @level2type=N'COLUMN',@level2name=N'LogType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'流程表單識別碼（外鍵：FlowForm.PK_ID）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'News_his', @level2type=N'COLUMN',@level2name=N'FlowFormId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立日期時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'News_his', @level2type=N'COLUMN',@level2name=N'SysCreateDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立使用者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'News_his', @level2type=N'COLUMN',@level2name=N'SysCreateUser'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[News_temp](
	[TempId] [int] IDENTITY(1,1) NOT NULL,
	[FlowFormId] [int] NULL,
	[FK_NewsPostId] [int] NULL,
	[ModifyType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[PK_Id] [int] NOT NULL,
	[Type] [int] NULL,
	[Title] [nvarchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Contents] [nvarchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Url] [nvarchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[IsActive] [bit] NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Release_date] [date] NULL,
 CONSTRAINT [PK__News_tem__06C703C185156229] PRIMARY KEY CLUSTERED
(
	[TempId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[News_temp] ADD  CONSTRAINT [DF__News_temp__Updat__0D7ACDDD]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[News_temp] ADD  CONSTRAINT [DF__News_temp__Creat__0E6EF216]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[News_temp] ADD  CONSTRAINT [DF__News_temp__SysCr__0F63164F]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'暫存資料識別碼（流水號）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'News_temp', @level2type=N'COLUMN',@level2name=N'TempId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'流程表單識別碼（外鍵：FlowForm.PK_ID）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'News_temp', @level2type=N'COLUMN',@level2name=N'FlowFormId'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[News_Views](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_NewsId] [int] NOT NULL,
	[Views] [int] NOT NULL,
 CONSTRAINT [PK_News_Views] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[NewsCountryType](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_CountryId] [int] NOT NULL,
	[FK_NewsId] [int] NOT NULL,
 CONSTRAINT [PK_NewsCountryType] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[NewsCountryType_his](
	[Log_Id] [int] IDENTITY(1,1) NOT NULL,
	[LogType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Fk_logId] [int] NOT NULL,
	[PK_Id] [int] NOT NULL,
	[FK_CountryId] [int] NOT NULL,
	[CountryName_TN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CountryName_CN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CountryName_EN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CountryName_JP] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CountryCode2] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK__NewsCoun__2D21E3B66EFF1A35] PRIMARY KEY CLUSTERED
(
	[Log_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[NewsCountryType_his] ADD  CONSTRAINT [DF__NewsCount__SysCr__0F58F4AE]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'歷史記錄識別碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'NewsCountryType_his', @level2type=N'COLUMN',@level2name=N'Log_Id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'異動行為類型 (INSERT/UPDATE/DELETE)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'NewsCountryType_his', @level2type=N'COLUMN',@level2name=N'LogType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立日期時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'NewsCountryType_his', @level2type=N'COLUMN',@level2name=N'SysCreateDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立使用者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'NewsCountryType_his', @level2type=N'COLUMN',@level2name=N'SysCreateUser'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[NewsCountryType_temp](
	[TempId] [int] IDENTITY(1,1) NOT NULL,
	[FK_TempId] [int] NOT NULL,
	[ModifyType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[PK_Id] [int] NULL,
	[FK_CountryId] [int] NULL,
	[FK_NewsId] [int] NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK__NewsCoun__06C703C191C6FBD2] PRIMARY KEY CLUSTERED
(
	[TempId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[NewsCountryType_temp] ADD  CONSTRAINT [DF__NewsCount__SysCr__6DF800E3]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'暫存資料識別碼（流水號）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'NewsCountryType_temp', @level2type=N'COLUMN',@level2name=N'TempId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'主表暫存資料外鍵' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'NewsCountryType_temp', @level2type=N'COLUMN',@level2name=N'FK_TempId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'異動類型' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'NewsCountryType_temp', @level2type=N'COLUMN',@level2name=N'ModifyType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立日期時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'NewsCountryType_temp', @level2type=N'COLUMN',@level2name=N'SysCreateDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立使用者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'NewsCountryType_temp', @level2type=N'COLUMN',@level2name=N'SysCreateUser'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[NewsFileMapping](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_NewsId] [int] NOT NULL,
	[FK_FileCenterId] [int] NOT NULL,
	[Create_date] [datetime] NULL,
	[Create_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_NewsFileMapping] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[NewsFileMapping_his](
	[Log_id] [int] IDENTITY(1,1) NOT NULL,
	[LogType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Fk_logId] [int] NOT NULL,
	[PK_Id] [int] NULL,
	[FileId] [int] NULL,
	[FileName] [nvarchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[FIle_Extension] [nvarchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Create_date] [datetime] NULL,
	[Create_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK__NewsFile__2D21E3B633184D46] PRIMARY KEY CLUSTERED
(
	[Log_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[NewsFileMapping_his] ADD  CONSTRAINT [DF__NewsFileM__SysCr__12356159]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'歷史記錄識別碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'NewsFileMapping_his', @level2type=N'COLUMN',@level2name=N'Log_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'異動行為類型 (INSERT/UPDATE/DELETE)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'NewsFileMapping_his', @level2type=N'COLUMN',@level2name=N'LogType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立日期時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'NewsFileMapping_his', @level2type=N'COLUMN',@level2name=N'SysCreateDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立使用者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'NewsFileMapping_his', @level2type=N'COLUMN',@level2name=N'SysCreateUser'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[NewsFileMapping_temp](
	[TempId] [int] IDENTITY(1,1) NOT NULL,
	[FK_TempId] [int] NOT NULL,
	[ModifyType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[PK_Id] [int] NULL,
	[FK_NewsId] [int] NULL,
	[FK_FileCenterId] [int] NULL,
	[Create_date] [datetime] NULL,
	[Create_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK__NewsFile__06C703C15E6CEB55] PRIMARY KEY CLUSTERED
(
	[TempId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[NewsFileMapping_temp] ADD  CONSTRAINT [DF__NewsFileM__SysCr__1333A733]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'暫存資料識別碼（流水號）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'NewsFileMapping_temp', @level2type=N'COLUMN',@level2name=N'TempId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'主表暫存資料外鍵' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'NewsFileMapping_temp', @level2type=N'COLUMN',@level2name=N'FK_TempId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'異動類型' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'NewsFileMapping_temp', @level2type=N'COLUMN',@level2name=N'ModifyType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立日期時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'NewsFileMapping_temp', @level2type=N'COLUMN',@level2name=N'SysCreateDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立使用者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'NewsFileMapping_temp', @level2type=N'COLUMN',@level2name=N'SysCreateUser'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[Notice](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[NoticeTitle] [nvarchar](255) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[NoticeType] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[NoticeContent] [nvarchar](4000) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_Notice] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[NoticeUser](
	[NoticeId] [int] NOT NULL,
	[UserId] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[IsRead] [bit] NOT NULL,
	[ReadDate] [datetime] NULL,
 CONSTRAINT [PK_NoticeUser] PRIMARY KEY CLUSTERED
(
	[NoticeId] ASC,
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE NONCLUSTERED INDEX [IX_NoticeUser] ON [dbo].[NoticeUser]
(
	[NoticeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
';
IF FILEGROUP_ID(N'NCRMS_IDX') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_IDX]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[OldData_Quota](
	[ExcelName] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[CountryCode2] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[RatingLevel] [int] NOT NULL,
	[TotalQuota] [int] NOT NULL,
	[TotalTranAmount] [decimal](18, 2) NOT NULL,
 CONSTRAINT [PK_OldData_Quota] PRIMARY KEY CLUSTERED
(
	[ExcelName] ASC,
	[CountryCode2] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[OldData_QuotaWeight](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[ExcelName] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[CountryId] [int] NOT NULL,
	[WeightPercent] [int] NOT NULL,
	[UnitCode] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[QuotaAmount] [int] NOT NULL,
 CONSTRAINT [PK_OldData_QuotaWeight] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[OldData_Rating](
	[ExcelName] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[CountryCode2] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Moodys] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[SP] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Fitch] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_OldData_Rating] PRIMARY KEY CLUSTERED
(
	[ExcelName] ASC,
	[CountryCode2] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[OS_LNSLMSD_D_MF](
	[LNSLMSD_BRANCH_NO] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LNSLMSD_LINE_NO] [nvarchar](13) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LNSLMSD_LINE_TYPE] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LNSLMSD_CIRCLE] [nvarchar](1) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LNSLMSD_CURRENCY] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LNSLMSD_APP_AMT] [decimal](17, 2) NULL,
	[LNSLMSD_CUSTOMER_ID] [nvarchar](11) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LNSLMSD_CUSTOMER_NAME] [nvarchar](36) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LNSLMSD_BGN_DATE] [date] NULL,
	[LNSLMSD_MATURITY] [date] NULL,
	[LNSLMSD_REG_COUNTRY] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LNSLMSD_APP_NO] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LNSLMSD_DATA_DATE] [date] NULL,
	[LNSLMSD_COUNTRY_RISK] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LNSLMSD_EXT_DATE] [date] NULL,
	[BUSINS_CODE] [nvarchar](7) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Create_date] [datetime] NOT NULL
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[OS_LNSLMSD_D_MF] ADD  CONSTRAINT [DF_OS_LNSLMSD_D_MF_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[OS_LNSLNKD_D_MF](
	[LNSLNKD_BRANCH_NO] [char](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LNSLNKD_DEPT_NO] [char](1) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LNSLNKD_LINE_NO] [char](13) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LNSLNKD_CUSTOMER_ID] [char](11) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LNSLNKD_SEC_NO] [char](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LNSLNKD_DATA_DATE] [date] NULL,
	[LNSLNKD_EXT_DATE] [date] NULL,
	[LNSLNKD_LOAD_DATE] [date] NULL,
	[LNSLNKD_LOAD_TIME] [char](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Create_date] [datetime] NOT NULL
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[OS_LNSLNKD_D_MF] ADD  CONSTRAINT [DF_OS_LNSLNKD_D_MF_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[OS_LNSMSTD_D_MF](
	[LNSMSTD_STATUS] [nvarchar](1) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LNSMSTD_BRANCH_NO] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LNSMSTD_TX_TYPE] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LNSMSTD_TX_NO] [nvarchar](25) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LNSMSTD_CURRENCY] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LNSMSTD_CUSTOMER_ID] [nvarchar](11) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LNSMSTD_LINE_NO] [nvarchar](13) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LNSMSTD_BALANCE] [decimal](15, 2) NULL,
	[LNSMSTD_BEGIN_DATE] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LNSMSTD_MATURITY] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LNSMSTD_ACCRUE_INT] [decimal](15, 2) NULL,
	[LNSMSTD_ACC_CODE_INT_9] [nchar](9) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LNSMSTD_DATA_DATE] [date] NULL,
	[LNSMSTD_EXT_DATE] [date] NULL,
	[BUSINS_CODE] [nvarchar](7) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Create_date] [datetime] NOT NULL
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[OS_LNSMSTD_D_MF] ADD  CONSTRAINT [DF_OS_LNSMSTD_D_MF_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'利息' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'OS_LNSMSTD_D_MF', @level2type=N'COLUMN',@level2name=N'LNSMSTD_ACCRUE_INT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'用來判斷是否為交易利息 ''135850003'',''135850004''  是交易利息 ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'OS_LNSMSTD_D_MF', @level2type=N'COLUMN',@level2name=N'LNSMSTD_ACC_CODE_INT_9'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[OS_LNSSECD_D_MF](
	[LNSSECD_BRANCH_NO] [char](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LNSSECD_CUSTOMER_ID] [char](11) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LNSSECD_SEC_NO] [char](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LNSSECD_SECURITY_TYPE] [char](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LNSSECD_CURRENCY] [char](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LNSSECD_SET_AMOUNT] [decimal](15, 2) NULL,
	[LNSSECD_SET_AMOUNT_USD] [decimal](15, 2) NULL,
	[LNSSECD_PRIORITY] [char](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LNSSECD_SET_AMOUNT_OTHERS] [decimal](15, 2) NULL,
	[LNSSECD_SET_AMOUNT_OTHERS_USD] [decimal](15, 2) NULL,
	[LNSSECD_CREDIT_LIMIT] [decimal](15, 2) NULL,
	[LNSSECD_CREDIT_LIMIT_USD] [decimal](15, 2) NULL,
	[LNSSECD_REF_PRICE] [decimal](15, 2) NULL,
	[LNSSECD_REF_PRICE_USD] [decimal](15, 2) NULL,
	[LNSSECD_REF_PRICE_DATE] [date] NULL,
	[LNSSECD_EVALUATE_PRICE] [decimal](15, 2) NULL,
	[LNSSECD_EVALUATE_PRICE_USD] [decimal](15, 2) NULL,
	[LNSSECD_EVALUATE_PRICE_DATE] [date] NULL,
	[LNSSECD_MATURITY] [date] NULL,
	[LNSSECD_EST_FR] [decimal](5, 0) NULL,
	[LNSSECD_SANDP] [char](6) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LNSSECD_MOODY] [char](6) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LNSSECD_FITCH] [char](6) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[LNSSECD_DATA_DATE] [date] NULL,
	[LNSSECD_EXT_DATE] [date] NULL,
	[LNSSECD_LOAD_DATE] [date] NULL,
	[LNSSECD_LOAD_TIME] [char](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Create_date] [datetime] NOT NULL
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[OS_LNSSECD_D_MF] ADD  CONSTRAINT [DF_OS_LNSSECD_D_MF_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[OSBDKF02_MF](
	[OSBDKF02_BRANCH_NO] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[OSBDKF02_TRAN_NO] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[OSBDKF02_TX_DATE] [date] NULL,
	[OSBDKF02_SWIFT_ID] [nvarchar](11) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[OSBDKF02_CUST_NAME1] [nvarchar](40) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[OSBDKF02_DOWN_DATE] [date] NULL,
	[OSBDKF02_MATURITY_DATE] [date] NULL,
	[OSBDKF02_CURENCY_COD] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[OSBDKF02_BALANCE_AMT] [decimal](17, 2) NULL,
	[OSBDKF02_BOND_PRICE] [decimal](17, 2) NULL,
	[OSBDKF02_LINE_PERMIT_NO] [nvarchar](13) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[OSBDKF02_ISSUER_COUNTRY] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[OSBDKF02_AC_9] [nvarchar](9) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[OSBDKF02_PRICE] [decimal](11, 5) NULL,
	[OSBDKF02_EXT_DATE] [date] NULL,
	[BUSINS_CODE] [nvarchar](7) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Create_date] [datetime] NOT NULL
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[OSBDKF02_MF] ADD  CONSTRAINT [DF_OSBDKF02_MF_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'交易金額新的' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'OSBDKF02_MF', @level2type=N'COLUMN',@level2name=N'OSBDKF02_BALANCE_AMT'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[OSFXKF02_MF](
	[OSFXKF02_BRANCH_NO] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[OSFXKF02_TRAN_NO] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[OSFXKF02_TX_DATE] [date] NULL,
	[OSFXKF02_TX_TYPE] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[OSFXKF02_CUATOMER_ID] [nvarchar](11) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[OSFXKF02_CUST_NAME1] [nvarchar](40) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[OSFXKF02_CPTY_COUNTRY] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[OSFXKF02_CPTY_COUNTRY_RISK] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[OSFXKF02_DEL_DATE] [date] NULL,
	[OSFXKF02_VALUE_DATE0] [date] NULL,
	[OSFXKF02_OBJECT_CCY] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[OSFXKF02_OBJECT_AMT] [decimal](17, 2) NULL,
	[OSFXKF02_CUR_BOUGHT] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[OSFXKF02_CUR_SOLD] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[OSFXKF02_EXT_DATE] [date] NULL,
	[BUSINS_CODE] [nvarchar](7) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Create_date] [datetime] NOT NULL
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[OSFXKF02_MF] ADD  CONSTRAINT [DF_OSFXKF02_MF_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[OSISKF02_MF](
	[OSISKF02_BRANCH_NO] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[OSISKF02_TRAN_NO] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[OSISKF02_TX_DATE] [date] NULL,
	[OSISKF02_CUATOMER_ID] [nvarchar](11) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[OSISKF02_CUST_NAME1] [nvarchar](40) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[OSISKF02_CPTY_COUNTRY] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[OSISKF02_CPTY_COUNTRY_RISK] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[OSISKF02_TRADE_DATE] [date] NULL,
	[OSISKF02_MATURITY] [date] NULL,
	[OSISKF02_IN_CCY] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[OSISKF02_RISK_AMT] [decimal](17, 2) NULL,
	[OSISKF02_EXT_DATE] [date] NULL,
	[BUSINS_CODE] [nvarchar](7) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Create_date] [datetime] NOT NULL
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[OSISKF02_MF] ADD  CONSTRAINT [DF_OSISKF02_MF_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[OSMMKF02_MF](
	[OSMMKF02_BRANCH_NO] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[OSMMKF02_TRAN_NO] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[OSMMKF02_TX_DATE] [date] NULL,
	[OSMMKF02_TRAN_TYPE] [nvarchar](1) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[OSMMKF02_SWIFT_ID] [nvarchar](11) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[OSMMKF02_CUST_NAME1] [nvarchar](40) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[OSMMKF02_CURENCY_COD] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[OSMMKF02_TRAN_AMOUNT] [decimal](17, 2) NULL,
	[OSMMKF02_MATURITY_DATE] [date] NULL,
	[OSMMKF02_COUNTRY_RISK] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[OSMMKF02_CONTRACT_DATE] [date] NULL,
	[OSMMKF02_EXT_DATE] [date] NULL,
	[BUSINS_CODE] [nvarchar](7) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Create_date] [datetime] NOT NULL
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[OSMMKF02_MF] ADD  CONSTRAINT [DF_OSMMKF02_MF_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[Permissions](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_Role_Id] [int] NOT NULL,
	[FK_Feature_Id] [int] NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_PERMISSIONS] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[Permissions] ADD  CONSTRAINT [DF_PERMISSIONS_FK_Role_Id]  DEFAULT ((0)) FOR [FK_Role_Id]
GO
ALTER TABLE [dbo].[Permissions] ADD  CONSTRAINT [DF_Permissions_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'權限對定的角色' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Permissions', @level2type=N'COLUMN',@level2name=N'FK_Role_Id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'權限對應的功能' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Permissions', @level2type=N'COLUMN',@level2name=N'FK_Feature_Id'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[Permissions_his](
	[log_Id] [int] IDENTITY(1,1) NOT NULL,
	[logType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[log_Role_Id] [int] NULL,
	[PK_Id] [int] NULL,
	[FK_Role_Id] [int] NOT NULL,
	[FK_Feature_Id] [int] NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_Permissions_his] PRIMARY KEY CLUSTERED
(
	[log_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[Permissions_his] ADD  CONSTRAINT [DF_Permissions_his_FK_Role_Id]  DEFAULT ('') FOR [FK_Role_Id]
GO
ALTER TABLE [dbo].[Permissions_his] ADD  CONSTRAINT [DF_Permissions_his_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[Permissions_his] ADD  CONSTRAINT [DF_Permissions_his_SysCreateDate]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
ALTER TABLE [dbo].[Permissions_his] ADD  CONSTRAINT [DF_Permissions_his_SysCreate_user]  DEFAULT ('') FOR [SysCreateUser]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'異動狀態' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Permissions_his', @level2type=N'COLUMN',@level2name=N'logType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'對應到的角色ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Permissions_his', @level2type=N'COLUMN',@level2name=N'FK_Role_Id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'權限對應到的功能ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Permissions_his', @level2type=N'COLUMN',@level2name=N'FK_Feature_Id'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[Permissions_Query](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_Role_Id] [int] NOT NULL,
	[LevelCode] [int] NOT NULL,
	[OrgCode] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_Permissions_Query] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[Permissions_Query] ADD  CONSTRAINT [DF_Permissions_Query_FK_Role_Id]  DEFAULT ((0)) FOR [FK_Role_Id]
GO
ALTER TABLE [dbo].[Permissions_Query] ADD  CONSTRAINT [DF_Permissions_Query_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'權限對定的角色' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Permissions_Query', @level2type=N'COLUMN',@level2name=N'FK_Role_Id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'單位層級' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Permissions_Query', @level2type=N'COLUMN',@level2name=N'LevelCode'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'群、處、分行 代碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Permissions_Query', @level2type=N'COLUMN',@level2name=N'OrgCode'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建立時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Permissions_Query', @level2type=N'COLUMN',@level2name=N'Create_date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建立者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Permissions_Query', @level2type=N'COLUMN',@level2name=N'Create_user'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[Permissions_Query_his](
	[log_id] [int] IDENTITY(1,1) NOT NULL,
	[logtype] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[log_Role_Id] [int] NOT NULL,
	[PK_Id] [int] NOT NULL,
	[FK_Role_Id] [int] NOT NULL,
	[LevelCode] [int] NOT NULL,
	[OrgCode] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK__Permissi__9E2397E072A11B54] PRIMARY KEY CLUSTERED
(
	[log_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[Permissions_Query_his] ADD  CONSTRAINT [DF_Permissions_Query_his_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[Permissions_Query_his] ADD  CONSTRAINT [DF_Permissions_Query_his_SysCreateDate]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[Post](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[Type] [int] NULL,
	[Title] [nvarchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Contents] [nvarchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Url] [nvarchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[IsActive] [bit] NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Release_date] [date] NULL,
	[Category] [int] NULL,
 CONSTRAINT [PK_Post] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[Post] ADD  CONSTRAINT [DF_Post_Contents]  DEFAULT ('') FOR [Contents]
GO
ALTER TABLE [dbo].[Post] ADD  CONSTRAINT [DF_Post_Url]  DEFAULT ('') FOR [Url]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[Post_his](
	[Log_id] [int] IDENTITY(1,1) NOT NULL,
	[LogType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[FlowFormId] [int] NULL,
	[PK_Id] [int] NOT NULL,
	[Type] [int] NULL,
	[Title] [nvarchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Contents] [nvarchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Url] [nvarchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[IsActive] [bit] NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Release_date] [date] NULL,
	[Category] [int] NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK__Post_his__2D21E3B6934210DC] PRIMARY KEY CLUSTERED
(
	[Log_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[Post_his] ADD  CONSTRAINT [DF__Post_his__SysCre__1ACAA75A]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'歷史記錄識別碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Post_his', @level2type=N'COLUMN',@level2name=N'Log_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'異動行為類型 (INSERT/UPDATE/DELETE)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Post_his', @level2type=N'COLUMN',@level2name=N'LogType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'流程表單識別碼（外鍵：FlowForm.PK_ID）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Post_his', @level2type=N'COLUMN',@level2name=N'FlowFormId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立日期時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Post_his', @level2type=N'COLUMN',@level2name=N'SysCreateDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立使用者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Post_his', @level2type=N'COLUMN',@level2name=N'SysCreateUser'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[Post_temp](
	[TempId] [int] IDENTITY(1,1) NOT NULL,
	[FlowFormId] [int] NULL,
	[ModifyType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[FK_NewsPostId] [int] NULL,
	[PK_Id] [int] NOT NULL,
	[Type] [int] NULL,
	[Title] [nvarchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Contents] [nvarchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Url] [nvarchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[IsActive] [bit] NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Release_date] [date] NULL,
	[Category] [int] NULL,
 CONSTRAINT [PK__Post_tem__06C703C18F5452D8] PRIMARY KEY CLUSTERED
(
	[TempId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[Post_temp] ADD  CONSTRAINT [DF__Post_temp__SysCr__18EC8089]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'暫存資料識別碼（流水號）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Post_temp', @level2type=N'COLUMN',@level2name=N'TempId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'流程表單識別碼（外鍵：FlowForm.PK_ID）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Post_temp', @level2type=N'COLUMN',@level2name=N'FlowFormId'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[Post_Views](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_PostId] [int] NOT NULL,
	[Views] [int] NOT NULL,
 CONSTRAINT [PK_Post_Views] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[PostCountryType](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_CountryId] [int] NOT NULL,
	[FK_PostId] [int] NOT NULL,
 CONSTRAINT [PK_PostCountryType] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[PostCountryType_his](
	[Log_id] [int] IDENTITY(1,1) NOT NULL,
	[LogType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Fk_logId] [int] NOT NULL,
	[PK_Id] [int] NOT NULL,
	[FK_CountryId] [int] NOT NULL,
	[CountryCode2] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CountryName_TN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CountryName_CN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CountryName_EN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CountryName_JP] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK__PostCoun__2D21E3B605E7C15A] PRIMARY KEY CLUSTERED
(
	[Log_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[PostCountryType_his] ADD  CONSTRAINT [DF__PostCount__SysCr__1E9B383E]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'歷史記錄識別碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PostCountryType_his', @level2type=N'COLUMN',@level2name=N'Log_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'異動行為類型 (INSERT/UPDATE/DELETE)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PostCountryType_his', @level2type=N'COLUMN',@level2name=N'LogType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立日期時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PostCountryType_his', @level2type=N'COLUMN',@level2name=N'SysCreateDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立使用者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PostCountryType_his', @level2type=N'COLUMN',@level2name=N'SysCreateUser'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[PostCountryType_temp](
	[TempId] [int] IDENTITY(1,1) NOT NULL,
	[FK_TempId] [int] NOT NULL,
	[ModifyType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[PK_Id] [int] NULL,
	[FK_CountryId] [int] NULL,
	[FK_PostId] [int] NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK__PostCoun__06C703C11BBDA5A7] PRIMARY KEY CLUSTERED
(
	[TempId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[PostCountryType_temp] ADD  CONSTRAINT [DF__PostCount__SysCr__683F278D]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'暫存資料識別碼（流水號）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PostCountryType_temp', @level2type=N'COLUMN',@level2name=N'TempId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'主表暫存資料外鍵' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PostCountryType_temp', @level2type=N'COLUMN',@level2name=N'FK_TempId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'異動類型' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PostCountryType_temp', @level2type=N'COLUMN',@level2name=N'ModifyType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立日期時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PostCountryType_temp', @level2type=N'COLUMN',@level2name=N'SysCreateDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立使用者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PostCountryType_temp', @level2type=N'COLUMN',@level2name=N'SysCreateUser'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[PostFileMapping](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_PostId] [int] NOT NULL,
	[FK_FileCenterId] [int] NOT NULL,
	[Create_date] [datetime] NULL,
	[Create_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_PostFileMapping] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[PostFileMapping_his](
	[Log_id] [int] IDENTITY(1,1) NOT NULL,
	[LogType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Fk_logId] [int] NOT NULL,
	[PK_Id] [int] NOT NULL,
	[FileId] [int] NULL,
	[FileName] [nchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[File_Extension] [nchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Create_date] [datetime] NULL,
	[Create_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK__PostFile__2D21E3B6396B36C0] PRIMARY KEY CLUSTERED
(
	[Log_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[PostFileMapping_his] ADD  CONSTRAINT [DF__PostFileM__SysCr__2177A4E9]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'歷史記錄識別碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PostFileMapping_his', @level2type=N'COLUMN',@level2name=N'Log_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'異動行為類型 (INSERT/UPDATE/DELETE)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PostFileMapping_his', @level2type=N'COLUMN',@level2name=N'LogType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立日期時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PostFileMapping_his', @level2type=N'COLUMN',@level2name=N'SysCreateDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立使用者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PostFileMapping_his', @level2type=N'COLUMN',@level2name=N'SysCreateUser'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[PostFileMapping_temp](
	[TempId] [int] IDENTITY(1,1) NOT NULL,
	[FK_TempId] [int] NOT NULL,
	[ModifyType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[PK_Id] [int] NULL,
	[FK_PostId] [int] NULL,
	[FK_FileCenterId] [int] NULL,
	[Create_date] [datetime] NULL,
	[Create_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK__PostFile__06C703C1CA6F8ED9] PRIMARY KEY CLUSTERED
(
	[TempId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[PostFileMapping_temp] ADD  CONSTRAINT [DF__PostFileM__SysCr__161013DE]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'暫存資料識別碼（流水號）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PostFileMapping_temp', @level2type=N'COLUMN',@level2name=N'TempId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'主表暫存資料外鍵' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PostFileMapping_temp', @level2type=N'COLUMN',@level2name=N'FK_TempId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'異動類型' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PostFileMapping_temp', @level2type=N'COLUMN',@level2name=N'ModifyType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立日期時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PostFileMapping_temp', @level2type=N'COLUMN',@level2name=N'SysCreateDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立使用者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PostFileMapping_temp', @level2type=N'COLUMN',@level2name=N'SysCreateUser'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[ProductMaster](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[GroupCode] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[ProductCode] [nvarchar](5) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[ProductName_TN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[ProductName_EN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[ProductName_CN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[ProductName_JP] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_ProductMaster] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[ProductMaster] ADD  CONSTRAINT [DF_ProductMaster_GroupCode]  DEFAULT ('') FOR [GroupCode]
GO
ALTER TABLE [dbo].[ProductMaster] ADD  CONSTRAINT [DF_ProductMaster_ProductName_EN]  DEFAULT ('') FOR [ProductName_EN]
GO
ALTER TABLE [dbo].[ProductMaster] ADD  CONSTRAINT [DF_ProductMaster_ProductName_CN]  DEFAULT ('') FOR [ProductName_CN]
GO
ALTER TABLE [dbo].[ProductMaster] ADD  CONSTRAINT [DF_ProductMaster_ProductName_JP]  DEFAULT ('') FOR [ProductName_JP]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'產品群組' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProductMaster', @level2type=N'COLUMN',@level2name=N'GroupCode'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'產品種類' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProductMaster', @level2type=N'COLUMN',@level2name=N'ProductCode'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'繁中' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProductMaster', @level2type=N'COLUMN',@level2name=N'ProductName_TN'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[QuickLink](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_Menu_Id] [int] NULL,
	[ParentId] [int] NULL,
	[Name] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[DisplayName] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Type] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Icon] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[IconColor] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Seq] [int] NOT NULL,
	[UserId] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_QuickLink] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[QuotaBank_D](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[CountryId] [int] NOT NULL,
	[UnitCode] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[QuotaAmount] [int] NOT NULL,
	[Memo] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
 CONSTRAINT [PK_QuotaBankD] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[QuotaBank_D] ADD  CONSTRAINT [DF_QuotaBank_D_Memo]  DEFAULT ('') FOR [Memo]
GO
ALTER TABLE [dbo].[QuotaBank_D] ADD  CONSTRAINT [DF_QuotaBank_D_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[QuotaBank_D] ADD  CONSTRAINT [DF_QuotaBank_D_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[QuotaBank_D_Form_AllData](
	[Pk_Id] [int] IDENTITY(1,1) NOT NULL,
	[QuotaFormAllData_MId] [int] NOT NULL,
	[UnitCode] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[QuotaAmount] [int] NOT NULL,
 CONSTRAINT [PK_QuotaBank_D_Form_AllData] PRIMARY KEY CLUSTERED
(
	[Pk_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'暫存資料識別碼（流水號）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QuotaBank_D_Form_AllData', @level2type=N'COLUMN',@level2name=N'Pk_Id'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[QuotaBank_D_his](
	[Log_id] [int] IDENTITY(1,1) NOT NULL,
	[LogType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Fk_logId] [int] NOT NULL,
	[CountryId] [int] NOT NULL,
	[UnitCode] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[QuotaAmount] [int] NOT NULL,
	[Memo] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK__QuotaBan__2D21E3B6A835C6F9] PRIMARY KEY CLUSTERED
(
	[Log_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[QuotaBank_D_his] ADD  CONSTRAINT [DF__QuotaBank__SysCr__109731AA]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'歷史記錄識別碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QuotaBank_D_his', @level2type=N'COLUMN',@level2name=N'Log_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'異動行為類型 (INSERT/UPDATE/DELETE)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QuotaBank_D_his', @level2type=N'COLUMN',@level2name=N'LogType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立日期時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QuotaBank_D_his', @level2type=N'COLUMN',@level2name=N'SysCreateDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立使用者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QuotaBank_D_his', @level2type=N'COLUMN',@level2name=N'SysCreateUser'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[QuotaBank_D_temp](
	[TempId] [int] IDENTITY(1,1) NOT NULL,
	[FK_TempId] [int] NOT NULL,
	[ModifyType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[CountryId] [int] NOT NULL,
	[UnitCode] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[QuotaAmount] [int] NOT NULL,
	[Memo] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK__QuotaBan__06C703C10F79C68D] PRIMARY KEY CLUSTERED
(
	[TempId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[QuotaBank_D_temp] ADD  CONSTRAINT [DF__QuotaBank___Memo__6D4DF56D]  DEFAULT ('') FOR [Memo]
GO
ALTER TABLE [dbo].[QuotaBank_D_temp] ADD  CONSTRAINT [DF__QuotaBank__SysCr__702A6218]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'暫存資料識別碼（流水號）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QuotaBank_D_temp', @level2type=N'COLUMN',@level2name=N'TempId'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[QuotaBank_D_Week](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[QuotaDate] [date] NULL,
	[Year] [int] NOT NULL,
	[Month] [int] NOT NULL,
	[Week] [int] NOT NULL,
	[CountryId] [int] NOT NULL,
	[UnitCode] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[QuotaAmount] [int] NOT NULL,
	[Memo] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
 CONSTRAINT [PK_QuotaBankD_Week] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_PADDING ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE UNIQUE NONCLUSTERED INDEX [IX_QuotaBank_D_Week] ON [dbo].[QuotaBank_D_Week]
(
	[Year] ASC,
	[Month] ASC,
	[Week] ASC,
	[CountryId] ASC,
	[UnitCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
';
IF FILEGROUP_ID(N'NCRMS_IDX') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_IDX]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[QuotaBank_D_Week] ADD  CONSTRAINT [DF_QuotaBank_D_Week_Memo]  DEFAULT ('') FOR [Memo]
GO
ALTER TABLE [dbo].[QuotaBank_D_Week] ADD  CONSTRAINT [DF_QuotaBank_D_Week_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[QuotaBank_D_Week] ADD  CONSTRAINT [DF_QuotaBank_D_Week_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[QuotaBank_Form_Data](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FlowFormId] [int] NOT NULL,
	[TotalNetWorthUSD] [decimal](18, 2) NOT NULL,
	[SysCreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_QuotaBank_Form_Data] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[QuotaBank_Form_Data] ADD  CONSTRAINT [DF_QuotaBank_Form_Data_SysCreateDate]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[QuotaBank_Form_ParentWeight](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FlowFormId] [int] NOT NULL,
	[CountryId] [int] NOT NULL,
	[ParentUnitCode] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[WeightPercent] [int] NOT NULL,
	[QuotaAmount] [int] NOT NULL,
 CONSTRAINT [PK_QuotaBank_Form_ParentWeight] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'暫存資料識別碼（流水號）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QuotaBank_Form_ParentWeight', @level2type=N'COLUMN',@level2name=N'PK_Id'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[QuotaBank_M](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[CountryId] [int] NOT NULL,
	[ApprovedAmount] [int] NOT NULL,
	[TotalUtilizedAmount] [int] NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
 CONSTRAINT [PK_QuotaBank] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[QuotaBank_M] ADD  CONSTRAINT [DF_QuotaBank_M_TotalUtilizedAmount]  DEFAULT ((0)) FOR [TotalUtilizedAmount]
GO
ALTER TABLE [dbo].[QuotaBank_M] ADD  CONSTRAINT [DF_QuotaBank_M_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[QuotaBank_M] ADD  CONSTRAINT [DF_QuotaBank_M_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'國家代碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QuotaBank_M', @level2type=N'COLUMN',@level2name=N'CountryId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'授權額度' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QuotaBank_M', @level2type=N'COLUMN',@level2name=N'ApprovedAmount'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'總分配額度' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QuotaBank_M', @level2type=N'COLUMN',@level2name=N'TotalUtilizedAmount'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[QuotaBank_M_Form_AllData](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FlowFormId] [int] NULL,
	[CountryId] [int] NOT NULL,
	[RiskLevel] [int] NOT NULL,
	[MaxAmount] [int] NOT NULL,
	[ApprovedAmount] [int] NOT NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[UnitLevel] [int] NOT NULL,
	[ParentUnitCode] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
 CONSTRAINT [PK_QuotaBank_M_Form_AllData] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[QuotaBank_M_Form_AllData] ADD  CONSTRAINT [DF_QuotaBank_M_Form_AllData_SysCreateDate]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
ALTER TABLE [dbo].[QuotaBank_M_Form_AllData] ADD  CONSTRAINT [DF_QuotaBank_M_Form_AllData_UnitLevel]  DEFAULT ((0)) FOR [UnitLevel]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'暫存資料識別碼（流水號）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QuotaBank_M_Form_AllData', @level2type=N'COLUMN',@level2name=N'PK_Id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'流程表單識別碼（外鍵：FlowForm.PK_ID）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QuotaBank_M_Form_AllData', @level2type=N'COLUMN',@level2name=N'FlowFormId'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[QuotaBank_M_his](
	[Log_Id] [int] IDENTITY(1,1) NOT NULL,
	[LogType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[FlowFormId] [int] NOT NULL,
	[UnitLevel] [int] NOT NULL,
	[CountryId] [int] NOT NULL,
	[RiskLevel] [int] NOT NULL,
	[ParentUnitCode] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[MaxAmount] [int] NOT NULL,
	[ApprovedAmount] [int] NOT NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_QuotaBank_M_his] PRIMARY KEY CLUSTERED
(
	[Log_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[QuotaBank_M_his] ADD  CONSTRAINT [DF_QuotaBank_M_his_SysCreateDate]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'暫存資料識別碼（流水號）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QuotaBank_M_his', @level2type=N'COLUMN',@level2name=N'Log_Id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'流程表單識別碼（外鍵：FlowForm.PK_ID）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QuotaBank_M_his', @level2type=N'COLUMN',@level2name=N'FlowFormId'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[QuotaBank_M_temp](
	[TempId] [int] IDENTITY(1,1) NOT NULL,
	[FlowFormId] [int] NULL,
	[ModifyType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[UnitLevel] [int] NOT NULL,
	[CountryId] [int] NOT NULL,
	[RiskLevel] [int] NOT NULL,
	[ParentUnitCode] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[MaxAmount] [int] NOT NULL,
	[ApprovedAmount] [int] NOT NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_QuotaBank_M_temp] PRIMARY KEY CLUSTERED
(
	[TempId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[QuotaBank_M_temp] ADD  CONSTRAINT [DF_QuotaBank_M_temp_SysCreateDate]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'暫存資料識別碼（流水號）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QuotaBank_M_temp', @level2type=N'COLUMN',@level2name=N'TempId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'流程表單識別碼（外鍵：FlowForm.PK_ID）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QuotaBank_M_temp', @level2type=N'COLUMN',@level2name=N'FlowFormId'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[QuotaBank_M_Week](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[QuotaDate] [date] NULL,
	[Year] [int] NOT NULL,
	[Month] [int] NOT NULL,
	[Week] [int] NOT NULL,
	[CountryId] [int] NOT NULL,
	[ApprovedAmount] [int] NOT NULL,
	[TotalUtilizedAmount] [int] NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
 CONSTRAINT [PK_QuotaBank_M_Week] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB],
 CONSTRAINT [IX_QuotaBank_M_Week] UNIQUE NONCLUSTERED
(
	[Year] ASC,
	[Month] ASC,
	[Week] ASC,
	[CountryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
IF FILEGROUP_ID(N'NCRMS_IDX') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_IDX]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[QuotaBank_M_Week] ADD  CONSTRAINT [DF_QuotaBank_M_Week_TotalUtilizedAmount]  DEFAULT ((0)) FOR [TotalUtilizedAmount]
GO
ALTER TABLE [dbo].[QuotaBank_M_Week] ADD  CONSTRAINT [DF_QuotaBank_M_Week_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[QuotaBank_M_Week] ADD  CONSTRAINT [DF_QuotaBank_M_Week_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'國家代碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QuotaBank_M_Week', @level2type=N'COLUMN',@level2name=N'CountryId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'授權額度' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QuotaBank_M_Week', @level2type=N'COLUMN',@level2name=N'ApprovedAmount'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'總分配額度' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QuotaBank_M_Week', @level2type=N'COLUMN',@level2name=N'TotalUtilizedAmount'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[QuotaBank_Weight](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[QuotaBankDetailId] [int] NOT NULL,
	[CountryWeightId] [int] NOT NULL,
	[QuotaAmount] [int] NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
 CONSTRAINT [PK_QuotaBank_Weight] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[QuotaBank_Weight_Form_AllData](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[QuotaD_Form_AllDataId] [int] NOT NULL,
	[WeightPercent] [int] NOT NULL,
	[QuotaAmount] [int] NOT NULL,
 CONSTRAINT [PK_QuotaBank_Weight_Form_AllData] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'主表暫存資料外鍵' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QuotaBank_Weight_Form_AllData', @level2type=N'COLUMN',@level2name=N'QuotaD_Form_AllDataId'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[QuotaBank_Weight_his](
	[Log_id] [int] IDENTITY(1,1) NOT NULL,
	[LogType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Fk_logId] [int] NOT NULL,
	[QuotaBankDetailId] [int] NOT NULL,
	[WeightPercent] [int] NOT NULL,
	[QuotaAmount] [int] NOT NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK__QuotaBan__2D21E3B6A00EBB77] PRIMARY KEY CLUSTERED
(
	[Log_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[QuotaBank_Weight_his] ADD  CONSTRAINT [DF__QuotaBank__SysCr__13739E55]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'歷史記錄識別碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QuotaBank_Weight_his', @level2type=N'COLUMN',@level2name=N'Log_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'異動行為類型 (INSERT/UPDATE/DELETE)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QuotaBank_Weight_his', @level2type=N'COLUMN',@level2name=N'LogType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立日期時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QuotaBank_Weight_his', @level2type=N'COLUMN',@level2name=N'SysCreateDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立使用者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QuotaBank_Weight_his', @level2type=N'COLUMN',@level2name=N'SysCreateUser'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[QuotaBank_Weight_temp](
	[TempId] [int] IDENTITY(1,1) NOT NULL,
	[FK_TempId] [int] NOT NULL,
	[ModifyType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[QuotaBankDetailId] [int] NOT NULL,
	[WeightPercent] [int] NOT NULL,
	[QuotaAmount] [int] NOT NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK__QuotaBan__06C703C1486D8CE9] PRIMARY KEY CLUSTERED
(
	[TempId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[QuotaBank_Weight_temp] ADD  CONSTRAINT [DF__QuotaBank__SysCr__73FAF2FC]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'暫存資料識別碼（流水號）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QuotaBank_Weight_temp', @level2type=N'COLUMN',@level2name=N'TempId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'主表暫存資料外鍵' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QuotaBank_Weight_temp', @level2type=N'COLUMN',@level2name=N'FK_TempId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'異動類型' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QuotaBank_Weight_temp', @level2type=N'COLUMN',@level2name=N'ModifyType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立日期時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QuotaBank_Weight_temp', @level2type=N'COLUMN',@level2name=N'SysCreateDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立使用者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QuotaBank_Weight_temp', @level2type=N'COLUMN',@level2name=N'SysCreateUser'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[QuotaBank_Weight_Week](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[QuotaDate] [date] NULL,
	[Year] [int] NOT NULL,
	[Month] [int] NOT NULL,
	[Week] [int] NOT NULL,
	[QuotaBankDetailId] [int] NOT NULL,
	[CountryId] [int] NOT NULL,
	[UnitCode] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[CountryWeightId] [int] NOT NULL,
	[QuotaAmount] [int] NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
 CONSTRAINT [PK_QuotaBank_Weight_Week] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_PADDING ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE UNIQUE NONCLUSTERED INDEX [IX_QuotaBank_Weight_Week] ON [dbo].[QuotaBank_Weight_Week]
(
	[Year] ASC,
	[Month] ASC,
	[Week] ASC,
	[UnitCode] ASC,
	[CountryWeightId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
';
IF FILEGROUP_ID(N'NCRMS_IDX') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_IDX]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[QuotaBank_Weight_Week] ADD  CONSTRAINT [DF_QuotaBank_Weight_Week_QuotaBankDetailId]  DEFAULT ((1)) FOR [QuotaBankDetailId]
GO
ALTER TABLE [dbo].[QuotaBank_Weight_Week] ADD  CONSTRAINT [DF_QuotaBank_Weight_Week_CountryId]  DEFAULT ((0)) FOR [CountryId]
GO
ALTER TABLE [dbo].[QuotaBank_Weight_Week] ADD  CONSTRAINT [DF_QuotaBank_Weight_Week_UnitCode]  DEFAULT ('') FOR [UnitCode]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[RatingRatioMaster](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[Year] [int] NOT NULL,
	[RatingLevel] [int] NOT NULL,
	[RiskRatio] [int] NOT NULL,
	[HasFCBBranch] [bit] NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK__RatingMu__F4A24B2232D6980E] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE NONCLUSTERED INDEX [IX_RatingRatioMaster] ON [dbo].[RatingRatioMaster]
(
	[Year] ASC,
	[RatingLevel] ASC,
	[HasFCBBranch] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
';
IF FILEGROUP_ID(N'NCRMS_IDX') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_IDX]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[RatingRatioMaster] ADD  CONSTRAINT [DF_RatingRatioMaster_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[RatingRatioMaster] ADD  CONSTRAINT [DF_RatingRatioMaster_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[RatingRatioMaster_his](
	[Log_id] [int] IDENTITY(1,1) NOT NULL,
	[LogType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Fk_logId] [int] NOT NULL,
	[PK_Id] [int] NOT NULL,
	[Year] [int] NOT NULL,
	[RatingLevel] [int] NOT NULL,
	[RiskRatio] [int] NOT NULL,
	[HasFCBBranch] [bit] NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK__RatingRa__2D21E3B6B416E659] PRIMARY KEY CLUSTERED
(
	[Log_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[RatingRatioMaster_his] ADD  CONSTRAINT [DF__RatingRat__SysCr__076CEECC]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'歷史記錄識別碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RatingRatioMaster_his', @level2type=N'COLUMN',@level2name=N'Log_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'異動行為類型 (INSERT/UPDATE/DELETE)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RatingRatioMaster_his', @level2type=N'COLUMN',@level2name=N'LogType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立日期時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RatingRatioMaster_his', @level2type=N'COLUMN',@level2name=N'SysCreateDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立使用者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RatingRatioMaster_his', @level2type=N'COLUMN',@level2name=N'SysCreateUser'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[RatingRatioMaster_temp](
	[TempId] [int] IDENTITY(1,1) NOT NULL,
	[FK_TempId] [int] NOT NULL,
	[ModifyType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[PK_Id] [int] NULL,
	[Year] [int] NULL,
	[RatingLevel] [int] NULL,
	[RiskRatio] [int] NULL,
	[HasFCBBranch] [bit] NULL,
	[Create_date] [datetime] NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Update_date] [datetime] NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK__RatingRa__06C703C1BF4C0345] PRIMARY KEY CLUSTERED
(
	[TempId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[RatingRatioMaster_temp] ADD  CONSTRAINT [DF__RatingRat__Creat__0A495B77]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[RatingRatioMaster_temp] ADD  CONSTRAINT [DF__RatingRat__Updat__0B3D7FB0]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[RatingRatioMaster_temp] ADD  CONSTRAINT [DF__RatingRat__SysCr__0C31A3E9]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'暫存資料識別碼（流水號）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RatingRatioMaster_temp', @level2type=N'COLUMN',@level2name=N'TempId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'主表暫存資料外鍵' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RatingRatioMaster_temp', @level2type=N'COLUMN',@level2name=N'FK_TempId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'異動類型' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RatingRatioMaster_temp', @level2type=N'COLUMN',@level2name=N'ModifyType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立日期時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RatingRatioMaster_temp', @level2type=N'COLUMN',@level2name=N'SysCreateDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立使用者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RatingRatioMaster_temp', @level2type=N'COLUMN',@level2name=N'SysCreateUser'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[RatingRatioMaster_Week](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[Year] [int] NOT NULL,
	[Month] [int] NOT NULL,
	[Week] [int] NOT NULL,
	[DataDate] [date] NULL,
	[RatingLevel] [int] NOT NULL,
	[RiskRatio] [int] NOT NULL,
	[HasFCBBranch] [bit] NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK__RatingRatioMaster_Week__F4A24B2232D6980E] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE NONCLUSTERED INDEX [IX_RatingRatioMaster_Week] ON [dbo].[RatingRatioMaster_Week]
(
	[Year] ASC,
	[Month] ASC,
	[Week] ASC,
	[RatingLevel] ASC,
	[HasFCBBranch] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
';
IF FILEGROUP_ID(N'NCRMS_IDX') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_IDX]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[RatingRatioMaster_Week] ADD  CONSTRAINT [DF_RatingRatioMaster_Week_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[RatingRatioMaster_Week] ADD  CONSTRAINT [DF_RatingRatioMaster_Week_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[RatingRatioMasterBase](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[RatingLevel] [int] NOT NULL,
	[RatingLevelName] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[RiskRatio] [int] NOT NULL,
	[HasFCBBranch] [bit] NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_RatingRatioMasterBase__F4A24B2232D6980E] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[RatingRatioMasterBase] ADD  CONSTRAINT [DF_RatingRatioMasterBase_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[RatingRatioMasterBase] ADD  CONSTRAINT [DF_RatingRatioMasterBase_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[RiskLineD](
	[GroupCode] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[UnitCode] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[BranchCode] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[CustomerId] [nvarchar](11) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[CustomerName] [nvarchar](40) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[LoanType] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[SYNDICATED_LOAN_MK] [bit] NOT NULL,
	[Apply_NO] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Apply_CURENCY_COD] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Apply_Amount] [decimal](18, 2) NOT NULL,
	[Apply_Date] [date] NOT NULL,
	[CountryCode2] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[PERMIT_NO] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[PERMIT_CURENCY_COD] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[PERMIT_Amount] [decimal](18, 2) NULL,
	[PERMIT_Date] [date] NULL,
	[REVOLVE_MK] [bit] NULL,
	[MATURITY_DATE] [date] NULL,
	[Approval_Status] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Memo] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Update_date] [datetime] NOT NULL,
 CONSTRAINT [PK_RiskLineD] PRIMARY KEY CLUSTERED
(
	[BranchCode] ASC,
	[Apply_NO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[RiskLineO](
	[GroupCode] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[UnitCode] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[BranchCode] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[CustomerId] [nvarchar](11) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[CustomerName] [nvarchar](40) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[LoanType] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[SYNDICATED_LOAN_MK] [bit] NOT NULL,
	[Apply_NO] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Apply_CURENCY_COD] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Apply_Amount] [decimal](18, 2) NOT NULL,
	[Apply_Date] [date] NOT NULL,
	[CountryCode2] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[PERMIT_NO] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[PERMIT_CURENCY_COD] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[PERMIT_Amount] [decimal](18, 2) NULL,
	[PERMIT_Date] [date] NULL,
	[REVOLVE_MK] [bit] NULL,
	[MATURITY_DATE] [date] NULL,
	[Approval_Status] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Memo] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Update_date] [datetime] NOT NULL,
 CONSTRAINT [PK_RiskLineO] PRIMARY KEY CLUSTERED
(
	[BranchCode] ASC,
	[Apply_NO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[Role](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_Unit_Code] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[RoleName_TN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[RoleName_CN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[RoleName_EN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[RoleName_JP] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_ROLE] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_PADDING ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE NONCLUSTERED INDEX [IX_Role_FK_Unit_Code] ON [dbo].[Role]
(
	[FK_Unit_Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
';
IF FILEGROUP_ID(N'NCRMS_IDX') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_IDX]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[Role] ADD  CONSTRAINT [DF_Role_RoleName_TN]  DEFAULT ('') FOR [RoleName_TN]
GO
ALTER TABLE [dbo].[Role] ADD  CONSTRAINT [DF_Role_RoleName_CN]  DEFAULT ('') FOR [RoleName_CN]
GO
ALTER TABLE [dbo].[Role] ADD  CONSTRAINT [DF_Role_RoleName_EN]  DEFAULT ('') FOR [RoleName_EN]
GO
ALTER TABLE [dbo].[Role] ADD  CONSTRAINT [DF_Role_RoleName_JP]  DEFAULT ('') FOR [RoleName_JP]
GO
ALTER TABLE [dbo].[Role] ADD  CONSTRAINT [DF_Role_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[Role] ADD  CONSTRAINT [DF_Role_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'角色綁定的處' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Role', @level2type=N'COLUMN',@level2name=N'FK_Unit_Code'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'角色名稱中文' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Role', @level2type=N'COLUMN',@level2name=N'RoleName_TN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'角色名稱簡中' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Role', @level2type=N'COLUMN',@level2name=N'RoleName_CN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'角色名稱英文' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Role', @level2type=N'COLUMN',@level2name=N'RoleName_EN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'角色名稱日文' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Role', @level2type=N'COLUMN',@level2name=N'RoleName_JP'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'修改時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Role', @level2type=N'COLUMN',@level2name=N'Update_date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'修改者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Role', @level2type=N'COLUMN',@level2name=N'Update_user'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'新增時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Role', @level2type=N'COLUMN',@level2name=N'Create_date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'新增使用者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Role', @level2type=N'COLUMN',@level2name=N'Create_user'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[Role_his](
	[log_Id] [int] IDENTITY(1,1) NOT NULL,
	[logType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[PK_Id] [int] NOT NULL,
	[FK_Unit_Code] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[RoleName_TN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[RoleName_CN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[RoleName_EN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[RoleName_JP] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_Role_his] PRIMARY KEY CLUSTERED
(
	[log_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[Role_his] ADD  CONSTRAINT [DF_Role_his_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[Role_his] ADD  CONSTRAINT [DF_Role_his_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[Role_his] ADD  CONSTRAINT [DF_Role_History_Create_user]  DEFAULT ('') FOR [Create_user]
GO
ALTER TABLE [dbo].[Role_his] ADD  CONSTRAINT [DF_Role_his_SysCreateDate]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
ALTER TABLE [dbo].[Role_his] ADD  CONSTRAINT [DF_Role_his_SysCreate_user]  DEFAULT ('') FOR [SysCreateUser]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'紀錄的狀態' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Role_his', @level2type=N'COLUMN',@level2name=N'logType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'角色FK(不會做關聯，只會group起來)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Role_his', @level2type=N'COLUMN',@level2name=N'PK_Id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'角色綁定的處' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Role_his', @level2type=N'COLUMN',@level2name=N'FK_Unit_Code'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'角色名稱' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Role_his', @level2type=N'COLUMN',@level2name=N'RoleName_TN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'異動日期' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Role_his', @level2type=N'COLUMN',@level2name=N'Create_date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'異動者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Role_his', @level2type=N'COLUMN',@level2name=N'Create_user'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[Role_Position_Mapping](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_Role_Id] [int] NOT NULL,
	[FK_Branch_Code] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[FK_Department_Code] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[TitleCode] [int] NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_Title_Permissions_Mapping] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_PADDING ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE NONCLUSTERED INDEX [IX_Role_Position_Mapping] ON [dbo].[Role_Position_Mapping]
(
	[TitleCode] ASC,
	[FK_Branch_Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
';
IF FILEGROUP_ID(N'NCRMS_IDX') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_IDX]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_PADDING ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE NONCLUSTERED INDEX [IX_Role_Position_Mapping_1] ON [dbo].[Role_Position_Mapping]
(
	[TitleCode] ASC,
	[FK_Department_Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
';
IF FILEGROUP_ID(N'NCRMS_IDX') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_IDX]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[Role_Position_Mapping] ADD  CONSTRAINT [DF_Role_Position_Mapping_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[Role_Position_Mapping] ADD  CONSTRAINT [DF_Role_Position_Mapping_Create_user]  DEFAULT ('') FOR [Create_user]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'異動日' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Role_Position_Mapping', @level2type=N'COLUMN',@level2name=N'Create_date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'異動者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Role_Position_Mapping', @level2type=N'COLUMN',@level2name=N'Create_user'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[Role_Position_Mapping_his](
	[log_Id] [int] IDENTITY(1,1) NOT NULL,
	[logType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[log_Role_Id] [int] NULL,
	[PK_Id] [int] NULL,
	[FK_Role_Id] [int] NOT NULL,
	[FK_Branch_Code] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[FK_Department_Code] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[TitleCode] [int] NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_Role_Position_Mapping_his] PRIMARY KEY CLUSTERED
(
	[log_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[Role_Position_Mapping_his] ADD  CONSTRAINT [DF_Role_Position_Mapping_his_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[Role_Position_Mapping_his] ADD  CONSTRAINT [DF_Position_Role_Mapping_his_Create_user]  DEFAULT ('') FOR [Create_user]
GO
ALTER TABLE [dbo].[Role_Position_Mapping_his] ADD  CONSTRAINT [DF_Role_Position_Mapping_his_SysCreateDate]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
ALTER TABLE [dbo].[Role_Position_Mapping_his] ADD  CONSTRAINT [DF_Role_Position_Mapping_his_SysCreate_user]  DEFAULT ('') FOR [SysCreateUser]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'紀錄的狀態' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Role_Position_Mapping_his', @level2type=N'COLUMN',@level2name=N'logType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'對應的角色FK' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Role_Position_Mapping_his', @level2type=N'COLUMN',@level2name=N'FK_Role_Id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'對應的分行Code FK' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Role_Position_Mapping_his', @level2type=N'COLUMN',@level2name=N'FK_Branch_Code'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'對應的部Code FK' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Role_Position_Mapping_his', @level2type=N'COLUMN',@level2name=N'FK_Department_Code'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'對應的職稱代碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Role_Position_Mapping_his', @level2type=N'COLUMN',@level2name=N'TitleCode'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'異動日' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Role_Position_Mapping_his', @level2type=N'COLUMN',@level2name=N'Create_date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'異動者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Role_Position_Mapping_his', @level2type=N'COLUMN',@level2name=N'Create_user'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[Role_User_Mapping](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_Role_Id] [int] NOT NULL,
	[FK_User_Id] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_USER_PERMISSIONS_MAPPING] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_PADDING ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE NONCLUSTERED INDEX [IX_Role_User_Mapping] ON [dbo].[Role_User_Mapping]
(
	[FK_User_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
';
IF FILEGROUP_ID(N'NCRMS_IDX') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_IDX]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE NONCLUSTERED INDEX [IX_Role_User_Mapping_1] ON [dbo].[Role_User_Mapping]
(
	[FK_Role_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
';
IF FILEGROUP_ID(N'NCRMS_IDX') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_IDX]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[Role_User_Mapping] ADD  CONSTRAINT [DF_USER_PERMISSIONS_MAPPING_FK_Role_Id]  DEFAULT ((0)) FOR [FK_Role_Id]
GO
ALTER TABLE [dbo].[Role_User_Mapping] ADD  CONSTRAINT [DF_USER_PERMISSIONS_MAPPING_FK_User_Id]  DEFAULT ((0)) FOR [FK_User_Id]
GO
ALTER TABLE [dbo].[Role_User_Mapping] ADD  CONSTRAINT [DF_Role_User_Mapping_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[Role_User_Mapping] ADD  CONSTRAINT [DF_Role_User_Mapping_Create_user]  DEFAULT ('') FOR [Create_user]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'使用者對訂到的角色' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Role_User_Mapping', @level2type=N'COLUMN',@level2name=N'FK_Role_Id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'對應到的使用者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Role_User_Mapping', @level2type=N'COLUMN',@level2name=N'FK_User_Id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'異動日期' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Role_User_Mapping', @level2type=N'COLUMN',@level2name=N'Create_date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'異動者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Role_User_Mapping', @level2type=N'COLUMN',@level2name=N'Create_user'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[Role_User_Mapping_his](
	[log_Id] [int] IDENTITY(1,1) NOT NULL,
	[logType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[log_Role_Id] [int] NULL,
	[PK_Id] [int] NULL,
	[FK_Role_Id] [int] NOT NULL,
	[FK_User_Id] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_Role_User_Mapping_his] PRIMARY KEY CLUSTERED
(
	[log_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[Role_User_Mapping_his] ADD  CONSTRAINT [DF_User_Role_Mapping_his_FK_Role_Id]  DEFAULT ((0)) FOR [FK_Role_Id]
GO
ALTER TABLE [dbo].[Role_User_Mapping_his] ADD  CONSTRAINT [DF_User_Role_Mapping_his_FK_User_Id]  DEFAULT ('') FOR [FK_User_Id]
GO
ALTER TABLE [dbo].[Role_User_Mapping_his] ADD  CONSTRAINT [DF_Role_User_Mapping_his_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[Role_User_Mapping_his] ADD  CONSTRAINT [DF_User_Role_Mapping_his_Create_user]  DEFAULT ('') FOR [Create_user]
GO
ALTER TABLE [dbo].[Role_User_Mapping_his] ADD  CONSTRAINT [DF_Role_User_Mapping_his_SysCreateDate]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
ALTER TABLE [dbo].[Role_User_Mapping_his] ADD  CONSTRAINT [DF_Role_User_Mapping_his_SysCreate_user]  DEFAULT ('') FOR [SysCreateUser]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'紀錄的狀態' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Role_User_Mapping_his', @level2type=N'COLUMN',@level2name=N'logType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'對應到的角色FK' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Role_User_Mapping_his', @level2type=N'COLUMN',@level2name=N'FK_Role_Id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'對應到的User FK' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Role_User_Mapping_his', @level2type=N'COLUMN',@level2name=N'FK_User_Id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'異動日期' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Role_User_Mapping_his', @level2type=N'COLUMN',@level2name=N'Create_date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'異動者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Role_User_Mapping_his', @level2type=N'COLUMN',@level2name=N'Create_user'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[RPA](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[Type] [int] NULL,
	[Title] [nvarchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Contents] [nvarchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Url] [nvarchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[IsActive] [bit] NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Release_date] [date] NULL,
 CONSTRAINT [PK_NewsPost] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[RPA] ADD  CONSTRAINT [DF_RPA_Contents]  DEFAULT ('') FOR [Contents]
GO
ALTER TABLE [dbo].[RPA] ADD  CONSTRAINT [DF_RPA_Url]  DEFAULT ('') FOR [Url]
GO
ALTER TABLE [dbo].[RPA] ADD  CONSTRAINT [DF_NewsPost_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[RPA] ADD  CONSTRAINT [DF_NewsPost_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'標題' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RPA', @level2type=N'COLUMN',@level2name=N'Title'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'內容' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RPA', @level2type=N'COLUMN',@level2name=N'Contents'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'超連結' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RPA', @level2type=N'COLUMN',@level2name=N'Url'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'是否已經發布' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RPA', @level2type=N'COLUMN',@level2name=N'IsActive'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[RPA_his](
	[Log_Id] [int] IDENTITY(1,1) NOT NULL,
	[LogType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[FlowFormId] [int] NULL,
	[PK_Id] [int] NULL,
	[Type] [int] NULL,
	[Title] [nvarchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Contents] [nvarchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Url] [nvarchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Release_date] [date] NULL,
	[IsActive] [bit] NULL,
	[Create_date] [datetime] NULL,
	[Create_user] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Update_date] [datetime] NULL,
	[Update_user] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SysCreateDate] [datetime] NULL,
	[SysCreateUser] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
 CONSTRAINT [PK_RPA_his] PRIMARY KEY CLUSTERED
(
	[Log_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[RPA_Source](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[Title] [nvarchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Contents] [nvarchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Url] [nvarchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[IsPost] [bit] NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_RPA_Source] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[RPA_temp](
	[TempId] [int] IDENTITY(1,1) NOT NULL,
	[FlowFormId] [int] NULL,
	[ModifyType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[PK_Id] [int] NOT NULL,
	[FK_NewsPostId] [int] NULL,
	[Type] [int] NOT NULL,
	[Title] [nvarchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Contents] [nvarchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Url] [nvarchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[IsActive] [bit] NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Release_date] [date] NULL,
 CONSTRAINT [PK__NewsPost__06C703C16ED4FA98] PRIMARY KEY CLUSTERED
(
	[TempId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[RPA_temp] ADD  CONSTRAINT [DF_RPA_temp_Url]  DEFAULT ('') FOR [Url]
GO
ALTER TABLE [dbo].[RPA_temp] ADD  CONSTRAINT [DF__NewsPost___Updat__4CD638E3]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[RPA_temp] ADD  CONSTRAINT [DF__NewsPost___Creat__4DCA5D1C]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[RPA_temp] ADD  CONSTRAINT [DF__NewsPost___SysCr__4EBE8155]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'暫存資料識別碼（流水號）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RPA_temp', @level2type=N'COLUMN',@level2name=N'TempId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'流程表單識別碼（外鍵：FlowForm.PK_ID）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RPA_temp', @level2type=N'COLUMN',@level2name=N'FlowFormId'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[RPA_Views](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_RPAId] [int] NOT NULL,
	[Views] [int] NOT NULL,
 CONSTRAINT [PK_RPA_Views] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[RPA_Views] ADD  CONSTRAINT [DF_RPA_Views_Views]  DEFAULT ((0)) FOR [Views]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[RPACountryType](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_RPAId] [int] NOT NULL,
	[FK_CountryId] [int] NOT NULL,
 CONSTRAINT [PK_RPACountryType] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[RPACountryType_his](
	[Log_Id] [int] IDENTITY(1,1) NOT NULL,
	[Fk_LogId] [int] NULL,
	[FK_CountryId] [int] NULL,
	[LogType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[PK_Id] [int] NULL,
	[CountryCode2] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CountryName_TN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CountryName_CN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CountryName_EN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CountryName_JP] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SysCreateDate] [datetime] NULL,
	[SysCreateUser] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
 CONSTRAINT [PK_RPACountryType_his] PRIMARY KEY CLUSTERED
(
	[Log_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[RPACountryType_temp](
	[TempId] [int] IDENTITY(1,1) NOT NULL,
	[FK_TempId] [int] NOT NULL,
	[ModifyType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[PK_Id] [int] NULL,
	[FK_RPAId] [int] NULL,
	[FK_CountryId] [int] NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK__RPACount__06C703C199E83B6C] PRIMARY KEY CLUSTERED
(
	[TempId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[RPACountryType_temp] ADD  CONSTRAINT [DF__RPACountr__SysCr__6B1B9438]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'暫存資料識別碼（流水號）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RPACountryType_temp', @level2type=N'COLUMN',@level2name=N'TempId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'主表暫存資料外鍵' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RPACountryType_temp', @level2type=N'COLUMN',@level2name=N'FK_TempId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'異動類型' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RPACountryType_temp', @level2type=N'COLUMN',@level2name=N'ModifyType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立日期時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RPACountryType_temp', @level2type=N'COLUMN',@level2name=N'SysCreateDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立使用者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RPACountryType_temp', @level2type=N'COLUMN',@level2name=N'SysCreateUser'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[RPAFileMapping](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_RPAId] [int] NOT NULL,
	[FK_FileCenterId] [int] NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_RPAFileMapping] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[RPAFileMapping_his](
	[Log_Id] [int] IDENTITY(1,1) NOT NULL,
	[LogType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Fk_LogId] [int] NULL,
	[PK_Id] [int] NULL,
	[FileId] [int] NULL,
	[FileName] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[File_Extension] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Create_date] [datetime] NULL,
	[Create_user] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SysCreateDate] [datetime] NULL,
	[SysCreateUser] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
 CONSTRAINT [PK_RPAFileMapping_his] PRIMARY KEY CLUSTERED
(
	[Log_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[RPAFileMapping_temp](
	[TempId] [int] IDENTITY(1,1) NOT NULL,
	[FK_TempId] [int] NOT NULL,
	[ModifyType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[PK_Id] [int] NULL,
	[FK_NewsPostId] [int] NULL,
	[FK_FileCenterId] [int] NULL,
	[Create_date] [datetime] NULL,
	[Create_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK__NewsPost__06C703C132452CA1] PRIMARY KEY CLUSTERED
(
	[TempId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[RPAFileMapping_temp] ADD  CONSTRAINT [DF__NewsPostF__Creat__61D155C9]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[RPAFileMapping_temp] ADD  CONSTRAINT [DF__NewsPostF__SysCr__62C57A02]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'暫存資料識別碼（流水號）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RPAFileMapping_temp', @level2type=N'COLUMN',@level2name=N'TempId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'主表暫存資料外鍵' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RPAFileMapping_temp', @level2type=N'COLUMN',@level2name=N'FK_TempId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'異動類型' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RPAFileMapping_temp', @level2type=N'COLUMN',@level2name=N'ModifyType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立日期時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RPAFileMapping_temp', @level2type=N'COLUMN',@level2name=N'SysCreateDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立使用者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RPAFileMapping_temp', @level2type=N'COLUMN',@level2name=N'SysCreateUser'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[ScheduleJobs](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Description] [nvarchar](500) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[CronExpression] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[JobAPI] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[IsActive] [bit] NOT NULL,
	[ISRunning] [bit] NOT NULL,
	[TimeOutMinutes] [int] NOT NULL,
	[LastStartRunTime] [datetime] NULL,
	[LastEndRunTime] [datetime] NULL,
	[NextRunTime] [datetime] NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[LastError] [nvarchar](500) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_ScheduleJobs] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[ScheduleJobs] ADD  CONSTRAINT [DF_ScheduleJobs_Name]  DEFAULT ('') FOR [Name]
GO
ALTER TABLE [dbo].[ScheduleJobs] ADD  CONSTRAINT [DF_ScheduleJobs_Description]  DEFAULT ('') FOR [Description]
GO
ALTER TABLE [dbo].[ScheduleJobs] ADD  CONSTRAINT [DF_ScheduleJobs_CronExpression]  DEFAULT (N'* * * * *') FOR [CronExpression]
GO
ALTER TABLE [dbo].[ScheduleJobs] ADD  CONSTRAINT [DF_ScheduleJobs_JobAPI]  DEFAULT ('') FOR [JobAPI]
GO
ALTER TABLE [dbo].[ScheduleJobs] ADD  CONSTRAINT [DF__ScheduleJ__IsEna__53F837BE]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[ScheduleJobs] ADD  CONSTRAINT [DF_ScheduleJobs_ISRunning]  DEFAULT ((0)) FOR [ISRunning]
GO
ALTER TABLE [dbo].[ScheduleJobs] ADD  CONSTRAINT [DF_ScheduleJobs_TimeOutMinutes]  DEFAULT ((1)) FOR [TimeOutMinutes]
GO
ALTER TABLE [dbo].[ScheduleJobs] ADD  CONSTRAINT [DF_ScheduleJobs_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[ScheduleJobs] ADD  CONSTRAINT [DF_ScheduleJobs_Update_user]  DEFAULT ('system') FOR [Update_user]
GO
ALTER TABLE [dbo].[ScheduleJobs] ADD  CONSTRAINT [DF_ScheduleJobs_Create_Date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[ScheduleJobs] ADD  CONSTRAINT [DF_ScheduleJobs_Create_User]  DEFAULT ('system') FOR [Create_user]
GO
ALTER TABLE [dbo].[ScheduleJobs] ADD  CONSTRAINT [DF_ScheduleJobs_LastError]  DEFAULT ('') FOR [LastError]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'排程名稱' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScheduleJobs', @level2type=N'COLUMN',@level2name=N'Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'描述' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScheduleJobs', @level2type=N'COLUMN',@level2name=N'Description'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Cron時間語言' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScheduleJobs', @level2type=N'COLUMN',@level2name=N'CronExpression'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'排程作業API' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScheduleJobs', @level2type=N'COLUMN',@level2name=N'JobAPI'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'是否啟用' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScheduleJobs', @level2type=N'COLUMN',@level2name=N'IsActive'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'是否執行中' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScheduleJobs', @level2type=N'COLUMN',@level2name=N'ISRunning'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'逾期時間(分鐘)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScheduleJobs', @level2type=N'COLUMN',@level2name=N'TimeOutMinutes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'上次執行開始時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScheduleJobs', @level2type=N'COLUMN',@level2name=N'LastStartRunTime'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'上次執行結束時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScheduleJobs', @level2type=N'COLUMN',@level2name=N'LastEndRunTime'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'下次執行時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScheduleJobs', @level2type=N'COLUMN',@level2name=N'NextRunTime'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'更新時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScheduleJobs', @level2type=N'COLUMN',@level2name=N'Update_date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'更新者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScheduleJobs', @level2type=N'COLUMN',@level2name=N'Update_user'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'創建時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScheduleJobs', @level2type=N'COLUMN',@level2name=N'Create_date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建立者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScheduleJobs', @level2type=N'COLUMN',@level2name=N'Create_user'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'上次執行錯誤內容' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScheduleJobs', @level2type=N'COLUMN',@level2name=N'LastError'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[ScheduleJobs_his](
	[Log_id] [int] IDENTITY(1,1) NOT NULL,
	[LogType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[FlowFormId] [int] NULL,
	[PK_Id] [int] NOT NULL,
	[Name] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Description] [nvarchar](500) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[CronExpression] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[JobAPI] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[IsActive] [bit] NOT NULL,
	[ISRunning] [bit] NOT NULL,
	[TimeOutMinutes] [int] NOT NULL,
	[LastStartRunTime] [datetime] NULL,
	[LastEndRunTime] [datetime] NULL,
	[NextRunTime] [datetime] NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[LastError] [nvarchar](500) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK__Schedule__2D21E3B610EB64F6] PRIMARY KEY CLUSTERED
(
	[Log_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[ScheduleJobs_his] ADD  CONSTRAINT [DF__ScheduleJo__Name__53F837BE]  DEFAULT ('') FOR [Name]
GO
ALTER TABLE [dbo].[ScheduleJobs_his] ADD  CONSTRAINT [DF__ScheduleJ__Descr__54EC5BF7]  DEFAULT ('') FOR [Description]
GO
ALTER TABLE [dbo].[ScheduleJobs_his] ADD  CONSTRAINT [DF__ScheduleJ__CronE__55E08030]  DEFAULT (N'* * * * *') FOR [CronExpression]
GO
ALTER TABLE [dbo].[ScheduleJobs_his] ADD  CONSTRAINT [DF__ScheduleJ__JobAP__56D4A469]  DEFAULT ('') FOR [JobAPI]
GO
ALTER TABLE [dbo].[ScheduleJobs_his] ADD  CONSTRAINT [DF__ScheduleJ__IsAct__57C8C8A2]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[ScheduleJobs_his] ADD  CONSTRAINT [DF__ScheduleJ__ISRun__58BCECDB]  DEFAULT ((0)) FOR [ISRunning]
GO
ALTER TABLE [dbo].[ScheduleJobs_his] ADD  CONSTRAINT [DF__ScheduleJ__TimeO__59B11114]  DEFAULT ((1)) FOR [TimeOutMinutes]
GO
ALTER TABLE [dbo].[ScheduleJobs_his] ADD  CONSTRAINT [DF__ScheduleJ__Updat__5AA5354D]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[ScheduleJobs_his] ADD  CONSTRAINT [DF__ScheduleJ__Updat__5B995986]  DEFAULT ('system') FOR [Update_user]
GO
ALTER TABLE [dbo].[ScheduleJobs_his] ADD  CONSTRAINT [DF__ScheduleJ__Creat__5C8D7DBF]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[ScheduleJobs_his] ADD  CONSTRAINT [DF__ScheduleJ__Creat__5D81A1F8]  DEFAULT ('system') FOR [Create_user]
GO
ALTER TABLE [dbo].[ScheduleJobs_his] ADD  CONSTRAINT [DF__ScheduleJ__LastE__5E75C631]  DEFAULT ('') FOR [LastError]
GO
ALTER TABLE [dbo].[ScheduleJobs_his] ADD  CONSTRAINT [DF__ScheduleJ__SysCr__5F69EA6A]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'歷史記錄識別碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScheduleJobs_his', @level2type=N'COLUMN',@level2name=N'Log_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'異動行為類型 (INSERT/UPDATE/DELETE)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScheduleJobs_his', @level2type=N'COLUMN',@level2name=N'LogType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'流程表單識別碼（外鍵：FlowForm.PK_ID）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScheduleJobs_his', @level2type=N'COLUMN',@level2name=N'FlowFormId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立日期時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScheduleJobs_his', @level2type=N'COLUMN',@level2name=N'SysCreateDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統建立使用者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScheduleJobs_his', @level2type=N'COLUMN',@level2name=N'SysCreateUser'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[ScheduleJobs_RECORD](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_ScheduleJobsID] [int] NOT NULL,
	[Name] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Description] [nvarchar](500) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[JobAPI] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[StartRunTime] [datetime] NULL,
	[EndRunTime] [datetime] NULL,
	[LastError] [nvarchar](500) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_Date] [datetime] NOT NULL,
	[Create_User] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_ScheduleJobs_RECORD] PRIMARY KEY CLUSTERED
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[ScheduleJobs_RECORD] ADD  CONSTRAINT [DF_ScheduleJobs_RECORD_Name]  DEFAULT ('') FOR [Name]
GO
ALTER TABLE [dbo].[ScheduleJobs_RECORD] ADD  CONSTRAINT [DF_ScheduleJobs_RECORD_Description]  DEFAULT ('') FOR [Description]
GO
ALTER TABLE [dbo].[ScheduleJobs_RECORD] ADD  CONSTRAINT [DF_ScheduleJobs_RECORD_JobAPI]  DEFAULT ('') FOR [JobAPI]
GO
ALTER TABLE [dbo].[ScheduleJobs_RECORD] ADD  CONSTRAINT [DF_ScheduleJobs_RECORD_LastError]  DEFAULT ('') FOR [LastError]
GO
ALTER TABLE [dbo].[ScheduleJobs_RECORD] ADD  CONSTRAINT [DF_ScheduleJobs_RECORD_Create_Date]  DEFAULT (getdate()) FOR [Create_Date]
GO
ALTER TABLE [dbo].[ScheduleJobs_RECORD] ADD  CONSTRAINT [DF_ScheduleJobs_RECORD_Create_User]  DEFAULT ('') FOR [Create_User]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'排程名稱' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScheduleJobs_RECORD', @level2type=N'COLUMN',@level2name=N'Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'描述' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScheduleJobs_RECORD', @level2type=N'COLUMN',@level2name=N'Description'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'排程作業API' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScheduleJobs_RECORD', @level2type=N'COLUMN',@level2name=N'JobAPI'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'排程啟動時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScheduleJobs_RECORD', @level2type=N'COLUMN',@level2name=N'StartRunTime'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'排程結束時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScheduleJobs_RECORD', @level2type=N'COLUMN',@level2name=N'EndRunTime'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'上次執行錯誤內容' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScheduleJobs_RECORD', @level2type=N'COLUMN',@level2name=N'LastError'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'創建時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScheduleJobs_RECORD', @level2type=N'COLUMN',@level2name=N'Create_Date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建立者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScheduleJobs_RECORD', @level2type=N'COLUMN',@level2name=N'Create_User'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[ScheduleJobs_temp](
	[TempId] [int] IDENTITY(1,1) NOT NULL,
	[FlowFormId] [int] NULL,
	[ModifyType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[PK_Id] [int] NOT NULL,
	[Name] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Description] [nvarchar](500) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[CronExpression] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[JobAPI] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[IsActive] [bit] NOT NULL,
	[ISRunning] [bit] NOT NULL,
	[TimeOutMinutes] [int] NOT NULL,
	[LastStartRunTime] [datetime] NULL,
	[LastEndRunTime] [datetime] NULL,
	[NextRunTime] [datetime] NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[LastError] [nvarchar](500) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK__Schedule__06C703C15BB935D9] PRIMARY KEY CLUSTERED
(
	[TempId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[ScheduleJobs_temp] ADD  CONSTRAINT [DF__ScheduleJo__Name__44B5F42E]  DEFAULT ('') FOR [Name]
GO
ALTER TABLE [dbo].[ScheduleJobs_temp] ADD  CONSTRAINT [DF__ScheduleJ__Descr__45AA1867]  DEFAULT ('') FOR [Description]
GO
ALTER TABLE [dbo].[ScheduleJobs_temp] ADD  CONSTRAINT [DF__ScheduleJ__CronE__469E3CA0]  DEFAULT (N'* * * * *') FOR [CronExpression]
GO
ALTER TABLE [dbo].[ScheduleJobs_temp] ADD  CONSTRAINT [DF__ScheduleJ__JobAP__479260D9]  DEFAULT ('') FOR [JobAPI]
GO
ALTER TABLE [dbo].[ScheduleJobs_temp] ADD  CONSTRAINT [DF__ScheduleJ__IsAct__48868512]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[ScheduleJobs_temp] ADD  CONSTRAINT [DF__ScheduleJ__ISRun__497AA94B]  DEFAULT ((0)) FOR [ISRunning]
GO
ALTER TABLE [dbo].[ScheduleJobs_temp] ADD  CONSTRAINT [DF__ScheduleJ__TimeO__4A6ECD84]  DEFAULT ((1)) FOR [TimeOutMinutes]
GO
ALTER TABLE [dbo].[ScheduleJobs_temp] ADD  CONSTRAINT [DF__ScheduleJ__Updat__4B62F1BD]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[ScheduleJobs_temp] ADD  CONSTRAINT [DF__ScheduleJ__Updat__4C5715F6]  DEFAULT ('system') FOR [Update_user]
GO
ALTER TABLE [dbo].[ScheduleJobs_temp] ADD  CONSTRAINT [DF__ScheduleJ__Creat__4D4B3A2F]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[ScheduleJobs_temp] ADD  CONSTRAINT [DF__ScheduleJ__Creat__4E3F5E68]  DEFAULT ('system') FOR [Create_user]
GO
ALTER TABLE [dbo].[ScheduleJobs_temp] ADD  CONSTRAINT [DF__ScheduleJ__LastE__4F3382A1]  DEFAULT ('') FOR [LastError]
GO
ALTER TABLE [dbo].[ScheduleJobs_temp] ADD  CONSTRAINT [DF__ScheduleJ__SysCr__5027A6DA]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'暫存資料識別碼（流水號）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScheduleJobs_temp', @level2type=N'COLUMN',@level2name=N'TempId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'流程表單識別碼（外鍵：FlowForm.PK_ID）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScheduleJobs_temp', @level2type=N'COLUMN',@level2name=N'FlowFormId'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[SysData](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name_TN] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Name_CN] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Name_EN] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Name_JP] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Version] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Seq] [int] NULL,
	[Url] [varchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[IsActive] [bit] NOT NULL,
	[Icon] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [varchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_user] [varchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
 CONSTRAINT [PK_SysData] PRIMARY KEY CLUSTERED
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[SysData] ADD  CONSTRAINT [DF_SysData_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[SysData] ADD  CONSTRAINT [DF_SysData_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[SysLog](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[System_code] [varchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[EventName] [varchar](1000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[EventSql] [varchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[UserId] [varchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Prog_id] [varchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Function_code] [varchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Api_url] [varchar](500) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Sys_id] [varchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CreateDate] [datetime] NULL,
	[Ip_address] [varchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Status_code] [int] NULL,
 CONSTRAINT [PK_sys_Log] PRIMARY KEY CLUSTERED
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_PADDING OFF
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[TempModifyRecord](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FormId] [int] NOT NULL,
	[TempId] [int] NOT NULL,
	[StepId] [uniqueidentifier] NOT NULL,
	[Field] [nvarchar](255) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[NewValue] [nvarchar](255) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[OldValue] [nvarchar](255) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_TempModifyRecord] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[TempModifyRecord] ADD  CONSTRAINT [DF_TempModifyRecord_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[Title](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[TitleCode] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[TitleName_TN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[TitleName_CN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[TitleName_EN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[TitleName_JP] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[seq] [int] NOT NULL,
 CONSTRAINT [PK_Title] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_PADDING ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE UNIQUE NONCLUSTERED INDEX [IX_Title] ON [dbo].[Title]
(
	[TitleCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
';
IF FILEGROUP_ID(N'NCRMS_IDX') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_IDX]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[Title] ADD  CONSTRAINT [DF_Title_seq]  DEFAULT ((1)) FOR [seq]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[TitleMapping](
	[TitleCode] [nvarchar](1) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[TitleId] [int] NULL,
	[TitleName] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[Users](
	[UserId] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[UserName] [nvarchar](255) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Email] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[GroupCode] [nvarchar](5) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[UnitCode] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[BranchCode] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[DepartmentCode] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[DepartmentName] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Chief] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[TitleCode] [int] NOT NULL,
	[TitleName] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[IsActive] [bit] NOT NULL,
	[IsEmployed] [bit] NOT NULL,
	[Leave_Start] [datetime] NULL,
	[Leave_End] [datetime] NULL,
	[Acting_Person] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Create_date] [datetime] NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_User] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Memo] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_Users] PRIMARY KEY CLUSTERED
(
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_PADDING ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE UNIQUE NONCLUSTERED INDEX [IX_Users] ON [dbo].[Users]
(
	[UserId] ASC,
	[UserName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
';
IF FILEGROUP_ID(N'NCRMS_IDX') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_IDX]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[Users] ADD  CONSTRAINT [DF_Users_IsActive]  DEFAULT ((0)) FOR [IsActive]
GO
ALTER TABLE [dbo].[Users] ADD  CONSTRAINT [DF_Users_IsEmployed]  DEFAULT ((1)) FOR [IsEmployed]
GO
ALTER TABLE [dbo].[Users] ADD  CONSTRAINT [DF_Users_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[Users] ADD  CONSTRAINT [DF_Users_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[Users] ADD  CONSTRAINT [DF_Users_Update_User]  DEFAULT ('system') FOR [Update_User]
GO
ALTER TABLE [dbo].[Users] ADD  CONSTRAINT [DF_Users_Memo]  DEFAULT ('') FOR [Memo]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'員工編號' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Users', @level2type=N'COLUMN',@level2name=N'UserId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'員工姓名' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Users', @level2type=N'COLUMN',@level2name=N'UserName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Mail' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Users', @level2type=N'COLUMN',@level2name=N'Email'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'事業群代碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Users', @level2type=N'COLUMN',@level2name=N'GroupCode'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'處或分行代碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Users', @level2type=N'COLUMN',@level2name=N'UnitCode'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'分行代碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Users', @level2type=N'COLUMN',@level2name=N'BranchCode'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'部門代號' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Users', @level2type=N'COLUMN',@level2name=N'DepartmentCode'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'部門名稱' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Users', @level2type=N'COLUMN',@level2name=N'DepartmentName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'直接主管代號' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Users', @level2type=N'COLUMN',@level2name=N'Chief'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'職稱代號' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Users', @level2type=N'COLUMN',@level2name=N'TitleCode'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'職稱名稱' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Users', @level2type=N'COLUMN',@level2name=N'TitleName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'是否啟用(HRIS沒資料=0)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Users', @level2type=N'COLUMN',@level2name=N'IsActive'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'是否在職' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Users', @level2type=N'COLUMN',@level2name=N'IsEmployed'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'請假起始時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Users', @level2type=N'COLUMN',@level2name=N'Leave_Start'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'請假結束時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Users', @level2type=N'COLUMN',@level2name=N'Leave_End'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'代理人' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Users', @level2type=N'COLUMN',@level2name=N'Acting_Person'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建立日期' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Users', @level2type=N'COLUMN',@level2name=N'Create_date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'更新時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Users', @level2type=N'COLUMN',@level2name=N'Update_date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'更新者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Users', @level2type=N'COLUMN',@level2name=N'Update_User'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'備註' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Users', @level2type=N'COLUMN',@level2name=N'Memo'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[Users_log](
	[logType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[UserId] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[UserName] [nvarchar](255) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Email] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[GroupCode] [nvarchar](5) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[UnitCode] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[BranchCode] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[DepartmentCode] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[DepartmentName] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Chief] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[TitleCode] [int] NULL,
	[TitleName] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[IsActive] [bit] NULL,
	[IsEmployed] [bit] NULL,
	[Leave_Start] [datetime] NULL,
	[Leave_End] [datetime] NULL,
	[Acting_Person] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Create_date] [datetime] NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_User] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Memo] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SysCreateDate] [datetime] NOT NULL
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[Users_log] ADD  CONSTRAINT [DF_Users_his_IsActive]  DEFAULT ((0)) FOR [IsActive]
GO
ALTER TABLE [dbo].[Users_log] ADD  CONSTRAINT [DF_Users_his_IsEmployed]  DEFAULT ((1)) FOR [IsEmployed]
GO
ALTER TABLE [dbo].[Users_log] ADD  CONSTRAINT [DF_Users_his_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[Users_log] ADD  CONSTRAINT [DF_Users_his_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[Users_log] ADD  CONSTRAINT [DF_Users_his_Update_User]  DEFAULT ('system') FOR [Update_User]
GO
ALTER TABLE [dbo].[Users_log] ADD  CONSTRAINT [DF_Users_his_Memo]  DEFAULT ('') FOR [Memo]
GO
ALTER TABLE [dbo].[Users_log] ADD  CONSTRAINT [DF_Users_his_SysCreateDate]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'紀錄的狀態' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Users_log', @level2type=N'COLUMN',@level2name=N'logType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'員工編號' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Users_log', @level2type=N'COLUMN',@level2name=N'UserId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'員工姓名' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Users_log', @level2type=N'COLUMN',@level2name=N'UserName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Mail' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Users_log', @level2type=N'COLUMN',@level2name=N'Email'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'事業群代碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Users_log', @level2type=N'COLUMN',@level2name=N'GroupCode'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'處或分行代碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Users_log', @level2type=N'COLUMN',@level2name=N'UnitCode'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'分行代碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Users_log', @level2type=N'COLUMN',@level2name=N'BranchCode'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'部門代號' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Users_log', @level2type=N'COLUMN',@level2name=N'DepartmentCode'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'部門名稱' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Users_log', @level2type=N'COLUMN',@level2name=N'DepartmentName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'直接主管代號' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Users_log', @level2type=N'COLUMN',@level2name=N'Chief'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'職稱代號' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Users_log', @level2type=N'COLUMN',@level2name=N'TitleCode'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'職稱名稱' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Users_log', @level2type=N'COLUMN',@level2name=N'TitleName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'是否啟用(HRIS沒資料=0)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Users_log', @level2type=N'COLUMN',@level2name=N'IsActive'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'是否在職' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Users_log', @level2type=N'COLUMN',@level2name=N'IsEmployed'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'請假起始時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Users_log', @level2type=N'COLUMN',@level2name=N'Leave_Start'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'請假結束時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Users_log', @level2type=N'COLUMN',@level2name=N'Leave_End'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'代理人' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Users_log', @level2type=N'COLUMN',@level2name=N'Acting_Person'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建立日期' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Users_log', @level2type=N'COLUMN',@level2name=N'Create_date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'更新時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Users_log', @level2type=N'COLUMN',@level2name=N'Update_date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'更新者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Users_log', @level2type=N'COLUMN',@level2name=N'Update_User'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'備註' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Users_log', @level2type=N'COLUMN',@level2name=N'Memo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'紀錄時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Users_log', @level2type=N'COLUMN',@level2name=N'SysCreateDate'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[UserTextLibrary](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Text] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_TextLibrary] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_PADDING ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE NONCLUSTERED INDEX [IX_UserTextLibrary] ON [dbo].[UserTextLibrary]
(
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
';
IF FILEGROUP_ID(N'NCRMS_IDX') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_IDX]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[UserToken](
	[PK_ID] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Token] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Expires_date] [datetime] NOT NULL,
	[IPAddress] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[UserAgent] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[ConnectionId] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
 CONSTRAINT [PK_UserToken] PRIMARY KEY CLUSTERED
(
	[PK_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_PADDING ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE UNIQUE NONCLUSTERED INDEX [IX_UserToken] ON [dbo].[UserToken]
(
	[Token] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
';
IF FILEGROUP_ID(N'NCRMS_IDX') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_IDX]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[UserToken] ADD  CONSTRAINT [DF_UserToken_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[UserToken] ADD  CONSTRAINT [DF_UserToken_IPAddress]  DEFAULT ('') FOR [IPAddress]
GO
ALTER TABLE [dbo].[UserToken] ADD  CONSTRAINT [DF_UserToken_UserAgent]  DEFAULT ('') FOR [UserAgent]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'使用者ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserToken', @level2type=N'COLUMN',@level2name=N'UserId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'登入Token' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserToken', @level2type=N'COLUMN',@level2name=N'Token'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建立日期' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserToken', @level2type=N'COLUMN',@level2name=N'Create_date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'有效期限' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserToken', @level2type=N'COLUMN',@level2name=N'Expires_date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'登入的IP' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserToken', @level2type=N'COLUMN',@level2name=N'IPAddress'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'使用裝置' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserToken', @level2type=N'COLUMN',@level2name=N'UserAgent'
GO
ALTER TABLE [dbo].[BankBranch_his]  WITH CHECK ADD  CONSTRAINT [FK_BankBranch_his_FlowForm] FOREIGN KEY([FlowFormId])
REFERENCES [dbo].[FlowForm] ([PK_Id])
GO
ALTER TABLE [dbo].[BankBranch_his] CHECK CONSTRAINT [FK_BankBranch_his_FlowForm]
GO
ALTER TABLE [dbo].[BankBranch_temp]  WITH CHECK ADD  CONSTRAINT [FK_BankBranch_temp_FlowForm] FOREIGN KEY([FlowFormId])
REFERENCES [dbo].[FlowForm] ([PK_Id])
GO
ALTER TABLE [dbo].[BankBranch_temp] CHECK CONSTRAINT [FK_BankBranch_temp_FlowForm]
GO
ALTER TABLE [dbo].[BankYearNeWorthBase_his]  WITH CHECK ADD  CONSTRAINT [FK_BankYearNeWorthBase_his_FlowForm] FOREIGN KEY([FlowFormId])
REFERENCES [dbo].[FlowForm] ([PK_Id])
GO
ALTER TABLE [dbo].[BankYearNeWorthBase_his] CHECK CONSTRAINT [FK_BankYearNeWorthBase_his_FlowForm]
GO
ALTER TABLE [dbo].[BankYearNeWorthBase_temp]  WITH CHECK ADD  CONSTRAINT [FK_BankYearNeWorthBase_temp_FlowForm] FOREIGN KEY([FlowFormId])
REFERENCES [dbo].[FlowForm] ([PK_Id])
GO
ALTER TABLE [dbo].[BankYearNeWorthBase_temp] CHECK CONSTRAINT [FK_BankYearNeWorthBase_temp_FlowForm]
GO
ALTER TABLE [dbo].[ContinentCountry]  WITH CHECK ADD  CONSTRAINT [FK_ContinentCountry_ContinentMaster] FOREIGN KEY([ContinentId])
REFERENCES [dbo].[ContinentMaster] ([PK_Id])
GO
ALTER TABLE [dbo].[ContinentCountry] CHECK CONSTRAINT [FK_ContinentCountry_ContinentMaster]
GO
ALTER TABLE [dbo].[ContinentCountry]  WITH CHECK ADD  CONSTRAINT [FK_ContinentCountry_CountryMaster] FOREIGN KEY([CountryId])
REFERENCES [dbo].[CountryMaster] ([PK_Id])
GO
ALTER TABLE [dbo].[ContinentCountry] CHECK CONSTRAINT [FK_ContinentCountry_CountryMaster]
GO
ALTER TABLE [dbo].[ContinentCountry_temp]  WITH CHECK ADD  CONSTRAINT [FK_ContinentCountry_temp_ContinentMaster_temp] FOREIGN KEY([FK_TempId])
REFERENCES [dbo].[ContinentMaster_temp] ([TempId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ContinentCountry_temp] CHECK CONSTRAINT [FK_ContinentCountry_temp_ContinentMaster_temp]
GO
ALTER TABLE [dbo].[ContinentMaster_his]  WITH CHECK ADD  CONSTRAINT [FK_ContinentMaster_his_FlowForm] FOREIGN KEY([FlowFormId])
REFERENCES [dbo].[FlowForm] ([PK_Id])
GO
ALTER TABLE [dbo].[ContinentMaster_his] CHECK CONSTRAINT [FK_ContinentMaster_his_FlowForm]
GO
ALTER TABLE [dbo].[ContinentMaster_temp]  WITH CHECK ADD  CONSTRAINT [FK_ContinentMaster_temp_FlowForm] FOREIGN KEY([FlowFormId])
REFERENCES [dbo].[FlowForm] ([PK_Id])
GO
ALTER TABLE [dbo].[ContinentMaster_temp] CHECK CONSTRAINT [FK_ContinentMaster_temp_FlowForm]
GO
ALTER TABLE [dbo].[CountryException_temp]  WITH CHECK ADD  CONSTRAINT [FK_CountryException_temp_FlowForm] FOREIGN KEY([FlowFormId])
REFERENCES [dbo].[FlowForm] ([PK_Id])
GO
ALTER TABLE [dbo].[CountryException_temp] CHECK CONSTRAINT [FK_CountryException_temp_FlowForm]
GO
ALTER TABLE [dbo].[CountryExceptionBankGroup]  WITH CHECK ADD  CONSTRAINT [FK_CountryExceptionBankGroup_CountryException] FOREIGN KEY([FK_CountryExceptionId])
REFERENCES [dbo].[CountryException] ([PK_Id])
GO
ALTER TABLE [dbo].[CountryExceptionBankGroup] CHECK CONSTRAINT [FK_CountryExceptionBankGroup_CountryException]
GO
ALTER TABLE [dbo].[CountryExceptionBankGroup_temp]  WITH CHECK ADD  CONSTRAINT [FK_CountryExceptionBankGroup_temp_CountryException_temp] FOREIGN KEY([FK_TempId])
REFERENCES [dbo].[CountryException_temp] ([TempId])
GO
ALTER TABLE [dbo].[CountryExceptionBankGroup_temp] CHECK CONSTRAINT [FK_CountryExceptionBankGroup_temp_CountryException_temp]
GO
ALTER TABLE [dbo].[CountryFocus_temp]  WITH CHECK ADD  CONSTRAINT [FK_CountryFocus_temp_FlowForm] FOREIGN KEY([FlowFormId])
REFERENCES [dbo].[FlowForm] ([PK_Id])
GO
ALTER TABLE [dbo].[CountryFocus_temp] CHECK CONSTRAINT [FK_CountryFocus_temp_FlowForm]
GO
ALTER TABLE [dbo].[CountryMaster]  WITH CHECK ADD  CONSTRAINT [FK_CountryMaster_ContinentMaster] FOREIGN KEY([FK_Continent])
REFERENCES [dbo].[ContinentMaster] ([PK_Id])
GO
ALTER TABLE [dbo].[CountryMaster] CHECK CONSTRAINT [FK_CountryMaster_ContinentMaster]
GO
ALTER TABLE [dbo].[CountryMaster_temp]  WITH CHECK ADD  CONSTRAINT [FK_CountryMaster_temp_FlowForm] FOREIGN KEY([FlowFormId])
REFERENCES [dbo].[FlowForm] ([PK_Id])
GO
ALTER TABLE [dbo].[CountryMaster_temp] CHECK CONSTRAINT [FK_CountryMaster_temp_FlowForm]
GO
ALTER TABLE [dbo].[CountryOutlookReport_his]  WITH CHECK ADD  CONSTRAINT [FK_CountryOutlookReport_his_FlowForm] FOREIGN KEY([FlowFormId])
REFERENCES [dbo].[FlowForm] ([PK_Id])
GO
ALTER TABLE [dbo].[CountryOutlookReport_his] CHECK CONSTRAINT [FK_CountryOutlookReport_his_FlowForm]
GO
ALTER TABLE [dbo].[CountryOutlookReport_temp]  WITH CHECK ADD  CONSTRAINT [FK_CountryOutlookReport_temp_FlowForm] FOREIGN KEY([FlowFormId])
REFERENCES [dbo].[FlowForm] ([PK_Id])
GO
ALTER TABLE [dbo].[CountryOutlookReport_temp] CHECK CONSTRAINT [FK_CountryOutlookReport_temp_FlowForm]
GO
ALTER TABLE [dbo].[CountryOutlookReport_Views]  WITH CHECK ADD  CONSTRAINT [FK_CountryOutlookReport_Views_CountryOutlookReport] FOREIGN KEY([FK_ReportId])
REFERENCES [dbo].[CountryOutlookReport] ([PK_Id])
GO
ALTER TABLE [dbo].[CountryOutlookReport_Views] CHECK CONSTRAINT [FK_CountryOutlookReport_Views_CountryOutlookReport]
GO
ALTER TABLE [dbo].[CountryWeightPercent]  WITH CHECK ADD  CONSTRAINT [FK_CountryWeightPercent_ContinentMaster] FOREIGN KEY([CountryId])
REFERENCES [dbo].[CountryMaster] ([PK_Id])
GO
ALTER TABLE [dbo].[CountryWeightPercent] CHECK CONSTRAINT [FK_CountryWeightPercent_ContinentMaster]
GO
ALTER TABLE [dbo].[CreditRating_CountApi]  WITH CHECK ADD  CONSTRAINT [FK_CreditRating_CountApi_Global] FOREIGN KEY([CreditRatingType])
REFERENCES [dbo].[Global] ([Id])
GO
ALTER TABLE [dbo].[CreditRating_CountApi] CHECK CONSTRAINT [FK_CreditRating_CountApi_Global]
GO
ALTER TABLE [dbo].[CreditRating_CountApi]  WITH CHECK ADD  CONSTRAINT [FK_CreditRating_CountApi_RatingAgency] FOREIGN KEY([FK_RatingAgency_Id])
REFERENCES [dbo].[CreditRatingMaster] ([PK_ID])
GO
ALTER TABLE [dbo].[CreditRating_CountApi] CHECK CONSTRAINT [FK_CreditRating_CountApi_RatingAgency]
GO
ALTER TABLE [dbo].[CreditRating_Country_Current]  WITH CHECK ADD  CONSTRAINT [FK_CreditRating_Country_Current_CountryMaster] FOREIGN KEY([FK_Country_Id])
REFERENCES [dbo].[CountryMaster] ([PK_Id])
GO
ALTER TABLE [dbo].[CreditRating_Country_Current] CHECK CONSTRAINT [FK_CreditRating_Country_Current_CountryMaster]
GO
ALTER TABLE [dbo].[CreditRating_Country_Current]  WITH CHECK ADD  CONSTRAINT [FK_CreditRating_Country_Current_CreditRatingMaster] FOREIGN KEY([FK_RatingAgency_Id])
REFERENCES [dbo].[CreditRatingMaster] ([PK_ID])
GO
ALTER TABLE [dbo].[CreditRating_Country_Current] CHECK CONSTRAINT [FK_CreditRating_Country_Current_CreditRatingMaster]
GO
ALTER TABLE [dbo].[CreditRating_Country_Log]  WITH CHECK ADD  CONSTRAINT [FK_CreditRating_Country_Log_CountryMaster] FOREIGN KEY([FK_CountryId])
REFERENCES [dbo].[CountryMaster] ([PK_Id])
GO
ALTER TABLE [dbo].[CreditRating_Country_Log] CHECK CONSTRAINT [FK_CreditRating_Country_Log_CountryMaster]
GO
ALTER TABLE [dbo].[CreditRating_Country_Log_Detail]  WITH CHECK ADD  CONSTRAINT [FK_CreditRating_Country_Log_Detail_CountryMaster] FOREIGN KEY([FK_Country_Id])
REFERENCES [dbo].[CountryMaster] ([PK_Id])
GO
ALTER TABLE [dbo].[CreditRating_Country_Log_Detail] CHECK CONSTRAINT [FK_CreditRating_Country_Log_Detail_CountryMaster]
GO
ALTER TABLE [dbo].[CreditRating_Country_Log_Detail]  WITH CHECK ADD  CONSTRAINT [FK_CreditRating_Country_Log_Detail_CreditRatingMaster] FOREIGN KEY([FK_RatingAgency_Id])
REFERENCES [dbo].[CreditRatingMaster] ([PK_ID])
GO
ALTER TABLE [dbo].[CreditRating_Country_Log_Detail] CHECK CONSTRAINT [FK_CreditRating_Country_Log_Detail_CreditRatingMaster]
GO
ALTER TABLE [dbo].[CreditRating_ErrorCountry]  WITH CHECK ADD  CONSTRAINT [FK_CreditRating_ErrorCountry_Country] FOREIGN KEY([FK_CountryId])
REFERENCES [dbo].[CountryMaster] ([PK_Id])
GO
ALTER TABLE [dbo].[CreditRating_ErrorCountry] CHECK CONSTRAINT [FK_CreditRating_ErrorCountry_Country]
GO
ALTER TABLE [dbo].[CreditRating_ErrorCountry]  WITH CHECK ADD  CONSTRAINT [FK_CreditRating_ErrorCountry_Global] FOREIGN KEY([Type])
REFERENCES [dbo].[Global] ([Id])
GO
ALTER TABLE [dbo].[CreditRating_ErrorCountry] CHECK CONSTRAINT [FK_CreditRating_ErrorCountry_Global]
GO
ALTER TABLE [dbo].[CreditRating_ErrorCountry]  WITH CHECK ADD  CONSTRAINT [FK_CreditRating_ErrorCountry_RatingAgency] FOREIGN KEY([FK_RatingAgency_Id])
REFERENCES [dbo].[CreditRatingMaster] ([PK_ID])
GO
ALTER TABLE [dbo].[CreditRating_ErrorCountry] CHECK CONSTRAINT [FK_CreditRating_ErrorCountry_RatingAgency]
GO
ALTER TABLE [dbo].[CreditRating_ErrorISIN]  WITH CHECK ADD  CONSTRAINT [FK_CreditRating_ErrorISIN_Global] FOREIGN KEY([Type])
REFERENCES [dbo].[Global] ([Id])
GO
ALTER TABLE [dbo].[CreditRating_ErrorISIN] CHECK CONSTRAINT [FK_CreditRating_ErrorISIN_Global]
GO
ALTER TABLE [dbo].[CreditRating_ErrorISIN]  WITH CHECK ADD  CONSTRAINT [FK_CreditRating_ErrorISIN_RatingAgency] FOREIGN KEY([FK_RatingAgency_Id])
REFERENCES [dbo].[CreditRatingMaster] ([PK_ID])
GO
ALTER TABLE [dbo].[CreditRating_ErrorISIN] CHECK CONSTRAINT [FK_CreditRating_ErrorISIN_RatingAgency]
GO
ALTER TABLE [dbo].[CreditRating_ErrorLEI]  WITH CHECK ADD  CONSTRAINT [FK_CreditRating_ErrorLEI_Global] FOREIGN KEY([Type])
REFERENCES [dbo].[Global] ([Id])
GO
ALTER TABLE [dbo].[CreditRating_ErrorLEI] CHECK CONSTRAINT [FK_CreditRating_ErrorLEI_Global]
GO
ALTER TABLE [dbo].[CreditRating_ErrorLEI]  WITH CHECK ADD  CONSTRAINT [FK_CreditRating_ErrorLEI_RatingAgency] FOREIGN KEY([FK_RatingAgency_Id])
REFERENCES [dbo].[CreditRatingMaster] ([PK_ID])
GO
ALTER TABLE [dbo].[CreditRating_ErrorLEI] CHECK CONSTRAINT [FK_CreditRating_ErrorLEI_RatingAgency]
GO
ALTER TABLE [dbo].[CreditRating_ScoreMapping_his]  WITH CHECK ADD  CONSTRAINT [FK_CreditRating_ScoreMapping_his_FlowForm] FOREIGN KEY([FlowFormId])
REFERENCES [dbo].[FlowForm] ([PK_Id])
GO
ALTER TABLE [dbo].[CreditRating_ScoreMapping_his] CHECK CONSTRAINT [FK_CreditRating_ScoreMapping_his_FlowForm]
GO
ALTER TABLE [dbo].[Customer_his]  WITH CHECK ADD  CONSTRAINT [FK_Customer_his_FlowForm] FOREIGN KEY([FlowFormId])
REFERENCES [dbo].[FlowForm] ([PK_Id])
GO
ALTER TABLE [dbo].[Customer_his] CHECK CONSTRAINT [FK_Customer_his_FlowForm]
GO
ALTER TABLE [dbo].[Customer_temp]  WITH CHECK ADD  CONSTRAINT [FK_Customer_temp_FlowForm] FOREIGN KEY([FlowFormId])
REFERENCES [dbo].[FlowForm] ([PK_Id])
GO
ALTER TABLE [dbo].[Customer_temp] CHECK CONSTRAINT [FK_Customer_temp_FlowForm]
GO
ALTER TABLE [dbo].[FeatureDetail]  WITH CHECK ADD  CONSTRAINT [FK_FeatureDetail_Menu] FOREIGN KEY([MenuId])
REFERENCES [dbo].[Menu] ([PK_Id])
GO
ALTER TABLE [dbo].[FeatureDetail] CHECK CONSTRAINT [FK_FeatureDetail_Menu]
GO
ALTER TABLE [dbo].[FileCenter_Downloads]  WITH CHECK ADD  CONSTRAINT [FK_FileCenter_Downloads_FileCenter] FOREIGN KEY([FK_FileId])
REFERENCES [dbo].[FileCenter] ([PK_Id])
GO
ALTER TABLE [dbo].[FileCenter_Downloads] CHECK CONSTRAINT [FK_FileCenter_Downloads_FileCenter]
GO
ALTER TABLE [dbo].[FinancialProductMaster_his]  WITH CHECK ADD  CONSTRAINT [FK_FinancialProductMaster_his_FlowForm] FOREIGN KEY([FlowFormId])
REFERENCES [dbo].[FlowForm] ([PK_Id])
GO
ALTER TABLE [dbo].[FinancialProductMaster_his] CHECK CONSTRAINT [FK_FinancialProductMaster_his_FlowForm]
GO
ALTER TABLE [dbo].[FinancialProductMaster_temp]  WITH CHECK ADD  CONSTRAINT [FK_FinancialProductMaster_temp_FlowForm] FOREIGN KEY([FlowFormId])
REFERENCES [dbo].[FlowForm] ([PK_Id])
GO
ALTER TABLE [dbo].[FinancialProductMaster_temp] CHECK CONSTRAINT [FK_FinancialProductMaster_temp_FlowForm]
GO
ALTER TABLE [dbo].[FinancialRiskFactorData]  WITH CHECK ADD  CONSTRAINT [FK_FinancialRiskFactorData_PeriodID_FinancialRiskFactorPeriodDay_PKID] FOREIGN KEY([FK_PeriodID])
REFERENCES [dbo].[FinancialRiskFactorPeriodDay] ([PK_ID])
GO
ALTER TABLE [dbo].[FinancialRiskFactorData] CHECK CONSTRAINT [FK_FinancialRiskFactorData_PeriodID_FinancialRiskFactorPeriodDay_PKID]
GO
ALTER TABLE [dbo].[FinancialRiskFactorData]  WITH CHECK ADD  CONSTRAINT [FK_FinancialRiskFactorData_ProductID_FinancialProductMaster_PKID] FOREIGN KEY([FK_ProductID])
REFERENCES [dbo].[FinancialProductMaster] ([PK_ID])
GO
ALTER TABLE [dbo].[FinancialRiskFactorData] CHECK CONSTRAINT [FK_FinancialRiskFactorData_ProductID_FinancialProductMaster_PKID]
GO
ALTER TABLE [dbo].[Flow]  WITH CHECK ADD  CONSTRAINT [FK_Flow_Menu] FOREIGN KEY([FK_Menu_ID])
REFERENCES [dbo].[Menu] ([PK_Id])
GO
ALTER TABLE [dbo].[Flow] CHECK CONSTRAINT [FK_Flow_Menu]
GO
ALTER TABLE [dbo].[FlowDetail]  WITH CHECK ADD  CONSTRAINT [FK_FlowDetail_Flow] FOREIGN KEY([FK_Flow_Id])
REFERENCES [dbo].[Flow] ([PK_Id])
GO
ALTER TABLE [dbo].[FlowDetail] CHECK CONSTRAINT [FK_FlowDetail_Flow]
GO
ALTER TABLE [dbo].[FlowFileMapping]  WITH CHECK ADD  CONSTRAINT [FK_FlowFileMapping_FileCenter] FOREIGN KEY([FileCenterId])
REFERENCES [dbo].[FileCenter] ([PK_Id])
GO
ALTER TABLE [dbo].[FlowFileMapping] CHECK CONSTRAINT [FK_FlowFileMapping_FileCenter]
GO
ALTER TABLE [dbo].[FlowFileMapping]  WITH CHECK ADD  CONSTRAINT [FK_FlowFileMapping_FlowRecord] FOREIGN KEY([FlowRecordId])
REFERENCES [dbo].[FlowRecord] ([PK_id])
GO
ALTER TABLE [dbo].[FlowFileMapping] CHECK CONSTRAINT [FK_FlowFileMapping_FlowRecord]
GO
ALTER TABLE [dbo].[FlowForm]  WITH CHECK ADD  CONSTRAINT [FK_FlowForm_Flow] FOREIGN KEY([FlowId])
REFERENCES [dbo].[Flow] ([PK_Id])
GO
ALTER TABLE [dbo].[FlowForm] CHECK CONSTRAINT [FK_FlowForm_Flow]
GO
ALTER TABLE [dbo].[FlowModifyRecord]  WITH CHECK ADD  CONSTRAINT [FK_FlowModifyRecord_FlowDetail] FOREIGN KEY([StepId])
REFERENCES [dbo].[FlowDetail] ([PK_Id])
GO
ALTER TABLE [dbo].[FlowModifyRecord] CHECK CONSTRAINT [FK_FlowModifyRecord_FlowDetail]
GO
ALTER TABLE [dbo].[FlowModifyRecord]  WITH CHECK ADD  CONSTRAINT [FK_FlowModifyRecord_FlowForm] FOREIGN KEY([FormId])
REFERENCES [dbo].[FlowForm] ([PK_Id])
GO
ALTER TABLE [dbo].[FlowModifyRecord] CHECK CONSTRAINT [FK_FlowModifyRecord_FlowForm]
GO
ALTER TABLE [dbo].[FlowRecord]  WITH CHECK ADD  CONSTRAINT [FK_FlowRecord_FlowDetail] FOREIGN KEY([FlowDetailId])
REFERENCES [dbo].[FlowDetail] ([PK_Id])
GO
ALTER TABLE [dbo].[FlowRecord] CHECK CONSTRAINT [FK_FlowRecord_FlowDetail]
GO
ALTER TABLE [dbo].[FlowRecord]  WITH CHECK ADD  CONSTRAINT [FK_FlowRecord_FlowForm] FOREIGN KEY([FlowFormId])
REFERENCES [dbo].[FlowForm] ([PK_Id])
GO
ALTER TABLE [dbo].[FlowRecord] CHECK CONSTRAINT [FK_FlowRecord_FlowForm]
GO
ALTER TABLE [dbo].[LoanApprovalEntry]  WITH NOCHECK ADD  CONSTRAINT [FK_LoanApprovalEntry_BranchData] FOREIGN KEY([LoanMainId])
REFERENCES [dbo].[LoanBranchData] ([LoanMainId])
GO
ALTER TABLE [dbo].[LoanApprovalEntry] CHECK CONSTRAINT [FK_LoanApprovalEntry_BranchData]
GO
ALTER TABLE [dbo].[LoanBranchApproveAmountHis]  WITH CHECK ADD  CONSTRAINT [FK_LoanBranchApproveAmountHis_BranchData] FOREIGN KEY([FlowFromId])
REFERENCES [dbo].[LoanBranchData] ([LoanMainId])
GO
ALTER TABLE [dbo].[LoanBranchApproveAmountHis] CHECK CONSTRAINT [FK_LoanBranchApproveAmountHis_BranchData]
GO
ALTER TABLE [dbo].[LoanBranchData]  WITH CHECK ADD  CONSTRAINT [FK_LoanBranchData_LoanMain] FOREIGN KEY([LoanMainId])
REFERENCES [dbo].[FlowForm_LoanMain] ([FlowFormId])
GO
ALTER TABLE [dbo].[LoanBranchData] CHECK CONSTRAINT [FK_LoanBranchData_LoanMain]
GO
ALTER TABLE [dbo].[LoanExtApp]  WITH CHECK ADD  CONSTRAINT [FK_LoanExtApp_LoanMain] FOREIGN KEY([LoanMainId])
REFERENCES [dbo].[LoanBranchData] ([LoanMainId])
GO
ALTER TABLE [dbo].[LoanExtApp] CHECK CONSTRAINT [FK_LoanExtApp_LoanMain]
GO
ALTER TABLE [dbo].[LoanMainUnitData]  WITH CHECK ADD  CONSTRAINT [FK_LoanMainUnitData_LoanMain] FOREIGN KEY([LoanMainId])
REFERENCES [dbo].[FlowForm_LoanMain] ([FlowFormId])
GO
ALTER TABLE [dbo].[LoanMainUnitData] CHECK CONSTRAINT [FK_LoanMainUnitData_LoanMain]
GO
ALTER TABLE [dbo].[Mail_temp]  WITH CHECK ADD  CONSTRAINT [FK_Mail_temp_FlowForm] FOREIGN KEY([FlowFormId])
REFERENCES [dbo].[FlowForm] ([PK_Id])
GO
ALTER TABLE [dbo].[Mail_temp] CHECK CONSTRAINT [FK_Mail_temp_FlowForm]
GO
ALTER TABLE [dbo].[MailCcMapping]  WITH CHECK ADD  CONSTRAINT [FK_MailCcMapping_FKMailId_Mail_Id] FOREIGN KEY([FK_MailId])
REFERENCES [dbo].[Mail] ([PK_Id])
GO
ALTER TABLE [dbo].[MailCcMapping] CHECK CONSTRAINT [FK_MailCcMapping_FKMailId_Mail_Id]
GO
ALTER TABLE [dbo].[MailCcMapping]  WITH CHECK ADD  CONSTRAINT [FK_MailCcMapping_UserId_Users_UserId] FOREIGN KEY([FK_UserId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[MailCcMapping] CHECK CONSTRAINT [FK_MailCcMapping_UserId_Users_UserId]
GO
ALTER TABLE [dbo].[MailCcMapping_temp]  WITH CHECK ADD  CONSTRAINT [FK_MailCcMapping_temp_Mail_temp] FOREIGN KEY([FK_TempId])
REFERENCES [dbo].[Mail_temp] ([TempId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[MailCcMapping_temp] CHECK CONSTRAINT [FK_MailCcMapping_temp_Mail_temp]
GO
ALTER TABLE [dbo].[MailCustomCcMapping]  WITH CHECK ADD  CONSTRAINT [FK_MailCustomCcMapping_FKMailId_Mail_Id] FOREIGN KEY([FK_MailId])
REFERENCES [dbo].[Mail] ([PK_Id])
GO
ALTER TABLE [dbo].[MailCustomCcMapping] CHECK CONSTRAINT [FK_MailCustomCcMapping_FKMailId_Mail_Id]
GO
ALTER TABLE [dbo].[MailCustomCcMapping_temp]  WITH CHECK ADD  CONSTRAINT [FK_MailCustomCcMapping_temp_Mail_temp] FOREIGN KEY([FK_TempId])
REFERENCES [dbo].[Mail_temp] ([TempId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[MailCustomCcMapping_temp] CHECK CONSTRAINT [FK_MailCustomCcMapping_temp_Mail_temp]
GO
ALTER TABLE [dbo].[MailCustomToMapping]  WITH CHECK ADD  CONSTRAINT [FK_MailCustomToMapping_FKMailId_Mail_Id] FOREIGN KEY([FK_MailId])
REFERENCES [dbo].[Mail] ([PK_Id])
GO
ALTER TABLE [dbo].[MailCustomToMapping] CHECK CONSTRAINT [FK_MailCustomToMapping_FKMailId_Mail_Id]
GO
ALTER TABLE [dbo].[MailCustomToMapping_temp]  WITH CHECK ADD  CONSTRAINT [FK_MailCustomToMapping_temp_Mail_temp] FOREIGN KEY([FK_TempId])
REFERENCES [dbo].[Mail_temp] ([TempId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[MailCustomToMapping_temp] CHECK CONSTRAINT [FK_MailCustomToMapping_temp_Mail_temp]
GO
ALTER TABLE [dbo].[MailGroupCcMapping]  WITH CHECK ADD  CONSTRAINT [FK_MailGroupCcMapping_FKMailId_Mail_Id] FOREIGN KEY([MailId])
REFERENCES [dbo].[Mail] ([PK_Id])
GO
ALTER TABLE [dbo].[MailGroupCcMapping] CHECK CONSTRAINT [FK_MailGroupCcMapping_FKMailId_Mail_Id]
GO
ALTER TABLE [dbo].[MailGroupCcMapping]  WITH CHECK ADD  CONSTRAINT [FK_MailGroupCcMapping_MailGroupId_Group_Id] FOREIGN KEY([MailGroupId])
REFERENCES [dbo].[MailGroup] ([PK_Id])
GO
ALTER TABLE [dbo].[MailGroupCcMapping] CHECK CONSTRAINT [FK_MailGroupCcMapping_MailGroupId_Group_Id]
GO
ALTER TABLE [dbo].[MailGroupCcMapping_temp]  WITH CHECK ADD  CONSTRAINT [FK_MailGroupCcMapping_temp_Mail_temp] FOREIGN KEY([FK_TempId])
REFERENCES [dbo].[Mail_temp] ([TempId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[MailGroupCcMapping_temp] CHECK CONSTRAINT [FK_MailGroupCcMapping_temp_Mail_temp]
GO
ALTER TABLE [dbo].[MailGroupMapping]  WITH CHECK ADD  CONSTRAINT [FK_MailGroupMapping_FKMailId_Mail_Id] FOREIGN KEY([MailId])
REFERENCES [dbo].[Mail] ([PK_Id])
GO
ALTER TABLE [dbo].[MailGroupMapping] CHECK CONSTRAINT [FK_MailGroupMapping_FKMailId_Mail_Id]
GO
ALTER TABLE [dbo].[MailGroupMapping]  WITH CHECK ADD  CONSTRAINT [FK_MailGroupMapping_MailGroupId_Group_Id] FOREIGN KEY([MailGroupId])
REFERENCES [dbo].[MailGroup] ([PK_Id])
GO
ALTER TABLE [dbo].[MailGroupMapping] CHECK CONSTRAINT [FK_MailGroupMapping_MailGroupId_Group_Id]
GO
ALTER TABLE [dbo].[MailGroupMapping_temp]  WITH CHECK ADD  CONSTRAINT [FK_MailGroupMapping_temp_Mail_temp] FOREIGN KEY([FK_TempId])
REFERENCES [dbo].[Mail_temp] ([TempId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[MailGroupMapping_temp] CHECK CONSTRAINT [FK_MailGroupMapping_temp_Mail_temp]
GO
ALTER TABLE [dbo].[MailGroupUser]  WITH CHECK ADD  CONSTRAINT [FK_MailGroupUser_MailGroupId_Group_Id] FOREIGN KEY([MailGroup_Id])
REFERENCES [dbo].[MailGroup] ([PK_Id])
GO
ALTER TABLE [dbo].[MailGroupUser] CHECK CONSTRAINT [FK_MailGroupUser_MailGroupId_Group_Id]
GO
ALTER TABLE [dbo].[MailGroupUser]  WITH CHECK ADD  CONSTRAINT [FK_MailGroupUser_UserId_Users_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[MailGroupUser] CHECK CONSTRAINT [FK_MailGroupUser_UserId_Users_UserId]
GO
ALTER TABLE [dbo].[MailLog_CcCustomMapping]  WITH CHECK ADD  CONSTRAINT [FK_MailLog_CcCustomMapping_MailLog] FOREIGN KEY([FK_LogId])
REFERENCES [dbo].[MailLog] ([PK_Id])
GO
ALTER TABLE [dbo].[MailLog_CcCustomMapping] CHECK CONSTRAINT [FK_MailLog_CcCustomMapping_MailLog]
GO
ALTER TABLE [dbo].[MailLog_CcGroupMapping]  WITH CHECK ADD  CONSTRAINT [FK_Mail_CcGroupMapping_MailGroup] FOREIGN KEY([FK_MailGroupId])
REFERENCES [dbo].[MailGroup] ([PK_Id])
GO
ALTER TABLE [dbo].[MailLog_CcGroupMapping] CHECK CONSTRAINT [FK_Mail_CcGroupMapping_MailGroup]
GO
ALTER TABLE [dbo].[MailLog_CcGroupMapping]  WITH CHECK ADD  CONSTRAINT [FK_Mail_CcGroupMapping_MailLog] FOREIGN KEY([FK_LogId])
REFERENCES [dbo].[MailLog] ([PK_Id])
GO
ALTER TABLE [dbo].[MailLog_CcGroupMapping] CHECK CONSTRAINT [FK_Mail_CcGroupMapping_MailLog]
GO
ALTER TABLE [dbo].[MailLog_CcMapping]  WITH CHECK ADD  CONSTRAINT [FK_MailLog_CcMapping_MailLog] FOREIGN KEY([FK_LogId])
REFERENCES [dbo].[MailLog] ([PK_Id])
GO
ALTER TABLE [dbo].[MailLog_CcMapping] CHECK CONSTRAINT [FK_MailLog_CcMapping_MailLog]
GO
ALTER TABLE [dbo].[MailLog_CcMapping]  WITH CHECK ADD  CONSTRAINT [FK_MailLog_CcMapping_Users] FOREIGN KEY([FK_UserId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[MailLog_CcMapping] CHECK CONSTRAINT [FK_MailLog_CcMapping_Users]
GO
ALTER TABLE [dbo].[MailLog_CustomMapping]  WITH CHECK ADD  CONSTRAINT [FK_MailLog_CustomMapping_MailLog] FOREIGN KEY([FK_LogId])
REFERENCES [dbo].[MailLog] ([PK_Id])
GO
ALTER TABLE [dbo].[MailLog_CustomMapping] CHECK CONSTRAINT [FK_MailLog_CustomMapping_MailLog]
GO
ALTER TABLE [dbo].[MailLog_FileMapping]  WITH CHECK ADD  CONSTRAINT [FK_MailLog_FileMapping_MailLog] FOREIGN KEY([FK_LogId])
REFERENCES [dbo].[MailLog] ([PK_Id])
GO
ALTER TABLE [dbo].[MailLog_FileMapping] CHECK CONSTRAINT [FK_MailLog_FileMapping_MailLog]
GO
ALTER TABLE [dbo].[MailLog_GroupMapping]  WITH CHECK ADD  CONSTRAINT [FK_MailLog_GroupMapping_MailLog] FOREIGN KEY([FK_LogId])
REFERENCES [dbo].[MailLog] ([PK_Id])
GO
ALTER TABLE [dbo].[MailLog_GroupMapping] CHECK CONSTRAINT [FK_MailLog_GroupMapping_MailLog]
GO
ALTER TABLE [dbo].[MailLog_Mapping]  WITH CHECK ADD  CONSTRAINT [FK_MailLog_Mapping_MailLog] FOREIGN KEY([FK_LogId])
REFERENCES [dbo].[MailLog] ([PK_Id])
GO
ALTER TABLE [dbo].[MailLog_Mapping] CHECK CONSTRAINT [FK_MailLog_Mapping_MailLog]
GO
ALTER TABLE [dbo].[MailLog_Mapping]  WITH CHECK ADD  CONSTRAINT [FK_MailLog_Mapping_Users] FOREIGN KEY([FK_UserId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[MailLog_Mapping] CHECK CONSTRAINT [FK_MailLog_Mapping_Users]
GO
ALTER TABLE [dbo].[MailToMapping]  WITH CHECK ADD  CONSTRAINT [Fk_MailToMapping_FKMailId_Mail_Id] FOREIGN KEY([FK_MailId])
REFERENCES [dbo].[Mail] ([PK_Id])
GO
ALTER TABLE [dbo].[MailToMapping] CHECK CONSTRAINT [Fk_MailToMapping_FKMailId_Mail_Id]
GO
ALTER TABLE [dbo].[MailToMapping]  WITH CHECK ADD  CONSTRAINT [FK_MailToMapping_UserId_Users_UserId] FOREIGN KEY([FK_UserId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[MailToMapping] CHECK CONSTRAINT [FK_MailToMapping_UserId_Users_UserId]
GO
ALTER TABLE [dbo].[MailToMapping_temp]  WITH CHECK ADD  CONSTRAINT [FK_MailToMapping_temp_Mail_temp] FOREIGN KEY([FK_TempId])
REFERENCES [dbo].[Mail_temp] ([TempId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[MailToMapping_temp] CHECK CONSTRAINT [FK_MailToMapping_temp_Mail_temp]
GO
ALTER TABLE [dbo].[MONITORDATA_his]  WITH CHECK ADD  CONSTRAINT [FK_MONITORDATA_his_FlowForm] FOREIGN KEY([FlowFormId])
REFERENCES [dbo].[FlowForm] ([PK_Id])
GO
ALTER TABLE [dbo].[MONITORDATA_his] CHECK CONSTRAINT [FK_MONITORDATA_his_FlowForm]
GO
ALTER TABLE [dbo].[MONITORDATA_temp]  WITH CHECK ADD  CONSTRAINT [FK_MONITORDATA_temp_FlowForm] FOREIGN KEY([FlowFormId])
REFERENCES [dbo].[FlowForm] ([PK_Id])
GO
ALTER TABLE [dbo].[MONITORDATA_temp] CHECK CONSTRAINT [FK_MONITORDATA_temp_FlowForm]
GO
ALTER TABLE [dbo].[News_his]  WITH CHECK ADD  CONSTRAINT [FK_News_his_FlowForm] FOREIGN KEY([FlowFormId])
REFERENCES [dbo].[FlowForm] ([PK_Id])
GO
ALTER TABLE [dbo].[News_his] CHECK CONSTRAINT [FK_News_his_FlowForm]
GO
ALTER TABLE [dbo].[News_temp]  WITH CHECK ADD  CONSTRAINT [FK_News_temp_FlowForm] FOREIGN KEY([FlowFormId])
REFERENCES [dbo].[FlowForm] ([PK_Id])
GO
ALTER TABLE [dbo].[News_temp] CHECK CONSTRAINT [FK_News_temp_FlowForm]
GO
ALTER TABLE [dbo].[News_Views]  WITH CHECK ADD  CONSTRAINT [FK_News_Views_News] FOREIGN KEY([FK_NewsId])
REFERENCES [dbo].[News] ([PK_Id])
GO
ALTER TABLE [dbo].[News_Views] CHECK CONSTRAINT [FK_News_Views_News]
GO
ALTER TABLE [dbo].[NewsCountryType]  WITH CHECK ADD  CONSTRAINT [FK_NewsCountryType_CountryMaster] FOREIGN KEY([FK_NewsId])
REFERENCES [dbo].[CountryMaster] ([PK_Id])
GO
ALTER TABLE [dbo].[NewsCountryType] CHECK CONSTRAINT [FK_NewsCountryType_CountryMaster]
GO
ALTER TABLE [dbo].[NewsCountryType]  WITH CHECK ADD  CONSTRAINT [FK_NewsCountryType_News] FOREIGN KEY([FK_NewsId])
REFERENCES [dbo].[News] ([PK_Id])
GO
ALTER TABLE [dbo].[NewsCountryType] CHECK CONSTRAINT [FK_NewsCountryType_News]
GO
ALTER TABLE [dbo].[NewsFileMapping]  WITH CHECK ADD  CONSTRAINT [FK_NewsFileMapping_News] FOREIGN KEY([FK_NewsId])
REFERENCES [dbo].[News] ([PK_Id])
GO
ALTER TABLE [dbo].[NewsFileMapping] CHECK CONSTRAINT [FK_NewsFileMapping_News]
GO
ALTER TABLE [dbo].[NoticeUser]  WITH CHECK ADD  CONSTRAINT [FK_NoticeUser_NoticeUser] FOREIGN KEY([NoticeId])
REFERENCES [dbo].[Notice] ([PK_Id])
GO
ALTER TABLE [dbo].[NoticeUser] CHECK CONSTRAINT [FK_NoticeUser_NoticeUser]
GO
ALTER TABLE [dbo].[Permissions]  WITH CHECK ADD  CONSTRAINT [FK_Permissions_FeatureDetail] FOREIGN KEY([FK_Feature_Id])
REFERENCES [dbo].[FeatureDetail] ([PK_Id])
GO
ALTER TABLE [dbo].[Permissions] CHECK CONSTRAINT [FK_Permissions_FeatureDetail]
GO
ALTER TABLE [dbo].[Permissions]  WITH CHECK ADD  CONSTRAINT [FK_Permissions_Role] FOREIGN KEY([FK_Role_Id])
REFERENCES [dbo].[Role] ([PK_Id])
GO
ALTER TABLE [dbo].[Permissions] CHECK CONSTRAINT [FK_Permissions_Role]
GO
ALTER TABLE [dbo].[Permissions_his]  WITH CHECK ADD  CONSTRAINT [FK_Permissions_his_Role_his] FOREIGN KEY([log_Role_Id])
REFERENCES [dbo].[Role_his] ([log_Id])
GO
ALTER TABLE [dbo].[Permissions_his] CHECK CONSTRAINT [FK_Permissions_his_Role_his]
GO
ALTER TABLE [dbo].[Permissions_Query]  WITH CHECK ADD  CONSTRAINT [FK_Permissions_Query_Role] FOREIGN KEY([FK_Role_Id])
REFERENCES [dbo].[Role] ([PK_Id])
GO
ALTER TABLE [dbo].[Permissions_Query] CHECK CONSTRAINT [FK_Permissions_Query_Role]
GO
ALTER TABLE [dbo].[Permissions_Query_his]  WITH CHECK ADD  CONSTRAINT [FK_Permissions_Query_his_Role_his] FOREIGN KEY([log_Role_Id])
REFERENCES [dbo].[Role_his] ([log_Id])
GO
ALTER TABLE [dbo].[Permissions_Query_his] CHECK CONSTRAINT [FK_Permissions_Query_his_Role_his]
GO
ALTER TABLE [dbo].[Post_his]  WITH CHECK ADD  CONSTRAINT [FK_Post_his_FlowForm] FOREIGN KEY([FlowFormId])
REFERENCES [dbo].[FlowForm] ([PK_Id])
GO
ALTER TABLE [dbo].[Post_his] CHECK CONSTRAINT [FK_Post_his_FlowForm]
GO
ALTER TABLE [dbo].[Post_temp]  WITH CHECK ADD  CONSTRAINT [FK_Post_temp_FlowForm] FOREIGN KEY([FlowFormId])
REFERENCES [dbo].[FlowForm] ([PK_Id])
GO
ALTER TABLE [dbo].[Post_temp] CHECK CONSTRAINT [FK_Post_temp_FlowForm]
GO
ALTER TABLE [dbo].[Post_Views]  WITH CHECK ADD  CONSTRAINT [FK_Post_Views_Post] FOREIGN KEY([FK_PostId])
REFERENCES [dbo].[Post] ([PK_Id])
GO
ALTER TABLE [dbo].[Post_Views] CHECK CONSTRAINT [FK_Post_Views_Post]
GO
ALTER TABLE [dbo].[PostCountryType]  WITH CHECK ADD  CONSTRAINT [FK_PostCountryType_CountryMaster] FOREIGN KEY([FK_CountryId])
REFERENCES [dbo].[CountryMaster] ([PK_Id])
GO
ALTER TABLE [dbo].[PostCountryType] CHECK CONSTRAINT [FK_PostCountryType_CountryMaster]
GO
ALTER TABLE [dbo].[PostCountryType]  WITH CHECK ADD  CONSTRAINT [FK_PostCountryType_Post] FOREIGN KEY([FK_PostId])
REFERENCES [dbo].[Post] ([PK_Id])
GO
ALTER TABLE [dbo].[PostCountryType] CHECK CONSTRAINT [FK_PostCountryType_Post]
GO
ALTER TABLE [dbo].[PostFileMapping]  WITH CHECK ADD  CONSTRAINT [FK_PostFileMapping_Post] FOREIGN KEY([FK_PostId])
REFERENCES [dbo].[Post] ([PK_Id])
GO
ALTER TABLE [dbo].[PostFileMapping] CHECK CONSTRAINT [FK_PostFileMapping_Post]
GO
ALTER TABLE [dbo].[QuickLink]  WITH CHECK ADD  CONSTRAINT [FK_QuickLink_QuickLink] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[QuickLink] CHECK CONSTRAINT [FK_QuickLink_QuickLink]
GO
ALTER TABLE [dbo].[QuotaBank_D_Form_AllData]  WITH CHECK ADD  CONSTRAINT [FK_QuotaBank_D_Form_AllData_QuotaBank_M_Form_AllData] FOREIGN KEY([QuotaFormAllData_MId])
REFERENCES [dbo].[QuotaBank_M_Form_AllData] ([PK_Id])
GO
ALTER TABLE [dbo].[QuotaBank_D_Form_AllData] CHECK CONSTRAINT [FK_QuotaBank_D_Form_AllData_QuotaBank_M_Form_AllData]
GO
ALTER TABLE [dbo].[QuotaBank_D_his]  WITH CHECK ADD  CONSTRAINT [FK_QuotaBank_D_his_QuotaBank_M_his] FOREIGN KEY([Fk_logId])
REFERENCES [dbo].[QuotaBank_M_his] ([Log_Id])
GO
ALTER TABLE [dbo].[QuotaBank_D_his] CHECK CONSTRAINT [FK_QuotaBank_D_his_QuotaBank_M_his]
GO
ALTER TABLE [dbo].[QuotaBank_D_temp]  WITH CHECK ADD  CONSTRAINT [FK_QuotaBank_D_temp_QuotaBank_M_temp] FOREIGN KEY([FK_TempId])
REFERENCES [dbo].[QuotaBank_M_temp] ([TempId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[QuotaBank_D_temp] CHECK CONSTRAINT [FK_QuotaBank_D_temp_QuotaBank_M_temp]
GO
ALTER TABLE [dbo].[QuotaBank_Form_Data]  WITH CHECK ADD  CONSTRAINT [FK_QuotaBank_Form_Data_FlowForm] FOREIGN KEY([FlowFormId])
REFERENCES [dbo].[FlowForm] ([PK_Id])
GO
ALTER TABLE [dbo].[QuotaBank_Form_Data] CHECK CONSTRAINT [FK_QuotaBank_Form_Data_FlowForm]
GO
ALTER TABLE [dbo].[QuotaBank_M_Form_AllData]  WITH CHECK ADD  CONSTRAINT [FK_QuotaBank_M_Form_AllData_FlowForm] FOREIGN KEY([FlowFormId])
REFERENCES [dbo].[FlowForm] ([PK_Id])
GO
ALTER TABLE [dbo].[QuotaBank_M_Form_AllData] CHECK CONSTRAINT [FK_QuotaBank_M_Form_AllData_FlowForm]
GO
ALTER TABLE [dbo].[QuotaBank_M_his]  WITH CHECK ADD  CONSTRAINT [FK_QuotaBank_M_his_FlowForm] FOREIGN KEY([FlowFormId])
REFERENCES [dbo].[FlowForm] ([PK_Id])
GO
ALTER TABLE [dbo].[QuotaBank_M_his] CHECK CONSTRAINT [FK_QuotaBank_M_his_FlowForm]
GO
ALTER TABLE [dbo].[QuotaBank_Weight_Form_AllData]  WITH CHECK ADD  CONSTRAINT [FK_QuotaBank_Weight_Form_AllData_QuotaBank_D_Form_AllData] FOREIGN KEY([QuotaD_Form_AllDataId])
REFERENCES [dbo].[QuotaBank_D_Form_AllData] ([Pk_Id])
GO
ALTER TABLE [dbo].[QuotaBank_Weight_Form_AllData] CHECK CONSTRAINT [FK_QuotaBank_Weight_Form_AllData_QuotaBank_D_Form_AllData]
GO
ALTER TABLE [dbo].[QuotaBank_Weight_his]  WITH CHECK ADD  CONSTRAINT [FK_QuotaBank_Weight_his_QuotaBank_D_his] FOREIGN KEY([Fk_logId])
REFERENCES [dbo].[QuotaBank_D_his] ([Log_id])
GO
ALTER TABLE [dbo].[QuotaBank_Weight_his] CHECK CONSTRAINT [FK_QuotaBank_Weight_his_QuotaBank_D_his]
GO
ALTER TABLE [dbo].[QuotaBank_Weight_temp]  WITH CHECK ADD  CONSTRAINT [FK_QuotaBank_Weight_temp_QuotaBank_D_temp] FOREIGN KEY([FK_TempId])
REFERENCES [dbo].[QuotaBank_D_temp] ([TempId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[QuotaBank_Weight_temp] CHECK CONSTRAINT [FK_QuotaBank_Weight_temp_QuotaBank_D_temp]
GO
ALTER TABLE [dbo].[RatingRatioMaster_temp]  WITH CHECK ADD  CONSTRAINT [FK_RatingRatioMaster_temp_BankYearNeWorthBase_temp] FOREIGN KEY([FK_TempId])
REFERENCES [dbo].[BankYearNeWorthBase_temp] ([TempId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[RatingRatioMaster_temp] CHECK CONSTRAINT [FK_RatingRatioMaster_temp_BankYearNeWorthBase_temp]
GO
ALTER TABLE [dbo].[Role_Position_Mapping]  WITH CHECK ADD  CONSTRAINT [FK_Role_Position_Mapping_Role] FOREIGN KEY([FK_Role_Id])
REFERENCES [dbo].[Role] ([PK_Id])
GO
ALTER TABLE [dbo].[Role_Position_Mapping] CHECK CONSTRAINT [FK_Role_Position_Mapping_Role]
GO
ALTER TABLE [dbo].[Role_Position_Mapping_his]  WITH CHECK ADD  CONSTRAINT [FK_Role_Position_Mapping_his_Role_his] FOREIGN KEY([log_Role_Id])
REFERENCES [dbo].[Role_his] ([log_Id])
GO
ALTER TABLE [dbo].[Role_Position_Mapping_his] CHECK CONSTRAINT [FK_Role_Position_Mapping_his_Role_his]
GO
ALTER TABLE [dbo].[Role_User_Mapping]  WITH CHECK ADD  CONSTRAINT [FK_Role_User_Mapping_Role] FOREIGN KEY([FK_Role_Id])
REFERENCES [dbo].[Role] ([PK_Id])
GO
ALTER TABLE [dbo].[Role_User_Mapping] CHECK CONSTRAINT [FK_Role_User_Mapping_Role]
GO
ALTER TABLE [dbo].[Role_User_Mapping]  WITH CHECK ADD  CONSTRAINT [FK_Role_User_Mapping_Users] FOREIGN KEY([FK_User_Id])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[Role_User_Mapping] CHECK CONSTRAINT [FK_Role_User_Mapping_Users]
GO
ALTER TABLE [dbo].[Role_User_Mapping_his]  WITH CHECK ADD  CONSTRAINT [FK_Role_User_Mapping_his_Role_his] FOREIGN KEY([log_Role_Id])
REFERENCES [dbo].[Role_his] ([log_Id])
GO
ALTER TABLE [dbo].[Role_User_Mapping_his] CHECK CONSTRAINT [FK_Role_User_Mapping_his_Role_his]
GO
ALTER TABLE [dbo].[RPA_temp]  WITH CHECK ADD  CONSTRAINT [FK_NewsPost_temp_FlowForm] FOREIGN KEY([FlowFormId])
REFERENCES [dbo].[FlowForm] ([PK_Id])
GO
ALTER TABLE [dbo].[RPA_temp] CHECK CONSTRAINT [FK_NewsPost_temp_FlowForm]
GO
ALTER TABLE [dbo].[RPA_Views]  WITH CHECK ADD  CONSTRAINT [FK_RPA_Views_RPA] FOREIGN KEY([FK_RPAId])
REFERENCES [dbo].[RPA] ([PK_Id])
GO
ALTER TABLE [dbo].[RPA_Views] CHECK CONSTRAINT [FK_RPA_Views_RPA]
GO
ALTER TABLE [dbo].[RPACountryType]  WITH CHECK ADD  CONSTRAINT [FK_RPACountryType_CountryMaster] FOREIGN KEY([FK_CountryId])
REFERENCES [dbo].[CountryMaster] ([PK_Id])
GO
ALTER TABLE [dbo].[RPACountryType] CHECK CONSTRAINT [FK_RPACountryType_CountryMaster]
GO
ALTER TABLE [dbo].[RPACountryType]  WITH CHECK ADD  CONSTRAINT [FK_RPACountryType_RPA] FOREIGN KEY([FK_RPAId])
REFERENCES [dbo].[RPA] ([PK_Id])
GO
ALTER TABLE [dbo].[RPACountryType] CHECK CONSTRAINT [FK_RPACountryType_RPA]
GO
ALTER TABLE [dbo].[RPAFileMapping]  WITH CHECK ADD  CONSTRAINT [FK_RPAFileMapping_RPA] FOREIGN KEY([FK_RPAId])
REFERENCES [dbo].[RPA] ([PK_Id])
GO
ALTER TABLE [dbo].[RPAFileMapping] CHECK CONSTRAINT [FK_RPAFileMapping_RPA]
GO
ALTER TABLE [dbo].[ScheduleJobs_his]  WITH CHECK ADD  CONSTRAINT [FK_ScheduleJobs_his_FlowForm] FOREIGN KEY([FlowFormId])
REFERENCES [dbo].[FlowForm] ([PK_Id])
GO
ALTER TABLE [dbo].[ScheduleJobs_his] CHECK CONSTRAINT [FK_ScheduleJobs_his_FlowForm]
GO
ALTER TABLE [dbo].[ScheduleJobs_temp]  WITH CHECK ADD  CONSTRAINT [FK_ScheduleJobs_temp_FlowForm] FOREIGN KEY([FlowFormId])
REFERENCES [dbo].[FlowForm] ([PK_Id])
GO
ALTER TABLE [dbo].[ScheduleJobs_temp] CHECK CONSTRAINT [FK_ScheduleJobs_temp_FlowForm]
GO
ALTER TABLE [dbo].[Users]  WITH CHECK ADD  CONSTRAINT [FK_Users_Users] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[Users] CHECK CONSTRAINT [FK_Users_Users]
GO
ALTER TABLE [dbo].[Users]  WITH CHECK ADD  CONSTRAINT [FK_Users_Users1] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[Users] CHECK CONSTRAINT [FK_Users_Users1]
GO
ALTER TABLE [dbo].[UserTextLibrary]  WITH CHECK ADD  CONSTRAINT [FK_UserTextLibrary_Users] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[UserTextLibrary] CHECK CONSTRAINT [FK_UserTextLibrary_Users]
GO
ALTER TABLE [dbo].[UserToken]  WITH CHECK ADD  CONSTRAINT [FK_Users_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[UserToken] CHECK CONSTRAINT [FK_Users_UserId]
GO
COMMIT TRANSACTION;
GO
PRINT N'PHASE 1 COMPLETED: Table schema deployment completed. Run 02_DropCreateProgrammableObjects.sql next.';
GO
-- Restore the session setting when preflight used NOEXEC to halt deployment.
SET NOEXEC OFF;
GO
