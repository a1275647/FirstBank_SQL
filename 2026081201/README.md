# 2026081201 國家信用評等資料表切換

## 目的與範圍

本批次建立下列資料庫結構，供後續 `CreditRatings` 程式切換使用：

- `CreditRating_Country_Log`：取代 `CreditRating_Country_M`，保留每日國家分數歷程。
- `CreditRating_Country_Log_Detail`：取代 `CreditRating_Country`，保留各信評公司原始結果歷程。
- `CreditRating_Country_Current`：保存各「信評公司＋國家」最近一次成功發布的資料，匯入失敗時不清空，也不退回較舊資料。
- `CountryMaster.CreditRatingScore` 與 `CountryMaster.CreditRatingScoreDate`：保存最近一次成功發布的國家分數及其業務日期。

本批次不會：

- 刪除或重新命名舊表 `CreditRating_Country_M`、`CreditRating_Country`。
- 修改 `ufn_table_GetCountryRating`。
- 將歷史資料回填到 `CreditRating_Country_Current` 或 `CountryMaster` 新欄位。
- 切換 `FirstBank_API` 的讀取來源；該專案仍可繼續讀舊表。

## 上版前置條件

1. 停止會寫入 `CreditRating_Country_M`、`CreditRating_Country` 的排程，並確認沒有執行中的匯入交易。
2. 先備份資料庫，並確認執行帳號具備建立資料表、修改資料表、指定識別欄位值及校正識別值的權限，對應 SQL Server 權限或操作為 `CREATE TABLE`、`ALTER TABLE`、`IDENTITY_INSERT` 與 `DBCC CHECKIDENT`。
3. 確認另一項工作中的 `ufn_table_GetCountryRating` 應用程式端改寫已完成，且新版 `CreditRatings` 的最終介面與本批次欄位一致。
4. 首次建立 `CreditRating_Country_Current` 與 `CountryMaster` 分數所需的成功條件，由需求負責人決定；本批次 SQL 不代替程式端進行此項業務判定。
5. 建議先在與正式環境資料庫結構及資料量相同的環境演練，尤其要確認歷史資料搬移的主檔與明細配對檢核能夠通過。

## 執行順序

請依下列順序逐檔執行，不要整個資料夾平行執行：

1. `Table/CountryMaster_AddCreditRatingScore.sql`
2. `Table/CreditRating_Country_Log.sql`
3. `Table/CreditRating_Country_Log_Detail.sql`
4. `Table/CreditRating_Country_Current.sql`
5. `Migration/CreditRating_Country_HistoryMigration.sql`
6. `Validation/CreditRating_Country_MigrationValidation.sql`

三張新資料表的結構建立腳本會在物件已存在時檢查其結構，結構不符時立即停止。`CountryMaster` 欄位腳本只會新增缺少的可為空值欄位；若同名欄位已存在但型別不符，也會立即停止。歷史資料搬移腳本會保留舊表的 `PK_Id`，以單一交易搬移尚未寫入的資料，並可在既有資料內容一致的前提下安全重跑。

## 歷史資料搬移與配對規則

- `CreditRating_Country_M` 全部搬入 `CreditRating_Country_Log`，保留 `PK_Id`。
- `CreditRating_Country` 全部搬入 `CreditRating_Country_Log_Detail`，保留 `PK_Id`。
- 明細資料以 `FK_Country_Id = FK_CountryId` 且 `date = CONVERT(date, Create_date)` 的條件尋找歷程主檔。
- 每筆舊明細必須且只能找到一筆舊主檔；同一主檔與同一信評公司也只能有一筆明細。任一條件不成立時，搬移腳本會在寫入前停止，不會自行推測資料關聯。

## 初始化與後續發布

執行本批次後：

- `CreditRating_Country_Current` 保持空表。
- `CountryMaster.CreditRatingScore`、`CreditRatingScoreDate` 保持 `NULL`。
- 新版 `CreditRatings` 上版後，由需求負責人安排一次完整匯入，建立第一版 `CreditRating_Country_Current` 與 `CountryMaster` 分數。
- 後續只有成功發布的匯入可以更新 `CreditRating_Country_Current` 與 `CountryMaster`；匯入失敗或三家公司皆無有效資料時，不得清空既有的最近成功資料。
- 歷史資料回補不得使 `CreditRating_Country_Current.date` 退回較舊日期。上述發布規則屬於應用程式端的交易邏輯，不由本批次 SQL 自動執行。

## 驗證與失敗處理

- 第 6 步成功時會輸出來源資料筆數、已搬移筆數，以及 `CreditRating_Country_Current` 和 `CountryMaster` 的初始化筆數。
- 驗證腳本預設使用 `@ExpectUninitialized = 1`；首次上版後、第一次執行新版匯入前請維持此值。
- 若建表步驟中斷，排除錯誤後可從第 1 步依序重跑。
- 歷史資料搬移使用單一交易；失敗時該次搬移會回復至執行前狀態。錯誤原因釐清前，不要手動略過檢核或刪除舊資料。
- 本批次刻意不提供刪除新物件的回復腳本。舊表仍會保留；若新版程式尚未發布，可繼續使用既有流程。若新版程式已發布，應先停止排程，再依應用程式版本回復計畫處理。
