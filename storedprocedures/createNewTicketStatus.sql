USE [superdesk]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[createNewTicketStatus]
	@statusname varchar(50)
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO [status] (name, active)
	VALUES (@statusname, 1)
END
GO