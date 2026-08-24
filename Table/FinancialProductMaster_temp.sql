SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[FinancialProductMaster_temp](
	[TempId] [int] IDENTITY(1,1) NOT NULL,
	[FlowFormId] [int] NULL,
	[ModifyType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[PK_ID] [int] NOT NULL,
	[FK_GlobalID_FinancialProductCategory] [int] NOT NULL,
	[ProductTypeName] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[ProductCode] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[IsActive] [bit] NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK__Financia__06C703C14E5F190D] PRIMARY KEY CLUSTERED
(
	[TempId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[FinancialProductMaster_temp] ADD  CONSTRAINT [DF__Financial__IsAct__2FAFEA50]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[FinancialProductMaster_temp] ADD  CONSTRAINT [DF__Financial__Updat__30A40E89]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[FinancialProductMaster_temp] ADD  CONSTRAINT [DF__Financial__Updat__319832C2]  DEFAULT ('system') FOR [Update_user]
GO
ALTER TABLE [dbo].[FinancialProductMaster_temp] ADD  CONSTRAINT [DF__Financial__Creat__328C56FB]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[FinancialProductMaster_temp] ADD  CONSTRAINT [DF__Financial__Creat__33807B34]  DEFAULT ('system') FOR [Create_user]
GO
ALTER TABLE [dbo].[FinancialProductMaster_temp] ADD  CONSTRAINT [DF__Financial__SysCr__34749F6D]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
ALTER TABLE [dbo].[FinancialProductMaster_temp]  WITH CHECK ADD  CONSTRAINT [FK_FinancialProductMaster_temp_FlowForm] FOREIGN KEY([FlowFormId])
REFERENCES [dbo].[FlowForm] ([PK_Id])
GO
ALTER TABLE [dbo].[FinancialProductMaster_temp] CHECK CONSTRAINT [FK_FinancialProductMaster_temp_FlowForm]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'暫存資料識別碼（流水號）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FinancialProductMaster_temp', @level2type=N'COLUMN',@level2name=N'TempId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'流程表單識別碼（外鍵：FlowForm.PK_ID）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FinancialProductMaster_temp', @level2type=N'COLUMN',@level2name=N'FlowFormId'
GO
