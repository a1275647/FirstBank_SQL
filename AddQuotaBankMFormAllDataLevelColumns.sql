-- ══════════════════════════════════════════════════════════════════════════
-- [QuotaBank_M_Form_AllData] 新增 UnitLevel / ParentUnitCode 欄位
-- 這張表是「額度分配-顯示全部」比較用的即時快照表，群/處/分行三層
-- （QuotaFirstService/QuotaUnitService/QuotaBranchService）共用同一張表寫入，
-- 原本只靠 FlowFormId + SysCreateDate 查詢，無法區分是哪一層存的，
-- 同一張表單同一時間戳跨層異動時，查出來的資料會混層、寬度對不上而顯示異常。
-- 既有資料無法回溯得知當初是哪一層存的，UnitLevel 一律先給 0（不屬於任何一層），
-- 上線後這些舊快照將不會出現在三層任一層的「顯示全部」比較結果中；
-- 新產生的快照則會照 UnitLevelType（Group=1/Unit=2/Branch=3）正確標記。
-- ══════════════════════════════════════════════════════════════════════════

ALTER TABLE [QuotaBank_M_Form_AllData] ADD [UnitLevel] int NOT NULL CONSTRAINT DF_QuotaBank_M_Form_AllData_UnitLevel DEFAULT 0;
ALTER TABLE [QuotaBank_M_Form_AllData] ADD [ParentUnitCode] nvarchar(20) NULL;
