# 2026082702 DAILY_CIF_TMP 移除誤設的 CIF_ID_NO 主鍵

## 目的與範圍

`DAILY_CIF_TMP` 的 `CIF_ID_NO` 被誤設為 Clustered Primary Key
（`PK_DAILY_CIF_TMP`），但 `FirstBankContext` 對這張表的設定是 `entity.HasNoKey()`，跟其他
DW 暫存表（`ACOLRT_STG`、`FPEXR_STG` 等）一致——這些表每天由
`DataMigrationByDwService.MigrateAsync` 先 `ExecuteDeleteAsync()` 清空、再整批
`BulkInsertAsync()` 寫入 Oracle 當日全量資料。

`CIF_ID_NO` 在 Oracle 來源不保證當天唯一（`DAILY_CIF_TMP` 是暫存表，非正式客戶主檔），
一旦來源出現重複值，`PK_DAILY_CIF_TMP` 的唯一性限制就會讓整批 `BulkInsertAsync` 失敗，
當天資料完全沒進去，只有 log 記錄，不會中斷 `MigrateAllAsync` 其他表的同步。

本批次不會：

- 異動 `DAILY_CIF_TMP` 既有資料或其他欄位定義。
- 補建其他索引；這張表目前查詢用途單純（全表覆蓋式暫存表），移除 PK 後不補建替代索引。

## 上版前置條件

1. 確認執行帳號具備 `ALTER TABLE`（`DROP CONSTRAINT`）權限。
2. `DROP CONSTRAINT` 在 Clustered PK 上會重建整張表的實體儲存結構，執行期間會鎖表；
   `DAILY_CIF_TMP` 資料量若不小，建議於離峰時段執行。

## 執行順序

1. `Migration/DAILY_CIF_TMP_DropCIFIdNoPK.sql`

腳本會在 `PK_DAILY_CIF_TMP` 已不存在時立即 `THROW` 停止，可安全重跑判斷是否已執行過。

## 驗證與失敗處理

- 執行後查詢 `sys.key_constraints`，確認 `dbo.DAILY_CIF_TMP` 已無 `PK_DAILY_CIF_TMP`。
- 跑一次 `DataMigrationByDwService.MigrateAllAsync`，確認 `DAILY_CIF_TMP` 這張表即使來源含
  重複 `CIF_ID_NO` 也能正常整批寫入（`InsertedCount` 等於 Oracle 端 `ReadCount`）。
- 執行失敗會自動 `ROLLBACK`，可直接重跑。
- 本批次刻意不提供還原腳本；如需恢復 PK，需先確認來源資料當天無重複
  `CIF_ID_NO`，否則還原後會立即重現原本的寫入失敗問題。
