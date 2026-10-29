-- 查看 SQL Server 版本,验证连接成功
SELECT @@VERSION;

-- 创建项目数据库
CREATE DATABASE HospitalDW;
GO
-- 切换到该数据库
USE HospitalDW;
GO
-- 创建三个 schema(命名空间),对应数仓三层
CREATE SCHEMA stg;   -- staging:原始数据落地层,原样保存
GO
CREATE SCHEMA dw;    -- data warehouse:清洗后的维度表和事实表
GO
CREATE SCHEMA etl;   -- 存放 ETL 日志和存储过程
GO