# 2026090102 OS_LNSLMSD_D_MF 新增根額度（TOP_LINE）欄位

## 目的與範圍

Oracle DTHST.OS_LNSLMSD_D_MF 新增了 5 個「根額度」欄位（截圖對照如下），SQL Server
端 `dbo.OS_LNSLMSD_D_MF` 需要補上對應欄位，DW 每日同步（`DataMigrationByDwService`）
才能把這些欄位一併帶過來：

| Oracle 欄位 | Oracle 型別 | SQL Server 欄位 | SQL Server 型別 | 說明 |
|---|---|---|---|---|
| LNSLMSD_TOP_LINE_LINE_NO | CHAR(13) | LNSLMSD_TOP_LINE_LINE_NO | nvarchar(13) | 根額度OBBS額度號碼 |
| LNSLMSD_TOP_LINE_CCY | CHAR(3) | LNSLMSD_TOP_LINE_CCY | nvarchar(3) | 根額度幣別 |
| LNSLMSD_TOP_LINE_APP_AMT | NUMBER(17,2) | LNSLMSD_TOP_LINE_APP_AMT | decimal(17,2) | 根額度核准金額 |
| LNSLMSD_TOP_LINE_CRISK | CHAR(2) | LNSLMSD_TOP_LINE_CRISK | nvarchar(2) | 根額度風險國別 |
| LNSLMSD_TOP_LINE_MATURITY | CHAR(10) | LNSLMSD_TOP_LINE_MATURITY | date | 根額度到期日 |

`LNSLMSD_TOP_LINE_MATURITY` 在 Oracle 端是 **CHAR(10)**，不是原生 DATE（跟同表既有的
`LNSLMSD_MATURITY` 不同——那個是原生 DATE）。已跟使用者確認實際格式是 `yyyyMMdd`
（8 碼日期右補 2 碼空白至 CHAR(10)）。SQL Server 端仍用 `date` 型別落地，C# 端
`OracleDbContext` 比照 `EL_ELLSTAPV_D_MF.ELLSTAPV_EXT_DATE`／`ACOLRT_STG.ACOLRT_LOAD_DATE`
的既有作法，用 `OracleCharDateOnlyConverter` 轉成 `DateOnly?`——該 converter 讀取時會先
`Trim()` 再用 `yyyyMMdd` 解析，剛好吃掉右邊補的空白；若某筆資料格式異常，安全轉 `NULL`
而不中斷整張表的讀取。

**務必注意**：`OracleDbContext.OnModelCreating` 對所有 Oracle 端 Entity 的 `DateOnly?`
屬性會「預設」套用 `NullableDateOnlyConverter`（假設來源是原生 Oracle DATE，直接綁定），
這條規則是用迴圈自動套用在每一個 Entity 屬性上。`LNSLMSD_TOP_LINE_MATURITY` 實際是
CHAR(10) 文字，如果只在 Entity 加上 `DateOnly?` 屬性、不額外覆寫，會被迴圈誤判成原生
DATE 型別去綁定 ODP.NET 參數而綁定失敗（比照既有 `ACOLRT_LOAD_DATE`/`ELLSTAPV_EXT_DATE`
註解說明的 ORA-01861 問題）。因此在 `OnModelCreating` 迴圈之後，額外用
`modelBuilder.Entity<OS_LNSLMSD_D_MF>().Property(e => e.LNSLMSD_TOP_LINE_MATURITY).HasConversion(OracleCharDateOnlyConverter)`
覆寫掉自動套用的轉換器。

## 對應程式碼變更

- `FirstBank_API/FirstBank_Entity/Entities/DWEntity/OS_LNSLMSD_D_MF.cs`：新增
  `LNSLMSD_TOP_LINE_LINE_NO`、`LNSLMSD_TOP_LINE_CCY`、`LNSLMSD_TOP_LINE_APP_AMT`、
  `LNSLMSD_TOP_LINE_CRISK`、`LNSLMSD_TOP_LINE_MATURITY` 5 個屬性。這個 Entity 類別是
  Oracle 端（`OracleDbContext`）與 SQL Server 端（`FirstBankContext`）共用，不需要另外
  改 Oracle 端的 DbSet 或欄位對應。
- `FirstBank_API/FirstBank_Entity/Entities/FirstBankContext.cs`：`OS_LNSLMSD_D_MF` 的
  `modelBuilder.Entity<>` 設定內補上對應 5 個欄位的 `HasMaxLength`/`HasColumnType`/
  `HasComment`。
- `SchedulerSystem/TransferDataAPI/Service/DataMigrationByDwService.cs` 的
  `MigrateAsync<OS_LNSLMSD_D_MF>` 呼叫本身不需要改——它是整個 Entity 複製，新屬性會
  自動一併同步，不用逐欄位維護投影清單。

## 本批次不會

- 判斷或轉換 `LNSLMSD_TOP_LINE_MATURITY` 的日期格式。
- 補索引；這 5 個新欄位目前沒有任何查詢用到，暫不評估。

## 上版前置條件

1. 確認執行帳號具備 `ALTER TABLE`／`sp_addextendedproperty` 權限。
2. 建議先於 Staging 環境執行，並跑一次 `DataMigrationByDwService.MigrateAllAsync`，
   確認 `OS_LNSLMSD_D_MF` 這 5 個新欄位有正確從 Oracle 帶值過來。

## 執行順序

1. `Migration/OS_LNSLMSD_D_MF_AddTopLineColumns.sql`

腳本會在任一欄位已存在時立即 `THROW` 停止，可安全重跑判斷是否已執行過。

## 驗證與失敗處理

- 執行後查詢 `sys.columns` 確認 5 個欄位皆已存在且型別如上表。
- 跑一次 DW 同步，抽查幾筆 `OS_LNSLMSD_D_MF` 資料，確認根額度欄位有值且格式跟 Oracle
  來源一致（尤其 `LNSLMSD_TOP_LINE_MATURITY` 是否維持原始字串格式，未被意外截斷）。
- 執行失敗會自動 `ROLLBACK`，可直接重跑。
- 本批次刻意不提供移除欄位的回復腳本；如需下版，直接對 5 個欄位執行
  `ALTER TABLE [dbo].[OS_LNSLMSD_D_MF] DROP COLUMN [欄位名稱];` 即可，但需同步把
  `OS_LNSLMSD_D_MF.cs`／`FirstBankContext.cs` 的對應屬性與設定一併移除。
