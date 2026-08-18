SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CountryExceptionBankGroup_temp](
	[TempId] [int] IDENTITY(1,1) NOT NULL,
	[FK_TempId] [int] NOT NULL,
	[ModifyType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[PK_Id] [int] NULL,
	[FK_CountryExceptionId] [int] NULL,
	[FK_BankGroupCode] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[CreditBusiness] [bit] NOT NULL,
	[InterbankDepositBusiness] [bit] NOT NULL,
	[InvestmentBusiness] [bit] NOT NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_Table_1] PRIMARY KEY CLUSTERED
(
	[TempId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
GO
ALTER TABLE [dbo].[CountryExceptionBankGroup_temp] ADD  CONSTRAINT [DF_CountryExceptionBankGroup_temp_CreditBusiness]  DEFAULT ((0)) FOR [CreditBusiness]
GO
ALTER TABLE [dbo].[CountryExceptionBankGroup_temp] ADD  CONSTRAINT [DF_CountryExceptionBankGroup_temp_InterbankDepositBusiness]  DEFAULT ((0)) FOR [InterbankDepositBusiness]
GO
ALTER TABLE [dbo].[CountryExceptionBankGroup_temp] ADD  CONSTRAINT [DF_CountryExceptionBankGroup_temp_InvestmentBusiness]  DEFAULT ((0)) FOR [InvestmentBusiness]
GO
ALTER TABLE [dbo].[CountryExceptionBankGroup_temp] ADD  CONSTRAINT [DF_Table_1_SysCreateDate]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
ALTER TABLE [dbo].[CountryExceptionBankGroup_temp]  WITH CHECK ADD  CONSTRAINT [FK_CountryExceptionBankGroup_temp_CountryException_temp] FOREIGN KEY([FK_TempId])
REFERENCES [dbo].[CountryException_temp] ([TempId])
GO
ALTER TABLE [dbo].[CountryExceptionBankGroup_temp] CHECK CONSTRAINT [FK_CountryExceptionBankGroup_temp_CountryException_temp]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'授信業務' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryExceptionBankGroup_temp', @level2type=N'COLUMN',@level2name=N'CreditBusiness'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'拆存業務' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryExceptionBankGroup_temp', @level2type=N'COLUMN',@level2name=N'InterbankDepositBusiness'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'投資業務' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CountryExceptionBankGroup_temp', @level2type=N'COLUMN',@level2name=N'InvestmentBusiness'
GO
