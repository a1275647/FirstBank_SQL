-- ══════════════════════════════════════════════════════════════════════════
-- [BankGroup] / [BankUnit] 新增 Seq 排序欄位
-- 第一層（BankGroup）與第二層（BankUnit）清單／下拉選單／組織樹統一依 Seq 排序
-- 第三層（BankBranch）沿用現有 BankCode 排序，不需新增欄位
-- 未在下方指定的單位，一律沿用 DEFAULT 99
-- ══════════════════════════════════════════════════════════════════════════

ALTER TABLE [BankGroup] ADD [Seq] int NOT NULL CONSTRAINT DF_BankGroup_Seq DEFAULT 99;
ALTER TABLE [BankUnit]  ADD [Seq] int NOT NULL CONSTRAINT DF_BankUnit_Seq  DEFAULT 99;

-- 第一層：國際 / 金融 / 法人金融 / 個人
UPDATE [BankGroup] SET [Seq] = 1 WHERE [GroupCode] = 'FB018'; -- 國際業務
UPDATE [BankGroup] SET [Seq] = 2 WHERE [GroupCode] = 'FB016'; -- 金融市場業務
UPDATE [BankGroup] SET [Seq] = 3 WHERE [GroupCode] = 'FB011'; -- 法人金融業務
UPDATE [BankGroup] SET [Seq] = 4 WHERE [GroupCode] = 'FB013'; -- 個人金融業務

-- 第二層：海外業務 / 外匯營運 / 金融市場 / 財務處 / 法人金融 / 消費金融
UPDATE [BankUnit] SET [Seq] = 1 WHERE [UnitCode] = 'H077050000'; -- 海外業務處
UPDATE [BankUnit] SET [Seq] = 2 WHERE [UnitCode] = 'H091050000'; -- 外匯營運處
UPDATE [BankUnit] SET [Seq] = 3 WHERE [UnitCode] = 'H089050000'; -- 金融市場業務處
UPDATE [BankUnit] SET [Seq] = 4 WHERE [UnitCode] = 'H069050000'; -- 財務處
UPDATE [BankUnit] SET [Seq] = 5 WHERE [UnitCode] = 'H064050000'; -- 法人金融業務處
UPDATE [BankUnit] SET [Seq] = 6 WHERE [UnitCode] = 'H067050000'; -- 消費金融業務處
