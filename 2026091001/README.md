# 2026091001 原始交易紀錄下載：新增選單與功能代碼

## 目的與範圍

為新功能「原始交易紀錄下載」建立左側選單一筆，以及兩個功能代碼：

| FeatureDetail.PK_Id | Feature_Describe | 對應程式碼 |
| --- | --- | --- |
| 123 | DW 資料表下載 | `FeatureType.RawTransactionDwDownload` |
| 124 | 來源原始檔下載 | `FeatureType.RawTransactionSourceFileDownload` |

選單 `RouteName` 為 `raw-transaction-data-download`，`PK_Id` 交給 IDENTITY 配號；
`SystemId`／`ParentId`／`MenuType`／`Icon` 一律沿用既有的
`country-risk-level-amount-report`（國家風險等級餘額趨勢月報）那一筆，
`Seq` 取同層最大值 +1，因此各環境層級結構不同時也能正確掛上。

## 對應程式碼變更

- `FirstBank_Service/Common/Enums/FeatureType.cs`：新增 123／124，
  並補上資料庫早已存在、enum 卻漏宣告的 121（異動通知-信件異動通知）與
  122（異常通知-信件異常通知）。
- `FirstBank_WebAPI/Controllers/RawTransactionData/RawTransactionDataController.cs`
- `FirstBank_Service/Services/RawTransactionData/`、`Common/Catalogs/`
- 前端 `FistBankVue`：`views/Home/Report/RawTransactionDataDownload.vue`、
  `router/index.ts`、`enums/permission.ts`、四語系 `locales/*.json`

## 本批次不會

- **不寫入 `Permissions`。** 權限一律由管理者在系統的「權限設定」頁發放；
  直接以 SQL 寫入會繞過系統自身的權限異動稽核。已確認角色 `Admin`（PK_Id 74）
  握有 `PermissionEdit`(35)，上線後可自行把 123／124 發給需要的角色，
  不會出現「沒人進得去」的死鎖。
- 不調整任何既有選單或功能代碼。

## 上版前置條件

1. `dbo.Menu` 內存在 `RouteName = 'country-risk-level-amount-report'` 的樣板選單，
   否則腳本會 `THROW 50001` 停止。
2. `dbo.FeatureDetail` 的 **PK_Id 123 與 124 尚未被其他功能使用**。
   功能代碼與程式碼的 `FeatureType` enum 是硬綁的（enum 值 = `FeatureDetail.PK_Id`），
   撞號會把權限發到錯誤的功能上，因此腳本偵測到佔用時會 `THROW 50002` 停止，
   **此時不可以自行改用其他號碼**，必須連同 `FeatureType.cs` 一起重新確認。

   > 開發環境（`NCRMS`）查證結果：`FeatureDetail` 最大 PK_Id 為 122，
   > 且 121／122 已被「信件異動通知／信件異常通知」佔用，故本批次使用 123／124。
   > **正式環境請於上版前再確認一次。**

## 執行順序

1. `Data/01_Menu_Feature.sql`

腳本包在單一交易內，且每個步驟都以 `IF NOT EXISTS` 判斷，可安全重跑：
不會產生第二筆選單，前一次只成功一半時重跑會補上缺少的那筆功能代碼。

## 驗證

```sql
SELECT PK_Id, SystemId, ParentId, Name_TN, MenuType, Seq, RouteName, IsActive
FROM dbo.Menu
WHERE RouteName = 'raw-transaction-data-download';

SELECT f.PK_Id, f.MenuId, f.Feature_Describe, f.Seq
FROM dbo.FeatureDetail f
WHERE f.PK_Id IN (123, 124);
```

預期：選單一筆、功能代碼兩筆且 `MenuId` 指向該選單。

## 另需的環境設定：FirstBank API 的 `Config/secrets.ini`

「來源原始檔下載」需要 API 端也能讀到 13 個來源的 FTPS 路徑，
但目前 `Config/secrets.ini` 只有 `[FTPS]`、`[FTPS_HRIS]`、`[FTPS_HRIS_ABSENCE]`
三個區段，**沒有任何 `ExcelSourceXX:Path`**（那些 key 只存在於排程主機的 ini）。
未補齊前，該區塊的清單會把來源標成「尚未設定 FTPS 路徑」而無法勾選（DW 半邊不受影響）。

請把排程主機 ini 內對應的值複製到 API 的 `Config/secrets.ini`（值請沿用該環境現有設定）：

```ini
[ExcelSource04]
Path=

[FTPS_ExcelSource05]
Path=

[ExcelSource10]
Path=

[ExcelSource11]
RiskLineD_Path=
RiskLineO_Path=

[ExcelSource12]
Path=

[ExcelSource13]
Path=

[ExcelSource14]
Path=

[ExcelSource15]
Path=

[ExcelSource16]
Path=

[ExcelSource18]
Path=

[TxtSource19]
Path=

[TxtSource20]
Path=
```

## 失敗處理與回復

執行失敗會自動 `ROLLBACK`，資料維持原狀，排查後可直接重跑。

需要移除本批次的異動時（**務必先確認沒有任何角色已被授予 123／124**，
否則會違反 `FK_Permissions_FeatureDetail`）：

```sql
BEGIN TRANSACTION;

DECLARE @MenuId int = (SELECT PK_Id FROM dbo.Menu WHERE RouteName = 'raw-transaction-data-download');

DELETE FROM dbo.Permissions   WHERE FK_Feature_Id IN (123, 124);
DELETE FROM dbo.FeatureDetail WHERE PK_Id IN (123, 124);
DELETE FROM dbo.Menu          WHERE PK_Id = @MenuId;

COMMIT TRANSACTION;
```
