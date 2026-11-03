USE HospitalDW;
GO

-- KPI 1:住院 LOS(按出院年,仅完整年份 2017-2025)
DROP VIEW IF EXISTS dw.v_kpi_inpatient_los;
GO
CREATE VIEW dw.v_kpi_inpatient_los AS
SELECT
    patient_key,
    episode_no,
    n_encounters,
    admit_datetime,
    discharge_datetime,
    YEAR(discharge_datetime) AS discharge_year,
    YEAR(discharge_datetime) * 10000 + MONTH(discharge_datetime) * 100 + DAY(discharge_datetime) AS discharge_date_key,
    los_hours / 24.0         AS los_days
FROM dw.v_inpatient_episode
WHERE YEAR(discharge_datetime) BETWEEN 2017 AND 2025;
GO

-- KPI 2:30 天再入院(直接复用 v_readmission,限定完整年份)
DROP VIEW IF EXISTS dw.v_kpi_readmission;
GO
CREATE VIEW dw.v_kpi_readmission AS
SELECT patient_key, episode_no, discharge_year, discharge_datetime,
       days_to_next_admit, is_readmit_30d,    
       YEAR(discharge_datetime) * 10000 + MONTH(discharge_datetime) * 100 + DAY(discharge_datetime) AS discharge_date_key
FROM dw.v_readmission
WHERE discharge_year BETWEEN 2017 AND 2025;
GO

-- KPI 3:急诊(真实 ED LOS + 模拟 PIA,带标记)
DROP VIEW IF EXISTS dw.v_kpi_ed;
GO
CREATE VIEW dw.v_kpi_ed AS
SELECT
    f.encounter_key,
    f.start_datetime,
    f.start_date_key,
    YEAR(f.start_datetime)         AS arrival_year,
    DATEPART(HOUR, f.start_datetime) AS arrival_hour,
    f.los_minutes                  AS ed_los_minutes,   -- 真实
    f.is_outlier,
    s.sim_pia_minutes,                                  -- 模拟
    ISNULL(s.data_source_flag, 'N/A') AS pia_source_flag
FROM dw.fact_encounter f
JOIN dw.dim_encounter_class c ON f.class_key = c.class_key
LEFT JOIN dw.sim_ed_pia s     ON f.encounter_key = s.encounter_key
WHERE c.class_code = 'emergency'
  AND YEAR(f.start_datetime) BETWEEN 2017 AND 2025;
GO

-- 验证行数
SELECT (SELECT COUNT(*) FROM dw.v_kpi_inpatient_los) AS los_rows,
       (SELECT COUNT(*) FROM dw.v_kpi_readmission)   AS readmit_rows,
       (SELECT COUNT(*) FROM dw.v_kpi_ed)            AS ed_rows;
GO