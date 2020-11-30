USE [superdesk]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[updateTicketBy]
	@ticketId int,
	@userName varchar(50)
AS
BEGIN
	SET NOCOUNT ON;

    UPDATE [tickets]
	SET [tickets].updatedby = (SELECT id FROM [user] WHERE username = @userName)
	FROM [tickets]
	WHERE [tickets].id = @ticketId

	UPDATE [tickets]
	SET [tickets].updated = (SELECT  GETDATE())
	FROM [tickets]
	WHERE [tickets].id = @ticketId
END
GO