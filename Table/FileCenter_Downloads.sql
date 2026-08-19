SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FileCenter_Downloads](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_FileId] [int] NOT NULL,
	[Downloads] [int] NOT NULL,
 CONSTRAINT [PK_FileCenter_Downloads] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
GO
ALTER TABLE [dbo].[FileCenter_Downloads] ADD  CONSTRAINT [DF_FileCenter_Downloads_Downloads]  DEFAULT ((0)) FOR [Downloads]
GO
ALTER TABLE [dbo].[FileCenter_Downloads]  WITH CHECK ADD  CONSTRAINT [FK_FileCenter_Downloads_FileCenter] FOREIGN KEY([FK_FileId])
REFERENCES [dbo].[FileCenter] ([PK_Id])
GO
ALTER TABLE [dbo].[FileCenter_Downloads] CHECK CONSTRAINT [FK_FileCenter_Downloads_FileCenter]
GO
