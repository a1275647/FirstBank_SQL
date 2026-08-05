-- ══════════════════════════════════════════════════════════════════════════
-- MailService.GetHistoryData / GetHistoryDetail 效能優化索引
-- 對應 FirstBankContext.cs 裡同名的 HasIndex(...) fluent config，Model 與 DB 結構保持一致。
-- ══════════════════════════════════════════════════════════════════════════

-- Mail_his：GetHistoryForm(FlowForm) GroupJoin Mail_his 皆以 FlowFormId 反查歷程。
CREATE NONCLUSTERED INDEX IX_Mail_his_FlowFormId
ON [dbo].[Mail_his] ([FlowFormId]);

-- MailGroupMapping_his / MailGroupCcMapping_his：GetHistoryDetail 依 Mail_his.Log_Id
-- 取收件/副本群組明細。
CREATE NONCLUSTERED INDEX IX_MailGroupMapping_his_FK_LogId
ON [dbo].[MailGroupMapping_his] ([FK_LogId]);

CREATE NONCLUSTERED INDEX IX_MailGroupCcMapping_his_FK_LogId
ON [dbo].[MailGroupCcMapping_his] ([FK_LogId]);

-- MailCcMapping_his / MailToMapping_his：GetHistoryDetail 依 Mail_his.Log_Id 取收件人/副本明細。
CREATE NONCLUSTERED INDEX IX_MailCcMapping_his_Fk_LogId
ON [dbo].[MailCcMapping_his] ([Fk_LogId]);

CREATE NONCLUSTERED INDEX IX_MailToMapping_his_Fk_LogId
ON [dbo].[MailToMapping_his] ([Fk_LogId]);

-- MailCustomCcMapping_his / MailCustomToMapping_his：GetHistoryDetail 依 Mail_his.Log_Id
-- 取自行輸入的收件人/副本明細。
CREATE NONCLUSTERED INDEX IX_MailCustomCcMapping_his_Fk_LogId
ON [dbo].[MailCustomCcMapping_his] ([Fk_LogId]);

CREATE NONCLUSTERED INDEX IX_MailCustomToMapping_his_Fk_LogId
ON [dbo].[MailCustomToMapping_his] ([Fk_LogId]);
