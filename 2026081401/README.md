# 2026081401 國家信用評等目前值週快照表

## 目的與範圍

新增 `CreditRating_Country_Current_Week`，供每日排程（`SchedulerTaskController.DataCopyToWeek` → `DataToWeekService.CreditRatingCountryCopyToWeek`）將 `CreditRating_Country_Current` 的目前值複製成週紀錄，比照既有的 `BankYearNeWorthBase_Week`、`QuotaBank_M_Week` 週快照表模式。

`CreditRating_Country_Current_Week` 每列代表「某年 / 月 / 週 × 國家 × 信評公司」的一筆快照，欄位內容為當次複製時 `CreditRating_Country_Current` 的完整值（含 `RatingDate` 可為 `NULL`，比照 2026081202 對 `CreditRating_Country_Current.RatingDate` 的欄位修正）。與其他既有週表一致，本表**不**對 `CountryMaster`／`CreditRatingMaster` 建外鍵，避免主檔資料異動或刪除時卡住歷史快照。

本批次不會：

- 回填歷史週資料；新表建立後保持空表，之後由排程逐週寫入。
- 修改 `CreditRating_Country_Current` 或其他既有資料表結構。

## 上版前置條件

1. 確認 `dbo.CreditRating_Country_Current` 已存在（2026081201／2026081202 已建立）。
2. 確認執行帳號具備 `CREATE TABLE` 權限。

## 執行順序

1. `Table/CreditRating_Country_Current_Week.sql`

資料表建立腳本會在物件已存在時檢查其結構（欄位、型別、nullability、unique constraint、索引），結構不符時立即停止，可安全重跑。

## 驗證與失敗處理

- 本批次未提供獨立 Validation 腳本；新表一開始為空表，且建立腳本本身已內建結構檢核（不符即 `THROW`）。
- 若需要確認排程是否正確寫入，可於首次執行 `DataCopyToWeek` 後直接查詢 `CreditRating_Country_Current_Week` 筆數是否與當週 `CreditRating_Country_Current` 筆數一致。
