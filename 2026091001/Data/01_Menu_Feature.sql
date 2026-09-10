/*
    原始交易紀錄下載：新增選單與兩個功能代碼。

    可重跑：全程以 IF NOT EXISTS 判斷，重複執行不會產生第二筆選單或功能。
    不含 Permissions：權限一律由管理者在系統的「權限設定」頁發放，
    直接寫 Permissions 會繞過系統本身的權限異動稽核。
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @RouteName          varchar(100) = 'raw-transaction-data-download';
    DECLARE @TemplateRouteName  varchar(100) = 'country-risk-level-amount-report';
    DECLARE @DwFeatureId        int          = 123;
    DECLARE @SourceFeatureId    int          = 124;
    DECLARE @Operator           nvarchar(20) = N'system';

    /* ---------------------------------------------------------------
       1. 以既有的報表選單當樣板，決定新選單掛在哪一個系統／層級。
          直接抄樣板而不是寫死數值，是為了讓各環境的 SystemId／ParentId
          不同時也能正確掛上去。
       --------------------------------------------------------------- */
    IF NOT EXISTS (SELECT 1 FROM dbo.Menu WHERE RouteName = @TemplateRouteName)
        THROW 50001, N'找不到樣板選單 country-risk-level-amount-report，無法決定新選單要掛在哪一層，請確認目標環境。', 1;

    /* ---------------------------------------------------------------
       2. 功能代碼與程式碼的 FeatureType enum 硬綁（enum 值 = FeatureDetail.PK_Id），
          號碼若已被其他功能佔用就必須停下來人工處理，不可以改用別的號碼，
          否則權限會發到錯誤的功能上。
       --------------------------------------------------------------- */
    IF EXISTS (
        SELECT 1
        FROM dbo.FeatureDetail f
        WHERE f.PK_Id IN (@DwFeatureId, @SourceFeatureId)
          AND NOT EXISTS (
                SELECT 1
                FROM dbo.Menu m
                WHERE m.PK_Id = f.MenuId
                  AND m.RouteName = @RouteName))
        THROW 50002, N'功能代碼 123 或 124 已被其他功能使用，請先確認 FeatureType 對照後再執行。', 1;

    /* ---------------------------------------------------------------
       3. 新增選單（PK_Id 為 IDENTITY，交給資料庫配號）。
       --------------------------------------------------------------- */
    IF NOT EXISTS (SELECT 1 FROM dbo.Menu WHERE RouteName = @RouteName)
    BEGIN
        INSERT INTO dbo.Menu
            (SystemId, ParentId, Name_TN, Name_CN, Name_EN, Name_JP,
             MenuType, Seq, RouteName, IsActive, ISSystem, ISNEEDFLOW, Icon,
             Update_date, Update_user, Create_date, Create_user)
        SELECT
            t.SystemId,
            t.ParentId,
            N'原始交易紀錄下載',
            N'原始交易记录下载',
            N'Raw Transaction Data Download',
            N'取引原データダウンロード',
            t.MenuType,
            /* 排在同層最後 */
            (SELECT ISNULL(MAX(s.Seq), 0) + 1
             FROM dbo.Menu s
             WHERE s.SystemId = t.SystemId
               AND ISNULL(s.ParentId, -1) = ISNULL(t.ParentId, -1)
               AND s.MenuType = t.MenuType),
            @RouteName,
            1,          /* IsActive */
            0,          /* ISSystem */
            0,          /* ISNEEDFLOW：本功能不走簽核流程 */
            t.Icon,
            GETDATE(), @Operator, GETDATE(), @Operator
        FROM dbo.Menu t
        WHERE t.RouteName = @TemplateRouteName;

        PRINT N'已新增選單：' + @RouteName;
    END
    ELSE
        PRINT N'選單已存在，略過：' + @RouteName;

    DECLARE @MenuId int = (SELECT PK_Id FROM dbo.Menu WHERE RouteName = @RouteName);

    /* ---------------------------------------------------------------
       4. 新增兩個功能代碼，PK_Id 必須與程式碼的 FeatureType 一致，
          因此明確指定值而非讓 IDENTITY 配號。
       --------------------------------------------------------------- */
    /* 兩筆分開判斷，前一次執行只成功一半時重跑才會把缺的那筆補上。 */
    SET IDENTITY_INSERT dbo.FeatureDetail ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.FeatureDetail WHERE PK_Id = @DwFeatureId)
    BEGIN
        INSERT INTO dbo.FeatureDetail
            (PK_Id, MenuId, Feature_Describe, Seq,
             Update_date, Update_user, Create_date, Create_user)
        VALUES
            (@DwFeatureId, @MenuId, N'DW 資料表下載', 1, GETDATE(), @Operator, GETDATE(), @Operator);

        PRINT N'已新增功能代碼 123（DW 資料表下載），MenuId=' + CAST(@MenuId AS nvarchar(10));
    END
    ELSE
        PRINT N'功能代碼 123 已存在，略過。';

    IF NOT EXISTS (SELECT 1 FROM dbo.FeatureDetail WHERE PK_Id = @SourceFeatureId)
    BEGIN
        INSERT INTO dbo.FeatureDetail
            (PK_Id, MenuId, Feature_Describe, Seq,
             Update_date, Update_user, Create_date, Create_user)
        VALUES
            (@SourceFeatureId, @MenuId, N'來源原始檔下載', 2, GETDATE(), @Operator, GETDATE(), @Operator);

        PRINT N'已新增功能代碼 124（來源原始檔下載），MenuId=' + CAST(@MenuId AS nvarchar(10));
    END
    ELSE
        PRINT N'功能代碼 124 已存在，略過。';

    SET IDENTITY_INSERT dbo.FeatureDetail OFF;

    COMMIT TRANSACTION;
    PRINT N'原始交易紀錄下載：選單與功能代碼部署完成。';
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    PRINT N'部署失敗，已全部回復。';
    THROW;
END CATCH;
GO
