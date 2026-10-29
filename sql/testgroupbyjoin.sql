SELECT YEAR(TRY_CONVERT(DATETIME2, START)) AS yr,
       COUNT(*) AS n
FROM stg.encounters
GROUP BY YEAR(TRY_CONVERT(DATETIME2, START))
ORDER BY yr;

SELECT AVG(DATEDIFF(HOUR,
                    TRY_CONVERT(DATETIME2, START),
                    TRY_CONVERT(DATETIME2, STOP)) / 24.0) AS avg_los_days
FROM stg.encounters
WHERE ENCOUNTERCLASS = 'inpatient';



SELECT TOP 10
    e.Id AS encounter_id,
    e.ENCOUNTERCLASS,
    p.GENDER,
    p.BIRTHDATE
FROM stg.encounters e
JOIN stg.patients p
    ON e.PATIENT = p.Id;




SELECT p.GENDER, COUNT(*) AS inpatient_count
FROM stg.encounters e
JOIN stg.patients p ON e.PATIENT = p.Id
WHERE e.ENCOUNTERCLASS = 'inpatient'
GROUP BY p.GENDER;


SELECT TOP 10
    o.NAME,
    COUNT(*) AS emergency_count
FROM stg.encounters e
JOIN stg.organizations o
    ON e.ORGANIZATION = o.Id
WHERE e.ENCOUNTERCLASS = 'emergency'
GROUP BY o.NAME
ORDER BY emergency_count DESC;
