SET NOCOUNT ON;
SET XACT_ABORT ON;

-- Role_his 底下 4 張子歷程表（成員/職位/功能權限/查詢權限）皆以 log_Role_Id 對應回
-- Role_his.log_Id，但完全沒有索引。PermissionService.GetRoleHistoryInfo 用這 4 張子表
-- 做 Count()/Select() 相關子查詢（組 TotalNumber、RoleHisQueryType 篩選、明細清單），
-- 沒有索引代表每一列 Role_his 都要各自對 4 張子表做全表掃描，資料量成長後會明顯變慢。
-- 這裡統一補上 log_Role_Id 索引，讓這些子查詢改用 Index Seek。

IF OBJECT_ID(N'[dbo].[Role_User_Mapping_his]', N'U') IS NULL
    THROW 51510, N'缺少資料表 dbo.Role_User_Mapping_his。', 1;
IF OBJECT_ID(N'[dbo].[Role_Position_Mapping_his]', N'U') IS NULL
    THROW 51511, N'缺少資料表 dbo.Role_Position_Mapping_his。', 1;
IF OBJECT_ID(N'[dbo].[Permissions_his]', N'U') IS NULL
    THROW 51512, N'缺少資料表 dbo.Permissions_his。', 1;
IF OBJECT_ID(N'[dbo].[Permissions_Query_his]', N'U') IS NULL
    THROW 51513, N'缺少資料表 dbo.Permissions_Query_his。', 1;

IF EXISTS (SELECT 1 FROM sys.indexes WHERE [object_id] = OBJECT_ID(N'[dbo].[Role_User_Mapping_his]') AND [name] = N'IX_Role_User_Mapping_his_LogRoleId')
    THROW 51514, N'dbo.Role_User_Mapping_his 已存在索引 IX_Role_User_Mapping_his_LogRoleId，請先確認是否已執行過本腳本。', 1;
IF EXISTS (SELECT 1 FROM sys.indexes WHERE [object_id] = OBJECT_ID(N'[dbo].[Role_Position_Mapping_his]') AND [name] = N'IX_Role_Position_Mapping_his_LogRoleId')
    THROW 51515, N'dbo.Role_Position_Mapping_his 已存在索引 IX_Role_Position_Mapping_his_LogRoleId，請先確認是否已執行過本腳本。', 1;
IF EXISTS (SELECT 1 FROM sys.indexes WHERE [object_id] = OBJECT_ID(N'[dbo].[Permissions_his]') AND [name] = N'IX_Permissions_his_LogRoleId')
    THROW 51516, N'dbo.Permissions_his 已存在索引 IX_Permissions_his_LogRoleId，請先確認是否已執行過本腳本。', 1;
IF EXISTS (SELECT 1 FROM sys.indexes WHERE [object_id] = OBJECT_ID(N'[dbo].[Permissions_Query_his]') AND [name] = N'IX_Permissions_Query_his_LogRoleId')
    THROW 51517, N'dbo.Permissions_Query_his 已存在索引 IX_Permissions_Query_his_LogRoleId，請先確認是否已執行過本腳本。', 1;

BEGIN TRY
    BEGIN TRANSACTION;

    CREATE NONCLUSTERED INDEX [IX_Role_User_Mapping_his_LogRoleId] ON [dbo].[Role_User_Mapping_his]
    (
        [log_Role_Id] ASC
    )
    INCLUDE
    (
        [FK_User_Id]
    )
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX];

    CREATE NONCLUSTERED INDEX [IX_Role_Position_Mapping_his_LogRoleId] ON [dbo].[Role_Position_Mapping_his]
    (
        [log_Role_Id] ASC
    )
    INCLUDE
    (
        [FK_Branch_Code],
        [FK_Department_Code],
        [TitleCode]
    )
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX];

    CREATE NONCLUSTERED INDEX [IX_Permissions_his_LogRoleId] ON [dbo].[Permissions_his]
    (
        [log_Role_Id] ASC
    )
    INCLUDE
    (
        [FK_Feature_Id]
    )
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX];

    CREATE NONCLUSTERED INDEX [IX_Permissions_Query_his_LogRoleId] ON [dbo].[Permissions_Query_his]
    (
        [log_Role_Id] ASC
    )
    INCLUDE
    (
        [OrgCode],
        [LevelCode]
    )
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX];

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;
