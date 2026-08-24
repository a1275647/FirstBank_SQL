SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Resolve optional named filegroups at execution time; PRIMARY is the portable fallback.
DECLARE @FilegroupSql nvarchar(max) = N'';
SET @FilegroupSql += N'CREATE TABLE [dbo].[RPA_temp](
	[TempId] [int] IDENTITY(1,1) NOT NULL,
	[FlowFormId] [int] NULL,
	[ModifyType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[PK_Id] [int] NOT NULL,
	[FK_NewsPostId] [int] NULL,
	[Type] [int] NOT NULL,
	[Title] [nvarchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Contents] [nvarchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Url] [nvarchar](2000) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[IsActive] [bit] NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Release_date] [date] NULL,
 CONSTRAINT [PK__NewsPost__06C703C16ED4FA98] PRIMARY KEY CLUSTERED
(
	[TempId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]';
IF FILEGROUP_ID(N'NCRMS_TAB') IS NULL
    SET @FilegroupSql = REPLACE(@FilegroupSql, N'[NCRMS_TAB]', N'[PRIMARY]');
EXEC sys.sp_executesql @FilegroupSql;
GO
ALTER TABLE [dbo].[RPA_temp] ADD  CONSTRAINT [DF_RPA_temp_Url]  DEFAULT ('') FOR [Url]
GO
ALTER TABLE [dbo].[RPA_temp] ADD  CONSTRAINT [DF__NewsPost___Updat__4CD638E3]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[RPA_temp] ADD  CONSTRAINT [DF__NewsPost___Creat__4DCA5D1C]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[RPA_temp] ADD  CONSTRAINT [DF__NewsPost___SysCr__4EBE8155]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
ALTER TABLE [dbo].[RPA_temp]  WITH CHECK ADD  CONSTRAINT [FK_NewsPost_temp_FlowForm] FOREIGN KEY([FlowFormId])
REFERENCES [dbo].[FlowForm] ([PK_Id])
GO
ALTER TABLE [dbo].[RPA_temp] CHECK CONSTRAINT [FK_NewsPost_temp_FlowForm]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'暫存資料識別碼（流水號）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RPA_temp', @level2type=N'COLUMN',@level2name=N'TempId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'流程表單識別碼（外鍵：FlowForm.PK_ID）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RPA_temp', @level2type=N'COLUMN',@level2name=N'FlowFormId'
GO
