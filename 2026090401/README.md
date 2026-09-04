# 2026090401 補齊 DataMigrationByDwService 每日轉檔缺的 EXT_DATE 索引

## 背景

`TransferDataAPI/Service/DataMigrationByDwService.cs` 的 `MigrateAllAsync` 每天對 27 張 DW
來源表逐一執行「`ExecuteDeleteAsync()  WHERE <欄位>_EXT_DATE = @date` → 整批
`BulkInsertAsync`」。實際觀測到 `DAILY_CIF_TMP` 的 `ExecuteDeleteAsync` 因為找不到索引全表
掃描，耗時超過 EF Core 預設的 30 秒 `CommandTimeout` 而失敗（`MigrateAsync` 內部會 catch 住
例外、記 log 後繼續下一張表，不會中斷整個排程，但當天 `DAILY_CIF_TMP` 不會被更新）。

逐一盤點這 27 張表後發現：2026090101 那批（`Source01/04/06/09_Add*Index*.sql`）已經涵蓋
了其中 23 張，但那批索引是為了給 `usp_Souce0X_By_*` 系列 SP 用，挑的欄位跟
`DataMigrationByDwService` 實際篩選的欄位不完全一致，有 3 張表因此還是全表掃描：

- `DAILY_CIF_TMP`：2026090101/Source06 補的是 `IX_DAILY_CIF_TMP_CifIdNo`（`CIF_ID_NO`），
  給 SP 的 JOIN 用；`DataMigrationByDwService` 篩選的是 `CIF_EXT_DATE`，完全沒被涵蓋到。
- `OS_LNSLNKD_D_MF`、`OS_LNSSECD_D_MF`：這兩張表沒有被任何 `usp_Souce01_OBBS_By_*` SP
  用到，2026090101 那批索引完全沒提到，從建表以來就是純 heap table。

本批次補上這 3 張表各自 `EXT_DATE` 欄位的非叢集索引：

- `Table/DAILY_CIF_TMP_AddExtDateIndex.sql`：`IX_DAILY_CIF_TMP_ExtDate`（`CIF_EXT_DATE`）。
- `Table/OS_LNSLNKD_D_MF_OS_LNSSECD_D_MF_AddExtDateIndexes.sql`：
  `IX_OS_LNSLNKD_D_MF_ExtDate`（`LNSLNKD_EXT_DATE`）、
  `IX_OS_LNSSECD_D_MF_ExtDate`（`LNSSECD_EXT_DATE`）。

## 本批次不會

- 異動任何表的既有資料或欄位定義，也不會動 `DataMigrationByDwService.cs` 本身的邏輯或
  `CommandTimeout` 設定。
- 幫 `OSBDKF02_MF`、`OSFXKF02_MF`、`OSISKF02_MF`、`OSMMKF02_MF`、`OS_LNSMSTD_D_MF`、
  `OS_LNSLMSD_D_MF` 這 6 張表額外補 `EXT_DATE` 單欄索引。這 6 張表在 2026090101 已經有
  `(分行, EXT_DATE, ...)` 複合索引，但 `EXT_DATE` 不是鍵值第一欄，
  `DataMigrationByDwService` 只用 `EXT_DATE` 篩選時仍無法 Seek，只能對這支較窄的
  nonclustered index 做 Scan（仍比掃 heap 全表快，因為每頁能塞更多列）。是否要為了這支
  轉檔服務再疊一個單欄索引，需衡量額外索引在每日 `BulkInsertAsync` 大量寫入時的維護成本；
  目前這 6 張表尚未在 log 中觀測到逾時，先列為觀察項目，之後如果也開始逾時再補。

## 上版前置條件

1. 確認執行帳號具備 `CREATE INDEX` 權限，且檔案群組 `NCRMS_IDX` 有足夠可用空間。
2. 建索引期間會鎖表（`ONLINE = OFF`，比照既有慣例），建議於離峰時段、
   `DataMigrationByDwService.MigrateAllAsync` 排程不會同時執行時進行。

## 執行順序

兩支腳本互相獨立，可任意順序或分開執行：

1. `Table/DAILY_CIF_TMP_AddExtDateIndex.sql`
2. `Table/OS_LNSLNKD_D_MF_OS_LNSSECD_D_MF_AddExtDateIndexes.sql`

腳本會在對應索引已存在時立即 `THROW` 停止，可安全重跑判斷是否已執行過。

## 驗證與失敗處理

- 執行後查詢 `sys.indexes` 確認三個索引都已建立在對應表上。
- 找一天資料量較大的 `@EXT_DATE`，對這 3 張表各自的 `DELETE ... WHERE <欄位>_EXT_DATE = @date`
  搭配 `SET STATISTICS IO, TIME ON` 執行，確認執行計畫由 Table Scan 改為 Index Seek，
  邏輯讀取次數／耗時明顯下降。
- 實際跑一次 `MigrateAllAsync`，確認這 3 張表的 log 不再出現
  `Failed executing DbCommand` 逾時錯誤。
- 執行失敗會自動 `ROLLBACK`，可直接重跑。
- 本批次刻意不提供移除索引的回復腳本；如需下版，直接對各索引執行
  `DROP INDEX [索引名稱] ON [對應資料表];` 即可，無資料風險。
