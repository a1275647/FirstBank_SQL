SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		AllenChen
-- Create date: 2026/09/07
-- Description:	Update MonitorData 行業別更新

-- =============================================
Create PROCEDURE [dbo].[usp_UpdateMonitorDataIndustry] @EXT_DATE AS DATE
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

		--Declare @EXT_DATE Date = '2026-09-01';
		
		update a set INDUSTRY = right(ISNULL(b.INDCODE,c.INDCODE),6) ,
		INDUSTRY_Type = case when b.INDCODE is not null then 2
						     when c.INDCODE is not null then 1
							 else null
						end
		from MONITORDATA_STAGE a
		left join INDUSTRY_Overseas b on b.BranchCode = left(dbo.ufn_CodePrefix(a.BRANCH_NO),3) and b.CustomerId = a.CUSTOMER_ID
		left join INDUSTRY_Internal c on c.CustomerId = a.CUSTOMER_ID
		where EXT_DATE = @EXT_DATE
	END TRY
	BEGIN CATCH
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT '發生錯誤: ' + @ErrorMsg;
		THROW;
	END CATCH

END
GO


