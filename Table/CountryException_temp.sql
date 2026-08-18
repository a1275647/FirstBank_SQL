SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CountryException_temp](
	[TempId] [int] IDENTITY(1,1) NOT NULL,
	[FlowFormId] [int] NULL,
	[ModifyType] [nvarchar](10) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[PK_Id] [int] NOT NULL,
	[FK_CountryId] [int] NULL,
	[IsException] [bit] NOT NULL,
	[ExceptionExplain] [nvarchar](255) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL,
	[Approval_date] [date] NULL,
	[SysCreateDate] [datetime] NOT NULL,
	[SysCreateUser] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_CountryException_temp] PRIMARY KEY CLUSTERED
(
	[TempId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
GO
ALTER TABLE [dbo].[CountryException_temp] ADD  CONSTRAINT [DF_CountryException_temp_SysCreateDate]  DEFAULT (getdate()) FOR [SysCreateDate]
GO
ALTER TABLE [dbo].[CountryException_temp]  WITH CHECK ADD  CONSTRAINT [FK_CountryException_temp_FlowForm] FOREIGN KEY([FlowFormId])
REFERENCES [dbo].[FlowForm] ([PK_Id])
GO
ALTER TABLE [dbo].[CountryException_temp] CHECK CONSTRAINT [FK_CountryException_temp_FlowForm]
GO
