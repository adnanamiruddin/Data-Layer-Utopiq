-- =====================================================
-- 04. Simple ETL: OLTP -> DWH -> Data Mart
-- Database: PostgreSQL
-- Run order:
--   1) 01_ddl_oltp_and_seed.sql]
--   2) 02_ddl_olap_dwh.sql
--   3) 03_ddl_data_mart.sql
--   4) 04_etl_oltp_to_dwh_to_mart.sql
-- =====================================================

-- =====================================================
-- A. LOAD DIMENSIONS
-- =====================================================

INSERT INTO dwh.dim_date
(date_key, full_date, day_of_month, month_number, month_name, quarter_number, year_number)
SELECT DISTINCT
    TO_CHAR(d::date, 'YYYYMMDD')::INT AS date_key,
    d::date AS full_date,
    EXTRACT(DAY FROM d)::INT AS day_of_month,
    EXTRACT(MONTH FROM d)::INT AS month_number,
    TO_CHAR(d::date, 'Month') AS month_name,
    EXTRACT(QUARTER FROM d)::INT AS quarter_number,
    EXTRACT(YEAR FROM d)::INT AS year_number
FROM (
    SELECT application_date AS d FROM oltp.credit_applications
    UNION SELECT approval_date FROM oltp.credit_applications WHERE approval_date IS NOT NULL
    UNION SELECT disbursement_date FROM oltp.credit_applications WHERE disbursement_date IS NOT NULL
    UNION SELECT due_date FROM oltp.installments
    UNION SELECT payment_date FROM oltp.payments
    UNION SELECT activity_time::date FROM oltp.audit_logs
) all_dates
ORDER BY d;

INSERT INTO dwh.dim_branch (branch_id, branch_code, branch_name, region, city)
SELECT id, branch_code, branch_name, region, city
FROM oltp.branches;

INSERT INTO dwh.dim_user (user_id, employee_number, full_name, role, branch_code)
SELECT u.id, u.employee_number, u.full_name, u.role, b.branch_code
FROM oltp.users u
JOIN oltp.branches b ON b.id = u.branch_id;

INSERT INTO dwh.dim_customer (customer_id, customer_number, full_name, gender, city, income_band)
SELECT
    id,
    customer_number,
    full_name,
    gender,
    city,
    CASE
        WHEN monthly_income < 3000000 THEN 'LOW'
        WHEN monthly_income < 8000000 THEN 'MEDIUM'
        ELSE 'HIGH'
    END AS income_band
FROM oltp.customers;

INSERT INTO dwh.dim_dealer (dealer_id, dealer_code, dealer_name, city)
SELECT id, dealer_code, dealer_name, city
FROM oltp.dealers;

INSERT INTO dwh.dim_vehicle (vehicle_id, brand, model, vehicle_type, price_band)
SELECT
    id,
    brand,
    model,
    vehicle_type,
    CASE
        WHEN price < 25000000 THEN 'ENTRY'
        WHEN price < 35000000 THEN 'MID'
        ELSE 'PREMIUM'
    END AS price_band
FROM oltp.vehicles;

-- =====================================================
-- B. LOAD FACTS
-- =====================================================

INSERT INTO dwh.fact_credit_application
(application_id, application_number, application_date_key, approval_date_key, disbursement_date_key,
 customer_key, branch_key, dealer_key, vehicle_key, surveyor_user_key,
 status, requested_amount, tenor_months, application_count, approved_count, rejected_count, disbursed_count)
SELECT
    ca.id AS application_id,
    ca.application_number,
    app_date.date_key AS application_date_key,
    approval_date.date_key AS approval_date_key,
    disbursement_date.date_key AS disbursement_date_key,
    dc.customer_key,
    db.branch_key,
    dd.dealer_key,
    dv.vehicle_key,
    du.user_key AS surveyor_user_key,
    ca.status,
    ca.requested_amount,
    ca.tenor_months,
    1 AS application_count,
    CASE WHEN ca.status = 'APPROVED' THEN 1 ELSE 0 END AS approved_count,
    CASE WHEN ca.status = 'REJECTED' THEN 1 ELSE 0 END AS rejected_count,
    CASE WHEN ca.status = 'DISBURSED' THEN 1 ELSE 0 END AS disbursed_count
FROM oltp.credit_applications ca
JOIN dwh.dim_date app_date ON app_date.full_date = ca.application_date
LEFT JOIN dwh.dim_date approval_date ON approval_date.full_date = ca.approval_date
LEFT JOIN dwh.dim_date disbursement_date ON disbursement_date.full_date = ca.disbursement_date
JOIN dwh.dim_customer dc ON dc.customer_id = ca.customer_id
JOIN dwh.dim_branch db ON db.branch_id = ca.branch_id
JOIN dwh.dim_dealer dd ON dd.dealer_id = ca.dealer_id
JOIN dwh.dim_vehicle dv ON dv.vehicle_id = ca.vehicle_id
JOIN dwh.dim_user du ON du.user_id = ca.surveyor_user_id;

INSERT INTO dwh.fact_installment
(installment_id, application_id, application_number, due_date_key, customer_key, branch_key,
 installment_no, principal_amount, interest_amount, total_due, status, installment_count, paid_installment_count)
SELECT
    i.id AS installment_id,
    ca.id AS application_id,
    ca.application_number,
    due_date.date_key AS due_date_key,
    dc.customer_key,
    db.branch_key,
    i.installment_no,
    i.principal_amount,
    i.interest_amount,
    i.total_due,
    i.status,
    1 AS installment_count,
    CASE WHEN i.status = 'PAID' THEN 1 ELSE 0 END AS paid_installment_count
FROM oltp.installments i
JOIN oltp.credit_applications ca ON ca.id = i.application_id
JOIN dwh.dim_date due_date ON due_date.full_date = i.due_date
JOIN dwh.dim_customer dc ON dc.customer_id = ca.customer_id
JOIN dwh.dim_branch db ON db.branch_id = ca.branch_id;

INSERT INTO dwh.fact_payment
(payment_id, installment_id, application_id, application_number, payment_date_key, customer_key, branch_key,
 payment_channel, amount_paid, payment_count)
SELECT
    p.id AS payment_id,
    i.id AS installment_id,
    ca.id AS application_id,
    ca.application_number,
    payment_date.date_key AS payment_date_key,
    dc.customer_key,
    db.branch_key,
    p.payment_channel,
    p.amount_paid,
    1 AS payment_count
FROM oltp.payments p
JOIN oltp.installments i ON i.id = p.installment_id
JOIN oltp.credit_applications ca ON ca.id = i.application_id
JOIN dwh.dim_date payment_date ON payment_date.full_date = p.payment_date
JOIN dwh.dim_customer dc ON dc.customer_id = ca.customer_id
JOIN dwh.dim_branch db ON db.branch_id = ca.branch_id;

INSERT INTO dwh.fact_audit_activity
(audit_id, application_id, application_number, activity_date_key, branch_key, user_key, activity_type, activity_count)
SELECT
    al.id AS audit_id,
    ca.id AS application_id,
    ca.application_number,
    activity_date.date_key AS activity_date_key,
    db.branch_key,
    du.user_key,
    al.activity_type,
    1 AS activity_count
FROM oltp.audit_logs al
JOIN oltp.credit_applications ca ON ca.id = al.application_id
JOIN dwh.dim_date activity_date ON activity_date.full_date = al.activity_time::date
JOIN dwh.dim_branch db ON db.branch_id = ca.branch_id
JOIN dwh.dim_user du ON du.user_id = al.user_id;

-- =====================================================
-- C. BUILD DATA MARTS FROM DWH FACTS
-- =====================================================

INSERT INTO mart.mart_application_daily_summary
(summary_date, branch_name, total_applications, approved_applications, rejected_applications, disbursed_applications, total_requested_amount)
SELECT
    dt.full_date AS summary_date,
    db.branch_name,
    SUM(fca.application_count) AS total_applications,
    SUM(fca.approved_count) AS approved_applications,
    SUM(fca.rejected_count) AS rejected_applications,
    SUM(fca.disbursed_count) AS disbursed_applications,
    SUM(fca.requested_amount) AS total_requested_amount
FROM dwh.fact_credit_application fca
JOIN dwh.dim_date dt ON dt.date_key = fca.application_date_key
JOIN dwh.dim_branch db ON db.branch_key = fca.branch_key
GROUP BY dt.full_date, db.branch_name
ORDER BY dt.full_date, db.branch_name;

INSERT INTO mart.mart_collection_monthly_summary
(month_start_date, branch_name, total_due_amount, total_paid_amount, payment_ratio_pct)
WITH due_by_month AS (
    SELECT
        DATE_TRUNC('month', dt.full_date)::date AS month_start_date,
        db.branch_name,
        SUM(fi.total_due) AS total_due_amount
    FROM dwh.fact_installment fi
    JOIN dwh.dim_date dt ON dt.date_key = fi.due_date_key
    JOIN dwh.dim_branch db ON db.branch_key = fi.branch_key
    GROUP BY DATE_TRUNC('month', dt.full_date)::date, db.branch_name
),
paid_by_month AS (
    SELECT
        DATE_TRUNC('month', dt.full_date)::date AS month_start_date,
        db.branch_name,
        SUM(fp.amount_paid) AS total_paid_amount
    FROM dwh.fact_payment fp
    JOIN dwh.dim_date dt ON dt.date_key = fp.payment_date_key
    JOIN dwh.dim_branch db ON db.branch_key = fp.branch_key
    GROUP BY DATE_TRUNC('month', dt.full_date)::date, db.branch_name
)
SELECT
    COALESCE(d.month_start_date, p.month_start_date) AS month_start_date,
    COALESCE(d.branch_name, p.branch_name) AS branch_name,
    COALESCE(d.total_due_amount, 0) AS total_due_amount,
    COALESCE(p.total_paid_amount, 0) AS total_paid_amount,
    CASE
        WHEN COALESCE(d.total_due_amount, 0) = 0 THEN 0
        ELSE ROUND((COALESCE(p.total_paid_amount, 0) / d.total_due_amount) * 100, 2)
    END AS payment_ratio_pct
FROM due_by_month d
FULL OUTER JOIN paid_by_month p
    ON p.month_start_date = d.month_start_date
   AND p.branch_name = d.branch_name
ORDER BY month_start_date, branch_name;

INSERT INTO mart.mart_payment_channel_summary
(payment_date, payment_channel, total_payments, total_paid_amount)
SELECT
    dt.full_date AS payment_date,
    fp.payment_channel,
    SUM(fp.payment_count) AS total_payments,
    SUM(fp.amount_paid) AS total_paid_amount
FROM dwh.fact_payment fp
JOIN dwh.dim_date dt ON dt.date_key = fp.payment_date_key
GROUP BY dt.full_date, fp.payment_channel
ORDER BY dt.full_date, fp.payment_channel;
