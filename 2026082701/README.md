# 2026082701 EL_ELLSTAPV_D_MF 新增 ELLSTAPV_EXT_DATE 欄位

## 目的與範圍

`EL_ELLSTAPV_D_MF`（授信逾期/警示名單）是唯一沒有依日期篩選、每次全表同步的 DW 表
（`DataMigrationByDwService.MigrateAllAsync` 呼叫 `MigrateAsync<EL_ELLSTAPV_D_MF>()` 沒帶
`queryBuilder`）。新增 `ELLSTAPV_EXT_DATE`（資料日期）欄位後，C# 端同步改為
`.Where(o => o.ELLSTAPV_EXT_DATE == date)`，比照其他 DW 表依日期篩選，不再每次整批同步。

Oracle 來源 `DTEL.EL_ELLSTAPV_D_MF.ELLSTAPV_EXT_DATE` 是 `CHAR(8)` 文字型日期，不是原生
`DATE`，`OracleDbContext` 已另外加上 `OracleCharDateOnlyConverter`（比照既有
`ACOLRT_STG.ACOLRT_LOAD_DATE` 的處理方式）轉換為 `DateOnly?`，格式錯誤時安全轉 `NULL`
而不中斷整批讀取。SQL Server 端維持一般 `date` 型別，不需要轉換。

本批次不會：

- 異動 `EL_ELLSTAPV_D_MF` 既有資料或其他欄位。
- 補建索引；`ELLSTAPV_EXT_DATE` 目前只作為每日同步的篩選條件，尚未評估是否需要索引。

## 上版前置條件

1. 確認執行帳號具備 `ALTER TABLE`／`sp_addextendedproperty` 權限。
2. 建議先於 Staging 環境執行，確認 `DataMigrationByDwService.MigrateAllAsync` 能正確依
   `ELLSTAPV_EXT_DATE` 篩選出當天資料再上正式環境。

## 執行順序

1. `Migration/EL_ELLSTAPV_D_MF_AddExtDate.sql`

腳本會在欄位已存在時立即 `THROW` 停止，可安全重跑判斷是否已執行過。

## 驗證與失敗處理

- 執行後查詢 `sys.columns` 確認 `EL_ELLSTAPV_D_MF.ELLSTAPV_EXT_DATE` 已存在且型別為 `date`。
- 跑一次 `DataMigrationByDwService.MigrateAllAsync`，確認 `EL_ELLSTAPV_D_MF` 這張表的
  `ReadCount`/`InsertedCount` log 只包含當天 `ELLSTAPV_EXT_DATE` 的資料，而不是整表筆數。
- 執行失敗會自動 `ROLLBACK`，可直接重跑。
- 本批次刻意不提供移除欄位的回復腳本；如需下版，直接
  `ALTER TABLE [dbo].[EL_ELLSTAPV_D_MF] DROP COLUMN [ELLSTAPV_EXT_DATE];` 即可，
  但需同步把 `DataMigrationByDwService.cs` 的 `queryBuilder` 改回不帶篩選。
