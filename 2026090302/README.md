# 2026090302 DAILY_CIF_TMP 新增統一編號序號欄位

## 目的與範圍

Oracle DTCIF.DAILY_CIF_TMP 有 `CIF_ID_SER_NO CHAR(1)`（統一編號序號），SQL Server 端
`dbo.DAILY_CIF_TMP` 目前沒有對應欄位，`DataMigrationByDwService.MigrateAllAsync` 的每日
DW 同步無法把這個欄位帶過來，需要補上。

| Oracle 欄位 | Oracle 型別 | SQL Server 欄位 | SQL Server 型別 | 說明 |
|---|---|---|---|---|
| CIF_ID_SER_NO | CHAR(1) | CIF_ID_SER_NO | nvarchar(1) | 統一編號序號 |

SQL Server 端刻意用 `nvarchar` 而不是同表既有 `CIF_ID_NO`／`CIF_CUST_NAME`／
`CIF_NATION_CODE` 等欄位慣用的非 Unicode固定長度 `char`，是本次明確指定的型別。

## 對應程式碼變更

- `FirstBank_API/FirstBank_Entity/Entities/DWEntity/DAILY_CIF_TMP.cs`：新增
  `CIF_ID_SER_NO` 屬性（`string?`）。這個 Entity 類別是 Oracle 端（`OracleDbContext`）
  與 SQL Server 端（`FirstBankContext`）共用，不需要另外改 Oracle 端的 DbSet 或欄位
  對應——`OracleDbContext.OnModelCreating` 用反射迴圈自動套用新屬性，不用逐一設定。
- `FirstBank_API/FirstBank_Entity/Entities/FirstBankContext.cs`：`DAILY_CIF_TMP` 的
  `modelBuilder.Entity<>` 設定內補上 `CIF_ID_SER_NO` 的 `HasMaxLength(1)` /
  `IsUnicode(false)` / `IsFixedLength()`，比照同表其餘欄位寫法。
- `SchedulerSystem/TransferDataAPI/Service/DataMigrationByDwService.cs` 的
  `MigrateAsync<DAILY_CIF_TMP>` 呼叫本身不需要改——它是整個 Entity 複製，新屬性會
  自動一併同步，不用逐欄位維護投影清單。

## 本批次不會

- 補齊 Oracle DTCIF.DAILY_CIF_TMP 其餘尚未帶入的欄位（例如 CIF_ID_CHK、
  CIF_ESTABL_BIRTH_DATE 等）；目前只依需求新增 CIF_ID_SER_NO。
- 補索引；這個新欄位目前沒有任何查詢用到，暫不評估。

## 上版前置條件

1. 確認執行帳號具備 `ALTER TABLE`／`sp_addextendedproperty` 權限。
2. 建議先於 Staging 環境執行，並跑一次 `DataMigrationByDwService.MigrateAllAsync`，
   確認 `DAILY_CIF_TMP` 的 `CIF_ID_SER_NO` 有正確從 Oracle 帶值過來。

## 執行順序

1. `Migration/DAILY_CIF_TMP_AddCifIdSerNo.sql`

腳本會在欄位已存在時立即 `THROW` 停止，可安全重跑判斷是否已執行過。

## 驗證與失敗處理

- 執行後查詢 `sys.columns` 確認 `CIF_ID_SER_NO` 已存在且型別為 `nvarchar(1)`。
- 跑一次 DW 同步，抽查幾筆 `DAILY_CIF_TMP` 資料，確認 `CIF_ID_SER_NO` 有值且跟 Oracle
  來源一致。
- 執行失敗會自動 `ROLLBACK`，可直接重跑。
- 本批次刻意不提供移除欄位的回復腳本；如需下版，直接執行
  `ALTER TABLE [dbo].[DAILY_CIF_TMP] DROP COLUMN [CIF_ID_SER_NO];` 即可，但需同步把
  `DAILY_CIF_TMP.cs`／`FirstBankContext.cs` 的對應屬性與設定一併移除。
