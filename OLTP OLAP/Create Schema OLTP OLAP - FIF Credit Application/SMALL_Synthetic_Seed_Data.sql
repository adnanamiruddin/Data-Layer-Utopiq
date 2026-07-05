-- =====================================================
-- FIF Credit Application - SMALL Synthetic Seed Data
-- PostgreSQL only
-- Schema: fifapp_credit_dashboard
-- =====================================================

SET search_path TO fifapp_credit_dashboard;
SET client_min_messages TO warning;

TRUNCATE TABLE
    audit_logs,
    payments,
    installments,
    risk_assessments,
    credit_applications,
    vehicles,
    dealers,
    customers,
    users,
    branches
RESTART IDENTITY CASCADE;

SELECT setseed(0.42);

SET synchronous_commit = off;

-- =====================================================
-- 1) MASTER / REFERENCE DATA
-- =====================================================

INSERT INTO branches (
    branch_code, branch_name, region, city, address,
    created_at, updated_at
)
WITH base AS (
    SELECT
        gs,
        TIMESTAMP '2023-01-01 08:00:00'
            + ((random() * 540)::int || ' days')::interval
            + ((random() * 9)::int || ' hours')::interval AS created_ts
    FROM generate_series(1, 100) gs
)
SELECT
    'BR' || LPAD(gs::text, 4, '0') AS branch_code,
    'FIF Branch ' || gs AS branch_name,
    (ARRAY['Jabodetabek', 'West Java', 'Central Java', 'East Java', 'Bali Nusra', 'Sumatra', 'Kalimantan', 'Sulawesi'])[1 + ((gs - 1) % 8)] AS region,
    (ARRAY['Jakarta', 'Bogor', 'Depok', 'Tangerang', 'Bekasi', 'Bandung', 'Semarang', 'Surabaya', 'Denpasar', 'Medan', 'Palembang', 'Makassar'])[1 + ((gs - 1) % 12)] AS city,
    'Jl. Training Data No. ' || gs AS address,
    created_ts,
    created_ts + ((random() * 420)::int || ' days')::interval
FROM base;

INSERT INTO users (
    branch_id, employee_number, username, full_name, role, is_active,
    created_at, updated_at
)
WITH base AS (
    SELECT
        gs,
        TIMESTAMP '2023-01-15 08:00:00'
            + ((random() * 650)::int || ' days')::interval
            + ((random() * 10)::int || ' hours')::interval AS created_ts
    FROM generate_series(1, 1000) gs
)
SELECT
    1 + ((gs - 1) % 100) AS branch_id,
    'EMP' || LPAD(gs::text, 6, '0') AS employee_number,
    'user' || LPAD(gs::text, 6, '0') AS username,
    'Employee ' || gs AS full_name,
    CASE
        WHEN gs % 100 < 60 THEN 'AGENT'
        WHEN gs % 100 < 80 THEN 'CREDIT_ANALYST'
        WHEN gs % 100 < 90 THEN 'COLLECTION'
        WHEN gs % 100 < 97 THEN 'SUPERVISOR'
        ELSE 'ADMIN'
    END AS role,
    CASE WHEN gs % 50 = 0 THEN FALSE ELSE TRUE END AS is_active,
    created_ts,
    created_ts + ((random() * 365)::int || ' days')::interval
FROM base;

INSERT INTO customers (
    customer_number, full_name, nik, birth_date, gender, phone_number, email, address, city,
    occupation, monthly_income, income_range,
    created_at, updated_at
)
WITH base AS (
    SELECT
        gs,
        (random() * 100)::int AS bucket,
        TIMESTAMP '2023-01-01 07:00:00'
            + ((random() * 900)::int || ' days')::interval
            + ((random() * 12)::int || ' hours')::interval AS created_ts
    FROM generate_series(1, 10000) gs
)
SELECT
    'CUST' || LPAD(gs::text, 8, '0') AS customer_number,
    'Customer ' || gs AS full_name,
    '3275' || LPAD(gs::text, 12, '0') AS nik,
    DATE '1965-01-01' + ((random() * 15000)::int) AS birth_date,
    CASE WHEN random() < 0.52 THEN 'MALE' ELSE 'FEMALE' END AS gender,
    '08' || LPAD((1000000000 + gs)::text, 10, '0') AS phone_number,
    'customer' || gs || '@example.com' AS email,
    'Alamat Customer No. ' || gs AS address,
    (ARRAY['Jakarta', 'Bogor', 'Depok', 'Tangerang', 'Bekasi', 'Bandung', 'Semarang', 'Surabaya', 'Denpasar', 'Medan', 'Palembang', 'Makassar'])[1 + ((gs - 1) % 12)] AS city,
    (ARRAY['Employee', 'Entrepreneur', 'Teacher', 'Driver', 'Merchant', 'Freelancer', 'Civil Servant'])[1 + ((gs - 1) % 7)] AS occupation,
    CASE
        WHEN bucket < 30 THEN (2500000 + random() * 2500000)::numeric(18,2)
        WHEN bucket < 75 THEN (5000000 + random() * 7000000)::numeric(18,2)
        WHEN bucket < 95 THEN (12000000 + random() * 18000000)::numeric(18,2)
        ELSE (30000000 + random() * 70000000)::numeric(18,2)
    END AS monthly_income,
    CASE
        WHEN bucket < 30 THEN 'LOW'
        WHEN bucket < 75 THEN 'MEDIUM'
        WHEN bucket < 95 THEN 'HIGH'
        ELSE 'VERY_HIGH'
    END AS income_range,
    created_ts,
    created_ts + ((random() * 360)::int || ' days')::interval
FROM base;

INSERT INTO dealers (
    dealer_code, dealer_name, city, region, is_active,
    created_at, updated_at
)
WITH base AS (
    SELECT
        gs,
        TIMESTAMP '2023-01-01 08:00:00'
            + ((random() * 700)::int || ' days')::interval
            + ((random() * 10)::int || ' hours')::interval AS created_ts
    FROM generate_series(1, 500) gs
)
SELECT
    'DLR' || LPAD(gs::text, 5, '0') AS dealer_code,
    'Dealer Partner ' || gs AS dealer_name,
    (ARRAY['Jakarta', 'Bogor', 'Depok', 'Tangerang', 'Bekasi', 'Bandung', 'Semarang', 'Surabaya', 'Denpasar', 'Medan', 'Palembang', 'Makassar'])[1 + ((gs - 1) % 12)] AS city,
    (ARRAY['Jabodetabek', 'West Java', 'Central Java', 'East Java', 'Bali Nusra', 'Sumatra', 'Kalimantan', 'Sulawesi'])[1 + ((gs - 1) % 8)] AS region,
    CASE WHEN gs % 40 = 0 THEN FALSE ELSE TRUE END AS is_active,
    created_ts,
    created_ts + ((random() * 520)::int || ' days')::interval
FROM base;

INSERT INTO vehicles (
    dealer_id, vehicle_code, brand, model, vehicle_type, vehicle_category,
    production_year, is_new, price,
    created_at, updated_at
)
WITH base AS (
    SELECT
        gs,
        TIMESTAMP '2023-02-01 08:00:00'
            + ((random() * 760)::int || ' days')::interval
            + ((random() * 10)::int || ' hours')::interval AS created_ts
    FROM generate_series(1, 5000) gs
)
SELECT
    1 + ((gs - 1) % 500) AS dealer_id,
    'VH' || LPAD(gs::text, 7, '0') AS vehicle_code,
    CASE
        WHEN gs % 10 < 8 THEN (ARRAY['Honda', 'Yamaha', 'Suzuki', 'Kawasaki'])[1 + ((gs - 1) % 4)]
        ELSE (ARRAY['Toyota', 'Daihatsu', 'Mitsubishi', 'Honda'])[1 + ((gs - 1) % 4)]
    END AS brand,
    CASE
        WHEN gs % 10 < 8 THEN 'Motor Model ' || (1 + (gs % 30))
        ELSE 'Car Model ' || (1 + (gs % 20))
    END AS model,
    CASE WHEN gs % 10 < 8 THEN 'MOTORCYCLE' ELSE 'CAR' END AS vehicle_type,
    CASE
        WHEN gs % 10 < 8 THEN (ARRAY['MATIC', 'SPORT'])[1 + (gs % 2)]
        ELSE (ARRAY['SUV', 'MPV', 'COMMERCIAL'])[1 + (gs % 3)]
    END AS vehicle_category,
    2017 + (gs % 9) AS production_year,
    CASE WHEN gs % 5 = 0 THEN FALSE ELSE TRUE END AS is_new,
    CASE
        WHEN gs % 10 < 8 THEN (18000000 + random() * 22000000)::numeric(18,2)
        ELSE (180000000 + random() * 250000000)::numeric(18,2)
    END AS price,
    created_ts,
    created_ts + ((random() * 420)::int || ' days')::interval
FROM base;

-- =====================================================
-- 2) CREDIT APPLICATIONS
-- =====================================================

INSERT INTO credit_applications (
    application_number, customer_id, vehicle_id, branch_id, created_by,
    application_date, vehicle_price, dp_amount, loan_amount, approved_amount,
    tenor_months, interest_rate, status,
    submitted_at, approved_at, rejected_at, manual_review_at, cancelled_at,
    decision_reason,
    created_at, updated_at
)
WITH app_base AS (
    SELECT
        gs,
        1 + ((random() * 9999)::int) AS customer_id,
        1 + ((random() * 4999)::int) AS vehicle_id,
        1 + ((random() * 99)::int) AS branch_id,
        1 + ((random() * 599)::int) AS created_by,
        DATE '2024-01-01' + ((random() * 895)::int) AS application_date,
        (random() * 100)::int AS status_bucket,
        (ARRAY[12, 18, 24, 30, 36])[1 + ((random() * 4)::int)] AS tenor_months
    FROM generate_series(1, 30000) gs
),
priced AS (
    SELECT
        b.*,
        v.price AS vehicle_price,
        CASE
            WHEN b.status_bucket < 55 THEN 'APPROVED'
            WHEN b.status_bucket < 75 THEN 'REJECTED'
            WHEN b.status_bucket < 90 THEN 'MANUAL_REVIEW'
            WHEN b.status_bucket < 95 THEN 'CANCELLED'
            WHEN b.status_bucket < 99 THEN 'SUBMITTED'
            ELSE 'DRAFT'
        END AS status
    FROM app_base b
    JOIN vehicles v ON v.id = b.vehicle_id
),
amounts AS (
    SELECT
        *,
        (vehicle_price * (0.10 + random() * 0.25))::numeric(18,2) AS dp_amount
    FROM priced
),
timeline AS (
    SELECT
        *,
        application_date::timestamp
            + ((8 + random() * 8)::int || ' hours')::interval
            + ((random() * 59)::int || ' minutes')::interval AS created_ts,

        CASE
            WHEN status <> 'DRAFT'
            THEN application_date::timestamp
                + ((1 + random() * 10)::int || ' hours')::interval
                + ((random() * 59)::int || ' minutes')::interval
            ELSE NULL
        END AS submitted_ts
    FROM amounts
),
final_timeline AS (
    SELECT
        *,
        CASE
            WHEN status = 'APPROVED'
            THEN submitted_ts + ((4 + random() * 72)::int || ' hours')::interval
            ELSE NULL
        END AS approved_ts,
        CASE
            WHEN status = 'REJECTED'
            THEN submitted_ts + ((4 + random() * 72)::int || ' hours')::interval
            ELSE NULL
        END AS rejected_ts,
        CASE
            WHEN status = 'MANUAL_REVIEW'
            THEN submitted_ts + ((4 + random() * 48)::int || ' hours')::interval
            ELSE NULL
        END AS manual_review_ts,
        CASE
            WHEN status = 'CANCELLED'
            THEN submitted_ts + ((1 + random() * 24)::int || ' hours')::interval
            ELSE NULL
        END AS cancelled_ts
    FROM timeline
)
SELECT
    'APP' || LPAD(gs::text, 8, '0') AS application_number,
    customer_id,
    vehicle_id,
    branch_id,
    created_by,
    application_date,
    vehicle_price,
    dp_amount,
    (vehicle_price - dp_amount)::numeric(18,2) AS loan_amount,
    CASE
        WHEN status = 'APPROVED'
        THEN (vehicle_price - dp_amount)::numeric(18,2)
        ELSE NULL
    END AS approved_amount,
    tenor_months,
    (8 + random() * 10)::numeric(5,2) AS interest_rate,
    status,
    submitted_ts,
    approved_ts,
    rejected_ts,
    manual_review_ts,
    cancelled_ts,
    CASE
        WHEN status = 'APPROVED' THEN 'Eligible based on score and income capacity'
        WHEN status = 'REJECTED' THEN 'Rejected due to risk policy or affordability issue'
        WHEN status = 'MANUAL_REVIEW' THEN 'Needs analyst review due to borderline profile'
        WHEN status = 'CANCELLED' THEN 'Cancelled by customer or branch'
        ELSE NULL
    END AS decision_reason,
    created_ts,
    COALESCE(
        approved_ts,
        rejected_ts,
        manual_review_ts,
        cancelled_ts,
        submitted_ts,
        created_ts
    ) + ((random() * 6)::int || ' hours')::interval AS updated_at
FROM final_timeline;

-- =====================================================
-- 3) RISK ASSESSMENTS
-- =====================================================

INSERT INTO risk_assessments (
    credit_application_id, assessed_by, risk_score, risk_level, decision,
    income_score, age_score, loan_amount_score, dbr_score, previous_payment_score,
    dbr_percentage, notes, assessed_at,
    created_at, updated_at
)
WITH base AS (
    SELECT
        ca.id,
        ca.status,
        1 + ((random() * 399)::int) + 600 AS assessed_by,
        CASE
            WHEN ca.status = 'APPROVED' THEN 60 + ((random() * 40)::int)
            WHEN ca.status = 'MANUAL_REVIEW' THEN 40 + ((random() * 30)::int)
            WHEN ca.status = 'REJECTED' THEN ((random() * 50)::int)
            ELSE 30 + ((random() * 50)::int)
        END AS risk_score,
        (10 + random() * 65)::numeric(5,2) AS dbr_percentage,
        COALESCE(
            ca.approved_at,
            ca.rejected_at,
            ca.manual_review_at,
            ca.cancelled_at,
            ca.submitted_at,
            ca.application_date::timestamp
        ) AS base_assessed_at
    FROM credit_applications ca
    WHERE ca.status <> 'DRAFT'
),
timeline AS (
    SELECT
        *,
        base_assessed_at + ((random() * 4)::int || ' hours')::interval AS assessed_ts
    FROM base
)
SELECT
    id AS credit_application_id,
    assessed_by,
    risk_score,
    CASE
        WHEN risk_score >= 70 THEN 'LOW'
        WHEN risk_score >= 45 THEN 'MEDIUM'
        ELSE 'HIGH'
    END AS risk_level,
    CASE
        WHEN status = 'APPROVED' THEN 'APPROVED'
        WHEN status = 'REJECTED' THEN 'REJECTED'
        ELSE 'MANUAL_REVIEW'
    END AS decision,
    LEAST(100, GREATEST(0, risk_score + ((random() * 20)::int - 10))) AS income_score,
    LEAST(100, GREATEST(0, risk_score + ((random() * 20)::int - 10))) AS age_score,
    LEAST(100, GREATEST(0, risk_score + ((random() * 20)::int - 10))) AS loan_amount_score,
    LEAST(100, GREATEST(0, risk_score + ((random() * 20)::int - 10))) AS dbr_score,
    LEAST(100, GREATEST(0, risk_score + ((random() * 20)::int - 10))) AS previous_payment_score,
    dbr_percentage,
    'Synthetic assessment for training data' AS notes,
    assessed_ts,
    assessed_ts,
    assessed_ts + ((random() * 12)::int || ' hours')::interval
FROM timeline;

-- =====================================================
-- 4) INSTALLMENTS
-- More realistic:
-- - Future due_date relative to as_of_date stays UNPAID
-- - Past due_date can be PAID, LATE, PARTIAL_PAID, DEFAULTED, or UNPAID
-- =====================================================

INSERT INTO installments (
    credit_application_id, installment_number, due_date,
    amount, paid_amount, outstanding_amount,
    payment_date, days_overdue, status,
    created_at, updated_at
)
WITH params AS (
    SELECT DATE '2026-06-30' AS as_of_date
),
app AS (
    SELECT
        id AS credit_application_id,
        application_date,
        loan_amount,
        tenor_months,
        approved_at
    FROM credit_applications
    WHERE status = 'APPROVED'
),
inst_base AS (
    SELECT
        a.credit_application_id,
        gs AS installment_number,
        (a.application_date + (gs || ' months')::interval)::date AS due_date,
        (a.loan_amount / a.tenor_months)::numeric(18,2) AS amount,
        COALESCE(a.approved_at, a.application_date::timestamp) AS base_created_at,
        (random() * 100)::int AS status_bucket,
        (random() * 60)::int AS overdue_random,
        p.as_of_date
    FROM app a
    CROSS JOIN params p
    CROSS JOIN LATERAL generate_series(1, a.tenor_months) gs
),
classified AS (
    SELECT
        *,
        CASE
            WHEN due_date > as_of_date THEN 'UNPAID'
            WHEN status_bucket < 62 THEN 'PAID'
            WHEN status_bucket < 75 THEN 'UNPAID'
            WHEN status_bucket < 88 THEN 'LATE'
            WHEN status_bucket < 96 THEN 'PARTIAL_PAID'
            ELSE 'DEFAULTED'
        END AS status
    FROM inst_base
),
payment_calc AS (
    SELECT
        *,
        CASE
            WHEN status = 'PAID' THEN amount
            WHEN status = 'LATE' THEN amount
            WHEN status = 'PARTIAL_PAID' THEN (amount * (0.25 + random() * 0.60))::numeric(18,2)
            ELSE 0::numeric(18,2)
        END AS calculated_paid_amount
    FROM classified
),
date_calc AS (
    SELECT
        *,
        CASE
            WHEN status = 'PAID'
                THEN GREATEST(
                    due_date - ((random() * 5)::int),
                    base_created_at::date
                )
            WHEN status = 'LATE'
                THEN LEAST(
                    due_date + (1 + overdue_random),
                    as_of_date
                )
            WHEN status = 'PARTIAL_PAID'
                THEN LEAST(
                    due_date + ((random() * 15)::int),
                    as_of_date
                )
            ELSE NULL
        END AS calculated_payment_date
    FROM payment_calc
)
SELECT
    credit_application_id,
    installment_number,
    due_date,
    amount,
    calculated_paid_amount AS paid_amount,
    GREATEST(amount - calculated_paid_amount, 0)::numeric(18,2) AS outstanding_amount,
    calculated_payment_date AS payment_date,
    CASE
        WHEN status IN ('LATE', 'DEFAULTED') THEN GREATEST(as_of_date - due_date, 1)
        WHEN status = 'PARTIAL_PAID' THEN GREATEST(COALESCE(calculated_payment_date, as_of_date) - due_date, 0)
        ELSE 0
    END AS days_overdue,
    status,
    base_created_at + ((installment_number - 1) || ' months')::interval AS created_at,
    COALESCE(
        calculated_payment_date::timestamp,
        LEAST(as_of_date, due_date)::timestamp
    ) + ((random() * 8)::int || ' hours')::interval AS updated_at
FROM date_calc;

-- =====================================================
-- 5) PAYMENTS
-- =====================================================

INSERT INTO payments (
    installment_id, paid_by, payment_number, payment_date, payment_amount,
    payment_method, payment_channel,
    created_at
)
WITH base AS (
    SELECT
        i.id AS installment_id,
        1 + ((random() * 999)::int) AS paid_by,
        'PAY' || LPAD(i.id::text, 10, '0') AS payment_number,
        i.payment_date AS payment_date,
        i.paid_amount AS payment_amount,
        random() AS method_bucket,
        random() AS channel_bucket
    FROM installments i
    WHERE i.paid_amount > 0
      AND i.payment_date IS NOT NULL
)
SELECT
    installment_id,
    paid_by,
    payment_number,
    payment_date,
    payment_amount,
    CASE
        WHEN method_bucket < 0.35 THEN 'VIRTUAL_ACCOUNT'
        WHEN method_bucket < 0.65 THEN 'TRANSFER'
        WHEN method_bucket < 0.85 THEN 'CASH'
        ELSE 'AUTODEBIT'
    END AS payment_method,
    CASE
        WHEN channel_bucket < 0.35 THEN 'MOBILE_APP'
        WHEN channel_bucket < 0.65 THEN 'BANK'
        WHEN channel_bucket < 0.85 THEN 'BRANCH'
        ELSE 'PARTNER'
    END AS payment_channel,
    payment_date::timestamp
        + ((7 + random() * 12)::int || ' hours')::interval
        + ((random() * 59)::int || ' minutes')::interval AS created_at
FROM base;

-- =====================================================
-- 6) AUDIT LOGS
-- =====================================================

INSERT INTO audit_logs (
    user_id, entity_name, entity_id, action, old_value, new_value,
    ip_address, user_agent, created_at
)
SELECT
    created_by AS user_id,
    'credit_applications' AS entity_name,
    id AS entity_id,
    'CREATE' AS action,
    NULL AS old_value,
    '{"status":"DRAFT"}' AS new_value,
    '10.10.' || (id % 255) || '.' || ((id * 7) % 255) AS ip_address,
    'Mozilla/5.0 Training Browser' AS user_agent,
    created_at
FROM credit_applications;

INSERT INTO audit_logs (
    user_id, entity_name, entity_id, action, old_value, new_value,
    ip_address, user_agent, created_at
)
SELECT
    created_by,
    'credit_applications',
    id,
    'SUBMIT',
    '{"status":"DRAFT"}',
    '{"status":"SUBMITTED"}',
    '10.20.' || (id % 255) || '.' || ((id * 11) % 255),
    'Mozilla/5.0 Training Browser',
    submitted_at
FROM credit_applications
WHERE submitted_at IS NOT NULL;

INSERT INTO audit_logs (
    user_id, entity_name, entity_id, action, old_value, new_value,
    ip_address, user_agent, created_at
)
SELECT
    COALESCE(ra.assessed_by, ca.created_by),
    'credit_applications',
    ca.id,
    CASE
        WHEN ca.status = 'APPROVED' THEN 'APPROVE'
        WHEN ca.status = 'REJECTED' THEN 'REJECT'
        ELSE 'UPDATE'
    END,
    '{"status":"SUBMITTED"}',
    '{"status":"' || ca.status || '"}',
    '10.30.' || (ca.id % 255) || '.' || ((ca.id * 13) % 255),
    'Mozilla/5.0 Training Browser',
    COALESCE(
        ca.approved_at,
        ca.rejected_at,
        ca.manual_review_at,
        ca.cancelled_at,
        ca.updated_at
    )
FROM credit_applications ca
LEFT JOIN risk_assessments ra
    ON ra.credit_application_id = ca.id
WHERE ca.status IN ('APPROVED', 'REJECTED', 'MANUAL_REVIEW', 'CANCELLED');

INSERT INTO audit_logs (
    user_id, entity_name, entity_id, action, old_value, new_value,
    ip_address, user_agent, created_at
)
SELECT
    paid_by,
    'payments',
    id,
    'PAYMENT',
    NULL,
    '{"payment_amount":' || payment_amount || '}',
    '10.40.' || (id % 255) || '.' || ((id * 17) % 255),
    'Payment Channel Simulator',
    created_at
FROM payments
WHERE id % 3 = 0;

INSERT INTO audit_logs (
    user_id, entity_name, entity_id, action, old_value, new_value,
    ip_address, user_agent, created_at
)
SELECT
    1 + ((random() * 999)::int),
    'users',
    1 + ((random() * 999)::int),
    'LOGIN',
    NULL,
    '{"login":"success"}',
    '10.50.' || (gs % 255) || '.' || ((gs * 19) % 255),
    'Mozilla/5.0 Training Browser',
    TIMESTAMP '2024-01-01 06:00:00'
        + ((random() * 912)::int || ' days')::interval
        + ((random() * 16)::int || ' hours')::interval
        + ((random() * 59)::int || ' minutes')::interval
FROM generate_series(1, 20000) gs;

-- =====================================================
-- 7) VALIDATION
-- =====================================================

SELECT 'branches' AS table_name, COUNT(*) AS total_rows FROM branches
UNION ALL SELECT 'users', COUNT(*) FROM users
UNION ALL SELECT 'customers', COUNT(*) FROM customers
UNION ALL SELECT 'dealers', COUNT(*) FROM dealers
UNION ALL SELECT 'vehicles', COUNT(*) FROM vehicles
UNION ALL SELECT 'credit_applications', COUNT(*) FROM credit_applications
UNION ALL SELECT 'risk_assessments', COUNT(*) FROM risk_assessments
UNION ALL SELECT 'installments', COUNT(*) FROM installments
UNION ALL SELECT 'payments', COUNT(*) FROM payments
UNION ALL SELECT 'audit_logs', COUNT(*) FROM audit_logs
ORDER BY table_name;

-- Optional date distribution checks for dashboard simulation

SELECT
    MIN(created_at) AS min_created_at,
    MAX(created_at) AS max_created_at
FROM credit_applications;

SELECT
    MIN(application_date) AS min_application_date,
    MAX(application_date) AS max_application_date
FROM credit_applications;

SELECT
    MIN(payment_date) AS min_payment_date,
    MAX(payment_date) AS max_payment_date
FROM payments;

SELECT
    status,
    COUNT(*) AS total_installments,
    MIN(due_date) AS min_due_date,
    MAX(due_date) AS max_due_date
FROM installments
GROUP BY status
ORDER BY status;