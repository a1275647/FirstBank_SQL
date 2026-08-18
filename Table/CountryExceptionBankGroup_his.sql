SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CountryExceptionBankGroup_his](
	[Log_Id] [int] IDENTITY(1,1) NOT NULL,
	[Fk_LogId] [int] NOT NULL,
	[LogType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[PK_Id] [int] NULL,
	[FK_CountryExceptionId] [int] NULL,
	[FK_BankGroupCode] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CreditBusiness] [bit] NULL,
	[InterbankDepositBusiness] [bit] NULL,
	[InvestmentBusiness] [bit] NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_CountryExceptionBankGroup_his] PRIMARY KEY CLUSTERED
(
	[Log_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
GO
ALTER TABLE [dbo].[CountryExceptionBankGroup_his] ADD  CONSTRAINT [DF_CountryExceptionBankGroup_his_SysCreateDate]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'授信業務' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryExceptionBankGroup_his', @level2type=N'COLUMN',@level2name=N'CreditBusiness'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'拆存業務' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryExceptionBankGroup_his', @level2type=N'COLUMN',@level2name=N'InterbankDepositBusiness'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'投資業務' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryExceptionBankGroup_his', @level2type=N'COLUMN',@level2name=N'InvestmentBusiness'
GO
