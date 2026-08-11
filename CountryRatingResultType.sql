USE [NCRMS]
GO

-- SQL Server 不支援 CREATE OR ALTER TYPE；存在時驗證契約，不刪除既有 type，
-- 因此本腳本可安全重複執行，也不會破壞相依的預存程序。
IF TYPE_ID(N'dbo.CountryRatingResultType') IS NULL
BEGIN
    EXEC(N'
        CREATE TYPE [dbo].[CountryRatingResultType] AS TABLE
        (
            [FK_Country_Id] INT NOT NULL PRIMARY KEY,
            [FinalRating] INT NOT NULL,
            [Score] INT NOT NULL
        );');
END
ELSE IF
    (SELECT COUNT(*)
     FROM sys.table_types tt
     INNER JOIN sys.columns c ON c.object_id = tt.type_table_object_id
     WHERE tt.schema_id = SCHEMA_ID(N'dbo')
       AND tt.name = N'CountryRatingResultType') <> 3
    OR
    (SELECT COUNT(*)
     FROM sys.table_types tt
     INNER JOIN sys.columns c ON c.object_id = tt.type_table_object_id
     INNER JOIN sys.types st ON st.user_type_id = c.user_type_id
     WHERE tt.schema_id = SCHEMA_ID(N'dbo')
       AND tt.name = N'CountryRatingResultType'
       AND (
           (c.column_id = 1 AND c.name = N'FK_Country_Id' AND st.name = N'int' AND c.is_nullable = 0)
           OR (c.column_id = 2 AND c.name = N'FinalRating' AND st.name = N'int' AND c.is_nullable = 0)
           OR (c.column_id = 3 AND c.name = N'Score' AND st.name = N'int' AND c.is_nullable = 0)
       )) <> 3
    OR NOT EXISTS
       (SELECT 1
        FROM sys.table_types tt
        INNER JOIN sys.indexes i ON i.object_id = tt.type_table_object_id
        INNER JOIN sys.index_columns ic
            ON ic.object_id = i.object_id
            AND ic.index_id = i.index_id
        INNER JOIN sys.columns c
            ON c.object_id = ic.object_id
            AND c.column_id = ic.column_id
        WHERE tt.schema_id = SCHEMA_ID(N'dbo')
          AND tt.name = N'CountryRatingResultType'
          AND i.is_primary_key = 1
          AND c.name = N'FK_Country_Id')
BEGIN
    THROW 51000, 'dbo.CountryRatingResultType exists but does not match the required contract.', 1;
END
GO
