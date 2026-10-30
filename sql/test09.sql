SELECT
    discharge_year,
    COUNT(*)                                       AS discharges,
    SUM(is_readmit_30d)                            AS readmits_30d,
    CAST(100.0 * SUM(is_readmit_30d) / COUNT(*) AS DECIMAL(5,2)) AS readmit_rate_pct
FROM dw.v_readmission
WHERE discharge_year BETWEEN 2017 AND 2025   -- 只用完整年份
GROUP BY discharge_year
ORDER BY discharge_year;