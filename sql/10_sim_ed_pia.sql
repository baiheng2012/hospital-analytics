USE HospitalDW;
GO

DROP VIEW IF EXISTS dw.sim_ed_pia;
GO

CREATE VIEW dw.sim_ed_pia AS
WITH ed AS (
    SELECT
        f.encounter_key,
        f.encounter_id,
        f.start_datetime,
        f.los_minutes,
        DATEPART(HOUR, f.start_datetime)  AS arrival_hour,
        MONTH(f.start_datetime)           AS arrival_month,
        (DATEPART(WEEKDAY, f.start_datetime) + @@DATEFIRST - 2) % 7 + 1 AS weekday_num,
        -- 确定性"随机数":由 encounter_id 哈希得到 0~1 之间的固定小数
        (ABS(CHECKSUM(f.encounter_id)) % 10000) / 10000.0 AS u
    FROM dw.fact_encounter f
    JOIN dw.dim_encounter_class c ON f.class_key = c.class_key
    WHERE c.class_code = 'emergency'
      AND f.is_outlier = 0             -- -- 异常标记在 07 脚本里统一定义
),
factors AS (
    SELECT *,
        -- 时段系数:白天高、凌晨低
        CASE WHEN arrival_hour BETWEEN 10 AND 21 THEN 1.3
             WHEN arrival_hour BETWEEN 6  AND 9  THEN 1.0
             ELSE 0.7 END AS hour_factor,
        -- 周一高峰
        CASE WHEN weekday_num = 1 THEN 1.2 ELSE 1.0 END AS weekday_factor,
        -- 冬季(12、1、2 月)呼吸道疾病高峰
        CASE WHEN arrival_month IN (12, 1, 2) THEN 1.25 ELSE 1.0 END AS season_factor
    FROM ed
)
SELECT
    encounter_key,
    encounter_id,
    start_datetime,
    arrival_hour,
    arrival_month,
    weekday_num,
    los_minutes,
    -- 基准 30 分钟 × 各系数 × 随机波动(0.5~1.5),并且不超过总停留时间
    CAST(
        CASE WHEN 30 * hour_factor * weekday_factor * season_factor * (0.5 + u) > los_minutes
             THEN los_minutes
             ELSE 30 * hour_factor * weekday_factor * season_factor * (0.5 + u)
        END AS INT) AS sim_pia_minutes,
    'SIMULATED' AS data_source_flag
FROM factors;
GO