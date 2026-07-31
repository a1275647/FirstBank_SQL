-- ══════════════════════════════════════════════════════════════════════════
-- [MailGroup] 新增 IsActive 欄位，支援信件群組軟刪除（停用取代實體刪除）
-- 既有資料一律預設為啟用中 (1)
-- ══════════════════════════════════════════════════════════════════════════

ALTER TABLE [MailGroup] ADD [IsActive] BIT NOT NULL CONSTRAINT DF_MailGroup_IsActive DEFAULT 1;
