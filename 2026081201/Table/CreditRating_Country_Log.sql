SET NOCOUNT ON;
SET XACT_ABORT ON;

IF OBJECT_ID(N'[dbo].[CountryMaster]', N'U') IS NULL
    THROW 51000, N'缺少前置資料表 dbo.CountryMaster。', 1;

IF OBJECT_ID(N'[dbo].[CreditRating_Country_Log]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[CreditRating_Country_Log]
    (
        [PK_Id]        int          IDENTITY(1, 1) NOT NULL,
        [FK_CountryId] int                         NOT NULL,
        [Score]        int                         NOT NULL,
        [Create_date]  datetime                   NOT NULL,
        CONSTRAINT [PK_CreditRating_Country_Log]
            PRIMARY KEY CLUSTERED ([PK_Id]),
        CONSTRAINT [UQ_CreditRating_Country_Log_Country_CreateDate]
            UNIQUE ([FK_CountryId], [Create_date]),
        CONSTRAINT [UQ_CreditRating_Country_Log_Id_Country]
            UNIQUE ([PK_Id], [FK_CountryId]),
        CONSTRAINT [FK_CreditRating_Country_Log_CountryMaster]
            FOREIGN KEY ([FK_CountryId])
            REFERENCES [dbo].[CountryMaster] ([PK_Id])
            ON DELETE NO ACTION
            ON UPDATE NO ACTION
    );
END;
ELSE
BEGIN
    IF COL_LENGTH(N'dbo.CreditRating_Country_Log', N'PK_Id') IS NULL
       OR COL_LENGTH(N'dbo.CreditRating_Country_Log', N'FK_CountryId') IS NULL
       OR COL_LENGTH(N'dbo.CreditRating_Country_Log', N'Score') IS NULL
       OR COL_LENGTH(N'dbo.CreditRating_Country_Log', N'Create_date') IS NULL
       OR (SELECT COUNT(*) FROM sys.columns WHERE [object_id] = OBJECT_ID(N'[dbo].[CreditRating_Country_Log]')) <> 4
       OR NOT EXISTS
          (
              SELECT 1
              FROM sys.columns AS c
              INNER JOIN sys.types AS t ON t.user_type_id = c.user_type_id
              WHERE c.[object_id] = OBJECT_ID(N'[dbo].[CreditRating_Country_Log]')
                AND c.[name] = N'PK_Id' AND t.[name] = N'int'
                AND c.is_nullable = 0 AND c.is_identity = 1
          )
       OR NOT EXISTS
          (
              SELECT 1
              FROM sys.columns AS c
              INNER JOIN sys.types AS t ON t.user_type_id = c.user_type_id
              WHERE c.[object_id] = OBJECT_ID(N'[dbo].[CreditRating_Country_Log]')
                AND c.[name] = N'FK_CountryId' AND t.[name] = N'int' AND c.is_nullable = 0
          )
       OR NOT EXISTS
          (
              SELECT 1
              FROM sys.columns AS c
              INNER JOIN sys.types AS t ON t.user_type_id = c.user_type_id
              WHERE c.[object_id] = OBJECT_ID(N'[dbo].[CreditRating_Country_Log]')
                AND c.[name] = N'Score' AND t.[name] = N'int' AND c.is_nullable = 0
          )
       OR NOT EXISTS
          (
              SELECT 1
              FROM sys.columns AS c
              INNER JOIN sys.types AS t ON t.user_type_id = c.user_type_id
              WHERE c.[object_id] = OBJECT_ID(N'[dbo].[CreditRating_Country_Log]')
                AND c.[name] = N'Create_date' AND t.[name] = N'datetime'
                AND c.is_nullable = 0
          )
        THROW 51001, N'dbo.CreditRating_Country_Log 已存在，但欄位結構不符合本批次定義。', 1;

    IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE [parent_object_id] = OBJECT_ID(N'[dbo].[CreditRating_Country_Log]') AND [name] = N'PK_CreditRating_Country_Log')
       OR NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE [parent_object_id] = OBJECT_ID(N'[dbo].[CreditRating_Country_Log]') AND [name] = N'UQ_CreditRating_Country_Log_Country_CreateDate')
       OR NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE [parent_object_id] = OBJECT_ID(N'[dbo].[CreditRating_Country_Log]') AND [name] = N'UQ_CreditRating_Country_Log_Id_Country')
       OR NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE [parent_object_id] = OBJECT_ID(N'[dbo].[CreditRating_Country_Log]') AND [name] = N'FK_CreditRating_Country_Log_CountryMaster')
        THROW 51002, N'dbo.CreditRating_Country_Log 已存在，但 constraint 結構不符合本批次定義。', 1;
END;
