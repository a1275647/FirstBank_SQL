SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[QuotaBank_Form_Data](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FlowFormId] [int] NOT NULL,
	[TotalNetWorthUSD] [decimal](18, 2) NOT NULL,
	[SysCreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_QuotaBank_Form_Data] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
GO
ALTER TABLE [dbo].[QuotaBank_Form_Data] ADD  CONSTRAINT [DF_QuotaBank_Form_Data_SysCreateDate]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
ALTER TABLE [dbo].[QuotaBank_Form_Data]  WITH CHECK ADD  CONSTRAINT [FK_QuotaBank_Form_Data_FlowForm] FOREIGN KEY([FlowFormId])
REFERENCES [dbo].[FlowForm] ([PK_Id])
GO
ALTER TABLE [dbo].[QuotaBank_Form_Data] CHECK CONSTRAINT [FK_QuotaBank_Form_Data_FlowForm]
GO
