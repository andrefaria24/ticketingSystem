USE [superdesk]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[createNewTicketType]
	@typename varchar(50)
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO [type] (name, active)
	VALUES (@typename, 1)
END
GO