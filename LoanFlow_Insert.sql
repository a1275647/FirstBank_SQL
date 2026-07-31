-- ══════════════════════════════════════════════════════════════════════════
-- 調借申請單 Flow / FlowDetail 初始化資料
-- ──────────────────────────────────────────────────────────────────────────
-- 設計說明：
--   所有簽核鏈的 FlowForm 共用同一個 Flow（BranchLoan 或 CUF）。
--   鏈類型由 Service 透過 RootFlowFormId / ParentId / LoanBranchData 推導，
--   不需在 Flow 或 FlowForm 額外加欄位。
--
-- TitleId：NULL=經辦  6=副理  5=經理  4=副處長  3=處長  2=副總經理
-- ElsType：100=調借鏈經辦  101=調借鏈簽核
-- Stage  ：0=經辦關卡  1=簽核關卡（Seq 區分順序）  -1=結束
-- Seq    ：同 Stage 內由左到右（無並聯，全部為 1 起）
--
-- 核決層級上限由 Service 在經辦送出時依單位類型限制 EndStepId 選單：
--   分行單位   → 最高到經理（TitleId=5）
--   處級單位   → 最高到副總（TitleId=2）
-- ══════════════════════════════════════════════════════════════════════════

DECLARE @Now  DATETIME     = GETDATE()
DECLARE @Sys  NVARCHAR(20) = N'SYSTEM'

DECLARE @BranchLoanFlowId INT   -- 分行調借申請單共用 Flow（Menu=152）
DECLARE @CufFlowId        INT   -- 跨額度調借申請單共用 Flow（Menu=153）


-- ══ STEP 1：Flow ══════════════════════════════════════════════════════════

INSERT INTO [Flow]
    (FK_Menu_Id, Name_TN, Name_CN, Name_EN, Name_JP, IsActive, Update_date, Update_user, Create_date, Create_user)
VALUES
    (152, N'分行調借簽核流程', N'分行调借签核流程', N'Branch Loan Signing Flow', N'支店ローン署名フロー', 1, @Now, @Sys, @Now, @Sys)
SET @BranchLoanFlowId = SCOPE_IDENTITY()

INSERT INTO [Flow]
    (FK_Menu_Id, Name_TN, Name_CN, Name_EN, Name_JP, IsActive, Update_date, Update_user, Create_date, Create_user)
VALUES
    (153, N'跨額度調借簽核流程', N'跨额度调借签核流程', N'CUF Signing Flow', N'CUF署名フロー', 1, @Now, @Sys, @Now, @Sys)
SET @CufFlowId = SCOPE_IDENTITY()


-- ══ STEP 2：FlowDetail ════════════════════════════════════════════════════

-- ── 分行調借簽核流程（BranchLoan，所有簽核鏈共用）─────────────────────────
INSERT INTO [FlowDetail]
    (PK_Id, FK_Flow_Id, TitleId, ElsType, Stage, Seq, Name_TN, Name_CN, Name_EN, Name_JP, Update_date, Update_user, Create_date, Create_user)
VALUES
    (NEWID(), @BranchLoanFlowId, NULL, 100,  0, 0, N'經辦',   N'经办',   N'Officer',              N'担当',       @Now, @Sys, @Now, @Sys),
    (NEWID(), @BranchLoanFlowId, 6,   101,  1, 1, N'副理',   N'副理',   N'Deputy Manager',       N'副部長',     @Now, @Sys, @Now, @Sys),
    (NEWID(), @BranchLoanFlowId, 5,   101,  1, 2, N'經理',   N'经理',   N'Manager',              N'部長',       @Now, @Sys, @Now, @Sys),
    (NEWID(), @BranchLoanFlowId, 4,   101,  1, 3, N'副處長', N'副处长', N'Deputy Director',      N'副局長',     @Now, @Sys, @Now, @Sys),
    (NEWID(), @BranchLoanFlowId, 3,   101,  1, 4, N'處長',   N'处长',   N'Director',             N'局長',       @Now, @Sys, @Now, @Sys),
    (NEWID(), @BranchLoanFlowId, 2,   101,  1, 5, N'副總經理', N'副总经理', N'Deputy General Mgr', N'副総経理',  @Now, @Sys, @Now, @Sys),
    (NEWID(), @BranchLoanFlowId, NULL,101, -1, 0, N'結束',   N'结束',   N'End',                  N'終了',       @Now, @Sys, @Now, @Sys)

-- ── 跨額度調借簽核流程（CUF，申請人鏈與中間單位鏈共用）───────────────────
INSERT INTO [FlowDetail]
    (PK_Id, FK_Flow_Id, TitleId, ElsType, Stage, Seq, Name_TN, Name_CN, Name_EN, Name_JP, Update_date, Update_user, Create_date, Create_user)
VALUES
    (NEWID(), @CufFlowId, NULL, 100,  0, 0, N'經辦',   N'经办',   N'Officer',              N'担当',       @Now, @Sys, @Now, @Sys),
    (NEWID(), @CufFlowId, 6,   101,  1, 1, N'副理',   N'副理',   N'Deputy Manager',       N'副部長',     @Now, @Sys, @Now, @Sys),
    (NEWID(), @CufFlowId, 5,   101,  1, 2, N'經理',   N'经理',   N'Manager',              N'部長',       @Now, @Sys, @Now, @Sys),
    (NEWID(), @CufFlowId, 4,   101,  1, 3, N'副處長', N'副处长', N'Deputy Director',      N'副局長',     @Now, @Sys, @Now, @Sys),
    (NEWID(), @CufFlowId, 3,   101,  1, 4, N'處長',   N'处长',   N'Director',             N'局長',       @Now, @Sys, @Now, @Sys),
    (NEWID(), @CufFlowId, 2,   101,  1, 5, N'副總經理', N'副总经理', N'Deputy General Mgr', N'副総経理',  @Now, @Sys, @Now, @Sys),
    (NEWID(), @CufFlowId, NULL,101, -1, 0, N'結束',   N'结束',   N'End',                  N'終了',       @Now, @Sys, @Now, @Sys)


-- ══ 確認查詢 ══════════════════════════════════════════════════════════════
SELECT 'Flow' AS [Table], PK_Id, FK_Menu_Id, Name_TN
FROM [Flow]
WHERE PK_Id IN (@BranchLoanFlowId, @CufFlowId)

SELECT 'FlowDetail' AS [Table], FK_Flow_Id, Stage, Seq, TitleId, ElsType, Name_TN
FROM [FlowDetail]
WHERE FK_Flow_Id IN (@BranchLoanFlowId, @CufFlowId)
ORDER BY FK_Flow_Id, Stage, Seq
