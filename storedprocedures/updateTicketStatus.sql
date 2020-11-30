USE [superdesk]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[updateTicketStatus]
	@ticketId int, 
	@statusName varchar(50)
AS
BEGIN
	SET NOCOUNT ON;

    UPDATE [tickets]
	SET [tickets].status = (SELECT id FROM status WHERE name = @statusName)
	FROM [tickets]
	LEFT JOIN [status] AS status ON [tickets].status = [status].id
	WHERE [tickets].id = @ticketId
END
GO

