USE HospitalDW;
GO

-- 对账结果表:每次运行追加记录,保留历史
IF OBJECT_ID('etl.reconciliation_log') IS NULL
CREATE TABLE etl.reconciliation_log (
    check_id     INT IDENTITY(1,1) PRIMARY KEY,
    checked_at   DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    check_name   NVARCHAR(100) NOT NULL,
    expected     BIGINT NOT NULL,
    actual       BIGINT NOT NULL,
    passed       AS (CASE WHEN expected = actual THEN 1 ELSE 0 END)
);
GO

-- 检查 1~3:行数对账(期望值来自源数据本身,不写死)
INSERT INTO etl.reconciliation_log (check_name, expected, actual)
SELECT 'fact rows = staging rows',
       (SELECT COUNT(*) FROM stg.encounters),
       (SELECT COUNT(*) FROM dw.fact_encounter);

INSERT INTO etl.reconciliation_log (check_name, expected, actual)
SELECT 'unknown dimension keys in fact = 0', 0,
       (SELECT COUNT(*) FROM dw.fact_encounter
         WHERE patient_key = -1 OR provider_key = -1
            OR organization_key = -1 OR class_key = -1);

INSERT INTO etl.reconciliation_log (check_name, expected, actual)
SELECT 'inpatient episodes + merged = raw inpatient',
       (SELECT COUNT(*) FROM dw.fact_encounter f
          JOIN dw.dim_encounter_class c ON f.class_key = c.class_key
         WHERE c.class_code = 'inpatient'),
       (SELECT SUM(n_encounters) FROM dw.v_inpatient_episode);

-- 检查 4:key 一致性。事实表的类型和 staging 原始类型逐条比较,抓"key 错位"
INSERT INTO etl.reconciliation_log (check_name, expected, actual)
SELECT 'class_key matches staging class (mismatches = 0)', 0,
       (SELECT COUNT(*)
          FROM dw.fact_encounter f
          JOIN dw.dim_encounter_class c ON f.class_key = c.class_key
          JOIN stg.encounters e ON f.encounter_id = e.Id
         WHERE c.class_code <> e.ENCOUNTERCLASS);
GO

-- 有任何一项不通过就报错,让运行器把这一步标记为 FAILED
IF EXISTS (SELECT 1 FROM etl.reconciliation_log
            WHERE passed = 0
              AND checked_at >= DATEADD(MINUTE, -5, SYSDATETIME()))
    RAISERROR('Reconciliation failed. See etl.reconciliation_log', 16, 1);
GO

SELECT TOP 4 check_name, expected, actual, passed
FROM etl.reconciliation_log ORDER BY check_id DESC;
GO