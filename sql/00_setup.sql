-- 创建数据库(已存在则跳过)
IF DB_ID('HospitalDW') IS NULL CREATE DATABASE HospitalDW;
GO
USE HospitalDW;
GO
-- 创建 schema(已存在则跳过)。CREATE SCHEMA 必须是批处理第一句,所以套一层 EXEC
IF SCHEMA_ID('stg') IS NULL EXEC('CREATE SCHEMA stg');
IF SCHEMA_ID('dw')  IS NULL EXEC('CREATE SCHEMA dw');
IF SCHEMA_ID('etl') IS NULL EXEC('CREATE SCHEMA etl');
GO