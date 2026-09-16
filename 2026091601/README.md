# 2026091601 動態查詢改以計算後美金金額（CAL_TO_USD_AMT／CAL_TO_USD_LIMIT）為準

## 目的與範圍

三支動態查詢（全行額度分配、產品別、產業別）的「使用餘額」與「佔用額度」原本抓
`MONITORDATA` 的原始美金欄位 `TO_USD_AMT`／`TO_USD_LIMIT`，改為抓排程算好的計算後欄位
`CAL_TO_USD_AMT`／`CAL_TO_USD_LIMIT`（已套用風險係數；到期額度的佔用額度改計餘額）。

本批次只調整 `ufn_table_GetMonitorDataLimitAmount`：

1. `SUM_TO_USD_LIMIT`（佔用額度）的去重分組與取值，由 `TO_USD_LIMIT` 改為 `CAL_TO_USD_LIMIT`。
2. **已到期額度（`LIMIT_MATURITY <= EXT_DATE`）不去重，每筆各算自己的 `CAL_TO_USD_LIMIT`。**
   `usp_UpdateMonitorDataLimit` 會把到期列的 `CAL_TO_USD_LIMIT` 改成各筆交易餘額，此時它已不是
   核准編號的屬性；若仍以「同核准編號同金額只算一次」去重，同一核准編號下兩筆餘額相同的到期
   交易會被少算一筆。TVF 內的到期條件必須與 `usp_UpdateMonitorDataLimit` 保持一致。
3. 輸出欄位補上 `CAL_TO_USD_AMT`、`CAL_TO_USD_LIMIT`。
4. 根額度封頂（`TOP_Limit_USD_Amount`）維持以原始美金金額比較，**不乘風險係數**。

`IX_MONITORDATA_EXTDATE_MARK_UNIT` 的 INCLUDE 清單原本就含這兩欄（見
[2026082101](../2026082101/)），索引不需異動。

## 對應程式碼變更

`FirstBank_Service/Services/DimensionService.cs`：

| 查詢 | 使用餘額 | 佔用額度 |
| --- | --- | --- |
| 全行額度分配（主表／當月最高餘額／Top30） | TVF `CAL_TO_USD_AMT` | TVF `SUM_TO_USD_LIMIT`（改由 CAL 計算） |
| 產品別（主表／Top30） | `MONITORDATA.CAL_TO_USD_AMT` | `MONITORDATA.CAL_TO_USD_LIMIT` |
| 產業別（主表／Top30） | `MONITORDATA.CAL_TO_USD_AMT` | `MONITORDATA.CAL_TO_USD_LIMIT` |

同口徑一併調整：

| 功能 | 檔案 | 使用餘額 |
| --- | --- | --- |
| 國家金額報表 `ExportCountryAmountReport` | `ExcelPDF/ExcelExportService.cs` | TVF `CAL_TO_USD_AMT` |
| 國家風險等級金額報表 `ExportCountryRiskLevelAmountReport` | `ExcelPDF/ExcelExportService.cs` | TVF `CAL_TO_USD_AMT` |
| 國家預警排程 `CountryWarningTask` | `SchedulerTaskService.cs` | `MONITORDATA.CAL_TO_USD_AMT` |

兩支報表的佔用額度原本就取自本 TVF 的 `SUM_TO_USD_LIMIT`，上版後同步變為 CAL 口徑。

交易明細（`TransactionDataDto`）仍回傳原始 `TO_USD_AMT`／`TO_USD_LIMIT`，並另帶 `CalToUsdAmt`／
`CalToUsdLimit`，不受影響。

## 本批次不會

- 對 `CAL_*` 為 NULL 的資料做 `TO_USD_*` 保底；請先確認歷史資料已由排程補齊。

## 上版前置條件

1. `dbo.MONITORDATA` 已有 `CAL_TO_USD_AMT`、`CAL_TO_USD_LIMIT` 兩欄（腳本會檢查並 `THROW`）。
2. 歷史資料已依序執行 `usp_UpdateMonitorDataPruduct07RiskFactor`、`usp_UpdateMonitorDataCNWeights`、
   `usp_UpdateMonitorDataCalculatedUsdAmount`、`usp_UpdateMonitorDataLimit`，否則查詢期間的 `CAL_*`
   為 NULL，動態查詢與報表金額會顯示 0。
   - 2026-09-16 測試 DB 查核：所有資料日的 `RISKFACTOR`、`CAL_*` 皆為 NULL；串接這四支 SP 的
     `usp_TransferDataAfterUpdateMonitorData` 存在於 repo 但**尚未部署到 DB**，需先部署並確認轉檔
     排程會呼叫它。
3. 若目標環境曾以 [2026081801](../2026081801/) 全量腳本建置，其中的 `ufn_table_GetMonitorDataLimitAmount`
   為舊版（無根額度封頂），本批次必須排在它之後執行。

## 執行順序

1. `TableFunction/ufn_table_GetMonitorDataLimitAmount_UseCalculatedUsd.sql`（`CREATE OR ALTER`，可重跑）

## 驗證與失敗處理

- 執行後以任一資料日呼叫 `SELECT TOP 10 CAL_TO_USD_AMT, CAL_TO_USD_LIMIT, SUM_TO_USD_LIMIT FROM
  dbo.ufn_table_GetMonitorDataLimitAmount('2026-08-06')` 確認新欄位有值。
- 回復方式：重新執行 `TableFunction/ufn_table_GetMonitorDataLimitAmount.sql` 的前一版本
  （改為 `CREATE OR ALTER`）即可。
