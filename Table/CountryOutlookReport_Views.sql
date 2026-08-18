SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CountryOutlookReport_Views](
	[PK_Id] [int] IDENTITY(1,1) NOT NULL,
	[FK_ReportId] [int] NOT NULL,
	[Views] [int] NOT NULL,
 CONSTRAINT [PK_CountryOutlookReport_Views] PRIMARY KEY CLUSTERED
(
	[PK_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
GO
ALTER TABLE [dbo].[CountryOutlookReport_Views] ADD  CONSTRAINT [DF_CountryOutlookReport_Views_Views]  DEFAULT ((0)) FOR [Views]
GO
ALTER TABLE [dbo].[CountryOutlookReport_Views]  WITH CHECK ADD  CONSTRAINT [FK_CountryOutlookReport_Views_CountryOutlookReport] FOREIGN KEY([FK_ReportId])
REFERENCES [dbo].[CountryOutlookReport] ([PK_Id])
GO
ALTER TABLE [dbo].[CountryOutlookReport_Views] CHECK CONSTRAINT [FK_CountryOutlookReport_Views_CountryOutlookReport]
GO
