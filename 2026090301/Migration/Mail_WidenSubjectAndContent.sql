SET NOCOUNT ON;
SET XACT_ABORT ON;

-- dbo.MailLog（寄信紀錄）與 dbo.Mail／Mail_his／Mail_temp（信件範本主檔/歷程/暫存）的
-- Subject/Mail_Content 太窄，長一點的內容（範本內容、或多筆異常訊息合併成一封信）存檔時
-- 會噴 String or binary data would be truncated。全部改成跟 dbo.Notice 的
-- NoticeTitle(255)/NoticeContent(4000) 對齊。max_length 以 byte 計，nvarchar(200)/(2000)
-- 存放時為 400/4000；已是新寬度時 IF EXISTS 找不到符合列，該段落自動略過，可安全重跑。

IF OBJECT_ID(N'[dbo].[MailLog]', N'U') IS NULL
   OR OBJECT_ID(N'[dbo].[Mail]', N'U') IS NULL
   OR OBJECT_ID(N'[dbo].[Mail_his]', N'U') IS NULL
   OR OBJECT_ID(N'[dbo].[Mail_temp]', N'U') IS NULL
    THROW 51400, N'找不到 dbo.MailLog / Mail / Mail_his / Mail_temp 其中之一。', 1;

BEGIN TRY
    BEGIN TRANSACTION;

    -- dbo.MailLog（Subject/Mail_Content 皆為 NULL 欄位）
    IF EXISTS (SELECT 1 FROM sys.columns WHERE [object_id] = OBJECT_ID(N'[dbo].[MailLog]') AND [name] = N'Subject' AND [max_length] = 400)
        ALTER TABLE [dbo].[MailLog] ALTER COLUMN [Subject] [nvarchar](255) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL;
    IF EXISTS (SELECT 1 FROM sys.columns WHERE [object_id] = OBJECT_ID(N'[dbo].[MailLog]') AND [name] = N'Mail_Content' AND [max_length] = 4000)
        ALTER TABLE [dbo].[MailLog] ALTER COLUMN [Mail_Content] [nvarchar](4000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL;

    -- dbo.Mail（Subject/Mail_Content 皆為 NOT NULL 欄位）
    IF EXISTS (SELECT 1 FROM sys.columns WHERE [object_id] = OBJECT_ID(N'[dbo].[Mail]') AND [name] = N'Subject' AND [max_length] = 400)
        ALTER TABLE [dbo].[Mail] ALTER COLUMN [Subject] [nvarchar](255) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL;
    IF EXISTS (SELECT 1 FROM sys.columns WHERE [object_id] = OBJECT_ID(N'[dbo].[Mail]') AND [name] = N'Mail_Content' AND [max_length] = 4000)
        ALTER TABLE [dbo].[Mail] ALTER COLUMN [Mail_Content] [nvarchar](4000) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL;

    -- dbo.Mail_his（Subject/Mail_Content 皆為 NOT NULL 欄位）
    IF EXISTS (SELECT 1 FROM sys.columns WHERE [object_id] = OBJECT_ID(N'[dbo].[Mail_his]') AND [name] = N'Subject' AND [max_length] = 400)
        ALTER TABLE [dbo].[Mail_his] ALTER COLUMN [Subject] [nvarchar](255) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL;
    IF EXISTS (SELECT 1 FROM sys.columns WHERE [object_id] = OBJECT_ID(N'[dbo].[Mail_his]') AND [name] = N'Mail_Content' AND [max_length] = 4000)
        ALTER TABLE [dbo].[Mail_his] ALTER COLUMN [Mail_Content] [nvarchar](4000) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL;

    -- dbo.Mail_temp（Subject/Mail_Content 皆為 NULL 欄位）
    IF EXISTS (SELECT 1 FROM sys.columns WHERE [object_id] = OBJECT_ID(N'[dbo].[Mail_temp]') AND [name] = N'Subject' AND [max_length] = 400)
        ALTER TABLE [dbo].[Mail_temp] ALTER COLUMN [Subject] [nvarchar](255) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL;
    IF EXISTS (SELECT 1 FROM sys.columns WHERE [object_id] = OBJECT_ID(N'[dbo].[Mail_temp]') AND [name] = N'Mail_Content' AND [max_length] = 4000)
        ALTER TABLE [dbo].[Mail_temp] ALTER COLUMN [Mail_Content] [nvarchar](4000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL;

    IF EXISTS (
        SELECT 1 FROM sys.columns
        WHERE ([object_id] = OBJECT_ID(N'[dbo].[MailLog]') OR [object_id] = OBJECT_ID(N'[dbo].[Mail]')
            OR [object_id] = OBJECT_ID(N'[dbo].[Mail_his]') OR [object_id] = OBJECT_ID(N'[dbo].[Mail_temp]'))
          AND [name] = N'Subject' AND [max_length] <> 510
    )
        THROW 51401, N'仍有資料表的 Subject 未成功加寬到 nvarchar(255)，請確認執行結果。', 1;

    IF EXISTS (
        SELECT 1 FROM sys.columns
        WHERE ([object_id] = OBJECT_ID(N'[dbo].[MailLog]') OR [object_id] = OBJECT_ID(N'[dbo].[Mail]')
            OR [object_id] = OBJECT_ID(N'[dbo].[Mail_his]') OR [object_id] = OBJECT_ID(N'[dbo].[Mail_temp]'))
          AND [name] = N'Mail_Content' AND [max_length] <> 8000
    )
        THROW 51402, N'仍有資料表的 Mail_Content 未成功加寬到 nvarchar(4000)，請確認執行結果。', 1;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;
