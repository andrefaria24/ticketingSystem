USE [superdesk]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[getAllTickets]

AS
BEGIN
	SET NOCOUNT ON;

	SELECT [tickets].id, [tickets].title, FORMAT([tickets].created, 'dd/MM/yyyy HH:mm:ss') AS created, FORMAT([tickets].updated, 'dd/MM/yyyy HH:mm:ss') AS updated, createdby.username AS createdby, updatedby.username AS updatedby, status.name AS status, [tickets].description, severity.name AS severity, type.name AS type
		FROM [tickets]
		LEFT JOIN [user] AS createdby ON [tickets].createdby = createdby.id
		LEFT JOIN [user] AS updatedby ON [tickets].updatedby = updatedby.id
		LEFT JOIN [status] AS status ON [tickets].status = [status].id
		LEFT JOIN [severity] AS severity ON [tickets].severity = [severity].id
		LEFT JOIN [type] AS type ON [tickets].type = [type].id
END