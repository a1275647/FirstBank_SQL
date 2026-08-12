SET NOCOUNT ON;
SET XACT_ABORT ON;

IF OBJECT_ID(N'[dbo].[CreditRating_Country_Log]', N'U') IS NULL
    THROW 51010, N'請先建立 dbo.CreditRating_Country_Log。', 1;

IF OBJECT_ID(N'[dbo].[CountryMaster]', N'U') IS NULL
   OR OBJECT_ID(N'[dbo].[CreditRatingMaster]', N'U') IS NULL
    THROW 51011, N'缺少 dbo.CountryMaster 或 dbo.CreditRatingMaster。', 1;

IF OBJECT_ID(N'[dbo].[CreditRating_Country_Log_Detail]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[CreditRating_Country_Log_Detail]
    (
        [PK_Id]                              int            IDENTITY(1, 1) NOT NULL,
        [FK_CreditRatingCountryLogId]        int                           NOT NULL,
        [FK_Country_Id]                      int                           NOT NULL,
        [FK_RatingAgency_Id]                 int                           NOT NULL,
        [AgencyRating]                       nvarchar(20)                  NOT NULL,
        [RatingDate]                         datetime2(7)                  NOT NULL,
        [RatingOutlook]                      nvarchar(50)                      NULL,
        [RatingOutlookDate]                  datetime2(7)                     NULL,
        [Remarks]                            nvarchar(500)                     NULL,
        [date]                               date                          NOT NULL,
        [Create_date]                        datetime2(7)                  NOT NULL,
        [Create_user]                        nvarchar(20)                      NULL,
        CONSTRAINT [PK_CreditRating_Country_Log_Detail]
            PRIMARY KEY CLUSTERED ([PK_Id]),
        CONSTRAINT [UQ_CreditRating_Country_Log_Detail_Log_Agency]
            UNIQUE ([FK_CreditRatingCountryLogId], [FK_RatingAgency_Id]),
        CONSTRAINT [UQ_CreditRating_Country_Log_Detail_Id_Country_Agency]
            UNIQUE ([PK_Id], [FK_Country_Id], [FK_RatingAgency_Id]),
        CONSTRAINT [FK_CreditRating_Country_Log_Detail_Log]
            FOREIGN KEY ([FK_CreditRatingCountryLogId], [FK_Country_Id])
            REFERENCES [dbo].[CreditRating_Country_Log] ([PK_Id], [FK_CountryId])
            ON DELETE NO ACTION
            ON UPDATE NO ACTION,
        CONSTRAINT [FK_CreditRating_Country_Log_Detail_CountryMaster]
            FOREIGN KEY ([FK_Country_Id])
            REFERENCES [dbo].[CountryMaster] ([PK_Id])
            ON DELETE NO ACTION
            ON UPDATE NO ACTION,
        CONSTRAINT [FK_CreditRating_Country_Log_Detail_CreditRatingMaster]
            FOREIGN KEY ([FK_RatingAgency_Id])
            REFERENCES [dbo].[CreditRatingMaster] ([PK_ID])
            ON DELETE NO ACTION
            ON UPDATE NO ACTION
    );
END;
ELSE
BEGIN
    IF COL_LENGTH(N'dbo.CreditRating_Country_Log_Detail', N'PK_Id') IS NULL
       OR COL_LENGTH(N'dbo.CreditRating_Country_Log_Detail', N'FK_CreditRatingCountryLogId') IS NULL
       OR COL_LENGTH(N'dbo.CreditRating_Country_Log_Detail', N'FK_Country_Id') IS NULL
       OR COL_LENGTH(N'dbo.CreditRating_Country_Log_Detail', N'FK_RatingAgency_Id') IS NULL
       OR COL_LENGTH(N'dbo.CreditRating_Country_Log_Detail', N'AgencyRating') IS NULL
       OR COL_LENGTH(N'dbo.CreditRating_Country_Log_Detail', N'RatingDate') IS NULL
       OR COL_LENGTH(N'dbo.CreditRating_Country_Log_Detail', N'RatingOutlook') IS NULL
       OR COL_LENGTH(N'dbo.CreditRating_Country_Log_Detail', N'RatingOutlookDate') IS NULL
       OR COL_LENGTH(N'dbo.CreditRating_Country_Log_Detail', N'Remarks') IS NULL
       OR COL_LENGTH(N'dbo.CreditRating_Country_Log_Detail', N'date') IS NULL
       OR COL_LENGTH(N'dbo.CreditRating_Country_Log_Detail', N'Create_date') IS NULL
       OR COL_LENGTH(N'dbo.CreditRating_Country_Log_Detail', N'Create_user') IS NULL
       OR (SELECT COUNT(*) FROM sys.columns WHERE [object_id] = OBJECT_ID(N'[dbo].[CreditRating_Country_Log_Detail]')) <> 12
        THROW 51012, N'dbo.CreditRating_Country_Log_Detail 已存在，但欄位集合不符合本批次定義。', 1;

    IF NOT EXISTS
       (
           SELECT 1
           FROM sys.columns AS c
           INNER JOIN sys.types AS t ON t.user_type_id = c.user_type_id
           WHERE c.[object_id] = OBJECT_ID(N'[dbo].[CreditRating_Country_Log_Detail]')
             AND c.[name] = N'PK_Id' AND t.[name] = N'int'
             AND c.is_nullable = 0 AND c.is_identity = 1
       )
       OR EXISTS
       (
           SELECT 1
           FROM sys.columns AS c
           INNER JOIN sys.types AS t ON t.user_type_id = c.user_type_id
           WHERE c.[object_id] = OBJECT_ID(N'[dbo].[CreditRating_Country_Log_Detail]')
             AND
             (
                 (c.[name] IN (N'FK_CreditRatingCountryLogId', N'FK_Country_Id', N'FK_RatingAgency_Id') AND (t.[name] <> N'int' OR c.is_nullable <> 0))
                 OR (c.[name] = N'AgencyRating' AND (t.[name] <> N'nvarchar' OR c.max_length <> 40 OR c.is_nullable <> 0))
                 OR (c.[name] = N'RatingDate' AND (t.[name] <> N'datetime2' OR c.scale <> 7 OR c.is_nullable <> 0))
                 OR (c.[name] = N'RatingOutlook' AND (t.[name] <> N'nvarchar' OR c.max_length <> 100 OR c.is_nullable <> 1))
                 OR (c.[name] = N'RatingOutlookDate' AND (t.[name] <> N'datetime2' OR c.scale <> 7 OR c.is_nullable <> 1))
                 OR (c.[name] = N'Remarks' AND (t.[name] <> N'nvarchar' OR c.max_length <> 1000 OR c.is_nullable <> 1))
                 OR (c.[name] = N'date' AND (t.[name] <> N'date' OR c.is_nullable <> 0))
                 OR (c.[name] = N'Create_date' AND (t.[name] <> N'datetime2' OR c.scale <> 7 OR c.is_nullable <> 0))
                 OR (c.[name] = N'Create_user' AND (t.[name] <> N'nvarchar' OR c.max_length <> 40 OR c.is_nullable <> 1))
             )
       )
        THROW 51013, N'dbo.CreditRating_Country_Log_Detail 已存在，但欄位型別或 nullability 不符合本批次定義。', 1;

    IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE [parent_object_id] = OBJECT_ID(N'[dbo].[CreditRating_Country_Log_Detail]') AND [name] = N'PK_CreditRating_Country_Log_Detail')
       OR NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE [parent_object_id] = OBJECT_ID(N'[dbo].[CreditRating_Country_Log_Detail]') AND [name] = N'UQ_CreditRating_Country_Log_Detail_Log_Agency')
       OR NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE [parent_object_id] = OBJECT_ID(N'[dbo].[CreditRating_Country_Log_Detail]') AND [name] = N'UQ_CreditRating_Country_Log_Detail_Id_Country_Agency')
       OR NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE [parent_object_id] = OBJECT_ID(N'[dbo].[CreditRating_Country_Log_Detail]') AND [name] = N'FK_CreditRating_Country_Log_Detail_Log')
       OR NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE [parent_object_id] = OBJECT_ID(N'[dbo].[CreditRating_Country_Log_Detail]') AND [name] = N'FK_CreditRating_Country_Log_Detail_CountryMaster')
       OR NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE [parent_object_id] = OBJECT_ID(N'[dbo].[CreditRating_Country_Log_Detail]') AND [name] = N'FK_CreditRating_Country_Log_Detail_CreditRatingMaster')
        THROW 51014, N'dbo.CreditRating_Country_Log_Detail 已存在，但 constraint 結構不符合本批次定義。', 1;
END;
