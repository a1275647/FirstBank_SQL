# 2026-08-28 DW 資料表結構修正（EL_ELLSTAPV_D_MF／DAILY_CIF_TMP／FL_FLMST_D_MF／FM_FMLINE_D_MF）部署紀錄

## 基本資料

| 項目 | 內容 |
|---|---|
| 部署批次 | 2026082701、2026082702、2026082703 |
| 正式機候選 commit | 44617c6b08173363108bf12b5c5e732e6955fdc4 |
| 紀錄確認日期 | 2026-08-31 |
| 正式機申請單號 | 2026H27019 |

## 正式機候選 SQL

| 執行順序 | SQL | SHA-256 |
|---:|---|---|
| 1 | 2026082701/Migration/EL_ELLSTAPV_D_MF_AddExtDate.sql | 5f5991d78d95e354232323f40fcc7af54044ac2aa9a5c195cf8da15005711acc |
| 2 | 2026082702/Migration/DAILY_CIF_TMP_DropCIFIdNoPK.sql | 1d47c8217985eedd884a78bb5d1440acd0fe397835ae401ccc5ad49065880933 |
| 3 | 2026082703/Migration/FL_FLMST_D_MF_FM_FMLINE_D_MF_AddMissingColumns.sql | e5f4bad2786b492aa250e95c6ff289ecbf88b32bc96b12f964db1b80a842eb96 |

> 三批彼此獨立，無先後相依關係，執行順序僅依批次編號排列。

## 環境部署狀態

| 環境 | 狀態 | 執行日期 | 執行人 | 實際版本／Checksum | 備註 |
|---|---|---|---|---|---|
| 公司測試機 | 待執行 | — | — | — | 使用者於 2026-08-31 確認尚未執行 |
| 甲方測試機 | 待執行 | — | — | — | 使用者於 2026-08-31 確認尚未執行 |
| 甲方正式機 | 已部署（版本待補） | 待補 | 待補 | 待補 | 使用者於 2026-08-31 確認已部署；實際執行資訊待補 |

## 正式機執行前確認

- [x] 已建立正式機申請單並填入單號
- [x] 已確認交付 SQL 來自候選 commit
- [x] 已重新計算 SHA-256 並與本文件一致
- [ ] 已確認三批可獨立執行，無先後相依順序
- [ ] 已確認正式機 dbo.EL_ELLSTAPV_D_MF 尚未存在 ELLSTAPV_EXT_DATE 欄位
- [ ] 已確認正式機 dbo.DAILY_CIF_TMP 仍存在 PK_DAILY_CIF_TMP 主鍵
- [ ] 已確認正式機 dbo.FL_FLMST_D_MF／dbo.FM_FMLINE_D_MF 缺少腳本內列出的欄位
- [ ] 已確認正式機 rollback 或異常處理方式（2026082703 未使用 transaction，需另行確認回復方式）
- [ ] 已將 SQL 與本部署紀錄一併交付 DBA

## 正式機執行後確認

- [ ] 已補上實際執行日期與執行人
- [ ] 已補上實際執行的 commit 或交付包 checksum
- [ ] 已確認三份 SQL 均執行成功
- [ ] 已確認 dbo.EL_ELLSTAPV_D_MF.ELLSTAPV_EXT_DATE 已存在且型別為 date
- [ ] 已確認 dbo.DAILY_CIF_TMP 已無 PK_DAILY_CIF_TMP
- [ ] 已確認 dbo.FL_FLMST_D_MF／dbo.FM_FMLINE_D_MF 缺少欄位均已補齊
- [ ] 已記錄驗證結果與異常處理

## 執行紀錄

| 日期時間 | 環境 | 操作人員 | 動作 | 結果 | 申請單號／備註 |
|---|---|---|---|---|---|
| 2026-08-31 | 甲方正式機 | — | 建立正式機申請單 | 已提報，待核准 | 2026H27019 |
| 2026-08-31 | 甲方正式機 | 待補 | 確認正式機部署狀態 | 已部署，版本待補 | 使用者確認；申請單號 2026H27019 |
| 2026-08-31 | 公司測試機／甲方測試機 | — | 確認測試機執行狀態 | 尚未執行 | 使用者確認 |

## 備註

- 2026082701（EL_ELLSTAPV_D_MF 新增 ELLSTAPV_EXT_DATE）、2026082702（DAILY_CIF_TMP 移除誤設主鍵）、2026082703（FL_FLMST_D_MF／FM_FMLINE_D_MF 補齊缺欄位）為三批各自獨立的 DW 表 schema 修正，彼此無相依關係。
- 2026082701、2026082702 使用 transaction 與 XACT_ABORT，執行期間發生例外時會 rollback 並重新拋出錯誤；2026082703 逐欄以 IF NOT EXISTS 判斷是否需要新增，未使用 transaction 包裹，可安全重跑但無整批 rollback 機制。
- 兩台測試機於 2026-08-31 確認尚未執行；正式機已先行部署完成，實際執行資訊仍待補。
- 兩台測試機與正式機的實際 commit、checksum、執行資訊尚未取得，不得直接填入正式機候選版本。
- 正式機完成後，只更新本部署紀錄；不得回頭修改 2026082701、2026082702、2026082703 的 SQL。
- 若正式機執行前需要修改 SQL，應建立新的日期批次與新的部署紀錄。
