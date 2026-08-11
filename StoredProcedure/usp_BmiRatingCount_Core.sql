USE [NCRMS]
GO
/****** Object:  StoredProcedure [dbo].[usp_BmiRatingCount_Core] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER PROCEDURE [dbo].[usp_BmiRatingCount_Core]
    @Date DATE,
    @CountryRatings [dbo].[CountryRatingResultType] READONLY
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        DECLARE @Year AS INT, @Month AS INT, @Week AS INT;
        SELECT @Year = YEAR(@Date), @Month = MONTH(@Date), @Week = dbo.ufn_GetWeekOfMonth(@Date)

        DELETE CreditRating_CountBmi_his
        WHERE [YEAR] = @Year AND [Month] = @Month AND [Week] = @Week

        DELETE CreditRating_CountBmi
        OUTPUT 
            @Year, @Month, @Week,
            deleted.FK_Country_Id, deleted.CountryName, deleted.CountryRating, deleted.TitleCountryRating,
            deleted.NominalGDP_Score, deleted.NominalGDP, deleted.RealGDPGrowthIMFAE_Score, deleted.RealGDPGrowthIMFAE,
            deleted.RealGDPGrowth_Score, deleted.RealGDPGrowth, deleted.ConsumerPriceIMFAE_Score, deleted.ConsumerPriceIMFAE,
            deleted.ConsumerPrice_Score, deleted.ConsumerPrice, deleted.Unemployment_Score, deleted.Unemployment,
            deleted.ImportCoverMonths_Score, deleted.ImportCoverMonths, deleted.TotalExternalDebtStock_Score, deleted.TotalExternalDebtStock,
            deleted.ShortTermExternalDebt_Score, deleted.ShortTermExternalDebt, deleted.BudgetBalance_Score, deleted.BudgetBalance,
            deleted.TotalGovernmentDebt_Score, deleted.TotalGovernmentDebt, deleted.PoliticalRisk_Score, deleted.PoliticalRisk,
            deleted.SecurityRisk_Score, deleted.SecurityRisk, deleted.BusinessStrategy_Explain, deleted.BusinessStrategy,
            deleted.CreditRating_Explain, deleted.CreditRating, deleted.Outlook_Explain, deleted.Outlook,
            deleted.Other_Explain, deleted.Other, deleted.End_Explain, deleted.AssessmentDay
        INTO CreditRating_CountBmi_his(
            [Year], [Month], [Week],
            [FK_Country_Id], [CountryName], [CountryRating], [TitleCountryRating],
            [NominalGDP_Score], [NominalGDP], [RealGDPGrowthIMFAE_Score], [RealGDPGrowthIMFAE],
            [RealGDPGrowth_Score], [RealGDPGrowth], [ConsumerPriceIMFAE_Score], [ConsumerPriceIMFAE],
            [ConsumerPrice_Score], [ConsumerPrice], [Unemployment_Score], [Unemployment],
            [ImportCoverMonths_Score], [ImportCoverMonths], [TotalExternalDebtStock_Score], [TotalExternalDebtStock],
            [ShortTermExternalDebt_Score], [ShortTermExternalDebt], [BudgetBalance_Score], [BudgetBalance],
            [TotalGovernmentDebt_Score], [TotalGovernmentDebt], [PoliticalRisk_Score], [PoliticalRisk],
            [SecurityRisk_Score], [SecurityRisk], [BusinessStrategy_Explain], [BusinessStrategy],
            [CreditRating_Explain], [CreditRating], [Outlook_Explain], [Outlook],
            [Other_Explain], [Other], [End_Explain], [AssessmentDay]
        );

		-- 把國家風險等級拉出去
        WITH RatingText AS (
			SELECT 
				rt.FK_Country_Id,
				rt.FinalRating,
				rt.Score,
				'第' +
					CASE rt.FinalRating
						WHEN 1 THEN '一'
						WHEN 2 THEN '二'
						WHEN 3 THEN '三'
						WHEN 4 THEN '四'
						WHEN 5 THEN '五'
					END + '等' AS RatingText,
				'國家風險等級：第' +
					CASE rt.FinalRating
						WHEN 1 THEN '一'
						WHEN 2 THEN '二'
						WHEN 3 THEN '三'
						WHEN 4 THEN '四'
						WHEN 5 THEN '五'
					END + '等' AS TitleRatingText,
				CASE rt.FinalRating
					WHEN 1 THEN 9
					WHEN 2 THEN 7
					WHEN 3 THEN 5
					WHEN 4 THEN 3
					WHEN 5 THEN 1
				END AS RatingScore,
				CASE rt.Score
					WHEN 1 THEN '正面'
					WHEN 0 THEN '持平'
					WHEN -1 THEN '負面'
					ELSE NULL
				END AS OutlookText
			FROM @CountryRatings rt
		),
        -- Default 分數從規則表讀取，ScoreLevel = 'Default' 的那筆
        DefaultScores AS (
            SELECT RuleName, Score
            FROM CreditRating_BmiRule
            WHERE ScoreLevel = 'Default' AND IsActive = 1
        ),
        BMIData AS (
            SELECT 
                ci.PK_Id AS FK_Country_Id,
                ci.CountryName_TN,
                ci.ISIMFAE,
                
                -- 原始值
                ROUND(a.BMI_GDP_NOM_USD_AVE / 1000000000, 1) AS NominalGDP,
                ROUND(a.BMI_GDP_REAL_PCTCH, 1) AS RealGDPGrowth_Raw,
                ROUND(a.BMI_INFLATION_CPI_AVE_UNIT, 1) AS ConsumerPrice_Raw,
                a.BMI_LABOUR_UNEMP_PCT_AVE_UNIT AS Unemployment,
                a.BMI_RESERVES_IMPCOVER AS ImportCoverMonths,
                ROUND(a.BMI_DEBT_EXT_PCGDP, 1) AS TotalExternalDebtStock,
                ROUND(a.BMI_DEBT_EXT_ST_PCTEXTDEBT, 1) AS ShortTermExternalDebt,
                ROUND(a.BMI_FISCAL_BALANCE_PCTGDP, 1) AS BudgetBalance,
                ROUND(a.BMI_DEBT_GOVT_PCGDP, 1) AS TotalGovernmentDebt,
                ROUND(a.BMI_INDEX_POLRISK_UNIT_50046_E, 1) AS PoliticalRisk,
                ROUND(a.BMI_INDEX_POLRISK_SECURITY_UNIT_10012_E, 1) AS SecurityRisk,
                
                -- 動態評分，找不到規則時用 DefaultScores 的值
                ISNULL(gdp_rule.Score, gdp_default.Score)                           AS NominalGDP_Score,
                
                CASE WHEN ci.ISIMFAE = 1 THEN ISNULL(CAST(gdp_growth_dev.Score AS FLOAT),    CAST(gdp_growth_dev_default.Score    AS FLOAT)) ELSE NULL END AS RealGDPGrowthIMFAE_Score,
                CASE WHEN ci.ISIMFAE = 1 THEN ROUND(a.BMI_GDP_REAL_PCTCH, 1) ELSE NULL END AS RealGDPGrowthIMFAE,
                CASE WHEN ci.ISIMFAE = 0 THEN ISNULL(CAST(gdp_growth_emerging.Score AS FLOAT), CAST(gdp_growth_emg_default.Score AS FLOAT)) ELSE NULL END AS RealGDPGrowth_Score,
                CASE WHEN ci.ISIMFAE = 0 THEN ROUND(a.BMI_GDP_REAL_PCTCH, 1) ELSE NULL END AS RealGDPGrowth,
                
                CASE WHEN ci.ISIMFAE = 1 THEN ISNULL(CAST(cpi_dev.Score AS FLOAT),           CAST(cpi_dev_default.Score           AS FLOAT)) ELSE NULL END AS ConsumerPriceIMFAE_Score,
                CASE WHEN ci.ISIMFAE = 1 THEN ROUND(a.BMI_INFLATION_CPI_AVE_UNIT, 1) ELSE NULL END AS ConsumerPriceIMFAE,
                CASE WHEN ci.ISIMFAE = 0 THEN ISNULL(CAST(cpi_emerging.Score AS FLOAT),       CAST(cpi_emg_default.Score           AS FLOAT)) ELSE NULL END AS ConsumerPrice_Score,
                CASE WHEN ci.ISIMFAE = 0 THEN ROUND(a.BMI_INFLATION_CPI_AVE_UNIT, 1) ELSE NULL END AS ConsumerPrice,
                
                ISNULL(CAST(unemp_rule.Score    AS FLOAT), CAST(unemp_default.Score    AS FLOAT)) AS Unemployment_Score,
                ISNULL(CAST(import_rule.Score   AS FLOAT), CAST(import_default.Score   AS FLOAT)) AS ImportCoverMonths_Score,
                ISNULL(CAST(ext_debt_rule.Score AS FLOAT), CAST(ext_debt_default.Score AS FLOAT)) AS TotalExternalDebtStock_Score,
                ISNULL(CAST(st_debt_rule.Score  AS FLOAT), CAST(st_debt_default.Score  AS FLOAT)) AS ShortTermExternalDebt_Score,
                ISNULL(CAST(budget_rule.Score   AS FLOAT), CAST(budget_default.Score   AS FLOAT)) AS BudgetBalance_Score,
                ISNULL(CAST(govt_debt_rule.Score AS FLOAT), CAST(govt_debt_default.Score AS FLOAT)) AS TotalGovernmentDebt_Score,
                ISNULL(pol_risk_rule.Score, pol_risk_default.Score)                 AS PoliticalRisk_Score,
                ISNULL(sec_risk_rule.Score, sec_risk_default.Score)                 AS SecurityRisk_Score,
                
                ROW_NUMBER() OVER (PARTITION BY ci.PK_Id ORDER BY ISNULL(a.PK_Id, 0) DESC) AS rn
                
            FROM CountryMaster ci
            LEFT JOIN CreditRating_Bmi a
                ON a.FK_Country_Id = ci.PK_Id
                AND a.Year = YEAR(@Date)
            
            -- NominalGDP
            LEFT JOIN CreditRating_BmiRule gdp_rule 
                ON gdp_rule.RuleName = 'NominalGDP' 
                AND gdp_rule.IsActive = 1
                AND gdp_rule.ScoreLevel <> 'Default'
                AND ROUND(a.BMI_GDP_NOM_USD_AVE / 1000000000, 1) >= ISNULL(gdp_rule.MinValue, -999999999)
                AND ROUND(a.BMI_GDP_NOM_USD_AVE / 1000000000, 1) <= ISNULL(gdp_rule.MaxValue, 999999999)
            LEFT JOIN DefaultScores gdp_default ON gdp_default.RuleName = 'NominalGDP'
            
            -- RealGDPGrowth (已開發)
            LEFT JOIN CreditRating_BmiRule gdp_growth_dev 
                ON gdp_growth_dev.RuleName = 'RealGDPGrowthDeveloped' 
                AND gdp_growth_dev.IsActive = 1
                AND gdp_growth_dev.ScoreLevel <> 'Default'
                AND ci.ISIMFAE = 1
                AND ROUND(a.BMI_GDP_REAL_PCTCH, 1) >= ISNULL(gdp_growth_dev.MinValue, -999999999)
                AND ROUND(a.BMI_GDP_REAL_PCTCH, 1) <= ISNULL(gdp_growth_dev.MaxValue, 999999999)
            LEFT JOIN DefaultScores gdp_growth_dev_default ON gdp_growth_dev_default.RuleName = 'RealGDPGrowthDeveloped'
            
            -- RealGDPGrowth (開發中)
            LEFT JOIN CreditRating_BmiRule gdp_growth_emerging 
                ON gdp_growth_emerging.RuleName = 'RealGDPGrowthDeveloping' 
                AND gdp_growth_emerging.IsActive = 1
                AND gdp_growth_emerging.ScoreLevel <> 'Default'
                AND ci.ISIMFAE = 0
                AND ROUND(a.BMI_GDP_REAL_PCTCH, 1) >= ISNULL(gdp_growth_emerging.MinValue, -999999999)
                AND ROUND(a.BMI_GDP_REAL_PCTCH, 1) <= ISNULL(gdp_growth_emerging.MaxValue, 999999999)
            LEFT JOIN DefaultScores gdp_growth_emg_default ON gdp_growth_emg_default.RuleName = 'RealGDPGrowthDeveloping'
            
            -- ConsumerPrice (已開發)
            LEFT JOIN CreditRating_BmiRule cpi_dev 
                ON cpi_dev.RuleName = 'ConsumerPriceDeveloped' 
                AND cpi_dev.IsActive = 1
                AND cpi_dev.ScoreLevel <> 'Default'
                AND ci.ISIMFAE = 1
                AND (
                    (cpi_dev.ScoreLevel = 'Deflation' AND ROUND(a.BMI_INFLATION_CPI_AVE_UNIT, 1) <= 0)
                    OR (cpi_dev.ScoreLevel <> 'Deflation' 
                        AND ROUND(a.BMI_INFLATION_CPI_AVE_UNIT, 1) > 0
                        AND ROUND(a.BMI_INFLATION_CPI_AVE_UNIT, 1) >= ISNULL(cpi_dev.MinValue, -999999999)
                        AND ROUND(a.BMI_INFLATION_CPI_AVE_UNIT, 1) <= ISNULL(cpi_dev.MaxValue, 999999999))
                )
            LEFT JOIN DefaultScores cpi_dev_default ON cpi_dev_default.RuleName = 'ConsumerPriceDeveloped'
            
            -- ConsumerPrice (開發中)
            LEFT JOIN CreditRating_BmiRule cpi_emerging 
                ON cpi_emerging.RuleName = 'ConsumerPriceDeveloping' 
                AND cpi_emerging.IsActive = 1
                AND cpi_emerging.ScoreLevel <> 'Default'
                AND ci.ISIMFAE = 0
                AND (
                    (cpi_emerging.ScoreLevel = 'Deflation' AND ROUND(a.BMI_INFLATION_CPI_AVE_UNIT, 1) <= 0)
                    OR (cpi_emerging.ScoreLevel <> 'Deflation' 
                        AND ROUND(a.BMI_INFLATION_CPI_AVE_UNIT, 1) > 0
                        AND ROUND(a.BMI_INFLATION_CPI_AVE_UNIT, 1) >= ISNULL(cpi_emerging.MinValue, -999999999)
                        AND ROUND(a.BMI_INFLATION_CPI_AVE_UNIT, 1) <= ISNULL(cpi_emerging.MaxValue, 999999999))
                )
            LEFT JOIN DefaultScores cpi_emg_default ON cpi_emg_default.RuleName = 'ConsumerPriceDeveloping'
            
            -- Unemployment
            LEFT JOIN CreditRating_BmiRule unemp_rule 
                ON unemp_rule.RuleName = 'Unemployment' 
                AND unemp_rule.IsActive = 1
                AND unemp_rule.ScoreLevel <> 'Default'
                AND a.BMI_LABOUR_UNEMP_PCT_AVE_UNIT >= ISNULL(unemp_rule.MinValue, -999999999)
                AND a.BMI_LABOUR_UNEMP_PCT_AVE_UNIT <= ISNULL(unemp_rule.MaxValue, 999999999)
            LEFT JOIN DefaultScores unemp_default ON unemp_default.RuleName = 'Unemployment'
            
            -- ImportCoverMonths
            LEFT JOIN CreditRating_BmiRule import_rule 
                ON import_rule.RuleName = 'ImportCoverMonths' 
                AND import_rule.IsActive = 1
                AND import_rule.ScoreLevel <> 'Default'
                AND a.BMI_RESERVES_IMPCOVER >= ISNULL(import_rule.MinValue, -999999999)
                AND a.BMI_RESERVES_IMPCOVER <= ISNULL(import_rule.MaxValue, 999999999)
            LEFT JOIN DefaultScores import_default ON import_default.RuleName = 'ImportCoverMonths'
            
            -- TotalExternalDebtStock
            LEFT JOIN CreditRating_BmiRule ext_debt_rule 
                ON ext_debt_rule.RuleName = 'TotalExternalDebtStock' 
                AND ext_debt_rule.IsActive = 1
                AND ext_debt_rule.ScoreLevel <> 'Default'
                AND ROUND(a.BMI_DEBT_EXT_PCGDP, 1) >= ISNULL(ext_debt_rule.MinValue, -999999999)
                AND ROUND(a.BMI_DEBT_EXT_PCGDP, 1) <= ISNULL(ext_debt_rule.MaxValue, 999999999)
            LEFT JOIN DefaultScores ext_debt_default ON ext_debt_default.RuleName = 'TotalExternalDebtStock'
            
            -- ShortTermExternalDebt
            LEFT JOIN CreditRating_BmiRule st_debt_rule 
                ON st_debt_rule.RuleName = 'ShortTermExternalDebt' 
                AND st_debt_rule.IsActive = 1
                AND st_debt_rule.ScoreLevel <> 'Default'
                AND ROUND(a.BMI_DEBT_EXT_ST_PCTEXTDEBT, 1) >= ISNULL(st_debt_rule.MinValue, -999999999)
                AND ROUND(a.BMI_DEBT_EXT_ST_PCTEXTDEBT, 1) <= ISNULL(st_debt_rule.MaxValue, 999999999)
            LEFT JOIN DefaultScores st_debt_default ON st_debt_default.RuleName = 'ShortTermExternalDebt'
            
            -- BudgetBalance
            LEFT JOIN CreditRating_BmiRule budget_rule 
                ON budget_rule.RuleName = 'BudgetBalance' 
                AND budget_rule.IsActive = 1
                AND budget_rule.ScoreLevel <> 'Default'
                AND ROUND(a.BMI_FISCAL_BALANCE_PCTGDP, 1) >= ISNULL(budget_rule.MinValue, -999999999)
                AND ROUND(a.BMI_FISCAL_BALANCE_PCTGDP, 1) <= ISNULL(budget_rule.MaxValue, 999999999)
            LEFT JOIN DefaultScores budget_default ON budget_default.RuleName = 'BudgetBalance'
            
            -- TotalGovernmentDebt
            LEFT JOIN CreditRating_BmiRule govt_debt_rule 
                ON govt_debt_rule.RuleName = 'TotalGovernmentDebt' 
                AND govt_debt_rule.IsActive = 1
                AND govt_debt_rule.ScoreLevel <> 'Default'
                AND ROUND(a.BMI_DEBT_GOVT_PCGDP, 1) >= ISNULL(govt_debt_rule.MinValue, -999999999)
                AND ROUND(a.BMI_DEBT_GOVT_PCGDP, 1) <= ISNULL(govt_debt_rule.MaxValue, 999999999)
            LEFT JOIN DefaultScores govt_debt_default ON govt_debt_default.RuleName = 'TotalGovernmentDebt'
            
            -- PoliticalRisk
            LEFT JOIN CreditRating_BmiRule pol_risk_rule 
                ON pol_risk_rule.RuleName = 'PoliticalRisk' 
                AND pol_risk_rule.IsActive = 1
                AND pol_risk_rule.ScoreLevel <> 'Default'
                AND ROUND(a.BMI_INDEX_POLRISK_UNIT_50046_E, 1) >= ISNULL(pol_risk_rule.MinValue, -999999999)
                AND ROUND(a.BMI_INDEX_POLRISK_UNIT_50046_E, 1) <= ISNULL(pol_risk_rule.MaxValue, 999999999)
            LEFT JOIN DefaultScores pol_risk_default ON pol_risk_default.RuleName = 'PoliticalRisk'
            
            -- SecurityRisk
            LEFT JOIN CreditRating_BmiRule sec_risk_rule 
                ON sec_risk_rule.RuleName = 'SecurityRisk' 
                AND sec_risk_rule.IsActive = 1
                AND sec_risk_rule.ScoreLevel <> 'Default'
                AND ROUND(a.BMI_INDEX_POLRISK_SECURITY_UNIT_10012_E, 1) >= ISNULL(sec_risk_rule.MinValue, -999999999)
                AND ROUND(a.BMI_INDEX_POLRISK_SECURITY_UNIT_10012_E, 1) <= ISNULL(sec_risk_rule.MaxValue, 999999999)
            LEFT JOIN DefaultScores sec_risk_default ON sec_risk_default.RuleName = 'SecurityRisk'
        )
        INSERT INTO CreditRating_CountBmi (
            FK_Country_Id, CountryName, CountryRating, TitleCountryRating,
            NominalGDP_Score, NominalGDP,
            RealGDPGrowthIMFAE_Score, RealGDPGrowthIMFAE,
            RealGDPGrowth_Score, RealGDPGrowth,
            ConsumerPriceIMFAE_Score, ConsumerPriceIMFAE,
            ConsumerPrice_Score, ConsumerPrice,
            Unemployment_Score, Unemployment,
            ImportCoverMonths_Score, ImportCoverMonths,
            TotalExternalDebtStock_Score, TotalExternalDebtStock,
            ShortTermExternalDebt_Score, ShortTermExternalDebt,
            BudgetBalance_Score, BudgetBalance,
            TotalGovernmentDebt_Score, TotalGovernmentDebt,
            PoliticalRisk_Score, PoliticalRisk,
            SecurityRisk_Score, SecurityRisk,
            BusinessStrategy_Explain, BusinessStrategy,
            CreditRating_Explain, CreditRating,
            Outlook_Explain, Outlook,
            Other_Explain, Other,
            End_Explain, AssessmentDay
        )
        SELECT 
            cm.PK_Id AS FK_Country_Id,
            CONCAT('國家：', ISNULL(bd.CountryName_TN, cm.CountryName_TN)) AS CountryName,
            ISNULL(rt.FinalRating, 5) AS CountryRating,
            ISNULL(rt.TitleRatingText, '國家風險等級：第五等') AS TitleCountryRating,
            bd.NominalGDP_Score,
            bd.NominalGDP,
            bd.RealGDPGrowthIMFAE_Score,
            bd.RealGDPGrowthIMFAE,
            bd.RealGDPGrowth_Score,
            bd.RealGDPGrowth,
            bd.ConsumerPriceIMFAE_Score,
            bd.ConsumerPriceIMFAE,
            bd.ConsumerPrice_Score,
            bd.ConsumerPrice,
            bd.Unemployment_Score,
            bd.Unemployment,
            bd.ImportCoverMonths_Score,
            bd.ImportCoverMonths,
            bd.TotalExternalDebtStock_Score,
            bd.TotalExternalDebtStock,
            bd.ShortTermExternalDebt_Score,
            bd.ShortTermExternalDebt,
            bd.BudgetBalance_Score,
            bd.BudgetBalance,
            bd.TotalGovernmentDebt_Score,
            bd.TotalGovernmentDebt,
            bd.PoliticalRisk_Score,
            bd.PoliticalRisk,
            bd.SecurityRisk_Score,
            bd.SecurityRisk,
            NULL AS BusinessStrategy_Explain,
            NULL AS BusinessStrategy,
            ISNULL(rt.RatingText, '第五等') AS CreditRating_Explain,
            ISNULL(rt.RatingScore, 1) AS CreditRating,
            ISNULL(rt.OutlookText, '持平') AS Outlook_Explain,
            ISNULL(rt.Score, 0) AS Outlook,
            NULL AS Other_Explain,
            NULL AS Other,
            CONCAT(ISNULL(bd.CountryName_TN, cm.CountryName_TN), '國家風險額度獲配___百萬美元，本次擬申請增加___百萬美元。') AS End_Explain,
            '評定日：' + FORMAT(@Date, 'yyyyMMdd') AS AssessmentDay
        FROM CountryMaster cm
        LEFT JOIN RatingText rt ON cm.PK_Id = rt.FK_Country_Id
        LEFT JOIN BMIData bd ON cm.PK_Id = bd.FK_Country_Id AND bd.rn = 1;


    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorLine INT = ERROR_LINE();
        PRINT '處理失敗於第 ' + CAST(@ErrorLine AS VARCHAR) + ' 行: ' + @ErrorMessage;
        THROW;
    END CATCH
END
