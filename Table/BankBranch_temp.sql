SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[BankBranch_temp](
	[TempId] [int] IDENTITY(1,1) NOT NULL,
	[FlowFormId] [int] NULL,
	[ModifyType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[PK_Id] [int] NOT NULL,
	[FK_BankUnit] [int] NULL,
	[BankCode] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[BankName_TN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[BankName_EN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[BankName_CN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[BankName_JP] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Latitude] [decimal](13, 10) NULL,
	[Longitude] [decimal](13, 10) NULL,
	[IsActive] [bit] NOT NULL,
	[IsSave] [bit] NOT NULL,
	[Memo] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK__BankBran__06C703C149E1DA90] PRIMARY KEY CLUSTERED
(
	[TempId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[BankBranch_temp] ADD  CONSTRAINT [DF__BankBranc__BankC__0134F289]  DEFAULT ('') FOR [BankCode]
GO
ALTER TABLE [dbo].[BankBranch_temp] ADD  CONSTRAINT [DF__BankBranc__BankN__022916C2]  DEFAULT ('') FOR [BankName_TN]
GO
ALTER TABLE [dbo].[BankBranch_temp] ADD  CONSTRAINT [DF__BankBranc__BankN__031D3AFB]  DEFAULT ('') FOR [BankName_EN]
GO
ALTER TABLE [dbo].[BankBranch_temp] ADD  CONSTRAINT [DF__BankBranc__BankN__04115F34]  DEFAULT ('') FOR [BankName_CN]
GO
ALTER TABLE [dbo].[BankBranch_temp] ADD  CONSTRAINT [DF__BankBranc__BankN__0505836D]  DEFAULT ('') FOR [BankName_JP]
GO
ALTER TABLE [dbo].[BankBranch_temp] ADD  CONSTRAINT [DF__BankBranc__IsAct__05F9A7A6]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[BankBranch_temp] ADD  CONSTRAINT [DF__BankBranc__IsSav__06EDCBDF]  DEFAULT ((0)) FOR [IsSave]
GO
ALTER TABLE [dbo].[BankBranch_temp] ADD  CONSTRAINT [DF__BankBranch__Memo__07E1F018]  DEFAULT ('') FOR [Memo]
GO
ALTER TABLE [dbo].[BankBranch_temp] ADD  CONSTRAINT [DF__BankBranc__Updat__08D61451]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[BankBranch_temp] ADD  CONSTRAINT [DF__BankBranc__Updat__09CA388A]  DEFAULT ('system') FOR [Update_user]
GO
ALTER TABLE [dbo].[BankBranch_temp] ADD  CONSTRAINT [DF__BankBranc__Creat__0ABE5CC3]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[BankBranch_temp] ADD  CONSTRAINT [DF__BankBranc__Creat__0BB280FC]  DEFAULT ('system') FOR [Create_user]
GO
ALTER TABLE [dbo].[BankBranch_temp] ADD  CONSTRAINT [DF__BankBranc__SysCr__0CA6A535]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
ALTER TABLE [dbo].[BankBranch_temp]  WITH CHECK ADD  CONSTRAINT [FK_BankBranch_temp_FlowForm] FOREIGN KEY([FlowFormId])
REFERENCES [dbo].[FlowForm] ([PK_Id])
GO
ALTER TABLE [dbo].[BankBranch_temp] CHECK CONSTRAINT [FK_BankBranch_temp_FlowForm]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'暫存資料識別碼（流水號）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankBranch_temp', @level2type=N'COLUMN',@level2name=N'TempId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'流程表單識別碼（外鍵：FlowForm.PK_ID）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankBranch_temp', @level2type=N'COLUMN',@level2name=N'FlowFormId'
GO
