SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[QuotaBank_M_Form_AllData](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FlowFormId] [int] NULL,
	[CountryId] [int] NOT NULL,
	[RiskLevel] [int] NOT NULL,
	[MaxAmount] [int] NOT NULL,
	[ApprovedAmount] [int] NOT NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[UnitLevel] [int] NOT NULL,
	[ParentUnitCode] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
 CONSTRAINT [PK_QuotaBank_M_Form_AllData] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
GO
ALTER TABLE [dbo].[QuotaBank_M_Form_AllData] ADD  CONSTRAINT [DF_QuotaBank_M_Form_AllData_SysCreateDate]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
ALTER TABLE [dbo].[QuotaBank_M_Form_AllData] ADD  CONSTRAINT [DF_QuotaBank_M_Form_AllData_UnitLevel]  DEFAULT ((0)) FOR [UnitLevel]
GO
ALTER TABLE [dbo].[QuotaBank_M_Form_AllData]  WITH CHECK ADD  CONSTRAINT [FK_QuotaBank_M_Form_AllData_FlowForm] FOREIGN KEY([FlowFormId])
REFERENCES [dbo].[FlowForm] ([PK_Id])
GO
ALTER TABLE [dbo].[QuotaBank_M_Form_AllData] CHECK CONSTRAINT [FK_QuotaBank_M_Form_AllData_FlowForm]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'暫存資料識別碼（流水號）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QuotaBank_M_Form_AllData', @level2type=N'COLUMN',@level2name=N'PK_Id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'流程表單識別碼（外鍵：FlowForm.PK_ID）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QuotaBank_M_Form_AllData', @level2type=N'COLUMN',@level2name=N'FlowFormId'
GO
