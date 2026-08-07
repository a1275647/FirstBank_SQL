-- ══════════════════════════════════════════════════════════════════════════
-- FeatureDetail（功能表）「通知」（MenuId=7）異常通知項目新增 + PK_Id=21 更名
-- ──────────────────────────────────────────────────────────────────────────
-- 說明：
--   1. 新增 4 筆「異常通知」細項，Seq 接續 MenuId=7 現有最大值往後排。
--   2. 既有 PK_Id=21（原「通知」）更名為「一般通知」。
-- ══════════════════════════════════════════════════════════════════════════

DECLARE @Now    DATETIME     = GETDATE()
DECLARE @Sys    NVARCHAR(20) = N'SYSTEM'
DECLARE @MenuId INT          = 7
DECLARE @Seq    INT          = (SELECT ISNULL(MAX(Seq), 0) FROM [FeatureDetail] WHERE MenuId = @MenuId)

-- ══ STEP 1：新增異常通知項目 ═════════════════════════════════════════════
INSERT INTO [FeatureDetail]
    (MenuId, Feature_Describe, Seq, Update_date, Update_user, Create_date, Create_user)
VALUES
    (@MenuId, N'異常通知-全行餘額使用率超逾八成',                    @Seq + 1, @Now, @Sys, @Now, @Sys),
    (@MenuId, N'異常通知-全行各國餘額使用率超逾八成',                @Seq + 2, @Now, @Sys, @Now, @Sys),
    (@MenuId, N'異常通知-各單位使用餘額超逾配賦額度',                @Seq + 3, @Now, @Sys, @Now, @Sys),
    (@MenuId, N'異常通知-全行的各國餘額單日變動超逾100百萬美元',      @Seq + 4, @Now, @Sys, @Now, @Sys)

-- ══ STEP 2：PK_Id = 21 更名為「一般通知」 ═══════════════════════════════
UPDATE [FeatureDetail]
SET Feature_Describe = N'一般通知',
    Update_date = @Now,
    Update_user = @Sys
WHERE PK_Id = 21


-- ══ 確認查詢 ══════════════════════════════════════════════════════════════
SELECT PK_Id, MenuId, Feature_Describe, Seq, Update_date, Update_user, Create_date, Create_user
FROM [FeatureDetail]
WHERE MenuId = @MenuId
ORDER BY Seq
