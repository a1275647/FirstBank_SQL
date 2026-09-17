# 2026091602 MonitorData 每日轉檔改為「暫存表 + 短交易換入」

## 目的

`TransferMonitorDataByDay` 每日轉檔約需 5 分鐘，現況整段包在一個交易內直接寫 `MONITORDATA`，
寫入筆數多到觸發 lock escalation 變成整表 X lock，期間前端所有查 MonitorData 的頁面
（含取最新日期的 `MAX(EXT_DATE)`）全部被擋到逾時。RCSI 不開放使用，因此改為：

```text
Phase 1（數分鐘，不鎖正式表）
  usp_TransferData → 各 usp_Souce* 寫入 MONITORDATA_STAGE
  C# 各來源（04/05/10~18/15/16/19/20/11）寫入 MONITORDATA_STAGE
  usp_TransferAfterUpdateMonitorData → 各 usp_UpdateMonitorData* 更新 MONITORDATA_STAGE

Phase 2（數秒）
  usp_MonitorData_Publish @EXT_DATE：短交易 DELETE 正式表當日 → INSERT…SELECT 自暫存表
```

正式表只在 Phase 2 的幾秒被鎖。

順帶修正：原 `usp_TransferData` 的 `DELETE MONITORDATA WHERE DATADATE = @EXT_DATE`
（`DATADATE` 全表為 NULL，等於從未刪除，重跑會累積重複列）——新流程改由 Publish 以 `EXT_DATE` 換入。

## 內容

| 檔案 | 說明 |
| --- | --- |
| `Deploy_All.sql` | **DBA 只需執行這一個檔**。依序包含下方所有物件，可重複執行（`IF NOT EXISTS` / `CREATE OR ALTER`） |
| `01_Table/ARS_SUKBD2_D_MF.sql` | DW 附買回／附賣回交易檔落地表：不存在就建；**已存在則逐欄補齊缺少的欄位**（正式機此表先前為手動建立、欄位不明），含 `IX_ARS_SUKBD2_D_MF_ExtDate`（已建者略過）。見下方「ARS_SUKBD2_D_MF」 |
| `01_Table/MONITORDATA_STAGE.sql` | 新增暫存表（欄位同 `MONITORDATA`，含 `PK_ID IDENTITY`），只建 `(EXT_DATE, SOURCE)` 索引；建完立即比對欄位，缺任何正式表欄位就 `THROW` |
| `02_StoredProcedure/01~20_usp_Souce*.sql` | 20 支來源轉檔 SP：`INSERT INTO MonitorData` → `MONITORDATA_STAGE`，其餘邏輯不變 |
| `02_StoredProcedure/21~27_usp_UpdateMonitorData*.sql` | 7 支後置更新 SP：目標表改 `MONITORDATA_STAGE`，其餘邏輯不變 |
| `02_StoredProcedure/28_usp_TransferData.sql` | 開頭改為清暫存表（本次日期 + 超過 `@RetentionDays`（預設 7）天的舊資料）；Source04 改呼叫 `usp_Souce04_By_LS_LSRSA_D_MF`，補上原本漏列的 `usp_Souce06_By_FM_FMLINE_D_MF`（額度檔，排最後）與 `usp_Souce09_By_ARS_SUKBD2_D_MF` |
| `02_StoredProcedure/29_usp_MonitorData_Publish.sql` | **新 SP**，見下方說明 |
| `03_Drop/Drop_Unused_Source_Procedures.sql` | 移除 2 支已不被呼叫、仍直接寫正式表的舊 SP（見「一併移除的舊 SP」），避免日後誤用 |
| `Verify.sql` | 部署後驗證（唯讀） |

原始碼（單一來源）已同步更新於 `Table/MONITORDATA_STAGE.sql`、`StoredProcedure/*.sql`；
本資料夾內的 SP 檔是由原始碼產生，統一轉為 UTF-8 與 `CREATE OR ALTER`。

### usp_MonitorData_Publish

```sql
EXEC usp_MonitorData_Publish @EXT_DATE = '2026-09-15';                      -- 換入該日期全部來源
EXEC usp_MonitorData_Publish @EXT_DATE = '2026-09-15', @SOURCES = '19,20';   -- 只換 Source 19、20
EXEC usp_MonitorData_Publish @EXT_DATE = '2026-09-15', @SOURCES = '11', @FIL9 = N'RiskLineD手工檔';
```

- 欄位清單由 `sys.columns` 動態取兩表共有且非 IDENTITY 的欄位，正式表日後加欄位時只要暫存表同步加了，SP 不必改；暫存表漏加會直接報錯。
- `@SOURCES` 逗號字串於 SP 內以迴圈拆解，不依賴 `STRING_SPLIT`。
- 回傳一列 `DeletedCount, InsertedCount`，由 TransferDataAPI 記入 log。
- **整日發佈**（未給 `@SOURCES`／`@FIL9`）時若暫存表該日期一筆都沒有，`THROW 50004` 拒絕發佈，避免上游沒產出資料卻把正式表既有的那一天清空；限定來源的單跑允許 0 筆。
- **不檢查**該日期是否已有 `Mark`／`Lock` 或簽核中資料；重新換入以暫存表為準（`Mark`／`Lock` 歸零）。
  簽核中的 MonitorData 註記表單由 TransferDataAPI 在呼叫前自動作廢並通知（已與業務確認）。

## 執行順序（UAT 與正式機相同）

1. 離峰時段，**確認當時沒有轉檔排程在跑**。
2. 執行 `Deploy_All.sql`（單一批次，約數秒）。
3. 執行 `Verify.sql`，每段 Result 應為 `OK`。
4. 授權：TransferDataAPI 使用的 DB 帳號需要
   - `MONITORDATA_STAGE`：`SELECT, INSERT, DELETE`（C# 直接 BulkInsert 與去重查詢）
   - `ARS_SUKBD2_D_MF`：`SELECT, INSERT, DELETE`（同其他 DW 落地表，若原本以角色授權則不用另給）
   - `usp_MonitorData_Publish`、`usp_TransferData`：`EXECUTE`（若原本以角色授權 EXECUTE 給全部 SP 則不用另給）
   - `usp_MonitorData_Publish` 宣告 `WITH EXECUTE AS OWNER`：它的 DELETE／INSERT 是動態 SQL，不適用擁有權鏈，
     改以 dbo 身分執行，程式帳號**不需要** `MONITORDATA` 的 DELETE 權限。若貴行政策不允許 `EXECUTE AS OWNER`，
     請移除該子句並改 `GRANT SELECT, INSERT, DELETE ON dbo.MONITORDATA` 與 `GRANT SELECT ON dbo.MONITORDATA_STAGE` 給程式帳號。
   - `MONITORDATA_temp`、`FlowForm`、`FlowRecord`、`Notice`、`NoticeUser`：既有權限即可（自動作廢用）
5. **同一時段部署新版 TransferDataAPI**（含 FirstBank_Service / FirstBank_Entity）。
   DB 與程式必須一起上：只上 DB 的話舊程式會把資料寫進暫存表卻不換入，正式表當天沒資料；
   只上程式的話會找不到 `MONITORDATA_STAGE`。
6. 手動跑一次 `POST /api/TransferData/TransferMonitorDataByDay?date=<昨日>`，觀察：
   - log 有 `Publish 完成 … Deleted=… Inserted=…`
   - 轉檔進行中前端可正常查詢 MonitorData（不再逾時）
   - `SELECT COUNT(*) FROM MONITORDATA WHERE EXT_DATE = <昨日>` 與 `MONITORDATA_STAGE` 同日期筆數一致

## ARS_SUKBD2_D_MF（DW 轉檔補漏）

`DataMigrationByDwService.MigrateAllAsync` 原本漏了 `DTARS.ARS_SUKBD2_D_MF`，SQL Server 端此表沒人餵資料，
`usp_Souce09_By_ARS_SUKBD2_D_MF` 每天讀到的都是空表。本批次補上 Entity、Oracle 對映與轉檔呼叫，並提供落地表腳本。

只保留 SP 用到的欄位（Entity `FirstBank_Entity/DWEntity/ARS_SUKBD2_D_MF.cs`）：

| 欄位 | 型別 | Oracle 來源型別 |
| --- | --- | --- |
| SUKBD2_BRANCH_NO | nvarchar(3) | CHAR(3) |
| SUKBD2_TRADE_NO | nvarchar(20) | CHAR(20) |
| SUKBD2_TRADE_TYPE | nvarchar(2) | CHAR(2) |
| SUKBD2_TRADE_DAY | **date** | CHAR(8) yyyyMMdd，轉檔時解析（無效值 → NULL） |
| SUKBD2_END_DATE | **date** | CHAR(8) yyyyMMdd，同上 |
| SUKBD2_REPO_CCY | nvarchar(3) | CHAR(3) |
| SUKBD2_REPO_AMOUNT | decimal(17,2) | NUMBER(17,2) |
| SUKBD2_ISSUER_ID | nvarchar(40) | CHAR(40) |
| SUKBD2_ISSUER_APPID | nvarchar(11) | CHAR(11) |
| SUKBD2_ISSUER_COUNTRY | nvarchar(2) | CHAR(2) |
| SUKBD2_EXT_DATE | date | DATE |
| Create_date / Create_user | datetime / nvarchar(20) | — |

正式機既有表若欄位型別與上表不同（例如日期欄位建成 nvarchar），腳本不會改型別；`Verify.sql` 第 8a 項會 FAIL，
請人工調整後再部署程式。部署後跑 `GET /api/TransferData/OracleSchemaValidation`／`SqlServerSchemaValidation`，
`ARS_SUKBD2_D_MF` 應為 valid；跑一次 `POST /api/TransferData/OracleTransferSqlServer?date=<昨日>` 後
`SELECT COUNT(*) FROM ARS_SUKBD2_D_MF WHERE SUKBD2_EXT_DATE = <昨日>` 應 > 0。

## 回退

程式回退到前一版即可（前一版直接寫 `MONITORDATA`，不需要暫存表）；
SP 需一併回退到 2026091601 之前的版本（`INSERT INTO MonitorData`）。暫存表可留著不影響。

## 本批次不會

- 不清理既有重複列（之前 `DATADATE` 問題累積的），另案處理。
- 不移除 `DATADATE` 欄位。
- 不改 `usp_TransferAfterUpdateMonitorData`（本身不碰資料表，只呼叫 7 支更新 SP）。

## 一併移除的舊 SP

以下 2 支已不被 `usp_TransferData` 呼叫、且仍直接寫正式表 `MONITORDATA`，由 `03_Drop` 移除並自原始碼刪除，避免日後誤呼叫繞過暫存表：

| SP | 原因 |
| --- | --- |
| `usp_Souce01_OBBS_By_OS_LNSMSTD_D_MF_OS_LNSLMSD_D_MF` | 已拆成 `…LNSMSTD_D_MF`／`…LNSLMSD_D_MF` 兩支 |
| `usp_Souce04_By_LS_LSRSA_D_MF_ACNOD_STG` | ACNOD_STG 合併改由 C# 端處理，`usp_TransferData` 改呼叫 `usp_Souce04_By_LS_LSRSA_D_MF` |
