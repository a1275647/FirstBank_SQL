SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		System
-- Create date: 2026/09/16
-- Description:	把 MONITORDATA_STAGE 內指定日期（可再限定來源）的資料換入正式表 MONITORDATA。
--   整個換入動作在一個短交易內完成：DELETE 正式表該範圍 → INSERT…SELECT 自暫存表，
--   正式表只在這幾秒被鎖，前端查詢不再被整段轉檔（數分鐘）擋住。
--   欄位清單由 sys.columns 動態取「兩表共有、且非 IDENTITY」的欄位，
--   正式表日後加欄位時只要暫存表也加了，本 SP 不用改；暫存表漏加則直接報錯。
--
--   參數：
--     @EXT_DATE   要換入的轉檔日期（必填）
--     @SOURCES    逗號分隔的 SOURCE 清單，例如 '10,12,13,14,18'；NULL = 該日期全部來源
--     @FIL9       再以 FIL9 限定（Source11 的 RiskLineD／RiskLineO 共用 SOURCE=11，靠 FIL9 區分）；NULL = 不限定
--   回傳一列：DeletedCount（正式表刪除筆數）、InsertedCount（自暫存表插入筆數）
--
--   注意：本 SP 不檢查該日期在正式表是否已有 Mark／Lock 或簽核中資料，重新換入會以暫存表內容為準
--        （Mark／Lock 歸零）。簽核中表單由呼叫端（TransferDataAPI）在呼叫前自動作廢。
--
--   WITH EXECUTE AS OWNER：DELETE／INSERT 是以 sp_executesql 動態執行，動態 SQL 不適用擁有權鏈，
--   若以呼叫者身分執行，程式帳號需要直接持有 MONITORDATA 的 DELETE／INSERT 權限；
--   改以 SP 擁有者（dbo）身分執行，程式帳號只需要 EXECUTE 本 SP。
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[usp_MonitorData_Publish]
	@EXT_DATE DATE,
	@SOURCES NVARCHAR(MAX) = NULL,
	@FIL9 NVARCHAR(100) = NULL
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	IF @EXT_DATE IS NULL
		THROW 50000, N'@EXT_DATE 為空值', 1;

	-- 1. 解析 @SOURCES 成字串常值清單 N'10', N'12', ...（不依賴 STRING_SPLIT，任何版本都能跑）
	DECLARE @SourceLiteral NVARCHAR(MAX) = NULL;
	IF @SOURCES IS NOT NULL AND LTRIM(RTRIM(@SOURCES)) <> N''
	BEGIN
		DECLARE @SourceList TABLE ([SOURCE] NVARCHAR(100) NOT NULL PRIMARY KEY);
		DECLARE @Remain NVARCHAR(MAX) = @SOURCES + N',';
		DECLARE @Pos INT = CHARINDEX(N',', @Remain);
		WHILE @Pos > 0
		BEGIN
			DECLARE @Item NVARCHAR(100) = LTRIM(RTRIM(SUBSTRING(@Remain, 1, @Pos - 1)));
			IF @Item <> N'' AND NOT EXISTS (SELECT 1 FROM @SourceList WHERE [SOURCE] = @Item)
				INSERT INTO @SourceList ([SOURCE]) VALUES (@Item);
			SET @Remain = SUBSTRING(@Remain, @Pos + 1, LEN(@Remain));
			SET @Pos = CHARINDEX(N',', @Remain);
		END
		IF NOT EXISTS (SELECT 1 FROM @SourceList)
		BEGIN
			-- 前一個陳述式是 WHILE 的 END，沒有分號，THROW 前要補一個
			;THROW 50001, N'@SOURCES 解析後沒有任何有效來源', 1;
		END

		SET @SourceLiteral = (
			SELECT STUFF((
				SELECT N', N''' + REPLACE([SOURCE], N'''', N'''''') + N''''
				FROM @SourceList
				ORDER BY [SOURCE]
				FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, N''));
	END

	-- 2. 正式表有而暫存表沒有的欄位視為部署不完整，直接擋下
	DECLARE @MissingInStage NVARCHAR(MAX) = (
		SELECT STUFF((
			SELECT N', ' + m.name
			FROM sys.columns m
			WHERE m.object_id = OBJECT_ID(N'[dbo].[MONITORDATA]')
			  AND m.is_identity = 0
			  AND NOT EXISTS (
				SELECT 1 FROM sys.columns s
				WHERE s.object_id = OBJECT_ID(N'[dbo].[MONITORDATA_STAGE]') AND s.name = m.name)
			FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, N''));
	IF @MissingInStage IS NOT NULL
	BEGIN
		DECLARE @MissingMsg NVARCHAR(4000) = N'MONITORDATA_STAGE 缺少欄位：' + @MissingInStage + N'，無法發佈。';
		THROW 50002, @MissingMsg, 1;
	END

	-- 3. 兩表共有、非 IDENTITY 的欄位清單，依正式表欄位順序
	DECLARE @Columns NVARCHAR(MAX) = (
		SELECT STUFF((
			SELECT N', ' + QUOTENAME(m.name)
			FROM sys.columns m
			INNER JOIN sys.columns s
				ON s.object_id = OBJECT_ID(N'[dbo].[MONITORDATA_STAGE]') AND s.name = m.name
			WHERE m.object_id = OBJECT_ID(N'[dbo].[MONITORDATA]')
			  AND m.is_identity = 0
			ORDER BY m.column_id
			FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, N''));
	IF @Columns IS NULL
		THROW 50003, N'找不到可發佈的欄位', 1;

	-- 4. 篩選條件兩邊共用，確保刪與插的範圍一致
	DECLARE @Where NVARCHAR(MAX) = N' WHERE [EXT_DATE] = @EXT_DATE';
	IF @SourceLiteral IS NOT NULL
		SET @Where += N' AND [SOURCE] IN (' + @SourceLiteral + N')';
	IF @FIL9 IS NOT NULL
		SET @Where += N' AND [FIL9] = @FIL9';

	DECLARE @DeleteSql NVARCHAR(MAX) =
		N'DELETE [dbo].[MONITORDATA]' + @Where + N'; SET @Affected = @@ROWCOUNT;';
	DECLARE @InsertSql NVARCHAR(MAX) =
		N'INSERT INTO [dbo].[MONITORDATA] (' + @Columns + N') ' +
		N'SELECT ' + @Columns + N' FROM [dbo].[MONITORDATA_STAGE]' + @Where + N'; SET @Affected = @@ROWCOUNT;';
	DECLARE @Params NVARCHAR(200) = N'@EXT_DATE DATE, @FIL9 NVARCHAR(100), @Affected INT OUTPUT';

	DECLARE @DeletedCount INT = 0, @InsertedCount INT = 0;

	-- 5. 整日發佈時暫存表若一筆都沒有，代表上游（DW／各來源）根本沒產出，不能把正式表既有的那一天清掉；
	--    限定來源的單跑則允許 0 筆（該來源當天確實沒資料時，正確狀態就是 0 筆）。
	IF @SourceLiteral IS NULL AND @FIL9 IS NULL
	   AND NOT EXISTS (SELECT 1 FROM [dbo].[MONITORDATA_STAGE] WHERE [EXT_DATE] = @EXT_DATE)
	BEGIN
		DECLARE @EmptyMsg NVARCHAR(4000) = N'MONITORDATA_STAGE 沒有 ' + CONVERT(NVARCHAR(10), @EXT_DATE, 120) + N' 的任何資料，拒絕發佈以免清空正式表該日資料。';
		THROW 50004, @EmptyMsg, 1;
	END

	-- 6. 短交易換入
	BEGIN TRY
		BEGIN TRANSACTION;

		EXEC sys.sp_executesql @DeleteSql, @Params,
			@EXT_DATE = @EXT_DATE, @FIL9 = @FIL9, @Affected = @DeletedCount OUTPUT;

		EXEC sys.sp_executesql @InsertSql, @Params,
			@EXT_DATE = @EXT_DATE, @FIL9 = @FIL9, @Affected = @InsertedCount OUTPUT;

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		IF XACT_STATE() <> 0
			ROLLBACK TRANSACTION;
		DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
		PRINT '發佈 MONITORDATA 發生錯誤: ' + @ErrorMsg;
		THROW;
	END CATCH

	SELECT @DeletedCount AS DeletedCount, @InsertedCount AS InsertedCount;
END
GO
