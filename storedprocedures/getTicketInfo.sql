USE [superdesk]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[getTicketInfo] @ticketId int

AS
BEGIN
	SET NOCOUNT ON;

	SELECT [tickets].id, [tickets].title, [tickets].created, [tickets].updated, createdby.username, updatedby.username, status.name, [tickets].description, severity.name, type.name
		FROM [tickets]
		LEFT JOIN [user] AS createdby ON [tickets].createdby = createdby.id
		LEFT JOIN [user] AS updatedby ON [tickets].updatedby = updatedby.id
		LEFT JOIN [status] AS status ON [tickets].status = [status].id
		LEFT JOIN [severity] AS severity ON [tickets].severity = [severity].id
		LEFT JOIN [type] AS type ON [tickets].type = [type].id
		WHERE [tickets].id = @ticketId
END
GO