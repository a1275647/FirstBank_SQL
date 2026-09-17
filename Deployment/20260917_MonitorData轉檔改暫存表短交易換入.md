# 程式變更說明

| 日期 | 版本 | 提交人 | 對應單號 |
|---|---|---|---|
| 2026-09-17 | | | |

## 變更內容

1. 【調整】每日交易資料轉檔（TransferMonitorDataByDay）改為先寫入暫存表、全部完成後再以數秒的短交易一次換入正式表 MonitorData；轉檔進行中的數分鐘，前端查詢 MonitorData（含「今天」日期判定）不再被鎖住逾時。
2. 【修正】原轉檔開頭的清除舊資料語句條件用錯欄位（DATADATE，實際全為空值），從未真正刪除，重跑同一天會累積重複資料；改為由換入程序以轉檔日期整批置換。
3. 【新增】換入程序（usp_MonitorData_Publish）支援只換入指定來源，各單一來源的重跑 API（Source04／05／範本檔／15／16／19+20／11-D／11-O）改為「清暫存 → 寫暫存 → 後置更新 → 只換入該來源」，重跑不再累積重複、也會補齊單位／週次／匯率等欄位。
4. 【新增】重新換入某日期時，該日期仍在簽核中的「交易紀錄註記」表單由系統自動作廢（簽核歷程記 System、說明「交易資料 yyyy-MM-dd 重新匯入，系統自動作廢」），並通知申請人與所有簽核過的人；已結案表單不動。
5. 【新增】整日換入時若暫存表該日期沒有任何資料（上游未產出），拒絕換入並回報錯誤，避免把正式表既有資料清空；單一來源重跑允許 0 筆。
6. 【調整】中國風險加權（usp_UpdateMonitorDataCNWeights）「到期日 92 天內加權 20」的規則限縮為產品別 04、09 才適用，其他產品別一律 100。
7. 【新增】DW 轉檔補上附買回／附賣回交易檔 ARS_SUKBD2_D_MF（原本漏轉，來源 09 該檔每天讀到空表）；訂約日期、到期日在 DW 為文字 yyyyMMdd，轉入時解析為日期，無效值以空值處理。
8. 【調整】轉檔總控（usp_TransferData）補上原本漏列的 usp_Souce06_By_FM_FMLINE_D_MF（額度檔）與 usp_Souce09_By_ARS_SUKBD2_D_MF；Source04 改呼叫 usp_Souce04_By_LS_LSRSA_D_MF（ACNOD_STG 合併已由程式端處理）。
9. 【調整】移除 2 支已不再使用、仍直接寫正式表的舊預存程序（usp_Souce01_OBBS_By_OS_LNSMSTD_D_MF_OS_LNSLMSD_D_MF、usp_Souce04_By_LS_LSRSA_D_MF_ACNOD_STG），避免日後誤用繞過暫存表。

## 異動範圍

| 系統 | 異動項目 |
|---|---|
| 前端 | 無 |
| 後端 | **TransferDataAPI**：`TransferDataController`（轉檔改兩段式、單一來源重跑共用流程、command timeout 10 分鐘）、`DataMigrationByExcelService`（9 處寫入改暫存表、去重比對改「暫存表優先、沒有才看正式表」、新增 ClearStageAsync）、新增 `MonitorDataPublishService`（後置更新 + 呼叫換入程序）、新增 `MonitorDataFormInvalidator`（自動作廢）、`DataMigrationByDwService`（加 ARS_SUKBD2_D_MF）、`OracleDbContext`／`OracleTableMappings`（ARS_SUKBD2_D_MF 對映與日期轉換）、`Program.cs`（DI 註冊）。**FirstBank_API**：新增 `MONITORDATA_STAGE`、`ARS_SUKBD2_D_MF` 實體與 `FirstBankContext` 設定、`MonitorDataMapsterConfig`（MONITORDATA → 暫存表對映） |
| 資料庫 | 新增資料表 `MONITORDATA_STAGE`；`ARS_SUKBD2_D_MF` 建表／補欄位；20 支來源轉檔 SP 與 7 支後置更新 SP 目標表改為暫存表；`usp_TransferData` 改清暫存表（含保留 7 天）並補呼叫清單；新增 `usp_MonitorData_Publish`；`usp_UpdateMonitorDataCNWeights` 規則調整；移除 2 支舊 SP。全部彙整於單一檔 `FirstBank_SQL/2026091602/Deploy_All.sql` |

## 測試結果

| # | 測試項目 | 步驟 | 預期結果 | 結果 |
|---|---|---|---|---|
| 1 | 部署腳本可執行、可重複執行 | 全新資料庫（含正式表、舊版 5 欄 ARS_SUKBD2_D_MF、2 支待刪舊 SP）→ 執行 Deploy_All.sql 兩次 | 兩次皆無錯誤；29 支 SP、暫存表建立，舊表補到 13 欄且既有索引保留，2 支舊 SP 移除 | ✅ |
| 2 | 部署後驗證 | 執行 Verify.sql | 35 項全部 OK（含 27 支 SP 不再直接寫正式表、欄位一致、日期型別） | ✅ |
| 3 | 整日換入 | 正式表有舊資料 5 筆、暫存表新資料 6 筆 → 執行換入 | 刪 5 插 6；其他日期不受影響；小數／根額度／週次欄位完整；主鍵重新配號；暫存表保留 | ✅ |
| 4 | 只換入單一來源（含 FIL9 區分） | 只換 Source11 RiskLineD | RiskLineO 不受影響、RiskLineD 換新 | ✅ |
| 5 | 多來源解析 | `@SOURCES = ' 19, 20 ,19,'` | 空白、重複、尾逗號皆正確解析，刪 2 插 2 | ✅ |
| 6 | 防呆：整日 0 筆拒絕／單來源 0 筆允許／無效來源清單 | 分別執行 | 分別回報錯誤 50004、成功（刪 1 插 0）、錯誤 50001 | ✅ |
| 7 | 防呆：正式表新增欄位、暫存表未同步 | 正式表加欄位後執行換入 | 回報錯誤 50002 並列出欄位名，正式表資料未被動到；暫存表補欄位後不改 SP 即自動帶入 | ✅ |
| 8 | 交易原子性 | 以觸發程序模擬插入失敗 | 例外往上拋、無殘留交易、刪除已回滾 | ✅ |
| 9 | 暫存表清理 | 暫存表放入當日、7 天前、8 天前資料 → 執行 usp_TransferData | 當日與 8 天前清除、剛好 7 天保留 | ✅ |
| 10 | 換入程序權限 | 以只有 EXECUTE 權限、無 MonitorData 權限的帳號執行換入 | 成功（EXECUTE AS OWNER）；同帳號直接刪 MonitorData 被拒 | ✅ |
| 11 | 中國風險加權新規則 | 9 筆邊界資料（排除客戶、04/09 短天期、91／92 天邊界、非 04/09、產品別空值、到期日空值、非 CN、非當日） | 加權依序為 0／20／20／100／100／100／100／不更新／不更新 | ✅ |
| 12 | 三個專案建置 | FirstBank_Entity、FirstBank_Service、TransferDataAPI | 0 錯誤 | ✅ |
| 13 | UAT 完整每日轉檔 | 部署 DB 與程式後執行 TransferMonitorDataByDay | log 出現「MonitorData 發佈完成 … Deleted／Inserted」；轉檔中前端查詢不逾時；正式表當日筆數與暫存表一致 | ⏸ 未執行 |
| 14 | 自動作廢 | 對已有簽核中註記表單的日期重跑轉檔 | 表單作廢、歷程記 System、申請人與簽核人收到「表單作廢通知」 | ⏸ 未執行 |
| 15 | ARS_SUKBD2_D_MF 轉檔 | 執行 OracleTransferSqlServer 後查詢該表當日筆數；Oracle／SqlServer Schema 驗證 API | 筆數 > 0；ARS_SUKBD2_D_MF 為 valid | ⏸ 未執行 |
| 16 | 單一來源重跑 | 任一單一來源 API 重跑昨日 | 該來源資料被置換、其他來源不變、Year/Month/Week 有值 | ⏸ 未執行 |

## 注意事項

- **資料庫腳本與程式必須同一時段部署**：只上 DB，舊程式會把資料寫進暫存表卻不換入，正式表當天沒資料；只上程式，會找不到暫存表。請先於 UAT 完成 #13～#16 再上正式機。
- DBA 執行 `FirstBank_SQL/2026091602/Deploy_All.sql`（先選好資料庫，腳本無 USE），再執行 `Verify.sql` 確認全部 OK；授權需求見同目錄 README（暫存表與 ARS_SUKBD2_D_MF 的 SELECT／INSERT／DELETE、新 SP 的 EXECUTE；換入程序以 EXECUTE AS OWNER 執行，程式帳號不需 MonitorData 的 DELETE 權限）。
- 重新換入某日期會以本次轉檔結果為準，該日期先前的人工「註記」與「鎖定」會歸零，簽核中的註記表單會被系統自動作廢；每日排程只新增新日期不受影響，補跑已處理過的日期前請先評估。
- 中國風險加權規則調整後，非 04／09 產品別且到期 92 天內的中國交易加權由 20 變為 100，下次轉檔起生效，歷史資料不回溯。
- 之前因清除條件錯誤累積的重複資料本次不清理，下次補跑該日期時會被整批置換；正式機 ARS_SUKBD2_D_MF 若既有欄位型別與腳本不同，腳本不會改型別，以 Verify.sql 第 8a 項與 SqlServerSchemaValidation 結果人工處理。
- 本次未涉及四種調借方式（reserve／wind_risk／business／cross_unit）的簽核流程，調借功能不受影響。

## 附件

- `FirstBank_SQL/2026091602/Deploy_All.sql`（DBA 執行）、`Verify.sql`（部署後驗證）、`README.md`（部署順序、授權、回退）
