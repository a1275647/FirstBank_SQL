SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[GroupIdCounter](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[GroupName] [nvarchar](50) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
	[GroupCount] [int] NOT NULL,
	[Create_date] [datetime] NOT NULL,
	[Create_user] [nvarchar](8) COLLATE Chinese_Taiwan_Stroke_CI_AS NOT NULL,
 CONSTRAINT [PK_GroupIdCounter] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
GO
ALTER TABLE [dbo].[GroupIdCounter] ADD  CONSTRAINT [DF_GroupIdCounter_GroupCount]  DEFAULT ((0)) FOR [GroupCount]
GO
ALTER TABLE [dbo].[GroupIdCounter] ADD  CONSTRAINT [DF_GroupIdCounter_Create_date]  DEFAULT (getdate()) FOR [Create_date]
GO
