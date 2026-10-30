USE HospitalDW;
GO

DROP TABLE IF EXISTS dw.fact_encounter;
CREATE TABLE dw.fact_encounter (
    encounter_key      INT IDENTITY(1,1) PRIMARY KEY,
    encounter_id       NVARCHAR(50)  NOT NULL,
    patient_key        INT NOT NULL,
    provider_key       INT NOT NULL,
    organization_key   INT NOT NULL,
    class_key          INT NOT NULL,
    start_date_key     INT NOT NULL,
    start_datetime     DATETIME2 NOT NULL,
    stop_datetime      DATETIME2 NULL,
    los_hours          INT NULL,
    los_minutes        INT NULL,                                       -- 新增
    los_days           AS (CAST(los_hours AS DECIMAL(10,2)) / 24.0),
    total_claim_cost   DECIMAL(12,2) NULL,
    reason_description NVARCHAR(500) NULL,
    is_outlier         BIT NOT NULL DEFAULT 0                          -- 新增
);


GO

INSERT INTO dw.fact_encounter
    (encounter_id, patient_key, provider_key, organization_key, class_key,
     start_date_key, start_datetime, stop_datetime, los_hours, los_minutes,
     total_claim_cost, reason_description, is_outlier)
SELECT
    e.Id,
    ISNULL(p.patient_key, -1),
    ISNULL(pr.provider_key, -1),
    ISNULL(o.organization_key, -1),
    ISNULL(c.class_key, -1),
    YEAR(s.start_dt) * 10000 + MONTH(s.start_dt) * 100 + DAY(s.start_dt),
    s.start_dt,
    s.stop_dt,
    DATEDIFF(HOUR,   s.start_dt, s.stop_dt),
    DATEDIFF(MINUTE, s.start_dt, s.stop_dt),                           -- 新增
    TRY_CONVERT(DECIMAL(12,2), e.TOTAL_CLAIM_COST),
    NULLIF(e.REASONDESCRIPTION, ''),
    -- 新增:急诊停留超过 72 小时标记为异常(标记不删除)
    CASE WHEN e.ENCOUNTERCLASS = 'emergency'
          AND DATEDIFF(MINUTE, s.start_dt, s.stop_dt) > 72 * 60
         THEN 1 ELSE 0 END
FROM stg.encounters e
CROSS APPLY (
    SELECT TRY_CONVERT(DATETIME2, e.START) AS start_dt,
           TRY_CONVERT(DATETIME2, e.STOP)  AS stop_dt
) s
LEFT JOIN dw.dim_patient            p  ON e.PATIENT        = p.patient_id
LEFT JOIN dw.dim_provider           pr ON e.PROVIDER       = pr.provider_id
LEFT JOIN dw.dim_organization       o  ON e.ORGANIZATION   = o.organization_id
LEFT JOIN dw.dim_encounter_class    c  ON e.ENCOUNTERCLASS = c.class_code
WHERE s.start_dt IS NOT NULL;
GO

CREATE INDEX IX_fact_encounter_class_date ON dw.fact_encounter (class_key, start_date_key);
CREATE INDEX IX_fact_encounter_patient    ON dw.fact_encounter (patient_key, start_datetime);
GO