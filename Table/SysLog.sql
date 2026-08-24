SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[SysLog](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[System_code] [varchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[EventName] [varchar](1000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[EventSql] [varchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[UserId] [varchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Prog_id] [varchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Function_code] [varchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Api_url] [varchar](500) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Sys_id] [varchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[CreateDate] [datetime] NULL,
	[Ip_address] [varchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Status_code] [int] NULL,
 CONSTRAINT [PK_sys_Log] PRIMARY KEY CLUSTERED
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
SET ANSI_PADDING OFF
GO
