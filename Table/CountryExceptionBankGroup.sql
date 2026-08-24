SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[CountryExceptionBankGroup](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_CountryExceptionId] [int] NOT NULL,
	[FK_BankGroupCode] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[CreditBusiness] [bit] NULL,
	[InterbankDepositBusiness] [bit] NULL,
	[InvestmentBusiness] [bit] NULL,
 CONSTRAINT [PK_CountryExceptionBankGroup] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[CountryExceptionBankGroup]  WITH CHECK ADD  CONSTRAINT [FK_CountryExceptionBankGroup_CountryException] FOREIGN KEY([FK_CountryExceptionId])
REFERENCES [dbo].[CountryException] ([PK_Id])
GO
ALTER TABLE [dbo].[CountryExceptionBankGroup] CHECK CONSTRAINT [FK_CountryExceptionBankGroup_CountryException]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'授信業務' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryExceptionBankGroup', @level2type=N'COLUMN',@level2name=N'CreditBusiness'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'拆存業務' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryExceptionBankGroup', @level2type=N'COLUMN',@level2name=N'InterbankDepositBusiness'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'投資業務' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryExceptionBankGroup', @level2type=N'COLUMN',@level2name=N'InvestmentBusiness'
GO
