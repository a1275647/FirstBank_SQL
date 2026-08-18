-- SSMS ready-to-run instructions:
--   1. Connect to the intended production SQL Server.
--   2. Select Query > SQLCMD Mode.
--   3. Press F5 without selecting only part of this file.
-- No script edits are required. This file performs a destructive schema rebuild of database NCRMS.
:ON ERROR EXIT
:setvar TargetDatabase "NCRMS"
:setvar ConfirmDestructiveRebuild "1"

USE [$(TargetDatabase)];
GO
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO
IF DB_NAME() <> N'$(TargetDatabase)'
    THROW 51000, 'Target database mismatch.', 1;
GO
IF N'$(ConfirmDestructiveRebuild)' <> N'1'
    THROW 51001, 'Set ConfirmDestructiveRebuild=1 only after confirming the target database can be destructively rebuilt.', 1;
GO
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    THROW 51002, 'Required table filegroup NCRMS_TAB does not exist in the target database.', 1;
IF FILEGROUP_ID(N'NCRMS_IDX') IS NULL
    THROW 51003, 'Required index filegroup NCRMS_IDX does not exist in the target database.', 1;
GO

-- Deployment-driver permission model:
--   * Requires DDL rights for the target database objects.
--   * Does not INSERT, UPDATE, DELETE, or SELECT rows from application tables.
--   * DML text inside procedure/trigger definitions is compiled only and is not executed here.
-- Preconditions:
--   * The target database contains no data that must be retained.
--   * No target-only foreign key may reference an EF-managed table; such a dependency fails safely at DROP TABLE.
BEGIN TRANSACTION;
GO

-- Drop the DB-sourced foreign keys explicitly so no temp-table DML or DMV permission is required.
IF OBJECT_ID(N'[dbo].[FK_BankBranch_his_FlowForm]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[BankBranch_his] DROP CONSTRAINT [FK_BankBranch_his_FlowForm];
GO
IF OBJECT_ID(N'[dbo].[FK_BankBranch_temp_FlowForm]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[BankBranch_temp] DROP CONSTRAINT [FK_BankBranch_temp_FlowForm];
GO
IF OBJECT_ID(N'[dbo].[FK_BankYearNeWorthBase_his_FlowForm]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[BankYearNeWorthBase_his] DROP CONSTRAINT [FK_BankYearNeWorthBase_his_FlowForm];
GO
IF OBJECT_ID(N'[dbo].[FK_BankYearNeWorthBase_temp_FlowForm]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[BankYearNeWorthBase_temp] DROP CONSTRAINT [FK_BankYearNeWorthBase_temp_FlowForm];
GO
IF OBJECT_ID(N'[dbo].[FK_ContinentCountry_ContinentMaster]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[ContinentCountry] DROP CONSTRAINT [FK_ContinentCountry_ContinentMaster];
GO
IF OBJECT_ID(N'[dbo].[FK_ContinentCountry_CountryMaster]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[ContinentCountry] DROP CONSTRAINT [FK_ContinentCountry_CountryMaster];
GO
IF OBJECT_ID(N'[dbo].[FK_ContinentCountry_temp_ContinentMaster_temp]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[ContinentCountry_temp] DROP CONSTRAINT [FK_ContinentCountry_temp_ContinentMaster_temp];
GO
IF OBJECT_ID(N'[dbo].[FK_ContinentMaster_his_FlowForm]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[ContinentMaster_his] DROP CONSTRAINT [FK_ContinentMaster_his_FlowForm];
GO
IF OBJECT_ID(N'[dbo].[FK_ContinentMaster_temp_FlowForm]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[ContinentMaster_temp] DROP CONSTRAINT [FK_ContinentMaster_temp_FlowForm];
GO
IF OBJECT_ID(N'[dbo].[FK_CountryException_temp_FlowForm]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[CountryException_temp] DROP CONSTRAINT [FK_CountryException_temp_FlowForm];
GO
IF OBJECT_ID(N'[dbo].[FK_CountryExceptionBankGroup_CountryException]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[CountryExceptionBankGroup] DROP CONSTRAINT [FK_CountryExceptionBankGroup_CountryException];
GO
IF OBJECT_ID(N'[dbo].[FK_CountryExceptionBankGroup_temp_CountryException_temp]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[CountryExceptionBankGroup_temp] DROP CONSTRAINT [FK_CountryExceptionBankGroup_temp_CountryException_temp];
GO
IF OBJECT_ID(N'[dbo].[FK_CountryFocus_temp_FlowForm]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[CountryFocus_temp] DROP CONSTRAINT [FK_CountryFocus_temp_FlowForm];
GO
IF OBJECT_ID(N'[dbo].[FK_CountryMaster_ContinentMaster]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[CountryMaster] DROP CONSTRAINT [FK_CountryMaster_ContinentMaster];
GO
IF OBJECT_ID(N'[dbo].[FK_CountryMaster_temp_FlowForm]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[CountryMaster_temp] DROP CONSTRAINT [FK_CountryMaster_temp_FlowForm];
GO
IF OBJECT_ID(N'[dbo].[FK_CountryOutlookReport_his_FlowForm]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[CountryOutlookReport_his] DROP CONSTRAINT [FK_CountryOutlookReport_his_FlowForm];
GO
IF OBJECT_ID(N'[dbo].[FK_CountryOutlookReport_temp_FlowForm]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[CountryOutlookReport_temp] DROP CONSTRAINT [FK_CountryOutlookReport_temp_FlowForm];
GO
IF OBJECT_ID(N'[dbo].[FK_CountryOutlookReport_Views_CountryOutlookReport]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[CountryOutlookReport_Views] DROP CONSTRAINT [FK_CountryOutlookReport_Views_CountryOutlookReport];
GO
IF OBJECT_ID(N'[dbo].[FK_CountryWeightPercent_ContinentMaster]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[CountryWeightPercent] DROP CONSTRAINT [FK_CountryWeightPercent_ContinentMaster];
GO
IF OBJECT_ID(N'[dbo].[FK_CreditRating_CountApi_Global]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[CreditRating_CountApi] DROP CONSTRAINT [FK_CreditRating_CountApi_Global];
GO
IF OBJECT_ID(N'[dbo].[FK_CreditRating_CountApi_RatingAgency]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[CreditRating_CountApi] DROP CONSTRAINT [FK_CreditRating_CountApi_RatingAgency];
GO
IF OBJECT_ID(N'[dbo].[FK_CreditRating_Country_Current_CountryMaster]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[CreditRating_Country_Current] DROP CONSTRAINT [FK_CreditRating_Country_Current_CountryMaster];
GO
IF OBJECT_ID(N'[dbo].[FK_CreditRating_Country_Current_CreditRatingMaster]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[CreditRating_Country_Current] DROP CONSTRAINT [FK_CreditRating_Country_Current_CreditRatingMaster];
GO
IF OBJECT_ID(N'[dbo].[FK_CreditRating_Country_Log_CountryMaster]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[CreditRating_Country_Log] DROP CONSTRAINT [FK_CreditRating_Country_Log_CountryMaster];
GO
IF OBJECT_ID(N'[dbo].[FK_CreditRating_Country_Log_Detail_CountryMaster]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[CreditRating_Country_Log_Detail] DROP CONSTRAINT [FK_CreditRating_Country_Log_Detail_CountryMaster];
GO
IF OBJECT_ID(N'[dbo].[FK_CreditRating_Country_Log_Detail_CreditRatingMaster]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[CreditRating_Country_Log_Detail] DROP CONSTRAINT [FK_CreditRating_Country_Log_Detail_CreditRatingMaster];
GO
IF OBJECT_ID(N'[dbo].[FK_CreditRating_ErrorCountry_Country]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[CreditRating_ErrorCountry] DROP CONSTRAINT [FK_CreditRating_ErrorCountry_Country];
GO
IF OBJECT_ID(N'[dbo].[FK_CreditRating_ErrorCountry_Global]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[CreditRating_ErrorCountry] DROP CONSTRAINT [FK_CreditRating_ErrorCountry_Global];
GO
IF OBJECT_ID(N'[dbo].[FK_CreditRating_ErrorCountry_RatingAgency]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[CreditRating_ErrorCountry] DROP CONSTRAINT [FK_CreditRating_ErrorCountry_RatingAgency];
GO
IF OBJECT_ID(N'[dbo].[FK_CreditRating_ErrorISIN_Global]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[CreditRating_ErrorISIN] DROP CONSTRAINT [FK_CreditRating_ErrorISIN_Global];
GO
IF OBJECT_ID(N'[dbo].[FK_CreditRating_ErrorISIN_RatingAgency]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[CreditRating_ErrorISIN] DROP CONSTRAINT [FK_CreditRating_ErrorISIN_RatingAgency];
GO
IF OBJECT_ID(N'[dbo].[FK_CreditRating_ErrorLEI_Global]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[CreditRating_ErrorLEI] DROP CONSTRAINT [FK_CreditRating_ErrorLEI_Global];
GO
IF OBJECT_ID(N'[dbo].[FK_CreditRating_ErrorLEI_RatingAgency]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[CreditRating_ErrorLEI] DROP CONSTRAINT [FK_CreditRating_ErrorLEI_RatingAgency];
GO
IF OBJECT_ID(N'[dbo].[FK_CreditRating_ScoreMapping_his_FlowForm]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[CreditRating_ScoreMapping_his] DROP CONSTRAINT [FK_CreditRating_ScoreMapping_his_FlowForm];
GO
IF OBJECT_ID(N'[dbo].[FK_Customer_his_FlowForm]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[Customer_his] DROP CONSTRAINT [FK_Customer_his_FlowForm];
GO
IF OBJECT_ID(N'[dbo].[FK_Customer_temp_FlowForm]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[Customer_temp] DROP CONSTRAINT [FK_Customer_temp_FlowForm];
GO
IF OBJECT_ID(N'[dbo].[FK_FeatureDetail_Menu]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[FeatureDetail] DROP CONSTRAINT [FK_FeatureDetail_Menu];
GO
IF OBJECT_ID(N'[dbo].[FK_FileCenter_Downloads_FileCenter]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[FileCenter_Downloads] DROP CONSTRAINT [FK_FileCenter_Downloads_FileCenter];
GO
IF OBJECT_ID(N'[dbo].[FK_FinancialProductMaster_his_FlowForm]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[FinancialProductMaster_his] DROP CONSTRAINT [FK_FinancialProductMaster_his_FlowForm];
GO
IF OBJECT_ID(N'[dbo].[FK_FinancialProductMaster_temp_FlowForm]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[FinancialProductMaster_temp] DROP CONSTRAINT [FK_FinancialProductMaster_temp_FlowForm];
GO
IF OBJECT_ID(N'[dbo].[FK_FinancialRiskFactorData_PeriodID_FinancialRiskFactorPeriodDay_PKID]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[FinancialRiskFactorData] DROP CONSTRAINT [FK_FinancialRiskFactorData_PeriodID_FinancialRiskFactorPeriodDay_PKID];
GO
IF OBJECT_ID(N'[dbo].[FK_FinancialRiskFactorData_ProductID_FinancialProductMaster_PKID]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[FinancialRiskFactorData] DROP CONSTRAINT [FK_FinancialRiskFactorData_ProductID_FinancialProductMaster_PKID];
GO
IF OBJECT_ID(N'[dbo].[FK_Flow_Menu]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[Flow] DROP CONSTRAINT [FK_Flow_Menu];
GO
IF OBJECT_ID(N'[dbo].[FK_FlowDetail_Flow]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[FlowDetail] DROP CONSTRAINT [FK_FlowDetail_Flow];
GO
IF OBJECT_ID(N'[dbo].[FK_FlowFileMapping_FileCenter]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[FlowFileMapping] DROP CONSTRAINT [FK_FlowFileMapping_FileCenter];
GO
IF OBJECT_ID(N'[dbo].[FK_FlowFileMapping_FlowRecord]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[FlowFileMapping] DROP CONSTRAINT [FK_FlowFileMapping_FlowRecord];
GO
IF OBJECT_ID(N'[dbo].[FK_FlowForm_Flow]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[FlowForm] DROP CONSTRAINT [FK_FlowForm_Flow];
GO
IF OBJECT_ID(N'[dbo].[FK_FlowModifyRecord_FlowDetail]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[FlowModifyRecord] DROP CONSTRAINT [FK_FlowModifyRecord_FlowDetail];
GO
IF OBJECT_ID(N'[dbo].[FK_FlowModifyRecord_FlowForm]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[FlowModifyRecord] DROP CONSTRAINT [FK_FlowModifyRecord_FlowForm];
GO
IF OBJECT_ID(N'[dbo].[FK_FlowRecord_FlowDetail]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[FlowRecord] DROP CONSTRAINT [FK_FlowRecord_FlowDetail];
GO
IF OBJECT_ID(N'[dbo].[FK_FlowRecord_FlowForm]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[FlowRecord] DROP CONSTRAINT [FK_FlowRecord_FlowForm];
GO
IF OBJECT_ID(N'[dbo].[FK_LoanApprovalEntry_BranchData]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[LoanApprovalEntry] DROP CONSTRAINT [FK_LoanApprovalEntry_BranchData];
GO
IF OBJECT_ID(N'[dbo].[FK_LoanBranchApproveAmountHis_BranchData]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[LoanBranchApproveAmountHis] DROP CONSTRAINT [FK_LoanBranchApproveAmountHis_BranchData];
GO
IF OBJECT_ID(N'[dbo].[FK_LoanBranchData_LoanMain]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[LoanBranchData] DROP CONSTRAINT [FK_LoanBranchData_LoanMain];
GO
IF OBJECT_ID(N'[dbo].[FK_LoanExtApp_LoanMain]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[LoanExtApp] DROP CONSTRAINT [FK_LoanExtApp_LoanMain];
GO
IF OBJECT_ID(N'[dbo].[FK_LoanMainUnitData_LoanMain]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[LoanMainUnitData] DROP CONSTRAINT [FK_LoanMainUnitData_LoanMain];
GO
IF OBJECT_ID(N'[dbo].[FK_Mail_temp_FlowForm]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[Mail_temp] DROP CONSTRAINT [FK_Mail_temp_FlowForm];
GO
IF OBJECT_ID(N'[dbo].[FK_MailCcMapping_FKMailId_Mail_Id]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[MailCcMapping] DROP CONSTRAINT [FK_MailCcMapping_FKMailId_Mail_Id];
GO
IF OBJECT_ID(N'[dbo].[FK_MailCcMapping_UserId_Users_UserId]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[MailCcMapping] DROP CONSTRAINT [FK_MailCcMapping_UserId_Users_UserId];
GO
IF OBJECT_ID(N'[dbo].[FK_MailCcMapping_temp_Mail_temp]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[MailCcMapping_temp] DROP CONSTRAINT [FK_MailCcMapping_temp_Mail_temp];
GO
IF OBJECT_ID(N'[dbo].[FK_MailCustomCcMapping_FKMailId_Mail_Id]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[MailCustomCcMapping] DROP CONSTRAINT [FK_MailCustomCcMapping_FKMailId_Mail_Id];
GO
IF OBJECT_ID(N'[dbo].[FK_MailCustomCcMapping_temp_Mail_temp]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[MailCustomCcMapping_temp] DROP CONSTRAINT [FK_MailCustomCcMapping_temp_Mail_temp];
GO
IF OBJECT_ID(N'[dbo].[FK_MailCustomToMapping_FKMailId_Mail_Id]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[MailCustomToMapping] DROP CONSTRAINT [FK_MailCustomToMapping_FKMailId_Mail_Id];
GO
IF OBJECT_ID(N'[dbo].[FK_MailCustomToMapping_temp_Mail_temp]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[MailCustomToMapping_temp] DROP CONSTRAINT [FK_MailCustomToMapping_temp_Mail_temp];
GO
IF OBJECT_ID(N'[dbo].[FK_MailGroupCcMapping_FKMailId_Mail_Id]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[MailGroupCcMapping] DROP CONSTRAINT [FK_MailGroupCcMapping_FKMailId_Mail_Id];
GO
IF OBJECT_ID(N'[dbo].[FK_MailGroupCcMapping_MailGroupId_Group_Id]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[MailGroupCcMapping] DROP CONSTRAINT [FK_MailGroupCcMapping_MailGroupId_Group_Id];
GO
IF OBJECT_ID(N'[dbo].[FK_MailGroupCcMapping_temp_Mail_temp]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[MailGroupCcMapping_temp] DROP CONSTRAINT [FK_MailGroupCcMapping_temp_Mail_temp];
GO
IF OBJECT_ID(N'[dbo].[FK_MailGroupMapping_FKMailId_Mail_Id]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[MailGroupMapping] DROP CONSTRAINT [FK_MailGroupMapping_FKMailId_Mail_Id];
GO
IF OBJECT_ID(N'[dbo].[FK_MailGroupMapping_MailGroupId_Group_Id]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[MailGroupMapping] DROP CONSTRAINT [FK_MailGroupMapping_MailGroupId_Group_Id];
GO
IF OBJECT_ID(N'[dbo].[FK_MailGroupMapping_temp_Mail_temp]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[MailGroupMapping_temp] DROP CONSTRAINT [FK_MailGroupMapping_temp_Mail_temp];
GO
IF OBJECT_ID(N'[dbo].[FK_MailGroupUser_MailGroupId_Group_Id]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[MailGroupUser] DROP CONSTRAINT [FK_MailGroupUser_MailGroupId_Group_Id];
GO
IF OBJECT_ID(N'[dbo].[FK_MailGroupUser_UserId_Users_UserId]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[MailGroupUser] DROP CONSTRAINT [FK_MailGroupUser_UserId_Users_UserId];
GO
IF OBJECT_ID(N'[dbo].[FK_MailLog_CcCustomMapping_MailLog]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[MailLog_CcCustomMapping] DROP CONSTRAINT [FK_MailLog_CcCustomMapping_MailLog];
GO
IF OBJECT_ID(N'[dbo].[FK_Mail_CcGroupMapping_MailGroup]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[MailLog_CcGroupMapping] DROP CONSTRAINT [FK_Mail_CcGroupMapping_MailGroup];
GO
IF OBJECT_ID(N'[dbo].[FK_Mail_CcGroupMapping_MailLog]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[MailLog_CcGroupMapping] DROP CONSTRAINT [FK_Mail_CcGroupMapping_MailLog];
GO
IF OBJECT_ID(N'[dbo].[FK_MailLog_CcMapping_MailLog]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[MailLog_CcMapping] DROP CONSTRAINT [FK_MailLog_CcMapping_MailLog];
GO
IF OBJECT_ID(N'[dbo].[FK_MailLog_CcMapping_Users]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[MailLog_CcMapping] DROP CONSTRAINT [FK_MailLog_CcMapping_Users];
GO
IF OBJECT_ID(N'[dbo].[FK_MailLog_CustomMapping_MailLog]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[MailLog_CustomMapping] DROP CONSTRAINT [FK_MailLog_CustomMapping_MailLog];
GO
IF OBJECT_ID(N'[dbo].[FK_MailLog_FileMapping_MailLog]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[MailLog_FileMapping] DROP CONSTRAINT [FK_MailLog_FileMapping_MailLog];
GO
IF OBJECT_ID(N'[dbo].[FK_MailLog_GroupMapping_MailLog]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[MailLog_GroupMapping] DROP CONSTRAINT [FK_MailLog_GroupMapping_MailLog];
GO
IF OBJECT_ID(N'[dbo].[FK_MailLog_Mapping_MailLog]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[MailLog_Mapping] DROP CONSTRAINT [FK_MailLog_Mapping_MailLog];
GO
IF OBJECT_ID(N'[dbo].[FK_MailLog_Mapping_Users]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[MailLog_Mapping] DROP CONSTRAINT [FK_MailLog_Mapping_Users];
GO
IF OBJECT_ID(N'[dbo].[Fk_MailToMapping_FKMailId_Mail_Id]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[MailToMapping] DROP CONSTRAINT [Fk_MailToMapping_FKMailId_Mail_Id];
GO
IF OBJECT_ID(N'[dbo].[FK_MailToMapping_UserId_Users_UserId]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[MailToMapping] DROP CONSTRAINT [FK_MailToMapping_UserId_Users_UserId];
GO
IF OBJECT_ID(N'[dbo].[FK_MailToMapping_temp_Mail_temp]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[MailToMapping_temp] DROP CONSTRAINT [FK_MailToMapping_temp_Mail_temp];
GO
IF OBJECT_ID(N'[dbo].[FK_MONITORDATA_his_FlowForm]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[MONITORDATA_his] DROP CONSTRAINT [FK_MONITORDATA_his_FlowForm];
GO
IF OBJECT_ID(N'[dbo].[FK_MONITORDATA_temp_FlowForm]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[MONITORDATA_temp] DROP CONSTRAINT [FK_MONITORDATA_temp_FlowForm];
GO
IF OBJECT_ID(N'[dbo].[FK_News_his_FlowForm]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[News_his] DROP CONSTRAINT [FK_News_his_FlowForm];
GO
IF OBJECT_ID(N'[dbo].[FK_News_temp_FlowForm]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[News_temp] DROP CONSTRAINT [FK_News_temp_FlowForm];
GO
IF OBJECT_ID(N'[dbo].[FK_News_Views_News]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[News_Views] DROP CONSTRAINT [FK_News_Views_News];
GO
IF OBJECT_ID(N'[dbo].[FK_NewsCountryType_CountryMaster]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[NewsCountryType] DROP CONSTRAINT [FK_NewsCountryType_CountryMaster];
GO
IF OBJECT_ID(N'[dbo].[FK_NewsCountryType_News]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[NewsCountryType] DROP CONSTRAINT [FK_NewsCountryType_News];
GO
IF OBJECT_ID(N'[dbo].[FK_NewsFileMapping_News]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[NewsFileMapping] DROP CONSTRAINT [FK_NewsFileMapping_News];
GO
IF OBJECT_ID(N'[dbo].[FK_NoticeUser_NoticeUser]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[NoticeUser] DROP CONSTRAINT [FK_NoticeUser_NoticeUser];
GO
IF OBJECT_ID(N'[dbo].[FK_Permissions_FeatureDetail]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[Permissions] DROP CONSTRAINT [FK_Permissions_FeatureDetail];
GO
IF OBJECT_ID(N'[dbo].[FK_Permissions_Role]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[Permissions] DROP CONSTRAINT [FK_Permissions_Role];
GO
IF OBJECT_ID(N'[dbo].[FK_Permissions_his_Role_his]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[Permissions_his] DROP CONSTRAINT [FK_Permissions_his_Role_his];
GO
IF OBJECT_ID(N'[dbo].[FK_Permissions_Query_Role]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[Permissions_Query] DROP CONSTRAINT [FK_Permissions_Query_Role];
GO
IF OBJECT_ID(N'[dbo].[FK_Permissions_Query_his_Role_his]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[Permissions_Query_his] DROP CONSTRAINT [FK_Permissions_Query_his_Role_his];
GO
IF OBJECT_ID(N'[dbo].[FK_Post_his_FlowForm]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[Post_his] DROP CONSTRAINT [FK_Post_his_FlowForm];
GO
IF OBJECT_ID(N'[dbo].[FK_Post_temp_FlowForm]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[Post_temp] DROP CONSTRAINT [FK_Post_temp_FlowForm];
GO
IF OBJECT_ID(N'[dbo].[FK_Post_Views_Post]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[Post_Views] DROP CONSTRAINT [FK_Post_Views_Post];
GO
IF OBJECT_ID(N'[dbo].[FK_PostCountryType_CountryMaster]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[PostCountryType] DROP CONSTRAINT [FK_PostCountryType_CountryMaster];
GO
IF OBJECT_ID(N'[dbo].[FK_PostCountryType_Post]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[PostCountryType] DROP CONSTRAINT [FK_PostCountryType_Post];
GO
IF OBJECT_ID(N'[dbo].[FK_PostFileMapping_Post]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[PostFileMapping] DROP CONSTRAINT [FK_PostFileMapping_Post];
GO
IF OBJECT_ID(N'[dbo].[FK_QuickLink_QuickLink]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[QuickLink] DROP CONSTRAINT [FK_QuickLink_QuickLink];
GO
IF OBJECT_ID(N'[dbo].[FK_QuotaBank_D_Form_AllData_QuotaBank_M_Form_AllData]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[QuotaBank_D_Form_AllData] DROP CONSTRAINT [FK_QuotaBank_D_Form_AllData_QuotaBank_M_Form_AllData];
GO
IF OBJECT_ID(N'[dbo].[FK_QuotaBank_D_his_QuotaBank_M_his]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[QuotaBank_D_his] DROP CONSTRAINT [FK_QuotaBank_D_his_QuotaBank_M_his];
GO
IF OBJECT_ID(N'[dbo].[FK_QuotaBank_D_temp_QuotaBank_M_temp]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[QuotaBank_D_temp] DROP CONSTRAINT [FK_QuotaBank_D_temp_QuotaBank_M_temp];
GO
IF OBJECT_ID(N'[dbo].[FK_QuotaBank_Form_Data_FlowForm]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[QuotaBank_Form_Data] DROP CONSTRAINT [FK_QuotaBank_Form_Data_FlowForm];
GO
IF OBJECT_ID(N'[dbo].[FK_QuotaBank_M_Form_AllData_FlowForm]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[QuotaBank_M_Form_AllData] DROP CONSTRAINT [FK_QuotaBank_M_Form_AllData_FlowForm];
GO
IF OBJECT_ID(N'[dbo].[FK_QuotaBank_M_his_FlowForm]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[QuotaBank_M_his] DROP CONSTRAINT [FK_QuotaBank_M_his_FlowForm];
GO
IF OBJECT_ID(N'[dbo].[FK_QuotaBank_Weight_Form_AllData_QuotaBank_D_Form_AllData]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[QuotaBank_Weight_Form_AllData] DROP CONSTRAINT [FK_QuotaBank_Weight_Form_AllData_QuotaBank_D_Form_AllData];
GO
IF OBJECT_ID(N'[dbo].[FK_QuotaBank_Weight_his_QuotaBank_D_his]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[QuotaBank_Weight_his] DROP CONSTRAINT [FK_QuotaBank_Weight_his_QuotaBank_D_his];
GO
IF OBJECT_ID(N'[dbo].[FK_QuotaBank_Weight_temp_QuotaBank_D_temp]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[QuotaBank_Weight_temp] DROP CONSTRAINT [FK_QuotaBank_Weight_temp_QuotaBank_D_temp];
GO
IF OBJECT_ID(N'[dbo].[FK_RatingRatioMaster_temp_BankYearNeWorthBase_temp]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[RatingRatioMaster_temp] DROP CONSTRAINT [FK_RatingRatioMaster_temp_BankYearNeWorthBase_temp];
GO
IF OBJECT_ID(N'[dbo].[FK_Role_Position_Mapping_Role]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[Role_Position_Mapping] DROP CONSTRAINT [FK_Role_Position_Mapping_Role];
GO
IF OBJECT_ID(N'[dbo].[FK_Role_Position_Mapping_his_Role_his]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[Role_Position_Mapping_his] DROP CONSTRAINT [FK_Role_Position_Mapping_his_Role_his];
GO
IF OBJECT_ID(N'[dbo].[FK_Role_User_Mapping_Role]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[Role_User_Mapping] DROP CONSTRAINT [FK_Role_User_Mapping_Role];
GO
IF OBJECT_ID(N'[dbo].[FK_Role_User_Mapping_Users]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[Role_User_Mapping] DROP CONSTRAINT [FK_Role_User_Mapping_Users];
GO
IF OBJECT_ID(N'[dbo].[FK_Role_User_Mapping_his_Role_his]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[Role_User_Mapping_his] DROP CONSTRAINT [FK_Role_User_Mapping_his_Role_his];
GO
IF OBJECT_ID(N'[dbo].[FK_NewsPost_temp_FlowForm]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[RPA_temp] DROP CONSTRAINT [FK_NewsPost_temp_FlowForm];
GO
IF OBJECT_ID(N'[dbo].[FK_RPA_Views_RPA]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[RPA_Views] DROP CONSTRAINT [FK_RPA_Views_RPA];
GO
IF OBJECT_ID(N'[dbo].[FK_RPACountryType_CountryMaster]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[RPACountryType] DROP CONSTRAINT [FK_RPACountryType_CountryMaster];
GO
IF OBJECT_ID(N'[dbo].[FK_RPACountryType_RPA]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[RPACountryType] DROP CONSTRAINT [FK_RPACountryType_RPA];
GO
IF OBJECT_ID(N'[dbo].[FK_RPAFileMapping_RPA]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[RPAFileMapping] DROP CONSTRAINT [FK_RPAFileMapping_RPA];
GO
IF OBJECT_ID(N'[dbo].[FK_ScheduleJobs_his_FlowForm]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[ScheduleJobs_his] DROP CONSTRAINT [FK_ScheduleJobs_his_FlowForm];
GO
IF OBJECT_ID(N'[dbo].[FK_ScheduleJobs_temp_FlowForm]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[ScheduleJobs_temp] DROP CONSTRAINT [FK_ScheduleJobs_temp_FlowForm];
GO
IF OBJECT_ID(N'[dbo].[FK_Users_Users]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[Users] DROP CONSTRAINT [FK_Users_Users];
GO
IF OBJECT_ID(N'[dbo].[FK_Users_Users1]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[Users] DROP CONSTRAINT [FK_Users_Users1];
GO
IF OBJECT_ID(N'[dbo].[FK_UserTextLibrary_Users]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[UserTextLibrary] DROP CONSTRAINT [FK_UserTextLibrary_Users];
GO
IF OBJECT_ID(N'[dbo].[FK_Users_UserId]', N'F') IS NOT NULL
    ALTER TABLE [dbo].[UserToken] DROP CONSTRAINT [FK_Users_UserId];
GO

DROP PROCEDURE IF EXISTS [dbo].[usp_UpdateMonitorDataUnit];
GO
DROP PROCEDURE IF EXISTS [dbo].[usp_UpdateMonitorDataPruduct07RiskFactor];
GO
DROP PROCEDURE IF EXISTS [dbo].[usp_UpdateCustomer];
GO
DROP PROCEDURE IF EXISTS [dbo].[usp_ResolveGroupIdForCustomer];
GO
DROP PROCEDURE IF EXISTS [dbo].[usp_BmiRatingCount];
GO
DROP PROCEDURE IF EXISTS [dbo].[usp_UpdateMonitorDataLimit];
GO
DROP PROCEDURE IF EXISTS [dbo].[usp_UpdateMonitorDataFPEXR_RateUSD];
GO
DROP PROCEDURE IF EXISTS [dbo].[usp_UpdateMonitorDataCNWeights];
GO
DROP PROCEDURE IF EXISTS [dbo].[usp_UpdateMonitorDataCalculatedUsdAmount];
GO
DROP PROCEDURE IF EXISTS [dbo].[usp_TransferData];
GO
DROP PROCEDURE IF EXISTS [dbo].[usp_Souce09_By_ARS_SUKSWP_D_MF];
GO
DROP PROCEDURE IF EXISTS [dbo].[usp_Souce09_By_ARS_SUKNMM_D_MF];
GO
DROP PROCEDURE IF EXISTS [dbo].[usp_Souce09_By_ARS_SUKNIRS_D_MF];
GO
DROP PROCEDURE IF EXISTS [dbo].[usp_Souce09_By_ARS_SUKNFX_D_MF];
GO
DROP PROCEDURE IF EXISTS [dbo].[usp_Souce09_By_ARS_SUKNFO_D_MF];
GO
DROP PROCEDURE IF EXISTS [dbo].[usp_Souce09_By_ARS_SUKNBD1_D_MF];
GO
DROP PROCEDURE IF EXISTS [dbo].[usp_Souce09_By_ARS_SUKMST_D_MF];
GO
DROP PROCEDURE IF EXISTS [dbo].[usp_Souce09_By_ARS_SUKIRO_D_MF];
GO
DROP PROCEDURE IF EXISTS [dbo].[usp_Souce09_By_ARS_SUKFRA_D_MF];
GO
DROP PROCEDURE IF EXISTS [dbo].[usp_Souce09_By_ARS_SUKBDO_D_MF];
GO
DROP PROCEDURE IF EXISTS [dbo].[usp_Souce09_By_ARS_SUKBD2_D_MF];
GO
DROP PROCEDURE IF EXISTS [dbo].[usp_Souce06_By_FL_FLMST_D_MF];
GO
DROP PROCEDURE IF EXISTS [dbo].[usp_Souce04_By_LS_LSRSA_D_MF_ACNOD_STG];
GO
DROP PROCEDURE IF EXISTS [dbo].[usp_Souce01_OBBS_By_OS_LNSMSTD_D_MF_OS_LNSLMSD_D_MF];
GO
DROP PROCEDURE IF EXISTS [dbo].[usp_Souce01_OBBS_By_OSMMKF02_MF];
GO
DROP PROCEDURE IF EXISTS [dbo].[usp_Souce01_OBBS_By_OSISKF02_MF];
GO
DROP PROCEDURE IF EXISTS [dbo].[usp_Souce01_OBBS_By_OSFXKF02_MF];
GO
DROP PROCEDURE IF EXISTS [dbo].[usp_Souce01_OBBS_By_OSBDKF02_MF];
GO
DROP PROCEDURE IF EXISTS [dbo].[usp_HRIS_Transfer_Users];
GO
DROP PROCEDURE IF EXISTS [dbo].[usp_HRIS_Transfer_BankUnit];
GO
DROP PROCEDURE IF EXISTS [dbo].[usp_HRIS_Transfer_BankGroup];
GO
DROP PROCEDURE IF EXISTS [dbo].[usp_HRIS_Transfer_BankBranch];
GO
DROP PROCEDURE IF EXISTS [dbo].[usp_GetGroupId];
GO
DROP PROCEDURE IF EXISTS [dbo].[usp_CreateTempTable_Detail];
GO
DROP PROCEDURE IF EXISTS [dbo].[usp_CreateTempTable];
GO
DROP PROCEDURE IF EXISTS [dbo].[usp_CreateHistoryTable_Detail];
GO
DROP PROCEDURE IF EXISTS [dbo].[usp_CreateHistoryTable];
GO
DROP PROCEDURE IF EXISTS [dbo].[usp_CreateHistoryHasFlowTable];
GO
DROP FUNCTION IF EXISTS [dbo].[ufn_table_GetUnitName];
GO
DROP FUNCTION IF EXISTS [dbo].[ufn_table_GetMonitorDataLimitAmount];
GO
DROP FUNCTION IF EXISTS [dbo].[ufn_table_GetCountryRating];
GO
DROP FUNCTION IF EXISTS [dbo].[ufn_MatchingCustomerGroupIds];
GO
DROP FUNCTION IF EXISTS [dbo].[ufn_GetWeekOfMonth];
GO
DROP FUNCTION IF EXISTS [dbo].[ufn_GetNumFromFileName];
GO
DROP FUNCTION IF EXISTS [dbo].[ufn_GetLastDateOfWeek];
GO
DROP FUNCTION IF EXISTS [dbo].[ufn_FinancialRiskFactor];
GO
DROP FUNCTION IF EXISTS [dbo].[ufn_CodePrefix];
GO
DROP VIEW IF EXISTS [dbo].[RoleUserMatch];
GO
DROP FUNCTION IF EXISTS [dbo].[getNUM];
GO
DROP TABLE IF EXISTS [dbo].[UserToken];
GO
DROP TABLE IF EXISTS [dbo].[UserTextLibrary];
GO
DROP TABLE IF EXISTS [dbo].[Users_log];
GO
DROP TABLE IF EXISTS [dbo].[Users];
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
DROP TABLE IF EXISTS [dbo].[RPA];
GO
DROP TABLE IF EXISTS [dbo].[Role_User_Mapping_his];
GO
DROP TABLE IF EXISTS [dbo].[Role_User_Mapping];
GO
DROP TABLE IF EXISTS [dbo].[Role_Position_Mapping_his];
GO
DROP TABLE IF EXISTS [dbo].[Role_Position_Mapping];
GO
DROP TABLE IF EXISTS [dbo].[Role_his];
GO
DROP TABLE IF EXISTS [dbo].[Role];
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
DROP TABLE IF EXISTS [dbo].[QuotaBank_M_temp];
GO
DROP TABLE IF EXISTS [dbo].[QuotaBank_M_his];
GO
DROP TABLE IF EXISTS [dbo].[QuotaBank_M_Form_AllData];
GO
DROP TABLE IF EXISTS [dbo].[QuotaBank_M];
GO
DROP TABLE IF EXISTS [dbo].[QuotaBank_Form_ParentWeight];
GO
DROP TABLE IF EXISTS [dbo].[QuotaBank_Form_Data];
GO
DROP TABLE IF EXISTS [dbo].[QuotaBank_D_Week];
GO
DROP TABLE IF EXISTS [dbo].[QuotaBank_D_temp];
GO
DROP TABLE IF EXISTS [dbo].[QuotaBank_D_his];
GO
DROP TABLE IF EXISTS [dbo].[QuotaBank_D_Form_AllData];
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
DROP TABLE IF EXISTS [dbo].[Post];
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
DROP TABLE IF EXISTS [dbo].[Notice];
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
DROP TABLE IF EXISTS [dbo].[News];
GO
DROP TABLE IF EXISTS [dbo].[MONITORDATA_temp];
GO
DROP TABLE IF EXISTS [dbo].[MONITORDATA_his];
GO
DROP TABLE IF EXISTS [dbo].[MONITORDATA];
GO
DROP TABLE IF EXISTS [dbo].[MIS_CRCY_REF];
GO
DROP TABLE IF EXISTS [dbo].[Menu];
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
DROP TABLE IF EXISTS [dbo].[MailLog];
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
DROP TABLE IF EXISTS [dbo].[MailGroup];
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
DROP TABLE IF EXISTS [dbo].[Mail_temp];
GO
DROP TABLE IF EXISTS [dbo].[Mail_his];
GO
DROP TABLE IF EXISTS [dbo].[Mail];
GO
DROP TABLE IF EXISTS [dbo].[m_parameter];
GO
DROP TABLE IF EXISTS [dbo].[LS_LSRSA_D_MF];
GO
DROP TABLE IF EXISTS [dbo].[LoanMainUnitData];
GO
DROP TABLE IF EXISTS [dbo].[LoanExtApp];
GO
DROP TABLE IF EXISTS [dbo].[LoanBranchData];
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
DROP TABLE IF EXISTS [dbo].[Global];
GO
DROP TABLE IF EXISTS [dbo].[FPEXR_STG];
GO
DROP TABLE IF EXISTS [dbo].[ForexRate];
GO
DROP TABLE IF EXISTS [dbo].[FM_FMLINE_D_MF];
GO
DROP TABLE IF EXISTS [dbo].[FlowUserReset];
GO
DROP TABLE IF EXISTS [dbo].[FlowRecord];
GO
DROP TABLE IF EXISTS [dbo].[FlowModifyRecord];
GO
DROP TABLE IF EXISTS [dbo].[FlowForm_LoanMain];
GO
DROP TABLE IF EXISTS [dbo].[FlowForm];
GO
DROP TABLE IF EXISTS [dbo].[FlowFileMapping];
GO
DROP TABLE IF EXISTS [dbo].[FlowDetail];
GO
DROP TABLE IF EXISTS [dbo].[Flow];
GO
DROP TABLE IF EXISTS [dbo].[FL_FLMST_D_MF];
GO
DROP TABLE IF EXISTS [dbo].[FinancialRiskFactorPeriodDay_temp];
GO
DROP TABLE IF EXISTS [dbo].[FinancialRiskFactorPeriodDay_his];
GO
DROP TABLE IF EXISTS [dbo].[FinancialRiskFactorPeriodDay];
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
DROP TABLE IF EXISTS [dbo].[FinancialProductMaster];
GO
DROP TABLE IF EXISTS [dbo].[FileCenter_Downloads];
GO
DROP TABLE IF EXISTS [dbo].[FileCenter];
GO
DROP TABLE IF EXISTS [dbo].[FeatureDetail];
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
DROP TABLE IF EXISTS [dbo].[CreditRatingMaster];
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
DROP TABLE IF EXISTS [dbo].[CountryOutlookReport];
GO
DROP TABLE IF EXISTS [dbo].[CountryMaster_temp];
GO
DROP TABLE IF EXISTS [dbo].[CountryMaster_his];
GO
DROP TABLE IF EXISTS [dbo].[CountryMaster];
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
DROP TABLE IF EXISTS [dbo].[CountryException_temp];
GO
DROP TABLE IF EXISTS [dbo].[CountryException_his];
GO
DROP TABLE IF EXISTS [dbo].[CountryException];
GO
DROP TABLE IF EXISTS [dbo].[ContinentMaster_temp];
GO
DROP TABLE IF EXISTS [dbo].[ContinentMaster_his];
GO
DROP TABLE IF EXISTS [dbo].[ContinentMaster];
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
DROP TABLE IF EXISTS [dbo].[BankYearNeWorthBase_temp];
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
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ACNOD_STG](
	[ACNOD_BRANCH_CODE] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[ACNOD_CRCY_CODE] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[ACNOD_ACC5_CODE] [nvarchar](5) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[ACNOD_ACC5_SUB_CODE] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[ACNOD_OPER_DATE_BAL_INF] [decimal](17, 2) NULL,
	[ACNOD_LAST_BAL_MARK] [nvarchar](1) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[ACNOD_EXT_DATE] [date] NULL,
	[Create_Date] [datetime] NOT NULL
) ON [NCRMS_TAB]
GO
CREATE NONCLUSTERED INDEX [IX_ACNOD_STG] ON [dbo].[ACNOD_STG]
(
	[ACNOD_EXT_DATE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
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
CREATE TABLE [dbo].[ACOLRT_STG](
	[ACOLRT_DATE] [date] NULL,
	[ACOLRT_BRANCH] [nvarchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[ACOLRT_CURENCY] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[ACOLRT_LOCAL_CURENCY] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[ACOLRT_RATE] [decimal](18, 10) NULL,
	[ACOLRT_EXT_DATE] [date] NULL,
	[ACOLRT_LOAD_DATE] [datetime] NULL,
	[Create_Date] [datetime] NOT NULL
) ON [NCRMS_TAB]
GO
ALTER TABLE [dbo].[ACOLRT_STG] ADD  CONSTRAINT [DF_ACOLRT_STG_Create_Date]  DEFAULT (getdate()) FOR [Create_Date]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建置時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ACOLRT_STG', @level2type=N'COLUMN',@level2name=N'Create_Date'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ARS_SUKBDO_D_MF](
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
CREATE TABLE [dbo].[ARS_SUKFRA_D_MF](
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
CREATE TABLE [dbo].[ARS_SUKIRO_D_MF](
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
CREATE TABLE [dbo].[ARS_SUKMST_D_MF](
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
CREATE TABLE [dbo].[ARS_SUKNBD1_D_MF](
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
GO
ALTER TABLE [dbo].[ARS_SUKNBD1_D_MF] ADD  CONSTRAINT [DF_ARS_SUKNBD1_D_MF_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建置時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKNBD1_D_MF', @level2type=N'COLUMN',@level2name=N'Create_date'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ARS_SUKNFO_D_MF](
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
GO
ALTER TABLE [dbo].[ARS_SUKNFO_D_MF] ADD  CONSTRAINT [DF_ARS_SUKNFO_D_MF_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建置時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKNFO_D_MF', @level2type=N'COLUMN',@level2name=N'Create_date'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ARS_SUKNFX_D_MF](
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
GO
ALTER TABLE [dbo].[ARS_SUKNFX_D_MF] ADD  CONSTRAINT [DF_ARS_SUKNFX_D_MF_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建置時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKNFX_D_MF', @level2type=N'COLUMN',@level2name=N'Create_date'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ARS_SUKNIRS_D_MF](
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
GO
ALTER TABLE [dbo].[ARS_SUKNIRS_D_MF] ADD  CONSTRAINT [DF_ARS_SUKNIRS_D_MF_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建置時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKNIRS_D_MF', @level2type=N'COLUMN',@level2name=N'Create_date'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ARS_SUKNMM_D_MF](
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
GO
ALTER TABLE [dbo].[ARS_SUKNMM_D_MF] ADD  CONSTRAINT [DF_ARS_SUKNMM_D_MF_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建置時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKNMM_D_MF', @level2type=N'COLUMN',@level2name=N'Create_date'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ARS_SUKSWP_D_MF](
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
GO
ALTER TABLE [dbo].[ARS_SUKSWP_D_MF] ADD  CONSTRAINT [DF_ARS_SUKSWP_D_MF_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建置時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ARS_SUKSWP_D_MF', @level2type=N'COLUMN',@level2name=N'Create_date'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BankBranch](
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
CREATE TABLE [dbo].[BankBranch_his](
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
CREATE TABLE [dbo].[BankBranch_temp](
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
CREATE TABLE [dbo].[BankGroup](
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
CREATE TABLE [dbo].[BankUnit](
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
CREATE TABLE [dbo].[BankYearNeWorthBase](
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
CREATE TABLE [dbo].[BankYearNeWorthBase_his](
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
CREATE TABLE [dbo].[BankYearNeWorthBase_temp](
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
CREATE TABLE [dbo].[BankYearNeWorthBase_Week](
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
GO
CREATE NONCLUSTERED INDEX [IX_BankYearNeWorthBase_Week] ON [dbo].[BankYearNeWorthBase_Week]
(
	[Year] ASC,
	[Month] ASC,
	[Week] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
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
CREATE TABLE [dbo].[CDS](
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
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ContinentCountry](
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
GO
CREATE NONCLUSTERED INDEX [IX_ContinentCountry] ON [dbo].[ContinentCountry]
(
	[ContinentId] ASC,
	[CountryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
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
CREATE TABLE [dbo].[ContinentCountry_his](
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
CREATE TABLE [dbo].[ContinentCountry_temp](
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
CREATE TABLE [dbo].[ContinentMaster](
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
CREATE TABLE [dbo].[ContinentMaster_his](
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
CREATE TABLE [dbo].[ContinentMaster_temp](
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
CREATE TABLE [dbo].[CountryException](
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
GO
ALTER TABLE [dbo].[CountryException] ADD  CONSTRAINT [DF_CountryException_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[CountryException] ADD  CONSTRAINT [DF_CountryException_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CountryException_his](
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
CREATE TABLE [dbo].[CountryException_temp](
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
GO
ALTER TABLE [dbo].[CountryException_temp] ADD  CONSTRAINT [DF_CountryException_temp_SysCreateDate]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CountryExceptionBankGroup](
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
CREATE TABLE [dbo].[CountryExceptionBankGroup_his](
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
CREATE TABLE [dbo].[CountryExceptionBankGroup_temp](
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
CREATE TABLE [dbo].[CountryFocus](
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
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CountryFocus_his](
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
GO
ALTER TABLE [dbo].[CountryFocus_his] ADD  CONSTRAINT [DF_CountryFocus_his_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[CountryFocus_his] ADD  CONSTRAINT [DF_CountryFocus_his_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CountryFocus_temp](
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
GO
ALTER TABLE [dbo].[CountryFocus_temp] ADD  CONSTRAINT [DF_CountryFocus_temp_Completion_date]  DEFAULT (getdate()) FOR [Approval_date]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CountryForexRateMapping](
	[CountryCode2] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[ForexRateCode] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
 CONSTRAINT [PK_CountryForexRateMapping] PRIMARY KEY CLUSTERED
(
	[CountryCode2] ASC,
	[ForexRateCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CountryMaster](
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
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
) ON [NCRMS_TAB]
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
CREATE TABLE [dbo].[CountryMaster_his](
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
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
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
CREATE TABLE [dbo].[CountryMaster_temp](
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
) ON [NCRMS_TAB]
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
CREATE TABLE [dbo].[CountryOutlookReport](
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
	[GdpGrowth] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
 CONSTRAINT [PK_CountryOutlookReport] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
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
CREATE TABLE [dbo].[CountryOutlookReport_his](
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
	[LastYearHighCDS] [decimal](18, 2) NULL,
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
CREATE TABLE [dbo].[CountryOutlookReport_Source](
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
GO
ALTER TABLE [dbo].[CountryOutlookReport_Source] ADD  CONSTRAINT [DF_CountryOutlookReport_Source_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CountryOutlookReport_temp](
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
	[LastYearHighCDS] [decimal](18, 2) NULL,
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
CREATE TABLE [dbo].[CountryOutlookReport_Views](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_ReportId] [int] NOT NULL,
	[Views] [int] NOT NULL,
 CONSTRAINT [PK_CountryOutlookReport_Views] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
GO
ALTER TABLE [dbo].[CountryOutlookReport_Views] ADD  CONSTRAINT [DF_CountryOutlookReport_Views_Views]  DEFAULT ((0)) FOR [Views]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CountryWeightPercent](
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
GO
CREATE NONCLUSTERED INDEX [IX_CountryWeightPercent] ON [dbo].[CountryWeightPercent]
(
	[CountryId] ASC,
	[WeightPercent] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
GO
ALTER TABLE [dbo].[CountryWeightPercent] ADD  CONSTRAINT [DF_CountryWeightPercent_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CreditRating_AllBmi](
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
GO
CREATE NONCLUSTERED INDEX [IX_CreditRating_AllBmi_Country_Year_Category] ON [dbo].[CreditRating_AllBmi]
(
	[FK_Country_Id] ASC,
	[Year] ASC,
	[FK_CategoriesId] ASC
)
INCLUDE([Score]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
GO
ALTER TABLE [dbo].[CreditRating_AllBmi] ADD  CONSTRAINT [DF_BMICountryRisk_temp_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CreditRating_Bmi](
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
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
 CONSTRAINT [PK_BMICountryRisk] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
GO
CREATE NONCLUSTERED INDEX [IX_Bmi_CountryYear] ON [dbo].[CreditRating_Bmi]
(
	[FK_Country_Id] ASC,
	[Year] ASC
)
INCLUDE([BMI_GDP_NOM_USD_AVE],[BMI_GDP_REAL_PCTCH],[BMI_INFLATION_CPI_AVE_UNIT],[BMI_LABOUR_UNEMP_PCT_AVE_UNIT],[BMI_RESERVES_IMPCOVER],[BMI_DEBT_EXT_PCGDP],[BMI_DEBT_EXT_ST_PCTEXTDEBT],[BMI_FISCAL_BALANCE_PCTGDP],[BMI_DEBT_GOVT_PCGDP],[BMI_INDEX_POLRISK_UNIT_50046_E],[BMI_INDEX_POLRISK_SECURITY_UNIT_10012_E]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
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
CREATE TABLE [dbo].[CreditRating_BmiRule](
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
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_BmiRule_RuleName_Active] ON [dbo].[CreditRating_BmiRule]
(
	[RuleName] ASC,
	[IsActive] ASC,
	[ScoreLevel] ASC
)
INCLUDE([MinValue],[MaxValue],[Score]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
GO
ALTER TABLE [dbo].[CreditRating_BmiRule] ADD  CONSTRAINT [DF__CreditRat__IsDis__33E06DE7]  DEFAULT ((1)) FOR [IsDisplay]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CreditRating_CountApi](
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
GO
CREATE NONCLUSTERED INDEX [IX_CreditRating_CountApi_Agency_Type] ON [dbo].[CreditRating_CountApi]
(
	[FK_RatingAgency_Id] ASC,
	[CreditRatingType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
GO
ALTER TABLE [dbo].[CreditRating_CountApi] ADD  CONSTRAINT [DF_CreditRating_CountApi_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CreditRating_CountBmi](
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
	[End_Explain] [nvarchar](500) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[AssessmentDay] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
 CONSTRAINT [PK_TotalCountryRating] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CreditRating_Country](
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
GO
CREATE NONCLUSTERED INDEX [IX_CreditRating_Country_Lookup] ON [dbo].[CreditRating_Country]
(
	[FK_Country_Id] ASC,
	[FK_RatingAgency_Id] ASC,
	[date] ASC
)
INCLUDE([AgencyRating],[RatingOutlook],[RatingOutlookDate],[RatingDate],[Create_date]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
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
CREATE TABLE [dbo].[CreditRating_Country_Current](
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
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CreditRating_Country_Log](
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
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CreditRating_Country_Log_Detail](
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
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CreditRating_Country_M](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_CountryId] [int] NOT NULL,
	[Score] [int] NOT NULL,
	[Create_date] [datetime] NULL,
 CONSTRAINT [PK_CreditRating_Country_M] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
GO
CREATE NONCLUSTERED INDEX [IX_CreditRating_Country_M_Country_CreateDate] ON [dbo].[CreditRating_Country_M]
(
	[FK_CountryId] ASC,
	[Create_date] DESC
)
INCLUDE([Score]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
GO
ALTER TABLE [dbo].[CreditRating_Country_M] ADD  CONSTRAINT [DF_CreditRating_Country_M_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CreditRating_CountryId](
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
GO
CREATE NONCLUSTERED INDEX [IX_CreditRating_CountryId_Agency_Country] ON [dbo].[CreditRating_CountryId]
(
	[FK_AgencyCode_Id] ASC,
	[FK_Country_Id] ASC
)
INCLUDE([EntityId]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
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
CREATE TABLE [dbo].[CreditRating_ErrorCountry](
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
GO
ALTER TABLE [dbo].[CreditRating_ErrorCountry] ADD  CONSTRAINT [DF_CreditRating_ErrorCountry_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[CreditRating_ErrorCountry] ADD  CONSTRAINT [DF_CreditRating_ErrorCountry_Count]  DEFAULT ((0)) FOR [Count]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CreditRating_ErrorISIN](
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
GO
ALTER TABLE [dbo].[CreditRating_ErrorISIN] ADD  CONSTRAINT [DF_CreditRating_ErrorISIN_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[CreditRating_ErrorISIN] ADD  CONSTRAINT [DF_CreditRating_ErrorISIN_Count]  DEFAULT ((0)) FOR [Count]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CreditRating_ErrorLEI](
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
GO
ALTER TABLE [dbo].[CreditRating_ErrorLEI] ADD  CONSTRAINT [DF_CreditRating_ErrorLEI_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[CreditRating_ErrorLEI] ADD  CONSTRAINT [DF_CreditRating_ErrorLEI_Count]  DEFAULT ((0)) FOR [Count]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CreditRating_LEI](
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
GO
ALTER TABLE [dbo].[CreditRating_LEI] ADD  CONSTRAINT [DF_CreditRating_LEI_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CreditRating_ScoreMapping](
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
GO
ALTER TABLE [dbo].[CreditRating_ScoreMapping] ADD  CONSTRAINT [DF_RatingScoreMapping_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[CreditRating_ScoreMapping] ADD  CONSTRAINT [DF_RatingScoreMapping_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CreditRating_ScoreMapping_his](
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
CREATE TABLE [dbo].[CreditRating_ScoreMapping_temp](
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
CREATE TABLE [dbo].[CreditRating_Token](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[Token] [nvarchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Type] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
 CONSTRAINT [PK_CreditRatingsToken] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
GO
ALTER TABLE [dbo].[CreditRating_Token] ADD  CONSTRAINT [DF_CreditRatingsToken_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CreditRatingMaster](
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
GO
ALTER TABLE [dbo].[CreditRatingMaster] ADD  CONSTRAINT [DF_RatingAgencyMaster_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[CreditRatingMaster] ADD  CONSTRAINT [DF_RatingAgencyMaster_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Customer](
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
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_Customer_CustomerMark_Match] ON [dbo].[Customer]
(
	[GroupId] ASC,
	[CustomerMark] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
GO
CREATE NONCLUSTERED INDEX [IX_Customer_GroupId] ON [dbo].[Customer]
(
	[GroupId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_Customer_ISIN] ON [dbo].[Customer]
(
	[ISIN] ASC
)
INCLUDE([GroupId]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_Customer_ISIN_Match] ON [dbo].[Customer]
(
	[ISIN] ASC
)
INCLUDE([GroupId])
WHERE ([ISIN] IS NOT NULL AND [ISIN]<>'')
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_Customer_LEI] ON [dbo].[Customer]
(
	[LEI] ASC
)
INCLUDE([GroupId]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_Customer_LEI_Match] ON [dbo].[Customer]
(
	[LEI] ASC
)
INCLUDE([GroupId])
WHERE ([LEI] IS NOT NULL AND [LEI]<>'')
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_Customer_SwiftCode] ON [dbo].[Customer]
(
	[SwiftCode] ASC
)
INCLUDE([GroupId]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
GO
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF
GO
CREATE NONCLUSTERED INDEX [IX_Customer_SwiftCode4_Match] ON [dbo].[Customer]
(
	[SwiftCode4] ASC
)
INCLUDE([GroupId])
WHERE ([SwiftCode] IS NOT NULL AND [SwiftCode]<>'')
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_Customer_Name_Unit] ON [dbo].[Customer]
(
	[CustomerName] ASC,
	[Unit] ASC,
	[CustomerId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
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
CREATE TABLE [dbo].[Customer_his](
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
GO
ALTER TABLE [dbo].[Customer_his] ADD  CONSTRAINT [DF__Customer___SysCr__25083EAB]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'歷史記錄識別碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer_his', @level2type=N'COLUMN',@level2name=N'Log_Id'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Customer_temp](
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
CREATE TABLE [dbo].[DAILY_CIF_TMP](
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
GO
SET ANSI_PADDING OFF
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ExcelTemplate](
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
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_ExcelTemplate] ON [dbo].[ExcelTemplate]
(
	[Excel_Template_Code] ASC,
	[Excel_Template_Filename] ASC,
	[Excel_Sheet_Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
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
CREATE TABLE [dbo].[FeatureDetail](
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
CREATE TABLE [dbo].[FileCenter](
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
CREATE TABLE [dbo].[FileCenter_Downloads](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_FileId] [int] NOT NULL,
	[Downloads] [int] NOT NULL,
 CONSTRAINT [PK_FileCenter_Downloads] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
GO
ALTER TABLE [dbo].[FileCenter_Downloads] ADD  CONSTRAINT [DF_FileCenter_Downloads_Downloads]  DEFAULT ((0)) FOR [Downloads]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FinancialProductMaster](
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
CREATE TABLE [dbo].[FinancialProductMaster_his](
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
GO
ALTER TABLE [dbo].[FinancialProductMaster_his] ADD  CONSTRAINT [DF__Financial__SysCr__2CD37DA5]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'歷史記錄識別碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FinancialProductMaster_his', @level2type=N'COLUMN',@level2name=N'Log_Id'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FinancialProductMaster_temp](
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
CREATE TABLE [dbo].[FinancialRiskFactorData](
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
GO
ALTER TABLE [dbo].[FinancialRiskFactorData] ADD  CONSTRAINT [DF_FinancialRiskFactorData_Create_Date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[FinancialRiskFactorData] ADD  CONSTRAINT [DF_FinancialRiskFactorData_Update_Date]  DEFAULT (getdate()) FOR [Update_date]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FinancialRiskFactorData_his](
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
CREATE TABLE [dbo].[FinancialRiskFactorData_temp](
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
CREATE TABLE [dbo].[FinancialRiskFactorPeriodDay](
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
GO
ALTER TABLE [dbo].[FinancialRiskFactorPeriodDay] ADD  CONSTRAINT [DF_FinancialRiskFactorPeriodDay_Create_Date]  DEFAULT (getdate()) FOR [Create_Date]
GO
ALTER TABLE [dbo].[FinancialRiskFactorPeriodDay] ADD  CONSTRAINT [DF_FinancialRiskFactorPeriodDay_Update_Date]  DEFAULT (getdate()) FOR [Update_Date]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FinancialRiskFactorPeriodDay_his](
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
CREATE TABLE [dbo].[FinancialRiskFactorPeriodDay_temp](
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
CREATE TABLE [dbo].[FL_FLMST_D_MF](
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
CREATE TABLE [dbo].[Flow](
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
CREATE TABLE [dbo].[FlowDetail](
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
CREATE TABLE [dbo].[FlowFileMapping](
	[PK_ID] [int] IDENTITY(1,1) NOT NULL,
	[FlowRecordId] [int] NOT NULL,
	[FileCenterId] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK__Flow_att__F4A24BC22201BC54] PRIMARY KEY CLUSTERED
(
	[PK_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
GO
ALTER TABLE [dbo].[FlowFileMapping] ADD  CONSTRAINT [DF_FlowFileMapping_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FlowForm](
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
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
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
CREATE TABLE [dbo].[FlowForm_LoanMain](
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
CREATE TABLE [dbo].[FlowModifyRecord](
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
GO
ALTER TABLE [dbo].[FlowModifyRecord] ADD  CONSTRAINT [DF_FlowModifyRecord_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FlowRecord](
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
CREATE TABLE [dbo].[FlowUserReset](
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
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FM_FMLINE_D_MF](
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
GO
ALTER TABLE [dbo].[FM_FMLINE_D_MF] ADD  CONSTRAINT [DF_FM_FMLINE_D_MF_Create_Date]  DEFAULT (getdate()) FOR [Create_Date]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ForexRate](
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
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FPEXR_STG](
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
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Global](
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
CREATE TABLE [dbo].[GroupIdCounter](
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
GO
ALTER TABLE [dbo].[GroupIdCounter] ADD  CONSTRAINT [DF_GroupIdCounter_GroupCount]  DEFAULT ((0)) FOR [GroupCount]
GO
ALTER TABLE [dbo].[GroupIdCounter] ADD  CONSTRAINT [DF_GroupIdCounter_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HRIS_Origin](
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
GO
ALTER TABLE [dbo].[HRIS_Origin] ADD  CONSTRAINT [DF_HRIS_Origin_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[i18nText](
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
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[INDUSTRY](
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
CREATE TABLE [dbo].[INDUSTRY_Internal](
	[CustomerId] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[INDCODE] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
 CONSTRAINT [PK_INDUSTRY_Internal] PRIMARY KEY CLUSTERED
(
	[CustomerId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[INDUSTRY_Overseas](
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
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LoanApprovalEntry](
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
GO
ALTER TABLE [dbo].[LoanApprovalEntry] ADD  CONSTRAINT [DF__LoanAppro__SortO__51E5D21A]  DEFAULT ((0)) FOR [SortOrder]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LoanBranchApproveAmountHis](
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
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LoanBranchData](
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
GO
ALTER TABLE [dbo].[LoanBranchData] ADD  CONSTRAINT [DF__LoanBranc__IsFir__4A44B052]  DEFAULT ((1)) FOR [IsFirstTime]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LoanExtApp](
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
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LoanMainUnitData](
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
GO
ALTER TABLE [dbo].[LoanMainUnitData] ADD  CONSTRAINT [DF__LoanMainU__IsNee__5892CFA9]  DEFAULT ((0)) FOR [IsNeedRunLoanUnit]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LS_LSRSA_D_MF](
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
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[m_parameter](
	[system_code] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[field_code] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[field_name] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[field1] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[field2] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[field3] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[field4] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[field5] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[field6] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[field7] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Memo] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_m_parameter] PRIMARY KEY CLUSTERED
(
	[system_code] ASC,
	[field_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
GO
ALTER TABLE [dbo].[m_parameter] ADD  CONSTRAINT [DF_m_parameter_field_name]  DEFAULT ('') FOR [field_name]
GO
ALTER TABLE [dbo].[m_parameter] ADD  CONSTRAINT [DF_m_parameter_field1]  DEFAULT ('') FOR [field1]
GO
ALTER TABLE [dbo].[m_parameter] ADD  CONSTRAINT [DF_m_parameter_field2]  DEFAULT ('') FOR [field2]
GO
ALTER TABLE [dbo].[m_parameter] ADD  CONSTRAINT [DF_m_parameter_field3]  DEFAULT ('') FOR [field3]
GO
ALTER TABLE [dbo].[m_parameter] ADD  CONSTRAINT [DF_m_parameter_field4]  DEFAULT ('') FOR [field4]
GO
ALTER TABLE [dbo].[m_parameter] ADD  CONSTRAINT [DF_m_parameter_field5]  DEFAULT ('') FOR [field5]
GO
ALTER TABLE [dbo].[m_parameter] ADD  CONSTRAINT [DF_m_parameter_field6]  DEFAULT ('') FOR [field6]
GO
ALTER TABLE [dbo].[m_parameter] ADD  CONSTRAINT [DF_m_parameter_field7]  DEFAULT ('') FOR [field7]
GO
ALTER TABLE [dbo].[m_parameter] ADD  CONSTRAINT [DF_m_parameter_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[m_parameter] ADD  CONSTRAINT [DF_m_parameter_Create_user]  DEFAULT ('') FOR [Create_user]
GO
ALTER TABLE [dbo].[m_parameter] ADD  CONSTRAINT [DF_m_parameter_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[m_parameter] ADD  CONSTRAINT [DF_m_parameter_Update_user]  DEFAULT ('') FOR [Update_user]
GO
ALTER TABLE [dbo].[m_parameter] ADD  CONSTRAINT [DF_m_parameter_Memo]  DEFAULT ('') FOR [Memo]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Mail](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[UnitCode] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[List_Name] [nvarchar](60) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Mail_Type] [int] NOT NULL,
	[Subject] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Mail_Content] [nvarchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
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
CREATE TABLE [dbo].[Mail_his](
	[Log_Id] [int] IDENTITY(1,1) NOT NULL,
	[LogType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[PK_Id] [int] NOT NULL,
	[FlowFormId] [int] NOT NULL,
	[UnitCode] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[List_Name] [nvarchar](60) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Mail_Type] [int] NOT NULL,
	[Subject] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Mail_Content] [nvarchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
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
GO
ALTER TABLE [dbo].[Mail_his] ADD  CONSTRAINT [DF__Mail_his__SysCre__0BA79404]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'歷史記錄識別碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Mail_his', @level2type=N'COLUMN',@level2name=N'Log_Id'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Mail_temp](
	[TempId] [int] IDENTITY(1,1) NOT NULL,
	[FlowFormId] [int] NULL,
	[ModifyType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[PK_Id] [int] NULL,
	[UnitCode] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[List_Name] [nvarchar](60) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Mail_Type] [int] NULL,
	[Subject] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Mail_Content] [nvarchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
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
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_Mail_temp_UnitCode_FlowFormId] ON [dbo].[Mail_temp]
(
	[UnitCode] ASC,
	[FlowFormId] ASC
)
INCLUDE([PK_Id],[TempId],[Mail_Type]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
GO
ALTER TABLE [dbo].[Mail_temp] ADD  CONSTRAINT [DF__Mail_temp__SysCr__0E8400AF]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'暫存資料識別碼（流水號）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Mail_temp', @level2type=N'COLUMN',@level2name=N'TempId'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MailCcMapping](
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
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MailCcMapping_his](
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
CREATE TABLE [dbo].[MailCcMapping_temp](
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
GO
CREATE NONCLUSTERED INDEX [IX_MailCcMapping_temp_FK_TempId] ON [dbo].[MailCcMapping_temp]
(
	[FK_TempId] ASC
)
INCLUDE([FK_UserId],[PK_Id]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
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
CREATE TABLE [dbo].[MailCustomCcMapping](
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
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MailCustomCcMapping_his](
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
CREATE TABLE [dbo].[MailCustomCcMapping_temp](
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
CREATE TABLE [dbo].[MailCustomToMapping](
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
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MailCustomToMapping_his](
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
CREATE TABLE [dbo].[MailCustomToMapping_temp](
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
CREATE TABLE [dbo].[MailGroup](
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
CREATE TABLE [dbo].[MailGroupCcMapping](
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
GO
ALTER TABLE [dbo].[MailGroupCcMapping] ADD  CONSTRAINT [DF_MailGroupToCCMapping_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MailGroupCcMapping_his](
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
CREATE TABLE [dbo].[MailGroupCcMapping_temp](
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
GO
CREATE NONCLUSTERED INDEX [IX_MailGroupToCCMapping_temp_FK_TempId] ON [dbo].[MailGroupCcMapping_temp]
(
	[FK_TempId] ASC
)
INCLUDE([MailGroupId],[PK_Id]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
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
CREATE TABLE [dbo].[MailGroupMapping](
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
GO
ALTER TABLE [dbo].[MailGroupMapping] ADD  CONSTRAINT [DF_MailGroupMapping_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MailGroupMapping_his](
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
GO
ALTER TABLE [dbo].[MailGroupMapping_his] ADD  CONSTRAINT [DF__MailGroup__SysCr__33B5855E]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'歷史記錄識別碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MailGroupMapping_his', @level2type=N'COLUMN',@level2name=N'Log_Id'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MailGroupMapping_temp](
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
GO
CREATE NONCLUSTERED INDEX [IX_MailGroupMapping_temp_FK_TempId] ON [dbo].[MailGroupMapping_temp]
(
	[FK_TempId] ASC
)
INCLUDE([MailGroupId],[PK_Id]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
GO
ALTER TABLE [dbo].[MailGroupMapping_temp] ADD  CONSTRAINT [DF__MailGroup__SysCr__2FE4F47A]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'暫存資料識別碼（流水號）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MailGroupMapping_temp', @level2type=N'COLUMN',@level2name=N'TempId'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MailGroupUser](
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
GO
CREATE NONCLUSTERED INDEX [IX_MailGroupUser] ON [dbo].[MailGroupUser]
(
	[PK_Id] ASC,
	[MailGroup_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
GO
ALTER TABLE [dbo].[MailGroupUser] ADD  CONSTRAINT [DF_MailGroupUser_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MailLog](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[UnitCode] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[List_Name] [nvarchar](60) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Mail_Type] [int] NULL,
	[Mail_From] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Subject] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Mail_Content] [nvarchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[IsSystem] [bit] NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
 CONSTRAINT [PK_MailLog] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
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
CREATE TABLE [dbo].[MailLog_CcCustomMapping](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_LogId] [int] NOT NULL,
	[CustomMail] [nvarchar](300) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_MailLog_CcCustomMapping] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MailLog_CcGroupMapping](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_LogId] [int] NOT NULL,
	[FK_MailGroupId] [int] NOT NULL,
 CONSTRAINT [PK_Mail_CcGroupMapping] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MailLog_CcMapping](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_LogId] [int] NOT NULL,
	[FK_UserId] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_MailLog_CcMapping] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MailLog_CustomMapping](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_LogId] [int] NOT NULL,
	[CustomMail] [nvarchar](300) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_MailLog_CustomMapping] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MailLog_FileMapping](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_LogId] [int] NOT NULL,
	[FileName] [nvarchar](300) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[FileExtenstion] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_MailLog_FileMapping] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MailLog_GroupMapping](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_LogId] [int] NOT NULL,
	[FK_MailGroupId] [int] NOT NULL,
 CONSTRAINT [PK_MailLog_GroupMapping] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MailLog_Mapping](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_LogId] [int] NOT NULL,
	[FK_UserId] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_MailLog_Mapping] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MailToMapping](
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
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MailToMapping_his](
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
CREATE TABLE [dbo].[MailToMapping_temp](
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
GO
CREATE NONCLUSTERED INDEX [IX_MailToMapping_temp_FK_TempId] ON [dbo].[MailToMapping_temp]
(
	[FK_TempId] ASC
)
INCLUDE([FK_UserId],[PK_Id]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
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
CREATE TABLE [dbo].[Menu](
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
CREATE TABLE [dbo].[MIS_CRCY_REF](
	[CRCY_CHN_NAME] [char](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CRCY_ENG_NAME] [char](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[CRCY_CODE] [char](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_MIS_CRCY_REF_1] PRIMARY KEY CLUSTERED
(
	[CRCY_CODE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
GO
SET ANSI_PADDING OFF
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MONITORDATA](
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
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_MONITORDATA_ASOFDATE_MARK] ON [dbo].[MONITORDATA]
(
	[AS_OF_DATE] ASC,
	[Mark] ASC,
	[PRODUCT_TYPE] ASC,
	[MATURITY_DATE] ASC
)
INCLUDE([PK_ID],[GROUP_NO],[UNIT_NO],[BRANCH_NO],[Create_DateTime],[Create_user]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_MONITORDATA_ASOFDATE_PAGING] ON [dbo].[MONITORDATA]
(
	[AS_OF_DATE] ASC,
	[GROUP_NO] ASC,
	[UNIT_NO] ASC,
	[BRANCH_NO] ASC
)
INCLUDE([PK_ID],[TRAN_NO],[Mark],[MATURITY_DATE],[PRODUCT_TYPE]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
GO
CREATE NONCLUSTERED INDEX [IX_MONITORDATA_DATE] ON [dbo].[MONITORDATA]
(
	[EXT_DATE] ASC,
	[Year] ASC,
	[Month] ASC,
	[Week] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
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
CREATE TABLE [dbo].[MONITORDATA_his](
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
	[CUR_BOUGHT] [nchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
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
GO
ALTER TABLE [dbo].[MONITORDATA_his] ADD  CONSTRAINT [DF__MONITORDA__SysCr__2C745649]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'歷史記錄識別碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MONITORDATA_his', @level2type=N'COLUMN',@level2name=N'Log_Id'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MONITORDATA_temp](
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
	[CUR_BOUGHT] [nchar](3) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
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
CREATE TABLE [dbo].[News](
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
CREATE TABLE [dbo].[News_his](
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
CREATE TABLE [dbo].[News_temp](
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
CREATE TABLE [dbo].[News_Views](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_NewsId] [int] NOT NULL,
	[Views] [int] NOT NULL,
 CONSTRAINT [PK_News_Views] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NewsCountryType](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_CountryId] [int] NOT NULL,
	[FK_NewsId] [int] NOT NULL,
 CONSTRAINT [PK_NewsCountryType] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NewsCountryType_his](
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
CREATE TABLE [dbo].[NewsCountryType_temp](
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
CREATE TABLE [dbo].[NewsFileMapping](
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
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NewsFileMapping_his](
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
CREATE TABLE [dbo].[NewsFileMapping_temp](
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
CREATE TABLE [dbo].[Notice](
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
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NoticeUser](
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
GO
CREATE NONCLUSTERED INDEX [IX_NoticeUser] ON [dbo].[NoticeUser]
(
	[NoticeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OldData_Quota](
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
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OldData_QuotaWeight](
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
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OldData_Rating](
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
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OS_LNSLMSD_D_MF](
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
GO
ALTER TABLE [dbo].[OS_LNSLMSD_D_MF] ADD  CONSTRAINT [DF_OS_LNSLMSD_D_MF_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[OS_LNSLNKD_D_MF](
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
GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[OS_LNSLNKD_D_MF] ADD  CONSTRAINT [DF_OS_LNSLNKD_D_MF_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OS_LNSMSTD_D_MF](
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
CREATE TABLE [dbo].[OS_LNSSECD_D_MF](
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
GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[OS_LNSSECD_D_MF] ADD  CONSTRAINT [DF_OS_LNSSECD_D_MF_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OSBDKF02_MF](
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
GO
ALTER TABLE [dbo].[OSBDKF02_MF] ADD  CONSTRAINT [DF_OSBDKF02_MF_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'交易金額新的' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'OSBDKF02_MF', @level2type=N'COLUMN',@level2name=N'OSBDKF02_BALANCE_AMT'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OSFXKF02_MF](
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
GO
ALTER TABLE [dbo].[OSFXKF02_MF] ADD  CONSTRAINT [DF_OSFXKF02_MF_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OSISKF02_MF](
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
GO
ALTER TABLE [dbo].[OSISKF02_MF] ADD  CONSTRAINT [DF_OSISKF02_MF_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OSMMKF02_MF](
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
GO
ALTER TABLE [dbo].[OSMMKF02_MF] ADD  CONSTRAINT [DF_OSMMKF02_MF_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Permissions](
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
CREATE TABLE [dbo].[Permissions_his](
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
CREATE TABLE [dbo].[Permissions_Query](
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
CREATE TABLE [dbo].[Permissions_Query_his](
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
GO
ALTER TABLE [dbo].[Permissions_Query_his] ADD  CONSTRAINT [DF_Permissions_Query_his_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[Permissions_Query_his] ADD  CONSTRAINT [DF_Permissions_Query_his_SysCreateDate]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Post](
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
GO
ALTER TABLE [dbo].[Post] ADD  CONSTRAINT [DF_Post_Contents]  DEFAULT ('') FOR [Contents]
GO
ALTER TABLE [dbo].[Post] ADD  CONSTRAINT [DF_Post_Url]  DEFAULT ('') FOR [Url]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Post_his](
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
CREATE TABLE [dbo].[Post_temp](
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
CREATE TABLE [dbo].[Post_Views](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_PostId] [int] NOT NULL,
	[Views] [int] NOT NULL,
 CONSTRAINT [PK_Post_Views] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PostCountryType](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_CountryId] [int] NOT NULL,
	[FK_PostId] [int] NOT NULL,
 CONSTRAINT [PK_PostCountryType] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PostCountryType_his](
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
CREATE TABLE [dbo].[PostCountryType_temp](
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
CREATE TABLE [dbo].[PostFileMapping](
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
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PostFileMapping_his](
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
CREATE TABLE [dbo].[PostFileMapping_temp](
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
CREATE TABLE [dbo].[ProductMaster](
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
CREATE TABLE [dbo].[QuickLink](
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
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[QuotaBank_D](
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
CREATE TABLE [dbo].[QuotaBank_D_Form_AllData](
	[Pk_Id] [int] IDENTITY(1,1) NOT NULL,
	[QuotaFormAllData_MId] [int] NOT NULL,
	[UnitCode] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[QuotaAmount] [int] NOT NULL,
 CONSTRAINT [PK_QuotaBank_D_Form_AllData] PRIMARY KEY CLUSTERED
(
	[Pk_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'暫存資料識別碼（流水號）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QuotaBank_D_Form_AllData', @level2type=N'COLUMN',@level2name=N'Pk_Id'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[QuotaBank_D_his](
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
CREATE TABLE [dbo].[QuotaBank_D_temp](
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
CREATE TABLE [dbo].[QuotaBank_D_Week](
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
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_QuotaBank_D_Week] ON [dbo].[QuotaBank_D_Week]
(
	[Year] ASC,
	[Month] ASC,
	[Week] ASC,
	[CountryId] ASC,
	[UnitCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
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
CREATE TABLE [dbo].[QuotaBank_Form_Data](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FlowFormId] [int] NOT NULL,
	[TotalNetWorthUSD] [decimal](18, 2) NOT NULL,
	[SysCreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_QuotaBank_Form_Data] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
GO
ALTER TABLE [dbo].[QuotaBank_Form_Data] ADD  CONSTRAINT [DF_QuotaBank_Form_Data_SysCreateDate]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[QuotaBank_Form_ParentWeight](
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
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'暫存資料識別碼（流水號）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QuotaBank_Form_ParentWeight', @level2type=N'COLUMN',@level2name=N'PK_Id'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[QuotaBank_M](
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
CREATE TABLE [dbo].[QuotaBank_M_Form_AllData](
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
CREATE TABLE [dbo].[QuotaBank_M_his](
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
CREATE TABLE [dbo].[QuotaBank_M_temp](
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
CREATE TABLE [dbo].[QuotaBank_M_Week](
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
CREATE TABLE [dbo].[QuotaBank_Weight](
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
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[QuotaBank_Weight_Form_AllData](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[QuotaD_Form_AllDataId] [int] NOT NULL,
	[WeightPercent] [int] NOT NULL,
	[QuotaAmount] [int] NOT NULL,
 CONSTRAINT [PK_QuotaBank_Weight_Form_AllData] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'主表暫存資料外鍵' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QuotaBank_Weight_Form_AllData', @level2type=N'COLUMN',@level2name=N'QuotaD_Form_AllDataId'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[QuotaBank_Weight_his](
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
CREATE TABLE [dbo].[QuotaBank_Weight_temp](
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
CREATE TABLE [dbo].[QuotaBank_Weight_Week](
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
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_QuotaBank_Weight_Week] ON [dbo].[QuotaBank_Weight_Week]
(
	[Year] ASC,
	[Month] ASC,
	[Week] ASC,
	[UnitCode] ASC,
	[CountryWeightId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
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
CREATE TABLE [dbo].[RatingRatioMaster](
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
GO
CREATE NONCLUSTERED INDEX [IX_RatingRatioMaster] ON [dbo].[RatingRatioMaster]
(
	[Year] ASC,
	[RatingLevel] ASC,
	[HasFCBBranch] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
GO
ALTER TABLE [dbo].[RatingRatioMaster] ADD  CONSTRAINT [DF_RatingRatioMaster_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[RatingRatioMaster] ADD  CONSTRAINT [DF_RatingRatioMaster_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RatingRatioMaster_his](
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
CREATE TABLE [dbo].[RatingRatioMaster_temp](
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
CREATE TABLE [dbo].[RatingRatioMaster_Week](
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
GO
CREATE NONCLUSTERED INDEX [IX_RatingRatioMaster_Week] ON [dbo].[RatingRatioMaster_Week]
(
	[Year] ASC,
	[Month] ASC,
	[Week] ASC,
	[RatingLevel] ASC,
	[HasFCBBranch] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
GO
ALTER TABLE [dbo].[RatingRatioMaster_Week] ADD  CONSTRAINT [DF_RatingRatioMaster_Week_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[RatingRatioMaster_Week] ADD  CONSTRAINT [DF_RatingRatioMaster_Week_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RatingRatioMasterBase](
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
GO
ALTER TABLE [dbo].[RatingRatioMasterBase] ADD  CONSTRAINT [DF_RatingRatioMasterBase_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[RatingRatioMasterBase] ADD  CONSTRAINT [DF_RatingRatioMasterBase_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RiskLineD](
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
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RiskLineO](
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
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Role](
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
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_Role_FK_Unit_Code] ON [dbo].[Role]
(
	[FK_Unit_Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
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
CREATE TABLE [dbo].[Role_his](
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
CREATE TABLE [dbo].[Role_Position_Mapping](
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
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_Role_Position_Mapping] ON [dbo].[Role_Position_Mapping]
(
	[TitleCode] ASC,
	[FK_Branch_Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_Role_Position_Mapping_1] ON [dbo].[Role_Position_Mapping]
(
	[TitleCode] ASC,
	[FK_Department_Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
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
CREATE TABLE [dbo].[Role_Position_Mapping_his](
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
CREATE TABLE [dbo].[Role_User_Mapping](
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
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_Role_User_Mapping] ON [dbo].[Role_User_Mapping]
(
	[FK_User_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
GO
CREATE NONCLUSTERED INDEX [IX_Role_User_Mapping_1] ON [dbo].[Role_User_Mapping]
(
	[FK_Role_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
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
CREATE TABLE [dbo].[Role_User_Mapping_his](
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
CREATE TABLE [dbo].[RPA](
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
CREATE TABLE [dbo].[RPA_his](
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
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RPA_Source](
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
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RPA_temp](
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
CREATE TABLE [dbo].[RPA_Views](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_RPAId] [int] NOT NULL,
	[Views] [int] NOT NULL,
 CONSTRAINT [PK_RPA_Views] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
GO
ALTER TABLE [dbo].[RPA_Views] ADD  CONSTRAINT [DF_RPA_Views_Views]  DEFAULT ((0)) FOR [Views]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RPACountryType](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_RPAId] [int] NOT NULL,
	[FK_CountryId] [int] NOT NULL,
 CONSTRAINT [PK_RPACountryType] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RPACountryType_his](
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
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RPACountryType_temp](
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
CREATE TABLE [dbo].[RPAFileMapping](
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
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RPAFileMapping_his](
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
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RPAFileMapping_temp](
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
CREATE TABLE [dbo].[ScheduleJobs](
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
CREATE TABLE [dbo].[ScheduleJobs_his](
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
CREATE TABLE [dbo].[ScheduleJobs_RECORD](
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
CREATE TABLE [dbo].[ScheduleJobs_temp](
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
CREATE TABLE [dbo].[SysData](
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
CREATE TABLE [dbo].[SysLog](
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
GO
SET ANSI_PADDING OFF
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TempModifyRecord](
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
GO
ALTER TABLE [dbo].[TempModifyRecord] ADD  CONSTRAINT [DF_TempModifyRecord_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Title](
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
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Title] ON [dbo].[Title]
(
	[TitleCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
GO
ALTER TABLE [dbo].[Title] ADD  CONSTRAINT [DF_Title_seq]  DEFAULT ((1)) FOR [seq]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TitleMapping](
	[TitleCode] [nvarchar](1) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[TitleId] [int] NULL,
	[TitleName] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL
) ON [NCRMS_TAB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Users](
	[UserId] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[UserName] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
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
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Users] ON [dbo].[Users]
(
	[UserId] ASC,
	[UserName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
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
CREATE TABLE [dbo].[Users_log](
	[logType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[UserId] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[UserName] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
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
CREATE TABLE [dbo].[UserTextLibrary](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Text] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_TextLibrary] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_UserTextLibrary] ON [dbo].[UserTextLibrary]
(
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserToken](
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
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_UserToken] ON [dbo].[UserToken]
(
	[Token] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
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
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
Create FUNCTION [dbo].[getNUM]
(@date1 as datetime)
RETURNS char(15)
BEGIN
declare @yyyy char(2),@mm char(2),@dd char(2),@hh char(2),@minu char(2),@ss char(2),@mill char(3),@str char(15)

SET @yyyy=RIGHT(DATENAME ( year , @date1 ),2)
SET       @mm=LTRIM(rtrim(month ( @date1 )))
SET       @dd=LTRIM(rtrim(DATENAME ( day , @date1 )) )
SET       @hh=LTRIM(rtrim(DATENAME ( hour , @date1 ))  )
SET       @minu=LTRIM(rtrim(DATENAME ( minute ,@date1 )))
SET       @ss=LTRIM(rtrim(DATENAME ( second , @date1)))
SET       @mill=LTRIM(rtrim(DATENAME ( millisecond , @date1 )))



REturn @YYYY+RTRIM(REPLICATE('0', 2-LEN(@MM)) +@MM)+RTRIM(REPLICATE('0', 2-LEN(@DD)) +@DD)+RTRIM(REPLICATE('0', 2-LEN(@HH)) +@HH)+RTRIM(REPLICATE('0', 2-LEN(@minu)) +@minu)+RTRIM(REPLICATE('0', 2-LEN(@ss)) +@ss)+RTRIM(REPLICATE('0', 3-LEN(@mill)) +@mill)

END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[RoleUserMatch]
AS
SELECT          u.UserId, rum.FK_Role_Id AS RoleId
FROM              Users u INNER JOIN
                            Role_User_Mapping rum ON rum.FK_User_Id = u.UserId
UNION
SELECT          u.UserId, rpm.FK_Role_Id AS RoleId
FROM              Users u INNER JOIN
                            Role_Position_Mapping rpm ON rpm.TitleCode = u.TitleCode AND ((rpm.FK_Branch_Code IS NOT NULL AND
                            rpm.FK_Branch_Code = u.BranchCode) OR
                            (rpm.FK_Branch_Code IS NULL AND rpm.FK_Department_Code = u.DepartmentCode));
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties =
   Begin PaneConfigurations =
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane =
      Begin Origin =
         Top = 0
         Left = 0
      End
      Begin Tables =
      End
   End
   Begin SQLPane =
   End
   Begin DataPane =
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane =
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'RoleUserMatch'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'RoleUserMatch'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[ufn_CodePrefix] (@code nvarchar(50))
RETURNS nvarchar(50)
AS
BEGIN
	RETURN　REPLACE(TRANSLATE(@code, 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz','@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'), '@', '')
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Allen
-- Create date: 20250908
-- Description:	傳入產品別英文代號，回傳ProductMaster.ProductCode
-- =============================================
CREATE FUNCTION [dbo].[ufn_FinancialRiskFactor](
	@DAY AS INT,@ProductCode as nvarchar(20),@CUR_BOUGHT AS NVARCHAR(3) = '',@CUR_SOLD AS NVARCHAR(3) = '')
RETURNS decimal(10,2)
--RETURNS NVARCHAR(20)
AS
BEGIN
	DECLARE @MAXID AS INT -- 有資料的時間最大ID
	DECLARE @MINID as int -- 有資料的時間最小ID
	DECLARE @MAPPING_DAYID AS INT
	DECLARE @ProductID AS INT
	DECLARE @RISKFACTOR AS DECIMAL(10,2)
	DECLARE @MAXDAY AS INT
	--取得目前系統最大上限DAY
	SELECT @MAXDAY = MAX(MaxDays)
	FROM FinancialRiskFactorPeriodDay
	--如果傳入的DAY大於系統最高上限，則轉換為最大上限DAY
	IF @DAY > @MAXDAY
		SET @DAY = @MAXDAY

	-- 如果是匯率風險係數，買幣別與賣幣別可以對調組成ProductCode，若找不到就指定為OTHERS
	IF @CUR_BOUGHT <> '' OR @CUR_SOLD <> '' BEGIN
		SET @ProductCode = ISNULL((
			SELECT ProductCode
			FROM FinancialProductMaster
			WHERE ProductCode IN(@CUR_BOUGHT+'/'+@CUR_SOLD,@CUR_SOLD+'/'+@CUR_BOUGHT)),'OTHERS')
	END
	--取得日期間對應的ID
	SELECT @MAPPING_DAYID = PK_ID
	FROM FinancialRiskFactorPeriodDay
	WHERE (CASE WHEN @DAY > 0 THEN @DAY ELSE 0 END) BETWEEN MinDays AND MaxDays
	--取得該項目有設定風險係數的最小時間範圍ID 與最大時間範圍ID
	SELECT @ProductID = FK_ProductID, @MINID = MIN(FK_PeriodID),@MAXID = MAX(FK_PeriodID)
	FROM FinancialRiskFactorData a
	inner join FinancialProductMaster b on a.FK_ProductID = b.PK_ID AND B.ProductCode = @ProductCode
	GROUP BY FK_ProductID

	--如果匹配不到@PRODUCT_ID IS NULL，代表PRODUCT_ID沒對應到，直接回傳NULL
	IF @ProductID IS NULL
		RETURN NULL

	SELECT @RISKFACTOR = RiskFactor
	FROM FinancialRiskFactorData
	WHERE FK_PeriodID = @MAPPING_DAYID AND FK_ProductID = @ProductID

	IF @RISKFACTOR IS NULL BEGIN
		-- 小於有設定天數按照最小有設定的天數算，大於最大有設定的天數按照最大有設定的天數算
		IF @MAPPING_DAYID < @MINID BEGIN
			SET @MAPPING_DAYID = @MINID
		END
		ELSE IF @MAPPING_DAYID > @MAXID BEGIN
			SET @MAPPING_DAYID = @MAXID
		END
	END
	SELECT @RISKFACTOR = RiskFactor
	FROM FinancialRiskFactorData
	WHERE FK_PeriodID = @MAPPING_DAYID AND FK_ProductID = @ProductID
	RETURN @RISKFACTOR
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Allen
-- Create date: 2026/03/26
-- Description:	填寫年月週，取得當週最後一天（週五）
-- =============================================
CREATE FUNCTION [dbo].[ufn_GetLastDateOfWeek]
(
    @Year INT,
    @Month INT,
    @Week INT
)
RETURNS DATE
AS
BEGIN
    DECLARE @FirstDayOfMonth DATE = CAST(@Year AS VARCHAR(4)) + '-' + RIGHT('0' + CAST(@Month AS VARCHAR(2)), 2) + '-01'

    -- 0=週六, 1=週日...6=週五（以週六為每週第一天）
    DECLARE @FirstDayWeekday INT = (DATEDIFF(DAY, '19000106', @FirstDayOfMonth) % 7)

    DECLARE @FirstSaturday DATE
    DECLARE @Result DATE

    IF @FirstDayWeekday = 0
        SET @FirstSaturday = @FirstDayOfMonth  -- 月初剛好是週六
    ELSE
        SET @FirstSaturday = DATEADD(DAY, 7 - @FirstDayWeekday, @FirstDayOfMonth)  -- 下一個週六

    IF @Week = 1
    BEGIN
        -- 第1週結束在第一個週六前的週五
        IF @FirstDayWeekday = 0
            -- 月初是週六，第1週週五 = 月初 + 6天
            SET @Result = DATEADD(DAY, 6, @FirstDayOfMonth)
        ELSE
            -- 月初不是週六，第1週週五 = 第一個週六的前一天
            SET @Result = DATEADD(DAY, -1, @FirstSaturday)
    END
    ELSE
    BEGIN
        -- 第N週的週六 = 第一個週六 + (N-2) * 7
        DECLARE @WeekStartSaturday DATE = DATEADD(DAY, (@Week - 2) * 7, @FirstSaturday)
        -- 當週週五 = 當週週六 + 6天
        SET @Result = DATEADD(DAY, 6, @WeekStartSaturday)
    END

    -- 避免超過當月最後一天
    DECLARE @LastDayOfMonth DATE = EOMONTH(@FirstDayOfMonth)
    IF @Result > @LastDayOfMonth
        SET @Result = @LastDayOfMonth

    RETURN @Result
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[ufn_GetNumFromFileName]
(
    @FileName NVARCHAR(500),
    @ContinuousOnly BIT = 1
)
RETURNS VARCHAR(20)
AS
BEGIN
    DECLARE @Len INT = LEN(@FileName)
    DECLARE @i INT = @Len
    DECLARE @Char NCHAR(1)
    DECLARE @NumericPart NVARCHAR(20) = ''
    DECLARE @FoundDigit BIT = 0  -- 是否已找到第一個數字

    WHILE @i > 0
    BEGIN
        SET @Char = SUBSTRING(@FileName, @i, 1)

        IF @Char LIKE '[0-9]'
        BEGIN
            SET @FoundDigit = 1
            SET @NumericPart = @Char + @NumericPart
        END
        ELSE IF @FoundDigit = 1 AND @ContinuousOnly = 1
            BREAK  -- 已收集數字後遇到非數字，停止

        SET @i = @i - 1
    END

    RETURN @NumericPart
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[ufn_GetWeekOfMonth] (@DateTime AS Date)
RETURNS INT
AS
BEGIN
    DECLARE @FirstDayOfMonth DATE = DATEADD(DAY, 1 - DAY(@DateTime), @DateTime)
    DECLARE @CurrentDate DATE = CAST(@DateTime AS DATE)

    -- '19000106' 是已知的週六，用來計算以週六為基準的星期幾
    -- 0=週六, 1=週日, 2=週一, 3=週二, 4=週三, 5=週四, 6=週五
    DECLARE @FirstDayWeekday INT = (DATEDIFF(DAY, '19000106', @FirstDayOfMonth) % 7)

    -- 計算當前日期距離月初有幾天
    DECLARE @DaysFromMonthStart INT = DATEDIFF(DAY, @FirstDayOfMonth, @CurrentDate)

    DECLARE @WeekNumber INT

    IF @FirstDayWeekday = 0
    BEGIN
        -- 月初剛好是週六，正常計算
        SET @WeekNumber = (@DaysFromMonthStart / 7) + 1
    END
    ELSE
    BEGIN
        -- 月初是週日~週五，先算到本週週五還剩幾天
        -- 距離本週週五的天數 = 6 - @FirstDayWeekday
        DECLARE @DaysToFriday INT = 6 - @FirstDayWeekday

        IF @DaysFromMonthStart <= @DaysToFriday
            SET @WeekNumber = 1  -- 還在第1週（不完整週）
        ELSE
            -- 從下一個週六開始算第2週
            SET @WeekNumber = ((@DaysFromMonthStart - @DaysToFriday - 1) / 7) + 2
    END

    RETURN @WeekNumber
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[ufn_MatchingCustomerGroupIds]
(
    @PK_Id INT,                     -- 排除自己；沒有自身PK_Id（如temp階段）可傳NULL
    @CustomerName NVARCHAR(500),
    @Unit NVARCHAR(50),
    @SwiftCode NVARCHAR(20),
    @LEI NVARCHAR(20),
    @ISIN NVARCHAR(12),
    @CustomerMark NVARCHAR(50) = NULL
)
RETURNS TABLE
AS
RETURN
(
    -- 歸戶五鍵值比對規則的唯一定義（single source of truth）。
    -- 給定一筆客戶的描述欄位，回傳 Customer 表中所有「視為同一客戶」的既有記錄
    -- (PK_Id, GroupId)。任一鍵值成立即算相符：
    --   1) CustomerName + Unit 皆相同
    --   2) SwiftCode 前四碼相同（比對持久化計算欄位 SwiftCode4，可走索引Seek）
    --   3) LEI 完全相同
    --   4) ISIN 完全相同
    --   5) CustomerMark（客戶自訂歸戶標記）完全相同
    SELECT c.PK_Id, c.GroupId
    FROM Customer c
    WHERE (@PK_Id IS NULL OR c.PK_Id <> @PK_Id)
      AND c.CustomerName = @CustomerName AND c.Unit = @Unit
      AND NULLIF(@CustomerName, N'') IS NOT NULL AND NULLIF(@Unit, N'') IS NOT NULL

    UNION

    SELECT c.PK_Id, c.GroupId
    FROM Customer c
    WHERE (@PK_Id IS NULL OR c.PK_Id <> @PK_Id)
      AND c.SwiftCode4 = LEFT(@SwiftCode, 4)
      AND NULLIF(c.SwiftCode4, N'') IS NOT NULL AND NULLIF(LEFT(@SwiftCode, 4), N'') IS NOT NULL

    UNION

    SELECT c.PK_Id, c.GroupId
    FROM Customer c
    WHERE (@PK_Id IS NULL OR c.PK_Id <> @PK_Id)
      AND c.LEI = @LEI
      AND NULLIF(c.LEI, N'') IS NOT NULL AND NULLIF(@LEI, N'') IS NOT NULL

    UNION

    SELECT c.PK_Id, c.GroupId
    FROM Customer c
    WHERE (@PK_Id IS NULL OR c.PK_Id <> @PK_Id)
      AND c.ISIN = @ISIN
      AND NULLIF(c.ISIN, N'') IS NOT NULL AND NULLIF(@ISIN, N'') IS NOT NULL

    UNION

    SELECT c.PK_Id, c.GroupId
    FROM Customer c
    WHERE (@PK_Id IS NULL OR c.PK_Id <> @PK_Id)
      AND c.CustomerMark = @CustomerMark
      AND NULLIF(c.CustomerMark, N'') IS NOT NULL AND NULLIF(@CustomerMark, N'') IS NOT NULL
);
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[ufn_table_GetCountryRating](@Date DATE)
RETURNS TABLE
AS
RETURN
(
    WITH RatingData AS (
        SELECT a.FK_Country_Id, b.InternalRatingLevel, a.RatingOutlook,
            ROW_NUMBER() OVER (PARTITION BY a.FK_Country_Id ORDER BY b.InternalRatingLevel) AS rn,
            COUNT(*) OVER (PARTITION BY a.FK_Country_Id) AS RatingCount
        FROM (
            SELECT FK_Country_Id, FK_RatingAgency_Id, AgencyRating, RatingOutlook,
                ROW_NUMBER() OVER (PARTITION BY FK_Country_Id, FK_RatingAgency_Id ORDER BY Create_date DESC) AS agency_rn
            FROM CreditRating_Country
            WHERE CAST(Create_date AS DATE) <= @Date
        ) a
        INNER JOIN CreditRating_ScoreMapping b
            ON a.FK_RatingAgency_Id = b.FK_RatingAgencyID
            AND a.AgencyRating = b.AgencyRating
        WHERE a.agency_rn = 1
    ),
    RatingCalculation AS (
		SELECT FK_Country_Id,
			CASE
				WHEN RatingCount = 3 THEN (SELECT InternalRatingLevel FROM RatingData rd2 WHERE rn = 2 AND rd2.FK_Country_Id = rd.FK_Country_Id)
				WHEN RatingCount >= 1 THEN MAX(InternalRatingLevel)
				ELSE 5
			END AS FinalRating,
			MIN(
				CASE
					WHEN RatingOutlook IN ('Positive', 'POS', 'Rating Outlook Positive') THEN 1
					WHEN RatingOutlook IN ('Stable', 'STA', 'Rating Outlook Stable')     THEN 0
					WHEN RatingOutlook IN ('Negative', 'NEG', 'Rating Outlook Negative') THEN -1
					ELSE NULL
				END
			) AS Score
		FROM RatingData rd
		GROUP BY FK_Country_Id, RatingCount
	)
    SELECT
		CASE WHEN c.CountryCode2 = 'S9' THEN 1
			 ELSE ISNULL(rc.FinalRating, 5)
		END AS FinalRating,
		c.PK_Id AS FK_Country_Id,
		ISNULL(rc.Score, 0) AS Score
	FROM CountryMaster c
	LEFT JOIN RatingCalculation rc ON c.PK_Id = rc.FK_Country_Id
)
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[ufn_table_GetMonitorDataLimitAmount] (@Dates NVARCHAR(MAX))
RETURNS TABLE
AS
RETURN
(
	with temp as (
		select *
			from MONITORDATA a
			WHERE CONVERT(DATE,EXT_DATE) IN (
										 SELECT CONVERT(DATE,value)
										 FROM string_split(@Dates,',')
										 where LTRIM(RTRIM(value)) <> '')
	),
	-- 相同額度 分行 核准編號 轉檔日期  核准額度只算一次 第一筆要給值 其他給0
	temp2 as (
		select  *,
				CASE WHEN ROW_NUMBER() OVER (PARTITION BY BRANCH_NO,ISNULL(NULLIF(LTRIM(RTRIM(PERMIT_NO)), ''), CAST(PK_Id AS NVARCHAR(20)))
														,COUNTRY_COD,TO_USD_LIMIT,EXT_DATE ORDER BY PK_Id) = 1
				THEN TO_USD_LIMIT
				ELSE 0
				END SUM_TO_USD_LIMIT
		from temp
	),
	temp3 as (
		select *,
			ROW_NUMBER() OVER(
				PARTITION BY BRANCH_NO,ISNULL(NULLIF(LTRIM(RTRIM(PERMIT_NO)), ''), CAST(PK_Id AS NVARCHAR(20))),EXT_DATE ORDER BY PK_Id
				) AS rn_final,
			SUM(SUM_TO_USD_LIMIT) OVER (
				PARTITION BY BRANCH_NO,ISNULL(NULLIF(LTRIM(RTRIM(PERMIT_NO)), ''), CAST(PK_Id AS NVARCHAR(20))),EXT_DATE
				) AS GroupTotal
		FROM temp2
	)
	SELECT PK_ID,GROUP_NO,UNIT_NO,BRANCH_NO,TX_DATE,AS_OF_DATE,PRODUCT_TYPE,TRAN_NO,CUSTOMER_ID,CUSTOMER_NAME,
			COUNTRY_COD,CURENCY_COD,TRAN_AMOUNT,TO_USD_AMT,PERMIT_NO,LIMIT,LIMIT_COD,TO_USD_LIMIT,
			CASE WHEN rn_final = 1 THEN
				CASE WHEN TOP_Limit_USD_Amount IS NOT NULL AND GroupTotal > TOP_Limit_USD_Amount
				then TOP_Limit_USD_Amount
				else GroupTotal
				end
			else 0
			end as SUM_TO_USD_LIMIT,
			REVOLVE_MK,FIL9,
			SOURCE,LIMIT_MATURITY,MATURITY_DATE,INDUSTRY,INDUSTRY_Type,PRODUCT_CODE,CUR_BOUGHT,CUR_SOLD,RISKFACTOR,
			WEIGHTS,Create_DateTime,YEAR,MONTH,Week,EXT_DATE,TOP_Limit_USD_Amount
	FROM temp3
)
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Allen
-- Create date: 20251003
-- Description:	取得部門單位
-- =============================================
CREATE FUNCTION [dbo].[ufn_table_GetUnitName](@UnitCode nvarchar(20))
RETURNS @TABLE TABLE(
	UNITCODE  NVARCHAR(120),
	UNITNAME_TN  NVARCHAR(120),
	UNITNAME_CN  NVARCHAR(120),
	UNITNAME_JP  NVARCHAR(120),
	UNITNAME_EN  NVARCHAR(120)
) AS BEGIN
	INSERT @TABLE
	SELECT @UnitCode,GroupName_TN,GroupName_CN,GroupName_JP,GroupName_EN
	FROM BankGroup WHERE GroupCode = @UnitCode
	UNION ALL
	SELECT @UnitCode,UnitName_TN,UnitName_CN,UnitName_JP,UnitName_EN
	FROM BankUnit WHERE UnitCode = @UnitCode
	UNION ALL
	SELECT @UnitCode,BankName_TN,BankName_CN,BankName_JP,BankName_EN
	FROM BankBranch WHERE BankCode = @UnitCode

	IF NOT EXISTS (SELECT 1 FROM @TABLE)
	BEGIN
		INSERT @TABLE
		SELECT TOP 1 @UnitCode,departmentName,departmentName,departmentName,departmentName
		FROM Users
		WHERE departmentCode = @UnitCode
	END

	RETURN
END;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_CreateHistoryHasFlowTable]
    @TableName NVARCHAR(128)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @HistoryTableName NVARCHAR(128) = @TableName + '_his';
    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @ColumnDefinitions NVARCHAR(MAX) = '';
    DECLARE @SchemaName NVARCHAR(128) = 'dbo';
    DECLARE @ObjectId INT;

    -- 檢查原始表是否存在
    IF NOT EXISTS (
        SELECT 1
        FROM INFORMATION_SCHEMA.TABLES
        WHERE TABLE_NAME = @TableName
          AND TABLE_SCHEMA = @SchemaName
    )
    BEGIN
        RAISERROR('原始表 %s 不存在', 16, 1, @TableName);
        RETURN;
    END

    -- 取得 Object ID
    SET @ObjectId = OBJECT_ID(@SchemaName + '.' + @TableName);

    IF @ObjectId IS NULL
    BEGIN
        RAISERROR('無法取得表 %s 的 Object ID', 16, 1, @TableName);
        RETURN;
    END

    -- 檢查歷史表是否已存在
    IF EXISTS (
        SELECT 1
        FROM INFORMATION_SCHEMA.TABLES
        WHERE TABLE_NAME = @HistoryTableName
          AND TABLE_SCHEMA = @SchemaName
    )
    BEGIN
        RAISERROR('歷史表 %s 已經存在', 16, 1, @HistoryTableName);
        RETURN;
    END

    -- 檢查 FlowForm 表是否存在
    IF NOT EXISTS (
        SELECT 1
        FROM INFORMATION_SCHEMA.TABLES
        WHERE TABLE_NAME = 'FlowForm'
          AND TABLE_SCHEMA = @SchemaName
    )
    BEGIN
        RAISERROR('FlowForm 表不存在，無法建立外鍵', 16, 1);
        RETURN;
    END

    -- 取得原始表的欄位定義（包含 NULL/NOT NULL 和預設值）
    SELECT @ColumnDefinitions = @ColumnDefinitions +
        '    ' + QUOTENAME(c.COLUMN_NAME) + ' ' +
        c.DATA_TYPE +
        CASE
            WHEN c.DATA_TYPE IN ('varchar', 'char', 'nvarchar', 'nchar')
            THEN '(' + CASE WHEN c.CHARACTER_MAXIMUM_LENGTH = -1
                           THEN 'MAX'
                           ELSE CAST(c.CHARACTER_MAXIMUM_LENGTH AS VARCHAR(10))
                       END + ')'
            WHEN c.DATA_TYPE IN ('decimal', 'numeric')
            THEN '(' + CAST(c.NUMERIC_PRECISION AS VARCHAR(10)) + ',' +
                      CAST(c.NUMERIC_SCALE AS VARCHAR(10)) + ')'
            WHEN c.DATA_TYPE IN ('datetime2', 'time', 'datetimeoffset')
            THEN '(' + CAST(c.DATETIME_PRECISION AS VARCHAR(10)) + ')'
            ELSE ''
        END +
        -- 保留原始表的 NULL/NOT NULL 設定
        CASE WHEN c.IS_NULLABLE = 'NO' THEN ' NOT NULL' ELSE ' NULL' END +
        -- 加入預設值
        CASE
            WHEN dc.definition IS NOT NULL
            THEN ' DEFAULT ' + dc.definition
            ELSE ''
        END +
        ',' + CHAR(13) + CHAR(10)
    FROM INFORMATION_SCHEMA.COLUMNS c
    LEFT JOIN sys.columns sc
        ON sc.object_id = @ObjectId
        AND sc.name = c.COLUMN_NAME
    LEFT JOIN sys.default_constraints dc
        ON dc.parent_object_id = @ObjectId
        AND dc.parent_column_id = sc.column_id
    WHERE c.TABLE_NAME = @TableName
      AND c.TABLE_SCHEMA = @SchemaName
    ORDER BY c.ORDINAL_POSITION;

    -- 檢查欄位定義是否為空
    IF LEN(@ColumnDefinitions) = 0
    BEGIN
        RAISERROR('錯誤: 無法取得表 %s 的欄位定義', 16, 1, @TableName);
        RETURN;
    END

    -- 移除最後一個逗號和換行
    SET @ColumnDefinitions = LEFT(@ColumnDefinitions, LEN(@ColumnDefinitions) - 3);

    -- 建立歷史表的 SQL
    SET @SQL =
        'CREATE TABLE ' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@HistoryTableName) + ' (' + CHAR(13) + CHAR(10) +
        '    [Log_id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,' + CHAR(13) + CHAR(10) +
        '    [LogType] NVARCHAR(10) NOT NULL,' + CHAR(13) + CHAR(10) +
        '    [FlowFormId] INT NULL,' + CHAR(13) + CHAR(10) +
        @ColumnDefinitions + ',' + CHAR(13) + CHAR(10) +
        '    [SysCreateDate] DATETIME NOT NULL DEFAULT GETDATE(),' + CHAR(13) + CHAR(10) +
        '    [SysCreateUser] NVARCHAR(100) NOT NULL,' + CHAR(13) + CHAR(10) +
        '    CONSTRAINT [FK_' + @HistoryTableName + '_FlowForm] FOREIGN KEY ([FlowFormId]) ' + CHAR(13) + CHAR(10) +
        '        REFERENCES ' + QUOTENAME(@SchemaName) + '.[FlowForm]([PK_ID])' + CHAR(13) + CHAR(10) +
        ');';

    BEGIN TRY
        -- 執行建立表的 SQL
        EXEC sp_executesql @SQL;
        PRINT '✓ 成功建立歷史表: ' + @HistoryTableName;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('建立歷史表失敗: %s', 16, 1, @ErrorMessage);
        RETURN;
    END CATCH

    -- ========== 加入欄位註釋 ==========
    BEGIN TRY
        EXEC sys.sp_addextendedproperty
            @name = N'MS_Description',
            @value = N'歷史記錄識別碼',
            @level0type = N'SCHEMA', @level0name = @SchemaName,
            @level1type = N'TABLE',  @level1name = @HistoryTableName,
            @level2type = N'COLUMN', @level2name = N'Log_id';

        EXEC sys.sp_addextendedproperty
            @name = N'MS_Description',
            @value = N'異動行為類型 (INSERT/UPDATE/DELETE)',
            @level0type = N'SCHEMA', @level0name = @SchemaName,
            @level1type = N'TABLE',  @level1name = @HistoryTableName,
            @level2type = N'COLUMN', @level2name = N'LogType';

        EXEC sys.sp_addextendedproperty
            @name = N'MS_Description',
            @value = N'流程表單識別碼（外鍵：FlowForm.PK_ID）',
            @level0type = N'SCHEMA', @level0name = @SchemaName,
            @level1type = N'TABLE',  @level1name = @HistoryTableName,
            @level2type = N'COLUMN', @level2name = N'FlowFormId';

        EXEC sys.sp_addextendedproperty
            @name = N'MS_Description',
            @value = N'系統建立日期時間',
            @level0type = N'SCHEMA', @level0name = @SchemaName,
            @level1type = N'TABLE',  @level1name = @HistoryTableName,
            @level2type = N'COLUMN', @level2name = N'SysCreateDate';

        EXEC sys.sp_addextendedproperty
            @name = N'MS_Description',
            @value = N'系統建立使用者',
            @level0type = N'SCHEMA', @level0name = @SchemaName,
            @level1type = N'TABLE',  @level1name = @HistoryTableName,
            @level2type = N'COLUMN', @level2name = N'SysCreateUser';

        PRINT '✓ 成功加入欄位註釋';
    END TRY
    BEGIN CATCH
        PRINT '⚠ 加入欄位註釋時發生警告: ' + ERROR_MESSAGE();
        -- 不中斷執行，只顯示警告
    END CATCH
    -- ========================================

    PRINT '========================================';
    PRINT '✓ 完成! 歷史表建立成功: ' + @HistoryTableName;
END;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_CreateHistoryTable]
    @TableName NVARCHAR(128)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @HistoryTableName NVARCHAR(128) = @TableName + '_his';
    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @ColumnDefinitions NVARCHAR(MAX) = '';
    DECLARE @SchemaName NVARCHAR(128) = 'dbo';
    -- 檢查原始表是否存在
    IF NOT EXISTS (
        SELECT 1
        FROM INFORMATION_SCHEMA.TABLES
        WHERE TABLE_NAME = @TableName
    )
    BEGIN
        RAISERROR('原始表 %s 不存在', 16, 1, @TableName);
        RETURN;
    END

    -- 檢查歷史表是否已存在
    IF EXISTS (
        SELECT 1
        FROM INFORMATION_SCHEMA.TABLES
        WHERE TABLE_NAME = @HistoryTableName
    )
    BEGIN
        RAISERROR('歷史表 %s 已經存在', 16, 1, @HistoryTableName);
        RETURN;
    END

    -- 取得原始表的欄位定義
    SELECT @ColumnDefinitions = @ColumnDefinitions +
        QUOTENAME(COLUMN_NAME) + ' ' +
        DATA_TYPE +
        CASE
            WHEN DATA_TYPE IN ('varchar', 'char', 'nvarchar', 'nchar')
            THEN '(' + CASE WHEN CHARACTER_MAXIMUM_LENGTH = -1
                           THEN 'MAX'
                           ELSE CAST(CHARACTER_MAXIMUM_LENGTH AS VARCHAR(10))
                       END + ')'
            WHEN DATA_TYPE IN ('decimal', 'numeric')
            THEN '(' + CAST(NUMERIC_PRECISION AS VARCHAR(10)) + ',' +
                      CAST(NUMERIC_SCALE AS VARCHAR(10)) + ')'
            ELSE ''
        END +
        CASE WHEN IS_NULLABLE = 'NO' THEN ' NOT NULL' ELSE ' NULL' END +
        ',' + CHAR(13) + CHAR(10)
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = @TableName
    ORDER BY ORDINAL_POSITION;

    -- 移除最後一個逗號和換行
    IF LEN(@ColumnDefinitions) > 0
    BEGIN
        SET @ColumnDefinitions = LEFT(@ColumnDefinitions, LEN(@ColumnDefinitions) - 3);
    END

    -- 建立歷史表的 SQL
    SET @SQL =
        'CREATE TABLE ' + QUOTENAME(@HistoryTableName) + ' (' + CHAR(13) + CHAR(10) +
        '    Log_Id int IDENTITY(1,1) PRIMARY KEY,' + CHAR(13) + CHAR(10) +
        '    LogType NVARCHAR(10) NOT NULL,' + CHAR(13) + CHAR(10) +
        @ColumnDefinitions + ',' + CHAR(13) + CHAR(10) +
        '    SysCreateDate DATETIME NOT NULL DEFAULT GETDATE(),' + CHAR(13) + CHAR(10) +
        '    SysCreateUser NVARCHAR(100) NOT NULL' + CHAR(13) + CHAR(10) +
        ');';
    BEGIN TRY
    -- 執行建立表的 SQL
    EXEC sp_executesql @SQL;
    PRINT '成功建立歷史表: ' + @HistoryTableName;
	END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('建立歷史表失敗: %s', 16, 1, @ErrorMessage);
        RETURN;
    END CATCH
	-- ========== 新增：加入欄位註釋 ==========
    EXEC sys.sp_addextendedproperty
        @name = N'MS_Description',
        @value = N'歷史記錄識別碼',
        @level0type = N'SCHEMA', @level0name = @SchemaName,
        @level1type = N'TABLE',  @level1name = @HistoryTableName,
        @level2type = N'COLUMN', @level2name = N'log_id';

    EXEC sys.sp_addextendedproperty
        @name = N'MS_Description',
        @value = N'異動行為類型 (INSERT/UPDATE/DELETE)',
        @level0type = N'SCHEMA', @level0name = @SchemaName,
        @level1type = N'TABLE',  @level1name = @HistoryTableName,
        @level2type = N'COLUMN', @level2name = N'log_type';

    EXEC sys.sp_addextendedproperty
        @name = N'MS_Description',
        @value = N'系統建立日期時間',
        @level0type = N'SCHEMA', @level0name = @SchemaName,
        @level1type = N'TABLE',  @level1name = @HistoryTableName,
        @level2type = N'COLUMN', @level2name = N'SysCreateDate';

    EXEC sys.sp_addextendedproperty
        @name = N'MS_Description',
        @value = N'系統建立使用者',
        @level0type = N'SCHEMA', @level0name = @SchemaName,
        @level1type = N'TABLE',  @level1name = @HistoryTableName,
        @level2type = N'COLUMN', @level2name = N'SysCreateUser';

    PRINT '✓ 成功加入欄位註釋';
    -- ========================================
    PRINT '完成!';
END;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_CreateHistoryTable_Detail]
    @TableName NVARCHAR(128)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @HistoryTableName NVARCHAR(128) = @TableName + '_his';
    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @ColumnDefinitions NVARCHAR(MAX) = '';
    DECLARE @SchemaName NVARCHAR(128) = 'dbo';
    -- 檢查原始表是否存在
    IF NOT EXISTS (
        SELECT 1
        FROM INFORMATION_SCHEMA.TABLES
        WHERE TABLE_NAME = @TableName
    )
    BEGIN
        RAISERROR('原始表 %s 不存在', 16, 1, @TableName);
        RETURN;
    END

    -- 檢查歷史表是否已存在
    IF EXISTS (
        SELECT 1
        FROM INFORMATION_SCHEMA.TABLES
        WHERE TABLE_NAME = @HistoryTableName
    )
    BEGIN
        RAISERROR('歷史表 %s 已經存在', 16, 1, @HistoryTableName);
        RETURN;
    END

    -- 取得原始表的欄位定義
    SELECT @ColumnDefinitions = @ColumnDefinitions +
        QUOTENAME(COLUMN_NAME) + ' ' +
        DATA_TYPE +
        CASE
            WHEN DATA_TYPE IN ('varchar', 'char', 'nvarchar', 'nchar')
            THEN '(' + CASE WHEN CHARACTER_MAXIMUM_LENGTH = -1
                           THEN 'MAX'
                           ELSE CAST(CHARACTER_MAXIMUM_LENGTH AS VARCHAR(10))
                       END + ')'
            WHEN DATA_TYPE IN ('decimal', 'numeric')
            THEN '(' + CAST(NUMERIC_PRECISION AS VARCHAR(10)) + ',' +
                      CAST(NUMERIC_SCALE AS VARCHAR(10)) + ')'
            ELSE ''
        END +
        CASE WHEN IS_NULLABLE = 'NO' THEN ' NOT NULL' ELSE ' NULL' END +
        ',' + CHAR(13) + CHAR(10)
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = @TableName
    ORDER BY ORDINAL_POSITION;

    -- 移除最後一個逗號和換行
    IF LEN(@ColumnDefinitions) > 0
    BEGIN
        SET @ColumnDefinitions = LEFT(@ColumnDefinitions, LEN(@ColumnDefinitions) - 3);
    END

    -- 建立歷史表的 SQL
    SET @SQL =
        'CREATE TABLE ' + QUOTENAME(@HistoryTableName) + ' (' + CHAR(13) + CHAR(10) +
        '    Log_id int IDENTITY(1,1) PRIMARY KEY,' + CHAR(13) + CHAR(10) +
        '    LogType NVARCHAR(10) NOT NULL,' + CHAR(13) + CHAR(10) +
		'	 Fk_logId Int NOT NULL,' + CHAR(13) + CHAR(10) +
        @ColumnDefinitions + ',' + CHAR(13) + CHAR(10) +
        '    SysCreateDate DATETIME NOT NULL DEFAULT GETDATE(),' + CHAR(13) + CHAR(10) +
        '    SysCreateUser NVARCHAR(100) NOT NULL' + CHAR(13) + CHAR(10) +
        ');';
    BEGIN TRY
    -- 執行建立表的 SQL
    EXEC sp_executesql @SQL;
    PRINT '成功建立歷史表: ' + @HistoryTableName;
	END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('建立歷史表失敗: %s', 16, 1, @ErrorMessage);
        RETURN;
    END CATCH
	-- ========== 新增：加入欄位註釋 ==========
    EXEC sys.sp_addextendedproperty
        @name = N'MS_Description',
        @value = N'歷史記錄識別碼',
        @level0type = N'SCHEMA', @level0name = @SchemaName,
        @level1type = N'TABLE',  @level1name = @HistoryTableName,
        @level2type = N'COLUMN', @level2name = N'log_id';

    EXEC sys.sp_addextendedproperty
        @name = N'MS_Description',
        @value = N'異動行為類型 (INSERT/UPDATE/DELETE)',
        @level0type = N'SCHEMA', @level0name = @SchemaName,
        @level1type = N'TABLE',  @level1name = @HistoryTableName,
        @level2type = N'COLUMN', @level2name = N'LogType';

    EXEC sys.sp_addextendedproperty
        @name = N'MS_Description',
        @value = N'系統建立日期時間',
        @level0type = N'SCHEMA', @level0name = @SchemaName,
        @level1type = N'TABLE',  @level1name = @HistoryTableName,
        @level2type = N'COLUMN', @level2name = N'SysCreateDate';

    EXEC sys.sp_addextendedproperty
        @name = N'MS_Description',
        @value = N'系統建立使用者',
        @level0type = N'SCHEMA', @level0name = @SchemaName,
        @level1type = N'TABLE',  @level1name = @HistoryTableName,
        @level2type = N'COLUMN', @level2name = N'SysCreateUser';

    PRINT '✓ 成功加入欄位註釋';
    -- ========================================
    PRINT '完成!';
END;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_CreateTempTable]
    @TableName NVARCHAR(128)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TempTableName NVARCHAR(128) = @TableName + '_temp';
    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @ColumnDefinitions NVARCHAR(MAX) = '';
    DECLARE @SchemaName NVARCHAR(128) = 'dbo';
    DECLARE @ObjectId INT;

    -- 檢查原始表是否存在
    IF NOT EXISTS (
        SELECT 1
        FROM INFORMATION_SCHEMA.TABLES
        WHERE TABLE_NAME = @TableName
          AND TABLE_SCHEMA = @SchemaName
    )
    BEGIN
        RAISERROR('原始表 %s 不存在', 16, 1, @TableName);
        RETURN;
    END

    -- 取得 Object ID
    SET @ObjectId = OBJECT_ID(@SchemaName + '.' + @TableName);

    IF @ObjectId IS NULL
    BEGIN
        RAISERROR('無法取得表 %s 的 Object ID', 16, 1, @TableName);
        RETURN;
    END

    -- 檢查 Temp 表是否已存在
    IF EXISTS (
        SELECT 1
        FROM INFORMATION_SCHEMA.TABLES
        WHERE TABLE_NAME = @TempTableName
          AND TABLE_SCHEMA = @SchemaName
    )
    BEGIN
        RAISERROR('Temp 表 %s 已經存在', 16, 1, @TempTableName);
        RETURN;
    END

    -- 檢查 FlowForm 表是否存在
    IF NOT EXISTS (
        SELECT 1
        FROM INFORMATION_SCHEMA.TABLES
        WHERE TABLE_NAME = 'FlowForm'
          AND TABLE_SCHEMA = @SchemaName
    )
    BEGIN
        RAISERROR('FlowForm 表不存在，無法建立外鍵', 16, 1);
        RETURN;
    END

    -- 取得原始表的欄位定義（包含 NULL/NOT NULL 和預設值）
    SELECT @ColumnDefinitions = @ColumnDefinitions +
        '    ' + QUOTENAME(c.COLUMN_NAME) + ' ' +
        c.DATA_TYPE +
        CASE
            WHEN c.DATA_TYPE IN ('varchar', 'char', 'nvarchar', 'nchar')
            THEN '(' + CASE WHEN c.CHARACTER_MAXIMUM_LENGTH = -1
                           THEN 'MAX'
                           ELSE CAST(c.CHARACTER_MAXIMUM_LENGTH AS VARCHAR(10))
                       END + ')'
            WHEN c.DATA_TYPE IN ('decimal', 'numeric')
            THEN '(' + CAST(c.NUMERIC_PRECISION AS VARCHAR(10)) + ',' +
                      CAST(c.NUMERIC_SCALE AS VARCHAR(10)) + ')'
            WHEN c.DATA_TYPE IN ('datetime2', 'time', 'datetimeoffset')
            THEN '(' + CAST(c.DATETIME_PRECISION AS VARCHAR(10)) + ')'
            ELSE ''
        END +
        -- 保留原始表的 NULL/NOT NULL 設定
        CASE WHEN c.IS_NULLABLE = 'NO' THEN ' NOT NULL' ELSE ' NULL' END +
        -- 加入預設值
        CASE
            WHEN dc.definition IS NOT NULL
            THEN ' DEFAULT ' + dc.definition
            ELSE ''
        END +
        ',' + CHAR(13) + CHAR(10)
    FROM INFORMATION_SCHEMA.COLUMNS c
    LEFT JOIN sys.columns sc
        ON sc.object_id = @ObjectId
        AND sc.name = c.COLUMN_NAME
    LEFT JOIN sys.default_constraints dc
        ON dc.parent_object_id = @ObjectId
        AND dc.parent_column_id = sc.column_id
    WHERE c.TABLE_NAME = @TableName
      AND c.TABLE_SCHEMA = @SchemaName
    ORDER BY c.ORDINAL_POSITION;

    -- 檢查欄位定義是否為空
    IF LEN(@ColumnDefinitions) = 0
    BEGIN
        RAISERROR('錯誤: 無法取得表 %s 的欄位定義', 16, 1, @TableName);
        RETURN;
    END

    -- 移除最後一個逗號和換行
    SET @ColumnDefinitions = LEFT(@ColumnDefinitions, LEN(@ColumnDefinitions) - 3);

    -- 建立 Temp 表的 SQL
    SET @SQL =
        'CREATE TABLE ' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TempTableName) + ' (' + CHAR(13) + CHAR(10) +
        '    [TempId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,' + CHAR(13) + CHAR(10) +
        '    [FlowFormId] INT NULL,' + CHAR(13) + CHAR(10) +
        '    [ModifyType] NVARCHAR(10) NOT NULL,' + CHAR(13) + CHAR(10) +
        @ColumnDefinitions + ',' + CHAR(13) + CHAR(10) +
        '    [SysCreateDate] DATETIME NOT NULL DEFAULT GETDATE(),' + CHAR(13) + CHAR(10) +
        '    [SysCreateUser] NVARCHAR(100) NOT NULL,' + CHAR(13) + CHAR(10) +
        '    CONSTRAINT [FK_' + @TempTableName + '_FlowForm] FOREIGN KEY ([FlowFormId]) ' + CHAR(13) + CHAR(10) +
        '        REFERENCES ' + QUOTENAME(@SchemaName) + '.[FlowForm]([PK_ID])' + CHAR(13) + CHAR(10) +
        ');';

    BEGIN TRY
        -- 執行建立表的 SQL
        EXEC sp_executesql @SQL;
        PRINT '✓ 成功建立 Temp 表: ' + @TempTableName;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('建立 Temp 表失敗: %s', 16, 1, @ErrorMessage);
        RETURN;
    END CATCH

    -- ========== 加入欄位註釋 ==========
    BEGIN TRY
        EXEC sys.sp_addextendedproperty
            @name = N'MS_Description',
            @value = N'暫存資料識別碼（流水號）',
            @level0type = N'SCHEMA', @level0name = @SchemaName,
            @level1type = N'TABLE',  @level1name = @TempTableName,
            @level2type = N'COLUMN', @level2name = N'TempId';

        EXEC sys.sp_addextendedproperty
            @name = N'MS_Description',
            @value = N'流程表單識別碼（外鍵：FlowForm.PK_ID）',
            @level0type = N'SCHEMA', @level0name = @SchemaName,
            @level1type = N'TABLE',  @level1name = @TempTableName,
            @level2type = N'COLUMN', @level2name = N'FlowFormId';

        PRINT '✓ 成功加入欄位註釋';
    END TRY
    BEGIN CATCH
        PRINT '⚠ 加入欄位註釋時發生警告: ' + ERROR_MESSAGE();
    END CATCH

    PRINT '========================================';
    PRINT '✓ 完成! Temp 表建立成功: ' + @TempTableName;
END;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_CreateTempTable_Detail]
    @TableName NVARCHAR(128)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TempTableName NVARCHAR(128) = @TableName + '_temp';
    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @ColumnDefinitions NVARCHAR(MAX) = '';
    DECLARE @SchemaName NVARCHAR(128) = 'dbo';
    DECLARE @ObjectId INT;

    -- 檢查原始表是否存在
    IF NOT EXISTS (
        SELECT 1
        FROM INFORMATION_SCHEMA.TABLES
        WHERE TABLE_NAME = @TableName
          AND TABLE_SCHEMA = @SchemaName
    )
    BEGIN
        RAISERROR('原始表 %s 不存在', 16, 1, @TableName);
        RETURN;
    END

    -- 取得 Object ID
    SET @ObjectId = OBJECT_ID(@SchemaName + '.' + @TableName);

    IF @ObjectId IS NULL
    BEGIN
        RAISERROR('無法取得表 %s 的 Object ID', 16, 1, @TableName);
        RETURN;
    END

    -- 檢查 Temp 表是否已存在
    IF EXISTS (
        SELECT 1
        FROM INFORMATION_SCHEMA.TABLES
        WHERE TABLE_NAME = @TempTableName
          AND TABLE_SCHEMA = @SchemaName
    )
    BEGIN
        RAISERROR('Temp 表 %s 已經存在', 16, 1, @TempTableName);
        RETURN;
    END

    -- 取得原始表的欄位定義（包含預設值，但強制所有欄位為 NULL）
    SELECT @ColumnDefinitions = @ColumnDefinitions +
        '    ' + QUOTENAME(c.COLUMN_NAME) + ' ' +
        c.DATA_TYPE +
        CASE
            WHEN c.DATA_TYPE IN ('varchar', 'char', 'nvarchar', 'nchar')
            THEN '(' + CASE WHEN c.CHARACTER_MAXIMUM_LENGTH = -1
                           THEN 'MAX'
                           ELSE CAST(c.CHARACTER_MAXIMUM_LENGTH AS VARCHAR(10))
                       END + ')'
            WHEN c.DATA_TYPE IN ('decimal', 'numeric')
            THEN '(' + CAST(c.NUMERIC_PRECISION AS VARCHAR(10)) + ',' +
                      CAST(c.NUMERIC_SCALE AS VARCHAR(10)) + ')'
            WHEN c.DATA_TYPE IN ('datetime2', 'time', 'datetimeoffset')
            THEN '(' + CAST(c.DATETIME_PRECISION AS VARCHAR(10)) + ')'
            ELSE ''
        END +
        -- 強制所有欄位為 NULL
        ' NULL' +
        -- 加入預設值
        CASE
            WHEN dc.definition IS NOT NULL
            THEN ' DEFAULT ' + dc.definition
            ELSE ''
        END +
        ',' + CHAR(13) + CHAR(10)
    FROM INFORMATION_SCHEMA.COLUMNS c
    LEFT JOIN sys.columns sc
        ON sc.object_id = @ObjectId
        AND sc.name = c.COLUMN_NAME
    LEFT JOIN sys.default_constraints dc
        ON dc.parent_object_id = @ObjectId
        AND dc.parent_column_id = sc.column_id
    WHERE c.TABLE_NAME = @TableName
      AND c.TABLE_SCHEMA = @SchemaName
    ORDER BY c.ORDINAL_POSITION;

    -- 檢查欄位定義是否為空
    IF LEN(@ColumnDefinitions) = 0
    BEGIN
        RAISERROR('錯誤: 無法取得表 %s 的欄位定義', 16, 1, @TableName);
        RETURN;
    END

    -- 移除最後一個逗號和換行
    SET @ColumnDefinitions = LEFT(@ColumnDefinitions, LEN(@ColumnDefinitions) - 3);

    -- 建立 Temp 表的 SQL
    SET @SQL =
        'CREATE TABLE ' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TempTableName) + ' (' + CHAR(13) + CHAR(10) +
        '    [TempId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,' + CHAR(13) + CHAR(10) +
        '    [FK_TempId] INT NOT NULL,' + CHAR(13) + CHAR(10) +
        '    [ModifyType] NVARCHAR(10) NOT NULL,' + CHAR(13) + CHAR(10) +
        @ColumnDefinitions + ',' + CHAR(13) + CHAR(10) +
        '    [SysCreateDate] DATETIME NOT NULL DEFAULT GETDATE(),' + CHAR(13) + CHAR(10) +
        '    [SysCreateUser] NVARCHAR(100) NOT NULL' + CHAR(13) + CHAR(10) +
        ');';

    BEGIN TRY
        -- 執行建立表的 SQL
        EXEC sp_executesql @SQL;
        PRINT '✓ 成功建立 Temp 表: ' + @TempTableName;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('建立 Temp 表失敗: %s', 16, 1, @ErrorMessage);
        RETURN;
    END CATCH

    -- ========== 加入欄位註釋 ==========
    BEGIN TRY
        EXEC sys.sp_addextendedproperty
            @name = N'MS_Description',
            @value = N'暫存資料識別碼（流水號）',
            @level0type = N'SCHEMA', @level0name = @SchemaName,
            @level1type = N'TABLE',  @level1name = @TempTableName,
            @level2type = N'COLUMN', @level2name = N'TempId';

        EXEC sys.sp_addextendedproperty
            @name = N'MS_Description',
            @value = N'主表暫存資料外鍵',
            @level0type = N'SCHEMA', @level0name = @SchemaName,
            @level1type = N'TABLE',  @level1name = @TempTableName,
            @level2type = N'COLUMN', @level2name = N'FK_TempId';

        EXEC sys.sp_addextendedproperty
            @name = N'MS_Description',
            @value = N'異動類型',
            @level0type = N'SCHEMA', @level0name = @SchemaName,
            @level1type = N'TABLE',  @level1name = @TempTableName,
            @level2type = N'COLUMN', @level2name = N'ModifyType';

        EXEC sys.sp_addextendedproperty
            @name = N'MS_Description',
            @value = N'系統建立日期時間',
            @level0type = N'SCHEMA', @level0name = @SchemaName,
            @level1type = N'TABLE',  @level1name = @TempTableName,
            @level2type = N'COLUMN', @level2name = N'SysCreateDate';

        EXEC sys.sp_addextendedproperty
            @name = N'MS_Description',
            @value = N'系統建立使用者',
            @level0type = N'SCHEMA', @level0name = @SchemaName,
            @level1type = N'TABLE',  @level1name = @TempTableName,
            @level2type = N'COLUMN', @level2name = N'SysCreateUser';

        PRINT '✓ 成功加入欄位註釋';
    END TRY
    BEGIN CATCH
        PRINT '⚠ 加入欄位註釋時發生警告: ' + ERROR_MESSAGE();
        -- 不中斷執行，只顯示警告
    END CATCH
    -- ========================================

    PRINT '========================================';
    PRINT '✓ 完成! Temp 表建立成功: ' + @TempTableName;
END;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- 取代原本 usp_GetGroupId 呼叫端的誤用。
-- 改用OUTPUT參數，並將SELECT與UPDATE包在同一顯式交易內，搭配UPDLOCK/ROWLOCK/HOLDLOCK使鎖定延續到交易結束，避免併發呼叫取得重複GroupId。
CREATE   PROCEDURE [dbo].[usp_GetGroupId]
    @GroupName NVARCHAR(50),
    @NewGroupId INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;

    SELECT @NewGroupId = GroupCount
    FROM GroupIdCounter WITH (UPDLOCK, ROWLOCK, HOLDLOCK)
    WHERE GroupName = @GroupName;

    IF @NewGroupId IS NULL
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 51000, 'GroupIdCounter 查無對應 GroupName', 1;
        RETURN;
    END

    UPDATE GroupIdCounter
    SET GroupCount = GroupCount + 1
    WHERE GroupName = @GroupName;

    COMMIT TRANSACTION;
END;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Allenchen
-- Create date: 2025/11/13
-- Description:	HRIS 洗資料 -- 分行
-- =============================================
CREATE PROCEDURE [dbo].[usp_HRIS_Transfer_BankBranch]
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		declare @Automatic nvarchar(2) = '自動',
				@Manual nvarchar(2) = '手動'

		DECLARE @H077050000_Id INT = (SELECT PK_Id FROM BankUnit WHERE UnitCode = 'H077050000'); -- 海業處 id
		DECLARE @FB009 INT = (SELECT PK_Id FROM BankUnit WHERE UnitCode = 'FB009'); -- 分行營業單位

		-- 分行沒有的新增 ，有就修改 ，HRIS沒有就停用
		MERGE INTO BankBranch AS Target
		USING (Select DISTINCT UnitBranchCode,UnitBranchName,
			   CASE WHEN Left(UnitBranchCode,2) = 'B9' OR Left(UnitBranchCode,4) = 'B095'
			   THEN @H077050000_Id
			   ELSE @FB009
			   END FK_BankUnit
			   FROM HRIS_Origin
			   Where GroupCode = 'FB009'
		) AS Source
		ON Target.BankCode = Source.UnitBranchCode
		WHEN MATCHED AND (BankName_TN <> Source.UnitBranchName OR ((Left(UnitBranchCode,2) = 'B9' OR Left(UnitBranchCode,4) = 'B095') AND IsActive = 0) OR
				(Source.UnitBranchName LIKE N'%辦事處%' AND IsActive = 1 AND Target.Memo <> @Manual AND Target.IsSave <> 1) OR
				ISNULL(Target.FK_BankUnit,'') <> ISNULL(Source.FK_BankUnit,''))
		THEN
			UPDATE SET FK_BankUnit = Source.FK_BankUnit,
						IsActive = CASE WHEN UnitBranchName LIKE N'%辦事處%' AND Target.Memo <> @Manual AND Target.IsSave <> 1
							      THEN 0
								  WHEN Left(UnitBranchCode,2) = 'B9' OR Left(UnitBranchCode,4) = 'B095'
								  THEN 1
								  ELSE IsActive
								  END,
						IsEmployed = 1,
					BankName_TN = UnitBranchName, Memo = @Automatic,Update_date = getdate(),Update_user = 'system'
		WHEN NOT MATCHED BY TARGET
		THEN
			INSERT (FK_BankUnit,BankCode,BankName_TN,BankName_EN,BankName_JP,BankName_CN,IsActive,IsSave,IsEmployed,Memo)
			VALUES (FK_BankUnit,Source.UnitBranchCode, Source.UnitBranchName, Source.UnitBranchName, Source.UnitBranchName, Source.UnitBranchName,
			CASE WHEN UnitBranchName LIKE N'%辦事處%'
			THEN 0
			WHEN Left(UnitBranchCode,2) = 'B9' OR Left(UnitBranchCode,4) = 'B095'
			THEN 1
			ELSE 0
			END,0,1, @Automatic)
		WHEN NOT MATCHED BY SOURCE and Target.Memo <> @Manual and Target.IsSave <> 1 AND  Target.IsActive <> 0
		THEN
			UPDATE SET IsActive = 0,IsEmployed = 0,Memo = @Automatic,Update_date = getdate(),Update_user = 'system'

		OUTPUT $action,isnull(deleted.PK_Id,inserted.PK_Id),isnull(deleted.FK_BankUnit,inserted.FK_BankUnit),
		isnull(deleted.BankCode,inserted.BankCode),isnull(deleted.BankName_TN,inserted.BankName_TN),
		isnull(deleted.BankName_EN,inserted.BankName_EN),isnull(deleted.BankName_CN,inserted.BankName_CN),
		isnull(deleted.BankName_JP,inserted.BankName_JP),isnull(deleted.Latitude,inserted.Latitude),
		isnull(deleted.Longitude,inserted.Longitude),isnull(deleted.IsActive,inserted.IsActive),
		isnull(deleted.IsSave,inserted.IsSave),isnull(deleted.IsEmployed,inserted.IsEmployed),
		isnull(deleted.Memo,inserted.Memo),isnull(deleted.Update_date,inserted.Update_date),
		isnull(deleted.Update_user,inserted.Update_user),isnull(deleted.Create_date,inserted.Create_date),
		isnull(deleted.Create_user,inserted.Create_user)
		INTO BankBranch_log(LogType,PK_Id,FK_BankUnit,BankCode,BankName_TN,BankName_EN,BankName_CN,BankName_JP,Latitude,Longitude,
		IsActive,IsSave,IsEmployed,Memo,Update_date,Update_user,Create_date,Create_user);

		  -- 🔑 回傳影響的記錄數
        DECLARE @AffectedRows INT = @@ROWCOUNT;
        PRINT '成功處理 ' + CAST(@AffectedRows AS NVARCHAR) + ' 筆記錄';

	END TRY
	BEGIN CATCH
		DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorLine INT = ERROR_LINE();

        PRINT '發生錯誤於第 ' + CAST(@ErrorLine AS NVARCHAR) + ' 行: ' + @ErrorMsg;
		THROW;
	END CATCH
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Allenchen
-- Create date: 2025/11/13
-- Description:	HRIS 洗資料 -- 事業群
-- =============================================
CREATE PROCEDURE [dbo].[usp_HRIS_Transfer_BankGroup]
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- 宣告變數
        DECLARE @Automatic NVARCHAR(10) = '自動';
        DECLARE @Manual NVARCHAR(10) = '手動';


        -- 事業群沒有的新增,名稱有差異就修改,HRIS沒有就停用
        MERGE INTO BankGroup AS t
        USING (SELECT DISTINCT GroupCode, GroupName FROM HRIS_Origin) AS s
        ON t.GroupCode = s.GroupCode

        -- MATCHED
        WHEN MATCHED AND t.GroupName_TN <> s.GroupName and t.IsEmployed = 0
        THEN
            UPDATE SET
                GroupName_TN = s.GroupName,
				IsEmployed = 1,
                Memo = @Automatic,
                Update_date = GETDATE(),
                Update_user = 'system'
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (GroupCode, GroupName_TN, GroupName_EN, GroupName_JP, GroupName_CN, IsActive,IsEmployed,IsBusinessUnit, Memo, Create_date, Create_user)
            VALUES (
                s.GroupCode,
                s.GroupName,
                s.GroupName,
                s.GroupName,
                s.GroupName,
                0,
				1,
				0,
                @Automatic,
                GETDATE(),
                'system'
            )
        -- NOT MATCHED BY SOURCE: 停用 (排除系統群組)
        WHEN NOT MATCHED BY SOURCE
        THEN
            UPDATE SET IsEmployed = 0,Memo = @Automatic,Update_date = GETDATE(),Update_user = 'system'
        -- 輸出到備份表
        OUTPUT
            $action,
            ISNULL(deleted.PK_Id, inserted.PK_Id),
            ISNULL(deleted.GroupCode, inserted.GroupCode),
            ISNULL(deleted.GroupName_EN, inserted.GroupName_EN),
            ISNULL(deleted.GroupName_TN, inserted.GroupName_TN),
            ISNULL(deleted.GroupName_CN, inserted.GroupName_CN),
            ISNULL(deleted.GroupName_JP, inserted.GroupName_JP),
            ISNULL(deleted.IsActive, inserted.IsActive),
			ISNULL(deleted.IsEmployed, inserted.IsEmployed),
			ISNULL(deleted.IsBusinessUnit, inserted.IsBusinessUnit),
            ISNULL(deleted.Memo, inserted.Memo),
            ISNULL(deleted.Update_date, inserted.Update_date),
            ISNULL(deleted.Update_user, inserted.Update_user),
            ISNULL(deleted.Create_date, inserted.Create_date),
            ISNULL(deleted.Create_user, inserted.Create_user)
        INTO BankGroup_log(logType, PK_Id, GroupCode, GroupName_EN, GroupName_TN, GroupName_CN, GroupName_JP,
            IsActive,IsEmployed,IsBusinessUnit,Memo, Update_date, Update_user, Create_date, Create_user
        );

        -- 🔑 新增:回傳影響的記錄數
        DECLARE @AffectedRows INT = @@ROWCOUNT;
        PRINT '成功處理 ' + CAST(@AffectedRows AS NVARCHAR) + ' 筆記錄';

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorLine INT = ERROR_LINE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        -- 記錄錯誤到 SysLog (如果有的話)
        PRINT '發生錯誤於第 ' + CAST(@ErrorLine AS NVARCHAR) + ' 行: ' + @ErrorMsg;

        -- 重新拋出錯誤
        THROW;
    END CATCH
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Allenchen
-- Create date: 2025/11/13
-- Description:	HRIS 洗資料 -- 處級
-- Modified:    2026/01/21 - 優化效能,使用 Table Variable
-- =============================================
CREATE PROCEDURE [dbo].[usp_HRIS_Transfer_BankUnit]
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- 宣告變數
        DECLARE @Automatic NVARCHAR(10) = '自動';
        DECLARE @Manual NVARCHAR(10) = '手動';

        -- 處級沒有的新增,有就修改,HRIS沒有就停用
        MERGE INTO BankUnit AS t
        USING (
            SELECT DISTINCT
                CASE WHEN a.GroupCode = 'FB009' then b.GroupCode else a.UnitBranchCode end UnitBranchCode,
				CASE WHEN a.GroupCode = 'FB009' then b.GroupName_TN else a.UnitBranchName end UnitBranchName,
                b.PK_Id AS BankGroupId
            FROM HRIS_Origin a
            INNER JOIN BankGroup b ON a.GroupCode = b.GroupCode
        ) AS s
        ON t.UnitCode = s.UnitBranchCode

        -- MATCHED: 系統單位被停用 OR 名稱有變化
        WHEN MATCHED AND (t.FK_BankGroup <> s.BankGroupId OR t.UnitName_TN <> s.UnitBranchName OR t.IsEmployed = 0)  -- 名稱有變化
        THEN
            UPDATE SET
				FK_BankGroup = s.BankGroupId,
                UnitName_TN = s.UnitBranchName,
				IsEmployed = 1,
                Memo = @Automatic,
                Update_date = GETDATE(),
                Update_user = 'system'

        -- NOT MATCHED BY TARGET: 新增 (系統單位預設啟用)
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (
                FK_BankGroup, UnitCode, UnitName_TN, UnitName_EN, UnitName_JP, UnitName_CN,
                IsActive,IsEmployed,IsMain,IsBusinessUnit, Memo, Create_date, Create_user
            )
            VALUES (
                s.BankGroupId,
                s.UnitBranchCode,
                s.UnitBranchName,
                s.UnitBranchName,
                s.UnitBranchName,
                s.UnitBranchName,
                0,0,0,0,
                @Automatic,
                GETDATE(),
                'system'
            )

        -- NOT MATCHED BY SOURCE: 停用 (排除手動維護的和系統單位)
        WHEN NOT MATCHED BY SOURCE and t.IsSave <> 1
        THEN
            UPDATE SET
                IsEmployed = 0,
                Memo = @Automatic,
                Update_date = GETDATE(),
                Update_user = 'system'
        -- 輸出到歷史表
        OUTPUT
            $action,
            ISNULL(deleted.PK_Id, inserted.PK_Id),
            ISNULL(deleted.FK_BankGroup, inserted.FK_BankGroup),
            ISNULL(deleted.UnitCode, inserted.UnitCode),
            ISNULL(deleted.UnitName_EN, inserted.UnitName_EN),
            ISNULL(deleted.UnitName_TN, inserted.UnitName_TN),
            ISNULL(deleted.UnitName_CN, inserted.UnitName_CN),
            ISNULL(deleted.UnitName_JP, inserted.UnitName_JP),
            ISNULL(deleted.IsMain, inserted.IsMain),
            ISNULL(deleted.IsActive, inserted.IsActive),
			ISNULL(deleted.IsSave, inserted.IsSave),
			ISNULL(deleted.IsEmployed, inserted.IsEmployed),
			ISNULL(deleted.IsBusinessUnit, inserted.IsBusinessUnit),
            ISNULL(deleted.Memo, inserted.Memo),
            ISNULL(deleted.Update_date, inserted.Update_date),
            ISNULL(deleted.Update_user, inserted.Update_user),
            ISNULL(deleted.Create_date, inserted.Create_date),
            ISNULL(deleted.Create_user, inserted.Create_user)
        INTO BankUnit_log(
            logType, PK_Id, FK_BankGroup, UnitCode, UnitName_EN, UnitName_TN, UnitName_CN, UnitName_JP,
            IsMain, IsActive,IsSave,IsEmployed,IsBusinessUnit, Memo, Update_date, Update_user, Create_date, Create_user
        );

        -- 🔑 回傳影響的記錄數
        DECLARE @AffectedRows INT = @@ROWCOUNT;
        PRINT '成功處理 ' + CAST(@AffectedRows AS NVARCHAR) + ' 筆記錄';

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorLine INT = ERROR_LINE();

        PRINT '發生錯誤於第 ' + CAST(@ErrorLine AS NVARCHAR) + ' 行: ' + @ErrorMsg;
        THROW;
    END CATCH
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		allenchen
-- Create date: 2025/11/06
-- Description:	將HRIS_ORG 資料 轉成 Users Table資料
-- =============================================
CREATE PROCEDURE [dbo].[usp_HRIS_Transfer_Users]
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

		DROP TABLE IF EXISTS #TransferUsers
		SELECT UserId,UserName,'i'+SUBSTRING(UserId, PATINDEX('%[^0]%', UserId),5)+ '@FirstBank.com.tw' Email,
				isnull(g.GroupCode,a.GroupCode) GroupCode,isnull(d.UnitCode,b.UnitCode) UnitCode,c.BankCode,
				DepartmentCode,DepartmentName,Chief Chief,f.PK_Id TitleCode,e.TitleName,
				a.Leave_Start,a.Leave_End,a.Acting_Person
		INTO #TransferUsers
		FROM(
				Select *
				From HRIS_Origin a
				WHERE NOT EXISTS (SELECT 1 FROM Global WHERE GroupId = 'HRIS_Filter_JobTitleCode' and Code = a.JobTitleCode) -- 排除不要轉入
			) a
		LEFT JOIN BankUnit b on a.UnitBranchCode = b.UnitCode
		LEFT JOIN BankBranch c on a.UnitBranchCode = c.BankCode
		LEFT JOIN BankUnit d on c.FK_BankUnit = d.PK_Id
		LEFT JOIN BankGroup g on d.FK_BankGroup = g.PK_Id
		INNER JOIN TitleMapping e on a.TitleCode = e.TitleCode
		INNER JOIN Title f on e.TitleId = f.PK_Id
		---------------------------------------------------------
		Declare @UserChange nvarchar(10) = '調/升/復職',
				@UserLeave nvarchar(10) = '離職',
				@UserAdd nvarchar(10)  = '新進員工',
				@Update nvarchar(10) = '更新資訊'
		DROP TABLE IF EXISTS #Users_his;
		SELECT * INTO #Users_his FROM Users_log WHERE 1=0

		Merge INTO Users as Target
		USING #TransferUsers as Source
		ON Target.UserId = Source.UserId
		--  調/升/復職 、 更新資訊
		WHEN MATCHED
		THEN
			UPDATE SET IsEmployed = 1,IsActive = 1,
				GroupCode = Source.GroupCode,
				UnitCode = Source.UnitCode,
				BranchCode = Source.BankCode,
				departmentCode = Source.departmentCode,
				departmentName = Source.departmentName,
				TitleCode = Source.TitleCode,
				TitleName = Source.TitleName,
				UserName = Source.UserName,
				Chief = Source.Chief,
				Leave_Start = Source.Leave_Start,
				Leave_End = Source.Leave_End,
				Acting_Person = Source.Acting_Person,
				Update_date = Getdate(),
				Update_user = 'system',
				Memo = case when Target.GroupCode <> Source.GroupCode OR
							ISNULL(Target.UnitCode,'') <> ISNULL(Source.UnitCode,'') OR
							ISNULL(Target.BranchCode,'') <> ISNULL(Source.BankCode,'') OR
							ISNULL(Target.departmentCode,'') <> ISNULL(Source.departmentCode,'') OR
							ISNULL(Target.TitleName,'') <> ISNULL(Source.TitleName,'') OR
							Target.IsEmployed = 0
						then @UserChange
						else @Update
						end
		-- 新進員工
		WHEN NOT MATCHED BY TARGET
		THEN
			INSERT (UserId,UserName,Email,GroupCode,UnitCode,BranchCode,DepartmentCode,DepartmentName,Chief,TitleCode,TitleName,IsActive
				,IsEmployed,Leave_Start,Leave_End,Acting_Person,Create_date,Update_date,Update_user,Memo)
			Values (UserId,UserName,Email,GroupCode,UnitCode,BankCode,DepartmentCode,DepartmentName,Chief,TitleCode,TitleName,1
				,1,Leave_Start,Leave_End,Acting_Person,getdate(),getdate(),'system',@UserAdd)
		-- 離職
		WHEN NOT MATCHED BY SOURCE AND TARGET.IsEmployed <> 0
		THEN
			UPDATE SET Target.IsEmployed = 0,
				Target.IsActive = 0,
				Update_date = Getdate(),
				Update_user = 'system',
				Memo = @UserLeave

		Output $action,
			isnull(deleted.UserId,inserted.UserId),
			isnull(deleted.UserName,inserted.UserName),
			isnull(deleted.Email,inserted.Email),
			isnull(deleted.GroupCode,inserted.GroupCode),
			isnull(deleted.UnitCode,inserted.UnitCode),
			isnull(deleted.BranchCode,inserted.BranchCode),
			isnull(deleted.departmentCode,inserted.departmentCode),
			isnull(deleted.departmentName,inserted.departmentName),
			isnull(deleted.Chief,inserted.Chief),
			isnull(deleted.TitleCode,inserted.TitleCode),
			isnull(deleted.TitleName,inserted.TitleName),
			isnull(deleted.IsActive,inserted.IsActive),
			isnull(deleted.IsEmployed,inserted.IsEmployed),
			isnull(deleted.Leave_Start,inserted.Leave_Start),
			isnull(deleted.Leave_End,inserted.Leave_End),
			isnull(deleted.Acting_Person,inserted.Acting_Person),
			isnull(deleted.Create_date,inserted.Create_date),
			isnull(deleted.Update_date,inserted.Update_date),
			isnull(deleted.Update_User,inserted.Update_User),
			inserted.Memo,
			getdate()
		INTO #Users_his(logType,UserId,UserName,Email,GroupCode,UnitCode,BranchCode,departmentCode,departmentName,
						Chief,TitleCode,TitleName,IsActive,IsEmployed,Leave_Start,Leave_End,Acting_Person,Create_date,
						Update_date,Update_User,Memo,SysCreateDate);
		Insert Users_log
		SELECT *
		FROM #Users_his

		SELECT *
		FROM #Users_his

	END TRY
	BEGIN CATCH
		DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT '發生錯誤: ' + @ErrorMsg;
		THROW;
	END CATCH

END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		AllenChen
-- Create date: 2025/10/17
-- Description:	01OBBS海外債券(OSBDKF02_MF) 轉檔，根據分行交易最大日期

-- =============================================
CREATE PROCEDURE [dbo].[usp_Souce01_OBBS_By_OSBDKF02_MF] @EXT_DATE AS DATE
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

	DECLARE @BufferDate INT = 14; -- 到期日緩衝時間

	WITH temp AS (
		SELECT *
		FROM OSBDKF02_MF
		WHERE TRIM(OSBDKF02_ISSUER_COUNTRY) <> 'TW' AND
			-- 檢查是否為最新資料
			EXISTS (
				SELECT 1
				FROM (
					SELECT OSBDKF02_BRANCH_NO, MAX(OSBDKF02_EXT_DATE) AS MAX_DATE
					FROM OSBDKF02_MF
					WHERE OSBDKF02_EXT_DATE <= @EXT_DATE
					GROUP BY OSBDKF02_BRANCH_NO
				) Latest
				WHERE
					OSBDKF02_MF.OSBDKF02_BRANCH_NO = Latest.OSBDKF02_BRANCH_NO AND
					OSBDKF02_MF.OSBDKF02_EXT_DATE = Latest.MAX_DATE
			) AND
			LEFT(OSBDKF02_AC_9, 5) not in ('22501','13007') AND --文件編號：D211150
			(OSBDKF02_MATURITY_DATE IS NULL OR DATEADD(DAY,@BufferDate,OSBDKF02_MATURITY_DATE) >= @EXT_DATE)

	)
	INSERT INTO MonitorData (
	    BRANCH_NO, UNIT_NO, PRODUCT_TYPE, TRAN_NO, GROUP_NO, TX_DATE,
	    CUSTOMER_NAME, CUSTOMER_ID, COUNTRY_COD, CURENCY_COD, TRAN_AMOUNT,
	    PERMIT_NO, LIMIT, LIMIT_COD, MATURITY_DATE, AS_OF_DATE,  FIL9,
	    SOURCE, CREATOR, LIMIT_MATURITY,INDUSTRY,INDUSTRY_Type,EXT_DATE)
	SELECT
		TRIM(OSBDKF02_BRANCH_NO) AS BRANCH_NO,
		'077' AS DIVISION_NO,
		'08' AS PRODUCT_TYPE,  -- 08 有價証券投資
		TRIM(OSBDKF02_TRAN_NO) AS TRAN_NO, --交易編號
		'018' AS BUSINESS_UNIT,
		OSBDKF02_DOWN_DATE AS TX_DATE, --訂約日期
		TRIM(OSBDKF02_CUST_NAME1) AS CUSTOMER_NAME,
		TRIM(OSBDKF02_SWIFT_ID) AS CUSTOMER_ID,
		TRIM(OSBDKF02_ISSUER_COUNTRY) AS COUNTRY_COD,
		TRIM(OSBDKF02_CURENCY_COD) AS CURENCY_COD,
		(OSBDKF02_BALANCE_AMT / OSBDKF02_PRICE) *100 AS TRAN_AMOUNT, -- 改抓OSBDKF02_BALANCE_AMT
		TRIM(OSBDKF02_LINE_PERMIT_NO) + OSBDKF02_BRANCH_NO AS PERMIT_NO, --核准編號
		(OSBDKF02_BALANCE_AMT / OSBDKF02_PRICE) *100 AS LIMIT, --核准額度 -- 改抓OSBDKF02_BALANCE_AMT
		TRIM(OSBDKF02_CURENCY_COD) AS LIMIT_COD, --幣別
		OSBDKF02_MATURITY_DATE AS MATURITY_DATE,
		OSBDKF02_TX_DATE AS AS_OF_DATE,
		'OSBDKF02_MF' AS FIL9,
		'01' AS SOURCE,
		'system' AS CREATOR,
		OSBDKF02_MATURITY_DATE AS LIMIT_MATURITY,
		TRIM(BUSINS_CODE) AS INDUSTRY,
		2,
		@EXT_DATE AS EXT_DATE
	FROM temp
	--國家風險餘額計算步驟：
	--	一、	依「CUST-NAME1」加總「BOND PRICE」之折美金值加總之金額如小於0，則不計入。
	--	三、	將各「CUST-NAME1」之加總「BOND PRICE」折美金值，依國碼別加總  ???
	WHERE EXISTS (
			SELECT 1
			FROM temp MF2
			WHERE TRIM(MF2.OSBDKF02_CUST_NAME1) = TRIM(temp.OSBDKF02_CUST_NAME1) AND
			MF2.OSBDKF02_BRANCH_NO = temp.OSBDKF02_BRANCH_NO
			GROUP BY TRIM(MF2.OSBDKF02_CUST_NAME1), MF2.OSBDKF02_BRANCH_NO
			HAVING SUM(MF2.OSBDKF02_BOND_PRICE) > 0
		);
	END TRY
	BEGIN CATCH
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT '發生錯誤: ' + @ErrorMsg;
		THROW;
	END CATCH

END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		AllenChen
-- Create date: 2025/10/17
-- Description:	01OBBS延伸性金融商品FXSWAP(OSFXKF02_MF) 轉檔，根據分行交易最大日期

-- =============================================
CREATE PROCEDURE [dbo].[usp_Souce01_OBBS_By_OSFXKF02_MF] @EXT_DATE AS DATE
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

	DECLARE @BufferDate INT = 14; -- 到期日緩衝時間

	INSERT INTO MonitorData (
		BRANCH_NO, UNIT_NO, PRODUCT_TYPE, TRAN_NO, GROUP_NO, TX_DATE,
		CUSTOMER_NAME, CUSTOMER_ID, COUNTRY_COD, CURENCY_COD, TRAN_AMOUNT,
		LIMIT, LIMIT_COD, MATURITY_DATE, AS_OF_DATE, FIL9,
		SOURCE, CREATOR, LIMIT_MATURITY,INDUSTRY,INDUSTRY_Type,CUR_BOUGHT,CUR_SOLD,EXT_DATE)
	SELECT
		TRIM(OSFXKF02_BRANCH_NO) AS BRANCH_NO,
		'077' AS DIVISION_NO,
		'07' AS PRODUCT_TYPE,
		TRIM(OSFXKF02_TRAN_NO) AS TRAN_NO,
		'018' AS BUSINESS_UNIT,
		OSFXKF02_DEL_DATE AS TX_DATE,
		TRIM(OSFXKF02_CUST_NAME1) AS CUSTOMER_NAME,
		TRIM(OSFXKF02_CUATOMER_ID) AS CUSTOMER_ID,
		TRIM(COALESCE(NULLIF(TRIM(OSFXKF02_CPTY_COUNTRY_RISK), ''), OSFXKF02_CPTY_COUNTRY)) AS COUNTRY_COD,
		TRIM(OSFXKF02_OBJECT_CCY) AS CURENCY_COD,
		OSFXKF02_OBJECT_AMT AS TRAN_AMOUNT,
		OSFXKF02_OBJECT_AMT AS LIMIT,
		TRIM(OSFXKF02_OBJECT_CCY) AS LIMIT_COD,
		OSFXKF02_VALUE_DATE0 AS MATURITY_DATE,
		OSFXKF02_TX_DATE AS AS_OF_DATE,
		'OSFXKF02_MF' AS FIL9,
		'01' AS source,
		'system' AS creator,
		OSFXKF02_VALUE_DATE0 AS LIMIT_MATURITY,
		TRIM(BUSINS_CODE) AS INDUSTRY,
		2,
		OSFXKF02_CUR_BOUGHT as CUR_BOUGHT,
		OSFXKF02_CUR_SOLD AS CUR_SOLD,
		@EXT_DATE AS EXT_DATE
	FROM OSFXKF02_MF
	WHERE OSFXKF02_TX_TYPE = '03' AND
		  TRIM(ISNULL(OSFXKF02_CPTY_COUNTRY_RISK,'')) <> 'TW' AND
			EXISTS (
					SELECT 1
					FROM (
						SELECT OSFXKF02_BRANCH_NO, MAX(OSFXKF02_EXT_DATE) AS MAX_DATE
						FROM OSFXKF02_MF
						WHERE OSFXKF02_EXT_DATE <= @EXT_DATE
						GROUP BY OSFXKF02_BRANCH_NO
					) Latest
					WHERE OSFXKF02_BRANCH_NO = Latest.OSFXKF02_BRANCH_NO AND
						OSFXKF02_EXT_DATE = Latest.MAX_DATE
				) AND
			(OSFXKF02_VALUE_DATE0 IS NULL OR DATEADD(DAY,@BufferDate,OSFXKF02_VALUE_DATE0) >= @EXT_DATE)
	END TRY
	BEGIN CATCH
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT '發生錯誤: ' + @ErrorMsg;
		THROW;
	END CATCH

END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		AllenChen
-- Create date: 2025/10/17
-- Description:	01OBBS衍伸性商品IRS(OSISKF02_MF) 轉檔，根據分行交易最大日期

-- =============================================
CREATE PROCEDURE [dbo].[usp_Souce01_OBBS_By_OSISKF02_MF] @EXT_DATE AS DATE
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

		DECLARE @BufferDate INT = 14; -- 到期日緩衝時間

		INSERT INTO MonitorData (
			BRANCH_NO, UNIT_NO, PRODUCT_TYPE, TRAN_NO, GROUP_NO, TX_DATE,
			CUSTOMER_NAME, CUSTOMER_ID, COUNTRY_COD, CURENCY_COD, TRAN_AMOUNT,
			LIMIT, LIMIT_COD, MATURITY_DATE, AS_OF_DATE,  FIL9,
			SOURCE, CREATOR, LIMIT_MATURITY, INDUSTRY,INDUSTRY_Type, PRODUCT_CODE,EXT_DATE)
		SELECT
			TRIM(OSISKF02_BRANCH_NO) AS BRANCH_NO,
			'077' AS DIVISION_NO,
			'07' AS PRODUCT_TYPE,
			TRIM(OSISKF02_TRAN_NO) AS TRAN_NO,
			'018' AS BUSINESS_UNIT,
			OSISKF02_TRADE_DATE AS TX_DATE,
			TRIM(OSISKF02_CUST_NAME1) AS CUSTOMER_NAME,
			TRIM(OSISKF02_CUATOMER_ID) AS CUSTOMER_ID,
			TRIM(OSISKF02_CPTY_COUNTRY_RISK) AS COUNTRY_COD,
			TRIM(OSISKF02_IN_CCY) AS CURENCY_COD,
			OSISKF02_risk_amt AS TRAN_AMOUNT,
			OSISKF02_risk_amt AS LIMIT,
			TRIM(OSISKF02_IN_CCY) AS LIMIT_COD,
			OSISKF02_MATURITY AS MATURITY_DATE,
			OSISKF02_TX_DATE AS AS_OF_DATE,
			'OSISKF02_MF' AS FIL9,
			'01' AS source,
			'system' AS creator,
			OSISKF02_MATURITY AS LIMIT_MATURITY,
			TRIM(BUSINS_CODE) AS INDUSTRY,
			2,
			'IRS' AS PRODUCT_CODE,
			@EXT_DATE AS EXT_DATE
		FROM OSISKF02_MF
		WHERE
			TRIM(OSISKF02_CPTY_COUNTRY_RISK) <> 'TW' AND
			 -- 檢查是否為最新資料
			EXISTS (
				SELECT 1
				FROM (
					SELECT OSISKF02_BRANCH_NO, MAX(OSISKF02_EXT_DATE) AS MAX_DATE
					FROM OSISKF02_MF
					WHERE OSISKF02_EXT_DATE <= @EXT_DATE
					GROUP BY OSISKF02_BRANCH_NO
				) Latest
				WHERE OSISKF02_MF.OSISKF02_BRANCH_NO = Latest.OSISKF02_BRANCH_NO AND
					OSISKF02_MF.OSISKF02_EXT_DATE = Latest.MAX_DATE
			) AND
			(OSISKF02_MATURITY IS NULL OR DATEADD(DAY,@BufferDate,OSISKF02_MATURITY) >= @EXT_DATE)
	END TRY
	BEGIN CATCH
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT '發生錯誤: ' + @ErrorMsg;
		THROW;
	END CATCH

END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		AllenChen
-- Create date: 2025/10/17
-- Description:	01OOBS 海外拆款與存同業務(OSMMKF02_MF) 轉檔，根據分行交易最大日期

-- =============================================
CREATE PROCEDURE [dbo].[usp_Souce01_OBBS_By_OSMMKF02_MF] @EXT_DATE DATE
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

		DECLARE @BufferDate INT = 14; -- 到期日緩衝時間

		WITH temp AS (
			SELECT *,
			CASE TRIM(OSMMKF02_TRAN_TYPE) WHEN '1' THEN '09' -- 09 拆款業務
			ELSE '04' -- 04 存同
			END PRODUCT_TYPE,
			CASE TRIM(OSMMKF02_TRAN_TYPE) WHEN '1' THEN OSMMKF02_MATURITY_DATE
			ELSE isnull(OSMMKF02_MATURITY_DATE,DATEADD(MONTH, 1, GETDATE()))
			END MATURITY_DATE,
			CASE TRIM(OSMMKF02_TRAN_TYPE) WHEN '1' THEN OSMMKF02_MATURITY_DATE
			ELSE DATEFROMPARTS(YEAR(GETDATE()), 12, 31)
			END LIMIT_MATURITY
			FROM OSMMKF02_MF
			WHERE TRIM(OSMMKF02_COUNTRY_RISK) <> 'TW' AND
			(TRIM(OSMMKF02_TRAN_TYPE) = '1' OR -- 1 = 09拆款
			(TRIM(OSMMKF02_TRAN_TYPE) IN ('3','4','5','6') AND -- 3,4,5,6  = 04 存同
			 LEFT(TRIM(OSMMKF02_SWIFT_ID), 4) <> 'FCBK')) AND -- FCB 國外分公司(FCBK是 FCB 國內外分行，FCBC 是加州分行，要算入)
			(OSMMKF02_MATURITY_DATE IS NULL OR OSMMKF02_MATURITY_DATE > OSMMKF02_EXT_DATE) AND
			(OSMMKF02_MATURITY_DATE IS NULL OR DATEADD(DAY,@BufferDate,OSMMKF02_MATURITY_DATE) >= @EXT_DATE) AND

			EXISTS (
					SELECT 1
					FROM (
						SELECT OSMMKF02_BRANCH_NO, MAX(OSMMKF02_EXT_DATE) AS MAX_DATE
						FROM OSMMKF02_MF
						WHERE OSMMKF02_EXT_DATE <= @EXT_DATE
						GROUP BY OSMMKF02_BRANCH_NO
					) Latest
					WHERE OSMMKF02_BRANCH_NO = Latest.OSMMKF02_BRANCH_NO
					AND OSMMKF02_EXT_DATE = Latest.MAX_DATE
			)
		)
		INSERT INTO MonitorData (
			BRANCH_NO, UNIT_NO, PRODUCT_TYPE, TRAN_NO, GROUP_NO, TX_DATE,
			CUSTOMER_NAME, CUSTOMER_ID, COUNTRY_COD, CURENCY_COD, TRAN_AMOUNT,
			LIMIT, LIMIT_COD, MATURITY_DATE, AS_OF_DATE, FIL9,
			SOURCE, CREATOR, LIMIT_MATURITY, INDUSTRY,INDUSTRY_Type,EXT_DATE)
		SELECT TRIM(OSMMKF02_BRANCH_NO) AS BRANCH_NO,
			'077' AS DIVISION_NO,
			PRODUCT_TYPE AS PRODUCT_TYPE,
			ISNULL(OSMMKF02_TRAN_NO,
				TRIM(OSMMKF02_BRANCH_NO) +
				TRIM(OSMMKF02_TRAN_TYPE) +
				TRIM(OSMMKF02_SWIFT_ID) +
				TRIM(OSMMKF02_CURENCY_COD)) AS TRAN_NO,
			'018' AS BUSINESS_UNIT,
			OSMMKF02_CONTRACT_DATE AS TX_DATE,
			TRIM(OSMMKF02_CUST_NAME1) AS CUSTOMER_NAME,
			TRIM(OSMMKF02_SWIFT_ID) AS CUSTOMER_ID,
			TRIM(OSMMKF02_COUNTRY_RISK) AS COUNTRY_COD,
			TRIM(OSMMKF02_CURENCY_COD) AS CURENCY_COD,
			ABS(OSMMKF02_TRAN_AMOUNT) AS TRAN_AMOUNT,
			ABS(OSMMKF02_TRAN_AMOUNT) AS LIMIT,
			TRIM(OSMMKF02_CURENCY_COD) AS LIMIT_COD,
			MATURITY_DATE AS MATURITY_DATE,
			OSMMKF02_TX_DATE AS AS_OF_DATE,
			'OSMMKF02_MF' AS FIL9,
			'01' AS source,
			'system' AS creator,
			LIMIT_MATURITY AS LIMIT_MATURITY,
			TRIM(BUSINS_CODE) AS INDUSTRY,
			2,
			@EXT_DATE AS EXT_DATE
		FROM
			temp
		WHERE
			EXISTS (
			SELECT 1
			FROM temp MF2
			WHERE LEFT(TRIM(MF2.OSMMKF02_SWIFT_ID),4) = LEFT(TRIM(OSMMKF02_SWIFT_ID),4)
			GROUP BY LEFT(TRIM(MF2.OSMMKF02_SWIFT_ID),4),case OSMMKF02_TRAN_TYPE when '1' then 1 else 0 end -- 原本有分 1 = 拆放, 其他存同
			HAVING SUM(ABS(MF2.OSMMKF02_TRAN_AMOUNT)) > 0)
	END TRY
	BEGIN CATCH
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT '發生錯誤: ' + @ErrorMsg;
		THROW;
	END CATCH

END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		AllenChen
-- Create date: 2025/10/17
-- Description:	01OBBS之海外各業務交易資料(OS_LNSMSTD_D_MF)與海外各業務額度資料(MF_OS_LNSLMSD_D_MF) 轉檔，根據分行交易最大日期

-- =============================================
CREATE PROCEDURE [dbo].[usp_Souce01_OBBS_By_OS_LNSMSTD_D_MF_OS_LNSLMSD_D_MF] @EXT_DATE AS DATE
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

		DECLARE @BufferDate INT = 14; -- 到期日緩衝時間

		with temp as (
			SELECT DISTINCT Trim(LNSMSTD_BRANCH_NO) AS BRANCH_NO,
			'077' AS Unit_NO,--處級單位代號
			case Trim(LNSMSTD_TX_TYPE)
				WHEN 'SL' THEN '01'  -- 聯合貸款
				WHEN 'GU' THEN '12'  -- 保證
				WHEN 'E3' THEN '03'  -- 保兌
				--WHEN 'E5' THEN '10'  -- 應收帳款承購 --賢欽 2025/11/13 說不用
			ELSE '02' -- 一般放款
			end AS PRODUCT_TYPE,--產品別
			Trim(LNSMSTD_TX_NO) AS TRAN_NO,--交易代號
			'018' AS Group_NO, --事業群代號 海外分行只有海外事業群 所以018
			cast(LNSMSTD_BEGIN_DATE as date) AS TX_DATE, --原始初貸日 = 交易日期
			Trim(LNSLMSD_CUSTOMER_NAME) AS CUSTOMER_NAME, --客戶姓名 -- 空要抓 c100 ，依據跟客戶ID 分行
			Trim(LNSMSTD_CUSTOMER_ID) AS CUSTOMER_ID, -- 客戶ID
			Trim(Isnull(LNSLMSD_COUNTRY_RISK,Isnull(LNSLMSD_REG_COUNTRY,''))) AS COUNTRY_COD,--交易國家 空 要抓c100
			Trim(LNSMSTD_CURRENCY) AS CURENCY_COD, --幣別
			LNSMSTD_BALANCE AS TRAN_AMOUNT, -- 交易金額
			Trim(LNSLMSD_APP_NO) AS PERMIT_NO,--核准編號
			ISNULL(LNSLMSD_APP_AMT,LNSMSTD_BALANCE) AS LIMIT,--核准額度  空 抓 交易金額
			ISNULL(Trim(LNSLMSD_CURRENCY),LNSMSTD_CURRENCY) AS LIMIT_COD, --核准幣別 空 抓交易幣別
			LEFT(LNSMSTD_MATURITY, 8) AS MATURITY_DATE,--到期日
			LNSMSTD_DATA_DATE AS AS_OF_DATE,--資料日期
			CASE TRIM(Isnull(LNSLMSD_CIRCLE,'')) WHEN 'Y' THEN 1 ELSE 0 END AS REVOLVE_MK,--是否循環 空 為 0
			'OS_LNSMSTD_D_MF' AS FIL9,-- 行業別主檔 只有授信產品
			'01' AS source,
			'system' AS creator,
			LNSMSTD_ACC_CODE_INT_9, -- 判斷是否為利息
			LNSMSTD_ACCRUE_INT,--利息
			LNSLMSD_MATURITY AS LIMIT_MATURITY, --額度到期日 空 可能要無限大
			TRIM(LNSM.BUSINS_CODE) AS INDUSTRY, -- 行業別主檔 只有授信產品
			2 AS INDUSTRY_TYPE, --海外
			@EXT_DATE as EXT_DATE
			FROM OS_LNSMSTD_D_MF LNSM --海外分行授信業務交易主檔
			LEFT JOIN OS_LNSLMSD_D_MF LNSL ON --海外分行額度檔
				LNSMSTD_LINE_NO = LNSLMSD_LINE_NO AND -- 額度號碼
				LNSMSTD_BRANCH_NO = LNSLMSD_BRANCH_NO AND -- 分行編號
				LNSMSTD_EXT_DATE = LNSLMSD_EXT_DATE --資料日
			WHERE
			NOT (LNSMSTD_BALANCE = 0 AND ( LNSLMSD_MATURITY IS NULL OR LNSLMSD_MATURITY < LNSMSTD_EXT_DATE)) AND --到期且餘額 = 0 排除
			-- 取到期日要大於轉檔日的資料，除了催收，催收項目為 LNSMSTD_ACC_CODE_INT_9 IN ('135850003','135850004')，催收的項目會超過到期日
			((LNSLMSD_MATURITY IS NULL OR DATEADD(DAY,@BufferDate,LNSLMSD_MATURITY) >= @EXT_DATE) OR
				LNSMSTD_ACC_CODE_INT_9 in ('135850003','135850004')
			) AND
			TRIM(LNSLMSD_COUNTRY_RISK) <> 'TW' AND -- 排除台灣
				 EXISTS (
						SELECT 1
						FROM (
							SELECT LNSMSTD_BRANCH_NO, MAX(LNSMSTD_EXT_DATE) AS MAX_DATE
							FROM OS_LNSMSTD_D_MF
							WHERE LNSMSTD_EXT_DATE <= @EXT_DATE
							GROUP BY LNSMSTD_BRANCH_NO
						) Latest
						WHERE LNSMSTD_BRANCH_NO = Latest.LNSMSTD_BRANCH_NO
						AND LNSMSTD_EXT_DATE = Latest.MAX_DATE
					) AND
				TRIM(lnsmstd_status) <> '2'  -- 排除呆帳
		)
		INSERT INTO MonitorData (
		BRANCH_NO, UNIT_NO, PRODUCT_TYPE, TRAN_NO, GROUP_NO, TX_DATE,
		CUSTOMER_NAME, CUSTOMER_ID, COUNTRY_COD, CURENCY_COD, TRAN_AMOUNT,
		PERMIT_NO, LIMIT, LIMIT_COD, MATURITY_DATE, AS_OF_DATE, REVOLVE_MK, FIL9,
		SOURCE, CREATOR, LIMIT_MATURITY, INDUSTRY,INDUSTRY_Type,EXT_DATE)
		SELECT BRANCH_NO,Unit_NO,PRODUCT_TYPE,TRAN_NO,Group_NO,TX_DATE,CUSTOMER_NAME,
				CUSTOMER_ID,COUNTRY_COD,CURENCY_COD,TRAN_AMOUNT,PERMIT_NO,LIMIT,LIMIT_COD,MATURITY_DATE,AS_OF_DATE,REVOLVE_MK,FIL9,
				source,creator,LIMIT_MATURITY,INDUSTRY,INDUSTRY_TYPE,EXT_DATE
		From temp
		UNION
		-- 利息要再加上去 LNSMSTD_ACC_CODE_INT_9 in ('135850003','135850004') and LNSMSTD_ACCRUE_INT <> 0
			SELECT BRANCH_NO,Unit_NO,PRODUCT_TYPE,TRAN_NO,Group_NO,TX_DATE,CUSTOMER_NAME,
				CUSTOMER_ID,COUNTRY_COD,CURENCY_COD,LNSMSTD_ACCRUE_INT,PERMIT_NO,LIMIT,
				LIMIT_COD,MATURITY_DATE,AS_OF_DATE,REVOLVE_MK,FIL9 + '_Interest',
				source,creator,LIMIT_MATURITY,INDUSTRY,INDUSTRY_TYPE,EXT_DATE
			From temp
			WHERE LNSMSTD_ACC_CODE_INT_9 in ('135850003','135850004') and LNSMSTD_ACCRUE_INT <> 0
		UNION
		-- 未動用但仍有效的授信額度
			SELECT
				TRIM(LNSLMSD_BRANCH_NO) AS BRANCH_NO, --分行代號
				'077' AS DIVISION_NO,--處級單位代號
				case Trim(LNSLMSD_LINE_TYPE)
					WHEN 'SL' THEN '01'  -- 聯合貸款
					WHEN 'SG' THEN '12'  -- 保證
				ELSE '02' -- 一般放款
				end AS PRODUCT_TYPE,--產品別
				'' AS TRAN_NO,--交易代號
				'018' AS BUSINESS_UNIT,--事業群代號
				LNSLMSD_BGN_DATE AS TX_DATE,--交易日期
				TRIM(LNSLMSD_CUSTOMER_NAME) AS CUSTOMER_NAME,--客戶姓名
				TRIM(LNSLMSD_CUSTOMER_ID) AS CUSTOMER_ID,--客戶 ID
				TRIM(LNSLMSD_COUNTRY_RISK) AS COUNTRY_COD, --國家別
				TRIM(LNSLMSD_CURRENCY) AS CURENCY_COD,--幣別
				0 AS TRAN_AMOUNT, --交易金額
				TRIM(LNSLMSD_APP_NO) AS PERMIT_NO,--核准編號
				LNSLMSD_APP_AMT AS LIMIT,--核准額度
				TRIM(LNSLMSD_CURRENCY) AS LIMIT_COD,--核准幣別
				LNSLMSD_MATURITY AS MATURITY_DATE, --到期日
				LNSLMSD_DATA_DATE AS AS_OF_DATE, --資料日期
				CASE TRIM(LNSLMSD_CIRCLE)
					WHEN 'Y' THEN 1
				ELSE 0
				END AS REVOLVE_MK,--是否循環
				'OS_LNSLMSD_D_MF' AS FIL9,
				'01' AS source,
				'system' AS creator,
				LNSLMSD_MATURITY AS LIMIT_MATURITY, -- 額度到期日
				TRIM(a.BUSINS_CODE) AS INDUSTRY,
				2,--海外
				@EXT_DATE AS DATADATE
			FROM OS_LNSLMSD_D_MF a
			Left join OS_LNSMSTD_D_MF b on trim(a.LNSLMSD_BRANCH_NO) = trim(b.LNSMSTD_BRANCH_NO) and
							Trim(a.LNSLMSD_LINE_NO) = trim(b.LNSMSTD_LINE_NO) and
							a.LNSLMSD_EXT_DATE = b.LNSMSTD_EXT_DATE
			WHERE EXISTS (
					SELECT 1
					FROM (
						SELECT LNSLMSD_BRANCH_NO, MAX(LNSLMSD_EXT_DATE) AS MAX_DATE
						FROM OS_LNSLMSD_D_MF
						WHERE LNSLMSD_EXT_DATE <= @EXT_DATE
						GROUP BY LNSLMSD_BRANCH_NO
					) Latest
					WHERE LNSLMSD_BRANCH_NO = Latest.LNSLMSD_BRANCH_NO AND
						LNSLMSD_EXT_DATE = Latest.MAX_DATE AND
						(LNSLMSD_MATURITY IS NULL OR DATEADD(DAY,@BufferDate,LNSLMSD_MATURITY) >= @EXT_DATE)  -- 到期日Buffer後不能過期轉檔日
				  ) AND
				  TRIM(LNSLMSD_LINE_TYPE) IN ('SL','LN','SG','IM','OD','BP') AND
				  TRIM(ISNULL(LNSLMSD_COUNTRY_RISK,'')) <> 'TW' AND
				  LNSLMSD_LINE_NO IS NOT NULL AND
				  b.LNSMSTD_STATUS <> '2' AND
				  b.LNSMSTD_LINE_NO IS NULL
					--LOAN:LN;
					--IMPORT:IM;
					--EXPORT:EX;
					--OVERDRAFT:OD;
					--CLEANBILL:CB;
					--GUARANTEE:SG
					--ACCEPTANCE:AC
					--SYNDICATED:SL
	END TRY
	BEGIN CATCH
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT '發生錯誤: ' + @ErrorMsg;
		THROW;
	END CATCH

END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		AllenChen
-- Create date: 2025/10/17
-- Description:	04存放銀行同業 交易最大日期

-- =============================================
CREATE PROCEDURE [dbo].[usp_Souce04_By_LS_LSRSA_D_MF_ACNOD_STG] @EXT_DATE DATE
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

		INSERT INTO MonitorData (
			BRANCH_NO, UNIT_NO, PRODUCT_TYPE, TRAN_NO, GROUP_NO, TX_DATE,
			CUSTOMER_NAME, CUSTOMER_ID, COUNTRY_COD, CURENCY_COD, TRAN_AMOUNT,
			PERMIT_NO, LIMIT, LIMIT_COD, MATURITY_DATE, AS_OF_DATE, FIL9,
			SOURCE, CREATOR, LIMIT_MATURITY, INDUSTRY,INDUSTRY_Type, EXT_DATE)
		SELECT
			'D01' AS BRANCH_NO,
			'091' AS DIVISION_NO,
			'04' AS PRODUCT_TYPE,
			TRIM(APRV_NO) AS TRAN_NO,
			'018' AS BUSINESS_UNIT,
			EXT_DATE AS TX_DATE,
			TRIM(ENG_NAME) AS CUSTOMER_NAME,
			TRIM(ISIN_CD) AS CUSTOMER_ID,
			TRIM(COUNTRY) AS COUNTRY_COD,
			TRIM(CURRENCY) AS CURENCY_COD,
			LN_BAL AS TRAN_AMOUNT,
			NULL AS PERMIT_NO,
			LN_BAL AS LIMIT,
			TRIM(CURRENCY) AS LIMIT_COD,
			DATEADD(month, 1, GETDATE()) AS MATURITY_DATE,
			EXT_DATE AS AS_OF_DATE,
			'LS_LSRSA_D_MF' AS FIL9,
			'04' AS source,
			'system' AS creator,
			DATEFROMPARTS(YEAR(GETDATE()), 12, 31) AS LIMIT_MATURITY,
			right(BUSINS_CODE,6) AS INDUSTRY,
			1,
			@EXT_DATE AS EXT_DATE
		FROM LS_LSRSA_D_MF
		WHERE (SELECT MAX(EXT_DATE) FROM LS_LSRSA_D_MF WHERE EXT_DATE <= @EXT_DATE) = EXT_DATE AND
			LEFT(ACC_CODE, 5) = '11021' AND
			TRIM(COUNTRY) <> 'TW' AND
			LEFT(TRIM(ISIN_CD), 4) <> 'FCBK'
		UNION ALL
		SELECT
			'098' AS BRANCH_NO,
			'069' AS DIVISION_NO,
			'04' AS PRODUCT_TYPE,
			NULL AS TRAN_NO,
			'016' AS BUSINESS_UNIT,
			ACNOD_EXT_DATE AS TX_DATE,
			'HSBC (GLOBAL CUSTODY CASH)' AS CUSTOMER_NAME,
			'HSBCHKHHGCC' AS CUSTOMER_ID,
			'GB' AS COUNTRY_COD,
			TRIM(ACNOD_CRCY_CODE) AS CURENCY_COD,
			ACNOD_OPER_DATE_BAL_INF AS TRAN_AMOUNT,
			NULL AS PERMIT_NO,
			ACNOD_OPER_DATE_BAL_INF AS LIMIT,
			TRIM(ACNOD_CRCY_CODE) AS LIMIT_COD,
			DATEFROMPARTS(YEAR(GETDATE()), 12, 31) AS MATURITY_DATE,
			ACNOD_EXT_DATE AS AS_OF_DATE,
			'ACNOD_STG' AS FIL9,
			'04' AS source,
			'system' AS creator,
			DATEFROMPARTS(YEAR(GETDATE()), 12, 31) AS LIMIT_MATURITY,
			null AS INDUSTRY,
			null,
			@EXT_DATE AS DATADATE
		FROM ACNOD_STG
		WHERE ACNOD_BRANCH_CODE = '092' AND
	　		 ACNOD_ACC5_CODE = '11134' AND
			ACNOD_ACC5_SUB_CODE = '001' AND
			ACNOD_LAST_BAL_MARK = 'Y' AND
			(SELECT MAX(ACNOD_EXT_DATE) FROM ACNOD_STG WHERE ACNOD_EXT_DATE <= @EXT_DATE) = ACNOD_EXT_DATE;

	END TRY
	BEGIN CATCH
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT '發生錯誤: ' + @ErrorMsg;
		THROW;
	END CATCH

END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		AllenChen
-- Create date: 2025/10/17
-- Description:	06外貸系統(外幣貸款系統) 交易最大日期

-- =============================================
CREATE PROCEDURE [dbo].[usp_Souce06_By_FL_FLMST_D_MF] @EXT_DATE DATE
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

	DECLARE @BufferDate INT = 14; -- 到期日緩衝時間

		WITH TEMP AS(
			SELECT MF.*,right(mf.BUSINS_CODE,6) INDUSTRY,
				   CIF.CIF_CUST_NAME,CR.CountryCode2,
				   LINE.FMLINE_LINE_AMT,LINE.FMLINE_REVOLING_TYPE,
				   LINE.FMLINE_LINE_EXPIRY,
				   LINE.FMLINE_MULT_MERGED_MARK,
				   LINE.FMLINE_MULT_MERGED_APRV_NO,
				   CUR.CRCY_ENG_NAME AS CURNAME,
				   CUR1.CRCY_ENG_NAME AS CURNAME1
			FROM FL_FLMST_D_MF MF
			LEFT JOIN DAILY_CIF_TMP CIF ON FLMST_CUST_ID = CIF.CIF_ID_NO
			LEFT JOIN FM_FMLINE_D_MF LINE ON
				LINE.FMLINE_EXT_DATE = FLMST_EXT_DATE AND
				LINE.FMLINE_DATE_TYPE = '10' AND
				FLMST_APRV_TYPE_1 = LINE.FMLINE_LINE_TYPE AND
				FLMST_CUST_ID = LINE.FMLINE_CUST_ID AND
				FLMST_RECV_BRANCH = LINE.FMLINE_BRANCH AND
				FLMST_APRV_NO_1 = LINE.FMLINE_APRV_NO
			LEFT JOIN CountryMaster CR on TRIM(FLMST_FINAL_RISK_CNTY) = CR.CountryCode4
			INNER JOIN MIS_CRCY_REF CUR ON TRIM(FLMST_CURENCY) = TRIM(CUR.CRCY_CODE)
			INNER JOIN MIS_CRCY_REF CUR1 ON TRIM(FLMST_APRV_CUR_1) = TRIM(CUR1.CRCY_CODE)
			WHERE FLMST_EXT_DATE = (SELECT MAX(FLMST_EXT_DATE) FROM FL_FLMST_D_MF WHERE FLMST_EXT_DATE <= @EXT_DATE) AND
				  TRIM(FLMST_FINAL_RISK_CNTY) NOT IN('0000','1001') AND
				  TRIM(FLMST_DATA_TYPE) = '0' AND　-- 待確認
				  NOT(FLMST_LOAN_TYPE = '10' AND ISNULL(FLMST_SUBSTITUTE_REMIT_MK, '') = 'Y') AND --註記邏輯可能要調整
				  TRIM(FLMST_DATA_STATUS) in ('0', '2', '4') AND -- 2是催收資料 -- 0 一般資料
				  (FLMST_MATURITY IS NULL OR DATEADD(DAY,@BufferDate,FLMST_MATURITY) >= @EXT_DATE)
		)

		-- FMLINE 未來 會添加一個風險國欄位
		-- ELLSTAPV 用分行加核准編號 去串 抓國家
		-- FLMST 原本風險國欄位

		INSERT INTO MonitorData (
		    BRANCH_NO, UNIT_NO, PRODUCT_TYPE, TRAN_NO, GROUP_NO, TX_DATE,
		    CUSTOMER_NAME, CUSTOMER_ID, COUNTRY_COD, CURENCY_COD, TRAN_AMOUNT,
		    PERMIT_NO, LIMIT, LIMIT_COD, MATURITY_DATE, AS_OF_DATE, REVOLVE_MK, FIL9,
			SOURCE, CREATOR, LIMIT_MATURITY,INDUSTRY,INDUSTRY_Type,EXT_DATE)
		SELECT
			TRIM(FLMST_RECV_BRANCH) as BRANCH_NO,
			'064' as DIVISION_NO,
			'02' as PRODUCT_TYPE,
			TRIM(FLMST_LC_NO) as TRAN_NO,
			'011' as BUSINESS_UNIT,
			FLMST_NEGO_DATE as TX_DATE,
			TRIM(CIF_CUST_NAME) as CUSTOMER_NAME,
			TRIM(FLMST_CUST_ID) as CUSTOMER_ID,
			CountryCode2 as COUNTRY_COD,
			TRIM(CURNAME) as CURENCY_COD,
			FLMST_ADVANCE_BALANCE as TRAN_AMOUNT,
			TRIM(FLMST_APRV_NO_1) as PERMIT_NO,
			FMLINE_LINE_AMT as [LIMIT],
			TRIM(CURNAME1) as LIMIT_COD,
			FLMST_MATURITY as MATURITY_DATE,
			FLMST_EXT_DATE as AS_OF_DATE,
			CASE FMLINE_REVOLING_TYPE WHEN '1' THEN 1
				 ELSE 0
				 END as REVOLVE_MK,
			'FL_FLMST_D_MF1' as FIL9,
			'06' as source,
			'system' as creator,
			FMLINE_LINE_EXPIRY as LIMIT_MATURITY,
			INDUSTRY as INDUSTRY,
			1,
			@EXT_DATE AS EXT_DATE
		FROM TEMP
		WHERE TRIM(FLMST_LOAN_TYPE) IN ('24','26')
		UNION
		SELECT
			TRIM(FLMST_RECV_BRANCH) as BRANCH_NO,
			'067' as DIVISION_NO,
			'02' as PRODUCT_TYPE,
			TRIM(FLMST_LC_NO) as TRAN_NO,
			'013' as BUSINESS_UNIT,
			FLMST_NEGO_DATE as TX_DATE,
			TRIM(CIF_CUST_NAME) as CUSTOMER_NAME,
			TRIM(FLMST_CUST_ID) as CUSTOMER_ID,
			CountryCode2 as COUNTRY_COD,
			TRIM(CURNAME) as CURENCY_COD,
			FLMST_ADVANCE_BALANCE as TRAN_AMOUNT,
			TRIM(FLMST_APRV_NO_1) as PERMIT_NO,
			FMLINE_LINE_AMT as [LIMIT],
			TRIM(CURNAME1) as LIMIT_COD,
			FLMST_MATURITY as MATURITY_DATE,
			FLMST_EXT_DATE as AS_OF_DATE,
			CASE FMLINE_REVOLING_TYPE WHEN '1' THEN 1
				 ELSE 0
				 END as REVOLVE_MK,
			'FL_FLMST_D_MF2' as FIL9,
			'06' as source,
			'system' as creator,
			FMLINE_LINE_EXPIRY as LIMIT_MATURITY,
			INDUSTRY as INDUSTRY,
			1,
			@EXT_DATE AS DATADATE
		FROM TEMP
		WHERE TRIM(FLMST_LOAN_TYPE) IN ('25','27','28','29')
		UNION
		SELECT
			TRIM(FLMST_RECV_BRANCH) as BRANCH_NO,
			CASE TRIM(FLMST_RECV_BRANCH)
				WHEN '091' THEN '091'
				WHEN '095' THEN '077'
			ELSE '064'
			END as DIVISION_NO,
			CASE WHEN FLMST_LOAN_TYPE IN ('01','02','03','04','05','06','07','08','11','12','13')
					THEN '02'
				WHEN FLMST_LOAN_TYPE = '09'
					THEN '01'
				WHEN FLMST_LOAN_TYPE = '10'
					THEN '12'
				ELSE '02'
			END as PRODUCT_TYPE,
			TRIM(FLMST_LC_NO) as TRAN_NO,
			CASE WHEN TRIM(FLMST_RECV_BRANCH) IN ('091','095')
				THEN '018'
			ELSE '011'
			END as BUSINESS_UNIT,
			FLMST_NEGO_DATE as TX_DATE,
			TRIM(CIF_CUST_NAME) as CUSTOMER_NAME,
			TRIM(FLMST_CUST_ID) as CUSTOMER_ID,
			CountryCode2 as COUNTRY_COD,
			TRIM(CURNAME) as CURENCY_COD,
			--CASE WHEN FLMST_LOAN_TYPE = '10'
			--	THEN FLMST_ADVANCE_BALANCE + FLMST_DISCOUNT_INT
			--	ELSE FLMST_ADVANCE_BALANCE END as TRAN_AMOUNT,
			FLMST_ADVANCE_BALANCE as TRAN_AMOUNT, -- 未來換上面那個
			TRIM(FLMST_APRV_NO_1) as PERMIT_NO,
			FMLINE_LINE_AMT as [LIMIT],
			TRIM(CURNAME1) as LIMIT_COD,
			FLMST_MATURITY as MATURITY_DATE, -- 改成close_date
			FLMST_EXT_DATE as AS_OF_DATE,
			CASE FMLINE_REVOLING_TYPE WHEN '1' THEN 1
				 ELSE 0
				 END as REVOLVE_MK,
			'FL_FLMST_D_MF3' as FIL9,
			'06' as source,
			'system' as creator,
			FMLINE_LINE_EXPIRY as LIMIT_MATURITY,
			INDUSTRY as INDUSTRY,
			1,
			@EXT_DATE AS DATADATE
		FROM TEMP
		WHERE TRIM(FLMST_LOAN_TYPE) NOT IN ('24','25','26','27')
		UNION
		SELECT  -- 額度檔
			TRIM(LINE.FMLINE_BRANCH) as BRANCH_NO,
			CASE TRIM(FLMST_RECV_BRANCH)
				WHEN '091' THEN '091'
				WHEN '095' THEN '077'
			ELSE '064'
			END as DIVISION_NO,
			'' as PRODUCT_TYPE, ---目前沒辦法分產品別
			'' as TRAN_NO,
			CASE WHEN TRIM(FLMST_RECV_BRANCH) IN ('091','095')
				THEN '018'
			ELSE '011'
			END as BUSINESS_UNIT,
			LINE.FMLINE_APRV_DATE as TX_DATE,
			TRIM(CIF_CUST_NAME) as CUSTOMER_NAME,
			TRIM(FMLINE_CUST_ID) as CUSTOMER_ID,
			 --ISNULL(LINE.FMLINE_FINAL_RISK_CNTY,ELL.RISK_NACTION_ID) as COUNTRY_COD,
			LINE.BUSINS_CODE as COUNTRY_COD, -- 要跟其他TABLE 拿，等資訊步道給我 -- LINE.FMLINE_FINAL_RISK_CNTY
			'' as CURENCY_COD,
			'' as TRAN_AMOUNT,
			LINE.FMLINE_APRV_NO as PERMIT_NO,
			LINE.FMLINE_LINE_AMT as [LIMIT],
			LINE.FMLINE_LINE_CURENCY as LIMIT_COD,
			LINE.FMLINE_LINE_EXPIRY as MATURITY_DATE,
			LINE.FMLINE_EXT_DATE as AS_OF_DATE, -- 不確定
			CASE LINE.FMLINE_REVOLING_TYPE WHEN '1' THEN 1
				 ELSE 0
				 END as REVOLVE_MK,
			'FM_FMLINE_D_MF' as FIL9,
			'06' as source,
			'system' as creator,
			FMLINE_LINE_EXPIRY as LIMIT_MATURITY,
			'' as INDUSTRY, -- 待確認
			1,
			@EXT_DATE AS DATADATE
		FROM FM_FMLINE_D_MF LINE
		--LEFT JOIN ELLSTAPV ELL ON LINE.FMLINE_CUST_ID = ELL.ELLSTAPV_CUST_ID AND LINE.FMLINE_APRV_NO = ELLSTAPV_APRV_NO  -- 未來要串這個去看國別
		-- 未來FM_FMLINE_D_MF 會有多一個欄位是 FMLINE_OBBS_APRV_NO 海外核准號碼，是為了RISKLINEO 匯入是對應 APROVE_NO，如果有就不用匯入RISKLINEO
		-- RISKLINED 核准編號對應 FMLINE_APRV_NO，如果有就排除RISKLINED
		LEFT JOIN FL_FLMST_D_MF FLMST ON
			LINE.FMLINE_EXT_DATE = FLMST_EXT_DATE AND
			LINE.FMLINE_DATE_TYPE = '10' AND
			FLMST_APRV_TYPE_1 = LINE.FMLINE_LINE_TYPE AND
			FLMST_CUST_ID = LINE.FMLINE_CUST_ID AND
			FLMST_RECV_BRANCH = LINE.FMLINE_BRANCH AND
			FLMST_APRV_NO_1 = LINE.FMLINE_APRV_NO
		LEFT JOIN DAILY_CIF_TMP CIF ON LINE.FMLINE_CUST_ID = CIF.CIF_ID_NO
		WHERE FLMST.FLMST_ACNT_BRANCH IS NULL

	END TRY
	BEGIN CATCH
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT '發生錯誤: ' + @ErrorMsg;
		THROW;
	END CATCH

END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		AllenChen
-- Create date: 2025/10/17
-- Description:	09SUKBD2附買回之資料擷取 交易最大日期
-- =============================================
CREATE PROCEDURE [dbo].[usp_Souce09_By_ARS_SUKBD2_D_MF] @EXT_DATE DATE
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY

        DECLARE @BufferDate INT = 14;

        INSERT INTO MonitorData (
            BRANCH_NO, UNIT_NO, PRODUCT_TYPE, TRAN_NO, GROUP_NO, TX_DATE,
            CUSTOMER_NAME, CUSTOMER_ID, COUNTRY_COD, CURENCY_COD, TRAN_AMOUNT,
            PERMIT_NO, LIMIT, LIMIT_COD, MATURITY_DATE, AS_OF_DATE, FIL9,
            SOURCE, CREATOR, LIMIT_MATURITY, INDUSTRY, INDUSTRY_Type, EXT_DATE)
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
            TRIM(MF.BUSINS_CODE)                                                 AS INDUSTRY,
            1                                                                    AS INDUSTRY_Type,
            @EXT_DATE                                                            AS EXT_DATE
        FROM ARS_SUKBD2_D_MF MF
        WHERE MF.SUKBD2_EXT_DATE = (
                SELECT MAX(SUKBD2_EXT_DATE)
                FROM ARS_SUKBD2_D_MF
                WHERE SUKBD2_EXT_DATE < @EXT_DATE
              ) AND
              MF.SUKBD2_TRADE_TYPE <> 'RP' AND
              TRIM(MF.SUKBD2_ISSUER_COUNTRY) <> 'TW' AND
              (MF.SUKBD2_END_DATE IS NULL OR
               DATEADD(DAY, @BufferDate, MF.SUKBD2_END_DATE) >= @EXT_DATE);

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT '發生錯誤: ' + @ErrorMsg;
        THROW;
    END CATCH
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		AllenChen
-- Create date: 2025/10/17
-- Description:	09SUKBDO衍伸性商品之資料擷取 交易最大日期

-- =============================================
CREATE PROCEDURE [dbo].[usp_Souce09_By_ARS_SUKBDO_D_MF] @EXT_DATE DATE
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

		INSERT INTO MonitorData (
			BRANCH_NO, UNIT_NO, PRODUCT_TYPE, TRAN_NO, GROUP_NO, TX_DATE,
			CUSTOMER_NAME, CUSTOMER_ID, COUNTRY_COD, CURENCY_COD, TRAN_AMOUNT,
			LIMIT, LIMIT_COD, MATURITY_DATE, AS_OF_DATE,  FIL9,
			SOURCE, CREATOR, LIMIT_MATURITY, INDUSTRY,INDUSTRY_Type, PRODUCT_CODE,EXT_DATE)
		SELECT
			trim(SUKBDO_BRANCH_NO) AS BRANCH_NO,
			CASE WHEN SUKBDO_BRANCH_NO IN('098','095','082') AND UPPER(TRIM(SUKBDO_DESK)) = 'STRUCTS_PD'
				THEN '089'
				ELSE '069'
			END AS DIVISION_NO,
			'07' AS PRODUCT_TYPE, -- 衍生性金融商品
			trim(SUKBDO_POSITIONID) AS TRAN_NO,
			'016' AS BUSINESS_UNIT,
			SUKBDO_TX_DATE	AS TX_DATE,
			trim(SUKBDO_CUST_NAME) AS CUSTOMER_NAME,
			trim(SUKBDO_CUSTOMER_ID) AS CUSTOMER_ID,
			trim(SUKBDO_CPTY_COUNTRY_RISK) AS COUNTRY_COD,
			'USD' AS CURENCY_COD,
			0 As TRAN_AMOUNT,
			--SUKBDO_RISK_AMT	AS TO_USD_AMT,
			--0 AS TO_USD_FXRATE,
			0 AS LIMIT,
			'USD' AS LIMIT_COD,
			--SUKBDO_RISK_AMT	AS TO_USD_LIMIT,
			SUKBDO_OPTIONEXPIRYDATE	AS MATURITY_DATE,
			SUKBDO_EXT_DATE AS AS_OF_DATE,
			'ARS_SUKBDO_D_MF' as FIL9,
			'09' as source,
			'system' as creator,
			SUKBDO_OPTIONEXPIRYDATE as LIMIT_MATURITY,
			TRIM(BUSINS_CODE) AS INDUSTRY,
			1,
			'BO' AS PRODUCT_CODE,
			@EXT_DATE AS EXT_DATE
		FROM ARS_SUKBDO_D_MF
		WHERE
			SUKBDO_EXT_DATE = (select max(SUKBDO_EXT_DATE)from ARS_SUKBDO_D_MF WHERE SUKBDO_EXT_DATE < @EXT_DATE) AND
			SUKBDO_BUY_SELL ='1' AND
			SUKBDO_CPTY_COUNTRY_RISK <> 'TW'


	END TRY
	BEGIN CATCH
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT '發生錯誤: ' + @ErrorMsg;
		THROW;
	END CATCH

END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		AllenChen
-- Create date: 2025/10/17
-- Description:	09ARS_SUKFRA_D_MF FRA衍伸性商品之資料擷取 交易最大日期

-- =============================================
CREATE PROCEDURE [dbo].[usp_Souce09_By_ARS_SUKFRA_D_MF] @EXT_DATE DATE
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

		INSERT INTO MonitorData (
			BRANCH_NO, UNIT_NO, PRODUCT_TYPE, TRAN_NO, GROUP_NO, TX_DATE,
			CUSTOMER_NAME, CUSTOMER_ID, COUNTRY_COD, CURENCY_COD, TRAN_AMOUNT,
			LIMIT, LIMIT_COD, MATURITY_DATE, AS_OF_DATE,  FIL9,
			SOURCE, CREATOR, LIMIT_MATURITY, INDUSTRY,INDUSTRY_Type, PRODUCT_CODE,EXT_DATE)
		SELECT
			trim(SUKFRA_BRANCH_NO) AS BRANCH_NO,
			CASE WHEN SUKFRA_BRANCH_NO IN('098','095','082') AND UPPER(TRIM(SUKFRA_SUPERVISOR)) = 'STRUCTS_PD'
				THEN '089'
				ELSE '069'
			END AS DIVISION_NO,
			'07' AS PRODUCT_TYPE, -- 衍生性金融商品
			trim(SUKFRA_TRADE_ID) AS TRAN_NO,
			'016' AS BUSINESS_UNIT,
			SUKFRA_TRADE_DATE AS TX_DATE,
			trim(SUKFRA_CUST_NAME2) AS CUSTOMER_NAME,
			trim(SUKFRA_CUSTOMER_ID) AS CUSTOMER_ID,
			trim(SUKFRA_CPTY_COUNTRY_RISK)	AS COUNTRY_COD,
			trim(SUKFRA_CCY)	AS CURENCY_COD,
			0 As TRAN_AMOUNT,
			--SUKFRA_RISK_AMT	AS TO_USD_AMT,
			--0		AS TO_USD_FXRATE,
			0 AS LIMIT,
			trim(SUKFRA_CCY) AS LIMIT_COD,
			--SUKFRA_RISK_AMT	AS     TO_USD_LIMIT,
			SUKFRA_MATURITY AS MATURITY_DATE,
			SUKFRA_EXT_DATE AS AS_OF_DATE,
			'ARS_SUKFRA_D_MF' as FIL9,
			'09' as source,
			'system' as creator,
			SUKFRA_MATURITY as LIMIT_MATURITY,
			TRIM(SUKFRA_CPTY_BUSINESS) AS INDUSTRY,
			1,
			'FRA',
			@EXT_DATE
		FROM ARS_SUKFRA_D_MF
		WHERE SUKFRA_EXT_DATE = (select max(SUKFRA_EXT_DATE) from ARS_SUKFRA_D_MF WHERE SUKFRA_EXT_DATE < @EXT_DATE) AND
			SUKFRA_BUY_SELL = '1' AND
			SUKFRA_CPTY_COUNTRY_RISK <> 'TW'


	END TRY
	BEGIN CATCH
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT '發生錯誤: ' + @ErrorMsg;
		THROW;
	END CATCH

END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		AllenChen
-- Create date: 2025/10/17
-- Description:	09ARS_SUKIRO_D_MF IRO衍伸性商品之資料擷取 交易最大日期

-- =============================================
CREATE PROCEDURE [dbo].[usp_Souce09_By_ARS_SUKIRO_D_MF] @EXT_DATE DATE
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

		INSERT INTO MonitorData (
		    BRANCH_NO, UNIT_NO, PRODUCT_TYPE, TRAN_NO, GROUP_NO, TX_DATE,
		    CUSTOMER_NAME, CUSTOMER_ID, COUNTRY_COD, CURENCY_COD, TRAN_AMOUNT,
		    LIMIT, LIMIT_COD, MATURITY_DATE, AS_OF_DATE,  FIL9,
		    SOURCE, CREATOR, LIMIT_MATURITY, INDUSTRY,INDUSTRY_Type, PRODUCT_CODE,EXT_DATE)
		SELECT
			trim(SUKIRO_BRANCH_NO) AS BRANCH_NO,
			CASE WHEN SUKIRO_BRANCH_NO IN('098','095','082') AND UPPER(TRIM(SUKIRO_SUPERVISOR)) = 'STRUCTS_PD'
				THEN '089'
				ELSE '069'
			END AS DIVISION_NO,
			'07' AS PRODUCT_TYPE, -- 衍生性金融商品
			trim(SUKIRO_TRADE_ID) AS TRAN_NO,
			'016' AS BUSINESS_UNIT,
			SUKIRO_TRADE_DATE AS TX_DATE,
			trim(SUKIRO_CUST_NAME2) AS CUSTOMER_NAME,
			trim(SUKIRO_CUSTOMER_ID) AS CUSTOMER_ID,
			trim(SUKIRO_CPTY_COUNTRY_RISK)	AS COUNTRY_COD,
			trim(SUKIRO_CCY)	AS CURENCY_COD,
			0 As TRAN_AMOUNT,
			--SUKIRO_RISK_AMT	AS TO_USD_AMT,
			--0 AS TO_USD_FXRATE,
			0 AS LIMIT,
			trim(SUKIRO_CCY) AS LIMIT_COD,
			--SUKIRO_RISK_AMT	AS TO_USD_LIMIT,
			SUKIRO_MATURITY_DATE	AS MATURITY_DATE,
			SUKIRO_EXT_DATE AS AS_OF_DATE,
			'ARS_SUKIRO_D_MF' as FIL9,
			'09' as source,
			'system' as creator,
			SUKIRO_MATURITY_DATE AS LIMIT_MATURITY,
			TRIM(SUKIRO_CPTY_BUSINESS) AS INDUSTRY,
			1,
			'IRO' AS PRODUCT_CODE,
			@EXT_DATE
		FROM
			ARS_SUKIRO_D_MF
		WHERE
			SUKIRO_EXT_DATE = (select max(SUKIRO_EXT_DATE) from ARS_SUKIRO_D_MF WHERE SUKIRO_EXT_DATE < @EXT_DATE) AND
			SUKIRO_BUY_SELL ='1' AND
			SUKIRO_CPTY_COUNTRY_RISK <> 'TW'

	END TRY
	BEGIN CATCH
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT '發生錯誤: ' + @ErrorMsg;
		THROW;
	END CATCH

END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		AllenChen
-- Create date: 2025/10/17
-- Description:	09ARS_SUKMST_D_MF IRS衍伸性商品之資料擷取 交易最大日期

-- =============================================
CREATE PROCEDURE [dbo].[usp_Souce09_By_ARS_SUKMST_D_MF] @EXT_DATE DATE
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

		INSERT INTO MonitorData (
			BRANCH_NO, UNIT_NO, PRODUCT_TYPE, TRAN_NO, GROUP_NO, TX_DATE,
			CUSTOMER_NAME, CUSTOMER_ID, COUNTRY_COD, CURENCY_COD, TRAN_AMOUNT,
			LIMIT, LIMIT_COD, MATURITY_DATE, AS_OF_DATE,  FIL9,
			SOURCE, CREATOR, LIMIT_MATURITY, INDUSTRY,INDUSTRY_Type, PRODUCT_CODE,EXT_DATE)
		SELECT
			trim(SUKMST_BRANCH_NO) AS BRANCH_NO,
			CASE WHEN SUKMST_BRANCH_NO IN('098','095','082') AND UPPER(TRIM(SUKMST_SUPERVISOR)) = 'STRUCTS_PD'
				THEN '089'
				ELSE '069'
			END AS DIVISION_NO,
			'07' AS PRODUCT_TYPE, -- 衍生性金融商品
			trim(SUKMST_TRAN_NO) AS TRAN_NO,
			'016' AS BUSINESS_UNIT,
			SUKMST_TRADE_DATE AS TX_DATE,
			trim(SUKMST_CUST_NAME2) AS CUSTOMER_NAME,
			trim(SUKMST_CUSTOMER_ID) AS CUSTOMER_ID,
			trim(SUKMST_CPTY_COUNTRY_RISK)	AS COUNTRY_COD,
			trim(SUKMST_OUT_CCY) AS CURENCY_COD,
			0 As TRAN_AMOUNT,
			--SUKMST_RISK_AMT	AS TO_USD_AMT,
			--0 AS TO_USD_FXRATE,
			0 AS LIMIT,
			trim(SUKMST_OUT_CCY) AS LIMIT_COD,
			--SUKMST_RISK_AMT	AS TO_USD_LIMIT,
			SUKMST_MATURITY	AS MATURITY_DATE,
			SUKMST_EXT_DATE AS AS_OF_DATE,
			'ARS_SUKMST_D_MF' as FIL9,
			'09' as source,
			'system' as creator,
			SUKMST_MATURITY as LIMIT_MATURITY,
			TRIM(SUKMST_CPTY_BUSINESS) AS INDUSTRY,
			1,
			'IRS' AS PRODUCT_CODE,
			@EXT_DATE AS EXT_DATE
		FROM ARS_SUKMST_D_MF MF
		WHERE
			SUKMST_EXT_DATE = (SELECT MAX(SUKMST_EXT_DATE) FROM ARS_SUKMST_D_MF WHERE SUKMST_EXT_DATE < @EXT_DATE) AND
			SUKMST_BUY_SELL ='1' AND
			ISNULL(SUKMST_DEPOSIT_LINK,'') NOT IN('SPD','DCD') AND
			SUKMST_ESTIMATE_FX <> 0 AND -- 因為SUMMIT來的資料有時會給0，計算會錯(不可以除以0)，要排除
			SUKMST_CPTY_COUNTRY_RISK <> 'TW'

	END TRY
	BEGIN CATCH
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT '發生錯誤: ' + @ErrorMsg;
		THROW;
	END CATCH

END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		AllenChen
-- Create date: 2025/10/17
-- Description:	09SUKNBD1債券投資之資料擷取 交易最大日期

-- =============================================
CREATE PROCEDURE [dbo].[usp_Souce09_By_ARS_SUKNBD1_D_MF] @EXT_DATE DATE
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		INSERT INTO MonitorData (
			BRANCH_NO, UNIT_NO, PRODUCT_TYPE, TRAN_NO, GROUP_NO, TX_DATE,
			CUSTOMER_NAME, CUSTOMER_ID, COUNTRY_COD, CURENCY_COD, TRAN_AMOUNT,
			PERMIT_NO, LIMIT, LIMIT_COD, MATURITY_DATE, AS_OF_DATE, REVOLVE_MK, FIL9,
			SOURCE, CREATOR, LIMIT_MATURITY, INDUSTRY,INDUSTRY_Type,EXT_DATE)
		SELECT
			TRIM(SUKBD1_BRANCH_NO) AS BRANCH_NO,
			CASE WHEN SUKBD1_BRANCH_NO IN('098','095','082') AND UPPER(TRIM(SUKBD1_SUPERVISOR)) = 'STRUCTS_PD'
				THEN '089'
				ELSE '069'
			END AS DIVISION_NO,
			'08' AS PRODUCT_TYPE,
			TRIM(SUKBD1_TRAN_NO) AS TRAN_NO,
			'016' AS BUSINESS_UNIT,
			SUKBD1_TX_DATE AS TX_DATE,
			TRIM(SUKBD1_CUST_NAME1) AS CUSTOMER_NAME,
			TRIM(SUKBD1_SWIFT_ID) AS CUSTOMER_ID,
			ISNULL(NULLIF(SUKBD1_ISSUER_COUNTRY,''), TRIM(SUKBD1_GU_LOG_CTY)) AS COUNTRY_COD,
			TRIM(SUKBD1_CURENCY_COD) AS CURENCY_COD,
			CASE UPPER(TRIM(SUKBD1_BUY_SELL)) WHEN 'B' THEN SUKBD1_BALANCE_AMT
											  WHEN 'S' THEN SUKBD1_BALANCE_AMT * -1
			END As TRAN_AMOUNT,
			SUKBD1_LINE_PERMIT_NO AS PERMIT_NO,
			CASE UPPER(TRIM(SUKBD1_BUY_SELL)) WHEN 'B' THEN SUKBD1_BALANCE_AMT
											  WHEN 'S' THEN SUKBD1_BALANCE_AMT * -1
			END AS LIMIT,
			TRIM(SUKBD1_CURENCY_COD) AS LIMIT_COD,
			SUKBD1_MATURITY_DATE AS MATURITY_DATE,
			SUKBD1_EXT_DATE AS AS_OF_DATE,
			0 AS REVOLVE_MK,
			'ARS_SUKNBD1_D_MF' as FIL9,
			'09' as source,
			'system' as creator,
			SUKBD1_MATURITY_DATE as LIMIT_MATURITY,
			TRIM(SUKBD1_ISSUER_BUSINESS) AS INDUSTRY,
			1,
			@EXT_DATE AS EXT_DATE
		FROM ARS_SUKNBD1_D_MF
		WHERE SUKBD1_EXT_DATE = (SELECT MAX(SUKBD1_EXT_DATE) FROM ARS_SUKNBD1_D_MF WHERE SUKBD1_EXT_DATE < @EXT_DATE) AND
			EXISTS (
				SELECT 1
				FROM ARS_SUKNBD1_D_MF MF2
				WHERE MF2.SUKBD1_EXT_DATE = ARS_SUKNBD1_D_MF.SUKBD1_EXT_DATE AND
					  MF2.SUKBD1_CUST_NAME1 = ARS_SUKNBD1_D_MF.SUKBD1_CUST_NAME1 AND
					  ISNULL(NULLIF(MF2.SUKBD1_ISSUER_COUNTRY,''), TRIM(MF2.SUKBD1_GU_LOG_CTY)) <> 'TW'
				GROUP BY MF2.SUKBD1_CUST_NAME1
				HAVING SUM( CASE UPPER(TRIM(MF2.SUKBD1_BUY_SELL)) WHEN 'B' THEN MF2.SUKBD1_BALANCE_AMT
																  WHEN 'S' THEN MF2.SUKBD1_BALANCE_AMT * -1
							END) > 0
			) AND
			ISNULL(NULLIF(SUKBD1_ISSUER_COUNTRY,''), TRIM(SUKBD1_GU_LOG_CTY))  <> 'TW' AND
			NOT(SUKBD1_MATURITY_DATE = SUKBD1_EXT_DATE AND
				SUKBD1_CURENCY_COD = 'TWD' AND
				SUKBD1_SECURITY_TYPE = 'BILL' AND
				SUKBD1_SEC_SUB_TYPE ='CP2');
	END TRY
	BEGIN CATCH
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT '發生錯誤: ' + @ErrorMsg;
		THROW;
	END CATCH

END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		AllenChen
-- Create date: 2025/10/17
-- Description:	09SUKNFO 衍生性商品(外匯選擇權) 交易最大日期

-- =============================================
CREATE PROCEDURE [dbo].[usp_Souce09_By_ARS_SUKNFO_D_MF] @EXT_DATE DATE
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		-- 衍生性金融商品資料
		INSERT INTO MonitorData (
			BRANCH_NO, UNIT_NO, PRODUCT_TYPE, TRAN_NO, GROUP_NO, TX_DATE,
			CUSTOMER_NAME, CUSTOMER_ID, COUNTRY_COD, CURENCY_COD, TRAN_AMOUNT,
			LIMIT, LIMIT_COD, MATURITY_DATE, AS_OF_DATE, FIL9,
			SOURCE, CREATOR, LIMIT_MATURITY, INDUSTRY,INDUSTRY_Type,CUR_BOUGHT,CUR_SOLD,EXT_DATE)
		SELECT
			TRIM(SUKFO_ACC_BRANCH_NO) AS BRANCH_NO,
			CASE WHEN SUKFO_ACC_BRANCH_NO IN('098','095','082') AND UPPER(TRIM(SUKFO_SUPERVISOR)) = 'STRUCTS_PD'
				THEN '089'
				ELSE '069'
			END AS DIVISION_NO,
			'07' AS PRODUCT_TYPE,                                   -- 衍生性金融商品
			TRIM(SUKFO_TRADE_ID) AS TRAN_NO,
			'016' AS BUSINESS_UNIT,
			SUKFO_TRADE_DATE AS TX_DATE,
			TRIM(SUKFO_CPTY_NAME) AS CUSTOMER_NAME,
			TRIM(SUKFO_BANK_SWIFT_ID) AS CUSTOMER_ID,
			TRIM(SUKFO_CPTY_COUNTRY_RISK) AS COUNTRY_COD,
			TRIM(SUKFO_OBJECT_CCY) AS CURENCY_COD,
			SUKFO_OBJECT_AMT AS TRAN_AMOUNT,
			SUKFO_OBJECT_AMT AS LIMIT,
			TRIM(SUKFO_OBJECT_CCY) AS LIMIT_COD,
			SUKFO_VALUE_DATE0 AS MATURITY_DATE,
			SUKFO_EXT_DATE AS AS_OF_DATE,
			'ARS_SUKNFO_D_MF' as FIL9,
			'09' as source,
			'system' as creator,
			SUKFO_VALUE_DATE0 as LIMIT_MATURITY,
			TRIM(SUKFO_CPTY_BUSINESS) AS INDUSTRY,
			1,
			TRIM(SUKFO_TRAN_BUY) AS CUR_BOUGHT,
			TRIM(SUKFO_TRAN_SELL) AS CUR_SOLD,
			@EXT_DATE
		FROM ARS_SUKNFO_D_MF
		WHERE
			SUKFO_EXT_DATE = (select max(SUKFO_EXT_DATE) from ARS_SUKNFO_D_MF WHERE SUKFO_EXT_DATE < @EXT_DATE)
			AND SUKFO_TRAN_TYPE = 'B'
			AND SUKFO_CPTY_NAME <> 'DCD_ONLINE'
			AND SUKFO_PRAM_CCY IS NULL
			AND SUKFO_CPTY_COUNTRY_RISK <> 'TW';
	END TRY
	BEGIN CATCH
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT '發生錯誤: ' + @ErrorMsg;
		THROW;
	END CATCH

END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		AllenChen
-- Create date: 2025/10/17
-- Description:	09SUKNFX 衍生性商品(NDF及保證金交易)之資料擷取 交易最大日期

-- =============================================
CREATE PROCEDURE [dbo].[usp_Souce09_By_ARS_SUKNFX_D_MF] @EXT_DATE DATE
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		INSERT INTO MonitorData (
			BRANCH_NO, UNIT_NO, PRODUCT_TYPE, TRAN_NO, GROUP_NO, TX_DATE,
			CUSTOMER_NAME, CUSTOMER_ID, COUNTRY_COD, CURENCY_COD, TRAN_AMOUNT,
			PERMIT_NO, LIMIT, LIMIT_COD, MATURITY_DATE, AS_OF_DATE, REVOLVE_MK, FIL9,
			SOURCE, CREATOR, LIMIT_MATURITY, INDUSTRY,INDUSTRY_Type,CUR_BOUGHT,CUR_SOLD,EXT_DATE)
		SELECT
			TRIM(SUKFX_BRANCH_NO) AS BRANCH_NO,
			CASE
				WHEN SUBSTRING(SUKFX_CUSTOMER_ID, 2, 1) < 'A' AND SUKFX_TX_TYPE IN('02', '03') THEN '077'
				WHEN SUKFX_BRANCH_NO IN('098','095','082') AND UPPER(TRIM(SUKFX_SUPERVISOR)) = 'STRUCTS_PD'
				THEN '089'
				ELSE '069'
				END AS DIVISION_NO,
			'07' AS PRODUCT_TYPE,
			TRIM(SUKFX_TRAN_NO) AS TRAN_NO,
			CASE WHEN SUBSTRING(SUKFX_CUSTOMER_ID, 2, 1) < 'A' AND SUKFX_TX_TYPE IN('02', '03') THEN '018'
				 ELSE '016' END AS BUSINESS_UNIT,
			SUKFX_TX_DATE AS TX_DATE,
			TRIM(SUKFX_CUST_NAME1) AS CUSTOMER_NAME,
			TRIM(SUKFX_CUSTOMER_ID) AS CUSTOMER_ID,
			TRIM(SUKFX_CPTY_COUNTRY_RISK) AS COUNTRY_COD,
			TRIM(SUKFX_OBJECT_CCY) AS CURENCY_COD,
			SUKFX_OBJECT_AMT As TRAN_AMOUNT,
			NULL AS PERMIT_NO,
			SUKFX_OBJECT_AMT AS LIMIT,
			TRIM(SUKFX_OBJECT_CCY) AS LIMIT_COD,
			SUKFX_VALUE_DATE0 AS MATURITY_DATE,
			SUKFX_EXT_DATE AS AS_OF_DATE,
			0 AS REVOLVE_MK,
			'ARS_SUKNFX_D_MF' as FIL9,
			'09' as source,
			'system' as creator,
			SUKFX_VALUE_DATE0 as LIMIT_MATURITY,
			TRIM(SUKFX_CPTY_BUSINESS) AS INDUSTRY,
			1,
			SUKFX_CUR_BOUGHT AS CUR_BOUGHT,
			SUKFX_CUR_SOLD AS CUR_SOLD,
			@EXT_DATE
		FROM ARS_SUKNFX_D_MF
		WHERE SUKFX_EXT_DATE = (select MAX(SUKFX_EXT_DATE) FROM ARS_SUKNFX_D_MF WHERE SUKFX_EXT_DATE < @EXT_DATE) AND
				SUKFX_TX_TYPE IN('02', '03', '04', '05') AND
				SUKFX_CPTY_COUNTRY_RISK <> 'TW';
	END TRY
	BEGIN CATCH
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT '發生錯誤: ' + @ErrorMsg;
		THROW;
	END CATCH

END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		AllenChen
-- Create date: 2025/10/17
-- Description:	09SUKNIRS 衍生性商品(IRS及CCS)之資料擷取 交易最大日期

-- =============================================
CREATE PROCEDURE [dbo].[usp_Souce09_By_ARS_SUKNIRS_D_MF] @EXT_DATE DATE
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		INSERT INTO MonitorData (
			BRANCH_NO, UNIT_NO, PRODUCT_TYPE, TRAN_NO, GROUP_NO, TX_DATE,
			CUSTOMER_NAME, CUSTOMER_ID, COUNTRY_COD, CURENCY_COD, TRAN_AMOUNT,
			LIMIT, LIMIT_COD, MATURITY_DATE, AS_OF_DATE, FIL9,
			SOURCE, CREATOR, LIMIT_MATURITY, INDUSTRY,INDUSTRY_Type,PRODUCT_CODE,EXT_DATE)
		SELECT
			TRIM(SUKIRS_BRANCH_NO) AS BRANCH_NO,
			CASE WHEN SUKIRS_BRANCH_NO IN('098','095','082') AND UPPER(TRIM(SUKIRS_SUPERVISOR)) = 'STRUCTS_PD'
				THEN '089'
				ELSE '069'
			END AS DIVISION_NO,
			'07' AS PRODUCT_TYPE,
			TRIM(SUKIRS_TRAN_NO) AS TRAN_NO,
			'016' AS BUSINESS_UNIT,
			SUKIRS_TX_DATE AS TX_DATE,
			TRIM(SUKIRS_CUST_NAME1) AS CUSTOMER_NAME,
			TRIM(SUKIRS_CUSTOMER_ID) AS CUSTOMER_ID,
			TRIM(SUKIRS_CPTY_COUNTRY_RISK) AS COUNTRY_COD,
			TRIM(SUKIRS_IN_CCY) AS CURENCY_COD,
			SUKIRS_IN_AMT As TRAN_AMOUNT,
			SUKIRS_IN_AMT AS LIMIT,
			TRIM(SUKIRS_IN_CCY) AS LIMIT_COD,
			SUKIRS_MATURITY AS MATURITY_DATE,
			SUKIRS_EXT_DATE AS AS_OF_DATE,
			'ARS_SUKNIRS_D_MF' as FIL9,
			'09' as source,
			'system' as creator,
			SUKIRS_MATURITY as LIMIT_MATURITY,
			TRIM(SUKIRS_CPTY_BUSINESS) AS INDUSTRY,
			1,
			CASE TRIM(SUKIRS_TX_TYPE) WHEN '01' THEN 'QS'
			ELSE 'IRS'
			END AS PRODUCT_CODE,
			@EXT_DATE AS EXT_DATE
		FROM ARS_SUKNIRS_D_MF
		WHERE
			SUKIRS_EXT_DATE = (SELECT MAX(SUKIRS_EXT_DATE) FROM ARS_SUKNIRS_D_MF WHERE SUKIRS_EXT_DATE < @EXT_DATE) AND
			ISNULL(SUKIRS_DEPOSIT_LINK,'') NOT IN ('SPD','DCD') AND
			SUKIRS_CPTY_COUNTRY_RISK <> 'TW';
	END TRY
	BEGIN CATCH
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT '發生錯誤: ' + @ErrorMsg;
		THROW;
	END CATCH

END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		AllenChen
-- Create date: 2025/10/17
-- Description:	09SUKNMM 拆款業務之資料擷取 交易最大日期

-- =============================================
CREATE PROCEDURE [dbo].[usp_Souce09_By_ARS_SUKNMM_D_MF] @EXT_DATE DATE
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		INSERT INTO MonitorData (
			BRANCH_NO, UNIT_NO, PRODUCT_TYPE, TRAN_NO, GROUP_NO, TX_DATE,
			CUSTOMER_NAME, CUSTOMER_ID, COUNTRY_COD, CURENCY_COD, TRAN_AMOUNT,
			PERMIT_NO, LIMIT, LIMIT_COD, MATURITY_DATE, AS_OF_DATE, REVOLVE_MK, FIL9,
			SOURCE, CREATOR, LIMIT_MATURITY, INDUSTRY,INDUSTRY_Type,EXT_DATE)
		SELECT
			TRIM(SUKMM_BRANCH_NO) AS BRANCH_NO,
			CASE WHEN SUKMM_BRANCH_NO IN('098','095','082') AND UPPER(TRIM(SUKMM_SUPERVISOR)) = 'STRUCTS_PD'
				THEN '089'
				ELSE '069'
			END AS DIVISION_NO,
			CASE TRIM(SUKMM_TRN_TYPE) WHEN '1' THEN '09'   -- 「09拆款」
									  WHEN '3' THEN '04'   -- 「04存同」
				 END AS PRODUCT_TYPE,
			TRIM(SUKMM_TRAN_NO) AS TRAN_NO,
			'016' AS BUSINESS_UNIT,
			SUKMM_TX_DATE AS TX_DATE,
			TRIM(SUKMM_CUST_NAME1) AS CUSTOMER_NAME,
			TRIM(SUKMM_SWIFT_ID) AS CUSTOMER_ID,
			TRIM(SUKMM_COUNTRY_RISK) AS COUNTRY_COD,
			TRIM(SUKMM_CURENCY_COD) AS CURENCY_COD,
			ABS(SUKMM_TRAN_AMOUNT) AS TRAN_AMOUNT,
			NULL AS PERMIT_NO,
			ABS(SUKMM_TRAN_AMOUNT) AS [LIMIT],
			TRIM(SUKMM_CURENCY_COD) AS LIMIT_COD,
			SUKMM_MATURITY_DATE AS MATURITY_DATE,
			SUKMM_EXT_DATE AS AS_OF_DATE,
			1 AS REVOLVE_MK,
			'ARS_SUKNMM_D_MF' AS FIL9,
			'09' AS source,
			'system' AS creator,
			SUKMM_MATURITY_DATE AS LIMIT_MATURITY,
			TRIM(SUKMM_CPTY_TYPE) AS INDUSTRY,
			1,
			@EXT_DATE AS EXT_DATE
		FROM ARS_SUKNMM_D_MF
		WHERE
			SUKMM_EXT_DATE = (select max(SUKMM_EXT_DATE) from ARS_SUKNMM_D_MF WHERE SUKMM_EXT_DATE < @EXT_DATE) AND
			(SUKMM_MATURITY_DATE IS NULL OR SUKMM_MATURITY_DATE > SUKMM_EXT_DATE) AND -- 並去除當日到期之資料
			TRIM(SUKMM_TRN_TYPE) IN ('1','3') AND -- 只抓取正的
			SUKMM_COUNTRY_RISK <> 'TW' AND
			(
				-- 條件1：非 group_id = '99999' 的客戶
				(TRIM(SUKMM_CUST_NAME1) NOT IN (SELECT customer_name FROM groupdata WHERE group_id = '99999'))
				OR
				-- 條件2：group_id = '99999' 的客戶，但排除 TWD 幣別
				(TRIM(SUKMM_CUST_NAME1) IN (SELECT customer_name FROM groupdata WHERE group_id = '99999')
				 AND SUKMM_CURENCY_COD <> 'TWD')
			) AND
			EXISTS (
				SELECT 1
				FROM ARS_SUKNMM_D_MF MF2
				WHERE	MF2.SUKMM_TRN_TYPE = ARS_SUKNMM_D_MF.SUKMM_TRN_TYPE AND -- 只抓取正的
						MF2.SUKMM_COUNTRY_RISK = ARS_SUKNMM_D_MF.SUKMM_COUNTRY_RISK AND
						MF2.SUKMM_EXT_DATE = ARS_SUKNMM_D_MF.SUKMM_EXT_DATE AND
						MF2.SUKMM_MATURITY_DATE = ARS_SUKNMM_D_MF.SUKMM_MATURITY_DATE AND
						LEFT(MF2.SUKMM_SWIFT_ID, 4) = LEFT(SUKMM_SWIFT_ID, 4)
				GROUP BY LEFT(MF2.SUKMM_SWIFT_ID, 4)
				HAVING SUM(ABS(MF2.SUKMM_TRAN_AMOUNT)) > 0)
	END TRY
	BEGIN CATCH
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT '發生錯誤: ' + @ErrorMsg;
		THROW;
	END CATCH

END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		AllenChen
-- Create date: 2025/10/17
-- Description:	09SUKSWP 之資料擷取 交易最大日期

-- =============================================
CREATE PROCEDURE [dbo].[usp_Souce09_By_ARS_SUKSWP_D_MF] @EXT_DATE DATE
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		INSERT INTO MonitorData (
			BRANCH_NO, UNIT_NO, PRODUCT_TYPE, TRAN_NO, GROUP_NO, TX_DATE,
			CUSTOMER_NAME, CUSTOMER_ID, COUNTRY_COD, CURENCY_COD, TRAN_AMOUNT,
			LIMIT, LIMIT_COD, MATURITY_DATE, AS_OF_DATE, FIL9,
			SOURCE, CREATOR, LIMIT_MATURITY, INDUSTRY,INDUSTRY_Type,PRODUCT_CODE,EXT_DATE)
		SELECT
			TRIM(SUKSWP_BRANCH_NO) AS BRANCH_NO,
			CASE WHEN SUKSWP_BRANCH_NO IN('098','095','082') AND UPPER(TRIM(SUKSWP_SUPERVISOR)) = 'STRUCTS_PD'
				THEN '089'
				ELSE '069'
			END AS DIVISION_NO,
			'07' AS PRODUCT_TYPE,
			TRIM(SUKSWP_EXTERNAL_ID) AS TRAN_NO,
			'016' AS BUSINESS_UNIT,
			SUKSWP_TX_DATE AS TX_DATE,
			TRIM(SUKSWP_CUST_NAME) AS CUSTOMER_NAME,
			TRIM(SUKSWP_CUSTOMER_ID) AS CUSTOMER_ID,
			TRIM(SUKSWP_CPTY_COUNTRY_RISK) AS COUNTRY_COD,
			TRIM(SUKSWP_CURRENCY) AS CURENCY_COD,
			0 As TRAN_AMOUNT,
			--SUKSWP_RISK_AMT AS TO_USD_AMT,
			--0 AS TO_USD_FXRATE,
			0 AS LIMIT,
			TRIM(SUKSWP_CURRENCY) AS LIMIT_COD,
			--SUKSWP_RISK_AMT AS TO_USD_LIMIT,
			SUKSWP_OPTIONEXPIRYDATE AS MATURITY_DATE,
			SUKSWP_EXT_DATE AS AS_OF_DATE,
			'ARS_SUKSWP_D_MF' as FIL9,
			'09' as source,
			'system' as creator,
			SUKSWP_OPTIONEXPIRYDATE as LIMIT_MATURITY,
			TRIM(SUKSWP_CPTY_BUSINESS) AS INDUSTRY,
			1,
			'IRO' AS PRODUCT_CODE,
			@EXT_DATE AS EXT_DATE
		FROM ARS_SUKSWP_D_MF
		WHERE SUKSWP_EXT_DATE = (select max(SUKSWP_EXT_DATE) from ARS_SUKSWP_D_MF WHERE SUKSWP_EXT_DATE < @EXT_DATE) AND
			SUKSWP_BUY_SELL ='B' AND
			SUKSWP_CPTY_COUNTRY_RISK <> 'TW';
	END TRY
	BEGIN CATCH
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT '發生錯誤: ' + @ErrorMsg;
		THROW;
	END CATCH

END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		AllenChen
-- Create date: 2025/10/17
-- Description:	轉檔流程呼叫入口

-- =============================================
CREATE PROCEDURE [dbo].[usp_TransferData] @EXT_DATE AS DATE
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		IF @EXT_DATE IS NULL
			THROW 50000, '@EXT_DATE 為空值', 1;
		Delete MONITORDATA
		Where DATADATE = @EXT_DATE
		-- DW 資料轉檔
		exec usp_Souce01_OBBS_By_OS_LNSMSTD_D_MF_OS_LNSLMSD_D_MF @EXT_DATE
		exec usp_Souce01_OBBS_By_OSBDKF02_MF @EXT_DATE
		exec usp_Souce01_OBBS_By_OSFXKF02_MF @EXT_DATE
		exec usp_Souce01_OBBS_By_OSISKF02_MF @EXT_DATE
		exec usp_Souce01_OBBS_By_OSMMKF02_MF @EXT_DATE
		exec usp_Souce04_By_LS_LSRSA_D_MF_ACNOD_STG @EXT_DATE
		exec usp_Souce06_By_FL_FLMST_D_MF @EXT_DATE  -- 慢
		exec usp_Souce09_By_ARS_SUKBDO_D_MF @EXT_DATE
		exec usp_Souce09_By_ARS_SUKFRA_D_MF @EXT_DATE
		exec usp_Souce09_By_ARS_SUKIRO_D_MF @EXT_DATE
		exec usp_Souce09_By_ARS_SUKMST_D_MF @EXT_DATE
		exec usp_Souce09_By_ARS_SUKNBD1_D_MF @EXT_DATE -- 慢
		exec usp_Souce09_By_ARS_SUKNFO_D_MF @EXT_DATE
		exec usp_Souce09_By_ARS_SUKNFX_D_MF @EXT_DATE
		exec usp_Souce09_By_ARS_SUKNIRS_D_MF @EXT_DATE
		exec usp_Souce09_By_ARS_SUKNMM_D_MF @EXT_DATE
		exec usp_Souce09_By_ARS_SUKSWP_D_MF @EXT_DATE

	END TRY
	BEGIN CATCH
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT '發生錯誤: ' + @ErrorMsg;
		THROW;
	END CATCH

END
GO
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
CREATE   PROCEDURE [dbo].[usp_UpdateMonitorDataCalculatedUsdAmount](@EXT_DATE AS DATE)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		UPDATE M
		SET
			-- TODO: 套用 WEIGHTS/RISKFACTOR 的計算公式，例如：
			CAL_TO_USD_AMT = M.TO_USD_AMT * M.WEIGHTS * M.RISKFACTOR,
			-- TODO: 套用 WEIGHTS/RISKFACTOR 的計算公式
			CAL_TO_USD_LIMIT = M.TO_USD_LIMIT * M.WEIGHTS * M.RISKFACTOR
		FROM MONITORDATA M
		WHERE M.EXT_DATE = @EXT_DATE;
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
		PRINT '發生錯誤: ' + @ErrorMsg;
		THROW;
	END CATCH
END
GO
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
		-- 2. 到期日天數 小於 92 為 20
		-- 3. 其餘 100
		UPDATE M SET WEIGHTS = CASE WHEN EXISTS (
											SELECT 1
											FROM @ExcludedCustomers e
											WHERE e.CustomerName = M.CUSTOMER_NAME
										) THEN '0'
									WHEN DATEDIFF(DAY,@EXT_DATE,M.MATURITY_DATE) < 92 THEN 20
									ELSE 100 END
		FROM MONITORDATA M
		WHERE M.EXT_DATE = @EXT_DATE AND COUNTRY_COD = 'CN'
	END TRY
    BEGIN CATCH
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT '發生錯誤: ' + @ErrorMsg;
        THROW;
    END CATCH
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Allen
-- Create date: 20250916
-- Description:	將指定轉入日期的MonitorData Update 交易金額(美金)核准金額(美金)與交易匯率更新
-- Modify:		新增 TRAN_FXRATE／LIMIT_FXRATE 落地保存實際套用的匯率，供追溯與後續計算使用
-- =============================================
CREATE PROCEDURE [dbo].[usp_UpdateMonitorDataFPEXR_RateUSD](@EXT_DATE AS DATE)
AS
BEGIN
	SET NOCOUNT ON;
    BEGIN TRY
		-- 交易金額(美金)與交易匯率更新
		--非柬埔寨幣使用FPEXR_STG(FPEXR_STG是台幣匯率檔，要再除一次美金)
		-- 柬埔寨幣用ACOLRT_STG 匯率檔
		UPDATE M
		SET
			TRAN_FXRATE = CASE
				WHEN M.CURENCY_COD = 'KHR' THEN ACO_TRAN.ACOLRT_RATE
				WHEN M.CURENCY_COD = 'TWD' THEN 1 / FPE2_TRAN.FPEXR_RATE
				ELSE FPE_TRAN.FPEXR_RATE / FPE2_TRAN.FPEXR_RATE
			END,
			TO_USD_AMT = CASE
				WHEN M.CURENCY_COD = 'KHR' THEN M.TRAN_AMOUNT * ACO_TRAN.ACOLRT_RATE
				WHEN M.CURENCY_COD = 'TWD' THEN M.TRAN_AMOUNT / FPE2_TRAN.FPEXR_RATE
				ELSE M.TRAN_AMOUNT * FPE_TRAN.FPEXR_RATE / FPE2_TRAN.FPEXR_RATE
			END,
			LIMIT_FXRATE = CASE
				WHEN M.LIMIT_COD = 'KHR' THEN ACO_LIMIT.ACOLRT_RATE
				WHEN M.LIMIT_COD = 'TWD' THEN 1 / FPE2_TRAN.FPEXR_RATE
				WHEN M.LIMIT_COD IS NULL THEN  -- 如果沒有額度幣別，使用交易幣別
					CASE
						WHEN M.CURENCY_COD = 'KHR' THEN ACO_TRAN.ACOLRT_RATE
						ELSE FPE_TRAN.FPEXR_RATE / FPE2_TRAN.FPEXR_RATE
					END
				ELSE FPE_LIMIT.FPEXR_RATE / FPE2_LIMIT.FPEXR_RATE
			END,
			TO_USD_LIMIT = CASE
				WHEN M.LIMIT_COD = 'KHR' THEN M.LIMIT * ACO_LIMIT.ACOLRT_RATE
				WHEN M.LIMIT_COD = 'TWD' THEN M.LIMIT / FPE2_TRAN.FPEXR_RATE
				WHEN M.LIMIT_COD IS NULL THEN  -- 如果沒有額度幣別，使用交易幣別
					CASE
						WHEN M.CURENCY_COD = 'KHR' THEN M.LIMIT * ACO_TRAN.ACOLRT_RATE
						ELSE M.LIMIT * FPE_TRAN.FPEXR_RATE / FPE2_TRAN.FPEXR_RATE
					END
				ELSE M.LIMIT * FPE_LIMIT.FPEXR_RATE / FPE2_LIMIT.FPEXR_RATE
			END
		FROM MONITORDATA M
		-- 交易幣別代號 JOIN
		INNER JOIN MIS_CRCY_REF CRCY_TRAN ON CRCY_TRAN.CRCY_ENG_NAME = M.CURENCY_COD
		-- 匯率檔JOIN
		LEFT JOIN FPEXR_STG FPE_TRAN ON CRCY_TRAN.CRCY_CODE = FPE_TRAN.FPEXR_CRCY_CODE
			AND FPE_TRAN.FPEXR_DATE = M.AS_OF_DATE
			AND M.CURENCY_COD <> 'KHR'
		-- 匯率檔美金
		LEFT JOIN FPEXR_STG FPE2_TRAN ON FPE2_TRAN.FPEXR_CRCY_CODE = '01'
			AND FPE2_TRAN.FPEXR_DATE =  M.AS_OF_DATE
			AND M.CURENCY_COD <> 'KHR'
		-- 匯率檔2 美金
		LEFT JOIN ACOLRT_STG ACO_TRAN ON CRCY_TRAN.CRCY_CODE = ACO_TRAN.ACOLRT_CURENCY
			AND ACO_TRAN.ACOLRT_DATE = M.AS_OF_DATE
			AND ACO_TRAN.ACOLRT_LOCAL_CURENCY = '01'
			AND M.CURENCY_COD = 'KHR'
		-- 核准額度幣別相關JOIN（僅當額度幣別存在且不同於交易幣別時）
		LEFT JOIN MIS_CRCY_REF CRCY_LIMIT ON CRCY_LIMIT.CRCY_ENG_NAME = M.LIMIT_COD
			AND M.LIMIT_COD IS NOT NULL
		LEFT JOIN FPEXR_STG FPE_LIMIT ON CRCY_LIMIT.CRCY_CODE = FPE_LIMIT.FPEXR_CRCY_CODE
			AND FPE_LIMIT.FPEXR_DATE = M.AS_OF_DATE
			AND M.LIMIT_COD <> 'KHR'
		LEFT JOIN FPEXR_STG FPE2_LIMIT ON FPE2_LIMIT.FPEXR_CRCY_CODE = '01'
			AND FPE2_LIMIT.FPEXR_DATE =  M.AS_OF_DATE
			AND M.LIMIT_COD <> 'KHR'
		LEFT JOIN ACOLRT_STG ACO_LIMIT ON CRCY_LIMIT.CRCY_CODE = ACO_LIMIT.ACOLRT_CURENCY
			AND ACO_LIMIT.ACOLRT_DATE = M.AS_OF_DATE
			AND ACO_LIMIT.ACOLRT_LOCAL_CURENCY = '01'
			AND M.LIMIT_COD = 'KHR'
		WHERE M.EXT_DATE = @EXT_DATE;
	END TRY
    BEGIN CATCH
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT '發生錯誤: ' + @ErrorMsg;
        THROW;
    END CATCH
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		allen
-- Create date: 20260424
-- Description:	更新指定轉檔日期MonitorData資料
-- =============================================
CREATE PROCEDURE [dbo].[usp_UpdateMonitorDataLimit] @EXT_DATE as date
AS
BEGIN
	SET NOCOUNT ON;
    BEGIN TRY
		update m set LIMIT = TRAN_AMOUNT, TO_USD_LIMIT = TO_USD_AMT
		from MONITORDATA m
		where m.EXT_DATE = @EXT_DATE AND LIMIT_MATURITY <= @EXT_DATE
	END TRY
    BEGIN CATCH
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT '發生錯誤: ' + @ErrorMsg;
        THROW;
    END CATCH
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_BmiRatingCount]
    @Date DATE,
    @CountryRatings [dbo].[CountryRatingResultType] READONLY
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @Year AS INT, @Month AS INT, @Week AS INT;
        SELECT @Year = YEAR(@Date), @Month = MONTH(@Date), @Week = dbo.ufn_GetWeekOfMonth(@Date)

        DELETE CreditRating_CountBmi_his
        WHERE [YEAR] = @Year AND [Month] = @Month AND [Week] = @Week

        DELETE CreditRating_CountBmi
        OUTPUT
            @Year, @Month, @Week,
            deleted.FK_Country_Id, deleted.CountryName, deleted.CountryRating, deleted.TitleCountryRating,
            deleted.NominalGDP_Score, deleted.NominalGDP, deleted.RealGDPGrowthIMFAE_Score, deleted.RealGDPGrowthIMFAE,
            deleted.RealGDPGrowth_Score, deleted.RealGDPGrowth, deleted.ConsumerPriceIMFAE_Score, deleted.ConsumerPriceIMFAE,
            deleted.ConsumerPrice_Score, deleted.ConsumerPrice, deleted.Unemployment_Score, deleted.Unemployment,
            deleted.ImportCoverMonths_Score, deleted.ImportCoverMonths, deleted.TotalExternalDebtStock_Score, deleted.TotalExternalDebtStock,
            deleted.ShortTermExternalDebt_Score, deleted.ShortTermExternalDebt, deleted.BudgetBalance_Score, deleted.BudgetBalance,
            deleted.TotalGovernmentDebt_Score, deleted.TotalGovernmentDebt, deleted.PoliticalRisk_Score, deleted.PoliticalRisk,
            deleted.SecurityRisk_Score, deleted.SecurityRisk, deleted.BusinessStrategy_Explain, deleted.BusinessStrategy,
            deleted.CreditRating_Explain, deleted.CreditRating, deleted.Outlook_Explain, deleted.Outlook,
            deleted.Other_Explain, deleted.Other, deleted.End_Explain, deleted.AssessmentDay
        INTO CreditRating_CountBmi_his(
            [Year], [Month], [Week],
            [FK_Country_Id], [CountryName], [CountryRating], [TitleCountryRating],
            [NominalGDP_Score], [NominalGDP], [RealGDPGrowthIMFAE_Score], [RealGDPGrowthIMFAE],
            [RealGDPGrowth_Score], [RealGDPGrowth], [ConsumerPriceIMFAE_Score], [ConsumerPriceIMFAE],
            [ConsumerPrice_Score], [ConsumerPrice], [Unemployment_Score], [Unemployment],
            [ImportCoverMonths_Score], [ImportCoverMonths], [TotalExternalDebtStock_Score], [TotalExternalDebtStock],
            [ShortTermExternalDebt_Score], [ShortTermExternalDebt], [BudgetBalance_Score], [BudgetBalance],
            [TotalGovernmentDebt_Score], [TotalGovernmentDebt], [PoliticalRisk_Score], [PoliticalRisk],
            [SecurityRisk_Score], [SecurityRisk], [BusinessStrategy_Explain], [BusinessStrategy],
            [CreditRating_Explain], [CreditRating], [Outlook_Explain], [Outlook],
            [Other_Explain], [Other], [End_Explain], [AssessmentDay]
        );

		-- 把國家風險等級拉出去
        WITH RatingText AS (
			SELECT
				rt.FK_Country_Id,
				rt.FinalRating,
				rt.Score,
				'第' +
					CASE rt.FinalRating
						WHEN 1 THEN '一'
						WHEN 2 THEN '二'
						WHEN 3 THEN '三'
						WHEN 4 THEN '四'
						WHEN 5 THEN '五'
					END + '等' AS RatingText,
				'國家風險等級：第' +
					CASE rt.FinalRating
						WHEN 1 THEN '一'
						WHEN 2 THEN '二'
						WHEN 3 THEN '三'
						WHEN 4 THEN '四'
						WHEN 5 THEN '五'
					END + '等' AS TitleRatingText,
				CASE rt.FinalRating
					WHEN 1 THEN 9
					WHEN 2 THEN 7
					WHEN 3 THEN 5
					WHEN 4 THEN 3
					WHEN 5 THEN 1
				END AS RatingScore,
				CASE rt.Score
					WHEN 1 THEN '正面'
					WHEN 0 THEN '持平'
					WHEN -1 THEN '負面'
					ELSE NULL
				END AS OutlookText
			FROM @CountryRatings rt
		),
        -- Default 分數從規則表讀取，ScoreLevel = 'Default' 的那筆
        DefaultScores AS (
            SELECT RuleName, Score
            FROM CreditRating_BmiRule
            WHERE ScoreLevel = 'Default' AND IsActive = 1
        ),
        BMIData AS (
            SELECT
                ci.PK_Id AS FK_Country_Id,
                ci.CountryName_TN,
                ci.ISIMFAE,

                -- 原始值
                ROUND(a.BMI_GDP_NOM_USD_AVE / 1000000000, 1) AS NominalGDP,
                ROUND(a.BMI_GDP_REAL_PCTCH, 1) AS RealGDPGrowth_Raw,
                ROUND(a.BMI_INFLATION_CPI_AVE_UNIT, 1) AS ConsumerPrice_Raw,
                a.BMI_LABOUR_UNEMP_PCT_AVE_UNIT AS Unemployment,
                a.BMI_RESERVES_IMPCOVER AS ImportCoverMonths,
                ROUND(a.BMI_DEBT_EXT_PCGDP, 1) AS TotalExternalDebtStock,
                ROUND(a.BMI_DEBT_EXT_ST_PCTEXTDEBT, 1) AS ShortTermExternalDebt,
                ROUND(a.BMI_FISCAL_BALANCE_PCTGDP, 1) AS BudgetBalance,
                ROUND(a.BMI_DEBT_GOVT_PCGDP, 1) AS TotalGovernmentDebt,
                ROUND(a.BMI_INDEX_POLRISK_UNIT_50046_E, 1) AS PoliticalRisk,
                ROUND(a.BMI_INDEX_POLRISK_SECURITY_UNIT_10012_E, 1) AS SecurityRisk,

                -- 動態評分，找不到規則時用 DefaultScores 的值
                ISNULL(gdp_rule.Score, gdp_default.Score)                           AS NominalGDP_Score,

                CASE WHEN ci.ISIMFAE = 1 THEN ISNULL(CAST(gdp_growth_dev.Score AS FLOAT),    CAST(gdp_growth_dev_default.Score    AS FLOAT)) ELSE NULL END AS RealGDPGrowthIMFAE_Score,
                CASE WHEN ci.ISIMFAE = 1 THEN ROUND(a.BMI_GDP_REAL_PCTCH, 1) ELSE NULL END AS RealGDPGrowthIMFAE,
                CASE WHEN ci.ISIMFAE = 0 THEN ISNULL(CAST(gdp_growth_emerging.Score AS FLOAT), CAST(gdp_growth_emg_default.Score AS FLOAT)) ELSE NULL END AS RealGDPGrowth_Score,
                CASE WHEN ci.ISIMFAE = 0 THEN ROUND(a.BMI_GDP_REAL_PCTCH, 1) ELSE NULL END AS RealGDPGrowth,

                CASE WHEN ci.ISIMFAE = 1 THEN ISNULL(CAST(cpi_dev.Score AS FLOAT),           CAST(cpi_dev_default.Score           AS FLOAT)) ELSE NULL END AS ConsumerPriceIMFAE_Score,
                CASE WHEN ci.ISIMFAE = 1 THEN ROUND(a.BMI_INFLATION_CPI_AVE_UNIT, 1) ELSE NULL END AS ConsumerPriceIMFAE,
                CASE WHEN ci.ISIMFAE = 0 THEN ISNULL(CAST(cpi_emerging.Score AS FLOAT),       CAST(cpi_emg_default.Score           AS FLOAT)) ELSE NULL END AS ConsumerPrice_Score,
                CASE WHEN ci.ISIMFAE = 0 THEN ROUND(a.BMI_INFLATION_CPI_AVE_UNIT, 1) ELSE NULL END AS ConsumerPrice,

                ISNULL(CAST(unemp_rule.Score    AS FLOAT), CAST(unemp_default.Score    AS FLOAT)) AS Unemployment_Score,
                ISNULL(CAST(import_rule.Score   AS FLOAT), CAST(import_default.Score   AS FLOAT)) AS ImportCoverMonths_Score,
                ISNULL(CAST(ext_debt_rule.Score AS FLOAT), CAST(ext_debt_default.Score AS FLOAT)) AS TotalExternalDebtStock_Score,
                ISNULL(CAST(st_debt_rule.Score  AS FLOAT), CAST(st_debt_default.Score  AS FLOAT)) AS ShortTermExternalDebt_Score,
                ISNULL(CAST(budget_rule.Score   AS FLOAT), CAST(budget_default.Score   AS FLOAT)) AS BudgetBalance_Score,
                ISNULL(CAST(govt_debt_rule.Score AS FLOAT), CAST(govt_debt_default.Score AS FLOAT)) AS TotalGovernmentDebt_Score,
                ISNULL(pol_risk_rule.Score, pol_risk_default.Score)                 AS PoliticalRisk_Score,
                ISNULL(sec_risk_rule.Score, sec_risk_default.Score)                 AS SecurityRisk_Score,

                ROW_NUMBER() OVER (PARTITION BY ci.PK_Id ORDER BY ISNULL(a.PK_Id, 0) DESC) AS rn

            FROM CountryMaster ci
            LEFT JOIN CreditRating_Bmi a
                ON a.FK_Country_Id = ci.PK_Id
                AND a.Year = YEAR(@Date)

            -- NominalGDP
            LEFT JOIN CreditRating_BmiRule gdp_rule
                ON gdp_rule.RuleName = 'NominalGDP'
                AND gdp_rule.IsActive = 1
                AND gdp_rule.ScoreLevel <> 'Default'
                AND ROUND(a.BMI_GDP_NOM_USD_AVE / 1000000000, 1) >= ISNULL(gdp_rule.MinValue, -999999999)
                AND ROUND(a.BMI_GDP_NOM_USD_AVE / 1000000000, 1) <= ISNULL(gdp_rule.MaxValue, 999999999)
            LEFT JOIN DefaultScores gdp_default ON gdp_default.RuleName = 'NominalGDP'

            -- RealGDPGrowth (已開發)
            LEFT JOIN CreditRating_BmiRule gdp_growth_dev
                ON gdp_growth_dev.RuleName = 'RealGDPGrowthDeveloped'
                AND gdp_growth_dev.IsActive = 1
                AND gdp_growth_dev.ScoreLevel <> 'Default'
                AND ci.ISIMFAE = 1
                AND ROUND(a.BMI_GDP_REAL_PCTCH, 1) >= ISNULL(gdp_growth_dev.MinValue, -999999999)
                AND ROUND(a.BMI_GDP_REAL_PCTCH, 1) <= ISNULL(gdp_growth_dev.MaxValue, 999999999)
            LEFT JOIN DefaultScores gdp_growth_dev_default ON gdp_growth_dev_default.RuleName = 'RealGDPGrowthDeveloped'

            -- RealGDPGrowth (開發中)
            LEFT JOIN CreditRating_BmiRule gdp_growth_emerging
                ON gdp_growth_emerging.RuleName = 'RealGDPGrowthDeveloping'
                AND gdp_growth_emerging.IsActive = 1
                AND gdp_growth_emerging.ScoreLevel <> 'Default'
                AND ci.ISIMFAE = 0
                AND ROUND(a.BMI_GDP_REAL_PCTCH, 1) >= ISNULL(gdp_growth_emerging.MinValue, -999999999)
                AND ROUND(a.BMI_GDP_REAL_PCTCH, 1) <= ISNULL(gdp_growth_emerging.MaxValue, 999999999)
            LEFT JOIN DefaultScores gdp_growth_emg_default ON gdp_growth_emg_default.RuleName = 'RealGDPGrowthDeveloping'

            -- ConsumerPrice (已開發)
            LEFT JOIN CreditRating_BmiRule cpi_dev
                ON cpi_dev.RuleName = 'ConsumerPriceDeveloped'
                AND cpi_dev.IsActive = 1
                AND cpi_dev.ScoreLevel <> 'Default'
                AND ci.ISIMFAE = 1
                AND (
                    (cpi_dev.ScoreLevel = 'Deflation' AND ROUND(a.BMI_INFLATION_CPI_AVE_UNIT, 1) <= 0)
                    OR (cpi_dev.ScoreLevel <> 'Deflation'
                        AND ROUND(a.BMI_INFLATION_CPI_AVE_UNIT, 1) > 0
                        AND ROUND(a.BMI_INFLATION_CPI_AVE_UNIT, 1) >= ISNULL(cpi_dev.MinValue, -999999999)
                        AND ROUND(a.BMI_INFLATION_CPI_AVE_UNIT, 1) <= ISNULL(cpi_dev.MaxValue, 999999999))
                )
            LEFT JOIN DefaultScores cpi_dev_default ON cpi_dev_default.RuleName = 'ConsumerPriceDeveloped'

            -- ConsumerPrice (開發中)
            LEFT JOIN CreditRating_BmiRule cpi_emerging
                ON cpi_emerging.RuleName = 'ConsumerPriceDeveloping'
                AND cpi_emerging.IsActive = 1
                AND cpi_emerging.ScoreLevel <> 'Default'
                AND ci.ISIMFAE = 0
                AND (
                    (cpi_emerging.ScoreLevel = 'Deflation' AND ROUND(a.BMI_INFLATION_CPI_AVE_UNIT, 1) <= 0)
                    OR (cpi_emerging.ScoreLevel <> 'Deflation'
                        AND ROUND(a.BMI_INFLATION_CPI_AVE_UNIT, 1) > 0
                        AND ROUND(a.BMI_INFLATION_CPI_AVE_UNIT, 1) >= ISNULL(cpi_emerging.MinValue, -999999999)
                        AND ROUND(a.BMI_INFLATION_CPI_AVE_UNIT, 1) <= ISNULL(cpi_emerging.MaxValue, 999999999))
                )
            LEFT JOIN DefaultScores cpi_emg_default ON cpi_emg_default.RuleName = 'ConsumerPriceDeveloping'

            -- Unemployment
            LEFT JOIN CreditRating_BmiRule unemp_rule
                ON unemp_rule.RuleName = 'Unemployment'
                AND unemp_rule.IsActive = 1
                AND unemp_rule.ScoreLevel <> 'Default'
                AND a.BMI_LABOUR_UNEMP_PCT_AVE_UNIT >= ISNULL(unemp_rule.MinValue, -999999999)
                AND a.BMI_LABOUR_UNEMP_PCT_AVE_UNIT <= ISNULL(unemp_rule.MaxValue, 999999999)
            LEFT JOIN DefaultScores unemp_default ON unemp_default.RuleName = 'Unemployment'

            -- ImportCoverMonths
            LEFT JOIN CreditRating_BmiRule import_rule
                ON import_rule.RuleName = 'ImportCoverMonths'
                AND import_rule.IsActive = 1
                AND import_rule.ScoreLevel <> 'Default'
                AND a.BMI_RESERVES_IMPCOVER >= ISNULL(import_rule.MinValue, -999999999)
                AND a.BMI_RESERVES_IMPCOVER <= ISNULL(import_rule.MaxValue, 999999999)
            LEFT JOIN DefaultScores import_default ON import_default.RuleName = 'ImportCoverMonths'

            -- TotalExternalDebtStock
            LEFT JOIN CreditRating_BmiRule ext_debt_rule
                ON ext_debt_rule.RuleName = 'TotalExternalDebtStock'
                AND ext_debt_rule.IsActive = 1
                AND ext_debt_rule.ScoreLevel <> 'Default'
                AND ROUND(a.BMI_DEBT_EXT_PCGDP, 1) >= ISNULL(ext_debt_rule.MinValue, -999999999)
                AND ROUND(a.BMI_DEBT_EXT_PCGDP, 1) <= ISNULL(ext_debt_rule.MaxValue, 999999999)
            LEFT JOIN DefaultScores ext_debt_default ON ext_debt_default.RuleName = 'TotalExternalDebtStock'

            -- ShortTermExternalDebt
            LEFT JOIN CreditRating_BmiRule st_debt_rule
                ON st_debt_rule.RuleName = 'ShortTermExternalDebt'
                AND st_debt_rule.IsActive = 1
                AND st_debt_rule.ScoreLevel <> 'Default'
                AND ROUND(a.BMI_DEBT_EXT_ST_PCTEXTDEBT, 1) >= ISNULL(st_debt_rule.MinValue, -999999999)
                AND ROUND(a.BMI_DEBT_EXT_ST_PCTEXTDEBT, 1) <= ISNULL(st_debt_rule.MaxValue, 999999999)
            LEFT JOIN DefaultScores st_debt_default ON st_debt_default.RuleName = 'ShortTermExternalDebt'

            -- BudgetBalance
            LEFT JOIN CreditRating_BmiRule budget_rule
                ON budget_rule.RuleName = 'BudgetBalance'
                AND budget_rule.IsActive = 1
                AND budget_rule.ScoreLevel <> 'Default'
                AND ROUND(a.BMI_FISCAL_BALANCE_PCTGDP, 1) >= ISNULL(budget_rule.MinValue, -999999999)
                AND ROUND(a.BMI_FISCAL_BALANCE_PCTGDP, 1) <= ISNULL(budget_rule.MaxValue, 999999999)
            LEFT JOIN DefaultScores budget_default ON budget_default.RuleName = 'BudgetBalance'

            -- TotalGovernmentDebt
            LEFT JOIN CreditRating_BmiRule govt_debt_rule
                ON govt_debt_rule.RuleName = 'TotalGovernmentDebt'
                AND govt_debt_rule.IsActive = 1
                AND govt_debt_rule.ScoreLevel <> 'Default'
                AND ROUND(a.BMI_DEBT_GOVT_PCGDP, 1) >= ISNULL(govt_debt_rule.MinValue, -999999999)
                AND ROUND(a.BMI_DEBT_GOVT_PCGDP, 1) <= ISNULL(govt_debt_rule.MaxValue, 999999999)
            LEFT JOIN DefaultScores govt_debt_default ON govt_debt_default.RuleName = 'TotalGovernmentDebt'

            -- PoliticalRisk
            LEFT JOIN CreditRating_BmiRule pol_risk_rule
                ON pol_risk_rule.RuleName = 'PoliticalRisk'
                AND pol_risk_rule.IsActive = 1
                AND pol_risk_rule.ScoreLevel <> 'Default'
                AND ROUND(a.BMI_INDEX_POLRISK_UNIT_50046_E, 1) >= ISNULL(pol_risk_rule.MinValue, -999999999)
                AND ROUND(a.BMI_INDEX_POLRISK_UNIT_50046_E, 1) <= ISNULL(pol_risk_rule.MaxValue, 999999999)
            LEFT JOIN DefaultScores pol_risk_default ON pol_risk_default.RuleName = 'PoliticalRisk'

            -- SecurityRisk
            LEFT JOIN CreditRating_BmiRule sec_risk_rule
                ON sec_risk_rule.RuleName = 'SecurityRisk'
                AND sec_risk_rule.IsActive = 1
                AND sec_risk_rule.ScoreLevel <> 'Default'
                AND ROUND(a.BMI_INDEX_POLRISK_SECURITY_UNIT_10012_E, 1) >= ISNULL(sec_risk_rule.MinValue, -999999999)
                AND ROUND(a.BMI_INDEX_POLRISK_SECURITY_UNIT_10012_E, 1) <= ISNULL(sec_risk_rule.MaxValue, 999999999)
            LEFT JOIN DefaultScores sec_risk_default ON sec_risk_default.RuleName = 'SecurityRisk'
        )
        INSERT INTO CreditRating_CountBmi (
            FK_Country_Id, CountryName, CountryRating, TitleCountryRating,
            NominalGDP_Score, NominalGDP,
            RealGDPGrowthIMFAE_Score, RealGDPGrowthIMFAE,
            RealGDPGrowth_Score, RealGDPGrowth,
            ConsumerPriceIMFAE_Score, ConsumerPriceIMFAE,
            ConsumerPrice_Score, ConsumerPrice,
            Unemployment_Score, Unemployment,
            ImportCoverMonths_Score, ImportCoverMonths,
            TotalExternalDebtStock_Score, TotalExternalDebtStock,
            ShortTermExternalDebt_Score, ShortTermExternalDebt,
            BudgetBalance_Score, BudgetBalance,
            TotalGovernmentDebt_Score, TotalGovernmentDebt,
            PoliticalRisk_Score, PoliticalRisk,
            SecurityRisk_Score, SecurityRisk,
            BusinessStrategy_Explain, BusinessStrategy,
            CreditRating_Explain, CreditRating,
            Outlook_Explain, Outlook,
            Other_Explain, Other,
            End_Explain, AssessmentDay
        )
        SELECT
            cm.PK_Id AS FK_Country_Id,
            CONCAT('國家：', ISNULL(bd.CountryName_TN, cm.CountryName_TN)) AS CountryName,
            ISNULL(rt.FinalRating, 5) AS CountryRating,
            ISNULL(rt.TitleRatingText, '國家風險等級：第五等') AS TitleCountryRating,
            bd.NominalGDP_Score,
            bd.NominalGDP,
            bd.RealGDPGrowthIMFAE_Score,
            bd.RealGDPGrowthIMFAE,
            bd.RealGDPGrowth_Score,
            bd.RealGDPGrowth,
            bd.ConsumerPriceIMFAE_Score,
            bd.ConsumerPriceIMFAE,
            bd.ConsumerPrice_Score,
            bd.ConsumerPrice,
            bd.Unemployment_Score,
            bd.Unemployment,
            bd.ImportCoverMonths_Score,
            bd.ImportCoverMonths,
            bd.TotalExternalDebtStock_Score,
            bd.TotalExternalDebtStock,
            bd.ShortTermExternalDebt_Score,
            bd.ShortTermExternalDebt,
            bd.BudgetBalance_Score,
            bd.BudgetBalance,
            bd.TotalGovernmentDebt_Score,
            bd.TotalGovernmentDebt,
            bd.PoliticalRisk_Score,
            bd.PoliticalRisk,
            bd.SecurityRisk_Score,
            bd.SecurityRisk,
            NULL AS BusinessStrategy_Explain,
            NULL AS BusinessStrategy,
            ISNULL(rt.RatingText, '第五等') AS CreditRating_Explain,
            ISNULL(rt.RatingScore, 1) AS CreditRating,
            ISNULL(rt.OutlookText, '持平') AS Outlook_Explain,
            ISNULL(rt.Score, 0) AS Outlook,
            NULL AS Other_Explain,
            NULL AS Other,
            CONCAT(ISNULL(bd.CountryName_TN, cm.CountryName_TN), '國家風險額度獲配___百萬美元，本次擬申請增加___百萬美元。') AS End_Explain,
            '評定日：' + FORMAT(@Date, 'yyyyMMdd') AS AssessmentDay
        FROM CountryMaster cm
        LEFT JOIN RatingText rt ON cm.PK_Id = rt.FK_Country_Id
        LEFT JOIN BMIData bd ON cm.PK_Id = bd.FK_Country_Id AND bd.rn = 1;


    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorLine INT = ERROR_LINE();
        PRINT '處理失敗於第 ' + CAST(@ErrorLine AS VARCHAR) + ' 行: ' + @ErrorMessage;
        THROW;
    END CATCH
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- 功能：客戶歸戶
-- 描述：用單個客戶歸戶，取找符合的GroupId或是返回新的GroupId
-- 單筆即時比對用的共用歸戶邏輯，供 C# 後端（CustomerService）呼叫，取代
-- GetOrCreateGroupId 內只比對 SwiftCode/LEI 完全相符的邏輯。
CREATE   PROCEDURE [dbo].[usp_ResolveGroupIdForCustomer]
    @PK_Id INT = NULL,                       --新增時為null，修改時才會帶入對應的Primary Key
    @CustomerName NVARCHAR(500) = NULL,      --客戶名稱
    @Unit NVARCHAR(50) = NULL,				 --客戶單位
    @SwiftCode NVARCHAR(20) = NULL,          --歸戶識別碼(SwiftCode)
    @LEI NVARCHAR(20) = NULL,			     --歸戶識別碼(LEI)
    @ISIN NVARCHAR(12) = NULL,               --歸戶識別嗎(ISIN)
    @CustomerMark NVARCHAR(50) = NULL,       --歸戶識別碼(客戶自行標記)
    @CreateIfNotFound BIT = 0				 --新增時是否回傳新的群組id
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ResolvedGroupId INT;
	--取得共用歸戶邏輯
    ;WITH Candidates AS (
        SELECT DISTINCT GroupId
        FROM dbo.ufn_MatchingCustomerGroupIds(@PK_Id, @CustomerName, @Unit, @SwiftCode, @LEI, @ISIN, @CustomerMark)
        WHERE GroupId IS NOT NULL
    )
    SELECT
        @ResolvedGroupId = MIN(GroupId)
    FROM Candidates;

    IF @ResolvedGroupId IS NULL AND @CreateIfNotFound = 1 --如果並未匹配到結果，並且需要回傳新的群組ID
    BEGIN
        EXEC dbo.usp_GetGroupId @GroupName = 'CustomerGroupId', @NewGroupId = @ResolvedGroupId OUTPUT; --呼叫後並且回傳
    END

    SELECT @ResolvedGroupId AS ResolvedGroupId;
END;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_UpdateCustomer]
    @IsScheduled BIT = 1  --這次重跑的觸發來源，寫入Customer_log.IsScheduled；
                           --1=排程/轉檔觸發（預設，沿用既有外部批次/轉檔呼叫端行為），
                           --0=手動觸發（由C#簽核流程結束後呼叫時明確帶入0）
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    ------------------------------------------------------------------------
    -- 0. 取出所有客戶，做為這次要處理的候選發起方
    ------------------------------------------------------------------------
    IF OBJECT_ID('tempdb..#WorkingSet') IS NOT NULL DROP TABLE #WorkingSet;
    SELECT PK_Id, GroupId, CustomerName, Unit, SwiftCode, LEI, ISIN, CustomerMark
    INTO #WorkingSet
    FROM Customer;

    CREATE UNIQUE CLUSTERED INDEX IX_WorkingSet_PK ON #WorkingSet(PK_Id);

    ------------------------------------------------------------------------
    -- 1. 對每一筆客戶比對「誰跟它是同一個客戶」，記成一條邊
    ------------------------------------------------------------------------
    IF OBJECT_ID('tempdb..#Edges') IS NOT NULL DROP TABLE #Edges;
    SELECT DISTINCT Type1, Key1, Type2, Key2
    INTO #Edges
    FROM (
        SELECT
            'P' AS Type1, a.PK_Id AS Key1,
            CASE WHEN m.GroupId IS NOT NULL THEN 'G' ELSE 'P' END AS Type2,
            CASE WHEN m.GroupId IS NOT NULL THEN m.GroupId ELSE m.PK_Id END AS Key2
        FROM #WorkingSet a
        CROSS APPLY dbo.ufn_MatchingCustomerGroupIds(
            a.PK_Id, a.CustomerName, a.Unit, a.SwiftCode, a.LEI, a.ISIN, a.CustomerMark) m
        WHERE (m.GroupId IS NOT NULL OR a.PK_Id < m.PK_Id)

        UNION ALL

        SELECT 'P' AS Type1, a.PK_Id AS Key1, 'G' AS Type2, a.GroupId AS Key2
        FROM #WorkingSet a
        WHERE a.GroupId IS NOT NULL
    ) e;

    ------------------------------------------------------------------------
    -- 1b. 把「客戶PK_Id」和「既有GroupId」統一編成一組連續整數NodeId
    ------------------------------------------------------------------------
    IF OBJECT_ID('tempdb..#NodeMap') IS NOT NULL DROP TABLE #NodeMap;
    SELECT NodeType, NodeKey, ROW_NUMBER() OVER (ORDER BY NodeType, NodeKey) AS NodeId
    INTO #NodeMap
    FROM (
        SELECT Type1 AS NodeType, Key1 AS NodeKey FROM #Edges
        UNION
        SELECT Type2 AS NodeType, Key2 AS NodeKey FROM #Edges
    ) x;

    CREATE UNIQUE CLUSTERED INDEX IX_NodeMap_Type_Key ON #NodeMap(NodeType, NodeKey);
    CREATE UNIQUE INDEX IX_NodeMap_NodeId ON #NodeMap(NodeId);

    ------------------------------------------------------------------------
    -- 1c. 把邊表轉成雙向的 #EdgesBi(NodeId, NeighborId)
    ------------------------------------------------------------------------
    IF OBJECT_ID('tempdb..#EdgesBi') IS NOT NULL DROP TABLE #EdgesBi;
    SELECT n1.NodeId, n2.NodeId AS NeighborId
    INTO #EdgesBi
    FROM #Edges e
    INNER JOIN #NodeMap n1 ON e.Type1 = n1.NodeType AND e.Key1 = n1.NodeKey
    INNER JOIN #NodeMap n2 ON e.Type2 = n2.NodeType AND e.Key2 = n2.NodeKey
    UNION ALL
    SELECT n2.NodeId, n1.NodeId AS NeighborId
    FROM #Edges e
    INNER JOIN #NodeMap n1 ON e.Type1 = n1.NodeType AND e.Key1 = n1.NodeKey
    INNER JOIN #NodeMap n2 ON e.Type2 = n2.NodeType AND e.Key2 = n2.NodeKey;

    CREATE CLUSTERED INDEX IX_EdgesBi_NodeId ON #EdgesBi(NodeId);

    ------------------------------------------------------------------------
    -- 2. 收斂：讓「有邊相連」的節點最終都拿到同一個代表值（CompLabel）
    ------------------------------------------------------------------------
    IF OBJECT_ID('tempdb..#Component') IS NOT NULL DROP TABLE #Component;
    SELECT NodeId, NodeId AS CompLabel
    INTO #Component
    FROM #NodeMap;

    CREATE UNIQUE CLUSTERED INDEX IX_Component_PK ON #Component(NodeId);

    DECLARE @RowsChanged INT = 1, @Iteration INT = 0, @MaxIteration INT = 50;

    WHILE @RowsChanged > 0 AND @Iteration < @MaxIteration
    BEGIN
        UPDATE c
        SET c.CompLabel = m.MinLabel
        FROM #Component c
        INNER JOIN (
            SELECT eb.NodeId, MIN(nb.CompLabel) AS MinLabel
            FROM #EdgesBi eb
            INNER JOIN #Component nb ON nb.NodeId = eb.NeighborId
            GROUP BY eb.NodeId
        ) m ON c.NodeId = m.NodeId
        WHERE c.CompLabel > m.MinLabel;

        SET @RowsChanged = @@ROWCOUNT;
        SET @Iteration += 1;
    END

    IF @Iteration >= @MaxIteration
    BEGIN
        RAISERROR('連通分量收斂超過預期迭代上限(50)，請人工檢查資料是否有異常巨型連結', 16, 1);
        RETURN;
    END

    ------------------------------------------------------------------------
    -- 3. 決定每個分量最終要用哪個GroupId
    ------------------------------------------------------------------------
    IF OBJECT_ID('tempdb..#ComponentGroups') IS NOT NULL DROP TABLE #ComponentGroups;
    SELECT c.CompLabel, nm.NodeKey AS OldGroupId
    INTO #ComponentGroups
    FROM #Component c
    INNER JOIN #NodeMap nm ON c.NodeId = nm.NodeId
    WHERE nm.NodeType = 'G';

    IF OBJECT_ID('tempdb..#ComponentAssign') IS NOT NULL DROP TABLE #ComponentAssign;
    SELECT CompLabel, MIN(OldGroupId) AS FinalGroupId
    INTO #ComponentAssign
    FROM #ComponentGroups
    GROUP BY CompLabel;

    IF OBJECT_ID('tempdb..#GroupMerge') IS NOT NULL DROP TABLE #GroupMerge;
    SELECT DISTINCT cg.OldGroupId, ca.FinalGroupId AS NewGroupId
    INTO #GroupMerge
    FROM #ComponentGroups cg
    INNER JOIN #ComponentAssign ca ON cg.CompLabel = ca.CompLabel
    WHERE cg.OldGroupId <> ca.FinalGroupId;

    CREATE UNIQUE CLUSTERED INDEX IX_GroupMerge_Old ON #GroupMerge(OldGroupId);

    ------------------------------------------------------------------------
    -- 到這裡為止都只在暫存表運算，沒動到Customer本表
    ------------------------------------------------------------------------
    BEGIN TRANSACTION;

    SELECT TOP (0) 1 FROM Customer WITH (TABLOCKX, HOLDLOCK);

    ------------------------------------------------------------------------
    -- 3a. 把「要被合併掉的舊GroupId」底下所有成員，一次性整批轉移
    ------------------------------------------------------------------------
    INSERT INTO Customer_log
        (IsScheduled, PK_Id, GroupId, CustomerName, Unit, CustomerId,
         SwiftCode, LEI, ISIN, CustomerMark, Remark, IsSystem,
         Update_date, Update_user, Create_date, Create_user, SysCreateDate, SysCreateUser)
    SELECT @IsScheduled, cu.PK_Id, cu.GroupId, cu.CustomerName, cu.Unit, cu.CustomerId,
        cu.SwiftCode, cu.LEI, cu.ISIN, cu.CustomerMark, cu.Remark, cu.IsSystem,
        cu.Update_date, cu.Update_user, cu.Create_date, cu.Create_user, GETDATE(), 'system'
    FROM Customer cu
    INNER JOIN #GroupMerge gm ON cu.GroupId = gm.OldGroupId;

    UPDATE cu
    SET cu.GroupId = gm.NewGroupId, cu.IsSystem = 1, cu.System_date = GETDATE()
    FROM Customer cu
    INNER JOIN #GroupMerge gm ON cu.GroupId = gm.OldGroupId;

    ------------------------------------------------------------------------
    -- 3a-ii. 把「原本沒有GroupId」的成員，補上這次算出來的最終GroupId
    ------------------------------------------------------------------------
    INSERT INTO Customer_log
        (IsScheduled, PK_Id, GroupId, CustomerName, Unit, CustomerId,
         SwiftCode, LEI, ISIN, CustomerMark, Remark, IsSystem,
         Update_date, Update_user, Create_date, Create_user, SysCreateDate, SysCreateUser)
    SELECT @IsScheduled, cu.PK_Id, cu.GroupId, cu.CustomerName, cu.Unit, cu.CustomerId,
        cu.SwiftCode, cu.LEI, cu.ISIN, cu.CustomerMark, cu.Remark, cu.IsSystem,
        cu.Update_date, cu.Update_user, cu.Create_date, cu.Create_user, GETDATE(), 'system'
    FROM Customer cu
    INNER JOIN #NodeMap nm ON cu.PK_Id = nm.NodeKey AND nm.NodeType = 'P'
    INNER JOIN #Component c ON nm.NodeId = c.NodeId
    INNER JOIN #ComponentAssign ca ON c.CompLabel = ca.CompLabel
    WHERE cu.GroupId IS NULL;

    UPDATE cu
    SET cu.GroupId = ca.FinalGroupId, cu.IsSystem = 1, cu.System_date = GETDATE()
    FROM Customer cu
    INNER JOIN #NodeMap nm ON cu.PK_Id = nm.NodeKey AND nm.NodeType = 'P'
    INNER JOIN #Component c ON nm.NodeId = c.NodeId
    INNER JOIN #ComponentAssign ca ON c.CompLabel = ca.CompLabel
    WHERE cu.GroupId IS NULL;

    ------------------------------------------------------------------------
    -- 3b. 完全沒有牽涉到既有GroupId的分量，一次性批次申請一段連續GroupId
    ------------------------------------------------------------------------
    IF OBJECT_ID('tempdb..#NewGroups') IS NOT NULL DROP TABLE #NewGroups;
    SELECT c.CompLabel,
        CAST(ROW_NUMBER() OVER (ORDER BY c.CompLabel) AS INT) AS Seq
    INTO #NewGroups
    FROM (SELECT DISTINCT CompLabel FROM #Component) c
    LEFT JOIN #ComponentAssign ca ON c.CompLabel = ca.CompLabel
    WHERE ca.CompLabel IS NULL;

    CREATE UNIQUE CLUSTERED INDEX IX_NewGroups_CompLabel ON #NewGroups(CompLabel);

    DECLARE @NewCount INT = (SELECT COUNT(*) FROM #NewGroups);

    IF @NewCount > 0
    BEGIN
        DECLARE @StartGroupId INT;

        SELECT @StartGroupId = GroupCount
        FROM GroupIdCounter WITH (UPDLOCK, ROWLOCK, HOLDLOCK)
        WHERE GroupName = 'CustomerGroupId';

        IF @StartGroupId IS NULL
        BEGIN
            ROLLBACK TRANSACTION;
            THROW 51000, 'GroupIdCounter 查無此 GroupName(CustomerGroupId)', 1;
            RETURN;
        END

        UPDATE GroupIdCounter
        SET GroupCount = GroupCount + @NewCount
        WHERE GroupName = 'CustomerGroupId';

        INSERT INTO Customer_log
            (IsScheduled, PK_Id, GroupId, CustomerName, Unit, CustomerId,
             SwiftCode, LEI, ISIN, CustomerMark, Remark, IsSystem,
             Update_date, Update_user, Create_date, Create_user, SysCreateDate, SysCreateUser)
        SELECT @IsScheduled, cu.PK_Id, cu.GroupId, cu.CustomerName, cu.Unit, cu.CustomerId,
            cu.SwiftCode, cu.LEI, cu.ISIN, cu.CustomerMark, cu.Remark, cu.IsSystem,
            cu.Update_date, cu.Update_user, cu.Create_date, cu.Create_user, GETDATE(), 'system'
        FROM Customer cu
        INNER JOIN #NodeMap nm ON cu.PK_Id = nm.NodeKey AND nm.NodeType = 'P'
        INNER JOIN #Component c ON nm.NodeId = c.NodeId
        INNER JOIN #NewGroups ng ON c.CompLabel = ng.CompLabel
        WHERE cu.GroupId IS NULL;

        UPDATE cu
        SET cu.GroupId = @StartGroupId + ng.Seq - 1, cu.IsSystem = 1, cu.System_date = GETDATE()
        FROM Customer cu
        INNER JOIN #NodeMap nm ON cu.PK_Id = nm.NodeKey AND nm.NodeType = 'P'
        INNER JOIN #Component c ON nm.NodeId = c.NodeId
        INNER JOIN #NewGroups ng ON c.CompLabel = ng.CompLabel
        WHERE cu.GroupId IS NULL;
    END

    COMMIT TRANSACTION;
END;
GO
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
CREATE PROCEDURE [dbo].[usp_UpdateMonitorDataPruduct07RiskFactor](@EXT_DATE AS DATE)
AS
BEGIN
	SET NOCOUNT ON;
    BEGIN TRY
		UPDATE MONITORDATA
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
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		allen
-- Create date: 20260424
-- Description:	更新指定轉檔日期MonitorData資料
-- =============================================
CREATE PROCEDURE [dbo].[usp_UpdateMonitorDataUnit] @EXT_DATE as date
AS
BEGIN
	SET NOCOUNT ON;
    BEGIN TRY
		update m set GROUP_NO =ISNULL(a.GroupCode,m.GROUP_NO) ,
				　	 UNIT_NO = ISNULL(b.UnitCode,m.UNIT_NO) ,
					BRANCH_NO = ISNULL(c.BankCode,m.BRANCH_NO),
					[YEAR] = YEAR(@EXT_DATE),
					[Month] = MONTH(@EXT_DATE),
					[Week] = dbo.ufn_GetWeekOfMonth(@EXT_DATE),
					EXT_DATE = @EXT_DATE
		from MONITORDATA m
		left join BankGroup a on left(dbo.ufn_CodePrefix(a.GroupCode),3) = m.GROUP_NO
		left join BankUnit b  on left(dbo.ufn_CodePrefix(b.UnitCode),3) = m.UNIT_NO
		left join BankBranch c on left(dbo.ufn_CodePrefix(c.BankCode),3) = m.BRANCH_NO AND
								 left(dbo.ufn_CodePrefix(b.UnitCode),3) = m.UNIT_NO AND
								b.PK_Id = c.FK_BankUnit
		where m.EXT_DATE = @EXT_DATE
	END TRY
    BEGIN CATCH
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT '發生錯誤: ' + @ErrorMsg;
        THROW;
    END CATCH
END
GO
COMMIT TRANSACTION;
GO
PRINT N'EF-managed table and module schema deployment completed.';
GO
