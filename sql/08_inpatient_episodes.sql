USE HospitalDW;
GO

DROP VIEW IF EXISTS dw.v_inpatient_episode;
GO

CREATE VIEW dw.v_inpatient_episode AS
WITH inpatient AS (
    -- 步骤 0:只取住院记录
    SELECT f.patient_key, f.encounter_id, f.start_datetime, f.stop_datetime
    FROM dw.fact_encounter f
    JOIN dw.dim_encounter_class c ON f.class_key = c.class_key
    WHERE c.class_code = 'inpatient'
),
flagged AS (
    -- 步骤 1:标记新住院的起点
    SELECT *,
        CASE
            WHEN MAX(stop_datetime) OVER (
                     PARTITION BY patient_key
                     ORDER BY start_datetime, encounter_id
                     ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING) IS NULL
                THEN 1     -- 该患者的第一条记录
            WHEN DATEDIFF(HOUR,
                     MAX(stop_datetime) OVER (
                         PARTITION BY patient_key
                         ORDER BY start_datetime, encounter_id
                         ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING),
                     start_datetime) > 24
                THEN 1     -- 与之前最晚出院间隔超过 24 小时
            ELSE 0         -- 延续同一次住院
        END AS is_new_episode
    FROM inpatient
),
numbered AS (
    -- 步骤 2:累加标记,得到岛屿编号
    SELECT *,
        SUM(is_new_episode) OVER (
            PARTITION BY patient_key
            ORDER BY start_datetime, encounter_id
            ROWS UNBOUNDED PRECEDING) AS episode_no
    FROM flagged
)
-- 步骤 3:按岛屿聚合
SELECT
    patient_key,
    episode_no,
    COUNT(*)            AS n_encounters,      -- 合并了几条原始记录
    MIN(start_datetime) AS admit_datetime,
    MAX(stop_datetime)  AS discharge_datetime,
    DATEDIFF(HOUR, MIN(start_datetime), MAX(stop_datetime)) AS los_hours
FROM numbered
GROUP BY patient_key, episode_no;
GO