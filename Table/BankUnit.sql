SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BankUnit](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_BankGroup] [int] NOT NULL,
	[UnitCode] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[UnitName_EN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[UnitName_TN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[UnitName_CN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[UnitName_JP] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[IsMain] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[IsBusinessUnit] [bit] NULL,
	[IsSave] [bit] NOT NULL,
	[Memo] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[IsEmployed] [bit] NOT NULL,
	[Seq] [int] NOT NULL,
 CONSTRAINT [PK_BankUnit] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB],
 CONSTRAINT [UQ__BankUnit__0665E6D9CD3FA132] UNIQUE NONCLUSTERED
(
	[UnitCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_IDX]
) ON [NCRMS_TAB]
GO
ALTER TABLE [dbo].[BankUnit] ADD  CONSTRAINT [DF_BankUnit_FK_BankGroup]  DEFAULT ('') FOR [FK_BankGroup]
GO
ALTER TABLE [dbo].[BankUnit] ADD  CONSTRAINT [DF_BankUnit_UnitCode]  DEFAULT ('') FOR [UnitCode]
GO
ALTER TABLE [dbo].[BankUnit] ADD  CONSTRAINT [DF_BankUnit_Name_EN]  DEFAULT ('') FOR [UnitName_EN]
GO
ALTER TABLE [dbo].[BankUnit] ADD  CONSTRAINT [DF_BankUnit_Name_TN]  DEFAULT ('') FOR [UnitName_TN]
GO
ALTER TABLE [dbo].[BankUnit] ADD  CONSTRAINT [DF_BankUnit_Name_CN]  DEFAULT ('') FOR [UnitName_CN]
GO
ALTER TABLE [dbo].[BankUnit] ADD  CONSTRAINT [DF_BankUnit_Name_JP]  DEFAULT ('') FOR [UnitName_JP]
GO
ALTER TABLE [dbo].[BankUnit] ADD  CONSTRAINT [DF_BankUnit_IsMain]  DEFAULT ((0)) FOR [IsMain]
GO
ALTER TABLE [dbo].[BankUnit] ADD  CONSTRAINT [DF_BankUnit_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[BankUnit] ADD  CONSTRAINT [DF_BankUnit_IsSave]  DEFAULT ((0)) FOR [IsSave]
GO
ALTER TABLE [dbo].[BankUnit] ADD  CONSTRAINT [DF_BankUnit_Memo]  DEFAULT ('') FOR [Memo]
GO
ALTER TABLE [dbo].[BankUnit] ADD  CONSTRAINT [DF_BankUnit_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[BankUnit] ADD  CONSTRAINT [DF_BankUnit_Update_user]  DEFAULT ('system') FOR [Update_user]
GO
ALTER TABLE [dbo].[BankUnit] ADD  CONSTRAINT [DF_BankUnit_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[BankUnit] ADD  CONSTRAINT [DF_BankUnit_Create_user]  DEFAULT ('system') FOR [Create_user]
GO
ALTER TABLE [dbo].[BankUnit] ADD  CONSTRAINT [DF__BankUnit__IsEmpl__326239C9]  DEFAULT ((1)) FOR [IsEmployed]
GO
ALTER TABLE [dbo].[BankUnit] ADD  CONSTRAINT [DF_BankUnit_Seq]  DEFAULT ((99)) FOR [Seq]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'事業群關聯用' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankUnit', @level2type=N'COLUMN',@level2name=N'FK_BankGroup'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'處代碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankUnit', @level2type=N'COLUMN',@level2name=N'UnitCode'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'英' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankUnit', @level2type=N'COLUMN',@level2name=N'UnitName_EN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'繁中' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankUnit', @level2type=N'COLUMN',@level2name=N'UnitName_TN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'簡中' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankUnit', @level2type=N'COLUMN',@level2name=N'UnitName_CN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'日' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankUnit', @level2type=N'COLUMN',@level2name=N'UnitName_JP'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'事業群主要業管處' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankUnit', @level2type=N'COLUMN',@level2name=N'IsMain'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'是否啟用' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankUnit', @level2type=N'COLUMN',@level2name=N'IsActive'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'是否為業務單位' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankUnit', @level2type=N'COLUMN',@level2name=N'IsBusinessUnit'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'是否為保留額度' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankUnit', @level2type=N'COLUMN',@level2name=N'IsSave'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'更新時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankUnit', @level2type=N'COLUMN',@level2name=N'Update_date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'更新者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankUnit', @level2type=N'COLUMN',@level2name=N'Update_user'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建置時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankUnit', @level2type=N'COLUMN',@level2name=N'Create_date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建置者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BankUnit', @level2type=N'COLUMN',@level2name=N'Create_user'
GO
