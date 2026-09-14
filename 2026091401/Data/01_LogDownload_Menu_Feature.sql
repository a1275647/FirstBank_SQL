/*
    系統日誌下載：新增報表管理選單與獨立功能代碼。

    權限不在部署腳本中預先發放；上線後由管理員透過既有權限設定功能授予角色。
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @RouteName         varchar(100) = 'log-download';
    DECLARE @TemplateRouteName varchar(100) = 'country-risk-level-amount-report';
    DECLARE @FeatureId         int = 125;
    DECLARE @Operator          nvarchar(20) = N'system';

    IF NOT EXISTS (SELECT 1 FROM dbo.Menu WHERE RouteName = @TemplateRouteName)
        THROW 50001, N'找不到報表管理選單範本 country-risk-level-amount-report，無法建立系統日誌下載選單。', 1;

    IF EXISTS (
        SELECT 1
        FROM dbo.FeatureDetail feature
        WHERE feature.PK_Id = @FeatureId
          AND NOT EXISTS (
              SELECT 1
              FROM dbo.Menu menu
              WHERE menu.PK_Id = feature.MenuId
                AND menu.RouteName = @RouteName))
        THROW 50002, N'功能代碼 125 已被其他功能使用，請先確認各環境資料後再部署。', 1;

    IF NOT EXISTS (SELECT 1 FROM dbo.Menu WHERE RouteName = @RouteName)
    BEGIN
        INSERT INTO dbo.Menu
            (SystemId, ParentId, Name_TN, Name_CN, Name_EN, Name_JP,
             MenuType, Seq, RouteName, IsActive, ISSystem, ISNEEDFLOW, Icon,
             Update_date, Update_user, Create_date, Create_user)
        SELECT
            template.SystemId,
            template.ParentId,
            N'系統日誌下載',
            N'系统日志下载',
            N'System Log Download',
            N'システムログダウンロード',
            template.MenuType,
            (SELECT ISNULL(MAX(sibling.Seq), 0) + 1
             FROM dbo.Menu sibling
             WHERE sibling.SystemId = template.SystemId
               AND ISNULL(sibling.ParentId, -1) = ISNULL(template.ParentId, -1)
               AND sibling.MenuType = template.MenuType),
            @RouteName,
            1,
            0,
            0,
            template.Icon,
            GETDATE(), @Operator, GETDATE(), @Operator
        FROM dbo.Menu template
        WHERE template.RouteName = @TemplateRouteName;
    END

    UPDATE dbo.Menu
    SET Name_TN = N'系統日誌下載',
        Name_CN = N'系统日志下载',
        Name_EN = N'System Log Download',
        Name_JP = N'システムログダウンロード',
        Update_date = GETDATE(),
        Update_user = @Operator
    WHERE RouteName = @RouteName;

    DECLARE @MenuId int = (SELECT PK_Id FROM dbo.Menu WHERE RouteName = @RouteName);

    SET IDENTITY_INSERT dbo.FeatureDetail ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.FeatureDetail WHERE PK_Id = @FeatureId)
    BEGIN
        INSERT INTO dbo.FeatureDetail
            (PK_Id, MenuId, Feature_Describe, Seq,
             Update_date, Update_user, Create_date, Create_user)
        VALUES
            (@FeatureId, @MenuId, N'系統日誌下載', 1,
             GETDATE(), @Operator, GETDATE(), @Operator);
    END

    SET IDENTITY_INSERT dbo.FeatureDetail OFF;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    THROW;
END CATCH;
GO
