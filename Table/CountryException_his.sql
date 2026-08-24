SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[CountryException_his](
	[Log_Id] [int] IDENTITY(1,1) NOT NULL,
	[FlowFormId] [int] NOT NULL,
	[LogType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[PK_Id] [int] NOT NULL,
	[FK_CountryId] [int] NULL,
	[CountryName_TN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CountryName_CN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CountryName_EN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CountryName_JP] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CountryCode2] [nvarchar](2) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[IsException] [bit] NOT NULL,
	[ExceptionExplain] [nvarchar](255) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Approval_date] [date] NULL,
	[Update_user] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_CountryException_his] PRIMARY KEY CLUSTERED
(
	[Log_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[CountryException_his] ADD  CONSTRAINT [DF_CountryException_his_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[CountryException_his] ADD  CONSTRAINT [DF_CountryException_his_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[CountryException_his] ADD  CONSTRAINT [DF_CountryException_his_SysCreateDate]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
