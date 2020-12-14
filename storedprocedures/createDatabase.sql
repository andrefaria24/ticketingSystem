USE [master]
GO
/****** CREATE BASELINE DATABASE ******/
CREATE DATABASE [superdesk]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'superdesk', FILENAME = N'/var/opt/mssql/data/superdesk.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'superdesk_log', FILENAME = N'/var/opt/mssql/data/superdesk_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
GO
ALTER DATABASE [superdesk] SET COMPATIBILITY_LEVEL = 140
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [superdesk].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [superdesk] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [superdesk] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [superdesk] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [superdesk] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [superdesk] SET ARITHABORT OFF 
GO
ALTER DATABASE [superdesk] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [superdesk] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [superdesk] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [superdesk] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [superdesk] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [superdesk] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [superdesk] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [superdesk] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [superdesk] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [superdesk] SET  DISABLE_BROKER 
GO
ALTER DATABASE [superdesk] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [superdesk] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [superdesk] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [superdesk] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [superdesk] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [superdesk] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [superdesk] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [superdesk] SET RECOVERY FULL 
GO
ALTER DATABASE [superdesk] SET  MULTI_USER 
GO
ALTER DATABASE [superdesk] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [superdesk] SET DB_CHAINING OFF 
GO
ALTER DATABASE [superdesk] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [superdesk] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [superdesk] SET DELAYED_DURABILITY = DISABLED 
GO
EXEC sys.sp_db_vardecimal_storage_format N'superdesk', N'ON'
GO
ALTER DATABASE [superdesk] SET QUERY_STORE = OFF
GO
/****** END CREATE BASELINE DATABASE ******/

/****** CREATE SUPERDESK USER AND ASSIGN REQUIRED ROLES ******/
USE [superdesk]
GO
CREATE USER [superdesk] FOR LOGIN [superdesk] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_accessadmin] ADD MEMBER [superdesk]
GO
ALTER ROLE [db_securityadmin] ADD MEMBER [superdesk]
GO
ALTER ROLE [db_datareader] ADD MEMBER [superdesk]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [superdesk]
GO
GRANT EXECUTE TO [superdesk]
GO
/****** END CREATE SUPERDESK USER AND ASSIGN REQUIRED ROLES ******/

/****** CREATE TABLES ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[permission](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](50) NOT NULL,
	[active] [bit] NULL,
 CONSTRAINT [PK_permission] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[severity](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](50) NOT NULL,
	[active] [bit] NULL,
 CONSTRAINT [PK_severity] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[status](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](50) NOT NULL,
	[active] [bit] NULL,
 CONSTRAINT [PK_status] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tickets](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[title] [varchar](50) NOT NULL,
	[created] [datetime] NOT NULL,
	[updated] [datetime] NULL,
	[createdby] [int] NOT NULL,
	[updatedby] [int] NULL,
	[status] [int] NOT NULL,
	[description] [varchar](max) NULL,
	[severity] [int] NOT NULL,
	[type] [int] NOT NULL,
 CONSTRAINT [PK_tickets] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[type](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](50) NOT NULL,
	[active] [bit] NULL,
 CONSTRAINT [PK_type] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[user](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[username] [varchar](50) NOT NULL,
	[password] [varchar](250) NOT NULL,
	[email] [varchar](50) NOT NULL,
	[firstname] [varchar](50) NULL,
	[lastname] [varchar](50) NULL,
	[phone] [varchar](50) NULL,
	[permissions] [int] NOT NULL,
	[active] [bit] NULL,
 CONSTRAINT [PK_user] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tickets]  WITH CHECK ADD  CONSTRAINT [FK_tickets_createdby] FOREIGN KEY([createdby])
REFERENCES [dbo].[user] ([id])
GO
ALTER TABLE [dbo].[tickets] CHECK CONSTRAINT [FK_tickets_createdby]
GO
ALTER TABLE [dbo].[tickets]  WITH CHECK ADD  CONSTRAINT [FK_tickets_severity] FOREIGN KEY([severity])
REFERENCES [dbo].[severity] ([id])
GO
ALTER TABLE [dbo].[tickets] CHECK CONSTRAINT [FK_tickets_severity]
GO
ALTER TABLE [dbo].[tickets]  WITH CHECK ADD  CONSTRAINT [FK_tickets_status] FOREIGN KEY([status])
REFERENCES [dbo].[status] ([id])
GO
ALTER TABLE [dbo].[tickets] CHECK CONSTRAINT [FK_tickets_status]
GO
ALTER TABLE [dbo].[tickets]  WITH CHECK ADD  CONSTRAINT [FK_tickets_type] FOREIGN KEY([type])
REFERENCES [dbo].[type] ([id])
GO
ALTER TABLE [dbo].[tickets] CHECK CONSTRAINT [FK_tickets_type]
GO
ALTER TABLE [dbo].[tickets]  WITH CHECK ADD  CONSTRAINT [FK_tickets_updatedby] FOREIGN KEY([updatedby])
REFERENCES [dbo].[user] ([id])
GO
ALTER TABLE [dbo].[tickets] CHECK CONSTRAINT [FK_tickets_updatedby]
GO
ALTER TABLE [dbo].[user]  WITH CHECK ADD  CONSTRAINT [FK_user_permission] FOREIGN KEY([permissions])
REFERENCES [dbo].[permission] ([id])
GO
ALTER TABLE [dbo].[user] CHECK CONSTRAINT [FK_user_permission]
GO
/****** END CREATE TABLES ******/

/****** CREATE STORED PROCEDURES ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[createNewTicket]
	@userName varchar(50),
	@title varchar(50),
	@severityName varchar(50),
	@typeName varchar(50),
	@description varchar(250)
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO [tickets] (title, created, createdby, status, description, severity, type)
	VALUES (@title, (SELECT  GETDATE()), (SELECT id FROM [user] WHERE username = @userName), 1, @description, (SELECT id FROM [severity] WHERE name = @severityName), (SELECT id FROM [type] WHERE name = @typeName))
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[createNewTicketType]
	@typename varchar(50)
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO [type] (name)
	VALUES (@typename)
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[getAllTickets]

AS
BEGIN
	SET NOCOUNT ON;

	SELECT [tickets].id, [tickets].title, [tickets].created, [tickets].updated, createdby.username, updatedby.username, status.name, [tickets].description, severity.name, type.name
		FROM [tickets]
		LEFT JOIN [user] AS createdby ON [tickets].createdby = createdby.id
		LEFT JOIN [user] AS updatedby ON [tickets].updatedby = updatedby.id
		LEFT JOIN [status] AS status ON [tickets].status = [status].id
		LEFT JOIN [severity] AS severity ON [tickets].severity = [severity].id
		LEFT JOIN [type] AS type ON [tickets].type = [type].id
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[getMyOpenTickets] @userId int

AS
BEGIN
	SET NOCOUNT ON;

	SELECT [tickets].id, [tickets].title, [tickets].created, [tickets].updated, createdby.username, updatedby.username, status.name, [tickets].description, severity.name, type.name
		FROM [tickets]
		LEFT JOIN [user] AS createdby ON [tickets].createdby = createdby.id
		LEFT JOIN [user] AS updatedby ON [tickets].updatedby = updatedby.id
		LEFT JOIN [status] AS status ON [tickets].status = [status].id
		LEFT JOIN [severity] AS severity ON [tickets].severity = [severity].id
		LEFT JOIN [type] AS type ON [tickets].type = [type].id
		WHERE createdby = @userId
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[getTicketInfo] @ticketId int

AS
BEGIN
	SET NOCOUNT ON;

	SELECT [tickets].id, [tickets].title, [tickets].created, [tickets].updated, createdby.username, updatedby.username, status.name, [tickets].description, severity.name, type.name
		FROM [tickets]
		LEFT JOIN [user] AS createdby ON [tickets].createdby = createdby.id
		LEFT JOIN [user] AS updatedby ON [tickets].updatedby = updatedby.id
		LEFT JOIN [status] AS status ON [tickets].status = [status].id
		LEFT JOIN [severity] AS severity ON [tickets].severity = [severity].id
		LEFT JOIN [type] AS type ON [tickets].type = [type].id
		WHERE [tickets].id = @ticketId
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[getUserInfo] @userId int

AS
BEGIN
	SET NOCOUNT ON;

	SELECT [user].id, [user].username, [user].email, [user].firstname, [user].lastname, [user].phone, permission.name, [user].active
		FROM [user]
		LEFT JOIN [permission] AS permission ON [user].permissions = [permission].id
		WHERE [user].id = @userId
END
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

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[updateTicketSeverity]
	@ticketId int, 
	@severityName varchar(50)
AS
BEGIN

	SET NOCOUNT ON;

	UPDATE [tickets]
	SET [tickets].severity = (SELECT id FROM severity WHERE name = @severityName)
	FROM [tickets]
	LEFT JOIN [severity] AS severity ON [tickets].severity = [severity].id
	WHERE [tickets].id = @ticketId
END
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

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[updateTicketType]
	@ticketId int, 
	@typeName varchar(50)
AS
BEGIN
	SET NOCOUNT ON;

    UPDATE [tickets]
	SET [tickets].type = (SELECT id FROM type WHERE name = @typeName)
	FROM [tickets]
	LEFT JOIN [type] AS type ON [tickets].type = [type].id
	WHERE [tickets].id = @ticketId
END
GO
/****** END CREATE STORED PROCEDURES ******/

/****** INSERT DEFAULT VALUES ******/
INSERT INTO [permission] (name)
VALUES ('Admin'), ('Helpdesk'), ('Customer')
GO

INSERT INTO [severity] (name)
VALUES ('Emergency'), ('High'), ('Medium'), ('Low')
GO

INSERT INTO [status] (name)
VALUES ('Open'), ('Pending'), ('Closed')
GO

INSERT INTO [type] (name)
VALUES ('General')
GO

INSERT INTO [user] (username, password, firstname, lastname, email, permissions, active)
VALUES ('admin', 'gAAAAABfyaAiCsft450tsxq-lXW15Gz1D9UaZLWkiYycZlzC6sjw3HLCJnJyvHraGrf4sfMlNWk9yFyIZRG_EjSnP0XnF_Sl9A==', 'Super', 'Admin', 'admin@superdesk.com', 1, 1)
GO
/****** END INSERT DEFAULT VALUES ******/

/****** SET DATABASE TO READWRITE MODE ******/
USE [master]
GO
ALTER DATABASE [superdesk] SET  READ_WRITE 
GO
/****** END SET DATABASE TO READWRITE MODE ******/