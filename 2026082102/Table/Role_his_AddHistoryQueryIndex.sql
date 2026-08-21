SET NOCOUNT ON;
SET XACT_ABORT ON;

IF OBJECT_ID(N'[dbo].[Role_his]', N'U') IS NULL
    THROW 51500, N'缺少資料表 dbo.Role_his。', 1;

IF EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE [object_id] = OBJECT_ID(N'[dbo].[Role_his]')
      AND [name] IN (N'IX_Role_his_UnitCode_SysCreateDate', N'IX_Role_his_SysCreateDate')
)
    THROW 51501, N'dbo.Role_his 已存在 IX_Role_his_UnitCode_SysCreateDate 或 IX_Role_his_SysCreateDate，請先確認是否已執行過本腳本。', 1;

-- 角色異動紀錄查詢頁（PermissionService.GetRoleHistoryInfo）以 FK_Unit_Code（一般人員只能查
-- 自己管理單位）過濾，並以 SysCreateDate 做區間篩選與預設排序，但 Role_his 只有 log_Id 叢集
-- 主鍵，完全沒有非叢集索引，導致每次查詢都是 Clustered Index Scan。
-- 一般使用者查詢會先用 FK_Unit_Code 縮小範圍，故建立 (FK_Unit_Code, SysCreateDate) 複合索引；
-- 風管單位可查全部角色（不吃 FK_Unit_Code 過濾），故另外建立單欄 (SysCreateDate) 索引，涵蓋
-- 純日期區間查詢與預設排序。
BEGIN TRY
    BEGIN TRANSACTION;

    CREATE NONCLUSTERED INDEX [IX_Role_his_UnitCode_SysCreateDate] ON [dbo].[Role_his]
    (
        [FK_Unit_Code] ASC,
        [SysCreateDate] ASC
    )
    INCLUDE
    (
        [SysCreateUser]
    )
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX];

    CREATE NONCLUSTERED INDEX [IX_Role_his_SysCreateDate] ON [dbo].[Role_his]
    (
        [SysCreateDate] ASC
    )
    INCLUDE
    (
        [FK_Unit_Code],
        [SysCreateUser]
    )
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX];

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;
