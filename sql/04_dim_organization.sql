USE HospitalDW;
GO

DROP TABLE IF EXISTS dw.dim_organization;
CREATE TABLE dw.dim_organization (
    organization_key  INT IDENTITY(1,1) PRIMARY KEY,
    organization_id   NVARCHAR(50)  NOT NULL,
    organization_name NVARCHAR(300) NOT NULL,
    city              NVARCHAR(100) NULL,
    state             NVARCHAR(50)  NULL,
    org_type          NVARCHAR(50)  NOT NULL
);
GO

SET IDENTITY_INSERT dw.dim_organization ON;
INSERT INTO dw.dim_organization (organization_key, organization_id, organization_name, city, state, org_type)
VALUES (-1, 'unknown', 'Unknown', NULL, NULL, 'Unknown');
SET IDENTITY_INSERT dw.dim_organization OFF;

INSERT INTO dw.dim_organization (organization_id, organization_name, city, state, org_type)
SELECT
    Id, NAME, CITY, STATE,
    CASE
        WHEN UPPER(NAME) LIKE '%MANOR%'
          OR UPPER(NAME) LIKE '%NURSING%'
          OR UPPER(NAME) LIKE '%REHAB%'
          OR UPPER(NAME) LIKE '%EXTENDED CARE%'
          OR UPPER(NAME) LIKE '%LIFE CARE%'
          OR UPPER(NAME) LIKE '%CARE CENTER%'
          OR UPPER(NAME) LIKE '%LIVING%'
          OR UPPER(NAME) LIKE '%HOME%'          THEN 'Long-term Care'
        WHEN UPPER(NAME) LIKE '%HOSPITAL%'
          OR UPPER(NAME) LIKE '%MEDICAL CENTER%' THEN 'Hospital'
        WHEN UPPER(NAME) LIKE '%CLINIC%'
          OR UPPER(NAME) LIKE '%HEALTH CENTER%'
          OR UPPER(NAME) LIKE '%PRACTICE%'
          OR UPPER(NAME) LIKE '%ASSOCIATES%'    THEN 'Clinic'
        ELSE 'Other'
    END
FROM stg.organizations
WHERE Id IS NOT NULL AND Id <> '';
GO

-- 分类补丁(第一轮复核后的修正)
UPDATE dw.dim_organization SET org_type = 'Clinic'
WHERE org_type = 'Hospital' AND UPPER(organization_name) LIKE '% PC';

UPDATE dw.dim_organization SET org_type = 'Clinic'
WHERE org_type = 'Other'
  AND (UPPER(organization_name) LIKE '%PRIMARY CARE%'
    OR UPPER(organization_name) LIKE '%FAMILY HEALTH%'
    OR UPPER(organization_name) LIKE '%PEDIATRIC%');

UPDATE dw.dim_organization SET org_type = 'Hospital'
WHERE org_type = 'Other' AND UPPER(organization_name) LIKE 'VA BOSTON%';

UPDATE dw.dim_organization SET org_type = 'Long-term Care'
WHERE org_type = 'Other'
  AND (UPPER(organization_name) LIKE '%HOSPICE%'
    OR UPPER(organization_name) LIKE '%VNA%'
    OR UPPER(organization_name) LIKE '%NURSE%');
GO

SELECT org_type, COUNT(*) AS n FROM dw.dim_organization GROUP BY org_type ORDER BY n DESC;
GO