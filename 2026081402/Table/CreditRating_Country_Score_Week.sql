SET NOCOUNT ON;
SET XACT_ABORT ON;

IF OBJECT_ID(N'[dbo].[CountryMaster]', N'U') IS NULL
   OR COL_LENGTH(N'dbo.CountryMaster', N'CreditRatingScore') IS NULL
   OR COL_LENGTH(N'dbo.CountryMaster', N'CreditRatingScorePublishedAt') IS NULL
    THROW 51500, N'缺少 dbo.CountryMaster 或其 CreditRatingScore／CreditRatingScorePublishedAt 欄位。', 1;

IF OBJECT_ID(N'[dbo].[CreditRating_Country_Score_Week]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[CreditRating_Country_Score_Week]
    (
        [PK_Id]                               int            IDENTITY(1, 1) NOT NULL,
        [Year]                                 int                           NOT NULL,
        [Month]                                int                           NOT NULL,
        [Week]                                 int                           NOT NULL,
        [DataDate]                             date                          NOT NULL,
        [FK_Country_Id]                        int                           NOT NULL,
        [CreditRatingScore]                    tinyint                       NOT NULL,
        [CreditRatingScorePublishedAt]         datetime                         NULL,
        [IsActive]                             bit                           NOT NULL,
        [Create_date]                          datetime                     NOT NULL,
        [Create_user]                          nvarchar(20)                     NULL,
        CONSTRAINT [PK_CreditRating_Country_Score_Week]
            PRIMARY KEY CLUSTERED ([PK_Id]),
        CONSTRAINT [UQ_CreditRating_Country_Score_Week_Period_Country]
            UNIQUE ([Year], [Month], [Week], [FK_Country_Id])
    );

    CREATE INDEX [IX_CreditRating_Country_Score_Week_Year_Month_Week]
        ON [dbo].[CreditRating_Country_Score_Week] ([Year], [Month], [Week]);
END;
ELSE
BEGIN
    IF COL_LENGTH(N'dbo.CreditRating_Country_Score_Week', N'PK_Id') IS NULL
       OR COL_LENGTH(N'dbo.CreditRating_Country_Score_Week', N'Year') IS NULL
       OR COL_LENGTH(N'dbo.CreditRating_Country_Score_Week', N'Month') IS NULL
       OR COL_LENGTH(N'dbo.CreditRating_Country_Score_Week', N'Week') IS NULL
       OR COL_LENGTH(N'dbo.CreditRating_Country_Score_Week', N'DataDate') IS NULL
       OR COL_LENGTH(N'dbo.CreditRating_Country_Score_Week', N'FK_Country_Id') IS NULL
       OR COL_LENGTH(N'dbo.CreditRating_Country_Score_Week', N'CreditRatingScore') IS NULL
       OR COL_LENGTH(N'dbo.CreditRating_Country_Score_Week', N'CreditRatingScorePublishedAt') IS NULL
       OR COL_LENGTH(N'dbo.CreditRating_Country_Score_Week', N'IsActive') IS NULL
       OR COL_LENGTH(N'dbo.CreditRating_Country_Score_Week', N'Create_date') IS NULL
       OR COL_LENGTH(N'dbo.CreditRating_Country_Score_Week', N'Create_user') IS NULL
       OR (SELECT COUNT(*) FROM sys.columns WHERE [object_id] = OBJECT_ID(N'[dbo].[CreditRating_Country_Score_Week]')) <> 11
        THROW 51501, N'dbo.CreditRating_Country_Score_Week 已存在，但欄位集合不符合本批次定義。', 1;

    IF NOT EXISTS
       (
           SELECT 1
           FROM sys.columns AS c
           INNER JOIN sys.types AS t ON t.user_type_id = c.user_type_id
           WHERE c.[object_id] = OBJECT_ID(N'[dbo].[CreditRating_Country_Score_Week]')
             AND c.[name] = N'PK_Id' AND t.[name] = N'int'
             AND c.is_nullable = 0 AND c.is_identity = 1
       )
       OR EXISTS
       (
           SELECT 1
           FROM sys.columns AS c
           INNER JOIN sys.types AS t ON t.user_type_id = c.user_type_id
           WHERE c.[object_id] = OBJECT_ID(N'[dbo].[CreditRating_Country_Score_Week]')
             AND
             (
                 (c.[name] IN (N'Year', N'Month', N'Week', N'FK_Country_Id') AND (t.[name] <> N'int' OR c.is_nullable <> 0))
                 OR (c.[name] = N'DataDate' AND (t.[name] <> N'date' OR c.is_nullable <> 0))
                 OR (c.[name] = N'CreditRatingScore' AND (t.[name] <> N'tinyint' OR c.is_nullable <> 0))
                 OR (c.[name] = N'CreditRatingScorePublishedAt' AND (t.[name] <> N'datetime' OR c.is_nullable <> 1))
                 OR (c.[name] = N'IsActive' AND (t.[name] <> N'bit' OR c.is_nullable <> 0))
                 OR (c.[name] = N'Create_date' AND (t.[name] <> N'datetime' OR c.is_nullable <> 0))
                 OR (c.[name] = N'Create_user' AND (t.[name] <> N'nvarchar' OR c.max_length <> 40 OR c.is_nullable <> 1))
             )
       )
        THROW 51502, N'dbo.CreditRating_Country_Score_Week 已存在，但欄位型別或 nullability 不符合本批次定義。', 1;

    IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE [parent_object_id] = OBJECT_ID(N'[dbo].[CreditRating_Country_Score_Week]') AND [name] = N'PK_CreditRating_Country_Score_Week')
       OR NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE [parent_object_id] = OBJECT_ID(N'[dbo].[CreditRating_Country_Score_Week]') AND [name] = N'UQ_CreditRating_Country_Score_Week_Period_Country')
        THROW 51503, N'dbo.CreditRating_Country_Score_Week 已存在，但 constraint 結構不符合本批次定義。', 1;

    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [object_id] = OBJECT_ID(N'[dbo].[CreditRating_Country_Score_Week]') AND [name] = N'IX_CreditRating_Country_Score_Week_Year_Month_Week')
        THROW 51504, N'dbo.CreditRating_Country_Score_Week 已存在，但缺少 IX_CreditRating_Country_Score_Week_Year_Month_Week 索引。', 1;
END;
