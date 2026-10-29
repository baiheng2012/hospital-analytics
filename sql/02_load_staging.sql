USE HospitalDW;
GO

TRUNCATE TABLE stg.patients;
BULK INSERT stg.patients
FROM '/data/patients.csv'
WITH (
    FORMAT = 'CSV',           -- 按标准 CSV 解析(处理带引号和逗号的字段)
    FIRSTROW = 2,             -- 跳过表头
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',   -- Linux 换行符
    TABLOCK                   -- 表级锁,加快批量导入
);

TRUNCATE TABLE stg.encounters;
BULK INSERT stg.encounters
FROM '/data/encounters.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDTERMINATOR = ',',
      ROWTERMINATOR = '0x0a', TABLOCK);

TRUNCATE TABLE stg.organizations;
BULK INSERT stg.organizations
FROM '/data/organizations.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDTERMINATOR = ',',
      ROWTERMINATOR = '0x0a', TABLOCK);

TRUNCATE TABLE stg.providers;
BULK INSERT stg.providers
FROM '/data/providers.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDTERMINATOR = ',',
      ROWTERMINATOR = '0x0a', TABLOCK);
GO

-- 验证行数
SELECT 'patients' AS tbl, COUNT(*) AS n FROM stg.patients
UNION ALL SELECT 'encounters', COUNT(*) FROM stg.encounters
UNION ALL SELECT 'organizations', COUNT(*) FROM stg.organizations
UNION ALL SELECT 'providers', COUNT(*) FROM stg.providers;