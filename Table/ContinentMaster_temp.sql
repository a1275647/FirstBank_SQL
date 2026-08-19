SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ContinentMaster_temp](
	[TempId] [int] IDENTITY(1,1) NOT NULL,
	[FlowFormId] [int] NULL,
	[ModifyType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[PK_Id] [int] NOT NULL,
	[ContinentCode] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[ContinentName_TN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[ContinentName_EN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[ContinentName_CN] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[ContinentName_JP] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[IsActive] [bit] NOT NULL,
	[IsContinent] [bit] NOT NULL,
	[seq] [int] NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](100) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK__Continen__06C703C1D3342835] PRIMARY KEY CLUSTERED
(
	[TempId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
GO
ALTER TABLE [dbo].[ContinentMaster_temp] ADD  CONSTRAINT [DF__Continent__Conti__7B3C2211]  DEFAULT ('') FOR [ContinentCode]
GO
ALTER TABLE [dbo].[ContinentMaster_temp] ADD  CONSTRAINT [DF__Continent__Conti__7C30464A]  DEFAULT ('') FOR [ContinentName_TN]
GO
ALTER TABLE [dbo].[ContinentMaster_temp] ADD  CONSTRAINT [DF__Continent__Conti__7D246A83]  DEFAULT ('') FOR [ContinentName_EN]
GO
ALTER TABLE [dbo].[ContinentMaster_temp] ADD  CONSTRAINT [DF__Continent__Conti__7E188EBC]  DEFAULT ('') FOR [ContinentName_CN]
GO
ALTER TABLE [dbo].[ContinentMaster_temp] ADD  CONSTRAINT [DF__Continent__Conti__7F0CB2F5]  DEFAULT ('') FOR [ContinentName_JP]
GO
ALTER TABLE [dbo].[ContinentMaster_temp] ADD  CONSTRAINT [DF__Continent__IsAct__0000D72E]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[ContinentMaster_temp] ADD  CONSTRAINT [DF__Continent__IsCon__00F4FB67]  DEFAULT ((0)) FOR [IsContinent]
GO
ALTER TABLE [dbo].[ContinentMaster_temp] ADD  CONSTRAINT [DF__ContinentMa__seq__01E91FA0]  DEFAULT ((1)) FOR [seq]
GO
ALTER TABLE [dbo].[ContinentMaster_temp] ADD  CONSTRAINT [DF__Continent__Updat__02DD43D9]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[ContinentMaster_temp] ADD  CONSTRAINT [DF__Continent__Updat__03D16812]  DEFAULT ('') FOR [Update_user]
GO
ALTER TABLE [dbo].[ContinentMaster_temp] ADD  CONSTRAINT [DF__Continent__Creat__04C58C4B]  DEFAULT ('') FOR [Create_user]
GO
ALTER TABLE [dbo].[ContinentMaster_temp] ADD  CONSTRAINT [DF__Continent__Creat__05B9B084]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[ContinentMaster_temp] ADD  CONSTRAINT [DF__Continent__SysCr__06ADD4BD]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
ALTER TABLE [dbo].[ContinentMaster_temp]  WITH CHECK ADD  CONSTRAINT [FK_ContinentMaster_temp_FlowForm] FOREIGN KEY([FlowFormId])
REFERENCES [dbo].[FlowForm] ([PK_Id])
GO
ALTER TABLE [dbo].[ContinentMaster_temp] CHECK CONSTRAINT [FK_ContinentMaster_temp_FlowForm]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'暫存資料識別碼（流水號）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ContinentMaster_temp', @level2type=N'COLUMN',@level2name=N'TempId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'流程表單識別碼（外鍵：FlowForm.PK_ID）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ContinentMaster_temp', @level2type=N'COLUMN',@level2name=N'FlowFormId'
GO
