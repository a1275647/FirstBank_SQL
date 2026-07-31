-- ══════════════════════════════════════════════════════════════════════════
-- CreditRatingsService.GetCountryBmi / GetAllCountryBmiInfo 效能優化索引
-- 對應 FirstBankContext.cs 裡同名的 HasIndex(...) fluent config，Model 與 DB 結構保持一致。
-- ══════════════════════════════════════════════════════════════════════════

-- CreditRating_AllBmi：分頁/串流查詢都先用 FK_Country_Id 篩選（WHERE EXISTS / IN），
-- 再依 Year、FK_CategoriesId 排序；Include Score 避免回表查找。
CREATE NONCLUSTERED INDEX IX_CreditRating_AllBmi_Country_Year_Category
ON [dbo].[CreditRating_AllBmi] ([FK_Country_Id], [Year], [FK_CategoriesId])
INCLUDE ([Score]);

-- CreditRating_CountryId：FitchId 查詢固定先用 FK_AgencyCode_Id = 2 過濾、再比對 FK_Country_Id
-- （相關子查詢／LEFT JOIN 兩種寫法都吃得到）。
CREATE NONCLUSTERED INDEX IX_CreditRating_CountryId_Agency_Country
ON [dbo].[CreditRating_CountryId] ([FK_AgencyCode_Id], [FK_Country_Id])
INCLUDE ([EntityId]);

-- CreditRating_Country_M：RiskLevel 查詢固定用 FK_CountryId 取 Create_date 最新一筆
-- （GetAllCountryBmiInfo、CountryFocusService 都是這個 pattern）。
CREATE NONCLUSTERED INDEX IX_CreditRating_Country_M_Country_CreateDate
ON [dbo].[CreditRating_Country_M] ([FK_CountryId], [Create_date] DESC)
INCLUDE ([Score]);
