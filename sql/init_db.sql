-- Initialization script for Monitoreo Infantil demo
-- Creates database `monitoreo`, table `personas` and inserts a sample row.

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'monitoreo')
BEGIN
    CREATE DATABASE monitoreo;
END
GO

USE monitoreo;
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[personas]') AND type in (N'U'))
BEGIN
    CREATE TABLE dbo.personas (
        id_number NVARCHAR(50) PRIMARY KEY,
        nombre NVARCHAR(100),
        apellido NVARCHAR(100),
        fecha_nacimiento DATE
    );
END
GO

-- Insert sample data if not exists
IF NOT EXISTS (SELECT 1 FROM dbo.personas WHERE id_number = '1023344558')
BEGIN
    INSERT INTO dbo.personas (id_number, nombre, apellido, fecha_nacimiento) VALUES ('1023344558','Julian','Coronado','2010-05-12');
END
GO
