# 2026082101 MONITORDATA 交易明細查詢索引修正

## 目的與範圍

新增索引 `IX_MONITORDATA_EXTDATE_MARK_UNIT`，修正全行額度／產品別／產業別三支動態查詢
的交易明細分頁查詢（`DimensionService.GetQuotaTransactionDataList`、
`GetProductTransactionDataListAsync`、`GetIndustryNewTransactionDataList`，共用
`QueryMonitorDataBase`／`GetTransactionDataQuery`）反應「查詢執行後卡住、一直轉圈」。

根因：這三支查詢皆以 `EXT_DATE`、`Mark` 過濾，並以 `GROUP_NO`/`UNIT_NO`/`BRANCH_NO`
三欄 OR 篩選權限單位。既有索引 `IX_MONITORDATA_ASOFDATE_MARK`、
`IX_MONITORDATA_ASOFDATE_PAGING` 領頭欄位是 `AS_OF_DATE`，跟查詢實際使用的 `EXT_DATE`
對不起來；唯一領頭 `EXT_DATE` 的 `IX_MONITORDATA_DATE` 又沒有 INCLUDE 查詢或顯示所需欄位。
加上 `Extension.IQueryable.ToPagedResponseAsync` 會對同一查詢執行兩次（`CountAsync()`
一次、`Skip/Take/ToListAsync()` 再一次），兩者疊加造成分頁查詢在資料量大時明顯變慢。

本批次不會：

- 異動 `MONITORDATA` 既有資料或既有索引。
- 修改三支動態查詢的 C# 查詢邏輯（例如 `GROUP_NO/UNIT_NO/BRANCH_NO` 三欄 OR 過濾的寫法）；
  若索引調整後效能仍不足，才需要評估改寫查詢。

## 上版前置條件

1. `MONITORDATA` 為大型交易明細表，本索引建置預設離線（`ONLINE = OFF`），執行期間會鎖表；
   建議於離峰維護時段執行。
2. 執行前請先在資料量與正式環境相近的環境估算建置時間，並確認執行帳號具備
   `CREATE INDEX` 權限。
3. 確認檔案群組 `NCRMS_IDX` 有足夠可用空間（本索引 INCLUDE 約 30 個欄位，索引本身會佔用
   不小的額外空間）。

## 執行順序

1. `Table/MONITORDATA_AddTransactionDataIndex.sql`

腳本會在索引已存在時立即 `THROW` 停止，可安全重跑判斷是否已執行過；不會嘗試修改或
重建已存在的同名索引。

## 驗證與失敗處理

- 本批次未提供獨立 Validation 腳本；建議執行後對三支交易明細 API（`/DimensionQuery/
  TransactionData/Quota`、`/Product`、`/Industry/New`）各查一次，比對執行計畫是否改用
  `IX_MONITORDATA_EXTDATE_MARK_UNIT`（Index Seek）取代原本的 Clustered Index Scan，
  並確認回應時間明顯縮短。
- 建置失敗或中斷時可重跑；若索引已存在但效能未如預期改善，代表瓶頸可能不只在索引，
  需回頭評估 `GROUP_NO/UNIT_NO/BRANCH_NO` 三欄 OR 過濾或查詢改寫。
- 本批次刻意不提供移除索引的回復腳本；如需下版，直接 `DROP INDEX
  [IX_MONITORDATA_EXTDATE_MARK_UNIT] ON [dbo].[MONITORDATA];` 即可，無資料風險。
