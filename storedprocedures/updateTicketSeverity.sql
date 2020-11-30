USE [superdesk]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[updateTicketSeverity]
	@ticketId int, 
	@severityName varchar(50)
AS
BEGIN

	SET NOCOUNT ON;

	UPDATE [tickets]
	SET [tickets].severity = (SELECT id FROM severity WHERE name = @severityName)
	FROM [tickets]
	LEFT JOIN [severity] AS severity ON [tickets].severity = [severity].id
	WHERE [tickets].id = @ticketId
END
