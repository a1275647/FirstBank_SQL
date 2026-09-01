# 2026090101 usp_Souce0X 系列來源表補索引

## 目的與範圍

`usp_Souce01_*`、`usp_Souce04_*`、`usp_Souce06_*`、`usp_Souce09_*` 共 18 支轉檔 SP，都是
以「找出某張來源表的最新一批資料（依 EXT_DATE，部分還要再依分行分組）」開頭。這些來源表
目前全部是 heap table（無 PK、無任何索引），每支 SP 每次執行都要對來源表做 1～2 次全表掃描
才能定位到當天要處理的資料，資料量成長後會愈跑愈慢。

新增 21 個非叢集索引，涵蓋以下 4 組：

- `Table/Source06_AddJoinIndexes.sql`：`FL_FLMST_D_MF`（`IX_FL_FLMST_D_MF_ExtDate`）、
  `FM_FMLINE_D_MF`（`IX_FM_FMLINE_D_MF_JoinKey`）、`DAILY_CIF_TMP`
  （`IX_DAILY_CIF_TMP_CifIdNo`）、`EL_ELLSTAPV_D_MF`
  （`IX_EL_ELLSTAPV_D_MF_ExtDateJoinKey`，鍵值 `ELLSTAPV_EXT_DATE, ELLSTAPV_CUST_ID,
  ELLSTAPV_APRV_NO`）。對應 `usp_Souce06_By_FL_FLMST_D_MF`。`EL_ELLSTAPV_D_MF` 這段 JOIN
  在 SP 裡目前是註解、尚未啟用，但 2026082701 已補上 `ELLSTAPV_EXT_DATE` 欄位且既有 DW
  每日同步已用它篩選，先一併補索引，避免未來真的接上這段 JOIN 時才發現又要重新補。
- `Table/Source01_AddLatestSnapshotIndexes.sql`：`OSBDKF02_MF`、`OSFXKF02_MF`、
  `OSISKF02_MF`、`OSMMKF02_MF`（皆為 `分行+資料日期`），以及互相 JOIN 的
  `OS_LNSMSTD_D_MF`、`OS_LNSLMSD_D_MF`（`分行+資料日期+額度號碼`）。對應
  `usp_Souce01_OBBS_By_*` 5 支 SP。
- `Table/Source04_AddLatestDateIndex.sql`：`LS_LSRSA_D_MF`（資料日期）。對應
  `usp_Souce04_By_LS_LSRSA_D_MF_ACNOD_STG` 的第一個分支；第二個分支用的 `ACNOD_STG`
  已有 `IX_ACNOD_STG`，不重複處理。
- `Table/Source09_AddLatestDateIndexes.sql`：11 張 `ARS_SUK*` 來源表（資料日期），對應
  `usp_Souce09_By_ARS_*` 11 支 SP。

索引鍵值只涵蓋「找最新一批資料」與「表間 JOIN」用到的欄位（分行代號、資料日期、額度
號碼、客戶編號等），比照既有 `dbo.ACNOD_STG` 的 `IX_ACNOD_STG` 做法只建鍵值、不加
`INCLUDE`——先解決「整張表被掃過好幾遍」這個最大的成本，其餘投影欄位仍會回heap 讀取。

## 本批次不會

- 異動任何來源表既有資料。
- 幫已經有索引的 `dbo.ACNOD_STG` 重複建索引。
- 幫 `dbo.CountryMaster` 補 `CountryCode4` 索引 —— `usp_Souce06_By_FL_FLMST_D_MF` 用
  `TRIM(FLMST_FINAL_RISK_CNTY) = CR.CountryCode4` 關聯，但 `CountryMaster` 只有
  `CountryCode2` 的唯一索引，`CountryCode4` 目前無索引。這張表是全系統共用的國家主檔，
  牽動範圍不只這批 SP，是否加索引、加在哪個欄位組合，需要另外跟其他會查詢
  `CountryMaster` 的功能一起評估，此批次刻意不動。
- 改變 `usp_Souce06_By_FL_FLMST_D_MF` 最後一段「額度檔」UNION 分支的邏輯——那段直接從
  `FM_FMLINE_D_MF` 出發、LEFT JOIN 回 `FL_FLMST_D_MF` 找「查無主檔」的額度，本來就沒有用
  `EXT_DATE` 篩選，會掃過 `FM_FMLINE_D_MF` 全部歷史資料。本批次新增的
  `IX_FM_FMLINE_D_MF_JoinKey` 只能加速它與 `FL_FLMST_D_MF` 的比對，無法縮小它本身要處理
  的資料量；是否要幫這段也限定日期範圍，屬於查詢邏輯調整，需另外確認後再處理。
- 解決 SP 內 `TRIM()` 造成的 non-sargable 問題（`FLMST_FINAL_RISK_CNTY`、
  `FLMST_CURENCY`、多支 SP 的 `COUNTRY_RISK`/`ISSUER_COUNTRY` 等欄位）。這批索引解決的
  是「先把整張表縮小到當天快照」這一步，`TRIM()` 之後的篩選仍是在縮小後的資料上做殘餘
  掃描，影響已大幅降低，但如果要徹底解決仍需搭配持久化計算欄位或資料源頭清理空白，
  這是後續議題。

## 上版前置條件

1. 這 20 張表多為每日轉檔用的來源/中介表，實際資料量未知，索引建置比照既有慣例設定
   `ONLINE = OFF`，執行期間會鎖表，建議於離峰時段、且轉檔排程不會同時執行時進行。
2. 確認執行帳號具備 `CREATE INDEX` 權限，且檔案群組 `NCRMS_IDX` 有足夠可用空間。

## 執行順序

四支腳本互相獨立，可任意順序或分開執行：

1. `Table/Source06_AddJoinIndexes.sql`
2. `Table/Source01_AddLatestSnapshotIndexes.sql`
3. `Table/Source04_AddLatestDateIndex.sql`
4. `Table/Source09_AddLatestDateIndexes.sql`

四支腳本皆在對應索引已存在時立即 `THROW` 停止，可安全重跑判斷是否已執行過；不會嘗試
修改或重建已存在的同名索引。

## 對應程式碼變更

- `FirstBank_SQL/StoredProcedure/usp_Souce06_By_FL_FLMST_D_MF.sql`：CTE 改為 `#TEMP`
  實體化、`UNION` 改 `UNION ALL`、`MAX(FLMST_EXT_DATE)` 移出改用變數（本批次索引與該次
  SP 改寫互補，缺一都跑不出完整效果）。
- 其餘 17 支 `usp_Souce01_*`／`usp_Souce04_*`／`usp_Souce09_*` SP 本身未改動，純粹補索引。

## 驗證與失敗處理

- 建置前後各挑 1～2 支 SP，用同一個 `@EXT_DATE` 搭配
  `SET STATISTICS IO, TIME ON` 執行，比對邏輯讀取次數／耗時是否明顯下降，執行計畫是否
  由 Table/Clustered Index Scan 改為 Index Seek。
- 建置失敗或中斷時可重跑；若索引已建立但特定 SP 效能未如預期改善，回頭檢查該 SP是否有
  額外的 `TRIM()`／`LEFT()`／`SUBSTRING()` 等函式包住篩選欄位，導致索引仍無法被用上。
- 本批次刻意不提供移除索引的回復腳本；如需下版，直接對各索引執行
  `DROP INDEX [索引名稱] ON [對應資料表];` 即可，無資料風險。
