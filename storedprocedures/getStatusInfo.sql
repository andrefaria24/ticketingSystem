USE [superdesk]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[getStatusInfo] @statusId int

AS
BEGIN
	SET NOCOUNT ON;

	SELECT [status].id, [status].name, [status].active
		FROM [status]
		WHERE [status].id = @statusId
END
GO