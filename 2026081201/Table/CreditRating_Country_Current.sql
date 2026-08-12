SET NOCOUNT ON;
SET XACT_ABORT ON;

IF OBJECT_ID(N'[dbo].[CreditRating_Country_Log_Detail]', N'U') IS NULL
    THROW 51020, N'請先建立 dbo.CreditRating_Country_Log_Detail。', 1;

IF OBJECT_ID(N'[dbo].[CountryMaster]', N'U') IS NULL
   OR OBJECT_ID(N'[dbo].[CreditRatingMaster]', N'U') IS NULL
    THROW 51021, N'缺少 dbo.CountryMaster 或 dbo.CreditRatingMaster。', 1;

IF OBJECT_ID(N'[dbo].[CreditRating_Country_Current]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[CreditRating_Country_Current]
    (
        [PK_Id]                               int            IDENTITY(1, 1) NOT NULL,
        [FK_CreditRatingCountryLogDetailId]   int                           NOT NULL,
        [FK_Country_Id]                       int                           NOT NULL,
        [FK_RatingAgency_Id]                  int                           NOT NULL,
        [AgencyRating]                        nvarchar(20)                  NOT NULL,
        [RatingDate]                          datetime2(7)                  NOT NULL,
        [RatingOutlook]                       nvarchar(50)                      NULL,
        [RatingOutlookDate]                   datetime2(7)                     NULL,
        [Remarks]                             nvarchar(500)                     NULL,
        [date]                                date                          NOT NULL,
        [Create_date]                         datetime2(7)                  NOT NULL,
        [Create_user]                         nvarchar(20)                      NULL,
        [PublishedAt]                         datetime2(7)                  NOT NULL,
        CONSTRAINT [PK_CreditRating_Country_Current]
            PRIMARY KEY CLUSTERED ([PK_Id]),
        CONSTRAINT [UQ_CreditRating_Country_Current_Agency_Country]
            UNIQUE ([FK_RatingAgency_Id], [FK_Country_Id]),
        CONSTRAINT [UQ_CreditRating_Country_Current_LogDetail]
            UNIQUE ([FK_CreditRatingCountryLogDetailId]),
        CONSTRAINT [FK_CreditRating_Country_Current_Log_Detail]
            FOREIGN KEY ([FK_CreditRatingCountryLogDetailId], [FK_Country_Id], [FK_RatingAgency_Id])
            REFERENCES [dbo].[CreditRating_Country_Log_Detail] ([PK_Id], [FK_Country_Id], [FK_RatingAgency_Id])
            ON DELETE NO ACTION
            ON UPDATE NO ACTION,
        CONSTRAINT [FK_CreditRating_Country_Current_CountryMaster]
            FOREIGN KEY ([FK_Country_Id])
            REFERENCES [dbo].[CountryMaster] ([PK_Id])
            ON DELETE NO ACTION
            ON UPDATE NO ACTION,
        CONSTRAINT [FK_CreditRating_Country_Current_CreditRatingMaster]
            FOREIGN KEY ([FK_RatingAgency_Id])
            REFERENCES [dbo].[CreditRatingMaster] ([PK_ID])
            ON DELETE NO ACTION
            ON UPDATE NO ACTION
    );
END;
ELSE
BEGIN
    IF COL_LENGTH(N'dbo.CreditRating_Country_Current', N'PK_Id') IS NULL
       OR COL_LENGTH(N'dbo.CreditRating_Country_Current', N'FK_CreditRatingCountryLogDetailId') IS NULL
       OR COL_LENGTH(N'dbo.CreditRating_Country_Current', N'FK_Country_Id') IS NULL
       OR COL_LENGTH(N'dbo.CreditRating_Country_Current', N'FK_RatingAgency_Id') IS NULL
       OR COL_LENGTH(N'dbo.CreditRating_Country_Current', N'AgencyRating') IS NULL
       OR COL_LENGTH(N'dbo.CreditRating_Country_Current', N'RatingDate') IS NULL
       OR COL_LENGTH(N'dbo.CreditRating_Country_Current', N'RatingOutlook') IS NULL
       OR COL_LENGTH(N'dbo.CreditRating_Country_Current', N'RatingOutlookDate') IS NULL
       OR COL_LENGTH(N'dbo.CreditRating_Country_Current', N'Remarks') IS NULL
       OR COL_LENGTH(N'dbo.CreditRating_Country_Current', N'date') IS NULL
       OR COL_LENGTH(N'dbo.CreditRating_Country_Current', N'Create_date') IS NULL
       OR COL_LENGTH(N'dbo.CreditRating_Country_Current', N'Create_user') IS NULL
       OR COL_LENGTH(N'dbo.CreditRating_Country_Current', N'PublishedAt') IS NULL
       OR (SELECT COUNT(*) FROM sys.columns WHERE [object_id] = OBJECT_ID(N'[dbo].[CreditRating_Country_Current]')) <> 13
        THROW 51022, N'dbo.CreditRating_Country_Current 已存在，但欄位集合不符合本批次定義。', 1;

    IF NOT EXISTS
       (
           SELECT 1
           FROM sys.columns AS c
           INNER JOIN sys.types AS t ON t.user_type_id = c.user_type_id
           WHERE c.[object_id] = OBJECT_ID(N'[dbo].[CreditRating_Country_Current]')
             AND c.[name] = N'PK_Id' AND t.[name] = N'int'
             AND c.is_nullable = 0 AND c.is_identity = 1
       )
       OR EXISTS
       (
           SELECT 1
           FROM sys.columns AS c
           INNER JOIN sys.types AS t ON t.user_type_id = c.user_type_id
           WHERE c.[object_id] = OBJECT_ID(N'[dbo].[CreditRating_Country_Current]')
             AND
             (
                 (c.[name] IN (N'FK_CreditRatingCountryLogDetailId', N'FK_Country_Id', N'FK_RatingAgency_Id') AND (t.[name] <> N'int' OR c.is_nullable <> 0))
                 OR (c.[name] = N'AgencyRating' AND (t.[name] <> N'nvarchar' OR c.max_length <> 40 OR c.is_nullable <> 0))
                 OR (c.[name] = N'RatingDate' AND (t.[name] <> N'datetime2' OR c.scale <> 7 OR c.is_nullable <> 0))
                 OR (c.[name] = N'RatingOutlook' AND (t.[name] <> N'nvarchar' OR c.max_length <> 100 OR c.is_nullable <> 1))
                 OR (c.[name] = N'RatingOutlookDate' AND (t.[name] <> N'datetime2' OR c.scale <> 7 OR c.is_nullable <> 1))
                 OR (c.[name] = N'Remarks' AND (t.[name] <> N'nvarchar' OR c.max_length <> 1000 OR c.is_nullable <> 1))
                 OR (c.[name] = N'date' AND (t.[name] <> N'date' OR c.is_nullable <> 0))
                 OR (c.[name] IN (N'Create_date', N'PublishedAt') AND (t.[name] <> N'datetime2' OR c.scale <> 7 OR c.is_nullable <> 0))
                 OR (c.[name] = N'Create_user' AND (t.[name] <> N'nvarchar' OR c.max_length <> 40 OR c.is_nullable <> 1))
             )
       )
        THROW 51023, N'dbo.CreditRating_Country_Current 已存在，但欄位型別或 nullability 不符合本批次定義。', 1;

    IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE [parent_object_id] = OBJECT_ID(N'[dbo].[CreditRating_Country_Current]') AND [name] = N'PK_CreditRating_Country_Current')
       OR NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE [parent_object_id] = OBJECT_ID(N'[dbo].[CreditRating_Country_Current]') AND [name] = N'UQ_CreditRating_Country_Current_Agency_Country')
       OR NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE [parent_object_id] = OBJECT_ID(N'[dbo].[CreditRating_Country_Current]') AND [name] = N'UQ_CreditRating_Country_Current_LogDetail')
       OR NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE [parent_object_id] = OBJECT_ID(N'[dbo].[CreditRating_Country_Current]') AND [name] = N'FK_CreditRating_Country_Current_Log_Detail')
       OR NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE [parent_object_id] = OBJECT_ID(N'[dbo].[CreditRating_Country_Current]') AND [name] = N'FK_CreditRating_Country_Current_CountryMaster')
       OR NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE [parent_object_id] = OBJECT_ID(N'[dbo].[CreditRating_Country_Current]') AND [name] = N'FK_CreditRating_Country_Current_CreditRatingMaster')
        THROW 51024, N'dbo.CreditRating_Country_Current 已存在，但 constraint 結構不符合本批次定義。', 1;
END;
