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
	-- 改成用「分行、國家別、資料日、上層核准編號(TOP_Permit_No)」分組，不再用個別額度自己的
	-- 核准編號分組——同一條根額度底下可能拆成好幾個核准編號(PERMIT_NO)，用 PERMIT_NO 分組
	-- 只會各自跟根額度上限比較，加總超過根額度的情況反而抓不到；要用根額度自己的識別碼
	-- (TOP_Permit_No) 分組，才能把同一條根額度下所有子額度的美金核准額度全部加在一起再封頂。
	-- TOP_Permit_No 為空時比照既有 PERMIT_NO 的防呆作法，退回用 PK_Id 當識別碼，避免同一批
	-- 尚未帶入根額度資料的資料被誤判成同一組而合併加總。
	temp3 as (
		select *,
			ROW_NUMBER() OVER(
				PARTITION BY BRANCH_NO,COUNTRY_COD,EXT_DATE,ISNULL(NULLIF(LTRIM(RTRIM(TOP_Permit_No)), ''), CAST(PK_Id AS NVARCHAR(20))) ORDER BY PK_Id
				) AS rn_final,
			SUM(SUM_TO_USD_LIMIT) OVER (
				PARTITION BY BRANCH_NO,COUNTRY_COD,EXT_DATE,ISNULL(NULLIF(LTRIM(RTRIM(TOP_Permit_No)), ''), CAST(PK_Id AS NVARCHAR(20)))
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
			WEIGHTS,Create_DateTime,YEAR,MONTH,Week,EXT_DATE,
			TOP_Limit_Amount,TOP_Limit_USD_Amount,TOP_Permit_No,TOP_Limit_Cod,TOP_Country_Cod,TOP_Limit_Maturity
	FROM temp3
)
GO
