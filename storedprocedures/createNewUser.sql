SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].createNewUser
	@userName varchar(50),
	@email varchar(50),
	@firstName varchar(50),
	@lastName varchar(50),
	@phone varchar(50),
	@permissions varchar(50),
	@password varchar(250)
AS
BEGIN
	SET NOCOUNT ON;

    INSERT INTO [user] (username, password, email, firstname, lastname, phone, permissions, active)
	VALUES (@userName, @password, @email, @firstName, @lastName, @phone, (SELECT [permission].id FROM [permission] WHERE [permission].name = @permissions), 1)
END
GO