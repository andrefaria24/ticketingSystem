USE [superdesk]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[createNewTicketSev]
	@sevname varchar(50)
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO [severity] (name, active)
	VALUES (@sevname, 1)
END
GO