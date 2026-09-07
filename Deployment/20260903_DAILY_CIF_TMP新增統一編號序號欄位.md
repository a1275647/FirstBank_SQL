# 2026-09-03 DAILY_CIF_TMP 新增統一編號序號欄位（CIF_ID_SER_NO）部署紀錄

## 基本資料

| 項目 | 內容 |
|---|---|
| 部署批次 | 2026090302 |
| 正式機候選 commit | 1572d4349a6bfd2ca3008a8208d152029162661d |
| 紀錄確認日期 | 2026-09-07 |
| 正式機申請單號 | 2026I04004 |

## 正式機候選 SQL

| 執行順序 | SQL | SHA-256 |
|---:|---|---|
| 1 | 2026090302/Migration/DAILY_CIF_TMP_AddCifIdSerNo.sql | ed8b3b31af7aa65ba8f9d5b06e64d35027468e116d352cb38e33d7549924b657 |

> `dbo.DAILY_CIF_TMP` 新增 `CIF_ID_SER_NO nvarchar(1)`，對應 Oracle
> `DTCIF.DAILY_CIF_TMP.CIF_ID_SER_NO CHAR(1)`（統一編號序號），供
> `DataMigrationByDwService.MigrateAllAsync` 一併同步帶入；全新環境改由
> `Table/DAILY_CIF_TMP.sql` 與 `2026081801/Deployment/01_DropCreateTables.sql`
> 直接建出含新欄位的表，詳見 `2026090302/README.md`。

## 環境部署狀態

| 環境 | 狀態 | 執行日期 | 執行人 | 實際版本／Checksum | 備註 |
|---|---|---|---|---|---|
| 公司測試機 | 待補 | 待補 | 待補 | 待補 | 尚未取得確認資訊 |
| 甲方測試機 | 待補 | 待補 | 待補 | 待補 | 尚未取得確認資訊 |
| 甲方正式機 | 已部署 | 2026-09-04 | 待補 | 與候選 commit 一致（1572d4349a6bfd2ca3008a8208d152029162661d） | 使用者於 2026-09-07 確認已上線且驗證完成 |

## 正式機執行前確認

- [x] 已建立正式機申請單並填入單號（2026I04004）
- [x] 已確認交付 SQL 來自候選 commit
- [x] 已重新計算 SHA-256 並與本文件一致
- [ ] 已確認正式機執行帳號具備 `ALTER TABLE`／`sp_addextendedproperty` 權限
- [x] 已確認 rollback 或異常處理方式（腳本以 transaction 包裹，失敗會整批 rollback；
      欄位已存在時會 `THROW` 停止，可安全重跑判斷是否已執行過）

## 正式機執行後確認

- [ ] 已補上實際執行人
- [x] 已確認實際執行的 commit 與候選 commit 一致
- [x] 已確認 `dbo.DAILY_CIF_TMP` 已新增 `CIF_ID_SER_NO` 欄位
- [x] 已記錄驗證結果
- [ ] 已記錄異常處理（如有）

## 執行紀錄

| 日期時間 | 環境 | 操作人員 | 動作 | 結果 | 申請單號／備註 |
|---|---|---|---|---|---|
| 2026-09-04 | 甲方正式機 | 待補 | 執行 2026090302 Migration | 已部署 | 申請單號 2026I04004 |
| 2026-09-07 | 甲方正式機 | 待補 | 確認正式機驗證結果 | 驗證完成 | 使用者確認；`dbo.DAILY_CIF_TMP.CIF_ID_SER_NO` 型別符合預期 |

## 備註

- 2026090302 批次為 `dbo.DAILY_CIF_TMP` 新增 `CIF_ID_SER_NO`（統一編號序號）欄位，
  讓 DW 每日同步能把 Oracle 端對應欄位帶過來；詳見 `2026090302/README.md`。
- 腳本使用 transaction 與 `XACT_ABORT`，欄位已存在時會 `THROW` 停止並回報，可安全重跑
  判斷是否已執行過；本批次未附移除欄位的回復腳本，如需下版需另外執行
  `ALTER TABLE [dbo].[DAILY_CIF_TMP] DROP COLUMN [CIF_ID_SER_NO];` 並同步移除對應程式碼。
- 正式機已於 2026-09-04（上週五）上線，並於 2026-09-07 確認驗證通過；實際執行人、
  兩台測試機的執行狀態與 checksum 仍待補，取得後應以獨立 commit 補上，不回頭覆寫本次記錄。
- 正式機完成後，只更新本部署紀錄；不得回頭修改 2026090302 的 SQL。
- 若正式機執行前需要修改 SQL，應建立新的日期批次與新的部署紀錄。
