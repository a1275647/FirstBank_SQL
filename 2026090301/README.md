# 2026090301 Mail 家族 Subject／Mail_Content 欄位加寬

## 目的與範圍

寄信相關的四張表——`dbo.MailLog`（寄信紀錄）、`dbo.Mail`／`Mail_his`／`Mail_temp`
（信件範本主檔/歷程/暫存）——的 `[Subject] nvarchar(200)`／`[Mail_Content] nvarchar(2000)`
太窄，長一點的內容（範本內容、或多筆通知合併成一封信）存檔時會噴
`String or binary data would be truncated`。全部改成跟 `dbo.Notice` 的
`NoticeTitle nvarchar(255)`／`NoticeContent nvarchar(4000)` 對齊：

| 資料表 | 欄位 | 原寬度 | 新寬度 |
|---|---|---|---|
| MailLog | Subject | nvarchar(200) | nvarchar(255) |
| MailLog | Mail_Content | nvarchar(2000) | nvarchar(4000) |
| Mail | Subject | nvarchar(200) | nvarchar(255) |
| Mail | Mail_Content | nvarchar(2000) | nvarchar(4000) |
| Mail_his | Subject | nvarchar(200) | nvarchar(255) |
| Mail_his | Mail_Content | nvarchar(2000) | nvarchar(4000) |
| Mail_temp | Subject | nvarchar(200) | nvarchar(255) |
| Mail_temp | Mail_Content | nvarchar(2000) | nvarchar(4000) |

## 對應程式碼變更

- `FirstBank_API/FirstBank_Entity/Entities/MailLog.cs`、`Mail.cs`、`Mail_his.cs`、
  `Mail_temp.cs`：`Subject`／`Mail_Content` 的 `[StringLength]` 分別改成 255／4000。
- `FirstBank_API/FirstBank_Service/Services/SMTPService.cs`：`SaveMailLogAsync` 寫入
  `MailLog` 前，改用共用的 `.Truncate(255)`／`.Truncate(4000)` extension method截斷
  `Subject`／`Mail_Content`（截斷只影響存進 `MailLog` 的紀錄，實際寄出的 SMTP 信件
  內容不受影響，仍是完整內容）。
- `FirstBank_API/FirstBank_Service/Common/MapsterConfigs/MailMapsterConfig.cs`：
  `TempMailRequireBase -> Mail`／`TempMailRequireBase -> Mail_temp` 的映射補上同樣的
  `.Truncate(255)`／`.Truncate(4000)`（原本完全沒有截斷保護）。
- `FirstBank_SQL/Table/MailLog.sql`、`Mail.sql`、`Mail_his.sql`、`Mail_temp.sql`，以及
  `FirstBank_SQL/2026081801/Deployment/01_DropCreateTables.sql` 內對應的建表定義已同步
  更新寬度，供全新環境部署使用；本批次的 `Migration/Mail_WidenSubjectAndContent.sql`
  則供既有環境就地升級四張表的欄位寬度。

## 本批次不會

- 改動除了 `MailLog`／`Mail`／`Mail_his`／`Mail_temp` 以外，其他同樣带 `Subject`／
  `Content` 欄位但不屬於寄信家族的資料表。

## 上版前置條件

1. 確認執行帳號具備 `ALTER TABLE` 權限。
2. 建議先於 Staging 環境執行，確認寄信功能（尤其站內通知合併寄信、信件範本編輯較長
   內容的場景）正常寫入且不再噴截斷錯誤。

## 執行順序

1. `Migration/Mail_WidenSubjectAndContent.sql`

腳本只在欄位仍是舊寬度時才執行對應的 `ALTER COLUMN`，可安全重跑。

## 驗證與失敗處理

- 執行後查詢 `sys.columns` 確認四張表的 `Subject`／`Mail_Content` 的 `max_length`
  分別為 510／8000（nvarchar 以 byte 計，即 255／4000 字）。
- 執行失敗會整批 `ROLLBACK`；可直接重跑腳本，已成功加寬的欄位會被 `IF EXISTS` 略過。
- 若需回復：對四張表的 `Subject`／`Mail_Content` 分別執行
  `ALTER TABLE [dbo].[資料表] ALTER COLUMN [Subject] nvarchar(200) ...;`／
  `ALTER TABLE [dbo].[資料表] ALTER COLUMN [Mail_Content] nvarchar(2000) ...;`，但需先
  確認既有資料沒有超過舊寬度的內容，否則會失敗。
