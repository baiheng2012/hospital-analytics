USE HospitalDW;
GO

DROP TABLE IF EXISTS dw.dim_patient;
CREATE TABLE dw.dim_patient (
    patient_key   INT IDENTITY(1,1) PRIMARY KEY,
    patient_id    NVARCHAR(50) NOT NULL,   -- 原始 UUID(业务键)
    gender        NVARCHAR(10) NULL,
    birth_date    DATE NULL,
    death_date    DATE NULL,
    race          NVARCHAR(50) NULL,
    ethnicity     NVARCHAR(50) NULL,
    marital_status NVARCHAR(10) NULL,
    city          NVARCHAR(100) NULL,
    county        NVARCHAR(100) NULL,
    state         NVARCHAR(100) NULL
);

-- 未知行
SET IDENTITY_INSERT dw.dim_patient ON;
INSERT INTO dw.dim_patient (patient_key, patient_id) VALUES (-1, 'unknown');
SET IDENTITY_INSERT dw.dim_patient OFF;

-- 加载。注意:不选 SSN、DRIVERS、PASSPORT、姓名、详细地址、经纬度
INSERT INTO dw.dim_patient
    (patient_id, gender, birth_date, death_date, race, ethnicity, marital_status, city, county, state)
SELECT
    Id,
    NULLIF(GENDER, ''),
    TRY_CONVERT(DATE, BIRTHDATE),
    TRY_CONVERT(DATE, NULLIF(DEATHDATE, '')),
    NULLIF(RACE, ''),
    NULLIF(ETHNICITY, ''),
    NULLIF(MARITAL, ''),
    NULLIF(CITY, ''),
    NULLIF(COUNTY, ''),
    NULLIF(STATE, '')
FROM stg.patients
WHERE Id IS NOT NULL AND Id <> '';
GO

-- 对账 + 质量检查
SELECT COUNT(*) AS n_patients FROM dw.dim_patient WHERE patient_key <> -1;            -- 应为 3396

SELECT COUNT(*) AS bad_birthdate FROM dw.dim_patient
WHERE patient_key <> -1 AND birth_date IS NULL;                                       -- 应为 0

SELECT COUNT(*) AS death_before_birth FROM dw.dim_patient
WHERE death_date < birth_date;                                                        -- 应为 0
GO