# 2026081202 國家信用評等歷程 schema 修正

本批次承接已執行過建表步驟、但歷史搬移失敗的 `2026081201`。`2026081201` 保留為已執行的歷史版本，不直接改寫；最終 schema、歷程搬移與目前值初始化都由本批次完成。

## 修正內容

- 為 `CreditRating_Country_Log`、`CreditRating_Country_Log_Detail` 補上 `BusinessDate`。
- 移除 Detail 對 Log 的必要外鍵與 `FK_CreditRatingCountryLogId`，兩張歷程表改為獨立留存。
- Log 唯一鍵改為「國家＋BusinessDate」；Detail 唯一鍵改為「國家＋信評公司＋BusinessDate」。
- 移除 Detail 的 `updated_Date`；Detail／Current 的來源 `RatingDate` 改為可空值。
- 以歷程最新資料補齊或向前更新 `CreditRating_Country_Current` 與 `CountryMaster`，不覆蓋時間較新的已發布資料。
- 取代失敗的舊版 `CreditRating_Country_HistoryMigration.sql`：分別完整搬移兩張舊表並保留 `PK_Id`，不要求 Detail 存在同日 Log。

## 執行前置條件與順序

1. 停止國家信評寫入排程並備份資料庫。
2. 確認舊表與 `2026081201` 新表均存在。
3. 不要再執行舊版 `2026081201/Migration/CreditRating_Country_HistoryMigration.sql`；執行 `Migration/Realign_CreditRating_Country_HistorySchema.sql`，由本腳本同時完成 ALTER、歷程搬移及目前值初始化。
4. 執行 `Validation/CreditRating_Country_HistorySchemaValidation.sql`，驗證最終 schema、兩張舊表的完整搬移、Current／CountryMaster 初始化及 foreign key trust。

腳本第一個 batch 只會以 nullable 型別補上缺少的 BusinessDate，第二個 batch 才檢核資料，並在單一交易內回填與完成其餘修正。若第二個 batch 失敗，欄位可能保留但資料與 constraint 修正會 rollback；排除原因後可安全重跑。BusinessDate 無法推得、業務鍵重複、外鍵來源不存在或 legacy Score 超出目前值欄位可保存的 0 至 255 時會停止。新發布流程仍只產生正式的 1 至 5 等級。腳本不刪除或重新命名舊表。
