# 2026082102 角色異動紀錄查詢索引修正

## 目的與範圍

新增 6 個非叢集索引，修正角色異動紀錄查詢頁（`/NCRMS/home/role-change/history`，
`PermissionService.GetRoleHistoryInfo`）反應的查詢效能不佳、疑似阻塞問題：

- `dbo.Role_his`：`IX_Role_his_UnitCode_SysCreateDate`（`FK_Unit_Code, SysCreateDate`）、
  `IX_Role_his_SysCreateDate`（`SysCreateDate`）
- `dbo.Role_User_Mapping_his`：`IX_Role_User_Mapping_his_LogRoleId`（`log_Role_Id`）
- `dbo.Role_Position_Mapping_his`：`IX_Role_Position_Mapping_his_LogRoleId`（`log_Role_Id`）
- `dbo.Permissions_his`：`IX_Permissions_his_LogRoleId`（`log_Role_Id`）
- `dbo.Permissions_Query_his`：`IX_Permissions_Query_his_LogRoleId`（`log_Role_Id`）

根因：`Role_his` 及其 4 張子歷程表過去只有 `log_Id` 叢集主鍵，完全沒有非叢集索引。但
`GetRoleHistoryInfo` 用 `FK_Unit_Code`（單位篩選）、`SysCreateDate`（區間篩選＋預設排序）
做 `WHERE`，並用 4 張子表的 `log_Role_Id` 做相關子查詢（`RoleHisQueryType` 分類判斷、
`TotalNumber` 計數、明細清單投影）。缺乏索引時每次查詢都是 `Role_his` 的 Clustered Index
Scan，疊加 4 張子表逐列全表掃描；加上 `Extension.IQueryable.ToPagedResponseAsync` 會對同一
查詢執行兩次（`CountAsync()` 一次、`Skip/Take/ToListAsync()` 再一次），在資料量成長、或
同時間有新的角色異動寫入 `Role_his`／子表時，長時間持有共享鎖的掃描容易與寫入交易互相等待，
造成使用者感受到的查詢卡住／阻塞。

搭配本批次索引，`PermissionService.cs` 的 `RoleHisQueryType` 篩選也同步把
`x.role_Permissions_his.Count == 0` 這類寫法改成 `!x.role_Permissions_his.Any()`，讓 EF
翻譯成 `NOT EXISTS`，才能真正吃到新增的 `log_Role_Id` 索引（相關子查詢的 `Count()` 聚合寫法
即使有索引，優化器也不一定會選擇 Index Seek + 反半連接的執行計畫）。

本批次不會：

- 異動 `Role_his` 或其子表既有資料。
- 修改前端程式碼或 API 契約。
- 更動 `Include`/`AsSplitQuery` 結構、分頁機制本身。

## 上版前置條件

1. 這 5 張表皆為歷程稽核表，預期資料量遠小於 `MONITORDATA`，但索引建置仍設定
   `ONLINE = OFF`（比照既有慣例），執行期間會短暫鎖表，建議於離峰執行。
2. 確認執行帳號具備 `CREATE INDEX` 權限，且檔案群組 `NCRMS_IDX` 有足夠可用空間。

## 執行順序

1. `Table/Role_his_AddHistoryQueryIndex.sql`
2. `Table/RoleHisChildTables_AddLogRoleIdIndex.sql`

兩支腳本皆在索引已存在時立即 `THROW` 停止，可安全重跑判斷是否已執行過；不會嘗試修改或
重建已存在的同名索引。

## 對應程式碼變更

- `FirstBank_API/FirstBank_Service/Services/PermissionService.cs`
  `GetRoleHistoryInfo` 內 `RoleHisQueryType` 篩選由 `Count == 0` 改為 `!Any()`。

## 驗證與失敗處理

- 執行後對 `GET /Permission/role/history/info`（可分別用一般單位帳號與風管帳號測試，
  對應不同篩選路徑）查詢一次，比對執行計畫是否由 Clustered Index Scan 改為 Index Seek，
  並確認回應時間明顯縮短。
- 建置失敗或中斷時可重跑；若索引已存在但效能未如預期改善，需回頭檢查角色名稱模糊查詢
  （`RoleName_TN/CN/EN/JP` 四欄 `OR StartsWith`）是否成為新的瓶頸，評估是否需要額外索引
  或限制查詢欄位。
- 本批次刻意不提供移除索引的回復腳本；如需下版，直接對各索引執行
  `DROP INDEX [索引名稱] ON [對應資料表];` 即可，無資料風險。
