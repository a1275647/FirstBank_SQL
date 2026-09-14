# 2026091401 系統日誌下載角色權限

## 目的

為「系統日誌下載」建立一般角色權限架構所需的選單與功能資料：

| 資料 | 值 |
| --- | --- |
| `Menu.RouteName` | `log-download` |
| `Menu.Name_TN` | 系統日誌下載 |
| `FeatureDetail.PK_Id` | `125` |
| `FeatureDetail.Feature_Describe` | 系統日誌下載 |
| 後端 enum | `FeatureType.LogDownload` |

選單沿用「報表管理」下既有月報的層級、類型與圖示，並排在同層最後一筆。四個語系名稱欄位都填入繁體中文，維持本功能已確認的固定繁中顯示。

## 權限發放

部署腳本不新增 `Permissions`。部署完成後，由管理員在既有「權限設定」畫面將「系統日誌下載」授予需要的角色，保留系統原有的權限異動稽核流程。

沒有取得功能代碼 `125` 的使用者不會收到此選單，直接呼叫 Preview 或 Download API 也會由 `RequireFunction` 回傳既有 `403A` 權限錯誤。

`Login:SkipLdapUsers` 只保留給 Production 登入流程的 LDAP 略過判斷，不參與本功能授權。

## 執行順序

1. 部署後端與前端功能。
2. 執行 `Data/01_LogDownload_Menu_Feature.sql`。
3. 由管理員透過權限設定將功能授予指定角色。

## 驗證

```sql
SELECT PK_Id, SystemId, ParentId, Name_TN, MenuType, Seq, RouteName, IsActive
FROM dbo.Menu
WHERE RouteName = 'log-download';

SELECT PK_Id, MenuId, Feature_Describe, Seq
FROM dbo.FeatureDetail
WHERE PK_Id = 125;

SELECT FK_Role_Id, FK_Feature_Id
FROM dbo.Permissions
WHERE FK_Feature_Id = 125;
```

執行腳本後，前兩段各應有一筆；第三段只有管理員實際發放角色權限後才會有資料。
