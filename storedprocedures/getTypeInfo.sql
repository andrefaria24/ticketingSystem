USE [superdesk]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[getTypeInfo] @typeId int

AS
BEGIN
	SET NOCOUNT ON;

	SELECT [type].id, [type].name, [type].active
		FROM [type]
		WHERE [type].id = @typeId
END
GO