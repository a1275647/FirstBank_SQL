# 2026090901 MONITORDATA 交易明細索引補上根額度欄位

## 目的與範圍

重建 `IX_MONITORDATA_EXTDATE_MARK_UNIT`，在 INCLUDE 清單補上 `TOP_Permit_No`、
`TOP_Limit_USD_Amount` 兩欄；鍵值（`EXT_DATE`, `Mark`）與既有 30 個 INCLUDE 欄位的順序
完全不變。

根因是兩個批次之間的落差：

1. [2026082101](../2026082101/) 建立 `IX_MONITORDATA_EXTDATE_MARK_UNIT` 時，INCLUDE 清單
   完整涵蓋當時 `ufn_table_GetMonitorDataLimitAmount` 會讀到的欄位。
2. [2026090201](../2026090201/) 幫 `MONITORDATA` 新增根額度欄位後，該 TVF 改用
   `TOP_Permit_No`／`TOP_Limit_USD_Amount` 計算 `SUM_TO_USD_LIMIT`（同一條根額度下的子額度
   加總後以根額度上限封頂），**但索引沒有跟著補這兩欄**。
3. 覆蓋因此失效。最佳化工具改用窄索引 `IX_MONITORDATA_DATE`（鍵值 `EXT_DATE`, `Year`,
   `Month`, `Week`，沒有任何 INCLUDE），再逐列回 clustered index 取其餘欄位。

實測（測試 DB，`EXT_DATE = '2026-08-06'`，18,658 筆）：

| 查詢讀取的欄位 | logical reads | 使用索引 | Key Lookup |
| --- | ---: | --- | --- |
| 只讀索引內既有欄位 | 646 | IX_MONITORDATA_EXTDATE_MARK_UNIT | 無 |
| 另外讀 `TOP_Permit_No`、`TOP_Limit_USD_Amount` | 59,593 | IX_MONITORDATA_DATE | 有 |

全行額度動態查詢（`GET /api/DimensionQuery/QuotaBank`）在 100 併發壓測下，TVF 平均每次
202,570 logical reads、平均 elapsed 1,606 ms，佔該 API 全部 SQL 時間約 65%；執行計畫中回表的
`Clustered Index Seek` 節點佔整句預估成本約 90%。

## 對應程式碼變更

無。本批次只調整索引，`ufn_table_GetMonitorDataLimitAmount` 與所有 C# 呼叫端都不需要改。

## 本批次不會

- 異動 `ufn_table_GetMonitorDataLimitAmount` 的定義或任何查詢邏輯。
- 新增第二個索引。採 `DROP_EXISTING = ON` 就地重建同名索引，不增加 DML 端要維護的索引數量。
- 補其餘 4 個根額度欄位（`TOP_Limit_Amount`／`TOP_Limit_Cod`／`TOP_Country_Cod`／
  `TOP_Limit_Maturity`）。TVF 目前的兩個呼叫端（`DimensionService.GetDimensionQuotaList`、
  `ExcelPDF/ExcelExportService`）都沒有投影到這 4 欄，加進去只會讓索引更肥。日後若有呼叫端
  投影到它們，覆蓋會再次失效，屆時需要再評估。
- 更新 `FirstBank_SQL/Table/MONITORDATA.sql`。該檔目前也沒有 2026082101 建立的
  `IX_MONITORDATA_EXTDATE_MARK_UNIT`，維持與前一批次相同做法，以批次資料夾為準。

## 上版前置條件

1. 需先完成 [2026082101](../2026082101/)（索引存在）與 [2026090201](../2026090201/)
   （兩個欄位存在）；腳本會各自檢查並在缺少時 `THROW` 停止。
2. 索引現況約 1,437 MB / 5,290,311 列（測試 DB 數據），補兩欄後預估再增加約 100–150 MB。
   請確認檔案群組 `NCRMS_IDX` 有足夠空間，重建期間另需相當於索引大小的暫存空間。
3. 腳本比照 2026082101 採 `ONLINE = OFF`，**重建期間會鎖住 `MONITORDATA`**，請於離峰維護
   時段執行，並避開轉檔排程。若目標環境為 Enterprise／Developer Edition 且需要線上重建，
   可自行將 `ONLINE = OFF` 改為 `ONLINE = ON`（本腳本未預設開啟，以免在 Standard Edition
   直接失敗）。
4. 確認執行帳號具備 `ALTER`／`CREATE INDEX` 權限。

## 執行順序

1. `Table/MONITORDATA_ExtendTransactionDataIndexIncludes.sql`

腳本在索引已包含 `TOP_Permit_No` 時會立即 `THROW` 停止，可安全重跑判斷是否已執行過。

## 驗證與失敗處理

- 執行後查 `sys.index_columns` 確認 `IX_MONITORDATA_EXTDATE_MARK_UNIT` 的 INCLUDE 欄位為 32 個，
  且包含 `TOP_Permit_No`、`TOP_Limit_USD_Amount`。
- 驗證覆蓋是否恢復：對 `MONITORDATA` 下一句同時讀 `TOP_Permit_No` 與 `TO_USD_AMT`、
  條件為單一 `EXT_DATE` 的查詢，檢查執行計畫應使用 `IX_MONITORDATA_EXTDATE_MARK_UNIT`
  且不含 Key Lookup，logical reads 應回到數百頁等級。
- 執行失敗會自動 `ROLLBACK`；因為是 `DROP_EXISTING` 重建，失敗時既有索引維持原狀，可直接重跑。
- 回復方式：重跑 [2026082101](../2026082101/) 的索引定義（同樣加上 `DROP_EXISTING = ON`）即可
  還原成不含這兩欄的版本。回復後 TVF 會退回 Key Lookup 計畫，只影響效能，不影響查詢結果。
