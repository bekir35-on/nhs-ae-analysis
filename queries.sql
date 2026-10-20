-- NHS England A&E analysis: SQL queries (SQLite)
-- Table ae_monthly: 24 monthly provider files (Oct 2024 - Sep 2026), snake_case columns

-- 1. Monthly Type 1 four-hour performance: UHL (RWE) vs England (TOTAL row)
DROP VIEW IF EXISTS monthly_type1;
CREATE VIEW monthly_type1 AS
WITH type1 AS (
    SELECT month, org_code,
           a_e_attendances_type_1 + a_e_attendances_booked_appointments_type_1 AS attendances,
           attendances_over_4hrs_type_1 + attendances_over_4hrs_booked_appointments_type_1 AS over_4hrs
    FROM ae_monthly
    WHERE org_code IN ('RWE', 'TOTAL')
)
SELECT month,
       100.0 * SUM(CASE WHEN org_code = 'RWE' THEN attendances - over_4hrs END)
             / SUM(CASE WHEN org_code = 'RWE' THEN attendances END) AS uhl,
       100.0 * SUM(CASE WHEN org_code = 'TOTAL' THEN attendances - over_4hrs END)
             / SUM(CASE WHEN org_code = 'TOTAL' THEN attendances END) AS england
FROM type1
GROUP BY month
ORDER BY month
;

-- 2. Winter (December-February) vs the rest of the year
SELECT CASE WHEN substr(month, 6, 2) IN ('12', '01', '02') THEN 'Winter (Dec-Feb)'
            ELSE 'Rest of year' END AS season,
       COUNT(*) AS months,
       ROUND(AVG(uhl), 1) AS uhl,
       ROUND(AVG(england), 1) AS england,
       ROUND(AVG(uhl - england), 1) AS gap
FROM monthly_type1
GROUP BY season
ORDER BY season;
