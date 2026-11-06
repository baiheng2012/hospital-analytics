USE HospitalDW;
GO

DROP VIEW IF EXISTS dw.v_readmission;
GO

CREATE VIEW dw.v_readmission AS
WITH ep AS (
    SELECT
        e.patient_key,
        e.episode_no,
        e.admit_datetime,
        e.discharge_datetime,
        -- LEAD:取同一患者按时间排序的"下一行"的入院时间
        LEAD(e.admit_datetime) OVER (
            PARTITION BY e.patient_key ORDER BY e.admit_datetime) AS next_admit_datetime
    FROM dw.v_inpatient_episode e
)
SELECT
    ep.patient_key,
    ep.episode_no,
    ep.admit_datetime,
    ep.discharge_datetime,
    YEAR(ep.discharge_datetime) AS discharge_year,
    ep.next_admit_datetime,
    DATEDIFF(DAY, ep.discharge_datetime, ep.next_admit_datetime) AS days_to_next_admit,
    CASE
        WHEN ep.next_admit_datetime IS NOT NULL
         AND DATEDIFF(DAY, ep.discharge_datetime, ep.next_admit_datetime) BETWEEN 0 AND 30
        THEN 1 ELSE 0
    END AS is_readmit_30d
FROM ep
JOIN dw.dim_patient p ON ep.patient_key = p.patient_key
-- 排除出院前已死亡的患者
WHERE p.death_date IS NULL OR p.death_date > CAST(ep.discharge_datetime AS DATE);
GO