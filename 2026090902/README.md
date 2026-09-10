# 2026090902 MONITORDATA 交易明細索引合併腳本（供其他環境部署）

## 目的與範圍

合併 [2026082101](../2026082101/)（建立 `IX_MONITORDATA_EXTDATE_MARK_UNIT`）與
[2026090901](../2026090901/)（補上 `TOP_Permit_No`／`TOP_Limit_USD_Amount` 兩個
INCLUDE 欄位）兩個既有批次成一份可重跑腳本，供不確定目標環境現況（是否已跑過
0、1 或 2 個原批次）的其他環境部署使用，不需要照順序執行兩份檔案、也不需要先
查清楚該環境跑到哪一步。

腳本會依目標環境現況自動判斷該做什麼：

- 索引不存在 → 直接建立（32 欄 INCLUDE）。
- 索引存在但缺 `TOP_Permit_No`／`TOP_Limit_USD_Amount` → 用 `DROP_EXISTING` 就地
  重建補上，等同執行一次 2026090901。
- 索引存在且已含這兩欄 → 視為已是最終狀態，印出訊息後直接結束，不做任何 DDL。

鍵值（`EXT_DATE`, `Mark`）與全部 32 個 INCLUDE 欄位，逐行比對過與原兩個批次的
定義完全一致，僅重新包裝成單一、可重跑的腳本。

## 對應程式碼變更

無。本批次只是把既有兩個索引批次重新包裝成一份給其他環境使用的部署腳本，不
涉及任何新的 C# 或 SP 變更，也不改變索引本身的定義。

## 本批次不會

- 異動 [2026082101](../2026082101/) 或 [2026090901](../2026090901/) 這兩個既有批次
  的檔案內容——原批次維持不動，作為本 repo 自己環境的部署歷程記錄；本批次僅供
  「跳過歷史、直接部署到最終狀態」的其他環境使用。
- 調整索引定義本身。鍵值與 INCLUDE 欄位清單與原兩批次的最終結果完全相同。

## 上版前置條件

1. `dbo.MONITORDATA` 存在。
2. `dbo.MONITORDATA` 已有 `TOP_Permit_No`、`TOP_Limit_USD_Amount` 兩欄（見
   [2026090201](../2026090201/)，`Migration/MONITORDATA_AddTopLineColumns.sql`）；
   腳本會檢查並在缺少時 `THROW` 停止。
3. `MONITORDATA` 為大型交易明細表，索引建立／重建預設離線（`ONLINE = OFF`），
   執行期間會鎖表；建議於離峰維護時段執行，並確認檔案群組 `NCRMS_IDX` 有足夠
   可用空間（INCLUDE 32 個欄位；索引已存在需重建的情況另需相當於索引大小的
   暫存空間）。若目標環境為 Enterprise／Developer Edition 且需要線上建置／
   重建，可自行將腳本內的 `ONLINE = OFF` 改為 `ONLINE = ON`。

## 執行順序

1. `Table/MONITORDATA_TransactionDataIndex_Consolidated.sql`

腳本會自動判斷目標環境現況，可安全重跑：不會產生第二個同名索引，也不會對已
是最終狀態的環境誤報錯誤。

## 驗證與失敗處理

- 執行後查 `sys.index_columns` 確認 `IX_MONITORDATA_EXTDATE_MARK_UNIT` 的 INCLUDE
  欄位為 32 個，且包含 `TOP_Permit_No`、`TOP_Limit_USD_Amount`。
- 若目標環境本來就已是最終狀態，腳本會印出「已是最終狀態…不做任何變更」並直接
  結束，不會有任何 DDL 動作。
- 執行失敗會自動 `ROLLBACK`；因為是可重跑腳本，失敗時既有索引維持原狀，可直接
  重跑排查後再執行一次。
- 回復方式：直接 `DROP INDEX [IX_MONITORDATA_EXTDATE_MARK_UNIT] ON [dbo].[MONITORDATA];`
  即可移除，無資料風險。
