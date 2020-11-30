USE [superdesk]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER PROCEDURE [dbo].[updateTicketType]
	@ticketId int, 
	@typeName varchar(50)
AS
BEGIN
	SET NOCOUNT ON;

    UPDATE [tickets]
	SET [tickets].type = (SELECT id FROM type WHERE name = @typeName)
	FROM [tickets]
	LEFT JOIN [type] AS type ON [tickets].type = [type].id
	WHERE [tickets].id = @ticketId
END
GO

