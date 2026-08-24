SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[QuotaBank_M](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[CountryId] [int] NOT NULL,
	[ApprovedAmount] [int] NOT NULL,
	[TotalUtilizedAmount] [int] NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
 CONSTRAINT [PK_QuotaBank] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[QuotaBank_M] ADD  CONSTRAINT [DF_QuotaBank_M_TotalUtilizedAmount]  DEFAULT ((0)) FOR [TotalUtilizedAmount]
GO
ALTER TABLE [dbo].[QuotaBank_M] ADD  CONSTRAINT [DF_QuotaBank_M_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[QuotaBank_M] ADD  CONSTRAINT [DF_QuotaBank_M_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'國家代碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QuotaBank_M', @level2type=N'COLUMN',@level2name=N'CountryId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'授權額度' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QuotaBank_M', @level2type=N'COLUMN',@level2name=N'ApprovedAmount'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'總分配額度' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QuotaBank_M', @level2type=N'COLUMN',@level2name=N'TotalUtilizedAmount'
GO
