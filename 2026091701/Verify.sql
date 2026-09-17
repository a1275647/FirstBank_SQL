SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
-- =============================================================
-- 2026091701 部署後驗證（唯讀，可重複執行）
-- 預期：每一段的 Result 都是 OK
-- =============================================================

-- 1. FeatureDetail 已無 4 / 5 / 28
SELECT N'1.FeatureDetail 4/5/28 已移除' AS Item,
       CASE WHEN NOT EXISTS (SELECT 1 FROM [dbo].[FeatureDetail] WHERE PK_Id IN (4, 5, 28)) THEN N'OK' ELSE N'FAIL' END AS Result;

-- 2. Permissions 已無指向 4 / 5 / 28 的授權
SELECT N'2.Permissions 無殘留授權' AS Item,
       CASE WHEN NOT EXISTS (SELECT 1 FROM [dbo].[Permissions] WHERE FK_Feature_Id IN (4, 5, 28)) THEN N'OK' ELSE N'FAIL' END AS Result;

-- 3. 信件範本選單（MenuId=24）仍保留 1（查詢信件範本）、19（信件範本異動）
SELECT N'3.MenuId=24 仍有 1 與 19' AS Item,
       CASE WHEN (SELECT COUNT(*) FROM [dbo].[FeatureDetail] WHERE MenuId = 24 AND PK_Id IN (1, 19)) = 2 THEN N'OK' ELSE N'FAIL' END AS Result;

-- 4. 目前 MenuId=24 底下的功能清單（供人工核對）
SELECT N'4.MenuId=24 現況' AS Item, PK_Id, Feature_Describe, Seq
FROM [dbo].[FeatureDetail]
WHERE MenuId = 24
ORDER BY Seq, PK_Id;
GO
