SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[QuotaBank_Weight_Form_AllData](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[QuotaD_Form_AllDataId] [int] NOT NULL,
	[WeightPercent] [int] NOT NULL,
	[QuotaAmount] [int] NOT NULL,
 CONSTRAINT [PK_QuotaBank_Weight_Form_AllData] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[QuotaBank_Weight_Form_AllData]  WITH CHECK ADD  CONSTRAINT [FK_QuotaBank_Weight_Form_AllData_QuotaBank_D_Form_AllData] FOREIGN KEY([QuotaD_Form_AllDataId])
REFERENCES [dbo].[QuotaBank_D_Form_AllData] ([Pk_Id])
GO
ALTER TABLE [dbo].[QuotaBank_Weight_Form_AllData] CHECK CONSTRAINT [FK_QuotaBank_Weight_Form_AllData_QuotaBank_D_Form_AllData]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'主表暫存資料外鍵' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QuotaBank_Weight_Form_AllData', @level2type=N'COLUMN',@level2name=N'QuotaD_Form_AllDataId'
GO
