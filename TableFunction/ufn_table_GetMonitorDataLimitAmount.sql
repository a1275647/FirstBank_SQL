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
			-- 排除已標記資料，跟 QueryMonitorDataBase（C# 端）的 Mark 過濾邏輯一致；
			-- NULL 視同未標記予以保留，只有明確 1（已標記）才排除。
			AND ISNULL(Mark,0) <> 1
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
