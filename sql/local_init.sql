-- Script to initialize local SQL Server database and sample data for Monitoreo Infantil
-- Run this in SSMS or with sqlcmd against your instance (e.g., localhost\SQLEXPRESS01)

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'monitoreo')
BEGIN
    CREATE DATABASE monitoreo;
END
GO

USE monitoreo;
GO

IF OBJECT_ID('dbo.personas', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.personas (
        id_number NVARCHAR(50) PRIMARY KEY,
        nombre NVARCHAR(100),
        apellido NVARCHAR(100),
        fecha_nacimiento DATE
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.personas WHERE id_number = '1023344558')
BEGIN
    INSERT INTO dbo.personas (id_number, nombre, apellido, fecha_nacimiento)
    VALUES ('1023344558','Julian','Coronado','2010-05-12');
END
GO
