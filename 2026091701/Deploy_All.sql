-- =============================================================
-- 2026091701 移除信件範本選單（MenuId=24）下未使用的功能代碼
--   FeatureDetail PK_Id 4（查詢草稿）、5（草稿異動）、28（Email 範本設定）
--   前後端已無任何程式碼引用這三個功能代碼（草稿功能未實作、28 無對應 enum）。
--
-- 執行順序：先刪 Permissions 中角色對這三個功能的授權（FK_Permissions_FeatureDetail），再刪 FeatureDetail。
-- Permissions_his（角色權限異動歷程）不刪，保留稽核紀錄；該表對 FeatureDetail 無 FK 約束，不會擋刪除。
-- 本檔可重複執行（第二次以後各段 DELETE 影響 0 列）。
-- =============================================================
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
SET XACT_ABORT ON;
GO

-- 0. 執行前盤點：列出將被移除的功能代碼與目前被哪些角色授權（僅查詢，供留檔）
SELECT N'0.待移除 FeatureDetail' AS Item, fd.PK_Id, fd.MenuId, fd.Feature_Describe, fd.Create_user, fd.Create_date
FROM [dbo].[FeatureDetail] fd
WHERE fd.PK_Id IN (4, 5, 28);

SELECT N'0.目前授權此功能的角色' AS Item, p.PK_Id AS Permission_Id, p.FK_Role_Id, r.RoleName_TN AS RoleName, p.FK_Feature_Id, fd.Feature_Describe
FROM [dbo].[Permissions] p
JOIN [dbo].[FeatureDetail] fd ON fd.PK_Id = p.FK_Feature_Id
LEFT JOIN [dbo].[Role] r ON r.PK_Id = p.FK_Role_Id
WHERE p.FK_Feature_Id IN (4, 5, 28);
GO

BEGIN TRANSACTION;

-- 1. 移除角色對這三個功能的授權
DELETE FROM [dbo].[Permissions]
WHERE FK_Feature_Id IN (4, 5, 28);
PRINT N'1. Permissions 已刪除 ' + CAST(@@ROWCOUNT AS NVARCHAR(10)) + N' 列';

-- 2. 移除功能代碼本身
DELETE FROM [dbo].[FeatureDetail]
WHERE PK_Id IN (4, 5, 28);
PRINT N'2. FeatureDetail 已刪除 ' + CAST(@@ROWCOUNT AS NVARCHAR(10)) + N' 列';

COMMIT TRANSACTION;
GO
