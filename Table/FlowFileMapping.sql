SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FlowFileMapping](
	[PK_ID] [int] IDENTITY(1,1) NOT NULL,
	[FlowRecordId] [int] NOT NULL,
	[FileCenterId] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK__Flow_att__F4A24BC22201BC54] PRIMARY KEY CLUSTERED
(
	[PK_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [NCRMS_TAB]
) ON [NCRMS_TAB]
GO
ALTER TABLE [dbo].[FlowFileMapping] ADD  CONSTRAINT [DF_FlowFileMapping_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[FlowFileMapping]  WITH CHECK ADD  CONSTRAINT [FK_FlowFileMapping_FileCenter] FOREIGN KEY([FileCenterId])
REFERENCES [dbo].[FileCenter] ([PK_Id])
GO
ALTER TABLE [dbo].[FlowFileMapping] CHECK CONSTRAINT [FK_FlowFileMapping_FileCenter]
GO
ALTER TABLE [dbo].[FlowFileMapping]  WITH CHECK ADD  CONSTRAINT [FK_FlowFileMapping_FlowRecord] FOREIGN KEY([FlowRecordId])
REFERENCES [dbo].[FlowRecord] ([PK_id])
GO
ALTER TABLE [dbo].[FlowFileMapping] CHECK CONSTRAINT [FK_FlowFileMapping_FlowRecord]
GO
