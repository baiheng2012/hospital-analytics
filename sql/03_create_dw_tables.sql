USE HospitalDW;
GO

-- ============ dim_encounter_class:就诊类型维度 ============
DROP TABLE IF EXISTS dw.dim_encounter_class;
CREATE TABLE dw.dim_encounter_class (
    class_key       INT IDENTITY(1,1) PRIMARY KEY,  -- 代理键,自动从 1 递增
    class_code      NVARCHAR(50)  NOT NULL,         -- 原始值,如 'inpatient'
    class_name      NVARCHAR(100) NOT NULL,         -- 展示名称
    class_group     NVARCHAR(50)  NOT NULL          -- 分组:Acute / Ambulatory / Other
);

-- 先放一个"未知"行,key 固定为 -1(IDENTITY 列默认不允许手动插入,需要临时打开)
SET IDENTITY_INSERT dw.dim_encounter_class ON;
INSERT INTO dw.dim_encounter_class (class_key, class_code, class_name, class_group)
VALUES (-1, 'unknown', 'Unknown', 'Unknown');
SET IDENTITY_INSERT dw.dim_encounter_class OFF;

-- 从 staging 里取出所有不重复的类型,自动填入
INSERT INTO dw.dim_encounter_class (class_code, class_name, class_group)
SELECT DISTINCT
    ENCOUNTERCLASS,
    UPPER(LEFT(ENCOUNTERCLASS, 1)) + SUBSTRING(ENCOUNTERCLASS, 2, 50),  -- 首字母大写
    CASE
        WHEN ENCOUNTERCLASS IN ('emergency', 'inpatient') THEN 'Acute'
        WHEN ENCOUNTERCLASS IN ('ambulatory', 'outpatient', 'wellness', 'urgentcare', 'virtual') THEN 'Ambulatory'
        ELSE 'Other'
    END
FROM stg.encounters
WHERE ENCOUNTERCLASS IS NOT NULL AND ENCOUNTERCLASS <> '';
GO

SELECT * FROM dw.dim_encounter_class ORDER BY class_key;
GO


-- ============ dim_date:日期维度 ============
DROP TABLE IF EXISTS dw.dim_date;
CREATE TABLE dw.dim_date (
    date_key      INT PRIMARY KEY,      -- 格式 yyyymmdd,如 20230418
    full_date     DATE NOT NULL,
    year_num      SMALLINT NOT NULL,
    quarter_num   TINYINT NOT NULL,
    month_num     TINYINT NOT NULL,
    month_name    NVARCHAR(20) NOT NULL,
    day_of_month  TINYINT NOT NULL,
    weekday_num   TINYINT NOT NULL,     -- 1=周一 ... 7=周日
    weekday_name  NVARCHAR(20) NOT NULL,
    is_weekend    BIT NOT NULL,
    fiscal_year   SMALLINT NOT NULL     -- 安省医院财年:4/1 到次年 3/31
);

-- 用递归 CTE 生成 2010-01-01 到 2030-12-31 的每一天
WITH d AS (
    SELECT CAST('2010-01-01' AS DATE) AS dt
    UNION ALL
    SELECT DATEADD(DAY, 1, dt) FROM d WHERE dt < '2030-12-31'
)
INSERT INTO dw.dim_date
SELECT
    YEAR(dt) * 10000 + MONTH(dt) * 100 + DAY(dt),
    dt,
    YEAR(dt),
    DATEPART(QUARTER, dt),
    MONTH(dt),
    DATENAME(MONTH, dt),
    DAY(dt),
    (DATEPART(WEEKDAY, dt) + @@DATEFIRST - 2) % 7 + 1,
    DATENAME(WEEKDAY, dt),
    CASE WHEN (DATEPART(WEEKDAY, dt) + @@DATEFIRST - 2) % 7 + 1 >= 6 THEN 1 ELSE 0 END,
    CASE WHEN MONTH(dt) >= 4 THEN YEAR(dt) + 1 ELSE YEAR(dt) END
FROM d
OPTION (MAXRECURSION 10000);   -- 默认递归上限 100 层,这里要 7670 天,必须调高
GO

SELECT COUNT(*) AS days, MIN(full_date) AS first_day, MAX(full_date) AS last_day FROM dw.dim_date;
GO