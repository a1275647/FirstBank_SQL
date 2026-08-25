# 2026-08-24 Users／Users_log 使用者名稱欄位長度調整部署紀錄

## 基本資料

| 項目 | 內容 |
|---|---|
| 部署批次 | 2026082401 |
| 正式機候選 commit | 2162c725a5c8270a2eebcd4e1a926e0258c71275 |
| 紀錄確認日期 | 2026-08-25 |
| 正式機申請單號 | 2026H25006 |

## 正式機候選 SQL

| 執行順序 | SQL | SHA-256 |
|---:|---|---|
| 1 | 2026082401/Migration/Users_Alter_UserName_255.sql | 34345c5b5248dd4d7453bae7dbc1c7751404e38a89f7a24731a31a753da0dfaa |
| 2 | 2026082401/Migration/Users_log_Alter_UserName_255.sql | 57646fd43982d79b08c89d58a5674297b7843d21de924d5bfc655b563ba6cc37 |

## 環境部署狀態

| 環境 | 狀態 | 執行日期 | 執行人 | 實際版本／Checksum | 備註 |
|---|---|---|---|---|---|
| 公司測試機 | 已部署（版本待補） | 2026-08-25 | Allen | 待補 | 使用者確認兩份 SQL 均已完成 |
| 甲方測試機 | 已部署（版本待補） | 2026-08-25 | Allen | 待補 | 使用者確認兩份 SQL 均已完成 |
| 甲方正式機 | 已提報未部署 | — | — | 候選版本 2162c72 | 正式機申請單號 2026H25006，待交由 DBA 執行 |

## 正式機執行前確認

- [x] 已建立正式機申請單並填入單號
- [x] 已確認交付 SQL 來自候選 commit
- [x] 已重新計算 SHA-256 並與本文件一致
- [x] 已確認執行順序
- [ ] 已確認 dbo.Users.UserName 為 NOT NULL nvarchar(20)，且尚未加寬為 nvarchar(255)
- [ ] 已確認 dbo.Users_log.UserName 為 NULL nvarchar(20)，且尚未加寬為 nvarchar(255)
- [ ] 已確認正式機 rollback 或異常處理方式
- [ ] 已將 SQL 與本部署紀錄一併交付 DBA

## 正式機執行後確認

- [ ] 已補上實際執行日期與執行人
- [ ] 已補上實際執行的 commit 或交付包 checksum
- [ ] 已確認兩份 SQL 均執行成功
- [ ] 已確認 dbo.Users.UserName 為 NOT NULL nvarchar(255)
- [ ] 已確認 dbo.Users_log.UserName 為 NULL nvarchar(255)
- [ ] 已確認兩欄位 Collation 均為 Chinese_Taiwan_Stroke_CI_AS
- [ ] 已記錄驗證結果與異常處理

## 執行紀錄

| 日期時間 | 環境 | 操作人員 | 動作 | 結果 | 申請單號／備註 |
|---|---|---|---|---|---|
| 2026-08-25 | 公司測試機 | Allen | 執行 2026082401 Migration | 已完成，版本待補 | 使用者確認 |
| 2026-08-25 | 甲方測試機 | Allen | 執行 2026082401 Migration | 已完成，版本待補 | 使用者確認 |
| 2026-08-25 | 甲方正式機 | — | 建立正式機申請單 | 已提報，待部署 | 2026H25006 |

## 備註

- 兩台測試機的實際 commit 與 checksum 尚未取得，不得直接填入正式機候選版本。
- 兩份 SQL 均使用 transaction 與 XACT_ABORT；執行期間發生例外時會 rollback 並重新拋出錯誤。
- SQL 會拒絕重複執行，也會在欄位現況不是預期的 nvarchar(20) 時停止；DBA 不應略過錯誤後繼續執行。
- 正式機完成後，只更新本部署紀錄；不得回頭修改 2026082401 的 Migration SQL。
- 若正式機執行前需要修改 SQL，應建立新的日期批次與新的部署紀錄。
