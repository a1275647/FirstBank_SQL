SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		allen
-- Create date: 20260424
-- Description:	更新指定轉檔日期MonitorData資料
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[usp_UpdateMonitorDataUnit] @EXT_DATE as date
AS
BEGIN
	SET NOCOUNT ON;
    BEGIN TRY
		
		--Declare @EXT_DATE Date = '2026-09-01';
		update m set GROUP_NO =ISNULL(a.GroupCode,m.GROUP_NO) ,
				　	 UNIT_NO = ISNULL(b.UnitCode,m.UNIT_NO) ,
					BRANCH_NO = ISNULL(c.BankCode,m.BRANCH_NO),
					[YEAR] = YEAR(@EXT_DATE),
					[Month] = MONTH(@EXT_DATE),
					[Week] = dbo.ufn_GetWeekOfMonth(@EXT_DATE)
		from MONITORDATA_STAGE m
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
