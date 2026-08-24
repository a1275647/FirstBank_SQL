SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[QuotaBank_D_temp](
	[TempId] [int] IDENTITY(1,1) NOT NULL,
	[FK_TempId] [int] NOT NULL,
	[ModifyType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[CountryId] [int] NOT NULL,
	[UnitCode] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[QuotaAmount] [int] NOT NULL,
	[Memo] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK__QuotaBan__06C703C10F79C68D] PRIMARY KEY CLUSTERED
(
	[TempId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[QuotaBank_D_temp] ADD  CONSTRAINT [DF__QuotaBank___Memo__6D4DF56D]  DEFAULT ('') FOR [Memo]
GO
ALTER TABLE [dbo].[QuotaBank_D_temp] ADD  CONSTRAINT [DF__QuotaBank__SysCr__702A6218]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
ALTER TABLE [dbo].[QuotaBank_D_temp]  WITH CHECK ADD  CONSTRAINT [FK_QuotaBank_D_temp_QuotaBank_M_temp] FOREIGN KEY([FK_TempId])
REFERENCES [dbo].[QuotaBank_M_temp] ([TempId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[QuotaBank_D_temp] CHECK CONSTRAINT [FK_QuotaBank_D_temp_QuotaBank_M_temp]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'暫存資料識別碼（流水號）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QuotaBank_D_temp', @level2type=N'COLUMN',@level2name=N'TempId'
GO
