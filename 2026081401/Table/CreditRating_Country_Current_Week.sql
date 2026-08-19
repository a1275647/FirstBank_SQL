SET NOCOUNT ON;
SET XACT_ABORT ON;

IF OBJECT_ID(N'[dbo].[CreditRating_Country_Current]', N'U') IS NULL
    THROW 51400, N'缺少 dbo.CreditRating_Country_Current。', 1;

IF OBJECT_ID(N'[dbo].[CreditRating_Country_Current_Week]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[CreditRating_Country_Current_Week]
    (
        [PK_Id]                               int            IDENTITY(1, 1) NOT NULL,
        [Year]                                 int                           NOT NULL,
        [Month]                                int                           NOT NULL,
        [Week]                                 int                           NOT NULL,
        [DataDate]                             date                          NOT NULL,
        [FK_Country_Id]                        int                           NOT NULL,
        [FK_RatingAgency_Id]                   int                           NOT NULL,
        [AgencyRating]                         nvarchar(20)                  NOT NULL,
        [RatingDate]                           datetime                         NULL,
        [RatingOutlook]                        nvarchar(50)                     NULL,
        [RatingOutlookDate]                    datetime                        NULL,
        [Remarks]                              nvarchar(500)                    NULL,
        [updated_Date]                         datetime                     NOT NULL,
        [Create_date]                          datetime                     NOT NULL,
        [Create_user]                          nvarchar(20)                     NULL,
        [PublishedAt]                          datetime                     NOT NULL,
        CONSTRAINT [PK_CreditRating_Country_Current_Week]
            PRIMARY KEY CLUSTERED ([PK_Id]),
        CONSTRAINT [UQ_CreditRating_Country_Current_Week_Period_Agency_Country]
            UNIQUE ([Year], [Month], [Week], [FK_Country_Id], [FK_RatingAgency_Id])
    );

    CREATE INDEX [IX_CreditRating_Country_Current_Week_Year_Month_Week]
        ON [dbo].[CreditRating_Country_Current_Week] ([Year], [Month], [Week]);
END;
ELSE
BEGIN
    IF COL_LENGTH(N'dbo.CreditRating_Country_Current_Week', N'PK_Id') IS NULL
       OR COL_LENGTH(N'dbo.CreditRating_Country_Current_Week', N'Year') IS NULL
       OR COL_LENGTH(N'dbo.CreditRating_Country_Current_Week', N'Month') IS NULL
       OR COL_LENGTH(N'dbo.CreditRating_Country_Current_Week', N'Week') IS NULL
       OR COL_LENGTH(N'dbo.CreditRating_Country_Current_Week', N'DataDate') IS NULL
       OR COL_LENGTH(N'dbo.CreditRating_Country_Current_Week', N'FK_Country_Id') IS NULL
       OR COL_LENGTH(N'dbo.CreditRating_Country_Current_Week', N'FK_RatingAgency_Id') IS NULL
       OR COL_LENGTH(N'dbo.CreditRating_Country_Current_Week', N'AgencyRating') IS NULL
       OR COL_LENGTH(N'dbo.CreditRating_Country_Current_Week', N'RatingDate') IS NULL
       OR COL_LENGTH(N'dbo.CreditRating_Country_Current_Week', N'RatingOutlook') IS NULL
       OR COL_LENGTH(N'dbo.CreditRating_Country_Current_Week', N'RatingOutlookDate') IS NULL
       OR COL_LENGTH(N'dbo.CreditRating_Country_Current_Week', N'Remarks') IS NULL
       OR COL_LENGTH(N'dbo.CreditRating_Country_Current_Week', N'updated_Date') IS NULL
       OR COL_LENGTH(N'dbo.CreditRating_Country_Current_Week', N'Create_date') IS NULL
       OR COL_LENGTH(N'dbo.CreditRating_Country_Current_Week', N'Create_user') IS NULL
       OR COL_LENGTH(N'dbo.CreditRating_Country_Current_Week', N'PublishedAt') IS NULL
       OR (SELECT COUNT(*) FROM sys.columns WHERE [object_id] = OBJECT_ID(N'[dbo].[CreditRating_Country_Current_Week]')) <> 16
        THROW 51401, N'dbo.CreditRating_Country_Current_Week 已存在，但欄位集合不符合本批次定義。', 1;

    IF NOT EXISTS
       (
           SELECT 1
           FROM sys.columns AS c
           INNER JOIN sys.types AS t ON t.user_type_id = c.user_type_id
           WHERE c.[object_id] = OBJECT_ID(N'[dbo].[CreditRating_Country_Current_Week]')
             AND c.[name] = N'PK_Id' AND t.[name] = N'int'
             AND c.is_nullable = 0 AND c.is_identity = 1
       )
       OR EXISTS
       (
           SELECT 1
           FROM sys.columns AS c
           INNER JOIN sys.types AS t ON t.user_type_id = c.user_type_id
           WHERE c.[object_id] = OBJECT_ID(N'[dbo].[CreditRating_Country_Current_Week]')
             AND
             (
                 (c.[name] IN (N'Year', N'Month', N'Week', N'FK_Country_Id', N'FK_RatingAgency_Id') AND (t.[name] <> N'int' OR c.is_nullable <> 0))
                 OR (c.[name] = N'DataDate' AND (t.[name] <> N'date' OR c.is_nullable <> 0))
                 OR (c.[name] = N'AgencyRating' AND (t.[name] <> N'nvarchar' OR c.max_length <> 40 OR c.is_nullable <> 0))
                 OR (c.[name] = N'RatingDate' AND (t.[name] <> N'datetime' OR c.is_nullable <> 1))
                 OR (c.[name] = N'RatingOutlook' AND (t.[name] <> N'nvarchar' OR c.max_length <> 100 OR c.is_nullable <> 1))
                 OR (c.[name] = N'RatingOutlookDate' AND (t.[name] <> N'datetime' OR c.is_nullable <> 1))
                 OR (c.[name] = N'Remarks' AND (t.[name] <> N'nvarchar' OR c.max_length <> 1000 OR c.is_nullable <> 1))
                 OR (c.[name] = N'updated_Date' AND (t.[name] <> N'datetime' OR c.is_nullable <> 0))
                 OR (c.[name] IN (N'Create_date', N'PublishedAt') AND (t.[name] <> N'datetime' OR c.is_nullable <> 0))
                 OR (c.[name] = N'Create_user' AND (t.[name] <> N'nvarchar' OR c.max_length <> 40 OR c.is_nullable <> 1))
             )
       )
        THROW 51402, N'dbo.CreditRating_Country_Current_Week 已存在，但欄位型別或 nullability 不符合本批次定義。', 1;

    IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE [parent_object_id] = OBJECT_ID(N'[dbo].[CreditRating_Country_Current_Week]') AND [name] = N'PK_CreditRating_Country_Current_Week')
       OR NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE [parent_object_id] = OBJECT_ID(N'[dbo].[CreditRating_Country_Current_Week]') AND [name] = N'UQ_CreditRating_Country_Current_Week_Period_Agency_Country')
        THROW 51403, N'dbo.CreditRating_Country_Current_Week 已存在，但 constraint 結構不符合本批次定義。', 1;

    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [object_id] = OBJECT_ID(N'[dbo].[CreditRating_Country_Current_Week]') AND [name] = N'IX_CreditRating_Country_Current_Week_Year_Month_Week')
        THROW 51404, N'dbo.CreditRating_Country_Current_Week 已存在，但缺少 IX_CreditRating_Country_Current_Week_Year_Month_Week 索引。', 1;
END;
