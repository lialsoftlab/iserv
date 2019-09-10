USE [master]
GO

IF (SELECT COUNT([name]) FROM sys.databases WHERE [name] = 'lial_dbistt_3213E83F5A5938281') = 1 BEGIN
	DROP DATABASE [lial_dbistt_3213E83F5A5938281];
END
GO 

CREATE DATABASE [lial_dbistt_3213E83F5A5938281];
GO 

USE [lial_dbistt_3213E83F5A5938281];
GO

CREATE TABLE [dbo].[AccPoint] (
	[id]   [bigint]        NOT NULL IDENTITY (1,1)
	,[code] [varchar](50)   NOT NULL
	,[name] [nvarchar](max) NOT NULL 

	,CONSTRAINT [PK__AccPoint] PRIMARY KEY CLUSTERED ([id])
)
GO

CREATE TABLE [dbo].[NetElem] (
	[id]   [bigint]        NOT NULL IDENTITY (1,1)
	,[code] [varchar](50)   NOT NULL 
	,[name] [nvarchar](max) NOT NULL 

	,CONSTRAINT [PK__NetElem] PRIMARY KEY CLUSTERED ([id])
)
GO

CREATE TABLE [dbo].[AccPoint2NetElementLink] (
	[accpoint_id] [bigint] NOT NULL   
	,[netelem_id]  [bigint] NOT NULL   

	,CONSTRAINT [UQ__AccPoint2NetElementLink_AccPoint] UNIQUE NONCLUSTERED ([accpoint_id])
	,CONSTRAINT [UQ__AccPoint2NetElementLink_NetElem] UNIQUE NONCLUSTERED ([netelem_id])
);
GO
	
ALTER TABLE [dbo].[AccPoint2NetElementLink] WITH CHECK 
	ADD CONSTRAINT [FK_AccPoint2NetElementLink_AccPoint]
		FOREIGN KEY([accpoint_id]) REFERENCES [dbo].[AccPoint] ([id]);
GO

ALTER TABLE [dbo].[AccPoint2NetElementLink] WITH CHECK 
	ADD CONSTRAINT [FK_AccPoint2NetElementLink_NetElem]
		FOREIGN KEY([netelem_id]) REFERENCES [dbo].[NetElem] ([id]);
GO

CREATE TABLE [dbo].[AccPointStatus] (
	[id]          [bigint] NOT NULL IDENTITY (1,1)
	,[accpoint_id] [bigint] NOT NULL
	,[date]        [date]   NOT NULL
	,[status]      [bit]    NOT NULL   

	,CONSTRAINT [PK_AccPointStatus] PRIMARY KEY CLUSTERED ([date], [accpoint_id], [id])
);
GO

ALTER TABLE [dbo].[AccPointStatus] WITH CHECK 
	ADD CONSTRAINT [FK_AccPointStatus_AccPoint]
		FOREIGN KEY([accpoint_id]) REFERENCES [dbo].[AccPoint] ([id]);
GO

CREATE TABLE [dbo].[NetElemStatus] (
	[id]         [bigint] NOT NULL  IDENTITY (1,1)
	,[netelem_id] [bigint] NOT NULL
	,[date]       [date]   NOT NULL
	,[status]     [bit]    NOT NULL   

	,CONSTRAINT [PK__NetElemStatus] PRIMARY KEY CLUSTERED ([date], [netelem_id], [id])
);
GO
	
ALTER TABLE [dbo].[NetElemStatus] WITH CHECK 
	ADD CONSTRAINT [FK_NetElemStatus_NetElem]
		FOREIGN KEY([netelem_id]) REFERENCES [dbo].[NetElem] ([id]);
GO


