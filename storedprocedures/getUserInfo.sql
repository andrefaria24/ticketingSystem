USE [superdesk]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[getUserInfo] @userId int

AS
BEGIN
	SET NOCOUNT ON;

	SELECT [user].id, [user].username, [user].email, [user].firstname, [user].lastname, [user].phone, permission.name, [user].active
		FROM [user]
		LEFT JOIN [permission] AS permission ON [user].permissions = [permission].id
		WHERE [user].id = @userId
END
