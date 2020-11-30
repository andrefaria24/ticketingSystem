USE [superdesk]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER PROCEDURE [dbo].[createNewTicket]
	@userName varchar(50),
	@title varchar(50),
	@severityName varchar(50),
	@typeName varchar(50),
	@description varchar(250)
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO [tickets] (title, created, createdby, status, description, severity, type)
	VALUES (@title, (SELECT  GETDATE()), (SELECT id FROM [user] WHERE username = @userName), 1, @description, (SELECT id FROM [severity] WHERE name = @severityName), (SELECT id FROM [type] WHERE name = @typeName))
END
GO