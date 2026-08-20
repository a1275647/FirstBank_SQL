-- PHASE 2 OF 2: PROGRAMMABLE OBJECTS
-- SSMS ready-to-run instructions:
--   1. Run 01_DropCreateTables.sql first and confirm that it prints PHASE 1 COMPLETED.
--   2. Connect to the same NCRMS database in a normal SSMS query window (SQLCMD Mode is not required).
--   3. Open this complete file and press F5 without selecting only part of it.
-- This file rebuilds stored procedures, functions, the managed view, and the retired table type cleanup.
USE [NCRMS];
GO
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO
DECLARE @PreflightError nvarchar(2048) = NULL;

IF DB_NAME() <> N'NCRMS'
    SET @PreflightError = N'Target database mismatch. Expected NCRMS but connected to ' + QUOTENAME(DB_NAME()) + N'.';

IF @PreflightError IS NOT NULL
BEGIN
    PRINT N'DEPLOYMENT HALTED: ' + @PreflightError;
    SET NOEXEC ON;
END;
GO

-- Requires DDL rights only. No application-table DML is executed by this deployment driver.
BEGIN TRANSACTION;
GO
DROP PROCEDURE IF EXISTS [dbo].[usp_UpdateMonitorDataUnit];
GO
DROP PROCEDURE IF EXISTS [dbo].[usp_UpdateMonitorDataPruduct07RiskFactor];
GO
DROP PROCEDURE IF EXISTS [dbo].[usp_UpdateCustomer];
GO
DROP PROCEDURE IF EXISTS [dbo].[usp_ResolveGroupIdForCustomer];
GO
DROP PROCEDURE IF EXISTS [dbo].[usp_BmiRatingCount];
GO
DROP PROCEDURE IF EXISTS [dbo].[usp_UpdateMonitorDataLimit];
GO
DROP PROCEDURE IF EXISTS [dbo].[usp_UpdateMonitorDataFPEXR_RateUSD];
GO
DROP PROCEDURE IF EXISTS [dbo].[usp_UpdateMonitorDataCNWeights];
GO
DROP PROCEDURE IF EXISTS [dbo].[usp_UpdateMonitorDataCalculatedUsdAmount];
GO
DROP PROCEDURE IF EXISTS [dbo].[usp_TransferData];
GO
DROP PROCEDURE IF EXISTS [dbo].[usp_Souce09_By_ARS_SUKSWP_D_MF];
GO
DROP PROCEDURE IF EXISTS [dbo].[usp_Souce09_By_ARS_SUKNMM_D_MF];
GO
DROP PROCEDURE IF EXISTS [dbo].[usp_Souce09_By_ARS_SUKNIRS_D_MF];
GO
DROP PROCEDURE IF EXISTS [dbo].[usp_Souce09_By_ARS_SUKNFX_D_MF];
GO
DROP PROCEDURE IF EXISTS [dbo].[usp_Souce09_By_ARS_SUKNFO_D_MF];
GO
DROP PROCEDURE IF EXISTS [dbo].[usp_Souce09_By_ARS_SUKNBD1_D_MF];
GO
DROP PROCEDURE IF EXISTS [dbo].[usp_Souce09_By_ARS_SUKMST_D_MF];
GO
DROP PROCEDURE IF EXISTS [dbo].[usp_Souce09_By_ARS_SUKIRO_D_MF];
GO
DROP PROCEDURE IF EXISTS [dbo].[usp_Souce09_By_ARS_SUKFRA_D_MF];
GO
DROP PROCEDURE IF EXISTS [dbo].[usp_Souce09_By_ARS_SUKBDO_D_MF];
GO
DROP PROCEDURE IF EXISTS [dbo].[usp_Souce09_By_ARS_SUKBD2_D_MF];
GO
DROP PROCEDURE IF EXISTS [dbo].[usp_Souce06_By_FL_FLMST_D_MF];
GO
DROP PROCEDURE IF EXISTS [dbo].[usp_Souce04_By_LS_LSRSA_D_MF_ACNOD_STG];
GO
DROP PROCEDURE IF EXISTS [dbo].[usp_Souce01_OBBS_By_OS_LNSMSTD_D_MF_OS_LNSLMSD_D_MF];
GO
DROP PROCEDURE IF EXISTS [dbo].[usp_Souce01_OBBS_By_OSMMKF02_MF];
GO
DROP PROCEDURE IF EXISTS [dbo].[usp_Souce01_OBBS_By_OSISKF02_MF];
GO
DROP PROCEDURE IF EXISTS [dbo].[usp_Souce01_OBBS_By_OSFXKF02_MF];
GO
DROP PROCEDURE IF EXISTS [dbo].[usp_Souce01_OBBS_By_OSBDKF02_MF];
GO
DROP PROCEDURE IF EXISTS [dbo].[usp_HRIS_Transfer_Users];
GO
DROP PROCEDURE IF EXISTS [dbo].[usp_HRIS_Transfer_BankUnit];
GO
DROP PROCEDURE IF EXISTS [dbo].[usp_HRIS_Transfer_BankGroup];
GO
DROP PROCEDURE IF EXISTS [dbo].[usp_HRIS_Transfer_BankBranch];
GO
DROP PROCEDURE IF EXISTS [dbo].[usp_GetGroupId];
GO
DROP PROCEDURE IF EXISTS [dbo].[usp_CreateTempTable_Detail];
GO
DROP PROCEDURE IF EXISTS [dbo].[usp_CreateTempTable];
GO
DROP PROCEDURE IF EXISTS [dbo].[usp_CreateHistoryTable_Detail];
GO
DROP PROCEDURE IF EXISTS [dbo].[usp_CreateHistoryTable];
GO
DROP PROCEDURE IF EXISTS [dbo].[usp_CreateHistoryHasFlowTable];
GO
DROP FUNCTION IF EXISTS [dbo].[ufn_table_GetUnitName];
GO
DROP FUNCTION IF EXISTS [dbo].[ufn_table_GetMonitorDataLimitAmount];
GO
DROP FUNCTION IF EXISTS [dbo].[ufn_table_GetCountryRating];
GO
DROP FUNCTION IF EXISTS [dbo].[ufn_MatchingCustomerGroupIds];
GO
DROP FUNCTION IF EXISTS [dbo].[ufn_GetWeekOfMonth];
GO
DROP FUNCTION IF EXISTS [dbo].[ufn_GetNumFromFileName];
GO
DROP FUNCTION IF EXISTS [dbo].[ufn_GetLastDateOfWeek];
GO
DROP FUNCTION IF EXISTS [dbo].[ufn_FinancialRiskFactor];
GO
DROP FUNCTION IF EXISTS [dbo].[ufn_CodePrefix];
GO
DROP VIEW IF EXISTS [dbo].[RoleUserMatch];
GO
DROP FUNCTION IF EXISTS [dbo].[getNUM];
GO
DROP TYPE IF EXISTS [dbo].[CountryRatingResultType];
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
Create FUNCTION [dbo].[getNUM]
(@date1 as datetime)
RETURNS char(15)
BEGIN
declare @yyyy char(2),@mm char(2),@dd char(2),@hh char(2),@minu char(2),@ss char(2),@mill char(3),@str char(15)

SET @yyyy=RIGHT(DATENAME ( year , @date1 ),2)
SET       @mm=LTRIM(rtrim(month ( @date1 )))
SET       @dd=LTRIM(rtrim(DATENAME ( day , @date1 )) )
SET       @hh=LTRIM(rtrim(DATENAME ( hour , @date1 ))  )
SET       @minu=LTRIM(rtrim(DATENAME ( minute ,@date1 )))
SET       @ss=LTRIM(rtrim(DATENAME ( second , @date1)))
SET       @mill=LTRIM(rtrim(DATENAME ( millisecond , @date1 )))



REturn @YYYY+RTRIM(REPLICATE('0', 2-LEN(@MM)) +@MM)+RTRIM(REPLICATE('0', 2-LEN(@DD)) +@DD)+RTRIM(REPLICATE('0', 2-LEN(@HH)) +@HH)+RTRIM(REPLICATE('0', 2-LEN(@minu)) +@minu)+RTRIM(REPLICATE('0', 2-LEN(@ss)) +@ss)+RTRIM(REPLICATE('0', 3-LEN(@mill)) +@mill)

END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[RoleUserMatch]
AS
SELECT          u.UserId, rum.FK_Role_Id AS RoleId
FROM              Users u INNER JOIN
                            Role_User_Mapping rum ON rum.FK_User_Id = u.UserId
UNION
SELECT          u.UserId, rpm.FK_Role_Id AS RoleId
FROM              Users u INNER JOIN
                            Role_Position_Mapping rpm ON rpm.TitleCode = u.TitleCode AND ((rpm.FK_Branch_Code IS NOT NULL AND
                            rpm.FK_Branch_Code = u.BranchCode) OR
                            (rpm.FK_Branch_Code IS NULL AND rpm.FK_Department_Code = u.DepartmentCode));
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties =
   Begin PaneConfigurations =
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane =
      Begin Origin =
         Top = 0
         Left = 0
      End
      Begin Tables =
      End
   End
   Begin SQLPane =
   End
   Begin DataPane =
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane =
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'RoleUserMatch'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'RoleUserMatch'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[ufn_CodePrefix] (@code nvarchar(50))
RETURNS nvarchar(50)
AS
BEGIN
	RETURN　REPLACE(TRANSLATE(@code, 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz','@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'), '@', '')
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Allen
-- Create date: 20250908
-- Description:	傳入產品別英文代號，回傳ProductMaster.ProductCode
-- =============================================
CREATE FUNCTION [dbo].[ufn_FinancialRiskFactor](
	@DAY AS INT,@ProductCode as nvarchar(20),@CUR_BOUGHT AS NVARCHAR(3) = '',@CUR_SOLD AS NVARCHAR(3) = '')
RETURNS decimal(10,2)
--RETURNS NVARCHAR(20)
AS
BEGIN
	DECLARE @MAXID AS INT -- 有資料的時間最大ID
	DECLARE @MINID as int -- 有資料的時間最小ID
	DECLARE @MAPPING_DAYID AS INT
	DECLARE @ProductID AS INT
	DECLARE @RISKFACTOR AS DECIMAL(10,2)
	DECLARE @MAXDAY AS INT
	--取得目前系統最大上限DAY
	SELECT @MAXDAY = MAX(MaxDays)
	FROM FinancialRiskFactorPeriodDay
	--如果傳入的DAY大於系統最高上限，則轉換為最大上限DAY
	IF @DAY > @MAXDAY
		SET @DAY = @MAXDAY

	-- 如果是匯率風險係數，買幣別與賣幣別可以對調組成ProductCode，若找不到就指定為OTHERS
	IF @CUR_BOUGHT <> '' OR @CUR_SOLD <> '' BEGIN
		SET @ProductCode = ISNULL((
			SELECT ProductCode
			FROM FinancialProductMaster
			WHERE ProductCode IN(@CUR_BOUGHT+'/'+@CUR_SOLD,@CUR_SOLD+'/'+@CUR_BOUGHT)),'OTHERS')
	END
	--取得日期間對應的ID
	SELECT @MAPPING_DAYID = PK_ID
	FROM FinancialRiskFactorPeriodDay
	WHERE (CASE WHEN @DAY > 0 THEN @DAY ELSE 0 END) BETWEEN MinDays AND MaxDays
	--取得該項目有設定風險係數的最小時間範圍ID 與最大時間範圍ID
	SELECT @ProductID = FK_ProductID, @MINID = MIN(FK_PeriodID),@MAXID = MAX(FK_PeriodID)
	FROM FinancialRiskFactorData a
	inner join FinancialProductMaster b on a.FK_ProductID = b.PK_ID AND B.ProductCode = @ProductCode
	GROUP BY FK_ProductID

	--如果匹配不到@PRODUCT_ID IS NULL，代表PRODUCT_ID沒對應到，直接回傳NULL
	IF @ProductID IS NULL
		RETURN NULL

	SELECT @RISKFACTOR = RiskFactor
	FROM FinancialRiskFactorData
	WHERE FK_PeriodID = @MAPPING_DAYID AND FK_ProductID = @ProductID

	IF @RISKFACTOR IS NULL BEGIN
		-- 小於有設定天數按照最小有設定的天數算，大於最大有設定的天數按照最大有設定的天數算
		IF @MAPPING_DAYID < @MINID BEGIN
			SET @MAPPING_DAYID = @MINID
		END
		ELSE IF @MAPPING_DAYID > @MAXID BEGIN
			SET @MAPPING_DAYID = @MAXID
		END
	END
	SELECT @RISKFACTOR = RiskFactor
	FROM FinancialRiskFactorData
	WHERE FK_PeriodID = @MAPPING_DAYID AND FK_ProductID = @ProductID
	RETURN @RISKFACTOR
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Allen
-- Create date: 2026/03/26
-- Description:	填寫年月週，取得當週最後一天（週五）
-- =============================================
CREATE FUNCTION [dbo].[ufn_GetLastDateOfWeek]
(
    @Year INT,
    @Month INT,
    @Week INT
)
RETURNS DATE
AS
BEGIN
    DECLARE @FirstDayOfMonth DATE = CAST(@Year AS VARCHAR(4)) + '-' + RIGHT('0' + CAST(@Month AS VARCHAR(2)), 2) + '-01'

    -- 0=週六, 1=週日...6=週五（以週六為每週第一天）
    DECLARE @FirstDayWeekday INT = (DATEDIFF(DAY, '19000106', @FirstDayOfMonth) % 7)

    DECLARE @FirstSaturday DATE
    DECLARE @Result DATE

    IF @FirstDayWeekday = 0
        SET @FirstSaturday = @FirstDayOfMonth  -- 月初剛好是週六
    ELSE
        SET @FirstSaturday = DATEADD(DAY, 7 - @FirstDayWeekday, @FirstDayOfMonth)  -- 下一個週六

    IF @Week = 1
    BEGIN
        -- 第1週結束在第一個週六前的週五
        IF @FirstDayWeekday = 0
            -- 月初是週六，第1週週五 = 月初 + 6天
            SET @Result = DATEADD(DAY, 6, @FirstDayOfMonth)
        ELSE
            -- 月初不是週六，第1週週五 = 第一個週六的前一天
            SET @Result = DATEADD(DAY, -1, @FirstSaturday)
    END
    ELSE
    BEGIN
        -- 第N週的週六 = 第一個週六 + (N-2) * 7
        DECLARE @WeekStartSaturday DATE = DATEADD(DAY, (@Week - 2) * 7, @FirstSaturday)
        -- 當週週五 = 當週週六 + 6天
        SET @Result = DATEADD(DAY, 6, @WeekStartSaturday)
    END

    -- 避免超過當月最後一天
    DECLARE @LastDayOfMonth DATE = EOMONTH(@FirstDayOfMonth)
    IF @Result > @LastDayOfMonth
        SET @Result = @LastDayOfMonth

    RETURN @Result
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[ufn_GetNumFromFileName]
(
    @FileName NVARCHAR(500),
    @ContinuousOnly BIT = 1
)
RETURNS VARCHAR(20)
AS
BEGIN
    DECLARE @Len INT = LEN(@FileName)
    DECLARE @i INT = @Len
    DECLARE @Char NCHAR(1)
    DECLARE @NumericPart NVARCHAR(20) = ''
    DECLARE @FoundDigit BIT = 0  -- 是否已找到第一個數字

    WHILE @i > 0
    BEGIN
        SET @Char = SUBSTRING(@FileName, @i, 1)

        IF @Char LIKE '[0-9]'
        BEGIN
            SET @FoundDigit = 1
            SET @NumericPart = @Char + @NumericPart
        END
        ELSE IF @FoundDigit = 1 AND @ContinuousOnly = 1
            BREAK  -- 已收集數字後遇到非數字，停止

        SET @i = @i - 1
    END

    RETURN @NumericPart
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[ufn_GetWeekOfMonth] (@DateTime AS Date)
RETURNS INT
AS
BEGIN
    DECLARE @FirstDayOfMonth DATE = DATEADD(DAY, 1 - DAY(@DateTime), @DateTime)
    DECLARE @CurrentDate DATE = CAST(@DateTime AS DATE)

    -- '19000106' 是已知的週六，用來計算以週六為基準的星期幾
    -- 0=週六, 1=週日, 2=週一, 3=週二, 4=週三, 5=週四, 6=週五
    DECLARE @FirstDayWeekday INT = (DATEDIFF(DAY, '19000106', @FirstDayOfMonth) % 7)

    -- 計算當前日期距離月初有幾天
    DECLARE @DaysFromMonthStart INT = DATEDIFF(DAY, @FirstDayOfMonth, @CurrentDate)

    DECLARE @WeekNumber INT

    IF @FirstDayWeekday = 0
    BEGIN
        -- 月初剛好是週六，正常計算
        SET @WeekNumber = (@DaysFromMonthStart / 7) + 1
    END
    ELSE
    BEGIN
        -- 月初是週日~週五，先算到本週週五還剩幾天
        -- 距離本週週五的天數 = 6 - @FirstDayWeekday
        DECLARE @DaysToFriday INT = 6 - @FirstDayWeekday

        IF @DaysFromMonthStart <= @DaysToFriday
            SET @WeekNumber = 1  -- 還在第1週（不完整週）
        ELSE
            -- 從下一個週六開始算第2週
            SET @WeekNumber = ((@DaysFromMonthStart - @DaysToFriday - 1) / 7) + 2
    END

    RETURN @WeekNumber
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[ufn_MatchingCustomerGroupIds]
(
    @PK_Id INT,                     -- 排除自己；沒有自身PK_Id（如temp階段）可傳NULL
    @CustomerName NVARCHAR(500),
    @Unit NVARCHAR(50),
    @SwiftCode NVARCHAR(20),
    @LEI NVARCHAR(20),
    @ISIN NVARCHAR(12),
    @CustomerMark NVARCHAR(50) = NULL
)
RETURNS TABLE
AS
RETURN
(
    -- 歸戶五鍵值比對規則的唯一定義（single source of truth）。
    -- 給定一筆客戶的描述欄位，回傳 Customer 表中所有「視為同一客戶」的既有記錄
    -- (PK_Id, GroupId)。任一鍵值成立即算相符：
    --   1) CustomerName + Unit 皆相同
    --   2) SwiftCode 前四碼相同（比對持久化計算欄位 SwiftCode4，可走索引Seek）
    --   3) LEI 完全相同
    --   4) ISIN 完全相同
    --   5) CustomerMark（客戶自訂歸戶標記）完全相同
    SELECT c.PK_Id, c.GroupId
    FROM Customer c
    WHERE (@PK_Id IS NULL OR c.PK_Id <> @PK_Id)
      AND c.CustomerName = @CustomerName AND c.Unit = @Unit
      AND NULLIF(@CustomerName, N'') IS NOT NULL AND NULLIF(@Unit, N'') IS NOT NULL

    UNION

    SELECT c.PK_Id, c.GroupId
    FROM Customer c
    WHERE (@PK_Id IS NULL OR c.PK_Id <> @PK_Id)
      AND c.SwiftCode4 = LEFT(@SwiftCode, 4)
      AND NULLIF(c.SwiftCode4, N'') IS NOT NULL AND NULLIF(LEFT(@SwiftCode, 4), N'') IS NOT NULL

    UNION

    SELECT c.PK_Id, c.GroupId
    FROM Customer c
    WHERE (@PK_Id IS NULL OR c.PK_Id <> @PK_Id)
      AND c.LEI = @LEI
      AND NULLIF(c.LEI, N'') IS NOT NULL AND NULLIF(@LEI, N'') IS NOT NULL

    UNION

    SELECT c.PK_Id, c.GroupId
    FROM Customer c
    WHERE (@PK_Id IS NULL OR c.PK_Id <> @PK_Id)
      AND c.ISIN = @ISIN
      AND NULLIF(c.ISIN, N'') IS NOT NULL AND NULLIF(@ISIN, N'') IS NOT NULL

    UNION

    SELECT c.PK_Id, c.GroupId
    FROM Customer c
    WHERE (@PK_Id IS NULL OR c.PK_Id <> @PK_Id)
      AND c.CustomerMark = @CustomerMark
      AND NULLIF(c.CustomerMark, N'') IS NOT NULL AND NULLIF(@CustomerMark, N'') IS NOT NULL
);
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[ufn_table_GetCountryRating](@Date DATE)
RETURNS TABLE
AS
RETURN
(
    WITH RatingData AS (
        SELECT a.FK_Country_Id, b.InternalRatingLevel, a.RatingOutlook,
            ROW_NUMBER() OVER (PARTITION BY a.FK_Country_Id ORDER BY b.InternalRatingLevel) AS rn,
            COUNT(*) OVER (PARTITION BY a.FK_Country_Id) AS RatingCount
        FROM (
            SELECT FK_Country_Id, FK_RatingAgency_Id, AgencyRating, RatingOutlook,
                ROW_NUMBER() OVER (PARTITION BY FK_Country_Id, FK_RatingAgency_Id ORDER BY Create_date DESC) AS agency_rn
            FROM CreditRating_Country
            WHERE CAST(Create_date AS DATE) <= @Date
        ) a
        INNER JOIN CreditRating_ScoreMapping b
            ON a.FK_RatingAgency_Id = b.FK_RatingAgencyID
            AND a.AgencyRating = b.AgencyRating
        WHERE a.agency_rn = 1
    ),
    RatingCalculation AS (
		SELECT FK_Country_Id,
			CASE
				WHEN RatingCount = 3 THEN (SELECT InternalRatingLevel FROM RatingData rd2 WHERE rn = 2 AND rd2.FK_Country_Id = rd.FK_Country_Id)
				WHEN RatingCount >= 1 THEN MAX(InternalRatingLevel)
				ELSE 5
			END AS FinalRating,
			MIN(
				CASE
					WHEN RatingOutlook IN ('Positive', 'POS', 'Rating Outlook Positive') THEN 1
					WHEN RatingOutlook IN ('Stable', 'STA', 'Rating Outlook Stable')     THEN 0
					WHEN RatingOutlook IN ('Negative', 'NEG', 'Rating Outlook Negative') THEN -1
					ELSE NULL
				END
			) AS Score
		FROM RatingData rd
		GROUP BY FK_Country_Id, RatingCount
	)
    SELECT
		CASE WHEN c.CountryCode2 = 'S9' THEN 1
			 ELSE ISNULL(rc.FinalRating, 5)
		END AS FinalRating,
		c.PK_Id AS FK_Country_Id,
		ISNULL(rc.Score, 0) AS Score
	FROM CountryMaster c
	LEFT JOIN RatingCalculation rc ON c.PK_Id = rc.FK_Country_Id
)
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[ufn_table_GetMonitorDataLimitAmount] (@Dates NVARCHAR(MAX))
RETURNS TABLE
AS
RETURN
(
	with temp as (
		select *
			from MONITORDATA a
			WHERE CONVERT(DATE,EXT_DATE) IN (
										 SELECT CONVERT(DATE,value)
										 FROM string_split(@Dates,',')
										 where LTRIM(RTRIM(value)) <> '')
	),
	-- 相同額度 分行 核准編號 轉檔日期  核准額度只算一次 第一筆要給值 其他給0
	temp2 as (
		select  *,
				CASE WHEN ROW_NUMBER() OVER (PARTITION BY BRANCH_NO,ISNULL(NULLIF(LTRIM(RTRIM(PERMIT_NO)), ''), CAST(PK_Id AS NVARCHAR(20)))
														,COUNTRY_COD,TO_USD_LIMIT,EXT_DATE ORDER BY PK_Id) = 1
				THEN TO_USD_LIMIT
				ELSE 0
				END SUM_TO_USD_LIMIT
		from temp
	),
	temp3 as (
		select *,
			ROW_NUMBER() OVER(
				PARTITION BY BRANCH_NO,ISNULL(NULLIF(LTRIM(RTRIM(PERMIT_NO)), ''), CAST(PK_Id AS NVARCHAR(20))),EXT_DATE ORDER BY PK_Id
				) AS rn_final,
			SUM(SUM_TO_USD_LIMIT) OVER (
				PARTITION BY BRANCH_NO,ISNULL(NULLIF(LTRIM(RTRIM(PERMIT_NO)), ''), CAST(PK_Id AS NVARCHAR(20))),EXT_DATE
				) AS GroupTotal
		FROM temp2
	)
	SELECT PK_ID,GROUP_NO,UNIT_NO,BRANCH_NO,TX_DATE,AS_OF_DATE,PRODUCT_TYPE,TRAN_NO,CUSTOMER_ID,CUSTOMER_NAME,
			COUNTRY_COD,CURENCY_COD,TRAN_AMOUNT,TO_USD_AMT,PERMIT_NO,LIMIT,LIMIT_COD,TO_USD_LIMIT,
			CASE WHEN rn_final = 1 THEN
				CASE WHEN TOP_Limit_USD_Amount IS NOT NULL AND GroupTotal > TOP_Limit_USD_Amount
				then TOP_Limit_USD_Amount
				else GroupTotal
				end
			else 0
			end as SUM_TO_USD_LIMIT,
			REVOLVE_MK,FIL9,
			SOURCE,LIMIT_MATURITY,MATURITY_DATE,INDUSTRY,INDUSTRY_Type,PRODUCT_CODE,CUR_BOUGHT,CUR_SOLD,RISKFACTOR,
			WEIGHTS,Create_DateTime,YEAR,MONTH,Week,EXT_DATE,TOP_Limit_USD_Amount
	FROM temp3
)
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Allen
-- Create date: 20251003
-- Description:	取得部門單位
-- =============================================
CREATE FUNCTION [dbo].[ufn_table_GetUnitName](@UnitCode nvarchar(20))
RETURNS @TABLE TABLE(
	UNITCODE  NVARCHAR(120),
	UNITNAME_TN  NVARCHAR(120),
	UNITNAME_CN  NVARCHAR(120),
	UNITNAME_JP  NVARCHAR(120),
	UNITNAME_EN  NVARCHAR(120)
) AS BEGIN
	INSERT @TABLE
	SELECT @UnitCode,GroupName_TN,GroupName_CN,GroupName_JP,GroupName_EN
	FROM BankGroup WHERE GroupCode = @UnitCode
	UNION ALL
	SELECT @UnitCode,UnitName_TN,UnitName_CN,UnitName_JP,UnitName_EN
	FROM BankUnit WHERE UnitCode = @UnitCode
	UNION ALL
	SELECT @UnitCode,BankName_TN,BankName_CN,BankName_JP,BankName_EN
	FROM BankBranch WHERE BankCode = @UnitCode

	IF NOT EXISTS (SELECT 1 FROM @TABLE)
	BEGIN
		INSERT @TABLE
		SELECT TOP 1 @UnitCode,departmentName,departmentName,departmentName,departmentName
		FROM Users
		WHERE departmentCode = @UnitCode
	END

	RETURN
END;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_CreateHistoryHasFlowTable]
    @TableName NVARCHAR(128)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @HistoryTableName NVARCHAR(128) = @TableName + '_his';
    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @ColumnDefinitions NVARCHAR(MAX) = '';
    DECLARE @SchemaName NVARCHAR(128) = 'dbo';
    DECLARE @ObjectId INT;

    -- 檢查原始表是否存在
    IF NOT EXISTS (
        SELECT 1
        FROM INFORMATION_SCHEMA.TABLES
        WHERE TABLE_NAME = @TableName
          AND TABLE_SCHEMA = @SchemaName
    )
    BEGIN
        RAISERROR('原始表 %s 不存在', 16, 1, @TableName);
        RETURN;
    END

    -- 取得 Object ID
    SET @ObjectId = OBJECT_ID(@SchemaName + '.' + @TableName);

    IF @ObjectId IS NULL
    BEGIN
        RAISERROR('無法取得表 %s 的 Object ID', 16, 1, @TableName);
        RETURN;
    END

    -- 檢查歷史表是否已存在
    IF EXISTS (
        SELECT 1
        FROM INFORMATION_SCHEMA.TABLES
        WHERE TABLE_NAME = @HistoryTableName
          AND TABLE_SCHEMA = @SchemaName
    )
    BEGIN
        RAISERROR('歷史表 %s 已經存在', 16, 1, @HistoryTableName);
        RETURN;
    END

    -- 檢查 FlowForm 表是否存在
    IF NOT EXISTS (
        SELECT 1
        FROM INFORMATION_SCHEMA.TABLES
        WHERE TABLE_NAME = 'FlowForm'
          AND TABLE_SCHEMA = @SchemaName
    )
    BEGIN
        RAISERROR('FlowForm 表不存在，無法建立外鍵', 16, 1);
        RETURN;
    END

    -- 取得原始表的欄位定義（包含 NULL/NOT NULL 和預設值）
    SELECT @ColumnDefinitions = @ColumnDefinitions +
        '    ' + QUOTENAME(c.COLUMN_NAME) + ' ' +
        c.DATA_TYPE +
        CASE
            WHEN c.DATA_TYPE IN ('varchar', 'char', 'nvarchar', 'nchar')
            THEN '(' + CASE WHEN c.CHARACTER_MAXIMUM_LENGTH = -1
                           THEN 'MAX'
                           ELSE CAST(c.CHARACTER_MAXIMUM_LENGTH AS VARCHAR(10))
                       END + ')'
            WHEN c.DATA_TYPE IN ('decimal', 'numeric')
            THEN '(' + CAST(c.NUMERIC_PRECISION AS VARCHAR(10)) + ',' +
                      CAST(c.NUMERIC_SCALE AS VARCHAR(10)) + ')'
            WHEN c.DATA_TYPE IN ('datetime2', 'time', 'datetimeoffset')
            THEN '(' + CAST(c.DATETIME_PRECISION AS VARCHAR(10)) + ')'
            ELSE ''
        END +
        -- 保留原始表的 NULL/NOT NULL 設定
        CASE WHEN c.IS_NULLABLE = 'NO' THEN ' NOT NULL' ELSE ' NULL' END +
        -- 加入預設值
        CASE
            WHEN dc.definition IS NOT NULL
            THEN ' DEFAULT ' + dc.definition
            ELSE ''
        END +
        ',' + CHAR(13) + CHAR(10)
    FROM INFORMATION_SCHEMA.COLUMNS c
    LEFT JOIN sys.columns sc
        ON sc.object_id = @ObjectId
        AND sc.name = c.COLUMN_NAME
    LEFT JOIN sys.default_constraints dc
        ON dc.parent_object_id = @ObjectId
        AND dc.parent_column_id = sc.column_id
    WHERE c.TABLE_NAME = @TableName
      AND c.TABLE_SCHEMA = @SchemaName
    ORDER BY c.ORDINAL_POSITION;

    -- 檢查欄位定義是否為空
    IF LEN(@ColumnDefinitions) = 0
    BEGIN
        RAISERROR('錯誤: 無法取得表 %s 的欄位定義', 16, 1, @TableName);
        RETURN;
    END

    -- 移除最後一個逗號和換行
    SET @ColumnDefinitions = LEFT(@ColumnDefinitions, LEN(@ColumnDefinitions) - 3);

    -- 建立歷史表的 SQL
    SET @SQL =
        'CREATE TABLE ' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@HistoryTableName) + ' (' + CHAR(13) + CHAR(10) +
        '    [Log_id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,' + CHAR(13) + CHAR(10) +
        '    [LogType] NVARCHAR(10) NOT NULL,' + CHAR(13) + CHAR(10) +
        '    [FlowFormId] INT NULL,' + CHAR(13) + CHAR(10) +
        @ColumnDefinitions + ',' + CHAR(13) + CHAR(10) +
        '    [SysCreateDate] DATETIME NOT NULL DEFAULT GETDATE(),' + CHAR(13) + CHAR(10) +
        '    [SysCreateUser] NVARCHAR(100) NOT NULL,' + CHAR(13) + CHAR(10) +
        '    CONSTRAINT [FK_' + @HistoryTableName + '_FlowForm] FOREIGN KEY ([FlowFormId]) ' + CHAR(13) + CHAR(10) +
        '        REFERENCES ' + QUOTENAME(@SchemaName) + '.[FlowForm]([PK_ID])' + CHAR(13) + CHAR(10) +
        ');';

    BEGIN TRY
        -- 執行建立表的 SQL
        EXEC sp_executesql @SQL;
        PRINT '✓ 成功建立歷史表: ' + @HistoryTableName;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('建立歷史表失敗: %s', 16, 1, @ErrorMessage);
        RETURN;
    END CATCH

    -- ========== 加入欄位註釋 ==========
    BEGIN TRY
        EXEC sys.sp_addextendedproperty
            @name = N'MS_Description',
            @value = N'歷史記錄識別碼',
            @level0type = N'SCHEMA', @level0name = @SchemaName,
            @level1type = N'TABLE',  @level1name = @HistoryTableName,
            @level2type = N'COLUMN', @level2name = N'Log_id';

        EXEC sys.sp_addextendedproperty
            @name = N'MS_Description',
            @value = N'異動行為類型 (INSERT/UPDATE/DELETE)',
            @level0type = N'SCHEMA', @level0name = @SchemaName,
            @level1type = N'TABLE',  @level1name = @HistoryTableName,
            @level2type = N'COLUMN', @level2name = N'LogType';

        EXEC sys.sp_addextendedproperty
            @name = N'MS_Description',
            @value = N'流程表單識別碼（外鍵：FlowForm.PK_ID）',
            @level0type = N'SCHEMA', @level0name = @SchemaName,
            @level1type = N'TABLE',  @level1name = @HistoryTableName,
            @level2type = N'COLUMN', @level2name = N'FlowFormId';

        EXEC sys.sp_addextendedproperty
            @name = N'MS_Description',
            @value = N'系統建立日期時間',
            @level0type = N'SCHEMA', @level0name = @SchemaName,
            @level1type = N'TABLE',  @level1name = @HistoryTableName,
            @level2type = N'COLUMN', @level2name = N'SysCreateDate';

        EXEC sys.sp_addextendedproperty
            @name = N'MS_Description',
            @value = N'系統建立使用者',
            @level0type = N'SCHEMA', @level0name = @SchemaName,
            @level1type = N'TABLE',  @level1name = @HistoryTableName,
            @level2type = N'COLUMN', @level2name = N'SysCreateUser';

        PRINT '✓ 成功加入欄位註釋';
    END TRY
    BEGIN CATCH
        PRINT '⚠ 加入欄位註釋時發生警告: ' + ERROR_MESSAGE();
        -- 不中斷執行，只顯示警告
    END CATCH
    -- ========================================

    PRINT '========================================';
    PRINT '✓ 完成! 歷史表建立成功: ' + @HistoryTableName;
END;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_CreateHistoryTable]
    @TableName NVARCHAR(128)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @HistoryTableName NVARCHAR(128) = @TableName + '_his';
    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @ColumnDefinitions NVARCHAR(MAX) = '';
    DECLARE @SchemaName NVARCHAR(128) = 'dbo';
    -- 檢查原始表是否存在
    IF NOT EXISTS (
        SELECT 1
        FROM INFORMATION_SCHEMA.TABLES
        WHERE TABLE_NAME = @TableName
    )
    BEGIN
        RAISERROR('原始表 %s 不存在', 16, 1, @TableName);
        RETURN;
    END

    -- 檢查歷史表是否已存在
    IF EXISTS (
        SELECT 1
        FROM INFORMATION_SCHEMA.TABLES
        WHERE TABLE_NAME = @HistoryTableName
    )
    BEGIN
        RAISERROR('歷史表 %s 已經存在', 16, 1, @HistoryTableName);
        RETURN;
    END

    -- 取得原始表的欄位定義
    SELECT @ColumnDefinitions = @ColumnDefinitions +
        QUOTENAME(COLUMN_NAME) + ' ' +
        DATA_TYPE +
        CASE
            WHEN DATA_TYPE IN ('varchar', 'char', 'nvarchar', 'nchar')
            THEN '(' + CASE WHEN CHARACTER_MAXIMUM_LENGTH = -1
                           THEN 'MAX'
                           ELSE CAST(CHARACTER_MAXIMUM_LENGTH AS VARCHAR(10))
                       END + ')'
            WHEN DATA_TYPE IN ('decimal', 'numeric')
            THEN '(' + CAST(NUMERIC_PRECISION AS VARCHAR(10)) + ',' +
                      CAST(NUMERIC_SCALE AS VARCHAR(10)) + ')'
            ELSE ''
        END +
        CASE WHEN IS_NULLABLE = 'NO' THEN ' NOT NULL' ELSE ' NULL' END +
        ',' + CHAR(13) + CHAR(10)
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = @TableName
    ORDER BY ORDINAL_POSITION;

    -- 移除最後一個逗號和換行
    IF LEN(@ColumnDefinitions) > 0
    BEGIN
        SET @ColumnDefinitions = LEFT(@ColumnDefinitions, LEN(@ColumnDefinitions) - 3);
    END

    -- 建立歷史表的 SQL
    SET @SQL =
        'CREATE TABLE ' + QUOTENAME(@HistoryTableName) + ' (' + CHAR(13) + CHAR(10) +
        '    Log_Id int IDENTITY(1,1) PRIMARY KEY,' + CHAR(13) + CHAR(10) +
        '    LogType NVARCHAR(10) NOT NULL,' + CHAR(13) + CHAR(10) +
        @ColumnDefinitions + ',' + CHAR(13) + CHAR(10) +
        '    SysCreateDate DATETIME NOT NULL DEFAULT GETDATE(),' + CHAR(13) + CHAR(10) +
        '    SysCreateUser NVARCHAR(100) NOT NULL' + CHAR(13) + CHAR(10) +
        ');';
    BEGIN TRY
    -- 執行建立表的 SQL
    EXEC sp_executesql @SQL;
    PRINT '成功建立歷史表: ' + @HistoryTableName;
	END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('建立歷史表失敗: %s', 16, 1, @ErrorMessage);
        RETURN;
    END CATCH
	-- ========== 新增：加入欄位註釋 ==========
    EXEC sys.sp_addextendedproperty
        @name = N'MS_Description',
        @value = N'歷史記錄識別碼',
        @level0type = N'SCHEMA', @level0name = @SchemaName,
        @level1type = N'TABLE',  @level1name = @HistoryTableName,
        @level2type = N'COLUMN', @level2name = N'log_id';

    EXEC sys.sp_addextendedproperty
        @name = N'MS_Description',
        @value = N'異動行為類型 (INSERT/UPDATE/DELETE)',
        @level0type = N'SCHEMA', @level0name = @SchemaName,
        @level1type = N'TABLE',  @level1name = @HistoryTableName,
        @level2type = N'COLUMN', @level2name = N'log_type';

    EXEC sys.sp_addextendedproperty
        @name = N'MS_Description',
        @value = N'系統建立日期時間',
        @level0type = N'SCHEMA', @level0name = @SchemaName,
        @level1type = N'TABLE',  @level1name = @HistoryTableName,
        @level2type = N'COLUMN', @level2name = N'SysCreateDate';

    EXEC sys.sp_addextendedproperty
        @name = N'MS_Description',
        @value = N'系統建立使用者',
        @level0type = N'SCHEMA', @level0name = @SchemaName,
        @level1type = N'TABLE',  @level1name = @HistoryTableName,
        @level2type = N'COLUMN', @level2name = N'SysCreateUser';

    PRINT '✓ 成功加入欄位註釋';
    -- ========================================
    PRINT '完成!';
END;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_CreateHistoryTable_Detail]
    @TableName NVARCHAR(128)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @HistoryTableName NVARCHAR(128) = @TableName + '_his';
    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @ColumnDefinitions NVARCHAR(MAX) = '';
    DECLARE @SchemaName NVARCHAR(128) = 'dbo';
    -- 檢查原始表是否存在
    IF NOT EXISTS (
        SELECT 1
        FROM INFORMATION_SCHEMA.TABLES
        WHERE TABLE_NAME = @TableName
    )
    BEGIN
        RAISERROR('原始表 %s 不存在', 16, 1, @TableName);
        RETURN;
    END

    -- 檢查歷史表是否已存在
    IF EXISTS (
        SELECT 1
        FROM INFORMATION_SCHEMA.TABLES
        WHERE TABLE_NAME = @HistoryTableName
    )
    BEGIN
        RAISERROR('歷史表 %s 已經存在', 16, 1, @HistoryTableName);
        RETURN;
    END

    -- 取得原始表的欄位定義
    SELECT @ColumnDefinitions = @ColumnDefinitions +
        QUOTENAME(COLUMN_NAME) + ' ' +
        DATA_TYPE +
        CASE
            WHEN DATA_TYPE IN ('varchar', 'char', 'nvarchar', 'nchar')
            THEN '(' + CASE WHEN CHARACTER_MAXIMUM_LENGTH = -1
                           THEN 'MAX'
                           ELSE CAST(CHARACTER_MAXIMUM_LENGTH AS VARCHAR(10))
                       END + ')'
            WHEN DATA_TYPE IN ('decimal', 'numeric')
            THEN '(' + CAST(NUMERIC_PRECISION AS VARCHAR(10)) + ',' +
                      CAST(NUMERIC_SCALE AS VARCHAR(10)) + ')'
            ELSE ''
        END +
        CASE WHEN IS_NULLABLE = 'NO' THEN ' NOT NULL' ELSE ' NULL' END +
        ',' + CHAR(13) + CHAR(10)
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = @TableName
    ORDER BY ORDINAL_POSITION;

    -- 移除最後一個逗號和換行
    IF LEN(@ColumnDefinitions) > 0
    BEGIN
        SET @ColumnDefinitions = LEFT(@ColumnDefinitions, LEN(@ColumnDefinitions) - 3);
    END

    -- 建立歷史表的 SQL
    SET @SQL =
        'CREATE TABLE ' + QUOTENAME(@HistoryTableName) + ' (' + CHAR(13) + CHAR(10) +
        '    Log_id int IDENTITY(1,1) PRIMARY KEY,' + CHAR(13) + CHAR(10) +
        '    LogType NVARCHAR(10) NOT NULL,' + CHAR(13) + CHAR(10) +
		'	 Fk_logId Int NOT NULL,' + CHAR(13) + CHAR(10) +
        @ColumnDefinitions + ',' + CHAR(13) + CHAR(10) +
        '    SysCreateDate DATETIME NOT NULL DEFAULT GETDATE(),' + CHAR(13) + CHAR(10) +
        '    SysCreateUser NVARCHAR(100) NOT NULL' + CHAR(13) + CHAR(10) +
        ');';
    BEGIN TRY
    -- 執行建立表的 SQL
    EXEC sp_executesql @SQL;
    PRINT '成功建立歷史表: ' + @HistoryTableName;
	END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('建立歷史表失敗: %s', 16, 1, @ErrorMessage);
        RETURN;
    END CATCH
	-- ========== 新增：加入欄位註釋 ==========
    EXEC sys.sp_addextendedproperty
        @name = N'MS_Description',
        @value = N'歷史記錄識別碼',
        @level0type = N'SCHEMA', @level0name = @SchemaName,
        @level1type = N'TABLE',  @level1name = @HistoryTableName,
        @level2type = N'COLUMN', @level2name = N'log_id';

    EXEC sys.sp_addextendedproperty
        @name = N'MS_Description',
        @value = N'異動行為類型 (INSERT/UPDATE/DELETE)',
        @level0type = N'SCHEMA', @level0name = @SchemaName,
        @level1type = N'TABLE',  @level1name = @HistoryTableName,
        @level2type = N'COLUMN', @level2name = N'LogType';

    EXEC sys.sp_addextendedproperty
        @name = N'MS_Description',
        @value = N'系統建立日期時間',
        @level0type = N'SCHEMA', @level0name = @SchemaName,
        @level1type = N'TABLE',  @level1name = @HistoryTableName,
        @level2type = N'COLUMN', @level2name = N'SysCreateDate';

    EXEC sys.sp_addextendedproperty
        @name = N'MS_Description',
        @value = N'系統建立使用者',
        @level0type = N'SCHEMA', @level0name = @SchemaName,
        @level1type = N'TABLE',  @level1name = @HistoryTableName,
        @level2type = N'COLUMN', @level2name = N'SysCreateUser';

    PRINT '✓ 成功加入欄位註釋';
    -- ========================================
    PRINT '完成!';
END;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_CreateTempTable]
    @TableName NVARCHAR(128)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TempTableName NVARCHAR(128) = @TableName + '_temp';
    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @ColumnDefinitions NVARCHAR(MAX) = '';
    DECLARE @SchemaName NVARCHAR(128) = 'dbo';
    DECLARE @ObjectId INT;

    -- 檢查原始表是否存在
    IF NOT EXISTS (
        SELECT 1
        FROM INFORMATION_SCHEMA.TABLES
        WHERE TABLE_NAME = @TableName
          AND TABLE_SCHEMA = @SchemaName
    )
    BEGIN
        RAISERROR('原始表 %s 不存在', 16, 1, @TableName);
        RETURN;
    END

    -- 取得 Object ID
    SET @ObjectId = OBJECT_ID(@SchemaName + '.' + @TableName);

    IF @ObjectId IS NULL
    BEGIN
        RAISERROR('無法取得表 %s 的 Object ID', 16, 1, @TableName);
        RETURN;
    END

    -- 檢查 Temp 表是否已存在
    IF EXISTS (
        SELECT 1
        FROM INFORMATION_SCHEMA.TABLES
        WHERE TABLE_NAME = @TempTableName
          AND TABLE_SCHEMA = @SchemaName
    )
    BEGIN
        RAISERROR('Temp 表 %s 已經存在', 16, 1, @TempTableName);
        RETURN;
    END

    -- 檢查 FlowForm 表是否存在
    IF NOT EXISTS (
        SELECT 1
        FROM INFORMATION_SCHEMA.TABLES
        WHERE TABLE_NAME = 'FlowForm'
          AND TABLE_SCHEMA = @SchemaName
    )
    BEGIN
        RAISERROR('FlowForm 表不存在，無法建立外鍵', 16, 1);
        RETURN;
    END

    -- 取得原始表的欄位定義（包含 NULL/NOT NULL 和預設值）
    SELECT @ColumnDefinitions = @ColumnDefinitions +
        '    ' + QUOTENAME(c.COLUMN_NAME) + ' ' +
        c.DATA_TYPE +
        CASE
            WHEN c.DATA_TYPE IN ('varchar', 'char', 'nvarchar', 'nchar')
            THEN '(' + CASE WHEN c.CHARACTER_MAXIMUM_LENGTH = -1
                           THEN 'MAX'
                           ELSE CAST(c.CHARACTER_MAXIMUM_LENGTH AS VARCHAR(10))
                       END + ')'
            WHEN c.DATA_TYPE IN ('decimal', 'numeric')
            THEN '(' + CAST(c.NUMERIC_PRECISION AS VARCHAR(10)) + ',' +
                      CAST(c.NUMERIC_SCALE AS VARCHAR(10)) + ')'
            WHEN c.DATA_TYPE IN ('datetime2', 'time', 'datetimeoffset')
            THEN '(' + CAST(c.DATETIME_PRECISION AS VARCHAR(10)) + ')'
            ELSE ''
        END +
        -- 保留原始表的 NULL/NOT NULL 設定
        CASE WHEN c.IS_NULLABLE = 'NO' THEN ' NOT NULL' ELSE ' NULL' END +
        -- 加入預設值
        CASE
            WHEN dc.definition IS NOT NULL
            THEN ' DEFAULT ' + dc.definition
            ELSE ''
        END +
        ',' + CHAR(13) + CHAR(10)
    FROM INFORMATION_SCHEMA.COLUMNS c
    LEFT JOIN sys.columns sc
        ON sc.object_id = @ObjectId
        AND sc.name = c.COLUMN_NAME
    LEFT JOIN sys.default_constraints dc
        ON dc.parent_object_id = @ObjectId
        AND dc.parent_column_id = sc.column_id
    WHERE c.TABLE_NAME = @TableName
      AND c.TABLE_SCHEMA = @SchemaName
    ORDER BY c.ORDINAL_POSITION;

    -- 檢查欄位定義是否為空
    IF LEN(@ColumnDefinitions) = 0
    BEGIN
        RAISERROR('錯誤: 無法取得表 %s 的欄位定義', 16, 1, @TableName);
        RETURN;
    END

    -- 移除最後一個逗號和換行
    SET @ColumnDefinitions = LEFT(@ColumnDefinitions, LEN(@ColumnDefinitions) - 3);

    -- 建立 Temp 表的 SQL
    SET @SQL =
        'CREATE TABLE ' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TempTableName) + ' (' + CHAR(13) + CHAR(10) +
        '    [TempId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,' + CHAR(13) + CHAR(10) +
        '    [FlowFormId] INT NULL,' + CHAR(13) + CHAR(10) +
        '    [ModifyType] NVARCHAR(10) NOT NULL,' + CHAR(13) + CHAR(10) +
        @ColumnDefinitions + ',' + CHAR(13) + CHAR(10) +
        '    [SysCreateDate] DATETIME NOT NULL DEFAULT GETDATE(),' + CHAR(13) + CHAR(10) +
        '    [SysCreateUser] NVARCHAR(100) NOT NULL,' + CHAR(13) + CHAR(10) +
        '    CONSTRAINT [FK_' + @TempTableName + '_FlowForm] FOREIGN KEY ([FlowFormId]) ' + CHAR(13) + CHAR(10) +
        '        REFERENCES ' + QUOTENAME(@SchemaName) + '.[FlowForm]([PK_ID])' + CHAR(13) + CHAR(10) +
        ');';

    BEGIN TRY
        -- 執行建立表的 SQL
        EXEC sp_executesql @SQL;
        PRINT '✓ 成功建立 Temp 表: ' + @TempTableName;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('建立 Temp 表失敗: %s', 16, 1, @ErrorMessage);
        RETURN;
    END CATCH

    -- ========== 加入欄位註釋 ==========
    BEGIN TRY
        EXEC sys.sp_addextendedproperty
            @name = N'MS_Description',
            @value = N'暫存資料識別碼（流水號）',
            @level0type = N'SCHEMA', @level0name = @SchemaName,
            @level1type = N'TABLE',  @level1name = @TempTableName,
            @level2type = N'COLUMN', @level2name = N'TempId';

        EXEC sys.sp_addextendedproperty
            @name = N'MS_Description',
            @value = N'流程表單識別碼（外鍵：FlowForm.PK_ID）',
            @level0type = N'SCHEMA', @level0name = @SchemaName,
            @level1type = N'TABLE',  @level1name = @TempTableName,
            @level2type = N'COLUMN', @level2name = N'FlowFormId';

        PRINT '✓ 成功加入欄位註釋';
    END TRY
    BEGIN CATCH
        PRINT '⚠ 加入欄位註釋時發生警告: ' + ERROR_MESSAGE();
    END CATCH

    PRINT '========================================';
    PRINT '✓ 完成! Temp 表建立成功: ' + @TempTableName;
END;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_CreateTempTable_Detail]
    @TableName NVARCHAR(128)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TempTableName NVARCHAR(128) = @TableName + '_temp';
    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @ColumnDefinitions NVARCHAR(MAX) = '';
    DECLARE @SchemaName NVARCHAR(128) = 'dbo';
    DECLARE @ObjectId INT;

    -- 檢查原始表是否存在
    IF NOT EXISTS (
        SELECT 1
        FROM INFORMATION_SCHEMA.TABLES
        WHERE TABLE_NAME = @TableName
          AND TABLE_SCHEMA = @SchemaName
    )
    BEGIN
        RAISERROR('原始表 %s 不存在', 16, 1, @TableName);
        RETURN;
    END

    -- 取得 Object ID
    SET @ObjectId = OBJECT_ID(@SchemaName + '.' + @TableName);

    IF @ObjectId IS NULL
    BEGIN
        RAISERROR('無法取得表 %s 的 Object ID', 16, 1, @TableName);
        RETURN;
    END

    -- 檢查 Temp 表是否已存在
    IF EXISTS (
        SELECT 1
        FROM INFORMATION_SCHEMA.TABLES
        WHERE TABLE_NAME = @TempTableName
          AND TABLE_SCHEMA = @SchemaName
    )
    BEGIN
        RAISERROR('Temp 表 %s 已經存在', 16, 1, @TempTableName);
        RETURN;
    END

    -- 取得原始表的欄位定義（包含預設值，但強制所有欄位為 NULL）
    SELECT @ColumnDefinitions = @ColumnDefinitions +
        '    ' + QUOTENAME(c.COLUMN_NAME) + ' ' +
        c.DATA_TYPE +
        CASE
            WHEN c.DATA_TYPE IN ('varchar', 'char', 'nvarchar', 'nchar')
            THEN '(' + CASE WHEN c.CHARACTER_MAXIMUM_LENGTH = -1
                           THEN 'MAX'
                           ELSE CAST(c.CHARACTER_MAXIMUM_LENGTH AS VARCHAR(10))
                       END + ')'
            WHEN c.DATA_TYPE IN ('decimal', 'numeric')
            THEN '(' + CAST(c.NUMERIC_PRECISION AS VARCHAR(10)) + ',' +
                      CAST(c.NUMERIC_SCALE AS VARCHAR(10)) + ')'
            WHEN c.DATA_TYPE IN ('datetime2', 'time', 'datetimeoffset')
            THEN '(' + CAST(c.DATETIME_PRECISION AS VARCHAR(10)) + ')'
            ELSE ''
        END +
        -- 強制所有欄位為 NULL
        ' NULL' +
        -- 加入預設值
        CASE
            WHEN dc.definition IS NOT NULL
            THEN ' DEFAULT ' + dc.definition
            ELSE ''
        END +
        ',' + CHAR(13) + CHAR(10)
    FROM INFORMATION_SCHEMA.COLUMNS c
    LEFT JOIN sys.columns sc
        ON sc.object_id = @ObjectId
        AND sc.name = c.COLUMN_NAME
    LEFT JOIN sys.default_constraints dc
        ON dc.parent_object_id = @ObjectId
        AND dc.parent_column_id = sc.column_id
    WHERE c.TABLE_NAME = @TableName
      AND c.TABLE_SCHEMA = @SchemaName
    ORDER BY c.ORDINAL_POSITION;

    -- 檢查欄位定義是否為空
    IF LEN(@ColumnDefinitions) = 0
    BEGIN
        RAISERROR('錯誤: 無法取得表 %s 的欄位定義', 16, 1, @TableName);
        RETURN;
    END

    -- 移除最後一個逗號和換行
    SET @ColumnDefinitions = LEFT(@ColumnDefinitions, LEN(@ColumnDefinitions) - 3);

    -- 建立 Temp 表的 SQL
    SET @SQL =
        'CREATE TABLE ' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TempTableName) + ' (' + CHAR(13) + CHAR(10) +
        '    [TempId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,' + CHAR(13) + CHAR(10) +
        '    [FK_TempId] INT NOT NULL,' + CHAR(13) + CHAR(10) +
        '    [ModifyType] NVARCHAR(10) NOT NULL,' + CHAR(13) + CHAR(10) +
        @ColumnDefinitions + ',' + CHAR(13) + CHAR(10) +
        '    [SysCreateDate] DATETIME NOT NULL DEFAULT GETDATE(),' + CHAR(13) + CHAR(10) +
        '    [SysCreateUser] NVARCHAR(100) NOT NULL' + CHAR(13) + CHAR(10) +
        ');';

    BEGIN TRY
        -- 執行建立表的 SQL
        EXEC sp_executesql @SQL;
        PRINT '✓ 成功建立 Temp 表: ' + @TempTableName;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('建立 Temp 表失敗: %s', 16, 1, @ErrorMessage);
        RETURN;
    END CATCH

    -- ========== 加入欄位註釋 ==========
    BEGIN TRY
        EXEC sys.sp_addextendedproperty
            @name = N'MS_Description',
            @value = N'暫存資料識別碼（流水號）',
            @level0type = N'SCHEMA', @level0name = @SchemaName,
            @level1type = N'TABLE',  @level1name = @TempTableName,
            @level2type = N'COLUMN', @level2name = N'TempId';

        EXEC sys.sp_addextendedproperty
            @name = N'MS_Description',
            @value = N'主表暫存資料外鍵',
            @level0type = N'SCHEMA', @level0name = @SchemaName,
            @level1type = N'TABLE',  @level1name = @TempTableName,
            @level2type = N'COLUMN', @level2name = N'FK_TempId';

        EXEC sys.sp_addextendedproperty
            @name = N'MS_Description',
            @value = N'異動類型',
            @level0type = N'SCHEMA', @level0name = @SchemaName,
            @level1type = N'TABLE',  @level1name = @TempTableName,
            @level2type = N'COLUMN', @level2name = N'ModifyType';

        EXEC sys.sp_addextendedproperty
            @name = N'MS_Description',
            @value = N'系統建立日期時間',
            @level0type = N'SCHEMA', @level0name = @SchemaName,
            @level1type = N'TABLE',  @level1name = @TempTableName,
            @level2type = N'COLUMN', @level2name = N'SysCreateDate';

        EXEC sys.sp_addextendedproperty
            @name = N'MS_Description',
            @value = N'系統建立使用者',
            @level0type = N'SCHEMA', @level0name = @SchemaName,
            @level1type = N'TABLE',  @level1name = @TempTableName,
            @level2type = N'COLUMN', @level2name = N'SysCreateUser';

        PRINT '✓ 成功加入欄位註釋';
    END TRY
    BEGIN CATCH
        PRINT '⚠ 加入欄位註釋時發生警告: ' + ERROR_MESSAGE();
        -- 不中斷執行，只顯示警告
    END CATCH
    -- ========================================

    PRINT '========================================';
    PRINT '✓ 完成! Temp 表建立成功: ' + @TempTableName;
END;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- 取代原本 usp_GetGroupId 呼叫端的誤用。
-- 改用OUTPUT參數，並將SELECT與UPDATE包在同一顯式交易內，搭配UPDLOCK/ROWLOCK/HOLDLOCK使鎖定延續到交易結束，避免併發呼叫取得重複GroupId。
CREATE   PROCEDURE [dbo].[usp_GetGroupId]
    @GroupName NVARCHAR(50),
    @NewGroupId INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;

    SELECT @NewGroupId = GroupCount
    FROM GroupIdCounter WITH (UPDLOCK, ROWLOCK, HOLDLOCK)
    WHERE GroupName = @GroupName;

    IF @NewGroupId IS NULL
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 51000, 'GroupIdCounter 查無對應 GroupName', 1;
        RETURN;
    END

    UPDATE GroupIdCounter
    SET GroupCount = GroupCount + 1
    WHERE GroupName = @GroupName;

    COMMIT TRANSACTION;
END;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Allenchen
-- Create date: 2025/11/13
-- Description:	HRIS 洗資料 -- 分行
-- =============================================
CREATE PROCEDURE [dbo].[usp_HRIS_Transfer_BankBranch]
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		declare @Automatic nvarchar(2) = '自動',
				@Manual nvarchar(2) = '手動'

		DECLARE @H077050000_Id INT = (SELECT PK_Id FROM BankUnit WHERE UnitCode = 'H077050000'); -- 海業處 id
		DECLARE @FB009 INT = (SELECT PK_Id FROM BankUnit WHERE UnitCode = 'FB009'); -- 分行營業單位

		-- 分行沒有的新增 ，有就修改 ，HRIS沒有就停用
		MERGE INTO BankBranch AS Target
		USING (Select DISTINCT UnitBranchCode,UnitBranchName,
			   CASE WHEN Left(UnitBranchCode,2) = 'B9' OR Left(UnitBranchCode,4) = 'B095'
			   THEN @H077050000_Id
			   ELSE @FB009
			   END FK_BankUnit
			   FROM HRIS_Origin
			   Where GroupCode = 'FB009'
		) AS Source
		ON Target.BankCode = Source.UnitBranchCode
		WHEN MATCHED AND (BankName_TN <> Source.UnitBranchName OR ((Left(UnitBranchCode,2) = 'B9' OR Left(UnitBranchCode,4) = 'B095') AND IsActive = 0) OR
				(Source.UnitBranchName LIKE N'%辦事處%' AND IsActive = 1 AND Target.Memo <> @Manual AND Target.IsSave <> 1) OR
				ISNULL(Target.FK_BankUnit,'') <> ISNULL(Source.FK_BankUnit,''))
		THEN
			UPDATE SET FK_BankUnit = Source.FK_BankUnit,
						IsActive = CASE WHEN UnitBranchName LIKE N'%辦事處%' AND Target.Memo <> @Manual AND Target.IsSave <> 1
							      THEN 0
								  WHEN Left(UnitBranchCode,2) = 'B9' OR Left(UnitBranchCode,4) = 'B095'
								  THEN 1
								  ELSE IsActive
								  END,
						IsEmployed = 1,
					BankName_TN = UnitBranchName, Memo = @Automatic,Update_date = getdate(),Update_user = 'system'
		WHEN NOT MATCHED BY TARGET
		THEN
			INSERT (FK_BankUnit,BankCode,BankName_TN,BankName_EN,BankName_JP,BankName_CN,IsActive,IsSave,IsEmployed,Memo)
			VALUES (FK_BankUnit,Source.UnitBranchCode, Source.UnitBranchName, Source.UnitBranchName, Source.UnitBranchName, Source.UnitBranchName,
			CASE WHEN UnitBranchName LIKE N'%辦事處%'
			THEN 0
			WHEN Left(UnitBranchCode,2) = 'B9' OR Left(UnitBranchCode,4) = 'B095'
			THEN 1
			ELSE 0
			END,0,1, @Automatic)
		WHEN NOT MATCHED BY SOURCE and Target.Memo <> @Manual and Target.IsSave <> 1 AND  Target.IsActive <> 0
		THEN
			UPDATE SET IsActive = 0,IsEmployed = 0,Memo = @Automatic,Update_date = getdate(),Update_user = 'system'

		OUTPUT $action,isnull(deleted.PK_Id,inserted.PK_Id),isnull(deleted.FK_BankUnit,inserted.FK_BankUnit),
		isnull(deleted.BankCode,inserted.BankCode),isnull(deleted.BankName_TN,inserted.BankName_TN),
		isnull(deleted.BankName_EN,inserted.BankName_EN),isnull(deleted.BankName_CN,inserted.BankName_CN),
		isnull(deleted.BankName_JP,inserted.BankName_JP),isnull(deleted.Latitude,inserted.Latitude),
		isnull(deleted.Longitude,inserted.Longitude),isnull(deleted.IsActive,inserted.IsActive),
		isnull(deleted.IsSave,inserted.IsSave),isnull(deleted.IsEmployed,inserted.IsEmployed),
		isnull(deleted.Memo,inserted.Memo),isnull(deleted.Update_date,inserted.Update_date),
		isnull(deleted.Update_user,inserted.Update_user),isnull(deleted.Create_date,inserted.Create_date),
		isnull(deleted.Create_user,inserted.Create_user)
		INTO BankBranch_log(LogType,PK_Id,FK_BankUnit,BankCode,BankName_TN,BankName_EN,BankName_CN,BankName_JP,Latitude,Longitude,
		IsActive,IsSave,IsEmployed,Memo,Update_date,Update_user,Create_date,Create_user);

		  -- 🔑 回傳影響的記錄數
        DECLARE @AffectedRows INT = @@ROWCOUNT;
        PRINT '成功處理 ' + CAST(@AffectedRows AS NVARCHAR) + ' 筆記錄';

	END TRY
	BEGIN CATCH
		DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorLine INT = ERROR_LINE();

        PRINT '發生錯誤於第 ' + CAST(@ErrorLine AS NVARCHAR) + ' 行: ' + @ErrorMsg;
		THROW;
	END CATCH
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Allenchen
-- Create date: 2025/11/13
-- Description:	HRIS 洗資料 -- 事業群
-- =============================================
CREATE PROCEDURE [dbo].[usp_HRIS_Transfer_BankGroup]
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- 宣告變數
        DECLARE @Automatic NVARCHAR(10) = '自動';
        DECLARE @Manual NVARCHAR(10) = '手動';


        -- 事業群沒有的新增,名稱有差異就修改,HRIS沒有就停用
        MERGE INTO BankGroup AS t
        USING (SELECT DISTINCT GroupCode, GroupName FROM HRIS_Origin) AS s
        ON t.GroupCode = s.GroupCode

        -- MATCHED
        WHEN MATCHED AND t.GroupName_TN <> s.GroupName and t.IsEmployed = 0
        THEN
            UPDATE SET
                GroupName_TN = s.GroupName,
				IsEmployed = 1,
                Memo = @Automatic,
                Update_date = GETDATE(),
                Update_user = 'system'
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (GroupCode, GroupName_TN, GroupName_EN, GroupName_JP, GroupName_CN, IsActive,IsEmployed,IsBusinessUnit, Memo, Create_date, Create_user)
            VALUES (
                s.GroupCode,
                s.GroupName,
                s.GroupName,
                s.GroupName,
                s.GroupName,
                0,
				1,
				0,
                @Automatic,
                GETDATE(),
                'system'
            )
        -- NOT MATCHED BY SOURCE: 停用 (排除系統群組)
        WHEN NOT MATCHED BY SOURCE
        THEN
            UPDATE SET IsEmployed = 0,Memo = @Automatic,Update_date = GETDATE(),Update_user = 'system'
        -- 輸出到備份表
        OUTPUT
            $action,
            ISNULL(deleted.PK_Id, inserted.PK_Id),
            ISNULL(deleted.GroupCode, inserted.GroupCode),
            ISNULL(deleted.GroupName_EN, inserted.GroupName_EN),
            ISNULL(deleted.GroupName_TN, inserted.GroupName_TN),
            ISNULL(deleted.GroupName_CN, inserted.GroupName_CN),
            ISNULL(deleted.GroupName_JP, inserted.GroupName_JP),
            ISNULL(deleted.IsActive, inserted.IsActive),
			ISNULL(deleted.IsEmployed, inserted.IsEmployed),
			ISNULL(deleted.IsBusinessUnit, inserted.IsBusinessUnit),
            ISNULL(deleted.Memo, inserted.Memo),
            ISNULL(deleted.Update_date, inserted.Update_date),
            ISNULL(deleted.Update_user, inserted.Update_user),
            ISNULL(deleted.Create_date, inserted.Create_date),
            ISNULL(deleted.Create_user, inserted.Create_user)
        INTO BankGroup_log(logType, PK_Id, GroupCode, GroupName_EN, GroupName_TN, GroupName_CN, GroupName_JP,
            IsActive,IsEmployed,IsBusinessUnit,Memo, Update_date, Update_user, Create_date, Create_user
        );

        -- 🔑 新增:回傳影響的記錄數
        DECLARE @AffectedRows INT = @@ROWCOUNT;
        PRINT '成功處理 ' + CAST(@AffectedRows AS NVARCHAR) + ' 筆記錄';

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorLine INT = ERROR_LINE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        -- 記錄錯誤到 SysLog (如果有的話)
        PRINT '發生錯誤於第 ' + CAST(@ErrorLine AS NVARCHAR) + ' 行: ' + @ErrorMsg;

        -- 重新拋出錯誤
        THROW;
    END CATCH
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Allenchen
-- Create date: 2025/11/13
-- Description:	HRIS 洗資料 -- 處級
-- Modified:    2026/01/21 - 優化效能,使用 Table Variable
-- =============================================
CREATE PROCEDURE [dbo].[usp_HRIS_Transfer_BankUnit]
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- 宣告變數
        DECLARE @Automatic NVARCHAR(10) = '自動';
        DECLARE @Manual NVARCHAR(10) = '手動';

        -- 處級沒有的新增,有就修改,HRIS沒有就停用
        MERGE INTO BankUnit AS t
        USING (
            SELECT DISTINCT
                CASE WHEN a.GroupCode = 'FB009' then b.GroupCode else a.UnitBranchCode end UnitBranchCode,
				CASE WHEN a.GroupCode = 'FB009' then b.GroupName_TN else a.UnitBranchName end UnitBranchName,
                b.PK_Id AS BankGroupId
            FROM HRIS_Origin a
            INNER JOIN BankGroup b ON a.GroupCode = b.GroupCode
        ) AS s
        ON t.UnitCode = s.UnitBranchCode

        -- MATCHED: 系統單位被停用 OR 名稱有變化
        WHEN MATCHED AND (t.FK_BankGroup <> s.BankGroupId OR t.UnitName_TN <> s.UnitBranchName OR t.IsEmployed = 0)  -- 名稱有變化
        THEN
            UPDATE SET
				FK_BankGroup = s.BankGroupId,
                UnitName_TN = s.UnitBranchName,
				IsEmployed = 1,
                Memo = @Automatic,
                Update_date = GETDATE(),
                Update_user = 'system'

        -- NOT MATCHED BY TARGET: 新增 (系統單位預設啟用)
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (
                FK_BankGroup, UnitCode, UnitName_TN, UnitName_EN, UnitName_JP, UnitName_CN,
                IsActive,IsEmployed,IsMain,IsBusinessUnit, Memo, Create_date, Create_user
            )
            VALUES (
                s.BankGroupId,
                s.UnitBranchCode,
                s.UnitBranchName,
                s.UnitBranchName,
                s.UnitBranchName,
                s.UnitBranchName,
                0,0,0,0,
                @Automatic,
                GETDATE(),
                'system'
            )

        -- NOT MATCHED BY SOURCE: 停用 (排除手動維護的和系統單位)
        WHEN NOT MATCHED BY SOURCE and t.IsSave <> 1
        THEN
            UPDATE SET
                IsEmployed = 0,
                Memo = @Automatic,
                Update_date = GETDATE(),
                Update_user = 'system'
        -- 輸出到歷史表
        OUTPUT
            $action,
            ISNULL(deleted.PK_Id, inserted.PK_Id),
            ISNULL(deleted.FK_BankGroup, inserted.FK_BankGroup),
            ISNULL(deleted.UnitCode, inserted.UnitCode),
            ISNULL(deleted.UnitName_EN, inserted.UnitName_EN),
            ISNULL(deleted.UnitName_TN, inserted.UnitName_TN),
            ISNULL(deleted.UnitName_CN, inserted.UnitName_CN),
            ISNULL(deleted.UnitName_JP, inserted.UnitName_JP),
            ISNULL(deleted.IsMain, inserted.IsMain),
            ISNULL(deleted.IsActive, inserted.IsActive),
			ISNULL(deleted.IsSave, inserted.IsSave),
			ISNULL(deleted.IsEmployed, inserted.IsEmployed),
			ISNULL(deleted.IsBusinessUnit, inserted.IsBusinessUnit),
            ISNULL(deleted.Memo, inserted.Memo),
            ISNULL(deleted.Update_date, inserted.Update_date),
            ISNULL(deleted.Update_user, inserted.Update_user),
            ISNULL(deleted.Create_date, inserted.Create_date),
            ISNULL(deleted.Create_user, inserted.Create_user)
        INTO BankUnit_log(
            logType, PK_Id, FK_BankGroup, UnitCode, UnitName_EN, UnitName_TN, UnitName_CN, UnitName_JP,
            IsMain, IsActive,IsSave,IsEmployed,IsBusinessUnit, Memo, Update_date, Update_user, Create_date, Create_user
        );

        -- 🔑 回傳影響的記錄數
        DECLARE @AffectedRows INT = @@ROWCOUNT;
        PRINT '成功處理 ' + CAST(@AffectedRows AS NVARCHAR) + ' 筆記錄';

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorLine INT = ERROR_LINE();

        PRINT '發生錯誤於第 ' + CAST(@ErrorLine AS NVARCHAR) + ' 行: ' + @ErrorMsg;
        THROW;
    END CATCH
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		allenchen
-- Create date: 2025/11/06
-- Description:	將HRIS_ORG 資料 轉成 Users Table資料
-- =============================================
CREATE PROCEDURE [dbo].[usp_HRIS_Transfer_Users]
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

		DROP TABLE IF EXISTS #TransferUsers
		SELECT UserId,UserName,'i'+SUBSTRING(UserId, PATINDEX('%[^0]%', UserId),5)+ '@FirstBank.com.tw' Email,
				isnull(g.GroupCode,a.GroupCode) GroupCode,isnull(d.UnitCode,b.UnitCode) UnitCode,c.BankCode,
				DepartmentCode,DepartmentName,Chief Chief,f.PK_Id TitleCode,e.TitleName,
				a.Leave_Start,a.Leave_End,a.Acting_Person
		INTO #TransferUsers
		FROM(
				Select *
				From HRIS_Origin a
				WHERE NOT EXISTS (SELECT 1 FROM Global WHERE GroupId = 'HRIS_Filter_JobTitleCode' and Code = a.JobTitleCode) -- 排除不要轉入
			) a
		LEFT JOIN BankUnit b on a.UnitBranchCode = b.UnitCode
		LEFT JOIN BankBranch c on a.UnitBranchCode = c.BankCode
		LEFT JOIN BankUnit d on c.FK_BankUnit = d.PK_Id
		LEFT JOIN BankGroup g on d.FK_BankGroup = g.PK_Id
		INNER JOIN TitleMapping e on a.TitleCode = e.TitleCode
		INNER JOIN Title f on e.TitleId = f.PK_Id
		---------------------------------------------------------
		Declare @UserChange nvarchar(10) = '調/升/復職',
				@UserLeave nvarchar(10) = '離職',
				@UserAdd nvarchar(10)  = '新進員工',
				@Update nvarchar(10) = '更新資訊'
		DROP TABLE IF EXISTS #Users_his;
		SELECT * INTO #Users_his FROM Users_log WHERE 1=0

		Merge INTO Users as Target
		USING #TransferUsers as Source
		ON Target.UserId = Source.UserId
		--  調/升/復職 、 更新資訊
		WHEN MATCHED
		THEN
			UPDATE SET IsEmployed = 1,IsActive = 1,
				GroupCode = Source.GroupCode,
				UnitCode = Source.UnitCode,
				BranchCode = Source.BankCode,
				departmentCode = Source.departmentCode,
				departmentName = Source.departmentName,
				TitleCode = Source.TitleCode,
				TitleName = Source.TitleName,
				UserName = Source.UserName,
				Chief = Source.Chief,
				Leave_Start = Source.Leave_Start,
				Leave_End = Source.Leave_End,
				Acting_Person = Source.Acting_Person,
				Update_date = Getdate(),
				Update_user = 'system',
				Memo = case when Target.GroupCode <> Source.GroupCode OR
							ISNULL(Target.UnitCode,'') <> ISNULL(Source.UnitCode,'') OR
							ISNULL(Target.BranchCode,'') <> ISNULL(Source.BankCode,'') OR
							ISNULL(Target.departmentCode,'') <> ISNULL(Source.departmentCode,'') OR
							ISNULL(Target.TitleName,'') <> ISNULL(Source.TitleName,'') OR
							Target.IsEmployed = 0
						then @UserChange
						else @Update
						end
		-- 新進員工
		WHEN NOT MATCHED BY TARGET
		THEN
			INSERT (UserId,UserName,Email,GroupCode,UnitCode,BranchCode,DepartmentCode,DepartmentName,Chief,TitleCode,TitleName,IsActive
				,IsEmployed,Leave_Start,Leave_End,Acting_Person,Create_date,Update_date,Update_user,Memo)
			Values (UserId,UserName,Email,GroupCode,UnitCode,BankCode,DepartmentCode,DepartmentName,Chief,TitleCode,TitleName,1
				,1,Leave_Start,Leave_End,Acting_Person,getdate(),getdate(),'system',@UserAdd)
		-- 離職
		WHEN NOT MATCHED BY SOURCE AND TARGET.IsEmployed <> 0
		THEN
			UPDATE SET Target.IsEmployed = 0,
				Target.IsActive = 0,
				Update_date = Getdate(),
				Update_user = 'system',
				Memo = @UserLeave

		Output $action,
			isnull(deleted.UserId,inserted.UserId),
			isnull(deleted.UserName,inserted.UserName),
			isnull(deleted.Email,inserted.Email),
			isnull(deleted.GroupCode,inserted.GroupCode),
			isnull(deleted.UnitCode,inserted.UnitCode),
			isnull(deleted.BranchCode,inserted.BranchCode),
			isnull(deleted.departmentCode,inserted.departmentCode),
			isnull(deleted.departmentName,inserted.departmentName),
			isnull(deleted.Chief,inserted.Chief),
			isnull(deleted.TitleCode,inserted.TitleCode),
			isnull(deleted.TitleName,inserted.TitleName),
			isnull(deleted.IsActive,inserted.IsActive),
			isnull(deleted.IsEmployed,inserted.IsEmployed),
			isnull(deleted.Leave_Start,inserted.Leave_Start),
			isnull(deleted.Leave_End,inserted.Leave_End),
			isnull(deleted.Acting_Person,inserted.Acting_Person),
			isnull(deleted.Create_date,inserted.Create_date),
			isnull(deleted.Update_date,inserted.Update_date),
			isnull(deleted.Update_User,inserted.Update_User),
			inserted.Memo,
			getdate()
		INTO #Users_his(logType,UserId,UserName,Email,GroupCode,UnitCode,BranchCode,departmentCode,departmentName,
						Chief,TitleCode,TitleName,IsActive,IsEmployed,Leave_Start,Leave_End,Acting_Person,Create_date,
						Update_date,Update_User,Memo,SysCreateDate);
		Insert Users_log
		SELECT *
		FROM #Users_his

		SELECT *
		FROM #Users_his

	END TRY
	BEGIN CATCH
		DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT '發生錯誤: ' + @ErrorMsg;
		THROW;
	END CATCH

END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		AllenChen
-- Create date: 2025/10/17
-- Description:	01OBBS海外債券(OSBDKF02_MF) 轉檔，根據分行交易最大日期

-- =============================================
CREATE PROCEDURE [dbo].[usp_Souce01_OBBS_By_OSBDKF02_MF] @EXT_DATE AS DATE
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

	DECLARE @BufferDate INT = 14; -- 到期日緩衝時間

	WITH temp AS (
		SELECT *
		FROM OSBDKF02_MF
		WHERE TRIM(OSBDKF02_ISSUER_COUNTRY) <> 'TW' AND
			-- 檢查是否為最新資料
			EXISTS (
				SELECT 1
				FROM (
					SELECT OSBDKF02_BRANCH_NO, MAX(OSBDKF02_EXT_DATE) AS MAX_DATE
					FROM OSBDKF02_MF
					WHERE OSBDKF02_EXT_DATE <= @EXT_DATE
					GROUP BY OSBDKF02_BRANCH_NO
				) Latest
				WHERE
					OSBDKF02_MF.OSBDKF02_BRANCH_NO = Latest.OSBDKF02_BRANCH_NO AND
					OSBDKF02_MF.OSBDKF02_EXT_DATE = Latest.MAX_DATE
			) AND
			LEFT(OSBDKF02_AC_9, 5) not in ('22501','13007') AND --文件編號：D211150
			(OSBDKF02_MATURITY_DATE IS NULL OR DATEADD(DAY,@BufferDate,OSBDKF02_MATURITY_DATE) >= @EXT_DATE)

	)
	INSERT INTO MonitorData (
	    BRANCH_NO, UNIT_NO, PRODUCT_TYPE, TRAN_NO, GROUP_NO, TX_DATE,
	    CUSTOMER_NAME, CUSTOMER_ID, COUNTRY_COD, CURENCY_COD, TRAN_AMOUNT,
	    PERMIT_NO, LIMIT, LIMIT_COD, MATURITY_DATE, AS_OF_DATE,  FIL9,
	    SOURCE, CREATOR, LIMIT_MATURITY,INDUSTRY,INDUSTRY_Type,EXT_DATE)
	SELECT
		TRIM(OSBDKF02_BRANCH_NO) AS BRANCH_NO,
		'077' AS DIVISION_NO,
		'08' AS PRODUCT_TYPE,  -- 08 有價証券投資
		TRIM(OSBDKF02_TRAN_NO) AS TRAN_NO, --交易編號
		'018' AS BUSINESS_UNIT,
		OSBDKF02_DOWN_DATE AS TX_DATE, --訂約日期
		TRIM(OSBDKF02_CUST_NAME1) AS CUSTOMER_NAME,
		TRIM(OSBDKF02_SWIFT_ID) AS CUSTOMER_ID,
		TRIM(OSBDKF02_ISSUER_COUNTRY) AS COUNTRY_COD,
		TRIM(OSBDKF02_CURENCY_COD) AS CURENCY_COD,
		(OSBDKF02_BALANCE_AMT / OSBDKF02_PRICE) *100 AS TRAN_AMOUNT, -- 改抓OSBDKF02_BALANCE_AMT
		TRIM(OSBDKF02_LINE_PERMIT_NO) + OSBDKF02_BRANCH_NO AS PERMIT_NO, --核准編號
		(OSBDKF02_BALANCE_AMT / OSBDKF02_PRICE) *100 AS LIMIT, --核准額度 -- 改抓OSBDKF02_BALANCE_AMT
		TRIM(OSBDKF02_CURENCY_COD) AS LIMIT_COD, --幣別
		OSBDKF02_MATURITY_DATE AS MATURITY_DATE,
		OSBDKF02_TX_DATE AS AS_OF_DATE,
		'OSBDKF02_MF' AS FIL9,
		'01' AS SOURCE,
		'system' AS CREATOR,
		OSBDKF02_MATURITY_DATE AS LIMIT_MATURITY,
		TRIM(BUSINS_CODE) AS INDUSTRY,
		2,
		@EXT_DATE AS EXT_DATE
	FROM temp
	--國家風險餘額計算步驟：
	--	一、	依「CUST-NAME1」加總「BOND PRICE」之折美金值加總之金額如小於0，則不計入。
	--	三、	將各「CUST-NAME1」之加總「BOND PRICE」折美金值，依國碼別加總  ???
	WHERE EXISTS (
			SELECT 1
			FROM temp MF2
			WHERE TRIM(MF2.OSBDKF02_CUST_NAME1) = TRIM(temp.OSBDKF02_CUST_NAME1) AND
			MF2.OSBDKF02_BRANCH_NO = temp.OSBDKF02_BRANCH_NO
			GROUP BY TRIM(MF2.OSBDKF02_CUST_NAME1), MF2.OSBDKF02_BRANCH_NO
			HAVING SUM(MF2.OSBDKF02_BOND_PRICE) > 0
		);
	END TRY
	BEGIN CATCH
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT '發生錯誤: ' + @ErrorMsg;
		THROW;
	END CATCH

END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		AllenChen
-- Create date: 2025/10/17
-- Description:	01OBBS延伸性金融商品FXSWAP(OSFXKF02_MF) 轉檔，根據分行交易最大日期

-- =============================================
CREATE PROCEDURE [dbo].[usp_Souce01_OBBS_By_OSFXKF02_MF] @EXT_DATE AS DATE
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

	DECLARE @BufferDate INT = 14; -- 到期日緩衝時間

	INSERT INTO MonitorData (
		BRANCH_NO, UNIT_NO, PRODUCT_TYPE, TRAN_NO, GROUP_NO, TX_DATE,
		CUSTOMER_NAME, CUSTOMER_ID, COUNTRY_COD, CURENCY_COD, TRAN_AMOUNT,
		LIMIT, LIMIT_COD, MATURITY_DATE, AS_OF_DATE, FIL9,
		SOURCE, CREATOR, LIMIT_MATURITY,INDUSTRY,INDUSTRY_Type,CUR_BOUGHT,CUR_SOLD,EXT_DATE)
	SELECT
		TRIM(OSFXKF02_BRANCH_NO) AS BRANCH_NO,
		'077' AS DIVISION_NO,
		'07' AS PRODUCT_TYPE,
		TRIM(OSFXKF02_TRAN_NO) AS TRAN_NO,
		'018' AS BUSINESS_UNIT,
		OSFXKF02_DEL_DATE AS TX_DATE,
		TRIM(OSFXKF02_CUST_NAME1) AS CUSTOMER_NAME,
		TRIM(OSFXKF02_CUATOMER_ID) AS CUSTOMER_ID,
		TRIM(COALESCE(NULLIF(TRIM(OSFXKF02_CPTY_COUNTRY_RISK), ''), OSFXKF02_CPTY_COUNTRY)) AS COUNTRY_COD,
		TRIM(OSFXKF02_OBJECT_CCY) AS CURENCY_COD,
		OSFXKF02_OBJECT_AMT AS TRAN_AMOUNT,
		OSFXKF02_OBJECT_AMT AS LIMIT,
		TRIM(OSFXKF02_OBJECT_CCY) AS LIMIT_COD,
		OSFXKF02_VALUE_DATE0 AS MATURITY_DATE,
		OSFXKF02_TX_DATE AS AS_OF_DATE,
		'OSFXKF02_MF' AS FIL9,
		'01' AS source,
		'system' AS creator,
		OSFXKF02_VALUE_DATE0 AS LIMIT_MATURITY,
		TRIM(BUSINS_CODE) AS INDUSTRY,
		2,
		OSFXKF02_CUR_BOUGHT as CUR_BOUGHT,
		OSFXKF02_CUR_SOLD AS CUR_SOLD,
		@EXT_DATE AS EXT_DATE
	FROM OSFXKF02_MF
	WHERE OSFXKF02_TX_TYPE = '03' AND
		  TRIM(ISNULL(OSFXKF02_CPTY_COUNTRY_RISK,'')) <> 'TW' AND
			EXISTS (
					SELECT 1
					FROM (
						SELECT OSFXKF02_BRANCH_NO, MAX(OSFXKF02_EXT_DATE) AS MAX_DATE
						FROM OSFXKF02_MF
						WHERE OSFXKF02_EXT_DATE <= @EXT_DATE
						GROUP BY OSFXKF02_BRANCH_NO
					) Latest
					WHERE OSFXKF02_BRANCH_NO = Latest.OSFXKF02_BRANCH_NO AND
						OSFXKF02_EXT_DATE = Latest.MAX_DATE
				) AND
			(OSFXKF02_VALUE_DATE0 IS NULL OR DATEADD(DAY,@BufferDate,OSFXKF02_VALUE_DATE0) >= @EXT_DATE)
	END TRY
	BEGIN CATCH
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT '發生錯誤: ' + @ErrorMsg;
		THROW;
	END CATCH

END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		AllenChen
-- Create date: 2025/10/17
-- Description:	01OBBS衍伸性商品IRS(OSISKF02_MF) 轉檔，根據分行交易最大日期

-- =============================================
CREATE PROCEDURE [dbo].[usp_Souce01_OBBS_By_OSISKF02_MF] @EXT_DATE AS DATE
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

		DECLARE @BufferDate INT = 14; -- 到期日緩衝時間

		INSERT INTO MonitorData (
			BRANCH_NO, UNIT_NO, PRODUCT_TYPE, TRAN_NO, GROUP_NO, TX_DATE,
			CUSTOMER_NAME, CUSTOMER_ID, COUNTRY_COD, CURENCY_COD, TRAN_AMOUNT,
			LIMIT, LIMIT_COD, MATURITY_DATE, AS_OF_DATE,  FIL9,
			SOURCE, CREATOR, LIMIT_MATURITY, INDUSTRY,INDUSTRY_Type, PRODUCT_CODE,EXT_DATE)
		SELECT
			TRIM(OSISKF02_BRANCH_NO) AS BRANCH_NO,
			'077' AS DIVISION_NO,
			'07' AS PRODUCT_TYPE,
			TRIM(OSISKF02_TRAN_NO) AS TRAN_NO,
			'018' AS BUSINESS_UNIT,
			OSISKF02_TRADE_DATE AS TX_DATE,
			TRIM(OSISKF02_CUST_NAME1) AS CUSTOMER_NAME,
			TRIM(OSISKF02_CUATOMER_ID) AS CUSTOMER_ID,
			TRIM(OSISKF02_CPTY_COUNTRY_RISK) AS COUNTRY_COD,
			TRIM(OSISKF02_IN_CCY) AS CURENCY_COD,
			OSISKF02_risk_amt AS TRAN_AMOUNT,
			OSISKF02_risk_amt AS LIMIT,
			TRIM(OSISKF02_IN_CCY) AS LIMIT_COD,
			OSISKF02_MATURITY AS MATURITY_DATE,
			OSISKF02_TX_DATE AS AS_OF_DATE,
			'OSISKF02_MF' AS FIL9,
			'01' AS source,
			'system' AS creator,
			OSISKF02_MATURITY AS LIMIT_MATURITY,
			TRIM(BUSINS_CODE) AS INDUSTRY,
			2,
			'IRS' AS PRODUCT_CODE,
			@EXT_DATE AS EXT_DATE
		FROM OSISKF02_MF
		WHERE
			TRIM(OSISKF02_CPTY_COUNTRY_RISK) <> 'TW' AND
			 -- 檢查是否為最新資料
			EXISTS (
				SELECT 1
				FROM (
					SELECT OSISKF02_BRANCH_NO, MAX(OSISKF02_EXT_DATE) AS MAX_DATE
					FROM OSISKF02_MF
					WHERE OSISKF02_EXT_DATE <= @EXT_DATE
					GROUP BY OSISKF02_BRANCH_NO
				) Latest
				WHERE OSISKF02_MF.OSISKF02_BRANCH_NO = Latest.OSISKF02_BRANCH_NO AND
					OSISKF02_MF.OSISKF02_EXT_DATE = Latest.MAX_DATE
			) AND
			(OSISKF02_MATURITY IS NULL OR DATEADD(DAY,@BufferDate,OSISKF02_MATURITY) >= @EXT_DATE)
	END TRY
	BEGIN CATCH
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT '發生錯誤: ' + @ErrorMsg;
		THROW;
	END CATCH

END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		AllenChen
-- Create date: 2025/10/17
-- Description:	01OOBS 海外拆款與存同業務(OSMMKF02_MF) 轉檔，根據分行交易最大日期

-- =============================================
CREATE PROCEDURE [dbo].[usp_Souce01_OBBS_By_OSMMKF02_MF] @EXT_DATE DATE
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

		DECLARE @BufferDate INT = 14; -- 到期日緩衝時間

		WITH temp AS (
			SELECT *,
			CASE TRIM(OSMMKF02_TRAN_TYPE) WHEN '1' THEN '09' -- 09 拆款業務
			ELSE '04' -- 04 存同
			END PRODUCT_TYPE,
			CASE TRIM(OSMMKF02_TRAN_TYPE) WHEN '1' THEN OSMMKF02_MATURITY_DATE
			ELSE isnull(OSMMKF02_MATURITY_DATE,DATEADD(MONTH, 1, GETDATE()))
			END MATURITY_DATE,
			CASE TRIM(OSMMKF02_TRAN_TYPE) WHEN '1' THEN OSMMKF02_MATURITY_DATE
			ELSE DATEFROMPARTS(YEAR(GETDATE()), 12, 31)
			END LIMIT_MATURITY
			FROM OSMMKF02_MF
			WHERE TRIM(OSMMKF02_COUNTRY_RISK) <> 'TW' AND
			(TRIM(OSMMKF02_TRAN_TYPE) = '1' OR -- 1 = 09拆款
			(TRIM(OSMMKF02_TRAN_TYPE) IN ('3','4','5','6') AND -- 3,4,5,6  = 04 存同
			 LEFT(TRIM(OSMMKF02_SWIFT_ID), 4) <> 'FCBK')) AND -- FCB 國外分公司(FCBK是 FCB 國內外分行，FCBC 是加州分行，要算入)
			(OSMMKF02_MATURITY_DATE IS NULL OR OSMMKF02_MATURITY_DATE > OSMMKF02_EXT_DATE) AND
			(OSMMKF02_MATURITY_DATE IS NULL OR DATEADD(DAY,@BufferDate,OSMMKF02_MATURITY_DATE) >= @EXT_DATE) AND

			EXISTS (
					SELECT 1
					FROM (
						SELECT OSMMKF02_BRANCH_NO, MAX(OSMMKF02_EXT_DATE) AS MAX_DATE
						FROM OSMMKF02_MF
						WHERE OSMMKF02_EXT_DATE <= @EXT_DATE
						GROUP BY OSMMKF02_BRANCH_NO
					) Latest
					WHERE OSMMKF02_BRANCH_NO = Latest.OSMMKF02_BRANCH_NO
					AND OSMMKF02_EXT_DATE = Latest.MAX_DATE
			)
		)
		INSERT INTO MonitorData (
			BRANCH_NO, UNIT_NO, PRODUCT_TYPE, TRAN_NO, GROUP_NO, TX_DATE,
			CUSTOMER_NAME, CUSTOMER_ID, COUNTRY_COD, CURENCY_COD, TRAN_AMOUNT,
			LIMIT, LIMIT_COD, MATURITY_DATE, AS_OF_DATE, FIL9,
			SOURCE, CREATOR, LIMIT_MATURITY, INDUSTRY,INDUSTRY_Type,EXT_DATE)
		SELECT TRIM(OSMMKF02_BRANCH_NO) AS BRANCH_NO,
			'077' AS DIVISION_NO,
			PRODUCT_TYPE AS PRODUCT_TYPE,
			ISNULL(OSMMKF02_TRAN_NO,
				TRIM(OSMMKF02_BRANCH_NO) +
				TRIM(OSMMKF02_TRAN_TYPE) +
				TRIM(OSMMKF02_SWIFT_ID) +
				TRIM(OSMMKF02_CURENCY_COD)) AS TRAN_NO,
			'018' AS BUSINESS_UNIT,
			OSMMKF02_CONTRACT_DATE AS TX_DATE,
			TRIM(OSMMKF02_CUST_NAME1) AS CUSTOMER_NAME,
			TRIM(OSMMKF02_SWIFT_ID) AS CUSTOMER_ID,
			TRIM(OSMMKF02_COUNTRY_RISK) AS COUNTRY_COD,
			TRIM(OSMMKF02_CURENCY_COD) AS CURENCY_COD,
			ABS(OSMMKF02_TRAN_AMOUNT) AS TRAN_AMOUNT,
			ABS(OSMMKF02_TRAN_AMOUNT) AS LIMIT,
			TRIM(OSMMKF02_CURENCY_COD) AS LIMIT_COD,
			MATURITY_DATE AS MATURITY_DATE,
			OSMMKF02_TX_DATE AS AS_OF_DATE,
			'OSMMKF02_MF' AS FIL9,
			'01' AS source,
			'system' AS creator,
			LIMIT_MATURITY AS LIMIT_MATURITY,
			TRIM(BUSINS_CODE) AS INDUSTRY,
			2,
			@EXT_DATE AS EXT_DATE
		FROM
			temp
		WHERE
			EXISTS (
			SELECT 1
			FROM temp MF2
			WHERE LEFT(TRIM(MF2.OSMMKF02_SWIFT_ID),4) = LEFT(TRIM(OSMMKF02_SWIFT_ID),4)
			GROUP BY LEFT(TRIM(MF2.OSMMKF02_SWIFT_ID),4),case OSMMKF02_TRAN_TYPE when '1' then 1 else 0 end -- 原本有分 1 = 拆放, 其他存同
			HAVING SUM(ABS(MF2.OSMMKF02_TRAN_AMOUNT)) > 0)
	END TRY
	BEGIN CATCH
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT '發生錯誤: ' + @ErrorMsg;
		THROW;
	END CATCH

END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		AllenChen
-- Create date: 2025/10/17
-- Description:	01OBBS之海外各業務交易資料(OS_LNSMSTD_D_MF)與海外各業務額度資料(MF_OS_LNSLMSD_D_MF) 轉檔，根據分行交易最大日期

-- =============================================
CREATE PROCEDURE [dbo].[usp_Souce01_OBBS_By_OS_LNSMSTD_D_MF_OS_LNSLMSD_D_MF] @EXT_DATE AS DATE
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

		DECLARE @BufferDate INT = 14; -- 到期日緩衝時間

		with temp as (
			SELECT DISTINCT Trim(LNSMSTD_BRANCH_NO) AS BRANCH_NO,
			'077' AS Unit_NO,--處級單位代號
			case Trim(LNSMSTD_TX_TYPE)
				WHEN 'SL' THEN '01'  -- 聯合貸款
				WHEN 'GU' THEN '12'  -- 保證
				WHEN 'E3' THEN '03'  -- 保兌
				--WHEN 'E5' THEN '10'  -- 應收帳款承購 --賢欽 2025/11/13 說不用
			ELSE '02' -- 一般放款
			end AS PRODUCT_TYPE,--產品別
			Trim(LNSMSTD_TX_NO) AS TRAN_NO,--交易代號
			'018' AS Group_NO, --事業群代號 海外分行只有海外事業群 所以018
			cast(LNSMSTD_BEGIN_DATE as date) AS TX_DATE, --原始初貸日 = 交易日期
			Trim(LNSLMSD_CUSTOMER_NAME) AS CUSTOMER_NAME, --客戶姓名 -- 空要抓 c100 ，依據跟客戶ID 分行
			Trim(LNSMSTD_CUSTOMER_ID) AS CUSTOMER_ID, -- 客戶ID
			Trim(Isnull(LNSLMSD_COUNTRY_RISK,Isnull(LNSLMSD_REG_COUNTRY,''))) AS COUNTRY_COD,--交易國家 空 要抓c100
			Trim(LNSMSTD_CURRENCY) AS CURENCY_COD, --幣別
			LNSMSTD_BALANCE AS TRAN_AMOUNT, -- 交易金額
			Trim(LNSLMSD_APP_NO) AS PERMIT_NO,--核准編號
			ISNULL(LNSLMSD_APP_AMT,LNSMSTD_BALANCE) AS LIMIT,--核准額度  空 抓 交易金額
			ISNULL(Trim(LNSLMSD_CURRENCY),LNSMSTD_CURRENCY) AS LIMIT_COD, --核准幣別 空 抓交易幣別
			LEFT(LNSMSTD_MATURITY, 8) AS MATURITY_DATE,--到期日
			LNSMSTD_DATA_DATE AS AS_OF_DATE,--資料日期
			CASE TRIM(Isnull(LNSLMSD_CIRCLE,'')) WHEN 'Y' THEN 1 ELSE 0 END AS REVOLVE_MK,--是否循環 空 為 0
			'OS_LNSMSTD_D_MF' AS FIL9,-- 行業別主檔 只有授信產品
			'01' AS source,
			'system' AS creator,
			LNSMSTD_ACC_CODE_INT_9, -- 判斷是否為利息
			LNSMSTD_ACCRUE_INT,--利息
			LNSLMSD_MATURITY AS LIMIT_MATURITY, --額度到期日 空 可能要無限大
			TRIM(LNSM.BUSINS_CODE) AS INDUSTRY, -- 行業別主檔 只有授信產品
			2 AS INDUSTRY_TYPE, --海外
			@EXT_DATE as EXT_DATE
			FROM OS_LNSMSTD_D_MF LNSM --海外分行授信業務交易主檔
			LEFT JOIN OS_LNSLMSD_D_MF LNSL ON --海外分行額度檔
				LNSMSTD_LINE_NO = LNSLMSD_LINE_NO AND -- 額度號碼
				LNSMSTD_BRANCH_NO = LNSLMSD_BRANCH_NO AND -- 分行編號
				LNSMSTD_EXT_DATE = LNSLMSD_EXT_DATE --資料日
			WHERE
			NOT (LNSMSTD_BALANCE = 0 AND ( LNSLMSD_MATURITY IS NULL OR LNSLMSD_MATURITY < LNSMSTD_EXT_DATE)) AND --到期且餘額 = 0 排除
			-- 取到期日要大於轉檔日的資料，除了催收，催收項目為 LNSMSTD_ACC_CODE_INT_9 IN ('135850003','135850004')，催收的項目會超過到期日
			((LNSLMSD_MATURITY IS NULL OR DATEADD(DAY,@BufferDate,LNSLMSD_MATURITY) >= @EXT_DATE) OR
				LNSMSTD_ACC_CODE_INT_9 in ('135850003','135850004')
			) AND
			TRIM(LNSLMSD_COUNTRY_RISK) <> 'TW' AND -- 排除台灣
				 EXISTS (
						SELECT 1
						FROM (
							SELECT LNSMSTD_BRANCH_NO, MAX(LNSMSTD_EXT_DATE) AS MAX_DATE
							FROM OS_LNSMSTD_D_MF
							WHERE LNSMSTD_EXT_DATE <= @EXT_DATE
							GROUP BY LNSMSTD_BRANCH_NO
						) Latest
						WHERE LNSMSTD_BRANCH_NO = Latest.LNSMSTD_BRANCH_NO
						AND LNSMSTD_EXT_DATE = Latest.MAX_DATE
					) AND
				TRIM(lnsmstd_status) <> '2'  -- 排除呆帳
		)
		INSERT INTO MonitorData (
		BRANCH_NO, UNIT_NO, PRODUCT_TYPE, TRAN_NO, GROUP_NO, TX_DATE,
		CUSTOMER_NAME, CUSTOMER_ID, COUNTRY_COD, CURENCY_COD, TRAN_AMOUNT,
		PERMIT_NO, LIMIT, LIMIT_COD, MATURITY_DATE, AS_OF_DATE, REVOLVE_MK, FIL9,
		SOURCE, CREATOR, LIMIT_MATURITY, INDUSTRY,INDUSTRY_Type,EXT_DATE)
		SELECT BRANCH_NO,Unit_NO,PRODUCT_TYPE,TRAN_NO,Group_NO,TX_DATE,CUSTOMER_NAME,
				CUSTOMER_ID,COUNTRY_COD,CURENCY_COD,TRAN_AMOUNT,PERMIT_NO,LIMIT,LIMIT_COD,MATURITY_DATE,AS_OF_DATE,REVOLVE_MK,FIL9,
				source,creator,LIMIT_MATURITY,INDUSTRY,INDUSTRY_TYPE,EXT_DATE
		From temp
		UNION
		-- 利息要再加上去 LNSMSTD_ACC_CODE_INT_9 in ('135850003','135850004') and LNSMSTD_ACCRUE_INT <> 0
			SELECT BRANCH_NO,Unit_NO,PRODUCT_TYPE,TRAN_NO,Group_NO,TX_DATE,CUSTOMER_NAME,
				CUSTOMER_ID,COUNTRY_COD,CURENCY_COD,LNSMSTD_ACCRUE_INT,PERMIT_NO,LIMIT,
				LIMIT_COD,MATURITY_DATE,AS_OF_DATE,REVOLVE_MK,FIL9 + '_Interest',
				source,creator,LIMIT_MATURITY,INDUSTRY,INDUSTRY_TYPE,EXT_DATE
			From temp
			WHERE LNSMSTD_ACC_CODE_INT_9 in ('135850003','135850004') and LNSMSTD_ACCRUE_INT <> 0
		UNION
		-- 未動用但仍有效的授信額度
			SELECT
				TRIM(LNSLMSD_BRANCH_NO) AS BRANCH_NO, --分行代號
				'077' AS DIVISION_NO,--處級單位代號
				case Trim(LNSLMSD_LINE_TYPE)
					WHEN 'SL' THEN '01'  -- 聯合貸款
					WHEN 'SG' THEN '12'  -- 保證
				ELSE '02' -- 一般放款
				end AS PRODUCT_TYPE,--產品別
				'' AS TRAN_NO,--交易代號
				'018' AS BUSINESS_UNIT,--事業群代號
				LNSLMSD_BGN_DATE AS TX_DATE,--交易日期
				TRIM(LNSLMSD_CUSTOMER_NAME) AS CUSTOMER_NAME,--客戶姓名
				TRIM(LNSLMSD_CUSTOMER_ID) AS CUSTOMER_ID,--客戶 ID
				TRIM(LNSLMSD_COUNTRY_RISK) AS COUNTRY_COD, --國家別
				TRIM(LNSLMSD_CURRENCY) AS CURENCY_COD,--幣別
				0 AS TRAN_AMOUNT, --交易金額
				TRIM(LNSLMSD_APP_NO) AS PERMIT_NO,--核准編號
				LNSLMSD_APP_AMT AS LIMIT,--核准額度
				TRIM(LNSLMSD_CURRENCY) AS LIMIT_COD,--核准幣別
				LNSLMSD_MATURITY AS MATURITY_DATE, --到期日
				LNSLMSD_DATA_DATE AS AS_OF_DATE, --資料日期
				CASE TRIM(LNSLMSD_CIRCLE)
					WHEN 'Y' THEN 1
				ELSE 0
				END AS REVOLVE_MK,--是否循環
				'OS_LNSLMSD_D_MF' AS FIL9,
				'01' AS source,
				'system' AS creator,
				LNSLMSD_MATURITY AS LIMIT_MATURITY, -- 額度到期日
				TRIM(a.BUSINS_CODE) AS INDUSTRY,
				2,--海外
				@EXT_DATE AS DATADATE
			FROM OS_LNSLMSD_D_MF a
			Left join OS_LNSMSTD_D_MF b on trim(a.LNSLMSD_BRANCH_NO) = trim(b.LNSMSTD_BRANCH_NO) and
							Trim(a.LNSLMSD_LINE_NO) = trim(b.LNSMSTD_LINE_NO) and
							a.LNSLMSD_EXT_DATE = b.LNSMSTD_EXT_DATE
			WHERE EXISTS (
					SELECT 1
					FROM (
						SELECT LNSLMSD_BRANCH_NO, MAX(LNSLMSD_EXT_DATE) AS MAX_DATE
						FROM OS_LNSLMSD_D_MF
						WHERE LNSLMSD_EXT_DATE <= @EXT_DATE
						GROUP BY LNSLMSD_BRANCH_NO
					) Latest
					WHERE LNSLMSD_BRANCH_NO = Latest.LNSLMSD_BRANCH_NO AND
						LNSLMSD_EXT_DATE = Latest.MAX_DATE AND
						(LNSLMSD_MATURITY IS NULL OR DATEADD(DAY,@BufferDate,LNSLMSD_MATURITY) >= @EXT_DATE)  -- 到期日Buffer後不能過期轉檔日
				  ) AND
				  TRIM(LNSLMSD_LINE_TYPE) IN ('SL','LN','SG','IM','OD','BP') AND
				  TRIM(ISNULL(LNSLMSD_COUNTRY_RISK,'')) <> 'TW' AND
				  LNSLMSD_LINE_NO IS NOT NULL AND
				  b.LNSMSTD_STATUS <> '2' AND
				  b.LNSMSTD_LINE_NO IS NULL
					--LOAN:LN;
					--IMPORT:IM;
					--EXPORT:EX;
					--OVERDRAFT:OD;
					--CLEANBILL:CB;
					--GUARANTEE:SG
					--ACCEPTANCE:AC
					--SYNDICATED:SL
	END TRY
	BEGIN CATCH
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT '發生錯誤: ' + @ErrorMsg;
		THROW;
	END CATCH

END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		AllenChen
-- Create date: 2025/10/17
-- Description:	04存放銀行同業 交易最大日期

-- =============================================
CREATE PROCEDURE [dbo].[usp_Souce04_By_LS_LSRSA_D_MF_ACNOD_STG] @EXT_DATE DATE
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

		INSERT INTO MonitorData (
			BRANCH_NO, UNIT_NO, PRODUCT_TYPE, TRAN_NO, GROUP_NO, TX_DATE,
			CUSTOMER_NAME, CUSTOMER_ID, COUNTRY_COD, CURENCY_COD, TRAN_AMOUNT,
			PERMIT_NO, LIMIT, LIMIT_COD, MATURITY_DATE, AS_OF_DATE, FIL9,
			SOURCE, CREATOR, LIMIT_MATURITY, INDUSTRY,INDUSTRY_Type, EXT_DATE)
		SELECT
			'D01' AS BRANCH_NO,
			'091' AS DIVISION_NO,
			'04' AS PRODUCT_TYPE,
			TRIM(APRV_NO) AS TRAN_NO,
			'018' AS BUSINESS_UNIT,
			EXT_DATE AS TX_DATE,
			TRIM(ENG_NAME) AS CUSTOMER_NAME,
			TRIM(ISIN_CD) AS CUSTOMER_ID,
			TRIM(COUNTRY) AS COUNTRY_COD,
			TRIM(CURRENCY) AS CURENCY_COD,
			LN_BAL AS TRAN_AMOUNT,
			NULL AS PERMIT_NO,
			LN_BAL AS LIMIT,
			TRIM(CURRENCY) AS LIMIT_COD,
			DATEADD(month, 1, GETDATE()) AS MATURITY_DATE,
			EXT_DATE AS AS_OF_DATE,
			'LS_LSRSA_D_MF' AS FIL9,
			'04' AS source,
			'system' AS creator,
			DATEFROMPARTS(YEAR(GETDATE()), 12, 31) AS LIMIT_MATURITY,
			right(BUSINS_CODE,6) AS INDUSTRY,
			1,
			@EXT_DATE AS EXT_DATE
		FROM LS_LSRSA_D_MF
		WHERE (SELECT MAX(EXT_DATE) FROM LS_LSRSA_D_MF WHERE EXT_DATE <= @EXT_DATE) = EXT_DATE AND
			LEFT(ACC_CODE, 5) = '11021' AND
			TRIM(COUNTRY) <> 'TW' AND
			LEFT(TRIM(ISIN_CD), 4) <> 'FCBK'
		UNION ALL
		SELECT
			'098' AS BRANCH_NO,
			'069' AS DIVISION_NO,
			'04' AS PRODUCT_TYPE,
			NULL AS TRAN_NO,
			'016' AS BUSINESS_UNIT,
			ACNOD_EXT_DATE AS TX_DATE,
			'HSBC (GLOBAL CUSTODY CASH)' AS CUSTOMER_NAME,
			'HSBCHKHHGCC' AS CUSTOMER_ID,
			'GB' AS COUNTRY_COD,
			TRIM(ACNOD_CRCY_CODE) AS CURENCY_COD,
			ACNOD_OPER_DATE_BAL_INF AS TRAN_AMOUNT,
			NULL AS PERMIT_NO,
			ACNOD_OPER_DATE_BAL_INF AS LIMIT,
			TRIM(ACNOD_CRCY_CODE) AS LIMIT_COD,
			DATEFROMPARTS(YEAR(GETDATE()), 12, 31) AS MATURITY_DATE,
			ACNOD_EXT_DATE AS AS_OF_DATE,
			'ACNOD_STG' AS FIL9,
			'04' AS source,
			'system' AS creator,
			DATEFROMPARTS(YEAR(GETDATE()), 12, 31) AS LIMIT_MATURITY,
			null AS INDUSTRY,
			null,
			@EXT_DATE AS DATADATE
		FROM ACNOD_STG
		WHERE ACNOD_BRANCH_CODE = '092' AND
	　		 ACNOD_ACC5_CODE = '11134' AND
			ACNOD_ACC5_SUB_CODE = '001' AND
			ACNOD_LAST_BAL_MARK = 'Y' AND
			(SELECT MAX(ACNOD_EXT_DATE) FROM ACNOD_STG WHERE ACNOD_EXT_DATE <= @EXT_DATE) = ACNOD_EXT_DATE;

	END TRY
	BEGIN CATCH
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT '發生錯誤: ' + @ErrorMsg;
		THROW;
	END CATCH

END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		AllenChen
-- Create date: 2025/10/17
-- Description:	06外貸系統(外幣貸款系統) 交易最大日期

-- =============================================
CREATE PROCEDURE [dbo].[usp_Souce06_By_FL_FLMST_D_MF] @EXT_DATE DATE
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

	DECLARE @BufferDate INT = 14; -- 到期日緩衝時間

		WITH TEMP AS(
			SELECT MF.*,right(mf.BUSINS_CODE,6) INDUSTRY,
				   CIF.CIF_CUST_NAME,CR.CountryCode2,
				   LINE.FMLINE_LINE_AMT,LINE.FMLINE_REVOLING_TYPE,
				   LINE.FMLINE_LINE_EXPIRY,
				   LINE.FMLINE_MULT_MERGED_MARK,
				   LINE.FMLINE_MULT_MERGED_APRV_NO,
				   CUR.CRCY_ENG_NAME AS CURNAME,
				   CUR1.CRCY_ENG_NAME AS CURNAME1
			FROM FL_FLMST_D_MF MF
			LEFT JOIN DAILY_CIF_TMP CIF ON FLMST_CUST_ID = CIF.CIF_ID_NO
			LEFT JOIN FM_FMLINE_D_MF LINE ON
				LINE.FMLINE_EXT_DATE = FLMST_EXT_DATE AND
				LINE.FMLINE_DATE_TYPE = '10' AND
				FLMST_APRV_TYPE_1 = LINE.FMLINE_LINE_TYPE AND
				FLMST_CUST_ID = LINE.FMLINE_CUST_ID AND
				FLMST_RECV_BRANCH = LINE.FMLINE_BRANCH AND
				FLMST_APRV_NO_1 = LINE.FMLINE_APRV_NO
			LEFT JOIN CountryMaster CR on TRIM(FLMST_FINAL_RISK_CNTY) = CR.CountryCode4
			INNER JOIN MIS_CRCY_REF CUR ON TRIM(FLMST_CURENCY) = TRIM(CUR.CRCY_CODE)
			INNER JOIN MIS_CRCY_REF CUR1 ON TRIM(FLMST_APRV_CUR_1) = TRIM(CUR1.CRCY_CODE)
			WHERE FLMST_EXT_DATE = (SELECT MAX(FLMST_EXT_DATE) FROM FL_FLMST_D_MF WHERE FLMST_EXT_DATE <= @EXT_DATE) AND
				  TRIM(FLMST_FINAL_RISK_CNTY) NOT IN('0000','1001') AND
				  TRIM(FLMST_DATA_TYPE) = '0' AND　-- 待確認
				  NOT(FLMST_LOAN_TYPE = '10' AND ISNULL(FLMST_SUBSTITUTE_REMIT_MK, '') = 'Y') AND --註記邏輯可能要調整
				  TRIM(FLMST_DATA_STATUS) in ('0', '2', '4') AND -- 2是催收資料 -- 0 一般資料
				  (FLMST_MATURITY IS NULL OR DATEADD(DAY,@BufferDate,FLMST_MATURITY) >= @EXT_DATE)
		)

		-- FMLINE 未來 會添加一個風險國欄位
		-- ELLSTAPV 用分行加核准編號 去串 抓國家
		-- FLMST 原本風險國欄位

		INSERT INTO MonitorData (
		    BRANCH_NO, UNIT_NO, PRODUCT_TYPE, TRAN_NO, GROUP_NO, TX_DATE,
		    CUSTOMER_NAME, CUSTOMER_ID, COUNTRY_COD, CURENCY_COD, TRAN_AMOUNT,
		    PERMIT_NO, LIMIT, LIMIT_COD, MATURITY_DATE, AS_OF_DATE, REVOLVE_MK, FIL9,
			SOURCE, CREATOR, LIMIT_MATURITY,INDUSTRY,INDUSTRY_Type,EXT_DATE)
		SELECT
			TRIM(FLMST_RECV_BRANCH) as BRANCH_NO,
			'064' as DIVISION_NO,
			'02' as PRODUCT_TYPE,
			TRIM(FLMST_LC_NO) as TRAN_NO,
			'011' as BUSINESS_UNIT,
			FLMST_NEGO_DATE as TX_DATE,
			TRIM(CIF_CUST_NAME) as CUSTOMER_NAME,
			TRIM(FLMST_CUST_ID) as CUSTOMER_ID,
			CountryCode2 as COUNTRY_COD,
			TRIM(CURNAME) as CURENCY_COD,
			FLMST_ADVANCE_BALANCE as TRAN_AMOUNT,
			TRIM(FLMST_APRV_NO_1) as PERMIT_NO,
			FMLINE_LINE_AMT as [LIMIT],
			TRIM(CURNAME1) as LIMIT_COD,
			FLMST_MATURITY as MATURITY_DATE,
			FLMST_EXT_DATE as AS_OF_DATE,
			CASE FMLINE_REVOLING_TYPE WHEN '1' THEN 1
				 ELSE 0
				 END as REVOLVE_MK,
			'FL_FLMST_D_MF1' as FIL9,
			'06' as source,
			'system' as creator,
			FMLINE_LINE_EXPIRY as LIMIT_MATURITY,
			INDUSTRY as INDUSTRY,
			1,
			@EXT_DATE AS EXT_DATE
		FROM TEMP
		WHERE TRIM(FLMST_LOAN_TYPE) IN ('24','26')
		UNION
		SELECT
			TRIM(FLMST_RECV_BRANCH) as BRANCH_NO,
			'067' as DIVISION_NO,
			'02' as PRODUCT_TYPE,
			TRIM(FLMST_LC_NO) as TRAN_NO,
			'013' as BUSINESS_UNIT,
			FLMST_NEGO_DATE as TX_DATE,
			TRIM(CIF_CUST_NAME) as CUSTOMER_NAME,
			TRIM(FLMST_CUST_ID) as CUSTOMER_ID,
			CountryCode2 as COUNTRY_COD,
			TRIM(CURNAME) as CURENCY_COD,
			FLMST_ADVANCE_BALANCE as TRAN_AMOUNT,
			TRIM(FLMST_APRV_NO_1) as PERMIT_NO,
			FMLINE_LINE_AMT as [LIMIT],
			TRIM(CURNAME1) as LIMIT_COD,
			FLMST_MATURITY as MATURITY_DATE,
			FLMST_EXT_DATE as AS_OF_DATE,
			CASE FMLINE_REVOLING_TYPE WHEN '1' THEN 1
				 ELSE 0
				 END as REVOLVE_MK,
			'FL_FLMST_D_MF2' as FIL9,
			'06' as source,
			'system' as creator,
			FMLINE_LINE_EXPIRY as LIMIT_MATURITY,
			INDUSTRY as INDUSTRY,
			1,
			@EXT_DATE AS DATADATE
		FROM TEMP
		WHERE TRIM(FLMST_LOAN_TYPE) IN ('25','27','28','29')
		UNION
		SELECT
			TRIM(FLMST_RECV_BRANCH) as BRANCH_NO,
			CASE TRIM(FLMST_RECV_BRANCH)
				WHEN '091' THEN '091'
				WHEN '095' THEN '077'
			ELSE '064'
			END as DIVISION_NO,
			CASE WHEN FLMST_LOAN_TYPE IN ('01','02','03','04','05','06','07','08','11','12','13')
					THEN '02'
				WHEN FLMST_LOAN_TYPE = '09'
					THEN '01'
				WHEN FLMST_LOAN_TYPE = '10'
					THEN '12'
				ELSE '02'
			END as PRODUCT_TYPE,
			TRIM(FLMST_LC_NO) as TRAN_NO,
			CASE WHEN TRIM(FLMST_RECV_BRANCH) IN ('091','095')
				THEN '018'
			ELSE '011'
			END as BUSINESS_UNIT,
			FLMST_NEGO_DATE as TX_DATE,
			TRIM(CIF_CUST_NAME) as CUSTOMER_NAME,
			TRIM(FLMST_CUST_ID) as CUSTOMER_ID,
			CountryCode2 as COUNTRY_COD,
			TRIM(CURNAME) as CURENCY_COD,
			--CASE WHEN FLMST_LOAN_TYPE = '10'
			--	THEN FLMST_ADVANCE_BALANCE + FLMST_DISCOUNT_INT
			--	ELSE FLMST_ADVANCE_BALANCE END as TRAN_AMOUNT,
			FLMST_ADVANCE_BALANCE as TRAN_AMOUNT, -- 未來換上面那個
			TRIM(FLMST_APRV_NO_1) as PERMIT_NO,
			FMLINE_LINE_AMT as [LIMIT],
			TRIM(CURNAME1) as LIMIT_COD,
			FLMST_MATURITY as MATURITY_DATE, -- 改成close_date
			FLMST_EXT_DATE as AS_OF_DATE,
			CASE FMLINE_REVOLING_TYPE WHEN '1' THEN 1
				 ELSE 0
				 END as REVOLVE_MK,
			'FL_FLMST_D_MF3' as FIL9,
			'06' as source,
			'system' as creator,
			FMLINE_LINE_EXPIRY as LIMIT_MATURITY,
			INDUSTRY as INDUSTRY,
			1,
			@EXT_DATE AS DATADATE
		FROM TEMP
		WHERE TRIM(FLMST_LOAN_TYPE) NOT IN ('24','25','26','27')
		UNION
		SELECT  -- 額度檔
			TRIM(LINE.FMLINE_BRANCH) as BRANCH_NO,
			CASE TRIM(FLMST_RECV_BRANCH)
				WHEN '091' THEN '091'
				WHEN '095' THEN '077'
			ELSE '064'
			END as DIVISION_NO,
			'' as PRODUCT_TYPE, ---目前沒辦法分產品別
			'' as TRAN_NO,
			CASE WHEN TRIM(FLMST_RECV_BRANCH) IN ('091','095')
				THEN '018'
			ELSE '011'
			END as BUSINESS_UNIT,
			LINE.FMLINE_APRV_DATE as TX_DATE,
			TRIM(CIF_CUST_NAME) as CUSTOMER_NAME,
			TRIM(FMLINE_CUST_ID) as CUSTOMER_ID,
			 --ISNULL(LINE.FMLINE_FINAL_RISK_CNTY,ELL.RISK_NACTION_ID) as COUNTRY_COD,
			LINE.BUSINS_CODE as COUNTRY_COD, -- 要跟其他TABLE 拿，等資訊步道給我 -- LINE.FMLINE_FINAL_RISK_CNTY
			'' as CURENCY_COD,
			'' as TRAN_AMOUNT,
			LINE.FMLINE_APRV_NO as PERMIT_NO,
			LINE.FMLINE_LINE_AMT as [LIMIT],
			LINE.FMLINE_LINE_CURENCY as LIMIT_COD,
			LINE.FMLINE_LINE_EXPIRY as MATURITY_DATE,
			LINE.FMLINE_EXT_DATE as AS_OF_DATE, -- 不確定
			CASE LINE.FMLINE_REVOLING_TYPE WHEN '1' THEN 1
				 ELSE 0
				 END as REVOLVE_MK,
			'FM_FMLINE_D_MF' as FIL9,
			'06' as source,
			'system' as creator,
			FMLINE_LINE_EXPIRY as LIMIT_MATURITY,
			'' as INDUSTRY, -- 待確認
			1,
			@EXT_DATE AS DATADATE
		FROM FM_FMLINE_D_MF LINE
		--LEFT JOIN ELLSTAPV ELL ON LINE.FMLINE_CUST_ID = ELL.ELLSTAPV_CUST_ID AND LINE.FMLINE_APRV_NO = ELLSTAPV_APRV_NO  -- 未來要串這個去看國別
		-- 未來FM_FMLINE_D_MF 會有多一個欄位是 FMLINE_OBBS_APRV_NO 海外核准號碼，是為了RISKLINEO 匯入是對應 APROVE_NO，如果有就不用匯入RISKLINEO
		-- RISKLINED 核准編號對應 FMLINE_APRV_NO，如果有就排除RISKLINED
		LEFT JOIN FL_FLMST_D_MF FLMST ON
			LINE.FMLINE_EXT_DATE = FLMST_EXT_DATE AND
			LINE.FMLINE_DATE_TYPE = '10' AND
			FLMST_APRV_TYPE_1 = LINE.FMLINE_LINE_TYPE AND
			FLMST_CUST_ID = LINE.FMLINE_CUST_ID AND
			FLMST_RECV_BRANCH = LINE.FMLINE_BRANCH AND
			FLMST_APRV_NO_1 = LINE.FMLINE_APRV_NO
		LEFT JOIN DAILY_CIF_TMP CIF ON LINE.FMLINE_CUST_ID = CIF.CIF_ID_NO
		WHERE FLMST.FLMST_ACNT_BRANCH IS NULL

	END TRY
	BEGIN CATCH
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT '發生錯誤: ' + @ErrorMsg;
		THROW;
	END CATCH

END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		AllenChen
-- Create date: 2025/10/17
-- Description:	09SUKBD2附買回之資料擷取 交易最大日期
-- =============================================
CREATE PROCEDURE [dbo].[usp_Souce09_By_ARS_SUKBD2_D_MF] @EXT_DATE DATE
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY

        DECLARE @BufferDate INT = 14;

        INSERT INTO MonitorData (
            BRANCH_NO, UNIT_NO, PRODUCT_TYPE, TRAN_NO, GROUP_NO, TX_DATE,
            CUSTOMER_NAME, CUSTOMER_ID, COUNTRY_COD, CURENCY_COD, TRAN_AMOUNT,
            PERMIT_NO, LIMIT, LIMIT_COD, MATURITY_DATE, AS_OF_DATE, FIL9,
            SOURCE, CREATOR, LIMIT_MATURITY, INDUSTRY, INDUSTRY_Type, EXT_DATE)
        SELECT
            TRIM(MF.SUKBD2_BRANCH_NO)                                           AS BRANCH_NO,
            --TRIM(MF.SUKBD2_ACC_BRANCH_NO)                                       AS UNIT_NO,
			TRIM(MF.SUKBD2_BRANCH_NO)                                       AS UNIT_NO,
            '07'                                                                 AS PRODUCT_TYPE,
            TRIM(MF.SUKBD2_TRADE_NO)                                            AS TRAN_NO,
            '016'                                                                AS GROUP_NO,
            MF.SUKBD2_TRADE_DAY                                                 AS TX_DATE,
            TRIM(MF.SUKBD2_ISSUER_ID)                                           AS CUSTOMER_NAME,
            TRIM(MF.SUKBD2_ISSUER_APPID)                                        AS CUSTOMER_ID,
            TRIM(MF.SUKBD2_ISSUER_COUNTRY)                                      AS COUNTRY_COD,
            TRIM(MF.SUKBD2_REPO_CCY)                                            AS CURENCY_COD,
            MF.SUKBD2_REPO_AMOUNT                                                AS TRAN_AMOUNT,
            NULL                                                                 AS PERMIT_NO,
            MF.SUKBD2_REPO_AMOUNT                                                AS [LIMIT],
            NULL                                                                 AS LIMIT_COD,
            MF.SUKBD2_END_DATE                                                   AS MATURITY_DATE,
            MF.SUKBD2_EXT_DATE                                                   AS AS_OF_DATE,
            'ARS_SUKBD2_D_MF'                                                   AS FIL9,
            '09'                                                                 AS SOURCE,
            'system'                                                             AS CREATOR,
            MF.SUKBD2_END_DATE                                                   AS LIMIT_MATURITY,
            TRIM(MF.BUSINS_CODE)                                                 AS INDUSTRY,
            1                                                                    AS INDUSTRY_Type,
            @EXT_DATE                                                            AS EXT_DATE
        FROM ARS_SUKBD2_D_MF MF
        WHERE MF.SUKBD2_EXT_DATE = (
                SELECT MAX(SUKBD2_EXT_DATE)
                FROM ARS_SUKBD2_D_MF
                WHERE SUKBD2_EXT_DATE < @EXT_DATE
              ) AND
              MF.SUKBD2_TRADE_TYPE <> 'RP' AND
              TRIM(MF.SUKBD2_ISSUER_COUNTRY) <> 'TW' AND
              (MF.SUKBD2_END_DATE IS NULL OR
               DATEADD(DAY, @BufferDate, MF.SUKBD2_END_DATE) >= @EXT_DATE);

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT '發生錯誤: ' + @ErrorMsg;
        THROW;
    END CATCH
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		AllenChen
-- Create date: 2025/10/17
-- Description:	09SUKBDO衍伸性商品之資料擷取 交易最大日期

-- =============================================
CREATE PROCEDURE [dbo].[usp_Souce09_By_ARS_SUKBDO_D_MF] @EXT_DATE DATE
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

		INSERT INTO MonitorData (
			BRANCH_NO, UNIT_NO, PRODUCT_TYPE, TRAN_NO, GROUP_NO, TX_DATE,
			CUSTOMER_NAME, CUSTOMER_ID, COUNTRY_COD, CURENCY_COD, TRAN_AMOUNT,
			LIMIT, LIMIT_COD, MATURITY_DATE, AS_OF_DATE,  FIL9,
			SOURCE, CREATOR, LIMIT_MATURITY, INDUSTRY,INDUSTRY_Type, PRODUCT_CODE,EXT_DATE)
		SELECT
			trim(SUKBDO_BRANCH_NO) AS BRANCH_NO,
			CASE WHEN SUKBDO_BRANCH_NO IN('098','095','082') AND UPPER(TRIM(SUKBDO_DESK)) = 'STRUCTS_PD'
				THEN '089'
				ELSE '069'
			END AS DIVISION_NO,
			'07' AS PRODUCT_TYPE, -- 衍生性金融商品
			trim(SUKBDO_POSITIONID) AS TRAN_NO,
			'016' AS BUSINESS_UNIT,
			SUKBDO_TX_DATE	AS TX_DATE,
			trim(SUKBDO_CUST_NAME) AS CUSTOMER_NAME,
			trim(SUKBDO_CUSTOMER_ID) AS CUSTOMER_ID,
			trim(SUKBDO_CPTY_COUNTRY_RISK) AS COUNTRY_COD,
			'USD' AS CURENCY_COD,
			0 As TRAN_AMOUNT,
			--SUKBDO_RISK_AMT	AS TO_USD_AMT,
			--0 AS TO_USD_FXRATE,
			0 AS LIMIT,
			'USD' AS LIMIT_COD,
			--SUKBDO_RISK_AMT	AS TO_USD_LIMIT,
			SUKBDO_OPTIONEXPIRYDATE	AS MATURITY_DATE,
			SUKBDO_EXT_DATE AS AS_OF_DATE,
			'ARS_SUKBDO_D_MF' as FIL9,
			'09' as source,
			'system' as creator,
			SUKBDO_OPTIONEXPIRYDATE as LIMIT_MATURITY,
			TRIM(BUSINS_CODE) AS INDUSTRY,
			1,
			'BO' AS PRODUCT_CODE,
			@EXT_DATE AS EXT_DATE
		FROM ARS_SUKBDO_D_MF
		WHERE
			SUKBDO_EXT_DATE = (select max(SUKBDO_EXT_DATE)from ARS_SUKBDO_D_MF WHERE SUKBDO_EXT_DATE < @EXT_DATE) AND
			SUKBDO_BUY_SELL ='1' AND
			SUKBDO_CPTY_COUNTRY_RISK <> 'TW'


	END TRY
	BEGIN CATCH
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT '發生錯誤: ' + @ErrorMsg;
		THROW;
	END CATCH

END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		AllenChen
-- Create date: 2025/10/17
-- Description:	09ARS_SUKFRA_D_MF FRA衍伸性商品之資料擷取 交易最大日期

-- =============================================
CREATE PROCEDURE [dbo].[usp_Souce09_By_ARS_SUKFRA_D_MF] @EXT_DATE DATE
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

		INSERT INTO MonitorData (
			BRANCH_NO, UNIT_NO, PRODUCT_TYPE, TRAN_NO, GROUP_NO, TX_DATE,
			CUSTOMER_NAME, CUSTOMER_ID, COUNTRY_COD, CURENCY_COD, TRAN_AMOUNT,
			LIMIT, LIMIT_COD, MATURITY_DATE, AS_OF_DATE,  FIL9,
			SOURCE, CREATOR, LIMIT_MATURITY, INDUSTRY,INDUSTRY_Type, PRODUCT_CODE,EXT_DATE)
		SELECT
			trim(SUKFRA_BRANCH_NO) AS BRANCH_NO,
			CASE WHEN SUKFRA_BRANCH_NO IN('098','095','082') AND UPPER(TRIM(SUKFRA_SUPERVISOR)) = 'STRUCTS_PD'
				THEN '089'
				ELSE '069'
			END AS DIVISION_NO,
			'07' AS PRODUCT_TYPE, -- 衍生性金融商品
			trim(SUKFRA_TRADE_ID) AS TRAN_NO,
			'016' AS BUSINESS_UNIT,
			SUKFRA_TRADE_DATE AS TX_DATE,
			trim(SUKFRA_CUST_NAME2) AS CUSTOMER_NAME,
			trim(SUKFRA_CUSTOMER_ID) AS CUSTOMER_ID,
			trim(SUKFRA_CPTY_COUNTRY_RISK)	AS COUNTRY_COD,
			trim(SUKFRA_CCY)	AS CURENCY_COD,
			0 As TRAN_AMOUNT,
			--SUKFRA_RISK_AMT	AS TO_USD_AMT,
			--0		AS TO_USD_FXRATE,
			0 AS LIMIT,
			trim(SUKFRA_CCY) AS LIMIT_COD,
			--SUKFRA_RISK_AMT	AS     TO_USD_LIMIT,
			SUKFRA_MATURITY AS MATURITY_DATE,
			SUKFRA_EXT_DATE AS AS_OF_DATE,
			'ARS_SUKFRA_D_MF' as FIL9,
			'09' as source,
			'system' as creator,
			SUKFRA_MATURITY as LIMIT_MATURITY,
			TRIM(SUKFRA_CPTY_BUSINESS) AS INDUSTRY,
			1,
			'FRA',
			@EXT_DATE
		FROM ARS_SUKFRA_D_MF
		WHERE SUKFRA_EXT_DATE = (select max(SUKFRA_EXT_DATE) from ARS_SUKFRA_D_MF WHERE SUKFRA_EXT_DATE < @EXT_DATE) AND
			SUKFRA_BUY_SELL = '1' AND
			SUKFRA_CPTY_COUNTRY_RISK <> 'TW'


	END TRY
	BEGIN CATCH
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT '發生錯誤: ' + @ErrorMsg;
		THROW;
	END CATCH

END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		AllenChen
-- Create date: 2025/10/17
-- Description:	09ARS_SUKIRO_D_MF IRO衍伸性商品之資料擷取 交易最大日期

-- =============================================
CREATE PROCEDURE [dbo].[usp_Souce09_By_ARS_SUKIRO_D_MF] @EXT_DATE DATE
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

		INSERT INTO MonitorData (
		    BRANCH_NO, UNIT_NO, PRODUCT_TYPE, TRAN_NO, GROUP_NO, TX_DATE,
		    CUSTOMER_NAME, CUSTOMER_ID, COUNTRY_COD, CURENCY_COD, TRAN_AMOUNT,
		    LIMIT, LIMIT_COD, MATURITY_DATE, AS_OF_DATE,  FIL9,
		    SOURCE, CREATOR, LIMIT_MATURITY, INDUSTRY,INDUSTRY_Type, PRODUCT_CODE,EXT_DATE)
		SELECT
			trim(SUKIRO_BRANCH_NO) AS BRANCH_NO,
			CASE WHEN SUKIRO_BRANCH_NO IN('098','095','082') AND UPPER(TRIM(SUKIRO_SUPERVISOR)) = 'STRUCTS_PD'
				THEN '089'
				ELSE '069'
			END AS DIVISION_NO,
			'07' AS PRODUCT_TYPE, -- 衍生性金融商品
			trim(SUKIRO_TRADE_ID) AS TRAN_NO,
			'016' AS BUSINESS_UNIT,
			SUKIRO_TRADE_DATE AS TX_DATE,
			trim(SUKIRO_CUST_NAME2) AS CUSTOMER_NAME,
			trim(SUKIRO_CUSTOMER_ID) AS CUSTOMER_ID,
			trim(SUKIRO_CPTY_COUNTRY_RISK)	AS COUNTRY_COD,
			trim(SUKIRO_CCY)	AS CURENCY_COD,
			0 As TRAN_AMOUNT,
			--SUKIRO_RISK_AMT	AS TO_USD_AMT,
			--0 AS TO_USD_FXRATE,
			0 AS LIMIT,
			trim(SUKIRO_CCY) AS LIMIT_COD,
			--SUKIRO_RISK_AMT	AS TO_USD_LIMIT,
			SUKIRO_MATURITY_DATE	AS MATURITY_DATE,
			SUKIRO_EXT_DATE AS AS_OF_DATE,
			'ARS_SUKIRO_D_MF' as FIL9,
			'09' as source,
			'system' as creator,
			SUKIRO_MATURITY_DATE AS LIMIT_MATURITY,
			TRIM(SUKIRO_CPTY_BUSINESS) AS INDUSTRY,
			1,
			'IRO' AS PRODUCT_CODE,
			@EXT_DATE
		FROM
			ARS_SUKIRO_D_MF
		WHERE
			SUKIRO_EXT_DATE = (select max(SUKIRO_EXT_DATE) from ARS_SUKIRO_D_MF WHERE SUKIRO_EXT_DATE < @EXT_DATE) AND
			SUKIRO_BUY_SELL ='1' AND
			SUKIRO_CPTY_COUNTRY_RISK <> 'TW'

	END TRY
	BEGIN CATCH
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT '發生錯誤: ' + @ErrorMsg;
		THROW;
	END CATCH

END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		AllenChen
-- Create date: 2025/10/17
-- Description:	09ARS_SUKMST_D_MF IRS衍伸性商品之資料擷取 交易最大日期

-- =============================================
CREATE PROCEDURE [dbo].[usp_Souce09_By_ARS_SUKMST_D_MF] @EXT_DATE DATE
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

		INSERT INTO MonitorData (
			BRANCH_NO, UNIT_NO, PRODUCT_TYPE, TRAN_NO, GROUP_NO, TX_DATE,
			CUSTOMER_NAME, CUSTOMER_ID, COUNTRY_COD, CURENCY_COD, TRAN_AMOUNT,
			LIMIT, LIMIT_COD, MATURITY_DATE, AS_OF_DATE,  FIL9,
			SOURCE, CREATOR, LIMIT_MATURITY, INDUSTRY,INDUSTRY_Type, PRODUCT_CODE,EXT_DATE)
		SELECT
			trim(SUKMST_BRANCH_NO) AS BRANCH_NO,
			CASE WHEN SUKMST_BRANCH_NO IN('098','095','082') AND UPPER(TRIM(SUKMST_SUPERVISOR)) = 'STRUCTS_PD'
				THEN '089'
				ELSE '069'
			END AS DIVISION_NO,
			'07' AS PRODUCT_TYPE, -- 衍生性金融商品
			trim(SUKMST_TRAN_NO) AS TRAN_NO,
			'016' AS BUSINESS_UNIT,
			SUKMST_TRADE_DATE AS TX_DATE,
			trim(SUKMST_CUST_NAME2) AS CUSTOMER_NAME,
			trim(SUKMST_CUSTOMER_ID) AS CUSTOMER_ID,
			trim(SUKMST_CPTY_COUNTRY_RISK)	AS COUNTRY_COD,
			trim(SUKMST_OUT_CCY) AS CURENCY_COD,
			0 As TRAN_AMOUNT,
			--SUKMST_RISK_AMT	AS TO_USD_AMT,
			--0 AS TO_USD_FXRATE,
			0 AS LIMIT,
			trim(SUKMST_OUT_CCY) AS LIMIT_COD,
			--SUKMST_RISK_AMT	AS TO_USD_LIMIT,
			SUKMST_MATURITY	AS MATURITY_DATE,
			SUKMST_EXT_DATE AS AS_OF_DATE,
			'ARS_SUKMST_D_MF' as FIL9,
			'09' as source,
			'system' as creator,
			SUKMST_MATURITY as LIMIT_MATURITY,
			TRIM(SUKMST_CPTY_BUSINESS) AS INDUSTRY,
			1,
			'IRS' AS PRODUCT_CODE,
			@EXT_DATE AS EXT_DATE
		FROM ARS_SUKMST_D_MF MF
		WHERE
			SUKMST_EXT_DATE = (SELECT MAX(SUKMST_EXT_DATE) FROM ARS_SUKMST_D_MF WHERE SUKMST_EXT_DATE < @EXT_DATE) AND
			SUKMST_BUY_SELL ='1' AND
			ISNULL(SUKMST_DEPOSIT_LINK,'') NOT IN('SPD','DCD') AND
			SUKMST_ESTIMATE_FX <> 0 AND -- 因為SUMMIT來的資料有時會給0，計算會錯(不可以除以0)，要排除
			SUKMST_CPTY_COUNTRY_RISK <> 'TW'

	END TRY
	BEGIN CATCH
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT '發生錯誤: ' + @ErrorMsg;
		THROW;
	END CATCH

END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		AllenChen
-- Create date: 2025/10/17
-- Description:	09SUKNBD1債券投資之資料擷取 交易最大日期

-- =============================================
CREATE PROCEDURE [dbo].[usp_Souce09_By_ARS_SUKNBD1_D_MF] @EXT_DATE DATE
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		INSERT INTO MonitorData (
			BRANCH_NO, UNIT_NO, PRODUCT_TYPE, TRAN_NO, GROUP_NO, TX_DATE,
			CUSTOMER_NAME, CUSTOMER_ID, COUNTRY_COD, CURENCY_COD, TRAN_AMOUNT,
			PERMIT_NO, LIMIT, LIMIT_COD, MATURITY_DATE, AS_OF_DATE, REVOLVE_MK, FIL9,
			SOURCE, CREATOR, LIMIT_MATURITY, INDUSTRY,INDUSTRY_Type,EXT_DATE)
		SELECT
			TRIM(SUKBD1_BRANCH_NO) AS BRANCH_NO,
			CASE WHEN SUKBD1_BRANCH_NO IN('098','095','082') AND UPPER(TRIM(SUKBD1_SUPERVISOR)) = 'STRUCTS_PD'
				THEN '089'
				ELSE '069'
			END AS DIVISION_NO,
			'08' AS PRODUCT_TYPE,
			TRIM(SUKBD1_TRAN_NO) AS TRAN_NO,
			'016' AS BUSINESS_UNIT,
			SUKBD1_TX_DATE AS TX_DATE,
			TRIM(SUKBD1_CUST_NAME1) AS CUSTOMER_NAME,
			TRIM(SUKBD1_SWIFT_ID) AS CUSTOMER_ID,
			ISNULL(NULLIF(SUKBD1_ISSUER_COUNTRY,''), TRIM(SUKBD1_GU_LOG_CTY)) AS COUNTRY_COD,
			TRIM(SUKBD1_CURENCY_COD) AS CURENCY_COD,
			CASE UPPER(TRIM(SUKBD1_BUY_SELL)) WHEN 'B' THEN SUKBD1_BALANCE_AMT
											  WHEN 'S' THEN SUKBD1_BALANCE_AMT * -1
			END As TRAN_AMOUNT,
			SUKBD1_LINE_PERMIT_NO AS PERMIT_NO,
			CASE UPPER(TRIM(SUKBD1_BUY_SELL)) WHEN 'B' THEN SUKBD1_BALANCE_AMT
											  WHEN 'S' THEN SUKBD1_BALANCE_AMT * -1
			END AS LIMIT,
			TRIM(SUKBD1_CURENCY_COD) AS LIMIT_COD,
			SUKBD1_MATURITY_DATE AS MATURITY_DATE,
			SUKBD1_EXT_DATE AS AS_OF_DATE,
			0 AS REVOLVE_MK,
			'ARS_SUKNBD1_D_MF' as FIL9,
			'09' as source,
			'system' as creator,
			SUKBD1_MATURITY_DATE as LIMIT_MATURITY,
			TRIM(SUKBD1_ISSUER_BUSINESS) AS INDUSTRY,
			1,
			@EXT_DATE AS EXT_DATE
		FROM ARS_SUKNBD1_D_MF
		WHERE SUKBD1_EXT_DATE = (SELECT MAX(SUKBD1_EXT_DATE) FROM ARS_SUKNBD1_D_MF WHERE SUKBD1_EXT_DATE < @EXT_DATE) AND
			EXISTS (
				SELECT 1
				FROM ARS_SUKNBD1_D_MF MF2
				WHERE MF2.SUKBD1_EXT_DATE = ARS_SUKNBD1_D_MF.SUKBD1_EXT_DATE AND
					  MF2.SUKBD1_CUST_NAME1 = ARS_SUKNBD1_D_MF.SUKBD1_CUST_NAME1 AND
					  ISNULL(NULLIF(MF2.SUKBD1_ISSUER_COUNTRY,''), TRIM(MF2.SUKBD1_GU_LOG_CTY)) <> 'TW'
				GROUP BY MF2.SUKBD1_CUST_NAME1
				HAVING SUM( CASE UPPER(TRIM(MF2.SUKBD1_BUY_SELL)) WHEN 'B' THEN MF2.SUKBD1_BALANCE_AMT
																  WHEN 'S' THEN MF2.SUKBD1_BALANCE_AMT * -1
							END) > 0
			) AND
			ISNULL(NULLIF(SUKBD1_ISSUER_COUNTRY,''), TRIM(SUKBD1_GU_LOG_CTY))  <> 'TW' AND
			NOT(SUKBD1_MATURITY_DATE = SUKBD1_EXT_DATE AND
				SUKBD1_CURENCY_COD = 'TWD' AND
				SUKBD1_SECURITY_TYPE = 'BILL' AND
				SUKBD1_SEC_SUB_TYPE ='CP2');
	END TRY
	BEGIN CATCH
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT '發生錯誤: ' + @ErrorMsg;
		THROW;
	END CATCH

END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		AllenChen
-- Create date: 2025/10/17
-- Description:	09SUKNFO 衍生性商品(外匯選擇權) 交易最大日期

-- =============================================
CREATE PROCEDURE [dbo].[usp_Souce09_By_ARS_SUKNFO_D_MF] @EXT_DATE DATE
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		-- 衍生性金融商品資料
		INSERT INTO MonitorData (
			BRANCH_NO, UNIT_NO, PRODUCT_TYPE, TRAN_NO, GROUP_NO, TX_DATE,
			CUSTOMER_NAME, CUSTOMER_ID, COUNTRY_COD, CURENCY_COD, TRAN_AMOUNT,
			LIMIT, LIMIT_COD, MATURITY_DATE, AS_OF_DATE, FIL9,
			SOURCE, CREATOR, LIMIT_MATURITY, INDUSTRY,INDUSTRY_Type,CUR_BOUGHT,CUR_SOLD,EXT_DATE)
		SELECT
			TRIM(SUKFO_ACC_BRANCH_NO) AS BRANCH_NO,
			CASE WHEN SUKFO_ACC_BRANCH_NO IN('098','095','082') AND UPPER(TRIM(SUKFO_SUPERVISOR)) = 'STRUCTS_PD'
				THEN '089'
				ELSE '069'
			END AS DIVISION_NO,
			'07' AS PRODUCT_TYPE,                                   -- 衍生性金融商品
			TRIM(SUKFO_TRADE_ID) AS TRAN_NO,
			'016' AS BUSINESS_UNIT,
			SUKFO_TRADE_DATE AS TX_DATE,
			TRIM(SUKFO_CPTY_NAME) AS CUSTOMER_NAME,
			TRIM(SUKFO_BANK_SWIFT_ID) AS CUSTOMER_ID,
			TRIM(SUKFO_CPTY_COUNTRY_RISK) AS COUNTRY_COD,
			TRIM(SUKFO_OBJECT_CCY) AS CURENCY_COD,
			SUKFO_OBJECT_AMT AS TRAN_AMOUNT,
			SUKFO_OBJECT_AMT AS LIMIT,
			TRIM(SUKFO_OBJECT_CCY) AS LIMIT_COD,
			SUKFO_VALUE_DATE0 AS MATURITY_DATE,
			SUKFO_EXT_DATE AS AS_OF_DATE,
			'ARS_SUKNFO_D_MF' as FIL9,
			'09' as source,
			'system' as creator,
			SUKFO_VALUE_DATE0 as LIMIT_MATURITY,
			TRIM(SUKFO_CPTY_BUSINESS) AS INDUSTRY,
			1,
			TRIM(SUKFO_TRAN_BUY) AS CUR_BOUGHT,
			TRIM(SUKFO_TRAN_SELL) AS CUR_SOLD,
			@EXT_DATE
		FROM ARS_SUKNFO_D_MF
		WHERE
			SUKFO_EXT_DATE = (select max(SUKFO_EXT_DATE) from ARS_SUKNFO_D_MF WHERE SUKFO_EXT_DATE < @EXT_DATE)
			AND SUKFO_TRAN_TYPE = 'B'
			AND SUKFO_CPTY_NAME <> 'DCD_ONLINE'
			AND SUKFO_PRAM_CCY IS NULL
			AND SUKFO_CPTY_COUNTRY_RISK <> 'TW';
	END TRY
	BEGIN CATCH
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT '發生錯誤: ' + @ErrorMsg;
		THROW;
	END CATCH

END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		AllenChen
-- Create date: 2025/10/17
-- Description:	09SUKNFX 衍生性商品(NDF及保證金交易)之資料擷取 交易最大日期

-- =============================================
CREATE PROCEDURE [dbo].[usp_Souce09_By_ARS_SUKNFX_D_MF] @EXT_DATE DATE
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		INSERT INTO MonitorData (
			BRANCH_NO, UNIT_NO, PRODUCT_TYPE, TRAN_NO, GROUP_NO, TX_DATE,
			CUSTOMER_NAME, CUSTOMER_ID, COUNTRY_COD, CURENCY_COD, TRAN_AMOUNT,
			PERMIT_NO, LIMIT, LIMIT_COD, MATURITY_DATE, AS_OF_DATE, REVOLVE_MK, FIL9,
			SOURCE, CREATOR, LIMIT_MATURITY, INDUSTRY,INDUSTRY_Type,CUR_BOUGHT,CUR_SOLD,EXT_DATE)
		SELECT
			TRIM(SUKFX_BRANCH_NO) AS BRANCH_NO,
			CASE
				WHEN SUBSTRING(SUKFX_CUSTOMER_ID, 2, 1) < 'A' AND SUKFX_TX_TYPE IN('02', '03') THEN '077'
				WHEN SUKFX_BRANCH_NO IN('098','095','082') AND UPPER(TRIM(SUKFX_SUPERVISOR)) = 'STRUCTS_PD'
				THEN '089'
				ELSE '069'
				END AS DIVISION_NO,
			'07' AS PRODUCT_TYPE,
			TRIM(SUKFX_TRAN_NO) AS TRAN_NO,
			CASE WHEN SUBSTRING(SUKFX_CUSTOMER_ID, 2, 1) < 'A' AND SUKFX_TX_TYPE IN('02', '03') THEN '018'
				 ELSE '016' END AS BUSINESS_UNIT,
			SUKFX_TX_DATE AS TX_DATE,
			TRIM(SUKFX_CUST_NAME1) AS CUSTOMER_NAME,
			TRIM(SUKFX_CUSTOMER_ID) AS CUSTOMER_ID,
			TRIM(SUKFX_CPTY_COUNTRY_RISK) AS COUNTRY_COD,
			TRIM(SUKFX_OBJECT_CCY) AS CURENCY_COD,
			SUKFX_OBJECT_AMT As TRAN_AMOUNT,
			NULL AS PERMIT_NO,
			SUKFX_OBJECT_AMT AS LIMIT,
			TRIM(SUKFX_OBJECT_CCY) AS LIMIT_COD,
			SUKFX_VALUE_DATE0 AS MATURITY_DATE,
			SUKFX_EXT_DATE AS AS_OF_DATE,
			0 AS REVOLVE_MK,
			'ARS_SUKNFX_D_MF' as FIL9,
			'09' as source,
			'system' as creator,
			SUKFX_VALUE_DATE0 as LIMIT_MATURITY,
			TRIM(SUKFX_CPTY_BUSINESS) AS INDUSTRY,
			1,
			SUKFX_CUR_BOUGHT AS CUR_BOUGHT,
			SUKFX_CUR_SOLD AS CUR_SOLD,
			@EXT_DATE
		FROM ARS_SUKNFX_D_MF
		WHERE SUKFX_EXT_DATE = (select MAX(SUKFX_EXT_DATE) FROM ARS_SUKNFX_D_MF WHERE SUKFX_EXT_DATE < @EXT_DATE) AND
				SUKFX_TX_TYPE IN('02', '03', '04', '05') AND
				SUKFX_CPTY_COUNTRY_RISK <> 'TW';
	END TRY
	BEGIN CATCH
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT '發生錯誤: ' + @ErrorMsg;
		THROW;
	END CATCH

END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		AllenChen
-- Create date: 2025/10/17
-- Description:	09SUKNIRS 衍生性商品(IRS及CCS)之資料擷取 交易最大日期

-- =============================================
CREATE PROCEDURE [dbo].[usp_Souce09_By_ARS_SUKNIRS_D_MF] @EXT_DATE DATE
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		INSERT INTO MonitorData (
			BRANCH_NO, UNIT_NO, PRODUCT_TYPE, TRAN_NO, GROUP_NO, TX_DATE,
			CUSTOMER_NAME, CUSTOMER_ID, COUNTRY_COD, CURENCY_COD, TRAN_AMOUNT,
			LIMIT, LIMIT_COD, MATURITY_DATE, AS_OF_DATE, FIL9,
			SOURCE, CREATOR, LIMIT_MATURITY, INDUSTRY,INDUSTRY_Type,PRODUCT_CODE,EXT_DATE)
		SELECT
			TRIM(SUKIRS_BRANCH_NO) AS BRANCH_NO,
			CASE WHEN SUKIRS_BRANCH_NO IN('098','095','082') AND UPPER(TRIM(SUKIRS_SUPERVISOR)) = 'STRUCTS_PD'
				THEN '089'
				ELSE '069'
			END AS DIVISION_NO,
			'07' AS PRODUCT_TYPE,
			TRIM(SUKIRS_TRAN_NO) AS TRAN_NO,
			'016' AS BUSINESS_UNIT,
			SUKIRS_TX_DATE AS TX_DATE,
			TRIM(SUKIRS_CUST_NAME1) AS CUSTOMER_NAME,
			TRIM(SUKIRS_CUSTOMER_ID) AS CUSTOMER_ID,
			TRIM(SUKIRS_CPTY_COUNTRY_RISK) AS COUNTRY_COD,
			TRIM(SUKIRS_IN_CCY) AS CURENCY_COD,
			SUKIRS_IN_AMT As TRAN_AMOUNT,
			SUKIRS_IN_AMT AS LIMIT,
			TRIM(SUKIRS_IN_CCY) AS LIMIT_COD,
			SUKIRS_MATURITY AS MATURITY_DATE,
			SUKIRS_EXT_DATE AS AS_OF_DATE,
			'ARS_SUKNIRS_D_MF' as FIL9,
			'09' as source,
			'system' as creator,
			SUKIRS_MATURITY as LIMIT_MATURITY,
			TRIM(SUKIRS_CPTY_BUSINESS) AS INDUSTRY,
			1,
			CASE TRIM(SUKIRS_TX_TYPE) WHEN '01' THEN 'QS'
			ELSE 'IRS'
			END AS PRODUCT_CODE,
			@EXT_DATE AS EXT_DATE
		FROM ARS_SUKNIRS_D_MF
		WHERE
			SUKIRS_EXT_DATE = (SELECT MAX(SUKIRS_EXT_DATE) FROM ARS_SUKNIRS_D_MF WHERE SUKIRS_EXT_DATE < @EXT_DATE) AND
			ISNULL(SUKIRS_DEPOSIT_LINK,'') NOT IN ('SPD','DCD') AND
			SUKIRS_CPTY_COUNTRY_RISK <> 'TW';
	END TRY
	BEGIN CATCH
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT '發生錯誤: ' + @ErrorMsg;
		THROW;
	END CATCH

END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		AllenChen
-- Create date: 2025/10/17
-- Description:	09SUKNMM 拆款業務之資料擷取 交易最大日期

-- =============================================
CREATE PROCEDURE [dbo].[usp_Souce09_By_ARS_SUKNMM_D_MF] @EXT_DATE DATE
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		INSERT INTO MonitorData (
			BRANCH_NO, UNIT_NO, PRODUCT_TYPE, TRAN_NO, GROUP_NO, TX_DATE,
			CUSTOMER_NAME, CUSTOMER_ID, COUNTRY_COD, CURENCY_COD, TRAN_AMOUNT,
			PERMIT_NO, LIMIT, LIMIT_COD, MATURITY_DATE, AS_OF_DATE, REVOLVE_MK, FIL9,
			SOURCE, CREATOR, LIMIT_MATURITY, INDUSTRY,INDUSTRY_Type,EXT_DATE)
		SELECT
			TRIM(SUKMM_BRANCH_NO) AS BRANCH_NO,
			CASE WHEN SUKMM_BRANCH_NO IN('098','095','082') AND UPPER(TRIM(SUKMM_SUPERVISOR)) = 'STRUCTS_PD'
				THEN '089'
				ELSE '069'
			END AS DIVISION_NO,
			CASE TRIM(SUKMM_TRN_TYPE) WHEN '1' THEN '09'   -- 「09拆款」
									  WHEN '3' THEN '04'   -- 「04存同」
				 END AS PRODUCT_TYPE,
			TRIM(SUKMM_TRAN_NO) AS TRAN_NO,
			'016' AS BUSINESS_UNIT,
			SUKMM_TX_DATE AS TX_DATE,
			TRIM(SUKMM_CUST_NAME1) AS CUSTOMER_NAME,
			TRIM(SUKMM_SWIFT_ID) AS CUSTOMER_ID,
			TRIM(SUKMM_COUNTRY_RISK) AS COUNTRY_COD,
			TRIM(SUKMM_CURENCY_COD) AS CURENCY_COD,
			ABS(SUKMM_TRAN_AMOUNT) AS TRAN_AMOUNT,
			NULL AS PERMIT_NO,
			ABS(SUKMM_TRAN_AMOUNT) AS [LIMIT],
			TRIM(SUKMM_CURENCY_COD) AS LIMIT_COD,
			SUKMM_MATURITY_DATE AS MATURITY_DATE,
			SUKMM_EXT_DATE AS AS_OF_DATE,
			1 AS REVOLVE_MK,
			'ARS_SUKNMM_D_MF' AS FIL9,
			'09' AS source,
			'system' AS creator,
			SUKMM_MATURITY_DATE AS LIMIT_MATURITY,
			TRIM(SUKMM_CPTY_TYPE) AS INDUSTRY,
			1,
			@EXT_DATE AS EXT_DATE
		FROM ARS_SUKNMM_D_MF
		WHERE
			SUKMM_EXT_DATE = (select max(SUKMM_EXT_DATE) from ARS_SUKNMM_D_MF WHERE SUKMM_EXT_DATE < @EXT_DATE) AND
			(SUKMM_MATURITY_DATE IS NULL OR SUKMM_MATURITY_DATE > SUKMM_EXT_DATE) AND -- 並去除當日到期之資料
			TRIM(SUKMM_TRN_TYPE) IN ('1','3') AND -- 只抓取正的
			SUKMM_COUNTRY_RISK <> 'TW' AND
			--(
			--	-- 條件1：非 group_id = '99999' 的客戶
			--	(TRIM(SUKMM_CUST_NAME1) NOT IN (SELECT customer_name FROM groupdata WHERE group_id = '99999'))
			--	OR
			--	-- 條件2：group_id = '99999' 的客戶，但排除 TWD 幣別
			--	(TRIM(SUKMM_CUST_NAME1) IN (SELECT customer_name FROM groupdata WHERE group_id = '99999')
			--	 AND SUKMM_CURENCY_COD <> 'TWD')
			--) AND
			EXISTS (
				SELECT 1
				FROM ARS_SUKNMM_D_MF MF2
				WHERE	MF2.SUKMM_TRN_TYPE = ARS_SUKNMM_D_MF.SUKMM_TRN_TYPE AND -- 只抓取正的
						MF2.SUKMM_COUNTRY_RISK = ARS_SUKNMM_D_MF.SUKMM_COUNTRY_RISK AND
						MF2.SUKMM_EXT_DATE = ARS_SUKNMM_D_MF.SUKMM_EXT_DATE AND
						MF2.SUKMM_MATURITY_DATE = ARS_SUKNMM_D_MF.SUKMM_MATURITY_DATE AND
						LEFT(MF2.SUKMM_SWIFT_ID, 4) = LEFT(SUKMM_SWIFT_ID, 4)
				GROUP BY LEFT(MF2.SUKMM_SWIFT_ID, 4)
				HAVING SUM(ABS(MF2.SUKMM_TRAN_AMOUNT)) > 0)
	END TRY
	BEGIN CATCH
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT '發生錯誤: ' + @ErrorMsg;
		THROW;
	END CATCH

END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		AllenChen
-- Create date: 2025/10/17
-- Description:	09SUKSWP 之資料擷取 交易最大日期

-- =============================================
CREATE PROCEDURE [dbo].[usp_Souce09_By_ARS_SUKSWP_D_MF] @EXT_DATE DATE
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		INSERT INTO MonitorData (
			BRANCH_NO, UNIT_NO, PRODUCT_TYPE, TRAN_NO, GROUP_NO, TX_DATE,
			CUSTOMER_NAME, CUSTOMER_ID, COUNTRY_COD, CURENCY_COD, TRAN_AMOUNT,
			LIMIT, LIMIT_COD, MATURITY_DATE, AS_OF_DATE, FIL9,
			SOURCE, CREATOR, LIMIT_MATURITY, INDUSTRY,INDUSTRY_Type,PRODUCT_CODE,EXT_DATE)
		SELECT
			TRIM(SUKSWP_BRANCH_NO) AS BRANCH_NO,
			CASE WHEN SUKSWP_BRANCH_NO IN('098','095','082') AND UPPER(TRIM(SUKSWP_SUPERVISOR)) = 'STRUCTS_PD'
				THEN '089'
				ELSE '069'
			END AS DIVISION_NO,
			'07' AS PRODUCT_TYPE,
			TRIM(SUKSWP_EXTERNAL_ID) AS TRAN_NO,
			'016' AS BUSINESS_UNIT,
			SUKSWP_TX_DATE AS TX_DATE,
			TRIM(SUKSWP_CUST_NAME) AS CUSTOMER_NAME,
			TRIM(SUKSWP_CUSTOMER_ID) AS CUSTOMER_ID,
			TRIM(SUKSWP_CPTY_COUNTRY_RISK) AS COUNTRY_COD,
			TRIM(SUKSWP_CURRENCY) AS CURENCY_COD,
			0 As TRAN_AMOUNT,
			--SUKSWP_RISK_AMT AS TO_USD_AMT,
			--0 AS TO_USD_FXRATE,
			0 AS LIMIT,
			TRIM(SUKSWP_CURRENCY) AS LIMIT_COD,
			--SUKSWP_RISK_AMT AS TO_USD_LIMIT,
			SUKSWP_OPTIONEXPIRYDATE AS MATURITY_DATE,
			SUKSWP_EXT_DATE AS AS_OF_DATE,
			'ARS_SUKSWP_D_MF' as FIL9,
			'09' as source,
			'system' as creator,
			SUKSWP_OPTIONEXPIRYDATE as LIMIT_MATURITY,
			TRIM(SUKSWP_CPTY_BUSINESS) AS INDUSTRY,
			1,
			'IRO' AS PRODUCT_CODE,
			@EXT_DATE AS EXT_DATE
		FROM ARS_SUKSWP_D_MF
		WHERE SUKSWP_EXT_DATE = (select max(SUKSWP_EXT_DATE) from ARS_SUKSWP_D_MF WHERE SUKSWP_EXT_DATE < @EXT_DATE) AND
			SUKSWP_BUY_SELL ='B' AND
			SUKSWP_CPTY_COUNTRY_RISK <> 'TW';
	END TRY
	BEGIN CATCH
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT '發生錯誤: ' + @ErrorMsg;
		THROW;
	END CATCH

END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		AllenChen
-- Create date: 2025/10/17
-- Description:	轉檔流程呼叫入口

-- =============================================
CREATE PROCEDURE [dbo].[usp_TransferData] @EXT_DATE AS DATE
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		IF @EXT_DATE IS NULL
			THROW 50000, '@EXT_DATE 為空值', 1;
		Delete MONITORDATA
		Where DATADATE = @EXT_DATE
		-- DW 資料轉檔
		exec usp_Souce01_OBBS_By_OS_LNSMSTD_D_MF_OS_LNSLMSD_D_MF @EXT_DATE
		exec usp_Souce01_OBBS_By_OSBDKF02_MF @EXT_DATE
		exec usp_Souce01_OBBS_By_OSFXKF02_MF @EXT_DATE
		exec usp_Souce01_OBBS_By_OSISKF02_MF @EXT_DATE
		exec usp_Souce01_OBBS_By_OSMMKF02_MF @EXT_DATE
		exec usp_Souce04_By_LS_LSRSA_D_MF_ACNOD_STG @EXT_DATE
		exec usp_Souce06_By_FL_FLMST_D_MF @EXT_DATE  -- 慢
		exec usp_Souce09_By_ARS_SUKBDO_D_MF @EXT_DATE
		exec usp_Souce09_By_ARS_SUKFRA_D_MF @EXT_DATE
		exec usp_Souce09_By_ARS_SUKIRO_D_MF @EXT_DATE
		exec usp_Souce09_By_ARS_SUKMST_D_MF @EXT_DATE
		exec usp_Souce09_By_ARS_SUKNBD1_D_MF @EXT_DATE -- 慢
		exec usp_Souce09_By_ARS_SUKNFO_D_MF @EXT_DATE
		exec usp_Souce09_By_ARS_SUKNFX_D_MF @EXT_DATE
		exec usp_Souce09_By_ARS_SUKNIRS_D_MF @EXT_DATE
		exec usp_Souce09_By_ARS_SUKNMM_D_MF @EXT_DATE
		exec usp_Souce09_By_ARS_SUKSWP_D_MF @EXT_DATE

	END TRY
	BEGIN CATCH
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT '發生錯誤: ' + @ErrorMsg;
		THROW;
	END CATCH

END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Create date: 20260807
-- Description:	依 WEIGHTS（usp_UpdateMonitorDataCNWeights）與 RISKFACTOR
--   （usp_UpdateMonitorDataPruduct07RiskFactor）套用後的計算後美金金額，
--   落地至 CAL_TO_USD_AMT／CAL_TO_USD_LIMIT。
-- 執行順序：必須排在 usp_UpdateMonitorDataFPEXR_RateUSD、
--   usp_UpdateMonitorDataCNWeights、usp_UpdateMonitorDataPruduct07RiskFactor 之後執行。
-- TODO：CAL_TO_USD_AMT／CAL_TO_USD_LIMIT 的實際計算公式待補（依 WEIGHTS/RISKFACTOR
--   套用規則），目前僅建立 SP 骨架與欄位落地位置，SET 子句先寫成 no-op。
-- =============================================
CREATE   PROCEDURE [dbo].[usp_UpdateMonitorDataCalculatedUsdAmount](@EXT_DATE AS DATE)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		UPDATE M
		SET
			-- TODO: 套用 WEIGHTS/RISKFACTOR 的計算公式，例如：
			CAL_TO_USD_AMT = M.TO_USD_AMT * M.WEIGHTS * M.RISKFACTOR,
			-- TODO: 套用 WEIGHTS/RISKFACTOR 的計算公式
			CAL_TO_USD_LIMIT = M.TO_USD_LIMIT * M.WEIGHTS * M.RISKFACTOR
		FROM MONITORDATA M
		WHERE M.EXT_DATE = @EXT_DATE;
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
		PRINT '發生錯誤: ' + @ErrorMsg;
		THROW;
	END CATCH
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Allen
-- Create date: 20250923
-- Description:	將指定轉入日期的MonitorData Update WEIGHTS 中國權重
-- =============================================
CREATE PROCEDURE [dbo].[usp_UpdateMonitorDataCNWeights](@EXT_DATE AS DATE)
AS
BEGIN
	SET NOCOUNT ON;
    BEGIN TRY
		-- 指定客戶名稱，且中國交易國的中國權重為0
		-- 建立表格變數存放要排除的客戶
		DECLARE @ExcludedCustomers TABLE (
			CustomerName NVARCHAR(255)
		);
		-- 插入要排除的客戶名稱
		INSERT INTO @ExcludedCustomers (CustomerName) VALUES
			('BOC_CNT'),
			('CCB_TPDBU'),
			('BKCOMM_TPE'),
			('BOC_TPE_DBU'),
			('BANK OF CHINA LTD. TAIPEI'),
			('CHINA CONSTRUCTION BK CORP. TAIPEI'),
			('BANK OF COMMUNICATIONS, TAIPEI'),
			('BANK OF CHINA LIMITED TAIPEI BRANCH');
		-- 中國風險加權計算方式
		-- 1. 指定客戶 為 0
		-- 2. 到期日天數 小於 92 為 20
		-- 3. 其餘 100
		UPDATE M SET WEIGHTS = CASE WHEN EXISTS (
											SELECT 1
											FROM @ExcludedCustomers e
											WHERE e.CustomerName = M.CUSTOMER_NAME
										) THEN '0'
									WHEN DATEDIFF(DAY,@EXT_DATE,M.MATURITY_DATE) < 92 THEN 20
									ELSE 100 END
		FROM MONITORDATA M
		WHERE M.EXT_DATE = @EXT_DATE AND COUNTRY_COD = 'CN'
	END TRY
    BEGIN CATCH
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT '發生錯誤: ' + @ErrorMsg;
        THROW;
    END CATCH
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Allen
-- Create date: 20250916
-- Description:	將指定轉入日期的MonitorData Update 交易金額(美金)核准金額(美金)與交易匯率更新
-- Modify:		新增 TRAN_FXRATE／LIMIT_FXRATE 落地保存實際套用的匯率，供追溯與後續計算使用
-- =============================================
CREATE PROCEDURE [dbo].[usp_UpdateMonitorDataFPEXR_RateUSD](@EXT_DATE AS DATE)
AS
BEGIN
	SET NOCOUNT ON;
    BEGIN TRY
		-- 交易金額(美金)與交易匯率更新
		--非柬埔寨幣使用FPEXR_STG(FPEXR_STG是台幣匯率檔，要再除一次美金)
		-- 柬埔寨幣用ACOLRT_STG 匯率檔
		UPDATE M
		SET
			TRAN_FXRATE = CASE
				WHEN M.CURENCY_COD = 'KHR' THEN ACO_TRAN.ACOLRT_RATE
				WHEN M.CURENCY_COD = 'TWD' THEN 1 / FPE2_TRAN.FPEXR_RATE
				ELSE FPE_TRAN.FPEXR_RATE / FPE2_TRAN.FPEXR_RATE
			END,
			TO_USD_AMT = CASE
				WHEN M.CURENCY_COD = 'KHR' THEN M.TRAN_AMOUNT * ACO_TRAN.ACOLRT_RATE
				WHEN M.CURENCY_COD = 'TWD' THEN M.TRAN_AMOUNT / FPE2_TRAN.FPEXR_RATE
				ELSE M.TRAN_AMOUNT * FPE_TRAN.FPEXR_RATE / FPE2_TRAN.FPEXR_RATE
			END,
			LIMIT_FXRATE = CASE
				WHEN M.LIMIT_COD = 'KHR' THEN ACO_LIMIT.ACOLRT_RATE
				WHEN M.LIMIT_COD = 'TWD' THEN 1 / FPE2_TRAN.FPEXR_RATE
				WHEN M.LIMIT_COD IS NULL THEN  -- 如果沒有額度幣別，使用交易幣別
					CASE
						WHEN M.CURENCY_COD = 'KHR' THEN ACO_TRAN.ACOLRT_RATE
						ELSE FPE_TRAN.FPEXR_RATE / FPE2_TRAN.FPEXR_RATE
					END
				ELSE FPE_LIMIT.FPEXR_RATE / FPE2_LIMIT.FPEXR_RATE
			END,
			TO_USD_LIMIT = CASE
				WHEN M.LIMIT_COD = 'KHR' THEN M.LIMIT * ACO_LIMIT.ACOLRT_RATE
				WHEN M.LIMIT_COD = 'TWD' THEN M.LIMIT / FPE2_TRAN.FPEXR_RATE
				WHEN M.LIMIT_COD IS NULL THEN  -- 如果沒有額度幣別，使用交易幣別
					CASE
						WHEN M.CURENCY_COD = 'KHR' THEN M.LIMIT * ACO_TRAN.ACOLRT_RATE
						ELSE M.LIMIT * FPE_TRAN.FPEXR_RATE / FPE2_TRAN.FPEXR_RATE
					END
				ELSE M.LIMIT * FPE_LIMIT.FPEXR_RATE / FPE2_LIMIT.FPEXR_RATE
			END
		FROM MONITORDATA M
		-- 交易幣別代號 JOIN
		INNER JOIN MIS_CRCY_REF CRCY_TRAN ON CRCY_TRAN.CRCY_ENG_NAME = M.CURENCY_COD
		-- 匯率檔JOIN
		LEFT JOIN FPEXR_STG FPE_TRAN ON CRCY_TRAN.CRCY_CODE = FPE_TRAN.FPEXR_CRCY_CODE
			AND FPE_TRAN.FPEXR_DATE = M.AS_OF_DATE
			AND M.CURENCY_COD <> 'KHR'
		-- 匯率檔美金
		LEFT JOIN FPEXR_STG FPE2_TRAN ON FPE2_TRAN.FPEXR_CRCY_CODE = '01'
			AND FPE2_TRAN.FPEXR_DATE =  M.AS_OF_DATE
			AND M.CURENCY_COD <> 'KHR'
		-- 匯率檔2 美金
		LEFT JOIN ACOLRT_STG ACO_TRAN ON CRCY_TRAN.CRCY_CODE = ACO_TRAN.ACOLRT_CURENCY
			AND ACO_TRAN.ACOLRT_DATE = M.AS_OF_DATE
			AND ACO_TRAN.ACOLRT_LOCAL_CURENCY = '01'
			AND M.CURENCY_COD = 'KHR'
		-- 核准額度幣別相關JOIN（僅當額度幣別存在且不同於交易幣別時）
		LEFT JOIN MIS_CRCY_REF CRCY_LIMIT ON CRCY_LIMIT.CRCY_ENG_NAME = M.LIMIT_COD
			AND M.LIMIT_COD IS NOT NULL
		LEFT JOIN FPEXR_STG FPE_LIMIT ON CRCY_LIMIT.CRCY_CODE = FPE_LIMIT.FPEXR_CRCY_CODE
			AND FPE_LIMIT.FPEXR_DATE = M.AS_OF_DATE
			AND M.LIMIT_COD <> 'KHR'
		LEFT JOIN FPEXR_STG FPE2_LIMIT ON FPE2_LIMIT.FPEXR_CRCY_CODE = '01'
			AND FPE2_LIMIT.FPEXR_DATE =  M.AS_OF_DATE
			AND M.LIMIT_COD <> 'KHR'
		LEFT JOIN ACOLRT_STG ACO_LIMIT ON CRCY_LIMIT.CRCY_CODE = ACO_LIMIT.ACOLRT_CURENCY
			AND ACO_LIMIT.ACOLRT_DATE = M.AS_OF_DATE
			AND ACO_LIMIT.ACOLRT_LOCAL_CURENCY = '01'
			AND M.LIMIT_COD = 'KHR'
		WHERE M.EXT_DATE = @EXT_DATE;
	END TRY
    BEGIN CATCH
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT '發生錯誤: ' + @ErrorMsg;
        THROW;
    END CATCH
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		allen
-- Create date: 20260424
-- Description:	更新指定轉檔日期MonitorData資料
-- =============================================
CREATE PROCEDURE [dbo].[usp_UpdateMonitorDataLimit] @EXT_DATE as date
AS
BEGIN
	SET NOCOUNT ON;
    BEGIN TRY
		update m set LIMIT = TRAN_AMOUNT, TO_USD_LIMIT = TO_USD_AMT
		from MONITORDATA m
		where m.EXT_DATE = @EXT_DATE AND LIMIT_MATURITY <= @EXT_DATE
	END TRY
    BEGIN CATCH
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT '發生錯誤: ' + @ErrorMsg;
        THROW;
    END CATCH
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- 功能：客戶歸戶
-- 描述：用單個客戶歸戶，取找符合的GroupId或是返回新的GroupId
-- 單筆即時比對用的共用歸戶邏輯，供 C# 後端（CustomerService）呼叫，取代
-- GetOrCreateGroupId 內只比對 SwiftCode/LEI 完全相符的邏輯。
CREATE   PROCEDURE [dbo].[usp_ResolveGroupIdForCustomer]
    @PK_Id INT = NULL,                       --新增時為null，修改時才會帶入對應的Primary Key
    @CustomerName NVARCHAR(500) = NULL,      --客戶名稱
    @Unit NVARCHAR(50) = NULL,				 --客戶單位
    @SwiftCode NVARCHAR(20) = NULL,          --歸戶識別碼(SwiftCode)
    @LEI NVARCHAR(20) = NULL,			     --歸戶識別碼(LEI)
    @ISIN NVARCHAR(12) = NULL,               --歸戶識別嗎(ISIN)
    @CustomerMark NVARCHAR(50) = NULL,       --歸戶識別碼(客戶自行標記)
    @CreateIfNotFound BIT = 0				 --新增時是否回傳新的群組id
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ResolvedGroupId INT;
	--取得共用歸戶邏輯
    ;WITH Candidates AS (
        SELECT DISTINCT GroupId
        FROM dbo.ufn_MatchingCustomerGroupIds(@PK_Id, @CustomerName, @Unit, @SwiftCode, @LEI, @ISIN, @CustomerMark)
        WHERE GroupId IS NOT NULL
    )
    SELECT
        @ResolvedGroupId = MIN(GroupId)
    FROM Candidates;

    IF @ResolvedGroupId IS NULL AND @CreateIfNotFound = 1 --如果並未匹配到結果，並且需要回傳新的群組ID
    BEGIN
        EXEC dbo.usp_GetGroupId @GroupName = 'CustomerGroupId', @NewGroupId = @ResolvedGroupId OUTPUT; --呼叫後並且回傳
    END

    SELECT @ResolvedGroupId AS ResolvedGroupId;
END;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_UpdateCustomer]
    @IsScheduled BIT = 1  --這次重跑的觸發來源，寫入Customer_log.IsScheduled；
                           --1=排程/轉檔觸發（預設，沿用既有外部批次/轉檔呼叫端行為），
                           --0=手動觸發（由C#簽核流程結束後呼叫時明確帶入0）
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    ------------------------------------------------------------------------
    -- 0. 取出所有客戶，做為這次要處理的候選發起方
    ------------------------------------------------------------------------
    IF OBJECT_ID('tempdb..#WorkingSet') IS NOT NULL DROP TABLE #WorkingSet;
    SELECT PK_Id, GroupId, CustomerName, Unit, SwiftCode, LEI, ISIN, CustomerMark
    INTO #WorkingSet
    FROM Customer;

    CREATE UNIQUE CLUSTERED INDEX IX_WorkingSet_PK ON #WorkingSet(PK_Id);

    ------------------------------------------------------------------------
    -- 1. 對每一筆客戶比對「誰跟它是同一個客戶」，記成一條邊
    ------------------------------------------------------------------------
    IF OBJECT_ID('tempdb..#Edges') IS NOT NULL DROP TABLE #Edges;
    SELECT DISTINCT Type1, Key1, Type2, Key2
    INTO #Edges
    FROM (
        SELECT
            'P' AS Type1, a.PK_Id AS Key1,
            CASE WHEN m.GroupId IS NOT NULL THEN 'G' ELSE 'P' END AS Type2,
            CASE WHEN m.GroupId IS NOT NULL THEN m.GroupId ELSE m.PK_Id END AS Key2
        FROM #WorkingSet a
        CROSS APPLY dbo.ufn_MatchingCustomerGroupIds(
            a.PK_Id, a.CustomerName, a.Unit, a.SwiftCode, a.LEI, a.ISIN, a.CustomerMark) m
        WHERE (m.GroupId IS NOT NULL OR a.PK_Id < m.PK_Id)

        UNION ALL

        SELECT 'P' AS Type1, a.PK_Id AS Key1, 'G' AS Type2, a.GroupId AS Key2
        FROM #WorkingSet a
        WHERE a.GroupId IS NOT NULL
    ) e;

    ------------------------------------------------------------------------
    -- 1b. 把「客戶PK_Id」和「既有GroupId」統一編成一組連續整數NodeId
    ------------------------------------------------------------------------
    IF OBJECT_ID('tempdb..#NodeMap') IS NOT NULL DROP TABLE #NodeMap;
    SELECT NodeType, NodeKey, ROW_NUMBER() OVER (ORDER BY NodeType, NodeKey) AS NodeId
    INTO #NodeMap
    FROM (
        SELECT Type1 AS NodeType, Key1 AS NodeKey FROM #Edges
        UNION
        SELECT Type2 AS NodeType, Key2 AS NodeKey FROM #Edges
    ) x;

    CREATE UNIQUE CLUSTERED INDEX IX_NodeMap_Type_Key ON #NodeMap(NodeType, NodeKey);
    CREATE UNIQUE INDEX IX_NodeMap_NodeId ON #NodeMap(NodeId);

    ------------------------------------------------------------------------
    -- 1c. 把邊表轉成雙向的 #EdgesBi(NodeId, NeighborId)
    ------------------------------------------------------------------------
    IF OBJECT_ID('tempdb..#EdgesBi') IS NOT NULL DROP TABLE #EdgesBi;
    SELECT n1.NodeId, n2.NodeId AS NeighborId
    INTO #EdgesBi
    FROM #Edges e
    INNER JOIN #NodeMap n1 ON e.Type1 = n1.NodeType AND e.Key1 = n1.NodeKey
    INNER JOIN #NodeMap n2 ON e.Type2 = n2.NodeType AND e.Key2 = n2.NodeKey
    UNION ALL
    SELECT n2.NodeId, n1.NodeId AS NeighborId
    FROM #Edges e
    INNER JOIN #NodeMap n1 ON e.Type1 = n1.NodeType AND e.Key1 = n1.NodeKey
    INNER JOIN #NodeMap n2 ON e.Type2 = n2.NodeType AND e.Key2 = n2.NodeKey;

    CREATE CLUSTERED INDEX IX_EdgesBi_NodeId ON #EdgesBi(NodeId);

    ------------------------------------------------------------------------
    -- 2. 收斂：讓「有邊相連」的節點最終都拿到同一個代表值（CompLabel）
    ------------------------------------------------------------------------
    IF OBJECT_ID('tempdb..#Component') IS NOT NULL DROP TABLE #Component;
    SELECT NodeId, NodeId AS CompLabel
    INTO #Component
    FROM #NodeMap;

    CREATE UNIQUE CLUSTERED INDEX IX_Component_PK ON #Component(NodeId);

    DECLARE @RowsChanged INT = 1, @Iteration INT = 0, @MaxIteration INT = 50;

    WHILE @RowsChanged > 0 AND @Iteration < @MaxIteration
    BEGIN
        UPDATE c
        SET c.CompLabel = m.MinLabel
        FROM #Component c
        INNER JOIN (
            SELECT eb.NodeId, MIN(nb.CompLabel) AS MinLabel
            FROM #EdgesBi eb
            INNER JOIN #Component nb ON nb.NodeId = eb.NeighborId
            GROUP BY eb.NodeId
        ) m ON c.NodeId = m.NodeId
        WHERE c.CompLabel > m.MinLabel;

        SET @RowsChanged = @@ROWCOUNT;
        SET @Iteration += 1;
    END

    IF @Iteration >= @MaxIteration
    BEGIN
        RAISERROR('連通分量收斂超過預期迭代上限(50)，請人工檢查資料是否有異常巨型連結', 16, 1);
        RETURN;
    END

    ------------------------------------------------------------------------
    -- 3. 決定每個分量最終要用哪個GroupId
    ------------------------------------------------------------------------
    IF OBJECT_ID('tempdb..#ComponentGroups') IS NOT NULL DROP TABLE #ComponentGroups;
    SELECT c.CompLabel, nm.NodeKey AS OldGroupId
    INTO #ComponentGroups
    FROM #Component c
    INNER JOIN #NodeMap nm ON c.NodeId = nm.NodeId
    WHERE nm.NodeType = 'G';

    IF OBJECT_ID('tempdb..#ComponentAssign') IS NOT NULL DROP TABLE #ComponentAssign;
    SELECT CompLabel, MIN(OldGroupId) AS FinalGroupId
    INTO #ComponentAssign
    FROM #ComponentGroups
    GROUP BY CompLabel;

    IF OBJECT_ID('tempdb..#GroupMerge') IS NOT NULL DROP TABLE #GroupMerge;
    SELECT DISTINCT cg.OldGroupId, ca.FinalGroupId AS NewGroupId
    INTO #GroupMerge
    FROM #ComponentGroups cg
    INNER JOIN #ComponentAssign ca ON cg.CompLabel = ca.CompLabel
    WHERE cg.OldGroupId <> ca.FinalGroupId;

    CREATE UNIQUE CLUSTERED INDEX IX_GroupMerge_Old ON #GroupMerge(OldGroupId);

    ------------------------------------------------------------------------
    -- 到這裡為止都只在暫存表運算，沒動到Customer本表
    ------------------------------------------------------------------------
    BEGIN TRANSACTION;

    SELECT TOP (0) 1 FROM Customer WITH (TABLOCKX, HOLDLOCK);

    ------------------------------------------------------------------------
    -- 3a. 把「要被合併掉的舊GroupId」底下所有成員，一次性整批轉移
    ------------------------------------------------------------------------
    INSERT INTO Customer_log
        (IsScheduled, PK_Id, GroupId, CustomerName, Unit, CustomerId,
         SwiftCode, LEI, ISIN, CustomerMark, Remark, IsSystem,
         Update_date, Update_user, Create_date, Create_user, SysCreateDate, SysCreateUser)
    SELECT @IsScheduled, cu.PK_Id, cu.GroupId, cu.CustomerName, cu.Unit, cu.CustomerId,
        cu.SwiftCode, cu.LEI, cu.ISIN, cu.CustomerMark, cu.Remark, cu.IsSystem,
        cu.Update_date, cu.Update_user, cu.Create_date, cu.Create_user, GETDATE(), 'system'
    FROM Customer cu
    INNER JOIN #GroupMerge gm ON cu.GroupId = gm.OldGroupId;

    UPDATE cu
    SET cu.GroupId = gm.NewGroupId, cu.IsSystem = 1, cu.System_date = GETDATE()
    FROM Customer cu
    INNER JOIN #GroupMerge gm ON cu.GroupId = gm.OldGroupId;

    ------------------------------------------------------------------------
    -- 3a-ii. 把「原本沒有GroupId」的成員，補上這次算出來的最終GroupId
    ------------------------------------------------------------------------
    INSERT INTO Customer_log
        (IsScheduled, PK_Id, GroupId, CustomerName, Unit, CustomerId,
         SwiftCode, LEI, ISIN, CustomerMark, Remark, IsSystem,
         Update_date, Update_user, Create_date, Create_user, SysCreateDate, SysCreateUser)
    SELECT @IsScheduled, cu.PK_Id, cu.GroupId, cu.CustomerName, cu.Unit, cu.CustomerId,
        cu.SwiftCode, cu.LEI, cu.ISIN, cu.CustomerMark, cu.Remark, cu.IsSystem,
        cu.Update_date, cu.Update_user, cu.Create_date, cu.Create_user, GETDATE(), 'system'
    FROM Customer cu
    INNER JOIN #NodeMap nm ON cu.PK_Id = nm.NodeKey AND nm.NodeType = 'P'
    INNER JOIN #Component c ON nm.NodeId = c.NodeId
    INNER JOIN #ComponentAssign ca ON c.CompLabel = ca.CompLabel
    WHERE cu.GroupId IS NULL;

    UPDATE cu
    SET cu.GroupId = ca.FinalGroupId, cu.IsSystem = 1, cu.System_date = GETDATE()
    FROM Customer cu
    INNER JOIN #NodeMap nm ON cu.PK_Id = nm.NodeKey AND nm.NodeType = 'P'
    INNER JOIN #Component c ON nm.NodeId = c.NodeId
    INNER JOIN #ComponentAssign ca ON c.CompLabel = ca.CompLabel
    WHERE cu.GroupId IS NULL;

    ------------------------------------------------------------------------
    -- 3b. 完全沒有牽涉到既有GroupId的分量，一次性批次申請一段連續GroupId
    ------------------------------------------------------------------------
    IF OBJECT_ID('tempdb..#NewGroups') IS NOT NULL DROP TABLE #NewGroups;
    SELECT c.CompLabel,
        CAST(ROW_NUMBER() OVER (ORDER BY c.CompLabel) AS INT) AS Seq
    INTO #NewGroups
    FROM (SELECT DISTINCT CompLabel FROM #Component) c
    LEFT JOIN #ComponentAssign ca ON c.CompLabel = ca.CompLabel
    WHERE ca.CompLabel IS NULL;

    CREATE UNIQUE CLUSTERED INDEX IX_NewGroups_CompLabel ON #NewGroups(CompLabel);

    DECLARE @NewCount INT = (SELECT COUNT(*) FROM #NewGroups);

    IF @NewCount > 0
    BEGIN
        DECLARE @StartGroupId INT;

        SELECT @StartGroupId = GroupCount
        FROM GroupIdCounter WITH (UPDLOCK, ROWLOCK, HOLDLOCK)
        WHERE GroupName = 'CustomerGroupId';

        IF @StartGroupId IS NULL
        BEGIN
            ROLLBACK TRANSACTION;
            THROW 51000, 'GroupIdCounter 查無此 GroupName(CustomerGroupId)', 1;
            RETURN;
        END

        UPDATE GroupIdCounter
        SET GroupCount = GroupCount + @NewCount
        WHERE GroupName = 'CustomerGroupId';

        INSERT INTO Customer_log
            (IsScheduled, PK_Id, GroupId, CustomerName, Unit, CustomerId,
             SwiftCode, LEI, ISIN, CustomerMark, Remark, IsSystem,
             Update_date, Update_user, Create_date, Create_user, SysCreateDate, SysCreateUser)
        SELECT @IsScheduled, cu.PK_Id, cu.GroupId, cu.CustomerName, cu.Unit, cu.CustomerId,
            cu.SwiftCode, cu.LEI, cu.ISIN, cu.CustomerMark, cu.Remark, cu.IsSystem,
            cu.Update_date, cu.Update_user, cu.Create_date, cu.Create_user, GETDATE(), 'system'
        FROM Customer cu
        INNER JOIN #NodeMap nm ON cu.PK_Id = nm.NodeKey AND nm.NodeType = 'P'
        INNER JOIN #Component c ON nm.NodeId = c.NodeId
        INNER JOIN #NewGroups ng ON c.CompLabel = ng.CompLabel
        WHERE cu.GroupId IS NULL;

        UPDATE cu
        SET cu.GroupId = @StartGroupId + ng.Seq - 1, cu.IsSystem = 1, cu.System_date = GETDATE()
        FROM Customer cu
        INNER JOIN #NodeMap nm ON cu.PK_Id = nm.NodeKey AND nm.NodeType = 'P'
        INNER JOIN #Component c ON nm.NodeId = c.NodeId
        INNER JOIN #NewGroups ng ON c.CompLabel = ng.CompLabel
        WHERE cu.GroupId IS NULL;
    END

    COMMIT TRANSACTION;
END;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Allen
-- Create date: 20250923
-- Description:	將MonitorData指定轉入日期 and 產品類別為 07 衍伸性金融商品
--				根據到期日與轉檔日得出剩餘天數 與 風險類型 取得風險係數，Update 交易額度與核准額度
-- =============================================
CREATE PROCEDURE [dbo].[usp_UpdateMonitorDataPruduct07RiskFactor](@EXT_DATE AS DATE)
AS
BEGIN
	SET NOCOUNT ON;
    BEGIN TRY
		UPDATE MONITORDATA
		SET RISKFACTOR = dbo.ufn_FinancialRiskFactor(DATEDIFF(DAY, @EXT_DATE, MATURITY_DATE),
			PRODUCT_CODE,CUR_BOUGHT,CUR_SOLD)
		WHERE EXT_DATE = @EXT_DATE AND PRODUCT_TYPE = '07';
	END TRY
    BEGIN CATCH
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT '發生錯誤: ' + @ErrorMsg;
        THROW;
    END CATCH
END
--SELECT
--	pm.FK_GlobalID_FinancialProductCategory,
--    G.Name_TN,
--    PM.ProductTypeName,
--    PM.ProductCode,
--	RFD.FK_ProductID,
--	RFD.FK_PeriodID,
--    PD.PeriodName,
--    PD.MinDays,
--    PD.MaxDays,
--    RFD.RiskFactor
--FROM FinancialRiskFactorData RFD
--INNER JOIN FinancialProductMaster PM ON RFD.FK_ProductID = PM.PK_ID
--INNER JOIN Global G ON PM.FK_GlobalID_FinancialProductCategory = G.Id
--INNER JOIN FinancialRiskFactorPeriodDay PD ON RFD.FK_PeriodID = PD.PK_ID
----ORDER BY PM.PK_ID

--SELECT
--    G.Name_TN AS ProductCategory,
--    PM.ProductTypeName,
--    PM.ProductCode,
--    [1] AS 'Days_2',
--    [2] AS 'Days_7',
--    [3] AS 'Days_30',
--    [4] AS 'Days_31_60',
--    [5] AS 'Days_61_91',
--    [6] AS 'Days_92_182',
--    [7] AS 'Days_183_270',
--    [8] AS 'Days_271_365',
--    [9] AS 'Days_366_456',
--    [10] AS 'Days_457_547',
--    [11] AS 'Days_548_635',
--    [12] AS 'Days_636_730',
--    [13] AS 'Days_731_1095',
--    [14] AS 'Days_1096_1825',
--    [15] AS 'Days_1826_2555',
--    [16] AS 'Days_2556_3650',
--    [17] AS 'Days_3651_5475',
--    [18] AS 'Days_5476_7300',
--    [19] AS 'Days_7301_9131',
--    [20] AS 'Days_9132_10958'
--FROM (
--    SELECT
--        G.Name_TN,
--        PM.ProductTypeName,
--        PM.ProductCode,
--        PM.PK_ID,
--        RFD.FK_PeriodID,
--        RFD.RiskFactor
--    FROM FinancialRiskFactorData RFD
--    INNER JOIN FinancialProductMaster PM ON RFD.FK_ProductID = PM.PK_ID
--    INNER JOIN Global G ON PM.FK_GlobalID_FinancialProductCategory = G.Id
--) AS SourceTable
--PIVOT (
--    MAX(RiskFactor)
--    FOR FK_PeriodID IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20])
--) AS PivotTable
--INNER JOIN FinancialProductMaster PM ON PivotTable.PK_ID = PM.PK_ID
--INNER JOIN Global G ON PM.FK_GlobalID_FinancialProductCategory = G.Id
--ORDER BY PM.PK_ID;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		allen
-- Create date: 20260424
-- Description:	更新指定轉檔日期MonitorData資料
-- =============================================
CREATE PROCEDURE [dbo].[usp_UpdateMonitorDataUnit] @EXT_DATE as date
AS
BEGIN
	SET NOCOUNT ON;
    BEGIN TRY
		update m set GROUP_NO =ISNULL(a.GroupCode,m.GROUP_NO) ,
				　	 UNIT_NO = ISNULL(b.UnitCode,m.UNIT_NO) ,
					BRANCH_NO = ISNULL(c.BankCode,m.BRANCH_NO),
					[YEAR] = YEAR(@EXT_DATE),
					[Month] = MONTH(@EXT_DATE),
					[Week] = dbo.ufn_GetWeekOfMonth(@EXT_DATE),
					EXT_DATE = @EXT_DATE
		from MONITORDATA m
		left join BankGroup a on left(dbo.ufn_CodePrefix(a.GroupCode),3) = m.GROUP_NO
		left join BankUnit b  on left(dbo.ufn_CodePrefix(b.UnitCode),3) = m.UNIT_NO
		left join BankBranch c on left(dbo.ufn_CodePrefix(c.BankCode),3) = m.BRANCH_NO AND
								 left(dbo.ufn_CodePrefix(b.UnitCode),3) = m.UNIT_NO AND
								b.PK_Id = c.FK_BankUnit
		where m.EXT_DATE = @EXT_DATE
	END TRY
    BEGIN CATCH
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT '發生錯誤: ' + @ErrorMsg;
        THROW;
    END CATCH
END
GO
COMMIT TRANSACTION;
GO
PRINT N'PHASE 2 COMPLETED: Programmable-object deployment completed.';
GO
-- Restore the session setting when preflight used NOEXEC to halt deployment.
SET NOEXEC OFF;
GO
