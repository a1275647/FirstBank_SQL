# 2026090201 MONITORDATA 新增剩餘根額度欄位

## 目的與範圍

`dbo.MONITORDATA` 目前已有 `TOP_Limit_Amount`（根額度核准金額）、`TOP_Limit_USD_Amount`
（根額度核准金額美金）兩個欄位。這批新增剩下 4 個「根額度」欄位，對應
[2026090102](../2026090102/) 幫 `OS_LNSLMSD_D_MF` 新增的 4 個 `LNSLMSD_TOP_LINE_*`
欄位，之後轉檔進 `MONITORDATA` 時會用到：

| 新欄位 | 型別 | 對應既有欄位（命名依據） | 說明 |
|---|---|---|---|
| TOP_Permit_No | nvarchar(13) | PERMIT_NO | 根額度OBBS額度號碼 |
| TOP_Limit_Cod | nvarchar(3) | LIMIT_COD | 根額度幣別 |
| TOP_Country_Cod | nvarchar(2) | COUNTRY_COD | 根額度風險國別 |
| TOP_Limit_Maturity | date | LIMIT_MATURITY | 根額度到期日 |

命名比照既有 `TOP_Limit_Amount` 的風格：`TOP_` 前綴 + 對應既有欄位語意，已與使用者
確認。

## 對應程式碼變更

- `FirstBank_API/FirstBank_Entity/Entities/MONITORDATA.cs`：補上 6 個 `TOP_` 屬性——
  這 4 個新欄位，以及原本就存在於 DB schema 但一直沒有對應到 Entity 的
  `TOP_Limit_Amount`／`TOP_Limit_USD_Amount`。`MONITORDATA` 這個 Entity 沒有
  `modelBuilder.Entity<MONITORDATA>()` 的 fluent 設定區塊，全部靠 Data Annotations
  （`[StringLength]` 等）+ 屬性名稱對應欄位名稱的預設慣例，所以不需要另外改
  `FirstBankContext.cs`。

## 本批次不會

- 異動任何 usp_SouceXX 轉檔 SP，讓它們實際把根額度資料寫進這 6 個欄位——目前沒有
  任何 SP 會用到，純粹先讓 DB schema／Entity 就緒。
- 補 `MONITORDATA_his`／`MONITORDATA_temp`——查過 FirstBank_SQL 沒有這兩張表的
  `Table/*.sql`，`MONITORDATA_his.cs`／`MONITORDATA_temp.cs` 這兩個 Entity 也還沒有
  對應到任何 `TOP_` 欄位，這批維持現狀不動，之後若要讓根額度資料進到變更歷程／待簽核
  暫存表，需要另外評估。

## 上版前置條件

1. 確認執行帳號具備 `ALTER TABLE`／`sp_addextendedproperty` 權限。
2. `MONITORDATA` 是交易明細大表，建議於離峰時段執行；本批次是單純 `ALTER TABLE ADD
   COLUMN`（無預設值、無資料回填），不會鎖表太久，但仍建議避開轉檔排程執行中的時間。

## 執行順序

1. `Migration/MONITORDATA_AddTopLineColumns.sql`

腳本會在任一欄位已存在時立即 `THROW` 停止，可安全重跑判斷是否已執行過。

## 驗證與失敗處理

- 執行後查詢 `sys.columns` 確認 4 個欄位皆已存在且型別如上表。
- 執行失敗會自動 `ROLLBACK`，可直接重跑。
- 本批次刻意不提供移除欄位的回復腳本；如需下版，直接對 4 個欄位執行
  `ALTER TABLE [dbo].[MONITORDATA] DROP COLUMN [欄位名稱];` 即可，無資料風險（欄位目前
  未被任何程式讀寫）。
