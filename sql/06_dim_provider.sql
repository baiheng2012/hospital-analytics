USE HospitalDW;
GO

DROP TABLE IF EXISTS dw.dim_provider;
CREATE TABLE dw.dim_provider (
    provider_key  INT IDENTITY(1,1) PRIMARY KEY,
    provider_id   NVARCHAR(50)  NOT NULL,
    provider_name NVARCHAR(200) NULL,
    specialty     NVARCHAR(200) NULL,
    gender        NVARCHAR(10)  NULL
);

SET IDENTITY_INSERT dw.dim_provider ON;
INSERT INTO dw.dim_provider (provider_key, provider_id, provider_name, specialty)
VALUES (-1, 'unknown', 'Unknown', 'Unknown');
SET IDENTITY_INSERT dw.dim_provider OFF;

INSERT INTO dw.dim_provider (provider_id, provider_name, specialty, gender)
SELECT Id, NULLIF(NAME, ''), NULLIF(SPECIALITY, ''), NULLIF(GENDER, '')
FROM stg.providers
WHERE Id IS NOT NULL AND Id <> '';
GO

SELECT COUNT(*) AS n FROM dw.dim_provider WHERE provider_key <> -1;   -- 应为 1024
SELECT specialty, COUNT(*) AS n FROM dw.dim_provider
GROUP BY specialty ORDER BY n DESC;
GO