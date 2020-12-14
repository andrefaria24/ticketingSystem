USE [superdesk]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[getSevInfo] @sevId int

AS
BEGIN
	SET NOCOUNT ON;

	SELECT [severity].id, [severity].name, [severity].active
		FROM [severity]
		WHERE [severity].id = @sevId
END
GO