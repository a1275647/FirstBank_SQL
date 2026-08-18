SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[m_parameter](
	[system_code] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[field_code] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[field_name] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[field1] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[field2] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[field3] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[field4] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[field5] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[field6] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[field7] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Update_date] [datetime] NOT NULL,
	[Update_user] [nvarchar](20) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[Memo] [nvarchar](200) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_m_parameter] PRIMARY KEY CLUSTERED
(
	[system_code] ASC,
	[field_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
GO
ALTER TABLE [dbo].[m_parameter] ADD  CONSTRAINT [DF_m_parameter_field_name]  DEFAULT ('') FOR [field_name]
GO
ALTER TABLE [dbo].[m_parameter] ADD  CONSTRAINT [DF_m_parameter_field1]  DEFAULT ('') FOR [field1]
GO
ALTER TABLE [dbo].[m_parameter] ADD  CONSTRAINT [DF_m_parameter_field2]  DEFAULT ('') FOR [field2]
GO
ALTER TABLE [dbo].[m_parameter] ADD  CONSTRAINT [DF_m_parameter_field3]  DEFAULT ('') FOR [field3]
GO
ALTER TABLE [dbo].[m_parameter] ADD  CONSTRAINT [DF_m_parameter_field4]  DEFAULT ('') FOR [field4]
GO
ALTER TABLE [dbo].[m_parameter] ADD  CONSTRAINT [DF_m_parameter_field5]  DEFAULT ('') FOR [field5]
GO
ALTER TABLE [dbo].[m_parameter] ADD  CONSTRAINT [DF_m_parameter_field6]  DEFAULT ('') FOR [field6]
GO
ALTER TABLE [dbo].[m_parameter] ADD  CONSTRAINT [DF_m_parameter_field7]  DEFAULT ('') FOR [field7]
GO
ALTER TABLE [dbo].[m_parameter] ADD  CONSTRAINT [DF_m_parameter_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
ALTER TABLE [dbo].[m_parameter] ADD  CONSTRAINT [DF_m_parameter_Create_user]  DEFAULT ('') FOR [Create_user]
GO
ALTER TABLE [dbo].[m_parameter] ADD  CONSTRAINT [DF_m_parameter_Update_date]  DEFAULT (getdate()) FOR [Update_date]
GO
ALTER TABLE [dbo].[m_parameter] ADD  CONSTRAINT [DF_m_parameter_Update_user]  DEFAULT ('') FOR [Update_user]
GO
ALTER TABLE [dbo].[m_parameter] ADD  CONSTRAINT [DF_m_parameter_Memo]  DEFAULT ('') FOR [Memo]
GO
